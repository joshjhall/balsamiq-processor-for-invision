HEAD
====

* TODO: Update README
* TODO: Update cron job plist
* TODO: Daemonized Sidekiq and Redis setup instructions


2.0 beta (2014-12-29)
---------------------

* Refactored into a Sidekiq queue
* Major cleanup of race condition bugs
* REMOVED all delete capabilities, because InVision sync isn't ready (especially through Dropbox)


1.0 (2014-09-13)
----------------

* Generate PNG from BMML and drop into the related screens directory
* Ignores BMML in the /assets directory when generating PNGs
* Removes bad directories from the output path
* Writes log entries to both file and console
* Refactored logging to be consistent everywhere
* Refactored settings to be centralized
* Supports sub-directories of wireframes
* Added rake tasks to update gem dependencies