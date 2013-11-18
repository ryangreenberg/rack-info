# Rack::Metadata

Rack::Metadata is a Rack middleware that can be used to expose properties about your application or environment as part of every request. You can use it to expose information like the current version of the application or which host served the request.

Metadata can be added as X- headers, output

## Installation

```
gem install rack-metadata
```

## Usage

For the simple case where you want to add the same values as headers to every request, provide Rack::Metadata with a hash of key/value pairs:

```
require 'rack'
require 'rack/lobster'
require 'rack/metadata'

use Rack::Metadata, {:git => `git rev-parse HEAD`, :host => Socket.gethostname}
run Rack::Lobster.new
```

For more complex usage, use a Rack::Metadata::Config object:

```
use(Rack::Metadata, Rack::Metadata::Config.new do |config|
  # Set any desired options; see Configuration below
  config.availability = lambda {|env| [true, false].sample }
  config.endpoint = "/version"
end)
```

## Configuration

Rack::Metadata can be configured in the following ways.

## Development

git clone ...
bundle install
rspec