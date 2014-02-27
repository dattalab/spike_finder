function [cluster1,k,pc,L,D,BIC,cont] = SortSpikes_fsmem_GI(spikes,trainingSetSize,pcc,cth,th,ltol,calc_index,isTetrode,testSet)

% sort spikes
ss=size(spikes);
ss=fliplr(ss);
% if ss(2)<200
%     cluster1=[]; cluster1(1:ss(2))=1;
% else
if ~isTetrode
    [pc_ch,eigvec,sv] = runpca_mod(spikes);pc=pc_ch(1:pcc,:); clear pc_ch;
else
    pc=[];
   
        appSpikes(:,:)=spikes;
        [pc_ch,eigvec,sv] = runpca(appSpikes); 
        pc_ch=pc_ch(1:pcc,:); 
        pc=[pc; pc_ch]; %add selected PCs of same spikes from the 4 channel in the same column 
   
    clear pc_ch;
end

if isTetrode
    ss=ss(1);
else
    ss=ss(2);
end

if ss<=trainingSetSize
    %[k,W,M,L,cluster1,V]=smem(pc,th,cth,ltol);
    [M,V,W,L] = fsmem_mvgm(pc);
    k=length(W);
else
    if isTetrode
        trainingSet=randperm(size(spikes,2));
    else
        trainingSet=randperm(size(spikes,1));
    end
    trainingSet=trainingSet(1:trainingSetSize);
    
    %         appS=0;
    %         while appS<(0.95*trainingSetSize)
    %             trainingSet=unique(ceil(rand(1,trainingSetSize)*ss(2)));
    %             appS=length(trainingSet);
    %         end
    
    pc_trainingSet=pc(:,trainingSet);
    %[k,W,M,L,cluster1,V]=smem(pc_trainingSet,th,cth,ltol);
    [M,V,W,L] = fsmem_mvgm(pc_trainingSet);
    k=length(W);
end
c_=[];
cum_=[];
disp('SortSpikes_fsmem line 53')
if k>1
    for i=1:k
        mu(1,:)=M(:,1,i);
        sigma(:,:)=V(:,:,i);
        c_(i,:)=mvnpdf_bis(pc',mu,sigma)*W(i);
        disp('SortSpikes_fsmem line 59')
        if cth>0
            cum_(i,:)=mvncdf(pc',mu,sigma);
            disp('SortSpikes_fsmem line 62')
        end
    end
else
    mu=M';
    sigma=V;
    c_(1,:)=mvnpdf_bis(pc',mu,sigma);
    if cth>0
        cum_(1,:)=mvncdf(pc',mu,sigma);
        disp('SortSpikes_fsmem line 71')
    end
end
% appW=ones(size(c_));
% appM=ones(size(c_));
% for i=1:size(c_,1)
%     appW(i,:)=appW(i,:)*W(i);
%     appM(i,:)=appM(i,:)*max(c_(i,:));
% end
disp('SortSpikes_fsmem line 80')
[app,cluster1]=max(c_,[],1);


% %Calculate Davies-Bouldin's statistics
% if calc_index
%     M_(:,:)=M(:,1,:);
%     [D,t]=db_index(pc,cluster1',M_);
% else
%     D=[];
% end
D=[];

%Calculate BIC index
if calc_index && length(testSet)>0
%     if isTetrode
%         testSet=randperm(size(spikes,3));
%         testSet=testSet(1:round(size(spikes,3)*testSetSize));
%     else
%         testSet=randperm(size(spikes,1));
%         testSet=testSet(1:round(size(spikes,1)*testSetSize));
%     end
    pc_testSet=pc(:,testSet);
    [E,L_bic] = Expectation(pc_testSet',k,W,M,V);
    m_bic=size(pc,1);
    D_bic=size(spikes,2);
    k_bic=m_bic*(0.5*D_bic*(D_bic+1)+D_bic+1);    %change this for concatenated spikes
    BIC=-2*L_bic+k_bic*log(size(pc_testSet,2));
else
    BIC=[];
end


%Misclassification detection
%if (k>1)
%cum1=cum_./appM;
if cth>0
    for i=1:size(cum_,2);
        app=cum_(cluster1(i),i);
        if app<cth || app>(1-cth)
            cluster1(i)=0;
        end
    end
end

clear spikes pc_testSet pc_trainingSet

%Compute false negative/positive index
N=1e5;
cont=zeros(1,k);
if calc_index && k>1
    g_fun=zeros(1,N);
    c_fun=zeros(1,N);
    simData=zeros(N,size(pc,1));
    index=1;
    c_=[];
    for i=1:k
        g_fun(index:index+round(W(i)*N)-1)=i;
        appM=[];
        appM(1,:)=M(:,1,i);
        %appM=repmat(appM,round(W(i)*N),1);
        appV(:,:)=V(:,:,i);
        simData(index:index+round(W(i)*N)-1,:)=mvnrnd_bis(appM,appV,round(W(i)*N));
        index=index+round(W(i)*N);
    end
    for i=1:k
        appM=[];
        appM(1,:)=M(:,:,i);
        appV(:,:)=V(:,:,i);
        c_(i,:)=mvnpdf_bis(simData,appM,appV)*W(i);
    end
    [app,c_fun]=max(c_);
    for i=1:k
       g_neg=find(g_fun==i);
       c_neg=length(find(c_fun(g_neg)~=i));
       fn=length(c_neg)/length(g_neg);
       g_pos=find(g_fun~=i);
       c_pos=length(find(c_fun(g_pos)==i));
       fp=length(c_pos)/length(g_pos);
       cont(i)=fn+fp;
    end
end
    


%end;
pc=pc';
clear spikes appM appW c1 c_;