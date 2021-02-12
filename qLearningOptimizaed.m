clc
clear

Elevator_floor=5;

state_count = (2^20)*5;

actions=[-1 1];
qtable=zeros(state_count,length(actions));
gamma = 0.5;
alpha = 0.5;

epsilon = 0.9;
K = 1000000000;
state = 192;
for it=1:K
	state =mod(it-1,state_count)+1;

    if mod(it,100000)==0
    disp(['iteration: ' num2str(it)]);
    end

    action_index = 1;
 
    [next_state,next_reward] = model(state,actions(action_index));
   
    
   
    qtable(state,action_index) = qtable(state,action_index) + alpha * (next_reward + gamma* max(qtable(next_state,:)) - qtable(state,action_index));
 
    action_index = 2;

    [next_state,next_reward] = model(state,actions(action_index));
    qtable(state,action_index) = qtable(state,action_index) + alpha * (next_reward + gamma* max(qtable(next_state,:)) - qtable(state,action_index));
   
end

function [next_state,r] = model(state,u)
r=0;
[c,elevator_floor]=converter(state);

if elevator_floor==5 && u==1
    next_state=state;
    r=-150;
elseif  elevator_floor==1 && u==-1
    next_state=state;
    r=-150;
else
    
    if u==1
        
        [reward,c,elevator_floor]=elevatorup(c,elevator_floor);
        r=r+reward;
        
    elseif u==-1
        
        [reward,c,elevator_floor]=elevatordown(c,elevator_floor);
        r=r+reward;
        
    end
    
    next_state=reverse_converter(c,elevator_floor)+1;
    
    for i=1:5
        for k=1:5
            r=r+(10-((i-k)^2)*c(i,k));
            if c(i,k)
                if elevator_floor == i
                    r=r+3;
                end
            end
            
        end
    end
    
end

end
function [c,elevator_floor]=converter(st)
e = de2bi(st-1,23);
c(1,2) =e(1);
c(1,3) =e(2);
c(1,4) =e(3);
c(1,5) =e(4);
c(2,1) =e(5);
c(2,3) =e(6);
c(2,4) =e(7);
c(2,5) =e(8);
c(3,1) =e(9);
c(3,2) =e(10);
c(3,4) =e(11);
c(3,5) =e(12);
c(4,1) =e(13);
c(4,2) =e(14);
c(4,3) =e(15);
c(4,5) =e(16);
c(5,1) =e(17);
c(5,2) =e(18);
c(5,3) =e(19);
c(5,4) =e(20);
elevator_floor=1+e(21)+2*e(22)+4*e(23);
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


function [reward,c,elevator_floor]=elevatordown(c,elevator_floor)
s=find(1==c(elevator_floor,:));
reward=0;
for i=1:length(s)
    if s(i)<elevator_floor
        c(elevator_floor,s(i)) = 0;
        c(elevator_floor-1,s(i)) = 1;
    end
end
elevator_floor=elevator_floor-1;
for i=1:length(c)
    if c(i,i)==1
        c(i,i)=0;
        reward=reward+50;
    end
end
end



function [reward,c,elevator_floor]=elevatorup(c,elevator_floor,s)
s=find(1==c(elevator_floor,:));
reward=0;
for i=1:length(s)
    if s(i)>elevator_floor
        c(elevator_floor,s(i)) = 0;
        c(elevator_floor+1,s(i)) = 1;
    end
end
elevator_floor=elevator_floor+1;
for i=1:length(c)
    if c(i,i)==1
        c(i,i)=0;  
        reward=reward+50;
    end
end
end





