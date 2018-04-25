TARGET = dds_papilio_pro_top_str
VLOGS = 
VLOGS_ALL = $(VLOGS)
MYHDLS = rs232tx.vhd rs232rx.vhd
VHDLS = dds_papilio_pro_top_str.vhd\
	sim/tb.vhd\
	myhdl/rs232tx.vhd\
	myhdl/rs232rx.vhd\
	myhdl/pck_myhdl_090.vhd\
	components/dds/phase_accumulator.vhdl\
	components/dds/lut.vhdl\
	components/dds/lut_interp.vhdl\
	components/dds/folder.vhdl\
	components/dds/dds_tb.vhdl\
	components/eth_phy/rmii_tx.vhdl\
	components/eth_phy/rmii_rx.vhdl\
	components/eth_phy/mdio.vhdl\
	components/eth_phy/phy_tb.vhdl\
	ip/pll/clk_wiz_v3_6.vhd

VHDLS_ALL = $(VHDLS)
SRCS_ALL = $(VLOGS_ALL) $(VHDLS_ALL)
TB = tb
PART = xc6slx9-tqg144-3
MAP_OPTS = -intstyle ise -p $(PART) -w -logic_opt off -ol high -t 1 -xt 0 -register_duplication off -r 4 -global_opt off -mt off -ir off -pr off -lc off -power off
PAR_OPTS = -w -intstyle ise -ol high -mt off 
TRCE_OPTS = -intstyle ise -v 3 -s 3 -n 3 -fastpaths
ISE_PATH = /home/bjohan/opt/xilinx/14.7/ISE_DS
ISE_SETUP = $(ISE_PATH)/settings64.sh
TEST_BENCH ?= tb
VCD_FILE ?= simulation_result.vcd
XIL_ENV_CMD ?= coregen
define run_xilinx_environment
    bash -c 'source $(ISE_SETUP) ; $(1)'
endef


all: fpga_target
BITGEN_OPTS = \
	-w \
	-g DebugBitstream:No \
	-g Binary:no \
	-g CRC:Enable \
	-g Reset_on_err:No \
	-g ConfigRate:2 \
	-g ProgPin:PullUp \
	-g TckPin:PullUp \
	-g TdiPin:PullUp \
	-g TdoPin:PullUp \
	-g TmsPin:PullUp \
	-g UnusedPin:PullDown \
	-g UserID:0xFFFFFFFF \
	-g ExtMasterCclk_en:No \
	-g SPI_buswidth:1 \
	-g TIMER_CFG:0xFFFF \
	-g multipin_wakeup:No \
	-g StartUpClk:CClk \
	-g DONE_cycle:4 \
	-g GTS_cycle:5 \
	-g GWE_cycle:6 \
	-g LCK_cycle:NoWait \
	-g Security:None \
	-g DonePipe:No \
	-g DriveDone:No \
	-g en_sw_gsr:No \
	-g drive_awake:No \
	-g sw_clk:Startupclk \
	-g sw_gwe_cycle:5 \
	-g sw_gts_cycle:4 


fpga_target: $(TARGET).bit
	sudo papilio-prog -f $(TARGET).bit

xst/projnav.tmp:
	@mkdir -p xst/projnav.tmp

$(TARGET).lso:
	@echo work > $(TARGET).lso

.PHONY: proj_struct
proj_struct: xst/projnav.tmp $(TARGET).lso
	@echo "Making xst project structure"	

.PHONY: xil_env_cmd
xil_env_cmd :
	$(call run_xilinx_environment, $(XIL_ENV_CMD));

create_plan_ahead_project.tcl: $(TARGET).syr $(TARGET).ucf $(TARGET).twx $(TARGET).ncd
	@echo "start_gui" > create_plan_ahead_project.tcl
	@echo "create_project tmp_proj /tmp/tmp_proj -part $(PART) -force" >> create_plan_ahead_project.tcl
	@echo "set_property design_mode GateLvl [current_fileset]" >> create_plan_ahead_project.tcl
	@echo "add_files -norecurse $(TARGET).ngc" >> create_plan_ahead_project.tcl
	@echo "import_files -force -norecurse" >> create_plan_ahead_project.tcl
	@echo "import_files -fileset constrs_1 -force -norecurse $(TARGET).ucf" >> create_plan_ahead_project.tcl
	@echo "import_as_run -run impl_1 -twx $(TARGET).twx $(TARGET).ncd" >> create_plan_ahead_project.tcl
	#@echo "open_run impl_1" >> create_plan_ahead_project.tcl
	#@echo "reset_run impl_1" >> create_plan_ahead_project.tcl
	#@echo "launch_runs impl_1" >> create_plan_ahead_project.tcl
	#@echo "wait_on_run impl_1" >> create_plan_ahead_project.tcl
	#@echo "report_drc -name drc_1" >> create_plan_ahead_project.tcl

plan_ahead : create_plan_ahead_project.tcl
	$(call run_xilinx_environment, planAhead -source create_plan_ahead_project.tcl)
    

sim_commands.tcl: FORCE
	echo "vcd dumpfile $(VCD_FILE)" > sim_commands.tcl
	echo "vcd dumpvars -m $(TEST_BENCH) -l 0" >> sim_commands.tcl
	echo "run $(SIM_RUN)" >> sim_commands.tcl
	echo "exit" >> sim_commands.tcl	
FORCE:

$(TARGET).prj: $(SRCS_ALL)
	@rm -f $(TARGET).prj
	@for i in $(MYHDLS); do make -C myhdl $$i; done
	@for i in $(VLOGS); do echo verilog work '"'$$i'"' >> $(TARGET).prj; done
	@for i in $(VHDLS); do echo vhdl work '"'$$i'"' >> $(TARGET).prj; done
	@for i in $(VLOGS); do echo verilog isim_temp '"'$$i'"' >> $(TARGET).prj; done
	@for i in $(VHDLS); do echo vhdl isim_temp '"'$$i'"' >> $(TARGET).prj; done

$(TB).prj: $(SRCS_ALL)
	@rm -f $(TB).prj
	@for i in $(VLOGS); do echo verilog work '"'$$i'"' >> $(TB).prj; done
	@for i in $(VHDLS); do echo vhdl work '"'$$i'"' >> $(TB).prj; done

$(TB).syr: proj_struct $(TARGET).prj $(TB).xst $(TB).prj
	$(call run_xilinx_environment, xst -intstyle ise -ifn $(TB).xst -ofn $(TB).syr)

$(TB).ngd: $(TB).syr
	$(call run_xilinx_environment, ngdbuild -intstyle ise -dd _ngo -nt timestamp -p $(PART) $(TB).ngc $(TB).ngd)

#$(TARGET).exe: $(TB).ngd
#	$(call run_xilinx_environment, fuse -intstyle ise -incremental -lib secureip -o $(TARGET).exe -prj $(TARGET).prj work.tb {})

$(TARGET).syr $(TARGET).ngc: $(TARGET).xst $(TARGET).prj xst/projnav.tmp $(TARGET).lso
	$(call run_xilinx_environment, xst -ifn $(TARGET).xst -ofn $(TARGET).syr | tee synth.log)

$(TARGET).ngd: $(TARGET).syr $(TARGET).ucf $(TARGET).ngc
	$(call run_xilinx_environment, ngdbuild -dd _ngo -uc $(TARGET).ucf -nt timestamp -p $(PART) "$(TARGET).ngc" $(TARGET).ngd)

$(TARGET)_map.ncd: $(TARGET).ngd
	$(call run_xilinx_environment, map $(MAP_OPTS) -o $(TARGET)_map.ncd $(TARGET).ngd $(TARGET).pcf | tee map.log)

$(TARGET).ncd: $(TARGET)_map.ncd
	$(call run_xilinx_environment, par $(PAR_OPTS) $(TARGET)_map.ncd $(TARGET).ncd $(TARGET).pcf | tee place_and_route.log)

$(TARGET).twr $(TARGET).twx: $(TARGET).ncd
	# -xml dds_papilio_pro_top_str.twx dds_papilio_pro_top_str.ncd -o dds_papilio_pro_top_str.twr dds_papilio_pro_top_str.pcf 
	$(call run_xilinx_environment, trce $(TRCE_OPTS) -xml $(TARGET).twx $(TARGET).ncd -o $(TARGET).twr $(TARGET).pcf)

$(TARGET).bit: $(TARGET).ncd
	$(call run_xilinx_environment, bitgen $(BITGEN_OPTS) $(TARGET).ncd)

$(TARGET).exe : $(TARGET).prj
	$(call run_xilinx_environment, fuse $(TEST_BENCH) -prj $(TARGET).prj -o $(TARGET).exe)

sim_gui : $(TARGET).exe
ifndef WCFG
	$(call run_xilinx_environment, ./$(TARGET).exe -gui)
endif
ifdef WCFG
	$(call run_xilinx_environment, ./$(TARGET).exe -gui -view $(WCFG))
endif

vcd : $(TARGET).exe sim_commands.tcl
	$(call run_xilinx_environment, ./$(TARGET).exe -tclbatch sim_commands.tcl)
	
#$(TARGET).svf: $(TARGET).bit impact.cmd
#	sed -e s/XXX/$(subst .bit,,$<)/ < impact.cmd > tmp.cmd
#	impact -batch tmp.cmd

clean:
	rm -f $(TARGET).bgn $(TARGET).ngc $(TARGET).svf $(TARGET).ngd $(TARGET).bit $(TARGET).twr $(TARGET).ncd $(TARGET)_map.ncd $(TARGET)_map.*
	rm -f $(TARGET).bld $(TARGET).drc $(TARGET)_ngdbuild.xrpt $(TARGET)_pad.* $(TARGET).pad $(TARGET).par $(TARGET)_par.xrpt $(TARGET).ngr
	rm -f $(TARGET).pcf $(TARGET)_summary.xml $(TARGET).unroutes $(TARGET)_usage.xml $(TARGET)_xst.xrpt $(TARGET).syr $(TARGET).ptwx $(TARGET).xpi
	rm -rf xst
	rm -rf xlnx_auto_*
	rm -rf _xmsgs
	rm -rf _ngo
	rm -f tmp.cmd
	rm -f create_plan_ahead_project.tcl
	rm -f sim_commands.tcl
	rm -f _impactbatch.log
	rm -f $(TARGET).prj
	rm -f $(TARGET).twx
	rm -f $(TARGET).lso
	rm -f $(TARGET)_bitgen.xwbt
	rm -f par_usage_statistics.html
	rm -f usage_statistics_webtalk.html
	rm -f webtalk.log
	rm -f synth.log
	rm -f map.log
	rm -f place_and_route.log
	rm -f $(TARGET).exe isim.log isim.wdb fuse.log fuseRelaunch.cmd fuse.xmsgs
	rm -f planAhead*
	rm -rf isim

