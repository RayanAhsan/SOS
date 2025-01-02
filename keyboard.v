


module sos (
    input [3:0] KEY,              // Keys for storing and switching turns
    input [9:0] SW,               // Switches for player inputs (8 switches)
    input CLOCK_50,
    inout PS2_CLK,
    inout PS2_DAT,
    output [9:0] LEDR,            // LED output
    output reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 // HEX display output
);

    // Declare internal signals and registers
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
   parameter pos1s = 8'h15;
    parameter pos2s = 8'h1D;
    parameter pos3s = 8'h2E;
    parameter pos4s = 8'h1C;
    parameter pos5s = 8'h4D;
    parameter pos6s = 8'h23;
    parameter pos7s = 8'h1A;
    parameter pos8s = 8'h22;
    parameter pos9s = 8'h21;
    parameter STORE = 8'h5A;  // Enter key scan code
    parameter RESET = 8'h29;
    parameter pos1o = 8'h6C;
    parameter pos2o = 8'h75;
    parameter pos3o = 8'h7D;
    parameter pos4o = 8'h6B;
    parameter pos5o = 8'h73;
    parameter pos6o = 8'h74;
    parameter pos7o = 8'h69;
    parameter pos8o = 8'h72;
    parameter pos9o = 8'h7A;
   
    // PS2 controller instance
    wire [7:0] ps2_key_data;
    wire ps2_key_pressed;
    PS2_Controller PS2(
        .CLOCK_50(CLOCK_50),
        .reset(~KEY[0]),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .received_data(ps2_key_data),
        .received_data_en(ps2_key_pressed)
    );
   
    initial current_player = 1'b0;
   
    reg [9:0] player; // Define the player register

    reg [9:0] playerInput;
	 
   assign LEDR[9] = sequenceFound;
	
	//assign LEDR[5] = illegal_move;
    // Instantiate playerConverter module for player
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
   
    wire sequenceFound1, sequenceFound2, sequenceFound3, sequenceFound4, sequenceFound5, sequenceFound6, sequenceFound7, sequenceFound8;
   
    determineMatch u1(POS1, POS2, POS3, sequenceFound1); // horizontal combo
    determineMatch u2(POS4, POS5, POS6, sequenceFound2); // horizontal combo
    determineMatch u3(POS7, POS8, POS9, sequenceFound3); // horizontal combo
    determineMatch u4(POS1, POS5, POS9, sequenceFound4); // diagonal combo
    determineMatch u5(POS3, POS5, POS7, sequenceFound5); // diagonal combo
    determineMatch u6(POS1, POS4, POS7, sequenceFound6); // vertical combo
    determineMatch u7(POS2, POS5, POS8, sequenceFound7); // vertical combo
    determineMatch u8(POS3, POS6, POS9, sequenceFound8); // vertical combo
   
    assign sequenceFound = (sequenceFound1 || sequenceFound2 || sequenceFound3 || sequenceFound4 || sequenceFound5 || sequenceFound6 || sequenceFound7 || sequenceFound8);
    
	 //assign LEDR[6] = sequenceFound;
	
	 
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

  /* always @(posedge CLOCK_50 or posedge ps2_key_pressed) begin
        if (ps2_key_pressed && ps2_key_data == STORE) begin
            player <= playerInput;
            current_player <= ~current_player;
        end
    end */

/*

always @(posedge CLOCK_50, posedge ps2_key_pressed) begin
       /* if (~KEY[1]) begin // Reset
            current_player <= 1'b0;
            POS1 <= 3'b000; POS2 <= 3'b000; POS3 <= 3'b000;
            POS4 <= 3'b000; POS5 <= 3'b000; POS6 <= 3'b000;
            POS7 <= 3'b000; POS8 <= 3'b000; POS9 <= 3'b000;
            player <= 10'b0000000000; // Reset player register
        end */
       /* if (ps2_key_pressed) begin
            case (ps2_key_data)
                pos1s: playerInput <=10'b0100001001;
                pos1o: playerInput <=10'b1000001001;
                pos2s: playerInput <= 10'b0100001010;
                pos2o: playerInput <= 10'b1000001010;
                pos3s: playerInput <= 10'b0100001100;
                pos3o: playerInput <= 10'b1000001100;
                pos4s: playerInput <= 10'b0100010001;
                pos4o: playerInput <= 10'b1000010001;
                pos5s: playerInput <= 10'b0100010010;
                pos5o: playerInput <= 10'b1000010010;
                pos6s: playerInput <= 10'b0100010100;
                pos6o: playerInput <= 10'b1000010100;
                pos7s: playerInput <= 10'b0100100001;
                pos7o: playerInput <= 10'b1000100001;
                pos8s: playerInput <= 10'b0100100010;
                pos8o: playerInput <= 10'b1000100010;
                pos9s: playerInput <= 10'b0100100100;
                pos9o: playerInput <= 10'b1000100100;
            endcase
        end
    end
   /*
    always @(*) begin
        if (ps2_key_pressed && ps2_key_data == STORE) begin
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
    end

*/




   always @(posedge CLOCK_50 or posedge ps2_key_pressed) begin
    if (ps2_key_pressed) begin
        // Handle input from the PS/2 keyboard
        case (ps2_key_data)
            pos1s: playerInput <= 10'b0100001001;
            pos1o: playerInput <= 10'b1000001001;
            pos2s: playerInput <= 10'b0100001010;
            pos2o: playerInput <= 10'b1000001010;
            pos3s: playerInput <= 10'b0100001100;
            pos3o: playerInput <= 10'b1000001100;
            pos4s: playerInput <= 10'b0100010001;
            pos4o: playerInput <= 10'b1000010001;
            pos5s: playerInput <= 10'b0100010010;
            pos5o: playerInput <= 10'b1000010010;
            pos6s: playerInput <= 10'b0100010100;
            pos6o: playerInput <= 10'b1000010100;
            pos7s: playerInput <= 10'b0100100001;
            pos7o: playerInput <= 10'b1000100001;
            pos8s: playerInput <= 10'b0100100010;
            pos8o: playerInput <= 10'b1000100010;
            pos9s: playerInput <= 10'b0100100100;
            pos9o: playerInput <= 10'b1000100100;
		  endcase

        // Update the `player` and toggle `current_player` when `STORE` is pressed
        if (ps2_key_data == RESET) begin
		  POS1 <= 3'b000; POS2 <= 3'b000; POS3 <= 3'b000;
			POS4 <= 3'b000; POS5 <= 3'b000; POS6 <= 3'b000;
			POS7 <= 3'b000; POS8 <= 3'b000; POS9 <= 3'b000;
            current_player <= ~current_player;
        end else if (ps2_key_data == STORE) begin
				player <= playerInput;
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

        // Update game state and position registers if move is not illegal
      /*  if (ps2_key_data == STORE && illegal_move == 1'b0) begin
            currentState <= nextState;
            POS1 <= pos1;
            POS2 <= pos2;
            POS3 <= pos3;
            POS4 <= pos4;
            POS5 <= pos5;
            POS6 <= pos6;
            POS7 <= pos7;
            POS8 <= pos8;
            POS9 <= pos9;
        end */
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
           
            if ( POS1 != 3'b000) begin
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



