* define mylib;
* change to your own folder;
libname mylib "~/Workshop_SAS/data";

* load in Employees dataset;
proc import datafile="~/Workshop_SAS/data/Employees.csv" out=mylib.employees dbms=csv replace;
run;

* print metadata;
proc contents data=mylib.employees;
run;

* print frequency table;
proc freq data=mylib.employees;
  tables Country;
run;

* sort Employees table by LastName;
proc sort data=mylib.employees out=mylib.employees_sorted;
  by LastName;
run;

* print summary statistics using means procedure;
proc means data=sashelp.cars;
    var EngineSize Horsepower;
run;

* list unique division and league;
proc sort data=sashelp.baseball(keep=division league) out=DL NODUPKEY;
    by _ALL_;
run;
proc print data=DL;
    title 'Baseball Leagues and Divisions';
run;

* list unique division and league using proc sql;
proc sql;
  select distinct division, league
  from sashelp.baseball;
run;

* list unique division and league using proc sql and create a output table;
proc sql;
  create table dl_sql as
    select distinct division, league
    from sashelp.baseball;
run;

* find revenue by year and country;
* step 1: load data;
* change to your own folder;
PROC IMPORT DATAFILE="~/Workshop_SAS/data/Orders.csv" OUT=mylib.orders DBMS=CSV REPLACE;
	getnames=yes;
RUN;

PROC IMPORT DATAFILE="~/Workshop_SAS/data/OrderDetails.csv" OUT=mylib.orderdetails DBMS=CSV REPLACE;
	getnames=yes;
RUN;

* step 2: use proc sql;
* not saving result;
proc sql;
    select year(datepart(OrderDate)) as Year, ShipCountry, sum(Quantity * UnitPrice) as Subtotal
    from mylib.orders
      join mylib.orderdetails on orders.OrderID = orderdetails.OrderId
    group by year, ShipCountry;
run;

* saving result;
proc sql;
    create table mylib.Revenue_Year_Country as
      select year(datepart(OrderDate)) as Year, ShipCountry, sum(Quantity * UnitPrice) as Subtotal
      from mylib.orders
        join mylib.orderdetails on orders.OrderID = orderdetails.OrderId
      group by year, ShipCountry;
run;

* filter rows;
data myclass;
    set sashelp.class;
    where age >= 15;
run;

data myclass;
    set sashelp.class(where=(age>=15));
run;

* subset columns;
data myclass;
    set sashelp.class;
    drop sex weight;
run;

data myclass(drop=sex weight);
    set sashelp.class;
run;

* filter rows and subset columns;
data stock_04onward;
    set sashelp.stocks;
    where Date>="01Jan2004"d and Stock="Intel";
    keep Stock Date Close;
run;

* create an indicator column;
* method 1;
data stock_04onward;
    set sashelp.stocks;
    if Stock="Intel" then intel = 1;
    else intel = 0;
    keep Stock Date Close intel;
run;

* method 2;
data stock_04onward;
    set sashelp.stocks;
    intel = (Stock = "Intel");
    keep Stock Date Close intel;
run;

* controlling output;
data forecast;
    set sashelp.shoes;
    keep Region Product Subsidiary Year ProjectedSales;
    format ProjectedSales dollar10.;
    Year=1;
    ProjectedSales=Sales*1.05;
    output;
    Year=2;
    ProjectedSales=ProjectedSales*1.05;
    output;
    Year=3;
    ProjectedSales=ProjectedSales*1.05;
    output;
run;

* controlling output, using loop;
data forecast;
    set sashelp.shoes(rename=(Sales=ProjectedSales));
    keep Region Product Subsidiary Year ProjectedSales;
    format ProjectedSales dollar10.;
    do Year = 1 to 3;
       ProjectedSales=ProjectedSales*1.05;
       output;
    end;
run;

* accumulated sum;
* step 1: filter data;
data stock_IBM_05;
    set sashelp.stocks;
    where Date>="01Jan2005"d and Date<="31Dec2005"d and Stock="IBM";
    keep Stock Date Volume;
run;

* step 2: sort by Date;
proc sort data=stock_IBM_05 out=stock_IBM_05_sorted;
    by Date;
run;

* step 3: calculate accumulated sum;
data stock_IBM_05_sorted;
    set stock_IBM_05_sorted;
    acc_volume + volume;
    month + 1;
run;

* total volume by year
* step 1: filter data;
data stock_IBM;
    set sashelp.stocks(where=(Stock="IBM") keep=Stock Date Volume);
    year = year(Date);
run;

* step 2: sort by Date;
proc sort data=stock_IBM out=stock_IBM_sorted;
    by Date;
run;

* step 3: calculate total volume sum by year;
* method 1;
data stock_IBM_sorted_total_by_year;
    set stock_IBM_sorted;
    by year;
    total_volume + volume;
    if last.year = 1;
    output;
    total_volume = 0;
    keep Stock year total_volume;
run;

* method 2;
data stock_IBM_sorted_total_by_year;
    set stock_IBM_sorted;
    by year;
    if first.year = 1 then total_volume = 0;
    total_volume + volume;
    if last.year = 1;
    keep stock year total_volume;
run;

* proc sql approach;
proc sql;
  create table stock_IBM_sorted_total_by_year as
    select stock, year(date) as year, sum(volume) as total_volume
    from sashelp.stocks
    where stock = "IBM"
    group by stock, year
    order by year;
run;

* accumulate sum by year
* step 1: filter data;
data stock_IBM;
    set sashelp.stocks(where=(Stock="IBM") keep=Stock Date Volume);
    year = year(Date);
run;

* step 2: sort by Date;
proc sort data=stock_IBM out=stock_IBM_sorted;
    by Date;
run;

* step 3: calculate monthly accumulated sum by year;
* method 1;
data stock_IBM_sorted_acc_by_year;
    set stock_IBM_sorted;
    by year;
    if first.year = 1 then total_volume = volume;
    else total_volume + volume;
run;

* method 2;
data stock_IBM_sorted_acc_by_year;
    set stock_IBM_sorted;
    by year;
    if first.year = 1 then total_volume = volume;
    else do;
        retain total_volume 0;
        total_volume = sum(total_volume, volume);
    end;
run;

* frequency table;
proc freq data=mylib.churn_telecom;
  tables churn_flg*gender_cd;
run;

* logistic regression;
proc logistic data=mylib.churn_telecom descending;
  class gender_cd / param=ref;
  model churn_flg = gender_cd;
run;


