json.array!(@objective_seminars) do |objective_seminar|
  json.extract! objective_seminar, :id
  json.url objective_seminar_url(objective_seminar, format: :json)
end
