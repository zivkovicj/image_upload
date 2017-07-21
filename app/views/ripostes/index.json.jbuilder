json.array!(@ripostes) do |riposte|
  json.extract! riposte, :id
  json.url riposte_url(riposte, format: :json)
end
