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
require 'json'

require_relative 'xinput'
require_relative 'xserver'
require_relative 'pointer'


@main_display = ":0"
@main_input = InputList.new(@main_display)



# Display 
display = ":99"

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
il.enable_pointers(pointer)

## Detach from main X server
@main_input.disable_pointers(pointer)

## disable main mouse ?
## enable sub-mouse ?

## move it...
pointer.move(10, 10)
pointer.move(20, 20
## Move to absolute location.
pointer.press_abs(460, 535)
sleep(0.2)
pointer.move_abs(460, 535)
sleep(0.2)
pointer.release_abs
sleep(0.2)
# "Logitech M325"

## DISPLAY=:99 xrandr -s 800x600
## DISPLAY=:99 setxkbmap fr bepo

@main_input = InputList.new(@main_display)
@main_input.load_all
#@main_input.get_inputs("Logitech")[0].disable
# @main_input.get_inputs("Logitech")[0].enable
        
## Enable the keyboard 
il.get_inputs("SIGMACHIP USB Keyboard").each { |i| i.enable } 

## enable mouse 
il.get_inputs("Logitech M325").each { |i| i.enable } 

## WIP

redis = Redis.new

last_x = 0
last_y = 0
# redis.subscribe_with_timeout(5, "evt:10:mouse:x") do |on|


t = Thread.new do 
  redis.subscribe("evt:99") do |on|
    on.message do |channel, message|
      
      m = JSON.parse(message)
      
      if m["name"] == "captureMouse"
        if(m["pressed"])
          il.get_inputs("Logitech").each { |i| i.enable }
          puts "capture mouse"
        else
          il.get_inputs("Logitech").each { |i| i.disable }
          puts "release mouse"
        end
      end
      
      if m["name"] == "captureKeyboard"
        if(m["pressed"])
          il.get_inputs("SIGMACHIP USB Keyboard").each { |i| i.enable }
          puts "capture keyboard"
        else
          il.get_inputs("SIGMACHIP USB Keyboard").each { |i| i.disable }
          puts "release keyboard"
        end
      end
      
    end
  end
end

t.kill
# if m["name"] == "mouseEvent"
      #   pressed = m["pressed"]

      #   unless pressed.nil?
      #     if pressed
      #     #            pointer.press_abs(last_x,last_y)
      #       pointer.press_left(true)
      #     else 
      #       pointer.press_left(false)
      #     end
      #   end
        
      #   x = m["x"] 
      #   y = m["y"]

      #   unless x.nil? or y.nil?
      #     # pointer.move(x
      #     pointer.move(x,y)
      #     last_x = x
      #     last_y = y
      #   end

        #       pointer.press_left(pressed)
#        puts "Pointer evt: " + x.to_s + " " + y.to_s + " " + pressed.to_s

#      puts m.to_s
#      puts m[:name]
#      puts "channel" + channel  +  " message " + message
      # ...
## ...


## Clear the pointer 
pointer.delete

# serv = XServer.new 10 
# p = serv.build

# p.start

# il = InputList.new(":10")
# il.load

