function call = makeRandCall(NUM_FLOORS)
   
    
    call = struct();
    
    call.fromFloor= [1 1 1 1 2 3 3 3 4 4 4 5 5 0];

    call.toFloor =  [2 3 4 5 3 1 4 5 1 2 3 2 4 1];
    
    % make sure toFloor isn't the same as fromFloor
    while call.toFloor == call.fromFloor
        call.toFloor = randi(NUM_FLOORS);
    end

 
end




