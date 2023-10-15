function [iso,r0]=find_isosb(wl,s1,s2)

wl_zoom=wl(1):0.1:wl(end);
s1_int=interp1(wl,s1,wl_zoom);
s2_int=interp1(wl,s2,wl_zoom);
diff_zoom=s1_int-s2_int;
[~,min_i]=min(abs(diff_zoom));
iso=wl_zoom(min_i);
r0=mean([s1_int(min_i),s2_int(min_i)]);
fprintf('Isosbestic point = %.2f\nR0 = %.4f\n',iso,r0)


end