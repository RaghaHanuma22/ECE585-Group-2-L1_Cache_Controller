function automatic int lru_8way(logic [2:0] lru_counter[7:0], logic [2:0] access_way, logic access_valid);
    int evict_way = 0;

    if (access_valid) begin
        foreach (lru_counter[i]) begin
            if (i != access_way) 
                lru_counter[i] = lru_counter[i] + 1;
            else 
                lru_counter[i] = 3'b000;  // Accessed way becomes MRU
        end
    end

    foreach (lru_counter[i]) begin
        if (lru_counter[i] == 3'b111) 
            evict_way = i;  // The way with max counter is LRU
    end

    return evict_way;
endfunction

