`ifndef SIGN_EXTEND_V
`define SIGN_EXTEND_V

module Sign_Extend (
    input [31:7] In,
    input [1:0] ImmSrc,
    output reg [31:0] Imm_Ext
);

    always @(*) begin
        case (ImmSrc)
            // I-Type immediate (Arithmetic immediates, Loads)
            2'b00:   Imm_Ext = { {20{In[31]}}, In[31:20] };
            
            // S-Type immediate (Stores)
            2'b01:   Imm_Ext = { {20{In[31]}}, In[31:25], In[11:7] };
            
            // B-Type immediate (Branches)
            2'b10:   Imm_Ext = { {20{In[31]}}, In[7], In[30:25], In[11:8], 1'b0 };
            
            // J-Type immediate (Jumps - JAL)
            2'b11:   Imm_Ext = { {12{In[31]}}, In[19:12], In[20], In[30:21], 1'b0 };
            
            default: Imm_Ext = 32'h00000000;
        endcase
    end

endmodule

`endif