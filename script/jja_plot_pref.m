runner = jja.get_looped_make_runner();
runner.convert_to_non_saving_with_output();

runner.input_directories = jja.gid( 'labels' );

results = runner.run( @(x) fcat.from(x('labels')) );
results(~[results.success]) = [];

orig_labs = vertcat( fcat, results.output );

%%  identify correction trials

cont = Container( rowzeros(rows(orig_labs)), SparseLabels.from_fcat(orig_labs) );
cont = jj_analysis.process.identify_correction_trials( cont );

labs = fcat.from( cont.labels );
jja.add_drug_labels( labs );

%%  get preference

pref_each = { 'date', 'identifier' };

% only choice trials, non-correction trials
mask = find( labs, {'correction__false', 'choice'} );

[preflabs, I] = keepeach( labs', pref_each, mask );
prefdat = rownan( numel(I) * 2 );

for i = 1:numel(I)
  n_rand = numel( find(labs, 'selected_random', I{i}) );
  n_info = numel( find(labs, 'selected_info', I{i}) );
  
  pref_info = n_info ./ ( n_info + n_rand );
  pref_rand = 1 - pref_info;
  
  prefdat(i) = pref_info;
  prefdat(numel(I) + i) = pref_rand;
end

repset( preflabs, 'selected_cue', {'selected_info', 'selected_random'} );

assert_ispair( prefdat, preflabs );

%%  bar preference

pltlabs = preflabs';
pltdat = prefdat;

pl = plotlabeled.make_common();

mask = fcat.mask( pltlabs ...
  , @find, {'juice', 'tarantino'} ...
  , @findnone, {'saline', 'oxytocin'} ...
);

xcats = { 'selected_cue' };
gcats = {};
pcats = { 'monkey' };

pl.bar( pltdat(mask), pltlabs(mask), xcats, gcats, pcats );
