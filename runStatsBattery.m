function [statsT] = runStatsBattery(animalBhvrT,sessDir,sName)
% 3/2/2021 LKW
% Input
parentDir = pwd;
cd(sessDir);

cleanT = animalBhvrT;
for i = 1:height(animalBhvrT)
    if animalBhvrT.stimType(i) == 'Square20Hz'
        delV(i) = 0;
    elseif animalBhvrT.stimType(i) == 'Square8Hz'
        delV(i) = 0;
    elseif animalBhvrT.stimType(i) == 'Triangle20Hz'
        delV(i) = 0;
    elseif animalBhvrT.stimType(i) == 'Triangle8Hz'
        delV(i) = 0; 
    else
        delV(i) = 1;
    end
end
cleanT(logical(delV)',:) = [];

pairVect = [cleanT.offAcc(:), cleanT.onAcc(:)];
%Parametric version of off Accuracy vs on Accuracy
[pairT_h,pairT_p,pairT_ci,pairT_stats] = ttest(pairVect(:,1),pairVect(:,2));
%Non-Parametric version of off Accuracy vs on Accuracy
[wilc_p,wilc_h,wilc_stats] = ranksum(pairVect(:,1),pairVect(:,2));

anovaVect = [cleanT.offAcc(:), cleanT.onAcc(:), cleanT.postAcc(:)];
%Parametric version of off Accuracy vs on Accuracy vs n+1 Accuracy
[anova_p,anova_tbl,anova_stats] = anova1(anovaVect,[],'off');
%Non-Parametric version of off Accuracy vs on Accuracy vs n+1 Accuracy
[kw_p,kw_tbl,kw_stats] = kruskalwallis(anovaVect,[],'off');
%
[fried_p,fried_tbl,fried_stats] = friedman(anovaVect,1,'off');

statsT = table('Size',[1 5],'VariableTypes',{'double','double','double','double','double'},'VariableNames',{'Paired_T','Wilcoxon','ANOVA','K_Wallis','Friedman'});
statsT.Paired_T = pairT_p; statsT.Wilcoxon = wilc_p; statsT.ANOVA = anova_p; statsT.K_Wallis = kw_p; statsT.Friedman = fried_p;

save(sName,'statsT');

cd(parentDir)
end