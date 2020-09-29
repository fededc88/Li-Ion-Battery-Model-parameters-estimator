function flancos = flanks(Buff, percent)
%
% [flancos] = flanks(Buff, percent)
%
% Compara las muestras n y n+1 del arreglo [Buff]. Si la dife-
% rencia entre ellas es mayor al porcentaje [percent] indicado devuelve 1 
% o -1 en la posición n del arreglo flancos según el sentido del mismo.
%
% Buff   : Arreglo que se quieren identificar los flancos
% percent: Porcentaje de diferencia entre muentra n y n+1 para identificar 
%           un flanco. En valor debe estar entre 1 y 100. 
%

dif_pos = 1 + percent/100;  
dif_neg = 1 - percent/100;

for n = 1:(length(Buff)-1)
    
    if(Buff(n) >= 0)
        if(Buff(n) < Buff(n+1))
            if(Buff(n)*dif_pos < Buff(n+1))
                flancos(n) = 1;
            end
        else
            %si I_ensayo(n) > I_ensayo(n+1)
            if(Buff(n)*dif_neg> Buff(n+1))
                flancos(n) = -1;
            end
        end
    else
        % si I_ensayo(n) < 0
        if(Buff(n) < Buff(n+1))
            if(Buff(n)*dif_neg < Buff(n+1))
                flancos(n) = 1;
            end
        else
            %si I_ensayo(n) > I_ensayo(n+1)
            if(Buff(n)*dif_pos > Buff(n+1))
                flancos(n) = -1;
            end
        end
    end
end

 flancos(n+1) = 0;
 
 flancos = flancos';
 end
                