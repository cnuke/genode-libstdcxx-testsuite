#
# List of state result lines begin with:
#
#  FAIL         test has failed (unexpectedly)
#  PASS         test was successful
#  UNRESOLVED   test did not have expected out-come,
#               human intervention needed
#  UNSUPPORTED  test is not supported on this platform
#  XFAIL        test has expectedly failed
#
# - Call script with '-v filter=FAIL' to only produce a failure table.
# - Call script with '-v log_file=path/to/libstdc++.log' to generate
#   log snippet containg failure messages produce by the failed test.
#

BEGIN {
	if (filter == "") {
		printf("<html>\n");
		printf("<head>\n");
		printf("<title>libstdc++-v3 testsuite results</title>\n")
		printf("<style>\n")
		printf("table { margin-left: auto; margin-right: auto; border-collapse: collapse; background-color: #fffdf6; width: 80%%; }\n")
		printf("table, th, td { border: 1px solid #a0a5b2; }\nth, td { padding: 3px; }\n")
		printf("th { font-size: 0.9em; text-align: center; background-color: #eeede6; }\n")
		printf("</style>\n")
		printf("</head>\n")
		printf("<body>\n")
	}
	printf("<table>\n")
	printf("<thead>\n")
	printf("<tr><th>Test</th><th>Result</th><th>Description</th><th>Log</th></tr>\n")
	printf("</thead>\n")
	printf("<tbody>\n")

	UNIQUE_ID=0
}


/[A-Z][A-Z]*:/ {
	#
	# Store complete line, in case of failure we use that to look up
	# the corresponding line in the .log file.
	#
	line=$0

	result=$1
	test=$2
	gsub(/:/,"",result)

	if (filter != "") {
		if (result != filter) {
			next
		}
	}

	#
	# Clear first fields so that we can access the
	# remaining fields via $0.
	#
	$1=""
	$2=""
	descr=$0
	gsub(/^[ \t]+/, "",descr)

	bg_style=""
	if(result == "PASS") {
		bg_style=" style=\"background-color: #00FF00\""
	} else
	if(result == "XFAIL") {
		bg_style=" style=\"background-color: #00FF00\""
	} else
	if(result == "FAIL") {
		bg_style=" style=\"background-color: #FF0000\""
	} else
	if(result == "UNRESOLVED") {
		bg_style=" style=\"background-color: #FFa018\""
	} else
	if(result == "UNSUPPORTED") {
		bg_style=" style=\"background-color: #FFFF00\""
	}

	printf("<tr%s>\n", bg_style)
	printf("<td>%s</td>\n", test)
	printf("<td>%s</td>\n", result)
	printf("<td>%s</td>\n", descr)

	if ((result == "FAIL" || result == "UNRESOLVED") && log_file != "") {
		nt=split(test,split_test,"/")
		# start by getting the last line because we need it for the distance check
		grep_end_cmd="grep -n '"line"' "log_file
		grep_end_cmd | getline grep_end
		close(grep_end_cmd)
		n=split(grep_end,end,":")

		# convert to integer
		distance=end[1]+1

		actual_start=0

		grep_start_cmd="grep -n 'Testing "split_test[nt-1]"/"split_test[nt]"' "log_file
		# as long as there is output getline returns 1, i.e., true
		while (grep_start_cmd | getline grep_start) {
			n=split(grep_start,start,":")

			d=(end[1]+0)-(start[1]+0)
			if (d > 0 && d < distance) {
				distance=d
				actual_start=start[1]
			}
		}
		close(grep_start_cmd)

		system(sprintf("sed -n '%d,%sp' %s > var/txt/%s/%d.txt",
		               actual_start, end[1], log_file, filter, UNIQUE_ID))
		printf("<td><a href=\"txt/%s/%d.txt\">%d.txt (%s-%s)</a></td>\n",
		       filter, UNIQUE_ID, UNIQUE_ID, actual_start, end[1])
		printf("</tr>\n")
		UNIQUE_ID = UNIQUE_ID + 1

		# annotation row
		printf("<tr><td colspan=\"4\">TODO</td></tr>\n")
	} else {
		printf("<td></td>\n");
		printf("</tr>\n")
	}
}


END {
	printf("</tbody></table>\n")
	if(filter == "") {
		printf("</body></html>\n")
	}
}
