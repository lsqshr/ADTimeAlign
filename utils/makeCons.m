% Make the two constraits for the optimisation algorithm
function [A, b, gfun] = makeCons(t0, c)
	% Construct constraint 1: timepoints in interval
	A = zeros(numel(t0), numel(t0));
	A(logical(eye(size(A)))) = 1;
	A = sparse([A;-A]);
    
	b = zeros(size(A,1),1);
	b(1:numel(t0)) = max(t0);
	b(numel(t0) + 1 : end) = min(t0);

	% Construct constraint 2: timepoints in same order
	g = @(t) -elediff(t, t) .* c .* (elediff(t0, t0) .* c);
	gfun = @(t) deal(g(t), []);
end