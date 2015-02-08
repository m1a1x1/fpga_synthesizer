module AUDIO_DAC(
	// host
	clk,
	reset,
	write,
	writedata,
	almost_full,
	clear,
	// dac
        clk_18,
	bclk,
	daclrc,
	dacdat
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

parameter	DATA_WIDTH     = 32;
parameter	REF_CLK	       = 18432000; // 18 MHz
parameter	SAMPLE_RATE    = 48000;	   // 48 Hz
parameter	CHANNEL_NUM    = 2;	

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
input			        clk;
input				reset;
input				write;
input	[(DATA_WIDTH-1):0]	writedata;
output  logic                   almost_full;
input				clear;

input                           clk_18;
output  logic                   bclk;
output  logic                   daclrc;
output	logic                   dacdat;


/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/


/*****************************************************************************
 *                 Internal wires and registers Declarations                 *
 *****************************************************************************/

// Note. Left Justified Mode
reg  [3:0]              BCK_DIV;
reg  [8:0]              LRCK_1X_DIV;

reg  [4:0]              bit_index;  //0~31
reg  [(DATA_WIDTH-1):0] data_to_dac;		

wire                    dacfifo_empty;
logic                   dacfifo_read;
wire [(DATA_WIDTH-1):0]	dacfifo_readdata;

/*****************************************************************************
 *                           Clock Declarations                              *
 *****************************************************************************/

// bclk declaration
always@( posedge clk_18 or posedge reset )
  begin
    if( reset )
      begin
        BCK_DIV <= 0;
        bclk    <= 0;
      end
    else
      begin
        if( BCK_DIV >= REF_CLK / ( SAMPLE_RATE * DATA_WIDTH * 2 ) - 1 )
          begin
            BCK_DIV <= 0;
            bclk    <= ~bclk;
          end
        else
          BCK_DIV <= BCK_DIV + 1;
      end
  end

// daclrc declaration
always@( posedge clk_18 or posedge reset )
  begin
    if( reset )
      begin
        LRCK_1X_DIV <= '0;
        daclrc      <= '0;
      end
    else
      begin
        if( LRCK_1X_DIV >= REF_CLK / ( SAMPLE_RATE * 2 ) - 1 )
          begin
            LRCK_1X_DIV	<= '0;
            daclrc      <= ~daclrc ;
          end
        else
          LRCK_1X_DIV <= LRCK_1X_DIV + 1;
      end
  end

/*****************************************************************************
 *                               Main                                        *
 *****************************************************************************/

// Bit number for sending to DUC
always @ ( negedge bclk ) 
  begin
    if ( reset || clear )
      begin
        bit_index  <= 0;
      end
    else
      begin
        if( bit_index == DATA_WIDTH - 1 )
          bit_index <= 0;
        else
          bit_index <= bit_index + 1;
	end
  end


// Read request ( when final bit from previos part send )
always_ff @( negedge bclk or posedge reset )
  begin
    if( reset )
      begin
        dacfifo_read <= '0;
      end
    else
      begin
        if( dacfifo_empty )
          dacfifo_read <= '0;
        else
          begin
            if( bit_index == DATA_WIDTH - 2 )
              dacfifo_read <= 1'b1;
            else
              dacfifo_read <= 1'b0;
          end
      end
  end

// Data to send
always_ff @( negedge bclk or posedge reset )
  begin
    if( reset )
      begin
        dacdat <= '0;
      end
    else
      begin
        dacdat <= dacfifo_readdata[ bit_index ];
      end
  end

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

audio_fifo dac_fifo(

  // write
  .wrclk   ( clk              ),
  .wrreq   ( write            ),
  .data    ( writedata        ),
  .wralmfull ( almost_full   ),
  .aclr    ( clear            ),  // sync with wrclk
  // read
  .rdclk   ( bclk             ),
  .rdreq   ( dacfifo_read     ),
  .q       ( dacfifo_readdata ),
  .rdempty ( dacfifo_empty    )

);

endmodule



