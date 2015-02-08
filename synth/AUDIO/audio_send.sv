module audio_send #(

  JINGLE_CNT   = 8,
  SAMPLE_WIDTH = 16,
  INIT_FILE    = "jingle.mif"

)
(

  input                             clk_i,
  input                             rst_i,

  input                             audio_ena_i,
  input  [$clog2(JINGLE_CNT) - 1:0] jingle_num_i,
  input                             jingle_num_val_i,

  input                             dac_fifo_almfull_i,
  output [SAMPLE_WIDTH - 1:0]       samp_data_o,
  output logic                      samp_wr_req_o,
  output                            clear_dac_o

);

localparam SAMPLES_CNT = 512; // max 512 bits for 1 jingle
localparam DATA_WIDTH  = SAMPLE_WIDTH + 1;
localparam ADDR_WIDTH  = $clog2( JINGLE_CNT * SAMPLES_CNT ); 

logic                              jingle_end;
logic [$clog2(SAMPLES_CNT) - 1:0]  samp_to_send_num;

logic [$clog2(JINGLE_CNT) - 1:0]   jingle_num_d1;
logic                              dac_fifo_almfull_d1;

logic                              jingle_changed /* synthesis prserve */;

logic [DATA_WIDTH-1:0]             rom_data;
logic [ADDR_WIDTH-1:0]             rom_adr;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      jingle_num_d1 <= '0;
    else
      jingle_num_d1 <= jingle_num_i;
  end

assign jingle_changed = ( jingle_num_i != jingle_num_d1 ); 
assign jingle_end     = rom_data[ SAMPLE_WIDTH ];

assign sound_ena = ( audio_ena_i ) && ( jingle_num_val_i ); 

assign samp_wr_req_o = ( sound_ena ) && ( !dac_fifo_almfull_d1 );

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      dac_fifo_almfull_d1 <= '0;
    else
      dac_fifo_almfull_d1 <= dac_fifo_almfull_i;
  end

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      samp_to_send_num <= 0;
    else
      begin
        if( !( sound_ena ) )
            samp_to_send_num <= 0;
        else
          begin
            if( jingle_changed )
                samp_to_send_num <= 0;
            else
              begin
                if( jingle_end )
                  samp_to_send_num <= 1;
                else
                  begin
                    if( !(dac_fifo_almfull_i ) )
                      samp_to_send_num <= samp_to_send_num + 1;
                  end
              end
          end
      end
  end


assign rom_adr[ADDR_WIDTH-1:$clog2(SAMPLES_CNT)] = jingle_num_d1;

always_comb
  begin
    if( jingle_end )
      rom_adr[$clog2(SAMPLES_CNT) - 1:0]  = '0;
    else 
      rom_adr[$clog2(SAMPLES_CNT) - 1:0]  = samp_to_send_num; 
  end

assign samp_data_o = rom_data[SAMPLE_WIDTH-1:0];

simps_rom#(

  .A_WIDTH   ( ADDR_WIDTH ),
  .D_WIDTH   ( DATA_WIDTH ),
  .INIT_FILE ( INIT_FILE  )

  ) sr (

  .clock   ( clk_i    ),
  .address ( rom_adr  ),
  .q       ( rom_data )

);


/*// Sound:  1 kHz sin
always_comb
  begin
    simp_1[ 0 ]  = 0;
    simp_1[ 1 ]  = 4276;
    simp_1[ 2 ]  = 8480;
    simp_1[ 3 ]  = 12539;
    simp_1[ 4 ]  = 16383;
    simp_1[ 5 ]  = 19947;
    simp_1[ 6 ]  = 23169;
    simp_1[ 7 ]  = 25995;
    simp_1[ 8 ]  = 28377;
    simp_1[ 9 ]  = 30272;
    simp_1[ 10 ] = 31650;
    simp_1[ 11 ] = 32486;
    simp_1[ 12 ] = 32767;
    simp_1[ 13 ] = 32486;
    simp_1[ 14 ] = 31650;
    simp_1[ 15 ] = 30272;
    simp_1[ 16 ] = 28377;
    simp_1[ 17 ] = 25995;
    simp_1[ 18 ] = 23169;
    simp_1[ 19 ] = 19947;
    simp_1[ 20 ] = 16383;
    simp_1[ 21 ] = 12539;
    simp_1[ 22 ] = 8480;
    simp_1[ 23 ] = 4276;
    simp_1[ 24 ] = 0;
    simp_1[ 25 ] = 61259;
    simp_1[ 26 ] = 57056;
    simp_1[ 27 ] = 52997;
    simp_1[ 28 ] = 49153;
    simp_1[ 29 ] = 45589;
    simp_1[ 30 ] = 42366;
    simp_1[ 31 ] = 39540;
    simp_1[ 32 ] = 37159;
    simp_1[ 33 ] = 35263;
    simp_1[ 34 ] = 33885;
    simp_1[ 35 ] = 33049;
    simp_1[ 36 ] = 32768;
    simp_1[ 37 ] = 33049;
    simp_1[ 38 ] = 33885;
    simp_1[ 39 ] = 35263;
    simp_1[ 40 ] = 37159;
    simp_1[ 41 ] = 39540;
    simp_1[ 42 ] = 42366;
    simp_1[ 43 ] = 45589;
    simp_1[ 44 ] = 49152;
    simp_1[ 45 ] = 52997;
    simp_1[ 46 ] = 57056;
    simp_1[ 47 ] = 61259;
  end

// Sound: 
always_comb
  begin
    simp_2[ 0 ] = 0;
    simp_2[ 1 ] = 2057;
    simp_2[ 2 ] = 4106;
    simp_2[ 3 ] = 6139;
    simp_2[ 4 ] = 8148;
    simp_2[ 5 ] = 10125;
    simp_2[ 6 ] = 12062;
    simp_2[ 7 ] = 13951;
    simp_2[ 8 ] = 15785;
    simp_2[ 9 ] = 17557;
    simp_2[ 10 ] = 19259;
    simp_2[ 11 ] = 20886;
    simp_2[ 12 ] = 22430;
    simp_2[ 13 ] = 23886;
    simp_2[ 14 ] = 25247;
    simp_2[ 15 ] = 26509;
    simp_2[ 16 ] = 27666;
    simp_2[ 17 ] = 28713;
    simp_2[ 18 ] = 29648;
    simp_2[ 19 ] = 30465;
    simp_2[ 20 ] = 31163;
    simp_2[ 21 ] = 31737;
    simp_2[ 22 ] = 32186;
    simp_2[ 23 ] = 32508;
    simp_2[ 24 ] = 32702;
    simp_2[ 25 ] = 32767;
    simp_2[ 26 ] = 32702;
    simp_2[ 27 ] = 32508;
    simp_2[ 28 ] = 32186;
    simp_2[ 29 ] = 31737;
    simp_2[ 30 ] = 31163;
    simp_2[ 31 ] = 30465;
    simp_2[ 32 ] = 29648;
    simp_2[ 33 ] = 28713;
    simp_2[ 34 ] = 27666;
    simp_2[ 35 ] = 26509;
    simp_2[ 36 ] = 25247;
    simp_2[ 37 ] = 23886;
    simp_2[ 38 ] = 22430;
    simp_2[ 39 ] = 20886;
    simp_2[ 40 ] = 19259;
    simp_2[ 41 ] = 17557;
    simp_2[ 42 ] = 15785;
    simp_2[ 43 ] = 13951;
    simp_2[ 44 ] = 12062;
    simp_2[ 45 ] = 10125;
    simp_2[ 46 ] = 8148;
    simp_2[ 47 ] = 6139;
    simp_2[ 48 ] = 4106;
    simp_2[ 49 ] = 2057;
    simp_2[ 50 ] = 0;
    simp_2[ 51 ] = 63478;
    simp_2[ 52 ] = 61429;
    simp_2[ 53 ] = 59396;
    simp_2[ 54 ] = 57387;
    simp_2[ 55 ] = 55410;
    simp_2[ 56 ] = 53473;
    simp_2[ 57 ] = 51584;
    simp_2[ 58 ] = 49750;
    simp_2[ 59 ] = 47978;
    simp_2[ 60 ] = 46276;
    simp_2[ 61 ] = 44649;
    simp_2[ 62 ] = 43105;
    simp_2[ 63 ] = 41649;
    simp_2[ 64 ] = 40288;
    simp_2[ 65 ] = 39026;
    simp_2[ 66 ] = 37869;
    simp_2[ 67 ] = 36822;
    simp_2[ 68 ] = 35887;
    simp_2[ 69 ] = 35070;
    simp_2[ 70 ] = 34372;
    simp_2[ 71 ] = 33798;
    simp_2[ 72 ] = 33349;
    simp_2[ 73 ] = 33027;
    simp_2[ 74 ] = 32833;
    simp_2[ 75 ] = 32769;
    simp_2[ 76 ] = 32833;
    simp_2[ 77 ] = 33027;
    simp_2[ 78 ] = 33349;
    simp_2[ 79 ] = 33798;
    simp_2[ 80 ] = 34372;
    simp_2[ 81 ] = 35070;
    simp_2[ 82 ] = 35887;
    simp_2[ 83 ] = 36822;
    simp_2[ 84 ] = 37869;
    simp_2[ 85 ] = 39026;
    simp_2[ 86 ] = 40288;
    simp_2[ 87 ] = 41649;
    simp_2[ 88 ] = 43105;
    simp_2[ 89 ] = 44649;
    simp_2[ 90 ] = 46276;
    simp_2[ 91 ] = 47978;
    simp_2[ 92 ] = 49750;
    simp_2[ 93 ] = 51584;
    simp_2[ 94 ] = 53473;
    simp_2[ 95 ] = 55410;
    simp_2[ 96 ] = 57387;
    simp_2[ 97 ] = 59396;
    simp_2[ 98 ] = 61429;
    simp_2[ 99 ] = 63478;
  end
*/
endmodule
