Passengers_brute_force=[13 13 12 10 8 6 5 4 2 0 0 0 0];

Passengers_q_learning=[13 12 11 10 9 7 6 5 4 2 1 1 0];
Passengers_rule_based=[13 13 12 10 8 7 7 5 4 4 2 0 0];
time=[0:1:length(Passengers_q_learning)-1]
%Passengers_dqn[]
figure(1)
plot(time,...
    Passengers_q_learning,time,Passengers_rule_based,time,Passengers_brute_force)
title('Comparison')
xlabel('Time') 
ylabel('Total Passenger') 
legend('Q learning','Rule Based','Brute Force')
a=0;
for i=1:13
    
waiting_time_brute_force(i)=Passengers_brute_force(i)+a;
a=waiting_time_brute_force(i);
end
a=0;
for i=1:13
    
waiting_time_rule_based(i)=Passengers_rule_based(i)+a;
a=waiting_time_rule_based(i);
end
a=0;
for i=1:13
    
waiting_time_q_learning(i)=Passengers_q_learning(i)+a;
a=waiting_time_q_learning(i);
end
figure(2)
plot(time,...
    waiting_time_q_learning,time,waiting_time_rule_based,time,waiting_time_brute_force)
title('Comparison')
xlabel('Time') 
ylabel('Total Waiting Time') 
legend('Q learning','Rule Based','Brute Force')
