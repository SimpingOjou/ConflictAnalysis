function [resulting_onset_time] = getSegmentedUniqueOnsets(onsets)
    % GETUNIQUEONSETS Get unique onsets given an array (n x channel_nbr)
    % Input:
    % - onsets: cell array where each cell contains an array of onset times (n x channel_nbr)
    % Output:
    % - result: array of unique onsets (n x 2 [fdi, adm])

    channel_nbr = length(onsets(1,:));
    signal_length = length(onsets(:,1));

    resulting_onset_time = ones(signal_length, 2);
    resulting_onset_time = resulting_onset_time * -1;
    for i = 1:signal_length
        % For each row find the average onset time and the prevalent finger
        current_fdi_row = onsets(i, 1:channel_nbr/2);
        current_adm_row = onsets(i, (channel_nbr/2 + 1):channel_nbr);
        fdi_count = length(current_fdi_row(current_fdi_row ~= -1));
        adm_count = length(current_adm_row(current_adm_row ~= -1));

        % Skip if no onset is detected by the channel
        if fdi_count == 0 && adm_count == 0
            continue
        end

        % If the count of the fdi is equal to the adm, then add to both
        % TODO: Add function to further separate the onset times if needed
        if fdi_count == adm_count
            resulting_onset_time(i, 1) = mean(current_fdi_row(current_fdi_row ~= -1));
            resulting_onset_time(i, 2) = mean(current_adm_row(current_adm_row ~= -1));
        end

        % If the count of the fdi is greater than the adm, then the onset time
        if fdi_count > adm_count
            resulting_onset_time(i, 1) = mean(current_fdi_row(current_fdi_row ~= -1));
        end
        if adm_count > fdi_count
            resulting_onset_time(i, 2) = mean(current_adm_row(current_adm_row ~= -1));
        end
    end
end

% vb_onset_indexes =

%          753          -1         751          -1          -1          -1
%           -1          -1          -1        4711        4739        4745
%           -1          -1          -1        8694        8714        8632
%           -1       12768       12756          -1          -1          -1
%        18196          -1          -1       16694       16708       16796
%           -1          -1          -1       20687       20681       20728
%           -1          -1       24748          -1          -1          -1
%           -1          -1          -1       28691       28702       28696
%        33518          -1       32746          -1          -1          -1
%           -1          -1          -1          -1          -1          -1
%           -1       40754       40740          -1          -1          -1
%           -1       44765       44734          -1          -1          -1
%           -1          -1          -1       48722       48744       48708
%           -1       52781       52740          -1          -1          -1
%           -1       56735       56730          -1          -1          -1
%           -1          -1          -1       60689       60693       60732
%           -1       64740       64733          -1          -1          -1
%        68742       68765       68734          -1          -1          -1
%           -1          -1          -1       72694       72700       72720
%        77773          -1          -1       76712       76727       76726
%           -1       80744       80740          -1          -1          -1
%           -1          -1          -1       84709       84706       84777
%           -1          -1          -1       88740       88754       88790
%           -1          -1          -1       92705       92697       92668
%           -1          -1          -1       96760       96778       96767
%           -1      100750      100734          -1          -1          -1
%       104695      104725      104729          -1          -1          -1
%       108728      108741      108725          -1          -1          -1
%           -1          -1          -1      112714      112736      112736
%           -1          -1          -1      116722      116742      116726
%       120766      120738      120717          -1          -1          -1
%       124757      124746      124721          -1          -1          -1
%           -1          -1          -1      128704      128709      128725
%       132725      132732      132715          -1          -1          -1
%           -1          -1          -1      136738      136758      136792
%       140732      140736      140726          -1          -1          -1
%           -1          -1          -1      144708      144725      144731
%       148781      148758      148740          -1          -1          -1
%       153364          -1          -1      152728      152725      152795
%       156780      156754      156740          -1          -1          -1
%       161255          -1          -1      160791      160790      160829
%           -1          -1          -1      164749      164743      164787
%       168755      168762      168749          -1          -1          -1
%       172757      172775      172754          -1          -1          -1
%       176794      176771      176746          -1          -1          -1
%           -1          -1          -1      180763      180758      180794
%           -1          -1          -1          -1          -1          -1
%       188763      188766      188750          -1          -1          -1
%           -1          -1          -1      192744      192756      192819
%           -1          -1          -1      196771      196794      196818
%       200711      200751      200739          -1          -1          -1
%       204772      204763      204750          -1          -1          -1
%           -1          -1          -1      208759      208779      208800
%       212767      212798      212765          -1          -1          -1
%           -1          -1          -1      216768      216771      216865
%       220750      220795      220763          -1          -1          -1
%           -1          -1          -1      224757      224755      224808
%       228730      228734      228733          -1          -1          -1
%       232744      232807      232796          -1          -1          -1
%           -1          -1          -1      236822          -1          -1
%       240778      240793      240769          -1          -1          -1
%           -1          -1      244769          -1          -1          -1
%           -1          -1          -1      248741      248744      248786
%           -1          -1          -1      252772      252805      252819
%       256719      256739      256760          -1          -1          -1
%           -1          -1          -1      260778      260781      260787
%           -1      264818      264809          -1          -1          -1
%           -1          -1          -1      268742      268729      268767
%       272799      272809      272801          -1          -1          -1
%           -1          -1          -1      276759      276755      276789
%           -1          -1      280820          -1          -1          -1
%       284766      284790      284777          -1          -1          -1
%           -1          -1          -1      288784      288821      288811
%           -1          -1          -1      292754      292765      292763
%       296817          -1      296820          -1          -1          -1
%       301738          -1          -1      300759      300766      300805
%           -1      304804      304804          -1          -1          -1
%           -1          -1          -1      308776      308772      308753
%           -1          -1          -1      312802      312816          -1
%           -1      316797      316783          -1          -1          -1
%       320805      320814      320791          -1          -1          -1
%           -1          -1          -1      324786      324784      324799
%           -1          -1          -1      328792      328800      328804
%       332818      332813      332798          -1          -1          -1
%           -1          -1          -1      336757      336766      336752
%           -1      340812      340797          -1          -1          -1
%           -1          -1          -1      344771          -1      344778
%       348848      348801      348789          -1          -1          -1
%           -1          -1          -1      352767      352766      352765
%           -1          -1          -1      356762      356756      356539
%           -1          -1          -1      360790      360793      360791
%       364803      364828      364816          -1          -1          -1
%           -1          -1          -1      368807      368826      368805
%           -1          -1          -1      372792      372836      372816
%       376842      376845      376820          -1          -1          -1
%           -1      380816      380795          -1          -1          -1
%       384788      384776      384781          -1          -1          -1
%           -1          -1          -1      388781      388798      388785
%           -1      392810      392796          -1          -1          -1
%       397379      396789      396782          -1          -1          -1
%       400837      400844          -1          -1          -1          -1
%           -1          -1          -1      404783      404784      404817
%       408815      408825      408812          -1          -1          -1
%       412837      412834      412808          -1          -1          -1
%       416837      416844      416819          -1          -1          -1
%           -1          -1          -1          -1          -1          -1
%           -1          -1          -1      424822      424858      424820
%       428842      428849      428827          -1          -1          -1
%           -1          -1          -1      432786      432806      432746
%           -1          -1          -1      436810      436815      436716
%       440838      440832      440819          -1          -1          -1
%           -1          -1          -1      444829      444853      444851

%       448862      448836      448818          -1          -1          -1
%       452845      452831      452818          -1          -1          -1
%           -1          -1          -1      456824      456830      456787
%           -1          -1          -1      460823      460852      460863
%           -1          -1          -1      464849          -1      465437
%           -1          -1          -1      468822      468821      468842
%       472781      472807      472802          -1          -1          -1
%           -1          -1          -1      476817      476828      476875
%       480867      480823      480809          -1          -1          -1
%       484896      484833      484812          -1          -1          -1
%           -1          -1          -1          -1          -1          -1
%           -1          -1          -1      492828      492822      492878
%           -1          -1          -1      496910          -1          -1
%           -1          -1          -1      500859          -1      500863
%           -1      504826      504810          -1          -1          -1
%       508819      508792      508802          -1          -1          -1
%           -1          -1          -1      512821      512811      512771
%       516816      516813      516811          -1          -1          -1
%       521723      520839      520821          -1          -1          -1
%           -1      524841      524818          -1          -1          -1
%           -1          -1          -1      528826      528822      528712
%           -1          -1          -1      532860      532901      532853
%           -1          -1          -1      536825      536840      536895
%           -1          -1          -1      540840      540848      540812
%           -1          -1          -1      544820      544839      544837
%       548794      548804      548804          -1          -1          -1
%           -1      552820      552807          -1          -1          -1
%           -1          -1          -1      556863      556885      556827
%           -1          -1          -1      560869      560886      560870
%       565539      564841      564825          -1          -1          -1
%           -1      568846      568829          -1          -1          -1
%           -1          -1          -1      572863      572854      572843
%       576838      576854      576830          -1          -1          -1
%           -1          -1          -1      580827      580834      580542
%           -1          -1          -1      584859      584875      584887
%       588874      588848      588828          -1          -1          -1
%       592856      592852      592831          -1          -1          -1
%       596876      596863      596837          -1          -1          -1
%           -1          -1          -1          -1          -1          -1
%           -1          -1          -1      604838      604840      604856
%       609576      608875      608849          -1          -1          -1
%       613748      612849      612837          -1          -1          -1
%           -1          -1          -1      616832      616849      616875
%           -1          -1          -1      620861      620875      620869
%           -1          -1          -1      624830      624831      624901
%       628819      628836      628827          -1          -1          -1
%           -1      632859      632842          -1          -1          -1
%           -1          -1          -1      636843      636841      636795
%       640886      640886      640857          -1          -1          -1
%           -1          -1          -1      644843      644847      644836
%           -1          -1          -1      648850      648863      648878
%       652906      652874      652858          -1          -1          -1
%       656873      656888      656865          -1          -1          -1
%       660920      660889      660868          -1          -1          -1
%           -1          -1          -1      664865      664877      664886
%           -1          -1          -1      668844      668864      668897
%           -1          -1          -1      672845      672863      672919
%           -1          -1          -1      676859      676876      676901
%           -1          -1          -1      680855      680852      680840
%       685818          -1          -1      684852      684852      684895
%           -1      688877      688868          -1          -1          -1
%           -1          -1          -1      692848      692860      692857
%       696896      696904      696878          -1          -1          -1
%           -1          -1          -1      700866      700899      700902
%       704921      704895      704879          -1          -1          -1
%       708899      708890      708879          -1          -1          -1
%       712897      712890      712881          -1          -1          -1
%       716843      716869      716862          -1          -1          -1
%           -1          -1          -1      720897      720923      720835
%           -1      724890      724870          -1          -1          -1
%       728876      728856      728861          -1          -1          -1
%       732884      732882      732868          -1          -1          -1
%           -1          -1          -1      736951          -1          -1
%       740960      740900      740883          -1          -1          -1
%           -1          -1          -1      744878      744891      744864
%       748927      748909      748890          -1          -1          -1
%       752927      752915      752885          -1          -1          -1
%       757454          -1          -1      756905      756940      756935
%       760867      760869      760875          -1          -1          -1
%           -1          -1          -1      764912      764928      764944
%           -1          -1          -1      768936      768976      768976
%           -1          -1          -1      772904      772927      773014
%           -1      776896      776890          -1          -1          -1
%           -1          -1          -1      780878      780894      780919
%           -1      784924      784901          -1          -1          -1
%           -1          -1          -1      788880      788900      788902
%       793816          -1          -1      792869      792881      792931
%           -1      796938      796915          -1          -1          -1
%           -1          -1          -1      800925      800921      800908
%           -1          -1          -1      804933      804952      804931
%           -1          -1          -1          -1          -1          -1
%       812954      812930      812911          -1          -1          -1
%       816962      816937      816917          -1          -1          -1
%       822305      822308          -1      820890      820888      820692
%           -1          -1          -1      824889      824886      824895
%           -1      828915      828904      829720          -1          -1
%           -1          -1          -1          -1      832877      832853
%           -1          -1          -1      836887      836899      836989
%           -1          -1          -1      840921      840951      840859
%           -1      844925      844907          -1          -1          -1
%           -1      850054          -1      848897      848907      848973
%           -1          -1          -1      852888      852896      852829
%       857532          -1          -1          -1          -1          -1
%       860917      860928      860915          -1          -1          -1
%       864958      864938      864930          -1          -1          -1
%       868898      868906      868905          -1          -1          -1
%       872929      872918      872907          -1          -1          -1
%       876891      876912      876912          -1          -1          -1
%           -1          -1          -1      880918      880919      880909
%           -1      886110          -1      884918      884920      884953
%           -1          -1      888919          -1          -1          -1
%           -1      892948      892927          -1          -1          -1
%       896957      896928
%       896916          -1          -1          -1
%       900908      900941      900928          -1          -1          -1
%           -1          -1          -1      904914      904934      904937
%       908947      908964      908939          -1          -1          -1
%       912956      912948      912926          -1          -1          -1
%       916951      916947      916931          -1          -1          -1
%           -1          -1          -1      920938      920942      920939
%           -1          -1          -1      924967      924994      924833
%           -1          -1          -1      928950      928985      928968
%           -1          -1          -1      932966          -1      932974
%       937017      936935      936915          -1          -1          -1
%           -1          -1          -1      940944      940977      940960
%           -1          -1          -1      944914      944914      944915
%       948917      948933      948924          -1          -1          -1
%           -1          -1          -1      952928      952939      952984
%       956912      956943      956938          -1          -1          -1