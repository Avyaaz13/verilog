[Q1,Q2,Q3,Q4,Q5] = Solution_code_2021_EX('EE2600_2021_EX4_DATA', 'QZ4_DS_G1_1');

function [Q1_sol,Q2_sol,Q3_sol,Q4_sol,Q5_sol] = Solution_code_2021_EX(IP_File_Name, File_Sheet)

mu_0=4*pi*(10^(-7));
eps_0=8.8541*(10^(-12));
%**************************************************************************
%Question 1
%**************************************************************************
data=xlsread(IP_File_Name,File_Sheet,'B3:B7');
r1=data(1)*(10^(-2))*exp(-0.25);
r2=data(2)*(10^(-2))*exp(-0.25);
r3=data(3)*(10^(-2))*exp(-0.25);
r4=data(4)*(10^(-2))*exp(-0.25);
D12=data(5);
D23=data(5);
D34=data(5);
D41=data(5);
D13=sqrt(2)*data(5);
D24=sqrt(2)*data(5);
I1=5000;
I2=10000;
I3=-7000;
I4=-(I1+I2+I3);

I=[I1 I2 I3 I4]';
L=1000*(mu_0/(2*pi))*[log(1/r1)  log(1/D12)  log(1/D13)  log(1/D41)
                 log(1/D12) log(1/r2)   log(1/D23)  log(1/D24)
                 log(1/D13) log(1/D23)  log(1/r3)   log(1/D34)
                 log(1/D41) log(1/D24)   log(1/D34)  log(1/r4)]; 

Q1_sol=abs(L*I);
%**************************************************************************
%Question 2
%**************************************************************************
data=xlsread(IP_File_Name,File_Sheet,'B11:B14');
r=data(1)*(10^(-2));
Ha=data(2);
Hb=data(3);
Hc=data(4);
Dab=(Hb-Ha)/cos(pi/4);
Dbc=(Hc-Hb)/cos(pi/4);
Dac=Dab+Dbc;
Daa_=2*Ha;
Dbb_=2*Hb;
Dcc_=2*Hc;
Dab_=sqrt((Dab*sin(pi/4))^2+(Daa_+0.5*(Dbb_-Daa_))^2);
Dbc_=sqrt((Dbc*sin(pi/4))^2+(Dbb_+0.5*(Dcc_-Dbb_))^2);
Dac_=sqrt((Dac*sin(pi/4))^2+(Daa_+0.5*(Dcc_-Daa_))^2);
P=(1/(2*pi*eps_0))*[log(Daa_/r)  log(Dab_/Dab) log(Dac_/Dac)
                    log(Dab_/Dab) log(Dbb_/r) log(Dbc_/Dbc)
                    log(Dac_/Dac) log(Dbc_/Dbc) log(Dcc_/r)];
C=inv(P)*(10^(12));
Q2_sol=zeros(6,1);
Q2_sol(1:3,1)=sum(C,2);
Q2_sol(4)=-C(1,2);
Q2_sol(5)=-C(2,3);
Q2_sol(6)=-C(3,1);
%**************************************************************************
%Question 3
%**************************************************************************
data=xlsread(IP_File_Name,File_Sheet,'B18:B21');

r=data(1)*(10^(-2));
d=data(2)*(10^(-2));
D12=data(3);
D23=data(4);
D31=D12+D23;

D1_1_1=(r*exp(-0.25)*d*d)^(1/3);
D1_2_1=(r*exp(-0.25)*d*d)^(1/3);
D1_3_1=(r*exp(-0.25)*d*d)^(1/3);
GMR=(D1_1_1*D1_2_1*D1_3_1)^(1/3);


D_1_1_2_1=D12;
D_1_1_2_2=sqrt(D12*D12+D12*d+d*d);
D_1_1_2_3=D12+d;
D_1_1_2=(D_1_1_2_1*D_1_1_2_2*D_1_1_2_3)^(1/3);

D_1_2_2_1=sqrt(D12*D12-D12*d+d*d);
D_1_2_2_2=D12;
D_1_2_2_3=sqrt(D12*D12+D12*d+d*d);
D_1_2_2=(D_1_2_2_1*D_1_2_2_2*D_1_2_2_3)^(1/3);

D_1_3_2_1=D12-d;
D_1_3_2_2=sqrt(D12*D12-D12*d+d*d);
D_1_3_2_3=D12;
D_1_3_2=(D_1_3_2_1*D_1_3_2_2*D_1_3_2_3)^(1/3);

GMD_1_2=(D_1_1_2*D_1_2_2*D_1_3_2)^(1/3);

D_2_1_3_1=D23;
D_2_1_3_2=sqrt(D23*D23+D23*d+d*d);
D_2_1_3_3=D23+d;
D_2_1_3=(D_2_1_3_1*D_2_1_3_2*D_2_1_3_3)^(1/3);

D_2_2_3_1=sqrt(D23*D23-D23*d+d*d);
D_2_2_3_2=D23;
D_2_2_3_3=sqrt(D23*D23+D23*d+d*d);
D_2_2_3=(D_2_2_3_1*D_2_2_3_2*D_2_2_3_3)^(1/3);

D_2_3_3_1=D23-d;
D_2_3_3_2=sqrt(D23*D23-D23*d+d*d);
D_2_3_3_3=D23;
D_2_3_3=(D_2_3_3_1*D_2_3_3_2*D_2_3_3_3)^(1/3);

GMD_2_3=(D_2_1_3*D_2_2_3*D_2_3_3)^(1/3);

D_3_1_1_1=D31;
D_3_1_1_2=sqrt(D31*D31+D31*d+d*d);
D_3_1_1_3=D31+d;
D_3_1_1=(D_3_1_1_1*D_3_1_1_2*D_3_1_1_3)^(1/3);

D_3_2_1_1=sqrt(D31*D31-D31*d+d*d);
D_3_2_1_2=D31;
D_3_2_1_3=sqrt(D31*D31+D31*d+d*d);
D_3_2_1=(D_3_2_1_1*D_3_2_1_2*D_3_2_1_3)^(1/3);

D_3_3_1_1=D31-d;
D_3_3_1_2=sqrt(D31*D31-D31*d+d*d);
D_3_3_1_3=D31;
D_3_3_1=(D_3_3_1_1*D_3_3_1_2*D_3_3_1_3)^(1/3);

GMD_3_1=(D_3_1_1*D_3_2_1*D_3_3_1)^(1/3);

GMD=(GMD_1_2*GMD_2_3*GMD_3_1)^(1/3);

Q3_sol=[GMR*100
        GMD];
%**************************************************************************
%Question 4
%**************************************************************************
data=xlsread(IP_File_Name,File_Sheet,'B25:B28');
R=data(1)*(10^(-3));
L=data(2)*(10^(-3));
G=data(3)*(10^(-9));
C=data(4)*(10^(-9));
z_se=R+j*100*pi*L;
y_sh=G+j*100*pi*C;
gamma=sqrt(z_se*y_sh);
Zc=sqrt(z_se/y_sh);

V_S=400/sqrt(3);
I_R=V_S/(Zc*(cosh(500*gamma)+sinh(500*gamma)));
V_R=I_R*Zc;
S=3*V_R*conj(I_R);
Q4_sol=[real(S)
        imag(S)];
%**************************************************************************
%Question 5
%**************************************************************************
data=xlsread(IP_File_Name,File_Sheet,'B32:B35');
V_Smag=data(1)/sqrt(3);
del_S=data(2)-(pi/6);
V_Rmag=data(3)/sqrt(3);
del_R=data(4)-(pi/6);
beta=100*pi*sqrt(L*C);
Zn=sqrt(L/C);

V_S=V_Smag*exp(j*del_S);
V_R=V_Rmag*exp(j*del_R);
I_R=(V_S-V_R*cos(500*beta))/(j*Zn*sin(500*beta));
V_m=V_R*cos(250*beta)+j*Zn*sin(250*beta)*I_R;

Q5_sol=[sqrt(3)*abs(V_m)
        angle(V_m)+(pi/6)];


return;
end