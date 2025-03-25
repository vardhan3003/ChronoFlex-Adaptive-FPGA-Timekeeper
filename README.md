1. INTRODUCTION
   
This project entails the design and implementation of a digital watch on a Basys board using Verilog. The watch operates in five primary modes: Real-Time Clock (RTC), Edit Mode, Timer Mode, Stopwatch Mode, and Alarm Mode.

The RTC mode displays the current time in a 24-hour format, updating seconds, minutes, and hours in real-time.
The Edit Mode allows users to modify the date, month, and time.
The Timer Mode functions as a countdown timer with a maximum duration of 59 minutes and 59 seconds.
The Stopwatch Mode counts elapsed time up to 59 minutes and 59 seconds.
The Alarm Mode allows setting an alarm that triggers at the specified time.
The design ensures that the real-time clock runs concurrently across all modes without interruption. This document provides a detailed overview of the functionality and implementation of the digital watch.

2. STATES OF OPERATION
The design consists of five primary states:

2.1 Real-Time Clock (RTC):

This state functions as a standard clock, displaying the current time in 24-hour format.
The time updates every second, incrementing seconds, minutes, and hours accordingly.
The clock runs continuously, even when switching to other modes.
The long press of the Increment button (inc) allows viewing the current date and month.

2.2 Edit Mode:

Users can manually set the time, date, and month.
The edit_shift button allows switching between the hours, minutes, date, and month fields.
The increment button (inc) increases the selected value.
The display blinks the currently active handle to indicate which value is being modified.

2.3 Timer Mode:

Functions as a countdown timer, allowing users to set a duration of up to 59 minutes and 59 seconds.
Users can set the timer using the edit_shift and increment (inc) buttons.
The start_stop button starts or stops the countdown.
In the stopped state, the seven-segment display blinks to indicate which value is selected for modification.

2.4 Stopwatch Mode:

Functions as a count-up timer, measuring elapsed time up to 59 minutes and 59 seconds.
The start_stop button is used to start, pause, or reset the stopwatch.
In the stopped state, the seven-segment display blinks, indicating the active values.

2.5 Alarm Mode:

Allows setting an alarm that rings when the clock time matches the set alarm time.
Users can set the alarm using edit_shift and increment (inc) buttons.
The start_stop button turns the alarm on or off.
When the alarm rings, the buzzer activates, and the start_stop button stops the alarm.
The long press of the start_stop button allows users to view the set alarm time.

3. CONSTRAINTS OF THE BOARD

3.1 Push Buttons
mode → Cycles through Clock, Edit, Timer, Stopwatch, and Alarm states.
reset → Resets:
Time values (hours, minutes, seconds) to 00:00 in Edit Mode.
Timer and Stopwatch to 00:00.
Date and Month to 1st January (default).
edit_shift → Switches between:
Hours and Minutes in Edit Mode and Alarm Mode.
Minutes and Seconds in Stopwatch and Timer Mode.
Date and Month in Edit Mode.
inc (Increment) → Increases values of time, date, timer, stopwatch, and alarm settings.
Long Press: Displays current date and month in Clock Mode.
start_stop → Manages operations in Stopwatch, Timer, and Alarm modes.
Starts or stops the Stopwatch and Timer.
Stops the alarm buzzer when ringing.
Long Press: Displays alarm time if the alarm is set.

3.2 LED Indicators
Indicate the current mode of operation.
Show the buzzer status when the alarm is activated.

3.3 Seven-Segment Display
Clock Mode:
Displays hours and minutes in real time.
Long press of Increment (inc) button shows date and month.

Edit Mode:
Displays hours, minutes, date, and month.
The blinking display indicates the currently active field being modified.

Timer Mode:
Displays minutes and seconds.
Operates based on the start/stop state.
The stopped state makes the display blink, indicating the active field.

Stopwatch Mode:
Displays elapsed time in minutes and seconds.
Stops, starts, or resets based on the start_stop button.
The stopped state makes the display blink, indicating the active field.

Alarm Mode:
Displays the set alarm time.
Long press of start_stop button shows the alarm time if the alarm is on.

5. OUTPUT ON THE BASYS BOARD
--------------------------------------------------------

