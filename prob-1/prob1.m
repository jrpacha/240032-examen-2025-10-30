clearvars
close all
format short e
format compact

d = 1.0;     %Distance form the right tip of the left spring to the 
             %left end of the bar
A = 3.0;
k1 = 1.0;    %Left spring's stiffness constant 
k2 = 3.0;    %Right spring's stiffness constant 
xP = pi / 4; %Point where to interpolate the displacement in item (d)

nodes = [0; pi; 3*pi/2; 2*pi];
numNodes = size(nodes,1);

%
% Part (a) K(3,3) and Tr K
%

% Local stiffness matrix for element 1
syms x;
Psi1 = @(x) [(x-nodes(2)) / (nodes(1) - nodes(2));
    (x-nodes(1)) / (nodes(2) - nodes(1))];
dPsi1 = diff(Psi1,x);

E1 = @(x) (pi*(2+cos(x)))
K1 = A*double(int(E1(x)*(dPsi1*dPsi1'),x,nodes(1),nodes(2)));
fprintf("K1 = \n")
fprintf("%10.6f%10.6f\n",K1')

% Local stiffness matrix for element 2
E2 = pi;
Psi2 = [@(x) (x-nodes(3)) * (x-nodes(4)) /...
    ((nodes(2)-nodes(3))*(nodes(2)-nodes(4)));
             (x-nodes(2)) * (x-nodes(4)) /... 
    ((nodes(3)-nodes(2))*(nodes(3)-nodes(4)));
             (x-nodes(2)) * (x-nodes(3)) /...
    ((nodes(4)-nodes(2))*(nodes(4)-nodes(3)))];

dPsi2 = diff(Psi2,x);

K2 = A*E2*double(int(dPsi2*dPsi2',x,nodes(2),nodes(4)));
fprintf("K2 = \n")
fprintf("%10.6f%10.6f%10.6f\n",K2')

K = zeros(numNodes);

% Assembly local matrices
rows = [1,2]; cols = rows;
K(rows,cols) = K1;
rows = [2,3,4]; cols = rows;
K(rows,cols)= K(rows,cols)+K2;

Kini = K; %Save a copy of the raw stiffness matrix

% Print global stiffness matrix, K
fprintf("K = \n")
fprintf("%10.6f%10.6f%10.6f%10.6f\n",Kini')
fprintf(['\n(a) K_{3,3} = %10.6f\n ',...
         '   Hint. Tr K = %10.6f\n\n'], Kini(3,3), trace(Kini))
%
% Part (b) Computation of u(3)
% 

%Boundary conditions
fixedNodes = 4;
freeNodes= setdiff(1:numNodes, fixedNodes);
Q = zeros(numNodes,1);
u = zeros(numNodes,1);

% Natural B.C.
Q(1) = -k1*d;

% Essential B.C.
u(4) = 0.0;

% New global stiffness matrix that incorporates the springs' strength
K(1,1) = K(1,1) + k1;
K(3,3) = K(3,3) + k2;

% Print the modified stiffness matrix
fprintf("K_new = \n")
fprintf("%10.6f%10.6f%10.6f%10.6f\n",K')

% Reduced system, (K_m | F_m)
Fm = Q(freeNodes) - K(freeNodes,fixedNodes)*u(fixedNodes);
Km = K(freeNodes,freeNodes);

fprintf("(Km | Fm) = \n")
fprintf("%10.6f%10.6f%10.6f | %10.6f\n",[Km Fm]')
% Solution of the reduced system:

%Solution of the reduced system
um = Km\Fm;

u(freeNodes) = um;

% Displacements
for i = 0:numNodes
    if i == 0
        fprintf("\n(b) The displacements of the nodes are:\n")
    else
        if i == 2
            fprintf("    u(%d) = %s %c %.4e * Displacement of point A *\n", ...
                i, strtrim(rats(u(i))),char(8776),u(i))
        else 
            fprintf("    u(%d) = %s %c %.4e\n",i, strtrim(rats(u(i))),char(8776),u(i))
        end
    end
end 

%
% Part (c)
%

% Post Process
Q = Kini * u;
fprintf("\n(c) Post process Q = K U - F:\n")
for nod = 1:numNodes
    if abs(Q(nod)) < 1.0e-14
        Q(nod) = 0;
    end
    if nod == 1 | nod == 3
        fprintf("    Q(%d) = %s %c %.4e (*)\n", nod,strtrim(rats(Q(nod))),char(8776),Q(nod))
    else
        fprintf("    Q(%d) = %s %c %.4e\n", nod,strtrim(rats(Q(nod))),char(8776),Q(nod))
    end
end

%
% Part (d) 
% 

% Displacement at the point P, xP = pi / 4
uP = [u(1), u(2)]*Psi1(xP);
fprintf('\n(d) Interpolated value of u at pi/4, U(pi/4) = %s %c %.4e\n\n',...
    strtrim(rats(uP)),char(8776),uP)

fprintf(['Solutions:\n',...
    '(a) K_{3,3} = %10.6f\n ',...
    '   Hint. Tr K = %10.6f\n',...
    '(b) Displacement of point A, u(2) = %s %c %.4e\n',...
    '(c) Q(1) = %s %c %.4e\n',...
    '    Hint. Q(3) = %s %c %.4e\n',...
    '(d) Interpolated value of u at pi/4, U(pi/4) = %s %c %.4e\n'],...
     Kini(3,3), trace(Kini),strtrim(rats(u(2))),char(8776),u(2),...
     strtrim(rats(Q(1))),char(8776),Q(1),strtrim(rats(Q(3))),char(8776),Q(3),...
     strtrim(rats(uP)),char(8776),uP)