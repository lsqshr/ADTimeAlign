function [cost] = costFunc(t, D, t0, c, v, lambda, miu)

	dt = elediff(t, t);
	dv = elediff(v, v);

	% Calculate S(t)
    dt0 = elediff(t0, t0);
	[w, h] = eleweight(t0, t0);
	S = sum(sum(w.* D));

	% Calculate R(t)
	R = sum(sum((abs(dt - dt0) .* c)));

	% Calculate V(t)
	V = -(dv .* dt);
	%V(V<=0) = 0;
    V = (V + abs(V)) / 2; % replace the negatives with 0 in the hard way to calculate hessian
	V = sum(sum(V .* ~c));

	cost = S + lambda * R + miu * V;
    %H = 2/h^2 .* D; % hessian matrix WRONG!
end