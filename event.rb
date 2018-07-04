# coding: utf-8


# Event


# TODO:
# 0. Start an X server.
# 1. Listen to all the event devices.
# 2. remove all of the event devices, except the keyboard maybe.
# 3. Create a custom uinput for a mouse / MT.
# 4. Remove this custom uinput from the main X server.
# 5. Wait / stream custom events to the new X server. 
# 6. enable/disable the keyboard at will.
# 7. (optionnal - care about the keyboard map)


# ~~ Launch some apps on the X server ?
#

# Killing process
# 1. Destroy the uinput.
# 2. Disconnect the clients - send dying message. 
# 3. Destroy the X server.


#  - read this character: ↳

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
device = pointer.create_device

## Attach new pointer
il.enable_pointer(pointer)

## Detach from main X server
@main_input.disable_pointer(pointer)

## move it...
pointer.move(10, 10)
## ...

## Clear the pointer 
pointer.delete

# serv = XServer.new 10 
# p = serv.build
# p.start

# il = InputList.new(":10")
# il.load

