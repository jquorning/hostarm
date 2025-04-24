
--  The resources are expected to be located on the path:
--     share/hostarm/ARM    - Contain 3 dirs with the 2xRM and AA
--     share/hostarm/www    - Hostarm pages (home.thtml and search.thtml)
--     share/hostarm/assets - CSS, images, tipuesearch
--
--  Before building search DBs and serving pages then current directory
--  must be set to the 'hostarm' dir above.

package HostARM_Configuration is

   Default_Port : Positive := 16#ADA#;  --  Decimal: 2778

   Web_Base   : constant String := "./";
   Page_Base  : constant String := "www/";
   Tipue_Base : constant String := "./";

   type ARM_Version is (ARM_2012, ARM_2022, AARM_202Y);

   function ARM_Base (Version : in ARM_Version)
                      return String;
   --  Web base for selected manual

   type State_Type is
      record
         Manual          : ARM_Version;

         Pyne_Banner     : Boolean;
         Pyne_Nav_Top    : Boolean;
         Pyne_Nav_Bottom : Boolean;
         Pyne_Sponsor    : Boolean;

         Modernize       : Boolean;
      end record;

   Default_State : constant State_Type :=
         (Manual          => ARM_2022,
          Pyne_Banner     => False,
          Pyne_Nav_Top    => True,
          Pyne_Nav_Bottom => True,
          Pyne_Sponsor    => False,
          Modernize       => True);

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

   procedure Lookup_Home_Variable;
   --  Lookup HOME variable. Must be called before Share_Candidate_Path below.

   function Looking_Valid (Path : in String)
                           return Boolean;
   --  See if Path contains the needed directories.

   type Share_Candidate_Index is range 1 .. 6;
   function Share_Candidate_Path (Index : in Share_Candidate_Index)
                                  return String;
   --  Loop around this to get path of possible candidates for shared.

   procedure Set_Directory (Directory : in String);

end HostARM_Configuration;
