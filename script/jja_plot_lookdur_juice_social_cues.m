function jja_plot_lookdur_juice_social_cues(juice_out, soc_out, varargin)

defaults = struct();
defaults.do_save = true;

params = jja.parsestruct( defaults, varargin );

plot_p = fullfile( jja.dataroot, 'plots', datestr(now, 'mmddyy'), 'juice_vs_social' );
analysis_p = fullfile( jja.dataroot, 'analyses', datestr(now, 'mmddyy'), 'juice_vs_social' );

params.plot_p = plot_p;
params.analysis_p = analysis_p;

%%

juice_lookdur = juice_out.looking_duration;
juice_looklabs = juice_out.labels';

use_soc_lookdur = soc_out.looking_duration;
use_soc_looklabs = soc_out.labels';

juice_lookdur = indexpair( juice_lookdur, juice_looklabs ...
  , find(juice_looklabs, 'juice') );

use_soc_lookdur = indexpair( use_soc_lookdur, use_soc_looklabs ...
  , find(use_soc_looklabs, 'social') );

lookdur = [ juice_lookdur; use_soc_lookdur ];
looklabs = extend( fcat(), juice_looklabs, use_soc_looklabs );

assert_ispair( lookdur, looklabs );

jja.add_drug_labels( looklabs );
jja.relabel_rois_by_selected_cue( looklabs );

prune( looklabs );

mask = fcat.mask( looklabs ...
  , @find, {'looks-to-info', 'looks-to-random'} ...
  , @findnot, {'looks-to-info', 'selected_random'} ...
  , @findnot, {'looks-to-random', 'selected_info'} ...
);

setcat( looklabs, 'roi', 'looks-to-cue', mask );

%%  normalize per monkey

normdur = lookdur;

I = findall( looklabs, {'monkey', 'task_type', 'roi', 'drug'} );

for i = 1:numel(I)
  normdur(I{i}) = normdur(I{i}) / nanmean( lookdur(I{i}) );
end

plot_lookdur( normdur, looklabs', params );

end

function plot_lookdur(pltdat, pltlabs, params)

do_save = params.do_save;
prefix = '';

is_per_reward_type = true;
is_per_bin = false;
is_per_monkey = false;
is_per_selected_cue = true;
is_choice_only = false;

pl = plotlabeled.make_common();
pl.x_tick_rotation = 0;

mask = fcat.mask( pltlabs ...
  , @find, 'no_errors' ...
  , @findnone, {'saline', 'oxytocin'} ...
  , @findnone, 'kubrick' ...
  , @find, {'looks-to-cue'} ...
);

if ( is_choice_only )
  mask = find( pltlabs, 'choice', mask );
end

bin_category = 'binned_trials';
jja.util.split_trials_each( pltlabs, 'identifier', bin_category, 2, mask );

xcats = { 'task_type' };
gcats = { 'selected_cue' };
pcats = { 'monkey' };

pltdat = pltdat(mask);
keep( pltlabs, mask );

if ( ~is_per_monkey ),        collapsecat( pltlabs, 'monkey' ); end
if ( ~is_per_reward_type ),   collapsecat( pltlabs, 'reward_type' ); end
if ( ~is_per_selected_cue ),  collapsecat( pltlabs, 'selected_cue' ); end
if ( is_per_bin ),            pcats{end+1} = bin_category; end

axs = pl.bar( pltdat, pltlabs, xcats, gcats, pcats );

if ( do_save )
  dsp3.req_savefig( gcf, params.plot_p, pltlabs, pcats, prefix );
end

anova_outs = dsp3.anovan( pltdat, pltlabs, {}, {'task_type', 'selected_cue'} ...
  , 'mask', find(~isnan(pltdat)) ...
  , 'include_per_factor_descriptives', true ...
);

if ( do_save )
  dsp3.save_anova_outputs( anova_outs, params.analysis_p, csunion(pcats, gcats) );
end

end