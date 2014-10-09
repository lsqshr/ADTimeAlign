% Make the two constraits for the optimisation algorithm
function [lb, ub, gfun] = makeCons(t0, c)
    nt = numel(t0);
    TC =  c .* (elediff(t0, t0) .* c);
	g = @(theta) -elediff(theta(1:nt), theta(1:nt)) .* TC;
	gfun = @(t) deal(g(t), []);
        
    ub(1:numel(t0),1) = max(t0);
    lb = [];
end