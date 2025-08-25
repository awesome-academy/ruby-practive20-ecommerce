// Admin Product Form JavaScript
document.addEventListener('DOMContentLoaded', function() {
  // Bootstrap form validation
  const forms = document.getElementsByClassName('needs-validation');
  
  Array.prototype.filter.call(forms, function(form) {
    form.addEventListener('submit', function(event) {
      if (form.checkValidity() === false) {
        event.preventDefault();
        event.stopPropagation();
      }
      form.classList.add('was-validated');
    }, false);
  });
});
