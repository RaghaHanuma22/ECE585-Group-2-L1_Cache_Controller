module msd;
import pkg_cache::*;
  int fd;                         // File descriptor
  string line, hex_str, filename; // Variables for reading input
  bit [3:0] n;                    // To store the leading 0 (operation code)
  logic [31:0] hex_value;         // To store the 8-digit hex value (32 bits)
  bit [13:0] set_id;              // Cache set index
  bit [2:0] d_victim_cache;       // Index of victim way in data cache
  bit [1:0] i_victim_cache;       // Index of victim way in instruction cache
  bit replacement_done;           // Flag indicating if replacement operation completed
  int data_hit;                   // Counter for data cache hits
  int instruction_hit;            // Counter for instruction cache hits
  bit mode;                       // Mode flag (likely debug/verbose output)

function void process_cache(bit [3:0] n);
case (n)
  0: begin //Read request to L1 data cache
      increment_d_read();         // Increment data read counter
      set_id = hex_value[19:6];   // Extract set index from address
      
      if(d_cache_check(d_cache, hex_value)) begin
        // Cache hit case
        //$display("Cache hit for address %0h in way %0h", hex_value, d_way_idx);
        d_LRU_Update(set_id, d_way_idx);  // Update LRU information
        increment_d_hit();                 // Increment hit counter
        
        // Update MESI state based on current state
        if(d_cache[set_id][d_way_idx].current_state == I) begin
          d_cache[set_id][d_way_idx].current_state = E;  // First cache hit from acting processor
        end
        else if(d_cache[set_id][d_way_idx].current_state == M) begin
          d_cache[set_id][d_way_idx].current_state = M;  // Maintain Modified state
        end
        else begin
          d_cache[set_id][d_way_idx].current_state = S;  // Considering hit from different processor
        end
        
       //$display("Current state is %s!", d_cache[set_id][d_way_idx].current_state);
      end
      else begin
        // Cache miss case
        increment_d_miss();       // Increment miss counter
        if(mode==1)               // If verbose mode is enabled
          $display("Cache miss for address %0h, reading from L2 cache", hex_value);
        
        replacement_done = 0;     // Reset replacement flag
        empty_flag = 0;           // Reset empty slot flag
        invalid_flag = 0;         // Reset invalid entry flag
        
        // Step 1: Check for empty slots (tag == 0)
        for(int j = 0; j < d_ways; j++) begin
          if(d_cache[set_id][j].tag == 0) begin
            d_cache[set_id][j].tag = hex_value[31:20];          // Store tag bits
            d_cache[set_id][j].current_state = E;               // Set MESI state to Exclusive
            d_LRU_Update(set_id, j);                            // Update LRU tracking
            empty_flag = 1;                                      // Set empty slot found flag
            replacement_done = 1;                                // Mark replacement as complete
            //$display("Replaced in empty way %0d", j);
            break;
          end
        end
        
        // Step 2: If no empty slots, check for invalid states
        if(!empty_flag) begin
          for(int e = 0; e < d_ways; e++) begin
            if(d_cache[set_id][e].current_state == I) begin
              d_cache[set_id][e].tag = hex_value[31:20];        // Store tag bits
              d_cache[set_id][e].current_state = E;             // Set MESI state to Exclusive
              d_LRU_Update(set_id, e);                          // Update LRU tracking
              invalid_flag = 1;                                  // Set invalid entry found flag
              replacement_done = 1;                              // Mark replacement as complete
             // $display("Replaced in invalid way %0d", e);
              break;
            end
          end
        end
        
        // Step 3: If no invalid states, use LRU victim
        if(!empty_flag && !invalid_flag) begin
          d_victim_cache = find_d_LRU_way(set_id);              // Find least recently used way
          if(d_cache[set_id][d_victim_cache].current_state == M) begin
           // $display("Modified line is being evicted, writing back data to L2 cache at address: %0h",hex_value);
          end
          d_cache[set_id][d_victim_cache].tag = hex_value[31:20]; // Store tag bits
          d_cache[set_id][d_victim_cache].current_state = E;      // Set MESI state to Exclusive
          d_LRU_Update(set_id, d_victim_cache);                   // Update LRU tracking
          //$display("Replaced LRU victim way %0d", d_victim_cache);
        end
        
        //$display("Now cache has %p", d_cache[set_id]);
      end
  end
    1:begin //write request to L1 data cache
      increment_write();          // Increment write counter
      set_id = hex_value[19:6];   // Extract set index from address
if(d_cache_check(d_cache,hex_value)) begin
       //$display("Cache hit for address %0h in way %0h",hex_value,d_way_idx);
       //$display("Data written at address %0h in way %0h",hex_value,d_way_idx);
       increment_d_hit();                              // Increment data hit counter
       d_LRU_Update(set_id,d_way_idx);                 // Update LRU status for accessed way
       if(d_cache[set_id][d_way_idx].current_state == I) begin
       d_cache[set_id][d_way_idx].current_state = M;    //First cache hit comes from acting processor
       if(mode==1)
         $display("First Write-through data to L2 at address: %0h",hex_value);
       end
       else if(d_cache[set_id][d_way_idx].current_state == E) begin
         d_cache[set_id][d_way_idx].current_state = M;  // Change Exclusive to Modified on write
       end
       else if(d_cache[set_id][d_way_idx].current_state == S) begin
           d_cache[set_id][d_way_idx].current_state = M; // Change Shared to Modified on write
         end
       else begin
         d_cache[set_id][d_way_idx].current_state = M;   // Maintain Modified state on write
       end
       //$display("Current state is %s!",d_cache[set_id][d_way_idx].current_state);
     end
     //cache miss case
     else begin
       increment_d_miss();                             // Increment data miss counter
       if(mode==1)
         $display("Read for ownership from L2 at address: %0h", hex_value);
       replacement_done = 0;                           // Reset replacement flag
       empty_flag = 0;                                 // Reset empty slot flag
       invalid_flag = 0;                               // Reset invalid entry flag
       // Step 1: Check for empty slots (tag == 0)
       for(int j=0;j<d_ways;j++) begin
         if(d_cache[set_id][j].tag==0) begin
         d_cache[set_id][j].tag=hex_value[31:20];      // Store tag bits
         d_LRU_Update(set_id,j);                       // Update LRU status
         d_cache[set_id][j].current_state = M;         // Set MESI state to Modified for write
         empty_flag = 1;                               // Set empty slot found flag
         replacement_done =1;                          // Mark replacement as complete
         //$display("Replaced in empty way %0d", j);
         break;
         end
       end
       // Step 2: If no empty slots, check for invalid states
       if(~empty_flag) begin
         for(int e = 0; e < d_ways; e++) begin
           if(d_cache[set_id][e].current_state == I) begin
             d_cache[set_id][e].tag = hex_value[31:20]; // Store tag bits
             d_cache[set_id][e].current_state = M;      // Set MESI state to Modified for write
             d_LRU_Update(set_id, e);                   // Update LRU status
             invalid_flag = 1;                          // Set invalid entry found flag
             replacement_done = 1;                      // Mark replacement as complete
             //$display("Replaced in invalid way %0d", e);
             break;
           end
         end
       end
      // Step 3: If no invalid states, use LRU victim
       if(!empty_flag && !invalid_flag) begin
         d_victim_cache = find_d_LRU_way(set_id);       // Find least recently used way
         if(mode==1)
           $display("Write data to L2 at address: %0h",hex_value);
         d_cache[set_id][d_victim_cache].tag = hex_value[31:20]; // Store tag bits
         d_cache[set_id][d_victim_cache].current_state = M;      // Set MESI state to Modified for write
         d_LRU_Update(set_id, d_victim_cache);                   // Update LRU status
         //$display("Replaced LRU victim way %0d", d_victim_cache);
       end
        //$display("Now cache has %p",d_cache[set_id]);
   end
   end
   2:begin //Instruction fetch to L1 instructions cache
     increment_i_read();                               // Increment instruction read counter
     set_id = hex_value[19:6];                         // Extract set index from address
     if(i_cache_check(i_cache,hex_value)) begin
       //$display("Cache hit for address %0h in way %0h",hex_value,i_way_idx);
       i_LRU_Update(set_id,i_way_idx);                 // Update LRU status for instruction cache
       increment_i_hit();                              // Increment instruction hit counter
       if(i_cache[set_id][i_way_idx].current_state == I) begin
       i_cache[set_id][i_way_idx].current_state = E;    //First cache hit comes from acting processor
       end
       else begin
         i_cache[set_id][i_way_idx].current_state = S;  //Considering that the 2nd cache hit comes from a different processor
       end
       //$display("Current state is %s!",i_cache[set_id][i_way_idx].current_state);
     end
//Cache miss case
     else begin
       increment_i_miss();                             // Increment instruction miss counter
       if(mode==1)
        $display("Cache miss for address %0h, reading from L2 cache", hex_value);

replacement_done = 0;                           // Reset replacement flag
empty_flag = 0;                                 // Reset empty slot flag
invalid_flag = 0;                               // Reset invalid entry flag
// Step 1: Check for empty slots (tag == 0)
for(int j=0;j<i_ways;j++) begin
 if(i_cache[set_id][j].tag==0) begin
 i_cache[set_id][j].tag=hex_value[31:20];      // Store tag bits
 i_cache[set_id][j].current_state = E;         // Set MESI state to Exclusive
 i_LRU_Update(set_id,j);                       // Update LRU status
 empty_flag = 1;                               // Set empty slot found flag
 replacement_done = 1;                         // Mark replacement as complete
 //$display("Replaced in empty way %0d", j);
 break;
 end    
end
// Step 2: If no empty slots, check for invalid states
if(~empty_flag) begin
  for(int e = 0; e < i_ways; e++) begin
   if(i_cache[set_id][e].current_state == I) begin
     i_cache[set_id][e].tag = hex_value[31:20]; // Store tag bits
     i_cache[set_id][e].current_state = E;      // Set MESI state to Exclusive
     i_LRU_Update(set_id, e);                   // Update LRU status
     invalid_flag = 1;                          // Set invalid entry found flag
     replacement_done = 1;                      // Mark replacement as complete
     //$display("Replaced in invalid way %0d", e);
     break;
   end
 end
end
// Step 3: If no invalid states, use LRU victim
if(!empty_flag && !invalid_flag) begin
 i_victim_cache = find_i_LRU_way(set_id);       // Find least recently used way in instruction cache
 i_cache[set_id][i_victim_cache].tag = hex_value[31:20]; // Store tag bits
 i_cache[set_id][i_victim_cache].current_state = E;      // Set MESI state to Exclusive
 i_LRU_Update(set_id, i_victim_cache);                   // Update LRU status
 //$display("Replaced LRU victim way %0d", i_victim_cache);
end

end
//$display("Now cache has %p",i_cache[set_id]);
end
3:begin
 set_id = hex_value[19:6];                      // Extract set index from address
 $display("Invalid command from L2 Cache");
 if(d_cache_check(d_cache,hex_value)) begin
   d_cache[set_id][d_way_idx].current_state = I; // Invalidate cache line
   //$display("Now cache has %p",d_cache[set_id]);
 end
end
4:begin
   /*
     RFO doubt: what happens if P1 is not in M state then where does P2 get its data from? 
   */
   set_id = hex_value[19:6];                     // Extract set index from address
   //$display("RFO from another processor!");
   if(d_cache_check(d_cache,hex_value)) begin
     if(d_cache[set_id][d_way_idx].current_state == M)begin
       if(mode==1)
         $display("Modified data is being returned to L2 Cache at address %0h",hex_value);
     end
       d_cache[set_id][d_way_idx].current_state = I; // Invalidate cache line due to Read For Ownership
       //$display("Our copy has become invalid: %p",d_cache[set_id]);
   end
end
8:begin
 i_cache_init();                                 // Initialize instruction cache
 d_cache_init();                                 // Initialize data cache
 current_state=I;                                // Set current state to Invalid
end
9: begin
 //for data cache
 $display("--------------Displaying Cache contents-----------------");
 $display("Data cache contents:");
 for(int set_idx=0; set_idx<sets; set_idx++) begin
   $display("Set: %0d", set_idx);
   for(int way_idx= 0; way_idx<d_ways; way_idx++) begin
     $display("Way: %0d: Tag:%0h, state: %s", way_idx, d_cache[set_idx][way_idx].tag, d_cache[set_idx][way_idx].current_state);
   end        
 end      
  $display("Instruction cache contents:");
//for instruction cache
 for(int set_idx=0; set_idx<sets; set_idx++) begin
   $display("Set: %0d", set_idx);
   for(int way_idx= 0; way_idx<i_ways; way_idx++) begin
     $display("Way: %0d: Tag:%h, state: %s", way_idx, i_cache[set_idx][way_idx].tag, i_cache[set_idx][way_idx].current_state);
   end        
 end
end

default: begin
 current_state = I;                            // Default case: reset state to Invalid
end
   
endcase
endfunction
 // Main execution
 initial begin
     if (!$value$plusargs("TRACE_FILE=%s", filename)) begin
   filename = "trial_trace.din";               // Default filename if not specified via command line
 end
   if(!$value$plusargs("MODE=%b",mode))begin
     mode=0;                                   // Default mode (non-verbose) if not specified
   end
   fd = $fopen(filename, "r");                 // Open trace file for reading
   if(fd)
     $display("File opened!!");
   else 
     $display("File was not opened!");
   
   i_cache_init();                             // Initialize instruction cache
   d_cache_init();                             // Initialize data cache
   
   while (!$feof(fd)) begin                    // Process file until end-of-file
     void'($fgets(line, fd));                  // Read line from file
// After extracting the leading bit
if (line.len() > 2) begin                       // Ensure line has enough characters
  // Just use sscanf directly with the format that matches your input line
  if ($sscanf(line, "%d %h", n, hex_value) == 2) begin  // Parse line for operation code and address
    //$display("Leading bit: %0d, Hex value: %b", n, hex_value);
    process_cache(n);                          // Process the cache operation
  end else begin
    $display("Failed to parse line: %s", line);
  end
end
   
   end
   $fclose(fd);                                // Close file when done
   $display("File operation done!");
 $display("-----------------Cache Summary------------------");
 $display("\nNo. of data cache reads: %0d",d_cache_read);
 $display("No. of instruction cache reads: %0d",i_cache_read);
 $display("No. of data cache writes: %0d",cache_write);
 $display("No. of data cache hits: %0d",d_cache_hit);
 $display("No. of instruction cache hits: %0d",i_cache_hit);
 $display("No. of data cache misses: %0d",d_cache_miss);
 $display("No. of instruction cache misses: %0d",i_cache_miss);
 d_hit_ratio();                                // Calculate and display data cache hit ratio
 i_hit_ratio();                                // Calculate and display instruction cache hit ratio
 end
endmodule
