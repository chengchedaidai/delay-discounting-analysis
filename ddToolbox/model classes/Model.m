classdef Model < handle
	%Model Base class to provide basic functionality

	properties (Access = public)
		modelType % string
		data % handle to Data class
		sampler % handle to SamplerWrapper class
		variables % array of variables
		varList
		saveFolder
		mcmc % handle to mcmc fit object
		plotFuncs % structure of function handles
		discountFuncType
		pointEstimateType
		initialParams
		goodnessOfFit
	end

	methods(Abstract, Access = public)
	end

	methods (Access = public)

		function obj = Model(data, saveFolder, varargin)
			p = inputParser;
			p.FunctionName = mfilename;
			p.addRequired('data', @(x) isa(x,'DataClass'));
			p.addRequired('saveFolder', @isstr);
			p.addParameter('pointEstimateType','mode',@(x) any(strcmp(x,{'mean','median','mode'})));
			p.parse(data, saveFolder, varargin{:});
			% add p.Results fields into obj
			fields = fieldnames(p.Results);
			for n=1:numel(fields)
				obj.(fields{n}) = p.Results.(fields{n});
			end
		end

		function varNames = extractLevelNVarNames(obj, N)
			varNames={};
			for var = each(fieldnames(obj.variables))
				if obj.variables.(var).analysisFlag == N
					varNames{end+1} = var;
				end
			end
		end

		function bool = isGroupLevelModel(obj)
			% we determine if the model has group level parameters by checking if
			% we have a 'groupLevel' subfield in the varList.
			if isfield(obj.varList,'groupLevel')
				bool = ~isempty(obj.varList.groupLevel);
			end
		end

		% MIDDLE-MAN METHODS ================================================

		function conductInference(obj)
			% TODO: get the observed data from the raw group data here.

			obj.setInitialParamValues();
			obj.sampler.initialParameters = obj.initialParams;

			obj.mcmc = obj.sampler.conductInference( obj , obj.data );
		end

		function setBurnIn(obj, nburnin)
			obj.sampler.setBurnIn(nburnin)
		end

		function setMCMCtotalSamples(obj, totalSamples)
			obj.sampler.setMCMCtotalSamples(totalSamples)
		end

		function setMCMCnumberOfChains(obj, nchains)
			obj.sampler.setMCMCnumberOfChains(nchains)
		end

		function plotMCMCchains(obj,vars)
			obj.mcmc.plotMCMCchains(vars);
		end

		function paramEstimateTable = exportParameterEstimates(obj, varargin)
			paramEstimateTable = obj.mcmc.exportParameterEstimates(...
				obj.varList.participantLevel,...
				obj.varList.groupLevel,...
				obj.data.IDname,...
				obj.saveFolder,...
				obj.pointEstimateType,...
				varargin{:});
		end




		% ===============================================================
		% WHERE SHOULD THESE FUNCTIONS LIVE?

		function conditionalDiscountRates(obj, reward, plotFlag)
			% Extract and plot P( log(k) | reward)
			warning('THIS METHOD IS A TOTAL MESS - PLAN THIS AGAIN FROM SCRATCH')
			obj.conditionalDiscountRates_ParticipantLevel(reward, plotFlag)

			if plotFlag
				removeYaxis
				title(sprintf('$P(\\log(k)|$reward=$\\pounds$%d$)$', reward),'Interpreter','latex')
				xlabel('$\log(k)$','Interpreter','latex')
				axis square
			end
		end

		function conditionalDiscountRates_ParticipantLevel(obj, reward, plotFlag)
			nParticipants = obj.data.nParticipants;
			%count=1;
			for p = 1:nParticipants
				params(:,1) = obj.mcmc.getSamplesFromParticipantAsMatrix(p, {'m'});
				params(:,2) = obj.mcmc.getSamplesFromParticipantAsMatrix(p, {'c'});
				% ==============================================
				[posteriorMean(p), lh(p)] =...
					calculateLogK_ConditionOnReward(reward, params, plotFlag);
				%lh(count).DisplayName=sprintf('participant %d', p);
				%row(count) = {sprintf('participant %d', p)};
				% ==============================================
				%count=count+1;
			end
			warning('GET THESE NUMBERS PRINTED TO SCREEN')
			% 			logkCondition = array2table([posteriorMode'],...
			% 				'VariableNames',{'logK_posteriorMode'},...)
			% 				'RowNames', num2cell([1:nParticipants]) )
		end








































		% **********************************************************************
		% **********************************************************************
		% PLOTTING *************************************************************
		% **********************************************************************
		% **********************************************************************
		% This plot method is highly unsatisfactory. We have a whole bunch of logic
		% which decides on the properties of the model (hierachical or not) and
		% (logk vs magnitude effect). It then uses a bunch of get methods in order
		% to grab the data in the appropriate format. We then pass this data to plot
		% functions/classes.
		%
		% Thinking needs to be done about the best way to refactor all this mess.





		function plot(obj)
			close all

			% IDEAS:
			% - Loop over participants (and group if there is one) and create an array of objects of a new participant class. This class will contain all the data for that person, as well as the plotting functions.
			%
			% - Or....


			%% PARTICIPANT LEVEL  ======================================
			% We will ALWAYS have participants.
			obj.plotParticiantStuff( )


			%% GROUP LEVEL ======================================
			% We are going to call this function, but it will be a 'null function' for models not doing hierachical inference. This is set in the concrete model class constructors.
			obj.plotFuncs.plotGroupLevel( obj )

		end


















		function posteriorPredictive(obj)

			%% Calculation
			% Calculate log posterior odds of data under the model and a
			% control model where prob of responding is 0.5.
			prob = @(responses, predicted) prod(binopdf(responses, ...
				ones(size(responses)),...
				predicted));

			nParticipants = obj.data.nParticipants;
			for p=1:nParticipants
				participantResponses = obj.data.participantLevel(p).table.R; % <-- replace with a get method

				% Calculate fit between posterior predictive responses and actual
				participant(p).predicted = obj.mcmc.getParticipantPredictedResponses(p);
				pModel = prob(participantResponses, participant(p).predicted');

				% calculate fit between control (random) model and actual
				% responses
				controlPredictions = ones(size(participantResponses)) .* 0.5;
				pRandom = prob(participantResponses, controlPredictions);

				logSomething(p) = log( pModel ./ pRandom);
				
				% save this value
				obj.goodnessOfFit(p).score = logSomething(p);
			end

			%% Set up text file to write information to
			[fid, fname] = setupTextFile(obj.saveFolder, 'PosteriorPredictiveReport.txt');


			%% Plotting
			for p=1:nParticipants
				figure, colormap(gray)
				%subplot(nParticipants,1,p)
				% plot predicted probability of choosing delayed
				bar(participant(p).predicted,'BarWidth',1)
				if p<nParticipants, set(gca,'XTick',[]), end
				box off
				% plot response data
				hold on
				plot([1:obj.data.participantLevel(p).trialsForThisParticant],... % <-- replace with a get method
					obj.data.participantLevel(p).table.R,... % <-- replace with a get method
					'o')
				myString = sprintf('%s: %3.2f\n', obj.data.IDname{p}, logSomething(p));
				%addTextToFigure('TR', myString, 12);
				title(myString)
				xlabel('trial')

				% Export figure
				myExport('PosteriorPredictive',...
				'saveFolder',obj.saveFolder,...
				'prefix', obj.data.IDname{p},...
				'suffix', obj.modelType)

                % Write info to text file
                myString = sprintf('%s: %3.2f\n', obj.data.IDname{p}, logSomething(p));
                logInfo(fid,myString)
			end

            % close text file
            fclose(fid);
            fprintf('Posterior predictive info saved in:\n\t%s\n\n',fname)

		end






		function plotParticiantStuff(obj)

			% UNIVARIATE SUMMARY STATISTICS ---------------------------------
			% We are going to add on group level inferences to the end of the
			% list. This is because the group-level inferences an be
			% seen as inferences we can make about an as yet unobserved
			% participant, in the light of the participant data available thus
			% far.
			IDnames = obj.data.IDname;
			if obj.isGroupLevelModel()
				IDnames{end+1}='GROUP';
			end
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
			obj.mcmc.figUnivariateSummary(IDnames, obj.varList.participantLevel, obj.pointEstimateType)
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
			latex_fig(16, 5, 5)
			myExport('UnivariateSummary',...
				'saveFolder',obj.saveFolder,...
				'prefix', obj.modelType)
			% --------------------------------------------------------------------




			pVariableNames = obj.varList.participantLevel;


			% LOOP OVER PARTICIPANTS
			for n = 1:obj.data.nParticipants
				participantFigFunc()
				participantTriPlot()
			end


			function participantFigFunc()
				% TODO ??????????????????
				opts.maxlogB	= max(abs(obj.data.observedData.B(:)));
				opts.maxD		= max(obj.data.observedData.DB(:));
				% ??????????????????

				fh = figure;
				fh.Name=['participant: ' obj.data.IDname{n}];

				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
				participantSamples = obj.mcmc.getSamplesAtIndex(n, pVariableNames);
				pData = obj.data.getParticipantData(n);

				if ~isempty(obj.goodnessOfFit)
					goodnessOfFitScore = obj.goodnessOfFit(n).score;
				else
					goodnessOfFitScore = [];
				end
				
				obj.plotFuncs.participantFigFunc(participantSamples,...
					obj.pointEstimateType,...
					'pData', pData,...
					'opts',opts,...
					'goodnessOfFit',goodnessOfFitScore);
				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~

				latex_fig(16, 18, 4)
				myExport(obj.data.IDname{n},...
					'saveFolder', obj.saveFolder,...
					'prefix', obj.modelType);
				close(fh)
			end

			function participantTriPlot()
				figure(87)

				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
				participantSamples = obj.mcmc.getSamplesFromParticipantAsMatrix(n, pVariableNames);
				priorSamples = obj.mcmc.getSamplesAsMatrix(obj.varList.participantLevelPriors);

				mcmc.TriPlotSamples(participantSamples,...
					pVariableNames,...
					'PRIOR',priorSamples,...
					'pointEstimateType',obj.pointEstimateType);
				% ~~~~~~~~~~~~~~~~~~~~~~~~~~~

				myExport([obj.data.IDname{n} '-triplot'],...
					'saveFolder', obj.saveFolder,...
					'prefix', obj.modelType);
			end









			%% SUMMARY PLOTS
			switch obj.discountFuncType
				case{'me'} % code smell
					% MC cluster plot
					probMass = 0.5; % <-- 50% prob mass to avoid too much clutter on graph
					% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
					figure(12)
					plotMCclusters(obj.mcmc,...
						obj.data, [1 0 0],...
					  probMass,...
						obj.pointEstimateType)
					% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
					myExport('MC_summary',...
						'saveFolder', obj.saveFolder,...
						'prefix', obj.modelType)

				case{'logk'}
					% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
					figure(12)
					plotLOGKclusters(obj.mcmc, obj.data, [1 0 0], obj.pointEstimateType)
					% ~~~~~~~~~~~~~~~~~~~~~~~~~~~
					myExport('LOGK_summary',...
						'saveFolder', obj.saveFolder,...
						'prefix', obj.modelType)
			end

			end


	end

end
