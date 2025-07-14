module PipelinedProcessor (
    input clk
);

    // Instruction and Register Memory
    reg [7:0] instr_mem [0:7];     // 8 instructions max
    reg [7:0] reg_file [0:3];      // 4 general-purpose registers

    // Pipeline Registers
    reg [7:0] IF_ID, ID_EX, EX_WB;

    // Internal PC Counter
    integer pc;
    integer i;

    initial begin
        // Initialize PC and register file
        pc = 0;
        for (i = 0; i < 4; i = i + 1)
            reg_file[i] = i;

        // Load some instructions
        instr_mem[0] = 8'b00000110;  // ADD R0 = R1 + R2
        instr_mem[1] = 8'b01011100;  // SUB R3 = R1 - R0
        instr_mem[2] = 8'b10001000;  // LOAD R2 = 8
        instr_mem[3] = 8'b00000011;  // ADD R0 = R0 + R3
    end

    always @(posedge clk) begin
        $display("-------------------------------------------------");
        $display("Cycle %0d:", pc+1);

        // ---------------- Stage 1: Instruction Fetch ----------------
        IF_ID <= instr_mem[pc];
        $display("IF Stage: Fetching instruction = %b from addr = %0d", instr_mem[pc], pc);

        // ---------------- Stage 2: Instruction Decode ----------------
        ID_EX <= IF_ID;
        $display("ID Stage: Decoding instruction = %b", IF_ID);

        // ---------------- Stage 3: Execute ----------------
        case(ID_EX[7:6])
            2'b00: begin  // ADD
                reg_file[ID_EX[5:4]] <= reg_file[ID_EX[3:2]] + reg_file[ID_EX[1:0]];
                $display("EX Stage: ADD R%d = R%d + R%d => %d",
                    ID_EX[5:4], ID_EX[3:2], ID_EX[1:0],
                    reg_file[ID_EX[3:2]] + reg_file[ID_EX[1:0]]);
            end
            2'b01: begin  // SUB
                reg_file[ID_EX[5:4]] <= reg_file[ID_EX[3:2]] - reg_file[ID_EX[1:0]];
                $display("EX Stage: SUB R%d = R%d - R%d => %d",
                    ID_EX[5:4], ID_EX[3:2], ID_EX[1:0],
                    reg_file[ID_EX[3:2]] - reg_file[ID_EX[1:0]]);
            end
            2'b10: begin  // LOAD
                reg_file[ID_EX[5:4]] <= ID_EX[3:0];
                $display("EX Stage: LOAD R%d = %d",
                    ID_EX[5:4], ID_EX[3:0]);
            end
            default: $display("EX Stage: NOP");
        endcase

        // ---------------- Stage 4: Write Back ----------------
        EX_WB <= ID_EX;
        $display("WB Stage: Register File Update for R%d = %d",
            ID_EX[5:4], reg_file[ID_EX[5:4]]);

        pc = pc + 1;

        if (pc >= 4) begin
            $display("Simulation complete.");
            $finish;
        end
    end

endmodule
