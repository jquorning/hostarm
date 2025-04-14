
with Ada.Strings.Fixed;
with Ada.Text_IO;

with AWS.Net;

with HostARM_Configuration;
with HostARM_Server;
with HostARM_Tipue;

-------------
-- HostARM --
-------------

procedure HostARM is
   package Config renames HostARM_Configuration;
   use Ada.Text_IO, Ada.Strings;
begin
   HostARM_Tipue.Build_Content (Config.ARM_2012);
   HostARM_Tipue.Build_Content (Config.ARM_2022);
   HostARM_Tipue.Build_Content (Config.AARM_202Y);

   HostARM_Server.Start;
   Put_Line ("HostARM: Accessible on URL: https://localhost:"
             & Fixed.Trim (Config.Default_Port'Image, Side => Left)
             & "/");

   HostARM_Server.Wait;
   Put_Line ("HostARM: Shutting down");

   HostARM_Server.Stop;

exception
   when AWS.Net.Socket_Error =>
      Put_Line (Standard_Error,
                "HostARM: Socket in use. Try waiting 10 seconds and "
                & "then try again");
end HostARM;
