%%

look_out = jja_get_social_image_looking_duration();

plot_p = fullfile( jja.dataroot, 'plots', datestr(now, 'mmddyy') );

%%

looklabs = look_out.labels';
lookdur = look_out.looking_duration;

assert_ispair( lookdur, looklabs );

jja.add_drug_labels( looklabs );

%%  ot vs sal lookdur

do_save = true;
prefix = 'lookdur_block_average_drug';

pl = plotlabeled.make_common();

pltlabs = looklabs';
pltdat = lookdur;

xcats = { 'monkey' };
gcats = { 'drug' };
pcats = { 'trial_type', 'selected_cue'  };

mask = fcat.mask( pltlabs ...
  , @find, 'no_errors' ...
  , @find, 'social' ...
  , @find, 'tarantino' ...
  , @find, {'saline', 'oxytocin'} ...
  , @find, 'choice' ...
);

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

do_save = true;
prefix = 'lookdur_trial_average_non_drug';

pl = plotlabeled.make_common();

pltlabs = looklabs';
pltdat = lookdur;

is_per_trial = false;

xcats = { 'monkey' };
gcats = { 'selected_cue' };
pcats = { 'trial_type' };

mask = fcat.mask( pltlabs ...
  , @find, 'no_errors' ...
  , @find, 'social' ...
  , @findnone, {'saline', 'oxytocin'} ...
  , @find, 'choice' ...
);

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



