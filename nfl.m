clear;
I0 = imread('12.tif');

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

%I3 = edge(I2,'canny'); %边缘提取

%区域膨胀，连通边缘
% I3 = I2;
% B1 = [0 1 0
%       1 1 1
%       0 1 0];
% for i = 1:1
%     I3 = imdilate(I3, B1);
% end

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

%闭运算连通
% I3 = imclose(I3, ones(5)); 

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

imshow(I0);
hold on
pN = polyfit(xN, yN, 8);
y1N = polyval(pN, xN);
xxN = linspace(1, n);
yyN = spline(xN, y1N, xxN);
plot(xxN, yyN, '-', 'LineWidth', 1, 'color', 'g');%线性拟合绘制
legend('NFL');

% imshow(I3);