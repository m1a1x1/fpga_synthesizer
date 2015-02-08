// В данном проекте вводятся следующие определения:
//   jingle      - мелодия;
//   sample      - отсчет звукового сигнала;
//   sample rate - частота дискретизации.


module top(

      ///////// AUD /////////
      inout logic    AUD_ADCLRCK, // inout
      inout logic    AUD_BCLK,    // inout
      output logic   AUD_DACDAT,
      inout logic   AUD_DACLRCK,  // inout
      output         AUD_XCK,

      ///////// CLOCK /////////
      input          CLOCK_50,

      ///////// FPGA /////////
      output         FPGA_I2C_SCLK,
      inout          FPGA_I2C_SDAT,

      ///////// PS2 /////////
      inout          PS2_CLK,
      inout          PS2_DAT,

      ///////// KEY /////////
      input   [3:0]  KEY,

      ///////// SW /////////
      input   [9:0]  SW,

      ///////// HEX /////////
      output  [6:0]  HEX0,

      output  [6:0]  HEX1,    

      output  [6:0]  HEX2,  

      output  [6:0]  HEX3,
      
      output  [6:0]  HEX4,  

      output  [6:0]  HEX5,

      ///////// LEDR /////////
      output  [9:0]  LEDR

      //SIMUlATION//
      //input         AUD_CTRL_CLK
);

parameter VERSION       = 2; 
parameter JINGLE_CNT    = 8;
parameter SAMPLE_WIDTH  = 16;
parameter ROM_INIT_FILE = "jingls.hex";

//=======================================================
//  REG/WIRE declarations
//=======================================================


wire       DLY_RST; 
// For Audio CODEC

reg        sw0_r; // on/off switch 

logic                           samp_wr_req;
logic [SAMPLE_WIDTH-1:0]        samp_data;

logic [(SAMPLE_WIDTH*2)-1:0]    lr_chan_data;

logic                           dac_fifo_almfull;

logic                           AUD_CTRL_CLK;
//=======================================================
//  Structural coding
//=======================================================
assign FPGA_I2C_SDAT = 1'bz;     						
assign FPGA_I2C_SCLK = 1'bz; 
// initial //  
assign AUD_ADCLRCK = 1'bz;     					
assign AUD_DACLRCK = 1'bz;     					
assign AUD_DACDAT  = 1'bz;     					
assign AUD_BCLK    = 1'bz;     						
assign AUD_XCK     = 1'bz;     						
assign AUD_XCK     = AUD_CTRL_CLK;
assign AUD_ADCLRCK = AUD_DACLRCK;

wire [7:0] cntr_to_ps2_dcdr;
wire       cntr_to_ps2_dcdr_en;

wire [2:0] ps2_to_dcdr;
wire       ps2_to_dcdr_en;

// sync switch
always@( posedge CLOCK_50 )
    begin
      sw0_r <= SW[ 0 ];
    end	
// Reset Delay Timer
Reset_Delay reset(	

 .iCLK   ( CLOCK_50 ),
 .oRESET ( DLY_RST  )

);
//	 Audio VGA PLL clock							 
VGA_Audio pll(

  .refclk   ( CLOCK_50     ), // refclk.clk
  .rst      ( ~DLY_RST     ), // reset.reset
  .outclk_0 ( VGA_CTRL_CLK ), // outclk0.clk
  .outclk_1 ( AUD_CTRL_CLK ), // outclk1.clk
  .outclk_2 ( mVGA_CLK     ), // outclk2.clk
  .locked   (              )  // locked.export

);

// equal data for left and right channels
assign lr_chan_data = { samp_data, samp_data };

audio_send #(
  .JINGLE_CNT       ( JINGLE_CNT     ),
  .SAMPLE_WIDTH     ( SAMPLE_WIDTH   ),
  .INIT_FILE        ( ROM_INIT_FILE  )
  
)  a_send(

  .clk_i            ( CLOCK_50       ),
  .rst_i            ( ~DLY_RST       ),

  .audio_ena_i      ( sw0_r          ),
  .jingle_num_i     ( ps2_to_dcdr    ),
  .jingle_num_val_i ( ps2_to_dcdr_en ),

  .dac_fifo_almfull_i ( dac_fifo_almfull  ),
  .samp_data_o      ( samp_data      ),
  .samp_wr_req_o    ( samp_wr_req    ),
  .clear_dac_o      (                )

);

AUDIO_DAC #(

  .DATA_WIDTH  ( SAMPLE_WIDTH * 2 ), 
  .SAMPLE_RATE ( 48000            )

) a_dac (

  // Audio Side
  .clk           ( CLOCK_50       ),
  .reset         ( ~DLY_RST       ),
  .write         ( samp_wr_req    ),
  .writedata     ( lr_chan_data   ),

  .almost_full   ( dac_fifo_almfull ),
  .clear         (                ),

  .clk_18        ( AUD_CTRL_CLK   ),
  .bclk          ( AUD_BCLK       ),
  .daclrc        ( AUD_DACLRCK    ),
  .dacdat        ( AUD_DACDAT     )

);	

PS2_Controller ps2(

  .CLOCK_50                               ( CLOCK_50             ),
  .reset                                  ( ~DLY_RST           ),

  .the_command                            (                       ),
  .send_command                           (                       ),

  // Bidirectionals
  .PS2_CLK                                ( PS2_CLK               ),
  .PS2_DAT                                ( PS2_DAT               ),

  .command_was_sent                       (                       ),
  .error_communication_timed_out          (                       ),

  .received_data                          ( cntr_to_ps2_dcdr      ),
  .received_data_en                       ( cntr_to_ps2_dcdr_en   )

);

wire test_led;
wire test_led_val;

PS2_decoder ps2_dcdr(

  .clk_i          ( CLOCK_50            ),
  .rst_i          ( ~DLY_RST           ),
  .ps2_data_i      ( cntr_to_ps2_dcdr    ),
  .ps2_data_val_i  ( cntr_to_ps2_dcdr_en ),

  .num_o           ( ps2_to_dcdr         ),
  .num_val_o       ( ps2_to_dcdr_en      ),
  .vol_cntrl_o     ( test_led            ),
  .vol_cntrl_val_o ( test_led_val        )

);

assign LEDR[8] =  test_led && test_led_val;
assign LEDR[9] = ~test_led && test_led_val;

wire [6:0] vol_cntl_to_print;

volume_control vlmc(

  .clk_i         ( CLOCK_50          ),
  .rst_i         ( ~DLY_RST         ),
  .vol_cng_i     ( test_led          ),
  .vol_cng_val_i ( test_led_val      ),

  .vol_lvl_o     ( vol_cntl_to_print )

);

print_vol prvm(

  .vol_lvl_i ( vol_cntl_to_print ),
  
  .v_o       ( HEX5              ),
  .o_o       ( HEX4              ),
  .l_o       ( HEX3              ),
  .vol1_o    ( HEX0              ),
  .vol2_o    ( HEX1              ),
  .vol3_o    ( HEX2              )
  
);

decoder dcdr(

  .clk_i     ( CLOCK_50       ),
  .num_i     ( ps2_to_dcdr    ), 
  .num_val_i ( ps2_to_dcdr_en ),

  .dig_o     ( LEDR )
  //.dig_val_o ()

);						  

logic [6:0] volume;

vol_convert vc(
 .vol_norm_i   ( vol_cntl_to_print ),
 .vol_to_I2C_o ( volume            )

);

I2C_AV_Config I2C_Conf(

  // Host Side
  .iCLK     ( CLOCK_50      ),
  .iRST_N   ( DLY_RST     ),
  .iVOLUME  ( volume        ),
  // I2C Side
  .I2C_SCLK ( FPGA_I2C_SCLK ),
  .I2C_SDAT ( FPGA_I2C_SDAT )

);

endmodule
