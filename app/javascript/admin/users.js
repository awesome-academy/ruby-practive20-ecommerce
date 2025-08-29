// Admin Users JavaScript
document.addEventListener('DOMContentLoaded', initAdminUsers);
document.addEventListener('turbo:load', initAdminUsers);

function initAdminUsers() {
  // Only run on admin users pages
  if (!document.querySelector('.admin-users-page')) return;
  
  initBulkActions();
  initSelectAllCheckbox();
  initUserCheckboxes();
  initBulkActionForm();
}

// Bulk Actions
function initBulkActions() {
  const bulkActionSelect = document.getElementById('bulk-action-select');
  const reasonField = document.getElementById('bulk-reason-field');
  const bulkActionBtn = document.getElementById('bulk-action-btn');
  
  if (!bulkActionSelect || !reasonField || !bulkActionBtn) return;
  
  bulkActionSelect.addEventListener('change', function() {
    const selectedAction = this.value;
    
    // Show/hide reason field for deactivate action
    if (selectedAction === 'deactivate') {
      reasonField.style.display = 'block';
      reasonField.required = true;
    } else {
      reasonField.style.display = 'none';
      reasonField.required = false;
      reasonField.value = '';
    }
    
    // Enable/disable bulk action button
    updateBulkActionButton();
  });
}

// Select All Checkbox
function initSelectAllCheckbox() {
  const selectAllCheckbox = document.getElementById('select-all-users');
  if (!selectAllCheckbox) return;
  
  selectAllCheckbox.addEventListener('change', function() {
    const userCheckboxes = document.querySelectorAll('.user-checkbox');
    userCheckboxes.forEach(checkbox => {
      checkbox.checked = this.checked;
    });
    
    updateBulkActionButton();
  });
}

// Individual User Checkboxes
function initUserCheckboxes() {
  const userCheckboxes = document.querySelectorAll('.user-checkbox');
  
  userCheckboxes.forEach(checkbox => {
    checkbox.addEventListener('change', function() {
      updateSelectAllCheckbox();
      updateBulkActionButton();
    });
  });
}

// Update Select All Checkbox state
function updateSelectAllCheckbox() {
  const selectAllCheckbox = document.getElementById('select-all-users');
  const userCheckboxes = document.querySelectorAll('.user-checkbox');
  
  if (!selectAllCheckbox || userCheckboxes.length === 0) return;
  
  const checkedCount = document.querySelectorAll('.user-checkbox:checked').length;
  
  if (checkedCount === 0) {
    selectAllCheckbox.checked = false;
    selectAllCheckbox.indeterminate = false;
  } else if (checkedCount === userCheckboxes.length) {
    selectAllCheckbox.checked = true;
    selectAllCheckbox.indeterminate = false;
  } else {
    selectAllCheckbox.checked = false;
    selectAllCheckbox.indeterminate = true;
  }
}

// Update Bulk Action Button state
function updateBulkActionButton() {
  const bulkActionBtn = document.getElementById('bulk-action-btn');
  const bulkActionSelect = document.getElementById('bulk-action-select');
  const checkedCount = document.querySelectorAll('.user-checkbox:checked').length;
  
  if (!bulkActionBtn || !bulkActionSelect) return;
  
  const hasSelectedUsers = checkedCount > 0;
  const hasSelectedAction = bulkActionSelect.value !== '';
  
  bulkActionBtn.disabled = !(hasSelectedUsers && hasSelectedAction);
  
  // Update button text with count
  if (hasSelectedUsers) {
    const baseText = bulkActionBtn.dataset.originalText || bulkActionBtn.textContent;
    bulkActionBtn.textContent = `${baseText} (${checkedCount})`;
    
    if (!bulkActionBtn.dataset.originalText) {
      bulkActionBtn.dataset.originalText = baseText;
    }
  } else {
    if (bulkActionBtn.dataset.originalText) {
      bulkActionBtn.textContent = bulkActionBtn.dataset.originalText;
    }
  }
}

// Bulk Action Form Submission
function initBulkActionForm() {
  const bulkForm = document.getElementById('bulk-actions-form');
  if (!bulkForm) return;
  
  bulkForm.addEventListener('submit', function(e) {
    const checkedCount = document.querySelectorAll('.user-checkbox:checked').length;
    const bulkActionSelect = document.getElementById('bulk-action-select');
    const selectedAction = bulkActionSelect ? bulkActionSelect.value : '';
    
    if (checkedCount === 0) {
      e.preventDefault();
      alert('Please select at least one user.');
      return false;
    }
    
    if (!selectedAction) {
      e.preventDefault();
      alert('Please select an action.');
      return false;
    }
    
    // Confirmation for destructive actions
    if (selectedAction === 'deactivate') {
      const reasonField = document.getElementById('bulk-reason-field');
      if (reasonField && reasonField.required && !reasonField.value.trim()) {
        e.preventDefault();
        alert('Please provide a reason for deactivation.');
        reasonField.focus();
        return false;
      }
      
      const confirmMessage = `Are you sure you want to deactivate ${checkedCount} user(s)?`;
      if (!confirm(confirmMessage)) {
        e.preventDefault();
        return false;
      }
    } else if (selectedAction === 'activate') {
      const confirmMessage = `Are you sure you want to activate ${checkedCount} user(s)?`;
      if (!confirm(confirmMessage)) {
        e.preventDefault();
        return false;
      }
    }
    
    return true;
  });
}

// Utility Functions
function showNotification(message, type = 'info') {
  // Create notification element
  const notification = document.createElement('div');
  notification.className = `alert alert-${type} alert-dismissible fade show`;
  notification.innerHTML = `
    ${message}
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  `;
  
  // Add to page
  const container = document.querySelector('.content-wrapper') || document.body;
  container.insertBefore(notification, container.firstChild);
  
  // Auto remove after 5 seconds
  setTimeout(() => {
    if (notification.parentNode) {
      notification.remove();
    }
  }, 5000);
}

// Export functions for external use
window.AdminUsers = {
  updateBulkActionButton,
  updateSelectAllCheckbox,
  showNotification
};
