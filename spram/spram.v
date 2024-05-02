module single_port_ram_inferred #(
	parameter WIDTH = 8,
	parameter DEPTH = 10
)(
	input wire clock,
	input wire we,
	input wire [$clog2(DEPTH)-1:0] address,
	input wire [WIDTH-1:0] data,
	output wire [WIDTH-1:0] Q
);
	reg [WIDTH-1:0] storage [0:DEPTH-1];
	genvar i;
	generate
		for( i = 0; i < DEPTH; i=i+1 ) begin
			initial storage[i] = 8'd0;
		end
	endgenerate

	assign Q = storage[address];
	always @(posedge clock) begin
		if( we ) begin
			storage[address] <= data;
		end
	end
endmodule
