% runAssignment2
% group 7, AY2022-2023
% Computes Euribor 3m bootstrap with a single-curve model

clear;
close all;
clc;
format long;

%% Read market data

if ispc()   % Windows version
    formatData='dd/mm/yyyy'; 
    [datesSet, ratesSet] = readExcelData('MktData_CurveBootstrap_AY22-23', formatData);
else        % MacOS version
    datesSet = load("datesSet.mat");
    datesSet = datesSet.datesSet;
    ratesSet = load("ratesSet.mat") ;
    ratesSet = ratesSet.ratesSet;
end

%% Bootstrap

% dates includes SettlementDate as first date
[dates, discounts] = BootStrap(datesSet, ratesSet); % SAY IN THE PAPER THAT WE MODIFIED THE SIGNATURE


%% Compute Zero Rates

zRates = zeroRates(dates, discounts);

%% Plot Results

% Discount curve
figure(1)
yyaxis right
plot(dates,discounts,'r-o');
ylabel('Discount factor')
xlabel('Date')
xticks([min(dates), (3*min(dates)+max(dates))/4, (min(dates)+max(dates))/2, (min(dates)+3*max(dates))/4, max(dates)]);
formatOut = 'mm/dd/yy';
xticklabels({datestr(min(dates), formatOut),datestr((3*min(dates)+max(dates))/4, formatOut),datestr((min(dates)+max(dates))/2, formatOut), datestr((min(dates)+3*max(dates))/4, formatOut), datestr(max(dates), formatOut)});

% Zero rate curve
yyaxis left
plot(dates(2:end),zRates,'b-o');
ylabel('Zero Rate')
legend('Zero Rates','Discount Factors')
axis('padded')


%% EXERCISE 2:
% With the discount curve obtained above compute (the absolute value of the 
% quantities specified below) for a portfolio composed only by one single 
% swap, a 6y plain vanilla IR swap vs Euribor 3m with a fixed rate 2.8173% 
% and a Notional of €10 Mln:

setDate = dates(1);
fixedLegPaymentDates = [datesSet.settlement; datenum(2024,02,02); dates(13:17)];
fixedRate = 2.8173/100;
shift = 1e-4;
couponPaymentDates = fixedLegPaymentDates;
Notional = 1e7;

% DV01 rates
ratesSet_DV01.depos = ratesSet.depos+shift;
ratesSet_DV01.futures = ratesSet.futures+shift;
ratesSet_DV01.swaps = ratesSet.swaps+shift;

% Bootstap of the DV01 discounts
[~, discounts_DV01] = BootStrap(datesSet, ratesSet_DV01);

% Compute sensitivities 
[DV01, BPV, DV01_z] = sensSwap(setDate, fixedLegPaymentDates, fixedRate, dates, discounts, discounts_DV01);
MacD = sensCouponBond(setDate, fixedLegPaymentDates(1:end), fixedRate, dates, discounts);

fprintf('The DV01 value is: %f\n', Notional*DV01);
fprintf('The DV01z value is: %f\n', Notional*DV01_z);
fprintf('The BPV value is: %f\n', Notional*BPV);
fprintf('The Macaulay Duration value is: %f\n', MacD);
