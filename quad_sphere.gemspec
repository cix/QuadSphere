# -*- coding: utf-8; mode: ruby -*-

Gem::Specification.new do |s|
  s.name        = 'quad_sphere'
  s.version     = '0.9.1'
  s.date        = '2013-02-02'
  s.summary     = 'Quadrilateralized spherical cube projection'
  s.description = <<-END
    This is an implementation of the quadrilateralized spherical cube
    projection, an approximately equal-area projection of the sphere
    onto the faces of a cube.  It is useful for storage of data
    collected on a spherical surface, and for general mapmaking.
  END
  s.author      = 'Cesar Rincon'
  s.email       = 'crincon@gmail.com'
  s.files       = [ 'lib/quad_sphere.rb',
                    'lib/quad_sphere/tangential.rb',
                    'lib/quad_sphere/csc.rb' ]
  s.homepage    = 'https://github.com/crinc/QuadSphere'
end
