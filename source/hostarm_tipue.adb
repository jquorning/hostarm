
with Ada.Characters.Latin_1;
with Ada.Text_IO.Unbounded_IO;

with HostARM_Configuration;
with HostARM_Tools;

package body HostARM_Tipue is

   package Config renames HostARM_Configuration;
   package Tools  renames HostARM_Tools;
   use Ada.Strings.Unbounded;

   Content     : UString;
   Parse_Error : exception;

   -------------------
   -- Get_Index_Div --
   -------------------

   procedure Get_Index_Div (Payload : in     UString;
                            From    : in     Natural;
                            Last    :    out Natural;
                            Block   :    out UString)
   is
      Match_First : constant String := "<div class=""Index"">";
      Match_Last  : constant String := "</div>";
      Pos         : Natural;
   begin
      Pos := Index (Payload, Match_First, From => From);
      if Pos = 0 then
         Last := 0;
         return;
      end if;
      Pos := Pos + Match_First'Length;  --  After div

      Last := Index (Payload, Match_Last, From => Pos);
      if Last = 0 then
         return;
      end if;

      Block := Unbounded_Slice (Payload, Pos, Last - 1);
      Last := Last + Match_Last'Length - 1;
   end Get_Index_Div;

   ------------------
   -- Get_A_Clause --
   ------------------
   --  <A HREF="Href">Load</A>

   procedure Get_A_Clause (Block : in UString;
                           Href  :    out UString;
                           Load  :    out UString;
                           From  : in     Natural;
                           Last  :    out Natural)
   is
      Match_First : constant String := "<A HREF=""";
      Match_Mid   : constant String := """>";
      Match_Last  : constant String := "</A>";
      Pos_First   : Natural;
      Pos_Mid     : Natural;
      Pos_Last    : Natural;
   begin
      Last := 0;
      Pos_First := Index (Block, Match_First, From => From);
      Pos_Mid   := Index (Block, Match_Mid,   From => From);
      if Pos_First = 0 or Pos_Mid = 0 then
         return;
      end if;

      Pos_Last := Index (Block, Match_Last, From => Pos_Mid);
      if Pos_Last = 0 then
         return;
      end if;

      Href := Unbounded_Slice (Block,
                               Low  => Pos_First + Match_First'Length,
                               High => Pos_Mid - 1);
      Load := Unbounded_Slice (Block,
                               Low  => Pos_Mid + Match_Mid'Length,
                               High => Pos_Last - 1);
      Last := Pos_Last - 1;
   end Get_A_Clause;

   --------------------
   -- Append_Content --
   --------------------

   procedure Append_Content (Title : in UString;
                             Text  : in UString;
                             Tags  : in UString;
                             URL   : in UString)
   is
      use Ada.Characters.Latin_1;
   begin
      Append (Content, "{" & LF);

      Append (Content, "  ""title"": """);  Append (Content, Title);
      Append (Content, """,");              Append (Content, LF);

      Append (Content, "  ""text"":  """);  Append (Content, Text);
      Append (Content, """,");              Append (Content, LF);

      Append (Content, "  ""tags"":  """);  Append (Content, Tags);
      Append (Content, """,");              Append (Content, LF);

      Append (Content, "  ""url"":   """);  Append (Content, URL);
      Append (Content, """");               Append (Content, LF);

      Append (Content, "}," & LF);

   end Append_Content;

   --------------------
   -- Translate_HTML --
   --------------------

   procedure Translate_HTML (Item : in out UString)
   is
      use Tools;
   begin
      Replace (Item, "&amp;", "&");
      Replace (Item, "&lt;",  "<");
      Replace (Item, "&gt;",  ">");
   end Translate_HTML;

   ---------------------
   -- Remove_I_Clause --
   ---------------------

   procedure Remove_I_Clause (Item : in out UString)
   is
      use Tools;
   begin
      Replace (Item, "<I>",  "");
      Replace (Item, "</I>", "");
   end Remove_I_Clause;

   --------------------------------
   -- Parse_Index_Div_And_Append --
   --------------------------------

   procedure Parse_Index_Div_And_Append
      (Block : in UString)
   is
      Match_BR   : constant String := "<BR>";
      Match_NBSP : constant String := "&nbsp;";
      Pos_BR     : Natural;
      Pos_NBSP   : Natural;
      Tags       : UString;
   begin
      Pos_BR   := Index (Block, Match_BR,   From => 1);
      Pos_NBSP := Index (Block, Match_NBSP, From => 1);

      if Pos_BR /= 0 and Pos_NBSP /= 0 then
         Tags := Unbounded_Slice (Block, 1, Natural'Min (Pos_BR   - 1,
                                                         Pos_NBSP - 1));
      elsif Pos_BR /= 0 then
         Tags := Unbounded_Slice (Block, 1, Pos_BR - 1);
      elsif Pos_NBSP /= 0 then
         Tags := Unbounded_Slice (Block, 1, Pos_NBSP - 1);
      else
         raise Parse_Error;     --  No <BR> or &nbsp;
      end if;

      if Tags = "" then  -- Heading
         return;
      end if;

      declare
         Href : UString;
         Load : UString;
         From : Natural;
         Last : Natural := 1;
      begin
         From := Natural'Max (Pos_BR, Pos_NBSP);

         while Last /= 0 loop
            Get_A_Clause (Block,
                          From => From, Last => Last,
                          Href => Href, Load => Load);
            exit when Last = 0;

            if Config.URL_Without_HTML then
               Tools.Replace (Href, ".html", "");
            end if;
            Translate_HTML (Tags);
            Remove_I_Clause (Tags);

            Append_Content
               (Title => Tags,  --  What else ??
                Text  => Load,
                Tags  => Tags,
                URL   => "/" & Href);

            From := Last + 1;
         end loop;
      end;

   end Parse_Index_Div_And_Append;

   --------------------
   -- Append_Content --
   --------------------

   procedure Append_Content (Index_File : in String)
   is
      Payload : Tools.UString;
      Block   : Tools.UString;  --  Contents of Index div.
      Pos     : Natural := 1;
      Last    : Natural;
   begin
      Tools.Load_File (Index_File, Payload);

      while Pos /= 0 loop

         Get_Index_Div (Payload, From => Pos, Last => Last, Block => Block);
         exit when Last = 0;

         Parse_Index_Div_And_Append (Block);

         Pos := Last + 1;
      end loop;

   end Append_Content;

   -------------------
   -- Build_Content --
   -------------------

   procedure Build_Content
   is
   begin
      Content := To_Unbounded_String ("");

      Append (Content, "var tipuesearch = {""pages"": [" & ASCII.LF);

      case Config.Default_ARM is
         when Config.ARM_2012 =>
            Append_Content (Config.ARM_Base & "/RM-0-5.html");
            Append_Content (Config.ARM_Base & "/RM-Q-1.html");
            Append_Content (Config.ARM_Base & "/RM-Q-2.html");
            Append_Content (Config.ARM_Base & "/RM-Q-3.html");
            Append_Content (Config.ARM_Base & "/RM-Q-4.html");
            Append_Content (Config.ARM_Base & "/RM-Q-5.html");

         when Config.ARM_2022 =>
            Append_Content (Config.ARM_Base & "/RM-0-4.html");
            Append_Content (Config.ARM_Base & "/RM-Q-1.html");
            Append_Content (Config.ARM_Base & "/RM-Q-2.html");
            Append_Content (Config.ARM_Base & "/RM-Q-3.html");
            Append_Content (Config.ARM_Base & "/RM-Q-4.html");
            Append_Content (Config.ARM_Base & "/RM-Q-5.html");

         when Config.AARM_202Y =>
            Append_Content (Config.ARM_Base & "/AA-0-4.html");
            Append_Content (Config.ARM_Base & "/AA-Q-1.html");
            Append_Content (Config.ARM_Base & "/AA-Q-2.html");
            Append_Content (Config.ARM_Base & "/AA-Q-3.html");
            Append_Content (Config.ARM_Base & "/AA-Q-4.html");
            Append_Content (Config.ARM_Base & "/AA-Q-5.html");

      end case;

      Delete (Content,
              From    => Length (Content) - 1,
              Through => Length (Content) - 1);
      --  Remove trailing ','. -1 beacuse of LF

      Append (Content, "]};" & ASCII.LF);

   end Build_Content;

   ------------------
   -- Dump_Content --
   ------------------

   procedure Dump_Content
   is
      use Ada.Text_IO;
   begin
      Unbounded_IO.Put_Line (Content);
   end Dump_Content;

   -----------------
   -- Get_Content --
   -----------------

   function Get_Content return UString
   is
   begin
      return Content;
   end Get_Content;

end HostARM_Tipue;
