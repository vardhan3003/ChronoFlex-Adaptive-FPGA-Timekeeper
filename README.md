1.INTRODUCTION 

This project entails the design and implementation 
of a digital watch on a Basys board using Verilog. 
The watch operates in three primary modes: Real
Time Clock (RTC), Edit Mode, and Timer Mode. 
The RTC mode displays the current time in a 24
hour format, updating seconds, minutes, and hours 
in real-time. The following sections provide a 
detailed overview of the functionality, and 
implementation of the digital watch.

2.STATES OF OPERATION 

The design is composed of three states: 

2.1 Real-Time Clock (RTC): 

This state functions as a standard clock, displaying 
the current time in a 24-hour format. The time is 
updated every second, incrementing the seconds, 
minutes, and hours accordingly. This mode is the 
default mode of the watch. 

2.2 Edit Mode: 

In this state, users can manually set the time. The 
edit_shift input allows users to switch between 
setting hours and minutes, and the inc input 
increments the selected value. The display shows 
the current selection by blinking the digits being 
edited. 

2.3 Timer Mode: 

The timer state enables the watch to function as a 
countdown timer. Users can set the duration using 
edit_shift and inc inputs. The start_stop input starts 
or stops the countdown. The display updates to 
show the remaining time. The maximum duration 
that can be set is 59 minutes and 59 seconds. 

3.CONSTRAINTS OF THE BOARD

3.1 Push Buttons 

reset: Resets all time values (hours, minutes, 
seconds) to 0 in the edit mode and the (minutes and 
seconds) to 0 in the timer mode. 
mode: Cycles through clock, edit, and timer states. 
edit_shift: Toggles in editing position (hours/minutes)
edit mode and (minutes/seconds) in timer mode. 
inc: Increments selected time unit (hours/minutes) 
in edit mode and  (minutes/seconds) in timer mode. 
start_stop: Starts or stops the timer in timer mode. 


3.2 LEDs 

mode_value: Displays the current mode on seven
segment display (mode_value[2:0]). 

3.3 Seven-Segment Display 

Clock Mode: Displays the current hours and 
minutes. 
Edit Mode: Shows hours and minutes; blinking 
alternates based on the edit shift to increment the 
selected time unit (hours/minutes). 
Timer Mode: Displays minutes and seconds. It 
operates based on the timer's start/stop state, 
allowing editing with increment and edit_place 
inputs. In the stop state, the display blinks and 
alternates based on the edit shift to increment the 
selected time unit (minutes/seconds). 

4.OUTPUT ON THE BASYS BOARD

Drive_link: https://drive.google.com/file/d/1PUQTWywNAGPOG6f4PEp72l2Ui6K2iOzT/view?usp=drivesdk
