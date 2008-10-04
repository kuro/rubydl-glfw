#!/usr/bin/env ruby

$: << File.dirname(__FILE__) + '/../lib'

require 'glfw'
include GLFW

require 'opengl'
include Gl

glfwInit
glfwOpenWindow(640, 480)
glfwSetWindowTitle 'ruby-glfw'

frames = 0
t0 = glfwGetTime

loop do
  t = glfwGetTime

  x, y = glfwGetMousePos

  if (t-t0) > 1.0 || frames == 0
    fps = frames.to_f / (t-t0)
    glfwSetWindowTitle("ruby-glfw: spinning triangle (%0.1f fps)" % fps)
    t0 = t
    frames = 0
  end
  frames += 1

  width, height = glfwGetWindowSize
  height = height > 0 ? height : 1
  # Set viewport
  glViewport(0, 0, width.to_f, height.to_f)
  # Clear color buffer
  glClearColor(0.0, 0.0, 0.0, 0.0)
  glClear(GL_COLOR_BUFFER_BIT)
  # Select and setup the projection matrix
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity
  gluPerspective(65.0, width.to_f/height.to_f, 1.0, 100.0)
  # Select and setup the modelview matrix
  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity
  gluLookAt(0.0,  1.0, 0.0,   # Eye-position
            0.0, 20.0, 0.0,   # View-point
            0.0,  0.0, 1.0)   # Up-vector

  glTranslatef(0.0, 14.0, 0.0)
  glRotatef(0.3*x + 100.0*t, 0.0, 0.0, 1.0)
  glBegin(GL_TRIANGLES)
  glColor3f   1.0, 0.0,  0.0
  glVertex3f -5.0, 0.0, -4.0
  glColor3f   0.0, 1.0,  0.0
  glVertex3f  5.0, 0.0, -4.0
  glColor3f   0.0, 0.0,  1.0
  glVertex3f  0.0, 0.0,  6.0
  glEnd

  glfwSwapBuffers
  glfwGetKey(GLFW_KEY_ESC).zero? or break
  glfwGetWindowParam(GLFW_OPENED).zero? and break

end

glfwCloseWindow
glfwTerminate
