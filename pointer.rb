require 'uinput/device'

class VirtualPointer
  attr_reader :device, :display
  
  def initialize(display=":0")
    @display = display
  end
  
  def create_device
#    puts "create " + @display.to_s
    display = @display
    
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
  
  def delete
    @device.destroy
  end

  def move(x,y)
    device.send_event(:EV_REL, :REL_X, x)
    device.send_event(:EV_REL, :REL_Y, y)
    device.send_event(:EV_SYN, :SYN_REPORT)
  end

  
  def unload_on(display)

  end

  def load_on(display)

  end
end
