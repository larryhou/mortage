clear

local gjj_year_rate = 3.6
local gjj_amount = 900000

local range = 20
local amount = 5340000 - `gjj_amount'
local year_rate = 4.9
local years = 30

local periods = `years' * 12

set obs `=`range'*2+1'

gen floating = `range' + 1 - _n

gen year_rate = `year_rate' * (1 + floating/100)
gen rate = year_rate / 100 / 12
gen gjj_rate = `gjj_year_rate' * (1 + floating/100) / 100 / 12

format %5.3f year_rate
format %7.6f rate

gen payment = `amount' * rate * (1+rate)^`periods' / ((1+rate)^`periods' - 1)
gen gjj_payment = `gjj_amount' * gjj_rate * (1+gjj_rate)^`periods'/((1+gjj_rate)^`periods' - 1)
gen adj_payment = payment + gjj_payment
gen diff_payment = payment - payment[`range' + 1]
format %6.0fc *payment

gen interest = payment * `periods' - `amount'
gen diff_interest = interest - interest[`range' + 1]
format %11.0fc *interest
