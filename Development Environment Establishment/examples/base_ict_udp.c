#include "base_ict_udp.h"


#define MAX_SEND_MTU_SIZE           1460
#define SEND_BUFF_SIZE              (sizeof(ICT_ST_HIF_DATA_T) - 1 + MAX_SEND_MTU_SIZE)


typedef struct{
    uint32_t  data_len;
    uint08_t   data[SEND_BUFF_SIZE];
} ICT_ST_SEND_DATA_T;

typedef struct{
    ICT_ST_IP_CONFIG_T  ip_params;
    ICT_ST_HIF_DATA_T   sock_info;

    ICT_ST_SOCKET_T     sock_params;
    sint32_t               data_sd;
    sint32_t               uc_sd;
    sint32_t               socket_type[NUM_OF_SOCKETS];
    sint32_t               port[NUM_OF_SOCKETS];
    uint08_t               remote_ipaddr[NUM_OF_SOCKETS][4];
} ICT_ST_SOCK_CNTX_T;

ICT_ST_JOIN_REQ_T   req_join;

static ICT_ST_SOCK_CNTX_T       sock_cntx;
static ICT_ST_SEND_DATA_T       socket_send_data;

static uint08_t sock_tx_buf[TX_MAX_SIZE];

ICT_ST_IP_CONFIG_T  local_ip_params;

static glb_udp_cmd_tpf cmd_spf = pNull_gd;
static bool_t bReconnect_s = false_gd;


void sock_get_params(ICT_ST_SOCKET_T *p_params){
    wjq_memory_memset_gd(p_params, 0x00, sizeof(ICT_ST_SOCKET_T));

    p_params->socket_type = sock_cntx.sock_params.socket_type;
    p_params->local_port = sock_cntx.sock_params.local_port;
    p_params->remote_port = sock_cntx.sock_params.remote_port;
    p_params->remote_ipaddr[0] = sock_cntx.sock_params.remote_ipaddr[0];
    p_params->remote_ipaddr[1] = sock_cntx.sock_params.remote_ipaddr[1];
    p_params->remote_ipaddr[2] = sock_cntx.sock_params.remote_ipaddr[2];
    p_params->remote_ipaddr[3] = sock_cntx.sock_params.remote_ipaddr[3];
}

void sock_clr_params(void){
    wjq_memory_memset_gd(&sock_cntx.sock_params, 0x00, sizeof(ICT_ST_SOCKET_T));
}

UINT16 sock_rtn_desc(sint32_t port){
    uint32_t sd;

    for(sd = 0; sd < NUM_OF_SOCKETS; sd++){
        if((sock_cntx.port[sd] != 0) && (sock_cntx.port[sd] == port)){
            break;
        }
    }

    return (sd);
}

sint32_t sock_close(void){
    ICT_ST_SOCKET_T params;
    ICT_ST_SOCKET_CLOSE_T socket_close;

    sock_get_params(&params);

    if(params.socket_type){
        UINT16 port;

        if(params.remote_port){
            port = params.remote_port;
        } else{
            port = params.local_port;
        }

        socket_close.socket_desc = sock_rtn_desc(port);

        if(socket_close.socket_desc < NUM_OF_SOCKETS){
            wjq_dbg_log3ValThenDly_gd("Socket will be closed 1!!! - type [%d] sd[%d] port[%d]\n", sock_cntx.socket_type[socket_close.socket_desc], socket_close.socket_desc, port);
            return (ict_api_tcpip_socket_close_handler(&socket_close));
        } else{
            wjq_dbg_log3ValThenDly_gd("Socket will be closed Error!!! - type [%d] sd[%d] port[%d]\n", sock_cntx.socket_type[socket_close.socket_desc], socket_close.socket_desc, port);
        }
    } else{
        for(socket_close.socket_desc = 0; socket_close.socket_desc < NUM_OF_SOCKETS; socket_close.socket_desc++){
            if(sock_cntx.socket_type[socket_close.socket_desc] != -1){
                wjq_dbg_log3ValThenDly_gd("Socket will be closed 2!!! - type [%d] sd[%d] port[%d]\n", sock_cntx.socket_type[socket_close.socket_desc], socket_close.socket_desc, sock_cntx.port[socket_close.socket_desc]);
                return (ict_api_tcpip_socket_close_handler(&socket_close));
            }
        }
    }

    return (ICT_ERR);
}

uint32_t sock_recv_ind(uint08_t *buf){
    ICT_ST_SOCKET_IND_T *socket_ind;

    socket_ind = (ICT_ST_SOCKET_IND_T *)buf;

    if(socket_ind->result == ERR_OK){
        if((0 > socket_ind->socket_desc) || (socket_ind->socket_desc >= NUM_OF_SOCKETS)){
            wjq_dbg_log1ValThenDly_gd("E: Error socket_desc = %d\n", socket_ind->socket_desc);
        } else{
            sock_cntx.data_sd = socket_ind->socket_desc;
        }

        wjq_dbg_log1ValThenDly_gd(" = socket_cmd  = %d\n", socket_ind->socket_cmd);
        wjq_dbg_log1ValThenDly_gd(" = socket_type = %d\n", socket_ind->socket_type);
        wjq_dbg_log1ValThenDly_gd(" = socket_desc = %d\n", socket_ind->socket_desc);
        wjq_dbg_log1ValThenDly_gd(" = result      = %d\n", socket_ind->result);

        if(socket_ind->socket_cmd == SOCKET_CMD_CREATE){
            ICT_ST_SOCKET_T params;

            sock_cntx.data_sd = socket_ind->socket_desc;

            sock_get_params(&params);

            sock_cntx.socket_type[socket_ind->socket_desc] = socket_ind->socket_type;

            wjq_dbg_log0ValThenDly_gd("SOCKET_CMD_CREATE\n");

            if(socket_ind->socket_type == SOCKET_TYPE_TCP_SERVER){
                wjq_dbg_log0ValThenDly_gd("SOCKET_TYPE_TCP_SERVER\n");
                sock_cntx.port[socket_ind->socket_desc] = params.local_port;
            } else if(socket_ind->socket_type == SOCKET_TYPE_TCP_CLIENT){
                wjq_dbg_log0ValThenDly_gd("SOCKET_TYPE_TCP_CLIENT\n");
                sock_cntx.port[socket_ind->socket_desc] = params.remote_port;
                sock_cntx.remote_ipaddr[socket_ind->socket_desc][0] = params.remote_ipaddr[0];
                sock_cntx.remote_ipaddr[socket_ind->socket_desc][1] = params.remote_ipaddr[1];
                sock_cntx.remote_ipaddr[socket_ind->socket_desc][2] = params.remote_ipaddr[2];
                sock_cntx.remote_ipaddr[socket_ind->socket_desc][3] = params.remote_ipaddr[3];
            } else if(socket_ind->socket_type == SOCKET_TYPE_UDP_SERVER){
                wjq_dbg_log0ValThenDly_gd("SOCKET_TYPE_UDP_SERVER\n");
                sock_cntx.port[socket_ind->socket_desc] = params.local_port;
            } else if(socket_ind->socket_type == SOCKET_TYPE_UDP_CLIENT){
                wjq_dbg_log0ValThenDly_gd("SOCKET_TYPE_UDP_CLIENT\n");
                sock_cntx.port[socket_ind->socket_desc] = params.remote_port;
                sock_cntx.remote_ipaddr[socket_ind->socket_desc][0] = params.remote_ipaddr[0];
                sock_cntx.remote_ipaddr[socket_ind->socket_desc][1] = params.remote_ipaddr[1];
                sock_cntx.remote_ipaddr[socket_ind->socket_desc][2] = params.remote_ipaddr[2];
                sock_cntx.remote_ipaddr[socket_ind->socket_desc][3] = params.remote_ipaddr[3];
            } else{
                wjq_dbg_log1ValThenDly_gd("W: Error Socket Type = %d\n", socket_ind->socket_type);
            }
        } else if(socket_ind->socket_cmd == SOCKET_CMD_CLOSE){
            wjq_dbg_log0ValThenDly_gd("SOCKET_CMD_CLOSE\n");

            if((sock_cntx.data_sd != NUM_OF_SOCKETS) && (sock_cntx.data_sd == socket_ind->socket_desc)){
                sock_cntx.data_sd = NUM_OF_SOCKETS;
            }

            sock_cntx.socket_type[socket_ind->socket_desc] = -1;
            sock_cntx.port[socket_ind->socket_desc] = 0;

            if(sock_cntx.sock_params.socket_type){
                sock_close();
            }
        } else{
            wjq_dbg_log0ValThenDly_gd("Socket Error 1\n");
        }
    } else{
        wjq_dbg_log0ValThenDly_gd("Socket Error 2\n");
    }

    sock_clr_params();

    return ICT_TRUE;
}

EErr_t base_ict_udp_txBytes(uint08_t *data, uint32_t data_len){
    ICT_ST_HIF_DATA_T *sock_info;
    sint32_t socket_desc;
    uint32_t *p_val;

    socket_desc = sock_cntx.data_sd;
    if((socket_desc >= NUM_OF_SOCKETS) && (data_len > 0)){
        wjq_dbg_err2ValThenDly_gd("socket_desc(%d), data_len(%d)\n", socket_desc, data_len);
        return EErr_UdpTx;
    }
    sock_cntx.uc_sd = socket_desc;

    if(sock_cntx.socket_type[sock_cntx.uc_sd] == -1){
        wjq_dbg_err1ValThenDly_gd("socket_type(%d)\n", sock_cntx.socket_type[sock_cntx.uc_sd]);
    }

    //socket_send_data;
    sock_info = (ICT_ST_HIF_DATA_T *)&sock_tx_buf[0];

    sock_info->socket_type = sock_cntx.socket_type[sock_cntx.uc_sd];
    sock_info->socket_desc = sock_cntx.uc_sd;
    sock_info->remote_port = sock_cntx.port[sock_cntx.uc_sd];
    sock_info->remote_ipaddr[0] = sock_cntx.remote_ipaddr[sock_cntx.uc_sd][0];
    sock_info->remote_ipaddr[1] = sock_cntx.remote_ipaddr[sock_cntx.uc_sd][1];
    sock_info->remote_ipaddr[2] = sock_cntx.remote_ipaddr[sock_cntx.uc_sd][2];
    sock_info->remote_ipaddr[3] = sock_cntx.remote_ipaddr[sock_cntx.uc_sd][3];

    sock_info->data_len = data_len;

    p_val = (uint32_t *)sock_info->data;

    wjq_memory_memcpy_gd(p_val, data, data_len);

    if(ict_api_send_data_handler(sock_info, TX_SIZE(sock_info->data_len)) != ICT_OK){
        wjq_dbg_err0ValThenDly_gd("send data\n");
        return EErr_UdpTx;
    }

    return EErr_None;
}

uint32_t sock_rcvd_data_ind(ICT_ST_HIF_DATA_T *sock_data, uint32_t len){
    if(sock_data->socket_type == SOCKET_TYPE_TCP_SERVER && sock_data->data_len == 0){
        sock_cntx.remote_ipaddr[sock_cntx.data_sd][0] = sock_data->remote_ipaddr[0];
        sock_cntx.remote_ipaddr[sock_cntx.data_sd][1] = sock_data->remote_ipaddr[1];
        sock_cntx.remote_ipaddr[sock_cntx.data_sd][2] = sock_data->remote_ipaddr[2];
        sock_cntx.remote_ipaddr[sock_cntx.data_sd][3] = sock_data->remote_ipaddr[3];
        sock_cntx.port[sock_cntx.data_sd] = sock_data->remote_port;

        wjq_dbg_log2ValThenDly_gd("Remote TCP Client ["IPSTR":%d] has been connected.\n",
                          IP2STR(sock_data->remote_ipaddr), sock_data->remote_port);
    } else if(sock_data->socket_type == SOCKET_TYPE_TCP_SERVER && sock_data->data_len == 0xFFFF){
        sock_cntx.remote_ipaddr[sock_cntx.data_sd][0] = 0;
        sock_cntx.remote_ipaddr[sock_cntx.data_sd][1] = 0;
        sock_cntx.remote_ipaddr[sock_cntx.data_sd][2] = 0;
        sock_cntx.remote_ipaddr[sock_cntx.data_sd][3] = 0;
        sock_cntx.port[sock_cntx.data_sd] = 0;

        wjq_dbg_log2ValThenDly_gd("Remote TCP Client ["IPSTR":%d] has been disconnected.\n",
                          IP2STR(sock_data->remote_ipaddr), sock_data->remote_port);
    } else{
        wjq_dbg_log3ValThenDly_gd("type[%d] sd[%d] port[%d]\n", sock_data->socket_type, sock_data->socket_desc, sock_data->remote_port);
        wjq_dbg_log1ValThenDly_gd("ip ["IPSTR"]\n", IP2STR(sock_data->remote_ipaddr));

        if((sock_cntx.data_sd != NUM_OF_SOCKETS) && (sock_cntx.data_sd == sock_data->socket_desc)){
            wjq_dbg_log1ValThenDly_gd("+DATA : %s\n", sock_data->data);
        }
    }

    return (ICT_TRUE);
}


uint32_t sock_rcvd_data_hif_ind(uint08_t *buf, uint32_t len){
    uint32_t status = ICT_FALSE;
    uint32_t sw_opt;

    sw_opt = ict_api_rcvd_data_sw_opt_handler(buf, len);
    //wjq_dbg_log3ValThenDly_gd("I: %s : %d : sw_opt=%d\n", __func__, __LINE__, sw_opt);

    switch(sw_opt){
        case HIF_SW_OPT_SOCKET_DATA:
        {
            ICT_ST_HIF_DATA_T *data_buf;
            uint32_t  data_len;
            uint08_t   send_buff[512];

            data_buf = ict_api_rcvd_data_handler(buf, &data_len);
            (*cmd_spf)(data_buf->data);


            //sock_rcvd_data_ind(data_buf, data_len);
            //wjq_dbg_log3ValThenDly_gd("I: %s : %d : HIF_SW_OPT_SOCKET_DATA : data_len=%d\n", __func__, __LINE__, data_len);

            //data_buf->data[data_buf->data_len++] = 0;
            //ict_api_send_data_handler(data_buf, TX_SIZE(data_buf->data_len));

            //base_ict_udp_txBytes(data_buf->data, data_buf->data_len);

            //wjq_dbg_log1ValThenDly_gd("I: Socket Rx Data : %s\n", data_buf->data);
            //len = ict_api_sprintf(send_buff, "%s%s", "Recv : ", data_buf->data);
            //uart_send_data(send_buff, len);

            break;
        }
        case HIF_SW_OPT_VENDOR_SPECIFIC:
        {
            uint08_t  *data_buf;
            uint32_t data_len, sw_type, more_flag;

            data_buf = ict_api_rcvd_data_sw_type_handler(buf, &data_len, &sw_type, &more_flag);

            switch(sw_type){
                case HIF_SW_TYPE_SMTP:
                    break;

                case HIF_SW_TYPE_POP3:
                    break;

                default:
                    break;
            }
            break;
        }
        default:
            break;
    }

    return (status);
}

static void sock_set_params(ICT_ST_SOCKET_T *p_params){
    sock_cntx.sock_params.socket_type = p_params->socket_type;
    sock_cntx.sock_params.local_port = p_params->local_port;
    sock_cntx.sock_params.remote_port = p_params->remote_port;
    sock_cntx.sock_params.remote_ipaddr[0] = p_params->remote_ipaddr[0];
    sock_cntx.sock_params.remote_ipaddr[1] = p_params->remote_ipaddr[1];
    sock_cntx.sock_params.remote_ipaddr[2] = p_params->remote_ipaddr[2];
    sock_cntx.sock_params.remote_ipaddr[3] = p_params->remote_ipaddr[3];
}

static void sock_operation_event_handler(T_MAC_EVENT *p_mac_event){
    ICT_ST_SOCKET_T     *p_sock_params;
    ICT_ST_IP_CONFIG_T  *p_ip_params;

    p_sock_params = (ICT_ST_SOCKET_T*)&sock_cntx.sock_params;
    p_ip_params = (ICT_ST_IP_CONFIG_T*)&sock_cntx.ip_params;

    switch(p_mac_event->code){
        case ICT_HIF_CMD_ST_JOIN_IND:
            if(ict_api_join_state(p_mac_event->buf) == ICT_TRUE){
                wjq_dbg_log0ValThenDly_gd("I: ASSOCIATED!\n");
            } else{
                wjq_dbg_log0ValThenDly_gd("W: DISCONNECT!\n");
                sock_close();
                sock_clr_params();
                bReconnect_s = true_gd;
            }
            break;

        case ICT_HIF_CMD_ST_DISCONNECTED_IND:
            wjq_dbg_log0ValThenDly_gd("E: DISASSOCIATED!!\n");
            break;

        case ICT_HIF_CMD_ST_NETWORK_INFO_IND:
            wjq_dbg_log0ValThenDly_gd("I: NETWORK_INFO_IND!!\n");
            {
                ICT_ST_NETWORK_INFO_IND_T *network_ind;
                network_ind = (ICT_ST_NETWORK_INFO_IND_T *)p_mac_event->buf;

                wjq_memory_memcpy_gd(p_ip_params->ipaddr, network_ind->ipaddr, 4);
                wjq_memory_memcpy_gd(p_ip_params->subnet, network_ind->subnet, 4);
                wjq_memory_memcpy_gd(p_ip_params->gateway, network_ind->gateway, 4);
                wjq_memory_memcpy_gd(p_ip_params->dns, network_ind->dns, 4);

                wjq_dbg_log1ValThenDly_gd(" LOCAL IP "IPSTR"\n", IP2STR(network_ind->ipaddr));
                wjq_dbg_log1ValThenDly_gd(" SUBNET   "IPSTR"\n", IP2STR(network_ind->subnet));
                wjq_dbg_log1ValThenDly_gd(" GATEWAY  "IPSTR"\n", IP2STR(network_ind->gateway));
                wjq_dbg_log1ValThenDly_gd(" DNS      "IPSTR"\n", IP2STR(network_ind->dns));
            }

            ict_api_tcpip_socket_create_handler(p_sock_params);
            break;
        case ICT_HIF_CMD_ST_SOCKET_IND:
            wjq_dbg_log0ValThenDly_gd("I: ICT_HIF_CMD_ST_SOCKET_IND.\n");
            sock_recv_ind(p_mac_event->buf);
            break;

        case ICT_HIF_CMD_ST_TCP_DISCONNECT_IND:
            wjq_dbg_log0ValThenDly_gd("E: ICT_HIF_CMD_ST_TCP_DISCONNECT_IND\n");
            break;

        case ICT_HIF_DATA_RX:
            wjq_dbg_log0ValThenDly_gd("I: ICT_HIF_DATA_RX\n");
            {
                sock_rcvd_data_hif_ind(p_mac_event->buf, p_mac_event->len);
            }
            break;

        default:
            wjq_dbg_log1ValThenDly_gd("E: unknown event. (%X)\n", p_mac_event->code);
            break;
    }
}


static EErr_t sock_connect_to_ap(ICT_ST_IP_CONFIG_T *p_params, ICT_ST_JOIN_REQ_T *p_join_req){
    if(ict_api_tcpip_set_ip_config_handler(p_params) != 0){
        return EErr_UdpConf;
    }
    if(ict_api_join_handler(p_join_req) != 0){
        return EErr_UdpJoin;
    }
    return EErr_None;
}


typedef struct _wlan_scan_ap_list{
    ICT_ST_SCAN_IND_T ap_info;
    struct _wlan_scan_ap_list *next;
} wlan_scan_ap_list_t;
static wlan_scan_ap_list_t *p_scan_head = ICT_NULL;
void wlan_init_scan_ap_list(){
    wlan_scan_ap_list_t *now_node = p_scan_head;
    wlan_scan_ap_list_t *tmp_node;

    while(now_node != ICT_NULL){
        tmp_node = now_node;
        now_node = now_node->next;

        ict_api_mfree(tmp_node);
    }

    p_scan_head = ICT_NULL;
}

void wlan_insert_scan_ap_list(ICT_ST_SCAN_IND_T *p_scan_ind){
    wlan_scan_ap_list_t *now_node = p_scan_head;
    wlan_scan_ap_list_t *tmp_node = ICT_NULL;

    /* 1. If exist a same BSSID, update that */
    while(now_node != ICT_NULL){
        if(ict_api_memcmp(now_node->ap_info.bssid, p_scan_ind->bssid, MAC_ADDR_LEN) == 0){
            wjq_memory_memcpy_gd(&now_node->ap_info, p_scan_ind, sizeof(ICT_ST_SCAN_IND_T));
            return;
        }
        now_node = now_node->next;
    }

    tmp_node = (wlan_scan_ap_list_t *)wjq_memory_malloc_gd(sizeof(wlan_scan_ap_list_t));
    wjq_memory_memset_gd(tmp_node, 0x00, sizeof(wlan_scan_ap_list_t));
    wjq_memory_memcpy_gd(&tmp_node->ap_info, p_scan_ind, sizeof(ICT_ST_SCAN_IND_T));

    /* 2. Check Head list */
    if(p_scan_head == ICT_NULL ||                                                      /* head is NULL */
        (p_scan_head != ICT_NULL && p_scan_head->ap_info.rssi <= tmp_node->ap_info.rssi))     /* head is weaker than new */
    {
        tmp_node->next = p_scan_head;
        p_scan_head = tmp_node;
        return;
    }

    /* 3. Check other list (If empty or weaker RSSI, add a list before that) */
    now_node = p_scan_head;
    while(now_node != ICT_NULL){
        if(now_node->next == ICT_NULL){
            now_node->next = tmp_node;
            return;
        } else{
            if(now_node->next->ap_info.rssi <= tmp_node->ap_info.rssi){
                tmp_node->next = now_node->next;
                now_node->next = tmp_node;
                return;
            }
        }

        now_node = now_node->next;
    }

    wjq_dbg_err1ValThenDly_gd("E: [%s] ERROR!\n", __func__);

    return;
}

void wlan_print_scan_ap_list(){
    wlan_scan_ap_list_t *now_node = p_scan_head;
    ICT_ST_SCAN_IND_T *ptr;

    wjq_dbg_log0ValThenDly_gd("************************* AP List *****************************\n");
    wjq_dbg_log0ValThenDly_gd(" CH  SSID                                BSSID            RSSI\n");
    while(now_node != ICT_NULL){
        ptr = &now_node->ap_info;
        wjq_dbg_log4ValThenDly_gd(" %3d %-32s "ICT_MACSTR"    %d\n", ptr->ch, ptr->ssid, ICT_MAC2STR(ptr->bssid), ptr->rssi);
        now_node = now_node->next;
    }
    wjq_dbg_log0ValThenDly_gd("***************************************************************\n");

    return;
}

void wlan_start_scan(ICT_ST_SCAN_REQ_T *scan_params){
    ict_api_scan_handler(scan_params);
}

void wlan_scan_event_handler(T_MAC_EVENT *p_mac_event){
    switch(p_mac_event->code){
        case ICT_HIF_CMD_ST_SCAN_IND:
            wjq_dbg_log0ValThenDly_gd("---- ICT_HIF_CMD_ST_SCAN_IND.\n");
            if(p_mac_event->buf){
                ICT_ST_SCAN_IND_T *p_scan_ind = (ICT_ST_SCAN_IND_T *)p_mac_event->buf;

                wlan_insert_scan_ap_list(p_scan_ind);
            }
            break;

        case ICT_HIF_CMD_ST_SCAN_RST_IND:
            wjq_dbg_log0ValThenDly_gd("---- ICT_HIF_CMD_ST_SCAN_RST_IND\n");
            wlan_print_scan_ap_list();
            break;

        default:
            wjq_dbg_err2ValThenDly_gd("E:[%s] unknown event. (%X)\n", __func__, p_mac_event->code);
            break;
    }
}
static bool_t scan(uint08_t const* pSsid_i){
    ICT_ST_SCAN_REQ_T params;

    uint16_t channel_list[] = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
        36, 40, 44, 48,
        52, 56, 60, 64,
        100, 104, 108, 112, 116,
        120, 124, 128,
        149, 153, 157, 161, 165,
        0
    };

    wlan_init_scan_ap_list();
    ict_cm_wlan_scan_event_callback_register(wlan_scan_event_handler);
    wjq_memory_memset_gd(&params, 0x00, sizeof(ICT_ST_SCAN_REQ_T));
    params.channel = channel_list;

    wlan_start_scan(&params);

    wjq_memory_memset_gd(params.ssid, 0x00, 32);
    wjq_memory_strcpy_gd(params.ssid, pSsid_i);
    params.ssid_len = ict_api_strlen((char*)params.ssid);

    if(ict_api_scan_handler(&params) != 0){
        return false_gd;
    }
    return true_gd;
}


EErr_t base_ict_udp_init(SUdp_t* psUdp_io, glb_udp_cmd_tpf cmd_pfi){
    if(cmd_spf == pNull_gd){
        cmd_spf = cmd_pfi;
    }
    /*if(scan(psUdp_io->aSsid) == false_gd){
        return EErr_UdpScan;
    }*/

    wjq_memory_memset_gd(&socket_send_data, 0x00, sizeof(ICT_ST_SEND_DATA_T));

    wjq_memory_memset_gd(&local_ip_params, 0x00, sizeof(ICT_ST_IP_CONFIG_T));
    local_ip_params.dhcp_mode = psUdp_io->bDhcp;
    IP4_ADDR_(local_ip_params.ipaddr, psUdp_io->aLclIpaddr[0], psUdp_io->aLclIpaddr[1], psUdp_io->aLclIpaddr[2], psUdp_io->aLclIpaddr[3]);
    IP4_ADDR_(local_ip_params.subnet, psUdp_io->aLclSubnet[0], psUdp_io->aLclSubnet[1], psUdp_io->aLclSubnet[2], psUdp_io->aLclSubnet[3]);
    IP4_ADDR_(local_ip_params.gateway, psUdp_io->aLclGateway[0], psUdp_io->aLclGateway[1], psUdp_io->aLclGateway[2], psUdp_io->aLclGateway[3]);
    IP4_ADDR_(local_ip_params.dns, psUdp_io->aLclDns[0], psUdp_io->aLclDns[1], psUdp_io->aLclDns[2], psUdp_io->aLclDns[3]);

    /* socket */
    sock_cntx.data_sd = NUM_OF_SOCKETS;
    sock_cntx.uc_sd = NUM_OF_SOCKETS;

    wjq_memory_memset_gd(&sock_cntx.sock_params, 0x00, sizeof(ICT_ST_SOCKET_T));

    /* socket descriptor */
    uint32_t i;
    for(i = 0; i < NUM_OF_SOCKETS; i++){
        sock_cntx.socket_type[i] = -1;
        sock_cntx.port[i] = 0;
    }

    wjq_memory_memset_gd(&req_join, 0x00, sizeof(ICT_ST_JOIN_REQ_T));
    req_join.ssid_len = ICT_STRLEN(psUdp_io->aSsid);
    ICT_STRCPY(req_join.ssid, psUdp_io->aSsid);
    req_join.key_len = ICT_STRLEN(psUdp_io->aPwd);
    ICT_STRCPY(req_join.key, psUdp_io->aPwd);

    ICT_ST_SOCKET_T set_sock_params;
    wjq_memory_memset_gd(&set_sock_params, 0x00, sizeof(ICT_ST_SOCKET_T));
    set_sock_params.socket_type = SOCKET_TYPE_UDP_CLIENT;
    set_sock_params.local_port = psUdp_io->lclPort;// 20016;
    set_sock_params.remote_port = psUdp_io->remotePort;// 30016;
    set_sock_params.remote_ipaddr[0] = psUdp_io->aRemoteIpaddr[0];
    set_sock_params.remote_ipaddr[1] = psUdp_io->aRemoteIpaddr[1];
    set_sock_params.remote_ipaddr[2] = psUdp_io->aRemoteIpaddr[2];
    set_sock_params.remote_ipaddr[3] = psUdp_io->aRemoteIpaddr[3];

    sock_set_params(&set_sock_params);

    ict_cm_wlan_event_callback_register((void *)sock_operation_event_handler);

    wjq_dbg_funcRtn_gd(sock_connect_to_ap(&local_ip_params, &req_join));
}


EErr_t base_ict_udp_isConnected(void){
    if(bReconnect_s == true_gd){
        bReconnect_s = false_gd;
        return EErr_None_Reconnect;
    }
    if(sock_cntx.data_sd >= NUM_OF_SOCKETS){
        return EErr_None_Connecting;
    }
    return EErr_None_Connected;
}
