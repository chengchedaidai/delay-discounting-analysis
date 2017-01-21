classdef test_PlotAllModels < matlab.unittest.TestCase

	properties
		data
		savePath = tempname(); % matlab auto-generated temp folders
	end

	properties (TestParameter)
		model = {'ModelHierarchicalME_MVNORM',...
			'ModelHierarchicalME',...
			'ModelHierarchicalMEUpdated',...
			'ModelMixedME',...
			'ModelSeparateME',...
			'ModelHierarchicalLogK',...
			'ModelMixedLogK',...
			'ModelSeparateLogK',...
			'ModelSeparateNonParametric',...
			'ModelHierarchicalExp1', 'ModelMixedExp1', 'ModelSeparateExp1'}
		pointEstimateType = {'mean','median','mode'}
		chains = {2,3}
	end

	%% CLASS-LEVEL SETUP/TEARDOWN -----------------------------------------
	methods (TestClassSetup)
		function setup(testCase)
			% assuming this is running on my maching
			addpath('~/git-local/delay-discounting-analysis/ddToolbox')
			datapath = '~/git-local/delay-discounting-analysis/demo/datasets/kirby';

			% only analyse 2 people, for speed of running tests
			filesToAnalyse={'AC-kirby27-DAYS.txt', 'CS-kirby27-DAYS.txt'};
			testCase.data = Data(datapath, 'files', filesToAnalyse);
		end
	end


	methods(TestClassTeardown)

		function remove_temp_directory(testCase)
			rmdir(testCase.savePath,'s')
		end

		function delete_stan_related_outputs(testCase)
			delete('*.data.R')
			delete('*.csv')
		end

		function close_figures(testCase)
			close all
		end

	end


	%% THE ACTUAL TESTS ---------------------------------------------------

	methods (Test)

		function plot(testCase, model)
			% make model
			makeModelFunction = str2func(model);
			model = makeModelFunction(testCase.data,...
				'savePath', testCase.savePath,...
				'shouldPlot','yes',...
				'shouldExportPlots', false,...
				'mcmcParams', struct('nsamples', get_numer_of_samples_for_tests(),...
										'nchains', 2,...
										'nburnin', get_burnin_for_tests()));
			%model.plot();

			% TODO: DO AN ACTUAL TEST HERE !!!!!!!!!!!!!!!!!!!!!!
		end

	end

end
