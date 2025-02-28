module BinToHex_tb;
    logic [31:0] binary;
    logic [7:0] hex_string[7:0];
    
    // Instantiate the BinToHex module
    BinToHex uut (
        .binary(binary),
        .hex_string(hex_string)
    );
    
    initial begin
        // Test cases
        binary = 32'h12345678;
        #10;
        $display("Binary: %h -> Hex: %s%s%s%s%s%s%s%s", binary,
                 hex_string[7], hex_string[6], hex_string[5], hex_string[4],
                 hex_string[3], hex_string[2], hex_string[1], hex_string[0]);
        
        binary = 32'hABCDEF01;
        #10;
        $display("Binary: %h -> Hex: %s%s%s%s%s%s%s%s", binary,
                 hex_string[7], hex_string[6], hex_string[5], hex_string[4],
                 hex_string[3], hex_string[2], hex_string[1], hex_string[0]);
        
        binary = 32'h00000000;
        #10;
        $display("Binary: %h -> Hex: %s%s%s%s%s%s%s%s", binary,
                 hex_string[7], hex_string[6], hex_string[5], hex_string[4],
                 hex_string[3], hex_string[2], hex_string[1], hex_string[0]);
        
        binary = 32'hFFFFFFFF;
        #10;
        $display("Binary: %h -> Hex: %s%s%s%s%s%s%s%s", binary,
                 hex_string[7], hex_string[6], hex_string[5], hex_string[4],
                 hex_string[3], hex_string[2], hex_string[1], hex_string[0]);
        
        $stop;
    end
endmodule

