Balsamiq Site Assets
====================

Designers or PMs that use the Balsamiq desktop editor need to install `BalsamiqMockups.cfg` to have access to the global components.

This is pretty easy to do.
1. Open the desktop version of Balsamiq
2. Go to `File > About`
3. Click on `Open Local Store Folder`
4. Copy `BalsamiqMockups.cfg.sample` from the ./config directory to the local store folder
5. Rename `BalsamiqMockups.cfg.sample` to `BalsamiqMockups.cfg`
6. Open `BalsamiqMockups.cfg` with a text editor, and update the path.  This should be the absolute path pointing to the Components project on InVision.  You'll need to restart Balsamiq if it's running.

You should now have access to all of the global assets stored in the Components project.  Test by opening Balsamiq and looking for the symbol `ios-10-frame-portrait`, which comes from `iOS - frames.bmml`.
