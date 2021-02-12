clc
clear





Elevator_floor=5;
states=zeros(1,(2^20)*5);

for i=1:(2^20)*5
    states(i)=i-1;
end

b=de2bi(states);

actions=[-1 1];
qtable=zeros(length(states),length(actions));
gamma = 0.5;
alpha = 0.5;
epsilon = 0.9;
K = 10000000;
state_index = 192;
for it=1:K
    disp(['iteration: ' num2str(it)]);
    r=rand; % get 1 uniform random number
    x=sum(r>=cumsum([0, 1-epsilon, epsilon])); % check it to be in which probability area
    
    % choose either explore or exploit
    if x == 1   % exploit
        [~,umax]=max(qtable(state_index,:));
        current_action = actions(umax);
    else        % explore
        current_action=datasample(actions,1); % choose 1 action randomly (uniform random distribution)
    end
    action_index = find(actions==current_action); % id of the chosen action
    % observe the next state and next reward ** there is no reward matrix
    [next_state,next_reward] = model(states(state_index),actions(action_index),b,state_index);
    next_state_index = find(states==next_state);  % id of the next state
    % print the results in each iteration
    disp(['current state : ' num2str(states(state_index)) ' next state : ' num2str(states(next_state_index)) ' taken action : ' num2str(actions(action_index))]);
    %disp([' next reward : ' num2str(next_reward)]);
    disp([' current action : ' num2str(actions(action_index))]);
    % update the Q matrix using the Q-learning rule
    qtable(state_index,action_index) = qtable(state_index,action_index) + alpha * (next_reward + gamma* max(qtable(next_state_index,:)) - qtable(state_index,action_index));
    
    
    %disp(qtable);  % display Q in each level
    state_index=next_state_index;
    if mod(state_index,2^20)==1
        state_index=randi(2^20*5);
    end
    % state_index=randi(192)
end

function [next_state,r] = model(x,u,d,state_index)
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
    r=-150;
elseif  elevator_floor==1 && u==-1
    next_state=x;
    r=-150;
else
    
    
    
    
    
    if u==1
        if isempty(check_pass)
            next_state=x;
            r=250;
        else
            [reward,c,elevator_floor]=elevatorup(c,elevator_floor,s);
            r=r+reward;
        end
    elseif u==-1
        
        if isempty(check_pass)
            next_state=x;
            r=250;
        else
            [reward,c,elevator_floor]=elevatordown(c,elevator_floor,s);
            r=r+reward;
        end
    end
    
    
    next_state=reverse_converter(c,elevator_floor);
    
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
function [reward,c,elevator_floor]=elevatordown(c,elevator_floor,s)
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





