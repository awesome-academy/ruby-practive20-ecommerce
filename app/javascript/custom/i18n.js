// Simple I18n implementation for i18n-js gem compatibility
(function() {
  'use strict';

  // Create I18n object if it doesn't exist
  if (typeof window.I18n === 'undefined') {
    window.I18n = {};
  }

  var I18n = window.I18n;

  // Initialize translations object
  I18n.translations = I18n.translations || {};

  // Default locale
  I18n.defaultLocale = 'en';
  
  // Function to update locale from Rails
  I18n.updateLocale = function() {
    I18n.locale = window.currentLocale || I18n.defaultLocale;
  };

  // Set initial locale
  I18n.updateLocale();

  // Update locale when it changes
  I18n.setLocale = function(locale) {
    I18n.locale = locale;
  };

  // Extend function to merge objects
  I18n.extend = function(target, source) {
    if (!target) target = {};
    if (!source) return target;

    for (var key in source) {
      if (source.hasOwnProperty(key)) {
        if (typeof source[key] === 'object' && source[key] !== null && !Array.isArray(source[key])) {
          target[key] = I18n.extend(target[key] || {}, source[key]);
        } else {
          target[key] = source[key];
        }
      }
    }
    return target;
  };

  // Simple translation function
  I18n.t = function(key, options) {
    options = options || {};
    var locale = options.locale || I18n.locale;
    var translations = I18n.translations[locale] || I18n.translations[I18n.defaultLocale] || {};
    
    var keys = key.split('.');
    var result = translations;
    
    for (var i = 0; i < keys.length; i++) {
      if (result && typeof result === 'object' && result.hasOwnProperty(keys[i])) {
        result = result[keys[i]];
      } else {
        // Fallback to default locale if not found
        if (locale !== I18n.defaultLocale) {
          return I18n.t(key, Object.assign({}, options, { locale: I18n.defaultLocale }));
        }
        return key; // Return key if translation not found
      }
    }
    
    // Handle interpolation
    if (typeof result === 'string' && options) {
      result = result.replace(/%\{([^}]+)\}/g, function(match, key) {
        return options.hasOwnProperty(key) ? options[key] : match;
      });
    }
    
    return result;
  };

  // Alias for translate
  I18n.translate = I18n.t;
})();

// Update I18n locale after Turbo navigation
document.addEventListener('turbo:load', function() {
  if (window.I18n && window.I18n.updateLocale) {
    window.I18n.updateLocale();
  }
});

// Also update on regular page load
document.addEventListener('DOMContentLoaded', function() {
  if (window.I18n && window.I18n.updateLocale) {
    window.I18n.updateLocale();
  }
});
