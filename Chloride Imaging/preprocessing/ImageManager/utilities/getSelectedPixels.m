function selectedPxl = getSelectedPixels(myImage,ROI)
    dim = size(myImage.CData);
    xPoints = linspace(myImage.XData(1),myImage.XData(end),dim(2));
    yPoints = linspace(myImage.YData(1),myImage.YData(end),dim(1));
    
    % [coordY;coordX]' stores the coordinates of all the matrix entries, in
    % column order
    coordY = repmat(yPoints,1,length(xPoints));
    coordX = reshape(repmat(xPoints,length(yPoints),1),length(xPoints)*length(yPoints),1)';
    selectedPxl = inROI(ROI,coordX,coordY); % linear logical indexing of the selected pxls in one frame
end