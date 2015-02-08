// В данном проекте вводятся следующие определения:
//   jingle      - мелодия;
//   sample      - отсчет звукового сигнала;
//   sample rate - частота дискретизации.


module top(

      ///////// AUD /////////
      inout          AUD_ADCLRCK, 
      inout          AUD_BCLK,    
      output         AUD_DACDAT,
      inout          AUD_DACLRCK,
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

);

parameter JINGLE_CNT    = 8;
parameter SAMPLE_WIDTH  = 16;
parameter ROM_INIT_FILE = "jingls.hex";

//=======================================================
//  TRI-STATE assigment
//=======================================================

assign FPGA_I2C_SDAT = 1'bz;     						
assign FPGA_I2C_SCLK = 1'bz; 

assign AUD_ADCLRCK   = 1'bz;     					
assign AUD_DACLRCK   = 1'bz;     					
assign AUD_DACDAT    = 1'bz;     					
assign AUD_BCLK      = 1'bz;     						
assign AUD_XCK       = 1'bz;     						
assign AUD_XCK       = AUD_CTRL_CLK;
assign AUD_ADCLRCK   = AUD_DACLRCK;

//=======================================================
//  REG/WIRE declarations
//=======================================================

wire                           DLY_RST; 

reg                            sw0_r; // on/off switch 

logic                   [6:0]  volume;
logic                   [6:0]  volume_to_I2C;

logic                   [7:0]  ps2_received_data;
logic                          ps2_received_data_en;

logic                          dac_fifo_almfull;
logic  [(SAMPLE_WIDTH*2)-1:0]  dac_fifo_data;
logic                          dac_fifo_wr_req;

//=======================================================
//  MAIN
//=======================================================

// On/off from switch
always@( posedge CLOCK_50 )
    begin
      sw0_r <= SW[ 0 ];
    end	

// Reset Delay Timer
Reset_Delay reset(	

  .iCLK      ( CLOCK_50     ),
  .oRESET    ( DLY_RST      )

);

// Audio PLL clock							 
VGA_Audio pll(

  .refclk    ( CLOCK_50      ), // refclk.clk
  .rst       ( ~DLY_RST      ), // reset.reset
  .outclk_0  (               ), // outclk0.clk
  .outclk_1  ( AUD_CTRL_CLK  ), // outclk1.clk
  .outclk_2  (               ), // outclk2.clk
  .locked    (               )  // locked.export

);

// Volume on inticators
print_vol prvm(

  .vol_lvl_i ( volume        ),
  
  .v_o       ( HEX5          ),
  .o_o       ( HEX4          ),
  .l_o       ( HEX3          ),
  .vol1_o    ( HEX0          ),
  .vol2_o    ( HEX1          ),
  .vol3_o    ( HEX2          )
  
);

// Configuration of audio codec
I2C_AV_Config I2C_Conf(

  // Host Side
  .iCLK      ( CLOCK_50      ),
  .iRST_N    ( DLY_RST       ),
  .iVOLUME   ( volume_to_I2C ),
  // I2C Side
  .I2C_SCLK  ( FPGA_I2C_SCLK ),
  .I2C_SDAT  ( FPGA_I2C_SDAT )

);

// Convert volume for sending to audio codec
vol_convert vc(

  .vol_norm_i   ( volume        ),
  .vol_to_I2C_o ( volume_to_I2C )

);

// Audio codec
AUDIO_DAC #(

  .DATA_WIDTH   ( SAMPLE_WIDTH * 2 ), 
  .SAMPLE_RATE  ( 48000            )

) a_dac (

  // Audio Side
  .clk          ( CLOCK_50         ),
  .reset        ( ~DLY_RST         ),
  .write        ( dac_fifo_wr_req  ),
  .writedata    ( dac_fifo_data    ),

  .almost_full  ( dac_fifo_almfull ),
  .clear        (                  ),

  .clk_18       ( AUD_CTRL_CLK     ),
  .bclk         ( AUD_BCLK         ),
  .daclrc       ( AUD_DACLRCK      ),
  .dacdat       ( AUD_DACDAT       )

);	

// Get info about key pressed 
PS2_Controller ps2(

  .CLOCK_50                      ( CLOCK_50             ),
  .reset                         ( ~DLY_RST             ),

  .the_command                   (                      ),
  .send_command                  (                      ),

  // Bidirectionals
  .PS2_CLK                       ( PS2_CLK              ),
  .PS2_DAT                       ( PS2_DAT              ),

  .command_was_sent              (                      ),
  .error_communication_timed_out (                      ),

  .received_data                 ( ps2_received_data    ),
  .received_data_en              ( ps2_received_data_en )

);

top_synth #(

  .JINGLE_CNT         ( JINGLE_CNT           ),
  .SAMPLE_WIDTH       ( SAMPLE_WIDTH         ), 
  .ROM_INIT_FILE      ( ROM_INIT_FILE        )

) synth(

  .clk_i              ( CLOCK_50             ),
  .rst_i              ( ~DLY_RST             ), //active 1

  .audio_ena_i        ( sw0_r                ),

  .dac_fifo_almfull_i ( dac_fifo_almfull     ),

  .samp_wr_req_o      ( dac_fifo_wr_req      ),
  .lr_chan_data_o     ( dac_fifo_data        ),

  .ps2_data_i         ( ps2_received_data    ),
  .ps2_data_en_i      ( ps2_received_data_en ),

  .volume_o           ( volume               )

);

endmodule
