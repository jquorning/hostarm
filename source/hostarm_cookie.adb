
with HostARM_RFC3875;

package body HostARM_Cookie is

   use HostARM_RFC3875;

   Key_Manual          : constant String := "Manual";
   Key_Pyne_Nav_Top    : constant String := "Pyne_Nav_Top";
   Key_Pyne_Nav_Bottom : constant String := "Pyne_Nav_Bottom";
   Key_Pyne_Banner     : constant String := "Pyne_Banner";
   Key_Pyne_Sponsor    : constant String := "Pyne_Sponsor";
   Key_Modernize       : constant String := "Modernize";

   --------------------
   -- Get_Or_Default --
   --------------------

   procedure Get_Or_Default (State : out Config.State_Type)
   is
      use Config;
   begin
      State := (
         Manual => ARM_Version'Value (Cookie_Value (
            Key      => Key_Manual,
            Required => True)),

         Pyne_Nav_Top => Boolean'Value (Cookie_Value (
            Key      => Key_Pyne_Nav_Top,
            Required => True)),

         Pyne_Nav_Bottom => Boolean'Value (Cookie_Value (
            Key      => Key_Pyne_Nav_Bottom,
            Required => True)),

         Pyne_Banner => Boolean'Value (Cookie_Value (
            Key      => Key_Pyne_Banner,
            Required => True)),

         Pyne_Sponsor => Boolean'Value (Cookie_Value (
            Key      => Key_Pyne_Sponsor,
            Required => True)),

         Modernize => Boolean'Value (Cookie_Value (
            Key      => Key_Modernize,
            Required => True))
      );

   exception when others =>
      State := Config.Default_State;
   end Get_Or_Default;

   -----------------
   -- Set_Cookies --
   -----------------

   procedure Set_Cookies (State : in Config.State_Type)
   is
      use Config;

      Expires : constant String := "Fri, 05 Jun 2037 15:30:00 GMT";
   begin
      Set_Cookie (
         Key     => Key_Manual,
         Value   => ARM_Version'Image (State.Manual),
         Expires => Expires);

      Set_Cookie (
         Key     => Key_Pyne_Nav_Top,
         Value   => Boolean'Image (State.Pyne_Nav_Top),
         Expires => Expires);

      Set_Cookie (
         Key     => Key_Pyne_Nav_Bottom,
         Value   => Boolean'Image (State.Pyne_Nav_Bottom),
         Expires => Expires);

      Set_Cookie (
         Key     => Key_Pyne_Banner,
         Value   => Boolean'Image (State.Pyne_Banner),
         Expires => Expires);

      Set_Cookie (
         Key     => Key_Pyne_Sponsor,
         Value   => Boolean'Image (State.Pyne_Sponsor),
         Expires => Expires);

      Set_Cookie (
         Key     => Key_Modernize,
         Value   => Boolean'Image (State.Modernize),
         Expires => Expires);
   end Set_Cookies;

end HostARM_Cookie;
