
```
from logs-endpoint //Select the index/indices you would like to query
| where event.category == "file" and event.action == "creation" //Apply some filtering
| stats filecount = count(file.name) by process.name,host.name //Create a new field called "filecount". It's value is going to be a count of all the file name on a host, split by the host name and process name
| eval split = process.name | dissect split "%{process}.%{extension}" //Create a field called "split", which is going to be equal to the value of process.name. Pipe that into a dissect function, so we can parse out the content in the process.name field further into two more fields - "process" and "extension". This is just to demonstrate some additional in-line parsing capability.
| eval fullproc = concat(process, ".", extension) // this is the exact inverse of the previous line. Create a new field called "fullproc" which is the concatonation of the "process" and "extension" fields
| eval proclength = length(process.name) //create a new field called "proclength". The value will be detemined based on the length of the process.name field
| where proclength > 10 //filter for those events where the proclength is greater than 10 characters
| sort filecount,proclength desc // sort the results by filecount and proclength in descending order
| limit 10 //limit the results to the top 10
| project host.name,process.name,filecount,process,extension,fullproc,proclength //show only these fields, in this order.
```


## Logic to use to_string(), CASE(), date_extract()

```
from *:myindex*
| EVAL year = to_string(date_extract("year", @timestamp))
| EVAL month = to_string(date_extract("month_of_year", @timestamp))
| EVAL date = to_string(date_extract("day_of_month", @timestamp))
| EVAL yyyymmdd = CONCAT(year,"-",month,"-", date)
| stats count=count(*) by yyyymmdd, event.action, sc_filter_result
| EVAL status = CASE(event.action is NULL,"System", CASE(event.action == "TCP_DENIED", "Denied",CASE(event.action != "TCP_DENIED" AND event.action is not NULL AND sc_filter_result != "DENIED","Allowed", "Other")))
| keep yyyymmdd, status, count

```
