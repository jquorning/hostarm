
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
      Strip_Nav_Top    := Get (Request, "Strip_Nav_Top");
      Strip_Nav_Bottom := Get (Request, "Strip_Nav_Bottom");
      Strip_Title      := Get (Request, "Strip_Title");
      Strip_Sponsor    := Get (Request, "Strip_Sponsor");
   end Load;

   ----------
   -- Save --
   ----------

   procedure Save
   is
      use Config;
   begin
      Set (Response, "Manual",           Default_ARM'Image);
      Set (Response, "Strip_Nav_Top",    Strip_Nav_Top);
      Set (Response, "Strip_Nav_Bottom", Strip_Nav_Bottom);
      Set (Response, "Strip_Title",      Strip_Title);
      Set (Response, "Strip_Sponsor",    Strip_Sponsor);
   end Save;

end HostARM_Cookie;
