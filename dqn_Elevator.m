clc
clear
env = ElevatorEnvironment;

rng(0)




statePath = [
    imageInputLayer([23 1 1],'Normalization','none','Name','state')
    fullyConnectedLayer(24,'Name','CriticStateFC1')
    reluLayer('Name','CriticRelu1')
    fullyConnectedLayer(24,'Name','CriticStateFC2')];
actionPath = [
    imageInputLayer([1 1 1],'Normalization','none','Name','action')
    fullyConnectedLayer(24,'Name','CriticActionFC1')];
commonPath = [
    additionLayer(2,'Name','add')
    reluLayer('Name','CriticCommonRelu')
    fullyConnectedLayer(1,'Name','output')];
criticNetwork = layerGraph(statePath);
criticNetwork = addLayers(criticNetwork, actionPath);
criticNetwork = addLayers(criticNetwork, commonPath);    
criticNetwork = connectLayers(criticNetwork,'CriticStateFC2','add/in1');
criticNetwork = connectLayers(criticNetwork,'CriticActionFC1','add/in2');


% figure
% plot(criticNetwork)


criticOpts = rlRepresentationOptions('LearnRate',0.01,'GradientThreshold',1);

obsInfo = getObservationInfo(env);
actInfo = getActionInfo(env);
critic = rlQValueRepresentation(criticNetwork,obsInfo,actInfo,'Observation',{'state'},'Action',{'action'},criticOpts);

agentOpts = rlDQNAgentOptions(...
    'UseDoubleDQN',false, ...  
    'TargetUpdateMethod',"periodic", ...
    'TargetUpdateFrequency',4, ...   
    'ExperienceBufferLength',100000, ...
    'DiscountFactor',0.99, ...
    'MiniBatchSize',256);
opt.EpsilonGreedyExploration.Epsilon = 0.98;

agent = rlDQNAgent(critic,agentOpts);

trainOpts = rlTrainingOptions(...
    'MaxEpisodes', 10000, ...
    'MaxStepsPerEpisode', 20, ...
    'Verbose', false, ...
    'Plots','training-progress',...
    'StopTrainingCriteria','AverageReward',...
    'StopTrainingValue',15000,...
    'SaveAgentCriteria','AverageReward',...
    'SaveAgentValue',5500); 


doTraining = true;
if doTraining    
    % Train the agent.
    trainingStats = train(agent,env,trainOpts);
else
    % Load pretrained agent for the example.
    load('savedAgents\Agent138.mat','saved_agent');
    agent=saved_agent;
end

%validateEnvironment(env)
simOptions = rlSimulationOptions('MaxSteps',20);
experience = sim(env,agent,simOptions);
% totalReward = sum(experience.Reward)
Valid_actions=experience.Action.CartPoleAction.Data;
Valid_observations=experience.Observation.Possibilties.Data;
