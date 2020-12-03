require_relative "lib/csproj/version"

Gem::Specification.new do |spec|
  spec.name = "csproj"
  spec.version = CsProj::VERSION
  spec.authors = ["Jake Barnby"]
  spec.email = ["jakeb994@gmail.com"]

  spec.summary = "Load and manipulate C# solutions and projects"
  spec.description = "Load and manipulate C# solutions and projects"
  spec.homepage = "https://github.com/abnegate/ruby-csproj"
  spec.license = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/abnegate/ruby-csproj"
  spec.metadata["changelog_uri"] = "https://github.com/abnegate/ruby-csproj/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*"] + %w[README.md LICENSE]
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.add_dependency "nokogiri", "~> 1.7"
end
