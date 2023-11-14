%% Change Peak Conditions
%Misclassified condition of 1 or more groups of stimulation
%Run directly after ALICStimEP - do not clear workspace

%% Condition was mislabelled as existing condition (ie - 5 conditions instead of 6)
%Condition needed
condition_Num = 6;

%Condition of group is stuck within another condition
index = 1218190; %location at the start of wrong condition
condition = L.locs>=index-5; %range to change (-5 for a cushion)

%%DO NOT EDIT BELOW HERE------------------------------------------------------------------
change_cond = find(condition);%idenitfy location of targeted region

L.Cond_Nums(change_cond:end) = condition_Num; %fix condition

%% Image Label Adjustment
f5 = figure
hold on
yyaxis left
plot(T.Selected_Chan)
plot(L.locs,T.Selected_Chan(L.locs),'r.', 'markersize', 24)
ylabel('Voltage')
xlabel('Sample Number')
yyaxis right
plot(L.locs,L.Cond_Nums,'p')
ylabel('Condition No.')
legend('Processed Signal','R Peak','Condition Number')
hold off
savefig("Final_Stim_Conditions")

%% Write new labels
%%% Print Labels
filename = sprintf("NS_Label_%s.txt",folder); 

fileID = fopen(filename,'w');
for i = 1:height(L)
    if L.Cond_Nums(i)>0 && L.Cond_Nums(i)<= length(conditions)
        fprintf(fileID,'%s\n',conditions{L.Cond_Nums(i)});
    end
end
fclose(fileID);