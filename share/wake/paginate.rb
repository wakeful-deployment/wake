def paginate(initial:, next:)
  output = []

  result = initial.call
  output.concat(result.body.value) if result.body

  while result = next.call(result)
    output.concat(result.body.value) if result.body
  end

  output
end
