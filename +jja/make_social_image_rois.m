function result = make_social_image_rois(varargin)

defaults = jja.get_common_make_defaults();

inputs = 'unified';
output = 'rois';

[params, loop_runner] = jja.get_params_and_loop_runner( inputs, output, defaults, varargin );
loop_runner.func_name = mfilename;

result = loop_runner.run( @make_roi_main, params );

end

function roi_file = make_roi_main(files, params)

unified_file = shared_utils.general.get( files, 'unified' );

roi_file = struct();
roi_file.identifier = unified_file.identifier;
roi_file.params = params;

rects = containers.Map();

stimuli = unified_file.stimuli;
screen_rect = unified_file.screen_rect;

if ( ~isfield(stimuli, 'social_image') )
  rects('image') = nan( 1, 4 );
else
  rects('image') = stimuli.social_image.vertices;
end

[left_cue_roi, right_cue_roi] = get_cue_rois( screen_rect, stimuli );

rects('left-cue') = left_cue_roi;
rects('right-cue') = right_cue_roi;

roi_file.rects = rects;

end

function [left, right] = get_cue_rois(screen_rect, stimuli)

left = nan( 1, 4 );
right = nan( 1, 4 );

if ( ~isfield(stimuli, 'info_cue') )
  return
else
  info_rect = stimuli.info_cue.vertices;
end

if ( ~isfield(stimuli, 'random_cue') )
  return
else
  rand_rect = stimuli.random_cue.vertices;
end

info_width = info_rect(3) - info_rect(1);
info_height = info_rect(4) - info_rect(2);
rand_width = rand_rect(3) - rand_rect(1);
rand_height = rand_rect(4) - rand_rect(2);

screen_width = screen_rect(3) - screen_rect(1);
screen_height = screen_rect(4) - screen_rect(2);

assert( info_width == rand_width && info_height == rand_height ...
  , 'info and random sizes are different.' );

stim_width = info_width;
stim_height = info_height;

screen_center_y = screen_height/2 + screen_rect(2);

screen_left_center_x = screen_width/4 + screen_rect(1);
screen_right_center_x = (screen_width * 3)/4 + screen_rect(1);

left_min_x = screen_left_center_x - stim_width/2;
left_max_x = screen_left_center_x + stim_width/2;
left_min_y = screen_center_y - stim_height/2;
left_max_y = screen_center_y + stim_height/2;

right_min_x = screen_right_center_x - stim_width/2;
right_max_x = screen_right_center_x + stim_width/2;
right_min_y = screen_center_y - stim_height/2;
right_max_y = screen_center_y + stim_height/2;

left = [ left_min_x, left_min_y, left_max_x, left_max_y ];
right = [ right_min_x, right_min_y, right_max_x, right_max_y ];

info_eq = isequaln(info_rect, left) || isequaln(info_rect, right);
rand_eq = isequaln(rand_rect, left) || isequaln(rand_rect, right);

assert( info_eq || rand_eq, 'Some rects did not match!' );

end