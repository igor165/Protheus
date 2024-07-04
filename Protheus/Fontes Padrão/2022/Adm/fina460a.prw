#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "FWBROWSE.CH"
#Include "ApWizard.ch"
#Include "FINA460A.CH"
#INCLUDE "FWLIBVERSION.CH"

#DEFINE OPER_BLOQUEAR		10
#DEFINE OPER_DESBLOQUEAR	11
#DEFINE OPER_CANCELAR		12
#DEFINE OPER_INCLUI			13
#DEFINE OPER_ALTERA			14
#DEFINE OPER_EFETIVAR		15
#DEFINE OPER_LIQUIDAR		16
#DEFINE OPER_RELIQUIDAR		17
#DEFINE OPER_VISUALIZAR		02
#DEFINE ENTER				Chr(13)+ Chr(10)

Static lValidou		:= .F.
Static __lComiLiq	:= NIL
Static __lTpComis	:= NIL
Static lJaMarcou	:= .F.
Static lMostraVA	:= .T.
Static lNoMark 		:= .F.
Static lCpoTxMoed 	:= .F.
Static lCpoFO1Ad	:= .F.
Static lPLSCTFIN	:= findFunction('PLSCTFIN')
Static cVl460Nt 	:= SuperGetMv("MV_VL460NT",.F.,"1")
Static __lPIXCanc   := FindFunction("PIXCancel")
Static __lMetric	:= .F.
Static __cFunBkp    := ""
Static __cFunMet	:= ""
Static __lJFilBco	:= NIL
Static __lGrvSEF	:= NIL // Indica se deve gravar SEF na liquidacao
Static __oQryFk1	:= NIL
Static __oQryFk5	:= NIL
Static __oStVldE1	:= NIL
Static __oStE1Par 	:= NIL

//Pontos de entrada - atenção para não repetir os 10 primeiros caracteres
Static __lF460FIL	:= NIL
Static __lF460MNU	:= NIL
Static __lf460Val	:= NIL
Static __lf460SE1	:= NIL
Static __lF460NUM	:= NIL
Static __lF460NCC	:= NIL
Static __lF460GNCC	:= NIL
Static __lSE5F460	:= NIL
Static __lF460GSEF	:= NIL
Static __lF460CTB	:= NIL
Static __lF460STI	:= NIL
Static __lNExbMsg	:= .F.
Static __lF070Tra   := NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA460A()
Cadastro de Simulação de liquidação a receber
@author lucas.oliveira
@since 13/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------
Function FINA460A(nPosArotina,xAutoCab,xAutoItens,xOpcAuto,xAutoFil,xNumLiq,xRotAutoVa)

Local oBrowse
Local cF460Fil := ""

Private lOpcAuto	:= (xOpcAuto <> Nil)
Private aRotina		:= {}
Private aPos   		:= {  15,  1, 70, 315 }
Private cCadastro	:= STR0001 //"Liquidação"
Private cLote		:= LoteCont("FIN")
Private lAltera		:= .F.
Private lhlplog 	:= .T.
Private aAutoCab	:= If(xAutoCab   <> Nil	,xAutoCab,  {})
Private aAutoItens	:= If(xAutoItens <> Nil ,xAutoItens,{})
Private nOpcAuto	:= If(xOpcAuto   <> Nil	,xOpcAuto,  0 )
Private cAutoFil	:= If(xAutoFil   <> Nil	,xAutoFil,  "")
Private cNumLiqCan	:= If(xNumLiq    <> Nil	,xNumLiq,   "")
Private aRotAutoVA	:= If(xRotAutoVA <> Nil	,xRotAutoVa,{})
Private lOracle 	:= "ORACLE" $ Upper(TcGetDB())
Private cMatApl 	:= " NULL "
Private nCodSer 	:= " NULL "
Private lMsgUnq		:= FWHasEai('FINA460') .AND. FWHasEai('FINA040')//indica se usa geração de título por mensagem unica.
Private cFilMsg		:= "2" //Filtra movimentos de msg unica
Private lRecalcula	:= .F.
Private nPergRepl   := 0
Private __nOpcOuMo  := 2
Private cFunOrig	:= ""

Default nPosArotina := 0

nMoeda := IIf(Type("nMoeda") == "U",1,nMoeda)

dbSelectArea("FO1")
lCpoFO1Ad := FO1->(ColumnPos("FO1_VLADIC")) > 0

DbSelectArea("FO2")
If ColumnPos( 'FO2_TIPO' ) == 0 
	
	HELP(" ",1,	STR0044 ,, STR0143 ,2,0,,,,,,{STR0144 + CRLF + STR0145 + CRLF + CRLF + STR0146 + CRLF +;
				STR0147 + CRLF +   STR0148 + CRLF + STR0149 + CRLF +;
				STR0150 + CRLF +   STR0151 + CRLF + STR0152 + CRLF + STR0153 })

	//"LIQUIDAÇÃO" # "Dicionário Desatualizado" # "Favor criar um novo campo com as" # "caracteristicas abaixo:" # "Campo: FO2_TIPO" #
	//"Tipo: Caracter" # "Tamanho: 3" # " Formato: @! " # 
	//"Título: Tipo" # "Consulta Padrão: 05" # "Obrigatório" # "Usado"

	Return .F. 
Endif
	
HelpLog(.t.)
SetKey (VK_F12,{|a,b| AcessaPerg("AFI460",.T.)})

MV_PAR09 := 1
pergunte("AFI460",.F.)

If nPosArotina > 0
	aRotina := MenuDef()
	dbSelectArea('SE1')
	bBlock := &( "{ || " + aRotina[ nPosArotina,2 ] + " }" )
	Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina)
Else
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias("FO0")
	oBrowse:SetDescription( (STR0001) ) // "Simulação de liquidação a receber"
	oBrowse:AddLegend( "FO0_STATUS=='2'"										,"RED"		,	(STR0002) )	// "Bloqueada"
	oBrowse:AddLegend( "FO0_STATUS=='1' .AND. FO0_DTVALI >= dDatabase"			,"GREEN"	,	(STR0003) )	// "Vigente"
	oBrowse:AddLegend( "FO0_STATUS=='1' .AND. FO0_DTVALI < dDatabase"			,"YELLOW"	,	(STR0005) )	// "Vencida"
	oBrowse:AddLegend( "FO0_STATUS=='4'"										,"WHITE"	,	(STR0006) )	// "Gerada"
	oBrowse:AddLegend( "FO0_STATUS=='5'"										,"BLACK"	,	(STR0007 + " / " + STR0004) )	// "Encerrada" / "Cancelada"

	//-- Filtra Browse
	if __lF460FIL == NIL
		__lF460FIL := ExistBlock("F460FIL")
	endIf
	If __lF460FIL
		cF460Fil := ExecBlock("F460FIL",.F.,.F.)
		If ValType(cF460Fil) == "C" .And. !Empty(cF460Fil)
			oBrowse:SetFilterDefault(cF460Fil)
		EndIf
	EndIf

	oBrowse:Activate()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Função responsavel pelo menu da rotina de simulação de liquidação a receber

@author lucas.oliveira
@since 13/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= {}
Local aRotAux	:= {}

ADD OPTION aRotina Title STR0008	Action 'F460AIncl(7)'    	OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title STR0011	Action 'F460AltSim(7)' 		OPERATION 4 ACCESS 0 //"Alterar" 	- Função de Recalculo
ADD OPTION aRotina Title STR0009	Action 'F460AEfet(8)'		OPERATION 4 ACCESS 0 //"Efetivar"	- Função de Recalculo
ADD OPTION aRotina Title STR0010	Action 'F460VerSim()'		OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title STR0012	Action 'F460ABlqCan(1)'		OPERATION 4 ACCESS 0 //"Bloquear"
ADD OPTION aRotina Title STR0013	Action 'F460ABlqCan(2)'		OPERATION 4 ACCESS 0 //"Estornar Bloqueio"

if __lF460MNU == NIL
	__lF460MNU := ExistBlock("F460MNU")
endIf
If __lF460MNU
	aRotAux := ExecBlock("F460MNU",.F.,.F.,{aRotina})
	If (ValType(aRotAux) == "A")
		aRotina := aClone(aRotAux)
	EndIf
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Função responsavel pelo modelo de dados da rotina de simulação de liquidação a receber

@author lucas.oliveira
@since 13/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStruFO0	:= FWFormStruct(1,"FO0")
Local oStruFO1	:= F460CpoFO1(1)
Local oStruFO2	:= FWFormStruct(1,"FO2")
Local aFO1Rel	:= {}
Local aFO2Rel	:= {}
Local aAuxFO0	:= aClone(oStruFO0:GetFields())
Local aAuxFO1	:= aClone(oStruFO1:GetFields())
Local aAuxFO2	:= aClone(oStruFO2:GetFields())
Local nX		:= 0
Local aTamVal	:= TamSx3("FO2_VALOR")
Local cCposBloc := ""
Local nTamRazao := TamSX3("A1_NOME")[1]
Local aTamNosNum := TamSX3("E1_NUMBCO")
Local aTamCodBar := TamSX3("E1_CODBAR")
Local aTamCCDeb  := TamSX3("E1_CCD")
Local aTamCCCred := TamSX3("E1_CCC")
Local aTamCTDeb  := TamSX3("E1_DEBITO")
Local aTamCTCred := TamSX3("E1_CREDIT")
Local aTamITDeb  := TamSX3("E1_ITEMD")
Local aTamITCred := TamSX3("E1_ITEMC")
Local aTamClDeb  := TamSX3("E1_CLVLDB")
Local aTamClCred := TamSX3("E1_CLVLCR")
Local aTamRegAca := TamSX3("E1_NUMRA")
Local aTamPerAca := TamSX3("E1_PERLET")
Local aTamMatApl := TamSX3("E1_IDAPLIC")
Local aTamClasse := TamSX3("E1_TURMA")
Local aTamItem   := TamSX3("E1_PRODUTO")
Local aTamContr	 := TamSX3("E1_CONTRAT")
Local aTamPort	 := TamSX3("E1_PORTADO")
Local aTamAgenc	 := TamSX3("E1_AGEDEP")
Local aTamConta	 := TamSX3("E1_CONTA")
Local aTamEmiss	 := TamSX3("E1_EMISSAO")
Local cEscrit    := ""
Local cCposVar   := ""
Local bBloco 	 := FwBuildFeature( STRUCT_FEATURE_VALID,'FA460TIPO("1")' )
Local lCpCalJur	 := FO0->(ColumnPos("FO0_CALJUR")) > 0 .And. FO2->(ColumnPos("FO2_TXCALC")) > 0 .And. FO2->(ColumnPos("FO2_VLRJUR")) > 0 // Proteção criada para versão 12.1.27
	
lOpcAuto := Iif(lOpcAuto == Nil, .F. ,lOpcAuto)

DbSelectArea("FO0")
lCpoTxMoed := FO0->(ColumnPos("FO0_TXMOED")) > 0
lCpoFO1Ad  := FO1->(ColumnPos("FO1_VLADIC")) > 0

lCmc7 	:= IIF(Type("lCmc7") == "L", lCmc7, .F.)
_nOper	:= IIf(Type("_nOper") == "U",0,_nOper)

oModel := MPFormModel():New("FINA460A", /*PreValidacao*/, {|oModel| F460APosVld(oModel)} /*PosValidacao*/, {|oModel| F460ACommit(oModel)} /*bCommit*/)
				
oStruFO0:AddField(			  ;
(STR0015)			, ;	// [01] Titulo do campo		//"Razão"
(STR0015)			, ; // [02] ToolTip do campo 	//"Razão"
"FO0_RAZAO"					, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
nTamRazao					, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de validação do campo
{ || .F. }					, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
.F.							, ; // [10] Indica se o campo tem preenchimento obrigatório
FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,Posicione('SA1',1,xFilial('SA1')+FO0->(FO0_CLIENT+FO0_LOJA),'A1_NOME'),'')") ,,,;// [11] Inicializador Padrão do campo
.T.)							//[14] Virtual

oStruFO0:AddField( STR0095, STR0095, "FO0_VLRLIQ", "N", aTamVal[1], aTamVal[2], {||.T.}, {||.F.}, {}, .F.)
oStruFO0:AddField( STR0095, STR0095, "FO0_VLRNEG", "N", aTamVal[1], aTamVal[2], {||.T.}, {||.F.}, {}, .F.)
oStruFO0:AddField( STR0138, STR0138, "FO0_VLRJUR", "N", aTamVal[1], aTamVal[2], {||.T.}, {||.F.}, {}, .F.)
oStruFO0:AddField( STR0137, STR0137, "FO0_TTLTIT", "C", 04, 0, {||.T.}, {||.F.}, {}, .F.)

oStruFO2:AddField((STR0095),(STR0095), "FO2_VLPARC", "N", aTamVal[1], aTamVal[2], {||.T.}, {||.F.}, {}, .F.)

//Campos especificos da integração RM -Protheus
If GetNewPar("MV_RMCLASS", .F.)
	oStruFO2:AddField((STR0108),(STR0108), "FO2_NOSNUM"   ,"C", aTamNosNum[1], aTamNosNum[2] ,{||.T.}, {||.F.}, {}, .F.)	//"Nosso Numero"
	oStruFO2:AddField((STR0109),(STR0109), "FO2_CODBAR"   ,"C", aTamCodBar[1], aTamCodBar[2] ,{||.T.}, {||.F.}, {}, .F.)	//"Código de Barras"
	oStruFO2:AddField((STR0110),(STR0110), "FO2_CCDEBITO" ,"C", aTamCCDeb[1] , aTamCCDeb[2]  ,{||.T.}, {||.F.}, {}, .F.)	//Centro de Custo Debito
	oStruFO2:AddField((STR0111),(STR0111), "FO2_CCCREDITO","C", aTamCCCred[1], aTamCCCred[2] ,{||.T.}, {||.F.}, {}, .F.)	//Centro de Custo Credito
	oStruFO2:AddField((STR0112),(STR0112), "FO2_CTDEBITO" ,"C", aTamCTDeb[1] , aTamCTDeb[2]  ,{||.T.}, {||.F.}, {}, .F.)	//Conta Contabil Debito
	oStruFO2:AddField((STR0113),(STR0113), "FO2_CTCREDITO","C", aTamCTCred[1], aTamCTCred[2] ,{||.T.}, {||.F.}, {}, .F.)	//Conta Contabil Credito
	oStruFO2:AddField((STR0114),(STR0114), "FO2_ITDEBITO" ,"C", aTamITDeb[1] , aTamITDeb[2]  ,{||.T.}, {||.F.}, {}, .F.)	//Item Contabil Debito
	oStruFO2:AddField((STR0115),(STR0115), "FO2_ITCREDITO","C", aTamITCred[1], aTamITCred[2] ,{||.T.}, {||.F.}, {}, .F.)	//Item Contabil Credito
	oStruFO2:AddField((STR0116),(STR0116), "FO2_CLDEBITO" ,"C", aTamClDeb[1] , aTamClDeb[2]  ,{||.T.}, {||.F.}, {}, .F.)	//Classe de Valor Debito
	oStruFO2:AddField((STR0117),(STR0117), "FO2_CLCREDITO","C", aTamClCred[1], aTamClCred[2] ,{||.T.}, {||.F.}, {}, .F.)	//Classe de Valor Credito
	oStruFO2:AddField((STR0118),(STR0118), "FO2_REGACAD"  ,"C", aTamRegAca[1], aTamRegAca[2] ,{||.T.}, {||.F.}, {}, .F.)	//Registro Academico
	oStruFO2:AddField((STR0119),(STR0119), "FO2_PERACAD"  ,"C", aTamPerAca[1], aTamPerAca[2] ,{||.T.}, {||.F.}, {}, .F.)	//Periodo Academico
	If cPaisLoc != "RUS"
		oStruFO2:AddField((STR0120),(STR0120), "FO2_MATAPLI"  ,"N", aTamMatApl[1], aTamMatApl[2] ,{||.T.}, {||.F.}, {}, .F.)	//Matrix Aplicada
	EndIf
	oStruFO2:AddField((STR0121),(STR0121), "FO2_IDTPROD"  ,"C", aTamItem[1]  , aTamItem[2]   ,{||.T.}, {||.F.}, {}, .F.)	//Identificador Produto
	oStruFO2:AddField((STR0122),(STR0122), "FO2_CLASSE"   ,"C", aTamClasse[1], aTamClasse[2] ,{||.T.}, {||.F.}, {}, .F.)	//Classe 
EndIf

If FwIsInCallStack("FINI460")
	oStruFO2:AddField(OemToAnsi(STR0161),OemToAnsi(STR0161), "FO2_CONTRACT"	,"C", aTamContr[1]	, aTamContr[2],{||.T.}, {||.F.}, {}, .F.)	//Contrato
	oStruFO2:AddField(OemToAnsi(STR0162),OemToAnsi(STR0162), "FO2_HOLDER"	,"C", aTamPort[1]	, aTamPort[2],{||.T.}, {||.F.}, {}, .F.)	//Portador
	oStruFO2:AddField(OemToAnsi(STR0163),OemToAnsi(STR0163), "FO2_AGENCY"	,"C", aTamAgenc[1]	, aTamAgenc[2],{||.T.}, {||.F.}, {}, .F.)	//Depositaria
	oStruFO2:AddField(OemToAnsi(STR0164),OemToAnsi(STR0164), "FO2_ACCOUNT"	,"C", aTamConta[1]	, aTamConta[2],{||.T.}, {||.F.}, {}, .F.)	//Num da Conta
	oStruFO2:AddField(OemToAnsi(STR0164),OemToAnsi(STR0164), "FO2_EMISSAO"	,"D", aTamEmiss[1]	, aTamEmiss[2],{||.T.}, {||.F.}, {}, .F.)	//Data Emissao
EndIf

If FwIsInCallStack("F460AIncl") .OR. FwIsInCallStack("F460AltSim") .Or. ( FwIsInCallStack("TMKA271D") .And. !FwIsInCallStack("F460AEfet") ) .Or. FwIsInCallStack("TURLIQAUT")
	oStruFO0:AddField(STR0049/*'Efetiva Liquidação?'*/, STR0050/*"Precisa efetivar a Liquidação?"*/, 'FO0_EFETIVA', 'C', 1, 0, , , {'1='+STR0047/*Sim*/, '2='+STR0048/*Não*/}, .F., FWBuildFeature( STRUCT_FEATURE_INIPAD, '2' ), .F., .F., .T., , )//'2='+STR0048
EndIf

oStruFO0:AddTrigger("FO0_CLIENT", "FO0_RAZAO", { || .T.}, { |oModel| F460AGatCli()})
oStruFO0:AddTrigger("FO0_LOJA"  , "FO0_RAZAO", { || .T.}, { |oModel| F460AGatCli()})

oModel:AddFields("MASTERFO0", /*cOwner*/, oStruFO0, /*bPreVld*/, /*bPosVld*/, /*bLoad*/)

If FwIsInCallStack("FINA460")
	oModel:SetDescription((STR0059)) // "Liquidação a Receber"
Else
	oModel:SetDescription((STR0014)) // "Simulação de Liquidação a Receber"
EndIf

oModel:AddGrid("TITSELFO1", "MASTERFO0", oStruFO1, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, /*bLoad*/ )
oModel:AddGrid("TITGERFO2", "MASTERFO0", oStruFO2, { |oModel, nLine, cAction,cField| FO2LINPRE(oModel,nLine,cAction,cField) }/*bLinePre*/, { |oModel, nLine| FO2LINPOS(oModel,nLine) }/*bLinePost*/ , /*bPre*/, /* bLinePost*/, /*bLoad*/ )

Aadd(aFO1Rel,{"FO1_FILIAL","xFilial('FO1')"})
Aadd(aFO1Rel,{"FO1_PROCES","FO0_PROCES"})
Aadd(aFO1Rel,{"FO1_VERSAO","FO0_VERSAO"})
oModel:SetRelation("TITSELFO1", aFO1Rel, FO1->(IndexKey(1)))

Aadd(aFO2Rel,{"FO2_FILIAL","xFilial('FO2')"})
Aadd(aFO2Rel,{"FO2_PROCES","FO0_PROCES"})
Aadd(aFO2Rel,{"FO2_VERSAO","FO0_VERSAO"})
oModel:SetRelation("TITGERFO2", aFO2Rel, FO2->(IndexKey(2)))

oModel:GetModel("TITGERFO2"):SetUniqueLine( { "FO2_PREFIX", "FO2_NUM", "FO2_PARCEL", "FO2_TIPO"} )
If !FwIsInCallStack("F460ABlqCan") .AND. !FwIsInCallStack("F460VerSim")
	
	If cPaisLoc != "RUS"
		cCposBloc := "FO0_PROCES|FO0_VERSAO|FO0_RAZAO|FO0_NUMLIQ|FO0_DATA|FO0_CLIENT|FO0_LOJA|FO0_STATUS|FO0_MOEDA|FO0_VLRNEG|FO0_VLRLIQ|FO0_TTLTIT|FO0_VLRJUR"
		cCposVar  := "FO0_COND|FO0_TIPO"
	Else
		cCposBloc := "FO0_PROCES|FO0_VERSAO|FO0_RAZAO|FO0_NUMLIQ|FO0_DATA|FO0_CLIENT|FO0_LOJA|FO0_STATUS|FO0_MOEDA|FO0_VLRNEG|FO0_VLRLIQ"
	EndIf
	
	If lCmC7
		cCposBloc += "|FO0_TXJRG|FO0_COND|FO0_TIPO"
	Endif
	If cPaisloc == "BRA"
		cCposBloc += "|FO0_NATURE" 
	EndIf
	
	For nX := 1 To Len(aAuxFO0)
	
		//SETA WHEN
		If lCmC7 .And. aAuxFO0[nX][3] $ cCposBloc
			oStruFO0:SetProperty( aAuxFO0[nX][3] , MODEL_FIELD_WHEN, {||.F.})
		ElseIf !lOpcAuto .And. aAuxFO0[nX][3] $ cCposVar
			oStruFO0:SetProperty( aAuxFO0[nX][3] , MODEL_FIELD_WHEN, {||F460When(oModel) })
		ElseIf aAuxFO0[nX][3] $ cCposBloc
			oStruFO0:SetProperty( aAuxFO0[nX][3] , MODEL_FIELD_WHEN, {||.F.})
		Else
			oStruFO0:SetProperty( aAuxFO0[nX][3] , MODEL_FIELD_WHEN, {||.T.})			
		Endif

		//SETA VALID
		If aAuxFO0[nX][3] $ "FO0_DTVALI"
			oStruFO0:SetProperty( aAuxFO0[nX][3] , MODEL_FIELD_VALID, {|| A460VldData() } )
		ElseIf aAuxFO0[nX][3] $ "FO0_TIPO"
			oStruFO0:SetProperty( "FO0_TIPO"   	, MODEL_FIELD_VALID, bBloco )
		EndIf
		
		If lCpoTxMoed
			oStruFO0:SetProperty( "FO0_TXMOED" 	, MODEL_FIELD_VALID, {|| FA460TXMOE()  } )
		Endif
		
	Next nX
	
	For nX := 1 To Len(aAuxFO1)
		If aAuxFO1[nX][3] $ "FO1_MARK|FO1_TXJUR|FO1_TXMUL|FO1_DESCON|FO1_TXMOED|FO1_VLADIC"
			oStruFO1:SetProperty( aAuxFO1[nX][3] , MODEL_FIELD_WHEN, {||.T.})
			If aAuxFO1[nX][3] $ "FO1_DESCON|FO1_TXMOED"
				If 	aAuxFO1[nX][3] == "FO1_TXMOED"
					oStruFO1:SetProperty("FO1_TXMOED"    , MODEL_FIELD_WHEN, {|oModel,cField,xValue,nLine,xOldValue| F460TxMoed(oModel,cField,xValue,nLine,xOldValue)})
					oStruFO1:SetProperty("FO1_TXMOED"    , MODEL_FIELD_VALID,{|oModel,cField,xValue,nLine,xOldValue| F460AtMoed(oModel,cField,xValue,nLine,xOldValue)})
				Else
					oStruFO1:SetProperty( "FO1_DESCON"	, MODEL_FIELD_VALID , {|oModel,cField,xValue,nLine,xOldValue| F460Desco(oModel,cField, xValue,nLine,xOldValue)})
				EndIf
			EndIf
		ElseIf aAuxFO1[nX][3] $ "FO1_VLJUR|FO1_VLMUL"
			oStruFO1:SetProperty( aAuxFO1[nX][3] , MODEL_FIELD_WHEN, {|oModelFO1| oModelFO1:GetValue("FO1_VENCRE") < dDataBase})
			
		Elseif aAuxFO1[nX][3] $  "FO1_TOTAL" 
			oStruFO1:SetProperty( "FO1_TOTAL"	, MODEL_FIELD_VALID , {|oModelFO1| oModelFO1:GetValue("FO1_SALDO") >= oModelFO1:GetValue("FO1_TOTAL")}) 
			
		Else
			oStruFO1:SetProperty( aAuxFO1[nX][3] , MODEL_FIELD_WHEN, {||.F.})
		EndIf
	Next nX			
	If FwIsInCallStack("A460Liquid") .OR. FwIsInCallStack("F460AIncl") .Or. FwIsInCallStack("TMKA271D") .or. FwIsInCallStack("F460ALTSIM")
		For nX := 1 To Len(aAuxFO2)
			oStruFO2:SetProperty( aAuxFO2[nX][3] , MODEL_FIELD_OBRIGAT, .F.)
		Next nX
			
		oStruFO2:SetProperty( "FO2_VENCTO" 	, MODEL_FIELD_VALID, {|| a460DataOK() } )
		oStruFO2:SetProperty( "FO2_TIPO"	, MODEL_FIELD_VALID, {|| FA460TIPO ("5","5")  } )
		oStruFO2:SetProperty( "FO2_CONTA" 	, MODEL_FIELD_VALID, {|| a460CtaChq() } )
		oStruFO2:SetProperty( "FO2_EMITEN" 	, MODEL_FIELD_VALID, {|| a460Emit()   } )
		oStruFO2:SetProperty( "FO2_NUMCH" 	, MODEL_FIELD_VALID, {|| A460Cheque() } )
		oStruFO2:SetProperty( "FO2_VALOR"   , MODEL_FIELD_VALID, {|oModel,cField,xValue,nLine,xOldValue| F460Valor(oModel,cField, xValue,nLine,xOldValue) } )
		oStruFO2:SetProperty( "FO2_ACRESC" 	, MODEL_FIELD_VALID, {|oModel,cField,xValue,nLine,xOldValue| F460AcrDcr(oModel,cField, xValue,nLine,xOldValue) } )
		oStruFO2:SetProperty( "FO2_DECRES" 	, MODEL_FIELD_VALID, {|oModel,cField,xValue,nLine,xOldValue| F460AcrDcr(oModel,cField, xValue,nLine,xOldValue) } )
		oStruFO2:SetProperty( "FO2_TOTAL"	, MODEL_FIELD_WHEN , {||.F.})

		if !lOpcAuto
			oStruFO2:SetProperty( "FO2_NUM"		, MODEL_FIELD_VALID, {|| a460PreNum("2","2") } )
			oStruFO2:SetProperty( "FO2_PREFIX"	, MODEL_FIELD_VALID, {|| a460PreNum("1","1") } )
			oStruFO2:SetProperty( "FO2_PARCEL" 	, MODEL_FIELD_VALID, {|| a460PreNum("4","4")} )
		endif

		If lCpCalJur
			oStruFO2:SetProperty( "FO2_VLRJUR"	, MODEL_FIELD_WHEN , {||.F.})
		Endif

		oStruFO2:SetProperty( "FO2_TXJUR"	, MODEL_FIELD_INIT , {|oModel,cField,xValue,nLine,xOldValue| F460TxJur(oModel,cField, xValue,nLine,xOldValue) } )
		oStruFO2:SetProperty( "FO2_VLJUR" 	, MODEL_FIELD_TITULO, STR0200 ) //"Vlr.Adicional Negoc."

		If lCMC7
			oStruFO2:SetProperty( "FO2_TXJUR"	, MODEL_FIELD_WHEN , {||.F.})
		Endif
		
	EndIf
	
Else

	oModel:lModify := .T.
	For nX := 1 To Len(aAuxFO0)
		oStruFO0:SetProperty( aAuxFO0[nX][3] , MODEL_FIELD_WHEN, {||.F.})
	Next nX
	
	For nX := 1 To Len(aAuxFO1)
		oStruFO1:SetProperty( aAuxFO1[nX][3] , MODEL_FIELD_WHEN, {||.F.})
	Next nX
	
	For nX := 1 To Len(aAuxFO2)
		oStruFO2:SetProperty( aAuxFO2[nX][3] , MODEL_FIELD_WHEN, {||.F.})
	Next nX
		
EndIf

If FwIsInCallStack("TMKA271D")

	oStruFO0:SetProperty( "FO0_TIPO"	, MODEL_FIELD_INIT , {|| SuperGetMv("MV_TMKTRTR",.F.,"BOL"	) } )
	oStruFO0:SetProperty( "FO0_TIPO"	, MODEL_FIELD_WHEN , {||.F.} )
	
	oStruFO0:SetProperty( "FO0_NATURE"	, MODEL_FIELD_INIT , {|| SuperGetMv("MV_TMKNTCB",.F.,""		) } )
	oStruFO0:SetProperty( "FO0_NATURE"	, MODEL_FIELD_WHEN , {||.F.} )	
	
	oStruFO1:SetProperty( "FO1_DESJUR"	, MODEL_FIELD_WHEN , {|| .T. } )
	
	oStruFO2:SetProperty( "FO2_PREFIX"	, MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD,'SuperGetMv("MV_TMKPRTR",.F.,"REN")' ) )
	oStruFO2:SetProperty( "FO2_PREFIX"	, MODEL_FIELD_WHEN , {|| .F. } )
	
	oStruFO2:SetProperty( "FO2_PARCEL" 	, MODEL_FIELD_VALID, {||.T.})
	oStruFO2:SetProperty( "FO2_VLJUR"	, MODEL_FIELD_WHEN , {||.T.})
	oStruFO2:SetProperty( "FO2_TOTAL"	, MODEL_FIELD_WHEN , {||.T.})
	
EndIf

If lJFilBco()
	cEscrit := 'JurGetDados("NS7", 4, xFilial("NS7") + cFilant + cEmpAnt, "NS7_COD")'
	oStruFO2:SetProperty('FO2_BANCO' , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'ExistCpo("SA6") .And. JurVldSA6("1", {' + cEscrit + ', FwFldGet("FO2_BANCO"), FwFldGet("FO2_AGENCI"), FwFldGet("FO2_CONTA")})'))
	oStruFO2:SetProperty('FO2_AGENCI', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'JurVldSA6("2", {' + cEscrit + ', FwFldGet("FO2_BANCO"), FwFldGet("FO2_AGENCI"), FwFldGet("FO2_CONTA")})'))
	oStruFO2:SetProperty('FO2_CONTA' , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'JurVldSA6("3", {' + cEscrit + ', FwFldGet("FO2_BANCO"), FwFldGet("FO2_AGENCI"), FwFldGet("FO2_CONTA")})'))
Else
	oStruFO2:SetProperty("FO2_BANCO",MODEL_FIELD_VALID,{||.T.})
EndIf

oStruFO2:SetProperty( "FO2_TIPO" , MODEL_FIELD_OBRIGAT, .F.)
oStruFO0:SetProperty( "FO0_TIPO" , MODEL_FIELD_OBRIGAT, .F.)	

//Caso seja uma operação de bloqueio, desbloqueio, cancelamento ou efetivação de simulação de liquidação, nao permito a inclusão e deleção de linhas.
If _nOper == OPER_BLOQUEAR .OR. _nOper == OPER_DESBLOQUEAR .OR. _nOper == OPER_CANCELAR .OR. _nOper == OPER_EFETIVAR .OR. _nOper == OPER_ALTERA .OR.;
	_nOper == OPER_VISUALIZAR //.OR. lCMC7
	oModel:GetModel( 'TITSELFO1' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'TITSELFO1' ):SetNoDeleteLine( .T. )
	If _nOper != OPER_ALTERA
		oModel:GetModel( 'TITGERFO2' ):SetNoInsertLine( .T. )
		oModel:GetModel( 'TITGERFO2' ):SetNoDeleteLine( .T. )
	Endif
Endif

If FwIsInCallStack("TMKA271D")
	oModel:GetModel( 'TITGERFO2' ):SetNoInsertLine( .F. )
	oModel:GetModel( 'TITGERFO2' ):SetNoDeleteLine( .F. )
Endif

oModel:GetModel('TITSELFO1'):SetMaxLine(9990)
oModel:SetActivate( {|oModel| FA460LOAD(oModel) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Função responsavel pela View da rotina de simulação de liquidação a receber

@author lucas.oliveira
@since 13/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FWLoadModel("FINA460A")
Local oView		:= FWFormView():New()
Local oStruFO0	:= FWFormStruct(2,"FO0")
Local oStruFO1	:= F460CpoFO1(2)
Local oStruFO2	:= FWFormStruct(2,"FO2")
Local oStruFOB	:= FWFormStruct(2,"FO0")
Local aAuxFO0	:= aClone(oStruFO0:GetFields())
Local aAuxFO1	:= aClone(oStruFO1:GetFields())
Local aAuxFO2	:= aClone(oStruFO2:GetFields())
Local nTimeMsg  := Int(SuperGetMv("MV_MSGTIME",.F.,120)*1000) 	//Estabelece 02 minutos para exibir a mensagem para o usuário

Local nX		:= 0
Local lCpCalJur	:= FO0->(ColumnPos("FO0_CALJUR")) > 0 .And. FO2->(ColumnPos("FO2_TXCALC")) > 0 .And. FO2->(ColumnPos("FO2_VLRJUR")) > 0  // Proteção criada para versão 12.1.27
Local lIntPFS   := FindFunction("JLiqView") .And. AliasInDic("OHT") .And. SuperGetMV("MV_JURXFIN",,.F.) // Integração SIGAFIN x SIGAPFS
Local lButMark	:= FwIsInCallStack("F460AIncl") .or. FwIsInCallStack("A460Liquid")

lCpoTxMoed := FO0->(ColumnPos("FO0_TXMOED")) > 0
lCpoFO1Ad  := FO1->(ColumnPos("FO1_VLADIC")) > 0
__lNExbMsg := .F.

oStruFO0:SetProperty( 'FO0_DATA'	, MVC_VIEW_ORDEM,	'05')
oStruFO0:SetProperty( 'FO0_DTVALI'	, MVC_VIEW_ORDEM,	'06')
oStruFO0:SetProperty( 'FO0_STATUS'	, MVC_VIEW_ORDEM,	'07')
oStruFO0:SetProperty( 'FO0_CLIENT'	, MVC_VIEW_ORDEM,	'08')
oStruFO0:SetProperty( 'FO0_LOJA'	, MVC_VIEW_ORDEM,	'09')
oStruFO0:SetProperty( 'FO0_NUMLIQ'	, MVC_VIEW_ORDEM,	'11')
oStruFO0:SetProperty( 'FO0_NATURE'	, MVC_VIEW_ORDEM,	'12')
oStruFO0:SetProperty( 'FO0_MOEDA'	, MVC_VIEW_ORDEM,	'13')
oStruFO0:SetProperty( 'FO0_COND'	, MVC_VIEW_ORDEM,	'14')
oStruFO0:SetProperty( 'FO0_TIPO'	, MVC_VIEW_ORDEM,	'15')
oStruFO0:SetProperty( 'FO0_TXJUR'	, MVC_VIEW_ORDEM,	'16')
oStruFO0:SetProperty( 'FO0_TXMUL'	, MVC_VIEW_ORDEM,	'17')
oStruFO0:SetProperty( 'FO0_TXJRG'	, MVC_VIEW_ORDEM,	'18')

If lCpoTxMoed
	oStruFO0:SetProperty( 'FO0_TXMOED'	, MVC_VIEW_ORDEM,	'19')
Endif

If lCpCalJur
	oStruFO0:SetProperty( 'FO0_CALJUR'	, MVC_VIEW_ORDEM,	'20')
Endif

oStruFO0:AddField(	"FO0_RAZAO" , "10", STR0015, STR0015, {}, "G", "@!")//"Razão social"

If FindFunction("RetGlbLGPD") .And. RetGlbLGPD("A1_NOME")
	oStruFO0:SetProperty( "FO0_RAZAO"	, MVC_VIEW_OBFUSCATED , .T.  )
Endif

If Empty(MV_PAR09) .Or. MV_PAR09 = 1
	oStruFO0:AddField(	"FO0_VLRLIQ", "20", STR0102, STR0102, {}, "N", PesqPict("FO2","FO2_VALOR") ) //"Valor Total a Liquidar"
	oStruFO0:AddField(	"FO0_VLRNEG", "21", STR0103, STR0103, {}, "N", PesqPict("FO2","FO2_VALOR") ) //"Valor Total Negociado"
	oStruFO0:AddField(	"FO0_VLRJUR", "22", STR0138, STR0138, {}, "N", PesqPict("FO2","FO2_VALOR") ) //"Valor Total Juros"
	oStruFO0:AddField(	"FO0_TTLTIT", "23", STR0137, STR0137, {}, "C" )	//"Qtde Títulos"
Else
	oStruFOB:AddField(	"FO0_VLRLIQ", "20", STR0102, STR0102, {}, "N", PesqPict("FO2","FO2_VALOR") ) //"Valor Total a Liquidar"
	oStruFOB:AddField(	"FO0_VLRNEG", "21", STR0103, STR0103, {}, "N", PesqPict("FO2","FO2_VALOR") ) //"Valor Total Negociado"
	oStruFOB:AddField(	"FO0_VLRJUR", "22", STR0138, STR0138, {}, "N", PesqPict("FO2","FO2_VALOR") ) //"Valor Total Juros"
	oStruFOB:AddField(	"FO0_TTLTIT", "23", STR0137, STR0137, {}, "C" )	//"Qtde Títulos"
Endif

If FwIsInCallStack("F460AIncl") .OR. FwIsInCallStack("F460AltSim") .Or. ( FwIsInCallStack("TMKA271D") .And. !FwIsInCallStack("F460AEfet") )
	oStruFO0:AddField( 'FO0_EFETIVA', '04', STR0049, STR0050, {	STR0051/*"Para efetivar esta simulação, selecione a "*/, STR0052/*"opção 'Sim' e clique em salvar para que"*/, STR0053 /*" o sistema realize a efetivação."*/}, 'Combo' ,,,,,,,{'1='+STR0047, '2='+STR0048},,'2='+STR0048,.T.,, )
EndIf

oStruFO2:AddField(	"FO2_VLPARC", "12", STR0088, STR0088, {}, "N", PesqPict("FO2","FO2_VALOR") )		//"Vlr. Parc. Gerar"
oStruFO2:SetProperty( 'FO2_PREFIX'	, MVC_VIEW_ORDEM,	'04')
oStruFO2:SetProperty( 'FO2_NUM'		, MVC_VIEW_ORDEM,	'05')
oStruFO2:SetProperty( 'FO2_PARCEL'	, MVC_VIEW_ORDEM,	'06')
oStruFO2:SetProperty( 'FO2_TIPO'	, MVC_VIEW_ORDEM,	'07')
oStruFO2:SetProperty( 'FO2_VALOR'	, MVC_VIEW_ORDEM,	'08')
oStruFO2:SetProperty( 'FO2_TXJUR'	, MVC_VIEW_ORDEM,	'09')
oStruFO2:SetProperty( 'FO2_VLJUR'	, MVC_VIEW_ORDEM,	'11')

If lCpCalJur
	oStruFO2:SetProperty( 'FO2_TXCALC'	, MVC_VIEW_ORDEM,	'12')
	oStruFO2:SetProperty( 'FO2_VLRJUR'	, MVC_VIEW_ORDEM,	'13')
endif

oStruFO2:SetProperty( 'FO2_VLPARC'	, MVC_VIEW_ORDEM,	'14')
oStruFO2:SetProperty( 'FO2_ACRESC'	, MVC_VIEW_ORDEM,	'15')
oStruFO2:SetProperty( 'FO2_DECRES'	, MVC_VIEW_ORDEM,	'16')
oStruFO2:SetProperty( 'FO2_TOTAL'	, MVC_VIEW_ORDEM,	'17')
oStruFO2:SetProperty( 'FO2_BANCO'	, MVC_VIEW_ORDEM,	'18')
oStruFO2:SetProperty( 'FO2_AGENCI'	, MVC_VIEW_ORDEM,	'19')
oStruFO2:SetProperty( 'FO2_CONTA'	, MVC_VIEW_ORDEM,	'20')
oStruFO2:SetProperty( 'FO2_NUMCH'	, MVC_VIEW_ORDEM,	'21')
oStruFO2:SetProperty( 'FO2_EMITEN'	, MVC_VIEW_ORDEM,	'22')
oStruFO2:SetProperty( 'FO2_PARCEL'	, MVC_VIEW_PICT,	'@!')
oStruFO2:SetProperty( 'FO2_VLJUR' 	, MVC_VIEW_TITULO, STR0200 ) //'Vlr.Adicional Negoc.'

If lJFilBco() // SIGAPFS
	oStruFO2:SetProperty('FO2_BANCO', MVC_VIEW_LOOKUP,	'SA6JUR')
EndIf

oView:SetModel(oModel)

If Empty(MV_PAR09) .Or. MV_PAR09 = 1
	oView:AddField("VIEW_FO0", oStruFO0, "MASTERFO0")
	oView:AddGrid("VIEW_FO1" , oStruFO1, "TITSELFO1")
	oView:AddGrid("VIEW_FO2" , oStruFO2, "TITGERFO2")
	
	oView:CreateHorizontalBox("BOXFO0", 30)
	oView:CreateHorizontalBox("BOXFO1", 35)
	oView:CreateHorizontalBox("BOXFO2", 35)
	
	oView:SetOwnerView("VIEW_FO0", "BOXFO0")
	oView:SetOwnerView("VIEW_FO1", "BOXFO1")
	oView:SetOwnerView("VIEW_FO2", "BOXFO2")
	
	If lButMark
		oView:AddOtherObject("btnMarcaDesm", {|oPanel,oView| F460Botao(oPanel,oView,oModel)})
		oView:SetOwnerView("btnMarcaDesm",'BOXFO1')
	Endif
	
	oView:EnableTitleView("VIEW_FO1", (STR0016)) // "Títulos Selecionados"
	oView:EnableTitleView("VIEW_FO2", (STR0017)) // "Títulos Gerados"
	
Else
	oView:AddField("VIEW_FO0", oStruFO0, "MASTERFO0")
	
	oView:CreateHorizontalBox('GERAL',85)
	oView:CreateHorizontalBox('BARRA',15)
	
	oView:AddField("VIEW_FOB", oStruFOB, "MASTERFO0")
	oView:SetOwnerView("VIEW_FOB", "BARRA")
	
	oView:CreateFolder('PASTAS','GERAL')
	oView:AddSheet('PASTAS','PASTA1', STR0059 ) // "Liquidação a Receber"
	oView:CreateHorizontalBox('ID_PASTA_MASTERFO0',100,,,'PASTAS', 'PASTA1' )
	
	oView:SetOwnerView('MASTERFO0','ID_PASTA_MASTERFO0')
	oView:AddSheet('PASTAS','PASTA2', STR0016 ) // "Títulos Selecionados"
	oView:CreateHorizontalBox('ID_PASTA_TITSELFO1',100,,,'PASTAS', 'PASTA2' )
	
	oView:AddGrid("VIEW_FO1", oStruFO1, "TITSELFO1")
	oView:SetOwnerView("VIEW_FO1", "ID_PASTA_TITSELFO1")
	
	oView:AddSheet('PASTAS','PASTA3', STR0017 ) // "Títulos Gerados"
	oView:CreateHorizontalBox('ID_PASTA_TITGERFO2',100,,,'PASTAS', 'PASTA3' )
	
	oView:AddGrid("VIEW_FO2",	oStruFO2, "TITGERFO2")
	oView:SetOwnerView("VIEW_FO2", "ID_PASTA_TITGERFO2")
	
	If lButMark
		oView:AddOtherObject("btnMarcaDesm", {|oPanel,oView| F460Botao(oPanel,oView,oModel)})
		oView:SetOwnerView("btnMarcaDesm",'ID_PASTA_TITSELFO1')
	Endif
	
	oView:EnableTitleView("VIEW_FOB",  STR0181 ) // "Títulos Totalizados" # "Totalizadores"
	
	oStruFOB:RemoveField("FO0_PROCES")
	oStruFOB:RemoveField("FO0_VERSAO")
	oStruFOB:RemoveField("FO0_NUMLIQ")
	oStruFOB:RemoveField("FO0_DATA")
	oStruFOB:RemoveField("FO0_DTVALI")
	oStruFOB:RemoveField("FO0_COND")
	oStruFOB:RemoveField("FO0_TXJUR")
	oStruFOB:RemoveField("FO0_TXMUL")
	oStruFOB:RemoveField("FO0_TXJRG")

	If lCpCalJur
		oStruFOB:RemoveField("FO0_CALJUR")
	Endif

	oStruFOB:RemoveField("FO0_CLIENT")
	oStruFOB:RemoveField("FO0_LOJA")
	oStruFOB:RemoveField("FO0_NATURE")
	oStruFOB:RemoveField("FO0_STATUS")
	oStruFOB:RemoveField("FO0_MOEDA")
	oStruFOB:RemoveField("FO0_BKPSTT")
	oStruFOB:RemoveField("FO0_ORIGEM")
	oStruFOB:RemoveField("FO0_CODLIG")
	oStruFOB:RemoveField("FO0_TIPO")
	oStruFOB:RemoveField("FO0_TXMOED")
	
Endif

oView:SetNoInsertLine("VIEW_FO1")
oView:SetNoDeleteLine("VIEW_FO1")

oView:SetViewProperty("VIEW_FO1", "GRIDFILTER", {.T.}) 

If Empty(MV_PAR09) .Or. MV_PAR09 = 1
	If _nOper == OPER_LIQUIDAR
		oView:EnableTitleView("VIEW_FO0", OemToAnsi( STR0059 ))//"Liquidação a Receber"
	ElseIf _nOper == OPER_RELIQUIDAR
		oView:EnableTitleView("VIEW_FO0", OemToAnsi( STR0060 ))//"Reliquidação a Receber"
	EndIf
Endif

For nX := 1 To Len(aAuxFO0)
	If aAuxFO0[nX][1] $ "FO0_BKPSTT|FO0_ORIGEM|FO0_CODLIG|"
		oStruFO0:RemoveField( aAuxFO0[nX][1] )
	EndIf
Next nX

For nX := 1 To Len(aAuxFO1)
	If !FwIsInCallStack("TMKA271D")
		If aAuxFO1[nX][1] $ "FO1_FILIAL|FO1_PROCES|FO1_VERSAO|FO1_IDDOC|FO1_DESJUR"
			oStruFO1:RemoveField( aAuxFO1[nX][1] )
		EndIf
	Else
		If aAuxFO1[nX][1] $ "FO1_FILIAL|FO1_PROCES|FO1_VERSAO|FO1_IDDOC"
			oStruFO1:RemoveField( aAuxFO1[nX][1] )
		EndIf	
	EndIf
Next nX

For nX := 1 To Len(aAuxFO2)
	If aAuxFO2[nX][1] $ "FO2_PROCES|FO2_VERSAO|FO2_IDSIM|"
		oStruFO2:RemoveField( aAuxFO2[nX][1] )
	EndIf
Next nX

oView:SetFieldAction("FO0_COND"  ,{|oModel| F460TitGer(oModel, "FO0_COND"  )} )
oView:SetFieldAction("FO0_TXJUR" ,{|oModel| F460JurMul(oModel, "FO0_TXJUR" )} )
oView:SetFieldAction("FO0_TXMUL" ,{|oModel| F460JurMul(oModel, "FO0_TXMUL" )} )
oView:SetFieldAction("FO0_TXJRG" ,{|oModel| F460JurMul(oModel, "FO0_TXJRG" )} )

If lCpCalJur
	oView:SetFieldAction("FO0_CALJUR",{|oModel| F460CalJur(oModel              )} )
Endif

oView:SetFieldAction("FO1_MARK"  ,{|oModel| F460TitGer(oModel, "FO1_MARK", Nil, Nil, Nil, Nil, @__lNExbMsg)})
oView:SetFieldAction("FO1_TXJUR" ,{|oModel| F460JurMul(oModel, "FO1_TXJUR" )} )
oView:SetFieldAction("FO1_TXMUL" ,{|oModel| F460JurMul(oModel, "FO1_TXMUL" )} )
oView:SetFieldAction("FO1_VLMUL" ,{|oModel| F460JurMul(oModel, "FO1_VLMUL" )} )
oView:SetFieldAction("FO1_VLJUR" ,{|oModel| F460JurMul(oModel, "FO1_VLJUR" )} )
oView:SetFieldAction("FO1_TOTAL" ,{|oModel| F460TitGer(oModel, "FO1_TOTAL" )} )
oView:SetFieldAction("FO1_VLDIA" ,{|oModel| F460JurMul(oModel, "FO1_VLDIA" )} )
oView:SetFieldAction("FO1_DESCON",{|oModel| F460JurMul(oModel, "FO1_DESCON")} )
If lCpoFO1Ad
	oView:SetFieldAction("FO1_VLADIC",{|oModel| F460JurMul(oModel, "FO1_VLADIC" )} )
EndIf

oView:SetFieldAction("FO2_TXJUR" ,{|oModel| F460JurMul(oModel,"FO2_TXJUR")})
oView:SetFieldAction("FO2_VLJUR" ,{|oModel| F460JurMul(oModel,"FO2_VLJUR")})
oView:SetFieldAction("FO2_VENCTO",{|oModel| F460JurMul(oModel,"FO2_VENCTO")})

If lCpCalJur
	oView:SetFieldAction("FO2_TXCALC",{|oModel| F460CalJur(oModel,,1)})
Endif

//Caso seja uma operação de bloqueio, desbloqueio, cancelamento ou efetivação de simulação de liquidação, nao permito a inclusão e deleção de linhas.
If _nOper == OPER_BLOQUEAR .OR. _nOper == OPER_DESBLOQUEAR .OR. _nOper == OPER_CANCELAR .OR. _nOper == OPER_EFETIVAR
	oView:SetOnlyView("VIEW_FO0")
	oView:SetOnlyView("VIEW_FO1")
	oView:SetOnlyView("VIEW_FO2")
	oView:SetNoInsertLine("VIEW_FO2")
	oView:SetNoDeleteLine("VIEW_FO2")
EndIf

If lIntPFS // Integração SIGAFIN x SIGAPFS
	JLiqView(oView)
EndIf

oView:SetTimer( nTimeMsg, { || F460ATime() } )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F460AGatCli()
Gatilho disparado dos campos FO0_CLINET E FO0_LOJA

@author lucas.oliveira
@since 14/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------
Function F460AGatCli()

Local oModel	:= FWModelActive()
Local oSubFO0	:= oModel:GetModel("MASTERFO0")
Local cCliente	:= oSubFO0:GetValue("FO0_CLIENT","A1_COD")
Local cLoja		:= oSubFO0:GetValue("FO0_LOJA","A1_LOJA")
Local cNome		:= ""

cLoja := IIF(Empty(cLoja),"",cLoja)
cNome := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,'A1_NOME')

Return cNome

//-------------------------------------------------------------------
/*/{Protheus.doc} F460AEfet()
Efetiva uma simulação de liquidação a receber.

@author lucas.oliveira
@since 14/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------
Function F460AEfet()

Local lRet  		 := .T.
Local nOperation	 := 0
Local cPrograma		 := ""
Local cTitulo		 := ""
Local oModelLiq		 := NIL
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,(STR0031)},{.T.,(STR0032)},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Cancelar"

Private nIDAPLIC 	 := 0				//Integracao Protheus x RM Classis
Private cTurma	 	 := ""
Private cNumRA		 := ""

If Type("lRecalcula")=="U"
	PRIVATE lRecalcula := .F.
EndIf

If FO0->FO0_STATUS == "1" .AND. FO0->FO0_DTVALI >= dDataBase		/* nao permite bloqueio de simulações nestes Status. */
	_nOper			:= OPER_EFETIVAR
	oModelLiq 		:= FWLoadModel("FINA460A")//Carrega estrutura do model
	oModelLiq:SetOperation( MODEL_OPERATION_UPDATE ) //Define operação de inclusao
	oModelLiq:Activate()//Ativa o model

	If F460ARec(oModelLiq) //Recalculo Realizado. 
		_lUserButton	:= .T.
	    cTitulo 		:= STR0058 //"Efetivar Liquidação"
	    cPrograma		:= "FINA460A"
	    nOperation		:= MODEL_OPERATION_UPDATE
	    bCancel			:= { |oModelLiq| F460NoAlt(oModelLiq)}
		nRet 			:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, aEnableButtons, bCancel , /*cOperatId*/, /*cToolBar*/,oModelLiq )
		_lUserButton	:= .F.
	EndIf
Else
	If FO0->FO0_STATUS != "1"
		Help(" ",1,"F460AEFET",, STR0057, 1, 0) 	// "Não é possível liquidar um processo que esteja Bloqueado, Cancelado, Gerado ou Encerrado."
	ElseIf FO0->FO0_DTVALI < dDataBase
		Help(" ",1,"F460AEFETV",, STR0098, 1, 0)	//"Não é possível liquidar um processo com data de validade anterior a data base do sistema"
	Endif
	lRet := .F.
EndIf

Return

//-------------------------------------------------------------------
/* {Protheus.doc} F460CpoFO1

Função criar um campo virtual para montagem da grid de seleção dos títulos

@author	Pâmela Bernardo
@since	15/10/2015
@Version	V12.1.8
@Project P12
@aparam  nTipo, indica se é 1 = model ou 2 = view 
@Return	oStruFO1 Estrutura de campos da tabela FO1		
*/
//-------------------------------------------------------------------

Static Function F460CpoFO1(nTipo) 
	Local oStruFO1 		:= FWFormStruct(nTipo,"FO1")
	Local lMostraMark	:= (FwIsInCallStack("F460AIncl") .Or. FwIsInCallStack("A460Liquid") .Or. FwIsInCallStack("TMKA271D") .Or. FwIsInCallStack("F460ABlqCan"))
	
	Default nTipo := 1 

	If nTipo == 1
		
		oStruFO1:AddField( ""				    ,"","FO1_MARK"		,"L", 1						,0,,,,.F.,,,,.T.)
		oStruFO1:AddField((STR0018)	,"","FO1_PREFIX"	,"C",TamSX3("E1_PREFIXO")[1],0,,,,.F.,,,,.T.)//"Prefixo"
		oStruFO1:AddField((STR0019)	,"","FO1_NUM"		,"C",TamSX3("E1_NUM")[1]	,0,,,,.F.,,,,.T.)//"Número"
		oStruFO1:AddField((STR0020)	,"","FO1_PARCEL"	,"C",TamSX3("E1_PARCELA")[1],0,,,,.F.,,,,.T.)//"Parcela"
		oStruFO1:AddField((STR0021)	,"","FO1_TIPO"		,"C",TamSX3("E1_TIPO")[1]	,0,,,,.F.,,,,.T.)//"Tipo"
		oStruFO1:AddField((STR0022)	,"","FO1_NATURE"	,"C",TamSX3("E1_NATUREZ")[1],0,,,,.F.,,,,.T.)//"Natureza"
		oStruFO1:AddField((STR0023)	,"","FO1_CLIENT"	,"C",TamSX3("E1_CLIENTE")[1],0,,,,.F.,,,,.T.)//"Cliente"
		oStruFO1:AddField((STR0024)	,"","FO1_LOJA"		,"C",TamSX3("E1_LOJA")[1]	,0,,,,.F.,,,,.T.)//"Loja"
		oStruFO1:AddField((STR0025)	,"","FO1_EMIS"		,"D",TamSX3("E1_EMISSAO")[1],0,,,,.F.,,,,.T.)//"Emissão"
		oStruFO1:AddField((STR0026)	,"","FO1_VENCTO"	,"D",TamSX3("E1_VENCTO")[1]	,0,,,,.F.,,,,.T.)//"Vencimento"
		oStruFO1:AddField((STR0097)	,"","FO1_VENCRE"	,"D",TamSX3("E1_VENCREA")[1],0,,,,.F.,,,,.T.)//"Vencimento Real"
		oStruFO1:AddField((STR0027)	,"","FO1_BAIXA"		,"D",TamSX3("E1_BAIXA")[1]	,0,,,,.F.,,,,.T.)//"Ult Baixa"
		oStruFO1:AddField((STR0028)	,"","FO1_VLBAIX"	,"N",TamSX3("E1_VALOR")[1]	,2,,,,.F.,,,,.T.)//"Valor de baixa"
		oStruFO1:AddField((STR0029)	,"","FO1_VALCVT"	,"N",TamSX3("E1_VALOR")[1]	,2,,,,.F.,,,,.T.)//"Vlr Convertido"
		oStruFO1:AddField((STR0030)	,"","FO1_HIST"		,"C",TamSX3("E1_HIST")[1]	,0,,,,.F.,,,,.T.)//"Histórico"
			
		oStruFO1:AddField((STR0030)	,"","FO1_CCUST"     ,"C",TamSX3("E1_CCUSTO")[1] ,0,,,,.F.,,,,.T.)//Centro de Custo
		oStruFO1:AddField((STR0030)	,"","FO1_ITEMCT"    ,"C",TamSX3("E1_ITEMCTA")[1],0,,,,.F.,,,,.T.)//ITEM DA CONTA
		oStruFO1:AddField((STR0030)	,"","FO1_CLVL"      ,"C",TamSX3("E1_CLVL")[1]   ,0,,,,.F.,,,,.T.)//Classe de Valor
		oStruFO1:AddField((STR0030)	,"","FO1_CREDIT"	,"C",TamSX3("E1_CREDIT")[1]   ,0,,,,.F.,,,,.T.)//Conta Credito
		oStruFO1:AddField((STR0030)	,"","FO1_DEBITO"    ,"C",TamSX3("E1_DEBITO")[1]   ,0,,,,.F.,,,,.T.)//Conta Debito
		oStruFO1:AddField((STR0030)	,"","FO1_CCC"      	,"C",TamSX3("E1_CCC")[1]   ,0,,,,.F.,,,,.T.)//Conta Credito
		oStruFO1:AddField((STR0030)	,"","FO1_CCD"      	,"C",TamSX3("E1_CCD")[1]   ,0,,,,.F.,,,,.T.)//Conta Credito
		oStruFO1:AddField((STR0030)	,"","FO1_ITEMC"     ,"C",TamSX3("E1_ITEMC")[1]   ,0,,,,.F.,,,,.T.)//Conta Credito
		oStruFO1:AddField((STR0030)	,"","FO1_ITEMD"     ,"C",TamSX3("E1_ITEMD")[1]   ,0,,,,.F.,,,,.T.)//Conta Credito
		oStruFO1:AddField((STR0030)	,"","FO1_CLVLCR"    ,"C",TamSX3("E1_CLVLCR")[1]   ,0,,,,.F.,,,,.T.)//Conta Credito
		oStruFO1:AddField((STR0030)	,"","FO1_CLVLDB"    ,"C",TamSX3("E1_CLVLDB")[1]   ,0,,,,.F.,,,,.T.)//Conta Credito
	Else 
		If lMostraMark
			oStruFO1:AddField("FO1_MARK"	, "01",""					,"",{},"L",""		)
		Endif
		oStruFO1:AddField("FO1_PREFIX"	, "03",(STR0018)		,"",{},"C","@!"	)
		oStruFO1:AddField("FO1_NUM"		, "04",(STR0019)		,"",{},"C","@!"	)
		oStruFO1:AddField("FO1_PARCEL"	, "05",(STR0020)		,"",{},"C","@!"	)
		oStruFO1:AddField("FO1_TIPO"	, "06",(STR0021)		,"",{},"C","@!"	)
		oStruFO1:AddField("FO1_NATURE"	, "07",(STR0022)		,"",{},"C","@!"	)
		oStruFO1:AddField("FO1_CLIENT"	, "08",(STR0023)		,"",{},"C","@!"	)
		oStruFO1:AddField("FO1_LOJA"	, "09",(STR0024)		,"",{},"C","@!"	)
		oStruFO1:AddField("FO1_EMIS"	, "10",(STR0025)		,"",{},"D",""	)
		oStruFO1:AddField("FO1_VENCTO"	, "11",(STR0026)		,"",{},"D",""	)
		oStruFO1:AddField("FO1_VENCRE"	, "12",(STR0097)		,"",{},"D",""	)
		oStruFO1:AddField("FO1_BAIXA"	, "16",(STR0027)		,"",{},"D",""	)
		oStruFO1:AddField("FO1_VLBAIX"	, "17",(STR0028)		,"",{},"N",PesqPict("SE1", "E1_VALOR"))
		oStruFO1:AddField("FO1_VALCVT"	, "18",(STR0029)		,"",{},"N",PesqPict("SE1", "E1_VALOR"))
		oStruFO1:AddField("FO1_CCUST" 	, "29",(STR0165)       ,"",{},"C","@!" )
		oStruFO1:AddField("FO1_ITEMCT"	, "30",(STR0166)       ,"",{},"C","@!" )
		oStruFO1:AddField("FO1_CLVL"	, "31",(STR0167)       ,"",{},"C","@!" )
		oStruFO1:AddField("FO1_CREDIT"	, "32",(STR0171)       ,"",{},"C","@!" ) // "Credito"
		oStruFO1:AddField("FO1_DEBITO"	, "33",(STR0170)       ,"",{},"C","@!" ) // "Debito"
		oStruFO1:AddField("FO1_HIST"	, "34",(STR0030)		,"",{},"C","@!"	)

		oStruFO1:SetProperty( 'FO1_FILORI'	, MVC_VIEW_ORDEM,	'02')
		oStruFO1:SetProperty( 'FO1_MOEDA'	, MVC_VIEW_ORDEM,	'13')
		oStruFO1:SetProperty( 'FO1_TXMOED'	, MVC_VIEW_ORDEM,	'14')
		oStruFO1:SetProperty( 'FO1_SALDO'	, MVC_VIEW_ORDEM,	'15')
		oStruFO1:SetProperty( 'FO1_TXJUR'	, MVC_VIEW_ORDEM,	'19')
		oStruFO1:SetProperty( 'FO1_VLDIA'	, MVC_VIEW_ORDEM,	'20')
		oStruFO1:SetProperty( 'FO1_VLJUR'	, MVC_VIEW_ORDEM,	'21')
		oStruFO1:SetProperty( 'FO1_TXMUL'	, MVC_VIEW_ORDEM,	'22')
		oStruFO1:SetProperty( 'FO1_VLMUL'	, MVC_VIEW_ORDEM,	'23')
		oStruFO1:SetProperty( 'FO1_DESCON'	, MVC_VIEW_ORDEM,	'24')
		If FwIsInCallStack("TMKA271D")
			oStruFO1:SetProperty( 'FO1_DESJUR'	, MVC_VIEW_ORDEM,	'25')				
		EndIf
		oStruFO1:SetProperty( 'FO1_VLABT'	, MVC_VIEW_ORDEM,	'26')
		oStruFO1:SetProperty( 'FO1_ACRESC'	, MVC_VIEW_ORDEM,	'27')
		oStruFO1:SetProperty( 'FO1_DECRES'	, MVC_VIEW_ORDEM,	'28')
		oStruFO1:SetProperty( 'FO1_TOTAL'	, MVC_VIEW_ORDEM,	'29')
		
	Endif
Return oStruFO1

//-------------------------------------------------------------------
/*/{Protheus.doc} F460ABlqCan()
Rotina que permite realizar o bloqueio, desbloqueio e cancelamento de uma simulação.

@author Diego Santos
@since 15/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------

Function F460ABlqCan(nTipo, cFilLiq, cLiqCan )

Local aArea 		:= GetArea()

Local lRet  		:= .T.
Local nOperation	:= 0

Local cPrograma		:= ""
Local cTitulo		:= ""

Local cQuery 		:= ""
Local cAliasCanc
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,OemToAnsi(STR0031)},{.T.,OemToAnsi(STR0032)},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Cancelar"
	
DEFAULT nTipo 	:= 0
DEFAULT cFilLiq	:= ""
DEFAULT cLiqCan	:= ""

If nTipo == 1 //Bloqueio

	If FO0->FO0_STATUS $ '2|3|4|5'		/* nao permite bloqueio de simulações nestes Status. */
		Help(" ",1,"F460ABLQ",, OemToAnsi(STR0033) ,1,0) // "Não é possível o bloqueio de simulações Bloqueadas, Canceladas, Geradas ou Encerradas."
		lRet := .F.
	Else
		_nOper			:= OPER_BLOQUEAR
	    cTitulo	 		:= OemToAnsi(STR0034) //"Bloqueio de Simulação"
		cPrograma		:= "FINA460A"
		nOperation		:= MODEL_OPERATION_UPDATE
		__lUserButton	:= .T.
		bCancel      	:=  { |oModel| F460NoAlt(oModel)}	
		nRet 			:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, aEnableButtons, bCancel )	
		_lUserButton := .F.	
	EndIf
	
ElseIf nTipo == 2 //Desbloqueio

	If FO0->FO0_STATUS != '2'	
		Help(" ",1,"F460ABLQ",, OemToAnsi(STR0035) ,1,0) // "Não é possível o desbloqueio de simulações Vigentes, Vencidas, Canceladas, Geradas ou Encerradas."
		lRet := .F.
	Else
		_nOper			:= OPER_DESBLOQUEAR
		cTitulo 		:= OemToAnsi(STR0036)//"Desbloqueio de Simulação"
		cPrograma		:= "FINA460A"
		nOperation		:= MODEL_OPERATION_UPDATE
		__lUserButton	:= .T.
		bCancel      	:=  { |oModel| F460NoAlt(oModel)}
		nRet 			:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, aEnableButtons, bCancel )
		_lUserButton := .F.
	EndIf
	
ElseIf nTipo == 3 //Cancelamento

	cQuery 		:= "SELECT R_E_C_N_O_ RECFO0 , FO0.* FROM " + RetSqlName("FO0") + " FO0 "
	cQuery 		+= "WHERE "
	cQuery		+= "FO0.FO0_FILIAL = '"+ cFilLiq +"' AND "
	cQuery		+= "FO0.FO0_NUMLIQ = '"+ cLiqCan +"' AND "
	cQuery 		+= "FO0.D_E_L_E_T_ = ' ' AND "
	cQuery 		+= "FO0.FO0_STATUS != '3' "
	
	cQuery 		:= ChangeQuery(cQuery)
	cAliasCanc	:= GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasCanc, .F., .T.)
	
	While (cAliasCanc)->(!Eof())	
		Begin Transaction
		dbSelectArea("FO0")
		FO0->(dbGoTo((cAliasCanc)->RECFO0))
			RecLock("FO0", .F.)
				FO0->FO0_BKPSTT := FO0->FO0_STATUS
				FO0->FO0_STATUS := "5"
			MsUnlock()
		End Transaction
		(cAliasCanc)->(DbSkip())		
	End
ElseIf nTipo == 4 //Usuário não confirmou o cancelamento das versões. 
				  //Então as versões retornam ao seu status anterior presente no campo FO0_BKPSTT.

	cQuery 		:= "SELECT R_E_C_N_O_ RECFO0 , FO0.* FROM "+ RetSqlName("FO0") + " FO0 "
	cQuery 		+= "WHERE "
	cQuery		+= "FO0.FO0_FILIAL = '"+ cFilLiq +"' AND "
	cQuery		+= "FO0.FO0_NUMLIQ = '"+ cLiqCan +"' AND "
	cQuery 		+= "FO0.D_E_L_E_T_ = ' ' AND "
	cQuery 		+= "FO0.FO0_STATUS != '3' "
	
	cQuery 		:= ChangeQuery(cQuery)
	cAliasCanc	:= GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasCanc, .F., .T.)
	Begin Transaction
	While (cAliasCanc)->(!Eof())	
			cStatus := FO0->FO0_STATUS
			dbSelectArea("FO0")
			FO0->(dbGoTo((cAliasCanc)->RECFO0))
			RecLock("FO0", .F.)				
				FO0->FO0_STATUS := FO0->FO0_BKPSTT
				FO0->FO0_BKPSTT := cStatus
				FO0->FO0_NUMLIQ := ""				
			MsUnlock()
		(cAliasCanc)->(DbSkip())		
	End
	End Transaction
	
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F460APosVld() //POS-VALIDACAO
Rotina que realiza a pos-validação do modelo de dados FINA460A

@author Diego Santos
@since 16/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------
Function F460APosVld( oModel, cAliasSE1 )

Local lRet	 	:= .T.
Local oFO0		:= Nil
Local lIntPfs   := SuperGetMV("MV_JURXFIN",,.F.)

oFO0	:= oModel:GetModel('MASTERFO0') 
cFO0Proc:= oFO0:GetValue("FO0_PROCES")

//Tratamento necessário pois, pela construção do model, esta validação é executada:
// - No botão salvar (pos Validação)
// - No oModel:VldData() (Commit do Model)
If !lValidou

	lRet := F460VldFO1(oModel)
	If lRet
		lRet := F460VldFO2(oModel)
	EndIf
	
	If lRet .And. FwIsInCallStack("TMKA271D")
		lRet := F460TmkVld(oModel)
	EndIf
	
Else
	lValidou := .F.
Endif

If lRet  .And. !lOpcAuto .And.( _nOper <> OPER_BLOQUEAR .And.  _nOper <> OPER_DESBLOQUEAR) 
	If _nOper == OPER_EFETIVAR .OR. _nOper == OPER_LIQUIDAR .OR. _nOper == OPER_RELIQUIDAR .Or.;
	( AllTrim(oFO0:GetValue("FO0_EFETIVA")) == '1' .And. FwIsInCallStack("F460AltSim")) 
		//Se deseja cadastrar os valores acessórios na inclusão
		If mv_par07 == 1 .And. lMostraVA	
			//Exibe a pergunta se deseja cadastrar os valores acessórios para os títulos gerados
			If MsgYesNo(STR0124,STR0056) 	
				Fa460VA(.F.,oModel) 
				lMostraVA	:= .F.
			Endif	
		EndIf
	EndIf
EndIf

If lIntPfs .And. FindFunction("JurPVldLiq")
	lRet := JurPVldLiq(oModel)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F460ACommit() //COMMIT
Rotina que realiza o commit do modelo de dados FINA460A

@author Rodrigo Pirolo
@since 16/10/2015
@version P12.1.8
@return lRet, logical, retorna se o commit foi realizado
@param oModel, object, Objeto do modelo de dados
/*/
//-------------------------------------------------------------------

Function F460ACommit(oModel as object) as logical

	Local cArquivo 		as character
	Local nTotal 		as numeric
	Local nHdlPrv 		as numeric
	Local nCntFor		as numeric
	Local nSe1Rec		as numeric
	Local lHeadProva	as logical
	Local lPadrao		as logical
	Local cPadrao		as character
	Local lContabiliza	as logical
	Local lDigita		as logical
	Local lAglutina		as logical
	Local aComplem		as Array
	Local lGeraNCC		as logical
	Local i				as numeric
	Local lAcreDecre	as logical
	Local nValorTotal	as numeric
	Local nValPadrao	as numeric
	Local aFlagCTB		as Array
	Local lUsaFlag		as logical
	Local aAlt 			as Array
	Local cChaveTit		as character
	Local cChaveFK7		as character
	Local nTxMoeFO0     as numeric
	Local lE1TxFixa     as logical
	Local cFuncOri      as character
	Local nX			as numeric
	Local lRastro		as logical
	Local aRastroOri	as Array
	Local aRastroDes	as Array
	Local nValProces	as numeric
	Local lPccBxCr		as logical
	Local nPropPcc		as numeric
	Local nTotLiq		as numeric
	Local lIrPjBxCr		as logical
	Local aDadosIR		as Array
	Local cIrBxCr		as character
	Local nPropIR		as numeric
	Local nIrrf			as numeric
	Local nTotIr		as numeric
	Local lBaseImp		as logical
	Local nTotBase		as numeric
	Local nBaseImp		as numeric
	Local lAtuSldNat	as logical
	Local nTamSeq		as numeric
	Local cSequencia	as character
	Local lTitpaiSE1	as logical
	Local nOrdTitPai	as numeric
	Local lMata460		as logical
	Local cPeriodoLet	as character
	Local cProdClass	as character
	Local cTpDoc		as character
	Local oModelBxR		as Object
	Local oSubFK1		as Object
	Local oSubFK6		as Object
	Local lRet			as logical
	Local cLog			as character
	Local cCamposE5		as character
	Local cChaveFK1		as character
	Local oSubFO0		as Object
	Local oSubFO1		as Object
	Local oSubFO2		as Object
	Local nTitBxd		as numeric
	Local oView 		as Object
	Local cSE1Chv2		as character
	Local cTitPai		as character
	Local cStatus		as character
	Local nSE1Des		as numeric
	Local nSE1Jur		as numeric
	Local nSE1Multa		as numeric
	Local nLFO1			as numeric
	Local nCount		as numeric
	Local nTotBaixar	as numeric
	Local nTotParc		as numeric
	Local nTotNcc 		as numeric
	Local nSaldoE1		as numeric
	Local nValCor		as numeric
	Local lVersao		as logical
	Local bWhile		as codeblock
	Local aBaixas		as array
	Local lRTipFin		as logical
	Local aBaseImp		as array
	Local aValorImp		as array
	Local nTotBasePis	as numeric
	Local nTotBaseCof	as numeric
	Local nTotBaseCsl	as numeric
	Local nBasePis		as numeric
	Local nBaseCof		as numeric
	Local nBaseCsl		as numeric
	Local nTotValPis	as numeric
	Local nTotValCof	as numeric
	Local nTotValCsl	as numeric
	Local nValorPis		as numeric
	Local nValorCof		as numeric
	Local nValorIrf		as numeric
	Local nValorIns		as numeric
	Local nValorIss		as numeric
	Local nTotValIrf	as numeric 
	Local nTotValIns	as numeric 
	Local nTotValIss	as numeric 
	Local nBaseIrf		as numeric
	Local nBaseIns		as numeric
	Local nBaseIss		as numeric
	Local nTotBaseIrf	as numeric
	Local nTotBaseIns	as numeric
	Local nTotBaseIss	as numeric
	Local nVlrAux		as numeric
	Local nVlrAuxAcr	as numeric
	Local nVlrTtlFO2	as numeric
	Local nSldMoeCon	as numeric
	Local nValBxParc	as numeric
	Local lFilLiq		as logical
	Local cFilAtu		as character
	Local cFilOld		as character
	Local cBanco 		as character
	Local cAgencia 		as character
	Local cConta 		as character
	Local cContrato 	as character
	Local cOrigem		as character
	Local cMvNumLiq		as character
	Local cSldBxCr		as character
	Local aVATit		as array
	Local aVaTitGer		as array
	Local nValorBX		as numeric
	Local nTotFO2		as numeric
	Local lLOJRREC		as logical
	Local lULOJRREC		as logical
	Local __aRelBx		as array
	Local __aRelNovos	as array
	Local lIMPLJRE		as logical
	Local aAreaSe1		as array
	Local aAreaSe5		as array
	Local aAreaRec		as array
	Local aParcelas		as array
	Local nRecSE5		as numeric
	Local lIntPFS       as logical
	Local cJurFat       as character
	Local cJurHist      as character
	Local lSE1Comp  	as logical
	Local nIdLan		as numeric
	Local nLstRecFO2	as numeric
	Local lRetIss		as logical
	Local cTPABISS		as character 
	Local lVldMark		as logical
	Local lRmClass		as logical
	Local lFini460		as logical
	Local nAliquota 	as numeric
	Local nVlrBase		as numeric
	Local lF460IRRF		as logical
	Local lCalcIRRF		as logical
	Local lCalcINSS		as logical
	Local lCalcISS		as logical
	Local cItemCta		as character
	Local cCLVL			as character
	Local nCountFO1		as numeric
	Local cNumFO0       as character
	Local MVTXPIS		as numeric
	Local MVTXCONFIN	as numeric
	Local nVlrMoed		as numeric
	Local nTtlImpAbt	as numeric
	Local nTtlPcc		as numeric
	Local nFo1Tot		as numeric
	Local nF01VlJur		as numeric
	Local nQtdFil		as numeric
	Local cPrefix		as character
	Local cNumLiq		as character
	Local cTxtMsg 		as character
	Local cParc2Ger		as character
	Local nTamParc		as numeric
	Local lChkFO2		as logical
	Local l460PIS		as logical
	Local l460COF		as logical
	Local l460CSL		as logical
	Local l460INS		as logical
	Local l460ISS		as logical
	Local l460IRR		as logical
	Local aArea460		as array
	Local cErrorAuto    as character
	Local aErrorAuto	as array
	Local cTitPaiAbt	as character
	Local nTotAbat 		as numeric
	Local nInicio		as numeric
	Local nFim			as numeric
	Local nGravados		as numeric
	Local nMoedaProc	as numeric
	Local nMoedaTit		as numeric
	local nTamNumLiq	as numeric

	local aAreaAnt		as array
	local aSalDup		as array
	local cAliasTemp	as character
	Local lAtuCli       as logical

	Private nCm			as numeric
	Private __LACO      as numeric
	Private aDiario		as array
	Private nVA			as numeric
	Private aRespInteg  as array
	Private cCCusFO1	as character
	Private cCredit		as character
	Private cDebito		as character
	Private cCcc		as character
	Private cCcd		as character
	Private cItemC		as character
	Private cItemD		as character
	Private cClvlCr		as character
	Private cClvlDb		as character

	Default	__lF460GNCC := ExistBlock("F460GerNCC")
	Default	__lF460NCC  := ExistBlock("F460NCC") 
	Default	__lf460SE1  := ExistBlock("F460SE1")
	Default	__lComiLiq  := ComisBx("LIQ") .AND. SuperGetMv("MV_COMILIQ",,"2") == "1"
	Default	__lTpComis  := SuperGetMV("MV_TPCOMIS",.F.) == "O"	
	Default	__lSE5F460  := ExistBlock("SE5FI460")
	Default	__lF460GSEF := ExistBlock( "F460GRVSEF" )
	Default	__lf460Val  := ExistBlock("F460VAL")
	DEFAULT __lF070Tra  := ExistBlock("F070TRAVA")

	nTotal 		 := 0 
	nHdlPrv 	 := 0
	nCntFor		 := 0
	nSe1Rec		 := 0
	lHeadProva	 := .F.
	lPadrao		 := .F.
	lContabiliza := .F.
	lDigita		 := .T.
	lAglutina	 := .T.
	aComplem	 := {}
	lGeraNCC	 := .T.
	i			 := 0
	lAcreDecre	 := .F.
	nValorTotal	 := 0     
	nValPadrao	 := 0
	aFlagCTB	 := {}
	lUsaFlag	 := SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
	aAlt 		 := {}
	cChaveTit	 := ""
	cChaveFK7	 := ""
	nTxMoeFO0    := 0
	lE1TxFixa    := .F.
	cFuncOri     := ""
	nX			 := 1

	//Rastreamento
	lRastro		 := FVerRstFin()
	aRastroOri	 := {}
	aRastroDes	 := {}
	nValProces	 := oModel:GetModel("MASTERFO0"):GetValue("FO0_VLRLIQ")

	//Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default))
	lPccBxCr	 := FPccBxCr()
	nPropPcc	 := 1
	nTotLiq		 := 0

	//Controla IRPJ na baixa
	lIrPjBxCr	 := FIrPjBxCr()
	aDadosIR	 := Array(3)
	cIrBxCr		 := ""
	nPropIR		 := 1
	nIrrf		 := 0
	nTotIr		 := 0   

	//639.04 Base Impostos diferenciada
	lBaseImp	 := F040BSIMP(2)
	nTotBase	 := 0
	nBaseImp	 := 0
	lAtuSldNat	 := .T.
	nTamSeq		 := TamSX3("E5_SEQ")[1]
	cSequencia	 := StrZero(0,nTamSeq)

	//Controle de abatimento
	lTitpaiSE1	 := .T.
	nOrdTitPai	 := 0
	lMata460	 := .F.
	cPeriodoLet	 := ''
	cProdClass	 := ''
	cTpDoc		 := ''

	//Reestruturação SE5
	oModelBxR	 := FWLoadModel("FINM010")
	lRet		 := .T.
	cLog		 := ""
	cCamposE5	 := ""
	cChaveFK1	 := ""

	//Variaveis para manipulação do Modelo
	oSubFO0		 := oModel:GetModel("MASTERFO0")
	oSubFO1		 := oModel:GetModel("TITSELFO1")
	oSubFO2		 := oModel:GetModel("TITGERFO2")
	nTitBxd		 := oSubFO1:Length()
	oView 		 := FWViewActive()
	cSE1Chv2	 := ""
	cTitPai		 := ""
	cStatus		 := ""
	nSE1Des		 := 0
	nSE1Jur		 := 0
	nSE1Multa	 := 0
	nLFO1		 := 0
	nCount		 := 0
	nTotBaixar	 := TotValFO1(oSubFO1)
	nTotParc	 := TotValFO2(oSubFO2)
	nTotNcc 	 := 0
	nSaldoE1	 := 0
	nValCor		 := 0
	lVersao		 := .F.
	bWhile		 := {|| !EOF() .And. E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA == LEFT(cSE1Chv2, LEN(cSE1Chv2) -3)}
	aBaixas		 := {}

	//Cálculo diferenciado dos impostos - MV_RTIPFIN
	lRTipFin	 := SuperGetMv("MV_RTIPFIN",.F.,"F")
	aBaseImp	 := {0,0,0,0,0,0} // [1]PIS | [2]COFINS | [3]CSLL | [4]IR | [5]INSS | [6]ISS
	aValorImp	 := {0,0,0,0,0,0} // [1]PIS | [2]COFINS | [3]CSLL | [4]IR | [5]INSS | [6]ISS
	nTotBasePis	 := 0 
	nTotBaseCof	 := 0
	nTotBaseCsl	 := 0
	nBasePis	 := 0
	nBaseCof	 := 0
	nBaseCsl	 := 0
	nTotValPis	 := 0 
	nTotValCof	 := 0
	nTotValCsl	 := 0
	nValorPis	 := 0
	nValorCof	 := 0
	nValorIrf	 := 0
	nValorIns	 := 0
	nValorIss	 := 0
	nTotValIrf	 := 0 
	nTotValIns	 := 0 
	nTotValIss	 := 0 
	nBaseIrf	 := 0
	nBaseIns	 := 0
	nBaseIss	 := 0
	nTotBaseIrf	 := 0
	nTotBaseIns	 := 0
	nTotBaseIss	 := 0
	nVlrAux		 := 0
	nVlrAuxAcr	 := 0
	nVlrTtlFO2	 := 0
	nSldMoeCon	 := 0
	nValBxParc	 := 0

	//Tratamento de gravação de filial do processo ou do titulo nas baixas
	lFilLiq		 := (SuperGetMV("MV_FILLIQ",.F.,"1") == "2") //1 = Filial do Processo 2 = Filial do titulo
	cFilAtu		 := cFilAnt
	cFilOld		 := ""
	cBanco 		 := ""
	cAgencia 	 := ""
	cConta 		 := ""
	cContrato 	 := ""
	cOrigem		 := ""
	cMvNumLiq	 := ""
	cSldBxCr	 := SuperGetMv("MV_SLDBXCR",,"B")
	aVATit		 := {}
	aVaTitGer	 := {}

	//Valores acessorios
	nValorBX	 := 0
	nTotFO2		 := 0
	lLOJRREC	 := ExistFunc("LOJRREC")              // Relatorio de impressao de Recibo
	lULOJRREC	 := ExistFunc("U_LOJRRecibo")         // Relatorio de impressao de Recibo (RDMAKE)
	__aRelBx	 := {} //Array com os titulos baixados para impressao do Recibo
	__aRelNovos	 := {} //Array com os Novos Titulos gerados para impressao do Recibo
	lIMPLJRE	 := SuperGetMV( "MV_IMPLJRE",.F., .F.)
	aAreaSe1	 := {}
	aAreaSe5	 := {}
	aAreaRec	 := {} 
	aParcelas	 := {}	
	nRecSE5		 := 0

	// Integração SIGAPFS x SIGAFIN
	lIntPFS      := SuperGetMV("MV_JURXFIN",,.F.)
	cJurFat      := ""
	cJurHist     := ""
	lSE1Comp  	 := FWModeAccess("SE1",3)== "C" // Verifica se SE1 é compartilhada
	nIdLan		 := 0
	nLstRecFO2	 := 0
	lRetIss		 := .T.
	cTPABISS	 := SuperGetMV("MV_TPABISS", .T., "2")
	lVldMark	 := .F.
	lRmClass	 := GetNewPar("MV_RMCLASS",.F.)
	lFini460	 := FwIsInCallStack("FINI460")
	nAliquota 	 := SuperGetMV("MV_ALIQISS",.T.)
	nVlrBase	 := 0
	lF460IRRF	 := .T.
	lCalcIRRF	 := .F.
	lCalcINSS	 := .F.
	lCalcISS	 := .F.
	cItemCta	 := ""
	cCLVL		 := ""
	nCountFO1	 := 0
	cNumFO0      := ""
	MVTXPIS		 := SuperGetMv("MV_TXPIS",.T.)
	MVTXCONFIN	 := SuperGetMV("MV_TXCOFIN",.T.)
	nVlrMoed	 := 0
	nTtlImpAbt	 := 0
	nTtlPcc		 := 0
	nFo1Tot		 := 0
	nF01VlJur	 := 0
	nQtdFil		 := 0
	cPrefix		 := ""
	cNumLiq		 := ""
	cTxtMsg 	 := ""
	cParc2Ger	 := Alltrim(SuperGetMv("MV_1DUP"))
	nTamParc	 := TamSx3("E1_PARCELA")[1]
	lChkFO2		 := .F.
	l460PIS		 := .F.
	l460COF		 := .F.
	l460CSL		 := .F.
	l460INS		 := .F.
	l460ISS		 := .F.
	l460IRR		 := .F.
	aArea460	 := {}
	cErrorAuto   := ""
	aErrorAuto	 := {}
	cTitPaiAbt	 := ""
	nTotAbat 	 := 0
	nInicio		 := 0
	nFim		 := 0
	nGravados	 := 0
	nMoedaProc	 := 0
	nMoedaTit	 := 0
	nTamNumLiq	 := F460TamLiq()

	aAreaAnt	 := {}
	aSalDup		 := {}
	cAliasTemp	 := getNextAlias()

	nCm			:= 0
	aDiario		:= {}
	nVA			:= 0
	cCCusFO1	:= ""
	cCredit		:= ""
	cDebito		:= ""
	cCcc		:= ""
	cCcd		:= ""
	cItemC		:= ""
	cItemD		:= ""
	cClvlCr		:= ""
	cClvlDb		:= ""
	
	lAtuCli		:= .T.

	If Type("cParc460") == "U"
		Private cParc460 := F460Parc()
	EndIf

	//Proteção para liquidação via EAI, que nao passa pelo ponto de declaração da variavel
	If Type("cCodDiario") == "U"
		If UsaSeqCor()
			Private cCodDiario := CTBAVerDia()
		Endif
	EndIf

	__lMetric	:= FwLibVersion() >= "20210517"

	cMvNumLiq := AllTrim(GetMv("MV_NUMLIQ",,.T.))
	cMvNumLiq := Replicate("0", nTamNumLiq - Len(cMvNumLiq)) + cMvNumLiq
	cMvNumLiq := left(cMvNumLiq, nTamNumLiq)
	cMvNumLiq := Soma1(cMvNumLiq)

	While !MayIUseCode("SE1"+xFilial("SE1")+cMvNumLiq)  //verifica se esta na memoria, sendo usado e se o número é válido
		// busca o proximo numero disponivel
		cMvNumLiq := Soma1(cMvNumLiq)
	EndDo

	//Variáveis para integração RM Classis
	cNumRA		:= IIf( Type('cNumRA') 	== 'U'	, "", cNumRA		)
	nIDAPLIC	:= IIf( Type('nIDAPLIC') == 'U'	, 0	, nIDAPLIC		)
	cTurma		:= IIf( Type('cTurma') 	== 'U'	, "", cTurma		)
	cPeriodoLet	:= IIf( cPeriodoLet == Nil		, "", cPeriodoLet	)
	cProdClass	:= IIf( cProdClass == Nil		, "", cProdClass	)
	cContrato	:= IIf( cContrato == Nil		, "", cContrato		)
	lCpoTxMoed  := FO0->(ColumnPos("FO0_TXMOED")) > 0
	If lCpoTxMoed
		nTxMoeFO0 := oSubFO0:GetValue("FO0_TXMOED")
	EndIf

	If Type( "lMsErroAuto" ) == "U"
		PRIVATE lMsErroAuto := .F.
	EndIf

	If Type( "lRecalcula" ) == "U"
		PRIVATE lRecalcula := .F.
	EndIf

	If lOpcAuto 
		If( Type("aRotAutoVA") == "A")	
			aVaTitGer := Aclone(aRotAutoVA)
		EndIf
	Else
		aVaTitGer := F460AAVA()
	EndIf

	aFill(aDadosIR,0)

	oSubFO1:SetNoDeleteLine(.F.)
	oSubFO2:SetNoDeleteLine(.F.)

	//Verifica se existem os capos de valores de acrescimo e decrescimo no SE5
	lAcreDecre := .T.
	nSaldoBx := 0

	//Zerar variaveis para contabilizar os impostos da lei 10925.
	VALOR  := 0
	VALOR5 := 0
	VALOR6 := 0
	VALOR7 := 0

	//Correcao Monetaria
	nCm := 0

	For nlFO1:= 1 To oSubFO1:Length()
		oSubFO1:GoLine(nLFO1)
		If oSubFO1:GetValue("FO1_MARK")
			lVldMark := .T.
			Exit
		Endif
	Next nlFO1

	If !lVldMark
		Help( ,,"VLDMARK",, STR0154 , 1, 0 ) // "Não existe titulo selecionado para negociação. Favor selecionar. "
		Return .F.
	Endif

	If Type("__nOpcOuMo") = "U"
		__nOpcOuMo := 2
	EndIf

	If nTxMoeFO0 > 0 .And. __nOpcOuMo = 3 
		If !lOpcAuto  
			If Aviso(STR0056 + STR0172 , + ; //"Atenção!" # " Taxa Fixa ou Taxa Variável"
				STR0173 + Alltrim(Transform(nTxMoeFO0,PesqPict("SE1","E1_TXMOEDA"))) +	STR0174 + CRLF + CRLF + ; //"A taxa da moeda informada no valor de " # " deverá ser fixa para os títulos que serão gerados ou esses novos títulos deverão ter correção monetária na baixa? "
				STR0175 + CRLF + CRLF + ; //"FIXA: A taxa informada será gravada no campo E1_TXMOEDA, de todos os títulos que serão gerados por essa liquidação, e esses títulos não sofrerão variação monetária."
				STR0176 + CRLF + CRLF + ; //"VARIÁVEL: A taxa informada NÃO será gravada nos títulos que serão gerados por essa liquidação, logo ao serem baixados será utilizada a taxa do dia da movimentação e, havendo variação da taxa, será gerada movimentaçao de correçao monetária."
				STR0177 , {STR0178,STR0179}) = 2 //"Clique na opção desejada!" # "Variável" # "Fixa"
				lE1TxFixa := .T.
			EndIf
		Else
			lE1TxFixa := Iif(nTpTaxa=2,.T.,.F.)
		EndIf
	EndIf

	// Inicia controle de transacao
	Begin Transaction

	If (FwIsInCallStack("TA45GerLiq") .Or. FwIsInCallStack("TMKA271D")) .And. !FwIsInCallStack("F460AEfet") .And. !FwIsInCallStack("F460ABlqCan")
		If AllTrim(oSubFO0:GetValue("FO0_EFETIVA")) == '1'
			_nOper := OPER_LIQUIDAR
		Else
			If !FwIsInCallStack("F460AltSim")
				_nOper := OPER_INCLUI
			EndIf
		EndIf
	EndIf

	If _nOper == OPER_INCLUI .AND. ( FwIsInCallStack("F460AIncl") .Or. FwIsInCallStack("TMKA271D") ) .And. AllTrim(oSubFO0:GetValue("FO0_EFETIVA")) == '2' 
		F460AIncE(oModel, .F.)
	ElseIf _nOper == OPER_ALTERA .AND. ( FwIsInCallStack("F460AltSim") .Or. FwIsInCallStack("TMKA271D") ) .And. AllTrim(oSubFO0:GetValue("FO0_EFETIVA")) == '1'
		lVersao:= F460AIncE(oModel, .T.)
	EndIf

	If _nOper == OPER_EFETIVAR .OR. _nOper == OPER_LIQUIDAR .OR. _nOper == OPER_RELIQUIDAR

		//--------------------------------------------------------
		// Baixa dos titulos utilizados na liquidação		
		//--------------------------------------------------------
		__aBaixados :={}

		//Metricas - Gravação da Liquidação
		If __lMetric
			nInicio := Seconds()
		Endif

		For nX := 1 To oSubFO2:Length()
			oSubFO2:GoLine(nX)
			If !oSubFO2:IsDeleted()
				nVlrAux    += oSubFO2:GetValue("FO2_DECRES")
				nVlrAuxAcr += oSubFO2:GetValue("FO2_ACRESC")
				nVlrTtlFO2 += oSubFO2:GetValue("FO2_VALOR")
			Endif
		Next nX
		
		nSldLiq  := oSubFO0:GetValue("FO0_VLRNEG")
			
		If SE4->E4_TIPO == "9"
			If ! IsBlind()
				If nValProces < nVlrTtlFO2
					If Aviso(STR0056, STR0155 + CRLF + ; //"Atenção" # "Validação da condição de Pagamento do tipo '9'."
						STR0156 + CRLF + ; //"O valor negociado é 'MAIOR' que o valor a ser gerado."
						STR0158 + Alltrim(Transform(nVlrTtlFO2 - nValProces,PesqPict("SE1","E1_VALOR"))) + ". "  + CRLF + STR0049, {STR0047,STR0048}) = 2 //"Será gerado uma NCC no valor de " # "Efetiva Liquidação?"
						oModel:SetErrorMessage("","","","","F460ACOMMIT",STR0160,"") //"Verifique os valores negociados."
						RollBackDelTran()
						Return .F.
					Endif
				ElseIf nValProces > nVlrTtlFO2
					If Aviso(STR0056, STR0155 + CRLF + ; //"Atenção" # "Validação da condição de Pagamento do tipo '9'."
						STR0157 + CRLF + ; //"O valor negociado é 'MENOR' que o valor a ser gerado."
						STR0159  + CRLF + STR0049, {STR0047,STR0048}) = 2 // # "Efetiva Liquidação?"
						oModel:SetErrorMessage("","","","","F460ACOMMIT",STR0160,"") //"Verifique os valores negociados."
						RollBackDelTran()
						Return .F.
					Endif
				Endif
			Endif
		Endif
		
		If nVlrAux > 0 .Or. nVlrAuxAcr > 0
			If nVlrAux > 0
				If  oSubFO0:GetValue("FO0_VLRLIQ") = (nVlrAux + nSldLiq)
					nSldLiq := oSubFO0:GetValue("FO0_VLRLIQ")
				Else
					nSldLiq += nVlrAux
				Endif
				If nVlrAuxAcr > 0
					nSldLiq -= nVlrAuxAcr
				Endif
			ElseIf nVlrAuxAcr > 0
				If  oSubFO0:GetValue("FO0_VLRLIQ") = (nVlrAuxAcr + nSldLiq)
					nSldLiq := oSubFO0:GetValue("FO0_VLRLIQ")
				Else
					nSldLiq -= nVlrAuxAcr
				Endif
			Endif
		Endif

		If cVl460Nt $ "2|3"
			aArea460	:= SE1->(GetArea())
			DbSelectArea("SE1")
			SE1->(DbSetOrder(2)) // Filial+Cliente+Loja+Prefixo+Num+Parcela+Tipo
			For nLFO1 := 1 To oSubFO1:Length()
				oSubFO1:GoLine(nLFO1)
				If oSubFO1:GetValue("FO1_MARK")
					cSE1Chv2 :=	xFilial("SE1",oSubFO1:GetValue("FO1_FILORI")) + oSubFO1:GetValue("FO1_CLIENT") + oSubFO1:GetValue("FO1_LOJA") +;
								oSubFO1:GetValue("FO1_PREFIX") + oSubFO1:GetValue("FO1_NUM") + oSubFO1:GetValue("FO1_PARCEL") + oSubFO1:GetValue("FO1_TIPO")
					If SE1->(DbSeek(cSE1Chv2))   // Filial+Cliente+Loja+Prefixo+Num+Parcela+Tipo
						If SE1->E1_SALDO > 0
							If !Empty(SE1->E1_PIS)
								l460PIS := .T.
							Endif
							If !Empty(SE1->E1_COFINS)
								l460COF := .T.
							Endif
							If !Empty(SE1->E1_CSLL)
								l460CSL := .T.
							Endif
							If !Empty(SE1->E1_INSS)
								l460INS := .T.
							Endif
							If !Empty(SE1->E1_ISS)
								l460ISS := .T.
							Endif
							If !Empty(SE1->E1_IRRF)
								l460IRR := .T.
							Endif
						Endif
					EndIf
				Endif
			Next nLFO1
			RestArea(aArea460)
		EndIf

		For nLFO1 := 1 To oSubFO1:Length()
			oSubFO1:GoLine(nLFO1)
			nTotFO2 := oSubFO1:GetValue("FO1_TOTAL")
			If oSubFO1:GetValue("FO1_MARK") .And. nSldLiq > 0
				
				//Alimenta o valor adicional na variavel exclusiva de contabilização
				If lCpoFO1Ad
					FO1VADI := oSubFO1:GetValue("FO1_VLADIC")
				EndIf
				
				nCountFO1++
				
				If nSldLiq  >= nTotFO2
					nValorBX := nTotFO2
					nSldLiq -= nValorBX
				ElseIf nSldLiq > 0
					If (nSldLiq - nTotFO2) < 0
						nValorBX := nTotFO2 - (nTotFO2 - nSldLiq)
						nSldLiq -= nValorBX
					Endif
				Else
					nValorBX := nSldLiq
					nSldLiq -= nValorBX
				EndIf
							
				oSubFO1:LoadValue("FO1_TOTAL",nValorBX)
				oSubFO1:LoadValue("FO1_SALDO",nValorBX)

				cSE1Chv2:=	XFILIAL("SE1",oSubFO1:GetValue("FO1_FILORI")) + oSubFO1:GetValue("FO1_CLIENT") + oSubFO1:GetValue("FO1_LOJA") +;
							oSubFO1:GetValue("FO1_PREFIX") + oSubFO1:GetValue("FO1_NUM") + oSubFO1:GetValue("FO1_PARCEL") + oSubFO1:GetValue("FO1_TIPO")
				
				cTitPai:=	oSubFO1:GetValue("FO1_CLIENT") + oSubFO1:GetValue("FO1_LOJA") + oSubFO1:GetValue("FO1_PREFIX") +;
							oSubFO1:GetValue("FO1_NUM") + oSubFO1:GetValue("FO1_PARCEL") + oSubFO1:GetValue("FO1_TIPO")

				cTitPaiAbt:= oSubFO1:GetValue("FO1_PREFIX") + oSubFO1:GetValue("FO1_NUM") + oSubFO1:GetValue("FO1_PARCEL") +;
							oSubFO1:GetValue("FO1_TIPO") + oSubFO1:GetValue("FO1_CLIENT") + oSubFO1:GetValue("FO1_LOJA")
				
				If FwIsInCallStack("TMKA271D")
					nSE1Des	:= oSubFO1:GetValue("FO1_DESCON") + oSubFO1:GetValue("FO1_DECRES") + oSubFO1:GetValue("FO1_DESJUR")// antigo TRB->DESCON
				Else
					nSE1Des	:= oSubFO1:GetValue("FO1_DESCON") + oSubFO1:GetValue("FO1_DECRES")			
				EndIf
				nSE1Jur := oSubFO1:GetValue("FO1_VLJUR") + oSubFO1:GetValue("FO1_ACRESC") // antigo TRB->JUROS
				
				nSE1Multa 	:= oSubFO1:GetValue("FO1_VLMUL")  
				nVA		 	:= oSubFO1:GetValue("FO1_VACESS")
				
				DbSelectArea("SE1")
				SE1->(DbSetOrder(2)) // Filial+Cliente+Loja+Prefixo+Num+Parcela+Tipo
				
				If SE1->(MsSeek(cSE1Chv2))   // Filial+Cliente+Loja+Prefixo+Num+Parcela+Tipo
					nSE1Rec := SE1->(Recno())
				EndIf
				
				aAdd(__aBaixados, {SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO })
				__cNroLiqui := oSubFO0:GetValue("FO0_NUMLIQ")
				
				If Empty(__cNroLiqui)
					oSubFO0:LoadValue("FO0_NUMLIQ", cMvNumLiq)
					__cNroLiqui := oSubFO0:GetValue("FO0_NUMLIQ")
				EndIf
				
				If lRmClass .And. (Empty(cPeriodoLet) .Or. Empty(cProdClass))
					cPeriodoLet := SE1->E1_PERLET
					cProdClass	:= SE1->E1_PRODUTO
					nIdLan		:= SE1->E1_IDLAN
					If SE1->E1_ORIGEM = "S" 
						cOrigem := SE1->E1_ORIGEM
					Endif
				EndIf

				//Verificacao SIGAPLS
				If lPLSCTFIN .and. PLSCTFIN('SE1') 
					cOrigem := SE1->E1_ORIGEM
				EndIf

				If FWHasEAI('FINA460',.T.,,.T.)
					cBanco 		:= SE1->E1_PORTADO
					cAgencia 	:= SE1->E1_AGEDEP
					cConta 		:= SE1->E1_CONTA
					cContrato 	:= SE1->E1_CONTRAT
				EndIf
				
				If lCpoTxMoed
					nVlrMoed := oSubFO0:GetValue("FO0_TXMOED")
				Else
					nVlrMoed := IIF(SE1->E1_TXMOEDA > 0,SE1->E1_TXMOEDA,RecMoeda(dDataBase, oSubFO0:GetValue("FO0_MOEDA") ))
				Endif

				If oSubFO1:GetValue("FO1_MOEDA") <> oSubFO0:GetValue("FO0_MOEDA")
					If oSubFO1:GetValue("FO1_MOEDA") == 1 
						nSldMoeCon	:= NoRound(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,oSubFO0:GetValue("FO0_MOEDA"),,3),3)
						nSaldoBx	:= Round(Round(xMoeda( nSldMoeCon  ,oSubFO0:GetValue("FO0_MOEDA"), oSubFO1:GetValue("FO1_MOEDA"),,3,,oSubFO1:GetValue("FO1_TXMOED")),3),2)
					Else
						If oSubFO0:GetValue("FO0_MOEDA") == 1   
							nTxMoeDia := IIF(SE1->E1_TXMOEDA > 0,SE1->E1_TXMOEDA,RecMoeda(dDataBase, oSubFO1:GetValue("FO1_MOEDA") ) )
							nSaldoBx  := Round(Round(xMoeda(nValorBX,oSubFO0:GetValue("FO0_MOEDA"),oSubFO1:GetValue("FO1_MOEDA"),dDataBase,3,nTxMoeDia,oSubFO1:GetValue("FO1_TXMOED")),3),2)
						Else
							nTxMoeDia := IIF(SE1->E1_TXMOEDA > 0,SE1->E1_TXMOEDA,RecMoeda(dDataBase, oSubFO1:GetValue("FO1_MOEDA") ))
							If nTxMoeDia <> oSubFO1:GetValue("FO1_TXMOED")
								nSaldoBx	:= Round(Round(xMoeda(nValorBX,oSubFO0:GetValue("FO0_MOEDA"),oSubFO1:GetValue("FO1_MOEDA"),dDataBase,3,RecMoeda(dDataBase, oSubFO0:GetValue("FO0_MOEDA")),oSubFO1:GetValue("FO1_TXMOED")),3),2)
							Else
								nSldMoeCon 	:= Round(NoRound(xMoeda(SE1->E1_SALDO,oSubFO1:GetValue("FO1_MOEDA"), oSubFO0:GetValue("FO0_MOEDA"),,3,oSubFO1:GetValue("FO1_TXMOED")),3),2)
								nSaldoBx	:= Round(NoRound(xMoeda(nSldMoeCon,oSubFO0:GetValue("FO0_MOEDA"), oSubFO1:GetValue("FO1_MOEDA"),dDataBase,3,,oSubFO1:GetValue("FO1_TXMOED")),3),2)
							Endif
						Endif
					Endif	
				Else		
					nSaldoBx	:= nValorBX
				EndIf
				nValBx		:= nSaldoBx - (   nSE1Multa + nSE1Jur - nSE1Des + nVA)
				
				//Correcao Monetaria
				nCm := 0
				nValCor	:= nValBx
				If oSubFO1:GetValue("FO1_MOEDA") > 1 .And. oSubFO1:GetValue("FO1_MOEDA") <> oSubFO0:GetValue("FO0_MOEDA")
					nCm := FA460CORR(nValCor,oSubFO1:GetValue("FO1_MOEDA"),oSubFO1:GetValue("FO1_TXMOED"))
				Endif
			
				nValPadrao	:= nValBx
				nAbatim		:= oSubFO1:GetValue("FO1_VLABT")
				nSaldoE1	:= SE1->E1_SALDO - nValBx
				
				If Str(nSaldoE1,17,2) == STR(nAbatim,17,2)
					nValBx += nAbatim
					nSaldoE1 -= nAbatim 
					nValPadrao := nValBx
				Endif

				//Corrige eventuais problemas de arredondamento da moeda
				If nSaldoE1 <= 0.009 //ABS(nSaldoE1) <= 0.009
					nSaldoE1 := 0
				Endif

				If nTotParc == nTotBaixar
					nTotBaixar := 0
				Elseif nTotParc > nTotBaixar .and. nTotBaixar > 0
					nTotNcc := nTotParc - nTotBaixar
				Endif	

				nTitBxd--

				If cPaisloc == "BRA"	
					If oSubFO0:GetValue("FO0_NATURE") = SE1->E1_NATUREZ
						If SE1->E1_SALDO <> SE1->E1_VALOR

							BEGINSQL alias cAliasTemp
								SELECT COALESCE(SUM(E1_VALOR),0) TOTAL
								FROM %table:SE1% SE1
								WHERE SE1.%notDel%
								AND E1_TITPAI = %exp:cTitPaiAbt%
								AND E1_TIPO IN ('PIS','COF','CSL','IRF')
								AND E1_FILIAL = %exp:SE1->E1_FILIAL%
								AND E1_PREFIXO = %exp:SE1->E1_PREFIXO%
								AND E1_NUM = %exp:SE1->E1_NUM%
								AND E1_CLIENTE = %exp:SE1->E1_CLIENTE%
								AND E1_LOJA = %exp:SE1->E1_LOJA%
							ENDSQL
							if !(cAliasTemp)->(Eof())
								nTotAbat := (cAliasTemp)->TOTAL
							endif	 
							(cAliasTemp)->(DbCloseArea())	
				
							If cVl460Nt != '3' .Or. (cVl460Nt == '3' .And. ( l460PIS .Or. l460COF .Or. l460CSL ) )
								
								if cVl460Nt = '2' .AND. !lPCCBxCr
									nPropPcc   := SE1->E1_VALOR
								else	
									nValBxParc := (SE1->E1_VALOR-SE1->E1_SALDO) - nTotAbat
									nPropPcc   := SE1->E1_VALOR - nValBxParc
								endif	

								aValorImp[01] += NoRound((SED->ED_PERCPIS * nPropPcc / 100),2) //PIS
								aValorImp[02] += NoRound((SED->ED_PERCCOF * nPropPcc / 100),2) //COFINS
								aValorImp[03] += NoRound((SED->ED_PERCCSL * nPropPcc / 100),2) //CSLL
			
								aBaseImp[01]  += nPropPcc//PIS
								aBaseImp[02]  += nPropPcc//COFINS
								aBaseImp[03]  += nPropPcc//CSLL
							EndIf

							If cVl460Nt != '3' .Or. (cVl460Nt == '3' .And. l460IRR )
								aValorImp[04] += SE1->E1_IRRF    //IR
								aBaseImp[04]  += SE1->E1_BASEIRF  //IR
							EndIf						
							
							If cVl460Nt != '3' .Or. (cVl460Nt == '3' .And. l460INS )
								aBaseImp[05]  += SE1->E1_BASEINS  //INSS
								aValorImp[05] += SE1->E1_INSS    //INSS
							EndIf
							If cVl460Nt != '3' .Or. (cVl460Nt == '3' .And. l460ISS )
								aBaseImp[06]  += SE1->E1_BASEISS  //ISS
								aValorImp[06] += SE1->E1_ISS     //ISS
							EndIf					
						Else
							nPropPcc := nValPadrao/SE1->E1_VALOR
							//Cálculo diferenciado dos impostos - MV_RTIPFIN

							If cVl460Nt != '3' .Or. (cVl460Nt == '3' .And. ( l460PIS .Or. l460COF .Or. l460CSL ) )
					
								aValorImp[01] += SE1->E1_PIS     * nPropPcc //PIS
								aValorImp[02] += SE1->E1_COFINS  * nPropPcc	//COFINS
								aValorImp[03] += SE1->E1_CSLL    * nPropPcc	//CSLL

								aBaseImp[01]  += SE1->E1_BASEPIS * nPropPcc//PISM
								aBaseImp[02]  += SE1->E1_BASECOF * nPropPcc//COFINS
								aBaseImp[03]  += SE1->E1_BASECSL * nPropPcc//CSLL
							EndIf
							If cVl460Nt != '3' .Or. (cVl460Nt == '3' .And. l460IRR )
								aValorImp[04] += SE1->E1_IRRF    * nPropPcc	//IR
								aBaseImp[04]  += SE1->E1_BASEIRF * nPropPcc//IR
							EndIf
							If cVl460Nt != '3' .Or. (cVl460Nt == '3' .And. l460INS )
								aValorImp[05] += SE1->E1_INSS    * nPropPcc	//INSS
								aBaseImp[05]  += SE1->E1_BASEINS * nPropPcc//INSS
							EndIf
							If cVl460Nt != '3' .Or. (cVl460Nt == '3' .And. l460ISS )
								aValorImp[06] += SE1->E1_ISS     * nPropPcc	//ISS
								aBaseImp[06]  += SE1->E1_BASEISS * nPropPcc//ISS
							EndIf
						//Cálculo diferenciado dos impostos - MV_RTIPFIN	
						EndIf
					ElseIf cVl460Nt = "1"
						nPropPcc := nValPadrao/SE1->E1_VALOR
						nVlrBase := SE1->E1_VALOR
						//Cálculo diferenciado dos impostos - MV_RTIPFIN
						If SED->ED_CALCCSL == "S" .Or. SED->ED_CALCCOF == "S" .Or. SED->ED_CALCPIS == "S" .Or. ;
							SED->ED_CALCIRF == "S" .Or. SED->ED_CALCINS == "S" .Or. SED->ED_CALCISS == "S"
							
							If SA1-> A1_RECPIS == "S" .And. SED->ED_CALCPIS == "S"
								aValorImp[01] += NoRound((nVlrBase * (Iif(SED->ED_PERCPIS > 0, SED->ED_PERCPIS, MVTXPIS) / 100)),2) //PIS
								aBaseImp[01]  += nVlrBase * nPropPcc//PIS	
							Endif
							
							If SA1-> A1_RECCOFI == "S" .And. SED->ED_CALCCOF == "S"
								aValorImp[02] += NoRound((nVlrBase * (Iif(SED->ED_PERCCOF > 0, SED->ED_PERCCOF, MVTXCONFIN) / 100)),2) //COFINS
								aBaseImp[02]  += nVlrBase	* nPropPcc //COFINS			
							Endif
							
							If SA1-> A1_RECCSLL == "S" .And. SED->ED_CALCCSL == "S"
								aValorImp[03] += NoRound((nVlrBase * (SED->ED_PERCCSL / 100)),2) //CSLL
								aBaseImp[03]  += nVlrBase	* nPropPcc //CSLL
							Endif
							
							If SED->ED_CALCIRF == "S"
								aValorImp[04] += F040CalcIr(nVlrBase,,.T.,,,lF460IRRF)	//IR
								aBaseImp[04]  += nVlrBase	* nPropPcc//IR
								lCalcIRRF	  := .T.
							Endif
							
							If SA1->A1_RECINSS == "S" .And. SED->ED_CALCINS == "S"
								aValorImp[05] += (nVlrBase * (SED->ED_PERCINS / 100)) //ISS
								aBaseImp[05]  +=  nVlrBase * nPropPcc //INSS
								lCalcINSS	  := .T.
							Endif
							
							If SA1-> A1_RECISS == "1" .And. SED->ED_CALCISS == "S"
								aValorImp[06] += nVlrBase * nAliquota / 100	//ISS
								aBaseImp[06]  += nVlrBase * nPropPcc //ISS
								lCalcISS	  := .T.
							Endif
						Endif
					ElseIf cVl460Nt $ "2|3"
						nPropPcc := nValPadrao/SE1->E1_VALOR
						nVlrBase := SE1->E1_VALOR

						If	SED->ED_CALCCSL == "S" .Or. SED->ED_CALCCOF == "S" .Or. SED->ED_CALCPIS == "S" .Or. ;
							SED->ED_CALCIRF == "S" .Or. SED->ED_CALCINS == "S" .Or. SED->ED_CALCISS == "S"

							If cVl460Nt != '3' .Or. (cVl460Nt == '3' .And. ( l460PIS .Or. l460COF .Or. l460CSL ) )
					
								If SA1->A1_RECPIS == "S" .And. SED->ED_CALCPIS == "S"
									If 	!Empty(SE1->E1_PIS)
										aValorImp[01] += SE1->E1_PIS	 * nPropPcc //PIS
										aBaseImp[01]  += SE1->E1_BASEPIS * nPropPcc//PISM
									ElseIf !l460PIS 
										aValorImp[01] += NoRound((nVlrBase * (Iif(SED->ED_PERCPIS > 0, SED->ED_PERCPIS, MVTXPIS) / 100)),2) //PIS
										aBaseImp[01]  += nVlrBase * nPropPcc//PIS	
									Endif
								Endif

								If SA1-> A1_RECCOFI == "S" .And. SED->ED_CALCCOF == "S"
									If !Empty(SE1->E1_COFINS)
										aValorImp[02] += SE1->E1_COFINS  * nPropPcc	//COFINS
										aBaseImp[02]  += SE1->E1_BASECOF * nPropPcc//COFINS
									ElseIf !l460COF
										aValorImp[02] += NoRound((nVlrBase * (Iif(SED->ED_PERCCOF > 0, SED->ED_PERCCOF, MVTXCONFIN) / 100)),2) //COFINS
										aBaseImp[02]  += nVlrBase	* nPropPcc //COFINS			
									Endif
								Endif

								If SA1-> A1_RECCSLL == "S" .And. SED->ED_CALCCSL == "S"
									If !Empty(SE1->E1_CSLL)
										aValorImp[03] += SE1->E1_CSLL    * nPropPcc	//CSLL
										aBaseImp[03]  += SE1->E1_BASECSL * nPropPcc//CSLL
									ElseIf !l460CSL
										aValorImp[03] += NoRound((nVlrBase * (SED->ED_PERCCSL / 100)),2) //CSLL
										aBaseImp[03]  += nVlrBase	* nPropPcc //CSLL
									Endif
								Endif
							EndIf

							If cVl460Nt != '3' .Or. (cVl460Nt == '3' .And. l460IRR )

								If SED->ED_CALCIRF == "S"
									If !Empty(SE1->E1_IRRF)
										aValorImp[04] += SE1->E1_IRRF    * nPropPcc	//IR
										aBaseImp[04]  += SE1->E1_BASEIRF * nPropPcc//IR
									ElseIf !l460IRR
										aValorImp[04] += F040CalcIr(nVlrBase,,.T.,,,lF460IRRF)	//IR
										aBaseImp[04]  += nVlrBase	* nPropPcc//IR
										lCalcIRRF	  := .T.
									Endif
								Endif
							EndIf
							If cVl460Nt != '3' .Or. (cVl460Nt == '3' .And. l460INS )
								If SA1->A1_RECINSS == "S" .And. SED->ED_CALCINS == "S"
									If !Empty(SE1->E1_INSS)
										aValorImp[05] += SE1->E1_INSS    * nPropPcc	//INSS
										aBaseImp[05]  += SE1->E1_BASEINS * nPropPcc//INSS
									ElseIf !l460INS
										aValorImp[05] += (nVlrBase * (SED->ED_PERCINS / 100)) //ISS
										aBaseImp[05]  +=  nVlrBase * nPropPcc //INSS
										lCalcINSS	  := .T.
									EndIf
								EndIf
							EndIf

							If cVl460Nt != '3' .Or. (cVl460Nt == '3' .And. l460ISS )
								If SA1-> A1_RECISS == "1" .And. SED->ED_CALCISS == "S"
									If !Empty(SE1->E1_ISS)
										aValorImp[06] += SE1->E1_ISS     * nPropPcc	//ISS
										aBaseImp[06]  += SE1->E1_BASEISS * nPropPcc//ISS
									ElseIf !l460ISS
										aValorImp[06] += nVlrBase * nAliquota / 100	//ISS
										aBaseImp[06]  += nVlrBase * nPropPcc //ISS
										lCalcISS	  := .T.
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
				
				//---------------------------------------------------------------
				// Baixa titulos no SE1, procurando por abatimentos e 
				// se for o caso, gera NCC para o cliente quando valor
				// dos cheques for maior que o dos titulos selecionados
				//---------------------------------------------------------------
				If SE1->E1_MOEDA > 1
					If nSaldoE1 <= 0.01
						//nSaldoBx := SE1->E1_SALDO
						nCm	:= Iif(Iif(oSubFO1:GetValue("FO1_TXMOED") != RecMoeda(dDataBase,SE1->E1_MOEDA), oSubFO1:GetValue("FO1_TXMOED"), RecMoeda(dDataBase,SE1->E1_MOEDA)) == If(Empty(SE1->E1_TXMOEDA), RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA), SE1->E1_TXMOEDA), 0, nCm)
						nSaldoE1 := 0
					EndIf
				EndIf
				
				DbSelectArea("SE1")
				If SE1->(MsSeek(cSE1Chv2))
					nSE1Rec := Recno()
					If !Empty(SE1->E1_NUMLIQ) .AND. _nOper == OPER_RELIQUIDAR // lReliquida
						cStatus := "R"
					Else
						cStatus := "B"
					EndIf
					
					cTipo:= "LIQ" 
					
					//--------------------------------------------------------------------------
					// Valores Acessórios - Atualiza saldo na FKD
					//--------------------------------------------------------------------------
					FAtuFKDBx(.F.)

					RecLock("SE1",.F.)
						Replace E1_VALLIQ	With nSaldoBx
						Replace E1_SALDO	With nSaldoE1 
						Replace E1_BAIXA	With Iif(dDataBase >= E1_BAIXA, dDataBase, E1_BAIXA)
						Replace E1_MOVIMEN	With dDataBase
						Replace E1_STATUS	With cStatus
						Replace E1_TIPOLIQ	With cTipo
						Replace E1_SDACRES	With 0
						Replace E1_SDDECRE	With 0
						Replace E1_JUROS	With nSE1Jur
						Replace E1_DESCONT	With nSE1Des
						Replace E1_CORREC	With nCm
						Replace E1_MULTA	With nSE1Multa
					SE1->(MsUnlock())
					
					//Metricas - Gravados
					nGravados += 1	

					If SE1->E1_ORIGEM = "MATA460" .And. cTPABISS = "1"
						lRetIss := .F.
					Endif
					
					If lAtuSldNat // SUBTRAIR O VALOR DO CAMPO FIV_TOTAL QUANDO NF
						If !SE1->E1_TIPO $ MVABATIM
							If lSE1Comp
								AtuSldNat(SE1->E1_NATUREZ, SE1->E1_VENCREA, SE1->E1_MOEDA, "2", "R", SE1->E1_VALOR, SE1->E1_VLCRUZ, "-",,FunName(),"SE1", SE1->(Recno()),0 , ,0, SE1->E1_FILORIG)
							Else
								AtuSldNat(SE1->E1_NATUREZ, SE1->E1_VENCREA, SE1->E1_MOEDA, "2", "R", SE1->E1_VALOR, SE1->E1_VLCRUZ, "-",,FunName(),"SE1", SE1->(Recno()),0 , ,0, SE1->E1_FILIAL)
							Endif
						Endif
					Endif
					
					aadd(__aRelBx, {	SE1->E1_NUM				,;	//01-Nro do Titulo
							SE1->E1_PREFIXO			,;	//02-Prefixo
							SE1->E1_PARCELA			,;	//03-Parcela
							SE1->E1_TIPO 			,;	//04-Tipo
							SE1->E1_CLIENTE			,;	//5-Cliente
							SE1->E1_LOJA			,;	//6-Loja
							Dtos(SE1->E1_EMISSAO)	,;	//7-Emissao
							Dtos(SE1->E1_VENCTO)	,;	//8-Vencimento
							SE1->E1_VLCRUZ			,;	//9-Valor Original
							SE1->E1_SALDO			,;	//10-Saldo
							SE1->E1_MULTA			,;	//11Multa
							SE1->E1_JUROS			,;	//12Juros
							SE1->E1_DESCONT			,;	//13Desconto
							SE1->E1_VALLIQ			})	//14Valor Recebido		
					//Rastreamento - Geradores
					If lRastro
						aadd(aRastroOri,{ SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,;
											SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_VALLIQ } )
					EndIf
					
					//------------------------------------------------------------------------------
					// Função Específica do Modulo Sigapls para atualizar Status de Guias Compradas 
					//------------------------------------------------------------------------------
					PL090TITCP(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,"1")
					
					//---------------------------------------------------------------
					// Integracao Protheus X RM Classis Net (RM Sistemas)
					//---------------------------------------------------------------
					if lRmClass .and. !Empty(SE1->E1_NUMRA)
						cNumRA 		:= SE1->E1_NUMRA 				 	//Pega o numero do RA do aluno para alimentar o campo E1_NUMRA com a inclusao do novo titulo
						nIDAPLIC 	:= SE1->E1_IDAPLIC 					//Pega o numero do IDENTIFICADOR DA MATRIZ APLICADA para alimentar o campo E1_IDAPLIC com a inclusao do novo titulo
						cTurma 		:= SE1->E1_TURMA 					//Pega a Turma do Aluno para alimentar o campo E1_TURMA com a inclusao do novo titulo
					EndIf
		
					If mv_par05 == 1  // Exclui cheque amarrado ao titulo liquidado
						//---------------------------------------------------------------
						// Verifica se existe um cheque gerado para este TITULO	
						// pois se tiver, dever  ser cancelado                  
						//---------------------------------------------------------------
						Fa460ExcSef(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO)
					EndIf
				
					//---------------------------------------------------------------
					// Baixar titulos de abatimento se for baixa total				
					//---------------------------------------------------------------
					If nSaldoE1 == 0 .and. ( oSubFO1:GetValue("FO1_VLABT") > 0 .OR. (SE1->(E1_PIS+E1_COFINS+E1_CSLL+E1_INSS+E1_IRRF+E1_ISS) > 0) )
						dbSelectArea("SE1")
						SE1->(dbSetOrder(2))
						SE1->(MsSeek( Left(cSE1Chv2, Len(cSE1Chv2)-3 ))) 	// Filial+Cliente+Loja+Prefixo+Num+Parcela
						
						If lTitpaiSE1
							If (nOrdTitPai:= OrdTitpai()) > 0
								DbSetOrder(nOrdTitPai)
								
								If	DbSeek(xFilial("SE1",SE1->E1_FILORIG)+cTitPai)
									bWhile  := {|| !Eof() .And. Alltrim(SE1->E1_TITPAI) == Alltrim(cTitPai)}  
								Else
									dbSetOrder(2)
									SE1->(MsSeek(LEFT(cSE1Chv2,LEN(cSE1Chv2)-3))) 	// Filial+Cliente+Loja+Prefixo+Num+Parcela   
								EndIf
							EndIf
						EndIf
						
						While Eval(bWhile)
						
							IF E1_TIPO $ MVABATIM
								RecLock("SE1")
								Replace E1_SALDO	With 0
								Replace E1_BAIXA	With Iif(dDataBase>=E1_BAIXA,dDataBase,E1_BAIXA)
								Replace E1_MOVIMEN  With dDataBase
								Replace E1_STATUS   With "B"
								MsUnlock()
							EndIF
							//---------------------------------------------------------------------------------------------
							// Carrega variavies para contabilizacao dos abatimentos (impostos da lei 10925). 			
							//---------------------------------------------------------------------------------------------
							If E1_TIPO == MVPIABT
								VALOR5 := E1_VALOR			
							ElseIf E1_TIPO == MVCFABT
								VALOR6 := E1_VALOR
							ElseIf E1_TIPO == MVCSABT
								VALOR7 := E1_VALOR						
							Endif		
							
							If lAtuSldNat // SUBTRAIR OS VALORES DOS IMPOSTOS
								If SE1->E1_TIPO $ MVABATIM
									If lSE1Comp
										AtuSldNat(SE1->E1_NATUREZ, SE1->E1_VENCREA, SE1->E1_MOEDA, "2", "R", SE1->E1_VALOR, SE1->E1_VLCRUZ, "+",,FunName(),"SE1", SE1->(Recno()),0 , ,0, SE1->E1_FILORIG)
									Else
										AtuSldNat(SE1->E1_NATUREZ, SE1->E1_VENCREA, SE1->E1_MOEDA, "2", "R", SE1->E1_VALOR, SE1->E1_VLCRUZ, "+",,FunName(),"SE1", SE1->(Recno()),0 , ,0, SE1->E1_FILIAL)
									Endif
								Endif	
							Endif
					
							dbSkip()
						EndDO
					Endif
					dbSelectArea("SE1")
					SE1->(DbSetOrder(1))
					dbGoto(nSE1Rec)

					If cPaisLoc == "BRA"
						cChaveTit := xFilial("SE1",SE1->E1_FILORIG) + "|" + SE1->E1_PREFIXO + "|" +;
										SE1->E1_NUM	+ "|" + SE1->E1_PARCELA + "|" +;
										SE1->E1_TIPO + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
						cChaveFK7 := FINGRVFK7("SE1",cChaveTit,SE1->E1_FILORIG)
						
						/*
						Verifica se titulo esta no PIX e retira */
						If __lPIXCanc
							If !PIXCancel(xFilial("SE1", SE1->E1_FILORIG), cChaveFK7)
								lRet := .F.
								RollBackDelTran()
								Exit
							EndIf
						EndIf
					EndIf

					//PCREQ-9881 Instrução de Cobrança.
					If MV_PAR04 == 2 .and. !lOpcAuto	//Todos (exceto quando for rotina automática) 
						FxBInsCob(/**/,'1|2')
					EndIf
					//---------------------------------------------------------------------------------------------
					// Caso tenha processado todos os titulos marcados e exista residuo 
					// (valor dos cheques > valor dos titulos)
					// Grava-se uma NCC para o Cliente        
					//---------------------------------------------------------------------------------------------			
					If __lF460GNCC
						lGeraNCC := ExecBlock("F460GerNCC",.F.,.F.)
					Endif
					
					If Round(nTotNcc,2) > 0  .AND. Empty(cNumRa) .AND. lGeraNCC .AND. (nTitBxd == 0 .Or. oSubFO1:GetValue("FO1_MARK"))
						//Metricas - Gravados
						nGravados += 1	

						A460VerPc( 1, .T., oSubFO0:GetValue("FO0_NUMLIQ") )
						RecLock("SE1",.T.)
							Replace E1_FILIAL	With xFilial("SE1")
							Replace E1_PREFIXO	With "LIQ"
							Replace E1_NUM		With oSubFO0:GetValue("FO0_NUMLIQ")
							Replace E1_PARCELA	With cParc460
							Replace E1_TIPO		With MV_CRNEG
							Replace E1_EMISSAO	With dDataBase
							Replace E1_VENCTO	With dDataBase
							Replace E1_VENCREA	With DataValida(dDataBase)
							Replace E1_SALDO	With nTotNcc
							Replace E1_VALOR	With nTotNcc
							Replace E1_VLCRUZ	With Round(NoRound(xMoeda(nTotNcc,oSubFO0:GetValue("FO0_MOEDA"),1,,3),3),2)
							Replace E1_MOEDA	With oSubFO0:GetValue("FO0_MOEDA")
							Replace E1_CLIENTE	With oSubFO0:GetValue("FO0_CLIENT")
							Replace E1_LOJA		With oSubFO0:GetValue("FO0_LOJA")
							Replace E1_NOMCLI	With Posicione("SA1",1,xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA, "A1_NOME")
							Replace E1_NUMLIQ	With oSubFO0:GetValue("FO0_NUMLIQ")
							Replace E1_STATUS	With "A"
							Replace E1_SITUACA	With "0"
							Replace E1_VENCORI	With dDataBase
							Replace E1_EMIS1	With dDataBase
							Replace E1_NATUREZ	With oSubFO0:GetValue("FO0_NATURE")
							Replace E1_FILORIG	With Iif(Empty(oSubFO1:GetValue("FO1_FILIAL")),cFilAnt,oSubFO1:GetValue("FO1_FILIAL"))
							Replace E1_ORIGEM	With "FINA460"
							Replace E1_MULTNAT	With "2"
		
							//Integracao Protheus x Classis
							If lRmClass
								SE1->E1_NUMRA 	:= cNumRa
								SE1->E1_IDAPLIC := nIdAplic
								SE1->E1_TURMA := cTurma
							Endif
					
						SE1->(MsUnLock())
						
						If __lF460NCC
							ExecBlock("F460NCC",.F.,.F.,{nSE1Rec})
						Endif
		
						//Rastreamento - Geradores
						If lRastro
							aadd(aRastroOri,{	SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,;
											SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_VALLIQ } )
						Endif			
		
						If mv_par01 == 1
						
							lPadrao	:= VerPadrao("500")		//Emissão de Contas a Receber
							If !lHeadProva .and. lPadrao .and. mv_par01 == 1
						
								nHdlPrv 	:= HeadProva( cLote, "FINA460", Substr( cUsuario, 7, 6 ), @cArquivo )
								lHeadProva 	:= .T.
							EndIf
							If lPadrao
								nTotal += DetProva( nHdlPrv, "500", "FINA460", cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/,;
													/*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
								If UsaSeqCor()
									AADD(aDiario,{"SE1",SE1->(recno()),cCodDiario,"E1_NODIA","E1_DIACTB"}) 
								endif
							EndIf
						
							If nTotal > 0 .AND. !lUsaFlag .OR.(SE1->E1_TIPO $ MV_CRNEG)
								RecLock("SE1")
									SE1->E1_LA := "S"
								SE1->(MsUnlock())
							Endif					
						Endif	
						dbGoto(nSE1Rec)
						lGeraNCC := .F.
						nTotParc := 0
						nTotNcc  := 0
					Endif
				EndIf
		
				//---------------------------------------------------------------------------------------------
				// Atualiza o Cadastro de Clientes 					
				//---------------------------------------------------------------------------------------------
				aAdd(aSalDup,{nSE1Rec, nValPadrao})			
			
				DbSelectArea("SE1")
				SE1->(DbSetOrder(1))		
				SE1->(DbGoto(nSE1Rec))
			
				//Tratamento de gravação de filial do processo ou do titulo nas baixas
				lContabiliza := Iif(mv_par01 == 1 .and. !lFilLiq,.T.,.F.)
			
				//---------------------------------------------------------------------------------------------
				// PONTO DE ENTRADA F460SE1                                      
				// Neste ponto de entrada dever  se retornar um array com os da- 
				// dos de campo e conte£do  com dados dos titulos geradores a    
				// serem gravados de forma complementar nos titulos gerados ap¢s 
				// a liquidacao.  									              
				//----------------------------------------------------------------------	
				If __lf460SE1
					aComplem :=	ExecBlock("F460SE1",.f.,.f.,aComplem)
				EndIf
		
				//----------------------------------------------------------------------
				// Verifica se a contabilização ser  feita neste momento
				// Este programa utiliza os proprios lancamentos padronizados da emissão 
				// e baixa de titulos a receber     
				// 521 em diante, dependendo da carteira               
				// 500 (Emissão de Titulos a Receber)                  
				//----------------------------------------------------------------------
				cPadrao := fa070pad()
				lPadrao:= VerPadrao(cPadrao)	
				
				// Localiza a sequencia da baixa  								
				cSequencia := FaNxtSeqBx("SE1", .T. , @__oQryFk1 , , @__oQryFk5 , .T.)
		
				If lFilLiq
					cFilAnt := SE1->E1_FILORIG
				Endif
				
				If nCountFO1 == 1
					cCCusFO1 := oSubFO1:GetValue("FO1_CCUST")
					cItemCta := oSubFO1:GetValue("FO1_ITEMCT")
					cCLVL    := oSubFO1:GetValue("FO1_CLVL")
					cCredit	 := oSubFO1:GetValue("FO1_CREDIT")
					cDebito	 := oSubFO1:GetValue("FO1_DEBITO")
					cCcc	 := oSubFO1:GetValue("FO1_CCC")
					cCcd	 := oSubFO1:GetValue("FO1_CCD")
					cItemC	 := oSubFO1:GetValue("FO1_ITEMC")
					cItemD	 := oSubFO1:GetValue("FO1_ITEMD")
					cClvlCr	 := oSubFO1:GetValue("FO1_CLVLCR")
					cClvlDb	 := oSubFO1:GetValue("FO1_CLVLDB")
				Else 
					If cCCusFO1 <> oSubFO1:GetValue("FO1_CCUST")
						cCCusFO1 := ""
					Endif
					If cItemCta <> oSubFO1:GetValue("FO1_ITEMCT")
						cItemCta := ""
					Endif
					If cCLVL <> oSubFO1:GetValue("FO1_CLVL")
						cCLVL := ""
					Endif
					If cCredit <> oSubFO1:GetValue("FO1_CREDIT")
						cCredit := ""
					Endif
					If cDebito <> oSubFO1:GetValue("FO1_DEBITO")
						cDebito := " "
					Endif
					If cCcc	 <> oSubFO1:GetValue("FO1_CCC")
						cCcc	:= ""
					Endif
					If cCcd	 <> oSubFO1:GetValue("FO1_CCD")
						cCcd 	:= ""
					Endif
					If cItemC <> oSubFO1:GetValue("FO1_ITEMC")
						cItemC	:= ""
					Endif
					If cItemD <> oSubFO1:GetValue("FO1_ITEMD")
						cItemD	:= ""
					Endif
					If cClvlCr <> oSubFO1:GetValue("FO1_CLVLCR")
						cClvlCr	:= ""
					Endif
					If cClvlDb <> oSubFO1:GetValue("FO1_CLVLDB")
						cClvlDb	:= ""
					Endif
				Endif
		
				//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
				cCamposE5 += "{{'E5_DTDIGIT', dDataBase}"
				cCamposE5 += ",{'E5_TIPO', SE1->E1_TIPO}"                            
				cCamposE5 += ",{'E5_PREFIXO', SE1->E1_PREFIXO}"
				cCamposE5 += ",{'E5_NUMERO', SE1->E1_NUM}"
				cCamposE5 += ",{'E5_PARCELA', SE1->E1_PARCELA}"
				cCamposE5 += ",{'E5_CLIFOR', SE1->E1_CLIENTE}"
				cCamposE5 += ",{'E5_CLIENTE', SE1->E1_CLIENTE}"
				cCamposE5 += ",{'E5_LOJA', SE1->E1_LOJA}"                            
				cCamposE5 += ",{'E5_BENEF', SE1->E1_NOMCLI}"
				cCamposE5 += ",{'E5_DTDISPO', dDataBase}"
				
				cCamposE5 += ",{'E5_DEBITO' , cDebito  }"
				cCamposE5 += ",{'E5_CREDITO', cCredit  }"
				cCamposE5 += ",{'E5_CCD'    , cCcd     }"
				cCamposE5 += ",{'E5_CCC'    , cCcc     }"
				cCamposE5 += ",{'E5_ITEMD'  , cItemD   }"
				cCamposE5 += ",{'E5_ITEMC'  , cItemC   }"
				cCamposE5 += ",{'E5_CLVLDB' , cClvlDb  }"
				cCamposE5 += ",{'E5_CLVLCR' , cClvlCr  }"
				cCamposE5 += ",{'E5_CCUSTO' , cCCusFO1 }"
				
				cCamposE5 += ",{'E5_VLJUROS'," + Str(Round(NoRound(xMoeda(nSE1Jur,oSubFO0:GetValue("FO0_MOEDA"),1,,3),3),2)) +"}"
				cCamposE5 += ",{'E5_VLDESCO'," + Str(Round(NoRound(xMoeda(nSE1Des,oSubFO0:GetValue("FO0_MOEDA"),1,,3),3),2)) +"}"
				cCamposE5 += ",{'E5_VLCORRE'," + Str(Round(NoRound(nCm,3),2)) +"}"
				cCamposE5 += ",{'E5_VLMULTA'," + Str(Round(NoRound(xMoeda(nSE1Multa,oSubFO0:GetValue("FO0_MOEDA"),1,,3),3),2)) +"}"
			
				If lAcreDecre
					cCamposE5 += ",{'E5_VLACRES'," + Str(Round(NoRound(xMoeda(oSubFO1:GetValue("FO1_ACRESC"),oSubFO0:GetValue("FO0_MOEDA"),1,,3),3),2)) +"}"
					cCamposE5 += ",{'E5_VLDECRE'," + Str(Round(NoRound(xMoeda(oSubFO1:GetValue("FO1_DECRES"),oSubFO0:GetValue("FO0_MOEDA"),1,,3),3),2)) +"}"
				EndIf
		
				cCamposE5 += "}"
		
				If oSubFO0:GetValue("FO0_MOEDA") == SE1->E1_MOEDA
					If ((xMoeda(nValorBX,oSubFO0:GetValue("FO0_MOEDA"),SE1->E1_MOEDA,,3)) - nSaldoBx) > 0.01
						nSaldoBX := nValorBX
					EndIf
				EndIf

				oModelBxR:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
				oModelBxR:Activate()	
				oModelBxR:SetValue( "MASTER", "E5_GRV", .T. ) //Informa se vai gravar SE5 ou não
				oModelBxR:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK5
				oModelBxR:SetValue( "MASTER", "NOVOPROC", .T. ) //Informa que a inclusão será feita com um novo número de processo
				
				oSubFK1	:= oModelBxR:GetModel("FK1DETAIL")
				oSubFK6	:= oModelBxR:GetModel("FK6DETAIL")
				
				cChaveTit	:= xFilial("SE1",SE1->E1_FILORIG) + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
				cChaveFK7	:= FINGRVFK7("SE1", cChaveTit, SE1->E1_FILORIG)
				cChaveFk1	:= FWUUIDV4()
				
				//Dados do Processo - Define a chave da FK5 no IDORIG
				oFKA := oModelBxR:GetModel("FKADETAIL")
			
				If !oFKA:IsEmpty()
					oFKA:AddLine()
				Endif
			
				oFKA:SetValue( "FKA_IDORIG", cChaveFk1 )
				oFKA:SetValue( "FKA_TABORI", "FK1" )

				If oSubFO1:GetValue("FO1_MOEDA") == 1 .And. oSubFO0:GetValue("FO0_MOEDA") != 1
					nTxMoeDia := Iif( oSubFO0:GetValue("FO0_TXMOED") > 0,oSubFO0:GetValue("FO0_TXMOED"),RecMoeda(dDataBase, oSubFO0:GetValue("FO0_MOEDA") ))
				Else
					nTxMoeDia := Iif( oSubFO1:GetValue("FO1_TXMOED") > 0,oSubFO1:GetValue("FO1_TXMOED"),RecMoeda(dDataBase, oSubFO1:GetValue("FO1_MOEDA") ))
				EndIf	
				//Dados da baixa a receber
				oSubFK1:SetValue("FK1_RECPAG","R")
				oSubFK1:SetValue("FK1_HISTOR",(STR0037))//"Valor Baixado p/Liquidação"
				oSubFK1:SetValue("FK1_DATA",dDataBase)
				oSubFK1:SetValue("FK1_TPDOC","BA")
				oSubFK1:SetValue("FK1_MOTBX","LIQ")
				oSubFK1:SetValue("FK1_SEQ",cSequencia)
				oSubFK1:SetValue("FK1_CCUSTO",cCCusFO1)

				/*----------------------------------------------------------------------------------------------------------- 
					Regra de Gravação - Processo que não depende de Banco
					FK1_MOEDA	- Grava a moeda do título.
					FK1_VALOR	- Grava o valor do movimento na moeda do título.
					FK1_VLMOE2	- Grava a conversão do valor de movimento (E5_VALOR) para a moeda corrente quando o título está em moeda estrangeira, ou
									a conversão para a moeda do processo quando o título está em moeda corrente.
					FK1_TXMOED	- Grava a taxa de movimento usada para efetivação de um processo. Essa taxa pode ser a que estiver pré-fixada no título,
									a do cadastro de moedas ou ainda uma taxa informada no momento que estiver realizando um processo.
				-----------------------------------------------------------------------------------------------------------*/
				nMoedaProc	:= oSubFO0:GetValue("FO0_MOEDA")
				nMoedaTit	:= oSubFO1:GetValue("FO1_MOEDA")
				nMoeda		:= nMoedaProc

				oSubFK1:SetValue("FK1_VALOR",nSaldoBX)
				
				If nMoedaProc == 1 .And. nMoedaTit == 1	//Real x Real
					oSubFK1:SetValue("FK1_VLMOE2",nSaldoBX)
				Else
					If nMoedaTit == 1	//Titulo em moeda corrente ==> converte para moeda do processo
						oSubFK1:SetValue("FK1_VLMOE2",Round(NoRound(xMoeda(nSaldoBx,1,nMoedaProc,dDataBase,3,1,nTxMoeDia),3),2))
					Else				//Titulo em moeda estrangeira ==> converte para moeda corrente	
						oSubFK1:SetValue("FK1_VLMOE2",Round(NoRound(xMoeda(nSaldoBx,nMoedaTit,1,dDataBase,,nTxMoeDia),3),2))
					EndIf
				EndIf
				
				oSubFK1:SetValue("FK1_DOC",oSubFO0:GetValue("FO0_NUMLIQ"))
				oSubFK1:SetValue("FK1_NATURE",oSubFO1:GetValue("FO1_NATURE"))
				oSubFK1:SetValue("FK1_FILORI",oSubFO1:GetValue("FO1_FILORI"))
				oSubFK1:SetValue("FK1_SITCOB",SE1->E1_SITUACA)
				oSubFK1:SetValue("FK1_MOEDA",StrZero(nMoedaTit, TamSX3("FK1_MOEDA")[1]))
				oSubFK1:SetValue("FK1_TXMOED",nTxMoeDia)
				oSubFK1:SetValue("FK1_LA",IIf(lContabiliza .And. lPadrao,'S',''))
				oSubFK1:SetValue("FK1_IDDOC",cChaveFK7)
				oSubFK1:SetValue("FK1_VENCTO",SE1->E1_VENCTO)
				oSubFK1:SetValue("FK1_ORIGEM","FINA460")

				For i := 1 To 5
					//----------------------------------------------------------------------
					// Atualiza a Movimentação Banc ria	   				         
					//----------------------------------------------------------------------
					If i == 1
						//Descontos + Descrescimo (o valor de decrescimo e desconto ja vem somado)
						cTpDoc  :="DC"
						cHistMov:= (STR0038) //"Desconto s/Receb.Titulo"
						nValOp := Round(NoRound(nSE1Des,3),2)
					ElseIf i == 2
						//Juros + Acrescimo
						cTpDoc  := "JR"
						cHistMov:= (STR0039) //"Juros s/Receb.Titulo"
						nValOp := Round(NoRound(oSubFO1:GetValue("FO1_VLJUR") + oSubFO1:GetValue("FO1_ACRESC"),3),2)
					ElseIf i == 3
						//Correcao monetaria
						cTpDoc  := "CM"
						cHistMov:= (STR0040) //"Correcao Monet s/Receb.Titulo"
						nValOp := Round(NoRound(nCm,3),2)
					ElseIf i == 4
						//Multa do loja
						cTpDoc  := "MT"
						cHistMov:= (STR0105) //"Multa s/Receb.Titulo"
						nValOp := Round(NoRound(oSubFO1:GetValue("FO1_VLMUL"),3),2)
					Elseif i == 5 
						//Valores Acessorios
						cTpDoc	 := "VA"
						cHistMov := ""		//Valores Acessórios (histórico virá da FKD)
						nValOp	 := 0		//Valores acessórios serão tratados pela rotina abaixo
						//Grava Novos Valores Acessorios (FKD)
						FSetFK6FKD(oSubFK6,cChaveFK7,cChaveFk1,"R")
					EndIf
					
					If nValOp != 0
						If !oSubFK6:IsEmpty()
							//Inclui a quantidade de linhas necessárias
							oSubFK6:AddLine()	
							//Vai para linha criada
							oSubFK6:GoLine( oSubFK6:Length() )	
						EndIf
					
						oSubFK6:SetValue( "FK6_FILIAL"	, FWxFilial("FK6") )
						oSubFK6:SetValue( 'FK6_IDFK6'	, GetSxEnum('FK6','FK6_IDFK6') )
						oSubFK6:SetValue( 'FK6_TABORI'	, 'FK1' )
						oSubFK6:SetValue( 'FK6_TPDOC'	, cTpDoc )
						oSubFK6:SetValue( 'FK6_VALCAL'	, nValOp )  
						oSubFK6:SetValue( 'FK6_VALMOV'	, nValOp  )
						oSubFK6:SetValue( 'FK6_RECPAG'	, "R" )
						oSubFK6:SetValue( 'FK6_HISTOR'	, cHistMov )
						oSubFK6:SetValue( 'FK6_IDORIG'	, cChaveFk1 )	
					Endif				
					
					If UsaSeqCor()
						AADD(aDiario,{"SE5",SE5->(recno()),cCodDiario,"E5_NODIA","E5_DIACTB"})
					endif

				Next i
				
				If oModelBxR:VldData()
					oModelBxR:CommitData()
							
					nRecSE5 := oModelBxR:GetValue("MASTER","E5_RECNO")
					SE5->(dbGoTo(nRecSE5))
						
					If __lTpComis .and. __lComiLiq
				
						If ! SE1->E1_TIPO $ MV_CRNEG .And. ! SE1->E1_TIPO $ MV_CPNEG
							aadd(aBaixas,{SE5->E5_MOTBX,SE5->E5_SEQ,SE5->(Recno())})
							Fa440CalcB(aBaixas,.F.,.F.,"FINA460","+",,,.T.,SE1->(Recno()) )
							aBaixas		:= {}
						Endif				

					Endif				

					//----------------------------------------------------------------------
					// PONTO DE ENTRADA			                  
					//----------------------------------------------------------------------
					If __lSE5F460
						ExecBlock('SE5FI460',.f.,.F.)
					Endif

					If lUsaFlag .And. lContabiliza .And. lPadrao // Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
					EndIf
				
					oModelBxR:DeActivate()
					cCamposE5 := ''
				Else
					cLog := cValToChar(oModelBxR:GetErrorMessage()[4]) + ' - '
					cLog += cValToChar(oModelBxR:GetErrorMessage()[5]) + ' - '
					cLog += cValToChar(oModelBxR:GetErrorMessage()[6])               
					Help( ,,"M010VALID",,cLog, 1, 0 )              
				EndIf

				//Implementação para geração de Variação Monetaria - Se o titulo liquidado é da mesma moeda do titulo a ser gerado
				If __nOpcOuMo = 3 .And. oSubFO1:GetValue("FO1_MOEDA") > 1 .And. oSubFO0:GetValue("FO0_MOEDA") = oSubFO1:GetValue("FO1_MOEDA") .And. nRecSE5 > 0
					F460GerVM( nSE1Rec,nRecSE5,oSubFO1:GetValue("FO1_TXMOED"),oSubFO0:GetValue("FO0_NUMLIQ"),oSubFO1:GetValue("FO1_MOEDA") )
				EndIf

				// Contabiliza On Line
				If lContabiliza
				
					cAliasAnt := Alias()
				
					DbSelectArea("SA1")
					SA1->( DbSetOrder(1) )
					SA1->( MsSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA ) )
				
					dbSelectArea(cAliasAnt)
				
					If !lHeadProva .and. lPadrao
						nHdlPrv := HeadProva( cLote, "FINA460", Substr( cUsuario, 7, 6 ), @cArquivo )
						lHeadProva := .T.
					EndIf
				
					If lPadrao
						nTotal += DetProva( nHdlPrv, cPadrao, "FINA460", cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/,;
						/*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
					EndIf
				EndIf
			
				MsUnlock()
				
				aAlt := {}
				aadd( aAlt,{ (STR0044),'','','',(STR0045) + Alltrim(oSubFO0:GetValue("FO0_NUMLIQ")) })   //"LIQUIDAÇÃO CR"//"O Título foi baixado pelo processo de liquidação "

				//chamada da Função que cria o Histórico de Cobrança
				cFilOld := cFilAnt
				cFilAnt := SE1->E1_FILORIG
				FinaCONC(aAlt)
				cFilAnt	:= cFilOld
							// Integração SIGAFIN x SIGAPFS
				If lRet .And. FindFunction("JGrvBaixa")
					JGrvBaixa(nSE1Rec, nRecSE5)
					
					If lIntPFS
						cJurFat  := SE1->E1_JURFAT
						cJurHist := SE1->E1_HIST
					EndIf
				EndIf
		
			Else
				oSubFO1:SetValue("FO1_MARK",.F.)
			EndIf
				
			DbSelectArea("SE1")
			SE1->(DbSkip())
		Next nLFO1

		FWModelActive(oModel)

		//Este trecho do codigo define se as parcelas geradas tem valores para o abatimento do IR/INSS/ISS
		nTtlImpAbt 	:= aValorImp[04] + aValorImp[05] + aValorImp[06]
		nTtlPcc		:= aValorImp[01] + aValorImp[02] + aValorImp[03]

		If nTtlPcc > 0
			If !Empty(oSubFO0:GetValue("FO0_COND"))
				aParcelas := Condicao( nTtlPcc, oSubFO0:GetValue("FO0_COND"), , dDataBase )
				nTtlPcc := aParcelas[1,2] 
			Else
				nTtlPcc := Round(nTtlPcc / oSubFO2:Length(), 2)
			Endif
			
		Else
			nTtlPcc := 0
		Endif

		If nTtlImpAbt > 0
			If lRTipFin
				//Gera abatimento na 1ª parcela
				For nCntFor := 1 To oSubFO2:Length()
					oSubFO2:Goline(nCntFor)
					If !oSubFO2:IsDeleted()
						Exit
					Endif
				Next nCntFor
			Else
				//Gera abatimento na ultima parcela
				For nCntFor := oSubFO2:Length() To 1 Step -1
					oSubFO2:Goline(nCntFor)
					If !oSubFO2:IsDeleted()
						Exit
					Endif
				Next nCntFor
			Endif

			If oSubFO2:GetValue("FO2_TOTAL") < (nTtlImpAbt + nTtlPcc)
				If nTtlPcc > 0
					cTxtMsg := ""
					cTxtMsg := STR0197 + "( R$ " + Alltrim(Transform(nTtlPcc, "@E 9,999,999.99")) + " ) " + STR0198
				Else
					cTxtMsg := ""
					cTxtMsg := STR0198
				Endif
				If !lOpcAuto  
					If Aviso( STR0056 , STR0185 + Alltrim(Transform(nTtlImpAbt, "@E 9,999,999.99")) + cTxtMsg + CRLF + STR0191 + CRLF + CRLF + STR0186 + CRLF + CRLF + STR0192 + CRLF + STR0193 , { STR0032, STR0184}, 3) == 1 //"Atenção" # "Cancelar" # "Recalcular Parcelas"
						// "A somatória dos impostos de IRRF e/ou INSS e/ou ISS ( R$ "
						// ") e demais impostos incidentes, ultrapassa o valor da Parcela. O que deseja fazer?"
						// "A opção Recalcular permitirá que o sistema recalcule as parcelas baseado na condição de pagamento informada."
						// "Se o parâmetro MV_RTIPFIN estiver com ‘.T.’ o cálculo será para a primeira parcela."
						// "Se o parâmetro MV_RTIPFIN estiver com ‘.F.’ o cálculo será para a última parcela."
						
						oModel:SetErrorMessage("","","","","F460COMIMP", STR0189,"")  
						//"Necessario que o valor da parcela seja igual ou maior que a somatoria dos impostos"
						RollBackDelTran()
						Return .F.
					Else
						If Empty(oSubFO0:GetValue("FO0_COND"))
							oModel:SetErrorMessage("","","","","F460COMIMP", STR0187 + CRLF + STR0188,"") 
							//"Não existe condição de pagamento informado para calculo. Os valores das parcela deverão ser alimentados manualmente "
							//"ou informe condição de pagamento."
							RollBackDelTran()
							Return .F.
						Else
							lChkFO2 := .T.
						EndIf
					Endif
				Else
					Help(" ",1,"F460AEXECA",, STR0194, 1, 0)
					//"Valores das parcelas não correspondem com os valores necessarios para baixa dos impostos de IR/INSS/ISS"
					RollBackDelTran()
					Return .F.
				Endif

				If lChkFO2 .Or. (lOpcAuto .And. !lChkFO2)
					For nCntFor := 1 To oSubFO1:Length()
						oSubFO1:GoLine(nCntFor)
						If oSubFO1:GetValue("FO1_MARK")
							nFo1Tot	  +=	oSubFO1:GetValue("FO1_TOTAL")
							nF01VlJur +=	oSubFO1:GetValue("FO1_VLJUR")
							nQtdFil++
						Endif
					Next nCntFor

					oSubFO0:LoadValue("FO0_VLRLIQ", nFo1Tot)
					oSubFO0:LoadValue("FO0_VLRNEG", nFo1Tot)
					oSubFO0:LoadValue("FO0_VLRJUR", nF01VlJur)
					oSubFO0:LoadValue("FO0_TTLTIT", StrZero(nQtdFil,4))

					oSubFO1:GoLine(1)

					cPrefix	:= oSubFO2:GetValue("FO2_PREFIX")
					cNumLiq	:= oSubFO2:GetValue("FO2_NUM")

					oSubFO2:ClearData( .T. )

					oSubFO2:SetNoInsertLine(.F.)

					cParc2Ger := cParc2Ger + Space(nTamParc - Len(cParc2Ger))	
					aParcelas := Condicao( oSubFO0:GetValue("FO0_VLRNEG") - nTtlImpAbt, oSubFO0:GetValue("FO0_COND"), , dDataBase )

					For nCntFor := 1 To Len(aParcelas)
						If nCntFor > 1 
							oSubFO2:AddLine()
							oSubFO2:GoLine(nCntFor)
						Endif
						If nCntFor == 1 .And. lRTipFin
							oSubFO2:LoadValue("FO2_PREFIX", Alltrim(cPrefix))
							oSubFO2:LoadValue("FO2_NUM"   , Alltrim(cNumLiq))
							oSubFO2:LoadValue("FO2_TIPO"  , Alltrim(oSubFO0:GetValue("FO0_TIPO")))
							oSubFO2:LoadValue("FO2_PARCEL", cParc2Ger)
							oSubFO2:LoadValue("FO2_VENCTO", aParcelas[nCntFor,1])
							oSubFO2:LoadValue("FO2_VALOR" , aParcelas[nCntFor,2]  + nTtlImpAbt) 
							oSubFO2:LoadValue("FO2_TOTAL" , (aParcelas[nCntFor,2] + nTtlImpAbt) + oSubFO2:GetValue("FO2_VLJUR") + oSubFO2:GetValue("FO2_ACRESC") - oSubFO2:GetValue("FO2_DECRES"))
							oSubFO2:LoadValue("FO2_VLPARC", (aParcelas[nCntFor,2] + nTtlImpAbt) + oSubFO2:GetValue("FO2_VLJUR") + oSubFO2:GetValue("FO2_ACRESC") - oSubFO2:GetValue("FO2_DECRES"))
							oSubFO2:LoadValue("FO2_TXJUR" , oSubFO0:GetValue("FO0_TXJRG"))
							oSubFO2:LoadValue("FO2_IDSIM" , FWUUIDV4() )
							oSubFO2:LoadValue("FO2_PROCES", oSubFO0:GetValue("FO0_PROCES"))
							oSubFO2:LoadValue("FO2_VERSAO", oSubFO0:GetValue("FO0_VERSAO"))
						ElseIf nCntFor == Len(aParcelas) .And. !lRTipFin
							oSubFO2:LoadValue("FO2_PREFIX", Alltrim(cPrefix))
							oSubFO2:LoadValue("FO2_NUM"   , Alltrim(cNumLiq))
							oSubFO2:LoadValue("FO2_TIPO"  , Alltrim(oSubFO0:GetValue("FO0_TIPO")))
							oSubFO2:LoadValue("FO2_PARCEL", cParc2Ger)
							oSubFO2:LoadValue("FO2_VENCTO", aParcelas[nCntFor,1])
							oSubFO2:LoadValue("FO2_VALOR" , (aParcelas[nCntFor,2] + nTtlImpAbt) )
							oSubFO2:LoadValue("FO2_TOTAL" , (aParcelas[nCntFor,2] + nTtlImpAbt) + oSubFO2:GetValue("FO2_VLJUR") + oSubFO2:GetValue("FO2_ACRESC") - oSubFO2:GetValue("FO2_DECRES"))
							oSubFO2:LoadValue("FO2_VLPARC", (aParcelas[nCntFor,2] + nTtlImpAbt) + oSubFO2:GetValue("FO2_VLJUR") + oSubFO2:GetValue("FO2_ACRESC") - oSubFO2:GetValue("FO2_DECRES"))
							oSubFO2:LoadValue("FO2_TXJUR" , oSubFO0:GetValue("FO0_TXJRG"))
							oSubFO2:LoadValue("FO2_IDSIM" , FWUUIDV4() )
							oSubFO2:LoadValue("FO2_PROCES", oSubFO0:GetValue("FO0_PROCES"))
							oSubFO2:LoadValue("FO2_VERSAO", oSubFO0:GetValue("FO0_VERSAO"))								
						Else
							oSubFO2:LoadValue("FO2_PREFIX", Alltrim(cPrefix))
							oSubFO2:LoadValue("FO2_NUM"   , Alltrim(cNumLiq))
							oSubFO2:LoadValue("FO2_TIPO"  , Alltrim(oSubFO0:GetValue("FO0_TIPO")))
							oSubFO2:LoadValue("FO2_PARCEL", cParc2Ger)
							oSubFO2:LoadValue("FO2_VENCTO", aParcelas[nCntFor,1])
							oSubFO2:LoadValue("FO2_VALOR" , aParcelas[nCntFor,2] )
							oSubFO2:LoadValue("FO2_TOTAL" , aParcelas[nCntFor,2] + oSubFO2:GetValue("FO2_VLJUR") + oSubFO2:GetValue("FO2_ACRESC") - oSubFO2:GetValue("FO2_DECRES"))
							oSubFO2:LoadValue("FO2_VLPARC", aParcelas[nCntFor,2] + oSubFO2:GetValue("FO2_VLJUR") + oSubFO2:GetValue("FO2_ACRESC") - oSubFO2:GetValue("FO2_DECRES"))
							oSubFO2:LoadValue("FO2_TXJUR" , oSubFO0:GetValue("FO0_TXJRG"))
							oSubFO2:LoadValue("FO2_IDSIM" , FWUUIDV4() )
							oSubFO2:LoadValue("FO2_PROCES", oSubFO0:GetValue("FO0_PROCES"))
							oSubFO2:LoadValue("FO2_VERSAO", oSubFO0:GetValue("FO0_VERSAO"))	
						Endif
						cParc2Ger := Soma1(alltrim(cParc2Ger))
					Next nCntFor

					oSubFO2:SetNoInsertLine(.T.)
					
					If !lOpcAuto 
						oSubFO1:GoLine(1)
						oSubFO2:GoLine(1)
						oView:Refresh("VIEW_FO1")
						oView:Refresh("VIEW_FO2")
						oModel:SetErrorMessage("","","","","F460COMIMP", STR0190 ,"") 
						//"Valores das parcelas foram calculados e alterados de acordo com o total de impostos de abatimento."
					Endif
					RollBackDelTran()
					Return .F.
				Endif
			Endif
		Endif

		FWModelActive(oModelBxR)

		//----------------------------------------------------------------------
		// Criacao dos titulos gerados pela liquidacao         
		//----------------------------------------------------------------------
		
		cPadrao	:= "500"
		lPadrao	:= VerPadrao("500")		//Emissão de Contas a Receber
		nTotLiq	:= 0

		//Tratamento de gravação de filial do processo ou do titulo nas baixas
		If lFilLiq
			cFilAnt := cFilAtu
		Endif
		
		//PCC Baixa CR
		//Necessario somar o total da fatura antes da geracao da fatura
		//para proporcionalizar o valor do PCC
		If lPccBxCR .or. lBaseImp .or. lIrPjBxCr
			For nCntFor:=1 To oSubFO2:Length()//
				oSubFO2:Goline(nCntFor)
				
				nTotLiq += oSubFO2:GetValue("FO2_TOTAL")
			
			Next nCntFor
		EndIf

		__aNovosTit := {}
		
		For nCntFor := 1 To oSubFO2:Length()	//FO2
			aVaTit		:= Aclone(aVaTitGer)
			oSubFO2:Goline(nCntFor)
			
			If !oSubFO2:IsDeleted()

				//Metricas - Gravados
				nGravados += 1	

				//Alimenta de valor de juros do titulos na variavel exclusiva de contabilização
				JUROS3 := oSubFO2:GetValue("FO2_VLJUR")
				
				//IR Baixa CR
				//Tratamento da proporcionalizacao dos impostos IR
				//para posterior gravacao na parcela gerada
				If lIrPjBxCr .OR. lBaseImp
					nPropIr		:= oSubFO2:GetValue("FO2_TOTAL") / nTotLiq
					nIrrf		:= Round(NoRound(aDadosIR[1] * nPropIr,3),2)
					nBaseImp	:= Round(NoRound(aDadosIR[2] * nPropIr,3),2)
					nTotIr   	+= nIrrf
					nTotBase	:= nBaseImp
					
					//Acerto de eventuais problemas de arredondamento
					If aDadosIR[1] - nTotIr <= 0.01
						nIrrf		+= aDadosIR[1] - nTotIr
					Endif
		
					If aDadosIR[2] - nTotBase <= 0.01
						nBaseImp	+= aDadosIR[2] - nTotBase 
					Endif
				EndIf
		
				DbSelectArea("SE1")
				SE1->(DbSetOrder(1))
				
				cNumTitulo		:= oSubFO2:GetValue("FO2_NUM")
				cTipo   		:= oSubFO2:GetValue("FO2_TIPO")
				cNumFO0         := oSubFO0:GetValue("FO0_NUMLIQ")
				
				//Ajusto a origem do titulo ao do processo de liquidação.
				If Empty(cOrigem)
					cOrigem		:= oSubFO0:GetValue("FO0_ORIGEM")
					cOrigem		:= If(Empty(cOrigem), "FINA460",cOrigem)
				EndIf

				cNomeCli := Posicione("SA1",1,xFilial("SA1") + oSubFO0:GetValue("FO0_CLIENT") + oSubFO0:GetValue("FO0_LOJA"), "A1_NOME")
				aTit := {}
				AADD(aTit , {"E1_FILIAL"	, xFilial("SE1")					, NIL})						
				AADD(aTit , {"E1_PREFIXO"	, oSubFO2:GetValue("FO2_PREFIX")	, NIL})
				AADD(aTit , {"E1_NUM"    	, cNumTitulo						, NIL})
				AADD(aTit , {"E1_PARCELA"	, oSubFO2:GetValue("FO2_PARCEL")	, NIL})
				AADD(aTit , {"E1_TIPO"		, oSubFO2:GetValue("FO2_TIPO")		, NIL})
				AADD(aTit , {"E1_NATUREZ"	, oSubFO0:GetValue("FO0_NATURE")	, NIL})
				AADD(aTit , {"E1_SITUACA"	, "0"								, NIL})
				
				If lFini460
					aAdd( aTit , {"E1_EMISSAO"	, oSubFO2:GetValue("FO2_EMISSAO")	, NIL})
				Else
					aAdd( aTit , {"E1_EMISSAO"	, dDataBase		, NIL})
				EndIf
				
				AADD(aTit , {"E1_VENCTO"	, oSubFO2:GetValue("FO2_VENCTO")	, NIL})
				AADD(aTit , {"E1_VENCREA"	, DataValida(oSubFO2:GetValue("FO2_VENCTO"),.T.)	, NIL})
				AADD(aTit , {"E1_VENCORI"	, oSubFO2:GetValue("FO2_VENCTO")	, NIL})
				AADD(aTit , {"E1_EMIS1"		, dDataBase							, NIL})
				AADD(aTit , {"E1_CLIENTE"	, oSubFO0:GetValue("FO0_CLIENT")	, NIL})
				AADD(aTit , {"E1_LOJA"		, oSubFO0:GetValue("FO0_LOJA")		, NIL})
				AADD(aTit , {"E1_NOMCLI"	, cNomeCli							, NIL})
				AADD(aTit , {"E1_MOEDA"		, oSubFO0:GetValue("FO0_MOEDA")		, NIL})
				AADD(aTit , {"E1_VALOR"		, oSubFO2:GetValue("FO2_VLPARC")	, NIL})
				AADD(aTit , {"E1_SALDO"		, oSubFO2:GetValue("FO2_VLPARC")	, NIL})

				If lCpoTxMoed .And. __nOpcOuMo = 3
					If lE1TxFixa
						AADD(aTit , {"E1_TXMOEDA" , nTxMoeFO0 , NIL})
						AADD(aTit , {"E1_VLCRUZ" , oSubFO2:GetValue("FO2_VLPARC") * nTxMoeFO0 , NIL})
					Else
						AADD(aTit , {"E1_VLCRUZ" , oSubFO2:GetValue("FO2_VLPARC") * nTxMoeFO0 , NIL})				
					EndIf
				Else
					AADD(aTit , {"E1_VLCRUZ" , xMoeda(oSubFO2:GetValue("FO2_VLPARC"), oSubFO0:GetValue("FO0_MOEDA"), 1, dDataBase)	, NIL})
				EndIf

				AADD(aTit , {"E1_STATUS"	,"A"								, NIL})
				AADD(aTit , {"E1_FLUXO"		,"S"								, NIL})
				AADD(aTit , {"E1_OCORREN"	,"01"								, NIL})
				AADD(aTit , {"E1_ORIGEM"	,cOrigem							, NIL})
				AADD(aTit , {"E1_NUMLIQ"	,cNumFO0							, NIL})
				AADD(aTit , {"E1_FILORIG"	,cFilAnt							, NIL})
				AADD(aTit , {"E1_EMITCHQ"	,oSubFO2:GetValue("FO2_EMITEN")		, NIL})
				AADD(aTit , {"E1_ACRESC"	,oSubFO2:GetValue("FO2_ACRESC")		, NIL})		// acrescimo
				AADD(aTit , {"E1_DECRESC"	,oSubFO2:GetValue("FO2_DECRES")		, NIL})		// decrescimo
				AADD(aTit , {"E1_SDACRES"	,oSubFO2:GetValue("FO2_ACRESC")		, NIL})		// acrescimo
				AADD(aTit , {"E1_SDDECRE"	,oSubFO2:GetValue("FO2_DECRES")		, NIL})		// decrescimo
				AADD(aTit , {"E1_MULTNAT"	,"2"								, NIL})	
				
				AADD(aTit , {"E1_CCUSTO"	,cCCusFO1							, NIL})     // Centro de Custo
				AADD(aTit , {"E1_ITEMCTA"	,cItemCta							, NIL})		// Item da Conta
				AADD(aTit , {"E1_CLVL"	    ,cCLVL								, NIL})		// Classe de Valor
				AADD(aTit , {"E1_CREDIT"	,cCredit							, NIL})		// Conta Credito
				AADD(aTit , {"E1_DEBITO"	,cDebito							, NIL})		// Conta Debito
				AADD(aTit , {"E1_CCC"		,cCcc								, NIL})		// Conta Debito
				AADD(aTit , {"E1_CCD"		,cCcd								, NIL})		// Conta Debito
				AADD(aTit , {"E1_ITEMC"		,cItemC								, NIL})		// Conta Debito
				AADD(aTit , {"E1_ITEMD"		,cItemD								, NIL})		// Conta Debito
				AADD(aTit , {"E1_CLVLCR"	,cClvlCr							, NIL})		// Conta Debito
				AADD(aTit , {"E1_CLVLDB"	,cClvlDb							, NIL})		// Conta Debito
				
					
				AAdd( __aNovosTit, {oSubFO2:GetValue("FO2_PREFIX"), oSubFO2:GetValue("FO2_NUM"), oSubFO2:GetValue("FO2_PARCEL"), oSubFO2:GetValue("FO2_TIPO")} )
		
				AADD(aTit , {"E1_BCOCHQ"	,oSubFO2:GetValue("FO2_BANCO")		, NIL})
				AADD(aTit , {"E1_AGECHQ"	,oSubFO2:GetValue("FO2_AGENCI")		, NIL})
				AADD(aTit , {"E1_CTACHQ"	,oSubFO2:GetValue("FO2_CONTA")		, NIL})
				AADD(aTit , {"E1_PORCJUR"   ,oSubFO2:GetValue("FO2_TXJUR")		, NIL})


				aAdd(__aRelNovos, {	xFilial("SE1")										,;	//01-Filial 
										cNumTitulo										,;	//02-Nro do Titulo
										oSubFO2:GetValue("FO2_PREFIX")					,;	//03-Prefixo
										oSubFO2:GetValue("FO2_PARCEL")					,;	//04-Parcela
										oSubFO2:GetValue("FO2_TIPO")		 			,;	//05-Tipo
										oSubFO0:GetValue("FO0_CLIENT")					,;	//06-Cliente
										oSubFO0:GetValue("FO0_LOJA")					,;	//07-Loja
										Dtos(dDatabase)									,;	//08-Emissao
										Dtos(DataValida(oSubFO2:GetValue("FO2_VENCTO"),.T.))				,;	//09-Vencimento
										xMoeda(oSubFO2:GetValue("FO2_VLPARC"), oSubFO0:GetValue("FO0_MOEDA"), 1, dDataBase)			,;	//10-Valor Original
										oSubFO2:GetValue("FO2_VLPARC")					,;	//11-Saldo
										0												,;	//12-Multa
										0												,;	//13-Juros
										0												,;	//14-Desconto
										oSubFO2:GetValue("FO2_VLPARC")					,;	//15-Valor Recebido
										oSubFO2:GetValue("FO2_NUMCH")					,;	//16-Numero do cheque
										oSubFO2:GetValue("FO2_BANCO") 					,;	//17-Banco
										oSubFO2:GetValue("FO2_AGENCI") 					,;	//18-Agencia
										oSubFO2:GetValue("FO2_CONTA") 					,;	//19-Conta
										oSubFO2:GetValue("FO2_NUMCH") 					,;	//20-nro. do cheque
										oSubFO2:GetValue("FO2_VALOR") 					})	//21-valor do cheque			


				If lIntPFS
					If !AliasInDic("OHT")
						AADD(aTit , {"E1_JURFAT", cJurFat , NIL})
					EndIf
					AADD(aTit , {"E1_HIST"  , cJurHist, NIL})
					AADD(aTit , {"E1_BOLETO", "1"     , NIL})
					cBanco   := oSubFO2:GetValue("FO2_BANCO")
					cAgencia := oSubFO2:GetValue("FO2_AGENCI")
					cConta   := oSubFO2:GetValue("FO2_CONTA")
				EndIf
				
				If lFini460
					aAdd( aTit , {'E1_CONTRAT'	, oSubFO2:GetValue("FO2_CONTRACT")	, Nil})
					aAdd( aTit , {'E1_PORTADO'	, oSubFO2:GetValue("FO2_HOLDER")	, Nil})
					aAdd( aTit , {'E1_AGEDEP'	, oSubFO2:GetValue("FO2_AGENCY")	, Nil})
					aAdd( aTit , {'E1_CONTA'	, oSubFO2:GetValue("FO2_ACCOUNT")	, Nil})
				Else
					aAdd( aTit , {'E1_CONTRAT'	, cContrato		, Nil})
					aAdd( aTit , {'E1_PORTADO'	, cBanco 		, Nil})
					aAdd( aTit , {'E1_AGEDEP'	, cAgencia		, Nil})
					aAdd( aTit , {'E1_CONTA'	, cConta		, Nil})
				EndIf
				
				//To Do - Ver com Berto	
				If lRmClass //Integracao Protheus X RM Classis Net (RM Sistemas)
					aAdd( aTit , {'E1_NUMRA'	, cNumRA		, Nil})
					aAdd( aTit , {'E1_IDAPLIC'	, nIDAPLIC		, Nil})
					aAdd( aTit , {'E1_TURMA'	, cTurma		, Nil})
					aAdd( aTit , {'E1_PERLET'	, cPeriodoLet	, Nil})
					aAdd( aTit , {'E1_PRODUTO'	, cProdClass	, Nil})
					aAdd( aTit , {'E1_IDLAN'	, nIdLan		, Nil})
				EndIf
				
				If lIrPjBxCr
					If "IRRF" $ cIrBxCr .and. nIrrf > 0
						AADD(aTit , {"E1_IRRF"   ,  nIrrf			, NIL})
					EndIf
				ElseIf lMata460
					AADD(aTit , {"E1_IRRF"   ,  nIrrf				, NIL})			
				EndIf
		
				//639.04 Base Impostos diferenciada
				If lBaseImp .and. aDadosIR[2] > 0
					AADD(aTit , {"E1_BASEIRF"  ,  ABS(nBaseImp) 	, NIL})
				EndIf

				nPropImp := oSubFO2:GetValue("FO2_TOTAL") / nTotLiq

				//Cálculo diferenciado dos impostos - MV_RTIPFIN
				If lRTipFin
					If nCntFor == 1
						aAdd(aTit, {'E1_IRRF'	, aValorImp[04]	, Nil})
						aAdd(aTit, {'E1_INSS'	, aValorImp[05]	, Nil})
						aAdd(aTit, {'E1_ISS'	, aValorImp[06]	, Nil})
						
						aAdd(aTit, {'E1_BASEIRF', aBaseImp[04]	, Nil})
						aAdd(aTit, {'E1_BASEINS', aBaseImp[05]	, Nil})
						aAdd(aTit, {'E1_BASEISS', aBaseImp[06]	, Nil})
					Else
						aAdd(aTit, {'E1_IRRF'	, 0, Nil})
						aAdd(aTit, {'E1_ISS'	, 0, Nil})
						aAdd(aTit, {'E1_INSS'	, 0, Nil})
						aAdd(aTit, {'E1_BASEIRF', 0, Nil})
						aAdd(aTit, {'E1_BASEINS', 0, Nil})
						aAdd(aTit, {'E1_BASEISS', 0, Nil})
					EndIf
				Else
					// [4]IR | [5]INSS | [6]ISS
					nValorIrf := 0
					nValorIns := 0
					nValorIss := 0
					
					nBaseIrf := 0
					nBaseIns := 0
					nBaseIss := 0

					If !lRTipFin .And. nCntFor == oSubFO2:Length() 
						
						If lCalcISS
							nValorIss   := Round(NoRound(aValorImp[06], 3),2)
							nBaseIss    := Round(NoRound(aBaseImp[06] , 3),2)
							nTotValIss  += nValorIss
							nTotBaseIss += nBaseIss
							lCalcISS	:= .F.
						Endif
						
						If lCalcINSS
							nValorIns   := Round(NoRound(aValorImp[05], 3),2)
							nBaseIns    := Round(NoRound(aBaseImp[05] , 3),2)
							nTotValIns  += nValorIns
							nTotBaseIns += nBaseIns
							lCalcINSS	:= .F.
						Endif
						
						If lCalcIRRF
							nValorIrf   := Round(NoRound(aValorImp[04], 3),2)
							nBaseIrf    := Round(NoRound(aBaseImp[04] , 3),2)
							nTotValIrf  += nValorIrf 
							nTotBaseIrf += nBaseIrf 
							lCalcIRRF	:= .F.
						Endif

						IF nTtlImpAbt > 0 .And. oSubFO2:Length() == 1 .and. (lCalcISS .And. lCalcINSS .And. lCalcIRRF)
							nValorIrf := aValorImp[04] - nTotValIrf
							nValorIns := aValorImp[05] - nTotValIns
							nValorIss := aValorImp[06] - nTotValIss
							
							nBaseIrf := aBaseImp[04] - nTotBaseIrf
							nBaseIns := aBaseImp[05] - nTotBaseIns 
							nBaseIss := aBaseImp[06] - nTotBaseIss
						Else
							If SA1->A1_RECISS != "2"		//Gera Abatimentos IS-
								nValorIss := aValorImp[06]
								nBaseIss  := aBaseImp[06]
							Endif

							If SA1->A1_RECIRRF != "2"		//Gera Abatimentos IR-
								nBaseIrf := aBaseImp[04]
								nValorIrf := aValorImp[04]
							Endif

							nBaseIns := aBaseImp[05]
							nValorIns := aValorImp[05]

						Endif
					Endif
					
					aAdd(aTit, {'E1_IRRF'	, nValorIrf, Nil})
					aAdd(aTit, {'E1_INSS'	, nValorIns, Nil})
					aAdd(aTit, {'E1_ISS'	, nValorIss, Nil})			

					aAdd(aTit, {'E1_BASEIRF', nBaseIrf, Nil})
					aAdd(aTit, {'E1_BASEINS', nBaseIns, Nil})
					aAdd(aTit, {'E1_BASEISS', nBaseIss, Nil})

				EndIf
			
				// [1]PIS | [2]COFINS | [3]CSLL
				If nCntFor != oSubFO2:Length() 
					nValorPis := Round(NoRound(aValorImp[01] * nPropImp,3),2)
					nValorCof := Round(NoRound(aValorImp[02] * nPropImp,3),2)
					nValorCsl := Round(NoRound(aValorImp[03] * nPropImp,3),2)
					
					nTotValPis += nValorPis 
					nTotValCof += nValorCof
					nTotValCsl += nValorCsl
					
					nBasePis := Round(NoRound(aBaseImp[01] * nPropImp,3),2)
					nBaseCof := Round(NoRound(aBaseImp[02] * nPropImp,3),2)
					nBaseCsl := Round(NoRound(aBaseImp[03] * nPropImp,3),2)	

					nTotBasePis += nBasePis 
					nTotBaseCof += nBaseCof
					nTotBaseCsl += nBaseCsl
				Else
					nValorPis := aValorImp[01] - nTotValPis
					nValorCof := aValorImp[02] - nTotValCof
					nValorCsl := aValorImp[03] - nTotValCsl

					nBasePis := aBaseImp[01] - nTotBasePis
					nBaseCof := aBaseImp[02] - nTotBaseCof 
					nBaseCsl := aBaseImp[03] - nTotBaseCsl 			
				EndIf
				
				aAdd(aTit, {'E1_PIS'	, nValorPis, Nil})
				aAdd(aTit, {'E1_COFINS'	, nValorCof, Nil})
				aAdd(aTit, {'E1_CSLL'	, nValorCsl, Nil})
					
				aAdd(aTit, {'E1_BASEPIS', nBasePis, Nil})
				aAdd(aTit, {'E1_BASECOF', nBaseCof, Nil})
				aAdd(aTit, {'E1_BASECSL', nBaseCsl, Nil})

				If lRmClass
					aAdd(aTit, {'E1_NUMBCO' , oSubFO2:GetValue("FO2_NOSNUM")  ,Nil})
					aAdd(aTit, {'E1_CODBAR' , oSubFO2:GetValue("FO2_CODBAR")  ,Nil})
					aAdd(aTit, {'E1_CCD'    ,oSubFO2:GetValue('FO2_CCDEBITO') ,NIL})
					aAdd(aTit, {'E1_CCC'    ,oSubFO2:GetValue('FO2_CCCREDITO'),NIL})
					aAdd(aTit, {'E1_DEBITO' ,oSubFO2:GetValue('FO2_CTDEBITO') ,NIL})
					aAdd(aTit, {'E1_CREDIT' ,oSubFO2:GetValue('FO2_CTCREDITO'),NIL})
					aAdd(aTit, {'E1_ITEMD'  ,oSubFO2:GetValue('FO2_ITDEBITO') ,NIL})
					aAdd(aTit, {'E1_ITEMC'  ,oSubFO2:GetValue('FO2_ITCREDITO'),NIL})
					aAdd(aTit, {'E1_CLVLDB' ,oSubFO2:GetValue('FO2_CLDEBITO') ,NIL})
					aAdd(aTit, {'E1_CLVLCR' ,oSubFO2:GetValue('FO2_CLCREDITO'),NIL})
					aAdd(aTit, {'E1_NUMRA'  ,oSubFO2:GetValue('FO2_REGACAD')  ,NIL})
					aAdd(aTit, {'E1_PERLET' ,oSubFO2:GetValue('FO2_PERACAD')  ,NIL})
					aAdd(aTit, {'E1_IDAPLIC',oSubFO2:GetValue('FO2_MATAPLI')  ,NIL})
					aAdd(aTit, {'E1_TURMA'  ,oSubFO2:GetValue('FO2_CLASSE')   ,NIL})
					
					If lOpcAuto .And. cMarca <> NIL
						aAuxRet := IntProInt(oSubFO2:GetValue('FO2_IDTPROD'), cMarca, /*Versão*/)
						If aAuxRet[1]
							aAdd(aTit, { "E1_PRODUTO", aAuxRet[2][3] , NIL})
						EndIf
					Else
						aAdd(aTit, { "E1_PRODUTO", oSubFO2:GetValue('FO2_IDTPROD') , NIL})
					EndIf
				
				EndIf

				//Salva a funname original
				cFuncOri := Alltrim(Funname())
					
				//Cálculo diferenciado dos impostos - MV_RTIPFIN
				SetFunName("FINA460")	

				MSExecAuto({|A,B,C,D,E,F,G,H,J| FINA040(A,B,C,D,E,F,G,H,J)}, aTit, 3, , , , , , aVaTit, lRetIss)		

				If (cVl460Nt == '3' .And. !( l460PIS .Or. l460COF .Or. l460CSL ) )
					RecLock("SE1", .F.)
						SE1->E1_BASECOF := 0
						SE1->E1_BASECSL := 0
						SE1->E1_BASEPIS := 0
					MsUnLock()
				EndIf
					
				//Restaura a funname original
				SetFunName(cFuncOri)

				//Verifica se a gravacao ocorreu normalmente
				If lMsErroAuto
					lRet:= .F.
					
					If !IsBlind()
						MOSTRAERRO() 
					EndIf

					aErrorAuto := GetAutoGRLog()
					AEval(aErrorAuto, {|x| cErrorAuto += x + CRLF})
					oModel:SetErrorMessage("","","","","FIN460AGRV",IIf(!Empty(cErrorAuto), cErrorAuto, STR0106),"")

					RollBackDelTran()
					Exit
				EndIf
		
				If lUsaFlag .AND. lPadrao .AND. MV_PAR01 == 1 // Armazena em aFlagCTB para atualizar no modulo Contabil
					aAdd( aFlagCTB, {"E1_LA", "S", "SE1", SE1->( Recno() ), 0, 0, 0} )
				Else
					RecLock("SE1",.F.)
						SE1->E1_LA := Iif(lPadrao .and. mv_par01==1,"S","")
					SE1->( MsUnLock() )
				EndIf
				
				nValorTotal+= SE1->E1_VLCRUZ
				
				//Rastreamento - Gerados
				If lRastro
					aadd(aRastroDes,{	SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,;
										SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA,SE1->E1_VALOR } )
				EndIf			
				
				If Alltrim(oSubFO2:GetValue("FO2_TIPO")) == Alltrim(MVCHEQUE) .And. lGrvSEF()
					// Se o cheque nao existir no cadastro
					If SEF->(	!MsSeek(xFilial("SEF") + "R" + oSubFO2:GetValue("FO2_BANCO") + oSubFO2:GetValue("FO2_AGENCI") + ;
								oSubFO2:GetValue("FO2_CONTA") + oSubFO2:GetValue("FO2_NUMCH") + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
						
						RecLock("SEF",.T.)
						SEF->EF_FILIAL		:= xFilial("SEF")
						SEF->EF_BANCO		:= oSubFO2:GetValue("FO2_BANCO") // Banco
						SEF->EF_AGENCIA		:= oSubFO2:GetValue("FO2_AGENCI") // Agencia
						SEF->EF_CONTA		:= oSubFO2:GetValue("FO2_CONTA") // Conta
						SEF->EF_NUM			:= oSubFO2:GetValue("FO2_NUMCH") // nro. do cheque
						SEF->EF_VALOR		:= oSubFO2:GetValue("FO2_TOTAL") // valor do cheque			
						SEF->EF_VALORBX		:= oSubFO2:GetValue("FO2_TOTAL") // valor do cheque		
						SEF->EF_CPFCNPJ		:= Posicione("SA1",1,xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA, "A1_CGC")	
						SEF->EF_EMITENT		:= oSubFO2:GetValue("FO2_EMITEN") // Emitente
						SEF->EF_DATA		:= dDataBase
						SEF->EF_VENCTO		:= oSubFO2:GetValue("FO2_VENCTO") // data de vencimento
						SEF->EF_HIST		:= (STR0041) // "Chq. gerado pela liquidacao"
						SEF->EF_CLIENTE		:= SE1->E1_CLIENTE
						SEF->EF_LOJACLI		:= SE1->E1_LOJA
						SEF->EF_PREFIXO		:= SE1->E1_PREFIXO
						SEF->EF_TITULO		:= SE1->E1_NUM
						SEF->EF_PARCELA		:= SE1->E1_PARCELA
						SEF->EF_TIPO		:= SE1->E1_TIPO
						SEF->EF_CART		:= "R"
						SEF->EF_ORIGEM		:= "FINA460"
						SEF->EF_FILORIG		:= SE1->E1_FILORIG
						// Grava o identificador de que o cheque ja foi utilizado na baixa, devido as
						// baixas parciais, pois nas baixas futuras esses cheques nao podem mais serem utilizados
						// na geracao do movimento bancario
						If cSldBxCr <> "C"
							SEF->EF_USADOBX := "S"
						Endif	
					
						// Ponto de Entrada que permite gravação de campos do usuário
						If __lF460GSEF
							ExecBlock( "F460GRVSEF" )
						EndIf

						SEF->( MsUnlock() )
					EndIf
				EndIf
		
				If __lf460Val
					ExecBlock("F460VAL",.f.,.f.,aComplem)
				EndIf
				
				// Contabiliza On Line
				If mv_par01 == 1
				
					If !lHeadProva .and. lPadrao
						nHdlPrv := HeadProva( cLote, "FINA460", Substr( cUsuario, 7, 6 ), @cArquivo )
		
						lHeadProva := .T.
					EndIf
		
					If lPadrao
						nTotal += DetProva( nHdlPrv, cPadrao, "FINA460", cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/,;
											/*lRateio*/, /*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ ) 
						If UsaSeqCor()
							AADD(aDiario,{"SE1",SE1->(recno()),cCodDiario,"E1_NODIA","E1_DIACTB"}) 
						Endif 
					
					EndIf
				EndIf
			Endif
		Next nCntFoR
		
		nLstRecFO2	:= SE1->(Recno())
		
		//Integração via Mensagem Única
		If FWHasEAI('FINA460',.T.,,.T.)
			FWIntegDef('FINA460')
				
			If ( ValType(aRespInteg) == "A" .AND. Len(aRespInteg) >= 2 .AND. !aRespInteg[1] ) .Or. nLstRecFO2 <> SE1->(Recno())  
				If ! IsBlind()
					Help( ,, "FINA040INTEG",, STR0139 + Iif( ValType(aRespInteg) == "U", STR0140, AllTrim(aRespInteg[2] ) ), 1, 0,,,,,, {STR0141} ) //"O registro não será gravado, pois ocorreu um erro na integração: ", "Verifique se a integração está configurada corretamente."  						
				Endif
				RollBackDelTran()
				Return .F.
			Endif
		EndIf
		
		oModel:Activate() //ativando o modelo de dados principal da liquidação, pois o modelo ativo foi alterado quando foi feita a baixa do título

		VALOR 	:= 0
		VALOR 	:= nValorTotal
		JUROS3	:= 0
		FO1VADI	:= 0
		
		If lContabiliza .AND. lPadrao 
		
			//Desposiciono SE1 para nao duplicar
			nSe1Rec := SE1->(RECNO())
			SE1->(dbGoBottom())
			SE1->(dbSkip())
		
			//Contabilizo totalizador - VALOR
			nTotal += DetProva( nHdlPrv, cPadrao, "FINA460", cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/,;
						/*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/,/*aDadosProva*/ )
		
			//Reposiciono SE1
			SE1->(DBGOTO(nSe1Rec))
		
		EndIf
	EndIf

	// Gravação do Modelo após a geração da SE1 caso seja Efetivar Liquidação
	If _nOper == OPER_LIQUIDAR .AND. lVersao
		_nOper := OPER_ALTERA
	EndIf

	If _nOper == OPER_INCLUI .AND. lRet
		
		For nCount:= 1 To oSubFO1:Length()
			oSubFO1:GoLine(nCount)
			
			If !oSubFO1:GetValue("FO1_MARK")
				oSubFO1:DeleteLine()
			EndIf
			
		Next nCount
		
		oSubFO1:GoLine(1)
		
		If oModel:VldData()
			lRet := FWFormCommit(oModel)
		Else
			lRet := .F.
			cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[6])
			Help(" ",1,"F460ACommit",, cLog, 1, 0) // "Não é possível liquidar um processo que esteja Bloqueado, Cancelado, Gerado ou Encerrado."
			RollBackDelTran()
		EndIf
		
	ElseIf _nOper == OPER_ALTERA .AND. lRet

		cVerAnt	:= oSubFO0:GetValue("FO0_VERSAO")
		cVerNova:= Soma1( oSubFO0:GetValue("FO0_VERSAO"), , .F., .T. )
		oSubFO0:LoadValue( "FO0_VERSAO", cVerNova )
		
		For nCount:= 1 To oSubFO1:Length()
			oSubFO1:GoLine(nCount)
			oSubFO1:LoadValue( "FO1_VERSAO", cVerNova )
		Next nCount
		oSubFO1:GoLine(1)
		
		For nCount:= 1 To oSubFO2:Length()
			oSubFO2:GoLine(nCount)
			oSubFO2:LoadValue( "FO2_VERSAO", cVerNova )
		Next nCount
		oSubFO1:GoLine(1)
		
		If oModel:VldData()
			FO0->(RecLock("FO0", .F.))
			FO0->FO0_BKPSTT := oSubFO0:GetValue( "FO0_STATUS" )
			FO0->FO0_STATUS := "5"
			FO0->(MsUnlock())
			lRet:= FA460GRV(oModel)
		Else
			lRet := .F.
			cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[6])
			Help(" ",1,"F460ACommit",, cLog, 1, 0)
			RollBackDelTran()
		EndIf
		
	ElseIf _nOper == OPER_BLOQUEAR .AND. lRet
		
		oSubFO0:LoadValue( "FO0_BKPSTT", oSubFO0:GetValue( "FO0_STATUS" ) )
		oSubFO0:LoadValue( "FO0_STATUS", "2" )
		
		If oModel:VldData()
			lRet := FWFormCommit(oModel)
		Else
			lRet := .F.
			cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[6])
			Help(" ",1,"F460ACommit",, cLog, 1, 0)
			RollBackDelTran()
		EndIf
		
	ElseIf _nOper == OPER_DESBLOQUEAR .AND. lRet
		
		oSubFO0:LoadValue( "FO0_BKPSTT", oSubFO0:GetValue( "FO0_STATUS" ) )
		oSubFO0:LoadValue( "FO0_STATUS", "1" )
			
		If oModel:VldData()
			lRet := FWFormCommit(oModel)
		Else
			lRet := .F.
			cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[6])
			Help(" ",1,"F460ACommit",, cLog, 1, 0)
			RollBackDelTran()
		EndIf
		
	ElseIf _nOper == OPER_EFETIVAR .AND. lRet
		
		If lRecalcula 
			cVerAnt	:= oSubFO0:GetValue("FO0_VERSAO")
			cVerNova:= Soma1( oSubFO0:GetValue("FO0_VERSAO"), , .F., .T. )
			oSubFO0:LoadValue( "FO0_VERSAO", cVerNova )
		
			For nCount:= 1 To oSubFO1:Length()
				oSubFO1:GoLine(nCount)
				oSubFO1:LoadValue( "FO1_VERSAO", cVerNova )
			Next nCount
			oSubFO1:GoLine(1)
		
			For nCount:= 1 To oSubFO2:Length()
				oSubFO2:GoLine(nCount)
				oSubFO2:LoadValue( "FO2_VERSAO", cVerNova )
			Next nCount
			oSubFO1:GoLine(1)
		
			If oModel:VldData()
				FO0->(RecLock("FO0", .F.))
				FO0->FO0_BKPSTT := oSubFO0:GetValue( "FO0_STATUS" )
				FO0->FO0_STATUS := "5"
				FO0->(MsUnlock())
				lRet := FA460GRV(oModel)
			Else
				lRet := .F.
				cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
				cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
				cLog += cValToChar(oModel:GetErrorMessage()[6])
				Help(" ",1,"F460ACommit",, cLog, 1, 0)
				RollBackDelTran()
			EndIf
		
		Else
			oSubFO0:LoadValue( "FO0_BKPSTT", oSubFO0:GetValue( "FO0_STATUS" ) )
			oSubFO0:LoadValue( "FO0_STATUS", "4" )
		
			If oModel:VldData()
				// Faz a gravação na tabela OHT - Relac. Fatura x Títulos
				If lIntPFS .And. Chkfile("OHT") .And. FindFunction("JurGrvOHT")
					JurGrvOHT(xFilial("FO0"), oSubFO0:GetValue("FO0_NUMLIQ"), ;
							oSubFO0:GetValue("FO0_CLIENT"), oSubFO0:GetValue("FO0_LOJA"))
				EndIf
				lRet := FWFormCommit(oModel)
			Else
				lRet := .F.
				cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
				cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
				cLog += cValToChar(oModel:GetErrorMessage()[6])
				Help(" ",1,"F460ACommit",, cLog, 1, 0)
				RollBackDelTran()
			EndIf
		EndIf

	ElseIf _nOper == OPER_LIQUIDAR .AND. lRet

		oSubFO0:LoadValue( "FO0_BKPSTT", oSubFO0:GetValue( "FO0_STATUS" ) )
		oSubFO0:LoadValue( "FO0_STATUS", "4" )
		
		For nCount:= 1 To oSubFO1:Length()
			oSubFO1:GoLine(nCount)
			
			If !oSubFO1:GetValue("FO1_MARK")
				oSubFO1:DeleteLine()
			EndIf
			
		Next nCount
		
		oSubFO1:GoLine(1)
		
		If oModel:VldData()
			// Faz a gravação na tabela OHT - Relac. Fatura x Títulos
			If lIntPFS .And. Chkfile("OHT") .And. FindFunction("JurGrvOHT")
				JurGrvOHT(xFilial("FO0"), oSubFO0:GetValue("FO0_NUMLIQ"), ;
							oSubFO0:GetValue("FO0_CLIENT"), oSubFO0:GetValue("FO0_LOJA"))
			EndIf
			lRet := FWFormCommit(oModel)
		Else
			lRet := .F.
			cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[6])
			Help(" ",1,"F460ACommit",, cLog, 1, 0)
			RollBackDelTran()
		EndIf

	ElseIf _nOper == OPER_RELIQUIDAR .AND. lRet

		oSubFO0:LoadValue( "FO0_BKPSTT", oSubFO0:GetValue( "FO0_STATUS" ) )
		oSubFO0:LoadValue( "FO0_STATUS", "4" )//FO0->FO0_STAANT
		
		If oModel:VldData()
			// Faz a gravação na tabela OHT - Relac. Fatura x Títulos
			If lIntPFS .And. Chkfile("OHT") .And. FindFunction("JurGrvOHT")
				JurGrvOHT(xFilial("FO0"), oSubFO0:GetValue("FO0_NUMLIQ"), ;
							oSubFO0:GetValue("FO0_CLIENT"), oSubFO0:GetValue("FO0_LOJA"))
			EndIf
			lRet := FWFormCommit(oModel)
		Else
			lRet := .F.
			cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[6])
			Help(" ",1,"F460ACommit",, cLog, 1, 0)		
			RollBackDelTran()
		EndIf

	EndIf

	//------------------------------------------------------------------------------------------------
	// Se a operação for de Liquidar, significa que o facilitador (FO0_EFETIVA = '1') foi utilizado,
	// sendo assim, o processo de efetivação do Financeiro e do TMK precisam ser chamados.
	//------------------------------------------------------------------------------------------------
	If _nOper == OPER_LIQUIDAR .And. !FwIsInCallStack("F460AltSim") .And. !FwIsInCallStack("TA45GerLiq").AND. !FwIsInCallStack("FINA460") .AND. !FwIsInCallStack("FINI460") .and. !lOpcAuto
		F460AEfet()
	EndIf
	//------------------------------------------------------------
	// Atualiza Parametro de Ultimo Numero de Liquidacao
	// Somente se nao existir o ponto de entrada, pois o mesmo 
	// ja atualiza o parametro                                 ³
	//------------------------------------------------------------
	if __lF460NUM == NIL
		__lF460NUM := ExistBlock("F460NUM")
	endIf
	If !__lF460NUM     
		cLiquid := FO0->FO0_NUMLIQ
		If GetMv("MV_NUMLIQ",,.T.) < cLiquid
			PutMv("MV_NUMLIQ", cLiquid)
		Endif
	Endif

	End Transaction

	//Alterações na SA1
	If lRet
		lAtuCli := .T.	
		If __lF070Tra 
			lAtuCli := ExecBlock("F070TRAVA",.F.,.F.) //P.E que indica ser haverá atualização das informações do cliente
		EndIf 

		aAreaAnt := GETAREA()
		for nX := 1 to len(aSalDup)
			DbSelectArea("SE1")
			DbGoto(aSalDup[nx][1])
			nValPadrao := aSalDup[nx][2]

			DbSelectArea("SA1")
			DbSetOrder(1)
			If SA1->(MsSeek(FWxFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
				//Atualiza "Saldo Duplicatas" do Cliente utilizando mesmo conceito do nValPadrao
				//utilizado na rotina de baixas a receber(FINA070/FINXATU) 
				nValClient := nValPadrao
				IF SE1->E1_MOEDA > 1
					//----------------------------------------------------------------------
					// Caso a Moeda seja > 1, converte o valor para atualização do  
					// cadastro do Cliente a partir do valor da moeda estrangeira   
					// convertida p/ moeda 1 na Data de Emissão do t¡tulo, pois pode
					// ser efetuada uma baixa informando taxa contratada.           
					//----------------------------------------------------------------------
					nValClient:=Round(NoRound(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,SE1->E1_EMISSAO,3),3),2)
				Endif

				AtuSalDup("-",nValClient,1,SE1->E1_TIPO,,SE1->E1_EMISSAO)
				
				If lAtuCli
					RecLock("SA1")	
					IF (SE1->E1_BAIXA-SE1->E1_VENCREA) > SA1->A1_MATR
						A1_MATR := (SE1->E1_BAIXA-SE1->E1_VENCREA)
					EndIf		
					
					// Atualiza Atraso Médio.  Revisao em 07/12/95				     
					A1_NROPAG := A1_NROPAG + 1  //Numero de Duplicatas

					If (SE1->E1_BAIXA - SE1->E1_VENCREA) > 0
						SA1->A1_PAGATR	:= A1_PAGATR+SE1->E1_VALLIQ   // Pagamentos Atrasados
						SA1->A1_ATR		:= IIF(A1_ATR==0,0,IIF(A1_ATR < SE1->E1_VALLIQ,0,A1_ATR - SE1->E1_VALLIQ))
						SA1->A1_METR	:=	(A1_METR * (A1_NROPAG-1) + (SE1->E1_BAIXA - SE1->E1_VENCREA)) / (A1_NROPAG)
					Endif		
					SA1->(MsUnlock())
				EndIf
			EndIf
		next nX
		restArea(aAreaAnt)
		FWFreeArray(aAreaAnt)
	EndIf

	If lRet .AND. (_nOper == OPER_EFETIVAR .OR. _nOper == OPER_LIQUIDAR .OR. _nOper == OPER_RELIQUIDAR) //nOpcx <> 7
		If nTotal > 0
			RodaProva(  nHdlPrv, nTotal)
						
			lDigita	:=IIF(mv_par02==1,.T.,.F.)
			lAglutina:=IIF(mv_par03==1,.T.,.F.)
			
			cA100Incl( cArquivo, nHdlPrv, 3, cLote, lDigita, lAglutina, /*cOnLine*/, /*dData*/, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, aDiario )
			aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
			
		EndIf
		
		VALOR := 0
		
		if __lF460CTB == NIL
			__lF460CTB := Existblock("F460CTB")		// ponto apos a contabilizacao
		endIf
		If __lF460CTB
			Execblock("F460CTB",.F.,.F.)
		EndIf
		
		//Gravacao do rastreamento
		If lRastro
			FINRSTGRV(2, "SE1", aRastroOri, aRastroDes, nValProces) 
		EndIf
	EndIf

	cFilAnt := cFilAtu
	lMostraVA	:= .T.
	aVaTitGer	:= F460CLEARVA()

	//Faz a impressao do Recibo de pagamento
	If lImpLjRe .And. (lLojrRec .Or. lULOJRREC) 
		If Len(__aRelBx) > 0
			aAreaSe1 := SE1->(GetArea())
			aAreaSe5 := SE5->(GetArea())
			aAreaRec := GetArea()
			
			If lULOJRREC
				//Fonte não será mais padrao mas sim um RDMake padrão.
				U_LOJRRecibo("", "", __aRelBx, Nil, __aRelNovos)
			Else
				LOJRREC("", "", __aRelBx, Nil, __aRelNovos)
			EndIf
			
			RestArea(aAreaSe1)
			RestArea(aAreaSe5)
			RestArea(aAreaRec)
		EndIf
	EndIf

	if oModelBxR != NIL
		oModelBxR:Destroy()
		oModelBxR := NIL
	endIf

	//Metricas - Gravação da Liquidação
	If __lMetric .and. nGravados > 0

		__cFunBkp   := FunName()
		__cFunMet	:= Iif(AllTrim(__cFunBkp)=='RPC',"RPCFINA460A",__cFunBkp)

		nFim := Seconds() - nInicio
		nFim := nFim / nGravados

		SetFunName(__cFunMet)
		FwCustomMetrics():setAverageMetric(Alltrim(ProcName())+" - TempoGravacao", "financeiro-protheus_tempo-conclusão-processo_seconds", nFim)
		SetFunName(__cFunBkp)
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F460AIncl() //Inclusão de Simulação
Rotina que realiza a inclusão de um simulação de liquidação FINA460A.

@author Diego Santos
@since 19/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------

Function F460AIncl()

Local nOpcx			:= OPER_INCLUI
Local cAliasTMP		:= GetNextAlias()

Local cMvJurTipo	:= SuperGetMv("MV_JURTIPO",,"")  // calculo de Multa do Loja , se JURTIPO == L
Local lMulLoj		:= SuperGetMv("MV_LJINTFS", ,.F.) //Calcula multa conforme regra do loja, se integração com financial estiver habilitada

Local aCpoBro		:= 	{	{ "FO1_MARK"  ,, " "    ,"@!"},;							
							{ "FO1_SALDO" ,, FO1->(RetTitle("FO1_SALDO"))	,"@E 999,999,999.999"},;	//Saldo negociado
							{ "FO1_TXJUR" ,, FO1->(RetTitle("FO1_TXJUR"))	,"@E 99.99"},;  			//Taxa de Juros
							{ "FO1_VLJUR" ,, FO1->(RetTitle("FO1_VLJUR"))	,"@E 9,999,999,999.99"},;  	//Valor do juros
							{ "FO1_TXMUL" ,, FO1->(RetTitle("FO1_TXMUL"))	,"@E 99.99"},;  			//Taxa da multa
							{ "FO1_VLMUL" ,, FO1->(RetTitle("FO1_VLMUL"))	,"@E 9,999,999,999.99"},;  	//Valor da multa
							{ "FO1_DESCON",, FO1->(RetTitle("FO1_DESCON"))	,"@E 9,999,999,999.99"},;  	//Descontos
							{ "FO1_ACRESC",, FO1->(RetTitle("FO1_ACRESC"))	,"@E 9,999,999,999.99"},;  	//Acrescimos
							{ "FO1_DECRES",, FO1->(RetTitle("FO1_DECRES"))	,"@E 9,999,999,999.99"},;  	//Decrescimos
							{ "FO1_VLABT" ,, FO1->(RetTitle("FO1_VLABT"))	,"@E 9,999,999,999.99"},;	//Valor abatido
							{ "FO1_TOTAL" ,, FO1->(RetTitle("FO1_TOTAL"))	,"@E 9,999,999,999.99"},;   //Total 							
							{ "FO1_FILORI",, FO1->(RetTitle("FO1_FILORI"))	,"@!"},;  					//Filial de Origem	
							{ "FO1_MOEDA" ,, FO1->(RetTitle("FO1_MOEDA"))	,"@!"},;					//Moeda
							{ "FO1_TXMOED",, FO1->(RetTitle("FO1_TXMOED"))	,"@E 99.99"},;  			//Taxa da moeda 							
							{ "FO1_VALCVT",, SE1->(RetTitle("E1_VALOR"))	,"@E 9,999,999,999.99"},; 	//Valor convertido na moeda							
							{ "FO1_PREFIX",, SE1->(RetTitle("E1_PREFIXO"))	,"@X"},;   					//Prefixo
							{ "FO1_NUM"   ,, SE1->(RetTitle("E1_NUM"))		,"@!"},; 					//Número do título
							{ "FO1_PARCEL",, SE1->(RetTitle("E1_PARCELA"))	,"@!"},;  					//Parcela
							{ "FO1_TIPO"  ,, SE1->(RetTitle("E1_TIPO"))		,"@!"},;					//Tipo
							{ "FO1_NATURE",, SE1->(RetTitle("E1_NATUREZ"))	,"@!"},;	 				//Natureza
							{ "FO1_CLIENT",, SE1->(RetTitle("E1_CLIENTE"))	,"@!"},;  					//Cliente
							{ "FO1_LOJA"  ,, SE1->(RetTitle("E1_LOJA"))		,"@!"},;  					//Loja do cliente
							{ "FO1_EMIS"  ,, SE1->(RetTitle("E1_EMISSAO"))	,"@D"},;  					//Dt. Emissão
							{ "FO1_VENCTO",, SE1->(RetTitle("E1_VENCTO"))	,"@D"},;  					//Dt. de vencimento
							{ "FO1_VENCRE",, SE1->(RetTitle("E1_VENCREA"))	,"@D"},;  					//Dt. de vencimento
							{ "FO1_BAIXA" ,, SE1->(RetTitle("E1_NUM"))		,"@D"},;  					//Dt. Baixa
							{ "FO1_VLBAIX",, SE1->(RetTitle("E1_VALLIQ"))	,"@E 9,999,999,999.99"},; 	//Valor baixado
							{ "FO1_HIST"  ,, SE1->(RetTitle("E1_HIST"))		,"@!"},;  					//Histórico
							{ "FO1_CCUST" ,, SE1->(RetTitle("E1_CCUSTO"))   ,"@!"},;					//Centro de Custo
							{ "FO1_ITEMCT",, SE1->(RetTitle("E1_ITEMCTA"))  ,"@!"},;					//ITEM DA CONTA
							{ "FO1_CLVL"  ,, SE1->(RetTitle("E1_CLVL"))     ,"@!"},;						//Classe de Valor	
							{ "FO1_CREDIT",, SE1->(RetTitle("E1_CREDIT"))   ,"@!"},;						//Conta Credito
							{ "FO1_DEBITO",, SE1->(RetTitle("E1_DEBITO"))  	,"@!"},;						//Conta Debito
							{ "FO1_CCC"	  ,, SE1->(RetTitle("E1_CCC"	))	,"@!"},;					//CC Credito
							{ "FO1_CCD"   ,, SE1->(RetTitle("E1_CCD"	))	,"@!"},;					//CC Debito
							{ "FO1_ITEMC" ,, SE1->(RetTitle("E1_ITEMC"	))	,"@!"},;					//Item Credito
							{ "FO1_ITEMD" ,, SE1->(RetTitle("E1_ITEMD"	))	,"@!"},;					//Item Debito
							{ "FO1_CLVLCR",, SE1->(RetTitle("E1_CLVLCR"	))	,"@!"},;					//Classe de Valor Credito
							{ "FO1_CLVLDB",, SE1->(RetTitle("E1_CLVLDB"	))	,"@!"}}						//Classe de Valor Debito

							
							
Local nTamLiq    		:= TamSX3("E1_NUMLIQ")[1]							

Private cLiquid			:= Space(nTamLiq)
Private cCliente 		:= Criavar ("E1_CLIENTE",.F.)
Private cLoja    		:= Criavar ("E1_LOJA",.F.)
Private cCli460			:= ""
Private cCliDE			:= Criavar ("E1_CLIENTE",.F.)
Private cLojaDE  		:= Criavar ("E1_LOJA",.F.)
Private cCliAte 		:= Criavar ("E1_CLIENTE",.F.)
Private cLojaAte 		:= Criavar ("E1_LOJA",.F.)
Private cNomeCli		:= CriaVar ("E1_NOMCLI")
Private cNatureza		:= Criavar ("E1_NATUREZ")
Private cTipo			:= Criavar ("E1_TIPO")
Private cCondicao		:= Space(3)			// numero de parcelas automaticas
Private cNumDe			:= CriaVar("E1_NUM")
Private cNumAte			:= CriaVar("E1_NUM")
Private cPrefDe			:= CriaVar("E1_PREFIXO")
Private cPrefAte		:= CriaVar("E1_PREFIXO")
Private cMarca			:= GetMark()
Private cParc460		:= F460Parc()		// controle de parcela (E1_PARCELA)
Private aTmpFil			:= {} 
Private cChvRaNDoc  	:= ""
Private cTurma	 		:= ""
Private cCodDiario		:= ""    
Private nUsado2			:= 0
Private nIntervalo		:= 1
Private nMoeda			:= 1
Private nValor	 		:= 0
Private nQtdTit 		:= 0
Private nValorMax		:= 0				// valor maximo de liquidacao (digitado)
Private nValorDe		:= 0 			   	// valor inicial dos titulos
Private nValorAte		:= 9999999999.99 	// Valor final dos titulos
Private nValorLiq		:= 0				// valor da liquidacao ap¢s mBrowse
Private nNroParc		:= 0				// numero de parcelas digitadas
Private nPosAtu			:= 0
Private nPosAnt			:= 9999
Private nColAnt			:= 9999
Private nValorAcr		:= 0				// valor da liquidacao ap¢s mBrowse
Private nValorDcr		:= 0				// valor da liquidacao ap¢s mBrowse
Private nValorTot		:= 0
Private nSaldoBx		:= 0
Private nIDAPLIC 		:= 0				//Integracao Protheus x RM Classis
Private nContrato   	:= 0
Private dData460I 		:= dDataBase
Private dData460F 		:= dDataBase
Private aHeader 		:= {}
Private aCols  			:= {}
Private aDiario 		:= {}
Private lInverte		:= .F.
Private lReliquida 		:= .F. //Exclusivo para a simulação FINA460A.
Private oGet
Private oValorLiq
Private oValorAcr
Private oValorDcr
Private oValorTot
Private oNroParc
Private oCliAte
Private oLojaAte
Private cMoeda460		:= ""
Private cOutrMoed		:= STR0061 //"2 - Nao Considera"

//-------------------------------------------------------------------
// Inicializa array com as moedas existentes.					 
//-------------------------------------------------------------------

DbSelectArea("SE1")
cAlias    	:= "SE1"
cCliente  	:= FO0->FO0_CLIENT
cCli460		:= cCliente
cLoja     	:= FO0->FO0_LOJA
cCliDE 		:= FO0->FO0_CLIENT
cLojaDE   	:= FO0->FO0_LOJA
cCliAte   	:= FO0->FO0_CLIENTE
cLojaAte  	:= FO0->FO0_LOJA
dData460I 	:= dDataBase
dData460F 	:= dDataBase
If Empty(cPrefAte)
	cPrefAte := Replicate("Z",TamSx3("E1_PREFIXO")[1])
EndIf
If Empty(cNumAte)
	cNumAte := Replicate("Z",TamSx3("E1_NUM")[1])
EndIf

M->E1_TIPO := cTipo

If cMvJurTipo == "L" .Or. lMulLoj
	aAdd( aCpoBro , {"MULTALJ",,OemToAnsi(STR0063),"@E 9,999,999,999.99"} ) //"Juros" 
EndIf

if __lF460STI == NIL
	__lF460STI := Existblock("F460STI")
endIf
If __lF460STI
	lRet := Execblock("F460STI",.F.,.F.,{cAliasTMP,nOpcx,aCpoBro})
	If lRet
		lRet := F460BuscSE1(cAliasTMP,nOpcx,aCpoBro, @cAliasTMP,2 )
		If lRet
			lRet := F460SelTit(@cAliasTMP,nOpcx)
		EndIf
	Endif
Else	
	lRet := F460BuscSE1(cAliasTMP,nOpcx,aCpoBro, @cAliasTMP,2 )
	If lRet
		lRet := F460SelTit(@cAliasTMP,nOpcx)
	EndIf
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F460AltSim() //Alteração de Simulação
Rotina que realiza a alteração e versionamento da um simulação de liquidação FINA460A.

@author Pâmela Bernardo
@since 21/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------

Function F460AltSim()

Local cPrograma     	:= ""
Local nOperation 		:= MODEL_OPERATION_UPDATE
Local aEnableButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,(STR0065)},{.T.,(STR0042)},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }//"Salvar Simulação" //"Fechar"
Local lRet				:= .T.
Local oModelLiq

_nOper			:= OPER_ALTERA
oModelLiq 		:= FWLoadModel("FINA460A")//Carrega estrutura do model

oModelLiq:SetOperation( MODEL_OPERATION_UPDATE ) //Define operação de inclusao
oModelLiq:Activate()//Ativa o model

If FO0->FO0_STATUS == "1" .AND. F460ARec(oModelLiq)       //Recalculo Realizado.
	cTitulo      	:= (STR0046) //"Alterar Simulação" 	
	cPrograma    	:= 'FINA460A'
	__lUserButton  	:= .T.
	bCancel      	:=  { |oModelLiq| F460NoAlt(oModelLiq)}
	nMoeda			:=  oModelLiq:GetValue( "MASTERFO0", "FO0_MOEDA" )
	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, aEnableButtons, bCancel , /*cOperatId*/, /*cToolBar*/,oModelLiq )
	_lUserButton 	:= .F.
	oModelLiq:Deactivate()
	oModelLiq:Destroy()
	oModelLiq := NIL
	
Else
	oModelLiq:Deactivate()
	oModelLiq:Destroy()
	oModelLiq := NIL
	Help(" ",1,"F460ALTSIM",,(STR0062), 1, 0) // "Não é possível alterar um processo que esteja Bloqueado, Cancelado, Gerado, Vencido ou Encerrado."
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F460VerSim() //Visualização de Simulação
Rotina que realiza a visualização da simulação de liquidação FINA460A.

@author Pâmela Bernardo
@since 21/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------

Function F460VerSim()


Local cPrograma     	:= ""
Local nOperation 		:= MODEL_OPERATION_UPDATE
Local aEnableButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,(STR0042)},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Fechar"
Local lRet				:= .T.

_nOper			:= OPER_VISUALIZAR
cTitulo      	:= (STR0043) //"Visualizar Simulação" 	
cPrograma    	:= 'FINA460A'
__lUserButton  	:= .T.
bCancel      	:=  { |oModel| F460NoAlt(oModel)}
nRet         	:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, aEnableButtons, bCancel , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
__lUserButton  	:= .F.

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F460NoAlt() //Visualização de Simulação
Rotina para inibir a pergunta se deseja salvar ou não a visualização da simulação.

@author Pâmela Bernardo
@since 21/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------

Function F460NoAlt(oModel)

Local oView := FWViewActive()

oView:SetModified(.F.)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} A460VldParc()

Função para validar as parcelas dos títulos a serem gerados

@author julio.teixeira
@since 26/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------
Function A460VldParc()

Local lRet 		:= .T.
Local oModel 	:= FWModelActive()
Local oView 	:= FWViewActive()
Local oModelFO0 := oModel:GetModel('MASTERFO0')
Local oModelFO2 := oModel:GetModel('TITGERFO2')
Local cParcel	:= oModelFO2:GetValue("FO2_PARCEL")
Local cNum		:= oModelFO2:GetValue("FO2_NUM")
Local cTipo 	:= oModelFO2:GetValue("FO2_TIPO")
Local nLinAtu	:= oModelFO2:GetLine()
Local nX := 1

For nX := 1 to oModelFO2:Length()
	oModelFO2:GoLine(nX)
	If cNum+cParcel+cTipo == oModelFO2:GetValue("FO2_NUM")+oModelFO2:GetValue("FO2_PARCEL")+oModelFO2:GetValue("FO2_TIPO") .AND. nX != nLinAtu .AND. lRet 
		oModel:SetErrorMessage("",,oModel:GetId(),"","F460VLDVEN",OemToAnsi(STR0064)+ cNum + " " + cParcel + " " + cTipo) //'Títulos com parcelas duplicadas. Verifique!'
		lRet := .F.		
		oModelFO2:GoLine(nLinAtu)
		oView:Refresh()
		Exit
	Endif 
Next nX

If !lRet
	oModelFO2:GoLine(nLinAtu)
	Return(lRet)
Endif

If nLinAtu == 1 .AND. lRet .And. !Empty(oModelFO0:GetValue("FO0_TIPO"))
	For nX := 2 to oModelFO2:Length()
		oModelFO2:GoLine(nX)
		cParcel := Soma1(cParcel)
		oModelFO2:LoadValue("FO2_PARCEL",cParcel)
	Next nX
Else
	oModelFO2:GoLine(nLinAtu)
	oModelFO2:LoadValue("FO2_PARCEL",cParcel)
Endif

If lRet 
	oModelFO2:GoLine(1)
	oView:Refresh()
	oModelFO2:GoLine(nLinAtu)
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F460ATime() //Timer tela de simulação
Rotina que irá controlar o tempo em que o usuário poderá permanecer com a 
tela de liquidação aberta.

@author Diego Santos
@since 26/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------

Function F460ATime()

Local oView		:= FwViewActive()
Local nTimeOut  := Int(SuperGetMv("MV_FATOUT",.F.,900)*1000) 	//Estabelece 15 minutos para que o usuarios selecione - 
Local nTimeMsg  := Int(SuperGetMv("MV_MSGTIME",.F.,120)*1000) 	//Estabelece 02 minutos para exibir a mensagem para o usuário
Local oDlgMsg
Local oTimer2
Local lMsgOk	:= .F.

If !FwIsInCallStack("F460VerSim")

	DEFINE MSDIALOG oDlgMsg TITLE (STR0056) From 10,10 To 18,45 OF oMainWnd	//"Atencao"
	oDlgMsg:lCentered := .T.
	
	@ 0.5, 1.8 Say STR0054	FONT oDlgMsg:oFont Of oDlgMsg	//"Esta tela sera finalizada automaticamente em "
	@ 1.5, 1.8 Say AllTrim(Str(INT(((nTimeOut-nTimeMsg)/1000)/60))) + STR0055	FONT oDlgMsg:oFont Of oDlgMsg	//" minuto(s), caso continue sem utilizacao."
	
	DEFINE SBUTTON FROM 40,55 TYPE 1 ACTION (lMsgOk := .T., oDlgMsg:End()) ENABLE OF oDlgMsg
	
	oTimer2:= TTimer():New((nTimeOut-nTimeMsg), {|| oDlgMsg:End() }, oDlgMsg)
	oTimer2:Activate()
	
	oDlgMsg:Activate()
	
	If !lMsgOk
		oView:SetModified(.F.)
		oView:ButtonCancelAction()
	EndIf

Endif

Return

//-------------------------------------------------------------------
/*/
Função para retornar o valor total de tituloas a baixar

@author rodrigo.pirolo
@since 28/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------

Static Function TotValFO1(oSubFO1)

Local nCount	:= 0
Local nValTot	:= 0

For nCount:= 1 To oSubFO1:Length()
	oSubFO1:GoLine(nCount)
	
	If oSubFO1:GetValue("FO1_MARK")
		nValTot+= oSubFO1:GetValue("FO1_TOTAL")
	EndIf
	
Next nCount

Return nValTot

//-------------------------------------------------------------------
/*/{Protheus.doc} TotValFO2( oSubFO2 )
Função para retornar o valor a ser liquidado.

@author Jose.Gavetti
@since 06/02/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------

Static Function TotValFO2(oSubFO2)

Local nCount	:= 0
Local nValTotLiq	:= 0

For nCount:= 1 To oSubFO2:Length()
	oSubFO2:GoLine(nCount)
	If !oSubFO2:IsDeleted()
		nValTotLiq+= oSubFO2:GetValue("FO2_VALOR")
	EndIf
Next nCount

Return nValTotLiq

//-------------------------------------------------------------------
/*/{Protheus.doc} F460ARec( oModel ) //Recalculo de Simulação.
Rotina que irá verificar se os títulos da simulação sofreram.
baixas parciais ou totais.

@author Diego Santos
@since 27/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------
Static Function F460ARec( oModel )

Local lRet 			:= .T.
Local nX
Local nY			:= 0 
Local oFO0			:= Nil
Local oFO1			:= Nil
Local aRecalculo	:= {}

Local nOpcRec		:= 0
Local oDlgRec		:= Nil

If FwIsInCallStack("F460AltSim") .Or. FwIsInCallStack("F460AEfet")

	oFO0 := oModel:GetModel('MASTERFO0')
	oFO1 := oModel:GetModel('TITSELFO1')
	
	For nX := 1 To oFO1:Length()
	
		oFO1:GoLine(nX)
		FK7->(DbSetOrder(1))
		If FK7->(MsSeek(xFilial("FK7",oFO1:GetValue("FO1_FILORI"))+ oFO1:GetValue("FO1_IDDOC")))
		
			cSE1Chv2:= FinFK7Key(FK7->FK7_CHAVE,"")
			If FwIsInCallStack("TMKA271D")		
				nSE1Des	:= oFO1:GetValue("FO1_DESCON") + oFO1:GetValue("FO1_DECRES") + oFO1:GetValue("FO1_DESJUR")
			Else
				nSE1Des	:= oFO1:GetValue("FO1_DESCON") + oFO1:GetValue("FO1_DECRES")			
			EndIf
		
			SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If SE1->(DbSeek(cSE1Chv2))
				If oFO1:GetValue("FO1_SALDO") <> SE1->E1_SALDO //Significa que houve alteração do saldo desde a criação da simulação.
					If SE1->E1_SALDO == 0
						aAdd( aRecalculo, { cSE1Chv2, SE1->E1_SALDO, nX, .F. } ) //Baixa Total
					Else
						aAdd( aRecalculo, { cSE1Chv2, SE1->E1_SALDO, nX, .T. } ) //Baixa Parcial							
					EndIf
				EndIf
			EndIf			
		EndIf
					
	Next nX
	
	//Verifica se algum item teve baixa parcial para efetuar o recalculo.
	For nY := 1 to Len(aRecalculo)
		If aRecalculo[nY][4]
			lRecalcula := .T.
			Exit
		EndIf
	Next
	
	//Se houve alguma baixa total e existe titulo sem baixa, deve recalcular a simulação
	If Len(aRecalculo) > 0 .And. ( Len(aRecalculo) < oFO1:Length())
		lRecalcula	:= .T.
	EndIf 
		
	If Len(aRecalculo) > 0
		If Len(aRecalculo) <= oFO1:Length() //Ainda existe saldo para se realizar o recalculo.
			
			DEFINE MSDIALOG oDlgRec TITLE OemToAnsi(STR0056) FROM 100,300 TO 210,750 PIXEL OF oMainWnd STYLE DS_MODALFRAME//"Atenção"
			oDlgRec:lCentered := .T.
			
			If lRecalcula
				//Exibe Msg perguntando se deseja encerrar ou recalcular a simulação.
				@1,2 Say OemToAnsi(STR0066) +; //"Houveram alterações nos saldos de alguns títulos após a criação desta simulação. "
				 		 ENTER + OemToAnsi(STR0067) Of oDlgRec //"Deseja realizar o recálculo dos valores ou encerrar esta negociação?"	
				
				@40,68   BUTTON OemToAnsi(STR0068) 	SIZE 040, 010 PIXEL OF oDlgRec ACTION ( nOpcRec := 1, oDlgRec:End()) //"Recalcular"
				@40,123  BUTTON OemToAnsi(STR0069)	SIZE 040, 010 PIXEL OF oDlgRec ACTION ( nOpcRec := 2, oDlgRec:End()) //"Encerrar"
			Else
				//Exibe Msg perguntando se deseja encerrar ou recalcular a simulação.
				@1,2 Say OemToAnsi(STR0070) +; //"Todos os títulos desta simulação foram baixados em sua totalidade. "
				 		 ENTER + OemToAnsi(STR0071) Of oDlgRec //"Esta solicitação será encerrada."

				@40,97  BUTTON OemToAnsi(STR0072) SIZE 040, 010 PIXEL OF oDlgRec ACTION ( nOpcRec := 2, oDlgRec:End()) //"Ok"
			EndIf
			
			ACTIVATE MSDIALOG oDlgRec CENTERED

			If nOpcRec == 1
				F460ARecalcula( oModel, aRecalculo )
				lRet := .T.				
			ElseIf nOpcRec == 2
				F460AEncerra( oModel, aRecalculo )
				lRet := .F.				
			EndIf
		EndIf		
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F460ARecalcula( oModel, aRegs ) //Recalculo de Simulação.
Rotina que irá recalcular a simulação caso um ou mais dos seus títulos tenham sofrido.
Baixas Parciais ou Totais.

@author Diego Santos
@since 28/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------
Static Function F460ARecalcula( oModel, aRegs )

Local aArea 	:= GetArea()
Local aFO0Area	:= FO0->(GetArea())
Local aFO1Area	:= FO1->(GetArea())
Local aFO2Area	:= FO2->(GetArea())
Local oModelFO0 := oModel:GetModel("MASTERFO0")
Local oModelFO1 := oModel:GetModel("TITSELFO1")
Local oModelFO2 := oModel:GetModel("TITGERFO2")
Local nX		:= 0
Local nCond		:= 0
Local aParcelas
Local cCond		:= oModelFO0:GetValue("FO0_COND")
Local nValor	:= 0
Local nDifer	:= 0
Local nValParc	:= 0
Local nTotNegoc := 0
Local nVlrLiqAnt:= 0 
Local nPropor	:= 0  

oModelFO1:SetNoDeleteLine( .F. )

For nX := 1 To Len(aRegs)

	oModelFO1:GoLine(aRegs[nX][3])	 
	oModelFO1:LoadValue("FO1_SALDO", aRegs[nX][2])
	oModelFO1:LoadValue("FO1_VLJUR", (aRegs[nX][2]/100) * oModelFO1:GetValue("FO1_TXJUR") ) //Recalcula
	oModelFO1:LoadValue("FO1_VLMUL", (aRegs[nX][2]/100) * oModelFO1:GetValue("FO1_TXMUL") ) //Recalcula
	
	oModelFO1:LoadValue("FO1_VALCVT", oModelFO1:GetValue("FO1_VALCVT") - (oModelFO1:GetValue("FO1_VALCVT")-oModelFO1:GetValue("FO1_SALDO"))) 
	oModelFO1:LoadValue("FO1_TOTAL" , oModelFO1:GetValue("FO1_TOTAL")  - (oModelFO1:GetValue("FO1_TOTAL")-oModelFO1:GetValue("FO1_SALDO")))
	
	If aRegs[nx][2] == 0 //Se o titulo foi baixado, exibe deletado na grid.
		oModelFO1:DeleteLine()
	EndIf

Next nX

For nX := 1 To oModelFO1:Length()
	oModelFO1:GoLine(nX)
	If !oModelFO1:IsDeleted()
		nValor += Round((oModelFO1:GetValue("FO1_SALDO") * oModelFO1:GetValue("FO1_TXMOED")),2)
	EndIf
Next nX

nVlrLiqAnt := oModelFO0:GetValue("FO0_VLRLIQ")
oModelFO0:LoadValue("FO0_VLRLIQ",nValor)

If !Empty(cCond)
	aParcelas := Condicao (nValor,cCond,,oModelFO0:GetValue("FO0_DATA"))
	//----------------------------------------------------------------------
	// Corrige possiveis diferencas entre o valor selecionado e o 
	// apurado ap¢s a divisao das parcelas						   	
	///----------------------------------------------------------------------
	For nCond := 1 to Len (aParcelas)
		nValParc += aParcelas [ nCond, 2]
	Next nCond
	
	If nValParc != nValor
		nDifer := Round(nValor - nValParc,2)
		aParcelas [ Len(aParcelas), 2 ] += nDifer
	EndIf
Else
	aParcelas	:= {}
	For nX := 1 To oModelFO2:Length()
		oModelFO2:GoLine(nX)
	
		nPropor := nValor * 100 / nVlrLiqAnt
		nValParc := ( oModelFO2:GetValue("FO2_VALOR") * nPropor ) /100 
	
		aadd(aParcelas, {oModelFO2:GetValue("FO2_VENCTO"),nValParc})	
	Next

EndIf

//Atualiza FO2.
For nX := 1 To oModelFO2:Length()
	oModelFO2:GoLine(nX)
	oModelFO2:LoadValue("FO2_VALOR",aParcelas [ nX, 2])
	oModelFO2:LoadValue("FO2_VLJUR",(aParcelas [ nX, 2]/100) * oModelFO2:GetValue("FO2_TXJUR"))
	oModelFO2:LoadValue("FO2_TOTAL",oModelFO2:GetValue("FO2_VALOR")+oModelFO2:GetValue("FO2_VLJUR")+oModelFO2:GetValue("FO2_ACRESC")-oModelFO2:GetValue("FO2_DECRES"))
	oModelFO2:LoadValue("FO2_VLPARC",oModelFO2:GetValue("FO2_VALOR")+oModelFO2:GetValue("FO2_VLJUR"))
	nTotNegoc += oModelFO2:GetValue("FO2_TOTAL")
Next nX

oModelFO0:LoadValue("FO0_VLRNEG",nTotNegoc)
oModelFO1:SetNoDeleteLine( .T. )

RestArea(aArea)
RestArea(aFO0Area)
RestArea(aFO1Area)
RestArea(aFO2Area)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F460AEncerra( oModel, aRegs ) //Encerramento de Simulação.
Rotina que irá encerrar a simulação. Altera o campo FO0_STATUS.

@author Diego Santos
@since 28/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------

Static Function F460AEncerra( oModel, aRegs )

Local aArea 	:= GetArea()
Local aFO0Area	:= FO0->(GetArea())
Local aFO1Area	:= FO1->(GetArea())
Local aFO2Area	:= FO2->(GetArea())

Begin Transaction
	RecLock("FO0",.F.)
		FO0->FO0_BKPSTT := FO0->FO0_STATUS 
		FO0->FO0_STATUS := "5"
	MsUnlock()
End Transaction

RestArea(aArea)
RestArea(aFO0Area)
RestArea(aFO1Area)
RestArea(aFO2Area)

Return

//-------------------------------------------------------------------
/*/
Função para validar a data de validade da simulação

@author julio.teixeira
@since 23/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------
Function A460VldData()

Local lRet 		:= .T.
Local oModel 	:= FWModelActive()
Local oModelFO0 := oModel:GetModel('MASTERFO0')
Local dValid 	:= dDataBase + SuperGetMV("MV_LMVLDLQ",.F.,0)

If oModelFO0:GetValue("FO0_DTVALI") < dDataBase
	oModel:SetErrorMessage("",,oModel:GetId(),"",'F460VLDANT',OemToAnsi(STR0123), STR0168 ) //"Data de validade digitada é anterior a database do sistema ou invalida." # "Favor verificar a Data Digitada."
	lRet := .F.
Endif

If lRet
	If oModelFO0:GetValue("FO0_DTVALI") > dValid
		oModel:SetErrorMessage("",,oModel:GetId(),"",'F460VLDVEN',OemToAnsi(STR0073)) //'Data superior a data de vencimento limite!'
		lRet := .F.
	Endif
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} a460DataOK()
Função para validar a data de Vencimento do titulo a ser gerado

@author Mauricio Pequim Jr
@since 22/01/1998
@version P12.1.8
/*/
//-------------------------------------------------------------------
Function a460DataOK()

Local lRet   := .T.
Local oModel := FWModelActive()
Local oModelFO2 := oModel:GetModel('TITGERFO2')

//----------------------------------------------------------------------
// Verifica se data não é menor que database                    
//----------------------------------------------------------------------
If  oModelFO2:GetValue("FO2_VENCTO") < dDataBase
	oModel:SetErrorMessage("",,oModel:GetId(),"","A460DTCHEQ",OemToAnsi(STR0074)) //"Data de validade menor que data atual!"
	lRet := .F.
Else
	F460CalJur(oModel,,3)
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F460TmkVld() //Validação se operador pode realizar a liquidação.

Rotina que irá validar os dados do grid antes da geração dos títulos (SIGATMK)

@author Diego dos Santos
@since 01/12/2015
@version P12.1.9
/*/
//-------------------------------------------------------------------

Static Function F460TmkVld(oModel)

Local oModelFO0	:= oModel:GetModel('MASTERFO0')
Local lRet 		:= .T.

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F460VldFO2() //Validação das linhas da FO2 antes da gravação

Rotina que irá validar os dados do grid antes da geração dos títulos

@author julio.teixeira
@since 27/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------

Static Function F460VldFO2(oModel)

Local oView		:= FWViewActive()
Local oModelFO0	:= oModel:GetModel('MASTERFO0')
Local oModelFO1 := oModel:GetModel('TITSELFO1')
Local oModelFO2 := oModel:GetModel('TITGERFO2')
Local nX 		:= 0
Local nY		:= 0
Local lRet 		:= .T.
Local lAltParc	:= .F.
Local cPrefixo	:= ''
Local cNum		:= ''
Local cParcel	:= ''
Local cTipoTit	:= ''
Local cIDSim	:= ''
Local cChaveAnt := ""
Local cNumBan   := ""
Local cNumAge   := ""
Local cNumCta   := ""
Local cNumChq   := ""
Local cEmitente	:= ""
Local nTotalFO2 := 0
Local nTotalFO1 := 0
Local nTotNegFO2:= 0
Local nValor	:= 0
Local dDataVenc	:= CTOD("  /  /  ") 
lCMC7 := IIf( type ("lCMC7") == "L",lCMC7 ,.F.)

DbSelectArea("SE1")
SE1->(DbSetOrder(1))

//Verifica se a numeráção está repetida
For nX := 1 to oModelFO2:Length()
	oModelFO2:Goline(nX)
	cPrefixo := oModelFO2:GetValue("FO2_PREFIX")
	cNum     := oModelFO2:GetValue("FO2_NUM")
	cParcel  := oModelFO2:GetValue("FO2_PARCEL")
	cTipoTit := oModelFO2:GetValue("FO2_TIPO")
	nValor	 := oModelFO2:GetValue("FO2_VALOR")
	dDataVenc:= oModelFO2:GetValue("FO2_VENCTO")
	
	If ( nValor = 0 .Or. Empty(dDataVenc) ) .and. !oModelFO2:IsDeleted()
		lRet := .F.
		oModel:SetErrorMessage("",,oModel:GetId(),"","F460VLDVAZ",OemToAnsi(STR0107)) //"Verificar se o valor e a data de vencimento dos títulos a serem gerados estão preenchidos."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
		Exit
	EndIf
	
	If nX > 1 
		If !oModelFO2:IsDeleted()
			If cChaveAnt == cPrefixo+cNum+cParcel+cTipoTit
				lRet	:= .F.
				oModel:SetErrorMessage("",,oModel:GetId(),"","F460VLDVEN",OemToAnsi(STR0064)+ cPrefixo + " " + cNum + " " + cParcel + " " + cTipoTit ) //'Títulos com parcelas duplicadas. Verifique!'
				Exit
			EndIf
		EndIf	
	EndIf
	cChaveAnt := oModelFO2:GetValue("FO2_PREFIX")+oModelFO2:GetValue("FO2_NUM")+oModelFO2:GetValue("FO2_PARCEL")+oModelFO2:GetValue("FO2_TIPO")
Next

If !lRet
	oModelFO2:Goline(1)
	Return(lRet)
EndIf
	
For nX := 1 to oModelFO2:Length()
	oModelFO2:Goline(nX)
	
	If !oModelFO2:IsDeleted()
		cPrefixo := oModelFO2:GetValue("FO2_PREFIX")
		cNum     := oModelFO2:GetValue("FO2_NUM")
		cParcel  := oModelFO2:GetValue("FO2_PARCEL")
		cTipoTit := oModelFO2:GetValue("FO2_TIPO")
		cIDSim	 := oModelFO2:GetValue("FO2_IDSIM")
		cNumBan	 := oModelFO2:GetValue("FO2_BANCO")
		cNumAge	 := oModelFO2:GetValue("FO2_AGENCI")
		cNumCta	 := oModelFO2:GetValue("FO2_CONTA")
		cNumChq	 := oModelFO2:GetValue("FO2_NUMCH")
		cEmitente:= oModelFO2:GetValue("FO2_EMITEN")
		
		If Empty(cNum)//Valida se a linha possui um número de título
			oModel:SetErrorMessage("",,oModel:GetId(),"","A460NUM",OemToAnsi(STR0075)) //'Informe um número de título para os títulos a serem gerados.'
			lRet := .F.
			Exit
		Endif
		
		If Empty(cTipoTit)//Valida se a linha possui um número de título
			oModel:SetErrorMessage("",,oModel:GetId(),"","F460TITGER",OemToAnsi(STR0135)) //'Informe um número de título para os títulos a serem gerados.'
			lRet := .F.
			Exit
		Endif
		If Alltrim(cTipoTit) == "CH" .And. lGrvSEF() .And. ( Empty(cNumBan) .Or. Empty(cNumAge) .Or. Empty(cNumCta) .Or. Empty(cNumChq) .Or. Empty(cEmitente) )
			oModel:SetErrorMessage("",,oModel:GetId(),"","F460CHQBAN",OemToAnsi(STR0169)) //"Sistema está parametrizado para gerar cheque porém os dados estão incompletos. Verifique os campos: nro cheque, banco, agência e conta."
			lRet := .F.
			Exit		
		EndIf

		If Empty(cIDSim)
			oModelFO2:LoadValue("FO2_IDSIM" ,FWUUIDV4() ) //Chave ID tabela FK1.
			oModelFO2:LoadValue("FO2_PROCES",oModelFO0:GetValue("FO0_PROCES")) //Processo
			oModelFO2:LoadValue("FO2_VERSAO",oModelFO0:GetValue("FO0_VERSAO")) //Versão
		Endif 

		nTotalFO2 += oModelFO2:GetValue("FO2_TOTAL")
		nTotNegFO2 += oModelFO2:GetValue("FO2_VALOR")
	Endif
Next nX

If FwIsInCallStack("FINA460") .Or. FwIsInCallStack("TMKA271D")  

	If lRet
		For nY := 1 To oModelFO1:Length()
			oModelFO1:Goline(nY)
			If oModelFO1:GetValue("FO1_MARK")
				nTotalFO1 += oModelFO1:GetValue("FO1_TOTAL")
			EndIf
		Next nY
	EndIf
EndIf

If lRet .and. lAltParc
	Help(" ",1,"F460VldFO2",,OemToAnsi(STR0077), 1, 0) // "As parcelas dos títulos a serem gerados foram alteradas para evitar a duplicação de títulos!")
EndIf

oModelFO2:Goline(1)

If !lOpcAuto
	oView:Refresh()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F460JurMul //Recalcula os juros e multas

Atualiza os campos de valores através das alterações nos campos de juros e multas

@param oModel
@param cCampo - String com nome do campo que chamou a função
@author julio.teixeira
@since 28/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------

Function F460JurMul(oModel,cCampo,nlinha,lMark)

Local oModelFO0 	:= oModel:GetModel("MASTERFO0")
Local oModelFO1 	:= oModel:GetModel("TITSELFO1")
Local oModelFO2 	:= oModel:GetModel("TITGERFO2")
Local oView 		:= FWViewActive()
Local cSE1Chv2		:= ""
Local nMoedaFO0 	:= oModelFO0:GetValue("FO0_MOEDA")
Local nTxJur		:= oModelFO0:GetValue("FO0_TXJUR")
Local nTxJrg		:= oModelFO0:GetValue("FO0_TXJRG")
Local nTxMul		:= oModelFO0:GetValue("FO0_TXMUL")
Local lCpoTxMoed    := FO0->(ColumnPos("FO0_TXMOED")) > 0
Local nTxMoeFO0     := Iif(lCpoTxMoed,oModelFO0:GetValue("FO0_TXMOED"),0)
Local nTxMoeda		:= 0
Local nValMul		:= 0
Local nValJur		:= 0
Local nX			:= 0
Local nLinFO1		:= 0
local nLinFO2		:= oModelFO2:GetLine()
Local nTotal		:= 0
Local nSaldo		:= 0
Local nTotLiq		:= 0
Local nTtlVlNg		:= 0
Local nTotGer		:= 0
Local nVlrJurFO2	:= 0
Local lUsaMark		:= (FwIsInCallStack("F460AIncl") .Or. FwIsInCallStack("A460Liquid"))
Local aSvLines		:= FWSaveRows()
Local lConvVal      := oModelFO1:GetValue("FO1_MOEDA") > 1 .AND. oModelFO0:GetValue("FO0_MOEDA") <> oModelFO1:GetValue("FO1_MOEDA")

Default lMark := .F.

If cCampo $ "FO0_TXJUR|FO0_TXMUL"
	//Atualiza a taxa de juros em todas as linhas da FO1
	For nX := 1 To oModelFO1:Length() 
		oModelFO1:Goline(nX)
		
		DbSelectArea("FK7")
		FK7->(DbSetOrder(1))
		If FK7->(MsSeek(xFilial("FK7",oModelFO1:GetValue("FO1_FILORI"))+ oModelFO1:GetValue("FO1_IDDOC")))
		
			cSE1Chv2:= FinFK7Key(FK7->FK7_CHAVE,"")
		
			SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If SE1->(DbSeek(cSE1Chv2))		
				If nTxMoeFO0 > 0
					nTxMoeda := nTxMoeFO0
					nSaldo := Round(NoRound(xMoeda( oModelFO1:GetValue("FO1_SALDO") - oModelFO1:GetValue("FO1_VLABT"), oModelFO1:GetValue("FO1_MOEDA"), nMoedaFO0, , 3,nTxMoeda ), 3), 2)
				Else	
					nTxMoeda:= Iif(SE1->E1_TXMOEDA > 0 ,SE1->E1_TXMOEDA,RecMoeda(dDataBase, oModelFO1:GetValue("FO1_MOEDA")))
					nSaldo := Round(NoRound(xMoeda( oModelFO1:GetValue("FO1_SALDO") - oModelFO1:GetValue("FO1_VLABT"), oModelFO1:GetValue("FO1_MOEDA"), nMoedaFO0, , 3,nTxMoeda), 3), 2)
				EndIf

				//Verifico se o titulo está atrasado
				If oModelFO1:GetValue("FO1_VENCRE") < dDataBase
					oModelFO1:LoadValue("FO1_TXJUR",nTxJur)
					//Calcula o juros e atribui a variável
					nAtraso := dDataBase - oModelFO1:GetValue("FO1_VENCTO")
					If cCampo == "FO0_TXJUR" 
						If nTxJur > 0 

							nValJur := faJuros(	SE1->E1_VALOR,SE1->E1_SALDO,oModelFO1:GetValue("FO1_VENCTO"),,;
												nTxJur,oModelFO0:GetValue("FO0_MOEDA"),,dDatabase,,,;
												oModelFO1:GetValue("FO1_VENCRE"),,,,,,/*Recalculo .T. */ , .F. /*Liquidação*/)

							nValJur := Round(NoRound(xMoeda(nValJur,SE1->E1_MOEDA,nMoeda,dDataBase,3,SE1->E1_TXMOEDA),3),2) 
						Else
							nValJur	:= 0 
						EndIf
					Else
						nValJur		:= oModelFO1:GetValue("FO1_VLJUR")
					EndIf

								 

					oModelFO1:LoadValue("FO1_VLJUR",nValJur)																
					oModelFO1:LoadValue("FO1_TXMUL",nTxMul)
			
					//Calcula o multa e atribui a variável
					If cCampo $ "FO0_TXMUL"
						nValMul	:= LojxRMul( , , oModelFO1:GetValue("FO1_TXMUL"), nSaldo, oModelFO1:GetValue("FO1_ACRESC"),;
												oModelFO1:GetValue("FO1_VENCRE"), dDataBase, ,/*oModelFO1:GetValue("FO1_VLMUL")*/,,;
												oModelFO1:GetValue("FO1_PREFIX"), oModelFO1:GetValue("FO1_NUM"),;
												oModelFO1:GetValue("FO1_PARCEL"), oModelFO1:GetValue("FO1_TIPO"),;
												oModelFO1:GetValue("FO1_CLIENT"), oModelFO1:GetValue("FO1_LOJA"), ,.T.)

						oModelFO1:LoadValue("FO1_VLMUL", Round( NoRound( xMoeda( nValMul, nMoedaFO0, nMoedaFO0, , 3,, nTxMoeda), 3 ), 2 ) )
					EndIf
				EndIf
					
				nTotal	:= nSaldo + oModelFO1:GetValue("FO1_VLJUR") + oModelFO1:GetValue("FO1_VLMUL") + oModelFO1:GetValue("FO1_ACRESC") + oModelFO1:GetValue("FO1_VACESS") + Iif(lCpoFO1Ad,oModelFO1:GetValue("FO1_VLADIC"),0)
					
				If FwIsInCallStack("TMKA271D")
					nTotal 	:= nTotal - oModelFO1:GetValue("FO1_DESCON") - oModelFO1:GetValue("FO1_DECRES") - oModelFO1:GetValue("FO1_DESJUR")
				Else
					nTotal 	:= nTotal - oModelFO1:GetValue("FO1_DESCON") - oModelFO1:GetValue("FO1_DECRES") 
				EndIf		
				oModelFO1:LoadValue("FO1_TOTAL", nTotal)
			
				If oModelFO1:GetValue("FO1_MARK") .or. !lUsaMark
					nTotLiq += nTotal
				Endif
			EndIf
		EndIf
	Next nX
	
	oModelFO0:LoadValue("FO0_VLRLIQ", nTotLiq)
	
	oModelFO1:Goline(1)

//Atualiza a taxa de juros informada em todas as linhas da FO2
ElseIf cCampo == "FO0_TXJRG"
	For nX := 1 To oModelFO2:Length() 
		oModelFO2:Goline(nX)
		oModelFO2:LoadValue("FO2_TXJUR",nTxJrg)
		nTotal := oModelFO2:GetValue("FO2_VALOR") + oModelFO2:GetValue("FO2_VLJUR") + oModelFO2:GetValue("FO2_ACRESC") - oModelFO2:GetValue("FO2_DECRES")
		oModelFO2:LoadValue("FO2_TOTAL", nTotal)
		nTotGer += nTotal
	Next
	If lOpcAuto
		oModelFO0:LoadValue("FO0_VLRNEG", nTotGer)
	EndIf

	oModelFO2:Goline(1)
	
//Atualiza a taxa de juros em linha especifica da FO1
ElseIf cCampo $ "FO1_TXJUR|FO1_TXMUL|FO1_VLDIA|FO1_VLJUR|FO1_DESCON|FO1_VLMUL|FO1_VLADIC" 
	//Calcula o juros e atribua variável
	nLinFO1 := oModelFO1:GetLine()
	
	nTxMoeda:= RecMoeda(dDataBase, nMoedaFO0)
	If lConvVal
		nSaldo := Round(NoRound(oModelFO1:GetValue("FO1_SALDO") * oModelFO1:GetValue("FO1_TXMOED"),3),2)
	Else
		nSaldo := Round(NoRound(xMoeda( oModelFO1:GetValue("FO1_SALDO"), oModelFO1:GetValue("FO1_MOEDA"), nMoedaFO0, dDataBase, 3, , nTxMoeda), 3), 2)
	EndIf

	If cCampo == "FO1_VLJUR"
		If lMark
			If  SE1->E1_PORCJUR > 0
				oModelFO1:LoadValue("FO1_TXJUR", SE1->E1_PORCJUR)
			ElseIf oModelFO0:GetValue("FO0_TXJUR") > 0
				oModelFO1:LoadValue("FO1_TXJUR", oModelFO0:GetValue("FO0_TXJUR"))
			Else
				oModelFO1:LoadValue("FO1_TXJUR", 0 )
			Endif
		Else
			oModelFO1:LoadValue("FO1_TXJUR", 0)
		EndIf
		For nX := 1 To oModelFO1:Length() 
			oModelFO1:Goline(nX)
			nVlrJurFO2 += oModelFO1:GetValue("FO1_VLJUR")
		Next nX
	EndIf
	
	If cCampo == "FO1_TXJUR" .OR. cCampo == "FO1_VLDIA"
		//Se a data de pagamento for menor ou igual que o vencimento real nao calculo juros
		If dDataBase <= oModelFO1:GetValue("FO1_VENCRE")
			nAtraso := 0
			nValJur := 0
		Else
			If (oModelFO0:GetValue("FO0_VLRJUR") - oModelFO1:GetValue("FO1_VLJUR")) > 0
				nVlrJurFO2 := oModelFO0:GetValue("FO0_VLRJUR") - oModelFO1:GetValue("FO1_VLJUR")
			Endif
			nTxJur  := oModelFO1:GetValue("FO1_TXJUR")
			nAtraso := dDataBase - oModelFO1:GetValue("FO1_VENCRE")
			If nTxJur > 0
				FK7->(DbSetOrder(1))
				If FK7->(MsSeek(xFilial("FK7",oModelFO1:GetValue("FO1_FILORI"))+ oModelFO1:GetValue("FO1_IDDOC")))
					cSE1Chv2 := FinFK7Key(FK7->FK7_CHAVE,"")
					SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					If SE1->(DbSeek(cSE1Chv2))
						If oModelFO0:GetValue("FO0_MOEDA") = oModelFO1:GetValue("FO1_MOEDA")
							nValJur := faJuros(nSaldo, nSaldo,oModelFO1:GetValue("FO1_VENCTO"),,;
												nTxJur,oModelFO0:GetValue("FO0_MOEDA"),,dDatabase,,,;
												oModelFO1:GetValue("FO1_VENCRE"),,,,,,/*Recalculo .T. */ , .F. /*Liquidação*/)
						Else
							nValJur := faJuros(	oModelFO1:GetValue("FO1_SALDO"),oModelFO1:GetValue("FO1_SALDO"),oModelFO1:GetValue("FO1_VENCTO"),,;
												nTxJur,oModelFO0:GetValue("FO0_MOEDA"),,dDatabase,,,;
												oModelFO1:GetValue("FO1_VENCRE"),,,,,,/*Recalculo .T. */ , .F. /*Liquidação*/)
						EndIf
						nValJur := Round(NoRound(xMoeda(nValJur,SE1->E1_MOEDA,nMoeda,dDataBase,3,SE1->E1_TXMOEDA),3),2) 	
					EndIf
				EndIf
			Else
				nValJur	:= 0 
			EndIf
		EndIf

		nVlrJurFO2 += nValJur
		
		oModelFO1:LoadValue("FO1_VLJUR", nValJur)

	ElseIf cCampo == "FO1_TXMUL"
		nTxMoeda:= RecMoeda(dDataBase, nMoedaFO0)
		nValMul := LojxRMul( , , oModelFO1:GetValue("FO1_TXMUL") , nSaldo,;
							oModelFO1:GetValue("FO1_ACRESC"), oModelFO1:GetValue("FO1_VENCRE"), dDataBase, ,;
							, , oModelFO1:GetValue("FO1_PREFIX"), oModelFO1:GetValue("FO1_NUM"),;
							oModelFO1:GetValue("FO1_PARCEL"),oModelFO1:GetValue("FO1_TIPO"),oModelFO1:GetValue("FO1_CLIENT"),;
							oModelFO1:GetValue("FO1_LOJA"), , .T. )
		
		nValMul := Round(NoRound(xMoeda(nValMul,SE1->E1_MOEDA,nMoeda,dDataBase,3,SE1->E1_TXMOEDA),3),2) 	
		oModelFO1:LoadValue("FO1_VLMUL", Round( NoRound( xMoeda( nValMul, nMoedaFO0, nMoedaFO0, dDataBase, 3, , nTxMoeda), 3 ), 2 ) )
	ElseIf cCampo == "FO1_VLMUL"
		If oModelFO1:GetValue("FO1_VLMUL") = 0
			oModelFO1:LoadValue("FO1_TXMUL",0)
		EndIf
	EndIf
	
	oModelFO1:Goline(nLinFO1)
	nOldTotal	:= oModelFO1:GetValue("FO1_TOTAL")
	nTotLiq 	:= oModelFO0:GetValue("FO0_VLRLIQ")
	nTotal 		:= nSaldo + ((oModelFO1:GetValue("FO1_VLJUR") + oModelFO1:GetValue("FO1_VLMUL") + oModelFO1:GetValue("FO1_ACRESC") + Iif(lCpoFO1Ad,oModelFO1:GetValue("FO1_VLADIC"),0)) - oModelFO1:GetValue("FO1_VLABT"))	
	
	If FwIsInCallStack("TMKA271D")
		nTotal := nTotal - oModelFO1:GetValue("FO1_DESCON") - oModelFO1:GetValue("FO1_DECRES") - oModelFO1:GetValue("FO1_DESJUR")
	Else
		nTotal := nTotal - oModelFO1:GetValue("FO1_DESCON") - oModelFO1:GetValue("FO1_DECRES") + oModelFO1:GetValue("FO1_VACESS")
	EndIf 
	oModelFO1:LoadValue("FO1_TOTAL", nTotal)
	
	If cCampo $ "FO1_TXMUL|FO1_TXJUR|FO1_VLMUL|FO1_VLJUR"
		nTtlVlNg := 0
		For nX := 1 To oModelFO2:Length()
			oModelFO2:GoLine(nX)
			nTtlVlNg += oModelFO2:GetValue("FO2_VALOR")
		Next nX
		oModelFO0:LoadValue("FO0_VLRNEG", nTtlVlNg) 
		oModelFO2:GoLine(nLinFO2)
	Endif
	
	If oModelFO1:GetValue("FO1_MARK") .or. !lUsaMark
		If !lConvVal
			nTotLiq	+= (nTotal - nOldTotal)
		EndIf
		oModelFO0:LoadValue("FO0_VLRLIQ", nTotLiq)
		oModelFO0:LoadValue("FO0_VLRJUR", nVlrJurFO2)
	EndIf
	
//Atualiza a taxa de juros em linha especifica da FO2
ElseIf cCampo $ "FO2_VENCTO|FO2_TXJUR|FO2_VLJUR"
	nOldTotal	:= oModelFO2:GetValue("FO2_TOTAL")
	nTotLiq 	:= oModelFO0:GetValue("FO0_VLRNEG")
	nValJur		:= oModelFO2:GetValue("FO2_VLJUR")
	nTxMoeda	:= RecMoeda(dDataBase, nMoedaFO0)
	
	nValParc := oModelFO2:GetValue("FO2_VALOR") + oModelFO2:GetValue("FO2_VLJUR")
	oModelFO2:LoadValue("FO2_VLPARC", nValParc)
	
	nTotal := oModelFO2:GetValue("FO2_VALOR") + oModelFO2:GetValue("FO2_VLJUR") + oModelFO2:GetValue("FO2_ACRESC") - oModelFO2:GetValue("FO2_DECRES")
	oModelFO2:LoadValue("FO2_TOTAL", nTotal)
	
	nTotLiq	+= (nTotal - nOldTotal)
	
	If cCampo = "FO2_TXJUR"
		nTotLiq := 0
		For nX := 1 To oModelFO2:Length()
			oModelFO2:GoLine(nX)
			nTotLiq += oModelFO2:GetValue("FO2_VALOR") + oModelFO2:GetValue("FO2_VLJUR") + oModelFO2:GetValue("FO2_ACRESC") - oModelFO2:GetValue("FO2_DECRES")
		Next nX
		oModelFO2:GoLine(nLinFO2)
	Endif

	oModelFO0:LoadValue("FO0_VLRNEG", nTotLiq) 

	F460CalJur(oModel,,3)

EndIf

If (nLinFO1 > 0 .OR. !(cCampo $ "FO2_TXJUR|FO0_TXJRG|FO2_VENCTO|FO2_VLJUR")) 
	If !lOpcAuto
		F460TitGer( oModel, cCampo, nLinFO1, lCmc7 )//Atualiza FO2
	EndIf
	FWRestRows( aSvLines )
Else
	FWRestRows( aSvLines )
	If !lOpcAuto .And. !FwIsInCallStack("F460ARecalcula") 
		
		If SE4->E4_TIPO == "9" 
			oView:Refresh("VIEW_FO0") 
		Else
			oView:Refresh()
		EndIf
		
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} F460AIncE
Rotina para Verificar se houve alteração na simulação de liquidação 
para somente gerar uma nova versão se houver alteração.

@author Rodrigo Pirolo
@since 29/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------

Static Function F460AIncE(oModel, lIncSim)

Local oSubFO0	:= oModel:GetModel("MASTERFO0")
Local oSubFO2	:= oModel:GetModel("TITGERFO2")

Local cNLiquid	:= ""

Local aFO2Fields:= oModel:GetModel("TITGERFO2"):oFormModelStruct:GetFields()

Local lVersao	:= .F.

Local nCampo	:= 0
Local nDados	:= 0

If !lIncSim
	For nDados := 1 To oSubFO2:Length()
		oSubFO2:GoLine(nDados)
		DbSelectArea("FO2")
		FO2->(DbSetOrder(1))
	
		If FO2->(MsSeek(oSubFO2:GetValue("FO2_FILIAL") + oSubFO2:GetValue("FO2_PROCES") +;
						oSubFO2:GetValue("FO2_VERSAO") + oSubFO2:GetValue("FO2_IDSIM") ))
			For nCampo := 1 To Len(aFO2Fields)
				cCampo := aFO2Fields[nCampo][3]
				If FO2->&(cCampo) <> oSubFO2:GetValue(cCampo)
					lVersao:= .T.
					Exit
				EndIf
			Next nCampo
		EndIf
	Next nDados
EndIf

If ( _nOper <> OPER_INCLUI .And. !lRecalcula )  .Or. AllTrim(oSubFO0:GetValue('FO0_EFETIVA')) == '1'
	_nOper := OPER_LIQUIDAR
EndIf

oFO0 := oModel:GetModel('MASTERFO0')
If lIncSim
	//adiciono numero de liquidação na efetivação pela inclusão ou alteração
	cNLiquid := F460NumLiq()
	oFO0:LoadValue( "FO0_NUMLIQ", cNLiquid )
EndIf

Return lVersao

//-------------------------------------------------------------------
/*/{Protheus.doc} F460LinOk
Rotina para acionar a validação da linha nos registros 
da tabela FO2.

@author Diego Santos
@since 12/11/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------

Function F460LinOk()

Local oModel	:= FWModelActive()
Local lRet := .T.
Local oModelFO2 := oModel:GetModel('TITGERFO2')

If AllTrim(oModelFO2:GetValue("FO2_TIPO")) == AllTrim(MVCHEQUE)
	If  Empty(oModelFO2:GetValue("FO2_NUMCH"))
		oModel:SetErrorMessage("",,oModel:GetId(),"","A460NUMCH","")
		lRet := .F.	
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F460VldFO1
Rotina para acionar a validação da grid dos títulos selecionados (FO1) 

@author Diego Santos
@since 16/11/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------

Function F460VldFO1(oModel)

Local oModelFO1 := oModel:GetModel('TITSELFO1')
Local oModelFO0	:= oModel:GetModel('MASTERFO0')
Local cFilTit	:= ""
Local cNumTit	:= ""
Local cPreTit	:= ""
Local cParcTit	:= ""
Local cTipoTit	:= ""
Local cChaveTit	:= ""
Local aChaveTit	:= {}
Local lRet      := .T.
Local nX        := 0
Local nTaxaFO1  := 0
Local nTaxaFO0  := Iif(lCpoTxMoed,oModelFO0:GetValue("FO0_TXMOED"),0)

If Type("__nOpcOuMo") = "U"
	__nOpcOuMo := 2
EndIf

For nX := 1 to oModelFO1:Length()
	oModelFO1:GoLine(nX)
	
	cFilTit		:= oModelFO1:GetValue("FO1_FILORI")
	cNumTit		:= oModelFO1:GetValue("FO1_NUM")
	cPreTit		:= oModelFO1:GetValue("FO1_PREFIX")
	cParcTit	:= oModelFO1:GetValue("FO1_PARCEL")
	cTipoTit	:= oModelFO1:GetValue("FO1_TIPO")
	nTaxaFO1    := oModelFO1:GetValue("FO1_TXMOED")
	
	If oModelFO1:GetValue("FO1_MARK")
		If __nOpcOuMo = 3 .And. (nTaxaFO0 <= 0 .Or. nTaxaFO1 <= 0)
			oModel:SetErrorMessage("",,oModel:GetId(),"","A460TXZERO",STR0180 ) //"Taxa da Moeda não pode ser menor ou igual a 0 (zero)."
			lRet := .F.
		Else
			SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If SE1->(DbSeek(cFilTit+cPreTit+cNumTit+cParcTit+cTipoTit))
			
				//----------------------------------------------------
				// Integracao Protheus x CorporeRM (GDP Educacional)
				//----------------------------------------------------
				If GetNewPar('MV_RMBIBLI',.F.) .and. AllTrim(Upper(SE1->E1_ORIGEM)) == 'L'		
					Aviso(OemToAnsi(STR0078),OemToAnsi(STR0079),{OemToAnsi(STR0080)}) //"Procedimento Inválido" //"Não é permitido liquidar/renegociar títulos nativos do RM Biblios" //"Voltar"
					lRet := .F.		
				EndIf
			
				//SERASA
				cChaveTit := SE1->(E1_FILORIG + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)
				AADD(aChaveTit,cChaveTit)
			EndIf
		EndIf
	EndIf
Next nX



Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A460Cheque
Rotina para preencher automaticamente os números de cheque da 
da tabela FO2. (Campo FO2_NUMCH)

@author Diego Santos
@since 16/11/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------

Function A460Cheque()

Local lRet 		:= .T.
Local oModel 	:= FWModelActive()
Local oModelFO2 := oModel:GetModel('TITGERFO2')
Local cBcoFO2	:= oModelFO2:GetValue("FO2_BANCO")
Local cAgFO2	:= oModelFO2:GetValue("FO2_AGENCI")
Local cCtaFO2	:= oModelFO2:GetValue("FO2_CONTA")
Local cCheque	:= oModelFO2:GetValue("FO2_NUMCH")
Local cBcoFO2nX	:= ""
Local cAgFO2nX	:= ""
Local cCtaFO2nX	:= ""
Local nLinAtu	:= oModelFO2:GetLine()
Local nX 		:= 1

If !Empty(cCheque) .and. AllTrim(oModelFO2:GetValue("FO2_TIPO")) == AllTrim(MVCHEQUE)
	For nX := 1 to oModelFO2:Length()
		If nX <> nLinAtu
			oModelFO2:GoLine(nX)
			If !oModelFO2:IsDeleted()				
				If oModelFO2:GetValue("FO2_NUMCH") == cCheque 
					cBcoFO2nX	:= oModelFO2:GetValue("FO2_BANCO")
					cAgFO2nX	:= oModelFO2:GetValue("FO2_AGENCI")
					cCtaFO2nX	:= oModelFO2:GetValue("FO2_CONTA")
					
					If (cBcoFO2nX + cAgFO2nX + cCtaFO2nX) == (cBcoFO2 + cAgFO2 + cCtaFO2)
						lRet := .F.
						Help(" ",1,"F460ACHQ",,STR0104, 1, 0) 	// "Não é possível digitar o mesmo número de cheque."				
						Exit
					Endif					
				EndIf 
			Endif
		EndIf		
	Next nX
EndIf
oModelFO2:GoLine(nLinAtu)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A460VerPc
Consiste numero de parcelas na Liquidação

@author Mauricio Pequim Jr
@since 17/04/2000
@version P12.1.8
/*/
//-------------------------------------------------------------------
Static Function A460VerPc(nContad,lNcc,cLiquid)

Local aAmbSE1   := {SE1->(Recno()),SE1->(Indexord())}
Local cOldAlias := Alias()
Local nTamParc  := TamSx3("E1_PARCELA")[1]
Local nTamMV1DUP := ""

cParc460   := Alltrim(GetNewPar("MV_1DUP","1"))
nTamMV1DUP := Len(cParc460)

If nTamParc > nTamMV1DUP
	cParc460 := cParc460 + SPACE( nTamParc-nTamMV1DUP )
ElseIf nTamParc < nTamMV1DUP
	cParc460 := Substr(cParc460,1,nTamParc)
EndIf

lNcc := Iif(lNcc == NIL, .F., lNcc)

//Verifico se existe o titulo no arquivo nao filtrado
//Este alias e aberto pela SomaAbat() sempre
DbSelectArea("__SE1")
DbSetOrder(1)

If cParc460 == "N"
	cParc460 := StrZero(1,TamSx3("E1_PARCELA")[1])
EndIf 

If lNcc
	While .T.
		If MsSeek(xFilial("SE1")+"LIQ"+cLiquid+cParc460+MV_CRNEG)
			cParc460 := Soma1(cParc460)
		Else			
			Exit				
		EndIf
	End
Else
	While .T.
		If MsSeek(xFilial("SE1")+Padr(aCols[nContad,1],TamSX3("E1_PREFIXO")[1])+Padr(aCols[nContad,6],TamSX3("E1_NUM")[1])+Padr(cParc460,TamSX3("E1_PARCELA")[1])+Padr(aCols[nContad,2],TamSX3("E1_TIPO")[1]))
			cParc460 := Soma1(cParc460)
		Else			
			Exit				
		EndIf
	End
EndIf

DbSetOrder(aAmbSE1[2])
DbGoTo(aAmbSE1[1])
DbSelectArea(cOldAlias)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F460AcrDcr
Consiste numero de parcelas na Liquidação

@author Mauricio Pequim Jr
@since 12/01/2016
@version P12.1.8
/*/
//-------------------------------------------------------------------
Function F460AcrDcr(oModel,cCampo, xValue, nLine,xOldValue,xRet)

Local nTotal	:= 0 
Local oModelPai := oModel:GetModel('TITGERFO2')		//Model Completo
Local oModelFO0 := oModelPai:GetModel("MASTERFO0")
Local lRet		:= .T.

If xValue < 0
	oModelPai:SetErrorMessage("",,oModelPai:GetId(),"","F460VLNEG",STR0093)	//"Não são permitidos valores negativos para esse campo. Por favor, informe um valor válido."
	lRet := .F.
Endif

If oModel:GetValue("FO2_DECRES") > 0 .and. oModel:GetValue("FO2_ACRESC") > 0
	oModelPai:SetErrorMessage("",,oModelPai:GetId(),"","F460ACDC",STR0096)	//"Não é permitido informar Acréscimos e Decréscimos para uma mesma parcela. Por favor, Verifique."
	lRet := .F.
Endif

If lRet
	nOldTotal := oModel:GetValue("FO2_TOTAL")
	If cCampo == "FO2_ACRESC"
		nTotal := nOldTotal + xValue - xOldValue
	ElseIf ccampo == "FO2_DECRES"
		nTotal := nOldTotal - xValue + xOldValue
		If nTotal <= 0
			oModelPai:SetErrorMessage("",,oModelPai:GetId(),"","F460VLNEG",STR0094)	//"Valor inválido para a parcela. Por favor, verifique."
			lRet := .F.
		Endif
	Endif
	
Endif

If lRet
	oModel:LoadValue("FO2_TOTAL", nTotal)
	nTotLiq := oModelFO0:GetValue("FO0_VLRNEG") - nOldTotal + nTotal
	oModelFO0:LoadValue("FO0_VLRNEG",nTotLiq)
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F460Valor
Validação do campo F02_VALOR

@author Mauricio Pequim Jr
@since 12/01/2016
@version P12.1.8
/*/
//-------------------------------------------------------------------
Function F460Valor(oModel,cField, xValue,nLine,xOldValue)

Local oModelAct := FWModelActive()	//Model Completo
Local lRet 		:= .T.

If xValue > 0
	F460JurMul(oModelAct,"FO2_TXJUR")
	F460CalJur(oModel,,4)
Else
	lRet := .F.
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F460TxJur
Validação do campo FO2_TXJUR

@author Mauricio Pequim Jr
@since 12/01/2016
@version P12.1.8
/*/
//-------------------------------------------------------------------
Function F460TxJur(oModel,cField, xValue,nLine,xOldValue)

Local nTxJuros	:= oModel:GetModel("MASTERFO0"):GetValue('MASTERFO0','FO0_TXJRG')

Return nTxJuros

//-------------------------------------------------------------------
/*/{Protheus.doc} F460Desco
Validação do campo FO1_DESCON

@author Mauricio Pequim Jr
@since 12/01/2016
@version P12.1.8
/*/
//-------------------------------------------------------------------
Function F460Desco(oModel,cCampo, xValue, nLine,xOldValue)

Local lRet := .T.
Local nValTot := oModel:GetValue("FO1_TOTAL") 
Local oModelPai := FWModelActive()	//Model Completo

If xValue >= 0
	If xValue >= nValTot
		oModelPai:SetErrorMessage("",,oModelPai:GetId(),"","F460VLDSC",STR0094)	//"Valor inválido para a parcela. Por favor, verifique."	
		lRet := .F.
	Endif
Else
	oModelPai:SetErrorMessage("",,oModelPai:GetId(),"","F460VLDCN",STR0099)	//"Valor inválido para desconto. Por favor, verifique."
	lRet := .F.		
Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} F460TxMoed
Tratamento para edição do campo FO1_TXMOED

@author Simone Mie Sato Kakinoana
@since 23/06/2016
@version P12.1.12
/*/
//-------------------------------------------------------------------
Function F460TxMoed(oModel,cCampo, xValue, nLine,xOldValue)

Local lRet			:= .T.
Local nMoedaFO1		:= oModel:GetValue("FO1_MOEDA")

If nMoedaFO1 == nMoeda
	lRet	:= .F. 	
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} F460AtMoed
Tratamento para atualização dos campos a partir do  FO1_TXMOED

@author Simone Mie Sato Kakinoana
@since 23/06/2016
@version P12.1.12
/*/
//-------------------------------------------------------------------
Function F460AtMoed(oModel,cField,xValue,nLine,xOldValue)

Local aSvLines	:= FWSaveRows()

Local oModel		:= FWModelActive()
Local oView 		:= FWViewActive()

Local oSubFO0		:= oModel:GetModel("MASTERFO0")
Local oSubFO1		:= oModel:GetModel("TITSELFO1")
Local oSubFO2		:= oModel:GetModel("TITGERFO2")

Local nX			:= 0 
Local nValOrig		:= oSubFO1:GetValue("FO1_SALDO")
Local nTxMoeda		:= oSubFO1:GetValue("FO1_TXMOED")
Local nMoedTit		:= oSubFO1:GetValue("FO1_MOEDA")
Local nMoedProc		:= oSubFO0:GetValue("FO0_MOEDA")
Local nAbat			:= oSubFO1:GetValue("FO1_VLABT")
Local nDescon		:= oSubFO1:GetValue("FO1_DESCON")
Local nMulta		:= oSubFO1:GetValue("FO1_VLMUL") 
Local nJuros		:= oSubFO1:GetValue("FO1_VLJUR") 
Local nAcresc		:= oSubFO1:GetValue("FO1_ACRESC")
Local nDecres		:= oSubFO1:GetValue("FO1_DECRES")
Local nVA   		:= oSubFO1:GetValue("FO1_VACESS")
Local nValBxd		:= 0 	
Local nTotal		:= 0 	
Local nValCvt		:= 0
Local nLinAtu		:= 0 
Local nTotLiq		:= 0
Local nLenFO2		:= 0
Local nTtlFO2		:= 0
Local nTtlNeg		:= 0
Local nTxMoeDia		:= 0
Local lRet			:= .T.
Local lUsaMark		:= (FwIsInCallStack("F460AIncl") .Or. FwIsInCallStack("A460Liquid"))

If oSubFO1:GetValue("FO1_MOEDA") == 1
	nTxMoeDia := 1
	If oSubFO1:GetValue("FO1_TXMOED") == 1
		nTxMoeda  := RecMoeda(dDataBase, oSubFO0:GetValue("FO0_MOEDA"))
	Else
		nTxMoeda  := oSubFO1:GetValue("FO1_TXMOED")
	Endif
	nValCvt := Round(NoRound(xMoeda(nValOrig, nMoedTit, nMoedProc, dDataBase, 3, nTxMoeDia, nTxMoeda ), 3), 2)
	nTotal	:= Round(NoRound(xMoeda(nValOrig-nAbat-nValBxd-nDescon+nMulta+nJuros+nAcresc-nDecres+nVA, nMoedTit, nMoedProc, dDataBase, 3, nTxMoeDia, nTxMoeda  ), 3), 2)
Else
	If oSubFO1:GetValue("FO1_TXMOED") = RecMoeda(dDataBase, oSubFO1:GetValue("FO1_MOEDA") )
		nValCvt := Round(NoRound(xMoeda(nValOrig, nMoedTit, nMoedProc, dDataBase, 3, nTxMoeda , nTxMoeDia ), 3), 2)
		nTotal	:= Round(NoRound(xMoeda(nValOrig-nAbat-nValBxd-nDescon+nMulta+nJuros+nAcresc-nDecres+nVA, nMoedTit, nMoedProc, dDataBase, 3, nTxMoeda, nTxMoeDia  ), 3), 2)
	Else
		nTxMoeDia := RecMoeda(dDataBase, oSubFO0:GetValue("FO0_MOEDA") )
		nValCvt := Round(NoRound(xMoeda(nValOrig, nMoedTit, nMoedProc, dDataBase, 3, nTxMoeda, nTxMoeDia  ), 3), 2)
		nTotal	:= Round(NoRound(xMoeda(nValOrig-nAbat-nValBxd-nDescon+nMulta+nJuros+nAcresc-nDecres+nVA, nMoedTit, nMoedProc, dDataBase, 3, nTxMoeda, nTxMoeDia  ), 3), 2)
	Endif
Endif

oSubFO1:LoadValue("FO1_TOTAL",nTotal)
oSubFO1:LoadValue("FO1_VALCVT",nValCvt)

nLinAtu	:= oSubFO1:GetLine()
For nX := 1 To oSubFO1:Length() 
	oSubFO1:Goline(nX)
	If oSubFO1:GetValue("FO1_MARK") .or. !lUsaMark
		nTotLiq += oSubFO1:GetValue("FO1_VALCVT")
	Endif
Next	

nLenFO2 := oSubFO2:Length()
	
If nLenFO2 > 0 
	nTtlFO2 := Round(nTotLiq / nLenFO2, 2)
	For nX := 1 To nLenFO2
		oSubFO2:Goline(nX)
		If !oSubFO2:IsDeleted()
			nTtlNeg += nTtlFO2
			oSubFO2:LoadValue("FO2_VALOR" , nTtlFO2 )
			oSubFO2:LoadValue("FO2_TOTAL" , nTtlFO2 )
			oSubFO2:LoadValue("FO2_VLPARC", nTtlFO2 )
			oSubFO0:LoadValue("FO0_VLRNEG", nTtlNeg )
		Endif
	Next nX
	
	If lCpoTxMoed
		oSubFO0:LoadValue("FO0_TXMOED", 0)
	Endif
Endif

oSubFO1:GoLine(nLinAtu)
oSubFO2:Goline(1)
oSubFO0:LoadValue("FO0_VLRLIQ", nTotLiq)
oView:Refresh()

FWRestRows( aSvLines )

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} FiLF00Cond
Utilizado na consulta padrão do campo F00_COND. Chama a função de filtro 
TkFilCndPg.

@author Simone Mie Sato Kakinoana
@since 04/07/2016
@version P12.1.13
/*/
//-------------------------------------------------------------------
Function FiLF00Cond()
Local cRetFiltro  := "@# @#"

Return cRetFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} FO2LinPre
Tratamento para atualizar o cabeçalho.

@author Simone Mie Sato Kakinoana
@since 28/06/2016
@version P12.1.12
/*/
//-------------------------------------------------------------------
Function FO2LINPRE(oModel,nLine,cAction,cField)

Local aSvLines		:= FWSaveRows()
Local lRet    		:= .T.
Local oModel		:= FWModelActive()
Local oSubFO0		:= oModel:GetModel("MASTERFO0")
Local oSubFO2		:= oModel:GetModel("TITGERFO2")
Local nTotGera		:= oSubFO0:GetValue("FO0_VLRNEG")

If cAction $ "DELETE|UNDELETE"
	If cAction == 'DELETE'
		nTotGera -= oSubFO2:GetValue("FO2_TOTAL")
	ElseIf cAction == 'UNDELETE' 
		nTotGera += oSubFO2:GetValue("FO2_TOTAL")
	Endif
	
	oSubFO0:LoadValue("FO0_VLRNEG", nTotGera) 
EndIf

FWRestRows( aSvLines )	

Return lRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} Fa460VA
Função de inclusão de valores acessórios para titulos CR

@author Simone Mie Sato kakinoana
@since 13/10/2016
@version 1.0

@return lRet	se o processo foi concluido com sucesso
/*/
//-------------------------------------------------------------------
Function Fa460VA(lVAAuto,oModel)

Local oModelVA		:= NIL
Local oSubFKD		:= NIL	 
Local cChave		:= ""
Local cIdDoc		:= ""
Local cLog			:= ""
Local lRet			:= .T.
Local nX			:= 0
Local nTamCod		:= TamSx3("FKD_CODIGO")[1]
Local cProcess		:= oModel:GetModel("MASTERFO0"):GetValue("FO0_PROCES")

DEFAULT lVAAuto	:= .F.

If lVAAuto
	//Rotina Automática para VA	
	oModelVA := FWLoadModel('FINA460VA')
	oModelVA:SetOperation( 4 ) //Alteração
	oModelVA:Activate()

	oSubFKD := oModelVA:GetModel('FKDDETAIL')
	
	cChave := xFilial("SE1",SE1->E1_FILORIG) +"|"+ SE1->E1_PREFIXO +"|"+ SE1->E1_NUM +"|"+ SE1->E1_PARCELA +"|"+ SE1->E1_TIPO +"|"+ SE1->E1_CLIENTE +"|"+ SE1->E1_LOJA
	cIdDoc := FINGRVFK7( 'SE1', cChave )
	oModelVA:LoadValue("FK7DETAIL","FK7_IDDOC", cIdDoc )
	
	For nX := 1 to Len(aVAAuto)
		If !oSubFKD:IsEmpty()
			oSubFKD:AddLine()
		EndIf
		oSubFKD:SetValue("FKD_CODIGO"	, Padr(aVAAuto[nX,1],nTamCod) )
		oSubFKD:SetValue("FKD_VALOR"	, aVAAuto[nX,2] )
	Next

	If oModelVA:VldData()
		FWFormCommit( oModelVA )
	Else
		lRet	 := .F.
		cLog := cValToChar(oModelVA:GetErrorMessage()[4]) + ' - '
		cLog += cValToChar(oModelVA:GetErrorMessage()[5]) + ' - '
		cLog += cValToChar(oModelVA:GetErrorMessage()[6])        	
		Help( ,,"F040VALAC",,cLog, 1, 0 )
	Endif
	oModelVA:Deactivate()
	oModelVA:Destroy()
	oModelVA := NIL
Else
	FINA460VA(cProcess)
Endif	

Return lRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} F460Botao
Função para inclusão do botão Marcar/Desmarcar todos os titulos

@author Ana Paula Nascimento
@since 21/01/2017
@version 1.0

@return 
/*/
//-------------------------------------------------------------------

Function F460Botao(oPanel, oView, oModel)
	Local oButton	:= Nil
	Local oRadio	:= Nil
	Local nRadio	:= 1
	Local aObjCoords := {}
	
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4], 0, 0 }
	aAdd( aObjCoords , { 100 , 100 , .T. , .F. } )	
	aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )
	
	If Empty(MV_PAR09) .Or. MV_PAR09 = 1
		@14,(aObjSize[1,4] / 2 - 120) Radio oRadio VAR nRadio ITEMS STR0129,STR0130 3D SIZE 100,10 OF oPanel PIXEL			//"Marcar todos os títulos"###"Desmarcar todos os títulos"
		@17,(aObjSize[1,4] / 2 - 55) BUTTON oButton PROMPT STR0131  SIZE 80,10 FONT oPanel:oFont ACTION MsgRun(STR0132,STR0133,{|| F460AMarca(oView,oModel,nRadio)}) OF oPanel PIXEL     //"Executar"###"Marca / Desmarca todos os títulos"###"Títulos"
	Else
		@00,(aObjSize[1,4] / 2 - 120) Radio oRadio VAR nRadio ITEMS STR0129,STR0130 3D SIZE 100,10 OF oPanel PIXEL			//"Marcar todos os títulos"###"Desmarcar todos os títulos"
		@05,(aObjSize[1,4] / 2 - 55) BUTTON oButton PROMPT STR0131  SIZE 80,10 FONT oPanel:oFont ACTION MsgRun(STR0132,STR0133,{|| F460AMarca(oView,oModel,nRadio)}) OF oPanel PIXEL     //"Executar"###"Marca / Desmarca todos os títulos"###"Títulos"
	Endif 

Return()


//-------------------------------------------------------------------
/*/ {Protheus.doc} F460AMarca
Função validar/marcar todos os titulos

@author Ana Paula Nascimento
@since 21/01/2017
@version 1.0

Alterado por Francisco Oliveira em 11/07/2019

@return 
/*/
//-------------------------------------------------------------------

Function F460AMarca(oView,oModel,nAcao)

Local oView    	:= FwViewActive()
Local oModel   	:= FWModelActive()
Local nQtdFil   := Len(oView:GetViewObj("VIEW_FO1")[3]:GetFilLines()) //Se existe filtro ativo na FO1 esse array contem apenas os numeros das linhas que estão exibidas

If FwIsInCallStack("F460ABlqCan")
	Help(" ",1,"SIMULBLQ",, STR0199, 1, 0) // "Para o Bloqueio / Desbloqueio de Simulação não é possivel o uso da rotina de Marcar / Desmarcar. "
	Return
Endif

If nAcao == 1
	cTextProc := STR0195 //"Marcação dos "
Else
	cTextProc := STR0196 //"Desmarcação dos "
Endif

Processa({|| F460MrkNew(oView, oModel, nAcao, __lNExbMsg)}, STR0182 + cTextProc + Alltrim(Str(nQtdFil)) + STR0183 ) //Processando a marcação dos titulos filtrados....

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FO2LinPos
Tratamento LINHAOK

@author Ana Paula N Silva
@since 06/06/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function FO2LINPOS(oModel,nLine)

	Local lRet    	:= .T.	
	Local cEscrit   := ""
	Local cBanco    := ""
	Local cAgencia  := ""
	Local cConta    := ""
	
	If lRet .And. lJFilBco()
		cEscrit   := JurGetDados("NS7", 4, xFilial("NS7") + cFilant + cEmpAnt, "NS7_COD")
		cBanco    := oModel:GetValue('FO2_BANCO')
		cAgencia  := oModel:GetValue('FO2_AGENCI')
		cConta    := oModel:GetValue('FO2_CONTA')
		lRet      := Empty(cBanco + cAgencia + cConta) .Or. JurVldSA6("3", {cEscrit, cBanco, cAgencia, cConta})
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F460IRRF
Tratamento Calculo de IRRF

@author Francisco Oliveira
@since 10/12/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function F460IRRF(nBaseIrrf)

Local aArea		:= GetArea()
Local cQuery	:= ""
Local lBaseImp	:= F040BSIMP(2)
Local lIrPjBxCr	:= FIrPjBxCr()
Local lAplMinIr	:= .F.
Local lVRetIrf	:= .T.	//Controle de retencao de valores pendentes 
Local lIrfRetAnt:= .T.	//Controle de retencao anterior no mesmo periodo
Local nAliqIRRF	:= 0
Local nTotTit	:= 0
Local nTotIrrf	:= 0
Local nTotRtIr	:= 0
Local nRecIRRF	:= 0
Local nValor 	:= 0
Local nVlrBCalc := 0
Local cSepNeg   := If("|"$MV_CRNEG,"|",",")
Local cSepProv  := If("|"$MVPROVIS,"|",",")
Local cSepRec   := If("|"$MVRECANT,"|",",")
Local cAcmIrrf 	:= SuperGetMv("MV_ACMIRCR", .T.,"1")  //1 = Acumula 2= Não acumula o imposto IRRF.
Local nMinIrrf 	:= SuperGetMV("MV_VLRETIR", .F., 10)

Local lRaRtImp	:= FRaRtImp()

DEFAULT nBaseIrrf 	:= 0

// Verifica se o CLIENTE trata o valor minimo de retencao.
// 1- Não considera 	 2- Considera o parâmetro MV_VLRETIR
If cPaisLoc == "BRA" .and. SA1->A1_MINIRF == "2"
	lAplMinIR := .T.
Endif	

// Prioridade de Acesso à alíquota de IRRF:
// 1 - Cadastro Cliente;
// 2 - Cadastro da Natureza Associada ao título;
// 3 - Parâmetro do Sistema MV_ALIQIRF
If !Empty( nAliqIRRF := Posicione('SA1',1,XFilial('SA1') + SE1->E1_CLIENTE + SE1->E1_LOJA,'A1_ALIQIR') )
ElseIf	!Empty( nAliqIRRF := SED->ED_PERCIRF )
Else
	nAliqIRRF := GetMV("MV_ALIQIRF")
EndIf
	
// Pessoa juridica totaliza os titulos emitidos no dia para calculo do imposto
If lVRetIrf
	cQuery := "SELECT DISTINCT E1_VALOR TotTit, E1_VRETIRF VRetIrf, E1_IRRF TotIrrf, "
	cQuery += "E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA, "
	cQuery += "E1_EMISSAO,E1_NATUREZ "		
Else	
	cQuery := "SELECT DISTINCT E1_VALOR TotTit,E1_IRRF TotIrrf,"
	cQuery += "E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA, "
	cQuery += "E1_EMISSAO,E1_NATUREZ "
Endif
	
//639.04 Base Impostos diferenciada
If lBaseImp
	cQuery += ",E1_BASEIRF TotBaseIrf "
Endif
			
If cPaisLoc == "BRA"
	//SED->ED_RECIRRF - Natureza (Indica como será feito o recolhimento do IRRF)
	cQuery += ",SED.ED_RECIRRF RECIRRF "
EndIf
	
cQuery += "FROM " + RetSQLname("SE1") + " SE1, " 	
cQuery +=           RetSQLname("SED") + " SED "
cQuery += " WHERE "
	
If lVretIrf
	//Se verifica base apenas na filial corrente e fornecedor corrente 
	cQuery += "SE1.E1_FILIAL  = '" + xFilial("SE1") + "' AND "
	cQuery += "SE1.E1_CLIENTE = '" + SA1->A1_COD    + "' AND "
	cQuery += "SE1.E1_LOJA    = '" + SA1->A1_LOJA   + "' AND "
Else
	cQuery += "SE1.E1_FILIAL  = '" + xFilial("SE1") + "' AND "
	cQuery += "SE1.E1_CLIENTE = '" + SA1->A1_COD    + "' AND "
	cQuery += "SE1.E1_LOJA    = '" + SA1->A1_LOJA   + "' AND "
Endif
		
cQuery += "SE1.E1_EMISSAO  = '" + Dtos(SE1->E1_EMISSAO) + "' AND " // De acordo com JIRA, dispensa e cumulatividade de IR PJ deverá ser ao dia e nao ao mes.
cQuery += "SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "
cQuery += "SE1.E1_TIPO NOT IN " + FormatIn(MV_CRNEG,cSepNeg)  + " AND "
cQuery += "SE1.E1_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
If !lRaRtImp 
	cQuery += "SE1.E1_TIPO NOT IN " + FormatIn(MVRECANT,cSepRec)  + " AND "  
EndIf
cQuery += "SE1.D_E_L_E_T_ = ' ' AND "
		
//Verifico a filial do SED
cQuery += "SED.ED_FILIAL  = '"+ xFilial("SED") + "' AND "
cQuery += "SE1.E1_NATUREZ = SED.ED_CODIGO AND "  
cQuery += "SED.ED_CALCIRF = 'S' AND "                                                                 
		
cQuery += "SED.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBIRF", .F., .T.)
TCSetField('TRBIRF', "TOTTIT", "N",17,2)
TCSetField('TRBIRF', "TOTIRRF", "N",17,2)

If lVRetIrf		
	TCSetField('TRBIRF', "VRETIRF", "N",17,2)		
Endif 
	
//639.04 Base Impostos diferenciada
If lBaseImp
	TCSetField('TRBIRF', "TOTBASEIRF", "N",17,2)		
Endif
	
dbSelectArea("TRBIRF")
While !(TRBIRF->(Eof()))
			
	// Se alteracao e a chave do titulo em memoria eh a mesma da query, desconsidera o titulo para evitar duplicidade na base de irrf
	If 	xFilial("SE1") + SE1->( E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA ) == ;
		TRBIRF->( E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA )
		TRBIRF->(dbSkip())
		Loop
	EndIf
			
	//639.04 Base Impostos diferenciada
	If lBaseImp .and. TRBIRF->TOTBASEIRF > 0
		nTotTit	+= TRBIRF->TOTBASEIRF				
	Else	
		nTotTit	+= TRBIRF->TOTTIT
	Endif
					
	nTotIrrf	+= If(lIrPjBxCr,TRBIRF->VRETIRF,TRBIRF->TOTIRRF)
					
	If lVRetIrf
		nTotRtIr += TRBIRF->VRETIRF
		If cPaisLoc == "BRA" .And. TRBIRF->RECIRRF == "2"
			nRecIRRF += TRBIRF->VRetIrf
		EndIf
	Endif
		
	TRBIRF->(dbSkip())
Enddo

//Fecha arquivo temporario e exclui do banco	
TRBIRF->(dbCloseArea())

If (nTotTit * nAliqIRRF / 100) < nMinIrrf
	nVlrBCalc := (nTotTit + nBaseIrrf) * nAliqIRRF / 100
	If nVlrBCalc <= nMinIrrf
		lIrfRetAnt := .F.
	Endif
Else
	nVlrBCalc := nBaseIrrf * nAliqIRRF / 100
	lIrfRetAnt := .T.
Endif

dbSelectArea("SE1")

//Calculo o IRRF devido
If !GetNewPar("MV_RNDIRRF",.F.)
	nValor := NoRound(xMoeda(nVlrBCalc, SE1->E1_MOEDA, 1, SE1->E1_EMISSAO, 3, SE1->E1_TXMOEDA) ,2)
Else
	nValor := Round(xMoeda(nVlrBCalc, SE1->E1_MOEDA, 1, SE1->E1_EMISSAO, 3, SE1->E1_TXMOEDA) ,2)
Endif
	
//Recolhimento do IRRF - Emitente
If cPaisLoc == "BRA" .And. ( SED->ED_RECIRRF == "2" .OR. ( SA1->A1_RECIRRF == "2" .AND. (SED->ED_RECIRRF == "3" .OR. SED->ED_RECIRRF == " ") ) )
	nRecIRRF += nValor
EndIf
	
RestArea(aArea)
	
//Controle de retencao anterior no mesmo periodo
//lIrfRetAnt := IIF(nValor > nMinIrrf, .T., .F.)
	
If cAcmIrrf == "2" .And. lAplMinIr .And. nValor <= nMinIrrf 
	nValor := 0
	nRecIRRF := 0
	SE1->E1_VRETIRF := 0
ElseIf !lIrfRetAnt
	nValor := 0
	nRecIRRF := 0
EndIf
		
// Titulos Provisorios ou Antecipados nao geram IR        	  
If SE1->E1_TIPO $ MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM 
	If !(lRaRtImp .and. lIrPjBxCr .and. SE1->E1_TIPO == MVRECANT)
		nValor := 0
		nRecIRRF := 0
		SE1->E1_VRETIRF	:= 0
	EndIf
EndIf

RestArea(aArea)

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} F460VldE1
Função para verificação de duplicidade de SE1

@author Francisco Oliveira
@since 25/01/2019
@version P12.1.17
/*/
//-------------------------------------------------------------------

Function F460VldE1(cPrefSE1, cNumSE1, cParcSE1, cTipoSE1, nPorcJur, cMaxParc)

	Local cQuery	 := ""
	Local cAlsTemp	 := GetNextAlias()
	Local lRet		 := .T.

	Default cPrefSE1 := ""
	Default cNumSE1  := ""
	Default cParcSE1 := ""
	Default cTipoSE1 := ""
	Default nPorcJur := 0
	Default cMaxParc := " "

	// E1_VALJUR - TAXA DE PERMANENCIA
	// E1_PORCJUR - PERCENTUAL DE JUROS = FO1_TXJUR
	
	if __oStVldE1 == NIL
		cQuery := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VALJUR, E1_PORCJUR "
		cQuery += " FROM " + RetSqlName("SE1") + " SE1 " 
		cQuery += " WHERE "
		cQuery += " E1_FILIAL = ? AND "
		cQuery += " E1_PREFIXO = ? AND "
		cQuery += " E1_NUM = ? AND " 
		cQuery += " E1_PARCELA = ? AND "
		cQuery += " E1_TIPO = ? AND "
		cQuery += " D_E_L_E_T_ = ' ' "
		__oStVldE1 := FWPreparedStatement():New(cQuery)
	endIf

	__oStVldE1:setString(1, xFilial("SE1"))
	__oStVldE1:setString(2, cPrefSE1)
	__oStVldE1:setString(3, cNumSE1)
	__oStVldE1:setString(4, cParcSE1)
	__oStVldE1:setString(5, cTipoSE1)
	cQuery := __oStVldE1:getFixQuery()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlsTemp, .F., .T.)

	If (cAlsTemp)->(Eof()) .And. (cAlsTemp)->(Bof())
		lRet := .F.
	Else
		nPorcJur := (cAlsTemp)->E1_PORCJUR
	Endif

	(cAlsTemp)->(DbCloseArea())

	If lRet
		cAlsTemp := GetNextAlias()

		if __oStE1Par == NIL
			cQuery := " SELECT MAX(E1_PARCELA) AS MaxParc "
			cQuery += " FROM " + RetSqlName("SE1") + " SE1 " 
			cQuery += " WHERE "
			cQuery += " E1_FILIAL  = ? AND "
			cQuery += " E1_PREFIXO = ? AND "
			cQuery += " E1_NUM     = ? AND " 
			cQuery += " E1_TIPO    = ? AND "
			cQuery += " D_E_L_E_T_ = ' ' "
			__oStE1Par := FWPreparedStatement():New(cQuery)
		endIf

		__oStE1Par:setString(1, xFilial("SE1"))
		__oStE1Par:setString(2, cPrefSE1)
		__oStE1Par:setString(3, cNumSE1)
		__oStE1Par:setString(4, cTipoSE1)
		cQuery := __oStE1Par:getFixQuery()
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlsTemp, .F., .T.)

		cMaxParc := Soma1((cAlsTemp)->MaxParc)

		(cAlsTemp)->(DbCloseArea())
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F460When
Função para retorno do WHEN de campos da FO0. 
Fecha os campos se houver registros marcados na FO1 e existindo registros na FO2
@author Luis Felipe Geraldo
@since 25/03/2019
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function F460When(oModel)

Local oWhenFO0
Local oWhenFO1
Local oWhenFO2
Local lRet    := .T.
Local lTemFO1 := .F.
Local lTemFO2 := .F.
Local nX      := 0
Local nQtdFO1 := 0
Local nQtdFO2 := 0
Local nLinAtu := 0
Local nTotNeg := 0

If Valtype(oModel) == "O"
	
	oWhenFO0 := oModel:GetModel("MASTERFO0")
	oWhenFO1 := oModel:GetModel("TITSELFO1")
	oWhenFO2 := oModel:GetModel("TITGERFO2")
	nTotNeg  := oWhenFO0:GetValue("FO0_VLRNEG")
	nQtdFO1  := oWhenFO1:Length()
	nQtdFO2  := oWhenFO2:Length()
	nLinAtu  := oWhenFO1:GetLine()
	
	For nX:=1 To nQtdFO1
		oWhenFO1:GoLine(nX)
		If oWhenFO1:GetValue("FO1_MARK")
			lTemFO1 := .T.
            If oWhenFO0:GetValue("FO0_VLRLIQ") > nTotNeg
				nTotNeg += oWhenFO0:GetValue("FO0_VLRLIQ")
			EndIf
			If nQtdFO2 > 0
				lTemFO2 := .T.
			EndIf
		EndIf
	Next
	
	If lTemFO1 .And. lTemFO2 .And. nTotNeg > 0
		lRet := .F.
	EndIf

	oWhenFO1:GoLine(nLinAtu)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F460GerVM
Função que gera o movimento na SE5 e FKs para variação monetária da liquidação. 

@author Luis Felipe Geraldo
@since 28/03/2019
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function F460GerVM(nRecSE1,nRecSE5,nTxFO1,cNroLiq,nCodMoe)

	Local aAreaAtu as array
	Local aAreaSE1 as array
	Local aAreaSE5 as array
	Local lMostraLan as logical

	aAreaAtu := GetArea()
	aAreaSE1 := SE1->(GetArea())
	aAreaSE5 := SE5->(GetArea())
	lMostraLan := (mv_par02 == 1)

	SE1->(dbGoTo(nRecSE1))
	SE5->(dbGoTo(nRecSE5))

	FINA350(.T., .T., nTxFO1, cNroLiq, nCodMoe, lMostraLan)

	Pergunte("AFI460",.F.)

	RestArea(aAreaSE1)
	RestArea(aAreaSE5)
	RestArea(aAreaAtu)

Return

/*/{Protheus.doc} lJFilBco
Indica se filtra as contas correntes vinculadas ao escritório logado - SIGAPFS
@author  Guilherme de Sordi
@since   28/01/2022
@version 1.0
/*/
static function lJFilBco() as logical
	if __lJFilBco == NIL
		__lJFilBco  := ExistFunc("JurVldSA6") .And. SuperGetMv("MV_JFILBCO", .F., .F.)
	endIf
return __lJFilBco

/*/{Protheus.doc} lGrvSEF
Conteúdo do parâmetro MV_GRSEFLQ
@author  Guilherme de Sordi
@since   28/01/2022
@version 1.0
/*/
static function lGrvSEF() as logical
	if __lGrvSEF == NIL
		__lGrvSEF := SuperGetMv("MV_GRSEFLQ",,.F.)  
	endIf
return __lGrvSEF
