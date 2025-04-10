with Ada.Text_IO;

with AWS.Net;

with HostARM_Config;
with HostARM_Server;
with HostARM_Tipue;

-------------
-- Hostarm --
-------------

procedure HostARM is
   package Config renames HostARM_Config;
   use Ada.Text_IO;
begin
   HostARM_Tipue.Build_Content (Config.ARM_Base & "/RM-0-4.html");
--   HostARM_Tipue.Dump_Content;

   Put_Line ("HostARM: Starting web server on port:"
             & Config.Default_Port'Image);

   HostARM_Server.Start;
   HostARM_Server.Wait;
   HostARM_Server.Stop;

exception
   when AWS.Net.Socket_Error =>
      Put_Line (Standard_Error,
                "HostARM: Socket in use. Try waiting 10 seconds and "
                & "then try again");
end HostARM;
