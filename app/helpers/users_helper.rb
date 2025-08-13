module UsersHelper
  def gravatar_for user
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    gravatar_url = "#{Settings.urls.gravatar}#{gravatar_id}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end

  def gender_options
    User.genders.map do |key, _value|
      [t("users.gender.#{key}"), key]
    end
  end
end
