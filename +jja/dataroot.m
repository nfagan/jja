function p = dataroot(conf)

%   DATAROOT -- Get the root data folder.
%
%     p = ... dataroot() returns the full path to the root data folder, as
%     defined in the saved config file.
%
%     p = ... dataroot( conf ) uses the config file `conf` instead of the
%     saved config file.
%
%     IN:
%       - `conf` (config file) |OPTIONAL|
%     OUT:
%       - `p` (char)

if ( nargin < 1 || isempty(conf) )
  conf = jja.config.load();
else
  jja.util.assertions.assert__is_config( conf );
end

paths = jja.field_or( conf, 'PATHS', struct() );
p = jja.field_or( paths, 'data_root', '' );

end