function [dark,stand]=readDark(varargin)
    
if nargin==0
    folder=uigetdir();
else
    folder=varargin{1};
end

[xyct_img,metadata] = import_PrairieTimeSequence(folder);

xyct_img(xyct_img==0)=nan;
dark=mean(xyct_img,[1 2 4]);
stand=std(double(xyct_img),[],[1 2 4]);
figure
yyaxis left
plot(squeeze(mean(xyct_img,[1 2])).')
ylabel('Mean')
yyaxis right
plot(squeeze(std(double(xyct_img),[],[1 2])).')
xlabel('Frame')
ylabel('Std')
legend

fid=fopen([folder '_values.txt'],'w');
fprintf(fid,'Average: %.1f,%.1f\nStd: %.1f,%.1f',dark,stand);
fclose(fid);
end