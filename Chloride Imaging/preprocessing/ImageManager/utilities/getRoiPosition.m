function outStruct = getRoiPosition(myroi)
% GETROIPOSITION Returns roi object properties that are useful to re-draw it programmatically.
% 
% OUTSTRUCT = GETROIPOSITION(MYROI)
%   INPUT
%       MYROI: any ROI object
%
%   OUTPUT
%       OUTSTRUCT: structure whose fields depend on MYROI class. outStruct
%           fields are called like the properties of MYROI that are useful for
%           drowing a roi of its class programmatically, and their values are
%           taken from MYROI.
%
% GAB, 2020/05/17

    switch class(myroi)
        case 'images.roi.Rectangle'
            outStruct.Position = myroi.Position;
            outStruct.RotationAngle = myroi.RotationAngle;
        case 'images.roi.Ellipse'
            outStruct.Center = myroi.Center;
            outStruct.RotationAngle = myroi.RotationAngle;
            outStruct.SemiAxes = myroi.SemiAxes;
        case 'images.roi.Polygon'
            outStruct.Position = myroi.Position;
        case 'images.roi.Freehand'
            outStruct.Closed = myroi.Closed;
            outStruct.Position = myroi.Position;
        case 'images.roi.Polyline'
            outStruct.Position = myroi.Position;
        case 'images.roi.Circle'
            outStruct.Center = myroi.Center;
            outStruct.Radius = myroi.Radius;
        case 'images.roi.Line'
            outStruct.Position = myroi.Position;
        case 'images.roi.Point'
            outStruct.Position = myroi.Position;
        case 'images.roi.Cuboid'
            outStruct.Vertices = myroi.Vertices;
            outStruct.RotationAngle = myroi.RotationAngle;
        case 'images.roi.Crosshair'
            outStruct.Position = myroi.Position;
    end
end