module volume_control(

  input        clk_i,
  input        rst_i,
  
  input        vol_cng_i,
  input        vol_cng_val_i,

  output [7:0] vol_lvl_o

);

// key hold counter
logic [32:0] key_hld_cnt;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      key_hld_cnt <= '0;
    else 
      if( vol_cng_val_i == 1'b0 )
        key_hld_cnt <= '0;
      else 
        if( vol_cng_val_i == 1'b1 )
          key_hld_cnt <= key_hld_cnt + 1'b1; 
  end


// volume level counter
logic [7:0] vol_lvl_cnt;

logic vol_up;
logic vol_down;

assign vol_up   =  vol_cng_i && vol_cng_val_i && vol_lvl_cnt != 7'd80 && key_hld_cnt == 15'd1;
assign vol_down = ~vol_cng_i && vol_cng_val_i && vol_lvl_cnt != 7'd0  && key_hld_cnt == 15'd1;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      vol_lvl_cnt <= '0;
    else 
      if( vol_up )
        vol_lvl_cnt <= vol_lvl_cnt + 7'd4;  
      else
        if( vol_down )
          vol_lvl_cnt <= vol_lvl_cnt - 7'd4;
  end

assign vol_lvl_o = vol_lvl_cnt;     

endmodule
