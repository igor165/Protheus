#include 'TOTVS.ch'
#include 'OMSATPR3.ch'

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
#define DATA_SEQ      17
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
Static oBrowsePdg   := Nil
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
Static _aRodape    	:= {}
Static _aPedagios  	:= {}
Static _nValPdg     := 0
Static _lPedagio    := .F.
Static _cFilRot     := ""
Static _cIdRot      := ""
Static _nSeqRot     := 0
Static _nQtdten     := 0
Static _lNovaRout   := SuperGetMv("MV_OMSLROT",.F.,.F.) //Ativa botao de novo ponto no mapa
Static _llogTPR 	:= SuperGetMV("MV_TPRCLOG",.F.,.T.)

/*/-----------------------------------------------------------
{Protheus.doc} OMSTPRRota() Copia do TMSAC24
Montagem e visualização do mapa com integração NEOLOG
@author Equipe OMS
@since 09/09/2021
@version 1.0
@type function
-----------------------------------------------------------/*/
Function OMSTPRRota( cFilRot, cIdRot, nSeqRot )
Local oSize
Local lRet := .F.
Local cJson := ""
Local bKeyF5 		:= { || OMSUpdTPR3() }//"Parâmetros do planejamento" 

Default cIdRot		:= "" 
Default nSeqRot     := Nil

SetKey( VK_F5, bKeyF5 )

lAllSeqRot:= nSeqRot == Nil

_nValPdg   := 0
_aRodape   := {}
_aPedagios := {}
_lPedagio  := .F.
_cFilRot   := cFilRot
_cIdRot    := cIdRot
_nSeqRot   := nSeqRot

//-- Calcula as dimensoes dos objetos
oSize := FwDefSize():New( .T. )  // Com enchoicebar
//-- Cria Enchoice
oSize:AddObject( "MASTER", 100, 100, .T., .T. ) // Adiciona enchoice

//-- Dispara o calculo
oSize:Process()

lRet := LoadPedidos( cFilRot, cIdRot, nSeqRot )

cJson := OMSViagJso(cFilRot, cIdRot)

OMSTPR3Dat(cJson, nSeqRot)

If lRet .And. !Empty(cJson)
	//-- Desenha a dialog
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM ; //--"Visualização de Rotas (TPR)"
	oSize:aWindSize[1],oSize:aWindSize[2] TO ;
	oSize:aWindSize[3],oSize:aWindSize[4] PIXEL STYLE NOr(WS_VISIBLE,WS_POPUP)

	LayLinear( cFilRot, cIdRot, nSeqRot, cJson  )

	ACTIVATE MSDIALOG oDlg
ElseIf Empty(cJson)
	Help(,,'HELP',,STR0027+ cFilRot+cIdRot+".",1,0,) //"Inconsistência ao obter roteirização 
Else
	Help(,,'HELP',,STR0023,1,0,) //O planejamento não possui roteirização (mapa).
EndIf

SetKey( VK_F5, Nil )

Return 

/*/{Protheus.doc} LoadPedidos
	(long_description)
	@author Carlos Augusto
	@since 21/09/2021
*/
Static Function LoadPedidos( cFilRot, cIdRot, nSeqRot )
	Local lRet		:= .F. 
	Local cQuery	:= "" 
	Local cAliasQry	:= GetNextAlias() 
	Local nCount	:= 0 
	Local nPontoEnt	:= 2
	Local cPontoAnt := ""
	Local nTamC9Fil := TamSX3('C9_FILIAL')[1]
	Local nTamC9Ped := TamSX3('C9_PEDIDO')[1]
	Local nTamC9Ite := TamSX3('C9_ITEM')[1]
	Local nTamC9Seq := TamSX3('C9_SEQUEN')[1]
	Local nTamC9Prd := TamSX3('C9_PRODUTO')[1]
	Default cIdRot	:= "" 
	Default nSeqRot := Nil

	cQuery += " SELECT SC5.C5_FILIAL,"
	cQuery += "       SC5.C5_NUM,"
	cQuery += "       DMS.DMS_STATUS,"
	cQuery += "       CASE"
	cQuery += "           WHEN SC5.C5_TIPO IN ('B',"
	cQuery += "                                'D') THEN SA2.A2_FILIAL"
	cQuery += "           ELSE SA1.A1_FILIAL"
	cQuery += "       END AS TMP_FILFCL,"
	cQuery += "       SC5.C5_CLIENT,"
	cQuery += "       CASE"
	cQuery += "           WHEN SC5.C5_TIPO IN ('B',"
	cQuery += "                                'D') THEN SA2.A2_LOJA"
	cQuery += "           ELSE SA1.A1_LOJA"
	cQuery += "       END AS TMP_LOJFCL,"
	cQuery += "       CASE"
	cQuery += "           WHEN (SC5.C5_REDESP IS NOT NULL"
	cQuery += "                 AND SC5.C5_REDESP <> ' ') THEN SA4.A4_NOME"
	cQuery += "           WHEN (SC5.C5_REDESP IS NULL"
	cQuery += "                 OR SC5.C5_REDESP = ' ')"
	cQuery += "                AND SC5.C5_TIPO IN ('B',"
	cQuery += "                                    'D') THEN SA2.A2_NOME"
	cQuery += "           ELSE SA1.A1_NOME"
	cQuery += "       END AS TMP_NOME,"
	cQuery += "       CASE"
	cQuery += "           WHEN (SC5.C5_REDESP IS NOT NULL"
	cQuery += "                 AND SC5.C5_REDESP <> ' ') THEN SA4.A4_NREDUZ"
	cQuery += "           WHEN (SC5.C5_REDESP IS NULL"
	cQuery += "                 OR SC5.C5_REDESP = ' ')"
	cQuery += "                AND SC5.C5_TIPO IN ('B',"
	cQuery += "                                    'D') THEN SA2.A2_NREDUZ"
	cQuery += "           ELSE SA1.A1_NREDUZ"
	cQuery += "       END AS TMP_NOMFAN,"
	cQuery += "       CASE"
	cQuery += "           WHEN (SC5.C5_REDESP IS NOT NULL"
	cQuery += "                 AND SC5.C5_REDESP <> ' ') THEN SA4.A4_CGC"
	cQuery += "           WHEN (SC5.C5_REDESP IS NULL"
	cQuery += "                 OR SC5.C5_REDESP = ' ')"
	cQuery += "                AND SC5.C5_TIPO IN ('B',"
	cQuery += "                                    'D') THEN SA2.A2_CGC"
	cQuery += "           ELSE SA1.A1_CGC"
	cQuery += "       END AS TMP_CGCCLI,"
	cQuery += "       CASE"
	cQuery += "           WHEN (SC5.C5_REDESP IS NOT NULL"
	cQuery += "                 AND SC5.C5_REDESP <> ' ') THEN SA4.A4_CEP"
	cQuery += "           WHEN (SC5.C5_REDESP IS NULL"
	cQuery += "                 OR SC5.C5_REDESP = ' ')"
	cQuery += "                AND SC5.C5_TIPO IN ('B',"
	cQuery += "                                    'D') THEN SA2.A2_CEP"
	cQuery += "           ELSE SA1.A1_CEP"
	cQuery += "       END AS TMP_CEP,"
	cQuery += "       CASE"
	cQuery += "           WHEN (SC5.C5_REDESP IS NOT NULL"
	cQuery += "                 AND SC5.C5_REDESP <> ' ') THEN SA4.A4_END"
	cQuery += "           WHEN (SC5.C5_REDESP IS NULL"
	cQuery += "                 OR SC5.C5_REDESP = ' ')"
	cQuery += "                AND SC5.C5_TIPO IN ('B',"
	cQuery += "                                    'D') THEN SA2.A2_END"
	cQuery += "           ELSE SA1.A1_END"
	cQuery += "       END AS TMP_END,"
	cQuery += "       CASE"
	cQuery += "           WHEN (SC5.C5_REDESP IS NOT NULL"
	cQuery += "                 AND SC5.C5_REDESP <> ' ') THEN SA4.A4_BAIRRO"
	cQuery += "           WHEN (SC5.C5_REDESP IS NULL"
	cQuery += "                 OR SC5.C5_REDESP = ' ')"
	cQuery += "                AND SC5.C5_TIPO IN ('B',"
	cQuery += "                                    'D') THEN SA2.A2_BAIRRO"
	cQuery += "           ELSE SA1.A1_BAIRRO"
	cQuery += "       END AS TMP_BAIRRO,"
	cQuery += "       CASE"
	cQuery += "           WHEN (SC5.C5_REDESP IS NOT NULL"
	cQuery += "                 AND SC5.C5_REDESP <> ' ') THEN SA4.A4_MUN"
	cQuery += "           WHEN (SC5.C5_REDESP IS NULL"
	cQuery += "                 OR SC5.C5_REDESP = ' ')"
	cQuery += "                AND SC5.C5_TIPO IN ('B',"
	cQuery += "                                    'D') THEN SA2.A2_MUN"
	cQuery += "           ELSE SA1.A1_MUN"
	cQuery += "       END AS TMP_MUN,"
	cQuery += "       CASE"
	cQuery += "           WHEN (SC5.C5_REDESP IS NOT NULL"
	cQuery += "                 AND SC5.C5_REDESP <> ' ') THEN SA4.A4_EST"
	cQuery += "           WHEN (SC5.C5_REDESP IS NULL"
	cQuery += "                 OR SC5.C5_REDESP = ' ')"
	cQuery += "                AND SC5.C5_TIPO IN ('B',"
	cQuery += "                                    'D') THEN SA2.A2_EST"
	cQuery += "           ELSE SA1.A1_EST"
	cQuery += "       END AS TMP_EST,"
	cQuery += "       CASE"
	cQuery += "           WHEN (SC5.C5_REDESP IS NOT NULL"
	cQuery += "                 AND SC5.C5_REDESP <> ' ') THEN 'SA4'"
	cQuery += "           WHEN (SC5.C5_REDESP IS NULL"
	cQuery += "                 OR SC5.C5_REDESP = ' ')"
	cQuery += "                AND SC5.C5_TIPO IN ('B',"
	cQuery += "                                    'D') THEN 'SA2'"
	cQuery += "           ELSE 'SA1'"
	cQuery += "       END AS TMP_ENTIDA"
	cQuery += " FROM " + RetSqlName("SC5") + " SC5"
	cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.C6_FILIAL = SC5.C5_FILIAL"
	cQuery += " AND SC6.C6_NUM = SC5.C5_NUM"
	cQuery += " AND SC6.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN " + RetSqlName("SC9") + " SC9 ON SC9.C9_FILIAL = SC5.C5_FILIAL"
	cQuery += " AND SC9.C9_PEDIDO = SC5.C5_NUM"
	cQuery += " AND SC9.C9_ITEM = SC6.C6_ITEM"
	cQuery += " AND SC9.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2 ON SA2.A2_FILIAL = '"+FwXFilial("SA2")+"'"
	cQuery += " AND SA2.A2_COD = SC5.C5_CLIENT"
	cQuery += " AND SA2.A2_LOJA = SC5.C5_LOJAENT"
	cQuery += " AND SA2.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL = '"+FwXFilial("SA1")+"'"
	cQuery += " AND SA1.A1_COD = SC5.C5_CLIENT"
	cQuery += " AND SA1.A1_LOJA = SC5.C5_LOJAENT"
	cQuery += " AND SA1.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN " + RetSqlName("SA4") + " SA4 ON SA4.A4_FILIAL = '"+FwXFilial("SA4")+"'"
	cQuery += " AND SA4.A4_COD = SC5.C5_REDESP"
	cQuery += " AND SA4.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN " + RetSqlName("DMS") + " DMS ON DMS.DMS_FILIAL = '"+FwXFilial("DMS")+"'"
	cQuery += " AND DMS.DMS_FILROT = '"+cFilRot+"'"
	cQuery += " AND DMS_IDROT = '"+cIdRot+"'"
	cQuery += " AND DMS.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN " + RetSqlName("DAI") + " DAI ON DAI.DAI_FILIAL = '"+FwXFilial("DAI")+"'"
	cQuery += " AND DAI.DAI_COD = SC9.C9_CARGA"
	cQuery += " AND DAI.DAI_SEQCAR = SC9.C9_SEQCAR"
	cQuery += " AND DAI.DAI_SEQUEN = SC9.C9_SEQENT"
	cQuery += " AND DAI.DAI_PEDIDO = SC9.C9_PEDIDO"
	cQuery += " WHERE DMS.DMS_ENTIDA = 'SC9'"
	cQuery += 	" AND SUBSTRING(DMS.DMS_CHVENT,1,"+cValtoChar(nTamC9Fil)+") = SC9.C9_FILIAL"
	cQuery += 	" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+1)+","+cValtoChar(nTamC9Ped)+") = SC9.C9_PEDIDO"		
	cQuery += 	" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+1)+","+cValtoChar(nTamC9Ite)+") = SC9.C9_ITEM"			
	cQuery += 	" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+nTamC9Ite+1)+","+cValtoChar(nTamC9Seq)+") = SC9.C9_SEQUEN"
	cQuery += 	" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+nTamC9Ite+nTamC9Seq+1)+","+cValtoChar(nTamC9Prd)+") = SC9.C9_PRODUTO"
	cQuery += " AND DMS_STATUS = '3'"
	cQuery += " AND DMS_CHVEXT <> '' "
	If !lAllSeqRot
		cQuery += " AND DMS_SEQROT = "+cValToChar(nSeqRot) +""
	EndIf

	cQuery += " GROUP BY SC5.C5_FILIAL,"
	cQuery += 	" SC5.C5_NUM,"
	cQuery += 	" DMS.DMS_STATUS,"
	cQuery += 	" SC5.C5_TIPO,"
	cQuery += 	" SA1.A1_FILIAL,"
	cQuery += 	" SA2.A2_FILIAL,"
	cQuery += 	" SA4.A4_FILIAL,"
	cQuery += 	" SC5.C5_CLIENT,"
	cQuery += 	" SA1.A1_COD,"
	cQuery += 	" SA2.A2_COD,"
	cQuery += 	" SA4.A4_COD,"
	cQuery += 	" SA1.A1_LOJA,"
	cQuery += 	" SA2.A2_LOJA,"
	cQuery += 	" SC5.C5_FECENT,"
	cQuery += 	" SC5.C5_REDESP,"
	cQuery += 	" SA2.A2_NOME,"
	cQuery += 	" SA1.A1_NOME,"
	cQuery += 	" SA4.A4_NOME,"
	cQuery += 	" SA2.A2_NREDUZ,"
	cQuery += 	" SA1.A1_NREDUZ,"
	cQuery += 	" SA4.A4_NREDUZ,"
	cQuery += 	" SA2.A2_CGC,"
	cQuery += 	" SA1.A1_CGC,"
	cQuery += 	" SA4.A4_CGC,"
	cQuery += 	" SA2.A2_CEP,"
	cQuery += 	" SA1.A1_CEP,"
	cQuery += 	" SA4.A4_CEP,"
	cQuery += 	" SA2.A2_END,"
	cQuery += 	" SA1.A1_END,"
	cQuery += 	" SA4.A4_END,"
	cQuery += 	" SA2.A2_BAIRRO,"
	cQuery += 	" SA1.A1_BAIRRO,"
	cQuery += 	" SA4.A4_BAIRRO,"
	cQuery += 	" SA2.A2_MUN,"
	cQuery += 	" SA1.A1_MUN,"
	cQuery += 	" SA4.A4_MUN,"
	cQuery += 	" SA2.A2_EST,"
	cQuery += 	" SA1.A1_EST,"
	cQuery += 	" SA4.A4_EST,"
	cQuery += 	" DAI.DAI_SEQUEN"
	cQuery += 	" ORDER BY DAI.DAI_SEQUEN "


	cQuery := ChangeQuery(cQuery)

	OMSTPRCLOG(_llogTPR, "OMSATPR3", STR0033 + STR0034 + cQuery ) //"TOTVS Planejamento de Rotas(TPR) - OMSATPR3 - Carregamento de pedidos: "

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

	aPedidos	:= {} 
	While (cAliasQry)->( !Eof() )
		lRet := .T.

		If !Empty(cPontoAnt) .And. cPontoAnt != (cAliasQry)->TMP_ENTIDA + (cAliasQry)->C5_CLIENT + (cAliasQry)->TMP_LOJFCL
			nPontoEnt++
		EndIf

		Aadd(aPedidos, { Val( (cAliasQry)->DMS_STATUS ) , cValToChar(nCount), (cAliasQry)->C5_NUM,;
						(cAliasQry)->C5_CLIENT , (cAliasQry)->TMP_LOJFCL,;
						(cAliasQry)->TMP_NOME,;
						(cAliasQry)->TMP_NOMFAN,;
						(cAliasQry)->TMP_END, (cAliasQry)->TMP_BAIRRO ,;
						(cAliasQry)->TMP_MUN , (cAliasQry)->TMP_EST , (cAliasQry)->TMP_CEP ,DDATABASE , Time() , "" , (cAliasQry)->TMP_ENTIDA,nPontoEnt} )

		cPontoAnt := (cAliasQry)->TMP_ENTIDA + (cAliasQry)->C5_CLIENT + (cAliasQry)->TMP_LOJFCL
		(cAliasQry)->( dbSkip() )
	EndDo 

	(cAliasQry)->(dbCloseArea())

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
@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function LayLinear( cFilRot, cIdRot, nSeqRot, cJson )
Local   aCoors  := FWGetDialogSize( oMainWnd )
Default cIdRot		:= "" 
Default cFilRot		:= "" 
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

oSayHeader := TSay():New(4,5,{||STR0001},oPanelHead,,,,,,.T.,,,200,10,,,,,,.T.) //-- "Visualização de Rotas (TPR)"
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
If _lPedagio .Or. _lNovaRout
	oPnLeftTop := TPanel():New(0,0,Nil,oPanelLeft,,.F.,,0,,170,aCoors[3]*0.22)
Else
	oPnLeftTop := TPanel():New(0,0,Nil,oPanelLeft,,.F.,,0,,170,aCoors[3]*0.39)
EndIf
oPnLeftTop:Align := CONTROL_ALIGN_TOP

If _lPedagio .Or. _lNovaRout
	//-- Pedagio	
	oPnLeftZ := TPanel():New(0,0,Nil,oPanelLeft,,.F.,,0,,170,aCoors[3]*0.17)
	oPnLeftZ:Align := CONTROL_ALIGN_ALLCLIENT
EndIf

oPnLeftBot := TPanel():New(0,0,Nil,oPanelLeft,,.F.,,0,,170,40)
oPnLeftBot:Align := CONTROL_ALIGN_BOTTOM 
	
CriaBrwPed(oPnLeftTop)
CriaDetEnt(oPnLeftBot)
If _lPedagio .Or. _lNovaRout
	CriaBrwPdg(oPnLeftZ)
EndIf

// ------------------------------------------
// Cria navegador embedado
// ------------------------------------------
oPanelCent := TPanel():New(0,0,Nil,oPanelBody,,.F.,,0,,170,300)
oPanelCent:Align := CONTROL_ALIGN_ALLCLIENT

oPanelSup := TPanel():New(0,0,Nil,oPanelCent,,.F.,,0,,170,aCoors[3]*0.42)
oPanelSup:Align := CONTROL_ALIGN_TOP

oPanelBai := TPanel():New(1500,0,Nil,oPanelCent,,.F.,,0,,170,40)
oPanelBai:Align := CONTROL_ALIGN_BOTTOM

oPanelInf := TPanel():New(0,0,Nil,oPanelBai,,.F.,,0,,aCoors[4]*0.333,40)
oPanelInf:Align := CONTROL_ALIGN_LEFT

oPanelBut := TPanel():New(0,0,Nil,oPanelBai,,.F.,,0,,20,40)
oPanelBut:Align := CONTROL_ALIGN_ALLCLIENT
oInfoTripc := TGroup():New(0,0,0,0,STR0030,oPanelBut,,,.T.) //"Ações"
oInfoTripc:Align := CONTROL_ALIGN_ALLCLIENT

TButton():New( 016, 005, STR0031, oInfoTripc,{|| OMSUpdTPR3() },30,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Atualizar"


TMSAC25( oPanelSup , cFilRot, cIdRot, nSeqRot )
CriaInfoTrip( oPanelInf )

Return


/*/-----------------------------------------------------------
{Protheus.doc} CriaBrwPed()
@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function CriaBrwPed(oOwner)
Local oPanel, oColumn
Local  aCoors  := FWGetDialogSize( oMainWnd )

If _lPedagio .Or. _lNovaRout
	oPanel := TPanel():New(0,0,,oOwner,,.T.,,,,170,aCoors[3]*0.22)
Else
	oPanel := TPanel():New(0,0,,oOwner,,.T.,,,,170,aCoors[3]*0.39)
EndIf
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

// Define o Browse
oBrowse := FWBrowse():New(oPanel)
oBrowse:SetDataArray(.T.)
oBrowse:SetArray(aPedidos)
oBrowse:DisableConfig(.T.)
oBrowse:DisableReport(.T.)
oBrowse:DisableLocate(.T.)
oBrowse:DisableFilter(.T.)

oColumn := FWBrwColumn():New()
oColumn:SetData({||aPedidos[oBrowse:nAt,DATA_SEQ]})
oColumn:SetTitle( "N" )
oColumn:SetSize(3)
oBrowse:SetColumns({oColumn})

oColumn := FWBrwColumn():New()
oColumn:SetData({||aPedidos[oBrowse:nAt,DATA_PEDIDO]})
oColumn:SetTitle( STR0002 ) //STR0002
oColumn:SetSize(TamSX3("C5_NUM")[1])
oBrowse:SetColumns({oColumn})

oColumn := FWBrwColumn():New()
oColumn:SetData({||aPedidos[oBrowse:nAt,DATA_NOMEREDZ]})
oColumn:SetTitle( STR0003 ) //STR0003
oColumn:SetSize(TamSX3("A1_NREDUZ")[1])
oBrowse:SetColumns({oColumn})
oBrowse:SetChange( {|| BrwPedChange() })
oBrowse:Activate()

Return oPanel

/*/-----------------------------------------------------------
{Protheus.doc} CriaDetEnt()
@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function CriaDetEnt(oOwner)
Local oLayGrid0, oLayGrid1, oSay

// Cria o grupo de informações
oGroupInfo := TGroup():New(0,0,0,0, STR0004 ,oOwner,,,.T.) //-- "Dados da Entrega"
oGroupInfo:Align := CONTROL_ALIGN_ALLCLIENT

// Cria o layout principal
oLayGrid0 := TGridLayout():New(oGroupInfo,CONTROL_ALIGN_ALLCLIENT)

// Primeira linha - Destino
oSay := TSay():New( 0, 0, {|| "<b>" + STR0020 + "</b>  " + aPedidos[oBrowse:nAt,DATA_CLIENTE] + "-" + aPedidos[oBrowse:nAt,DATA_LOJACLI] + "  " + RTrim(aPedidos[oBrowse:nAt,DATA_NOMECLI]) },oGroupInfo, , , , , , .T., , , 0,10, , , , , , .T.) //-- Cliente
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid0:addInLayout(oSay, 1, 1,,,LAYOUT_ALIGN_VCENTER)
Aadd(oGroupInfo:aControls,oSay)

// Segunda linha - Endereço
//oLayGrid1 := TGridLayout():New(oGroupInfo, LAYOUT_LINEAR_L2R)
oSay := TSay():New( 0, 0, {||"<b>" + STR0005 + "</b>  " + RTrim(aPedidos[oBrowse:nAt,DATA_ENDERECO]) },oGroupInfo, , , , , , .T., , , 0,10, , , , , , .T.)
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid0:addInLayout(oSay, 2, 1,,,LAYOUT_ALIGN_TOP)
Aadd(oGroupInfo:aControls,oSay)

// Terceira linha - Bairro e Cidade
oLayGrid1 := TGridLayout():New(oGroupInfo, LAYOUT_LINEAR_L2R)
oSay := TSay():New( 0, 0, {|| "<b>" + STR0006 + "</b>  " + RTrim(aPedidos[oBrowse:nAt,DATA_BAIRRO]) },oGroupInfo, , , , , , .T., , , 0,10, , , , , , .T.)
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid1:addInLayout(oSay, 1, 1,,,LAYOUT_ALIGN_VCENTER)
Aadd(oGroupInfo:aControls,oSay)
oSay := TSay():New( 0, 0, {|| "<b>" + STR0007 + "</b>  "+ RTrim(aPedidos[oBrowse:nAt,DATA_CIDADE]) },oGroupInfo, , , , , , .T., , , 0,10, , , , , , .T.)
oLayGrid1:addInLayout(oSay, 1, 2,,,LAYOUT_ALIGN_VCENTER)
Aadd(oGroupInfo:aControls,oSay)
oLayGrid0:addInLayout(oLayGrid1, 3, 1,,,LAYOUT_ALIGN_TOP)

// Terceira linha - Cidade, Estado e CEP
oLayGrid1 := TGridLayout():New(oGroupInfo, LAYOUT_LINEAR_L2R)
oSay := TSay():New( 0, 0, {|| "<b>" + STR0008 + "</b>  " + aPedidos[oBrowse:nAt,DATA_ESTADO] },oGroupInfo, , , , , , .T., , , 0,10, , , , , , .T.)
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid1:addInLayout(oSay, 1, 2,,,LAYOUT_ALIGN_VCENTER)
Aadd(oGroupInfo:aControls,oSay)
oSay := TSay():New( 0, 0, {|| "<b>" + STR0009 + "</b>  " + aPedidos[oBrowse:nAt,DATA_CEP] },oGroupInfo, , , , , , .T., , , 0,10, , , , , , .T.)
oLayGrid1:addInLayout(oSay, 1, 3,,,LAYOUT_ALIGN_VCENTER)
Aadd(oGroupInfo:aControls,oSay)
oLayGrid0:addInLayout(oLayGrid1, 4, 1,,,LAYOUT_ALIGN_TOP)

Return oGroupInfo

/*/-----------------------------------------------------------
{Protheus.doc} BrwPedChange()
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
@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function CriaBrwPdg(oOwner)
Local oPanel, oColumn , oGroupPDg , oSayPdg , oPanelAux
Local aCoors  := FWGetDialogSize( oMainWnd )

oPanel := TPanel():New(0,0,,oOwner,,.F.,,0,,170,aCoors[3]*0.17)
oPanel:Align := CONTROL_ALIGN_TOP

// Define o Browse
oBrowsePdg := FWBrowse():New(oPanel)
oBrowsePdg:SetDataArray(.T.)
//oBrowsePdg:SetArray(aAux)
oBrowsePdg:DisableConfig(.T.)
oBrowsePdg:DisableReport(.T.)
oBrowsePdg:DisableLocate(.T.)
oBrowsePdg:DisableFilter(.T.)

// Adiciona as colunas do Browse
oColumn := FWBrwColumn():New()
//oColumn:SetData({||IIF(!Empty(_aPedagios), _aPedagios[oBrowsePdg:nAt,1],)})
oColumn:SetData({|| _aPedagios[oBrowsePdg:nAt,1]})
oColumn:SetTitle( STR0010 ) // "Pedagio")
oColumn:SetSize(15)
oBrowsePdg:SetColumns({oColumn})

oColumn := FWBrwColumn():New()
oColumn:SetData({|| "R$ " +  Transform(_aPedagios[oBrowsePdg:nAt,2],"@E 999,999.99")} )  
oColumn:SetTitle( STR0011 ) //"Valor")
oColumn:SetSize(6)
oBrowsePdg:SetColumns({oColumn})

oColumn := FWBrwColumn():New()
oColumn:SetData({|| _aPedagios[oBrowsePdg:nAt,3] })
oColumn:SetTitle( STR0003 ) //Destino
oColumn:SetSize(TamSX3("A1_NREDUZ")[1])
oBrowsePdg:SetColumns({oColumn})


oBrowsePdg:SetArray(_aPedagios)

oBrowsePdg:Activate()

oPanelAux := TPanel():New(0,0,,oOwner,,.F.,,0,,170,15)
oPanelAux:Align := CONTROL_ALIGN_BOTTOM

oGroupPDg := TGroup():New(0,0,0,0,STR0010 ,oPanelAux,,,.F.) //-- pedagio
oGroupPDg:Align := CONTROL_ALIGN_BOTTOM

oSayPdg := TSay():New( 0, 0, {|| "<b>" + STR0012 + " R$ " + Transform(_nValPdg,"@E 999,999.99")  },oGroupPDg, , , , , , .T., , , 0,10, , , , , , .T.) //-- Valor total: 
oSayPdg:SetCSS("QLabel { padding-left: 8px; }")

Return oPanel


/*/-----------------------------------------------------------
{Protheus.doc} CriaInfoTrip()
@author Caio Murakami   
@since 01/07/2019
@params
 aRodape
 1 - Retorno para filial
 2 - Distancia
 3 - Paradas
 4 - Volume
 5 - Peso
 6 - Duracao
 7 - Viagem Extra
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function CriaInfoTrip(oOwner )
Local oLayGrid0
Local oSay 
Local oInfoTrip
Default oOwner		:= Nil 

// Cria o grupo de informações
oInfoTrip := TGroup():New(0,0,0,0,STR0022,oOwner,,,.T.) //- "Informações das rotas"
oInfoTrip:Align := CONTROL_ALIGN_ALLCLIENT

// Cria o layout principal
oLayGrid0 := TGridLayout():New(oInfoTrip,CONTROL_ALIGN_ALLCLIENT)

// Segunda linha - Distância
oSay := TSay():New( 0, 0, {|| "<b>" + STR0014+ "</b>  " + Transform(_aRodape[2], '@E 999,999.999') + " Km" },oInfoTrip, , , , , , .T., , , 0,10, , , , , , .T.)//Distancia total
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid0:addInLayout(oSay, 1, 1,,,LAYOUT_ALIGN_TOP)
Aadd(oInfoTrip:aControls,oSay)

oSay := TSay():New( 0, 0, {|| "<b>" + STR0015+ "</b>  " + cValToChar(_aRodape[3]) },oInfoTrip, , , , , , .T., , , 0,10, , , , , , .T.)//N de paradas
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid0:addInLayout(oSay, 1, 2,,,LAYOUT_ALIGN_TOP)
Aadd(oInfoTrip:aControls,oSay)

oSay := TSay():New( 0, 0, {|| "<b>" + STR0017+ "</b>  " + cValToChar(_aRodape[5]) + " Kg" },oInfoTrip, , , , , , .T., , , 0,10, , , , , , .T.)//Peso:
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid0:addInLayout(oSay, 1, 3,,,LAYOUT_ALIGN_TOP)
Aadd(oInfoTrip:aControls,oSay)

oSay := TSay():New( 0, 0, {|| "<b>" + STR0016+ "</b>  " +  Transform(_aRodape[4], '@E 999,999.999')  + " m³" },oInfoTrip, , , , , , .T., , , 0,10, , , , , , .T.) //Volume
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid0:addInLayout(oSay, 1, 4,,,LAYOUT_ALIGN_TOP)
Aadd(oInfoTrip:aControls,oSay)

oSay := TSay():New( 0, 0, {|| "<b>" + STR0024 + "</b>  " + cValToChar(_aRodape[6])  + "h" },oInfoTrip, , , , , , .T., , , 0,10, , , , , , .T.)//"Duração:"
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid0:addInLayout(oSay, 2, 1,,,LAYOUT_ALIGN_TOP)
Aadd(oInfoTrip:aControls,oSay)

oSay := TSay():New( 0, 0, {|| "<b>" + STR0025 + "</b>  " + cValToChar(_aRodape[1]) },oInfoTrip, , , , , , .T., , , 0,10, , , , , , .T.)//"Ret. Filial:"
oSay:SetCSS("QLabel { padding-left: 8px; }")
oLayGrid0:addInLayout(oSay, 2, 2,,,LAYOUT_ALIGN_TOP)
Aadd(oInfoTrip:aControls,oSay)

If !Empty(_aRodape[7])
	oSay := TSay():New( 0, 0, {|| "<b>" + STR0026 + "</b>  " + cValToChar(_aRodape[7])  },oInfoTrip, , , , , , .T., , , 0,10, , , , , , .T.)//"Viagem extra: "
	oSay:SetCSS("QLabel { padding-left: 8px; }")
	oLayGrid0:addInLayout(oSay, 2, 3,,,LAYOUT_ALIGN_TOP)
	Aadd(oInfoTrip:aControls,oSay)
EndIf

Return oInfoTrip


/*/-----------------------------------------------------------
{Protheus.doc} OMSATPRMap()
Busca a roteirizacao da carga
@author Equipe OMS
@since 25/09/2021
@version 1.0
@type function
-----------------------------------------------------------/*/
Function OMSATPRMap( cAlias, nRecno, nOpcx ) 
Local cQuery	:= "" 
Local cAliasQry	:= ""
Local aArea		:= GetArea() 
Local cFilRot	:= ""
Local cIdRot	:= ""
Local lRet		:= .T. 
Local nSeqRot   := Nil

	cAliasQry	:= GetNextAlias() 

	cQuery 	:= " SELECT DMS_FILROT, DMS_IDROT,DMS_SEQROT "
	cQuery	+= " FROM " + RetSQLName("DMS") + " DMS "
	cQuery	+= " WHERE DMS_FILIAL	= '" + xFilial("DMS") + "' "
	cQuery	+= " AND DMS_ENTEXT 	= 'DAK' "
	cQuery	+= " AND DMS_CHVEXT		= '" + RTrim( DAK->( DAK_FILIAL+DAK_COD ) ) + "' "
	cQuery	+= " AND DMS_STATUS		= '3' " //-- 3=Processado
	cQuery	+= " AND DMS.D_E_L_E_T_ = ' ' "
	
	OMSTPRCLOG(_llogTPR, "OMSATPR3", STR0033 + STR0035 + cQuery )  //"TOTVS Planejamento de Rotas(TPR) - OMSATPR3 - Query dos dados da DMS: "

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)), cAliasQry, .F., .T.)
	If !(cAliasQry)->(Eof()) 
		cFilRot	:= (cAliasQry)->DMS_FILROT
		cIdRot	:= (cAliasQry)->DMS_IDROT
		nSeqRot	:= (cAliasQry)->DMS_SEQROT
		(cAliasQry)->(dbSkip())
	EndIf

	(cAliasQry)->(dbCloseArea())
			
	//-- Exibe mapa
	If !Empty( cIdRot )
		OMSTPRRota(cFilRot, cIdRot, nSeqRot)
	Else
		lRet	:= .F. 
		Help(,,'HELP',,STR0021,1,0,) //"A carga não possui planejamento de rota."
	EndIf 

	RestArea( aArea )

Return lRet


/*/-----------------------------------------------------------
{Protheus.doc} OMSMiliseg()
Milisegundos em hora, minuto, segundos e o resto dos milisegundos =D
@author Equipe OMS
@since 28/09/2021
@version 1.0
@type function
-----------------------------------------------------------/*/
Function OMSMiliseg(nMiliseg, nType, nTamH, nTamM, nTamS)
	Local cSeg := 0
	Local cMin := 0
	Local cHora := 0
	Local cRetorno := ""
	Default nTamH := 4
	Default nTamM := 2
	Default nTamS := 2

	If nMiliseg >= 3600000
		cHora := Int(  nMiliseg / (1000*60*60))
	EndIf
	cHora := StrZero( cHora, nTamH) 
	If nMiliseg >= 60000
		cMin  := Int( Mod( nMiliseg / (1000*60), 60 ))
	EndIf
	cMin  := StrZero( cMin, nTamM)

	If nType = 0
		If nMiliseg >= 1000
			cSeg :=	Int( Mod( nMiliseg / 1000, 60 ))
		EndIf
		cSeg := StrZero( cSeg, nTamS)
		cRetorno := cHora + ":" + cMin + ":" + cSeg
	ElseIf nType = 1
		cRetorno := cHora + ":" + cMin
	EndIf

Return  cRetorno


/*/-----------------------------------------------------------
{Protheus.doc} OMSViagJso()
Busca o json da carga
@author Equipe OMS
@since 16/11/2021
@version 1.0
@type function
-----------------------------------------------------------/*/
Function OMSViagJso(cFilRot, cIdRot)
	Local cQuery 	:= ""
	Local cJson 	:= ""
	Local cAliasQry	:= GetNextAlias()

	cQuery	:= " SELECT R_E_C_N_O_ DLURECNO "
	cQuery	+= " FROM " + RetSQLName("DLU") +" DLU "
	cQuery	+= " WHERE DLU_FILIAL	=	'" + xFilial("DLU") + "' "
	cQuery	+= " AND DLU_ENTIDA		= 'DMR' "
	cQuery	+= " AND DLU_CHVENT		= '" + cFilRot + cIdRot + "' "
	cQuery	+= " AND DLU.D_E_L_E_T_ = ' ' "

	OMSTPRCLOG(_llogTPR, "OMSATPR3", STR0033 + STR0036 + cQuery ) //"TOTVS Planejamento de Rotas(TPR) - OMSATPR3 - Query dos dados da DLU"

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

	While (cAliasQry)->(!Eof())
		DLU->(DBGoTo(( cAliasQry)->DLURECNO ))
		cJson	:= RTrim( DLU->DLU_RETORN )
 		_nQtdten := DLU->DLU_QTDTEN 
		(cAliasQry)->( dbSkip() )
	EndDo 

	(cAliasQry)->(dbCloseArea())

Return cJson


/*/-----------------------------------------------------------
{Protheus.doc} OMSTPR3Dat()
Obtem os dados do json
@author Equipe OMS
@since 22/12/2021
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function OMSTPR3Dat(cJson, nSeqRot)
	Local oObj			:= JsonObject():New()
	Local nDist			:= 0 
	Local nStops		:= 0 
	Local nVolume		:= 0 
	Local nPeso			:= 0 
	Local nDuracao		:= 0 
	Local oObjRot 		:= JsonObject():New()
	Local oObjPdg 		:= JsonObject():New()
	Local oObjStp 		:= JsonObject():New()
	Local nCount		:= 1 
	Local nCountPdg		:= 1 
	Local nCountStp		:= 1 
	Local cRetFil 		:= .F.
	Local cViaExt 		:= Nil
	Local cDescDest 	:= ""
	Default nSeqRot     := Nil

	_aRodape := {}
	ASize( _aPedagios, 0 )
	_nValPdg := 0

	If !Empty(cJson) .And. oObj:FromJson( cJson ) <> "C"
		For nCount := 1 To Len( oObj["tripsResults"] )
			oObjRot := oObj["tripsResults"][nCount]

			If lAllSeqRot .Or. oObjRot["sequential"] =  nSeqRot
				//Os pedagios sao de todas as paradas
				If !Empty(oObjRot["tollValue"])
					_nValPdg += oObjRot["tollValue"]
				EndIf

				For nCountStp := 1 To Len( oObjRot["stops"] )
					oObjStp := oObjRot["stops"][nCountStp]
					If oObjStp["sequence"] = 0
						loop
					EndIf

					If !Empty(oObjStp["tollValues"])
						For nCountPdg := 1 To Len( oObjStp["tollValues"] )

							If oObjStp["type"]=="FAKE_STOP"
								Loop
							EndIf

							oObjPdg := oObjStp["tollValues"][nCountPdg]

							If !Empty(oObjStp["locality"]["name"])
								cDescDest := oObjStp["locality"]["name"]
							EndIf

							Aadd(_aPedagios,  { oObjPdg["name"], oObjPdg["value"],  cDescDest})
							_lPedagio := .T.
						Next nCountPdg 
					EndIf

				Next nCountStp 
			EndIf

			If lAllSeqRot
				
				If Empty(cRetFil) .Or. oObjRot["considerReturnDistance"] ==.T.
					cRetFil	:= IIF( oObjRot["considerReturnDistance"]==.T.,STR0028,STR0029) //Sim, Não
				EndIf

				nDist	:= oObj["summary"]["totalDistance"]
				nStops	:= oObj["summary"]["totalStops"]
				nVolume	:= oObj["summary"]["totalVolume"]
				nPeso	:= oObj["summary"]["totalWeight"]
				nDuracao:= OMSMiliseg( oObj["summary"]["totalDuration"], 0)
				If Empty(cViaExt) .Or. oObjRot["extraTrip"] ==.T.
					cViaExt	:= IIF( oObjRot["extraTrip"] == .T.,STR0028,STR0029) //Sim, Não
				EndIf
			ElseIf oObjRot["sequential"] =  nSeqRot

				nDist	:= oObjRot["distance"]  
				nStops	:= oObjRot["numberOfStops"]
				nVolume	:= oObjRot["volume"]
				nPeso	:= oObjRot["weight"]
				nDuracao := OMSMiliseg( oObjRot["duration"], 0)	
				cRetFil	:= IIF( oObjRot["considerReturnDistance"]==.T.,STR0028,STR0029) //Sim, Não
				cViaExt	:= IIF( oObjRot["extraTrip"] == .T.,STR0028,STR0029) //Sim, Não

				Exit
			EndIf
		Next nCount 
	EndIf

	Aadd(_aRodape, cRetFil)
	Aadd(_aRodape, nDist)
	Aadd(_aRodape, nStops)
	Aadd(_aRodape, nVolume)
	Aadd(_aRodape, nPeso)
	Aadd(_aRodape, nDuracao)
	Aadd(_aRodape, cViaExt)

Return


/*/-----------------------------------------------------------
{Protheus.doc} OMSUpdTPR3()
Atualiza as informacoes na tela
@author Equipe OMS
@since 23/05/2022
@version 1.0
@type function
-----------------------------------------------------------/*/
Function OMSUpdTPR3()
	Local lRet := .F.
	Local cJson := ""
	Local nQtdten := _nQtdten

	cJson := OMSViagJso( _cFilRot, _cIdRot)
	If nQtdten != _nQtdten
		OmsMsgTime(STR0032, 2) //"Atualizando as informações da rota..."
		lRet := LoadPedidos( _cFilRot, _cIdRot, _nSeqRot )
		OMSTPR3Dat(cJson, _nSeqRot)

		oBrowse:Refresh(.T.)
		If _lPedagio .Or. _lNovaRout
			oBrowsePdg:Refresh(.T.)
		EndIf
	EndIf

Return
