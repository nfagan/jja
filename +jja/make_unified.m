function make_unified(varargin)

defaults = jja.get_common_make_defaults();

params = jja.parsestruct( defaults, varargin );

conf = params.config;

dr = jja.dataroot( conf );
mat_p = fullfile( dr, 'raw', 'mat' );
unified_p = jja.gid( 'unified', conf );

mats = jja.find_containing( mat_p, '.mat', params.files_containing );
identifiers = shared_utils.io.filenames( mats );

parfor i = 1:numel(mats)
  shared_utils.general.progress( i, numel(mats), mfilename );
  
  id = sprintf( '%s.mat', identifiers{i} );
  
  output_filename = fullfile( unified_p, id );
  
  if ( jja.conditional_skip_file(output_filename, params.overwrite) )
    continue;
  end
  
  try
    unified_file = make_unified_main( mats{i}, id, params );
    
    if ( params.save )
      shared_utils.io.require_dir( unified_p );
      shared_utils.io.psave( output_filename, unified_file, 'unified_file' );
    end
  catch err
    jja.print_fail_warn( id, err.message );
    continue;
  end
end

end

function unified_file = make_unified_main(mat_filename, id, params)

raw_file = shared_utils.io.fload( mat_filename );

unified_file = struct();
unified_file.identifier = id;
unified_file.params = params;
unified_file.meta = get_meta( raw_file, id );
unified_file.trial_data = raw_file.DATA;
unified_file.screen_rect = get_screen_rect( raw_file );
unified_file.stimuli = get_stimuli( raw_file );

end

function screen_rect = get_screen_rect(raw_file)

if ( ~isfield(raw_file, 'opts') )
  screen_rect = [0 0 1600 900];
else
  screen_rect = raw_file.opts.WINDOW.rect;
end

end

function s = get_stimuli(raw_file)

if ( ~isfield(raw_file, 'opts') || ~isfield(raw_file.opts, 'STIMULI') )
  s = struct();
  return;
end

stim_names = fieldnames( raw_file.opts.STIMULI );

s = struct();

for i = 1:numel(stim_names)
  stim_name = stim_names{i};
  
  stim = raw_file.opts.STIMULI.(stim_name);
  
  if ( isempty(stim) || isstruct(stim) )
    continue;
  end
  
  reformatted = struct();
  reformatted.vertices = stim.vertices;
  reformatted.color = stim.color;
  
  s.(stim_name) = reformatted;
end

end

function meta = get_meta(raw_file, id)

check_fields = { 'monkey', 'date', 'session', 'notes' };

meta = struct();

for i = 1:numel(check_fields)
  field = check_fields{i};
  
  if ( isfield(raw_file, 'META') )
    meta.(field) = jja.field_or( raw_file.META, field, '' );
  end
end

if ( ~isfield(raw_file, 'opts') || ~isfield(raw_file.opts.STRUCTURE, 'IS_JUICE') )
  task_type = 'juice';
elseif ( raw_file.opts.STRUCTURE.IS_JUICE )
  task_type = 'juice';
else
  task_type = 'social';
end

meta.task_type = task_type;
meta.monkey = identify_monkey( id );
meta.day = get_day( id );
meta.date = get_date( meta.day );
meta.session = sprintf( 'session_%s', meta.session );

end

function d = get_date(day)

d = datestr( datenum(day, 'mmdd') );

end

function d = get_day(identifier)

d = identifier([1, 2, 4, 5]);

end

function m = identify_monkey(identifier)

is_tarantino = ~isempty( strfind(identifier, 'Ta') );
is_kubrick = ~isempty( strfind(identifier, 'Ku') );
is_ephron = ~isempty( strfind(identifier, 'Ep') );

n_found = is_tarantino + is_kubrick + is_ephron;

assert( n_found == 1, 'More or fewer than one match for: "%s".', identifier );

if ( is_tarantino )
  m = 'tarantino';
elseif ( is_kubrick )
  m = 'kubrick';
elseif ( is_ephron )
  m = 'ephron';
else
  error( 'Unhandled case.' );
end

end