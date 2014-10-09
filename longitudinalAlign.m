% Depends on the Fathom library to calculate the Bray-Curtis Dissimlarity Matrix
% http://www.marine.usf.edu/user/djones/matlab/matlab.html

function [t1, M] = longitudinalAlign(L, t0, c, filter, severityFunc, lambda, miu)
	G = filter(L); 
	v = severityFunc(L);
	D = f_dis(G, 'bc'); % Dissimilar matrix

    [lb, ub, gfun] = makeCons(t0, c);
    
    [t1,~,~,~] = fmincon(@(t)costFunc(t, D, t0, c, v, lambda, miu), t0, [], [], [], [], lb, ub, gfun);

    % Estimate disease progression model
    M = @(t) sum(eleweight(t, t1) * G, 2) ./ sum(eleweight(t, t1), 2); % spatial distribusion
end
