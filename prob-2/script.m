%% 2025-26-ex-parcial-q1
%% Problem 2

clearvars
close all
format short e
format compact

%--------------------------------------------------------------------------
% Data
%--------------------------------------------------------------------------
h = 60; %min in an hour
row = 54;
timeInterp1DHour = 3.0; %3h
timeInterp1DMin = 40.0; %40min
timeInterp1D = timeInterp1DHour * h + timeInterp1DMin; %Time to compute the average
rowToAv = 180;                                         %Row that holds the data to interpolate temperature


tempT = 24.0;                                        %Threshold temperature for part (b)

pointP = [2.5, 41.7];                                %Point to interpolate the temperature in part (c)
timeInterp2D = 1 * h;  %1 A.M.                             

timeAvSouthBCN = 5;
deg = char(176);
%--------------------------------------------------------------------------

%eval ('estacions')
%save estacions.mat dat elem
load estacions.mat -mat dat elem

[numStations,numFiles] = size(dat);
numElem = size(elem,1);

%
% (a) (2 points) Consider the station (node) given by the row number 54 of
%     the dat matrix. Assuming that we take quadratic elements on Omega_1 =
%     = [1,2], Omega_2 = [2,3], Omrga_3 = [3,4],... Which is the interpola-
%     ted value of the temperature (in °C) at 3h40min?
%
time= 0:30:360; time = 60 + time;
temp = dat(row,3:end);
numTimeData = size(temp,2);
elemTimeData = [1:2:numTimeData-2; 2:2:numTimeData-1; 3:2:numTimeData]';
elemTimeToInterpolate = 1 + floor( (timeInterp1D - time(1)) / h); 
nodesTimeToInterpolate = elemTimeData(elemTimeToInterpolate,:);
coefs = polyfit(time(nodesTimeToInterpolate),temp(nodesTimeToInterpolate),2);
%fprintf("(a) For the row %d, interpolated value of the temperature at %dh%dmin: %.5e\n",...
%   row, timeInterp1DHour, timeInterp1DMin, polyval(coefs,timeInterp1D))

%
% (b)(2 points) How many stations had a minimum temperature strictly larger
%    than 24°C?
% 
numStationsOverTempT = 0; 
for e = 1:numStations
    temp = dat(e,3:end);
    minTemp = min(temp);
    if minTemp > tempT
        numStationsOverTempT = numStationsOverTempT + 1;
    end
end
%fprintf("(b) Number of stations with temperature larger than %.1f%cC: %d\n",...
%  tempT, deg, numStationsOverTempT)

%
% (c) (3 points) Which is the interpolated temperature at 1h AM at the
%     point with coordinates (2.5,41.7)?
% 
nodTemp = 3 + floor((timeInterp2D- time(1)) / h);
for e = 1:numElem
    nodes = elem(e,:);
    vertices = dat(nodes,1:2);
    [alphas, isInside]=baryCoord(vertices, pointP);
    if isInside > 0
        temp = dat(nodes,nodTemp);
        intepolatedTemp = alphas * temp;
        break
    end
end
%fprintf("(c) Interpolated temperature at point (%.1f, %.1f): %.5e%cC\n",...
%    pointP', intepolatedTemp, deg)

%
% (d) Consider the stations at the Mediterranean coast below Barcelona, 
%     which lie at the boundary between Station 69 in the Southwest and
%     station 167 in the Northeast, both included (see Figure). Which is
%     the average (mean) temperature at 5h AM?
%

% Nodes on the boundary
indNodesBd = boundaryNodes(dat(:,1:2), elem);

% Box coordinates
x1 = dat(69,1);
x2 = dat(167,1);
y1 = dat(69,2);
y2 = dat(167,2);

nodTemp = 3 + 2 * (timeAvSouthBCN - 1);

% Nodes in the box that lie on the coast
%indexos = find(dat(indNodesBd,1) >= x1 & dat(indNodesBd,1) <= x2 & ...
%   dat(indNodesBd,2) >= y1 & dat(indNodesBd,2) <= y2)
indexos = dat(indNodesBd,1) >= x1 & dat(indNodesBd,1) <= x2 & ...
    dat(indNodesBd,2) >= y1 & dat(indNodesBd,2) <= y2;
nodesSouthBCN = indNodesBd(indexos);

% Plot of the mesh. The nodes on the coast between the specified 
% coordinates bolted in red (uncomment)

%
%plotElements(dat(:,1:2), elem, 0)
%hold on
%plot(dat(nodesSouthBCN,1), dat(nodesSouthBCN,2),'o',MarkerFaceColor='red')
%hold off
%

% Catalan coast's average temperature's computation form the selected nodes

tempSouthBCN=dat(nodesSouthBCN,nodTemp);
size(tempSouthBCN,1);
avTemp = sum(tempSouthBCN) / size(tempSouthBCN,1);
%fprintf("(d) Averaged (mean) temperature at %.2fh AM: %.5e%cC\n",...
%    timeAvSouthBCN, avTemp, deg)

% Print all the soluitons at once:
fprintf(['Solutions:\n' ...
    '(a) For the row %d, interpolated value of the temperature at ',...
     '%dh%dmin: %.5e%cC\n',...
    '(b) Number of stations with temperature larger than %.1f%cC: %d\n',...
    '(c) Interpolated temperature at point (%.1f, %.1f): %.5e%cC\n',...
    '(d) Averaged (mean) temperature at %.2fh AM: %.5e%cC\n'],...
    row, timeInterp1DHour, timeInterp1DMin, polyval(coefs,timeInterp1D),...
    deg, tempT, deg, numStationsOverTempT,...
    pointP', intepolatedTemp, deg,...
    timeAvSouthBCN, avTemp, deg)