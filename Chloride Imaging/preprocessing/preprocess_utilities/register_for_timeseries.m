
%% get template
[file,fold]=uigetfile('*.tif');
info=imfinfo([fold,file]);
templ=imread([fold file],'tif');
for i=2:numel(info)
    templ=templ+imread([fold file],'tif',i);
end
for i=1:numel(info)
    templ=templ+imread([fold strrep(file,'Ch1','Ch2')],'tif',i);
end
templ=templ./2./numel(info);

%% get and register image

[file,fold]=uigetfile([fold '*.tif']);
info=imfinfo([fold,file]);
ch1=zeros(info(1).Height,info(1).Width,numel(info));
for i=1:numel(info)
    ch1(:,:,i)=imread([fold file],'tif',i);
end
ch2=zeros(info(1).Height,info(1).Width,numel(info));
for i=1:numel(info)
    ch2(:,:,i)=imread([fold strrep(file,'Ch1','Ch2')],'tif',i);
end
avg_ch=mean(cat(4,ch1,ch2),4);
[~,deltas] = myregistration(avg_ch,templ);
ch1_reg=imreg_trasl(ch1,deltas);
ch2_reg=imreg_trasl(ch2,deltas);

%save
tagstruct.Photometric=Tiff.Photometric.MinIsBlack;
tagstruct.Compression=Tiff.Compression.PackBits;
tagstruct.BitsPerSample=32;
tagstruct.SamplesPerPixel=1;
tagstruct.SubFileType=2;
tagstruct.SampleFormat=Tiff.SampleFormat.IEEEFP;
tagstruct.ImageLength=info(1).Height;
tagstruct.ImageWidth=info(1).Width;
tagstruct.PlanarConfiguration=Tiff.PlanarConfiguration.Chunky;
tagstruct.TileLength=info(1).Height;
tagstruct.TileWidth=info(1).Width;

outDir=fold;
for i_ch=1:2 %channels
    if i_ch==1
        filename = sprintf('%s_reg.tif',file);
        data_reg = ch1_reg;
    else
        filename = sprintf('%s_reg.tif',strrep(file,'Ch1','Ch2'));
        data_reg = ch2_reg;
    end
    t = Tiff([outDir filename],'w');
    setTag(t,tagstruct)
    t.write(single(data_reg(:,:,1)));
    for i_wl=2:numel(info)
        writeDirectory(t);
        setTag(t,tagstruct)
        t.write(single(data_reg(:,:,i_wl)));
    end
end

close(t)
disp('done') 