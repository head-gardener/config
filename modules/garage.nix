{ pkgs, ... }:
{
  services.garage = {
    package = pkgs.garage;
    settings = {
      metadata_dir = "/var/lib/garage/meta";
      data_dir = "/var/lib/garage/data";
      metadata_fsync = true;
      data_fsync = false;
      s3_api = {
        api_bind_addr = "[::]:3900";
        s3_region = "garage";
        root_domain = ".s3.garage";
      };
      s3_web = {
        bind_addr = "[::]:3902";
        root_domain = ".web.garage";
      };
      admin = {
        api_bind_addr = "[::]:3903";
        metrics_token = "BCAdFjoa9G0KJR0WXnHHm7fs1ZAbfpI8iIZ+Z/a2NgI=";
        admin_token = "UkLeGWEvHnXBqnueR3ISEMWpOnm40jH2tM2HnnL/0F4=";
        trace_sink = "http://localhost:4317";
      };
      compression_level = 1;

      rpc_secret = "4425f5c26c5e11581d3223904324dcb5b5d5dfb14e5e7f35e38c595424f5f1e6";
      rpc_bind_addr = "[::]:3901";
      rpc_bind_outgoing = false;
      rpc_public_addr = "[fc00:1::1]:3901";
    };
    enable = true;
  };
}
