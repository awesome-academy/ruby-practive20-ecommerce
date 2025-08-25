// Admin Category Form JavaScript
document.addEventListener('DOMContentLoaded', function() {
  const nameField = document.querySelector('#category_name');
  const slugField = document.querySelector('#category_slug');
  
  if (nameField && slugField) {
    nameField.addEventListener('input', function() {
      if (slugField.value === '' || !slugField.dataset.manuallyEdited) {
        const slug = this.value
          .toLowerCase()
          .replace(/[^a-z0-9\s-]/g, '')
          .replace(/\s+/g, '-')
          .replace(/-+/g, '-')
          .trim('-');
        slugField.value = slug;
      }
    });
    
    slugField.addEventListener('input', function() {
      this.dataset.manuallyEdited = 'true';
    });
  }
  
  // Character counter for meta description
  const metaDescField = document.querySelector('#category_meta_description');
  if (metaDescField) {
    const counter = document.createElement('small');
    counter.className = 'text-muted';
    metaDescField.parentNode.appendChild(counter);
    
    function updateCounter() {
      const length = metaDescField.value.length;
      counter.textContent = `${length}/160 characters`;
      counter.className = length > 160 ? 'text-danger' : 'text-muted';
    }
    
    metaDescField.addEventListener('input', updateCounter);
    updateCounter();
  }
});
