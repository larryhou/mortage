clear 
set obs 360
gen index = _n

local price_total = 8030486
local discount = 0.99 ^ 5
local area = 124.74
disp `discount'
local price = `discount' * `price_total'
disp `price'
local loan = floor(`price' * 0.7 / 10000)*10000
disp `loan'

local down_payment = `price' - `loan'
disp `down_payment'

local year_rate = 4.9 * 1.1
local rate = `year_rate' / 100 / 12
disp `rate'

// payment = amount * rate * pow(1 + rate, periods) / (pow(1 + rate, periods) - 1)
local payment = `loan' * `rate' * (1 + `rate')^_N / ((1 + `rate')^_N - 1)

gen double payment_i = .
gen double payment_p = .
label var payment_i "月供利息"
label var payment_p "月供本金"
gen double payed_i = .
gen double payed_p = .
label var payed_p "累积偿还本金"
label var payed_i "累积偿还利息"

gen double simple = _n * 5340000 / 360

gen double remain = .
label var remain "剩余银行欠款"
local remain = `loan'
local payed_i = 0
local payed_p = 0
quiet forvalues n = 1/360 {
	replace payment_i = `remain' * `rate' in `n'
	replace payment_p = `payment' - payment_i[`n'] in `n'
	
	local remain = `remain' - payment_p[`n']
	replace remain = `remain' in `n'
	
	local payed_i = `payed_i' + payment_i[`n']
	replace payed_i = `payed_i' in `n'
	
	local payed_p = `payed_p' + payment_p[`n']
	replace payed_p = `payed_p' in `n'
}

gen ep_payed_i = ., after(payed_i)
label var ep_payed_i "等额本金累积偿还利息"
local remain = `loan'
local ep_payed_i = 0
quiet forvalues n = 1/360 {
	local ep_payed_i = `ep_payed_i' + `remain' * `rate'
	replace ep_payed_i = `ep_payed_i' in `n'
	local remain = `remain' - `loan' / 360
}

gen payed_total = payed_i + payed_p
gen ep_payed_total = ep_payed_i + _n * `loan' / 360
gen diff_payed_total = ep_payed_total - payed_total
label var payed_total "等本息累积付款"
label var ep_payed_total "等本金累积付款"
label var diff_payed_total "等本金与等本息付款差额"


gen double ip_diff = payed_i - payed_p
label var ip_diff "累积利息与累积本金差额"
label var ip_diff "利息还贷差"

gen double pct_i = payed_i / `loan' * 100
gen double pct_p = payed_p / `loan' * 100
label var pct_i "累积利息占贷款总额百分比"
label var pct_p "累积本金占贷款总额百分比"
format %4.2f pct_*

gen double ip_ratio = payment_i / payment_p
label var ip_ratio "月供利息本金百分比"

format %10.2fc payment_*
format %10.0fc remain ip_diff *payed*

gen year = ceil(_n / 12)
gen expect_up = (payed_i + `price') / `area'
label var expect_up "考虑利息保本最低涨幅"
format %7.0fc expect_up

list year payed_i payed_p ip_diff pct_* expect_up if mod(_n, 12) == 0

forvalues n = 1000000(1000000)5000000 {
	disp in yellow "payed_i = " %9.0fc `n'
	quiet sum payed_i if payed_i >= `n'
	list payed_i payed_p ip_diff remain if payed_i == r(min)
}

sum ip_diff
list payed_i payed_p ip_diff remain if ip_diff == r(max)

// 43 89 139 196 275 

#delimit ;
twoway 
line ep_payed_i payed_i payed_p index, xsize(16) ysize(9)
xtitle("") xlabel(0(12)360, labs(*.5) angle(0))
ytitle("") ylabel(0(1000000)5500000,labs(*.65) format(%10.0fc) angle(90))
ymtick(##5, grid glw(*.4))
lc(orange_red red green) lw(*1.5 ..) lp(-) ||
line ip_diff index, lc(magenta) lw(*1.5) ||
line simple index, lc (black) lp(-.) lw(*.5)
|| ,
legend(off)
text(`=payed_i[43]' 43 `"[43(`=strofreal(43/12,"%4.1f")') `=strofreal(payed_i[43],"%10.0fc")']"', place(nw) margin(b + 1) size(vsmall))
text(`=payed_p[43]' 43 `"[43(`=strofreal(43/12,"%4.1f")') `=strofreal(payed_p[43],"%10.0fc")']"', place(se) margin(b + 1) size(vsmall))
text(`=payed_i[89]' 89 `"[89(`=strofreal(89/12,"%4.1f")') `=strofreal(payed_i[89],"%10.0fc")']"', place(nw) margin(b + 1) size(vsmall))
text(`=payed_p[89]' 89 `"[89(`=strofreal(89/12,"%4.1f")') `=strofreal(payed_p[89],"%10.0fc")']"', place(se) margin(b + 1) size(vsmall))
text(`=payed_i[139]' 139 `"[139(`=strofreal(139/12,"%4.1f")') `=strofreal(payed_i[139],"%10.0fc")']"', place(nw) margin(b + 1) size(vsmall))
text(`=payed_p[139]' 139 `"[139(`=strofreal(139/12,"%4.1f")') `=strofreal(payed_p[139],"%10.0fc")']"', place(se) margin(b + 1) size(vsmall))
text(`=payed_i[196]' 196 `"[196(`=strofreal(196/12,"%4.1f")') `=strofreal(payed_i[196],"%10.0fc")']"', place(nw) margin(b + 1) size(vsmall))
text(`=payed_p[196]' 196 `"[196(`=strofreal(196/12,"%4.1f")') `=strofreal(payed_p[196],"%10.0fc")']"', place(se) margin(b + 1) size(vsmall))
text(`=payed_i[275]' 275 `"[275(`=strofreal(275/12,"%4.1f")') `=strofreal(payed_i[275],"%10.0fc")']"', place(nw) margin(b + 1) size(vsmall))
text(`=payed_p[275]' 275 `"[275(`=strofreal(275/12,"%4.1f")') `=strofreal(payed_p[275],"%10.0fc")']"', place(se) margin(b + 1) size(vsmall))
text(`=ip_diff[206]' 206 `"MAX[206(`=strofreal(206/12,"%4.1f")') `=strofreal(ip_diff[206],"%10.0fc")']"', place(n) margin(b + 1) size(small) c(magenta))
;
#delimit cr
graph export payed_ip.pdf, replace

forvalues n = 1/4 {
	disp in yellow "ip_ratio = " %2.0fc `n'
	quiet sum ip_ratio if ip_ratio >= `n'
	list payed_i payed_p ip_diff remain ip_ratio if ip_ratio == r(min)
}

#delimit ;
line diff_payed_total index, xsize(16) ysize(9)
lw(*2.0 ..) lc(black)
xtitle("") xlabel(0(12)360, labs(*.5) angle(0))
ytitle(, size(*.75)) ylabel(, labs(*.75))
ymtick(##5, grid glw(*.4))
text(`=diff_payed_total[134]' 134 `"[134(`=strofreal(134/12,"%4.1f")') `=strofreal(`=diff_payed_total[134]',"%8.0fc")']"', place(n) margin(b 1) size(small) color(red))
text(`=diff_payed_total[268]' 268 `"[268(`=strofreal(268/12,"%4.1f")') `=strofreal(`=diff_payed_total[268]',"%8.0fc")']"', place(ne) margin(b 0) size(small) color(midgreen))
;
#delimit cr

// 1 51 115 206
#delimit ;
line ip_ratio index, xsize(16) ysize(9) 
lc(green) lw(*1.5)
xtitle("") xlabel(0(12)360, labs(*.5) angle(0))
ytitle("")
text(`=ip_ratio[1]' 1 `"[1(`=strofreal(1/12,"%4.1f")') `=strofreal(`=ip_ratio[1]',"%3.1f")']"', place(ne) size(small))
text(`=ip_ratio[51]' 51 `"[51(`=strofreal(51/12,"%4.1f")') `=strofreal(`=ip_ratio[51]',"%3.1f")']"', place(ne) size(small))
text(`=ip_ratio[115]' 115 `"[115(`=strofreal(115/12,"%4.1f")') `=strofreal(`=ip_ratio[115]',"%3.1f")']"', place(ne) size(small))
text(`=ip_ratio[206]' 206 `"[206(`=strofreal(206/12,"%4.1f")') `=strofreal(`=ip_ratio[206]',"%3.1f")']"', place(ne) size(small))
;
#delimit cr
graph export ip_ratio.pdf, replace

sum ip_diff
list if ip_diff == r(max)

#delimit ;
line ip_diff index, xsize(16) ysize(9)
xtitle("") xlabel(0(12)360, labs(*.5) angle(0))
ytitle("") ylabel(,labs(*.5) format(%10.0fc) angle(90))
xline(206, lp(-) lw(*.5))
legend(ring(0) position(5))
lc(red) lw(*1.5)
text(`=ip_diff[206]' 206 `"MAX[206(`=strofreal(206/12,"%4.1f")') `=strofreal(ip_diff[206],"%10.0fc")']"', place(n) margin(b + 1) size(small) c(red))
;
#delimit cr
graph export payed_ip_diff.pdf, replace

#delimit ;
graph bar payed_p payed_i, xsize(20) ysize(8) stack
over(index, label(angle(90) labs(*.2))) 
ylabel(, labs(*.75) format(%10.0fc))
ymtick(##4, grid glp(-.) glw(*.5))
bar(1, color(green))
bar(2, color(red))
note(`"总计付款 = `=strofreal(payed_i[_N]+payed_p[_N],"%10.0fc")'"'
	 `"累积利息 = `=strofreal(payed_i[_N],"%10.0fc")'"'
	 `"累积本金 = `=strofreal(payed_p[_N],"%10.0fc")'"'
	 , ring(0) position(11) linegap(2) size(*1.2))
legend(off)
;
#delimit cr
graph export payed_ip_stack.pdf, replace

#delimit ;
graph bar payment_p payment_i, xsize(20) ysize(8) stack
over(index, label(angle(90) labs(*.2))) 
bar(1, color(green))
bar(2, color(red))
legend(off)
;
#delimit cr
graph export payment_ip_stack.pdf, replace


