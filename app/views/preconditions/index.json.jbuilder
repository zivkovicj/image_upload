json.array!(@preconditions) do |precondition|
  json.extract! precondition, :id
  json.url precondition_url(precondition, format: :json)
end
