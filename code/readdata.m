function [X sfreq]=readdata(groupnum)   %读取心电数据 
%PATH= 'C:\Users\Administrator\Desktop\ecg\myfun\';      %指定数据的储存路径
% PATH='C:\Users\gcl\Desktop\[重要]ECG分类采用小波和ELM\ecg';
datanum=num2str(groupnum);
suffixhead='.hea'; 
suffixdate='.dat';
HEADERFILE=[datanum suffixhead];                  %.hea 格式，头文件，可用记事本打开
DATAFILE=[datanum suffixdate];                     %.dat 格式，ECG 数据
SAMPLES2READ=40000;                      %指定需要读入的样本数,若.dat文件中存储有两个通道的信号:则读入 2*SAMPLES2READ 个数据 


%读取头文件中的信息
signalh=fullfile(PATH, HEADERFILE);                   % 通过函数 fullfile 获得头文件的完整路径
fid1=fopen(signalh,'r');                              % 打开头文件，其标识符为 fid1 ，属性为'r'--“只读”
z=fgetl(fid1);                                        % 读取头文件的第一行数据，字符串格式
A=sscanf(z, '%*s %d %d %d',[1,3]);                    % 按照格式 '%*s %d %d %d' 转换数据并存入矩阵 A 中
nosig=A(1);                                          % 信号通道数目
sfreq=A(2);                                           % 数据采样频率
clear A;                                              % 清空矩阵 A ，准备获取下一行数据
for k=1:nosig                                         % 读取每个通道信号的数据信息
    z= fgetl(fid1);
    A= sscanf(z, '%*s %d %d %d %d %d',[1,5]);
    dformat(k)= A(1);           % 信号格式; 这里只允许为 212 格式
    gain(k)= A(2);              % 每 mV 包含的整数个数
    bitres(k)= A(3);            % 采样精度（位分辨率）
    zerovalue(k)= A(4);         % ECG 信号零点相应的整数值
    firstvalue(k)= A(5);        % 信号的第一个整数值 (用于偏差测试)
end;
fclose(fid1);
clear A;


%读取data数据
if dformat~= [212,212], error('this script does not apply binary formats different to 212.'); end;
signald= fullfile(PATH, DATAFILE);           % 读入 212 格式的 ECG 信号数据
fid2=fopen(signald,'r');
A= fread(fid2, [3,SAMPLES2READ], 'uint8');  % matrix with 3 rows, each 8 bits long, = 2*12bit 矩阵A共有SAMPLES2READ行、3列，每列数据都是以uint8格式读入，注意这时数据通过uint8的读入方式已经成为十进制数了
fclose(fid2);
M2H= bitshift(A(2,:), -4);        % 字节向右移四位，即取字节的高四位，属于信号2的高4位
M1H= bitand(A(2,:), 15);          %取字节的低四位
PRL=bitshift(bitand(A(2,:),8),9);     % sign-bit   取出字节低四位中最高位，向右移九位  移位？
PRR=bitshift(bitand(A(2,:),128),5);   % sign-bit   取出字节高四位中最高位，向右移五位
M( 1 , :)= bitshift(M1H,8)+ A( 1 , : )-PRL;% 将M1H、M2H分别左移8位，即乘以2^8，再分别加上A(:,1)，A(:,2)，
M( 2 , :)= bitshift(M2H,8)+ A( 2 , : )-PRR;% 由于左移时把符号位也移动了，要减去符号位的值
M( 1 , :)= (M( 1 , :)- zerovalue(1))/gain(1);
M( 2 , :)= (M( 2 , :)- zerovalue(2))/gain(2);
clear A M1H M2H PRR PRL;
X=M(1,:);
end


