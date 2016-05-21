% filterplot    Plot the frequency response of a filter
% 
% filterplot(b,a,fftlen,Fs,title_text, passbands,stopbands)
% where b and a are the filter coefficients, fftlen is the size of the fft,
% title_text is the title of the plot and passbands and stopbands each 
% is an array of passband and stopband frequencies

function [H,f,varargout] = filterplot(b,a,fftlen,Fs,title_text,passband,stopband,varargin);

buse = b/sum(b);
[H,f] = freqz(buse,a,fftlen);

if nargin == 8
    gcolor = varargin{1};
else
    gcolor = 'b';
end

plot(f/2/pi*Fs,dbv(abs(H)),gcolor),grid,title(title_text);
xlabel('Frequency in MHz'),ylabel('Magnitude in dB');
axis([0 Fs/2 -120 5]);

pb = length(passband)
sb = length(stopband)
if ( mod(pb,2) ~= 0 || mod(sb,2) ~= 0 )
    error('Passband and stopband should have at least 2 entries and multiples of 2 thereof\n');
end


for iter = 1:2:pb-1
    fpb_LS = ceil(passband(iter)/Fs*fftlen*2)
    if (fpb_LS == 0)
        fpb_LS = 1;
    end
    fpb_RS = ceil(passband(iter+1)/Fs*fftlen*2)
    pb_droop = min(dbv(abs(H(fpb_LS:fpb_RS))))
    pb_ripple = max(dbv(abs(H(fpb_LS:fpb_RS)))) - min(dbv(abs(H(fpb_LS:fpb_RS))))
    %pbtext1 = sprintf('Passband droop upto %.fMHz is %.2f',fpb_RS/fftlen/2*Fs,pb_droop);
    pbtext2 = sprintf('Passband ripple is %.2f',pb_ripple);
    %text(pb(iter),pb_ripple - iter*6, pbtext1,'Fontsize',8)
    text(pb(iter),pb_ripple - iter*6-10, pbtext2,'Fontsize',8)
    line([fpb_LS/fftlen/2*Fs fpb_RS/fftlen/2*Fs],[-pb_ripple -pb_ripple],'Color','g','LineWidth',1)
end

for iter = 1:2:sb-1
    fsb_imgLS = floor(stopband(iter)/Fs*fftlen*2)
    fsb_imgRS = ceil(stopband(iter+1)/Fs*fftlen*2)
    sb_rej = max(dbv(abs(H(fsb_imgLS:fsb_imgRS))))
      sb_rejvec(iter) = sb_rej;
    sbtext = sprintf('Stopband rej %.fMHz to %.fMHz is %.f dB',fsb_imgLS/fftlen/2*Fs,fsb_imgRS/fftlen/2*Fs,sb_rej);
    text(3.5*Fs/16,(-iter*6-18), sbtext,'Fontsize',8)
    line([fsb_imgLS/fftlen/2*Fs fsb_imgRS/fftlen/2*Fs],[sb_rej sb_rej],'Color','r','LineWidth',1)

end
varargout{1} = pb_ripple
varargout{2} = sb_rejvec
