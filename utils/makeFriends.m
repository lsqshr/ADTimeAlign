% Given tribes output relationship tables

function T = makeFriends(tribes)
	% Find #people 
	npeople = max(cellfun(@(x)max(x(:)), tribes));
	T = zeros(npeople, npeople);

	% Fill the relationship table
	for t = 1 : numel(tribes)
		tribe = tribes{t};
		b = combntns(tribe, 2); % binary relationships
		invb = [];
	    invb(:,1) = b(:,2);
		invb(:,2) = b(:,1);

		b = [b;invb];
		b = sub2ind(size(T), b(:,1), b(:,2));
		T(b) = 1;
	end

	diagidx = [[1:npeople]', [1:npeople]'];
	diagidx = sub2ind(size(T), diagidx(:,1), diagidx(:,2));
	T(diagidx) = 1;

end