function d = elediff(t1, t2)
    d = repmat(t1,1,numel(t2)) - repmat(t2',numel(t1),1);
end