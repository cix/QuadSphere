# -*- coding: utf-8 -*-

# Please mind: in this documentation, and in the code comments, we use
# φ (phi) to denote longitude, or azimuthal angle, and θ (theta) for
# latitude, or elevation.  This is the convention commonly used in
# physics.  We apologise to all mathheads out there for any
# inconvenience this may cause.
module QuadSphere

  # The identifier of the cube face whose centre maps to θ=π/2
  # (90°N, the North Pole).
  TOP_FACE    = 0

  # The identifier of the cube face whose centre maps to φ=0, θ=0
  # (0° 0°, think Ghana).
  FRONT_FACE  = 1

  # The identifier of the cube face whose centre maps to φ=π/2, θ=0
  # (0° 90°E, think India).
  EAST_FACE   = 2

  # The identifier of the cube face whose centre maps to φ=π, θ=0
  # (0° 180°, think Fiji).
  BACK_FACE   = 3

  # The identifier of the cube face whose centre maps to φ=-π/2, θ=0
  # (0° 90°W, think Central America).
  WEST_FACE  = 4

  # The identifier of the cube face whose centre maps to θ=-π/2
  # (90°S, the South Pole).
  BOTTOM_FACE = 5

end
