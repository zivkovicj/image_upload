json.array!(@labels) do |label|
  json.extract! label, :id, :name, :extent, :user_id
  json.url label_url(label, format: :json)
end
