function result = make_labels(varargin)

defaults = jja.get_common_make_defaults();

inputs = 'unified';
output = 'labels';

[params, loop_runner] = jja.get_params_and_loop_runner( inputs, output, defaults, varargin );
loop_runner.func_name = mfilename;

result = loop_runner.run( @make_labels_main, params );

end

function labels_file = make_labels_main(files, params)

unified_file = shared_utils.general.get( files, 'unified' );

trial_data = unified_file.trial_data;

n_trials = numel( trial_data );

labs = fcat();
tmp_labs = fcat();

for i = 1:n_trials
  dat = trial_data(i);
  
  selected_cue_name = dat.selected_cue;
  reward_cue_name = dat.shown_reward_cue;
  social_image_name = jja.field_or( dat, 'shown_social_image', '' );
  random_location = dat.random_location;
  info_location = dat.info_location;
  
  if ( isempty(selected_cue_name) ), selected_cue_name = 'none'; end
  if ( isempty(reward_cue_name) ), reward_cue_name = 'none'; end
  if ( isempty(social_image_name) ), social_image_name = 'none'; end
  if ( isempty(info_location) ), info_location = 'none'; end
  if ( isempty(random_location) ), random_location = 'none'; end
  
  info_location = get_direction_label( info_location );
  random_location = get_direction_label( random_location );
  
  addsetcat( tmp_labs, 'block', sprintf('block_%d', dat.block_number) );
  addsetcat( tmp_labs, 'trial_type', dat.trial_type );
  addsetcat( tmp_labs, 'selected_cue', sprintf('selected_%s', selected_cue_name) );
  addsetcat( tmp_labs, 'reward_cue', sprintf('reward_cue_%s', reward_cue_name) );
  addsetcat( tmp_labs, 'social_image', sprintf('social_image_%s', social_image_name) );
  addsetcat( tmp_labs, 'reward_type', dat.reward_type ); 
  addsetcat( tmp_labs, 'error', get_error_label(dat) );
  
  addsetcat( tmp_labs, 'info_location', sprintf('info_location_%s', info_location) );
  addsetcat( tmp_labs, 'random_location', sprintf('random_location_%s', random_location) );
  
  append( labs, tmp_labs );
end

meta = unified_file.meta;

fs = fieldnames( meta );

for i = 1:numel(fs)
  field = fs{i};
  
  val = meta.(field);
  
  if ( isempty(val) )
    val = sprintf( '%s_none', field );
  end
  
  addsetcat( labs, field, val );
end

addsetcat( labs, 'identifier', unified_file.identifier );

labels_file = struct();
labels_file.identifier = unified_file.identifier;
labels_file.params = params;
labels_file.labels = categorical( labs );
labels_file.categories = getcats( labs );

end

function dir = get_direction_label(direction)

switch ( direction )
  case 'center-left'
    dir = 'left';
  case 'center-right'
    dir = 'right';
  case 'center'
    dir = 'center';
  otherwise
    dir = direction;
end

end

function err = get_error_label(current)

if ( current.errors.broke_choice )
  err = 'broke_choice';
elseif ( current.errors.no_choice )
  err = 'no_choice';
elseif ( current.errors.broke_fixation )
  err = 'broke_fix';
elseif ( current.errors.no_fixation )
  err = 'no_fix';
elseif ( isfield(current.errors, 'chose_too_late') && current.errors.chose_too_late )
  err = 'chose_late';
else
  assert( sum(structfun(@(x) x, current.errors)) == 0 ...
    , 'Some error types were unaccounted for.' );
  err = 'no_errors';
end

end