function out = jja_get_social_image_looking_duration(varargin)

defaults = jja.get_common_make_defaults();
defaults.start_event = 'display_social_image';
defaults.stop_event = 'reward';

inputs = { 'events', 'labels', 'edf_sync', 'edf', 'rois' };
output = '';

[params, runner] = jja.get_params_and_loop_runner( inputs, output, defaults, varargin );
runner.convert_to_non_saving_with_output();
runner.main_error_handler = 'error';

results = runner.run( @social_image_main, params );

results(~[results.success]) = [];
outputs = [ results.output ];

out = struct();
out.looking_duration = vertcat( outputs.looking_duration );
out.looking_fraction = vertcat( outputs.looking_fraction );
out.labels = vertcat( fcat(), outputs.labels );

end

function outs = social_image_main(files, params)

labels_file =   shared_utils.general.get( files, 'labels' );
edf_file =      shared_utils.general.get( files, 'edf' );
events_file =   shared_utils.general.get( files, 'events' );
sync_file =     shared_utils.general.get( files, 'edf_sync' );
roi_file =      shared_utils.general.get( files, 'rois' );

events = events_file.events;
rects = roi_file.rects;

roi_names = keys( rects );

n_trials = rows( events );
n_rois = rects.Count;

x = edf_file.x;
y = edf_file.y;

lookdur = rownan( n_trials * n_rois );
lookfrac = rownan( numel(lookdur) );
event_indices = rownan( numel(lookdur) );
roi_indices = rownan( numel(lookdur) );

start_event_name = params.start_event;
stop_event_name = params.stop_event;

onset_time = events(:, events_file.event_key(start_event_name));
offset_time = events(:, events_file.event_key(stop_event_name));

mat_starts = sync_file.mat_sync;
edf_starts = sync_file.edf_sync;

stp = 1;

for i = 1:n_rois
  roi_name = roi_names{i};
  rect = rects(roi_name);
  
  ib = bfw.bounds.rect( x, y, rect );
  
  for j = 1:n_trials
    img_onset = onset_time(j);
    rwd_onset = offset_time(j);
    
    event_indices(stp) = j;
    roi_indices(stp) = i;

    if ( isnan(img_onset) || isnan(rwd_onset) )
      stp = stp + 1;
      continue; 
    end

    edf_img_onset = round( shared_utils.sync.cinterp(img_onset, mat_starts, edf_starts) );
    edf_rwd_onset = round( shared_utils.sync.cinterp(rwd_onset, mat_starts, edf_starts) );

    edf_start = edf_file.t == edf_img_onset;
    edf_stop = edf_file.t == edf_rwd_onset;

    if ( nnz(edf_start) ~= 1 || nnz(edf_stop) ~= 1 )
      warning( 'No matching start or stop time.' );
      stp = stp + 1;
      continue;
    end
    
    subset_ib = ib(find(edf_start):find(edf_stop));
    
    lookdur(stp) = sum( subset_ib ) / 1e3;  % seconds
    lookfrac(stp) = pnz( subset_ib );
    
    stp = stp + 1;
  end
end

labs = fcat.from( labels_file.labels, labels_file.categories );

repmat( labs, n_rois );
addsetcat( labs, 'roi', roi_names(roi_indices) );

outs = struct();

outs.looking_duration = lookdur;
outs.looking_fraction = lookfrac;
outs.labels = labs;

end