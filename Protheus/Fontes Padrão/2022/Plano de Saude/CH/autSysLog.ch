// Tipo de mensagem
#define TYPE_SYSLOG 1

// Tipo de Saida
#define CONSOLE 1
#define FILE 2
#define API 3

// ch gerado com base no documento http://www.rfc-base.org/txt/rfc-5424.txt

#define LOG_DEFAULT_HAT "log_hat"
#define AUDITO_LOG "syslog_integracao_auditoria"
#define INTDAD_LOG "syslog_integracao_dados"
#define POOLING_LOG "syslog_pooling"

//Facilities

#define KERNEL 0
#define USER_LEVEL 1
#define MAIL_SYSTEM 2
#define SYSTEM_DAEMON 3
#define AUTH_SECURITY 4
#define SYSLOG 5
#define LINE_PRINTER_SUBSYSTEM 6
#define NETWORK_NEWS_SUBSYSTEM 7
#define UUCP_SUBSYSTEM 8
#define CRON 9
#define AUTHPRIV_SECURITY 10
#define FTP_DAEMON 11
#define NTP_SUBSYSTEM 12
#define LOG_AUDIT 13
#define LOG_ALERT 14
#define CLOCK_DAEMON 15
#define RESTAPI 16
#define POOLING 17
#define REDISSRV 18
#define COVERAGE 19
#define INTEGRATION 20
#define BILLING 21
#define FILEMANAGER 22
#define LOCAL7 23
#define SGBD_INTERFACE 24

//Level

#define CRITICAL 0
#define ERROR 1
#define WARNING 2 
#define INFORMATIONAL 3
#define DEBUG 4

//
