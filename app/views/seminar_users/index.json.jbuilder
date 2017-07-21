json.array!(@seminar_users) do |seminar_user|
  json.extract! seminar_user, :id
  json.url seminar_user_url(seminar_user, format: :json)
end
