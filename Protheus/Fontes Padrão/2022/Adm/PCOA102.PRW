#INCLUDE "PCOA102.ch"
#Include "Protheus.ch"

STATIC oPCO_CO
STATIC oPMSUSER
Static _oPCOA1021
//amarracao para subida na main

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA102   บAutor  ณPaulo Carnelossi    บ Data ณ  16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para copiar outra planilha ou conta para a planilha  บฑฑ
ฑฑบ          ณatual                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA102(cPlanOri, cRevOri, cCtaOri, aPeriodo)
Local oWizard
Local cArquivo
Local aAreaAK1 := AK1->(GetArea())
Local aAreaAK2 := AK2->(GetArea())
Local aAreaAK3 := AK3->(GetArea())
Local aAreaAKE := AKE->(GetArea())
Local lRet 		:= .F.
Local lParam, lBrowse:=.T., lParam2
Local aParametros := {			{ 1 ,STR0001,Replicate(" ",LEN(AK1->AK1_CODIGO)) ,"@!" 	 ,"(M->AKR_ORCAME:=MV_PAR01, .T.)"  ,"AK1" ,"" ,65 ,.T. }, ; //"Planilha Or็amentแria"
								{ 1 ,STR0002,Replicate(" ",LEN(AKE->AKE_REVISA)) ,"@!" 	 ,""  ,"AKE1" ,"" ,65 ,.T. }, ;
								{ 3 ,STR0035, 2 ,{STR0036, STR0037},160,,.F.} } //"Considerar Valores da Planilha "##"Considera valores dos periodos da planilha a ser copiada"##"Considera somente se periodos estao dentro do exercicio"

Local aConfig := {Replicate(" ",LEN(AK1->AK1_CODIGO)),Replicate(" ",LEN(AKE->AKE_REVISA)), 2}

Local aParam2 :={ 	{3,STR0003, 3,{STR0004, STR0028, STR0005, STR0006},160,,.F.} } //"Parametros para C๓pia"###"Planilha "###"Somente Conta Posicionada + Itens"###"Somente Itens da Conta Posicionada" //"Conta + Dependencias"
Local aConfig2 := {3}
Local aPerAux  := {}

PRIVATE aAuxCps
PRIVATE cRevisa
PRIVATE cPlanAnt := ""
PRIVATE cCtaOrc := ""

DEFAULT cPlanOri 	:= AK1->AK1_CODIGO
DEFAULT cRevOri 	:= IF(Empty(AK1->AK1_VERREV), AK1->AK1_VERSAO, AK1->AK1_VERREV)
DEFAULT cCtaOri 	:= AK3->AK3_CO
DEFAULT aPeriodo 	:= PcoRetPer()

//nao retirar estas linhas atribuindo mv_par pois sao utilizadas na ParamOK()
mv_par01 := Replicate(" ",LEN(AK1->AK1_CODIGO))
mv_par02 := Replicate(" ",LEN(AKE->AKE_REVISA))

dbSelectArea("AK3")
dbSeek(xFilial("AK3")+cPlanOri+cRevOri+cPlanOri)

oWizard := APWizard():New(STR0034/*<chTitle>*/,; //"Atencao"
									STR0007/*<chMsg>*/, STR0008/*<cTitle>*/, ; //"Este assistente lhe ajudara a copiar um or็amento existente para a planilha atual."###"C๓piar Or็amento"
									STR0009/*<cText>*/,; //"Voce devera escolher o or็amento e ao finalizar o assistente, este serแ copiado conforme os parametros solicitados."
									{||.T.}/*<bNext>*/, ;
									{|| .T.}/*<bFinish>*/,;
									/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)

oWizard:NewPanel( STR0001/*<chTitle>*/,; //"Planilha Or็amentแria"
						 STR0010/*<chMsg>*/, ; //"Neste passo voce deverแ informar o c๓digo e a versao da planilha or็amentaria."
						 {||.T.}/*<bBack>*/, ;
						 {||ParamOk(aParametros, aConfig) .And. A102ChkPlan(aConfig, @lBrowse, cPlanOri, cRevOri) .And. A102Periodo(aPeriodo, aConfig, aPerAux) }/*<bNext>*/, ;
						 {||.T.}/*<bFinish>*/,;
						 .T./*<.lPanel.>*/,;
						 {||A102Plan_Box(oWizard,@lParam, aParametros, aConfig)}/*<bExecute>*/ )
					  
oWizard:NewPanel( STR0011/*<chTitle>*/,;  //"Conta Or็amentแria"
						STR0029/*<chMsg>*/,;  //"Neste passo voce deverแ informar a conta or็amentแria a ser copiada."
						{||.T.}/*<bBack>*/, ;
						{||cCtaOrc := (cArquivo)->XK3_CO, .T.}/*<bNext>*/, ;
						{||.T.}/*<bFinish>*/,;
						.T./*<.lPanel.>*/, ;
						{||A102ContaOrc(oWizard:oMPanel[oWizard:nPanel], aConfig, @lBrowse, @cArquivo)}/*<bExecute>*/ )

oWizard:NewPanel( STR0012/*<chTitle>*/,; //"Parโmetros"
 						STR0013/*<chMsg>*/, ; //"Neste passo voce deverแ informar como serใo copiados os itens or็amentแrios."
 						{||.T.}/*<bBack>*/, ;
 						{||.T.}/*<bNext>*/, ;
 						{|| A102Rest_Par(aConfig2),If(ParamOk(aParam2, aConfig2)/*.And.Eval(bOk)*/, ;
 						lRet := A102Fim_Wiz(aConfig, aConfig2, cCtaOrc, cPlanOri, cRevOri, cPlanOri, aPeriodo, aPerAux), .F.)}/*<bFinish>*/, ;
 						.T./*<.lPanel.>*/, ;
 						{||A102Param_Orc(oWizard, lParam2, aParam2, aConfig2)}/*<bExecute>*/ )

oWizard:Activate( .T./*<.lCenter.>*/,;
						 {||.T.}/*<bValid>*/, ;
						 {||.T.}/*<bInit>*/, ;
						 {||.T.}/*<bWhen>*/ )
						 
//Deleta tabela temporaria criada no banco de dados
If _oPCOA1021 <> Nil
	_oPCOA1021:Delete()
	_oPCOA1021 := Nil
Endif
						 

RestArea(aAreaAK1)
RestArea(aAreaAK2)
RestArea(aAreaAK3)
RestArea(aAreaAKE)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA102Plan_Box บAutor  ณPaulo Carnelossi  บ Data ณ 16/05/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para escolha da planilha a ser copiada               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102Plan_Box(oWizard, lParam, aParametros, aConfig)

If lParam == NIL
	M->AKR_ORCAME := Space(Len(AKE->AKE_ORCAME))
	ParamBox(aParametros ,STR0014, aConfig,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel])  //"Parametros"
	lParam := .T.
Else
	A102Rest_Par(aConfig)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA102ChkPlan บAutor  ณPaulo Carnelossi   บ Data ณ 16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para verificacao se planilha nao e a mesma e se      บฑฑ
ฑฑบ          ณexiste na base                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102ChkPlan(aConfig, lBrowse, cPlanOri, cRevOri)
Local lRet := .F.

If cPlanOri+cRevOri == aConfig[1]+aConfig[2]
	HELP("   ",1,"PLANIGUAL",,STR0015,3,0) //"Planilha selecionada nใo pode ser a mesma da origem. Verifique."
Else
	dbSelectArea("AK1")
	dbSetOrder(1)
	If dbSeek(xFilial("AK1")+aConfig[1])
		dbSelectArea("AKE")
		dbSetOrder(1)
		If dbSeek(xFilial("AKE")+aConfig[1]+aConfig[2])
			dbSelectArea("AK3")
			dbSetOrder(1)
			If dbSeek(xFilial("AK3")+aConfig[1]+aConfig[2])
			   lRet := .T.
			EndIf   
		EndIf
	EndIf
	
	If ! lRet
		HELP("   ",1,"NOEXIST",,STR0004+Alltrim(aConfig[1])+"/"+Alltrim(aConfig[2])+STR0016,3,0) //"Planilha "###" nใo existente. Verifique."
	Else
		If cPlanAnt != aConfig[1]+aConfig[2]
			cPlanAnt := aConfig[1]+aConfig[2]
			lBrowse := .T.
		EndIf	
	EndIf
EndIf

If Valtype(aConfig[3]) == "C"
	aConfig[3] := Val(aConfig[3])
EndIf	

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA102ContaOrcบAutor  ณPaulo Carnelossi   บ Data ณ 16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para escolha da conta orcamentaria a ser copiada paraบฑฑ
ฑฑบ          ณa planilha atual                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A102ContaOrc(oDlg, aConfig, lBrowse, cArquivo, lCriaArq, cContaOrc)

If lBrowse
	AuxContaOrc(oDlg, aConfig, lBrowse, @cArquivo, lCriaArq, cContaOrc)	
	lBrowse := .F.
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA102ContaOrcบAutor  ณPaulo Carnelossi   บ Data ณ 16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para escolha da conta orcamentaria a ser copiada paraบฑฑ
ฑฑบ          ณa planilha atual   (funcao auxiliar)                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AuxContaOrc(oDlg, aConfig, lBrowse, cArquivo, lCriaArq, cContaAux)
Local aCampos := {	{"AK3_DESCRI","AK3_DESCRI",55,,,.F.,"",260}, ;
							{"AK3_CO","AK3_CO",55,,,.F.,"",50}	}
Local nX
Local aStru := {}
Local aAlter
Local aExpand		:= {}
Local nNivelMax

Local oFont
Local oBrowse
Local oAll		:= LoadBitmap( GetResources(), "PMSEXPALL" )
Local oMenos	:= LoadBitmap( GetResources(), "PMSMENOS" )
Local oMais		:=	LoadBitmap( GetResources(), "PMSMAIS" )
Local oCmp		:= LoadBitmap( GetResources(), "PMSEXPCMP" )

DEFAULT oDlg := oMainWnd
DEFAULT lCriaArq := .T.
DEFAULT cContaAux := ""

aAuxCps	:= aClone(aCampos)

If lCriaArq
	cRevisa   := AKE->AKE_REVISA
EndIf

For nx := 1 to Len(aCampos)
	dbSelectArea("SX3")
	dbSetOrder(2)
	If MsSeek(aCampos[nx][1])
		aAdd(aStru,{"X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)),X3_TIPO,X3_TAMANHO,X3_DECIMAL})
		If aCampos[nx][6]
			aAdd(aAlter,"X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)))
		EndIf		
	ElseIf Substr(aCampos[nx][1],1,1) == "$"
		aAdd(aStru,aClone(&(Substr(aCampos[nx][1],2,Len(aCampos[nx][1])-1)+"(1)")))
	ElseIf Substr(aCampos[nx][1],1,1) == "%"
		aAdd(aStru,{"FORM"+StrZero(nx,2,0),Substr(aCampos[nx][1],15,1),Val(Substr(aCampos[nx][1],17,2)),Val(Substr(aCampos[nx][1],20,2))})
	EndIf
Next
aAdd(aStru,{"CTRLNIV","C",1,0})
aAdd(aStru,{"L_I_XO","C",1,0})
aAdd(aStru,{"ALIAS","C",3,0})
aAdd(aStru,{"RECNO","N",14,0})
aAdd(aStru,{"FLAG","L",1,0})

If _oPCOA1021 <> Nil
	_oPCOA1021:Delete()
	_oPCOA1021 := Nil
Endif

cArquivo		:= GetNextAlias()

_oPCOA1021 := FWTemporaryTable():New( cArquivo )  
_oPCOA1021:SetFields(aStru) 
_oPCOA1021:AddIndex("1", {"RECNO"})

//------------------
//Cria็ใo da tabela temporaria
//------------------
_oPCOA1021:Create()  

nNivelMax := PCOAtuPlan(cRevisa,cArquivo,10000,aExpand,,.F./*lUser*/,".T."/*cFiltro*/)

DEFINE FONT oFont NAME "Arial" SIZE 0, -11 BOLD

dbSelectArea(cArquivo)
dbGotop()

If !Empty(cContaAux)
	While !Eof()
		If Alltrim(XK3_CO)==Alltrim(cContaAux)
			Exit
		EndIf	
		dbSkip()
	End
EndIf	

nAlias	:= Select()
oBrowse := TcBrowse():New( 23, 1,285, 110, , , , oDlg,,,,,{|| If(!Empty((cArquivo)->CTRLNIV),(PcoPlnExp(cArquivo,aExpand,@nNivelMax),PCOAtuPlan(cRevisa,cArquivo,@nNivelMax,aExpand,,.F./*lUser*/,".T."/*cFiltro*/),oBrowse:Refresh()),NIL) },,oFont,,,,, .F.,cArquivo, .T.,, .F., , ,.f. )
oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oBrowse:bChange := {||oBrowse:nColPos := 1}
oBrowse:AddColumn( TCColumn():New( "",{ || If((cArquivo)->CTRLNIV=="-",oMenos,If((cArquivo)->CTRLNIV=="+",oMais,If((cArquivo)->CTRLNIV=="*",oAll,If((cArquivo)->CTRLNIV=="!",oCmp,Nil) )))},,,,"LEFT" , 15, .T., .F.,,,, .F., ))
oBrowse:AddColumn( TCColumn():New( "",{ || PcoRetRes((cArquivo)->ALIAS) },,,, "LEFT", 15, .T., .F.,,,, .T., ))
For nx := 1 to Len(aCampos)
	If Substr(aCampos[nx][1],1,1)=="$"
		aAuxRet := &(Substr(aCampos[nx][1],2,Len(aCampos[nx][1])-1)+"(2)")
		oBrowse:AddColumn( TCColumn():New( aAuxRet[1], FieldWBlock( aAuxRet[2] , nAlias ),AllTrim(aAuxRet[3]),,, if(aAuxRet[5]=="N","RIGHT","LEFT"), If(aCampos[nx][8]!=Nil,aCampos[nx][8],If(aAuxRet[4]>Len(aAuxRet[1]),(aAuxRet[4]*3),(LEN(aAuxRet[1])*3))), .F., .F.,,,, .F., ) )
	ElseIf Substr(aCampos[nx][1],1,1)=="%"
		oBrowse:AddColumn( TCColumn():New( Trim(Substr(aCampos[nx][1],2,12)), FieldWBlock( "FORM"+StrZero(nx,2,0) , nAlias ) ,Substr(aCampos[nx][1],22,35),,, if(Substr(aCampos[nx][1],15,1)=="N","RIGHT","LEFT"), If(Val(Substr(aCampos[nx][1],17,2))>Len(AllTrim(Substr(aCampos[nx][1],2,12))),(Val(Substr(aCampos[nx][1],17,2))*3),(Len(AllTrim(Substr(aCampos[nx][1],2,12)))*3)), .F., .F.,,,, .F., ) )
	Else
		dbSelectArea("SX3")
		dbSetOrder(2)
		If MsSeek(aCampos[nx][1])
			oBrowse:AddColumn( TCColumn():New( Trim(x3titulo()), FieldWBlock( "X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)), nAlias ),AllTrim(X3_PICTURE),,, if(X3_TIPO=="N","RIGHT","LEFT"), If(aCampos[nx][8]!=Nil,aCampos[nx][8],If(X3_TAMANHO>Len(X3_TITULO),(X3_TAMANHO*3),(LEN(X3_TITULO)*3))), .F., .F.,,,, .F., ) )
		EndIf
	EndIf
Next
oBrowse:AddColumn( TCColumn():New( "",{|| " " },,,, "LEFT", 5, .T., .F.,,,, .T., ))
dbSelectArea(cArquivo)
oBrowse:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณA102Param_Orc บAutor  ณPaulo Carnelossi  บ Data ณ 16/05/05  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para parametrizar o modo como sera a copia ( se plan.บฑฑ
ฑฑบ          ณinteira/conta + dep. /conta / ou somente itens)             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102Param_Orc(oWizard, lParam2, aParam2, aConfig2)

If lParam2 == NIL
	ParamBox(aParam2 ,STR0014, aConfig2,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel])  //"Parametros"
  	lParam2 := .T.
Else
	A102Rest_Par(aConfig2)	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA102Rest_ParบAutor  ณPaulo Carnelossi   บ Data ณ 16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para restauracao dos conteudos das variaveis MV_PAR  บฑฑ
ฑฑบ          ณna navegacao entre os paineis do assistente de copia        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102Rest_Par(aParam)
Local nX
Local cVarMem

For nX := 1 TO Len(aParam)
	cVarMem := "MV_PAR"+AllTrim(STRZERO(nX,2,0))
	&(cVarMem) := aParam[nX]	
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA102Fim_Wiz บAutor  ณPaulo Carnelossi   บ Data ณ 16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para execucao das rotinas de copias quando pressionarบฑฑ
ฑฑบ          ณo botao Finalizar do assistente de copia                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102Fim_Wiz(aConfig, aConfig2, cCtaOrc, cPlanOri, cRevOri, cPlanOri, aPeriodo, aPerAux)
Local lRet := .F.
Local cContaPai
Local nRecAK3 := 0 
Local nX
Local aRecAuxAK2

If 		aConfig2[1] == 1 //copiar planilha inteira

			lRet := (Aviso(STR0017,STR0018+; //"Copia da planilha "###"Confirma a copia da planilha orcamentaria "
											alltrim(aConfig[1])+"/"+alltrim(aConfig[2]) +;
											STR0019+Alltrim(cPlanOri)+"/"+; //" para a planilha "
											alltrim(cRevOri)+" ? ",{STR0020,STR0021},2)==1) //"Sim"###"Nao"

         If lRet
         		// OTIMIZACAO - MSSEEK EM TODAS AS PESQUISAS	
				dbSelectArea("AK3")
				dbSetOrder(3)
				
				If MsSeek(xFilial("AK3")+cPlanOri+cRevOri+StrZero(1, Len(AK3->AK3_NIVEL)))
					dbSkip()
					If Eof()
						lRet := .T.
					Else
						lRet := (AK3_FILIAL+AK3_ORCAME+AK3_VERSAO != xFilial("AK3")+cPlanOri+cRevOri)
					EndIf	
				EndIf
				
				If lRet
					dbSelectArea("AK3")
					dbSetOrder(3)
					If MsSeek(xFilial("AK3")+aConfig[1]+aConfig[2]+StrZero(1, Len(AK3->AK3_NIVEL)))
						dbSkip() // deve avancar para o Nivel 2 da planilha, pois o primeiro nivel eh a propria planilha
						If AK3_FILIAL+AK3_ORCAME+AK3_VERSAO == xFilial("AK3")+aConfig[1]+aConfig[2]
							cCtaOrc := AK3->AK3_CO
	   		         		A102IncPlanInt(aConfig, cCtaOrc, aPeriodo, cPlanOri, cRevOri, aPerAux)
		   	      		Else
		   	      			//Planilha sem estrutura definida ou seja sem contas orcamentarias
							HELP("   ",1,"PLANEXIST",,STR0004+Alltrim(cPlanOri)+"/"+Alltrim(cRevOri)+STR0022,3,0) //"Planilha "###" ja existente, nใo pode ser copiada a planilha inteira. Verifique."
	   		      		EndIf   
	   	      		Else
						HELP("   ",1,"PLANEXIST",,STR0004+Alltrim(cPlanOri)+"/"+Alltrim(cRevOri)+STR0022,3,0) //"Planilha "###" ja existente, nใo pode ser copiada a planilha inteira. Verifique."
	   	      		EndIf   
				Else
					HELP("   ",1,"PLANEXIST",,STR0004+Alltrim(cPlanOri)+"/"+Alltrim(cRevOri)+STR0022,3,0) //"Planilha "###" ja existente, nใo pode ser copiada a planilha inteira. Verifique."
				EndIf
				
	         //Voltar para ordem 1
				dbSelectArea("AK3")
				dbSetOrder(1)
         EndIf

ElseIf 	aConfig2[1] == 2 //copiar conta + dependencia

			lRet := (Aviso(STR0023+alltrim(cCtaOrc),STR0024+alltrim(cCtaOrc)+STR0025+; //"Copia da Conta "###"Confirma a copia da conta "###" posicionada + dependencias na planilha orcamentaria "
											alltrim(aConfig[1])+"/"+alltrim(aConfig[2]) +;
											STR0019+Alltrim(cPlanOri)+"/"+; //" para a planilha "
											alltrim(cRevOri)+" ? ",{STR0020,STR0021},2)==1) //"Sim"###"Nao"

			If lRet
				dbSelectArea("AK3")
				dbSetOrder(1)
				
				If ! dbSeek(xFilial("AK3")+cPlanOri+cRevOri+cCtaOrc) .And. ;
					dbSeek(xFilial("AK3")+aConfig[1]+aConfig[2]+cCtaOrc) 
					nNivAtual := Val(AK3->AK3_NIVEL)
					nRecAK3   := AK3->(Recno())
					
					If nNivAtual == 1
						lRet := .F.
						HELP("   ",1,"CTAEXIST",,STR0026+Alltrim(cPlanOri)+"/"+Alltrim(cRevOri)+STR0027,3,0) //"Conta orcamentaria ja existente na planilha orcamentaria "###". Verifique."
					Else
					
						aRecAuxAK2 := {}
						//subir a hierarquia das contas 
						//neste caso copia somente as contas orcamentarias superiores sem os itens
						If	nNivAtual > 2
							While AK3->(! Eof() .And. Val(AK3->AK3_NIVEL) > 2 .And. ;
												AK3_FILIAL+AK3_ORCAME+AK3_VERSAO ==;
												xFilial("AK3")+aConfig[1]+aConfig[2])       
								If dbSeek(xFilial("AK3")+aConfig[1]+aConfig[2]+AK3->AK3_PAI)
									lRet := A102IncConta(aConfig[1], aConfig[2], AK3->AK3_CO, cPlanOri, cRevOri)							
								EndIf
							End
						EndIf
						
						//descer a hierarquia das contas
						//neste caso copia as contas abaixo desta + os itens de cada conta
						dbGoto(nRecAK3)
						
						A102IncDepCta(aConfig[1], aConfig[2], AK3->AK3_CO, cPlanOri, cRevOri, aPeriodo,  aRecAuxAK2 )
						
						PcoIniLan('000252')
						dbSelectArea("AK2")
						For nX := 1 TO Len(aRecAuxAK2)
							dbGoto(aRecAuxAK2[nX])
							PcoDetLan("000252","01","PCOA100")
						Next	
						PcoFinLan('000252')

					EndIf

				Else

					lRet := .F.
					HELP("   ",1,"CTAEXIST",,STR0026+Alltrim(cPlanOri)+"/"+Alltrim(cRevOri)+STR0027,3,0) //"Conta orcamentaria ja existente na planilha orcamentaria "###". Verifique."

				EndIf	
				
			Else
				lRet := .F.
				HELP("   ",1,"CTAEXIST",,STR0026+Alltrim(cPlanOri)+"/"+Alltrim(cRevOri)+STR0027,3,0) //"Conta orcamentaria ja existente na planilha orcamentaria "###". Verifique."
			EndIf
			
ElseIf 	aConfig2[1] == 3 //copiar somente conta posicionada
			lRet := (Aviso(STR0023+alltrim(cCtaOrc),STR0024+alltrim(cCtaOrc)+STR0030+; //"Copia da Conta "###"Confirma a copia da conta "###" posicionada na planilha orcamentaria "
											alltrim(aConfig[1])+"/"+alltrim(aConfig[2]) +;
											STR0019+Alltrim(cPlanOri)+"/"+; //" para a planilha "
											alltrim(cRevOri)+" ? ",{STR0020,STR0021},2)==1) //"Sim"###"Nao"

			If lRet
				dbSelectArea("AK3")
				dbSetOrder(1)
				If dbSeek(xFilial("AK3")+aConfig[1]+aConfig[2]+cCtaOrc)
					cContaPai := AK3->AK3_PAI
					nRecAK3 := AK3->(Recno())
					If ! dbSeek(xFilial("AK3")+aConfig[1]+cRevOri+cContaPai)
						lRet := .F.
						HELP("   ",1,"CONTASUP",,STR0031+Alltrim(cPlanOri)+"/"+Alltrim(cRevOri)+STR0027,3,0) //"Conta superior nao encontrada na Planilha "###". Verifique."
               		Else
						If ! dbSeek(xFilial("AK3")+cPlanOri+cRevOri+cCtaOrc)
							AK3->(dbGoto(nRecAK3))
							lRet := A102IncCtaPos(aConfig, cCtaOrc, aPeriodo, cPlanOri, cRevOri)
						Else
							lRet := .F.
							HELP("   ",1,"CTAEXIST",,STR0026+Alltrim(cPlanOri)+"/"+Alltrim(cRevOri)+STR0027,3,0) //". Verifique." //"Conta orcamentaria ja existente na planilha orcamentaria "
						EndIf
					EndIf	
				EndIf	
			EndIf
			
ElseIf 	aConfig2[1] == 4 //copiar somente itens da conta posicionada
			lRet := (Aviso(STR0032+alltrim(cCtaOrc),STR0033+alltrim(cCtaOrc)+STR0030+; //"Copia dos Itens Or็amentแrios - "###"Confirma a copia da dos itens da conta "###" posicionada na planilha orcamentaria "
											alltrim(aConfig[1])+"/"+alltrim(aConfig[2]) +;
											STR0019+Alltrim(cPlanOri)+"/"+; //" para a planilha "
											alltrim(cRevOri)+" ? ",{"Sim","Nao"},2)==1)

			If lRet
				aRecAuxAK2 := {}
				A102Incl_Item(cPlanOri, cRevOri, cCtaOrc, aConfig[1], aConfig[2], aPeriodo, , aRecAuxAK2)
				PcoIniLan('000252')
				dbSelectArea("AK2")
				For nX := 1 TO Len(aRecAuxAK2)
					dbGoto(aRecAuxAK2[nX])
					PcoDetLan("000252","01","PCOA100")
				Next	
				PcoFinLan('000252')
			EndIf			
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณA102IncPlanInt บAutor ณPaulo Carnelossi  บ Data ณ 16/05/05  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para copia da planilha inteira                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102IncPlanInt(aConfig, cCtaOrc, aPeriodo, cPlanOri, cRevOri, aPerAux)
Local aRecAuxAK2 := {}
Local nX
Local lQuery := .F.            
Local lExiste := .F. 
Local cQuery     := "" 
Local cAliasAK3  := "" 

Local oProc 

lQuery := .T. 
	    
//nao tirar desta posicao, pois a query utiliza indexkey()
dbSelectArea("AK3")
dbSetOrder(3)

If lQuery 

	cAliasAK3 := GetNextAlias() 
	
	cQuery := "SELECT AK3.AK3_ORCAME,AK3.AK3_VERSAO,AK3.AK3_CO,AK3.R_E_C_N_O_ AK3RECNO FROM " + RetSqlName( "AK3" ) + " AK3 " 
	cQuery += "WHERE " 
	cQuery += "AK3.AK3_FILIAL='" + xFilial( "AK3" ) + "' AND " 
	cQuery += "AK3.AK3_ORCAME='" + aConfig[1] + "' AND " 
	cQuery += "AK3.AK3_VERSAO='" + aConfig[2] + "' AND " 
	cQuery += "AK3.AK3_NIVEL<>'" + StrZero(1, Len(AK3->AK3_NIVEL)) + "' AND " 
	cQuery += "AK3.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY " + SqlOrder( AK3->( IndexKey() ) )  
	
	cQuery := ChangeQuery( cQuery ) 
	
	dbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), cAliasAK3, .F., .T. )   
	
	TcSetField( cAliasAK3, "AK3RECNO", "N", 12, 0 ) 
	
	If !( cAliasAK3 )->( Eof() ) 
	
		While !( cAliasAK3 )->( Eof() )        
	                                     
			If A102IncConta(aConfig[1], aConfig[2], ( cAliasAK3 )->AK3_CO, cPlanOri, cRevOri, ( cAliasAK3 )->AK3RECNO )
				
				lExiste := .F. 
				    
				cAK2Count := GetNextAlias() 
				cQuery := ""
				
				cQuery += "SELECT COUNT(*) AK2COUNT FROM " + RetSqlName( "AK2" ) + " AK2 " 
				cQuery += "WHERE "
				cQuery += "AK2.AK2_FILIAL='" + xFilial( "AK2" ) + "' AND " 
				cQuery += "AK2.AK2_ORCAME='" + ( cAliasAK3 )->AK3_ORCAME + "' AND "
				cQuery += "AK2.AK2_VERSAO='" + (cAliasAK3)->AK3_VERSAO + "' AND " 
				cQuery += "AK2.AK2_CO='" + (cAliasAK3)->AK3_CO + "' AND "
				cQuery += "AK2.D_E_L_E_T_=' '"				
				
				cQuery := ChangeQuery( cQuery )
				
				dbUseArea( .t., "TOPCONN", TcGenQry( ,, cQuery ), cAK2Count, .F., .T. ) 					
				
				TcSetField( cAK2Count, "AK2COUNT", "N", 12, 0 ) 
				
				lExiste := !Empty( ( cAK2Count )->AK2COUNT ) 
				
				( cAK2Count )->( dbCloseArea() ) 
				dbSelectArea( "AK2" )
	        
 				If lExiste 
					A102Incl_Item(cPlanOri, cRevOri, (cAliasAK3)->AK3_CO, aConfig[1], aConfig[2], aPeriodo, aPerAux, aRecAuxAK2 )
				EndIf 	
	
			EndIf
	
			( cAliasAK3 )->( dbSkip() ) 			
		
        EndDo
        
    	
    EndIf
    
    ( cAliasAK3 )->( dbCloseArea() ) 
    dbSelectArea( "AK2" ) 
    

Else 
	
	If dbSeek(xFilial("AK3")+aConfig[1]+aConfig[2]+StrZero(1, Len(AK3->AK3_NIVEL)))
		dbSkip()  //deve avancar para o segundo nivel pois o primeiro eh a propria planilha
		aRecAuxAK2 := {}
	
		//copiar a planilha
		While AK3->(! Eof() .And. AK3_FILIAL+AK3_ORCAME+AK3_VERSAO ==;
										xFilial("AK3")+aConfig[1]+aConfig[2])       
				
			If A102IncConta(aConfig[1], aConfig[2], AK3->AK3_CO, cPlanOri, cRevOri)
		
				dbSelectArea("AK2")
				dbSetOrder(1)
				If dbSeek(xFilial("AK2")+AK3->AK3_ORCAME+AK3->AK3_VERSAO+AK3->AK3_CO)
		      		A102Incl_Item(cPlanOri, cRevOri, AK3->AK3_CO, aConfig[1], aConfig[2], aPeriodo, aPerAux, aRecAuxAK2 )
			 	EndIf
	
		   EndIf
		      
			AK3->(dbSkip())
			
		End
	
	EndIf
EndIf 

If !Empty( aRecAuxAK2 ) 
	PcoIniLan('000252')	
	dbSelectArea("AK2")
	
	oProc := MsNewProcess():New( { |lEnd| A102CallDet( oProc, aRecAuxAK2 ) },"Atualizando saldos das contas orcamentarias",NIL ,.F.)
	oProc:Activate()
	
	PcoFinLan('000252')		
EndIf 
	
Return                                                                        


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA102CallDet  บAutor ณPaulo Carnelossi   บ Data ณ 26/01/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A102CallDet( oProc, aRecAuxAK2 )

oProc:SetRegua1( Len( aRecAuxAK2 ) ) 

// Atualiza os saldos das contas orcamentarias

dbSelectArea( "AK2" ) 
AEval( aRecAuxAK2, { |x| AK2->( dbGoto(x) ), PcoDetLan("000252","01","PCOA100"), oProc:IncRegua1() } )

Return( .t. ) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA102IncConta บAutor ณPaulo Carnelossi   บ Data ณ 11/05/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณInclui as contas orcamentarias ref a tab (AK3)   posicionadoบฑฑ
ฑฑบ          ณutiliza recursividade ao chamar a funcao A200Nivel() para   บฑฑ
ฑฑบ          ณchamar novamente A200IncConta para as contas pai            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102IncConta(cPlanilha, cVersao, cCtaOrc, cPlanOri, cRevOri, nRecAK3)
Local aArea := GetArea()
Local aAreaAK3 := AK3->(GetArea())
Local aCampos := {	{"AK3_ORCAME",cPlanOri},;
							{"AK3_VERSAO",cRevOri}	}

Local lRet := .F.
Local nRegIncl := 0

DEFAULT nRecAK3 := AK3->( Recno() )  

dbSelectArea("AK3")
dbSetOrder(1)

If !dbSeek(xFilial("AK3")+cPlanOri+cRevOri+cCtaOrc)
	PmsCopyReg("AK3", nRecAK3, aCampos, @nRegIncl)
	
   AK3->(dbGoto(nRegIncl))
	RecLock("AK3", .F.)
	If AK3->AK3_NIVEL == StrZero(2, Len(AK3->AK3_NIVEL)) //Empty(AK3->AK3_PAI)
		AK3->AK3_PAI := cPlanOri
		//AK3->AK3_NIVEL := StrZero(2, Len(AK3->AK3_NIVEL))  // "002"
	Else
		//AK3->AK3_PAI := If(ALLTRIM(AK3->AK3_PAI) == ALLTRIM(cPlanilha), cPlanOri, AK3->AK3_PAI)
		If AllTrim(AK3->AK3_PAI) == AllTrim(cPlanilha)
			AK3->AK3_PAI := cPlanOri
		EndIf	
	EndIf	
	MsUnlock()
	lRet := .T.
EndIf

RestArea(aAreaAK3)
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA102Incl_Item บAutor ณPaulo Carnelossi บ Data ณ  15/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclui item orcamentario para a conta posicionada (AK3)     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102Incl_Item(cPlanOri, cRevOri, cCtaOrc, cPlanilha, cVersao, aPeriodo, aPerAux, aRecAuxAK2)
Local nX
Local bItens := {||A102ItAK2(cPlanOri, cRevOri, cCtaOrc, nRegIncl)}
Local nRecAK2 := 0
Local nRegIncl := 0
Local aCampos := {	{"AK2_ORCAME",cPlanOri},;
							{"AK2_VERSAO",cRevOri} }

Local aAuxPer, cId, cIdAnt
Local dIniPer, dFinPer
Local cAliasAK2 := "AK2" 
Local lQuery  := .F. 
Local bBlkAtu
Local cQuery

cQuery := ""

DEFAULT aPerAux := {}
DEFAULT aRecAuxAK2 := {}   
//nao tirar desta posicao pois a query tb utiliza indexkey()
dbSelectArea("AK2")
dbSetOrder(5)
                            
cAliasAK2 := GetNextAlias() 

cQuery := ""
cQuery += "SELECT AK2.AK2_ID,AK2.AK2_PERIOD,AK2.AK2_FILIAL,AK2.AK2_ORCAME,AK2.AK2_VERSAO,AK2.AK2_CO,AK2.R_E_C_N_O_ AK2RECNO FROM " + RetSqlName( "AK2" ) + " AK2 "
cQuery += "WHERE " 
cQuery += "AK2.AK2_FILIAL='" + xFilial( "AK2" ) + "' AND " 
cQuery += "AK2.AK2_ORCAME='" + cPlanilha + "' AND " 
cQuery += "AK2.AK2_VERSAO='" + cVersao   + "' AND " 
cQuery += "AK2.AK2_CO='"     + cCtaOrc   + "' AND " 
cQuery += "AK2.D_E_L_E_T_=' ' "                                     
cQuery += "ORDER BY " +  SqlOrder( AK2->( IndexKey() ) ) 

cQuery := ChangeQuery( cQuery ) 

dbUseArea( .t., "TOPCONN", TcGenQry( ,, cQuery ), cAliasAK2, .F., .T. ) 

TcSetField( cAliasAK2, "AK2RECNO", "N" , 12, 0 ) 
TcSetField( cAliasAK2, "AK2_PERIOD", "D", 8, 0 ) 

lQuery := .T. 
	
If lQuery .Or. AK2->( dbSeek(xFilial("AK2")+cPlanilha+cVersao+cCtaOrc) ) 

	While ( cAliasAK2 )->( !Eof() .And. AK2_FILIAL + AK2_ORCAME + AK2_VERSAO + AK2_CO == ;
										xFilial("AK2")+cPlanilha+cVersao+cCtaOrc )

		cIdAnt := ( cAliasAK2 )->AK2_ID
		nRegIncl := 0
		cId := Eval(bItens)
		
		While ( cAliasAK2 )->( !Eof() .And. AK2_FILIAL + AK2_ORCAME + AK2_VERSAO + AK2_CO + AK2_ID == ;
										xFilial("AK2")+cPlanilha+cVersao+cCtaOrc+cIdAnt )
		
			If Empty(aPerAux)
				aAuxPer := A102VerPeriodo( (cAliasAK2 )->AK2_PERIOD, aPeriodo)
				If !Empty(aAuxPer)
					dIniPer := aAuxPer[1]
					dFinPer := aAuxPer[2]
				EndIf
			Else
				aAuxPer := A102VerPeriodo((cAliasAK2)->AK2_PERIOD, aPeriodo, aPerAux, @dIniPer, @dFinPer)
			EndIf	

			If !Empty(aAuxPer)
			
				If lQuery 
					nRecAk2 := ( cAliasAK2 )->AK2RECNO 
				Else					
					nRecAk2 := AK2->(Recno())
				EndIf 	
				bBlkAtu := { || 	AK2->AK2_ID := cId,;
									AK2->AK2_PERIOD := dIniPer,;
									AK2->AK2_DATAI := dIniPer,;
									AK2->AK2_DATAF := dFinPer} 
				
				PmsCopyReg("AK2", nRecAK2, aCampos, @nRegIncl, { bBlkAtu })

				aAdd(aRecAuxAK2, nRegIncl )				
		                      
				If !lQuery
					AK2->(dbGoto(nRecAK2))
				EndIf 	
		
			EndIf

			( cAliasAK2 )->(dbSkip())
	
		EndDo 
		
	EndDo 
		
EndIf          

( cAliasAK2 )->( dbCloseArea() ) 
dbSelectArea( "AK2" ) 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA102ItAK2บAutor ณPaulo Carnelossi      บ Data ณ  12/05/05   บฑฑ
ฑฑฬออออออออออุอออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o item a ser gravado na tabela AK2 - incrementa 1   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102ItAK2(cPlanOri, cRevOri, cCtaOrc, nRecno)
Local nItAK2 := 0
Local cItAK2
Local aArea := AK2->(GetArea())
Local lQuery := .F. 
Local cQuery    := ""
Local cAliasAK2 := "" 

lQuery := .T. 
	
If lQuery          

	dbSelectArea("AK2") 

	cAliasAK2 := GetNextAlias() 

	cQuery := ""
	
	cQuery += "SELECT MAX(AK2.AK2_ID) IDMAX FROM " + RetSqlName("AK2") + " AK2 "
	cQuery += "WHERE " 
	cQuery += "AK2.AK2_FILIAL='" + xFilial("AK2") + "' AND "
	cQuery += "AK2.AK2_ORCAME='" + cPlanOri       + "' AND "
	cQuery += "AK2.AK2_VERSAO='" + cRevOri        + "' AND "
	cQuery += "AK2.AK2_CO='"     + cCtaOrc        + "' AND " 
	cQuery += "AK2.R_E_C_N_O_<>" + AllTrim(Str(nRecno)) + " AND " 
	cQuery += "AK2.D_E_L_E_T_=' '" 
	
	cQuery := ChangeQuery( cQuery )        
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasAK2, .F., .T. ) 
	
	nItAK2 := VAL((cAliasAK2)->IDMAX) 
	
	( cAliasAK2 )->( dbCloseArea() ) 
	dbSelectArea( "AK2" ) 

Else

	dbSelectArea("AK2")
	dbSetOrder(5)
	If dbSeek(xFilial("AK2")+cPlanOri+cRevOri+cCtaOrc)
		While AK2->(!Eof().And.AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO == ;
						xFilial("AK2")+cPlanOri+cRevOri+cCtaOrc)
			If nRecno != AK2->(Recno())
				nItAK2 := VAL(AK2->AK2_ID)
			EndIf
			AK2->(dbSkip())
		End
	EndIf
	
EndIf 	
	
nItAK2++
cItAK2 := StrZero(nItAK2, Len(AK2->AK2_ID))

RestArea(aArea)
dbSelectArea("AK2")

Return(cItAK2)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA102VerPeriodo บAutor ณPaulo Carnelossiบ Data ณ  12/05/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna array com data inicio e fim do periodo              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102VerPeriodo(dData, aPeriodo, aPerAux, dIniPer, dFinPer)
Local aRetorno := {}
Local dIni, dFim
Local nX

DEFAULT aPerAux := {}
DEFAULT dIniPer := CTOD("  /  /  ")
DEFAULT dFinPer := CTOD("  /  /  ")

If Empty(aPerAux)

	For nX := 1 TO Len(aPeriodo)
		dIni := CTOD(Subs(aPeriodo[nX], 1, 10))
		dFim := CTOD(Alltrim(Subs(aPeriodo[nX], 14)))
		If dData >= dIni .And. dData <= dFim
			aAdd(aRetorno, dIni)
			aAdd(aRetorno, dFim)
			Exit
		EndIf
	Next
	
Else

	For nX := 1 TO Len(aPerAux)
		dIni := CTOD(Subs(aPerAux[nX,2],1,10))
		dFim := CTOD(Alltrim(Subs(aPerAux[nX,2], 14)))
		If dData >= dIni .And. dData <= dFim
			aAdd(aRetorno, dIni)
			aAdd(aRetorno, dFim)
			dIniPer := CTOD(Subs(aPerAux[nX,1],1,10))
			dFinPer := CTOD(Alltrim(Subs(aPerAux[nX,1], 14)))
			Exit
		EndIf
	Next

EndIf

Return(aRetorno)

Static Function A102IncCtaPos(aConfig, cCtaOrc, aPeriodo, cPlanOri, cRevOri)
Local lRet := .F.
Local nX
Local aRecAuxAK2 := {}
If A102IncConta(aConfig[1], aConfig[2], cCtaOrc, cPlanOri, cRevOri)
   lRet := .T.
	dbSelectArea("AK2")
	dbSetOrder(1)
	If dbSeek(xFilial("AK2")+aConfig[1]+aConfig[2]+cCtaOrc)
		A102Incl_Item(cPlanOri, cRevOri, cCtaOrc, aConfig[1], aConfig[2], aPeriodo, , aRecAuxAK2)
 	EndIf
	PcoIniLan('000252')
	dbSelectArea("AK2")
	For nX := 1 TO Len(aRecAuxAK2)
		dbGoto(aRecAuxAK2[nX])
		PcoDetLan("000252","01","PCOA100")
	Next	
	PcoFinLan('000252')

EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณA102IncDepCtaบAutor ณPaulo Carnelossi    บ Data ณ 16/05/05  บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para copia da Conta + dependencias                   บฑฑ
ฑฑบ          ณfunciona da seguinte forma:                                 บฑฑ
ฑฑบ          ณas contas superiores sao copiadas sem os itens              บฑฑ
ฑฑบ          ณas contas inferiores e a posionada e copiado contas + itens บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102IncDepCta(cPlanilha, cVersao, cCtaOrcInc, cPlanOri, cRevOri, aPeriodo, aRecAuxAK2 )
Local nRecAK3 := AK3->(Recno())
Local aAreaAK3
Local cChavAux 

DEFAULT aRecAuxAK2 := {}

If A102IncConta(cPlanilha, cVersao, cCtaOrcInc, cPlanOri, cRevOri)

	dbSelectArea("AK2")
	dbSetOrder(1)
	If dbSeek(xFilial("AK2")+AK3->AK3_ORCAME+AK3->AK3_VERSAO+AK3->AK3_CO)
      	A102Incl_Item(cPlanOri, cRevOri, AK3->AK3_CO, cPlanilha, cVersao, aPeriodo, , aRecAuxAK2)
 	EndIf
 	
 	//procura proximo registro cujo pai eh o q acabou de ser incluido
 	dbSelectArea("AK3")
 	dbSetOrder(2) //ORDEM: AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_PAI
 	dbGoto(nRecAK3)  
 	cChavAux :=xFilial("AK3")+cPlanilha+cVersao+AK3->AK3_CO
 	
 	//aqui implementar um laco para pegar todas as co
 	If dbSeek(cChavAux)
 	   While AK3->(! Eof() .AND. AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_PAI==cChavAux)
 	   		If Val(AK3->AK3_NIVEL) > 1
	 	   		aAreaAK3 := AK3->(GetArea())
				A102IncDepCta(cPlanilha, cVersao, AK3->AK3_CO, cPlanOri, cRevOri, aPeriodo, aRecAuxAK2)
				RestArea(aAreaAK3)
			EndIf
			AK3->(dbSkip())
		End		
	EndIf	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA102PeriodoบAutor  ณPaulo Carnelossi    บ Data ณ 29/11/06   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna array com periodos da planilha a ser copiada        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102Periodo(aPerPla, aConfig, aPerAux)
Local lRet := .F.
Local aPerCop
Local dIniPla, dIniCop
Local dFimPla, dFimCop
Local nX

DEFAULT aPerAux := {}

aPerAux := {}
dIniPla := CTOD(PadR(aPerPla[1],10))
dFimPla := CTOD(Subs(aPerPla[Len(aPerPla)],14))

aPerCop := A102RetPer(aConfig)

If !Empty(aPerCop)

	dIniCop := CTOD(PadR(aPerCop[1],10))
	dFimCop := CTOD(Subs(aPerCop[Len(aPerCop)],14))

	If Len(aPerPla) == Len(aPerCop)
		lRet := .T.
		If aConfig[3] == 1
			For nX := 1 TO Len(aPerPla)
				aAdd(aPerAux, { aPerPla[nX], aPerCop[nX] })
			Next
		EndIf
	Else
		If dIniCop >= dIniPla .And. dFimCop <= dFimPla
			lRet := .T.
		EndIf
	EndIf

EndIf
If ! lRet
	Aviso("Atencao", "Os valores nao serao copiados, pois os periodos nao sao equivalentes.", {"Ok"}) 
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA102RetPerบAutor  ณPaulo Carnelossi    บ Data ณ  29/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna array com periodos da planilha a ser copiada        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A102RetPer(aConfig)
Local aPerCop := {}
Local aArea := GetArea()
Local aAreaAK1 := AK1->(GetArea())

dbSelectArea("AK1")
If dbSeek(xFilial("AK1")+aConfig[1]+aConfig[2])
	aPerCop := PcoRetPer()
EndIf	

RestArea(aAreaAK1)
RestArea(aArea)

Return(aPerCop)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoPlnExpณ Autor ณ Edson Maricate         ณ Data ณ 05-12-2003 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de Expansao/Compressao da planilha orcamentaria        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAPCO                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoPlnExp(cArquivo,aExpand,nNivelMax)
Local nPos

If !Empty(aExpand).And. (nPos:=aScan(aExpand,{|x|x[1]==(cArquivo)->ALIAS+(cArquivo)->XK3_CO})) >0
	If (cArquivo)->CTRLNIV == "-"
		aExpand[nPos][2] := .F.
	ElseIf (cArquivo)->CTRLNIV == "+"
		aExpand[nPos][2] := .T.
	ElseIf (cArquivo)->CTRLNIV == "*"
		nNivelMax := 2000
		aExpand := {}
		dbSelectArea(cArquivo)
		dbGotop()
		Zap
		Pack
	ElseIf (cArquivo)->CTRLNIV == "!"
		nNivelMax := 1
		aExpand := {}
		dbSelectArea(cArquivo)
		dbGotop()
		Zap
		Pack
	EndIf
Else
	If (cArquivo)->CTRLNIV == "-"
		aAdd(aExpand,{(cArquivo)->ALIAS+(cArquivo)->XK3_CO,.F.})
	ElseIf (cArquivo)->CTRLNIV == "+"
		aAdd(aExpand,{(cArquivo)->ALIAS+(cArquivo)->XK3_CO,.T.})	
	ElseIf (cArquivo)->CTRLNIV == "*"
		nNivelMax := 2000
		aExpand := {}		
		dbSelectArea(cArquivo)
		dbGotop()
		Zap
		Pack
	ElseIf (cArquivo)->CTRLNIV == "!"
		nNivelMax := 1
		aExpand := {}
		dbSelectArea(cArquivo)
		dbGotop()
		Zap
		Pack
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoRetResณ Autor ณ Edson Maricate         ณ Data ณ 05-12-2003 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de retorno do bitmap da planilha orcamentaria          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAPCO                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoRetRes(cAlias,lString)
Local oRet

DEFAULT lString := .F.

// corrige o erro quando
// a linha do projeto esta
// selecionada e foi selecionada
// a impressao
//
// correcao temporaria, necessario
// descobrir a origem do problema
If AllTrim(cAlias)==""
	Return
EndIf

If oPCO_CO==Nil
	oPCO_CO := LoadBitmap( GetResources(), "MDIVISIO_PQ" )
	oPMSUSER := LoadBitmap( GetResources(), "BMPUSER_PQ" )
EndIf

If lString
	Do Case
		Case cAlias $ "AK3/AK1"
			oRet := "PCO_CO"
		Case cAlias == "AKG"
			oRet := "BMPUSER_PQ"
	EndCase
Else
	Do Case
		Case cAlias $ "AK3/AK1"
			oRet := oPCO_CO
		Case cAlias == "AKG"
			oRet := oPMSUSER
	EndCase
EndIf

Return oRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoAtuPlanณ Autor ณ Edson Maricate        ณ Data ณ 05-12-2003 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณExecuta a atualizacao do arquivo de trabalho.                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณSIGAPCO                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoAtuPlan(cRevisa,cArquivo,nNivelMax,aExpand,lZap,lUser,cFiltro,cCOInic)

Local nNivelAtu := 1
Local aArea		:= GetArea()
Local aAreaTmp
Local aProcForm
Local nCount
Local nx
Local ny

DEFAULT cRevisa		:= AK1->AK1_VERSAO
DEFAULT nNivelMax	:= 10000
DEFAULT lZap		:= .T.

                      
dbSelectArea(cArquivo)
aAreaTmp	:= GetArea()
If LastRec() > 0 
	nNivelMax := 10000
EndIf
dbGotop()
If lZap
	Zap
	Pack
EndIf

RecLock(cArquivo,.T.)
(cArquivo)->XK3_CO := AK1->AK1_CODIGO
(cArquivo)->XK3_DESCRI := AK1->AK1_DESCRI
(cArquivo)->RECNO := AK1->(RecNo())
(cArquivo)->ALIAS := "AK1"
AK3->(dbSetOrder(3))
If AK3->(MsSeek(xFilial()+AK1->AK1_CODIGO+cRevisa+"001"))
	aProcForm	:= {}
	For nx := 1 to Len(aAuxCps)
		If aAuxCps[nx][1]=="AK3_DESCRI"
			FieldPut(FieldPos("X"+Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)),SPACE((VAL(AK3->AK3_NIVEL)-1)*5)+AK3->(FieldGet(FieldPos(aAuxCps[nx][2]))))
		ElseIf Substr(aAuxCps[nx][1],1,1)=="%"
			aAdd(aProcForm,nx)
		Else
			If Substr(aAuxCps[nx][1],1,1)=="$"
				FieldPut(FieldPos(Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)),&(Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)+"(3,'AK3',AK3->(RecNo()))"))
			Else
				If Substr(aAuxCps[nx][1],1,1)!="|"
					If AK3->(FieldPos(aAuxCps[nx][2])) > 0
						FieldPut(FieldPos("X"+Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)),AK3->(FieldGet(FieldPos(aAuxCps[nx][2]))))
					Endif
				EndIf
			Endif
		EndIf
	Next

	For nx := 1 to Len(aProcForm)
		nCntLet := 0
		nCount := 0
			
		For ny := 1 to Len(aAuxCps)
			If Substr(aAuxCps[ny][1], 1, 1) # "|"
				nCntLet++
				If nCntLet > 26
					nCntLet	:= 1
					nCount++
				EndIf
				If nCount > 0
					If Upper(AllTrim((cArquivo)->(FieldName(1))))=="CTRLNIV"
						&(Chr(64+nCntLet)+Chr(48+nCount)) := (cArquivo)->(FieldGet(ny+1))
					Else
						&(Chr(64+nCntLet)+Chr(48+nCount)) := (cArquivo)->(FieldGet(ny))
					EndIf
				Else
					If Upper(AllTrim((cArquivo)->(FieldName(1))))=="CTRLNIV"
						&(Chr(64+nCntLet)) := (cArquivo)->(FieldGet(ny+1))
					Else
						&(Chr(64+nCntLet)) := (cArquivo)->(FieldGet(ny))
					EndIf
				EndIf
			EndIf
		Next
		
		If RepVar(@cBlock, Substr(aAuxCps[aProcForm[nx]][1],58,60))==-1
			HELP("  ",1,"PCOERROCPO",,Substr(aAuxCps[aProcForm[nx]][1],2,12)+"="+cBlock)
			MsUnlock()
			Return			
		EndIf

		Begin Sequence
			FieldPut(FieldPos("FORM"+StrZero(aProcForm[nx],2,0)), &(cBlock))

			// recalcula as formulas anteriores (somente as formulas)
			// este recalculo e necessario para formulas que utilizam
			// formulas ainda nao calculadas

			// o recalculo deve ser feito apos o calculo da formula atual
			cBlock := ""
			nCntLet := 0
			nCount := 0
	
			For ny := 1 to Len(aAuxCps)
				If Substr(aAuxCps[ny][1], 1, 1) # "|"
					nCntLet++
					If nCntLet > 26
						nCntLet	:= 1
						nCount++
					EndIf
          
					If Substr(aAuxCps[ny][1],1,1)=="%"
						If RepVar(@cBlock, Substr(aAuxCps[ny][1],58,60))==-1
							HELP("  ",1,"PCOERROCPO",,Substr(aAuxCps[ny][1],2,12)+"="+cBlock)
							MsUnlock()
							Return			
						EndIf
					Else
						Loop
					EndIf								

					If nCount > 0
						&(Chr(64+nCntLet)+Chr(48+nCount)) := &(cBlock)
					Else
						&(Chr(64+nCntLet)) := &(cBlock)
					EndIf
						
					FieldPut(FieldPos("FORM"+StrZero(ny,2,0)), &(cBlock))
				EndIf
			Next		
		Recover
			MsUnlock()
			ErrorBlock(bBlock)
			Return
		End Sequence
	Next
EndIf
If nNivelMax <> 2000
	(cArquivo)->CTRLNIV	:= "*"
Else
	(cArquivo)->CTRLNIV	:= "!"
EndIf
MsUnlock()

If aExpand != Nil
	aAdd(aExpand,{(cArquivo)->ALIAS+(cArquivo)->XK3_CO,.T.})	
EndIf

If cCOInic != NIL

	dbSelectArea("AK3")
	dbSetOrder(1)
	MsSeek(xFilial()+AK1->AK1_CODIGO+cRevisa+cCOInic)
	PcoAddPlan(AK3_ORCAME,AK3_VERSAO,AK3_CO,cArquivo,@nNivelAtu,@nNivelMax,@aExpand,lUser,cFiltro)

Else
	
	dbSelectArea("AK3")
	dbSetOrder(3)
	MsSeek(xFilial()+AK1->AK1_CODIGO+cRevisa+"001")
	While !Eof() .And. 	AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_NIVEL==;
						xFilial("AK3")+AK1->AK1_CODIGO+cRevisa+"001"
		PcoAddPlan(AK3_ORCAME,AK3_VERSAO,AK3_CO,cArquivo,@nNivelAtu,@nNivelMax,@aExpand,lUser,cFiltro)
		dbSelectArea("AK3")
		dbSkip()
	End
	
EndIf

RestArea(aAreaTmp)
RestArea(aArea)

Return nNivelAtu