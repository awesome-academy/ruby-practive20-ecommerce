// Admin Layout JavaScript Functions
// Initialize components when page loads
function initializeComponents() {
  // Auto-hide alerts after 5 seconds
  const alerts = document.querySelectorAll('.alert-dismissible');
  alerts.forEach(function(alert) {
    setTimeout(function() {
      if (alert && alert.parentNode) {
        const bsAlert = new bootstrap.Alert(alert);
        bsAlert.close();
      }
    }, 5000);
  });
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', initializeComponents);

// Re-initialize on Turbo navigation (Rails 7)
document.addEventListener('turbo:load', initializeComponents);
