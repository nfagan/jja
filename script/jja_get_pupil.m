function out = jja_get_mean_pupil(varargin)

defaults = jja.get_common_make_defaults();
defaults.look_back = 0;
defaults.look_ahead = 1e3;

params = jja.parsestruct( defaults, varargin );

conf = params.config;

events_p = jja.gid( 'events', conf );
labels_p = jja.gid( 'labels', conf );
sync_p = jja.gid( 'edf_sync', conf );
edf_p = jja.gid( 'edf', conf );

mats = jja.find_containing( events_p, '.mat', params.files_containing );

lookdurs = rowcell( numel(mats) );
lookfracs = rowcell( numel(mats) );
looklabs = rowcell( numel(mats) );
is_ok = rowones( numel(mats), 'logical' );

for i = 1:numel(mats)
  shared_utils.general.progress( i, numel(mats), mfilename );
  
  events_file = shared_utils.io.fload( mats{i} );
  
  id = events_file.identifier;
  
  try
    edf_file = jja.load_intermediate( edf_p, id );
    sync_file = jja.load_intermediate( sync_p, id );
    labels_file = jja.load_intermediate( labels_p, id );
    
    out = pupil_main( labels_file, edf_file, events_file, sync_file );  
    
    lookdurs{i} = out.looking_duration;
    lookfracs{i} = out.looking_fraction;
    looklabs{i} = out.labels;
    
  catch err
    jja.print_fail_warn( id, err.message );
    is_ok(i) = false;
    continue;
  end
end

out = struct();
out.looking_duration = vertcat( lookdurs{is_ok} );
out.looking_fraction = vertcat( lookfracs{is_ok} );
out.labels = vertcat( fcat(), looklabs{is_ok} );

end

function outs = pupil_main(labels_file, edf_file, events_file, sync_file, params)

events = events_file.events;

n_trials = rows( events );

ps = edf_file.pupil;

trial_start

social_image_onset = events(:, events_file.event_key('display_social_image'));
reward_onset = events(:, events_file.event_key('reward'));

mat_starts = sync_file.mat_sync;
edf_starts = sync_file.edf_sync;

stp = 1;

for i = 1:n_rois
  roi_name = roi_names{i};
  rect = rects(roi_name);
  ib = bfw.bounds.rect( x, y, rect );
  
  for j = 1:n_trials
    img_onset = social_image_onset(j);
    rwd_onset = reward_onset(j);
    
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