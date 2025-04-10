
with Ada.Strings.Unbounded;

with HostARM_Config;

package body HostARM_Stripping is

   use Ada.Strings.Unbounded;
   package Config renames HostARM_Config;

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

   -----------------
   -- Strip_Title --
   -----------------

   procedure Strip_Title (Item : in out Tools.UString)
   is
      Body_Match : constant String := "<BODY TEXT=";
      Top_Match  : constant String := "<DIV><SPAN ";
      Bot_Match  : constant String := "</DIV>";
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
   end Strip_Title;

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

   -------------------
   -- Strip_Sponsor --
   -------------------

   procedure Strip_Sponsor (Item : in out Tools.UString)
   is
      HR_Match   : constant String := "<HR>";
      Top_Match  : constant String := "<DIV Style=";
      Bot_Match  : constant String := "</DIV>";
      HR_Pos   : Natural;
      Top_Pos  : Natural;
      Bot_Pos  : Natural;
   begin
      HR_Pos := Index (Item, HR_Match, From => 1);
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
   end Strip_Sponsor;

   --------------
   -- Strip_HR --
   --------------

   procedure Strip_HR (Item  : in out Tools.UString;
                       First : in     Boolean)
   is
      HR_Match : constant String := "<HR>";
      HR_Pos   : Natural;
   begin
      HR_Pos := Index (Item, HR_Match, From => 1);
      if HR_Pos = 0 then
         return;
      end if;

      if not First then
         HR_Pos := Index (Item, HR_Match, From => HR_Pos + HR_Match'Length);
      end if;
      if HR_Pos = 0 then
         return;
      end if;

      Delete (Item,
              From    => HR_Pos,
              Through => HR_Pos + HR_Match'Length);
   end Strip_HR;

   -----------
   -- Strip --
   -----------

   procedure Strip (Item : in out Tools.UString) is
   begin
      if Config.Strip_Legend_Top then
         Strip_Top (Item);
      end if;

      if Config.Strip_Legend_Bottom then
         Strip_Bottom (Item);
      end if;

      if Config.Strip_Title then
         Strip_Title (Item);
      end if;

      if Config.Strip_Sponsor then
         Strip_Sponsor (Item);
      end if;

      if Config.Strip_Sponsor and Config.Strip_Legend_Bottom then
         Strip_HR (Item, First => False);
      end if;

      if Config.Strip_Title and Config.Strip_Legend_Top then
         Strip_HR (Item, First => True);
      end if;

   end Strip;

end HostARM_Stripping;
