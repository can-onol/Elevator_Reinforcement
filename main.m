clc
clear

handles=[];

o=1;
%% set constants

tic; % start timer to see how long it takes to compute

PLOTTING = true; % if true, display a plot of the car positions each iteration

% which algorithm to test. Either naivePicker or goodPicker.
% The @ sign is needed to create a function handle
 

ITERATIONS = 100; % number of seconds to run through

config.DELTA_T = 0.5; % seconds between updates (smaller means smoother but slower)
config.CALL_FREQUENCY = 0.15; % average number of calls per second (between 0 and 1)
config.NUM_FLOORS = 5;
config.FLOOR_HEIGHT = 3; % m
config.BOARDING_TIME = 5; % time elevator doors stay open for boarding (s)
config.MAX_VELOCITY = 10; % m/s
config.ACCELERATION = 1.5; % m/s^2
config.PLOT_SPEED = 5; % times faster to do the simulation (bigger is faster)


    figure(1);
    ax = gca; % get current axes


%% set variables

passengers = struct();
cars = struct();

heights = zeros(1, 1);

numDroppedOff = 0; % number of passengers successfully dropped off
numPickedUp = 0; % passengers currently in an elevator
numWaiting = 0; % passengers waiting for an elevator to arrive

%1 = config.NUM_CARS;
    cars(1).y = 2 * config.FLOOR_HEIGHT; % position of TOP of car sabitlenebilir
    cars(1).velocity = 0;
    cars(1).doorsOpen = false;
    cars(1).destinations = []; % Next floors this car wants to travel to.
                                  % First number goes first, and so on.
    cars(1).timeRemaining = 0; % how long to wait before it can leave
    
    msg(['Car ', num2str(1), ' at y = ', num2str(cars(1).y)]);


%% run simulation

for it = 1:config.DELTA_T:ITERATIONS
    %% clear the figure so we can put down the next positions
    if PLOTTING && it ~= 1 || it == ITERATIONS
        drawnow; 
        cla(ax, 'reset');

    end
    
   
    
    %% randomly make call
    
    
    if 0 < config.CALL_FREQUENCY * config.DELTA_T && o < 13
        call = makeRandCall(config.NUM_FLOORS);
        numWaiting = numWaiting + 1;
        
        
            o=o+1;
        
        cars(1).destinations = cat(2,cars(1).destinations, call.fromFloor(o));
        % TODO: let pickerAlg change the destination queue
        
        msg(['new call from ', num2str(call.fromFloor(o)*config.FLOOR_HEIGHT),...
            ' to ', num2str(call.toFloor(o)*config.FLOOR_HEIGHT),...
            ', taken by car ', num2str(1)]);
       % msg(['Car scores: ', num2str(scores)]);
        
        % add data to passengers struct array
        passengers(end+1).startTime = it;
        passengers(end).fromFloor = call.fromFloor(o);
        passengers(end).toFloor = call.toFloor(o);
        passengers(end).responder = 1;
        passengers(end).pickedUp = false;
        passengers(end).droppedOff = false;
        
    else
        msg('No call made');
    end
    
    %% update all elevator positions
    %for 1 = 1:config.NUM_CARS
        msg(['CAR ', num2str(1), ':']);
        
        % If the car still has to wait, don't call updateY. Instead,
        % decrement the time the car has to remain waiting
        if cars(1).timeRemaining > 0
            msg(['  Waiting for ', num2str(cars(1).timeRemaining), ' more second(s)']);
            cars(1).timeRemaining = cars(1).timeRemaining - config.DELTA_T;
            
            % if that was the last waiting period, set the doors to close
            if cars(1).timeRemaining == 0
                cars(1).doorsOpen = false;
            end
        elseif ~isempty(cars(1).destinations)
            deltaYs = cars(1).destinations*config.FLOOR_HEIGHT - cars(1).y;
            if deltaYs(1) ~= 0
                if cars(1).velocity == 0
                    % Sort the destinations for a more optimal order of travel,
                    % but only if the car isn't moving. A potential
                    % improvement would be to modify the current
                    % destination if the car can still stop at a closer,
                    % and therefore more efficient, destination.
                    
                    destinationsUp = cars(1).destinations(deltaYs > 0);
                    destinationsDown = cars(1).destinations(deltaYs < 0);
                    
                    % Tiebreaker so we head in the direction of the current
                    % first destination if there are equal calls in both
                    % directions. If the first call is up, add 0.5 to the
                    % length of destinationsUp so it will win if there equal
                    % calls up and down. Otherwise, 0.5 will be subtracted so
                    % destinationsDown will win in a tie.
                    tiebreaker = sign(deltaYs(1))/2;
                   
                
                    if tiebreaker + length(destinationsUp) > length(destinationsDown) % heading up
                        cars(1).destinations = ...
                            [sort(destinationsUp), sort(destinationsDown, 'descend')];
                    else % heading down
                        cars(1).destinations = ...
                            [sort(destinationsDown, 'descend'), sort(destinationsUp)];
                    end
%                     make deltaY with the new first destination
                    deltaY = cars(1).destinations(1)*config.FLOOR_HEIGHT - cars(1).y;
                    
                    cars(1).tLeave = it;
                    cars(1).deltaYLeave = deltaY;
                end
                
                [cars(1).y, cars(1).velocity] = updateY(it, config, cars(1));
                
            end
        end
        msg(['  at y = ', num2str(cars(1).y)]);
        
        
        % if car is stopped at a floor that is a destination
        if cars(1).velocity == 0 &&...
                ismember(cars(1).y, cars(1).destinations * config.FLOOR_HEIGHT)
            msg(['  arrived at y = ', num2str(cars(1).y)]);
            
            % adjust the relevant passenger struct(s)
            % start at 2 because the first is empty
            for ipass = 2:length(passengers)
                % drop passenger off
                if passengers(ipass).pickedUp && ~passengers(ipass).droppedOff
                    if passengers(ipass).toFloor * config.FLOOR_HEIGHT == cars(1).y
                           
                        numDroppedOff = numDroppedOff + 1;
                        numPickedUp = numPickedUp - 1
                        
                        passengers(ipass).droppedOff = true;
                        passengers(ipass).dropOffTime = it;
                        passengers(ipass).totalTime = it - passengers(ipass).startTime;
                        
                        msg(['  dropped off passenger ', num2str(ipass-1),...
                            '. Total waiting time: ', num2str(passengers(ipass).totalTime)]);
                        
                        % add new destination to queue and remove current floor
                        toFiltered = cars(1).destinations ~= passengers(ipass).toFloor;
                        cars(1).destinations = cars(1).destinations(toFiltered);
                        
                        cars(1).timeRemaining = config.BOARDING_TIME;
                        cars(1).doorsOpen = true;
                    end
                elseif ~passengers(ipass).droppedOff % pick passenger up
                    if passengers(ipass).fromFloor * config.FLOOR_HEIGHT == cars(1).y
                            
                        numPickedUp = numPickedUp + 1
                        numWaiting = numWaiting - 1;
                        
                        passengers(ipass).pickedUp = true;
                        passengers(ipass).pickUpTime = it;
                        passengers(ipass).pickUpCar = 1;
                        
                        msg(['  picked up passenger ', num2str(ipass-1)]);
                        
                        % add new destination to queue and remove current floor
                        fromFiltered = cars(1).destinations ~= passengers(ipass).fromFloor;
                        cars(1).destinations = [passengers(ipass).toFloor,...
                            cars(1).destinations(fromFiltered)];
                        
                        cars(1).timeRemaining = config.BOARDING_TIME;
                        cars(1).doorsOpen = true;
                    end
                end
            end % end for
        end
        
        msg(['  destinations: ', num2str(cars(1).destinations * config.FLOOR_HEIGHT)]);
        
        % always update the plot for the last iteration
        if PLOTTING || it == ITERATIONS
            % display each car's position as a rectangle on the plot
            width = 0.5;
            pos = [1 - width/2, cars(1).y - config.FLOOR_HEIGHT,...
                width, config.FLOOR_HEIGHT];
            
            if cars(1).doorsOpen
                faceColor = [.4 .6 .6]; % darker blue
            else
                faceColor = [.65 .85 .9]; % light blue
            end
            
            rectangle(ax, 'Position', pos, 'FaceColor', faceColor);
        end
        heights(1) = cars(1).y;
    
    
    %% plot car destinations
    
    % display every call on the plot to show each car's destination(s)
    if PLOTTING || it == ITERATIONS        
        yyaxis(ax, 'right');
        % on the right y-axis, display floor numbers
        ylim(ax, [0.5, config.NUM_FLOORS + 0.5]);
        hold(ax, 'on');
        
        for ipass = 2:length(passengers)
            pass = passengers(ipass);
            if ~pass.droppedOff
                if ~pass.pickedUp
                    y = pass.fromFloor;
                    if pass.toFloor - pass.fromFloor > 0
                        % call is heading up
                        marker = '^';
                        y = y + 0.25;
                    else % heading down
                        marker = 'v';
                        y = y - 0.25;
                    end
                else
                    marker = 'square';
                    y = pass.toFloor;
                end
                
                plot(ax, pass.responder, y,...
                    'Marker', marker,...
                    'MarkerSize', 10,...
                    'MarkerFaceColor', 'black',...
                    'MarkerEdgeColor', 'none'...
                    );
            end
        end
        
        hold(ax, 'off');
        ax.YTick = 1:config.NUM_FLOORS;
        ylabel(ax, 'Floor number');
        
        yyaxis(ax, 'left');
        axis(ax, [0.5, 1+0.5, 0, config.FLOOR_HEIGHT*config.NUM_FLOORS]);
        ylabel(ax, 'Height (m)');
        xlabel(ax, 'Elevator car number');
        ax.YTick = 0 : config.FLOOR_HEIGHT : config.FLOOR_HEIGHT*config.NUM_FLOORS;
        ax.XTick = 1:1; % force plot to display only integers
        grid(ax, 'on'); % display only y (horizontal) gridlines
        
        %drawnow;
    end
end


%% display statistics

% create an array with only the completed times
numPassengers = length(passengers) - 1;
times = [];
for ipass = 1:numPassengers
    if(passengers(ipass).droppedOff)
        times(end+1) = passengers(ipass).totalTime;
    end
end

% when displaying the histogram, chop off the top and bottom 1% so the
% relevant data is more easily seen.
timesSorted = sort(times);
chop = floor(0.01 * length(times));
timesChopped = timesSorted(chop+1 : end - chop);

msg(' ');
disp('----- END OF RUN -----');
if ~PLOTTING
    disp(['Took ', num2str(toc), ' seconds to compute']);
end
disp(['Iterations: ', num2str(ITERATIONS)]);
disp(['Total passengers: ', num2str(numPassengers)]);
disp(['  Passengers waiting for car: ', num2str(numWaiting)]);
disp(['  Passengers riding elevator: ', num2str(numPickedUp)]);
disp(['  Passengers dropped off:     ', num2str(numDroppedOff)]);
disp('Wait times:');
disp(['   Average:            ', num2str(mean(times))]);
disp(['   Median:             ', num2str(median(times))]);
disp(['   Shortest:           ', num2str(min(times))]);
disp(['   Longest:            ', num2str(max(times))]);
disp(['   Standard deviation: ', num2str(std(times))]);

% if we're running this from the GUI, prepare a table of statistics
if ~isempty(handles)
    handles.tText.String = ['t = ', num2str(ITERATIONS)];
    stats = {
        'Iterations', ITERATIONS;
        'Total passengers', numPassengers;
        'Passengers waiting for car', numWaiting;
        'Passengers riding elevator', numPickedUp;
        'Passengers dropped off', numDroppedOff;
        'Average wait time', mean(times);
        'Median wait time', median(times);
        'Shortest wait time', min(times);
        'Longest wait time', max(times);
        'Standard deviation', std(times)
    };
    if ~PLOTTING
        stats = [stats; {'Time to compute (s)', toc}];
    end
    handles.statsTable.Data = stats;
%     handles.runButton.String = 'Run simulation';
    
    ax = handles.histogramAxes;
else
    figure(2);
    ax = gca;
end

histogram(ax, timesChopped);
title('Histogram of wait times');
xlabel('Wait time (s)');
ylabel('Frequency');

%% msg function
% displays detailed debug messages to the command window. This
% significantly slows running, so set to 0 for more than a few dozen
% iterations
function msg(message)
    if 0
        disp(message);
    end
end


