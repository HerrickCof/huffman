function huffmanDecode(fileName)
%only for 8 bit gray image
%usage: huffmanDecode(filename)
%output:a 8bit gray image extract from the file
if ~ischar(fileName)
    disp('Invalid file name');
else
    bin=fopen(fileName,'r');
    entry=fread(bin,1,'ubit8',0,'b');
    sum=fread(bin,1,'ubit32',0,'b');
    length=fread(bin,1,'ubit32',0,'b');
    width=fread(bin,1,'ubit32',0,'b');
    word=zeros(entry,1);
    frequency=zeros(entry,1);
    codeDepth=zeros(entry,1);
    code=cell(entry,1);
    for i=1:entry
        word(i)=fread(bin,1,'ubit8',0,'b');
        frequency(i)=fread(bin,1,'ubit32',0,'b');
        codeDepth(i)=fread(bin,1,'ubit8',0,'b');
        ct=char(fread(bin,1,'ubit1',0,'b')+'0');
        for k=2:codeDepth(i)
            ct=[ct,fread(bin,1,'ubit1',0,'b')+'0'];
        end
        code{i}=ct;
    end
    J=fread(bin,sum,'ubit1',0,'b');
    J=J';
    fclose(bin);
    global tree;
    tree=zeros(2*entry-1,4);
    for i=1:entry
        tree(i,1)=word(i);
        tree(i,2)=frequency(i);
        tree(i,3)=-1;
        tree(i,4)=-1;
    end
    index=1:entry;
    min1=0;%minimum frequence
    min2=0;%minimum frequence
    u=0;  %index of min1
    v=0;  %index of min2
    y=entry+1;
    for i=1:entry-1
        min1=min(tree(index,2));
        u=find(tree(:,2)==min1,1);
        index=setdiff(index,u);
        min2=min(tree(index,2));
        v=find(tree(:,2)==min2,1);
        if u==v %if same find another
            v=find(tree(:,2)==min2,2);
            v=v(2);
        end
        index=setdiff(index,v);
        tree(y,:)=[-1,tree(u,2)+tree(v,2),v,u];
        index=[index,y];
        y=y+1;
    end  
    I=zeros(length,width);
    k=1;
    root=2*entry-1;
    for i=1:length
        for j=1:width
            c=J(k);
            node=root;
            while tree(node,1)==-1
                if c==1
                    node=tree(node,4);
                else
                    node=tree(node,3);
                end
                if k<sum
                    k=k+1;
                    c=J(k);
                else
                    break;
                end
            end
            I(i,j)=tree(node,1);
        end
    end
    I=uint8(I);
%     subplot();imshow(I);
    imwrite(I,'decompressed_LENA.bmp');
end
    