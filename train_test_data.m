     function [train_ica_set,train_label,test_ica_set,test_label] = train_test_data()
clear
% close all
dir_name = {'正常','左束支阻滞','右束支阻滞','室性早搏','房性早搏','起搏心跳'};
train_set_0 = [];
train_label = [];
test_set_0 = [];
test_label = []; 

for dir_index = 1:length(dir_name)
    dir_path = ['C:\Users\gcl\Desktop\[重要]ECG分类采用小波和ELM\ecg\data\', dir_name{dir_index}];
    files = dir(fullfile(dir_path, '*.mat'));
    num = length(files);
    file_vector = randperm(num);
    figure;
    for i = 1:num%%%%%处理一个文件夹下的每个文件
        out=[];
        file_name = [dir_path, '\',  files(file_vector(i)).name];
        load(file_name);%%%%读取文件    
        out_size=length(RR)-2;
        
        for j=2:out_size+1
            datax=(C{j}-mean(C{j}))/std(C{j});%%%标注化
            tt=wpdec(datax',3,'haar');   
            wp=wpcoef(tt,8); 
            out=[out;wp];%%%%1个心跳的数据
        end
        datay=C{ceil(out_size/2)};
        subplot(ceil(num/2),2,i);plot(datay);axis([1 261 -3 3]);title(dir_name{dir_index});

        index_vector = randperm(out_size);%%%%打乱顺序
        train_size = floor(out_size*.6);%%训练集的数目
        test_size = out_size - train_size;%%测试集的数目

        train_set_0 = [train_set_0;out(index_vector(1:train_size),:)];%%%训练集的心跳数据
        test_set_0 = [test_set_0;out(index_vector(train_size+1:out_size),:)];%%%测试集的心跳数据
       
        train_label = [train_label;dir_index*ones(train_size,1)];%%%训练集的label 
        test_label = [test_label;dir_index*ones(test_size,1)];%%%测试集的label 

    end
end

[X,A,~] = fastica([train_set_0;test_set_0]', 'numOfIC',40);%%%ICA独立成分分析
train_ica_set = X(:,1:length(train_label));%%%%%%%得到训练集数据
test_ica_set = X(:,length(train_label)+1:end);%%%%%%%得到测试集数据