function Y = shuffle(X)
% Randomly redorders cell and numeric arrays.
% Written by KGS Lab
% Edited by AS 8/2014

dims = size(X);
[~, new_order] = sort(rand(1, prod(dims)));
Y = X(new_order);
Y = reshape(Y, dims);

end
