# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{acts_as_spammable}
  s.version = "2.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mostafa Ali"]
  s.autorequire = %q{acts_as_spammable}
  s.date = %q{2011-04-18}
  s.description = %q{Plugin/gem that provides spamming functionality}
  s.email = %q{unknown@juixe.com}
  s.extra_rdoc_files = ["README", "MIT-LICENSE"]
  s.files = ["MIT-LICENSE", "README", "generators/comment", "generators/spammable/spammable_generator.rb", "generators/spammable/templates", "generators/spammable/templates/spammable.rb"]
  s.has_rdoc = false
  s.homepage = %q{http://www.juixe.com/techknow/index.php/2006/06/18/acts-as-commentable-plugin/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Plugin/gem that provides spamming functionality}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
