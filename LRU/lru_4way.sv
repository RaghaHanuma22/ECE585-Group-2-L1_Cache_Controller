function automatic int lru_4way(logic [1:0] lru_counter[3:0], logic [1:0] access_way, logic access_valid);
    int evict_way = 0;

    if (access_valid) begin
        foreach (lru_counter[i]) begin
            if (i != access_way) 
                lru_counter[i] = lru_counter[i] + 1;
            else 
                lru_counter[i] = 2'b00;  // Accessed way becomes MRU
        end
    end

    foreach (lru_counter[i]) begin
        if (lru_counter[i] == 2'b11) 
            evict_way = i;  // The way with max counter is LRU
    end

    return evict_way;
endfunction
