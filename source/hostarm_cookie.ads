
with AWS.Status;
with AWS.Response;

package HostARM_Cookie is

   function Exists (Request : in AWS.Status.Data)
                    return Boolean;
   procedure Load (Request : in out AWS.Status.Data);
   procedure Save (Response : in out AWS.Response.Data);

end HostARM_Cookie;
