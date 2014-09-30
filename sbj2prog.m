% Fitting a new subject to the disease progression model
% L: #case * #biomarkers
% T: #timepoints to be fitted * 1

function t1 = sbj2prog(L, t0, M, c, xi, filter)
	G = filter(L);

	options = optimoptions('fmincon','Algorithm','interior-point','Display','iter');

    [A, b, gfun] = makeCons(t0, c);

	% t0 -> t1
	[t1,~,~,~] = fmincon(@(t)costFunc(t, M, L, t0, xi, c),...
	                                    t0, A, b, [], [], [], [], gfun, options);
end

function cost = costFunc(t, M, L, t0, xi, c)
	d=@(h1, h2)sum(sum(h1.*log2(h2+eps)-h2.*log2(h1+eps)));
	dt = elediff(t, t);
    dt0 = elediff(t0, t0);
	R = sum(sum((abs(dt - dt0) .* c))); 
    cost = d(M(t), L) + xi * R;
end