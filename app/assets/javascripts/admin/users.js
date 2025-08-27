// Admin Users JavaScript

document.addEventListener('DOMContentLoaded', function() {
  // Select all checkbox functionality
  const selectAllCheckbox = document.getElementById('select-all');
  const userCheckboxes = document.querySelectorAll('.user-checkbox');
  const bulkSubmitBtn = document.getElementById('bulk-submit');
  const bulkActionSelect = document.getElementById('bulk-action-select');
  const reasonField = document.getElementById('reason-field');

  if (selectAllCheckbox) {
    selectAllCheckbox.addEventListener('change', function() {
      userCheckboxes.forEach(function(checkbox) {
        checkbox.checked = selectAllCheckbox.checked;
      });
      updateBulkSubmitButton();
    });
  }

  // Individual checkbox change
  userCheckboxes.forEach(function(checkbox) {
    checkbox.addEventListener('change', function() {
      updateSelectAllCheckbox();
      updateBulkSubmitButton();
    });
  });

  // Bulk action select change
  if (bulkActionSelect) {
    bulkActionSelect.addEventListener('change', function() {
      const selectedAction = this.value;
      
      // Show/hide reason field for deactivate action
      if (reasonField) {
        if (selectedAction === 'deactivate') {
          reasonField.style.display = 'block';
        } else {
          reasonField.style.display = 'none';
        }
      }
      
      updateBulkSubmitButton();
    });
  }

  // Deactivate modal handling
  const deactivateModal = document.getElementById('deactivateModal');
  if (deactivateModal) {
    // Handle modal trigger from table buttons
    document.querySelectorAll('[data-toggle="modal"][data-target="#deactivateModal"]').forEach(function(button) {
      button.addEventListener('click', function(e) {
        e.preventDefault();
        
        const userId = this.getAttribute('data-user-id');
        const userName = this.getAttribute('data-user-name');
        const form = document.getElementById('deactivate-form');
        const userNamePlaceholder = document.getElementById('user-name-placeholder');
        
        if (form && userId) {
          // Update form action URL
          const baseUrl = this.href;
          form.action = baseUrl;
        }
        
        if (userNamePlaceholder && userName) {
          userNamePlaceholder.textContent = userName;
        }
        
        // Show modal
        $(deactivateModal).modal('show');
      });
    });
  }

  function updateSelectAllCheckbox() {
    const checkedCount = document.querySelectorAll('.user-checkbox:checked').length;
    const totalCount = userCheckboxes.length;
    
    if (selectAllCheckbox) {
      if (checkedCount === 0) {
        selectAllCheckbox.indeterminate = false;
        selectAllCheckbox.checked = false;
      } else if (checkedCount === totalCount) {
        selectAllCheckbox.indeterminate = false;
        selectAllCheckbox.checked = true;
      } else {
        selectAllCheckbox.indeterminate = true;
        selectAllCheckbox.checked = false;
      }
    }
  }

  function updateBulkSubmitButton() {
    const checkedCount = document.querySelectorAll('.user-checkbox:checked').length;
    const selectedAction = bulkActionSelect ? bulkActionSelect.value : '';
    
    if (bulkSubmitBtn) {
      if (checkedCount > 0 && selectedAction) {
        bulkSubmitBtn.disabled = false;
        bulkSubmitBtn.textContent = bulkSubmitBtn.textContent.replace(/\(\d+\)/, '') + ' (' + checkedCount + ')';
      } else {
        bulkSubmitBtn.disabled = true;
        bulkSubmitBtn.textContent = bulkSubmitBtn.textContent.replace(/\s*\(\d+\)/, '');
      }
    }
  }

  // Search form auto-submit on filter change
  const searchForm = document.querySelector('form[action*="admin/users"]');
  if (searchForm) {
    const filterSelects = searchForm.querySelectorAll('select');
    const dateInputs = searchForm.querySelectorAll('input[type="date"]');
    
    filterSelects.forEach(function(select) {
      select.addEventListener('change', function() {
        searchForm.submit();
      });
    });
    
    dateInputs.forEach(function(input) {
      input.addEventListener('change', function() {
        // Add small delay to allow user to select both dates
        setTimeout(function() {
          const startDate = searchForm.querySelector('input[name="start_date"]').value;
          const endDate = searchForm.querySelector('input[name="end_date"]').value;
          
          if (startDate && endDate) {
            searchForm.submit();
          }
        }, 500);
      });
    });
  }

  // Confirmation for bulk actions
  const bulkForm = document.getElementById('bulk-form');
  if (bulkForm) {
    bulkForm.addEventListener('submit', function(e) {
      const checkedCount = document.querySelectorAll('.user-checkbox:checked').length;
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
      
      const actionText = selectedAction === 'activate' ? 'activate' : 'deactivate';
      const confirmMessage = 'Are you sure you want to ' + actionText + ' ' + checkedCount + ' user(s)?';
      
      if (!confirm(confirmMessage)) {
        e.preventDefault();
        return false;
      }
    });
  }

  // Initialize on page load
  updateSelectAllCheckbox();
  updateBulkSubmitButton();
});
