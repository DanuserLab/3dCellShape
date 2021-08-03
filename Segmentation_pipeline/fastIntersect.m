function C = fastIntersect(A,B)

% fastIntersect - A faster version of Matlab's builtin intersect that only works on positive integers
% (from http://www.mathworks.com/matlabcentral/answers/53796-speed-up-intersect-setdiff-functions)

P = zeros(1, max(max(A),max(B)) ) ;
P(A) = 1;
C = B(logical(P(B)));