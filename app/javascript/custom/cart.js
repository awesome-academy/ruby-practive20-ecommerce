document.addEventListener("DOMContentLoaded", function() {
  function t(key, options) {
    if (window.I18n && window.I18n.t) {
      return window.I18n.t(key, options);
    }
    return key;
  }

  // Handle quantity changes
  document.addEventListener("click", function(e) {
    if (e.target.closest(".quantity-btn")) {
      const btn = e.target.closest(".quantity-btn");
      const action = btn.dataset.action;
      const itemId = btn.dataset.itemId;
      const input = document.querySelector(`.quantity-input[data-item-id="${itemId}"]`);
      
      if (!input) return;
      
      let currentValue = parseInt(input.value);
      const maxStock = parseInt(input.dataset.availableStock);
      
      if (action === "increase" && currentValue < maxStock) {
        input.value = currentValue + 1;
        updateCartItem(itemId, input.value);
      } else if (action === "decrease" && currentValue > 1) {
        input.value = currentValue - 1;
        updateCartItem(itemId, input.value);
      }
    }
  });

  // Handle manual quantity input changes
  document.addEventListener("change", function(e) {
    if (e.target.classList.contains("quantity-input")) {
      const input = e.target;
      const itemId = input.dataset.itemId;
      const maxStock = parseInt(input.dataset.availableStock);
      let value = parseInt(input.value);
      
      // Validate input
      if (isNaN(value) || value < 1) {
        value = 1;
        input.value = value;
      } else if (value > maxStock) {
        value = maxStock;
        input.value = value;
        showAlert(t("carts.javascript.stock_warning", { count: maxStock }), "warning");
      }
      
      updateCartItem(itemId, value);
    }
  });

  // Handle remove item
  document.addEventListener("click", function(e) {
    if (e.target.closest(".remove-item-btn")) {
      e.preventDefault();
      const btn = e.target.closest(".remove-item-btn");
      const itemId = btn.dataset.itemId;
      const deleteUrl = btn.dataset.url;
      const confirmMessage = btn.dataset.confirm;
      
      if (confirm(confirmMessage)) {
        removeCartItem(itemId, deleteUrl);
      }
    }
  });

  // Handle add to cart from suggested products
  document.addEventListener("submit", function(e) {
    if (e.target.classList.contains("add-to-cart-form")) {
      e.preventDefault();
      const form = e.target;
      const formData = new FormData(form);
      
      // Show loading state
      const submitBtn = form.querySelector('button[type="submit"]');
      const originalText = submitBtn.innerHTML;
      submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> ' + t("carts.javascript.adding_product");
      submitBtn.disabled = true;
      
      fetch(form.action, {
        method: "POST",
        body: formData,
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRF-Token": getCSRFToken()
        }
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          showAlert(t("carts.javascript.product_added"), "success");
          updateCartBadge(data.cart_items_count);
          
          // Update cart page header count if on cart page
          if (window.location.pathname.includes('/cart')) {
            updateCartPageHeaderCount(data.cart_items_count);
          }
          
          // If we're on the cart page, reload it to show the new item
          if (window.location.pathname.includes('/cart')) {
            setTimeout(() => {
              window.location.reload();
            }, 1000);
          }
        } else {
          showAlert(data.message || t("carts.javascript.error_occurred"), "error");
        }
      })
      .catch(error => {
        console.error("Error:", error);
        showAlert(t("carts.javascript.add_product_error"), "error");
      })
      .finally(() => {
        // Restore button state
        submitBtn.innerHTML = originalText;
        submitBtn.disabled = false;
      });
    }
  });

  function updateCartItem(itemId, quantity) {
    const loadingSpinner = showLoadingSpinner(itemId);
    const locale = document.documentElement.lang || 'en';
    
    fetch(`/${locale}/cart/items/${itemId}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
        "X-CSRF-Token": getCSRFToken()
      },
      body: JSON.stringify({ quantity: quantity })
    })
    .then(response => response.json())
    .then(data => {
      hideLoadingSpinner(loadingSpinner);
      
      if (data.success) {
        // Update item total
        const itemTotalElement = document.querySelector(`.total-price[data-item-id="${itemId}"]`);
        if (itemTotalElement) {
          itemTotalElement.textContent = formatCurrency(data.item_total);
        }
        
        // Update cart summary
        updateCartSummary(data.cart_total, data.cart_items_count);
        
        // Update cart page header count
        updateCartPageHeaderCount(data.cart_items_count);
        
        showAlert(t("carts.javascript.cart_updated"), "success");
      } else {
        showAlert(data.message || t("carts.javascript.error_occurred"), "error");
        // Revert input value
        location.reload();
      }
    })
    .catch(error => {
      hideLoadingSpinner(loadingSpinner);
      console.error("Error:", error);
      showAlert(t("carts.javascript.update_cart_error"), "error");
      location.reload();
    });
  }

  function removeCartItem(itemId, deleteUrl) {
    const itemElement = document.getElementById(`cart-item-${itemId}`);
    if (itemElement) {
      itemElement.style.opacity = "0.5";
      itemElement.style.pointerEvents = "none";
    }
    
    fetch(deleteUrl, {
      method: "DELETE",
      headers: {
        "X-Requested-With": "XMLHttpRequest",
        "X-CSRF-Token": getCSRFToken()
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // Remove item from DOM
        if (itemElement) {
          itemElement.remove();
        }
        
        // Update cart summary
        updateCartSummary(data.cart_total, data.cart_items_count);
        
        // Update cart page header count
        updateCartPageHeaderCount(data.cart_items_count);
        
        // Check if cart is empty
        const cartItemsContainer = document.getElementById("cart-items");
        if (cartItemsContainer && cartItemsContainer.children.length === 0) {
          location.reload(); // Reload to show empty cart state
        }
        
        showAlert(data.message || t("carts.javascript.product_removed"), "success");
      } else {
        // Restore item appearance
        if (itemElement) {
          itemElement.style.opacity = "1";
          itemElement.style.pointerEvents = "auto";
        }
        showAlert(data.message || t("carts.javascript.error_occurred"), "error");
      }
    })
    .catch(error => {
      // Restore item appearance
      if (itemElement) {
        itemElement.style.opacity = "1";
        itemElement.style.pointerEvents = "auto";
      }
      console.error("Error:", error);
      showAlert(t("carts.javascript.remove_product_error"), "error");
    });
  }

  function updateCartSummary(total, itemsCount) {
    // Update cart total
    const cartTotalElement = document.querySelector(".cart-total");
    if (cartTotalElement) {
      cartTotalElement.textContent = formatCurrency(total);
    }
    
    // Update cart subtotal
    const cartSubtotalElement = document.querySelector(".cart-subtotal");
    if (cartSubtotalElement) {
      cartSubtotalElement.textContent = formatCurrency(total);
    }
    
    // Update cart badge
    updateCartBadge(itemsCount);
  }

  function updateCartBadge(count) {
    // Update cart badge in header
    const badge = document.getElementById("cart-items-count");
    if (badge) {
      badge.textContent = count;
      badge.style.display = count > 0 ? "inline" : "none";
    }
    
    // Update navbar cart badge if exists
    const navCartBadge = document.querySelector(".navbar .cart-badge");
    if (navCartBadge) {
      navCartBadge.textContent = count;
      if (navCartBadge instanceof HTMLElement) {
        navCartBadge.style.display = count > 0 ? "inline" : "none";
      }
    }
  }

  function updateCartPageHeaderCount(count) {
    // Update cart count in cart page header
    const cartCountElement = document.querySelector(".cart-page .cart-count");
    if (cartCountElement) {
      cartCountElement.textContent = count;
    }
  }

  function showLoadingSpinner(itemId) {
    const spinner = document.createElement("div");
    spinner.innerHTML = '<i class="fas fa-spinner fa-spin text-primary"></i>';
    spinner.className = "loading-spinner position-absolute";
    spinner.style.cssText = "top: 50%; left: 50%; transform: translate(-50%, -50%); z-index: 1000;";
    
    const itemElement = document.getElementById(`cart-item-${itemId}`);
    if (itemElement) {
      itemElement.style.position = "relative";
      itemElement.appendChild(spinner);
    }
    
    return spinner;
  }

  function hideLoadingSpinner(spinner) {
    if (spinner && spinner.parentNode) {
      spinner.parentNode.removeChild(spinner);
    }
  }

  function formatCurrency(amount) {
    // Format consistently with Rails number_to_currency helper - Vietnamese format
    // Convert to number and format manually to match Rails format exactly
    const number = parseFloat(amount);
    const parts = number.toFixed(2).split('.');
    const integerPart = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    const decimalPart = parts[1];
    return `${integerPart},${decimalPart} ₫`;
  }

  function getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]');
    return token ? token.getAttribute("content") : "";
  }

  function showAlert(message, type = "info") {
    // Create alert element
    const alert = document.createElement("div");
    alert.className = `alert alert-${type === "error" ? "danger" : type} alert-dismissible fade show position-fixed`;
    alert.style.cssText = "top: 20px; right: 20px; z-index: 1050; min-width: 300px;";
    
    alert.innerHTML = `
      ${message}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    document.body.appendChild(alert);
    
    // Auto dismiss after 5 seconds
    setTimeout(() => {
      if (alert.parentNode) {
        alert.classList.remove("show");
        setTimeout(() => {
          if (alert.parentNode) {
            alert.parentNode.removeChild(alert);
          }
        }, 150);
      }
    }, 5000);
  }
});
