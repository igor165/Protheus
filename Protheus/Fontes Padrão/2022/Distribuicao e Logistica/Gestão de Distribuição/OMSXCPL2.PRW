#INCLUDE "PROTHEUS.CH"	
#INCLUDE "FWMVCDEF.CH"	
#INCLUDE "OMSXCPL2.CH"

#DEFINE CRMARCA  1 
#DEFINE CRCORBRW 2
#DEFINE CRALIAS  3
#DEFINE CRNOME   4
#DEFINE CRROTINA 5
#DEFINE CRMODEL  6
#DEFINE CRFILTRO 7
#DEFINE CRFILORG 8
#DEFINE CRMSG    9  
/*/{Protheus.doc} OMSXCPL2
	Programa responsável por dar carga inicial e acesso a informações de falha de transmissão.
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function OMSXCPL2()
Local aSize     := {}
Local aObjects  := {}

Local aInfo     := {}
Local aPosObj   := {}
Local oBranco   := LoadBitmap(GetResources(),'BR_BRANCO')
Local oOk       := LoadBitMap(GetResources(),"LBOK")
Local oNo       := LoadBitMap(GetResources(),"LBNO")
Local oBtn01
Local oBtn02
Local nPosi := 20
Local cFiltroSA1 := If(SuperGetMv("MV_CPLEX",.F.,"2") == "1","","((A1_PAIS = '   '{´OR´}A1_PAIS = '105'){´AND´}A1_EST != 'EX')")
Local cFiltroDUE := If(SuperGetMv("MV_CPLEX",.F.,"2") == "1","","(DUE_EST $ '" + OMSXCPLGUf("C") + "')")// A definição de exterior se dá pela UF
Local cFiltroDUL := If(SuperGetMv("MV_CPLEX",.F.,"2") == "1","","(DUL_EST $ '" + OMSXCPLGUf("C") + "')")// A definição de exterior se dá pela UF 
Local cMsgObsSM0 := If(SuperGetMv("MV_CPLEX",.F.,"2") == "1","",STR0029) // "Filiais consideradas estrangeiras não serão enviadas."
Local cMsgObsSA1 := If(SuperGetMv("MV_CPLEX",.F.,"2") == "1","",STR0030) // "Clientes considerados estrangeiros não serão enviados."
Local cMsgObsDUE := If(SuperGetMv("MV_CPLEX",.F.,"2") == "1","",STR0031) // "Solicitantes considerados estrangeiros não serão enviados."
Local cMsgObsDUL := If(SuperGetMv("MV_CPLEX",.F.,"2") == "1","",STR0032) // "Endereços de solicitantes considerados estrangeiros não serão enviados."
Local cMsgObsSA2 := STR0036 //Fornecedores com os campos A2_TRANSP preenchido ou A2_RNTRC preenchido ou A2_PAGGFE igual a '1-sim' serão enviados como transportadores. 

Private oVerde      := LoadBitmap(GetResources(),'BR_VERDE')
Private oAmarelo	:= LoadBitmap(GetResources(),'BR_AMARELO')
Private oListBox	:= Nil
Private oDlg		:= Nil
Private oQtdDoc	    := Nil
Private oQtdMrk	    := Nil
Private nQtdDoc	    := 0
Private nQtdMrk	    := 0
Private lExecAuto	:= .F.
Private aListBox    := {}
Private oBtn03
Private lCplEx      := SuperGetMv("MV_CPLEX",.F.,"2") == "2" 
//-- Checkbox
Private lAllMark:= .F.   // Usado para o controle da marca de todos os documentos
//-- Rotinas Marcadas
Private aRotMark:= {}

	If !OMSXCPL1AT()
		Return
	EndIf

	CursorWait()
	 
	Aadd(aListBox,{'2',oBranco ,'SM0',STR0001,''       ,'',''        ,''        ,cMsgObsSM0}) // Cadastro de Filiais
	Aadd(aListBox,{'2',oAmarelo,'SB1',STR0002,'MATA010','',''        ,''        ,''        }) // Cadastro de Produtos
	Aadd(aListBox,{'2',oAmarelo,'SA1',STR0003,'MATA030','',cFiltroSA1,cFiltroSA1,cMsgObsSA1}) // Cadastro de Clientes
	Aadd(aListBox,{'2',oAmarelo,'DUE',STR0004,'TMSA440','',cFiltroDUE,cFiltroDUE,cMsgObsDUE}) // Cadastro de Solicitantes
	Aadd(aListBox,{'2',oAmarelo,'DUL',STR0005,'TMSA450','',cFiltroDUL,cFiltroDUL,cMsgObsDUL}) // Cadastro de Endereço de Solicitantes
	Aadd(aListBox,{'2',oAmarelo,'SA2',STR0006,'MATA020','',''        ,''        ,cMsgObsSA2}) // Cadastro de Fornecedores
	Aadd(aListBox,{'2',oAmarelo,'SA4',STR0007,'MATA050','',''        ,''        ,''        }) // Cadastro de Transportadora
	Aadd(aListBox,{'2',oAmarelo,'DUT',STR0008,'TMSA530','',''        ,''        ,''        }) // Tipos de Veículo

	CursorArrow()
	
	aSize    := MsAdvSize(.F. )
	aObjects := {}
	
	AAdd( aObjects, { 100, 020, .T., .F., .T.  } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 020, .F., .F. } )

	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3, .T.  }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE MSDIALOG oDlg TITLE STR0009 From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL // "Carga de dados Cockpit"
	
		oPanel := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oDlg,,,,,CLR_WHITE,(aPosObj[1,3]), (aPosObj[1,4]), .T.,.T.)
		
		@ 005,005 CHECKBOX oAllMark VAR lAllMark PROMPT STR0010 SIZE 168, 08; // "Marca/Desmarca Todos"
		ON CLICK(OMSXCPLAll(aListBox)) OF oPanel PIXEL              
		
		//-- Cabecalho dos campos do Monitor.                                                        
		@ aPosObj[2,1],aPosObj[2,2] LISTBOX oListBox Fields HEADER;
		  "","","Alias", STR0011, STR0012, STR0013 SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL // "Rotina" ## "Nome" ## "Observação" 
		   
		oListBox:SetArray( aListBox )
		oListBox:bLDblClick := { || OMSXCPLMrk(aListBox) }                              
		oListBox:bLine      := { || {	Iif(aListBox[ oListBox:nAT,CRMARCA ] == '1',oOk,oNo),;	
												aListBox[ oListBox:nAT,CRCORBRW],;				
												aListBox[ oListBox:nAT,CRALIAS ],;
												aListBox[ oListBox:nAT,CRROTINA],;
												aListBox[ oListBox:nAT,CRNOME  ],;
												aListBox[ oListBox:nAT,CRMSG  ]}}
		oListBox:bChange := {|| HabilitaFiltro()}                                                   
		//-- Botoes da tela do monitor.
		@ aPosObj[3,1],aPosObj[3,4] - 100 BUTTON oBtn01 PROMPT STR0014 ACTION OMSXCPLLeg() OF oDlg PIXEL SIZE 035,011 // "Legenda"
		@ aPosObj[3,1],aPosObj[3,4] - 060 BUTTON oBtn02 PROMPT STR0015 ACTION Iif(MsgYesNo(STR0016,STR0017),; // "Processar" ## "Confirma o Processamento" ## "Carga Inicial" 
			Processa( { || OMSXCPLProc(aListBox) }, , STR0018, .T. ),'') OF oDlg PIXEL SIZE 035,011 // "Transmitindo"
//		@ aPosObj[3,1], 300 BUTTON oBtnx PROMPT "Deletar" ACTION Iif(MsgYesNo("Confirma o Processamento","Carga Inicial"),;        //--"Confirma o Processamento",Carga Inicial
//			Processa( { || OMSXCPLProc(aListBox,.T.) }, , "Transmitindo", .T. ),'') OF oDlg PIXEL SIZE 035,011
		@ aPosObj[3,1],aPosObj[3,4] - 020 BUTTON oBtn03 PROMPT STR0019 ACTION OMSXCPLFil(@aListBox) OF oDlg PIXEL SIZE 035,011 // "Filtro"
		@ aPosObj[3,1],aPosObj[3,4] + nPosi BUTTON oBtn0x PROMPT STR0020 ACTION OMSXCPL4() OF oDlg PIXEL SIZE 035,011 // "Falhas"
		
		@ aPosObj[3,1],aPosObj[3,4] + nPosi*3 BUTTON oBtn05 PROMPT STR0021 ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 // "Sair" 
		
	ACTIVATE MSDIALOG oDlg CENTERED
	
	OMSXCLRCH()
Return ( Nil )
/*/{Protheus.doc} OMSXCPLPROC
	Realiza o processamento e o envio dos dados
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param aListBox, array, 
@param lDelete, logical,
@example
(examples)
@see (links_or_references)
/*/
Function OMSXCPLPROC(aListBox,lDelete)
	Local nX 
	Local aListProc := OMSXCPLRot(aListBox)
	Local aArea
	Local cFilialTab
	Local nOperacao := MODEL_OPERATION_UPDATE
	Local cFilBkp
	Default lDelete := .F.
	
	If lDelete
		nOperacao := MODEL_OPERATION_DELETE
	EndIf
	
	If OsIsCplDbg() .And. !MsgYesNo(STR0022 + CRLF + STR0023 + OsCplDbgDir() + CRLF + STR0024) // "Quando o modo debug está habilitado todas as mensagens" ## "enviadas serão gravados na pasta " ## "Deseja continuar?"
		Return
	EndIf
	
	For nX := 1 To Len(aListProc)
		cFilTro := StrTran(StrTran(aListProc[nX,CRFILTRO],"{´"," ."),"´}",". ")
		aArea := (aListProc[nX,3])->(GetArea())
		
		dbSelectArea(aListProc[nX,CRALIAS])
		If aListProc[nX,CRALIAS] != "SM0"
			If !Empty(cFilTro)
				SET FILTER TO &(cFilTro)
			Else
				SET FILTER TO
			EndIf
			dbGoTop()
			dbseek(xFilial(aListProc[nX,CRALIAS]))
			cFilialTab := (aListProc[nX,CRALIAS])+"->"+IIF(SubStr((aListProc[nX,CRALIAS]),1,1) == 'S',SubStr((aListProc[nX,CRALIAS]),2,3),(aListProc[nX,CRALIAS]))+"_FILIAL"
		Else
			dbGoTop()
		EndIf
		
		While !Eof() .And. ( ( aListProc[nX,CRALIAS] == "SM0" ) ;
					.Or. (!Empty(cFilialTab) .And.  &cFilialTab == xFilial(aListProc[nX,CRALIAS])))
			If aListProc[nX,CRALIAS] != "SM0" .Or. (( aListProc[nX,CRALIAS] == "SM0" ) .And. (!lCplEx .Or. OMSXCPLEST(SM0->M0_ESTENT) != "EX" ))
				OMSXCPLENVIA(aListProc[nX,CRALIAS],nOperacao)
			EndIf
			dbSelectArea(aListProc[nX,CRALIAS])
			dbSkip()
			
		EndDo
		
		RestArea(aArea)
		dbSelectArea(aListProc[nX,CRALIAS])
		SET FILTER TO
	Next nX
	
Return

Static Function OMSXCPLLeg()

BrwLegenda( STR0025		, STR0025,; // "Filtro" 			
			{{'BR_BRANCO' , STR0026 },; // "Não se aplica"  		
			{'BR_AMARELO' , STR0027 },; // "Não Informado"  	
			{'BR_VERDE'   , STR0028}}) // "Informado"  		

Return Nil
/*/{Protheus.doc} OMSXCPLMrk
	Realiza a marcação
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param aListBox, array, descricao
@param nItem, numeric, Item da lista
@param lRefresh, logical, Se efetua refresh da tela
@param lUmItem, logical, se está sendo marcado somente um item
@param lRetMark, logical, se é uma marcação ou desmarcação em grupo
@example
(examples)
@see (links_or_references)
/*/
Static Function OMSXCPLMrk(aListBox,nItem,lRefresh,lUmItem,lRetMark)
Local   nPosMrk := 0
Local	  nDocMrk := 0
Local cIntTms := SuperGetMv("MV_INTTMS",.F.,.F.)		

Default nItem   := oListBox:nAt
Default lRefresh:= .T.
Default lUmItem := .T.
Default lRetMark:= .F.

If lUmItem
	aListBox[nItem,CRMARCA] := Iif(aListBox[nItem,CRMARCA] == '1','2','1')
	If(aListBox[nItem,CRMARCA]) == '1'
		nQtdMrk += 1 

	ElseIf(aListBox[nItem,CRMARCA]) == '2'		
		nQtdMrk -= 1
	EndIf	
Else
	If lAllMark
		aListBox[nItem,CRMARCA] := '1'
		nQtdMrk += 1
	Else
		aListBox[nItem,CRMARCA] := '2'
		nQtdMrk := 0
	EndIf                                                                      
EndIf
nPosMrk := Ascan(aRotMark,{ | e | e[1]+e[2] == aListBox[nItem,CRALIAS]+aListBox[nItem,CRROTINA] })
If nPosMrk == 0
	Aadd(aRotMark,{ aListBox[nItem,CRROTINA], aListBox[nItem,CRALIAS], '' })
	nPosMrk := Len(aRotMark)
EndIf
aRotMark[nPosMrk,3] := aListBox[nItem,CRMARCA]
If lRefresh
	oListBox:Refresh()
EndIf
If cIntTms
	If aListBox[nItem,CRALIAS] == 'SA1'
		nPos := aScan(aListBox,{|x|x[CRALIAS] == 'DUL'})
		If aListBox[nPos,CRMARCA] != aListBox[nItem,CRMARCA]
			OMSXCPLMrk(aListBox,nPos,lRefresh,lUmItem,lRetMark)
		EndIf
	EndIf
EndIf
	 
Return Nil
/*/{Protheus.doc} OMSXCPLAll
	Marca todos os registros
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param aListBox, array
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function OMSXCPLAll(aListBox)
Local nI      := 0
Local lRefresh:= .T.
Local lUmItem := .F.

CursorWait()
nQtdMrk := 0

For nI := 1 To Len(aListBox)
	OMSXCPLMrk(aListBox,nI,lRefresh,lUmItem)
Next nI	

CursorArrow()

oListBox:Refresh()

Return Nil
/*/{Protheus.doc} OMSXCPLRot
	Retorna as rotinas a serem processadas.
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param aListBox, array, 
@example
(examples)
@see (links_or_references)
/*/
Static Function OMSXCPLRot(aListBox)
Local   nI         := 0
Local   aRotProc 	 := {}

For nI := 1 To Len(aListBox)
	If aListBox[nI,CRMARCA] == '1'
		Aadd(aRotProc, {aListBox[nI,CRMARCA],aListBox[nI,CRCORBRW],aListBox[nI][CRALIAS],aListBox[nI][CRNOME], aListBox[nI][CRROTINA], aListBox[nI][CRMODEL], aListBox[nI][CRFILTRO]} )
	EndIf	
Next nI

Return ( aRotProc )
/*/{Protheus.doc} OMSXCPLFil
	Permite que o usuário crie um filtro e salve junto com o filtro padrão para aplicação no alias
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param aListBox, array
@example
(examples)
@see (links_or_references)
/*/
Static Function OMSXCPLFil(aListBox)                                              
Local cExpr := ""
Default aListBox := {}

If !Empty(aListBox[oListBox:nAT,CRFILORG])
	aListBox[oListBox:nAT,CRFILTRO] := SubStr(aListBox[oListBox:nAT,CRFILTRO],Len(aListBox[oListBox:nAT,CRFILORG])+1)
EndIf

cExpr := BuildExpr( aListBox[ oListBox:nAT,CRALIAS ], ,aListBox[oListBox:nAT,CRFILTRO])

If Empty(cExpr)
	cExpr := aListBox[oListBox:nAT,CRFILORG]
	If At(".And.",cExpr) >0
		cExpr := SubStr(cExpr,1,at(".And.",cExpr)-1)
	EndIf
Else
	If At(".And.",aListBox[oListBox:nAT,CRFILORG]) == 0 .And. !Empty(aListBox[oListBox:nAT,CRFILORG])
		aListBox[oListBox:nAT,CRFILORG] := aListBox[oListBox:nAT,CRFILORG] + " .And. "
	EndIf
	cExpr := aListBox[oListBox:nAT,CRFILORG] + cExpr
EndIf

aListBox[oListBox:nAT,CRFILTRO] := cExpr

If !Empty(SubStr(aListBox[oListBox:nAT,CRFILTRO],Len(aListBox[oListBox:nAT,CRFILORG])+1) )
	aListBox[ oListBox:nAT,CRCORBRW] := oVerde
	oListBox:Refresh()
Else	                                                                               
	aListBox[ oListBox:nAT,CRCORBRW] := oAmarelo
	oListBox:Refresh()
EndIf                                                                                     

Return ( Nil )
/*/{Protheus.doc} HabilitaFiltro
	Habilita/Desabilita o botão de filtro da tela
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function HabilitaFiltro()
	Local lDesabilita
	Static cUltimo := ""
	Static aAliasDesab := {"SM0"}
	If cUltimo != aListBox[ oListBox:nAT,CRALIAS ]
		cUltimo := aListBox[ oListBox:nAT,CRALIAS ]
		lDesabilita := aScan(aAliasDesab,{|x| x == ALLTRIM(UPPER(aListBox[ oListBox:nAT,CRALIAS ]))}) != 0
		oBtn03:SetDisable(lDesabilita)
	EndIf
Return 