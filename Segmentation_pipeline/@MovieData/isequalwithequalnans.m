function [ varargout ] = isequalwithequalnans( varargin )
%isequaln Same as isequal

[varargout{1:nargout}] = isequal(varargin{:});


end

