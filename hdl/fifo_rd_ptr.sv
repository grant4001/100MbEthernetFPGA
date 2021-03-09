module fifo_rd_ptr # (
    parameter PTR_WIDTH = 9
)
(
    input logic                         i_rst_n, 
    input logic                         i_clk_rd, 
    input logic                         i_rd_en, 
    input logic     [PTR_WIDTH-1:0]     i_wr_ptr,
    output logic                        o_empty, 
    output logic    [PTR_WIDTH-2:0]     o_rd_ptr_bin,
    output logic    [PTR_WIDTH-1:0]     o_rd_ptr_gr
);

logic     [PTR_WIDTH-1:0] rd_ptr_bin_next;
logic     [PTR_WIDTH-1:0] rd_ptr_bin;

assign o_rd_ptr_bin    = rd_ptr_bin[PTR_WIDTH-2:0];
assign rd_ptr_bin_next = rd_ptr_bin + ((i_rd_en)&&(!o_empty));

// Empty flag generator
always_ff @(posedge i_clk_rd or negedge i_rst_n)
    if (~i_rst_n)   o_empty     <= 1'b1;
    else            o_empty     <= (rd_ptr_gr_next == {~i_wr_ptr[PTR_WIDTH-1],
                                                        i_wr_ptr[PTR_WIDTH-2:0]});
    
// Read address going into the dpbram
always_ff @(posedge i_clk_rd or negedge i_rst_n)
    if (~i_rst_n)   rd_ptr_bin  <= '0;
    else            rd_ptr_bin  <= rd_ptr_bin_next;

// Read pointer going into the wr pointer generator module
always_ff @(posedge i_clk_rd or negedge i_rst_n)
    if (~i_rst_n)   o_rd_ptr_gr <= '0;
    else            o_rd_ptr_gr <= rd_ptr_gr_next;
    
fifo_bin2gray # (
    .N          (PTR_WIDTH)
)
module_fifo_bin2gray (
    .binary_in  (rd_ptr_bin_next)
    .gray_out   (rd_ptr_gr_next)
);

endmodule