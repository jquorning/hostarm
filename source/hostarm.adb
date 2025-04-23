
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

procedure HostARM
 is
   package Config renames HostARM_Configuration;
   use Ada.Text_IO, Ada.Strings;
   use Ada.Command_Line;
   use Config;

   Found : Boolean := False;
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
      Put_Line ("    hostarm [--help] | [--version] | [<Path>]");
      New_Line;
      Put_Line ("ARGUMENTS");
      Put_Line ("    <Path> - Path of shared.");
      return;
   end if;

   if Argument_Count = 1 then
      if Looking_Valid (Argument (1) & "hostarm/") then
         Found := True;
         Set_Directory (Argument (1) & "hostarm/");
      else
         Put_Line ("HostARM: Shared resource '" & Argument (1) &
                   "' not found or not valid.");
         return;
      end if;

   elsif Argument_Count = 0 then

      Find_Resource_Path :
      for A in Share_Candidate_Index'Range loop
         if Looking_Valid (Share_Candidate_Path (A) & "hostarm/") then
            Found := True;
            Set_Directory (Share_Candidate_Path (A) & "hostarm/");
            exit Find_Resource_Path;
         end if;
      end loop Find_Resource_Path;

      if not Found then
         Put_Line ("HostARM: Shared resource not found in");
         for A in Share_Candidate_Index'Range loop
            Put_Line ("    " & Share_Candidate_Path (A));
         end loop;
         return;
      end if;
   end if;

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
