class CartsController < ApplicationController
  before_action :authenticate_user!

  def show
    @cart_items = current_user.cart_items.includes(:product)
    @subtotal = @cart_items.sum(&:total_price)
    @points_to_use = params[:points_to_use].to_i
    @points_to_use = [@points_to_use, current_user.points, @subtotal.to_i].min
    @points_to_use = 0 if @points_to_use < 0
    @total = [@subtotal - @points_to_use, 0].max
  end

  def destroy
    current_user.cart_items.destroy_all
    redirect_to cart_path, notice: 'Cart cleared successfully!'
  end
end
