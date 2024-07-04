#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPWSINIT.CH"

/*--------------------------------------------------------------------------------------------------//
//Programa:		PCPWSInit
//Autor:		Juliana de Oliveira
//Data:			01/03/2021
//Descricao:	Função responsável por iniciar o ambiente no WS e retornar o array com as informações.
//--------------------------------------------------------------------------------------------------*/

Function PCPWSInit()
	Local aPrepareIn
	Local cEnvSource
	Local cMsgIni := ""
	Local lReturn := .T.
	
	If Type("cEmpAnt")=="U"
		cPrepareIn := GetPvProfString(GetWebJob() , "PCPPREPAREIN" , "ERROR" , GetAdv97() )
		aPreparein := StrTokArr(cPreparein,",")

		IF aPreparein[1] == "ERROR"
			cMsgIni := STR0006 + " [PCPPREPAREIN] " + STR0007 + " ["+GetWebJob()+"] " + STR0008 + " ["+GetAdv97()+"] " //Chave //não encontrada na seção //do arquivo de configuração
			lReturn := .F.
		EndIf

		if lReturn
			SetsDefault()
			// Armazena em memória que o ambiente foi carregado pelo PCPPREPAREIN (Não consome licença)
			PutGlbValue("PCP_WS", "PCPPREPAREIN")
			RpcsetType(3)
			If RpcSetEnv(aPrepareIn[1],aPrepareIn[2])
				SetModulo("SIGAPCP","PCP")
				LogMsg('PCPWSInit', 14, 4, 1, '', '', STR0001) //"Instância do WebService para uso padrão."
			Else
				cMsgIni := STR0003 //"PCP - Falha inicialização ambiente - OpenSM0"
				lReturn := .F.
			EndIf
		EndIf
	Else
		cEnvSource := GetGlbValue("PCP_WS")
		// Verifica qual a origem de carregamento do ambiente PREPAREIN ou PCPPREPAREIN
		If Empty(cEnvSource)
			cPrepareIn := GetPvProfString(GetWebJob() , "PCPPREPAREIN" , "" , GetAdv97() )
			If Empty(cPrepareIn)
				PutGlbValue("PCP_WS", "PREPAREIN")
				LogMsg('PCPWSInit', 14, 4, 1, '', '', STR0002) //"Instância do WebService para uso de métodos customizado."
			Else
				PutGlbValue("PCP_WS", "PCPPREPAREIN")
				LogMsg('PCPWSInit', 14, 4, 1, '', '', STR0001) //"Instância do WebService para uso padrão."
			EndIf
		EndIF
	EndIf
	
	If !lReturn
		LogMsg('PCPWSInit', 14, 4, 1, '', '', STR0004 + STR0005 + cMsgIni + " ") //"[WSEXECTEQUERY.PCPWSInit]" + "Falha na inicialização do ambiente. Motivo:" 
	EndIf

Return {lReturn,cMsgIni}
