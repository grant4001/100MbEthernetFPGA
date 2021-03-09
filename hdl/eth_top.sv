module echo_server_top (
    mdio, mdc, phy_reset_n, tx_data, tx_en, tx_clk, rx_data, 
    rx_er, rx_dv, rx_clk, col, crs
);

inout           mdio;
output          mdc;
output          phy_reset_;
output [3:0]    tx_data;
output          tx_en;
output          tx_clk;
input [3:0]     rx_data;
input           rx_er;
input           rx_dv;
input           rx_clk;
input           col;
input           crs;


endmodule