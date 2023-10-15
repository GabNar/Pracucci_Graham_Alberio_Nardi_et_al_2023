function [flats,ratios,folder] = loadFlats(varargin)

% input parsing
if nargin==0
    tmpfolder=uigetdir(pwd,'Select flats folder');
    if tmpfolder==0
        flats=[];
        ratios=[];
        folder=0;
        return
    else
        folder=tmpfolder;
    end
else
    folder=varargin{1};
end


% look for flats
flat_files=dir([folder filesep 'Flat_*.tif']);
% get wavelengths
wl_name=regexp({flat_files.name},'_\d*nm','match');
wl_name=cellfun(@(x)(x{1}(2:end-2)),wl_name,'UniformOutput',false);
n_wl=numel(wl_name);
info=imfinfo([folder filesep flat_files(1).name]);
n_x=info(1).Width;
n_y=info(1).Height;
% load flats
flats=zeros(n_y,n_x,2,n_wl); % y,x,ch,wl
ratios=zeros(1,n_wl);
edge_pxl=10;
for i=1:n_wl
    flats(:,:,1,i)=imread([folder filesep flat_files(i).name],1); %ch1
    flats(:,:,2,i)=imread([folder filesep flat_files(i).name],2); %ch2
    ratios(i)=mean(flats(edge_pxl:end-edge_pxl,edge_pxl:end-edge_pxl,2,i),'all')...% red
            ./mean(flats(edge_pxl:end-edge_pxl,edge_pxl:end-edge_pxl,1,i),'all'); % over green
end


