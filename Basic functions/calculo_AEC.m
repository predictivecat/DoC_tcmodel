function AEC = calculo_AEC(signal1)
%CALCULOAEC Funcion que calcula la correlacion de la envolvente de amplitud de dos
%senyales
%   Variables de entrada:
%   signal1, signal2: senyales sobre las que se va a calcular el parametro
%   Variables de salida:
%   AEC: correlacion de amplitud de envolvente. 
%   Por tanto, es un vector de nChannels elementos (un valor por
%   canal)

%% Creamos el vector de salida con las correlaciones
signal2 = signal1;
AEC=NaN(1,size(signal1,2));

% Calculamos el logaritmo de la
% envolvente al cuadrado (power envelope). En un bucle lo hacemos banda por
% banda
% En Matlab 2012 no tenemos envelope, asi que usamos Hilbert para
% calcular la senyal analitica y la sacamos a partir de ahi

hilb1 = hilbert(signal1(:,:));
hilb2 = hilbert(signal2(:,:));
envelope1 = squeeze(abs(hilb1));
envelope2 = squeeze(abs(hilb2));
% env1=log(envelope1.^2);
% env2=log(envelope2.^2);
env1 = envelope1;
env2 = envelope2;

% Ahora calculamos la correlacion lineal entre las dos envolventes
AEC = corr(env1,env2);
end
