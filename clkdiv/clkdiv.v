module clkdiv #(
	parameter COUNT=48_000_000
)(
	input  wire i_clk,
	output reg  o_clk
);
	//We want to basically count, then toggle o_clk high for a single pulse of i_clk
	reg [$clog2(COUNT)-1:0] ctr = 0;
	always @(posedge i_clk) begin
		if( ctr == COUNT ) begin
			ctr   <= 0;
			o_clk <= 1;
		end else begin
			ctr   <= ctr + 1;
			o_clk <= 0;
		end
	end
	
endmodule
