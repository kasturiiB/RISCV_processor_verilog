## General Overview of the Signals

Here is a quick guide to the variables shown on the left side of the simulation screen:

*   **`clk` & `reset`:** The heartbeat and power-cycle of the processor.
*   **`uart_rx_in` & `uart_tx_out`:** The communication lines. This represents the processor "listening" to the user type on a keyboard (`rx`) and "speaking" back to a screen (`tx`).
*   **`operand_A` & `operand_B`:** The two numbers the user wants to calculate.
*   **`operator_char`:** The mathematical symbol (`+`, `-`, `*`, `/`, etc.) chosen by the user.
*   **`result`:** The final mathematical answer calculated by the CPU.

---

### The Boot & Idle State (Time: 92.87 µs)

![Boot and Idle State](<images/Waveform showing The Boot and Idle State.png>)

*   **What it shows:** The CPU has just powered on and is in its initial waiting phase.
*   **The Values:** Look at the left panel. `operand_A`, `operand_B`, `operator_char`, and `result` are all sitting at `00000000` (zero).
*   **The Action:** The yellow cursor is placed very early in the simulation. The processor has successfully booted up and cleared its memory. If you look at the `uart_rx_in` line (the receiving wire), you can see green pulses happening just to the right of the cursor. This means the user has started typing the first number, but the CPU has not finished reading and decoding it yet.
*   **Takeaway:** This image demonstrates a clean system reset. The processor correctly zeroes out its internal monitors to prevent garbage data from ruining a calculation.

---

### The Final Output & Standby State (Time: 1,388.29 µs)

![Final Output Standby](<images/Waveform showing Final Output and Stability State.png>)

*   **What it shows:** The calculation is over, the result has been transmitted, and the CPU is ready for the next problem.
*   **The Values:** The numbers on the left are identical to the previous screenshot (5, `+`, 3, and 8).
*   **The Action:** the yellow cursor is now at the very end of the simulation. Look at the `uart_tx_out` line (the transmit wire). Now, the `uart_tx_out` line is a solid, flat green line. The CPU has finished talking. It has looped back to the beginning of its code and is patiently waiting for the user to type a brand new equation.
*   **Takeaway:** This demonstrates the processor's program loop. It doesn't just do one math problem and die; it holds the previous result on the monitor while simultaneously returning to an idle state, proving it can run continuously as a calculator.

---

### The Multiplication Test & Correct Result Lock (Time: 1,356.51 µs)

![Multiplication Test](<images/Waveform showing Multiplication and Correct Result Lock.png>)

*   **What it shows:** The completed multiplication calculation and the successful hardware fix that locks the correct answer on the screen.
*   **The Values:** All parameters are filled. `operand_A` is 7, `operator_char` is `2a` (`*`), and `operand_B` is 4. The CPU's hardware multiplier successfully calculated 7 * 4 and output the result `0000001c`. In the hexadecimal number system, `1c` equals the decimal number 28.
*   **The Action:** The yellow cursor is placed at the end of the simulation timeline. The processor has completely finished the math, and the UART TX line (which was previously pulsing) has gone flat, meaning it has finished sending the "28" back to the user's screen.
*   **Takeaway:** This is a crucial validation screenshot for two reasons. First, it proves the Arithmetic Logic Unit (ALU) correctly executes multiplication, not just addition. Second, it proves that the newly implemented "Result Monitor Lock" logic was successful. Instead of displaying the leftover remainder from the UART divide-by-10 printing loop, the monitor correctly grabbed the true mathematical result (`1c`) on the first pass and locked it safely for display.

---

### Receiving the Operator & Waiting for Operand B (Time: 564.60 µs)

![Receiving Operator](<images/Waveform showing Receiving Operator and Waiting for Operand.png>)

*   **What it shows:** The CPU successfully processing a new test case (7 * 4) and holding state while waiting for the final number.
*   **The Values:** Looking at the left panel, the CPU has captured `operand_A` as `00000007` (7). The `operator_char` is now `2a`, which is the ASCII hex code for the multiplication symbol (`*`). However, `operand_B` and `result` are still zero.
*   **The Action:** The yellow cursor shows the system paused mid-operation. The CPU has already listened to the UART RX line, converted the '7', and decoded the '*'. The `uart_rx_in` signal just to the right of the cursor, it is actively pulsing. The CPU is currently listening to the final number ('4') being typed but hasn't finished loading it into the `operand_B` register yet.
*   **Takeaway:** This image demonstrates the asynchronous stability of the processor. It proves the CPU correctly handles data arriving at different times, securely storing the first operand and the operator while patiently waiting for the user to finish transmitting the rest of the equation.

---

### The Asynchronous Clear Screen State (Time: 586.04 µs) 

![Clear Screen State](<images/The Asynchronous Clear Screen State (Time 586.04 µs).png>)

*   **The Data:** The CPU has received `operand_A` = `00000007` (7) and `operator_char` = `2b` (ASCII for `+`). The `operand_B` and `result` registers are sitting at `00000000`.
*   **Description:** The waveform shows `operand_A` holding 7 and `operator_char` holding `2b` (`+`), while `operand_B` and `result` are cleared to 0. This proves the CPU correctly halts execution and waits for the final UART transmission before allowing the ALU to process garbage data. 

---

### The Addition Operation (Time: 813.01 µs)

![Addition Operation](<images/The Addition Operation (Time 813.01  µs).png>)

*   **The Data:** The CPU is fed `operand_A` = `00000007` (7), `operator_char` = `2b` (ASCII for `+`), and `operand_B` = `00000005` (5). The output `result` is `0000000c`.
*   **Explanation:** The processor is evaluating the equation 7 + 5. The control unit decodes the `+` operator and triggers the standard ADD instruction inside the ALU. The ALU mathematically adds the two values to get 12. In hexadecimal format, the decimal number 12 is represented as `c`, which perfectly matches result output of `0000000c`. 

---

### The Subtraction Execution State (Time: 1,378.15 µs) 

![Subtraction Execution](<images/The Subtraction Execution State (Time 1378.15 µs).png>)

*   **The Data:** The CPU is fed `operand_A` = `00000007` (7), `operator_char` = `2d` (ASCII for `-`), and `operand_B` = `00000005` (5). The output `result` is `00000002`. 
*   **Description:** The waveform captures the successful execution of the subtraction operation (7 - 5). Both operands have been completely received and stored by the UART interface, and the operator register contains the ASCII code `2d`, representing the subtraction operator. The ALU correctly computes the arithmetic difference and stores the value `00000002` in the `result` register. This confirms that the instruction decoding, operand loading, ALU control generation, and arithmetic execution stages of the RISC-V processor operate correctly for subtraction instructions. 

---

### Verifying Greater Than (Time: 2,255.59 µs)

![Greater Than](<images/Verifying Greater Than ( Time 2,255.59 µs).png>)

*   **The Data:** The CPU receives `operand_A` = `00000009` (9), `operator_char` = `3e` (ASCII for `>`), and `operand_B` = `00000005` (5). The output `result` is `00000001`.
*   **Explanation:** The processor is evaluating the equation 9 > 5. Since RISC-V intentionally omits a "Greater Than" hardware gate to save physical silicon space, processor executes this using software logic. The machine code dynamically swaps the registers and asks the ALU to evaluate 5 < 9 using the SLT instruction. Because 5 is less than 9, the `result` register outputs `00000001` (True), successfully proving the workaround logic. 

---

### Verifying Set Less Than (Time: 2,262.89 µs)

![Set Less Than](<images/Verifying Set Less Than (Time 2,262.89 µs ).png>)

*   **The Data:** The CPU is fed `operand_A` = `00000007` (7), `operator_char` = `3c` (ASCII for `<`), and `operand_B` = `00000009` (9). The output `result` is `00000001`.
*   **Explanation:** The processor is evaluating the equation 7 < 9. The control unit decodes the `<` symbol and routes the data to the newly expanded Set Less Than (SLT) instruction in the ALU. The ALU hardware directly compares the two values. Since 7 is indeed less than 9, the final `result` register correctly locks in `00000001` (True). 

---

### Verifying Equal To (Time: 2,756.30 µs)

![Equal To](<images/Verifying Equal To ( Time 2,756.30 µs).png>)

*   **The Data:** The CPU evaluates `operand_A` = `00000005` (5), `operator_char` = `3d` (ASCII for `=`), and `operand_B` = `00000005` (5). The output `result` is `00000001`.
*   **Explanation:** The processor is evaluating the equation 5 = 5. Because the base RISC-V ISA does not include a dedicated "Set Equal To" hardware instruction, software handles this by instructing the Arithmetic Logic Unit (ALU) to subtract the two operands. The `ALU_result` shows exactly `00000000`, which proves the hardware correctly calculated 5 - 5 = 0. The software will detect this zero and branch to output a 1 (True).
