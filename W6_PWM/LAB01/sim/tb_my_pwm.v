`timescale 1 ns / 1 ps
// tb_my_pwm.v - week 6: drive my_pwm_v1_0_S00_AXI over AXI4-Lite like the C code does
//   Xil_Out32(+0x4, PERIOD); Xil_Out32(+0x8, DUTY); Xil_Out32(+0x0, 1);
//   then count, over one period, how many clocks led4 is high (expected: DUTY)
//   run: xvlog my_pwm_v1_0_S00_AXI.v tb_my_pwm.v && xelab tb_my_pwm -s sim && xsim sim -R

module tb_my_pwm;

	reg         clk = 1'b0;
	reg         rstn = 1'b0;
	reg  [3:0]  awaddr = 4'd0;
	reg         awvalid = 1'b0;
	wire        awready;
	reg  [31:0] wdata = 32'd0;
	reg  [3:0]  wstrb = 4'hF;
	reg         wvalid = 1'b0;
	wire        wready;
	wire [1:0]  bresp;
	wire        bvalid;
	reg         bready = 1'b1;
	reg  [3:0]  araddr = 4'd0;
	reg         arvalid = 1'b0;
	wire        arready;
	wire [31:0] rdata;
	wire [1:0]  rresp;
	wire        rvalid;
	reg         rready = 1'b1;
	wire [3:0]  led4;

	always #10 clk = ~clk;	// 50 MHz, like FCLK_CLK0

	my_pwm_v1_0_S00_AXI #(.C_S_AXI_DATA_WIDTH(32), .C_S_AXI_ADDR_WIDTH(4)) dut (
		.led4(led4),
		.S_AXI_ACLK(clk), .S_AXI_ARESETN(rstn),
		.S_AXI_AWADDR(awaddr), .S_AXI_AWPROT(3'd0), .S_AXI_AWVALID(awvalid), .S_AXI_AWREADY(awready),
		.S_AXI_WDATA(wdata), .S_AXI_WSTRB(wstrb), .S_AXI_WVALID(wvalid), .S_AXI_WREADY(wready),
		.S_AXI_BRESP(bresp), .S_AXI_BVALID(bvalid), .S_AXI_BREADY(bready),
		.S_AXI_ARADDR(araddr), .S_AXI_ARPROT(3'd0), .S_AXI_ARVALID(arvalid), .S_AXI_ARREADY(arready),
		.S_AXI_RDATA(rdata), .S_AXI_RRESP(rresp), .S_AXI_RVALID(rvalid), .S_AXI_RREADY(rready)
	);

	// Xil_Out32(base + addr, data)
	task axi_write(input [3:0] addr, input [31:0] data);
	begin
		@(posedge clk);
		awaddr <= addr; awvalid <= 1'b1; wdata <= data; wvalid <= 1'b1;
		wait (awready && wready);
		@(posedge clk);
		awvalid <= 1'b0; wvalid <= 1'b0;
		wait (bvalid);
		@(posedge clk);
	end
	endtask

	// data = Xil_In32(base + addr)
	reg [31:0] rd;
	task axi_read(input [3:0] addr);
	begin
		@(posedge clk);
		araddr <= addr; arvalid <= 1'b1;
		wait (arready);
		@(posedge clk);
		arvalid <= 1'b0;
		wait (rvalid);
		rd = rdata;
		@(posedge clk);
	end
	endtask

	// count high clocks of led4[0] over n clocks
	integer i, hi;
	task count_high(input integer n);
	begin
		hi = 0;
		for (i = 0; i < n; i = i + 1) begin
			@(posedge clk); #1;
			hi = hi + led4[0];
		end
	end
	endtask

	task check(input [15:0] period, input [15:0] duty);
	begin
		axi_write(4'h4, period);
		axi_write(4'h8, duty);
		axi_write(4'h0, 32'd0);		// restart from count 0
		axi_write(4'h0, 32'd1);
		count_high(period);
		$display("PERIOD %5d  DUTY %5d : led4 high %5d of %5d clocks (exp %5d)  %s",
			period, duty, hi, period, (duty > period) ? period : duty,
			(hi == ((duty > period) ? period : duty)) ? "OK" : "MISMATCH");
	end
	endtask

	initial begin
		repeat (5) @(posedge clk);
		rstn <= 1'b1;

		check(16'd200,   16'd50);	// 25 %, the ILA example (4 us)
		check(16'd200,   16'd150);	// 75 %
		check(16'd200,   16'd0);	// always off
		check(16'd200,   16'd200);	// always on
		check(16'd50000, 16'd12500);	// 1 kHz, 25 %, the C example


		axi_write(4'h0, 32'd0);		// EN = 0
		count_high(1000);
		axi_read(4'h8); $display("EN = 0 : led4 high %0d of 1000 clocks (exp 0), DUTY reads back %0d", hi, rd[15:0]);
		$finish;
	end

endmodule
