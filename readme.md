#UndoSendMail

Here's a little plugin to Mail.app which I wrote because I missed Gmail's functionality to delay the sending of Emails for a short time.
This plug-in will do exactly that.
So: write a mail, hit send, and you'll have some time to review your text before it is send for good. 
Hit send (Command-Shift-D) again to abort the sending and edit it once more.

This software is not finished, not supported by Apple or me, has not a particularly well designed user experience, and does contain bugs.
I built this for myself, and for now, this will remain the scope of this project. 
Use this software only if you are a programmer and know what you are doing.
That said, I'll be happy to hear about suggestions and pull requests.

*Use at your own risk.*

— Leonhard Lichtschlag <br />leonhard@lichtschlag.net


##Compiling:
Built with Xcode 5 prerelease version, it will need minor tweaks with the build settings to compile on earlier versions.


##Installation:
1. Build
2. Copy to ~/Library/Mail/Bundles/


##Uninstallation:
1. Delete ~/Library/Mail/Bundles/UndoSendMail.mailbundle


##Debugging:
UndoSendMail will complain on the console if something is not working as expected. 
Also, Mail.app will quarantine UndoSendMail should it crash.
The Info.plist needs a key to whitelist each Mail.app release it is compatible with, so with each update to Mail.app this needs to be updated as well...
