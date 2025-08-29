// Product Detail Page JavaScript
document.addEventListener('DOMContentLoaded', function() {
  // Initialize product image gallery
  initProductImageGallery();
  
  // Initialize product tabs
  initProductTabs();
});

// Product Image Gallery
function initProductImageGallery() {
  const thumbnails = document.querySelectorAll('.thumbnail-item');
  const mainImages = document.querySelectorAll('.main-image-item');
  
  thumbnails.forEach(function(thumbnail) {
    thumbnail.addEventListener('click', function() {
      const imageIndex = this.getAttribute('data-image');
      
      // Remove active class from all thumbnails
      thumbnails.forEach(function(thumb) {
        thumb.classList.remove('active');
      });
      
      // Add active class to clicked thumbnail
      this.classList.add('active');
      
      // Hide all main images
      mainImages.forEach(function(image) {
        image.classList.remove('active');
      });
      
      // Show corresponding main image
      const targetImage = document.querySelector('.main-image-item[data-image="' + imageIndex + '"]');
      if (targetImage) {
        targetImage.classList.add('active');
      }
    });
  });
}

// Product Tabs
function initProductTabs() {
  const tabButtons = document.querySelectorAll('[data-bs-toggle="tab"]');
  const tabPanes = document.querySelectorAll('.tab-pane');
  
  tabButtons.forEach(function(button) {
    button.addEventListener('click', function(e) {
      e.preventDefault();
      
      const targetId = this.getAttribute('data-bs-target');
      
      // Remove active class from all tab buttons
      tabButtons.forEach(function(btn) {
        btn.classList.remove('active');
      });
      
      // Add active class to clicked button
      this.classList.add('active');
      
      // Hide all tab panes
      tabPanes.forEach(function(pane) {
        pane.classList.remove('show', 'active');
      });
      
      // Show target tab pane
      const targetPane = document.querySelector(targetId);
      if (targetPane) {
        targetPane.classList.add('show', 'active');
      }
    });
  });
}

// Add to cart functionality
function addToCart(productId, quantity) {
  const form = document.querySelector('.add-to-cart-form');
  if (form) {
    // You can add AJAX functionality here
    console.log('Adding to cart:', productId, quantity);
  }
}

// Wishlist functionality
function toggleWishlist(productId) {
  const wishlistBtn = document.querySelector('.btn-wishlist');
  if (wishlistBtn) {
    const icon = wishlistBtn.querySelector('i');
    if (icon.classList.contains('far')) {
      icon.classList.remove('far');
      icon.classList.add('fas');
      wishlistBtn.style.color = '#e91e63';
    } else {
      icon.classList.remove('fas');
      icon.classList.add('far');
      wishlistBtn.style.color = '';
    }
  }
}

// Add event listeners for wishlist buttons
document.addEventListener('DOMContentLoaded', function() {
  const wishlistBtns = document.querySelectorAll('.btn-wishlist');
  wishlistBtns.forEach(function(btn) {
    btn.addEventListener('click', function(e) {
      e.preventDefault();
      // Get product ID from data attribute or form
      const productId = document.querySelector('input[name="product_id"]')?.value;
      if (productId) {
        toggleWishlist(productId);
      }
    });
  });
});
