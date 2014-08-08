function F = comp_ifilterbank_fftbl(c,G,foff,a,realonly)
%COMP_IFILTERBANK_FFTBL  Compute filtering in FD
%
%

M = numel(c);
W = size(c{1},2);

if size(a,2)>1
   afrac=a(:,1)./a(:,2);
else
   afrac = a(:,1);
end

if 0
   N = cellfun(@(cEl) size(cEl,1),c);
   L = N.*afrac;
   assert(all(rem(L,1))<1e-6,'%s: Bad subband lengths. \n',upper(mfilename));
   L = round(L);
   assert(all(L==L(1)),'%s:Bad subband lengths. \n',upper(mfilename));
   L = L(1);
else
   L = afrac(1).*size(c{1},1);
end

F = zeros(L,W,assert_classname(c{1},G{1}));

fsuppRangeSmall = cellfun(@(fEl,GEl) mod([fEl:fEl+numel(GEl)-1].',L)+1,...
                          num2cell(foff),G,'UniformOutput',0);
%
for w=1:W 
   for m=1:M
     Ctmp = postpad(circshift(fft(c{m}(:,w)),-foff(m)),numel(G{m}));
     %Ctmp = postpad(fft(c{m}(:,w)),numel(G{m}));
     F(fsuppRangeSmall{m},w)=F(fsuppRangeSmall{m},w) + Ctmp.*conj(G{m});
   end;
end


% Handle the real only as a separate filter using recursion
realonlyRange = 1:M;
realonlyRange = realonlyRange(realonly>0);

if ~isempty(realonlyRange)
   Gconj = cellfun(@(gEl) conj(gEl(end:-1:1)),G(realonlyRange),'UniformOutput',0);
   LG = cellfun(@(gEl) numel(gEl),Gconj);
   foffconj = -L+mod(L-foff(realonlyRange)-LG,L)+1;
   aconj = a(realonlyRange,:);

   cconj = comp_ifilterbank_fftbl(F,Gconj,L,foffconj,aconj,0);
   for ii=1:numel(cconj)
      c{realonlyRange(ii)} = (c{realonlyRange(ii)} + cconj{ii})/2;
   end
end