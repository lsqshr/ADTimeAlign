function [x, t, c] = loadHippo(dataFile, filterLen)
	x = [dataFile.lefthippo; dataFile.righthippo];
	v = dataFile.VISCODE;
	t = zeros(numel(v), 1);

	for i = 1 : numel(v)
		if strcmp(v{i}, 'bl')
			t(i) = 0;
		else
            t(i) = str2num(v{i}(2:end)); % Remove the 'm' in front of the VISCODE
		end
	end

    % Make relationship table c and filter out the len(sequence) < 3
	[Y, I]  = sort(dataFile.RID);
	edgePts = getEdges(Y);
	ntribe  = numel(edgePts) - 1; 

	Y1     = [];
	I1     = [];
	ctr    = 0;

	% Filter out the sequences that are too short
    for i = 1 : ntribe
        if edgePts(i+1) - edgePts(i) >= filterLen 
            Y1 = [Y1; Y(edgePts(i)+1 : edgePts(i+1))];
            I1 = [I1; I(edgePts(i)+1 : edgePts(i+1))];
        end
    end

    % Make the tribes with the filtered sequences
    tribes = {};
	edgePts1 = getEdges(Y1);
	ntribe1   = numel(edgePts1) - 1; 
    for i = 1 : ntribe1
        tribes{i} = edgePts1(i)+1 : edgePts1(i+1);
    end
    c = makeFriends(tribes);

    % Re-order the data and timepoints
    x = x(I1, :);
    t = t(I1, :);
end

function edges = getEdges(Y)
    edges = find(diff(Y)>0); % Where there is a change in the next element 
    edges = [0; edges; numel(Y)];
end