%Compare rater counts ACCA vs LKW vs WBS
% addpath('G:\Shared drives\HasselmoUsers\lwilmerd\Code')
% cts_LKW = readtable('E:\ACCA\SD_10x_Validation\Cell_Counts_Manual_LKW.csv');
% cts_WBS = readtable('E:\ACCA\SD_10x_Validation\Cell_Counts_Manual_WBS.csv');
cts_LKW = readtable('F:\Research\Experimental\DG_nonsense_project\Analysis\cell_count_validation\Cell_Counts_Manual_LKW.csv');
cts_WBS = readtable('F:\Research\Experimental\DG_nonsense_project\Analysis\cell_count_validation\Cell_Counts_Manual_WBS.csv');

saveFlag = 1;
saveDir = 'F:\Research\Experimental\DG_nonsense_project\Analysis\cell_count_validation\';

%% Compare eYFP across raters

eyfp_aca = cts_WBS.eYFPCounts;
eyfp_lkw = [cts_LKW.eYFPManualCounts(2:end); 39];   %Correct for ACCA bug
eyfp_wbs = cts_WBS.eYFPManualCounts;

[rhos.lkwwbs_eyfp,ps.lkwwbs_eyfp] = corr(eyfp_lkw,eyfp_wbs,'Type','Pearson','rows','complete');
[rhos.acalkw_eyfp,ps.acalkw_eyfp] = corr(eyfp_aca,eyfp_lkw,'Type','Pearson','rows','complete');
[rhos.acawbs_eyfp,ps.acawbs_eyfp] = corr(eyfp_aca,eyfp_wbs,'Type','Pearson','rows','complete');

mdl_eyfp_acalkw = fitlm(eyfp_aca,eyfp_lkw);
mdl_eyfp_acalkw_ys = predict(mdl_eyfp_acalkw,[min(eyfp_aca);max(eyfp_aca)]);

mdl_eyfp_acawbs = fitlm(eyfp_aca,eyfp_wbs);
mdl_eyfp_acawbs_ys = predict(mdl_eyfp_acawbs,[min(eyfp_aca);max(eyfp_aca)]);

manVauto_eyfp_fig = figure; hold on; axis square
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.27,0.525]);
plot([min(eyfp_aca),max(eyfp_aca)],mdl_eyfp_acalkw_ys,'LineWidth',2,'Color',[0.6 1 0.1])
plot([min(eyfp_aca),max(eyfp_aca)],mdl_eyfp_acawbs_ys,'LineWidth',2,'Color',[0.3 0.8 0.1])
scatter(eyfp_aca,eyfp_lkw,25,'MarkerEdgeColor',[0.6 1 0.1],'MarkerFaceColor',[0.6 1 0.1]);
scatter(eyfp_aca,eyfp_wbs,25,'MarkerEdgeColor',[0.3 0.8 0.1],'MarkerFaceColor',[0.3 0.8 0.1]);
% xlim([10 65]); ylim([10 65])
legend({'Rater 1', 'Rater 2'},'Location','nw')
ylabel('eYFP Counts Manual'); xlabel('eYFP Counts Auto');
set(gca,'FontSize',16,'FontName','Arial')

%% Compare cFos across raters

cfos_aca = cts_WBS.cFosCounts;
cfos_lkw = [cts_LKW.cFosManualCounts(2:end); cts_LKW.cFosManualCounts(1)];   %Correct for ACCA bug
cfos_wbs = cts_WBS.cFosManualCounts;

[rhos.lkwwbs_cfos,ps.lkwwbs_cfos] = corr(cfos_lkw,cfos_wbs,'Type','Pearson','rows','complete');
[rhos.lkwaca_cfos,ps.lkwaca_cfos] = corr(cfos_lkw,cfos_aca,'Type','Pearson','rows','complete');
[rhos.wbsaca_cfos,ps.wbsaca_cfos] = corr(cfos_wbs,cfos_aca,'Type','Pearson','rows','complete');

mdl_cfos_acalkw = fitlm(cfos_aca,cfos_lkw);
mdl_cfos_acalkw_ys = predict(mdl_cfos_acalkw,[min(cfos_aca);max(cfos_aca)]);

mdl_cfos_acawbs = fitlm(cfos_aca,cfos_wbs);
mdl_cfos_acawbs_ys = predict(mdl_cfos_acawbs,[min(cfos_aca);max(cfos_aca)]);

manVauto_cfos_fig = figure; hold on; axis square
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.27,0.525]);
plot([min(cfos_aca),max(cfos_aca)],mdl_cfos_acalkw_ys,'LineWidth',2,'Color',[1 0.6 0.1])
plot([min(cfos_aca),max(cfos_aca)],mdl_cfos_acawbs_ys,'LineWidth',2,'Color',[1 0 0])
scatter(cfos_aca,cfos_lkw,25,'MarkerEdgeColor',[1 0.6 0.1],'MarkerFaceColor',[1 0.6 0.1]);
scatter(cfos_aca,cfos_wbs,25,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0]);
% xlim([10 65]); ylim([10 65])
legend({'Rater 1', 'Rater 2'},'Location','nw')
ylabel('cFos Counts Manual'); xlabel('cFos Counts Auto');
set(gca,'FontSize',16,'FontName','Arial')

%% Save Auto Compares
if saveFlag == 1
    saveFigTypes(manVauto_cfos_fig,[saveDir,'countComp_cfos_corr_manVauto'])
    saveFigTypes(manVauto_eyfp_fig,[saveDir,'countComp_eyfp_corr_manVauto'])
    save([saveDir, 'cellCountValidation_stats'],'ps','rhos')
end

%% Prep Cell Count Table averages
corrType = 'Pearson';
% plotDir = 'F:\Research\Experimental\DG_nonsense_project\Analysis\OBC_Final\OBC_expVsctl_cellcount\';
plotDir = 'F:\Research\Experimental\DG_nonsense_project\Analysis\OBCD_Final\OBCD_expVsctl\';
saveBase = 'OBCD_Blade_Avg_Count.mat';

% ZZ_T = readtable('G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\OBC Group\OBC_Imaging\cfos_prob_0_8_Cell_Counts_Final.csv');
% ZZ_T = readtable('G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\OBCC Group\cfos_prob_0_8_Cell_Counts_Final.csv');
% ZZ_T = readtable('F:\Research\Experimental\DG_nonsense_project\Cell Count Data\OBC_Blade_Counts_Final.xlsx');
% ZZ_T = readtable('F:\Research\Experimental\DG_nonsense_project\Cell Count Data\OBCC_Blade_Counts_Final_cfos_prob_0_8.csv');
ZZ_T = readtable('F:\Research\Experimental\DG_nonsense_project\Cell Count Data\OBCD_Hilus_Cell_Counts_Final.csv');

clear tmpT mouse

for i = 1:height(ZZ_T)
    mouse(i) = strtok(ZZ_T.File(i),'_');
end

ZZ_T.mouse = mouse';

% % Exclude aadHPC slice for OBC group
% ZZ_T(21,:) = [];

mNames = unique(ZZ_T.mouse);

MM_T_avg = ZZ_T(1,:);
for i = 1:numel(mNames)
    mousetmp = mNames{i};
    tmpT = ZZ_T(find(ZZ_T.mouse == string(mousetmp)),:);
    MM_T_avg(i,:) = tmpT(1,:);
    MM_T_avg.DapiCounts(i) = mean(tmpT.DapiCounts);
    MM_T_avg.eYFPCounts(i) = mean(tmpT.eYFPCounts);
    MM_T_avg.CfosCounts(i) = mean(tmpT.CfosCounts);
%     MM_T_avg.eYFP_OL(i) = mean(tmpT.eYFP_OL);
%     MM_T_avg.cFos_OL(i) = mean(tmpT.cFos_OL);
    MM_T_avg.CfosXEYFPOverlapCounts(i) = mean(tmpT.CfosXEYFPOverlapCounts);
%     MM_T_avg.autoCount_z_adjust(i) = mean(tmpT.autoCount_z_adjust);
%     MM_T_avg.dapi_OL(i) = mean(tmpT.dapi_OL);
end

if saveFlag; save(saveBase,'MM_T_avg'); end

%% Load behavior and average within mouse
cd('F:\Research\Experimental\DG_nonsense_project\Cell Count Data');
load('OBC_Blade_Avg_Count.mat'); OBC_BladeT = MM_T_avg;
OBC_BladeT = OBC_BladeT(3:end,:);   %Remove subiculum tagged OBC 17 and 19
load('OBCC_Blade_Avg_Count.mat'); OCC_BladeT = MM_T_avg;
% cd('F:\Research\Experimental\DG_nonsense_project\Analysis\OBC_Final');
% load('expBhvrT.mat'); load('ctlBhvrT.mat');
cd('F:\Research\Experimental\DG_nonsense_project\Analysis\OBC_Final\OBC_6Cohort\');
load('expBhvrT.mat'); load('ctlBhvrT.mat');

ps = struct; stats = struct;
nExp = size(expBhvrT.sessionID,1)/5;
nCtl = size(ctlBhvrT.sessionID,1)/5;
accOBC = mean(reshape(expBhvrT.onAcc,5,nExp))';
offOBC = mean(reshape(expBhvrT.totOffAcc,5,nExp))';
accOCC = mean(reshape(ctlBhvrT.onAcc,5,nCtl))';
offOCC = mean(reshape(ctlBhvrT.totOffAcc,5,nCtl))';

obc_ed = OBC_BladeT.eYFPArea ./ OBC_BladeT.DapiArea;
obc_cd = OBC_BladeT.CfosArea ./ OBC_BladeT.DapiArea;
obc_od = OBC_BladeT.CfosXEYFPOverlapArea ./ OBC_BladeT.DapiArea;
obc_ch = obc_od ./ (obc_ed .* obc_cd);  % (OL / Dapi) / (eyfp/dapi * cfos/dapi)

occ_ed = OCC_BladeT.eYFPArea ./ OCC_BladeT.DapiArea;
occ_cd = OCC_BladeT.CfosArea ./ OCC_BladeT.DapiArea;
occ_od = OCC_BladeT.CfosXEYFPOverlapArea ./ OCC_BladeT.DapiArea;
occ_ch = occ_od ./ (occ_ed .* occ_cd);

%% Correlate Raw DG Blade counts to behavior
cd(plotDir)

reds = [1 0.6 0.1; 1 0 0];
grns = [0.6 1 0.1; 0.3 0.8 0.1];
ylws = [0.9 0.7 0.075; 0.9 0.9 0.2];

[tmprho,tmpp,fig_eyfp] = plotStainVBhvr_comp(OBC_BladeT.eYFPCounts,OCC_BladeT.eYFPCounts,accOBC,accOCC,grns,corrType);
xlabel('eYFP Count'); ylabel('Laser On Accuracy'); legend({'OBC','OBCC'},'location','se')
rhos.obc_eyfpVmaccon = tmprho(1); rhos.obcc_eyfpVmaccon = tmprho(2); ps.obc_eyfpVmaccon = tmpp(1); ps.obcc_eyfpVmaccon = tmpp(2);
[tmprho,tmpp,fig_cfos] = plotStainVBhvr_comp(OBC_BladeT.CfosCounts,OCC_BladeT.CfosCounts,accOBC,accOCC,reds,corrType);
xlabel('cFos Count'); ylabel('Laser On Accuracy'); legend({'OBC','OBCC'},'location','se')
rhos.obc_cfosVmaccon = tmprho(1); rhos.obcc_cfosVmaccon = tmprho(2); ps.obc_cfosVmaccon = tmpp(1); ps.obcc_cfosVmaccon = tmpp(2);
[tmprho,tmpp,fig_ovlp] = plotStainVBhvr_comp(OBC_BladeT.CfosXEYFPOverlapCounts./OBC_BladeT.eYFPCounts,OCC_BladeT.CfosXEYFPOverlapCounts./OCC_BladeT.eYFPCounts,accOBC,accOCC,ylws,corrType);
xlabel('Overlap / eYFP'); ylabel('Laser On Accuracy'); legend({'OBC','OBCC'},'location','se')
rhos.obc_ovlpVmaccon = tmprho(1); rhos.obcc_ovlpVmaccon = tmprho(2); ps.obc_ovlpVmaccon = tmpp(1); ps.obcc_ovlpVmaccon = tmpp(2);

[tmprho,tmpp,fig_eyfp_off] = plotStainVBhvr_comp(OBC_BladeT.eYFPCounts,OCC_BladeT.eYFPCounts,offOBC,offOCC,grns,corrType);
xlabel('eYFP Count'); ylabel('Laser Off Accuracy');
rhos.obc_eyfpVmaccoff = tmprho(1); rhos.obcc_eyfpVmaccoff = tmprho(2); ps.obc_eyfpVmaccoff = tmpp(1); ps.obcc_eyfpVmaccoff = tmpp(2);
[tmprho,tmpp,fig_cfos_off] = plotStainVBhvr_comp(OBC_BladeT.CfosCounts,OCC_BladeT.CfosCounts,offOBC,offOCC,reds,corrType);
xlabel('cFos Count'); ylabel('Laser Off Accuracy');
rhos.obc_cfosVmaccoff = tmprho(1); rhos.obcc_cfosVmaccoff = tmprho(2); ps.obc_cfosVmaccoff = tmpp(1); ps.obcc_cfosVmaccoff = tmpp(2);
[tmprho,tmpp,fig_ovlp_off] = plotStainVBhvr_comp(OBC_BladeT.CfosXEYFPOverlapCounts./OBC_BladeT.eYFPCounts,OCC_BladeT.CfosXEYFPOverlapCounts./OCC_BladeT.eYFPCounts,offOBC,offOCC,ylws,corrType);
xlabel('Overlap / eYFP'); ylabel('Laser Off Accuracy');
rhos.obc_ovlpVmaccoff = tmprho(1); rhos.obcc_ovlpVmaccoff = tmprho(2); ps.obc_ovlpVmaccoff = tmpp(1); ps.obcc_ovlpVmaccoff = tmpp(2);

if saveFlag
    saveFigTypes(fig_eyfp,[plotDir 'bladeCount_eYFP_on_OBCVSOBCC'])
    saveFigTypes(fig_cfos,[plotDir 'bladeCount_cFos_on_OBCVSOBCC'])
    saveFigTypes(fig_ovlp,[plotDir 'bladeCount_OL_on_OBCVSOBCC'])
    saveFigTypes(fig_eyfp_off,[plotDir 'bladeCount_eYFP_off_OBCVSOBCC'])
    saveFigTypes(fig_cfos_off,[plotDir 'bladeCount_cFos_off_OBCVSOBCC'])
    saveFigTypes(fig_ovlp_off,[plotDir 'bladeCount_OL_off_OBCVSOBCC'])
end

%% DG Blade Behavior Correlations DNMP Acc DELTA by Raw Count 

[tmprho,tmpp,fig_eyfp_delta] = plotStainVBhvr_comp(OBC_BladeT.eYFPCounts,OCC_BladeT.eYFPCounts,accOBC-offOBC,accOCC-offOCC,grns,corrType);
xlabel('eYFP Count'); ylabel('\Delta DNMP Accuracy'); ylim([-.3 .3]); legend({'OBC','OBCC'},'location','ne')
rhos.obc_blade_eyfpVmaccDelta = tmprho(1); rhos.obcc_blade_eyfpVmaccDelta = tmprho(2); ps.obc_blade_eyfpVmaccDelta = tmpp(1); ps.obcc_blade_eyfpVmaccDelta = tmpp(2);
[tmprho,tmpp,fig_cfos_delta] = plotStainVBhvr_comp(OBC_BladeT.CfosCounts,OCC_BladeT.CfosCounts,accOBC-offOBC,accOCC-offOCC,reds,corrType);
xlabel('cFos Count'); ylabel('\Delta DNMP  Accuracy'); ylim([-.3 .3]); legend({'OBC','OBCC'},'location','ne')
rhos.obc_blade_cfosVmaccDelta = tmprho(1); rhos.obcc_blade_cfosVmaccDelta = tmprho(2); ps.obc_blade_cfosVmaccDelta = tmpp(1); ps.obcc_blade_cfosVmaccDelta = tmpp(2);
[tmprho,tmpp,fig_ovlp_delta] = plotStainVBhvr_comp(OBC_BladeT.CfosXEYFPOverlapCounts,OCC_BladeT.CfosXEYFPOverlapCounts,accOBC-offOBC,accOCC-offOCC,ylws,corrType);
xlabel('Overlap Count'); ylabel('\Delta DNMP  Accuracy'); ylim([-.3 .3]); legend({'OBC','OBCC'},'location','ne')
rhos.obc_blade_ovlpVmaccDelta = tmprho(1); rhos.obcc_blade_ovlpVmaccDelta = tmprho(2); ps.obc_blade_ovlpVmaccDelta = tmpp(1); ps.obcc_blade_ovlpVmaccDelta = tmpp(2);

if saveFlag
    saveFigTypes(fig_eyfp_delta,[plotDir 'bladeCount_eYFP_delta_OBCVSOBCC'])
    saveFigTypes(fig_cfos_delta,[plotDir 'bladeCount_cFos_delta_OBCVSOBCC'])
    saveFigTypes(fig_ovlp_delta,[plotDir 'bladeCount_OL_delta_OBCVSOBCC'])
end

%% Correlate Chance-Normalized Blade Counts to Behavior

[tmprho,tmpp,fig_ed] = plotStainVBhvr_comp(obc_ed,occ_ed,accOBC,accOCC,grns,corrType);
xlabel('eYFP / Dapi Area'); ylabel('Laser On Accuracy');
rhos.obc_edVmaccon = tmprho(1); rhos.obcc_edVmaccon = tmprho(2); ps.obc_edVmaccon = tmpp(1); ps.obcc_edVmaccon = tmpp(2);
[tmprho,tmpp,fig_cd] = plotStainVBhvr_comp(obc_cd,occ_cd,accOBC,accOCC,reds,corrType);
xlabel('cFos / Dapi Area'); ylabel('Laser On Accuracy');
rhos.obc_cdVmaccon = tmprho(1); rhos.obcc_cdVmaccon = tmprho(2); ps.obc_cdVmaccon = tmpp(1); ps.obcc_cdVmaccon = tmpp(2);
[tmprho,tmpp,fig_ch] = plotStainVBhvr_comp(obc_ch,occ_ch,accOBC,accOCC,ylws,corrType);
xlabel('Overlap Area / Chance'); ylabel('Laser On Accuracy');
rhos.obc_chVmaccon = tmprho(1); rhos.obcc_chVmaccon = tmprho(2); ps.obc_chVmaccon = tmpp(1); ps.obcc_chVmaccon = tmpp(2);

[tmprho,tmpp,fig_ed_off] = plotStainVBhvr_comp(obc_ed,occ_ed,offOBC,offOCC,grns,corrType);
xlabel('eYFP / Dapi Area'); ylabel('Laser Off Accuracy');
rhos.obc_edVmaccoff = tmprho(1); rhos.obcc_edVmaccoff = tmprho(2); ps.obc_edVmaccoff = tmpp(1); ps.obcc_edVmaccoff = tmpp(2);
[tmprho,tmpp,fig_cd_off] = plotStainVBhvr_comp(obc_cd,occ_cd,offOBC,offOCC,reds,corrType);
xlabel('cFos / Dapi Area'); ylabel('Laser Off Accuracy');
rhos.obc_cdVmaccoff = tmprho(1); rhos.obcc_cdVmaccoff = tmprho(2); ps.obc_cdVmaccoff = tmpp(1); ps.obcc_cdVmaccoff = tmpp(2);
[tmprho,tmpp,fig_ch_off] = plotStainVBhvr_comp(obc_ch,occ_ch,offOBC,offOCC,ylws,corrType);
xlabel('Overlap Area / Chance'); ylabel('Laser Off Accuracy');
rhos.obc_chVmaccoff = tmprho(1); rhos.obcc_chVmaccoff = tmprho(2); ps.obc_chVmaccoff = tmpp(1); ps.obcc_chVmaccoff = tmpp(2);

if saveFlag
    saveFigTypes(fig_ed,[plotDir 'bladeCount_eYFPDapiArea_on_OBCVSOBCC'])
    saveFigTypes(fig_cd,[plotDir 'bladeCount_cFosDapiArea_on_OBCVSOBCC'])
    saveFigTypes(fig_ch,[plotDir 'bladeCount_OLChance_on_OBCVSOBCC'])
    saveFigTypes(fig_ed_off,[plotDir 'bladeCount_eYFPDapiArea_off_OBCVSOBCC'])
    saveFigTypes(fig_cd_off,[plotDir 'bladeCount_cFosDapiArea_off_OBCVSOBCC'])
    saveFigTypes(fig_ch_off,[plotDir 'bladeCount_OLChance_off_OBCVSOBCC'])
end

%% DG Blade Behavior Correlations DNMP Acc DELTA by normalized area 

[tmprho,tmpp,fig_ed_delta] = plotStainVBhvr_comp(obc_ed,occ_ed,accOBC-offOBC,accOCC-offOCC,grns,corrType);
xlabel('eYFP / Dapi Area'); ylabel('\Delta DNMP Accuracy'); ylim([-.3 .3]); legend({'OBC','OBCC'},'location','ne')
rhos.obc_blade_edVmaccDelta = tmprho(1); rhos.obcc_blade_edVmaccDelta = tmprho(2); ps.obc_blade_edVmaccDelta = tmpp(1); ps.obcc_blade_edVmaccDelta = tmpp(2);
[tmprho,tmpp,fig_cd_delta] = plotStainVBhvr_comp(obc_cd,occ_cd,accOBC-offOBC,accOCC-offOCC,reds,corrType);
xlabel('cFos / Dapi Area'); ylabel('\Delta DNMP  Accuracy'); ylim([-.3 .3]); legend({'OBC','OBCC'},'location','ne')
rhos.obc_blade_cdVmaccDelta = tmprho(1); rhos.obcc_blade_cdVmaccDelta = tmprho(2); ps.obc_blade_cdVmaccDelta = tmpp(1); ps.obcc_blade_cdVmaccDelta = tmpp(2);
[tmprho,tmpp,fig_ch_delta] = plotStainVBhvr_comp(obc_ch,occ_ch,accOBC-offOBC,accOCC-offOCC,ylws,corrType);
xlabel('Overlap Area / Chance'); ylabel('\Delta DNMP  Accuracy'); ylim([-.3 .3]); legend({'OBC','OBCC'},'location','ne')
rhos.obc_blade_chVmaccDelta = tmprho(1); rhos.obcc_blade_chVmaccDelta = tmprho(2); ps.obc_blade_chVmaccDelta = tmpp(1); ps.obcc_blade_chVmaccDelta = tmpp(2);

if saveFlag
    saveFigTypes(fig_ed_delta,[plotDir 'bladeCount_eYFPDapiArea_delta_OBCVSOBCC'])
    saveFigTypes(fig_cd_delta,[plotDir 'bladeCount_cFosDapiArea_delta_OBCVSOBCC'])
    saveFigTypes(fig_ch_delta,[plotDir 'bladeCount_OLChance_delta_OBCVSOBCC'])
    save([plotDir 'OBC_bladeCount_stats'],'ps','rhos')
end

%% Plot average counts eYFP, cFos and Overlap

[~,ps.blade_rawct_cfos,~,stats.blade_rawct_cfos] = ttest2(OCC_BladeT.CfosCounts,OBC_BladeT.CfosCounts);
[~,ps.blade_rawct_eyfp,~,stats.blade_rawct_eyfp] = ttest2(OCC_BladeT.eYFPCounts,OBC_BladeT.eYFPCounts);
[~,ps.blade_rawct_ovlp,~,stats.blade_rawct_ovlp] = ttest2(OCC_BladeT.CfosXEYFPOverlapCounts,OBC_BladeT.CfosXEYFPOverlapCounts);
% [~,ps.nrmct_ovlpeyfp_ctlVexp,~,stats.nrmct_ovlpeyfp_ctlVexp] = ttest2(nrm_ovlpeyfp_ctl,nrm_ovlpeyfp_exp);
% [~,ps.nrmct_ovlpcfos_ctlVexp,~,stats.nrmct_ovlpcfos_ctlVexp] = ttest2(nrm_ovlpcfos_ctl,nrm_ovlpcfos_exp);

cfosCols = [0.7 0.1 0.1; 1 0 0];
eyfpCols = [0.3 0.8 0.1; 0.6 1 0.1]; 
ovlpCols = [0.9 0.7 0.075; 0.9 0.9  0.2];

if saveFlag; fname_c_raw = strcat('OBC_Blade_RawCt_cFos'); else; fname_c_raw = 0; end
fig_raw_cfos = plot_obc_rawcellct(OCC_BladeT.CfosCounts,OBC_BladeT.CfosCounts,cfosCols,fname_c_raw);
ylabel('cFos Count'); ylim([50 225]);
if saveFlag; fname_e_raw = strcat('OBC_Blade_RawCt_eYFP'); else; fname_e_raw = 0; end
fig_raw_eyfp = plot_obc_rawcellct(OCC_BladeT.eYFPCounts,OBC_BladeT.eYFPCounts,eyfpCols,fname_e_raw);
ylabel('eYFP Count'); ylim([0 700]);
if saveFlag; fname_o_raw = strcat('OBC_Blade_RawCt_Ovlp'); else; fname_o_raw = 0; end
fig_raw_ovlp = plot_obc_rawcellct(OCC_BladeT.CfosXEYFPOverlapCounts,OBC_BladeT.CfosXEYFPOverlapCounts,ovlpCols,fname_o_raw);
ylabel('Overlap Count'); ylim([0 70]);
% fig_nrm_ovlpeyfp = plot_obc_rawcellct(nrm_ovlpeyfp_ctl, nrm_ovlpeyfp_exp,ovlpCols,0);
% ylabel('eYFP Normalized Overlap'); ylim([0 0.5]);

%% Plot chance-normalized blade overlap and compare vs 0
[~,ps.obc_blade_chV0,~,stats.obc_blade_chV0] = ttest(1-obc_ch);
[~,ps.occ_blade_chV0,~,stats.occ_blade_chV0] = ttest(1-occ_ch);

if saveFlag; fname_o_nrm = strcat('OBC_Blade_NrmChance_Ovlp'); else; fname_o_nrm = 0; end
fig_ch_ovlp = plot_obc_rawcellct(occ_ch,obc_ch,flipud(ovlpCols),fname_o_nrm);
ylabel('Overlap Area / Chance');

%% Hilus Cell Counts - Old version of Organize Data with all mice in 1 table
corrType = 'Pearson';
% Load and clean behavior
% load('G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\Analysis\OBC_Analysis\OBC_cohort_n7_reanalysis_lapTable')
load('G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\Analysis\OBC_Analysis\OBC_hilus_cohort\OBC_hilus_cohort_lapTable.mat')
tagInd = bhvrT.day == 0;
% mInd = contains(bhvrT.sessionID, 'OBC17') | contains(bhvrT.sessionID, 'OBC19') | contains(bhvrT.sessionID, 'OBC4');
% xInds = (tagInd + mInd) > 0;
exptT = bhvrT;
exptT(tagInd,:) = [];
nMice = length(exptT.day)/5;
accOBC = mean(reshape(exptT.onAcc,5,nMice))';
offOBC = mean(reshape(exptT.totOffAcc,5,nMice))';

load('G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\Analysis\OBCC_Analysis\OBCC_Cohort01-06_lapTable.mat')
tagInd = bhvrT.day == 0;
ctlT = bhvrT;
ctlT(tagInd,:) = [];
nMice = length(ctlT.day)/5;
accOCC = mean(reshape(ctlT.onAcc,5,nMice))';
offOCC = mean(reshape(ctlT.totOffAcc,5,nMice))';

%Load and organize cell count data
% HiT = readtable('E:\OptoBehaviorProject\OBC\OBC_CellCount_Hilus\OBC_CellCount_Hilus_ACCA_Output_00252024\Cell_Counts_Final_hilus.csv');
HiT = readtable('G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\Analysis\OBC_Analysis\OBC_hilus_cohort\Cell_Counts_Hilus_Sub.csv');

ZZ_T = HiT(HiT.Group == 1,:);  %Just the higher laser images

% Avg table then split by group (messy)
OCC_HilusT = MM_T_avg(MM_T_avg.mGroup == "OBCC",:);
OBC_HilusT = MM_T_avg(MM_T_avg.mGroup == "OBC",:);

%% Hilus Count Load new split Excel tables and average
corrType = 'Pearson';
plotDir = 'F:\Research\Experimental\DG_nonsense_project\Analysis\OBC_Final\OBC_expVsctl_cellcount\';
saveBase = 'OBCC_Hilus_Avg_Count.mat';
saveFlag = 1;

% ZZ_T = readtable('F:\Research\Experimental\DG_nonsense_project\Cell Count Data\OBC_Hilus_Counts_Final.csv');
ZZ_T = readtable('F:\Research\Experimental\DG_nonsense_project\Cell Count Data\OBCC_Hilus_Counts_Final.csv');

for i = 1:height(ZZ_T)
    mouse(i) = strtok(ZZ_T.File(i),'_');
end

ZZ_T.mouse = mouse';
ZZ_T.mGroup = repmat("x",[height(ZZ_T),1]);

mNames = unique(ZZ_T.mouse);

MM_T_avg = ZZ_T(1,:);
clear tmpT
for i = 1:numel(mNames)
    mousetmp = mNames{i};
    tmpT = ZZ_T(ZZ_T.mouse == string(mousetmp),:);
    MM_T_avg(i,:) = tmpT(1,:);
    MM_T_avg.eYFPCounts(i) = mean(tmpT.eYFPCounts);
    MM_T_avg.cFosCounts(i) = mean(tmpT.cFosCounts);
    MM_T_avg.CfosXEYFPOverlapCounts(i) = mean(tmpT.CfosXEYFPOverlapCounts);
    MM_T_avg.DapiArea(i)   = mean(tmpT.DapiArea);
    MM_T_avg.eYFPArea(i)   = mean(tmpT.eYFPArea);
    MM_T_avg.cFosArea(i)   = mean(tmpT.cFosArea);
    MM_T_avg.CfosXEYFPOverlapArea(i) = mean(tmpT.CfosXEYFPOverlapArea);
    if contains(mousetmp,'OBCC')
        MM_T_avg.mGroup(i) = 'OBCC';
    else
        MM_T_avg.mGroup(i) = 'OBC';
    end
end

if saveFlag; save(saveBase,'MM_T_avg'); end

%% Load behavior and average within mouse
cd('F:\Research\Experimental\DG_nonsense_project\Cell Count Data');
load('OBC_Hilus_Avg_Count.mat'); OBC_HilusT = MM_T_avg;
OBC_HilusT = OBC_HilusT(3:end,:);   %Remove subiculum tagged OBC 17 and 19
load('OBCC_Hilus_Avg_Count.mat'); OCC_HilusT = MM_T_avg;
% cd('F:\Research\Experimental\DG_nonsense_project\Analysis\OBC_Final');
% load('expBhvrT.mat'); load('ctlBhvrT.mat');
cd('F:\Research\Experimental\DG_nonsense_project\Analysis\OBC_Final\OBC_6Cohort\');
load('expBhvrT.mat'); load('ctlBhvrT.mat');

ps = struct; rhos = struct;
nExp = size(expBhvrT.sessionID,1)/5;
nCtl = size(ctlBhvrT.sessionID,1)/5;
accOBC = mean(reshape(expBhvrT.onAcc,5,nExp))';
offOBC = mean(reshape(expBhvrT.totOffAcc,5,nExp))';
accOCC = mean(reshape(ctlBhvrT.onAcc,5,nCtl))';
offOCC = mean(reshape(ctlBhvrT.totOffAcc,5,nCtl))';

obc_ed = OBC_HilusT.eYFPArea ./ OBC_HilusT.DapiArea;
obc_cd = OBC_HilusT.cFosArea ./ OBC_HilusT.DapiArea;
obc_od = OBC_HilusT.CfosXEYFPOverlapArea ./ OBC_HilusT.DapiArea;
obc_ch = obc_od ./ (obc_ed .* obc_cd);  % (OL / Dapi) / (eyfp/dapi * cfos/dapi)

occ_ed = OCC_HilusT.eYFPArea ./ OCC_HilusT.DapiArea;
occ_cd = OCC_HilusT.cFosArea ./ OCC_HilusT.DapiArea;
occ_od = OCC_HilusT.CfosXEYFPOverlapArea ./ OCC_HilusT.DapiArea;
occ_ch = occ_od ./ (occ_ed .* occ_cd);

%% Hilus Cell counts - correlations by group - raw eYFP, cFos, OL/eYFP
cd(plotDir)

reds = [1 0.6 0.1; 1 0 0];
grns = [0.6 1 0.1; 0.3 0.8 0.1];
ylws = [0.9 0.7 0.075; 0.9 0.9 0.2];

[tmprho,tmpp,fig_eyfp] = plotStainVBhvr_comp(OBC_HilusT.eYFPCounts,OCC_HilusT.eYFPCounts,accOBC,accOCC,grns,corrType);
xlabel('eYFP Count'); ylabel('Laser On Accuracy'); legend({'OBC','OBCC'},'location','se')
rhos.obc_eyfpVmaccon = tmprho(1); rhos.obcc_eyfpVmaccon = tmprho(2); ps.obc_eyfpVmaccon = tmpp(1); ps.obcc_eyfpVmaccon = tmpp(2);
[tmprho,tmpp,fig_cfos] = plotStainVBhvr_comp(OBC_HilusT.CfosCounts,OCC_HilusT.cFosCounts,accOBC,accOCC,reds,corrType);
xlabel('cFos Count'); ylabel('Laser On Accuracy'); legend({'OBC','OBCC'},'location','se')
rhos.obc_cfosVmaccon = tmprho(1); rhos.obcc_cfosVmaccon = tmprho(2); ps.obc_cfosVmaccon = tmpp(1); ps.obcc_cfosVmaccon = tmpp(2);
[tmprho,tmpp,fig_ovlp] = plotStainVBhvr_comp(OBC_HilusT.CfosXEYFPOverlapCounts./OBC_HilusT.eYFPCounts,OCC_HilusT.CfosXEYFPOverlapCounts./OCC_HilusT.eYFPCounts,accOBC,accOCC,ylws,corrType);
xlabel('Overlap / eYFP'); ylabel('Laser On Accuracy'); legend({'OBC','OBCC'},'location','se')
rhos.obc_ovlpVmaccon = tmprho(1); rhos.obcc_ovlpVmaccon = tmprho(2); ps.obc_ovlpVmaccon = tmpp(1); ps.obcc_ovlpVmaccon = tmpp(2);

[tmprho,tmpp,fig_eyfp_off] = plotStainVBhvr_comp(OBC_HilusT.eYFPCounts,OCC_HilusT.eYFPCounts,offOBC,offOCC,grns,corrType);
xlabel('eYFP Count'); ylabel('Laser Off Accuracy');
rhos.obc_eyfpVmaccoff = tmprho(1); rhos.obcc_eyfpVmaccoff = tmprho(2); ps.obc_eyfpVmaccoff = tmpp(1); ps.obcc_eyfpVmaccoff = tmpp(2);
[tmprho,tmpp,fig_cfos_off] = plotStainVBhvr_comp(OBC_HilusT.CfosCounts,OCC_HilusT.cFosCounts,offOBC,offOCC,reds,corrType);
xlabel('cFos Count'); ylabel('Laser Off Accuracy');
rhos.obc_cfosVmaccoff = tmprho(1); rhos.obcc_cfosVmaccoff = tmprho(2); ps.obc_cfosVmaccoff = tmpp(1); ps.obcc_cfosVmaccoff = tmpp(2);
[tmprho,tmpp,fig_ovlp_off] = plotStainVBhvr_comp(OBC_HilusT.CfosXEYFPOverlapCounts./OBC_HilusT.eYFPCounts,OCC_HilusT.CfosXEYFPOverlapCounts./OCC_HilusT.eYFPCounts,offOBC,offOCC,ylws,corrType);
xlabel('Overlap / eYFP'); ylabel('Laser Off Accuracy');
rhos.obc_ovlpVmaccoff = tmprho(1); rhos.obcc_ovlpVmaccoff = tmprho(2); ps.obc_ovlpVmaccoff = tmpp(1); ps.obcc_ovlpVmaccoff = tmpp(2);

if saveFlag
    saveFigTypes(fig_eyfp,[plotDir 'hilusCount_eYFP_on_OBCVSOBCC'])
    saveFigTypes(fig_cfos,[plotDir 'hilusCount_cFos_on_OBCVSOBCC'])
    saveFigTypes(fig_ovlp,[plotDir 'hilusCount_OL_on_OBCVSOBCC'])
    saveFigTypes(fig_eyfp_off,[plotDir 'hilusCount_eYFP_off_OBCVSOBCC'])
    saveFigTypes(fig_cfos_off,[plotDir 'hilusCount_cFos_off_OBCVSOBCC'])
    saveFigTypes(fig_ovlp_off,[plotDir 'hilusCount_OL_off_OBCVSOBCC'])
end

%% DG Hilus Behavior Correlations DNMP Acc DELTA by Raw Count 

[tmprho,tmpp,fig_eyfp_delta] = plotStainVBhvr_comp(OBC_HilusT.eYFPCounts,OCC_HilusT.eYFPCounts,accOBC-offOBC,accOCC-offOCC,grns,corrType);
xlabel('eYFP Count'); ylabel('\Delta DNMP Accuracy'); ylim([-.3 .3]); legend({'OBC','OBCC'},'location','ne')
rhos.obc_hilus_eyfpVmaccDelta = tmprho(1); rhos.obcc_hilus_eyfpVmaccDelta = tmprho(2); ps.obc_hilus_eyfpVmaccDelta = tmpp(1); ps.obcc_hilus_eyfpVmaccDelta = tmpp(2);
[tmprho,tmpp,fig_cfos_delta] = plotStainVBhvr_comp(OBC_HilusT.CfosCounts,OCC_HilusT.cFosCounts,accOBC-offOBC,accOCC-offOCC,reds,corrType);
xlabel('cFos Count'); ylabel('\Delta DNMP  Accuracy'); ylim([-.3 .3]); legend({'OBC','OBCC'},'location','ne')
rhos.obc_hilus_cfosVmaccDelta = tmprho(1); rhos.obcc_hilus_cfosVmaccDelta = tmprho(2); ps.obc_hilus_cfosVmaccDelta = tmpp(1); ps.obcc_hilus_cfosVmaccDelta = tmpp(2);
[tmprho,tmpp,fig_ovlp_delta] = plotStainVBhvr_comp(OBC_HilusT.CfosXEYFPOverlapCounts,OCC_HilusT.CfosXEYFPOverlapCounts,accOBC-offOBC,accOCC-offOCC,ylws,corrType);
xlabel('Overlap Count'); ylabel('\Delta DNMP  Accuracy'); ylim([-.3 .3]); legend({'OBC','OBCC'},'location','ne')
rhos.obc_hilus_ovlpVmaccDelta = tmprho(1); rhos.obcc_hilus_ovlpVmaccDelta = tmprho(2); ps.obc_hilus_ovlpVmaccDelta = tmpp(1); ps.obcc_hilus_ovlpVmaccDelta = tmpp(2);

if saveFlag
    saveFigTypes(fig_eyfp_delta,[plotDir 'hilusCount_eYFP_delta_OBCVSOBCC'])
    saveFigTypes(fig_cfos_delta,[plotDir 'hilusCount_cFos_delta_OBCVSOBCC'])
    saveFigTypes(fig_ovlp_delta,[plotDir 'hilusCount_OL_delta_OBCVSOBCC'])
end

%% Hilus Cell Counts - correlations by group - eYFP, cFos and OL/Chance

[tmprho,tmpp,fig_ed] = plotStainVBhvr_comp(obc_ed,occ_ed,accOBC,accOCC,grns,corrType);
xlabel('eYFP / Dapi Area'); ylabel('Laser On Accuracy');
rhos.obc_edVmaccon = tmprho(1); rhos.obcc_edVmaccon = tmprho(2); ps.obc_edVmaccon = tmpp(1); ps.obcc_edVmaccon = tmpp(2);
[tmprho,tmpp,fig_cd] = plotStainVBhvr_comp(obc_cd,occ_cd,accOBC,accOCC,reds,corrType);
xlabel('cFos / Dapi Area'); ylabel('Laser On Accuracy');
rhos.obc_cdVmaccon = tmprho(1); rhos.obcc_cdVmaccon = tmprho(2); ps.obc_cdVmaccon = tmpp(1); ps.obcc_cdVmaccon = tmpp(2);
[tmprho,tmpp,fig_ch] = plotStainVBhvr_comp(obc_ch,occ_ch,accOBC,accOCC,ylws,corrType);
xlabel('Overlap Area / Chance'); ylabel('Laser On Accuracy');
rhos.obc_chVmaccon = tmprho(1); rhos.obcc_chVmaccon = tmprho(2); ps.obc_chVmaccon = tmpp(1); ps.obcc_chVmaccon = tmpp(2);

[tmprho,tmpp,fig_ed_off] = plotStainVBhvr_comp(obc_ed,occ_ed,offOBC,offOCC,grns,corrType);
xlabel('eYFP / Dapi Area'); ylabel('Laser Off Accuracy');
rhos.obc_edVmaccoff = tmprho(1); rhos.obcc_edVmaccoff = tmprho(2); ps.obc_edVmaccoff = tmpp(1); ps.obcc_edVmaccoff = tmpp(2);
[tmprho,tmpp,fig_cd_off] = plotStainVBhvr_comp(obc_cd,occ_cd,offOBC,offOCC,reds,corrType);
xlabel('cFos / Dapi Area'); ylabel('Laser Off Accuracy');
rhos.obc_cdVmaccoff = tmprho(1); rhos.obcc_cdVmaccoff = tmprho(2); ps.obc_cdVmaccoff = tmpp(1); ps.obcc_cdVmaccoff = tmpp(2);
[tmprho,tmpp,fig_ch_off] = plotStainVBhvr_comp(obc_ch,occ_ch,offOBC,offOCC,ylws,corrType);
xlabel('Overlap Area / Chance'); ylabel('Laser Off Accuracy');
rhos.obc_chVmaccoff = tmprho(1); rhos.obcc_chVmaccoff = tmprho(2); ps.obc_chVmaccoff = tmpp(1); ps.obcc_chVmaccoff = tmpp(2);

if saveFlag
    saveFigTypes(fig_ed,[plotDir 'hilusCount_eYFPDapiArea_on_OBCVSOBCC'])
    saveFigTypes(fig_cd,[plotDir 'hilusCount_cFosDapiArea_on_OBCVSOBCC'])
    saveFigTypes(fig_ch,[plotDir 'hilusCount_OLChance_on_OBCVSOBCC'])
    saveFigTypes(fig_ed_off,[plotDir 'hilusCount_eYFPDapiArea_off_OBCVSOBCC'])
    saveFigTypes(fig_cd_off,[plotDir 'hilusCount_cFosDapiArea_off_OBCVSOBCC'])
    saveFigTypes(fig_ch_off,[plotDir 'hilusCount_OLChance_off_OBCVSOBCC'])
end

%% Hilus Behavior Correlations DNMP Acc DELTA by normalized area 

[tmprho,tmpp,fig_ed_delta] = plotStainVBhvr_comp(obc_ed,occ_ed,accOBC-offOBC,accOCC-offOCC,grns,corrType);
xlabel('eYFP / Dapi Area'); ylabel('\Delta DNMP Accuracy'); ylim([-.3 .3]); legend({'OBC','OBCC'},'location','ne')
rhos.obc_hilus_edVmaccDelta = tmprho(1); rhos.obcc_hilus_edVmaccDelta = tmprho(2); ps.obc_hilus_edVmaccDelta = tmpp(1); ps.obcc_hilus_edVmaccDelta = tmpp(2);
[tmprho,tmpp,fig_cd_delta] = plotStainVBhvr_comp(obc_cd,occ_cd,accOBC-offOBC,accOCC-offOCC,reds,corrType);
xlabel('cFos / Dapi Area'); ylabel('\Delta DNMP  Accuracy'); ylim([-.3 .3]); legend({'OBC','OBCC'},'location','ne')
rhos.obc_hilus_cdVmaccDelta = tmprho(1); rhos.obcc_hilus_cdVmaccDelta = tmprho(2); ps.obc_hilus_cdVmaccDelta = tmpp(1); ps.obcc_hilus_cdVmaccDelta = tmpp(2);
[tmprho,tmpp,fig_ch_delta] = plotStainVBhvr_comp(obc_ch,occ_ch,accOBC-offOBC,accOCC-offOCC,ylws,corrType);
xlabel('Overlap Area / Chance'); ylabel('\Delta DNMP  Accuracy'); ylim([-.3 .3]); legend({'OBC','OBCC'},'location','ne')
rhos.obc_hilus_chVmaccDelta = tmprho(1); rhos.obcc_hilus_chVmaccDelta = tmprho(2); ps.obc_hilus_chVmaccDelta = tmpp(1); ps.obcc_hilus_chVmaccDelta = tmpp(2);

if saveFlag
    saveFigTypes(fig_ed_delta,[plotDir 'hilusCount_eYFPDapiArea_delta_OBCVSOBCC'])
    saveFigTypes(fig_cd_delta,[plotDir 'hilusCount_cFosDapiArea_delta_OBCVSOBCC'])
    saveFigTypes(fig_ch_delta,[plotDir 'hilusCount_OLChance_delta_OBCVSOBCC'])
    save([plotDir 'OBC_hilusCount_stats'],'ps','rhos')
end

%% Plot average counts eYFP, cFos and Overlap

[~,ps.hilus_rawct_cfos,~,stats.hilus_rawct_cfos] = ttest2(OCC_HilusT.cFosCounts,OBC_HilusT.cFosCounts);
[~,ps.hilus_rawct_eyfp,~,stats.hilus_rawct_eyfp] = ttest2(OCC_HilusT.eYFPCounts,OBC_HilusT.eYFPCounts);
[~,ps.hilus_rawct_ovlp,~,stats.hilus_rawct_ovlp] = ttest2(OCC_HilusT.CfosXEYFPOverlapCounts,OBC_HilusT.CfosXEYFPOverlapCounts);

if saveFlag; fname_c_raw = strcat('OBC_Hilus_RawCt_cFos'); else; fname_c_raw = 0; end
fig_raw_cfos = plot_obc_rawcellct(OCC_HilusT.cFosCounts,OBC_HilusT.cFosCounts,cfosCols,fname_c_raw);
ylabel('cFos Count'); ylim([0 150]);
if saveFlag; fname_e_raw = strcat('OBC_Hilus_RawCt_eYFP'); else; fname_e_raw = 0; end
fig_raw_eyfp = plot_obc_rawcellct(OCC_HilusT.eYFPCounts,OBC_HilusT.eYFPCounts,eyfpCols,fname_e_raw);
ylabel('eYFP Count'); ylim([0 140]);
if saveFlag; fname_o_raw = strcat('OBC_Hilus_RawCt_Ovlp'); else; fname_o_raw = 0; end
fig_raw_ovlp = plot_obc_rawcellct(OCC_HilusT.CfosXEYFPOverlapCounts,OBC_HilusT.CfosXEYFPOverlapCounts,ovlpCols,fname_o_raw);
ylabel('Overlap Count'); ylim([0 70]);

%% Plot chance-normalized hilus overlap and compare vs 0
[~,ps.obc_hilus_chV0,~,stats.obc_hilus_chV0] = ttest(1-obc_ch);
[~,ps.occ_hilus_chV0,~,stats.occ_hilus_chV0] = ttest(1-occ_ch);
[~,ps.hilus_obcVocc,~,stats.hilus_obcVocc] = ttest2(obc_ch,occ_ch);

if saveFlag; fname_o_nrm = strcat('OBC_Hilus_NrmChance_Ovlp'); else; fname_o_nrm = 0; end
fig_ch_ovlp = plot_obc_rawcellct(occ_ch,obc_ch,flipud(ovlpCols),fname_o_nrm); 
ylim([0 2.5]);
ylabel('Overlap Area / Chance');

%% Functions

function [rhos, ps, fhandle] = plotStainVBhvr_comp(stain1,stain2,bhvr1,bhvr2,cMat,corrType)
[rhos(1),ps(1)] = corr(stain1,bhvr1,'Type',corrType);
[rhos(2),ps(2)] = corr(stain2,bhvr2,'Type',corrType);
mdl1 = fitlm(stain1,bhvr1);
xs1 = [min(stain1); max(stain1)];
ys1 = predict(mdl1,xs1);
mdl2 = fitlm(stain2,bhvr2);
xs2 = [min(stain2); max(stain2)];
ys2 = predict(mdl2,xs2);

fhandle = figure; hold on; axis square
plot(stain1,bhvr1,'o','MarkerFaceColor',cMat(1,:),'MarkerEdgeColor',cMat(1,:));
plot(stain2,bhvr2,'o','MarkerFaceColor',cMat(2,:),'MarkerEdgeColor',cMat(2,:));
plot(xs1,ys1,'--','Color',cMat(1,:),'LineWidth',2)
plot(xs2,ys2,'--','Color',cMat(2,:),'LineWidth',2)
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.25,0.45]);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);
ylim([0 1])
end







