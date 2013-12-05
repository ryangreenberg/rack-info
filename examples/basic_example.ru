$:.unshift(File.expand_path('../../lib', __FILE__))
require 'rack/info'
require 'socket'

use Rack::Head
use Rack::Info, {:git => `git rev-parse HEAD`.strip, :host => Socket.gethostname}
run lambda {|env| [200, {"Content-Type" => "text/plain"}, ["OK"]] }
