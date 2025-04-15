
with Ada.Strings.Unbounded;

with HostARM_Configuration;
with HostARM_Navigate;

package HostARM_Modern is

   package Config renames HostARM_Configuration;

   subtype UString  is Ada.Strings.Unbounded.Unbounded_String;
   subtype Nav_Info is HostARM_Navigate.Nav_Info;

   procedure Make_Navigation_DIV (DIV     :    out UString;
                                  Nav     : in     Nav_Info;
                                  Version : in     Config.ARM_Version);

   procedure Insert_Navigation_DIV (Payload : in out UString;
                                    DIV     : in     UString);
   --  Insert DIV right after <BODY> in Payload.

end HostARM_Modern;
