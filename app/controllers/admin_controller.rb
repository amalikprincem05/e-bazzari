class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def dashboard
    @total_products = Product.count
    @total_orders = Order.count
    @total_users = User.count
    @recent_orders = Order.order(created_at: :desc).limit(5)
    @low_stock_products = Product.where('stock_quantity < ?', 10)
  end

  def products
    @products = Product.all.order(created_at: :desc)
  end

  def new_product
    @product = Product.new
    @categories = Product.distinct.pluck(:category).compact
  end

  def create_product
    @product = Product.new(product_params)
    
    if @product.save
      redirect_to admin_products_path, notice: 'Product created successfully!'
    else
      @categories = Product.distinct.pluck(:category).compact
      render :new_product
    end
  end

  def edit_product
    @product = Product.find(params[:id])
    @categories = Product.distinct.pluck(:category).compact
  end

  def update_product
    @product = Product.find(params[:id])
    
    if @product.update(product_params)
      redirect_to admin_products_path, notice: 'Product updated successfully!'
    else
      @categories = Product.distinct.pluck(:category).compact
      render :edit_product
    end
  end

  def delete_product
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to admin_products_path, notice: 'Product deleted successfully!'
  end

  def orders
    @orders = Order.includes(:user, :order_items).order(created_at: :desc)
    
    # Filter by user if search parameter is provided
    if params[:user_search].present?
      search_term = params[:user_search].strip
      
      # Search by user ID or email
      if search_term.match?(/^\d+$/)
        # Search by user ID
        user = User.find_by(id: search_term)
        @orders = @orders.where(user: user) if user
      else
        # Search by email
        user = User.find_by(email: search_term)
        @orders = @orders.where(user: user) if user
      end
      
      @searched_user = user
    end
  end

  def update_order_status
    @order = Order.find(params[:id])
    new_status = params[:status]
    
    if @order.update(status: new_status)
      redirect_to admin_orders_path, notice: "Order status updated to #{new_status.titleize} successfully!"
    else
      redirect_to admin_orders_path, alert: "Failed to update order status."
    end
  end

  def users
    @users = User.order(created_at: :desc)
    @new_user = User.new(created_by_admin: true)
  end

  def create_user
    @new_user = User.new(admin_user_params.merge(created_by_admin: true))

    if @new_user.save
      redirect_to admin_users_path, notice: 'Customer account created successfully.'
    else
      @users = User.order(created_at: :desc)
      flash.now[:alert] = 'Unable to create account. Please review the errors below.'
      render :users, status: :unprocessable_entity
    end
  end

  private

  def ensure_admin
    unless current_user&.admin?
      redirect_to root_path, alert: 'Access denied. Admin privileges required.'
    end
  end

  def product_params
    params.require(:product).permit(
      :name,
      :description,
      :price,
      :category,
      :stock_quantity,
      :image,
      :featured_ad,
      :featured_badge,
      :featured_priority
    )
  end

  def admin_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :cnic, :password, :password_confirmation)
  end
end
