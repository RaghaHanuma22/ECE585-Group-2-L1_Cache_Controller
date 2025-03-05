module msd;
import pkg_cache::*;
  int fd;
  string line, hex_str;
  bit [3:0] n;  // To store the leading 0
  logic [31:0] hex_value;   // To store the 8-digit hex value (32 bits)
  bit [13:0] set_id;


/*
function mesi_state_t next_state(mesi_state_t current_state, );

endfunction
*/

function void process_cache(bit [3:0] n);
case (n)
    0: begin //Read request to L1 data cache
      set_id = hex_value[19:6];
      if(d_cache_check(d_cache,hex_value)) begin
        $display("Cache hit for address %0h in way %0h",hex_value,d_way_idx);
        if(d_cache[set_id][d_way_idx].current_state == I) begin
        d_cache[set_id][d_way_idx].current_state = E;    //First cache hit comes from acting processor
        end
        else if(d_cache[set_id][d_way_idx].current_state == M) begin
          d_cache[set_id][d_way_idx].current_state = M;
        end
        else begin
          d_cache[set_id][d_way_idx].current_state = S;  //Considering that the 2nd cache hit comes from a different processor
        end
        $display("Current state is %s!",d_cache[set_id][d_way_idx].current_state);
      end
      else begin
        for(int j=0;j<d_ways;j++) begin
          if(d_cache[set_id][j].tag==0) begin
          d_cache[set_id][j].tag=hex_value[31:20];
          d_cache[set_id][j].current_state = E;
          break;
          end
          else begin
            $display("Cache Full da venna!!");
            //function for LRU
          end
        end
        $display("Current state is %s!",current_state);
        $display("Now cache has %p",d_cache[set_id]);
    end
    end

    1:begin //write request to L1 data cache
      set_id = hex_value[19:6];
      if(d_cache_check(d_cache,hex_value)) begin
        $display("Cache hit for address %0h in way %0h",hex_value,d_way_idx);
        $display("Data written at address %0h in way %0h",hex_value,d_way_idx);
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
      else begin
        for(int j=0;j<d_ways;j++) begin
          if(d_cache[set_id][j].tag==0) begin
          d_cache[set_id][j].tag=hex_value[31:20];
          if(d_cache [set_id][j].current_state == I) begin
          $display("Data is also being written through to Main Memory");
          end
          d_cache[set_id][j].current_state = M;
          break;
          end
          else begin
            $display("Cache Full da venna!!");
            //function for LRU
          end
        end
        
    end
    $display("Current state is %s!",current_state);
        $display("Now cache has %p",d_cache[set_id]);
    end

    2:begin //Instruction fetch to L1 instructions cache
      set_id = hex_value[19:6];
      if(i_cache_check(i_cache,hex_value)) begin
        if(current_state == I) begin
        current_state = E;    //First cache hit comes from acting processor
        end
        else begin
          current_state = S;  //Considering that the 2nd cache hit comes from a different processor
        end
        $display("Current state is %s!",current_state);
      end
      else begin
        for(int j=0;j<i_ways;j++) begin
          if(i_cache[set_id][j].tag==0) begin
          i_cache[set_id][j].tag=hex_value[31:20];
          break;
          end
          else begin
            $display("Cache Full da venna!!");
          end
        end
        $display("Current state is %s!",current_state);
        $display("Now cache has %p",i_cache[set_id]);
      end
    end

    4:begin
        /*
          RFO doubt: what happens if P1 is not in M state then where does P2 get its data from? 
        */
    end

    8:begin
      i_cache_init();
      d_cache_init();
      current_state=I;
    end

    default: begin
      current_state = I;
    end

    
  endcase
endfunction

  // Main execution
  initial begin
    fd = $fopen("rwims.din", "r");
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
          break; //to remove
        end

      

      end

    


    end

  process_cache(0);
  #10;
  process_cache(1);
  #10;
  process_cache(8);

    
    $fclose(fd);
    $display("File operation done!");
  end
endmodule