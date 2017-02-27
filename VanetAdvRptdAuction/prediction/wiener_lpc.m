function [a] = wiener_lpc(x, N)

% >>>> FOR DEBUG
% N = 10;
% x = sin(2*pi*0.05*[0:2*N-1])+randn(1,2*N)*0.05;

x = x(end-2*N+1:end);

XMat = zeros(N);

for indX = 1:N
    XMat(indX,:) = fliplr(x(indX+[0:N-1]));
end

bMat(1:N-1) = XMat(2:end, 1);bMat(N) = x(2*N);
Rxx = XMat.'*XMat;Rdx = XMat.'*bMat.';
a = inv(Rxx)*Rdx;

% %>>>> FOR DEBUG
% a2 = lpc(x, N);
% y = filter(a, 1, x);
% y2 = filter(-a(2:end), 1, x);
% figure(1);plot([x;y;y2].');legend('x','mylpc','matlablpc');
