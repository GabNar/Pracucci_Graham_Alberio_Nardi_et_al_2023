%%
delete(myobj.figChangedListener)
delete(myobj)
clear all
close all
clc
%%
figure('name','f1')
a11 = subplot(2,1,1);
imagesc(randn(5,5))
a21 = subplot(2,1,2);
imagesc(randn(15,15))
title(a11,'a1_f1')
title(a21,'a2_f1')

figure('name','f2')
a12 = subplot(1,3,1);
imagesc(randn(5,5))
a22 = subplot(1,3,2);
imagesc(randn(15,15))
a32 = subplot(1,3,3);
imagesc(NaN)
title(a12,'a1_f2')
title(a22,'a2_f2')
title(a32,'a3_f2')

drawnow

myobj = axesSelector;
myobj.figLisCallback();

disp(myobj.selAx.Title.String)