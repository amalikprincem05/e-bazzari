# E-Bazzari E-commerce Platform

A modern, fully-featured e-commerce website built with Ruby on Rails and Bootstrap 5, featuring beautiful user authentication, comprehensive product catalog, shopping cart functionality, and complete order management system.

## ✨ Features

### 🔐 **Enhanced User Authentication**
- **Beautiful Sign In/Sign Up Pages**: Modern, responsive design with Bootstrap 5
- **Complete User Management**: Profile editing, password reset, account deletion
- **Form Validation**: Client-side and server-side validation with helpful feedback
- **Security**: Devise-powered authentication with secure password handling
- **User Profiles**: First name, last name, phone, and address management

### 🛍️ **Product Catalog & Shopping**
- **Product Catalog**: Browse products by category with pagination
- **Product Details**: Detailed product pages with images and descriptions
- **Category Filtering**: Filter products by categories
- **Stock Management**: Real-time inventory tracking
- **Image Support**: Active Storage integration for product images
- **Search & Pagination**: Kaminari-powered pagination

### 🛒 **Shopping Cart & Orders**
- **Shopping Cart**: Add/remove items, update quantities
- **Cart Persistence**: Cart items saved across sessions
- **Order Management**: Complete order placement and tracking
- **Order Status**: Track orders (pending, paid, shipped, delivered, cancelled)
- **Order History**: View past orders with detailed information

### 💳 **Payment Integration**
- **Stripe Integration**: Ready-to-configure payment processing
- **Webhook Support**: Handle payment events securely
- **Payment Tracking**: Store payment intent IDs for order tracking

### 🎨 **Modern UI/UX**
- **Bootstrap 5**: Responsive, mobile-first design
- **Font Awesome Icons**: Beautiful icons throughout the interface
- **Professional Design**: Clean, modern, and user-friendly interface
- **Mobile Responsive**: Optimized for all device sizes
- **Accessibility**: Proper ARIA attributes and keyboard navigation

### 📱 **Pages & Navigation**
- **Home Page**: Hero section, featured products, categories, features
- **Shop Page**: Product catalog with filtering and pagination
- **Product Details**: Individual product pages with add to cart
- **Shopping Cart**: Cart management with quantity updates
- **Orders**: Order history and detailed order views
- **About Page**: Company information and features
- **Contact Page**: Contact form and FAQ section

## 🚀 Quick Start

### Prerequisites

- Ruby 3.1.0 or higher
- PostgreSQL
- Node.js (for asset compilation)
- rbenv (recommended for Ruby version management)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd e_bazzari
   ```

2. **Install Ruby dependencies**
   ```bash
   eval "$(rbenv init -)"  # If using rbenv
   bundle install
   ```

3. **Set up the database**
   ```bash
   # Start PostgreSQL (if not running)
   brew services start postgresql
   
   # Create and migrate database
   rails db:create
   rails db:migrate
   ```

4. **Seed the database with sample data**
   ```bash
   rails db:seed
   ```

5. **Start the Rails server**
   ```bash
   rails server
   ```

6. **Visit the application**
   Open your browser and go to `http://localhost:3000`

## 📊 Sample Data

The seed file creates a complete e-commerce environment:

- **6 Users** (including admin account)
- **50 Products** across 8 categories (Electronics, Clothing, Home & Garden, Sports, Books, Beauty, Toys, Automotive)
- **Sample Orders** with various statuses
- **Cart Items** for testing shopping functionality

### 🔑 Test Accounts

- **Admin**: `admin@ebazzari.com` / `password123`
- **Users**: `user1@example.com` to `user5@example.com` / `password123`

## ⚙️ Configuration

### Stripe Payment Integration

To enable Stripe payments:

1. Get your Stripe API keys from [Stripe Dashboard](https://dashboard.stripe.com)
2. Add them to your Rails credentials:
   ```bash
   rails credentials:edit
   ```
3. Add the following configuration:
   ```yaml
   stripe:
     publishable_key: pk_test_...
     secret_key: sk_test_...
     webhook_secret: whsec_...
   ```

### Environment Variables

Create a `.env` file in the root directory:
```bash
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

## 🏗️ Project Structure

```
app/
├── controllers/          # Rails controllers
│   ├── home_controller.rb
│   ├── products_controller.rb
│   ├── cart_items_controller.rb
│   ├── carts_controller.rb
│   ├── orders_controller.rb
│   └── stripe_controller.rb
├── models/              # ActiveRecord models
│   ├── user.rb
│   ├── product.rb
│   ├── order.rb
│   ├── order_item.rb
│   └── cart_item.rb
├── views/               # ERB templates
│   ├── layouts/
│   ├── home/
│   ├── products/
│   ├── carts/
│   ├── orders/
│   ├── pages/
│   └── devise/          # Custom authentication views
└── assets/              # CSS and JavaScript

config/
├── routes.rb            # Application routes
├── database.yml         # Database configuration
└── initializers/        # App configuration

db/
├── migrate/             # Database migrations
└── seeds.rb             # Sample data
```

## 🗄️ Database Schema

### Key Models

- **User**: Customer accounts with Devise authentication
  - Fields: email, encrypted_password, first_name, last_name, phone, address
  - Associations: has_many orders, cart_items

- **Product**: Product catalog with categories and inventory
  - Fields: name, description, price, category, stock_quantity
  - Associations: has_many order_items, cart_items, has_one_attached image

- **Order**: Customer orders with status tracking
  - Fields: user_id, total_amount, status, stripe_payment_intent_id
  - Associations: belongs_to user, has_many order_items

- **OrderItem**: Individual items within orders
  - Fields: order_id, product_id, quantity, unit_price
  - Associations: belongs_to order, product

- **CartItem**: Shopping cart functionality
  - Fields: user_id, product_id, quantity
  - Associations: belongs_to user, product

## 🌐 API Endpoints

### Public Routes
- `GET /` - Home page
- `GET /shop` - Product catalog
- `GET /products/:id` - Product details
- `GET /about` - About page
- `GET /contact` - Contact page

### Authentication Routes
- `GET /users/sign_in` - Sign in page
- `GET /users/sign_up` - Sign up page
- `GET /users/password/new` - Forgot password
- `GET /users/edit` - Edit profile

### User Routes (Authenticated)
- `GET /cart` - Shopping cart
- `POST /cart_items` - Add to cart
- `PATCH /cart_items/:id` - Update cart item
- `DELETE /cart_items/:id` - Remove from cart
- `GET /orders` - User orders
- `GET /orders/:id` - Order details
- `POST /orders` - Create order

### Payment Routes
- `POST /stripe/webhook` - Stripe webhook handler

## 🛠️ Development

### Running Tests
```bash
rails test
```

### Database Console
```bash
rails console
```

### Generate New Migration
```bash
rails generate migration AddColumnToTable column:type
```

### Reset Database
```bash
rails db:drop db:create db:migrate db:seed
```

### View Routes
```bash
rails routes
```

## 🚀 Deployment

### Production Setup

1. **Database**: Set up PostgreSQL database
2. **Environment**: Configure environment variables
3. **Stripe**: Set up Stripe webhook endpoints
4. **Email**: Configure email delivery for order confirmations
5. **Storage**: Set up file storage for product images
6. **SSL**: Ensure HTTPS for secure payments

### Heroku Deployment

1. Create Heroku app
2. Add PostgreSQL addon
3. Set environment variables
4. Configure Stripe webhooks
5. Deploy with Git

```bash
heroku create your-app-name
heroku addons:create heroku-postgresql:hobby-dev
heroku config:set STRIPE_PUBLISHABLE_KEY=pk_live_...
heroku config:set STRIPE_SECRET_KEY=sk_live_...
git push heroku main
heroku run rails db:migrate
heroku run rails db:seed
```

## 🎨 UI/UX Features

### Authentication Pages
- **Modern Card Design**: Clean, centered layout with shadows
- **Icon Integration**: Font Awesome icons for visual appeal
- **Form Validation**: Real-time validation with helpful feedback
- **Responsive Design**: Optimized for all screen sizes
- **Professional Styling**: Consistent branding throughout

### Shopping Experience
- **Product Cards**: Beautiful product displays with images
- **Category Filtering**: Easy product discovery
- **Cart Management**: Intuitive add/remove/update functionality
- **Order Tracking**: Clear order status and history
- **Mobile Optimization**: Touch-friendly interface

## 🔧 Technical Stack

- **Backend**: Ruby on Rails 7.2
- **Database**: PostgreSQL
- **Frontend**: Bootstrap 5.3 + Font Awesome 6
- **Authentication**: Devise
- **Payments**: Stripe
- **Pagination**: Kaminari
- **Image Handling**: Active Storage
- **Form Validation**: Bootstrap validation + custom JavaScript

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Email**: support@ebazzari.com
- **Issues**: [GitHub Issues](https://github.com/your-username/e-bazzari/issues)
- **Documentation**: Check the `/docs` folder for detailed guides

## 🎯 Roadmap

- [ ] Advanced search functionality
- [ ] Product reviews and ratings
- [ ] Wishlist feature
- [ ] Email notifications
- [ ] Admin dashboard
- [ ] Inventory management
- [ ] Multi-language support
- [ ] Mobile app integration

---

**Built with ❤️ using Ruby on Rails and Bootstrap**