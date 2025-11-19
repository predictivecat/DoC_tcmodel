function tseries_out=AAL2Deco(tseries)

%%
%This function reorders Deco time series to normal AAL90  AAL90-->Deco.
%Works with time series and SC matrices
id_fix_ = [1:45];
id_fix_2 = [90:-1:46];
id_fix_ = reshape([id_fix_; zeros(size(id_fix_))],[],1);
id_fix_2 = reshape([ zeros(size(id_fix_2));id_fix_2;],[],1);
id_fix = (id_fix_ + id_fix_2).';

if size(tseries,2) > size(tseries,1) % Time series (channels,samples)
    tseries_out = tseries(id_fix,:);
elseif size(tseries,2) == size(tseries,1) % SC or FC matrix (channels,channels)
    tseries_out = tseries(id_fix,id_fix);
end

end