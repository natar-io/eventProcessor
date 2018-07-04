require 'childprocess'

# serv = XServer.new 10 
# p = serv.build
# p.start

class XServer
  attr_reader :display, :id, :process
  
  def initialize(display)
    @id = display_to_int(display)
    @display = display
  end

  def build
    @process = ChildProcess.build("Xorg", "-noreset", "+extension", "GLX","+extension", "RANDR",  "+extension", "RENDER",
                            "-logfile", "./#{id.to_s}.log", "-configdir", "dummy", "-config", "./xorg.conf", "#{display}")

    # inherit stdout/stderr from parent...
    @process.io.inherit!  ## for debug
    
    # ...or pass an IO -> to do 
    ## @process.io.stdout = Tempfile.new("child-output")

    # modify the environment for the child
    @process.environment["a"] = "b"
    @process.environment["c"] = nil

    # set the child's working directory
    # @process.cwd = '/some/path'
    @process
  end

  def start_vnc
    `x11vnc -display :#{@id} -localhost`
    sleep 8
    `vncviewer :0`
  end
end
  
# # start the process
# @process.start

# # check process status
# @process.alive?    #=> true
# @process.exited?   #=> false

# # wait indefinitely for process to exit...
# @process.wait
# @process.exited?   #=> true

# # get the exit code
# @process.exit_code #=> 0

# # ...or poll for exit + force quit
# begin
#   @process.poll_for_exit(10)
# rescue ChildProcess::TimeoutError
#   @process.stop # tries increasingly harsher methods to kill the process.
# end
