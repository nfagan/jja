function result = make_edfs(varargin)

defaults = jja.get_common_make_defaults();

params = jja.parsestruct( defaults, varargin );

conf = params.config;

loop_runner = jja.get_looped_make_runner( params );

loop_runner.input_directories =   fullfile( jja.dataroot(conf), 'raw', 'edf' );
loop_runner.output_directory =    jja.gid( 'edf', conf );
loop_runner.load_func =           @Edf2Mat;
loop_runner.get_identifier_func = @get_edf_identifier;
loop_runner.find_files_func =     @(x) shared_utils.io.find( x, '.edf' );
loop_runner.func_name =           mfilename;

result = loop_runner.run( @make_samples_main, params );

end

function edf_file = make_samples_main(files, params)

edf_obj = files.edf;

id = get_edf_identifier( edf_obj, edf_obj.filename );

samps = edf_obj.Samples;
evts = edf_obj.Events;

x = samps.posX;
y = samps.posY;
t = samps.time;
ps = samps.pupilSize;

info = evts.Messages.info;
evt_ts = evts.Messages.time;

is_sync_msg = cellfun( @(x) ~isempty(strfind(x, 'TRIAL_')), info );
sync_times = evt_ts(is_sync_msg);
sync_msgs = info(is_sync_msg);

edf_file = struct();
edf_file.identifier = id;
edf_file.params = params;
edf_file.x = x;
edf_file.y = y;
edf_file.t = t;
edf_file.pupil = ps;
edf_file.sync_times = sync_times;
edf_file.sync_messages = sync_msgs;
edf_file.sync_trial_numbers = get_sync_trial_numbers( sync_msgs );

end

function ts = get_sync_trial_numbers(sync_msgs)

ts = nan( size(sync_msgs) );
n = numel( 'TRIAL__' ) + 1;

for i = 1:numel(sync_msgs)
  tn = str2double( sync_msgs{i}(n:end) );
  
  assert( ~isnan(tn), 'Trial number failed to parse.' );
  
  ts(i) = tn;
end

end

function id = get_edf_identifier(edf_obj, filename)
id = sprintf( '%s.mat', shared_utils.io.filenames(filename) );
end