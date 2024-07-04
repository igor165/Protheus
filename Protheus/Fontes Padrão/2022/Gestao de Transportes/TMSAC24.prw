#include 'TOTVS.ch'
#include 'TMSAC24.ch'

#define STR0001 "Trip"

// Alinhamento do método addInLayout
#define LAYOUT_ALIGN_LEFT     1
#define LAYOUT_ALIGN_RIGHT    2
#define LAYOUT_ALIGN_HCENTER  4
#define LAYOUT_ALIGN_TOP      32
#define LAYOUT_ALIGN_BOTTOM   64
#define LAYOUT_ALIGN_VCENTER  128

// Alinhamento para preenchimento dos componentes no TLinearLayout
#define LAYOUT_LINEAR_L2R 0 // LEFT TO RIGHT
#define LAYOUT_LINEAR_R2L 1 // RIGHT TO LEFT
#define LAYOUT_LINEAR_T2B 2 // TOP TO BOTTOM
#define LAYOUT_LINEAR_B2T 3 // BOTTOM TO TOP

#define DATA_STATUS   1
#define DATA_PEDIDO   3
#define DATA_CLIENTE  4
#define DATA_LOJACLI  5
#define DATA_NOMECLI  6
#define DATA_NOMEREDZ 7
#define DATA_ENDERECO 8
#define DATA_BAIRRO   9
#define DATA_CIDADE   10
#define DATA_ESTADO   11
#define DATA_CEP      12
#define DATA_DATACHEG 13
#define DATA_HORACHEG 14
#define DATA_TIMESERV 15
#define DATA_TIPODOC  16

#define DMS_PENDENTE 1
#define DMS_REJEIT 2
#define DMS_PROCESSA 3
#define DMS_FALHA 4

Static oDlg        	:= Nil
Static oBrowse     	:= Nil
Static oGroupInfo  	:= Nil
Static aPedidos    	:= {}
Static aDestinos   	:= {}
Static aFieldsDest 	:= {}
Static aFieldsPdg	:= {}
Static aOrigem     	:= {}
Static aFieldsOrig 	:= {}
Static aCalcTolls	:= {} 
Static oTripResult 	:= Nil
Static lAllSeqRot   := .F.   //Todas as sequencias de roteirização
Static nValPdg		:= 0 
Static aPdgTPR		:= {}
Static aRodTPR		:= {}	

/*/-----------------------------------------------------------
{Protheus.doc} TMSAC24()
Montagem e visualização do mapa com integração NEOLOG

Uso: TMSAC24

@sample
//ViewDef()

@author Caio Murakami   
@since 09/09/2021
@version 1.0
@type function
-----------------------------------------------------------/*/
Function TMSAC24( cFilRot, cIdRot, nSeqRot )
Local oSize
Local lRet          := .F.
Local cChvEnt		:= ""

Default cFilRot     := ""
Default cIdRot		:= ""
Default nSeqRot     := Nil

lAllSeqRot:= nSeqRot == Nil

nValPdg	:= 0
aPdgTPR := {}
aRodTPR	:= {}

lRet:= LoadPedidos( cFilRot, cIdRot, nSeqRot )

cChvEnt := cFilRot + cIdRot

cJson:= TMS21RetJs(cChvEnt)

If lRet
	//--Informações da Viagem TPR 
	InfTripTPR(cJson, nSeqRot)

	//-- Calcula as dimensoes dos objetos
	oSize := FwDefSize():New( .T. )  // Com enchoicebar
	//-- Cria Enchoice
	oSize:AddObject( "MASTER", 100, 100, .T., .T. ) // Adiciona enchoice

	//-- Dispara o calculo
	oSize:Process()

	//-- Desenha a dialog
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM ; //-- "Planejamento de Rotas"
	oSize:aWindSize[1],oSize:aWindSize[2] TO ;
	oSize:aWindSize[3],oSize:aWindSize[4] PIXEL STYLE NOr(WS_VISIBLE,WS_POPUP)
	LayLinear( cFilRot, cIdRot, nSeqRot )

	ACTIVATE MSDIALOG oDlg 
Else
	Help("",1,"TMSAC2401")  //-- Não foram localizados os dados dos documentos para Plotagem do Mapa.
EndIf

aPedidos  := {}
lAllSeqRot:= .F.
Return  lRet


/*/{Protheus.doc} LoadPedidos
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 21/09/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function LoadPedidos( cFilRot, cIdRot, nSeqRot)
Local lRet		:= .F. 
Local cQuery	:= "" 
Local cAliasQry	:= GetNextAlias() 
Local cAliasEnt	:= "" 
Local cIndEnt	:= "" 
Local cChvEnt	:= "" 
Local nCount	:= 0 
Local nStatus	:= 0 
Local aFilSM0   := {}

Default cFilRot := ""
Default cIdRot	:= "" 
Default nSeqRot := Nil

cQuery		:= " SELECT * "
cQuery		+= " FROM " + retSqlName("DMS") + " DMS "
cQuery		+= " WHERE DMS_FILIAL	= '" + xfilial("DMS") + "' "
cQuery		+= " AND DMS_FILROT		= '" + cFilRot + "' "
cQuery		+= " AND DMS_IDROT		= '" + cIdRot + "' "
If !lAllSeqRot
	cQuery		+= " AND DMS_SEQROT  	= " + cValToChar(nSeqRot) 
EndIf
cQuery		+= " AND DMS.D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

aPedidos	:= {} 
SA1->(DBSetOrder(1))
While (cAliasQry)->( !Eof() )
	cAliasEnt		:= (cAliasQry)->DMS_ENTIDA 
	cIndEnt			:= (cAliasQry)->DMS_INDENT
	cChvEnt			:= GetChvExt( (cAliasQry)->DMS_CHVENT )
	nStatus			:= Val( (cAliasQry)->DMS_STATUS )

	nCount++
	If cAliasEnt == "DTC"
		DTC->( dbSetOrder( Val(cIndEnt )))

		If DTC->( MsSeek( cChvEnt )) 
			If SA1->(MsSeek(xfilial("SA1") + DTC->DTC_CLIDES + DTC->DTC_LOJDES ))

				Aadd(aPedidos, { nStatus , cValToChar(nCount), RTrim(DTC->DTC_NUMNFC)+ "-" + DTC->DTC_SERNFC ,;
								DTC->DTC_CLIDES , DTC->DTC_LOJDES ,;
								SA1->A1_NOME,;
								SA1->A1_NREDUZ,;
								SA1->A1_END , SA1->A1_BAIRRO ,;
								SA1->A1_MUN , SA1->A1_EST , SA1->A1_CEP ,DDATABASE , Time() , "" , "NF" } )
			EndIf

		EndIf 

	ElseIf cAliasEnt == "DT6"
		DT6->( dbSetOrder( Val(cIndEnt )))

		If DT6->( MsSeek( cChvEnt ))
			If SA1->(MsSeek(xfilial("SA1") + DT6->DT6_CLIDES + DT6->DT6_LOJDES ))
			
				Aadd(aPedidos, { nStatus , cValToChar(nCount), rtRIM(DT6->DT6_DOC) + "-" + DT6->DT6_SERIE ,;
								DT6->DT6_CLIDES , DT6->DT6_LOJDES ,;
								SA1->A1_NOME,;
								SA1->A1_NREDUZ,;
								SA1->A1_END , SA1->A1_BAIRRO ,;
								SA1->A1_MUN , SA1->A1_EST , SA1->A1_CEP ,DDATABASE , Time() , "" , "CTE"} )
						
			EndIf
		EndIf 
	ElseIf cAliasEnt == "DT5"
		DT5->( dbSetOrder( Val(cIndEnt )))

		If DT5->( MsSeek( cChvEnt ))
			If !Empty(DT5->DT5_CLIDES)	
				If SA1->(MsSeek(xfilial("SA1") + DT5->DT5_CLIDES + DT5->DT5_LOJDES ))			
					If !Empty(DT5->DT5_SQEDES)
						DUL->(DbSetOrder(3))
						If DUL->(DbSeek(xFilial("DUL") + DT5->DT5_SQEDES)) 	
							If Empty(DUL->DUL_CODRED) .And. Empty(DUL->DUL_LOJRED)
								Aadd(aPedidos, { nStatus , cValToChar(nCount), rtRIM(DT5->DT5_DOC) + "-" + DT5->DT5_SERIE ,;
										DT5->DT5_CLIDES , DT5->DT5_LOJDES ,;
										SA1->A1_NOME,;
										SA1->A1_NREDUZ,;
										DUL->DUL_END  ,  DUL->DUL_BAIRRO ,;
										DUL->DUL_MUN , DUL->DUL_EST , DUL->DUL_CEP ,DDATABASE , Time() , "" , "COL"} )
							Else
								If SA1->(MsSeek(xfilial("SA1") + DUL->DUL_CODRED + DUL->DUL_LOJRED ))
									Aadd(aPedidos, { nStatus , cValToChar(nCount), rtRIM(DT5->DT5_DOC) + "-" + DT5->DT5_SERIE ,;
											DUL->DUL_CODRED , DUL->DUL_LOJRED ,;
											SA1->A1_NOME,;
											SA1->A1_NREDUZ,;
											SA1->A1_END , SA1->A1_BAIRRO ,;
											SA1->A1_MUN , SA1->A1_EST , SA1->A1_CEP ,DDATABASE , Time() , "" , "COL"} )
								EndIf
							EndIf
						EndIf
					Else
						Aadd(aPedidos, { nStatus , cValToChar(nCount), rtRIM(DT5->DT5_DOC) + "-" + DT5->DT5_SERIE ,;
										DT5->DT5_CLIDES , DT5->DT5_LOJDES ,;
										SA1->A1_NOME,;
										SA1->A1_NREDUZ,;
										SA1->A1_END , SA1->A1_BAIRRO ,;
										SA1->A1_MUN , SA1->A1_EST , SA1->A1_CEP ,DDATABASE , Time() , "" , "COL"} )
				
					EndIf
				EndIf
			Else

				aFilSM0 := FWSM0Util():GetSM0Data( cEmpAnt , DT5->DT5_FILORI, {"M0_CODFIL","M0_NOME","M0_NOMECOM", "M0_ENDENT",;
				                                  "M0_BAIRENT","M0_CIDENT", "M0_ESTENT", "M0_CEPENT"} ) 
				
				Aadd(aPedidos, { nStatus , cValToChar(nCount), rtRIM(DT5->DT5_DOC) + "-" + DT5->DT5_SERIE ,;
								aFilSM0[1][2],; //M0_CODFIL
								' ',;  
								aFilSM0[2][2],;  //M0_NOMECOM
								aFilSM0[3][2],;  //M0_NOME
								aFilSM0[4][2],;  //M0_ENDENT 
								aFilSM0[5][2],;  //M0_BAIRENT
								aFilSM0[6][2],;  //M0_CIDENT  
								aFilSM0[7][2],;  //M0_ESTENT 
								aFilSM0[8][2],;  //M0_CEPENT ,
								dDataBase, Time(), "", "COL"} )              
				
            EndIf		
		EndIf 
	EndIf 

	(cAliasQry)->( dbSkip() )
EndDo 

(cAliasQry)->(dbCloseArea())

If Len(aPedidos) > 0
	lRet:= .T.
EndIf

FwFreeArray(aFilSM0)
Return lRet 


/*/{Protheus.doc} GetChvExt( cChaveExt )
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 21/09/21
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function GetChvExt( cChaveExt )
Local cRet 	:= ""
Local aRet	:= {} 

Default cChaveExt		:= "" 

aRet	:= StrTokArr( cChaveExt, "|" )

cRet	:= aRet[Len(aRet)]
Return cRet 

/*/-------------------------------------------------------
{Protheus.doc} LayLinear()

Uso: TMSAC24

@sample
//ViewDef()

@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function LayLinear( cFilRot, cIdRot, nSeqRot )
Local   aCoors      := FWGetDialogSize( oMainWnd )

Default cFilRot     := ""
Default cIdRot		:= "" 
Default nSeqRot     := Nil

oPanelMain := TPanel():New(0,0,Nil,oDlg,,.F.,,,CLR_WHITE,200,20)
oPanelMain:Align := CONTROL_ALIGN_ALLCLIENT
oPanelMain:SetCSS("QFrame{ background-color: white; }")

//-------------------
// Frame superior
//-------------------
oPanelHead := TPanel():New(0,0,Nil,oPanelMain,,.F.,,,,200,20)
oPanelHead:Align := CONTROL_ALIGN_TOP
oTButton := TBtnBmp2():New(0,0,26,10,'fwskin_delete_ico',,,,{||oDlg:End()},oPanelHead,,,.T. )
oTButton:Align := CONTROL_ALIGN_RIGHT

oSayHeader := TSay():New(4,5,{||STR0001},oPanelHead,,,,,,.T.,,,200,10,,,,,,.T.) //-- "Planejamento de Rotas"
oSayHeader:SetCSS("QLabel{ font-size: 18px; }")
oSayHeader:lTransparent := .T.

//-------------------
// Frame central
//-------------------
oPanelBody := TPanel():New(0,0,Nil,oPanelMain,,.F.,,0,0,300,300)
oPanelBody:Align := CONTROL_ALIGN_ALLCLIENT

oPanelLeft := TPanel():New(0,0,Nil,oPanelBody,,.F.,,0,,170,150)
oPanelLeft:Align := CONTROL_ALIGN_LEFT

// Itens do painel Esquerdo
oPnLeftTop := TPanel():New(0,0,Nil,oPanelLeft,,.F.,,0,,170,180)
oPnLeftTop:Align := CONTROL_ALIGN_TOP

//-- Pedagio	
oPnLeftZ := TPanel():New(0,0,Nil,oPanelLeft,,.F.,,0,,170,180)
oPnLeftZ:Align := CONTROL_ALIGN_ALLCLIENT

oPnLeftBot := TPanel():New(0,0,Nil,oPanelLeft,,.F.,,0,,170,40)
oPnLeftBot:Align := CONTROL_ALIGN_BOTTOM 
	
CriaBrwPed(oPnLeftTop)
CriaDetEnt(oPnLeftBot)
CriaBrwPdg(oPnLeftZ)

// ------------------------------------------
// Cria navegador embedado
// ------------------------------------------
oPanelCent := TPanel():New(0,0,Nil,oPanelBody,,.F.,,0,,170,300)
oPanelCent:Align := CONTROL_ALIGN_ALLCLIENT

oPanelSup := TPanel():New(0,0,Nil,oPanelCent,,.F.,,0,,170,aCoors[3]*0.42)
oPanelSup:Align := CONTROL_ALIGN_TOP

oPanelInf := TPanel():New(1500,0,Nil,oPanelCent,,.F.,,0,,170,40)
oPanelInf:Align := CONTROL_ALIGN_BOTTOM

TMSAC25( oPanelSup , cFilRot, cIdRot, nSeqRot )
CriaInfoTrip( oPanelInf )

Return


/*/-----------------------------------------------------------
{Protheus.doc} CriaBrwPed()

Uso: TMSAC24

@sample
//ViewDef()

@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function CriaBrwPed(oOwner)
Local oPanel, oColumn

oPanel := TPanel():New(0,0,,oOwner,,.T.,,,,0,0)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

// Define o Browse
oBrowse := FWBrowse():New(oPanel)
oBrowse:SetDataArray(.T.)
oBrowse:SetArray(aPedidos)
oBrowse:DisableConfig(.T.)
oBrowse:DisableReport(.T.)
oBrowse:DisableLocate(.T.)
oBrowse:DisableFilter(.T.)

// Cria uma coluna de legenda
oBrowse:AddLegend({||aPedidos[oBrowse:nAt,DATA_STATUS]==DMS_PENDENTE}	, "BLUE"  	,STR0002 ) //"Pendente")
oBrowse:AddLegend({||aPedidos[oBrowse:nAt,DATA_STATUS]==DMS_REJEIT}		, "RED"    	,STR0003 ) //"Rejeitado")
oBrowse:AddLegend({||aPedidos[oBrowse:nAt,DATA_STATUS]==DMS_PROCESSA}	, "GREEN"  	,STR0004 ) //"Processado")
oBrowse:AddLegend({||aPedidos[oBrowse:nAt,DATA_STATUS]==DMS_FALHA}		, "ORANGE"  ,STR0005 ) //"Falha")


// Adiciona as colunas do Browse
oColumn := FWBrwColumn():New()
oColumn:SetData({||aPedidos[oBrowse:nAt,DATA_TIPODOC]})
oColumn:SetTitle( STR0006 ) // "Tipo Doc")
oColumn:SetSize(3)
oBrowse:SetColumns({oColumn})

oColumn := FWBrwColumn():New()
oColumn:SetData({||aPedidos[oBrowse:nAt,DATA_PEDIDO]})
oColumn:SetTitle( STR0007 ) //"Nº Documento")
oColumn:SetSize(TamSX3("DT6_DOC")[1] + TamSX3("DT6_SERIE")[1] )
oBrowse:SetColumns({oColumn})

oColumn := FWBrwColumn():New()
oColumn:SetData({||aPedidos[oBrowse:nAt,DATA_NOMEREDZ]})
oColumn:SetTitle( STR0008 ) // "Cliente Destinatário")
oColumn:SetSize(TamSX3("A1_NREDUZ")[1])
oBrowse:SetColumns({oColumn})
oBrowse:SetChange( {|| BrwPedChange() })
oBrowse:Activate()

Return oPanel

/*/-----------------------------------------------------------
{Protheus.doc} CriaDetEnt()

Uso: TMSAC24

@sample
//ViewDef()

@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function CriaDetEnt(oOwner)
Local oLayGrid0, oLayGrid1, oSay

// Cria o grupo de informações
oGroupInfo := TGroup():New(0,0,0,0, STR0009 ,oOwner,,,.T.) //-- "Dados da Entrega"
oGroupInfo:Align := CONTROL_ALIGN_ALLCLIENT

// Cria o layout principal
oLayGrid0 := TGridLayout():New(oGroupInfo,CONTROL_ALIGN_ALLCLIENT)

// Primeira linha - Cliente
oSay := TSay():New( 0, 0, {|| "<b>" + STR0010 + "</b>  " + aPedidos[oBrowse:nAt,DATA_CLIENTE] + "-" + aPedidos[oBrowse:nAt,DATA_LOJACLI] + "  " + RTrim(aPedidos[oBrowse:nAt,DATA_NOMECLI]) },oGroupInfo, , , , , , .T., , , 0,10, , , , , , .T.) //-- Cliente
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid0:addInLayout(oSay, 1, 1,,,LAYOUT_ALIGN_VCENTER)
Aadd(oGroupInfo:aControls,oSay)

// Segunda linha - Endereço
//oLayGrid1 := TGridLayout():New(oGroupInfo, LAYOUT_LINEAR_L2R)
oSay := TSay():New( 0, 0, {||"<b>" + STR0011 + "</b>  " + RTrim(aPedidos[oBrowse:nAt,DATA_ENDERECO]) },oGroupInfo, , , , , , .T., , , 0,10, , , , , , .T.)
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid0:addInLayout(oSay, 2, 1,,,LAYOUT_ALIGN_TOP)
Aadd(oGroupInfo:aControls,oSay)

// Terceira linha - Bairro e Cidade
oLayGrid1 := TGridLayout():New(oGroupInfo, LAYOUT_LINEAR_L2R)
oSay := TSay():New( 0, 0, {|| "<b>" + STR0012 + "</b>  " + RTrim(aPedidos[oBrowse:nAt,DATA_BAIRRO]) },oGroupInfo, , , , , , .T., , , 0,10, , , , , , .T.)
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid1:addInLayout(oSay, 1, 1,,,LAYOUT_ALIGN_VCENTER)
Aadd(oGroupInfo:aControls,oSay)
oSay := TSay():New( 0, 0, {|| "<b>" + STR0013 + "</b>  "+ RTrim(aPedidos[oBrowse:nAt,DATA_CIDADE]) },oGroupInfo, , , , , , .T., , , 0,10, , , , , , .T.)
oLayGrid1:addInLayout(oSay, 1, 2,,,LAYOUT_ALIGN_VCENTER)
Aadd(oGroupInfo:aControls,oSay)
oLayGrid0:addInLayout(oLayGrid1, 3, 1,,,LAYOUT_ALIGN_TOP)

// Terceira linha - Cidade, Estado e CEP
oLayGrid1 := TGridLayout():New(oGroupInfo, LAYOUT_LINEAR_L2R)
oSay := TSay():New( 0, 0, {|| "<b>" + STR0014 + "</b>  " + aPedidos[oBrowse:nAt,DATA_ESTADO] },oGroupInfo, , , , , , .T., , , 0,10, , , , , , .T.)
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid1:addInLayout(oSay, 1, 2,,,LAYOUT_ALIGN_VCENTER)
Aadd(oGroupInfo:aControls,oSay)
oSay := TSay():New( 0, 0, {|| "<b>" + STR0015 + "</b>  " + aPedidos[oBrowse:nAt,DATA_CEP] },oGroupInfo, , , , , , .T., , , 0,10, , , , , , .T.)
oLayGrid1:addInLayout(oSay, 1, 3,,,LAYOUT_ALIGN_VCENTER)
Aadd(oGroupInfo:aControls,oSay)
oLayGrid0:addInLayout(oLayGrid1, 4, 1,,,LAYOUT_ALIGN_TOP)

// Quarta linha - Chegada, Tempo e Saída
/*oLayGrid1 := TGridLayout():New(oGroupInfo, LAYOUT_LINEAR_L2R)
oSay := TSay():New( 0, 0, {|| "<b>Chegada Prevista:</b> " + DtoC(aPedidos[oBrowse:nAt,DATA_DATACHEG]) + " " + DtoC(aPedidos[oBrowse:nAt,DATA_HORACHEG])  },oGroupInfo, , , , , , .T., , , 0,10, , , , , , .T.)
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid1:addInLayout(oSay, 2, 1,,,LAYOUT_ALIGN_VCENTER)
Aadd(oGroupInfo:aControls,oSay)
oLayGrid0:addInLayout(oLayGrid1, 5, 1,,,LAYOUT_ALIGN_TOP)

oLayGrid1 := TGridLayout():New(oGroupInfo, LAYOUT_LINEAR_L2R)
oSay := TSay():New( 0, 0, {|| "<b>Saída Prevista:</b> " + DtoC(aPedidos[oBrowse:nAt,DATA_DATACHEG]) + " " + IntToHora(HoraToInt(aPedidos[oBrowse:nAt,DATA_HORACHEG],2)+HoraToInt(aPedidos[oBrowse:nAt,DATA_TIMESERV],4),2) + ":00" },oGroupInfo, , , , , , .T., , , 0,10, , , , , , .T.)
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid1:addInLayout(oSay, 1, 1,,,LAYOUT_ALIGN_VCENTER)
Aadd(oGroupInfo:aControls,oSay)
oLayGrid0:addInLayout(oLayGrid1, 6, 1,,,LAYOUT_ALIGN_TOP)*/

Return oGroupInfo

/*/-----------------------------------------------------------
{Protheus.doc} BrwPedChange()

Uso: TMSAC24

@sample
//ViewDef()

@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function BrwPedChange()
Local nX

If (oGroupInfo != Nil)
	For nX := 1 To Len(oGroupInfo:aControls)
		oGroupInfo:aControls[nX]:Refresh()
	Next nX
EndIf

Return

/*/-----------------------------------------------------------
{Protheus.doc} CriaBrwPdg()

Uso: TMSAO51

@sample
//ViewDef()

@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function CriaBrwPdg(oOwner)
Local oPanel, oColumn , oGroupPDg , oSayPdg , oPanelAux
Local aCoors  := FWGetDialogSize( oMainWnd )

//Local nValPdg	:= 0 

Static oBrowsePdg := Nil


oPanel := TPanel():New(0,0,,oOwner,,.F.,,0,,170,aCoors[3]*0.17)
oPanel:Align := CONTROL_ALIGN_TOP

// Define o Browse
oBrowsePdg := FWBrowse():New(oPanel)
oBrowsePdg:SetDataArray(.T.)
oBrowsePdg:DisableConfig(.T.)
oBrowsePdg:DisableReport(.T.)
oBrowsePdg:DisableLocate(.T.)
oBrowsePdg:DisableFilter(.T.)

// Adiciona as colunas do Browse
oColumn := FWBrwColumn():New()
oColumn:SetData({||aPdgTPR[oBrowsePdg:nAt,1]})
oColumn:SetTitle( STR0016 ) // "Pedagio")
oColumn:SetSize(15)
oBrowsePdg:SetColumns({oColumn})

oColumn := FWBrwColumn():New()
oColumn:SetData({|| "R$ " + Transform(aPdgTPR[oBrowsePdg:nAt,2],"@E 999,999.99")} )  //aPdgTPR
oColumn:SetTitle( STR0017 ) //"Valor")
oColumn:SetSize(6)
oBrowsePdg:SetColumns({oColumn})

oBrowsePdg:SetArray(aPdgTPR)

oBrowsePdg:Activate()

oPanelAux := TPanel():New(0,0,,oOwner,,.F.,,0,,170,15)
oPanelAux:Align := CONTROL_ALIGN_BOTTOM

oGroupPDg := TGroup():New(0,0,0,0,STR0016 ,oPanelAux,,,.F.) //-- pedagio
oGroupPDg:Align := CONTROL_ALIGN_BOTTOM

oSayPdg := TSay():New( 0, 0, {|| "<b>" + STR0018 + " R$ </b>  " + Transform(nValPdg,"@E 999,999.99")  },oGroupPDg, , , , , , .T., , , 0,10, , , , , , .T.) //-- Valor total: 
oSayPdg:SetCSS("QLabel { padding-left: 8px; }")

Return oPanel


/*/-----------------------------------------------------------
{Protheus.doc} CriaInfoTrip()

Uso: TMSAC24

@sample
//ViewDef()

@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function CriaInfoTrip(oOwner)
Local oLayGrid0, oLayGrid1, oSay , oInfoTrip

Default oOwner		:= Nil 

// Cria o grupo de informações
oInfoTrip := TGroup():New(0,0,0,0,STR0001,oOwner,,,.T.) //- "Planejamento de Rotas"
oInfoTrip:Align := CONTROL_ALIGN_ALLCLIENT

// Cria o layout principal
oLayGrid0 := TGridLayout():New(oInfoTrip,CONTROL_ALIGN_ALLCLIENT)

// Primeira linha - Viagens //--nTrip
oSay := TSay():New( 0, 0, {|| "<b>" + STR0019+ "</b>  " + cValToChar(aRodTPR[8])  },oInfoTrip, , , , , , .T., , , 0,10, , , , , , .T.)
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid0:addInLayout(oSay, 1, 1,,,LAYOUT_ALIGN_VCENTER)
Aadd(oInfoTrip:aControls,oSay)

// Segunda linha - Endereço //--nDist 
//oLayGrid1 := TGridLayout():New(oGroupInfo, LAYOUT_LINEAR_L2R)
oSay := TSay():New( 0, 0, {|| "<b>" + STR0020+ "</b>  " + Transform(aRodTPR[2], '@E 999,999.999') + " Km"  },oInfoTrip, , , , , , .T., , , 0,10, , , , , , .T.)
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid0:addInLayout(oSay, 2, 1,,,LAYOUT_ALIGN_TOP)
Aadd(oInfoTrip:aControls,oSay)

// Terceira linha - Bairro e Cidade //--nStops
oLayGrid1 := TGridLayout():New(oInfoTrip, LAYOUT_LINEAR_L2R)
oSay := TSay():New( 0, 0, {|| "<b>" + STR0021+ "</b>  " + cValToChar(aRodTPR[3]) },oInfoTrip, , , , , , .T., , , 0,10, , , , , , .T.)
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid1:addInLayout(oSay, 1, 1,,,LAYOUT_ALIGN_VCENTER)
Aadd(oInfoTrip:aControls,oSay) //--nVolume
oSay := TSay():New( 0, 0, {|| "<b>" + STR0022+ "</b>  " + cValToChar(aRodTPR[4]) },oInfoTrip, , , , , , .T., , , 0,10, , , , , , .T.)
oLayGrid1:addInLayout(oSay, 1, 2,,,LAYOUT_ALIGN_VCENTER)
Aadd(oInfoTrip:aControls,oSay)
oLayGrid0:addInLayout(oLayGrid1, 3, 1,,,LAYOUT_ALIGN_TOP)

// Terceira linha - Cidade, Estado e CEP - nPeso
oLayGrid1 := TGridLayout():New(oInfoTrip, LAYOUT_LINEAR_L2R)
oSay := TSay():New( 0, 0, {|| "<b>" + STR0023+ "</b>  " + cValToChar(aRodTPR[5]) },oInfoTrip, , , , , , .T., , , 0,10, , , , , , .T.)
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid1:addInLayout(oSay, 1, 2,,,LAYOUT_ALIGN_VCENTER)
Aadd(oInfoTrip:aControls,oSay)

oSay := TSay():New( 0, 0, {|| "<b>" + STR0024+ "</b>  " + cValToChar(aRodTPR[6]) },oInfoTrip, , , , , , .T., , , 0,10, , , , , , .T.) //--nDuracao
oLayGrid1:addInLayout(oSay, 1, 3,,,LAYOUT_ALIGN_VCENTER)
Aadd(oInfoTrip:aControls,oSay)
oLayGrid0:addInLayout(oLayGrid1, 4, 1,,,LAYOUT_ALIGN_TOP)

// Quarta linha - Chegada, Tempo e Saída //-- nRejeit
oLayGrid1 := TGridLayout():New(oInfoTrip, LAYOUT_LINEAR_L2R)
oSay := TSay():New( 0, 0, {|| "<b>" + STR0025+ "</b>  " + cValToChar(aRodTPR[9])  },oInfoTrip, , , , , , .T., , , 0,10, , , , , , .T.)
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid1:addInLayout(oSay, 2, 1,,,LAYOUT_ALIGN_VCENTER)
Aadd(oInfoTrip:aControls,oSay)
oLayGrid0:addInLayout(oLayGrid1, 5, 1,,,LAYOUT_ALIGN_TOP)

oSay := TSay():New( 0, 0, {|| "<b>" + "Ret.Filial: " + "</b>  " + cValToChar(aRodTPR[1]) },oInfoTrip, , , , , , .T., , , 0,10, , , , , , .T.)//"Ret. Filial:" cRetFil
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid0:addInLayout(oSay, 2, 2,,,LAYOUT_ALIGN_VCENTER)
Aadd(oInfoTrip:aControls,oSay)

If !Empty(aRodTPR[7]) //--cViaExt
	oSay := TSay():New( 0, 0, {|| "<b>" + STR0026 + "</b>  " + cValToChar(aRodTPR[7])  },oInfoTrip, , , , , , .T., , , 0,10, , , , , , .T.)//"Viagem extra: "
	oSay:SetCSS("QLabel { padding-left: 8px; }")
	oLayGrid0:addInLayout(oSay, 2, 3,,,LAYOUT_ALIGN_VCENTER)
	Aadd(oInfoTrip:aControls,oSay)
EndIf

Return oInfoTrip


/*/-----------------------------------------------------------
{Protheus.doc} TMSAC24Map()

Uso: TMSAC24

@sample
//ViewDef()

@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Function TMSAC24Map( cAlias, nRecno, nOpcx ) 
Local aArea		:= GetArea() 
Local cFilRot   := ""
Local cIdRot	:= "" 
Local lRet		:= .T. 
Local nSeqRot   := Nil

TMSAC24Id(cAlias, nRecno, nOpcx, @cFilRot, @cIdRot, @nSeqRot )

//-- Exibe mapa
If !Empty( cIdRot )
	TMSAC24(cFilRot, cIdRot, nSeqRot)
Else
	lRet	:= .F. 
	Help("",1,"TMSAC2401")  //-- Não foram localizados os dados dos documentos para Plotagem do Mapa.
EndIf 

RestArea( aArea )
Return lRet


/*/-----------------------------------------------------------
{Protheus.doc} TMSAC24Id()

Uso: TMSAC24

@sample
//ViewDef()

@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Function TMSAC24Id( cAlias, nRecno, nOpcx, cFilRot, cIdRot, nSeqRot ) 
Local cQuery	:= "" 
Local cAliasQry	:= ""
Local aArea		:= GetArea() 

If cAlias == "DF8"

	cAliasQry	:= GetNextAlias() 

	cQuery 	:= " SELECT DMS_FILROT, DMS_IDROT, DMS_SEQROT "
	cQuery	+= " FROM " + RetSQLName("DMS") + " DMS "
	cQuery	+= " WHERE DMS_FILIAL	= '" + xFilial("DMS") + "' "
	cQuery	+= " AND DMS_ENTEXT 	= 'DF8' "
	cQuery	+= " AND DMS_CHVEXT		= '" + RTrim( DF8->( DF8_FILIAL+DF8_FILORI+DF8_NUMPRG+DF8_SEQPRG ) ) + "' "
	cQuery	+= " AND DMS_STATUS		= '3' " //-- 3=Processado
	cQuery	+= " AND DMS.D_E_L_E_T_ = '' "
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)), cAliasQry, .F., .T.)
	While !(cAliasQry)->(Eof()) 
		cFilRot := (cAliasQry)->DMS_FILROT 
		cIdRot	:= (cAliasQry)->DMS_IDROT
		nSeqRot	:= (cAliasQry)->DMS_SEQROT
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())
			
ElseIf cAlias == "DTQ"
	cAliasQry	:= GetNextAlias() 

	cQuery 	:= " SELECT DMS_FILROT, DMS_IDROT, DMS_SEQROT "
	cQuery	+= " FROM " + RetSQLName("DMS") + " DMS "
	cQuery	+= " INNER JOIN " + RetSQLName("DF8") + " DF8 "
	cQuery	+= " 	ON DF8_FILIAL	= '" + xFilial("DF8") + "' "
	cQuery	+= " 	AND DF8_FILORI	= '" + DTQ->DTQ_FILORI + "' "
	cQuery	+= " 	AND DF8_VIAGEM	= '" + DTQ->DTQ_VIAGEM + "' "
	cQuery	+= "	AND DF8_STATUS	= '2' " //-- 2=Efetivada
	cQuery	+= " 	AND DF8.D_E_L_E_T_ = '' "
	cQuery	+= " WHERE DMS_FILIAL	= '" + xFilial("DMS") + "' "
	cQuery	+= " AND DMS_ENTEXT 	= 'DF8' "
	cQuery	+= " AND DMS_CHVEXT		=  DF8_FILIAL+DF8_FILORI+DF8_NUMPRG+DF8_SEQPRG "
	cQuery	+= " AND DMS_STATUS		= '3' " //-- 3=Processado
	cQuery	+= " AND DMS.D_E_L_E_T_ = '' "

	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)), cAliasQry, .F., .T.)
	While !(cAliasQry)->(Eof()) 
		cFilRot := (cAliasQry)->DMS_FILROT 
		cIdRot	:= (cAliasQry)->DMS_IDROT
		nSeqRot	:= (cAliasQry)->DMS_SEQROT
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

ElseIf cAlias == "DMR"
	cAliasQry	:= GetNextAlias() 

	cQuery 	:= " SELECT DMS_FILROT, DMS_IDROT , DMS_SEQROT "
	cQuery	+= " FROM " + RetSQLName("DMS") + " DMS "
	cQuery	+= " WHERE DMS_FILIAL	= '" + xFilial("DMS") + "' "
	cQuery	+= " AND DMS_FILROT		= '" + DMR->DMR_FILROT + "' "
	cQuery	+= " AND DMS_IDROT		= '" + DMR->DMR_IDROT + "' "
	cQuery	+= " AND DMS_STATUS		= '3' " //-- 3=Processado
	cQuery	+= " AND DMS.D_E_L_E_T_ = '' "
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)), cAliasQry, .F., .T.)
	While !(cAliasQry)->(Eof()) 
		cFilRot :=  (cAliasQry)->DMS_FILROT 
		cIdRot	:=  (cAliasQry)->DMS_IDROT
		nSeqRot	:=  (cAliasQry)->DMS_SEQROT
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())
EndIf 

RestArea(aArea)
FwFreeArray(aArea)
Return


/*/-----------------------------------------------------------
{Protheus.doc} InfTripTPR()

Uso: TMSAC24

@sample
//ViewDef()

@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function InfTripTPR(cJson , nSeqRot)

Local oObj			:= JsonObject():New()
Local oObjRot   	:= JsonObject():New()
Local oObjPdg 		:= JsonObject():New()
Local oObjStp 		:= JsonObject():New()
Local nTrips		:= 0 
Local nDist			:= 0 
Local nStops		:= 0 
Local nVolume		:= 0 
Local nPeso			:= 0 
Local nDuracao		:= 0 
Local nRejeit		:= 0 
Local nCount        := 0
Local cViaExt 		:= .F.
Local cRetFil       := ""
Local nCountStp		:= 0
Local nCountPdg		:= 0
Local cDescDest		:= ""

Default cJson		:= "" 
Default nSeqRot     := Nil


If !Empty(cJson) .And. oObj:FromJson( cJson ) <> "C"
	For nCount := 1 To Len( oObj["tripsResults"] )
		oObjRot := oObj["tripsResults"][nCount]
		cRetFil	:= If( oObjRot["considerReturnDistance"]==.T.,"Sim","Não")

		
		If lAllSeqRot
			//-Identifa os pedágios pela DMS 
			For nCountStp := 1 To Len( oObjRot["stops"] )
				oObjStp := oObjRot["stops"][nCountStp]
				If oObjStp["sequence"] = 0
					loop
				EndIf

				If !Empty(oObjStp["tollValues"])
					For nCountPdg := 1 To Len( oObjStp["tollValues"] )
						oObjPdg := oObjStp["tollValues"][nCountPdg]

						cDescDest := IIF(Empty(oObjStp["locality"]["name"]),  oObjStp["locality"]["identifier"], oObjStp["locality"]["name"])

						Aadd(aPdgTPR,  { oObjPdg["name"], oObjPdg["value"], cDescDest})
					Next nCountPdg 
				EndIf
				//-- Soma o valor do pedágio 
				If !Empty(oObjRot["tollValue"])
					nValPdg += oObjRot["tollValue"]
				EndIf 
			Next nCountStp

			nTrips	:= Iif(ValType(oObj["summary"]["totalTrips"])<>"U", oObj["summary"]["totalTrips"], 0)
			nDist	:= oObj["summary"]["totalDistance"]
			nStops	:= oObj["summary"]["totalStops"]
			nVolume	:= oObj["summary"]["totalVolume"]
			nPeso	:= oObj["summary"]["totalWeight"]
			nDuracao:= OMSMiliseg( oObj["summary"]["totalDuration"])
			nRejeit	:= oObj["summary"]["rejectedOrders"]
			If Empty(cViaExt) .Or. oObjRot["extraTrip"] ==.T.
				cViaExt	:= Iif( oObjRot["extraTrip"] == .T.,"Sim","Não")
			EndIf
		Else
			If oObjRot["sequential"] =  nSeqRot
				//--Identifica os pedagios por sequencia  	
				For nCountStp := 1 To Len( oObjRot["stops"] )
					oObjStp := oObjRot["stops"][nCountStp]
					If oObjStp["sequence"] = 0
						loop
					EndIf

					If !Empty(oObjStp["tollValues"])
						For nCountPdg := 1 To Len( oObjStp["tollValues"] )
							oObjPdg := oObjStp["tollValues"][nCountPdg]

							cDescDest := IIF(Empty(oObjStp["locality"]["name"]),  oObjStp["locality"]["identifier"], oObjStp["locality"]["name"])

							Aadd(aPdgTPR,  { oObjPdg["name"], oObjPdg["value"], cDescDest})
						Next nCountPdg 
					EndIf

				Next nCountStp
				//Valor total do Pedágio
				If !Empty(oObjRot["tollValue"])
					nValPdg := oObjRot["tollValue"]
				EndIf

				nTrips  := 1
				nDist	:= oObjRot["distance"]  
				nStops	:= oObjRot["numberOfStops"]
				nVolume	:= oObjRot["volume"]
				nPeso	:= oObjRot["weight"]
				nDuracao:= OMSMiliseg( oObjRot["duration"])	
				cViaExt	:= Iif( oObjRot["extraTrip"] == .T.,"Sim","Não")

				Exit
			EndIf
		EndIf
	Next nCount 
EndIf
//-- Dados do rodapé de inf. da TRIP 
Aadd(aRodTPR, cRetFil)
Aadd(aRodTPR, nDist)
Aadd(aRodTPR, nStops)
Aadd(aRodTPR, nVolume)
Aadd(aRodTPR, nPeso)
Aadd(aRodTPR, nDuracao)
Aadd(aRodTPR,cViaExt)
Aadd(aRodTPR, nTrips)
Aadd(aRodTPR, nRejeit)

Return 
