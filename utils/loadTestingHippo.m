function [ x1, x2, t1, t2, c1, c2 ] = loadTestingHippo(nnew)
	%LOADTESTINGHIPPO Load the progression volumes of left/right hippocampus from adnigo2 
	rawfile = load('UCSF-FS-Raw-All.mat');
    data = rawfile.rawdata;
    x = data.adnigo2.x;
    y = data.adnigo2.y;
    s = data.adnigo2.serial;
    h = data.adnigo2.featheader;

    leftHippoIdx = strmatch('ST29SV', h, 'exact');
    rightHippoIdx = strmatch('ST88SV', h, 'exact');

    unwantedLabels = [-1];
    filteredIdx = filterLabel(y, unwantedLabels); % Find the labels we are interested

    % Extract the RID and the months
    [rid, t0] = decoupleSerial(s(filteredIdx));

    % Make relationship table c and filter out the len(sequence) < 3
    filterLen = 3;
    [Y, I] = sort(rid);
    edgePts = find(diff(Y)>0); % Where there is a change in the next element 
    edgePts = [0, edgePts, numel(I)];
    ntribe  = numel(edgePts) - 1; 

    tribes = {};
    Y1 = [];
    Y2 = [];
    I1 = [];
    I2 = [];
    ctr = 0;
    for i = 1 : ntribe
        if edgePts(i+1) - edgePts(i) >= filterLen
            if ctr > nnew
                Y1 = [Y1, Y(edgePts(i)+1 : edgePts(i+1))];
                I1 = [I1, I(edgePts(i)+1 : edgePts(i+1))];
            else
                Y2 = [Y2, Y(edgePts(i)+1 : edgePts(i+1))];
                I2 = [I2, I(edgePts(i)+1 : edgePts(i+1))];
                ctr = ctr+1;
            end
        end
    end

    c1 = makeRelTable(Y1);
    c2 = makeRelTable(Y2);
    x1 = x(I1, [leftHippoIdx]);
    x2 = x(I2, [leftHippoIdx]);
    t1 = t0(I1,:);
    t2 = t0(I2,:);
end


function [ rid, t ] = decoupleSerial(s)
	for i = 1 : numel(s)
	    spstr = strread(s{i}, '%s', 'delimiter', '#');
	    rid(i) = str2double(spstr{1});
	    spstr = strread(spstr{2}, '%s', 'delimiter', 'm');
	    t(i) = str2double(spstr{2});
	end

	% Nomalise each subject by minused by its minimum time point observed 
	% First, find the minimum time point of each rid
    mrid = zeros(max(rid), 1); % The minimum time points of each rid
    mrid(:) = 1000;

    for i = 1 : numel(rid)
        if mrid(rid(i)) > t(i)
        	mrid(rid(i)) = t(i);
        end
    end

    % Second deduct each time points by its rid's minimum 
    for i = 1 : numel(t)
    	t(i) = t(i) - mrid(rid(i));
    end
    
    t = t'; % Keep the convention that dimension 1 is #sbj
end


function fidx = filterLabel(y, unwantedLabels)
	fidx = find(~ismember(y, unwantedLabels));
end


function c = makeRelTable(rid)
    % Make the RID idx into tribes by sorting O(nlogn)
    [Y, I]  = sort(rid);
    edgePts = find(diff(Y)>0); % Where there is a change in the next element 
    edgePts = [0, edgePts, numel(I)];
    ntribe  = numel(edgePts) - 1; 

    tribes = {};
    for i = 1 : ntribe
        tribes{end+1} = I(edgePts(i)+1 : edgePts(i+1));
    end

    % Make relationship table 
    c = makeFriends(tribes);
end