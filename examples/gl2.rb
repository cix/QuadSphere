# A shaded view of the CSC projection.  You need OpenGL for this.

require 'quad_sphere/csc'
require 'opengl'

class CSCShadedApp

  WINDOW_SIZE = 480

  # How many subdivisions of each cube face.  Can be raised for
  # smoother shading, at the cost of model complexity.
  FACE_SUBDIV = 10

  def run
    @ang1 = 0
    @ang2 = 0
    @ang3 = 0

    glutInit
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH)
    glutInitWindowSize(WINDOW_SIZE, WINDOW_SIZE) 
    glutCreateWindow('CSC')

    glEnable(GL_LIGHTING)
    glEnable(GL_LIGHT0)
    glEnable(GL_DEPTH_TEST)
    glEnable(GL_CULL_FACE)
    glFrontFace(GL_CW)
    glClearColor(0.5, 0.5, 0.5, 0.0)
    setup_model

    glutDisplayFunc(method :display) 
    glutReshapeFunc(method :reshape)
    glutKeyboardFunc(method :keyboard)

    # And run.
    glutMainLoop()
  end

  private

  def setup_model
    glGenLists(1)
    glNewList(1, GL_COMPILE)

    # The cube faces, and the colour we want each:
    faces = [ [ QuadSphere::TOP_FACE,    [ 0.9, 0.25,  0.25, 1.0 ] ],  # red
              [ QuadSphere::FRONT_FACE,  [ 0.25, 0.25, 0.9,  1.0 ] ],  # blue
              [ QuadSphere::EAST_FACE,   [ 0.25, 0.9,  0.25, 1.0 ] ],  # green
              [ QuadSphere::BACK_FACE,   [ 0.9,  0.9,  0.25, 1.0 ] ],  # yellow
              [ QuadSphere::WEST_FACE,   [ 0.25, 0.9,  0.9,  1.0 ] ],  #cyan
              [ QuadSphere::BOTTOM_FACE, [ 0.9,  0.25, 0.9,  1.0 ] ] ] #magenta

    faces.each do |face, colour|
      glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, colour);
      # Calculate all the vertices we'll use for this face...
      vertices = grid(face, FACE_SUBDIV)
      # ... and arrange them in triangle strips:
      mesh2strips(FACE_SUBDIV, vertices)
    end

    glEndList
  end

  def reshape(w, h)
    glViewport(0, 0,  w,  h) 
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    gluPerspective(45.0,  w.to_f / h.to_f, 1.0, 20.0)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()
    gluLookAt(3.2,0,0, 0,0,0, 0,0,1)

    # Add a light.
    glPushMatrix()
    glTranslate(2.5,-0.8,0.8);
    glLightfv(GL_LIGHT0, GL_POSITION, [0, 0, 0, 1])
    glPopMatrix()
  end

  def display
    # XXX - maybe it'd be more efficient to only clear the depth
    # buffer if we moved the model or camera?
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    # Rotate and draw the model.
    glPushMatrix()
    glRotate(@ang1, 0, 0, 1)
    glRotate(@ang2, 1, 0, 0)
    glRotate(@ang3, 0, 1, 0)
    glCallList(1)
    glPopMatrix()

    # Done.
    glutSwapBuffers()
  end

  def keyboard(key, x, y)
    case  (key)
    when ?s
      @ang1 = (@ang1 + 5) % 360
      glutPostRedisplay()
    when ?a
      @ang1 = (@ang1 - 5) % 360
      glutPostRedisplay()
    when ?w
      @ang2 = (@ang2 + 5) % 360
      glutPostRedisplay()
    when ?q
      @ang2 = (@ang2 - 5) % 360
      glutPostRedisplay()
    when ?x
      @ang3 = (@ang3 + 5) % 360
      glutPostRedisplay()
    when ?z
      @ang3 = (@ang3 - 5) % 360
      glutPostRedisplay()
    when ?r
      @ang1 = @ang2 = @ang3 = 0
      glutPostRedisplay()
    when ?\e, ?Q
      exit(0)
    end
  end

  # Create a NxN grid of points on a face of the cube.  Note that this
  # will generate (N+1)*(N+1) points.
  #
  # Each point is projected on the sphere and stored in an array.  Note
  # that all these are points on the unit sphere, and so their distance
  # to the origin is 1, and so each point can be used as its own normal.
  def grid(face, n)
    dx = 2.0/n
    dy = 2.0/n
    a = Array.new
    n += 1

    n.times do |j|
      y = -1.0 + j*dy
      n.times do |i|
        x = -1.0 + i*dx
        lon, lat = QuadSphere::CSC.inverse(face, x, y)
        sx = Math::cos(lat) * Math::cos(lon)
        sy = Math::cos(lat) * Math::sin(lon)
        sz = Math::sin(lat)
        a << [sx,sy,sz]
      end
    end

    a
  end

  # p grid(0, 3)
  #
  # Create triangle strips to represent a NxN mesh.  The given array
  # should then contain (N+1)**2 points, arranged as N+1 rows of N+1
  # points.

  def mesh2strips(n,a)
    dx = 2.0/n
    dy = 2.0/n
    row = n+1

    n.times do |j|
      glBegin(GL_TRIANGLE_STRIP)
      rowi = j*row
      row.times do |x|
        add_vertex(a[rowi+x])
        add_vertex(a[rowi+row+x])
      end
      glEnd
    end
  end

  def add_vertex(v)
    glNormal3fv(v)
    glVertex3fv(v)
  end

end

CSCShadedApp.new.run
