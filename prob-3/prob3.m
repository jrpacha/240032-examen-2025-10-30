% 2025-26-ex-parcial-q1
% Problem 3

clearvars
close all

%
% Data
% -------------------------------------------------------------------------------------------------------------------
a1 = [0.59, 0.49, 0.31, 0.29, 0.16]; %question 1
%a1 = [0.53, 0.43, 0.35, 0.30, 0.20]; %question 2
%a1 = [0.60, 0.50, 0.40, 0.25, 0.18]; %question 3
%a1 = [0.54, 0.44, 0.39, 0.28, 0.20]; %question 4
%a1 = [0.50, 0.40, 0.38, 0.29, 0.17]; %question 5
%a1 = [0.57, 0.47, 0.34, 0.27, 0.12]; %question 6

L = 0.10;  %m

f = 180.0; %N / m^2, question 1
%f = 110.0; %N / m^2, question 2
%f = 120.0; %N / m^2, question 3
%f = 110.0; %N / m^2, question 4
%f = 170.0; %N / m^2, question 5
%f = 180.0; %N / m^2, question 6

numNodes = 6;

pointP = L / 2;
pointHint = L / 4;


a = 0; b = L;
% -------------------------------------------------------------------------

%
% (a) (2 points) The value $K^{1}_{1,1}$ is:
%
nodes = linspace(a,b,numNodes);
elem = [1:numNodes-1; 2:numNodes]';
numElem = size(elem,1); h = (b-a) / numElem;

%fprintf(['(a) K^1_11 = %.4f\n',...
%        '    Hint: K^2_11 = %4f\n'], a1(1) / h, a1(2) / h)
K = zeros(numNodes);
F = zeros(numNodes,1);
Q = zeros(numNodes,1);

Fe = f * h * [1; 1] / 2;

for e = 1:numElem
    rows = [elem(e,1), elem(e,2)];
    cols = rows;
    Ke = a1(e) * [1, -1; -1, 1] / h;
    K(rows,cols) = K(rows, cols) + Ke;
    F(rows) = F(rows) + Fe;
end

%
% (b) The maximum velocity u(y_i) among all the nodes
%

%Boundary conditions
fixedNodes = [1, 6];
freeNodes = setdiff(1:numNodes, fixedNodes);

%Natural B.C.:
Q(freeNodes) = 0.0; %Not necessary, since vector Q was initialised to 0

%Essential B.C.:
u = zeros(numNodes,1);
u(1) = 0.0;
u(6) = 0.0;

%Reduced system
Fm = F(freeNodes) + Q(freeNodes) - K(freeNodes,fixedNodes)*u(fixedNodes);
% Remark: Not necessary, since u(fixedNodes) = 0;
Km = K(freeNodes,freeNodes);

%Solution of the reduced system
um = Km \ Fm;
u(freeNodes) = um;

%fprintf(['(b) Maximum velocity among all the nodes: %.4f m/s\n', ...
%         '    Hint; Sum(u) = %.4f\n'] , max(u), sum(u))

%
% (c) Interpolate the solution values u(y_i) using a function p(y) = 
%     sum(c_i y^i, i = 0..5)
%

coefs = polyfit(nodes, u, 5);
%fprintf(['(c) Interpolated Solution value at half the depth of the pipe, p(%.2f) = %.4f\n', ...
%        '    Hint: p(%.3f) = %.4f\n'],...
%        pointP, polyval(coefs, pointP), pointHint, polyval(coefs, pointHint))

%
% Print all the solutions at once:
%
fprintf(['Solutions:\n',...
    '(a) K^1_11 = %.4f\n',...
    '    Hint: K^2_11 = %4f\n',...
    '(b) Maximum velocity among all the nodes: %.4f m/s\n',...
    '    Hint; Sum(u) = %.4f\n',...
    '(c) Interpolated Solution value at half the depth of the pipe, p(%.2f) = %.4f\n', ...
    '    Hint: p(%.3f) = %.4f\n'],...
         a1(1) / h, a1(2) / h,...
         max(u), sum(u),...
         pointP, polyval(coefs, pointP), pointHint, polyval(coefs, pointHint))