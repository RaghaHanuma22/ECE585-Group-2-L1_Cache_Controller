module HexToBin_tb;
    logic [7:0] hex_string[7:0];
    logic [31:0] binary;
    
    HexToBin uut (
        .hex_string(hex_string),
        .binary(binary)
    );
    
    initial begin
        // Test Case 1: Hex "12345678"
        hex_string[0] = "1";
        hex_string[1] = "2";
        hex_string[2] = "3";
        hex_string[3] = "4";
        hex_string[4] = "5";
        hex_string[5] = "6";
        hex_string[6] = "7";
        hex_string[7] = "8";
        #10;
        $display("Hex: 12345678 -> Binary: %b", binary);
        
        // Test Case 2: Hex "ABCDEF12"
        hex_string[0] = "A";
        hex_string[1] = "B";
        hex_string[2] = "C";
        hex_string[3] = "D";
        hex_string[4] = "E";
        hex_string[5] = "F";
        hex_string[6] = "1";
        hex_string[7] = "2";
        #10;
        $display("Hex: ABCDEF12 -> Binary: %b", binary);
        
        // Test Case 3: Hex "00000000"
        hex_string[0] = "0";
        hex_string[1] = "0";
        hex_string[2] = "0";
        hex_string[3] = "0";
        hex_string[4] = "0";
        hex_string[5] = "0";
        hex_string[6] = "0";
        hex_string[7] = "0";
        #10;
        $display("Hex: 00000000 -> Binary: %b", binary);
        
        // Test Case 4: Hex "FFFFFFFF"
        hex_string[0] = "F";
        hex_string[1] = "F";
        hex_string[2] = "F";
        hex_string[3] = "F";
        hex_string[4] = "F";
        hex_string[5] = "F";
        hex_string[6] = "F";
        hex_string[7] = "F";
        #10;
        $display("Hex: FFFFFFFF -> Binary: %b", binary);
        
        $stop;
    end
endmodule

