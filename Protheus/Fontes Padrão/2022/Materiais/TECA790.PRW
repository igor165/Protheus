#include "TECA790.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 

//----------------------------------------------------------
/*/{Protheus.doc} TECA790()
Cadastro de Feriados 

@Return 	nil
@author 	Serviços
@since 		14/05/2014
/*/
//----------------------------------------------------------
Function TECA790()

Local oBrowse 

oBrowse := FwMBrowse():New()
oBrowse:SetAlias("AC0")
oBrowse:SetDescription(STR0001) // STR0001//"Cadastro de Feriados"
oBrowse:DisableDetails()
oBrowse:Activate()

Return(Nil) 


//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Cadastro de Feriados

@Return 	MenuDef
@author 	Serviços
@since 		14/05/2014
/*/
//----------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 		ACTION "AxPesqui" 				OPERATION 1	ACCESS 0 	// STR0002//"Pesquisar"
ADD OPTION aRotina TITLE STR0003 		ACTION "VIEWDEF.TECA790"		OPERATION 2	ACCESS 0 	// STR0003//"Visualizar"
ADD OPTION aRotina TITLE STR0004 		ACTION "VIEWDEF.TECA790" 		OPERATION 3	ACCESS 0 	// STR0004//"Incluir"
ADD OPTION aRotina TITLE STR0005		ACTION "VIEWDEF.TECA790"		OPERATION 4	ACCESS 0 	// STR0005//"Alterar"
ADD OPTION aRotina TITLE STR0006		ACTION "VIEWDEF.TECA790"		OPERATION 5	ACCESS 0 	// STR0006//"Excluir"
ADD OPTION aRotina TITLE STR0008		ACTION "VIEWDEF.TECA790"		OPERATION 9	ACCESS 0	// "Copiar"
ADD OPTION aRotina TITLE STR0034		ACTION "at790fac"				OPERATION 1 ACCESS 0	// "Ajustar datas" 
ADD OPTION aRotina TITLE STR0036		ACTION "AT790Canc"				OPERATION 3 ACCESS 0	// "Cancelamento de Feriado"
ADD OPTION aRotina TITLE STR0035 		ACTION "AT790Inc"				OPERATION 3 ACCESS 0	// "Remanejar"

Return(aRotina)



//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Cadastro de Feriados

@Return 	model
@author 	Serviços
@since 		14/05/2014
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel	// Modelo de dados que será construido
Local oStruAC0 		:= FWFormStruct(1,"AC0") 
Local oStruRR0		:= FwFormStruct(1,"RR0")
Local bCommit		:= {|oModel|At790Grv(oModel)}

oModel := MPFormModel():New("TECA790", /*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/ )

oStruRR0:SetProperty('RR0_DATA',MODEL_FIELD_KEY ,.F.)
oStruRR0:SetProperty('RR0_DATA',MODEL_FIELD_INIT,{||""})
oModel:AddFields("AC0MASTER",/*cOwner*/,oStruAC0, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:AddGrid('RR0DETAIL','AC0MASTER',oStruRR0)
oModel:SetRelation('RR0DETAIL', { { 'RR0_FILIAL', 'xFilial("RR0")' }, { 'RR0_CODCAL','AC0_CODIGO' } }, RR0->(IndexKey(3)) )

oModel:SetDescription(STR0007) // Cadastro de Feriados 									  //"Cadastro de Feriados"

//Configura o Grid para não duplicar a linha do Grid
oModel:GetModel("RR0DETAIL"):SetUniqueLine({"RR0_DATA"})

Return(oModel)


//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Cadastro de Feriados

@Return 	view
@author 	Serviços
@since 		15/05/2014
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel   	:= FWLoadModel("TECA790")  
Local oStruAC0 	:= FWFormStruct(2,"AC0")
Local oStruRR0	:= FwFormStruct(2,"RR0", { |cCpo| !AllTrim(cCpo)$"RR0_CODCAL+RR0_MESDIA+RR0_RHEXP"})

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_AC0",oStruAC0,"AC0MASTER")
oView:AddGrid("VIEW_RR0",oStruRR0,"RR0DETAIL")

oView:CreateHorizontalBox( "TELA" , 20 )
oView:CreateHorizontalBox("INFERIOR" , 80)
 
oView:SetOwnerView( "VIEW_AC0", "TELA" ) 
oView:SetOwnerView( "VIEW_RR0", "INFERIOR" ) 

Return(oView)

Function At790Grv(oModel)

Local nOpcx			:= oModel:GetOperation()
Local oMdlRR0		:= oModel:GetModel("RR0DETAIL")
Local lRet			:= .F.
Local cRR0MesDia	:= Space( TamSx3( "RR0_MESDIA" )[1] )
Local nLoop			:= 0

If nOpcx == MODEL_OPERATION_UPDATE .OR. nOpcx == MODEL_OPERATION_INSERT
	
	For nLoop := 1 To oMdlRR0:Length()
		oMdlRR0:GoLine(nLoop)
	
		If oMdlRR0:GetValue("RR0_FIXO") $ "sS"
			lRet := oMdlRR0:LoadValue("RR0_MESDIA", MesDia(oMdlRR0:GetValue("RR0_DATA")) )
		Else
			lRet := oMdlRR0:LoadValue("RR0_MESDIA", cRR0MesDia )
		EndIf
	
	Next nLoop
		
	lRet := FwFormCommit( oModel )
Else
	
	If oModel:VldData()
		lRet := FwFormCommit( oModel )
	EndIf

EndIf

Return(lRet)


//----------------------------------------------------------
/*/{Protheus.doc} at790fac
Responsável pela montagem e abertura da tela de ajustes em lote no calendário do GS

@author 	Diego Bezerra
@since 		18/03/2020
/*/
//----------------------------------------------------------
Function at790fac()

Local oDlgEscTela 	:= Nil
Local cQuery 		:= ""
Local oBrowse 		:= FWMBrowse():New()
Local cAls 			:= GetNextAlias()
Local aIndex 		:= {}
Local oColumn 		:= NIL
Local cVlFilter		:= ""
Local oPanel1		:= Nil
Local dData 		:= dDataBase
Local oOk			:= Nil
Local cMark			:= Nil
Default nOption		:= ""

cMark 	 := 'LBNO'
cQuery	 += AT790QRY(cMark)
cQuery 	 := ChangeQuery(cQuery)
		
Aadd( aIndex, "RR0_DATA" )

nSuperior := 0
nEsquerda := 0
nInferior := GetScreenRes()[2] * 0.6
nDireita  := GetScreenRes()[1] * 0.8
cVlFilter := REPLICATE(" ",TamSX3("RR0_DESC")[1])
nSize 	  := CalcFieldSize("C", 12, 0, "@!", STR0010)// "Descrição do feriado"

DEFINE MSDIALOG oDlgEscTela TITLE STR0011 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL //"Alteração em lote de calendário"

oPanel1 := TPanel():Create( oDlgEscTela, 5, 5, "", /*[ oFont ]*/, /*[ lCentered ]*/, /*[ uParam7 ]*/, /*[ nClrText ]*/, /*[ nClrBack ]*/,nDireita-25,  80  /*[ lLowered ]*/,.F. )

oSay := TSay():New( 003,000,{||OemToAnsi('<p>'+STR0012+'</p><br/>')},; //'<p>Deseja realizar a operação em lote para o calendário selecionado ou para todos? </p>'
		oPanel1,,TFont():New("Tahoma",,-13,.T.,.T.),,,,.T.,,,300,130,,,,,,.T.)     
@ 22, 00 Say oSay1 Prompt STR0013 OF oPanel1 SIZE nSize, 10 PIXEL //"Descrição do feriado"
@ 22, (nSize*2)+10 Say oSay1 Prompt STR0014 OF oPanel1 SIZE nSize, 10 PIXEL //"Data Final"
oOk := TButton():New( 032, nSize+10, STR0015 ,oPanel1,{|| TECA790FT(@cQuery,@oBrowse,cVlFilter) }, 38,12,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Filtrar"
@ 32, 00 MSGET cVlFilter SIZE 080,10 WHEN .T. OF oPanel1 PIXEL 
@ 32, (nSize*2)+10 GET oGet VAR dData SIZE nSize,10 OF oPanel1 PIXEL VALID !empty(dData) When .T.

oPanel2 := TPanel():Create( oDlgEscTela, 50, 0, , /*[ oFont ]*/, /*[ lCentered ]*/, /*[ uParam7 ]*/, /*[ nClrText ]*/, /*[ nClrBack ]*/,nDireita-400 , nInferior-80 , /*[ lLowered ]*/, /*[ lRaised ]*/ )

oBrowse := FWFormBrowse():New()
oBrowse:SetOwner(oPanel2)
oBrowse:SetDataQuery(.T.)
oBrowse:SetAlias(cAls)
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetQuery(cQuery)
oBrowse:SetSeek({|| .F. },{})
oBrowse:DisableReport() 
oBrowse:SetMenuDef("")
oBrowse:DisableDetails()
oBrowse:AddButton( OemTOAnsi(STR0016),{ || FwMsgRun(Nil,{|| lRet := AT790MOD(@oBrowse, dToS(dData), 'LBNO', @cVlFilter),}, Nil, STR0017),oBrowse:Refresh() },,,,.F.,1) //"Alterar datas"#"Alterando calendários..."	
oBrowse:AddButton( OemTOAnsi(STR0018),{ || A790SelAll( @oBrowse, @cMark, @cVlFilter ), oBrowse:refresh()  },,,,.F.,1) 	//"Marcar todos"

ADD MARKCOLUMN oColumn DATA { || IIF( (oBrowse:getAlias())->OK == "LBOK", "LBOK", "LBNO") };
DOUBLECLICK { |oBrowse| clickMarker(oBrowse) };
HEADERCLICK { |oBrowse| A790SelAll( @oBrowse, @cMark, @cVlFilter ), oBrowse:refresh() };
OF oBrowse

ADD COLUMN oColumn DATA { ||  AC0_CODIGO  } TITLE "COD.CALENDARIO" SIZE TamSX3("AC0_CODIGO")[1] OF oBrowse
ADD COLUMN oColumn DATA { ||  AC0_DESC  } TITLE "CALENDARIO" SIZE TamSX3("AC0_DESC")[1] OF oBrowse
ADD COLUMN oColumn DATA { ||  TecDToStr(STOD(RR0_DATA))  } TITLE "DATA" SIZE TamSX3("RR0_DATA")[1] OF oBrowse	
ADD COLUMN oColumn DATA { ||  RR0_DESC  } TITLE "DESCRICAO DO FERIADO" SIZE TamSX3("RR0_DESC")[1] OF oBrowse

oBrowse:Activate()
ACTIVATE MSDIALOG oDlgEscTela CENTERED

Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} TECA790FT
Realiza o filtro do browse

@author 	Diego Bezerra
@since 		18/03/2020
/*/
//----------------------------------------------------------
FUNCTION TECA790FT(cQuery,oBrowse,cVlFilter)

Local cQueryBk := cQuery
cQuery += "AND UPPER(RR0_DESC) LIKE UPPER('%"+ALLTRIM(cVlFilter)+"%') "
oBrowse:SetQuery(cQuery)
oBrowse:Refresh()
cQuery := cQueryBk	

Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} AT790MOD
Responsável por alterar a data dos calendários, em lote.

@author 	Diego Bezerra
@since 		17/03/2020
/*/
//----------------------------------------------------------
STATIC FUNCTION AT790MOD(oBrowse, cData, cMark, cFilter)

Local cAlias 	:= oBrowse:Alias()
Local nRec		:= 0
Local nLast 	:= 0
Local cLogErr	:= ""
Local cLogSuc	:= STR0019 + CRLF //"########### LOG DE PROCESSAMENTO ###########"
Local cLog		:= ""
Local cDtAnt	:= ""
Local nCount	:= 0
Local cCountEr	:= 0
Local aAreaTmp	:= ( oBrowse:getAlias() )->( GetArea() )
Local lSeek		:= .F.
Local aAux		:= {}
Local nX 		:= 0

DbSelectArea("RR0")
RR0->(DbSetOrder(1))
(cAlias)->(DBGOTOP())

While (cAlias)->(!EOF())
	IF (cAlias)->OK == "LBOK"
		nRec := (oBrowse:Alias())->REC
		RR0->(DbSetOrder(1))
		RR0->(DBGOTO( nRec ))
		lSeek := RR0->(DBSEEK((xFilial("RR0") + cData + (cAlias)->RR0_CODCAL)));
				.OR. ASCAN(aAux, {|x| x[3] == (cAlias)->AC0_CODIGO }) == 1

		IF ! lSeek
			nCount ++
			cDtAnt := (cAlias)->RR0_DATA
			aAdd(aAux,{nRec, cData, (cAlias)->AC0_CODIGO })

			cLogSuc += STR0020 + ALLTRIM((cAlias)->RR0_DESC) //"Feriado "
			cLogSuc += STR0021 + ALLTRIM((cAlias)->AC0_DESC) //" do calendário "
			cLogSuc += STR0022 + TecDToStr(STOD(cDtAnt)) + STR0023 + TecDToStr(STOD(cData)) + CRLF //" foi alterada de " # " para "
		ELSE
			cCountEr ++
			cLogErr += CRLF + STR0024 + ALLTRIM(RR0->RR0_DESC) + STR0025; //"O feriado " # " não pode ser alterado para a data "
					+ TecDToStr(STOD(cData)) + STR0026 + ALLTRIM((cAlias)->AC0_DESC)+")"; //" pois já existe um feriado nessa mesma data ("
					+ STR0027 + (cAlias)->AC0_CODIGO + ") "+ CRLF //" para esse calendário (calendário código "
		ENDIF
	ENDIF
	(cAlias)->(DBSKIP())
	nLast ++
EndDO

For nX := 1 to len(aAux)
	RR0->(DBGOTO( aAux[nX][1] ))
	RR0->(RECLOCK("RR0", .F.))
	RR0->RR0_DATA := SToD(aAux[nX][2])
	RR0->(MSUNLOCK())
Next nX

IF !EMPTY(cLogSuc)
	cLogSuc = STR0028 + cValToChar(nCount) + STR0029 + CRLF + CRLF + cLogSuc //"FORAM ALTERADOS " # " registros "
ELSE
	cLogSuc += STR0030 + CRLF //"Não foi alterado nenhum registro."
ENDIF

IF cCountEr > 0
	cLogErr = STR0031  + cValToChar(cCountEr) + STR0032 + CRLF + cLogErr //"Foram encontrado(s) " # " erro(s) "
EndIf
cLog := cLogSuc + CRLF + cLogErr
AtShowLog(cLog, STR0033, .T., .T., .T.) //"Alterações nos cadastros de feriados do GS"
(cAlias)->(dbGoTo(nLast))

oBrowse:setQuery(AT790QRY(cMark, cFilter))

RestArea( aAreaTmp )
aSize( aAreaTmp, 0 )

Return 

//----------------------------------------------------------
/*/{Protheus.doc} AT790MOD
Realiza a marcação de uma coluna no browse

@param oBrowse, objeto, FWFORMBROWSE

@author 	Diego Bezerra
@since 		19/03/2020
/*/
//----------------------------------------------------------
STATIC FUNCTION clickMarker(oBrowse)
If (oBrowse:Alias())->OK == 'LBOK'
	(oBrowse:Alias())->OK := 'LBNO'
Else
	(oBrowse:Alias())->OK := 'LBOK'
EndIf

RETURN .T.


//----------------------------------------------------------
/*/{Protheus.doc} AT790MOD
Realiza a marcação de todos os registros do browse

@param oBrowse, objeto, FWFORMBROWSE
@param	string, valor da marca utilizada na markcolumn
@author 	Diego Bezerra
@since 		19/03/2020
/*/
//----------------------------------------------------------
STATIC FUNCTION A790SelAll( oBrowse, cMark, cFilter )

Local aAreaTmp	:= ( oBrowse:getAlias() )->( GetArea() )	

( oBrowse:getAlias() )->( DbGoTop() )

While ( oBrowse:getAlias() )->( !Eof() )
	clickMarker(oBrowse)
	( oBrowse:getAlias() )->( DbSkip() )
Enddo

IF cMark == 'LBNO'
	cMark := 'LBOK'
ELSE
	cMark := 'LBNO'
ENDIF
RestArea( aAreaTmp )
aSize( aAreaTmp, 0 )

oBrowse:setQuery(AT790QRY(cMark, cFilter))

RETURN

//----------------------------------------------------------
/*/{Protheus.doc} AT790MOD
Atualiza a query utilizada no FWFORMBROWSE

@param cMark, string, novo valor para a marca da coluna ('LBNO' ou 'LBOK')
@param	string, valor da marca utilizada na markcolumn
@author 	Diego Bezerra
@since 		19/03/2020
/*/
//----------------------------------------------------------
STATIC FUNCTION AT790QRY(cMark, cFilter)

Local cQuery := ""

cQuery += "SELECT '"+cMark+"' OK, AC0_CODIGO, AC0_DESC, RR0_DATA, RR0_DESC, RR0_CODCAL, RR0.R_E_C_N_O_ REC " 
cQuery += "FROM "+retSqlName('AC0')+" AC0 INNER JOIN " +retSqlName("RR0")+" RR0 "
cQuery += "ON AC0.AC0_CODIGO = RR0.RR0_CODCAL "
cQuery += "WHERE AC0_FILIAL = '"+xFilial('AC0')+"' AND RR0_FILIAL = '"+xFilial('RR0')+"' "
cQuery += "AND AC0.D_E_L_E_T_ = ' ' AND RR0.D_E_L_E_T_ = ' ' "
If !Empty(cFilter)
	cQuery += "AND UPPER(RR0_DESC) LIKE UPPER('%"+ALLTRIM(cFilter)+"%') "
ENDIF

RETURN cQuery

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT790Canc
@description Abre a opção de cancelamento de feriado.
@return 
@author Augusto Albuquerque
@since  15/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT790Canc()
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,STR0038},{.T.,STR0039},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}} // "Salvar" # "Cancelar"
FwExecView( STR0036, "VIEWDEF.TECA790A", MODEL_OPERATION_INSERT, /*oOwner*/, {||.T.}, /*bOk*/, 45, aButtons ) // "Cancelamento de Feriado"
Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT790Inc
@description Abre a opção de Inclusão de feriado par ao novo dia
@return 
@author Diego Bezerra
@since  15/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT790Inc()
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,STR0038},{.T.,STR0039},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}} // "Salvar" # "Cancelar"
FwExecView( STR0037, "VIEWDEF.TECA790A", MODEL_OPERATION_INSERT, /*oOwner*/, {||.T.}, /*bOk*/, 45, aButtons ) // "Cancelamento"
Return

