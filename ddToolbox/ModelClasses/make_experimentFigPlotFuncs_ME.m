function experimentFigPlotFuncs = make_experimentFigPlotFuncs_ME()
% Define plotting functions for the participant mult-panel
% figure
experimentFigPlotFuncs{1} = @(plotdata) mcmc.BivariateDistribution(plotdata.samples.posterior.epsilon(:), plotdata.samples.posterior.alpha(:),...
	'xLabel','error rate, $\epsilon$',...
	'ylabel','comparison accuity, $\alpha$',...
	'pointEstimateType',plotdata.pointEstimateType,...
	'plotStyle', 'hist',...
	'axisSquare', true);

experimentFigPlotFuncs{2} = @(plotdata) plotPsychometricFunc(plotdata.samples, plotdata.pointEstimateType);

experimentFigPlotFuncs{3} = @(plotdata) mcmc.BivariateDistribution(plotdata.samples.posterior.m(:), plotdata.samples.posterior.c(:),...
	'xLabel','slope, $m$',...
	'ylabel','intercept, $c$',...
	'pointEstimateType',plotdata.pointEstimateType,...
	'plotStyle', 'hist',...
	'axisSquare', true);

experimentFigPlotFuncs{4} = @(plotdata) plotMagnitudeEffect(plotdata.samples, plotdata.pointEstimateType);

experimentFigPlotFuncs{5} = @(plotdata) plotDiscountSurface(plotdata);
end