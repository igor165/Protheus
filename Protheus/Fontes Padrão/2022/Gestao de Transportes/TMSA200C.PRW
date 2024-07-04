#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TOPCONN.ch' 
#INCLUDE "TMSA200C.ch"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM200EXMOT()
Tela para cadastrar o motivo da exclusão de documentos.
@type 		: Function
@autor		: Marlon Augusto Heiber
@since		: 28/08/2019
@version 	: 12.1.28
@param 		: aDocExc - Array com todos os documentos ta tela de estorno.
@param 		: aDocExcMot - Array que retorna pra função anterior com todos os documentos que receberam o motivo.
@param 		: cTipDocMot - Lista com tipos de documentos que precisam ter o motivo de estorno conforme parametro MV_DMOTEST.
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA200C(aDocExc,aDocExcMot,cTipDocMot)
Local aBotoes     := {} //Botoes da tela
Local aStructBrw  := {} //Estrutura da tela
Local aColsBrw    := {} //Colunas que compoem a tela
Local aAreaDT6	:= DT6->( GetArea() )
Local cTabelaDOC  := "" //Nome da tabela temporária no banco
Local cAliTemp	  := ""
Local cMotivo 	  := Space(3)
Local cDescMotEx  := Space(254)
Local lRet 		  := .F.
Local nX          := 1
Local oBrwCol	  := Nil
Local oModal	  := Nil
Local oContainer  := Nil
Local oEditor 	  := Nil
Local oTempTable  := Nil
Local oPnlModal   := Nil
Local oPanelUp    := Nil
Local oPanelDown  := Nil
Local oMotivo     := Nil
Local oMarkBrw    := Nil

	aadd(aStructBrw, {"MARK",       "C",    1, 0})
	aadd(aStructBrw, {"INFORMADO",  "C",    1, 0})
	aadd(aStructBrw, {"DOC_FILDOC",	"C",  TAMSX3("DT6_FILDOC")[1], 0})
	aadd(aStructBrw, {"DOC_DOC", 	"C",  TAMSX3("DT6_DOC")[1]   , 0})
	aadd(aStructBrw, {"DOC_SERIE",  "C",  TAMSX3("DT6_SERIE")[1] , 0})
	aadd(aStructBrw, {"DOC_CODMOT",	"C",    5, 0})
	aadd(aStructBrw, {"DOC_OBSMOT",	"C",  254, 0})
	
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| DOC_FILDOC }"))
	oBrwCol:SetTitle(STR0001) //"Filial Doc." 
	oBrwCol:SetSize(TAMSX3("DT6_FILDOC")[1])
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("")
	oBrwCol:SetReadVar("DOC_FILDOC")
	AAdd(aColsBrw, oBrwCol)
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| DOC_DOC }"))
	oBrwCol:SetTitle(STR0002) //"Documento"  
	oBrwCol:SetSize(TAMSX3("DT6_DOC")[1])
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("")
	oBrwCol:SetReadVar("DOC_DOC")	
	AAdd(aColsBrw, oBrwCol)
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| DOC_SERIE }"))
	oBrwCol:SetTitle(STR0003) //"Serie"  
	oBrwCol:SetSize(TAMSX3("DT6_SERIE")[1])
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("")
	oBrwCol:SetReadVar("DOC_SERIE")	
	AAdd(aColsBrw, oBrwCol)
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| DOC_CODMOT }"))
	oBrwCol:SetTitle(STR0004) //"Cod. Mot." 
	oBrwCol:SetSize(5)
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("")
	oBrwCol:SetReadVar("DOC_CODMOT")	
	AAdd(aColsBrw, oBrwCol)
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| DOC_OBSMOT }"))
	oBrwCol:SetTitle(STR0005) // "Observ. Mot." 
	oBrwCol:SetSize(254)
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("")
	oBrwCol:SetReadVar("DOC_OBSMOT")	
	oBrwCol:SetAlign( 1 )
	AAdd(aColsBrw, oBrwCol)
	
	If Len(GetSrcArray("FWTEMPORARYTABLE.PRW")) > 0 .And. !(InTransaction())
		cAliTemp := GetNextAlias()
		oTempTable := FWTemporaryTable():New("DOC")
		oTempTable:SetFields(aStructBrw)
		oTempTable:AddIndex("1",{"DOC_FILDOC","DOC_DOC","DOC_SERIE"})
		oTempTable:AddIndex("2",{"MARK"})
		oTempTable:Create()
		cAliTemp  := oTempTable:GetAlias()
		cTabelaDOC:= oTempTable:GetRealName()
	EndIf
	
	DT6->(DbSetOrder(1))
	DbSelectArea("DOC")
	
	For nX := 1 To Len(aDocExc)
		If aDocExc[nx][1] = .T.
			If DT6->(DBSeek(xFilial('DT6')+aDocExc[nX][4]+aDocExc[nX][5]+aDocExc[nX][6])) .AND. UPPER(DT6->DT6_DOCTMS) $ UPPER(cTipDocMot)
				("DOC")->(RecLock(("DOC"), .T.))
				("DOC")->DOC_FILDOC := aDocExc[nX][4]
				("DOC")->DOC_DOC 	:= aDocExc[nX][5]
				("DOC")->DOC_SERIE 	:= aDocExc[nX][6]
				("DOC")->(MsUnlock())
			Endif
		EndIf	
	Next

	oModal := FWDialogModal():New()
	oModal:SetBackground(.F.)      
	oModal:SetTitle(STR0006) //"Motivo de Estorno"
    oModal:SetEscClose(.F.)
    oModal:SetSize(300,300)
    oModal:CreateDialog()
    
    oPnlModal := oModal:GetPanelMain()
    
    oFWLayer := FWLayer():New()                 //-- Container
	oFWLayer:Init(oPnlModal, .F., .F.)          //-- Inicializa container
    
    // Painel Superior  
	oFWLayer:AddLine('UP', 30, .F.)           //-- Superior
	oFWLayer:AddCollumn('COL', 100, .F., 'UP') //-- Coluna
	oPanelUp := oFWLayer:GetColPanel('COL', 'UP')

	// Painel Inferior 
	oFWLayer:AddLine('DOWN', 70, .F.)          //-- Inferior
	oFWLayer:AddCollumn('COL', 100, .F., 'DOWN') //-- Coluna
	oPanelDown := oFWLayer:GetColPanel( 'COL' , 'DOWN' ) 
	
	oContainer := TPanel():New( ,,,oPanelUp )
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT
     
    TSay():New(5,10,{|| STR0007 },oContainer,,,,,,.T.,,,90,20,,,,,,.T.) // "Código Motivo Estorno"
    @ 015,010 MSGET oMotivo VAR cMotivo F3 "O5" Size 30,10 OF oContainer VALID Empty(cMotivo) .OR. ExistCpo("SX5","O5"+cMotivo) PIXEL
  
    TSay():New(5,110,{|| STR0008 },oContainer,,,,,,.T.,,,90,20,,,,,,.T.) // "Descrição Motivo Estorno"
    @ 015,110 MSGET Iif(Empty(cMotivo) .OR. Empty(FwGetSX5("O5",Alltrim(cMotivo)))," ",FwGetSX5("O5",Alltrim(cMotivo))[1][4]) Size 180,10 OF oContainer WHEN .F. PIXEL

    TSay():New(35,10,{|| STR0009 },oContainer,,,,,,.T.,,,90,20,,,,,,.T.) //"Observação Referente Estorno"
    oEditor := tMultiget():New(045,010,{|x| Alltrim(If( pCount() > 0,cDescMotEx := x, cDescMotEx))},oContainer,280,30,,,,,,.T.,,,,,,,{||ValTxtDesc(cDescMotEx)},,,,,,1,,)    

	oMarkBrw := FWMarkBrowse():New()
	oMarkBrw:SetMenuDef("TMSA200C")
	oMarkBrw:SetTemporary(.T.)
	oMarkBrw:AddLegend('Empty(DOC_CODMOT)' ,"BR_AZUL_CLARO"	,STR0010) //"Motivo Não Informado"	
	oMarkBrw:AddLegend('!Empty(DOC_CODMOT)',"BR_AZUL"		,STR0011) //"Motivo Informado"
	oMarkBrw:SetColumns(aColsBrw)
	oMarkBrw:SetAlias("DOC")
	oMarkBrw:SetFieldMark("MARK")
	oMarkBrw:DisableConfig()
	oMarkBrw:DisableReport()
	oMarkBrw:DisableFilter()
	oMarkBrw:SetIgnoreARotina(.T.)
	oMarkBrw:SetOwner(oPanelDown)

	oMarkBrw:SetAllMark({||TM200Mark(cTabelaDOC,oMarkBrw,)})
	oMarkBrw:AddButton(STR0012,{||TM200Mark(cTabelaDOC,oMarkBrw,)},, 4,7) //"Marcar/Desmarcar Todos"
	oMarkBrw:AddButton(STR0013,{||TM200Grav(cMotivo,AllTrim(cDescMotEx),cTabelaDOC,oMarkBrw)},, 4,7) //"Gravar Motivo"
	
	bConfir := {|| lRet := TM200OK(cTabelaDOC,@aDocExcMot,oModal)}
	bCancel := {|| lRet := TM200Canc(cTabelaDOC,oModal)}
	
	Aadd(aBotoes, {"", STR0014, bConfir, , , .T., .F.}) // 'Confirmar'
	Aadd(aBotoes, {"", STR0015, bCancel, , , .T., .F.}) // 'Cancelar'

	oModal:AddButtons(aBotoes)
	
    oMarkBrw:Activate()
	
    oModal:Activate()
    
	DbSelectArea('DOC')
	DbCloseArea()
	RestArea( aAreaDT6 )
	
	If File(cAliTemp+GetDBExtension())
		FErase(cAliTemp+GetDBExtension())
	EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef()
Menudef
@type 		: Static Function
@autor		: Marlon Augusto Heiber
@since		: 28/08/2019
@version 	: 12.1.28
/*/
//-------------------------------------------------------------------------------------------------
Static Function Menudef()
Local aRotina := {}
	
Return aRotina

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM200Mark()
Função para marcar/desmarcar todos os registros do grid
@type 		: Static Function
@autor		: Marlon Augusto Heiber
@since		: 28/08/2019
@version 	: 12.1.28
/*/
//-------------------------------------------------------------------------------------------------
Static Function TM200Mark(cTabelaDOC,oMarkBrw)
	Local cQuery  := ""
	Local nStatus := 0
	
	DbSelectArea('DOC')
	DOC->(DBSetOrder(2))
								
    If DOC->( DbSeek(" "))	
    	cQuery := "UPDATE " + cTabelaDOC + " SET MARK = '" + oMarkBrw:Mark() + "'"
    Else
    	cQuery := "UPDATE " + cTabelaDOC + " SET MARK = ' ' "
    Endif
	nStatus := TcSqlExec(cQuery)
	
	If (nStatus < 0)
		TmsLogMsg("ERROR", "TCSQLError() : " + TCSQLError())
	EndIf
	
	DOC->(DBSetOrder(1))
	oMarkBrw:Refresh(.T.)
	
Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM200Grav()
Função para gravar o motivo na tabela temporária 
@type 		: Static Function
@autor		: Marlon Augusto Heiber
@since		: 28/08/2019
@version 	: 12.1.28
/*/
//-------------------------------------------------------------------------------------------------
Static Function TM200Grav(cMotivo,cDescMotEx,cTabelaDOC,oMarkBrw)
	Local cQuery  := ""
	Local nStatus := 0
	Local cMark	  := oMarkBrw:Mark()
	
	If !Empty(cMotivo)
	
		DbSelectArea('DOC')
		DOC->(DBSetOrder(2))						
	    If DOC->(DbSeek(cMark))	
	    	cQuery := "UPDATE " + cTabelaDOC 
	    	cQuery += " SET DOC_CODMOT = '" + cMotivo + "' , DOC_OBSMOT = '" + cDescMotEx + "' , MARK = ' '"   
	    	cQuery += " WHERE MARK =  '" + cMark + "'"  
	    Else
	    	Help(,,'Help',,STR0016,1,0,,,,,,{STR0017}) // "Nenhum documento selecionado." - "Selecione o documento para gravar o motivo."
	    Endif
		nStatus := TcSqlExec(cQuery)
		
		If (nStatus < 0)
			TmsLogMsg("ERROR", "TCSQLError() : " + TCSQLError())
		EndIf
		
		DOC->(DBSetOrder(1))
		oMarkBrw:Refresh(.T.)
		
	Else
		Help(,,'Help',,STR0018,1,0,,,,,,{STR0019}) //"Código do motivo não informado." - "Informe o código do motivo a ser gravado no documento."
	EndIf

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM200OK()
Função do botão confirmar, grava os motivos e observações de estorno da tabela temporária para o array
@type 		: Static Function
@autor		: Marlon Augusto Heiber
@since		: 28/08/2019
@version 	: 12.1.28
/*/
//-------------------------------------------------------------------------------------------------
Static Function TM200OK(cTabelaDOC,aDocExcMot,oModal)
	Local cQuery		:= ""
	Local cAliasDOC		:= GetNextAlias()
	Local lRet			:= .T.
	Default aDocExcMot	:= {}
	
	cQuery := " SELECT DOC_FILDOC, DOC_DOC, DOC_SERIE ,DOC_CODMOT, DOC_OBSMOT "
	cQuery += " FROM " + cTabelaDOC 
	cQuery += " WHERE DOC_CODMOT = ' ' "
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasDOC, .F., .T. )
	
	If !(cAliasDOC)->(Eof())
		Help(,,'Help',,STR0020,1,0,,,,,,{STR0021}) //"Encontrado documento sem motivo de estorno gravado." - "É necessário gravar o motivo de todos os documentos antes de confirmar."
		lRet := .F.
		(cAliasDOC)->(DbCloseArea())
	Else
		(cAliasDOC)->(DbCloseArea())
		cAliasDOC	:= GetNextAlias()
		cQuery := " SELECT DOC_FILDOC, DOC_DOC, DOC_SERIE ,DOC_CODMOT, DOC_OBSMOT "
		cQuery += " FROM " + cTabelaDOC 
		cQuery := ChangeQuery( cQuery )	
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasDOC, .F., .T. )
		
		While !(cAliasDOC)->(Eof())
		
            If Ascan( aDocExcMot, { |x|x[1]+x[2]+x[3] == (cAliasDOC)->DOC_FILDOC + (cAliasDOC)->DOC_DOC + (cAliasDOC)->DOC_SERIE } ) = 0
            	Aadd(aDocExcMot,{ (cAliasDOC)->DOC_FILDOC, (cAliasDOC)->DOC_DOC, (cAliasDOC)->DOC_SERIE,(cAliasDOC)->DOC_CODMOT,(cAliasDOC)->DOC_OBSMOT })
            EndIf
  
			(cAliasDOC)->(dbSkip())
		EndDo
		(cAliasDOC)->(DbCloseArea())
	EndIf
	
	If lRet
		oModal:DeActivate()
	EndIf
	
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM200Canc()
Função do botão cancelar 
@type 		: Static Function
@autor		: Marlon Augusto Heiber
@since		: 28/08/2019
@version 	: 12.1.28
/*/
//-------------------------------------------------------------------------------------------------
Static Function TM200Canc(cTabelaDOC,oModal)
Local cQuery		:= ""
	Local cAliasDOC		:= GetNextAlias()
	Local lRet			:= .T.
	
	cQuery := " SELECT DOC_FILDOC, DOC_DOC, DOC_SERIE ,DOC_CODMOT, DOC_OBSMOT "
	cQuery += " FROM " + cTabelaDOC 
	cQuery += " WHERE DOC_CODMOT <> ' ' "
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasDOC, .F., .T. )
	
	If !(cAliasDOC)->(Eof())
		lRet := MsgYesNo(STR0022) //"Ao cancelar, os motivos já informados serão perdidos. Deseja realmente cancelar a operação?"
	EndIf
	
	(cAliasDOC)->(DbCloseArea())
	
	If lRet
		oModal:DeActivate()
		lRet := .F.
	EndIf
	
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValTxtDesc()
Valid do campo de observação referente estorno. 
@type 		: Static Function
@autor		: Marlon Augusto Heiber
@since		: 29/08/2019
@version 	: 12.1.28
/*/
//-------------------------------------------------------------------------------------------------
Static Function ValTxtDesc(cDescMotEx)
Local lRet 	   := .T.
Local nTamanho := Len(cDescMotEx)

If !Empty(cDescMotEx)
	If nTamanho > 254
		MsgAlert(STR0023+CRLF+CRLF+STR0024+Alltrim(Str(nTamanho))+ STR0025) //"O tamanho máximo de caracteres para a descrição do motivo é de 254." - "- A descrição informada possui " - " caracteres."
		lRet := .F.
	EndIf
EndIf
Return lRet