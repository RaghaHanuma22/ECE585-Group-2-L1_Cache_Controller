module HexToBinary (
  input logic [31:0] hex_in,      // 32-bit hexadecimal input
  output logic [31:0] bin_out    // 128-bit binary output (32 bits per hex digit)
);

    // Always block to convert the hex input to binary
    always_comb begin
        bin_out = 0;  // Initialize the binary output to 0
        for (int i = 0; i < 8; i++) begin  // Loop through each hexadecimal digit (8 digits for 32-bit hex)
            // Extract each hex digit and convert it to a 4-bit binary value
            bin_out[4*i +: 4] = hex_in[4*i +: 4];  
        end
    end

endmodule


