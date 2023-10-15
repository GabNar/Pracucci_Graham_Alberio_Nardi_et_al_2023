% If this function is called following to the
% interactive deletion of a ROI by the user, then
% ev is the event related to this action. In this case,
% the ROI will be deleted automatically.
%
% If ev is the 'buttonPressed' event from deleteRoiButton, the
% target roi is one of the rois selected in roiListBox. The roi
% has to be actively deleted.
%
% If ev is the 'buttonPressed' event from Discard button, the
% target roi is app.newROI. If ev is empty instead, it means 
% that this function has been called during the drawROI function,
% because a new ROI is going to be drawn. In both cases, the
% target ROI is app.newROI and it has to be actively deleted,
% UNLESS it has been stored. So, check first if the roi belongs
% to app.storedROI.

% Before starting, if ev is empty create a field called Source,
% because we are going to query the event source later.
if isempty(ev)
    ev.Source = [];
end
% also, state that the roi will be actively deleted.
activelyDelete = true;

% First, check if the source is one of the stored ROIs.
idx = arrayfun(@(x) isequal(x,src),app.storedROI);
if sum(idx)
    % if it's so, and if the triggering event is the
    % 'DeletingROI' listener or the pressing of the 'deleteROI
    % button', then clear the roi handle from app.storedROI and
    % its entry in the roiListBox
    if isequal(ev.Source,app.deleteRoiButton) || isequal(ev.Source,src)
        app.storedROI(idx) = [];
        app.roiListBox.Items(idx) = [];
    else
        % otherwise, you just want to delete the 'newROI', but
        % it has been stored already! So, don't delete it at all!
        activelyDelete = false;
    end    
elseif ~isempty(app.newROI)
    % check if the ROI to be deleted is the newRoi, if it exists
    if isequal(src,app.newROI)
        app.newROI = [];
        cla(app.zProfileAxes)
        app.StoreButton.Enable = 'off';
        app.DiscardButton.Enable = 'off';
    end
end

% Finally, if this function is not called by a listener 
% to the 'DeletingROI' event, actively delete the ROI.
if (~isequal(ev.Source,src)) && activelyDelete
    if isvalid(src) % better safe than sorry
        src.delete();
    end
end