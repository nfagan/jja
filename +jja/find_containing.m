function fs = find_containing(p, ext, containing)

%   FIND_CONTAINING -- Find files containing string(s).
%
%     IN:
%       - `p` (cell array of strings, char)
%       - `ext` (char)
%       - `containing` (cell array of strings, char)
%     OUT:
%       - `fs` (cell array of strings)

if ( nargin < 3 )
  containing = [];
end

fs = shared_utils.io.find( p, ext );

if ( ~isempty(containing) )
  fs = shared_utils.cell.containing( fs, containing );
end

end