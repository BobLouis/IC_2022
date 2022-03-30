module JAM (
input CLK,
input RST,
output  [2:0] W,
output  [2:0] J,
input [6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output reg Valid );

reg [2:0]state, next_state;
parameter IDLE = 3'b000;
parameter READ = 3'b001;
parameter CAL = 3'b010;
parameter OUT = 3'b011;

reg [9:0]min;
reg [3:0]arr[0:8];
reg [7:0]cnt;
wire [6:0]cmp;
reg [2:0]idx;
reg done;
reg half_done;
reg [2:0]i;
reg [2:0]sw;
always@(posedge CLK or posedge RST)begin
    if(RST)
        state <= IDLE;
    else 
        state <= next_state;
end

always@(*)begin
    if(RST)
        next_state = IDLE;
    else begin
        case(state)
            IDLE:
                next_state = READ;
            READ:begin
                if(cnt == 3'd7) next_state = CAL;
                else next_state = READ;  
            end
            CAL:begin
                if(arr[0]==3'd7&&arr[1]==3'd6&&arr[2]==3'd5&&arr[3]==3'd4&&arr[4]==3'd3&&
                arr[5]==3'd2&&arr[6]==3'd1&&arr[7]==3'd0) next_state = OUT;
                else next_state = READ;
            end 
            OUT:
                next_state = READ; 
            default:    next_state = IDLE;
        endcase
    end 
end

//cnt
always@(posedge CLK or posedge RST)begin
    if(RST)
        cnt <= 0;
    else if(state == READ)
        cnt <= cnt + 3'd1;
    else 
        cnt <= 0;
end

assign cmp[0] = (arr[7] > arr[6]) ? 1 : 0;
assign cmp[1] = (arr[6] > arr[5]) ? 1 : 0;
assign cmp[2] = (arr[5] > arr[4]) ? 1 : 0;
assign cmp[3] = (arr[4] > arr[3]) ? 1 : 0;
assign cmp[4] = (arr[3] > arr[2]) ? 1 : 0;
assign cmp[5] = (arr[2] > arr[1]) ? 1 : 0;
assign cmp[6] = (arr[1] > arr[0]) ? 1 : 0;


wire [3:0]a0, a1, a2, a3, a4, a5, a6, a7;
wire [3:0]b0, b1, b2, b3;
wire [3:0]c0, c1;
wire [3:0]d0;
assign a0 = 4'd8;
assign a1 = (1 > idx && arr[idx] <= arr[1]) ? 4'd1 : 4'd8;
assign a2 = (2 > idx && arr[idx] <= arr[2]) ? 4'd2 : 4'd8;
assign a3 = (3 > idx && arr[idx] <= arr[3]) ? 4'd3 : 4'd8;
assign a4 = (4 > idx && arr[idx] <= arr[4]) ? 4'd4 : 4'd8;
assign a5 = (5 > idx && arr[idx] <= arr[5]) ? 4'd5 : 4'd8;
assign a6 = (6 > idx && arr[idx] <= arr[6]) ? 4'd6 : 4'd8;
assign a7 = (7 > idx && arr[idx] <= arr[7]) ? 4'd7 : 4'd8;

assign b0 = (arr[a0] < arr[a1]) ? a0 : a1;
assign b1 = (arr[a2] < arr[a3]) ? a2 : a3;
assign b2 = (arr[a4] < arr[a5]) ? a4 : a5;
assign b3 = (arr[a6] < arr[a7]) ? a6 : a7;

assign c0 = (arr[b0] < arr[b1]) ? b0 : b1;
assign c1 = (arr[b2] < arr[b3]) ? b2 : b3;

assign d0 = (arr[c0] < arr[c1]) ? c0 : c1;

//SORTING
always@(posedge CLK or posedge RST)begin
    if(RST)begin
        arr[0] <= 4'd0;
        arr[1] <= 4'd1;
        arr[2] <= 4'd2;
        arr[3] <= 4'd3;
        arr[4] <= 4'd4;
        arr[5] <= 4'd5;
        arr[6] <= 4'd6;
        arr[7] <= 4'd7;
        arr[8] <= 4'd8;
        done <= 0;
        i <= 0;
    end
    else if(state == READ)begin
        if(!done)begin
            if(cnt == 0)begin
                sw <= idx;
               
            end
            else if(cnt == 1)begin
                arr[sw] <= arr[d0];
                arr[d0] <= arr[sw];
            end
            else begin
                case(sw)
                    0:begin
                        arr[7] <= arr[1];
                        arr[1] <= arr[7];

                        arr[2] <= arr[6];
                        arr[6] <= arr[2];

                        arr[3] <= arr[5];
                        arr[5] <= arr[3];    
                    end
                    1:begin
                        arr[2] <= arr[7];
                        arr[7] <= arr[2];

                        arr[3] <= arr[6];
                        arr[6] <= arr[3];

                        arr[4] <= arr[5];
                        arr[5] <= arr[4];
                    end
                    2:begin
                        arr[3] <= arr[7];
                        arr[7] <= arr[3];

                        arr[4] <= arr[6];
                        arr[6] <= arr[4];
                    end
                    3:begin
                        arr[4] <= arr[7];
                        arr[7] <= arr[4];

                        arr[5] <= arr[6];
                        arr[6] <= arr[5];
                    end
                    4:begin
                        arr[5] <= arr[7];
                        arr[7] <= arr[5];
                    end
                    5:begin
                        arr[6] <= arr[7];
                        arr[7] <= arr[6];
                    end 
                endcase
                done <= 1;
            end
        end
    end
    else if(state == CAL)begin
        done <= 0;
        // half_done <= 0;
    end
    
end

assign W = cnt;
assign J = arr[cnt];
/*always@(*)begin
    if(state == READ)begin
        W = cnt;
        J = arr[cnt];
    end
    else begin 
        W = W;
        J = J;
    end
end*/

//DATA INPUT
always@(posedge CLK or posedge RST)begin
    if(RST)begin
        MinCost <= 10'd1023;
        min <= 0;
        MatchCount <= 0;
    end
    else if(state == READ)begin
        if(cnt <= 3'd7)begin
            min <= min + Cost;  
        end 
    end
    else if(state == CAL && MinCost == min) begin
        min <= min + 4'd1;
        min <= 0;
        MatchCount <= MatchCount + 1;
    end
    else if(state == CAL && MinCost > min)begin
        MinCost <= min;
        MatchCount <= 1;
        min <= 0;
    end
    else if(state == CAL && MinCost < min)
        min <= 0;
    
end

// always@(posedge CLK or posedge RST)begin
//     if(RST)begin
//         MatchCount <= 0;
//     end
//     else begin
//         if(state == CAL && MinCost == min)begin
//             MatchCount = MatchCount + 1;
//         end
//     end
// end

//CMP 
always@(*)begin
    casex (cmp)
        7'bxxxxxx1:  idx = 6;  
        7'bxxxxx10:  idx = 5;
        7'bxxxx100:  idx = 4;
        7'bxxx1000:  idx = 3;
        7'bxx10000:  idx = 2;
        7'bx100000:  idx = 1;
        7'b1000000:  idx = 0;
        default: idx = 0;
    endcase

end

//OUTPUT
always @(*) begin
    if(next_state == OUT)
        Valid = 1'b1;
    else 
        Valid = 0;
end

endmodule
