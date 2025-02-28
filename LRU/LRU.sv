
module LRU_4way (
    input  logic clk, rst,
    input  logic [1:0] access_way,  // Which way is accessed (0-3)
    input  logic access_valid,      // High when a cache access happens
    output logic [1:0] evict_way    // Way to be evicted
);
    logic [1:0] lru_counter[3:0];  // 2-bit LRU counters for 4 ways

    // Reset LRU counters
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            lru_counter[0] <= 2'b00;
            lru_counter[1] <= 2'b01;
            lru_counter[2] <= 2'b10;
            lru_counter[3] <= 2'b11;
        end 
        else if (access_valid) begin
            // Increase counters for all ways except the accessed way
            foreach (lru_counter[i]) begin
                if (i != access_way) 
                    lru_counter[i] <= lru_counter[i] + 1;
                else 
                    lru_counter[i] <= 2'b00;  // Accessed way becomes MRU
            end
        end
    end

    // Find the way with the highest counter (LRU way)
    always_comb begin
        evict_way = 2'b00;
        foreach (lru_counter[i]) begin
            if (lru_counter[i] == 2'b11) 
                evict_way = i[1:0];  // The way with max counter is LRU
        end
    end
endmodule

module LRU_8way (
    input  logic clk, rst,
    input  logic [2:0] access_way,  // Which way is accessed (0-7)
    input  logic access_valid,      // High when a cache access happens
    output logic [2:0] evict_way    // Way to be evicted
);
    logic [2:0] lru_counter[7:0];  // 3-bit LRU counters for 8 ways

    // Reset LRU counters
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            lru_counter[0] <= 3'b000;
            lru_counter[1] <= 3'b001;
            lru_counter[2] <= 3'b010;
            lru_counter[3] <= 3'b011;
            lru_counter[4] <= 3'b100;
            lru_counter[5] <= 3'b101;
            lru_counter[6] <= 3'b110;
            lru_counter[7] <= 3'b111;
        end 
        else if (access_valid) begin
            // Increase counters for all ways except the accessed way
            foreach (lru_counter[i]) begin
                if (i != access_way) 
                    lru_counter[i] <= lru_counter[i] + 1;
                else 
                    lru_counter[i] <= 3'b000;  // Accessed way becomes MRU
            end
        end
    end

    // Find the way with the highest counter (LRU way)
    always_comb begin
        evict_way = 3'b000;
        foreach (lru_counter[i]) begin
            if (lru_counter[i] == 3'b111) 
                evict_way = i[2:0];  // The way with max counter is LRU
        end
    end
endmodule
