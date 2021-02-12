classdef ElevatorEnvironment < rl.env.MATLABEnvironment
    %MYENVIRONMENT: Template for defining custom environment in MATLAB.    
    
    %% Properties (set properties' attributes accordingly)
    properties
%         % Specify and initialize environment's necessary properties    
%         % Acceleration due to gravity in m/s^2
%         Gravity = 9.8
%         
%         % Mass of the cart
%         CartMass = 1.0
%         
%         % Mass of the pole
%         PoleMass = 0.1
%         
%         % Half the length of the pole
%         HalfPoleLength = 0.5
%         
%         % Max Force the input can apply
%         MaxForce = 10
               
        % Sample time
        %Ts = 1 %CHECK
        
        % Angle at which to fail the episode (radians)
        %PassengerThreshold = 0;
        
        % Distance at which to fail the episode
        
        
%         Reward each time step the cart-pole is balanced
%         RewardForNotFalling = 10
%         
%         Penalty when the cart-pole fails to balance
%         PenaltyForFalling = -10 
    end
    
    properties
        % Initialize system state [x,dx,theta,dtheta]'
        State = zeros(23,1);
    end
    
    properties(Access = protected)
        % Initialize internal flag to indicate episode termination
        IsDone = false        
    end

    %% Necessary Methods
    methods              
        % Contructor method creates an instance of the environment
        % Change class name and constructor name accordingly
        function this = ElevatorEnvironment()
            Obs_span=[1:23];
            % Initialize Observation settings
            ObservationInfo = rlNumericSpec([23 1]);
            ObservationInfo.Name = 'Possibilties';
            
            
            % Initialize Action settings   
            ActionInfo = rlFiniteSetSpec([-1 1]);
            ActionInfo.Name = 'CartPole Action';
            
            % The following line implements built-in functions of RL env
            this = this@rl.env.MATLABEnvironment(ObservationInfo,ActionInfo);
            
            % Initialize property values and pre-compute necessary values
            
        end
        
        % Apply system dynamics and simulates the environment with the 
        % given action for one step.
        function [Observation,Reward,IsDone,LoggedSignals] = step(this,Action)
            LoggedSignals = [];
            
                       
            


            state_output=bi2de([this.State(1),this.State(2),this.State(3),this.State(4),...
                this.State(5),this.State(6),this.State(7),this.State(8),...
                this.State(9),this.State(10),this.State(11),this.State(12),...
                this.State(13),this.State(14),this.State(15),this.State(16),...
                this.State(17),this.State(18),this.State(19),this.State(20),...
                this.State(21),this.State(22),this.State(23)]);
            
            [next_state_dec,r] = model(state_output,Action,this);
            next_state_bin=de2bi(next_state_dec,23);
            % Euler integration
            Observation = next_state_bin;

            % Update system states
            this.State = Observation;
            
            % Check terminal condition
            X = mod(next_state_dec,2^20);
            
            IsDone = X == 0;
            this.IsDone = IsDone;
            
            % Get reward
            Reward = r;
            
            % (optional) use notifyEnvUpdated to signal that the 
            % environment has been updated (e.g. to update visualization)
            notifyEnvUpdated(this);
        end
        
        % Reset environment to initial state and output initial observation
        function InitialObservation = reset(this)
          
            
            InitialObservation = (de2bi(randi(2^20*5),23));
            this.State = InitialObservation;
            
            % (optional) use notifyEnvUpdated to signal that the 
            % environment has been updated (e.g. to update visualization)
            notifyEnvUpdated(this);
        end
    end
    %% Optional Methods (set methods' attributes accordingly)
    methods   
        function [next_state,r] = model(x,u,this)
r=0;
d=de2bi(x,23);
[c,elevator_floor]=converter(d,this);

s=find(1==c(elevator_floor,:));

if elevator_floor==5 && u==1
    next_state=x;
    r=-150;
elseif  elevator_floor==1 && u==-1
    next_state=x;
    r=-150;
else
  
    if u==1
      
            [reward,c,elevator_floor]=elevatorup(c,elevator_floor,s,this);
            r=r+reward;
        
    elseif u==-1
        
     
            [reward,c,elevator_floor]=elevatordown(c,elevator_floor,s,this);
            r=r+reward;
        
    end
    
    if sum(sum(c))==0
    r=r+500;
end
    next_state=reverse_converter(c,elevator_floor,this);
    
    for i=1:5
        for k=1:5
            r=r+(1-((i-k)^2)*c(i,k));
            if c(i,k)
                if elevator_floor == i
                    r=r+2;
                end
            end
            
        end
    end
    
end

end
function [c,elevator_floor]=converter(e,this)
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

function [state_output]=reverse_converter(c_rev,elevator_floor_rev,this)
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
function [reward,c,elevator_floor]=elevatordown(c,elevator_floor,s,this)
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
        reward=reward+80;
    end
end
end
function [reward,c,elevator_floor]=elevatorup(c,elevator_floor,s,this)
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
        reward=reward+80;
    end
end
end

        % Helper methods to create the environment
        % Discrete force 1 or 2
%         function force = getForce(this,action)
%             if ~ismember(action,this.ActionInfo.Elements)
%                 error('Action must be %g for going left and %g for going right.',-this.MaxForce,this.MaxForce);
%             end
%             force = action;           
%         end
%         % update the action info based on max force
%         function updateActionInfo(this)
%             this.ActionInfo.Elements = this.MaxForce*[-1 1];
%         end
        
        % Reward function
%         function Reward = getReward(this)
%             if ~this.IsDone
%                 Reward = this.RewardForNotFalling;
%             else
%                 Reward = this.PenaltyForFalling;
%             end          
%         end
        
        % (optional) Visualization method
%         function plot(this)
%             % Initiate the visualization
%             
%             % Update the visualization
%             envUpdatedCallback(this)
%         end
        
        % (optional) Properties validation through set methods
%         function set.State(this,state)
%             validateattributes(state,{'numeric'},{'finite','real','vector','numel',4},'','State');
%             this.State = double(state(:));
%             notifyEnvUpdated(this);
%         end

%         function set.Gravity(this,val)
%             validateattributes(val,{'numeric'},{'finite','real','positive','scalar'},'','Gravity');
%             this.Gravity = val;
%         end
%         function set.CartMass(this,val)
%             validateattributes(val,{'numeric'},{'finite','real','positive','scalar'},'','CartMass');
%             this.CartMass = val;
%         end
%         function set.PoleMass(this,val)
%             validateattributes(val,{'numeric'},{'finite','real','positive','scalar'},'','PoleMass');
%             this.PoleMass = val;
%         end
%         function set.MaxForce(this,val)
%             validateattributes(val,{'numeric'},{'finite','real','positive','scalar'},'','MaxForce');
%             this.MaxForce = val;
%             updateActionInfo(this);
%         end
%         function set.Ts(this,val)
%             validateattributes(val,{'numeric'},{'finite','real','positive','scalar'},'','Ts');
%             this.Ts = val;
%         end
%         function set.AngleThreshold(this,val)
%             validateattributes(val,{'numeric'},{'finite','real','positive','scalar'},'','AngleThreshold');
%             this.AngleThreshold = val;
%         end
%         function set.DisplacementThreshold(this,val)
%             validateattributes(val,{'numeric'},{'finite','real','positive','scalar'},'','DisplacementThreshold');
%             this.DisplacementThreshold = val;
%         end
%         function set.RewardForNotFalling(this,val)
%             validateattributes(val,{'numeric'},{'real','finite','scalar'},'','RewardForNotFalling');
%             this.RewardForNotFalling = val;
%         end
%         function set.PenaltyForFalling(this,val)
%             validateattributes(val,{'numeric'},{'real','finite','scalar'},'','PenaltyForFalling');
%             this.PenaltyForFalling = val;
%         end
    end
    
    methods (Access = protected)
        % (optional) update visualization everytime the environment is updated 
        % (notifyEnvUpdated is called)
        function envUpdatedCallback(this)
        end
    end
end

     