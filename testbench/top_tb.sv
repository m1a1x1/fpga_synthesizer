module top_tb;

timeunit        1ns;
timeprecision 0.1ns;

logic           clk;
logic           clk_18;

logic           AUD_ADCLRCK;  
logic           AUD_BCLK;     
logic           AUD_DACDAT;   
logic           AUD_DACLRCK;  
logic           AUD_XCK;

logic  [3:0]    KEY;
logic  [9:0]    SW;

initial
  begin
    SW = '0;
    KEY[0] = 1'b0;
    #100;
    KEY[0] = 1'b1;
  end
initial
  begin
    clk = 0;
    forever
      #10.0 clk = ~clk;
  end

initial
  begin
    clk_18 = 0;
    forever
      #55.5 clk_18 = ~clk_18;
  end

/*
initial
  begin
    SW = '0;
    #1000;
    SW[0] = 1'b1;
    #10000;
    SW[1] = 1'b1;
    #10000;
    SW[1] = 1'b0;
    SW[2] = 1'b1;
    #10000;
    SW[2] = 1'b0;
    SW[3] = 1'b1;
    #10000;
    SW[3] = 1'b0;
    SW[4] = 1'b1;
    #10000;
    SW[4] = 1'b0;
    SW[5] = 1'b1;
    #10000;
    SW[5] = 1'b0;
    SW[6] = 1'b1;
    #10000;
    SW[6] = 1'b0;
    SW[7] = 1'b1;
    #10000;
    SW[7] = 1'b0;
    SW[8] = 1'b1;
  end
*/

top DUT(

  .AUD_ADCLRCK                            (        ),
  .AUD_BCLK                               (           ),
  .AUD_DACDAT                             (        ),
  .AUD_DACLRCK                            (        ),
  .AUD_XCK                                (          ),
  .KEY                                    ( KEY               ),
  .CLOCK_50                               ( clk               ),

  .FPGA_I2C_SCLK                          ( FPGA_I2C_SCLK     ),
  .FPGA_I2C_SDAT                          ( FPGA_I2C_SDAT     ),

  .SW                                     ( SW                )

  //.AUD_CTRL_CLK                           ( clk_18            )

);

endmodule
