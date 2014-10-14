function testChangeRateExtraction()
    NNEW = 10;
    nseq = 6;
    
    df = load('hippo+ventricle.mat');
    [L, t0, c] = loadADNISeq(df, nseq, 1); % 1 stable NC 2. stable MCI 3. NC2MCI 4. MCI2AD 5 stable AD
    NTOTAL = numel(t0);
    plotAll(L, t0, c, 1, '-')
    histAll(L,2);
    
    df = load('hippo+ventricle.mat');
    [L, t0, c] = loadADNISeq(df, nseq, 2); % 1 stable NC 2. stable MCI 3. NC2MCI 4. MCI2AD 5 stable AD
    NTOTAL = numel(t0);
    plotAll(L, t0, c, 3, '-')
    histAll(L,4);
    
    [L, t0, c] = loadADNISeq(df, nseq, 4); % 1 stable NC 2. stable MCI 3. NC2MCI 4. MCI2AD 5 stable AD
    NTOTAL = numel(t0);
    plotAll(L, t0, c, 5, '-')
    histAll(L,6);
end

function plotAll(L, T, c, plotidx, lineSpec)
    nL = size(L, 2);
    ploty = double(int32(nL ^ 0.5))+1;
    plotx = ploty;
    figure(plotidx)
    for i = 1 : size(L, 2)
        subplot(plotx, ploty, i);
        plotResults(L(:,i), T, c, '-');
    end
end

function plotResults(L, T, c, lineSpec)
	nSubject = size(c, 1);
    tribes = findFriends(c);

	
	hold on;
	for s  = 1 : numel(tribes)
	    l = L(tribes{s});
	    t = T(tribes{s});
        [t, I] = sort(t);
        l = l(I);
	    plot(t, l, lineSpec);
	end
	hold off;
end

function histAll(L, plotidx)
    nL = size(L, 2);
    ploty = double(int32(nL ^ 0.5))+1;
    plotx = ploty;
    figure(plotidx)
    for i = 1 : size(L, 2)
        subplot(plotx, ploty, i);
        [f,x] = hist(L(:,i),50);
        bar(x,f/sum(f))
    end
end
