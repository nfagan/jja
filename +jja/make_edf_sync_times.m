function result = make_edf_sync_times(varargin)

defaults = jja.get_common_make_defaults();

inputs = { 'unified', 'edf' };
output = 'edf_sync';

[params, loop_runner] = jja.get_params_and_loop_runner( inputs, output, defaults, varargin );
loop_runner.func_name = mfilename;

result = loop_runner.run( @make_sync_main, params );

end

function sync_file = make_sync_main(files, params)

unified_file = files.unified;
edf_file = files.edf;

mat_start_times = arrayfun( @(x) x.events.trial_start, unified_file.trial_data );
edf_start_times = edf_file.sync_times;

n_mat = numel( mat_start_times );
n_edf = numel( edf_start_times );

if ( n_mat ~= n_edf )
  assert( n_edf == n_mat + 1, ['Mismatch between .edf and .mat sync times:' ...
    , ' mat has %d; edf has %d.'], n_mat, n_edf );
  
  edf_start_times = edf_start_times(1:end-1);
end

sync_file = struct();
sync_file.identifier = unified_file.identifier;
sync_file.params = params;
sync_file.mat_sync = mat_start_times(:);
sync_file.edf_sync = edf_start_times(:);

end