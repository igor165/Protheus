#include 'totvs.ch'
#DEFINE ARQUIVO_LOG "sintetiza_beneficiario_sip.log"
#DEFINE JOB_PROCES "1"
#DEFINE JOB_AGUARD "2"
#DEFINE JOB_CONCLU "3"
#DEFINE MV_PLCENDB	GetNewPar("MV_PLCENDB",.F.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSSNTBENE

Funcao criada para Sintetizar as Despesas na tabela XML_SIP(B3M)
Função que deve ser utilizada para criação do Schedule de entetização

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSSNTBENE()
	PRIVATE __cError := ""
	PRIVATE __cCallStk := ""

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSBENESNT

Funcao criada para Sintetizar as Despesas na tabela XML_SIP(B3M) pelo menu

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSBENESNT(cCodComp,cTipo)
	Local lRet := .F.
	PRIVATE __cError := ""
	PRIVATE __cCallStk := ""
	Default cCodComp	:= ""
	Default cTipo		:= "1"

	If cTipo <> "1"
		MsgInfo("Selecione um compromisso de uma obrigacao do tipo SIP!")
	Else
		lRet := SintetizaBenef(cCodComp)
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SintetizaBenef

Funcao de sintetização de beneficiários no NIO

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SintetizaBenef(cCodComp)
	Local cSeg		    := ""
	Local cItem		    := ""
	Local nArquivo	    := 0 //handle do arquivo/semaforo
	Local nRegPro	    := 0 //Contador de registros processados
	Local aArea		    := GetArea()
	Local lRet		    := .F.
	Local cCodOpe	    := ""
	Local cTriRec	    := ""
	Local cSazona	    := ""
	Local aTriOco	    := {}
	Local cEstado	    := ""
	Local nThread	    := 0
	Local nQuinzena	    := 1
	Local nRegSel	    := 0
	Local cNomJob	    := ""
	Local cDesJob	    := ""
	Local cDatExe	    := ""
	Local cHorExe	    := ""
	Local lMV_PLCENDB	:= MV_PLCENDB
	Local cClas         :=""
	Local nI            := 0
	Default cCodComp    := ''

	PlsLogFil(CENDTHRL("I") + "Sintetiza beneficiario inicio",ARQUIVO_LOG)

	If CarregaCompromisso(cCodComp)

		B3M->(DbSetOrder(1))
		B3K->(DbSetOrder(1))
		BA0->(DbSetOrder(5))

		If BA0->(dbSeek(xFilial("BA0")+TRBCOM->B3D_CODOPE))
			cEstado:= BA0->BA0_EST
		EndIf

		cCodOpe	:= TRBCOM->B3D_CODOPE
		cCodObr := TRBCOM->B3D_CDOBRI
		cAnoCmp := TRBCOM->B3D_ANO
		cCodCmp := TRBCOM->B3D_CODIGO
		cTriRec	:= TRBCOM->B3D_ANO + SubStr(TRBCOM->B3D_CODIGO,2,2)
		cNomJob := CENNOMJOB(nThread,nQuinzena,"SNTBENSIP",.F.)[1]
		cDesJob := CENNOMJOB(nThread,nQuinzena,"SNTBENSIP",.F.)[2]

		cDatExe := DTOS(dDataBase)
		cHorExe	:= Time()
		cObs := "Iniciando sintetização de beneficiários"
		CENMANTB3V(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_AGUARD,,lMV_PLCENDB)

		PlsAtuMonitor("PLSSNTBENE")

		While !TRBCOM->(Eof())
			B3D->(DbGoto(TRBCOM->RECNO))
			cComp := TRBCOM->(B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO)
			PlsAtuMonitor("PLSSNTBENE: Compromisso=" + cComp)
			//abrir semaforo
			nArquivo := Semaforo('A',0, cComp)

			//bBlock := ErrorBlock( { |e| ChecErro(e) } )
			//BEGIN SEQUENCE

			If nArquivo > 0

				//Carrega os dados dos beneficiários
				If CarregaBenef()

					While !TRBBEN->(Eof())
						cItem	:= PADR(AllTrim(TRBBEN->B3O_ITEM),tamSX3("B3M_ITEM")[1])

						lRet := .T.
						nRegPro++
						//B3M_FILIAL+B3M_CODOPE+B3M_SAZONA+B3M_TRIREC+B3M_TRIOCO+B3M_UF+B3M_ITEM+B3M_FORCON+B3M_SEGMEN
						cCodOpe	:= TRBCOM->B3D_CODOPE
						cSazona	:= TRBCOM->B3A_SZNLDD
						cTriRec	:= TRBCOM->B3D_ANO + SubStr(TRBCOM->B3D_CODIGO,2,2)
						cTipCon	:= TRBBEN->B3J_FORCON
						cSeg	:= AjustaSeg(cItem)

						aTrioco	:= CarTriOco(TRBCOM->B3D_CODOPE,cTipCon,cSeg,cEstado,cItem,cTriRec)

						If !(Alltrim(cItem)) == "A"

							If nRegPro % 1000 == 0 .Or. nRegPro == 1
								PlsAtuMonitor("PLSSNTBENE: " + cCodOpe+cTipCon+cSeg+cEstado+cItem+cTriRec)
								cObs := AllTrim(Str(nRegPro)) + " registros processados de " + AllTrim(Str(nRegSel)) + " lidos"
								CENMANTB3V(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
							EndIf

							For nI:=1 to Len(aTrioco)

								If Alltrim(cItem) <> "C14"  .And. Alltrim(cItem) <> "C3"

									If  !(SubStr(cItem,1,2)+cTipCon+aTrioco[nI,1]+aTrioco[nI,2]) $ cClas .And. Len(Alltrim(citem)) < 3

									cClas += SubStr(cItem,1,2) + cTipCon + aTrioco[nI,1] + aTrioco[nI,2] +"/"
									lInclui := !ExisteB3M(cCodOpe,cSazona,cTriRec,aTrioco[nI,1],aTrioco[nI,2],SubStr(cItem,1,1),cTipCon,cSeg)
									GravaB3M(lInclui,cCodOpe,TRBCOM->B3A_SZNLDD,cTipCon,cSeg,aTrioco[nI,2],SubStr(cItem,1,1),cTriRec,aTrioco[nI,1],int(TRBBEN->QTDEZZZ))

								EndIf

								EndIf

								If Len(Alltrim(cItem))>1
									lInclui := !ExisteB3M(cCodOpe,cSazona,cTriRec,aTrioco[nI,1],aTrioco[nI,2],cItem,cTipCon,cSeg)
									GravaB3M(lInclui,cCodOpe,TRBCOM->B3A_SZNLDD,cTipCon,cSeg,aTrioco[nI,2],cItem,cTriRec,aTrioco[nI,1],int(TRBBEN->QTDEZZZ))
								EndIf

								If Len(Alltrim(cItem))>1 .And. ("E" $ Alltrim(citem))  //vou verificar se será necessário atualizar o cabeçalho da internação caso este valor seja maior

									lInclui := !ExisteB3M(cCodOpe,cSazona,cTriRec,aTrioco[nI,1],aTrioco[nI,2],"E",cTipCon,cSeg)
									If !lInclui
										GravaB3M(lInclui,cCodOpe,TRBCOM->B3A_SZNLDD,cTipCon,cSeg,aTrioco[nI,2],"E",cTriRec,aTrioco[nI,1],int(TRBBEN->QTDEZZZ))
									Endif
								EndIf

							Next nI

						EndIf

						TRBBEN->(DbSkip())

					EndDo

					//Informa que a carência foi sintetizada
					If B3D->B3D_SNTBEN <> '2'
						Reclock("B3D",.F.)
						B3D->B3D_SNTBEN 	:= '2'
						B3D->(MsUnlock())
					EndIf

				EndIf

				TRBBEN->(dbCloseArea())

			EndIf

			nArquivo := Semaforo('F',nArquivo,cComp)
			TRBCOM->(DbSkip())

		EndDo

		cObs := cNomJob + " concluído!"
		CENMANTB3V(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)

	EndIf

	TRBCOM->(dbCloseArea())
	MsUnlockAll()
	RestArea(aArea)

	PlsLogFil(CENDTHRL("I") + "Sintetiza beneficiario termino",ARQUIVO_LOG)

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChecErro

Funcao criada para capturar o erro as variáveis __cError e __cCallStk sao private e precisam ser criadas
na rotina que ira ter o controle SEQUENCE que chama esta funcao

@param e		Referencia ao erro
@param nThread	Numero da thread em execucao

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
STATIC FUNCTION ChecErro(e)

	__cError := e:Description
	__cCallStk := e:ErrorStack

	BREAK

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PObrInErro

Funcao criada para incluir registros na tabela de erros da Central de Obrigacoes

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PObrInErro()
	//Função desativa pois não atende atende a boa pratica de usar recno como chave
	//Esta é uma prática frágil. Existem situações em que o recno pode ser renumerado
Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Semaforo

Funcao criada para abrir e fechar semaforo em arquivo

@param cOpcao		A-abrir; F-Fechar
@param nArquivo		Handle do arquivo no disco
@param cComp		Codigo do compromisso

@return nArquivo	Handle do arquivo criado o zero quando fechar

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function Semaforo(cOpcao,nArquivo,cComp)
	Local cArquivo		:= 'sintet_benef_sip_'+ cComp +'.smf'
	Default nArquivo	:= 0
	Default cOpcao		:= 'A'

	Do Case

		Case cOpcao == 'A' //Vou criar/abrir o semaforo/arquivo

			nArquivo := FOPEN(cArquivo,2)
			if nArquivo = -1
				nArquivo := FCreate(cArquivo,0)
			EndIf

		Case cOpcao == 'F' //Vou apagar/fechar o semaforo/arquivo

			If FClose(nArquivo)
				nArquivo := 0
			EndIf

	EndCase

Return nArquivo
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaCompromisso

Verifica se um beneficiario ja se encontra cadastrado na tabela B3K

@param cCodComp		Chave do compromisso

@return lRet		Retorna .T. se o beneficiario ja existe, senao retorna .F.

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaCompromisso(cCodComp)
	Local lRet	:= .T.
	Local cSql	:= ""

	cSql := " SELECT "
	cSql += "	B3D_CODOPE, B3D_CDOBRI, B3D_ANO, B3D_CODIGO, B3A_SZNLDD," + RetSqlName('B3D') + ".R_E_C_N_O_ RECNO "
	cSql += " FROM "
	cSql += "	" + RetSqlName('B3D') + ", " + RetSqlName('B3A')//compromisso, obrigacoes
	cSql += " WHERE "
	cSql += "	B3A_FILIAL = '" + xFilial('B3A') + "' "
	cSql += "	AND B3D_FILIAL = '" + xFilial('B3D') + "' "
	cSql += "	AND B3D_CODOPE = B3A_CODOPE "
	cSql += "	AND B3D_CDOBRI = B3A_CODIGO "
	cSql += "	AND B3D_TIPOBR = '1' "
	cSql += "	AND B3D_STATUS <= '3' "
	cSql += "	AND " + RetSqlName('B3D') + ".D_E_L_E_T_ = ' ' "

	//Verifico se deve ser processado um compromisso específico
	If !Empty(cCodComp)
		cSql += "	AND B3D_CODOPE || B3D_CDOBRI || B3D_ANO || B3D_CODIGO = '" + cCodComp + "' "
	EndIf

	cSql += " ORDER BY "
	cSql += "	B3D_CODOPE, B3D_CDOBRI, B3D_ANO, B3D_CODIGO, B3D_VCTO "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCOM",.F.,.T.)
	lRet := !TRBCOM->(Eof())

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaBenef

Funcao criada para carregar a quantidade de dias coberto por item, contratacao e segmentacao por beneficiario valido

@return lRet	Retorna .T. se encontrou registros , senao .F.

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaBenef()
	Local lRet	:= .T.
	Local cSql	:= ""

	cSql := " SELECT "
	cSql += "	B3O_ITEM, B3J_FORCON, "
	If AllTrim( TCGetDB() ) == "ORACLE"
		cSql += "	SUM(TO_NUMBER(B3O_DIACOB,'999999999.999')) / 90 QTDEZZZ "
	ElseIf AllTrim( TCGetDB() ) == "POSTGRES"
		cSql += "	SUM(B3O_DIACOB) / 90 QTDEZZZ "
	Else
		cSql += "	SUM(convert(NUMERIC(9,3),B3O_DIACOB)) / 90 QTDEZZZ "
	EndIf
	cSql += " FROM "
	cSql += " " + RetSqlName('B3O') + ", "
	cSql += " " + RetSqlName('B3K') + ", "
	cSql += " " + RetSqlName('B3J') + " "
	cSql += " WHERE "
	cSql += " 	  B3O_FILIAL = '" + xFilial('B3O') + "' "
	cSql += "     AND B3J_FILIAL = '" + xFilial('B3J') + "' "
	cSql += "     AND B3K_FILIAL = '" + xFilial('B3K') + "' "
	cSql += "     AND B3O_CODOPE = B3K_CODOPE "
	cSql += "     AND B3O_MATRIC = B3K_MATRIC "
	cSql += "     AND B3J_CODOPE = B3K_CODOPE "
	cSql += "     AND B3J_CODIGO = B3K_CODPRO "
	cSql += "     AND B3K_STATUS = '2' "
	cSql += "     AND B3O_CODOPE = '" + TRBCOM->B3D_CODOPE + "' "
	cSql += "     AND B3O_CDOBRI = '" + TRBCOM->B3D_CDOBRI + "' "
	cSql += "     AND B3O_ANO  = '" + TRBCOM->B3D_ANO + "' "
	cSql += "     AND B3O_CDCOMP = '" + TRBCOM->B3D_CODIGO + "' "
	cSql += "     AND " + RetSqlName('B3O') + ".D_E_L_E_T_ = ' ' "
	cSql += "     AND " + RetSqlName('B3J') + ".D_E_L_E_T_ = ' ' "
	cSql += "     AND " + RetSqlName('B3K') + ".D_E_L_E_T_ = ' ' "
	cSql += " GROUP BY "
	cSql += "     B3O_ITEM, B3J_FORCON ORDER BY B3O_ITEM, B3J_FORCON "

	cSql := ChangeQuery(cSql)
	PlsLogFil(CENDTHRL("I") + cSql,ARQUIVO_LOG)

	PlsLogFil(CENDTHRL("I") + "Query inicio",ARQUIVO_LOG)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBEN",.F.,.T.)
	PlsLogFil(CENDTHRL("I") + "Query termino",ARQUIVO_LOG)

	If !TRBBEN->(Eof())
		lRet := .T.
		PlsLogFil(CENDTHRL("I") + " Encontrou beneficiarios",ARQUIVO_LOG)
	Else
		lRet := .F.
		PlsLogFil(CENDTHRL("I") + " Nao encontrou beneficiarios",ARQUIVO_LOG)
	EndIf

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SchedDef

Funcao criada para definir o pergunte do schedule

@return aParam		Parametros para a pergunta do schedule

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SchedDef()
	Local aOrdem := {}
	Local aParam := {}

	aParam := { "P","SIPSDE",,aOrdem,""}

Return aParam
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlsAtuMonitor

Funcao criada para atualizar mensagem de observacao no servidor

@param nQtdeReg		Quantidade de registros processados
@param cMsg			Mensagem informativa

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function PlsAtuMonitor(cMsg)
	Default cMsg	:= ""

	PtInternal(1,AllTrim(cMsg))

Return Nil

Static Function ExisteB3M(cCodOpe,cSazona,cTriRec,cTriOco,cEstado,cItem,cTipCon,cSeg)
	Local lRetorno		:= .F.
	Local cSql			:= ''

	cSql := " SELECT R_E_C_N_O_ RECB3M "
	cSql += " FROM " + RETSQLNAME('B3M') + " "
	cSql += " WHERE "
	cSql += "     B3M_FILIAL = '" + XFILIAL('B3M') + "' "
	cSql += "     AND B3M_CODOPE = '" + cCodOpe + "' "
	cSql += "     AND B3M_SAZONA = '" + cSazona + "' "
	cSql += "     AND B3M_TRIREC = '" + cTriRec + "' "
	cSql += "     AND B3M_TRIOCO = '" + cTriOco + "' "
	cSql += "     AND B3M_UF = '" + cEstado + "' "
	cSql += "     AND B3M_ITEM = '" + citem + "' "
	cSql += "     AND B3M_FORCON = '" + ctipcon + "' "
	cSql += "     AND B3M_SEGMEN = '" + cSeg + "' "
	cSql += "     AND D_E_L_E_T_ = ' '"

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB3M",.F.,.T.)

	lRetorno := !TRBB3M->(Eof())
	If lRetorno
		B3M->(dbGoTo(TRBB3M->RECB3M))
	EndIf

	TRBB3M->(DBCLOSEAREA())

Return lRetorno

Static Function GravaB3M(lInclui,cCodOpe,cSazona,cTipCon,cSeg,cEstado,cItem,cTriRec,cTriOco,nqtdben)
	Default lInclui	:= .T.
	Default cCodOpe	:= '000000'
	Default cSazona	:= '0'
	Default cTipCon	:= '0'
	Default cSeg	:= '0'
	Default cEstado	:= 'XX'
	Default cItem	:= 'X'
	Default cTriRec	:= '000000'
	Default cTriOco	:= '000000'
	Default nqtdben	:= 0

	RecLock("B3M",lInclui)
	B3M->B3M_FILIAL	:= xFilial("B3M")
	B3M->B3M_CODOPE	:= cCodOpe
	B3M->B3M_SAZONA	:= cSazona
	B3M->B3M_FORCON	:= cTipCon
	B3M->B3M_SEGMEN	:= cSeg
	B3M->B3M_UF		:= cEstado
	B3M->B3M_ITEM	:= cItem
	B3M->B3M_TRIREC	:= cTriRec
	B3M->B3M_TRIOCO	:= cTriOco

	If !lInclui
		If B3M->B3M_QTDBEN <= nqtdben
			B3M->B3M_QTDBEN	:= nqtdben
		EndIf
	Else
		B3M->B3M_QTDBEN:= nqtdben
	Endif

	B3M->(MsUnlock())

Return

Static Function CarTriOco(cCodOpe,cForCon,cSegmen,cUF,cItem,cTriRec)
	Local aTrio	   := {}
	Local cSql	   := ""
	Default cForCon:= ""
	Default cCodOpe:= ""
	Default cSegmen:= ""
	Default cItem  := ""
	Default cTriRec:= ""
	Default cUf    := ""

	//B3M_FILIAL+B3M_CODOPE+B3M_FORCON+B3M_SEGMEN+B3M_UF+B3M_ITEM+B3M_TRIREC
	cSql := " SELECT B3M_TRIOCO,B3M_UF FROM " + RetSqlName('B3M') + " "
	cSql += " WHERE "
	cSql += " 	  B3M_FILIAL = '" + xFilial('B3M') + "' "
	cSql += "     AND B3M_CODOPE = '" + cCodOpe + "' "
	cSql += "     AND B3M_FORCON = '" + cForCon + "' "
	cSql += "     AND B3M_SEGMEN = '" + cSegmen + "' "
	cSql += "     AND B3M_ITEM   = '" + cItem + "' "
	cSql += "     AND B3M_TRIREC = '" + cTrirec + "' "
	cSql += " GROUP BY B3M_TRIOCO,B3M_UF "

	cSql := ChangeQuery(cSql)

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBTRI",.F.,.T.)

	While !TRBTRI->(Eof())
		AADD(aTrio,{TRBTRI->B3M_TRIOCO,TRBTRI->B3M_UF})
		TRBTRI->(DbSkip())
	EndDo

	TRBTRI->(dbCloseArea())

	If Len(aTrio)==0
		AADD(aTrio,{cTriRec,cUF})
	EndIf

Return aTrio
