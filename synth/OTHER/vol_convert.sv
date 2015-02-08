module vol_convert( 

  input  [6:0] vol_norm_i,
  output [6:0] vol_to_I2C_o

);

always_comb
  begin
    vol_to_I2C_o = vol_norm_i + 47;    
  end

endmodule
