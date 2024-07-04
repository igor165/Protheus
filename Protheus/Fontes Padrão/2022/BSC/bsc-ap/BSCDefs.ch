// ######################################################################################
// Projeto: BSC
// Modulo : Core
// Fonte  : BSCDefs.ch
// -----------+---------------------------+----------------------------------------------
// Data       | Autor                     | Descricao
// -----------+---------------------------+----------------------------------------------
// 07.05.03   | 1728. Fernando Patelli    |
// 22.06.09   | 3510 - Gilmar P. Santos   | Constantes para ProgressBar
//			  |                           | FNC 00000008745/2009
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"

// Tipos de log(cTipo) ao executar TBIBSCCore:Log(cTexto, cTipo)
#define BSC_LOG_SCR		1 
#define BSC_LOG_FILE    2 
#define BSC_LOG_RAISE   3
#define BSC_LOG_SCRFILE 4

// Response Status
#define BSC_ST_OK				0
#define BSC_ST_BADID			1
#define BSC_ST_INUSE			2
#define BSC_ST_UNIQUE			3
#define BSC_ST_NOCMD			4
#define BSC_ST_NOTRANSACTION	5
#define BSC_ST_BADXML			6
#define BSC_ST_NORIGHTS			7
#define BSC_ST_HASCHILD			8
#define BSC_ST_EXPIREDSESSION	9
#define BSC_ST_GENERALERROR		10

// Tipos de dados trafegaveis
#define BSC_BOOLEAN				0
#define BSC_DATE                1
#define BSC_FLOAT               2
#define BSC_INT                 3
#define BSC_STRING              4
#define BSC_PERCENT             5

// Feedback do sistema BSC
#define BSC_FB_GRAY			0
#define BSC_FB_REDDN		1
#define BSC_FB_REDUP		2
#define BSC_FB_REDSM		3
#define BSC_FB_YELLOWDN		4
#define BSC_FB_YELLOWUP		5
#define BSC_FB_YELLOWSM		6
#define BSC_FB_GREENDN		7
#define BSC_FB_GREENUP		8
#define BSC_FB_GREENSM		9
#define BSC_FB_BLUEDN		10
#define BSC_FB_BLUEUP		11
#define BSC_FB_BLUESM		12

// Classe do Data Source
#define BSC_SRC_TOP			1
#define BSC_SRC_ADVPL		2
#define BSC_SRC_DW			3
#define BSC_SRC_FORMULA		4

// Configuracao do Data Source para TopConnect
#define BSC_SRC_ENVIRONMENT		1
#define BSC_SRC_CUSTOM			2

// Tipo de Planilha de Indicador
#define BSC_PLAN_INDICADOR	1     
#define BSC_PLAN_REFERENCIA	2

// Frequencias
#define BSC_FREQ_ANUAL			1
#define BSC_FREQ_SEMESTRAL		2
#define BSC_FREQ_QUADRIMESTRAL	9
#define BSC_FREQ_TRIMESTRAL		3
#define BSC_FREQ_BIMESTRAL		4
#define BSC_FREQ_MENSAL			5
#define BSC_FREQ_QUINZENAL		6
#define BSC_FREQ_SEMANAL		7
#define BSC_FREQ_DIARIA			8

// Montante
#define BSC_MT_SUM				0
#define BSC_MT_AVG				1
#define BSC_MT_EDT				2

// Segurança
#define BSC_SEC_ARQUITETURA		1
#define BSC_SEC_REUNIOES		2
#define BSC_SEC_PESSOAS         3
#define BSC_SEC_PAINEIS         4
#define BSC_SEC_RELATORIOS      5
#define BSC_SEC_GRAFICOS        6
#define BSC_SEC_METAS           7
#define BSC_SEC_AVALIACOES      8
#define BSC_SEC_PLANILHAS       9
#define BSC_SEC_FONTEDADOS      0
#define BSC_SEC_DOCUMENTOS     11
#define BSC_SEC_TAREFAS        12
#define BSC_SEC_RETORNOS       13
#define BSC_SEC_NUMEROS        14
#define BSC_SEC_CORES          15
#define BSC_SEC_ACESSOORG      16
#define BSC_SEC_ACESSOEST      17
#define BSC_SEC_ACESSAORG      18

// Mensagens
#define BSC_MSG_ENVIADA			 1
#define BSC_MSG_RECEBIDA		 2
#define BSC_MSG_EXCLUIDA     	 3
#define BSC_MSG_DESCARTADA   	 4
#define BSC_MSG_ALTA		   	 1
#define BSC_MSG_MEDIA		   	 2
#define BSC_MSG_BAIXA		   	 3
#define BSC_MSG_REMETENTE   	 1
#define BSC_MSG_DESTINATARIO  	 2
#define BSC_MSG_PARA  			 1
#define BSC_MSG_CC				 2

// Constantes para uso do ProgressBar
#define PROGRESS_BAR_ERROR		-1
#define PROGRESS_BAR_OK			0
#define PROGRESS_BAR_END		1

// Tipos de Fonte de Dados - Resultado, Referência e Metas
#define DTSRC_RESULT 			"resultado"
#define DTSRC_REFER				"referencia"
#define DTSRC_METAS				"valormetas"