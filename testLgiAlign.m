function testLgiAlign()
L = [1,1;1,3;1,1;1,2;2,3;3,3];
t0 = [0,1,0,1,2,3];
c = zeros(6,6);
c(logical(eye(size(c)))) = 1;
c(1,2) = 1;
c(2,1) = 1;
c(3:end,3:end) = 1;

lambda = 1e-6;
miu = 1e-6;

t1 = longitudinalAlign(L, t0, c, @(l)identityFilter(l), @(l)simpleSum(l), @(l)MSE(l), lambda, miu);
disp(t1)

% Plot original data and results

T1 = t0(1:2);
V1 = simpleSum(L(1:2,:));
T2 = t0(3:end);
V2 = simpleSum(L(3:end,:));

T1_o = t1(1:2);
V1_o = simpleSum(L(1:2,:));
T2_o = t1(3:end);
V2_o = simpleSum(L(3:end,:));

figure
subplot(2,1,1);
plot(T1, V1, T2, V2);
subplot(2,1,2);
plot(T1_o, V1_o, T2_o, V2_o);

end

function l = identityFilter(l)
l = l ;
end

function s = simpleSum(l)
s = sum(l, 2)';
end

function d = MSE(l)
l = sum(l, 2);
d = repmat(l,1,numel(l)) - repmat(l',numel(l),1);
d = d.^2;
end