module print_version(

  output [6:0] v_o,
  output [6:0] s_o,

  output [6:0] ver1_o,
  output [6:0] ver2_o,
  output [6:0] ver3_o

);

parameter VERSION = 6;

logic [7:0] version_w;

logic [3:0] ONES;
logic [3:0] TENS;
logic [1:0] HUNDREDS;

assign version_w = VERSION;

assign v_o = 7'b1000001; 
assign s_o = 7'b0010010;

bin_to_BCD b1(
  version_w,
  ONES,
  TENS,
  HUNDREDS
);

SEG7_LUT u1(

  ver1_o,
  ONES

);

SEG7_LUT u2(

  ver2_o,
  TENS

);

SEG7_LUT u3(

  ver3_o,
  {2'b00,HUNDREDS}

);

endmodule
