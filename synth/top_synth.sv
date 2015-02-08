// В данном проекте вводятся следующие определения:
//   jingle      - мелодия;
//   sample      - отсчет звукового сигнала;
//   sample rate - частота дискретизации.


module top_synth
#(

  parameter JINGLE_CNT    = 8;
  parameter SAMPLE_WIDTH  = 16;
  parameter ROM_INIT_FILE = "jingls.hex";

)
(
  
  input                           clk_i,
  input                           rst_i, //active 1(000100)
   
  input                           audio_ena_i,

  //DAC_if:
  input                           dac_fifo_almfull_i,

  output                          samp_wr_req_o,
  output  [(SAMPLE_WIDTH*2)-1:0]  lr_chan_data_o,

  //PS2_if:
  input                    [7:0]  ps2_data_i,
  input                           ps2_data_en_i,

  output                   [6:0]  volume_o

);


logic                             samp_wr_req;
logic         [SAMPLE_WIDTH-1:0]  samp_data;


logic                             dac_fifo_almfull;

logic                  

logic   [$clog2(JINGLE_CNT)-1:0]  jingle_num;
logic                             jingle_num_val;

logic                      [6:0]  volume;

assign volume_o = volume;

// equal data for left and right channels
assign lr_chan_data_o = { samp_data, samp_data };

audio_send #(

  .JINGLE_CNT         ( JINGLE_CNT         ),
  .SAMPLE_WIDTH       ( SAMPLE_WIDTH       ),
  .INIT_FILE          ( ROM_INIT_FILE      )
  
)  a_send(

  .clk_i              ( clk_i              ),
  .rst_i              ( rst_i              ),

  .audio_ena_i        ( audio_ena_i        ),
  .jingle_num_i       ( jingle_num         ),
  .jingle_num_val_i   ( jingle_num_val     ),

  .dac_fifo_almfull_i ( dac_fifo_almfull_i ),
  .samp_data_o        ( samp_data          ),
  .samp_wr_req_o      ( samp_wr_req_o      ),
  .clear_dac_o        (                    )

);

PS2_decoder #(

  .JINGLE_CNT         ( JINGLE_CNT         )

) ps2_dcdr(

  .clk_i              ( clk_i              ),
  .rst_i              ( rst_i              ),
  .ps2_data_i         ( ps2_data_i         ),
  .ps2_data_val_i     ( ps2_data_en_i      ),

  .num_o              ( jingle_num         ),
  .num_val_o          ( jingle_num_val     ),
  .vol_cntrl_o        ( vol_up_down        ),
  .vol_cntrl_val_o    ( vol_up_down_val    )

);

volume_control vlmc(

  .clk_i              ( clk_i              ),
  .rst_i              ( rst_i              ),
  .vol_cng_i          ( vol_up_down        ),
  .vol_cng_val_i      ( vol_up_down_val    ),

  .vol_lvl_o          ( volume             )

);
   
   
endmodule
