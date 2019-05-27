# Back-Propagation-Neural-Network-Classification-Algorithm-of-ECG-Signal
## -------在 ECG 自动分类系统中，识别的准确率与系统处理数据的时间一直是学者们研究的重要内容。因此针对衡量 ECG 自动分类系统采用 BP 神经网络对心电信号进行分类识别。 <br>
针对心电信号预处理部分，根据不同频率的噪声，采用均值滤波器滤除高频
的工频干扰和肌电噪声，采用中值滤波器滤除低频的基线漂移。 <br>
针对心电信号特征提取部分，采用小波变换提取心电信号中单个 QRS 波的全
部特征点。并对提取的特征值进行归一化与ICA处理。 <br>
针对心电信号分类识别部分，根据 BP 神经网络，搭建出 BP 神经网络神经网络模型，将提取出来的
特征值送入神经网络中进行训练和分类。<br>
根据实验结果的验证，得出 BP 神经网
络针对四种心律失常的分类有更好的识别效果和更快的处理速度，适用于 ECG
自动分类系统。 


> do   // 初始化网络权值（通常是小的随机值）  
> forEach 训练样本 ex
>>    prediction = neural-net-output(network, ex)  // 正向传递 <br>
>>    actual = teacher-output(ex)  
>>    计算输出单元的误差 (prediction - actual)  
>>    计算  对于所有隐藏层到输出层的权值                           // 反向传递  
>>    计算  对于所有输入层到隐藏层的权值                           // 继续反向传递  
>>    更新网络权值 // 输入层不会被误差估计改变  \<br>
> until 所有样本正确分类或满足其他停止标准  
> return 该网络  
 ![image](https://github.com/1579477793/Back-Propagation-Neural-Network-Classification-Algorithm-of-ECG-Signal/blob/master/img/%E6%AD%A3%E5%B8%B8.jpg)
 ![image](https://github.com/1579477793/Back-Propagation-Neural-Network-Classification-Algorithm-of-ECG-Signal/blob/master/img/%E7%BB%93%E6%9E%9C_%E6%B7%B7%E6%B7%86%E7%9F%A9%E9%98%B5.jpg)
