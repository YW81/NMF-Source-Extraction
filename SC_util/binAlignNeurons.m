function [binData,trialInfo] = binAlignNeurons(neurData, syncObj)

%% Binning Parameters
% For now these are set to default values
posBins = linspace(5,205,31); %Edges for 30 spatial bins
posBins(1)=0;
preTrialShifts = -3:-1;
postTrialShifts = 0:23;

trialInfo.posBins = posBins;
trialInfo.preTrialShifts = preTrialShifts;
trialInfo.postTrialShifts = postTrialShifts;
%% Create trial info structure
trialInfo.missingTrials = union(find(isnan(syncObj.verm2frame(syncObj.trialStarts))),find(isnan(syncObj.verm2frame(syncObj.trialChoices))));
nTrials = min(length(syncObj.trialStarts),length(syncObj.trialChoices));
trialInfo.validTrials = setdiff(1:nTrials,trialInfo.missingTrials);
trialInfo.worldVec = syncObj.tWorld(trialInfo.validTrials);

trialInfo.wTrials = find(mod(trialInfo.worldVec,2)==1); %white cue
trialInfo.bTrials = find(mod(trialInfo.worldVec,2)==0); %black cue
trialInfo.kTrials = find(trialInfo.worldVec<5);         %checker trial
trialInfo.nTrials = find(trialInfo.worldVec>=5);        %no checker trial
trialInfo.rTrials = find(mod(trialInfo.worldVec,4)<2);  %left chamber
trialInfo.lTrials = find(mod(trialInfo.worldVec,4)>=2); %right chamber
trialInfo.cTrials = find(syncObj.tReward(trialInfo.validTrials) == 1); %Correct Trials
trialInfo.iTrials = find(syncObj.tReward(trialInfo.validTrials) == 0); %Incorrect Trials

%%
load(syncObj.vrFile),

%%
vT = trialInfo.validTrials;
posData = nan(size(neurData,1),length(posBins)-1,length(vT));
preData = nan(size(neurData,1),length(preTrialShifts),length(vT));
postData = nan(size(neurData,1),length(postTrialShifts),length(vT));

for iTrial = 1:length(vT)
    nTrial = vT(iTrial);
    trialOffset = syncObj.trialStarts(nTrial)-1;
    trialData = sessionData(:,syncObj.trialStarts(nTrial):syncObj.trialChoices(nTrial));
    
    for posBin = 1:length(posBins)-1
        binInd = find(trialData(6,:)>posBins(posBin) & trialData(6,:)<= posBins(posBin+1));
        frameInds = ceil(syncObj.verm2frame(binInd + trialOffset)/5);
        posData(:,posBin,iTrial) = mean(neurData(:,frameInds),2);
    end
    
    preData(:,:,iTrial) = neurData(:,preTrialShifts+ceil(syncObj.verm2frame(syncObj.trialStarts(nTrial))/5));
    postData(:,:,iTrial) = neurData(:,postTrialShifts+ceil(syncObj.verm2frame(syncObj.trialChoices(nTrial))/5));
end

binData = cat(2,preData,posData,postData);
    