%   @desc This script is used as an unitary test for the function findLineIntersection,
%   which computes the intersection point between two lines defined by its start and end
%   points.
%
%%--------------------------------------------------------------------------------------------------
%   @ref https://es.mathworks.com/help/matlab/script-based-unit-tests.html
%
%%--------------------------------------------------------------------------------------------------
%   @author Andres Ferreiro Gonzalez (@aferreiro)
%   @company Galician Research and Development Center in Advanced Telecommunications (GRADIANT)
%   @date 24/03/17
%   @version 1.0
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------

% Test Lines

start1 = [2 1];
end1 = [7 6];

start2 = [5 1];
end2 = [5 6];

start3 = [7 1];
end3 = [7 6];


intx = [5 7];
inty = [4 6];

% preconditions

assert(not(start1(1) == end1(1) && start1(2) == end1(2)), 'Error in test deffinition, line 1 is just a point')
assert(not(start2(1) == end2(1) && start2(2) == end2(2)), 'Error in test deffinition, line 2 is just a point')
assert(not(start3(1) == end3(1) && start3(2) == end3(2)), 'Error in test deffinition, line1 is just a point')
assert(not(start1(1) == start2(1) && start1(2) == start2(2) && end1(1) == end2(1) ...
    && end1(2) == end2(2)), 'Error in test deffinition, line 1 and line 2 are the same')

assert(not(start3(1) == start2(1) && start3(2) == start2(2) && end3(1) == end2(1) ...
    && end3(2) == end2(2)), 'Error in test deffinition, line 2 and line 3 are the same')

assert(not(start1(1) == start3(1) && start1(2) == start3(2) && end1(1) == end3(1) ...
    && end1(2) == end3(2)), 'Error in test deffinition, line 1 and line 3 are the same') 


%% Test 1: Line One and Line Two

[ intersx, intersy ] = findLineIntersection( start1, end1, start2, end2 );

assert(intersx == intx(1) && intersy == inty(1), 'Intersection between lines is not correct')

%% Test 2: Line Two and Line Three

[ intersx, intersy ] = findLineIntersection( start2, end2, start3, end3 );

assert(isnan(intersx) && isnan(intersy), 'Intersection between lines is not correct')


%% Test 3: Line One and Line Three

[ intersx, intersy ] = findLineIntersection( start1, end1, start3, end3 );

assert(intersx == intx(2) && intersy == inty(2), 'Intersection between lines is not correct')
