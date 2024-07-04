#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "FINA720.ch"
#DEFINE nAgrAlu  1
#DEFINE nAgrBol  2
#DEFINE nAgrPrd  3
#DEFINE nAgrOnly 4
#DEFINE nAgrNot  5

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Geração de NF a partir dos títulos a Receber

@author David

@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function FINA720()

Private aRotina    	:= MenuDef()
Private oNoMarked  	:= LoadBitmap( GetResources(), 'LBNO' )
Private oMarked	  	:= LoadBitmap( GetResources(), 'LBOK' )

If cPaisLoc == "BRA"
	If SuperGetMV( "MV_RMCLASS", .F. , .F. )
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("SE1")
		oBrowse:SetDescription("Gerar NF")//"Gerar NF"

		oBrowse:AddLegend( "EMPTY(E1_PRODUTO)"                          , "WHITE", STR0038 )//"Título sem produto vinculado."	
		oBrowse:AddLegend( "EMPTY(E1_CHAVENF) .and. !EMPTY(E1_PRODUTO)" , "GREEN", STR0025 )//"Título não faturado"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
		oBrowse:AddLegend( "!EMPTY(E1_CHAVENF).and. !EMPTY(E1_PRODUTO)" , "RED"  , STR0026)//"Título faturado"

		// Remove os botões de navegação na edição ou visualização do model
		oBrowse:SetUseCursor(.F.)
	
		oBrowse:Activate()
	Else
		MsgInfo(STR0035) //"Função disponível apenas se o parêmetro de integração RM Classis estiver ativo."
	EndIf
Else
	MsgInfo(STR0036) //"Função disponível apenas para o Brasil."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author David

@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStr1:= FWFormStruct(1,'SE1')

oModel := MPFormModel():New('ModelName')

oModel:addFields('FIELD1',,oStr1)

oModel:SetPrimaryKey({'E1_FILIAL','E1_NUM','E1_PARCELA','E1_TIPO','E1_PREFIXO'})//Chave primária

oModel:SetDescription("Geração de NF")//"Geração de NF"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author David

@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1   := FWFormStruct(2,'SE1')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddField('VIEW_SE1',oStr1,'FIELD1')

oView:CreateHorixontalBox('TELA',100)

oView:SetOwnerView('VIEW_SE1','TELA')  

// Força o fechamento da tela ao salvar o model
oView:SetCloseOnOk({|| .T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu do sistema

@author David

@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {} 

ADD OPTION aRotina Title STR0001	Action 'FI720GERNF' 		OPERATION 3	ACCESS 0 		//"Gerar NF"
ADD OPTION aRotina Title STR0002	Action 'FI720ESTNF' 		OPERATION 2	ACCESS 0 		//"Estornar NF"
ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.FINA720' 	OPERATION 2	ACCESS 0 		//"Visualizar"

Return aRotina 

//-------------------------------------------------------------------
/*/{Protheus.doc} FI720GERNF
hamada para funcao que processara a Nota Fiscal

@author David

@since 02/04/2014
@version 1.0
/*/
//------------------------------------------------------------------- 
Function FI720GERNF(cAlias, nReg, nOpc, nItem )
Local lRet 		:= .T.
Local cSerie	:= ""
Local lSerie	:= .F.   
Local aGerNF 	:= {}  
Local dDataNf1  := Date() 
Local cProcNF1  := FRJ->FRJ_NUMPRO
Local nCount	:= 0
Local oDifnf, oBtGera, oBtVoltar, oDataNf, oDataNf1, oProcNF, oProcNF1
Local aAgrupa   := {STR0019, STR0020} 

Private cAgrupa := ""

aGerNF := FI20SelSE1(@nCount)	

If 	Len(aGerNf) > 0
	lSerie := Sx5NumNota(@cSerie,SuperGetMV("MV_TPNRNFS")) 	  
	If lSerie
		
		If nCount > 0

			//Monta o Dialog de "Geracao de NFs"
			oDlgGeNf := MSDIALOG():Create()
			oDlgGeNf:cName := "oDlgGeNf"
			oDlgGeNf:cCaption := STR0004  //"Geração de NFs "
			oDlgGeNf:nLeft := 0
			oDlgGeNf:nTop := 0
			oDlgGeNf:nWidth := 850
			oDlgGeNf:nHeight := 550
			oDlgGeNf:lShowHint := .F.
			oDlgGeNf:lCentered := .T.

			//Monta a getDados de "Geracao de NFs"
			oDifnf := TWBrowse():New( 01,01,420,230/*<nHeight>*/, /*[\{|| \{<Flds> \} \}]*/, {"X", STR0027, STR0042, STR0028, STR0029, STR0034, STR0030, STR0031, STR0032 }/*[\{<aHeaders>\}]*/, {20, 35, 20, 80, 35, 80,40}/*[\{<aColSizes>\}]*/, oDlgGeNf/*<oDlg>*/, /*<(cField)>*/, /*<uValue1>*/, /*<uValue2>*/, /*[<{uChange}>]*/, /*[\{|nRow,nCol,nFlags|<uLDblClick>\}]*/, /*[\{|nRow,nCol,nFlags|<uRClick>\}]*/, /*<oFont>*/, /*<oCursor>*/, /*<nClrFore>*/, /*<nClrBack>*/, /*<cMsg>*/, /*<.update.>*/, /*<cAlias>*/, .T./*<.pixel.>*/, /*<{uWhen}>*/, /*<.design.>*/, /*<{uValid}>*/, /*<{uLClick}>*/, /*[\{<{uAction}>\}]*/ ) //"Opções"
			oDifnf:SetArray(aGerNF)
			oDifnf:bLine := {|| {if(aGerNF[oDifnf:nAt,1], oMarked, oNoMarked), aGerNF[oDifnf:nAt,2], aGerNF[oDifnf:nAt,9], aGerNF[oDifnf:nAt,3], aGerNF[oDifnf:nAt,4], aGerNF[oDifnf:nAt,5],aGerNF[oDifnf:nAt,6], aGerNF[oDifnf:nAt,7], aGerNF[oDifnf:nAt,8]   } }
			oDifnf:bLDblClick := {|| FI020Mark( @oDifnf, @aGerNF  ) }
			oDifnf:bHeaderClick := {|x,y| if(y==1, F020MrkAll(@oDifnf, @aGerNF), FI020Ordem(@oDifnf, @aGerNF, y)) }

			//Monta o Say "Processo"
			oProcNF:= TSAY():Create(oDlgGeNf)
			oProcNF:cName := "oProcNF"
			oProcNF:cCaption := STR0033//Agrupa Clientes?
			oProcNF:nLeft := 90
			oProcNF:nTop := 489
			oProcNF:nWidth := 70
			oProcNF:nHeight := 16
			oProcNF:lShowHint := .F.
			oProcNF:lReadOnly := .F.
			oProcNF:Align := 0
			oProcNF:lVisibleControl := .T.
			oProcNF:lWordWrap := .F.
			oProcNF:lTransparent := .F.

			//Monta o Get "Processo"
			oProcNF1 := TComboBox():New(,,{|u| If(PCount()>0,cAgrupa:=u,cAgrupa)},aAgrupa,100,006,oProcNF1,,,,,,.T.,,,,)
			oProcNF1:cName := "oProcNF1"
			oProcNF1:nLeft := 190
			oProcNF1:nTop := 489
			oProcNF1:nWidth := 80
			oProcNF1:nHeight := 21
			oProcNF1:lShowHint := .F.
			oProcNF1:Align := 0
			oProcNF1:cVariable := "cProcNF1"
			oProcNF1:bSetGet := {|u| If(PCount()>0,cAgrupa:=u,cAgrupa) }
			oProcNF1:lVisibleControl := .T.
			oProcNF1:bWhen := {|| .T.}

			//Monta o Say "Data Emissao NF"
			oDataNf:= TSAY():Create(oDlgGeNf)
			oDataNf:cName := "oDataNf"
			oDataNf:cCaption := STR0005//"Data Emissão NF:"
			oDataNf:nLeft := 290
			oDataNf:nTop := 489
			oDataNf:nWidth := 80
			oDataNf:nHeight := 16
			oDataNf:lShowHint := .F.
			oDataNf:lReadOnly := .F.
			oDataNf:Align := 0
			oDataNf:lVisibleControl := .T.
			oDataNf:lWordWrap := .F.
			oDataNf:lTransparent := .F.

			//Monta o get "Data Emissao NF"
			oDataNf1:= TGET():Create(oDlgGeNf)
			oDataNf1:cName := "oDataNf1"
			oDataNf1:nLeft := 375
			oDataNf1:nTop := 489 
			oDataNf1:nWidth := 80
			oDataNf1:nHeight := 21
			oDataNf1:lShowHint := .F.
			oDataNf1:Align := 0
			oDataNf1:cVariable := "dDataNf1"
			oDataNf1:bSetGet := {|u| If(PCount()>0,dDataNf1:=u,dDataNf1) }
			oDataNf1:lVisibleControl := .T.
			oDataNf1:lPassword := .F.
			oDataNf1:Picture := "@D"
			oDataNf1:lHasButton := .F.
			oDataNf1:bValid := {|| .T.}

			//Monta o Botao "Gerar NFs"
			oBtGera:= TButton():Create(oDlgGeNf)
			oBtGera:cName := "oBtGera"
			oBtGera:cCaption := STR0006 //"Gerar NF"
			oBtGera:nLeft := 540
			oBtGera:nTop := 485
			oBtGera:nWidth := 90
			oBtGera:nHeight := 25
			oBtGera:lShowHint := .F.
			oBtGera:lReadOnly := .F.
			oBtGera:Align := 0
			oBtGera:bAction := {|| Processa( { |lEnd| if(.T.,lRet := FRJ020NF(cSerie, aGerNF, dDataNf1),lRet:=.F.)}, STR0023 ) , If(lRet,oDlgGeNf:End(),lRet:=.F.) }     //Processando...

			//Monta o Botão "Voltar"
			oBtVoltar:= TButton():Create(oDlgGeNf)
			oBtVoltar:cName 	:= "oBtVoltar"
			oBtVoltar:cCaption 	:= STR0007 //"Voltar"
			oBtVoltar:nLeft 	:= 640
			oBtVoltar:nTop 		:= 485
			oBtVoltar:nWidth 	:= 90
			oBtVoltar:nHeight 	:= 25
			oBtVoltar:lShowHint := .F.
			oBtVoltar:lReadOnly := .F.
			oBtVoltar:Align 	:= 0
			oBtVoltar:bAction 	:= {|| oDlgGeNf:End() }

			oDlgGeNf:Activate()
		Else
			MsgInfo(STR0008) //"Não há dados para geração de nota Fiscal"
		Endif
	Endif	
Else	
	MsgInfo(STR0008) //"Não há dados para geração de nota Fiscal"
Endif

Return( lRet ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} FI20SelSE1
NF-e Educacional com Integracao RM

@param nCount

@return aRet

@author David
@since 02/04/2014
@version P12 
/*/
//-------------------------------------------------------------------
Static Function FI20SelSE1(nCount)

Local aRet 		:= {}
Local cQuery 	:= ""
Local cNomeCli 	:= ""

Dbselectarea("SX1")
Dbsetorder(1) 
If !dbSeek("FINA720") 
	MSGINFO(STR0040) // "Grupo de perguntas 'FINA720' não existente no dicionário SX1, por favor atualizar seu dicionário de dados"
	return aRet
Endif

pergunte("FINA720",.T.)

cQuery := "SELECT E1_NUM, E1_PRODUTO, E1_CLIENTE, E1_PREFIXO, E1_PARCELA, E1_TIPO, E1_CHAVENF, E1_LOJA "+CRLF
cQuery += "FROM "+RetSQLName("SE1")+" SE1"+CRLF
cQuery += "WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"'"+CRLF
cQuery += " AND SE1.E1_VENCREA BETWEEN '" + DtoS(MV_PAR03) + "' AND '" + DtoS(MV_PAR04) + "' "+CRLF
cQuery += " AND SE1.E1_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "+CRLF
cQuery += " AND SE1.E1_PREFIXO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "+CRLF
cQuery += " AND SE1.E1_NUMRA   BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "+CRLF
If MV_PAR09 == 1
	cQuery += " AND SE1.E1_BAIXA <> '' "+CRLF
ElseIf MV_PAR09 == 2
	cQuery += " AND SE1.E1_BAIXA = '' "+CRLF
Endif
cQuery += " AND SE1.E1_CHAVENF = '' "+CRLF
cQuery += " AND SE1.E1_PRODUTO  <> ''"+CRLF
cQuery += " AND SE1.D_E_L_E_T_  <> '*'"+CRLF
cQuery += " ORDER BY SE1.E1_NUM, SE1.E1_PRODUTO, SE1.E1_CLIENTE"+CRLF

cQuery := ChangeQuery( cQuery )

IIF(Select("QRYSE1")>0,QRYSE1->(dbCloseArea()),Nil)
dbUseArea(.T., "TopConn", TCGenQry(,,cQuery), "QRYSE1", .F., .F.) 

QRYSE1->( dbEval( {|| nCount++ } ) )
QRYSE1->( dbGoTop() )

While QRYSE1->( !EOF() )

	//Coleta o nome do Cliente
	If RetGlbLGPD("A1_NOME")
		cNomeCli := Replicate("*", TamSX3("A1_NOME")[1])
	Else
		cNomeCli := alltrim(Posicione("SA1",1,xFilial("SA1")+QRYSE1->(E1_CLIENTE+E1_LOJA), "A1_NOME"))
	Endif

	//Monta o retorno (aCols)
	Aadd( aRet, {.F.,QRYSE1->E1_CLIENTE,cNomeCli,QRYSE1->E1_PRODUTO,QRYSE1->E1_NUM,QRYSE1->E1_PREFIXO, QRYSE1->E1_PARCELA, QRYSE1->E1_TIPO, QRYSE1->E1_LOJA} )
	QRYSE1->( DbSkip() )
End

QRYSE1->( dbCloseArea() )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FI020Mark
Evento de duplo click na ListBox

@param oList
@param aArray

@author David
@since 02/04/2014
@version P12 
/*/
//-------------------------------------------------------------------
Static Function FI020Mark( oList, aArray )

aArray[oList:nAt,1] := !aArray[oList:nAt,1]
oList:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F020MrkAll
Evento de "Marca Tudo" na ListBox

@param oList
@param aArray

@author David
@since 02/04/2014
@version P12 
/*/
//-------------------------------------------------------------------
Static Function F020MrkAll( oList, aArray )
Local nCont := 0

aEval( aArray, { |x| nCont += iif( x[1], 1, 0 ) } )

if nCont == len(aArray)
	aEval( aArray, {|x| x[1] := .F.} )
else
	aEval( aArray, {|x| x[1] := .T.} )
endif

oList:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FI020OrdemºAutor  ³ Alberto Deviciente º Data ³ 19/Nov/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ordena o List conforme coluna clicada.                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro - NF-e Educacional com Integracao RM            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} FI020Ordem
Ordena o List conforme coluna clicada

@param oList
@param aArray
@param nColClick

@author David
@since 02/04/2014
@version P12 
/*/
//-------------------------------------------------------------------
Static Function FI020Ordem( oList, aArray, nColClick )

Static nColAnt

if nColAnt == nil
	nColAnt := 0
endif

if nColAnt <> nColClick
	Asort(aArray,,, { |x,y| x[nColClick] < y[nColClick] }) //Ordena o array
	oList:Refresh()
	nColAnt := nColClick
endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRJ020NF  ºAutor  ³Alberto Deviciente  º Data ³  19/Nov/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao de Notas Fiscais (Varios itens por NF)             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro - NF-e Educacional com Integracao RM            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Frj020Nf(cSerie, aGerNF, dDataNf1)

Fi020UIte(cSerie, aGerNF, dDataNf1)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fi020VIte ºAutor  ³Microsiga           º Data ³  18/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao de Notas Fiscais (Unico iten por NF)               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro - NF-e Educacional com Integracao RM            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Fi020UIte(cSerie, aGerNF, dDataNf1)

Local aCabec		:= {}
Local aItem			:= {}
Local nValPed		:= 0
Local nValDeducao	:= 0
Local j				:= 0
Local nItemSD2		:= 0
Local cNota			:= ""   
Local dDtEfet
Local cHrEfet
Local cUsEfet 
Local nInd			:= 1             
Local aStruSD2   	:= SD2->(dbStruct())
Local aStruSF2   	:= SF2->(dbStruct())
Local aSF2RecNo  	:= {}
Local nProcTot		:= 0 
Local nCont			:= 0
Local cCliente      := ""
Local cLoja         := ""
Local i				:= 0
Local nX            := 1
Local cCountTot 	:= ""
Local cCdCli    	:= ""
Local cRaAluno      := ""
Local cCodTES 		:= ""
Local aInRecSE1 	:= {}
Local cAgrup		:= ""
Local cCCusto		:= ""
Local cCValor		:= ""
Local cItemC		:= ""
Local cPdVen		:= ""
Local aAreaSA1		:= {}
Local aAreaSB1		:= {}
Local aArea			:= {}

aEval( aGerNF, {|x| nProcTot += if(x[1], 1, 0)} )
cCountTot := AllTrim(str(nProcTot))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre e seta areas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB1")
dbSelectArea("SD2")
dbSelectArea("SA1")
dbSelectArea("SE1")
SB1->( dbSetOrder(1) ) //B1_FILIAL+B1_COD
SA1->(dbSetOrder(1)) 	//A1_FILIAL+A1_COD+A1_LOJA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta regua de processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua( nProcTot )
IncProc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime todas as notas dos Clientes marcados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While nInd <= len(aGerNF)
	If aGerNF[nInd,1]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Coleta cod. cli e cod RA e incrementa regua³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCont++		
		IncProc( STR0009 +AllTrim(str(nCont)) + " / " +cCountTot) //"Gerando NF: "
		cCdCli 		:= aGerNF[nInd,2]
		cRaAluno 	:= aGerNF[nInd,4]
		If !SA1->( dbSeek( xFilial("SA1")+cCdCli+aGerNF[nInd,9] ) )
			MsgAlert(STR0010 + cCdCli + CHR(10)+CHR(10) + STR0011) //"Nao foi encontrado o Cliente: " "O processamento será abortado!"
			Return .F.
		Endif

		//Inicializa variaveis
		aCabec		:= {}
		aItem		:= {}
		aSF2RecNo   := {}
		nItemSD2	:= 0
		aInRecSE1	:= {}

		//Agrupa Item
		If cAgrupa == "2"//2- Sim
			cCliente := aGerNF[nX][2]
			cLoja    := aGerNF[nX][9]
		EndIf

		//Pra Cada Itens a serem gera uma NF
		While nX <= Len(aGerNF)

			If aGerNF[nX,1]

				//Valida produto			
				if !SB1->( dbSeek( xFilial("SB1")+aGerNF[nX][4] ) )
					MsgAlert(STR0012 + "("+aGerNF[nX][4]+")" + CHR(10)+CHR(10) + STR0011) //"Não foi encontrado o Produto: " "O processamento será abortado!"
					Return .F.
				endif

				SE1->(DbSelectArea("SE1"))
				SE1->(DbSetOrder(1))
				If !SE1->(DbSeek(xFilial('SE1')+aGerNF[nX][6]+aGerNF[nX][5]+aGerNF[nX][7]+aGerNF[nX][8]))
					MsgAlert("Título não encontrado: " + "("+aGerNF[nX][5]+")" + CHR(10)+CHR(10) + STR0013) //"Título não encontrado
					Return .F.
				EndIf

				cCodTES := RetFldProd(SB1->B1_COD,"B1_TS") 
				nValPed	:= SE1->E1_VALOR
				nValDeducao := 0//Round(QRY080NF->DESCON,2)
				cAgrup  := ""//QRY080NF->AGRUP			
				cCCusto	:= ""//QRY080NF->FRK_CCUSTO
				cCValor	:= ""//QRY080NF->FRK_CLVL
				cItemC	:= ""//QRY080NF->FRK_ITEMCC
				cCond   := POSICIONE('SA1',1,xFilial('SA1')+aGerNF[nX][2]+aGerNF[nX][9], "A1_COND")

				aadd(aItem,{})
				nItemSD2++

				SF4->(DbSetOrder(1)) //F4_FILIAL+F4_CODIGO
				If !SF4->(DbSeek(xFilial("SF4") + cCodTES ))
					MsgAlert(STR0014 +cCodTES + CHR(10)+CHR(10) + STR0011 ) //"Não foi encontrado o TES: " "O processamento será abortado!"
					Return .F.
				Endif

				aAdd( aInRecSE1, SE1->(RECNO()))
				aAdd( aSF2RecNo, 0 )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de entrada para o cliente criar um pedido de venda customizado caso deseje³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("Fi020PrvNf")
					aAreaSA1 := SA1->(getArea())
					aAreaSB1 := SB1->(getArea())
					aArea	 := getArea()
					cPdVen 	:= ExecBlock("Fi020PrvNf", .F., .F., { } )
					RestArea(aAreaSA1)
					RestArea(aAreaSB1)
					RestArea(aArea)
				Endif

				For j := 1 to len(aStruSD2)		
					Do Case
						Case ALLTRIM(aStruSD2[j][1]) == 'D2_FILIAL'
							Aadd( aItem[nItemSD2], xFilial("SD2")	)		// Filial

						Case ALLTRIM(aStruSD2[j][1]) == 'D2_ITEM'
							Aadd( aItem[nItemSD2], StrZero(nItemSD2,2)	)	// Item
							
						Case ALLTRIM(aStruSD2[j][1]) == 'D2_COD'
							Aadd( aItem[nItemSD2], SB1->B1_COD 	)			// Produto

						Case ALLTRIM(aStruSD2[j][1]) == 'D2_UM'
							Aadd( aItem[nItemSD2], SB1->B1_UM 		)		// Unidade de medida

						Case ALLTRIM(aStruSD2[j][1]) == 'D2_QUANT'
							Aadd( aItem[nItemSD2],  1         		)		// Quantidade

						Case ALLTRIM(aStruSD2[j][1]) == 'D2_PRCVEN'
							Aadd( aItem[nItemSD2], nValPed	   		) 		// Preco unitario
						
						Case ALLTRIM(aStruSD2[j][1]) == 'D2_TOTAL'
							Aadd( aItem[nItemSD2], nValPed    		) 		// Valor total do item

						Case ALLTRIM(aStruSD2[j][1]) == 'D2_TES'
							Aadd( aItem[nItemSD2], cCodTES 			)		// TES

						Case ALLTRIM(aStruSD2[j][1]) == 'D2_CF'
							Aadd( aItem[nItemSD2], SF4->F4_CF 		)		// Codigo Fiscal    
							
						Case ALLTRIM(aStruSD2[j][1]) == 'D2_DESCON'
							Aadd( aItem[nItemSD2],  nValDeducao		)		// Desconto 

						Case ALLTRIM(aStruSD2[j][1]) == 'D2_PEDIDO'
							Aadd( aItem[nItemSD2], ' '  			)		// Pedido de Venda

						Case ALLTRIM(aStruSD2[j][1]) == 'D2_CLIENTE'
							Aadd( aItem[nItemSD2], SA1->A1_COD 	)			// Cliente
						
						Case ALLTRIM(aStruSD2[j][1]) == 'D2_LOJA'
							Aadd( aItem[nItemSD2], SA1->A1_LOJA 	)		// Loja

						Case ALLTRIM(aStruSD2[j][1]) == 'D2_TP'
							Aadd( aItem[nItemSD2], SB1->B1_TIPO		)		// Tp Produto

						Case ALLTRIM(aStruSD2[j][1]) == 'D2_EMISSAO'
							Aadd( aItem[nItemSD2], dDataBase  		)		// Emissao

						Case ALLTRIM(aStruSD2[j][1]) == 'D2_PRUNIT'
							Aadd( aItem[nItemSD2], nValPed    		) 		// Valor unitario do item

						Case ALLTRIM(aStruSD2[j][1]) == 'D2_TIPO'
							Aadd( aItem[nItemSD2], "N"	        	)		// Tipo											

						Case ALLTRIM(aStruSD2[j][1]) == 'D2_CODISS'
							Aadd( aItem[nItemSD2], RetFldProd(SB1->B1_COD,"B1_CODISS") )	    // Codigo de imposto sobre servicos (ISS)

						Case ALLTRIM(aStruSD2[j][1]) == 'D2_CCUSTO'
							Aadd( aItem[nItemSD2], 	cCCusto 		)		// Centro de Custo

						Case ALLTRIM(aStruSD2[j][1]) == 'D2_CLVL'
							Aadd( aItem[nItemSD2], cCValor 			)		// Classe de Valor

						Case ALLTRIM(aStruSD2[j][1]) == 'D2_ITEMCC'
							Aadd( aItem[nItemSD2], cItemC 			)		// Item Contabil

						Otherwise
							Aadd( aItem[nItemSD2], CriaVar(aStruSD2[j][1]) ) // demais campo da estrutura da tabela SD2 necessarios na criacao da nota fiscal sem pedido de vendas*/
					EndCase
				Next j

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Proximo Item³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nX++
				nInd++

				//Agrupa Cliente
				If cAgrupa == "2"//2- Sim
					If nX <= Len(aGerNF)
						If (cCliente + cLoja) <> (aGerNF[nX][2] + aGerNF[nX][9])
							Exit
						EndIf
					EndIf
				Else
					Exit			
				EndIf
			Else
				nX++
				nInd++
			EndIF	

		EndDo

		//Monta o cabecalho da NF
		For j := 1 to len(aStruSF2)
			Do Case
				Case ALLTRIM(aStruSF2[j][1]) == 'F2_FILIAL'
					Aadd( aCabec, xFilial("SF2") )			// Filial

				Case ALLTRIM(aStruSF2[j][1]) == 'F2_CLIENTE'
					Aadd( aCabec, SA1->A1_COD    )			// Cliente

				Case ALLTRIM(aStruSF2[j][1]) == 'F2_LOJA'
					Aadd( aCabec, SA1->A1_LOJA   )			// Loja

				Case ALLTRIM(aStruSF2[j][1]) == 'F2_CLIENT'
					Aadd( aCabec, SA1->A1_COD    )			// Cliente

				Case ALLTRIM(aStruSF2[j][1]) == 'F2_LOJENT'
					Aadd( aCabec, SA1->A1_LOJA   )			// Loja

				Case ALLTRIM(aStruSF2[j][1]) == 'F2_TIPO'
					Aadd( aCabec,     "N"        )		    // Tipo (Normal)

				Case ALLTRIM(aStruSF2[j][1]) == 'F2_TIPOCLI'
					Aadd( aCabec, SA1->A1_PESSOA )		    // Tipo de cliente (F=Pessoa Fisica; J=Pessoa Juridica)

				Case ALLTRIM(aStruSF2[j][1]) == 'F2_EMISSAO'
					Aadd( aCabec,  dDataBase     )		    // Data de emissao

				Case ALLTRIM(aStruSF2[j][1]) == 'F2_COND'
					Aadd( aCabec,    cCond	     )	     	// Condicao de pagamento

				Case ALLTRIM(aStruSF2[j][1]) == 'F2_HORA'
					Aadd( aCabec, SubStr(Time(),1,5) )		// Hora do processamento

				Case ALLTRIM(aStruSF2[j][1]) == 'F2_EST'
					Aadd( aCabec, SA1->A1_EST    ) 	        // Estado

				Case ALLTRIM(aStruSF2[j][1]) == 'F2_NEXTDOC'
					Aadd( aCabec, "      "       )		    // Proximo docto

				Case ALLTRIM(aStruSF2[j][1]) == 'F2_TPNFEXP'
					Aadd( aCabec, " "       )		    	// TEMPORARIO - REMOVER FUTURAMENTE

				Otherwise
					Aadd( aCabec, CriaVar(aStruSF2[j][1]) ) 
					// Campos excedentes do cabecalho da nota fiscal, necessarios na rotina mata461 
					// para geracao de nota sem pedido de venda.
			EndCase
		Next j

		//Pontos de Entrada para cliente alterar informacoes antes do ExecAuto
		//Ou Adicionar campos de usuario.									   
		If ExistBlock("Fi020Cabec")
			aCabec := ExecBlock("Fi020Cabec", .F., .F., {aCabec})
		Endif

		If ExistBlock("Fi020Itens")
			aItem := ExecBlock("Fi020Itens", .F., .F., {aItem})
		Endif

		//Gera a NF   

		dbSelectArea("SF2")

		cNota := MaNfs2Nfs(,,SA1->A1_COD,SA1->A1_LOJA,cSerie,,,,,,,,,,,,,{|| .T.},aSF2RecNo,aItem,aCabec,.F.,{|| .T.},,{|| .T.})		
		cNota := PadR(cNota,TamSX3('F2_DOC')[1])

		Begin Transaction
		//Se nota foi gerada com exito, entao atualiza variaveis
		if !empty(cNota)
			aTitulos := {}
			for i:=1 to len(aInRecSE1)				

				// Atualiza a SE1 com o numero da NF gerada
				SE1->( dbGoTo(aInRecSE1[i]) )
				RecLock("SE1",.F.)
				SE1->E1_CHAVENF := cNota+cSerie
				SE1->E1_NUMNOTA := cNota
				SE1->( msUnlock() )

				//Armazena o numero do Titulo
				aAdd(aTitulos,{SE1->E1_NUM,SE1->E1_PRODUTO,cCdCli,cSerie,cNota})

			next i
		else
				MsgAlert(STR0016)			
		Endif		    

		End Transaction

		//Ponto de entrada executado apos a geracao da NF
		If ExistBlock("Fi020PosNf")
			aAreaSA1 := SA1->(getArea())
			aAreaSB1 := SB1->(getArea())
			aArea	 := getArea()
			ExecBlock("Fi020PosNf", .F., .F., {aTitulos} )
			RestArea(aAreaSA1)
			RestArea(aAreaSB1)
			RestArea(aArea)
		Endif	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reinicializa variaveis e pula para proximo cliente marcado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aTitulos	:= {}
		aCabec		:= {}
		aItem		:= {}
		aSF2RecNo   := {}
		nItemSD2	:= 0
		aInRecSE1   := {}		
    Else
		nX++
		nInd++
	EndIf
EndDo

dDtEfet	:= dDataNf1
cHrEfet	:= Time()
cUsEfet	:= Subs( cUsuario, 7, TamSX3("FRJ_USGENF")[1] )

//Exibe mensagem de alerta ao usuario 
If !Empty(cNota)
	MsgInfo(STR0015) 	//"Gerado com Sucesso."
Else
	MsgAlert(STR0016) 	//'Ocorreram erros durante a geração das notas fiscais'
EndIF

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FI720ESTNF ºAutor  ³Microsiga           º Data ³  03/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Estorna NF								               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 													           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FI720ESTNF() As Logical

Local aRegSD2		As Array
Local aRegSE1		As Array
Local aRegSE2		As Array
Local aStruSF2		As Array
Local lMostraCtb	As Logical
Local lAglCtb		As Logical
Local lRet			As Logical
Local lIntACD		As Logical
Local lSF2520ET		As Logical
Local lSF2520E		As Logical
Local cChave		As Character
Local nTamDoc		As Numeric
Local nTamSerie		As Numeric

aRegSD2   := {}
aRegSE1   := {}
aRegSE2   := {}				
aStruSF2  := {}
lMostraCtb:= .F.
lAglCtb   := .F.
lRet      := .F.
lIntACD	:= SuperGetMV("MV_INTACD",.F.,"0") == "1"
lSF2520ET := ExistTemplate("SF2520E") 
lSF2520E  := Existblock("SF2520E")
cChave	:= ""
nTamDoc	:= TamSX3("F2_DOC")[1]
nTamSerie	:= TamSX3("F2_SERIE")[1]

If !Empty(SE1->E1_CHAVENF)

	cChave := SE1->E1_CHAVENF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o estorno do documento de saida pode ser feito     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRegSD2 := {}
	aRegSE1 := {}
	aRegSE2 := {}
	aStruSF2  := SF2->(dbStruct())
	cAliasSF2 := "QRYFINA720"

	SF2->(DbSelectArea("SF2"))
	SF2->(DbSetOrder(1))
	If SF2->(DbSeek(xFilial("SF2") + SubSTR(SE1->E1_CHAVENF, 1, nTamDoc + nTamSerie) + SE1->E1_CLIENTE + SE1->E1_LOJA))

		If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2) .AND. MA521VerSC6(SE1->E1_FILIAL,SubSTR(SE1->E1_CHAVENF,1,nTamDoc),SubSTR(SE1->E1_CHAVENF,nTamDoc+1,nTamSerie),SE1->E1_CLIENTE,SE1->E1_LOJA)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Integracao com o ACD - Acerto do CB0 na Exclusao da NF de devolucao via Protheus,			³
			//³ Somente se a etiqueta estiver com NF de Devolucao gravada 		  							³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIntACD .And. FindFunction("CBSF2520E")
				CBSF2520E()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pontos de Entrada 	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf lSF2520ET
				ExecTemplate("SF2520E",.F.,.F.)
			EndIf

			If lSF2520E
				ExecBlock("SF2520E",.F.,.F.)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Estorna o documento de saida                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
			SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,lMostraCtb,lAglCtb,.F.,.F.))

			Begin Transaction

				BeginSQL Alias "TMPSE1X"
					SELECT R_E_C_N_O_   
					FROM %Table:SE1% 
					WHERE  E1_CHAVENF = %Exp:cChave% AND
							E1_FILIAL  = %Exp:xFilial("SE1")% AND
							%NotDel% 	
				EndSQL

				While TMPSE1X->(!Eof())

					SE1->(dbGoTo(TMPSE1X->R_E_C_N_O_))

					SE1->(RecLock('SE1',.F.))
					SE1->E1_CHAVENF := ""
					SE1->E1_NUMNOTA := ""
					SE1->(msUnlock())	

					TMPSE1X->(DBSkip())
				Enddo

				TMPSE1X->(DbCloseArea())

				lRet := .T.
			End Transaction

		EndIf

		MsUnLockAll()

		If lRet 
			MsgInfo(STR0024)	//"Estornado com Sucesso."
		EndIf
	
	Else
		Help( ,,"F720NOCAN",,STR0041, 1, 0 )	//"Não foi possível localizar uma NF (SF2) com a chave desse título.
	EndIf
ElseiF Empty(SE1->E1_PRODUTO)
	MSGINFO(STR0039) //"Título não Possui Produto Vinculado."
Else
	Help(" ",1,"FINA720EXCL")//Não existe NF para este titulo!
EndIf

Return .T.
