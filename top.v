module top(clk,rst,s,A,B,Done,P);
input clk,rst,s;
input [3:0] A,B;
output Done;
output [7:0] P;

wire LA,LB,SA,SB,LP,SP,z,Bo;

FSM fsm1(.clk(clk),.rst(rst),.s(s),.z(z),.Bo(Bo),.LA(LA),.LB(LB),.SA(SA),.SB(SB),.SP(SP),.LP(LP),.Done(Done));
dataPath dp1(.clk(clk),.A(A),.B(B),.LA(LA),.LB(LB),.SA(SA),.SB(SB),.LP(LP),.SP(SP),.z(z),.Bo(Bo),.P(P));

endmodule

module FSM(clk,rst,s,z,Bo,LA,LB,SA,SB,SP,LP,Done);
input clk,rst,s,z,Bo;
output reg LA,LB,SA,SB,SP,LP,Done;

parameter S0=2'b00, S1=2'b01, S2=2'b10;
reg [1:0] curr_state, next_state;

initial begin
	curr_state = S0;
	next_state = S0;
end

always@(posedge clk,negedge rst)begin
	if(rst == 0) curr_state <= S0;
	else curr_state <= next_state;
end

always@(*)begin
	case(curr_state)
		S0:begin
			if(s == 0) next_state = S0;
			else if(s == 1) next_state = S1;
		end
		S1:begin
			if(z == 0) next_state = S1;
			else if(z == 1) next_state = S2;
		end
		S2:begin
			if(s == 0) next_state = S0;
			else if(s == 1) next_state = S2;
		end
	endcase
end

always@(*)begin
	LA = 0; LB = 0; SA = 0; SB = 0; SP = 0; LP = 0; Done = 0;
	case(curr_state)
		S0:begin
			LA = 1;
			LB = 1;
			SP = 0;
			LP = 1;
		end
		S1:begin
			SA = 1;
			SB = 1;
			SP = 1;
			
			if(Bo == 0) LP = 0;
			else LP = 1;
		end
		S2:begin
			Done = 1;
		end
	endcase
	
end


endmodule

module dataPath (clk,A,B,LA,LB,SA,SB,LP,SP,z,Bo,P);

input clk;
input [3:0]A,B;
input LA,LB,SA,SB,LP,SP;

output [7:0]P;
output z,Bo;

wire [7:0]OutA;//leftShiftA (clk,A,LoadA,ShiftA,OutA);
leftShiftA ls1(.clk(clk),.A(A),.LoadA(LA),.ShiftA(SA),.OutA(OutA));


rightShiftB rs1(.clk(clk),.B(B),.LoadB(LB),.ShiftB(SB),.z(z),.Bo(Bo));

wire [7:0]AddOut;
adder a1(.Aout(OutA),.Pout(P),.AddOut(AddOut));

PRegister pr1(.clk(clk),.In(AddOut),.SelP(SP),.LoadP(LP),.Pout(P));

endmodule

module leftShiftA (clk,A,LoadA,ShiftA,OutA);
input clk,LoadA,ShiftA;
input [3:0]A;
output reg [7:0]OutA;

initial OutA <= 0;

always@(posedge clk)begin
	if(LoadA == 1) OutA <=A;
	else if (ShiftA == 1) OutA <= OutA <<1;
end

endmodule

module rightShiftB (clk,B,LoadB,ShiftB,z,Bo);
input clk,LoadB,ShiftB;
input [3:0]B;
output reg z,Bo;

reg [3:0]OutB;

initial begin
	z <= 0;
	Bo <= 0;
end

always@(posedge clk)begin
	if(LoadB == 1) OutB <=B;
	else if (ShiftB == 1) OutB <= OutB >> 1;
	
	z <= ~(|OutB);
	Bo <= OutB[0];
end

endmodule

module adder(Aout,Pout,AddOut);
input [7:0]Aout,Pout;
output reg [7:0]AddOut;

always@(*) AddOut = Aout + Pout;

endmodule

module PRegister(clk,In,SelP, LoadP,Pout);
input clk,SelP,LoadP;
input [7:0]In;
output reg [7:0]Pout;

reg [7:0]InP;

always@(posedge clk)begin
	if(SelP == 0) InP <= 0;
	else if (SelP == 1) InP <= In;
	
	if(LoadP == 1) Pout <= InP;
end

endmodule

/*
module FSM #(parameter width = 1) (output reg z);
	always@(*) z = width;
endmodule
*/
