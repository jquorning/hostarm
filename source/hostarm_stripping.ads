with HostARM_Tools;

package HostARM_Stripping is

   package Tools renames HostARM_Tools;

   procedure Strip (Item : in out Tools.UString);

   procedure Replace_Doctype (Item : in out Tools.UString);

   procedure Replace_Style_CSS (Item : in out Tools.UString);

   procedure Append_Navigation_Bar (Item : in out Tools.UString);

end HostARM_Stripping;
