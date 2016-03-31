classdef ModelHierarchicalUpdated < ModelHierarchical
	%ModelHierarchicalUpdated A model to estimate the magnitide effect
	%   Extends ModelHierarchical but uses new JAGS model with new priors.

	properties
	end

	methods (Access = public)
		% =================================================================
		function obj = ModelHierarchicalUpdated(toolboxPath, sampler, data, saveFolder)
			% Inherit from ModelHierarchical and override selected methods
			obj = obj@ModelHierarchical(toolboxPath, sampler, data, saveFolder);

			switch sampler
				case{'JAGS'}
					modelPath = '/jagsModels/hierarchicalMEupdated.txt';
					obj.sampler = JAGSSampler([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
				case{'STAN'}
					error('NOT IMPLEMENTED YET')
			end

			% give sampler a handle back to the model (ie this hierarchicalME model)
			obj.sampler.modelHandle = obj;
		end
		% =================================================================

	end

end
