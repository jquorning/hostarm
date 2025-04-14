
with Ada.Characters.Latin_1;

with HostARM_Tools;

package body HostARM_Navigate is

   package Tools renames HostARM_Tools;

   use Ada.Characters;

   CRLF : constant String := Latin_1.CR & Latin_1.LF;

   -------------------
   -- Get_Nav_Block --
   -------------------

   procedure Get_Nav_Block (Payload : in     UString;
                            Legend  :    out UString)
   is
      Text_1 : constant String := "<BODY ";
      Text_2 : constant String := "<div style=";
      Text_3 : constant String := "<HR>";
      Pos_1, Pos_2, Pos_3 : Natural;
   begin
      --  Match <BODY
      Pos_1 := Index (Payload, Text_1, 1);
      if Pos_1 = 0 then
         return;
      end if;

      --  Match <div style=
      Pos_2 := Index (Payload, Text_2, Pos_1,
                      Mapping => Tools.To_Lower_Case);
      if Pos_2 = 0 then
         return;
      end if;

      --  Match <HR>
      Pos_3 := Index (Payload, Text_3, Pos_2);
      if Pos_3 = 0 then
         return;
      end if;

      --  The navigation legend is roughly Pos_2 .. Pos_3
      Legend := Unbounded_Slice (Payload,
                                 Low  => Pos_2,
                                 High => Pos_3 - 1);

   end Get_Nav_Block;

   -------------------
   -- Get_A_Element --
   -------------------

   procedure Get_A_Element (Legend : in     UString;
                            Src    :    out UString;
                            Href   :    out UString;
                            From   : in     Positive;
                            Last   :    out Natural)
   is
      Text_4 : constant String  := "<A HREF=""";
      Text_5 : constant String  := "<IMG SRC=""";

      Pos_4, Pos_5, Pos_6, Pos_7 : Natural;
   begin
      Last := 0;

      --  Match <A HREF=
      Pos_4 := Index (Legend, Text_4, From);
      if Pos_4 = 0 then
         return;
      end if;

      --  Match "
      Pos_6 := Index (Legend, """", Pos_4 + Text_4'Length); -- HREF close
      if Pos_6 = 0 then  -- Runaway..!
         return;
      end if;

      --  HREF between Pos_4 + Text_4'Length .. Pos_6 - 1

      --  Match <IMG SRC=
      Pos_5 := Index (Legend, Text_5, Pos_6);
      if Pos_5 = 0 then
         return;
      end if;

      --  Match "
      Pos_7 := Index (Legend, """", Pos_5 + Text_5'Length);
      if Pos_7 = 0 then  -- Runnaway ..?
         return;
      end if;

      --  Image source between Pos_5 + Text_5'Length .. Pos_7 - 1

      Href := Unbounded_Slice (Legend,
                               Pos_4 + Text_4'Length,
                               Pos_6 - 1);
      Src  := Unbounded_Slice (Legend,
                               Pos_5 + Text_5'Length,
                               Pos_7 - 1);
      Last := Pos_7;
   end Get_A_Element;

   ---------------------
   -- Read_Navigation --
   ---------------------

   procedure Read_Navigation (Payload : in     UString;
                              Info    :    out Nav_Info)
   is
      Legend : UString;
      Href   : UString;
      Src    : UString;
      From   : Positive := 1;
      Last   : Natural;
   begin
      Info := Empty_Info;
      Get_Nav_Block (Payload, Legend);

      Parse_A_Elements :
      loop

         Get_A_Element (Legend,
                        Href => Href, Src  => Src,
                        From => From, Last => Last);
         exit Parse_A_Elements when Last = 0;

--         Ada.Text_IO.Put_Line ("HREF: " & To_String (Href));
--         Ada.Text_IO.Put_Line ("SRC : " & To_String (Src));

         if    Src = "cont.gif"  then Info.Contents  := Href;
         elsif Src = "index.gif" then Info.Index     := Href;
         elsif Src = "lib.gif"   then Info.Reference := Href;
         elsif Src = "find.gif"  then Info.Search    := Href;
         elsif Src = "prev.gif"  then Info.Prev      := Href;
         elsif Src = "next.gif"  then Info.Next      := Href;
         else  raise Constraint_Error with "unexpected gif";
         end if;

         From := Last;
      end loop Parse_A_Elements;

   end Read_Navigation;

   --------------------
   -- Insert_Key_Nav --
   --------------------

   procedure Insert_Key_Nav (Payload : in out UString;
                             Key     : in     Character;
                             Href    : in     UString;
                             From    : in     Positive;
                             Last    :    out Natural)
   is
      Href_2  : constant String := "/" & To_String (Href); -- Fix search navig
      Text_1  : constant String := "    if (e.keyCode==";
      Text_2  : constant String := ")  document.location.href='";
      Text_3  : constant String := "';     // Key code for ";
      Img_Key : constant String := Natural'(Character'Pos (Key))'Image;
      Line    : constant String :=
        Text_1 & Img_Key & Text_2 & Href_2 &
        Text_3 & Key & CRLF;
   begin
      if Href = "" then
         Last := From - 1;
         return;
      end if;

      Insert (Payload, Before => From, New_Item => Line);

      Last := From + Line'Length - 1;
   end Insert_Key_Nav;

   ------------------------------
   -- Insert_JS_Key_Navigation --
   ------------------------------

   procedure Insert_JS_Key_Navigation (Payload : in out UString;
                                       Info    : in     Nav_Info)
   is
      Text_1 : constant String :=
        "<script>" & CRLF;
      Text_2 : constant String :=
        "document.addEventListener('keydown',function(e){" & CRLF &
        "   if (e.target=='[object HTMLInputElement]') return true;" & CRLF;
      Text_3 : constant String :=
        "})"        & CRLF &
        "</script>" & CRLF;

      From : Natural;
      Last : Natural;
   begin
      From := Index (Payload, "</head>", 1,
                     Mapping => Tools.To_Lower_Case);
      --  Mapping needed because of the two adverseries.
      if From = 0 then
         return;
      end if;

      Insert (Payload, Before   => From,
                       New_Item => Text_1);
      From := From + Text_1'Length;

      Insert (Payload, Before   => From,
                       New_Item => Text_2);
      From := From + Text_2'Length;

      Insert_Key_Nav (Payload, 'C', Info.Contents, From,     Last);
      Insert_Key_Nav (Payload, 'T', Info.Contents, Last + 1, Last);
      Insert_Key_Nav (Payload, 'I', Info.Index,    Last + 1,  Last);
      Insert_Key_Nav (Payload, 'R', Info.Reference, Last + 1, Last);
      Insert_Key_Nav (Payload, 'N', Info.Next,     Last + 1,  Last);
      Insert_Key_Nav (Payload, 'F', Info.Next,     Last + 1, Last);
      Insert_Key_Nav (Payload, 'P', Info.Prev,     Last + 1, Last);
      Insert_Key_Nav (Payload, 'B', Info.Prev,     Last + 1, Last);
      Insert_Key_Nav (Payload, 'A', Info.Search,   Last + 1, Last);
      Insert_Key_Nav (Payload, 'S', To_Unbounded_String ("search"),
                      Last + 1, Last);
      Insert_Key_Nav (Payload, 'H', To_Unbounded_String ("toplevel"),
                      Last + 1, Last);

      Insert (Payload, Before => Last + 1,
                       New_Item => Text_3);

   end Insert_JS_Key_Navigation;

   ------------------
   -- Default_Info --
   ------------------

   function Default_Info (Version : in Config.ARM_Version;
                          Next    : in String;
                          Prev    : in String)
                          return Nav_Info
   is
      package Config renames HostARM_Configuration;

      Info : Nav_Info;
   begin
      Info.Contents  := To_Unbounded_String (Config.URI_Contents  (Version));
      Info.Index     := To_Unbounded_String (Config.URI_Index     (Version));
      Info.Reference := To_Unbounded_String (Config.URI_Reference (Version));
      Info.Search    := To_Unbounded_String (Config.URI_Search    (Version));
      Info.Next      := To_Unbounded_String (Next);
      Info.Prev      := To_Unbounded_String (Prev);

      return Info;
   end Default_Info;

end HostARM_Navigate;
