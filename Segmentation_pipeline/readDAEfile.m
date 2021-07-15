function [surface, normals] = readDAEfile(filePath)

% readDAEfile - read a DAE file and convert it into a mesh

% read the file into a string
daeText = fileread(filePath);

% find the vertices
[~, firstDigit] = regexp(daeText, '<float_array id="shape0-lib-positions-array" count="\d*">\d');
[~,lastDigit] = regexp(daeText, '<float_array id="shape0-lib-positions-array" count="\d*">[-e.\d\s]*');
vertices = str2num(daeText(firstDigit:lastDigit));
vertices = reshape(vertices, 3, []);
surface.vertices = vertices';

% find the vertices
[~, firstDigit] = regexp(daeText, '<float_array id="shape0-lib-normals-array" count="\d*">[-\d]');
[~,lastDigit] = regexp(daeText, '<float_array id="shape0-lib-normals-array" count="\d*">[-e.\d\s]*');
normals = str2num(daeText(firstDigit:lastDigit));
normals = reshape(normals, 3, []);
normals = normals';

% find the faces
[~, firstDigit] = regexp(daeText, '<p>\d');
[~,lastDigit] = regexp(daeText, '<p>[\d\s]*');
faces = str2num(daeText(firstDigit:lastDigit)) + 1;
faces = reshape(faces, 2, []);
faces = reshape(faces(1,:), 3, []);
surface.faces = faces';
% 
% % debugging plot
% figure
% patch('Faces',surface.faces, 'Vertices',surface.vertices, 'FaceColor','red', 'EdgeColor','none')
% daspect([1,1,1])
% axis tight
% camlight
% camlight(-80,-10)
% lighting gouraud