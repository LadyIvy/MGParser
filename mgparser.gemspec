# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "version"

Gem::Specification.new do |s|
  s.name = "mgparser"
  s.version = Mgparser::VERSION::STRING

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dawid Pogorzelski"]

  s.date = Date.today.to_s
  s.description = "MGParser (MGP) is a tool which makes analysis of Mediatrix ISDN gateways debug a much simpler task"
  s.email = "dawid.pogorzelski@mybushido.com"
  s.executables = ["mgparser"]

  s.files = %w{
    README.markdown
    bin/mgparser
    mgparser.gemspec
    lib/version.rb
    lib/call.rb
    lib/optparser.rb
    lib/snmp_gw.rb
    LICENSE
    Gemfile
  }

  s.homepage = "https://github.com/dawid999/MGParser"
  s.require_paths = ["lib"]
  s.summary = "Mediatrix ISDN gateways debug utility"

  # Runtime dependencies
  s.add_runtime_dependency("bundler", [">= 1.0.10"])
  s.add_runtime_dependency("eventmachine")
  s.add_runtime_dependency("snmp")
end
