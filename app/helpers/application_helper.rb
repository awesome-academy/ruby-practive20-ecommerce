module ApplicationHelper
  def full_title page_title = ""
    base_title = Settings.app.name
    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end

  def link_to_locale locale_key
    locale_name = locale_key.to_s.upcase
    current_locale = I18n.locale.to_s
    css_class = current_locale == locale_key.to_s ? "active" : ""

    link_to locale_name, url_for(locale: locale_key), class: css_class
  end

  def alert_class_for message_type
    case message_type.to_s.to_sym
    when :success
      Settings.alert.success
    when :error
      Settings.alert.error
    when :danger
      Settings.alert.danger
    when :warning
      Settings.alert.warning
    when :info
      Settings.alert.info
    else
      "alert-#{message_type}"
    end
  end
end
