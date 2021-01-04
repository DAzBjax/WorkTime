# WorkTime
PRIVACY -> All your data tracks in \DB\ folder, remove it if you needed
 - !!! Does not hide your data, do not use it in public locations, or add data hiding/crypto.


1. Must be started with admin rights, win32 DOES NOT WORKS in amd64 platfroms, Use win64 in AMD64 platforms.
2. Admins manifest already applyed for project, for DEBUG -> starts delphi with admins rights.
3. Automatically restarts when new day reached, have Mutex for preventing starts of 2 more instances.
4. Filters in \WCards\X-Category\ExeName.txt, where:
    - X - is an integer for sorting categories, 
    - ExeName - is 'exe name' for filter, .txt - is editable by notepad
5. X-Category\Color is 'one line text file' with R.G.B color data (in bytes 0-255) for charts 255.0.0 -> clRed
6. X-Category\Default is an empty file for category that will be DEFAULT for all UNMATCHED processes. 


ExeName.txt is multiline filter file, where each line is:
 - '\*' + 'LINE TEXT FROM FILE' + '\*', for filtering forms feaders. '\*' as first and last character will add automaticaly. File does not contains it '\*', but you can add it if you needed
 - an empty file meaning just '\*' filter
 - new lines can be added by double clicking an line in ListView, edit mask and save.


How it works : 
 1. Every 1000ms -> Track 'active form header' and it '.exe' -> filter this data by \WCards\X-Category\ExeName.txt -> Add into filtered 'Category'
 2. Saves data every 10s or OnApplicationExit only for changed processes.
 3 .Re-Filters TODAY data only OnApplicationRestart
