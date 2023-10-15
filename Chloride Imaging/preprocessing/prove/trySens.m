function [tot,sens]=trySens(from,to,n,img,nhood,plotFlag)
sens = linspace(from,to,n);
tot=nan(numel(sens),1);
img(isnan(img))= quantile(img,0.8,'all');
% rescale and apply a gamma
img = rescale(img,0,1).^0.55;
for i = 1:length(sens)
    currimg = imbinarize(img,adaptthresh(img,sens(i),'NeighborhoodSize',nhood,'Statistic','gaussian'));
    tot(i)=sum(currimg,'all')./numel(currimg);
end
if plotFlag
    figure
    yyaxis('left')
    plot(sens,tot)
    yyaxis('right')
    plot(sens(2:end),diff(tot))
    xlabel('sensibility')
end