# frozen_string_literal: true

# Pagy initializer file
require 'pagy/extras/bootstrap'
require 'pagy/extras/trim'
require 'pagy/extras/i18n'

# Set default values for Pagy v9+
Pagy::DEFAULT[:limit] = 12
Pagy::DEFAULT[:items] = 12  # Để cả hai cho tương thích
