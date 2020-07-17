# fluent-plugin-gelf-transformer

[Fluentd](https://fluentd.org/) filter plugin to transform parsed apache format to gelf format.

## Installation

### RubyGems

```
$ gem install fluent-plugin-gelf-transformer
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-gelf-transformer"
```

And then execute:

```
$ bundle
```

## Configuration

You can generate configuration template:

```
$ fluent-plugin-config-format filter gelf-transformer
```

### Caution!
**The records which are input for gelf-plugin have to include `origin_log` , `host` field.**

## Copyright

* Copyright(c) 2020-SeongpyoHong
* License
  * Apache License, Version 2.0
