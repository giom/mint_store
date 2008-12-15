# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mint_store}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Guillaume Maury"]
  s.date = %q{2008-12-16}
  s.description = %q{Mint store for merb-cache based on http://blog.disqus.net/2008/06/11/mintcache-simple-version/}
  s.email = %q{dev@gom-jabbar.org}
  s.extra_rdoc_files = ["README.md", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README.md", "Rakefile", "TODO", "lib/mint_store", "lib/mint_store/mint_store.rb", "lib/mint_store.rb", "spec/helpers", "spec/helpers/abstract_store.rb", "spec/helpers/abstract_strategy_store.rb", "spec/mint_store_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://gom-jabbar.org/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{merb}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Mint store for merb-cache based on http://blog.disqus.net/2008/06/11/mintcache-simple-version/}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<merb-cache>, [">= 1.0"])
    else
      s.add_dependency(%q<merb-cache>, [">= 1.0"])
    end
  else
    s.add_dependency(%q<merb-cache>, [">= 1.0"])
  end
end
