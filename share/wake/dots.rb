def dots(timer: 1.5)
  t = Thread.new do
    loop do
      $stderr.print "."
      $stderr.flush
      sleep timer
    end
  end

  result = yield

  t.exit

  $stderr.print "\n"
  $stderr.flush

  result
end
