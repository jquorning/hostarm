with Ada.Text_IO;

with HostARM_Config;
with HostARM_Server;
with HostARM_Tipue;

-------------
-- Hostarm --
-------------

procedure HostARM is
   package Config renames HostARM_Config;
begin
   HostARM_Tipue.Build_Content (Config.ARM_Base & "/RM-0-4.html");
--   HostARM_Tipue.Dump_Content;

   Ada.Text_IO.Put_Line
     ("Starting web server on port:" & Config.Default_Port'Image);

   HostARM_Server.Start;
   HostARM_Server.Wait;
   HostARM_Server.Stop;

end HostARM;
