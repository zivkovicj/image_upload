json.array!(@objective_users) do |objective_user|
  json.extract! objective_user, :id
  json.url objective_user_url(objective_user, format: :json)
end
