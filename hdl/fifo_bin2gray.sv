module fifo_bin2gray # (
    parameter N = 8
)
(
    input logic     [N-1:0] binary_in, 
    output logic    [N-1:0] gray_out
);

assign gray_out = binary_in^(binary_in>>1);

endmodule