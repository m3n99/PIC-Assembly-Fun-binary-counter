# PIC-Assembly-Fun-binary-counter

Simulation using Proteus 8.11 & code using MPLAB.

We would like to build a fun binary counter that is able to count up from 0 to 31 on a 16F877A PIC microcontroller but not necessarily in a sequential order. The hardware should be composed of 5 LEDs to show the count and 2 push buttons. We’ll call the 2 push buttons P1 and P2 consecutively. The system should behave as follows:
• When powered up, the default behavior for the counter is to count up sequentially from 0 to 31 with a pause of 1 second between the counts.
• If push button P1 is clicked, the counter should continue counting from its current value up to 31 but should increment by 2 instead of 1.
• If push button P1 is clicked again, the counter should continue counting from its current value up to 31 but should increment by 3. Further clickings on P1 should increment the counter by 4, then by 5 and then back to increment by 1.
• If push button P2 is clicked during counting, the counter should increase the pause value between increments: The first time P2 is clicked, the pause between counts
should be made 2 seconds. Further clickings on P2 should make the pause between counts 3 seconds, 4 seconds and 5 seconds consecutively. Clicking on P2 after the 5-second pause should bring it back to 1 second.
