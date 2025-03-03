
module LRU_4way (
    input  logic clk, rst,
    input  logic [1:0] access_way,  // Accessed way (0-3)
    input  logic access_valid,      // High when a cache access happens
    output logic [1:0] evict_way    // Way to be evicted
);
    logic [1:0] lru_counter [3:0];  // Unpacked array for LRU counters

    // Function to update LRU counters
    function automatic void update_LRU_4way(
        ref logic [1:0] lru[3:0],  // Reference to the current LRU state
        input logic [1:0] accessed_way  // Recently accessed way
    );
        for (int i = 0; i < 4; i++) begin
            if (lru[i] < lru[accessed_way]) begin
                lru[i] = lru[i] + 1;
            end
        end
        lru[accessed_way] = 2'b00; // Mark as most recently used
    endfunction

    // Sequential update of LRU counters
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Initialize LRU counters
            lru_counter[0] <= 2'b00;
            lru_counter[1] <= 2'b01;
            lru_counter[2] <= 2'b10;
            lru_counter[3] <= 2'b11;
        end
        else if (access_valid) begin
            update_LRU_4way(lru_counter, access_way);
        end
    end

    // Find LRU way (way with max value)
    always_comb begin
        evict_way = 2'b00;
        for (int i = 0; i < 4; i++) begin
            if (lru_counter[i] == 2'b11)  // Max value indicates LRU
                evict_way = i[1:0];
        end
    end
endmodule

