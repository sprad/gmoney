require 'rubygems'
require 'rake'
require 'echoe'
require 'spec/rake/spectask'
require 'lib/gmoney'

task :default => :spec

desc "Run the gmoney specs"
task :spec do
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec']
    t.spec_opts = ['--options', "spec/spec.opts"]
  end
end

desc "Gemify GMoney"
  namespace :gemify do
  Echoe.new('gmoney', GMoney.version) do |p|
    p.description = "A gem for interacting with the Google Finance API"
    p.url = "http://www.justinspradlin.com/programming/introducing-gmoney-a-rubygem-for-interacting-with-the-google-finance-api/"
    p.author = "Justin Spradlin"
    p.email = "jspradlin@gmail.com"
    p.ignore_pattern = ["coverage/*", "*~"]
    p.development_dependencies = []
  end
end
