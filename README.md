# Tetris on FPGA with SoC - ECE 385 Final Project
Final Project for Digital Systems Laboratory (ECE 385). Designed with system-on-chip MicroBlaze softcore processor, used to handle USB input. Capable of HDMI display, the game is controlled using a standard USB keyboard, as well as having AUDIO output through AUDIO OUT of FPGA board.

Project and constraints are designed to work for the Urbana board, with the AMD spartan-7 XC7S50-CSGA324 FPGA.

[RealDigital Urbana Board](https://www.amd.com/en/corporate/university-program/aup-boards/realdigital-urbana-board.html)

[Urbana Board Reference Manual](https://www.realdigital.org/doc/496fed57c6b275735fe24c85de5718c2)

## Digital Systems Laboratory (ECE 385) - Spring 2025
## Course Description
Design, build, and test digital systems using transistor-transistor logic (TTL), SystemVerilog, and field-programmable gate arrays (FPGAs). Topics include combinational and sequential logic, storage elements, input/output and display, timing analysis, design tradeoffs, synchronous and asynchronous design methods, datapath and controller, microprocessor design, software/hardware co-design, and system-on-a-chip.

## Course Information
- **Institution:** University of Illinois Urbana-Champaign
- **Course Director:** Zuofu Cheng
- **Subject Area:** Computer Engineering

## Topics Covered
- Combinational logic circuits
- Storage elements
- Hazards and race conditions
- Circuit characteristics (fanout, delays, etc.)
- Field Programmable Gate Arrays (FPGAs)
- Combinational networks (adders, multiplexers, etc.) in SystemVerilog
- Sequential networks (counters, shift registers, etc.) in SystemVerilog
- Synchronous state machines
- Static timing analysis, clock domains, metastability, and synchronization
- Logic simulation and testbenches
- Microprocessors and system on chip
- Project using a microprocessor and system on chip concepts

## Labs Overview
- **Lab 2: 8-bit Logic Processor**  
  Design utilizing two 8-bit shift registers, multiple multiplexers, and a counter to perform seventeen distinct functions.

- **Lab 3: Introduction to SystemVerilog, FPGA, EDA, and 16-bit Adders**  
  Transition from TTL-based physical logic to RTL design on FPGA. Implement and analyze various adder circuits using modern EDA tools.

- **Lab 4: An 8-Bit Multiplier in SystemVerilog**  
  Develop a multiplier for two 8-bit 2’s complement numbers and implement it on the Urbana FPGA board.

- **Lab 5: Simple Computer SLC-3.2 in SystemVerilog**  
  Design a simplified microprocessor based on a subset of the LC-3 ISA, featuring 16-bit instructions and registers.

- **Lab 6: MicroBlaze Based SoC Introduction**  
  Build a simple system-on-chip interfacing with peripherals such as on-board switches and LEDs. Second portion of this lab will require interfacing with display and I/O peripherals, such as HDMI and USB keyboards.

- **Lab 7: HDMI Text Mode Graphics with AXI4-Lite Interface**  
  Create a text mode graphics controller for VGA/HDMI output, evolving from a basic monochrome design to one supporting per-character colors.

## Academic Integrity Policy
Students are expected to uphold the highest standards of academic integrity. Cheating—defined as taking someone else’s work for credit—will incur severe penalties, including:
- A zero score for the affected lab or test.
- A reduction of one full letter grade on the final course grade.
- Reporting to the college for academic misconduct.

Automated tools will be employed to detect similarities in submitted code and lab reports. Self-plagiarism is also considered a violation of academic integrity.

---
*This repository contains all lab assignments for the Digital Systems Laboratory course, Spring 2025.*
