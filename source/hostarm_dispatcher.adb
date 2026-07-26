
with Ada.Strings.Fixed;
with Ada.Text_IO;

with Templates_Parser;

with Hostarm_Config;

with HostARM_Configuration;
with HostARM_Cookie;
with HostARM_Navigate;
with HostARM_Pyning;
with HostARM_RFC3875;
with HostARM_Tipue;
with HostARM_Tools;

package body HostARM_Dispatcher is

   package Config  renames HostARM_Configuration;
   package Cookie  renames HostARM_Cookie;
   package RFC3875 renames HostARM_RFC3875;
   package Tools   renames HostARM_Tools;

   use Ada.Text_IO;

   Tipue_Path  : constant String := "/assets/tipuesearch";

   -----------
   -- Trans --
   -----------

   function Trans
     (State : in Config.State_Type) return Templates_Parser.Translate_Table
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

      Version : ARM_Version renames State.Manual;
   begin
      return
        (Assoc ("MANUAL_TOC", Config.URI_Contents (Version)),
         Assoc ("MANUAL_INDEX", Config.URI_Index (Version)),
         Assoc ("MANUAL_AUTH_SEARCH", Config.URI_Search (Version)),
         Assoc ("MANUAL_REFERENCE", Config.URI_Reference (Version)),

         Assoc ("PYNE_BANNER", Checked_If (State.Pyne_Banner)),
         Assoc ("PYNE_NAV_TOP", Checked_If (State.Pyne_Nav_Top)),
         Assoc ("PYNE_NAV_BOTTOM", Checked_If (State.Pyne_Nav_Bottom)),
         Assoc ("PYNE_SPONSOR", Checked_If (State.Pyne_Sponsor)),

         Assoc ("MODERNIZE", Checked_If (State.Modernize)),

         Assoc ("PROGRAM_NAME", Hostarm_Config.Crate_Name),
         Assoc ("PROGRAM_VERSION", Hostarm_Config.Crate_Version),

         Assoc ("MAN_ARM_2012", Checked_If (State.Manual = ARM_2012)),
         Assoc ("MAN_ARM_2022", Checked_If (State.Manual = ARM_2022)),
         Assoc ("MAN_AARM_202Y", Checked_If (State.Manual = AARM_202Y)));
   end Trans;

   ----------------
   -- Route_Path --
   ----------------

   function Route_Path return String is
      use Ada.Strings.Fixed;

      --  PATH_INFO is the part of the URL after the CGI script name
      --  (e.g. "/RM-2012/RM-1.html" for a request to
      --  ".../hostarm/RM-2012/RM-1.html"), which is what the routing
      --  below expects. REQUEST_URI would still carry the script's own
      --  path ("/hostarm") as a prefix, breaking every route match.
      Full : constant String := RFC3875.Get_Environment ("PATH_INFO");
      Mark : constant Natural := Index (Full, "?");
   begin
      if Mark = 0 then
         return Full;
      else
         return Full (Full'First .. Mark - 1);
      end if;
   end Route_Path;

   --------------------
   -- Service_Search --
   --------------------

   procedure Service_Search
   is
      use HostARM_Navigate;

      Name    : constant String := Config.Page_Base & "/search.thtml";
      State   : Config.State_Type;
      Payload : Tools.UString;
   begin
      Cookie.Get_Or_Default (State);

      Payload :=
        Templates_Parser.Parse
          (Filename => Name, Translations => Trans (State));

      Insert_JS_Key_Navigation
        (Payload,
         Info =>
           Default_Info
             (Version => State.Manual, Next => Config.URI_Index (State.Manual),
              Prev    => Config.URI_Contents (State.Manual)));

      HostARM_Pyning.Insert_CSS_Links (Payload);

      HostARM_Pyning.Pyne
        (Payload, State, Next => Config.URI_Index (State.Manual),
         Prev                 => Config.URI_Contents (State.Manual));
      --  Nothing to pyne but inserts navigation header

      RFC3875.Put_CGI_Header;
      Put_Line (Tools.To_String (Payload));
   end Service_Search;

   -----------------
   -- Service_ARM --
   -----------------

   procedure Service_ARM
   is
      use Tools;

      URI      : constant String := Strip_Slash (Route_Path);
      Payload  : Tools.UString;
      Nav_Info : HostARM_Navigate.Nav_Info;
      State    : Config.State_Type;
   begin
      Cookie.Get_Or_Default (State);

      Tools.Load_File
        (Name    => Config.ARM_Base (State.Manual) & URI & ".html",
         Payload => Payload);

      HostARM_Navigate.Read_Navigation (Payload, Nav_Info);
      HostARM_Navigate.Insert_JS_Key_Navigation (Payload, Nav_Info);

      if URI = "/" & Config.URI_Index (State.Manual) then
         HostARM_Pyning.Append_Navigation_Bar (Payload);
      end if;

      HostARM_Pyning.Pyne (Payload, State => State);

      HostARM_Pyning.Replace_Doctype (Payload);

      HostARM_Pyning.Remove_Head_Style_CSS (Payload);
      HostARM_Pyning.Insert_CSS_Links (Payload);

      RFC3875.Put_CGI_Header;
      Put_Line (To_String (Payload));
   end Service_ARM;

   -------------------
   -- Service_Tipue --
   -------------------

   procedure Service_Tipue
   is
      use Tools;

      URI     : constant String := Route_Path;
      Name    : constant String := Config.Tipue_Base & URI;
      State   : Config.State_Type;
      Payload : Tools.UString;
   begin
      Cookie.Get_Or_Default (State);

      if URI = Tipue_Path & "/tipuesearch_content.js" then
         RFC3875.Put_CGI_Header ("Content-type: text/javascript");
         Put_Line (To_String (HostARM_Tipue.Get_Content (State.Manual)));

      elsif Tail_Is (URI, ".js") then
         Tools.Load_File (Name, Payload);

         RFC3875.Put_CGI_Header ("Content-type: text/javascript");
         Put_Line (To_String (Payload));

      elsif Tail_Is (URI, ".css") then
         Tools.Load_File (Name, Payload);

         RFC3875.Put_CGI_Header ("Content-type: text/css");
         Put_Line (To_String (Payload));

      elsif Tail_Is (URI, ".png") then
         Tools.Load_File (Name, Payload);

         RFC3875.Put_CGI_Header ("Content-type: image/png");
         Put_Line (To_String (Payload));

      end if;

      raise Program_Error with "Correct this to a 404";

   end Service_Tipue;

   -----------------
   -- Service_CSS --
   -----------------

   procedure Service_CSS
   is
      URI     : constant String := Route_Path;
      Name    : constant String := Config.Web_Base & URI;
      Payload : Tools.UString;
   begin
      Tools.Load_File (Name, Payload);

      RFC3875.Put_CGI_Header ("Content-type: text/css");
      Put_Line (Tools.To_String (Payload));
   end Service_CSS;

   ------------------
   -- Service_JPEG --
   ------------------

   procedure Service_JPEG
   is
      URI     : constant String := Route_Path;
      Name    : constant String := Config.Web_Base & URI;
      Payload : Tools.UString;
   begin
      Tools.Load_File (Name, Payload);

      RFC3875.Put_CGI_Header ("Content-type: image/jpeg");
      Put_Line (Tools.To_String (Payload));
   end Service_JPEG;

   -----------------
   -- Service_PNG --
   -----------------

   procedure Service_PNG
   is
      URI     : constant String := Route_Path;
      Name    : constant String := Config.Web_Base & URI;
      Payload : Tools.UString;
   begin
      Tools.Load_File (Name, Payload);

      RFC3875.Put_CGI_Header ("Content-type: text/png");
      Put_Line (Tools.To_String (Payload));
   end Service_PNG;

   -----------------
   -- Service_GIF --
   -----------------

   procedure Service_GIF
   is
      URI     : constant String := Route_Path;
      State   : Config.State_Type;
      Payload : Tools.UString;
   begin
      Cookie.Get_Or_Default (State);

      Tools.Load_File
        (Name => Config.ARM_Base (State.Manual) & URI, Payload => Payload);

      RFC3875.Put_CGI_Header ("Content-type: image/gif");
      Put_Line (Tools.To_String (Payload));
   end Service_GIF;

   ----------------------
   -- Service_Redirect --
   ----------------------

   procedure Service_Redirect
   is
      use Ada.Strings.Fixed;

      Match   : constant String := ".html";
      URI     : constant String := Route_Path;
      New_URI : constant String := Head (URI, URI'Length - Match'Length);
   begin
      RFC3875.Put_CGI_Header ("Location: " & New_URI);
   end Service_Redirect;

   ---------------------
   -- Service_Default --
   ---------------------

   procedure Service_Default
   is
   begin
      RFC3875.Put_CGI_Header ("Location: /");
   end Service_Default;

   ------------------
   -- Service_Home --
   ------------------

   procedure Service_Home
   is
      use Config;
      use HostARM_Navigate;
      use RFC3875;

      function Get_Boolean (Key : in String) return Boolean
      is
      begin
         return Boolean'Value (Value (Key, Required => True));

      exception when others =>
            return False;
      end Get_Boolean;

      Name     : constant String := Config.Page_Base & "/home.thtml";
      State    : Config.State_Type;
      Payload  : Tools.UString;
   begin

      case CGI_Method is
         when Get =>
            Cookie.Get_Or_Default (State);

         when Post =>
            State :=
              (Manual          => ARM_Version'Value (Value ("manual")),
               Pyne_Banner     => Get_Boolean ("pyne_banner"),
               Pyne_Nav_Top    => Get_Boolean ("pyne_nav_top"),
               Pyne_Nav_Bottom => Get_Boolean ("pyne_nav_bottom"),
               Pyne_Sponsor    => Get_Boolean ("pyne_sponsor"),
               Modernize       => Get_Boolean ("modernize"));

         when Unknown =>
            null;
      end case;

      Payload :=
        Templates_Parser.Parse
          (Filename => Name, Translations => Trans (State));

      Insert_JS_Key_Navigation
        (Payload,
         Info =>
           Default_Info
             (Version => State.Manual, Next => Config.URI_Index (State.Manual),
              Prev    => Config.URI_Contents (State.Manual)));

      HostARM_Pyning.Insert_CSS_Links (Payload);

      HostARM_Pyning.Pyne
        (Payload, State, Next => Config.URI_Index (State.Manual),
         Prev                 => Config.URI_Contents (State.Manual));
      --  Nothing to pyne but inserts navigation header

      if CGI_Method = Post then
         Cookie.Set_Cookies (State);
      end if;

      RFC3875.Put_CGI_Header ("Content-type: text/html");
      Put_Line (Tools.To_String (Payload));
   end Service_Home;

   --------------
   -- Dispatch --
   --------------

   procedure Dispatch is

      use Ada.Strings;

      -----------------
      -- Head_Equals --
      -----------------

      function Head_Equals (Item : String; Pattern : String) return Boolean is
      begin
         if Item'Length < Pattern'Length then
            return False;
         end if;

         return Item (Item'First .. Pattern'Length) = Pattern;
      end Head_Equals;

      ---------------
      -- Tail_From --
      ---------------

      function Tail_From (Item : String; Pattern : String) return String is
         Pos : constant Natural :=
           Fixed.Index (Item, Pattern, Going => Backward);
      begin
         if Pos = 0 then
            return "";
         end if;

         return Item (Pos + Pattern'Length .. Item'Last);
      end Tail_From;

      URL : constant String := Route_Path;
      Ext : constant String := Tail_From (URL, Pattern => ".");
   begin
      if URL = "/search"    then  Service_Search; --  Prefix => True);
      elsif URL in "/" | "" then  Service_Home;
      elsif URL = "/home"   then  Service_Home;

      elsif Ext = "jpg"     then  Service_JPEG;
      elsif Ext = "png"     then  Service_PNG;
      elsif Ext = "gif"     then  Service_GIF;
      elsif Ext = "html"    then  Service_Redirect;
      elsif Head_Equals (URL, "/assets/css") and Ext = "css" then  Service_CSS;

      elsif Head_Equals (URL, "/assets/tipuesearch") then Service_Tipue;
      elsif Head_Equals (URL, "/RM-") then Service_ARM;
      elsif Head_Equals (URL, "/AA-") then Service_ARM;

      else Service_Default;
      end if;
   end Dispatch;

   ---------
   -- Run --
   ---------

   procedure Run is
   begin
      Dispatch;
   end Run;

end HostARM_Dispatcher;
