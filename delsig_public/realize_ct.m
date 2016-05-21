function [ABCDc,tdac2] = realize_ct( ntf, topology, tdac, bp, ABCDc)
% [ABCDc,tdac2] = realize_ct( ntf, topology={'FB',1:ceil(order/2)}, tdac, bp=zeros(...), ABCDc)	
% Realize an NTF with a continuous-time loop filter.
%
% Output
% ABCDc      A state-space description of the CT loop filter
%
% tdac2	     A matrix with the DAC timings, including ones
%	     that were automatically added.
%
%
% Input Arguments
% ntf	A noise transfer function in pole-zero form.
%	The zeros are assumed to be ordered as follows: 
%	real zero (if odd) followed by complex-conjugate pairs
%
% topology = {'FB'|'FF'|'LFFB', ordering|a_value}	
%       A cell array specifying the topology of the loop filter.
%	For the FB structure, the elements of Bc are calculated
% 	so that the sampled pulse response matches the L1 impulse
% 	response.  For the FF structure, Cc is calculated.
%    ordering
%	A vector specifying the ordering of NTF zeros in the loop filter.
% 	Default is for the zeros to be used in the order given in the NTF.
%	Ordering is irrelevant when a leapfrog (LFxx) structure is used.
%
%
% tdac	The timing for the feedback DAC(s). If tdac(1)>=1,
% 	direct feedback terms are added to the quantizer.
%	Multiple timings (1 or more per integrator) for the FB 
%       topology can be specified by making tdac a cell array,
%       e.g. tdac = { [1,2]; [1 2]; {[0.5 1],[1 1.5]}; []}; 
%	In this example, the first two integrators have
%	dacs with [1,2] timing, the third has a pair of
% 	dacs, one with [0.5 1] timing and the other with
%	[1 1.5] timing, and there is no direct feedback
% 	DAC to the quantizer
%
% bp	A vector specifying which resonator sections are bandpass.
%	The default (zeros(...)) is for all sections to be lowpass.
%
% ABCDc The loop filter structure, in state-space form.
%	If this argument is omitted, ABCDc is constructed according 
%       to "topology."
% 

order = length(ntf.p{1});
% Handle the input arguments
defaults = { {'ntf', NaN}, {'topology', {'FB',[1:ceil(order/2)]}}, {'tdac', [0 1]}, {'bp', []}, {'ABCDc',[]} };
for i=1:length(defaults)
    parameter = defaults{i}{1};
    if i>nargin | ( eval(['isnumeric(' parameter ') '])  &  ...
     eval(['any(isnan(' parameter ')) | isempty(' parameter ') ']) )
	eval([parameter '=defaults{i}{2};'])  
    end
end
if ischar(topology)
    topology = {topology,[1:ceil(order/2)]};
end

ntf_p = ntf.p{1};
ntf_z = ntf.z{1};

order2 = floor(order/2);
odd = order - 2*order2;

% compensate for limited accuracy of zero calculation
ntf_z(find(abs(ntf_z - 1) < eps^(1/(1+order)))) = 1;

if iscell(tdac)
    if size(tdac) ~= [order+1 1]
	msg = sprintf(['%s error. For cell array tdac, size(tdac) ' ...
	  'must be [order+1 1].\n'],  mfilename);
	error(msg);
    end
    if topology{1} ~= 'FB'
	msg = sprintf(['%s error. Currently only supporting topology{1}=''FB'' ' ...
	  'for cell-array tdac'], mfilename); 
	error(msg);
    end
else
    if size(tdac) ~= [1 2]
	error('For non cell array tdac, size(tdac) must be [1 2]');
    end
end
if isempty(bp)
    bp = zeros(1,order2);
end
if ~iscell(tdac)
    % Need direct terms for every interval of memory in the DAC
    n_direct = ceil(tdac(2))-1;
    if ceil(tdac(2)) - floor(tdac(1)) > 1
	n_extra = n_direct-1;     % tdac pulse spans a sample point
    else
	n_extra = n_direct;
    end
    tdac2 = [ -1 -1; 
	       tdac; 
	       0.5*ones(n_extra,1)*[-1 1] + cumsum(ones(n_extra,2),1)];
else
    n_direct = 0;
    n_extra = 0;
end

if isempty(ABCDc)
    ABCDc = zeros(order+1,order+2);
    % Stuff the A portion
    switch topology{1}
	case {'FB','FF','HFB'}
	    i1 = 1;
	    ir = 1;
	    ordering = topology{2};
	    if length(ordering) ~= order2 + odd
		msg = sprintf('Length of "ordering" should be %d rather than %d.\n', ...
		  order2+odd, length(ordering));
		error(msg);
	    end
	    for i = 1:length(ordering)
		if ordering(i)==1 && odd
		    ABCDc(i1+[0 1],i1) =[ real( log( ntf_z(1) ) ); 1 ];
		    i1 = i1+1;
		else
		    n = bp(ir);
		    zi = 2*ordering(i) - odd - 1;
		    s = log( ntf_z(zi) );
		    ABCDc(i1+[0 1 2],i1+[0 1]) =[ 2*real(s)  -norm(s)^2
						  1   0
						  n  1-n ];
		    i1 = i1+2;
		    ir = ir+1;
		end
	    end
	    ABCDc(abs(ABCDc)<1e-12) = 0;
	case {'LFFB','LFFF'}
	    % Start with all LP sections and all LF poles on jw-axis
	    subdiag = 2:order+2:order*(order+1);
	    ABCDc(subdiag) = 1;
	    supdiag = order+2:order+2:order*(order+1);
	    if order ~= 4
		error('LFxx only supports order=4 .\n');
	    end
	    w1 = abs( angle( ntf_z(1) ) );
	    w2 = abs( angle( ntf_z(3) ) );
	    a = w1*w2 * topology{2};
	    c = (w1*w2)^2/a;
	    b = w1^2 + w2^2 - a - c;
	    ABCDc(supdiag) = -[a b c];
	    Ac = ABCDc(1:order,1:order);
	otherwise
	    error(sprintf('%s error. Sorry, no A-stuffing code for topology{1} "%s".\n', ... 
		mfilename, topology{1}));
    end
    ABCDc(1,order+1) = 1;
    ABCDc(1,order+2) = -1;	% 2006-10-02: Changed to -1 to make FF STF have +ve gain at DC
end
Ac = ABCDc(1:order,1:order);
switch topology{1}
    case {'FB','LFFB','HFB'}
    Cc = ABCDc(order+1,1:order);
	if ~iscell(tdac)
	    Bc = [eye(order) zeros(order,1)];
	    Dc = [zeros(1,order) 1];
	    tp = repmat(tdac,order+1,1);
	else	% Assemble tdac2, Bc and Dc
	    tdac2 = [-1 -1];
	    Bc = [];
	    Dc = [];
	    Bci = [eye(order) zeros(order,1)];
	    Dci = [zeros(1,order) 1];
	    for i=1:length(tdac)
		tdi = tdac{i};
		if iscell(tdi)
		    for j=1:length(tdi)
			tdj = tdi{j};
			tdac2 = [tdac2; tdj];
			Bc = [Bc Bci(:,i)];
			Dc = [Dc Dci(:,i)];
		    end
		elseif ~isempty(tdi)
		    tdac2 = [tdac2; tdi];
		    Bc = [Bc Bci(:,i)];
		    Dc = [Dc Dci(:,i)];
		end
	    end
	    tp = tdac2(2:end,:);
        topology{1}
                 
    end
    if(strcmp(topology{1},'HFB'))
            %Bc(2,2)=0;
            Ac(4,2)=6.08; %Add ff path
    end
    case {'FF','LFFF'}
	Cc = [eye(order); zeros(1,order)];
   	Bc = [-1; zeros(order-1,1)]; 
	Dc = [zeros(order,1); 1];
	tp = tdac;	% 2008-03-24 fix from Ayman Shabra
    otherwise
	error(sprintf('%s error. Sorry, no code for topology{1} "%s".\n', ... 
	    mfilename, topology{1}));
end

Ac;
Bc;
Cc;
Dc;
% Sample the L1 impulse response
n_imp = ceil( 2*order + max(tdac2(:,2)) +1 );
y = impL1(ntf,n_imp);

sys_c = ss( Ac, Bc, Cc, Dc );
yy = pulse(sys_c,tp,1,n_imp,1);
yy = squeeze(yy);
% Endow yy with n_extra extra impulses.
% These will need to be implemented with n_extra extra DACs.
% !! Note: if t1=int, matlab says pulse(sys) @t1 ~=0
% !! This code corrects this problem.
if n_extra>0
    y_right = padb([zeros(1,n_extra+1); eye(n_extra+1)], n_imp+1);
    % Replace the last column in yy with an ordered set of impulses
    yy = [yy(:,1:end-1) y_right(:,end:-1:1)];
end

% Solve for the coefficients
x = yy\y;
if norm(yy*x-y) > 1e-4
    warning('Pulse response fit is poor.');
end
switch topology{1} 
    case {'FB','LFFB'}
	if ~iscell(tdac)
	    Bc2 = [ x(1:order) zeros(order,n_extra) ];
	    Dc2 = x(order+1:end).';
	else
	    BcDc = [Bc;Dc];
	    i = find(BcDc);
	    BcDc(i) = x;
	    Bc2 = BcDc(1:end-1,:);
	    Dc2 = BcDc(end,:);
    end
    case {'HFB'}
	if ~iscell(tdac)
	    Bc2 = [ x(1:order) zeros(order,n_extra) ];
	    Dc2 = x(order+1:end).';
	else
	    BcDc = [Bc;Dc];
	    i = find(BcDc);
	    BcDc(i) = x;
	    Bc2 = BcDc(1:end-1,:);
	    Dc2 = BcDc(end,:);
    end
    case {'FF','LFFF'}
	Bc2 = [Bc zeros(order,n_extra)];
	Cc = x(1:order).';
	Dc2 = x(order+1:end).';
    otherwise
	fprintf(1,'%s error. No code for topology{1} "%s".\n', mfilename, topology{1});
end
Dc1 = 0;
Dc = [Dc1 Dc2];
Bc1 = [1; zeros(order-1,1)];
if(strcmp(topology{1},'HFB'))
            Bc1 = [1; 0; zeros(order-2,1)];
    end
Bc = [Bc1 Bc2];
% Scale Bc1 for unity STF magnitude at f0
fz = angle(ntf.z{1})/(2*pi);
f1 = fz(1);
ibz = abs(fz-f1) <= abs(fz+f1);
fz = fz(ibz);
f0 = mean(fz);
if min(abs(fz)) < 3*min(abs(fz-f0))
    f0 = 0;
end
L0c = zpk(ss(Ac,Bc1,Cc,Dc1));
G0 = evalTFP(L0c,ntf,f0);
Bc(:,1) = Bc(:,1)/abs(G0);

ABCDc = [Ac Bc; Cc Dc];
