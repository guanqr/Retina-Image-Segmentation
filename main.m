clear;
I0 = imread('9.tif');

%Vitreous提取
[m,n] = size(I0);
I1 = medfilt2(I0,[5, 5]); %中值滤波
thresh = graythresh(I1);    %大津法全局阈值调整
I2 = imbinarize(I1, thresh); %二值化
I3 = edge(I2,'canny'); %边缘提取

%边界特征提取
for j = 1:n
    ymin(j) = m;
end

for i = 1:m
    for j = 1:n
        if(I3(i, j) == 1)
            if(i < ymin(j))
                ymin(j) = i;
            elseif(i < ymin(j) + 10 && j ~= 2)
                if(I3(i, j+1) == 1 && I3(i, j-1) == 1)
                    I3(i,j) = 0;
                end
            else
                I3(i,j)=0;
            end
        end
    end
end

k = 1;
for i = 1:m
    for j = 1:n
        if(I3(i,j) == 1)
            if(i == ymin(j))
                yV(k) = i;
                xV(k) = j;
                k = k + 1;
            end
        end
    end
end

imshow(I0);
hold on;

%绘制边界
pV = polyfit(xV, yV, 10);
y1V = polyval(pV, xV);
xxV = linspace(1, n, 300);
yyV = spline(xV, y1V, xxV);
V=plot(xxV, yyV, '-', 'LineWidth', 1, 'color', 'b');

%RPE提取
[m,n] = size(I0);
I1 = medfilt2(I0,[5, 5]); %中值滤波
I1 = imadjust(I1,[],[],1.5);
thresh = graythresh(I1);    %大津法全局阈值调整
I2 = imbinarize(I1, thresh+0.17); %二值化
I3 = edge(I2,'canny'); 

%边界特征提取
for j = 1:n
    ymin(j) = 1;
end

for i = m:-1:1
    for j = 1:n
        if(I3(i, j) == 1)
            if(i > ymin(j))
                ymin(j) = i;
            else
                I3(i,j)=0;
            end
        end
    end
end

B1 = [0 0 0
      1 1 1
      0 0 0];
for i = 1:6
    I3 = imdilate(I3, B1);
end
B2 = [0 1 0
      1 1 1
      0 1 0];
for i = 1:4
    I3 = imdilate(I3, B2);
end

imLabel = bwlabel(I3);                %对各连通域进行标记
stats = regionprops(imLabel, 'Area');    %求各连通域的大小
area = cat(1, stats.Area);
index = find(area == max(area));        %求最大连通域的索引
I3 = ismember(imLabel, index);          %获取最大连通域图像

for j = 1:n
    ymin(j) = 1;
end

for i = m:-1:1
    for j = 1:n
        if(I3(i, j) == 1)
            if(i > ymin(j))
                ymin(j) = i;
            else
                I3(i,j)=0;
            end
        end
    end
end

k = 1;
for i = 1:m
    for j = 1:n
        if(I3(i,j) == 1)
            if(i == ymin(j))
                yR(k) = i;
                xR(k) = j;
                k = k + 1;
            end
        end
    end
end

%绘制边界
pR = polyfit(xR, yR, 10);
y1R = polyval(pR, xR);
xxR = linspace(1, n, 300);
yyR = spline(xR, y1R, xxR);
R=plot(xxR, yyR-4, '-', 'LineWidth', 1, 'color', 'm');

%NFL提取
I1=histeq(I0); 
thresh = graythresh(I1);    %大津法全局阈值调整
I2 = imbinarize(I1, thresh+0.46); %二值化

[m,n]=size(I2);

for j = 1:n
    for i = 1:m
        if(I2(i, j) == 1)
            for k = i+20:m
                I2(k, j) = 0;
            end
        end
    end
end

%确定第一个点
for i = 1:m
    if(I2(i, j) == 1)
        k = i;
    end
end

%去除下方多余的点
for j = 1:n
    for i = k+140:m
        I2(i, j) = 0;
    end
end

%闭运算连通
I3 = imclose(I2, ones(3)); 

%提取底部轮廓
for j = 1:n
    for i = 1:m
        if (I3(i, j) == 1 && I3(i+1, j) == 1)
            I3(i, j) = 0;
        elseif (I3(i, j) == 1 && I3(i+1, j) == 0) %去除底部多余杂点
            for k = i+1:m
                I3(k, j) = 0;
            end
        end
    end
end

I4 = I3;

%绘图
for j = 1:n
    ymax(j) = 1;
end
for i = 1:m
    for j = 1:n
        if(I4(i,j) == 1)
            if(i > ymax(j))
                ymax(j) = i;
            end
        end
    end
end

k = 1;
for i = 1:m
    for j = 1:n
        if(I4(i,j) == 1)
            if(i == ymax(j))
                yN(k) = i;
                xN(k) = j;
                k = k+1;
            end
        end
    end
end

pN = polyfit(xN, yN, 8);
y1N = polyval(pN, xN);
xxN = linspace(1, n);
yyN = spline(xN, y1N, xxN);
N = plot(xxN, yyN, '-', 'LineWidth', 1, 'color', 'g');%线性拟合绘制

legend([V,N,R],'Vitreous','NFL','RPE');