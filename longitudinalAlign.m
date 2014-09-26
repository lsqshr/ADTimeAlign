function [t1, sG] = longitudinalAlign(L, t0, c, filter, severityFunc, dissimilarFunc, nGSample, lambda, miu)
	G = filter(L); 
	v = severityFunc(L);
	D = dissimilarFunc(G); % Dissimilar matrix

	options = optimoptions('fmincon','Algorithm','interior-point','Display','iter');

	% Construct constraint 1: timepoints in interval
	A = zeros(numel(t0), numel(t0));
	A(logical(eye(size(A)))) = 1;
	A = [A;-A];

	b = zeros(size(A,1),1);
	b(1:numel(t0)) = max(t0);
	b(numel(t0) + 1 : end) = min(t0);

	% Construct constraint 2: timepoints in same order
	g = @(t) -elediff(t, t) .* c .* (elediff(t0, t0) .* c);
	gfun = @(t) deal(g(t), []);

	% t0 -> t1
	[t1,~,~,~] = fmincon(@(t)costFunc(t, D, t0, c, v, lambda, miu),...
	                                    t0, A, b, [], [], [], [], gfun, options);

    % Estimate disease progression model
    tall = linspace(min(t1), max(t1), nGSample)';
    w = eleweight(tall, t1);
    %sG = sum(w * G, 2) ./ sum(w, 2); % spatial distribusion
    sG = 0;
end

function cost = costFunc(t, D, t0, c, v, lambda, miu)

	dt = elediff(t, t);
	dv = elediff(v, v);

	% Calculate S(t)
    dt0 = elediff(t0, t0);
	w = eleweight(t0, t0);
	S = sum(sum(w.* D));

	% Calculate R(t)
	R = sum(sum((abs(dt - dt0) .* c)));

	% Calculate V(t)
	V = -(dv .* dt);
	V(V<=0) = 0;
	V = sum(sum(V .* ~c));

	cost = S + lambda * R + miu * V;

end

