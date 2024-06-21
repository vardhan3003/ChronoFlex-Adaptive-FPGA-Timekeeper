`timescale 1ns / 1ps
module digital_watch(input clk, reset, start_stop, mode, edit_shift, inc, output [0:6] seg,output [3:0] digit,output reg shift_conf, mode_conf,output reg [2:0] mode_value);

reg edit_place;

reg [5:0] seconds,minutes;
reg [4:0] hours;

reg [5:0] seconds_temp=0,minutes_temp=0;
reg [4:0] hours_temp=0;

wire [3:0] ones,tens,hundreds,thousands;

//initial values
initial edit_place=1;
initial seconds=0;
initial minutes=0;
initial hours=0;

//Confirmation LED's
initial mode_value=3'b100;
initial shift_conf=0;
initial mode_conf=0;

//Modes
parameter clock = 0;
parameter edit =1;
parameter timer =2; 
//Timer_Modes
parameter tm_stop=0;
parameter tm_start=1;

reg tm_state=tm_stop, tm_nstate=tm_stop;
reg [1:0] state = clock, nstate = clock;   
reg trigger=0;

reg sclk=0;
integer count=0;
reg[31:0] scount=0;
 
digits digits_1(clk,reset,state,seconds,minutes,hours,ones,tens,hundreds,thousands);
seven_seg seven_seg_1(clk,reset,state,edit_place,ones,tens,hundreds,thousands,seg,digit);

 //Slower Clock
 always @(posedge clk) begin
     if(count==49_999_999) begin //
         count<=0;
         sclk<=~sclk;
     end 
     else count<=count+1;
 end
 
 //Original Clock Run
 always @(posedge clk) begin
	 if(state==edit) begin
			hours_temp<=hours;
			minutes_temp<=minutes;
			seconds_temp<=seconds;
	end
	else if(sclk==1'b1 && count==0) begin  
		seconds_temp<=seconds_temp + 1; 
		if(seconds_temp==59) begin 
			seconds_temp<=0;  
			minutes_temp<=minutes_temp + 1;
			if(minutes_temp==59) begin 
				minutes_temp<=0; 
				hours_temp<=hours_temp + 1; 
			   if(hours_temp==23) begin  
					hours_temp<=0; 
				end 
			end
		end     
	end
	
 end
 
 //Modes_Run
always @(posedge clk) begin
    if(state==clock)
        mode_value<=3'b100;
     else if(state==edit)
        mode_value<=3'b010;
    else if(state==timer)
        mode_value<=3'b001;
end
 
//Different Modes
always @(posedge(clk) ) begin
	case(state)
	clock: begin
		if(mode) begin
            if(scount<15_000_000) //25_000_000
                scount<=scount+1;
            else begin
                if(mode && scount==15_000_000) begin //25_000_000
					nstate<=edit;
                    mode_conf<=1;
                    scount<=scount+1;
                end
                else begin
					nstate<=nstate;
                    mode_conf<=1;
                    scount<=scount+1;
                end
            end
        end
		else begin
		    scount<=0;
			state<=nstate;
			mode_conf<=0;
			hours<=hours_temp;
			minutes<=minutes_temp;
			seconds<=seconds_temp;
		end
	end
	
	edit: begin
			if(reset) begin 
				if(scount<15_000_000) //25_000_000
					scount<=scount+1;
				else begin
					if(reset && scount==15_000_000) begin //25_000_000
						seconds<=0;
						minutes<=0;
						hours<=0;
						scount<=scount+1;
					end
					else begin
						scount<=scount+1;
					end
				end
			end
			
			else if(mode) begin
				if(scount<15_000_000) //25_000_000
					scount<=scount+1;
				else begin
					if(mode && scount==15_000_000) begin //25_000_000 
						nstate<=timer;
						trigger<=1;
						mode_conf<=1;
						scount<=scount+1;
					end
					else begin
						nstate<=nstate;
						mode_conf<=1;
						scount<=scount+1;
					end
				end
			end
			
			else if(edit_shift) begin
				if(scount<15_000_000) //25_000_000
					scount<=scount+1;
				else begin
					if(edit_shift && scount==15_000_000) begin //25_000_000
						scount<=scount+1;
						shift_conf<=1;
						edit_place<=~edit_place;
					end
					else begin
						shift_conf<=1;
						scount<=scount+1;
						edit_place<=edit_place;
					end
				end
			end
			
			else if(inc) begin
				if(scount<15_000_000) //25_000_000
					scount<=scount+1;
				else begin
					if(inc && scount==15_000_000) begin //25_000_000
						
						if(edit_place) begin
							if(hours<23)
								hours<=hours+1;
							else
								hours<=0;
						end 
						else if(~edit_place) begin
							if(minutes<59)
								minutes<=minutes+1;
							else
								minutes<=0;
						end
						scount<=scount+1;
					end
					else begin
						scount<=scount+1;
					end
				end
			end
			
			else begin
				scount<=0;
				shift_conf<=0;
				mode_conf<=0;
				state<=nstate;
			end
	   end
	
	timer: begin
		if(trigger) begin
			minutes<=0;
			seconds<=0;
			trigger<=0;
		end
		case(tm_state)
			tm_stop: begin
				if(reset == 1'b1) begin 
					if(scount<15_000_000) //25_000_000
						scount<=scount+1;
					else begin
						if(reset && scount==15_000_000) begin //25_000_000
							seconds<=0;
							minutes<=0;
							scount<=scount+1;
						end
						else begin
							seconds<=seconds;
							minutes<=minutes;
							scount<=scount+1;
						end
					end
				end
				else if(mode) begin
					if(scount<15_000_000) //25_000_000
						scount<=scount+1;
					else begin
						if(mode && scount==15_000_000) begin  //25_000_000
							nstate<=clock;
							mode_conf<=1;
							scount<=scount+1;
						end
						else begin
							nstate<=nstate;
							mode_conf<=1;
							scount<=scount+1;
						end
					end
				end
				else if(inc) begin
					if(scount<15_000_000) //25_000_000
						scount<=scount+1;
					else begin
						if(inc && scount==15_000_000) begin //25_000_000
							
							if(edit_place) begin
								if(minutes<60)
									minutes<=minutes+1;
								else
									minutes<=0;
							end 
							else begin
								if(seconds<59)
									seconds<=seconds+1;
								else
									seconds<=0;
							end
							scount<=scount+1;
						end
						else begin
							scount<=scount+1;
							minutes<=minutes;
							seconds<=seconds;
						end
					end
				end
				else if(edit_shift) begin
					if(scount<15_000_000) //25_000_000
						scount<=scount+1;
					else begin
						if(edit_shift && scount==15_000_000) begin //25_000_000
							scount<=scount+1;
							shift_conf<=1;
							edit_place<=~edit_place;
						end
						else begin
							shift_conf<=1;
							edit_place<=edit_place;
							scount<=scount+1;
						end
					end
				end
				else if(start_stop) begin
					if(scount<15_000_000) //25_000_000
						scount<=scount+1;
					else begin
						if(start_stop && scount==15_000_000) begin //25_000_000
							tm_nstate<=tm_start;
							scount<=scount+1;
						end
						else begin
							tm_nstate<=tm_nstate;
							scount<=scount+1;
						end
					end
				end
				else begin
					mode_conf<=0;
					shift_conf<=0;
					scount<=0;
					state<=nstate;
					tm_state<=tm_nstate;
					
				end
			end
			tm_start: begin
				if(start_stop) begin
					if(scount<15_000_000) //25_000_000
						scount<=scount+1;
					else begin
						if(start_stop && scount==15_000_000) begin //25_000_000
							tm_nstate<=tm_stop;
							scount<=scount+1;
						end
						else begin
							tm_nstate<=tm_nstate;
							scount<=scount+1;
						end
					end
				end
				else begin
					scount<=0;
					tm_state<=tm_nstate;
					if(sclk==1'b1 && count==0 && tm_nstate==tm_start) begin  
						if(minutes>0) begin
							if(seconds>0) 
								seconds<=seconds-1;
							else begin
								minutes<=minutes-1;
								seconds<=6'd59;
							end
						end
						else begin
							if(seconds==0) begin
								seconds<=seconds;
								minutes<=minutes;
								tm_state<=tm_stop;
							end
							else
								seconds<=seconds-1;
						end		
					end
				end
			end
			default: begin
				tm_state<=tm_stop;
				seconds<=seconds;
				minutes<=minutes;
			end
		endcase
		end
		default: begin
			state<=clock;
			seconds<=seconds;
			minutes<=minutes;
			hours<=hours;
		end
	endcase
end
endmodule