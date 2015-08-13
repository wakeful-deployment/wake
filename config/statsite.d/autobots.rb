#!/usr/bin/env ruby
# encoding: utf-8

require 'json'

TYPES = {
  1 => 'kv',
  2 => 'counter',
  3 => 'timer'
}

VTYPES = {
  0 => 'kv',
  1 => 'sum',
  2 => 'sumsqrt',
  3 => 'mean',
  4 => 'count',
  5 => 'stddev',
  6 => 'min',
  7 => 'max',
  128 => 'percentile'
}

$debug = false

# Calculate percentiles
(1..100).each { |n| VTYPES[128|n] = "P%02d" % n }

# An iterator over a statsite binary stream
# Yields: key, metric type, value, value type, timestamp
def rawdata_iter(fh)
  # timestamp | type  | value type | key length | value  | key
  # ----------+-------+------------+------------+--------+-----
  #   uint64  | uint8 |   uint8    |   uint16   | double |
  Enumerator.new do |enum|
    while true
      prefix = fh.read(20)
      break if prefix.nil? || prefix.length != 20
      ts, type, vtype, key_len, val = prefix.unpack('QCCSD')
      key = fh.read(key_len).chop().force_encoding('utf-8')

      enum.yield key, type, val, vtype, ts
    end
  end
end


def collect(source)
  data = []
  source.each do |key, type, val, vtype, ts|
    type = TYPES[type]
    vtype = VTYPES[vtype]
    # puts "read: #{ts}: #{key}|#{type} #{val}|#{vtype}"
    data << {
      'key' => key,
      vtype => val,
      'timestamp' => ts,
      'type' => type
    }
  end
  data.group_by{ |e| e["key"] }.values.map{ |a| a.inject(&:merge) }
end

def main
  data = collect(rawdata_iter($stdin.binmode()))
  puts JSON.dump(data) if ENV['DEBUG']
  return if data.empty?

  if bot = ENV["AUTOBOT"]
    puts `echo '#{JSON.dump(data)}' | #{bot}`
  elsif autobots_url = ENV["AUTOBOTS_URL"]
    `curl -s -X POST -d '#{JSON.dump(data)}' #{autobots_url}`
  else
    puts JSON.pretty_generate(data)
  end
end


main() if __FILE__ == $0
