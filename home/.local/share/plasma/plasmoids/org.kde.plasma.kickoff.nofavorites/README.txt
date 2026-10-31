Kickoff ("Application Launcher") without the "Favorites" entry in the sidebar
=============================================================================

Why: stock Kickoff always adds a "Favorites" row at the top of the sidebar
(applets/kickoff/main.qml hardcodes `showFavoritesPlaceholder: true`); there is
no setting to hide it.

What this is: a user-level (file based) copy of the Kickoff applet package based
on the Plasma/6.8 branch, with two small changes:

  contents/ui/main.qml
      RootModel: showFavoritesPlaceholder: false

  contents/ui/ApplicationsPage.qml
      * index 0 of the sidebar is now "All Applications" (instead of Favorites)
      * content view switching adapted accordingly
      * drop area for "drag to Favorites" removed (the row no longer exists)

The rest of the QML is an unmodified copy; the C++ side of the applet is
provided by the installed org.kde.plasma.kickoff plugin. Translations were
copied from plasma_applet_org.kde.plasma.kickoff.mo under
~/.local/share/locale/<lang>/LC_MESSAGES/.

The panel uses this package (plugin=org.kde.plasma.kickoff.nofavorites) in
~/.config/plasma-org.kde.plasma.desktop-appletsrc.

To revert: set plugin=org.kde.plasma.kickoff back for the applet and delete this
directory, then `systemctl --user restart plasma-plasmashell.service`.

Note: after a Plasma update, re-check that the copy still matches the installed
version (it is a fork of the 6.8 sources).
