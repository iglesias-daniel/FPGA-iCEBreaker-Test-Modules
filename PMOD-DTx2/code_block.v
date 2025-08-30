reg [7:0] rom [0:15];
reg [3:0] counter[0:1];
reg [6:0] D_i[0:1];
reg sel_reg;
reg [15:0] counter_clk;
reg btn_up_sync1, btn_up_sync2;
reg btn_dwn_sync1, btn_dwn_sync2;
reg btn_rst_sync1, btn_rst_sync2;

always @(posedge clk) begin
    // Sincronizar botones
    btn_up_sync1 <= btn_up;
    btn_up_sync2 <= btn_up_sync1;
    btn_dwn_sync1 <= btn_dwn;
    btn_dwn_sync2 <= btn_dwn_sync1;
    btn_rst_sync1 <= btn_rst;
    btn_rst_sync2 <= btn_rst_sync1;
    
    // & (counter[1] < 9) & (counter[0] < 9)
    // Detectar flanco
    if (btn_up_sync1 & ~btn_up_sync2) begin
        if (counter[0] == 9) begin
            if (counter[1] != 9) begin
                counter[0] <= 0;
                counter[1] <= counter[1] + 1;
            end
        end else begin 
            counter[0] <= counter[0] + 1;
        end
    end else if (btn_dwn_sync1 & ~btn_dwn_sync2) begin
        if (counter[0] == 0) begin
            if (counter[1] != 0) begin
                counter[0] <= 9;
                counter[1] <= counter[1] - 1;
            end
        end else begin 
            counter[0] <= counter[0] - 1;
        end
    end

    // Reset
    if (btn_rst_sync1 & ~btn_rst_sync2) begin
        counter[0] <= 0;
        counter[1] <= 0;
        sel_reg <= 0;
    end
        
    // Actualizar salida del display
    D_i[0] <= rom[counter[0]];
    D_i[1] <= rom[counter[1]];
    
    if (counter_clk > 50000) begin
        counter_clk <= 0;
        sel_reg <= ~sel_reg;
    end else begin
        counter_clk <= counter_clk + 1;
    end
end

assign D = (sel_reg) ? ~D_i[0] : ~D_i[1];
assign sel = sel_reg;

initial begin
    counter[0] = 0;
    counter[1] = 0;
    sel_reg = 0;
    D_i[0] = 0;
    D_i[1] = 0;
    if (ROMFILE) $readmemh(ROMFILE, rom);
end
