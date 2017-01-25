% filterplot_fft    Plot the frequency response of a filter
% 
% filterplot_fft(H,f,Fs,title,passbands,stopbands,{drawgraph, color,ripple_display})
% where b and a are the filter coefficients, fftlen is the size of the fft
% and passbands and stopbands each is an array of passband and stopband
% frequencies

function [H,f,varargout] = filterplot_fft(H,f,Fs,title_text,passband,stopband,varargin);

MHz = 1e6;
if nargin == 7
    drawgraph = varargin{1};
else
    drawgraph = 1;
end


if nargin == 8
    gcolor = varargin{2};
else
    gcolor = 'b';
end

if nargin == 9
    ripple_disp = varargin{2};
else
    ripple_disp = 1;
end
    
fftlen = length(H);
if Fs > MHz
    Fs = Fs/MHz;
    passband = passband/MHz;
    stopband = stopband/MHz;
end

if drawgraph == 1
    plot(f/2/pi*Fs,dbv(abs(H)),gcolor),grid,title(title_text);
    xlabel('Frequency (MHz)');
    ylabel('Magnitude (dB)');
end
%axis([0 Fs/2 -160 5]);
pb = length(passband);
sb = length(stopband);
if ( mod(pb,2) ~= 0 || mod(sb,2) ~= 0 )
    error('Passband and stopband should have at least 2 entries and multiples of 2 thereof\n');
end

for iter = 1:2:pb-1
    fpb_LS = ceil(passband(iter)/Fs*fftlen*2);
    if (fpb_LS == 0)
        fpb_LS = 1;
    end
    fpb_RS = ceil(passband(iter+1)/Fs*fftlen*2);
    pb_droop = min(dbv(abs(H(fpb_LS:fpb_RS))));
    maxpass = max(dbv(abs(H(fpb_LS:fpb_RS))));
    minpass = min(dbv(abs(H(fpb_LS:fpb_RS))));
    pb_ripple = maxpass - minpass;
    %pbtext1 = sprintf('Passband droop upto %.1fMHz is %.2f',fpb_RS/fftlen/2*Fs,pb_droop);
    pbtext2 = sprintf('Passband ripple is %.2gdB',pb_ripple);
    if drawgraph == 1
     %   text(pb(iter),pb_ripple - iter*6, pbtext1,'Fontsize',9)
        if ripple_disp == 1
            text(pb(iter),pb_ripple - iter*6-10, pbtext2,'Fontsize',9);
        end
        line([fpb_LS/fftlen/2*Fs fpb_RS/fftlen/2*Fs],[minpass minpass],'Color','r','LineWidth',1,'LineStyle','--');
        line([fpb_LS/fftlen/2*Fs fpb_RS/fftlen/2*Fs],[maxpass maxpass],'Color','r','LineWidth',1,'LineStyle','--');        
    end
end

jter = 1;
for iter = 1:2:sb-1
    fsb_imgLS = floor(stopband(iter)/Fs*fftlen*2);
    fsb_imgRS = ceil(stopband(iter+1)/Fs*fftlen*2);
    sb_rej = max(dbv(abs(H(fsb_imgLS:fsb_imgRS))));
    sb_rejvec(jter) = sb_rej;
    sbtext = sprintf('Stopband rej %.1fMHz to %.1fMHz is %.1f dB',fsb_imgLS/fftlen/2*Fs,fsb_imgRS/fftlen/2*Fs,sb_rej);
    if drawgraph == 1
        text(3.5*Fs/16,(-iter*6-28), sbtext,'Fontsize',9);
        line([fsb_imgLS/fftlen/2*Fs fsb_imgRS/fftlen/2*Fs],[sb_rej sb_rej],'Color','r','LineWidth',1);
        
    end
    % Draw the vertical lines next
    %line([fsb_imgLS/fftlen/2*Fs fsb_imgLS/fftlen/2*Fs],[-80 -140],'Color','r','LineWidth',1, 'LineStyle','-.')
    %line([fsb_imgRS/fftlen/2*Fs fsb_imgRS/fftlen/2*Fs],[-80 -140],'Color','r','LineWidth',1, 'LineStyle','-.')
    jter = jter+1;
end
%axis([0 Fs/2 -120 5])
varargout{1} = pb_ripple;
varargout{2} = sb_rejvec;
