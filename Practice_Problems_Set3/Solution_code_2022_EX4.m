[Q1,Q2,Q3,Q4,Q5] = Solution_code_2022_EX('EE2600_2022_EX4_DATA', 'EXAM4_DS_A');

disp('--- Question 1 Solution: Capacitances ---');
disp(['C_pp: ', num2str(Q1(1)), ' μF']);
disp(['C_p0: ', num2str(Q1(2)), ' μF']);

disp('--- Question 2 Solution: Sending End Power ---');
disp(['Active Power (P_S): ', num2str(Q2(1)), ' W']);
disp(['Reactive Power (Q_S): ', num2str(Q2(2)), ' VAR']);

disp('--- Question 3 Solution: Generator Schedule and Cost ---');
for i = 1:4
    disp(['Generator ', num2str(i), ' Output: ', num2str(Q3(i)), ' MW']);
end
disp(['Total Cost: ', num2str(Q3(5)), ' $']);

disp('--- Question 4 Solution: Line Losses and Voltage ---');
disp(['Active Power Loss: ', num2str(Q4(1)), ' W']);
disp(['Reactive Power Loss: ', num2str(Q4(2)), ' VAR']);
disp(['Receiving End Voltage Magnitude: ', num2str(Q4(3)), ' pu']);

disp('--- Question 5 Solution: Nonlinear Equations ---');
disp(['x after iteration 1: ', num2str(Q5(1))]);
disp(['y after iteration 1: ', num2str(Q5(2))]);
disp(['x after iteration 2: ', num2str(Q5(3))]);
disp(['y after iteration 2: ', num2str(Q5(4))]);


function [Q1_sol,Q2_sol,Q3_sol,Q4_sol,Q5_sol] = Solution_code_2022_EX(IP_File_Name, File_Sheet)

%**************************************************************************
%Question 1
%**************************************************************************
data=xlsread(IP_File_Name,File_Sheet,'B3:B5');
r=data(1)*0.01;%Radius
H=data(2);%Height
D=data(3);%Center-to-center distance

%Let us first calculate the distance between two conductors over a
%particular transposition section
D_a1a2=2*H;% Distance between a-phase conductor and its image;
D_b1b2=2*H;% Distance between b-phase conductor and its image;
D_c1c2=2*H;% Distance between c-phase conductor and its image;

D_a1b1=D; % Distance between a-phase and b-phase conductors;
D_b1c1=D; % Distance between b-phase and c-phase conductors;
D_c1a1=2*D; % Distance between c-phase and a-phase conductors;

D_a2b2=D; % Distance between the images of a-phase and b-phase conductors;
D_b2c2=D; % Distance between the images of b-phase and c-phase conductors;
D_c2a2=2*D; % Distance between the images of c-phase and a-phase conductors;

D_a1b2=sqrt(D*D+4*H*H); % Distance between the a-phase conductor and the image of b-phase conductor;
D_b1c2=sqrt(D*D+4*H*H); % Distance between the b-phase conductor and the image of c-phase conductor;
D_c1a2=sqrt(4*D*D+4*H*H); % Distance between the c-phase conductor and the image of a-phase conductor;

D_a2b1=sqrt(D*D+4*H*H); % Distance between the b-phase conductor and the image of a-phase conductor;
D_b2c1=sqrt(D*D+4*H*H); % Distance between the c-phase conductor and the image of b-phase conductor;
D_c2a1=sqrt(D*D+4*H*H); % Distance between the a-phase conductor and the image of c-phase conductor;

% Next, we will calculate different GMD values for the full-length of the
% transmission line

GMD_a1a2=nthroot(D_a1a2*D_b1b2*D_c1c2,3);
GMD_b1b2=nthroot(D_a1a2*D_b1b2*D_c1c2,3);
GMD_c1c2=nthroot(D_a1a2*D_b1b2*D_c1c2,3);

GMD_a1b1=nthroot(D_a1b1*D_b1c1*D_c1a1,3);
GMD_b1c1=nthroot(D_a1b1*D_b1c1*D_c1a1,3);
GMD_c1a1=nthroot(D_a1b1*D_b1c1*D_c1a1,3);

GMD_a2b2=nthroot(D_a2b2*D_b2c2*D_c2a2,3);
GMD_b2c2=nthroot(D_a2b2*D_b2c2*D_c2a2,3);
GMD_c2a2=nthroot(D_a2b2*D_b2c2*D_c2a2,3);

GMD_a1b2=nthroot(D_a1b2*D_b1c2*D_c1a2,3);
GMD_b1c2=nthroot(D_a1b2*D_b1c2*D_c1a2,3); 
GMD_c1a2=nthroot(D_a1b2*D_b1c2*D_c1a2,3);

GMD_a2b1=nthroot(D_a2b1*D_b2c1*D_c2a1,3);
GMD_b2c1=nthroot(D_a2b1*D_b2c1*D_c2a1,3);
GMD_c2a1=nthroot(D_a2b1*D_b2c1*D_c2a1,3);

eps_0=8.8541*(10^(-12));

A=[log(GMD_a1a2/r)         log(GMD_a2b1/GMD_a1b1)      log(GMD_c1a2/GMD_c1a1)
   log(GMD_a1b2/GMD_a1b1)  log(GMD_b1b2/r)             log(GMD_b2c1/GMD_b1c1)
   log(GMD_c2a1/GMD_c1a1)  log(GMD_b1c2/GMD_b1c1)      log(GMD_c1c2/r)];

C=2*pi*eps_0*500000*inv(A);
C_pp=-C(1,2)/0.000001;
C_p0=sum(C(1,:))/0.000001;

Q1_sol=[C_pp C_p0]';
%**************************************************************************
%Question 2
%**************************************************************************
data=xlsread(IP_File_Name,File_Sheet,'B9:B14');
l=data(1)*0.001;% Series inductance per unit length
r=data(2)*0.001;% Series resistance per unit length
c=data(3)*0.000000001;%Shunt capacitance per unit length
g=data(4)*0.000000001;% Shunt conductance per unit length
V_R_mag=data(5);% Receiving end voltage magnitude
I_R_mag=data(6);% Receiving end current magnitude

z_se=r+1i*100*pi*l;%Series impedance per unit length at 50 Hz
y_sh=g+1i*100*pi*c; % Shunt admittance per unit length at 50 Hz

%Let us then calculate the characteristic impedance and the propagation
%constant
Zc=sqrt(z_se/y_sh);
gamma=sqrt(z_se*y_sh);

%The load voltage, load current and load power factor is given. Without losing
%generality, the receiving end voltage angle can be set to zero. Subsequenly, 
%we can easily determine the receiving end voltage and current phasors 

V_R=V_R_mag;
I_R_ang=acos(0.8);
I_R=I_R_mag*exp(1i*I_R_ang);

%Next, we will calculate the sending end voltage and current phasors by
%using transmission line characteristic equations

V_S=V_R*cosh(gamma*500)+I_R*Zc*sinh(gamma*500);
I_S=(V_R/Zc)*sinh(gamma*500)+I_R*cosh(gamma*500);

% Finally, we will calculate the active power and reactive power at the
% sending end
S=3*V_S*conj(I_S);
P_S=real(S);
Q_S=imag(S);

Q2_sol=[P_S Q_S]';
%**************************************************************************
%Question 3
%**************************************************************************
data=xlsread(IP_File_Name,File_Sheet,'B18:F21');
a=data(:,1);%Quadratic cost coefficients of generators
b=data(:,2);%Linear cost coeffients of generators
c=data(:,3);% Fixed costs of generators
P_max=data(:,4);% Maximum power production limits of generators
P_min=data(:,5);% Minimum power production limits of generators
P_sch=zeros(4,1);

% The variable cost associated with Generator 4 is zero. Moreover, its loss
% contribution is also zero. Therefore, its output should be first
% maximized without creating the possibility of the minimum generation
% limit violation for other generators. For the given data, we can
% comfortably set the power generation of Generator 1 to its upper limit as
% the sum of the minimum limits of other generators is still lower than the
% remaining load.

P_sch(4)=P_max(4);

%Subsequently, we have to solve the following optimization problem
%Minimize sum(a(1:3).*Pg(1:3).*Pg(1:3))+sum(b(1:3).*Pg(1:3))+sum(c(1:3))
% Subjected to,
% sum(Pg(1:3))=3000+0.03*sum(Pg(1:3))-P_max(4)
%Pg(1:3)<=P_max(1:3)
%Pg(1:3)>=P_min(1:3)

sch_ind=[4];% Set of generators whose outputs have been fixed
nsch_ind=[1 2 3]; % Set of generators whose outputs are still to be decided
eta=1/(1-0.03);

for iter=1:3% We need to run multiple iterations to fix the limit violations
%Let us first eliminate the generators that have already been scheduled to
%operate at their upper or lower limits  
      P_D=3000-P_max(4);
      Nsch=size(sch_ind,2);
      for g=1:(Nsch-1)
          l=sch_ind(g);
          P_D=P_D-(1/eta)*P_sch(l);
      end
% We will now apply the KKT stationary condition and the power balance condition
% to determine the outputs of unscheduled generators
      Nnsch=4-Nsch;
      L_num=P_D;
      L_den=0;
      for g=1:Nnsch
          l=nsch_ind(g);
          L_num=L_num+(b(l)/a(l))*(0.5/eta);
          L_den=L_den+(0.5/a(l))*(1/eta)*(1/eta);         
      end  
      L=L_num/L_den;% The optimal value of the Lagrangian multiplier for the present iteration
      P_temp=zeros(Nnsch,1);
         
      for g=1:Nnsch
          l=nsch_ind(g);
          P_temp(g)=(0.5/a(l))*(L/eta)-0.5*(b(l)/a(l));%Optimal outputs of generators for the present iteration
      end
% Let us check the limit violation and fix it. For the given problem, there should be either upper limit violation or lower
%limit violation at a time.
      flag=0;% It indicates if there is a limit violation
      for g=1:Nnsch
          l=nsch_ind(g);
          if P_temp(g)>P_max(l)
              P_sch(l)=P_max(l);
              sch_ind=union(sch_ind,l);
              flag=1;
          elseif P_temp(g)<P_min(l)
              P_sch(l)=P_min(l);
              sch_ind=union(sch_ind,l);              
              flag=1;
          end
      end
      nsch_ind=setdiff(nsch_ind,sch_ind);
      if flag==0
          break;
      end
end

for g=1:Nnsch
    l=nsch_ind(g);
    P_sch(l)=P_temp(g);
end

cost=sum(a(1:4).*P_sch(1:4).*P_sch(1:4))+sum(b(1:4).*P_sch(1:4))+sum(c(1:4));
  
Q3_sol=[P_sch
        cost];

%**************************************************************************
%Question 4
%**************************************************************************
data=xlsread(IP_File_Name,File_Sheet,'B25:B29');

Rse=data(1);% Total series resistance of the transmission line
Xse=data(2); % Total series reactance of the transmission line
Bsh=data(3); % Total shunt susceptance of the transmission line
P_R=-data(4); % Active power load at the receiving end
Q_R=-data(5); % Reactive power load at the receiving end

% We will mark the receiving end bus as Bus 1 and the sending end bus as
% Bus 2. Moreover, Bus 2 is the slack as well as angle reference bus here.
%Let us first calculate the  Ybus matrix.

Zse=Rse+1i*Xse;
Yse=1/Zse;
Ybus=zeros(2,2);

Ybus(1,1)=Yse+1i*0.5*Bsh;
Ybus(1,2)=-Yse;
Ybus(2,1)=-Yse;
Ybus(2,2)=Yse+1i*0.5*Bsh;


% We will now start the Gauss-Seidel iterations

V_bus1=1;
V_bus2=1;

for iter=1:5
    V_bus1=(1/Ybus(1,1))*(((P_R-1i*Q_R)/conj(V_bus1))-Ybus(1,2)*V_bus2);
end
V_bus1_mag=abs(V_bus1);

%Now we will calculate the power losses in the line
I_bus1=Ybus(1,1)*V_bus1+Ybus(1,2)*V_bus2;
I_bus2=Ybus(2,1)*V_bus1+Ybus(2,2)*V_bus2;

S_loss=V_bus1*conj(I_bus1)+V_bus2*conj(I_bus2);

P_loss=real(S_loss);
Q_loss=imag(S_loss);

Q4_sol=[P_loss Q_loss V_bus1_mag]';
%**************************************************************************
%Question 5
%**************************************************************************
data=xlsread(IP_File_Name,File_Sheet,'B33:B40');
k_1=data(1);
k_2=data(2);
k_3=data(3);
k_4=data(4);
c_1=data(5);
c_2=data(6);
x_0=data(7);
y_0=data(8);
Q5_sol=[];

for iter=1:2
    error=[c_1+x_0+y_0-exp(k_1*x_0)-exp(k_2*y_0)
           c_2+x_0-y_0-exp(k_3*x_0)+exp(k_4*y_0)]; % The mismatch vector (i.e., c-f(x_0))
   
    J=[k_1*exp(k_1*x_0)-1  k_2*exp(k_2*y_0)-1 
       k_3*exp(k_3*x_0)-1  -k_4*exp(k_4*y_0)+1]; %The jacobian matrix
  
   var_update=inv(J)*error;
   
   x_0=x_0+var_update(1);
   y_0=y_0+var_update(2);
   
   Q5_sol=[Q5_sol
           x_0
           y_0];     
end

return; 

 
end
 
              
 
 
 
 
 
 
 
  





