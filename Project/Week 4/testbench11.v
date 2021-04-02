`timescale 1ns/1ps

module testbench11;

    `include "params.v"
    parameter DIM = WIDTH * HEIGHT;
    parameter t = 10;

    reg         clk, reset;
    reg  [23:0] RGB;
    wire [7:0]  L;

    reg [23:0] rom[0:DIM-1];

    // Output ram
    reg  [7:0]             out_ram[0:DIM-1];
    wire [7:0]             din;
    reg  [$clog2(DIM)-1:0] addr;
    reg                    value_in, value_out;
    initial begin
	if(value_in)
	        $readmemb("RGB.txt", rom);
    end

    always @ clk
        #(t / 2) clk <= ~clk;

    Convert dut(
        .clk(clk),
        .reset(reset),
        .RGB(RGB),
        .L(L)
    );

   //Addr RAM
    always @ (posedge clk or posedge reset) begin
        if (reset)
            value_out <= 1'b0;
        else
            value_out <= value_in;
    end

    always @ (posedge clk or posedge reset) begin
        if (reset)
            addr <= 0;
        else if (value_out)
            addr <= (addr == (DIM - 1)) ? 0 : (addr + 1);
    end	
    //Value RAM
    assign din = L;
    always @ (posedge clk) begin
        if (value_out)
            out_ram[addr] <= din;
    end

    integer i;
    initial begin
        reset <= 1'b1;
        clk   <= 1'b1;
        value_in  <= 1'b0;
        #(t * 5);
        reset <= 1'b0;
        #2;

        for (i = 0; i < WIDTH * HEIGHT; i = i + 1) begin
            RGB <= rom[i];
            value_in <= 1'b1;
            #t;
        end
        value_in <= 1'b0;

        #(t * 10);
	if(value_out)
        	$writememb("Gray.txt", out_ram);
        $finish;
    end

endmodule