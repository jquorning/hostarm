with Ada.Strings.Unbounded;

package HostARM_Tools is

   subtype UString is Ada.Strings.Unbounded.Unbounded_String;

   procedure Load_File (Name    : in     String;
                        Payload :    out UString);

end HostARM_Tools;
