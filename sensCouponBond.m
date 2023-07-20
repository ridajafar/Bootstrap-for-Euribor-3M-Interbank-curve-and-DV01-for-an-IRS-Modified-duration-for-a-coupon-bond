function MacD = sensCouponBond(setDate, couponPaymentDates, fixedRate, dates, discounts)
%computes the value of the Mcaulay duration

% INPUT 
% setDate:              date in which the contract is set
% fixedLegPaymentDates: payments dates for the fixed leg
% fixedRate:            fixed rate
% dates:                complete set of dates
% discounts:            complete set of discounts

% Computing Yearly discounts
firstDiscountfactor = interp1(dates(2:end), zeroRates(dates,discounts)/100,couponPaymentDates(2));
Yearly_discounts =[ exp(-firstDiscountfactor.*yearfrac(setDate,couponPaymentDates(2),3)) ; discounts(13:17)];

% Setting c_i
c= fixedRate*yearfrac(couponPaymentDates(1:end-2),couponPaymentDates(2:end-1),6);
c=[c ; 1+fixedRate*yearfrac(couponPaymentDates(end-1),couponPaymentDates(end),6)];

% Computing the Bond price
Bond_price = sum(c.*Yearly_discounts);
fprintf('The price of the bond (with Notional=1) is %f\n', Bond_price);

% MACD computation
MacD=sum(c.*yearfrac(couponPaymentDates(1),couponPaymentDates(2:end),6).*Yearly_discounts)/Bond_price;

end