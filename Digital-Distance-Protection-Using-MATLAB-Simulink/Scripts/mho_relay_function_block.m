function [trip1,trip2,trip3,cb_cmd,Rz,Xz] = mho_relay(v,i)
%#codegen
N = 100; Ts = 0.0002;
kN = complex(1.15605303,-0.374458535);
th = 1.5274254;
Zr = [23.4885284 35.2327926 44.0409908];
Tz = [0 0.3 0.6];
persistent bv bi n t2 t3 l1 l2 l3
if isempty(bv)
    bv = zeros(N,3); bi = zeros(N,3); n = 0; t2 = 0; t3 = 0;
    l1 = false; l2 = false; l3 = false;
end
trip1 = double(l1); trip2 = double(l2); trip3 = double(l3);
cb_cmd = double(~(l1 || l2 || l3));
Rz = NaN; Xz = NaN;
bv = [bv(2:end,:); reshape(v,1,3)];
bi = [bi(2:end,:); reshape(i,1,3)];
n = min(n + 1, N);
if n < N
    return;
end
w  = exp(-1j*2*pi*(0:N-1)'/N);
V  = (sqrt(2)/N)*(bv.'*w);
I  = (sqrt(2)/N)*(bi.'*w);
Ir = I(1)+I(2)+I(3);
Vl = [V(1); V(2); V(3); V(1)-V(2); V(2)-V(3); V(3)-V(1)];
Il = [I(1)+kN*Ir; I(2)+kN*Ir; I(3)+kN*Ir; I(1)-I(2); I(2)-I(3); I(3)-I(1)];
Z  = complex(1e6*ones(6,1),0);
for k = 1:6
    if abs(Il(k)) > 50
        Z(k) = Vl(k)/Il(k);
    end
end
[zm,idx] = min(abs(Z));
if zm < 1e5
    Rz = real(Z(idx)); Xz = imag(Z(idx));
end
in1 = false; in2 = false; in3 = false;
for k = 1:6
    in1 = in1 || (abs(Z(k) - 0.5*Zr(1)*exp(1j*th)) < 0.5*Zr(1));
    in2 = in2 || (abs(Z(k) - 0.5*Zr(2)*exp(1j*th)) < 0.5*Zr(2));
    in3 = in3 || (abs(Z(k) - 0.5*Zr(3)*exp(1j*th)) < 0.5*Zr(3));
end
if in2, t2 = t2 + Ts; else, t2 = 0; end
if in3, t3 = t3 + Ts; else, t3 = 0; end
if in1 && Tz(1) <= 0, l1 = true; end
if in2 && t2 >= Tz(2), l2 = true; end
if in3 && t3 >= Tz(3), l3 = true; end
trip1 = double(l1); trip2 = double(l2); trip3 = double(l3);
cb_cmd = double(~(l1 || l2 || l3));
end