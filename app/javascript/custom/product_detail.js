// Product Detail Page JavaScript
document.addEventListener('DOMContentLoaded', initProductDetail);
document.addEventListener('turbo:load', initProductDetail);

function initProductDetail() {
  // Initialize product detail functionality
  initProductOptions();
  initQuantityControls();
  initProductTabs();
}

// Product Options (Color and Size)
function initProductOptions() {
  // Color options
  const colorOptions = document.querySelectorAll('.color-option');
  colorOptions.forEach(option => {
    option.addEventListener('click', function() {
      // Remove active class from all color options
      colorOptions.forEach(o => o.classList.remove('active'));

      // Add active class to clicked option
      this.classList.add('active');

      // You can add logic here to update product info based on color
      const selectedColor = this.dataset.color;
      console.log('Selected color:', selectedColor);
    });
  });

  // Size options
  const sizeOptions = document.querySelectorAll('.size-option');
  sizeOptions.forEach(option => {
    option.addEventListener('click', function() {
      // Remove active class from all size options
      sizeOptions.forEach(o => o.classList.remove('active'));

      // Add active class to clicked option
      this.classList.add('active');

      // You can add logic here to update product info based on size
      const selectedSize = this.dataset.size;
      console.log('Selected size:', selectedSize);
    });
  });
}

// Quantity Controls
function initQuantityControls() {
  const qtyInput = document.querySelector('.qty-input');
  const minusBtn = document.querySelector('.qty-btn.minus');
  const plusBtn = document.querySelector('.qty-btn.plus');

  if (!qtyInput || !minusBtn || !plusBtn) return;

  // Minus button
  minusBtn.addEventListener('click', function() {
    let currentValue = parseInt(qtyInput.value) || 1;
    if (currentValue > 1) {
      qtyInput.value = currentValue - 1;
    }
  });

  // Plus button
  plusBtn.addEventListener('click', function() {
    let currentValue = parseInt(qtyInput.value) || 1;
    qtyInput.value = currentValue + 1;
  });

  // Input validation
  qtyInput.addEventListener('input', function() {
    let value = parseInt(this.value);
    if (isNaN(value) || value < 1) {
      this.value = 1;
    }
  });

  // Add to cart button
  const addToCartBtn = document.querySelector('.add-to-cart-btn');
  if (addToCartBtn) {
    addToCartBtn.addEventListener('click', function() {
      const quantity = parseInt(qtyInput.value) || 1;
      const selectedColor = document.querySelector('.color-option.active')?.dataset.color;
      const selectedSize = document.querySelector('.size-option.active')?.dataset.size;

      // Here you would typically make an AJAX request to add the item to cart
      console.log('Adding to cart:', {
        quantity: quantity,
        color: selectedColor,
        size: selectedSize
      });

      // Show success message (you can customize this)
      showNotification('Product added to cart!', 'success');
    });
  }
}

// Product Tabs
function initProductTabs() {
  console.log('Initializing product tabs...');

  const tabButtons = document.querySelectorAll('.tab-btn');
  const tabPanes = document.querySelectorAll('.tab-pane');

  console.log('Found tab buttons:', tabButtons.length);
  console.log('Found tab panes:', tabPanes.length);

  if (tabButtons.length === 0 || tabPanes.length === 0) {
    console.log('No tabs found, exiting...');
    return;
  }

  tabButtons.forEach((button, index) => {
    console.log(`Setting up tab button ${index}:`, button.dataset.tab);

    button.addEventListener('click', function(e) {
      e.preventDefault();
      console.log('Tab clicked:', this.dataset.tab);

      const targetTab = this.dataset.tab;

      // Remove active class from all buttons and panes
      tabButtons.forEach(btn => btn.classList.remove('active'));
      tabPanes.forEach(pane => pane.classList.remove('active'));

      // Add active class to clicked button
      this.classList.add('active');

      // Show corresponding tab pane
      const targetPane = document.getElementById(targetTab);
      if (targetPane) {
        targetPane.classList.add('active');
        console.log('Activated tab pane:', targetTab);
      } else {
        console.log('Tab pane not found:', targetTab);
      }
    });
  });

  console.log('Product tabs initialized successfully');
}

// Utility function to show notifications
function showNotification(message, type = 'info') {
  // Create notification element
  const notification = document.createElement('div');
  notification.className = `notification notification-${type}`;
  notification.innerHTML = `
    <div class="notification-content">
      <span class="notification-message">${message}</span>
      <button class="notification-close">&times;</button>
    </div>
  `;

  // Add styles
  notification.style.cssText = `
    position: fixed;
    top: 20px;
    right: 20px;
    background: ${type === 'success' ? '#38a169' : type === 'error' ? '#e53e3e' : '#667eea'};
    color: white;
    padding: 15px 20px;
    border-radius: 8px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
    z-index: 1000;
    transform: translateX(100%);
    transition: transform 0.3s ease;
  `;

  // Add to page
  document.body.appendChild(notification);

  // Animate in
  setTimeout(() => {
    notification.style.transform = 'translateX(0)';
  }, 100);

  // Close button functionality
  const closeBtn = notification.querySelector('.notification-close');
  closeBtn.addEventListener('click', () => {
    removeNotification(notification);
  });

  // Auto remove after 3 seconds
  setTimeout(() => {
    removeNotification(notification);
  }, 3000);
}

function removeNotification(notification) {
  notification.style.transform = 'translateX(100%)';
  setTimeout(() => {
    if (notification.parentNode) {
      notification.parentNode.removeChild(notification);
    }
  }, 300);
}

// Smooth scrolling for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', function (e) {
    e.preventDefault();
    const target = document.querySelector(this.getAttribute('href'));
    if (target) {
      target.scrollIntoView({
        behavior: 'smooth',
        block: 'start'
      });
    }
  });
});

// Image zoom on hover (optional enhancement)
function initImageZoom() {
  const mainImage = document.getElementById('mainProductImage');
  if (!mainImage) return;

  mainImage.addEventListener('mouseenter', function() {
    this.style.transform = 'scale(1.1)';
    this.style.transition = 'transform 0.3s ease';
  });

  mainImage.addEventListener('mouseleave', function() {
    this.style.transform = 'scale(1)';
  });
}

// Initialize image zoom if needed
// initImageZoom();
