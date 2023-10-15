function [s,ax]=mySliceViewer(fig,mat)

figure(fig);
s=sliceViewer(mat);
pan=fig.Children;
isaxes=strcmp(arrayfun(@class,pan.Children,'UniformOutput',false),...
    'matlab.graphics.axis.Axes');
ax=pan.Children(isaxes);
% ax.Visible=true;