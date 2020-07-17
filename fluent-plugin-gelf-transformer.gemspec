lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-gelf-transformer"
  spec.version = "0.1.0"
  spec.authors = ["Seongpyo Hong"]
  spec.email   = ["sphong0417@gmail.com"]

  spec.summary       = %q{Filter Plugin to Transform Parsed Apache Format to GELF Format}
  spec.description   = %q{Filter Plugin to Transform Parsed Apache Format to GELF Format[Full]} 
  spec.homepage      = "https://github.com/seongpyoHong/fluentd-apache-gelf-kafka-plugins/tree/master/fluent-plugin-gelf-transformer"
  spec.license       = "Apache-2.0"

  ### Version Control
  # test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
  #   f.match(%r{^(test|spec|features)/})
  # end
  
  spec.files         = ["lib/fluent/plugin/filter_gelf_transformer.rb"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = ["test/plugin/test_filter_gelf_transformer.rb"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
end
