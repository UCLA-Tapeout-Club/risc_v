module run_controller (
    input logic clk,
    input logic rst_n,

    input logic cpu_start,
    input logic cpu_step,
    input logic [1:0] pc_value,

    output logic cpu_enable,
    output logic cpu_done
);

typedef enum logic [1:0] {
    CPU_LOAD,
    CPU_RUN,
    CPU_DONE
} cpu_state_t;

cpu_state_t state;

assign cpu_enable = (state == CPU_RUN) || cpu_step;
assign cpu_done = (state == CPU_DONE);

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= CPU_LOAD;
    end else begin
        case (state)
            CPU_LOAD: begin
                if (cpu_start) begin
                    state <= CPU_RUN;
                end
            end

            CPU_RUN: begin
                if (pc_value == 2'b11) begin
                    state <= CPU_DONE;
                end
            end

            CPU_DONE: begin
                if (cpu_start) begin
                    state <= CPU_RUN;
                end
            end

            default: begin
                state <= CPU_LOAD;
            end
        endcase
    end
end

endmodule
