function [A,b] = GenerateRandomHessenberg(size, opts)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
arguments
    size
    opts.maxVal = 1e3
end

A=randi([-opts.maxVal, opts.maxVal],size,size);

if randi([0,1],1,1)==1
    A = tril(A,1);%lower hessenberg
else
    A = triu(A,-1);%upper hessenberg
end
while rcond(A)<1e-10
    A=randi([-opts.maxVal, opts.maxVal],size,size);

    if randi([0,1],1,1)==1
        A = tril(A,1);%lower hessenberg
    else
        A = triu(A,-1);%upper hessenberg
    end
end
%losowanie b
b = randi([-opts.maxVal, opts.maxVal],size,1);
end
