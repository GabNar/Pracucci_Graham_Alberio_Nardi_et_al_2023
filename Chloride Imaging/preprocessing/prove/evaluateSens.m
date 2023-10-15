% EVALUATE SENSITIVITY PARAMETER
function [first,last]=evaluateSens(img,varargin)

pars=inputParser();
pars.addRequired('img');
pars.addOptional('nhood',21);
pars.addOptional('first',0);
pars.addOptional('last',1);
pars.addOptional('n',21);
pars.addOptional('plotFlag',false);
parse(pars,img,varargin{:});
names=fieldnames(pars.Results);
for i=1:length(names)
   eval(sprintf('%s=pars.Results.(names{%i});',names{i},i)) 
end

% img is the frame to binarize
covergence_crit = 0.05; % fold change in fist or last

% starting values (full range)
% first = 0;
% last = 1;

foldchange = 1;
% plotFlag = true;
if plotFlag
    figure
end
while foldchange > covergence_crit
    if plotFlag
        close(gcf)
    end
    [tot,sens]=trySens(first,last,n,img,nhood,plotFlag);
    newfirst = sens(find(diff(tot)>0.002,1));
    newlast =  sens(min(find(diff(tot)>0.002,1,'last')+2,length(sens)));
    foldchange = max(abs(first-newfirst)./first,abs(last-newlast)./last);
    first = newfirst;
    last = newlast;
end
end