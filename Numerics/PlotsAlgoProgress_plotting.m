%% Parameters
alpha       = 2;
epsilon     = 1;
gamma       = 0.90;
T           = 0.50;
eta         = 0.95;
RE          = 0.01;
Teff        = T_eff(gamma, T, eta, RE);
gammaeff    = gamma_eff(gamma, T, eta, RE);
mt          = noiselessRescale(T_eff(gamma, T, eta, RE), alpha);                        % Matrix that distorts the qubit due to ZPS and Teleamp. together.
Wmat        = W(sqrt(T_eff(gamma, T, eta, RE))*alpha, gamma_eff(gamma, T, eta, RE));    % Process matrix for the effective loss channel
Nbasis      = noisebasisTable();                                                        % A table of vec(basis operators) for the effective loss channel
N           = Jw(Wmat, Nbasis);
%% Picking the best R and how we got there
runs        = 1;    % # runs for each point
[ylist,Rlist, diffRlistlist, Flistlist] = makeY(alpha, gamma, T, eta, RE ,epsilon, runs);
[maxy, idx] = max(ylist);
Ropt        = Rlist(:,:,idx);
diffRlist   = diffRlistlist(:,idx);
Flist       = Flistlist(:, idx);
%%
maxy        = Flist(end);    
%% Changes in diffR
X           = 1:size(diffRlist, 2); 
plot(X,diffRlist,'Color','k');

ylabel('$|\!| \delta\mathcal{R} |\!|$', 'Interpreter', 'latex');
xlabel('steps', 'Interpreter', 'latex');
title('a','fontsize',20,'fontname','CMU Sans Serif');
set(gca,'fontsize',10);
xaxisproperties= get(gca, 'XAxis');
xaxisproperties.TickLabelInterpreter = 'latex'; % latex for x-axis
yaxisproperties= get(gca, 'YAxis');
yaxisproperties.TickLabelInterpreter = 'latex';   % latex for y-axis
%set(gca,'fontname','CMU Sans Serif');
%% Changes in Fidelity
X           = 1:size(Flist, 2); 
plot(X,Flist,'Color','k');

ylabel('$\mathcal{F}$', 'Interpreter', 'latex');
ylim([0 1]);
xlabel('steps', 'Interpreter', 'latex');
title('b','fontsize',20,'fontname','CMU Sans Serif');
set(gca,'fontsize',10);
xaxisproperties= get(gca, 'XAxis');
xaxisproperties.TickLabelInterpreter = 'latex'; % latex for x-axis
yaxisproperties= get(gca, 'YAxis');
yaxisproperties.TickLabelInterpreter = 'latex';   % latex for y-axis
%set(gca,'fontname','CMU Sans Serif');
%% Bloch sphere
samples         = 50000;
rho0X           = zeros(1, samples);
rho0Y           = zeros(1, samples);
rho0Z           = zeros(1, samples);
recpointsX      = zeros(1, samples);
recpointsY      = zeros(1, samples);
recpointsZ      = zeros(1, samples);
markersize      = 0.25;
markeropacity   = 0.4;
gridopacity     = 0.20;    
for l           = 1:samples
    rhoin=randn(2,1)+1i.*randn(2,1);
    rhoin=rhoin*rhoin';
    rho0tmp=rhoin./trace(rhoin);                            % Initial density matrix of the pure qubit state
    rho0X(l)            = real(trace(Pauli(1)'*rho0tmp));
    rho0Y (l)           = real(trace(Pauli(2)'*rho0tmp));
    rho0Z(l)            = real(trace(Pauli(3)'*rho0tmp));
    rhoZPStmp           = rhot(rho0tmp,    mt);                    % Distorted pure qubit after ideal ZPS
    rhoLosstmp          = rhow(rhoZPStmp,  N);                     % Mixed state after the loss channel
    rhoRecoveredtmp     = rhox(rhoLosstmp, Ropt);
    recpointsX(l)       = real(trace(Pauli(1)'*rhoRecoveredtmp));
    recpointsY(l)       = real(trace(Pauli(2)'*rhoRecoveredtmp));
    recpointsZ(l)       = real(trace(Pauli(3)'*rhoRecoveredtmp));
end
[sphX,sphY,sphZ]=sphere;
surf(sphX,sphY,sphZ, 'FaceColor','none', 'EdgeColor' , 'k','EdgeAlpha', gridopacity );
hold on;
scatter3(rho0X, rho0Y, rho0Z, markersize,'MarkerEdgeColor' , 'none' , ...
    'MarkerFaceColor' ,'#FF1313', 'MarkerFaceAlpha',markeropacity);
scatter3(recpointsX,recpointsY,recpointsZ, markersize,'MarkerEdgeColor' , 'none' , ...
    'MarkerFaceColor' ,'#0000FF', 'MarkerFaceAlpha',markeropacity);
hold off;

axis off;
daspect([1 1 1]);
title('c','fontsize',16,'fontname','CMU Sans Serif');
set(gca,'fontsize',10);
%%
numstates=10000;
rhoout=zeros(2,2,numstates);
fids=zeros(numstates,1);
for j=1:numstates
    rhoin=randn(2,1)+1i.*randn(2,1);
    rhoin=rhoin*rhoin';
    rhoin=rhoin./trace(rhoin);                      % Initial density matrix of the pure qubit state
    rhoZPStmp           = rhot(rhoin,    mt);       % Distorted pure qubit after ideal ZPS
    rhoLosstmp          = rhow(rhoZPStmp,  N);      % Mixed state after the loss channel
    rhoRecoveredtmp     = rhox(rhoLosstmp, Ropt);
    rhoout(:,:,j)=rhoRecoveredtmp;
    fids(j)=real(trace(rhoin*rhoRecoveredtmp));
end
%%
worse_fids_rand=zeros(numstates,1);
pointSize       = 3;
recpointsX      = zeros(1, numstates);
recpointsY      = zeros(1, numstates);
recpointsZ      = zeros(1, numstates);
for l           = 1:numstates
    l
    rhoin=randn(2,1)+1i.*randn(2,1);
    rhoin=rhoin*rhoin';
    rho0tmp=rhoin./trace(rhoin);                        % Initial density matrix of the pure qubit state
    rhoZPStmp           = rhot(rho0tmp,    mt);         % Distorted pure qubit after ideal ZPS
    rhoLosstmp          = rhow(rhoZPStmp,  N);          % Mixed state after the loss channel
    rhoRecoveredtmp     = rhox(rhoLosstmp, Ropt);
    recpointsX(l)       = real(trace(Pauli(1)'*rhoRecoveredtmp));
    recpointsY(l)       = real(trace(Pauli(2)'*rhoRecoveredtmp));
    recpointsZ(l)       = real(trace(Pauli(3)'*rhoRecoveredtmp));
    worse_fids_rand(l)=real(trace(rho0tmp*rhoRecoveredtmp));
end
[sphX,sphY,sphZ]=sphere;
plotAlpha = 0.1;
figure
surf(sphX,sphY,sphZ, 'FaceAlpha' , plotAlpha, 'EdgeColor' , 'k','EdgeAlpha', plotAlpha );
hold on;
scatter3(recpointsX,recpointsY,recpointsZ, pointSize,'MarkerEdgeColor' , 'k' , ...
    'MarkerFaceColor' ,[0 .75 .75]);
hold off;
xlim([-1 1]);
ylim([-1 1]);
zlim([-1 1]);
daspect([1 1 1]);
%%
numRs=100;
worse_fids=zeros(numRs,1);
for j=1:numRs
    j
    seed        = rand(8,8)+1j*rand(8,8);               % A random full rank complex matrix. It is not a CPTP.
    seed        = (seed'*seed)/trace(seed'*seed);       % trace normalizing
    R           = CPTP(seed);
    [~,worse_fids(j)] = innerOpt(R, mt, N);
end

%%
X=1:numstates;
X2=1:numRs;
figure
linewidth   = 1.5;
subplot(1,2,1)
plot(X,fids','.','Color' ,'#0000FF')
hold on
plot(X,ones(1,numstates).*maxy,'-','Color' ,'#FF1313','linewidth',linewidth)

title('a','fontsize',18,'fontname','CMU Sans Serif');
xlabel('Sample no.','Interpreter','latex')
ylabel('$\mathcal{F}$','Interpreter','latex')
set(gca,'fontsize',13);
xaxisproperties                         = get(gca, 'XAxis');
yaxisproperties                         = get(gca, 'YAxis');
xaxisproperties.TickLabelInterpreter    = 'latex';          
yaxisproperties.TickLabelInterpreter    = 'latex';          


subplot(1,2,2)
plot(X2,worse_fids','.','Color' ,'#0000FF')
hold on
plot(X2,ones(1,numRs).*maxy,'-','Color' ,'#FF1313','linewidth',linewidth);

title('b','fontsize',18,'fontname','CMU Sans Serif');
xlabel('$\mathcal{R}$ no.','Interpreter','latex')
ylabel('$\mathcal{F}$','Interpreter','latex')
set(gca,'fontsize',13);
xaxisproperties                         = get(gca, 'XAxis');
yaxisproperties                         = get(gca, 'YAxis');
xaxisproperties.TickLabelInterpreter    = 'latex';          
yaxisproperties.TickLabelInterpreter    = 'latex';          

