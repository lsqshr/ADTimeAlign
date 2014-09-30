% Depends on the Fathom library to calculate the Bray-Curtis Dissimlarity Matrix
% http://www.marine.usf.edu/user/djones/matlab/matlab.html

function [t1, M] = longitudinalAlign(L, t0, c, filter, severityFunc, lambda, miu)
	G = filter(L); 
	v = severityFunc(L);
	D = f_dis(G, 'bc'); % Dissimilar matrix

	options = optimoptions('fmincon','Algorithm','interior-point','Display','iter');

    [A, b, gfun] = makeCons(t0, c);

	% t0 -> t1
	[t1,~,~,~] = fmincon(@(t)costFunc(t, D, t0, c, v, lambda, miu),...
	                                    t0, A, b, [], [], [], [], gfun, options);

    % Estimate disease progression model
    %tall = linspace(min(t1), max(t1), ntimepoints)';
    M = @(t) sum(eleweight(t, t1) * G, 2) ./ sum(eleweight(t, t1), 2); % spatial distribusion
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

