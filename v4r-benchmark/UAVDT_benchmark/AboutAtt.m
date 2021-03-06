% 生成各跟踪器各个属性的error和overlap表格，注意如下：
% - 需要和 .\util\plotDrawSave.m 配合实现，思路为生成各属性对应的.mat文件，然后进行读取。
% - 结果以excel形式进行保存
% by lfl

function AboutAtt()

paperTitle = 'ICRA19_LFL'; % 针对的会议或期刊名称和作者
evalType = 'OPE'; % 'SRE', 'OPE'

AttPerfDataPath = ['.\dataAnaly\', paperTitle, '\data_', evalType, '\'];
AboutAttPath = ['.\dataAnaly\', paperTitle, '\AboutAtt\'];
if ~exist(AboutAttPath, 'dir')
    mkdir(AboutAttPath);
end

typeOPE = {'Precision','Success'};

for typeNum = 1:length(typeOPE)   
	fprintf('Start making attributes table: %s.', typeOPE{typeNum});
    OJFiles = dir([AttPerfDataPath typeOPE{typeNum} '*OPE - *(*).mat']);
    len=length(OJFiles);
    temp = load([AttPerfDataPath num2str(OJFiles(1).name)]);
    OJ(1,:) = temp.rankingValues(1,:); % 第1行：跟踪器名称
    
    for ii = 1:len % 第2行-第13行：各属性的性能得分
        temp = load([AttPerfDataPath num2str(OJFiles(ii).name)]);
        row_count = ii+1;
        OJ(row_count,:) = temp.rankingValues(2,:);  %rankingValues，这里是因为plotDrawSave设置保存出来的变量
    end
    
    overall = load([AttPerfDataPath typeOPE{typeNum} ' plots of ' evalType ' - ' typeOPE{typeNum} ' plots.mat']);
    OJ(row_count+1,:) = overall.rankingValues(2,:); % 最后一行：总体性能得分
    
%     attName = {'Background clutter','Camera motion','Object motion','Small object','Illumination variations','Object blur','Scale variations','Long-term tracking','Large occlusion'};
    attFigName={'Trackers' 'BC' 'CM' 'IV' 'LO' 'LTT' 'OB' 'OM' 'SV' 'SO' 'Overall'}; % 行标
    OJ_1 = OJ'; % 原本 行标为trakers，纵标为各类threshold，所以加了转置
    OJ_1 = [attFigName;OJ_1(1:end,:)];
    
    saveDir = AboutAttPath;
    
    save([saveDir typeOPE{typeNum} '_att.mat'],'OJ_1');

    plot_table = importdata([saveDir typeOPE{typeNum} '_att.mat']);
    for ii = 2:size(plot_table,1)
        rowLabels{ii-1} = plot_table{ii, 1};
        for jj = 2:size(plot_table,2)
            aa = plot_table{ii,jj};
            matrix(ii-1,jj-1) = str2num(aa); % 注意matrix里的元素是char类型，要变化下
            columnLabels{jj-1} = plot_table{1, jj};
        end
    end
    
%     matrix = 100*matrix; % 转成百分号表示
    OJ_1(2:end, 2:end) = num2cell(matrix);
    xlswrite([saveDir typeOPE{typeNum} '_att.xlsx'], OJ_1);
	fprintf(' End!\n');
end
fprintf('All excel tables are in: %s\n', saveDir);
end