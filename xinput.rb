# coding: utf-8

def display_to_int(display)
  display.split(":")[1].to_i
end

class InputList
  attr_reader :inputs, :detached, :attached
  
  def initialize(display=":0")
    @display = display
  end

  def get_list
    l = `DISPLAY=#{@display} xinput list`
    @all_inputs = l.split("\n")
  end
  
  def load_all
    get_list
    inputs = @all_inputs.select {|i|  i.include?("∼") or i.include?("↳")}
    @inputs = inputs.map {|p| Xinput.new p,@display}
  end

  def load_attached
    get_list
    attached = @all_inputs.select {|i| i.include?("↳")}
    @attached = attached.map {|p| Xinput.new p,@display}
  end
  
  def load_detached
    get_list
    detached = @all_inputs.select {|i| i.include?("∼")}
    @detached = detached.map {|p| Xinput.new p,@display}
  end
  
  def enable_all
    @inputs.each {|i| i.enable }
  end

  def disable_all
    @inputs.each {|i| i.disable }
  end


  def disable_pointer(virtual_pointer)
    load_attached
    p = @attached.select {|d| d.name.include? virtual_pointer.name }
    p[0].disable unless p.empty?
  end

  
  def enable_pointer(virtual_pointer)
    load_detached
    p = @detached.select {|d| d.name.include? virtual_pointer.name }
    p[0].enable unless p.empty?
  end

  def enable(id)
    Xinput.inputs[display_to_int(@display)][id].enable
  end
  
  def disable(id)
    Xinput.inputs[display_to_int(@display)][id].disable
  end

end


class Xinput
  attr_reader :id, :name, :display, :display_id
  
  def initialize(description, display=":0")
    elements = description.split("\t")

    ## TODO: parse again
    @name = elements[0].strip 
    @id = elements[1].strip.split("=")[1].to_i

    @display = display
    @display_id = display_to_int(display)
    @@inputs={} unless defined? @@inputs

    @@inputs[@display_id]={} if @@inputs[@display_id].nil?
    @@inputs[@display_id][@id] = self
  end

  def self.inputs
    @@inputs
  end

  def disable
    `DISPLAY=#{@display} xinput disable #{@id}`
    @@inputs[@display_id][@id] = nil
  end    
  def enable
    `DISPLAY=#{@display} xinput enable #{@id}`
    @@inputs[@display_id][@id] = self
  end    
end
