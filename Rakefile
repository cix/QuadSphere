# -*- coding: utf-8; mode: ruby -*-

require 'rake/testtask'
require 'yard'

task :default => :test

desc "Run tests"
Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Generate docs"
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']   # optional
end
