module JAM (
input CLK,
input RST,
output reg [2:0] W,
output reg [2:0] J,
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
reg [2:0]arr[0:7];
reg [7:0]cnt;
wire [6:0]cmp;
reg [2:0]idx;
reg done;
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
        next_state <= IDLE;
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

//SORTING
always@(posedge CLK or posedge RST)begin
    if(RST)begin
        arr[0] <= 3'd0;
        arr[1] <= 3'd1;
        arr[2] <= 3'd2;
        arr[3] <= 3'd3;
        arr[4] <= 3'd4;
        arr[5] <= 3'd5;
        arr[6] <= 3'd6;
        arr[7] <= 3'd7;
        done <= 0;
        i <= 0;
    end
    else if(state == READ)begin
        if(!done)begin
            if(cnt == 0)begin
                i <= idx +1;
                sw <= idx;
            end
            else begin
                if(arr[i] - arr[sw])begin
                    //swap
                    arr[i] <= arr[sw];
                    arr[sw] <= arr[i];
                    done <= 1;
                end
                else begin
                    i <= i+1;
                end
            end 
        end
    end
    else if(state == CAL)begin
        done <= 0;
    end
    
end

always@(*)begin
    if(state == READ)begin
        W = cnt;
        J = arr[cnt];
    end
end

//DATA INPUT
always@(posedge CLK or posedge RST)begin
    if(RST)begin
        min <= 10'd1023;
        MinCost <= 0;
        MatchCount <= 0;
    end
    else if(state == READ)begin
        if(cnt <= 3'd7)begin
            MinCost <= MinCost + Cost;  
        end 
    end
    else if(state == CAL && MinCost == min) begin
        MatchCount <= MatchCount + 4'd1;
        MinCost <= 0;
    end
    else if(state == CAL && MinCost < min)begin
        min <= MinCost;
        MinCost <= 0;
    end
    else if(state == CAL && MinCost > min)
        MinCost <= 0;
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