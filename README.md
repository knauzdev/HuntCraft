# HuntCraft
A WoW 3.3.5 modding project that combines the game mechanics of Hunt: Showdown and World of Warcraft done over the course of 1 month. In this repository you'll find the client patch and Eluna scripts allowing you to run it yourself or just see how it was made. Fair warning, the server-side scripting is terrible and needs a full rewrite :P

# Instructions

*(prior experience with WoW Modding is recommended)*

1. Find and download a WoW 3.3.5.12340 client.
2. Pack the contents of "PATCH-V.MPC" folder into a WoW 3.3.5 MPQ-patch using MPQEditor and place it in your Data folder. (Or run it unpacked with a patched client)
3. Download or build TrinityCore with Eluna: https://github.com/ElunaLuaEngine/ElunaTrinityWotlk
4. Place the "lua_scripts" folder inside your TrinityCore+Eluna folder.
5. Setup your server: https://trinitycore.info/install/Core-Installation/windows-core-installation
6. Once trinitycore has set up the database for you: Run the "huntcraft world.sql" SQL-file, this should add the missing server db entries for you.
7. Copy the .dbc files from "PATCH-V.MPC/DBFilesClient" into your server "dbc" folder.
8. Should be good to go.

# Videos: 

[![Watch the video](https://img.youtube.com/vi/CvmnAJPkKck/0.jpg)](https://youtu.be/CvmnAJPkKck)

[![Watch the video](https://img.youtube.com/vi/I3_1GVudo-I/0.jpg)](https://youtu.be/I3_1GVudo-I)

# Credits
**Moldred:** Login-Screen Framework (original release seems to be lost to time but a reupload can be found here: https://github.com/haephaistoss/LoginScreen-by-Mordred) 
