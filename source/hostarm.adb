
with Ada.Command_Line;
with Ada.Text_IO;

with Resources;

with Hostarm_Config;
with HostARM_Configuration;
with HostARM_Dispatcher;
with HostARM_Tipue;

-------------
-- HostARM --
-------------

procedure HostARM is
   package Config renames HostARM_Configuration;
   use Ada.Text_IO; -- , Ada.Strings;
   use Ada.Command_Line;
   use Config;

   package Resource is new Resources (Hostarm_Config.Crate_Name);
begin
   if Argument_Count = 1 and then Argument (1) = "--version" then
      Put_Line ("HostARM version " & Hostarm_Config.Crate_Version);
      return;
   end if;

   if Argument_Count = 1 and then Argument (1) = "--help" then
      Put_Line ("SUMMARY");
      Put_Line (
        "    HostARM provides (Annotated) Ada Reference " &
        "Manual.");
      Put_Line (
        "    HostARM is a CGI program ment to run from a " &
        "web server.");
      New_Line;
      Put_Line ("USAGE");
      Put_Line ("    hostarm [--help] | [--version]");
      New_Line;
      return;
   end if;

   if Looking_Valid (Resource.Resource_Path) then
      Set_Directory (Resource.Resource_Path);
   else
      Put_Line
        ("HostARM: Assets not found in " & Resource.Resource_Path & ".");
      return;
   end if;

   HostARM_Tipue.Build_Content (Config.ARM_2012);
   HostARM_Tipue.Build_Content (Config.ARM_2022);
   HostARM_Tipue.Build_Content (Config.AARM_202Y);

   HostARM_Dispatcher.Run;
--   HostARM_Dispatcher.Start;
--   Put_Line
--     ("HostARM: Accessible on URL: http://localhost:" &
--      Fixed.Trim (Config.Server_Port'Image, Side => Left) & "/");

--   HostARM_Dispatcher.Wait;
--   Put_Line ("HostARM: Shutting down");

--   HostARM_Dispatcher.Stop;

--  exception
--   when Program_Error =>
--      Put_Line ("HostARM: Could not start server.");
--      Put_Line ("HostARM: Port in use or missing permission.");
end HostARM;
