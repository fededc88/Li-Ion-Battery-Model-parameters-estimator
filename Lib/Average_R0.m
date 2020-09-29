function R0 = Average_R0(I_ensayo,V_ensayo)

% R0 = Average_R0(Current)
%
% La función calcula el parámetro R0 del modelo como un promedio de todos
% los R0(i) calculados en cada escalon de corriente del ensayo.
%
% I_en: Perfil de descarga del test HPPC
% V_en: Perfil de voltage del test HPPC
%
%         Vmax(i)-Vmin(i)
% R0(i) = --------------
%         Imax(i)-Imin(i)
%
% R0 = Sum(R0(i))/n
%
% Solo detecta flancos de corriente descendentes. En caso de contar con un 
% ensayo HPPC con pulsos de carda tendrémos que editarla

i = 1;
R0 = 0;

flancos = flanks(I_ensayo, 50);

for n = 1:(length(I_ensayo))
    
    if (flancos(n) == -1)
        %hay un flanco descendente
        Vmax(i)= V_ensayo(n);
        Vmin(i)= V_ensayo(n+1); 
        Imin(i)= I_ensayo(n+1);
        Imax(i)= I_ensayo(n);
        i=i+1;
    end

end

Vdif = Vmax-Vmin;
Idif = Imax-Imin;

for i = 1: length(Vmax)
   R0 = R0 + Vdif(i)/Idif(i);  
end

R0 = R0/i;

end
