clear;
I0 = imread('12.tif');

%OS提取
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

imshow(I0);
hold on;

%绘制边界
pOS = polyfit(xOS, yOS, 10);
y1OS = polyval(pOS, xOS);
xxOS = linspace(1, n, 300);
yyOS = spline(xOS, y1OS, xxOS);
plot(xxOS, yyOS, '--', 'LineWidth', 1, 'color', 'y');
legend('OS');