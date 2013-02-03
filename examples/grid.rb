# -*- coding: utf-8 -*-

require 'quad_sphere/csc'
require 'chunky_png'

# This is certainly not the best way to draw a grid, mind you, but
# it's a very compact one.

# The size of each cube face, and some colours:
size = 99
colour = ChunkyPNG::Color.html_color(:mediumvioletred)
background = ChunkyPNG::Color::WHITE
face_border = ChunkyPNG::Color::BLACK

# This is where we'll place each face, the usual cross.
faces = {
  QuadSphere::TOP_FACE    => [ 2*size,      0 ],
  QuadSphere::BACK_FACE   => [      0,   size ],
  QuadSphere::WEST_FACE   => [   size,   size ],
  QuadSphere::FRONT_FACE  => [ 2*size,   size ],
  QuadSphere::EAST_FACE   => [ 3*size,   size ],
  QuadSphere::BOTTOM_FACE => [ 2*size, 2*size ]
}

image = ChunkyPNG::Image.new(4*size+1, 3*size+1, ChunkyPNG::Color::TRANSPARENT)

# QuadSphere::CSC.inverse takes coordinates from -1 to 1. So we'll
# use this factor for scale:
f = 2.0/size

# To work.  For each face...
faces.each_pair do |face, offsets|
  off_x, off_y = offsets
  # ... draw a rectangle around it...
  image.rect(off_x, off_y, off_x+size, off_y+size, face_border, background)
  # ... then for each pixel in the face...
  size.times do |y|
    size.times do |x|
      # ... compute its latitude and longitude in degrees...
      lon, lat = QuadSphere::CSC.inverse(face, x*f - 1, y*f - 1).collect\
        { |angle| (angle*180/Math::PI).round }
      # ... and when either is an multiple of 10°, paint the pixel.
      image[x+off_x,y+off_y] = colour if lon % 10 == 0 || lat % 10 == 0
    end
  end
end

# There done, save our masterpiece.
image.save('grid.png', :best_compression)
