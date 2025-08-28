// Prevent uploading of big images with I18n support
document.addEventListener("turbo:load", function() {
  document.addEventListener("change", function(event) {
    let image_upload = document.querySelector('#product_images');
    if (image_upload && event.target === image_upload && image_upload instanceof HTMLInputElement) {
      const files = image_upload.files;
      if (files && files.length > 0) {
        let hasError = false;
        const max_size = window.Settings.product.max_image_size;
        const validTypes = window.Settings.product.allowed_mime_types;
        
        // Check each file
        for (let i = 0; i < files.length; i++) {
          const file = files[i];
          const size_in_megabytes = file.size/1024/1024;
          
          // Check file size
          if (size_in_megabytes > max_size) {
            const errorMessage = I18n.t('javascript.image_upload.file_size_error', {size: max_size});
            alert(errorMessage);
            hasError = true;
            break;
          }
          
          // Check file format
          if (!validTypes.includes(file.type)) {
            const errorMessage = I18n.t('javascript.image_upload.invalid_format');
            alert(errorMessage);
            hasError = true;
            break;
          }
        }
        
        // Clear input if there was an error
        if (hasError) {
          image_upload.value = "";
        }
      }
    }
  });
});
