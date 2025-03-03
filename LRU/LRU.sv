
module LRU_8way (
    input  logic clk, rst,
    input  logic [2:0] access_way,  // Accessed way (0-7)
    input  logic access_valid,      // High when a cache access happens
    output logic [2:0] evict_way    // Way to be evicted
);
    logic [2:0] lru_counter[7:0];  // Storage for LRU state (3-bit for 8 ways)

    // Sequential update of LRU counters
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Initialize LRU counters to unique values
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
            lru_counter <= update_LRU_8way(lru_counter, access_way);
        end
    end

    // Find LRU way (way with max value)
    always_comb begin
        evict_way = 3'b000;
        for (int i = 0; i < 8; i++) begin
            if (lru_counter[i] == 3'b111)  // Max value indicates LRU
                evict_way = i[2:0];
        end
    end
endmodule

