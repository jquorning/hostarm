
with Ada.Strings.Fixed;
with Ada.Text_IO;

with AWS.Config.Set;
with AWS.Response;
with AWS.Parameters;
with AWS.Server;
with AWS.Services.Dispatchers.URI;
with AWS.Status;

with Templates_Parser;

with HostARM_Configuration;
with HostARM_Cookie;
with HostARM_Navigate;
with HostARM_Stripping;
with HostARM_Tipue;
with HostARM_Tools;

package body HostARM_Server is

   package Config renames HostARM_Configuration;
   package Tools  renames HostARM_Tools;

   Server_Name : constant String := "HostARM: Ada Reference Manual";
   Tipue_Path  : constant String := "/assets/tipuesearch";

   Server      : AWS.Server.HTTP;
   Server_Conf : AWS.Config.Object;
   Dispatcher  : AWS.Services.Dispatchers.URI.Handler;

   -------------------
   -- Service_THTML --
   -------------------

   function Service_THTML (Request : in AWS.Status.Data)
                           return AWS.Response.Data
   is
      use HostARM_Navigate;

      URI     : constant String
        := Tools.Strip_Slash (AWS.Status.URI (Request));
      Name    : constant String := Config.WWW_Base & URI & ".thtml";
      Payload : Tools.UString;
      Info    : constant Nav_Info := Default_Info (Next => "/search",
                                                   Prev => "/search");
   begin
      Tools.Load_File (Name, Payload);

      Insert_JS_Script (Payload, Info);

      return
         AWS.Response.Build (Content_Type    => "text/html",
                             UString_Message => Payload);
   end Service_THTML;

   --------------------
   -- Service_Config --
   --------------------

   function Service_Config (Request : in AWS.Status.Data)
                            return AWS.Response.Data
   is
      use HostARM_Navigate;
      use AWS.Parameters;
      use Templates_Parser;
      use Config;

      function Checked_If (Condition : in Boolean) return String is
      begin
         return (if Condition then "checked" else "");
      end Checked_If;

      function Get_Boolean (Params : in List;
                            Key    : in String)
                            return Boolean
      is
      begin
         return Boolean'Value (Get (Params, Key));
      exception
         when Constraint_Error =>
            return False;
      end Get_Boolean;

      URI     : constant String
        := Tools.Strip_Slash (AWS.Status.URI (Request));
      Name    : constant String := Config.WWW_Base & URI & ".thtml";
      Payload : Tools.UString;
      Info    : constant Nav_Info := Default_Info (Next => "/search",
                                                   Prev => "/search");
      Params  : constant List := AWS.Status.Parameters (Request);

      function Trans return Translate_Table is
      begin
         return
            (Assoc ("STRIP_TITLE",      Checked_If (Strip_Title)),
             Assoc ("STRIP_NAV_TOP",    Checked_If (Strip_Nav_Top)),
             Assoc ("STRIP_NAV_BOTTOM", Checked_If (Strip_Nav_Bottom)),
             Assoc ("STRIP_SPONSOR",    Checked_If (Strip_Sponsor)),
             Assoc ("MAN_ARM_2012",     Checked_If (Default_ARM = ARM_2012)),
             Assoc ("MAN_ARM_2022",     Checked_If (Default_ARM = ARM_2022)),
             Assoc ("MAN_AARM_202Y",    Checked_If (Default_ARM = AARM_202Y))
            );
      end Trans;

   begin

      case AWS.Status.Method (Request) is
         when AWS.Status.GET  => null;
            Payload := Templates_Parser.Parse (Filename     => Name,
                                               Translations => Trans);
            Insert_JS_Script (Payload, Info);

         when AWS.Status.POST =>
            Strip_Title      := Get_Boolean (Params, "strip_title");
            Strip_Nav_Top    := Get_Boolean (Params, "strip_nav_top");
            Strip_Nav_Bottom := Get_Boolean (Params, "strip_nav_bottom");
            Strip_Sponsor    := Get_Boolean (Params, "strip_sponsor");
            Default_ARM      := ARM_Version'Value (Get (Params, "manual"));
            HostARM_Tipue.Build_Content;  -- Rebuild Tipuesearch database

            Payload := Templates_Parser.Parse (Filename     => Name,
                                               Translations => Trans);
            Insert_JS_Script (Payload, Info);

         when others => null;
      end case;

      return
         AWS.Response.Build (Content_Type    => "text/html",
                             UString_Message => Payload);
   end Service_Config;

   -----------------
   -- Service_ARM --
   -----------------

   function Service_ARM (Request : in AWS.Status.Data)
                         return AWS.Response.Data
   is
      use Tools;

      URI     : constant String := Strip_Slash (AWS.Status.URI (Request));
      Name    : constant String := Config.ARM_Base & URI & ".html";
      Payload  : Tools.UString;
      Nav_Info : HostARM_Navigate.Nav_Info;
   begin
      Tools.Load_File (Name, Payload);

      HostARM_Navigate.Read_Navigation  (Payload, Nav_Info);
      HostARM_Navigate.Insert_JS_Script (Payload, Nav_Info);

      HostARM_Stripping.Strip (Payload);
      HostARM_Stripping.Replace_Doctype (Payload);

      return
         AWS.Response.Build (Content_Type    => "text/html",
                             UString_Message => Payload);
   end Service_ARM;

   -------------------
   -- Service_Tipue --
   -------------------

   function Service_Tipue (Request : in AWS.Status.Data)
                           return AWS.Response.Data
   is
      use Tools;

      URI     : constant String := AWS.Status.URI (Request);
      Name    : constant String := Config.Tipue_Base & URI;
      Payload : Tools.UString;
   begin

      if URI = Tipue_Path & "/tipuesearch_content.js" then
         return
            AWS.Response.Build
                (Content_Type    => "text/javascript",
                 UString_Message => HostARM_Tipue.Get_Content);

      elsif Tail_Is (URI, ".js") then
         Tools.Load_File (Name, Payload);

         return
            AWS.Response.Build (Content_Type    => "text/javascript",
                                UString_Message => Payload);
      elsif Tail_Is (URI, ".css") then
         Tools.Load_File (Name, Payload);

         return
            AWS.Response.Build (Content_Type    => "text/css",
                                UString_Message => Payload);

      elsif Tail_Is (URI, ".png") then
         Tools.Load_File (Name, Payload);

         return
            AWS.Response.Build (Content_Type    => "image/png",
                                UString_Message => Payload);
      end if;

      raise Program_Error with "Correct this to a 404";

   end Service_Tipue;

   -----------------
   -- Service_GIF --
   -----------------

   function Service_GIF (Request : in AWS.Status.Data)
                         return AWS.Response.Data
   is
      URI     : constant String := AWS.Status.URI (Request);
      Name    : constant String := Config.ARM_Base & URI;
      Payload : Tools.UString;
   begin
      Tools.Load_File (Name, Payload);

      return
         AWS.Response.Build (Content_Type    => "image/gif",
                             UString_Message => Payload);
   end Service_GIF;

   -----------------
   -- Service_ICO --
   -----------------

   function Service_ICO (Request : in AWS.Status.Data)
                         return AWS.Response.Data
   is
      URI     : constant String := AWS.Status.URI (Request);
      Name    : constant String :=
        Config.WWW_Base & "/../assets/favicon/" & URI;
      Payload : Tools.UString;
   begin
      Tools.Load_File (Name, Payload);

      return
         AWS.Response.Build (Content_Type    => "image/ico",
                             UString_Message => Payload);
   end Service_ICO;

   ----------------------
   -- Service_Redirect --
   ----------------------

   function Service_Redirect (Request : in AWS.Status.Data)
                              return AWS.Response.Data
   is
      use Ada.Strings.Fixed;

      Match   : constant String := ".html";
      URI     : constant String := AWS.Status.URI (Request);
      New_URI : constant String
       := Head (URI, URI'Length - Match'Length);
   begin
      return AWS.Response.URL (Location => New_URI);
   end Service_Redirect;

   -----------------
   -- Service_Odd --
   -----------------

   function Service_Odd (Request : in AWS.Status.Data)
                         return AWS.Response.Data
   is
      URI     : constant String := AWS.Status.URI (Request);
      New_URI : constant String := "/readme";
   begin
      return AWS.Response.URL (Location => New_URI);
   end Service_Odd;

   -------------------------
   -- Register_Dispatcher --
   -------------------------

   procedure Register_Dispatcher
   is
      use AWS.Services.Dispatchers.URI;
   begin

      Register (Dispatcher, "/config", Service_Config'Access);
      Register (Dispatcher, "/search", Service_THTML'Access, Prefix => True);
      Register (Dispatcher, "/readme", Service_THTML'Access);
      Register (Dispatcher, "/",       Service_Odd'Access);
      Register (Dispatcher, "",        Service_Odd'Access);
      Register (Dispatcher, "/favicon.ico", Service_ICO'Access);

      Register_Regexp (Dispatcher, ".*\.gif",  Service_GIF'Access);
      Register_Regexp (Dispatcher, ".*\.html", Service_Redirect'Access);

      Register_Regexp (Dispatcher, "/assets/tipuesearch/.*",
                       Service_Tipue'Access);
      Register_Regexp (Dispatcher, "/RM-.*", Service_ARM'Access);
      Register_Regexp (Dispatcher, "/AA-.*", Service_ARM'Access);

   end Register_Dispatcher;

   -------------------
   -- Config_Server --
   -------------------

   procedure Config_Server
   is
      use AWS.Config;
   begin
      Server_Conf := Default_Config;
      Set.Server_Name    (Server_Conf, Server_Name);
      Set.Max_Connection (Server_Conf, 8);
      Set.Server_Port    (Server_Conf, Config.Default_Port);
   end Config_Server;

   -----------
   -- Start --
   -----------

   procedure Start is
   begin
      Config_Server;
      Register_Dispatcher;

      AWS.Server.Start
        (Web_Server => Server,
         Dispatcher => Dispatcher,
         Config     => Server_Conf);

   end Start;

   ----------
   -- Stop --
   ----------

   procedure Stop is
   begin
      AWS.Server.Shutdown (Server);
   end Stop;

   ----------
   -- Wait --
   ----------

   procedure Wait is
   begin
      AWS.Server.Wait (AWS.Server.Q_Key_Pressed);
   end Wait;

end HostARM_Server;
