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

if ( ~isfield(unified_file.stimuli, 'social_image') )
  rects('image') = nan( 1, 4 );
else
  rects('image') = unified_file.stimuli.social_image.vertices;
end

roi_file.rects = rects;

end