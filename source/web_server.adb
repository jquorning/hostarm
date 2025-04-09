
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
      if URI = "/index" then
         return
            AWS.Response.Build (Content_Type => "text/html",
                                Message_Body => "<p>Just a test");
      end if;

      declare
         Name : constant String := Config.ARM_Base & URI;
         Payload : Tools.UString;
      begin
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
      AWS.Server.Wait (AWS.Server.No_Server);
   end Wait;

end Web_Server;
