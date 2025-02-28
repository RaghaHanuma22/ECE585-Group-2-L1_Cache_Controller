
module HexToBin (
    input logic [7:0] hex_string[7:0],
    output logic [31:0] binary
);
    int i;
    always_comb begin
        binary = 32'b0;
        for (i = 0; i < 8; i++) begin
            case (hex_string[i])
                "0": binary[i*4 +: 4] = 4'h0;
                "1": binary[i*4 +: 4] = 4'h1;
                "2": binary[i*4 +: 4] = 4'h2;
                "3": binary[i*4 +: 4] = 4'h3;
                "4": binary[i*4 +: 4] = 4'h4;
                "5": binary[i*4 +: 4] = 4'h5;
                "6": binary[i*4 +: 4] = 4'h6;
                "7": binary[i*4 +: 4] = 4'h7;
                "8": binary[i*4 +: 4] = 4'h8;
                "9": binary[i*4 +: 4] = 4'h9;
                "A": binary[i*4 +: 4] = 4'hA;
                "B": binary[i*4 +: 4] = 4'hB;
                "C": binary[i*4 +: 4] = 4'hC;
                "D": binary[i*4 +: 4] = 4'hD;
                "E": binary[i*4 +: 4] = 4'hE;
                "F": binary[i*4 +: 4] = 4'hF;
                default: binary[i*4 +: 4] = 4'h0;
            endcase
        end
    end
endmodule

