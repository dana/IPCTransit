Gem::Specification.new do |s|
  s.name               = 'ipc_transit'
  s.version            = '0.0.2'
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'SysVIPC'
  s.executables        << 'trrecv'
  s.executables        << 'trsend'
  s.executables        << 'trlist'
  s.executables        << 'transitd'
  s.executables        << 'trserver'

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.authors = ['Dana M. Diederich']
  s.date = %q{2012-11-17}
  s.description = %q{Brokerless Message Queue}
  s.email = %q{diederich@gmail.com}
  s.files = ['Rakefile', 'lib/ipc_transit.rb', 'lib/ipc_transit/test.rb', 'bin/trrecv', 'bin/trsend', 'bin/trlist','bin/transitd','bin/trserver']
  s.test_files = ['test/tc_transit_simple.rb','test/tc_transit_remote.rb']
  s.homepage = %q{http://rubygems.org/gems/ipc_transit}
  s.require_paths = ['lib']
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Brokerless, cross-language, fast message queue library}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

