module coder(

  input               clk_i,
  input               rst_i,

  input        [7:0]  sw,

  output logic [2:0]  num_o,
  output              num_val_o

);

logic [7:0] sw_r;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      sw_r <= '0;
    else
      begin
        sw_r[ 0 ] <= sw[0]; 
        sw_r[ 1 ] <= sw[1]; 
        sw_r[ 2 ] <= sw[2]; 
        sw_r[ 3 ] <= sw[3]; 
        sw_r[ 4 ] <= sw[4]; 
        sw_r[ 5 ] <= sw[5]; 
        sw_r[ 6 ] <= sw[6]; 
        sw_r[ 7 ] <= sw[7]; 
      end
  end

always_comb
  begin
    num_o = '0;
    for( int i = 0; i < 8; i++ )
      begin
        if( sw_r[ i ] )
          begin
            num_o = i;
          end
      end
  end

assign num_val_o = |sw_r;

endmodule
