class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show]

  def index
    @orders = current_user.orders.order(created_at: :desc)
    
    # Debug: Log current orders count
    Rails.logger.info "User #{current_user.id} has #{@orders.count} orders"
    
    # Handle Stripe checkout success
    if params[:session_id]
      begin
        Stripe.api_key = ENV['STRIPE_SECRET_KEY']
        session = Stripe::Checkout::Session.retrieve(params[:session_id])
        
        Rails.logger.info "Processing session #{params[:session_id]} with payment status: #{session.payment_status}"
        
        if session.payment_status == 'paid'
          # Check if order already exists (from webhook)
          existing_order = current_user.orders.find_by(stripe_payment_intent_id: session.payment_intent)
          
          if existing_order
            # Order already exists from webhook
            Rails.logger.info "Order #{existing_order.id} already exists from webhook"
            flash[:success] = 'Payment successful! Your order has been processed.'
          elsif current_user.has_items_in_cart?
            # Fallback: Create order if webhook didn't work
            Rails.logger.info "Creating fallback order for user #{current_user.id}"
            create_order_from_session(session)
            flash[:success] = 'Payment successful! Your order has been processed and your cart has been cleared.'
          else
            # No cart items and no existing order - something went wrong
            Rails.logger.warn "No cart items found for user #{current_user.id} after payment"
            flash[:alert] = 'Payment was successful but no order was created. Please contact support.'
          end
          
          # Ensure cart is cleared
          if current_user.has_items_in_cart?
            Rails.logger.warn "Cart not cleared for user #{current_user.id} after successful payment"
            current_user.clear_cart!
          end
        else
          flash[:alert] = 'Payment was not completed successfully. Please try again.'
        end
      rescue Stripe::StripeError => e
        Rails.logger.error "Stripe error retrieving session #{params[:session_id]}: #{e.message}"
        flash[:alert] = 'There was an issue processing your payment. Please contact support.'
      end
    end
  end

  def show
  end

  def debug
    # Debug action to check orders in database
    @all_orders = Order.all.order(created_at: :desc)
    @user_orders = current_user.orders.order(created_at: :desc)
    
    Rails.logger.info "DEBUG: Total orders in database: #{@all_orders.count}"
    Rails.logger.info "DEBUG: Orders for user #{current_user.id}: #{@user_orders.count}"
    
    render json: {
      total_orders: @all_orders.count,
      user_orders: @user_orders.count,
      user_id: current_user.id,
      orders: @user_orders.map { |o| { id: o.id, total: o.total_amount, status: o.status, created_at: o.created_at } }
    }
  end

  def create
    subtotal = calculate_cart_total
    points_to_use = params[:points_to_use].to_i
    points_to_use = [points_to_use, current_user.points, subtotal.to_i].min
    points_to_use = 0 if points_to_use < 0
    final_amount = [subtotal - points_to_use, 0].max

    @order = current_user.orders.build(
      total_amount: subtotal,
      status: 'pending',
      points_used: points_to_use
    )

    if @order.save
      create_order_items
      if points_to_use > 0
        current_user.deduct_points!(points_to_use)
      end
      current_user.cart_items.destroy_all
      redirect_to @order, notice: 'Order placed successfully!'
    else
      redirect_to cart_path, alert: 'Failed to create order.'
    end
  end

  private

  def set_order
    if current_user.admin?
      @order = Order.find(params[:id])
    else
      @order = current_user.orders.find(params[:id])
    end
  end

  def calculate_cart_total
    current_user.cart_items.sum(&:total_price)
  end

  def create_order_items
    current_user.cart_items.each do |cart_item|
      @order.order_items.create!(
        product: cart_item.product,
        quantity: cart_item.quantity,
        unit_price: cart_item.product.price
      )
    end
  end

  def create_order_from_session(session)
    # Fallback method to create order when webhook doesn't work
    cart_items = current_user.cart_items.includes(:product)
    
    if cart_items.any?
      total_amount = current_user.cart_total
      points_used = (session.metadata&.points_used || 0).to_i
      
      # Create order
      order = current_user.orders.create!(
        total_amount: total_amount,
        status: 'paid',
        stripe_payment_intent_id: session.payment_intent,
        points_used: points_used
      )
      
      # Create order items
      cart_items.each do |cart_item|
        order.order_items.create!(
          product: cart_item.product,
          quantity: cart_item.quantity,
          unit_price: cart_item.product.price
        )
      end
      
      # Deduct points if used
      if points_used > 0
        current_user.deduct_points!(points_used)
      end
      
      # Clear cart
      current_user.clear_cart!
      
      Rails.logger.info "Fallback order #{order.id} created for user #{current_user.id} with total $#{total_amount}, points used: #{points_used}"
    end
  end
end
