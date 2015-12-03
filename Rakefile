code_files = FileList["**/*.rb"]
code_files.include("**/*.erb")
code_files.include("**/*.json")
code_files.include("**/Dockerfile*")

task :crlf do
  code_files.each do |file|
    new_file = File.read(file, universal_newline: true).lines.map { |line| line.delete("\r") }.join
    File.open(file, mode: "w", universal_newline: true) { |f| f << new_file }
  end
end

begin
  require 'rubocop/rake_task'
  
  desc 'Run RuboCop'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.patterns = ['**/*.rb']
    task.formatters = ['files']
    task.fail_on_error = false
  end
rescue
  $stderr.puts "gem install rubocop to have access to those rake tasks"
end