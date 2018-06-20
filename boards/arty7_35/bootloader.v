module bootloader (
  input       CLK100MHZ,

  inout [3:0] jb,

  output      qspi_cs,
  inout [1:0] qspi_dq
);
  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  ////////
  //////// generate 48 mhz clock
  ////////
  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
   wire clk_48mhz;
   wire clk_48mhz_prebuf;
   wire clkfbout;
   wire clkfbout_buf;
   wire pin_clk_buf;
   wire locked;

  BUFG clkfbout_ibufg_i
   (.O (clk_48mhz),
    .I (clkfbout));
   

  IBUF clkin1_ibufg_i
   (.O (pin_clk_buf),
    .I (CLK100MHZ));

   MMCME2_ADV
  #(.BANDWIDTH            ("OPTIMIZED"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (5),
    .CLKFBOUT_MULT_F      (49.500),
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (20.625),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKIN1_PERIOD        (10.000))
  mmcm_i
   (
    .CLKFBOUT            (clkfbout),
    .CLKOUT0             (clk_48mhz_prebuf),
    .CLKFBIN             (clkfbout_buf),
    .CLKIN1              (pin_clk_buf),
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DWE                 (1'b0),
    // Ports for dynamic phase shift
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    // Other control and status signals
    .LOCKED              (locked),
    .PWRDWN              (1'b0),
    .RST                 (1'b0));

  BUFG clkfbout_buf_i
   (.O (clkfbout_buf),
    .I (clkfbout));

  BUFG clkout1_buf
   (.O   (clk_48),
    .I   (clk_48_clk_wiz_0));

  STARTUPE2 startup
  (.CLK                   (1'b0),
   .GSR                   (1'b0),
   .GTS                   (1'b0),
   .KEYCLEARB             (1'b1),
   .PACK                  (1'b0),
   .USRCCLKO              (cclk),
   .USRCCLKTS             (1'b0),
   .USRDONEO              (1'b1),
   .USRDONETS             (1'b0));


  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  ////////
  //////// instantiate tinyfpga bootloader
  ////////
  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  wire usb_p_tx;
  wire usb_n_tx;
  wire usb_p_rx;
  wire usb_n_rx;
  wire usb_tx_en;
  wire cclk;

  tinyfpga_bootloader tinyfpga_bootloader_inst (
    .clk_48mhz(clk_48mhz),
    .usb_p_tx(usb_p_tx),
    .usb_n_tx(usb_n_tx),
    .usb_p_rx(usb_p_rx),
    .usb_n_rx(usb_n_rx),
    .usb_tx_en(usb_tx_en),
    .spi_miso(qspi_dq[1]),
    .spi_cs(qspi_cs),
    .spi_mosi(qspi_dq[0]),
    .spi_sck(cclk),
    .boot(boot)
  );

  assign jb[0] = usb_tx_en ? usb_p_tx : 1'bz;
  assign jb[1] = usb_tx_en ? usb_n_tx : 1'bz;
  assign usb_p_rx = usb_tx_en ? 1'b1 : jb[0];
  assign usb_n_rx = usb_tx_en ? 1'b0 : jb[1];

  assign jb[2] = 1'b1;
  assign jb[3] = 1'b1;
endmodule
