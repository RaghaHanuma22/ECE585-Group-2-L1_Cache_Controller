vlog pkg_cache.sv msd.sv
vsim msd +TRACE_FILE=new_trace.din +MODE=0
run -all
quit -sim

#vsim msd +TRACE_FILE=trial_trace.din
#run -all