
with HostARM_Configuration;

package HostARM_Cookie is

   package Config renames HostARM_Configuration;

   procedure Get_Or_Default (State : out Config.State_Type);

   procedure Set (State : in Config.State_Type);

end HostARM_Cookie;
