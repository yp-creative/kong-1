package = "kong"
version = "0.8.3-0"
supported_platforms = {"linux", "macosx"}
source = {
  url = "kong"
}
description = {
  summary = "Kong is a scalable and customizable API Management Layer built on top of Nginx.",
  homepage = "http://getkong.org",
  license = "MIT"
}
dependencies = {
  "luasec ~> 0.5-2",
  "penlight ~> 1.3.2",
  "lua-resty-http ~> 0.07-0",
  "lua_uuid ~> 0.2.0-2",
  "lua_system_constants ~> 0.1.1-0",
  "luatz ~> 0.3-1",
  "yaml ~> 1.1.2-1",
  "lapis ~> 1.3.1-1",
  "stringy ~> 0.4-1",
  "lua-cassandra ~> 0.5.2",
  "pgmoon ~> 1.4.0",
  "multipart ~> 0.3-2",
  "lua-path ~> 0.2.3-1",
  "lua-cjson ~> 2.1.0-1",
  "ansicolors ~> 1.0.2-3",
  "lbase64 ~> 20120820-1",
  "lua-resty-iputils ~> 0.2.0-1",
  "mediator_lua ~> 1.1.2-0",

  "luasocket ~> 2.0.2-6",
  "lrexlib-pcre ~> 2.7.2-1",
  "lua-llthreads2 ~> 0.1.3-1",
  "luacrypto >= 0.3.2-1",
  "luasyslog >= 1.0.0-2",
  "lua_pack ~> 1.0.4-0"
}
build = {
  type = "builtin",
  modules = {
    ["kong"] = "kong/kong.lua",

    ["classic"] = "kong/vendor/classic.lua",
    ["lapp"] = "kong/vendor/lapp.lua",

    ["kong.meta"] = "kong/meta.lua",
    ["kong.constants"] = "kong/constants.lua",
    ["kong.singletons"] = "kong/singletons.lua",

    ["kong.cli.utils.logger"] = "kong/cli/utils/logger.lua",
    ["kong.cli.utils.ssl"] = "kong/cli/utils/ssl.lua",
    ["kong.cli.utils.services"] = "kong/cli/utils/services.lua",
    ["kong.cli.cmds.config"] = "kong/cli/cmds/config.lua",
    ["kong.cli.cmds.quit"] = "kong/cli/cmds/quit.lua",
    ["kong.cli.cmds.stop"] = "kong/cli/cmds/stop.lua",
    ["kong.cli.cmds.start"] = "kong/cli/cmds/start.lua",
    ["kong.cli.cmds.reload"] = "kong/cli/cmds/reload.lua",
    ["kong.cli.cmds.restart"] = "kong/cli/cmds/restart.lua",
    ["kong.cli.cmds.version"] = "kong/cli/cmds/version.lua",
    ["kong.cli.cmds.status"] = "kong/cli/cmds/status.lua",
    ["kong.cli.services.base_service"] = "kong/cli/services/base_service.lua",
    ["kong.cli.services.nginx"] = "kong/cli/services/nginx.lua",

    ["kong.api.app"] = "kong/api/app.lua",
    ["kong.api.api_helpers"] = "kong/api/api_helpers.lua",
    ["kong.api.crud_helpers"] = "kong/api/crud_helpers.lua",
    ["kong.api.routes.kong"] = "kong/api/routes/kong.lua",
    ["kong.api.routes.apis"] = "kong/api/routes/apis.lua",
    ["kong.api.routes.consumers"] = "kong/api/routes/consumers.lua",
    ["kong.api.routes.plugins"] = "kong/api/routes/plugins.lua",
    ["kong.api.routes.cache"] = "kong/api/routes/cache.lua",
    ["kong.api.routes.cluster"] = "kong/api/routes/cluster.lua",

    ["kong.tools.io"] = "kong/tools/io.lua",
    ["kong.tools.utils"] = "kong/tools/utils.lua",
    ["kong.tools.printable"] = "kong/tools/printable.lua",
    ["kong.tools.responses"] = "kong/tools/responses.lua",
    ["kong.tools.timestamp"] = "kong/tools/timestamp.lua",
    ["kong.tools.config_defaults"] = "kong/tools/config_defaults.lua",
    ["kong.tools.config_loader"] = "kong/tools/config_loader.lua",

    ["kong.core.handler"] = "kong/core/handler.lua",
    ["kong.core.error_handlers"] = "kong/core/error_handlers.lua",

    ["kong.dao.errors"] = "kong/dao/errors.lua",
    ["kong.dao.schemas_validation"] = "kong/dao/schemas_validation.lua",
    ["kong.dao.base_db"] = "kong/dao/base_db.lua",
    ["kong.dao.cassandra_db"] = "kong/dao/cassandra_db.lua",
    ["kong.dao.postgres_db"] = "kong/dao/postgres_db.lua",

    ["kong.plugins.base_plugin"] = "kong/plugins/base_plugin.lua",

    ["kong.plugins.log-serializers.basic"] = "kong/plugins/log-serializers/basic.lua",
    ["kong.plugins.log-serializers.runscope"] = "kong/plugins/log-serializers/runscope.lua",

    ["kong.plugins.file-log.handler"] = "kong/plugins/file-log/handler.lua",
    ["kong.plugins.file-log.schema"] = "kong/plugins/file-log/schema.lua",

    ["kong.plugins.rate-limiting.migrations.cassandra"] = "kong/plugins/rate-limiting/migrations/cassandra.lua",
    ["kong.plugins.rate-limiting.migrations.postgres"] = "kong/plugins/rate-limiting/migrations/postgres.lua",
    ["kong.plugins.rate-limiting.handler"] = "kong/plugins/rate-limiting/handler.lua",
    ["kong.plugins.rate-limiting.schema"] = "kong/plugins/rate-limiting/schema.lua",
    ["kong.plugins.rate-limiting.dao.cassandra"] = "kong/plugins/rate-limiting/dao/cassandra.lua",
    ["kong.plugins.rate-limiting.dao.postgres"] = "kong/plugins/rate-limiting/dao/postgres.lua",

    ["kong.plugins.syslog.handler"] = "kong/plugins/syslog/handler.lua",
    ["kong.plugins.syslog.schema"] = "kong/plugins/syslog/schema.lua",

    ["kong.yop.cache"] = "kong/yop/cache.lua",
    ["kong.yop.response"] = "kong/yop/response.lua",
    ["kong.yop.dkjson"] = "kong/yop/dkjson.lua",
    ["kong.yop.security_center"] = "kong/yop/security_center.lua",
    ["kong.plugins.yop.interceptor.authenticate"] = "kong/plugins/yop/interceptor/authenticate.lua",
    ["kong.plugins.yop.interceptor.authenticate-impl.oauth2_authenticate"] = "kong/plugins/yop/interceptor/authenticate-impl/oauth2_authenticate.lua",
    ["kong.plugins.yop.interceptor.authenticate-impl.secret_authenticate"] = "kong/plugins/yop/interceptor/authenticate-impl/secret_authenticate.lua",
    ["kong.plugins.yop.interceptor.authorize"] = "kong/plugins/yop/interceptor/authorize.lua",
    ["kong.plugins.yop.interceptor.default_value"] = "kong/plugins/yop/interceptor/default_value.lua",
    ["kong.plugins.yop.interceptor.http_method"] = "kong/plugins/yop/interceptor/http_method.lua",
    ["kong.plugins.yop.interceptor.initialize_ctx"] = "kong/plugins/yop/interceptor/initialize_ctx.lua",
    ["kong.plugins.yop.interceptor.load_balance"] = "kong/plugins/yop/interceptor/load_balance.lua",
    ["kong.plugins.yop.interceptor.request_transformer"] = "kong/plugins/yop/interceptor/request_transformer.lua",
    ["kong.plugins.yop.interceptor.request_validator"] = "kong/plugins/yop/interceptor/request_validator.lua",
    ["kong.plugins.yop.interceptor.whitelist"] = "kong/plugins/yop/interceptor/whitelist.lua",
    ["kong.plugins.yop.interceptor.yop_request_id"] = "kong/plugins/yop/interceptor/yop_request_id.lua",
    ["kong.plugins.yop.handler"] = "kong/plugins/yop/handler.lua"
  },
  install = {
    conf = { "kong.yml" },
    bin = { "bin/kong" }
  }
}
