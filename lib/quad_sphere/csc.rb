# -*- coding: utf-8 -*-

require 'quad_sphere'
require 'quad_sphere/tangential'

module QuadSphere

  # Implements the quadrilateralised spherical cube projection.
  #
  # The quadrilateralised spherical cube projection, or "Quad Sphere"
  # or "COBE Sky Cube" (CSC), applies a further curvilinear
  # transformation to the tangential spherical cube projection, to
  # make it approximately equal-area.  This is useful for storing
  # spherical data in a raster: then you can integrate directly on the
  # cube face planes, without having to map your data back to the
  # original sphere.
  #
  # This projection has been used extensively by the Cosmic Background
  # Explorer project (COBE), and this implementation _should_ match
  # results from their software.  This can't be guaranteed, though, as
  # this author hasn't pursued finding and testing raw COBE data.
  # There's a to-do, right there.
  #
  # Mind that this implements only the spherical projection, not the
  # scheme for storing pixels along a Z-order curve, that is described
  # in length as part of the COBE data format.  We don't deal with
  # pixels at all.
  #
  # Also: this implements the projection described by Chan & O'Neill,
  # 1975, _not_ the one by Laubscher & O'Neill, 1976, which is
  # non-differentiable along the diagonals.
  #
  # As Chan's original report is not readily available, this
  # implementation is based on formulae found in FITS WCS documents.
  # Specifically: "Representations of celestial coordinates in FITS
  # (Paper II)", Calabretta, M. R., and Greisen, E. W., <i>Astronomy &
  # Astrophysics</i>, 395, 1077-1122, 2002.  This is available from
  # the FITS Support Office at NASA/GSFC; see reference below.  And
  # mind the possible implications of this on the accuracy of the
  # transformation, discussed in the documentation of
  # {forward_distort}.
  #
  # @see http://lambda.gsfc.nasa.gov/product/cobe/skymap_info_new.cfm
  #   COBE Quadrilateralized Spherical Cube at NASA's data center for
  #   Cosmic Microwave Background research.
  # @see http://fits.gsfc.nasa.gov/fits_wcs.html
  #   FITS World Coordinate System Documents at NASA/GSFC.
  # @see http://en.wikipedia.org/wiki/Quadrilateralized_spherical_cube
  #   Quadrilateralized spherical cube at Wikipedia.
  # @see http://gis.stackexchange.com/questions/40957/is-the-quadrilateralized-spherical-cube-map-projection-the-same-as-snyders-cubi
  #   Remarks by (allegedly) Kenneth Chan regarding his and
  #   Laubscher's work, at the GIS StackExchange.
  # @see http://www.progonos.com/furuti/MapProj/Normal/ProjPoly/projPoly2.html
  #   Pretty maps at Carlos A. Furuti's website.
  #
  # @author César Rincón
  module CSC

    # Computes the projection of a point on the surface of the sphere,
    # given in spherical coordinates (φ,θ), to a point of cartesian
    # coordinates (x,y) on one of the six cube faces.
    #
    # @param phi (Float) the φ angle in radians, from -π to π (or 0 to
    #   to 2π, if you like).  This is the azimuth, or longitude
    #   (spherical, not geodetic).
    # @param theta (Float) the θ angle in radians, from -π/2 to π/2.
    #   This is the elevation, or latitude (spherical, not geodetic).
    #
    # @return (Array) an array of three elements: the identifier of
    #   the face (see constants in {QuadSphere}), the _x_ coordinate
    #   of the projected point, and the _y_ coordinate of the
    #   projected point.  Both coordinates will be in the range -1 to
    #   1.
    #
    # @see inverse
    def self.forward(phi, theta)
      face, chi, psi = Tangential.forward(phi, theta)
      [ face, forward_distort(chi,psi), forward_distort(psi,chi) ]
    end

    # Computes the projection of a point at cartesian coordinates
    # (x,y) on one of the six cube faces, to a point at spherical
    # coordinates (φ,θ) on the surface of the sphere.
    #
    # Note that, while the projection is reversible for points within
    # each of the cube faces, it is not necessarily so for points
    # located exactly on the edges.  This is because points on the
    # edges of the cube are shared amongst two or even three faces,
    # and the forward projection may return an alternative mapping to
    # a neighbouring face.
    #
    # @param face (Integer) the identifier of the cube face; see
    #   constants in {QuadSphere}.
    # @param x (Float) the _x_ coordinate of the point within the
    #   face, from -1.0 to 1.0.
    # @param y (Float) the _y_ coordinate of the point within the
    #   face, from -1.0 to 1.0.
    #
    # @return (Array) an array of two elements: the φ angle in radians
    #   (azimuth or longitude - spherical, not geodetic), from -π to
    #   π; and the θ angle in radians, from -π/2 to π/2 (elevation or
    #   latitude - spherical, not geodetic).
    #
    # @see forward
    def self.inverse(face, x, y)
      chi = inverse_distort(x,y)
      psi = inverse_distort(y,x)
      Tangential.inverse(face, chi, psi)
    end

    # This performs the forward curvilinear transformation of
    # coordinates on a cube face, from the basic tangential to the CSC
    # projection.  Specifically, the function computes the adjusted
    # cartesian coordinate _x_ from the original coordinates χ,ψ
    # produced by tangential projection.  To compute the _y_
    # coordinate, evaluate again for ψ,χ.
    #
    # This is not an exact transformation, and its accuracy is further
    # impaired by the fact that the math foundation behind the CSC
    # projection is not publicly available - the closest we have to a
    # "gold standard" is the polynomial approximation put forward in
    # the Calabretta paper.  Equivalent calculations appear almost
    # verbatim in published COBE Data Analysis Software, available at
    # http://lambda.gsfc.nasa.gov/product/cobe/cgis.cfm
    # (brush up on your FORTRAN and download +cgis-for.tar.gz+).
    #
    # Of interest: a user of the the GIS StackExchange, allegedly
    # Kenneth Chan, the original designer of this projection, had this
    # to say on this particular topic:
    #
    #   "Alex, When you get my report, you will notice that my direct
    #   and inverse mappings are accurate to 4 or 5 significant
    #   figures.  Laubscher changed my coefficients in his report.  A
    #   comparison reveals that the transformations given in
    #   Calabretta's paper do not bear any resemblance to mine.  The
    #   coefficients are not from my original report but are based on
    #   Laubscher's report.  Because of this, Calabretta states that
    #   my transformations are accurate to 1%.  Moreover, it is also
    #   stated that the code disagrees with the formulas.  Please bear
    #   this in mind. My advice is to go by the report in the original
    #   for [...]"
    #
    # (link to the thread in the module doc above)
    #
    # So our coefficients may not be Chan's - ours are indeed the ones
    # in the Calabretta paper.  We are trying to contact Ken Chan for
    # clarification... and/or a copy of his 1975 paper, that would be
    # brilliant.  On the other hand, this is the exact same
    # computation done by actual COBE software, apparently, so it
    # probably matches their results.  Go figure.
    #
    # In our own tests of this implementation, when transforming (χ,ψ)
    # to (x,y) and back to (χ',ψ'), where the domain of all four
    # variables is -1.0 to 1.0, we've found the mean closure error
    # (mean distance from point (χ,ψ) to point (χ',ψ')) to be
    # 4.152E-05, with a standard deviation of 3.72E-05, and a maximum
    # error of 2.33E-04 in small regions around the origin and
    # corners.
    #
    # To put this in perspective: if you were mapping the Earth, then
    # the domain of this transformation is a cube face, then the mean
    # closure error would be around 415 metres, with a standard
    # deviation of 372 m, and small zones of high error near the cube
    # face centres where it can get as bad as 2.3 km (very very quick
    # approximation there, don't quote me on those figures).  So aye,
    # we could use more precision.
    #
    # There is code in the +extras+ directory to compute the error
    # distribution, and even generate a picture showing the areas of
    # low and high error on the plane.  Peek there if you're curious.
    #
    # @see inverse_distort
    def self.forward_distort(chi, psi)
      chi2 = chi**2
      chi3 = chi**3
      psi2 = psi**2
      omchi2 = 1.0 - chi2
      chi*(1.37484847732 - 0.37484847732*chi2) +
        chi*psi2*omchi2*(-0.13161671474 +
                         0.136486206721*chi2 +
                         (1.0 - psi2) *
                         (0.141189631152 +
                          psi2*(-0.281528535557 + 0.106959469314*psi2) +
                          chi2*(0.0809701286525 +
                                0.15384112876*psi2 -
                                0.178251207466*chi2))) +
        chi3*omchi2*(-0.159596235474 -
                     (omchi2 * (0.0759196200467 - 0.0217762490699*chi2)))
    end

    # This performs the inverse curvilinear transformation of
    # coordinates on a cube face, from the CSC to the basic tangential
    # projection.  Specifically, the function computes the original
    # cartesian coordinate χ produced by tangential projection, from
    # the adjusted coordinates x,y.  To compute the coordinate ψ,
    # evaluate again for y,x.
    #
    # @see forward_distort Notes regarding accuracy in the
    #   documentation of forward_distort.
    def self.inverse_distort(x, y)
      # This is the sum Σ, from j=0 to 6, of the sum Σ, from i=0 to 6-j,
      # of Pij * (X**(2*i)) * (Y**(2*j))

      # We unroll.
      x2  = x*x
      x4  = x**4
      x6  = x**6
      x8  = x**8
      x10 = x**10
      x12 = x**12
      y2  = y*y
      y4  = y**4
      y6  = y**6
      y8  = y**8
      y10 = y**10
      y12 = y**12

      x + x*(1 - x2) *
        (-0.27292696 - 0.07629969 * x2 -
         0.22797056 * x4 + 0.54852384 * x6 -
         0.62930065 * x8 + 0.25795794 * x10 +
         0.02584375 * x12 - 0.02819452 * y2 -
         0.01471565 * x2 * y2 + 0.48051509 * x4 * y2 -
         1.74114454 * x6 * y2 + 1.71547508 * x8 * y2 -
         0.53022337 * x10 * y2 + 0.27058160 * y4 -
         0.56800938 * x2 * y4 + 0.30803317 * x4 * y4 +
         0.98938102 * x6 * y4 - 0.83180469 * x8 * y4 -
         0.60441560 * y6 + 1.50880086 * x2 * y6 -
         0.93678576 * x4 * y6 + 0.08693841 * x6 * y6 +
         0.93412077 * y8 - 1.41601920 * x2 * y8 +
         0.33887446 * x4 * y8 - 0.63915306 * y10 +
         0.52032238 * x2 * y10 + 0.14381585 * y12)
    end

  end # module CSC
end #module QuadSphere
