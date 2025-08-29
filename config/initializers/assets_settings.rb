# Make Settings and I18n available to JavaScript
Rails.application.configure do
  config.after_initialize do
    # Expose settings to JavaScript
    Rails.application.config.assets.precompile += %w( settings.js )
  end
end
