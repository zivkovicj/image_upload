json.array!(@users) do |user|
  json.extract! user, :id, :first_name, :last_name, :email, :current_class, :password_digest, :remember_digest, :role, :activation_digest, :activated, :activated_at, :reset_digest, :reset_sent_at, :title, :last_login, :username
  json.url user_url(user, format: :json)
end
