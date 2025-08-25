// Admin Categories Index JavaScript
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
});
