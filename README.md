# Rack::Metadata

`Rack::Metadata` is a Rack middleware that can be used to add information about your application or environment to requests. You can use it to expose information like the current version of the application or which host served the request.

Metadata can be added as X-headers, output as HTML, or served from a dedicated endpoint.

## Installation

```
gem install rack-metadata
```

## Usage

For the simple case where you want to add the same values as headers to every request, provide `Rack::Metadata` with a hash of key/value pairs:

```
require 'rack'
require 'rack/metadata'

use Rack::Metadata, {:git => `git rev-parse HEAD`.strip, :host => Socket.gethostname}
run lambda {|env| [200, {"Content-Type" => "text/plain"}, ["OK"]] }
```

For more complex usage, use a `Rack::Metadata::Config` object:

```
use(Rack::Metadata, Rack::Metadata::Config.new do |config|
  # Set any desired options; see Configuration below
  config.is_enabled = lambda {|env| [true, false].sample }
  config.path = "/version"
end)
```

## Configuration

Configuration is done via an instance of `Rack::Metadata::Config`. You can create a configuration by providing a block to the constructor, or by setting values directly on a new instance:

```
Rack::Metadata::Config.new do |config|
  config.add_html = false
end

config = Rack::Metadata::Config.new
config.add_html = false
```

The following options can be set on an config object:

- `metadata`: a hash of key/value pairs that will be added as X- headers,
HTML content, or exposed directly at a JSON endpoint, depending on the
other configuration. (default: `{}`)
- `is_enabled`: whether or not this middleware will add any metadata to the response. It can be a boolean value, or an object that responds to .call with a boolean value. The Rack request environment is provided to a callable object. This can be useful for adding data only to requests from a certain IP block, for example. (default: `true`)
- `add_headers`: whether or not metadata will be added to this request as X-headers. It can be a boolean value, or an object that responds to .call with a boolean value. The Rack request environment _and_ current Rack response tuple are provided to a callable object. (default: `true`)
- `add_html`: whether or not metadata will be added to this request as HTML. It can be a boolean value, or an object that responds to .call with a boolean value. The Rack request environment *and* current Rack response tuple are provided to a callable object. Note: content is only added to responses with a content-type header of text/html. (default: `true`)
- `insert_html_after`: the HTML tag after which the HTML metadata will be added. (default: `</body>`)
- `html_formatter`: object that converts metadata pairs to an HTML string. See `HTMLComment` and `HTMLMetaTag` for examples. (default: `HTMLComment`)
- `path`: an endpoint at which metadata will be returned as a JSON string. Set to nil to disable. (default: `nil`)

## Examples

You can find examples of different configurations in `examples`.

## Development

To make changes to rack-metadata:

1. Clone this repository
2. `bundle install`
3. Run tests with `rspec`
