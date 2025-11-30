class Product < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_one_attached :image

  validates :name, :price, :stock_quantity, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :featured_badge, presence: true, if: :featured_ad?
  validates :featured_priority, numericality: { greater_than_or_equal_to: 0 }

  scope :in_stock, -> { where('stock_quantity > 0') }
  scope :by_category, ->(category) { where(category: category) }
  scope :featured_ads, -> { where(featured_ad: true).order(featured_priority: :asc, updated_at: :desc) }
  scope :search, lambda { |term|
    sanitized = "%#{term.to_s.downcase.strip}%"
    where('LOWER(name) LIKE :term OR LOWER(description) LIKE :term OR LOWER(category) LIKE :term', term: sanitized)
  }

  def available?
    stock_quantity > 0
  end
end
