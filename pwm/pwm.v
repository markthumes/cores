module pwm_blink(
	input wire clk,
	output wire pwm
);
	
	////////////////////////////////////////////////////////////////////////
	//                             PWM BLINK                              //
	//Load sine wave
	localparam COUNT=1000;
	localparam MAX_VALUE=1000;
	reg [11:0] memory [0:COUNT-1];
	initial $readmemh("cgen/sine/sine.dat", memory);

	//index through memory
	wire [11:0] pulse_width;
	reg [$clog2(COUNT)-1:0] pulse_index = 0;
`ifdef SIM
	localparam MAX_PULSE_CTR = 48;
`else
	localparam MAX_PULSE_CTR = 96_000;
`endif
	assign pulse_width = memory[pulse_index];
	reg [$clog2(MAX_PULSE_CTR)-1:0] pulse_ctr = 0;
	always @(posedge clk ) begin
		if( pulse_ctr == MAX_PULSE_CTR-1 ) begin
			pulse_ctr = 0;
			if( pulse_index == COUNT-1 ) begin
				pulse_index <= 0;
			end else begin
				pulse_index <= pulse_index + 1;
			end
		end else begin
			pulse_ctr <= pulse_ctr + 1;
		end
	end

	reg pwm_state = 0;
	reg [$clog2(48_000_000)-1:0] ctr = 0;

	assign pwm = pwm_state;

	localparam DWELL_TIME = 1_000;
	
`ifdef SIM
	localparam MAX_CTR = 48_000;
`else
	localparam MAX_CTR = 48_000_000;
`endif

	always @(posedge clk) begin
		if( ctr < pulse_width ) begin
			pwm_state = 1;
			ctr <= ctr + 1;
		end
		else if( ctr > DWELL_TIME ) begin
			ctr <= 0;
			pwm_state <= 0;
		end
		else begin
			pwm_state <= 0;
			ctr <= ctr + 1;
		end
	end
endmodule

