
with Ada.Strings.Unbounded;

package HostARM_Navigate is

   use Ada.Strings.Unbounded;
   subtype UString is Ada.Strings.Unbounded.Unbounded_String;

   type Legend_Info is private;
   Empty_Info : constant Legend_Info;

   procedure Read_Navigation_Legend (Payload : in UString;
                                     Info    : out Legend_Info);

   procedure Insert_JS_Script (Payload : in out UString;
                               Info    : in     Legend_Info);

private

   type Legend_Info is
      record
         Contents  : UString;
         Index     : UString;
         Reference : UString;
         Search    : UString;
         Next      : UString;
         Prev      : UString;
      end record;

   Empty_Info : constant Legend_Info :=
      (others => Null_Unbounded_String);

end HostARM_Navigate;
