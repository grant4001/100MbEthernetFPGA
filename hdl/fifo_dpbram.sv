module fifo_dpbram #(
    parameter ADDR_WIDTH    = 8,
    parameter DEPTH         = 256,
    parameter DATA_WIDTH    = 8
)
(
    input logic                     i_clk_wr, 
    input logic                     i_clk_rd, 
    input logic                     i_wr_en, 
    input logic [DATA_WIDTH-1:0]    i_wr_data, 
    input logic [ADDR_WIDTH-1:0]    i_wr_addr, 
    input logic [ADDR_WIDTH-1:0]    i_rd_addr, 
    input logic [DATA_WIDTH-1:0]    o_rd_data
);

logic [DATA_WIDTH-1:0] mem [DEPTH-1:0];

always_ff @(posedge i_clk_wr)
    if (i_wr_en) mem[i_wr_addr]  <= i_wr_data;

always_ff @(posedge i_clk_rd)              
    o_rd_data       <= mem[i_rd_addr];
    
endmodule