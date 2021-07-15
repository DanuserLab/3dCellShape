function C = fastSetDiff(A,B)

% fastSetDiff - A faster version of Matlab's builtin setdiff that only works on positive integers
% (from http://www.mathworks.com/matlabcentral/answers/53796-speed-up-intersect-setdiff-functions)

check = false(1, max(max(A), max(B)));
check(A) = true;
check(B) = false;
C = A(check(A));