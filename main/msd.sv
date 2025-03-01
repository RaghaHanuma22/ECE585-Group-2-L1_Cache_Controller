module msd;
import pkg_cache::*;
  int fd;
  string line, hex_str;
  bit [3:0] n;  // To store the leading 0
  logic [31:0] hex_value;   // To store the 8-digit hex value (32 bits)
  
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
        end
      end

    


    end

    
    $fclose(fd);
    $display("File operation done!");
  end
endmodule