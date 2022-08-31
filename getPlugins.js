//@auth
//@url(wordpress.getplugins)
//@req(envName)

import com.hivext.api.Response;

let resp = api.env.control.ExecCmdByGroup( envName, session, "cp", toJSON([{ command: "wp plugin list --format=json --path=/var/www/webroot/ROOT/" }]));

if (resp.result != 0) return resp;

let scriptResp;

try {
    scriptResp = JSON.parse(resp.responses[0].out);
} catch(ex) {
    scriptResp = { result: Response.ERROR_UNKNOWN, error: ex, resp: resp }
}

return { result: 0, plugins: scriptResp };
