//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    John Youkhana                                                    --
//    05-07-2025                                                             --
//                                                                       --
//                                                                       --
//                                                                       --
//    For use with ECE 385 USB + HDMI                                    --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( // "Lines cleared"
                       input  logic [6:0] text[13],
                       // "Welcome to Tetris"
                       input  logic [6:0] welcometext[17],
                       // "Game Over"
                       input  logic [6:0] gameover_text[8],
                       // 10x20 Grid tetris play area
                       input  logic [2:0] grid[10][22],
                       //Current pixel position
                       input  logic [9:0] DrawX, DrawY,
                       // Score "XXX"
                       input  logic [9:0] score,
                       // Indicator of game over condition
                       input  logic gameover_indicator,
                       // RGB Values
                       output logic [3:0]  Red, Green, Blue );
    // ball_on high if pixel inside playing field
    // font_on
    logic ball_on, font_on;
    //addr: 11 bit address into font rom
    //addrt: temp variable
	logic [10:0] addr, addrt;
	//8-bit data from font rom
	logic [7:0] data;
	// High when drawing Welcome to tetris text
    logic        welcome_on;
    // temp variable for welcome 
    logic [10:0] welcome_addr;
    int row, idx, bit_idx;
always_comb begin
      // Top “WELCOME TO ”  (Y=224–239, X=68–155)
      // Bottom “TETRIS”   (Y=240–255, X=90–137)
      // DrawY >= 224 && DrawY < 256 checks if we are in row 14 or 15
      // 
      welcome_on = (DrawY >= 224 && DrawY < 256) &&
                   ( (DrawY < 240 && DrawX >= 68 && DrawX < (68 + 11*8)) ||  // 11 chars “WELCOME TO”
                     (DrawY >= 240 && DrawX >= 90 && DrawX < (90 + 6*8)) );      //  6 chars “TETRIS”
    
      if (welcome_on) begin
        // pick which letter:
        //   if on first line, index = (DrawX - 68) /8 ? 0…10
        //   if on second, index = 11 + (DrawX/8) ? 11…16
        if (DrawY < 240) begin
            idx = ((DrawX - 68) >> 3); //characters 0 through 10
            row = DrawY - 224; // zero index Y
        end else begin
            idx = 11 + ((DrawX - 90) >> 3); // characters 11 through 16
            row = DrawY - 240;
        end
        //idx = (DrawY < 240)
         //       ? (DrawX >> 3)
          //      : (11 + (DrawX >> 3));
    
        // row within the glyph:
        //row = DrawY - (DrawY < 240 ? 224 : 240);
        
        // Address calculation << 4 = x 16
        welcome_addr = (welcometext[idx] << 4) + row;
      end else begin
        welcome_addr = 0;
      end
end
  
	always_comb begin
	//LINES CLEARED banner from y = 224 - 240
    if (DrawY >= 224 && DrawY < 240) begin
        // "LINES CLEARED" banner, x=468 - 579
        addrt = ((text[(DrawX - 468) >> 3]) << 4) + (DrawY - 224);
    end else begin
        // Hundreds bit
        if (DrawX >= 508 && DrawX < 516) begin
            addrt = ((8'h30 + (score / 100) % 10) << 4) + (DrawY - 240);
        end else if (DrawX >= 516 && DrawX < 524) begin
       // tens bit
            addrt = ((8'h30 + ((score / 10) % 10)) << 4) + (DrawY - 240);
        end else begin
       // ones bit
            addrt = ((8'h30 + (score % 10)) << 4) + (DrawY - 240);
        end
    end
    
    end
    
    
    always_comb begin
    // If welcome bit is high, use welcome address
      addr = (welcome_on ? welcome_addr : addrt);
    end    
    
    font_rom font_rom(.addr(addr), .data(data));
    
    
    always_comb
    begin:Ball_on_proc
        // Check to see if current pixel is within play area
        if (DrawX >= 240 && DrawX < 400 && DrawY >= 80 && DrawY < 400)
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
    end 
     
    always_comb
     begin:font
        // choose bit index based on which text region
        //bit_idx = welcome_on
        //            ? (DrawX        & 7)       // left side
        //            : ((DrawX-468) & 7);       // right side
        bit_idx = welcome_on
              ? ( (DrawY<240 ? (DrawX - 68) : (DrawX - 90)) & 7)       // left side
              : ((DrawX-468) & 7);       // right side
        if (data[7 - bit_idx] == 1)
             font_on = 1'b1;
         else
             font_on = 1'b0;
     end
       
       
always_comb begin: RGB_Display
    if (ball_on) begin
        // playfield coloring
        //block coloring inspired by Jstris
        // Each grid is 16 pixels wide, bc it is 160 pixels wide, and tetris is usually 10 grids wide
        // each grid is 16 pixels tall, bc its 320 pixels tall, and tetris is uaully 10 pixels tall
        // add 2 to drawY / 16 bc first two rows are hidden, spawn rows
        if (grid[(DrawX-240)>>4][((DrawY-80)>>4)+2] == 1) begin
            // settled blocks (Gray)
            Red = 4'h7; 
            Green = 4'h7; 
            Blue = 4'h7;
        end else if (grid[(DrawX-240)>>4][((DrawY-80)>>4)+2] == 2) begin
            // square block (change to yellow)
            Red = 4'hf; 
            Green = 4'hf; 
            Blue = 4'h0;
        end else if (grid[(DrawX-240)>>4][((DrawY-80)>>4)+2] == 3) begin
            // | block (change to light blue)
            Red = 4'h0; 
            Green = 4'h7; 
            Blue = 4'hf;
        end else if (grid[(DrawX-240)>>4][((DrawY-80)>>4)+2] == 4) begin
            // S block (change to green)
            Red = 4'h0; 
            Green = 4'hf; 
            Blue = 4'h0;
        end else if (grid[(DrawX-240)>>4][((DrawY-80)>>4)+2] == 5) begin
            // Z block (change to red)
            Red = 4'ha; 
            Green = 4'h0; 
            Blue = 4'h0;
        end else if (grid[(DrawX-240)>>4][((DrawY-80)>>4)+2] == 6) begin
            // L block (Change to Orange)
            Red = 4'hf; 
            Green = 4'h7; 
            Blue = 4'h0;
        end else if (grid[(DrawX-240)>>4][((DrawY-80)>>4)+2] == 7) begin
            // J block (Change to dark blue)
            Red = 4'h0; 
            Green = 4'h0; 
            Blue = 4'hf;
        end else if (grid[(DrawX-240)>>4][((DrawY-80)>>4)+2] == 8) begin
            // T block (change to light purple)
            Red = 4'hd; 
            Green = 4'h4; 
            Blue = 4'hd;    
        end else begin
            // empty black playfield
            Red = 4'h0; 
            Green = 4'h0; 
            Blue = 4'h0;
        end
        
    end else begin
        // Welcome to tetris sign printed in white
        if (welcome_on && font_on) begin
            Red = 4'hf; 
            Green = 4'hf; 
            Blue = 4'hf;
        end
        // line cleared sign printed in white
        else if (DrawX >= 468 && DrawX < 572 &&
                 DrawY >= 224 && DrawY < 240 && font_on) begin
            Red = 4'hf; 
            Green = 4'hf; 
            Blue = 4'hf;
        end
        // score text printed in white
        else if (DrawX >= 508 && DrawX < 532 &&
                 DrawY >= 240 && DrawY < 256 && font_on) begin
            Red = 4'hf; 
            Green = 4'hf; 
            Blue = 4'hf;
        end
        //  white border??
        else if ( (DrawX < 240 && DrawX >= 236 && DrawY >= 76 && DrawY < 404) || 
                (DrawX >= 400 && DrawX < 404 && DrawY >= 80 && DrawY < 404) ||
                 (DrawY < 80 && DrawY >= 76 && DrawX >= 240 && DrawX < 404) || 
                 (DrawY >= 400 && DrawY < 404 && DrawX >= 240 && DrawX < 404) ) begin
            Red = 4'hf; 
            Green = 4'hf; 
            Blue = 4'hf;
        end    
        // Playfield background
        else if (DrawX < 236 || DrawX >= 404 ||
                 DrawY < 76  || DrawY >= 404) begin
            Red = 4'h4; 
            Green = 4'h4; 
            Blue = 4'h4;
        end 
        /*
        // Playfield background
        else if (DrawX < 240 || DrawX >= 400 ||
                 DrawY < 80  || DrawY >= 400) begin
            Red = 4'h4; 
            Green = 4'h4; 
            Blue = 4'h4;
        end */
        // Default case
        else begin
            Red   = 4'h0; Green = 4'h0; Blue = 4'h0;
        end
    end
end
        
endmodule
