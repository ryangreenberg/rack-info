$:.unshift(File.expand_path('../../lib', __FILE__))
require 'rack/metadata'
require 'socket'

use Rack::Head
use Rack::Metadata, {:git => `git rev-parse HEAD`.strip, :host => Socket.gethostname}
run lambda {|env| [200, {}, ["OK"]] }
