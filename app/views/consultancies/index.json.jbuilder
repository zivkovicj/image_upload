json.array!(@consultancies) do |consultancy|
  json.extract! consultancy, :id
  json.url consultancy_url(consultancy, format: :json)
end
