module hextobin_tb;

    logic [31:0] hex_input;       // 32-bit hexadecimal input
    logic [31:0] binary_output;   // 32-bit binary output

    // Instantiate HexToBinary module
    HexToBinary htb (
        .hex_in(hex_input),
        .bin_out(binary_output)
    );

    initial begin
        // Test case 1: Hexadecimal 0xA5F3C9B2
        hex_input = 32'hA5F3C9B2;
        #10;  // Wait for conversion
        $display("Hex Input: %h | Binary Output: %032b", hex_input, binary_output);  // Use %032b to ensure 32-bit output

        // Test case 2: Hexadecimal 0x1A2B3C4D
        hex_input = 32'h1A2B3C4D;
        #10;  // Wait for conversion
        $display("Hex Input: %h | Binary Output: %032b", hex_input, binary_output);

        // Test case 3: Hexadecimal 0xFFFFFFFF (all bits set)
        hex_input = 32'hFFFFFFFF;
        #10;  // Wait for conversion
        $display("Hex Input: %h | Binary Output: %032b", hex_input, binary_output);

        // Test case 4: Hexadecimal 0x00000000 (all bits cleared)
        hex_input = 32'h00000000;
        #10;  // Wait for conversion
        $display("Hex Input: %h | Binary Output: %032b", hex_input, binary_output);
        
        $finish;
    end
endmodule

