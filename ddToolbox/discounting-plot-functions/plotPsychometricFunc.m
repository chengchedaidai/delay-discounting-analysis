function plotPsychometricFunc(pSamples, pointEstimateType)

% Psychometric function ---------------------------------------------------
%fh = @(x,params) params(:,1) + (1-2*params(:,1)) * normcdf( (x ./ params(:,2)) , 0, 1);
% Fast verion -------------------------------------------------------------
fh = @(x,params) bsxfun(@plus,...
	params(:,1),...
	bsxfun(@times, ...
	(1-2*params(:,1)),...
	normcdf( bsxfun(@rdivide, x, params(:,2) ) , 0, 1)) );
% -------------------------------------------------------------------------

samples(:,1) = pSamples.posterior.epsilon;
samples(:,2) = pSamples.posterior.alpha;

% check that we actually have samples
if any(isnan(samples))
	return
end

mcmc.PosteriorPrediction1D(fh,...
    'xInterp',linspace(-200,200,200),... % TODO: make this a function of alpha?
    'samples',samples,...
    'ciType','examples',...
    'variableNames', {'$V^B-V^A$', 'P(choose delayed)'},...
	'pointEstimateType',pointEstimateType);

return