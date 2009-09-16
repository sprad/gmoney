require 'rubygems'
require 'rake'
require 'echoe'
require 'spec/rake/spectask'

task :default => :specs

desc "Run the gmoney specs"
task :specs do
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec']
    t.spec_opts = ['--options', "spec/spec.opts"]
  end
end

Echoe.new('gmoney', '0.0.2') do |p|
  p.description = "A gem for interacting with the Google Finance API"
  p.url = "http://github.com/jspradlin/gmoney"
  p.author = "Justin Spradlin"
  p.email = "jspradlin@gmail.com"
  p.ignore_pattern = ["coverage/*", "*~"]
  p.development_dependencies = []
end
