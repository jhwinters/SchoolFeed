The code here is not a complete runnable program (although it's
taken from one).  It is intended to demonstrate generic code
which will take the XML output produced by the iSAMS batch API
and convert it into Ruby objects.  These objects can then
be iterated through, probably updating records in some other
system and thus keeping that system in step with the information
held in iSAMS.

The code was written to copy staff, pupil, room, group, timetable,
cover and activity information from iSAMS to Scheduler.

The code makes extensive use of Ruby's open classes.  That is,
the code which makes up a class can be written in several different
files, and even be varied at run-time.  Code which is specific to
iSAMS lives in the isams directory, whilst more code for the same
classes will be found in the misimport directory.
