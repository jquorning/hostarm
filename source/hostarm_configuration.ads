package HostARM_Configuration is

   Default_Port : Positive := 16#ADA#;  --  Decimal: 2778

   Web_Base   : constant String := "share/hostarm";
   Page_Base  : constant String := Web_Base & "/www";
   Tipue_Base : constant String := Web_Base;

   type ARM_Version is (ARM_2012, ARM_2022, AARM_202Y);

   function ARM_Base (Version : in ARM_Version)
                      return String;
   --  Web base for selected manual

   type State_Type is
      record
         Manual : ARM_Version;

         Pyne_Banner     : Boolean;
         Pyne_Nav_Top    : Boolean;
         Pyne_Nav_Bottom : Boolean;
         Pyne_Sponsor    : Boolean;
      end record;

   Default_State : constant State_Type :=
         (Manual          => ARM_2022,
          Pyne_Banner     => False,
          Pyne_Nav_Top    => False,
          Pyne_Nav_Bottom => True,
          Pyne_Sponsor    => False);

   Settings : State_Type := Default_State;

   URL_Without_HTML : Boolean := True;
   --  Strip .html from URL in Tipuesearch

   function URI_Contents (Version : in ARM_Version)
                          return String;
   function URI_Index (Version : in ARM_Version)
                       return String;
   function URI_Search (Version : in ARM_Version)
                        return String;
   function URI_Reference (Version : in ARM_Version)
                           return String;
   --  Selected manual page URI

end HostARM_Configuration;
