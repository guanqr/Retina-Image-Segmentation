clear;
I0 = imread('2.tif');

%Vitreous提取
[m,n] = size(I0);
I1 = medfilt2(I0,[5, 5]); %中值滤波
I2 = graythresh(I1);    %大津法全局阈值调整
I3 = imbinarize(I1, I2); %二值化
I4 = edge(I3,'canny'); %边缘提取

%边界特征提取
for j = 1:n
    ymin(j) = m;
end

for i = 1:m
    for j = 1:n
        if(I4(i, j) == 1)
            if(i < ymin(j))
                ymin(j) = i;
            elseif(i < ymin(j) + 10 && j ~= 2)
                if(I4(i, j+1) == 1 && I4(i, j-1) == 1)
                    I4(i,j) = 0;
                end
            else
                I4(i,j)=0;
            end
        end
    end
end

k = 1;
for i = 1:m
    for j = 1:n
        if(I4(i,j) == 1)
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
I2 = graythresh(I1);    %大津法全局阈值调整
I3 = imbinarize(I1, I2+0.17); %二值化
I4 = edge(I3,'canny'); 
%I5 = I4;

%边界特征提取
for j = 1:n
    ymin(j) = 1;
end

for i = m:-1:1
    for j = 1:n
        if(I4(i, j) == 1)
            if(i > ymin(j))
                ymin(j) = i;
            else
                I4(i,j)=0;
            end
        end
    end
end

B1 = [0 0 0
      1 1 1
      0 0 0];
for i = 1:6
    I4 = imdilate(I4, B1);
end
B2 = [0 1 0
      1 1 1
      0 1 0];
for i = 1:4
    I4 = imdilate(I4, B2);
end

imLabel = bwlabel(I4);                %对各连通域进行标记
stats = regionprops(imLabel,'Area');    %求各连通域的大小
area = cat(1,stats.Area);
index = find(area == max(area));        %求最大连通域的索引
I4 = ismember(imLabel,index);          %获取最大连通域图像

for j = 1:n
    ymin(j) = 1;
end

for i = m:-1:1
    for j = 1:n
        if(I4(i, j) == 1)
            if(i > ymin(j))
                ymin(j) = i;
            else
                I4(i,j)=0;
            end
        end
    end
end

k = 1;
for i = 1:m
    for j = 1:n
        if(I4(i,j) == 1)
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
legend([V,R],'Vitreous','RPE');