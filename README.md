QuadSphere
==========

By César Rincón

QuadSphere is a Ruby implementation of a mapping of the sphere onto
the faces of a cube, that preserves areas, and produces no
singularities at the poles or elsewhere.  This is useful for storing
spherical data in raster form: then you can integrate directly on the
face planes, without having to map your data back to the original
sphere.

The particular transformation is the [COBE Quadrilateralized Spherical
Cube][1], proposed in 1975 by Chan and O'Neill, and used extensively
by the Cosmic Background Explorer project.  Note specifically that
this is _not_ the projection by Laubscher and O'Neill, 1976, which is
non-differentiable along the diagonals.  Also note that only the
spherical projection is implemented, not the binning scheme - we don't
deal with pixels at all.

As Chan's original report is not readily available, this
implementation is based on formulae found in FITS WCS documents.
Specifically: "Representations of celestial coordinates in FITS (Paper
II)", Calabretta, M. R., and Greisen, E. W., <i>Astronomy &
Astrophysics</i>, 395, 1077-1122, 2002.  This is [available from the
FITS Support Office at NASA/GSFC][2].  Mind the possible implications
of this on the accuracy of the transformation, discussed in the
documentation of {QuadSphere::CSC.forward_distort}.

Examples and stuff to follow; see the YARD-generated docs for the time
being.

[1]: http://lambda.gsfc.nasa.gov/product/cobe/skymap_info_new.cfm
[2]: http://fits.gsfc.nasa.gov/fits_wcs.html
