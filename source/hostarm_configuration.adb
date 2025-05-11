
with Ada.Environment_Variables;
with Ada.Directories;
with Ada.Strings.Unbounded;

package body HostARM_Configuration is

   subtype UString is Ada.Strings.Unbounded.Unbounded_String;

   Home_Path : UString;

   --------------
   -- ARM_Base --
   --------------

   function ARM_Base (Version : in ARM_Version)
                      return String
   is
   begin
      case Version is
         when ARM_2012  =>  return "ARM/Ada_2012/";
         when ARM_2022  =>  return "ARM/Ada_2022/";
         when AARM_202Y =>  return "ARM/Ada_202Y/";
      end case;
   end ARM_Base;

   ------------------
   -- URI_Contents --
   ------------------

   function URI_Contents (Version : in ARM_Version) return String
   is
   begin
      case Version is
         when ARM_2012  =>  return "RM-TOC";
         when ARM_2022  =>  return "RM-TOC";
         when AARM_202Y =>  return "AA-TOC";
      end case;
   end URI_Contents;

   ---------------
   -- URI_Index --
   ---------------

   function URI_Index (Version : in ARM_Version) return String
   is
   begin
      case Version is
         when ARM_2012  =>  return "RM-0-5";
         when ARM_2022  =>  return "RM-0-4";
         when AARM_202Y =>  return "AA-0-4";
      end case;
   end URI_Index;

   ----------------
   -- URI_Search --
   ----------------

   function URI_Search (Version : in ARM_Version) return String
   is
   begin
      case Version is
         when ARM_2012  =>  return "RM-SRCH";
         when ARM_2022  =>  return "RM-SRCH";
         when AARM_202Y =>  return "AA-SRCH";
      end case;
   end URI_Search;

   -------------------
   -- URI_Reference --
   -------------------

   function URI_Reference (Version : in ARM_Version) return String
   is
   begin
      case Version is
         when ARM_2012  =>  return "RM-STDS";
         when ARM_2022  =>  return "RM-STDS";
         when AARM_202Y =>  return "AA-STDS";
      end case;
   end URI_Reference;

   -------------------
   -- Looking_Valid --
   -------------------

   function Looking_Valid (Path : in String)
                           return Boolean
   is
      use Ada.Directories;
   begin
      return      Exists (Path)
         and then Exists (Path & "ARM/")
         and then Exists (Path & "www/")
         and then Exists (Path & "assets/");
   end Looking_Valid;

   --------------------------
   -- Share_Path_Candidate --
   --------------------------

   function Share_Candidate_Path (Index : in Share_Candidate_Index)
                                  return String
   is
      use Ada.Strings.Unbounded;
   begin
      case Index is
         when  1 =>  return "/usr/share/";
         when  2 =>  return "/usr/local/share/";
         when  3 =>  return To_String (Home_Path) & "/share/";
         when  4 =>  return To_String (Home_Path) & "/.alire/share/";
         when  5 =>  return To_String (Home_Path) & "/.local/share/";
         when  6 =>  return "../share/";
         when  7 =>  return "./share/";
      end case;
   end Share_Candidate_Path;

   -------------------
   -- Set_Directory --
   -------------------

   procedure Set_Directory (Directory : in String)
      renames Ada.Directories.Set_Directory;

   --------------------------
   -- Lookup_Home_Variable --
   --------------------------

   procedure Lookup_Home_Variable
   is
      use Ada.Environment_Variables;
      use Ada.Strings.Unbounded;

      Not_Found          : constant String := "<not found>";
      Home_Path_Unix     : constant String := Value ("HOME",      Not_Found);
      Home_Drive_Windows : constant String := Value ("HOMEDRIVE", Not_Found);
      Home_Path_Windows  : constant String := Value ("HOMEPATH",  Not_Found);
   begin

      if Home_Path_Unix /= Not_Found then
         Home_Path := To_Unbounded_String (Home_Path_Unix);
         return;
      end if;

      if
        Home_Drive_Windows /= Not_Found and
        Home_Path_Windows  /= Not_Found
      then
         Home_Path :=
            To_Unbounded_String (Home_Drive_Windows & Home_Path_Windows);
         return;
      end if;

      raise Constraint_Error with "HOME environt variable not found";
   end Lookup_Home_Variable;

end HostARM_Configuration;
