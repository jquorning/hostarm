
with Ada.Text_IO;

with AWS.Response;
with AWS.Server;
with AWS.Status;

with Config;
with Tools;

package body Web_Server is

   Server : AWS.Server.HTTP;

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
      end if;

      declare
         Name : constant String := Config.ARM_Base & URI;
         Payload : Tools.UString;
      begin
Ada.Text_IO.Put_Line (Name);
         Tools.Load_File (Name, Payload);

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

end Web_Server;
