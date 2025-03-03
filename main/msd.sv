module msd;
import pkg_cache::*;
  int fd;
  string line, hex_str;
  bit [3:0] n;  // To store the leading 0
  logic [31:0] hex_value;   // To store the 8-digit hex value (32 bits)
  bit [13:0] set_id;

typedef enum bit [1:0] {M=2'b00,E=2'b01,S=2'b10,I=2'b11} mesi_state_t;

mesi_state_t current_state=I;
/*
function mesi_state_t next_state(mesi_state_t current_state, );

endfunction
*/

  // Main execution
  initial begin
    fd = $fopen("rwims.din", "r");
    if(fd)
      $display("File opened!!");
    else 
      $display("File was not opened!");
    
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
          break; //to remove
        end
      end

    


    end

  case (n)
    0:begin
      set_id = hex_value[19:6];
      if(i_cache_check(i_cache,hex_value)) begin
        current_state = E;
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
    default: begin
      current_state = I;
    end
  endcase

    
    $fclose(fd);
    $display("File operation done!");
  end
endmodule