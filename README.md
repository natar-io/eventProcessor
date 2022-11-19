# eventProcessor

Project that enables the creation of a new X11 display, create virtual devices (mouse, touch input, keyboard) and bind them 
together. 

The goal of this project is to manage an offscreen display, run an applicationd and 
push virtual mouse and keyboards events to it. Then the inputs and rendered display can 
be read using  FFMPEG X11 display reader and used in augmented reality projects. 
