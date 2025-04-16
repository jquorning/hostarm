
with Ada.Strings.Fixed;
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

   -----------------
   -- Strip_Slash --
   -----------------

   function Strip_Slash (URL : in String)
                         return String
   is
   begin
      if URL'Length >= 1 and then URL (URL'Last) = '/' then
         return URL (URL'First .. URL'Last - 1);
      else
         return URL;
      end if;
   end Strip_Slash;

   -------------
   -- Tail_Is --
   -------------

   function Tail_Is (Item  : in String;
                     Match : in String)
                     return Boolean
   is
      use Ada.Strings.Fixed;
   begin
      return Tail (Item, Match'Length) = Match;
   end Tail_Is;

end HostARM_Tools;
