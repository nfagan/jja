function labs = split_trials_into_n_bins(labs, category, N, mask)

if ( nargin < 4 )
  mask = rowmask( labs );
end

n_mask = numel( mask );

N = min( N, n_mask );

n_per_bin = floor( n_mask / N );
bin_number = 1;

while ( bin_number <= N )
  start = (bin_number-1) * n_per_bin + 1;
  
  if ( bin_number < N )
    stop = min( start + n_per_bin - 1, n_mask );
  else
    stop = n_mask;
  end
  
  indices = mask(start:stop);
  
  setcat( labs, category, sprintf('binned-%d', bin_number), indices );
  
  bin_number = bin_number + 1;
end

end