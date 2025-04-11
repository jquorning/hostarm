package body HostARM_Config is

   --------------
   -- ARM_Base --
   --------------

   function ARM_Base return String
   is
   begin
      case Default_ARM is
         when ARM_2012  =>  return Web_Base & "/ARM/Ada_2012";
         when ARM_2022  =>  return Web_Base & "/ARM/Ada_2022";
         when AARM_202Y =>  return Web_Base & "/ARM/Ada_202Y";
      end case;
   end ARM_Base;

   ------------------
   -- URI_Contents --
   ------------------

   function URI_Contents return String
   is
   begin
      case Default_ARM is
         when ARM_2012  =>  return "RM-TOC";
         when ARM_2022  =>  return "RM-TOC";
         when AARM_202Y =>  return "AA-TOC";
      end case;
   end URI_Contents;

   ---------------
   -- URI_Index --
   ---------------

   function URI_Index return String
   is
   begin
      case Default_ARM is
         when ARM_2012  =>  return "RM-0-4";
         when ARM_2022  =>  return "RM-0-4";
         when AARM_202Y =>  return "AA-0-4";
      end case;
   end URI_Index;

   ----------------
   -- URI_Search --
   ----------------

   function URI_Search return String
   is
   begin
      case Default_ARM is
         when ARM_2012  =>  return "RM-SRCH";
         when ARM_2022  =>  return "RM-SRCH";
         when AARM_202Y =>  return "AA-SRCH";
      end case;
   end URI_Search;

   -------------------
   -- URI_Reference --
   -------------------

   function URI_Reference return String
   is
   begin
      case Default_ARM is
         when ARM_2012  =>  return "RM-STDS";
         when ARM_2022  =>  return "RM-STDS";
         when AARM_202Y =>  return "AA-STDS";
      end case;
   end URI_Reference;

end HostARM_Config;
