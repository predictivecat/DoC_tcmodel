function[p,pe,ptie] = entropy(y,epz)
% entropy - order 3
ord = 3;
pe = 0;
ly=length(y); % timeseries needs to be 1*n size
permlist = perms(1:ord);
ctie = 0;
ct(1:length(permlist)) = 0; % init bin

for j = 1:ly-2
    seg = y(j:j+2);
    [a,iv] = sort(seg); % sorts ordsize section of seg
    da = abs(diff(a)); % find difference between points in the motif
    if (min(da))<epz
        ctie=ctie+1; % if<threshold add to 7th bin
    else
        for i = 1:length(permlist)
            if permlist(i,:)-iv ==0
                ct(i)=ct(i)+1;
            end
        end
    end
end
p = ct/(ly-ord); %normalize to total area
ptie = ctie/(ly-ord); % normalize for ctie
ziz = find(p>0);
e = -sum(p(ziz).*log(p(ziz))); % compute entropy
if ptie>0
    etie = -ptie.*log(ptie);
else etie = 0;
end
pe = (e+etie)/log(7);
end
