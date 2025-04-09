package Config is

   Default_Port : Positive := 16#ADA#;  --  Decimal: 2778

   Web_Base : constant String := "share/hostarm";
   WWW_Base : constant String := Web_Base & "/www";

   type ARM_Version is (ARM_2012, ARM_2022, AARM_202Y);

   Default_ARM : ARM_Version := ARM_2022;

   function ARM_Base return String
   is (case Default_ARM is
       when ARM_2012 =>   Web_Base & "/ARM/Ada_2012",
       when ARM_2022 =>   Web_Base & "/ARM/Ada_2022",
       when AARM_202Y =>  Web_Base & "/ARM/Ada_202Y");

end Config;
