module LRU_8way (
    input  logic clk, rst,
    input  logic [2:0] access_way,  // Accessed way (0-7)
    input  logic access_valid,      // High when a cache access happens
    output logic [2:0] evict_way    // Way to be evicted
);
    logic [2:0] lru_counter [7:0];  // Storage for LRU state (3-bit for 8 ways)

    // Sequential update of LRU counters
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 8; i++) 
                lru_counter[i] <= i[2:0]; // Initialize with unique values
        end 
        else if (access_valid) begin
            for (int i = 0; i < 8; i++) begin
                if (i == access_way)
                    lru_counter[i] <= 3'b000; // Most recently used
                else if (lru_counter[i] < lru_counter[access_way])
                    lru_counter[i] <= lru_counter[i] + 1; // Increment rank
            end
        end
    end

    // Find LRU way (highest counter value)
    always_comb begin
        int i;
        logic [2:0] max_value;
        max_value = 3'b000;
        evict_way = 3'b000;
        
        for (i = 0; i < 8; i++) begin
            if (lru_counter[i] > max_value) begin
                max_value = lru_counter[i];
                evict_way = i[2:0];
            end
        end
    end
endmodule

