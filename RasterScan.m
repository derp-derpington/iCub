function M=RasterScan(Mask,nPix)
% suggest nPix>3
M=-im2double(Mask);
[s1 s2]=size(M);
%% First Pass: connect adjacent groups (right down)
% if -1 assign lable as...
% if no neighbors labled increment lable and apply most recent
% if neighbors labeled, assign lowest neighbor lable
k=0;
for i=1:s1
    for j=1:s2
        if M(i,j)==-1
            if i==1&&j==1
                k=k+1;
                M(i,j)=k;
            end
            if i==1&&j>1
                if M(i,j-1)==0
                    k=k+1;
                    M(i,j)=k;
                else
                    M(i,j)=M(i,j-1);
                end
            end
            if i>1&&j==1
                if M(i-1,j)==0
                    k=k+1;
                    M(i,j)=k;
                else
                    M(i,j)=M(i-1,j);
                end
            end
            if i>1&&j>1
                if (M(i-1,j)==0)&&(M(i,j-1)==0)
                    k=k+1;
                    M(i,j)=k;
                end
                if (M(i-1,j)==0)&&(M(i,j-1)~=0)
                    M(i,j)=M(i,j-1);
                end
                if (M(i-1,j)~=0)&&(M(i,j-1)==0)
                    M(i,j)=M(i-1,j);
                end
                if (M(i-1,j)~=0)&&(M(i,j-1)~=0)
                    M(i,j)=min(M(i-1,j),M(i,j-1));
                end
            end
        end
    end
end
%% Second Pass: connect adjacent groups (left up)
% if neighbor left or up reassign as lowest
for i=1:s1-1
    for j=1:s2-1
        if M(i,j)~=0
            if M(i+1,j)~=0 && M(i+1,j)~=M(i,j)
                M=(M==M(i+1,j))*M(i,j)+(M~=M(i+1,j)).*M;
            end
            if M(i,j+1)~=0 && M(i,j+1)~=M(i,j)
                M=(M==M(i,j+1))*M(i,j)+(M~=M(i,j+1)).*M;
            end
        end
    end
end
%% Third Pass: sort 1 to n of size > nPix
% if below min pix size discard
s=0;M1=0*M;
for k=1:max(max(M))
    if sum(sum(M==k))>nPix
        s=s+1;
        M1=((M==k)*s+(M~=k).*M1);
    end
end
M=M1;
%% Third Pass: sort by size
% sort from largest (labeled 1) to smallest
Msize=[];
for k=1:max(max(M1))
    Msize(k)=sum(sum(M1==k));
end
[temp indx]=sort(-Msize);
M2=0*M1;
for k=1:max(max(M1))
    M2=(M~=indx(k)).*M2+(M1==indx(k))*k;
end
M=M2;

