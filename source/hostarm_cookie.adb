
with AWS.Cookie;

package body HostARM_Cookie is

   use AWS.Cookie;

   Key_Manual          : constant String := "Manual";
   Key_Pyne_Nav_Top    : constant String := "Pyne_Nav_Top";
   Key_Pyne_Nav_Bottom : constant String := "Pyne_Nav_Bottom";
   Key_Pyne_Banner     : constant String := "Pyne_Banner";
   Key_Pyne_Sponsor    : constant String := "Pyne_Sponsor";

   --------------------
   -- Get_Or_Default --
   --------------------

   procedure Get_Or_Default (Request : in     AWS.Status.Data;
                             State   :    out Config.State_Type)
   is
      use Config;
   begin
      if not Exists (Request, Key_Manual) then
         State := Config.Default_State;
         return;
      end if;

      State :=
         (Manual =>
            ARM_Version'Value (String'(Get (Request, Key_Manual))),
          Pyne_Nav_Top    => Get (Request, Key_Pyne_Nav_Top),
          Pyne_Nav_Bottom => Get (Request, Key_Pyne_Nav_Bottom),
          Pyne_Banner     => Get (Request, Key_Pyne_Banner),
          Pyne_Sponsor    => Get (Request, Key_Pyne_Sponsor)
         );
   end Get_Or_Default;

   ---------
   -- Set --
   ---------

   procedure Set (Response : in out AWS.Response.Data;
                  State    : in     Config.State_Type)
   is
      use Config;
   begin
      Set (Response, Key_Manual,          State.Manual'Image);
      Set (Response, Key_Pyne_Nav_Top,    State.Pyne_Nav_Top);
      Set (Response, Key_Pyne_Nav_Bottom, State.Pyne_Nav_Bottom);
      Set (Response, Key_Pyne_Banner,     State.Pyne_Banner);
      Set (Response, Key_Pyne_Sponsor,    State.Pyne_Sponsor);
   end Set;

end HostARM_Cookie;
