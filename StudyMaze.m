clear;clc;
%% ========================================================================
% Model Parameters:
ImageFile='StudyMaze1.jpg';
Blur=false;Sigma=3;%Gaussian pixel blur
MinimumGroupPixelCount=10;
RedThresh=@(R,G,B) (R>0.90)&(R<1.00)&(G>0.32)&(G<0.55)&(B>0.33)&(B<0.56);
InvScale=400;
GrdScale=8;
%% ========================================================================
f = imread(ImageFile);
figure(1);clf;set(gcf,'color','w');imshow(f)
f = im2double(f);% image to double
title('Original Image')

%f=imresize(f, [1000 1000]);
if Blur==true
    g = fspecial('gaussian',2*ceil(3*Sigma)+1,Sigma);
    f=imfilter(f,g, 'replicate');
end
hsv_f=rgb2hsv(f);
figure(2);set(gcf,'color','w');imshow(hsv_f)
title('HSV Image')

hsv_R=hsv_f(:,:,1);
hsv_G=hsv_f(:,:,2);
hsv_B=hsv_f(:,:,3);
Mask=RedThresh(hsv_R,hsv_G,hsv_B);% red threshold
figure(3);clf;set(gcf,'color','w');imshow(Mask==0);
title('Applying Red Threshold')

%% raster scan to detect color blobs
% values sorted from largest to smallest (1=largest)
M=RasterScan(Mask,MinimumGroupPixelCount);
nObjects=max(max(M))
figure(4);clf;set(gcf,'color','w');imshow(Mask==0);
title([num2str(nObjects),' Detected Objects']);axis ij;
hold on;%Show 4 largest objects
for k=1:4
    [xc(k),yc(k)]=ObjectCenter(M,k);    
end
for k=1:4
    for i=1:4
        if i~=k
            plot([xc(k),xc(i)],[yc(k),yc(i)],'-b','linewidth',3)
        end
    end
end
for k=1:4
    plot(xc(k),yc(k),'or','linewidth',3,'markersize',20,'markerfacecolor','r')
    text(xc(k),yc(k),['\color{blue}',num2str(k)],...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'FontSize',12)   
end
hold off

%Assign Quadrants
figure(1);clf;set(gcf,'color','w');imshow(f)
[s1 s2]=size(f);
Direction={'NE','NW','SW','SE'};
for k=1:4
    [xc(k),yc(k)];
    if sum(xc(k)>xc)>1 && sum(yc(k)<yc)>1
        Q(k)=1;text(xc(k),yc(k),...
            Direction{1},'color','w','FontSize',20,'HorizontalAlignment','center')
    end
    if sum(xc(k)<xc)>1 && sum(yc(k)<yc)>1
        Q(k)=2;text(xc(k),yc(k),...
            Direction{2},'color','w','FontSize',20,'HorizontalAlignment','center')
    end
    if sum(xc(k)<xc)>1 && sum(yc(k)>yc)>1
        Q(k)=3;text(xc(k),yc(k),...
            Direction{3},'color','w','FontSize',20,'HorizontalAlignment','center')
    end
    if sum(xc(k)>xc)>1 && sum(yc(k)>yc)>1
        Q(k)=4;text(xc(k),yc(k),...
            Direction{4},'color','w','FontSize',20,'HorizontalAlignment','center')
    end
end
%% Inverse Homography
%Tagged Corner Locations
NE1=[xc(Q(1)) yc(Q(1))];
NW1=[xc(Q(2)) yc(Q(2))];
SW1=[xc(Q(3)) yc(Q(3))];
SE1=[xc(Q(4)) yc(Q(4))];
%Transformed Corner Locations
NW2=[1 1];NE2=[InvScale 1];SW2=[1 InvScale];SE2=[InvScale InvScale];
% Inverse Homography
x1=[NE1(1);NW1(1);SW1(1);SE1(1)];y1=[NE1(2);NW1(2);SW1(2);SE1(2)];
x2=[NE2(1);NW2(1);SW2(1);SE2(1)];y2=[NE2(2);NW2(2);SW2(2);SE2(2)];
[f_inv,x_inv,y_inv,H]=InverseHomo(hsv_f,x1,y1,x2,y2);H
hxc=(x2-x_inv(1));%<<< divide by two for projected? >>>
hyc=(y2-y_inv(1));
%Direction={'NE','NW','SW','SE'};
figure(5);clf;set(gcf,'color','w');imshow(f_inv)
for k=1:4
    text(hxc(k),hyc(k),...
        Direction{k},'color','w','FontSize',20,'HorizontalAlignment','center')
end
title('Labeled Inverse Homography')

%% Crop and Grid
f_inv_crop=f_inv(round(hyc(2)):round(hyc(3)),...
    round(hxc(2)):round(hxc(4)),:);%If this has indx error reduce InvScale
figure(6);clf;set(gcf,'color','w');imshow(f_inv_crop)
title('Cropped Image')
[s1 s2]=size(f_inv_crop(:,:,1));
hold on
for k=1:GrdScale-1
    plot([k*s1/GrdScale,k*s1/GrdScale],[1,s2],'w','linewidth',1)
end
for k=1:GrdScale-1
    plot([1,s1],[k*s2/GrdScale,k*s2/GrdScale],'w','linewidth',1)
end
hold off

%% Anylyze Grid and Determine Policy

%% Policy GrdScale X GrdScale matrix of entries from 1 to 4
% e.g.
P = ceil(4*rand(GrdScale));

% if ball in grid i,j apply P(i,j) then level then repeat, etc.


% The output of StudyMaze is the matrix P (and that nothing else)

