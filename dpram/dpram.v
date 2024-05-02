module dual_port_ram_inferred #(
	parameter WIDTH = 8,
	parameter DEPTH = 10
)(
	input wire [$clog2(DEPTH)-1:0] WrAddress,
	input wire [$clog2(DEPTH)-1:0] RdAddress,
	input wire RdClock,
	//input wire RdClockEn,
	//input wire Reset,
	input wire WrClock,
	//input wire WrClockEn,
	input wire WE,
	input wire [WIDTH-1:0] Data,
	output reg [WIDTH-1:0] Q
);
	//Define Storage
	reg [WIDTH-1:0] storage [0:DEPTH-1];
	//init storage
	genvar i;
	generate
		for( i = 0; i < DEPTH; i=i+1 ) initial storage[i] = 0;
	endgenerate
	//Define Write Operations in ClockDomain WrClock
	always @(posedge WrClock) begin
		if( WE ) storage[WrAddress] <= Data;
	end
	//Define Read Operations in ClockDomain RdClock
	always @(posedge RdClock) begin
		Q <= storage[RdAddress];
	end
endmodule
