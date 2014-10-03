function [x, t, c] = loadHippo(dataFile)
	x = [dataFile.leftHippo; rightHippo];
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
    [Y, I] = sort(rid);
    edgePts = find(diff(Y)>0); % Where there is a change in the next element 
    edgePts = [0, edgePts, numel(I)];
    ntribe  = numel(edgePts) - 1; 

    tribes = {};
    Y1 = [];
    I1 = [];
    ctr = 0;

    for i = 1 : ntribe
        if edgePts(i+1) - edgePts(i) >= filterLen % Filter out the sequences that are too short
            Y1 = [Y1, Y(edgePts(i)+1 : edgePts(i+1))];
            I1 = [I1, I(edgePts(i)+1 : edgePts(i+1))];
        end
    end

    % Reorder the data and timepoints
    x = x(I1, :);
    t = t(I1, :);
    c = makeRelTable(Y1);
end