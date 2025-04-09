with Ada.Text_IO;

with Hostarm_Config;
with Hostarm_Server;

-------------
-- Hostarm --
-------------

procedure Hostarm is	
   package Config renames Hostarm_Config;
begin

   Ada.Text_IO.Put_Line
     ("Starting web server on port:" & Config.Default_Port'Image);

   Hostarm_Server.Start;
   Hostarm_Server.Wait;
   Hostarm_Server.Stop;

end Hostarm;
