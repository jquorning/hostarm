with Ada.Strings.Unbounded;

package HostARM_Tools is

   subtype UString is Ada.Strings.Unbounded.Unbounded_String;

   procedure Load_File (Name    : in     String;
                        Payload :    out UString);

   procedure Replace (Item    : in out UString;
                      Pattern : in     String;
                      By      : in     String);
   --  Replace first occurence of Pattern in Item with By.

   function Strip_Slash (URL : in String)
                         return String;
   --  Strip last slash, if any.

   function Tail_Is (Item  : in String;
                     Match : in String)
                     return Boolean;

end HostARM_Tools;
