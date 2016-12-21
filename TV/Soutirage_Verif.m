function [Verif] = Soutirage_Verif(n_souti,etat6_n,etat7,etat7_n,etat8,etat9_n,h9_0)
%Verifie si on a resolu le systeme d'équations

sys1 = zeros(n_souti);
sys2 = zeros(n_souti,1);

sys1(1,1) =  sys1(1,1) + etat6_n(1).h - etat7_n(1).h;
sys2(1) = etat9_n(1).h - h9_0;

if n_souti >= 4
    
    for i = 2:3
        sys1(i,i) = sys1(i,i) + etat6_n(i).h - etat7_n(i).h;
        sys2(i) = etat9_n(i).h - etat9_n(i-1).h;
        for j = 1:3
            sys1(i,j) = sys1(i,j) - (etat9_n(i).h - etat9_n(i-1).h);
        end
    end
    for i = 1:3
        sys1(1,i) = sys1(1,i) - (etat9_n(1).h - h9_0);
    end
    for i = 1:2
        for j = i+1:3
            sys1(i,j) = sys1(i,j) + etat7_n(i+1).h - etat7_n(i).h;
        end
    end
    for i = 1:3
        sys1(4,i) = sys1(4,i) - (etat7_n(4).h - etat9_n(3).h);
    end
    sys1(4,4) = sys1(4,4) + etat6_n(4).h - etat7_n(4).h;
    sys2(4) = etat7_n(4).h - etat9_n(3).h;
    for i = 4:n_souti-1
        for j = i+1 : n_souti
            sys1(i,j) = sys1(i,j) + etat7_n(i+1).h - etat7_n(i).h;
        end
    end
    for i = 5:n_souti
        sys1(i,i) = sys1(i,i) + etat6_n(i).h - etat7_n(i).h;
        sys2(i) = etat9_n(i).h - etat9_n(i-1).h;
        for j = 1:n_souti
            sys1(i,j) = sys1(i,j) - (etat9_n(i).h - etat9_n(i-1).h);
        end
    end
    
else
    
    for i = 2:n_souti
        sys1(i,i) = sys1(i,i) + etat6_n(i).h - etat7_n(i).h;
        sys2(i) = etat9_n(i).h - etat9_n(i-1).h;
        for j = 1:n_souti
            sys1(i,j) = sys1(i,j) - (etat9_n(i).h-etat9_n(i-1).h);
        end
    end
    for i = 1:n_souti
        sys1(1,i) = sys1(1,i) - (etat9_n(1).h - h9_0);
    end
    for i = 1:n_souti-1
        for j = i+1:n_souti
            sys1(i,j) = sys1(i,j) + etat7_n(i+1).h - etat7_n(i).h;
        end
    end
    
end

X = sys1\sys2;

if n_souti >= 4
    Verif = sum(X(1:3))*(etat7_n(1).h-etat7.h) - (h9_0-etat8.h)*(1+sum(X(1:3)));
else
    Verif = sum(X)*(etat7_n(1).h-etat7.h) - (h9_0-etat8.h)*(1+sum(X));
end

end