
with Ada.Strings.Fixed;
with Ada.Text_IO;

with AWS.Config.Set;
with AWS.Response;
with AWS.Server;
with AWS.Services.Dispatchers.URI;
with AWS.Status;

with HostARM_Config;
with HostARM_Navigate;
with HostARM_Stripping;
with HostARM_Tipue;
with HostARM_Tools;

package body HostARM_Server is

   package Config renames HostARM_Config;
   package Tools  renames HostARM_Tools;

   Server_Name : constant String := "HostARM: Ada Reference Manual";
   Tipue_Path  : constant String := "/assets/tipuesearch";

   Server      : AWS.Server.HTTP;
   Server_Conf : AWS.Config.Object;
   Dispatcher  : AWS.Services.Dispatchers.URI.Handler;

   ------------------
   -- Service_Page --
   ------------------

   function Service_Page (Request : in AWS.Status.Data)
                          return AWS.Response.Data
   is
      URI     : constant String
        := Tools.Strip_Slash (AWS.Status.URI (Request));
      Name    : constant String := Config.WWW_Base & URI & ".thtml";
      Payload : Tools.UString;
   begin
      Ada.Text_IO.Put_Line ("URI: " & URI);
      Tools.Load_File (Name, Payload);

      return
         AWS.Response.Build (Content_Type    => "text/html",
                             UString_Message => Payload);
   end Service_Page;

   -----------------
   -- Service_ARM --
   -----------------

   function Service_ARM (Request : in AWS.Status.Data)
                         return AWS.Response.Data
   is
      use Tools;

      URI     : constant String := Strip_Slash (AWS.Status.URI (Request));
      Name    : constant String := Config.ARM_Base & URI & ".html";
      Payload     : Tools.UString;
      Legend_Info : HostARM_Navigate.Legend_Info;
   begin
      Ada.Text_IO.Put_Line ("HTML: " & URI);
      Tools.Load_File (Name, Payload);

      HostARM_Navigate.Read_Navigation_Legend (Payload, Legend_Info);
      HostARM_Navigate.Insert_JS_Script       (Payload, Legend_Info);

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
      Name    : constant String := Config.ARM_Base & URI;
      Payload : Tools.UString;
   begin
      Ada.Text_IO.Put_Line ("ICO: " & URI);
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
      Ada.Text_IO.Put_Line ("REDIRECT:" & URI & " to " & New_URI);

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
      Ada.Text_IO.Put_Line ("REDIRECT:" & URI & " to " & New_URI);

      return AWS.Response.URL (Location => New_URI);

   end Service_Odd;

   -------------------------
   -- Register_Dispatcher --
   -------------------------

   procedure Register_Dispatcher
   is
      use AWS.Services.Dispatchers.URI;
   begin

      Register (Dispatcher, "/config", Service_Page'Access);
      Register (Dispatcher, "/search", Service_Page'Access, Prefix => True);
      Register (Dispatcher, "/readme", Service_Page'Access);
      Register (Dispatcher, "/",       Service_Odd'Access);
      Register (Dispatcher, "",        Service_Odd'Access);

      Register_Regexp (Dispatcher, ".*\.gif",  Service_GIF'Access);
      Register_Regexp (Dispatcher, ".*\.ico",  Service_ICO'Access);
--      Register_Regexp (Dispatcher, ".*\.css",  Service'Access);
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
