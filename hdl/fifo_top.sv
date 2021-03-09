module fifo_top # (
    parameter DATA_WIDTH    = 8,
    parameter DEPTH         = 256
)
(
    input  logic                    i_rst_n, 
    input  logic                    i_clk_wr, 
    input  logic                    i_clk_rd, 
    input  logic                    i_wr_en, 
    input  logic [DATA_WIDTH-1:0]   i_wr_data, 
    input  logic                    i_rd_en, 
    output logic [DATA_WIDTH-1:0]   o_rd_data, 
    output logic                    o_full, 
    output logic                    o_empty
);

localparam RAM_ADDR_WIDTH   = $clog2(DEPTH);
localparam PTR_WIDTH        = RAM_ADDR_WIDTH + 1;

// DPRAM interface signals
logic                           ram_wr_en;
logic    [RAM_ADDR_WIDTH-1:0]   ram_wr_addr;
logic    [RAM_ADDR_WIDTH-1:0]   ram_rd_addr;

// Gray-coded pointers 
logic    [PTR_WIDTH-1:0]        wr_ptr_gr;
logic    [PTR_WIDTH-1:0]        rd_ptr_gr;
logic    [PTR_WIDTH-1:0]        wr_ptr_sync [1:0];
logic    [PTR_WIDTH-1:0]        rd_ptr_sync [1:0];

assign ram_wr_en = ((i_wr_en)&&(!o_full));

always_ff @(posedge i_clk_rd or negedge i_rst_n)
    if (~i_rst_n)   wr_ptr_sync <= {'0,'0};
    else            wr_ptr_sync <= {wr_ptr_sync[0],wr_ptr_gr}; 

always_ff @(posedge i_clk_wr or negedge i_rst_n)
    if (~i_rst_n)   rd_ptr_sync <= {'0,'0};
    else            rd_ptr_sync <= {rd_ptr_sync[0],rd_ptr_gr};     

fifo_dpbram #( 
    .ADDR_WIDTH (RAM_ADDR_WIDTH),
    .DEPTH      (DEPTH),
    .DATA_WIDTH (DATA_WIDTH)
)
module_fifo_dpbram ( 
    .i_clk_wr   (i_clk_wr),
    .i_clk_rd   (i_clk_rd),
    .i_wr_en    (ram_wr_en),
    .i_wr_data  (i_wr_data),
    .i_wr_addr  (ram_wr_addr),
    .i_rd_addr  (ram_rd_addr),
    .o_rd_data  (o_rd_data)
);

fifo_wr_ptr #(
    .PTR_WIDTH      (PTR_WIDTH)
)
module_fifo_wr_ptr (
    .i_rst_n        (i_rst_n),
    .i_clk_wr       (i_clk_wr),
    .i_wr_en        (i_wr_en),
    .i_rd_ptr       (rd_ptr_sync[1]),
    .o_full         (o_full),
    .o_wr_ptr_bin   (ram_wr_addr),
    .o_wr_ptr_gr    (wr_ptr_gr)
);

fifo_rd_ptr #(
    .PTR_WIDTH      (PTR_WIDTH)
)
module_fifo_rd_ptr (
    .i_rst_n        (i_rst_n),
    .i_clk_rd       (i_clk_rd),
    .i_rd_en        (i_rd_en),
    .i_wr_ptr       (wr_ptr_sync[1]),
    .o_empty        (o_empty),
    .o_rd_ptr_bin   (ram_rd_addr),
    .o_rd_ptr_gr    (rd_ptr_gr)
);

endmodule