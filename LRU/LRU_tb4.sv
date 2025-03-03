module LRU_4way_tb;
    logic clk, rst;
    logic [1:0] access_way;  // 2-bit for 4-way
    logic access_valid;
    logic [1:0] evict_way;

    // Instantiate LRU 4-way module
    LRU_4way uut (
        .clk(clk),
        .rst(rst),
        .access_way(access_way),
        .access_valid(access_valid),
        .evict_way(evict_way)
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns clock period

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        access_way = 0;
        access_valid = 0;

        // Apply reset
        #10 rst = 0;

        // Apply test cases
        $display("Testing LRU 4-Way...");
        test_access(2);
        test_access(0);
        test_access(3);
        test_access(1);
        test_access(2);
        test_access(0);
        test_access(3);
        test_access(1);

        // End simulation
        #50;
        $display("Simulation complete.");
        $stop;
    end

    // Task to simulate cache access
    task test_access(input logic [1:0] way);
        begin
            access_way = way;
            access_valid = 1;
            #10; // Wait for clock edge
            access_valid = 0;
            #10;
            $display("Accessed Way: %0d | LRU 4-Way Evict: %0d", way, evict_way);
        end
    endtask

endmodule

