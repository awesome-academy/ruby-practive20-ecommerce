# Create Brands
brands = Brand.create!([
  { name: "Apple", description: "Technology company" },
  { name: "Samsung", description: "Electronics company" },
  { name: "Nike", description: "Sportswear company" },
  { name: "Adidas", description: "Athletic apparel company" }
])

# Create Categories
electronics = Category.create!(name: "Electronics", position: 1)
smartphones = Category.create!(name: "Smartphones", parent: electronics, position: 1)
laptops = Category.create!(name: "Laptops", parent: electronics, position: 2)

fashion = Category.create!(name: "Fashion", position: 2)
shoes = Category.create!(name: "Shoes", parent: fashion, position: 1)
clothing = Category.create!(name: "Clothing", parent: fashion, position: 2)

# Create Products
products = []

# Electronics - iPhones
products << Product.create!(
  name: "iPhone 15 Pro",
  short_description: "Latest iPhone with A17 Pro chip",
  description: "The iPhone 15 Pro is powered by the A17 Pro chip and features a titanium design.",
  base_price: 999.00,
  sale_price: 899.00,
  stock_quantity: 50,
  brand: brands[0], # Apple
  is_featured: true
)

products << Product.create!(
  name: "iPhone 15 Pro Max",
  short_description: "Largest iPhone with A17 Pro chip and ProRAW camera",
  description: "iPhone 15 Pro Max with 6.7-inch display and advanced camera system.",
  base_price: 1199.00,
  sale_price: 1099.00,
  stock_quantity: 40,
  brand: brands[0], # Apple
  is_featured: true
)

products << Product.create!(
  name: "iPhone 15",
  short_description: "Standard iPhone with Dynamic Island",
  description: "iPhone 15 with USB-C and improved camera capabilities.",
  base_price: 799.00,
  stock_quantity: 60,
  brand: brands[0] # Apple
)

products << Product.create!(
  name: "iPhone 14 Pro",
  short_description: "Previous generation iPhone with A16 Bionic",
  description: "iPhone 14 Pro with Dynamic Island and 48MP camera.",
  base_price: 899.00,
  sale_price: 749.00,
  stock_quantity: 35,
  brand: brands[0] # Apple
)

# Samsung Phones
products << Product.create!(
  name: "Samsung Galaxy S24",
  short_description: "Samsung's flagship smartphone with AI features",
  description: "Galaxy S24 with advanced AI features and excellent camera.",
  base_price: 899.00,
  stock_quantity: 30,
  brand: brands[1], # Samsung
  is_featured: true
)

products << Product.create!(
  name: "Samsung Galaxy S24 Ultra",
  short_description: "Premium Samsung phone with S Pen and 200MP camera",
  description: "Galaxy S24 Ultra with integrated S Pen and professional camera system.",
  base_price: 1299.00,
  sale_price: 1199.00,
  stock_quantity: 25,
  brand: brands[1], # Samsung
  is_featured: true
)

products << Product.create!(
  name: "Samsung Galaxy S23",
  short_description: "Previous generation Samsung flagship",
  description: "Galaxy S23 with Snapdragon 8 Gen 2 processor.",
  base_price: 799.00,
  sale_price: 649.00,
  stock_quantity: 45,
  brand: brands[1] # Samsung
)

products << Product.create!(
  name: "Samsung Galaxy A54",
  short_description: "Mid-range Samsung phone with great value",
  description: "Galaxy A54 offering flagship features at an affordable price.",
  base_price: 449.00,
  stock_quantity: 80,
  brand: brands[1] # Samsung
)

# MacBooks and Laptops
products << Product.create!(
  name: "MacBook Pro 16\"",
  short_description: "Professional laptop with M3 Pro chip",
  description: "MacBook Pro 16-inch with M3 Pro chip for professional workflows.",
  base_price: 2499.00,
  sale_price: 2299.00,
  stock_quantity: 20,
  brand: brands[0] # Apple
)

products << Product.create!(
  name: "MacBook Pro 14\"",
  short_description: "Compact professional laptop with M3 chip",
  description: "MacBook Pro 14-inch with M3 chip, perfect for developers and creators.",
  base_price: 1999.00,
  sale_price: 1799.00,
  stock_quantity: 30,
  brand: brands[0] # Apple
)

products << Product.create!(
  name: "MacBook Air 15\"",
  short_description: "Largest MacBook Air with M2 chip",
  description: "MacBook Air 15-inch with M2 chip, ultra-thin and lightweight.",
  base_price: 1299.00,
  stock_quantity: 40,
  brand: brands[0] # Apple
)

products << Product.create!(
  name: "MacBook Air 13\"",
  short_description: "Popular MacBook Air with M2 chip",
  description: "MacBook Air 13-inch with M2 chip, perfect for everyday use.",
  base_price: 1099.00,
  sale_price: 999.00,
  stock_quantity: 50,
  brand: brands[0] # Apple
)

# Nike Shoes
products << Product.create!(
  name: "Nike Air Jordan 1 Retro High",
  short_description: "Classic basketball shoes in original colorway",
  description: "Iconic Air Jordan 1 sneakers with premium leather construction.",
  base_price: 170.00,
  stock_quantity: 100,
  brand: brands[2], # Nike
  is_featured: true
)

products << Product.create!(
  name: "Nike Air Force 1",
  short_description: "Timeless basketball shoes with Air cushioning",
  description: "Classic Air Force 1 with durable leather upper and Air-Sole unit.",
  base_price: 110.00,
  stock_quantity: 150,
  brand: brands[2] # Nike
)

products << Product.create!(
  name: "Nike Dunk Low",
  short_description: "Retro basketball shoes with college colors",
  description: "Nike Dunk Low with vintage basketball style and modern comfort.",
  base_price: 100.00,
  sale_price: 85.00,
  stock_quantity: 120,
  brand: brands[2] # Nike
)

products << Product.create!(
  name: "Nike Air Max 90",
  short_description: "Running shoes with visible Air cushioning",
  description: "Air Max 90 with iconic design and Max Air cushioning technology.",
  base_price: 130.00,
  stock_quantity: 90,
  brand: brands[2] # Nike
)

# Adidas Shoes
products << Product.create!(
  name: "Adidas Ultraboost 22",
  short_description: "Running shoes with responsive boost technology",
  description: "Ultraboost 22 with responsive boost midsole for energy return.",
  base_price: 180.00,
  sale_price: 144.00,
  stock_quantity: 75,
  brand: brands[3] # Adidas
)

products << Product.create!(
  name: "Adidas Stan Smith",
  short_description: "Classic white tennis shoes with green accents",
  description: "Timeless Stan Smith sneakers with clean white leather design.",
  base_price: 80.00,
  stock_quantity: 200,
  brand: brands[3] # Adidas
)

products << Product.create!(
  name: "Adidas Superstar",
  short_description: "Iconic shell-toe sneakers from the 70s",
  description: "Original Superstar with distinctive shell toe and three stripes.",
  base_price: 90.00,
  sale_price: 72.00,
  stock_quantity: 160,
  brand: brands[3] # Adidas
)

products << Product.create!(
  name: "Adidas NMD R1",
  short_description: "Modern street shoes with boost cushioning",
  description: "NMD R1 combining street style with boost technology.",
  base_price: 140.00,
  stock_quantity: 85,
  brand: brands[3] # Adidas
)

# Additional Products to reach over 20 for pagination
products << Product.create!(
  name: "iPad Pro 12.9\"",
  short_description: "Professional tablet with M2 chip and Liquid Retina display",
  description: "iPad Pro with M2 chip, perfect for creative professionals and productivity.",
  base_price: 1099.00,
  sale_price: 999.00,
  stock_quantity: 35,
  brand: brands[0] # Apple
)

products << Product.create!(
  name: "iPad Air",
  short_description: "Versatile tablet with M1 chip",
  description: "iPad Air with M1 chip offering laptop-level performance.",
  base_price: 599.00,
  stock_quantity: 60,
  brand: brands[0] # Apple
)

products << Product.create!(
  name: "AirPods Pro 2",
  short_description: "Active noise cancelling wireless earbuds",
  description: "AirPods Pro with advanced noise cancellation and spatial audio.",
  base_price: 249.00,
  sale_price: 199.00,
  stock_quantity: 100,
  brand: brands[0] # Apple
)

products << Product.create!(
  name: "Samsung Galaxy Watch 6",
  short_description: "Advanced smartwatch with health monitoring",
  description: "Galaxy Watch 6 with comprehensive health tracking and long battery life.",
  base_price: 329.00,
  stock_quantity: 70,
  brand: brands[1] # Samsung
)

products << Product.create!(
  name: "Samsung Galaxy Buds2 Pro",
  short_description: "Premium wireless earbuds with ANC",
  description: "Galaxy Buds2 Pro with intelligent active noise cancellation.",
  base_price: 229.00,
  sale_price: 179.00,
  stock_quantity: 90,
  brand: brands[1] # Samsung
)

products << Product.create!(
  name: "Nike React Infinity Run",
  short_description: "Running shoes designed to reduce injury risk",
  description: "React Infinity Run with Nike React foam for smooth, responsive ride.",
  base_price: 160.00,
  stock_quantity: 80,
  brand: brands[2] # Nike
)

products << Product.create!(
  name: "Adidas Yeezy Boost 350",
  short_description: "Kanye West collaboration with boost technology",
  description: "Yeezy Boost 350 with distinctive design and comfortable boost sole.",
  base_price: 220.00,
  stock_quantity: 25,
  brand: brands[3] # Adidas
)

# Assign categories to products
ProductCategory.create!(product: products[0], category: smartphones) # iPhone
ProductCategory.create!(product: products[1], category: smartphones) # Samsung
ProductCategory.create!(product: products[2], category: laptops) # MacBook
ProductCategory.create!(product: products[3], category: shoes) # Jordan
ProductCategory.create!(product: products[4], category: shoes) # Ultraboost

puts "Created #{Brand.count} brands"
puts "Created #{Category.count} categories"
puts "Created #{Product.count} products"
puts "Created #{ProductCategory.count} product-category associations"

# Create sample microposts
Micropost.create!(content: "First micropost! Hello world!")
Micropost.create!(content: "Learning Ruby on Rails is awesome!")
Micropost.create!(content: "This is my third micropost. Building a sample app.")
Micropost.create!(content: "Rails makes web development fun and easy!")
Micropost.create!(content: "Just finished implementing the microposts feature!")
