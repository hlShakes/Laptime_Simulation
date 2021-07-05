Curvefitting
target = 9;


topspeed = 60;
lapsimulation;
result1 = [topspeed, kwh, mean(vel)];

topspeed = 20;
lapsimulation;
result2 = [topspeed, kwh, mean(vel)];

result3 = result2;

while (result3(2)> target) || (result3(2) < (target * 0.95))
    m = (result1(1) - result2(1)) / (result1(1) - result2(1));
    c = result1(1) - (m * result1(2));
    topspeed = (m * target) + c
    lapsimulation;
    result3 = [topspeed, kwh, mean(vel)];
    if kwh > target
        result1 = result3;
    else
        result2 = result3;
    end
end

hold on
kwh = cumpower / (3600000);
SoC = 1 - (kwh / target);
plot(disp,SoC)