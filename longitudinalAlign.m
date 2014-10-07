% Depends on the Fathom library to calculate the Bray-Curtis Dissimlarity Matrix
% http://www.marine.usf.edu/user/djones/matlab/matlab.html

function [t1, M] = longitudinalAlign(L, t0, c, filter, severityFunc, lambda, miu)
	G = filter(L); 
	v = severityFunc(L);
	D = f_dis(G, 'bc'); % Dissimilar matrix

	%options = optimoptions('fmincon','Algorithm','interior-point','Display','iter');
    options = optimoptions('fmincon','Hessian',{'lbfgs'}, 'Display','iter');

    [A, b, gfun] = makeCons(t0, c);

    % Supply the hessian funcion
%     T = sym('T', [numel(t0),1]);
%     F = costFunc(T, D, t0, c, v, lambda, miu);
%     H = hessian(F,T);
    
	% t0 -> t1
	[t1,~,~,~] = fmincon(@(t)costFunc(t, D, t0, c, v, lambda, miu),...
	                                    t0, A, b, [], [], [], [], gfun, options);

    % Estimate disease progression model
    %tall = linspace(min(t1), max(t1), ntimepoints)';
    M = @(t) sum(eleweight(t, t1) * G, 2) ./ sum(eleweight(t, t1), 2); % spatial distribusion
end



