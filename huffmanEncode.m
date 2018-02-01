function huffmanEncode(I,name)
%only for 8 bit gray image
%usage: huffmanEncode(matrix,filename) 
%output:a binary file contains huffman code and dictionary
if ~ischar(name)
    disp('Invalid file name');
else
    f=imhist(I);
    t=size(find(f~=0));
    g=zeros(t(1),2);
    global code;
    code=cell(t(1),1);
    global codeDepth;
    codeDepth=zeros(t(1),1);
    l=1;
    for i=1:256
        if f(i)~=0
            g(l,1)=i-1;
            g(l,2)=f(i);            
            l=l+1;
        end
    end
    global h;
    h=zeros(2*t(1)-1,4);%full binary tree has 2*n0-1 nodes
    left=-1; % -1 means null
    right=-1;
    for i=1:t(1)
        h(i,:)=[g(i,1),g(i,2),left,right];
    end
    index=1:t(1);
    min1=0;%minimum frequence
    min2=0;%minimum frequence
    u=0;  %index of min1
    v=0;  %index of min2
    y=t(1)+1;
    for i=1:t(1)-1
        min1=min(h(index,2));
        u=find(h(:,2)==min1,1);
        index=setdiff(index,u);
        min2=min(h(index,2));
        v=find(h(:,2)==min2,1);
        if u==v %if same find another
            v=find(h(:,2)==min2,2);
            v=v(2);
        end
        index=setdiff(index,v);
        h(y,:)=[-1,h(u,2)+h(v,2),v,u];
        index=[index,y];
        y=y+1;
    end
    preOrder(h(2*t(1)-1,3),'0');
    preOrder(h(2*t(1)-1,4),'1');    
    [m,n]=size(I);
    sum=0;
    for i=1:t(1)
        sum=sum + g(i,2)*codeDepth(i);
    end
    bin = fopen(name,'wb');
    dicsize=8+32*3;
    for i=1:t(1)
        dicsize=dicsize+8+8+32+codeDepth(i);
    end    
    fwrite(bin,t(1),'ubit8',0,'b');%8bits for dic header
    fwrite(bin,sum,'ubit32',0,'b');%32bits for total huffman code
    fwrite(bin,m,'ubit32',0,'b'); %length
    fwrite(bin,n,'ubit32',0,'b'); %width
    for i=1:t(1)
        fwrite(bin,g(i,1),'ubit8',0,'b');
        fwrite(bin,g(i,2),'ubit32',0,'b');
        fwrite(bin,codeDepth(i),'ubit8',0,'b');
        for q=1:codeDepth(i)
            fwrite(bin,code{i}(q)-'0','ubit1',0,'b');
        end
    end
    
    disp(['Compressed Rate = ',num2str((sum+dicsize)*100/(m*n*8)), '% (for 8bit gray image)']);
    for i=1:m
        for j=1:n
            o=find(g(:,1)==I(i,j));
            p=zeros(1,codeDepth(o));
            for k=1:codeDepth(o)
                 p(k)=code{o}(k)-'0';
            end
            p=boolean(p);
            fwrite(bin,p,'ubit1',0,'b');
        end
    end
    fclose(bin);
end

function [] = preOrder(node,c)
global h;
global code;
global codeDepth;
if h(node,1) ~= -1 % is leaf
    code{node}=c;
    temp=size(c);
    codeDepth(node)=temp(2);
else
    %left
    preOrder(h(node,3),[c,'0']);
    %right
    preOrder(h(node,4),[c,'1']);
end




