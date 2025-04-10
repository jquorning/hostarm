
with Ada.Strings.Fixed;
with Ada.Text_IO;

with AWS.Response;
with AWS.Server;
with AWS.Status;

with HostARM_Config;
with HostARM_Stripping;
with HostARM_Tipue;
with HostARM_Tools;

package body HostARM_Server is

   package Config renames HostARM_Config;
   package Tools  renames HostARM_Tools;

   Server : AWS.Server.HTTP;
   Tipue_Path : constant String := "/assets/tipuesearch";
   URI_Search : constant String := "/search";

   -------------
   -- Service --
   -------------

   function Service (Request : in AWS.Status.Data) return AWS.Response.Data
   is
      URI : constant String := AWS.Status.URI (Request);
   begin
      if URI = "/config" then
         declare
            Name    : constant String := Config.WWW_Base & URI & ".thtml";
            Payload : Tools.UString;
         begin
            Ada.Text_IO.Put_Line (Name);
            Tools.Load_File (Name, Payload);

            return
               AWS.Response.Build (Content_Type    => "text/html",
                                   UString_Message => Payload);
         end;

      elsif Ada.Strings.Fixed.Head (URI, URI_Search'Length) = URI_Search then
         declare
            Name    : constant String := Config.WWW_Base & "/search.thtml";
            Payload : Tools.UString;
         begin
            Ada.Text_IO.Put_Line ("Search:" & Name);
            Tools.Load_File (Name, Payload);

            return
               AWS.Response.Build (Content_Type    => "text/html",
                                   UString_Message => Payload);
         end;

      elsif URI = "/about" then
         declare
            Name    : constant String := Config.WWW_Base & "/about.thtml";
            Payload : Tools.UString;
         begin
            Tools.Load_File (Name, Payload);

            return
               AWS.Response.Build (Content_Type    => "text/html",
                                   UString_Message => Payload);
         end;

      elsif URI = "/" or URI = "" then
         declare
            Name    : constant String := Config.WWW_Base & "/index.thtml";
            Payload : Tools.UString;
         begin
            Tools.Load_File (Name, Payload);

            return
               AWS.Response.Build (Content_Type    => "text/html",
                                   UString_Message => Payload);
         end;

      elsif
        Ada.Strings.Fixed.Tail (URI, String'(".gif")'Length) in ".gif" | ".ico"
      then
         declare
            Name    : constant String := Config.ARM_Base & URI;
            Payload : Tools.UString;
         begin
            Ada.Text_IO.Put_Line ("GIF:" & URI & " Name:" & Name);
            Tools.Load_File (Name, Payload);

            return
               AWS.Response.Build (Content_Type    => "text/html",
                                   UString_Message => Payload);
         end;

      end if;

      Redirect_From_HTML :
      declare
         use Ada.Strings.Fixed;

         Match : constant String := ".html";
      begin
         if Tail (URI, Match'Length) = Match then
            declare
               New_URI : constant String
                 := Head (URI, URI'Length - Match'Length);
            begin
               Ada.Text_IO.Put_Line ("REDIRECT:" & URI & " to " & New_URI);
               return AWS.Response.URL (Location => New_URI);
            end;
         end if;
      end Redirect_From_HTML;

      if Ada.Strings.Fixed.Head (URI, Tipue_Path'Length) = Tipue_Path then
         if URI = Tipue_Path & "/tipuesearch_content.js" then
               return
                  AWS.Response.Build (Content_Type    => "text/html",
                                      UString_Message => HostARM_Tipue.Get_Content);
         else
            declare
               Name    : constant String := Config.Tipue_Base & URI;
               Payload : Tools.UString;
            begin
               Tools.Load_File (Name, Payload);

               return
                  AWS.Response.Build (Content_Type    => "text/html",
                                      UString_Message => Payload);
            end;
         end if;
      end if;

      declare
         Name    : constant String := Config.ARM_Base & URI & ".html";
         Payload : Tools.UString;
      begin
         Ada.Text_IO.Put_Line (Name);
         Tools.Load_File (Name, Payload);
         HostARM_Stripping.Strip (Payload);

         return
            AWS.Response.Build (Content_Type    => "text/html",
                                UString_Message => Payload);
      end;
   end Service;

   -----------
   -- Start --
   -----------

   procedure Start is
   begin
      AWS.Server.Start
        (Web_Server  => Server,
         Name        => "Ada Reference Manual (hostarm)",
         Callback    => Service'Access,
         Port        => Config.Default_Port);
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
