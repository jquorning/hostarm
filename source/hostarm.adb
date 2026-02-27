
with Ada.Command_Line;
with Ada.Strings.Fixed;
with Ada.Text_IO;

with Resources;

with Hostarm_Config;
with HostARM_Configuration;
with HostARM_Server;
with HostARM_Tipue;

-------------
-- HostARM --
-------------

procedure HostARM
is
   package Config renames HostARM_Configuration;
   use Ada.Text_IO, Ada.Strings;
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
      Put_Line ("    Start HostARM and then access (Annotated) Ada Reference");
      Put      ("    Manual in the web browser address ");
      Put_Line ("htts://localhost:2778/.");
      New_Line;
      Put_Line ("USAGE");
      Put_Line ("    hostarm [--help] | [--version] | [--port=PORT]");
      New_Line;
      return;
   end if;

   if Argument_Count = 1 then
      declare
         Arg   : constant String  := Argument (1);
         Equal : constant Natural := Ada.Strings.Fixed.Index (Arg, "=");
      begin
         if Equal = 0 or Arg (Arg'First .. Equal) /= "--port=" then
            Put_Line ("HostARM: Argument error in " & Arg & ".");
            return;
         end if;
         Config.Server_Port :=
           Natural'Value (Arg (Equal + 1 .. Arg'Last));

      exception
         when others =>
            Put_Line ("HostARM: Argument error in " & Arg & ".");
            return;
      end;
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

   HostARM_Server.Start;
   Put_Line ("HostARM: Accessible on URL: http://localhost:"
             & Fixed.Trim (Config.Server_Port'Image, Side => Left)
             & "/");

   HostARM_Server.Wait;
   Put_Line ("HostARM: Shutting down");

   HostARM_Server.Stop;

end HostARM;
