mc = metaclass(imageGateway);
properts = mc.PropertyList;
valids = {properts(:).Validation};
propNames = {properts(:).Name};
classes = cellfun(@getObjectClasses,valids,'UniformOutput',false);

isAfigure = cellfun(@(x) strcmp(x,'matlab.ui.Figure'),classes);
figNames = propNames(isAfigure);

isAnAxes = cellfun(@(x) strcmp(x,'matlab.ui.control.UIAxes'),classes);
axesNames = propNames(isAnAxes);

isAnApp = cellfun(@(x) ~isempty( find(regexp(x,'_App'),1)),classes);
appNames = propNames(isAnApp);



for i=1:length(figNames)
    eval(['z=findobj(imageGateway.' figNames{i} ',''Type'',''axes'');'])
end