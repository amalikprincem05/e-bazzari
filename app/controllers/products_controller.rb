class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  def index
    @products = Product.in_stock
    @products = @products.by_category(params[:category]) if params[:category].present?
    @products = @products.search(params[:q]) if params[:q].present?
    @products = @products.page(params[:page]).per(12)
    @categories = Product.distinct.pluck(:category).compact
    @search_term = params[:q]
  end

  def show
    @cart_item = CartItem.new
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end
end
