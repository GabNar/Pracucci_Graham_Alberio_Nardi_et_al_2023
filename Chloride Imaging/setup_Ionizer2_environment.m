function setup_Ionizer2_environment()

this_file = mfilename('fullpath');
sep=regexp(this_file,filesep);
this_folder = this_file(1:sep(end));

folders_to_add=[...
    "functions",...
    "calibration_files",...
    "preprocessing",...
    "preprocessing\utilities",...
    "preprocessing\preprocess_utilities",...
    "preprocessing\ImageManager",...
    "preprocessing\ImageManager\utilities",...
    "preprocessing\ImageManager\icons",...
    "preprocessing\ImageManager\icons\matlab icons"];

addpath(this_folder)
fprintf('Added to path: %s\n',this_folder)
for i=1:numel(folders_to_add)
    now=strcat(this_folder,folders_to_add(i));
    addpath(now)
    fprintf('Added to path: %s\n',now)
end
disp('Environment setup complete')

end