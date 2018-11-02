function result = make_events(varargin)

defaults = jja.get_common_make_defaults();

inputs = 'unified';
output = 'events';

[params, loop_runner] = jja.get_params_and_loop_runner( inputs, output, defaults, varargin );
loop_runner.func_name = mfilename;

result = loop_runner.run( @make_events_main, params );

end

function events_file = make_events_main(files, params)

unified_file = files.unified;

event_key = { 'trial_start', 'fixation', 'display_random_vs_info_cues' ...
  , 'look_to_random_vs_info', 'choose_random_vs_info', 'display_info_cues' ...
  , 'display_social_image', 'reward' };

trial_data = unified_file.trial_data;

n_trials = numel( trial_data );
n_events = numel( event_key );

events_mat = nan( n_trials, n_events );

for i = 1:n_trials
  
  evts = trial_data(i).events;
  
  for j = 1:n_events
    evt_name = event_key{j};
    
    if ( isfield(evts, evt_name) )
      events_mat(i, j) = evts.(evt_name);
    end
  end
end

c = containers.Map();

for i = 1:numel(event_key)
  c(event_key{i}) = i;
end

events_file = struct();
events_file.identifier = unified_file.identifier;
events_file.params = params;
events_file.events = events_mat;
events_file.event_key = c;

end