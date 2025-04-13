
with Ada.Strings.Maps;
with Ada.Strings.Unbounded;

package HostARM_Tools is

   use Ada.Strings.Maps;

   subtype UString is Ada.Strings.Unbounded.Unbounded_String;

   To_Lower_Case : constant Character_Mapping :=
     To_Mapping (From => To_Sequence (To_Set ("ABCDEFGHIJKLMNOPQRSTUVWXYZ")),
                 To   => To_Sequence (To_Set ("abcdefghijklmnopqrstuvwxyz")));

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
