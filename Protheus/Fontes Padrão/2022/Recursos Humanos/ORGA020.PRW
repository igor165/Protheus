#INCLUDE "PROTHEUS.CH"
#INCLUDE "ORGA020.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "APDTREEN.CH"
#INCLUDE "HEADERGD.CH"

//#DEFINE TREE_PERMISSION {"UNCHECKED_15", "CHECKED_15", "NOCHECKED_15", "CHECKED_MASTER_15", "NOCHECKED_MASTER_15", "CHECKED_CHILD_15", "NOCHECKED_CHILD_15"}
//#DEFINE GRID_PERMISSION {"NONE_15", "OK_15", "CANCEL_15"}
#DEFINE TREE_PERMISSION {"UNCHECKED", "CHECKED", "NOCHECKED", "CHECKED_MDI", "NOCHECKED_MDI", "CHECKED_OCEAN", "NOCHECKED_OCEAN"}
#DEFINE GRID_PERMISSION {"WFUNCHK", "CHECKOK", "BR_CANCEL"}

#DEFINE TAB_ESTRUT_ORG	1
#DEFINE TAB_DEPTO		2

Static lChanged:= .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณ ORGA020  ณ Autor ณ Rogerio Ribeiro       ณ Data ณ 18/10/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Configurador de Permissoes					              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณData      ณ Programador   ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ29/11/2010ณEmerson Campos ณAjuste para nova interface 11. Projeto      ณฑฑ
ฑฑณ          ณ               ณversใo 11.5                                 ณฑฑ
ฑฑณ24/04/2013ณClaudinei S.   ณAjuste em Org020Tree() e em SaveDataset()   ณฑฑ
ฑฑณ          ณ0000006769/2013ณpara que as visoes de niveis diferentes nao ณฑฑ
ฑฑณ          ณ         TGXJBVณherdem as permissoes dadas ou removidas.    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function ORGA020()
	Local nCombo:= 1
	Local aSQBHeader, aRCLHeader
	Local nCount
	Local aGdCoord
	Local aGdCoord1
	
	Private htbRows			:= Hashtable():New()
	Private htbVisOrg		:= HashTable():New()
	Private aListaEmpresas	:= fGetSM0(.T.)
	Private oSize 			:= FwDefSize():New()             
	
	oSize:AddObject( "CABECALHO",  oSize:aWindSize[4], oSize:aWindSize[3] * 0.20, .F., .F. ) // Nใo dimensionavel
	oSize:AddObject( "GETDADOS",  oSize:aWindSize[4], oSize:aWindSize[3] * 0.80, .F., .F. ) // Nใo dimensionavel
		        
	oSize:lProp 	:= .F. // Proporcional             
	oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
	oSize:Process() 	   // Dispara os calculos   
		
	ResetStaticVariables()
	OpenTables()

	//
	//frmConfigurador
	//
	Private frmConfigurador:= MSDialog():Create(GetWndDefault())
	frmConfigurador:cName := "frmConfigurador"
	frmConfigurador:cCaption := STR0001 //"Configurador de Permissoes"
	frmConfigurador:nLeft := oSize:aWindSize[2]
	frmConfigurador:nTop := oSize:aWindSize[1]
	frmConfigurador:nWidth := oSize:aWindSize[4]
	frmConfigurador:nHeight := oSize:aWindSize[3]
	frmConfigurador:bInit := {|| FormInit() }
	
	//
	//grpTipo
	//
	Private grpTipo:= TGroup():Create(frmConfigurador)
	grpTipo:nTop := oSize:GetDimension("CABECALHO","LININI") + 30 
	grpTipo:nLeft := oSize:GetDimension("CABECALHO","COLINI") 
	grpTipo:nWidth := oSize:GetDimension("CABECALHO","COLEND") - 10
	grpTipo:nHeight := oSize:GetDimension("CABECALHO","LINEND") - 10
	grpTipo:cCaption := STR0002 //"Tipo"
	//
	//radTipo
	//
	Private radTipo:= TRadMenu():Create(grpTipo)
	radTipo:cName := "radTipo"
	radTipo:nTop := oSize:GetDimension("CABECALHO","LININI")+50
	radTipo:nLeft := oSize:GetDimension("CABECALHO","COLINI")+20
	radTipo:nWidth := 100
	radTipo:nHeight := 40
	radTipo:bSetGet := {|u| If(PCount() > 0, radTipo:cVariable:=Str(u), Val(radTipo:cVariable)) }
	radTipo:aItems := {STR0003, STR0004} // "Usuแrio", "Grupo"

	
	radTipo:nOption := 1
	radTipo:bChange := {|| RadioChanged() }
	radTipo:bWhen := {|| RadioWhen() }
	//
	//sayUsrOrGrp
	//
	Private sayUsrOrGrp := TSay():Create(frmConfigurador)
	sayUsrOrGrp:nTop := oSize:GetDimension("CABECALHO","LININI") + 53
	sayUsrOrGrp:nLeft := oSize:GetDimension("CABECALHO","COLINI")+ 100
	sayUsrOrGrp:nWidth := 50
	sayUsrOrGrp:nHeight := 20
	sayUsrOrGrp:cCaption := STR0003 + ":" //"Usuแrio:"
	//
	//getUsrOrGrp
	//
	Private getUsrOrGrp := TGet():Create(frmConfigurador)
	getUsrOrGrp:nTop := oSize:GetDimension("CABECALHO","LININI") + 50
	getUsrOrGrp:nLeft := oSize:GetDimension("CABECALHO","COLINI")+ 180
	getUsrOrGrp:nWidth := 158
	getUsrOrGrp:nHeight := 22
	getUsrOrGrp:cF3:= "US2"
	getUsrOrGrp:bValid := {|| ValidUser()}
	getUsrOrGrp:bSetGet := {|value| If(PCount() > 0, getUsrOrGrp:cVariable:=value, getUsrOrGrp:cVariable) }
	getUsrOrGrp:cText := SPACE(6)
	//			
	//sayNameOrDesc
	//
	Private sayNameOrDesc := TSay():Create(frmConfigurador)
	sayNameOrDesc:nTop := oSize:GetDimension("CABECALHO","LININI") + 53
	sayNameOrDesc:nLeft := oSize:GetDimension("CABECALHO","COLINI")+ 350
	sayNameOrDesc:nWidth := 50
	sayNameOrDesc:nHeight := 20
	sayNameOrDesc:cCaption := STR0005 + ":" //"Nome:"
	//
	//getNameOrDesc
	//
	Private getNameOrDesc := TGet():Create(frmConfigurador)
	getNameOrDesc:nTop := oSize:GetDimension("CABECALHO","LININI") + 50
	getNameOrDesc:nLeft := oSize:GetDimension("CABECALHO","COLINI")+ 400
	getNameOrDesc:nWidth := 258
	getNameOrDesc:nHeight := 22
	getNameOrDesc:bSetGet := {|value| If(PCount() > 0, getNameOrDesc:cVariable:=value, getNameOrDesc:cVariable) }
	getNameOrDesc:cText := Space(30)
	getNameOrDesc:lReadOnly := .T.	
	//
	//fldPermissoes
	//
	Private fldPermissoes:= TFolder():New(NIL, NIL, NIL, NIL, frmConfigurador)
	fldPermissoes:cName := "fldPermissoes"
	fldPermissoes:nTop := oSize:GetDimension("GETDADOS","LININI")
	fldPermissoes:nLeft := oSize:GetDimension("GETDADOS","COLINI")
	fldPermissoes:nHeight:= oSize:GetDimension("GETDADOS","LINEND")
	fldPermissoes:nWidth:= oSize:GetDimension("GETDADOS","COLEND")
	fldPermissoes:AddItem(STR0006) //"Estrutura Organizacional"
	fldPermissoes:AddItem(STR0008) //"Departamentos"
	fldPermissoes:SetOption(1)
	fldPermissoes:bSetOption := {|nDest| TabChanged(nDest) }
	fldPermissoes:bWhen := {|| FolderWhen() }
	
	aPosGetD := { 3, 3, oSize:GetDimension("GETDADOS","YSIZE") - 16, oSize:GetDimension("GETDADOS","XSIZE") - 4 }
	//
	//sayCdVisOrg
	//	
	Private sayCdVisOrg := TSay():Create(fldPermissoes:aDialogs[TAB_ESTRUT_ORG])
	sayCdVisOrg:nTop := aPosGetD[1] + 13
	sayCdVisOrg:nLeft := aPosGetD[2] + 5
	sayCdVisOrg:nWidth := 96
	sayCdVisOrg:nHeight := 26
	sayCdVisOrg:cCaption := STR0010 + ":" //"Visao:"
	//
	//getCdVisOrg
	//
	Private getCdVisOrg := TGet():Create(fldPermissoes:aDialogs[TAB_ESTRUT_ORG])
	getCdVisOrg:nTop := aPosGetD[1] + 10
	getCdVisOrg:nLeft := aPosGetD[2] + 50
	getCdVisOrg:nWidth := 98
	getCdVisOrg:nHeight := 22
	getCdVisOrg:bSetGet := {|value| If(PCount() > 0, getCdVisOrg:cVariable:=value, getCdVisOrg:cVariable) }
	getCdVisOrg:cText := Space(GetSx3Cache("RDK_CODIGO", "X3_TAMANHO"))
	getCdVisOrg:cF3:= "RDKORG"
	getCdVisOrg:bValid:= {|| ValidOrgVision() }
	getCdVisOrg:lReadOnly := .F.
	//
	//sayDsVisOrg
	//
	Private sayDsVisOrg := TSay():Create(fldPermissoes:aDialogs[TAB_ESTRUT_ORG])
	sayDsVisOrg:nTop := aPosGetD[1] + 13
	sayDsVisOrg:nLeft := aPosGetD[2] + 160
	sayDsVisOrg:nWidth := 52
	sayDsVisOrg:nHeight := 26
	sayDsVisOrg:cCaption := STR0011 + ":" //"Descricao:"
	//
	//getDsVisOrg
	//
	Private getDsVisOrg := TGet():Create(fldPermissoes:aDialogs[TAB_ESTRUT_ORG])
	getDsVisOrg:nTop := aPosGetD[1] + 10
	getDsVisOrg:nLeft := aPosGetD[2] + 220
	getDsVisOrg:nWidth := 258
	getDsVisOrg:nHeight := 22
	getDsVisOrg:bSetGet := {|value| If(PCount() > 0, getDsVisOrg:cVariable:=value, getDsVisOrg:cVariable) }
	getDsVisOrg:cText := Space(GetSx3Cache("RDK_DESC", "X3_TAMANHO"))
	getDsVisOrg:lReadOnly := .T.
	//                                                            
	//dbtVisOrg
	//
  	Private dbtVisOrg:= DBTree():New(NIL, NIL, NIL, NIL, fldPermissoes:aDialogs[TAB_ESTRUT_ORG])
	dbtVisOrg:cName:= "dbtVisOrg"
	dbtVisOrg:nTop := aPosGetD[1] + 40
	dbtVisOrg:nLeft := aPosGetD[2] + 5
	dbtVisOrg:nHeight := aPosGetD[3] - 150
	dbtVisOrg:nWidth := aPosGetD[4] - 20
	dbtVisOrg:lCargo:= .T.  
	//
	//ngdDepartamentos
	//					
	Private ngdDepartamentos := MsNewGetDados():New( aPosGetD[1] + 30	,;
									   			aPosGetD[2] + 5			,;
											    aPosGetD[3] * 0.4		,;
												aPosGetD[4] / 2			,;
												NIL						,;
												NIL						,;
												NIL						,;
												NIL						,;
												NIL						,;
												0						,;
												999						,; 
												NIL						,;
												NIL						,;
												NIL						,;
												fldPermissoes:aDialogs[TAB_DEPTO],;
												aSQBHeader:= GdMontaHeader(NIL, NIL, NIL, "SQB", NIL, .T., NIL, { { "COLBMP" , GRID_PERMISSION[REVOKE]} }),;
												GetBlankRow("SQB", aSQBHeader);
											  )
	ngdDepartamentos:oBrowse:bRClicked:= {|o,x,y| DepPopMenu(ngdDepartamentos, x, y) }	
	//
	//cmbDeptoBusca
	//
	Private cmbDeptoBusca := TComboBox():New(NIL,NIL, bSETGET(nCombo), GetIndexes("SQB"), NIL, NIL, fldPermissoes:aDialogs[TAB_DEPTO])
	cmbDeptoBusca:nTop := aPosGetD[1] + 10
	cmbDeptoBusca:nLeft := aPosGetD[2] + 5
	cmbDeptoBusca:nWidth := 230
	cmbDeptoBusca:nHeight := 22
	cmbDeptoBusca:lReadOnly := .F.
	//
	//getDeptoBusca
	//
	Private getDeptoBusca := TGet():Create(fldPermissoes:aDialogs[TAB_DEPTO])
	getDeptoBusca:nTop := aPosGetD[1] + 10
	getDeptoBusca:nLeft := aPosGetD[2] + 250
	getDeptoBusca:nWidth := 230
	getDeptoBusca:nHeight := 22
	getDeptoBusca:bSetGet := {|value| If(PCount() > 0, getDeptoBusca:cVariable:=value, getDeptoBusca:cVariable) }
	getDeptoBusca:cText := Space(30)
	getDeptoBusca:lReadOnly := .F.
	//
	//btnDeptoBusca
	//
	Private btnDeptoBusca:= TButton():Create(fldPermissoes:aDialogs[TAB_DEPTO])   
	btnDeptoBusca:nTop := aPosGetD[1] + 10
	btnDeptoBusca:nLeft := aPosGetD[2] + 500
	btnDeptoBusca:nWidth := 90
	btnDeptoBusca:nHeight := 22
	btnDeptoBusca:cCaption := STR0012 //"Buscar"	
	btnDeptoBusca:bAction := {|| BtnSearchClick(@ngdDepartamentos, cmbDeptoBusca:nAt, AllTrim(getDeptoBusca:cText), "SQB") }	
	//
	//btnDeptoFilter
	//
	Private btnDeptoFilter:= TButton():Create(fldPermissoes:aDialogs[TAB_DEPTO])   
	btnDeptoFilter:nTop := aPosGetD[1] + 10
	btnDeptoFilter:nLeft := aPosGetD[2] + 610 
	btnDeptoFilter:nWidth := 90
	btnDeptoFilter:nHeight := 22
	btnDeptoFilter:cCaption := STR0013 //"Filtrar"	
	btnDeptoFilter:bAction := {|| BtnFilterClick(@ngdDepartamentos) }
	
	ACTIVATE DIALOG frmConfigurador
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Org020Tree(objTree, aTreeCoords, htbVisoes)
	Local cAlias:= "RDK"
	Local nReg:= RDK->(RecNo())
	
	Local aComplDesc		:= {}
	Local aDbTreeInfo		:= {}
	Local bRd4TreeAddItem 	:= { |cLastItemNum| Rd4TreeAddItem( cAlias , nReg , cLastItemNum ) }
	Local cFilRDK			:= xFilial("RDK")
	Local cKeyFilter		:= ""
	Local nOrderItem		:= RetOrdem( "RD4" , "RD4_FILIAL+RD4_CODIGO+RD4_ITEM+RD4_TREE" )
	Local nOrderTree		:= RetOrdem( "RD4" , "RD4_FILIAL+RD4_CODIGO+RD4_TREE+RD4_ITEM" )

	Local aMenuPopUp:=	{	{OemToAnsi(STR0014), { || CursorWait(), lChanged:= .T., OrgTreeRevoke(@&(objTree:cName)), CursorArrow() }, .T., NIL, TREE_PERMISSION[REVOKE]},;	 																	//"Remover Permissใo"
							{OemToAnsi(STR0015 + "..."), NIL, .T., {;//"Conceder Permissใo..."
							{OemToAnsi(STR0016), { || CursorWait(), lChanged:= .T., OrgTreeGrant(@&(objTree:cName), .F.), CursorArrow() }, .T., NIL, TREE_PERMISSION[GRANT]},;	 														//"Somente neste departamento"
							{OemToAnsi(STR0017), { || CursorWait(), lChanged:= .T., OrgTreeGrant(@&(objTree:cName), .T.), CursorArrow() }, .T., NIL, TREE_PERMISSION[MASTER_GRANT]}		}, TREE_PERMISSION[GRANT]		},;				//"A partir deste ponto da arquitetura"
							{OemToAnsi(STR0018 + "..."), NIL, .T., {; //"Negar Permissใo..."
							{OemToAnsi(STR0016), { || CursorWait(), lChanged:= .T., OrgTreeDeny(@&(objTree:cName), .F.), CursorArrow() }, .T., NIL, TREE_PERMISSION[DENY]},;															//"Somente neste departamento"
							{OemToAnsi(STR0017), { || CursorWait(), lChanged:= .T., OrgTreeDeny(@&(objTree:cName), .T.), CursorArrow() }, .T., NIL, TREE_PERMISSION[MASTER_DENY]}		}, TREE_PERMISSION[DENY]		}		}  		//"A partir deste ponto da arquitetura"


	aAdd( aComplDesc , "RD4_EMPIDE" )
	aAdd( aComplDesc , "RD4_FILIDE" )
	aAdd( aComplDesc , "RD4_CODIDE" )
	
	RDK->( MsGoto( nReg ) )
	cKeyFilter := RDK->RDK_CODIGO


	If !htbVisoes:ContainsKey(RDK->RDK_CODIGO)
		htbVisoes:SetItem(	RDK->RDK_CODIGO,;
							SelectTreeRows("SQB", GdMontaHeader(NIL, NIL, NIL, "RD4", NIL, .T., NIL, { { "COLBMP" , TREE_PERMISSION[REVOKE]} }), "1", RDK->RDK_CODIGO, RDK->RDK_DESC, RDK->(RECNO()));
						 )	
	End
	
	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Define aDbTreeInfo                                      	   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	aDbTreeInfo :=	{;
	 			    	{;
	 			    		cAlias,;				//01 , 01 -> Alias Mestre do Tree
	 			    		nReg,;					//01 , 02 -> Recno para o Posicionamento do Tree
	 			    		cFilRDK,;				//01 , 03 -> Filial para a Montagem do Tree
	 			    		cKeyFilter,;			//01 , 04 -> Chave para a Montagem do Tree
	 			    		"RDK_DESC",;			//01 , 05 -> Descricao do Tree
	 			    		{|| "NORMAS"},;
	 			    		{|| "NORMAS"};
	 			    	},;
	 			    	{;
	 			    		"RD4",;			//02 , 01 -> Alias Filho do Tree
	 			    		"RD4_ITEM",;			//02 , 02 -> Item
	 			    		nOrderItem,;			//02 , 03 -> Ordem do Item
	 			    		"RD4_TREE",;			//02 , 04 -> Tree (Grupo Superior)
	 			    		nOrderTree,;			//02 , 05 -> Ordem do Tree
	 			    		"(RD4_CODIDE + ' - ' + RD4_DESC)",;			//02 , 06 -> Descricao do Item
	 			    		NIL,;					//02 , 07 -> Bloco para o DelOk
	 			    		"RD4SetPdFilter()",;	//02 , 08 -> Funcao Para Setar o Filtro
	 			    		NIL,;					//02 , 09 -> Bloco para Validar o Cut
	 			    		NIL,;					//02 , 10 -> Bloco para Get das Informacoes
	 			    		{|| PERMISSION[REVOKE]},;	//02 , 11 -> Campo para Get do Resource1
	 			    		{|| PERMISSION[REVOKE]},;	//02 , 12 -> Campo para Get do Resource2
	 			    		"RD4_FILIAL",;			//02 , 13 -> Campo de Filial
	 			    		"RD4_CODIGO",;			//02 , 14 -> Campo de Codigo
	 			    		bRd4TreeAddItem,;		//02 , 15 -> Bloco para Adicao de Novo Item
	 			    		"RD4",;					//02 , 16 -> Alias para a Consulta Padrao
	 			    	};
	 			    }
	
	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณMonta o Tree             												 ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	oTree:= OrgBldTree(	aDbTreeInfo,;		// Array Com Informacoes do tree
						STR0007,;			// Titulo do DBTree
						NIL,;				// Bloco TreeOk
						NIL,;				// Bloco TreeChange				
						NIL,;				// Bloco TreeInit
						.F.,;				// Logico Grava
						{aTreeCoords},;		// Array ObjSize
						100,;				// Numero WidthTree
						objTree:oWnd,; 			// Objeto Dialog
						.T.,;				// Logico MenuPopUp
						NIL,;				// Array MenuDisable
						aMenuPopUp,;		// Array MenuPopUp
						NIL,;				// Bloco TreeRightClick
						NIL,;				// Array FormalAdvSize
						@objTree,;		// 
						htbVisoes:GetItem(RDK->RDK_CODIGO))		// 
Return oTree

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ValidUser()
	Static cUsrOrGrp:= Space(6)
	
	If (cUsrOrGrp == getUsrOrGrp:cText)
		Return .T.
	EndIf
	
	If (cUsrOrGrp != getUsrOrGrp:cText) .AND. lChanged
		If (	Aviso(	STR0019,; //"Atencao"
						STR0020,; //"Nao foram gravadas as alteracoes apos edicao. Abandona sem gravar?"
						{STR0021, STR0022},;//"Sim" "Nao"
						2) == 2)
						
			Return .F.
		EndIf
	EndIF

	ResetForm()	
	
	cUsrOrGrp:= getUsrOrGrp:cText
	
	If Empty(getUsrOrGrp:cText)
		getNameOrDesc:cText:= ""
		fldPermissoes:SetOption(1)
				
		Return .T.
	EndIf

	If radTipo:nOption == 1
		getNameOrDesc:cText:= UsrRetName(getUsrOrGrp:cText)
	Else
		getNameOrDesc:cText:= GrpRetName(getUsrOrGrp:cText)	
	EndIf
	
	IF Empty(getNameOrDesc:cText)
		If radTipo:nOption == 1
			Alert(STR0023) //"Usuario nใo encontrado!"
		else
			Alert(STR0024) //"Grupo nใo encontrado!"
	 	EndIf               

		Return .F.
	EndIf
	
	fldPermissoes:SetOption(fldPermissoes:nOption)
Return .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ValidOrgVision()
	Static cCodOrg:= Space(GetSx3Cache("RDK_CODIGO", "X3_TAMANHO"))

	If getCdVisOrg:cText == cCodOrg
		Return .T.
	EndIf
	
	If Empty(getCdVisOrg:cText)
		htbVisOrg:SetItem(cCodOrg, OrgGetTreeNodes())
		OrgTreeCacheClear()
		
		cCodOrg:= getCdVisOrg:cText
		getDsVisOrg:cText:= ""
		dbtVisOrg:Reset() 
		
		Return .T.
	EndIf
	
	If !(RDK->(DBSeek(XFilial("RDK") + getCdVisOrg:cText)))
		Alert(STR0025)
		getDsVisOrg:cText:= ""
		Return .F.
	EndIf
	
	If RDK->RDK_HIERAR != '1'
		Alert(STR0026) //"Visao deve ser do tipo organizacional!"
		getCdVisOrg:cText:= Space(GetSx3Cache("RDK_CODIGO", "X3_TAMANHO"))
		getDsVisOrg:cText:= ""
		Return .F.
	EndIf
                             
	If !Empty(cCodOrg)
		htbVisOrg:SetItem(cCodOrg, OrgGetTreeNodes())
	EndIf

	cCodOrg:= getCdVisOrg:cText
	getDsVisOrg:cText:= RDK->RDK_DESC
	
	dbtVisOrg:= Org020Tree(dbtVisOrg,;
							{	aPosGetD[1] + 40,;
								aPosGetD[2] + 5,;
								aPosGetD[3] - 150,;
								aPosGetD[4] - 20,;
							},;
							@htbVisOrg)
							
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function DepPopMenu(oSender, nX, nY)
	//Local aDiff:= GetDiffPosition(oSender)
	Local oMenu:= OrgBldMnuTree(	{	{OemToAnsi(STR0014),	{|| MnuRevokeClick(@oSender) }, .T., NIL, TREE_PERMISSION[REVOKE]},;	//"Remover Permissใo"
										{OemToAnsi(STR0015),	{|| MnuGrantClick(@oSender) }, .T., NIL, TREE_PERMISSION[GRANT]},;		//"Conceder Permissao"
										{OemToAnsi(STR0018),	{|| MnuDenyClick(@oSender) }, .T., NIL, TREE_PERMISSION[DENY]}	}, {})	//"Negar Permissใo"

	
	oMenu:Activate( nX , nY , oSender:oWnd)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MnuRevokeClick(oGetDados)
	lChanged:= .T.	
	oGetDados:aCols[oGetDados:oBrowse:nAt, 1]:= GRID_PERMISSION[REVOKE] //"ORG_NONE"
	oGetDados:oBrowse:Refresh(.T.)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MnuGrantClick(oGetDados)
	lChanged:= .T.	
	oGetDados:aCols[oGetDados:oBrowse:nAt, 1]:= GRID_PERMISSION[GRANT] //"ORG_OK"
	oGetDados:oBrowse:Refresh(.T.)
Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MnuDenyClick(oGetDados)
	lChanged:= .T.	
	oGetDados:aCols[oGetDados:oBrowse:nAt, 1]:= GRID_PERMISSION[DENY] //"ORG_CANCEL"
	oGetDados:oBrowse:Refresh(.T.)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function TabChanged(nDest)
	If (nDest == TAB_ESTRUT_ORG)
		OrgSetTreeNodes(htbVisOrg:GetItem(getCdVisOrg:cText))
	ElseIf (nDest == TAB_DEPTO)	
		If !htbRows:ContainsKey("SQB")
			htbRows:SetItem("SQB", SelectPlainRows("SQB", ngdDepartamentos:aHeader, "3"))

			ApplyFilter(@ngdDepartamentos, "SQB", "")
		EndIf
	EndIf
	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RadioChanged()
	If radTipo:nOption == 1
		sayUsrOrGrp:SetText(STR0003 + ":") //"Usuario:"
		sayNameOrDesc:SetText(STR0005 + ":") //"Nome:")
		getUsrOrGrp:cF3:= "US2"
	Else
		sayUsrOrGrp:SetText(STR0004 + ":") //"Grupo:"
		sayNameOrDesc:SetText(STR0028 + ":")	//"Descri็ใo:"
		getUsrOrGrp:cF3:= "GRP"
	EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RadioWhen()
	If Type("getUsrOrGrp") == NIL
		Return .T.
	EndIF
	
	If Empty(getUsrOrGrp:cText)
		Return .T.
	EndIF	
Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FolderWhen()
Return !RadioWhen()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function BtnFilterClick(oGetDados)
	Static htbFilter:= Hashtable():New()
	Local cFilter:= ""
	Local cAlias:= IIF(oGetDados == ngdDepartamentos, "SQB", "RCL")
	
	If htbFilter:ContainsKey(cAlias)
		cFilter:= htbFilter:GetItem(cAlias)
	EndIf
	
	If (cAlias)->(GpFltBldExp(cAlias, frmConfigurador, @cFilter) )
		If cFilter!= htbFilter:GetItem(cAlias)
			htbFilter:SetItem(cAlias, cFilter)
	
			ApplyFilter(@oGetDados, cAlias, cFilter)
		EndIf
	EndIf
Return                                     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ApplyFilter(oGetDados, cAlias, cFilter)
	Local nCount
	Local arlFilter:= Arraylist():New()
	Local aRows:= htbRows:GetItem(cAlias)
	Local bVerify:= {|| .T.}

	If !Empty(cFilter)
		bVerify:= BuildVerifyBlock(cAlias, cFilter, oGetDados:aHeader)

		For nCount:= 1 To Len(aRows)	
			If Eval(bVerify, aRows[nCount]) == .T.
				arlFilter:Add(aRows[nCount])	
			EndIf
		Next
	
		oGetDados:aCols:= arlFilter:ToArray()
	Else
		oGetDados:aCols:= aRows
	EndIf
	
	oGetDados:Refresh()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function BuildVerifyBlock(cAlias, cFilter, aHeader)
	Local nCount
	
	cFilter:= StrTran(cFilter, cAlias + "->", "")

	For nCount:= 1 to Len(aHeader)
		If At(aHeader[nCount, 2], cFilter) > 0
			cFilter:= StrTran(cFilter, aHeader[nCount, 2], "aCells[" + AllTrim(Str(nCount)) + "]")
		EndIf
	Next
Return  &("{|aCells| " + cFilter + "}")



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GetIndexes(cAlias)
	Local arlReturn:= Arraylist():New()

	DbSelectArea("SIX")
	DbSetOrder(1)
	DBSeek(cAlias)
	While !SIX->(EOF()) .AND. SIX->INDICE == cAlias
		arlReturn:Add(STR0040 + SixDescricao())
		DBSkip()
	EndDo
Return arlReturn:ToArray()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GetBlankRow(cAlias, aColumns)
	Local nCount
	Local arlRow:= ArrayList():New()
            
	arlRow:Add(aColumns[1, __AHEADER_INITPAD__])
	
	For nCount:= 2 To Len(aColumns)
		arlRow:Add(GetValType(aColumns[nCount, __AHEADER_TYPE__] , aColumns[nCount, __AHEADER_WIDTH__]))
    Next
	    
    arlRow:Add(.F.)
Return {arlRow:ToArray()}



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function BtnSearchClick(oGetDados, nOption, cKey, cAlias)
	Local nPos
	Local nCount
	Local bSeek
	Local cSeek:= ""	
	Static htbIndex:= Hashtable():New()
	
	If !htbIndex:ContainsKey(cAlias + Str(nOption, 1))
		DbSelectArea("SIX")
		DbSetOrder(1)
		
		If DBSeek(cAlias + Str(nOption, 1))
			aFields:= StrToArray(SIX->CHAVE)
			  
			For nCount:= 1 To Len(aFields)
				nPos:= AScan(oGetDados:aHeader, {|aColumn| aColumn[__AHEADER_FIELD__] == aFields[nCount]}    )
				
				If (nPos > 0)		
					cSeek+= IIF(!Empty(cSeek), "+", "") + "aSearchRow["+ AllTrim(Str(nPos)) + "]"
				EndIf
			Next

			htbIndex:SetItem(cAlias + Str(nOption, 1), cSeek)
		Else
		    //Error
		EndIf
	Else		
		cSeek:= htbIndex:GetItem(cAlias + Str(nOption, 1))		
	EndIf

	bSeek:= &("{ |aSearchRow| SubStr(" + cSeek + ",1," + LTrim(Str(Len(cKey))) + ") == '" + cKey + "'}")
	nPos:= AScan(oGetDados:aCols, bSeek)
	
	If (nPos > 0)
		oGetDados:oBrowse:nAt:= nPos
		oGetDados:Refresh()
		oGetDados:oBrowse:SetFocus()
	Else
		Alert(STR0029) //"Registro nใo encontrado!"
	EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function	OpenTables()	
	DbSelectArea("RD4")
	DbSetOrder(1)	
	DbSelectArea("RDK")
	DbSetOrder(1)	
	DbSelectArea("SQB")
	DbSetOrder(1)	
	DbSelectArea("RCL")
	DbSetOrder(1)
	DbSelectArea("RBV")
	DbSetOrder(1)
	DbSelectArea("RBZ")
	DbSetOrder(1)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function	ResetStaticVariables()
	cUsrOrGrp:= Space(6)
	cCodOrg:= Space(GetSx3Cache("RDK_CODIGO", "X3_TAMANHO"))
	cCodCom:= Space(GetSx3Cache("RDK_CODIGO", "X3_TAMANHO"))
	
	lChanged:= .F.
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function	ResetChanges()
	lChanged:= .F.

	htbRows:Clear()
	htbVisOrg:Clear()	
/*	htbVisCom:Clear()*/
Return



Static Function	ResetForm()
	ResetChanges()
                     	
	getCdVisOrg:cText:= cCodOrg:= Space(Len(getCdVisOrg:cText))
	getDsVisOrg:cText:= Space(Len(getDsVisOrg:cText))
	dbtVisOrg:Reset()
	ngdDepartamentos:aCols := GetBlankRow("SQB", ngdDepartamentos:aHeader)
	ngdDepartamentos:Refresh()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FormInit()
	Local bGrava	:=	{ || BtnSaveClick()		}
	Local bOk		:=	{ || BtnOkClick()		}
	Local bCancel	:=	{ || BtnCancelClick()	}
	Local bRevoke	:=	{ || BtnRevokeClick()	}
	Local bGrant	:=	{ || BtnGrantClick(.F.)	}
	Local bDeny		:=	{ || BtnDenyClick(.F.)	}
	Local aButtons:= {}
	
	AAdd(aButtons, {"UNCHECKED",		bRevoke,	OemToAnsi(STR0030 + "...<F5>"), OemToAnsi(STR0030)})	//"Remover"
	AAdd(aButtons, {"CHECKED", 			bGrant,		OemToAnsi(STR0031 + "...<F6>"), OemToAnsi(STR0031)})	//"Conceder"
	AAdd(aButtons, {"NOCHECKED", 		bDeny,		OemToAnsi(STR0034 + "...<F7>"), OemToAnsi(STR0034)})	//"Negar"
	AAdd(aButtons, {"SALVAR",			bGrava,		OemToAnsi(STR0037 + "...<F9>"), OemToAnsi( STR0037 )})	//"Salvar"
	
	SetKey(VK_F5, bRevoke)
	SetKey(VK_F6, bGrant)
	SetKey(VK_F7, bDeny)
	SetKey(VK_F9, bGrava)			

	EnchoiceBar(frmConfigurador, bOk, bCancel, NIL, aButtons)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MakeDataSet(oHashtable)
	Local nCount
	Local aKeys:= oHashtable:GetKeys()
	Local oDataset:= ArrayList():New()
	
	For nCount:= 1 to Len(aKeys)	
		aTreeNodes:= htbVisOrg:GetItem(aKeys[nCount])
		
		If ValType(aTreeNodes) == "A" .AND. Len(aTreeNodes) > 0
			oDataset:Add(GetRowsRecursively(aTreeNodes[1]))
		EndIf
	Next
Return oDataset


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GetRowsRecursively(aTreeNodes)
	Local oReturn := Arraylist():New()
	Local nCount

	If aTreeNodes[NODE_ACOLS] != NIL
		oRow:= aTreeNodes[NODE_ACOLS]
		oRow:SetItem("COLBMP", aTreeNodes[NODE_RESOURCE1])
		
		oReturn:Add(oRow)		
	EndIf
	
	For nCount := 1 to Len(aTreeNodes[NODE_TREE])
		oRecursively:= GetRowsRecursively(aTreeNodes[NODE_TREE, nCount])

		If oRecursively:GetCount() > 0
			oReturn:AddRange(oRecursively:ToArray())
		EndIf
	Next
Return oReturn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function BtnSaveClick()
	Local nCount
	Local cAlias:= IIF(radTipo:nOption == 1	, "RBZ", "RBV")
	Local oDtsOrg

	If fldPermissoes:nOption == TAB_ESTRUT_ORG
		htbVisOrg:SetItem(getCdVisOrg:cText, OrgGetTreeNodes())
	EndIf
	
	oDtsOrg:= MakeDataset(htbVisOrg)
		
	Begin Transaction
		For nCount:= 1 to oDtsOrg:GetCount()
			SaveDataset(cAlias, "1", oDtsOrg:GetItem(nCount), "SQB", "RD4_CODIDE", "RD4_CODIGO")
		Next
		
		If htbRows:ContainsKey("SQB")
			SaveArray(cAlias, "3", htbRows:GetItem("SQB"), ngdDepartamentos:aHeader, "SQB", "QB_DEPTO")
		EndIf
		
	End Transaction   
	
	lChanged:= .F.

	MsgInfo(STR0038) //"Dados gravados com sucesso!"
Return
                   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function SaveArray(cAlias, cTipo, aRows, aHeader, cAliasIdent, cColIdent)
	Local aRow
	Local nCount
	Local lFound  
	Local nAcao
	Local nPosIdent:= AScan(aHeader, { |aColumn| aColumn[__AHEADER_FIELD__] == cColIdent })
	Local nPosBmp:= AScan(aHeader, { |aColumn| aColumn[__AHEADER_FIELD__] == "COLBMP" })
	Local cKey:= xFilial(cAlias) + getUsrOrGrp:cText + cTipo
	Local cEmpIde:= xEmpresa(cAliasIdent)
	Local cFilIde:= xFilial(cAliasIdent)

	DBSelectArea(cAlias)
	DBSetOrder(1)

	For nCount:= 1 To Len(aRows)
		aRow:= aRows[nCount]
		cIdent:= aRow[nPosIdent]
		nAcao:= GetAction(aRow[nPosBmp])
		lFound:= (cAlias)->(DBSeek(cKey + cEmpIde + cFilIde + cIdent))

		If nAcao == REVOKE
			If lFound
				RecLock(cAlias, .F., .T.)
				DBDelete()
				MsUnlock()
			EndIf
		Else
			RecLock(cAlias, !lFound)
			SetData(cAlias, cTipo, nAcao, cAliasIdent, cEmpIde, cFilIde, cIdent)
			MsUnlock()
		EndIf
	Next


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function SaveDataset(cAlias, cTipo, oDataset, cAliasIdent)
	Local aRow
	Local nCount
	Local lFound
	Local lPrimeira	:= .F.
	Local lPerTodos	:= .F.
	Local lRemTodos	:= .F.
	Local nAcao
	Local nAcaoHerd
	Local nIdentIni
	Local cKey:= xFilial(cAlias) + getUsrOrGrp:cText + cTipo
	Local cEmpIde:= xEmpresa(cAliasIdent)
	Local cFilIde:= xFilial(cAliasIdent)
	Local cEmpVis:= xEmpresa("RDK")
	Local cFilVis:= xFilial("RDK")
	Local nFieldSize:= GetSX3Cache(If(cTipo=="1", "QB_DEPTO", "RCL_POSTO"), "X3_TAMANHO")
	Local cIdentA := "000"
	Local cItem	:= ""
	Local lHeader := .F.
	
	DBSelectArea(cAlias)
	DBSetOrder(1)

	For nCount:= 1 To oDataset:GetCount()
		aRow:= oDataset:GetItem(nCount)		
		cIdent:= SubStr(aRow:GetItem("RD4_CODIDE"), 1, nFieldSize)
		cItem := substr(aRow:GetItem("RD4_CHAVE"),1,3)
		
		nAcao:= GetAction(aRow:GetItem("COLBMP")) 
		
		cVisao:= aRow:GetItem("RD4_CODIGO")
		lFound:= (cAlias)->(DBSeek(cKey + cEmpIde + cFilIde + cIdent + cEmpVis + cFilVis + cVisao))
		
		If substr(aRow:GetItem("RD4_CHAVE"),1,3) > cIdentA  .Or. (!lPerTodos .and. !lRemTodos)
			lHeader := .T.
			cIdentA := cItem
			lPerTodos := .F.
			lRemTodos := .F.
			If nAcao == 4
				lPerTodos := .T.
				nAcao := 2
				nAcaoHerd := 6
			Elseif nAcao == 5
				lRemTodos := .T.
				nAcao := 3      
				nAcaoHerd := 7  
			Endif
		Else
			lHeader := .F.
		EndIf	

		If  lPerTodos
			nAcao := 2
			nAcaoHerd := 6
		Elseif  lRemTodos
			nAcao := 3
			nAcaoHerd := 7
		Endif
		
		If nAcao == REVOKE .OR. nAcao == CHILD_GRANT .OR. nAcao == CHILD_DENY
			If lFound
				RecLock(cAlias, .F., .T.)
				DBDelete()
				MsUnlock()
			EndIf
		Else
			RecLock(cAlias, !lFound)
			
			If (lPerTodos .Or. lRemTodos ) .And. !lHeader 
				nAcao := nAcaoHerd
			Endif
			
			SetData(cAlias, cTipo, nAcao, cAliasIdent, cEmpIde, cFilIde, cIdent, cEmpVis, cFilVis, cVisao)
			MsUnlock()
		EndIf
		
	Next



Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GetAction(cBitmap)
	Local nReturn
	
	If	cBitmap == TREE_PERMISSION[GRANT] .OR.;
		cBitmap == GRID_PERMISSION[GRANT] .OR.;
		cBitmap == TREE_PERMISSION[CHILD_GRANT] 
		
	   nReturn:= GRANT
	   
	ElseIf cBitmap == TREE_PERMISSION[DENY] .OR.;
		   cBitmap == GRID_PERMISSION[DENY] .OR.;
		   cBitmap == TREE_PERMISSION[CHILD_DENY] 
		   
	   nReturn:= DENY
	   
	ElseIf cBitmap == TREE_PERMISSION[MASTER_GRANT]
	
	   nReturn:= MASTER_GRANT
	   
	ElseIf cBitmap == TREE_PERMISSION[MASTER_DENY]
	
	   nReturn:= MASTER_DENY
	   
	Else
	
	   nReturn:= REVOKE
	   
	EndIf
	
Return nReturn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function SetData(cAlias, cTipo, nAcao, cAliasIde, cEmpIde, cFilIde, cCodIde, cEmpVis, cFilVis,cCodVis)
	If cAlias == "RBZ"
		RBZ->RBZ_FILIAL:= xFilial("RBZ")
		RBZ->RBZ_CODUSR:= getUsrOrGrp:cText
		RBZ->RBZ_TIPO:= cTipo
		RBZ->RBZ_ACAO:= AllTrim(Str(nAcao))
		RBZ->RBZ_EMPIDE:= cEmpIde
		RBZ->RBZ_FILIDE:= cFilIde
		RBZ->RBZ_CODIDE:= cCodIde

		If cCodVis != NIL
			RBZ->RBZ_EMPVIS:= cEmpVis
			RBZ->RBZ_FILVIS:= cFilVis
			RBZ->RBZ_CODVIS:= cCodVis
		EndIf
	Else
		RBV->RBV_FILIAL:= xFilial("RBV")
		RBV->RBV_CODGRP:= getUsrOrGrp:cText
		RBV->RBV_TIPO:= cTipo
		RBV->RBV_ACAO:= AllTrim(Str(nAcao))
		RBV->RBV_EMPIDE:= cEmpIde
		RBV->RBV_FILIDE:= cFilIde
		RBV->RBV_CODIDE:= cCodIde

		If cCodVis != NIL
			RBV->RBV_EMPVIS:= cEmpVis
			RBV->RBV_FILVIS:= cFilVis
			RBV->RBV_CODVIS:= cCodVis
		EndIf
	EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function BtnOkClick()
	If lChanged
		BtnSaveClick()
	EndIf
	
	frmConfigurador:End()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function BtnCancelClick()
	If lChanged
		If (Aviso(	STR0019,; 				//"Atencao"
					STR0020,; 				//"Nao foram gravadas as alteracoes apos edi็ใo. Abandona sem gravar?"
					{STR0021, STR0022},;	//"Sim" //"Nao"
					2) == 2)
			Return
		EndIf
	EndIf
	
	frmConfigurador:End()
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  28/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function xEmpresa(cAlias)
	Local cReturn := cEmpAnt
	Local aSaveArea := GetArea()
	Local aSM0Area := SM0->(GetArea())
	Local iEmp :=0
	
	If SM0->(RecCount()) == 1
		For iEmp := 1 to Len(aListaEmpresas)
			If aListaEmpresas[iEmp][SM0_EMPRESA] != cEmpAnt
				If !EqualFullName(cAlias , cEmpAnt , aListaEmpresas[iEmp][SM0_EMPRESA])
					cReturn:= cEmpAnt
					Exit
				EndIf
			EndIf	                   
		Next iEmp
	EndIF

	RestArea(aSM0Area)
	RestArea(aSaveArea)
Return cReturn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  28/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function SelectPlainRows(cAliasIde, aHeader, cTipo)
	Local cQuery
	Local aCells	
	Local nCount
	Local cAliasPerm := IIF(radTipo:nOption == 1, "RBZ", "RBV")
	Local cAlias := GetNextAlias()
	Local oRows:= ArrayList():New()
	
	cQuery:= "SELECT"
	cQuery+= " CASE WHEN " + cAliasPerm + "." + cAliasPerm + "_ACAO IS NULL THEN '1' ELSE " + cAliasPerm + "." + cAliasPerm + "_ACAO END AS COLBMP "
	
	For nCount:= 2 to Len(aHeader)
		If Upper(aHeader[nCount, __AHEADER_CONTEXT__]) != "V"
			cQuery+= ", " + cAliasIde + "." + aHeader[nCount, __AHEADER_FIELD__]
		EndIf
	Next

	cQuery+= " "
	cQuery+= "FROM "
	cQuery+= " " + RetSqlName(cAliasIde) + " " + cAliasIde + " "
	cQuery+= "LEFT OUTER JOIN " + RetSqlName(cAliasPerm) + " " + cAliasPerm + " "
	cQuery+= "ON " + cAliasPerm + "." + cAliasPerm + "_CODIDE = " + cAliasIde + "." + IIF(cAliasIde == "SQB", "QB_DEPTO", "RCL_POSTO") + " "
	cQuery+= "AND " + cAliasPerm + "." + cAliasPerm + "_FILIDE = " + cAliasIde + "." + IIF(cAliasIde == "SQB", "QB_FILIAL", "RCL_FILIAL") + " "
	cQuery+= "AND " + cAliasPerm + "." + cAliasPerm + "_EMPIDE = '" + xEmpresa(cAliasIde) + "' "
	cQuery+= "AND " + cAliasPerm + "." + cAliasPerm + "_TIPO = '" + cTipo + "' "	
	cQuery+= "AND " + cAliasPerm + "." + IIF(cAliasPerm == "RBZ", "RBZ_CODUSR", "RBV_CODGRP") + " = '" + getUsrOrGrp:cText + "' "
	cQuery+= "AND " + cAliasPerm + ".D_E_L_E_T_ = ' ' "	
	cQuery+= "WHERE "
	cQuery+= " " + cAliasIde + ".D_E_L_E_T_ = ' '"

	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery), cAlias,.T.,.T.)	

	                
	While !(cAlias)->(Eof())
		aCells:= Array(Len(aHeader) + 1)
		aCells[Len(aCells)]:= .F.
		aCells[1]:= GRID_PERMISSION[Val((cAlias)->COLBMP)]
		
		For nCount:= 2 to Len(aHeader)
			If Upper(aHeader[nCount, __AHEADER_CONTEXT__]) != "V"
				aCells[nCount]:= (cAlias)->(__ExecMacro(aHeader[nCount, __AHEADER_FIELD__]))
			Else
				IF !Empty(aHeader[nCount , __AHEADER_INITPAD__ ] )
					IF !CheckExecForm( __ExecMacro( " { || aCells[nCount] := " + aHeader[nCount , __AHEADER_INITPAD__ ] + " } " ) , .F. )
						aCells[nCount] := GetValType( aHeader[nCount, __AHEADER_TYPE__] , aHeader[nCount, __AHEADER_WIDTH__] )
					EndIf
				Else
					aCells[nCount] := GetValType( aHeader[nCount, __AHEADER_TYPE__] , aHeader[nCount, __AHEADER_WIDTH__] )
				EndIf
			EndIf
		Next
		
		oRows:Add(aCells)

		(cAlias)->(DBSkip())
	EndDo
Return oRows:ToArray()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  28/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function BtnRevokeClick()
	If OrgGetTreeNodes() == NIL .AND.;
	   (fldPermissoes:nOption == TAB_ESTRUT_ORG)
		Return
	EndIf
	
	DO CASE
		CASE fldPermissoes:nOption == TAB_ESTRUT_ORG
			OrgTreeRevoke(@dbtVisOrg, .F.)				
		CASE fldPermissoes:nOption == TAB_DEPTO
			MnuRevokeClick(@ngdDepartamentos)
	END CASE
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  28/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function BtnGrantClick(lInherited)
	If OrgGetTreeNodes() == NIL .AND.;
	   (fldPermissoes:nOption == TAB_ESTRUT_ORG)
		Return
	EndIf
	
	If lInherited .AND.;
	   (fldPermissoes:nOption == TAB_DEPTO)
		MsgStop(STR0039) //"Op็ใo disponํvel apenas para permissoes por estrutura!"
		Return
	EndIf

	DO CASE
		CASE fldPermissoes:nOption == TAB_ESTRUT_ORG
			OrgTreeGrant(@dbtVisOrg, lInherited)
		CASE fldPermissoes:nOption == TAB_DEPTO
			MnuGrantClick(@ngdDepartamentos)
	END CASE
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  28/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function BtnDenyClick(lInherited)
	If OrgGetTreeNodes() == NIL .AND.;
	   (fldPermissoes:nOption == TAB_ESTRUT_ORG)
		Return
	EndIf
	
	If lInherited .AND.;
	   (fldPermissoes:nOption == TAB_DEPTO)
		MsgStop(STR0039) //"Op็ใo disponํvel apenas para permissoes por estrutura!"
		Return
	EndIf
	
	DO CASE
		CASE fldPermissoes:nOption == TAB_ESTRUT_ORG
			OrgTreeDeny(@dbtVisOrg, lInherited)
		CASE fldPermissoes:nOption == TAB_DEPTO
			MnuDenyClick(@ngdDepartamentos)
	END CASE
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function SelectTreeRows(cAliasIde, aHeader, cTipo, cCodVisao, cDescVisao, nRecVisao)
	Local cQuery
	Local oRows:= ArrayList():New()
	Local oCells	
	Local nCount
	Local cAliasPerm := IIF(radTipo:nOption == 1, "RBZ", "RBV")
	Local cAlias := GetNextAlias()
	Local xValue
	
	cQuery:= "SELECT"
	cQuery+= " CASE WHEN " + cAliasPerm + "." + cAliasPerm + "_ACAO IS NULL THEN '1' ELSE " + cAliasPerm + "." + cAliasPerm + "_ACAO END AS COLBMP"
	
	For nCount:= 2 to Len(aHeader)
		If Upper(aHeader[nCount, __AHEADER_CONTEXT__]) != "V"
			cQuery+= ", RD4." + aHeader[nCount, __AHEADER_FIELD__]
		EndIf
	Next

	cQuery+= ", RD4.R_E_C_N_O_ "
	cQuery+= "FROM " + RetSqlName("RD4") + " RD4 "
	cQuery+= "INNER JOIN " + RetSqlName(cAliasIde) + " " + cAliasIde
	cQuery+= " ON RD4.RD4_EMPIDE = '" + xEmpresa(cAliasIde) + "' "
	cQuery+= "AND RD4.RD4_FILIDE = " + cAliasIde + "." + IIF(cAliasIde == "SQB", "QB_FILIAL", "RCL_FILIAL") + " "
	cQuery+= "AND RD4.RD4_CODIDE = " + cAliasIde + "." + IIF(cAliasIde == "SQB", "QB_DEPTO", "RCL_POSTO") + " "
	cQuery+= "LEFT OUTER JOIN " + RetSqlName(cAliasPerm) + " " + cAliasPerm
	cQuery+= " ON " + cAliasPerm + "." + cAliasPerm + "_CODIDE = " + cAliasIde + "." + IIF(cAliasIde == "SQB", "QB_DEPTO", "RCL_POSTO") + " "
	cQuery+= "AND " + cAliasPerm + "." + cAliasPerm + "_FILIDE = " + cAliasIde + "." + IIF(cAliasIde == "SQB", "QB_FILIAL", "RCL_FILIAL") + " "
	cQuery+= "AND " + cAliasPerm + "." + cAliasPerm + "_EMPIDE = '" + xEmpresa(cAliasIde) + "' "
	cQuery+= "AND " + cAliasPerm + "." + cAliasPerm + "_CODVIS = RD4.RD4_CODIGO "
	cQuery+= "AND " + cAliasPerm + "." + cAliasPerm + "_FILVIS = RD4.RD4_FILIAL "
	cQuery+= "AND " + cAliasPerm + "." + cAliasPerm + "_EMPVIS = '" + xEmpresa("RD4") + "' "	
	cQuery+= "AND " + cAliasPerm + "." + cAliasPerm + "_TIPO = '" + cTipo + "' "	
	cQuery+= "AND " + cAliasPerm + "." + IIF(cAliasPerm == "RBZ", "RBZ_CODUSR", "RBV_CODGRP") + " = '" + getUsrOrGrp:cText + "' "
	cQuery+= "AND " + cAliasPerm + "." + "D_E_L_E_T_ = ' ' "
	cQuery+= "WHERE "
	cQuery+= " RD4.RD4_CODIGO = '" + cCodVisao + "' AND "	
	cQuery+= " RD4.RD4_TREE <> '' AND RD4.D_E_L_E_T_ = ' ' AND "
	cQuery+= " " + cAliasIde + ".D_E_L_E_T_ = ' ' "
	cQuery+= "ORDER BY RD4_CHAVE"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery), cAlias,.T.,.T.)		
             
	While !(cAlias)->(Eof())	
		oCells:= HashTable():New()
		oCells:SetItem("COLBMP", TREE_PERMISSION[Val((cAlias)->COLBMP)])
		
		For nCount:= 2 to Len(aHeader)
			xValue:= NIL
			
			If Upper(aHeader[nCount, __AHEADER_CONTEXT__]) != "V"
				xValue:= (cAlias)->(__ExecMacro(aHeader[nCount, __AHEADER_FIELD__]))
			Else
				IF !Empty(aHeader[nCount , __AHEADER_INITPAD__ ] )
					CheckExecForm( __ExecMacro( " { || xValue := " + aHeader[nCount , __AHEADER_INITPAD__ ] + " } " ) , .F. )
				EndIf
			EndIf

			If xValue != NIL
				oCells:SetItem(aHeader[nCount, __AHEADER_FIELD__], xValue)
			Else
				oCells:SetItem(aHeader[nCount, __AHEADER_FIELD__], GetValType( aHeader[nCount, __AHEADER_TYPE__] , aHeader[nCount, __AHEADER_WIDTH__] ) )
			EndIf
		Next

		oCells:SetItem("RECNO", (cAlias)->R_E_C_N_O_)
		oRows:Add(oCells)

		(cAlias)->(DBSkip())	
	EndDo

Return BuildTree(oRows, cDescVisao, nRecVisao)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function BuildTree(oRows, cDescVisao, nRecVisao)
	Local cCodNode:= Replicate("0", GetSx3Cache("RD4_TREE", "X3_TAMANHO"))
	Local aNodeMaster:= CreateNewNode(	cCodNode,; 
										cCodNode,;
										cDescVisao,; 
										"NORMAS",; 
										nRecVisao)
	
	AddRowsRecursively(	@aNodeMaster[NODE_TREE],;
						@oRows,;
						"",;
						TREE_PERMISSION[REVOKE])
Return {aNodeMaster}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function AddRowsRecursively(aNodes, oRows, cChave, cMasterResource)
	Local nCount
	Local cTempKey
	Local oChildNodes:= ArrayList():New()
	Local aNewNode
	Local cResouce
	Local cItem
	Local cPrompt
	
	For nCount:= oRows:GetCount() to 1 step -1		  
		cTempKey:= AllTrim(oRows:GetItem(nCount):GetItem("RD4_CHAVE"))
		
		If SubStr(cTempKey, 1, Len(cTempKey) - 3) == cChave
			oChildNodes:Add(oRows:GetItem(nCount))
			oRows:RemoveAt(nCount)
		EndIf	
	Next
	
	For nCount:= 1 to oChildNodes:GetCount()
		oRow:= oChildNodes:GetItem(nCount)
	
		cItem:= oRow:GetItem("RD4_ITEM")
		cPrompt:= PadR(cItem + " - " + oRow:GetItem("RD4_DESC"),  NODE_DESC_SIZE )
		cResouce:= oRow:GetItem("COLBMP")
		
		If (;
				cMasterResource == TREE_PERMISSION[MASTER_GRANT] .AND.;
			   (cResouce == TREE_PERMISSION[REVOKE] .OR.;
			    cResouce == TREE_PERMISSION[GRANT] .OR.;
			    cResouce == TREE_PERMISSION[MASTER_GRANT]	);
		    )
			cResouce:= PERMISSION[CHILD_GRANT]
		ElseIf (cMasterResource == TREE_PERMISSION[MASTER_DENY])
			cResouce:= PERMISSION[CHILD_DENY]
		EndIf
	

		aNewNode:= CreateNewNode(	cItem,; 
									oRow:GetItem("RD4_TREE"),;
									cPrompt,; 
									cResouce,;
									oRow:GetItem("RECNO"),;
									oRow)
									
		If cResouce == PERMISSION[MASTER_GRANT] .OR.;
		   cResouce == PERMISSION[MASTER_DENY]
			cMasterResource := cResouce
		EndIf

		AddRowsRecursively(	@aNewNode[NODE_TREE],;
							@oRows,;
							AllTrim(oChildNodes:GetItem(nCount):GetItem("RD4_CHAVE")),;
							cMasterResource)

		AAdd(aNodes, aNewNode)
	Next	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณRogerio Ribeiro     บ Data ณ  30/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function CreateNewNode(	cInferior	,;
								cSuperior	,;
								cPrompt		,;
								cResource	,;
								nRecno		,;
								oRow		;
						  )
	Local aNode := Array(NODE_ELEMENTS)
	Default cSuperior:= cInferior

	aNode[ NODE_INFERIOR 	]	:= cInferior
	aNode[ NODE_SUPERIOR 	]	:= cSuperior
	aNode[ NODE_PROMPT   	]	:= cPrompt
	aNode[ NODE_ACOLS	 	]	:= oRow
	aNode[ NODE_ACTIVE   	]	:= .T.
	aNode[ NODE_TREE     	]	:= {}
	aNode[ NODE_SEQ			]	:= ""
	aNode[ NODE_RESOURCE1	]	:= cResource
	aNode[ NODE_RESOURCE2	]	:= cResource
	aNode[ NODE_RECNO		] 	:= nRecno
Return aNode

/*/
ฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟ
ณFun…o    ณRd4TreeAddItemณAutorณMarinaldo de Jesus   ณ Data ณ31/08/2004ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤด
ณDescri…o ณFuncao para Adicao de Novo Item no Tree                     ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณSintaxe   ณ<Vide Parametros Formais>                                    ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณParametrosณ<Vide Parametros Formais>                                    ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณUso       ณAPDA010                                                        ณ
ภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
Static Function Rd4TreeAddItem( cAlias , nReg , cLastItemNum )

/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณSeta o Ultimo Numero Utilizado                                   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
Rd4ItemSet( cLastItemNum )

/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณExecuta a Rotina de Alteracao para Inclusao de Novos Itens       ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
Apda010Alt( cAlias , nReg , GD_INSERT + GD_UPDATE )

/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณLock do Registro do RDK                                       ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
WhileNoLock( "RDK" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetRdk )

/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณLock do Registro do RD4                                       ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
WhileNoLock( "RD4" , NIL , NIL , 1 , 1 , .T. , 10 , 5 , bGetRd4 )

Return( NIL )
