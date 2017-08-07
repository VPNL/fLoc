function history = get_history(order)
% Computes the number of times a given condition is preceded by all others
% assuming a single column input where each row is a condition.
% Written by KGS Lab
% Edited by AS 8/2014

num_blocks = size(order, 1);
num_conds = length(unique(order));
history = zeros(num_conds);
for n = 2:num_blocks  
	history(order(n), order(n - 1)) = history(order(n), order(n - 1)) + 1;
end

end