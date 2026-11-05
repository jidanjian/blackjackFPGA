`timescale 1ns / 1ps

// Pseudo-random blackjack card value generator.
//   q     = card value 1..10  (Ace = 1, 2..9 = face value, 10/J/Q/K = 10)
//   isAce = 1 when the card is an Ace (so you can count it as 1 or 11)
module card_lfsr (
    input  logic       clk,
    input  logic       rst,
    output logic [7:0] q,       // the value of the card
    output logic       isAce    // 1 if the card is an Ace
);

    // 16-bit register holding the LFSR state. Must never be all zeros.
    logic [15:0] state = 16'h0001;     // same seed as reset, so power-up == reset
    logic        feedback;
    logic [3:0]  rank;                 // 0..12  (0=A, 1..8 = 2..9, 9..12 = 10,J,Q,K)

    // Maximal-length taps for 16 bits (16,15,13,4): visits all 65535 non-zero states.
    assign feedback = state[15] ^ state[14] ^ state[12] ^ state[3];

    always_ff @(posedge clk) begin
        if (rst) state <= 16'h0001;
        else     state <= {state[14:0], feedback};   // shift left, feedback enters at bit 0
    end

    // Turn the random number into one of 13 ranks
    assign rank = state % 13;

    // Turn the rank into a blackjack value
    always_comb begin
        if (rank == 0) begin            // Ace
            q     = 8'd1;
            isAce = 1'b1;
        end else if (rank <= 8) begin   // 2..9
            q     = rank + 8'd1;
            isAce = 1'b0;
        end else begin                  // 10, J, Q, K
            q     = 8'd10;
            isAce = 1'b0;
        end
    end
endmodule
