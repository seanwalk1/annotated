script and task scheduler object are stored on
\\wosdbg\Users\debug\annotated\AutoUpdate, and synced to the git repository
https://wosgitsla/wos/MTC%20Annotated%20Debug.

All the git commands can have the –dry-run argument to prevent them from
making any actual changes to TFS.  Is recommeneded to make this change, and
save the script before making any other changes to the script.  Then remove
these arguments and save the completed script when finished editing.

The task is scheduled to run on system startup and every hour after that.  It
is recommended the box running this script have firmware or hardware TPM, so if
it is rebooted, the task should just start back up without any need for manual
intervention.  Currently the script and task are not configured to run on an IT
managed server with ops support.

Script functions by using a cloned TFS repository as a local repo in PowerShell
but uses the path to the original share, \\wosdbg\Users\debug\annotated, as the
local path to sync files to.  Once this is configured the script leverages the
git status command to check for modifications.  If it finds any, it uses the
default git behavior in add/commit wildcards to grab all changes, commit them,
and finally the git push command to upload to TFS.

There currently is little error checking because we are unaware of what errors
could occur to check for.  This is an obvious area for future improvement.
Until then, logs should be checked regulary for unexpected output.

If the password expires or is changed for user whose credentials the task
scheduler is running under, the task scheduler will fail to launch the task.
The script will not be called as task scheduler will throw an error at task
trigger before script is run.  If the script is not running, the updated
timestamp of the log file at \\wosdbg\Users\debug\AutoSyncAnnotationLog.txt
should be noticeably stale.  The last updated timestamp should never be more
than an hour ago at most.

To fix this, open the task in task scheduler for edit, then click ok.  Task
Scheduler will prompt for new credentials.  Also update your password in the
Credential Manager as you would for any TFS git access, as this will also
prevent the sync script of completing any git commands.

To configure this sync to run on a new system.
  1. Clone TFS git repository https://wosgitsla/wos/MTC%20Annotated%20Debug to
     path \\wosdbg\Users\debug\annotated
  2. Import the 'Annotated Debug Auto-Sync.xml' task into Task Scheduler from
     \\wosdbg\Users\debug\annotated\AutoUpdate
  3. Restart system to trigger task, and begin timed triggering