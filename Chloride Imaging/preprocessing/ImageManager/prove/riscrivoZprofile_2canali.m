% plot and store the z profile
            % GAB: for this function to work, a pointer to the "source" stac must be saved in the
            % UserData property of the axes in which figures are shown.
            % Here it is an example on how to use pointers to matlab arrays
            %             mat = randn(10,20,30);
            %             ptr = libpointer('MATLAB array',mat); % define the pointer
            %             ax.UserData = ptr; % assign it to the user data
            %             c = get(ax.UserData); % fet the pointer
            %             d = c.Value; % now d=mat
            % 
            % Ev: event data. If this function is called when a ROI is
            %       created, then ev is empty. If this function is called when a
            %       ROI is moved or reshaped, it stores the event object.
            
            if strcmp(app.TabGroup.SelectedTab.Title,'Z axis profile') || isempty(ev)
                % Go on with the function only if the 'Z axis profile' tab
                % is selected. The only exception is when a ROI has just
                % been created. In this case we have to set up the plot,
                % such that it can be updated if 'Z axis profile'
                % will be selected in the future.
            
                ptrs = ROI.Parent.UserData; % UserData must cointain a pointer to the source matrix
                if ~isempty(ptrs)
                    % proceed only if there's a non-empty pointer
                    
                    % retrieve stack or movie matrix
                    ptrData = get(ptrs.data);
                    mat = ptrData.Value;
                    
                    % timepoints
                    ptrX = get(ptrs.x);
                    xPts = ptrX.Value;
                    
                    % stimulus time, if provided
                    if isfield(ptrs,'stimuli')
                        ptrStim = get(ptrs.stimuli); % must be a line, NOT a column
                        xStim = ptrStim.Value;
                        nStim = length(xStim);
                    else
                        nStim = 0;
                    end
  
                    % save array dimensions
                    dim = size(mat);
                    dtaLen = length(xPts);
                    
                    % Investigate which kind of matrix we have to manage
                    % with:
                    % case 1: single channel 3D stack or movie
                    % case 2: there are 2 channels (actually, this code works
                    %   for an arbitrary number of channels: mat is a 4D matrix of
                    %   dimensions x*y*ch*time;
                    % case 3: any of the previous, but stimuli are delivered.
                    %   stimulus time must be provided.
                    
                    if length(dim) == 3
                        % dimensions are x*y*time
                        tmp = mat;
                        % add a singleton as channel dimension
                        mat = NaN(dim(1),dim(2),1,dim(3));
                        mat(:,:,1,:) = tmp;
                        % update dimensions
                        dim = size(mat);
                    end
                    
                    if length(dim) == 4
                        % get the image plot in the selected axes
                        allChildren = findobj(ROI.Parent,'Type','Image');
                        % ROIs MIGHT BE image subtype(they were in 2019a) but can be distinguished:
                        myImage = allChildren(strcmp( arrayfun(@(x) x.Type, allChildren,'UniformOutput',false),'image')); % arrayfun returns a cell array with
                        %                                                                                   the array characters of the field "Type"                      
                        
                        % find the pixels belonging to the ROI.
                        % getSelectedPixels returns selected pixels using
                        % logical linear indexing. 
                        selectedPxl = getSelectedPixels(myImage,ROI);
                        
                        % selectedPxl is a logical array with as many elements as
                        % the number of pixels in a frame. selectedPxl(i)
                        % is true if the i-th pixel (in column order) of
                        % the image is included in the ROI.
                        % Now, we want to obtain a matrix of selected
                        % pixels. The new matrix shape will be N*ch*time
                        % where N is the number of selected pixels in a
                        % frame (i.e. sum(selectedPxl)). To do so, we have
                        % to perform several passages in which the matrix
                        % is reshaped and permuted. All the passages are
                        % condensed in a single line for speeding up the
                        % code.
                        % Passages explained:
                        % 	allSelectedPxl=
                        % 	repmat(selectedPxl,dim(3)*dim(4),1)); % repeat the selected pxls for every 
                        %                                           frame of every channel
                        % 	linearized_selected_Mat = mat( allSelectedPxl ); % obtain only the selected pixels in a column vector
                        % 	stackedMat = reshape(linearized_selected_Mat,sum(selectedPxl),dim(3),dim(4)); % reshape in the form   
                        %                                           of (number_of_ROI_pixels)*(n_channels)*(n_frames)
                        % 	line2plot = squeeze(mean( stackedMat,1))'; % compute the average for every channel and
                        %                                               frame, obtain a matrix of dimensions time*channels
                        lines2plot = squeeze( mean( reshape( mat( repmat(selectedPxl,dim(3)*dim(4),1)) ,sum(selectedPxl),dim(3),dim(4)),1))';
                        minY = min(lines2plot,'all');
                        maxY = max(lines2plot,'all');
                        % set y axis limits
                        if ~app.holdyButton.Value
                            app.zProfileAxes.YLim  = [minY-0.05*(maxY-minY),maxY+0.05*(maxY-minY)];
                            app.yToEditField.Value = app.zProfileAxes.YLim(2);
                            app.yFromEditField.Value = app.zProfileAxes.YLim(1);
                        end
                        if isempty(ev)
                            % This ROI has just been created
                            cla(app.zProfileAxes)

                            app.zProfileLine = plot(app.zProfileAxes,xPts,lines2plot,'LineWidth',1);
                            % set x axis limits
                            if ~app.holdyButton.Value
                                app.zProfileAxes.XLim = [xPts(1), xPts(end)];
                                app.xToEditField.Value = app.zProfileAxes.XLim(2);
                                app.xFromEditField.Value = app.zProfileAxes.XLim(1);
                            end
                            if nStim>0
                                % also plot vertical lines at the beginning of every
                                % trial
%                                 linesX = [1:fpt:dim(3);1:fpt:dim(3)-fpt+1];
                                linesX = [xStim; xStim];
                                linesY = ones(size(linesX)).*(app.zProfileAxes.YLim)';
                                plot(app.zProfileAxes,linesX,linesY,'Color','y')
                                app.zProfileAxes.XLim = [1,dim(3)];
                            end
                        else
                            % update the z line
                            set(app.zProfileLine,'XData',repmat({xPts},dim(3),1)); % dim(3) = n_channels; dim(4) = data_length
                            set(app.zProfileLine,'YData',mat2cell(lines2plot,dim(4),ones(1,dim(3))));
            
                            % also update the limits of the trial lines
                            chil = app.zProfileAxes.Children;
                            trialLines = arrayfun(@(x) (~isequal(x,app.zProfileLine)),chil);
                            arrayfun(@(x)(set(x,'YData',app.zProfileAxes.YLim)),chil(trialLines))
                        end
                    end
                end
            end