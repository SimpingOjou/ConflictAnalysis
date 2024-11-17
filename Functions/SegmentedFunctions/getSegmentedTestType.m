function [test_type, vb_index, mv_index, vb_fing, mv_fing] = ...
    getSegmentedTestType(unique_vb, unique_mv)
    % getSeggmetedTestType - Determine the test type based on the onset data
    % Input:
    %   unique_vb: The unique vibration onsets
    %   unique_mv: The unique movement onsets
    % Output: 
    %   test_type: The type of the test
            % 1 = FDI vb and ADM mv
            % 2 = ADM vb and FDI mv
            % 3 = FDI vb and FDI mv
            % 4 = ADM vb and ADM mv
            % -1 = Not found
    %   vb_index: The index of the vibration onset
            % -1 = Not found
    %   mv_index: The index of the movement onset
            % -1 = Not found
    %   vb_fing: The finger that vibrates
            % 1 = FDI
            % 2 = ADM
            % -1 = Not found
    %   mv_fing: The finger that moves
            % 1 = FDI
            % 2 = ADM
            % -1 = Not found

    trial_nbr = size(unique_vb, 1);
    % Get trial type from analyzed data
    fdi_column = 1;
    adm_column = 2;

    % Initialize the variables
    test_type = ones(1, trial_nbr);
    test_type = test_type * -1;
    vb_index = ones(1, trial_nbr);
    vb_index = vb_index * -1;
    mv_index = ones(1, trial_nbr);
    mv_index = mv_index * -1;
    vb_fing = ones(1, trial_nbr);
    vb_fing = vb_fing * -1;
    mv_fing = ones(1, trial_nbr);
    mv_fing = mv_fing * -1;

    % For each row, get the trial type and compare it to the box data
    for i = 1:trial_nbr
        % Skip if the unique onset is not found
        if all(unique_vb(i,:) == -1) || all(unique_mv(i,:) == -1)
            continue;
        end

        % Get the trial type from the box data
        if unique_vb(i,fdi_column) ~= -1 && unique_mv(i,adm_column) ~= -1
            test_type(i) = 1;
            vb_index(i) = unique_vb(i,fdi_column);
            mv_index(i) = unique_mv(i,adm_column);
            vb_fing(i) = 1;
            mv_fing(i) = 2;
        end
        if unique_vb(i,adm_column) ~= -1 && unique_mv(i,fdi_column) ~= -1
            test_type(i) = 2;
            vb_index(i) = unique_vb(i,adm_column);
            mv_index(i) = unique_mv(i,fdi_column);
            vb_fing(i) = 2;
            mv_fing(i) = 1;
        end
        if unique_vb(i,fdi_column) ~= -1 && unique_mv(i,fdi_column) ~= -1
            test_type(i) = 3;
            vb_index(i) = unique_vb(i,fdi_column);
            mv_index(i) = unique_mv(i,fdi_column);
            vb_fing(i) = 1;
            mv_fing(i) = 1;
        end
        if unique_vb(i,adm_column) ~= -1 && unique_mv(i,adm_column) ~= -1
            test_type(i) = 4;
            vb_index(i) = unique_vb(i,adm_column);
            mv_index(i) = unique_mv(i,adm_column);
            vb_fing(i) = 2;
            mv_fing(i) = 2;
        end
    end

end