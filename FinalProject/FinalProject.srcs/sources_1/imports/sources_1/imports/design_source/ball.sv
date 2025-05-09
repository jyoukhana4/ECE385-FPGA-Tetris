//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf     03-01-2006                           --
//                                  03-12-2007                           --
//    Translated by Joe Meng        07-07-2013                           --
//    Modified by Zuofu Cheng       08-19-2023                           --
//    Modified by Satvik Yellanki   12-17-2023                           --
//    Fall 2024 Distribution                                             --
//                                                                       --
//    For use with ECE 385 USB + HDMI Lab                                --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------
module  ball 
( 
    input  logic        Reset, 
    input  logic        frame_clk,
    input  logic [7:0]  keycode,
    //input  logic [2:0]  rand_num,
    
    //output logic       new_piece,
    output logic [9:0] score,
    output logic [2:0] grid[10][22]
);
	 
    logic [7:0] prev_keycode;
    // timer used to count blocks time
    // if timer = update then block moves down a row
    // !!! RENAME TIMER TO DROP_COUNTER
    logic [4:0] timer;
    // update used as the block speed
    // !!! RENAME UPDATE TO DROP_INTERVAL
    logic [4:0] update, updateTemp;
        
    // temp_grid calculates the next grid
    logic [2:0] temp_grid[10][22];
    //temp temp used for drop logic
    // !!! RENAME TO DROP GRID
    logic [2:0] temp_temp_grid[10][22];
    // logic [2:0] prev_grid[10][22];
    
    // Used to start the game
    logic blankBoard, blankBoardTemp;
        
    // Completed row variable
    logic rowComplete;    
    
    // Can we drop???    
    logic validToDrop, validToDropTemp;
    logic validToMove;

    // random number
    //logic [2:0] rand_num, randTemp;
    logic [2:0] rand_num, randTemp;
    logic [1:0] rotated, rotatedTemp;
    
    // generateNew signals the creation of a new block
    logic generateNew;
    
    // values used for rotations
    // ny and nx = current row and curr col pivots
    // tx and ty are next row and col
    logic [4:0] nx, ny, tx, ty;
    
    // alreadyMoved keeps user from moving and rotating at the same time
    // !!! CHANGE NAME
    logic alreadyMoved;
    
    logic [9:0] scoreTemp, scoreTracker;
    logic dropIt, dropItTemp;


    always_comb begin
        
        // update variables
        temp_grid = grid;
        randTemp = rand_num;
        blankBoardTemp = blankBoard;
        rotated = rotatedTemp;
        scoreTemp = score;
        scoreTracker = score;
        updateTemp = update;
        generateNew = 0;
        alreadyMoved = 0;
        tx = nx;
        ty = ny;
        dropItTemp = dropIt;

        if (blankBoard) begin
            generateNew = 1;
            //new_piece = 1;
            blankBoardTemp = 0;
        end
               
        //new_piece = 0;
                
        // check if okay to drop
        validToDropTemp = 1;
        for (int i = 0; i < 10; i++) begin
            for (int j = 0; j < 22; j++) begin
                if (grid[i][j] >= 2) begin // Only current tetris blocks (empty=0 or locked=1) are ignored
                    if (j >= 21) begin // bottom of playfield
                        validToDropTemp = 0;
                    end else if (grid[i][j+1] != 0 && grid[i][j+1] != grid[i][j]) begin
                    // grid[i][j+1] != 0 checks if something is at the next row
                    // grid[i][j+1] != grid[i][j] checks if that something is NOT part of the current block
                        validToDropTemp = 0;
                    end
                end
            end
        end
        
        
        // time cycle: update
        // timer == update indicates the time is ready for block to drop
        // dropIt drops the block when 's' is pressed
        if (timer == update || dropIt) begin
            // drop logic
            if (validToDropTemp) begin
                alreadyMoved = 1;
                ty = ny + 1;
                for (int i = 0; i < 10; i++) begin // each col
                    for (int j = 0; j < 22; j++) begin // each row
                        if (j == 0) begin
                            temp_grid[i][j] = 0; // top row is always empty
                        end else if (grid[i][j] == 1) begin
                            temp_grid[i][j] = grid[i][j]; // locked blocks stay locked
                        end else if (grid[i][j-1] >= 2) begin
                            temp_grid[i][j] = grid[i][j-1]; // active blocks should fall
                        end else begin
                            temp_grid[i][j] = 0; // everything else empty
                        end
                    end
                end
             // cant drop block any further (Collision)   
            // deactivate current block and generate new block
            end else begin
                dropItTemp = 0;
                for (int i = 0; i < 10; i++) begin // each col
                    for (int j = 0; j < 22; j++) begin // each row
                        if (grid[i][j] >= 2) begin
                            temp_grid[i][j] = 1; // active block is locked 
                        end
                    end
                end
                generateNew = 1; // generate new block
                //new_piece = 1;
            end
        end
        
        if (generateNew) begin
            // delete completed rows
            for (int j = 0; j < 22; j++) begin // iterate through every row
                temp_temp_grid = temp_grid;
                rowComplete = 1; // default
                for (int i = 0; i < 10; i++) begin
                // check every column in that row
                // if any column does not have a locked block, row is not complete
                    if (temp_temp_grid[i][j] != 1) begin
                        rowComplete = 0;
                    end
                end
                if (rowComplete) begin
                // increment score
                    scoreTracker += 1;
                    for (int k = 0; k < 10; k++) begin // for each column
                        for (int l = 0; l <= j; l++) begin // for each row up to j (above cleared row)
                            if (l == 0) begin
                                temp_grid[k][l] = 0; // Row 0 is cleared 
                            end else begin
                                // every other block gets dropped
                                // the current block gets the block above it
                                // only up to j, so above the cleared row
                                //rows below the cleared row are not affected
                                temp_grid[k][l] = temp_temp_grid[k][l-1];
                            end
                        end
                    end
                    // speed up the block fall speed after each block drop
                    // we go no faster than 5 (equal to 0.09s)
                    if (update > 5) begin
                        updateTemp = update - 1;
                    end
                end
            end
            
            scoreTemp = scoreTracker;
            
            // generate new block
            if (rand_num >= 5) begin
                randTemp = rand_num % 5;
            end else begin
                randTemp = rand_num + 1;
            end
            
            // 2x2 block (Square)
            if (randTemp == 0) begin
                temp_grid[4][0] = 2;
                temp_grid[5][0] = 2;
                temp_grid[4][1] = 2;
                temp_grid[5][1] = 2;
                tx = 4;
                ty = 0;
                rotated = 0;
            // 4x1 block (l block)
            end else if (randTemp == 1) begin
                temp_grid[3][1] = 3;
                temp_grid[4][1] = 3;
                temp_grid[5][1] = 3;
                temp_grid[6][1] = 3;
                tx = 3;
                ty = 1;
                rotated = 0;
            // s block 
            end else if (randTemp == 2) begin
                temp_grid[4][1] = 4;
                temp_grid[5][1] = 4;
                temp_grid[5][0] = 4;
                temp_grid[6][0] = 4;
                tx = 4;
                ty = 1;
                rotated = 0;
            // z block
            end else if (randTemp == 3) begin
                temp_grid[4][0] = 5;
                temp_grid[5][0] = 5;
                temp_grid[5][1] = 5;
                temp_grid[6][1] = 5;
                tx = 4;
                ty = 0;
                rotated = 0;
            // L block
            end else if (randTemp == 4) begin
                temp_grid[4][1] = 6;
                temp_grid[5][1] = 6;
                temp_grid[6][1] = 6;
                temp_grid[6][0] = 6;
                tx = 4;
                ty = 1;
                rotated = 0;
            // j block
            end else if (randTemp == 5) begin
                temp_grid[4][0] = 7;
                temp_grid[4][1] = 7;
                temp_grid[5][1] = 7;
                temp_grid[6][1] = 7;
                tx = 4;
                ty = 0;
                rotated = 0;
            //t block 
            // FPGA is too small for grid value to be 4 bits wide
               end else if (randTemp == 6) begin
                temp_grid[4][1] = 8;
                temp_grid[5][1] = 8;
                temp_grid[5][0] = 8;
                temp_grid[6][1] = 8;
                tx = 4;
                ty = 1;
                rotated = 0;
            end
        end 
        
        // keycode logic
        else if (keycode != 8'h00 && prev_keycode == 8'h00 && !alreadyMoved) begin
            // w key
            if (keycode == 8'h1A) begin
               // randTemp = rand_num + 1;
                // 4x1 block
                // grid[nx][ny] == 3 gives line block
                if (grid[nx][ny] == 3) begin
                    // rotatedTemp[0] == 0 means line block is horizontal
                    if (rotatedTemp[0] == 0) begin
                    // ny <= 0 || ny >= 20 prevents flipping into boundaries
                    // grid[nx+1][ny-1] == 1 || grid[nx+1][ny+1] == 1 || grid[nx+1][ny+2] == 1 
                    //checks new positions after flipping
                        if (ny <= 0 || ny >= 20 || grid[nx+1][ny-1] == 1 || grid[nx+1][ny+1] == 1 || grid[nx+1][ny+2] == 1) begin
                            // do nothing
                        end else begin // rotate!!
                            rotated = rotatedTemp + 1;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+2][ny] = 0;
                            temp_grid[nx+3][ny] = 0;
                            temp_grid[nx+1][ny-1] = 3;
                            temp_grid[nx+1][ny+1] = 3;
                            temp_grid[nx+1][ny+2] = 3;
                            tx = nx + 1;
                            ty = ny - 1;
                            // new pivot at grid[nx+1][ny-1]
                        end
                    end else begin
                        if (nx <= 0 || nx >= 8 || grid[nx-1][ny+1] == 1 || grid[nx+1][ny+1] == 1 || grid[nx+2][ny+1] == 1) begin
                             // do nothing
                        end else begin
                            rotated = rotatedTemp - 1;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx][ny+2] = 0;
                            temp_grid[nx][ny+3] = 0;
                            temp_grid[nx-1][ny+1] = 3;
                            temp_grid[nx+1][ny+1] = 3;
                            temp_grid[nx+2][ny+1] = 3;
                            tx = nx - 1;
                            ty = ny + 1;
                            // new pivot at grid[nx-1][ny+1] (Original)
                        end
                    end
                end
                        
                // s block
                else if (grid[nx][ny] == 4) begin
                    if (rotatedTemp[0] == 0) begin
                        if (ny >= 21 || grid[nx][ny-1] == 1 || grid[nx+1][ny+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx+1][ny-1] = 0;
                            temp_grid[nx+2][ny-1] = 0;
                            temp_grid[nx][ny-1] = 4;
                            temp_grid[nx+1][ny+1] = 4;
                            tx = nx;
                            ty = ny - 1;
                        end
                    end else begin
                        if (nx >= 8 || grid[nx+1][ny-1] == 1 || grid[nx+2][ny-1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp - 1;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+1][ny+2] = 0;
                            temp_grid[nx+1][ny] = 4;
                            temp_grid[nx+2][ny] = 4;
                            tx = nx;
                            ty = ny + 1;
                        end
                    end
                end
                
                // z block
                else if (grid[nx][ny] == 5) begin
                    if (rotatedTemp[0] == 0) begin
                        if (ny >= 21 || grid[nx+2][ny] == 1 || grid[nx+1][ny+2] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+1][ny] = 0;
                            temp_grid[nx+2][ny] = 5;
                            temp_grid[nx+1][ny+2] = 5;
                            tx = nx + 1;
                            ty = ny + 1;
                        end
                    end else begin
                        if (nx <= 0 || grid[nx-1][ny-1] == 1 || grid[nx][ny-1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp - 1;
                            temp_grid[nx][ny+1] = 0;
                            temp_grid[nx+1][ny-1] = 0;
                            temp_grid[nx-1][ny-1] = 5;
                            temp_grid[nx][ny-1] = 5;
                            tx = nx - 1;
                            ty = ny - 1;
                        end
                    end
                end
                
                // l block   
                else if (grid[nx][ny] == 6) begin
                    if (rotatedTemp == 0) begin
                        if (ny >= 21 || grid[nx+1][ny-1] == 1 || grid[nx+1][ny+1] == 1 || grid[nx+2][ny+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx+1][ny-1] = 6;
                            temp_grid[nx+1][ny+1] = 6;
                            temp_grid[nx+2][ny+1] = 6;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+2][ny] = 0;
                            temp_grid[nx+2][ny-1] = 0;
                            tx = nx + 1;
                            ty = ny - 1;
                        end
                    end else if (rotatedTemp == 1) begin
                        if (nx <= 0 || grid[nx-1][ny+1] == 1 || grid[nx-1][ny+2] == 1 || grid[nx+1][ny+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx-1][ny+1] = 6;
                            temp_grid[nx-1][ny+2] = 6;
                            temp_grid[nx+1][ny+1] = 6;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx][ny+2] = 0;
                            temp_grid[nx+1][ny+2] = 0;
                            tx = nx - 1;
                            ty = ny + 1;
                        end
                    end else if (rotatedTemp == 2) begin
                        if (ny <= 0 || grid[nx][ny-1] == 1 || grid[nx+1][ny-1] == 1 || grid[nx+1][ny+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx][ny-1] = 6;
                            temp_grid[nx+1][ny-1] = 6;
                            temp_grid[nx+1][ny+1] = 6;
                            temp_grid[nx][ny+1] = 0;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+2][ny] = 0;
                            tx = nx;
                            ty = ny - 1;
                        end
                    end else begin
                        if (nx >= 8 || grid[nx+2][ny] == 1 || grid[nx+2][ny+1] == 1 || grid[nx][ny+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp - 3;
                            temp_grid[nx+2][ny] = 6;
                            temp_grid[nx+2][ny+1] = 6;
                            temp_grid[nx][ny+1] = 6;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+1][ny] = 0;
                            temp_grid[nx+1][ny+2] = 0;
                            tx = nx;
                            ty = ny + 1;
                        end
                    end
                end
                
                // j block
                else if (grid[nx][ny] == 7) begin
                    if (rotatedTemp == 0) begin
                        if (ny >= 20 || grid[nx+1][ny] == 1 || grid[nx+2][ny] == 1 || grid[nx+1][ny+2] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx+1][ny] = 7;
                            temp_grid[nx+2][ny] = 7;
                            temp_grid[nx+1][ny+2] = 7;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx][ny+1] = 0;
                            temp_grid[nx+2][ny+1] = 0;
                            tx = nx + 1;
                            ty = ny;
                        end
                    end else if (rotatedTemp == 1) begin
                        if (nx <= 0 || grid[nx-1][ny+1] == 1 || grid[nx+1][ny+1] == 1 || grid[nx+1][ny+2] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx-1][ny+1] = 7;
                            temp_grid[nx+1][ny+1] = 7;
                            temp_grid[nx+1][ny+2] = 7;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+1][ny] = 0;
                            temp_grid[nx][ny+2] = 0;
                            tx = nx - 1;
                            ty = ny + 1;
                        end
                    end else if (rotatedTemp == 2) begin
                        if (ny <= 0 || grid[nx][ny+1] == 1 || grid[nx+1][ny+1] == 1 || grid[nx+1][ny-1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx][ny+1] = 7;
                            temp_grid[nx+1][ny+1] = 7;
                            temp_grid[nx+1][ny-1] = 7;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+2][ny] = 0;
                            temp_grid[nx+2][ny+1] = 0;
                            tx = nx;
                            ty = ny + 1;
                        end
                    end else begin
                        if (nx >= 8 || grid[nx][ny-1] == 1 || grid[nx][ny-2] == 1 || grid[nx+2][ny-1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp - 3;
                            temp_grid[nx][ny-1] = 7;
                            temp_grid[nx][ny-2] = 7;
                            temp_grid[nx+2][ny-1] = 7;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+1][ny] = 0;
                            temp_grid[nx+1][ny-2] = 0;
                            tx = nx;
                            ty = ny - 2;
                        end
                    end 
                end
                
                // t block
                else if (grid[nx][ny] == 8) begin
                    if (rotatedTemp == 0) begin
                        if (ny >= 21 || grid[nx+2][ny+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+2][ny] = 0;
                            temp_grid[nx+2][ny+1] = 8;
                            temp_grid[nx+1][ny+2] = 8;
                            tx = nx + 1;
                            ty = ny + 2;
                        end
                    end else if (rotatedTemp == 1) begin
                        if (nx <= 0 || grid[nx-1][ny+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx-1][ny-1] = 8;
                            tx = nx + 1;
                            ty = ny - 1;
                        end
                    end else if (rotatedTemp == 2) begin
                        if (ny <= 0 || grid[nx][ny-2] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx+1][ny+1] = 0;
                            temp_grid[nx][ny+2] = 8;
                            tx = nx - 1;
                            ty = ny + 1;
                        end
                    end else begin
                        if (nx >= 8 || grid[nx+1][ny+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp -3;
                            temp_grid[nx+1][ny-1] = 0;
                            temp_grid[nx+2][ny] = 8;
                            tx = nx + 1;
                            ty = ny + 1;
                        end
                    end
                end
                // end of t
                
            // a key
            end else if (keycode == 8'h04) begin
                randTemp = rand_num + 1;
                validToMove = 1;
                for (int i = 0; i < 10; i++) begin
                    for (int j = 0; j < 22; j++) begin
                        if (grid[i][j] >= 2) begin
                            if (i-1 < 0) begin
                                validToMove = 0;
                            end else if (grid[i-1][j] != 0 && grid[i-1][j] != grid[i][j]) begin
                                validToMove = 0;
                            end
                        end
                    end
                end
                
                if (validToMove) begin
                    tx = nx - 1;
                    for (int i = 0; i < 10; i++) begin
                        for (int j = 0; j < 22; j++) begin
                            if (grid[i][j] == 1) begin
                                temp_grid[i][j] = 1;
                            end else if (i < 9 && grid[i+1][j] >= 2) begin
                                temp_grid[i][j] = grid[i+1][j];
                            end else begin
                                temp_grid[i][j] = 0;
                            end
                        end
                    end
                end
                
            // s key
            end else if (keycode == 8'h16) begin
                dropItTemp = 1;
                randTemp = rand_num + 4;
            // d key
            end else if (keycode == 8'h07) begin
                randTemp = rand_num + 3;
                validToMove = 1;
                for (int i = 0; i < 10; i++) begin
                    for (int j = 0; j < 22; j++) begin
                        if (grid[i][j] >= 2) begin
                            if (i+1 >= 10) begin
                                validToMove = 0;
                            end else if (grid[i+1][j] != 0 && grid[i+1][j] != grid[i][j]) begin
                                validToMove = 0;
                            end
                        end
                    end
                end
                
                if (validToMove) begin
                    tx = nx + 1;
                    for (int i = 0; i < 10; i++) begin
                        for (int j = 0; j < 22; j++) begin
                            if (grid[i][j] == 1) begin
                                temp_grid[i][j] = 1;
                            end else if (i >= 1 && grid[i-1][j] >= 2) begin
                                temp_grid[i][j] = grid[i-1][j];
                            end else begin
                                temp_grid[i][j] = 0;
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
            // set grid to empty
           
           // for (int i = 0; i < 10; i++) begin
             //   for (int j = 0; j < 22; j++) begin
             //       temp_temp_grid[i][j]  <= 0;
              //      temp_grid[i][j] <= 0;
              //      grid[i][j] <= 0;
              //  end
            //end 
            
            //temp_temp_grid <= '{default:'0};
            //temp_grid <= '{default:'0};
            grid <= '{default:'0};            
            
            // set variables
            prev_keycode <= 8'h00;
            timer <= 0;
            alreadyMoved <= 0;
            rand_num <= 5;
            validToDrop <= 1;
            blankBoard <= 1;
            score <= 0;
            update <= 30;
            rotatedTemp <= 0;
            dropIt <= 0;
        end 
        else begin
            // update variables
            grid <= temp_grid;
            rand_num <= randTemp;
            validToDrop <= validToDropTemp;
            blankBoard <= blankBoardTemp;
            nx <= tx;
            ny <= ty;
            rotatedTemp <= rotated;
            score <= scoreTemp;
            update <= updateTemp;
            dropIt <= dropItTemp;
            
            // update more variables
            prev_keycode <= keycode;
            
            timer <= timer + 1;
            if (timer > update) begin
                timer <= 0;
            end
        end
    end
      
endmodule

/* old one
module  ball 
( 
    input  logic        Reset, 
    input  logic        frame_clk,
    input  logic [7:0]  keycode,

    output logic [9:0] score,
    output logic [2:0] grid[10][22]
);
	 
    logic [7:0] prev_keycode;
    // timer used to count blocks time
    // if timer = update then block moves down a row
    // !!! RENAME TIMER TO DROP_COUNTER
    logic [4:0] timer;
    // update used as the block speed
    // !!! RENAME UPDATE TO DROP_INTERVAL
    logic [4:0] update, updateTemp;
        
    logic [2:0] rotateTimer;
    // temp_grid calculates the next grid
    logic [2:0] temp_grid[10][22];
    //temp temp used for drop logic
    // !!! RENAME TO DROP GRID
    logic [2:0] temp_temp_grid[10][22];
    // logic [2:0] prev_grid[10][22];
    
    // Used to start the game
    logic blankBoard, blankBoardTemp;
        
    // Completed row variable
    logic rowComplete;    
    
    // Can we drop???    
    logic validToDrop, validToDropTemp;
    logic validToMove;

    // random number
    logic [2:0] rand_num, randTemp;
    logic [1:0] rotated, rotatedTemp;
    
    // generateNew signals the creation of a new block
    logic generateNew;
    
    // values used for rotations
    // ny and nx = current row and curr col pivots
    // tx and ty are next row and col
    logic [4:0] nx, ny, tx, ty;
    
    // alreadyMoved keeps user from moving and rotating at the same time
    // !!! CHANGE NAME
    logic alreadyMoved;
    
    logic [9:0] scoreTemp, scoreTracker;
    logic dropIt, dropItTemp;


    always_comb begin
        
        // update variables
        temp_grid = grid;
        randTemp = rand_num;
        blankBoardTemp = blankBoard;
        rotated = rotatedTemp;
        scoreTemp = score;
        scoreTracker = score;
        updateTemp = update;
        generateNew = 0;
        alreadyMoved = 0;
        tx = nx;
        ty = ny;
        dropItTemp = dropIt;

        if (blankBoard) begin
            generateNew = 1;
            blankBoardTemp = 0;
        end
                
        // check if okay to drop
        validToDropTemp = 1;
        for (int i = 0; i < 10; i++) begin
            for (int j = 0; j < 22; j++) begin
                if (grid[i][j] >= 2) begin // Only current tetris blocks (empty=0 or locked=1) are ignored
                    if (j >= 21) begin // bottom of playfield
                        validToDropTemp = 0;
                    end else if (grid[i][j+1] != 0 && grid[i][j+1] != grid[i][j]) begin
                    // grid[i][j+1] != 0 checks if something is at the next row
                    // grid[i][j+1] != grid[i][j] checks if that something is NOT part of the current block
                        validToDropTemp = 0;
                    end
                end
            end
        end
        
        
        // time cycle: update
        // timer == update indicates the time is ready for block to drop
        // dropIt drops the block when 's' is pressed
        if (timer == update || dropIt) begin
            // drop logic
            if (validToDropTemp) begin
                alreadyMoved = 1;
                ty = ny + 1;
                for (int i = 0; i < 10; i++) begin // each col
                    for (int j = 0; j < 22; j++) begin // each row
                        if (j == 0) begin
                            temp_grid[i][j] = 0; // top row is always empty
                        end else if (grid[i][j] == 1) begin
                            temp_grid[i][j] = grid[i][j]; // locked blocks stay locked
                        end else if (grid[i][j-1] >= 2) begin
                            temp_grid[i][j] = grid[i][j-1]; // active blocks should fall
                        end else begin
                            temp_grid[i][j] = 0; // everything else empty
                        end
                    end
                end
             // cant drop block any further (Collision)   
            // deactivate current block and generate new block
            end else begin
                dropItTemp = 0;
                for (int i = 0; i < 10; i++) begin // each col
                    for (int j = 0; j < 22; j++) begin // each row
                        if (grid[i][j] >= 2) begin
                            temp_grid[i][j] = 1; // active block is locked 
                        end
                    end
                end
                generateNew = 1; // generate new block
            end
        end
        
        if (generateNew) begin
            // delete completed rows
            for (int j = 0; j < 22; j++) begin // iterate through every row
                temp_temp_grid = temp_grid;
                rowComplete = 1; // default
                for (int i = 0; i < 10; i++) begin
                // check every column in that row
                // if any column does not have a locked block, row is not complete
                    if (temp_temp_grid[i][j] != 1) begin
                        rowComplete = 0;
                    end
                end
                if (rowComplete) begin
                // increment score
                    scoreTracker += 1;
                    for (int k = 0; k < 10; k++) begin // for each column
                        for (int l = 0; l <= j; l++) begin // for each row up to j (above cleared row)
                            if (l == 0) begin
                                temp_grid[k][l] = 0; // Row 0 is cleared 
                            end else begin
                                // every other block gets dropped
                                // the current block gets the block above it
                                // only up to j, so above the cleared row
                                //rows below the cleared row are not affected
                                temp_grid[k][l] = temp_temp_grid[k][l-1];
                            end
                        end
                    end
                    // speed up the block fall speed after each block drop
                    // we go no faster than 5 (equal to 0.09s)
                    if (update > 5) begin
                        updateTemp = update - 1;
                    end
                end
            end
            
            scoreTemp = scoreTracker;
            
            // generate new block
            if (rand_num >= 5) begin
                randTemp = rand_num % 5;
            end else begin
                randTemp = rand_num + 1;
            end
            
            // 2x2 block (Square)
            if (randTemp == 0) begin
                temp_grid[4][0] = 2;
                temp_grid[5][0] = 2;
                temp_grid[4][1] = 2;
                temp_grid[5][1] = 2;
                tx = 4;
                ty = 0;
                rotated = 0;
            // 4x1 block (l block)
            end else if (randTemp == 1) begin
                temp_grid[3][1] = 3;
                temp_grid[4][1] = 3;
                temp_grid[5][1] = 3;
                temp_grid[6][1] = 3;
                tx = 3;
                ty = 1;
                rotated = 0;
            // s block 
            end else if (randTemp == 2) begin
                temp_grid[4][1] = 4;
                temp_grid[5][1] = 4;
                temp_grid[5][0] = 4;
                temp_grid[6][0] = 4;
                tx = 4;
                ty = 1;
                rotated = 0;
            // z block
            end else if (randTemp == 3) begin
                temp_grid[4][0] = 5;
                temp_grid[5][0] = 5;
                temp_grid[5][1] = 5;
                temp_grid[6][1] = 5;
                tx = 4;
                ty = 0;
                rotated = 0;
            // L block
            end else if (randTemp == 4) begin
                temp_grid[4][1] = 6;
                temp_grid[5][1] = 6;
                temp_grid[6][1] = 6;
                temp_grid[6][0] = 6;
                tx = 4;
                ty = 1;
                rotated = 0;
            // j block
            end else if (randTemp == 5) begin
                temp_grid[4][0] = 7;
                temp_grid[4][1] = 7;
                temp_grid[5][1] = 7;
                temp_grid[6][1] = 7;
                tx = 4;
                ty = 0;
                rotated = 0;
            //t block
               end else if (randTemp == 6) begin
                temp_grid[4][1] = 8;
                temp_grid[5][1] = 8;
                temp_grid[5][0] = 8;
                temp_grid[6][1] = 8;
                tx = 4;
                ty = 1;
                rotated = 0;
            end
        end
        
        // keycode logic
        else if (keycode != 8'h00 && prev_keycode == 8'h00 && !alreadyMoved) begin
            // w key
            if (keycode == 8'h1A) begin
                randTemp = rand_num + 1;
                // 4x1 block
                if (grid[nx][ny] == 3) begin
                    if (rotatedTemp[0] == 0) begin
                        if (ny <= 0 || ny >= 20 || grid[nx+1][ny-1] == 1 || grid[nx+1][ny+1] == 1 || grid[nx+1][ny+2] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+2][ny] = 0;
                            temp_grid[nx+3][ny] = 0;
                            temp_grid[nx+1][ny-1] = 3;
                            temp_grid[nx+1][ny+1] = 3;
                            temp_grid[nx+1][ny+2] = 3;
                            tx = nx + 1;
                            ty = ny - 1;
                        end
                    end else begin
                        if (nx <= 0 || nx >= 8 || grid[nx-1][ny+1] == 1 || grid[nx+1][ny+1] == 1 || grid[nx+2][ny+1] == 1) begin
                             // do nothing
                        end else begin
                            rotated = rotatedTemp - 1;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx][ny+2] = 0;
                            temp_grid[nx][ny+3] = 0;
                            temp_grid[nx-1][ny+1] = 3;
                            temp_grid[nx+1][ny+1] = 3;
                            temp_grid[nx+2][ny+1] = 3;
                            tx = nx - 1;
                            ty = ny + 1;
                        end
                    end
                end
                        
                // s block
                else if (grid[nx][ny] == 4) begin
                    if (rotatedTemp[0] == 0) begin
                        if (ny >= 21 || grid[nx][ny-1] == 1 || grid[nx+1][ny+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx+1][ny-1] = 0;
                            temp_grid[nx+2][ny-1] = 0;
                            temp_grid[nx][ny-1] = 4;
                            temp_grid[nx+1][ny+1] = 4;
                            tx = nx;
                            ty = ny - 1;
                        end
                    end else begin
                        if (nx >= 8 || grid[nx+1][ny-1] == 1 || grid[nx+2][ny-1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp - 1;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+1][ny+2] = 0;
                            temp_grid[nx+1][ny] = 4;
                            temp_grid[nx+2][ny] = 4;
                            tx = nx;
                            ty = ny + 1;
                        end
                    end
                end
                
                // z block
                else if (grid[nx][ny] == 5) begin
                    if (rotatedTemp[0] == 0) begin
                        if (ny >= 21 || grid[nx+2][ny] == 1 || grid[nx+1][ny+2] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+1][ny] = 0;
                            temp_grid[nx+2][ny] = 5;
                            temp_grid[nx+1][ny+2] = 5;
                            tx = nx + 1;
                            ty = ny + 1;
                        end
                    end else begin
                        if (nx <= 0 || grid[nx-1][ny-1] == 1 || grid[nx][ny-1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp - 1;
                            temp_grid[nx][ny+1] = 0;
                            temp_grid[nx+1][ny-1] = 0;
                            temp_grid[nx-1][ny-1] = 5;
                            temp_grid[nx][ny-1] = 5;
                            tx = nx - 1;
                            ty = ny - 1;
                        end
                    end
                end
                
                // l block   
                else if (grid[nx][ny] == 6) begin
                    if (rotatedTemp == 0) begin
                        if (ny >= 21 || grid[nx+1][ny-1] == 1 || grid[nx+1][ny+1] == 1 || grid[nx+2][ny+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx+1][ny-1] = 6;
                            temp_grid[nx+1][ny+1] = 6;
                            temp_grid[nx+2][ny+1] = 6;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+2][ny] = 0;
                            temp_grid[nx+2][ny-1] = 0;
                            tx = nx + 1;
                            ty = ny - 1;
                        end
                    end else if (rotatedTemp == 1) begin
                        if (nx <= 0 || grid[nx-1][ny+1] == 1 || grid[nx-1][ny+2] == 1 || grid[nx+1][ny+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx-1][ny+1] = 6;
                            temp_grid[nx-1][ny+2] = 6;
                            temp_grid[nx+1][ny+1] = 6;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx][ny+2] = 0;
                            temp_grid[nx+1][ny+2] = 0;
                            tx = nx - 1;
                            ty = ny + 1;
                        end
                    end else if (rotatedTemp == 2) begin
                        if (ny <= 0 || grid[nx][ny-1] == 1 || grid[nx+1][ny-1] == 1 || grid[nx+1][ny+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx][ny-1] = 6;
                            temp_grid[nx+1][ny-1] = 6;
                            temp_grid[nx+1][ny+1] = 6;
                            temp_grid[nx][ny+1] = 0;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+2][ny] = 0;
                            tx = nx;
                            ty = ny - 1;
                        end
                    end else begin
                        if (nx >= 8 || grid[nx+2][ny] == 1 || grid[nx+2][ny+1] == 1 || grid[nx][ny+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp - 3;
                            temp_grid[nx+2][ny] = 6;
                            temp_grid[nx+2][ny+1] = 6;
                            temp_grid[nx][ny+1] = 6;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+1][ny] = 0;
                            temp_grid[nx+1][ny+2] = 0;
                            tx = nx;
                            ty = ny + 1;
                        end
                    end
                end
                
                // j block
                else if (grid[nx][ny] == 7) begin
                    if (rotatedTemp == 0) begin
                        if (ny >= 20 || grid[nx+1][ny] == 1 || grid[nx+2][ny] == 1 || grid[nx+1][ny+2] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx+1][ny] = 7;
                            temp_grid[nx+2][ny] = 7;
                            temp_grid[nx+1][ny+2] = 7;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx][ny+1] = 0;
                            temp_grid[nx+2][ny+1] = 0;
                            tx = nx + 1;
                            ty = ny;
                        end
                    end else if (rotatedTemp == 1) begin
                        if (nx <= 0 || grid[nx-1][ny+1] == 1 || grid[nx+1][ny+1] == 1 || grid[nx+1][ny+2] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx-1][ny+1] = 7;
                            temp_grid[nx+1][ny+1] = 7;
                            temp_grid[nx+1][ny+2] = 7;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+1][ny] = 0;
                            temp_grid[nx][ny+2] = 0;
                            tx = nx - 1;
                            ty = ny + 1;
                        end
                    end else if (rotatedTemp == 2) begin
                        if (ny <= 0 || grid[nx][ny+1] == 1 || grid[nx+1][ny+1] == 1 || grid[nx+1][ny-1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp + 1;
                            temp_grid[nx][ny+1] = 7;
                            temp_grid[nx+1][ny+1] = 7;
                            temp_grid[nx+1][ny-1] = 7;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+2][ny] = 0;
                            temp_grid[nx+2][ny+1] = 0;
                            tx = nx;
                            ty = ny + 1;
                        end
                    end else begin
                        if (nx >= 8 || grid[nx][ny-1] == 1 || grid[nx][ny-2] == 1 || grid[nx+2][ny-1] == 1) begin
                            // do nothing
                        end else begin
                            rotated = rotatedTemp - 3;
                            temp_grid[nx][ny-1] = 7;
                            temp_grid[nx][ny-2] = 7;
                            temp_grid[nx+2][ny-1] = 7;
                            temp_grid[nx][ny] = 0;
                            temp_grid[nx+1][ny] = 0;
                            temp_grid[nx+1][ny-2] = 0;
                            tx = nx;
                            ty = ny - 2;
                        end
                    end 
                end
                
                // t block
                else if (grid[nx][ny] == 8) begin
                    if (rotated == 0) begin
                        if (ny >= 21 || grid[nx+1][ny+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated += 1;
                            temp_grid[nx+1][ny+1] = 8;
                            temp_grid[nx][ny] = 0;
                        end
                    end else if (rotated == 1) begin
                        if (nx <= 0 || grid[nx-1][ny+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated += 1;
                            temp_grid[nx-1][ny+1] = 8;
                            temp_grid[nx][ny] = 0;
                        end
                    end else if (rotated == 2) begin
                        if (ny <= 0 || grid[nx+1][ny-1] == 1) begin
                            // do nothing
                        end else begin
                            rotated += 1;
                            temp_grid[nx+1][ny-1] = 8;
                            temp_grid[nx+2][ny] = 0;
                        end
                    end else begin
                        if (nx >= 8 || grid[nx+1][ny+1] == 1) begin
                            // do nothing
                        end else begin
                            rotated -= 3;
                            temp_grid[nx+2][ny] = 8;
                            temp_grid[nx+1][ny+1] = 0;
                        end
                    end
                end
                // end of t
                
            // a key
            end else if (keycode == 8'h04) begin
                randTemp = rand_num + 2;
                validToMove = 1;
                for (int i = 0; i < 10; i++) begin
                    for (int j = 0; j < 22; j++) begin
                        if (grid[i][j] >= 2) begin
                            if (i-1 < 0) begin
                                validToMove = 0;
                            end else if (grid[i-1][j] != 0 && grid[i-1][j] != grid[i][j]) begin
                                validToMove = 0;
                            end
                        end
                    end
                end
                
                if (validToMove) begin
                    tx = nx - 1;
                    for (int i = 0; i < 10; i++) begin
                        for (int j = 0; j < 22; j++) begin
                            if (grid[i][j] == 1) begin
                                temp_grid[i][j] = 1;
                            end else if (i < 9 && grid[i+1][j] >= 2) begin
                                temp_grid[i][j] = grid[i+1][j];
                            end else begin
                                temp_grid[i][j] = 0;
                            end
                        end
                    end
                end
                
            // s key
            end else if (keycode == 8'h16) begin
                dropItTemp = 1;
                
            // d key
            end else if (keycode == 8'h07) begin
                randTemp = rand_num + 3;
                validToMove = 1;
                for (int i = 0; i < 10; i++) begin
                    for (int j = 0; j < 22; j++) begin
                        if (grid[i][j] >= 2) begin
                            if (i+1 >= 10) begin
                                validToMove = 0;
                            end else if (grid[i+1][j] != 0 && grid[i+1][j] != grid[i][j]) begin
                                validToMove = 0;
                            end
                        end
                    end
                end
                
                if (validToMove) begin
                    tx = nx + 1;
                    for (int i = 0; i < 10; i++) begin
                        for (int j = 0; j < 22; j++) begin
                            if (grid[i][j] == 1) begin
                                temp_grid[i][j] = 1;
                            end else if (i >= 1 && grid[i-1][j] >= 2) begin
                                temp_grid[i][j] = grid[i-1][j];
                            end else begin
                                temp_grid[i][j] = 0;
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
            // set grid to empty
           
           // for (int i = 0; i < 10; i++) begin
             //   for (int j = 0; j < 22; j++) begin
             //       temp_temp_grid[i][j]  <= 0;
              //      temp_grid[i][j] <= 0;
              //      grid[i][j] <= 0;
              //  end
            //end 
            
            //temp_temp_grid <= '{default:'0};
            //temp_grid <= '{default:'0};
            grid <= '{default:'0};            
            
            // set variables
            prev_keycode <= 8'h00;
            timer <= 0;
            rotateTimer <= 0;
            
            rand_num <= 5;
            validToDrop <= 1;
            blankBoard <= 1;
            score <= 0;
            update <= 30;
            rotatedTemp <= 0;
            dropIt <= 0;
        end 
        else begin
            // update variables
            grid <= temp_grid;
            rand_num <= randTemp;
            validToDrop <= validToDropTemp;
            blankBoard <= blankBoardTemp;
            nx <= tx;
            ny <= ty;
            rotatedTemp <= rotated;
            score <= scoreTemp;
            update <= updateTemp;
            dropIt <= dropItTemp;
            
            // update more variables
            prev_keycode <= keycode;
            
            timer <= timer + 1;
            if (timer > update) begin
                timer <= 0;
            end
        end
    end
      
endmodule
*/