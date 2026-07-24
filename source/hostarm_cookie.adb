
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

   procedure Get_Or_Default (Request : in     AWS.Status.Data;
                             State   :    out Config.State_Type)
   is
      use Config;
   begin
      State :=
         (Manual =>
            ARM_Version'Value (Cookie_Value (Key_Manual,
                                             Required => True)),
          Pyne_Nav_Top    =>
            Boolean'Value (Cookie_Value (Key_Pyne_Nav_Top,
                                         Required => True)),
          Pyne_Nav_Bottom =>
            Boolean'Value (Cookie_Value (Key_Pyne_Nav_Bottom,
                                         Required => True)),
          Pyne_Banner     =>
            Boolean'Value (Cookie_Value (Key_Pyne_Banner,
                                         Required => True)),
          Pyne_Sponsor    =>
            Boolean'Value (Cookie_Value (Key_Pyne_Sponsor,
                                         Required => True)),
          Modernize       =>
            Boolean'Value (Cookie_Value (Key_Modernize,
                                         Required => True))
         );
   exception when others =>
      State := Config.Default_State;
   end Get_Or_Default;

   ---------
   -- Set --
   ---------

   procedure Set (Response : in out AWS.Response.Data;
                  State    : in     Config.State_Type)
   is
      use Config;
   begin
      Set_Cookie (Key_Manual,          ARM_Version'Image (State.Manual));
      Set_Cookie (Key_Pyne_Nav_Top,    Boolean'Image (State.Pyne_Nav_Top));
      Set_Cookie (Key_Pyne_Nav_Bottom, Boolean'Image (State.Pyne_Nav_Bottom));
      Set_Cookie (Key_Pyne_Banner,     Boolean'Image (State.Pyne_Banner));
      Set_Cookie (Key_Pyne_Sponsor,    Boolean'Image (State.Pyne_Sponsor));
      Set_Cookie (Key_Modernize,       Boolean'Image (State.Modernize));
   end Set;

end HostARM_Cookie;
