module BinToHex (
    input logic [31:0] binary,
    output logic [7:0] hex_string [7:0]
);
    int i;
    always_comb begin
        for (i = 0; i < 8; i++) begin
            case (binary[28 - (i * 4) +: 4]) // Extracts bits correctly (MSB first)
                4'h0: hex_string[i] = "0";
                4'h1: hex_string[i] = "1";
                4'h2: hex_string[i] = "2";
                4'h3: hex_string[i] = "3";
                4'h4: hex_string[i] = "4";
                4'h5: hex_string[i] = "5";
                4'h6: hex_string[i] = "6";
                4'h7: hex_string[i] = "7";
                4'h8: hex_string[i] = "8";
                4'h9: hex_string[i] = "9";
                4'hA: hex_string[i] = "A";
                4'hB: hex_string[i] = "B";
                4'hC: hex_string[i] = "C";
                4'hD: hex_string[i] = "D";
                4'hE: hex_string[i] = "E";
                4'hF: hex_string[i] = "F";
                default: hex_string[i] = "?"; // Error case
            endcase
        end
    end
endmodule

