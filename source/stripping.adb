
with Ada.Strings.Unbounded;

with Config;

package body Stripping is

   use Ada.Strings.Unbounded;

   ---------------
   -- Strip_Top --
   ---------------

   procedure Strip_Top (Item : in out Tools.UString)
   is
      Body_Match : constant String := "<BODY TEXT=";
      Top_Match  : constant String := "<div style=";
      Bot_Match  : constant String := "</div>";
      Body_Pos : Natural;
      Top_Pos  : Natural;
      Bot_Pos  : Natural;
   begin
      Body_Pos := Index (Item, Body_Match, From => 1);
      if Body_Pos = 0 then
         return;
      end if;

      Top_Pos := Index (Item, Top_Match, From => Body_Pos);
      Bot_Pos := Index (Item, Bot_Match, From => Top_Pos);
      if Top_Pos = 0 or Bot_Pos = 0 then
         return;
      end if;

      Delete (Item,
              From    => Top_Pos,
              Through => Bot_Pos + Bot_Match'Length);
   end Strip_Top;

   ------------------
   -- Strip_Bottom --
   ------------------

   procedure Strip_Bottom (Item : in out Tools.UString)
   is
      HR_Match : constant String := "<HR>";
      Top_Match  : constant String := "<div style=";
      Bot_Match  : constant String := "</div>";
      HR_Pos   : Natural;
      Top_Pos  : Natural;
      Bot_Pos  : Natural;
   begin
      HR_Pos := Index (Item, HR_Match, 1);
      if HR_Pos = 0 then
         return;
      end if;

      HR_Pos := Index (Item, HR_Match, From => HR_Pos + HR_Match'Length);
      if HR_Pos = 0 then
         return;
      end if;

      Top_Pos := Index (Item, Top_Match, From => HR_Pos);
      Bot_Pos := Index (Item, Bot_Match, From => Top_Pos);
      if Top_Pos = 0 or Bot_Pos = 0 then
         return;
      end if;

      Delete (Item,
              From    => Top_Pos,
              Through => Bot_Pos + Bot_Match'Length);
   end Strip_Bottom;

   -----------
   -- Strip --
   -----------

   procedure Strip (Item : in out Tools.UString) is
   begin
      if Config.Strip_Legend_Top then
         Strip_Top (Item);
      end if;

      if Config.Strip_Legend_Top then
         Strip_Bottom (Item);
      end if;
   end Strip;

end Stripping;
