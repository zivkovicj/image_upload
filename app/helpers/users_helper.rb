module UsersHelper

  # Returns the Gravatar for the given user.
  def gravatar_for(user, options = { size: 80 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.last_name, class: "gravatar")
  end
  
  def verify_waiting_teachers_message
    "IMPORTANT: Some teachers are your school are waiting to be verified. Since you are the mentor for #{@school.name}, will you please take a moment to verify the other teachers."
  end
end