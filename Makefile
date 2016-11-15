default_target: stats

include config

# Log onto wlm01 and gather pbs-report data for required period
pbs-report.raw.$(suffix).csv:
	echo ssh to root@wlm01 to run pbs-report ; ssh root@wlm01 "cd $(PWD) && ./pbsreport-get && chown $(LOGNAME) pbs-report.raw.$(suffix).csv"

# Clean raw pbs-report data
pbs-report.cleaned.$(suffix).csv: pbs-report.raw.$(suffix).csv
	./pbsreport-clean

# Parse pbs-report to calculate number of cores in each job
cores.$(suffix).csv: pbs-report.cleaned.$(suffix).csv
	./pbsreport-count-cores

# convert config file into format to be read into R scripts
config.R: config
	./make-config.R

.PHONY : stats
stats: pbs-report.cleaned.$(suffix).csv cores.$(suffix).csv config.R
	./generate-application-statistics

# Clean up data generated from R scripts
.PHONY : clean
clean:
	rm -f {alldata,top100,unknown,org,application,user_}*.$(suffix).csv *.Rdata config.R

# Only remove application data if necessary as it takes a little while to regnerate
.PHONY : veryclean
veryclean: clean
	rm -f alljobs.$(suffix).csv usernames{,-raw}.$(suffix).csv 

# Only remove pbs-report data as a last resort as it takes a long time to regenerate
.PHONY : distclean
distclean: veryclean
	rm -f pbs-report.raw.$(suffix).csv pbs-report.$(suffix).csv cores.$(suffix).csv $(prefix)-*.zip

.PHONY: all
all:
	./run

