# -*- coding: utf-8 -*-

module QuadSphere

  # Implements the tangential spherical cube projection. 
  #
  # In this projection, points on the sphere are projected from the
  # centre of the sphere onto the six faces of an inscribed cube.
  # Thus, the projection consists of six planar faces, each of which
  # is a gnomonic projection of a portion of the sphere.
  #
  # This module exists solely because the CSC projection is a
  # distortion of the mapping produced by a tangential projection.
  # Thus, the forward and inverse computations here are required, but
  # they have been segregated on the oft chance that they could be
  # useful on their own.
  #
  # @see http://en.wikipedia.org/wiki/Gnomonic_projection
  #   Gnomonic projection at Wikipedia.
  #
  # @author Cesar Rincon
  module Tangential

    # Information for each face.  Faces are given in the order: top,
    # front, left, back, right, bottom.
    #
    # These procedures rearrange the direction cosines as appropriate
    # for the face we're projecting.  The 3 values returned are ξ, η,
    # and ζ.
    FORWARD_PARAMETERS =
      [ Proc.new{ |l, m, n| [  m, -l,  n ] },
        Proc.new{ |l, m, n| [  m,  n,  l ] },
        Proc.new{ |l, m, n| [ -l,  n,  m ] },
        Proc.new{ |l, m, n| [ -m,  n, -l ] },
        Proc.new{ |l, m, n| [  l,  n, -m ] },
        Proc.new{ |l, m, n| [  m,  l, -n ] } ]
    private_constant :FORWARD_PARAMETERS \
      if self.respond_to?(:private_constant) # don't die for this in 1.8

    # Computes the projection of a point on the surface of the sphere,
    # given in spherical coordinates (φ,θ), to a point of cartesian
    # coordinates (χ,ψ) on one of the six cube faces.
    #
    # @param phi (Float) the φ angle in radians, from -π to π (or 0 to
    #   to 2π, if you like).  This is the azimuth, or longitude
    #   (spherical, not geodetic).
    # @param theta (Float) the θ angle in radians, from -π/2 to π/2.
    #   This is the elevation, or latitude (spherical, not geodetic).
    #
    # @return (Array) an array of three elements: the identifier of
    #   the face (see constants in {QuadSphere}), the χ coordinate of
    #   the projected point, and the ψ coordinate of the projected
    #   point.  Both coordinates will be in the range -1 to 1.
    def self.forward(phi, theta)
      # compute the direction cosines
      l = Math::cos(theta) * Math::cos(phi)
      m = Math::cos(theta) * Math::sin(phi)
      n = Math::sin(theta)

      # identify the face, and adjust our parameters.
      max, face = nil, -1
      [ n, l, m, -l, -m, -n ].each_with_index do |v, i|
        max, face = v, i if max.nil? || v > max
      end

      xi, eta, zeta = FORWARD_PARAMETERS[face].call(l,m,n)

      # Compute χ and ψ.
      # XXX - This will blow up if ζ is zero... can it happen?
      chi = xi / zeta
      psi = eta / zeta

      # Out of curiosity: why does Calabretta do this?
      # x = phi_c + Math::PI/4 * chi
      # y = theta_c + Math::PI/4 * psi

      [face,chi,psi]
    end

    # Information for each face.  Faces are given in the order:
    # top, front, left, back, right, bottom.
    #
    # These procedures return the direction cosines:
    #   1. l (cos(θ)*cos(φ))
    #   2. m (cos(θ)*sin(φ))
    #   3. n (sin(θ))
    INVERSE_PARAMETERS =
      [ Proc.new{ |xi, eta, zeta| [  -eta,    xi,  zeta ] },
        Proc.new{ |xi, eta, zeta| [  zeta,    xi,   eta ] },
        Proc.new{ |xi, eta, zeta| [   -xi,  zeta,   eta ] },
        Proc.new{ |xi, eta, zeta| [ -zeta,   -xi,   eta ] },
        Proc.new{ |xi, eta, zeta| [    xi, -zeta,   eta ] },
        Proc.new{ |xi, eta, zeta| [   eta,    xi, -zeta ] } ]
    private_constant :INVERSE_PARAMETERS \
      if self.respond_to?(:private_constant) # don't die for this in 1.8

    # Computes the projection of a point at cartesian coordinates
    # (χ,ψ) on one of the six cube faces, to a point at spherical
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
    # @param chi (Float) the χ coordinate of the point within the
    #   face, from -1.0 to 1.0.
    # @param psi (Float) the ψ coordinate of the point within the
    #   face, from -1.0 to 1.0.
    #
    # @return (Array) an array of two elements: the φ angle in radians
    #   (azimuth or longitude - spherical, not geodetic), from -π to
    #   π; and the θ angle in radians, from -π/2 to π/2 (elevation or
    #   latitude - spherical, not geodetic).
    def self.inverse(face, chi, psi)
      zeta = 1.0 / Math.sqrt(1.0 + chi**2 + psi**2)
      xi = chi*zeta
      eta = psi*zeta

      # get the direction cosines
      l, m, n = INVERSE_PARAMETERS[face].call(xi, eta, zeta)

      [ Math.atan2(m,l), Math.asin(n) ] # φ,θ
    end

  end # module Tangential
end # module QuadSphere
