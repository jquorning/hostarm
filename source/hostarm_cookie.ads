
with AWS.Response;
with AWS.Status;

with HostARM_Configuration;

package HostARM_Cookie is

   package Config renames HostARM_Configuration;

   procedure Get_Or_Default (Request : in     AWS.Status.Data;
                             State   :    out Config.State_Type);

   procedure Set (Response : in out AWS.Response.Data;
                  State    : in     Config.State_Type);

end HostARM_Cookie;
