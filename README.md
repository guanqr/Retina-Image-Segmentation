# Retina-Image-Segmentation

人眼视网膜由多层组织构成，利用给出的 OCT 视网膜断层图，运行该程序实现 Vitreous、NFL、GCL、INL、OPL、ONL、OS、RPE 共八层的图像分割。

![](https://raw.githubusercontent.com/guanqr/Retina-Image-Segmentation/master/docs/oct-1.jpg)

其中 `main.m` 程序为总程序，设置读取的图像所在地址，直接运行即可标注出每一层层所在位置。其余程序为独立绘制程序，程序名对应其绘制的曲线。

整体效果如下图所示。

![](https://raw.githubusercontent.com/guanqr/Retina-Image-Segmentation/master/docs/oct-2.png)

*注：本程序为浙江大学光电学院《机器视觉与图像处理》课程设计内容，代码仅供个人参考，请勿抄袭。*
