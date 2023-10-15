function [registered,deltas] = myregistration(stack,template)
% rigid registration (only translation) with cross correlation


% average projection
[ny,nx,nframes] = size(stack);
gamma = 0.5;

% start plotting the unregistered image
figure('position',[528   291   895   371]);
subplot(1,2,1)
q_templ = quantile(template,0.25,'all');
stack_proj = mean(stack,3,'omitnan');
q_stack = quantile(stack_proj,0.25,'all');
imagesc(cat(3,rescale(template,'InputMin',q_templ).^gamma,rescale(stack_proj,"InputMin",q_stack).^gamma,rescale(template,'InputMin',q_templ)).^gamma)
set(gca,'plotboxaspectratio',[1 1 1])
title('differece with template before registr')

drawnow
% interactively draw a ROI to select a sub-image
r = drawrectangle(gca);
disp('ROI drawn')
x = ceil(r.Vertices(1,1)) : floor(r.Vertices(3,1));
y = ceil(r.Vertices(1,2)) : floor(r.Vertices(2,2));
delete(r)
% substack = movmean(stack(y,x,:),3,3);
substack = stack(y,x,:);
subtempl = template(y,x);
patch(gca,[x(1) x(end) x(end) x(1)],[y(1) y(1) y(end) y(end)],'r','facealpha',0,'edgecolor','r','linewidth',2)
drawnow

registered = nan(size(stack));

deltas=nan(2,nframes);
disp('Registration starting...')
for i = 1:nframes
    if rem(i,100)==1 || i==1
        fprintf('Processing frame %i of %i\n',i,nframes)
    end
    
    % compute correlation
    slice = squeeze(substack(:,:,i));
    c = xcorr2(subtempl-mean(subtempl,'all'),slice-mean(slice,'all'));
    ylag = -length(y):length(y);
    xlag = -length(x):length(x);
%         figure
%         imagesc(xlag,ylag,c)
%         colormap(turbo)
%         colorbar
%         hold on
%         plot(xlim,[0 0],'r')
%         plot([0 0],ylim,'r')
    [~,m] = max(c,[],'all','linear');
    [iy,ix]=ind2sub(size(c),m);
    deltas(1,i) = ylag(iy);
    deltas(2,i) = xlag(ix);
    
    % start registering the stack
    %first, crop it
    tmp = squeeze(stack( max(1,1-deltas(1,i)):min(ny,ny-deltas(1,i)), max(1,1-deltas(2,i)):min(nx,nx-deltas(2,i)),i));
    % pad the cropped images with nans to restore the original size
    % first the x dimension
    
    xpad_before=nan(size(tmp,1),max(0,+deltas(2,i)));
    xpad_after=nan(size(tmp,1),max(0,-deltas(2,i)));
    tmp =   cat(2,xpad_before, tmp, xpad_after);
    % then the y dimension
    ypad_before=nan(max(0,+deltas(1,i)),size(tmp,2));
    ypad_after=nan(max(0,-deltas(1,i)),size(tmp,2));
    registered(:,:,i) = cat(1,ypad_before, tmp, ypad_after);
end



% plot the result
subplot(1,2,2)
stack_proj = mean(registered,3);
q_registered = quantile(stack_proj,0.25,'all');
imagesc(cat(3,rescale(template,'InputMin',q_templ).^gamma,rescale(stack_proj,"InputMin",q_registered).^gamma,rescale(template,'InputMin',q_templ)).^gamma)
title('differece with template after registr')
set(gca,'plotboxaspectratio',[1 1 1])
end

