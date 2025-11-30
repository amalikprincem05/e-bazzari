class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]
  before_action :authenticate_user!, only: [:create_checkout_session]
  
  def create_checkout_session
    # Set Stripe API key
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    
    # Get cart items
    cart_items = current_user.cart_items.includes(:product)
    
    if cart_items.empty?
      redirect_to cart_path, alert: 'Your cart is empty!'
      return
    end
    
    # Calculate totals with points
    subtotal = cart_items.sum(&:total_price)
    points_to_use = params[:points_to_use].to_i
    points_to_use = [points_to_use, current_user.points, subtotal.to_i].min
    points_to_use = 0 if points_to_use < 0
    
    final_amount = [subtotal - points_to_use, 0].max
    
    # If order is fully paid with points, create order directly
    if final_amount <= 0 && points_to_use > 0
      create_order_with_points(points_to_use, cart_items)
      redirect_to orders_path, notice: 'Order placed successfully using points!'
      return
    end
    
    # Create line items for Stripe checkout
    # If points are used, adjust line items proportionally to reflect the discount
    if points_to_use > 0 && subtotal > 0
      discount_ratio = final_amount / subtotal
      line_items = cart_items.map do |item|
        discounted_price = (item.product.price * discount_ratio).round(2)
        {
          price_data: {
            currency: 'usd',
            product_data: {
              name: item.product.name,
              description: item.product.description&.truncate(100),
              images: item.product.image.attached? ? [url_for(item.product.image)] : []
            },
            unit_amount: (discounted_price * 100).to_i # Convert to cents
          },
          quantity: item.quantity
        }
      end
    else
      line_items = cart_items.map do |item|
        {
          price_data: {
            currency: 'usd',
            product_data: {
              name: item.product.name,
              description: item.product.description&.truncate(100),
              images: item.product.image.attached? ? [url_for(item.product.image)] : []
            },
            unit_amount: (item.product.price * 100).to_i # Convert to cents
          },
          quantity: item.quantity
        }
      end
    end
    
    # Create checkout session
    session_obj = Stripe::Checkout::Session.create({
      payment_method_types: ['card'],
      line_items: line_items,
      mode: 'payment',
      success_url: "#{request.base_url}/orders?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "#{request.base_url}/cart",
      customer_email: current_user.email,
      metadata: {
        user_id: current_user.id,
        points_used: points_to_use.to_s
      }
    })
    
    # Redirect to Stripe checkout
    redirect_to session_obj.url, allow_other_host: true
  end
  
  def create_order_with_points(points_to_use, cart_items)
    subtotal = cart_items.sum(&:total_price)
    
    # Create order
    order = current_user.orders.create!(
      total_amount: subtotal,
      status: 'paid',
      points_used: points_to_use
    )
    
    # Create order items
    cart_items.each do |cart_item|
      order.order_items.create!(
        product: cart_item.product,
        quantity: cart_item.quantity,
        unit_price: cart_item.product.price
      )
    end
    
    # Deduct points
    current_user.deduct_points!(points_to_use)
    
    # Clear cart
    current_user.clear_cart!
    
    Rails.logger.info "Order #{order.id} created with #{points_to_use} points for user #{current_user.id}"
  end
  
  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

    case event.type
    when 'checkout.session.completed'
      handle_checkout_success(event.data.object)
    when 'payment_intent.succeeded'
      handle_payment_success(event.data.object)
    when 'payment_intent.payment_failed'
      handle_payment_failure(event.data.object)
    end

    render json: { status: 'success' }
  end

  private

  def handle_checkout_success(session)
    # Create order from successful checkout
    user = User.find(session.metadata.user_id)
    points_used = session.metadata.points_used.to_i
    
    if user.has_items_in_cart?
      # Calculate total before clearing cart
      total_amount = user.cart_total
      cart_items = user.cart_items.includes(:product)
      
      # Create order
      order = user.orders.create!(
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
        user.deduct_points!(points_used)
      end
      
      # Clear cart after successful order creation
      user.clear_cart!
      
      # Log successful order creation
      Rails.logger.info "Order #{order.id} created successfully for user #{user.id} with total $#{total_amount}, points used: #{points_used}"
    else
      Rails.logger.warn "No cart items found for user #{user.id} during checkout success"
    end
  end

  def handle_payment_success(payment_intent)
    # Update order status to paid
    order = Order.find_by(stripe_payment_intent_id: payment_intent.id)
    if order
      order.update!(status: 'paid')
      # Send confirmation email here if needed
    end
  end

  def handle_payment_failure(payment_intent)
    # Handle payment failure
    order = Order.find_by(stripe_payment_intent_id: payment_intent.id)
    if order
      order.update!(status: 'cancelled')
      # Send failure notification here if needed
    end
  end
end
