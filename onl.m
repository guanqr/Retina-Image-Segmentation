clear;
I0 = imread('12.tif');

%ONL提取
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



imshow(I3)
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
                yOP(k) = i;
                xOP(k) = j;
                k = k + 1;
            end
        end
    end
end

imshow(I0);
hold on;

%绘制边界
pOP = polyfit(xOP, yOP, 8);
y1OP= polyval(pOP, xOP);
xxOP = linspace(1, n, 300);
yyOP = spline(xOP, y1OP, xxOP);
plot(xxOP, yyOP, '--', 'LineWidth', 1, 'color', 'b');
legend('ONL');