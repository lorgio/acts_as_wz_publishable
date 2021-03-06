# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{acts_as_wz_publishable}
  s.version = "0.1.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Lorgio Jimenez"]
  s.date = %q{2010-12-10}
  s.description = %q{add publishing workflow to models}
  s.email = %q{lorgio.jimenez@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".DS_Store",
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/active_record/acts/wz_publishable.rb",
    "lib/acts_as_wz_publishable.rb",
    "test/abstract_unit.rb",
    "test/database.yml",
    "test/debug.log",
    "test/fixtures/page.rb",
    "test/fixtures/page_soft_delete.rb",
    "test/fixtures/page_soft_deletes.yml",
    "test/fixtures/pages.yml",
    "test/helper.rb",
    "test/pages_test.rb",
    "test/schema.rb",
    "test/test_acts_as_wz_publishable.rb"
  ]
  s.homepage = %q{http://github.com/lorgio/acts_as_wz_publishable}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{acts as wz publishable}
  s.test_files = [
    "test/abstract_unit.rb",
    "test/fixtures/page.rb",
    "test/fixtures/page_soft_delete.rb",
    "test/helper.rb",
    "test/pages_test.rb",
    "test/schema.rb",
    "test/test_acts_as_wz_publishable.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<aasm>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_runtime_dependency(%q<aasm>, [">= 0"])
    else
      s.add_dependency(%q<aasm>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<aasm>, [">= 0"])
    end
  else
    s.add_dependency(%q<aasm>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<aasm>, [">= 0"])
  end
end

