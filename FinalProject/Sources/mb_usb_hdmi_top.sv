//-------------------------------------------------------------------------
//    mb_usb_hdmi_top.sv                                                 --
//    Zuofu Cheng                                                        --
//    2-29-24                                                            --
//                                                                       --
//                                                                       --
//    Spring 2024 Distribution                                           --
//                                                                       --
//    For use with ECE 385 USB + HDMI                                    --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module mb_usb_hdmi_top(
    input logic Clk,
    input logic reset_rtl_0,
    
    //USB signals
    input logic [0:0] gpio_usb_int_tri_i,
    output logic gpio_usb_rst_tri_o,
    input logic usb_spi_miso,
    output logic usb_spi_mosi,
    output logic usb_spi_sclk,
    output logic usb_spi_ss,
    
    //UART
    input logic uart_rtl_0_rxd,
    output logic uart_rtl_0_txd,
    
    //HDMI
    output logic hdmi_tmds_clk_n,
    output logic hdmi_tmds_clk_p,
    output logic [2:0]hdmi_tmds_data_n,
    output logic [2:0]hdmi_tmds_data_p,
        
    //HEX displays
    output logic [7:0] hex_segA,
    output logic [3:0] hex_gridA,
    output logic [7:0] hex_segB,
    output logic [3:0] hex_gridB,
    
    // Audio
  output logic speaker,
  output logic speaker2
);
    
    logic [31:0] keycode0_gpio, keycode1_gpio;
    logic clk_25MHz, clk_125MHz, clk, clk_100MHz;
    logic locked;
    logic [9:0] drawX, drawY, ballxsig, ballysig, ballsizesig;

    logic hsync, vsync, vde;
    logic [3:0] red, green, blue;
    logic reset_ah;
    
    assign reset_ah = reset_rtl_0;
    logic [2:0] block_grid[10][22];
    logic [9:0] score;
    // LOGIC FOR PRINTING SIGNS
    logic [6:0] text[13];
    logic [6:0] welcometext[17];
    logic [6:0] gameover_text[8];
    logic gameover_indicator;
    
    assign text[0] = 7'h4c; // L
    assign text[1] = 7'h49; // I
    assign text[2] = 7'h4e; // N
    assign text[3] = 7'h45; // E
    assign text[4] = 7'h53; // S
    assign text[5] = 7'h00; // NULL
    assign text[6] = 7'h43; // C
    assign text[7] = 7'h4c; // L
    assign text[8] = 7'h45; // E
    assign text[9] = 7'h41; // A
    assign text[10] = 7'h52; // R
    assign text[11] = 7'h45; // E
    assign text[12] = 7'h44; // D

    assign welcometext[0] = 7'h57; // W
    assign welcometext[1] = 7'h45; // E
    assign welcometext[2] = 7'h4c; // L
    assign welcometext[3] = 7'h43; // C
    assign welcometext[4] = 7'h4f; // O
    assign welcometext[5] = 7'h4d; // M
    assign welcometext[6] = 7'h45; // E
    assign welcometext[7] = 7'h00; // NULL
    assign welcometext[8] = 7'h54; // T
    assign welcometext[9] = 7'h4f; // O    
    assign welcometext[10] = 7'h00; // NULL    
    assign welcometext[11] = 7'h54; // T
    assign welcometext[12] = 7'h45; // E
    assign welcometext[13] = 7'h54; // T
    assign welcometext[14] = 7'h52; // R
    assign welcometext[15] = 7'h49; // I
    assign welcometext[16] = 7'h53; // S  
    
    assign gameover_text[0] = 7'h47; // G
    assign gameover_text[1] = 7'h41; // A
    assign gameover_text[2] = 7'h4d; // M    
    assign gameover_text[3] = 7'h45; // E
    assign gameover_text[4] = 7'h00; // NULL    
    assign gameover_text[5] = 7'h4f; // O
    assign gameover_text[6] = 7'h56; // V
    assign gameover_text[6] = 7'h45; // E
    assign gameover_text[7] = 7'h52; // R


    //logic        new_piece;      // will drive `next`
   // logic [2:0]  next_piece_id;  // comes from the randomizer  
    /*
    //Keycode HEX drivers
    hex_driver HexA (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[31:28], keycode0_gpio[27:24], keycode0_gpio[23:20], keycode0_gpio[19:16]}),
        .hex_seg(hex_segA),
        .hex_grid(hex_gridA)
    );
    
    hex_driver HexB (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[15:12], keycode0_gpio[11:8], keycode0_gpio[7:4], keycode0_gpio[3:0]}),
        .hex_seg(hex_segB),
        .hex_grid(hex_gridB)
    ); */
    
    mb_block_1 mb_block_i (
        .clk_100MHz(Clk),
        .gpio_usb_int_tri_i(gpio_usb_int_tri_i),
        .gpio_usb_keycode_0_tri_o(keycode0_gpio),
        .gpio_usb_keycode_1_tri_o(keycode1_gpio),
        .gpio_usb_rst_tri_o(gpio_usb_rst_tri_o),
        .reset_rtl_0(~reset_ah), //Block designs expect active low reset, all other modules are active high
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd),
        .usb_spi_miso(usb_spi_miso),
        .usb_spi_mosi(usb_spi_mosi),
        .usb_spi_sclk(usb_spi_sclk),
        .usb_spi_ss(usb_spi_ss)
    );
        
    //clock wizard configured with a 1x and 5x clock for HDMI
    clk_wiz_0 clk_wiz (
        .clk_out1(clk_25MHz),
        .clk_out2(clk_125MHz),
        .reset(reset_ah),
        .locked(locked),
        .clk_in1(Clk)
    );
    
    //VGA Sync signal generator
    vga_controller vga (
        .pixel_clk(clk_25MHz),
        .reset(reset_ah),
        .hs(hsync),
        .vs(vsync),
        .active_nblank(vde),
        .drawX(drawX),
        .drawY(drawY)
    );    

    //Real Digital VGA to HDMI converter
    hdmi_tx_0 vga_to_hdmi (
        //Clocking and Reset
        .pix_clk(clk_25MHz),
        .pix_clkx5(clk_125MHz),
        .pix_clk_locked(locked),
        //Reset is active LOW
        .rst(reset_ah),
        //Color and Sync Signals
        .red(red),
        .green(green),
        .blue(blue),
        .hsync(hsync),
        .vsync(vsync),
        .vde(vde),
        
        //aux Data (unused)
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        
        //Differential outputs
        .TMDS_CLK_P(hdmi_tmds_clk_p),          
        .TMDS_CLK_N(hdmi_tmds_clk_n),          
        .TMDS_DATA_P(hdmi_tmds_data_p),         
        .TMDS_DATA_N(hdmi_tmds_data_n)          
    );

    
    Block Block_instance(
        .Reset(reset_ah),
        .frame_clk(vsync),                    //Figure out what this should be so that the ball will move
        .keycode(keycode0_gpio[7:0]),    //Notice: only one keycode connected to ball by default
        .grid(block_grid),
        .score(score),
        .gameover_flag(gameover_indicator)
       // .rand_num (next_piece_id),
       // .new_piece(new_piece)
    );
    
    //Color Mapper Module   
    color_mapper color_instance(
        .score(score),
        .text(text),
        .welcometext(welcometext),
        .gameover_text(gameover_text),
        .gameover_indicator(gameover_indicator),
        .grid(block_grid),
        .DrawX(drawX),
        .DrawY(drawY),
        .Red(red),
        .Green(green),
        .Blue(blue)
    );
    
assign speaker = speaker2;    
  tetrisTheme music(
      .clk(Clk),
      .reset(reset_ah),
      //.speaker(),
      .speaker2(speaker2)
  );    
  /*
Randomizer rng (
  .clk      (vsync),   // use your VGA/frame clock
  .reset    (reset_ah),    // your active-high reset
  .next     (new_piece),   // pulse high whenever you need a fresh spawn
  .piece_id (next_piece_id)
);  */
endmodule
