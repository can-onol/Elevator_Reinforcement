clc
clear
C=zeros(5,5);



states=zeros(1,(2^20)*5);

for i=1:(2^20)*5
    states(i)=i-1;
end

b=de2bi(states);


state_index = 1420009;

inside_elevator = zeros(5,1);

sum_reward=0;
end_of_episode=0;
history = [];
passenger_history = [];
reward =0;

[c,elevator_floor]=converter(b,state_index);

[reward,history,passenger_history] = search(state_index,b,0,inside_elevator);





function [reward,history,passenger_history]=search(state_index,b,index,inside_elevator)

actions=[-1 1];
[c,elevator_floor]=converter(b,state_index);

elevator_array = zeros(5,1);

r=rand;

if (sum(sum(c))+sum(inside_elevator)) == 0
    reward = 0;
    history = [];
    passenger_history = [];
    return;
end

if index == 12
    reward = 1000;
    history = [];
    passenger_history = [];
    return;
end



action_index=2;
 % choose 1 action randomly (uniform random distribution)

[next_state_up,next_reward,inside_elevator_up] = model((state_index-1),actions(action_index),b,state_index,inside_elevator);

action_index=1;
 % choose 1 action randomly (uniform random distribution)

[next_state_down,next_reward,inside_elevator_down] = model((state_index-1) ,actions(action_index),b,state_index,inside_elevator);



[reward_up,history_up,passenger_history_up] = search(next_state_up+1,b,index+1,inside_elevator_up);
[reward_down,history_down,passenger_history_down] = search(next_state_down+1,b,index+1,inside_elevator_down);



if reward_up > reward_down
    [c,elevator_floor]=converter(b,next_state_down+1);
    reward = reward_down;
    inside_elevator = inside_elevator_down;
    history = [1,history_down];
    passenger_history = [(sum(sum(c))+sum(inside_elevator)),passenger_history_down];
    
else
    [c,elevator_floor]=converter(b,next_state_up+1);
    reward = reward_up;
    inside_elevator = inside_elevator_up;
    history = [2,history_up];
    passenger_history = [(sum(sum(c))+sum(inside_elevator)),passenger_history_up];
    
end

reward = reward + (sum(sum(c))+sum(inside_elevator));
    




%disp(qtable);  % display Q in each level
%state_index=next_state_index;
%if mod(state_index,2^20)==1
%    state_index=randi(2^20*5);
%end
% state_index=randi(192)
end



function [next_state,r,inside_elevator] = model(x,u,d,state_index,inside_elevator)

r=0;
[c,elevator_floor]=converter(d,state_index);
s=find(1==c(elevator_floor,:));
check_pass_1=find(1==c(1,:));
check_pass_2=find(1==c(2,:));
check_pass_3=find(1==c(3,:));
check_pass_4=find(1==c(4,:));
check_pass_5=find(1==c(5,:));
check_pass=[check_pass_1,check_pass_2,check_pass_3,check_pass_4,check_pass_5];
if elevator_floor==5 && u==1
    next_state=x;
    
elseif  elevator_floor==1 && u==-1
    next_state=x;
    
else
    if u==1
        if isempty(check_pass)
            next_state=x;
        else
            [c,elevator_floor,inside_elevator]=elevatorup(c,elevator_floor,s,inside_elevator);
        end
    elseif u==-1
        
        if isempty(check_pass)
            next_state=x;
        else
            [c,elevator_floor,inside_elevator]=elevatordown(c,elevator_floor,s,inside_elevator);
        end
    end
    next_state=reverse_converter(c,elevator_floor);
end
end
function [c,elevator_floor]=converter(e,st)
c(1,2) =e(st,1);
c(1,3) =e(st,2);
c(1,4) =e(st,3);
c(1,5) =e(st,4);
c(2,1) =e(st,5);
c(2,3) =e(st,6);
c(2,4) =e(st,7);
c(2,5) =e(st,8);
c(3,1) =e(st,9);
c(3,2) =e(st,10);
c(3,4) =e(st,11);
c(3,5) =e(st,12);
c(4,1) =e(st,13);
c(4,2) =e(st,14);
c(4,3) =e(st,15);
c(4,5) =e(st,16);
c(5,1) =e(st,17);
c(5,2) =e(st,18);
c(5,3) =e(st,19);
c(5,4) =e(st,20);
elevator_floor=1+e(st,21)+2*e(st,22)+4*e(st,23);
end

function [state_output]=reverse_converter(c_rev,elevator_floor_rev)
a=[0,0,0];
if elevator_floor_rev==5
    a=[0,0,1];
elseif elevator_floor_rev==4
    a=[1,1,0];
elseif elevator_floor_rev==3
    a=[0,1,0];
elseif elevator_floor_rev==2
    a=[1,0,0];
elseif elevator_floor_rev==1
    a=[0,0,0];
    
end
state_output=bi2de([c_rev(1,2),c_rev(1,3),c_rev(1,4),c_rev(1,5),...
    c_rev(2,1),c_rev(2,3),c_rev(2,4),c_rev(2,5),...
    c_rev(3,1),c_rev(3,2),c_rev(3,4),c_rev(3,5),...
    c_rev(4,1),c_rev(4,2),c_rev(4,3),c_rev(4,5),...
    c_rev(5,1),c_rev(5,2),c_rev(5,3),c_rev(5,4),a]);

end
function [c,elevator_floor,inside_elevator]=elevatordown(c,elevator_floor,s,inside_elevator)
dropped_passenger=0;
for i=1:length(s)
    if s(i)<elevator_floor
        c(elevator_floor,s(i)) = 0;
        if c(elevator_floor-1,s(i)) == 1
        c(elevator_floor-1,s(i)) = 1;
        inside_elevator(s(i))=inside_elevator(s(i))+1;
        else
            c(elevator_floor-1,s(i)) = 1;
        end
        
    end
end
elevator_floor=elevator_floor-1;
for i=1:length(c)
    if c(i,i)==1
        c(i,i)=0;
        inside_elevator(i)=0;
    end
end
end
function [c,elevator_floor,inside_elevator]=elevatorup(c,elevator_floor,s,inside_elevator)

for i=1:length(s)
    if s(i)>elevator_floor
        c(elevator_floor,s(i)) = 0;
        
        if c(elevator_floor+1,s(i)) == 1
            inside_elevator(s(i))=inside_elevator(s(i))+1;
        else
            c(elevator_floor+1,s(i)) = 1;
        end
    end
end
elevator_floor=elevator_floor+1;
for i=1:length(c)
    if c(i,i)==1
        c(i,i)=0;
        
        inside_elevator(i)=0;
    end
end
end





