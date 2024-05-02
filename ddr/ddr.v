module oddr(
	input wire D0,
	input wire D1,
	input wire SCLK,
	output wire Q
);

`ifdef SIM
	reg regQ;
	initial regQ = D0;
	assign Q = regQ;
	always @(posedge SCLK) begin
		regQ = D0;
	end
	always @(negedge SCLK) begin
		regQ = D1;
	end
`else
	ODDRX1F #(
	)oddr_mask(
		.D0(D0),
		.D1(D1),
		.SCLK(SCLK),
		.Q(Q)
	);
`endif
endmodule

module iddr(
	input wire D,
	input wire SCLK,
	input wire RST,
	output wire Q0,
	output wire Q1
);
`ifdef SIM
	//what do we do, we gather data at the falling and rising edge of SCLK
	reg [1:0] regQ;
	assign Q0 = regQ[0]; //Positive Edge
	assign Q1 = regQ[1]; //Negative Edge
	always @(posedge SCLK) begin
		if( RST ) regQ = 2'b00;
		regQ[0] = D;
	end
	assign Q1 = regQ[1]; //Negative Edge
	always @(negedge SCLK) begin
		if( RST ) regQ = 2'b00;
		regQ[1] = D;
	end
`else
	wire clk_injection_removal;
	DELAYG #(
		.DEL_MODE("SCLK_CENTERED"),
		.DEL_VALUE(0)
	)
	delay_abstraction(
		.A(D),
		.Z(clk_injection_removal)
	);
	IDDRX1F iddr_abstraction(
		.D(clk_injection_removal),
		.SCLK(SCLK),
		.RST(RST),
		.Q0(Q0),
		.Q1(Q1)
	);
`endif

endmodule
