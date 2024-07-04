#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA530A.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530PrDisบAutor  ณVendas CRM          บ Data ณ  23/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInterface para respostas de perguntas dissertativas         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530PrDis()

Local aArea		:= GetArea()
Local lConf		:= .F.
Local cPerg	 	:= AllTrim(SKG->KG_DESC)
Local cResp	 	:= Space(TamSX3("AG6_RESP")[1])
Local oDlg		:= Nil
Local oFont		:= Nil 
Local oPerg		:= Nil
Local oResp		:= Nil

DEFINE FONT oFont NAME "Arial" SIZE 0,18 BOLD 

DEFINE MSDIALOG oDlg TITLE STR0001 FROM 0,0 TO 190,535 PIXEL	//"Responda a questใo abaixo"

	//Labels
	@ 000,001 TO 038,267 LABEL STR0002 PIXEL OF oDlg	//"Pergunta"
	@ 040,001 TO 068,267 LABEL STR0003 PIXEL OF oDlg	//"Resposta"

	//Caixas de texto
	@ 009,005 Get oPerg Var cPerg Size 258,024 Multiline When .F. Font oFont PIXEL OF oDlg
	@ 049,005 Get oResp Var cResp Size 258,010 COLOR CLR_BLACK PIXEL OF oDlg
	
	//Botoes
	DEFINE SBUTTON FROM 75,210 TYPE 1 ENABLE OF oDlg Action( If( Ft530VldPr("3",@cResp), oDlg:End(), .F. ))
	DEFINE SBUTTON FROM 75,240 TYPE 2 ENABLE OF oDlg Action( oDlg:End() )
	
ACTIVATE MSDIALOG oDlg CENTERED 

RestArea(aArea)

Return cResp
    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530PrAltบAutor  ณVendas CRM          บ Data ณ  23/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInterface para respostas de perguntas alternativas          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530PrAlt()

Local aArea		:= GetArea()
Local aAreaSKG	:= SKG->(GetArea())
Local aResp 	:= {}
Local cResp		:= "" 
Local cPerg		:= AllTrim(SKG->KG_DESC)
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )		//Imagem "Marcado"
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )		//Imagem "Desmarcado"                
Local oDlg		:= Nil    
Local oResp		:= Nil
Local oFont		:= Nil

Ft530LeRsp(SKG->KG_CODQST,@aResp)

If Len(aResp) > 0
	
	DEFINE FONT oFont NAME "Arial" SIZE 0,18 BOLD 
	
	DEFINE MSDIALOG oDlg TITLE STR0004 FROM 0,0 TO 300,535 PIXEL	//"Selecione uma alternativa"
	
		//Labels       
		@ 000,001 TO 038,267 LABEL STR0002 PIXEL OF oDlg	//"Pergunta"
		@ 040,001 TO 130,267 LABEL STR0003 PIXEL OF oDlg	//"Resposta"
	
		//Caixas de texto
		@ 009,005 Get oPerg Var cPerg Size 258,024 Multiline When .F. Font oFont PIXEL OF oDlg
		
		//Botoes
		DEFINE SBUTTON FROM 135,210 TYPE 1 ENABLE OF oDlg Action( If(Ft530VldPr("1",@cResp,oResp),oDlg:End(),.F.) )
		DEFINE SBUTTON FROM 135,240 TYPE 2 ENABLE OF oDlg Action( oDlg:End() )
	
		@ 049,005 ListBox oResp Fields HEADER " ",STR0005,STR0003 Size 257,075 Of oDlg Pixel //"Cod.Resp."###"Resposta"
	                                                                                               
		oResp:bLDblClick	:= {|| Ft530SelRs(@oResp) }
		oResp:SetArray(aResp)	
		oResp:bLine 		:= {|| {If(aResp[oResp:nAT,01],oOk,oNo),;
									aResp[oResp:nAT,02],;
									aResp[oResp:nAT,03]}}
	
	ACTIVATE MSDIALOG oDlg CENTERED 
	
Else
	
	MsgInfo(STR0006,STR0007) //"Nใo existem respostas associadas a esta questใo."###"Aten็ใo"

EndIf

RestArea(aAreaSKG)
RestArea(aArea)

Return cResp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530LeRspบAutor  ณVendas CRM          บ Data ณ  23/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega as respostas possiveis do SKH para a pergunta       บฑฑ
ฑฑบ          ณenviada no parametro.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Codigo da pergunta                                  บฑฑ
ฑฑบ          ณExpA2 - Array (recebido por referencia) de respostas.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530LeRsp(cPerg,aResp)

Local aAreaSKH	:= SKH->(GetArea())
Local cFilSKH	:= xFilial("SKH")

aResp	:= {}

DbSelectArea("SKH")
DbSetOrder(1) //KH_FILIAL+KH_CODQST+KH_CODALT
DbSeek(cFilSKH + cPerg)

While !SKH->(Eof()) 			.AND.;
	SKH->KH_FILIAL == cFilSKH	.AND.;
	SKH->KH_CODQST == cPerg

	If SKH->KH_HABILIT <> "2"
		AAdd(aResp, {.F., SKH->KH_CODALT, AllTrim(Capital(SKH->KH_DESC)) })
	EndIf

	SKH->(DbSkip())

End

RestArea(aAreaSKH)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530LeRspบAutor  ณVendas CRM          บ Data ณ  23/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAlterna o item selecionado para a listbox com respostas de  บฑฑ
ฑฑบ          ณperguntas alternativas.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto da listbox de respostas                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530SelRs(oResp)

Local nItMarca	:= 0
Local nX		:= 0
Local lMudou	:= .F.

For nX := 1 to Len(oResp:aArray)
	If (oResp:aArray[nX][1]) .AND. (oResp:nAt <> nX)
		nItMarca := nX
		Exit
	EndIf
Next nX

If !oResp:aArray[oResp:nAt][1]
	oResp:aArray[oResp:nAt][1] := .T.
	lMudou := .T.
EndIf

If lMudou .AND. nItMarca > 0
	oResp:aArray[nItMarca][1] := .F.
EndIf

oResp:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530VldPrบAutor  ณVendas CRM          บ Data ณ  23/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a resposta da pergunta respondida.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Tipo da questao(1-Alternativa,3-Dissertativa)       บฑฑ
ฑฑบ          ณExpC2 - Texto da alternativa escolhida(referencia).         บฑฑ
ฑฑบ          ณExpO3 - Objeto da listbox de respostas                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530VldPr(cTipo,cResp,oResp)

Local lRet	:= .F.
Local nX	:= 0
Local lOk	:= .T.
Local cChar	:= ""

If cTipo == "1" //Alternativa

	If (nX := aScan(oResp:aArray,{|x| x[1] })) > 0  
		lRet 	:= .T.
		cResp	:= oResp:aArray[nX][2]
	End

ElseIf cTipo == "3" //Dissertativa

	cResp := AllTrim(cResp)

	If !Empty(cResp)

		nX := 1

		While nX <= Len(cResp) .AND. lOk
			cChar := SubStr(cResp,nX++,1)
			lOk := IsDigit(cChar) .OR. (cChar $ ".,")
		End
		
		If lOk
			lRet := .T.
		Else
			MsgStop(STR0008,STR0007) //"A resposta deve ser num้rica"###"Aten็ใo"
		EndIf
		
	EndIf  
	
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530RlPerบAutor  ณVendas CRM          บ Data ณ  24/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInterface para a associacao de perguntas para cada processo บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 - Opcao selecionada no aRotina                        บฑฑ
ฑฑบ          ณExpC2 - Tipo processo:1-Composicao;2-Modelo;3-Simulacao     บฑฑ
ฑฑบ          ณExpC3 - Codigo do processo                                  บฑฑ
ฑฑบ          ณExpC4 - Local (EDT/Tarefa) onde a pergunta foi relacionada. บฑฑ
ฑฑบ          ณExpL5 - Indica se deve ser exibida como tela de respostas.  บฑฑ
ฑฑบ          ณExpC6 - Versao da simulacao                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530RlPer(nOpcx	, cTipoOp	, cCodProc	, cLocaliz	,;
					lResp, cVersao	)

Local aArea		:= GetArea()
Local aHead		:= {}
Local aCol		:= {} 
Local aCposNao	:= {}
Local aAlter	:= {}
Local nOpc		:= aRotina[nOpcx][4]
Local nOpcGD	:= 0
Local lGrava	:= .F.
Local bAfterCols:= {|aC,aH|Ft530IniCp(aC,aH)}
Local bActResp	:= {||Ft530RsQst()}
Local bSeekFor	:= {||.T.}
Local cFieldOk	:= "" 

Static oGetD	:= Nil

Default cLocaliz	:= ""
Default lResp		:= .F.
Default cVersao 		:= "001"

aCposNao := IIf(lResp,{"AG6_TIPO"},{"AG6_TIPO","AG6_CODPRO","AG6_LOCAL","AG6_VERSAO","AG6_VERORI"})

SaveInter() //Salva status das variaveis private e public

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณA validacao Ft530RlFOk deve verificar se a pergunta estaณ
//ณse relacionando a uma tarefa ou ao modelo               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(cLocaliz)
	cFieldOk	:= "Ft530RlFOk(.F.)"
Else
	cFieldOk	:= "Ft530RlFOk(.T.)"
EndIf

DbSelectArea("AG6")
DbSetOrder(4) //AG6_FILIAL+AG6_TIPO+AG6_CODPRO+AG6_VERSAO+AG6_LOCAL+AG6_CODPER

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta GetDados das perguntasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lResp    
	//Se foi acionada para respostas exibe todas as perguntas
	bWhile	:=	{||AG6->AG6_FILIAL + AG6->AG6_TIPO + AG6->AG6_CODPRO + AG6->AG6_VERSAO}
ElseIf Empty(cLocaliz)
	bWhile		:= {||AG6->AG6_FILIAL + AG6->AG6_TIPO + AG6->AG6_CODPRO + AG6->AG6_VERSAO}
	bSeekFor	:= {||Empty(AG6->AG6_LOCAL)} //***Nao funcionou
Else
	bWhile	:=	{||AG6->AG6_FILIAL + AG6->AG6_TIPO + AG6->AG6_CODPRO  + AG6->AG6_VERSAO + AG6->AG6_LOCAL}
EndIf

cSeek 	:= 	xFilial("AG6") + cTipoOp + cCodProc + cVersao + cLocaliz

FillGetDados(nOpc,"AG6",4,cSeek,bWhile,bSeekFor,aCposNao,,,,,,@aHead,@aCol,bAfterCols)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriacao da telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlg TITLE STR0009 FROM 0,0 TO 265,660 PIXEL //"Perguntas"

//Label
@ 000,001 TO 117,325 LABEL STR0010 PIXEL OF oDlg //"Perguntas relacionadas:"

//Botoes
If lResp 
	@ 120,229 Button STR0011 Size 30,11 OF oDlg PIXEL Action Eval(bActResp) //"Responder"
EndIf

DEFINE SBUTTON FROM 120,265 TYPE 1 ENABLE OF oDlg Action( lGrava := IIf(lResp,Ft530VlRes(),.T.), oDlg:End() )
DEFINE SBUTTON FROM 120,295 TYPE 2 ENABLE OF oDlg Action( oDlg:End() )

//GetDados
nOpcGD	:= IIF((INCLUI .OR. ALTERA) .AND. !lResp,GD_INSERT+GD_UPDATE+GD_DELETE,0)
oGetD	:= MsNewGetDados():New(008,005,113,320,nOpcGD,,,,,,,cFieldOk,,,oDlg,aHead,aCol)

If lResp
	oGetD:oBrowse:bLDblClick := bActResp
EndIf
	
ACTIVATE MSDIALOG oDlg CENTERED 

If lGrava
	Ft530GrRes(	cTipoOp		, cCodProc , cLocaliz	, oGetD:aHeader	,;
				oGetD:aCols	, lResp, cVersao		)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a situacao anteriorณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea(aArea)
RestInter() //Restaura status das variaveis private e public

Return lGrava


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530VlResบAutor  ณVendas / Crm        บ Data ณ  12/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se houve resposta na confirma็ใo                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530A                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530VlRes()
Local InX := 0
Local lTemResp := .F.
Local nPosResp := aScan(oGetD:aHeader,{|x| AllTrim(x[2]) == "AG6_RESP"} )

If nPosResp > 0
	For InX := 1 To Len(oGetD:aCols)
	   If !Empty(oGetD:aCols[InX][nPosResp])
	   	lTemResp := .T.
	   	Exit
	   EndIf
	Next InX
EndIf

Return lTemResp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530GrResบAutor  ณVendas CRM          บ Data ณ  24/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGravacao das respostas/associacoes de perguntas             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Tipo processo:1-Composicao;2-Modelo;3-Simulacao     บฑฑ
ฑฑบ          ณExpC2 - Codigo do processo                                  บฑฑ
ฑฑบ          ณExpC3 - Local (EDT/Tarefa) onde a pergunta foi relacionada. บฑฑ
ฑฑบ          ณExpA4 - aHeader da GetDados                                 บฑฑ
ฑฑบ          ณExpA5 - aCols da GetDados                                   บฑฑ
ฑฑบ          ณExpL6 - Indica se deve ser exibida como tela de respostas.  บฑฑ
ฑฑบ			   ณExpL7 - Indica se foi posicionado numa EDT (AF5).          บฑฑ
ฑฑบ          ณExpC8 - Versao do processo                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530GrRes(	cTipoOp	, cCodProc	, cLocaliz	, aHead	,;
							aCol	, lResp, cVersao		)

Local aArea		:= GetArea()
Local nLin		:= 0
Local nCpo		:= 0
Local nPDel		:= Len(aHead)+1
Local nPRecn	:= aScan(aHead,{|x|"_REC_WT" $ x[2]}) 
Local cFilAG6	:= xFilial("AG6")

Default cVersao	:= "001"

DbSelectArea("AG6")
DbSetOrder(1)

For nLin := 1 to Len(aCol)

	If !aCol[nLin][nPDel]

		If aCol[nLin][nPRecn] > 0
			AG6->(DbGoTo(aCol[nLin][nPRecn]))
			RecLock("AG6",.F.)
		Else
			RecLock("AG6",.T.)
		EndIf
		
		If !lResp
		
			For nCpo := 1 to Len(aHead)				
				If 	("_REC_WT" $ aHead[nCpo][2]) .OR. ("_ALI_WT" $ aHead[nCpo][2]) .OR. (aHead[nCpo][10] == "V")
					Loop
				EndIf	
				AG6->(FieldPut(FieldPos(aHead[nCpo][2]),aCol[nLin][nCpo]))				
			Next nCpo			

			AG6->AG6_FILIAL	:= cFilAG6
			AG6->AG6_TIPO	:= cTipoOp 
			AG6->AG6_CODPRO	:= cCodProc
			AG6->AG6_LOCAL	:= cLocaliz
			AG6->AG6_VERSAO	:= cVersao
			AG6->AG6_VERORI	:= cVersao			
			
		Else   
		  
			AG6->AG6_RESP	:= aCol[nLin][aScan(aHead,{|x| AllTrim(x[2]) == "AG6_RESP"})]
			
		EndIf

		MsUnLock()
		
	Else 

		//Deleta registros marcados para exclusao
		If aCol[nLin][nPRecn] > 0
			AG6->(DbGoTo(aCol[nLin][nPRecn]))
			RecLock("AG6",.F.)
			DbDelete()
			MsUnLock()
		EndIf

	EndIf

Next nLin

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530IniCpบAutor  ณVendas CRM          บ Data ณ  24/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicializa os campos virtuais da getdados                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1 - aHeader da GetDados                                 บฑฑ
ฑฑบ          ณExpA2 - aCols da GetDados                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530IniCp(aCol,aHead)

Local aArea		:= GetArea()
Local nLin		:= Len(aCol)
Local nPDesc	:= aScan(aHead,{|x|AllTrim(x[2]) == "AG6_DSCPER"})
Local nPPerg	:= aScan(aHead,{|x|AllTrim(x[2]) == "AG6_CODPER"})

If (nPDesc > 0) .AND. (nPPerg > 0)
	aCol[nLin][nPDesc] := Posicione("SKG",1,xFilial("SKG")+aCol[nLin][nPPerg],"KG_DESC")
EndIf

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530RlFOkบAutor  ณVendas CRM          บ Data ณ  24/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao do campo digitado na getdados de perguntas        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpL1 - Indica se e uma tarefa(.T.) ou modelo(.F.)          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530RlFOk(lTarefa)

	Local aArea		:= GetArea()
	Local lRet		:= .T.	
	Local cVar		:= ReadVar()
	Local nPDesc	:= 0
	Local nPRecn	:= aScan(aHeader,{|x|"_REC_WT" $ x[2]})

	If cVar == "M->AG6_CODPER"
		
		nPDesc	:= aScan(aHeader,{|x|AllTrim(x[2]) == "AG6_DSCPER"})
		
		DbSelectArea("SKG")
		DbSetOrder(1)
		DbSeek( xFilial("SKG") + M->AG6_CODPER )
		aCols[n,nPDesc] := SKG->KG_DESC
			
		DbSelectArea("AG6")
		DbSetOrder(1)

		If !GdDeleted()

			If aCols[ n, nPRecn ] > 0
				AG6->(DbGoTo(aCols[ n, nPRecn ]))
				RecLock("AG6",.F.)
			Else
				RecLock("AG6",.T.)
			EndIf

			AG6->AG6_FILIAL	:= xFilial("AG6")
			AG6->AG6_TIPO	:= "2"
			AG6->AG6_CODPRO	:= M->AF1_ORCAME
			AG6->AG6_LOCAL	:= IIF( lTarefa, AF2->AF2_TAREFA, AF5->AF5_EDT )
			AG6->AG6_CODPER	:= M->AG6_CODPER
			AG6->AG6_VERSAO	:= "001"
			AG6->AG6_VERORI	:= "001"
			
			If !lTarefa
				AG6->AG6_EDT	:= "S"
			EndIf  
			
			MsUnlock()
			
		EndIf
		
	EndIf

	RestArea(aArea)
	aSize(aArea, 0)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530RsQstบAutor  ณVendas CRM          บ Data ณ  25/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAciona a interface de resposta e armazena seu retorno na li-บฑฑ
ฑฑบ          ณnha corrente.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530/FATA530A                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530RsQst() 

	MsgRun(STR0024,STR0025,{|| Ft530MsgRun() })	//"Aguarde aplicando resposta no projeto..."###"Pergunta(s)"		

Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530MsgRunบAutor  ณMicrosiga           บ Data ณ  30/09/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAciona a interface de resposta e armazena seu retorno na li- บฑฑ
ฑฑบ          ณnha corrente.                                                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATA530/FATA530A                                            บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530MsgRun()

Local cResp		:= ""

Local nPMarca	:= aScan(oGd[4]:AHEADER,{|x|AllTrim(x[2]) == "AG6_MARCA"	})
Local nPPerg	:= aScan(oGd[4]:AHEADER,{|x|AllTrim(x[2]) == "AG6_CODPER" })
Local npResp	:= aScan(oGd[4]:AHEADER,{|x|AllTrim(x[2]) == "AG6_RESP"   })
Local nRecAg6	:= aScan(oGd[4]:AHEADER,{|x|AllTrim(x[2]) == "AG6_REC_WT"	})
Local nSomaItem := 0

If	!aTail(oGd[4]:ACOLS[oGd[4]:nAt])

	cResp := Ft530Perg(oGd[4]:ACOLS[oGd[4]:nAt][nPPerg])

	If !Empty(cResp)

		oGd[4]:ACOLS[oGd[4]:nAt][npResp] 	:= cResp
		oGd[4]:ACOLS[oGd[4]:nAt][nPMarca] 	:= "checked"
		
		dbSelectArea("AG6")
		DbGoTo(oGd[4]:ACOLS[oGd[4]:nAt][nRecAg6])
		RecLock("AG6",.F.)
		AG6_RESP 	:= cResp
		AG6_MARCA 	:= "checked"
		MsUnLock()
		
		Ft530GrRsp(M->AF1_ORCAME,M->AF1_VERSAO,0,oGd[4]:ACOLS[oGd[4]:nAt][nPPerg],AG6->AG6_LOCAL) 
			
		If	AG6_EDT <> "S"			
		
			nSomaItem := Ft531Soma()
			
			If	nSomaItem >= 0
				M->AF2_QUANT := nSomaItem
			Endif 
							
			oGd[4]:Refresh()
			aObj[1][1]:Refresh()    
			
		Endif 
		
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530Perg บAutor  ณVendas CRM          บ Data ณ  23/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para exibicao de interface para resposta das pergun- บฑฑ
ฑฑบ          ณtas(SKG).                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Codigo da pergunta a ser exibida.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ft530Perg(cPerg)

Local aArea		:= GetArea()
Local aAreaSKG	:= SKG->(GetArea())
Local cResp		:= ""

DbSelectArea("SKG")
DbSetOrder(1)//KG_FILIAL+KG_CODQST  

If DbSeek(xFilial("SKG") + cPerg)

	If SKG->KG_TIPOQST == "1"
		cResp := Ft530PrAlt()
	ElseIf SKG->KG_TIPOQST == "3"
		cResp := Ft530PrDis()		
	Else
		MsgStop(STR0015, STR0007 )//"Tipo de questใo invแlido (m๚ltipla escolha)."###"Aten็ใo"
	EndIf

EndIf

RestArea(aAreaSKG)
RestArea(aArea)

Return cResp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530CpPrgบAutor  ณVendas CRM          บ Data ณ  28/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCopia as perguntas entre tarefas e modelos para a simulacao บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Tipo original (1-Composicao;2-Modelo;3-SimulacaoT.) บฑฑ
ฑฑบ          ณExpC2 - Codigo do processo original                         บฑฑ
ฑฑบ          ณExpC3 - Tipo de destino                                     บฑฑ
ฑฑบ          ณExpC4 - Codigo do processo de destino                       บฑฑ
ฑฑบ          ณExpC5 - Codigo da tarefa de origem                          บฑฑ
ฑฑบ          ณExpC6 - Codigo da tarefa de destino                         บฑฑ
ฑฑบ          ณExpL7 - Codigo da tarefa de destino                         บฑฑ
ฑฑบ          ณExpL8 - Versao da simulacao                                 บฑฑ
ฑฑบ          ณExpL9 - Versao da simula็ใo destino                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530CpPrg(cTipoOri, cCodOri	, cTipoDst	, cCodDst	,;
					cTarOri	, cTarDst, lEdt,	cVerOri, cVerDst)

Local aArea		:= GetArea()
Local aAreaAG6	:= AG6->(GetArea())
Local cFilAG6	:= xFilial("AG6")
Local aPergs	:= {}
Local nX		:= 0

Default cTarOri	:= Space(TamSX3("AG6_LOCAL")[1])
Default cTarDst	:= Space(TamSX3("AG6_LOCAL")[1])
Default lEdt	:= .F.
Default cCodOri 	:= "001"
Default cVerDst	:= "001"
 
DbSelectArea("AG6")
DbSetOrder(4) //"AG6_FILIAL+AG6_TIPO+AG6_CODPRO+AG6_VERSAO+AG6_LOCAL+AG6_CODPER"
DbSeek(cFilAG6+cTipoOri+cCodOri+cVerOri+cTarOri)

While	!AG6->(EOF())				.AND.;
		 AG6->AG6_FILIAL	== cFilAG6	.AND.;
		  AG6->AG6_TIPO 	== cTipoOri	.AND.;
		   AG6->AG6_CODPRO	== cCodOri	.AND.;
		   AG6->AG6_VERSAO	== cVerOri	.AND.;
		    If(Empty(cTarOri), Empty(AG6->AG6_LOCAL), AG6->AG6_LOCAL == cTarOri)
	
	AAdd( aPergs, AG6->AG6_CODPER )
	
	AG6->(DbSkip())
	
End

DbSetOrder(5) //AG6_FILIAL+AG6_TIPO+AG6_CODPRO+AG6_VERSAO+AG6_PROORI+AG6_VERORI+AG6_LOCAL+AG6_CODPER

For nX := 1 to Len(aPergs) 

	If !AG6->(DbSeek(cFilAG6+cTipoDst+cCodDst+cCodOri+cTarDst+aPergs[nX]))
		
		RecLock("AG6",.T.)
		AG6->AG6_FILIAL		:= cFilAG6
		AG6->AG6_TIPO		:= cTipoDst
		AG6->AG6_CODPRO		:= cCodDst
		AG6->AG6_VERSAO		:= cVerDst
		AG6->AG6_VERORI		:= cVerOri
		AG6->AG6_CODPER		:= aPergs[nX]
		AG6->AG6_LOCAL		:= cTarDst
		AG6->AG6_PROORI		:= cCodOri     //Processo Original
		AG6->AG6_MARCA		:= "nochecked"
		
		If AG6->(FieldPos("AG6_EDT")) > 0 .AND. lEdt
			AG6->AG6_EDT	:= "S"				
		EndIf  
		MsUnLock()

	EndIf
	
Next nX

RestArea(aAreaAG6)
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530ExForบAutor  ณVendas CRM          บ Data ณ  30/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta a formula relacionada a pergunta atual.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Codigo da pergunta                                  บฑฑ
ฑฑบ          ณExpC2 - Texto da resposta                                   บฑฑ
ฑฑบ          ณExpC3 - Codigo do projeto                                   บฑฑ
ฑฑบ          ณExpC4 - Codigo da tarefa                                    บฑฑ
ฑฑบ          ณExpl5 - Atualiza e confirma se ้ opera็ใo de soma/subtracao บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530ExFor(cPergunta,cResposta,cProjeto,cVersao,cTarefa,lSoma,cModOri,nValRef)

Local aArea		:= GetArea()
Local aAreaSKG	:= SKG->(GetArea())
Local nResult	:= 0  
Local nValor	:= 0
Local nFator	:= 0
Local cOperacao	:= ""
Local cFormula	:= ""
Local lContinua	:= .T.
Local cErro		:= ""
Local bBloco	:= Nil

Local bBlock	:= ErrorBlock()
Local bErro 	:= ErrorBlock( { |e| ChecErro(e) } )

Default cTarefa	:= ""
Default lSoma	:= .F.
Default cModOri := ""
Default nValRef	:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLocaliza a questaoณ 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SKG")
DbSetOrder(1) //KG_FILIAL+KG_CODQST

If (lContinua := DbSeek(xFilial("SKG") + cPergunta))
	cFormula	:= AllTrim(SKG->KG_FORMUL)
	nValor		:= SKG->KG_VALOR
	nFator		:= SKG->KG_FATOR
	cOperacao	:= SKG->KG_OPERA	//"1=Soma;2=Subtracao;3=Multiplicacao;4=Divisao"
	lSoma 		:= (cOperacao $ "12")
Else
	cErro		:= STR0018 + cPergunta + STR0019  //"Questใo "###" nใo encontrada."
EndIf

If lContinua
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLe o valor de referencia (tarefa ou projeto)ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If	nValRef == 0
		nValRef	:= Ft530Qtd(cProjeto,cTarefa,.F.,cModOri,cVersao)
	Endif 		

	Do Case
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExpressao ADVPL ou Funcaoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Case !Empty(cFormula)
			
			bBloco	:= &("{|cPergunta,cResposta,cProjeto,cTarefa,nValRef|" + cFormula + "}")
			
			BEGIN SEQUENCE
				nResult := Eval(bBloco,cPergunta,cResposta,cProjeto,cTarefa,nValRef)
			END SEQUENCE
			
			ErrorBlock(bBlock)
			
			If ValType(nResult) <> "N"
				MsgStop(STR0020  + cFormula + STR0021,STR0022) //"A fun็ใo "###" nใo retorna valores num้ricos."###"Erro"
				nResult := 0
			EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณOperacoes com valoresณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Case (nValor > 0)
			
			Do Case
				Case cOperacao == "1"
					nResult := nValor
				Case cOperacao == "2"
					nResult	:= -nValor
				Case cOperacao == "3"
					nResult	:= nValRef * nValor
				Case cOperacao == "4"
					nResult	:= nValRef / nValor
			EndCase
			
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณOperacoes com percentuaisณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Case (nFator > 0)

			nResult := nValRef * nFator
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณQuestao nao configuradaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Otherwise
		
			cErro	:= STR0016 + cPergunta + STR0023 //"A questใo "###" nใo foi configurada corretamente."
	
	EndCase

EndIf

If !Empty(cErro)
	MsgStop(cErro,STR0007) //"Aten็ใo!"
EndIf
		
RestArea(aAreaSKG)
RestArea(aArea)

Return nResult

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530FatorบAutor  ณVendas CRM          บ Data ณ  28/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os fatores de cada produto utilizado no projeto     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530Fator(cProjeto,cVersao)

Local aArea		:= GetArea()
Local aFatores	:= {}
Local cAliasSql	:= "TMP4"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSeleciona os produtos utilizados na simulacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Select(cAliasSql) > 0
	(cAliasSql)->(DbCloseArea())
EndIf

cQuery	:= "SELECT DISTINCT AF3_PRODUT,AF3_FATOR "
cQuery	+= " FROM " + RetSqlName("AF3")
cQuery	+= " WHERE D_E_L_E_T_ = '' " 
cQuery	+= " AND AF3_FILIAL = '" + xFilial("AF3") + "'"
cQuery	+= " AND AF3_ORCAME = '" + cProjeto + "'"
cQuery	+= " AND AF3_VERSAO = '" + cVersao + "'"
cQuery	+= " AND AF3_TAREFA <> ''" 

cQuery	:= ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSql,.T.,.T.)
DbGoTop()

While !(cAliasSql)->(Eof())
	AAdd(aFatores,{(cAliasSql)->AF3_PRODUT,(cAliasSql)->AF3_FATOR})
	(cAliasSql)->(DbSkip())
End

(cAliasSql)->(DbCloseArea())

RestArea(aArea)

Return aFatores

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFt530Qtd  บAutor  ณEduardo Gomes Juniorบ Data ณ  30/09/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a quantidade de horas para a tarefa selecionada     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA530                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ft530Qtd(cProjeto,cTarefa,lQtdOri,cModOri,cVersao)

Local aArea		:= Getarea()
Local aAreaADX	:= ADX->(GetArea())
Local cFilADX	:= xFilial("ADX")
Local nQtd		:= 0
Local cQuery	:= "" 

Local cAliasQry	:= "ADXTMP"

Default cTarefa	:= ""
Default lQtdOri  := .F.
Default cModOri  := ""

cTarefa := AllTrim(cTarefa)

If Select(cAliasQry) > 0
	(cAliasQry)->(DbCloseArea())
EndIf
	
cQuery	:= " SELECT "+IIf(lQtdOri," SUM(ADX_QTDORI) "," SUM(ADX_QUANT) ") + "ADX_QUANT "
cQuery	+= " FROM " + RetSqlName("ADX")
cQuery	+= " WHERE ADX_FILIAL = '" + cFilADX + "' AND ADX_ORCAME = '" + cProjeto + "' AND ADX_VERSAO = '"+cVersao+"'"

If !Empty(cTarefa)
	cQuery	+= " AND ADX_TAREFA = '" + cTarefa + "' "
ElseIf !Empty(cModOri)
	cQuery	+= " AND ADX_PROORI = '" + cModOri + "' "
EndIf

If TcSrvType() != "AS/400"
	cQuery	+= " AND D_E_L_E_T_ = '' "
Else
	cQuery	+= " AND @DELETED@ = '' "
EndIf

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
DbGoTop()
	
nQtd := (cAliasQry)->ADX_QUANT
	
(cAliasQry)->(DbCloseArea())
	
RestArea(aAreaADX)
RestArea(aArea)

Return nQtd
