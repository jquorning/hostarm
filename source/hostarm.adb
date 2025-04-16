
with Ada.Command_Line;
with Ada.Strings.Fixed;
with Ada.Text_IO;

with AWS.Net;

with Hostarm_Config;
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
   declare
      use Ada.Command_Line;
   begin
      if Argument_Count = 1 and then Argument (1) = "--version" then
         Put_Line ("HostARM version " & Hostarm_Config.Crate_Version);
         return;
      end if;

      if Argument_Count = 1 and then Argument (1) = "--help" then
         Put_Line
           ("Start HostARM and then access (Annotated) Ada Reference " &
            "Manual in the web browser address htts://localhost:2778/.");
         return;
      end if;
   end;

   HostARM_Tipue.Build_Content (Config.ARM_2012);
   HostARM_Tipue.Build_Content (Config.ARM_2022);
   HostARM_Tipue.Build_Content (Config.AARM_202Y);

   HostARM_Server.Start;
   Put_Line ("HostARM: Accessible on URL: https://localhost:"
             & Fixed.Trim (Config.Default_Port'Image, Side => Left)
             & "/");
   Put_Line ("HostARM: Press 'Q' to quit.");

   HostARM_Server.Wait;
   Put_Line ("HostARM: Shutting down");

   HostARM_Server.Stop;

exception
   when AWS.Net.Socket_Error =>
      Put_Line (Standard_Error,
                "HostARM: Socket in use. Try waiting 2 minutes and "
                & "then try again");
end HostARM;
