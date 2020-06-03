clear;
I0 = imread('9.tif');

%OPL提取
[m,n] = size(I0);
I1 = medfilt2(I0,[5, 5]); %中值滤波
thresh = graythresh(I1);    %大津法全局阈值调整
I2 = imbinarize(I1, thresh-0.06); %二值化
%I2 = medfilt2(I2,[6, 6]); %中值滤波
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
% 
imshow(I0);
hold on
pOP = polyfit(xOP, yOP, 6);
y1OP = polyval(pOP, xOP);
xxOP = linspace(1, n);
yyOP = spline(xOP, y1OP, xxOP);
plot(xxOP, yyOP, '-', 'LineWidth', 1, 'color', 'c');%线性拟合绘制
legend('OPL');