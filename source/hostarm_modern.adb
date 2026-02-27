
with Ada.Strings.Fixed;

with HostARM_Tools;

package body HostARM_Modern is

   package Tools  renames HostARM_Tools;

   CRLF : String renames Tools.CRLF;

   Text_1  : constant String :=
      CRLF & "<header class='nav'><ul class='nav'>" & CRLF;
   Text_31 : constant String := "  <li class='nav'>";
   Text_3x : constant String := "<a class='nav-";
   Text_3y : constant String := "' href='";
   Text_33 : constant String := "'>";
   Text_34 : constant String := "</a></li>"  & CRLF;
   Text_2  : constant String := CRLF & "</ul></header>" & CRLF;

   ---------------
   -- Append_LI --
   ---------------

   procedure Append_LI (DIV : in out UString;
                        URI : in     String;
                        ALT : in     String)
   is
      use Ada.Strings.Fixed;
      use Ada.Strings.Unbounded;

      --  Ie 'nav-index'
      Class_2 : constant String := Translate (ALT,     Tools.To_Lower_Case);
      Class   : constant String := Translate (Class_2, Tools.Space_To_Hyphen);
   begin
      if URI = "" then
         return;
      end if;

      Append (DIV, Text_31);
      Append (DIV, Text_3x);
      Append (DIV, Class);

      Append (DIV, Text_3y);  Append (DIV, URI);
      Append (DIV, Text_33);  Append (DIV, ALT);
      Append (DIV, Text_34);
   end Append_LI;

   -------------------------
   -- Make_Navigation_DIV --
   -------------------------

   procedure Make_Navigation_DIV (DIV     :    out UString;
                                  Nav     : in     Nav_Info;
                                  Version : in     Config.ARM_Version)
   is
      use Ada.Strings.Unbounded;
   begin
      Append (DIV, Text_1);
      Append_LI (DIV, ALT => "Home",        URI => "/home");
      Append_LI (DIV, ALT => "Contents",    URI => To_String (Nav.Contents));
      Append_LI (DIV, ALT => "Index",       URI => To_String (Nav.Index));
      Append_LI (DIV, ALT => "Reference",   URI => To_String (Nav.Reference));
      Append_LI (DIV,
                 ALT => "Ada-Auth Search",
                 URI => Config.URI_Search (Version));
      Append_LI (DIV, ALT => "Search",      URI => "/search");
      Append_LI (DIV, ALT => "Previous",    URI => To_String (Nav.Prev));
      Append_LI (DIV, ALT => "Next",        URI => To_String (Nav.Next));
      Append (DIV, Text_2);
   end Make_Navigation_DIV;

   ---------------------------
   -- Insert_Navigation_DIV --
   ---------------------------

   procedure Insert_Navigation_DIV (Payload : in out UString;
                                    DIV     : in     UString)
   is
      use Ada.Strings.Unbounded;

      DIV_String : constant String := To_String (DIV);
      Match_1 : constant String := "<body";
      Match_2 : constant String := ">";
      Pos_1   : Natural;
      Pos_2   : Natural;
   begin
      Pos_1 := Index (Payload, Match_1, From => 1,
                      Mapping => Tools.To_Lower_Case);
      if Pos_1 = 0 then
         return;
      end if;

      Pos_2 := Index (Payload, Match_2, From => Pos_1 + Match_1'Length);
      if Pos_2 = 0 then   -- BODY has no end bracket!!
         return;
      end if;

      Replace_Slice (Payload, By => DIV_String,
                     Low  => Pos_2 + Match_2'Length,
                     High => Pos_2 + Match_2'Length);
   end Insert_Navigation_DIV;

end HostARM_Modern;
