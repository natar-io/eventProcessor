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

pointer.delete

## Attach new pointer
il.enable_pointers(pointer)

## Detach from main X server
@main_input.disable_pointers(pointer)
# @main_input.enable_pointers(pointer)

## disable main mouse ?
## enable sub-mouse ?

## move it...
pointer.move(10, 10)
pointer.move(20, 20)
## Move to absolute location.
pointer.press_abs(1920, 1080)
sleep(0.2)
pointer.move_abs(460, 535)
sleep(0.2)
pointer.release_abs
sleep(0.2)
# "Logitech M325"

pointer.press_abs_mt(200, 200, 10, 0)
sleep(0.2)
pointer.move_abs_mt(200, 300, 0)
sleep(0.2)
pointer.release_abs_mt(0)

## DISPLAY=:99 xrandr -s 800x600
## DISPLAY=:99 setxkbmap fr bepo

# @main_input = InputList.new(@main_display)
# @main_input.load_all
#@main_input.get_inputs("Logitech")[0].disable
# @main_input.get_inputs("Logitech")[0].enable
        
## Enable the keyboard 
# il.get_inputs("SIGMACHIP USB Keyboard").each { |i| i.enable } 

## enable mouse 
# il.get_inputs("Logitech M325").each { |i| i.enable } 

## WIP

redis = Redis.new

last_x = 0
last_y = 0
# redis.subscribe_with_timeout(5, "evt:10:mouse:x") do |on|

## Enable/disable keyboard and mouse
t = Thread.new do 
  redis.subscribe("evt:99") do |on|
    on.message do |channel, message|
      
      m = JSON.parse(message)
      
      if m["name"] == "captureMouse"
        if(m["pressed"])
          il.get_inputs("Logitech").each { |i| i.enable }
          puts "Capture mouse"
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


pointers = {}
slots = {} ## Hash: ID -> slot

## Thread for mouse events
redis2 = Redis.new

t2 = Thread.new do 
  redis2.subscribe("evt:99") do |on|
    on.message do |channel, message|
      
      m = JSON.parse(message)

      if m["name"] == "pointer"
        id = m["id"]

        x = (m["x"].to_f * 2048).to_i
        y = (m["y"].to_f * 2048).to_i

        ## update
        known = pointers.include?(id)
        
        if not known

          slot_id = slots.size
          slots[id] = slot_id

          puts "creation of #{id}. #{slot_id}, #{x}, #{y}"
          # pointer.press_abs_mt(x, y, id.to_i, slot_id)
          pointer.press_abs(x, y)
          
          pointers[id] = [x,y]
#          sleep(0.2)
        else
          slot_id = slots[id]
          slot_id = 0  if slot_id.nil?

          #pointer.move_abs_mt(x, y, slot_id)
          pointer.move_abs(x, y)
          pointers[id] = [x,y]
#          puts "update of #{id}, #{x} #{y}, slot #{slot_id} "
        end
      end 

      if m["name"] == "pointerDeath"
        id = m["id"]
        known = pointers.include? id
        if not known
          puts "Death of an unknown pointer"
        else
          ##pointer.release_abs
          slot_id = slots[id]

          # pointer.release_abs_mt(slot_id)
          pointer.release_abs
          slots.delete id
          pointers.delete id
          puts "Death of #{id}, slot #{slot_id}"
        end
      end 

    end
  end
end

t2.kill


## Clear the pointer 
pointer.delete

# serv = XServer.new 10 
# p = serv.build

# p.start

# il = InputList.new(":10")
# il.load

