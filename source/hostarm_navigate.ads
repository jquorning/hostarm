
with Ada.Strings.Unbounded;

package HostARM_Navigate is

   use Ada.Strings.Unbounded;
   subtype UString is Ada.Strings.Unbounded.Unbounded_String;

   type Nav_Info is
      record
         Contents  : UString;
         Index     : UString;
         Reference : UString;
         Search    : UString;
         Next      : UString;
         Prev      : UString;
      end record;

   Empty_Info : constant Nav_Info :=
      (others => Null_Unbounded_String);

   function Default_Info (Next : in String;
                          Prev : in String)
                          return Nav_Info;

   procedure Read_Navigation (Payload : in UString;
                              Info    : out Nav_Info);

   procedure Insert_JS_Key_Navigation (Payload : in out UString;
                                       Info    : in     Nav_Info);

end HostARM_Navigate;
