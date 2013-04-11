# motion.h

Include iOS system libraries in RubyMotion.

Outside of the usual Apple frameworks, iOS includes many system C libraries,
with the most well known examples being [SQLite](http://www.sqlite.org/), and
[Libxml2](http://www.xmlsoft.org/). RubyMotion provides the ability to directly
call into C libraries through a mechanism called BridgeSupport, which takes us
to the point in the story where `motion.h` is introduced. In order to use
BridgeSupport, the compiler must be fed an XML file that describes a library's
C API, and this is what `motion.h` takes care of. Simply declare the header
files needed, just like in C, and now RubyMotion code can call directly into
the specified system library, without having to write an Objective-C wrapper.

## Installation

Add this line to your application's Gemfile:

    gem 'motion.h'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install motion.h

## Examples

In your `Rakefile`:

### SQLite

```ruby
Motion::Project::App.setup do |config|
  config.libs << '/usr/lib/libsqlite3.dylib'
  config.include 'sqlite3.h'
end
```

### Objective-C Runtime

```ruby
Motion::Project::App.setup do |config|
  config.include 'objc/runtime.h'
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
