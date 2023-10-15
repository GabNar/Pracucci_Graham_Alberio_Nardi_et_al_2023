function [stack,mainfolder] = import_PrairieMultifolder(varargin)
% GAB 2023. This function loads multiple imaging files recorded with
% PrairieView. The function "import_PrairieTimeSequence" is used. This
% function is commonly used to load images or stacks recorded on the same
% acquisition field at different excitation wavelengths during
% spectroscopic measures with LSSmClopHensor. In this case, each folder
% contains images acquired at a specific wavelength, and it can contain:
%   -a single image
%   -a z-series
%   -single images acquired at different x-y positions (Cycles)
%   -z-series acquired at different x-y positions (Cycles).

% INPUT:
%    (optional): cell array containing the names of the source folders as
%    character arrays. If this function is called with no input arguments,
%    the source folders are selected interactively using the function
%    "uigetmultidir".

% OUTPUT:
%   stack: 5-D matrix containing the images loaded. Stack dimensions
%           are y*x*channel*folder*frame.
% 	mainfolder: array of characters of the complete path of the source folders.


% input parsing
if nargin==0
    folders=uigetmultidir();
    if isempty(folders)
        stack=[];
        mainfolder=0;
        return
    end
else
    folders=varargin{1};
end

% retrieve the name of the main folder
i_sep=regexp(folders{1},filesep);
mainfolder=folders{1}(1:i_sep(end)-1);

% number of folders
n_folds = numel(folders); % # of selected folders

% load the 1st folder
fprintf('Importing folder 1 of %i...\n',n_folds)
xyct_img = import_PrairieTimeSequence(folders{1});

% compute image size, # of channels and # of fields. Allocate a 5D array
[ny,nx,nch,nframes]=size(xyct_img);
stack=zeros([ny,nx,nch,n_folds,nframes]); % y*x*ch*folders*field
stack(:,:,:,1,:)=xyct_img;

% load the other folders
for i=2:n_folds  
    fprintf('Importing folder %i of %i...\n',i,n_folds)
    [xyct_img,~] = import_PrairieTimeSequence(folders{i});
    stack(:,:,:,i,:)=xyct_img;
end

