module VGA(
    input clk, rst,
    output reg [3:0] vga_b, vga_g, vga_r,
    output hsync, vsync
);
    parameter H_SYNC = 96,
              H_SYNC_BACK_Porch = 48,
              H_SYNC_ADDRESSABLE_VIDEO = 640,
              H_SYNC_FRONT_PORCH = 16,
              H_SYNC_PERIOD = H_SYNC + H_SYNC_BACK_Porch + H_SYNC_ADDRESSABLE_VIDEO + H_SYNC_FRONT_PORCH;

    parameter V_SYNC = 2,
              V_SYNC_BACK_Porch = 33,
              V_SYNC_ADDRESSABLE_VIDEO = 480,
              V_SYNC_FRONT_PORCH = 10,
              V_SYNC_PERIOD = V_SYNC + V_SYNC_BACK_Porch + V_SYNC_ADDRESSABLE_VIDEO + V_SYNC_FRONT_PORCH;

    reg [9:0] h_counter, v_counter;

    // 直角三角形的底邊位置、高度和長度
    parameter BASE_X = 320;  // 直角三角形頂點 X
    parameter BASE_Y = 240;  // 直角三角形頂點 Y
    parameter BASE_WIDTH = 200;  // 底邊長度
    parameter HEIGHT = 200;  // 高度

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            h_counter <= 10'd0;
            v_counter <= 10'd0;
        end else begin
            if (h_counter == H_SYNC_PERIOD - 1) begin
                h_counter <= 10'd0;
                if (v_counter == V_SYNC_PERIOD - 1) begin
                    v_counter <= 10'd0;
                end else begin
                    v_counter <= v_counter + 1;
                end
            end else begin
                h_counter <= h_counter + 1;
            end
        end
    end

    assign hsync = (h_counter < H_SYNC) ? 1'b0 : 1'b1;
    assign vsync = (v_counter < V_SYNC) ? 1'b0 : 1'b1;

    wire valid_flag;
    assign valid_flag = (h_counter >= (H_SYNC + H_SYNC_BACK_Porch)) &&
                         (h_counter < (H_SYNC + H_SYNC_BACK_Porch + H_SYNC_ADDRESSABLE_VIDEO)) &&
                         (v_counter >= (V_SYNC + V_SYNC_BACK_Porch)) && 
                         (v_counter < (V_SYNC + V_SYNC_BACK_Porch + V_SYNC_ADDRESSABLE_VIDEO));

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            vga_r <= 4'h0;
            vga_g <= 4'h0;
            vga_b <= 4'h0;
        end else begin
            // 顯示直角三角形
            if (valid_flag) begin
                // 判斷該像素是否在直角三角形內
                // 三角形的邊界條件，確保顯示的範圍是正確的
                if (h_counter >= BASE_X && 
                    h_counter <= BASE_X + BASE_WIDTH &&
                    v_counter >= BASE_Y && 
                    v_counter <= BASE_Y + HEIGHT &&
                    v_counter <= BASE_Y + HEIGHT - (h_counter - BASE_X) * HEIGHT / BASE_WIDTH) begin
                    vga_r <= 4'hf;   // 顯示為紅色
                    vga_g <= 4'h0;
                    vga_b <= 4'h0;
                end else begin
                    vga_r <= 4'h0;
                    vga_g <= 4'h0;
                    vga_b <= 4'h0;  // 背景顯示為黑色
                end
            end else begin
                vga_r <= 4'h0;
                vga_g <= 4'h0;
                vga_b <= 4'h0;
            end
        end
    end
endmodule
