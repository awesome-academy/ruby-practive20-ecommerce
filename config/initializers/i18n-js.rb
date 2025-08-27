# I18n-js configuration
require 'i18n-js'

I18n.backend.class.send(:include, I18n::Backend::Pluralization)
I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
