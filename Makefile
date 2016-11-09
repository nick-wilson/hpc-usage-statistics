default_target: stats

.PHONY : stats
stats:
	./generate-application-statistics

.PHONY : clean
clean:
	rm -f all{data,jobs}.*.csv *.Rdata {unknown,org,application}_*.csv usernames{,-raw}.csv config.R

.PHONY : veryclean
veryclean: clean
	rm -f pbs-report.cleaned.*.csv cores.*.csv

.PHONY : distclean
distclean: veryclean
	rm -f pbs-report.raw.*.csv


