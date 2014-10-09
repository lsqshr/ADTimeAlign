function testLgiAlign(testData)

	LAMBDA = 5e-12;
	MIU = 1e-4;
	XI  = 1e-12;

	if nargin == 0
        NTOTAL = 110;
        NNEW = 50;
        [L,t0,c] = generateTests(NTOTAL);
		tL = L(NTOTAL-NNEW+1:end,:);
		L = L(1:NTOTAL-NNEW,:);
		tt0 = t0(NTOTAL-NNEW+1:end);
		t0 = t0(1:NTOTAL-NNEW);
		tc = c(NTOTAL-NNEW+1:end, NTOTAL-NNEW+1:end);
		c = c(1:NTOTAL-NNEW,1:NTOTAL-NNEW);
	elseif strcmp(testData, 'adni')
        NNEW = 10;
        df = load('hippo.mat');
	    [L, t0, c] = loadHippo(df, 2, 4); % 1 stable NC 2. stable MCI 3. NC2MCI 4. MCI2AD 5 stable AD
        NTOTAL = numel(t0);
	    L = L(:, 2);
		tL = L(NTOTAL-NNEW+1:end,:);
		L = L(1:NTOTAL-NNEW,:);
		tt0 = t0(NTOTAL-NNEW+1:end);
		t0 = t0(1:NTOTAL-NNEW);
		tc = c(NTOTAL-NNEW+1:end, NTOTAL-NNEW+1:end);
		c = c(1:NTOTAL-NNEW,1:NTOTAL-NNEW);
    end

    plotResults(L, t0, c, 1, '-'); % Plot original data
    
    % Start Alignment fitting
	[t1, M] = longitudinalAlign(L, t0, c, @(l)identityFilter(l), @(l)simpleSum(l), LAMBDA, MIU);

	% Plot the fitting set
	plotResults(L, t1, c, 1, '--r'); % Plot results

    % Fit a new subject to the model
    tt1 = sbj2prog(tL, tt0, M, tc, XI, @(l)identityFilter(l));

    % Plot the testing set
	plotResults(tL, tt0, tc, 2, '-'); % Plot original data
    plotResults(tL, tt1, tc, 2, '--r'); % Plot results

end


function l = identityFilter(l)
	l = l ;
end


function s = simpleSum(l)
	s = sum(l, 2);
end


function d = MSE(l)
	d = elediff(l,l);
	d = d.^2;
end


function [L, T, c] = generateTests(nSubject)
	VMAX = 60;
	VMIN = 0;

	% Generate the length of sequence
	rng(0, 'twister');
	nSeq = int32(nSubject^0.5)+1;
	prop = rand(1, nSeq);
	prop = prop / sum(prop);
	seqlen = int32(nSubject * prop);
	seqlen(end) = nSubject - sum(seqlen(1:end-1));

	L = rand(nSubject,1) * 100;
	T = randi([0, 100], nSubject, 1);
	c = zeros(nSubject, nSubject);
	cidx = 1;
	for s  = 1 : numel(seqlen)
		% Chope and sort the random L sequence
	    L(cidx:cidx+seqlen(s)-1) = sort(L(cidx:cidx+seqlen(s)-1));

		% Chope and sort the random T sequence
	    T(cidx:cidx+seqlen(s)-1) = sort(T(cidx:cidx+seqlen(s)-1));
	    T(cidx:cidx+seqlen(s)-1) = T(cidx:cidx+seqlen(s)-1) - min(T(cidx:cidx+seqlen(s)-1));

		% Make the relationship matrix c
	    c(cidx:cidx+seqlen(s)-1, cidx:cidx+seqlen(s)-1) = 1;

	    cidx = cidx + seqlen(s);
	end
end

function plotResults(L, T, c, plotidx, lineSpec)
	nSubject = size(c, 1);
    tribes = findFriends(c);

	figure(plotidx)
	hold on;
	for s  = 1 : numel(tribes)
	    l = L(tribes{s});
	    t = T(tribes{s});
        [t, I] = sort(t);
        l = l(I);
	    plot(t, l, lineSpec);
	end
	hold off;
end
