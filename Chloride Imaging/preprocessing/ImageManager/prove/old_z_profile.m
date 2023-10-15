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
                    ptrData = get(ptrs.data);
                    mat = ptrData.Value;
                    ptrX = get(ptrs.x);
                    xpts = ptrX.Value;
%             
%                     % Associate to this ROI a listener to the UserData property
%                     % of its parent Axes. When the pointer changes, (i.e. the
%                     % source image stack changes), then refresh the ROI.
%                     ROI.UserData(3) = event.proplistener(ROI.Parent,findprop(matlab.ui.control.UIAxes,'UserData'),'PostSet',@(src,ev) refreshSource(app));
            
                    dim = size(mat);
                    % we can only treat 3D stacks
                    fpt = []; %number of frames per trial
                    if length(dim) == 4
                        % dimensions are x*y*trials*time
                        % so, unroll trials
                        fpt = dim(4); % store number of frames per trial
                        mat = reshape(permute(mat,[1,2,4,3]), dim(1),dim(2),[]);
                        dim = size(mat); % update dimensions
                    end
                    if length(dim) == 3
                        allChildren = findobj(ROI.Parent,'Type','Image');
                        % ROIs MIGHT BE image subtype(they were in 2019a) but can be distinguished:
                        myImage = allChildren(strcmp( arrayfun(@(x) x.Type, allChildren,'UniformOutput',false),'image')); % arrayfun returns a cell array with
                        %                                                                                   the array characters of the field "Type"                      
                        selectedPxl = getSelectedPixels(myImage,ROI);
                        %               Passages explained:
                        %                 allSelectedPxl=  repmat(selectedPxl,dim(3),1)); % repeat the selected pxls for every frame       0 
                        %                 linearized_selected_Mat = mat( allSelectedPxl ); % obtain only the selected pixels in a column vector
                        %                 stackedMat = reshape(linearized_selected_Mat,sum(selectedPxl),dim(3)); % reshape in the form   
                        %                                                                          % of (number_of_ROI_pixels)*(number_of_frames)
                        %                 line2plot = squeeze(mean( stackedMat,1)); % compute the average for every frame
                        line2plot = squeeze( mean( reshape( mat( repmat(selectedPxl,dim(3),1)) ,sum(selectedPxl),dim(3)),1));
                        minY = min(line2plot);
                        maxY = max(line2plot);
                        % set y axis limits
                        if ~app.holdyButton.Value
                            app.zProfileAxes.YLim  = [minY-0.05*(maxY-minY),maxY+0.05*(maxY-minY)];
                            app.yToEditField.Value = app.zProfileAxes.YLim(2);
                            app.yFromEditField.Value = app.zProfileAxes.YLim(1);
                        end
                        if isempty(ev)
                            % This ROI has just been created
                            cla(app.zProfileAxes)
%                             if app.framePeriodCheck.Value
%                                 xpts = (0:dim(3)-1)*app.FrameperiodauEditField.Value;
%                             else
%                                 xpts = 1:dim(3);
%                             end
                            app.zProfileLine = plot(app.zProfileAxes,xpts,line2plot,'LineWidth',1);
                            % set x axis limits
                            if ~app.holdyButton.Value
                                app.zProfileAxes.XLim = [xpts(1), xpts(end)];
                                app.xToEditField.Value = app.zProfileAxes.XLim(2);
                                app.xFromEditField.Value = app.zProfileAxes.XLim(1);
                            end
                            if ~isempty(fpt)
                                % also plot vertical lines at the beginning of every
                                % trial
                                linesX = [1:fpt:dim(3);1:fpt:dim(3)-fpt+1];
                                linesY = ones(2,size(linesX,2)).*(app.zProfileAxes.YLim)';
                                plot(app.zProfileAxes,linesX,linesY,'Color','y')
                                app.zProfileAxes.XLim = [1,dim(3)];
                            end
                        else
                            % update the z line
                            app.zProfileLine.XData = xpts;
                            app.zProfileLine.YData = line2plot;
            
                            % also update the limits of the trial lines
                            chil = app.zProfileAxes.Children;
                            trialLines = arrayfun(@(x) (~isequal(x,app.zProfileLine)),chil);
                            arrayfun(@(x)(set(x,'YData',app.zProfileAxes.YLim)),chil(trialLines))
                        end
                    end
                end
            end