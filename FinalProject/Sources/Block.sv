`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2025 03:24:59 AM
// Design Name: 
// Module Name: Block
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Block( 
    input  logic        Reset, 
    input  logic        frame_clk,
    input  logic [7:0]  keycode,
    //input  logic [2:0]  rand_num,
    
    //output logic       new_piece,
    output logic       gameover_flag,
    output logic [9:0] score,
    output logic [2:0] grid[10][22]
);
	 
    logic [7:0] prev_keycode;
    // timer used to count blocks time
    // if timer = update then block moves down a row
    // !!! RENAME TIMER TO DROP_COUNTER
    logic [4:0] timer;
    
    // update used as the block speed
    logic [4:0] drop_interval, drop_interval_2;
        
    // current_grid calculates the next grid
    logic [2:0] current_grid[10][22];
    
    //drop grid used for drop logic
    logic [2:0] drop_grid[10][22];
    
    // Used to start the game
    logic blankBoard, blankBoard2;
        
    // Completed row variable
    logic rowComplete;    
    
    // Can we drop???    
    logic drop, drop_condition;
    
    //Can we move??
    logic move_condition;
    
    // Allows instant drop
    logic drop_block, drop_l;

    // random number
    //logic [2:0] rand_num, randTemp;
    logic [2:0] rand_num, randTemp;
    
    // track rotations
    logic [1:0] rotate, flipped;
    
    // generateNew signals the creation of a new block
    logic generateNew;
    
    // values used for rotations
    // y and x = current row and curr col pivots
    // col and row are next row and col
    logic [4:0] x, y, col, row;
    
    
    // alreadyMoved keeps user from moving and rotating at the same time
    // !!! CHANGE NAME
    logic alreadyMoved;
    
    logic [9:0] score_l, scoreTracker;



    always_comb begin
        
        // update variables
        col = x;
        row = y;
        current_grid = grid;
        randTemp = rand_num;
        blankBoard2 = blankBoard;
        rotate = flipped;
        score_l = score;
        scoreTracker = score;
        drop_interval_2 = drop_interval;
        generateNew = 0;
        alreadyMoved = 0;
        drop_l = drop_block;

        if (blankBoard) begin
            generateNew = 1;
            //new_piece = 1;
            blankBoard2 = 0;
        end
               
        //check for a game over
        for (int i = 0; i <= 2; i++) begin
            for (int j = 0; j < 10; j++) begin
                if (grid[j][i] == 1) begin
                    gameover_flag = 1;
                end
            end
        end        
        
        // time cycle: update
        // timer == drop_interval indicates the time is ready for block to drop
        // dropIt drops the block when 's' is pressed
        if (timer == drop_interval || drop_block) begin
            // drop logic
            if (drop_condition) begin
                alreadyMoved = 1;
                row = row + 1;
                for (int i = 0; i < 10; i++) begin // each col
                    for (int j = 0; j < 22; j++) begin // each row
                        if (j == 0) begin
                            current_grid[i][j] = 0; // top row is always empty
                        end else if (grid[i][j] == 1) begin
                            current_grid[i][j] = grid[i][j]; // locked blocks stay locked
                        end else if (grid[i][j-1] >= 2) begin
                            current_grid[i][j] = grid[i][j-1]; // active blocks should fall
                        end else begin
                            current_grid[i][j] = 0; // everything else empty
                        end
                    end
                end
             // cant drop block any further (Collision)   
            // deactivate current block and generate new block
            end else begin
                drop_l = 0;
                for (int i = 0; i < 10; i++) begin // each col
                    for (int j = 0; j < 22; j++) begin // each row
                        if (grid[i][j] >= 2) begin
                            current_grid[i][j] = 1; // active block is locked 
                        end
                    end
                end
                generateNew = 1; // generate new block
                //new_piece = 1;
            end
        end        
        
        // check if okay to drop
        drop_condition = 1;
        for (int i = 0; i < 10; i++) begin
            for (int j = 0; j < 22; j++) begin
                if (grid[i][j] >= 2) begin // Only current tetris blocks (empty=0 or locked=1) are ignored
                    if (j >= 21) begin // bottom of playfield
                        drop_condition = 0;
                    end else if (grid[i][j+1] != 0 && grid[i][j+1] != grid[i][j]) begin
                    // grid[i][j+1] != 0 checks if something is at the next row
                    // grid[i][j+1] != grid[i][j] checks if that something is NOT part of the current block
                        drop_condition = 0;
                    end
                end
            end
        end
        
        
        
        if (generateNew) begin
            // delete completed rows
            for (int j = 0; j < 22; j++) begin // iterate through every row
                drop_grid = current_grid;
                rowComplete = 1; // default
                for (int i = 0; i < 10; i++) begin
                // check every column in that row
                // if any column does not have a locked block, row is not complete
                    if (drop_grid[i][j] != 1) begin
                        rowComplete = 0;
                    end
                end
                if (rowComplete) begin
                // increment score
                    scoreTracker += 1;
                    for (int k = 0; k < 10; k++) begin // for each column
                        for (int l = 0; l <= j; l++) begin // for each row up to j (above cleared row)
                            if (l == 0) begin
                                current_grid[k][l] = 0; // Row 0 is cleared 
                            end else begin
                                // every other block gets dropped
                                // the current block gets the block above it
                                // only up to j, so above the cleared row
                                //rows below the cleared row are not affected
                                current_grid[k][l] = drop_grid[k][l-1];
                            end
                        end
                    end
                    // speed up the block fall speed after each block drop
                    // we go no faster than 5 (equal to 0.09s)
                    if (drop_interval > 5) begin
                        drop_interval_2 = drop_interval - 1;
                    end
                end
            end
            
            score_l = scoreTracker;
            
            // generate new block
            if (rand_num >= 5) begin
                randTemp = rand_num % 5;
            end else begin
                randTemp = rand_num + 1;
            end
            
            // 2x2 block (Square)
            if (randTemp == 0) begin
                current_grid[4][0] = 2;
                current_grid[5][0] = 2;
                current_grid[4][1] = 2;
                current_grid[5][1] = 2;
                col = 4;
                row = 0;
                rotate = 0;
            // 4x1 block (l block)
            end else if (randTemp == 1) begin
                current_grid[3][1] = 3;
                current_grid[4][1] = 3;
                current_grid[5][1] = 3;
                current_grid[6][1] = 3;
                col = 3;
                row = 1;
                rotate = 0;
            // s block 
            end else if (randTemp == 2) begin
                current_grid[4][1] = 4;
                current_grid[5][1] = 4;
                current_grid[5][0] = 4;
                current_grid[6][0] = 4;
                col = 4;
                row = 1;
                rotate = 0;
            // z block
            end else if (randTemp == 3) begin
                current_grid[4][0] = 5;
                current_grid[5][0] = 5;
                current_grid[5][1] = 5;
                current_grid[6][1] = 5;
                col = 4;
                row = 0;
                rotate = 0;
            // L block
            end else if (randTemp == 4) begin
                current_grid[4][1] = 6;
                current_grid[5][1] = 6;
                current_grid[6][1] = 6;
                current_grid[6][0] = 6;
                col = 4;
                row = 1;
                rotate = 0;
            // j block
            end else if (randTemp == 5) begin
                current_grid[4][0] = 7;
                current_grid[4][1] = 7;
                current_grid[5][1] = 7;
                current_grid[6][1] = 7;
                col = 4;
                row = 0;
                rotate = 0;
            //t block 
            // FPGA is too small for grid value to be 4 bits wide
               //end else if (randTemp == 6) begin
                //current_grid[4][1] = 8;
                //current_grid[5][1] = 8;
                //current_grid[5][0] = 8;
                //current_grid[6][1] = 8;
                //col = 4;
                //row = 1;
                //rotate = 0;
            end
         end
        
        // keycode logic
        else if (prev_keycode == 8'h00 && !alreadyMoved) begin
            // w key
            if (keycode == 8'h1A) begin
               // randTemp = rand_num + 1;
                // 4x1 block
                // grid[nx][ny] == 3 gives line block
                if (grid[x][y] == 3) begin
                    // rotatedTemp[0] == 0 means line block is horizontal
                    if (flipped[0] == 0) begin
                    // ny <= 0 || ny >= 20 prevents flipping into boundaries
                    // grid[nx+1][ny-1] == 1 || grid[nx+1][ny+1] == 1 || grid[nx+1][ny+2] == 1 
                    //checks new positions after flipping
                        if (y <= 0 || y >= 20 || grid[x+1][y-1] == 1 || grid[x+1][y+1] == 1 || grid[x+1][y+2] == 1) 
                        begin
                            // do nothing
                        end else begin // rotate!!
                            rotate = flipped + 1;
                            current_grid[x][y] = 0;
                            current_grid[x+2][y] = 0;
                            current_grid[x+3][y] = 0;
                            current_grid[x+1][y-1] = 3;
                            current_grid[x+1][y+1] = 3;
                            current_grid[x+1][y+2] = 3;
                            col = x + 1;
                            row = y - 1;
                            // new pivot at grid[nx+1][ny-1]
                        end
                    end else begin
                        if (x <= 0 || x >= 8 || grid[x-1][y+1] == 1 || grid[x+1][y+1] == 1 || grid[x+2][y+1] == 1) 
                        begin
                             // do nothing
                        end else begin
                            rotate = flipped - 1;
                            current_grid[x][y] = 0;
                            current_grid[x][y+2] = 0;
                            current_grid[x][y+3] = 0;
                            current_grid[x-1][y+1] = 3;
                            current_grid[x+1][y+1] = 3;
                            current_grid[x+2][y+1] = 3;
                            col = x - 1;
                            row = y + 1;
                            // new pivot at grid[nx-1][ny+1] (Original)
                        end
                    end
                end
                        
                // s block
                else if (grid[x][y] == 4) begin
                    if (flipped[0] == 0) begin
                        if (y >= 21 || grid[x][y-1] == 1 || grid[x+1][y+1] == 1) begin
                            // do nothing
                        end else begin
                            rotate = flipped + 1;
                            current_grid[x+1][y-1] = 0;
                            current_grid[x+2][y-1] = 0;
                            current_grid[x][y-1] = 4;
                            current_grid[x+1][y+1] = 4;
                            col = x;
                            row = y - 1;
                        end
                    end else begin
                        if (x >= 8 || grid[x+1][y-1] == 1 || grid[x+2][y-1] == 1) begin
                            // do nothing
                        end else begin
                            rotate = flipped - 1;
                            current_grid[x][y] = 0;
                            current_grid[x+1][y+2] = 0;
                            current_grid[x+1][y] = 4;
                            current_grid[x+2][y] = 4;
                            col = x;
                            row = y + 1;
                        end
                    end
                end
                
                // z block
                else if (grid[x][y] == 5) begin
                    if (flipped[0] == 0) begin
                        if (y >= 21 || grid[x+2][y] == 1 || grid[x+1][y+2] == 1) begin
                            // do nothing
                        end else begin
                            rotate = flipped + 1;
                            current_grid[x][y] = 0;
                            current_grid[x+1][y] = 0;
                            current_grid[x+2][y] = 5;
                            current_grid[x+1][y+2] = 5;
                            col = x + 1;
                            row = y + 1;
                        end
                    end else begin
                        if (x <= 0 || grid[x-1][y-1] == 1 || grid[x][y-1] == 1) begin
                            // do nothing
                        end else begin
                            rotate = flipped - 1;
                            current_grid[x][y+1] = 0;
                            current_grid[x+1][y-1] = 0;
                            current_grid[x-1][y-1] = 5;
                            current_grid[x][y-1] = 5;
                            col = x - 1;
                            row = y - 1;
                        end
                    end
                end
                
                // l block   
                else if (grid[x][y] == 6) begin
                    if (flipped == 0) begin
                        if (y >= 21 || grid[x+1][y-1] == 1 || grid[x+1][y+1] == 1 || grid[x+2][y+1] == 1) begin
                            // do nothing
                        end else begin
                            rotate = flipped + 1;
                            current_grid[x+1][y-1] = 6;
                            current_grid[x+1][y+1] = 6;
                            current_grid[x+2][y+1] = 6;
                            current_grid[x][y] = 0;
                            current_grid[x+2][y] = 0;
                            current_grid[x+2][y-1] = 0;
                            col = x + 1;
                            row = y - 1;
                        end
                    end else if (flipped == 1) begin
                        if (x <= 0 || grid[x-1][y+1] == 1 || grid[x-1][y+2] == 1 || grid[x+1][y+1] == 1) 
                        begin
                            // do nothing
                        end else begin
                            rotate = flipped + 1;
                            current_grid[x-1][y+1] = 6;
                            current_grid[x-1][y+2] = 6;
                            current_grid[x+1][y+1] = 6;
                            current_grid[x][y] = 0;
                            current_grid[x][y+2] = 0;
                            current_grid[x+1][y+2] = 0;
                            col = x - 1;
                            row = y + 1;
                        end
                    end else if (flipped == 2) begin
                        if (y <= 0 || grid[x][y-1] == 1 || grid[x+1][y-1] == 1 || grid[x+1][y+1] == 1) begin
                            // do nothing
                        end else begin
                            rotate = flipped + 1;
                            current_grid[x][y-1] = 6;
                            current_grid[x+1][y-1] = 6;
                            current_grid[x+1][y+1] = 6;
                            current_grid[x][y+1] = 0;
                            current_grid[x][y] = 0;
                            current_grid[x+2][y] = 0;
                            col = x;
                            row = y - 1;
                        end
                    end else begin
                        if (x >= 8 || grid[x+2][y] == 1 || grid[x+2][y+1] == 1 || grid[x][y+1] == 1) begin
                            // do nothing
                        end else begin
                            rotate = flipped - 3;
                            current_grid[x+2][y] = 6;
                            current_grid[x+2][y+1] = 6;
                            current_grid[x][y+1] = 6;
                            current_grid[x][y] = 0;
                            current_grid[x+1][y] = 0;
                            current_grid[x+1][y+2] = 0;
                            col = x;
                            row = y + 1;
                        end
                    end
                end
                
                // j block
                else if (grid[x][y] == 7) begin
                    if (flipped == 0) begin
                        if (y >= 20 || grid[x+1][y] == 1 || grid[x+2][y] == 1 || grid[x+1][y+2] == 1) begin
                            // do nothing
                        end else begin
                            rotate = flipped + 1;
                            current_grid[x+1][y] = 7;
                            current_grid[x+2][y] = 7;
                            current_grid[x+1][y+2] = 7;
                            current_grid[x][y] = 0;
                            current_grid[x][y+1] = 0;
                            current_grid[x+2][y+1] = 0;
                            col = x + 1;
                            row = y;
                        end
                    end else if (flipped == 1) begin
                        if (x <= 0 || grid[x-1][y+1] == 1 || grid[x+1][y+1] == 1 || grid[x+1][y+2] == 1) begin
                            // do nothing
                        end else begin
                            rotate = flipped + 1;
                            current_grid[x-1][y+1] = 7;
                            current_grid[x+1][y+1] = 7;
                            current_grid[x+1][y+2] = 7;
                            current_grid[x][y] = 0;
                            current_grid[x+1][y] = 0;
                            current_grid[x][y+2] = 0;
                            col = x - 1;
                            row = y + 1;
                        end
                    end else if (flipped == 2) begin
                        if (y <= 0 || grid[x][y+1] == 1 || grid[x+1][y+1] == 1 || grid[x+1][y-1] == 1) begin
                            // do nothing
                        end else begin
                            rotate = flipped + 1;
                            current_grid[x][y+1] = 7;
                            current_grid[x+1][y+1] = 7;
                            current_grid[x+1][y-1] = 7;
                            current_grid[x][y] = 0;
                            current_grid[x+2][y] = 0;
                            current_grid[x+2][y+1] = 0;
                            col = x;
                            row = y + 1;
                        end
                    end else begin
                        if (x >= 8 || grid[x][y-1] == 1 || grid[x][y-2] == 1 || grid[x+2][y-1] == 1) begin
                            // do nothing
                        end else begin
                            rotate = flipped - 3;
                            current_grid[x][y-1] = 7;
                            current_grid[x][y-2] = 7;
                            current_grid[x+2][y-1] = 7;
                            current_grid[x][y] = 0;
                            current_grid[x+1][y] = 0;
                            current_grid[x+1][y-2] = 0;
                            col = x;
                            row = y - 2;
                        end
                    end 
                end
                
                // t block 
           /*     else if (grid[x][y] == 8) begin
                    if (rotatedTemp == 0) begin
                        if (y >= 21 || grid[x+2][y+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            current_grid[x][y] = 0;
                            current_grid[x+2][y] = 0;
                            current_grid[x+2][y+1] = 8;
                            current_grid[x+1][y+2] = 8;
                            col = x + 1;
                            row = y + 2;
                        end
                    end else if (rotatedTemp == 1) begin
                        if (x <= 0 || grid[x-1][y+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            current_grid[x][y] = 0;
                            current_grid[x-1][y-1] = 8;
                            col = x + 1;
                            row = y - 1;
                        end
                    end else if (rotatedTemp == 2) begin
                        if (y <= 0 || grid[x][y-2] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            current_grid[x+1][y+1] = 0;
                            current_grid[x][y+2] = 8;
                            col = x - 1;
                            row = y + 1;
                        end
                    end else begin
                        if (x >= 8 || grid[x+1][y+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp -3;
                            current_grid[x+1][y-1] = 0;
                            current_grid[x+2][y] = 8;
                            col = x + 1;
                            row = y + 1;
                        end
                    end
                end */
                // end of t
                
            // a key
            end else if (keycode == 8'h04) begin
                randTemp = rand_num + 1;
                move_condition = 1;
                for (int i = 0; i < 10; i++) begin
                    for (int j = 0; j < 22; j++) begin
                        if (grid[i][j] >= 2) begin
                            if (i-1 < 0) begin
                                move_condition = 0;
                            end else if (grid[i-1][j] != 0 && grid[i-1][j] != grid[i][j]) begin
                                move_condition = 0;
                            end
                        end
                    end
                end
                
                if (move_condition) begin
                    col = x - 1;
                    for (int i = 0; i < 10; i++) begin
                        for (int j = 0; j < 22; j++) begin
                            if (grid[i][j] == 1) begin
                                current_grid[i][j] = 1;
                            end else if (i < 9 && grid[i+1][j] >= 2) begin
                                current_grid[i][j] = grid[i+1][j];
                            end else begin
                                current_grid[i][j] = 0;
                            end
                        end
                    end
                end
                
            // s key
            end else if (keycode == 8'h16) begin
                drop_l = 1;
                randTemp = rand_num + 3;
            // d key
            end else if (keycode == 8'h07) begin
                randTemp = rand_num + 3;
                move_condition = 1;
                for (int i = 0; i < 10; i++) begin
                    for (int j = 0; j < 22; j++) begin
                        if (grid[i][j] >= 2) begin
                            if (i+1 >= 10) begin
                                move_condition = 0;
                            end else if (grid[i+1][j] != 0 && grid[i+1][j] != grid[i][j]) begin
                                move_condition = 0;
                            end
                        end
                    end
                end
                
                if (move_condition) begin
                    col = x + 1;
                    for (int i = 0; i < 10; i++) begin
                        for (int j = 0; j < 22; j++) begin
                            if (grid[i][j] == 1) begin
                                current_grid[i][j] = 1;
                            end else if (i >= 1 && grid[i-1][j] >= 2) begin
                                current_grid[i][j] = grid[i-1][j];
                            end else begin
                                current_grid[i][j] = 0;
                            end
                        end
                    end
                end
            end
        end
    end  
        

    always_ff @(posedge frame_clk or posedge Reset) // make sure the frame clock is instantiated correctly
    begin
        if (Reset)
        begin 
            grid <= '{default:'0};            
            gameover_flag <= 0;
            // set variables
            prev_keycode <= 8'h00;
            timer <= 0;
            alreadyMoved <= 0;
            rand_num <= 5;
            drop <= 1;
            blankBoard <= 1;
            score <= 0;
            drop_interval <= 30;
            flipped <= 0;
            drop_block <= 0;
        end 
        else begin
            // update variables
            grid <= current_grid;
            rand_num <= randTemp;
            drop <= drop_condition;
            drop_block <= drop_l;
            blankBoard <= blankBoard2;
            x <= col;
            y <= row;
            flipped <= rotate;
            score <= score_l;
            drop_interval <= drop_interval_2;
            
            // update more variables
            prev_keycode <= keycode;
            
            timer <= timer + 1;
            if (timer > drop_interval) begin
                timer <= 0;
            end
        end
    end
      
endmodule

