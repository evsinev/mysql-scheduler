set names utf8 collate utf8_general_ci;

grant select on mysql.proc to '${grant_user}' @'${grant_host}';