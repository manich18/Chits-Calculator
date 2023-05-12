options symbolgen mprint nofmterr;
option validvarname = upcase;


proc format;
value $ chit_members
"person1"="A" /**person1, who lifts chit value amount first**/
"person2"="B" /**person2, who lifts chit value amount in 2nd cycle**/
"person3"="C" /**person3, who lifts chit value amount in 3rd cycle**/
"person4"="D"
"person5"="E"
"person6"="F"
"person7"="G"
"person8"="H"
"person9"="I"
"person10"="J"
"person11"="K"
"person12"="L"
;
run;

%macro chit_calculator(chit_value=,chit_duration=,chit_rate_of_intrest=,chit_orgnsr_commission_pct=,chit_start_date=);

%let chit_value=&chit_value;
%put &=chit_value;

%let chit_duration=&chit_duration;/*****Duration in Months****/ 
%put &=chit_duration;

%let chit_members=&chit_duration;/****Duration equal to number of subscribers/investors****/
%put &=chit_members;

%let monthly_chit_value=%eval(&chit_value/&chit_duration);
%put &=monthly_chit_value;

%let chit_rate_of_intrest=&chit_rate_of_intrest;/******1RS=12%**********/
%put &=chit_rate_of_intrest;

%let monthly_intrest=%sysevalf(&chit_value*1/12*&chit_rate_of_intrest/100);
%put &=monthly_intrest;

%let chit_orgnsr_commission_pct=&chit_orgnsr_commission_pct;
%put &=chit_orgnsr_commission_pct;

%let subscr_paid_as_comission=%sysevalf(&chit_value*&chit_orgnsr_commission_pct/100);
%put &=subscr_paid_as_comission;

%let chit_start_date=&chit_start_date;
%put &=chit_start_date;

/****Chit Details*************************/
data chit_info;
	length Chit_Details $200.;
	Chit_Details="chit_value=&chit_value";
	output;
	Chit_Details="monthly_chit_value=&monthly_chit_value";
	output;
	Chit_Details="chit_duration=&chit_duration";
	output;
	Chit_Details="chit_members=&chit_members";
	output;
	Chit_Details="chit_rate_of_intrest=&chit_rate_of_intrest"||"%";
	output;
	Chit_Details="monthly_intrest=&monthly_intrest";
	output;
	Chit_Details="chit_orgnsr_commission_pct=&chit_orgnsr_commission_pct";
	output;
	Chit_Details="subscr_paid_as_comission=&subscr_paid_as_comission";
	output;
	Chit_Details=cats("chit_start_date=",&chit_start_date);
	output;
run;




/****Summary of Chit*********************/
data chit_summary;

	do nth_cycle= 1 to &chit_duration;
	     
	     chit_mon_year=put(intnx("month",&chit_start_date.d,nth_cycle-1),monyy7.);
	     
		subscriber_names=put(strip(cats("person",nth_cycle)),$chit_members.);
		
		intr_accru_at_chit_collector=(&monthly_intrest*(nth_cycle-1));

		Paid_this_intrest_to=catx(" ","chit organiser gives this",intr_accru_at_chit_collector,"Rs as intrest to",put(subscriber_names,$chit_members.),"in cycle",nth_cycle);

		subscriber_receive_this_amount=(&chit_value-&subscr_paid_as_comission)+(&monthly_intrest*(nth_cycle-1));

		subscri_recei_thi_amnt_calcu=cats(&chit_value,"-",&subscr_paid_as_comission,"+","(",&monthly_intrest,"*",nth_cycle-1,")","=",subscriber_receive_this_amount);

		k=&chit_duration-nth_cycle;

		tot_amt_paid_by_subscriber=(&chit_value+(k*&monthly_intrest));

		tot_amt_paid_by_subscri_calc=cats(&chit_value,"+","(",k,"*",&monthly_intrest,")","=",tot_amt_paid_by_subscriber);

		net_profit_loss_in_chit=subscriber_receive_this_amount-tot_amt_paid_by_subscriber;

		accured_chit_maintainer_comiss=(&subscr_paid_as_comission*nth_cycle);
		
		subsc_lens_recivd_amnt_out_18pt=subscriber_receive_this_amount+(subscriber_receive_this_amount*0.18*k/12);
		
		subsc_lens_recivd_amnt_out_24pt=subscriber_receive_this_amount+(subscriber_receive_this_amount*0.24*k/12);
		
		net_18pt_intrest=subsc_lens_recivd_amnt_out_18pt-subscriber_receive_this_amount;
		
		net_24pt_intrest=subsc_lens_recivd_amnt_out_24pt-subscriber_receive_this_amount;
		
		net_18pt_profit=net_18pt_intrest+net_profit_loss_in_chit;
		
		net_24pt_profit=net_24pt_intrest+net_profit_loss_in_chit;
		output;
	end;
drop k;
run;

proc export data=chit_info
            outfile="%sysfunc(getoption(sasuser))/Chit_calculator.xlsx"
            dbms=xlsx
            replace;
            sheet="Chit Information";
run; 

proc export data=chit_summary
            outfile="%sysfunc(getoption(sasuser))/Chit_calculator.xlsx"
            dbms=xlsx
            replace;
            sheet="Chit Summary";
run;  


	%do i=1 %to &chit_members;
		data person&i;
			name=put("person&i",$chit_members.);
				do nth_cycle=1 to &chit_duration;
					if nth_cycle>&i then chit_month_contrib=(&monthly_chit_value+&monthly_intrest);
					else chit_month_contrib=&monthly_chit_value;
				accrue_chit_month_contrib=sum(accrue_chit_month_contrib,chit_month_contrib);
				output;
				end;
		run;
		
		proc export data=person&i
            outfile="%sysfunc(getoption(sasuser))/Chit_calculator.xlsx"
            dbms=xlsx
            replace;
            sheet="person&i";
		run;  
	%end;


%mend chit_calculator;

%chit_calculator(chit_value=150000,
                 chit_duration=12, /*****Duration in Months****/
                 chit_rate_of_intrest=12, /******1RS=12%**********/
                 chit_orgnsr_commission_pct=3,
                 chit_start_date="01JAN2023" /**Date in Date9 Format:ddmmmyyy**/                 
					)






   
