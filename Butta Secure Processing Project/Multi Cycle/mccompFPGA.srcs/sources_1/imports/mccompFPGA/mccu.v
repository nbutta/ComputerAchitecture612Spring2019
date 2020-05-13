/************************************************
  The Verilog HDL code example is from the book
  Computer Principles and Design in Verilog HDL
  by Yamin Li, published by A JOHN WILEY & SONS
************************************************/
module mccu (
            input wire [31:0] pc,
            input wire [5:0] op,
            input wire [5:0] func,
            input wire z,
            input wire clk,
            input wire clrn,

            //secure
            input wire gcm_aes_done,
            input wire [127:0] instruction_signature,
            input wire [127:0] data_signature,
            input wire [127:0] calculated_signature,

            input wire [31:0] sn_data_out, 
            input wire [31:0] regc,

            output reg wpc,
            output reg wir,

            //secure
            output reg write_encrypted_ir,
            output reg gcm_aes_en,
            output reg [127:0] gcm_aes_IV,

            output reg sn_we,
            output reg [31:0] sn_data_in,
            output reg [1:0] gcmaessel,
            output reg we_e_regb,

            output reg wmem,         //sw instruction 
            output reg wreg,         //write register file (only if data verified on lw)
            output reg iord,         //use pc or regc to index into memory
            output reg regrt,
            output reg m2reg,        //high for lw instruction
            output reg [3:0] aluc,
            output reg shift,
            output reg alusrca,
            output reg [1:0] alusrcb,
            output reg [1:0] pcsrc,
            output reg jal,
            output reg sext,
            output reg [3:0] state
            );    // control unit
    
    reg        [3:0] next_state;                   // next state
    parameter  [3:0] sif                 = 4'b0000,                // IF  state
                     sverify             = 4'b0001,
                     sid                 = 4'b0010,                // ID  state
                     sexe                = 4'b0011,                // EXE state
                     smem                = 4'b0100,                // MEM state
                     s_authenticate1     = 4'b0101,
                     s_auth_wait         = 4'b0110,
                     s_authenticate2     = 4'b0111,
                     swb                 = 4'b1000,                // WB  state
                     s_data_verify       = 4'b1001, 
                     s_data_verify_check = 4'b1010;
                     
    wire rtype,i_add,i_sub,i_and,i_or,i_xor,i_sll,i_srl,i_sra,i_jr;
    wire i_addi,i_andi,i_ori,i_xori,i_lw,i_sw,i_beq,i_bne,i_lui,i_j,i_jal;

    // and (out, in1, in2, ...);                   // instruction decode
    and (rtype,~op[5],~op[4],~op[3],~op[2],~op[1],~op[0]);
    and (i_add,rtype, func[5],~func[4],~func[3],~func[2],~func[1],~func[0]);
    and (i_sub,rtype, func[5],~func[4],~func[3],~func[2], func[1],~func[0]);
    and (i_and,rtype, func[5],~func[4],~func[3], func[2],~func[1],~func[0]);
    and (i_or, rtype, func[5],~func[4],~func[3], func[2],~func[1], func[0]);
    and (i_xor,rtype, func[5],~func[4],~func[3], func[2], func[1],~func[0]);
    and (i_sll,rtype,~func[5],~func[4],~func[3],~func[2],~func[1],~func[0]);
    and (i_srl,rtype,~func[5],~func[4],~func[3],~func[2], func[1],~func[0]);
    and (i_sra,rtype,~func[5],~func[4],~func[3],~func[2], func[1], func[0]);
    and (i_jr, rtype,~func[5],~func[4], func[3],~func[2],~func[1],~func[0]);
    and (i_addi,~op[5],~op[4], op[3],~op[2],~op[1],~op[0]);
    and (i_andi,~op[5],~op[4], op[3], op[2],~op[1],~op[0]);
    and (i_ori, ~op[5],~op[4], op[3], op[2],~op[1], op[0]);
    and (i_xori,~op[5],~op[4], op[3], op[2], op[1],~op[0]);
    and (i_lw,   op[5],~op[4],~op[3],~op[2], op[1], op[0]);
    and (i_sw,   op[5],~op[4], op[3],~op[2], op[1], op[0]);
    and (i_beq, ~op[5],~op[4],~op[3], op[2],~op[1],~op[0]);
    and (i_bne, ~op[5],~op[4],~op[3], op[2],~op[1], op[0]);
    and (i_lui, ~op[5],~op[4], op[3], op[2], op[1], op[0]);
    and (i_j,   ~op[5],~op[4],~op[3],~op[2], op[1],~op[0]);
    and (i_jal, ~op[5],~op[4],~op[3],~op[2], op[1], op[0]);
    wire i_shift = i_sll | i_srl | i_sra;

    //FSM
    always @* begin                                // default outputs:

        wpc     = 0;                               // do not write pc
        wir     = 0;                               // do not write ir
        wmem    = 0;                               // do not write memory
        wreg    = 0;                               // do not write regfile
        iord    = 0;                               // select pc as address
        aluc    = 4'bx000;                         // alu operation: add
        alusrca = 0;                               // alu a: reg a or sa
        alusrcb = 2'h0;                            // alu input b: reg b
        regrt   = 0;                               // reg dest no: rd
        m2reg   = 0;                               // select reg c
        shift   = 0;                               // select reg a
        pcsrc   = 2'h0;                            // select alu output
        jal     = 0;                               // not a jal
        sext    = 1;                               // sign extend

        //secure
        write_encrypted_ir = 0;
        gcm_aes_en = 0;
        gcm_aes_IV = 0;
        sn_data_in = 0;
        sn_we = 0;
        gcmaessel = 2'h0;
        we_e_regb = 0;

        next_state = state;

        case (state) 
            //------------------------------------------------- IF:
            //Kick off the GCM AES engine to decrypt the instruction and calculate
            //the signature on the decrypted output (plaintext)
            sif: begin                             // IF state
                wpc     = 1;                       // write PC
                alusrca = 1;                       // PC
                alusrcb = 2'h1;                    // 4

                //SMCP
                write_encrypted_ir  = 1;
                gcm_aes_en          = 1;

                //only needs to be set when gcm_aes_en goes high (gets registered in to the controller immediately)
                //IV is the address of the current instruction (pc has not been written pc+4 yet) concatenated with 1
                gcm_aes_IV          = {64'b0, pc, 32'b1};

                //gcm_aes_data_in = encrypted_ir
                gcmaessel           = 2'h0;

                next_state          = sverify;
            end 

            //At this point, we have the encrypted instruction sitting in e_ir
            //We need to wait for the Engine to complete and verify the signatures match
            sverify: begin
                gcmaessel = 2'h0;
                //Counting on done not to be 1 at this point (just transitioned from IDLE to KEY)
                if (gcm_aes_done) begin
                  if (instruction_signature == calculated_signature) begin
                    //if the instruction was verified, proceed as normal to Decode
                    wir        = 1;
                    next_state = sid;
                  end else begin
                    next_state = sif;
                  end
                end
            end

            //------------------------------------------------------ ID:
            sid: begin                             // ID state
                if (i_j) begin                     // j instruction
                    pcsrc = 2'h3;                  // jump address
                    wpc   = 1;                     // write PC
                    next_state = sif;              // next state: IF
                end else if (i_jal) begin          // jal instruction
                    pcsrc = 2'h3;                  // jump address
                    wpc   = 1;                     // write PC
                    jal   = 1;                     // reg no = 31
                    wreg  = 1;                     // save PC+4
                    next_state = sif;              // next state: IF
                end else if (i_jr) begin           // jr instruction
                    pcsrc = 2'h2;                  // jump register
                    wpc   = 1;                     // write PC
                    next_state = sif;              // next state: IF
                end else begin                     // other instructions
                    aluc    = 4'bx000;             // add
                    alusrca = 1;                   // PC
                    alusrcb = 2'h3;                // branch offset
                    next_state = sexe;             // next state: EXE
                end
            end 
            //----------------------------------------------------- EXE:
            //       add sub and or xor sll srl sra lw sw beq bne addi andi ori xori lui
            // aluc[3] X  X   X   X  X   0   0   1  X  X   X   X    X    X   X    X   X
            // aluc[2] 0  1   0   1  0   0   1   1  0  0   0   0    0    0   1    0   1
            // aluc[1] 0  0   0   0  1   1   1   1  0  0   1   1    0    0   0    1   1
            // aluc[0] 0  0   1   1  0   1   1   1  0  0   0   0    0    1   1    0   0
            sexe: begin                            // EXE state
                aluc[3] = i_sra;
                aluc[2] = i_sub | i_or  | i_srl | i_sra | i_ori  | i_lui;
                aluc[1] = i_xor | i_sll | i_srl | i_sra | i_xori | i_beq  |
                          i_bne | i_lui;
                aluc[0] = i_and | i_or  | i_sll | i_srl | i_sra  | i_andi |
                          i_ori;
                if (i_beq || i_bne) begin          // beq or bne inst
                    pcsrc = 2'h1;                  // branch address
                    wpc = i_beq & z | i_bne & ~z;  // write PC
                    next_state = sif;              // next state: IF
                end else begin                     // other instruction
                    if (i_lw || i_sw) begin        // lw or sw inst
                        alusrcb = 2'h2;            // select offset
                        next_state = smem;         // next state: MEM
                    end else begin                 // other instruction
                        if (i_shift) shift = 1;    // shift instruction
                        if (i_addi || i_andi || i_ori || i_xori || i_lui)
                            alusrcb = 2'h2;        // select immediate
                        if (i_andi || i_ori || i_xori) sext=0;   // 0 extend
                        next_state = swb;          // next state: WB
                    end
                end
            end

            //At this point, regc has the effective address we need          
            //By the next cycle, we will have the encrypted data and its signature for a load  
            //----------------------------------------------------- MEM:
            smem: begin                            // MEM state

                //Use regc as the data memory address instead of the pc
                iord = 1;                          

                //Keep this at offset to make sure regC doesnt change
                alusrcb = 2'h2;

                //Load. Verification needed
                //Our encrypted data and its signature will be in registers after this state for load
                if (i_lw) begin                    
                    next_state = s_data_verify;    

                //Store. Signing needed
                end else begin                     

                    //regc holds the effective address
                    //sn_data_out holds the sequence number for the address of interest
                    gcm_aes_IV = regc + sn_data_out + 1;

                    //use regb (the data to store) as input to the Engine
                    gcmaessel  = 2'h1;
                    gcm_aes_en = 1;
                    next_state = s_authenticate1;
                end
            end 

            //Wait for the first round of encryption to complete
            s_authenticate1: begin
                gcmaessel = 2'h1;                
                alusrcb = 2'h2;
                if (gcm_aes_done) begin

                    //write the encrypted version of regb
                    we_e_regb  = 1;
                    next_state = s_auth_wait;
                end
            end

            //Set up the second round of encryption
            //Unfortunately, we need to do this because the GCM AES Engine does not support a decrypt mode
            //Therefore, we have to perform another encryption (using the result of the first encryption as input)
            //to get the original unencrypted data register back out, and then calculate the signature on the plaintext instead of
            //the ciphertext as in the case of the first encryption
            //The signature on the plaintext is what we will end up storing along with the encrypted data in memory
            //so that on verification we can use the Engine in encrypt mode to get the decrypted message out and the signature
            //which will be on the plaintext for quick comparison with what is in the signature memory for that chunk of data
            s_auth_wait: begin
                //Encrypt it again using the encrypted regb as input
                alusrcb    = 2'h2;
                gcm_aes_IV = regc + sn_data_out + 1;
                gcm_aes_en = 1;

                //use the encrypted regb as input to the Engine. The engine data output will be the original data
                gcmaessel  = 2'h2;
                next_state = s_authenticate2;
            end

            //Store the encrypted data and the signature on its plaintext
            s_authenticate2: begin
                //Use regc as the data memory address instead of the pc for the store
                iord       = 1;                          
                gcmaessel  = 2'h2;
                alusrcb    = 2'h2;
                if (gcm_aes_done) begin

                    //We're done! 
                    //Signature sitting at output of the engine in caluclated signature
                    //Data sitting in e_regb

                    //Increment the sequence number for the data just stored and put in in the seqeunce number memory
                    //This value will be used on the next load
                    sn_data_in = sn_data_out + 1;
                    sn_we = 1;

                    wmem = 1;
                    next_state = sif;
                end
            end

            //Set up the controller to decrypt the data
            s_data_verify: begin
                //Make sure the data register doesnt change
                //Use regc as the address, not PC
                iord       = 1;                          
                gcmaessel  = 2'h3;
                alusrcb    = 2'h2;
                gcm_aes_IV = regc + sn_data_out;
                gcm_aes_en = 1;
                next_state = s_data_verify_check;
            end

            //Verify the calculated and fetched signatuers match. If so, write the value into the register
            //Otherwise, don't
            s_data_verify_check: begin
                iord       = 1;                          // memory address = C
                gcmaessel  = 2'h3;
                alusrcb    = 2'h2;
                if (gcm_aes_done) begin
                   if (data_signature == calculated_signature) begin
                      m2reg = 1;
                      regrt = 1;
                      wreg  = 1;
                    end
                    
                    next_state = sif;
                end
            end

            //LW actually wont get here any more
            //It will be shortcircuited at the previous state
            //------------------------------------------------------ WB:
            swb: begin                             // WB state
                if (i_lw) m2reg = 1;               // select memory data
                if (i_lw || i_addi || i_andi || i_ori || i_xori || i_lui)
                    regrt = 1;                     // reg dest no: rt
                wreg = 1;                          // write register file
                next_state = sif;                  // next state: IF
            end 

            //------------------------------------------------------ END
            default: begin
                next_state = sif;                  // default state: IF
            end
        endcase
    end
    always @ (posedge clk or negedge clrn) begin
        if (!clrn) begin
            state <= sif;                          // reset state to IF
        end else begin
            state <= next_state;                   // state transition
        end
    end
endmodule
