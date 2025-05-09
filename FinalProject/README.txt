HOW TO RUN

- Create a new project, import all of the SV design source files, as well as the constraint file.

- We use the MicroBlaze Microcontroller + USB peripherals Block design from lab 6.2, This also needs to be imported.

- The HDMI/DVI Encoder from lab 6.2 should be added as a User repository under IP catalog. Set up in HDMI mode with 4 bits of RGB, similar to lab 6 and 7. The Clocking Wizard from IP Catalog should also be instantiated, with two output clocks of 25 MHz and 125 MHz, same as lab 6 and 7.

- Generate a bitstream, which will be exported as hardware using the Export hardware platform, to create an XSA file.

- Create a Vitis IDE environment, which will be used to create an application project. The XSA file generated from the Vivado project should be used as the project hardware. Select the "Hello world" project preset to create your project.

- Navigate to the source files of this project, delete the helloworld.c files and other  files generated from this project, and add this projects software files to that folder.

- Build the project, and run a "Single application debug" run configuration. The Urbana board should be plugged into your PC prior. The HDMI output from the FPGA can be attached to any display monitor, and the USB port can be wired to a standard USB keyboard. For audio, standard headphones or a speaker can be wired into the FPGA with an AUX cord, to the AUDIO OUT port.

- At this point, the game should be displayed to the monitor, the USB inputs should be responding, and the tetris theme should be playing through your audio device.