#include "protheus.ch"
#include "fwmvcdef.ch"
#include "fwbrowse.ch"
#include "agrac002.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} AGRAC002
Consulta de Saída de Pluma
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------
Function AGRAC002()
	Local oDLg		:= Nil
	Local oSize		:= Nil
	Local oPnl		:= Nil
	Local oBrw		:= Nil
	Local aCoors	:= FWGetDialogSize( oMainWnd )
	Local bKeyF12	:= {|| If( Pergunte("AGRAC002", .T.), AG615AtuBw(@oBrw), .T. ) }
	Local aIndex	:= {}
	Local cQuery	:= ""
	
	//variavel de unidade de beneficiamento
	Private cUserBenf 	:= "" 
	Private lRet		:= .F.
	
	If !Pergunte("AGRAC002", .T.)
		Return
	EndIf
	
	//verifica se possui unidade de beneficiamento
	lRet := AGC002Usu()	
	//If !lRet
	//	Return
	//EndIf
		
	cQuery := AG615Query()
//-------------------------------------------------------------------
// Indica os índices da tabela temporária
//-------------------------------------------------------------------
	Aadd( aIndex, "DXS_CODIGO" )

//- Coordenadas da area total da Dialog
	oSize := FWDefSize():New(.T.)
	oSize:AddObject('TOTAL',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:aMargins := {3,3,3,3}
	oSize:lProp 	:= .T.
	oSize:Process()

	DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] OF oMainWnd PIXEL
	@ oSize:aPosObj[1,1],oSize:aPosObj[1,2] MSPANEL oPnl SIZE oSize:aPosObj[1,4], oSize:aPosObj[1,3] OF oDlg
	
	//-------------------------------------------------------------------
	// Define o Browse
	//-------------------------------------------------------------------
	DEFINE FWFORMBROWSE oBrw DATA QUERY ALIAS "TRB" QUERY cQuery INDEXQUERY aIndex DESCRIPTION STR0001 OF oDlg
	oBrw:DisableDetails()
	oBrw:SetFieldFilter(CampsFiltr())
	oBrw:SetUseFilter(.T.)
	oBrw:SetParam(bKeyF12) // Seta tecla F12
	oBrw:AddButton("Sair",{||oDlg:End()},,,,,,'10')
		
	ADD COLUMN oColumn DATA { || DXS_CODIGO } TITLE STR0002    	SIZE  TamSX3("DXS_CODIGO")[1]  ;
		PICTURE PesqPict("DXS","DXS_CODIGO") TYPE TamSX3("DXS_CODIGO")[3]	OF oBrw
	ADD COLUMN oColumn DATA { || DXT_ITEM   } TITLE STR0003   	SIZE  TamSX3("DXT_ITEM")[1]  	;
		PICTURE PesqPict("DXT","DXT_ITEM")   TYPE TamSX3("DXT_ITEM")[3]	OF oBrw
	ADD COLUMN oColumn DATA { || DXT_NUMIE  } TITLE STR0004    	SIZE  TamSX3("DXT_NUMIE")[1]  	;
		PICTURE PesqPict("DXT","DXT_NUMIE")  TYPE TamSX3("DXT_NUMIE")[3]	OF oBrw
	ADD COLUMN oColumn DATA { || DXT_ITEMIE } TITLE STR0005	  	SIZE  TamSX3("DXT_ITEMIE")[1]  	;
		PICTURE PesqPict("DXT","DXT_ITEMIE") TYPE TamSX3("DXT_ITEMIE")[3]	OF oBrw
	ADD COLUMN oColumn DATA { || ADA_CODCLI } TITLE STR0006		SIZE  TamSX3("ADA_CODCLI")[1]  	;
		PICTURE PesqPict("ADA","ADA_CODCLI") TYPE TamSX3("ADA_CODCLI")[3]	OF oBrw
	ADD COLUMN oColumn DATA { || D2_CLIENTE } TITLE STR0007 	SIZE  TamSX3("D2_CLIENTE")[1]  	;
		PICTURE PesqPict("SD2","D2_CLIENTE") TYPE TamSX3("D2_CLIENTE")[3]	OF oBrw
	ADD COLUMN oColumn DATA { || StoD(DXS_DATA)   } TITLE STR0008	SIZE  TamSX3("DXS_DATA")[1] ;
		PICTURE PesqPict("DXS","DXS_DATA")   TYPE TamSX3("DXS_DATA")[3]	OF oBrw
	ADD COLUMN oColumn DATA { || DXS_NUMNFS } TITLE STR0009		SIZE  TamSX3("DXS_NUMNFS")[1]  	;
		PICTURE PesqPict("DXS","DXS_NUMNFS") TYPE TamSX3("DXS_NUMNFS")[3]	OF oBrw
	ADD COLUMN oColumn DATA { || DXS_SERNFS } TITLE STR0010		SIZE  TamSX3("DXS_SERNFS")[1]  	;
		PICTURE PesqPict("DXS","DXS_SERNFS") TYPE TamSX3("DXS_SERNFS")[3]	OF oBrw
	ADD COLUMN oColumn DATA { || DXS_PLACA  } TITLE STR0011		SIZE  TamSX3("DXS_PLACA")[1]  	;
		PICTURE PesqPict("DXS","DXS_PLACA")  TYPE TamSX3("DXS_PLACA")[3]	OF oBrw
	ADD COLUMN oColumn DATA { || DXT_QUANT  } TITLE STR0012		SIZE  TamSX3("DXT_QUANT")[1]  	;
		PICTURE PesqPict("DXT","DXT_QUANT")  TYPE TamSX3("DXT_QUANT")[3]	OF oBrw
	ADD COLUMN oColumn DATA { || DXT_BLOCO  } TITLE STR0013 	SIZE  TamSX3("DXT_BLOCO")[1]  	;
		PICTURE PesqPict("DXT","DXT_BLOCO")  TYPE TamSX3("DXT_BLOCO")[3]	OF oBrw
	ADD COLUMN oColumn DATA { || D2_QUANT   } TITLE STR0014 	SIZE  TamSX3("D2_QUANT")[1]  	;
		PICTURE PesqPict("SD2","D2_QUANT")   TYPE TamSX3("D2_QUANT")[3]	OF oBrw
	ADD COLUMN oColumn DATA { || D2_PRCVEN  } TITLE STR0015 	SIZE  TamSX3("D2_PRCVEN")[1]  	;
		PICTURE PesqPict("SD2","D2_PRCVEN")  TYPE TamSX3("D2_PRCVEN")[3]	OF oBrw
	ADD COLUMN oColumn DATA { || D2_TOTAL   } TITLE STR0016		SIZE  TamSX3("D2_TOTAL")[1]  	;
		PICTURE PesqPict("SD2","D2_TOTAL")   TYPE TamSX3("D2_TOTAL")[3]	OF oBrw
	//-------------------------------------------------------------------
	// Ativação do Browse
	//-------------------------------------------------------------------
	ACTIVATE FWFORMBROWSE oBrw
	ACTIVATE MSDIALOG oDlg CENTER
Return

Static Function CampsFiltr()
	Local aCampos := {}
	Local aCmpsTab := {}
	
	aCmpsTab := TamSX3("DXS_CODIGO");AAdd(aCampos,{"DXS_CODIGO", DescriSX3("DXS_CODIGO"),aCmpsTab[3] ,aCmpsTab[1],aCmpsTab[2], PesqPict("DXS","DXS_CODIGO")})
	aCmpsTab := TamSX3("DXT_ITEM"  );AAdd(aCampos,{"DXT_ITEM"  , DescriSX3("DXT_ITEM"  ),aCmpsTab[3] ,aCmpsTab[1],aCmpsTab[2], PesqPict("DXT","DXT_ITEM"  )})
	aCmpsTab := TamSX3("DXT_NUMIE" );AAdd(aCampos,{"DXT_NUMIE" , DescriSX3("DXT_NUMIE" ),aCmpsTab[3] ,aCmpsTab[1],aCmpsTab[2], PesqPict("DXT","DXT_NUMIE" )})
	aCmpsTab := TamSX3("DXT_ITEMIE");AAdd(aCampos,{"DXT_ITEMIE", DescriSX3("DXT_ITEMIE"),aCmpsTab[3] ,aCmpsTab[1],aCmpsTab[2], PesqPict("DXT","DXT_ITEMIE")})
	                                                                                   
	aCmpsTab := TamSX3("ADA_CODCLI");AAdd(aCampos,{"ADA_CODCLI", DescriSX3("ADA_CODCLI"),aCmpsTab[3] ,aCmpsTab[1],aCmpsTab[2], PesqPict("ADA","ADA_CODCLI")})
	aCmpsTab := TamSX3("D2_CLIENTE");AAdd(aCampos,{"D2_CLIENTE", DescriSX3("D2_CLIENTE"),aCmpsTab[3] ,aCmpsTab[1],aCmpsTab[2], PesqPict("SD2","D2_CLIENTE")})
	aCmpsTab := TamSX3("DXS_DATA"  );AAdd(aCampos,{"DXS_DATA"  , DescriSX3("DXS_DATA"  ),aCmpsTab[3] ,aCmpsTab[1],aCmpsTab[2], PesqPict("DXS","DXS_DATA"  )})
	aCmpsTab := TamSX3("DXS_NUMNFS");AAdd(aCampos,{"DXS_NUMNFS", DescriSX3("DXS_NUMNFS"),aCmpsTab[3] ,aCmpsTab[1],aCmpsTab[2], PesqPict("DXS","DXS_NUMNFS")})
	                                                                                 
	aCmpsTab := TamSX3("DXS_SERNFS");AAdd(aCampos,{"DXS_SERNFS", DescriSX3("DXS_SERNFS"),aCmpsTab[3] ,aCmpsTab[1],aCmpsTab[2], PesqPict("DXS","DXS_SERNFS")})
	aCmpsTab := TamSX3("DXS_PLACA" );AAdd(aCampos,{"DXS_PLACA" , DescriSX3("DXS_PLACA" ),aCmpsTab[3] ,aCmpsTab[1],aCmpsTab[2], PesqPict("DXS","DXS_PLACA" )})
	aCmpsTab := TamSX3("DXT_QUANT" );AAdd(aCampos,{"DXT_QUANT" , DescriSX3("DXT_QUANT" ),aCmpsTab[3] ,aCmpsTab[1],aCmpsTab[2], PesqPict("DXT","DXT_QUANT" )})
	aCmpsTab := TamSX3("DXT_BLOCO" );AAdd(aCampos,{"DXT_BLOCO" , DescriSX3("DXT_BLOCO" ),aCmpsTab[3] ,aCmpsTab[1],aCmpsTab[2], PesqPict("DXT","DXT_BLOCO" )})
	                                                                                  
	aCmpsTab := TamSX3("D2_QUANT"  );AAdd(aCampos,{"D2_QUANT"  , DescriSX3("D2_QUANT"  ),aCmpsTab[3] ,aCmpsTab[1],aCmpsTab[2], PesqPict("SD2","D2_QUANT"  )})
	aCmpsTab := TamSX3("D2_PRCVEN" );AAdd(aCampos,{"D2_PRCVEN" , DescriSX3("D2_PRCVEN" ),aCmpsTab[3] ,aCmpsTab[1],aCmpsTab[2], PesqPict("SD2","D2_PRCVEN" )})
	aCmpsTab := TamSX3("D2_TOTAL"  );AAdd(aCampos,{"D2_TOTAL"  , DescriSX3("D2_TOTAL"  ),aCmpsTab[3] ,aCmpsTab[1],aCmpsTab[2], PesqPict("SD2","D2_TOTAL"  )})
	
Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} AG615Query
Função para montar query de consulta
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------
Static Function AG615Query()
	Local cQuery:= ""
		
//DXS_CODIGO
	cQuery := " SELECT DXS.DXS_CODIGO,DXT.DXT_ITEM,DXT.DXT_NUMIE,DXT.DXT_ITEMIE,ADA_CODCLI,ADA_SAFRA, "
	cQuery += " COALESCE(SD2.D2_CLIENTE,'') D2_CLIENTE ,DXS.DXS_DATA,DXS.DXS_CODCTP,DXS.DXS_NUMNFS,DXS.DXS_SERNFS, "
	cQuery += " DXS.DXS_PLACA,DXT.DXT_QUANT, DXT.DXT_BLOCO, ISNULL(SD2.D2_QUANT, 0) D2_QUANT,"
	cQuery += " ISNULL(SD2.D2_PRCVEN, 0) D2_PRCVEN,ISNULL(SD2.D2_TOTAL, 0)D2_TOTAL"
	cQuery += " FROM "+ RetSqlName("DXS") +" DXS "
	cQuery += " INNER JOIN "+ RetSqlName("DXT") +" DXT  ON DXS.DXS_CODIGO = DXT.DXT_CODIGO AND DXT.DXT_FILIAL = '"+xFilial("DXT")+"' "
	cQuery += " INNER JOIN "+ RetSqlName("ADA") +" ADA  ON ADA.ADA_NUMCTR = DXS.DXS_CODCTP  AND ADA.ADA_FILIAL = '"+xFilial("ADA")+"' "
	cQuery += " LEFT JOIN " + RetSqlName("SD2") +" SD2  ON DXS.DXS_FILIAL = '"+xFilial("SD2")+"'  and  SD2.D2_DOC = DXS.DXS_NUMNFS AND "
	cQuery += " SD2.D2_SERIE = DXS.DXS_SERNFS  and SD2.D2_CLIENTE = DXS.DXS_CLIENT AND SD2.D2_LOJA =  DXS.DXS_LJCLI and SD2.D2_ITEM = DXT.DXT_item"
	cQuery += " WHERE DXS.D_E_L_E_T_ = '' AND DXT.D_E_L_E_T_ = '' AND ADA.D_E_L_E_T_ = '' "
	
	If !Empty(mv_par01)
		cQuery += " AND ADA.ADA_SAFRA =  '"+ mv_par01 +"'"
	EndIf

	If !Empty(mv_par02) .And. !Empty(mv_par03)
		cQuery += " AND DXS.DXS_DATA BETWEEN '"+DTOS(mv_par02)+"' AND '"+DTOS(mv_par03)+"'
	EndIf

	If mv_par04 <> 1
		cQuery += " AND DXS.DXS_NUMNFS = '' "
	EndIf

	If mv_par05 <> 1
		cQuery += " AND DXS.DXS_NUMNFS <> '' "
	EndIf

	If !Empty(mv_par06)
		cQuery += " AND SD2.D2_CLIENTE =  '"+ mv_par06 +"'"
	EndIf

	If !Empty(mv_par08)
		cQuery += " AND DXS.DXS_CODCTP =  '"+ mv_par08+"'"
	EndIf

	If !Empty(mv_par09) .And. !Empty(mv_par10)
		cQuery += " AND DXS.DXS_NUMNFS BETWEEN '"+ mv_par09 +"' AND '"+ mv_par10 +"'
	EndIf

	If !Empty(mv_par11)
		cQuery += " AND DXT.DXT_NUMIE  = '"+ mv_par11 +"'"
	EndIf

	cQuery := ChangeQuery( cQuery )

Return cQuery

Static Function DescriSX3(cCampo)
	Local cDesc := ""
	Local AreaSX3
	
	dbSelectArea("SX3")
	dbSetOrder(2)
	AreaSX3 := SX3->( GetArea() )
	SX3->(MsSeek(cCampo))
	cDesc := X3Descric(cCampo)
	
	RestArea(AreaSX3)
Return cDesc
//-------------------------------------------------------------------
/*/{Protheus.doc} AG615AtuBw
Função para atualizar browser ao modificar os paramentros.
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------
Static Function AG615AtuBw(oBrw)
	
	oBrw:Data():DeActivate()
	oBrw:SetQuery(AG615Query())
	oBrw:Data():Activate()
	oBrw:GoTo( 1, .T.)
	oBrw:UpdateBrowse()
	oBrw:Refresh()

Return .T.

//-----------------------------------------------------------
/*{Protheus.doc} AGC002Usu
Validação a inicialização do modelo de dados

@param..: lRet
@author.: Ana Laura Olegini
@since..: 23/06/2015
@Uso....: AGRAC002
*/
//-----------------------------------------------------------
Static Function AGC002Usu()
	Local cCodUser 	:= RetCodUsr()
	dbSelectArea("NKF")
	dbSetOrder(1)
	If !MsSeek(xFilial("NKF")+cCodUser)	
		//Help('',1,STR0017,,STR0018,1) //"Atenção"###"Usuário não possui Unidade de Beneficiamento cadastrado."
		lRet := .F.
	Else
		cUserBenf := NKF->NKF_CODUNB
		lRet := .T.
	EndIf
Return lRet