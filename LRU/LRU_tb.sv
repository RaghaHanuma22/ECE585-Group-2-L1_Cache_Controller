// Code your testbench here
// or browse Examples
module tb_LRU;
    logic clk, rst;
    logic [1:0] access_way_4;
    logic [2:0] access_way_8;
    logic access_valid;
    logic [1:0] evict_way_4;
    logic [2:0] evict_way_8;

    // Instantiate 4-way LRU module
    LRU_4way lru4 (
        .clk(clk),
        .rst(rst),
        .access_way(access_way_4),
        .access_valid(access_valid),
        .evict_way(evict_way_4)
    );

    // Instantiate 8-way LRU module
    LRU_8way lru8 (
        .clk(clk),
        .rst(rst),
        .access_way(access_way_8),
        .access_valid(access_valid),
        .evict_way(evict_way_8)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $dumpfile("lru.vcd");
        $dumpvars(0, tb_LRU);
        
        clk = 0; rst = 1; access_valid = 0;
        #10 rst = 0;

        // Simulate 4-way LRU access pattern
        #10 access_way_4 = 2; access_valid = 1; // Access way 2
        #10 access_valid = 0;

        #10 access_way_4 = 0; access_valid = 1; // Access way 0
        #10 access_valid = 0;

        #10 access_way_4 = 3; access_valid = 1; // Access way 3
        #10 access_valid = 0;

        #10 access_way_4 = 1; access_valid = 1; // Access way 1
        #10 access_valid = 0;
      
      
      
        #10 access_way_4 = 3; access_valid = 1; // Access way 3
        #10 access_valid = 0;

        #10 access_way_4 = 1; access_valid = 1; // Access way 1
        #10 access_valid = 0;
      
      
      #10 access_way_4 = 2; access_valid = 1; // Access way 2
        #10 access_valid = 0;

        // Check eviction way (should be 2, as it's the least recently used)
        #10 $display("4-Way Evict: %d", evict_way_4);

        // Simulate 8-way LRU access pattern
        
      #10 access_way_8 = 0; access_valid = 1; // Access way 5
        #10 access_valid = 0;
      
        #10 access_way_8 = 3; access_valid = 1; // Access way 5
        #10 access_valid = 0;
      
      
      #10 access_way_8 = 5; access_valid = 1; // Access way 5
        #10 access_valid = 0;
      
        #10 access_way_8 = 7; access_valid = 1; // Access way 5
        #10 access_valid = 0;
      
        
      
      
      
      #10 access_way_8 = 4; access_valid = 1; // Access way 4
        #10 access_valid = 0;

        #10 access_way_8 = 2; access_valid = 1; // Access way 2
        #10 access_valid = 0;

        #10 access_way_8 = 6; access_valid = 1; // Access way 6
        #10 access_valid = 0;

        #10 access_way_8 = 1; access_valid = 1; // Access way 1
        #10 access_valid = 0;

        
         
      #10 access_way_8 = 0; access_valid = 1; // Access way 5
        #10 access_valid = 0;
      
        #10 access_way_8 = 3; access_valid = 1; // Access way 5
        #10 access_valid = 0;
      
      
      #10 access_way_8 = 5; access_valid = 1; // Access way 5
        #10 access_valid = 0;
      
        #10 access_way_8 = 7; access_valid = 1; // Access way 5
        #10 access_valid = 0;
       
       #10 access_way_8 = 4; access_valid = 1; // Access way 4
        #10 access_valid = 0;

        #10 access_way_8 = 2; access_valid = 1; // Access way 2
        #10 access_valid = 0;

        #10 access_way_8 = 6; access_valid = 1; // Access way 6
        #10 access_valid = 0;

        #10 access_way_8 = 1; access_valid = 1; // Access way 1
        #10 access_valid = 0;

        // Check eviction way (should be the least recently used one)
        #10 $display("8-Way Evict: %d", evict_way_8);

        #10 $finish;
    end
endmodule

