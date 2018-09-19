classdef fLocSequence
    
    properties
        num_runs    % number of runs in experiment
        stim_onsets % onset times of each stimulus in a run
        stim_names  % sequence of stimulus filenames
        task_probes % index of stimuli that are task probes
    end
    
    properties (Hidden)
        stim_set     % stimulus set/s (1 = standard, 2 = alternate, 3 = both)
        task_num     % task number (1 = 1-back, 2 = 2-back, 3 = oddball)
        block_onsets % block onsets relative to beginning of run (seconds)
        block_conds  % block conditions labels
    end
    
    properties (Constant)
        stim_conds = {'Bodies' 'Characters' 'Faces' 'Objects' 'Places'};
        stim_per_block = 12;   % number of stimuli in a block
        stim_duty_cycle = 0.5; % duration of stimulus duty cycle (s)
    end
    
    properties (Constant, Hidden)
        stim_set1 = {'body' 'word' 'adult' 'car' 'house'};
        stim_set2 = {'limb' 'number' 'child' 'instrument' 'corridor'};
        stim_per_set = 144;
        task_names = {'1back' '2back' 'oddball'};
        task_freq = 0.5;
    end
    
    properties (Dependent)
        task_name % descriptor for each task number
        run_dur   % run duration (seconds)
        stim_dur  % stimulus duration (seconds)
        isi_dur   % interstimulus interval duration (seconds)
    end
    
    properties (Dependent, Hidden)
        num_conds % number of conditions in experiment
        run_sets  % stimulus set used in each run
    end
    
    methods
        
        % class constructor
        function seq = fLocSequence(stim_set, num_runs, task_num)
            if nargin < 1
                seq.stim_set = 3;
            else
                seq.stim_set = stim_set;
            end
            if nargin < 2
                seq.num_runs = 4;
            else
                seq.num_runs = num_runs;
            end
            if nargin < 3
                seq.task_num = 3;
            else
                seq.task_num = task_num;
            end
        end
        
        % get name of task
        function task_name = get.task_name(seq)
            task_name = seq.task_names{seq.task_num};
        end
        
        % get run duration given stimulus duty cycle
        function run_dur = get.run_dur(seq)
            block_dur = seq.stim_per_block * seq.stim_duty_cycle;
            blocks_per_run = 1 + (1 + length(seq.stim_conds)) ^ 2 + 1;
            run_dur = block_dur * blocks_per_run;
        end
        
        % get ISI duration given task
        function isi_dur = get.isi_dur(seq)
            if seq.task_num == 3
                isi_dur = 0;
            else
                isi_dur = 0.1;
            end
        end
        
        % get stimulus duration given ISI
        function stim_dur = get.stim_dur(seq)
            stim_dur = seq.stim_duty_cycle - seq.isi_dur;
        end
        
        % get number of experimental conditions including baseline
        function num_conds = get.num_conds(seq)
            num_conds = 1 + length(seq.stim_conds);
        end
        
        % get image sets for each run given selection
        function run_sets = get.run_sets(seq)
            switch seq.stim_set
                case 1
                    run_sets = repmat(seq.stim_set1, seq.num_runs, 1);
                case 2
                    run_sets = repmat(seq.stim_set2, seq.num_runs, 1);
                case 3
                    run_sets = [seq.stim_set1; seq.stim_set2];
                    cat_iters = ceil(seq.num_runs / 2);
                    run_sets = repmat(run_sets, cat_iters, 1);
                    run_sets = run_sets(1:seq.num_runs, :);
                otherwise
                    error('Invalid stim_set argument.');
            end
        end
        
        % generate randomized stimulus sequences and insert task probes
        function seq = make_runs(seq)
            % calculate number of images needed from each category
            [unique_cats, ~, idxs] = unique(seq.run_sets(:));
            unique_cats = unique_cats';
            cnts = accumarray(idxs(:), 1, [], @sum)';
            stim_per_cat = cnts * seq.stim_per_block * seq.num_conds;
            cycles_per_cat = ceil(stim_per_cat / seq.stim_per_set);
            % randomize the order of stimuli minimizing image repetition
            stim_nums = cell(1, length(cycles_per_cat));
            for cc = 1:length(cycles_per_cat)
                for cy = 1:cycles_per_cat(cc)
                    stim_nums{cc} = [stim_nums{cc} randperm(seq.stim_per_set)];
                end
            end
            stim_nums = cellfun(@(X, Y) X(1:Y), stim_nums, num2cell(stim_per_cat), 'uni', false);
            % get order of conditions in each run with padding blocks
            block_conds = make_orders(seq.num_conds, seq.num_conds, seq.num_runs);
            block_conds = [zeros(1, seq.num_runs); block_conds; zeros(1, seq.num_runs)];
            block_dur = seq.stim_per_block * seq.stim_duty_cycle;
            block_onsets = repmat(0:block_dur:seq.run_dur - block_dur, seq.num_runs, 1)';
            % generate sequence of stimulus filenames for each run
            stim_mat = cell(seq.stim_per_block, seq.num_conds ^ 2 + 2, seq.num_runs);
            for rr = 1:seq.num_runs
                cat_list = ['baseline' seq.run_sets(rr, :)];
                cat_seq = cat_list(block_conds(:, rr) + 1);
                stim_mat(:, :, rr) = repmat(cat_seq, seq.stim_per_block, 1);
            end
            stim_cat_list = reshape(stim_mat, [], 1);
            stim_num_list = zeros(size(stim_cat_list));
            for cc = 1:length(unique_cats)
                cat_idxs = find(strcmp(unique_cats{cc}, stim_mat));
                stim_num_list(cat_idxs) = stim_nums{cc};
            end
            stim_num_list = num2cell(stim_num_list);
            stim_num_list = cellfun(@(X) ['-' num2str(X) '.jpg'], stim_num_list, 'uni', false);
            stim_num_list = strrep(stim_num_list, '-0.jpg', '');
            stim_list = cellfun(@(X, Y) [X Y], stim_cat_list, stim_num_list, 'uni', false);
            % insert task probes in randomly-selected stimulus blocks
            probes_per_run = floor(seq.task_freq * seq.num_conds ^ 2);
            if seq.task_num == 2
                probe_pos = randi(seq.stim_per_block - 3, [probes_per_run seq.num_runs]) + 2;
            else
                probe_pos = randi(seq.stim_per_block - 2, [probes_per_run seq.num_runs ]) + 1;
            end
            probe_stim_mat = zeros(seq.stim_per_block, seq.num_conds ^ 2 + 2, seq.num_runs);
            for rr = 1:seq.num_runs
                stim_block_idxs = shuffle(find(block_conds(:, rr) > 0));
                xi = probe_pos(:, rr);
                yi = sort(stim_block_idxs(1:probes_per_run));
                zi = repmat(rr, probes_per_run, 1);
                run_probe_idxs = sub2ind(size(probe_stim_mat), xi, yi, zi);
                probe_stim_mat(run_probe_idxs) = 1;
            end
            probe_stim_idxs = find(probe_stim_mat);
            if seq.task_num == 1
                probe_stim_names = stim_list(probe_stim_idxs - 1);
            elseif seq.task_num == 2
                probe_stim_names = stim_list(probe_stim_idxs - 2);
            else
                oddball_nums = num2cell(randi(seq.stim_per_set, probes_per_run * seq.num_runs, 1));
                probe_stim_names = cellfun(@(X) ['scrambled-' num2str(X) '.jpg'], oddball_nums, 'uni', false);
            end
            stim_list(probe_stim_idxs) = probe_stim_names;
            stim_names = reshape(stim_list', [], seq.num_runs);
            stim_onsets = repmat(0:seq.stim_duty_cycle:seq.run_dur - seq.stim_duty_cycle, seq.num_runs, 1)';
            task_probes = reshape(probe_stim_mat, [], seq.num_runs);
            % store stimulus sequence parameters
            seq.block_onsets = block_onsets;
            seq.block_conds = block_conds;
            seq.stim_onsets = stim_onsets;
            seq.stim_names = stim_names;
            seq.task_probes = task_probes;
        end
                
    end
    
end

