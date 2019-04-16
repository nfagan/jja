%%

event_names = struct();
% event_names.start_event = 'display_social_image';
% event_names.stop_event = 'reward';

event_names.start_event = 'display_info_cues';
event_names.stop_event = 'display_social_image';
% event_names.stop_event = 'reward';

look_out = jja_get_social_image_looking_duration( ...
  'is_parallel', true ...
  , event_names ...
);

plot_p = fullfile( jja.dataroot, 'plots', datestr(now, 'mmddyy') );

%%  drug and roi labeling

is_info_random_cues = true;

looklabs = look_out.labels';
lookdur = look_out.looking_duration;

assert_ispair( lookdur, looklabs );

jja.add_drug_labels( looklabs );
jja.relabel_rois_by_selected_cue( looklabs );

prune( looklabs );

if ( is_info_random_cues )
  mask = fcat.mask( looklabs ...
    , @find, {'looks-to-info', 'looks-to-random'} ...
    , @findnot, {'looks-to-info', 'selected_random'} ...
    , @findnot, {'looks-to-random', 'selected_info'} ...
  );
  
  setcat( looklabs, 'roi', 'looks-to-cue', mask );
end

%%  normalize per monkey

normdur = lookdur;

I = findall( looklabs, {'monkey', 'roi', 'task_type', 'drug'} );

for i = 1:numel(I)
  normdur(I{i}) = normdur(I{i}) / nanmean( lookdur(I{i}) );
end

%%  ot vs sal lookdur

do_save = false;
is_per_trial = true;
prefix = 'lookdur_block_average_drug';

pl = plotlabeled.make_common();

pltlabs = looklabs';
pltdat = lookdur;

mask = fcat.mask( pltlabs ...
  , @find, 'image' ...
  , @find, 'no_errors' ...
  , @find, 'social' ...
  , @find, 'tarantino' ...
  , @find, {'saline', 'oxytocin'} ...
  , @find, 'choice' ...
);

bin_category = 'binned_trials';
jja.util.split_trials_each( pltlabs, 'identifier', bin_category, 2, mask );

xcats = { 'monkey' };
gcats = { 'drug' };
pcats = { 'trial_type', 'selected_cue', bin_category  };

spec = { 'block', 'identifier', 'task_type', 'drug', 'selected_cue', 'trial_type' };

if ( is_per_trial )
  pltdat = pltdat(mask);
  keep( pltlabs, mask );
else
  [pltlabs, I] = keepeach( pltlabs', spec, mask );
  pltdat = rownanmean( pltdat, I );
end

pl.bar( pltdat, pltlabs, xcats, gcats, pcats );

if ( do_save )
  dsp3.req_savefig( gcf, plot_p, pltlabs, pcats, prefix );
end

%%  no-drug lookdur

do_save = false;
prefix = 'normalized_looking_to_cues_by_outcome_by_valence_choice_and_cued';

is_per_reward_type = true;
is_per_bin = false;
is_per_monkey = false;
is_per_selected_cue = true;
is_choice_only = false;
is_per_trial = true;
is_normalized = true;
is_info_random_cues = true;

pl = plotlabeled.make_common();
pl.x_tick_rotation = 0;

pltlabs = looklabs';
pltdat = ternary( is_normalized, normdur, lookdur );

mask = fcat.mask( pltlabs ...
  , @find, 'no_errors' ...
  , @find, 'social' ...
  , @findnone, {'saline', 'oxytocin'} ...
);

if ( is_choice_only )
  mask = find( pltlabs, 'choice', mask );
end

if ( is_info_random_cues )
  mask = fcat.mask( pltlabs, mask ...
    , @find, {'looks-to-cue'} ...
  );
else
  mask = find( pltlabs, 'image', mask );
end

bin_category = 'binned_trials';
jja.util.split_trials_each( pltlabs, 'identifier', bin_category, 2, mask );

xcats = { 'monkey' };
gcats = { 'selected_cue' };
pcats = { 'reward_type' };

if ( is_per_trial )
  pltdat = pltdat(mask);
  keep( pltlabs, mask );
else
  spec = { 'block', 'identifier', 'task_type', 'drug' ...
    , 'selected_cue', 'trial_type' };
  [pltlabs, I] = keepeach( pltlabs', spec, mask );
  pltdat = rownanmean( pltdat, I );
end

if ( ~is_per_monkey ),        collapsecat( pltlabs, 'monkey' ); end
if ( ~is_per_reward_type ),   collapsecat( pltlabs, 'reward_type' ); end
if ( ~is_per_selected_cue ),  collapsecat( pltlabs, 'selected_cue' ); end
if ( is_per_bin ),            pcats{end+1} = bin_category; end

axs = pl.bar( pltdat, pltlabs, xcats, gcats, pcats );

if ( do_save )
  dsp3.req_savefig( gcf, plot_p, pltlabs, pcats, prefix );
end

%%  no drug lookdur, choice + cued

do_save = false;
should_collapse_cues = true;
prefix = 'collapsed_all';

pl = plotlabeled.make_common();

pltlabs = looklabs';
pltdat = lookdur;

is_per_trial = true;

mask = fcat.mask( pltlabs ...
  , @find, {'looks-to-info', 'looks-to-random'} ...
  , @find, 'no_errors' ...
  , @find, {'social'} ...
  , @find, 'choice' ...
  , @findnone, {'saline', 'oxytocin', 'kubrick'} ...
  , @findnot, {'looks-to-info', 'selected_random'} ...
  , @findnot, {'looks-to-random', 'selected_info'} ...
);

bin_category = 'binned_trials';
jja.util.split_trials_each( pltlabs, 'identifier', bin_category, 2, mask );

% xcats = { 'trial_type' };
% gcats = { 'selected_cue' };

if ( should_collapse_cues )
  collapsecat( pltlabs, 'roi' );
end

xcats = { 'selected_cue' };
gcats = { 'reward_type' };
% gcats = {};
pcats = { 'roi', 'monkey' };

spec = { 'block', 'identifier', 'task_type', 'drug', 'selected_cue', 'trial_type' };

if ( is_per_trial )
  pltdat = pltdat(mask);
  keep( pltlabs, mask );
else
  [pltlabs, I] = keepeach( pltlabs', spec, mask );
  pltdat = rownanmean( pltdat, I );
end

axs = pl.bar( pltdat, pltlabs, xcats, gcats, pcats );

if ( do_save )
  dsp3.req_savefig( gcf, plot_p, pltlabs, pcats, prefix );
end

%%  

pltlabs = looklabs';
pltdat = lookdur;

is_per_trial = false;

mask = fcat.mask( pltlabs, find(~isnan(pltdat)) ...
  , @find, 'image' ...
  , @find, 'no_errors' ...
  , @find, 'social' ...
  , @findnone, {'saline', 'oxytocin'} ...
  , @find, 'choice' ...
);

if ( is_per_trial )
  pltdat = pltdat(mask);
  keep( pltlabs, mask );
else
  [pltlabs, I] = keepeach( pltlabs', spec, mask );
  pltdat = rownanmean( pltdat, I );
end

pcats = { 'trial_type', 'selected_cue', 'monkey' };

axs = pl.hist( pltdat, pltlabs, pcats, 100 );



