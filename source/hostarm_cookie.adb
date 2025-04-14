
with AWS.Cookie;
with AWS.Response;
with AWS.Status;

with HostARM_Configuration;

package body HostARM_Cookie is

   package Config renames HostARM_Configuration;
   use AWS.Cookie;

   Request  : AWS.Status.Data;
   Response : AWS.Response.Data;

   ------------
   -- Exists --
   ------------

   function Exists return Boolean
   is
   begin
      return Exists (Request, "Manual");
   end Exists;

   ----------
   -- Load --
   ----------

   procedure Load
   is
      use Config;
   begin
      Default_ARM := ARM_Version'Value (String'(Get (Request, "Manual")));
      Pyne_Nav_Top    := Get (Request, "Pyne_Nav_Top");
      Pyne_Nav_Bottom := Get (Request, "Pyne_Nav_Bottom");
      Pyne_Banner     := Get (Request, "Pyne_Banner");
      Pyne_Sponsor    := Get (Request, "Pyne_Sponsor");
   end Load;

   ----------
   -- Save --
   ----------

   procedure Save
   is
      use Config;
   begin
      Set (Response, "Manual",          Default_ARM'Image);
      Set (Response, "Pyne_Nav_Top",    Pyne_Nav_Top);
      Set (Response, "Pyne_Nav_Bottom", Pyne_Nav_Bottom);
      Set (Response, "Pyne_Banner",     Pyne_Banner);
      Set (Response, "Pyne_Sponsor",    Pyne_Sponsor);
   end Save;

end HostARM_Cookie;
