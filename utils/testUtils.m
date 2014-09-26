function testUtils()
	% Test Find Friends
	intribes = {[1,2,4], [3,5]};
	T = makeFriends(intribes);
	outtribes = findFriends(T);
	assert(isequal(intribes, outtribes));
end