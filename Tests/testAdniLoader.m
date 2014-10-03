function testAdniLoader()
	% Make subset of the data for testing
    df = load('hippo.mat');
    df.RID = df.RID(1:9,:);
    df.VISCODE = df.VISCODE(1:9);
    df.lefthippo = df.lefthippo(1:9,:);
    df.righthippo = df.righthippo(1:9,:);

	[ x, t, c ] = loadHippo(df, 3);
    nsub = size(x,1);
    assert(nsub == 7); % a sequence of 2 should be removed
    assert(nsub == numel(t));
    assert(all([nsub, nsub] == size(c)));
    expectedMat = zeros(nsub,nsub);
    expectedMat(1:4,1:4) = 1;
    expectedMat(5:end,5:end) = 1;
    assert(all(all(expectedMat == c)));
    disp('**testAdniLoader Test Passed!');
end