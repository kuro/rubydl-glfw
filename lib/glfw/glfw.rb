#
# Copyright 2008 Blanton Black
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'dl'
require 'dl/import'

require 'glfw/enums'

module GLFW

  class Error < RuntimeError
  end

  GLFWvidmode = Struct.new(:width, :height, :red_bits, :blue_bits, :green_bits)
  GLFWimage = Struct.new(:width, :height, :format, :bytes_per_pixel, :data)

  LIB = case RUBY_PLATFORM
        when /linux/
          DL::dlopen('libglfw.so')
        else
          raise Error, 'unsupported platform'
        end


  function_map = %w/
    glfwInit                     I
    glfwTerminate                0
    glfwGetVersion               0iii
    glfwOpenWindow               IIIIIIIIII
    glfwOpenWindowHint           0II
    glfwCloseWindow              0
    glfwSetWindowTitle           0S
    glfwGetWindowSize            0ii
    glfwSetWindowSize            0II
    glfwSetWindowPos             0II
    glfwIconifyWindow            0
    glfwRestoreWindow            0
    glfwSwapBuffers              0
    glfwSwapInterval             0I
    glfwGetWindowParam           II
    glfwSetWindowSizeCallback    0P
    glfwSetWindowCloseCallback   0P
    glfwSetWindowRefreshCallback 0P
    glfwGetVideoModes            IPI
    glfwGetDesktopMode           0P
    glfwPollEvents               0
    glfwWaitEvents               0
    glfwGetKey                   II
    glfwGetMouseButton           II
    glfwGetMousePos              0ii
    glfwSetMousePos              0II
    glfwGetMouseWheel            I
    glfwSetMouseWheel            0I
    glfwSetKeyCallback           0P
    glfwSetCharCallback          0P
    glfwSetMouseButtonCallback   0P
    glfwSetMousePosCallback      0P
    glfwSetMouseWheelCallback    0P
    glfwGetJoystickParam         III
    glfwGetJoystickPos           IIaI
    glfwGetJoystickButtons       IIaI
    glfwGetTime                  D
    glfwSetTime                  0D
    glfwSleep                    0D
    glfwExtensionSupported       IS
    glfwGetProcAddress           PS
    glfwGetGLVersion             0iii
    glfwCreateThread             IPP
    glfwDestroyThread            0I
    glfwWaitThread               III
    glfwGetThreadID              I
    glfwCreateMutex              P
    glfwDestroyMutex             0P
    glfwLockMutex                0P
    glfwUnlockMutex              0P
    glfwCreateCond               P
    glfwDestroyCond              0P
    glfwWaitCond                 0PPD
    glfwSignalCond               0P
    glfwBroadcastCond            0P
    glfwGetNumberOfProcessors    I
    glfwEnable                   0I
    glfwDisable                  0I
    glfwReadImage                ISPI
    glfwReadMemoryImage          IPLPI
    glfwFreeImage                0P
    glfwLoadTexture2D            ISI
    glfwLoadMemoryTexture2D      IPLI
    glfwLoadTextureImage2D       IPI
    /
  function_map = Hash[*function_map]
  function_map.each do |func, sig|
    const_name = func.gsub(/([a-z])([0-9A-Z])/, '\1_\2').upcase
    self.const_set const_name, LIB[func, sig]
  end

  def glfw_call (target, *args)
    ret, rs = target.call(*args)
    yield rs if block_given?
    return ret
  end

  def glfwInit
    glfw_call(GLFW_INIT)
    self
  end
  def glfwTerminate
    glfw_call(GLFW_TERMINATE)
    self
  end
  def glfwGetVersion
    a = b = c = 0
    glfw_call(GLFW_GET_VERSION, a, b, c) do |a, b, c|
    end
    return [a, b, c]
  end

  # window handling
  def glfwOpenWindow(width = 0, height = 0,
                     redbits = 8, greenbits = 8, bluebits = 8, alphabits = 8,
                     depthbits = 24, stencilbits = 8, mode = GLFW_WINDOW)
    glfw_call(GLFW_OPEN_WINDOW,
                width, height, redbits, greenbits, bluebits, alphabits,
                depthbits, stencilbits, mode)
    self
  end
  def glfwOpenWindowHint(targe, hint)
    glfw_call(GLFW_OPEN_WINDOW_HINT, target, hint)
    self
  end
  def glfwCloseWindow
    glfw_call(GLFW_CLOSE_WINDOW)
    self
  end
  def glfwSetWindowTitle(title)
    glfw_call(GLFW_SET_WINDOW_TITLE, title)
    self
  end
  def glfwGetWindowSize
    width = height = 0
    retval = nil
    glfw_call(GLFW_GET_WINDOW_SIZE, width, height) do |width, height|
      retval = [width, height]
    end
    return retval
  end
  def glfwSetWindowSize(width, height)
    glfw_call(GLFW_SET_WINDOW_SIZE, width, height)
    self
  end
  def glfwSetWindowPos(x, y)
    glfw_call(GLFW_SET_WINDOW_POS, x, y)
    self
  end
  def glfwIconifyWindow
    glfw_call(GLFW_ICONIFY_WINDOW)
    self
  end
  def glfwRestoreWindow
    glfw_call(GLFW_RESTORE_WINDOW)
    self
  end
  def glfwSwapBuffers
    glfw_call(GLFW_SWAP_BUFFERS)
    self
  end
  def glfwSwapInterval(interval)
    glfw_call(GLFW_SWAP_INTERVAL, interval)
    self
  end
  def glfwGetWindowParam(param)
    return glfw_call(GLFW_GET_WINDOW_PARAM, param)
  end
  def glfwSetWindowSizeCallback(&block)
    glfw_call(GLFW_SET_WINDOW_SIZE_CALLBACK, DL.callback('0II', block))
    self
  end
  # block must return true to close
  def glfwSetWindowCloseCallback(&block)
    cb = DL.callback('I') do
      block.call ? 1 : 0
    end
    glfw_call(GLFW_SET_WINDOW_CLOSE_CALLBACK, cb)
    self
  end
  def glfwSetWindowRefreshCallback(&block)
    glfw_call(GLFW_SET_WINDOW_REFRESH_CALLBACK, DL.callback('0', block))
    self
  end

  # Video mode functions
  def glfwGetVideoModes(maxcount = 24)
    struct_size = DL.sizeof('IIIII')
    list = DL.malloc(struct_size * maxcount)
    count = glfw_call(GLFW_GET_VIDEO_MODES, list, maxcount)
    values = list.to_a('I', count * struct_size)
    retval = Array.new
    count.times do
      vm = GLFWvidmode.new
      vm.width      = values.shift
      vm.height     = values.shift
      vm.red_bits   = values.shift
      vm.blue_bits  = values.shift
      vm.green_bits = values.shift
      retval << vm
    end
    return retval
  end
  def glfwGetDesktopMode
    ptr = Array.new(5, 0).pack('iiiii').to_ptr
    glfw_call(GLFW_GET_DESKTOP_MODE, ptr)
    return GLFWvidmode.new(*ptr.to_a('I', 5))
  end

  # Input handling
  def glfwPollEvents
    glfw_call(GLFW_POLL_EVENTS)
    self
  end
  def glfwWaitEvents
    glfw_call(GLFW_WAIT_EVENTS)
    self
  end
  def glfwGetKey(key)
    return glfw_call(GLFW_GET_KEY, key)
  end
  def glfwGetMouseButton(button)
    return glfw_call(GLFW_GET_MOUSE_BUTTON, key)
  end
  def glfwGetMousePos
    x = y = 0
    retval = nil
    glfw_call(GLFW_GET_MOUSE_POS, x, y) do |x, y|
      retval = [x, y]
    end
    return retval
  end
  def glfwSetMousePos(xpos, ypos)
    glfw_call(GLFW_SET_MOUSE_POS, xpos, ypos)
    self
  end
  def glfwGetMouseWheel
    return glfw_call(GLFW_GET_MOUSE_WHEEL)
  end
  def glfwSetMouseWheel(pos)
    glfw_call(GLFW_SET_MOUSE_WHEEL, pos)
    self
  end
  # key, state
  def glfwSetKeyCallback(&block)
    glfw_call(GLFW_SET_KEY_CALLBACK, DL.callback('0II', block))
    self
  end
  def glfwSetCharCallback(&block)
    glfw_call(GLFW_SET_CHAR_CALLBACK, DL.callback('0II', block))
    self
  end
  def glfwSetMouseButtonCallback(&block)
    glfw_call(GLFW_SET_MOUSE_BUTTON_CALLBACK, DL.callback('0II', block))
    self
  end
  def glfwSetMousePosCallback(flip_y = true, &block)
    win_x, win_y = glfwGetWindowSize
    cb = DL.callback('0II') do |x, y|
      yield x, flip_y ? win_y - y - 1 : y
    end
    glfw_call(GLFW_SET_MOUSE_POS_CALLBACK, cb)
    self
  end
  # direction
  def glfwSetMouseWheelCallback(&block)
    glfw_call(GLFW_SET_MOUSE_WHEEL_CALLBACK, DL.callback('0I', block))
    self
  end

  # Joystick input
  def glfwGetJoystickParam(joy, param)
    return glfw_call(GLFW_GET_JOYSTICK_PARAM, joy, param)
  end
  def glfwGetJoystickPos(joy, numaxes)
    a = Array.new(numaxes, 0.0)
    r = glfw_call(GLFW_GET_JOYSTICK_POS, joy, a, numaxes) do |joy, a, n|
    end
    raise Error, 'glfw error' if r == 0
    return a.to_a('F', numaxes)
  end
  def glfwGetJoystickButtons(joy, numbuttons)
    buttons = Array.new(numbuttons, 0)
    retval = nil
    r = glfw_call(GLFW_GET_JOYSTICK_BUTTONS,
                  joy, buttons, numbuttons) do |joy, buttons, n|
    end
    raise Error, 'glfw error' if r == 0
    return buttons.to_a('C', numbuttons)
  end

  # Time
  def glfwGetTime
    return glfw_call(GLFW_GET_TIME)
  end
  def glfwSetTime(time)
    glfw_call(GLFW_SET_TIME, time)
    self
  end
  def glfwSleep(time)
    glfw_call(GLFW_SLEEP, time.to_f)
    self
  end

  # Extension support (glfwGetProcAddress omitted)
  def glfwExtensionSupported(extension)
    return glfw_call(GLFW_EXTENSION_SUPPORTED, extension) == 1
  end
  def glfwGetGLVersion
    a = b = c = 0xd00d
    retval = nil
    glfw_call(GLFW_GET_GLVERSION, a, b, c) do |a, b, c|
      retval = [a, b, c]
    end
    return retval
  end

  # Threading support
  def glfwCreateThread(fun, arg)
    # TODO write me
    self
  end
  def glfwDestroyThread(id)
    # TODO write me
    self
  end
  def glfwWaitThread(id, waitmode)
    # TODO write me
    self
  end
  def glfwGetThreadID
    return glfw_call(GLFW_GET_THREAD_ID)
  end
  def glfwCreateMutex
    # TODO write me
    self
  end
  def glfwDestroyMutex(mutex)
    # TODO write me
    self
  end
  def glfwLockMutex(mutex)
    # TODO write me
    self
  end
  def glfwUnlockMutex(mutex)
    # TODO write me
    self
  end
  def glfwCreateCond
    # TODO write me
    self
  end
  def glfwDestroyCond(cond)
    # TODO write me
    self
  end
  def glfwWaitCond(cond, mutex, timeout)
    # TODO write me
    self
  end
  def glfwSignalCond(cond)
    # TODO write me
    self
  end
  def glfwBroadcastCond(cond)
    # TODO write me
    self
  end
  def glfwGetNumberOfProcessors
    return glfw_call(GLFW_GET_NUMBER_OF_PROCESSORS)
  end

  # Enable/disable functions
  def glfwEnable(token)
    glfw_call(GLFW_ENABLE, token)
    self
  end
  def glfwDisable(token)
    glfw_call(GLFW_DISABLE, token)
    self
  end

  # Image/texture I/O support
  def glfwReadImage(fname, flags = 0)
    ptr = DL::PtrData.malloc(DL.sizeof('IIIIP'))
    ptr.struct!('IIIIP', :width, :height, :format, :bytes_per_pixel, :data_ptr)

    r = glfw_call(GLFW_READ_IMAGE, fname, ptr, flags)

    raise Error, 'glfw error' if r == 0

    ptr[:data_ptr].size = ptr[:width] * ptr[:height] * ptr[:bytes_per_pixel]
    image = GLFWimage.new(ptr[:width], ptr[:height], ptr[:format],
                          ptr[:bytes_per_pixel], ptr[:data_ptr].to_str)

    glfw_call(GLFW_FREE_IMAGE, ptr)

    return image
  end
  def glfwReadMemoryImage(data, flags = 0)
    ptr = DL::PtrData.malloc(DL.sizeof('IIIIP'))
    ptr.struct!('IIIIP', :width, :height, :format, :bytes_per_pixel, :data_ptr)

    r = glfw_call(GLFW_READ_MEMORY_IMAGE, data, data.size, ptr, flags)

    raise Error, 'glfw error' if r == 0

    ptr[:data_ptr].size = ptr[:width] * ptr[:height] * ptr[:bytes_per_pixel]
    image = GLFWimage.new(ptr[:width], ptr[:height], ptr[:format],
                          ptr[:bytes_per_pixel], ptr[:data_ptr].to_str)

    glfw_call(GLFW_FREE_IMAGE, ptr)

    return image
  end
  def glfwLoadTexture2D(name, flags = 0)
    glfw_call(GLFW_LOAD_TEXTURE_2D, name, flags)
    self
  end
  def glfwLoadMemoryTexture2D(data, flags = 0)
    r = glfw_call(GLFW_LOAD_MEMORY_TEXTURE_2D, data.to_ptr, data.size, flags)
    raise Error, 'glfw error' if r == 0
    self
  end
  def glfwLoadTextureImage2D(img, flags = 0)
    ptr = DL::PtrData.malloc(DL.sizeof('IIIIS'))
    ptr.struct!('IIIIS', :width, :height, :format, :bytes_per_pixel, :data_ptr)

    ptr[:width]           = img.width
    ptr[:height]          = img.height
    ptr[:format]          = img.format
    ptr[:bytes_per_pixel] = img.bytes_per_pixel
    ptr[:data_ptr]        = img.data.to_ptr

    r = glfw_call(GLFW_LOAD_TEXTURE_IMAGE_2D, ptr, flags)
    raise Error, 'glfw error' if r == 0
    self
  end

end # module GLFW
