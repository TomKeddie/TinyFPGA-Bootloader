# Build template customised for PROJ

set common_files [list ../../common/edge_detect.v ../../common/serial.v ../../common/tinyfpga_bootloader.v ../../common/usb_fs_in_arb.v ../../common/usb_fs_in_pe.v ../../common/usb_fs_out_arb.v ../../common/usb_fs_out_pe.v ../../common/usb_fs_pe.v ../../common/usb_fs_rx.v ../../common/usb_fs_tx_mux.v ../../common/usb_fs_tx.v ../../common/usb_reset_det.v ../../common/usb_serial_ctrl_ep.v ../../common/usb_spi_bridge_ep.v]

create_project -force -part PROJPART PROJNAME

# Common files
add_files $common_files

# Project specific files
add_files [list PROJFILES]
set_property top bootloader [current_fileset]
add_files PROJNAME.xdc

# Synth
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

launch_runs impl_1 -jobs 4 -to_step route_design
wait_on_run impl_1
set directory [get_property DIRECTORY [get_runs impl_1]]
open_checkpoint $directory/bootloader_routed.dcp
write_bitstream -force -bin_file PROJNAME.bit
exit

