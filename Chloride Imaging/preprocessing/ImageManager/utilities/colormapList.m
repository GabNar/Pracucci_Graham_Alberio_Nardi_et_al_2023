function ColormapsList = colormapList()
% GAB, 2020-03-23

CurrFolder=pwd;

cd(strcat(matlabroot,'\toolbox\matlab\graphics\color'))

Colormaps=dir('*.m');

ColormapsList={Colormaps.name};

ColormapsList=cellfun(@(x) x(1:end-2),ColormapsList,'UniformOutput',false);

cd(CurrFolder);

