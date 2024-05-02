module clock_divider #(
	parameter COUNTER = 48_000_000
)(
	input  wire clk,
	input  wire rst,
	output wire tick
);
	localparam MAX_CTR = $clog2(COUNTER);
	reg [MAX_CTR-1:0] ctr = 0;
	assign tick = ( ctr == COUNTER - 1 );
	always @(posedge clk) begin
		if( rst | tick ) ctr <= 0;
		else ctr <= ctr + 1;
	end
	
endmodule

module top(
	input wire CLK48,
	input wire CLK125,
	output wire [3:0] ETH_TX,
	output wire [3:0] ETH_RX //not actually, but using for simulation purposes
);
	wire [7:0] odata;
	wire [7:0] odata2;
	assign ETH_TX = odata[3:0];
	assign ETH_RX = odata2[3:0];
	//DO NOT DRIVE FLIP FLOP CLOCKS FROM OUTPUT Q OF OTHER FLIPFLOPS. 
	//This creates clock domain crossing and metastability issues.
	wire clk10;
	clock_divider #(10) cd(
		.clk(CLK48),
		.tick(clk10)
	);
	reg [3:0] ctr = 0;
	always @(posedge CLK48) begin
		if( clk10 ) begin
			if( ctr == 9 ) ctr <= 0;
			else ctr <= ctr + 1;
		end
	end
	single_port_ram_inferred ebr(
		.clock(CLK48),
		.we(1'b1),
		.address(ctr),
		.data({4'd0,ctr}),
		.Q(odata)
	);
endmodule
