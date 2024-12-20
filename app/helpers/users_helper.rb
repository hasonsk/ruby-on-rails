module UsersHelper
  def gravatar_for user, size: Settings.default.gravatar_size
    gravatar_id  = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = Settings.default.secure_gravatar_url << "#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
