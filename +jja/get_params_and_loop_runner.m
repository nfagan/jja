function [params, loop_runner] = get_params_and_loop_runner(inputs, output, defaults, args)

%   GET_PARAMS_AND_LOOP_RUNNER -- Parse main-function inputs and obtain
%     parameters and loop runner.
%
%     IN:
%       - `inputs` (cell array of strings, char)
%       - `output` (char)
%       - `defaults` (struct)
%       - `args` (cell)
%     OUT:
%       - `params` (struct)
%       - `loop_runner` (shared_utils.pipeline.LoopedMakeRunner)

params = jja.parsestruct( defaults, args );

conf = params.config;

loop_runner = jja.get_looped_make_runner( params );

loop_runner.input_directories = jja.gid( inputs, conf );
loop_runner.output_directory = jja.gid( output, conf );

end