function jja_plot_cue_and_image_lookdur_final(look_out, is_info_random_cues, varargin)

defaults = struct();
defaults.do_save = true;
defaults.prefix = '';
defaults.is_normalized = true;

params = jja.parsestruct( defaults, varargin );

params.plot_p = fullfile( jja.dataroot, 'plots', datestr(now, 'mmddyy') );
params.analysis_p = fullfile( jja.dataroot, 'analyses', datestr(now, 'mmddyy') );

params.plot_p = fullfile( params.plot_p, ternary(params.is_normalized, 'norm', 'non-norm') );
params.analysis_p = fullfile( params.analysis_p, ternary(params.is_normalized, 'norm', 'non-norm') );

%%  drug and roi labeling

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

%%

if ( params.is_normalized )
  usedur = normdur;
else
  usedur = lookdur;
end

plot_looks_by_valence_and_outcome( usedur, looklabs', is_info_random_cues, params );

end

function plot_looks_by_valence_and_outcome(pltdat, pltlabs, is_info_random_cues, params)
  
do_save = params.do_save;
prefix = params.prefix;

is_per_reward_type = true;
is_per_bin = false;
is_per_monkey = false;
is_per_selected_cue = true;
is_choice_only = false;
is_per_trial = true;

pl = plotlabeled.make_common();
pl.x_tick_rotation = 0;

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

copy_labs = pltlabs';

if ( ~is_per_monkey ),        collapsecat( pltlabs, 'monkey' ); end
if ( ~is_per_reward_type ),   collapsecat( pltlabs, 'reward_type' ); end
if ( ~is_per_selected_cue ),  collapsecat( pltlabs, 'selected_cue' ); end
if ( is_per_bin ),            pcats{end+1} = bin_category; end

axs = pl.bar( pltdat, pltlabs, xcats, gcats, pcats );

if ( do_save )
  dsp3.req_savefig( gcf, params.plot_p, pltlabs, pcats, prefix );
end

%%  Anova

factors = { 'selected_cue', 'reward_type' };
mask = find( ~isnan(pltdat) );

anova_outs = dsp3.anovan( pltdat, pltlabs', {}, factors, 'mask', mask );

if ( params.do_save )
  save_p = fullfile( params.analysis_p, ternary(is_info_random_cues, 'cues', 'faces') );
  
  dsp3.save_anova_outputs( anova_outs, save_p, csunion(gcats, pcats) );
end

%%  Means per selected cue

outcome_descriptives = dsp3.descriptive_table( pltdat, copy_labs', 'selected_cue', [], mask );

if ( params.do_save )
  save_p = fullfile( params.analysis_p, ternary(is_info_random_cues, 'cues', 'faces') );
  
  dsp3.savetbl( outcome_descriptives, save_p, copy_labs', 'selected_cue', 'per_outcome_descriptives__' );
end

%%  Means across monkey

descriptives = dsp3.descriptive_table( pltdat, copy_labs', 'monkey', [], mask );

if ( params.do_save )
  save_p = fullfile( params.analysis_p, ternary(is_info_random_cues, 'cues', 'faces') );
  
  dsp3.savetbl( descriptives, save_p, copy_labs', 'monkey', 'collapsed_descriptives__' );
end

%%  Means across monkey, per valence

valence_descriptives = dsp3.descriptive_table( pltdat, copy_labs', {'monkey', 'reward_type'}, [], mask );

if ( params.do_save )
  save_p = fullfile( params.analysis_p, ternary(is_info_random_cues, 'cues', 'faces') );
  
  dsp3.savetbl( valence_descriptives, save_p, copy_labs', {'monkey', 'reward_type'}, 'collapsed_descriptives__' );
end
  
end

