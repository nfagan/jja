
function conf = create(do_save)

%   CREATE -- Create the config file. 
%
%     Define editable properties of the config file here.
%
%     IN:
%       - `do_save` (logical) -- Indicate whether to save the created
%         config file. Default is `false`

if ( nargin < 1 ), do_save = false; end

const = jja.config.constants();

conf = struct();

% ID
conf.(const.config_id) = true;

% PATHS
PATHS = struct();
PATHS.data_root = '';
PATHS.repositories = fileparts( jja.util.get_project_folder() );

% DEPENDENCIES
DEPENDS = struct();
DEPENDS.repositories = { 'bfw' };

conf.PATHS = PATHS;
conf.DEPENDS = DEPENDS;

if ( do_save )
  jja.config.save( conf );
end

end