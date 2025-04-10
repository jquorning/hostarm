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
   -- Ada_Auth_URL --
   ------------------

   function Ada_Auth_URL return String
   is
   begin
      case Default_ARM is
         when ARM_2012  =>
            return "http://www.ada-auth.org/search-rm12_w_tc1.cgi";
         when ARM_2022  =>
            return "http://www.ada-auth.org/search-rm22.cgi";
         when AARM_202Y =>
            return "http://www.ada-auth.org/search-aarm2y.cgi";
      end case;
   end Ada_Auth_URL;

end HostARM_Config;
