#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA095.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA095
Rotina de transmissão de GNRE Online via Web Service

@author Simone Oliveira
@since 24.06.2015
@version 11.80

/*/
//-------------------------------------------------------------------
function FISA095()

	local aArea       := GetArea()
	local lRetorno    := .T.
	local lOk         := .F.
	Local lTSS        := .F.
	Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

	private aFilBrw   := {}
	private cURL      := Padr(GetNewPar("MV_SPEDURL","http://"),250)
	private cInscMun  := Alltrim(SM0->M0_INSCM)
	private cIdEnt    := FSA095IDEnt()
	private cVerTss   := ""
	private lBtnFiltro:= .F.
	private oWS       := Nil
	private oRetorno  := Nil
	private oXml      := Nil


//Realiza Conexão com TSS

	If lVerpesssen
		oWs:= WsSpedCfgNFe():New()
		oWs:cUSERTOKEN      := "TOTVS"
		oWs:cID_ENT         := cIdEnt
		oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		lOk                 := oWs:CfgTSSVersao()

		if lOk
			cVerTss := oWs:cCfgTSSVersaoResult
			lTss:= ( substr(cVerTss,1,2) == '12' .and. cVerTss >= "12.1.007" ) .Or. ( substr(cVerTss,1,2) <> '12' .and. cVerTss >= "2.55" ) //tratamento para a versão 11 e 12 do TSS
			If !lTSS
				Alert("Versão do TSS não atende a GNRE via Web Service. Realize a atualização do TSS.")
			endif
		else
			Aviso("GNRE",iif(empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0025},3) //OK
			//Realiza a configuração do Wizard TSS
			FISA095CFG()
			return
		endif

		while lRetorno
			lBtnFiltro:= .F.
			lRetorno := FISA095Brw()
			if !lBtnFiltro
				exit
			endif
		enddo
	EndIf
	RestArea(aArea)
return nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FISA095Brw
Browse Rotina Gnre via Web service

@author Simone Oliveira
@since 24.06.2015
@version 1.0

/*/
//-------------------------------------------------------------------
function FISA095Brw()

	local oBrw			:= FWmBrowse():New()

	local aArea 		:= GetArea()
	local cFiltro		:= ''
	local cFiltroBrw	:= ''
	local lRetorno 		:= .T.
	local lGnreWS		:= SF6->(FieldPos("F6_GNREWS")) > 0
	local lRecibo		:= SF6->(FieldPos("F6_RECIBO")) > 0
	local lAmbiente		:= SF6->(FieldPos("F6_AMBIWS")) > 0
	local lIdTSS		:= SF6->(FieldPos("F6_IDTSS" )) > 0
	local lNumCtr		:= SF6->(FieldPos("F6_NUMCTRL")) > 0
	local lCodBarras	:= SF6->(FieldPos("F6_CDBARRA")) > 0
	local lXMLEnv		:= SF6->(FieldPos("F6_XMLENV" )) > 0

	private cUF	   		:= ''
	private cFilDe  	:= ''
	private cFilAte 	:= ''

//Verifico primeiramente se a base de Dados contém o campo F6_GNREWS (Flag da Gnre Via Web Service).
	dbSelectArea("SF6")
	if !(lGnreWS .And. lRecibo .And. lAmbiente .And. lIdTSS .and. lNumCtr .and. lCodBarras .and. lXMLEnv)
		help("",1,"Help","Help",STR0002,1,0) //Os campos necessários para a correta execução da GNRE via Web Service não existem na base de Dados. Execute o compatibilizador UPDFIS para a criação destes campos.
		return
	endif

//Montagem das perguntas
	If pergunte("FSA095",.T.)
		// Desvio para a rotina de lote
		If AliasIndic("CIB") .And. MV_PAR05 == 2
			FISA214()
			Return
		EndIf
		cDataDe		:= DtoS( MV_PAR01 ) //Data De:
		cDataAte	:= DtoS( MV_PAR02 ) //Data De:
		cFiltro		:= cValtoChar( MV_PAR03 ) //Filtra?# 1 - Sem Filtro # 2 - Transmitidas# 3 - Não Transmitidas #4-Autorizadas #5-Não Autorizadas
		cUF			:= MV_PAR04

		cFiltroBrw :='F6_FILIAL == "' + xFilial('SF6') + '"'
		cFiltroBrw += '.AND. DtoS(F6_DTARREC) >= "'+ cDataDe + '" .AND. DtoS(F6_DTARREC) <= "' + cDataAte + '"'
		cFiltroBrw += '.AND. (F6_TIPOIMP $ "3-B" .OR. (F6_TIPOIMP == "1" .AND. F6_CODREC == "100030")) ' //ICMS ST e DIFAL #FECP DIFAL

		//Filtro
		if cFiltro == "2" 			//"2-Transmitidas"
			cFiltroBrw +=  '.AND. F6_GNREWS $ "T"'
		elseif cFiltro == "3" 		//"3-Não Transmitidas"
			cFiltroBrw += '.AND. F6_GNREWS == " " '
		elseif cFiltro == "4" 		//"4-Autorizadas
			cFiltroBrw += '.AND. F6_GNREWS == "S" '
		elseif cFiltro == "5" 		//"4-Não Autorizadas
			cFiltroBrw += '.AND. F6_GNREWS == "N" '
		endif

		//Uf
		if !empty(cUF)
			cFiltroBrw += '.AND. F6_EST == "' + cUF + '"'
		endif

		oBrw := FWMBrowse():New()
		oBrw:SetAlias( "SF6" )
		oBrw:SetDescription( STR0001+ STR0054 + cIdEnt ) //Guia Nacional do Recolhimento - Web Service### - Entidade:
		oBrw:SetFilterDefault( cFiltroBrw )

		oBrw:AddLegend( "F6_GNREWS==' '", "BLUE"	, "GNRE Não Transmitida" )
		oBrw:AddLegend( "F6_GNREWS=='T'", "YELLOW"	, "GNRE Transmitida"     )
		oBrw:AddLegend( "F6_GNREWS=='S'", "GREEN"	, "GNRE Autorizada"      )
		oBrw:AddLegend( "F6_GNREWS=='N'", "BLACK"	, "GNRE Não Autorizada"  )
		oBrw:SetMenuDef( 'FISA095' )
		oBrw:Activate()

	Endif

	RestArea(aArea)
return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Simone Oliveira
@since 24.06.2015
@version 1.0
/*/
//-------------------------------------------------------------------
static function MenuDef()

	local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.FISA095'	OPERATION 2  ACCESS 0
	ADD OPTION aRotina TITLE 'Ambiente'		ACTION 'Fisa095Amb'			OPERATION 7  ACCESS 0
	ADD OPTION aRotina TITLE 'Transmitir'	ACTION 'Fisa095Trans'		OPERATION 8  ACCESS 0
	ADD OPTION aRotina TITLE 'Wiz. Config.'	ACTION 'Fisa095CFG'			OPERATION 9  ACCESS 0
	ADD OPTION aRotina TITLE 'Monitor'		ACTION 'Fisa095Mnt'			OPERATION 10 ACCESS 0
	ADD OPTION aRotina TITLE 'Inf. Extras'	ACTION 'Fisa095Ext'			OPERATION 11 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'		ACTION 'Fisa095Imp'			OPERATION 11 ACCESS 0

return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Simone Oliveira
@since 24.06.2015
@version 1.0
/*/
//-------------------------------------------------------------------
static function ModelDef()

	local oStru		:= FWFormStruct(1, 'SF6')
	local oModel	:= MPFormModel():New('FISA095')
	local cEntWs	:= FSA095IDEnt()

	oModel	:=	MPFormModel():New('FISA095MOD', ,{ |oModel| ValidForm(oModel) }  )

	oModel:AddFields( 'FISA095MOD' ,, oStru )

	oModel:SetPrimaryKey({"F6_FILIAL"},{"F6_EST"},{"F6_NUMERO"},{"R_E_C_N_O_"},{"D_E_L_E_T_"})

	oModel:SetDescription(STR0001 + STR0054 + cEntWs) //Guia Nacional do Recolhimento - Web Service### - Entidade:

return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Simone Oliveira
@since 24.06.2015
@version 1.0
/*/
//-------------------------------------------------------------------
static function ViewDef()

	local oModel:= FWLoadModel('FISA095')
	local oStru := FWFormStruct(2, 'SF6')
	local oView := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW', oStru, 'FISA095MOD')

	oView:EnableTitleView('VIEW', STR0001+ STR0054 + cIdEnt) //Guia Nacional do Recolhimento - Web Service### - Entidade:
	oView:CreateHorizontalBox('FIELDS', 100)
	oView:SetOwnerView('VIEW', 'FIELDS')

return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa095CFG
Rotina de Configuração do Web Service - GNRE

@author Simone dos Santos de Oliveira
@since 24.06.2015
@version 1.0

/*/
//-------------------------------------------------------------------     
function Fisa095CFG()

	SpedNFeCFG()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA095Trans
Rotina de Transmissão da GNRE WS

@author Simone dos Santos de Oliveira
@since 24.06.2015
@version 1.0

/*/
//-------------------------------------------------------------------     
function Fisa095Trans()

	local oWizard	:= Nil

	local aArea		:= GetArea()
	local aPerg   	:= {}
	local aGNRE		:= {"",""}
	local aParam  	:= { space(len(SF6->F6_NUMERO)) , space(len(SF6->F6_NUMERO)) , space(len(SF6->F6_EST)) }
	local aTexto	:= {"",""}
	local cAmbiente	  := alltrim(GetMV("MV_AMBGNRE",,"2"))
	local cVerGNRE := alltrim(GetMV("MV_GNREVE",,"1.00"))
	local cRetGNRE	:= ""
	local cXML		:= ""
	local cAmbGnre	:= ""
	local cParRem	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"FISA095REM"
	local lOk		:= .F.

	MV_PAR01 := aParam[01] := PadR(ParamLoad(cParRem,aPerg,1,aParam[01]),len(SF6->F6_NUMERO))
	MV_PAR02 := aParam[02] := PadR(ParamLoad(cParRem,aPerg,2,aParam[02]),len(SF6->F6_NUMERO))
	MV_PAR03 := aParam[03] := PadR(ParamLoad(cParRem,aPerg,3,aParam[03]),len(SF6->F6_EST))


	aadd(aPerg,{1,STR0034,aParam[01],"",".T.","",".T.",50,.T.}) //"Número GNRE Inicial:"
	aadd(aPerg,{1,STR0035,aParam[02],"",".T.","",".T.",50,.T.}) //"Número GNRE Final:"
	aadd(aPerg,{1,"Estado",aParam[03],"@!",".T.","12",".T.",50,.T.}) //"Estado:"

	//Apresentação ambiente
	if cAmbiente $ "1"
		cAmbGnre := "1-Produção"
	else
		cAmbGnre := "2-Homologação"
	endif


	// Montagem da Interface  de Transmissão

	aadd(aTexto,{})

	aTexto[1] := STR0026+CRLF
	aTexto[1] += STR0062+CRLF
	aTexto[1] += STR0063+ cAmbGnre + CRLF
	aTexto[1] += STR0066+ cVerGNRE + CRLF

	aadd(aTexto,{})

	DEFINE WIZARD oWizard ;
		TITLE STR0027;
		HEADER STR0019;
		MESSAGE STR0020;
		TEXT aTexto[1] ;
	NEXT {|| .T.} ;
	FINISH {||.T.}

CREATE PANEL oWizard  ;
	HEADER STR0027;
	MESSAGE ""	;
	BACK {|| .T.} ;
	NEXT {|| ParamSave(cParRem,aPerg,"1"),Processa({|lEnd| cRetGNRE := GnreTrans(Alltrim(aParam[1]),Alltrim(aParam[2]),cAmbiente,@lEnd,aParam[3])}),aTexto[02]:= cRetGNRE,.T.} ;
	PANEL
ParamBox(aPerg,STR0055,@aParam,,,,,,oWizard:oMPanel[2],cParRem,.T.,.T.) //"Transmissão de GNRE"


CREATE PANEL oWizard  ;
	HEADER STR0027;
	MESSAGE "";
	BACK {|| .T.} ;
	FINISH {|| .T.} ;
	PANEL
@ 010,010 GET aTexto[02] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]

ACTIVATE WIZARD oWizard CENTERED

RestArea(aArea)
return

//-------------------------------------------------------------------
/*/{Protheus.doc} GnreTrans
Obtem o codigo da entidade apos enviar o post para o Totvs Service SOA

@author Simone dos Santos de Oliveira
@since 24.06.2015
@version 11.80

@param		cGNREIni	Número GNRE inicial
@param		cGNREFim	Número GNRE final
@param		cAmbiente	Ambiente de Transmissão (1-Produção / 2-Homologação)

/*/
//-------------------------------------------------------------------
static function GnreTrans(cGNREIni,cGNREFim,cAmbiente,lEnd,cUFFav)

	local aXML			:= {}
	local aGNRE			:= {}
	local aFieldDt		:= {}
	local aGnreOk		:= {}
	local cRetorno		:= ""
	local cAliasSF6		:= "SF6"
	local cFiltro		:= ""
	local cIndex		:= ""
	local cNumGNRE		:= ""
	local cIdGNRE		:= ""
	local cWhere		:= ""
	local nA			:= 0
	local nX			:= 0
	local nY			:= 0
	local nB			:= 0
	local lIDGUIA		:= SF6->(FieldPos("F6_IDGUIA")) > 0
	Local cNoGuias		:= ""
	local cMVUFGNWS		:= GetNewPar('MV_UFGNWS' ,'') //Apenas as UF's que possuem GNRE Web Service.
	Local cEspaco		:= CHR(10) + CHR(13)
	Local cMsgUF	 		:= ""
	Local cCampos		:= ""
	Local lF6CODAREA 	:= SF6->(FieldPos("F6_CODAREA")) > 0
	Local lF6Vlfund		:= SF6->(FieldPos("F6_VALFUND")) > 0

	default cGNREIni	:= ""
	default cGNREFim	:= ""
	default cAmbiente	:= ""
	default cUFFav	:= ""

	if !(empty(cGNREIni) .and. empty(cGNREFim) .and. empty(cAmbiente))

		dbSelectArea("SF6")
		SF6->(dbSetOrder(1))
		#IFDEF TOP

			if (TcSrvType ()<>"AS/400")
				lQuery    := .T.
				cAliasSF6 := GetNextAlias()

				aadd(aFieldDt,"F6_DTVENC")
				aadd(aFieldDt,"F6_DTPAGTO")

				cCampos := "%"
				If lF6CODAREA
					cCampos += " , F6_CODAREA "
				Endif
				If lF6Vlfund
					cCampos += " ,F6_VALFUND "
				Endif
				cCampos += "%"

				cWhere := "%"
				If !Empty(cUFFav)
					cWhere += " AND SF6.F6_EST = '"+cUFFav+"' "
				Endif
				cWhere += "%"

				//Necessario definir quais os campos necessários na query, por quetões de performance alem de existir campo MEMO F6_XMLENV, inviabilizando usar "SELECT *""
				BeginSql Alias cAliasSF6
				SELECT F6_FILIAL, F6_EST, F6_NUMERO, F6_TIPOIMP, F6_VALOR, F6_INSC, F6_DTARREC, F6_DTVENC, F6_MESREF, F6_ANOREF, F6_NUMCONV, F6_BANCO,
				F6_AGENCIA,F6_CODREC, F6_CLAVENC, F6_OBSERV, F6_DOC, F6_SERIE, F6_CLIFOR, F6_LOJA, F6_OPERNF, F6_TIPODOC, F6_DTPAGTO, F6_CNPJ,
				F6_VENCAUT, F6_DOCOR, F6_REF, F6_ATMON, F6_JUROS, F6_MULTA, F6_INF, F6_CODPROD, F6_AUTENT, F6_ACORDO, F6_NUMPROC, F6_INDPROC,
				F6_DESCOMP, F6_DETRECE, F6_PROCESS, F6_PEDDED, F6_VIMPDED, F6_ISSOR, F6_CODMUN, F6_COBREC, F6_SDOC, F6_RECIBO, F6_GNREWS, F6_IDTSS,
				F6_AMBIWS, F6_CDBARRA, F6_NUMCTRL, F6_FECP, F6_IFCOMP, F6_DTLIMI, F6_IDGUIA, F6_DOCAEST, F6_DOCORIG, F6_TIPOGNU
				%Exp:cCampos%
				FROM
					%Table:SF6% SF6
				WHERE
					SF6.F6_FILIAL=%xFilial:SF6% AND
					SF6.F6_NUMERO >= %Exp:cGnreIni% AND SF6.F6_NUMERO <= %Exp:cGnreFim% AND
					(SF6.F6_TIPOIMP ='3' OR SF6.F6_TIPOIMP ='B' OR (SF6.F6_TIPOIMP ='1' AND SF6.F6_CODREC = '100030')) AND
					SF6.%NotDel%
					%Exp:cWhere%
				EndSql
				for nX := 1 To Len(aFieldDt)
					TcSetField(cAliasSF6,aFieldDt[nX],"D",8,0)
				next nX
			else
			#EndIf
			cIndex  := CriaTrab(NIL,.F.)
			cFiltro := 'F6_FILIAL=="'+xFilial ("SF6")+'".And.'
			cFiltro += 'F6_NUMERO>="'+ cGNREIni +'".And. F6_NUMERO<="'+ cGNREFim +'" '
			cFiltro += '.And. (F6_TIPOIMP =="3" .Or. F6_TIPOIMP =="B" .Or. (F6_TIPOIMP == "1" .And. F6_CODREC == "100030"))'
			cFiltro += '.And. F6_OPERNF =="2" '
			cFiltro += '.And. F6_EST == "'+cUFFav+'" '
			indregua (cAliasSF6, cIndex, SF6->(IndexKey ()),, cFiltro)
			nIndex := retindex(cAliasSF6)
			#IFNDEF TOP
				dbSetIndex(cIndex+OrdBagExt())
			#ENDIF
			dbSelectArea (cAliasSF6)
			dbSetOrder (nIndex+1)
			#IFDEF TOP
			endif
		#EndIf

		dbSelectArea (cAliasSF6)
		(cAliasSF6)->(dbGoTop())

		while !(cAliasSF6)->(eof ()) .And. (xFilial("SF6") == (cAliasSF6)->F6_FILIAL)
			// Não permite enviar guias que estão dentro de um lote
			If lIDGUIA .And. !Empty(AllTrim((cAliasSF6)->F6_IDGUIA))
				cNoGuias += (cAliasSF6)->F6_EST + "/" + (cAliasSF6)->F6_NUMERO + " - LOTE: " + (cAliasSF6)->F6_IDGUIA + cEspaco
				(cAliasSF6)->(dbSkip())
				Loop
			EndIf
			// Não permite transmitir guias para os estados que não estão no parâmetro MV_UFGNWS
			If !(cAliasSF6)->F6_EST $ cMVUFGNWS
				cMsgUF += "Guia: " + (cAliasSF6)->F6_EST + "/" + (cAliasSF6)->F6_NUMERO
				(cAliasSF6)->(dbSkip())
				Loop
			EndIf

			IncProc("(2/2) "+ STR0056 +(cAliasSF6)->F6_NUMERO) //"Transmitindo XML da GNRE: "

			aadd(aXML,{})
			nY := Len(aXML)
			aXML[nY] := ExecBlock("GnreXMLEnv",.F.,.F.,{cAliasSF6})

			(cAliasSF6)->(dbSkip())
		enddo

		if len(aXML) > 0
			dbselectarea('SF6')
			SF6->(dbSetOrder(1))

			//Gravo o Id na tabela SF6
			for nB:= 1 to len( aXML )

				cIdGN     := alltrim( aXML[nB,1] )
				cUFGnre   := left(cIdGN, 2)
				cNumGN    := right(cIdGN, len(cIdGN)-2)
				cXml      := aXML[nB,2]

				if dbSeek(xFilial("SF6")+cUFGnre+cNumGN)
					RecLock("SF6",.F.)
					SF6->F6_IDTSS  := cIdGN
					SF6->F6_XMLENV := cXml
					MsUnlock()
				endif
			next

			//Transmissão da GNRE
			cRetorno := RemessaGnre(cAmbiente, aXML, @aGnreOk )

			//Atualiza o Status da GNRE
			if len( aGnreOk ) > 0
				for nY:=1 to len( aGnreOk )

					cIdGNRE  := alltrim( aGnreOk[nY,1] )
					cUFOk    := left(cIdGNRE, 2)
					cNumGNRE := right(cIdGNRE, len(cIdGNRE)-2)

					if dbSeek(xFilial("SF6")+cUFOk+cNumGNRE)
						RecLock("SF6",.F.)
						SF6->F6_GNREWS := "T"
						SF6->F6_AMBIWS := cAmbiente
						SF6->F6_IDTSS  := cIdGNRE
						MsUnlock()
					endif
				next
			endif
		endif
	endif


	If Len(aGnreOk) == 0
		cRetorno +=  "Foram transmtidas: 0 guias. Verifique os parâmetros de transmissão." + cEspaco
	EndIf
	If !Empty(AllTrim(cMsgUF))
		cRetorno += cEspaco + "As seguintes guias não foram transmitidas por não configuração do parâmetro MV_UFGNWS :  " + cEspaco
		cRetorno += cMsgUF + cEspaco
	EndIf

	If !Empty(AllTrim(cNoGuias))
		cRetorno += cEspaco + "As seguintes guias não foram transmitidas por que estão associadas a um lote:  " + cEspaco
		cRetorno += cNoGuias + cEspaco
		cRetorno += cMsgUF + cEspaco
	EndIf

	#IFDEF TOP
		dbSelectArea(cAliasSF6)
		dbCloseArea()
	#ELSE
		dbSelectArea(cAliasSF6)
		RetIndex(cAliasSF6)
		ferase(nIndex+OrdBagExt())
	#ENDIF


return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} RemessaGnre
Função de Transmissão da GNRE para o TSS

@author Simone dos Santos de Oliveira
@since 24.06.2015
@version 11.80

@param		cAmbiente	Ambiente de Transmissão (1-Produção / 2-Homologação)
@param		aXML 		Array com Informações a serem transmitidas 
@param		aGnreOk	Array com as Gnres transmitidas


/*/
//-------------------------------------------------------------------
static function RemessaGnre(cAmbiente, aXML, aGnreOk )

	local aErroGnre		:= {}
	local cRetorno		:= ""
	local cHoraIni		:= Time()
	local dDataIni		:= date()
	local nX			:= 0
	local nY			:= 0
	local xOk
	Local cVersao	:= GetMv("MV_GNREVE",,"1.00")

	default cAmbiente	:= ""
	default aXML		:= {}
	default aGnreOk		:= {}

	if len( aXML ) > 0
		oWS := WSTSSGNRE():New()
		oWS:cUSERTOKEN:= "TOTVS"
		oWS:cIDENT 	:= cIdEnt
		oWS:cAMBIENTE := cAmbiente
		oWS:cUF		:= cUf
		oWS:cVersao	:= cVersao
		oWS:_URL		:= AllTrim(cURL)+"/TSSGNRE.apw"
		//oWS:VERSAOTSS	:= '2.00'
		oWS:oWSDOCS:oWSDOCUMENTOS := TSSGNRE_ARRAYOFREMESSADOCUMENTO():New()

		for nX:= 1 to len(aXML)
			aadd(oWS:OWSDOCS:OWSDOCUMENTOS:OWSREMESSADOCUMENTO,TSSGNRE_REMESSADOCUMENTO():NEW())
			oWS:OWSDOCS:OWSDOCUMENTOS:OWSREMESSADOCUMENTO[nX]:CID := aXML[nX][1]
			oWS:OWSDOCS:OWSDOCUMENTOS:OWSREMESSADOCUMENTO[nX]:CXML:= aXML[nX][2]
		next

		xOk := oWS:REMESSA()

		If ValType(xOk) == 'L'
			cFiltro := 'xOk'
		ElseIf xOk == Nil
			cFiltro := 'xOk <> Nil'
		EndIf

		If &cFiltro
			for nY:= 1 to len( oWS:OWSREMESSARESULT:OWSDOCUMENTOS:OWSREMESSARETDOC )

				if type("oWS:OWSREMESSARESULT:OWSDOCUMENTOS:OWSREMESSARETDOC["+Str(nY)+"]:LSUCESSO")<>"U"
					if !(oWS:OWSREMESSARESULT:OWSDOCUMENTOS:OWSREMESSARETDOC[nY]:LSUCESSO)
						aadd(aErroGnre,{oWS:OWSREMESSARESULT:OWSDOCUMENTOS:OWSREMESSARETDOC[nY]:CID + " - " + oWS:OWSREMESSARESULT:OWSDOCUMENTOS:OWSREMESSARETDOC[nY]:CERRO})
						//Utilizar futuramente para tela de erro de schema na transmissão
						//oWS:OWSREMESSARESULT:OWSDOCUMENTOS:OWSREMESSARETDOC[1]:CERRO
					else
						aadd(aGnreOk,{oWS:OWSREMESSARESULT:OWSDOCUMENTOS:OWSREMESSARETDOC[nY]:CID})
					endif
				endif
			next

			cRetorno := STR0028+CRLF //"Você concluíu com sucesso a transmissão do Protheus para o Totvs Services SPED."
			cRetorno += STR0029+CRLF+CRLF //"Consulte o Status da(s) GNRE(s) utilizando a rotina 'Monitor'."
			cRetorno += STR0030+AllTrim(Str(Len(aGnreOk),18))+STR0031+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF//"Foram transmitidas "####" GNRE(s) em "#####

		else
			Aviso("GNRE",STR0032,{STR0025},3)//Houve erro durante a transmissão para o Totvs Services SPED.###OK
		endif

		if len( aErroGnre ) > 0
			cRetorno += STR0033+ CRLF+CRLF //"As GNRes abaixo foram recusadas, verifique a rotina 'Monitor' para saber os motivos."
			for nX:= 1 to len ( aErroGnre )
				cRetorno += aErroGnre[nX,1] + CRLF + CRLF
			next
		endif

	endif

return(cRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa095Mnt
Função de Monitoramento das GNREs

@author Simone dos Santos de Oliveira
@since 24.06.2015
@version 11.80


/*/
//-------------------------------------------------------------------
function Fisa095Mnt( )

	local oDlg			:= nil
	local oListBox		:= nil
	local oBtn1			:= nil
	local oBtn2			:= nil
	local oBtn3			:= nil
	local oBtn4			:= nil

	local aPerg   		:= {}
	local aListBox		:= {}
	local aSize   		:= {}
	local aObjects 		:= {}
	local aInfo    		:= {}
	local aPosObj  		:= {}
	local aErros		:= {}
	local aXMLResult	:= {}
	local aParam  		:= {space(len(SF6->F6_NUMERO)),space(len(SF6->F6_NUMERO)),space(len(SF6->F6_EST))}
	local cGnreIni		:= ""
	local cGnreFim		:= ""
	Local cUfFav		:= ""
	local cAmbGNRE		:= alltrim(GetMv("MV_AMBGNRE",,"2"))
	local cTela			:= STR0057 + cIdEnt  //"Monitoramento da GNRE" + " - Entidade : "
	local cUrl			:= Alltrim (Padr( GetNewPar("MV_SPEDURL",""), 250 ))
	Local lLote			:= IsInCallStack('FISA214')
	local cParGnreRem	:= SM0->M0_CODIGO+SM0->M0_CODFIL+Iif( lLote , "FISA095MON214", 'FISA095MON' )
	local lOk			:= .F.
	Local cLoteIni		:= "Lote Inicial"
	Local cLoteFinal	:= "Lote Final"

//Parâmetros de Configuração
	MV_PAR01 := aParam[01] := PadR(ParamLoad(cParGnreRem,aPerg,1,aParam[01]),len(SF6->F6_NUMERO))
	MV_PAR02 := aParam[02] := PadR(ParamLoad(cParGnreRem,aPerg,2,aParam[02]),len(SF6->F6_NUMERO))
	MV_PAR03 := aParam[03] := PadR(ParamLoad(cParGnreRem,aPerg,2,aParam[02]),len(SF6->F6_NUMERO))

	aadd(aPerg,{1,Iif( lLote, cLoteIni  , STR0034),aParam[01],"",".T.","",".T.",50,.T.}) //"Número GNRE Inicial:"
	aadd(aPerg,{1,Iif( lLote, cLoteFInal,STR0035),aParam[02],"",".T.","",".T.",50,.T.}) //"Número GNRE Final:"
	aadd(aPerg,{1,"Estado: ",aParam[03],"@!","ExistCpo('SX5','12' + MV_PAR03)","12",".T.",50,.T.}) //"Estado:"

	if IsReadyGNRE( cUrl )

		lOk := ParamBox(aPerg,cTela,@aParam,,,,,,,cParGnreRem,.T.,.T.)

		if lOk
			cGnreIni := Alltrim ( aParam[01] )
			cGnreFim := Alltrim ( aParam[02] )
			cUfFav	 := Alltrim ( aParam[03] )

			aListBox := GetListBox( cUrl, cGnreIni, cGnreFim, cAmbGNRE, @aErros, @aXMLResult, cUfFav )

			If Len(aListBox) > 0
				if ! empty(aListBox[1,2])
					aSize := MsAdvSize()
					aObjects := {}
					AAdd( aObjects, { 100, 100, .t., .t. } )
					AAdd( aObjects, { 100, 015, .t., .f. } )

					aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
					aPosObj := MsObjSize( aInfo, aObjects )

					DEFINE MSDIALOG oDlg TITLE STR0046 From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL //"GNRE - Web Service"

					@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER "",STR0037,STR0036,STR0038, STR0064,STR0039; //"Num. GNRE"###"Ambiente"###""Recibo""###"Núm. de Controle"###"Recomendação"###
					SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
					oListBox:SetArray( aListBox )
					oListBox:bLine := { || { aListBox[ oListBox:nAT,1 ],aListBox[ oListBox:nAT,2 ],aListBox[ oListBox:nAT,3 ],aListBox[ oListBox:nAT,4 ], aListBox[ oListBox:nAT,6 ], aListBox[ oListBox:nAT,5 ]} }

					@ aPosObj[2,1],aPosObj[2,4]-040 BUTTON oBtn1 PROMPT STR0025 ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //OK
					@ aPosObj[2,1],aPosObj[2,4]-080 BUTTON oBtn2 PROMPT STR0040 ACTION (Bt2GnreMnt(cUrl, aListBox[ oListBox:nAT,2 ],aListBox[ oListBox:nAT,3 ],2,aErros)) OF oDlg PIXEL SIZE 035,011 //Mensagens
					@ aPosObj[2,1],aPosObj[2,4]-120 BUTTON oBtn3 PROMPT STR0041 ACTION (Bt3GnreMnt(cUrl, aListBox[ oListBox:nAT,2 ],aListBox[ oListBox:nAT,3 ],1)) OF oDlg PIXEL SIZE 035,011 //Rec.XML
					@ aPosObj[2,1],aPosObj[2,4]-160 BUTTON oBtn4 PROMPT STR0042 ACTION (aListBox := GetListBox( cUrl, cGnreIni, cGnreFim, cAmbGNRE, @aErros,@aXMLResult, cUFFav ),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //Refresh
					@ aPosObj[2,1],aPosObj[2,4]-200 BUTTON oBtn4 PROMPT STR0043 ACTION (Bt4GnreMnt(cUrl,aListBox[ oListBox:nAT,2 ],cAmbGNRE)) OF oDlg PIXEL SIZE 035,011 //Schema

					ACTIVATE MSDIALOG oDlg

					//Após processamento do Monitor, realizo a chamada do método Retorna para buscar xml de retorno do fisco para gravar os campos conforme layout de retorno da GNRE PE
					FiscoResult( cUrl, aXMLResult )

				endif
			Endif
		else
			return nil
		endif

	endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} getListBox
Função que executa Monitoramento e retorna array para o listbox

@author Simone dos Santos de Oliveira
@since 24.06.2015
@version 11.80

@param		cURL		Endereço do Web Wervice no TSS 

/*/
//-------------------------------------------------------------------
static function getListBox(cUrl, cGnreIni, cGnreFim, cAmbGNRE, aRetErro, aResult , cUFFav)

	local oOk			:= LoadBitMap(GetResources(), "ENABLE")
	local oNo			:= LoadBitMap(GetResources(), "DISABLE")
	local aRetorno		:= {}
	local aListBox		:= {}
	local aIdTss		:= {}
	local cAviso		:= ''
	local cIdIni		:= ''
	local cIdFim		:= ''
	local cId			:= ''
	local cProtocolo	:= ''
	local cRecomendacao	:= ''
	local cAmbiente		:= ''
	local cStatusTSS	:= ''
	local cNumControl	:= ''
	local cCodBarras	:= ''
	local cFiltro		:= ''
	local cIndex		:= ''
	local lFinLDCB		:= FindFunction("FinLDCB")
	Local lLote			:= IsInCallStack("FISA214")
	Local aAreaSF6			:= SF6->(GetArea())

	local cAliasSF6		:= 'SF6'
	local nX			:= 0
	local nY			:= 0
	local nA			:= 0

	default cAmbGNRE	:= ''
	default cGnreIni	:= ''
	default cGnreFim	:= ''
	default cUFFav  	:= ''
	default cUrl		:= ''
	default aResult		:= {}

	If !(Empty(cUrl) .And. Empty(cGnreIni) .And. Empty(cGnreFim) .And. Empty(cAmbGNRE))

		dbselectarea('SF6')
		SF6->(dbsetorder(1))

		//Id para enviar para o TSS
		If Empty(cUFFav)

			#IFDEF TOP
				If (TcSrvType ()<>"AS/400")
					lQuery    := .T.
					cAliasSF6 := GetNextAlias()
					If lLote
						BeginSql Alias cAliasSF6
						SELECT CIB.CIB_FILIAL, CIB.CIB_EST, CIB.CIB_ID, CIB.CIB_IDTSS
						FROM %Table:CIB% CIB
						WHERE CIB.CIB_FILIAL=%xFilial:CIB% AND
							CIB.CIB_ID >= %Exp:cGnreIni% AND CIB.CIB_ID <= %Exp:cGnreFim% AND
							CIB.CIB_IDTSS <> '' AND
							CIB.%NotDel%
						ORDER BY %Order:CIB%
						EndSql
					Else
						BeginSql Alias cAliasSF6
						SELECT SF6.F6_FILIAL, SF6.F6_EST, SF6.F6_NUMERO, SF6.F6_IDTSS
						FROM %Table:SF6% SF6
						WHERE SF6.F6_FILIAL=%xFilial:SF6% AND
							SF6.F6_NUMERO >= %Exp:cGnreIni% AND SF6.F6_NUMERO <= %Exp:cGnreFim% AND
							SF6.F6_IDTSS <> '' AND
							SF6.%NotDel%
						ORDER BY %Order:SF6%
						EndSql
					EndIf


				Else
				#EndIf
				cIndex  := CriaTrab(NIL,.F.)
				cFiltro := 'F6_FILIAL=="'+xFilial ("SF6")+'".And.'
				cFiltro += 'F6_NUMERO >="'+ cGnreIni +'".And. SF6.F6_NUMERO <="'+ cGnreFim +'" '
				cFiltro += '.And. F6_IDTSS <> "" '
				indregua (cAliasSF6, cIndex, SF6->(IndexKey ()),, cFiltro)
				nIndex := retindex(cAliasSF6)
				#IFNDEF TOP
					dbSetIndex(cIndex+OrdBagExt())
				#ENDIF
				dbSelectArea (cAliasSF6)
				dbSetOrder (nIndex+1)
				#IFDEF TOP
				Endif
			#EndIf

			dbSelectArea (cAliasSF6)
			(cAliasSF6)->(dbGoTop ())

			While !(cAliasSF6)->(eof ())

				aadd(aIdTss,{})
				nA := len(aIdTss)
				cIDTSS	:= iIF( lLote , (cAliasSF6)->CIB_IDTSS , (cAliasSF6)->F6_IDTSS )
				aadd(aIdTss[nA], alltrim( cIDTSS ) )

				(cAliasSF6)->(dbSkip())
			enddo

			if len(aIdTss) > 0 //pego o primeiro e o ultimo id
				cIdIni := aIdTss[1,1]
				cIdFim := aIdTss[len(aIdTss),1]
			Else
				cIdIni := cGnreIni
				cIdFim := cGnreFim
			endif

		Else // Informou UF
			If lLote
				cIdIni := "L"+ cUFFav + cGnreIni
				cIdFim := "L"+ cUFFav + cGnreFim
			Else
				cIdIni := cUFFav + cGnreIni
				cIdFim := cUFFav + cGnreFim
			EndIf

		Endif

		//Comunicação com o TSS
		aRetorno := RetMonitor(cUrl, cIdIni, cIdFim, cAmbGNRE ,@cAviso)

		If empty(cAviso)

			dbSelectArea('SE2')
			SE2->(dbSetOrder(1))

			If lLote
				CIB->(DbSetOrder(2))
			EndIf

			for nX := 1 to len(aRetorno)

				cId				:= alltrim( aRetorno[nX][1])
				cAmbiente		:= alltrim( aRetorno[nX][2])
				cRecomendacao	:= alltrim( aRetorno[nX][3])
				cProtocolo		:= alltrim( aRetorno[nX][4])
				cStatusTSS		:= alltrim( aRetorno[nX][7])
				cErroXML		:= alltrim( aRetorno[nX][14])
				cNumControl	:= alltrim( aRetorno[nX][15])
				cCodBarras		:= alltrim( aRetorno[nX][16])

				aadd(aListBox,{	iif(cStatusTSS<>"5",oNo,oOk),;
					cId,;
					iif(cAmbiente == "1","Produção","Homologação"),;
					cProtocolo,;
					cRecomendacao,;
					cNumControl})

				//Se tiver erro, gravo o Id e o XML para apresentar nas Mensagens do lote
				if ! empty( cErroXML )
					aadd(aRetErro,{ cId, cErroXML})
				endif

				//Se o retorno for Não autorizado / Autorizado pela SEFAZ atualizo a SF6
				If cStatusTSS $"4#5"
					If lLote
						aID	:= TSSIDLote(cId)
						If CIB->( DbSeek( xFilial("CIB") + aID[2] + aID[3]  ) )
							RecLock("CIB",.f.)
							CIB->CIB_GNREWS := Iif(cStatusTSS=='5',"S","N")
							CIB->CIB_RECIBO := cProtocolo
							CIB->CIB_CDBARR := cCodBarras
							CIB->CIB_NUMCTR := cNumControl
							CIB->(MsUnlock())
							aadd(aResult,{cId, cAmbiente, cCodBarras})
							// Atualiza guias ilhas
							SF6->(DbSetOrder(5))
							If SF6->(DbSeek( xFilial("SF6")  + aID[2] + aID[3]  ))
								While SF6->(!Eof()) .And. SF6->( F6_EST+F6_IDGUIA )  == aID[2] + aID[3]
									RecLock("SF6",.f.)
									SF6->F6_GNREWS := iif(cStatusTSS=='5',"S","N")
									SF6->F6_RECIBO := cProtocolo
									SF6->F6_NUMCTRL:= cNumControl
									MsUnlock()
									SF6->(DbSkip())
								End
							EndIf
							RestArea(aAreaSF6)
						EndIf

					Else
						If SF6->(dbseek(xFilial("SF6")+SubStr(cId,1,2)+SubStr(cId,3,Len(cId)-2)))
							RecLock("SF6",.f.)
							SF6->F6_GNREWS := iif(cStatusTSS=='5',"S","N")
							SF6->F6_RECIBO := cProtocolo
							SF6->F6_CDBARRA:= cCodBarras
							SF6->F6_NUMCTRL:= cNumControl
							MsUnlock()

							If ! empty( cCodBarras )
								//Gravação do código de barras no Titulo do financeiro
								If SE2->(dbSeek(xFilial("SE2")+Alltrim(SF6->F6_NUMERO)))
									RecLock("SE2",.f.)

									//Converte a linha digitável de 47/48 posições para código de barras FEBRABRAM de 44 posições, caso exista a função de conversão do contas a pagar no RPO.
									If lFinLDCB
										SE2->E2_CODBAR := IIF(Len(cCodBarras) == 44,cCodBarras,FinLDCB(cCodBarras))
									EndIf

									SE2->E2_LINDIG := IIF(!Len(cCodBarras) == 44 ,cCodBarras,FinCbLd(cCodBarras))

									MsUnlock()
								Endif

							/*Tratamento para preencher campos retornados pelo Portal da Gnre / SEFAZ 
							Adiciono as informações das GNREs autorizadas para após da demonstração em tela do monitor, processo o retorna() para buscar o xml de retorno*/
							aadd(aResult,{cId, cAmbiente, cCodBarras})

						Endif
					Endif
				EndIf
			Endif
		Next

		SF6->(dbCloseArea())
		SE2->(dbCloseArea())

		If empty(aListBox[1,2])
			Aviso("GNRE",STR0045,{STR0025}) //Não há dados###OK
		Endif
	Else
		Aviso("GNRE",STR0045,{STR0025}) //Não há dados###OK
	Endif
Endif

If empty( cUF )
	#IFDEF TOP
		dbSelectArea(cAliasSF6)
		dbCloseArea()
	#ELSE
		dbSelectArea(cAliasSF6)
		RetIndex(cAliasSF6)
		ferase(nIndex+OrdBagExt())
	#ENDIF
Endif

Return aListBox
//-------------------------------------------------------------------
/*/{Protheus.doc} RetMonitor
Função que executa Monitoramento

@author Simone dos Santos de Oliveira
@since 24.06.2015
@version 11.80

@param		cURL		Endereço do Web Wervice no TSS 

/*/
//-------------------------------------------------------------------
static function RetMonitor(cUrl, cIdIni, cIdFim, cAmbGNRE ,cAviso)

local aRetMnt		:= {}
local cIdGNRE		:= ""   
local cAmb			:= ""  
local cDesc			:= ""  
local cRecibo		:= ""  
local cResultado	:= ""  
local cLote			:= ""  
local cStatus		:= ""  
local cHrEnvSef		:= ""  
local cHrEnvTSS		:= ""  
local cHrRecSef		:= "" 
local cXMLErro		:= ""  
local cNumContro	:= "" 
local cCodBarras	:= ""
local dDtEnvSef		:= SToD ("  /  /  ")
local dDtEnvTSS		:= SToD ("  /  /  ")
local dDtRecSef		:= SToD ("  /  /  ")
local lOk			:= .F. 
local nX			:= 0 

default cUrl		:= ""
default cIdIni		:= ""
default cIdFim 		:= ""
default cAmbGNRE	:= ""
default cAviso		:= ""


oWS:= WSTSSGNRE():New()
oWS:cUSERTOKEN:= "TOTVS"
oWS:cIDENT 	:= cIdEnt
oWS:cAMBIENTE := cAmbGNRE
oWS:_URL		:= AllTrim(cURL)+"/TSSGNRE.apw"
oWS:cIDINI		:= cIdIni
oWS:cIDFIM		:= cIdFim
oWS:oWSMONITORRESULT:oWSDOCUMENTOS := TSSGNRE_ARRAYOFMONITORRETDOC():New()

aadd(oWS:oWSMONITORRESULT:oWSDOCUMENTOS:oWSMONITORRETDOC,TSSGNRE_MONITORRETDOC():New())

	lOk := oWS:MONITOR()

	if (lOk <> nil .Or. lOk) .And. type("oWS:OWSMONITORRESULT:OWSDOCUMENTOS:OWSMONITORRETDOC")<>"U"	

		oRetorno := oWS:OWSMONITORRESULT:OWSDOCUMENTOS:OWSMONITORRETDOC

		for nX:= 1 to len( oRetorno )

			cIdGNRE	:= oRetorno[nX]:CID
			cAmb		:= oRetorno[nX]:CAMBIENTE
			cDesc		:= oRetorno[nX]:CDESCRICAO
			cRecibo		:= oRetorno[nX]:CRECIBO	
			cResultado	:= oRetorno[nX]:CRESULTADO
			cLote		:= oRetorno[nX]:CLOTE
			cStatus		:= oRetorno[nX]:CSTATUS
			cHrEnvSef	:= oRetorno[nX]:CHRENVSEF
			cHrEnvTSS	:= oRetorno[nX]:CHRENVTSS
			cHrRecSef	:= oRetorno[nX]:CHRRECSEF
			dDtEnvSef	:= oRetorno[nX]:DDTENVSEF
			dDtEnvTSS	:= oRetorno[nX]:DDTENVTSS
			dDtRecSef	:= oRetorno[nX]:DDTRECSEF
			cXMLErro	:= oRetorno[nX]:CXMLERRO
			cNumContro	:= oRetorno[nX]:CNUMCONTRO
			cCodBarras	:= oRetorno[nX]:CCODBARRAS

			//dados para atualização da base
			aadd(aRetMnt, {	cIdGNRE,;
								cAmb,;
								cDesc,;
								cRecibo,;
								cResultado,;
								cLote,;
								cStatus,;
								cHrEnvSef,;
								cHrEnvTSS,;
								cHrRecSef,;
								dDtEnvSef,;
								dDtEnvTSS,;
								dDtRecSef,;
								cXMLErro,;
								cNumContro,;
								cCodBarras})
		next
	else
		cAviso := iif( empty(getWscError(3)),getWscError(1),getWscError(3) )
	endif

return aRetMnt
//-------------------------------------------------------------------
/*/{Protheus.doc} FSA095IDEnt
Obtem o codigo da entidade apos enviar o post para o Totvs Service SOA

@author Simone dos Santos de Oliveira
@since 24.06.2015
@version 11.80

/*/
//-------------------------------------------------------------------
function FSA095IDEnt()

local aArea			:= GetArea()
local cEntidade		:= ""
local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
local lUsaGesEmp	:= iif(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)
local lEnvCodEmp	:= GetNewPar("MV_ENVCDGE",.F.)


	//Obtem o codigo da entidade
	
	oWS := WsSPEDAdm():New()
	oWS:cUSERTOKEN := "TOTVS"
		
	oWS:oWSEMPRESA:cCNPJ       := iif(SM0->M0_TPINSC==2 .Or. empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
	oWS:oWSEMPRESA:cCPF        := iif(SM0->M0_TPINSC==3 .Or. SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
	oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   := iif(lUsaGesEmp,FWFilialName(),Alltrim(SM0->M0_NOME))
	oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
	oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     := nil
	oWS:oWSEMPRESA:cCP         := nil
	oWS:oWSEMPRESA:cDDD        := PADL(FisGetTel(SM0->M0_TEL,,,.T.)[2],3)
	oWS:oWSEMPRESA:cFONE       := AllTrim(FisGetTel(SM0->M0_TEL,,,.T.)[3])
	oWS:oWSEMPRESA:cFAX        := AllTrim(FisGetTel(SM0->M0_FAX,,,.T.)[3])
	oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        := iif(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  := ""
	oWS:oWSEMPRESA:cID_MATRIZ  := ""

	if lUsaGesEmp .And. lEnvCodEmp
		oWS:oWSEMPRESA:CIDEMPRESA:= FwGrpCompany()+FwCodFil()
	endif

	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
	if oWs:ADMEMPRESAS()
		cEntidade  := oWs:cADMEMPRESASRESULT
	else
		Aviso("SPED",iif( empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0025},3 ) //OK
	endif
	
	FreeObj(oWs)
	oWs := nil


RestArea(aArea)
aArea := aSize(aArea,0)
aArea := nil

return(cEntidade)

//-------------------------------------------------------------------
/*/{Protheus.doc} IsReadyGNRE
Função para verificar conexão com o TSS

@author Simone dos Santos de Oliveira         
@since 24.06.2015
@version 11.80

@param		cURL		Endereço do Web Wervice no TSS 

/*/
//-------------------------------------------------------------------
function IsReadyGNRE( cURL )

local lRetorno:= .F.
local nX      := 0

default cURL	:=	""

//Verifica se o servidor da Totvs esta no ar
oWs 			:= WsSpedCfgNFe():New()
oWs:cUserToken:= "TOTVS"
oWS:_URL 		:= AllTrim(cURL)+"/SPEDCFGNFe.apw"

if oWs:CFGCONNECT()
	lRetorno := .T.
else
	Aviso("GNRE",iif(empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0025},3) //OK
	lRetorno := .F.
endif

return(lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} Bt2GnreMnt
Função para retornar mensagens do Lote

@author Simone dos Santos de Oliveira        
@since 24.06.2015
@version 11.80

/*/
//-------------------------------------------------------------------
static function Bt2GnreMnt(cUrl,cIdGnre,cAmb,nTipo,aErros)

local oDlg			:= Nil
local oListBox		:= Nil
local oBtn1			:= Nil
local oFont			:= Nil
local oLbLote		:= Nil
local oGtLote		:= Nil
local oLbDataLote	:= Nil
local oGtDataLote	:= Nil
local oLbHoraLote	:= Nil
local oGtHoraLote	:= Nil
local oLbRecSEF		:= Nil
local oGtRecSEF		:= Nil
local oListSubProc	:= Nil
local oLegenda 		:= Nil
local oBtEnd		:= Nil
local oLbIdGnre		:= Nil
local oGtIdGnre		:= Nil
local oOk			:= LoadBitMap(GetResources(), "ENABLE")
local oNo			:= LoadBitMap(GetResources(), "DISABLE")

local aSize    		:= MsAdvSize()
local aObjects 		:= {}
local aInfo    		:= {}
local aPosObj  		:= {}
local aMsg		 	:= {}
local aMsgErro 		:= {}
local aMsgLote		:= {}
local cError   		:= ''
local cWarning 		:= ''
local cXMLErro		:= ''
local cLote			:= ''
local cHrLote		:= ''
local cRecibo		:= ''
local cCodRetTSS	:= ''
local dDtLote		:= SToD ("  /  /  ")
local nPos   		:= 0  
local nX			:= 0
local nI			:= 0

default cUrl  		:= ''  
default cIdGnre 	:= ''
default cAmb  		:= ''
default nTipo		:= 2
default aErros 		:= {}


if ! ( empty(cUrl) .And. empty(cIdGnre) .And. empty(cAmb) )
	
	Bt3GnreMnt(cUrl,cIdGnre,cAmb,nTipo,@aMsg)

	//Verifico se tem erros e posiciono no array para pegar o xml de erro e dar o parser
	if len(aErros) > 0
		nPos := Ascan(aErros,{|x|AllTrim(x[1])== Alltrim(cIdGnre)})
		if nPos <> 0
			cXMLErro := aErros[nPos][2]
		
			//Parser no XML
			oXml := XmlParser( cXMLErro, "_", @cError, @cWarning )   
			
			//Array com as Mensagens para apresentar no Grid
			if empty(cError) .And. empty(cWarning) .And. type("oXml:_XMLERRO:_ERROS:_ERRO")<>"U" 
				if type("oXml:_XMLERRO:_ERROS:_ERRO:_CODIGO")<>"U" .And. !empty(oXml:_XMLERRO:_ERROS:_ERRO:_CODIGO:TEXT)
						
					aadd(aMsgErro,{oXml:_XMLERRO:_ERROS:_ERRO:_CODIGO:TEXT, oXml:_XMLERRO:_ERROS:_ERRO:_DESCRICAO:TEXT})
				
				//tratamento para verificar se há mais de um erro	
				elseif type("oXml:_XMLERRO:_ERROS:_ERRO[1]:_CODIGO") <> "U" .And. !empty(oXml:_XMLERRO:_ERROS:_ERRO[1]:_CODIGO:TEXT)
					
					for  nX:=1 to len(oXml:_XMLERRO:_ERROS:_ERRO)
					    
						aadd(aMsgErro,{oXml:_XMLERRO:_ERROS:_ERRO[nX]:_CODIGO:TEXT,;
						             oXml:_XMLERRO:_ERROS:_ERRO[nX]:_DESCRICAO:TEXT})
				
				    next
				endif
				//tratamento quando o TSS retorna a estrutura de xml de erro, mas não contém mensagem
				if !empty(aMsg[1,1]) .And. aMsg[1,5]=='3'
					aadd(aMsgErro,{"000", "LOTE PROCESSADO COM SUCESSO."})
				elseif !( empty(aMsg[1,1]) .and. empty(aMsg[1,7]) .and. empty(aMsg[1,8]) )  
					aadd(aMsgErro,{aMsg[1,7],aMsg[1,8]}) //Temporario
				else
					aadd(aMsgErro,{"999", "LOTE PROCESSADO COM ERRO."})
				endif
			else
				Aviso("GNRE",IIf(!Empty(cError),cError,cWarning),{STR0025},3) //OK
				return
			endif
		elseif !empty(aMsg[1,1]) .And. aMsg[1,5]=='3'
			aadd(aMsgErro,{"000", "LOTE PROCESSADO COM SUCESSO."})
		elseif !empty(aMsg[1,7]) .And. !empty(aMsg[1,8])
			aadd(aMsgErro,{aMsg[1,7],aMsg[1,8]}) //Temporario
		else
			aadd(aMsgErro,{"999", "LOTE PROCESSADO COM ERRO."})
		endif
	elseif !empty(aMsg[1,1]) .And. aMsg[1,5]=='3'
		aadd(aMsgErro,{"000", "LOTE PROCESSADO COM SUCESSO."})
	elseif !empty(aMsg[1,7]) .And. !empty(aMsg[1,8])
		aadd(aMsgErro,{aMsg[1,7],aMsg[1,8]})
	else
		aadd(aMsgErro,{"999", "LOTE PROCESSADO COM ERRO."})
	endif
	
	
	if !empty(aMsg[1][1]) .And. len(aMsgErro)>0 .And. !empty(aMsgErro[1,1])
	
		cLote		:= aMsg[1,1]
		cDtLote	:= aMsg[1,2]
		cHrLote	:= aMsg[1,3]
		cRecibo	:= aMsg[1,4]
		cCodRetTSS	:= aMsg[1,5]
		
		for nI:= 1 to len(aMsgErro)
					
			aadd(aMsgLote,{iif(Alltrim(aMsgErro[nI][1])=="000",oOk,oNo ), Alltrim(aMsgErro[nI][1]), Alltrim(aMsgErro[nI][2])})
		
		next nI
	
		DEFINE MSDIALOG oDlg TITLE STR0046 FROM 000, 000 TO 570,1200 PIXEL 
		
		DEFINE FONT oFont BOLD
		
			//ID GNRE
			@000, 000 SAY  oLbIdGnre PROMPT "ID GNRE:"  FONT oFont	SIZE 000, 000 OF oDlg PIXEL
			oLbIdGnre:nTop	:= 020
			oLbIdGnre:nLeft	:= 020
			oLbIdGnre:nWidth	:= 70
			oLbIdGnre:nHeight	:= 015

			@000, 000 SAY  oGtIdGnre PROMPT cIdGnre	SIZE 000, 000 OF oDlg PIXEL
			oGtIdGnre:nTop	:= 020
			oGtIdGnre:nLeft	:= oLbIdGnre:nLeft + oLbIdGnre:nWidth + 30
			oGtIdGnre:nWidth	:= oDlg:nWidth - 40   
			oGtIdGnre:nHeight	:= 015
			
					
			//LOTE
			@000, 000 SAY  oLbLote PROMPT "Lote:"  FONT oFont	SIZE 000, 000 OF oDlg PIXEL
			oLbLote:nTop		:= oLbIdGnre:nTop + oLbIdGnre:nHeight + 10
			oLbLote:nLeft		:= 020
			oLbLote:nWidth	:= 70
			oLbLote:nHeight	:= 015

			@000, 000 SAY  oGtLote PROMPT cLote	SIZE 000, 000 OF oDlg PIXEL
			oGtLote:nTop		:= oLbLote:nTop
			oGtLote:nLeft		:= oLbLote:nLeft + oLbLote:nWidth + 30
			oGtLote:nWidth	:= oDlg:nWidth - 40   
			oGtLote:nHeight	:= 015
			

			//DATA LOTE			
			@000, 000 SAY oLbDataLote	PROMPT "Data Lote:"	SIZE 000, 000	OF oDlg PIXEL FONT oFont  
			oLbDataLote:nTop		:= oLbLote:nTop + oLbLote:nHeight + 10   
			oLbDataLote:nLeft		:= 020
			oLbDataLote:nWidth	:= 100
			oLbDataLote:nHeight	:= 015			

			@025, 060 SAY oGtDataLote	PROMPT cDtLote	SIZE 000, 000 OF oDlg PIXEL
			oGtDataLote:nTop		:= oLbDataLote:nTop
			oGtDataLote:nLeft		:= oLbDataLote:nLeft + oLbDataLote:nWidth 
			oGtDataLote:nWidth	:= oDlg:nWidth - 40
			oGtDataLote:nHeight	:= 015	
			
			//HORA LOTE	
			@000, 000 SAY oLbHoraLote	PROMPT "Hora Lote:"	SIZE 000, 000	OF oDlg PIXEL FONT oFont  
			oLbHoraLote:nTop		:= oLbDataLote:nTop + oLbDataLote:nHeight + 10   
			oLbHoraLote:nLeft		:= 020
			oLbHoraLote:nWidth	:= 100
			oLbHoraLote:nHeight	:= 015			

			@025, 060 SAY oGtHoraLote	PROMPT cHrLote	SIZE 000, 000 OF oDlg PIXEL
			oGtHoraLote:nTop		:= oLbHoraLote:nTop
			oGtHoraLote:nLeft		:= oLbHoraLote:nLeft + oLbHoraLote:nWidth 
			oGtHoraLote:nWidth	:= oDlg:nWidth - 40
			oGtHoraLote:nHeight	:= 015		
			
			
			//RECIBO SEFAZ	
			@000, 000 SAY oLbRecSEF	PROMPT "Recibo SEFAZ:"	SIZE 000, 000	OF oDlg PIXEL FONT oFont  
			oLbRecSEF:nTop		:= oLbHoraLote:nTop + oLbHoraLote:nHeight + 10   
			oLbRecSEF:nLeft		:= 020
			oLbRecSEF:nWidth		:= 100
			oLbRecSEF:nHeight		:= 015			

			@025, 060 SAY oGtRecSEF	PROMPT cRecibo	SIZE 000, 000 OF oDlg PIXEL
			oGtRecSEF:nTop		:= oLbRecSEF:nTop
			oGtRecSEF:nLeft		:= oLbRecSEF:nLeft + oLbRecSEF:nWidth 
			oGtRecSEF:nWidth		:= oDlg:nWidth - 40
			oGtRecSEF:nHeight		:= 015	
		
			//LISTBOX SUB PROCESSO
			@ 000,000 LISTBOX oListSubProc FIELDS HEADER "", "Codigo", "Descricao" SIZE 587, 170 OF oDlg PIXEL 
			oListSubProc:nTop := oLbRecSEF:nTop + 30
			oListSubProc:nLeft:= 020
			oListSubProc:nWidth:= oDlg:nWidth - 60
			oListSubProc:nHeight:= 300
			oListSubProc:setArray(aMsgLote)
			oListSubProc:bLine		:= {||	{	aMsgLote[oListSubProc:nAt, 1], aMsgLote[oListSubProc:nAt, 2],;
																	aMsgLote[oListSubProc:nAt, 3]}}
		
			//LEGENDA
			@ 000, 000 GROUP oLegenda TO 295, 120 PROMPT "Legenda"   OF oDlg  PIXEL
			oLegenda:nTop		:= oListSubProc:nTop + oListSubProc:nHeight + 20 
			oLegenda:nleft 	:= 020
			oLegenda:nwidth 	:= 240
			oLegenda:nHeight	:= oDlg:nHeight * 0.10
			
			//BTMAPS DOS STATUS
			@ 245, 020 BITMAP oOk RESOURCE "BR_VERDE.PNG" NO BORDER SIZE 017, 017 OF oLegenda PIXEL
			@ 245, 030 SAY "Lote Autorizado" SIZE 100,010 PIXEL OF oDlg	
			@ 255, 020 BITMAP oNo RESOURCE "BR_VERMELHO.PNG" NO BORDER SIZE 017, 017 OF oLegenda PIXEL
			@ 255, 030 SAY "Lote Não Autorizado" SIZE 100,010 PIXEL OF oDlg
	
			//BOTAO SAIR
			@ 000,000 BUTTON oBtEnd PROMPT "Sair" SIZE 000, 000 ACTION ( oDlg:end() ) OF oDlg PIXEL			
			oBtEnd:nTop 	:= oLegenda:nTop + 10
			oBtEnd:nleft 	:= oDlg:nWidth - 150
			oBtEnd:nWidth := 100
			oBtEnd:nHeight:= 035
			oBtEnd:setCSS(  "STYLE_BTN_CLOSE" ) 
		
		ACTIVATE MSDIALOG oDlg
	endif
endif	

return(.T.)

//-----------------------------------------------------------------------
/*/{Protheus.doc} Bt3GnreMnt
Função que Retorna XML da Gnre.

@author Simone dos Santos de Oliveira         
@since 24.06.2015
@version 11.80

@param	cUrl		URL do Web Service
		cIdGnre		Id da Gnre 
		cAmb		Ambiente de Transmissão  #1-Produção / 2-Homologação
		nTipo		Tipo de execução do Serviço # 1-Retorna XML 2-Mensagens Referente ao lote
					3 - Busca XML para Validação Schema / 4 - Pega apenas o RESULTSEF do retorno
 
@return	.T.
/*/
//-----------------------------------------------------------------------
static function Bt3GnreMnt(cUrl,cIdGnre,cAmb,nTipo,aRetGnre,cXML)

local cAmbiente		:= "" 
local cLote			:= "" 
local cHrLote		:= ""
local cRecibo		:= ""    
local cCodRetTSS	:= ""   
local cMsgRetTSS	:= "" 
local cCodRetSef	:= ""   
local cMsgRetSef	:= "" 
local nX			:= 0
local dDtLote		:= SToD ("  /  /  ")

default aRetGNRE	:= {}
default cUrl  		:= ""  
default cIdGnre 	:= ""
default cAmb  		:= ""
default cXML		:= ""
default nTipo		:= 1

                                                          
if ! ( empty(cUrl) .And. empty(cIdGnre) .And. empty(cAmb) )

	cAmbiente	:= iif(upper(cAmb)$"1PRODUÇÃO","1","2")    

	oWS:= WSTSSGNRE():New()
	oWS:cUSERTOKEN	:= "TOTVS"
	oWS:cIDENT 		:= cIdEnt
	oWS:cAMBIENTE 	:= cAmbiente
	oWS:_URL			:= AllTrim( cURL )+"/TSSGNRE.apw"
	oWS:cID			:= Alltrim( cIdGnre )

	lOk := oWS:RETORNA()

	if (lOk <> nil .Or. lOk)
	
		if nTipo == 1 .Or. nTipo == 3 //Retorna XML
			if lOk .And. type("oWS:OWSRETORNARESULT:OWSDOCUMENTOS:OWSRETORNARETDOC[1]:CXML")<>"U"
				if nTipo == 1
					Aviso("GNRE",oWS:OWSRETORNARESULT:OWSDOCUMENTOS:OWSRETORNARETDOC[1]:CXML,{STR0025},3,,,,.T.) //OK
				else
					cXML	:= oWS:OWSRETORNARESULT:OWSDOCUMENTOS:OWSRETORNARETDOC[1]:CXML
				endif	
			else
				Aviso("GNRE",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0025},3,,,,.T.) //OK
			endif
		elseif nTipo==4 .and. type("oWS:OWSRETORNARESULT:OWSDOCUMENTOS:OWSRETORNARETDOC[1]:CRESULTSEF")<>"U"
			cXML := oWS:OWSRETORNARESULT:OWSDOCUMENTOS:OWSRETORNARETDOC[1]:CRESULTSEF
		else
			//Mensagem referente ao Lote  
			if type("oWS:OWSRETORNARESULT:OWSDOCUMENTOS:OWSRETORNARETDOC[1]")<>"U"
				cLote		:= oWS:OWSRETORNARESULT:OWSDOCUMENTOS:OWSRETORNARETDOC[1]:CLOTE
				cLote		:= iif(!empty(cLote),StrTran(cLote,'0',""),"") 
				dDtLote	:= oWS:OWSRETORNARESULT:OWSDOCUMENTOS:OWSRETORNARETDOC[1]:DDTENVLOTE
				cHrLote	:= oWS:OWSRETORNARESULT:OWSDOCUMENTOS:OWSRETORNARETDOC[1]:CHRENVLOTE
				cRecibo	:= oWS:OWSRETORNARESULT:OWSDOCUMENTOS:OWSRETORNARETDOC[1]:CRECIBO
				cCodRetTSS	:= oWS:OWSRETORNARESULT:OWSDOCUMENTOS:OWSRETORNARETDOC[1]:CSTATUS    
				cMsgRetTSS	:= oWS:OWSRETORNARESULT:OWSDOCUMENTOS:OWSRETORNARETDOC[1]:CDESCRICAO 
				cCodRetSef	:= oWS:OWSRETORNARESULT:OWSDOCUMENTOS:OWSRETORNARETDOC[1]:CSTATSEF    
				cMsgRetSef	:= Alltrim(oWS:OWSRETORNARESULT:OWSDOCUMENTOS:OWSRETORNARETDOC[1]:CDESCSEF)
								
				//dados para apresentação de informações do lote
				aadd(aRetGnre, {	cLote,;
									dDtLote,;
									cHrLote,;
									cRecibo,;	
									cCodRetTSS,;
									cMsgRetTSS,;
									cCodRetSef,;
									cMsgRetSef})    
			else
				Aviso("GNRE",iif( empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0025},3,,,,.T.) //OK
			endif
		endif
	else
		Aviso("GNRE",iif(empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0025},3,,,,.T.) //OK
	endif
endif

return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} Bt4GnreMnt
Função que faz validação de schema.

@author Simone dos Santos de Oliveira         
@since 24.06.2015
@version 11.80

@param	cUrl		URL do Web Service
		cIdGnre	Id da Gnre que será feito a validação de schema
		cAmb		Ambiente de Transmissão  #1-Produção / 2-Homologação
 
@return	.T.
/*/
//-----------------------------------------------------------------------
static function Bt4GnreMnt(cUrl,cIdGnre,cAmb)

local cString	:= ""
Local cVersao	:= GetMv("MV_GNREVE",,"1.00")
Local lLote		:= IsInCallStack('FISA214')
Local aID		:= {}
default cUrl	:= ""
default cIdGnre	:= ""
default cAmb	:= ""



if ! ( empty(cUrl) .And. empty(cIdGnre) .And. empty(cAmb) )

	//Busco o XML que será enviado para validação de schema através do Método Retorna
	//Bt3GnreMnt(cUrl,cIdGnre,cAmb,3,,@cString)
	If !lLote
		dbSelectArea("SF6")
		SF6->(dbSetOrder(1))
		SF6->(DbSeek(xFilial("SF6")+cIdGnre))
		cString := Alltrim(SF6->F6_XMLENV)
	Else
		aID := TSSIDLote(cIdGnre)
		dbSelectArea("CIB")
		CIB->(dbSetOrder(2))
		If CIB->( DbSeek(xFilial("CIB")+ aID[2] + aID[3] ))
			cString := Alltrim(CIB->CIB_XMLENV)	
		EndIf
	EndIf


	if ! empty(cString)

		//Validação de Schema
		oWS:= WSTSSGNRE():New()
		oWS:cUSERTOKEN	:= "TOTVS"
		oWS:cIDENT		:= cIdEnt
		oWS:cAMBIENTE	:= cAmb	
		oWS:cID			:= Alltrim( cIdGnre )
		oWS:cXML		:= cString
		oWS:cUF			:= cUf
		oWS:cVersao		:= cVersao
		oWS:_URL		:= AllTrim( cURL )+"/TSSGNRE.apw"

		lOk := oWS:SCHEMA()

		if (lOk <> nil .Or. lOk)

			if type("oWS:OWSSCHEMARESULT:OWSDOCUMENTOS:OWSSCHEMARETDOC[1]") <> "U"
				if oWS:OWSSCHEMARESULT:OWSDOCUMENTOS:OWSSCHEMARETDOC[1]:LSUCESSO
					Aviso("GNRE",STR0058,{STR0025},3) //Schema Válido.###OK
				else
					cRetSchema := oWS:OWSSCHEMARESULT:OWSDOCUMENTOS:OWSSCHEMARETDOC[1]:CMSG
					Aviso("GNRE",cRetSchema,{STR0025},3) //OK
				endif
			endif
		else
			Aviso("GNRE",iif( empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0025},3) //OK
		endif
	endif
endif

return .T.
//-----------------------------------------------------------------------
/*/{Protheus.doc} Fisa095Amb
Função utilizada para configurar o ambiente de transmissão e monitoramento 
da GNRE WS.

@author Simone dos Santos de Oliveira         
@since 22.02.2016
@version 11.80

/*/
//-----------------------------------------------------------------------
function Fisa095Amb()

Local aPerg			:= {}
Local aParam		:= {space(len("2-Homologação")),Space(Len("2.00"))}
Local cTela			:= STR0061 + cIdEnt //Ambiente GNRE - Entidade :
Local cParGnreAmb	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"FISA095AMB"
Local cAmbiente		:= ""
Local cVersao		:= GetVersao(.F.)
Local cVerRPO		:= GetRPORelease()
Local cENGSX6		:= "ENGSX6" + SubStr(cVerRPO,4,1) + SubStr(cVerRPO,7,2)
Local cParam		:= "MV_AMBGNRE"
Local lOk			:= .F.
Local lCIB			:= AliasIndic("CIB")

//Parametros de Configuração
MV_PAR01 := aParam[01] := PadR(ParamLoad(cParGnreAmb,aPerg,1,aParam[01]),len(STR0005)) //2-Homologação
aadd(aPerg,{2,STR0036,PadR("",Len(STR0005)),{STR0004,STR0005},60,".T.",.T.,".T."}) //Ambiente:###1-Produção###2-Homologação

If lCIB
	MV_PAR02 := aParam[02] := PadR(ParamLoad(cParGnreAmb,aPerg,1,aParam[02]),len("2.00")) //Versão 
	aadd(aPerg,{2,STR0067,PadR("",Len("2.00")),{"1.00","2.00"},60,".T.",.T.,".T."}) //Versão:###1.00###2.00
EndIf

lOk := ParamBox(aPerg,cTela,@aParam,,,,,,,cParGnreAmb,.T.,.T.)

If lOk
	cAmbiente := SubStr( alltrim (aParam[01]), 1, 1 )

	If cVersao <> "12" .Or. !FindFunction(cENGSX6)
		PutMv(cParam,cAmbiente)
		If lCIB
			PutMv("MV_GNREVE", AllTrim(aParam[02]) )
		EndIf
	Else
		&cENGSX6.(cParam,cAmbiente)
		If lCIB
			&cENGSX6.("MV_GNREVE", AllTrim(aParam[02]) )
		EndIf
	EndIf
	MsgInfo("Ambiente configurado com Sucesso!")
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RetCodInt
Retorna código controle interno das Mensagens de retorno.

@author Simone dos Santos de Oliveira
@since 26/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
function RetCodInt( cTitulo )

local cCodigo		:= '' 
local cAtuMon		:= 'ATUALIZACAO MONETARIA|'
local cCarga		:= 'CARGA'  
local cChave		:= 'CHAVE'
local cCNAE			:= "CNAE FISCAL"
local cCNPJRem		:= "CNPJ REMETENTE"
local cConhecInte	:= "CONHECIMENTO DE TRANSPORTE INTERNACIONAL"
local cDtSaida		:= "DATA DA SAIDA DA MERCADORIA"
local cDtEmisNf		:= "DATA DE EMISSÃO DA NOTA FISCAL|DATA DE EMISSAO"
local cDtDesem		:= "DATA DO DESEMBARACO"
local cDetReceita	:= "DETALHAMENTO DA RECEITA"
local cGuast		:= "GUIAST"
local cInfComp		:= "INFORMACOES ADICIONAIS|INFORMAÇÃO COMPLEMENTAR|INFORMACOES COMPLEMENTARES|INFORMACOES COMPLEMENTARES 2|INFORMACOES COMPLEMENTARES 4|INFORMACOES COMPLEMENTARES 1|INFORMACOES  COMPLEMENTARES|INFORMACAO COMPLEMENTAR|"
local cJuros		:= "JUROS"
local cManifCarga	:= "MANIFESTO DE CARGA"
local cMulta		:= "MULTA"
local cMulOrig		:= "MUNICIPIO DE ORIGEM"
local cNumNota		:= "NRO DA NOTA FISCAL|N DA NOTA FISCAL|NUMERO DA NOTA FISCAL|Nº DA NOTA FISCAL"
local cNomeRem		:= "NOME DO REMETENTE" 
local cObs			:= "OBSERVACOES|JUSTIFICATIVA|OBSERVACAO|OBS1|OBS2"
local cPlacaCam		:= "PLACA DO CAMINHAO"
local cProtSint		:= "PROTOCOLO TED DE TRANSMISSAO DO SINTEGRA"
local cValAdua		:= "VALOR ADUANEIRO"

default cTitulo	:= ""

if !empty( cTitulo )

	do case 
	
		case cTitulo $ cObs
			cCodigo	:= "OBS"
			
		case cTitulo $ cInfComp
			cCodigo	:= "INF"  
			
		case cChave $ cTitulo 
			cCodigo	:= "CHV"    
		
		case cTitulo $ cDtEmisNf
			cCodigo	:= "DEM"   
			
		case cTitulo $ cDtSaida
			cCodigo	:= "DSA"
		
		case cTitulo $ cDetReceita
			cCodigo	:= "DET"	 
			
		case cTitulo $ cNumNota
			cCodigo	:= "NNF"
				
		case cTitulo $ cAtuMon
			cCodigo	:= "ATM"  
			
		case cTitulo $ cCarga
			cCodigo	:= "CRG" 
		
		case cTitulo $ cNomeRem
			cCodigo	:= "NRE"    
		
		case cTitulo $ cCNPJRem
			cCodigo	:= "CNP"
		
		case cTitulo $ cCNAE
			cCodigo	:= "CNA"	
				
		case cTitulo $ cConhecInte
			cCodigo	:= "CIN"
				
		case cTitulo $ cDtDesem
			cCodigo	:= "DES"

		case cTitulo $ cGuast
			cCodigo	:= "GST"
			
		case cTitulo $ cJuros
			cCodigo	:= "JRS"
		
		case cTitulo $ cManifCarga
			cCodigo	:= "MCR"
		
		case cTitulo $ cMulta
			cCodigo	:= "MLT"
			
		case cTitulo $ cMulOrig
			cCodigo	:= "MOR"

		case cTitulo $ cPlacaCam
			cCodigo	:= "PCA"
		
		case cTitulo $ cProtSint
			cCodigo	:= "PTS"
		
		case cTitulo $ cValAdua
			cCodigo	:= "VLD"
		
		otherwise
			cCodigo	:= " "
	
	endCase
endif

return cCodigo
//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa095Ext
Realiza sincronização e cadastro de Inf. Extras (FISA117)

@author Simone dos Santos de Oliveira
@since 26/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
function Fisa095Ext()

Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetDescription( STR0065) //Cadastro Informações Extras GNRE WS
oBrowse:SetAlias( 'F0N' )
oBrowse:SetMenuDef( 'FISA117' )
oBrowse:DisableDetails()
oBrowse:ForceQuitButton()
oBrowse:activate()

return
//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa095Imp
Realiza impressão da GNRE

@author Simone dos Santos de Oliveira
@since 07/03/2016
@version 1.0

/*/
//-------------------------------------------------------------------
function Fisa095Imp()

local oImpGNRE
local oSetup

local aDevice    := {}

local cFilePrint := "GNRE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
local cSession   := GetPrinterSession()

AADD(aDevice,"DISCO") // 1
AADD(aDevice,"SPOOL") // 2
AADD(aDevice,"EMAIL") // 3
AADD(aDevice,"EXCEL") // 4
AADD(aDevice,"HTML" ) // 5
AADD(aDevice,"PDF"  ) // 6

nLocal       := if(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
nOrientation := 1 //Retrato
cDevice      := if(empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
nPrintType   := ascan(aDevice,{|x| x == cDevice })

If IsReadyGNRE( cUrl )

	lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
	oImpGNRE := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, /*cPathInServer*/, .T.)

	// ----------------------------------------------
	// Cria e exibe tela de Setup Customizavel
	// OBS: Utilizar include "FWPrintSetup.ch"
	// ----------------------------------------------
	nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN + PD_DISABLEORIENTATION

	if findfunction("u_PrtGNRE")
		if ( !oImpGNRE:lInJob )
			oSetup := FWPrintSetup():New(nFlags, "GNRE")
			// ----------------------------------------------
			// Define saida
			// ----------------------------------------------
			oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
			oSetup:SetPropert(PD_ORIENTATION , nOrientation)
			oSetup:SetPropert(PD_DESTINATION , nLocal)
			oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
			oSetup:SetPropert(PD_PAPERSIZE   , 2)
		endif

		// Pressionado botão OK na tela de Setup
		if oSetup:Activate() == PD_OK // PD_OK =1

			//Salva os Parametros no Profile
			fwWriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
			fwWriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )
			fwWriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )

			// Configura o objeto de impressão com o que foi configurado na interface.
			oImpGNRE:setCopies( val( oSetup:cQtdCopia ) )

			u_PrtGNRE(cIdEnt, oImpGNRE, oSetup, cFilePrint)		

		else
			msginfo("Relatório cancelado pelo usuário.")
			return
		endif
	else
		msginfo("RDMAKE FISA119 não encontrado. Relatório não será impresso!")
	endif
endif

oImpGNRE:= nil
oSetup  := nil

return

//-------------------------------------------------------------------
/*/{Protheus.doc} FiscoResult
Função que trata o xml de retorno do Portal GNRE PE para alimentar os 
campos conforme layout de retorno 

@author Simone dos Santos de Oliveira
@since 22/08/2017
@version 1.0

/*/
//-------------------------------------------------------------------
static function FiscoResult ( cUrl, aResultSEF )

local aXML			:= {}
local cXmlResult	:= ''
local cDtLimPgto	:= ''
local nA			:= 0
local nX			:= 0
Local cVersao		:= "1.00"
Local cError		:= ""
Local cWarning		:= ""
Local cAliasTmp		:= ""
Local aValores		:= Nil
Local lLote			:= IsInCallStack('FISA214')
Private oXMl		:= Nil

default cUrl		:= ''
default aResultSEF	:= {}

If lLote
	CIB->(DbSetOrder(2))
EndIf

For nA:=1 To Len( aResultSEF )

	If !Left(aResultSEF[nA,1], 2)$"RJ/ES"
		//Busco o XML pelo método retorna para tratar posteriormente
		Bt3GnreMnt(cUrl,aResultSEF[nA,1],aResultSEF[nA,2],4,,@cXmlResult)

		//oXMl	:= XmlParser( cXmlResult, "_", @cError, @cWarning )
		oXMl	:= GnreParser( cXmlResult, "_", @cError, @cWarning )
		// Identifica se o retorno da SEFAZ é da versão 1.00 ou 2.00
		Iif( Empty(cError) .And. Empty(cWarning) .And. TYPE('oXMl:_GNRERESPOSTAMSG') == 'O' , cVersao := "2.00" , cVersao:= "1.00" )

		If cVersao == "1.00" .And. !Empty(cXmlResult) 
			aXML := StrTokArr(cXmlResult,CHR(10))
			for nX := 1 to len(aXML)
				If SubStr(aXML[nX],1,1) == "1" .And. (aResultSEF[nA,3] == SubStr(aXML[nx],979,48)) 
					cProduto	:= alltrim(SubStr(aXML[nX],290,255))
					cInfCompl	:= alltrim(SubStr(aXML[nX],593,300))
					cAtuMon		:= Val(SubStr(aXML[nX],934,15))/100
					cJuros		:= Val(SubStr(aXML[nX],949,15))/100
					cMulta		:= Val(SubStr(aXML[nX],964,15))/100
					cDtLimPgto	:= alltrim(SubStr(aXML[nX],901,8))
					//tratamento para gravar data Limite de Pagamento na tabela
					cDtLimPgto:= iif( !Empty( cDtLimPgto ),substr(cDtLimPgto,5,4) + substr(cDtLimPgto,3,2) + substr(cDtLimPgto,1,2), '')
					cSeek := PadR(SubStr(aResultSEF[nA,1],1,2),2) + PadR(SubStr(aResultSEF[nA,1],3,12),12)
					AtuSF6SE2( cSeek, 0, cMulta , cJuros , cAtuMon , 0 , cDtLimPgto  )
				Endif
			Next nX
		ElseIf cVersao == "2.00"

			// Guias emitidas via FISA095 1.00 E 2.00
			If TYPE('oXMl:_GNRERESPOSTAMSG:_NS1_TRESULTLOTE_GNRE:_NS1_RESULTADO:_NS1_GUIA:_NS1_ITENSGNRE:_NS1_ITEM') == 'O' .And. !SubStr(aResultSEF[nA,1],1,1) == "L"
				aValores := oXMl:_GNRERESPOSTAMSG:_NS1_TRESULTLOTE_GNRE:_NS1_RESULTADO:_NS1_GUIA:_NS1_ITENSGNRE:_NS1_ITEM:_NS1_VALOR
				aValores := Valores(aValores)
				cAtuMon		:= aValores[4]
				cJuros		:= aValores[3]
				cMulta		:= aValores[2]
				If TYPE('oXMl:_GNRERESPOSTAMSG:_NS1_TRESULTLOTE_GNRE:_NS1_RESULTADO:_NS1_GUIA:_NS1_DATALIMITEPAGAMENTO') == 'O' 
					cDtLimPgto	:= Alltrim(oXMl:_GNRERESPOSTAMSG:_NS1_TRESULTLOTE_GNRE:_NS1_RESULTADO:_NS1_GUIA:_NS1_DATALIMITEPAGAMENTO:TEXT)
					//tratamento para gravar data Limite de Pagamento na tabela
					cDtLimPgto:= Iif( !Empty( cDtLimPgto ),substr(cDtLimPgto,1,4) + substr(cDtLimPgto,6,2) + substr(cDtLimPgto,9,2), '')					
				ENdIf
				cSeek := PadR(SubStr(aResultSEF[nA,1],1,2),2) + PadR(SubStr(aResultSEF[nA,1],3,12),12)
				AtuSF6SE2( cSeek, aValores[1], cMulta , cJuros , cAtuMon , aValores[5] , cDtLimPgto )			
			
			// Guias emitidas via FISA214 2.00
			ElseIf TYPE('oXMl:_GNRERESPOSTAMSG:_NS1_TRESULTLOTE_GNRE:_NS1_RESULTADO:_NS1_GUIA:_NS1_ITENSGNRE:_NS1_ITEM') == 'A' .And. SubStr(aResultSEF[nA,1],1,1) == "L"
				aItens	:= oXMl:_GNRERESPOSTAMSG:_NS1_TRESULTLOTE_GNRE:_NS1_RESULTADO:_NS1_GUIA:_NS1_ITENSGNRE:_NS1_ITEM
				cAtuMon		:= 0
				cJuros		:= 0
				cMulta		:= 0
				For nX := 1 To Len(aItens)
					aValores 	 := aItens[nX]:_NS1_VALOR
					cCodReceita	 := aItens[nX]:_NS1_RECEITA:TEXT
					cChaveAcesso := aItens[nX]:_NS1_DOCUMENTOORIGEM:TEXT
					aValores := Valores(aValores)
					// Acumula valores para gravar no cabeçalho do lote da GNRE
					cAtuMon		+= aValores[4]
					cJuros		+= aValores[3]
					cMulta		+= aValores[2]
					If TYPE('oXMl:_GNRERESPOSTAMSG:_NS1_TRESULTLOTE_GNRE:_NS1_RESULTADO:_NS1_GUIA:_NS1_DATALIMITEPAGAMENTO') == 'O' 
						cDtLimPgto	:= Alltrim(oXMl:_GNRERESPOSTAMSG:_NS1_TRESULTLOTE_GNRE:_NS1_RESULTADO:_NS1_GUIA:_NS1_DATALIMITEPAGAMENTO:TEXT)
						//tratamento para gravar data Limite de Pagamento na tabela
						cDtLimPgto:= Iif( !Empty( cDtLimPgto ),substr(cDtLimPgto,1,4) + substr(cDtLimPgto,6,2) + substr(cDtLimPgto,9,2), '')
					EndIf
					// Se o documento de origem for chave acesso eu atualizo os dados.
					If Len(cChaveAcesso) == 44
						cAliasTmp := GetNextAlias()
						BeginSql Alias cAliasTmp
							SELECT SF6.R_E_C_N_O_ RECNO FROM %Table:SF3% SF3
							INNER JOIN %Table:SF6% SF6 ON
								F6_FILIAL = %xFilial:SF6%
								AND F6_DOC = F3_NFISCAL
								AND F6_SERIE = F3_SERIE
								AND F6_CLIFOR = F3_CLIEFOR
								AND F6_LOJA = F3_LOJA
								AND SF6.F6_CODREC = %Exp:cCodReceita%
								AND SF6.%NotDel%
							WHERE 
								F3_FILIAL = %xFilial:SF3%
								AND F3_CHVNFE = %Exp:cChaveAcesso%
								AND SF3.%NotDel%
						EndSql
						SF6->( DbGoTo( (cAliasTmp)->RECNO) )
						cSeek := SF6->F6_EST + SF6->F6_NUMERO
						// Grava informações da SEFAZ na Guia
						AtuSF6SE2( cSeek, aValores[1], aValores[2] , aValores[3] , aValores[4] , aValores[5] , cDtLimPgto )
						(cAliasTmp)->(DbCloSeArea())
					EndIf
				Next nX
				// Grava informações da SEFAZ no cabeçalho
				aId := TSSIDLote(aResultSEF[nA,1])
				If CIB->( DbSeek( xFilial("CIB") + aID[2] + aID[3]  ) )
					RecLock("CIB",.F.)
						CIB->CIB_JUROS := cJuros
						CIB->CIB_MULTA := cMulta
						CIB->CIB_ATUMON := cAtuMon
					CIB->(MsUnlock())	
				EndIf

			//Mais de uma guia transmitida juntas
			ElseIf TYPE('oXMl:_GNRERESPOSTAMSG:_NS1_TRESULTLOTE_GNRE:_NS1_RESULTADO:_NS1_GUIA') == 'A' .And. TYPE('oXMl:_GNRERESPOSTAMSG:_NS1_TRESULTLOTE_GNRE:_NS1_RESULTADO:_NS1_GUIA['+Str(nA)+']:_NS1_ITENSGNRE:_NS1_ITEM') == 'O' .And. !SubStr(aResultSEF[nA,1],1,1) == "L" 

				aValores	:= oXMl:_GNRERESPOSTAMSG:_NS1_TRESULTLOTE_GNRE:_NS1_RESULTADO:_NS1_GUIA[nA]:_NS1_ITENSGNRE:_NS1_ITEM:_NS1_VALOR
				aValores := Valores(aValores)
				cAtuMon		:= aValores[4]
				cJuros		:= aValores[3]
				cMulta		:= aValores[2]
				If TYPE('oXMl:_GNRERESPOSTAMSG:_NS1_TRESULTLOTE_GNRE:_NS1_RESULTADO:_NS1_GUIA['+Str(nA)+']:_NS1_DATALIMITEPAGAMENTO') == 'O' 
					cDtLimPgto	:= Alltrim(oXMl:_GNRERESPOSTAMSG:_NS1_TRESULTLOTE_GNRE:_NS1_RESULTADO:_NS1_GUIA[nA]:_NS1_DATALIMITEPAGAMENTO:TEXT)
					//tratamento para gravar data Limite de Pagamento na tabela
					cDtLimPgto:= Iif( !Empty( cDtLimPgto ),substr(cDtLimPgto,1,4) + substr(cDtLimPgto,6,2) + substr(cDtLimPgto,9,2), '')					
				ENdIf
				cSeek := PadR(SubStr(aResultSEF[nA,1],1,2),2) + PadR(SubStr(aResultSEF[nA,1],3,12),12)
				AtuSF6SE2( cSeek, aValores[1], cMulta , cJuros , cAtuMon , aValores[5] , cDtLimPgto )		

			EndIf

		EndIf
	Else
		Return
	Endif
Next

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Valores
Retorna os valores atualizados da guia com base no ResultSef do metodo Retornar (TSSGNRE)
@return aRet 1-Principal  2-Multa  3-Juros 4-Atumonetaria 5-Total
@author Raphael Augustos
@since 10/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Valores( aVal )
Local nX	:= 1
Local aRet  := {0,0,0,0,0}
Local aValores

aValores := aVal

If ValType( aValores ) == "A"
	For nX := 1 To Len(aValores)
		If Valtype(aValores[nX]) <> 'O' 
			Loop
		Endif	
		ProcValor( aValores[nX], @aRet )
	Next nX

ElseIf ValType( aValores ) == "O"
	ProcValor( aValores, @aRet )	

EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcValor
Rotina interna para relaizar o tratamento dos valores atualizados da 
guia com base no ResultSef do metodo Retornar (TSSGNRE)
@return aRet 1-Principal  2-Multa  3-Juros 4-Atumonetaria 5-Total
@author  Yuri Fortunato Palacio
@since   06/11/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcValor(oValor, aVlrBase )
	If oValor:_Tipo:text == "11" //Principal
		aVlrBase[1]	:= Val(oValor:text)
	ElseIf oValor:_Tipo:text == "31" // Multa
		aVlrBase[2]	:= Val(oValor:text)
	ElseIf oValor:_Tipo:text == "41" // Juros
		aVlrBase[3]	:= Val(oValor:text)
	ElseIf oValor:_Tipo:text == "51" // Atumonetaria
		aVlrBase[4]	:= Val(oValor:text)
	ElseIf oValor:_Tipo:text == "21" // Total
		aVlrBase[5]	:= Val(oValor:text)
	EndIf
Return aVlrBase

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSF6SE2
Atualiza os valores da SF6 E SE2
@author Raphael Augustos
@since 10/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
 
Static Function AtuSF6SE2(cSeek,nPrincipal,nMulta,nJuros,nAtuMon,nTotal,cDtLimPgto)
local lDtLimi		:= SF6->(FieldPos("F6_DTLIMI")) > 0
Default cSeek 		:= ""
Default nPrincipal 	:= 0
Default nMulta 		:= 0
Default nJuros 		:= 0
Default nAtuMon 	:= 0
Default nTotal 		:= 0
Default nLinha 		:= ""
Default cDtLimPgto	:= ""

SF6->(dbSetOrder(1))
If SF6->(dbSeek(xFilial("SF6") + cSeek ))
	RecLock("SF6",.F.)
		SF6->F6_ATMON   := Iif ( SF6->F6_ATMON==0,cAtuMon, SF6->F6_ATMON)
		SF6->F6_JUROS   := Iif ( SF6->F6_JUROS==0,cJuros	, SF6->F6_JUROS )
		SF6->F6_MULTA   := Iif ( SF6->F6_MULTA==0,cMulta	, SF6->F6_MULTA )
		If lDtLimi
			SF6->F6_DTLIMI := STOD(cDtLimPgto)
		Endif
	MsUnlock()
	SE2->(dbSetOrder(1))
	If SE2->(dbSeek(xFilial("SE2")+Alltrim(SF6->F6_NUMERO)))
		RecLock("SE2",.F.)
			SE2->E2_CORREC := iif ( SE2->E2_CORREC==0,cAtuMon	, SE2->E2_CORREC)
			SE2->E2_MULTA  := iif ( SE2->E2_MULTA ==0,cJuros	, SE2->E2_MULTA )
			SE2->E2_JUROS  := iif ( SE2->E2_JUROS ==0,cMulta	, SE2->E2_JUROS )
		MsUnlock()
	Endif
Endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSF6SE2
Função identica a TSSXmlParser (compartilhada pelo time do TSS) para fazer a tratatica do xml para que não seja levado carater especial para a função XmlParser

@param	cXml	XML que será feito a validação 
		cExp	Compatibilização
		cAviso	Mensagem de aviso retornada pelo XmlParser()
		cErro	Mensagem de erro retornada pelo XmlParser()

@return	oXml	Objeto com o parser do XML feito

@adilson.roberto
@since 08/08/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GnreParser( cXmlResult, cExp, cError, cWarning )

Local oXml    

DEFAULT cExp		:= ""                             
DEFAULT cWarning	:= ""  
DEFAULT cError		:= "" 

/*Retira e valida algumas informações e caracteres indesejados para o parse*/
cXmlResult := XmlClean(cXmlResult)  
 
/*Faz o parser do XML*/
oXml := XmlParser(cXmlResult,"_",@cError,@cWarning)    

//Em caso de Falha no parser, verifica se há codificação OEM no XML
if(oXml == nil)
	cXmlResult := OEMToANSI( cXmlResult )
	oXml := XmlParser(cXmlResult,"_",@cError,@cWarning)
endif

Return oXml

//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} XmlClean

Função compartilhada pelo time de TSS.
Retira e valida algumas informações e caracteres indesejados para 
o parse do XML.

@author adilson.roberto
@since 08/08/2022
@version 1.0 

@param	cXml	XML que será feito a validação e a retirada dos
				caracteres especiais

@return	cRetorno	XML limpo
/*/
//-------------------------------------------------------------------

Static Function XmlClean( cXml )
    
Local cRetorno		:= "" 

DEFAULT cXml		:= ""

If ( !Empty(cXml) )

	cRetorno := cXml 

	/*
	< - &lt; 
	> - &gt; 
	& - &amp; 
	" - &quot; 
	' - &#39;
	' - &apos;
	*/
	If !( "&amp;" $ cRetorno .or. "&lt;" $ cRetorno .or. "&gt;" $ cRetorno .or. "&quot;" $ cRetorno .or. "&#39;" $ cRetorno .or. "&apos;" $ cRetorno)
		/*Retira caracteres especiais e faz a substituição*/
		cRetorno := StrTran(cRetorno,"&","&amp;amp;")   
	EndIf      
	
EndIf

Return cRetorno     
                 
//-------------------------------------------------------------------


