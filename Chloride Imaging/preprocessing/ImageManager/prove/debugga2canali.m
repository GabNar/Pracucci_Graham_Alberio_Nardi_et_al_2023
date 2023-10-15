%ig.Xcorr  

tmp = squeeze(ig.workImages(:,:,:,ig.Xcorr.currentFrame));

realMat = ig.workImages(:,:,1,:);
myMat = ig.workImages(:,:,1,:).*(3/4);
newMat = cat(3,realMat,myMat);

pointers = [];
% pointers.data = libpointer('MATLAB array',single(newMat));
pointers.data = libpointer('MATLAB array',newMat);
pointers.x = libpointer('MATLAB array',ig.timeI);

% just try for debugging the ROI manager
pointers.stimuli = libpointer('MATLAB array',((1:28:size(ig.workImages,4))-1 ) * ig.metadata.meanSP);

cla(ig.Xcorr.distW)
imagesc(ig.Xcorr.distW,tmp);
axis(ig.Xcorr.distW, [1, size(tmp,2), 1, size(tmp,1)])
ig.Xcorr.distW.UserData = pointers;

% ig.Xcorr.sourceMap.UserData = rmfield(ig.Xcorr.sourceMap.UserData,'stimuli');