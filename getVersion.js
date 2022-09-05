//@auth
//@url(wordpress.getversion)
//@req(envName)

import com.hivext.api.Response;

var envInfo = jelastic.env.control.GetEnvInfo(envName, session);

if (envInfo.result != 0) return envInfo;
    
for (var i = 0, k = envInfo.nodes; i < k.length; i++) {
    if (k[i].nodeGroup == 'cp' && k[i].ismaster)
        nodeId = k[i].id;
}

var resp = api.env.control.ExecCmdById(envName, session, nodeId, toJSON([{ command: "curl --silent https://raw.githubusercontent.com/sych74/wordpress-cli/main/japp.sh > ~/bin/japp.sh && bash ~/bin/japp.sh getVersion" }]));

if (resp.result != 0) return resp;

var scriptResp;

try {
    scriptResp = JSON.parse(resp.responses[0].out);
} catch(ex) {
    scriptResp = { result: Response.ERROR_UNKNOWN, error: ex, resp: resp }
}

return { result: 0, out: scriptResp };
