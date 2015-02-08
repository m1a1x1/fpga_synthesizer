module print_vol(

  input  [6:0] vol_lvl_i,

  output [6:0] v_o,
  output [6:0] o_o,
  output [6:0] l_o,

  output [6:0] vol1_o,
  output [6:0] vol2_o,
  output [6:0] vol3_o

);

logic [3:0] ONES;
logic [3:0] TENS;
logic [1:0] HUNDREDS;

assign v_o = 7'b1000001; 
assign o_o = 7'b1000000;
assign l_o = 7'b1000111;

bin_to_BCD b1(
  {1'b0,vol_lvl_i},
  ONES,
  TENS,
  HUNDREDS
);

SEG7_LUT u1(

  vol1_o,
  ONES

);

SEG7_LUT u2(

  vol2_o,
  TENS

);

SEG7_LUT u3(

  vol3_o,
  {2'b00,HUNDREDS}

);

endmodule
