# Retina-Image-Segmentation

人眼视网膜由多层组织构成，利用给出的 OCT 视网膜断层图，运行该程序实现 Vitreous、NFL、RPE 三层的图像分割。

![](https://raw.githubusercontent.com/guanqr/Retina-Image-Segmentation/master/docs/oct-1.jpg)

其中 `main.m` 程序为总程序，设置读取的图像所在地址，直接运行即可标注出 Vitreous、NFL、RPE 三层所在位置。其余三个程序为独立绘制程序，程序名对应其绘制的曲线。

整体效果如下图所示。

![](https://raw.githubusercontent.com/guanqr/Retina-Image-Segmentation/master/docs/oct-2.png)
