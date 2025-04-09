with Ada.Text_IO;

with Config;
with Web_Server;

-------------
-- Hostarm --
-------------

procedure Hostarm is
begin

   Ada.Text_IO.Put_Line
     ("Starting web server on port:" & Config.Default_Port'Image);

   Web_Server.Start;
   Web_Server.Wait;
   Web_Server.Stop;

end Hostarm;
