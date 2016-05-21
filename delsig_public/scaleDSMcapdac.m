function dsm = scaleDSM( dsm, n_sigma, f, a )
% dsm = scaleDSM( dsm, n_sigma=5, f=linspace(0,0.5,200), a=1 ) 
% Perform dynamic-range scaling on a DT delta-sigma modulator
% using an analytical method.
%
%Inputs
% dsm a struct containing the following fields
%   ABCDu
%   M
%   f0=0
%   quadrature=0
%
% n_sigma   Multiplier for converting rms to peak
% f         Input frequencies
% a         Input amplitudes relative to full-scale. !!! Default should be min(1,1/stf)
%
% Output
% The following fields get added to the dsm struct
%   ABCD    ABCDu scaled for unit swing
%   scale   Scale factors for converting ABCDu to ABCD 

% Argument checking and default-setting 
ArgumentsAndDefaults = {
  'dsm', NaN 
  'n_sigma', 3
  'f', []
  'a', 1 
  };
for i = 1:size(ArgumentsAndDefaults,1)
    parameter = ArgumentsAndDefaults{i,1};
    if i>nargin || ( eval(['isnumeric(' parameter ') '])  &&  ...
     eval(['any(isnan(' parameter ')) | isempty(' parameter ') ']) )
        if isnan(ArgumentsAndDefaults{i,2})
            error('%s: Argument %d (%s) is required.',mfilename, i, parameter )
        else
            eval([parameter '= ArgumentsAndDefaults{i,2};'])
        end
    end
end
% Extract the specified fields. If unset, set to their defaults.
FieldsAndDefaults = { 
  'ABCDu', NaN
  'M', NaN
  'f0', 0
  'quadrature', 0
  };
for i = 1:size(FieldsAndDefaults,1)
    parameter = FieldsAndDefaults{i,1};
    if ~isfield(dsm,parameter )
        if isnan(FieldsAndDefaults{i,2})
            error('%s: The dsm argument must contain a field named ''%s''.', ...
                mfilename, parameter)
        else
            dsm.(parameter) = FieldsAndDefaults{i,2};
        end
    end
    eval([parameter '=dsm.(parameter);'])
end
if isempty(f)
    if ~quadrature
        f = linspace(0,0.5,200);
    else
        f = linspace(-0.5,0.5,400);
    end
end
if size(a)==1
    a = repmat(a,1,length(f));
end
size(a)
order = size(ABCDu,2) - 2

[A B C D]= partitionABCD(ABCDu,2)
% See page 23 of ADI Notebook #36
B1 = B(:,1); B2 = B(:,2);
D1 = D(end,1); %D2 = D(:,2);
Ap = A + B2*C(end,:);
Bp = [B1 + B2*D1 B2]
sys = ss(Ap,Bp,[C;zeros(1,order)],[D;zeros(1,2)],1);
F = freqresp(sys,2*pi*f);
F1_max = max( abs(squeeze(F(:,1,:)) .* repmat(a,order,1)), [], 2 );
F2_2  = sqrt( mean( abs(squeeze(F(:,2,:))).^2,  2 ) );
sigma_e = sqrt(1/3);

scale = 1 ./ (M*F1_max + n_sigma*sigma_e*F2_2);
S = diag(scale); Sinv = diag(1./scale); % xs = scale .* x;
[A B C D]= partitionABCD(ABCDu,2);
ABCD = [S*A*Sinv S*B; C*Sinv D];
dsm.scale = scale;
dsm.ABCD = ABCD;


figure(1); clf
u = linspace(0,1);
for i = 1:order
    subplot(order,1,i);
    hold on;
    plot(u, F1_max(i)*M*u, 'g');
    plot(u, F1_max(i)*M*u, 'g');
    plot(u, M*F1_max(i)*u + n_sigma*sigma_e*F2_2(i) );
end
figure(2); clf

for i = 1:order
    subplot(order,1,i);
    hold on;
    plot(f,M.*a'.*abs(squeeze(F(i,1,:))),'b');
    plot(f,n_sigma*sigma_e*abs(squeeze(F(i,2,:))),'r');
    grid on;
end
xlabel('Normalized Frequency');
%{
hold on;
plot(f,abs(C*squeeze(F(:,1,:))),'g', 'Linewidth',4);    % STF
plot(f,abs(C*squeeze(F(:,2,:))+1),'g', 'Linewidth',4);    % NTF
[ntf, stf] = calculateTF(ABCDu);
plot(f,abs(evalTF(ntf,exp(2i*pi*f))),'m', 'Linewidth',1);
plot(f,abs(evalTF(stf,exp(2i*pi*f))),'m', 'Linewidth',1);
%}
%}
return
