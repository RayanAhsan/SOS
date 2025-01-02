/*
*   Displays a pattern, which is read from a small memory, at (x,y) on the VGA output.
*   To set coordinates, first place the desired value of y onto SW[6:0] and press KEY[1].
*   Next, place the desired value of x onto SW[7:0] and then press KEY[2]. The (x,y)
*   coordinates are displayed (in hexadecimal) on (HEX3-2,HEX1-0). Finally, press KEY[3]
*   to draw the pattern at location (x,y).
*/
module vga_demo(CLOCK_50, SW, KEY, HEX3, HEX2, HEX1, HEX0,
				VGA_R, VGA_G, VGA_B,
				VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, LEDR);
	
	input CLOCK_50;	
	input [9:0] SW;
	input [3:0] KEY;
	output [9:0] LEDR;
	output reg [6:0] HEX3, HEX2, HEX1, HEX0;
	
	
	
	
	wire illegal_move;             // Indicator for illegal moves

    reg [9:0] player1;            // Store Player 1's code
    reg [9:0] player2;            // Store Player 2's code
    reg [8:0] occupied;           // Tracks occupied positions
    reg current_player;           // 0 for Player 1, 1 for Player 2

    wire [8:0] player_position;
    wire [2:0] player_choice;    
    wire [6:0] HEX5_p1, HEX4_p1, HEX3_p1;
    wire [6:0] HEX5_p2, HEX4_p2, HEX3_p2;
    wire [2:0] pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8, pos9;
    wire winner;
    wire sequenceFound;
    wire continueGame;
    reg ContGame;
    reg [2:0] POS1, POS2, POS3, POS4, POS5, POS6, POS7, POS8, POS9;

reg [1:0] currentState, nextState;
parameter IDLE = 2'b00;
parameter PLAYER1_MOVE = 2'b01;
parameter PLAYER2_MOVE = 2'b10;
parameter ENDGAME = 2'b11;

	
	
	
	
	
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK_N;
	output VGA_SYNC_N;
	output VGA_CLK;	
	
	wire [7:0] X;           // starting x location of object
	wire [6:0] Y;           // starting y location of object
    wire [2:0] XC, YC;      // used to access object memory
    wire Ex, Ey;
	wire [7:0] VGA_X;       // x location of each object pixel
	wire [6:0] VGA_Y;       // y location of each object pixel
	wire [2:0] VGA_COLOR;   // color of each object pixel
	
    // store (x,y) starting location


    // connect to VGA controller
    vga_adapter VGA (
			.resetn(KEY[2]),
			.clock(CLOCK_50),
			.colour(VGA_COLOR),
			.x(VGA_X),
			.y(VGA_Y),
			.plot(~KEY[3]),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK_N(VGA_BLANK_N),
			.VGA_SYNC_N(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "image.colour.mif";
		
		
		
		
		initial current_player = 1'b0;
 

    reg [9:0] player; // Define the player register

    // Instantiate playerConverter modules for both players
    playerConverter pc1 (
        .POS1(POS1),
        .POS2(POS2),
        .POS3(POS3),
        .POS4(POS4),
        .POS5(POS5),
        .POS6(POS6),
        .POS7(POS7),
        .POS8(POS8),
        .POS9(POS9),
        .player(player),
        .player_position(player_position),
        .HEX5(HEX5_p1),
        .HEX4(HEX4_p1),
        .HEX3(HEX3_p1),
        .pos1(pos1), .pos2(pos2), .pos3(pos3),
        .pos4(pos4), .pos5(pos5), .pos6(pos6),
        .pos7(pos7), .pos8(pos8), .pos9(pos9),
        .illegal_move(illegal_move),
		  .CLOCK_50(CLOCK_50)
    );




wire sequenceFound1,sequenceFound2,sequenceFound3,sequenceFound4,sequenceFound5,sequenceFound6,sequenceFound7, sequenceFound8;


determineMatch u1(POS1,POS2,POS3, sequenceFound1); //horizontal combo

determineMatch u2(POS4,POS5,POS6, sequenceFound2); //horizontal combo

determineMatch u3(POS7,POS8,POS9, sequenceFound3); //horizontal combo

determineMatch u4(POS1,POS5,POS9, sequenceFound4);  //diagonal combo

determineMatch u5(POS3,POS5,POS7, sequenceFound5); //diagonal combo

determineMatch u6(POS1,POS4,POS7, sequenceFound6); //vertical combo

determineMatch u7(POS2,POS5,POS8, sequenceFound7); //vertical combo

determineMatch u8(POS3,POS6,POS9, sequenceFound8); //vertical combo

assign sequenceFound = (sequenceFound1 || sequenceFound2|| sequenceFound3|| sequenceFound4|| sequenceFound5|| sequenceFound6|| sequenceFound7|| sequenceFound8);


assign LEDR[6] = sequenceFound;

//assign LEDR[0] = illegal_move;

//assign LEDR[3] = (continueGame == 1'b0) ? 1'b1 : 1'b0;



 
    always @(negedge KEY[0]) begin
        if (~KEY[0]) begin
            player <= SW[9:0];
            current_player <= 1'b0;
        end
    end

    always @(posedge CLOCK_50) begin
        if (current_player == 1'b0) begin
            HEX2 = HEX5_p1;
            HEX1 = HEX4_p1;
            HEX0 = HEX3_p1;
        end else begin
            HEX2 = HEX5_p2;
            HEX1 = HEX4_p2;
            HEX0 = HEX3_p2;
        end
		  end
//		  always @(posedge CLOCK_50)
//		  begin
//		   // Display illegal move status on HEX0
//
//        if (illegal_move == 1) begin
//
//            HEX0 = 7'b1111001; // Display '1' for illegal move
//
//        end 
//		  else 
//		  begin
//
//            HEX0 = 7'b1000000; // Display '0' for no illegal move
//
//        end
//
// 
//end
 


   
always @(*) begin

if (~KEY[0]) begin
            currentState <= nextState;
     if (illegal_move == 1'b0) begin
                POS1 <= pos1;
                POS2 <= pos2;
                POS3 <= pos3;
                POS4 <= pos4;
                POS5 <= pos5;
                POS6 <= pos6;
                POS7 <= pos7;
                POS8 <= pos8;
                POS9 <= pos9;
            end
				
			
		  
end

        if (~KEY[1]) begin
            currentState <= IDLE;
            POS1 <= 3'b000; POS2 <= 3'b000; POS3 <= 3'b000;
            POS4 <= 3'b000; POS5 <= 3'b000; POS6 <= 3'b000;
            POS7 <= 3'b000; POS8 <= 3'b000; POS9 <= 3'b000;
           
        end

		  
		   

    end
	 
	  game_End gameEndInstance (

        .continueGame(continueGame),

        .p1(POS1),

        .p2(POS2),

        .p3(POS3),

        .p4(POS4),

        .p5(POS5),

        .p6(POS6),

        .p7(POS7),

        .p8(POS8),

        .p9(POS9)

    );


		
		
		
		
		
		
endmodule

module regn(R, Resetn, E, Clock, Q);
    parameter n = 8;
    input [n-1:0] R;
    input Resetn, E, Clock;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (!Resetn)
            Q <= 0;
        else if (E)
            Q <= R;
endmodule

module count (Clock, Resetn, E, Q);
    parameter n = 8;
    input Clock, Resetn, E;
    output reg [n-1:0] Q;

    always @ (posedge Clock)
        if (Resetn == 0)
            Q <= 0;
        else if (E)
                Q <= Q + 1;
endmodule






module playerConverter(
    input [9:0] player, // Input representing the player's switches
    input [2:0] POS1,
    input [2:0] POS2,
    input [2:0] POS3,
    input [2:0] POS4,
    input [2:0] POS5,
    input [2:0] POS6,
    input [2:0] POS7,
    input [2:0] POS8,
    input [2:0] POS9,
    output reg [8:0] player_position, // Output for player positions
    output reg [6:0] HEX5,
    output reg [6:0] HEX4,
    output reg [6:0] HEX3,
    output reg [2:0] pos1,          // Position 1
    output reg [2:0] pos2,          // Position 2
    output reg [2:0] pos3,          // Position 3
    output reg [2:0] pos4,          // Position 4
    output reg [2:0] pos5,          // Position 5
    output reg [2:0] pos6,          // Position 6
    output reg [2:0] pos7,          // Position 7
    output reg [2:0] pos8,          // Position 8
    output reg [2:0] pos9,          // Position 9
    output reg illegal_move, // Signal for illegal move
	 input CLOCK_50
);

    wire [6:0] A, B, C, ONE, TWO, THREE, S, O;

    // Assign segment values
    assign A = 7'b0001000;
    assign B = 7'b0000011;
    assign C = 7'b1000110;
    assign ONE = 7'b1111001;
    assign TWO = 7'b0100100;
    assign THREE = 7'b0110000;
    assign S = 7'b0010010;
    assign O = 7'b0100011;

    // Handle conversions
    always @(posedge CLOCK_50) begin
        // Initialize outputs
        player_position = 9'b0; // Reset positions
        illegal_move = 1'b0; // Reset illegal move flag

        // Position 1
        if (player[0] && player[3] && player[8]) begin
           
            if (POS1 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[0] = 1;
                pos1 = 3'b001;
                HEX5 = A;
                HEX4 = ONE;
                HEX3 = S;
            end
        end else if (player[0] && player[3] && player[9]) begin
           
            if (POS1 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[0] = 1;
                pos1 = 3'b010;
                HEX5 = A;
                HEX4 = ONE;
                HEX3 = O;
            end
        end

        // Position 2
        if (player[1] && player[3] && player[8]) begin
           
            if (POS2 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[1] = 1;
                pos2 = 3'b001;
                HEX5 = B;
                HEX4 = ONE;
                HEX3 = S;
            end
        end else if (player[1] && player[3] && player[9]) begin
           
            if (POS2 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[1] = 1;
                pos2 = 3'b010;
                HEX5 = B;
                HEX4 = ONE;
                HEX3 = O;
            end
        end

        // Position 3
        if (player[2] && player[3] && player[8]) begin
           
            if (POS3 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[2] = 1;
                pos3 = 3'b001;
                HEX5 = C;
                HEX4 = ONE;
                HEX3 = S;
            end
        end else if (player[2] && player[3] && player[9]) begin
           
            if (POS3 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[2] = 1;
                pos3 = 3'b010;
                HEX5 = C;
                HEX4 = ONE;
                HEX3 = O;
            end
        end

        // Position 4
        if (player[0] && player[4] && player[8]) begin
           
            if (POS4 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[3] = 1;
                pos4 = 3'b001;
                HEX5 = A;
                HEX4 = TWO;
                HEX3 = S;
            end
        end else if (player[0] && player[4] && player[9]) begin
           
            if (POS4 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[3] = 1;
                pos4 = 3'b010;
                HEX5 = A;
                HEX4 = TWO;
                HEX3 = O;
            end
        end

        // Position 5
        if (player[1] && player[4] && player[8]) begin
           
            if (POS5 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
  player_position[4] = 1;
                pos5 = 3'b001;
                HEX5 = B;
                HEX4 = TWO;
                HEX3 = S;
            end
        end else if (player[1] && player[4] && player[9]) begin
           
            if (POS5 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[4] = 1;
                pos5 = 3'b010;
                HEX5 = B;
                HEX4 = TWO;
                HEX3 = O;
            end
        end

        // Position 6
        if (player[2] && player[4] && player[8]) begin
            if (POS6 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[5] = 1;
                pos6 = 3'b001;
                HEX5 = C;
                HEX4 = TWO;
                HEX3 = S;
            end
        end else if (player[2] && player[4] && player[9]) begin
           
            if (POS6 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[5] = 1;
                pos6 = 3'b010;
                HEX5 = C;
                HEX4 = TWO;
                HEX3 = O;
            end
        end

        // Position 7
        if (player[0] && player[5] && player[8]) begin
           
            if (POS7 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[6] = 1;
                pos7 = 3'b001;
                HEX5 = A;
                HEX4 = THREE;
                HEX3 = S;
            end
        end else if (player[0] && player[5] && player[9]) begin
           
            if (POS7 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[6] = 1;
                pos7 = 3'b010;
                HEX5 = A;
                HEX4 = THREE;
                HEX3 = O;
            end
        end

        // Position 8
        if (player[1] && player[5] && player[8]) begin
           
            if (POS8 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[7] = 1;
                pos8 = 3'b001;
                HEX5 = B;
                HEX4 = THREE;
                HEX3 = S;
            end
        end else if (player[1] && player[5] && player[9]) begin
            if (POS8 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[7] = 1;
                pos8 = 3'b010;
                HEX5 = B;
                HEX4 = THREE;
                HEX3 = O;
            end
        end

        // Position 9
        if (player[2] && player[5] && player[8]) begin
           
            if (POS9 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[8] = 1;
                pos9 = 3'b001;
                HEX5 = C;
                HEX4 = THREE;
                HEX3 = S;
            end
        end else if (player[2] && player[5] && player[9]) begin
            if (POS9 != 3'b000) begin
                illegal_move = 1'b1;
            end else begin
player_position[8] = 1;
                pos9 = 3'b010;
                HEX5 = C;
                HEX4 = THREE;
                HEX3 = O;
            end
        end
    end
endmodule

module determineMatch(input [2:0] pos1,pos2,pos3, output sequenceFound);

assign sequenceFound = (pos1 == 3'b001) && (pos2==3'b010) && (pos3 == 3'b001);

endmodule


module game_End(output reg continueGame, input [2:0] p1, p2, p3, p4, p5, p6, p7, p8, p9);
    always @(*) begin
        continueGame <= 1'b1; // Assume the game continues by default
        // Check if all positions are filled
        if (p1 != 3'b000 && p2 != 3'b000 && p3 != 3'b000 &&
            p4 != 3'b000 && p5 != 3'b000 && p6 != 3'b000 &&
            p7 != 3'b000 && p8 != 3'b000 && p9 != 3'b000) begin
            continueGame <= 1'b0; // End the game if all positions are filled
        end
    end
endmodule




