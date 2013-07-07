function [xc,yc]=ObjectCenter(M,k)
% M is a matrix with nonzero entries of k
% the i,j centroid is:
[s1 s2]=size(M);
N=0;xc=0;yc=0;
for i=1:s1
    for j=1:s2
        if M(i,j)==k
            xc=xc+j;
            yc=yc+i;
            N=N+1;
        end
    end
end
xc=xc/N;
yc=yc/N;