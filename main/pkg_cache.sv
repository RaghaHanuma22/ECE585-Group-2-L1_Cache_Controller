package pkg_cache;
parameter d_ways = 8; //8 way
parameter i_ways = 4; //4 way
parameter sets = 16384;  //16K sets
parameter by_of = 512; //64 bytes so 512 bits
parameter TAG_WIDTH = 12;
int cache_hit;
int cache_miss;


typedef struct packed {
  logic [TAG_WIDTH-1:0] tag;     // Tag bits
  logic [1:0] lru_bits;
  logic [511:0] data;            // 512-bit (64-byte) data
} i_cache_line_t;

typedef struct packed {
  logic [TAG_WIDTH-1:0] tag;     // Tag bits
  logic [2:0] lru_bits;
  logic [511:0] data;            // 512-bit (64-byte) data
} d_cache_line_t;

i_cache_line_t i_cache [i_ways-1:0] [sets-1:0];
d_cache_line_t d_cache [d_ways-1:0] [sets-1:0];

function automatic int i_cache_check(i_cache_line_t i_cache_mem [i_ways-1:0] [sets-1:0], bit [31:0] address);

int hit=0;
logic [13:0] set_idx = address[19:6];
logic [11:0] tag = address[31:20];

for(int i=0;i<i_ways;i++) begin 
  if(i_cache_mem[i][set_idx].tag == tag) begin
  hit=1;
  break;
  end
end

if(hit) 
  $display("Cache hit!");
  else
  $display("Cache miss!");

  return hit;    

endfunction

function automatic int d_cache_check(d_cache_line_t d_cache_mem [d_ways-1:0] [sets-1:0], bit [31:0] address);

int hit=0;
logic [13:0] set_idx = address[19:6];
logic [11:0] tag = address[31:20];

for(int i=0;i<d_ways;i++) begin 
  if(d_cache_mem[i][set_idx].tag == tag) begin
  hit=1;
  break;
  end
end

if(hit) 
  $display("Cache hit!");
  else
  $display("Cache miss!");

return hit;    

endfunction

function int increment_hit();
    cache_hit++;
endfunction

function int increment_miss();
    cache_miss++;
endfunction


endpackage