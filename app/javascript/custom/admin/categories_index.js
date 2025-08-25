// Admin Categories Index JavaScript

// I18n helper function
function t(key) {
  if (window.I18n && window.I18n.t) {
    return window.I18n.t(key);
  }
  return key;
}

document.addEventListener('DOMContentLoaded', function() {
  // Get buttons
  const expandAllBtn = document.getElementById('expand-all-btn');
  const collapseAllBtn = document.getElementById('collapse-all-btn');

  // Expand/Collapse functionality
  function expandAll() {
    document.querySelectorAll('.collapse').forEach(function(element) {
      const collapse = new bootstrap.Collapse(element, { toggle: false });
      collapse.show();
    });
  }

  function collapseAll() {
    document.querySelectorAll('.collapse.show').forEach(function(element) {
      const collapse = new bootstrap.Collapse(element, { toggle: false });
      collapse.hide();
    });
  }

  // Add event listeners
  if (expandAllBtn) {
    expandAllBtn.addEventListener('click', expandAll);
  }
  
  if (collapseAllBtn) {
    collapseAllBtn.addEventListener('click', collapseAll);
  }

  // SortableJS Drag and Drop functionality
  const sortable = document.querySelector('.sortable');
  
  if (sortable && window.Sortable) {
    new window.Sortable(sortable, {
      animation: 150,
      ghostClass: 'sortable-ghost',
      chosenClass: 'sortable-chosen',
      handle: '.drag-handle',
      onEnd: function(evt) {
        const row = evt.item;
        const newIndex = evt.newIndex;
        const oldIndex = evt.oldIndex;
        
        if (newIndex !== oldIndex) {
          updatePositions();
        }
      }
    });
  }

  function updatePositions() {
    const sortableEl = document.querySelector('.sortable');
    if (!sortableEl) return;
    
    const rows = sortableEl.querySelectorAll('.category-item');
    const categoryIds = Array.from(rows).map(row => {
      const element = row;
      return element.dataset.id;
    });
    
    // Send AJAX request to update positions
    const sortUrl = sortableEl.dataset.sortUrl;
    const sortParam = sortableEl.dataset.sortParam;
    
    if (sortUrl && categoryIds.length > 0) {
      const formData = new FormData();
      categoryIds.forEach((id) => {
        formData.append('category[]', id);
      });

      const csrfToken = document.querySelector('meta[name="csrf-token"]');
      const headers = {
        'Accept': 'application/json'
      };
      
      if (csrfToken) {
        headers['X-CSRF-Token'] = csrfToken.getAttribute('content');
      }

      fetch(sortUrl, {
        method: 'PATCH',
        body: formData,
        headers: headers
      })
      .then(response => {
        if (response.ok) {
          // Update positions in real-time
          updatePositionsDisplay();
          
          showNotification(t('admin.categories.javascript.reorder_success'), 'success');
        } else {
          console.error('Failed to reorder categories');
          showNotification(t('admin.categories.javascript.reorder_error'), 'error');
        }
      })
      .catch(error => {
        console.error('Error:', error);
        showNotification(t('admin.categories.javascript.reorder_exception'), 'error');
      });
    }
  }

  function updatePositionsDisplay() {
    // Update position display for all parent categories
    const parentRows = document.querySelectorAll('.category-item');
    
    parentRows.forEach((row, index) => {
      const parentPosition = index + 1;
      const positionCell = row.querySelector('td:nth-child(7) .badge'); // Position column
      
      if (positionCell) {
        positionCell.textContent = parentPosition.toString();
      }
      
      // Update child categories positions
      let nextSibling = row.nextElementSibling;
      let childIndex = 1;
      
      while (nextSibling && nextSibling.classList.contains('category-child')) {
        const childPositionCell = nextSibling.querySelector('td:nth-child(7) .badge');
        if (childPositionCell) {
          childPositionCell.textContent = `${parentPosition}.${childIndex}`;
        }
        childIndex++;
        nextSibling = nextSibling.nextElementSibling;
      }
    });
  }

  function showNotification(message, type) {
    // Create and show a Bootstrap alert
    const alertHtml = `
      <div class="alert alert-${type === 'success' ? 'success' : 'danger'} alert-dismissible fade show" role="alert">
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
      </div>
    `;
    
    const container = document.querySelector('.container-fluid');
    if (container) {
      container.insertAdjacentHTML('afterbegin', alertHtml);
      
      // Auto remove after 3 seconds
      setTimeout(() => {
        const alert = container.querySelector('.alert');
        if (alert) {
          alert.remove();
        }
      }, 3000);
    }
  }

  // Enhanced fallback initialization with multiple timing attempts
  function initializeSortableFallback() {
    if (window.Sortable) {
      const sortable = document.querySelector('.sortable');
      if (sortable && !window.categorySortable) {
        window.categorySortable = new window.Sortable(sortable, {
          animation: 150,
          ghostClass: 'sortable-ghost',
          chosenClass: 'sortable-chosen',
          handle: '.drag-handle',
          onEnd: function(evt) {            
            // Get all parent category rows in new order (not child categories)
            const sortableEl = document.querySelector('.sortable');
            const rows = sortableEl.querySelectorAll('tr.category-item[data-id]');
            const categoryIds = Array.from(rows).map(row => row.dataset.id);
            
            // Update position via AJAX
            const sortUrl = sortableEl.dataset.sortUrl;
            
            const formData = new FormData();
            categoryIds.forEach((id, index) => {
              formData.append('category[]', id);
            });
            
            fetch(sortUrl, {
              method: 'PATCH',
              body: formData,
              headers: {
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                'X-Requested-With': 'XMLHttpRequest'
              }
            })
            .then(response => {
              if (response.ok) {
                // Update position numbers in the table
                updatePositionNumbersFallback();
                showNotification(t('admin.categories.javascript.reorder_success'), 'success');
              } else {
                console.error('Failed to update position');
                showNotification(t('admin.categories.javascript.reorder_error'), 'error');
                // Revert the change
                evt.from.insertBefore(evt.item, evt.from.children[evt.oldIndex]);
              }
            })
            .catch(error => {
              console.error('Error updating position:', error);
              showNotification(t('admin.categories.javascript.reorder_exception'), 'error');
              // Revert the change
              evt.from.insertBefore(evt.item, evt.from.children[evt.oldIndex]);
            });
          }
        });
        window.fallbackSortableRan = true;
        return true;
      }
    }
    return false;
  }

  function updatePositionNumbersFallback() {
    const rows = document.querySelectorAll('.sortable tr[data-id]');
    rows.forEach((row, index) => {
      const positionCell = row.querySelector('[data-position]');
      if (positionCell) {
        positionCell.textContent = index + 1;
      }
    });
  }

  // Initialize fallback sortable functionality
  function initializeFallbackSortable() {
    // Try initialization immediately
    if (!initializeSortableFallback()) {
      // If failed, try on DOMContentLoaded
      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
          if (!initializeSortableFallback()) {
            // If still failed, try after a short delay
            setTimeout(initializeSortableFallback, 100);
          }
        });
      } else {
        // Document already loaded, try after a short delay
        setTimeout(initializeSortableFallback, 100);
      }
    }
  }

  // Initialize fallback
  initializeFallbackSortable();

  // Also try on Turbo events for Rails 7
  document.addEventListener('turbo:load', initializeSortableFallback);
  document.addEventListener('turbo:render', initializeSortableFallback);
});
