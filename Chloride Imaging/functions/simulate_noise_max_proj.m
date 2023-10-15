% simulation: noise with maximum projection of several slices

stand=15;
n_samp=15;
n_sli=5;
samples=randn(n_samp,n_samp,n_sli).*stand;
avg0=mean(samples,'all');
M=max(samples,[],3);
avgM=mean(M,'all');

slice2plot=1;

figure
subplot(2,2,1) % single slice
imagesc(samples(:,:,1))
colorbar
set(gca,'Clim',[-3*stand,3*stand])
title(sprintf('Slice %i of %i',slice2plot,n_sli))

subplot(2,2,3) % single slice distrib
histogram(samples(:,:,1),linspace(-4*stand,4*stand,128))
hold on
this_mean=mean(samples(:,:,1),'all');
plot([this_mean,this_mean],ylim)
xlabel('Pixel value')
ylabel('Counts')
title(sprintf('Mean: %.3f',this_mean))

subplot(2,2,2)
imagesc(M)
colorbar
set(gca,'Clim',[-3*stand,3*stand])
title(sprintf('Max proj. of %i slcies',n_sli))

subplot(2,2,4) % Max proj distrib
histogram(M,linspace(-4*stand,4*stand,128))
hold on
plot([avgM,avgM],ylim)
xlabel('Pixel value')
ylabel('Counts')
title(sprintf('Mean: %.3f',avgM))




%% plot
gre=60:600;
red=(60:600)';
rat=gre./red;

rat2=(gre+30)./(red+30);

figure
imagesc(gre,red,rat2./rat)
colorbar
title(sprintf('Alteration due to max proj, noise=%.1f',stand))
xlabel('green')
ylabel('red')
hold on
% plot(gre',[0.33, 0.5 1 1.25].*gre','k')
plot(gre',0.33.*gre','k')
set(gca,'clim',[0.8 1.2],'fontsize',15)
colormap turbo
% set(gca,'clim',[0.5 3.5])

