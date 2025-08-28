// Bootstrap 3 JavaScript components
// Load jQuery first
import "jquery"
import "bootstrap"

// Initialize Bootstrap components after DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
  // Auto-initialize modal, dropdown, and other components
  console.log('Bootstrap 3 JavaScript initialized');
  
  // Check if jQuery and Bootstrap are loaded
  const $ = window['$'];
  if ($) {
    console.log('jQuery loaded successfully');
    console.log('Modal plugin:', typeof $.fn.modal);
  } else {
    console.log('jQuery not loaded');
  }
});
