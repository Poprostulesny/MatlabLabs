function [A,b] = GenerateNotFriendlyHessenberg(size, opts)
% Generates random Hessenberg matrices which sattisfy the necessary
% solvability criterion, but take long to calculate
%   A=D+R
%   Bj = -D^(-1)*R
%   We first choose the matrix Bj with p(Bj)<1
%   Than R = -DBj
%   And therefore A = D-DBj=D(I-Bj)
% Input params:
% size - desired size of the square matrix
% (optional) opts - named field of optional values:
%       maxVal - absolute value of the biggest possible element in the matrix, defaults to 1e5
% Returns:
% A - Hessenberg Matrix, 
% b - RHS of equation, 

arguments
    size
    opts.maxVal = 1e5
end

d=1+rand(size,1);
D=diag(d);

%randomly choosing an upper or a lower matrix
if randi([0,1],1,1)==1
    B = tril(randn(size),1);
else
    B = triu(randn(size),-1);
end

%setting diagonal entries to zero
B(1:size+1:end)=0;

%forcing B to have rhoB<1
target_rhoB = 0.95+(0.999-0.95)*rand(1);
rhoB = max(abs(eig(B)));
if rhoB>target_rhoB
    B = target_rhoB*B/rhoB;
end
A = D*(eye(size)-B);

%losowanie b
b = randi([-opts.maxVal, opts.maxVal],size,1);
end
