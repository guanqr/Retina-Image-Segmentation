clear;
I0 = imread('1.tif');

%*****************************************%
%               Vitreous提取
%*****************************************%

[m,n] = size(I0);
I1 = medfilt2(I0,[5, 5]); %中值滤波
thresh = graythresh(I1); %大津法全局阈值调整
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
V = plot(xxV, yyV, '-', 'LineWidth', 1, 'color', 'b');

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

%*****************************************%
%                 GCL提取
%*****************************************%

[m,n] = size(I0);
I1 = medfilt2(I0,[5, 5]); %中值滤波
thresh = graythresh(I1);    %大津法全局阈值调整
I2 = imbinarize(I1, thresh+0.08); %二值化

I3 = imclose(I2, ones(5));

for j = 1:n
    for i = 1:m
        if I3(i, j) == 1
            for k = i+100:m
                I3(k, j) = 0;
            end
        end
    end
end

%判断是否下凹
for i = 1:m
    if I3(i, 50) == 1
        imin = i;
        break;
    end
end

for i = 1:m
    if I3(i, 150) == 1
        imax = i;
        break;
    end
end

if imax - imin > 60
    %去除凹形多余白色区域
    for j = 1:n
        for k = imin+120:m
            I3(k, j) = 0;
        end
    end
    I3 = medfilt2(I3,[2, 2]); %中值滤波
    %左1
    for i = m:-1:1
        if I3(i, 80) == 1
            del = i;
            break;
        end
    end
    for j = 1:80
        for k = del-30:del
            I3(k, j) = 0;
        end
    end
    %左2
    for i = m:-1:1
        if I3(i, 120) == 1
            del = i;
            break;
        end
    end
    for j = 80:140
        for k = del-15:del+20
            I3(k, j) = 0;
        end
    end
    %右1
    for i = m:-1:1
        if I3(i, 160) == 1
            del = i;
            break;
        end
    end
    for j = 180:220
        for k = del-8:del+20
            I3(k, j) = 0;
        end
    end
    %右2
    for i = m:-1:1
        if I3(i, 240) == 1
            del = i;
            break;
        end
    end
    for j = 220:260
        for k = del-20:del+20
            I3(k, j) = 0;
        end
    end
    %右3
    for j = 260:300
        for k = del-30:del+20
            I3(k, j) = 0;
        end
    end
else
    imLabel = bwlabel(I3); %对各连通域进行标记
    stats = regionprops(imLabel,'Area'); %求各连通域的大小
    area = cat(1,stats.Area);
    index = find(area == max(area)); %求最大连通域的索引
    I3 = ismember(imLabel,index); %获取最大连通域图像 
    %针对第10幅图需要单独删除多余区域
    for j = 1:n
        for i = 1:m
            if I3(i, j) == 1
                for k = i+70:m
                    I3(k, j) = 0;
                end
            end
        end
    end
end

%提取下边界特征
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
                yG(k) = i;
                xG(k) = j;
                k = k+1;
            end
        end
    end
end

pG = polyfit(xG, yG, 8);
y1G = polyval(pG, xG);
xxG = linspace(1, n);
yyG = spline(xG, y1G, xxG);
G = plot(xxG, yyG, '-', 'LineWidth', 1, 'color', 'y');%线性拟合绘制

%*****************************************%
%                 OPL提取
%*****************************************%

[m,n] = size(I0);
I1 = medfilt2(I0,[5, 5]); %中值滤波
thresh = graythresh(I1);    %大津法全局阈值调整
I2 = imbinarize(I1, thresh-0.06); %二值化
I2 = imopen(I2, ones(6));
I2 = imclose(I2, ones(6));
I2 = imopen(I2, ones(15));
I2 = medfilt2(I2,[6, 6]); %中值滤波
for j = 1:n
    for i = 1:m
        if(I2(i, j) == 1)
            for k = i+110:m
                I2(k, j) = 0;
            end
        end
    end
end

%判断是否下凹
for i = 1:m
    if I2(i, 50) == 1
        imin = i;
        break;
    end
end

for i = 1:m
    if I2(i, 150) == 1
        imax = i;
        break;
    end
end

if imax - imin > 60
    %去除凹形多余白色区域
    for i = m:-1:1
        if I2(i, 160) == 1
            ymax = i;
            break;
        end
    end
    for j = 1:n
        for k = ymax-100:ymax+20
            I2(k, j) = 0;
        end
    end
end

B1 = [1 1 1
      1 1 1
      0 0 0];
for i = 1:8
    I2 = imdilate(I2, B1);
end

I3 = edge(I2,'canny'); 
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
                yOP(k) = i;
                xOP(k) = j;
                k = k+1;
            end
        end
    end
end

pOP = polyfit(xOP, yOP, 6);
y1OP = polyval(pOP, xOP);
xxOP = linspace(1, n);
yyOP = spline(xOP, y1OP, xxOP);
OP = plot(xxOP, yyOP, '-', 'LineWidth', 1, 'color', 'c');%线性拟合绘制

%*****************************************%
%                 ONL提取
%*****************************************%

[m,n] = size(I0);
I1 = medfilt2(I0,[5, 5]); %中值滤波
thresh = graythresh(I1);    %大津法全局阈值调整
I2 = imbinarize(I1, thresh+0.15); %二值化

B1 = [0 0 0
      1 1 1
      0 0 0];
for i = 1:6
    I2 = imdilate(I2, B1);
end
I2 = imopen(I2, ones(5));

for j = 1:n
    for i = m:-1:1
        if(I2(i, j) == 1)
            for k = i-75:-1:1
                I2(k, j) = 0;
            end
        end
    end
end

%确定第一个点
for i = m:-1:1
    if(I2(i, j) == 1)
        k = i;
    end
end

%去除下方多余的点
for j = 1:n
    for i = k-90:-1:1
        I2(i, j) = 0;
    end
end

I2 = imclose(I2, ones(3)); 
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
                yON(k) = i;
                xON(k) = j;
                k = k + 1;
            end
        end
    end
end

%绘制边界
pON = polyfit(xON, yON, 8);
y1ON = polyval(pON, xON);
xxON = linspace(1, n, 300);
yyON = spline(xON, y1ON, xxON);
ON=plot(xxON, yyON, '--', 'LineWidth', 1, 'color', 'b');

%*****************************************%
%                 OS提取
%*****************************************%

[m,n] = size(I0);
I1=histeq(I0); 
thresh = graythresh(I1); %大津法全局阈值调整
I2 = imbinarize(I1, thresh+0.47); %二值化
I2 = medfilt2(I2,[6,6]); %中值滤波

for j = 1:n
    for i = m:-1:1
        if(I2(i, j) == 1)
            for k = i-10:-1:1
                I2(k, j) = 0;
            end
        end
    end
end

%确定第一个点
for i = 1:m
    for j = 1:n
     if(I2(i,j)==1 && i>k)
         k=i;
     end
    end
end

%去除上方多余的点
for j = 1:n
    for i = k-70:-1:1
        I2(i, j) = 0;
    end
end

I3 = edge(I2,'canny'); 

B1 = [0 1 0
      1 1 1
      0 1 0];
for i = 1:1
    I3 = imdilate(I3, B1);
end

%边界特征提取
for j = 1:n
    ymin(j) = m;
end

for i = 1:m
    for j = 1:n
        if(I3(i, j) == 1)
            if(i < ymin(j))
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
                yOS(k) = i;
                xOS(k) = j;
                k = k + 1;
            end
        end
    end
end

%绘制边界
pOS = polyfit(xOS, yOS, 10);
y1OS = polyval(pOS, xOS);
xxOS = linspace(1, n, 300);
yyOS = spline(xOS, y1OS, xxOS);
OS = plot(xxOS, yyOS, '--', 'LineWidth', 1, 'color', 'y');

%*****************************************%
%                 RPE提取
%*****************************************%

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
yyR = spline(xR, y1R, xxR)-4;
R = plot(xxR, yyR, '--', 'LineWidth', 1, 'color', 'm');

legend([V, N, G, OP, ON, OS, R], 'Vitreous', 'NFL', 'GCL', 'OPL', 'ONL', 'OS', 'RPE');