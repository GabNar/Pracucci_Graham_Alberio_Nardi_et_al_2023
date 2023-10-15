figure
ax = axes;
ima = imagesc(NaN);
% r = NaN(1,3);
r    = drawrectangle(ax);
% r(2) = drawrectangle(ax);
% r(3) = drawrectangle(ax);
% 
% addlistener(r(1),'DeletingROI',@(src,ev) roiDeleting(r,src,ev));
% addlistener(r(2),'DeletingROI',@(src,ev) roiDeleting(r,src,ev));
% addlistener(r(3),'DeletingROI',@(src,ev) roiDeleting(r,src,ev));

listenerArray = event.listener.empty(1,0);

myListn = addlistener(r,'MovingROI',@(src,ev) (disp('moving')));
listenerArray(2) = myListn;




