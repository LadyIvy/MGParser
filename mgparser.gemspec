# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lib/version"

Gem::Specification.new do |s|
  s.name = "mgparser"
  s.version = VERSION::STRING

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dawid Pogorzelski"]

  s.date = Date.today.to_s
  s.description = "MGParser (MGP) is a tool which makes analysis of Mediatrix ISDN gateways debug a much simpler task."
  s.email = "dawid.pogorzelski@mybushido.com"
  s.executables = ["mgparser"]

  s.files = %w{
    README.markdown
    mgparser
    mgparser.gemspec
    lib/version.rb
    LICENSE
    Gemfile
  }

  s.has_rdoc = true
  s.homepage = "https://github.com/dawid999/adhearsion-cw"
  s.require_paths = ["lib"]
  s.rubyforge_project = "adhearsion"
  s.rubygems_version = "1.2.0"
  s.summary = "Adhearsion-cw, open-source telephony development framework. This is a fork from the original Adhearsion project http://adhearsion.com"

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      # Runtime dependencies
      s.add_runtime_dependency("bundler", [">= 1.0.10"])
      s.add_runtime_dependency("log4r", [">= 1.0.5"])
      s.add_runtime_dependency("activesupport", [">= 2.1.0"])
      s.add_runtime_dependency("rake")
      # i18n is only strictly a dependency for ActiveSupport >= 3.0.0
      # Since it doesn't conflict with <3.0.0 we'll require it to be
      # on the safe side.
      s.add_runtime_dependency("i18n")
      s.add_runtime_dependency("rubigen", [">= 1.5.6"])

      # Development dependencies
      s.add_development_dependency('rubigen', [">= 1.5.6"])
      s.add_development_dependency('rspec', [">= 2.4.0"])
      s.add_development_dependency('flexmock')
      s.add_development_dependency('activerecord')
    else
      s.add_dependency("bundler", [">= 1.0.10"])
      s.add_dependency("log4r", [">= 1.0.5"])
      s.add_dependency("activesupport", [">= 2.1.0"])
      s.add_dependency("rake")
    end
  else
    s.add_dependency("bundler", [">= 1.0.10"])
    s.add_dependency("log4r", [">= 1.0.5"])
    s.add_dependency("activesupport", [">= 2.1.0"])
    s.add_dependency("rake")
  end
end
