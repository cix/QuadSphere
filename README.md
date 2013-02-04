QuadSphere
==========

QuadSphere is a small Ruby gem that implements a projection of
spherical to planar coordinates, called the _quadrilateralised
spherical cube_.  It is useful for handling geographic or astronomical
data, or for general mapmaking.

![Quad sphere grid picture][9]

Background
----------

The quadrilateralised spherical cube, or "quad sphere" for short, is a
projection of the sphere onto the sides of an inscribed cube, where
the distortion of the tangential (gnomonic) projection is compensated
by a further curvilinear transformation.  This makes it approximately
equal-area, with no singularities at the poles, or anywhere;
distortion is moderate over the entire sphere.  This makes it
well-suited for storing data collected on a spherical surface, like
the Earth or the celestial sphere, as rasters of pixels: each
equal-area pixel then corresponds to an equal-area region on the
sphere, so numerical analysis can be performed on the pixels rather
than the original surface.

This projection was proposed in 1975 in the report "Feasibility Study
of a Quadrilateralized Spherical Cube Earth Data Base", by F. K. Chan
and E. M. O'Neill ([citation entry][6]), and it was used to hold data
for the Cosmic Background Explorer project (COBE).  The quad sphere,
along with a binning scheme for storing pixels along a Z-order curve,
became the [COBE Sky Cube][1] format.

This is not a Sky Cube reader, though — neither the binning scheme nor
the FITS format are implemented here.  You should use a [FITS][5] library
if you need to read COBE data.  And, for current astronomical work,
the quadrilateralised spherical cube projection has been superseded by
[HEALPix][3], so you should use that instead.  This implementation was
only created because this author had a very specific need involving
storage and manipulation of spherical data — for a game, no less.

Note also that this is _not_ the projection by Laubscher and O'Neill,
1976, which is similar to this but introduces singularities, making it
non-differentiable along the diagonals.

As Chan's original report is not readily available, this
implementation is based on formulae found in [FITS WCS documents][2].
Specifically: "Representations of celestial coordinates in FITS (Paper
II)", Calabretta, M. R., and Greisen, E. W., _Astronomy &
Astrophysics_, 395, 1077-1122, 2002.

Finally, bear in mind that this is not an exact projection, it's
accuracy is limited — see discussion in the documentation of
[`QuadSphere::CSC.forward_distort`][8].

Examples and stuff to follow; see the [API reference][7] for the time
being.

[1]: http://lambda.gsfc.nasa.gov/product/cobe/skymap_info_new.cfm
[2]: http://fits.gsfc.nasa.gov/fits_wcs.html
[3]: http://healpix.jpl.nasa.gov/
[4]: http://lambda.gsfc.nasa.gov/product/cobe/skymap_info_new.cfm
[5]: http://en.wikipedia.org/wiki/FITS
[6]: http://www.dtic.mil/docs/citations/ADA010232
[7]: http://rubydoc.info/github/crinc/QuadSphere/master/frames
[8]: http://rubydoc.info/github/crinc/QuadSphere/master/QuadSphere/CSC.forward_distort
[9]: https://raw.github.com/crinc/QuadSphere/master/examples/grid.png
