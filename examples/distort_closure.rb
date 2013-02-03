# -*- coding: utf-8 -*-
# Compute the closure error introduced by the curvilinear distortion
# in QuadSphere::CSC.  This requires two additional gems: Joseph
# Ruscio's Aggregate, and Willem van Bergen's ChunkyPNG.

require 'quad_sphere/csc'
require 'aggregate'
require 'chunky_png'

# Some routines to manipulate colours. We should really pack this
# stuff in a gem one day...
module Colour

  # We expect an array of stops.  A gradient stop is an array of 4
  # elements: a min value, a max value, a start colour, and an end
  # colour.
  #
  # We expect the min of a stop to be always less than the max, and
  # we expect all stops to have a max equal or smaller than the min
  # of the next stop.  We expect all colours to be arrays of three
  # floats.
  #
  # We don't validate any of this; just expect breakage if you don't
  # conform.
  def self.gradient_map(stops, value, rgbout)
    stops.each do |min, max, start, finish|
      if value >= min && value <= max
        t = (value - min) / (max - min)
        lerp(t, start, finish, rgbout)
        return true
      end
    end

    # If we're here, v is out of range.  We'll just hardcode a
    # value.
    rgbout[0] = 1.0
    rgbout[1] = 0.0
    rgbout[2] = 0.0
    false
  end

  # Performs a linear interpolation between two colours.
  def self.lerp(t, rgb1, rgb2, rgbout)
    rgbout[0] = rgb1[0] + t*(rgb2[0] - rgb1[0])
    rgbout[1] = rgb1[1] + t*(rgb2[1] - rgb1[1])
    rgbout[2] = rgb1[2] + t*(rgb2[2] - rgb1[2])
  end

  # Converts as expected by chunkypng
  def self.rgb1_to_i(rgb)
    r = (rgb[0]*256).floor
    g = (rgb[1]*256).floor
    b = (rgb[2]*256).floor

    (r < 0 ? 0 : r > 255 ? 255 : r) << 24 |
      (g < 0 ? 0 : g > 255 ? 255 : g) << 16 |
        (b < 0 ? 0 : b > 255 ? 255 : b) << 8 | 0xff
  end
end # module Colour

# Size of the pretty pic. Computation time depends on the square of
# this, so keep it reasonable.
grid = 200

image = ChunkyPNG::Image.new(grid,grid)
stats = Aggregate.new

# The expected maximum error is just below 2.4e-4, so we'll set a B&W
# gradient white to that.
stops = [ [ 0.0, 2.4e-4, [0.0,0.0,0.0], [1.0,1.0,1.0] ] ]
rgb = Array.new(3)

# We're mapping the range -1.0 to 1.0, inclusive, to 0 to grid-1.
# Which is to say, if grid is 100, we want -1.0 at grid 0, and 1.0 at
# grid 1...
d = 2.0/(grid-1)

# Perform grid² transformations of χ,ψ to x,y and back to χ',ψ', and
# measuring the closure error.
grid.times do |row|
  grid.times do |col|
    chi = col*d - 1.0
    psi = row*d - 1.0
    x = QuadSphere::CSC.forward_distort(chi,psi)
    y = QuadSphere::CSC.forward_distort(psi,chi)
    chi1 = QuadSphere::CSC.inverse_distort(x,y)
    psi1 = QuadSphere::CSC.inverse_distort(y,x)
    error = Math::sqrt((chi1-chi)**2 + (psi1-psi)**2)

    # since we're dealing with very small errors, and Aggregate only
    # works with integers, we scale the error for it.
    stats << error*1e8

    Colour.gradient_map(stops, error, rgb)
    image[col,row] = Colour.rgb1_to_i(rgb)
  end
end

# Print statistics:
puts("samples: %d mean: %8g min: %8g max: %8g std_dev: %8g" %
     [ stats.count,
       stats.mean/1e8, stats.min/1e8, stats.max/1e8, stats.std_dev/1e8 ])

# Print histogram:
puts stats.to_s

# Write the pretty pic:
image.save('distort-error.png')
