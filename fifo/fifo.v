module fifo #(
	parameter DATASIZE = 8,
	parameter ADDRSIZE = 4
)(
	output wire [DATASIZE-1:0] rdata,
	output wire                wfull,
	output wire                rempty,
	input  wire [DATASIZE-1:0] wdata,
	input  wire                winc,
	input  wire                wclk,
	input  wire                wrst_n,
	input  wire                rinc,
	input  wire                rclk,
	input  wire                rrst_n
);
	wire [ADDRSIZE-1:0] waddr;
	wire [ADDRSIZE-1:0] raddr;
	wire [ADDRSIZE:0] wptr;
	wire [ADDRSIZE:0] rptr;
	wire [ADDRSIZE:0] wq2_rptr;
	wire [ADDRSIZE:0] rq2_wptr;

	dpram #(DATASIZE, ADDRSIZE) dpram (
		.rdata(rdata),
		.wdata(wdata),
		.waddr(waddr),
		.raddr(raddr),
		.wclken(winc),
		.wfull(wfull),
		.wclk(wclk)
	);

	//Synchronization read pointer into the write clock domain
	always @(posedge wclk or negedge wrst_n) begin
		if( !wrst_n ) begin
			wq2_rptr <= 0;
			wq1_rptr <= 0;
		end else begin
			wq2_rptr <= wq1_rptr;
			wq1_rptr <= rptr;
		end
	end

	//Synchronize write pointer into the read clock domain
	always @(posedge rclk or negedge rrst_n) begin
		if( !rrst_n ) begin
			rq2_wptr <= 0;
			rq1_wptr <= 0;
		end else begin
			rq2_wptr <= rq1_wptr;
			rq1_wptr <= wptr;
		end
	end

	rptr_empty #(ADDRSIZE) rptr_empty(
		.rempty(rempty),
		.raddr(raddr),
		.rptr(rptr),
		.rq2_wptr(rq2_wptr),
		.rinc(rinc),
		.rclk(rclk),
		.rrst_n(rrst_n)
	);
	wptr_full #(ADDRSIZE) wptr_empty(
		.wfull(wfull),
		.waddr(waddr),
		.wptr(wptr),
		.wq2_rptr(wq2_rptr),
		.winc(winc),
		.wclk(wclk),
		.wrst_n(wrst_n)
	);
endmodule

//Synchronous dual port ram
module dpram #(
	parameter DATASIZE = 8,
	parameter ADDRSIZE = 4
)(
	input  wire wclk,
	input  wire wclken,
	input  wire wfull,
	input  wire [DATASIZE-1:0] wdata,
	input  wire [ADDRSIZE-1:0] waddr,
	input  wire [ADDRSIZE-1:0] raddr,
	output wire [DATASIZE-1:0] rdata
);
`ifdef ECP5
	//TODO
`else
	//An addrsize of 4bits gets a depth of 2^addrsize (equivalent to 0x01 << addrsize)
	localparam DEPTH = 1<<ADDRSIZE;
	reg [DATASIZE-1:0] storage [0:DEPTH-1];

	assign rdata = mem[raddr];
	always @(posedge wclk)
		if( wclken && !wfull ) mem[waddr] <= wdata;
`endif
endmodule

module rptr_empty #(
	parameter ADDRSIZE = 4
)(
	output reg rempty,
	output wire [ADDRSIZE-1:0] raddr,
	output reg  [ADDRSIZE:0] rptr,
	input  wire [ADDRSIZE:0] rq2_wptr,
	input  wire              rinc,
	input  wire              rclk,
	input  wire              rrst_n
);
	reg  [ADDRSIZE:0] rbin;
	wire [ADDRSIZE:0] rgraynext;
	wire [ADDRSIZE:0] rbinext;

	always @(posedge rclk or negedge rrst_n) begin
		if(!rrst_n) begin
			rbin <= 0;
			rptr <= 0;
		end
		else begin
			rbin <= rbinnext;
			rptr <= rgraynext;
		end
	end

	assign raddr = rbin[ADDRSIZE-1:0];
	assign rbinnext = rbin + (rinc & ~rempty);
	assign rgraynext = (rbinnext >> 1) ^ rbinnext;

	assign rempty_val = (rgraynext == rq2_wptr);
	
	always @(posedge rclk or negedge rrst_n) begin
		if( !rrst_n ) rempty <= 1'b1;
		else          rempty <= rempty_val;
	end
endmodule

module wptr_full #(
)(
	output reg                 wfull,
	output wire [ADDRSIZE-1:0] waddr,
	output reg  [ADDRSIZE  :0] wptr,
	input  wire [ADDRSIZE  :0] wq2_rptr,
	input  wire                winc,
	input  wire                wclk,
	input  wire                wrst_n
);
	reg [ADDRSIZE:0] wbin;
	wire [ADDRSIZE:0] wgraynext;
	wire [ADDRSIZE:0] wbinnext;

	always @(posedge wclk or negedge wrst_n) begin
		if( !wrst_n ) begin
			wbin <= 0;
			wptr <= 0;
		end else begin
			wbin <= wbinnext;
			wptr <= wgraynext;
		end
	end
	
	assign waddr = wbin[ADDRSIZE-1:0];
	
	assign wbinnext = wbin + (winc & ~wfull);
	assign wgraynext = (wbinnext>>1) ^ wbinnext;

	assign wfull_val = (
		( wgnext[ADDRSIZE-0]   != wq2_rptr[ADDRSIZE-0]   ) &&
		( wgnext[ADDRSIZE-1]   != wq2_rptr[ADDRSIZE-1]   ) &&
		( wgnext[ADDRSIZE-2:0] == wq2_rptr[ADDRSIZE-2:0] )
	);

	always @(posedge wclk or negedge wrst_n) begin
		if( !wrst_n ) wfull <= 1'b0;
		else          wfull <= wfull_val;
	end
endmodule