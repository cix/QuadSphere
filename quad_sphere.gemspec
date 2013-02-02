# -*- coding: utf-8; mode: ruby -*-

Gem::Specification.new do |s|
  s.name        = 'quad_sphere'
  s.version     = '1.0.0'
  s.date        = '2013-01-31'
  s.summary     = 'Quadrilateralized spherical cube projection'
  s.description = <<-END
    This is an implementation of the quadrilateralized spherical cube
    projection, an approximately equal-area projection (to within a
    few percent) in which a sphere is projected onto an inscribed
    cube.
  END
  s.author      = 'Cesar Rincon'
  s.email       = 'crincon@gmail.com'
  s.files       = [ 'lib/quad_sphere.rb',
                    'lib/quad_sphere/tangential.rb',
                    'lib/quad_sphere/cobe.rb' ]
  s.homepage    = 'http://rubygems.org/gems/quad_sphere'
end
