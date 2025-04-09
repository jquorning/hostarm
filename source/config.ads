package Config is

   Default_Port : Positive := 16#ADA#;  --  Decimal: 2778

   Web_Base : constant String := "share/hostarm/ARM";

   type ARM_Version is (ARM_2012, ARM_2022, AARM_202Y);

   Default_ARM : ARM_Version := AARM_202Y;

   function ARM_Base return String
   is (case Default_ARM is
       when ARM_2012 =>   Web_Base & "/Ada_2012",
       when ARM_2022 =>   Web_Base & "/Ada_2022",
       when AARM_202Y =>  Web_Base & "/Ada_202Y");

end Config;
