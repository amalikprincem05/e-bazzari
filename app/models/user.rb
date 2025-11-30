require 'securerandom'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :orders, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :referrals, class_name: 'User', foreign_key: :referred_by_id, dependent: :nullify
  belongs_to :referrer, class_name: 'User', optional: true, foreign_key: :referred_by_id

  validates :first_name, :last_name, presence: true
  validates :phone, presence: true, on: :create
  validates :phone, format: { with: /\A\+?\d{10,15}\z/, message: "must be a valid phone number" }, allow_blank: true
  validates :phone, uniqueness: { case_sensitive: false }, allow_blank: true
  validates :cnic, presence: true, on: :create
  validates :cnic, format: { with: /\A\d{13}\z/, message: "must be a 13-digit CNIC number" }, allow_blank: true
  validate :enforce_cnic_limits, if: -> { cnic.present? }
  validates :referral_code, uniqueness: { case_sensitive: false }, allow_blank: true
  validate :referral_code_input_valid, if: -> { referral_code_input.present? && new_record? }

  attr_accessor :referral_code_input

  before_validation :assign_referrer_from_code, if: -> { referral_code_input.present? && new_record? }
  before_create :generate_unique_referral_code
  after_create :award_referral_points, if: -> { referrer.present? }

  REFERRER_BONUS = 50
  NEW_USER_BONUS = 20

  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    super_admin? || self[:admin]
  end

  def super_admin?
    self[:super_admin]
  end

  def cart_total
    cart_items.sum(&:total_price)
  end

  def cart_items_count
    cart_items.sum(:quantity)
  end

  def has_items_in_cart?
    cart_items.any?
  end

  def clear_cart!
    cart_items.destroy_all
  end

  def add_points!(amount)
    update!(points: points + amount)
  end

  def deduct_points!(amount)
    raise ArgumentError, "Insufficient points" if points < amount
    update!(points: points - amount)
  end

  def can_use_points?(amount)
    points >= amount && amount > 0
  end

  def max_points_usable_for(total_amount)
    [points, total_amount.to_i].min
  end

  private

  def assign_referrer_from_code
    return if referred_by_id.present?
    referrer = User.find_by(referral_code: referral_code_input.to_s.strip.upcase)
    self.referrer = referrer if referrer.present?
  end

  def referral_code_input_valid
    return if User.exists?(referral_code: referral_code_input.to_s.strip.upcase)

    errors.add(:referral_code_input, 'is invalid or expired')
  end

  def generate_unique_referral_code
    return if referral_code.present?

    loop do
      self.referral_code = SecureRandom.alphanumeric(8).upcase
      break unless User.exists?(referral_code: referral_code)
    end
  end

  def award_referral_points
    referrer.increment!(:points, REFERRER_BONUS)
    increment!(:points, NEW_USER_BONUS)
  end

  def enforce_cnic_limits
    if created_by_admin?
      admin_accounts = User.where(cnic: cnic, created_by_admin: true).where.not(id: id)
      if admin_accounts.count >= 5
        errors.add(:cnic, "already has 5 admin-managed accounts")
      end
    else
      existing = User.where(cnic: cnic).where.not(id: id)
      if existing.exists?
        errors.add(:cnic, "is already registered")
      end
    end
  end
end
