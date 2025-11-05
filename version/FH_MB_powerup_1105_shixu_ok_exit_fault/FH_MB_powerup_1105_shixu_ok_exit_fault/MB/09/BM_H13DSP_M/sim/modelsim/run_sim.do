# Run simulation script for ModelSim
vlib work
vlog ../testbench/BM_H13DSP_M_TOP_tb.v
vsim work.BM_H13DSP_M_TOP_tb
run -all
quit