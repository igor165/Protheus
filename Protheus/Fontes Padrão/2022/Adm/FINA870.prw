#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "FINA870.CH"
#include "FILEIO.CH"
#include "SIGAWIN.CH"

/*{Protheus.doc}FINA870
@author Kaique Schiller
@since 22/06/2015
@version P12
@project Inovação Controladoria
Aglutinação de Titulos - INSS.
*/
//-------------------------------------------------------------------
Function FINA870()
	Local oBrowse 	:= NIL
	Local cFiltro   := "Alltrim(E2_ORIGEM) == 'FINA870' "
	Local lFilBrw   := SuperGetMv("MV_BRW870",.F.,.T.) 
	Private aRotina	:= MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SE2")
	oBrowse:SetDescription(STR0001) //"Aglutinação de Títulos - INSS"
	oBrowse:AddLegend( 'E2_SALDO = 0' , 'RED', STR0022 )//"Titulo baixado"
	oBrowse:AddLegend( 'E2_SALDO > 0' , 'GREEN' , STR0023)//"Titulo em aberto"

	If lFilBrw
		oBrowse:SetFilterDefault(cFiltro)
	Else	
		oBrowse:AddLegend( 'Alltrim(E2_ORIGEM) = "FINA870" ', 'BLUE', STR0020 )//"Titulo aglutinador de INSS"
	Endif

	oBrowse:Activate()

Return

/*{Protheus.doc}MenuDef
Crição dos menus
@author Kaique Schiller
@since 22/06/2015
@version P12
@return aRotina - Vetor com as opções da Rotina do Vetor
@project Inovação Controladoria
*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0019      Action 'FINA870M' 	OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina Title STR0003	  Action 'FINA870A'  	OPERATION 2 ACCESS 0 //"Emitir Guia"
	ADD OPTION aRotina Title STR0004	  Action 'FIN870INC'	OPERATION 3 ACCESS 0 //"Aglutinar"
	ADD OPTION aRotina Title STR0005	  Action 'FINR871' 		OPERATION 4 ACCESS 0 //"Relatório"
	ADD OPTION aRotina Title STR0006	  Action 'FIN870CAN' 	OPERATION 5 ACCESS 0 //"Cancelar"
	
Return aRotina

/*{Protheus.doc}ModelDef
Crição dos menus
@author Kaique Schiller
@since 22/06/2015
@version P12
@return ModelDef - Definição do Modelo de Dados.
@project Inovação Controladoria
*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruMst	:= FWFormStruct(1,'SE2', { |x| ALLTRIM(x) $ 'E2_NUM, E2_PARCELA, E2_PREFIXO, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_EMISSAO, E2_VENCREA, E2_SALDO, E2_VALOR' } )
	Local oStruSE2  := FWFormStruct(1,'SE2', { |x| ALLTRIM(x) $ 'E2_NUM, E2_PARCELA, E2_PREFIXO, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_EMISSAO, E2_VENCREA, E2_RETINS, E2_CNPJRET' } )
	Local oModel
	Local bLoad     := {|oGridModel, lCopia| LoadFWM(oGridModel, lCopia)}	

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'FINA870',/*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'SE2MASTER', /*cOwner*/, oStruMst )

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'SE2DETAIL', 'SE2MASTER', oStruSE2, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, bLoad )

	//Define que o submodelo não será gravavél (será apenas para visualização).
	oModel:GetModel('SE2MASTER'):SetOnlyQuery( .T. )

	// Adiciona a descricao do Modelo de Dados
	oModel:GetModel( 'SE2MASTER' ):SetDescriptadion( STR0026 )//"Titulo aglutinador"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
	oModel:GetModel( 'SE2DETAIL' ):SetDescription( STR0027 )//"Titulos aglutinados"

Return oModel

/*{Protheus.doc}ViewDef
Crição dos menus
@author Kaique Schiller
@since 22/06/2015
@version P12
@return ViewDef - Definição da Interface da Rotina.
@project Inovação Controladoria
*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oStruMst	:= FWFormStruct(2,'SE2', { |x| ALLTRIM(x) $ 'E2_NUM, E2_PARCELA, E2_PREFIXO, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_EMISSAO, E2_VENCREA, E2_SALDO, E2_VALOR' } )
	Local oStruSE2  := FWFormStruct(2,'SE2', { |x| ALLTRIM(x) $ 'E2_NUM, E2_PARCELA, E2_PREFIXO, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_EMISSAO, E2_VENCREA, E2_RETINS, E2_CNPJRET' } )
	Local oModel    := FWLoadModel( 'FINA870' )
	Local oView

	oStruMst:SetNoFolder()

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('VIEW_SE2',oStruMst, 'SE2MASTER' )
	oView:AddGrid("VIEW_SE2T",oStruSE2,  "SE2DETAIL")

	If RetGlbLGPD("E2_NOMFOR")
		oStruSE2:SetProperty( "E2_NOMFOR"	, MVC_VIEW_OBFUSCATED , .T.  )
	Endif

	If RetGlbLGPD("E2_CNPJRET")
		oStruSE2:SetProperty( "E2_CNPJRET"	, MVC_VIEW_OBFUSCATED , .T.  )
	Endif

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELAPAI' , 30 )
	oView:CreateHorizontalBox( 'TELAFIL' , 70 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_SE2', 'TELAPAI' )
	oView:SetOwnerView( 'VIEW_SE2T', 'TELAFIL' )

	oView:EnableTitleView('VIEW_SE2',STR0020)//"Titulo Aglutinador"
	oView:EnableTitleView('VIEW_SE2T',STR0027)//"Titulos aglutinados"

Return oView

/*{Protheus.doc}FIN870INC
Processamento de Aglutinação dos Títulos - INSS
@author Kaique Schiller
@since 22/06/2015
@version P12
*/
//-------------------------------------------------------------------
Function FIN870INC()
	Local aSelFil	:= {}
	Local aTitBx	:= {}
	Local aSaveArea	:= GetArea()
	Local cAliasQry := GetNextAlias()
	Local cQuery	:= ""
	Local cRetins 	:= ""
	Local cTipo		:= ""
	Local cCnpjRet  := ""
	Local cFilInss	:= ""
	Local cProces 	:= ""
	Local nTotTit	:= 0
	Local cNumAgl	:= ""
	Local aAreaSM0  := SM0->(GetArea())  // Salva a area do SM0
	Local cSavFil   := cFilAnt
	Local lVerLibBx := SuperGetMv("MV_CTLIPAG",.F.,.F.)
	Local nVlMinLib := SuperGetMv('MV_VLMINPG',.F., 0)

	If !Pergunte("FINA870",.T.)
		Return
	Endif

	If MV_PAR01 > MV_PAR02
		Help(" ",1,"FIN870INC",,STR0007,1,0) //"Data inicial maior que a data final"
		Return
	Elseif MV_PAR02 < MV_PAR01
		Help(" ",1,"FIN870INC",,STR0008,1,0) //"Data final menor que a data Incial"
		Return
	Elseif MV_PAR03 < MV_PAR01
		Help(" ",1,"FIN870INC",,STR0009,1,0) //"Data de vencimento da aglutinação menor que a data inicio"
		Return
	Endif

	cQuery := "SELECT E2_FILIAL, E2_EMISSAO, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_SALDO, E2_EMISSAO, E2_RETINS, E2_CNPJRET, E2_VALOR, E2_FORNECE, E2_LOJA, E2_FILORIG, E2_TITPAI "
	cQuery += "FROM " + RetSqlName('SE2') +" SE2 "
	cQuery += "WHERE "
	If MV_PAR04 == 1 //Seleciona Filial.
		aSelFil := AdmGetFil()
		If Empty(aSelFil)
			Return
		Else
			cQuery += "E2_FILIAL "+GetRngFil(aSelFil,"SE2")+" AND "
		Endif
	Else
		cQuery += "E2_FILIAL = '" + XFilial("SE2") + "' AND "
	Endif

	// Trata liberacao para baixa
	If lVerLibBx
		cQuery += "(E2_DATALIB <> ' ' "
		cQuery += "OR (E2_SALDO+E2_SDACRES-E2_SDDECRE<="+ALLTRIM(STR(nVlMinLib,17,2))+")) AND "
	Endif

	cQuery += "E2_TIPO IN ('INS','INA', 'INP') AND "
	cQuery += "E2_SALDO > 0 AND "
	cQuery += "E2_ORIGEM <> 'FINA870 ' AND "
	cQuery += "E2_RETINS <> ' ' AND "
	cQuery += "E2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND "
	cQuery += "SE2.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY E2_FILIAL,E2_TIPO,E2_CNPJRET,E2_RETINS"

	cQuery := ChangeQuery(cQuery)

	If Select(cAliasQry) > 0
		(cAliasQry)->(DbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))

	If (cAliasQry)->(!Eof())
		cProces := FIN870Conf("FWM","FWM_PROCES")
	Endif

	cNumAgl := "000001"
	cFilInss := (cAliasQry)->E2_FILORIG
	cRetins	 := (cAliasQry)->E2_RETINS
	cTipo	 := (cAliasQry)->E2_TIPO
	cCnpjRet := (cAliasQry)->E2_CNPJRET

	While (cAliasQry)->(!Eof())
		
		cFilAnt := cFilInss

		DbSelectArea("SE2")
		SE2->(DbSetOrder(1))
		If SE2->(DbSeek(XFilial("SE2")+(cAliasQry)->E2_TITPAI))
			If SA2->(DbSeek(xFilial("SA2",SE2->E2_FILORIG)+SE2->E2_FORNECE+SE2->E2_LOJA))
				If SA2->A2_TIPO == "J"
					If cFilInss == (cAliasQry)->E2_FILORIG .AND. cRetins == (cAliasQry)->E2_RETINS .AND. cCnpjRet == (cAliasQry)->E2_CNPJRET .AND. cTipo == (cAliasQry)->E2_TIPO 
						If (cAliasQry)->E2_TIPO == "INA" .AND. F090PagINA((cAliasQry)->E2_FILIAL+(cAliasQry)->E2_PREFIXO+(cAliasQry)->E2_NUM+(cAliasQry)->E2_PARCELA+(cAliasQry)->E2_TIPO+(cAliasQry)->E2_FORNECE+(cAliasQry)->E2_LOJA)
							nTotTit := nTotTit-(cAliasQry)->E2_VALOR
						Else
							nTotTit := nTotTit+(cAliasQry)->E2_VALOR
						Endif
						Aadd(aTitBx,(cAliasQry)->E2_FILIAL+(cAliasQry)->E2_PREFIXO+(cAliasQry)->E2_NUM+(cAliasQry)->E2_PARCELA+(cAliasQry)->E2_TIPO+(cAliasQry)->E2_FORNECE+(cAliasQry)->E2_LOJA)
					Else
						FIN870AGL(nTotTit,aTitBx,cProces,cRetins,cCnpjRet,cNumAgl, cTipo)
						If cNumAgl == ""
							cNumAgl := "000001"
						Else
							cNumAgl := Soma1(cNumAgl)			
						Endif
						nTotTit := (cAliasQry)->E2_VALOR
						aTitBx	:= {}
						cRetins  := (cAliasQry)->E2_RETINS
						cCnpjRet := (cAliasQry)->E2_CNPJRET
						cTipo	 := (cAliasQry)->E2_TIPO
						Aadd(aTitBx,(cAliasQry)->E2_FILIAL+(cAliasQry)->E2_PREFIXO+(cAliasQry)->E2_NUM+(cAliasQry)->E2_PARCELA+(cAliasQry)->E2_TIPO+(cAliasQry)->E2_FORNECE+(cAliasQry)->E2_LOJA)
					Endif
				ElseIf SA2->A2_TIPO == "F"
					If cFilInss == (cAliasQry)->E2_FILORIG .AND. cRetins == (cAliasQry)->E2_RETINS .AND. cTipo == (cAliasQry)->E2_TIPO 
						If (cAliasQry)->E2_TIPO == "INA" .AND. F090PagINA((cAliasQry)->E2_FILIAL+(cAliasQry)->E2_PREFIXO+(cAliasQry)->E2_NUM+(cAliasQry)->E2_PARCELA+(cAliasQry)->E2_TIPO+(cAliasQry)->E2_FORNECE+(cAliasQry)->E2_LOJA)
							nTotTit := nTotTit-(cAliasQry)->E2_VALOR
						Else	
							nTotTit := nTotTit+(cAliasQry)->E2_VALOR
						Endif
						Aadd(aTitBx,(cAliasQry)->E2_FILIAL+(cAliasQry)->E2_PREFIXO+(cAliasQry)->E2_NUM+(cAliasQry)->E2_PARCELA+(cAliasQry)->E2_TIPO+(cAliasQry)->E2_FORNECE+(cAliasQry)->E2_LOJA)
					Else
						FIN870AGL(nTotTit,aTitBx,cProces,cRetins,cCnpjRet,cNumAgl, cTipo)
						If cNumAgl == ""
							cNumAgl := "000001"
						Else
							cNumAgl := Soma1(cNumAgl)			
						Endif
						nTotTit := (cAliasQry)->E2_VALOR
						aTitBx	:= {}
						cRetins  := (cAliasQry)->E2_RETINS
						cTipo	 := (cAliasQry)->E2_TIPO
						Aadd(aTitBx,(cAliasQry)->E2_FILIAL+(cAliasQry)->E2_PREFIXO+(cAliasQry)->E2_NUM+(cAliasQry)->E2_PARCELA+(cAliasQry)->E2_TIPO+(cAliasQry)->E2_FORNECE+(cAliasQry)->E2_LOJA)
					Endif
				Endif
			Endif
		Endif
		
		cFilAnt := (cAliasQry)->E2_FILORIG
		SM0->( DbSeek( cEmpAnt + (cAliasQry)->E2_FILORIG ) )
		
		(cAliasQry)->(DbSkip())
		cFilInss := (cAliasQry)->E2_FILORIG
		
		If (cAliasQry)->(Eof())
			cFilAnt := cSavFil
			FIN870AGL(nTotTit,aTitBx,cProces,cRetins,cCnpjRet,cNumAgl, cTipo)
		Endif
	EndDo

	(cAliasQry)->(DBCloseArea())

	RestArea(aSaveArea)

	cFilAnt := cSavFil
	SM0->(RestArea(aAreaSM0))

	If INCLUI
		MBrChgLoop(.F.) // Evita que a operação seja reiniciada pela mBrowse
	EndIf

Return(Nil)

/*{Protheus.doc}FIN870AGL
Aglutinação dos Títulos - INSS
@author Kaique Schiller
@since 22/06/2015
@version P12
*/
//-------------------------------------------------------------------
Static Function FIN870AGL(nTotTit,aTitBx,cProces,cRetins,cCnpjRet,cNumAgl, cTipoAgi)
	Local aTitAgl 	 := {}
	Local cChaveSE2  := ""
	Local cChvFK7Agl := ""
	Local cNumInss	 := ""
	Local dDtAgl	 := cTod("  /  /  ")
	Local cPrefixo   := PadR( "AGI", 	TamSX3("E2_PREFIXO")[1], "" )
	Local cParcela   := PadR( "", 	TamSX3("E2_PARCELA")[1], "" )
	Local cTipo	     := Iif(cTipoAgi = "INP", PadR( "INP", TamSX3("E2_TIPO")[1], "" ), PadR( MVINSS, TamSX3("E2_TIPO")[1], "" ))
	Local cFornece   := Padr(SuperGetMv("MV_FORINSS",.T.,"INPS" ), TamSX3("E2_FORNECE")[1]) 
	Local cLojaImp   := PadR( "00", 	TamSX3("A2_LOJA")[1], "0" )
	Local cNaturez   := Iif(cTipoAgi = "INP", &(GetMv("MV_INSP")), &(GetMv("MV_INSS")) )

	Default nTotTit  := 0
	Private cFileLog := ""
	Private cPath	 := ""
	Private lMsErroAuto := .F.

	If nTotTit < 1
		Return
	Endif

	Pergunte("FINA870",.F.)

	dDtAgl := If(!Empty(MV_PAR03),MV_PAR03,Ddatabase)

	DbSelectArea("SE2")
	SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

	cNumInss := FIN870Conf("SE2","E2_NUM", cPrefixo)

	If !SE2->(DbSeek(xFilial("SE2")+cPrefixo+cNumInss+cParcela+cTipo+cFornece+cLojaImp))
		
		aAdd(aTitAgl, {"E2_FILIAL" 	,xFilial("SE2")			,NIL})
		aAdd(aTitAgl, {"E2_NUM"    	,cNumInss				,NIL})
		aAdd(aTitAgl, {"E2_PREFIXO"	,cPrefixo					,NIL})
		aAdd(aTitAgl, {"E2_PARCELA"	,cParcela					,NIL})
		aAdd(aTitAgl, {"E2_TIPO"   	,cTipo					,NIL})
		aAdd(aTitAgl, {"E2_NATUREZ"	,cNaturez			,NIL})
		aAdd(aTitAgl, {"E2_FORNECE"	,cFornece				,NIL})
		aAdd(aTitAgl, {"E2_LOJA"   	,cLojaImp				,NIL})
		aAdd(aTitAgl, {"E2_EMISSAO"	,Ddatabase				,NIL})
		aAdd(aTitAgl, {"E2_VENCTO"	,dDtAgl					,NIL})
		aAdd(aTitAgl, {"E2_VENCREA"	,DataValida(dDtAgl,.T.)	,NIL})
		aAdd(aTitAgl, {"E2_VENCORI"	,DataValida(dDtAgl,.T.)	,NIL})
		aAdd(aTitAgl, {"E2_EMIS1"  	,Ddatabase				,NIL})
		aAdd(aTitAgl, {"E2_MOEDA"  	,1						,NIL})
		aAdd(aTitAgl, {"E2_VALOR"  	,nTotTit				,NIL})
		aAdd(aTitAgl, {"E2_VLCRUZ" 	,nTotTit				,NIL})
		aAdd(aTitAgl, {"E2_ORIGEM" 	,"FINA870 "				,NIL})
		aAdd(aTitAgl, {"E2_LA" 		,"S"					,NIL})
		aAdd(aTitAgl, {"E2_RETINS" 	,cRetins				,NIL})
		aAdd(aTitAgl, {"E2_CNPJRET" ,cCnpjRet				,NIL})
		
		Begin Transaction

		MSExecAuto({|x, y| FINA050(x, y)}, aTitAgl, 3)
			
		cFileLog := NomeAutoLog()
		cPath := ""

		If !Empty(cFileLog)
			aTitBx := {}
			DisarmTransaction()
			MostraErro(cPath,cFileLog)
			Return
		Else 
			cChaveSE2  := xFilial("SE2")+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA
			cChvFK7Agl := FINGRVFK7("SE2",cChaveSE2)	
			If cChvFK7Agl <> ""
				FIN870BXP(cNumAgl,cChvFK7Agl,aTitBx,cProces) //Realiza a Baixa
			Endif
		Endif

		End Transaction

	Endif

Return(Nil)

/*{Protheus.doc}FIN870BXP
Baixa dos Títulos - INSS
@author Kaique Schiller
@since 22/06/2015
@version P12
*/
//-------------------------------------------------------------------
Static Function FIN870BXP(cNumAgl,cChvFK7Agl,aTitBx,cProces)
	Local nX		   := 0
	Local aBaixa	   := {}
	Local aAreaSE2	   := SE2->(GetArea())
	Local cChvFK7Bx    := ""
	Local cChaveBx	   := ""
	Default cNumAgl	   := ""
	Default cChvFK7Agl := ""
	Default aTitBx     := {}
	Private lMsErroAuto := .F.

	If aTitBx <> {}
		DbSelectArea("SE2")
		SE2->(DbSetOrder(1))
		FIN870MotBx("AGL","AGLUT INS","PNNN")
	Else
		Return
	Endif

	For nX := 1 To Len(aTitBx)
		If SE2->(DbSeek(aTitBx[nX]))
			If Ddatabase < SE2->E2_EMISSAO
				Help(" ",1,"FIN870BXP",,STR0010,1,0) //"DataBase menor que a Emissão do Título, Altere o Database"
				DisarmTransaction()
				Return
			Endif
			Aadd(aBaixa, {"E2_FILIAL" 	, SE2->E2_FILIAL 	, Nil})
			Aadd(aBaixa, {"E2_PREFIXO" 	, SE2->E2_PREFIXO 	, Nil})
			Aadd(aBaixa, {"E2_NUM" 		, SE2->E2_NUM 		, Nil})
			Aadd(aBaixa, {"E2_PARCELA" 	, SE2->E2_PARCELA 	, Nil})
			Aadd(aBaixa, {"E2_TIPO" 	, SE2->E2_TIPO 		, Nil})
			Aadd(aBaixa, {"E2_FORNECE" 	, SE2->E2_FORNECE 	, Nil})
			Aadd(aBaixa, {"E2_LOJA" 	, SE2->E2_LOJA 		, Nil})
			Aadd(aBaixa, {"AUTMOTBX" 	, "AGL" 			, Nil})
			Aadd(aBaixa, {"AUTDTBAIXA" 	, dDataBase 		, Nil}) 
			Aadd(aBaixa, {"AUTDTCREDITO", dDataBase 		, Nil})
			Aadd(aBaixa, {"AUTHIST" 	, "Agl. Tit. Pag."  , Nil})
			Aadd(aBaixa, {"AUTVLRPG" 	, SE2->E2_SALDO 	, Nil})
		Endif
		

		Begin Transaction

		MsExecAuto({|x,y| FINA080(x,y)}, aBaixa, 3)

		If lMsErroAuto
			MOSTRAERRO()
			DisarmTransaction()
			Return
		Else
			aBaixa    := {}
			cChaveBx  := SE2->E2_FILIAL+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA
			cChvFK7Bx := FINGRVFK7("SE2",cChaveBx)
			If cChvFK7Bx <> ""
				DbSelectArea("FWM")
				FWM->(DbSetorder(1))
				If !FWM->(DbSeek(xFilial("FWM")+cProces+cNumAgl+cChvFK7Bx))
					RecLock("FWM",.T.)
					FWM->FWM_FILIAL := xFilial("FWM")
					FWM->FWM_PROCES	:= cProces
					FWM->FWM_SUBPRO := cNumAgl
					FWM->FWM_FK7ORI := cChvFK7Bx
					FWM->FWM_FK7DES := cChvFK7Agl
					FWM->FWM_STATUS := "1" 
					FWM->FWM_EMISS 	:= dDataBase
					FWM->(MsUnLock())
				Endif
			Endif
		EndIf
		End Transaction
	Next

	RestArea(aAreaSE2)

Return(Nil)

/*{Protheus.doc}FIN870MotBx
Motivo de Baixa.
@author Kaique Schiller
@since 22/06/2015
@version P12
*/
//-------------------------------------------------------------------
Static Function FIN870MotBx(cMot,cNomMot, cConfMot)
	Local lMotBxEsp	:= .F.
	Local aMotbx 	:= ReadMotBx(@lMotBxEsp)
	Local nHdlMot	:= 0
	Local I			:= 0
	Local cFile 	:= "SIGAADV.MOT"
	Local nTamLn	:= 19

	If lMotBxEsp
		nTamLn	:= 20
		cConfMot	:= cConfMot + "N"
	EndIf
	If ExistBlock("FILEMOT")
		cFile := ExecBlock("FILEMOT",.F.,.F.,{cFile})
	Endif

	If Ascan(aMotbx, {|x| Substr(x,1,3) == Upper(cMot)}) < 1
		nHdlMot := FOPEN(cFile,FO_READWRITE)
		If nHdlMot <0
			HELP(" ",1,"SIGAADV.MOT")
			Final("SIGAADV.MOT")
		Endif
	
		nTamArq:=FSEEK(nHdlMot,0,2)	// VerIfica tamanho do arquivo
		FSEEK(nHdlMot,0,0)			// Volta para inicio do arquivo

		For I:= 0 to  nTamArq step nTamLn // Processo para ir para o final do arquivo	
			xBuffer:=Space(nTamLn)
			FREAD(nHdlMot,@xBuffer,nTamLn)
		Next		
	
		fWrite(nHdlMot,cMot+cNomMot+cConfMot+chr(13)+chr(10))	
		fClose(nHdlMot)		
	EndIf

Return(Nil)

/*{Protheus.doc}FIN870Conf
Confirma a numeração.
@author Kaique Schiller
@since 22/06/2015
@version P12
*/
//-------------------------------------------------------------------
Static Function FIN870Conf(cTabGet,cCmpGet, cPrefixo)
	Local lRet 		:= .T.
	Local cNumConf	:= ""

	Default cPrefixo := ""

	While lRet
		cNumConf := GetSXENum(cTabGet, cCmpGet)
		ConfirmSx8()
		dbSelectArea(cTabGet)
		(cTabGet)->(dbSetOrder(1))
		If !(cTabGet)->(dbSeek(xFilial(cTabGet)+cPrefixo+cNumConf))
			Exit
		EndIf
	EndDo

Return(cNumConf)

/*{Protheus.doc}FIN870CAN
Cancelamento de Processo.
@author Kaique Schiller
@since 22/06/2015
@version P12
*/
//-------------------------------------------------------------------
Function FIN870CAN(cAlias,nRec,nOpc,lAutomato)
	Local cChaveSE2  := ""
	Local cChave		:= ""
	Local cAlsQry  := GetNextAlias()
	Local cAlsQry2 := ""
	Local cQry		 := ""
	Local cQry2		 := ""
	Local cFilSE2  	 := ""
	Local aPergs	 := {}
	Local aRet		 := {}
	Local aBarra	:= {}
	Local lRet		 := .T.
	Local aCancTit	 := {}
	Local aBxTit	 := {}
	Local nCont	:= 0 
	Local nPOs		:= 0 
	Local nPosAnt	:= 0 
	Local nTamChave:= 0
	Local aAreaSM0 := SM0->(GetArea())  // Salva a area do SM0
	Local cSavFil  := cFilAnt

	Private lMsErroAuto := .F.
	Private cFileLog := ""
	Private cPath	 := ""

	DEFAULT lAutomato := .F.

	If Alltrim(SE2->E2_ORIGEM) <> "FINA870"
		Help(" ",1,"F870NOTIT",,STR0024,1,0,,,,,,{STR0025})//"O titulo posicionado não faz parte de um processo de aglutinação"#"Posicionar sobre um titulo aglutinador"
		lRet := .F.
	Endif	

	If SE2->E2_SALDO < 0
		Help(" ",1,"FIN870CAN",,STR0011,1,0) //"Título baixado, Para cancelar a aglutinação deverá cancelar a baixa primeiro"
		lRet := .F.
	Else
		aAdd( aPergs ,{3,STR0012 ,"1",{STR0013, STR0014},50,'.T.',.T.})//"Cancelamento" ### "Tit. Posicionado" ### "Processo de Aglt."
	Endif

	If !lAutomato
		If lRet .AND. !ParamBox(aPergs ,STR0015,aRet)//"Cancelamento de Aglutinação"
			lRet := .F.
		EndIf
	Else
		If FindFunction("GetParAuto")
			aRet	:= GetParAuto("FINA870TestCase")
		EndIf
	EndIf

	If lRet
		cFilSE2 	:= COMPFILIAL("SE2", "FWM", SE2->E2_FILIAL)
		cChave 		:= SE2->E2_FILIAL+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA
		cChaveSE2 	:= FINGRVFK7("SE2",cChave)
		
		nTamChave	:= Len(cChave)
		For nCont := 1 to nTamChave	
			nPos := AT("|",Subs(cChave,nCont,nTamChave))
			nPosAnt += nPos
			AADD(aBarra,nPosAnt)
			nCont := nPosAnt
			If Len(aBarra) == 6 
				Exit
			Endif
		Next
		nCont := 0 
		nPos := 0 
		nPosAnt:= 0 
	Endif


	If lRet .AND. aRet[1] = 2
		
		DbSelectArea("FWM")
		FWM->(DbSetOrder(3))


		If FWM->(DbSeek(cFilSE2+cChaveSE2))
			cQry := "SELECT DISTINCT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_NATUREZ, E2_FORNECE, E2_LOJA, FWM_FK7DES, E2_SALDO "
			cQry += "FROM " + RetSqlName('FWM') + " FWM "
			cQry += "INNER JOIN " + RetSqlName('FK7') +" FK7 ON "
			cQry += "FK7.D_E_L_E_T_ 	= ' ' "
			cQry += "AND FK7.FK7_IDDOC 	= FWM.FWM_FK7DES "
			cQry += "INNER JOIN " + RetSqlName('SE2') +" SE2 ON "
			cQry += "SE2.D_E_L_E_T_ 	= ' ' "
			cQry += "AND SE2.E2_FILIAL = SUBSTRING(FK7_CHAVE,1,"+Alltrim(Str(aBarra[1]-1))+")"
			cQry += "AND SE2.E2_PREFIXO = SUBSTRING(FK7_CHAVE,"+Alltrim(Str(aBarra[1]+1))+","+Alltrim(Str(aBarra[2]-aBarra[1]-1))+")"
			cQry += "AND SE2.E2_NUM = SUBSTRING(FK7_CHAVE,"+Alltrim(Str(aBarra[2]+1))+","+Alltrim(Str(aBarra[3]-aBarra[2]-1))+")"
			cQry += "AND SE2.E2_PARCELA= SUBSTRING(FK7_CHAVE,"+Alltrim(Str(aBarra[3]+1))+","+Alltrim(Str(aBarra[4]-aBarra[3]-1))+")"
			cQry += "AND SE2.E2_TIPO= SUBSTRING(FK7_CHAVE,"+Alltrim(Str(aBarra[4]+1))+","+Alltrim(Str(aBarra[5]-aBarra[4]-1))+")"
			cQry += "AND SE2.E2_FORNECE= SUBSTRING(FK7_CHAVE,"+Alltrim(Str(aBarra[5]+1))+","+Alltrim(Str(aBarra[6]-aBarra[5]-1))+")"
			cQry += "AND SE2.E2_LOJA = SUBSTRING(FK7_CHAVE,"+Alltrim(Str(aBarra[6]+1))+","+STR(TamSx3("E2_LOJA")[1])+")"	
			cQry += "WHERE "
			cQry += "FWM.D_E_L_E_T_ 	= '' "
			cQry += "AND FWM_PROCES	 	= '"+FWM->FWM_PROCES+"' "
			cQry += "AND FWM_STATUS	 	= '1' "

			cQry := ChangeQuery(cQry)
			
			If Select(cAlsQry) > 0
				(cAlsQry)->(DbCloseArea())
			EndIf
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlsQry,.T.,.T.)
			
			While (cAlsQry)->(!Eof())
				If (cAlsQry)->E2_SALDO < 0 
					Help(" ",1,"FIN870CAN",,STR0011,1,0) //"Título baixado, Para cancelar a aglutinação deverá cancelar a baixa primeiro"
					lRet := .F.
					Exit
				Endif
				(cAlsQry)->(DbSkip())
				lRet := .T.
			EndDo
		Endif
	Endif

	If lRet
		If aRet[1] = 1
			aAdd(aCancTit, {"E2_PREFIXO"	,SE2->E2_PREFIXO			,NIL})
			aAdd(aCancTit, {"E2_NUM"    	,SE2->E2_NUM				,NIL})
			aAdd(aCancTit, {"E2_PARCELA"	,SE2->E2_PARCELA			,NIL})
			aAdd(aCancTit, {"E2_TIPO"   	,SE2->E2_TIPO				,NIL})
			aAdd(aCancTit, {"E2_NATUREZ"	,SE2->E2_NATUREZ			,NIL})
			aAdd(aCancTit, {"E2_FORNECE"	,SE2->E2_FORNECE			,NIL})
			aAdd(aCancTit, {"E2_LOJA"   	,SE2->E2_LOJA				,NIL})

			Begin Transaction

			MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aCancTit,, 5)

			aCancTit := {}
			cPath 	 := ""

			If 	lMsErroAuto
				cFileLog := NomeAutoLog()
				DisarmTransaction()
				MostraErro(cPath,cFileLog)
				lRet := .F.
			Endif

			End Transaction

		Else
			(cAlsQry)->(DbGoTop())
		
			Begin Transaction
			
			SE2->(DbSetOrder(1))
			While (cAlsQry)->(!Eof())
				If SE2->(DbSeek((cAlsQry)->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
					aAdd(aCancTit, {"E2_FILIAL"		,(cAlsQry)->E2_FILIAL	,NIL})
					aAdd(aCancTit, {"E2_PREFIXO"	,(cAlsQry)->E2_PREFIXO	,NIL})
					aAdd(aCancTit, {"E2_NUM"    	,(cAlsQry)->E2_NUM		,NIL})
					aAdd(aCancTit, {"E2_PARCELA"	,(cAlsQry)->E2_PARCELA	,NIL})
					aAdd(aCancTit, {"E2_TIPO"   	,(cAlsQry)->E2_TIPO		,NIL})
					aAdd(aCancTit, {"E2_NATUREZ"	,(cAlsQry)->E2_NATUREZ	,NIL})
					aAdd(aCancTit, {"E2_FORNECE"	,(cAlsQry)->E2_FORNECE	,NIL})
					aAdd(aCancTit, {"E2_LOJA"   	,(cAlsQry)->E2_LOJA		,NIL})
					
					cFilAnt	:= SE2->E2_FILORIG
					MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aCancTit,, 5)
		
					aCancTit := {}
					cFileLog := NomeAutoLog()
					cPath 	 := ""
		
					If !Empty(cFileLog)
						DisarmTransaction()
						MostraErro(cPath,cFileLog)
						lRet := .F.
						Exit
					Endif
				Endif
				(cAlsQry)->(DbSkip())
			EndDo

			End Transaction

			If (cAlsQry)->(Eof())
				(cAlsQry)->(DbCloseArea())
			Endif

		Endif
	Endif

	If lRet
		cAlsQry2 := GetNextAlias()

		DbSelectArea("FWM")
		FWM->(DbSetOrder(3))
		If FWM->(DbSeek(cFilSE2+cChaveSE2))
			cQry2 := "SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,E2_SALDO, FWM_FILIAL, FWM_PROCES, FWM_SUBPRO, FWM_FK7ORI "
			cQry2 += "FROM " + RetSqlName('FWM') + " FWM "
			cQry2 += "INNER JOIN " + RetSqlName('FK7') +" FK7 ON "
			cQry2 += "FK7.D_E_L_E_T_ 	 = ' ' "
			cQry2 += "AND FK7.FK7_IDDOC  = FWM.FWM_FK7ORI "
			cQry2 += "INNER JOIN " + RetSqlName('SE2') +" SE2 ON "
			cQry2 += "SE2.D_E_L_E_T_ 	 = ' ' "
			cQry2 += "AND SE2.E2_FILIAL = SUBSTRING(FK7_CHAVE,1,"+Alltrim(Str(aBarra[1]-1))+")"
			cQry2 += "AND SE2.E2_PREFIXO = SUBSTRING(FK7_CHAVE,"+Alltrim(Str(aBarra[1]+1))+","+Alltrim(Str(aBarra[2]-aBarra[1]-1))+")"
			cQry2 += "AND SE2.E2_NUM = SUBSTRING(FK7_CHAVE,"+Alltrim(Str(aBarra[2]+1))+","+Alltrim(Str(aBarra[3]-aBarra[2]-1))+")"
			cQry2 += "AND SE2.E2_PARCELA= SUBSTRING(FK7_CHAVE,"+Alltrim(Str(aBarra[3]+1))+","+Alltrim(Str(aBarra[4]-aBarra[3]-1))+")"
			cQry2 += "AND SE2.E2_TIPO= SUBSTRING(FK7_CHAVE,"+Alltrim(Str(aBarra[4]+1))+","+Alltrim(Str(aBarra[5]-aBarra[4]-1))+")"
			cQry2 += "AND SE2.E2_FORNECE= SUBSTRING(FK7_CHAVE,"+Alltrim(Str(aBarra[5]+1))+","+Alltrim(Str(aBarra[6]-aBarra[5]-1))+")"
			cQry2 += "AND SE2.E2_LOJA = SUBSTRING(FK7_CHAVE,"+Alltrim(Str(aBarra[6]+1))+","+STR(TamSx3("E2_LOJA")[1])+")"
			cQry2 += "WHERE "
			cQry2 += "FWM.D_E_L_E_T_ 	 = '' "
			cQry2 += "AND FWM_PROCES 	 = '"+FWM->FWM_PROCES+"' "
			If aRet[1] = 1
				cQry2 += "AND FWM_SUBPRO = '"+FWM->FWM_SUBPRO+"' "
			Endif
			cQry2 += "AND FWM_STATUS = '1' "
			cQry2 := ChangeQuery(cQry2)
			
			If Select(cAlsQry2) > 0
				(cAlsQry2)->(DbCloseArea())
			EndIf
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry2),cAlsQry2,.T.,.T.)
		Endif
	Endif

	If lRet
		If Select(cAlsQry2) > 0
			(cAlsQry2)->(DbGoTop())
			Begin Transaction
			
			SE2->(DbSetOrder(1))
			While (cAlsQry2)->(!Eof())
				If SE2->(DbSeek((cAlsQry2)->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
					Aadd(aBxTit, {"E2_FILIAL" 	, (cAlsQry2)->E2_FILIAL 	, Nil})
					Aadd(aBxTit, {"E2_PREFIXO" 	, (cAlsQry2)->E2_PREFIXO 	, Nil})
					Aadd(aBxTit, {"E2_NUM" 		, (cAlsQry2)->E2_NUM 		, Nil})
					Aadd(aBxTit, {"E2_PARCELA" 	, (cAlsQry2)->E2_PARCELA 	, Nil})
					Aadd(aBxTit, {"E2_TIPO" 	, (cAlsQry2)->E2_TIPO 		, Nil})
					Aadd(aBxTit, {"E2_FORNECE" 	, (cAlsQry2)->E2_FORNECE 	, Nil})
					Aadd(aBxTit, {"E2_LOJA" 	, (cAlsQry2)->E2_LOJA 		, Nil})
					
					cFilAnt	:= SE2->E2_FILORIG
					
					MSExecAuto({|x,y| FINA080(x,y)}, aBxTit, 5)
					
					aBxTit := {}
					If lMsErroAuto
						DisarmTransaction()
						MostraErro()
						lRet := .F.
						Exit
					Else
						DbSelectArea("FWM")
						FWM->(DbSetOrder(1)) //FWM_FILIAL+FWM_PROCES+FWM_SUBPRO+FWM_FK7ORI
						If FWM->(DbSeek((cAlsQry2)->(FWM_FILIAL+FWM_PROCES+FWM_SUBPRO+FWM_FK7ORI)))
							RecLock("FWM",.F.)
							FWM->FWM_STATUS := "2"
							FWM->(MsUnLock())
							lRet := .T.
						Endif
					Endif
					(cAlsQry2)->(DbSkip())
				Endif
			EndDo
				
			End Transaction
		
			If (cAlsQry2)->(Eof())
				(cAlsQry2)->(DbCloseArea())
			Endif
		EndIf
	Endif

	cFilAnt := cSavFil
	SM0->(RestArea(aAreaSM0))
  
Return(Nil)

//-------------------------------------------------------------------
/*/ {Protheus.doc} LoadFWM
Funcao de carregamento dos titulos que foram aglutinados

@param oGridModel - Model que chamou o bLoad
@param lCopia - Se é uma operacao de copia

@author Vitor Duca
@since 28/10/2019

@return Array com informacoes para composicao do grid
/*/
//-------------------------------------------------------------------
Static Function LoadFWM(oGridModel As Object, lCopia As Logical) As Array 
	Local aGrid 	As Array
	Local aCampos 	As Array
	Local aAux     	As Array
	Local cAlias   	As Character
	Local cQry	   	As Character
	Local cKeySE2   As Character
	Local oTmp  	As Object
	Local cChaveSe2 As Character
	Local aArea     As Array

	//inicialização das variaveis
	aGrid     := {}
	aCampos   := {}
	aAux      := {}
	cAlias    := CriaTrab(,.F.)
	cQry	  := ""
	cKeySE2   := xFilial("SE2",SE2->E2_FILORIG)+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA
	oTmp	  := NIL
	cChaveSe2 := ""
	aArea	  := GetArea()

	oTmp := FwTemporaryTable():New(cAlias)

	Aadd(aCampos, {"FK7ORI", "C", TamSX3("FWM_FK7ORI")[1],  0})
	oTmp:SetFields(aCampos)

	oTmp:Create()

	cQry += " SELECT FWM.FWM_FK7ORI FK7ORI, FWM.R_E_C_N_O_ RECNO FROM " + RetSqlName("FWM") + " FWM"
	cQry += " 	INNER JOIN " + RetSqlName("FK7") + " FK7 "
	cQry += " 	ON FK7.FK7_FILIAL = FWM.FWM_FILIAL "
	cQry += " 	AND FK7.FK7_IDDOC = FWM.FWM_FK7DES "
	cQry += " WHERE "
	cQry += " FWM.FWM_FILIAL = '" + xFilial("FWM") + "'"
	cQry += " AND FWM.D_E_L_E_T_ = ' ' "
	cQry += " AND FK7.FK7_CHAVE = '" + cKeySE2 + "'"
	cQry += " AND FK7.D_E_L_E_T_ = ' ' "
	cQry := ChangeQuery(cQry)
	MPSysOpenQuery(cQry, cAlias)
	
	FK7->(DbSetOrder(1))//FK7_FILIAL, FK7_IDDOC
	SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

	// Prepara estrutura de composicao do grid
	While !(cAlias)->(EoF())
		cChaveSe2 := ""
		If FK7->(dbSeek(xFilial("FK7")+(cAlias)->FK7ORI))
			cChaveSe2 := FK7->FK7_CHAVE
		Endif	
		cChaveSe2 := strtran(cChaveSe2,"|","")

		If SE2->(dbSeek(cChaveSe2))
			aAdd( aGrid , SE2->E2_NUM)
			aAdd( aGrid , SE2->E2_PARCELA)
			aAdd( aGrid , SE2->E2_PREFIXO)
			aAdd( aGrid , SE2->E2_TIPO)
			aAdd( aGrid , SE2->E2_FORNECE)
			aAdd( aGrid , SE2->E2_LOJA)
			aAdd( aGrid , SE2->E2_NOMFOR)
			aAdd( aGrid , SE2->E2_EMISSAO)
			aAdd( aGrid , SE2->E2_VENCREA)
			aAdd( aGrid , SE2->E2_RETINS)
			aAdd( aGrid , SE2->E2_CNPJRET)

			aAdd(aAux,{(cAlias)->RECNO, aGrid})
			(cAlias)->(dbSkip())
			aGrid := {}
		Endif	
	EndDo

	(cAlias)->(dbCloseArea())
	oTmp:Delete()
	oTmp := Nil

	FwFreeArray(aGrid)
	FwFreeArray(aCampos)
	RestArea(aArea)
	FwFreeArray(aArea)

Return aAux

//-----------------------------------------------------------------------------
/*/{Protheus.doc}FINA870M
Consulta processo de aglutinação de INSS.

@author Vitor Duca
@since  28/10/2019
@version 12
/*/	
//-----------------------------------------------------------------------------
Function FINA870M()
	Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

	If Alltrim(SE2->E2_ORIGEM) <> "FINA870"
		Help(" ",1,"F870NOTIT",,STR0024,1,0,,,,,,{STR0025})//"O titulo posicionado não faz parte de um processo de aglutinação"#"Posicionar sobre um titulo aglutinador"
	Else	
		FWExecView( STR0001 ,"FINA870", MODEL_OPERATION_VIEW,/**/,/**/,/**/,,aEnableButtons )
	EndIf	
	
	FwFreeArray(aEnableButtons)
Return 


//-----------------------------------------------------------------------------
/*/{Protheus.doc}COMPFILIAL
Retorna a Filial no formato certo para utilizar em tabelas compartilhas

@param cAliasOri - Alias da tabela de origem a ser comparada
@param cAliasDes - Alias da tabela de destino a ser comparada
@param cFilPos   - Filial do titulo posicionado

@author Adriano Sato
@since  04/03/2021
@version 12
/*/	
//-----------------------------------------------------------------------------
Function COMPFILIAL(cAliasOri as Character, cAliasDes as Character, cFilPos as Character)  as Character

Local cEstruOri	 := FWModeAccess(cAliasOri,1)+FWModeAccess(cAliasOri,2)+FWModeAccess(cAliasOri,3)
Local cEstruDes	 := FWModeAccess(cAliasDes,1)+FWModeAccess(cAliasDes,2)+FWModeAccess(cAliasDes,3)
Local nTamFilOri := Len(Alltrim(xFilial(cAliasOri)))
Local nTamFilDes := ""
Local cRetFil 	 := ""
Local lFilPosDif := xFilial(cAliasOri) == cFilPos

Default cAliasOri := ""
Default cAliasDes := ""
Default cFilPos   := ""

If lFilPosDif
	nTamFilDes := Len(Alltrim(xFilial(cAliasDes)))
Else
	nTamFilDes := Len(Alltrim(cFilPos))
EndIf

If cEstruOri == cEstruDes
	cRetFil := cFilPos
Else
	If nTamFilOri > nTamFilDes
		If lFilPosDif
			cRetFil := xFilial(cAliasDes)
		Else
			cRetFil := cFilPos
		EndIf
	Else
		If lFilPosDif
			cRetFil := xFilial(cAliasOri)
		Else
			cRetFil := cFilPos
		EndIf
	EndIf
Endif

Return cRetFil
