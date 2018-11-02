function defaults = get_common_make_defaults(defaults)

if ( nargin < 1 ), defaults = struct(); end

defaults.files_containing = [];
defaults.overwrite = false;
defaults.append = true;
defaults.is_parallel = true;
defaults.save = true;
defaults.log_level = 'info';
defaults.config = jja.config.load();

end