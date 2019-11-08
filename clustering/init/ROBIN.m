function [C,lof] = ROBIN(data,k,nn,varargin)
%The ROBIN clustering initialisation method based on the work of [1].
%Original code in R can be found here [2]:
%https://github.com/brodsa/wrsk

% Matlab implementation:
% Avgoustinos Vouros <avouros1@sheffield.ac.uk>, <av.vouros@gmail.com>

%References:
% [1] Al Hasan, Mohammad, et al. "Robust partitional clustering by outlier 
%     and density insensitive seeding." Pattern Recognition Letters 30.11 
%     (2009): 994-1002.
% [2] BrodinovÃ¡, Å ., Filzmoser, P., Ortner, T., Breiteneder, C., & Rohm, 
%     M. (2017). Robust and sparse k-means clustering for high-dimensional 
%     data. Advances in Data Analysis and Classification, 1-28.

%%

% Input:
% - x  : a matrix where rows are observations and columns are attributes.
% - k  : number of target clusters.
% - nn : number of neighbors.

% Output:
% - C   : vector of row indeces of x (datapoints) to be used as initial
%         centroids. 
% - LOF : the Local Outlier Factor score of each datapoint.
% - varargin:
%         (1) 'DETERMINISTIC': Gives a deterministic solution by fixing the
%         reference point to the most dense region of the feature space.
%         (2) 'critRobin', real-number:
%         Critical cut-off value around 1 for LOF scores (1-critRobin, 
%         1+critRobin).
%         (3) 'LOF', Nx1 vector (N = number of datapoints):
%         Pre-computed LOF scores for the datapoints.

% NOTE: The default crit values of 0.05 and 1.05 was obtained from the ROBIN
%       implementation in the study of [2].

%%

    LOFCOM = 'lof_paper';
    DETERMINISTIC = 0;
	critRobin = 0.05;
    critRobin_1 = 1.05;
    lof = [];
        
    for iii = 1:length(varargin)
        if isequal(varargin{iii},'LOFCOM')
            LOFCOM = varargin{iii+1};
			i = iii;
        elseif isequal(varargin{iii},'DETERMINISTIC')
            DETERMINISTIC = 1;
        elseif isequal(varargin{iii},'critRobin')
            critRobin = varargin{iii+1};
        elseif isequal(varargin{iii},'LOF')
            lof = varargin{iii+1};
        end
    end  
    
    % Compute distance matrix
    dists = squareform(pdist(data));
    
    % Compute LOF either based on the code or the paper
    if isempty(lof)
        switch LOFCOM
            case 'lof_paper'
                lof = lof_paper(data,nn);
            case 'lof_given'
                lof = varargin{i+2};
            otherwise
                error('Wrong LOF');
        end       
    end
    
    % Select reference point
    if ~DETERMINISTIC
        n = size(data,1);
        r = randsample(n,1);
    else
        r = abs(1-lof);
        [~,r] = min(r);
    end
    
    
    % Find centroids
    C = [];
    while length(C) < k
        if length(C) < 1
            [~,sorted] = sort(dists(r,:),'descend');
        else
            [~,sorted] = sort(min(dists(C,:),[],1),'descend');
        end
        sorted_lof = lof(sorted);
		id = find( (1-critRobin < sorted_lof) & (sorted_lof < 1+critRobin) );
		if isempty(id)
			warning('ROBIN: no valid id point, try 1.');
			id = find((sorted_lof < critRobin_1) == 1);    
			if isempty(id)
				error('ROBIN: cannot find valid id point.')
			end
		end
        id = id(1);
        r = sorted(id);
        C = union(C,r);
    end

end
