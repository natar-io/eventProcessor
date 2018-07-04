# coding: utf-8


# Event


# TODO:
# 0. OK Start an X server.
# 1. OK Listen to all the event devices.
# 2. OK remove all of the event devices, except the keyboard maybe.
# 3. OK Create a custom uinput for a mouse / MT.
# 4. OK Remove this custom uinput from the main X server.
# 5. Wait / stream custom events to the new X server. 
# 6. enable/disable the keyboard at will.
# 7. (optionnal - care about the keyboard map)


# ~~ Launch some apps on the X server ?
#

# Killing process
# 1. Destroy the uinput.
# 2. Disconnect the clients - send dying message. 
# 3. Destroy the X server.


require "redis"

require_relative 'xinput'
require_relative 'xserver'
require_relative 'pointer'


@main_display = ":0"
@main_input = InputList.new(@main_display)



# Display 
display = ":10"

## Create X server
server = XServer.new(display)
p = server.build
p.start

## Load dedicated input, disable existing devices
il = InputList.new(display)
il.load_all
il.disable_all

## Create new pointer
pointer = VirtualPointer.new(display)
device = pointer.create_devices

## Attach new pointer
il.enable_pointer(pointer)

## Detach from main X server
# @main_input.disable_pointer(pointer)

## move it...
pointer.move(10, 10)
pointer.move(20, 20)

## Move to absolute location.
pointer.press_abs(150, 50)
sleep(0.2)
pointer.move_abs(252, 55)
sleep(0.2)
pointer.release_abs
sleep(0.2)


## WIP
redis = Redis.new

# redis.subscribe_with_timeout(5, "evt:10:mouse:x") do |on|
t = Thread.new do 
  redis.subscribe("evt:10") do |on|
    on.message do |channel, message|
      puts "channel" + channel  +  " message " + message
      # ...
    end
  end
end
## ...

t.kill

## Clear the pointer 
pointer.delete

# serv = XServer.new 10 
# p = serv.build
# p.start

# il = InputList.new(":10")
# il.load

