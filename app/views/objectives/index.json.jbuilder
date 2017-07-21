json.array!(@objectives) do |objective|
  json.extract! objective, :id
  json.url objective_url(objective, format: :json)
end
