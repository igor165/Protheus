#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TMSAE45A.CH"

/*/{Protheus.doc} TMSAE45A
Painel Pré-Fatura

@type		function
@author  	Fabio M. Sampaio
@version 	P12
@since   	19/02/2019
@return  	Nil
/*/

Function TMSAE45A()
Local aStatus    := {}
Local aSizeDlg   := FwGetDialogSize(oMainWnd)
Local aButtons   := {}
Local nHeight    := aSizeDlg[3]
Local nWidth     := aSizeDlg[4]
Local nOpca      := 0
Local cAliasPFat := GetNextAlias()
Local cAliasDoc  := GetNextAlias()
Local cMarkBrw   := GetMark()
Local aSeek		 := {} 
Local aIndex	 := {} 
Local aColunas   := {}
Local nlin 		 := 0
Local nCol 		 := 0
Local cPerg      := "TME45A"
Local lPergunte	 := .F.

//-- Variaveis da tela
Local oDlgConsult
Local oFWLayer
Local oColumn                                       

Local oPanelUp,   oPnlBrwUp,  oPnlButUp
Local oPanelDown, oPnlBrwDwn, oPnlButDwn

Local aButTop  := {}
Local aButDown := {}

Local oBrwPFat 
Local oBrwDoc 


//-- Blocos da tela
//-- Botão "OK" da tela
Local bBtOk := {|| 	nOpca:= 1,	oDlgConsult:End() }
//-- Botão "Cancel" da tela
Local bBtCancel := {|| oDlgConsult:End() }

//-- Marcação de uma Pré-Fatura
Local bMarkPFat	:= {||  RecLock(cAliasPFat,.F.), ;
						Iif( (cAliasPFat)->DEB_OK==cMarkBrw, ;
							 (cAliasPFat)->DEB_OK := "",;
							 (cAliasPFat)->DEB_OK := cMarkBrw;
							),;
						MsUnlock(),; 
						Eval(bMrkAllDoc,.T. /*lForce*/)}

//-- Marcação de um Documento
Local bMarkDoc	 := {|| ME45AMDoc(cAliasDoc,oTbMark,cMarkBrw,oBrwPFat,.F.)}

//-- Marcação de todos Documentos
Local bMrkAllDoc := {|lForce| Iif( (ValType(lForce) <> "L" .Or. !lForce) .And. Empty((cAliasPFat)->DEB_OK),;
							 		Nil,;
									( (cAliasDoc)->(DbGoTop()), ;
									  (cAliasDoc)->(DbEval({|| ME45AMDoc(cAliasDoc,oTbMark,cMarkBrw,oBrwPFat,.T.)}/*bMarkDoc*/)),;
									  (cAliasDoc)->(DbGoTop()),;															 
									  oBrwDoc:Refresh(),;
									  oBrwDoc:Gotop();
									);
									) }

Local bRefresh := {|lAll|	Iif( lAll == Nil .Or. lAll,;
								 (TMA45ACpo(@aColunas,1),;
								  TMA45AFil(oTbMark,.T.,oBrwPFat,aColunas,1,,cMarkBrw);
								 ),;
								 Nil;
								),;
						TMA45ACpo(@aColunas,2),;
						TMA45AFil(oTbMark,.T.,oBrwDoc,aColunas,2,oBrwPFat,cMarkBrw) }

//-- Array para teclas de atalho
Local aSetKey 	:= {}

Local arrayPfat := {}

//-- Variáveis para Temporário com doctos marcados
Local aCampos,oTbMark

//-- Variaveis Private
Private cCadastro := STR0001 
Private aRotina   := StaticCall( TMSAE45, MenuDef )

//-- Cria tabela temporária para documentos desmarcados
aCampos:= {}
Aadd(aCampos,{"TRB_FILDOC","C",TamSX3("DT6_FILDOC")[1],0})
Aadd(aCampos,{"TRB_DOC"   ,"C",TamSX3("DEB_DOC")[1]   ,0})
Aadd(aCampos,{"TRB_SERIE" ,"C",TamSX3("DEB_SERIE")[1] ,0})

oTbMark := FWTemporaryTable():New(GetNextAlias())
oTbMark:SetFields(aCampos)
oTbMark:AddIndex("01",{"TRB_FILDOC","TRB_DOC","TRB_SERIE"})
oTbMark:Create()

//-- Teclas de Atalho
AAdd(aSetKey, { 15 ,  bBtOk     } ) //-- "OK" - Ctrl + O
AAdd(aSetKey, { 24 ,  bBtCancel } ) //-- "Cancel" - Ctrl + X
AAdd(aSetKey, { VK_F12 , { || Pergunte('TME45A',.T.,,,,.T.)} } )

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

lPergunte := Pergunte(cPerg,.T.)

If lPergunte
	DEFINE MSDIALOG oDlgConsult FROM 0,0 TO nHeight, nWidth TITLE cCadastro PIXEL of oMainWnd
	
		/////////////////////////////////////////////////////////////////////////////////
		//                              Monta objeto FWLayer                           //
		/////////////////////////////////////////////////////////////////////////////////
		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDlgConsult,.F.)
	
	    oFWLayer:AddLine("LinPFat",45,.F.)
	    oFWLayer:addCollumn("ColPFat",100,.F.,"LinPFat")
	    oFWLayer:addWindow("ColPFat","JanPFat",STR0014,100,.T.,.T.,{|| },"LinPFat")  //-- "Pré-Fatura"
	    oPanelUp := oFWLayer:GetWinPanel("ColPFat",'JanPFat',"LinPFat")
	
		//-- Divide o Layer superior para Browse e botões
		nAltBut := 12
		nLarg := oPanelUp:nWidth  * 0.5
		nAlt  := oPanelUp:nHeight * 0.5 
		@ 0             ,0 MSPANEL oPnlBrwUp SIZE nLarg,nAlt +12 - nAltBut  OF oPanelUp
		@ nAlt-nAltBut+1,0 MSPANEL oPnlButUp SIZE nLarg,nAltBut-1           OF oPanelUp

	    oFWLayer:AddLine("LinDoc",45,.F.)
	    oFWLayer:addCollumn("ColDoc",100,.F.,"LinDoc")
	    oFWLayer:addWindow("ColDoc","JanDoc",STR0015,100,.T.,.T.,{|| },"LinDoc")  //-- "Documentos"
	    oPanelDown := oFWLayer:GetWinPanel("ColDoc",'JanDoc',"LinDoc")
		
		//-- Divide o Layer inferior para Browse e botões
		nAltBut := 12
		nLarg := oPanelDown:nWidth  * 0.5
		nAlt  := oPanelDown:nHeight * 0.5 
		@ 0             ,0 MSPANEL oPnlBrwDwn SIZE nLarg,nAlt +12 - nAltBut  OF oPanelDown
		@ nAlt-nAltBut+1,0 MSPANEL oPnlButDwn SIZE nLarg,nAltBut-1           OF oPanelDown

		/////////////////////////////////////////////////////////////////////////////////
		//                         Monta Janela                                        //
		/////////////////////////////////////////////////////////////////////////////////
	
	
		//-------------------------------------------------------------------
		// Define o Browse da Pré-Fatura
		//-------------------------------------------------------------------
		TMA45ACpo(@aColunas,1)
		cQuery := TMA45AFil(oTbMark,.F.,oBrwPFat,aColunas,1,,cMarkBrw)
	
		Aadd( aIndex, "DEB_NUMPRE" )
		Aadd( aSeek, { allTrim(RetTitle("DEB_NUMPRE"))		, {{"","C",TamSX3("DEB_NUMPRE")[1],0, AllTrim(RetTitle("DEB_NUMPRE"))			,,}} } )
	
		DEFINE FWBROWSE oBrwPFat DATA QUERY ALIAS cAliasPFat QUERY cQuery FILTER SEEK ORDER aSeek INDEXQUERY aIndex NO REPORT OF oPnlBrwUp
		oBrwPFat:oOwner:nBottom -= 30

		//-- Botões superiores (Pré-Fatura)
		nlin := 0
		nCol := nLarg - (5*40) - 20

		@ nlin,nCol BUTTON oButtonFil PROMPT STR0016 SIZE 035, 010 OF oPnlButUp PIXEL ; //-- 'Legenda'
					ACTION ( Eval({|| A45Legenda(1)} ) )
		nCol += 040
		@ nlin,nCol BUTTON oButtonFil PROMPT STR0017 SIZE 035, 010 OF oPnlButUp PIXEL ; //-- 'Transf.Docto.'
					ACTION ( Eval({|| AE45Transf(oTbMark,oBrwPFat)} ) ;
						    ,Eval(bRefresh))
		nCol += 040
		@ nlin,nCol BUTTON oButtonFil PROMPT STR0018 SIZE 035, 010 OF oPnlButUp PIXEL ; //-- 'Vis. Fat.'
					ACTION Eval({|| SaveInter(), Iif( Type("aRotina") == "A", aRotOld := aClone(aRotina), aRotOld := {}), ;
									aRotina := StaticCall(TMSA850,MenuDef ), INCLUI := .F., ALTERA := .F., ;
									Tmsae45Doc(, @arrayPFat, , .T., oBrwPFat:Alias()),;
									Tmsae45Vis( arrayPfat), aSize(arrayPFat,0),;
									RestInter(), aRotina := aClone(aRotOld), aSize(aRotOld,0) }) 
		nCol += 040
		@ nlin,nCol BUTTON oButtonFil PROMPT STR0019 SIZE 035, 010 OF oPnlButUp PIXEL ; //-- 'Gera Fatura'
					ACTION ( Eval({|| SaveInter(), Iif( Type("aRotina") == "A", aRotOld := aClone(aRotina), aRotOld := {}), ;
									  Tmsae45Doc(oBrwPFat:oData:oTempDb:GetRealName(), @arrayPFat,oTbMark:GetRealName(),.F.),;
									  Tmsae45Prc( arrayPfat, 1, oTbMark:GetRealName()), arrayPFat := {},;
									  RestInter(), aRotina := aClone(aRotOld), aSize(aRotOld,0)} ) ;
						    ,Eval(bRefresh))
		nCol += 040
		@ nlin,nCol BUTTON oButtonFil PROMPT STR0020 SIZE 035, 010 OF oPnlButUp PIXEL ; //-- 'Exc. Fatura.'
					ACTION ( Eval({|| SaveInter(), Iif( Type("aRotina") == "A", aRotOld := aClone(aRotina), aRotOld := {}), ;
									  Tmsae45Doc(oBrwPFat:oData:oTempDb:GetRealName(), @arrayPFat,oTbMark:GetRealName(),.T.),;
									  Tmsae45Prc( arrayPfat, 2, oTbMark:GetRealName()), arrayPFat := {},;
									  RestInter(), aRotina := aClone(aRotOld), aSize(aRotOld,0)} ) ;
						    ,Eval(bRefresh))
		nCol += 040
	
	    //-- Double Click em qualquer coluna da Linha
	    oBrwPFat:bLDblClick := bMarkPFat
	
	    //-- Double Click Header e coluna de marcação
	    oBrwPFat:AddMarkColumns ( {|| Iif(DEB_OK==cMarkBrw,'LBOK','LBNO')},;
	                            bMarkPFat /* bLDblClick*/,;
	                            Nil /*bHeaderClick*/ )
							  
		oBrwPFat:SetColumns(aColunas[1])
		oBrwPFat:SetFieldFilter(aColunas[3])
	    oBrwPFat:SetChange( {||TMA45ACpo(@aColunas,2), TMA45AFil(oTbMark,.T.,oBrwDoc,aColunas,2,oBrwPFat,cMarkBrw) } )
	
		//-------------------------------------------------------------------
		// Define o Browse de Documentos
		//-------------------------------------------------------------------
		TMA45ACpo(@aColunas,2)
		cQuery := TMA45AFil(oTbMark,.F.,oBrwDoc,aColunas,2,oBrwPFat,cMarkBrw)
	
		DEFINE FWBROWSE oBrwDoc DATA QUERY ALIAS cAliasDoc QUERY cQuery NO REPORT OF oPnlBrwDwn
		oBrwDoc:oOwner:nBottom -= 30
		
		//-- Botões inferiores (Documentos)
		nlin := 0
		nCol := nLarg - (6*40) - 20
		@ nlin,nCol BUTTON oButtonFil PROMPT STR0016 SIZE 035, 010 OF oPnlButDwn PIXEL ; //-- 'Legenda'
					ACTION ( Eval({|| A45Legenda(2)} ) )
		nCol += 040
		@ nlin,nCol BUTTON oButtonFil PROMPT STR0021 SIZE 035, 010 OF oPnlButDwn PIXEL ; //-- 'Vis. Pré-Fat.'
		            ACTION Eval({|| INCLUI:=.F.,ALTERA:=.F.,;
									Posicione("DEB",4,xFilial("DEB") + (cAliasPFat)->(DEB_CGCDEV + DEB_NUMPRE)+ (cAliasDoc)->(DEB_FILDOC+ DEB_DOC+ DEB_SERIE),"DEB_DOC"),;
									TMSE45Mnt("DEB",DEB->(Recno()),2)} )
		nCol += 040
		@ nlin,nCol BUTTON oButtonFil PROMPT STR0022 SIZE 035, 010 OF oPnlButDwn PIXEL ; //-- 'Inc. Pré-Fat.'
					ACTION ( Eval({|| INCLUI:=.T., ALTERA:=.F., TMSE45Mnt("DEB",0,3)} ) ;
						    ,Eval(bRefresh))
		nCol += 040
		@ nlin,nCol BUTTON oButtonFil PROMPT STR0023 SIZE 035, 010 OF oPnlButDwn PIXEL ; //-- 'Alt. Pré-Fat.'
					ACTION ( Eval({|| INCLUI:=.F., ALTERA:=.T.,;
									  Posicione("DEB",4,xFilial("DEB") + (cAliasPFat)->(DEB_CGCDEV + DEB_NUMPRE)+ (cAliasDoc)->(DEB_FILDOC+ DEB_DOC+ DEB_SERIE),"DEB_DOC"),;
									  TMSE45Mnt("DEB",DEB->(Recno()),4)} ) ;
							,Eval(bRefresh,.F.))
		nCol += 040
		@ nlin,nCol BUTTON oButtonFil PROMPT STR0024 SIZE 035, 010 OF oPnlButDwn PIXEL ; //-- 'Exc. Pré-Fat.'
					ACTION ( Eval({|| INCLUI:=.F., ALTERA:=.F.,;
									  Posicione("DEB",4,xFilial("DEB") + (cAliasPFat)->(DEB_CGCDEV + DEB_NUMPRE)+ (cAliasDoc)->(DEB_FILDOC+ DEB_DOC+ DEB_SERIE),"DEB_DOC"),;
									  TMSE45Mnt("DEB",DEB->(Recno()),5)} ) ;
						    ,Eval(bRefresh,.F.))
		nCol += 040
		@ nlin,nCol BUTTON oButtonFil PROMPT STR0025 SIZE 035, 010 OF oPnlButDwn PIXEL ; //-- 'Vis. Doc.'
					ACTION Eval({|| SaveInter(), Iif( Type("aRotina") == "A", aRotOld := aClone(aRotina), aRotOld := {}), ;
									aRotina := StaticCall(TMSA500,MenuDef ), INCLUI := .F., ALTERA := .F., ;
									(cAliasDoc)->(TMSViewDoc(DEB_FILDOC, DEB_DOC, DEB_SERIE)),;
									RestInter(), aRotina := aClone(aRotOld), aSize(aRotOld,0) }) 
		nCol += 040

	    //-- Double Click em qualquer coluna da Linha
	    oBrwDoc:bLDblClick := bMarkDoc
	
	    //-- Double Click Header e coluna de marcação
	    oBrwDoc:AddMarkColumns ( {|| Iif(AllTrim((cAliasDoc)->DEB_OK) == AllTrim(cMarkBrw),'LBOK','LBNO')},; 
	                            bMarkDoc /* bLDblClick*/,;
	                            bMrkAllDoc /*bHeaderClick*/ )

		oBrwDoc:SetColumns(aColunas[1])
		
		ACTIVATE FWBROWSE oBrwPFat
		ACTIVATE FWBROWSE oBrwDoc

		ACTIVATE MSDIALOG oDlgConsult ON INIT EnchoiceBar( oDlgConsult,bBtOk,bBtCancel,, aButtons )
	
	//-- Finaliza Teclas de Atalhos
	TmsKeyOff(aSetKey)

EndIf
	
//-- Exclui tabela temporária dos doctos desmarcados
oTbMark:Delete()

Return nOpcA


/*/{Protheus.doc} TMA45AFil
Retorna a query e reconstrói dados no(s) Browse(s)
@type		function
@return		cQuery
@author  	Fabio M Sampaio
@version 	P12
@since   	19/02/2019
@return  	Nil
/*/
Static Function TMA45AFil(oTbMark,lRefazObj,oBrw,aColunas,nBrowse,oBrwOwner,cMark)
Local cAliasObj
Local nSpaceMrk		:= Len(cMark)
Local lDEBFilDoc	:= DEB->(FieldPos("DEB_FILDOC")) > 0
Local lDEBCGCDev	:= DEB->(FieldPos("DEB_CGCDEV")) > 0
Local cDT6NumVaz	:= Space(TamSX3("DT6_NUM")[1])
Local cFILDOCVaz	:= Space(TamSX3("DT6_FILDOC")[1])
Local cGroup		:= ""

DEFAULT lRefazObj	:= .F.
DEFAULT oBrwOwner	:= Nil

CursorWait()

//-- Monta a Query
If nBrowse == 1
	Pergunte("TME45A", .F.)
    cQuery := " SELECT '"+Space(nSpaceMrk)+"' DEB_OK, DEB_NUMPRE, DEB_CGCDEV"
	cQuery += "       , SUM(DEB_VALOR)                                                    DEB_VALOR  "
	cQuery += "       , SUM(COALESCE(DT6.DT6_VALTOT,0))                                   DT6_VALTOT "
	cQuery += "       , SUM(COALESCE(DT6.DT6_VALFAT,0))                                   DT6_VALFAT "
    cQuery += "       , COUNT(DEB_DOC)                                                    NDOCPFAT   " //-- Coluna apenas para Status
    cQuery += "       , SUM(CASE WHEN COALESCE(DT6.DT6_NUM,'" + cDT6NumVaz + "') > '" + cDT6NumVaz + "' THEN 1 ELSE 0 END)  NDOCFAT    " //-- Coluna apenas para Status
    cQuery += " FROM "  + RetSqlName("DEB") + " DEB " 
    cQuery += " LEFT JOIN " + RetSqlName("DT6") + " DT6  "
	cQuery += "    ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "'" 
	cQuery += "   AND DT6.DT6_FILDOC = DEB.DEB_FILDOC "
	cQuery += "   AND DT6.DT6_DOC    = DEB.DEB_DOC "
	cQuery += "   AND DT6.DT6_SERIE  = DEB.DEB_SERIE "
	cQuery += "   AND DT6.D_E_L_E_T_ = ' '"   
    cQuery += " WHERE DEB.D_E_L_E_T_ = ' ' "
    cQuery += " AND DEB.DEB_FILIAL = '" + xFilial("DEB") + "' "
	If !Empty(MV_PAR01)
    	cQuery += " AND DEB.DEB_CGCDEV = '" + (MV_PAR01) + "' "  
	EndIf
    cQuery += " AND DEB.DEB_DATVEN BETWEEN '" + dtos(MV_PAR02) + "' AND '" + dtos(MV_PAR03) + "' "
	
	cGroup := " GROUP BY DEB_NUMPRE, DEB_CGCDEV "
	//-- Limpa os documentos marcados quando reconstroi o Browse de Pré-Fatura
	A45ClearMK(oTbMark:GetRealName())
ElseIf nBrowse == 2
	If "POSTGRES" $ AllTrim(Upper(TCGetDB())) 
    	cQuery := " SELECT  CAST( (CASE WHEN COALESCE(MRK.TRB_FILDOC,'"+cFILDOCVaz+"') > '"+cFILDOCVaz+"' THEN '"+cMark+"' ELSE '"+Space(nSpaceMrk)+"' END) AS VARCHAR("+Str(nSpaceMrk)+")) DEB_OK, " 
	Else
    	cQuery := " SELECT  CASE WHEN COALESCE(MRK.TRB_FILDOC,'"+cFILDOCVaz+"') > '"+cFILDOCVaz+"' THEN '"+cMark+"' ELSE '"+Space(nSpaceMrk)+ "' END DEB_OK, " 
	EndIf

	cQuery += " DEB.DEB_NUMPRE, "
	cQuery += " DEB.DEB_FILDOC, "
	cQuery += " DEB.DEB_DOC, "
	cQuery += " DEB.DEB_SERIE, "
	cQuery += " COALESCE(DT6.DT6_VALTOT, 0 ) DT6_VALTOT, "
	cQuery += " DEB.DEB_VALOR, "
	cQuery += " COALESCE(DT6.DT6_VALFAT, 0 ) DT6_VALFAT, "
	If "POSTGRES" $ AllTrim(Upper(TCGetDB()))  
		cQuery += " CAST(COALESCE(DT6.DT6_PREFIX,'"+Space(TamSX3("DT6_PREFIX")[1])+"') AS VARCHAR("+Str(TamSX3("DT6_PREFIX")[1])+") ) DT6_PREFIX, "
		cQuery += " CAST(COALESCE(DT6.DT6_NUM   ,'"+Space(TamSX3("DT6_NUM"   )[1])+"') AS VARCHAR("+Str(TamSX3("DT6_NUM"   )[1])+") ) DT6_NUM, "
		cQuery += " CAST(COALESCE(DT6.DT6_TIPO  ,'"+Space(TamSX3("DT6_TIPO"  )[1])+"') AS VARCHAR("+Str(TamSX3("DT6_TIPO"  )[1])+") ) DT6_TIPO "
	Else
		cQuery += " COALESCE(DT6.DT6_PREFIX,' ') DT6_PREFIX, "
		cQuery += " COALESCE(DT6.DT6_NUM   ,' ') DT6_NUM, "
		cQuery += " COALESCE(DT6.DT6_TIPO  ,' ') DT6_TIPO "
	EndIf
    cQuery += " FROM "  + RetSqlName("DEB") + " DEB " 
    cQuery += " LEFT JOIN " + oTbMark:GetRealName() + " MRK  "
	cQuery += "    ON MRK.TRB_FILDOC = DEB.DEB_FILDOC "
	cQuery += "   AND MRK.TRB_DOC    = DEB.DEB_DOC "
	cQuery += "   AND MRK.TRB_SERIE  = DEB.DEB_SERIE "
    cQuery += " LEFT JOIN " + RetSqlName("DT6") + " DT6  "
	cQuery += "    ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "'" 
	cQuery += "   AND DT6.DT6_FILDOC = DEB.DEB_FILDOC "
	cQuery += "   AND DT6.DT6_DOC    = DEB.DEB_DOC "
	cQuery += "   AND DT6.DT6_SERIE  = DEB.DEB_SERIE "
	cQuery += "   AND DT6.D_E_L_E_T_ = ' '"   
    cQuery += " WHERE DEB.D_E_L_E_T_ = ' '" 
    cQuery += " AND DEB.DEB_FILIAL = '" + xFilial("DEB") + "' "
    cQuery += "   AND DEB.DEB_CGCDEV = '" + (oBrwOwner:Alias())->DEB_CGCDEV + "' "  
    cQuery += "   AND DEB.DEB_NUMPRE = '" + (oBrwOwner:Alias())->DEB_NUMPRE + "'"

EndIf

// Ponto de entrada para realização de filtros.
If ExistBlock("TM45AQRY")
    cQuery := ExecBlock("TM45AQRY", .F., .F., { nBrowse, cQuery } )
EndIf

cQuery := ChangeQuery( cQuery + cGroup )

If lRefazObj
	CursorWait()
	cAliasObj := oBrw:Alias()
	(cAliasObj)->(DbCloseArea())
	oBrw:SetAlias(cAliasObj)
	oBrw:SetQuery( cQuery )
	oBrw:oData:DeActivate(.T.)
	oBrw:oData:Activate() 
	oBrw:Refresh() //NÃO RETIRAR ESSA LINHA DEVIDO A ERRO DE FRAMEWORK
	oBrw:GoTop()   //NÃO RETIRAR ESSA LINHA DEVIDO A ERRO DE FRAMEWORK
	CursorArrow()
EndIf

CursorArrow()

Return cQuery

/*/{Protheus.doc} TMA45ACpo
Função para montar os campos da consulta
@type		function
@return		cQuery
@author  	Fabio M. Sampaio
@version 	P12
@since   	19/02/2019
@return  	Nil
/*/
Static Function TMA45ACpo(aColunas,nBrowse)
Local aCpos    := {}
Local nCntFor1

If nBrowse == 1
    //-- Por ter "Group By" na query, tem que alterar a select para os campos
    aAdd(aCpos,{"LEGENDA"   ,"TMA45AStPF(.T.)", ""})
    aAdd(aCpos,{"DEB_NUMPRE","TMA45AStPF(.F.)", STR0026}) //-- "Status"
    aAdd(aCpos,{"DEB_NUMPRE"})
    aAdd(aCpos,{"DEB_NOMREM","Posicione('SA1',3,xFilial('SA1')+DEB_CGCDEV,'A1_NREDUZ')", STR0027}) //-- "Cliente Dev."
    aAdd(aCpos,{"DT6_VALTOT",, STR0028 }) //-- "Valor TMS"
    aAdd(aCpos,{"DEB_VALOR" ,, STR0029 }) //-- "Valor Pré-Fatura" 
    aAdd(aCpos,{"DT6_VALFAT",, STR0030 }) //-- "Valor Faturado" 

ElseIf nBrowse == 2
    aAdd(aCpos,{"LEGENDA"   ,"TMA45AStDC(.T.)", ""})
    aAdd(aCpos,{"DEB_NUMPRE","TMA45AStDC(.F.)", STR0026}) //-- "Status"
    aAdd(aCpos,{"DEB_FILDOC"}) 
    aAdd(aCpos,{"DEB_DOC"   }) 
    aAdd(aCpos,{"DEB_SERIE" })
    aAdd(aCpos,{"DT6_VALTOT",, STR0028 }) //-- "Valor TMS"
    aAdd(aCpos,{"DEB_VALOR" ,, STR0029 }) //-- "Valor Pré-Fatura"
    aAdd(aCpos,{"DT6_VALFAT",, STR0030 }) //-- "Valor Faturado" 
    aAdd(aCpos,{"DT6_PREFIX"})
    aAdd(aCpos,{"DT6_NUM"   })
    aAdd(aCpos,{"DT6_TIPO"  })
EndIf
aColunas := fColumns(aCpos)

Return

/*/{Protheus.doc} fColumns
Retorna um array, onde a primeira posicao é um vetor de objetos da classe
FWBrwColumn, esses serao responsaveis pelos campos exibidos no mBrowse.
Já a segunda posicao, retorna os campos que serao retornados na query. (from LJSUBNFE.PRW)
@type		function
@return		aRet [1] array com os campos do mBrowse [2] string com os campos que serao retornados na query
@author  	Varejo
@version 	P12
@since   	05/12/2016
@return  	Nil
/*/
Static Function fColumns(aCpos)

Local cColumns	:= ""
Local aRet 		:= {}
Local aColumns	:= {}
Local aArea		:= GetArea()
Local nI
Local aCamposFil := {}
Local aDadosCpo  := {}
Local cCBox	   := ""

For nI := 1 To Len(aCpos)
	cX3Campo := aCpos[nI][1]
	cCBox    := GetSX3Cache(cX3Campo,"X3_CBOX")
	aDadosCpo:= TamSX3(cX3Campo)
	//cria uma instancia da classe FWBrwColum
	Aadd( aColumns, FWBrwColumn():New() )

	If ( aCpos[nI][1] == 'LEGENDA' )
		Atail(aColumns):SetPicture("@BMP")
		Atail(aColumns):SetImage(.T.)      
		Atail(aColumns):SetTitle(" ")
	EndIf

	If Len(aCpos[nI]) >= 2 .And. !Empty(aCpos[nI][2])
		Atail(aColumns):SetData( &("{||" + aCpos[nI][2] + "}") )
	Else
		cColumns += (cX3Campo +",")
		Aadd(aCamposFil, {cX3Campo, FWX3Titulo(cX3Campo), aDadosCpo[3], aDadosCpo[1], aDadosCpo[2], X3Picture(cX3Campo) })
			If aDadosCpo[3] == "D"
			Atail(aColumns):SetData( &("{||StoD(" + cX3Campo + ")}") )
		Else
			Atail(aColumns):SetData( &("{||" + cX3Campo + "}") )
		EndIf
	EndIf 

	If ( aCpos[nI][1] != 'LEGENDA' )
		If !Empty(cCBox) .And. "#" $ cCBox
			Atail(aColumns):SetOptions(StrToKArr(&(StrTran(cCBox,"#","")),";"))
		ElseIf !Empty(cCBox) 
			Atail(aColumns):SetOptions(StrToKArr(cCBox,";"))
		EndIf
		Atail(aColumns):SetSize( Max(Int(aDadosCpo[1]/8),5) ) // Tamanho da coluna não é o tamanho do campo
		Atail(aColumns):SetDecimal( aDadosCpo[2] )
		If Len(aCpos[nI]) >= 3 .And. !Empty(aCpos[nI][3])
			Atail(aColumns):SetTitle( aCpos[nI][3])		
		Else
			Atail(aColumns):SetTitle( FWX3Titulo(cX3Campo))
		EndIf
		Atail(aColumns):SetPicture( X3Picture(cX3Campo) )
		If aDadosCpo[3] == "N"
		
			Atail(aColumns):SetAlign( CONTROL_ALIGN_RIGHT )
		Else
			Atail(aColumns):SetAlign( CONTROL_ALIGN_LEFT )
		EndIf
	EndIf
End	

RestArea(aArea)

//retira a ultima virgula dos campos da query
cColumns := Substr(cColumns, 1, Len(cColumns)-1)

Aadd(aRet, Aclone(aColumns) )	//campos presentes na mBrowse (cada campo é um objeto da classe FWBrwColumn)
Aadd(aRet, cColumns )			//campos que serao retornados na query
Aadd(aRet, aCamposFil )			//campos que serao Utilizados no filtro

//destroi o aColumns
aSize( aColumns,0 )
aColumns := Nil

Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsae45Prc
@autor		: Valdemar Roberto
@descricao	: Chama a geração de faturas na rotina de Painel da Pré Fatura
@since		: 18/02/2019
@using		: TMSAE45A
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsae45Prc(aVetPre,nAcao,cArqMrk)
Local cAliasTrb  := ""
Local cAliasDEB  := ""
Local cAliasSE1  := ""
Local cQuery     := ""
Local cCGCDev    := ""
Local cCliDev    := ""
Local cLojDev    := ""
Local cNumPre    := ""
Local cPrefix    := ""
Local cNum       := ""
Local cTipo      := ""
Local aAreas     := {SA1->(GetArea()),SE1->(GetArea()),GetArea()}
Local aCampos    := {}
Local aMsgErr    := {}
Local nLenErr    := 0
Local nCntFor1   := 0
Local oTempTable
Local lPerg		 := .F.
Local aPerfil
Local lContinua
Local lPrintFt

Private aPreFat  := {}

Default aVetPre := {}
Default nAcao   := 0
Default cArqMrk := ""

Pergunte("TME45A", .F.)
lPrintFt := MV_PAR04 == 1

Aadd(aCampos,{"TRB_CLIDEV","C",TamSX3("DT6_CLIDEV")[1],0})
Aadd(aCampos,{"TRB_LOJDEV","C",TamSX3("DT6_LOJDEV")[1],0})
Aadd(aCampos,{"TRB_NUMPRE","C",TamSX3("DEB_NUMPRE")[1],0})
Aadd(aCampos,{"TRB_FILDOC","C",TamSX3("DT6_FILDOC")[1],0})
Aadd(aCampos,{"TRB_DOC"   ,"C",TamSX3("DEB_DOC")[1]   ,0})
Aadd(aCampos,{"TRB_SERIE" ,"C",TamSX3("DEB_SERIE")[1] ,0})
Aadd(aCampos,{"TRB_DATVEN","C",TamSX3("DEB_DATVEN")[1] ,0})


For nCntFor1 := 1 To Len(aVetPre)
	//-- Busca dados básicos para localização da pré fatura
	cCGCDev := aVetPre[nCntFor1,1]
	SA1->(DbSetOrder(3))
	If SA1->(DbSeek(xFilial("SA1") + cCGCDev))
		cCliDev := SA1->A1_COD
		cLojDev := SA1->A1_LOJA
	EndIf
	cNumPre := aVetPre[nCntFor1,2]

	//-- Chama a geração da fatura
	If nAcao == 1	//-- Gera fatura
		If A491PreVld()
			//-- Cria tabela temporária para uso na query do TMSA850
			cAliasTrb  := GetNextAlias()
			oTempTable := FWTemporaryTable():New(cAliasTrb)
			oTempTable:SetFields(aCampos)
			oTempTable:AddIndex("01",{"TRB_CLIDEV","TRB_LOJDEV","TRB_NUMPRE","TRB_FILDOC","TRB_DOC","TRB_SERIE"})
			oTempTable:Create()

			//-- Valida registros da pré fatura
			lContinua := TMSAE45VlP(cCliDev, cLojDev, cCGCDev, cNumPre, cArqMrk, @aMsgErr)

			// -- Valida se tem condição de pagamento cadastrado no SA1
			If lContinua
				lContinua := TMAE45Cond(cCliDev, cLojDev, @aMsgErr)
			EndIf

			//-- Grava tabela temporária
			If lContinua
				cQuery := "INSERT INTO  " + oTempTable:GetRealName() + " (TRB_CLIDEV, TRB_LOJDEV, TRB_NUMPRE, TRB_FILDOC, TRB_DOC, TRB_SERIE, TRB_DATVEN) "
				cQuery += "            (SELECT '" + cCliDev + "', '" + cLojDev + "', DEB_NUMPRE, DEB_FILDOC, DEB_DOC, DEB_SERIE, DEB_DATVEN "
				cQuery += "               FROM " + RetSqlName("DEB") + " DEB "
				If !Empty(cArqMrk)
					cQuery += "				  JOIN " + cArqMrk + " MRK "
					cQuery += " 			    ON MRK.TRB_FILDOC = DEB.DEB_FILDOC "	
					cQuery += "				   AND MRK.TRB_DOC    = DEB.DEB_DOC "
					cQuery += "   			   AND MRK.TRB_SERIE  = DEB.DEB_SERIE "	
				EndIf		
				cQuery += "              WHERE DEB_FILIAL = '" + xFilial("DEB") + "' "
				cQuery += "                AND DEB_CGCDEV = '" + cCgcDev + "' "
				cQuery += "                AND DEB_NUMPRE = '" + cNumPre + "' "
				cQuery += "                AND DEB.D_E_L_E_T_ = ' ')"
				TCSqlExec(cQuery)

				nLenErr := Len(aMsgErr) //-- Salva a qtde de msg de erro (Pré-Faturas anteriores podem ter dado erro.. )
				If Tmsa850Aut("SE1",0,3,oTempTable,cCliDev,cLojDev,cNumPre,aVetPre[nCntFor1,6],aVetPre[nCntFor1,7], @aMsgErr)

					//-- Verica se a pré-fatura atual gerou novos erros
					lContinua := nLenErr == Len(aMsgErr)

					//-- Conta os documentos marcados que estão faturados - se houver diferença, lista.
					aPerfil := TmsPerfil(cCliDev,cLojDev,,.F.)
					If !Empty(cArqMrk) .And. lContinua
						If Len(aPerfil) >= 61 .And. ValType(aPerfil[61]) == "A" .And. Len(aPerfil[61]) >= 7 .And.aPerfil[61][6] != '1' //-- DUO_QBRPRF
							DbCommitAll()
							cAliasDEB := GetNextAlias()
							cQuery := " SELECT COUNT(1) NFAT "
							cQuery += " FROM " + RetSqlName("DEB") + " DEB "
							cQuery += "	JOIN " + cArqMrk + " MRK "
							cQuery += "    ON MRK.TRB_FILDOC = DEB.DEB_FILDOC "	
							cQuery += "	  AND MRK.TRB_DOC    = DEB.DEB_DOC "
							cQuery += "   AND MRK.TRB_SERIE  = DEB.DEB_SERIE "			
							cQuery += " JOIN " + RetSqlName("DT6") + " DT6  "
							cQuery += "    ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "'" 
							cQuery += "   AND DT6.DT6_FILDOC = DEB.DEB_FILDOC "
							cQuery += "   AND DT6.DT6_DOC    = DEB.DEB_DOC "
							cQuery += "   AND DT6.DT6_SERIE  = DEB.DEB_SERIE "
							cQuery += "   AND DT6.DT6_NUM    > ' '"   
							cQuery += "   AND DT6.D_E_L_E_T_ = ' '"   
							cQuery += " WHERE DEB.DEB_FILIAL = '" + xFilial("DEB") + "' "
							cQuery += "   AND DEB.DEB_CGCDEV = '" + cCgcDev + "' "
							cQuery += "   AND DEB.DEB_NUMPRE = '" + cNumPre + "' "
							cQuery += "   AND DEB.D_E_L_E_T_ = ' '"
							DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDEB,.F.,.T.)
						
							If (cAliasDEB)->(!Eof()) .And. (cAliasDEB)->NFAT != (oTempTable:GetAlias())->(RecCount())
								Aadd(aMsgErr, {STR0031 + cNumPre, "00",""}) //-- "Um ou mais documentos selecionados não foram Faturados - verifique a pré-fatura "
							EndIf
							(cAliasDEB)->(DbCloseArea())
							RestArea(aTail(aAreas))
						EndIf
					EndIf

					If lContinua .And. !Empty(aPreFat)
						//-- Caso o pergunte TME45A esteja habilidado será impresso a fatura.
						If lPrintFt
							A45Print(cCliDev,cLojDev,aPreFat)
						EndIf

						//-- Caso o Perfil do cliente tenha o envio automático do envio financeiro do EDI (DOCCOB)
						A45EDI(cCliDev,cLojDev,aPreFat,aPerfil)
					EndIf

					//Zera a variavel statica criada no TMSA850 
					aPreFat := {}

				EndIf
			EndIf

			//-- Exclui tabela temporária
			oTempTable:Delete()
		EndIf
		
	//-- Exclusão da Fatura
	ElseIf nAcao == 2
		cPrefix := aVetPre[nCntFor1,3]
		cNum    := aVetPre[nCntFor1,4]
		cTipo   := aVetPre[nCntFor1,5]

		cAliasSE1 := GetNextAlias()
		cQuery := "SELECT SE1.R_E_C_N_O_ NUMREG "
		cQuery += "  FROM " + RetSqlName("SE1") + " SE1 "
		cQuery += " WHERE E1_FILIAL  = '" + xFilial("SE1") + "' "
		cQuery += "   AND E1_PREFIXO = '" + cPrefix + "' "
		cQuery += "   AND E1_NUM     = '" + cNum + "' "
		cQuery += "   AND E1_TIPO    = '" + cTipo + "' "
		cQuery += "   AND SE1.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.F.,.T.)
	
		If (cAliasSE1)->(!Eof())
			SE1->(DbGoTo((cAliasSE1)->NUMREG))
			Tmsa850Exc("SE1",(cAliasSE1)->NUMREG,4,,{},.F.,.F.,Aclone(aVetPre),nCntFor1,@aMsgErr)
		EndIf
		(cAliasSE1)->(DbCloseArea())
	EndIf
	
Next nCntFor1

If !IsInCallStack("TMSME10") .And. !Empty(aMsgErr)
	TmsMsgErr(aMsgErr)
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})
			
Return
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsae45Prc
@autor		: Daniel Leme
@descricao	: Chama a geração de faturas na rotina de Painel da Pré Fatura
@since		: 09/04/2019
@using		: TMSAE45A
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsae45Vis(aVetPre)
Local aAreas     := {SA1->(GetArea()),SE1->(GetArea()),GetArea()}
Local cAliasSE1  := ""
Local cQuery     := ""
Local nCntFor1   := Len(aVetPre)
Local aFaturas 

//-- Se a Pré-fatura tiver mais de uma fatura, abre tela para selecionar
If nCntFor1 > 1
	aFaturas   := {}
	aEval(aVetPre,{ |x| aAdd(aFaturas,{x[3],x[4],x[5]}) })
	nCntFor1 := TmsF3Array( {RetTitle("E1_PREFIXO"), RetTitle("E1_NUM"), RetTitle("E1_TIPO")}, aFaturas, "Faturas" ) 
	aSize( aFaturas, 0 )
EndIf

//-- Se não houver faturas ou não for selecionada uma fatura
If !Empty(nCntFor1)
	cAliasSE1 := GetNextAlias()
	cQuery := "SELECT SE1.R_E_C_N_O_ NUMREG "
	cQuery += "  FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += " WHERE SE1.E1_FILIAL  = '" + xFilial("SE1")      + "' "
	cQuery += "   AND SE1.E1_PREFIXO = '" + aVetPre[nCntFor1,3] + "' "
	cQuery += "   AND SE1.E1_NUM     = '" + aVetPre[nCntFor1,4] + "' "
	cQuery += "   AND SE1.E1_TIPO    = '" + aVetPre[nCntFor1,5] + "' "
	cQuery += "   AND SE1.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.F.,.T.)
	
	If (cAliasSE1)->(!Eof())
		SE1->(DbGoTo((cAliasSE1)->NUMREG))
		Tmsa850Vis("SE1",(cAliasSE1)->NUMREG,2)
		(cAliasSE1)->(DbCloseArea())
	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsae45Doc
@autor		: Valdemar Roberto
@descricao	: Transforma o objeto da pre fatura em vetor
@since		: 20/02/2019
@using		: TMSAE45A
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsae45Doc(cArqPre,aVetPre,cArqMrk,lOnlyFat,cAliasPFat)
Local aArea     := GetArea()
Local cQuery    := ""
Local cAliasQry := ""

Default cArqPre    := ""
Default lOnlyFat   := .F.
Default cAliasPFat := ""

cAliasQry := GetNextAlias()
cQuery := " SELECT DEB.DEB_CGCDEV,DEB.DEB_NUMPRE,DT6.DT6_PREFIX,DT6.DT6_NUM,DT6.DT6_TIPO,MAX(DT6.DT6_DATEMI) DATA_MAX,MIN(DT6.DT6_DATEMI) DATA_MIN"
cQuery += "   FROM " + RetSqlName("DEB") + " DEB "
If !Empty(cArqPre)
	cQuery += "   JOIN " + cArqPre + " DEBPRE "					//-- Pré-Faturas marcadas
	cQuery += "     ON DEBPRE.DEB_CGCDEV = DEB.DEB_CGCDEV "
	cQuery += "    AND DEBPRE.DEB_NUMPRE = DEB.DEB_NUMPRE "
    cQuery += "    AND DEBPRE.DEB_OK <> ' ' "
EndIf
If !Empty(cArqMrk)
	cQuery += "   JOIN " + cArqMrk + " MRK "					//-- Documentos marcados, dentro das pré-faturas
	cQuery += "     ON MRK.TRB_FILDOC = DEB.DEB_FILDOC "	
	cQuery += "    AND MRK.TRB_DOC    = DEB.DEB_DOC "
	cQuery += "    AND MRK.TRB_SERIE  = DEB.DEB_SERIE "
EndIf
cQuery += "   JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += "     ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "    AND DT6.DT6_FILDOC = DEB.DEB_FILDOC "	
cQuery += "    AND DT6.DT6_DOC    = DEB.DEB_DOC "
cQuery += "    AND DT6.DT6_SERIE  = DEB.DEB_SERIE "
//-- Se exclui fatura, somente documentos faturados devem ser considerados.
If lOnlyFat
	cQuery += "    AND DT6.DT6_NUM  > ' ' "
Else
	cQuery += "    AND DT6.DT6_NUM  = ' ' "
EndIf		
cQuery += "    AND DT6.D_E_L_E_T_ = ' ' "
cQuery += "  WHERE DEB.DEB_FILIAL = '" + xFilial("DEB") + "' "
cQuery += "    AND DEB.D_E_L_E_T_ = ' ' "

If !Empty(cAliasPFat) 
	cQuery += "    AND DEB.DEB_CGCDEV = '" + (cAliasPFat)->DEB_CGCDEV + "' "
	cQuery += "    AND DEB.DEB_NUMPRE = '" + (cAliasPFat)->DEB_NUMPRE + "' "
EndIf
cQuery += "  GROUP BY DEB.DEB_CGCDEV,DEB.DEB_NUMPRE,DT6.DT6_PREFIX,DT6.DT6_NUM,DT6.DT6_TIPO"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

TCSetField(cAliasQRY,"DATA_MAX","D",08,0)
TCSetField(cAliasQRY,"DATA_MIN","D",08,0)

While (cAliasQry)->(!Eof())
	Aadd(aVetPre,{(cAliasQry)->DEB_CGCDEV,(cAliasQry)->DEB_NUMPRE,(cAliasQry)->DT6_PREFIX,(cAliasQry)->DT6_NUM,(cAliasQry)->DT6_TIPO,;
					(cAliasQry)->DATA_MAX,(cAliasQry)->DATA_MIN})
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

RestArea(aArea)

Return

/*/{Protheus.doc} TMA45ACpo
Função para status da pre-fatura
@type		function
@return		TMA45AStPF
@author  	Fabio M. Sampaio
@version 	P12
@since   	19/02/2019
@return  	Nil
/*/
Function TMA45AStPF(lLegenda)
Local cRet := ""
Local cBMP := "BR_BRANCO"   

If NDOCPFAT == NDOCFAT
    cRet := STR0032 //-- "Faturado Totalmente"
	cBMP := "BR_AZUL"
ElseIf Empty(NDOCFAT)
    cRet := STR0033 //-- "Não Faturado"
	cBMP := "BR_VERDE"
ElseIf NDOCPFAT != NDOCFAT
    cRet := STR0034 //-- "Faturado Parcialmente"
	cBMP := "BR_AMARELO"
EndIf

Return IIf(lLegenda,cBMP,cRet)

/*/{Protheus.doc} TMA45ACpo
Função para status do documneto 
@type		function
@return		TMA45AStPF
@author  	Fabio M. Sampaio
@version 	P12
@since   	19/02/2019
@return  	Nil
/*/
Function TMA45AStDC(lLegenda)
Local cBMP := "BR_BRANCO"   
Local cRet		:= ""

If Empty(DT6_VALTOT)
    cRet := STR0035 //-- "Não Encontrado"
	cBMP := "BR_VERMELHO"
ElseIf Empty(DT6_NUM)
    cRet := STR0033 //-- "Não Faturado"
	cBMP := "BR_VERDE"
Else
    cRet := STR0044 //-- "Faturado"
	cBMP := "BR_AZUL"
EndIf

Return IIf(lLegenda,cBMP,cRet)


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSAE45VlP
@autor		: Felipe M. Barbiere
@descricao	: Valida o documento à ser faturado de acordo com o perfial do cliente
@since		: 27/02/2019
@using		: TMSAE45A
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TMSAE45VlP(cCliDev, cLojDev, cCGCDev, cNumPre, cAliasMark, aMsgErr)
Local cAliasNew    := GetNextAlias()
Local cQuery       := ""
Local nDocNOk      := 0
Local nDocMark     := 0
Local dVencAnt     := CtoD(Space(08))
Local aPerfil      := {}
Local lRet         := .T.
Local lEdi         := IsInCallStack("TMSME10")
Local nDocPFat     := 0
Local cSelect      := ""
Local lDocOK
Local nLenIni
Local cErro

Default cCGCDev    := ""
Default cCliDev    := ""
Default cLojDev    := ""
Default cNumPre    := ""
Default cAliasMark := ""
Default aMsgErr    := {}

aPerfil := TmsPerfil(cCliDev,cLojDev,,.F.)
If Len(aPerfil) >= 61 .And. ValType(aPerfil[61]) == "A" .And. Len(aPerfil[61]) >= 7 

	cSelect := " SELECT COUNT(1) NREG "
	cQuery  := " FROM " + RetSqlName("DEB") + " DEB "
	cQuery  += " WHERE DEB.DEB_FILIAL = '" + xFilial("DEB") + "' "
	cQuery  += "   AND DEB.DEB_CGCDEV = '" + cCGCDev + "' "
	cQuery  += "   AND DEB.DEB_NUMPRE = '" + cNumPre + "' "
	cQuery  += "   AND DEB.D_E_L_E_T_ = ' ' "
	//| Validação se pode quebrar a pre-fatura
	//| Campo Ger Qtd.Fat.
	//| 1=SIM : Permite quebrar a Fatura, se houver 1 ou mais documentos divergentes estes poderao ser removidos do faturamento.
	//| 2=NAO : Não permite quebrar a fatura, faturamento deve conter todos os documentos envolvidos.
	If aPerfil[61][6] <> "1"  //-- aPerfil[61][6] Permite "quebrar" uma pré-fatura em "n" faturas (DUO_QBRPRF)
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cSelect + cQuery ), cAliasNew, .F., .T. )
		nDocPFat := (cAliasNew)->NREG
		(cAliasNew)->(DbCloseArea())
	EndIf

	If cAliasMark <> Nil .And. !Empty(cAliasMark)
		cQuery += " AND EXISTS(SELECT 1 FROM " + cAliasMark + " DEBTMP "
		cQuery += "            WHERE DEBTMP.TRB_FILDOC = DEB.DEB_FILDOC "
		cQuery += "              AND DEBTMP.TRB_DOC    = DEB.DEB_DOC "
		cQuery += "              AND DEBTMP.TRB_SERIE  = DEB.DEB_SERIE) "
	EndIf

	cSelect := " SELECT DEB.DEB_FILDOC, DEB.DEB_DOC, DEB.DEB_SERIE, DEB.DEB_VALOR,DEB.DEB_NUMPRE, DEB_DATVEN "
	cSelect += " , DEB.R_E_C_N_O_ RECDEB "
	cQuery  := ChangeQuery( cSelect + cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )

	While lRet .And. (cAliasNew)->(!Eof())
		nDocMark++ 
		nLenIni := Len(aMsgErr)

		DT6->(DbSetOrder(1)) //--DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
		If (lDocOK := DT6->(DbSeek(xFilial('DT6')+(cAliasNew)->DEB_FILDOC+(cAliasNew)->DEB_DOC+(cAliasNew)->DEB_SERIE )))

			If aPerfil[61][4] == '1' //-- aPerfil[61][4] Tolerância Percentual (DUO_TIPTOL)
				If Abs((DT6->DT6_VALFAT / (cAliasNew)->DEB_VALOR)-1) > (aPerfil[61][5]/100) //-- aPerfil[61][5] Valor Tolerância (DUO_VALTOL)
					Aadd(aMsgErr, {STR0002 + STR0003 + (cAliasNew)->DEB_FILDOC + '/' +; //O Valor à ser faturado excede a tolerância cadastrada no perfil do cliente. Documento: 
									(cAliasNew)->DEB_DOC + '/' +(cAliasNew)->DEB_SERIE + ;
							  		" " + STR0004 + AllTrim(Round(DT6->DT6_VALFAT, 2)) + " " + STR0005 + AllTrim(Round((cAliasNew)->DEB_VALOR, 2)), "00",""}) //Valor Doc.  ** Valor Pre Fatura
					lDocOK := .F. 
					nDocNOk ++
				EndIf 
			ElseIf aPerfil[61][4] == '2' //-- Tolerância por Valor (DUO_TIPTOL)
				If Abs(DT6->DT6_VALFAT - (cAliasNew)->DEB_VALOR) > aPerfil[61][5] //-- aPerfil[61][5] Valor Tolerância (DUO_VALTOL)
					Aadd(aMsgErr, {STR0002 + STR0003 + (cAliasNew)->DEB_FILDOC + '/' +;
									(cAliasNew)->DEB_DOC + '/' +(cAliasNew)->DEB_SERIE + ;
							  		" " + STR0004 + AllTrim(Round(DT6->DT6_VALFAT, 2)) + " " + STR0005 + AllTrim(Round((cAliasNew)->DEB_VALOR, 2)), "00",""})	
					lDocOK := .F. 
					nDocNOk ++
				EndIf			
			Else //Não considera
				If DT6->DT6_VALFAT <> (cAliasNew)->DEB_VALOR
					Aadd(aMsgErr, {STR0006 + STR0003 + (cAliasNew)->DEB_FILDOC + '/' +; //O Valor à ser faturado divergente entre pre fatura e calculado pelo sistema.
									(cAliasNew)->DEB_DOC + '/' +(cAliasNew)->DEB_SERIE + ;
							  		" " + STR0004 + AllTrim(Round(DT6->DT6_VALFAT, 2)) + " " + STR0005 + AllTrim(Round((cAliasNew)->DEB_VALOR, 2)), "00",""})
					lDocOK := .F. 
					nDocNOk ++
				EndIf 
			EndIf
			
			If aPerfil[61][7] == '1' //-- 1 = Cond. Pagto para consisedar da Dt.Pré-Fatura
				If Empty(dVencAnt) 
					dVencAnt := StoD((cAliasNew)->DEB_DATVEN)
				EndIf
				
				If Empty((cAliasNew)->DEB_DATVEN) //Data de vencimento em branco do documento: XXXXX Verifique o campo de condição de pagto no perfil do cliente
					Aadd(aMsgErr, {STR0010 + (cAliasNew)->DEB_FILDOC + '/' + (cAliasNew)->DEB_DOC + '/' +(cAliasNew)->DEB_SERIE + ;
				  		" " + STR0011, "00",""})	
					lDocOK := .F. 
					nDocNOk ++
				ElseIf !Empty((cAliasNew)->DEB_DATVEN) .And. StoD((cAliasNew)->DEB_DATVEN) < dDataBase //Vencimento da fatura não pode ser inferior a data atual.
					Aadd(aMsgErr, {STR0003 + (cAliasNew)->DEB_FILDOC + '/' + (cAliasNew)->DEB_DOC + '/' +(cAliasNew)->DEB_SERIE + ;
						" " + STR0012, "00",""})	
					lDocOK := .F. 
					nDocNOk ++
				ElseIf !Empty((cAliasNew)->DEB_DATVEN) .And. SToD((cAliasNew)->DEB_DATVEN) <> dVencAnt //Datas de vencimento divergentes entre os documentos de pré-fatura
					Aadd(aMsgErr, {STR0003 + (cAliasNew)->DEB_FILDOC + '/' + (cAliasNew)->DEB_DOC + '/' +(cAliasNew)->DEB_SERIE + ;
						" " + STR0013, "00",""})	
					lDocOK := .F. 
					nDocNOk ++
				Endif				
			EndIf
		Else
			Aadd(aMsgErr, { STR0003 + (cAliasNew)->DEB_FILDOC + '/' + (cAliasNew)->DEB_DOC + '/' +(cAliasNew)->DEB_SERIE + ;
				" " + STR0036, "00",""})	 //-- " Documento não encontrado (DT6) "
			lDocOK := .F. 
			nDocNOk ++
		EndIf

		If !lDocOK 
			//-- Se foi chamado pelo EDI Diretamente, grava Msg no campo da DEB e não exibe o Help
			If lEdi .And. nLenIni < Len(aMsgErr)
				DEB->(DbGoTo((cAliasNew)->RECDEB))

				If DEB->(!Eof())
					cErro := ""
					aEval(aMsgErr,{|x,y| cErro += AllTrim(x[1]) + Chr(13) + Chr(10) },nLenIni+1)

					RecLock("DEB",.F.)
					DEB->DEB_STATUS := "["+DtoC(Date()) + "-" + Time() + "] " + cErro + Repl("-",40) + Chr(13)+ Chr(10) + AllTrim(DEB->DEB_STATUS) 
					MsUnLock()
				EndIf
			EndIf
		EndIf

		(cAliasNew)->(DbSkip())
	EndDo
	(cAliasNew)->(DbCloseArea())

	//-- Valida se foram marcados todos os documentos
	If lRet .And. aPerfil[61][6] <> "1"  //-- aPerfil[61][6] Permite "quebrar" uma pré-fatura em "n" faturas (DUO_QBRPRF)
		If nDocPFat != nDocMark 
			Aadd(aMsgErr,{STR0045 + STR0009 + cCliDev + cLojDev + Posicione("SA1",1, cCliDev + cLojDev ,"A1_NOME"),"00",""}) // "Não foram marcados todos os documentos da Pré-Fatura. " ### "Verifique o campo 'Ger Qtd.Fat' para o cliente: " ######
			Aadd(aMsgErr,{STR0037 + cNumPre ,"00",""}) //-- "PreFat: "
			lRet := .F.
		EndIf
	EndIf

	//| Validação se pode quebrar a pre-fatura
	//| Campo Ger Qtd.Fat.
	//| 1=SIM : Permite quebrar a Fatura, se houver 1 ou mais documentos divergentes estes poderao ser removidos do faturamento.
	//| 2=NAO : Não permite quebrar a fatura, faturamento deve conter todos os documentos envolvidos.
	If lRet .And. nDocNOk > 0 
		Aadd(aMsgErr,{STR0008 + STR0009 + cCliDev + cLojDev + Posicione("SA1",1, cCliDev + cLojDev ,"A1_NOME"),"00",""}) //STR0008 "Pré-Fatura com documentos divergentes não poderão ser faturado(s)." STR0009 "Verifique o campo 'Ger Qtd.Fat' para o cliente: " ######
		Aadd(aMsgErr,{STR0037 + cNumPre ,"00",""}) //-- "PreFat: "
		lRet := .F.
	EndIf
EndIf

aSize(aPerfil,0)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMAE45Cond
@autor		: Fabio Marchiori Sampaio
@descricao	: Valida a condição de pagamento está cadastrado no SA1
@since		: 06/03/2019
@using		: TMSAE45A
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TMAE45Cond(cCliDev, cLojDev, aMsgErr)

Local cCondicao		:= ""
Local lRet          := .T.

Default cCliDev     := ""
Default cLojDev     := ""
Default aMsgErr		:= {}

cCondicao := Posicione("SA1",1,xFilial("SA1")+(cCliDev+cLojDev),"A1_COND")

If Empty(cCondicao)
	Aadd(aMsgErr, {STR0007 , "00",""}) //Cliente sem condição de pagamento cadastrada !!
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsPreVFat
@autor		: Felipe M. Barbiere
@descricao	: Retorna o valor à ser faturado de acordo com o perfil do cliente
@since		: 27/02/2019
@using		: TMSAE45A
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsPreVFat(cCliDev, cLojDev, nDEBVlFat, nDT6VlFat)

Local nValRet 	  := 0
Local aPerfil     := {}

Default cCliDev   := ""
Default cLojDev   := ""
Default nDEBVlFat := 0
Default nDT6VlFat := 0

aPerfil := TmsPerfil(cCliDev,cLojDev,,.F.)
If Len(aPerfil) >= 61 .And. ValType(aPerfil[61]) == "A" .And. Len(aPerfil[61]) >= 7 .And. aPerfil[61][3] == "1"
	nValRet := nDEBVlFat
Else
	nValRet := nDT6VlFat
EndIf

Return nValRet
	
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AE45Transf
@autor		: Daniel Leme
@descricao	: Transfere Doctos de uma Pré-Fatura para outra Pré-Fatura
@since		: 08/03/2019
@using		: TMSAE45A
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function AE45Transf(oTbMark,oBrwOwner)	
Local cAliasNew := GetNextAlias()
Local cQuery    := ""
Local lContinua := .T.
Local aParamBox := {}
Local aRetParam := {}

Local cDT6NumVaz  := Space(TamSX3("DT6_NUM")[1])

//-- Verifica se tem documentos marcados que estejam aptos a serem transferidos
cQuery := " SELECT SUM(CASE WHEN COALESCE(DT6.DT6_NUM,'" + cDT6NumVaz + "') > '" + cDT6NumVaz + "' THEN 0 ELSE 1 END)  NDOCNFAT    " 
cQuery += "       ,SUM(1)  NDOCS    " 
cQuery += " FROM " + oTbMark:GetRealName() + " DOCS "  //-- Documentos marcados
cQuery += " LEFT JOIN " + RetSqlName("DT6") + " DT6  "
cQuery += "    ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "'" 
cQuery += "   AND DT6.DT6_FILDOC = DOCS.TRB_FILDOC"
cQuery += "   AND DT6.DT6_DOC    = DOCS.TRB_DOC"
cQuery += "   AND DT6.DT6_SERIE  = DOCS.TRB_SERIE"
cQuery += "   AND DT6.D_E_L_E_T_ = ' '"   
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )

//-- Valida se existe documentos a transferir (não faturados)
If (cAliasNew)->(!Eof()) .And. Empty((cAliasNew)->NDOCNFAT)
	lContinua := .F.
	MsgAlert(STR0038) //-- "Não há Documentos marcados que não estejam faturados!"
EndIf
//-- Avisa o usário que há documentos marcados que não serão transferidos e questiona sobre a continuidade do processo.
If lContinua .And. (cAliasNew)->(!Eof()) .And. (cAliasNew)->(NDOCNFAT <>  NDOCS)
	lContinua := MsgYesNo(STR0039) //-- "Existem documentos marcados que estão faturados e, portanto não serão transferidos. Deseja continuar?"
EndIf
(cAliasNew)->(DbCloseArea())

If lContinua
	aAdd(aParamBox,{1,RetTiTle("DEB_NUMPRE"),CriaVar("DEB_NUMPRE",.T.),PesqPict("DEB","DEB_NUMPRE")," " /*Valid*/ ,"" /*F3*/,""/* when */,TamSX3("DEB_NUMPRE")[1],.T. /* obrigat */})    
	If ParamBox(aParamBox,STR0040,@aRetParam)     //-- "Mover Documentos marcados para outra Pré-Fatura"

		cQuery := " SELECT DEB.R_E_C_N_O_ RECDEB, DT6_NUM "
		cQuery += " FROM " + oTbMark:GetRealName() + " DOCS "  //-- Documentos marcados
		cQuery += " JOIN " + RetSqlName("DEB") + " DEB "
		cQuery += "    ON DEB.DEB_FILIAL = '" + xFilial("DEB") + "'"
		cQuery += "   AND DEB.DEB_FILDOC = DOCS.TRB_FILDOC"
		cQuery += "   AND DEB.DEB_DOC    = DOCS.TRB_DOC"
		cQuery += "   AND DEB.DEB_SERIE  = DOCS.TRB_SERIE"
		cQuery += "   AND DEB.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN " + RetSqlName("DT6") + " DT6  "
		cQuery += "    ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "'" 
		cQuery += "   AND DT6.DT6_FILDOC = DEB.DEB_FILDOC "
		cQuery += "   AND DT6.DT6_DOC    = DEB.DEB_DOC "
		cQuery += "   AND DT6.DT6_SERIE  = DEB.DEB_SERIE "
		cQuery += "   AND DT6.D_E_L_E_T_ = ' '"   
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
		While (cAliasNew)->(!Eof())
			If Empty((cAliasNew)->DT6_NUM)
				DEB->(DbGoto((cAliasNew)->RECDEB))
				If DEB->(!Eof())

					RecLock("DEB",.F.)
					DEB->DEB_STATUS := STR0041 + DEB->DEB_NUMPRE + Chr(13)+ Chr(10) + AllTrim(DEB->DEB_STATUS) //-- " Docto Transferido da Pré-Fatura: "
					DEB->DEB_NUMPRE := aRetParam[1]
					MsUnlock()
				EndIf
			EndIf
			(cAliasNew)->(DbSkip())
		EndDo
		(cAliasNew)->(DbCloseArea())

		//-- Limpa os documentos da temporária de "marcados" após a transfer
		A45ClearMK(oTbMark:GetRealName() )
	EndIf
EndIf
Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ME45AMDoc
@autor		: Daniel Leme
@descricao	: Marcação dos Documentos
@since		: 22/03/2019
@using		: TMSAE45A
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function ME45AMDoc(cAliasDoc,oTbMark,cMarkBrw,oBrwPFat,lAll)
Local lContinua := .T.
Local cQuery    := ""

//-- Validações, se estiver marcando
If Empty((cAliasDoc)->DEB_OK)
	//-- Não Marca Doctos caso a Pré-Fatura não esteja marcada. 
	If lContinua .And. Empty((oBrwPFat:Alias())->DEB_OK)
		If !lAll
			MsgAlert(STR0042 + (oBrwPFat:Alias())->DEB_NUMPRE + STR0043) //-- "A Pré-Fatura " ## " não está marcada. Selecione-a para interagir com os Documentos dela"
		EndIf
		lContinua := .F.
	EndIf

	//-- Se não encontrar DT6, não marca
	If lContinua .And. Empty((cAliasDoc)->DT6_VALTOT)
		lContinua := .F.
	EndIf

//-- Validações se estiver Desmarcando
Else
	//-- Sem validações
	lContinua := .T.
EndIf

If lContinua
	//-- Desmarcando
	If !Empty((cAliasDoc)->DEB_OK)
		//-- Limpa o documento da temporária de "marcados"
		If (lContinua := A45ClearMK(oTbMark:GetRealName() , (cAliasDoc)->DEB_FILDOC, (cAliasDoc)->DEB_DOC, (cAliasDoc)->DEB_SERIE))

			//-- Limpa a marca no objeto (temp do FwBrowse)
			RecLock(cAliasDoc,.F.)
			(cAliasDoc)->DEB_OK := ""
			MsUnlock()
		EndIf

	//-- Marcando
	Else
		//-- Acrescenta o documento à temporária de "marcados"
		If (lContinua := A45AddMarK(oTbMark:GetRealName() , (cAliasDoc)->DEB_FILDOC, (cAliasDoc)->DEB_DOC, (cAliasDoc)->DEB_SERIE))
			//-- Grava a marca no objeto (temp do FwBrowse)
			RecLock(cAliasDoc,.F.)
			(cAliasDoc)->DEB_OK := cMarkBrw
			MsUnlock()
		EndIf
	EndIf
	
EndIf

Return lContinua

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A45ClearMK
@autor		: Daniel Leme
@descricao	: Limpa tabela temporária com Doctos Marcados
@since		: 22/03/2019
@using		: TMSAE45A
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function A45ClearMK(cAliasMark, cFilDoc, cDoc, cSerie)
Local cQuery := ""
Local lRet   := .T.

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""

//-- Limpa os documentos da temporária de "marcados"
cQuery := "DELETE  FROM " + cAliasMark
If !Empty(cDoc)
	cQuery += " WHERE TRB_FILDOC = '" + cFilDoc + "'"
	cQuery += "   AND TRB_DOC    = '" + cDoc    + "'"
	cQuery += "   AND TRB_SERIE  = '" + cSerie  + "'"
EndIf
If TCSqlExec(cQuery) <> 0 
	MsgALert("Erro SQL: "+ TcSqlError())
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A45AddMarK
@autor		: Daniel Leme
@descricao	: Acrescenta documento à tabela temporária com Doctos Marcados
@since		: 24/04/2019
@using		: TMSAE45A
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function A45AddMarK(cAliasMark, cFilDoc, cDoc, cSerie)
Local cQuery := ""
Local lRet   := .T.

//-- Acrescenta documento à tabela temporária com Doctos Marcados
cQuery := "INSERT INTO  " + cAliasMark + " (TRB_FILDOC, TRB_DOC, TRB_SERIE) "
cQuery += "       VALUES('"+cFilDoc+"','"+cDoc+"','"+cSerie+"')"

If TCSqlExec(cQuery) <> 0 
	MsgALert("Erro SQL: "+ TcSqlError())
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A45Legenda
@autor		: Daniel Leme
@descricao	: Mostra Legenda
@since		: 08/04/2019
@using		: TMSAE45A
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function A45Legenda(nBrowse)
Local aArea    := GetArea()
Local aLegenda := {}		

If nBrowse == 1 //-- Pré-Fatura
	Aadd(aLegenda,{"BR_AZUL"   ,STR0032  }) //-- "Faturado Totalmente"
	Aadd(aLegenda,{"BR_VERDE"  ,STR0033  })	//-- "Não Faturado"
	Aadd(aLegenda,{"BR_AMARELO",STR0034  })	//-- "Faturado Parcialmente"
ElseIf nBrowse == 2 //-- Documentos da Pré-Fatura
	Aadd(aLegenda,{"BR_AZUL"    ,STR0044  })    //-- "Faturado"
	Aadd(aLegenda,{"BR_VERDE"   ,STR0026  })	//-- "Não Faturado"	
	Aadd(aLegenda,{"BR_VERMELHO",STR0034  })	//-- "Faturado Parcialmente"	
EndIf

If Len(aLegenda) > 0  
	BrwLegenda(STR0016,STR0016,aLegenda)	//-- "Legenda"
EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A45Print
@autor		: Daniel Leme
@descricao	: Realiza a chamada à Impressão da Fatura, caso o pergunte indique esta opção
@since		: 02/12/2019
@using		: TMSAE45A
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function A45Print(cCliDev,cLojDev,aPreFat)
Local cPrefixo, cNumPrim, cNumFinal, dDatVenIn, dDatVenFi

If MV_PAR04 == 1 .And. !IsBlind()
	cPrefixo := aPreFat[1][1]
	cNumPrim := aPreFat[1][2] 
	cNumFinal:= aPreFat[Len(aPreFat)][2]
	dDatVenIn:= aPreFat[1][3]
	dDatVenFi:= aPreFat[Len(aPreFat)][3]

	SetMVValue("TMSR650","MV_PAR01",cPrefixo   		)    //Prefixo ?                     
	SetMVValue("TMSR650","MV_PAR02",cNumPrim    	)	//Fatura de ?                
	SetMVValue("TMSR650","MV_PAR03",cNumFinal   	)	//Fatura até ?               
	SetMVValue("TMSR650","MV_PAR04",cCliDev     	)	//Cliente De ?               
	SetMVValue("TMSR650","MV_PAR05",cLojDev     	)	//Loja de ?                  
	SetMVValue("TMSR650","MV_PAR06",cCliDev     	)	//Cliente Até ?              
	SetMVValue("TMSR650","MV_PAR07",cLojDev     	)	//Loja até ?                 
	SetMVValue("TMSR650","MV_PAR08",dDatVenIn   	)	//Data de ?                  
	SetMVValue("TMSR650","MV_PAR09",dDatVenFi   	)	//Data até ?                 
	SetMVValue("TMSR650","MV_PAR10",'Pre-Fatura'    )   //Observação ?               

	lPerg := .T.
	ExecBlock("TMSR650",.F.,.F.,{lPerg})
EndIf

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A45EDI
@autor		: Daniel Leme
@descricao	: Realiza a chamada ao EDI DOCCOB para fatura gerada por pré-fatura
@since		: 02/12/2019
@using		: TMSAE45A
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function A45EDI(cCliDev,cLojDev,aPreFat,aPerfil)
Local cPrefixo, cNumPrim, cNumFinal

If !Empty(aPerfil) .And. Len(aPerfil) >= 61 .And. ValType(aPerfil[61]) == "A" .And. Len(aPerfil[61]) >= 8 .And.aPerfil[61][8] == '1' //-- DUO_PRFEDI

	cPrefixo := aPreFat[1][1]
	cNumPrim := aPreFat[1][2] 
	cNumFinal:= aPreFat[Len(aPreFat)][2]
	
	SetMVValue("TMME02","MV_PAR01",cCliDev   	)   // Cliente De ?   
	SetMVValue("TMME02","MV_PAR02",cLojDev     	)	// Loja De ?      
	SetMVValue("TMME02","MV_PAR03",cCliDev      )	// Cliente Ate ?  
	SetMVValue("TMME02","MV_PAR04",cLojDev     	)	// Loja Ate ?     
	SetMVValue("TMME02","MV_PAR05",cNumPrim     )	// Fatura De ?    
	SetMVValue("TMME02","MV_PAR06",cNumFinal    )	// Fatura Ate ?   
	SetMVValue("TMME02","MV_PAR07",dDataBase    )	// Data De ?      
	SetMVValue("TMME02","MV_PAR08",dDataBase   	)	// Data Ate ?     
	SetMVValue("TMME02","MV_PAR09",2	   		)	// Retransmissao ?

	TMSME05(2,.T.)

	Pergunte("TME45A", .F.)
EndIf

Return Nil
