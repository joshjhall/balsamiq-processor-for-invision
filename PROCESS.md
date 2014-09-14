# InVision Process

## PM
Focussed on UE output (via InVision web interface), and PM document store.

* Desktop versions of Balsamiq can be acquired through http://toolan.intel.com/.  Do a manufactor search for “balsamiq”.  It’s $54 per head.  Anybody that needs to edit a wireframe, needs this application installed (setup instructions separate).
* InVision client / file sync.  Anybody running OS X (Windows will be supported in the future) can use the InVision client to sync files locally (similar to Dropbox).  So, you can work while offline, and updates will be synced when you go back online.  Documents can be added and downloaded from the web interface directly, so the client isn't necessary (but very helpful).
* I recommend storing PM documents (requirements, POP, etc.) in a separate directory within the project.  This keeps things consolidated around the project.  The proposed directory structure for a project is explained below.
* The project name should be mirrored as a project in Rally where work progress is tracked.
* Callouts and business logic are added via the InVision web editor on top of the wireframes and redlines.  This allows for easy tracking and collaboration across teams.  You can also subscribe to specific projects to recieve updates when things are changed, or when somebody responds to a callout.  Questions or clarifications can be added directly to the callout by anybody on the team (e.g., PM clarifies a use-case on a callout created by UE).


## Engineering / QA
Focussed on UE output (via InVision web interface), and engineering design document store.

* InVision client / file sync.  Anybody running OS X (Windows will be supported in the future) can use the InVision client to sync files locally (similar to Dropbox).  So, you can work while offline, and updates will be synced when you go back online.  Documents can be added and downloaded from the web interface directly, so the client isn't necessary (but very helpful).
* I recommend storing engineering design documents in a separate directory within the project.  This keeps things consolidated around the project.  The proposed directory structure for a project is explained below.
* The project name should be mirrored as a project in Rally where work progress is tracked.
* Callouts and business logic are added via the InVision web editor on top of the wireframes and redlines.  This allows for easy tracking and collaboration across teams.  You can also subscribe to specific projects to recieve updates when things are changed, or when somebody responds to a callout.  Questions or clarifications can be added directly to the callout by anybody on the team (e.g., engineer asks about an edge case on a callout created by UE, then PM or UE can respond in the conversation thread for that callout).


## UE
Focussed on asset creation, and business logic callouts (via InVision web interface).

* Desktop versions of Balsamiq can be acquired through http://toolan.intel.com/.  Do a "manufactor" search for “balsamiq”.  It’s $54 per head.  Anybody that needs to edit a wireframe, needs this application installed (setup instructions separate).
* InVision client / file sync.  Anybody running OS X (Windows will be supported in the future) can use the InVision client to sync files locally (similar to Dropbox).  So, you can work while offline, and updates will be synced when you go back online.  The file sync client is necessary for UE work, because file updates are far more frequent than PM or engineering.
* The project name should be mirrored as a project in Rally where work progress is tracked.
* Callouts and business logic are added via the InVision web editor on top of the wireframes and redlines.  This allows for easy tracking and collaboration across teams.  You can also subscribe to specific projects to recieve updates when things are changed, or when somebody responds to a callout.  Questions or clarifications can be added directly to the callout by anybody on the team (e.g., UE clarifies a use-case on a callout question from engineering).


## InVision Directory Structure
- Project Name
  - Assets => *Managed by UE:*
    - Source Files => Illustrator and Photoshop redlines
    - Wireframes => BMML wireframe source files (without comments)
      - assets => project assets used by across the project wireframes
  - Engineering Designs => *Managed by engineering:*  Engineering design specs and documents
  - PM Documents => *Managed by PM:*  Requirements, research, SSNiFs and other supplementary documents
  - Screens => *Automatically managed by UE:*  Automatically generated output from Assets
