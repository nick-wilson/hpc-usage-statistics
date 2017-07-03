default_target: stats

include config

# convert config file into format to be read into R scripts
config.py config.R: config
	./make-config

# Log onto wlm01 and gather pbs-report data for required period
pbs-report.raw.$(suffix).csv:
	./pbsreport-get

# Clean raw pbs-report data
pbs-report.cleaned.$(suffix).csv: pbs-report.raw.$(suffix).csv config.py
	./pbsreport-clean.py

# Parse pbs-report to calculate number of cores in each job
cores.$(suffix).csv: pbs-report.cleaned.$(suffix).csv config.py
	./pbsreport-count-cores.py

# Parse storage data
storage.$(suffix).csv:
	./make-storage

# Collect username information
usernames.$(suffix).csv: pbs-report.cleaned.$(suffix).csv storage.$(suffix).csv
	./make-usernames

# Collect application information
alljobs.$(suffix).csv: pbs-report.cleaned.$(suffix).csv
	cp $(csvalljobs) $@

# Collect project information
project.$(suffix).csv: pbs-report.cleaned.$(suffix).csv
	cp $(csvproject) $@

# Generate statistics if any source files have been updated
alldata.$(suffix).csv: pbs-report.cleaned.$(suffix).csv cores.$(suffix).csv usernames.$(suffix).csv storage.$(suffix).csv alljobs.$(suffix).csv project.$(suffix).csv config.R
	./make-stats

.PHONY : stats
stats: alldata.$(suffix).csv

# Clean up data generated from R scripts
.PHONY : clean
clean:
	rm -f {active*,alldata,top100,unknown,org,total,application,user_,stats_by_core,cpu_walltime_by_user_by_application_,storage-,project_}*.$(suffix).csv $(prefix)-*.zip *.$(suffix).png

# Remove everything apart from raw PBS data and config file
.PHONY : veryclean
veryclean: clean
	rm -f alljobs.$(suffix).csv project.$(suffix).csv usernames{,-raw}.$(suffix).csv pbs-report.cleaned.$(suffix).csv cores.$(suffix).csv config.R config.pyc config.py data.Rdata users.Rdata storage.$(suffix).csv

# Only remove pbs-report data as a last resort as it is an external dependency
.PHONY : distclean
distclean: veryclean
	rm -f pbs-report.raw.$(suffix).csv config

.PHONY: aggregate
aggregate:
	./aggregate ; $(MAKE) stats

