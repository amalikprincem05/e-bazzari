class CartItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart_item, only: [:update, :destroy]

  def create
    product_id = params[:product_id] || params.dig(:cart_item, :product_id)
    quantity = params[:quantity] || params.dig(:cart_item, :quantity) || 1
    
    @cart_item = current_user.cart_items.find_or_initialize_by(product_id: product_id)
    @cart_item.quantity = (@cart_item.quantity || 0) + quantity.to_i

    if @cart_item.save
      redirect_to cart_path, notice: 'Product added to cart successfully!'
    else
      redirect_to product_path(product_id), alert: 'Failed to add product to cart.'
    end
  end

  def update
    if @cart_item.update(cart_item_params)
      redirect_to cart_path, notice: 'Cart updated successfully!'
    else
      redirect_to cart_path, alert: 'Failed to update cart item.'
    end
  end

  def destroy
    @cart_item.destroy
    redirect_to cart_path, notice: 'Item removed from cart.'
  end

  private

  def set_cart_item
    @cart_item = current_user.cart_items.find(params[:id])
  end

  def cart_item_params
    params.require(:cart_item).permit(:quantity)
  end
end
