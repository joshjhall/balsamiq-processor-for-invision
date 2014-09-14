Invision
========

Automatically convert BMML files into PNG for Balsamiq integration with InVision



Setup
=====

Start by making sure you have the command line x-code tools installed.  Open a terminal window and run `gcc` to force the installer if needed (will complain about not having any input files if the command line tools are already installed).


Homebrew
--------
Could also use Macports, but Homebrew ([http://brew.sh]) is generally easier to get setup and running correctly with RVM.  Once installed, run the following commands to install some of the dependencies.
* `brew install node`
* `brew install osxutils`


RVM
---
Needed to install Ruby and gems into a sandboxed environment.  Generally a good idea, and mitigates the need for su rights all of the time.  Install instructions are available at [http://rvm.io/].  Homebrew needs to be installed first, so additional depenencies can be installed and compiled.  Install Ruby 2.1.2 with `rvm install ruby-2.1.2`, because this is what I've tested everything with (later versions should be fine, but may require some debugging and updated dependencies).

Changing to the project directory in terminal will automatically install the gem dependencies.  However, you can also run `bundle` in the correct directory to ensure they're installed.


Balsamiq Site Assets
--------------------
Designers or PMs that use the Balsamiq desktop editor need to install `BalsamiqMockups.cfg` to have access to the global components.

This is pretty easy to do.

1. Open the desktop version of Balsamiq
2. Go to `File > About`
3. Click on `Open Local Store Folder`
4. Copy `BalsamiqMockups.cfg.sample` from the ./config directory to the local store folder
5. Rename `BalsamiqMockups.cfg.sample` to `BalsamiqMockups.cfg`
6. Open `BalsamiqMockups.cfg` with a text editor, and update the path.  This should be the absolute path pointing to the Components project on InVision.  You'll need to restart Balsamiq if it's running.

You should now have access to all of the global assets.


Launchctl (preferred on OS X)
-----------------------------
Install the launchctl plist to the local user account.  Unfortunately, this can't run as a background service, because we're relying upon Adobe Air / Flash to render the PNGs.  I recommend setting up the transcode machine to automatically sign in on boot.



Settings
========

There are several settings, but these are mostly self-explantory.  Tilda (~) can be used as a pseudonym for the local home directory.
* `accountRoot` => Path to InVision sync directory
* `balsamiqBin` => Path to Balsamiq executable (typically won't need to be changed)
* `exportLog` => Path to the export log file (typically won't need to be changed)
* `listenerLog` => Path to the listener log file (typically won't need to be changed)
* `componentsProject` => Project that contains the components project (used as site assets in Balsamiq)



Script Usage
============

Rake tasks
----------
Rake tasks allow manual access to key functions.  Basic syntax is `rake task`.  An optional parameter can be passed to identify the requestor `rake task[user_name]`; however, this isn't necessary as parallel processing isn't useful in this context.

* `rake `



TODO
====

* Improve documentation of the processes
* Expand script to keep track of files that have or haven't been updated.  Preferably store a hash of each bmml to check against and determine if an export is necessary.  This would substantially help if the transcode machine goes offline, or something is missed by the listener (in short, error recovery)
* Instead of mass exporting for updated components or project assets, parse each bmml and determine if it's required on a per file basis
* Use stored hash / bmml file list to also cleanup old PNGs during recovery
