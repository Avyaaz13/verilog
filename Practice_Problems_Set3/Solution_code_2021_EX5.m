[Q1_sol,Q2_sol,Q3_sol,Q4_sol] = Solution_code_2021_EX('EE2600_2021_EX5_DATA', 'QZ5_DS_G1_1');
function [Q1_sol,Q2_sol,Q3_sol,Q4_sol] = Solution_code_2021_EX(IP_File_Name, File_Sheet)

%**************************************************************************
%Question 1
%**************************************************************************
data=xlsread(IP_File_Name,File_Sheet,'B3:B7');
k1=data(1);
k2=data(2);
c1=data(3);
c2=data(4);
c3=data(5);
flag=zeros(4,1);
x_sol=zeros(4,1);
y_sol=zeros(4,1);
z_sol=zeros(4,1);

u=-(1/(4*k1));
v=-(1/(4*k2));

%Case1: Assume that both the inequality constraints are inactive
lambda=0;
x_sol(1)=nthroot(u*lambda,3);
y_sol(1)=nthroot(v*lambda,3);
z_sol(1)=c1;

if (z_sol(1)>=c2)&((2*x_sol(1)-3*y_sol(1))>=c3)
    flag(1)=1;
end

%Case2: Assume that only the first inequality constraint is active
u=nthroot(u,3);
v=nthroot(v,3);

lambda_cr=((c1-c2)/(u+v));
x_sol(2)=u*lambda_cr;
y_sol(2)=v*lambda_cr;
z_sol(2)=c2;
mu1_cr=lambda_cr;

if (mu1_cr>=0)&((2*x_sol(2)-3*y_sol(2))>=c3)
    flag(2)=1;
end

%Case3: Assume that only the second inequality constraint is active

u=u*nthroot(-2,3);
v=v*nthroot(3,3);
mu2_cr=(c3/(2*u-3*v));
x_sol(3)=u*mu2_cr;
y_sol(3)=v*mu2_cr;
z_sol(3)=c2-x_sol(3)-y_sol(3);

if (mu2_cr>=0)&(z_sol(3)>=c2)
    flag(3)=1;
end
%Case4: Assume that both the inequality constraints are active

A=[1 1 1
   0 0 1
   2 -3 0];
h=[c1
   c2
   c3];
sol=inv(A)*h;
x_sol(4)=sol(1);
y_sol(4)=sol(2);
z_sol(4)=sol(3);

A=[1 0 -2
   1 0 3
   1 -1 0];

h=[-4*k1*x_sol(4)*x_sol(4)*x_sol(4)
   -4*k2*y_sol(4)*y_sol(4)*y_sol(4)
   0];

sol=inv(A)*h;
mu1=sol(2);
mu2=sol(3);

if (mu1>=0)&(mu2>=0)
    flag(4)=1;
end

for k=1:4
    if flag(k)==1
        Q1_sol=[x_sol(k)
                y_sol(k)
                z_sol(k)];
         break;
    end
end
%**************************************************************************
%Question 2
%**************************************************************************
data=xlsread(IP_File_Name,File_Sheet,'B11:B16');
c1=data(1);
c2=data(2);
c3=data(3);
x=data(4);
y=data(5);
z=data(6);

for iter=1:2
    x0=x;
    y0=y;
    z0=z;
    x=cos(x0)-x0+y0*sin(z0)+c1;
    y=sin(x0+y0)+y0+cos(z0)+c2;
    z=cos(x0)+sin(2*y0)+cos(3*z0)+c3;
    x=x0+0.9*(x-x0);
    y=y0+0.9*(y-y0);
    z=z0+0.9*(z-z0);
end
Q2_sol=[x y z]';

%**************************************************************************
%Question 3
%**************************************************************************
data=xlsread(IP_File_Name,File_Sheet,'B20:B25');
c1=data(1);
c2=data(2);
c3=data(3);
x=data(4);
y=data(5);
z=data(6);

for iter=1:2
    
    er=[c1-(x*x+y*z+y)
        c2-(x+x*y+x*y*z)
        c3-(x*y+y+z)];
    J=[2*x      1+z       y
       1+y+y*z  x+x*z     x*y
       y        1+x       1];
    dvar=inv(J)*er;
    x=x+dvar(1);
    y=y+dvar(2);
    z=z+dvar(3);
end
Q3_sol=[x y z]';
%**************************************************************************
%Question 4
%**************************************************************************
 data=xlsread(IP_File_Name,File_Sheet,'B30:D34');
 a=data(:,1);
 b=data(:,2);
 c=data(:,3);  
 data=xlsread(IP_File_Name,File_Sheet,'B38:B62');
 B=[data(1:5)'
    data(6:10)' 
    data(11:15)'
    data(16:20)'
    data(21:25)'];
 data=xlsread(IP_File_Name,File_Sheet,'E38:E42');
 B0=data;
 data=xlsread(IP_File_Name,File_Sheet,'H38:H38');
 B00=data;
 
 numerator=2000;
 denominator=0;
 for k=1:5
     numerator=numerator+0.5*(b(k)/a(k));
     denominator=denominator+0.5*(1/a(k));    
 end
 lambda=numerator/denominator;
 
 Pg=zeros(5,1);
 
 for k=1:5
     Pg(k)=(lambda-b(k))/(2*a(k));
 end

 for iter=1:2
     Ploss=Pg'*B*Pg+B0'*Pg+B00;
     dPlossdPg=B0'+2*Pg'*B';
     J11=2*(diag(a)+lambda*B);
     J12=dPlossdPg'-ones(5,1);
     J21=-J12';
     J22=0;
     J=[J11 J12
        J21 J22];     
     er=[-lambda*J12-diag(a)*Pg-b
         2000+Ploss-ones(1,5)*Pg];
     dvar=inv(J)*er;    
     Pg=Pg+dvar(1:5);     
 end
 
 Q4_sol=[Pg
         a'*(Pg.*Pg)+b'*Pg+ones(1,5)*c];
%**************************************************************************
%Question 5
%**************************************************************************
bus_no=6;
line_no=9;
[bus_data, bus_type]=xlsread(IP_File_Name,File_Sheet,'A67:F72');
bus_name={'A'
          'B'
          'C'
          'D'
          'E'
          'F'};
 for k=1:6
     if strcmp(bus_type{k},'Slack')==1
         bus_data(k,1)=0;
     elseif strcmp(bus_type{k},'P-Q')==1
         bus_data(k,1)=1;
     else   
         bus_data(k,1)=2;
     end
 end
 
line_data=xlsread(IP_File_Name,File_Sheet,'D76:F84');
line_name={'Ln1' 'A' 'B'
           'Ln2' 'B' 'C'
           'Ln3' 'C' 'D'
           'Ln4' 'D' 'A'
           'Ln5' 'D' 'B'
           'Ln6' 'A' 'E'
           'Ln7' 'C' 'E'
           'Ln8' 'B' 'F'
           'Ln9' 'D' 'F'};
       


% [Sol,iter] = FDLF(bus_no,line_no,bus_data, bus_name, line_data, line_name,0, 2,1);
%  Q5_sol=[Sol.V(:,2)
%          Sol.DEL(:,2)];


return;
end