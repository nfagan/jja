function out = jja_get_mean_pupil(varargin)

defaults = jja.get_common_make_defaults();
defaults.look_back = -300;
defaults.look_ahead = 0;
defaults.event = 'display_random_vs_info_cues';

params = jja.parsestruct( defaults, varargin );

conf = params.config;

events_p = jja.gid( 'events', conf );
labels_p = jja.gid( 'labels', conf );
sync_p = jja.gid( 'edf_sync', conf );
edf_p = jja.gid( 'edf', conf );

mats = jja.find_containing( events_p, '.mat', params.files_containing );

pupil = rowcell( numel(mats) );
ts = rowcell( numel(mats) );
labs = rowcell( numel(mats) );
is_ok = rowones( numel(mats), 'logical' );

parfor i = 1:numel(mats)
  shared_utils.general.progress( i, numel(mats), mfilename );
  
  events_file = shared_utils.io.fload( mats{i} );
  
  id = events_file.identifier;
  
  try
    edf_file = jja.load_intermediate( edf_p, id );
    sync_file = jja.load_intermediate( sync_p, id );
    labels_file = jja.load_intermediate( labels_p, id );
    
    out = pupil_main( labels_file, edf_file, events_file, sync_file, params );  
    
    pupil{i} = out.pupil;
    ts{i} = out.t;
    labs{i} = out.labels;
    
  catch err
    jja.print_fail_warn( id, err.message );
    is_ok(i) = false;
    continue;
  end
end

out = struct();
out.pupil = vertcat( pupil{is_ok} );
out.t = vertcat( ts{is_ok} );
out.labels = vertcat( fcat(), labs{is_ok} );

end

function outs = pupil_main(labels_file, edf_file, events_file, sync_file, params)

events = events_file.events;

n_trials = rows( events );

t_series = params.look_back:params.look_ahead;

n_tp = numel( t_series );

ps = edf_file.pupil;
t = edf_file.t;
first_t = t(1);
n_t = numel( t );

event = events(:, events_file.event_key(params.event));

mat_starts = sync_file.mat_sync;
edf_starts = sync_file.edf_sync;

pup_mat = nan( n_trials, n_tp );

to_assign = true( 1, n_tp );

for i = 1:n_trials
  evt = event(i);
  
  if ( isnan(evt) )
    continue;
  end
  
  edf_evt = round( shared_utils.sync.cinterp(evt, mat_starts, edf_starts) );
  
  if ( isnan(edf_evt) ), continue; end
  
  edf_start = edf_evt + params.look_back - first_t + 1;
  edf_stop = edf_evt + params.look_ahead - first_t + 1;
  
  full_range = edf_start:edf_stop;
  
  to_assign(:) = true;
  to_assign(full_range > n_t) = false;
  to_assign(full_range < 1) = false;
  
  pup_mat(i, to_assign) = ps(full_range(to_assign));
end

labs = fcat.from( labels_file.labels, labels_file.categories );

outs = struct();

outs.pupil = pup_mat;
outs.labels = labs;
outs.t = t_series;

end