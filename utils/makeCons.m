% Make the two constraits for the optimisation algorithm
function [lb, ub, gfun] = makeCons(t0, c)
	TC =  c .* (elediff(t0, t0) .* c);
	g = @(t) -elediff(t, t) .* TC;
	gfun = @(t) deal(g(t), []);
    %lb(1:numel(t0),1) = min(t0);
    
    ub(1:numel(t0),1) = max(t0);
    lb = [];
end