% Given a relationship matrix of n subjects return the groups of indices of friends

function tribes = findFriends(c)
	npeople = size(c, 1);
	assert(npeople > 0);
	foundflags = zeros(1, npeople);

    tribes = {};
	nextFinder = 1;
	while nextFinder ~= -1
        friends = find(c(nextFinder, nextFinder : npeople) == 1)  + nextFinder - 1; % Find the friends of the current finder
        tribes{end+1} = friends;
        foundflags(friends) = 1; % mark the people have been found
        nextFinder = find(foundflags == 0, 1, 'first'); % Find next finder without a tribe

        if numel(nextFinder) == 0
        	nextFinder = -1;
        end
	end

end