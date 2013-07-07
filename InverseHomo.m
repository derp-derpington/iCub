function [f_inv,x_inv,y_inv,H]=InverseHomo(f,x1,y1,x2,y2)
% computes inverse homography for 4 or more sets of points
% {x1(k),y1(k)} are ordered pairs of points in the untransformed image
% {x2(k),y2(k)} are ordered pairs of points in the transformed image
z=zeros(1,3);A=[];
for i=1:length(x2)
    A=[A;[z,[x1(i),y1(i),1],-y2(i)*[x1(i),y1(i),1];
        [x1(i),y1(i),1],z,-x2(i)*[x1(i),y1(i),1]]];
end
if length(x1)==4% less computationaly expensive
    temp=null(A);
    h=temp(:,end)/temp(end,end);
else
    [U,S,V]=svd(A);h = V(:,9)./V(9,9);
end

H(1,:)=h(1:3);H(2,:)=h(3+1:3+3);H(3,:)=h(6+1:6+3);
Transform = maketform('projective',H');
[f_inv,x_inv,y_inv]=imtransform(f,Transform);
f_inv=im2double(f_inv);