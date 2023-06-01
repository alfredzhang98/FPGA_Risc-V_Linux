all: clean comp

comp:
	vcs -full64 -debug_acc+all -LDFLAGS -Wl,--no-as-needed -sverilog -l comp_log -f file.list

run:
	./simv -ucli -i run.tcl -l run_log

rung:
	./simv -gui -l run_log &

verdi:
	verdi -f file.list -ssf dump.fsdb -nolog &

verdi_base:
	verdi -f file.list
