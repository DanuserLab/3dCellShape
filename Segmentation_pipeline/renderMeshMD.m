function [meshHandle, figHandle] = renderMeshMD(processOrMovieData, varargin)
% renderMeshMD - wraps plotMeshMD (via RenderMeshProcess) to create custom renderings via a GUI and export to other formats (e.g., .dae)
% Specifically,  plotMeshMDWrapper will check if a .fig has already been created for the desired rendering. 
% Minimally requires that Mesh3DProcess has successfully run. ()
% also see: RenderMeshProcess.m, plotMeshMD.m, Morphology3DPackage.m
% Andrew R. Jamieson, July 2018
%


%Check input
ip = inputParser;
ip.CaseSensitive = false;
ip.addRequired('movieData', @(x) isa(x,'Process') && isa(x.getOwner(),'MovieData') || isa(x,'MovieData'));
ip.addOptional('paramsIn',[], @isstruct);
ip.addParameter('ProcessIndex',[],@isnumeric);
ip.parse(processOrMovieData,varargin{:});
paramsIn = ip.Results.paramsIn;

[MD, process] = getOwnerAndProcess(processOrMovieData,'RenderMeshProcess',true);
p = parseProcessParams(process, paramsIn);

process.setOutFilePaths({p.OutputDirectory});

[meshHandle, figHandle] = plotMeshMD(MD, 'chan', p.ChannelIndex, p);

figure(figHandle);
title(p.surfaceMode); figHandle.Name = ['Custom Rendering: < ' p.surfaceMode ' > created '  datestr(now, 'dd-mmm-yyyy HH:MM')];
