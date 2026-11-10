`timescale 1ns / 1ps

module _jkflip(J, CLK, K, q, qd);
    input J, K, CLK;
    output reg q, qd;
    
    initial begin 
        q = 0;
        qd = 1;
    end
    
    always @(negedge CLK) begin
        case ({J, K})
            2'b00: q = q;       
            2'b01: q = 0;       
            2'b10: q = 1;     
            2'b11: q = ~q;     
        endcase
        qd = ~q;
    end
endmodule

module overlapping_seqdetector_moore(x, CLK, y);
    input x, CLK;
    output y;
    wire q2, q1, q0, qd2, qd1, qd0;
    wire j2, k2, j1, k1, j0, k0;
    

    assign j2 = (~x) & q1 & (~q0);
    assign k2 = ~((~x) & q1 & (~q0));
    
    assign j1 = ((~x) & q0) | (x & q2);
    assign k1 = ~(((~x) & q0) | (x & q2));
    
    assign j0 = x;
    assign k0 = ~x;
    
    assign y = q1 & q0;
    
    _jkflip flip2(j2, CLK, k2, q2, qd2);
    _jkflip flip1(j1, CLK, k1, q1, qd1);
    _jkflip flip0(j0, CLK, k0, q0, qd0);
endmodule

module tb_overlapping_seqdetector_moore();
    reg x, CLK;
    wire y;
    
    overlapping_seqdetector_moore dut(x, CLK, y);
    
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
    
    initial begin
       x=1; #5;
       x=0; #10;
       x=0; #10;
       x=1; #10;
       x=0; #10;
       x=0; #10;
       x=1; #10;
       x=0; #10;
       x=0; #10;
       x=0; #10;
       x=0; #10;
       x=0; #10;
       x=1; #10;
       x=0; #10;
       x=0; #10;
       x=1; #10;
       $finish;
    end
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_overlapping_seqdetector_moore);
        $monitor("Time=%0t | x=%b | state=%b%b%b | y=%b", $time, x, dut.q2, dut.q1, dut.q0, y);
    end
endmodule
