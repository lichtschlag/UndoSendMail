##What it does

#UndoSendMail

Here's a little plugin to Mail.app which I wrote because I missed Gmail's functionality to delay the sending of Emails for a short time.
This plug-in will do exactly that.
So: write a mail, hit send, and you'll have some time to review your text before it is sent for good. 
Hit send (Command-Shift-D) again to abort the sending and edit it once more.

This software is not finished, not supported by Apple or me, has not a particularly well designed user experience, and does contain bugs.
I built this for myself, and for now, this will remain the scope of this project. 
Use this software only if you are a programmer and know what you are doing.
That said, I'll be happy to hear about suggestions and pull requests.

*Use at your own risk.*

— Leonhard Lichtschlag <br />leonhard@lichtschlag.net


##Installation:
1. Complile with Xcode
2. Copy product to ~/Library/Mail/Bundles/


##Uninstallation:
1. Delete ~/Library/Mail/Bundles/UndoSendMail.mailbundle


##Debugging:
Of course, future releases of Mail.app can break the plug-in functionality.
Mail.app loads only plug-ins that advertise to be compatible with the respective version of Mail. If Mail gets updated (e.g. a point release on Mac OS) all plug-ins (including UndoSendMail) need to whitelist the release in the Info.plist.
Should UndoSendMail encounter problems that it cannot deal with, it will complain on the console.
Should UndoSendMail crash Mail, Mail.app will quarantine the bundle from the plug-in folder.
