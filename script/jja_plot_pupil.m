%%

pup_out = jja_get_mean_pupil( ...
    'event', 'display_random_vs_info_cues' ...
  , 'look_back', -300 ...
  , 'look_ahead', 0 ...
);

plot_p = fullfile( jja.dataroot, 'plots', datestr(now, 'mmddyy') );

%%
puplabs = pup_out.labels';
pupil = pup_out.pupil;
t = pup_out.t;

assert_ispair( pupil, puplabs );

jja.add_drug_labels( puplabs );

%%  ot vs sal pupil

do_save = true;
prefix = 'pupil_collapsed_task_types';

pl = plotlabeled.make_common();
pl.y_lims = [3500, 4000];

pltlabs = puplabs';
pltdat = nanmean( pupil, 2 );

xcats = {};
gcats = { 'drug' };
pcats = { 'monkey'  };

mask = fcat.mask( pltlabs ...
  , @find, 'tarantino' ...
  , @find, {'saline', 'oxytocin'} ...
);

spec = { 'block', 'identifier', 'task_type', 'drug' };

[pltlabs, I] = keepeach( pltlabs', spec, mask );
pltdat = rownanmean( pltdat, I );

pl.bar( pltdat, pltlabs, xcats, gcats, pcats );

if ( do_save )
  dsp3.req_savefig( gcf, plot_p, pltlabs, pcats, prefix );
end
