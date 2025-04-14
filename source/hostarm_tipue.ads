
with HostARM_Configuration;

with Ada.Strings.Unbounded;

package HostARM_Tipue is

   package Config renames HostARM_Configuration;

   subtype UString is Ada.Strings.Unbounded.Unbounded_String;

   procedure Build_Content (Version : in Config.ARM_Version);
   --  Build database of search results to 'tipuesearch_contents.js'.

   function Get_Content (Version : in Config.ARM_Version)
                         return UString;

   procedure Dump_Content (Version : in Config.ARM_Version);
   --  Dump Contents to Standard output.

end HostARM_Tipue;
