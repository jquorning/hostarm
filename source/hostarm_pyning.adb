
with Ada.Strings.Unbounded;
with Ada.Characters.Latin_1;

with HostARM_Configuration;

package body HostARM_Pyning is

   package Config renames HostARM_Configuration;

   use Ada.Strings.Unbounded;

   -------------------------
   -- Pyne_Top_Navigation --
   -------------------------

   procedure Pyne_Top_Navigation (Item : in out Tools.UString)
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

      Top_Pos := Index (Item, Top_Match,
                        From    => Body_Pos,
                        Mapping => Tools.To_Lower_Case);
      Bot_Pos := Index (Item, Bot_Match,
                        From    => Natural'Max (Top_Pos,
                                                Body_Pos),
                        Mapping => Tools.To_Lower_Case);
      if Top_Pos = 0 or Bot_Pos = 0 then
         return;
      end if;

      Delete (Item,
              From    => Top_Pos,
              Through => Bot_Pos + Bot_Match'Length);
   end Pyne_Top_Navigation;

   -----------------
   -- Pyne_Banner --
   -----------------

   procedure Pyne_Banner (Item : in out Tools.UString)
   is
      Body_Match   : constant String := "<BODY TEXT=";
      Top_RM_Match : constant String := "<DIV><SPAN ";
      Top_AA_Match : constant String := "<DIV><B><SPAN ";  --  AA is special
      Bot_Match    : constant String := "</DIV>";
      Body_Pos   : Natural;
      Top_RM_Pos : Natural;
      Top_AA_Pos : Natural;
      Top_Pos    : Natural;
      Bot_Pos    : Natural;
   begin
      Body_Pos := Index (Item, Body_Match, From => 1);
      if Body_Pos = 0 then
         return;
      end if;

      Top_RM_Pos := Index (Item, Top_RM_Match, Body_Pos);
      Top_AA_Pos := Index (Item, Top_AA_Match, Body_Pos);
      if Top_RM_Pos = 0 and Top_AA_Pos = 0 then
         return;
      end if;

      Top_Pos := Natural'Max (Top_RM_Pos, Top_AA_Pos);
      Bot_Pos := Index (Item, Bot_Match, From => Top_Pos);
      if Bot_Pos = 0 then
         return;
      end if;

      Delete (Item,
              From    => Top_Pos,
              Through => Bot_Pos + Bot_Match'Length);
   end Pyne_Banner;

   ----------------------------
   -- Pyne_Bottom_Navigation --
   ----------------------------

   procedure Pyne_Bottom_Navigation (Item : in out Tools.UString)
   is
      HR_Match  : constant String := "<HR>";
      Top_Match : constant String :=
        "<div style=""margin-top: 0.0em; margin-bottom";
      Bot_Match : constant String := "</div>";
      HR_Pos   : Natural;
      Top_Pos  : Natural;
      Bot_Pos  : Natural;
   begin
      HR_Pos := Index (Item, HR_Match, 1);
      if HR_Pos = 0 then
         return;
      end if;

      --  Find second location of <HR>
      HR_Pos := Index (Item, HR_Match, From => HR_Pos + HR_Match'Length);
      if HR_Pos = 0 then
         return;
      end if;

      Top_Pos := Index (Item, Top_Match,
                        From    => HR_Pos,
                        Mapping => Tools.To_Lower_Case);
      Bot_Pos := Index (Item, Bot_Match,
                        From    => Positive'Max (Top_Pos, 1),
                        Mapping => Tools.To_Lower_Case);
      if Top_Pos = 0 or Bot_Pos = 0 then
         return;
      end if;

      Delete (Item,
              From    => Top_Pos,
              Through => Bot_Pos + Bot_Match'Length);
   end Pyne_Bottom_Navigation;

   ------------------
   -- Pyne_Sponsor --
   ------------------

   procedure Pyne_Sponsor (Item : in out Tools.UString)
   is
      HR_Match   : constant String := "<HR>";
      Top_Match  : constant String :=
         "<DIV Style=""margin-top:0.0em""><IMG SRC=""AE_logo.gif""";
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
   end Pyne_Sponsor;

   -------------
   -- Pyne_HR --
   -------------

   procedure Pyne_HR (Item  : in out Tools.UString;
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
   end Pyne_HR;

   ----------
   -- Pyne --
   ----------

   procedure Pyne (Item : in out Tools.UString) is
   begin
      if Config.Settings.Pyne_Nav_Top then
         Pyne_Top_Navigation (Item);
      end if;

      if Config.Settings.Pyne_Nav_Bottom then
         Pyne_Bottom_Navigation (Item);
      end if;

      if Config.Settings.Pyne_Banner then
         Pyne_Banner (Item);
      end if;

      if Config.Settings.Pyne_Sponsor then
         Pyne_Sponsor (Item);
      end if;

      if
        Config.Settings.Pyne_Sponsor and
        Config.Settings.Pyne_Nav_Bottom
      then
         Pyne_HR (Item, First => False);
      end if;

      if
        Config.Settings.Pyne_Banner and
        Config.Settings.Pyne_Nav_Top
      then
         Pyne_HR (Item, First => True);
      end if;

   end Pyne;

   ---------------------
   -- Replace_Doctype --
   ---------------------

   procedure Replace_Doctype (Item : in out Tools.UString)
   is
      use HostARM_Tools, Ada.Characters;

      Match_Doctype : constant String :=
        "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN"""
        & Latin_1.CR & Latin_1.LF
        & """http://www.w3.org/TR/html4/loose.dtd"">";

      Match_2       : constant String :=
        "<!DOCTYPE html PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN"">";

      By_Doctype    : constant String := "<!DOCTYPE html>";
   begin
      Replace (Item, Match_Doctype, By_Doctype);
      Replace (Item, Match_2,       By_Doctype);
      --  Match_2 only applies to two pages: Reference and Search.

   end Replace_Doctype;

   -----------------------
   -- Replace_Style_CSS --
   -----------------------

   procedure Replace_Style_CSS (Item : in out Tools.UString)
   is
      Match_1 : constant String := "<STYLE type=";
      Match_2 : constant String := "</STYLE>";
      Match_3 : constant String := "</HEAD>";
      Pos_1, Pos_2, Pos_3 : Natural;
      Repl    : constant String :=
        "<link rel='stylesheet' href='/assets/css/arm.css'>";
   begin
      Pos_1 := Index (Item, Match_1, 1);
      Pos_2 := Index (Item, Match_2, Natural'Max (1, Pos_1));
      Pos_3 := Index (Item, Match_3, Natural'Max (1, Pos_2));
      if Pos_1 = 0 or Pos_2 = 0 or Pos_3 = 0 or Pos_2 < Pos_1 then
         return;
      end if;

      Replace_Slice (Item,
                     Low  => Pos_1,
                     High => Pos_2 + Match_2'Length,
                     By   => Repl);
   end Replace_Style_CSS;

   ---------------------------
   -- Append_Navigation_Bar --
   ---------------------------

   procedure Append_Navigation_Bar (Item : in out Tools.UString)
   is
      CRLF    : constant String :=
         Ada.Characters.Latin_1.CR & Ada.Characters.Latin_1.LF;
      Match_1 : constant String := "<SPAN STYLE=""font-size: 156%""><B>";
      Match_2 : constant String := "</B></SPAN><BR>";
      New_11  : constant String := "<h2 id='Section_";
      New_12  : constant String := "' class='IndexSection'>";
      New_2   : constant String := "</h2>";
      Section : Character;
      Pos_1   : Natural;
      Pos_2   : Natural;
      First   : Natural := 1;
      Navig   : Tools.UString;
      Nav_0   : constant String := "<div class='IndexNavigation'>" & CRLF;
      Nav_1   : constant String :=
         "<a class='IndexNavigation' href='#Section_";
      Nav_2   : constant String := "'>";
      Nav_3   : constant String := "</a> " & CRLF;
      Nav_4   : constant String := "</div>";
   begin

      Append (Navig, Nav_0);

      loop
         Pos_1 := Index (Item, Match_1, First);
         exit when Pos_1 = 0;

         Pos_2 := Index (Item, Match_2, First);
         exit when Pos_2 = 0;

         Section := Element (Item, Pos_1 + Match_1'Length);
         --  Character after Match_1

         --  Replace latter so Pos_1 stays valid
         Replace_Slice (Item,
                        Low  => Pos_2,
                        High => Pos_2 + Match_2'Length - 1,
                        By   => New_2);
         Replace_Slice (Item,
                        Low  => Pos_1,
                        High => Pos_1 + Match_1'Length - 1,
                        By   => New_11 & Section & New_12);

         Append (Navig, Nav_1 & Section & Nav_2 & Section & Nav_3);

         First := First + New_11'Length + New_12'Length; --  Approximate
      end loop;

      Append (Navig, Nav_4);

      --  Insert navigation bar right under heading 1
      declare
         Match : constant String := "</H1>";
         Pos   : Natural;
      begin
         Pos := Index (Item, Match, 1);
         if Pos = 0 then
            return;
         end if;

         Replace_Slice (Item,
                        Low   => Pos + Match'Length,
                        High  => Pos + Match'Length,
                        By    => To_String (Navig));
      end;

   end Append_Navigation_Bar;

end HostARM_Pyning;
