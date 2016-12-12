<?php
$_xhprof = array();

// Change these:
$_xhprof['dbtype'] = 'mysql'; // Only relevant for PDO
$_xhprof['dbhost'] = 'localhost';
$_xhprof['dbuser'] = '{{ DB_USER }}';
$_xhprof['dbpass'] = '{{ DB_PASS }}';
$_xhprof['dbname'] = 'xhprof';
$_xhprof['dbadapter'] = 'Pdo';
$_xhprof['servername'] = 'myserver';
$_xhprof['namespace'] = 'arquivei';
$_xhprof['url'] = 'https://xhprof.arquivei.com.br';
$_xhprof['getparam'] = "_profile";

$_xhprof['serializer'] = 'json';

$_xhprof['dot_binary']  = '/usr/bin/dot';
$_xhprof['dot_tempdir'] = '/tmp';
$_xhprof['dot_errfile'] = '/tmp/xh_dot.err';

$ignoreURLs = array();
$ignoreDomains = array();
$exceptionURLs = array();

$exceptionPostURLs = array();
$exceptionPostURLs[] = "login";

$_xhprof['display'] = false;
$_xhprof['doprofile'] = false;

//Control IPs allow you to specify which IPs will be permitted to control when profiling is on or off within your application, and view the results via the UI.
$controlIPs = false; //Disables access controlls completely.

//$otherURLS = array();

// ignore builtin functions and call_user_func* during profiling
//$ignoredFunctions = array('call_user_func', 'call_user_func_array', 'socket_select');

//Default weight - can be overidden by an Apache environment variable 'xhprof_weight' for domain-specific values
$weight = 100;

if ($domain_weight = getenv('xhprof_weight')) {
    $weight = $domain_weight;
}

unset($domain_weight);


function _aggregateCalls($calls, $rules = null)
{
    $rules = array(
        'Loading' => 'load::',
        'mysql' => 'mysql_'
    );

    // For domain-specific configuration, you can use Apache setEnv xhprof_aggregateCalls_include [some_php_file]
    if (isset($run_details['aggregateCalls_include']) && strlen($run_details['aggregateCalls_include']) > 1) {
        require_once($run_details['aggregateCalls_include']);
    }

    $addIns = array();
    foreach($calls as $index => $call) {
        foreach($rules as $rule => $search) {
            if (strpos($call['fn'], $search) !== false) {
                if (isset($addIns[$search])) {
                    unset($call['fn']);
                    foreach($call as $k => $v) {
                        $addIns[$search][$k] += $v;
                    }
                } else {
                    $call['fn'] = $rule;
                    $addIns[$search] = $call;
                }
                unset($calls[$index]);  //Remove it from the listing
                break;  //We don't need to run any more rules on this
            }
        }
    }
    return array_merge($addIns, $calls);
}
