function [model] = run_me()
%RUN_ME
% The code in this function provides a simple example of how to analyse
% delay discounting data. To run your own analysis, you can make a copy of
% this function and update as appropriate.
%
% Click this to run the demo code (it will take a while to compute)
% <a href="matlab:[model] = run_me();">[model] = run_me();</a>
%
% MAIN ANALYSIS PROCEDURE -------------------------------------------------
%
% 1) Set the path of the toolbox folder:
% >> addpath('~/git-local/delay-discounting-analysis/ddToolbox')
%
% 2) Run the toolbox setup code. This MUST be done once, at the start of
% each Matlab analysis session:
% >> ddAnalysisSetUp();
%
% 3) Load your data:
% >> datapath = '~/git-local/delay-discounting-analysis/demo/data';
% >> data = Data(datapath, 'files', allFilesInFolder(datapath, 'txt'));
%
% 4) Run an analysis:
% >> model = ModelHierarchicalME(data)
%
% Get help about the optional arguments when conducting inference:
% >> help Model.conductInference
%
%
% OPTIONAL EXTRAS ---------------------------------------------------------
%
% There are lots of preferences that you can change:
% >> model = ModelHierarchicalME(...
%		Data(datapath, 'files', allFilesInFolder(datapath, 'txt')),...
%		'savePath', 'analysis_with_hierarchical_magnitude_effect',...
%		'pointEstimateType','median',...
%		'shouldPlot', 'no',...
%		'mcmcParams', struct('nsamples', 10^4,...
% 						     'nchains', 4,...
% 	 					     'nburnin', 10^3));
%
% You can save the data and model objects as follows. You don't have to
% save the data, as it's stored internally in the model object. However it
% could be useful to store the data if you wanted to analyse with a
% different model.
% >> save('my_analysis.mat', 'data', 'model')
%
% And load it again at a later date with:
% >> clear, load('my_analysis.mat')
%
% Plotting: If you did not ask the conductInference() method to plot then
% you can generate the plots by:
% >> model.plot()
%
% You can inspect MCMC chains for diagnostic purposes by:
% >> model.coda.trellisplots({'m','c'})
%
% If you analysed your data with a model which accounts for the magnitude
% effect, then you may want to work out what the discount rate, log(k),
% might be for a given reward magnitude. You can do this by:
% >> logk = model.getLogDiscountRate(100,1) % <-------------TODO: MAKE IMPROVEMENTS
% >> logk.plot()							% <-------------TODO: MAKE IMPROVEMENTS
%
% You can get access to samples using code such as the following. They will
% be returned into a structure:
% >> samples = model.coda.getSamples({'m','c','alpha','epsilon'});
%
%
% You can do many things with the samples. By way of example, you could
% conduct Bayesian hypothesis testing. For details, see the contents of
% this function:
% >> hypothesisTestScript(model)
%
% You can also extract estimated present subjective values of the rewards
% for each trial in your dataset. After fitting a model, you can do this
% with the following command. This will return a table: rows are trials in
% your overall dataset. The columns labelled VA and VB give a point
% estimate of the predicted present subjective values of the rewards A and
% B, respectively. This information is particularly useful if you want to
% regress these against imaging data, for example.
% >> subjective_values = model.get_inferred_present_subjective_values();
%
% MORE INFORMATION --------------------------------------------------------
% For more information, see <a href="matlab:
% web('https://github.com/drbenvincent/delay-discounting-analysis/wiki')">the GitHub wiki</a> or just tweet me <a href="matlab:web('https://twitter.com/inferencelab')">@inferencelab</a>
% for help.
%
%
% See also: Data, Model

% --------- USE THE CODE BELOW AS A TEMPLATE FOR YOUR OWN ANALYSES --------
% USERS TO REPLACE THIS CODE BLOCK ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
path_of_this_mfile = strrep(which(mfilename),[mfilename '.m'],'');
toolbox_path = fullfile(path_of_this_mfile,'..','ddToolbox');
datapath = fullfile(path_of_this_mfile,'datasets','kirby');
% WITH THIS (update the paths as appropriate) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% toolbox_path = '~/git-local/delay-discounting-analysis/ddToolbox'
% addpath(toolbox_path)
% datapath = '~/git-local/delay-discounting-analysis/demo/datasets/kirby';
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Run setup routine
addpath(toolbox_path)
ddAnalysisSetUp();

% Do an analysis
model = ModelHierarchicalME(...
	Data(datapath, 'files', allFilesInFolder(datapath, 'txt')),...
	'savePath', fullfile(pwd,'output','my_analysis'),...
	'pointEstimateType', 'median',...
	'shouldPlot', 'yes',...
	'shouldExportPlots', true,...
	'exportFormats', {'png'},...
	'mcmcParams', struct('nsamples', 10000,...
						 'nchains', 4,...
	 					 'nburnin', 1000));

% NOTE:
% - you will want to increase the 'nburnin' and 'nsamples' when you are
% running proper analyses. I have provided small numbers here just to
% confirm the code is working without having to wait a long time.
% - you can change the point estimate type to mean, median, or mode


% If we didn't ask for plots when we ran the model, then we do that
% after with this command...
%	model.plot('shouldExportPlots', false)

end
