
with HostARM_Configuration;
with HostARM_Tools;

package HostARM_Pyning is

   package Config renames HostARM_Configuration;
   package Tools  renames HostARM_Tools;

   procedure Pyne (Item  : in out Tools.UString;
                   State : in     Config.State_Type);

   procedure Replace_Doctype (Item : in out Tools.UString);

   procedure Replace_Style_CSS (Item : in out Tools.UString);

   procedure Append_Navigation_Bar (Item : in out Tools.UString);

end HostARM_Pyning;
