#!/usr/bin/env ruby -wKU

# Ensure that all of the examples start properly and respond to a request
# successfully
#
# This set of tests relies on certain Unix commands that will not be available
# on Windows.

require 'fileutils'
require 'net/http'
require 'tmpdir'

def wait_for_port(port, timeout_secs)
  timeout_secs.times do
    success = system("lsof -i:#{port} >/dev/null")
    return if success
    sleep 1
  end
  abort("Port #{port} was not in use after waiting for #{timeout_secs} seconds")
end

def with_server(rackup_config)
  pid_file = "#{Dir.tmpdir}/example.pid"
  port = 9292
  print "Starting server using #{rackup_config}..."
  success = system("rackup --daemonize --pid #{pid_file} #{rackup_config}")
  abort("Unable to start server using #{example}") unless success
  wait_for_port(port, 10)
  puts "OK"

  yield URI.parse("http://localhost:#{port}") if block_given?
ensure
  pid = File.read(pid_file)
  puts "Stopping pid #{pid}"
  system("kill -9 #{pid}")
end

def main
  examples = Dir["./examples/*.ru"]
  examples.each do |example|
    with_server(example) do |uri|
      http = Net::HTTP.new(uri.host, uri.port)
      http.request_get("/") do |rsp|
        puts ""
        puts "GET #{uri}/ => HTTP #{rsp.code}"
        rsp.each_header {|header| puts "#{header}: #{rsp[header]}" }
        puts rsp.body
        puts ""
        abort("Received non-HTTP 200 response from #{uri}") unless rsp.code == "200"
      end
    end
  end
end

main