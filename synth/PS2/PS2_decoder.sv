module PS2_decoder(

  input              clk_i,
  input              rst_i,

  input [7:0]        ps2_data_i,
  input              ps2_data_val_i,

  output logic [2:0] num_o,
  output logic       num_val_o,

  output             vol_cntrl_o,
  output             vol_cntrl_val_o
 
);

logic [2:0][7:0] ps2_data_sr;

always_ff @( posedge clk_i or posedge rst_i )
  if( rst_i )
    begin
      ps2_data_sr <= '0;
    end
  else
    if( ps2_data_val_i )
      begin
        ps2_data_sr <= { ps2_data_sr[1], ps2_data_sr[0], ps2_data_i };
      end

logic [7:0][7:0] key_pos;

assign key_pos[0] = 8'h16;
assign key_pos[1] = 8'h1E;
assign key_pos[2] = 8'h26;
assign key_pos[3] = 8'h25;
assign key_pos[4] = 8'h2E;
assign key_pos[5] = 8'h36;
assign key_pos[6] = 8'h3D;
assign key_pos[7] = 8'h3E;

always_comb
  begin
    num_o     = '0;
    num_val_o = 1'b0;

    for( int i = 0; i < 8; i++ )
      begin
        if( ps2_data_sr[0] == key_pos[i] )
          begin
            num_o     = i;

            if( ps2_data_sr[1] != 8'hF0 )
              begin
                num_val_o = 1'b1;
              end
          end
      end
  end

always_comb
  begin
    vol_cntrl_o     = 1'b0;
    vol_cntrl_val_o = 1'b0;

    casex( ps2_data_sr )
      // volume up make and break
      { 8'hxx, 8'hE0, 8'h32 }:
        begin
          vol_cntrl_o     = 1'b1;
          vol_cntrl_val_o = 1'b1;
        end
      { 8'hE0, 8'hF0, 8'h32 }:
        begin
          vol_cntrl_o     = 1'b1;
          vol_cntrl_val_o = 1'b0;
        end

      // volume down make and break
      { 8'hxx, 8'hE0, 8'h21 }:
        begin
          vol_cntrl_o     = 1'b0;
          vol_cntrl_val_o = 1'b1;
        end
      { 8'hE0, 8'hF0, 8'h21 }:
        begin
          vol_cntrl_o     = 1'b0;
          vol_cntrl_val_o = 1'b0;
        end
      default:
        begin
          vol_cntrl_o     = 1'b0;
          vol_cntrl_val_o = 1'b0;
        end
    endcase

  end

// working volume part with + and - 
/*
always_comb
  begin
    vol_cntrl_o     = 1'b0;
    vol_cntrl_val_o = 1'b0;

    case( ps2_data_sr[0] )
      8'h55:
        begin
          vol_cntrl_o     = 1'b1;
          vol_cntrl_val_o = ( ps2_data_sr[1] != 8'hF0 ) ? 1 : 0;
        end
      8'h4E:
        begin
          vol_cntrl_o     = 1'b0;
          vol_cntrl_val_o = ( ps2_data_sr[1] != 8'hF0 ) ? 1 : 0;
        end
      default:
        begin
          vol_cntrl_o     = 1'b0;
        end
    endcase
  end
*/


endmodule
