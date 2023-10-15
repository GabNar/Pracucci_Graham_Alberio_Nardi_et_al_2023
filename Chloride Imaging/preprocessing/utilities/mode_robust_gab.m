function dataMode = mode_robust_gab(inputData)
    %{
    Robust estimator of the mode of a data set using the half-sample mode.
    If inputData is a matrix, compute the mode for each of its columns.

    .. versionadded: 1.0.3
    """
    %}
%     if ~isempty(axis)
%         
%         if axis == 2
%             dataMode = arrayfun(@(n)  mode_robust(inputData(n,:),[]), 1:size(inputData,1));
%         elseif axis == 1
%             dataMode = arrayfun(@(n)  mode_robust(inputData(:,n),[]), 1:size(inputData,2));
%         else
%             error('axis can be 1 or two')
%         end
%     else
%         % Create the function that we can use for the half-sample mode
%         data = inputData(:);
%         % The data need to be sorted for this to work
%         data = sort(data);
%         % Find the mode
%         dataMode = hsm_gab(data);
%     end
    n=size(inputData,2);
    dataMode = nan(1,n);
    for i=1:n
        tmp = inputData(:,i);
        dataMode(i)=hsm_(sort(tmp));
    end
end