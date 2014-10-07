function [x, t, c] = loadHippo(dataFile, filterLen, filterLabel)
% filterLabel: 1 stable NC 2. stable MCI 3. NC2MCI 4. MCI2AD 5 stable AD

	x = double([dataFile.lefthippo dataFile.righthippo]);
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

    dx = dataFile.dxchange(I);
    
	% Filter out the sequences that are too short
    for i = 1 : ntribe
        seql = seqLabel(dx(edgePts(i)+1 : edgePts(i+1)));
        if edgePts(i+1) - edgePts(i) >= filterLen && seql == filterLabel
            Y1 = [Y1; Y(edgePts(i)+1 : edgePts(i+1))];
            I1 = [I1; I(edgePts(i)+1 : edgePts(i+1))];
        end
    end

    % Re-order the data and timepoints
    x = x(I1, :);
    t = t(I1, :);
    
    % Make the tribes with the filtered sequences
    tribes = {};
	edgePts1 = getEdges(Y1);
	ntribe1   = numel(edgePts1) - 1; 
    for i = 1 : ntribe1
        tribes{i} = edgePts1(i)+1 : edgePts1(i+1);
        tribeT = t(edgePts1(i)+1 : edgePts1(i+1));
        t(edgePts1(i)+1 : edgePts1(i+1)) = (tribeT - min(tribeT)) / 3;
        x(edgePts1(i)+1 : edgePts1(i+1), :) = x(edgePts1(i)+1 : edgePts1(i+1), :) ./ repmat(x(edgePts1(i)+1, :), edgePts1(i+1)-edgePts1(i), 1);
    end
    c = makeFriends(tribes);
end

function edges = getEdges(Y)
    edges = find(diff(Y)>0); % Where there is a change in the next element 
    edges = [0; edges; numel(Y)];
end

function l = seqLabel(S)
    l = 0; % Default label
    allNL = true;
    allMCI = true;
    allAD = true;
    
    for i = 1 : numel(S)
        s = S(i);
        % if all members are 'Stable: NL' : 1
        if ~strcmp(s, 'Stable: NL')
            allNL = false;
        end
        
        % if all members are 'Stable: MCI': 2
        if ~strcmp(s, 'Stable: MCI')
            allMCI = false;
        end
        
        % if all members are 'Stable: Dementia': 5
        if ~strcmp(s, 'Stable: Dementia')
            allAD = false;
        end
        
        % if exist member 'Conversion: NL to MCI': 3
        if strcmp(s, 'Conversion: NL to MCI')
            l = 3;
            return
        end
        
        % if exist member 'Conversion: MCI to Dementia': 4
        if strcmp(s, 'Conversion: MCI to Dementia')
            l = 4;
            return
        end
    end
    
    if allNL
        l = 1;
        return
    end
    
    if allMCI
        l = 2;
        return
    end
    
    if allAD
        l = 5;
        return
    end
end

