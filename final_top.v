module top(input clk, reset, start_stop, mode, edit_shift, inc, output reg buzzer, output [0:6] seg,output [3:0] digit,output reg [4:0] mode_value);

reg [1:0] edit_place;

reg [5:0] seconds,minutes;
reg [4:0] hours;

//clock handles
reg [5:0] seconds_temp=0,minutes_temp=0;
reg [4:0] hours_temp=0;

//Adding alaram Handles
reg [5:0] al_minutes;
reg [4:0] al_hours;

//Adding date handles
reg [4:0] day_temp=1;
reg [3:0] month_temp=1;

wire [3:0] ones,tens,hundreds,thousands;

//initial values
initial edit_place=0;
initial seconds=0;
initial minutes=0;
initial hours=0;

//Initializing Alaram needs
initial al_minutes=0;
initial al_hours=0;
initial buzzer=0;

//Confirmation LED's
initial mode_value=5'b10000;

//Modes
parameter clock = 0;
parameter edit =1;
parameter timer =2; 
parameter stop_watch=3;
parameter alarm=4;

//Timer_States
parameter tm_stop=0;
parameter tm_start=1;
//Stop_Watch States
parameter sw_stop=0;
parameter sw_start=1;
//Alaram States 
parameter alarm_off=0;
parameter alarm_on=1;

reg tm_state=tm_stop, tm_nstate=tm_stop;
reg sw_state=sw_stop, sw_nstate=sw_stop;
reg alarm_state=alarm_off, alarm_nstate=alarm_off;


reg [2:0] state = clock, nstate = clock;   
reg trigger=0;

reg sclk=0;
integer count=0;
reg[31:0] scount=0;
reg[31:0] a_count=0;
 
digits digits_1(clk,reset,state,seconds,minutes,hours,ones,tens,hundreds,thousands);
seven_seg seven_seg_1(clk,reset,state,start_stop,inc,tm_state,sw_state,alarm_state,scount,edit_place,ones,tens,hundreds,thousands,seg,digit);

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
		if(edit_place==0 || edit_place==1) begin
			if (reset==1 && scount==15_000_001) begin
				hours_temp<=hours;
				minutes_temp<=minutes;
				seconds_temp<=seconds;
			end
			else if (inc==1 && scount==15_000_001) begin
				hours_temp<=hours;
				minutes_temp<=minutes;
			end
		end
	end
    
	if(sclk==1'b1 && count==0) begin  
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
	
	//Ringing the alarm
	if(hours_temp==al_hours && minutes_temp==al_minutes && alarm_state==alarm_on) begin
		if(seconds_temp==0)
			buzzer<=1;
		else if(start_stop && buzzer==1) begin
			if(a_count<15_000_000)
				a_count<=a_count + 1;
			else if(start_stop && a_count==15_000_000) begin
				buzzer<=0;
				a_count<=a_count + 1;
			end
			else
				a_count<=a_count + 1;		
		end
		else
			a_count<=0;
	end
	else begin
		a_count<=0;
		buzzer<=0;
	end
 end
 
 //Modes_Run
always @(posedge clk) begin
    if(state==clock)
        mode_value<=5'b10000;
    else if(state==edit)
        mode_value<=5'b01000;
    else if(state==timer)
        mode_value<=5'b00100;
    else if(state==stop_watch)
        mode_value<=5'b00010;
	else if(state==alarm)
        mode_value<=5'b00001;
end

/////////// Date_Run //////////////////////////////
always@(posedge clk) begin
	if(state==edit) begin
		if(edit_place==2 || edit_place==3) begin
			if (reset==1 && scount==15_000_001) begin
				day_temp<=hours;
				month_temp<=minutes;
			end
			else if (inc==1 && scount==15_000_001) begin
				day_temp<=hours;
				month_temp<=minutes;
			end
		end
	end
	
	if(seconds_temp==59 && minutes_temp==59 && hours_temp==23 && sclk==1 && count==49_999_999) begin
		day_temp<=day_temp + 1;
		if(month_temp==2 && day_temp==28) begin
			day_temp<=1;
			month_temp<=month_temp + 1;
		end
		else if(day_temp== (30+(month_temp & 1)^(month_temp>7))) begin 
			day_temp<=1;
			month_temp<=month_temp + 1;
			if(month_temp==12) 
				month_temp<=1;
		end
	end

end


//Different Modes
always @(posedge(clk)) begin
	case(state)
	clock: begin
		if(mode) begin
            if(scount<15_000_000) //25_000_000
                scount<=scount+1;
            else begin
                if(mode && scount==15_000_000) begin //25_000_000
					nstate<=edit;
					trigger<=1;//////////////
                    scount<=scount+1;
                end
                else begin
					nstate<=nstate;
                    scount<=scount+1;
                end
            end
        end
		else if(alarm_state==alarm_on && start_stop) begin
			if(scount<15_000_000)
					scount<=scount + 1;
				else begin
					hours<=al_hours;
					minutes<=al_minutes;
				end
		end
		else if(inc) begin 
			if(scount<15_000_000)
				scount<=scount + 1;
			else begin
				hours<=day_temp;
				minutes<=month_temp;
			end
		end
		else begin
		    scount<=0;
			state<=nstate;
			hours<=hours_temp;
			minutes<=minutes_temp;
			seconds<=seconds_temp;
			alarm_state=alarm_nstate;
		end
	end
	
	edit: begin
		////////////////////
		if(trigger) begin
			edit_place<=0;
			trigger<=0;
		end
		if(reset) begin 
			if(scount<15_000_000) //25_000_000
				scount<=scount+1;
			else begin
				if(reset && scount==15_000_000) begin //25_000_000
					if(edit_place==0 || edit_place==1) begin
						seconds<=0;
						minutes<=0;
						hours<=0;
					end
					else begin
						hours<=1;
						minutes<=1;
					end
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
					scount<=scount+1;
				end
				else begin
					nstate<=nstate;
					scount<=scount+1;
					trigger<=1;
				end
			end
		end
		
		else if(edit_shift) begin
			if(scount<15_000_000) //25_000_000
				scount<=scount+1;
			else begin
				if(edit_shift && scount==15_000_000) begin //25_000_000
					scount<=scount+1;
					if(edit_place<3)
						edit_place<=edit_place + 1;
					else
						edit_place<=0;
				end
				else begin
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
					if(edit_place==0) begin //minutes
						if(minutes<59)
							minutes<=minutes+1;
						else
							minutes<=0;
					end
					else if(edit_place==1) begin //hours
						if(hours<23)
							hours<=hours+1;
						else
							hours<=0;
					end 
					else if(edit_place==2) begin //month
						if(minutes<12)
							minutes<=minutes + 1;
						else
							minutes<=1;
					end
					else if(edit_place==3) begin //day
						if(minutes==2) begin
							if(hours<28)
								hours<=hours + 1;
							else
								hours<=1;
						end
						else begin
							if(hours < (30+(month_temp & 1)^(month_temp>7)))
								hours<=hours + 1;
							else
								hours<=1;
						end
					end
					
					scount<=scount+1;
				end
				else begin
					scount<=scount+1;
				end
			end
		end
		
		else begin
			if(edit_place==0 || edit_place==1) begin
				if(minutes!=minutes_temp || hours!=hours_temp) begin
					minutes<=minutes_temp;
					hours<=hours_temp;
				end
			end
			else begin
				if(minutes!=month_temp || hours!=day_temp) begin
					minutes<=month_temp;
					hours<=day_temp;
				end
			end
			scount<=0;
			if (nstate==timer)
				trigger<=1;
			state<=nstate;
			
		end
	  end
	
	timer: begin
		if(trigger) begin
			edit_place<=0;
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
							nstate<=stop_watch;
							trigger<=1;
							scount<=scount+1;
						end
						else begin
							nstate<=nstate;
							scount<=scount+1;
						end
					end
				end
				else if(inc) begin
					if(scount<15_000_000) //25_000_000
						scount<=scount+1;
					else begin
						if(inc && scount==15_000_000) begin //25_000_000
							
							if(edit_place==1) begin
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
							if(edit_place<1)
								edit_place<=edit_place + 1;
							else
								edit_place<=0;
						end
						else begin
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
					scount<=0;
					if (nstate==stop_watch)
						trigger<=1;
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
							    tm_nstate<=tm_stop;
								seconds<=seconds;
								minutes<=minutes;
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
		stop_watch: begin
			if(trigger) begin
				edit_place<=0;
				minutes<=0;
				seconds<=0;
				trigger<=0;
			end
			case(sw_state)
			sw_stop: begin
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
							nstate<=alarm;
							scount<=scount+1;
						end
						else begin
							nstate<=nstate;
							scount<=scount+1;
							trigger<=1;
						end
					end
				end
				else if(start_stop) begin
					if(scount<15_000_000) //25_000_000
						scount<=scount+1;
					else begin
						if(start_stop && scount==15_000_000) begin //25_000_000
							sw_nstate<=sw_start;
							scount<=scount+1;
						end
						else begin
							sw_nstate<=sw_nstate;
							scount<=scount+1;
						end
					end
				end
				else begin
					scount<=0;
					if (nstate==alarm)
						trigger<=1;
					state<=nstate;
					sw_state<=sw_nstate;
					
				end
			end
			sw_start: begin
				if(start_stop) begin
					if(scount<15_000_000) //25_000_000
						scount<=scount+1;
					else begin
						if(start_stop && scount==15_000_000) begin //25_000_000
							sw_nstate<=sw_stop;
							scount<=scount+1;
						end
						else begin
							sw_nstate<=sw_nstate;
							scount<=scount+1;
						end
					end
				end
				else begin
					scount<=0;
					sw_state<=sw_nstate;
					if(sclk==1'b1 && count==0 && sw_nstate==sw_start) begin  
						if(minutes<59) begin
							if(seconds<59) 
								seconds<=seconds+1;
							else begin
								minutes<=minutes+1;
								seconds<=6'd00;
							end
						end
						else begin
							if(seconds==6'd59) begin
							    sw_nstate<=sw_stop;
								seconds<=seconds;
								minutes<=minutes;
							end
							else
								seconds<=seconds+1;
						end		
					end
				end
			end
			default: begin
				sw_state<=sw_stop;
				seconds<=seconds;
				minutes<=minutes;
			end
			endcase
		end
		alarm: begin
			if(trigger) begin
				edit_place<=0;
				minutes<=al_minutes;
				hours  <=al_hours;
				trigger<=0;
			end
			case(alarm_state)
				alarm_off: begin
					if(mode) begin
						if(scount<15_000_000) //25_000_000
							scount<=scount+1;

						else begin
							if(mode && scount==15_000_000) begin  //25_000_000
								nstate<=clock;
								scount<=scount+1;
							end
							else begin
								nstate<=nstate;
								scount<=scount+1;
							end
						end
					end
					else if(start_stop) begin
						if(scount<15_000_000) //25_000_000
							scount<=scount+1;
						else begin
							if(start_stop && scount==15_000_000) begin //25_000_000
								alarm_nstate<=alarm_on;
								scount<=scount+1;
							end
							else begin
								alarm_nstate<=alarm_nstate;
								scount<=scount+1;
							end
						end
					end
					else if(inc) begin
						if(scount<15_000_000) //25_000_000
							scount<=scount+1;
						else begin
							if(inc && scount==15_000_000) begin //25_000_000
								if(edit_place==1) begin
									if(hours<23)
										hours<=hours+1;
									else
										hours<=0;
								end 
								else if(edit_place==0) begin
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
			
					else if(edit_shift) begin
						if(scount<15_000_000) //25_000_000
							scount<=scount+1;
						else begin
							if(edit_shift && scount==15_000_000) begin //25_000_000
								scount<=scount+1;
								if(edit_place<1)
									edit_place<=edit_place + 1;
								else
									edit_place<=0;
							end
							else begin
								edit_place<=edit_place;
								scount<=scount+1;
							end
						end
					end
					else begin
						scount<=0;
						al_minutes<=minutes;
						al_hours<=hours;
						state<=nstate;
						alarm_state<=alarm_nstate;
					end
				end
				alarm_on: begin
				
					if(mode) begin
						if(scount<15_000_000) //25_000_000
							scount<=scount+1;

						else begin
							if(mode && scount==15_000_000) begin  //25_000_000
								nstate<=clock;
								scount<=scount+1;
							end
							else begin
								nstate<=nstate;
								scount<=scount+1;
							end
						end
					end
					else if(start_stop) begin
						if(scount<15_000_000) //25_000_000
							scount<=scount+1;
						else begin
							if(start_stop && scount==15_000_000) begin //25_000_000
								alarm_nstate<=alarm_off;
								scount<=scount+1;
							end
							else begin
								alarm_nstate<=alarm_nstate;
								scount<=scount+1;
							end
						end
					
					end
					else begin
						scount<=0;
						state<=nstate;
						alarm_state<=alarm_nstate;
					end
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
