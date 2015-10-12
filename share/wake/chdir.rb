def chdir(dir)
  current_dir = Dir.pwd
  Dir.chdir(dir)
  yield
ensure
  Dir.chdir(current_dir)
end
