Dr. Scripto needs your help.  He is rolling out a monitoring solution and was promised some assistance but has been let down. He needs you to:

* Create a monitoring xml configuration file for each server from the data supplied in servers.csv. A sample file is part of the download package. The items that have to be monitored may be different between servers and not all items will be present for all servers
* 
* Copy that xml file to the appropriate server – path c:\drsmonitoring
  * If the path doesn’t exist it should be created
  * Store the config file on the local disk in c:\monitoringfiles
* Set registry value. Key - HKLM:\SOFTWARE\DRSmonitoing. The registry value Monitoring under that key should be set to 1. The registry key may or may not already exist.
The code should be able to perform bulk actions or work for a single server. The file copy and registry setting should be generic so that functionality can be re-used for other projects.

Dr. Scripto needs the following information gathering so that he can report on progress:

* Servers where the registry key existed and was set correctly
* Servers where the registry key existed and was set incorrectly
* Servers where the registry key had to be created
* Servers that have had the monitoring config file installed

Dr.Scripto would like you to output the data as an object that can be optionally stored on disk. The object should have its own type and formatting (table and list). The data should be presented as a single report including server name and the data the test was performed. He would also like an html based report.

As a final option Dr. Scripto would like the ability to compare the configuration file on a remote server with the copy you created from the CSV file. This will test for unwanted changes. If a new file is rolled out it should overwrite the existing file in both the local store and the remote server.

Assume that you have permissions to the remote machines.

Your code should be production ready with:

* Ability to optionally report on progress
* Full error checking, reporting and handling
* Ability to accept pipeline input where appropriate
* Help is available
* Input is validated

In your entry submission, include a transcript that shows you running the command as described in this scenario.
