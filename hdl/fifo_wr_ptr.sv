module fifo_wr_ptr # (
    parameter PTR_WIDTH = 9
)
(
    input logic                         i_rst_n, 
    input logic                         i_clk_wr, 
    input logic                         i_wr_en, 
    input logic     [PTR_WIDTH-1:0]     i_rd_ptr,
    output logic                        o_full, 
    output logic    [PTR_WIDTH-2:0]     o_wr_ptr_bin, 
    output logic    [PTR_WIDTH-1:0]     o_wr_ptr_gr
);

logic     [PTR_WIDTH-1:0] wr_ptr_bin_next;
logic     [PTR_WIDTH-1:0] wr_ptr_bin;

assign o_wr_ptr_bin    = wr_ptr_bin[PTR_WIDTH-2:0];
assign wr_ptr_bin_next = wr_ptr_bin + ((i_wr_en)&&(!o_full));

// Full flag generator
always_ff @(posedge i_clk_wr or negedge i_rst_n)
    if (~i_rst_n)   o_full          <= 1'b0;
    else            o_full          <= (wr_ptr_gr_next == {~i_rd_ptr[PTR_WIDTH-1:PTR_WIDTH-2],
                                                            i_rd_ptr[PTR_WIDTH-3:0]});
                                                     
// Write address going to the RAM (binary)
always_ff @(posedge i_clk_wr or negedge i_rst_n)
    if (~i_rst_n)   wr_ptr_bin     <= '0;
    else            wr_ptr_bin     <= wr_ptr_bin_next;

// Write address with extra bit (gray) going to the fifo_rd_ptr and empty generator
always_ff @(posedge i_clk_wr or negedge i_rst_n)
    if (~i_rst_n)   o_wr_ptr_gr    <= '0;
    else            o_wr_ptr_gr    <= wr_ptr_gr_next;

fifo_bin2gray # (
    .N          (PTR_WIDTH)
)
module_fifo_bin2gray (
    .binary_in  (wr_ptr_bin_next)
    .gray_out   (wr_ptr_gr_next)
);

endmodule