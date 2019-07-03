default_target: stats

.PHONY: aggregate
aggregate:
	./aggregate ; $(MAKE) stats

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

storage-byproject.$(suffix).csv: storage.$(suffix).csv
	./make-storage

# Collect username information
usernames.$(suffix).csv: pbs-report.cleaned.$(suffix).csv
	cp $(base)/$(data)/$(csvusernames) $@

# Collect application information
alljobs.$(suffix).csv: pbs-report.cleaned.$(suffix).csv
	cp $(base)/$(data)/$(csvalljobs) $@ ; rm -f alljobs1.$(suffix).csv

# Collect project information
project.$(suffix).csv: pbs-report.cleaned.$(suffix).csv
	cp $(base)/$(data)/$(csvproject) $@

# Collect project information
project-info.$(suffix).csv: pbs-report.cleaned.$(suffix).csv
	cp $(base)/$(data)/$(csvprojectinfo) $@

# Collect job dependeny information
depend.$(suffix).csv: pbs-report.cleaned.$(suffix).csv
	cp $(base)/$(data)/$(csvdepend) $@

# Collect job dependeny information
ngpus.$(suffix).csv: pbs-report.cleaned.$(suffix).csv
	cp $(base)/$(data)/$(csvngpus) $@

#Calculate unused allocations
unused.$(suffix).csv: config
	./make-unused

ams-personal.$(suffix).csv: config
	./make-ams

ams-projects.$(suffix).csv: config
	./make-ams

queue_firstrun.$(suffix).csv: config
	./make-queuefirstrun

# Generate statistics if any source files have been updated
alldata.$(suffix).csv: unused.$(suffix).csv pbs-report.cleaned.$(suffix).csv cores.$(suffix).csv usernames.$(suffix).csv storage-byproject.$(suffix).csv alljobs.$(suffix).csv project.$(suffix).csv project-info.$(suffix).csv depend.$(suffix).csv ngpus.$(suffix).csv config.R
	./make-stats

.PHONY : stats
stats: queue_firstrun.$(suffix).csv alldata.$(suffix).csv ams-personal.$(suffix).csv ams-projects.$(suffix).csv

# Clean up data generated from R scripts
.PHONY : clean
clean:
	rm -f {active*,alldata,top100,unknown,org,total,application,user_,stats_by_core,cpu_walltime_by_user_by_application_,storage-byorg,storage-byuser,project_,partial}*.$(suffix).csv $(prefix)-*.zip *.$(suffix).png no_rename-$(suffix).xlsx application_usage-$(suffix).xlsx

# Remove everything apart from raw PBS data and config file
.PHONY : veryclean
veryclean: clean
	rm -f alljobs.$(suffix).csv alljobs1.$(suffix).csv alljobs2.$(suffix).csv project.$(suffix).csv project-info.$(suffix).csv usernames.$(suffix).csv ams-p*.$(suffix).csv depend.$(suffix).csv ngpus.$(suffix).csv pbs-report.cleaned.$(suffix).csv pbs-report.cleaned.partial.$(suffix).csv cores.$(suffix).csv cores.partial.$(suffix).csv config.R config.pyc config.py data.Rdata users.Rdata storage*.$(suffix).csv user-summary.$(suffix).csv

# Remove data which requires root access
# Only remove pbs-report data as a last resort as it is an external dependency
.PHONY : veryveryclean
veryveryclean: veryclean
	rm -f pbs-report.raw.$(suffix).csv pbs-report.raw.partial.$(suffix).csv queue_firstrun.$(suffix).stdout queue_firstrun.$(suffix).csv cores-mean.$(suffix).csv cores-summary.$(suffix).csv gpus-mean.$(suffix).csv gpus-summary.$(suffix).csv unused.$(suffix).csv ams-raw.$(suffix).csv ams-archive.$(suffix).csv

.PHONY : distclean
distclean: veryveryclean
	rm -f config
