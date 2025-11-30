# Clear existing data
puts "Clearing existing data..."
User.destroy_all
Product.destroy_all
Order.destroy_all
OrderItem.destroy_all
CartItem.destroy_all

puts "\n=== Creating Users ==="

# Create 1 Super Admin
puts "Creating super admin..."
super_admin = User.create!(
  first_name: "Super",
  last_name: "Admin",
  email: "superadmin@ebazzari.com",
  password: "password123",
  password_confirmation: "password123",
  phone: "+923001234567",
  cnic: "3520212345670",
  admin: true,
  super_admin: true,
  created_by_admin: true,
  points: 1000
)
puts "✓ Super Admin created: #{super_admin.email}"

# Create 2 Admins
puts "Creating admins..."
admin1 = User.create!(
  first_name: "Admin",
  last_name: "One",
  email: "admin1@ebazzari.com",
  password: "password123",
  password_confirmation: "password123",
  phone: "+923001234568",
  cnic: "3520212345671",
  admin: true,
  super_admin: false,
  created_by_admin: true,
  points: 500
)
puts "✓ Admin 1 created: #{admin1.email}"

admin2 = User.create!(
  first_name: "Admin",
  last_name: "Two",
  email: "admin2@ebazzari.com",
  password: "password123",
  password_confirmation: "password123",
  phone: "+923001234569",
  cnic: "3520212345672",
  admin: true,
  super_admin: false,
  created_by_admin: true,
  points: 500
)
puts "✓ Admin 2 created: #{admin2.email}"

# Create 10 Normal Users
puts "Creating 10 normal users..."
10.times do |i|
  # Generate 13-digit CNIC: 35202 (5 digits) + 8 digits
  cnic_suffix = sprintf("%08d", 10000000 + i)
  phone_suffix = sprintf("%07d", 1000000 + i)
  
  user = User.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: "user#{i+1}@example.com",
    password: "password123",
    password_confirmation: "password123",
    phone: "+92300#{phone_suffix}",
    cnic: "35202#{cnic_suffix}",
    admin: false,
    super_admin: false,
    created_by_admin: false,
    points: rand(0..200)
  )
  puts "✓ User #{i+1} created: #{user.email} (Points: #{user.points})"
end

puts "\n=== Creating Products ==="

# Product categories
categories = ["Electronics", "Clothing", "Home & Garden", "Sports", "Books", "Beauty", "Toys", "Automotive"]

# Product names for better variety
product_names = [
  "Smartphone Pro Max", "Wireless Headphones", "Laptop Stand", "Gaming Mouse", "USB-C Cable",
  "Cotton T-Shirt", "Denim Jeans", "Running Shoes", "Winter Jacket", "Baseball Cap",
  "Coffee Maker", "Desk Lamp", "Plant Pot", "Throw Pillow", "Wall Clock",
  "Basketball", "Yoga Mat", "Dumbbells", "Tennis Racket", "Soccer Ball",
  "Mystery Novel", "Cookbook", "Biography", "Science Fiction", "History Book",
  "Face Cream", "Lipstick", "Shampoo", "Perfume", "Sunscreen"
]

# Create 30 Products
30.times do |i|
  product = Product.create!(
    name: product_names[i] || Faker::Commerce.product_name,
    description: Faker::Lorem.paragraph(sentence_count: 3),
    price: Faker::Commerce.price(range: 10.0..500.0),
    category: categories.sample,
    stock_quantity: Faker::Number.between(from: 5, to: 100)
  )
  puts "✓ Product #{i+1} created: #{product.name} ($#{product.price})"
end

# Mark 8 products as featured ads
puts "\n=== Marking Featured Products ==="
featured_products = Product.in_stock.sample(8)
featured_badges = ["Featured", "Best Seller", "Hot Deal", "Limited Offer", "New Arrival", "Special", "Trending", "Popular"]

featured_products.each_with_index do |product, index|
  product.update!(
    featured_ad: true,
    featured_badge: featured_badges[index] || "Featured",
    featured_priority: index
  )
  puts "✓ Featured: #{product.name} (#{product.featured_badge})"
end

puts "\n=== Creating Sample Orders ==="

# Create some orders for normal users
normal_users = User.where(admin: false, super_admin: false).limit(5)
normal_users.each do |user|
  # Create cart items first
  products = Product.in_stock.sample(rand(1..4))
  products.each do |product|
    CartItem.create!(
      user: user,
      product: product,
      quantity: Faker::Number.between(from: 1, to: 3)
    )
  end
  
  # Create order
  total = user.cart_items.sum(&:total_price)
  points_used = [0, rand(0..[user.points, total.to_i].min)].sample
  
  order = Order.create!(
    user: user,
    total_amount: total,
    status: ['pending', 'paid', 'shipped', 'delivered'].sample,
    points_used: points_used
  )
  
  # Create order items
  user.cart_items.each do |cart_item|
    OrderItem.create!(
      order: order,
      product: cart_item.product,
      quantity: cart_item.quantity,
      unit_price: cart_item.product.price
    )
  end
  
  # Deduct points if used
  if points_used > 0
    user.update!(points: user.points - points_used)
  end
  
  # Clear cart after order
  user.cart_items.destroy_all
  puts "✓ Order created for #{user.email} (Total: $#{total}, Points used: #{points_used})"
end

puts "\n=== Seed Data Summary ==="
puts "Users: #{User.count}"
puts "  - Super Admins: #{User.where(super_admin: true).count}"
puts "  - Admins: #{User.where(admin: true, super_admin: false).count}"
puts "  - Customers: #{User.where(admin: false).count}"
puts "Products: #{Product.count}"
puts "  - Featured Products: #{Product.where(featured_ad: true).count}"
puts "  - In Stock: #{Product.in_stock.count}"
puts "Orders: #{Order.count}"
puts "Order Items: #{OrderItem.count}"
puts "\n=== Login Credentials ==="
puts "Super Admin: superadmin@ebazzari.com / password123"
puts "Admin 1: admin1@ebazzari.com / password123"
puts "Admin 2: admin2@ebazzari.com / password123"
puts "Users: user1@example.com to user10@example.com / password123"
puts "\n✓ Seed data created successfully!"