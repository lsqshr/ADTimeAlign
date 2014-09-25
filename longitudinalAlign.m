function t1 = longitudinalAlign(L, t0, c, filter, severityFunc, dissimilarFunc, lambda, miu)
G = filter(L); 
v = severityFunc(L);
D = dissimilarFunc(G); % dissimilar matrix

options = optimoptions('fmincon','Algorithm','interior-point','Display','iter');

% Construct constraint 1: timepoints in interval
A = zeros(numel(t0), numel(t0));
A(logical(eye(size(A)))) = 1;
A = [A;-A];

b = zeros(size(A,1),1);
b(1:numel(t0)) = max(t0);
b(numel(t0) + 1 : end) = min(t0);

% Construct constraint 2: timepoints in same order
g = @(t) elediff(t) .* c .* (elediff(t0) .* c);
gfun = @(t) deal(g(t), []);

[t1,fval,exitflag,output] = fmincon(@(t)costFunc(t, D, t0, c, v, lambda, miu), t0, A, b, [], [], [], [], gfun, options);

end

function cost = costFunc(t, D, t0, c, v, lambda, miu)

dt = elediff(t);
dt0 = elediff(t0);
dv = elediff(v);

% Calculate S(t)
w = dt0.^2; % costs of dissimilarity
h = max(t0) - min(t0);
w = exp(-w ./ h^2);
S = sum(sum(w.* D));

% Calculate R(t)
R = sum(sum((abs(dt - dt0) .* c)));

% Calculate V(t)
V = -(dv .* dt);
V(V<=0) = 0;
V = sum(sum(V .* ~c));

cost = S + lambda * R + miu * V;

end

function d = elediff(t)
    d = repmat(t',1,numel(t)) - repmat(t,numel(t),1);
end