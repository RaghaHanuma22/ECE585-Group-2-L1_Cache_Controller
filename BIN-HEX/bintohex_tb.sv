module BinToHex_tb;
    logic [31:0] binary;
    logic [7:0] hex_string[7:0];
    string hex_output;
    integer i;

    // Instantiate the BinToHex module
    BinToHex uut (
        .binary(binary),
        .hex_string(hex_string)
    );

    initial begin
        // Test cases
        binary = 32'b10111100110111101111000000010000; // BCDEF010
        #10;
        hex_output = "";
        for (i = 0; i < 8; i++) 
            hex_output = {hex_output, hex_string[i]};
        $display("Binary: %b -> Hex: %s", binary, hex_output);

        binary = 32'b00010010001101000101011001111000; // 12345678
        #10;
        hex_output = "";
        for (i = 0; i < 8; i++) 
            hex_output = {hex_output, hex_string[i]};
        $display("Binary: %b -> Hex: %s", binary, hex_output);

        binary = 32'b00000000000000000000000000000000; // 00000000
        #10;
        hex_output = "";
        for (i = 0; i < 8; i++) 
            hex_output = {hex_output, hex_string[i]};
        $display("Binary: %b -> Hex: %s", binary, hex_output);

        binary = 32'b11111111111111111111111111111111; // FFFFFFFF
        #10;
        hex_output = "";
        for (i = 0; i < 8; i++) 
            hex_output = {hex_output, hex_string[i]};
        $display("Binary: %b -> Hex: %s", binary, hex_output);

        $stop;
    end
endmodule
