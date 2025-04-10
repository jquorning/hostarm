
with Ada.Strings.Unbounded;

package HostARM_Tipue is

   subtype UString is Ada.Strings.Unbounded.Unbounded_String;

   procedure Build_Content (Index_File : in String);
   --  Build database of search results to 'tipuesearch_contents.js'.

   function Get_Content return UString;

   procedure Dump_Content;
   --  Dump Contents to Standard output.

end HostARM_Tipue;
