<#
.SYNOPSIS
    Script to detect and sync new annotated debugs to the TFS server
    automatically
.DESCRIPTION
    Script checks, current git status, and if changes are
    detected, does an add, commit, and push operation to sync changes to the
    server.
    Task scheduler task should be created to run this script on some reoccuring
    time cycle on a system where network share is configured as a git local
    repository.
    Local system MUST be configured with the network share as a local GIT
    repository of the TFS project targeted for sync.  All GIT commands assume
    local repository is configured correctly.
.NOTES
    Author: Erik L. Philemonoff
.EXAMPLE
    PS > Sync-Annotation.ps1
#>

Write-Host "Checking for new annotated debug records to push..."

# Path to annotated debug share
$DebugUserPath = "\\wosdbg.amr.corp.intel.com\Users\debug"
$AnnotatedDebugPath = ($DebugUserPath + "\annotated")

# This is the string we search for to determine if any changes have been made.
# No changes to this string are expected, but future git build could change
# this.
[string]$CleanStatusLine = "nothing to commit, working tree clean"

# Working directory is not preserved by Task Scheduler when calling into
# PowerShell, so need to change directory so the git commands will operate on
# the correct files.
cd $AnnotatedDebugPath

# Since Task Scheduler process is hidden from desktop, need to log the output
# somewhere so we can observe status and output of sync script.  Transcript
# allows automatic capture of all output with a pair of encapsulating commands
# as opposed to redirecting every line to file.
Start-Transcript -Append -Path ($DebugUserPath + "\AutoSyncAnnotationLog.txt")

# Collect the current status of share folder as a local git repository.  If
# string is found in output indicating no changes, then we can exit the script
# now.
$gitStatus = git status
if( $gitStatus.Contains($CleanStatusLine) ){
    Write-Host "Working tree is clean.  No changes to sync."
    Stop-Transcript
    exit
}
#else continue...

Write-Host "┌─────────────────────────────────────────────────────────────────────────────┐"
Write-Host "│  Changes detected.  Starting Sync.                                          │"
Write-Host "└─────────────────────────────────────────────────────────────────────────────┘"

# git add * will automatically add all modified or new files in the share, or
# its sub-directories to staging.

# git commit will commit all staged files to local repository

#git push will sync all commited changes from local repository to TFS server.

# Add '--dry-run' argument to all 3 of these commands to disable actual
#   operation when debugging or modifying script.
# This will cause commands to output enough data to tell if script is
#   working without actually modifying the contents on production
#   server.
git add *
git commit -m ("Automatic sync by scheduled script. {0}" -f (Get-Date))
git push

Stop-Transcript