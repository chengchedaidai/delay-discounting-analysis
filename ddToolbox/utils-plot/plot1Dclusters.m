function plot1Dclusters(mcmcContainer, data, col, plotOptions, varInfo)

% TODO: plotExpclusters.m and plotLOGKclusters are pretty much identical

% TODO: plotExpclusters.m and plotLOGKclusters also do the same thing
% (conceptually) as plotMCclusters.m

% TODO:
% remove input:
% - mcmcContainer, just pass in the data
% - data, just pass in 
% rename to plotUnivariateDistributions

% plot posteriors over log(k) for all participants

%% REAL EXPERIMENT DATA
% build samples
for p = 1:data.getNExperimentFiles()
	temp = mcmcContainer.getSamplesAtIndex_asMatrix(p, {varInfo.name});
	if ~isempty(temp)
		samples(:,p) = temp;
	end
end

uniG1 = mcmc.UnivariateDistribution(samples(:,[1:data.getNRealExperimentFiles()]),...
    'xLabel', varInfo.label,...
    'plotHDI', false,...
	'pointEstimateType', plotOptions.pointEstimateType,...
	'patchProperties',definePlotOptions4Participant(col));

% keep axes zoomed in on all participants
axis tight
participantAxisBounds = axis;

%% GROUP LEVEL (UNOBSERVED PARTICIPANT)
if size(samples,2)==data.getNExperimentFiles()
	groupSamples = samples(:,data.getNExperimentFiles());
	
	if data.isUnobservedPartipantPresent() && ~any(isnan(groupSamples))
		mcmc.UnivariateDistribution(groupSamples,...
			'xLabel', varInfo.label,...
			'plotHDI', false,...
			'pointEstimateType', plotOptions.pointEstimateType,...
			'patchProperties', definePlotOptions4Group(col));
	end
end

%% Formatting
set(gca,'PlotBoxAspectRatio',[3,1,1])
axis(participantAxisBounds)
% set(gca,'XAxisLocation','origin',...
% 	'YAxisLocation','origin')
drawnow


	function properties = definePlotOptions4Participant(col)
		properties = {'FaceAlpha', 0.2,...
			'FaceColor', col,...
			'LineStyle', 'none'};
	end

	function properties = definePlotOptions4Group(col)
		properties = {'FaceColor', 'none',...
			'EdgeColor', col/2,...
			'LineWidth', 3};
	end
end
