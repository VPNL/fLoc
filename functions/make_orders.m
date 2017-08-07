function orders = make_orders(num_conds, trials_per_cond, num_orders)
% Generates counterbalanced order of conditions.
% Written by KGS Lab
% Edited by AS 8/2014

% check that num_conds is a factor of trials_per_cond
num_trials = num_conds * trials_per_cond;
if (num_trials / (num_conds ^ 2)) ~= round(num_trials / (num_conds ^ 2))
    error('num_conds must be a factor of trials_per_cond.')
end

% generate specified number of condition orders
orders = zeros(num_conds * trials_per_cond, num_orders);
for oo = 1:num_orders
    % set up goal state
    order = zeros(num_trials, 1);
    for cc = 1:num_conds
        for tt = 1:trials_per_cond
            order(((cc - 1) * trials_per_cond) + tt) = cc;
        end
    end
    order = shuffle(order);
    goal = ones(num_conds, num_conds) * (num_trials / (num_conds * num_conds));
    % minimize difference between the goal and the current history
    while 1
        % get the energy for the current design
        history = get_history(order);
        old_energy = sum(sum(abs(history - goal)));
        % make a random swap in a copy of the design
        new = order; a = randi(num_trials); b = randi(num_trials);
        swap = new(a); new(a) = new(b); new(b) = swap;
        % calculate and minimize the energy in the new design
        new_energy = sum(sum(abs(gethistory(new) - goal)));
        if new_energy > 13
            if new_energy < old_energy
                order = new;
            end
        else
            if new_energy <= old_energy
                order = new;
            end
        end
        if new_energy == 1
            break
        end
    end
    orders(:, oo) = order - 1;
end

end
