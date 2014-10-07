function [w, h] = eleweight(t1, t2)
    dt = elediff(t1, t2);
    w = dt.^2; % costs of dissimilarity
	h = max([t1;t2]) - min([t1;t2]);
	w = exp(-w ./ h^2);
end