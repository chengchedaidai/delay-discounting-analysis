function postPred = calcPosteriorPredictive(obj)
%calcPosteriorPredictive Calculate various posterior predictive measures.
% Data saved to postPred(p).xxx

% TODO: remove obj being passed in?

display('Calculating posterior predictive measures...')

for p = 1:obj.data.nRealParticipants;
	% get data ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	trialIndOfThisParicipant	= obj.observedData.ID==p;
	responses_predictedMCMC		= obj.mcmc.getPChooseDelayed(trialIndOfThisParicipant);
	responses_actual			= obj.data.getParticipantResponses(p);
	responses_predicted			= obj.mcmc.getParticipantPredictedResponses(trialIndOfThisParicipant);
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	% Calculate metrics
	postPred(p).score							= calcPostPredOverallScore(responses_predicted, responses_actual);
	postPred(p).GOF_distribtion					= calcGoodnessOfFitDistribution(responses_predictedMCMC, responses_actual);
	postPred(p).percentPredictedDistribution	= calcPercentResponsesCorrectlyPredicted(responses_predictedMCMC, responses_actual);
	postPred(p).responses_actual	= responses_actual;
	postPred(p).responses_predicted = responses_predicted;
end
end

function score = calcPostPredOverallScore(responses_predicted, responses_actual)
% Calculate log posterior odds of data under the model and a
% control model where prob of responding is 0.5.
responses_control_model = ones(size(responses_predicted)).*0.5;

score = calcLogOdds(...
	calcDataLikelihood(responses_actual, responses_predicted'),...
	calcDataLikelihood(responses_actual, responses_control_model'));
end

function [score] = calcGoodnessOfFitDistribution(responses_predictedMCMC, responses_actual)
% Expand the participant responses so we can do vectorised calculations below
totalSamples			= size(responses_predictedMCMC,2);
responses_actual		= repmat(responses_actual, [1,totalSamples]);
responses_control_model = ones(size(responses_actual)) .* 0.5;

score = calcLogOdds(...
	calcDataLikelihood(responses_actual, responses_predictedMCMC),...
	calcDataLikelihood(responses_actual, responses_control_model));
end

function percentResponsesPredicted = calcPercentResponsesCorrectlyPredicted(responses_predictedMCMC, responses_actual)
%% Calculate % responses predicted by the model
totalSamples				= size(responses_predictedMCMC,2);
nQuestions					= numel(responses_actual);
modelPrediction				= zeros(size(responses_predictedMCMC));
modelPrediction(responses_predictedMCMC>=0.5)=1;
responses_actual			= repmat(responses_actual, [1,totalSamples]);
isCorrectPrediction			= modelPrediction == responses_actual;
percentResponsesPredicted	= sum(isCorrectPrediction,1)./nQuestions;
end

function logOdds = calcLogOdds(a,b)
logOdds = log(a./b);
end

function dataLikelihood = calcDataLikelihood(responses, predicted)
% Responses are Bernoulli distributed: a special case of the Binomial with 1 event.
dataLikelihood = prod(binopdf(responses, ...
	ones(size(responses)),...
	predicted));
end
