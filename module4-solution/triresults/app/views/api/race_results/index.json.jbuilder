json.ignore_nil!
json.array!(@entrants) do |entrant|
  json.partial! "result", result: entrant
end