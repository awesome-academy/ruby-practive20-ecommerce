// Checkout page functionality

// I18n helper function
function t(key) {
  if (window.I18n && window.I18n.t) {
    return window.I18n.t(key);
  }
  return key;
}

function initializeCheckoutJS() {
  const shippingRadios = document.querySelectorAll('.shipping-radio');
  const shippingFeeElement = document.getElementById('shipping-fee');
  const totalAmountElement = document.getElementById('total-amount');
  
  // Get subtotal from the page data
  const subtotalElement = document.querySelector('.price-breakdown .price-row:first-child span:last-child');
  
  if (!subtotalElement || !shippingFeeElement || !totalAmountElement) {
    console.log('Checkout elements not found, skipping initialization');
    return; // Exit if required elements are not found
  }
  
  const subtotal = parseFloat(subtotalElement.textContent.replace(/[^\d]/g, ''));
  console.log('Initializing checkout with subtotal:', subtotal);
  
  // Function to format currency in Vietnamese format
  function formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN').format(amount) + ' ₫';
  }
  
  // Remove any existing event listeners to prevent duplicates
  shippingRadios.forEach(radio => {
    radio.removeEventListener('change', radio._checkoutHandler);
  });
  
  // Add event listeners to shipping radio buttons
  shippingRadios.forEach(radio => {
    const handler = function() {
      if (this.checked) {
        const shippingPrice = parseInt(this.dataset.price);
        const total = subtotal + shippingPrice;
        
        console.log('Shipping method changed:', this.value, 'Price:', shippingPrice, 'Total:', total);
        
        // Update shipping fee display
        shippingFeeElement.textContent = formatCurrency(shippingPrice);
        
        // Update total amount display
        totalAmountElement.textContent = formatCurrency(total);
        
        // Add visual feedback
        shippingFeeElement.style.color = '#007bff';
        totalAmountElement.style.color = '#007bff';
        
        setTimeout(() => {
          shippingFeeElement.style.color = '';
          totalAmountElement.style.color = '';
        }, 300);
      }
    };
    
    // Store the handler reference for later removal
    radio._checkoutHandler = handler;
    radio.addEventListener('change', handler);
  });
  
  // Form validation
  const checkoutForm = document.querySelector('.checkout-form');
  const placeOrderBtn = document.getElementById('place-order-btn');
  
  if (checkoutForm && placeOrderBtn) {
    // Remove existing listener if any
    if (placeOrderBtn._checkoutClickHandler) {
      placeOrderBtn.removeEventListener('click', placeOrderBtn._checkoutClickHandler);
    }
    
    const clickHandler = function(e) {
      const termsCheckbox = document.getElementById('order_form_terms_accepted');
      
      if (termsCheckbox && termsCheckbox instanceof HTMLInputElement && !termsCheckbox.checked) {
        e.preventDefault();
        alert(t('checkout.new.terms_required'));
        termsCheckbox.focus();
        return false;
      }
    };
    
    placeOrderBtn._checkoutClickHandler = clickHandler;
    placeOrderBtn.addEventListener('click', clickHandler);
  }
  
  console.log('Checkout JavaScript initialized successfully');
}

// Initialize on DOMContentLoaded
document.addEventListener('DOMContentLoaded', initializeCheckoutJS);

// Also initialize on Turbo navigation (Rails 7+ with Turbo)
document.addEventListener('turbo:load', initializeCheckoutJS);

// For older Turbolinks (Rails < 7)
document.addEventListener('turbolinks:load', initializeCheckoutJS);
