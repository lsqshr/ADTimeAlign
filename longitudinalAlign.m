function [t1, w, M] = longitudinalAlign(L, t0, c, filter, severityFunc, lambda, miu)
% Depends on the Fathom library to calculate the Bray-Curtis Dissimlarity Matrix
% http://www.marine.usf.edu/user/djones/matlab/matlab.html

    [lb, ub, gfun] = makeCons(t0, c);
    rw = rand(size(L, 2), 1);
    rw = rw/sum(rw);
    intheta = [t0; rw];
    
    [outtheta,~,~,~] = fmincon(@(theta)costFunc(theta, t0, L, c, filter, @(G)f_dis(G, 'bc'),...
	    severityFunc, lambda, miu), intheta, [], [], [], [], lb, ub, gfun);

    t1 = outtheta(1:size(c,1));
    w = outtheta(size(c,1) + 1 : end);

    % Estimate disease progression model
    M = @(t) sum(eleweight(t, t1) * G, 2) ./ sum(eleweight(t, t1), 2); % spatial distribusion
end
