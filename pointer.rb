require 'uinput/device'

class VirtualPointer
  attr_reader :device, :device_abs, :device_mt, :display
  
  def initialize(display=":0")
    @display = display
  end
  
  def create_devices
#    puts "create " + @display.to_s
    display = @display

    ## Absolute pointer
    @device_abs = Uinput::Device.new do
      self.name =  "Virtual absolute device on " + display
      self.type = LinuxInput::BUS_VIRTUAL
      self.add_event(:EV_SYN)
      self.add_event(:EV_KEY)
      self.add_key(:BTN_TOUCH)
      self.add_event(:EV_ABS)

      self.add_abs(:ABS_X, 0,0,2048)
      self.add_abs(:ABS_Y, 0,0,2048)
      self.add_abs_event(:ABS_X)
      self.add_abs_event(:ABS_Y)

      self.set_prop(:INPUT_PROP_POINTER)
      self.set_prop(:INPUT_PROP_DIRECT)
    end

    ## MultiTouch pointer
    @device_mt = Uinput::Device.new do
      self.name = "Virtual multitouch device on " + display
      self.type = LinuxInput::BUS_VIRTUAL

      self.add_event(:EV_SYN)
      self.add_event(:EV_KEY)
      
      #    self.add_key(:BTN_TOUCH)
      self.add_event(:EV_ABS)
      self.add_event(:EV_REL)
      
      self.add_abs(:ABS_MT_SLOT, 0, 0, 10) ## 10 points
      
      self.add_abs(:ABS_MT_POSITION_X, 0,0, 2048)
      self.add_abs(:ABS_MT_POSITION_Y, 0,0, 2048)
      self.add_abs(:ABS_MT_TRACKING_ID, 0,0, 65535)
      # self.add_abs(:ABS_MT_TOUCH_MAJOR, 0,0,15) 
      # self.add_abs(:ABS_MT_PRESSURE, 0,0, 255)
      
      self.add_abs_event(:ABS_MT_SLOT)
      self.add_abs_event(:ABS_MT_POSITION_X)
      self.add_abs_event(:ABS_MT_POSITION_Y)
      self.add_abs_event(:ABS_MT_TRACKING_ID)
      
      # self.add_abs_event(:ABS_MT_TOUCH_MAJOR)
      # self.add_abs_event(:ABS_MT_PRESSURE)
      
      self.set_prop(:INPUT_PROP_POINTER)
      self.set_prop(:INPUT_PROP_DIRECT)
    end
    
    
    
    @device = Uinput::Device.new do
      self.name = "Virtual mouse device on " + display
      self.type = LinuxInput::BUS_VIRTUAL
      # self.add_key(:KEY_A)
      
      self.add_event(:EV_REL)
      self.add_event(:EV_KEY)
      self.add_event(:EV_SYN)
      
      ## Test with ABS
      self.add_event(:EV_ABS)
      self.add_event(:ABS_X)
      self.add_event(:ABS_Y)
      
      self.add_key(:BTN_LEFT)
      self.add_key(:BTN_RIGHT)
      
      self.add_rel_event(:REL_X)
      self.add_rel_event(:REL_Y)
    end
  end

  # def id  ## Not reliable
  #   return @device.dev_path.split("event")[1].to_i
  # end

  def name; "Virtual mouse device on #{@display}"; end
  def name_abs; "Virtual absolute device on #{@display}"; end
  def name_mt; "Virtual multitouch device on #{@display}"; end

  def names ; [name, name_abs, name_mt] ; end
  
  def delete
    @device.destroy
    @device_abs.destroy
    @device_mt.destroy
  end

  def press_left(press)

    v = press ? 0 : 1
    @device.send_event(:EV_KEY, :BTN_LEFT, v)
    @device.send_event(:EV_SYN, :SYN_REPORT)
  end
  def press_right(press)
    v = press ? 0 : 1
    @device.send_event(:EV_KEY, :BTN_RIGHT, v)
    @device.send_event(:EV_SYN, :SYN_REPORT)
  end
  
  def move(x,y)
    @device.send_event(:EV_REL, :REL_X, x)
    @device.send_event(:EV_REL, :REL_Y, y)
    @device.send_event(:EV_SYN, :SYN_REPORT)
  end

  def press_abs(x,y)
    @device_abs.send_event(:EV_KEY, :BTN_TOUCH , 1)
    @device_abs.send_event(:EV_ABS, :ABS_X , x)
    @device_abs.send_event(:EV_ABS, :ABS_Y , y)
    @device_abs.send_event(:EV_SYN, :SYN_REPORT)
  end

  def move_abs(x,y)
    @device_abs.send_event(:EV_ABS, :ABS_X , x)
    @device_abs.send_event(:EV_ABS, :ABS_Y , y)
    @device_abs.send_event(:EV_SYN, :SYN_REPORT)
  end

  def release_abs
    @device_abs.send_event(:EV_KEY, :BTN_TOUCH , 0)
    @device_abs.send_event(:EV_SYN, :SYN_REPORT)
  end

  def press_abs_mt(x,y, id, slot)
    @device_mt.send_event(:EV_ABS, :ABS_MT_SLOT, slot)
    @device_mt.send_event(:EV_ABS, :ABS_MT_TRACKING_ID, id)

    @device_mt.send_event(:EV_ABS, :ABS_MT_POSITION_X, x)
    @device_mt.send_event(:EV_ABS, :ABS_MT_POSITION_Y, y)
    @device_mt.send_event(:EV_SYN, :SYN_REPORT)
  end

  def move_abs_mt(x,y, slot)
    @device_mt.send_event(:EV_ABS, :ABS_MT_SLOT, slot)
    @device_mt.send_event(:EV_ABS, :ABS_MT_POSITION_X, x)
    @device_mt.send_event(:EV_ABS, :ABS_MT_POSITION_Y, y)
    @device_mt.send_event(:EV_SYN, :SYN_REPORT)
  end

  def release_abs_mt(slot)
    @device_mt.send_event(:EV_ABS, :ABS_MT_SLOT, 0)
    @device_mt.send_event(:EV_ABS, :ABS_MT_TRACKING_ID, -1)
    @device_mt.send_event(:EV_SYN, :SYN_REPORT)
  end

  def release_abs_mt_purge
    (0...10).each {|i| release_abs_mt(i) }
  end
  
  
  def unload_on(display)

  end

  def load_on(display)

  end
end
