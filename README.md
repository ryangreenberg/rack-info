# Rack::Info

`Rack::Info` is a Rack middleware that can be used to add information about your application or environment to requests. You can use it to expose data like the current version of the application or which host served the request.

This information can be added as X-headers, output as HTML, or served from a dedicated endpoint.

## Installation

```
gem install rack-info
```

## Usage

For the simple case where you want to add the same values as headers to every request, provide `Rack::Info` with a hash of key/value pairs.

Here's an example from `examples/basic_example.ru`:
```
require 'rack/info'
require 'socket'

use Rack::Head
use Rack::Info, {:git => `git rev-parse HEAD`.strip, :host => Socket.gethostname}
run lambda {|env| [200, {"Content-Type" => "text/plain"}, ["OK"]] }
```

After you start a server by running `rackup config/basic_example.ru`, you can see the headers are added to your request:

```
$ curl -I http://localhost:9292
HTTP/1.1 200 OK
X-Git: 3e534f6302eca4e8f94456efa09523b49b1c41c7
X-Host: Ollantaytambo.local
Transfer-Encoding: chunked
Connection: close
```

For more complex cases, use a `Rack::Info::Config` object:

```
use(Rack::Info, Rack::Info::Config.new do |config|
  # Set any desired options; see Configuration below
  config.data = {:git => `git rev-parse HEAD`.strip, :host => Socket.gethostname}
  config.is_enabled = lambda {|env| [true, false].sample }
  config.path = "/version"
end)
```

## Configuration

Configuration is done via an instance of `Rack::Info::Config`. You can create a configuration by providing a block to the constructor, or by setting values directly on a new instance:

```
Rack::Info::Config.new do |config|
  config.add_html = false
end

config = Rack::Info::Config.new
config.add_html = false
```

The following options can be set on an config object:

- `data`: a hash of key/value pairs that will be added as X-headers, HTML content, or exposed directly at a JSON endpoint, depending on the other configuration. (default: `{}`)
- `is_enabled`: whether or not this middleware will add any data to the response. It can be a boolean value, or an object that responds to .call with a boolean value. The Rack request environment is provided to a callable object. This can be useful for adding data only to requests from a certain IP block, for example. (default: `true`)
- `add_headers`: whether or not data will be added to this request as X-headers. It can be a boolean value, or an object that responds to .call with a boolean value. The Rack request environment _and_ current Rack response tuple are provided to a callable object. (default: `true`)
- `add_html`: whether or not data will be added to this request as HTML. It can be a boolean value, or an object that responds to .call with a boolean value. The Rack request environment *and* current Rack response tuple are provided to a callable object. Note: content is only added to responses with a content-type header of text/html. (default: `true`)
- `insert_html_after`: the HTML tag after which the HTML data will be added. (default: `</body>`)
- `html_formatter`: object that converts data to an HTML string. See `HTMLComment` and `HTMLMetaTag` for examples. (default: `HTMLComment`)
- `path`: an endpoint at which data will be returned as a JSON string. Set to nil to disable. (default: `nil`)

## Examples

You can find examples of different configurations in `examples`.

## Development

To make changes to rack-info:

1. Clone this repository
2. `bundle install`
3. Run tests with `rspec`
