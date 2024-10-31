module UsersHelper
  # Returns the Gravatar for the given user.
  def gravatar_for(user, size: 80)
    gravatar_id  = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = Settings.default.secure_gravatar_url << "#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
