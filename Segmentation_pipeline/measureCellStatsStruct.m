function cellStats = measureCellStatsStruct(mesh, areas, blebStats)

% measureCellStats - calculates cell-scale statistics for a cell

% update the bleb count 
cellStats.blebCount = blebStats.count;

% find the cell surface area
cellStats.cellSurfaceArea = sum(areas);

% find the cell volume
cellStats.cellVolume = measureMeshVolume(mesh);
