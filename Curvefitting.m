clear all
% Read the GPS Data
M = csvread('GPSTT.csv');

x = M(:, 1);
y = M(:, 2);
z = M(:, 3);

% Center the track
for i = 1:size(x)
    x(i) = (x(i) + 3000);
    y(i) = (y(i) - 8000);
end

%Reduce the mesh count of the track
sumx = 0;
sumy = 0;
sumz = 0;
n = 0;
mesh = 2;

for i = 1:size(x)
    sumx = sumx + x(i);
    sumy = sumy + y(i);
    sumz = sumz + z(i);
    n = n + 1;
    if n == mesh
        xtemp(i/mesh) = (sumx /mesh);
        ytemp(i/mesh) = (sumy /mesh);
        ztemp(i/mesh) = (sumz /mesh);
        sumx = 0;
        sumy = 0;
        sumz = 0;
        n = 0;
    end  
end

xtemp(end + 1) = (sumx /n);
ytemp(end + 1) = (sumy /n);
ztemp(end + 1) = (sumz /n);

%smooth the result 
x = smooth(xtemp);
y = smooth(ytemp);
z = smooth(ztemp);

cumlength = zeros(1, 1);

for i = 1:(size(x) - 1)
   
    xdif = x(i + 1) - x(i);
    ydif = y(i + 1) - y(i);
    zdif = z(i + 1) - z(i);
    
    %Determine the angle between points
    if ydif == 0 || xdif ==0
        theta(i) = 0;
    else
        theta(i) = abs(atan(ydif/xdif));
    end
    %Determine the distance between points
    length(i) = sqrt(xdif^2 + ydif^2 + zdif^2);
    
    %Keep track of the cumlative length
    if i == 1
        cumlength(i) = length(i);
    else
        cumlength(i) = cumlength(i - 1) + length(i);
    end
    
    %Determine the height gain per m
    if zdif == 0
        height(i) = 0;
    else
        height(i) = zdif/length(i);
    end
end

%Determine the delta of theta
for i = 1:(size(x) - 2)
   
    thetadelta(i) = (abs(theta(i + 1) - theta(i)));
    radius(i) = length(i) / thetadelta(i);
    
end

radiusmax = max(radius);
radiusmin = min(radius);
radiusav = mean(radius);

for i = 2:(size(x) - 1)
    green(i - 1) = log(radius(i - 1));
end

greenmax = max(green);
greenmin = min(green);
greenav = mean(green);

%  hold on
%  
%      plot3(x, y, z, 'Color', [0, 1 ,0])
% 
% 
% % hold on
% % for i = 2:(size(x) - 1)
% %     green(i - 1) = green(i - 1) / (greenmax -  greenmin);
% %     if (green(i - 1) > 1) green(i - 1) = 1; end;
% %     red = 1 - green(i - 1);
% %     plot(x(i), y(i), '.', 'markers', 20, 'Color', [red, green(i - 1) ,0])
% % end
% % 
% % % for i = 1:size(x)
% % %     plot(x(i), y(i), 'bo', 'markers', 1, 'Color', [1, 0 ,0])
% % % end
% 
% axis([-10000 10000 -10000 10000, -1000 1000]);


