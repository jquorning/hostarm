
with AWS.Cookie;

with HostARM_Configuration;

package body HostARM_Cookie is

   package Config renames HostARM_Configuration;
   use AWS.Cookie;

   ------------
   -- Exists --
   ------------

   function Exists (Request : in AWS.Status.Data)
                    return Boolean
   is
   begin
      return Exists (Request, "Manual");
   end Exists;

   ----------
   -- Load --
   ----------

   procedure Load (Request : in out AWS.Status.Data)
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

   procedure Save (Response : in out AWS.Response.Data)
   is
      use Config;
   begin
      Response := AWS.Response.Build (Content_Type => "text/plain",
                                      Message_Body => "");
      Set (Response, "Manual",           Default_ARM'Image);
      Set (Response, "Strip_Nav_Top",    Strip_Nav_Top);
      Set (Response, "Strip_Nav_Bottom", Strip_Nav_Bottom);
      Set (Response, "Strip_Title",      Strip_Title);
      Set (Response, "Strip_Sponsor",    Strip_Sponsor);
   end Save;

end HostARM_Cookie;
