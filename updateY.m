function [newY, newV] = updateY(t, config, car)


%% set some useful variables

% deltaY - distance the car has to travel to reach its next destination
deltaY = car.destinations(1)*config.FLOOR_HEIGHT - car.y;

% deltaT - amount of time the car has been moving after this timeframe
deltaT = t - car.tLeave + config.DELTA_T;

% vMaxMag - the maximum velocity the car will reach, determined by its
% total traveling distance
vMaxMag = sqrt(config.ACCELERATION * abs(car.deltaYLeave));

% tHalf - Time when we're halfway to to the destination. Start decelerating
% after this point.
tHalf = vMaxMag / config.ACCELERATION;

%% calculate newV

if deltaT < tHalf
    % accelerate if we're on the first half of progress toward the destination
    newV = config.ACCELERATION * deltaT;
else
    % otherwise, decelerate
    newV = 2 * vMaxMag - config.ACCELERATION * deltaT;
end

% make sure we're not going above the max velocity
if newV > config.MAX_VELOCITY
    newV = config.MAX_VELOCITY;
end

% since we're dealing with magnitudes above, make velocity negative if
% it should be heading down
if deltaY < 0
    newV = -newV;
end

%% calculate newY

% derived from y = y_0 + v_0*t + 1/2 a t^2
% y = y_0 + v_0*t + 1/2 * delta v * t
newY = (car.y) + (car.velocity * config.DELTA_T) + ...
    (0.5 * (newV-car.velocity) * config.DELTA_T);


if car.velocity ~= 0 && deltaT > tHalf && ...
        config.ACCELERATION > abs(car.velocity) / config.DELTA_T > car.velocity^2 / (2*abs(deltaY))
    newV = 0;
    newY = car.destinations(1) * config.FLOOR_HEIGHT;
end
