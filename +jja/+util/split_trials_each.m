function labs = split_trials_each(labs, cats, category, N, mask)

if ( nargin < 5 )
  mask = rowmask( labs );
end

I = findall( labs, cats, mask );
addcat( labs, category );

for i = 1:numel(I)
  jja.util.split_trials_into_n_bins( labs, category, N, I{i} );
end

end