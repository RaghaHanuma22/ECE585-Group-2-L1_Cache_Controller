package pkg_cache;
parameter d_ways = 8; //8 way
parameter i_ways = 4; //4 way
parameter sets = 16384;  //16K sets
parameter by_of = 512; //64 bytes so 512 bits
parameter TAG_WIDTH = 12;
bit [2:0] d_way_idx;
bit [1:0] i_way_idx;
int d_cache_hit;
int d_cache_miss;
int d_cache_read;
int cache_write;
int i_cache_hit;
int i_cache_miss;
int i_cache_read;
bit empty_flag;
bit invalid_flag;

typedef enum bit [1:0] {M=2'b00,E=2'b01,S=2'b10,I=2'b11} mesi_state_t;

mesi_state_t current_state=I;

typedef struct packed {
  bit [TAG_WIDTH-1:0] tag;     // Tag bits
  logic [1:0] lru_bits;
  logic [511:0] data;            // 512-bit (64-byte) data
  mesi_state_t current_state;
} i_cache_line_t;

typedef struct packed {
  bit [TAG_WIDTH-1:0] tag;     // Tag bits
  logic [2:0] lru_bits;
  logic [511:0] data;            // 512-bit (64-byte) data
  mesi_state_t current_state;
} d_cache_line_t;

i_cache_line_t i_cache [sets-1:0] [i_ways-1:0];
d_cache_line_t d_cache [sets-1:0] [d_ways-1:0];

function automatic int i_cache_check(i_cache_line_t i_cache_mem [sets-1:0] [i_ways-1:0], bit [31:0] address);

int hit=0;
logic [13:0] set_idx = address[19:6];
logic [11:0] tag = address[31:20];

for(int i=0;i<i_ways;i++) begin 
  if(i_cache_mem[set_idx][i].tag == tag && ~(i_cache_mem[set_idx][i].current_state == I)) begin
  hit=1;
  i_way_idx=i;
  break;
  end
end

if(hit) begin
  $display("Cache hit!");
  return 1;
end
  else begin
  $display("Cache miss!");
  return 0;
  end


endfunction

function automatic int d_cache_check(d_cache_line_t d_cache_mem [sets-1:0] [d_ways-1:0], bit [31:0] address);

int hit=0;
logic [13:0] set_idx = address[19:6];
logic [11:0] tag = address[31:20];

for(int i=0;i<d_ways;i++) begin 
  if(d_cache_mem[set_idx][i].tag == tag && ~(d_cache_mem[set_idx][i].current_state == I)) begin
  hit=1;
  d_way_idx=i;
  break;
  end
end

if(hit) begin
  //$display("Cache hit!");
  return 1;
end
  else begin
  $display("Cache miss!");
  return 0;
  end 

endfunction


function void i_cache_init();
  $display("Initializing/Resetting Instn Cache!");
  for(int i=0;i<sets;i++) begin
    for(int j=0;j<i_ways;j++) begin
      i_cache [i][j] ='0;
      i_cache [i][j].current_state = I;
      i_cache [i][j].lru_bits = 2'b00;
    end
  end
endfunction

function void d_cache_init();
  $display("Initializing/Resetting Data Cache!");
  for(int i=0;i<sets;i++) begin
    for(int j=0;j<d_ways;j++) begin
      d_cache [i][j] ='0;
      d_cache [i][j].current_state = I;
      d_cache [i][j].lru_bits = 3'b000;
    end
  end
endfunction

//////////////////////////LRU///////////////////////////////////////


// LRU Update task for instruction cache - uses 2-bit LRU tracking
function automatic void i_LRU_Update(logic [13:0] set_idx, logic [1:0] way_idx);
    logic [1:0] current_lru;
    
    // Store current LRU value of the accessed way
    current_lru = i_cache[set_idx][way_idx].lru_bits;
    
    // Update LRU values for all ways in this set
    for(int i = 0; i < i_ways; i++) begin
        // If way's LRU value is greater than the accessed way's value, decrement it
        if(i_cache[set_idx][i].lru_bits > current_lru)
            i_cache[set_idx][i].lru_bits = i_cache[set_idx][i].lru_bits - 1;
    end
    
    // Set the accessed way's LRU value to maximum (3 for 2-bit field)
    i_cache[set_idx][way_idx].lru_bits = 2'b11;
endfunction

// LRU Update task for data cache - uses 3-bit LRU tracking
function automatic void d_LRU_Update(logic [13:0] set_idx, logic [2:0] way_idx);
    logic [2:0] current_lru;
    
    // Store current LRU value of the accessed way
    current_lru = d_cache[set_idx][way_idx].lru_bits;
    
    // Update LRU values for all ways in this set
    for(int i = 0; i < d_ways; i++) begin
        // If way's LRU value is greater than the accessed way's value, decrement it
        if(d_cache[set_idx][i].lru_bits > current_lru)
            d_cache[set_idx][i].lru_bits = d_cache[set_idx][i].lru_bits - 1;
    end
    
    // Set the accessed way's LRU value to maximum (7 for 3-bit field)
    d_cache[set_idx][way_idx].lru_bits = 3'b111;
endfunction

// Function to find LRU way for instruction cache
function automatic logic [1:0] find_i_LRU_way(logic [13:0] set_idx);
    for(int i = 0; i < i_ways; i++) begin
        // Find way with LRU value of 0 (least recently used)
        if(i_cache[set_idx][i].lru_bits == 0)
            return i[1:0];
    end
    
    // Fallback - should never reach here if LRU is properly maintained
    return 0;
endfunction


// Function to find LRU way for data cache
function automatic logic [2:0] find_d_LRU_way(logic [13:0] set_idx);
    for(int i = 0; i < d_ways; i++) begin
        // Find way with LRU value of 0 (least recently used)
        if(d_cache[set_idx][i].lru_bits == 0)
            return i[2:0];
    end
    
    // Fallback - should never reach here if LRU is properly maintained
    return 0;
endfunction



///////////////////////////////////////////////////////////////////



function void increment_d_hit();
     d_cache_hit++;
endfunction

function void increment_d_miss();
     d_cache_miss++;
endfunction

function void increment_d_read();
     d_cache_read++;
endfunction

function void increment_write();
     cache_write++;
endfunction

function void increment_i_hit();
     i_cache_hit++;
endfunction

function void increment_i_miss();
     i_cache_miss++;
endfunction

function void increment_i_read();
     i_cache_read++;
endfunction


function void d_hit_ratio();

	$display ("Data Cache Hit Ratio = %0f percent", ((real'(d_cache_hit) / (d_cache_hit + d_cache_miss)))*100);

endfunction

function void i_hit_ratio();

	$display ("Instruction Cache Hit Ratio = %0f percent", ((real'(i_cache_hit) / (i_cache_hit + i_cache_miss)))*100);

endfunction

endpackage


