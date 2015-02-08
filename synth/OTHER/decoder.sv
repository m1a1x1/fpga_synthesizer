module decoder(

  input        clk_i,
  input  [2:0] num_i,
  input        num_val_i,
  output [7:0] dig_o
  //output       dig_val_o

);

logic [7:0] num_r;


always_comb
  begin
    num_r = '0;
    if( num_val_i )
      begin
        num_r[ num_i ] = 1'b1;
      end
  end

/*
always_comb
  begin
    //dig_o = '0;
    if( num_val_i )
      begin
        case( num_i )
          3'd0: num_r <= 8'b00000001;
          3'd1: num_r <= 8'b00000010;
          3'd2: num_r <= 8'b00000100;
          3'd3: num_r <= 8'b00001000;
          3'd4: num_r <= 8'b00010000;
          3'd5: num_r <= 8'b00100000;
          3'd6: num_r <= 8'b01000000;
          3'd7: num_r <= 8'b10000000;
        endcase
      end
  end
*/
assign dig_o = num_r;

//assign num_val_i = dig_val_o;

endmodule
