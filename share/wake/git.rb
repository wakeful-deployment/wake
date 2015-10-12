module Git
  module_function

  def with_checkout(rev)
    run! "git checkout #{rev}"
    yield
  ensure
    run! "git checkout -"
  end
end
