
with Ada.Directories;

package body HostARM_Configuration is

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

   -------------------
   -- Set_Directory --
   -------------------

   procedure Set_Directory (Directory : in String)
      renames Ada.Directories.Set_Directory;

end HostARM_Configuration;
