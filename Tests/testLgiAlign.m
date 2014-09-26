function testLgiAlign()

	LAMBDA = 5e-7;
	MIU = 1e-7;
    
    % Previous Hand Crafted Data
	%L = [2;4;2;3;5;6];
	%t0 = [0,1,0,1,2,3];
	%c = zeros(6,6);
	%c(logical(eye(size(c)))) = 1;
	%c(1,2) = 1;
	%c(2,1) = 1;
	%c(3:end,3:end) = 1;

	[L,t0,c] = generateTests(100);
	plotResults(L,t0,c,1, '-'); % Plot original data
	
    % Start Alignment fitting
	[t1, sG] = longitudinalAlign(L, t0, c, @(l)identityFilter(l), @(l)simpleSum(l), @(l)MSE(l), 10, LAMBDA, MIU);
    plotResults(L,t1,c,1, '--r'); % Plot results
    
end


function l = identityFilter(l)
	l = l ;
end


function s = simpleSum(l)
	s = sum(l, 2);
end


function d = MSE(l)
	l = sum(l, 2);
	d = repmat(l,1,numel(l)) - repmat(l',numel(l),1);
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

	L = rand(1,nSubject) * 100;
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
	    plot(t, l, lineSpec);
	end
	hold off;
end
