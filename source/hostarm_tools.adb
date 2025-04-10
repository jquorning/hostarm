
with Ada.Characters.Latin_1;
with Ada.Text_IO;

package body HostARM_Tools is

   ---------------
   -- Load_File --
   ---------------

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

   -------------
   -- Replace --
   -------------

   procedure Replace (Item    : in out UString;
                      Pattern : in String;
                      By      : in String)
   is
      use Ada.Strings.Unbounded;

      Pos_Pattern : Natural;
   begin
      Pos_Pattern := Index (Item, Pattern, 1);
      if Pos_Pattern = 0 then
         return;
      end if;

      Replace_Slice (Item,
                     Low  => Pos_Pattern,
                     High => Pos_Pattern + Pattern'Length - 1,
                     By   => By);
   end Replace;

end HostARM_Tools;
