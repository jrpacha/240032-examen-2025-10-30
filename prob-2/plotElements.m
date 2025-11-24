function plotElements(nodes, elem, numbering)

%
% (c)Numerical Factory 2024
%

if (numbering == 1)
    nE=1;  nN=1;
else 
    nE=0;  nN=0;
end    
[numNodes, dim] = size(nodes);
[numElem, nod4Elem] = size(elem);
% quadratic triangular elements
if (nod4Elem == 6 && dim ==2)
    elem = elem(:,1:3);
    % nod4Elem =3;
end


if (nod4Elem == 3 || nod4Elem == 6) %triangle edges
    edges = unique(sort([elem(:,[1,2]);elem(:,[2,3]);elem(:,[3,1])],2),'rows');
elseif (nod4Elem == 4) %quadrilateral edges
    edges = unique(sort([elem(:,[1,2]);elem(:,[2,3]);elem(:,[3,4]);elem(:,[4,1])],2),'rows');
elseif (nod4Elem == 2) %quadrilateral edges
    edges = elem(:,[1,2]);
end    

%Computation of the window size
xmin = min(nodes(:,1));
xmax = max(nodes(:,1));
if (dim==1)
    ymax=2;
    ymin=-2;
else
    ymax = max(nodes(:,2));
    ymin = min(nodes(:,2));
end
lx = xmax-xmin;
ly = ymax-ymin;
xmin = xmin - 0.1*lx;
xmax = xmax + 0.1*lx; 
ymin = ymin - 0.1*ly;
ymax = ymax + 0.1*ly;
lx = xmax-xmin;
ly = ymax-ymin;
figure('units','normalized','outerposition',[0 0 1 1]) % full screen figure
% figure()
ax1 = axes('Position',[0.1, 0.1, 0.8, 0.8]);
set(groot,'DefaultAxesFontSize',10)
grid on
hold on;
%Line widths and marker/font sizes adapted to the window size and the mesh
minDist1=min(sum(abs(nodes(edges(:,1),:)-nodes(edges(:,2),:)),2));
ratio=minDist1/max(lx,ly);
lineWidthNode=max(0.5,min(3,200*ratio));
if (numElem > 100), lineWidthNode=0.8; end %just to plot big meshes
lineWidthEdge = min(3,2*lineWidthNode);
if nN
    markerSizeNode = min(25,10*lineWidthNode);
%     msNodeBd = 8*lwNode;
else
    markerSizeNode = min(25,4*lineWidthNode);
    % markerSizeNode = 4*lineWidthNode;
%     msNodeBd = 4*lwNode;
end
fontSizeElem = min(20,8*lineWidthNode);
fontSizeNode = min(20,8*lineWidthNode);
shift=0;

if (dim <= 2)
    if (nod4Elem <= 3 && dim == 1) %1D bar elements
        nodes(:,2)=0;
        shift=0.2;

    elseif(nod4Elem == 2 && dim == 2) % 2D bar elements
        shift=0.03*ly;

    end
        axis equal
        axis([xmin xmax ymin ymax])
        patch(ax1,'Faces',elem,'Vertices',nodes,'FaceColor','none','Linewidth',lineWidthEdge)
        plot(ax1,nodes(:,1),nodes(:,2),'ko',...
            'MarkerFaceColor',[0.99,1,0.8],'Markersize',markerSizeNode,...
            'LineWidth',lineWidthNode);
        %Labels for numbering nodes and elements, trying to get a "nice" figure
        if nE
            for e=1:numElem
                xy=sum(nodes(elem(e,:),:),1)/nod4Elem;
                % labelNode = ['{\boldmath$',num2str(e),'$}'];
                labelNode = ['$\textbf{',num2str(e),'}$'];
                
                if (nod4Elem == 2 && dim == 2) %2D bar elements
                    vect=nodes(elem(e,2),:)-nodes(elem(e,1),:);
                    vect=vect/norm(vect);
                    xy(1)=xy(1)-shift*vect(2);
                    xy(2)=xy(2)+shift*vect(1);
                else    
                xy(2)=xy(2)+shift;
                end
                text(ax1, xy(1),xy(2),labelNode,'interpreter','LaTeX',...
                    'FontSize',fontSizeElem,'HorizontalAlignment','center')
            end
        end
        if nN
            for n=1:numNodes
                xy=nodes(n,:);
                % labelNode = ['{\boldmath$',num2str(n),'$}'];
                labelNode = ['$\textbf{',num2str(n),'}$'];
                text(ax1,xy(1),xy(2),labelNode,'interpreter','LaTeX',...
                    'FontSize',fontSizeNode,'HorizontalAlignment','center')
            end
        end

        h=title(['nNodes = ',num2str(numNodes),',  nElem = ',num2str(numElem)]);
        set(h,'FontSize',25,'FontWeight','bold') 

        hold off;
else %3 dimensions
    zmin = min(nodes(:,3));
    zmax = max(nodes(:,3));

    if(nod4Elem == 2 && dim == 3) %3D bar elements
        shift=0.03*ly;
        lz=zmax-zmin;
        dl = 0.03*min([lx,ly,lz]);
        axis equal
        axis([xmin xmax ymin ymax zmin zmax])
        %patch('Faces',elem,'Vertices',nodes,'FaceColor','none','Linewidth',0.8*lwEdge)
        for e=1:numElem
            pa = nodes(elem(e,end),:);
            pb = nodes(elem(e,1),:);
            vect = pb-pa;
            vect = vect/norm(vect);
            qa = pa + dl*vect;
            qb = pb - dl*vect;
            plot3([qa(1),qb(1)],[qa(2),qb(2)],[qa(3),qb(3)],'k-',...
            'LineWidth',lineWidthNode);
        end
        plot3(nodes(:,1),nodes(:,2),nodes(:,3),'ko',...
            'MarkerFaceColor',[0.99,1,0.8],'Markersize',markerSizeNode);
        az = 120;
        el = 20;
        view(az,el);
        camera = zeros(3,1);
        camera(1) = cos(pi*el/180)*sin(pi*az/180);
        camera(2) = -cos(pi*el/180)*cos(pi*az/180);
        camera(3) = sin(pi*el/180);
        %Labels for numbering nodes and elements, trying to get a "nice" figure
        if nE
            for e=1:numElem
                xy=sum(nodes(elem(e,:),:),1)/nod4Elem;
                labelNode = ['{\boldmath$',num2str(e),'$}'];
                vect=nodes(elem(e,end),:)-nodes(elem(e,1),:);
                vect=vect/norm(vect);
                vect=cross(vect,camera);
                xy=xy-shift*vect;
                text(xy(1),xy(2),xy(3),labelNode,'interpreter','LaTeX',...
                    'FontSize',fontSizeElem,'HorizontalAlignment','center')
            end
        end
        if nN
            for n=1:numNodes
                xy=nodes(n,:);
                labelNode = ['{\boldmath$',num2str(n),'$}'];
                text(xy(1),xy(2),xy(3),labelNode,'interpreter','LaTeX',...
                    'FontSize',fontSizeNode,'HorizontalAlignment','center')
            end
        end
        
        axis equal vis3d


        h=title(['nNodes = ',num2str(numNodes),',  nElem = ',num2str(numElem)]);
        set(h,'FontSize',25,'FontWeight','bold') 

        hold off;



    elseif (nod4Elem == 4 && dim == 3) % case Tetrahedra
        TRI=[];
        for e=1:numElem   
            TRI=[TRI; elem(e,[1,2,3])]; %face 1
            TRI=[TRI; elem(e,[1,3,4])];
            TRI=[TRI; elem(e,[1,2,4])];
            TRI=[TRI; elem(e,[2,3,4])];
        end
        trimesh(TRI,nodes(:,1),nodes(:,2),nodes(:,3),'EdgeColor', [0.1, 0.8, 0.8], 'FaceAlpha',0.7);
        view(120,20);
        axis equal vis3d


        hold off;
    end
end




