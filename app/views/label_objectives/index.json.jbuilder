json.array!(@label_objectives) do |label_objective|
  json.extract! label_objective, :id
  json.url label_objective_url(label_objective, format: :json)
end
