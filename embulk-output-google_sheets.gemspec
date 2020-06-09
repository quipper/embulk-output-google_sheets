
Gem::Specification.new do |spec|
  spec.name          = "embulk-output-google_sheets"
  spec.version       = "0.1.0"
  spec.authors       = ["shase"]
  spec.summary       = "Google Sheets output plugin for Embulk"
  spec.description   = "Dumps records to Google Sheets."
  spec.email         = ["shase428@gmail.com"]
  spec.licenses      = ["MIT"]
  # TODO set this: spec.homepage      = "https://github.com/shase428/embulk-output-google_sheets"

  spec.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  #spec.add_dependency 'YOUR_GEM_DEPENDENCY', ['~> YOUR_GEM_DEPENDENCY_VERSION']
  spec.add_development_dependency 'embulk', ['>= 0.8.39']
  spec.add_development_dependency 'bundler', ['>= 2.1.4']
  spec.add_development_dependency 'rake', ['>= 13.0.1']

  spec.add_dependency 'google-api-client', ['>= 0.32.1']
end
