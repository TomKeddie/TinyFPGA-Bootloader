PROJNAME=arty7_35
PROJPART=xc7a35ticsg324-1l
PROJFILES=bootloader.v

all : $(PROJNAME).bit

$(PROJNAME).bit : vivado_build_$(PROJNAME).tcl $(PROJNAME).xdc
	vivado -mode tcl -source $<
	mv -f $(PROJNAME).bit $(PROJNAME).bin

vivado_build_$(PROJNAME).tcl : ../common/vivado_build.tcl Makefile
	sed -e "s+PROJNAME+$(PROJNAME)+g" -e "s+PROJPART+$(PROJPART)+g"  -e "s+PROJFILES+$(PROJFILES)+g" < $< > $@

$(PROJNAME).xdc : Arty/Resources/XDC/Arty_Master.xdc Makefile
	echo "## Voltage config" > $@
	echo "set_property CFGBVS VCCO [current_design]" >> $@
	echo "set_property CONFIG_VOLTAGE 3.3 [current_design]" >> $@
	echo "set_property BITSTREAM.GENERAL.COMPRESS True [current_design]" >> $@
	grep -E 'jb\[[0-3]|CLK100MHZ|qspi_cs|qspi_dq\[[0-1]' $< | cut -c2- >> $@

clean :
	rm -rf $(PROJNAME).bin vivado*.log vivado*.jou vivado*.str vivado_build_$(PROJNAME).tcl $(PROJNAME).cache $(PROJNAME).runs $(PROJNAME).xdc .Xil $(PROJNAME).ip_user_files $(PROJNAME).xpr $(PROJNAME).hw
