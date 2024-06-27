#compdef warp-cli

autoload -U is-at-least

_warp-cli() {
    typeset -A opt_args
    typeset -a _arguments_options
    local ret=1

    if is-at-least 5.2; then
        _arguments_options=(-s -S -C)
    else
        _arguments_options=(-s -C)
    fi

    local context curcontext="$curcontext" state line
    _arguments "${_arguments_options[@]}" \
'-t+[Timeout (in seconds) before IPC channel is considered hung]:IPCTIMEOUT: ' \
'--timeout=[Timeout (in seconds) before IPC channel is considered hung]:IPCTIMEOUT: ' \
'-l[Listen for status changes and DNS logs (if enabled)]' \
'--listen[Listen for status changes and DNS logs (if enabled)]' \
'--accept-tos[Accept the Terms of Service agreement]' \
'*-v[Enable verbose output. Multiple "v"s adds more verbosity]' \
'*--verbose[Enable verbose output. Multiple "v"s adds more verbosity]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
":: :_warp-cli_commands" \
"*::: :->warp-cli" \
&& ret=0
    case $state in
    (warp-cli)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-command-$line[1]:"
        case $line[1] in
            (api)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__api_commands" \
"*::: :->api" \
&& ret=0

    case $state in
    (api)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-api-command-$line[1]:"
        case $line[1] in
            (endpoint)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__api__endpoint_commands" \
"*::: :->endpoint" \
&& ret=0

    case $state in
    (endpoint)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-api-endpoint-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':addr -- A valid IPv4 or IPv6 address:' \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__api__endpoint__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-api-endpoint-help-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__api__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-api-help-command-$line[1]:"
        case $line[1] in
            (endpoint)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__api__help__endpoint_commands" \
"*::: :->endpoint" \
&& ret=0

    case $state in
    (endpoint)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-api-help-endpoint-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(connect)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(debug)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__debug_commands" \
"*::: :->debug" \
&& ret=0

    case $state in
    (debug)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-debug-command-$line[1]:"
        case $line[1] in
            (access-reauth)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(alternate-network)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(connectivity-check)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':enabled:(enable disable)' \
&& ret=0
;;
(dex)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(network)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(panic)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(posture)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(pcap)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__debug__pcap_commands" \
"*::: :->pcap" \
&& ret=0

    case $state in
    (pcap)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-debug-pcap-command-$line[1]:"
        case $line[1] in
            (start)
_arguments "${_arguments_options[@]}" \
'--packet-size=[Maximum number of bytes to save for each packet]:PACKET_SIZE: ' \
'-h[Print help]' \
'--help[Print help]' \
'::interface -- Network interface to capture from; use '\''_default'\'' for the default network interface, '\''_tun'\'' for network interface for tunnel to Cloudflare, or name of a specific interface to target:' \
&& ret=0
;;
(stop)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__debug__pcap__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-debug-pcap-help-command-$line[1]:"
        case $line[1] in
            (start)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(stop)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(task-dump)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(qlog)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':enabled:(enable disable)' \
&& ret=0
;;
(log-filter)
_arguments "${_arguments_options[@]}" \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
":: :_warp-cli__debug__log-filter_commands" \
"*::: :->log-filter" \
&& ret=0

    case $state in
    (log-filter)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-debug-log-filter-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':filter:' \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__debug__log-filter__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-debug-log-filter-help-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__debug__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-debug-help-command-$line[1]:"
        case $line[1] in
            (access-reauth)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(alternate-network)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(connectivity-check)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(dex)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(network)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(panic)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(posture)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(pcap)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__debug__help__pcap_commands" \
"*::: :->pcap" \
&& ret=0

    case $state in
    (pcap)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-debug-help-pcap-command-$line[1]:"
        case $line[1] in
            (start)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(stop)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(task-dump)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(qlog)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(log-filter)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__debug__help__log-filter_commands" \
"*::: :->log-filter" \
&& ret=0

    case $state in
    (log-filter)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-debug-help-log-filter-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(disconnect)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(dns)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__dns_commands" \
"*::: :->dns" \
&& ret=0

    case $state in
    (dns)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-dns-command-$line[1]:"
        case $line[1] in
            (endpoint)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__dns__endpoint_commands" \
"*::: :->endpoint" \
&& ret=0

    case $state in
    (endpoint)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-dns-endpoint-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':addr -- A valid IPv4 or IPv6 address:' \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__dns__endpoint__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-dns-endpoint-help-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(fallback)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__dns__fallback_commands" \
"*::: :->fallback" \
&& ret=0

    case $state in
    (fallback)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-dns-fallback-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':add:' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':remove:' \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__dns__fallback__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-dns-fallback-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(families)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':mode:(full malware off)' \
&& ret=0
;;
(gateway-id)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__dns__gateway-id_commands" \
"*::: :->gateway-id" \
&& ret=0

    case $state in
    (gateway-id)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-dns-gateway-id-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':param:' \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__dns__gateway-id__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-dns-gateway-id-help-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(log)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':enabled:(enable disable)' \
&& ret=0
;;
(stats)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__dns__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-dns-help-command-$line[1]:"
        case $line[1] in
            (endpoint)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__dns__help__endpoint_commands" \
"*::: :->endpoint" \
&& ret=0

    case $state in
    (endpoint)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-dns-help-endpoint-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(fallback)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__dns__help__fallback_commands" \
"*::: :->fallback" \
&& ret=0

    case $state in
    (fallback)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-dns-help-fallback-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(families)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(gateway-id)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__dns__help__gateway-id_commands" \
"*::: :->gateway-id" \
&& ret=0

    case $state in
    (gateway-id)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-dns-help-gateway-id-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(log)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(stats)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(mdm)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__mdm_commands" \
"*::: :->mdm" \
&& ret=0

    case $state in
    (mdm)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-mdm-command-$line[1]:"
        case $line[1] in
            (get-configs)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(set-config)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':config:' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__mdm__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-mdm-help-command-$line[1]:"
        case $line[1] in
            (get-configs)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(set-config)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(mode)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':mode:(warp doh warp+doh dot warp+dot proxy tunnel_only)' \
&& ret=0
;;
(override)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':code:' \
":: :_warp-cli__override_commands" \
"*::: :->override" \
&& ret=0

    case $state in
    (override)
        words=($line[2] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-override-command-$line[2]:"
        case $line[2] in
            (show)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(unlock)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':code:' \
&& ret=0
;;
(generate)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':hours:' \
&& ret=0
;;
(local-network)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__override__local-network_commands" \
"*::: :->local-network" \
&& ret=0

    case $state in
    (local-network)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-override-local-network-command-$line[1]:"
        case $line[1] in
            (allow)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(show)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(stop)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__override__local-network__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-override-local-network-help-command-$line[1]:"
        case $line[1] in
            (allow)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(show)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(stop)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__override__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-override-help-command-$line[1]:"
        case $line[1] in
            (show)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(unlock)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(generate)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(local-network)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__override__help__local-network_commands" \
"*::: :->local-network" \
&& ret=0

    case $state in
    (local-network)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-override-help-local-network-command-$line[1]:"
        case $line[1] in
            (allow)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(show)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(stop)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(proxy)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__proxy_commands" \
"*::: :->proxy" \
&& ret=0

    case $state in
    (proxy)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-proxy-command-$line[1]:"
        case $line[1] in
            (port)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':port:' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__proxy__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-proxy-help-command-$line[1]:"
        case $line[1] in
            (port)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(registration)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__registration_commands" \
"*::: :->registration" \
&& ret=0

    case $state in
    (registration)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-registration-command-$line[1]:"
        case $line[1] in
            (show)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
'::organization -- Optional\: a Zero Trust organization to join:' \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(organization)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(devices)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(license)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':key:' \
&& ret=0
;;
(token)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':url:' \
&& ret=0
;;
(initialize-token-callback)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__registration__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-registration-help-command-$line[1]:"
        case $line[1] in
            (show)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(organization)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(devices)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(license)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(token)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(initialize-token-callback)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(settings)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__settings_commands" \
"*::: :->settings" \
&& ret=0

    case $state in
    (settings)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-settings-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(support-url)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(mode-switch-allowed)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__settings__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-settings-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(support-url)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(mode-switch-allowed)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(status)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(trusted)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__trusted_commands" \
"*::: :->trusted" \
&& ret=0

    case $state in
    (trusted)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-trusted-command-$line[1]:"
        case $line[1] in
            (ssid)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__trusted__ssid_commands" \
"*::: :->ssid" \
&& ret=0

    case $state in
    (ssid)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-trusted-ssid-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':add:' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':remove:' \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__trusted__ssid__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-trusted-ssid-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(ethernet)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':enabled:(enable disable)' \
&& ret=0
;;
(wifi)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':enabled:(enable disable)' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__trusted__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-trusted-help-command-$line[1]:"
        case $line[1] in
            (ssid)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__trusted__help__ssid_commands" \
"*::: :->ssid" \
&& ret=0

    case $state in
    (ssid)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-trusted-help-ssid-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(ethernet)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(wifi)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(tunnel)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__tunnel_commands" \
"*::: :->tunnel" \
&& ret=0

    case $state in
    (tunnel)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-tunnel-command-$line[1]:"
        case $line[1] in
            (dump)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(host)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__tunnel__host_commands" \
"*::: :->host" \
&& ret=0

    case $state in
    (host)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-tunnel-host-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':add:' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':remove:' \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__tunnel__host__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-tunnel-host-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(ip)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__tunnel__ip_commands" \
"*::: :->ip" \
&& ret=0

    case $state in
    (ip)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-tunnel-ip-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':add -- A valid IPv4 or IPv6 address:' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':remove -- A valid IPv4 or IPv6 address:' \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__tunnel__ip__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-tunnel-ip-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(stats)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(rotate-keys)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(endpoint)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
":: :_warp-cli__tunnel__endpoint_commands" \
"*::: :->endpoint" \
&& ret=0

    case $state in
    (endpoint)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-tunnel-endpoint-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':sockaddr:' \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__tunnel__endpoint__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-tunnel-endpoint-help-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(mtu)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':mtu:' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__tunnel__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-tunnel-help-command-$line[1]:"
        case $line[1] in
            (dump)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(host)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__tunnel__help__host_commands" \
"*::: :->host" \
&& ret=0

    case $state in
    (host)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-tunnel-help-host-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(ip)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__tunnel__help__ip_commands" \
"*::: :->ip" \
&& ret=0

    case $state in
    (ip)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-tunnel-help-ip-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(stats)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(rotate-keys)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(endpoint)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__tunnel__help__endpoint_commands" \
"*::: :->endpoint" \
&& ret=0

    case $state in
    (endpoint)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-tunnel-help-endpoint-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(mtu)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(vnet)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
'::vnet:' \
&& ret=0
;;
(register)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(teams-enroll)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':team:' \
&& ret=0
;;
(teams-enroll-token)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':url:' \
&& ret=0
;;
(register-token-callback)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(rotate-keys)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(warp-stats)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(warp-dns-stats)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(disable-wifi)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(enable-wifi)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(disable-ethernet)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(enable-ethernet)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(add-trusted-ssid)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':ssid:' \
&& ret=0
;;
(remove-trusted-ssid)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':ssid:' \
&& ret=0
;;
(exclude-private-ips)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(enable-dns-log)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(disable-dns-log)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(account)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(devices)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(network)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(get-virtual-networks)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(set-virtual-network)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':network:' \
&& ret=0
;;
(set-mode)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':mode:(warp doh warp+doh dot warp+dot proxy tunnel_only)' \
&& ret=0
;;
(set-families-mode)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':mode:(full malware off)' \
&& ret=0
;;
(set-license)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':license:' \
&& ret=0
;;
(set-gateway)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':unique_id:' \
&& ret=0
;;
(clear-gateway)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(set-custom-endpoint)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':endpoint:' \
&& ret=0
;;
(clear-custom-endpoint)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(set-warp-override-ip)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':ip:' \
&& ret=0
;;
(clear-warp-override-ip)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(add-excluded-route)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':ip:' \
&& ret=0
;;
(remove-excluded-route)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':ip:' \
&& ret=0
;;
(get-excluded-routes)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(get-included-routes)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(get-excluded-hosts)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(get-included-hosts)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(add-excluded-host)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':host:' \
&& ret=0
;;
(remove-excluded-host)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':host:' \
&& ret=0
;;
(set-doh-endpoint)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':endpoint:' \
&& ret=0
;;
(clear-doh-endpoint)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(add-fallback-domain)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':fd:' \
&& ret=0
;;
(remove-fallback-domain)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':fd:' \
&& ret=0
;;
(get-fallback-domains)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(restore-fallback-domains)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(get-device-posture)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(get-override-code)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
'::time_limit -- Time limit for admin override code (in hours):' \
&& ret=0
;;
(set-proxy-port)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':warp:' \
&& ret=0
;;
(is-mode-switch-allowed)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(reset-settings)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(get-organization)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(access-reauth)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(get-support-url)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(get-pause-end)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(get-override-end)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(disable-connectivity-checks)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(enable-connectivity-checks)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(set-tunnel-mtu)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':mtu:' \
&& ret=0
;;
(force-panic)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(dump-excluded-routes)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(get-alternate-network)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(get-dex-data)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(start-packet-capture)
_arguments "${_arguments_options[@]}" \
'--packet-size=[Maximum number of bytes to save for each packet]:PACKET_SIZE: ' \
'-h[Print help]' \
'--help[Print help]' \
'::interface -- Network interface to capture from; use '\''_default'\'' for the default network interface, '\''_tun'\'' for network interface for tunnel to Cloudflare, or name of a specific interface to target:' \
&& ret=0
;;
(stop-packet-capture)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(generate-completions)
_arguments "${_arguments_options[@]}" \
'-h[Print help]' \
'--help[Print help]' \
':shell:(bash elvish fish powershell zsh)' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-command-$line[1]:"
        case $line[1] in
            (api)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__api_commands" \
"*::: :->api" \
&& ret=0

    case $state in
    (api)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-api-command-$line[1]:"
        case $line[1] in
            (endpoint)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__api__endpoint_commands" \
"*::: :->endpoint" \
&& ret=0

    case $state in
    (endpoint)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-api-endpoint-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(connect)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(debug)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__debug_commands" \
"*::: :->debug" \
&& ret=0

    case $state in
    (debug)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-debug-command-$line[1]:"
        case $line[1] in
            (access-reauth)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(alternate-network)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(connectivity-check)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(dex)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(network)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(panic)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(posture)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(pcap)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__debug__pcap_commands" \
"*::: :->pcap" \
&& ret=0

    case $state in
    (pcap)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-debug-pcap-command-$line[1]:"
        case $line[1] in
            (start)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(stop)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(task-dump)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(qlog)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(log-filter)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__debug__log-filter_commands" \
"*::: :->log-filter" \
&& ret=0

    case $state in
    (log-filter)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-debug-log-filter-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(disconnect)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(dns)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__dns_commands" \
"*::: :->dns" \
&& ret=0

    case $state in
    (dns)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-dns-command-$line[1]:"
        case $line[1] in
            (endpoint)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__dns__endpoint_commands" \
"*::: :->endpoint" \
&& ret=0

    case $state in
    (endpoint)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-dns-endpoint-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(fallback)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__dns__fallback_commands" \
"*::: :->fallback" \
&& ret=0

    case $state in
    (fallback)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-dns-fallback-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(families)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(gateway-id)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__dns__gateway-id_commands" \
"*::: :->gateway-id" \
&& ret=0

    case $state in
    (gateway-id)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-dns-gateway-id-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(log)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(stats)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(mdm)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__mdm_commands" \
"*::: :->mdm" \
&& ret=0

    case $state in
    (mdm)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-mdm-command-$line[1]:"
        case $line[1] in
            (get-configs)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(set-config)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(mode)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(override)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__override_commands" \
"*::: :->override" \
&& ret=0

    case $state in
    (override)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-override-command-$line[1]:"
        case $line[1] in
            (show)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(unlock)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(generate)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(local-network)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__override__local-network_commands" \
"*::: :->local-network" \
&& ret=0

    case $state in
    (local-network)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-override-local-network-command-$line[1]:"
        case $line[1] in
            (allow)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(show)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(stop)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(proxy)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__proxy_commands" \
"*::: :->proxy" \
&& ret=0

    case $state in
    (proxy)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-proxy-command-$line[1]:"
        case $line[1] in
            (port)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(registration)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__registration_commands" \
"*::: :->registration" \
&& ret=0

    case $state in
    (registration)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-registration-command-$line[1]:"
        case $line[1] in
            (show)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(organization)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(devices)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(license)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(token)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(initialize-token-callback)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(settings)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__settings_commands" \
"*::: :->settings" \
&& ret=0

    case $state in
    (settings)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-settings-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(support-url)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(mode-switch-allowed)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(status)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(trusted)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__trusted_commands" \
"*::: :->trusted" \
&& ret=0

    case $state in
    (trusted)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-trusted-command-$line[1]:"
        case $line[1] in
            (ssid)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__trusted__ssid_commands" \
"*::: :->ssid" \
&& ret=0

    case $state in
    (ssid)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-trusted-ssid-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(ethernet)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(wifi)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(tunnel)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__tunnel_commands" \
"*::: :->tunnel" \
&& ret=0

    case $state in
    (tunnel)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-tunnel-command-$line[1]:"
        case $line[1] in
            (dump)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(host)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__tunnel__host_commands" \
"*::: :->host" \
&& ret=0

    case $state in
    (host)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-tunnel-host-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(ip)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__tunnel__ip_commands" \
"*::: :->ip" \
&& ret=0

    case $state in
    (ip)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-tunnel-ip-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(stats)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(rotate-keys)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(endpoint)
_arguments "${_arguments_options[@]}" \
":: :_warp-cli__help__tunnel__endpoint_commands" \
"*::: :->endpoint" \
&& ret=0

    case $state in
    (endpoint)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:warp-cli-help-tunnel-endpoint-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(mtu)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
(vnet)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(register)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(teams-enroll)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(teams-enroll-token)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(register-token-callback)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(rotate-keys)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(warp-stats)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(warp-dns-stats)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(disable-wifi)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(enable-wifi)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(disable-ethernet)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(enable-ethernet)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(add-trusted-ssid)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(remove-trusted-ssid)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(exclude-private-ips)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(enable-dns-log)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(disable-dns-log)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(account)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(devices)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(network)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(get-virtual-networks)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(set-virtual-network)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(set-mode)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(set-families-mode)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(set-license)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(set-gateway)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(clear-gateway)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(set-custom-endpoint)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(clear-custom-endpoint)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(set-warp-override-ip)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(clear-warp-override-ip)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(add-excluded-route)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(remove-excluded-route)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(get-excluded-routes)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(get-included-routes)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(get-excluded-hosts)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(get-included-hosts)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(add-excluded-host)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(remove-excluded-host)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(set-doh-endpoint)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(clear-doh-endpoint)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(add-fallback-domain)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(remove-fallback-domain)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(get-fallback-domains)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(restore-fallback-domains)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(get-device-posture)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(get-override-code)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(set-proxy-port)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(is-mode-switch-allowed)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(reset-settings)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(get-organization)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(access-reauth)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(get-support-url)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(get-pause-end)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(get-override-end)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(disable-connectivity-checks)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(enable-connectivity-checks)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(set-tunnel-mtu)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(force-panic)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(dump-excluded-routes)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(get-alternate-network)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(get-dex-data)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(start-packet-capture)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(stop-packet-capture)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(generate-completions)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
}

(( $+functions[_warp-cli_commands] )) ||
_warp-cli_commands() {
    local commands; commands=(
'api:Allow overriding Cloudflare API address' \
'connect:Maintain a connection whenever possible' \
'debug:Debugging commands' \
'disconnect:Disconnect the client' \
'dns:Configure DNS settings' \
'mdm:MDM configs' \
'mode:Set the client'\''s general operating mode' \
'override:Allow temporary overrides of administrative settings' \
'proxy:Configure proxy mode settings' \
'registration:Registration settings' \
'settings:Show or alter general application settings' \
'status:Return the current connection status' \
'trusted:Configure trusted networks where the client will be automatically disabled (Consumer only)' \
'tunnel:Configure tunnel settings' \
'vnet:Get or specify connected virtual network' \
'register:Register with the WARP API, replacing any existing registration (Must be run before first connection!)' \
'teams-enroll:Enroll with Cloudflare for Teams' \
'teams-enroll-token:' \
'register-token-callback:Registers the browser token callback without actually registering' \
'delete:Delete current registration' \
'rotate-keys:Generate a new key-pair, keeping the current registration' \
'warp-stats:Retrieve the stats for the current WARP connection' \
'warp-dns-stats:Retrieve the DNS stats for the current WARP connection' \
'disable-wifi:Automatically disable WARP on Wi-Fi networks (disabled for Zero Trust customers)' \
'enable-wifi:Allow WARP on Wi-Fi networks (disabled for Zero Trust customers)' \
'disable-ethernet:Automatically disable WARP on ethernet networks (disabled for Zero Trust customers)' \
'enable-ethernet:Allow WARP on ethernet networks (disabled for Zero Trust customers)' \
'add-trusted-ssid:Add a trusted Wi-Fi network for which WARP will be automatically disconnected' \
'remove-trusted-ssid:Remove a trusted Wi-Fi network' \
'exclude-private-ips:Exclude private IP ranges from tunnel' \
'enable-dns-log:Enable DNS logging (Use with the -l option)' \
'disable-dns-log:Disable DNS logging' \
'account:Display the account associated with the current registration' \
'devices:Display the list of devices associated with the current registration' \
'network:Display the current network information' \
'get-virtual-networks:List the available virtual networks' \
'set-virtual-network:Set the currently connected virtual network via the id from get-virtual-networks' \
'set-mode:Set the mode' \
'set-families-mode:Set the families mode' \
'set-license:Attach the current registration to a different account using a license key' \
'set-gateway:Force the app to use the specified Gateway ID for DNS queries' \
'clear-gateway:Clear the Gateway ID' \
'set-custom-endpoint:Force the client to connect to the specified IP\:PORT endpoint (Zero Trust customers must run this command as a privileged user)' \
'clear-custom-endpoint:Remove the custom endpoint setting' \
'set-warp-override-ip:Add an IP to use instead of the default Cloudflare API IP' \
'clear-warp-override-ip:Remove all override IPs for the Cloudflare API' \
'add-excluded-route:Add an excluded IP' \
'remove-excluded-route:Remove an excluded IP' \
'get-excluded-routes:Get the list of excluded routes' \
'get-included-routes:Get the list of included routes' \
'get-excluded-hosts:Get the list of excluded hosts' \
'get-included-hosts:Get the list of included hosts' \
'add-excluded-host:Add an excluded host' \
'remove-excluded-host:Remove an excluded host' \
'set-doh-endpoint:Set a custom DNS Over HTTPS server endpoint. Must be a valid IP address, not hostname' \
'clear-doh-endpoint:Remove the custom endpoint setting' \
'add-fallback-domain:Add a domain that should be resolved with the fallback resolver instead of WARP'\''s' \
'remove-fallback-domain:Stop a domain from being resolved with the fallback resolver' \
'get-fallback-domains:Get the list of domains that go to the fallback resolver' \
'restore-fallback-domains:Restore the list of fallback resolver domains to its default value' \
'get-device-posture:Get the current device posture' \
'get-override-code:Generate admin override code for Teams account (requires admin permissions)' \
'set-proxy-port:Set the listening port for WARP proxy (127.0.0.1\:{port})' \
'is-mode-switch-allowed:Outputs true if Teams users should be able to change connection mode, or false if not' \
'reset-settings:Restore settings to default' \
'get-organization:Get the name of the Teams organization currently in settings' \
'access-reauth:Force refresh authentication with Cloudflare Access' \
'get-support-url:Get the support url for the current Teams organization' \
'get-pause-end:Retrieve the pause end time' \
'get-override-end:Retrieve the admin override end time' \
'disable-connectivity-checks:Disable the runtime connectivity checks' \
'enable-connectivity-checks:Enable the runtime connectivity checks' \
'set-tunnel-mtu:Set the MTU value of the tunnel' \
'force-panic:Force the daemon to panic' \
'dump-excluded-routes:Get split tunnel routing dump. For include-only mode, this shows routes NOT included' \
'get-alternate-network:Get the name of the currently detected alternate network, if any' \
'get-dex-data:Get the most recently uploaded DEX data. Returns the most recent test for each dex metric' \
'start-packet-capture:Start packet capture' \
'stop-packet-capture:Stop packet capture' \
'generate-completions:Generate completions for a given shell and print to stdout' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli commands' commands "$@"
}
(( $+functions[_warp-cli__access-reauth_commands] )) ||
_warp-cli__access-reauth_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli access-reauth commands' commands "$@"
}
(( $+functions[_warp-cli__debug__access-reauth_commands] )) ||
_warp-cli__debug__access-reauth_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug access-reauth commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help__access-reauth_commands] )) ||
_warp-cli__debug__help__access-reauth_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug help access-reauth commands' commands "$@"
}
(( $+functions[_warp-cli__help__access-reauth_commands] )) ||
_warp-cli__help__access-reauth_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help access-reauth commands' commands "$@"
}
(( $+functions[_warp-cli__help__debug__access-reauth_commands] )) ||
_warp-cli__help__debug__access-reauth_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help debug access-reauth commands' commands "$@"
}
(( $+functions[_warp-cli__account_commands] )) ||
_warp-cli__account_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli account commands' commands "$@"
}
(( $+functions[_warp-cli__help__account_commands] )) ||
_warp-cli__help__account_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help account commands' commands "$@"
}
(( $+functions[_warp-cli__dns__fallback__add_commands] )) ||
_warp-cli__dns__fallback__add_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns fallback add commands' commands "$@"
}
(( $+functions[_warp-cli__dns__fallback__help__add_commands] )) ||
_warp-cli__dns__fallback__help__add_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns fallback help add commands' commands "$@"
}
(( $+functions[_warp-cli__dns__help__fallback__add_commands] )) ||
_warp-cli__dns__help__fallback__add_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns help fallback add commands' commands "$@"
}
(( $+functions[_warp-cli__help__dns__fallback__add_commands] )) ||
_warp-cli__help__dns__fallback__add_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help dns fallback add commands' commands "$@"
}
(( $+functions[_warp-cli__help__trusted__ssid__add_commands] )) ||
_warp-cli__help__trusted__ssid__add_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help trusted ssid add commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__host__add_commands] )) ||
_warp-cli__help__tunnel__host__add_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help tunnel host add commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__ip__add_commands] )) ||
_warp-cli__help__tunnel__ip__add_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help tunnel ip add commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__help__ssid__add_commands] )) ||
_warp-cli__trusted__help__ssid__add_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted help ssid add commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__ssid__add_commands] )) ||
_warp-cli__trusted__ssid__add_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted ssid add commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__ssid__help__add_commands] )) ||
_warp-cli__trusted__ssid__help__add_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted ssid help add commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__host__add_commands] )) ||
_warp-cli__tunnel__help__host__add_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel help host add commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__ip__add_commands] )) ||
_warp-cli__tunnel__help__ip__add_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel help ip add commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__host__add_commands] )) ||
_warp-cli__tunnel__host__add_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel host add commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__host__help__add_commands] )) ||
_warp-cli__tunnel__host__help__add_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel host help add commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__ip__add_commands] )) ||
_warp-cli__tunnel__ip__add_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel ip add commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__ip__help__add_commands] )) ||
_warp-cli__tunnel__ip__help__add_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel ip help add commands' commands "$@"
}
(( $+functions[_warp-cli__add-excluded-host_commands] )) ||
_warp-cli__add-excluded-host_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli add-excluded-host commands' commands "$@"
}
(( $+functions[_warp-cli__help__add-excluded-host_commands] )) ||
_warp-cli__help__add-excluded-host_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help add-excluded-host commands' commands "$@"
}
(( $+functions[_warp-cli__add-excluded-route_commands] )) ||
_warp-cli__add-excluded-route_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli add-excluded-route commands' commands "$@"
}
(( $+functions[_warp-cli__help__add-excluded-route_commands] )) ||
_warp-cli__help__add-excluded-route_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help add-excluded-route commands' commands "$@"
}
(( $+functions[_warp-cli__add-fallback-domain_commands] )) ||
_warp-cli__add-fallback-domain_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli add-fallback-domain commands' commands "$@"
}
(( $+functions[_warp-cli__help__add-fallback-domain_commands] )) ||
_warp-cli__help__add-fallback-domain_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help add-fallback-domain commands' commands "$@"
}
(( $+functions[_warp-cli__add-trusted-ssid_commands] )) ||
_warp-cli__add-trusted-ssid_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli add-trusted-ssid commands' commands "$@"
}
(( $+functions[_warp-cli__help__add-trusted-ssid_commands] )) ||
_warp-cli__help__add-trusted-ssid_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help add-trusted-ssid commands' commands "$@"
}
(( $+functions[_warp-cli__help__override__local-network__allow_commands] )) ||
_warp-cli__help__override__local-network__allow_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help override local-network allow commands' commands "$@"
}
(( $+functions[_warp-cli__override__help__local-network__allow_commands] )) ||
_warp-cli__override__help__local-network__allow_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override help local-network allow commands' commands "$@"
}
(( $+functions[_warp-cli__override__local-network__allow_commands] )) ||
_warp-cli__override__local-network__allow_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override local-network allow commands' commands "$@"
}
(( $+functions[_warp-cli__override__local-network__help__allow_commands] )) ||
_warp-cli__override__local-network__help__allow_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override local-network help allow commands' commands "$@"
}
(( $+functions[_warp-cli__debug__alternate-network_commands] )) ||
_warp-cli__debug__alternate-network_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug alternate-network commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help__alternate-network_commands] )) ||
_warp-cli__debug__help__alternate-network_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug help alternate-network commands' commands "$@"
}
(( $+functions[_warp-cli__help__debug__alternate-network_commands] )) ||
_warp-cli__help__debug__alternate-network_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help debug alternate-network commands' commands "$@"
}
(( $+functions[_warp-cli__api_commands] )) ||
_warp-cli__api_commands() {
    local commands; commands=(
'endpoint:' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli api commands' commands "$@"
}
(( $+functions[_warp-cli__help__api_commands] )) ||
_warp-cli__help__api_commands() {
    local commands; commands=(
'endpoint:' \
    )
    _describe -t commands 'warp-cli help api commands' commands "$@"
}
(( $+functions[_warp-cli__clear-custom-endpoint_commands] )) ||
_warp-cli__clear-custom-endpoint_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli clear-custom-endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__help__clear-custom-endpoint_commands] )) ||
_warp-cli__help__clear-custom-endpoint_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help clear-custom-endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__clear-doh-endpoint_commands] )) ||
_warp-cli__clear-doh-endpoint_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli clear-doh-endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__help__clear-doh-endpoint_commands] )) ||
_warp-cli__help__clear-doh-endpoint_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help clear-doh-endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__clear-gateway_commands] )) ||
_warp-cli__clear-gateway_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli clear-gateway commands' commands "$@"
}
(( $+functions[_warp-cli__help__clear-gateway_commands] )) ||
_warp-cli__help__clear-gateway_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help clear-gateway commands' commands "$@"
}
(( $+functions[_warp-cli__clear-warp-override-ip_commands] )) ||
_warp-cli__clear-warp-override-ip_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli clear-warp-override-ip commands' commands "$@"
}
(( $+functions[_warp-cli__help__clear-warp-override-ip_commands] )) ||
_warp-cli__help__clear-warp-override-ip_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help clear-warp-override-ip commands' commands "$@"
}
(( $+functions[_warp-cli__connect_commands] )) ||
_warp-cli__connect_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli connect commands' commands "$@"
}
(( $+functions[_warp-cli__help__connect_commands] )) ||
_warp-cli__help__connect_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help connect commands' commands "$@"
}
(( $+functions[_warp-cli__debug__connectivity-check_commands] )) ||
_warp-cli__debug__connectivity-check_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug connectivity-check commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help__connectivity-check_commands] )) ||
_warp-cli__debug__help__connectivity-check_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug help connectivity-check commands' commands "$@"
}
(( $+functions[_warp-cli__help__debug__connectivity-check_commands] )) ||
_warp-cli__help__debug__connectivity-check_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help debug connectivity-check commands' commands "$@"
}
(( $+functions[_warp-cli__debug_commands] )) ||
_warp-cli__debug_commands() {
    local commands; commands=(
'access-reauth:Force refresh authentication with Cloudflare Access' \
'alternate-network:Get the name of the currently detected alternate network, if any' \
'connectivity-check:Enable or disable connectivity checks' \
'dex:Get the most recently uploaded DEX data. Returns the most recent test for each dex metric' \
'network:Display the current network information' \
'panic:Force a daemon panic' \
'posture:Display the most recent device posture information' \
'pcap:Run a packet capture on the device' \
'task-dump:Get a dump of the currently running async tasks' \
'qlog:Enable qlog logging on the tunnel, if supported by the tunnel protocol' \
'log-filter:Modify the dynamic log filter using env-filter directives' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli debug commands' commands "$@"
}
(( $+functions[_warp-cli__help__debug_commands] )) ||
_warp-cli__help__debug_commands() {
    local commands; commands=(
'access-reauth:Force refresh authentication with Cloudflare Access' \
'alternate-network:Get the name of the currently detected alternate network, if any' \
'connectivity-check:Enable or disable connectivity checks' \
'dex:Get the most recently uploaded DEX data. Returns the most recent test for each dex metric' \
'network:Display the current network information' \
'panic:Force a daemon panic' \
'posture:Display the most recent device posture information' \
'pcap:Run a packet capture on the device' \
'task-dump:Get a dump of the currently running async tasks' \
'qlog:Enable qlog logging on the tunnel, if supported by the tunnel protocol' \
'log-filter:Modify the dynamic log filter using env-filter directives' \
    )
    _describe -t commands 'warp-cli help debug commands' commands "$@"
}
(( $+functions[_warp-cli__delete_commands] )) ||
_warp-cli__delete_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli delete commands' commands "$@"
}
(( $+functions[_warp-cli__help__delete_commands] )) ||
_warp-cli__help__delete_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help delete commands' commands "$@"
}
(( $+functions[_warp-cli__help__registration__delete_commands] )) ||
_warp-cli__help__registration__delete_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help registration delete commands' commands "$@"
}
(( $+functions[_warp-cli__registration__delete_commands] )) ||
_warp-cli__registration__delete_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration delete commands' commands "$@"
}
(( $+functions[_warp-cli__registration__help__delete_commands] )) ||
_warp-cli__registration__help__delete_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration help delete commands' commands "$@"
}
(( $+functions[_warp-cli__devices_commands] )) ||
_warp-cli__devices_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli devices commands' commands "$@"
}
(( $+functions[_warp-cli__help__devices_commands] )) ||
_warp-cli__help__devices_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help devices commands' commands "$@"
}
(( $+functions[_warp-cli__help__registration__devices_commands] )) ||
_warp-cli__help__registration__devices_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help registration devices commands' commands "$@"
}
(( $+functions[_warp-cli__registration__devices_commands] )) ||
_warp-cli__registration__devices_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration devices commands' commands "$@"
}
(( $+functions[_warp-cli__registration__help__devices_commands] )) ||
_warp-cli__registration__help__devices_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration help devices commands' commands "$@"
}
(( $+functions[_warp-cli__debug__dex_commands] )) ||
_warp-cli__debug__dex_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug dex commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help__dex_commands] )) ||
_warp-cli__debug__help__dex_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug help dex commands' commands "$@"
}
(( $+functions[_warp-cli__help__debug__dex_commands] )) ||
_warp-cli__help__debug__dex_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help debug dex commands' commands "$@"
}
(( $+functions[_warp-cli__disable-connectivity-checks_commands] )) ||
_warp-cli__disable-connectivity-checks_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli disable-connectivity-checks commands' commands "$@"
}
(( $+functions[_warp-cli__help__disable-connectivity-checks_commands] )) ||
_warp-cli__help__disable-connectivity-checks_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help disable-connectivity-checks commands' commands "$@"
}
(( $+functions[_warp-cli__disable-dns-log_commands] )) ||
_warp-cli__disable-dns-log_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli disable-dns-log commands' commands "$@"
}
(( $+functions[_warp-cli__help__disable-dns-log_commands] )) ||
_warp-cli__help__disable-dns-log_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help disable-dns-log commands' commands "$@"
}
(( $+functions[_warp-cli__disable-ethernet_commands] )) ||
_warp-cli__disable-ethernet_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli disable-ethernet commands' commands "$@"
}
(( $+functions[_warp-cli__help__disable-ethernet_commands] )) ||
_warp-cli__help__disable-ethernet_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help disable-ethernet commands' commands "$@"
}
(( $+functions[_warp-cli__disable-wifi_commands] )) ||
_warp-cli__disable-wifi_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli disable-wifi commands' commands "$@"
}
(( $+functions[_warp-cli__help__disable-wifi_commands] )) ||
_warp-cli__help__disable-wifi_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help disable-wifi commands' commands "$@"
}
(( $+functions[_warp-cli__disconnect_commands] )) ||
_warp-cli__disconnect_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli disconnect commands' commands "$@"
}
(( $+functions[_warp-cli__help__disconnect_commands] )) ||
_warp-cli__help__disconnect_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help disconnect commands' commands "$@"
}
(( $+functions[_warp-cli__dns_commands] )) ||
_warp-cli__dns_commands() {
    local commands; commands=(
'endpoint:Configure a custom DNS Over HTTPS server endpoint' \
'fallback:Configure fallback domains' \
'families:Configure Families Mode settings (Consumer only)' \
'gateway-id:Force the app to use the specified Gateway ID for DNS queries' \
'log:Enable/Disable DNS logging' \
'stats:Retrieve DNS stats for the current connection' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli dns commands' commands "$@"
}
(( $+functions[_warp-cli__help__dns_commands] )) ||
_warp-cli__help__dns_commands() {
    local commands; commands=(
'endpoint:Configure a custom DNS Over HTTPS server endpoint' \
'fallback:Configure fallback domains' \
'families:Configure Families Mode settings (Consumer only)' \
'gateway-id:Force the app to use the specified Gateway ID for DNS queries' \
'log:Enable/Disable DNS logging' \
'stats:Retrieve DNS stats for the current connection' \
    )
    _describe -t commands 'warp-cli help dns commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__dump_commands] )) ||
_warp-cli__help__tunnel__dump_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help tunnel dump commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__dump_commands] )) ||
_warp-cli__tunnel__dump_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel dump commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__dump_commands] )) ||
_warp-cli__tunnel__help__dump_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel help dump commands' commands "$@"
}
(( $+functions[_warp-cli__dump-excluded-routes_commands] )) ||
_warp-cli__dump-excluded-routes_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dump-excluded-routes commands' commands "$@"
}
(( $+functions[_warp-cli__help__dump-excluded-routes_commands] )) ||
_warp-cli__help__dump-excluded-routes_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help dump-excluded-routes commands' commands "$@"
}
(( $+functions[_warp-cli__enable-connectivity-checks_commands] )) ||
_warp-cli__enable-connectivity-checks_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli enable-connectivity-checks commands' commands "$@"
}
(( $+functions[_warp-cli__help__enable-connectivity-checks_commands] )) ||
_warp-cli__help__enable-connectivity-checks_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help enable-connectivity-checks commands' commands "$@"
}
(( $+functions[_warp-cli__enable-dns-log_commands] )) ||
_warp-cli__enable-dns-log_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli enable-dns-log commands' commands "$@"
}
(( $+functions[_warp-cli__help__enable-dns-log_commands] )) ||
_warp-cli__help__enable-dns-log_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help enable-dns-log commands' commands "$@"
}
(( $+functions[_warp-cli__enable-ethernet_commands] )) ||
_warp-cli__enable-ethernet_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli enable-ethernet commands' commands "$@"
}
(( $+functions[_warp-cli__help__enable-ethernet_commands] )) ||
_warp-cli__help__enable-ethernet_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help enable-ethernet commands' commands "$@"
}
(( $+functions[_warp-cli__enable-wifi_commands] )) ||
_warp-cli__enable-wifi_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli enable-wifi commands' commands "$@"
}
(( $+functions[_warp-cli__help__enable-wifi_commands] )) ||
_warp-cli__help__enable-wifi_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help enable-wifi commands' commands "$@"
}
(( $+functions[_warp-cli__api__endpoint_commands] )) ||
_warp-cli__api__endpoint_commands() {
    local commands; commands=(
'set:Set an override IP to use for the Cloudflare API IP' \
'reset:Remove any configured override IP for the Cloudflare API' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli api endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__api__help__endpoint_commands] )) ||
_warp-cli__api__help__endpoint_commands() {
    local commands; commands=(
'set:Set an override IP to use for the Cloudflare API IP' \
'reset:Remove any configured override IP for the Cloudflare API' \
    )
    _describe -t commands 'warp-cli api help endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__dns__endpoint_commands] )) ||
_warp-cli__dns__endpoint_commands() {
    local commands; commands=(
'set:Set an override IP to use for the Cloudflare API IP' \
'reset:Remove any configured override IP for the Cloudflare API' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli dns endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__dns__help__endpoint_commands] )) ||
_warp-cli__dns__help__endpoint_commands() {
    local commands; commands=(
'set:Set an override IP to use for the Cloudflare API IP' \
'reset:Remove any configured override IP for the Cloudflare API' \
    )
    _describe -t commands 'warp-cli dns help endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__help__api__endpoint_commands] )) ||
_warp-cli__help__api__endpoint_commands() {
    local commands; commands=(
'set:Set an override IP to use for the Cloudflare API IP' \
'reset:Remove any configured override IP for the Cloudflare API' \
    )
    _describe -t commands 'warp-cli help api endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__help__dns__endpoint_commands] )) ||
_warp-cli__help__dns__endpoint_commands() {
    local commands; commands=(
'set:Set an override IP to use for the Cloudflare API IP' \
'reset:Remove any configured override IP for the Cloudflare API' \
    )
    _describe -t commands 'warp-cli help dns endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__endpoint_commands] )) ||
_warp-cli__help__tunnel__endpoint_commands() {
    local commands; commands=(
'set:Set an override' \
'reset:Remove any configured override' \
    )
    _describe -t commands 'warp-cli help tunnel endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__endpoint_commands] )) ||
_warp-cli__tunnel__endpoint_commands() {
    local commands; commands=(
'set:Set an override' \
'reset:Remove any configured override' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli tunnel endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__endpoint_commands] )) ||
_warp-cli__tunnel__help__endpoint_commands() {
    local commands; commands=(
'set:Set an override' \
'reset:Remove any configured override' \
    )
    _describe -t commands 'warp-cli tunnel help endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__help__trusted__ethernet_commands] )) ||
_warp-cli__help__trusted__ethernet_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help trusted ethernet commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__ethernet_commands] )) ||
_warp-cli__trusted__ethernet_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted ethernet commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__help__ethernet_commands] )) ||
_warp-cli__trusted__help__ethernet_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted help ethernet commands' commands "$@"
}
(( $+functions[_warp-cli__exclude-private-ips_commands] )) ||
_warp-cli__exclude-private-ips_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli exclude-private-ips commands' commands "$@"
}
(( $+functions[_warp-cli__help__exclude-private-ips_commands] )) ||
_warp-cli__help__exclude-private-ips_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help exclude-private-ips commands' commands "$@"
}
(( $+functions[_warp-cli__dns__fallback_commands] )) ||
_warp-cli__dns__fallback_commands() {
    local commands; commands=(
'list:' \
'add:' \
'remove:' \
'reset:' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli dns fallback commands' commands "$@"
}
(( $+functions[_warp-cli__dns__help__fallback_commands] )) ||
_warp-cli__dns__help__fallback_commands() {
    local commands; commands=(
'list:' \
'add:' \
'remove:' \
'reset:' \
    )
    _describe -t commands 'warp-cli dns help fallback commands' commands "$@"
}
(( $+functions[_warp-cli__help__dns__fallback_commands] )) ||
_warp-cli__help__dns__fallback_commands() {
    local commands; commands=(
'list:' \
'add:' \
'remove:' \
'reset:' \
    )
    _describe -t commands 'warp-cli help dns fallback commands' commands "$@"
}
(( $+functions[_warp-cli__dns__families_commands] )) ||
_warp-cli__dns__families_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns families commands' commands "$@"
}
(( $+functions[_warp-cli__dns__help__families_commands] )) ||
_warp-cli__dns__help__families_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns help families commands' commands "$@"
}
(( $+functions[_warp-cli__help__dns__families_commands] )) ||
_warp-cli__help__dns__families_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help dns families commands' commands "$@"
}
(( $+functions[_warp-cli__force-panic_commands] )) ||
_warp-cli__force-panic_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli force-panic commands' commands "$@"
}
(( $+functions[_warp-cli__help__force-panic_commands] )) ||
_warp-cli__help__force-panic_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help force-panic commands' commands "$@"
}
(( $+functions[_warp-cli__dns__gateway-id_commands] )) ||
_warp-cli__dns__gateway-id_commands() {
    local commands; commands=(
'set:Set an override' \
'reset:Remove any configured override' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli dns gateway-id commands' commands "$@"
}
(( $+functions[_warp-cli__dns__help__gateway-id_commands] )) ||
_warp-cli__dns__help__gateway-id_commands() {
    local commands; commands=(
'set:Set an override' \
'reset:Remove any configured override' \
    )
    _describe -t commands 'warp-cli dns help gateway-id commands' commands "$@"
}
(( $+functions[_warp-cli__help__dns__gateway-id_commands] )) ||
_warp-cli__help__dns__gateway-id_commands() {
    local commands; commands=(
'set:Set an override' \
'reset:Remove any configured override' \
    )
    _describe -t commands 'warp-cli help dns gateway-id commands' commands "$@"
}
(( $+functions[_warp-cli__help__override__generate_commands] )) ||
_warp-cli__help__override__generate_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help override generate commands' commands "$@"
}
(( $+functions[_warp-cli__override__generate_commands] )) ||
_warp-cli__override__generate_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override generate commands' commands "$@"
}
(( $+functions[_warp-cli__override__help__generate_commands] )) ||
_warp-cli__override__help__generate_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override help generate commands' commands "$@"
}
(( $+functions[_warp-cli__generate-completions_commands] )) ||
_warp-cli__generate-completions_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli generate-completions commands' commands "$@"
}
(( $+functions[_warp-cli__help__generate-completions_commands] )) ||
_warp-cli__help__generate-completions_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help generate-completions commands' commands "$@"
}
(( $+functions[_warp-cli__get-alternate-network_commands] )) ||
_warp-cli__get-alternate-network_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli get-alternate-network commands' commands "$@"
}
(( $+functions[_warp-cli__help__get-alternate-network_commands] )) ||
_warp-cli__help__get-alternate-network_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help get-alternate-network commands' commands "$@"
}
(( $+functions[_warp-cli__help__mdm__get-configs_commands] )) ||
_warp-cli__help__mdm__get-configs_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help mdm get-configs commands' commands "$@"
}
(( $+functions[_warp-cli__mdm__get-configs_commands] )) ||
_warp-cli__mdm__get-configs_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli mdm get-configs commands' commands "$@"
}
(( $+functions[_warp-cli__mdm__help__get-configs_commands] )) ||
_warp-cli__mdm__help__get-configs_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli mdm help get-configs commands' commands "$@"
}
(( $+functions[_warp-cli__get-device-posture_commands] )) ||
_warp-cli__get-device-posture_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli get-device-posture commands' commands "$@"
}
(( $+functions[_warp-cli__help__get-device-posture_commands] )) ||
_warp-cli__help__get-device-posture_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help get-device-posture commands' commands "$@"
}
(( $+functions[_warp-cli__get-dex-data_commands] )) ||
_warp-cli__get-dex-data_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli get-dex-data commands' commands "$@"
}
(( $+functions[_warp-cli__help__get-dex-data_commands] )) ||
_warp-cli__help__get-dex-data_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help get-dex-data commands' commands "$@"
}
(( $+functions[_warp-cli__get-excluded-hosts_commands] )) ||
_warp-cli__get-excluded-hosts_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli get-excluded-hosts commands' commands "$@"
}
(( $+functions[_warp-cli__help__get-excluded-hosts_commands] )) ||
_warp-cli__help__get-excluded-hosts_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help get-excluded-hosts commands' commands "$@"
}
(( $+functions[_warp-cli__get-excluded-routes_commands] )) ||
_warp-cli__get-excluded-routes_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli get-excluded-routes commands' commands "$@"
}
(( $+functions[_warp-cli__help__get-excluded-routes_commands] )) ||
_warp-cli__help__get-excluded-routes_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help get-excluded-routes commands' commands "$@"
}
(( $+functions[_warp-cli__get-fallback-domains_commands] )) ||
_warp-cli__get-fallback-domains_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli get-fallback-domains commands' commands "$@"
}
(( $+functions[_warp-cli__help__get-fallback-domains_commands] )) ||
_warp-cli__help__get-fallback-domains_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help get-fallback-domains commands' commands "$@"
}
(( $+functions[_warp-cli__get-included-hosts_commands] )) ||
_warp-cli__get-included-hosts_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli get-included-hosts commands' commands "$@"
}
(( $+functions[_warp-cli__help__get-included-hosts_commands] )) ||
_warp-cli__help__get-included-hosts_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help get-included-hosts commands' commands "$@"
}
(( $+functions[_warp-cli__get-included-routes_commands] )) ||
_warp-cli__get-included-routes_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli get-included-routes commands' commands "$@"
}
(( $+functions[_warp-cli__help__get-included-routes_commands] )) ||
_warp-cli__help__get-included-routes_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help get-included-routes commands' commands "$@"
}
(( $+functions[_warp-cli__get-organization_commands] )) ||
_warp-cli__get-organization_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli get-organization commands' commands "$@"
}
(( $+functions[_warp-cli__help__get-organization_commands] )) ||
_warp-cli__help__get-organization_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help get-organization commands' commands "$@"
}
(( $+functions[_warp-cli__get-override-code_commands] )) ||
_warp-cli__get-override-code_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli get-override-code commands' commands "$@"
}
(( $+functions[_warp-cli__help__get-override-code_commands] )) ||
_warp-cli__help__get-override-code_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help get-override-code commands' commands "$@"
}
(( $+functions[_warp-cli__get-override-end_commands] )) ||
_warp-cli__get-override-end_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli get-override-end commands' commands "$@"
}
(( $+functions[_warp-cli__help__get-override-end_commands] )) ||
_warp-cli__help__get-override-end_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help get-override-end commands' commands "$@"
}
(( $+functions[_warp-cli__get-pause-end_commands] )) ||
_warp-cli__get-pause-end_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli get-pause-end commands' commands "$@"
}
(( $+functions[_warp-cli__help__get-pause-end_commands] )) ||
_warp-cli__help__get-pause-end_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help get-pause-end commands' commands "$@"
}
(( $+functions[_warp-cli__get-support-url_commands] )) ||
_warp-cli__get-support-url_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli get-support-url commands' commands "$@"
}
(( $+functions[_warp-cli__help__get-support-url_commands] )) ||
_warp-cli__help__get-support-url_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help get-support-url commands' commands "$@"
}
(( $+functions[_warp-cli__get-virtual-networks_commands] )) ||
_warp-cli__get-virtual-networks_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli get-virtual-networks commands' commands "$@"
}
(( $+functions[_warp-cli__help__get-virtual-networks_commands] )) ||
_warp-cli__help__get-virtual-networks_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help get-virtual-networks commands' commands "$@"
}
(( $+functions[_warp-cli__api__endpoint__help_commands] )) ||
_warp-cli__api__endpoint__help_commands() {
    local commands; commands=(
'set:Set an override IP to use for the Cloudflare API IP' \
'reset:Remove any configured override IP for the Cloudflare API' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli api endpoint help commands' commands "$@"
}
(( $+functions[_warp-cli__api__endpoint__help__help_commands] )) ||
_warp-cli__api__endpoint__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli api endpoint help help commands' commands "$@"
}
(( $+functions[_warp-cli__api__help_commands] )) ||
_warp-cli__api__help_commands() {
    local commands; commands=(
'endpoint:' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli api help commands' commands "$@"
}
(( $+functions[_warp-cli__api__help__help_commands] )) ||
_warp-cli__api__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli api help help commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help_commands] )) ||
_warp-cli__debug__help_commands() {
    local commands; commands=(
'access-reauth:Force refresh authentication with Cloudflare Access' \
'alternate-network:Get the name of the currently detected alternate network, if any' \
'connectivity-check:Enable or disable connectivity checks' \
'dex:Get the most recently uploaded DEX data. Returns the most recent test for each dex metric' \
'network:Display the current network information' \
'panic:Force a daemon panic' \
'posture:Display the most recent device posture information' \
'pcap:Run a packet capture on the device' \
'task-dump:Get a dump of the currently running async tasks' \
'qlog:Enable qlog logging on the tunnel, if supported by the tunnel protocol' \
'log-filter:Modify the dynamic log filter using env-filter directives' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli debug help commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help__help_commands] )) ||
_warp-cli__debug__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug help help commands' commands "$@"
}
(( $+functions[_warp-cli__debug__log-filter__help_commands] )) ||
_warp-cli__debug__log-filter__help_commands() {
    local commands; commands=(
'set:Set the dynamic log filter' \
'reset:Reset the dynamic log filter' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli debug log-filter help commands' commands "$@"
}
(( $+functions[_warp-cli__debug__log-filter__help__help_commands] )) ||
_warp-cli__debug__log-filter__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug log-filter help help commands' commands "$@"
}
(( $+functions[_warp-cli__debug__pcap__help_commands] )) ||
_warp-cli__debug__pcap__help_commands() {
    local commands; commands=(
'start:Start packet capture' \
'stop:Stop packet capture' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli debug pcap help commands' commands "$@"
}
(( $+functions[_warp-cli__debug__pcap__help__help_commands] )) ||
_warp-cli__debug__pcap__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug pcap help help commands' commands "$@"
}
(( $+functions[_warp-cli__dns__endpoint__help_commands] )) ||
_warp-cli__dns__endpoint__help_commands() {
    local commands; commands=(
'set:Set an override IP to use for the Cloudflare API IP' \
'reset:Remove any configured override IP for the Cloudflare API' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli dns endpoint help commands' commands "$@"
}
(( $+functions[_warp-cli__dns__endpoint__help__help_commands] )) ||
_warp-cli__dns__endpoint__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns endpoint help help commands' commands "$@"
}
(( $+functions[_warp-cli__dns__fallback__help_commands] )) ||
_warp-cli__dns__fallback__help_commands() {
    local commands; commands=(
'list:' \
'add:' \
'remove:' \
'reset:' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli dns fallback help commands' commands "$@"
}
(( $+functions[_warp-cli__dns__fallback__help__help_commands] )) ||
_warp-cli__dns__fallback__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns fallback help help commands' commands "$@"
}
(( $+functions[_warp-cli__dns__gateway-id__help_commands] )) ||
_warp-cli__dns__gateway-id__help_commands() {
    local commands; commands=(
'set:Set an override' \
'reset:Remove any configured override' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli dns gateway-id help commands' commands "$@"
}
(( $+functions[_warp-cli__dns__gateway-id__help__help_commands] )) ||
_warp-cli__dns__gateway-id__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns gateway-id help help commands' commands "$@"
}
(( $+functions[_warp-cli__dns__help_commands] )) ||
_warp-cli__dns__help_commands() {
    local commands; commands=(
'endpoint:Configure a custom DNS Over HTTPS server endpoint' \
'fallback:Configure fallback domains' \
'families:Configure Families Mode settings (Consumer only)' \
'gateway-id:Force the app to use the specified Gateway ID for DNS queries' \
'log:Enable/Disable DNS logging' \
'stats:Retrieve DNS stats for the current connection' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli dns help commands' commands "$@"
}
(( $+functions[_warp-cli__dns__help__help_commands] )) ||
_warp-cli__dns__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns help help commands' commands "$@"
}
(( $+functions[_warp-cli__help_commands] )) ||
_warp-cli__help_commands() {
    local commands; commands=(
'api:Allow overriding Cloudflare API address' \
'connect:Maintain a connection whenever possible' \
'debug:Debugging commands' \
'disconnect:Disconnect the client' \
'dns:Configure DNS settings' \
'mdm:MDM configs' \
'mode:Set the client'\''s general operating mode' \
'override:Allow temporary overrides of administrative settings' \
'proxy:Configure proxy mode settings' \
'registration:Registration settings' \
'settings:Show or alter general application settings' \
'status:Return the current connection status' \
'trusted:Configure trusted networks where the client will be automatically disabled (Consumer only)' \
'tunnel:Configure tunnel settings' \
'vnet:Get or specify connected virtual network' \
'register:Register with the WARP API, replacing any existing registration (Must be run before first connection!)' \
'teams-enroll:Enroll with Cloudflare for Teams' \
'teams-enroll-token:' \
'register-token-callback:Registers the browser token callback without actually registering' \
'delete:Delete current registration' \
'rotate-keys:Generate a new key-pair, keeping the current registration' \
'warp-stats:Retrieve the stats for the current WARP connection' \
'warp-dns-stats:Retrieve the DNS stats for the current WARP connection' \
'disable-wifi:Automatically disable WARP on Wi-Fi networks (disabled for Zero Trust customers)' \
'enable-wifi:Allow WARP on Wi-Fi networks (disabled for Zero Trust customers)' \
'disable-ethernet:Automatically disable WARP on ethernet networks (disabled for Zero Trust customers)' \
'enable-ethernet:Allow WARP on ethernet networks (disabled for Zero Trust customers)' \
'add-trusted-ssid:Add a trusted Wi-Fi network for which WARP will be automatically disconnected' \
'remove-trusted-ssid:Remove a trusted Wi-Fi network' \
'exclude-private-ips:Exclude private IP ranges from tunnel' \
'enable-dns-log:Enable DNS logging (Use with the -l option)' \
'disable-dns-log:Disable DNS logging' \
'account:Display the account associated with the current registration' \
'devices:Display the list of devices associated with the current registration' \
'network:Display the current network information' \
'get-virtual-networks:List the available virtual networks' \
'set-virtual-network:Set the currently connected virtual network via the id from get-virtual-networks' \
'set-mode:Set the mode' \
'set-families-mode:Set the families mode' \
'set-license:Attach the current registration to a different account using a license key' \
'set-gateway:Force the app to use the specified Gateway ID for DNS queries' \
'clear-gateway:Clear the Gateway ID' \
'set-custom-endpoint:Force the client to connect to the specified IP\:PORT endpoint (Zero Trust customers must run this command as a privileged user)' \
'clear-custom-endpoint:Remove the custom endpoint setting' \
'set-warp-override-ip:Add an IP to use instead of the default Cloudflare API IP' \
'clear-warp-override-ip:Remove all override IPs for the Cloudflare API' \
'add-excluded-route:Add an excluded IP' \
'remove-excluded-route:Remove an excluded IP' \
'get-excluded-routes:Get the list of excluded routes' \
'get-included-routes:Get the list of included routes' \
'get-excluded-hosts:Get the list of excluded hosts' \
'get-included-hosts:Get the list of included hosts' \
'add-excluded-host:Add an excluded host' \
'remove-excluded-host:Remove an excluded host' \
'set-doh-endpoint:Set a custom DNS Over HTTPS server endpoint. Must be a valid IP address, not hostname' \
'clear-doh-endpoint:Remove the custom endpoint setting' \
'add-fallback-domain:Add a domain that should be resolved with the fallback resolver instead of WARP'\''s' \
'remove-fallback-domain:Stop a domain from being resolved with the fallback resolver' \
'get-fallback-domains:Get the list of domains that go to the fallback resolver' \
'restore-fallback-domains:Restore the list of fallback resolver domains to its default value' \
'get-device-posture:Get the current device posture' \
'get-override-code:Generate admin override code for Teams account (requires admin permissions)' \
'set-proxy-port:Set the listening port for WARP proxy (127.0.0.1\:{port})' \
'is-mode-switch-allowed:Outputs true if Teams users should be able to change connection mode, or false if not' \
'reset-settings:Restore settings to default' \
'get-organization:Get the name of the Teams organization currently in settings' \
'access-reauth:Force refresh authentication with Cloudflare Access' \
'get-support-url:Get the support url for the current Teams organization' \
'get-pause-end:Retrieve the pause end time' \
'get-override-end:Retrieve the admin override end time' \
'disable-connectivity-checks:Disable the runtime connectivity checks' \
'enable-connectivity-checks:Enable the runtime connectivity checks' \
'set-tunnel-mtu:Set the MTU value of the tunnel' \
'force-panic:Force the daemon to panic' \
'dump-excluded-routes:Get split tunnel routing dump. For include-only mode, this shows routes NOT included' \
'get-alternate-network:Get the name of the currently detected alternate network, if any' \
'get-dex-data:Get the most recently uploaded DEX data. Returns the most recent test for each dex metric' \
'start-packet-capture:Start packet capture' \
'stop-packet-capture:Stop packet capture' \
'generate-completions:Generate completions for a given shell and print to stdout' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli help commands' commands "$@"
}
(( $+functions[_warp-cli__help__help_commands] )) ||
_warp-cli__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help help commands' commands "$@"
}
(( $+functions[_warp-cli__mdm__help_commands] )) ||
_warp-cli__mdm__help_commands() {
    local commands; commands=(
'get-configs:Show information about current MDM configurations' \
'set-config:Apply config from configs found in MDM file' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli mdm help commands' commands "$@"
}
(( $+functions[_warp-cli__mdm__help__help_commands] )) ||
_warp-cli__mdm__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli mdm help help commands' commands "$@"
}
(( $+functions[_warp-cli__override__help_commands] )) ||
_warp-cli__override__help_commands() {
    local commands; commands=(
'show:Return information about any currently applied administrative override' \
'unlock:Temporarily override policies that require the client to stay enabled' \
'generate:Generate admin override code for Teams account (requires admin permissions)' \
'local-network:Override settings to access the local area network' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli override help commands' commands "$@"
}
(( $+functions[_warp-cli__override__help__help_commands] )) ||
_warp-cli__override__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override help help commands' commands "$@"
}
(( $+functions[_warp-cli__override__local-network__help_commands] )) ||
_warp-cli__override__local-network__help_commands() {
    local commands; commands=(
'allow:Allow access to the local network, if permitted by settings' \
'show:Return information about any currently applied local network access' \
'stop:Stop any current local network access' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli override local-network help commands' commands "$@"
}
(( $+functions[_warp-cli__override__local-network__help__help_commands] )) ||
_warp-cli__override__local-network__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override local-network help help commands' commands "$@"
}
(( $+functions[_warp-cli__proxy__help_commands] )) ||
_warp-cli__proxy__help_commands() {
    local commands; commands=(
'port:Override the listening port for proxy mode (127.0.0.1\:{port})' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli proxy help commands' commands "$@"
}
(( $+functions[_warp-cli__proxy__help__help_commands] )) ||
_warp-cli__proxy__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli proxy help help commands' commands "$@"
}
(( $+functions[_warp-cli__registration__help_commands] )) ||
_warp-cli__registration__help_commands() {
    local commands; commands=(
'show:Show information about the current registration' \
'new:Register this client, replacing any existing registration (Must be run before first connection!)' \
'delete:Delete current registration' \
'organization:Get the name of the current Teams organization' \
'devices:Display the list of devices associated with the current registration' \
'license:Attach the current registration to a different account using a license key' \
'token:Used internally by callbacks to return tokens as part of registration' \
'initialize-token-callback:Registers the browser token callback without actually registering' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli registration help commands' commands "$@"
}
(( $+functions[_warp-cli__registration__help__help_commands] )) ||
_warp-cli__registration__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration help help commands' commands "$@"
}
(( $+functions[_warp-cli__settings__help_commands] )) ||
_warp-cli__settings__help_commands() {
    local commands; commands=(
'list:Retrieve the current application settings' \
'reset:Restore settings to default' \
'support-url:Get the support url for the current Teams organization' \
'mode-switch-allowed:Outputs true if Teams users should be able to change connection mode, or false if not' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli settings help commands' commands "$@"
}
(( $+functions[_warp-cli__settings__help__help_commands] )) ||
_warp-cli__settings__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli settings help help commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__help_commands] )) ||
_warp-cli__trusted__help_commands() {
    local commands; commands=(
'ssid:Configure trusted Wi-Fi networks for which the client will be automatically disconnected' \
'ethernet:Automatically disconnect on all ethernet networks (disabled for Zero Trust customers)' \
'wifi:Automatically disconnect on all Wi-Fi networks (disabled for Zero Trust customers)' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli trusted help commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__help__help_commands] )) ||
_warp-cli__trusted__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted help help commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__ssid__help_commands] )) ||
_warp-cli__trusted__ssid__help_commands() {
    local commands; commands=(
'list:' \
'add:' \
'remove:' \
'reset:' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli trusted ssid help commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__ssid__help__help_commands] )) ||
_warp-cli__trusted__ssid__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted ssid help help commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__endpoint__help_commands] )) ||
_warp-cli__tunnel__endpoint__help_commands() {
    local commands; commands=(
'set:Set an override' \
'reset:Remove any configured override' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli tunnel endpoint help commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__endpoint__help__help_commands] )) ||
_warp-cli__tunnel__endpoint__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel endpoint help help commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help_commands] )) ||
_warp-cli__tunnel__help_commands() {
    local commands; commands=(
'dump:Get split tunnel routing dump. For include-only mode, this shows routes NOT included' \
'host:Configure split tunnel hosts' \
'ip:Configure split tunnel IP ranges' \
'stats:Retrieve the stats for the current tunnel connection' \
'rotate-keys:Generate a new key-pair, keeping the current registration' \
'endpoint:Force the client to connect to the specified IP\:PORT endpoint (Zero Trust customers must run this command as a privileged user)' \
'mtu:Set the MTU value of the tunnel' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli tunnel help commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__help_commands] )) ||
_warp-cli__tunnel__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel help help commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__host__help_commands] )) ||
_warp-cli__tunnel__host__help_commands() {
    local commands; commands=(
'list:' \
'add:' \
'remove:' \
'reset:' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli tunnel host help commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__host__help__help_commands] )) ||
_warp-cli__tunnel__host__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel host help help commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__ip__help_commands] )) ||
_warp-cli__tunnel__ip__help_commands() {
    local commands; commands=(
'list:' \
'add:' \
'remove:' \
'reset:' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli tunnel ip help commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__ip__help__help_commands] )) ||
_warp-cli__tunnel__ip__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel ip help help commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__host_commands] )) ||
_warp-cli__help__tunnel__host_commands() {
    local commands; commands=(
'list:' \
'add:' \
'remove:' \
'reset:' \
    )
    _describe -t commands 'warp-cli help tunnel host commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__host_commands] )) ||
_warp-cli__tunnel__help__host_commands() {
    local commands; commands=(
'list:' \
'add:' \
'remove:' \
'reset:' \
    )
    _describe -t commands 'warp-cli tunnel help host commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__host_commands] )) ||
_warp-cli__tunnel__host_commands() {
    local commands; commands=(
'list:' \
'add:' \
'remove:' \
'reset:' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli tunnel host commands' commands "$@"
}
(( $+functions[_warp-cli__help__registration__initialize-token-callback_commands] )) ||
_warp-cli__help__registration__initialize-token-callback_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help registration initialize-token-callback commands' commands "$@"
}
(( $+functions[_warp-cli__registration__help__initialize-token-callback_commands] )) ||
_warp-cli__registration__help__initialize-token-callback_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration help initialize-token-callback commands' commands "$@"
}
(( $+functions[_warp-cli__registration__initialize-token-callback_commands] )) ||
_warp-cli__registration__initialize-token-callback_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration initialize-token-callback commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__ip_commands] )) ||
_warp-cli__help__tunnel__ip_commands() {
    local commands; commands=(
'list:' \
'add:' \
'remove:' \
'reset:' \
    )
    _describe -t commands 'warp-cli help tunnel ip commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__ip_commands] )) ||
_warp-cli__tunnel__help__ip_commands() {
    local commands; commands=(
'list:' \
'add:' \
'remove:' \
'reset:' \
    )
    _describe -t commands 'warp-cli tunnel help ip commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__ip_commands] )) ||
_warp-cli__tunnel__ip_commands() {
    local commands; commands=(
'list:' \
'add:' \
'remove:' \
'reset:' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli tunnel ip commands' commands "$@"
}
(( $+functions[_warp-cli__help__is-mode-switch-allowed_commands] )) ||
_warp-cli__help__is-mode-switch-allowed_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help is-mode-switch-allowed commands' commands "$@"
}
(( $+functions[_warp-cli__is-mode-switch-allowed_commands] )) ||
_warp-cli__is-mode-switch-allowed_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli is-mode-switch-allowed commands' commands "$@"
}
(( $+functions[_warp-cli__help__registration__license_commands] )) ||
_warp-cli__help__registration__license_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help registration license commands' commands "$@"
}
(( $+functions[_warp-cli__registration__help__license_commands] )) ||
_warp-cli__registration__help__license_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration help license commands' commands "$@"
}
(( $+functions[_warp-cli__registration__license_commands] )) ||
_warp-cli__registration__license_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration license commands' commands "$@"
}
(( $+functions[_warp-cli__dns__fallback__help__list_commands] )) ||
_warp-cli__dns__fallback__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns fallback help list commands' commands "$@"
}
(( $+functions[_warp-cli__dns__fallback__list_commands] )) ||
_warp-cli__dns__fallback__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns fallback list commands' commands "$@"
}
(( $+functions[_warp-cli__dns__help__fallback__list_commands] )) ||
_warp-cli__dns__help__fallback__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns help fallback list commands' commands "$@"
}
(( $+functions[_warp-cli__help__dns__fallback__list_commands] )) ||
_warp-cli__help__dns__fallback__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help dns fallback list commands' commands "$@"
}
(( $+functions[_warp-cli__help__settings__list_commands] )) ||
_warp-cli__help__settings__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help settings list commands' commands "$@"
}
(( $+functions[_warp-cli__help__trusted__ssid__list_commands] )) ||
_warp-cli__help__trusted__ssid__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help trusted ssid list commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__host__list_commands] )) ||
_warp-cli__help__tunnel__host__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help tunnel host list commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__ip__list_commands] )) ||
_warp-cli__help__tunnel__ip__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help tunnel ip list commands' commands "$@"
}
(( $+functions[_warp-cli__settings__help__list_commands] )) ||
_warp-cli__settings__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli settings help list commands' commands "$@"
}
(( $+functions[_warp-cli__settings__list_commands] )) ||
_warp-cli__settings__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli settings list commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__help__ssid__list_commands] )) ||
_warp-cli__trusted__help__ssid__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted help ssid list commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__ssid__help__list_commands] )) ||
_warp-cli__trusted__ssid__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted ssid help list commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__ssid__list_commands] )) ||
_warp-cli__trusted__ssid__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted ssid list commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__host__list_commands] )) ||
_warp-cli__tunnel__help__host__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel help host list commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__ip__list_commands] )) ||
_warp-cli__tunnel__help__ip__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel help ip list commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__host__help__list_commands] )) ||
_warp-cli__tunnel__host__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel host help list commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__host__list_commands] )) ||
_warp-cli__tunnel__host__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel host list commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__ip__help__list_commands] )) ||
_warp-cli__tunnel__ip__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel ip help list commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__ip__list_commands] )) ||
_warp-cli__tunnel__ip__list_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel ip list commands' commands "$@"
}
(( $+functions[_warp-cli__help__override__local-network_commands] )) ||
_warp-cli__help__override__local-network_commands() {
    local commands; commands=(
'allow:Allow access to the local network, if permitted by settings' \
'show:Return information about any currently applied local network access' \
'stop:Stop any current local network access' \
    )
    _describe -t commands 'warp-cli help override local-network commands' commands "$@"
}
(( $+functions[_warp-cli__override__help__local-network_commands] )) ||
_warp-cli__override__help__local-network_commands() {
    local commands; commands=(
'allow:Allow access to the local network, if permitted by settings' \
'show:Return information about any currently applied local network access' \
'stop:Stop any current local network access' \
    )
    _describe -t commands 'warp-cli override help local-network commands' commands "$@"
}
(( $+functions[_warp-cli__override__local-network_commands] )) ||
_warp-cli__override__local-network_commands() {
    local commands; commands=(
'allow:Allow access to the local network, if permitted by settings' \
'show:Return information about any currently applied local network access' \
'stop:Stop any current local network access' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli override local-network commands' commands "$@"
}
(( $+functions[_warp-cli__dns__help__log_commands] )) ||
_warp-cli__dns__help__log_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns help log commands' commands "$@"
}
(( $+functions[_warp-cli__dns__log_commands] )) ||
_warp-cli__dns__log_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns log commands' commands "$@"
}
(( $+functions[_warp-cli__help__dns__log_commands] )) ||
_warp-cli__help__dns__log_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help dns log commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help__log-filter_commands] )) ||
_warp-cli__debug__help__log-filter_commands() {
    local commands; commands=(
'set:Set the dynamic log filter' \
'reset:Reset the dynamic log filter' \
    )
    _describe -t commands 'warp-cli debug help log-filter commands' commands "$@"
}
(( $+functions[_warp-cli__debug__log-filter_commands] )) ||
_warp-cli__debug__log-filter_commands() {
    local commands; commands=(
'set:Set the dynamic log filter' \
'reset:Reset the dynamic log filter' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli debug log-filter commands' commands "$@"
}
(( $+functions[_warp-cli__help__debug__log-filter_commands] )) ||
_warp-cli__help__debug__log-filter_commands() {
    local commands; commands=(
'set:Set the dynamic log filter' \
'reset:Reset the dynamic log filter' \
    )
    _describe -t commands 'warp-cli help debug log-filter commands' commands "$@"
}
(( $+functions[_warp-cli__help__mdm_commands] )) ||
_warp-cli__help__mdm_commands() {
    local commands; commands=(
'get-configs:Show information about current MDM configurations' \
'set-config:Apply config from configs found in MDM file' \
    )
    _describe -t commands 'warp-cli help mdm commands' commands "$@"
}
(( $+functions[_warp-cli__mdm_commands] )) ||
_warp-cli__mdm_commands() {
    local commands; commands=(
'get-configs:Show information about current MDM configurations' \
'set-config:Apply config from configs found in MDM file' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli mdm commands' commands "$@"
}
(( $+functions[_warp-cli__help__mode_commands] )) ||
_warp-cli__help__mode_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help mode commands' commands "$@"
}
(( $+functions[_warp-cli__mode_commands] )) ||
_warp-cli__mode_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli mode commands' commands "$@"
}
(( $+functions[_warp-cli__help__settings__mode-switch-allowed_commands] )) ||
_warp-cli__help__settings__mode-switch-allowed_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help settings mode-switch-allowed commands' commands "$@"
}
(( $+functions[_warp-cli__settings__help__mode-switch-allowed_commands] )) ||
_warp-cli__settings__help__mode-switch-allowed_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli settings help mode-switch-allowed commands' commands "$@"
}
(( $+functions[_warp-cli__settings__mode-switch-allowed_commands] )) ||
_warp-cli__settings__mode-switch-allowed_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli settings mode-switch-allowed commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__mtu_commands] )) ||
_warp-cli__help__tunnel__mtu_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help tunnel mtu commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__mtu_commands] )) ||
_warp-cli__tunnel__help__mtu_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel help mtu commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__mtu_commands] )) ||
_warp-cli__tunnel__mtu_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel mtu commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help__network_commands] )) ||
_warp-cli__debug__help__network_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug help network commands' commands "$@"
}
(( $+functions[_warp-cli__debug__network_commands] )) ||
_warp-cli__debug__network_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug network commands' commands "$@"
}
(( $+functions[_warp-cli__help__debug__network_commands] )) ||
_warp-cli__help__debug__network_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help debug network commands' commands "$@"
}
(( $+functions[_warp-cli__help__network_commands] )) ||
_warp-cli__help__network_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help network commands' commands "$@"
}
(( $+functions[_warp-cli__network_commands] )) ||
_warp-cli__network_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli network commands' commands "$@"
}
(( $+functions[_warp-cli__help__registration__new_commands] )) ||
_warp-cli__help__registration__new_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help registration new commands' commands "$@"
}
(( $+functions[_warp-cli__registration__help__new_commands] )) ||
_warp-cli__registration__help__new_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration help new commands' commands "$@"
}
(( $+functions[_warp-cli__registration__new_commands] )) ||
_warp-cli__registration__new_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration new commands' commands "$@"
}
(( $+functions[_warp-cli__help__registration__organization_commands] )) ||
_warp-cli__help__registration__organization_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help registration organization commands' commands "$@"
}
(( $+functions[_warp-cli__registration__help__organization_commands] )) ||
_warp-cli__registration__help__organization_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration help organization commands' commands "$@"
}
(( $+functions[_warp-cli__registration__organization_commands] )) ||
_warp-cli__registration__organization_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration organization commands' commands "$@"
}
(( $+functions[_warp-cli__help__override_commands] )) ||
_warp-cli__help__override_commands() {
    local commands; commands=(
'show:Return information about any currently applied administrative override' \
'unlock:Temporarily override policies that require the client to stay enabled' \
'generate:Generate admin override code for Teams account (requires admin permissions)' \
'local-network:Override settings to access the local area network' \
    )
    _describe -t commands 'warp-cli help override commands' commands "$@"
}
(( $+functions[_warp-cli__override_commands] )) ||
_warp-cli__override_commands() {
    local commands; commands=(
'show:Return information about any currently applied administrative override' \
'unlock:Temporarily override policies that require the client to stay enabled' \
'generate:Generate admin override code for Teams account (requires admin permissions)' \
'local-network:Override settings to access the local area network' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli override commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help__panic_commands] )) ||
_warp-cli__debug__help__panic_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug help panic commands' commands "$@"
}
(( $+functions[_warp-cli__debug__panic_commands] )) ||
_warp-cli__debug__panic_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug panic commands' commands "$@"
}
(( $+functions[_warp-cli__help__debug__panic_commands] )) ||
_warp-cli__help__debug__panic_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help debug panic commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help__pcap_commands] )) ||
_warp-cli__debug__help__pcap_commands() {
    local commands; commands=(
'start:Start packet capture' \
'stop:Stop packet capture' \
    )
    _describe -t commands 'warp-cli debug help pcap commands' commands "$@"
}
(( $+functions[_warp-cli__debug__pcap_commands] )) ||
_warp-cli__debug__pcap_commands() {
    local commands; commands=(
'start:Start packet capture' \
'stop:Stop packet capture' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli debug pcap commands' commands "$@"
}
(( $+functions[_warp-cli__help__debug__pcap_commands] )) ||
_warp-cli__help__debug__pcap_commands() {
    local commands; commands=(
'start:Start packet capture' \
'stop:Stop packet capture' \
    )
    _describe -t commands 'warp-cli help debug pcap commands' commands "$@"
}
(( $+functions[_warp-cli__help__proxy__port_commands] )) ||
_warp-cli__help__proxy__port_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help proxy port commands' commands "$@"
}
(( $+functions[_warp-cli__proxy__help__port_commands] )) ||
_warp-cli__proxy__help__port_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli proxy help port commands' commands "$@"
}
(( $+functions[_warp-cli__proxy__port_commands] )) ||
_warp-cli__proxy__port_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli proxy port commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help__posture_commands] )) ||
_warp-cli__debug__help__posture_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug help posture commands' commands "$@"
}
(( $+functions[_warp-cli__debug__posture_commands] )) ||
_warp-cli__debug__posture_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug posture commands' commands "$@"
}
(( $+functions[_warp-cli__help__debug__posture_commands] )) ||
_warp-cli__help__debug__posture_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help debug posture commands' commands "$@"
}
(( $+functions[_warp-cli__help__proxy_commands] )) ||
_warp-cli__help__proxy_commands() {
    local commands; commands=(
'port:Override the listening port for proxy mode (127.0.0.1\:{port})' \
    )
    _describe -t commands 'warp-cli help proxy commands' commands "$@"
}
(( $+functions[_warp-cli__proxy_commands] )) ||
_warp-cli__proxy_commands() {
    local commands; commands=(
'port:Override the listening port for proxy mode (127.0.0.1\:{port})' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli proxy commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help__qlog_commands] )) ||
_warp-cli__debug__help__qlog_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug help qlog commands' commands "$@"
}
(( $+functions[_warp-cli__debug__qlog_commands] )) ||
_warp-cli__debug__qlog_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug qlog commands' commands "$@"
}
(( $+functions[_warp-cli__help__debug__qlog_commands] )) ||
_warp-cli__help__debug__qlog_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help debug qlog commands' commands "$@"
}
(( $+functions[_warp-cli__help__register_commands] )) ||
_warp-cli__help__register_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help register commands' commands "$@"
}
(( $+functions[_warp-cli__register_commands] )) ||
_warp-cli__register_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli register commands' commands "$@"
}
(( $+functions[_warp-cli__help__register-token-callback_commands] )) ||
_warp-cli__help__register-token-callback_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help register-token-callback commands' commands "$@"
}
(( $+functions[_warp-cli__register-token-callback_commands] )) ||
_warp-cli__register-token-callback_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli register-token-callback commands' commands "$@"
}
(( $+functions[_warp-cli__help__registration_commands] )) ||
_warp-cli__help__registration_commands() {
    local commands; commands=(
'show:Show information about the current registration' \
'new:Register this client, replacing any existing registration (Must be run before first connection!)' \
'delete:Delete current registration' \
'organization:Get the name of the current Teams organization' \
'devices:Display the list of devices associated with the current registration' \
'license:Attach the current registration to a different account using a license key' \
'token:Used internally by callbacks to return tokens as part of registration' \
'initialize-token-callback:Registers the browser token callback without actually registering' \
    )
    _describe -t commands 'warp-cli help registration commands' commands "$@"
}
(( $+functions[_warp-cli__registration_commands] )) ||
_warp-cli__registration_commands() {
    local commands; commands=(
'show:Show information about the current registration' \
'new:Register this client, replacing any existing registration (Must be run before first connection!)' \
'delete:Delete current registration' \
'organization:Get the name of the current Teams organization' \
'devices:Display the list of devices associated with the current registration' \
'license:Attach the current registration to a different account using a license key' \
'token:Used internally by callbacks to return tokens as part of registration' \
'initialize-token-callback:Registers the browser token callback without actually registering' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli registration commands' commands "$@"
}
(( $+functions[_warp-cli__dns__fallback__help__remove_commands] )) ||
_warp-cli__dns__fallback__help__remove_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns fallback help remove commands' commands "$@"
}
(( $+functions[_warp-cli__dns__fallback__remove_commands] )) ||
_warp-cli__dns__fallback__remove_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns fallback remove commands' commands "$@"
}
(( $+functions[_warp-cli__dns__help__fallback__remove_commands] )) ||
_warp-cli__dns__help__fallback__remove_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns help fallback remove commands' commands "$@"
}
(( $+functions[_warp-cli__help__dns__fallback__remove_commands] )) ||
_warp-cli__help__dns__fallback__remove_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help dns fallback remove commands' commands "$@"
}
(( $+functions[_warp-cli__help__trusted__ssid__remove_commands] )) ||
_warp-cli__help__trusted__ssid__remove_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help trusted ssid remove commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__host__remove_commands] )) ||
_warp-cli__help__tunnel__host__remove_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help tunnel host remove commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__ip__remove_commands] )) ||
_warp-cli__help__tunnel__ip__remove_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help tunnel ip remove commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__help__ssid__remove_commands] )) ||
_warp-cli__trusted__help__ssid__remove_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted help ssid remove commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__ssid__help__remove_commands] )) ||
_warp-cli__trusted__ssid__help__remove_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted ssid help remove commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__ssid__remove_commands] )) ||
_warp-cli__trusted__ssid__remove_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted ssid remove commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__host__remove_commands] )) ||
_warp-cli__tunnel__help__host__remove_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel help host remove commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__ip__remove_commands] )) ||
_warp-cli__tunnel__help__ip__remove_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel help ip remove commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__host__help__remove_commands] )) ||
_warp-cli__tunnel__host__help__remove_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel host help remove commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__host__remove_commands] )) ||
_warp-cli__tunnel__host__remove_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel host remove commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__ip__help__remove_commands] )) ||
_warp-cli__tunnel__ip__help__remove_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel ip help remove commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__ip__remove_commands] )) ||
_warp-cli__tunnel__ip__remove_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel ip remove commands' commands "$@"
}
(( $+functions[_warp-cli__help__remove-excluded-host_commands] )) ||
_warp-cli__help__remove-excluded-host_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help remove-excluded-host commands' commands "$@"
}
(( $+functions[_warp-cli__remove-excluded-host_commands] )) ||
_warp-cli__remove-excluded-host_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli remove-excluded-host commands' commands "$@"
}
(( $+functions[_warp-cli__help__remove-excluded-route_commands] )) ||
_warp-cli__help__remove-excluded-route_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help remove-excluded-route commands' commands "$@"
}
(( $+functions[_warp-cli__remove-excluded-route_commands] )) ||
_warp-cli__remove-excluded-route_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli remove-excluded-route commands' commands "$@"
}
(( $+functions[_warp-cli__help__remove-fallback-domain_commands] )) ||
_warp-cli__help__remove-fallback-domain_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help remove-fallback-domain commands' commands "$@"
}
(( $+functions[_warp-cli__remove-fallback-domain_commands] )) ||
_warp-cli__remove-fallback-domain_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli remove-fallback-domain commands' commands "$@"
}
(( $+functions[_warp-cli__help__remove-trusted-ssid_commands] )) ||
_warp-cli__help__remove-trusted-ssid_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help remove-trusted-ssid commands' commands "$@"
}
(( $+functions[_warp-cli__remove-trusted-ssid_commands] )) ||
_warp-cli__remove-trusted-ssid_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli remove-trusted-ssid commands' commands "$@"
}
(( $+functions[_warp-cli__api__endpoint__help__reset_commands] )) ||
_warp-cli__api__endpoint__help__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli api endpoint help reset commands' commands "$@"
}
(( $+functions[_warp-cli__api__endpoint__reset_commands] )) ||
_warp-cli__api__endpoint__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli api endpoint reset commands' commands "$@"
}
(( $+functions[_warp-cli__api__help__endpoint__reset_commands] )) ||
_warp-cli__api__help__endpoint__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli api help endpoint reset commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help__log-filter__reset_commands] )) ||
_warp-cli__debug__help__log-filter__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug help log-filter reset commands' commands "$@"
}
(( $+functions[_warp-cli__debug__log-filter__help__reset_commands] )) ||
_warp-cli__debug__log-filter__help__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug log-filter help reset commands' commands "$@"
}
(( $+functions[_warp-cli__debug__log-filter__reset_commands] )) ||
_warp-cli__debug__log-filter__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug log-filter reset commands' commands "$@"
}
(( $+functions[_warp-cli__dns__endpoint__help__reset_commands] )) ||
_warp-cli__dns__endpoint__help__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns endpoint help reset commands' commands "$@"
}
(( $+functions[_warp-cli__dns__endpoint__reset_commands] )) ||
_warp-cli__dns__endpoint__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns endpoint reset commands' commands "$@"
}
(( $+functions[_warp-cli__dns__fallback__help__reset_commands] )) ||
_warp-cli__dns__fallback__help__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns fallback help reset commands' commands "$@"
}
(( $+functions[_warp-cli__dns__fallback__reset_commands] )) ||
_warp-cli__dns__fallback__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns fallback reset commands' commands "$@"
}
(( $+functions[_warp-cli__dns__gateway-id__help__reset_commands] )) ||
_warp-cli__dns__gateway-id__help__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns gateway-id help reset commands' commands "$@"
}
(( $+functions[_warp-cli__dns__gateway-id__reset_commands] )) ||
_warp-cli__dns__gateway-id__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns gateway-id reset commands' commands "$@"
}
(( $+functions[_warp-cli__dns__help__endpoint__reset_commands] )) ||
_warp-cli__dns__help__endpoint__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns help endpoint reset commands' commands "$@"
}
(( $+functions[_warp-cli__dns__help__fallback__reset_commands] )) ||
_warp-cli__dns__help__fallback__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns help fallback reset commands' commands "$@"
}
(( $+functions[_warp-cli__dns__help__gateway-id__reset_commands] )) ||
_warp-cli__dns__help__gateway-id__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns help gateway-id reset commands' commands "$@"
}
(( $+functions[_warp-cli__help__api__endpoint__reset_commands] )) ||
_warp-cli__help__api__endpoint__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help api endpoint reset commands' commands "$@"
}
(( $+functions[_warp-cli__help__debug__log-filter__reset_commands] )) ||
_warp-cli__help__debug__log-filter__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help debug log-filter reset commands' commands "$@"
}
(( $+functions[_warp-cli__help__dns__endpoint__reset_commands] )) ||
_warp-cli__help__dns__endpoint__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help dns endpoint reset commands' commands "$@"
}
(( $+functions[_warp-cli__help__dns__fallback__reset_commands] )) ||
_warp-cli__help__dns__fallback__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help dns fallback reset commands' commands "$@"
}
(( $+functions[_warp-cli__help__dns__gateway-id__reset_commands] )) ||
_warp-cli__help__dns__gateway-id__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help dns gateway-id reset commands' commands "$@"
}
(( $+functions[_warp-cli__help__settings__reset_commands] )) ||
_warp-cli__help__settings__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help settings reset commands' commands "$@"
}
(( $+functions[_warp-cli__help__trusted__ssid__reset_commands] )) ||
_warp-cli__help__trusted__ssid__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help trusted ssid reset commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__endpoint__reset_commands] )) ||
_warp-cli__help__tunnel__endpoint__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help tunnel endpoint reset commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__host__reset_commands] )) ||
_warp-cli__help__tunnel__host__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help tunnel host reset commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__ip__reset_commands] )) ||
_warp-cli__help__tunnel__ip__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help tunnel ip reset commands' commands "$@"
}
(( $+functions[_warp-cli__settings__help__reset_commands] )) ||
_warp-cli__settings__help__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli settings help reset commands' commands "$@"
}
(( $+functions[_warp-cli__settings__reset_commands] )) ||
_warp-cli__settings__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli settings reset commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__help__ssid__reset_commands] )) ||
_warp-cli__trusted__help__ssid__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted help ssid reset commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__ssid__help__reset_commands] )) ||
_warp-cli__trusted__ssid__help__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted ssid help reset commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__ssid__reset_commands] )) ||
_warp-cli__trusted__ssid__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted ssid reset commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__endpoint__help__reset_commands] )) ||
_warp-cli__tunnel__endpoint__help__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel endpoint help reset commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__endpoint__reset_commands] )) ||
_warp-cli__tunnel__endpoint__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel endpoint reset commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__endpoint__reset_commands] )) ||
_warp-cli__tunnel__help__endpoint__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel help endpoint reset commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__host__reset_commands] )) ||
_warp-cli__tunnel__help__host__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel help host reset commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__ip__reset_commands] )) ||
_warp-cli__tunnel__help__ip__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel help ip reset commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__host__help__reset_commands] )) ||
_warp-cli__tunnel__host__help__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel host help reset commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__host__reset_commands] )) ||
_warp-cli__tunnel__host__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel host reset commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__ip__help__reset_commands] )) ||
_warp-cli__tunnel__ip__help__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel ip help reset commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__ip__reset_commands] )) ||
_warp-cli__tunnel__ip__reset_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel ip reset commands' commands "$@"
}
(( $+functions[_warp-cli__help__reset-settings_commands] )) ||
_warp-cli__help__reset-settings_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help reset-settings commands' commands "$@"
}
(( $+functions[_warp-cli__reset-settings_commands] )) ||
_warp-cli__reset-settings_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli reset-settings commands' commands "$@"
}
(( $+functions[_warp-cli__help__restore-fallback-domains_commands] )) ||
_warp-cli__help__restore-fallback-domains_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help restore-fallback-domains commands' commands "$@"
}
(( $+functions[_warp-cli__restore-fallback-domains_commands] )) ||
_warp-cli__restore-fallback-domains_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli restore-fallback-domains commands' commands "$@"
}
(( $+functions[_warp-cli__help__rotate-keys_commands] )) ||
_warp-cli__help__rotate-keys_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help rotate-keys commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__rotate-keys_commands] )) ||
_warp-cli__help__tunnel__rotate-keys_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help tunnel rotate-keys commands' commands "$@"
}
(( $+functions[_warp-cli__rotate-keys_commands] )) ||
_warp-cli__rotate-keys_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli rotate-keys commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__rotate-keys_commands] )) ||
_warp-cli__tunnel__help__rotate-keys_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel help rotate-keys commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__rotate-keys_commands] )) ||
_warp-cli__tunnel__rotate-keys_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel rotate-keys commands' commands "$@"
}
(( $+functions[_warp-cli__api__endpoint__help__set_commands] )) ||
_warp-cli__api__endpoint__help__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli api endpoint help set commands' commands "$@"
}
(( $+functions[_warp-cli__api__endpoint__set_commands] )) ||
_warp-cli__api__endpoint__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli api endpoint set commands' commands "$@"
}
(( $+functions[_warp-cli__api__help__endpoint__set_commands] )) ||
_warp-cli__api__help__endpoint__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli api help endpoint set commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help__log-filter__set_commands] )) ||
_warp-cli__debug__help__log-filter__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug help log-filter set commands' commands "$@"
}
(( $+functions[_warp-cli__debug__log-filter__help__set_commands] )) ||
_warp-cli__debug__log-filter__help__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug log-filter help set commands' commands "$@"
}
(( $+functions[_warp-cli__debug__log-filter__set_commands] )) ||
_warp-cli__debug__log-filter__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug log-filter set commands' commands "$@"
}
(( $+functions[_warp-cli__dns__endpoint__help__set_commands] )) ||
_warp-cli__dns__endpoint__help__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns endpoint help set commands' commands "$@"
}
(( $+functions[_warp-cli__dns__endpoint__set_commands] )) ||
_warp-cli__dns__endpoint__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns endpoint set commands' commands "$@"
}
(( $+functions[_warp-cli__dns__gateway-id__help__set_commands] )) ||
_warp-cli__dns__gateway-id__help__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns gateway-id help set commands' commands "$@"
}
(( $+functions[_warp-cli__dns__gateway-id__set_commands] )) ||
_warp-cli__dns__gateway-id__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns gateway-id set commands' commands "$@"
}
(( $+functions[_warp-cli__dns__help__endpoint__set_commands] )) ||
_warp-cli__dns__help__endpoint__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns help endpoint set commands' commands "$@"
}
(( $+functions[_warp-cli__dns__help__gateway-id__set_commands] )) ||
_warp-cli__dns__help__gateway-id__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns help gateway-id set commands' commands "$@"
}
(( $+functions[_warp-cli__help__api__endpoint__set_commands] )) ||
_warp-cli__help__api__endpoint__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help api endpoint set commands' commands "$@"
}
(( $+functions[_warp-cli__help__debug__log-filter__set_commands] )) ||
_warp-cli__help__debug__log-filter__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help debug log-filter set commands' commands "$@"
}
(( $+functions[_warp-cli__help__dns__endpoint__set_commands] )) ||
_warp-cli__help__dns__endpoint__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help dns endpoint set commands' commands "$@"
}
(( $+functions[_warp-cli__help__dns__gateway-id__set_commands] )) ||
_warp-cli__help__dns__gateway-id__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help dns gateway-id set commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__endpoint__set_commands] )) ||
_warp-cli__help__tunnel__endpoint__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help tunnel endpoint set commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__endpoint__help__set_commands] )) ||
_warp-cli__tunnel__endpoint__help__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel endpoint help set commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__endpoint__set_commands] )) ||
_warp-cli__tunnel__endpoint__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel endpoint set commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__endpoint__set_commands] )) ||
_warp-cli__tunnel__help__endpoint__set_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel help endpoint set commands' commands "$@"
}
(( $+functions[_warp-cli__help__mdm__set-config_commands] )) ||
_warp-cli__help__mdm__set-config_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help mdm set-config commands' commands "$@"
}
(( $+functions[_warp-cli__mdm__help__set-config_commands] )) ||
_warp-cli__mdm__help__set-config_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli mdm help set-config commands' commands "$@"
}
(( $+functions[_warp-cli__mdm__set-config_commands] )) ||
_warp-cli__mdm__set-config_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli mdm set-config commands' commands "$@"
}
(( $+functions[_warp-cli__help__set-custom-endpoint_commands] )) ||
_warp-cli__help__set-custom-endpoint_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help set-custom-endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__set-custom-endpoint_commands] )) ||
_warp-cli__set-custom-endpoint_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli set-custom-endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__help__set-doh-endpoint_commands] )) ||
_warp-cli__help__set-doh-endpoint_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help set-doh-endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__set-doh-endpoint_commands] )) ||
_warp-cli__set-doh-endpoint_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli set-doh-endpoint commands' commands "$@"
}
(( $+functions[_warp-cli__help__set-families-mode_commands] )) ||
_warp-cli__help__set-families-mode_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help set-families-mode commands' commands "$@"
}
(( $+functions[_warp-cli__set-families-mode_commands] )) ||
_warp-cli__set-families-mode_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli set-families-mode commands' commands "$@"
}
(( $+functions[_warp-cli__help__set-gateway_commands] )) ||
_warp-cli__help__set-gateway_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help set-gateway commands' commands "$@"
}
(( $+functions[_warp-cli__set-gateway_commands] )) ||
_warp-cli__set-gateway_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli set-gateway commands' commands "$@"
}
(( $+functions[_warp-cli__help__set-license_commands] )) ||
_warp-cli__help__set-license_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help set-license commands' commands "$@"
}
(( $+functions[_warp-cli__set-license_commands] )) ||
_warp-cli__set-license_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli set-license commands' commands "$@"
}
(( $+functions[_warp-cli__help__set-mode_commands] )) ||
_warp-cli__help__set-mode_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help set-mode commands' commands "$@"
}
(( $+functions[_warp-cli__set-mode_commands] )) ||
_warp-cli__set-mode_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli set-mode commands' commands "$@"
}
(( $+functions[_warp-cli__help__set-proxy-port_commands] )) ||
_warp-cli__help__set-proxy-port_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help set-proxy-port commands' commands "$@"
}
(( $+functions[_warp-cli__set-proxy-port_commands] )) ||
_warp-cli__set-proxy-port_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli set-proxy-port commands' commands "$@"
}
(( $+functions[_warp-cli__help__set-tunnel-mtu_commands] )) ||
_warp-cli__help__set-tunnel-mtu_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help set-tunnel-mtu commands' commands "$@"
}
(( $+functions[_warp-cli__set-tunnel-mtu_commands] )) ||
_warp-cli__set-tunnel-mtu_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli set-tunnel-mtu commands' commands "$@"
}
(( $+functions[_warp-cli__help__set-virtual-network_commands] )) ||
_warp-cli__help__set-virtual-network_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help set-virtual-network commands' commands "$@"
}
(( $+functions[_warp-cli__set-virtual-network_commands] )) ||
_warp-cli__set-virtual-network_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli set-virtual-network commands' commands "$@"
}
(( $+functions[_warp-cli__help__set-warp-override-ip_commands] )) ||
_warp-cli__help__set-warp-override-ip_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help set-warp-override-ip commands' commands "$@"
}
(( $+functions[_warp-cli__set-warp-override-ip_commands] )) ||
_warp-cli__set-warp-override-ip_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli set-warp-override-ip commands' commands "$@"
}
(( $+functions[_warp-cli__help__settings_commands] )) ||
_warp-cli__help__settings_commands() {
    local commands; commands=(
'list:Retrieve the current application settings' \
'reset:Restore settings to default' \
'support-url:Get the support url for the current Teams organization' \
'mode-switch-allowed:Outputs true if Teams users should be able to change connection mode, or false if not' \
    )
    _describe -t commands 'warp-cli help settings commands' commands "$@"
}
(( $+functions[_warp-cli__settings_commands] )) ||
_warp-cli__settings_commands() {
    local commands; commands=(
'list:Retrieve the current application settings' \
'reset:Restore settings to default' \
'support-url:Get the support url for the current Teams organization' \
'mode-switch-allowed:Outputs true if Teams users should be able to change connection mode, or false if not' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli settings commands' commands "$@"
}
(( $+functions[_warp-cli__help__override__local-network__show_commands] )) ||
_warp-cli__help__override__local-network__show_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help override local-network show commands' commands "$@"
}
(( $+functions[_warp-cli__help__override__show_commands] )) ||
_warp-cli__help__override__show_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help override show commands' commands "$@"
}
(( $+functions[_warp-cli__help__registration__show_commands] )) ||
_warp-cli__help__registration__show_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help registration show commands' commands "$@"
}
(( $+functions[_warp-cli__override__help__local-network__show_commands] )) ||
_warp-cli__override__help__local-network__show_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override help local-network show commands' commands "$@"
}
(( $+functions[_warp-cli__override__help__show_commands] )) ||
_warp-cli__override__help__show_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override help show commands' commands "$@"
}
(( $+functions[_warp-cli__override__local-network__help__show_commands] )) ||
_warp-cli__override__local-network__help__show_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override local-network help show commands' commands "$@"
}
(( $+functions[_warp-cli__override__local-network__show_commands] )) ||
_warp-cli__override__local-network__show_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override local-network show commands' commands "$@"
}
(( $+functions[_warp-cli__override__show_commands] )) ||
_warp-cli__override__show_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override show commands' commands "$@"
}
(( $+functions[_warp-cli__registration__help__show_commands] )) ||
_warp-cli__registration__help__show_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration help show commands' commands "$@"
}
(( $+functions[_warp-cli__registration__show_commands] )) ||
_warp-cli__registration__show_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration show commands' commands "$@"
}
(( $+functions[_warp-cli__help__trusted__ssid_commands] )) ||
_warp-cli__help__trusted__ssid_commands() {
    local commands; commands=(
'list:' \
'add:' \
'remove:' \
'reset:' \
    )
    _describe -t commands 'warp-cli help trusted ssid commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__help__ssid_commands] )) ||
_warp-cli__trusted__help__ssid_commands() {
    local commands; commands=(
'list:' \
'add:' \
'remove:' \
'reset:' \
    )
    _describe -t commands 'warp-cli trusted help ssid commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__ssid_commands] )) ||
_warp-cli__trusted__ssid_commands() {
    local commands; commands=(
'list:' \
'add:' \
'remove:' \
'reset:' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli trusted ssid commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help__pcap__start_commands] )) ||
_warp-cli__debug__help__pcap__start_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug help pcap start commands' commands "$@"
}
(( $+functions[_warp-cli__debug__pcap__help__start_commands] )) ||
_warp-cli__debug__pcap__help__start_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug pcap help start commands' commands "$@"
}
(( $+functions[_warp-cli__debug__pcap__start_commands] )) ||
_warp-cli__debug__pcap__start_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug pcap start commands' commands "$@"
}
(( $+functions[_warp-cli__help__debug__pcap__start_commands] )) ||
_warp-cli__help__debug__pcap__start_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help debug pcap start commands' commands "$@"
}
(( $+functions[_warp-cli__help__start-packet-capture_commands] )) ||
_warp-cli__help__start-packet-capture_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help start-packet-capture commands' commands "$@"
}
(( $+functions[_warp-cli__start-packet-capture_commands] )) ||
_warp-cli__start-packet-capture_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli start-packet-capture commands' commands "$@"
}
(( $+functions[_warp-cli__dns__help__stats_commands] )) ||
_warp-cli__dns__help__stats_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns help stats commands' commands "$@"
}
(( $+functions[_warp-cli__dns__stats_commands] )) ||
_warp-cli__dns__stats_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli dns stats commands' commands "$@"
}
(( $+functions[_warp-cli__help__dns__stats_commands] )) ||
_warp-cli__help__dns__stats_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help dns stats commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel__stats_commands] )) ||
_warp-cli__help__tunnel__stats_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help tunnel stats commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__help__stats_commands] )) ||
_warp-cli__tunnel__help__stats_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel help stats commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel__stats_commands] )) ||
_warp-cli__tunnel__stats_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli tunnel stats commands' commands "$@"
}
(( $+functions[_warp-cli__help__status_commands] )) ||
_warp-cli__help__status_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help status commands' commands "$@"
}
(( $+functions[_warp-cli__status_commands] )) ||
_warp-cli__status_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli status commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help__pcap__stop_commands] )) ||
_warp-cli__debug__help__pcap__stop_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug help pcap stop commands' commands "$@"
}
(( $+functions[_warp-cli__debug__pcap__help__stop_commands] )) ||
_warp-cli__debug__pcap__help__stop_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug pcap help stop commands' commands "$@"
}
(( $+functions[_warp-cli__debug__pcap__stop_commands] )) ||
_warp-cli__debug__pcap__stop_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug pcap stop commands' commands "$@"
}
(( $+functions[_warp-cli__help__debug__pcap__stop_commands] )) ||
_warp-cli__help__debug__pcap__stop_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help debug pcap stop commands' commands "$@"
}
(( $+functions[_warp-cli__help__override__local-network__stop_commands] )) ||
_warp-cli__help__override__local-network__stop_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help override local-network stop commands' commands "$@"
}
(( $+functions[_warp-cli__override__help__local-network__stop_commands] )) ||
_warp-cli__override__help__local-network__stop_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override help local-network stop commands' commands "$@"
}
(( $+functions[_warp-cli__override__local-network__help__stop_commands] )) ||
_warp-cli__override__local-network__help__stop_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override local-network help stop commands' commands "$@"
}
(( $+functions[_warp-cli__override__local-network__stop_commands] )) ||
_warp-cli__override__local-network__stop_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override local-network stop commands' commands "$@"
}
(( $+functions[_warp-cli__help__stop-packet-capture_commands] )) ||
_warp-cli__help__stop-packet-capture_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help stop-packet-capture commands' commands "$@"
}
(( $+functions[_warp-cli__stop-packet-capture_commands] )) ||
_warp-cli__stop-packet-capture_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli stop-packet-capture commands' commands "$@"
}
(( $+functions[_warp-cli__help__settings__support-url_commands] )) ||
_warp-cli__help__settings__support-url_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help settings support-url commands' commands "$@"
}
(( $+functions[_warp-cli__settings__help__support-url_commands] )) ||
_warp-cli__settings__help__support-url_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli settings help support-url commands' commands "$@"
}
(( $+functions[_warp-cli__settings__support-url_commands] )) ||
_warp-cli__settings__support-url_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli settings support-url commands' commands "$@"
}
(( $+functions[_warp-cli__debug__help__task-dump_commands] )) ||
_warp-cli__debug__help__task-dump_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug help task-dump commands' commands "$@"
}
(( $+functions[_warp-cli__debug__task-dump_commands] )) ||
_warp-cli__debug__task-dump_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli debug task-dump commands' commands "$@"
}
(( $+functions[_warp-cli__help__debug__task-dump_commands] )) ||
_warp-cli__help__debug__task-dump_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help debug task-dump commands' commands "$@"
}
(( $+functions[_warp-cli__help__teams-enroll_commands] )) ||
_warp-cli__help__teams-enroll_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help teams-enroll commands' commands "$@"
}
(( $+functions[_warp-cli__teams-enroll_commands] )) ||
_warp-cli__teams-enroll_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli teams-enroll commands' commands "$@"
}
(( $+functions[_warp-cli__help__teams-enroll-token_commands] )) ||
_warp-cli__help__teams-enroll-token_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help teams-enroll-token commands' commands "$@"
}
(( $+functions[_warp-cli__teams-enroll-token_commands] )) ||
_warp-cli__teams-enroll-token_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli teams-enroll-token commands' commands "$@"
}
(( $+functions[_warp-cli__help__registration__token_commands] )) ||
_warp-cli__help__registration__token_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help registration token commands' commands "$@"
}
(( $+functions[_warp-cli__registration__help__token_commands] )) ||
_warp-cli__registration__help__token_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration help token commands' commands "$@"
}
(( $+functions[_warp-cli__registration__token_commands] )) ||
_warp-cli__registration__token_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli registration token commands' commands "$@"
}
(( $+functions[_warp-cli__help__trusted_commands] )) ||
_warp-cli__help__trusted_commands() {
    local commands; commands=(
'ssid:Configure trusted Wi-Fi networks for which the client will be automatically disconnected' \
'ethernet:Automatically disconnect on all ethernet networks (disabled for Zero Trust customers)' \
'wifi:Automatically disconnect on all Wi-Fi networks (disabled for Zero Trust customers)' \
    )
    _describe -t commands 'warp-cli help trusted commands' commands "$@"
}
(( $+functions[_warp-cli__trusted_commands] )) ||
_warp-cli__trusted_commands() {
    local commands; commands=(
'ssid:Configure trusted Wi-Fi networks for which the client will be automatically disconnected' \
'ethernet:Automatically disconnect on all ethernet networks (disabled for Zero Trust customers)' \
'wifi:Automatically disconnect on all Wi-Fi networks (disabled for Zero Trust customers)' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli trusted commands' commands "$@"
}
(( $+functions[_warp-cli__help__tunnel_commands] )) ||
_warp-cli__help__tunnel_commands() {
    local commands; commands=(
'dump:Get split tunnel routing dump. For include-only mode, this shows routes NOT included' \
'host:Configure split tunnel hosts' \
'ip:Configure split tunnel IP ranges' \
'stats:Retrieve the stats for the current tunnel connection' \
'rotate-keys:Generate a new key-pair, keeping the current registration' \
'endpoint:Force the client to connect to the specified IP\:PORT endpoint (Zero Trust customers must run this command as a privileged user)' \
'mtu:Set the MTU value of the tunnel' \
    )
    _describe -t commands 'warp-cli help tunnel commands' commands "$@"
}
(( $+functions[_warp-cli__tunnel_commands] )) ||
_warp-cli__tunnel_commands() {
    local commands; commands=(
'dump:Get split tunnel routing dump. For include-only mode, this shows routes NOT included' \
'host:Configure split tunnel hosts' \
'ip:Configure split tunnel IP ranges' \
'stats:Retrieve the stats for the current tunnel connection' \
'rotate-keys:Generate a new key-pair, keeping the current registration' \
'endpoint:Force the client to connect to the specified IP\:PORT endpoint (Zero Trust customers must run this command as a privileged user)' \
'mtu:Set the MTU value of the tunnel' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'warp-cli tunnel commands' commands "$@"
}
(( $+functions[_warp-cli__help__override__unlock_commands] )) ||
_warp-cli__help__override__unlock_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help override unlock commands' commands "$@"
}
(( $+functions[_warp-cli__override__help__unlock_commands] )) ||
_warp-cli__override__help__unlock_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override help unlock commands' commands "$@"
}
(( $+functions[_warp-cli__override__unlock_commands] )) ||
_warp-cli__override__unlock_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli override unlock commands' commands "$@"
}
(( $+functions[_warp-cli__help__vnet_commands] )) ||
_warp-cli__help__vnet_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help vnet commands' commands "$@"
}
(( $+functions[_warp-cli__vnet_commands] )) ||
_warp-cli__vnet_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli vnet commands' commands "$@"
}
(( $+functions[_warp-cli__help__warp-dns-stats_commands] )) ||
_warp-cli__help__warp-dns-stats_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help warp-dns-stats commands' commands "$@"
}
(( $+functions[_warp-cli__warp-dns-stats_commands] )) ||
_warp-cli__warp-dns-stats_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli warp-dns-stats commands' commands "$@"
}
(( $+functions[_warp-cli__help__warp-stats_commands] )) ||
_warp-cli__help__warp-stats_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help warp-stats commands' commands "$@"
}
(( $+functions[_warp-cli__warp-stats_commands] )) ||
_warp-cli__warp-stats_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli warp-stats commands' commands "$@"
}
(( $+functions[_warp-cli__help__trusted__wifi_commands] )) ||
_warp-cli__help__trusted__wifi_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli help trusted wifi commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__help__wifi_commands] )) ||
_warp-cli__trusted__help__wifi_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted help wifi commands' commands "$@"
}
(( $+functions[_warp-cli__trusted__wifi_commands] )) ||
_warp-cli__trusted__wifi_commands() {
    local commands; commands=()
    _describe -t commands 'warp-cli trusted wifi commands' commands "$@"
}

if [ "$funcstack[1]" = "_warp-cli" ]; then
    _warp-cli "$@"
else
    compdef _warp-cli warp-cli
fi
