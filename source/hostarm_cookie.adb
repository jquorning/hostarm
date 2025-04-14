
with AWS.Cookie;
with AWS.Response;
with AWS.Status;

with HostARM_Configuration;

package body HostARM_Cookie is

   package Config renames HostARM_Configuration;
   use AWS.Cookie;

   Request  : AWS.Status.Data;
   Response : AWS.Response.Data;

   Key_Manual          : constant String := "Manual";
   Key_Pyne_Nav_Top    : constant String := "Pyne_Nav_Top";
   Key_Pyne_Nav_Bottom : constant String := "Pyne_Nav_Bottom";
   Key_Pyne_Banner     : constant String := "Pyne_Banner";
   Key_Pyne_Sponsor    : constant String := "Pyne_Sponsor";

   ------------
   -- Exists --
   ------------

   function Exists return Boolean
   is
   begin
      return Exists (Request, Key_Manual);
   end Exists;

   ----------
   -- Load --
   ----------

   procedure Load
   is
      use Config;
   begin
      Settings.Manual :=
         ARM_Version'Value (String'(Get (Request, Key_Manual)));
      Settings.Pyne_Nav_Top    := Get (Request, Key_Pyne_Nav_Top);
      Settings.Pyne_Nav_Bottom := Get (Request, Key_Pyne_Nav_Bottom);
      Settings.Pyne_Banner     := Get (Request, Key_Pyne_Banner);
      Settings.Pyne_Sponsor    := Get (Request, Key_Pyne_Sponsor);
   end Load;

   ----------
   -- Save --
   ----------

   procedure Save
   is
      use Config;
   begin
      Set (Response, Key_Manual,          Settings.Manual'Image);
      Set (Response, Key_Pyne_Nav_Top,    Settings.Pyne_Nav_Top);
      Set (Response, Key_Pyne_Nav_Bottom, Settings.Pyne_Nav_Bottom);
      Set (Response, Key_Pyne_Banner,     Settings.Pyne_Banner);
      Set (Response, Key_Pyne_Sponsor,    Settings.Pyne_Sponsor);
   end Save;

end HostARM_Cookie;
