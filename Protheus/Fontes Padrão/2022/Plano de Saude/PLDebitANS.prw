#INCLUDE "PROTHEUS.CH"
#DEFINE LOGPLS 'debans2020.log'

STATIC CONCCHAR := IIF( AllTrim( TCGetDB() ) $ "ORACLE/DB2" , '||', '+')

//-----------------------------------------------------------------
/*/{Protheus.doc} PLDebitANS
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Class PLDebitANS

    Data lSuccess as Boolean
    Data cMesCred as String
    Data cAnoCred as String
    Data cAliasQuery as string
	Data aParam as Array
	Data cCredReajus  as String
	Data cCredFaixa   as String
	Data cDebitReajus as String
	Data cDebitFaixa  as String
	Data nParcelas    as Integer
	Data lPE001 as Boolean
	Data lPE002 as Boolean

    Method New()
    Method calcDebANS()
    Method getQuery()
	Method procDebit()
	Method getExiBSQ(cAnoMesQry,cCodLan)
	Method grvDebBSQ(cMatric,cCodLan,nVlrParc,aCliente,cAno,cMes)

EndClass



//-----------------------------------------------------------------
/*/{Protheus.doc} New
 Classe Construtora
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method New() Class PLDebitANS

    self:lSuccess    := .T.
    self:cMesCred    := ""
    self:cAnoCred    := ""
    self:cAliasQuery := ''
	self:aParam      := {}
	self:cCredReajus  := ""
	self:cCredFaixa   := ""
	self:cDebitReajus := ""
	self:cDebitFaixa  := ""
	self:nParcelas    := 12
	self:lPE001       := ExistBlock("PLANSD01")
	self:lPE002       := ExistBlock("PLANSD02")

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} calcDebANS
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method calcDebANS(aParam) Class PLDebitANS

    if self:getQuery(aParam)
		
		BA3->(DbSetOrder(1))
		BG9->(DbSetOrder(1))
		BT5->(DbSetOrder(1))
		BQC->(DbSetOrder(1))
		BT6->(DbSetOrder(1))

		while !(self:cAliasQuery)->(Eof())
			self:procDebit()
			(self:cAliasQuery)->(DbSkip())
    	endDo

	else
		MsgInfo("Não foram encontrados registros para os parâmetros informados.")
	endIf

	if self:lSuccess
		(self:cAliasQuery)->(dbCloseArea())
    endif

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} getQuery
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method getQuery() Class PLDebitANS

	Local cSql := ''
	Local nVerCon := Tamsx3("BSQ_VERCON")[1]
	Local nSubCon := Tamsx3("BSQ_SUBCON")[1]
	Local nVerSub := Tamsx3("BSQ_VERSUB")[1]
	
    self:cAliasQuery := getNextAlias()

	cSql += " SELECT BSQ_USUARI, SUM(BSQ_VALOR) AS VALOR, BSQ_CODLAN, BSQ_CODINT, "
	cSql += " BSQ_CODEMP, BSQ_CONEMP, BSQ_VERCON, BSQ_SUBCON, BSQ_VERSUB, "
	cSql += " BSQ_TIPEMP "
	
	cSql += " FROM " + RetSqlName("BSQ")	
	cSql += " WHERE BSQ_FILIAL = '"+xFilial("BSQ")+"' " 
	cSql += " AND BSQ_CODINT = '"+self:aParam[1]+"' "
	cSql += " AND BSQ_CODEMP BETWEEN '"+self:aParam[3]+"' AND '"+self:aParam[4]+"' "
	cSql += " AND BSQ_CONEMP BETWEEN '"+self:aParam[5]+"' AND '"+self:aParam[6]+"' "
	cSql += " AND BSQ_VERCON BETWEEN '"+Space(nVerCon)+"' AND '"+Replicate('Z',nVerCon)+"' "
	cSql += " AND BSQ_SUBCON BETWEEN '"+Space(nSubCon)+"' AND '"+Replicate('Z',nSubCon)+"' "
	cSql += " AND BSQ_VERSUB BETWEEN '"+Space(nVerSub)+"' AND '"+Replicate('Z',nVerSub)+"' "
	cSql += " AND BSQ_MATRIC BETWEEN '"+self:aParam[7]+"' AND '"+self:aParam[8]+"' "
	cSql += " AND BSQ_TIPEMP = '"+self:aParam[2]+ "' "
	cSql += " AND BSQ_CODLAN IN ('"+self:aParam[9]+"','"+self:aParam[10]+"') "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " GROUP BY BSQ_USUARI, BSQ_CODLAN, BSQ_CODINT, BSQ_CODEMP, "
	cSql += " BSQ_CONEMP, BSQ_VERCON, BSQ_SUBCON, BSQ_VERSUB, BSQ_TIPEMP "

	if self:lPE001
		cSql := ExecBlock("PLANSD01",.F.,.F.,{cSql})
	endIf

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),self:cAliasQuery,.T.,.F.)

    if select(self:cAliasQuery) > 0
        self:lSuccess := (self:cAliasQuery)->(!Eof())
        if !self:lSuccess
            (self:cAliasQuery)->(dbCloseArea())
        endif
	else
		self:lSuccess := .F.
    endif

Return self:lSuccess


//-----------------------------------------------------------------
/*/{Protheus.doc} procDebit
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method procDebit() Class PLDebitANS

	Local nVlrParc   := 0
	Local nX         := 0
	Local aAnoMes    := {}
	Local cMatric    := (self:cAliasQuery)->BSQ_USUARI
	Local cCodLan    := (self:cAliasQuery)->BSQ_CODLAN
	Local cAno       := self:cAnoCred
	Local cMes       := self:cMesCred
	Local cAnoMesQry := ''

	PlsPtuLog('',LOGPLS)
	PlsPtuLog('-----------------------------------------------------',LOGPLS)
	PlsPtuLog('Usuario: ' + cMatric,LOGPLS)
	PlsPtuLog('Processamento: '+Dtos(dDatabase) + " - " + Time(),LOGPLS)
	PlsPtuLog('',LOGPLS)

	if BA3->(DbSeek(xFilial("BA3")+Substr(cMatric,1,14) ))

		//Monta variaveis com Ano/Mes dos debitos que serao gerados
		for nX := 1 to self:nParcelas
			if Val(cMes) > 12
				cMes := "01"
				cAno := cValToChar(Val(cAno)+1)
			endIf
			AADD(aAnoMes,{cAno,cMes})
			cAnoMesQry += iif(nX == 1,"'"+cAno+cMes+"'",",'"+cAno+cMes+"'" )
			cMes := Strzero((Val(cMes)+1),2) //Adiciona um mes
		next

		cCodLan := iif(oCredANS:cCredReajus == (self:cAliasQuery)->BSQ_CODLAN ,self:cDebitReajus ,self:cDebitFaixa)

		nVlrParc := (self:cAliasQuery)->VALOR / self:nParcelas			

		PlsPtuLog('Lancamento credito: ' +  (self:cAliasQuery)->BSQ_CODLAN ,LOGPLS)
		PlsPtuLog('Lancamento debito: ' + cCodLan,LOGPLS)	
		PlsPtuLog('Valor total dos créditos: R$ ' + cValToChar((self:cAliasQuery)->VALOR) ,LOGPLS)
		PlsPtuLog('Valor parcela: ('+cValtoChar(self:nParcelas)+') x R$ ' + cValtoChar(nVlrParc)  ,LOGPLS)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,self:getExiBSQ(cAnoMesQry,cCodLan)),"TRBBSQ",.F.,.T.)

		if TRBBSQ->(Eof())

			BG9->(DbSeek(xFilial("BG9")+BA3->BA3_CODINT+BA3->BA3_CODEMP))
			BT5->(DbSeek(xFilial("BT5")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON))
			BQC->(DbSeek(xFilial("BQC")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB))
			BT6->(DbSeek(xFilial("BT6")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB+BA3->BA3_CODPLA+BA3->BA3_VERSAO))

			aCliente := PLS770NIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,;
											BA3->BA3_MATRIC,If(BA3->BA3_TIPOUS=="1","F","J"),;
											BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,;
											BA3->BA3_VERSUB,1)
			
			PlsPtuLog('',LOGPLS)
			//Gera os debitos
			for nX := 1 to len(aAnoMes)
				if nX == len(aAnoMes) .And. nX > 1
					nVlrParc := (self:cAliasQuery)->VALOR - (BSQ->BSQ_VALOR * (nX-1))
				endIf
				self:grvDebBSQ(cMatric,cCodLan,nVlrParc,aCliente,aAnoMes[nX,1],aAnoMes[nX,2])
			next
		else
			PlsPtuLog('Nao foi possivel criar o Credito, pois o mesmo ja existe na BSQ para o Ano/Mes selecionados: '+TRBBSQ->BSQ_CODSEQ,LOGPLS)
		endIf

		TRBBSQ->(dbCloseArea())
	else
		PlsPtuLog('Nao foi possivel encontrar a familia : '+cMatric,LOGPLS)
	endIf

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} getExiBSQ
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method getExiBSQ(cAnoMesQry,cCodLan) Class PLDebitANS

	Local cSql := ''
	Local cMatric := (self:cAliasQuery)->BSQ_USUARI
	Local cCODINT := (self:cAliasQuery)->BSQ_CODINT
	Local cCODEMP := (self:cAliasQuery)->BSQ_CODEMP
	Local cCONEMP := (self:cAliasQuery)->BSQ_CONEMP
	Local cVERCON := (self:cAliasQuery)->BSQ_VERCON
	Local cSUBCON := (self:cAliasQuery)->BSQ_SUBCON
	Local cVERSUB := (self:cAliasQuery)->BSQ_VERSUB
	
	cSql += " SELECT BSQ_CODSEQ FROM " + RetSqlName("BSQ")
	cSql += " WHERE BSQ_FILIAL = '"+xFilial("BSQ")+"' "
	cSql += " AND BSQ_USUARI = '"+cMatric+"' "
	cSql += " AND BSQ_CONEMP = '"+cCONEMP+"' "
	cSql += " AND BSQ_VERCON = '"+cVERCON+"' "
	cSql += " AND BSQ_SUBCON = '"+cSUBCON+"' "
	cSql += " AND BSQ_VERSUB = '"+cVERSUB+"' "
	cSql += " AND BSQ_ANO "+CONCCHAR+" BSQ_MES IN ("+cAnoMesQry+") "
	cSql += " AND BSQ_CODINT = '"+cCODINT+"' "
	cSql += " AND BSQ_CODEMP = '"+cCODEMP+"' "
	cSql += " AND BSQ_CODLAN = '"+cCodLan+"' "
	cSql += " AND D_E_L_E_T_ = ' ' "

	if self:lPE002
		cSql := ExecBlock("PLANSD02",.F.,.F.,{cSql})
	endIf

Return cSql


//-----------------------------------------------------------------
/*/{Protheus.doc} grvDebBSQ
 
 Grava os registros de debito na BSQ 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method grvDebBSQ(cMatric,cCodLan,nVlrParc,aCliente,cAno,cMes) Class PLDebitANS

	Local cNumBSQ := PLSA625Cd("BSQ_CODSEQ","BSQ",1,"D_E_L_E_T_"," ")

	BSQ->(recLock("BSQ",.T.))
	BSQ->BSQ_FILIAL := xFilial('BSQ')
	BSQ->BSQ_CODSEQ := cNumBSQ
	BSQ->BSQ_USUARI := cMatric
	BSQ->BSQ_CODINT := BA3->BA3_CODINT
	BSQ->BSQ_CODEMP := BA3->BA3_CODEMP
	BSQ->BSQ_CONEMP := BA3->BA3_CONEMP
	BSQ->BSQ_VERCON := BA3->BA3_VERCON
	BSQ->BSQ_SUBCON := BA3->BA3_SUBCON
	BSQ->BSQ_VERSUB := BA3->BA3_VERSUB
	BSQ->BSQ_MATRIC := BA3->BA3_MATRIC
	BSQ->BSQ_ANO    := cAno
	BSQ->BSQ_MES    := cMes
	BSQ->BSQ_CODLAN := cCodLan
	BSQ->BSQ_VALOR  := nVlrParc
	BSQ->BSQ_TIPO   := '1' //Debito
	BSQ->BSQ_AUTOMA := '1'
	BSQ->BSQ_COBNIV := iif(len(aCliente)> 0,aCliente[1][18],'') 
	BSQ->BSQ_ATOCOO := '0'
	BSQ->BSQ_TIPPE  := IIF(BA3->BA3_TIPOUS=='1','F',IIF(BA3->BA3_TIPOUS=='2','J','A'))
	BSQ->BSQ_TIPEMP := BG9->BG9_TIPO
				
	BSQ->(msUnLock())
	PlsPtuLog('Credito '+cNumBSQ+ ' gerado com sucesso. Ano: '+cAno+" - Mes: "+cMes+" - Valor R$ "+cValtoChar(BSQ->BSQ_VALOR) ,LOGPLS)

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} PLDebitPar
 Chamada inicial

@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Main Function PLDebitPar(lAuto,aParam)

	Local aParamBox		:= {}
	Local cTitulo       :="Gerar Débitos Reajuste ANS 2020"  
	Local lCentered     := .T.	
	Local aTipoPes		:= {"1=Pessoa Fisica","2=Juridica"}
	Local aMes          := {"01=Janeiro",;
							"02=Fevereiro",;
							"03=Marco",;
							"04=Abril",;
							"05=Maio",;
							"06=Junho",;
							"07=Julho",;
							"08=Agosto",;
							"09=Setembro",;
							"10=Outubro",;
							"11=Novembro",;
							"12=Dezembro"}

	Default lAuto	:= .F.
	Default aParam      := {}

	if !lAuto
		aAdd(aParamBox, {1, "Operadora"		    	, Space(Tamsx3("BDC_CODOPE")[1])			,"@!"					, "", "B89PLS"	, "", 50, .T.} )
		aAdd(aParamBox, {2, "Tipo"																						,""	,aTipoPes 	, 60, "", .T.} )
    	aAdd(aParamBox, {1, "Empresa De"			, Space(Tamsx3("BA3_CODEMP")[1])			,"@!"					, "", "B7APLS"	, "", 50, .F.} )
		aAdd(aParamBox, {1, "Empresa Até"			, Replicate("Z",Tamsx3("BA3_CODEMP")[1])	,"@!"					, "", "B7APLS"	, "", 50, .F.} )
		aAdd(aParamBox, {1, "Contrato De"			, Space(Tamsx3("BA3_CONEMP")[1])			,"@!"					, "", ""	    , "", 50, .F.} )
		aAdd(aParamBox, {1, "Contrato Até"			, Replicate("Z",Tamsx3("BA3_CONEMP")[1])	,"@!"					, "", ""    	, "", 50, .F.} )
		aAdd(aParamBox, {1, "Matricula De"			, Space(Tamsx3("BA3_MATRIC")[1])			,"@!"					, "", ""		, "", 50, .F.} )
		aAdd(aParamBox, {1, "Matricula Até"			, Replicate("Z",Tamsx3("BA3_MATRIC")[1])	,"@!"					, "", ""		, "", 50, .F.} )
		aAdd(aParamBox, {1, "Lanc.Credito Reajuste" , Space(Tamsx3("BSQ_CODLAN")[1])			,"@!"					, "", "BSPPLS"	, "", 50, .T.} ) 
		aAdd(aParamBox, {1, "Lanc.Credito Faixa"	, Space(Tamsx3("BSQ_CODLAN")[1])			,"@!"					, "", "BSPPLS"	, "", 50, .T.} )
    	aAdd(aParamBox, {1, "Lanc.Debito Reajuste"  , Space(Tamsx3("BSQ_CODLAN")[1])			,"@!"					, "", "BSPPLS"	, "", 50, .T.} ) 
		aAdd(aParamBox, {1, "Lanc.Debito Faixa"		, Space(Tamsx3("BSQ_CODLAN")[1])			,"@!"					, "", "BSPPLS"	, "", 50, .T.} )
		aAdd(aParamBox, {2, "Mes Inicial Debito"																		,""	,aMes 	    , 60, "", .T.} ) //aAdd(aParamBox, {1, "Mes Inicial Cred:"  	, Space(Tamsx3("BDC_MESINI")[1])			,"@!"					, "", ""		, "", 50, .T.} )
		aAdd(aParamBox, {1, "Ano Inicial Debito"	, Space(Tamsx3("BDC_ANOINI")[1])			,"@!"					, "", ""		, "", 50, .T.} ) 	
		aAdd(aParamBox, {1, "Qtde. Parcelas"		, 12                                        ,"@ER 99"               ,"Positivo()", "", ".T.", 50, .T.})
	endIf

	if lAuto .Or. ParamBox(aParamBox, cTitulo,@aParam ,,, lCentered,,, /*oMainDlg */, , , )

        oCredANS  := PLDebitANS():New()
		oCredANS:cCredReajus  := aParam[09]
		oCredANS:cCredFaixa   := aParam[10]
		oCredANS:cDebitReajus := aParam[11]
		oCredANS:cDebitFaixa  := aParam[12]
		oCredANS:cMesCred     := aParam[13]
   		oCredANS:cAnoCred     := aParam[14]
		oCredANS:nParcelas    := aParam[15]
		oCredANS:aParam       := aParam

		iif(!lAuto,Processa({|| oCredANS:calcDebANS() }, "Processando familias","Processando....",.T.), oCredANS:calcDebANS() )
		iif(!lAuto,MsgInfo("Processamento finalizado."),Conout("Processamento finalizado."))
		
	endIf

Return