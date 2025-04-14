
with Ada.Strings.Fixed;

with AWS.Config.Set;
with AWS.Response;
with AWS.Parameters;
with AWS.Server;
with AWS.Services.Dispatchers.URI;
with AWS.Status;

with Templates_Parser;

with HostARM_Configuration;
--  with HostARM_Cookie;
with HostARM_Navigate;
with HostARM_Pyning;
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

   -----------
   -- Trans --
   -----------

   function Trans (Version : in Config.ARM_Version)
                   return Templates_Parser.Translate_Table
   is
      use Config, Templates_Parser;

      function Checked_If (Condition : in Boolean) return String is
      begin
         if Condition then
            return "checked";
         else
            return "";
         end if;
      end Checked_If;

   begin
      return
         (Assoc ("MANUAL_TOC",         Config.URI_Contents  (Version)),
          Assoc ("MANUAL_INDEX",       Config.URI_Index     (Version)),
          Assoc ("MANUAL_AUTH_SEARCH", Config.URI_Search    (Version)),
          Assoc ("MANUAL_REFERENCE",   Config.URI_Reference (Version)),

          Assoc ("PYNE_BANNER",      Checked_If (Settings.Pyne_Banner)),
          Assoc ("PYNE_NAV_TOP",     Checked_If (Settings.Pyne_Nav_Top)),
          Assoc ("PYNE_NAV_BOTTOM",  Checked_If (Settings.Pyne_Nav_Bottom)),
          Assoc ("PYNE_SPONSOR",     Checked_If (Settings.Pyne_Sponsor)),

          Assoc ("MAN_ARM_2012",  Checked_If (Settings.Manual = ARM_2012)),
          Assoc ("MAN_ARM_2022",  Checked_If (Settings.Manual = ARM_2022)),
          Assoc ("MAN_AARM_202Y", Checked_If (Settings.Manual = AARM_202Y))
        );
   end Trans;

   --------------------
   -- Service_Search --
   --------------------

   function Service_Search (Request : in AWS.Status.Data)
                            return AWS.Response.Data
   is
      pragma Unreferenced (Request);

      use HostARM_Navigate;

      Name    : constant String := Config.WWW_Base & "/search.thtml";
      Payload : Tools.UString;
      Info    : constant Nav_Info :=
         Default_Info (Version => Config.Settings.Manual,
                       Next    => "/search",
                       Prev    => "/search");
   begin
      Payload := Templates_Parser.Parse
         (Filename     => Name,
          Translations => Trans (Config.Settings.Manual));

      Insert_JS_Key_Navigation (Payload, Info);

      return
         AWS.Response.Build (Content_Type    => "text/html",
                             UString_Message => Payload);
   end Service_Search;

   -----------------
   -- Service_ARM --
   -----------------

   function Service_ARM (Request : in AWS.Status.Data)
                         return AWS.Response.Data
   is
      use Tools;

      URI     : constant String := Strip_Slash (AWS.Status.URI (Request));
      Name    : constant String :=
         Config.ARM_Base (Config.Settings.Manual) & URI & ".html";
      Payload  : Tools.UString;
      Nav_Info : HostARM_Navigate.Nav_Info;
   begin
      Tools.Load_File (Name, Payload);

      HostARM_Navigate.Read_Navigation          (Payload, Nav_Info);
      HostARM_Navigate.Insert_JS_Key_Navigation (Payload, Nav_Info);

      if URI = "/" & Config.URI_Index (Config.Settings.Manual) then
         HostARM_Pyning.Append_Navigation_Bar (Payload);
      end if;

      HostARM_Pyning.Pyne (Payload);
      HostARM_Pyning.Replace_Doctype (Payload);
      HostARM_Pyning.Replace_Style_CSS (Payload);

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
                 UString_Message =>
                    HostARM_Tipue.Get_Content (Config.Settings.Manual));

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
   -- Service_CSS --
   -----------------

   function Service_CSS (Request : in AWS.Status.Data)
                         return AWS.Response.Data
   is
      URI     : constant String := AWS.Status.URI (Request);
      Name    : constant String := Config.WWW_Base & "/../" & URI;
      Payload : Tools.UString;
   begin
      Tools.Load_File (Name, Payload);

      return
         AWS.Response.Build (Content_Type    => "text/css",
                             UString_Message => Payload);
   end Service_CSS;

   ------------------
   -- Service_JPEG --
   ------------------

   function Service_JPEG (Request : in AWS.Status.Data)
                         return AWS.Response.Data
   is
      URI     : constant String := AWS.Status.URI (Request);
      Name    : constant String := Config.WWW_Base & "/.." & URI;
      Payload : Tools.UString;
   begin
      Tools.Load_File (Name, Payload);

      return
         AWS.Response.Build (Content_Type    => "image/jpeg",
                             UString_Message => Payload);
   end Service_JPEG;

   -----------------
   -- Service_GIF --
   -----------------

   function Service_GIF (Request : in AWS.Status.Data)
                         return AWS.Response.Data
   is
      URI     : constant String := AWS.Status.URI (Request);
      Name    : constant String :=
         Config.ARM_Base (Config.Settings.Manual) & URI;
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

   ---------------------
   -- Service_Default --
   ---------------------

   function Service_Default (Request : in AWS.Status.Data)
                             return AWS.Response.Data
   is
      pragma Unreferenced (Request);
   begin
      return AWS.Response.URL (Location => "/");
   end Service_Default;

   ----------------------
   -- Service_Toplevel --
   ----------------------

   function Service_Toplevel (Request : in AWS.Status.Data)
                              return AWS.Response.Data
   is
      use HostARM_Navigate;
      use AWS.Parameters;
      use Config;

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

      Params  : constant List := AWS.Status.Parameters (Request);
      Name    : constant String := Config.WWW_Base & "/toplevel.thtml";
      Payload : Tools.UString;
   begin

      case AWS.Status.Method (Request) is
         when AWS.Status.GET  =>
            null;

         when AWS.Status.POST =>
            Pyne_Banner     := Get_Boolean (Params, "pyne_banner");
            Pyne_Nav_Top    := Get_Boolean (Params, "pyne_nav_top");
            Pyne_Nav_Bottom := Get_Boolean (Params, "pyne_nav_bottom");
            Pyne_Sponsor    := Get_Boolean (Params, "pyne_sponsor");
            Config.Settings.Manual :=
               ARM_Version'Value (Get (Params, "manual"));

         when others => null;
      end case;

      Payload := Templates_Parser.Parse
         (Filename     => Name,
          Translations => Trans (Config.Settings.Manual));

      Insert_JS_Key_Navigation
         (Payload,
          Info => Default_Info (Version => Config.Settings.Manual,
                                Next    => "/search",
                                Prev    => "/search"));

      return
         AWS.Response.Build (Content_Type    => "text/html",
                             UString_Message => Payload);
   end Service_Toplevel;

   -------------------------
   -- Register_Dispatcher --
   -------------------------

   procedure Register_Dispatcher
   is
      use AWS.Services.Dispatchers.URI;
   begin

      Register (Dispatcher, "/search",      Service_Search'Access,
                Prefix => True);
      Register (Dispatcher, "/",            Service_Toplevel'Access);
      Register (Dispatcher, "",             Service_Toplevel'Access);
      Register (Dispatcher, "/toplevel",    Service_Toplevel'Access);
      Register (Dispatcher, "/favicon.ico", Service_ICO'Access);

      Register_Regexp (Dispatcher, "/.*\.jpg", Service_JPEG'Access);
      Register_Regexp (Dispatcher, ".*\.gif",  Service_GIF'Access);
      Register_Regexp (Dispatcher, ".*\.html", Service_Redirect'Access);
      Register_Regexp (Dispatcher, "/assets/css/.*\.css", Service_CSS'Access);

      Register_Regexp (Dispatcher, "/assets/tipuesearch/.*",
                       Service_Tipue'Access);
      Register_Regexp (Dispatcher, "/RM-.*", Service_ARM'Access);
      Register_Regexp (Dispatcher, "/AA-.*", Service_ARM'Access);

      Register_Regexp (Dispatcher, ".*",  Service_Default'Access);

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
