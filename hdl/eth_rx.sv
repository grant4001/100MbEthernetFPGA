`default_nettype none

module eth_rx ( 
    input logic         i_rst_n, 
    input logic         i_rx_clk,
    input logic [3:0]   i_rx_data, 
    input logic         i_rx_er, 
    input logic         i_rx_dv
);

logic [7:0]   rx_data_reg;
logic         nibble_received;
logic         byte_ready;
logic [2:0]   state;
localparam  STATE_START_FRAME   = 0;
localparam  STATE_MAC_DEST      = 1;
localparam  STATE_MAC_SRC       = 2;
localparam  STATE_ETHERTYPE     = 3;
localparam  STATE_PAYLOAD       = 4;
localparam  STATE_CRC32         = 5;

always @(posedge i_rx_clk or negedge i_rst_n)
    if (~i_rst_n)   nibble_received <= 0;
    else            nibble_received <= nibble_received^((!i_rx_er)&&(i_rx_dv));

always @(posedge i_rx_clk or negedge i_rst_n)
    if (~i_rst_n)   byte_ready  <= 0;
    else            byte_ready  <= ((!i_rx_er)&&(i_rx_dv)&&(nibble_received));

always @(posedge i_rx_clk or negedge i_rst_n)
    if (~i_rst_n)
        rx_data_reg         <= 0;
    else if ((!i_rx_er)&&(i_rx_dv))
        if (nibble_received) begin
            rx_data_reg[3]  <= i_rx_data[0];
            rx_data_reg[2]  <= i_rx_data[1];
            rx_data_reg[1]  <= i_rx_data[2];
            rx_data_reg[0]  <= i_rx_data[3];
        end else begin
            rx_data_reg[7]  <= i_rx_data[0];
            rx_data_reg[6]  <= i_rx_data[1];
            rx_data_reg[5]  <= i_rx_data[2];
            rx_data_reg[4]  <= i_rx_data[3];
        end

reg [2:0] counter;
reg [47:0] mac_dest_addr;
reg [47:0] mac_src_addr;

always @(posedge i_rx_clk or negedge i_rst_n)
    if (((state==STATE_MAC_DEST)||(state==STATE_MAC_SRC))&&(byte_ready)) begin
        counter                 <= counter + 1;
        if (count==5) counter   <= 0;
    end else if ((state==STATE_ETHERTYPE)&&(byte_ready)) begin
        counter <= counter + 1;
        if (count==1) counter   <= 0;
    end
        
always @(posedge rx_clk)
    if ((state==STATE_MAC_DEST)&&(byte_ready))
        mac_dest_addr[47-8*counter -: 8] <= rx_data_reg;
        
always @(posedge rx_clk)
    if ((state==STATE_MAC_SRC)&&(byte_ready))
        mac_src_addr[47-8*counter -: 8] <= rx_data_reg;
        
always @(posedge rx_clk)
    if ((state==STATE_ETHERTYPE)&&(byte_ready))
        ethertype[15-8*counter -: 8] <= rx_data_reg;
        
always @(posedge rx_clk)
    case (state)
        STATE_START_FRAME:  begin
            if ((byte_ready)&&(rx_data_reg==8'hD5))
                state   <= STATE_MAC_DEST;
        end
        STATE_MAC_DEST:     begin
            if ((byte_ready)&&(counter==5))
                state   <= STATE_MAC_SRC;
        end
        STATE_MAC_SRC:      begin
            if ((byte_ready)&&(counter==5))
                state   <= STATE_MAC_SRC;
        end
        STATE_ETHERTYPE:    begin
            if ((byte_ready)&&(counter==1))
                state   <= STATE_PAYLOAD;
        end
        STATE_PAYLOAD:      begin
            
    
    endcase


endmodule