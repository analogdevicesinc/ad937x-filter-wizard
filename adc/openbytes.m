function [profbytes usestr] = openbytes(adc)

BW=adc.BW;
Fs=adc.Fs;
F0=adc.F0;
usage=adc.usage;
regs=adc.regs;

%Change: DEC-04-15 - now builds entire profile contents

profbytes = zeros(1,37);
iprof=1;

%components 0-15 
for cap = 1:size(regs.Ccodes,2)
    profbytes(iprof) = regs.Ccodes(cap);
    iprof=iprof+1;
end
for res = 1:size(regs.Gcodes,2)
    profbytes(iprof) = regs.Gcodes(res);
    iprof=iprof+1;
end
if(regs.Icodes(1)<0)
    profbytes(iprof) = 64+abs(regs.Icodes(1));
    iprof=iprof+1;
else
    profbytes(iprof) = regs.Icodes(1);
    iprof=iprof+1;
end
for cur = 2:size(regs.Icodes,2)
    profbytes(iprof) = regs.Icodes(cur);
    iprof=iprof+1;
end

%components 16-19 for DAC bias tweaking default 0
profbytes(iprof:iprof+3) = zeros(1,4);
iprof=iprof+4;

%component 20 is DFB current divided by 4
profbytes(iprof) = round(regs.Icodes(5)/4);
iprof = iprof+1;

%figure out bias bytes 21-36 here

%share cm and amp 1&2, 3&4 settings for now
%default settings for 1228.8/1536 clock rates - 32 mA
cm1=0;
cm2=0;
cm3=0;
gm3c=0;
amp12_gm0=0;
amp12_gm1=0;
amp12_gm2=0;
amp12_gm3=0;
amp12_gmr=0;
amp12_rcap=5;
amp1_comp=4;
amp2_comp=2;
amp34_gm0=0;
amp34_gm1=0;
amp34_gm2=0;
amp34_gm3=0;
amp34_comp=2;

%manually define settings for modes
if Fs<750e6 %low-power - 22 mA (save 10)
    amp12_gm0=5;
    amp12_gm1=4;
    amp12_gm2=4;
    amp12_gmr=4;
    amp12_rcap=7;
    amp1_comp=7;
    amp2_comp=7;
    amp34_gm0=5;
    amp34_gm1=4;
    amp34_gm2=4;
    amp34_comp=7;
 elseif Fs<1000e6 %med power 27 mA (save 5)
    amp12_gm0=6;
    amp12_gm1=6;
    amp12_gm2=6;
    amp12_gmr=6;
    amp12_rcap=7;
    amp1_comp=7;
    amp2_comp=4;
    amp34_gm0=6;
    amp34_gm1=6;
    amp34_gm2=6;
    amp34_comp=7; 
end

miscbytes=zeros(1,16);

 % make bytes 21-36 from amp settings
 %byte3 [31:24] {1'b0 (cm_ctrl[3:0]) comp[2:0]} ((3),4)
 %byte3 [31:24] {2'b0 rcap[2:0] comp[2:0]} (1,2)
 %byte2 [23:16] {cm3[1:0] gm3[2:0] gm2[1:0]}
 %byte1 [15:8]  {cm2[1:0] gm1[2:0] gm0[2:0]}
 %byte0 [7:0]   {(gmr[2:0]) gm3c[2:0] cm1[1:0]}

%amp1 byte0
miscbytes(1) = insertBits(miscbytes(1),cm1,2,0);
miscbytes(1) = insertBits(miscbytes(1),gm3c,3,2);
miscbytes(1) = insertBits(miscbytes(1),amp12_gmr,3,5);
%amp1 byte1
miscbytes(2) = insertBits(miscbytes(2),amp12_gm0,3,0);
miscbytes(2) = insertBits(miscbytes(2),amp12_gm1,3,3);
miscbytes(2) = insertBits(miscbytes(2),cm2,2,6);
%amp1 byte2
miscbytes(3) = insertBits(miscbytes(3),amp12_gm2,3,0);
miscbytes(3) = insertBits(miscbytes(3),amp12_gm3,3,3);
miscbytes(3) = insertBits(miscbytes(3),cm3,2,6);
%amp1 byte3
miscbytes(4) = insertBits(miscbytes(4),amp1_comp,3,0);
miscbytes(4) = insertBits(miscbytes(4),amp12_rcap,3,3);
%copy bytes 0-2 to amp2
miscbytes(5:7) = miscbytes(1:3);
%amp2 byte3
miscbytes(8) = insertBits(miscbytes(8),amp2_comp,3,0);
miscbytes(8) = insertBits(miscbytes(8),amp12_rcap,3,3);

%amp3 byte0
miscbytes(9) = insertBits(miscbytes(9),cm1,2,0);
miscbytes(9) = insertBits(miscbytes(9),gm3c,3,2);
%amp1 byte1
miscbytes(10) = insertBits(miscbytes(10),amp34_gm0,3,0);
miscbytes(10) = insertBits(miscbytes(10),amp34_gm1,3,3);
miscbytes(10) = insertBits(miscbytes(10),cm2,2,6);
%amp1 byte2
miscbytes(11) = insertBits(miscbytes(11),amp34_gm2,3,0);
miscbytes(11) = insertBits(miscbytes(11),amp34_gm3,3,3);
miscbytes(11) = insertBits(miscbytes(11),cm3,2,6);
%amp1 byte3
miscbytes(12) = insertBits(miscbytes(12),amp34_comp,3,0);
%miscbytes(12) = insertBits(miscbytes(12),cm_ctrl,4,3); %cm_ctrl=0
%copy to amp4
miscbytes(13:16) = miscbytes(9:12);

profbytes(iprof:iprof+15) = miscbytes;
%profbytes(end) = round(regs.Gcodes(1)/sqrt(2));

varlist = {'amp12_gm0','amp12_gm1','amp12_gm2','amp12_gm3','amp12_gmr','amp12_rcap','amp1_comp','amp2_comp', ...
   'amp34_gm0','amp34_gm1','amp34_gm2','amp34_gm3','amp34_comp'};
usestr=[];
for ii = 1:length(varlist)
    evalcmd = sprintf('usestr=sprintf(''%%s%s=%%d\\n'',usestr,%s);',varlist{ii},varlist{ii});
    eval(evalcmd);
end

return
