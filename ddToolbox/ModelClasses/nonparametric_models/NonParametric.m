classdef (Abstract) NonParametric < Model
	%NonParametric  NonParametric is a subclass of Model for examining models that do NOT make parametric assumptions about the discount function.

    properties (Access = private)
        AUC_DATA
		getDiscountRate % function handle
	end

	methods (Access = public)

		function obj = NonParametric(data, varargin)
			obj = obj@Model(data, varargin{:});
			obj.dfClass = @DF_NonParametric;
            % Create variables
			obj.varList.participantLevel = {'discountFraction'};
			obj.varList.monitored = {'discountFraction', 'alpha', 'epsilon', 'Rpostpred', 'P'};
		end

	end

	
	methods (Abstract)
		initialiseChainValues
    end
    
    methods (Access = protected)

        
        function obj = calcDerivedMeasures(obj)
        end

    end
    
    
    
    methods (Access = public)

		function plot(obj, varargin) % overriding from Model base class
			% parse inputs
			p = inputParser;
			p.FunctionName = mfilename;
			p.addParameter('shouldExportPlots', true, @islogical);
			p.parse(varargin{:});

            obj.pdata = obj.packageUpDataForPlotting();

			obj.shouldExportPlots = p.Results.shouldExportPlots;
			for n=1:numel(obj.pdata)
				obj.pdata(n).shouldExportPlots = p.Results.shouldExportPlots;
			end

			close all

            % POSTERIOR PREDICTION PLOTS =======================================
			arrayfun(@figPosteriorPrediction, obj.pdata) % posterior prediction plot
			
			%% TODO...
            
            % FOREST PLOT OF AUC VALUES ========================================
            %figUnivariateSummary(alldata)

            % EXPERIMENT PLOT ==================================================
            obj.experimentPlot();

		end
        
        
        function experimentPlot(obj)
            
            names = obj.data.getIDnames('all');
            
            for ind = 1:numel(names)
                fh = figure('Name', ['participant: ' names{ind}]);
                latex_fig(12, 10, 3)

                %%  Set up psychometric function
                psycho = PsychometricFunction('samples', obj.coda.getSamplesAtIndex(ind,{'alpha','epsilon'}));
                
                %% plot bivariate distribution of alpha, epsilon
                subplot(1,4,1)
                samples = obj.coda.getSamplesAtIndex(ind,{'alpha','epsilon'});
                mcmc.BivariateDistribution(...
                    samples.epsilon(:),...
                    samples.alpha(:),...
                    'xLabel','error rate, $\epsilon$',...
                    'ylabel','comparison accuity, $\alpha$',...
                    'pointEstimateType',obj.pointEstimateType,...
                    'plotStyle', 'hist',...
                    'axisSquare', true);
                
                %% Plot the psychometric function
                subplot(1,4,2)
                psycho.plot()
                
                                
                %% Set up discount function
				personInfo = obj.getExperimentData(ind);
                discountFunction = DF_NonParametric('delays',personInfo.delays,...
                    'theta', personInfo.dfSamples);
				
                %% plot distribution of AUC
                subplot(1,4,3)
                discountFunction.AUC.plot()
                
                %% plot discount function
                subplot(1,4,4)
                discountFunction.plot() 
                
                drawnow
                if obj.shouldExportPlots
                    myExport(obj.savePath, 'expt',...
                        'prefix', names{ind},...
                        'suffix', obj.modelFilename);
                end
                
                close(fh)
            end
        end
        
        
        
        function personStruct = getExperimentData(obj, p)
			% Create a structure with all the useful info about a person
			% p = person number
			participantName = obj.data.getIDnames(p);
			try
				parts = strsplit(participantName,'-');
				personStruct.participantName = strjoin(parts(1:2),'-');
			catch
				personStruct.participantName = participantName;
			end
			personStruct.delays = obj.observedData.uniqueDelays;
			personStruct.dfSamples = obj.extractDiscountFunctionSamples(p);
			personStruct.data = obj.data.getExperimentData(p);
		end



		function dfSamples = extractDiscountFunctionSamples(obj, personNumber)
			samples = obj.coda.getSamples({'discountFraction'});
			[chains, nSamples, participants, nDelays] = size(samples.discountFraction);
			personSamples = squeeze(samples.discountFraction(:,:,personNumber,:));
			% collapse over chains
			for d=1:nDelays
				dfSamples(:,d) = vec(personSamples(:,:,d));
			end
		end


		% 		function observedData = constructObservedDataForMCMC(obj, all_data)
		% 			%% Call superclass method to prepare the core data
		% 			observedData = constructObservedDataForMCMC@Model(obj, all_data);
		%
		% 			%% Now add model specific observed data
		% 			observedData.uniqueDelays = sort(unique(observedData.DB))';
		% 			observedData.delayLookUp = calcDelayLookup();
		%
		% 			function delayLookUp = calcDelayLookup()
		% 				delayLookUp = observedData.DB;
		% 				for n=1: numel(observedData.uniqueDelays)
		% 					delay = observedData.uniqueDelays(n);
		% 					delayLookUp(observedData.DB==delay) = n;
		% 				end
		% 			end
		% 		end

        
    end
    
    
    methods (Static, Access = protected)
		function observedData = addititional_model_specific_ObservedData(observedData)
			observedData.uniqueDelays = sort(unique(observedData.DB))';
			observedData.delayLookUp = calcDelayLookup();

			function delayLookUp = calcDelayLookup()
				delayLookUp = observedData.DB;
				for n=1: numel(observedData.uniqueDelays)
					delay = observedData.uniqueDelays(n);
					delayLookUp(observedData.DB==delay) = n;
				end
			end
		end
	end
    

end
