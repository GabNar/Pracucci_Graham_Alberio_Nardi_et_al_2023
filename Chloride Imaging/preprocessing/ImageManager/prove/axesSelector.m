classdef axesSelector < handle
    
    properties
        rootCopy
        currFig
        selAx
        figChangedListener
        figureIsChanged
        axesIsChanged
        selectionRunning
    end
    
    methods
        
        function aS = axesSelector()
            % get the Graphics root object
            aS.rootCopy = groot;
            % assign the current figure property
            aS.currFig = get(aS.rootCopy,'CurrentFigure');
            % assign the current axes property
            if ~isempty(aS.currFig)
                aS.selAx = get(aS.currFig,'CurrentAxes');
            else
                aS.selAx = [];
            end
            % current figure and current axes are not changed
            aS.figureIsChanged = false;
            aS.axesIsChanged = false;
            aS.selectionRunning = false;
            % create a listener to current figure changes
            aS.figChangedListener = addlistener(aS.rootCopy,'CurrentFigure','PostSet',@(src,ev)aS.figLisCallback());
        end
        
        function figLisCallback(aS)
            % update currFigProperty
            r = groot;
            aS.currFig = get(r,'CurrentFigure');
            % reset currAxProperty
            aS.selAx = [];
            % keep note that current figure has changed
            aS.figureIsChanged = true;
            % try to select an axes
            waitfor(aS,'selectionRunning',false)
            aS.selectAxes()
        end
        
        function selectAxes(aS)
            aS.selectionRunning = true;
            % main function. 
            % current figure has change, so here we are. Let's reset that
            % property.
            aS.figureIsChanged = false;
            % Also reset the current axes and wait until 1) the user selects 
            % an axes or 2) a new figure is selected.
            r = groot;
%             r.CurrentFigure.CurrentAxes = [];
            l = addlistener(r.CurrentFigure,'CurrentAxes','PostSet',@(src,ev) aS.axLisCallback());
%             while isempty(r.CurrentFigure.CurrentAxes) && ~aS.figureIsChanged
            while ~aS.axesIsChanged && ~aS.figureIsChanged
                drawnow % just wait for the user to do something
            end
            
            % we're out of the while loop. Why?
%             if ~isempty(aS.currFig.CurrentAxes)
            if aS.axesIsChanged
                aS.axesIsChanged = false;
                %   1) if an axes has been selected, we've done, so:
                %       delete the listener
                delete(aS.figChangedListener)
                %       store the selected axes
%                 aS.selAx = aS.currFig.CurrentAxes;
                aS.selAx = gca;
            elseif aS.figureIsChanged
                %   2) the user selected another figure
                %   do nothing: another call to this function is going to
                %   be performed by the listener callback
            else
                err('Unespected error while waiting for user action')
            end
            delete(l)
            aS.selectionRunning = false;
        end
        
        function axLisCallback(aS)
            aS.axesIsChanged = true;
        end
        
    end
end