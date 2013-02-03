QuadSphere
==========

QuadSphere is a small Ruby gem that implements a projection of
spherical to planar coordinates, called the "quadrilateralised
spherical cube".  This useful for handling geographic or astronomic
data, or for general mapmaking.

Background
----------

The quadrilateralised spherical cube, or "quad sphere" for short, is a
projection of the sphere onto the sides of an inscribed cube, using a
curvilinear transformation designed to preserve area.  It produces no
singularities at the poles or anywhere; distortion is moderate over
the entire sphere.  This makes it well-suited for storing data
collected on a spherical surface, like the Earth or the celestial
sphere, as rasters on six planes: each equal-area pixel corresponds to
an equal-area region on the sphere, so numerical analysis can be
performed on the pixels rather than the original surface.

This projection was proposed in 1975 in the report "Feasibility Study
of a Quadrilateralized Spherical Cube Earth Data Base", by F. K. Chan
and E. M. O'Neill and it was used to hold data for the Cosmic
Background Explorer project (COBE).  This projection, along with a
binning scheme for storing pixels along a Z-order curve, became the
"COBE Sky Cube" format.

This is not a Sky Cube reader, though — neither the binning scheme nor
the FITS format are implemented here.  You should use a FITS library
if you need to read COBE data.  And, for current astronomical work,
the quadrilateralised spherical cube projection has been superseded by
Healpix, so you should use that instead.  This implementation was only
created because this author had a very specific need involving storage
and manipulation of spherical data — for a game, no less.

Note also that this is _not_ the projection by Laubscher and O'Neill,
1976, which is non-differentiable along the diagonals.

As Chan's original report is not readily available, this
implementation is based on formulae found in FITS WCS documents.
Specifically: "Representations of celestial coordinates in FITS (Paper
II)", Calabretta, M. R., and Greisen, E. W., _Astronomy &
Astrophysics_, 395, 1077-1122, 2002.  This is [available from the FITS
Support Office at NASA/GSFC][2].

Finally, bear in mind that this is not an exact projection, it's
accuracy is limited — see discussion in the documentation of
`QuadSphere::CSC.forward_distort`.

Examples and stuff to follow; see the YARD-generated docs for the time
being.

[1]: http://lambda.gsfc.nasa.gov/product/cobe/skymap_info_new.cfm
[2]: http://fits.gsfc.nasa.gov/fits_wcs.html
