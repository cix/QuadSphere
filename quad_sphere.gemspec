# -*- coding: utf-8; mode: ruby -*-

Gem::Specification.new do |s|
  s.name        = 'quad_sphere'
  s.version     = '1.0.0'
  s.date        = '2013-02-04'
  s.summary     = 'Quadrilateralised spherical cube projection'
  s.description = <<END
An implementation of the quadrilateralised spherical cube, an
approximately equal-area projection of the sphere onto the faces of a
cube. It is useful for storing data collected on a spherical surface,
and for general mapmaking.
END
  s.homepage    = 'https://github.com/crinc/QuadSphere'
  s.author      = 'Cesar Rincon'
  s.email       = 'crincon@gmail.com'
  s.files       = [ 'README.md',
                    'COPYING',
                    'quad_sphere.gemspec',
                    'examples/binning.rb',
                    'examples/distort_closure.rb',
                    'examples/gl1.rb',
                    'examples/gl2.rb',
                    'examples/grid.rb',
                    'lib/quad_sphere.rb',
                    'lib/quad_sphere/tangential.rb',
                    'lib/quad_sphere/csc.rb',
                    'lib/quad_sphere/version.rb' ]
  s.test_files  = [ 'test/test_quad_sphere.rb' ]
end
