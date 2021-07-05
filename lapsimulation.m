clearvars -except keepVariables x y z thetadelta cumlength length radius height topspeed target result1 result2 result3 kwhlog vellog

%topspeed = 59.5614;
mass = 300;
tyreforce = mass * 9.81 * 1.3;
ratio = 40/30;

simulate = 1;

i = 1;
j = 1;
timestep = 0.1;

acc(i) = 0;
vel(i) = 0;
disp(i) = 0;
time(i) = 0;
cumpower(i) = 0;

while(simulate == 1)
   
    i = i + 1;
    
    centf(i) = (mass * vel(i - 1)^2) / radius(j);
    
    if centf(i) > tyreforce
        k = -1;
        while(centf(i) > tyreforce)
            k = k + 1;
            for l = (i - k - 1):i - 1
                m = j;
                while disp(l) < cumlength(m)
                    m = m - 1;
                end
                centf(l) = (mass * vel(l - 1)^2) / radius(m);
                motor(l) = 0;
                drag(l) = 0.5 * 1.225 * 0.438 * vel(l - 1) ^ 2;
                gravpot(l) = 9.81 * mass * (vel(l - 1) * timestep) * height(m);
                brake(l) = tyreforce - centf(l) - drag(l) - gravpot(l);
                
                if brake(l) < 0
                    wantedforce = abs(brake(l));
                    brake(l) = 0;
                    wantedtorque = 0.311 * wantedforce * (1/ratio) * 1.02 * 1.05;
                    motorrpm(l) = ratio * (vel(l - 1) / (2 * pi * 0.311)) * 60;

                    if motorrpm < 2000
                        if wantedtorque > 350
                            motortorque(l) = 350;
                            motorforce(l) = (((ratio) * motortorque(l) * 0.98 * 0.95) / 0.311);
                        else
                            motortorque(l) = wantedtorque;
                            motorforce(l) = wantedforce;
                        end
                    elseif motorrpm > 4000
                        motortorque(l) = 0;
                        motorforce(l) = 0;
                    else
                        avalibletorque = (-0.05 * motorrpm(l)) + 450;
                        if wantedtorque > avalibletorque
                            motortorque(l) = avalibletorque;
                            motorforce(l) = ((ratio * motortorque(l) * 0.98 * 0.95) / 0.311);
                        else
                            motortorque(l) = wantedtorque;
                            motorforce(l) = wantedforce;
                        end
                    end
                end
                
                motorpower(l) = motortorque(l) * (motorrpm(l) * (2 * pi / 60));
                cumpower(l) = cumpower(l - 1) + (motorpower(l) * timestep);
                force(l) = motor(l) - brake(l) - drag(l) - gravpot(l);
                
                acc(l) = force(l)/ mass;
                vel(l) = vel(l - 1) + (acc(l) * timestep);
                disp(l) = disp(l - 1) + (vel(l) * timestep);
            end
            centf(i) = (mass * vel(i - 1)^2) / radius(j);
        end
    end
      
    drag(i) = 0.5 * 1.225 * 0.4 * vel(i - 1) ^ 2;
    gravpot(i) = 9.81 * mass * (vel(i - 1) * timestep) * height(j);
    
%   Calcualte motorforce
    if vel(i - 1) > topspeed
        wantedforce = drag(i) + gravpot(i);
    else
        wantedforce = tyreforce - centf(i) + drag(i) + gravpot(i);
    end
    wantedtorque = 0.311 * wantedforce * (1/ratio) * 1.02 * 1.05;
    motorrpm(i) = ratio * (vel(i - 1) / (2 * pi * 0.311)) * 60;
    
    if motorrpm < 2000
        if wantedtorque > 350
            motortorque(i) = 350;
            motorforce(i) = ((ratio * motortorque(i) * 0.98 * 0.95) / 0.311);
        else
            motortorque(i) = wantedtorque;
            motorforce(i) = wantedforce;
        end
    elseif motorrpm > 4000
        motortorque(i) = 0;
        motorforce(i) = 0;
    else
        avalibletorque = (-0.05 * motorrpm(i)) + 450;
        if wantedtorque > avalibletorque
            motortorque(i) = avalibletorque;
            motorforce(i) = ((ratio * motortorque(i) * 0.98 * 0.95) / 0.311);
        else
            motortorque(i) = wantedtorque;
            motorforce(i) = wantedforce;
        end
    end
    brake(i) = 0;
    
    motorpower(i) = motortorque(i) * (motorrpm(i) * (2 * pi / 60));
    batterypower(i) = motorpower(i) * 1.02 * 1.05;
    if batterypower(i) < 0
        batterypower(i) = 0;
    end
    cumpower(i) = cumpower(i - 1) + ( batterypower(i) * timestep);
    
    force(i) = motorforce(i) - brake(i) - drag(i) - gravpot(i);

    acc(i) = force(i)/ mass;
    vel(i) = vel(i - 1) + (acc(i) * timestep);
    disp(i) = disp(i - 1) + (vel(i) * timestep);
    time(i) = time(i - 1) + timestep;
    
    
    if disp(i) > cumlength(j)
        j = j + 1;
        if j > size(cumlength) - 1
            simulate = 0;
        end
    end
    
end

mean(vel);
kwh = cumpower(i) / (3600000);

cumaccforce(1) = 0;
cumdrag(1) = 0;

for i = 2:size(disp, 2)
   if (acc(i) * mass) > 0
        cumaccforce(i) =  cumaccforce(i - 1) + (acc(i) * mass);
   else
       cumaccforce(i) = cumaccforce(i - 1);
   end
   cumdrag(i) = cumdrag(i -1) + drag(i);
end

% hold on
% axis([-10000 10000 -10000 10000 -1000 1000]);
% j = 1;
% for i = 1:size(x) - 1
%     avgcntr = 0;
%     avgvel = 0;
%     while(disp(j) <= cumlength(i))
%         avgcntr = avgcntr + 1;
%         avgvel = avgvel + (vel(j));
%         j = j + 1;
%     end
%     if avgcntr ~= 0
%         avgvel = avgvel / avgcntr;
%         green = avgvel / (max(vel) -  min(vel));
%         red = 1 - green;
%         plot(x(i), y(i), '.', 'markers', 20, 'Color', [red, green, 0])
%     end
% end