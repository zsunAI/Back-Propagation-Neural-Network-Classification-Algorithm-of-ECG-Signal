clc;
clear;
close all
addpath wavelet;
addpath FastICA_25;
addpath code;
warning off
 
dir_name = {'正常','左束支阻滞','右束支阻滞','室性早搏','房性早搏','起搏心跳'};
train_set_0 = [];
train_label = [];
test_set_0 = [];
test_label = [];

for dir_index = 1:length(dir_name)
    dir_path = ['data\', dir_name{dir_index}]; % i=1正常
    files = dir(fullfile(dir_path, '*.mat')); 
    num = length(files);% 正常的文件夹下有num=5个,mat文件
    file_vector = randperm(num); % 1—5随机排序
    figure;
    for i = 1:num%%%%%处理一个文件夹下的每个文件
        out=[];
        file_name = [dir_path, '\',  files(file_vector(i)).name];
        load(file_name);%%%%读取文件  RR   
        out_size=length(RR)-2; 
        
        for j=2:out_size+1
            datax=(C{j}-mean(C{j}))/std(C{j});%%%标注化 标准差标准化，经过处理的数据符合标准正态分布(标准分数，平均数0标准差1，相对位置不变分布形状不变)
            tt=wpdec(datax',3,'haar'); % 一维haar小波包分析，第三层，数据长度是1/(2^n)，n=3
            wp=wpcoef(tt,8); % 某个节点的小波包系数重构，得到的是和原信号一样长度的信号。
            out=[out;wp];%%%%1个心跳的数据
        end
        datay=C{ceil(out_size/2)};
        subplot(ceil(num/2),2,i);plot(datay);axis([1 261 -3 3]);title(dir_name{dir_index});
%       每一行是一个周期，是一个完整数据
        index_vector = randperm(out_size);%%%%打乱顺序1-134的排列打乱
        train_size = floor(out_size*.6);%%训练集的数目80
        test_size = out_size - train_size;%%测试集的数目54

        train_set_0 = [train_set_0;out(index_vector(1:train_size),:)];%%%训练集的心跳数据
        test_set_0 = [test_set_0;out(index_vector(train_size+1:out_size),:)];%%%测试集的心跳数据
       
        train_label = [train_label;dir_index*ones(train_size,1)];%%%训练集的label “正常==1”
        test_label = [test_label;dir_index*ones(test_size,1)];%%%测试集的label “正常==1”

    end
end
% ICA X输出独立分量、混合矩阵A
[X,A,~] = fastica([train_set_0;test_set_0]', 'numOfIC',40);%%%ICA独立成分分析,第一个参数，矩阵合并并转置。ICA是指在只知道混合信号，而不知道源信号、噪声以及混合机制的情况下，分离或近似地分离出源信号的一种分析过程。
train_set = X(:,1:length(train_label));%%%%%%%得到训练集数据
test_set = X(:,length(train_label)+1:end);%%%%%%%得到测试集数据


Tn_train=BP(train_label); % 标签的处理，比如正常[100000],左束支阻滞[010000]

net=newff(minmax(train_set),[20,6],{'tansig' 'tansig'} ,'traingda'); % 每行的最大最小值minmax(train_set)，33行2列，第一层有20个神经元，第二层6个，第一层的传递函数是tan-sigmoid正切S型传递函数
net.trainParam.show=500;        %  show: 两次显示之间的训练次数
%训练网络
net.trainParam.lr=1;            % 学习速率下降值
net.trainParam.epochs=5000;      %训练次数取10000
net.trainParam.goal=0.05;        %误差门限取0.01
net=train(net,train_set,Tn_train); % 仿真 输出矩阵Q×N，其中Q为网络输出个数


%统计训练精度
YY=sim(net,train_set); % 6 行1420列，比如第一列第一行，表示是正常的概率,...
[maxi,ypred]=max(YY); % ypred存储的是训练之后的标签，maxi对应最大的准确率
maxi=maxi';
ypred=ypred';
CC=ypred-train_label; %标签的距离。
n=length(find(CC==0)); % 1290
TrainingAccuracy=n/size(train_set,2); % 0.9085
%统计测试精度
YY=sim(net,test_set);
[maxi,ypred]=max(YY);
maxi=maxi';
ypred=ypred';
CC=ypred-test_label;
n=length(find(CC==0));
TestingAccuracy=n/size(test_set,2); % 0.8917

end_time_train=cputime;
%  Time_using=end_time_train-start_time_train;

%将训练测试精度打印出来在command框里看
disp(sprintf('BP训练精度为%i',TrainingAccuracy));
disp(sprintf('BP测试精度为%i',TestingAccuracy));
 

T_test=test_label;



test_hunxiao=[];
for i=1:6
    for j=1:6
        test_hunxiao(i,j)=length(find(ypred(find(T_test==i))==j))/length(find(T_test==i)); % 混淆矩阵的计算，1行一个：原来是1预测是1的概率，1行2：原是1预测是2概率

    end
end
figure
imagesc(test_hunxiao);%画混淆矩阵
colormap(flipud(gray));  %# 转成灰度图，因此高value是渐黑色的，低value是渐白的

textStrings = num2str(test_hunxiao(:),'%0.2f');  
textStrings = strtrim(cellstr(textStrings)); 
[x,y] = meshgrid(1:6); 
hStrings = text(x(:),y(:),textStrings(:), 'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim')); 
textColors = repmat(test_hunxiao(:) > midValue,1,3); 
%改变test的颜色，在黑cell里显示白色
set(gca,'xtick',[1:1:6]);
set(gca,'ytick',[1:1:6]);
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors

set(gca,'xticklabel',{'正常','左束支阻滞','右束支阻滞','室性早搏','房性早搏','起搏心跳'},'XAxisLocation','top');
set(gca,'yticklabel',{'正常','左束支阻滞','右束支阻滞','室性早搏','房性早搏','起搏心跳'},'XAxisLocation','top');
title('识别率的混淆矩阵');


   