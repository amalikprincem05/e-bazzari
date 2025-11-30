class HomeController < ApplicationController
  def index
    @featured_products = Product.in_stock.order(created_at: :desc).limit(6)
    @categories = Product.distinct.pluck(:category).compact
    @ad_products = Product.featured_ads.includes(image_attachment: :blob).limit(8)
  end
end
