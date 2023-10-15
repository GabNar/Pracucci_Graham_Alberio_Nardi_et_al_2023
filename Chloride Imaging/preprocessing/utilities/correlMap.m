function map = correlMap(x,neighR,norm)

    % computes the pixel-wise correlation map of a movie. For each pixel,
    % compute a neighbourhood of radius = neighR and compute the average
    % lag-0 cross correlation of that pixel with the pixels belonging to
    % its neighbourhood. 
    
    % iput: x, a 3D matrix with dimensions y*x*time
    %       neighR: a scalar indicating the radius of the neighbourhood
    %       norm: boolean. if true, compute the normalized cross
    %           correlation (optional. default = false)
    
    if nargin<3
        norm=false;
    end

    [ny,nx,nt] = size(x);
    map = nan(ny,nx);

    templ = strel('disk',neighR,0);
    templmat = templ.Neighborhood;
    templmat(neighR+1,neighR+1)=0; % the center becomes false;
    
    x = x-nanmean(x,3); % subtract the mean = fluctuations around the mean
    parfor py = 1:ny
%     for py = 1:ny   
        if ~rem(py,10)
            disp(['Processing line ' num2str(py) ' over ' num2str(ny) '...'])
        end
        for px = 1:nx
            currentPx = x(py,px,:);
            if ~prod(isnan(currentPx)) % at least one timepoint is not nan
                neigX = max(1,px-neighR):min(nx,px+neighR);
                neigY = max(1,py-neighR):min(ny,py+neighR);
                neigmat = x(neigY,neigX,:);
                selpx = templmat(neigY-py+neighR+1,neigX-px+neighR+1);
                
                if norm
                    tmp=nansum(neigmat.*currentPx,3)./nansum(neigmat.^2,3).*selpx;
                else
                    tmp = nansum(neigmat.*currentPx,3).*selpx;
                end
                map(py,px) = nansum(tmp,'all')./ ...
                                        sum(any(~isnan(neigmat),3) & selpx,'all');

            else
                map(py,px) = nan;
            end
        end
    end
%     map(any(isnan(x),3))=nan;
end