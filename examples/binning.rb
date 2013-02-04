# -*- coding: utf-8 -*-

# The example from the README.

require 'quad_sphere/csc'

def geographic_to_storage_bin(latitude, longitude)
  # Convert both angles to radians.
  latitude = latitude*Math::PI/180
  longitude = longitude*Math::PI/180

  # Geographic latitudes are normally geodetic; we convert this to
  # geocentric because we want spherical coordinates.  The magic
  # number below is the Earth's eccentricity, squared, using the WGS84
  # ellipsoid.
  latitude = Math.atan((1 - 6.69437999014e-3) * Math.tan(latitude))

  # Apply the forward transformation...
  face, x, y = QuadSphere::CSC.forward(longitude, latitude)

  # ... then adjust x and y so they become integer coordinates on a
  # 100x100 grid, with 0,0 being top-left, as used in pictures.
  x = (100*(1+x)/2).floor
  y = 99 - (100*(1+y)/2).floor

  # And return the computed values.
  [ face, x, y ]
end

[ [ 'Accra',          5.5500,   -0.2167 ],
  [ 'Buenos Aires', -34.6036,  -58.3817 ],
  [ 'Cairo',         30.0566,  -31.2262 ],
  [ 'Honolulu',      21.3069, -157.8583 ],
  [ 'Kuala Lumpur',   3.1597,  101.7000 ],
  [ 'London',        51.5171,   -0.1062 ],
  [ 'Longyearbyen',  78.216667, 15.55   ],
  [ 'New Delhi',     28.6667,   77.2167 ],
  [ 'New York',      40.7142,  -74.0064 ],
  [ 'Quito',         -0.2186,  -78.5097 ],
  [ 'Sydney',       -33.8683,  151.2086 ],
  [ 'Ushuaia',      -54.8000,  -68.3000 ] ].each do |city, lat, lon|
  face, x, y = geographic_to_storage_bin(lat, lon)
  puts '%-12s - bitmap %d, x=%2d, y=%2d' % [city, face, x, y]
end
