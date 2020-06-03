clear;
I0 = imread('11.tif');

%GCL提取
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

%I3 = imfill(I3,'holes');
%提取底部轮廓
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

% I4 = edge(I3,'canny'); %边缘提取
%imshow(I3);
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

imshow(I0);
hold on
pG = polyfit(xG, yG, 6);
y1G = polyval(pG, xG);
xxG = linspace(1, n);
yyG = spline(xG, y1G, xxG);
plot(xxG, yyG, '-', 'LineWidth', 1, 'color', 'y');%线性拟合绘制
legend('GCL');