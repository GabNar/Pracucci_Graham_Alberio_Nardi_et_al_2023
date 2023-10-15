function registered = imreg_trasl(stack,deltas)
[ny,nx,nframes] = size(stack);
registered = nan(size(stack));
disp('Registration starting...')
for i = 1:nframes
    if rem(i,100)==1 || i==1
        fprintf('Processing frame %i of %i\n',i,nframes)
    end
    
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
disp('Registration complete')

end