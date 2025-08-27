# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data
puts "Clearing existing data..."
ProductCategory.destroy_all
Product.destroy_all
Category.destroy_all
Brand.destroy_all
User.destroy_all

# Create Brands
puts "Creating brands..."
brands = Brand.create!([
  { name: "Apple", description: "Innovative technology company", is_active: true },
  { name: "Samsung", description: "Global electronics leader", is_active: true },
  { name: "Nike", description: "Just Do It - Athletic footwear & apparel", is_active: true },
  { name: "Adidas", description: "Impossible is Nothing - Sports brand", is_active: true },
  { name: "Dell", description: "Computer hardware manufacturer", is_active: true },
  { name: "Sony", description: "Electronics and entertainment", is_active: true },
  { name: "HP", description: "Hewlett-Packard technology solutions", is_active: true },
  { name: "Lenovo", description: "Personal computer manufacturer", is_active: true },
  { name: "Puma", description: "Forever Faster - Sports lifestyle brand", is_active: true },
  { name: "New Balance", description: "Athletic footwear company", is_active: true }
])

# Create hierarchical categories
puts "Creating categories..."

# Main categories
electronics = Category.create!(name: "Electronics", position: 1, is_active: true, description: "Electronic devices and gadgets")
fashion = Category.create!(name: "Fashion", position: 2, is_active: true, description: "Clothing, footwear and accessories")
sports = Category.create!(name: "Sports & Outdoors", position: 3, is_active: true, description: "Sports equipment and outdoor gear")
Category.create!(name: "Books & Media", position: 4, is_active: true, description: "Books, movies and entertainment")
Category.create!(name: "Home & Garden", position: 5, is_active: true, description: "Home improvement and garden supplies")

# Electronics subcategories
smartphones = Category.create!(name: "Smartphones", parent: electronics, position: 1, is_active: true, description: "Mobile phones and accessories")
laptops = Category.create!(name: "Laptops", parent: electronics, position: 2, is_active: true, description: "Portable computers")
tablets = Category.create!(name: "Tablets", parent: electronics, position: 3, is_active: true, description: "Tablet computers and e-readers")
audio = Category.create!(name: "Audio & Headphones", parent: electronics, position: 4, is_active: true, description: "Headphones, speakers and audio equipment")
gaming = Category.create!(name: "Gaming", parent: electronics, position: 5, is_active: true, description: "Gaming consoles and accessories")
Category.create!(name: "TV & Video", parent: electronics, position: 6, is_active: true, description: "Televisions and video equipment")

# Fashion subcategories
mens_fashion = Category.create!(name: "Men's Fashion", parent: fashion, position: 1, is_active: true, description: "Men's clothing and accessories")
womens_fashion = Category.create!(name: "Women's Fashion", parent: fashion, position: 2, is_active: true, description: "Women's clothing and accessories")
shoes = Category.create!(name: "Shoes", parent: fashion, position: 3, is_active: true, description: "Footwear for all occasions")
accessories = Category.create!(name: "Accessories", parent: fashion, position: 4, is_active: true, description: "Bags, watches and jewelry")

# Sports subcategories
fitness = Category.create!(name: "Fitness", parent: sports, position: 1, is_active: true, description: "Fitness equipment and gear")
Category.create!(name: "Outdoor Recreation", parent: sports, position: 2, is_active: true, description: "Camping, hiking and outdoor activities")
Category.create!(name: "Team Sports", parent: sports, position: 3, is_active: true, description: "Basketball, football and team sport equipment")

# Create admin user
puts "Creating admin user..."
  admin_user = User.create!(
    name: "Admin User",
    email: "admin@example.com",
    password: "password123",
    password_confirmation: "password123",
    birthday: Date.new(1990, 1, 1),
    gender: "male",
    activated: true,
    role: :admin,
    phone_number: "0123456789"
  )

# Create sample users
puts "Creating sample users..."
10.times do |i|
  user = User.create!(
    name: "User #{i + 1}",
    email: "user#{i + 1}@example.com",
    password: "password123",
    password_confirmation: "password123",
    birthday: Date.new(1990 + rand(20), rand(12) + 1, rand(28) + 1),
    gender: ["male", "female", "other"].sample,
    activated: [true, false].sample,
    role: :user,
    phone_number: "012345678#{i}",
    default_address: "#{rand(100) + 1} Street #{i + 1}, District #{rand(10) + 1}, Ho Chi Minh City"
  )

  # Create some orders for active users
  if user.activated? && rand(3) > 0
    rand(1..5).times do |j|
      Order.create!(
        user: user,
        order_number: "ORD-#{user.id}-#{j + 1}-#{Time.current.to_i}",
        total_amount: rand(100_000..2_000_000),
        status: Order.statuses.keys.sample,
        shipping_address: user.default_address,
        recipient_name: user.name,
        recipient_phone: user.phone_number,
        created_at: rand(30.days).seconds.ago
      )
    end
  end
end

puts "Created #{User.count} users and #{Order.count} orders"

# Create sample products with categories
puts "Creating products..."

# Smartphones
products = []

products << Product.create!(
  name: "iPhone 15 Pro Max",
  short_description: "Latest iPhone with A17 Pro chip and titanium design",
  description: "The iPhone 15 Pro Max features the powerful A17 Pro chip, a stunning titanium design, and the most advanced camera system ever in an iPhone. With its 6.7-inch Super Retina XDR display and Action Button, it delivers unparalleled performance and innovation.",
  base_price: 1199.00,
  sale_price: 1099.00,
  stock_quantity: 45,
  brand: brands.find { |b| b.name == "Apple" },
  is_active: true,
  is_featured: true,
  sku: "IPH15PM001"
)

products << Product.create!(
  name: "iPhone 15 Pro",
  short_description: "Pro iPhone with A17 Pro chip and advanced cameras",
  description: "iPhone 15 Pro with 6.1-inch display, A17 Pro chip, and professional-grade camera system. Features titanium construction and USB-C connectivity.",
  base_price: 999.00,
  sale_price: 949.00,
  stock_quantity: 60,
  brand: brands.find { |b| b.name == "Apple" },
  is_active: true,
  is_featured: true,
  sku: "IPH15P001"
)

products << Product.create!(
  name: "iPhone 15",
  short_description: "Standard iPhone with Dynamic Island and improved cameras",
  description: "iPhone 15 brings the Dynamic Island to the standard iPhone, along with a 48MP main camera and USB-C. Available in multiple vibrant colors.",
  base_price: 799.00,
  stock_quantity: 80,
  brand: brands.find { |b| b.name == "Apple" },
  is_active: true,
  sku: "IPH15001"
)

products << Product.create!(
  name: "Samsung Galaxy S24 Ultra",
  short_description: "Samsung's flagship with AI features and S Pen",
  description: "Galaxy S24 Ultra with built-in S Pen, advanced AI features, and exceptional camera capabilities. Features a 6.8-inch display and powerful performance.",
  base_price: 1299.00,
  sale_price: 1199.00,
  stock_quantity: 35,
  brand: brands.find { |b| b.name == "Samsung" },
  is_active: true,
  is_featured: true,
  sku: "SAM24U001"
)

products << Product.create!(
  name: "Samsung Galaxy S24+",
  short_description: "Premium Galaxy with enhanced display and cameras",
  description: "Galaxy S24+ offers a larger 6.7-inch display, improved cameras, and all-day battery life. Perfect balance of features and performance.",
  base_price: 999.00,
  stock_quantity: 50,
  brand: brands.find { |b| b.name == "Samsung" },
  is_active: true,
  is_featured: true,
  sku: "SAM24P001"
)

products << Product.create!(
  name: "Samsung Galaxy S24",
  short_description: "Compact flagship with AI-powered features",
  description: "Galaxy S24 in a compact 6.2-inch form factor, featuring AI photography, enhanced performance, and premium design.",
  base_price: 799.00,
  sale_price: 749.00,
  stock_quantity: 70,
  brand: brands.find { |b| b.name == "Samsung" },
  is_active: true,
  sku: "SAM24001"
)

# Laptops
products << Product.create!(
  name: "MacBook Pro 16-inch M3 Pro",
  short_description: "Professional laptop with M3 Pro chip",
  description: "MacBook Pro 16-inch with M3 Pro chip delivers exceptional performance for professionals. Features Liquid Retina XDR display and up to 18 hours of battery life.",
  base_price: 2499.00,
  sale_price: 2299.00,
  stock_quantity: 25,
  brand: brands.find { |b| b.name == "Apple" },
  is_active: true,
  is_featured: true,
  sku: "MBP16M3001"
)

products << Product.create!(
  name: "MacBook Pro 14-inch M3",
  short_description: "Compact professional laptop with M3 chip",
  description: "MacBook Pro 14-inch with M3 chip offers pro-level performance in a portable design. Perfect for developers, creators, and professionals.",
  base_price: 1999.00,
  sale_price: 1799.00,
  stock_quantity: 35,
  brand: brands.find { |b| b.name == "Apple" },
  is_active: true,
  sku: "MBP14M3001"
)

products << Product.create!(
  name: "MacBook Air 15-inch M3",
  short_description: "Largest MacBook Air with M3 chip",
  description: "MacBook Air 15-inch with M3 chip provides ample screen space in an incredibly thin and light design. Perfect for productivity and entertainment.",
  base_price: 1299.00,
  stock_quantity: 40,
  brand: brands.find { |b| b.name == "Apple" },
  is_active: true,
  sku: "MBA15M3001"
)

products << Product.create!(
  name: "MacBook Air 13-inch M3",
  short_description: "Ultra-portable laptop with M3 chip",
  description: "MacBook Air 13-inch with M3 chip delivers incredible performance and all-day battery life in the world's most popular laptop size.",
  base_price: 1099.00,
  sale_price: 999.00,
  stock_quantity: 55,
  brand: brands.find { |b| b.name == "Apple" },
  is_active: true,
  sku: "MBA13M3001"
)

products << Product.create!(
  name: "Dell XPS 13 Plus",
  short_description: "Premium ultrabook with InfinityEdge display",
  description: "Dell XPS 13 Plus features a stunning InfinityEdge display, premium build quality, and powerful Intel processors. Perfect for business and creative work.",
  base_price: 1299.00,
  sale_price: 1199.00,
  stock_quantity: 30,
  brand: brands.find { |b| b.name == "Dell" },
  is_active: true,
  sku: "DXP13P001"
)

products << Product.create!(
  name: "HP Spectre x360 14",
  short_description: "Convertible laptop with 2-in-1 design",
  description: "HP Spectre x360 14 combines laptop and tablet functionality with a 360-degree hinge, OLED display options, and premium materials.",
  base_price: 1199.00,
  stock_quantity: 25,
  brand: brands.find { |b| b.name == "HP" },
  is_active: true,
  sku: "HPS360014"
)

# Tablets
products << Product.create!(
  name: "iPad Pro 12.9-inch M4",
  short_description: "Ultimate iPad with M4 chip and Liquid Retina XDR",
  description: "iPad Pro 12.9-inch with M4 chip offers unprecedented performance and the stunning Liquid Retina XDR display. Compatible with Apple Pencil Pro and Magic Keyboard.",
  base_price: 1299.00,
  sale_price: 1199.00,
  stock_quantity: 30,
  brand: brands.find { |b| b.name == "Apple" },
  is_active: true,
  is_featured: true,
  sku: "IPP129M4001"
)

products << Product.create!(
  name: "iPad Air 11-inch M4",
  short_description: "Versatile iPad with M4 chip performance",
  description: "iPad Air 11-inch with M4 chip provides desktop-class performance in a thin and light design. Perfect for creativity and productivity.",
  base_price: 799.00,
  stock_quantity: 45,
  brand: brands.find { |b| b.name == "Apple" },
  is_active: true,
  sku: "IPA11M4001"
)

products << Product.create!(
  name: "iPad 10th Generation",
  short_description: "Most popular iPad with modern design",
  description: "iPad 10th generation features a modern all-screen design, A14 Bionic chip, and compatibility with Apple Pencil (1st generation).",
  base_price: 449.00,
  sale_price: 399.00,
  stock_quantity: 60,
  brand: brands.find { |b| b.name == "Apple" },
  is_active: true,
  sku: "IPD10G001"
)

# Audio & Headphones
products << Product.create!(
  name: "AirPods Pro 2nd Generation",
  short_description: "Pro wireless earbuds with advanced noise cancellation",
  description: "AirPods Pro 2nd generation feature advanced active noise cancellation, adaptive transparency, and spatial audio for an immersive listening experience.",
  base_price: 249.00,
  sale_price: 199.00,
  stock_quantity: 100,
  brand: brands.find { |b| b.name == "Apple" },
  is_active: true,
  is_featured: true,
  sku: "APP2G001"
)

products << Product.create!(
  name: "AirPods 3rd Generation",
  short_description: "Wireless earbuds with spatial audio",
  description: "AirPods 3rd generation deliver rich, detailed sound with spatial audio, longer battery life, and a comfortable, secure fit.",
  base_price: 179.00,
  sale_price: 149.00,
  stock_quantity: 80,
  brand: brands.find { |b| b.name == "Apple" },
  is_active: true,
  sku: "AP3G001"
)

products << Product.create!(
  name: "Sony WH-1000XM5",
  short_description: "Industry-leading noise canceling headphones",
  description: "Sony WH-1000XM5 headphones offer industry-leading noise cancellation, exceptional sound quality, and up to 30 hours of battery life.",
  base_price: 399.00,
  sale_price: 329.00,
  stock_quantity: 40,
  brand: brands.find { |b| b.name == "Sony" },
  is_active: true,
  is_featured: true,
  sku: "SWH1000XM5"
)

# Gaming
products << Product.create!(
  name: "Sony PlayStation 5",
  short_description: "Next-generation gaming console with 4K gaming",
  description: "PlayStation 5 delivers breathtaking immersion with support for 4K gaming, 3D audio, and lightning-fast SSD storage. Includes DualSense wireless controller.",
  base_price: 499.00,
  stock_quantity: 20,
  brand: brands.find { |b| b.name == "Sony" },
  is_active: true,
  is_featured: true,
  sku: "PS5001"
)

# Nike Shoes
products << Product.create!(
  name: "Nike Air Jordan 1 Retro High OG",
  short_description: "Iconic basketball shoes in classic colorway",
  description: "Air Jordan 1 Retro High OG brings back the classic design that started it all. Premium leather construction with the iconic Wings logo.",
  base_price: 170.00,
  stock_quantity: 120,
  brand: brands.find { |b| b.name == "Nike" },
  is_active: true,
  is_featured: true,
  sku: "NAJ1RH001"
)

products << Product.create!(
  name: "Nike Air Force 1 '07",
  short_description: "Classic basketball shoes with Air cushioning",
  description: "Nike Air Force 1 '07 features the timeless design that revolutionized basketball footwear. Durable leather upper with Air-Sole unit in the heel.",
  base_price: 110.00,
  sale_price: 95.00,
  stock_quantity: 150,
  brand: brands.find { |b| b.name == "Nike" },
  is_active: true,
  sku: "NAF107001"
)

products << Product.create!(
  name: "Nike Dunk Low Retro",
  short_description: "Retro basketball shoes with college-inspired colors",
  description: "Nike Dunk Low Retro brings back the '80s basketball style with a variety of colorways inspired by college teams. Premium materials and classic design.",
  base_price: 100.00,
  sale_price: 85.00,
  stock_quantity: 100,
  brand: brands.find { |b| b.name == "Nike" },
  is_active: true,
  sku: "NDL001"
)

products << Product.create!(
  name: "Nike Air Max 90",
  short_description: "Running shoes with visible Air cushioning",
  description: "Nike Air Max 90 features the iconic waffle outsole, visible Max Air cushioning, and classic design that's been a favorite for decades.",
  base_price: 130.00,
  stock_quantity: 90,
  brand: brands.find { |b| b.name == "Nike" },
  is_active: true,
  sku: "NAM90001"
)

products << Product.create!(
  name: "Nike React Infinity Run Flyknit 4",
  short_description: "Running shoes designed to help reduce injury",
  description: "Nike React Infinity Run Flyknit 4 provides soft, responsive cushioning and a secure fit designed to help reduce running-related injuries.",
  base_price: 160.00,
  sale_price: 140.00,
  stock_quantity: 70,
  brand: brands.find { |b| b.name == "Nike" },
  is_active: true,
  sku: "NRIF4001"
)

# Adidas Shoes
products << Product.create!(
  name: "Adidas Ultraboost 23",
  short_description: "Running shoes with responsive BOOST technology",
  description: "Adidas Ultraboost 23 features responsive BOOST midsole, Primeknit upper, and Continental rubber outsole for energy return with every step.",
  base_price: 190.00,
  sale_price: 160.00,
  stock_quantity: 80,
  brand: brands.find { |b| b.name == "Adidas" },
  is_active: true,
  is_featured: true,
  sku: "AUB23001"
)

products << Product.create!(
  name: "Adidas Stan Smith",
  short_description: "Classic tennis shoes with clean white design",
  description: "Adidas Stan Smith remains one of the most iconic tennis shoes ever made. Clean white leather design with green accents and perforated 3-Stripes.",
  base_price: 80.00,
  stock_quantity: 200,
  brand: brands.find { |b| b.name == "Adidas" },
  is_active: true,
  sku: "ASS001"
)

products << Product.create!(
  name: "Adidas Superstar",
  short_description: "Iconic shell-toe sneakers from the '70s",
  description: "Adidas Superstar features the famous shell toe, premium leather upper, and classic 3-Stripes design. A true icon that transcends generations.",
  base_price: 90.00,
  sale_price: 75.00,
  stock_quantity: 160,
  brand: brands.find { |b| b.name == "Adidas" },
  is_active: true,
  sku: "AS001"
)

products << Product.create!(
  name: "Adidas NMD_R1",
  short_description: "Modern street shoes with BOOST cushioning",
  description: "Adidas NMD_R1 combines archive-inspired design with modern technology. Features BOOST cushioning and distinctive design elements.",
  base_price: 140.00,
  sale_price: 120.00,
  stock_quantity: 85,
  brand: brands.find { |b| b.name == "Adidas" },
  is_active: true,
  sku: "ANMDR1001"
)

# Puma Shoes
products << Product.create!(
  name: "Puma Suede Classic",
  short_description: "Iconic suede sneakers with vintage appeal",
  description: "Puma Suede Classic features soft suede upper, classic formstrip, and vintage basketball styling. A timeless design that never goes out of style.",
  base_price: 70.00,
  stock_quantity: 120,
  brand: brands.find { |b| b.name == "Puma" },
  is_active: true,
  sku: "PSC001"
)

products << Product.create!(
  name: "Puma RS-X3",
  short_description: "Retro-futuristic running shoes with bold design",
  description: "Puma RS-X3 features a bold, chunky silhouette with mesh and synthetic upper, RS cushioning, and eye-catching colorways.",
  base_price: 110.00,
  sale_price: 95.00,
  stock_quantity: 75,
  brand: brands.find { |b| b.name == "Puma" },
  is_active: true,
  sku: "PRSX3001"
)

# New Balance Shoes
products << Product.create!(
  name: "New Balance 990v5",
  short_description: "Premium running shoes made in USA",
  description: "New Balance 990v5 features premium materials, superior craftsmanship, and the comfort and performance that made the 990 series legendary.",
  base_price: 185.00,
  stock_quantity: 60,
  brand: brands.find { |b| b.name == "New Balance" },
  is_active: true,
  is_featured: true,
  sku: "NB990V5001"
)

products << Product.create!(
  name: "New Balance 574",
  short_description: "Classic lifestyle sneakers with retro appeal",
  description: "New Balance 574 offers a perfect blend of function and style with ENCAP midsole technology and suede/mesh upper construction.",
  base_price: 80.00,
  sale_price: 70.00,
  stock_quantity: 140,
  brand: brands.find { |b| b.name == "New Balance" },
  is_active: true,
  sku: "NB574001"
)

# Additional products to reach 40+ total
products << Product.create!(
  name: "Lenovo ThinkPad X1 Carbon",
  short_description: "Business ultrabook with enterprise security",
  description: "Lenovo ThinkPad X1 Carbon delivers enterprise-level security, durability, and performance in a lightweight carbon fiber chassis.",
  base_price: 1899.00,
  sale_price: 1699.00,
  stock_quantity: 20,
  brand: brands.find { |b| b.name == "Lenovo" },
  is_active: true,
  sku: "LTX1C001"
)

products << Product.create!(
  name: "Samsung Galaxy Watch 6",
  short_description: "Advanced smartwatch with health monitoring",
  description: "Galaxy Watch 6 offers comprehensive health and fitness tracking, sleep monitoring, and seamless connectivity with your Galaxy devices.",
  base_price: 329.00,
  sale_price: 279.00,
  stock_quantity: 90,
  brand: brands.find { |b| b.name == "Samsung" },
  is_active: true,
  sku: "SGW6001"
)

products << Product.create!(
  name: "Samsung Galaxy Buds2 Pro",
  short_description: "Premium wireless earbuds with intelligent ANC",
  description: "Galaxy Buds2 Pro feature intelligent active noise cancellation, 360 Audio, and crystal-clear voice quality for calls and music.",
  base_price: 229.00,
  sale_price: 179.00,
  stock_quantity: 110,
  brand: brands.find { |b| b.name == "Samsung" },
  is_active: true,
  sku: "SGB2P001"
)

# Now assign categories to products
puts "Assigning categories to products..."

category_assignments = [
  # Smartphones
  { product_name: "iPhone 15 Pro Max", categories: [smartphones, electronics] },
  { product_name: "iPhone 15 Pro", categories: [smartphones, electronics] },
  { product_name: "iPhone 15", categories: [smartphones, electronics] },
  { product_name: "Samsung Galaxy S24 Ultra", categories: [smartphones, electronics] },
  { product_name: "Samsung Galaxy S24+", categories: [smartphones, electronics] },
  { product_name: "Samsung Galaxy S24", categories: [smartphones, electronics] },

  # Laptops
  { product_name: "MacBook Pro 16-inch M3 Pro", categories: [laptops, electronics] },
  { product_name: "MacBook Pro 14-inch M3", categories: [laptops, electronics] },
  { product_name: "MacBook Air 15-inch M3", categories: [laptops, electronics] },
  { product_name: "MacBook Air 13-inch M3", categories: [laptops, electronics] },
  { product_name: "Dell XPS 13 Plus", categories: [laptops, electronics] },
  { product_name: "HP Spectre x360 14", categories: [laptops, electronics] },
  { product_name: "Lenovo ThinkPad X1 Carbon", categories: [laptops, electronics] },

  # Tablets
  { product_name: "iPad Pro 12.9-inch M4", categories: [tablets, electronics] },
  { product_name: "iPad Air 11-inch M4", categories: [tablets, electronics] },
  { product_name: "iPad 10th Generation", categories: [tablets, electronics] },

  # Audio
  { product_name: "AirPods Pro 2nd Generation", categories: [audio, electronics] },
  { product_name: "AirPods 3rd Generation", categories: [audio, electronics] },
  { product_name: "Sony WH-1000XM5", categories: [audio, electronics] },
  { product_name: "Samsung Galaxy Buds2 Pro", categories: [audio, electronics] },

  # Gaming
  { product_name: "Sony PlayStation 5", categories: [gaming, electronics] },

  # Shoes - Nike
  { product_name: "Nike Air Jordan 1 Retro High OG", categories: [shoes, fashion, mens_fashion] },
  { product_name: "Nike Air Force 1 '07", categories: [shoes, fashion, mens_fashion, womens_fashion] },
  { product_name: "Nike Dunk Low Retro", categories: [shoes, fashion, mens_fashion, womens_fashion] },
  { product_name: "Nike Air Max 90", categories: [shoes, fashion, fitness, sports] },
  { product_name: "Nike React Infinity Run Flyknit 4", categories: [shoes, fashion, fitness, sports] },

  # Shoes - Adidas
  { product_name: "Adidas Ultraboost 23", categories: [shoes, fashion, fitness, sports] },
  { product_name: "Adidas Stan Smith", categories: [shoes, fashion, mens_fashion, womens_fashion] },
  { product_name: "Adidas Superstar", categories: [shoes, fashion, mens_fashion, womens_fashion] },
  { product_name: "Adidas NMD_R1", categories: [shoes, fashion, mens_fashion, womens_fashion] },

  # Shoes - Others
  { product_name: "Puma Suede Classic", categories: [shoes, fashion, mens_fashion, womens_fashion] },
  { product_name: "Puma RS-X3", categories: [shoes, fashion, fitness, sports] },
  { product_name: "New Balance 990v5", categories: [shoes, fashion, fitness, sports] },
  { product_name: "New Balance 574", categories: [shoes, fashion, mens_fashion, womens_fashion] },

  # Accessories
  { product_name: "Samsung Galaxy Watch 6", categories: [accessories, fashion, electronics] }
]

category_assignments.each do |assignment|
  product = products.find { |p| p.name == assignment[:product_name] }
  if product
    assignment[:categories].each do |category|
      ProductCategory.create!(product: product, category: category)
      puts "  Assigned #{product.name} to #{category.name}"
    end
  else
    puts "  Warning: Product '#{assignment[:product_name]}' not found"
  end
end

# Add sample images to products
puts "Adding sample images to products..."

# Simple image assignments - one image per product
image_assignments = {
  "iPhone 15 Pro Max" => "https://picsum.photos/800/800?random=1",
  "iPhone 15 Pro" => "https://picsum.photos/800/800?random=2",
  "iPhone 15" => "https://picsum.photos/800/800?random=3",
  "Samsung Galaxy S24 Ultra" => "https://picsum.photos/800/800?random=4",
  "Samsung Galaxy S24+" => "https://picsum.photos/800/800?random=5",
  "Samsung Galaxy S24" => "https://picsum.photos/800/800?random=6",
  "MacBook Pro 16-inch M3 Pro" => "https://picsum.photos/800/800?random=7",
  "MacBook Pro 14-inch M3" => "https://picsum.photos/800/800?random=8",
  "MacBook Air 15-inch M3" => "https://picsum.photos/800/800?random=9",
  "MacBook Air 13-inch M3" => "https://picsum.photos/800/800?random=10",
  "Dell XPS 13 Plus" => "https://picsum.photos/800/800?random=11",
  "HP Spectre x360 14" => "https://picsum.photos/800/800?random=12",
  "iPad Pro 12.9-inch M4" => "https://picsum.photos/800/800?random=13",
  "iPad Air 11-inch M4" => "https://picsum.photos/800/800?random=14",
  "iPad 10th Generation" => "https://picsum.photos/800/800?random=15",
  "AirPods Pro 2nd Generation" => "https://picsum.photos/800/800?random=16",
  "AirPods 3rd Generation" => "https://picsum.photos/800/800?random=17",
  "Sony WH-1000XM5" => "https://picsum.photos/800/800?random=18",
  "Sony PlayStation 5" => "https://picsum.photos/800/800?random=19",
  "Nike Air Jordan 1 Retro High OG" => "https://picsum.photos/800/800?random=20",
  "Nike Air Force 1 '07" => "https://picsum.photos/800/800?random=21",
  "Nike Dunk Low Retro" => "https://picsum.photos/800/800?random=22",
  "Nike Air Max 90" => "https://picsum.photos/800/800?random=23",
  "Nike React Infinity Run Flyknit 4" => "https://picsum.photos/800/800?random=24",
  "Adidas Ultraboost 23" => "https://picsum.photos/800/800?random=25",
  "Adidas Stan Smith" => "https://picsum.photos/800/800?random=26",
  "Adidas Superstar" => "https://picsum.photos/800/800?random=27",
  "Adidas NMD_R1" => "https://picsum.photos/800/800?random=28",
  "Puma Suede Classic" => "https://picsum.photos/800/800?random=29",
  "Puma RS-X3" => "https://picsum.photos/800/800?random=30",
  "New Balance 990v5" => "https://picsum.photos/800/800?random=31",
  "New Balance 574" => "https://picsum.photos/800/800?random=32",
  "Lenovo ThinkPad X1 Carbon" => "https://picsum.photos/800/800?random=33",
  "Samsung Galaxy Watch 6" => "https://picsum.photos/800/800?random=34",
  "Samsung Galaxy Buds2 Pro" => "https://picsum.photos/800/800?random=35"
}

image_assignments.each do |product_name, image_url|
  product = Product.find_by(name: product_name)
  if product
    product.update!(image_url: image_url)
    puts "  ✓ Added image to #{product_name}"
  else
    puts "  ✗ Product '#{product_name}' not found"
  end
end

# Print summary
puts "\n" + "="*50
puts "SEEDING COMPLETED SUCCESSFULLY!"
puts "="*50
puts "Created #{Brand.count} brands"
puts "Created #{Category.count} categories"
puts "  - #{Category.where(parent_id: nil).count} main categories"
puts "  - #{Category.where.not(parent_id: nil).count} subcategories"
puts "Created #{Product.count} products"
puts "  - #{Product.where(is_featured: true).count} featured products"
puts "  - #{Product.where(is_active: true).count} active products"
puts "  - #{Product.where.not(image_url: nil).count} products with images"
puts "Created #{ProductCategory.count} product-category associations"
puts "Created #{User.count} users (#{User.where(role: :admin).count} admin)"

# Show category breakdown
puts "\nCategory breakdown:"
Category.where(parent_id: nil).each do |main_cat|
  product_count = main_cat.total_products_count
  puts "  #{main_cat.name}: #{product_count} products"

  main_cat.children.each do |sub_cat|
    sub_product_count = sub_cat.total_products_count
    puts "    └── #{sub_cat.name}: #{sub_product_count} products"
  end
end

puts "\nSample login credentials:"
puts "Admin: admin@example.com / password123"
puts "\n" + "="*50
