# -*- coding: utf-8 -*-

require 'test/unit'
require 'quad_sphere'
require 'quad_sphere/tangential'
require 'quad_sphere/csc'

module MappingTests
  # Some constants to save typing (not that I typed all this heh)
  PI = Math::PI

  TOP_FACE = QuadSphere::TOP_FACE
  FRONT_FACE = QuadSphere::FRONT_FACE
  EAST_FACE = QuadSphere::EAST_FACE
  BACK_FACE = QuadSphere::BACK_FACE
  WEST_FACE = QuadSphere::WEST_FACE
  BOTTOM_FACE = QuadSphere::BOTTOM_FACE

  # This is the floating point round-off error expected to be
  # introduced by our computations.  Most of our tangential
  # projections are exact to the unit roundoff given by Ruby,
  # actually. It's only a couple that are above one epsilon.  But in
  # any case, just take from this the tangential projection is
  # accurate to 15 digits...
  #
  # Float::EPSILON = 2.220446049250313e-16 on my MacBook, ruby
  # 1.9.3p374 (2013-01-15 revision 38858) [x86_64-darwin11.4.2]
  DELTA = 2*Float::EPSILON

  # This is a small value we use to test rollover to the neighbouring
  # face, in the forward projection.
  NUDGE = Float::EPSILON

  # Picture a sphere of unit radius inscribed in a cube, with the
  # centre of the sphere at the origin of the cartesian space, and
  # with the cube oriented so that each coordinate axis passes through
  # the centres of two opposite cube faces.
  #
  # The sides of this cube are then of length 2 (twice the sphere's
  # radius), thus the diagonal of the cube is of length 2*sqrt(3).  It
  # follows that, at each corner of the cube, the distance from the
  # corner vertex to the horizontal plane is 1 (half the length of a
  # cube side), and the distance from the vertex to the origin is
  # sqrt(3) (half the length of the cube diagonal).  It further
  # follows that the sine of the elevation angle to the corners of the
  # cube is 1/sqrt(3).
  #
  # So the four northern corners of the cube are at latitude
  # θc = arcsin(1/sqrt(3)); and the southern corners at latitude -θc.
  #
  # I don't know is there is a way to write this angle in terms of π
  # or roots or something.  Would be cute.
  THETA_C = Math::asin(1/Math::sqrt(3))

  def test_forward_mapping
    p = self.projection

    # We'll test the mappings of 26 specific points around the sphere.

    # First, the one north pole.

    # 1. θ = π/2 (90°N) should map to the centre point of the top
    # face.  φ is irrelevant here.
    face, x, y = p.forward(0.0, PI/2)
    assert_equal(TOP_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)

    # Then the four middle points of the edges of the top cube face.
    # These are all at θ = π/4 (45°N).

    # 2. φ = -π/2, θ = π/4 (45°N 90°W) should map to the left point of
    # the top face, or the up point of the west face.  When
    # coordinates are given exactly like that, this implementation
    # maps to the west face.
    face, x, y = p.forward(-PI/2, PI/4)
    assert_equal(WEST_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta( 1.0, y, DELTA)
    # A nudge northward, though, and we're on the top face.
    face, x, y = p.forward(-PI/2, PI/4+NUDGE)
    assert_equal(TOP_FACE, face)
    assert_in_delta(-1.0+NUDGE, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)

    # 3. φ = 0, θ = π/4 (45°N 0°) should map to the down point of the
    # top face, or the up point of the front face.  When coordinates
    # are given exactly like that, this implementation maps to the
    # front face.
    face, x, y = p.forward(0.0, PI/4)
    assert_equal(FRONT_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta( 1.0, y, DELTA)
    # A nudge northward, though, and we're on the top face.
    face, x, y = p.forward(0.0, PI/4+NUDGE)
    assert_equal(TOP_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta(-1.0+NUDGE, y, DELTA)

    # 4. φ = π/2, θ = π/4 (45°N 90°E) should map to the right point of
    # the top face, or the up point of the east face.  When
    # coordinates are given exactly like that, this implementation
    # maps to the east face.
    face, x, y = p.forward(PI/2, PI/4)
    assert_equal(EAST_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta( 1.0, y, DELTA)
    # A nudge northward, though, and we're on the top face.
    face, x, y = p.forward(PI/2, PI/4+NUDGE)
    assert_equal(TOP_FACE, face)
    assert_in_delta( 1.0-NUDGE, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)

    # 5. φ = π, θ = π/4 (45°N 180°) should map to the up point of the
    # top face, or the up point of the back face.  When coordinates
    # are given exactly like that, this implementation maps to the
    # back face.
    face, x, y = p.forward(PI, PI/4)
    assert_equal(BACK_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta( 1.0, y, DELTA)
    # A nudge northward, though, and we're on the top face.
    face, x, y = p.forward(PI, PI/4+NUDGE)
    assert_equal(TOP_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta( 1.0-NUDGE, y, DELTA)

    # Then the four corners of the top cube face.  These are all at
    # θ = θc = arcsin(1/√3) -- about 35.26°N.

    # 6. φ = -3π/4, θ = θc (35.26°N 135°W) should map to the up-left
    # point of the top face, or the up-right point of the back face,
    # or the up-left point of the west face.  When coordinates are
    # given exactly like that, this implementation maps to the top
    # face.
    face, x, y = p.forward(-3*PI/4, THETA_C)
    assert_equal(TOP_FACE, face)
    assert_in_delta(-1.0, x, DELTA)
    assert_in_delta( 1.0, y, DELTA)
    # A nudge westward, though, and we're on the back face.
    face, x, y = p.forward(-3*PI/4-2*NUDGE, THETA_C)
    assert_equal(BACK_FACE, face)
    assert_in_delta( 1.0-3*NUDGE, x, DELTA)
    assert_in_delta( 1.0, y, DELTA)
    # Or a nudge eastward, and we're on the west face.
    face, x, y = p.forward(-3*PI/4+2*NUDGE, THETA_C)
    assert_equal(WEST_FACE, face)
    assert_in_delta(-1.0+3*NUDGE, x, DELTA)
    assert_in_delta( 1.0, y, DELTA)

    # 7. φ = -π/4, θ = θc (35.26°N 45°W) should map to the down-left
    # point of the top face, or the up-left point of the front face,
    # or the up-right point of the west face.  When coordinates are
    # given exactly like that, this implementation maps to the top
    # face.
    face, x, y = p.forward(-PI/4, THETA_C)
    assert_equal(TOP_FACE, face)
    assert_in_delta(-1.0, x, DELTA)
    assert_in_delta(-1.0, y, DELTA)
    # A nudge westward, though, and we're on the west face.
    face, x, y = p.forward(-PI/4-2*NUDGE, THETA_C)
    assert_equal(WEST_FACE, face)
    assert_in_delta( 1.0-3*NUDGE, x, DELTA)
    assert_in_delta( 1.0, y, DELTA)
    # Or a nudge eastward, and we're on the front face.
    face, x, y = p.forward(-PI/4+2*NUDGE, THETA_C)
    assert_equal(FRONT_FACE, face)
    assert_in_delta(-1.0+3*NUDGE, x, DELTA)
    assert_in_delta( 1.0, y, DELTA)

    # 8. φ = π/4, θ = θc (35.26°N 45°E) should map to the down-right
    # point of the top face, or the up-right point of the front face,
    # or the up-left point of the east face.  When coordinates are
    # given exactly like that, this implementation maps to the top
    # face.
    face, x, y = p.forward(PI/4, THETA_C)
    assert_equal(TOP_FACE, face)
    assert_in_delta( 1.0, x, DELTA)
    assert_in_delta(-1.0, y, DELTA)
    # A nudge westward, though, and we're on the front face.
    face, x, y = p.forward(PI/4-2*NUDGE, THETA_C)
    assert_equal(FRONT_FACE, face)
    assert_in_delta( 1.0-3*NUDGE, x, DELTA)
    assert_in_delta( 1.0, y, DELTA)
    # Or a nudge eastward, and we're on the east face.
    face, x, y = p.forward(PI/4+2*NUDGE, THETA_C)
    assert_equal(EAST_FACE, face)
    assert_in_delta(-1.0+3*NUDGE, x, DELTA)
    assert_in_delta( 1.0, y, DELTA)

    # 9. φ = 3π/4, θ = θc (35.26°N 135°E) should map to the up-right
    # point of the top face, or the up-right point of the east face,
    # or the up-left point of the back face.  When coordinates are
    # given exactly like that, this implementation maps to the top
    # face.
    face, x, y = p.forward(3*PI/4, THETA_C)
    assert_equal(TOP_FACE, face)
    assert_in_delta( 1.0, x, DELTA)
    assert_in_delta( 1.0, y, DELTA)
    # A nudge westward, though, and we're on the east face.
    face, x, y = p.forward(3*PI/4-2*NUDGE, THETA_C)
    assert_equal(EAST_FACE, face)
    assert_in_delta( 1.0-3*NUDGE, x, DELTA)
    assert_in_delta( 1.0, y, DELTA)
    # Or a nudge eastward, and we're on the back face.
    face, x, y = p.forward(3*PI/4+2*NUDGE, THETA_C)
    assert_equal(BACK_FACE, face)
    assert_in_delta(-1.0+3*NUDGE, x, DELTA)
    assert_in_delta( 1.0, y, DELTA)

    # Then the "equatorial belt", eight points, being the four centres
    # of the front, east, back and west faces, and the the midpoints
    # of the vertical edges of these faces.  These eight points are at
    # θ = zero, of course.

    # 10. φ = -3π/4, θ = 0 (0° 135°W) should map to the right point of
    # the back face, or the left point of the west face.  When
    # coordinates are given exactly like that, this implementation
    # maps to the west face.
    face, x, y = p.forward(-3*PI/4, 0.0)
    assert_equal(WEST_FACE, face)
    assert_in_delta(-1.0, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)
    # A nudge westward, though, and we're on the back face.
    face, x, y = p.forward(-3*PI/4-2*NUDGE, 0.0)
    assert_equal(BACK_FACE, face)
    assert_in_delta( 1.0-3*NUDGE, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)

    # 11. φ = -π/2, θ = 0 (0° 90°W) should map to the centre point of
    # the west face.
    face, x, y = p.forward(-PI/2, 0.0)
    assert_equal(WEST_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)

    # 12. φ = -π/4, θ = 0 (0° 45°W) should map to the left point of
    # the front face, or the right point of the west face.  When
    # coordinates are given exactly like that, this implementation
    # maps to the front face.
    face, x, y = p.forward(-PI/4, 0.0)
    assert_equal(FRONT_FACE, face)
    assert_in_delta(-1.0, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)
    # A nudge westward, though, and we're on the XXX face.
    face, x, y = p.forward(-PI/4-2*NUDGE, 0.0)
    assert_equal(WEST_FACE, face)
    assert_in_delta( 1.0-3*NUDGE, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)

    # 13. φ = 0, θ = 0 (0° 0°) should map to the centre point of the
    # front face.
    face, x, y = p.forward(0.0, 0.0)
    assert_equal(FRONT_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)

    # 14. φ = π/4, θ = 0 (0° 45°E) should map to the right point of
    # the front face, or the left point of the east face.  When
    # coordinates are given exactly like that, this implementation
    # maps to the front face.
    face, x, y = p.forward(PI/4, 0.0)
    assert_equal(FRONT_FACE, face)
    assert_in_delta( 1.0, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)
    # A nudge eastward, though, and we're on the east face.
    face, x, y = p.forward(PI/4+2*NUDGE, 0.0)
    assert_equal(EAST_FACE, face)
    assert_in_delta(-1.0+3*NUDGE, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)

    # 15. φ = π/2, θ = 0 (0° 90°E) should map to the centre point of
    # the east face.
    face, x, y = p.forward(PI/2, 0.0)
    assert_equal(EAST_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)

    # 16. φ = 3π/4, θ = 0 (0° 135°E) should map to the right point of
    # the east face, or the left point of the back face.  When
    # coordinates are given exactly like that, this implementation
    # maps to the east face.
    face, x, y = p.forward(3*PI/4, 0.0)
    assert_equal(EAST_FACE, face)
    assert_in_delta( 1.0, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)
    # A nudge eastward, though, and we're on the back face.
    face, x, y = p.forward(3*PI/4+2*NUDGE, 0.0)
    assert_equal(BACK_FACE, face)
    assert_in_delta(-1.0+3*NUDGE, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)

    # 17. φ = π, θ = 0 (0° 180°) should map to the centre point of the
    # back face.
    face, x, y = p.forward(PI, 0.0)
    assert_equal(BACK_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)

    # Then the four corners of the bottom cube face.  These are all at
    # θ = -θc = -arcsin(1/√3) -- about 35.26°S.

    # 18. φ = -3π/4, θ = -θc (35.26°S 135°W) should map to the
    # down-right point of the back face, or the down-left point of the
    # west face, or the down-left point of the bottom face.  When
    # coordinates are given exactly like that, this implementation
    # maps to the bottom face.
    face, x, y = p.forward(-3*PI/4, -THETA_C)
    assert_equal(BOTTOM_FACE, face)
    assert_in_delta(-1.0, x, DELTA)
    assert_in_delta(-1.0, y, DELTA)
    # A nudge westward, though, and we're on the back face.
    face, x, y = p.forward(-3*PI/4-2*NUDGE, -THETA_C)
    assert_equal(BACK_FACE, face)
    assert_in_delta( 1.0-3*NUDGE, x, DELTA)
    assert_in_delta(-1.0, y, DELTA)
    # Or a nudge eastward, and we're on the west face.
    face, x, y = p.forward(-3*PI/4+2*NUDGE, -THETA_C)
    assert_equal(WEST_FACE, face)
    assert_in_delta(-1.0+3*NUDGE, x, DELTA)
    assert_in_delta(-1.0, y, DELTA)

    # 19. φ = -π/4, θ = -θc (35.26°S 45°W) should map to the down-left
    # point of the front face, or the down-right point of the west
    # face, or the up-left point of the bottom face.  When coordinates
    # are given exactly like that, this implementation maps to the
    # bottom face.
    face, x, y = p.forward(-PI/4, -THETA_C)
    assert_equal(BOTTOM_FACE, face)
    assert_in_delta(-1.0, x, DELTA)
    assert_in_delta( 1.0, y, DELTA)
    # A nudge westward, though, and we're on the west face.
    face, x, y = p.forward(-PI/4-2*NUDGE, -THETA_C)
    assert_equal(WEST_FACE, face)
    assert_in_delta( 1.0-3*NUDGE, x, DELTA)
    assert_in_delta(-1.0, y, DELTA)
    # Or a nudge eastward, and we're on the front face.
    face, x, y = p.forward(-PI/4+2*NUDGE, -THETA_C)
    assert_equal(FRONT_FACE, face)
    assert_in_delta(-1.0+3*NUDGE, x, DELTA)
    assert_in_delta(-1.0, y, DELTA)

    # 20. φ = π/4, θ = -θc (35.26°S 45°E) should map to the down-right
    # point of the front face, or the down-left point of the east
    # face, or the up-right point of the bottom face.  When
    # coordinates are given exactly like that, this implementation
    # maps to the bottom face.
    face, x, y = p.forward(PI/4, -THETA_C)
    assert_equal(BOTTOM_FACE, face)
    assert_in_delta( 1.0, x, DELTA)
    assert_in_delta( 1.0, y, DELTA)
    # A nudge westward, though, and we're on the front face.
    face, x, y = p.forward(PI/4-2*NUDGE, -THETA_C)
    assert_equal(FRONT_FACE, face)
    assert_in_delta( 1.0-3*NUDGE, x, DELTA)
    assert_in_delta(-1.0, y, DELTA)
    # Or a nudge eastward, and we're on the east face.
    face, x, y = p.forward(PI/4+2*NUDGE, -THETA_C)
    assert_equal(EAST_FACE, face)
    assert_in_delta(-1.0+3*NUDGE, x, DELTA)
    assert_in_delta(-1.0, y, DELTA)

    # 21. φ = 3π/4, θ = -θc (35.26°S 135°E) should map to the
    # down-right point of the east face, or the down-left point of the
    # back face, or the down-right point of the bottom face.  When
    # coordinates are given exactly like that, this implementation
    # maps to the bottom face.
    face, x, y = p.forward(3*PI/4, -THETA_C)
    assert_equal(BOTTOM_FACE, face)
    assert_in_delta( 1.0, x, DELTA)
    assert_in_delta(-1.0, y, DELTA)
    # A nudge westward, though, and we're on the east face.
    face, x, y = p.forward(3*PI/4-2*NUDGE, -THETA_C)
    assert_equal(EAST_FACE, face)
    assert_in_delta( 1.0-3*NUDGE, x, DELTA)
    assert_in_delta(-1.0, y, DELTA)
    # Or a nudge eastward, and we're on the back face.
    face, x, y = p.forward(3*PI/4+2*NUDGE, -THETA_C)
    assert_equal(BACK_FACE, face)
    assert_in_delta(-1.0+3*NUDGE, x, DELTA)
    assert_in_delta(-1.0, y, DELTA)

    # Then the four middle points of the edges of the bottom cube
    # face.  These are all at θ = -π/4 (45°S).

    # 22. φ = -π/2, θ = -π/4 (45°S 90°W) should map to the down point
    # of the west face, or the left point of the bottom face.  When
    # coordinates are given exactly like that, this implementation
    # maps to the west face.
    face, x, y = p.forward(-PI/2, -PI/4)
    assert_equal(WEST_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta(-1.0, y, DELTA)
    # A nudge southward, though, and we're on the bottom face.
    face, x, y = p.forward(-PI/2, -PI/4-NUDGE)
    assert_equal(BOTTOM_FACE, face)
    assert_in_delta(-1.0+NUDGE, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)

    # 23. φ = 0, θ = -π/4 (45°S 0°) should map to the down point of
    # the front face, or the up point of the bottom face.  When
    # coordinates are given exactly like that, this implementation
    # maps to the FRONT face.
    face, x, y = p.forward(0.0, -PI/4)
    assert_equal(FRONT_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta(-1.0, y, DELTA)
    # A nudge southward, though, and we're on the bottom face.
    face, x, y = p.forward(0.0, -PI/4-NUDGE)
    assert_equal(BOTTOM_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta( 1.0-NUDGE, y, DELTA)

    # 24. φ = π/2, θ = -π/4 (45°S 90°E) should map to the down point
    # of the east face, or the right point of the bottom face.  When
    # coordinates are given exactly like that, this implementation
    # maps to the east face.
    face, x, y = p.forward(PI/2, -PI/4)
    assert_equal(EAST_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta(-1.0, y, DELTA)
    # A nudge southward, though, and we're on the bottom face.
    face, x, y = p.forward(PI/2, -PI/4-NUDGE)
    assert_equal(BOTTOM_FACE, face)
    assert_in_delta( 1.0-NUDGE, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)

    # 25. φ = π, θ = -π/4 (45°S 180°) should map to the down point of
    # the back face, or the down point of the bottom face.  When
    # coordinates are given exactly like that, this implementation
    # maps to the back face.
    face, x, y = p.forward(PI, -PI/4)
    assert_equal(BACK_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta(-1.0, y, DELTA)
    # A nudge southward, though, and we're on the bottom face.
    face, x, y = p.forward(PI, -PI/4-NUDGE)
    assert_equal(BOTTOM_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta(-1.0+NUDGE, y, DELTA)

    # Finally, the one south pole.

    # 26. θ = -π/2 (90°S ) should map to the centre point of the
    # bottom face.  φ is irrelevant here.

    face, x, y = p.forward(0.0, -PI/2)
    assert_equal(BOTTOM_FACE, face)
    assert_in_delta( 0.0, x, DELTA)
    assert_in_delta( 0.0, y, DELTA)

  end # test_forward_mapping


  def test_inverse_mapping
    p = self.projection

    # We'll test nine points on each cube face: the four corners, the
    # four centres of each edge, and the centre of the face.  Please
    # note that, except for the face centres, the mappings are not
    # necessarily reversible.  This is because, for any point that is
    # shared amongst two or three faces, the forward projection may
    # choose to return a mapping to any of the shared faces.  See all
    # those nudges in the forward mapping tests above.

    # 1. The top face.

    # The up-left point of the top face should map to
    # φ = -3π/4, θ = θc.
    phi, theta = p.inverse(TOP_FACE, -1.0,  1.0)
    assert_in_delta(-3*PI/4, phi, DELTA)
    assert_in_delta(THETA_C, theta, DELTA)

    # The up point of the top face should map to
    # φ = π, θ = π/4.
    phi, theta = p.inverse(TOP_FACE,  0.0,  1.0)
    assert_in_delta(PI, phi, DELTA)
    assert_in_delta(PI/4, theta, DELTA)

    # The up-right point of the top face should map to
    # φ = 3π/4, θ = θc.
    phi, theta = p.inverse(TOP_FACE,  1.0,  1.0)
    assert_in_delta(3*PI/4, phi, DELTA)
    assert_in_delta(THETA_C, theta, DELTA)

    # The left point of the top face should map to
    # φ = -π/2, θ = π/4.
    phi, theta = p.inverse(TOP_FACE, -1.0,  0.0)
    assert_in_delta(-PI/2, phi, DELTA)
    assert_in_delta(PI/4, theta, DELTA)

    # The centre point of the top face should map to
    # θ = π/2, with φ being irrelevant.
    phi, theta = p.inverse(TOP_FACE,  0.0,  0.0)
    assert_in_delta(PI/2, theta, DELTA)
    # So here, any value is correct.  This implementation returns
    # PI, though, for some reason, and we'll watch for changes.
    assert_in_delta(PI, phi, DELTA)

    # The right point of the top face should map to
    # φ = π/2, θ = π/4.
    phi, theta = p.inverse(TOP_FACE,  1.0,  0.0)
    assert_in_delta(PI/2, phi, DELTA)
    assert_in_delta(PI/4, theta, DELTA)

    # The down-left point of the top face should map to
    # φ = -π/4, θ = θc.
    phi, theta = p.inverse(TOP_FACE, -1.0, -1.0)
    assert_in_delta(-PI/4, phi, DELTA)
    assert_in_delta(THETA_C, theta, DELTA)

    # The down point of the top face should map to
    # φ = 0, θ = π/4.
    phi, theta = p.inverse(TOP_FACE,  0.0, -1.0)
    assert_in_delta(0.0, phi, DELTA)
    assert_in_delta(PI/4, theta, DELTA)

    # The down-right point of the top face should map to
    # φ = π/4, θ = θc.
    phi, theta = p.inverse(TOP_FACE,  1.0, -1.0)
    assert_in_delta(PI/4, phi, DELTA)
    assert_in_delta(THETA_C, theta, DELTA)

    # 2. The front face.

    # The up-left point of the front face should map to
    # φ = -π/4, θ = θc.
    phi, theta = p.inverse(FRONT_FACE, -1.0,  1.0)
    assert_in_delta(-PI/4, phi, DELTA)
    assert_in_delta(THETA_C, theta, DELTA)

    # The up point of the front face should map to
    # φ = 0, θ = π/4.
    phi, theta = p.inverse(FRONT_FACE,  0.0,  1.0)
    assert_in_delta(0.0, phi, DELTA)
    assert_in_delta(PI/4, theta, DELTA)

    # The up-right point of the front face should map to
    # φ = π/4, θ = θc.
    phi, theta = p.inverse(FRONT_FACE,  1.0,  1.0)
    assert_in_delta(PI/4, phi, DELTA)
    assert_in_delta(THETA_C, theta, DELTA)

    # The left point of the front face should map to
    # φ = -π/4, θ = 0.
    phi, theta = p.inverse(FRONT_FACE, -1.0,  0.0)
    assert_in_delta(-PI/4, phi, DELTA)
    assert_in_delta(0.0, theta, DELTA)

    # The centre point of the front face should map to
    # φ = 0, θ = 0.
    phi, theta = p.inverse(FRONT_FACE,  0.0,  0.0)
    assert_in_delta(0.0, phi, DELTA)
    assert_in_delta(0.0, theta, DELTA)

    # The right point of the front face should map to
    # φ = π/4, θ = 0.
    phi, theta = p.inverse(FRONT_FACE,  1.0,  0.0)
    assert_in_delta(PI/4, phi, DELTA)
    assert_in_delta(0.0, theta, DELTA)

    # The down-left point of the front face should map to
    # φ = -π/4, θ = -θc.
    phi, theta = p.inverse(FRONT_FACE, -1.0, -1.0)
    assert_in_delta(-PI/4, phi, DELTA)
    assert_in_delta(-THETA_C, theta, DELTA)

    # The down point of the front face should map to
    # φ = 0, θ = -π/4.
    phi, theta = p.inverse(FRONT_FACE,  0.0, -1.0)
    assert_in_delta(0.0, phi, DELTA)
    assert_in_delta(-PI/4, theta, DELTA)

    # The down-right point of the front face should map to
    # φ = π/4, θ = -θc.
    phi, theta = p.inverse(FRONT_FACE,  1.0, -1.0)
    assert_in_delta(PI/4, phi, DELTA)
    assert_in_delta(-THETA_C, theta, DELTA)

    # 3. The east face.

    # The up-left point of the east face should map to
    # φ = π/4, θ = θc.
    phi, theta = p.inverse(EAST_FACE, -1.0,  1.0)
    assert_in_delta(PI/4, phi, DELTA)
    assert_in_delta(THETA_C, theta, DELTA)

    # The up point of the east face should map to
    # φ = π/2, θ = π/4.
    phi, theta = p.inverse(EAST_FACE,  0.0,  1.0)
    assert_in_delta(PI/2, phi, DELTA)
    assert_in_delta(PI/4, theta, DELTA)

    # The up-right point of the east face should map to
    # φ = 3π/4, θ = θc.
    phi, theta = p.inverse(EAST_FACE,  1.0,  1.0)
    assert_in_delta(3*PI/4, phi, DELTA)
    assert_in_delta(THETA_C, theta, DELTA)

    # The left point of the east face should map to
    # φ = π/4, θ = 0.
    phi, theta = p.inverse(EAST_FACE, -1.0,  0.0)
    assert_in_delta(PI/4, phi, DELTA)
    assert_in_delta(0.0, theta, DELTA)

    # The centre point of the east face should map to
    # φ = π/2, θ = 0.
    phi, theta = p.inverse(EAST_FACE,  0.0,  0.0)
    assert_in_delta(PI/2, phi, DELTA)
    assert_in_delta(0.0, theta, DELTA)

    # The right point of the east face should map to
    # φ = 3π/4, θ = 0.
    phi, theta = p.inverse(EAST_FACE,  1.0,  0.0)
    assert_in_delta(3*PI/4, phi, DELTA)
    assert_in_delta(0.0, theta, DELTA)

    # The down-left point of the east face should map to
    # φ = π/4, θ = -θc.
    phi, theta = p.inverse(EAST_FACE, -1.0, -1.0)
    assert_in_delta(PI/4, phi, DELTA)
    assert_in_delta(-THETA_C, theta, DELTA)

    # The down point of the east face should map to
    # φ = π/2, θ = -π/4.
    phi, theta = p.inverse(EAST_FACE,  0.0, -1.0)
    assert_in_delta(PI/2, phi, DELTA)
    assert_in_delta(-PI/4, theta, DELTA)

    # The down-right point of the east face should map to
    # φ = 3π/4, θ = -θc.
    phi, theta = p.inverse(EAST_FACE,  1.0, -1.0)
    assert_in_delta(3*PI/4, phi, DELTA)
    assert_in_delta(-THETA_C, theta, DELTA)

    # 4. The back face.

    # The up-left point of the back face should map to
    # φ = 3π/4, θ = θc.
    phi, theta = p.inverse(BACK_FACE, -1.0,  1.0)
    assert_in_delta(3*PI/4, phi, DELTA)
    assert_in_delta(THETA_C, theta, DELTA)

    # The up point of the back face should map to
    # φ = π, θ = π/4.
    # Note the implementation returns φ = -π, which is also correct.
    phi, theta = p.inverse(BACK_FACE,  0.0,  1.0)
    assert_in_delta(-PI, phi, DELTA)
    assert_in_delta(PI/4, theta, DELTA)

    # The up-right point of the back face should map to
    # φ = -3π/4, θ = θc.
    phi, theta = p.inverse(BACK_FACE,  1.0,  1.0)
    assert_in_delta(-3*PI/4, phi, DELTA)
    assert_in_delta(THETA_C, theta, DELTA)

    # The left point of the back face should map to
    # φ = 3π/4, θ = 0.
    phi, theta = p.inverse(BACK_FACE, -1.0,  0.0)
    assert_in_delta(3*PI/4, phi, DELTA)
    assert_in_delta(0.0, theta, DELTA)

    # The centre point of the back face should map to
    # φ = π, θ = 0.
    # Note the implementation returns φ = -π, which is also correct.
    phi, theta = p.inverse(BACK_FACE,  0.0,  0.0)
    assert_in_delta(-PI, phi, DELTA)
    assert_in_delta(0.0, theta, DELTA)

    # The right point of the back face should map to
    # φ = -3π/4, θ = 0.
    phi, theta = p.inverse(BACK_FACE,  1.0,  0.0)
    assert_in_delta(-3*PI/4, phi, DELTA)
    assert_in_delta(0.0, theta, DELTA)

    # The down-left point of the back face should map to
    # φ = 3π/4, θ = -θc.
    phi, theta = p.inverse(BACK_FACE, -1.0, -1.0)
    assert_in_delta(3*PI/4, phi, DELTA)
    assert_in_delta(-THETA_C, theta, DELTA)

    # The down point of the back face should map to
    # φ = π, θ = -π/4.
    # Note the implementation returns φ = -π, which is also correct.
    phi, theta = p.inverse(BACK_FACE,  0.0, -1.0)
    assert_in_delta(-PI, phi, DELTA)
    assert_in_delta(-PI/4, theta, DELTA)

    # The down-right point of the back face should map to
    # φ = -3π/4, θ = -θc.
    phi, theta = p.inverse(BACK_FACE,  1.0, -1.0)
    assert_in_delta(-3*PI/4, phi, DELTA)
    assert_in_delta(-THETA_C, theta, DELTA)

    # 5. The west face.

    # The up-left point of the west face should map to
    # φ = -3π/4, θ = θc.
    phi, theta = p.inverse(WEST_FACE, -1.0,  1.0)
    assert_in_delta(-3*PI/4, phi, DELTA)
    assert_in_delta(THETA_C, theta, DELTA)

    # The up point of the west face should map to
    # φ = -π/2, θ = π/4.
    phi, theta = p.inverse(WEST_FACE,  0.0,  1.0)
    assert_in_delta(-PI/2, phi, DELTA)
    assert_in_delta(PI/4, theta, DELTA)

    # The up-right point of the west face should map to
    # φ = -π/4, θ = θc.
    phi, theta = p.inverse(WEST_FACE,  1.0,  1.0)
    assert_in_delta(-PI/4, phi, DELTA)
    assert_in_delta(THETA_C, theta, DELTA)

    # The left point of the west face should map to
    # φ = -3π/4, θ = 0.
    phi, theta = p.inverse(WEST_FACE, -1.0,  0.0)
    assert_in_delta(-3*PI/4, phi, DELTA)
    assert_in_delta(0.0, theta, DELTA)

    # The centre point of the west face should map to
    # φ = -π/2, θ = 0.
    phi, theta = p.inverse(WEST_FACE,  0.0,  0.0)
    assert_in_delta(-PI/2, phi, DELTA)
    assert_in_delta(0.0, theta, DELTA)

    # The right point of the west face should map to
    # φ = -π/4, θ = 0.
    phi, theta = p.inverse(WEST_FACE,  1.0,  0.0)
    assert_in_delta(-PI/4, phi, DELTA)
    assert_in_delta(0.0, theta, DELTA)

    # The down-left point of the west face should map to
    # φ = -3π/4, θ = -θc.
    phi, theta = p.inverse(WEST_FACE, -1.0, -1.0)
    assert_in_delta(-3*PI/4, phi, DELTA)
    assert_in_delta(-THETA_C, theta, DELTA)

    # The down point of the west face should map to
    # φ = -π/2, θ = -π/4.
    phi, theta = p.inverse(WEST_FACE,  0.0, -1.0)
    assert_in_delta(-PI/2, phi, DELTA)
    assert_in_delta(-PI/4, theta, DELTA)

    # The down-right point of the west face should map to
    # φ = -π/4, θ = -θc.
    phi, theta = p.inverse(WEST_FACE,  1.0, -1.0)
    assert_in_delta(-PI/4, phi, DELTA)
    assert_in_delta(-THETA_C, theta, DELTA)

    # 6. The bottom face.

    # The up-left point of the bottom face should map to
    # φ = -π/4, θ = -θc.
    phi, theta = p.inverse(BOTTOM_FACE, -1.0,  1.0)
    assert_in_delta(-PI/4, phi, DELTA)
    assert_in_delta(-THETA_C, theta, DELTA)

    # The up point of the bottom face should map to
    # φ = 0, θ = -π/4.
    phi, theta = p.inverse(BOTTOM_FACE,  0.0,  1.0)
    assert_in_delta(0.0, phi, DELTA)
    assert_in_delta(-PI/4, theta, DELTA)

    # The up-right point of the bottom face should map to
    # φ = π/4, θ = -θc.
    phi, theta = p.inverse(BOTTOM_FACE,  1.0,  1.0)
    assert_in_delta(PI/4, phi, DELTA)
    assert_in_delta(-THETA_C, theta, DELTA)

    # The left point of the bottom face should map to
    # φ = -π/2, θ = -π/4.
    phi, theta = p.inverse(BOTTOM_FACE, -1.0,  0.0)
    assert_in_delta(-PI/2, phi, DELTA)
    assert_in_delta(-PI/4, theta, DELTA)

    # The centre point of the bottom face should map to
    # θ = -π/2, with φ being irrelevant.
    phi, theta = p.inverse(BOTTOM_FACE,  0.0,  0.0)
    assert_in_delta(-PI/2, theta, DELTA)
    # So here, any value is correct.  This implementation returns
    # zero, though, for some reason.  And we'll watch for changes.
    assert_in_delta(0.0, phi, DELTA)

    # The right point of the bottom face should map to
    # φ = π/2, θ = -π/4.
    phi, theta = p.inverse(BOTTOM_FACE,  1.0,  0.0)
    assert_in_delta(PI/2, phi, DELTA)
    assert_in_delta(-PI/4, theta, DELTA)

    # The down-left point of the bottom face should map to
    # φ = -3π/4, θ = -θc.
    phi, theta = p.inverse(BOTTOM_FACE, -1.0, -1.0)
    assert_in_delta(-3*PI/4, phi, DELTA)
    assert_in_delta(-THETA_C, theta, DELTA)

    # The down point of the bottom face should map to
    # φ = π, θ = -π/4.
    phi, theta = p.inverse(BOTTOM_FACE,  0.0, -1.0)
    assert_in_delta(PI, phi, DELTA)
    assert_in_delta(-PI/4, theta, DELTA)

    # The down-right point of the bottom face should map to
    # φ = 3π/4, θ = -θc.
    phi, theta = p.inverse(BOTTOM_FACE,  1.0, -1.0)
    assert_in_delta(3*PI/4, phi, DELTA)
    assert_in_delta(-THETA_C, theta, DELTA)

  end # test_inverse_mapping

end # module MappingTests

class TangentialMappingTest < Test::Unit::TestCase
  include MappingTests

  def projection
    QuadSphere::Tangential
  end
end

class CSCMappingTest < Test::Unit::TestCase
  include MappingTests

  def projection
    QuadSphere::CSC
  end

  def test_distortion_closure
    expected_error = 2.4e-4

    (-0.99).step(0.99, 0.01) do |psi|
      (-0.99).step(0.99, 0.01) do |chi|
        x = projection.forward_distort(chi, psi)
        y = projection.forward_distort(psi, chi)
        chi1 = projection.inverse_distort(x,y)
        assert_in_delta(0.0, chi1-chi, expected_error)
        psi1 = projection.inverse_distort(y,x)
        error = Math::sqrt((chi1-chi)**2 + (psi1-psi)**2)
        assert_in_delta(0.0, error, expected_error)
      end
    end
  end

  def test_closure
    error = 3.0e-4

    100.times do |row|
      100.times do |col|
        x = 0.005+col/100.0
        y = 0.005+row/100.0
        phi, theta = projection.inverse(WEST_FACE, x, y)
        f1, x1, y1 = projection.forward(phi, theta)
        assert_equal(WEST_FACE, f1)
        assert_in_delta(x, x1, error)
        assert_in_delta(y, y1, error)
      end
    end
  end
end

