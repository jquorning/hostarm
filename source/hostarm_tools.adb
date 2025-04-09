
with Ada.Text_IO;
with Ada.Characters.Latin_1;

package body Hostarm_Tools is

   procedure Load_File (Name    : in     String;
                        Payload :    out UString)
   is
      use Ada.Text_IO, Ada.Strings.Unbounded, Ada.Characters;

      File : File_Type;
   begin
      Open (File, In_File, Name);
      while not End_Of_File (File) loop
         Append (Payload, Get_Line (File));
         Append (Payload, Latin_1.LF);
      end loop;
      Close (File);
   end Load_File;

end Hostarm_Tools;
