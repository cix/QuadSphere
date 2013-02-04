# -*- coding: utf-8 -*-

require 'quad_sphere/csc'
require 'chunky_png'

# Not the best way to draw a grid — we repaint a lot of pixels.  But
# it's compact and hopefully clear.

# The size of each cube face, and some colours:
size = 99
colour = ChunkyPNG::Color.html_color(:grey)
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

# The longest distance on a cube face is the diagonal, which is of
# length d=size*√2. This is an angle of π/2 on the sphere. We split
# π/2 over d to get a small angle Δ that, along the diagonal, would
# map to pixels at unit distance from each other, and we use Δ as
# "angular resolution" everywhere, because this will keep our lines
# continuous.  This is wasteful: Δ could be larger everywhere else; we
# repaint a lot of pixels.  But hey, tis just an example.
delta = Math::PI/(2*size*Math::sqrt(2))

# And this is a lambda to paint a point by latitude and longitude.
# We'll do this a lot.
plot = lambda do |lon,lat|
  face, x, y = QuadSphere::CSC.forward(lon, lat)
  x = (size*(x+1)/2).floor
  y = (size*(y+1)/2).floor
  offx, offy = faces[face]
  image[x+offx,y+offy] = colour
end

# To work.  Draw a rectangle around each face.
faces.each_pair do |face, offsets|
  off_x, off_y = offsets
  image.rect(off_x, off_y, off_x+size, off_y+size, face_border, background)
end

# Draw the meridians.
36.times do |meridian|
  lon = meridian*Math::PI/18
  (-Math::PI/2).step(Math::PI/2, delta) do |lat|
    plot.call(lon,lat)
  end
end

# Draw the parallels.
18.times do |parallel|
  lat = -Math::PI/2 + parallel*Math::PI/18
  (-Math::PI).step(Math::PI, delta) do |lon|
    plot.call(lon,lat)
  end
end

# There done, save our masterpiece.
image.save('grid.png', :best_compression)
