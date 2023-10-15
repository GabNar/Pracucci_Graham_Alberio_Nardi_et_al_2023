function [axesArrayOut,axesParentAppOut,appsDoneOut] = lookForAxes(app,axesArrayIn,axesParentAppIn,appsDoneIn)

    % salvo il nome dell'app in input come stringa
    appInName = class(app);

    % trovo i nomi e le classi delle proprietà dell'app in input
    propNames = properties(app);
    classes = cellfun(@(x) getObjClass(x,app),propNames,'UniformOutput',false);

    % vedo quali sono figure
    isAfigure = cellfun(@(x) strcmp(x,'matlab.ui.Figure'),classes);
    figNames = propNames(isAfigure);

    % vedo quali sono gli handles alle altre app collegate
    isAnApp = cellfun(@(x) ~isempty( find(regexp(x,'_App'),1)),classes);
    appNames = propNames(isAnApp);

    % ora cosa devo fare?
    % 1) cercare gli assi nella figura e appenderli a axesArrayIn
    axesArrayOut = axesArrayIn;
    for i=1:length(figNames)
        eval(['axesArrayOut = cat(1,axesArrayOut,findobj(app.' figNames{i} ',''Type'',''axes''));'])
    end
    appsDoneOut = cat(1,appsDoneIn,{appInName}); % ricordo che questa app l'ho già fatta
    newlyAddedAxesN = length(axesArrayOut)-length(axesArrayIn);
    axesParentAppOut = cat(1,axesParentAppIn,repmat({appInName},newlyAddedAxesN,1));
    
    % 2) trovare le app e richiamare ricorsivamente la funzione
    for i=1:length(appNames)
       % solo se l'app in questione non è già stata fatta, altrimenti loop
       % infinito
        currAppName = '';
        eval(['currAppName = class(app.' appNames{i} ');']);
        if ~ismember(currAppName,appsDoneOut)
            eval(['[axesArrayOut,axesParentAppOut,appsDoneOut] = lookForAxes(app.' appNames{i} ',axesArrayOut,axesParentAppOut,appsDoneOut);']);
       end
    end
end