medFilt=9;
x=medfilt2(ffa.data(1).data_med(:,:,1),[medFilt medFilt]) ./ ...
    medfilt2(ffa.data(1).data_med(:,:,2),[medFilt medFilt]); % g/r
lowpass=medfilt2(x,[13 13]);
ratio_mean=mean(lowpass,'all','omitnan');
noise=x-lowpass+ratio_mean;

figure('Name',sprintf('Medfilt = %i',medFilt))
subplot(1,3,1)
imagesc(x)
colorbar
set(gca,'clim',quantile(x,[0.025 0.975],'all'))
title('Flat ratio (g/r)')

subplot(1,3,2)
imagesc(noise)
colorbar
colormap(turbo)
set(gca,'clim',quantile(noise,[0.025 0.975],'all'))
title('Flat detrended (noise)')

subplot(1,3,3)
histogram(noise(20:end-20,20:end-20),...
    linspace(ratio_mean-0.4,ratio_mean+0.4,128))
set(gca,'yscale','log')
title('Flat noise distrib')
