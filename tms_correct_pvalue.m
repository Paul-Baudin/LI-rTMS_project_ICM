addpath \\lexport\iss01.charpier\analyses\tms\scripts;
addpath \\lexport\iss01.charpier\analyses\tms\scripts\external\fdr_bh\;

table_path = '\\lexport\iss01.charpier\analyses\tms\stats\fig1_pvalues.xlsx';
data = readtable(table_path);

[h, crit_p, adj_ci_cvrg, data.pvalue_corr]=fdr_bh(data.pvalue);

writetable(data, table_path);





