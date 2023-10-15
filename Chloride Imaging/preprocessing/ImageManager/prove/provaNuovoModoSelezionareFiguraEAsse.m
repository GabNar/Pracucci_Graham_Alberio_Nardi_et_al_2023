% reset the current figure
                myRoot = groot;
                
                allFigs = get(myRoot,'Children');
                if length(allFig) > 1
                    myRoot.CurrentFigure = [];
                    % wait until you hover the mouse over a figure
                    waitfor(get(groot),'CurrentFigure') 
                    
                    % else: the only figure is already the current figure
                end
                % the callback updates the property app.currFigChanged
                % setting it to true, and calls the function for selecting
                % the axes. 
                lis = addlistener(myRoot,'CurrentFigure','PostSet',@(src,ev)currFigChanged_fcn(app,src,ev));
                
                

                % now reset the current axes
                selFig = getfield(get(groot),'CurrentFigure');
                allAxes = findobj(selFig,'type','axes');
                if length(allAxes) > 1
                    selFig.CurrentAxes = [];
                    % and wait until the user cliks on an axes
                    waitfor(gcf,'CurrentAxes')
                    
                    % else: the only axes is already the current axes
                end

                currAxes = gca;