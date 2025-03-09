module msd;
import pkg_cache::*;
  int fd;
  string line, hex_str;
  bit [3:0] n;  // To store the leading 0
  logic [31:0] hex_value;   // To store the 8-digit hex value (32 bits)
  bit [13:0] set_id;
  bit [1:0] d_victim_cache;
  bit [1:0] i_victim_cache;
  bit replacement_done;


function void process_cache(bit [3:0] n);
case (n)

  0: begin //Read request to L1 data cache
      increment_d_read();
      set_id = hex_value[19:6];
      
      if(d_cache_check(d_cache, hex_value)) begin
        // Cache hit case
        $display("Cache hit for address %0h in way %0h", hex_value, d_way_idx);
        d_LRU_Update(set_id, d_way_idx);
        increment_d_hit();
        
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
        
        $display("Current state is %s!", d_cache[set_id][d_way_idx].current_state);
      end
      else begin
        // Cache miss case
        increment_d_miss();
        $display("Cache miss for address %0h, reading from L2 cache", hex_value);
        
        replacement_done = 0;
        empty_flag = 0;
        invalid_flag = 0;
        
        // Step 1: Check for empty slots (tag == 0)
        for(int j = 0; j < d_ways; j++) begin
          if(d_cache[set_id][j].tag == 0) begin
            d_cache[set_id][j].tag = hex_value[31:20];
            d_cache[set_id][j].current_state = E;
            d_LRU_Update(set_id, j);
            empty_flag = 1;
            replacement_done = 1;
            $display("Replaced in empty way %0d", j);
            break;
          end
        end
        
        // Step 2: If no empty slots, check for invalid states
        if(!empty_flag) begin
          $display("Cache full da venna!");
          for(int e = 0; e < d_ways; e++) begin
            if(d_cache[set_id][e].current_state == I) begin
              d_cache[set_id][e].tag = hex_value[31:20];
              d_cache[set_id][e].current_state = E;
              d_LRU_Update(set_id, e);
              invalid_flag = 1;
              replacement_done = 1;
              $display("Replaced in invalid way %0d", e);
              break;
            end
          end
        end
        
        // Step 3: If no invalid states, use LRU victim
        if(!empty_flag && !invalid_flag) begin
          d_victim_cache = find_d_LRU_way(set_id);
          d_cache[set_id][d_victim_cache].tag = hex_value[31:20];
          d_cache[set_id][d_victim_cache].current_state = E;
          d_LRU_Update(set_id, d_victim_cache);
          $display("Replaced LRU victim way %0d", d_victim_cache);
        end
        
        $display("Now cache has %p", d_cache[set_id]);
      end
  end


    1:begin //write request to L1 data cache
      increment_write();
      set_id = hex_value[19:6];
      if(d_cache_check(d_cache,hex_value)) begin
        $display("Cache hit for address %0h in way %0h",hex_value,d_way_idx);
        $display("Data written at address %0h in way %0h",hex_value,d_way_idx);
        increment_d_hit();
        d_LRU_Update(set_id,d_way_idx);

        if(d_cache[set_id][d_way_idx].current_state == I) begin
        d_cache[set_id][d_way_idx].current_state = M;    //First cache hit comes from acting processor
        end
        else if(d_cache[set_id][d_way_idx].current_state == E) begin
          d_cache[set_id][d_way_idx].current_state = M;
        end
        else if(d_cache[set_id][d_way_idx].current_state == S) begin
            d_cache[set_id][d_way_idx].current_state = M;
          end
        else begin
          d_cache[set_id][d_way_idx].current_state = M; 
        end
        $display("Current state is %s!",d_cache[set_id][d_way_idx].current_state);
      end

      //cache miss case
      else begin
        increment_d_miss();
         $display("Cache miss for address %0h, reading from L2 cache", hex_value);
        replacement_done = 0;
        empty_flag = 0;
        invalid_flag = 0;

        // Step 1: Check for empty slots (tag == 0)
        for(int j=0;j<d_ways;j++) begin
          if(d_cache[set_id][j].tag==0) begin
          d_cache[set_id][j].tag=hex_value[31:20];
          if(d_cache [set_id][j].current_state == I) begin
          $display("Data is also being written through to L2 Cache"); //write through for first miss
          end
          d_LRU_Update(set_id,j);
          d_cache[set_id][j].current_state = M;
          empty_flag = 1;
          replacement_done =1;
          $display("Replaced in empty way %0d", j);
          break;
          end
        end


        // Step 2: If no empty slots, check for invalid states
        if(~empty_flag) begin
          $display("Cache Full da venna!!");
          for(int e = 0; e < d_ways; e++) begin
            if(d_cache[set_id][e].current_state == I) begin
              d_cache[set_id][e].tag = hex_value[31:20];
              d_cache[set_id][e].current_state = M;
              d_LRU_Update(set_id, e);
              invalid_flag = 1;
              replacement_done = 1;
              $display("Replaced in invalid way %0d", e);
              break;
            end
          end
        end

       // Step 3: If no invalid states, use LRU victim
        if(!empty_flag && !invalid_flag) begin
          d_victim_cache = find_d_LRU_way(set_id);
          d_cache[set_id][d_victim_cache].tag = hex_value[31:20];
          d_cache[set_id][d_victim_cache].current_state = M;
          d_LRU_Update(set_id, d_victim_cache);
          $display("Replaced LRU victim way %0d", d_victim_cache);
        end

         $display("Now cache has %p",d_cache[set_id]);
    end
    end

    2:begin //Instruction fetch to L1 instructions cache
      increment_i_read();
      set_id = hex_value[19:6];
      if(i_cache_check(i_cache,hex_value)) begin
        $display("Cache hit for address %0h in way %0h",hex_value,i_way_idx);
        i_LRU_Update(set_id,i_way_idx);
        increment_i_hit();

        if(i_cache[set_id][i_way_idx].current_state == I) begin
        i_cache[set_id][i_way_idx].current_state = E;    //First cache hit comes from acting processor
        end
        else begin
          i_cache[set_id][i_way_idx].current_state = S;  //Considering that the 2nd cache hit comes from a different processor
        end
        $display("Current state is %s!",i_cache[set_id][i_way_idx].current_state);
      end

//Cache miss case
      else begin
        increment_i_miss();
         $display("Cache miss for address %0h, reading from L2 cache", hex_value);

        replacement_done = 0;
        empty_flag = 0;
        invalid_flag = 0;

        // Step 1: Check for empty slots (tag == 0)
        for(int j=0;j<i_ways;j++) begin
          if(i_cache[set_id][j].tag==0) begin
          i_cache[set_id][j].tag=hex_value[31:20];
          i_cache[set_id][j].current_state = E;
          i_LRU_Update(set_id,j);
          empty_flag = 1;
          replacement_done = 1;
          $display("Replaced in empty way %0d", j);
          break;
          end    
        end

        // Step 2: If no empty slots, check for invalid states
        if(~empty_flag) begin
           $display("Cache Full da venna!!");
           for(int e = 0; e < i_ways; e++) begin
            if(i_cache[set_id][e].current_state == I) begin
              i_cache[set_id][e].tag = hex_value[31:20];
              i_cache[set_id][e].current_state = E;
              i_LRU_Update(set_id, e);
              invalid_flag = 1;
              replacement_done = 1;
              $display("Replaced in invalid way %0d", e);
              break;
            end
          end
        end

      // Step 3: If no invalid states, use LRU victim
        if(!empty_flag && !invalid_flag) begin
          i_victim_cache = find_i_LRU_way(set_id);
          i_cache[set_id][i_victim_cache].tag = hex_value[31:20];
          i_cache[set_id][i_victim_cache].current_state = E;
          i_LRU_Update(set_id, i_victim_cache);
          $display("Replaced LRU victim way %0d", i_victim_cache);
        end

        $display("Now cache has %p",i_cache[set_id]);
      end
    end

    3:begin
      set_id = hex_value[19:6];
      $display("Invalid command from L2 Cache");
      if(d_cache_check(d_cache,hex_value)) begin
        d_cache[set_id][d_way_idx].current_state = I;
        $display("Now cache has %p",d_cache[set_id]);
      end
    end

    4:begin
        /*
          RFO doubt: what happens if P1 is not in M state then where does P2 get its data from? 
        */
        set_id = hex_value[19:6];
        $display("RFO from another processor!");
        if(d_cache_check(d_cache,hex_value)) begin
          if(d_cache[set_id][d_way_idx].current_state == M)begin
            $display("Modified data is being written to L2 Cache at address %0h",hex_value);
          end
            d_cache[set_id][d_way_idx].current_state = I;
            $display("Our copy has become invalid: %p",d_cache[set_id]);
        end
    end

    8:begin
      i_cache_init();
      d_cache_init();
      current_state=I;
    end

    9: begin
      //for data cache
      $display("Displaying Cache contents:");
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
      current_state = I;
    end

    
  endcase
endfunction

  // Main execution
  initial begin
    fd = $fopen("lru_trace.din", "r");
    if(fd)
      $display("File opened!!");
    else 
      $display("File was not opened!");
    
    i_cache_init();
    d_cache_init();
    
    while (!$feof(fd)) begin
      $fgets(line, fd);
      
      if (line.len() > 0) begin
        // Extract the leading bit (first character)
        n = line.substr(0, 0).atoi();
        
        // Extract and convert the 8-digit hex value
        if (line.len() >= 11) begin  // Ensure line has enough characters
           hex_str = line.substr(2, 9);  // Skip the leading bit and space
          hex_value = '0;  // Initialize to zero
          
          // Convert string hex value to actual bits
          if ($sscanf(hex_str, "%h", hex_value) == 1) begin
            $display("Leading bit: %0d, Hex value: %b", n, hex_value);
          end else begin
            $display("Failed to convert hex string: %s", hex_str);
          end
          process_cache(n);
          `ifdef debug
            break;
          `endif
           //to remove
        end

      

      end

    


    end
/*
  process_cache(0);
  #10;
  process_cache(1);
  #10;
  //process_cache(8);
  #10;
  //process_cache(9);
  //process_cache(3);
  #10;
  process_cache(4);
*/
    $fclose(fd);
    $display("File operation done!");
  end
endmodule