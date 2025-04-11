package HostARM_Configuration is

   Default_Port : Positive := 16#ADA#;  --  Decimal: 2778

   Web_Base   : constant String := "share/hostarm";
   WWW_Base   : constant String := Web_Base & "/www";
   Tipue_Base : constant String := Web_Base;

   type ARM_Version is (ARM_2012, ARM_2022, AARM_202Y);

   Default_ARM : ARM_Version := ARM_2022;

   function ARM_Base return String;
   --  Web base for selected manual

   Strip_Legend_Top    : Boolean := False;
   Strip_Legend_Bottom : Boolean := True;
   Strip_Title         : Boolean := True;
   Strip_Sponsor       : Boolean := True;

   URL_Without_HTML : Boolean := True;
   --  Strip .html from URL in Tipuesearch

   function URI_Contents  return String;
   function URI_Index     return String;
   function URI_Search    return String;
   function URI_Reference return String;
   --  Selected manual page URI

end HostARM_Configuration;
