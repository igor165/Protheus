#INCLUDE "Protheus.ch"
#INCLUDE "Fwmvcdef.ch"
#INCLUDE "Fwbrowse.ch"
#INCLUDE "Agrac003.ch"

Static __oArqTemp := NIL
 
//-------------------------------------------------------------------
/*/{Protheus.doc} AGRAC003
Consulta de Classificação HVI
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------
Function AGRAC003()
	Local oDLg			:= Nil,nx
	Local aCoors		:= FWGetDialogSize( oMainWnd )
	
	Local bKeyF12  		:= {|| If( Pergunte("AGRAC003", .T.), ( cAliasTRB := AGRC003TRB()[1], oBrw:SetAlias(cAliasTRB), oBrw:Refresh()), .T. ) }
	Local vVetCam   	:= {"DX7_MIC","DX7_RES","DX7_FIBRA","DX7_UI","DX7_SFI","DX7_ELONG","DX7_LEAF","DX7_AREA",;
							"DX7_CSP","DX7_SCI","DX7_CG","DX7_RD","DX7_COUNT","DX7_UHM","DX7_MATU","DX7_MAISB"}
	Private cAliasTRB	:= ""
	Private oSize		:= Nil
	Private oBrw  	 	:= Nil
	Private aArqTemp 	:= {}
	Private vTitulos 	:= {}
	Private aMatCam  	:= {{"DXL_PSESTI",TamSx3("DXL_PSESTI")[3],TamSx3("DXL_PSESTI")[1],TamSx3("DXL_PSESTI")[2],STR0002+"s", "@E 99,999,999,999" },{"DX7_MIC"},{"DX7_RES"},{"DX7_FIBRA"},{"DX7_UI"},{"DX7_SFI"},;
		                    {"DX7_ELONG"},{"DX7_LEAF"},{"DX7_AREA"},{"DX7_CSP"},{"DX7_SCI"},{"DX7_RD"},{"DX7_COUNT"},{"DX7_UHM"},{"DX7_MATU"},{"DX7_MAISB"}} 
	Private vVetDPar 	:= {}
	Private	nTotFardos 	:= 0
	Private aRotina 	:= AGREMULAROT()
	
	Private _lNovSafra 	:= .F.
	
	If NN1->(ColumnPos('NN1_CODSAF' )) > 0
		_lNovSafra := .T.
	EndIf

	If !Pergunte("AGRAC003", .T.)
		Return
	EndIf
	
	For nx := 1 To Len(vVetCam)
	   Aadd (vTitulos,AGRTITULO(vVetCam[nx]))
	Next nx
	 	
	//-----------------
	// Seta tecla F12
	//-----------------
	SetKey( VK_F12, bKeyF12 )
	
	aRet := AGRC003TRB()
	cAliasTRB 	:= aRet[1] // Arquivo temporario
	aArqTemp 	:= aRet[2] // Estrutura do arquivo temporario
	
	If Select(cAliasTRB) > 0
		(cAliasTRB)->(DbSetOrder(1))                                
	   	   
		//- Coordenadas da area total da Dialog
		oSize := FWDefSize():New(.F.)
		oSize:AddObject('ALL',100,100,.T.,.T.) 
		oSize:SetWindowSize(aCoors)
		oSize:aMargins := {3,3,3,3}      
		oSize:lProp 	  := .T.      
		oSize:Process()
		nMCo := oSize:aPosObj[1,4] - 100
		nLin := 5 // 10	
		nCol := oSize:aPosObj[1,2]
		
		DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] OF oMainWnd PIXEL

		//	Instancia o layer
		oFWL := FWLayer():New()

		// Inicia o Layer
		oFWL:init(oDlg,.F.)

		// Cria uma linha unica para o Layer

		oFWL:addLine( 'SUP', 90 , .F.)
		oFWL:addLine( 'INF', 10 , .F.)

		// Cria colunas 
		oFWL:addCollumn('ESQ',100,.T.,'INF' )
		oPnlLine1 := oFWL:getLinePanel('SUP') 
		oPnDir    := oFWL:getColPanel('ESQ','INF')

		//-------------------------------------------------------------------
		// Define o Browse
		//-------------------------------------------------------------------
		DEFINE FWFORMBROWSE oBrw DATA TABLE ALIAS cAliasTRB DESCRIPTION STR0001 OF oPnlLine1 //oPnlCol   //"Classificação HVI"	

		oBrw:SetTemporary(.T.)
		oBrw:SetdbFFilter(.T.)
		oBrw:SetUseFilter(.T.)				
		oBrw:SetFieldFilter(CriaArray())
		oBrw:DisableDetails()
		oBrw:SetProfileID('1')
		oBrw:BVLDEXECFILTER := {|| AGRAC003RT()}
		oBrw:AddButton("Sair",{||oDlg:End()},,,,,,'10')
		ADD COLUMN oColumn DATA { || &(aArqTemp[1,1])	} 				TITLE STR0002		SIZE  TamSX3("DXI_CODIGO")[1] 	;
		PICTURE PesqPict("DXI","DXI_CODIGO")	TYPE TamSX3("DXI_CODIGO")[3]	OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[2,1])  	} 			TITLE STR0003		SIZE  TamSX3("DXI_PSLIQU")[1] 	;
		PICTURE PesqPict("DXI","DXI_PSLIQU") 	TYPE TamSX3("DXI_PSLIQU")[3]	OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[3,1])  	} 			TITLE STR0004		SIZE  TamSX3("DXI_ETIQ")[1]   	;
		PICTURE PesqPict("DXI","DXI_ETIQ")	 	TYPE TamSX3("DXI_ETIQ")[3]		OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[4,1])  	} 			TITLE STR0005		SIZE  TamSX3("DXI_FARDAO")[1] 	;
		PICTURE PesqPict("DXI","DXI_FARDAO") 	TYPE TamSX3("DXI_FARDAO")[3]	OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[5,1])  	} 			TITLE STR0006		SIZE  TamSX3("DXL_FAZ")[1]  	;
		PICTURE PesqPict("DXL","DXL_FAZ")	 	TYPE TamSX3("DXL_FAZ")[3]		OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[6,1])  	} 			TITLE STR0007		SIZE  TamSX3("DXL_TALHAO")[1] 	;
		PICTURE PesqPict("DXL","DXL_TALHAO") 	TYPE TamSX3("DXL_TALHAO")[3]	OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[7,1])  	}			TITLE STR0008		SIZE  TamSX3("DXL_CODVAR")[1] 	;
		PICTURE PesqPict("DXL","DXL_CODVAR") 	TYPE TamSX3("DXL_CODVAR")[3]	OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[8,1])  	} 			TITLE STR0009		SIZE  TamSX3("DXI_PRENSA")[1] 	;
		PICTURE PesqPict("DXI","DXI_PRENSA") 	TYPE TamSX3("DXI_PRENSA")[3]	OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[9,1])  	} 			TITLE STR0010		SIZE  TamSX3("DXI_BLOCO")[1]  	;
		PICTURE PesqPict("DXI","DXI_BLOCO")  	TYPE TamSX3("DXI_BLOCO")[3]		OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[10,1]) 	} 			TITLE STR0011		SIZE  TamSX3("DXK_CODROM")[1] 	;
		PICTURE PesqPict("DXK","DXK_CODROM") 	TYPE TamSX3("DXK_CODROM")[3]	OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[11,1])	} 			TITLE STR0045 		SIZE  TamSX3("DXI_CLAVIS")[1] 	;
		PICTURE PesqPict("DXI","DXI_CLAVIS") 	TYPE TamSX3("DXI_CLAVIS")[3]	OF oBrw	//"Classificação Visual"

		If _lNovSafra
			ADD COLUMN oColumn DATA { || &(aArqTemp[31,1])	} 			TITLE STR0046		SIZE  TamSX3("DXK_CLACON")[1] 	;
			PICTURE PesqPict("DXK","DXK_CLACON") 	TYPE TamSX3("DXK_CLACON")[3]	OF oBrw	//"Classificação Conferência"
		EndIf 

		ADD COLUMN oColumn DATA { || &(aArqTemp[30,1])	} 			TITLE STR0047		SIZE  TamSX3("DXI_CLACOM")[1] 	;
		PICTURE PesqPict("DXI","DXI_CLACOM") 	TYPE TamSX3("DXI_CLACOM")[3]	OF oBrw	//"Classificação Comercial"
		If _lNovSafra
			ADD COLUMN oColumn DATA { || &(aArqTemp[32,1])	} 			TITLE STR0048		SIZE  06 	;		
			PICTURE PesqPict("DXI","DXK_TIPCON") 	TYPE TamSX3("DXK_TIPCON")[3]	OF oBrw	//"Tipo Conferência"
		EndIf
		ADD COLUMN oColumn DATA { || AGC003Stat()		  	} 			TITLE STR0013		SIZE  10 OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[13,1])           } 	TITLE vTitulos[1]	SIZE  TamSX3("DX7_MIC")[1];    
		PICTURE PesqPict("DX7","DX7_MIC") 	  	TYPE TamSX3("DX7_MIC")[3]		OF oBrw

		ADD COLUMN oColumn DATA { || &(aArqTemp[14,1])           } 	TITLE vTitulos[2]	SIZE  TamSX3("DX7_RES")[1]  	;
		PICTURE PesqPict("DX7","DX7_RES") 	  	TYPE TamSX3("DX7_RES")[3]		OF oBrw
		ADD COLUMN oColumn DATA { || AGRMMToPol(&(aArqTemp[15,1]))}	TITLE vTitulos[3]	SIZE  TamSX3("DX7_FIBRA")[1] 	;
		PICTURE PesqPict("DX7","DX7_FIBRA") 	TYPE TamSX3("DX7_FIBRA")[3]		OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[16,1])           } 	TITLE vTitulos[4]	SIZE  TamSX3("DX7_UI")[1]  		;
		PICTURE PesqPict("DX7","DX7_UI") 	  	TYPE TamSX3("DX7_UI")[3]			OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[17,1])          } 	TITLE vTitulos[5]	SIZE  TamSX3("DX7_SFI")[1]  	;
		PICTURE PesqPict("DX7","DX7_SFI") 	  	TYPE TamSX3("DX7_SFI")[3]		OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[18,1]) 	       } 	TITLE vTitulos[6]	SIZE  TamSX3("DX7_ELONG")[1] 	;
		PICTURE PesqPict("DX7","DX7_ELONG") 	TYPE TamSX3("DX7_ELONG")[3]		OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[19,1])	       } 	TITLE vTitulos[7]	SIZE  TamSX3("DX7_LEAF")[1]  	;
		PICTURE PesqPict("DX7","DX7_LEAF")  	TYPE TamSX3("DX7_LEAF")[3]		OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[20,1])	       } 	TITLE vTitulos[8]	SIZE  TamSX3("DX7_AREA")[1]  	;
		PICTURE PesqPict("DX7","DX7_AREA")  	TYPE TamSX3("DX7_AREA")[3]		OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[21,1])	   } 		TITLE vTitulos[9]	SIZE  TamSX3("DX7_CSP")[1]  	;
		PICTURE PesqPict("DX7","DX7_CSP")   	TYPE TamSX3("DX7_CSP")[3]		OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[29,1])	   } 		TITLE vTitulos[10]SIZE  TamSX3("DX7_SCI")[1]  	;
		PICTURE PesqPict("DX7","DX7_SCI")   	TYPE TamSX3("DX7_SCI")[3]		OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[22,1])	         }	TITLE vTitulos[11]SIZE  TamSX3("DX7_CG")[1]  		;
		PICTURE PesqPict("DX7","DX7_CG") 	  	TYPE TamSX3("DX7_CG")[3]			OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[23,1])		} 		TITLE vTitulos[12]SIZE  TamSX3("DX7_RD")[1]  		;
		PICTURE PesqPict("DX7","DX7_RD") 	  	TYPE TamSX3("DX7_RD")[3]			OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[24,1])	         }	TITLE vTitulos[13]SIZE  TamSX3("DX7_COUNT")[1] 	;
		PICTURE PesqPict("DX7","DX7_COUNT") 	TYPE TamSX3("DX7_COUNT")[3]		OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[25,1])		} 		TITLE vTitulos[14]SIZE  TamSX3("DX7_UHM")[1]  	;
		PICTURE PesqPict("DX7","DX7_UHM") 	  	TYPE TamSX3("DX7_UHM")[3]		OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[26,1])			} 	TITLE vTitulos[15]SIZE  TamSX3("DX7_MATU")[1]  	;
		PICTURE PesqPict("DX7","DX7_MATU")  	TYPE TamSX3("DX7_MATU")[3]		OF oBrw
		ADD COLUMN oColumn DATA { || &(aArqTemp[27,1])			} 	TITLE vTitulos[16]SIZE  TamSX3("DX7_MAISB")[1] 	;
		PICTURE PesqPict("DX7","DX7_MAISB") 	TYPE TamSX3("DX7_MAISB")[3]		OF oBrw
		oBrw:Acolumns[1]:CREADVAR := 'DXI_CODIGO'
		oBrw:Acolumns[2]:CREADVAR := 'DXI_PSLIQU'
		oBrw:Acolumns[4]:CREADVAR := 'DXI_FARDAO'
		AGRMOSTOTAIS(aMatCam,vVetDPar,,@oBrw)
		
		//-------------------------------------------------------------------
		// Ativação do Browse
		//-------------------------------------------------------------------					
		ACTIVATE FWFORMBROWSE oBrw
		ACTIVATE MSDIALOG oDlg CENTER
		(cAliasTRB)->(DbCloseArea())
	EndIf

	//Elimina a tabela temporária, se houver
	AGRDLTPTB(__oArqTemp)
    
Return

Static Function CriaArray()
	Local aCampos := {}
	Local aCmpsTam := {}
	aCmpsTam := TamSX3("DXI_CODIGO");AADD(aCampos,{"DXI_CODIGO"  ,AGRTITULO("DXI_CODIGO"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	
	aCmpsTam := TamSX3("DXI_PSLIQU");AADD(aCampos,{"DXI_PSLIQU"  ,AGRTITULO("DXI_PSLIQU"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 		
	aCmpsTam := TamSX3("DXI_ETIQ"  );AADD(aCampos,{"DXI_ETIQ"    ,AGRTITULO("DXI_ETIQ")  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	
	aCmpsTam := TamSX3("DXI_FARDAO");AADD(aCampos,{"DXI_FARDAO"  ,AGRTITULO("DXI_FARDAO"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	
	aCmpsTam := TamSX3("DXL_FAZ"   );AADD(aCampos,{"DXL_FAZ"     ,AGRTITULO("DXL_FAZ")   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	
	aCmpsTam := TamSX3("DXL_TALHAO");AADD(aCampos,{"DXL_TALHAO"  ,AGRTITULO("DXL_TALHAO"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	
	aCmpsTam := TamSX3("DXL_CODVAR");AADD(aCampos,{"DXL_CODVAR"  ,AGRTITULO("DXL_CODVAR"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	
	aCmpsTam := TamSX3("DXI_PRENSA");AADD(aCampos,{"DXI_PRENSA"  ,AGRTITULO("DXI_PRENSA"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	
	aCmpsTam := TamSX3("DXI_BLOCO" );AADD(aCampos,{"DXI_BLOCO"   ,AGRTITULO("DXI_BLOCO") ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	
	aCmpsTam := TamSX3("DXK_CODROM");AADD(aCampos,{"DXK_CODROM"  ,AGRTITULO("DXK_CODROM"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	
	aCmpsTam := TamSX3("DXI_CLAVIS");AADD(aCampos,{"DXI_CLAVIS"  ,AGRTITULO("DXI_CLAVIS"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	
	aCmpsTam := TamSX3("DXI_CODRES");AADD(aCampos,{"DXI_CODRES"  ,AGRTITULO("DXI_CODRES"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	
	aCmpsTam := TamSX3("DX7_MIC"   );AADD(aCampos,{"DX7_MIC"     ,AGRTITULO("DX7_MIC")   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 		
	aCmpsTam := TamSX3("DX7_RES"   );AADD(aCampos,{"DX7_RES"     ,AGRTITULO("DX7_RES")   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 		
	aCmpsTam := TamSX3("DX7_FIBRA" );AADD(aCampos,{"DX7_FIBRA"   ,AGRTITULO("DX7_FIBRA") ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	
	aCmpsTam := TamSX3("DX7_UI"    );AADD(aCampos,{"DX7_UI"      ,AGRTITULO("DX7_UI")    ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 		
	aCmpsTam := TamSX3("DX7_SFI"   );AADD(aCampos,{"DX7_SFI"     ,AGRTITULO("DX7_SFI")   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 		
	aCmpsTam := TamSX3("DX7_ELONG" );AADD(aCampos,{"DX7_ELONG"   ,AGRTITULO("DX7_ELONG") ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	
	aCmpsTam := TamSX3("DX7_LEAF"  );AADD(aCampos,{"DX7_LEAF"    ,AGRTITULO("DX7_LEAF")  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	 	
	aCmpsTam := TamSX3("DX7_AREA"  );AADD(aCampos,{"DX7_AREA"    ,AGRTITULO("DX7_AREA")  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	 	
	aCmpsTam := TamSX3("DX7_CSP"   );AADD(aCampos,{"DX7_CSP"     ,AGRTITULO("DX7_CSP")   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DX7_SCI"   );AADD(aCampos,{"DX7_SCI"     ,AGRTITULO("DX7_SCI")   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})  		
	aCmpsTam := TamSX3("DX7_CG"    );AADD(aCampos,{"DX7_CG"      ,AGRTITULO("DX7_CG")    ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 		
	aCmpsTam := TamSX3("DX7_RD"    );AADD(aCampos,{"DX7_RD"      ,AGRTITULO("DX7_RD")    ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 		
	aCmpsTam := TamSX3("DX7_COUNT" );AADD(aCampos,{"DX7_COUNT"   ,AGRTITULO("DX7_COUNT") ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 		
	aCmpsTam := TamSX3("DX7_UHM"   );AADD(aCampos,{"DX7_UHM"     ,AGRTITULO("DX7_UHM")   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	
	aCmpsTam := TamSX3("DX7_MATU"  );AADD(aCampos,{"DX7_MATU"    ,AGRTITULO("DX7_MATU")  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	 	
	aCmpsTam := TamSX3("DX7_MAISB" );AADD(aCampos,{"DX7_MAISB"   ,AGRTITULO("DX7_MAISB") ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 	
	aCmpsTam := TamSX3("DXI_ROMSAI");AADD(aCampos,{"DXI_ROMSAI"  ,AGRTITULO("DXI_ROMSAI"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXI_CLACOM");AADD(aCampos,{"DXI_CLACOM"  ,AGRTITULO("DXI_CLACOM"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	If _lNovSafra
		aCmpsTam := TamSX3("DXK_CLACON");AADD(aCampos,{"DXK_CLACON"  ,AGRTITULO("DXK_CLACON"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) 
		aCmpsTam := TamSX3("DXK_TIPCON");AADD(aCampos,{"DXK_TIPCON"  ,AGRTITULO("DXK_TIPCON"),aCmpsTam[3],         06,aCmpsTam[2],""})  	
	EndIf
Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} AG615Query
Função para montar TRB de consulta
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------
Static Function AGRC003TRB()
	Local cQuery		:= ""
	Local aArqTemp 	:= {} 
	Local cArqTemp	:= ""
	Local aCmpsTam  	:= {}
	Private nQtdl   	:= 0  
	Private cAlias	:= "" 
	                      
	If (!Empty(cAliasTRB)) .AND. (Select(cAliasTRB) > 0)
		(cAliasTRB)->(dbCloseArea())
	EndIf		
	
	// Cria arquivo de trabalho
	aCmpsTam := TamSX3("DXI_CODIGO");AADD(aArqTemp,{"DXI_CODIGO"  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 01
	aCmpsTam := TamSX3("DXI_PSLIQU");AADD(aArqTemp,{"DXI_PSLIQU"  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 02 		
	aCmpsTam := TamSX3("DXI_ETIQ"  );AADD(aArqTemp,{"DXI_ETIQ"    ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 03
	aCmpsTam := TamSX3("DXI_FARDAO");AADD(aArqTemp,{"DXI_FARDAO"  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 04
	aCmpsTam := TamSX3("DXL_NMFAZ" );AADD(aArqTemp,{"DXL_NMFAZ"   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 05
	aCmpsTam := TamSX3("DXL_TALHAO");AADD(aArqTemp,{"DXL_TALHAO"  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 06
	aCmpsTam := TamSX3("DXL_DESCVR");AADD(aArqTemp,{"DXL_DESCVR"  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 07
	aCmpsTam := TamSX3("DXI_PRENSA");AADD(aArqTemp,{"DXI_PRENSA"  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 08
	aCmpsTam := TamSX3("DXI_BLOCO" );AADD(aArqTemp,{"DXI_BLOCO"   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 09
	aCmpsTam := TamSX3("DXK_CODROM");AADD(aArqTemp,{"DXK_CODROM"  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 10
	aCmpsTam := TamSX3("DXI_CLAVIS");AADD(aArqTemp,{"DXI_CLAVIS"  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 11
	aCmpsTam := TamSX3("DXI_CODRES");AADD(aArqTemp,{"DXI_CODRES"  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 12
	aCmpsTam := TamSX3("DX7_MIC"   );AADD(aArqTemp,{"DX7_MIC"     ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 13
	aCmpsTam := TamSX3("DX7_RES"   );AADD(aArqTemp,{"DX7_RES"     ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 14	
	aCmpsTam := TamSX3("DX7_FIBRA" );AADD(aArqTemp,{"DX7_FIBRA"   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 15
	aCmpsTam := TamSX3("DX7_UI"    );AADD(aArqTemp,{"DX7_UI"      ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 16	
	aCmpsTam := TamSX3("DX7_SFI"   );AADD(aArqTemp,{"DX7_SFI"     ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 17	
	aCmpsTam := TamSX3("DX7_ELONG" );AADD(aArqTemp,{"DX7_ELONG"   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 18
	aCmpsTam := TamSX3("DX7_LEAF"  );AADD(aArqTemp,{"DX7_LEAF"    ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 19 	
	aCmpsTam := TamSX3("DX7_AREA"  );AADD(aArqTemp,{"DX7_AREA"    ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 20 	
	aCmpsTam := TamSX3("DX7_CSP"   );AADD(aArqTemp,{"DX7_CSP"     ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]})	//Posicao: 21 	
	aCmpsTam := TamSX3("DX7_CG"    );AADD(aArqTemp,{"DX7_CG"      ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 22	
	aCmpsTam := TamSX3("DX7_RD"    );AADD(aArqTemp,{"DX7_RD"      ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 23	
	aCmpsTam := TamSX3("DX7_COUNT" );AADD(aArqTemp,{"DX7_COUNT"   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 24	
	aCmpsTam := TamSX3("DX7_UHM"   );AADD(aArqTemp,{"DX7_UHM"     ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 25
	aCmpsTam := TamSX3("DX7_MATU"  );AADD(aArqTemp,{"DX7_MATU"    ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 26 	
	aCmpsTam := TamSX3("DX7_MAISB" );AADD(aArqTemp,{"DX7_MAISB"   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 27
	aCmpsTam := TamSX3("DXI_ROMSAI");AADD(aArqTemp,{"DXI_ROMSAI"  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]}) 	//Posicao: 28
	aCmpsTam := TamSX3("DX7_SCI"   );AADD(aArqTemp,{"DX7_SCI"     ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]})	//Posicao: 29
	aCmpsTam := TamSX3("DXI_CLACOM");AADD(aArqTemp,{"DXI_CLACOM"  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]})	//Posicao: 30 

	If _lNovSafra
		aCmpsTam := TamSX3("DXK_CLACON");AADD(aArqTemp,{"DXK_CLACON"  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2]})	//Posicao: 31
		aCmpsTam := TamSX3("DXK_TIPCON");AADD(aArqTemp,{"DXK_TIPCON"  ,aCmpsTam[3],         06,aCmpsTam[2]})	//Posicao: 32
	EndIf

	//-- Cria Indice de Trabalho
	cArqTemp   := GetNextAlias()
	__oArqTemp   := AGRCRTPTB(cArqTemp, {aArqTemp, {{"", "DXI_CODIGO"}} } ) 
	cAliasTRB  := cArqTemp


	cQuery := " SELECT DXI_CODIGO,DXI.DXI_PSLIQU,DXI.DXI_FARDAO,DXI_PRENSA,DXI_BLOCO,DXI_CODRES,DXI_CLAVIS,DXI_CLACOM,DXI_ETIQ,DXI_ROMSAI, "
	cQuery +=        " DX7_MIC,DX7_RES,DX7_FIBRA,DX7_UI,DX7_SFI,DX7_ELONG,DX7_LEAF,DX7_AREA,DX7_CSP,DX7_SCI,DX7_CG,DX7_RD,DX7_COUNT,DX7_UHM,DX7_MATU,DX7_MAISB, "
	cQuery +=        " DXL.DXL_FAZ,DXL_TALHAO,DXL_CODVAR,NN2_NOME AS DXL_NMFAZ,NNV_DESCRI AS DXL_DESCVR, "
	cQuery +=        " DXK.DXK_CODROM, DXK.DXK_CLAVIS "

	If _lNovSafra
		cQuery +=      " , DXK.DXK_TIPCON, DXK.DXK_CLACON "
	EndIf

	/*	cQuery +="  (SELECT MAX(DXJ.DXJ_CODIGO) FROM "+ RetSqlName("DXJ") +" DXJ  "
	cQuery +="     INNER JOIN   "+ RetSqlName("DXK") +"  DXK  ON DXK.D_E_L_E_T_ <> '*' AND "
	cQuery +="												      DXK.DXK_FILIAL = '"+FWxFilial ("DXK")+"'  AND " 
	cQuery +="													   DXK.DXK_CODROM = DXJ.DXJ_CODIGO "
	cQuery +=" WHERE DXK.D_E_L_E_T_ <> '*' AND DXK.DXK_FILIAL = DXI.DXI_FILIAL AND DXK.DXK_SAFRA = DXI.DXI_SAFRA AND DXK.DXK_ETIQ = DXI.DXI_ETIQ  AND DXJ.DXJ_TIPO = '2' ) DXK_CODROM " 
	*/
	cQuery +=   " FROM "+ RetSqlName("DX7") +" DX7 "
	cQuery +=   " JOIN  "+ RetSqlName("DXI") +" DXI ON DXI.D_E_L_E_T_ <> '*' AND DXI.DXI_FILIAL = '"+FWxFilial ("DXI")+"' AND DXI.DXI_SAFRA = DX7.DX7_SAFRA AND DXI.DXI_ETIQ = DX7.DX7_ETIQ "
	cQuery +=   " JOIN  "+ RetSqlName("DXL") +" DXL ON DXL.D_E_L_E_T_ <> '*' AND DXL.DXL_FILIAL = '"+FWxFilial ("DXL")+"' AND  DXL.DXL_CODIGO = DXI.DXI_FARDAO AND DXI.DXI_SAFRA  = DXL.DXL_SAFRA AND  DXL.DXL_PRDTOR = DXI.DXI_PRDTOR AND DXL.DXL_LJPRO = DXI.DXI_LJPRO AND DXL.DXL_FAZ = DXI.DXI_FAZ "
	cQuery +=   " LEFT JOIN  "+ RetSqlName("DXS") +" DXS ON DXS.D_E_L_E_T_ <> '*' AND DXS.DXS_FILIAL = '"+FWxFilial ("DXS")+"' AND DXS.DXS_CODIGO = DXI.DXI_ROMSAI "
	cQuery +=   " LEFT JOIN  "+ RetSqlName("NN2") +" NN2 ON NN2.D_E_L_E_T_ <> '*' AND NN2.NN2_FILIAL = '"+FWxFilial ("NN2")+"' AND NN2.NN2_CODIGO = DXL.DXL_FAZ AND NN2.NN2_PRDTOR = DXL.DXL_PRDTOR AND NN2.NN2_LJPRO = DXL.DXL_LJPRO "
	cQuery +=   " LEFT JOIN  "+ RetSqlName("NNV") +" NNV ON NNV.D_E_L_E_T_ <> '*' AND NNV.NNV_FILIAL = '"+FWxFilial ("NNV")+"' AND NNV.NNV_CODIGO = DXL.DXL_CODVAR "	
	cQuery +=   " LEFT JOIN  "+ RetSqlName("DXK") +" DXK ON DXK.D_E_L_E_T_ <> '*' AND DXK.DXK_FILIAL = DXI.DXI_FILIAL AND DXK.DXK_SAFRA = DXI.DXI_SAFRA AND DXK.DXK_ETIQ = DXI.DXI_ETIQ "
	If _lNovSafra
		cQuery += " AND DXK.DXK_TIPO = '1' "
	EndIf		
	cQuery +=  " WHERE DX7_ATIVO = '1' AND DX7.D_E_L_E_T_ <> '*'  "

	MakeSqlExpr("AGRAC003")
	//Filtro de unidade de beneficiamento
	If _lNovSafra
		If !Empty(mv_par24) //UBA
			cQuery += " AND DXI.DXI_CODUNB = '" + mv_par24 + "'"
		EndIf
	Else
		If !Empty(mv_par23) //UBA
			cQuery += " AND DXI.DXI_CODUNB = '" + mv_par23 + "'"
		EndIf
	EndIf		
	
	If !Empty(mv_par01) //Safra
		cQuery += " AND DXI.DXI_SAFRA = '" + mv_par01 +"'"
	EndIf
	
	If _lNovSafra
		If !Empty(mv_par02) //Produto
			cQuery += " AND DXL.DXL_CODPRO = '" + mv_par02 +"'"
		EndIf
	EndIf	
	
	If _lNovSafra
		If !Empty(mv_par03) .And. !Empty(mv_par04)//Produtor+Loja
			cQuery += " AND DXI.DXI_PRDTOR = '" + mv_par03 +"' AND DXL.DXL_LJPRO = '" + mv_par04 +"'"
		EndIf
	Else
		If !Empty(mv_par02) .And. !Empty(mv_par03)//Produtor+Loja
			cQuery += " AND DXI.DXI_PRDTOR = '" + mv_par02 +"' AND DXL.DXL_LJPRO = '" + mv_par03 +"'"
		EndIf
	EndIf		
	
	If _lNovSafra
		If !Empty(mv_par05)//Bloco por Range
			If "( IN(" $ mv_par05 
				cQuery += " AND DXI.DXI_BLOCO " + SubStr( mv_par05, 2, len(mv_par05) - 2) 
			Else
				cQuery += " AND DXI.DXI_BLOCO = '" + mv_par05 + "'" 
			EndIf
		EndIf
	Else
		If !Empty(mv_par04)//Bloco por Range
			If "( IN(" $ mv_par04 
				cQuery += " AND DXI.DXI_BLOCO " + SubStr( mv_par04, 2, len(mv_par04) - 2) 
			Else
				cQuery += " AND DXI.DXI_BLOCO = '" + mv_par04 + "'" 
			EndIf
		EndIf
	EndIf		
	
	If _lNovSafra
		If !Empty(mv_par06) .And. !Empty(mv_par07)//Laboratorio + Unidade
			cQuery += " AND DX7.DX7_LAB    = '" + mv_par06 +"' AND DX7.DX7_UNI = '" + mv_par07 +"'"
		EndIf
	Else
		If !Empty(mv_par05) .And. !Empty(mv_par06)//Laboratorio + Unidade
			cQuery += " AND DX7.DX7_LAB    = '" + mv_par05 +"' AND DX7.DX7_UNI = '" + mv_par06 +"'"
		EndIf
	EndIf	
	
	If _lNovSafra
		If !Empty(mv_par08) //Talhao
			cQuery += " AND DXL.DXL_TALHAO = '" + mv_par08 +"'"
		EndIf
	Else
		If !Empty(mv_par07) //Talhao
			cQuery += " AND DXL.DXL_TALHAO = '" + mv_par07 +"'"
		EndIf
	EndIf		
	
	If _lNovSafra
		If !Empty(mv_par09) //Variedade
			cQuery += " AND DXL.DXL_CODVAR = '" + mv_par09 +"'"
		EndIf
	Else
		If !Empty(mv_par08) //Variedade
			cQuery += " AND DXL.DXL_CODVAR = '" + mv_par08 +"'"
		EndIf
	EndIf	
	
	If _lNovSafra
		If !Empty(mv_par10)//Fardao
			cQuery += " AND DXL.DXL_CODIGO = '" + mv_par10 +"'"
		EndIf
	Else
		If !Empty(mv_par09)//Fardao
			cQuery += " AND DXL.DXL_CODIGO = '" + mv_par09 +"'"
		EndIf
	EndIf	
	
	If _lNovSafra
		If !Empty(mv_par11)//Contrato
			cQuery += " AND DXS.DXS_CODCTP = '" + mv_par11 +"'"
		EndIf
	Else
		If !Empty(mv_par10)//Contrato
			cQuery += " AND DXS.DXS_CODCTP = '" + mv_par10 +"'"
		EndIf
	EndIf	
	
	If _lNovSafra
		If !Empty(mv_par12)//Prensa
			cQuery += " AND DXI.DXI_PRENSA = '" + mv_par12 +"'"
		EndIf
	Else
		If !Empty(mv_par11)//Prensa
			cQuery += " AND DXI.DXI_PRENSA = '" + mv_par11 +"'"
		EndIf
	EndIf	
	
	If _lNovSafra
		If !Empty(mv_par13) .And. !Empty(mv_par14)//Cliente + Loja
			cQuery += " AND DXS.DXS_CLIENT    = '" + mv_par13 +"' AND DXS.DXS_LJCLI = '" + mv_par14 +"'"
		EndIf
	Else
		If !Empty(mv_par12) .And. !Empty(mv_par13)//Cliente + Loja
			cQuery += " AND DXS.DXS_CLIENT    = '" + mv_par12 +"' AND DXS.DXS_LJCLI = '" + mv_par13 +"'"
		EndIf
	EndIf	
	
	If _lNovSafra
		If !Empty(mv_par15) .And. !Empty(mv_par16)//Nota Fiscal
			cQuery += " AND DXS.DXS_NUMNFS BETWEEN "+ mv_par15 +" AND "+ mv_par16 + "'"
		EndIf
	Else
		If !Empty(mv_par14) .And. !Empty(mv_par15)//Nota Fiscal
			cQuery += " AND DXS.DXS_NUMNFS BETWEEN "+ mv_par14 +" AND "+ mv_par15 + "'"
		EndIf
	EndIf
		
	If _lNovSafra
		If !Empty(mv_par17)//Classificação Visual
			cQuery += " AND DXI.DXI_CLAVIS = '" + mv_par17 +"'"
		EndIf
	Else
		If !Empty(mv_par16)//Classificação Visual
			cQuery += " AND DXI.DXI_CLAVIS = '" + mv_par16 +"'"
		EndIf
	EndIf	
    
    If _lNovSafra	
		If mv_par18 == 1 .AND. mv_par19 == 2 .AND. mv_par20 == 2			//SE DISPONIVEL *** SIM *** E RESERVADO *** NAO *** E ENTREGUE *** NAO ***
			//* DISPONIVEL
			cQuery += " AND DXI_CODRES = ' '  AND DXI_ROMSAI = ' ' " 
		
		ElseIf mv_par18 == 2 .AND. mv_par19 == 1 .AND. mv_par20 == 2		//SE DISPONIVEL *** NAO *** E RESERVADO *** SIM *** E ENTREGUE *** NAO ***
			//* RESERVADO
			cQuery += " AND DXI_CODRES <> ' ' AND DXI_ROMSAI = ' ' "
	
		ElseIf mv_par18 == 2 .AND. mv_par19 == 2 .AND. mv_par20 == 1		//SE DISPONIVEL *** NAO *** E RESERVADO *** NAO *** E ENTREGUE *** SIM ***
			//* ENTREGUE
			cQuery += " AND DXI_ROMSAI <> ' ' AND DXI_CODRES <> ' ' "	
		
		ElseIf mv_par18 == 1 .AND. mv_par19 == 2 .AND. mv_par20 == 1		//SE DISPONIVEL *** SIM *** E RESERVADO *** NAO *** E ENTREGUE *** SIM ***
			//** DISPONIVEL E ENTREGUE --- VICE-VERSA
			cQuery += " AND (DXI_CODRES = ' '  AND DXI_ROMSAI = ' ' OR (DXI_ROMSAI <> ' ' AND DXI_CODRES <> ' ') ) "
	
		ElseIf mv_par18 == 1 .AND. mv_par19 == 1 .AND. mv_par20 == 2		//SE DISPONIVEL *** SIM *** E RESERVADO *** SIM *** E ENTREGUE *** NAO ***
			//** DISPONIVEL E RESERVADO --- VICE-VERSA
			cQuery += " AND (DXI_CODRES = ' '  AND DXI_ROMSAI = ' ' OR (DXI_CODRES <> ' ' AND DXI_ROMSAI = ' ') ) "
	 	
		ElseIf mv_par18 == 2 .AND. mv_par19 == 1 .AND. mv_par20 == 1		//SE DISPONIVEL *** NAO *** E RESERVADO *** NAO *** E ENTREGUE *** SIM ***
			//** RESERVADO E ENTREGUE   --- VICE-VERSA
			cQuery += " AND (DXI_CODRES <> ' ' AND DXI_ROMSAI = ' ' OR (DXI_ROMSAI <> ' ' AND DXI_CODRES <> ' ') ) "
		EndIf
	Else
		If mv_par17 == 1 .AND. mv_par18 == 2 .AND. mv_par19 == 2			//SE DISPONIVEL *** SIM *** E RESERVADO *** NAO *** E ENTREGUE *** NAO ***
			//* DISPONIVEL
			cQuery += " AND DXI_CODRES = ' '  AND DXI_ROMSAI = ' ' " 
		
		ElseIf mv_par17 == 2 .AND. mv_par18 == 1 .AND. mv_par19 == 2		//SE DISPONIVEL *** NAO *** E RESERVADO *** SIM *** E ENTREGUE *** NAO ***
			//* RESERVADO
			cQuery += " AND DXI_CODRES <> ' ' AND DXI_ROMSAI = ' ' "
	
		ElseIf mv_par17 == 2 .AND. mv_par18 == 2 .AND. mv_par19 == 1		//SE DISPONIVEL *** NAO *** E RESERVADO *** NAO *** E ENTREGUE *** SIM ***
			//* ENTREGUE
			cQuery += " AND DXI_ROMSAI <> ' ' AND DXI_CODRES <> ' ' "	
		
		ElseIf mv_par17 == 1 .AND. mv_par18 == 2 .AND. mv_par19 == 1		//SE DISPONIVEL *** SIM *** E RESERVADO *** NAO *** E ENTREGUE *** SIM ***
			//** DISPONIVEL E ENTREGUE --- VICE-VERSA
			cQuery += " AND (DXI_CODRES = ' '  AND DXI_ROMSAI = ' ' OR (DXI_ROMSAI <> ' ' AND DXI_CODRES <> ' ') ) "
	
		ElseIf mv_par17 == 1 .AND. mv_par18 == 1 .AND. mv_par19 == 2		//SE DISPONIVEL *** SIM *** E RESERVADO *** SIM *** E ENTREGUE *** NAO ***
			//** DISPONIVEL E RESERVADO --- VICE-VERSA
			cQuery += " AND (DXI_CODRES = ' '  AND DXI_ROMSAI = ' ' OR (DXI_CODRES <> ' ' AND DXI_ROMSAI = ' ') ) "
	 	
		ElseIf mv_par17 == 2 .AND. mv_par18 == 1 .AND. mv_par19 == 1		//SE DISPONIVEL *** NAO *** E RESERVADO *** NAO *** E ENTREGUE *** SIM ***
			//** RESERVADO E ENTREGUE   --- VICE-VERSA
			cQuery += " AND (DXI_CODRES <> ' ' AND DXI_ROMSAI = ' ' OR (DXI_ROMSAI <> ' ' AND DXI_CODRES <> ' ') ) "
		EndIf
	EndIf	 
	
	If _lNovSafra
		If !Empty(mv_par22)//Romaneio de Classificação	
		cQuery +=" AND  (SELECT DXJ.DXJ_CODIGO FROM "+ RetSqlName("DXJ") +" DXJ  "
		cQuery +="     INNER JOIN   "+ RetSqlName("DXK") +"  DXK  ON DXK.D_E_L_E_T_ <> '*' AND "
		cQuery +="												      DXK.DXK_FILIAL = '"+xFilial("DXK")+"'    AND " 
		cQuery +="													   DXK.DXK_CODROM = DXJ.DXJ_CODIGO "
		cQuery +=" WHERE DXK.D_E_L_E_T_ <> '*' AND DXK.DXK_FILIAL = DXI.DXI_FILIAL AND DXK.DXK_SAFRA = DXI.DXI_SAFRA AND DXK.DXK_ETIQ = DXI.DXI_ETIQ  AND DXJ.DXJ_TIPO = '2' ) = '" + mv_par22 +"'"
		EndIf
	Else
		If !Empty(mv_par21)//Romaneio de Classificação	
		cQuery +=" AND  (SELECT DXJ.DXJ_CODIGO FROM "+ RetSqlName("DXJ") +" DXJ  "
		cQuery +="     INNER JOIN   "+ RetSqlName("DXK") +"  DXK  ON DXK.D_E_L_E_T_ <> '*' AND "
		cQuery +="												      DXK.DXK_FILIAL = '"+xFilial("DXK")+"'    AND " 
		cQuery +="													   DXK.DXK_CODROM = DXJ.DXJ_CODIGO "
		cQuery +=" WHERE DXK.D_E_L_E_T_ <> '*' AND DXK.DXK_FILIAL = DXI.DXI_FILIAL AND DXK.DXK_SAFRA = DXI.DXI_SAFRA AND DXK.DXK_ETIQ = DXI.DXI_ETIQ  AND DXJ.DXJ_TIPO = '2' ) = '" + mv_par21 +"'"
		EndIf
	EndIf	
	
	If _lNovSafra
		If !Empty(mv_par23)//Reserva
			cQuery += " AND DXI.DXI_CODRES= '" + mv_par23 +"'"
		EndIf
	Else
		If !Empty(mv_par22)//Reserva
			cQuery += " AND DXI.DXI_CODRES= '" + mv_par22 +"'"
		EndIf
	EndIf	
		
	cQuery := ChangeQuery( cQuery )
	cAlias := "AliasQry"
	dbUseArea( .T., 'TOPCONN', TcGenQry( , , cQuery), cAlias, .F., .T. )	

	(cAlias)->(dbGoTop())
	Count To nQtdl 
	Processa({|| AGRAC003P() },STR0014)
	DbselectArea(cArqTemp)
	dbGoTop()
	
Return({cArqTemp, aArqTemp})

/* -------------------------------------------------------------------------------------
AGRAC003P Processamento
@param: Nil
@author: Inácio Luiz Kolling
@since: 19/06/2014
@Uso: UBAC008
-------------------------------------------------------------------------------------
*/
Static Function AGRAC003P()
	DbselectArea(cAlias)
	(cAlias)->(dbGotop())
	ProcRegua(nQtdl)
	nRegl := 0
	vVetDPar := {} 
	nTotFardos := 0
	AGRCRIAMATOT(aMatCam,vVetDPar)
	While (cAlias)->(!Eof())
	   nRegl ++ 
 	   IncProc(STR0015+Alltrim(Str(nRegl,5))+" / "+Alltrim(Str(nQtdl,5))) //"Processando Bloco -> "
 	   DbselectArea(cAliasTRB)
		Reclock(cAliasTRB, .T.)
		(cAliasTRB)->DXI_CODIGO :=(cAlias)->DXI_CODIGO
		(cAliasTRB)->DXI_PSLIQU	:=(cAlias)->DXI_PSLIQU
		(cAliasTRB)->DXI_ETIQ 	:=(cAlias)->DXI_ETIQ
		(cAliasTRB)->DXI_FARDAO	:=(cAlias)->DXI_FARDAO
		(cAliasTRB)->DXL_NMFAZ	:=(cAlias)->DXL_NMFAZ
		(cAliasTRB)->DXL_TALHAO	:=(cAlias)->DXL_TALHAO
		(cAliasTRB)->DXL_DESCVR	:=(cAlias)->DXL_DESCVR
		(cAliasTRB)->DXI_PRENSA	:=(cAlias)->DXI_PRENSA
		(cAliasTRB)->DXI_BLOCO	:=(cAlias)->DXI_BLOCO
		(cAliasTRB)->DXK_CODROM	:=(cAlias)->DXK_CODROM
		(cAliasTRB)->DXI_CLAVIS	:=(cAlias)->DXI_CLAVIS
		(cAliasTRB)->DXI_CLACOM	:=(cAlias)->DXI_CLACOM
		(cAliasTRB)->DXI_CODRES	:=(cAlias)->DXI_CODRES
		(cAliasTRB)->DX7_MIC   	:=(cAlias)->DX7_MIC
		(cAliasTRB)->DX7_RES  	:=(cAlias)->DX7_RES
		(cAliasTRB)->DX7_FIBRA	:=(cAlias)->DX7_FIBRA
		(cAliasTRB)->DX7_UI    	:=(cAlias)->DX7_UI
		(cAliasTRB)->DX7_SFI  	:=(cAlias)->DX7_SFI
		(cAliasTRB)->DX7_ELONG 	:=(cAlias)->DX7_ELONG
		(cAliasTRB)->DX7_LEAF		:=(cAlias)->DX7_LEAF
		(cAliasTRB)->DX7_AREA  	:=(cAlias)->DX7_AREA
		(cAliasTRB)->DX7_CSP   	:=(cAlias)->DX7_CSP
		(cAliasTRB)->DX7_SCI  	:=(cAlias)->DX7_SCI
		(cAliasTRB)->DX7_CG     :=(cAlias)->DX7_CG
		(cAliasTRB)->DX7_RD     :=(cAlias)->DX7_RD
		(cAliasTRB)->DX7_COUNT 	:=(cAlias)->DX7_COUNT
		(cAliasTRB)->DX7_UHM    :=(cAlias)->DX7_UHM
		(cAliasTRB)->DX7_MATU   :=(cAlias)->DX7_MATU
		(cAliasTRB)->DX7_MAISB  :=(cAlias)->DX7_MAISB
		(cAliasTRB)->DXI_ROMSAI :=(cAlias)->DXI_ROMSAI
		If _lNovSafra
			(cAliasTRB)->DXK_CLACON := (cAlias)->DXK_CLACON
			(cAliasTRB)->DXK_TIPCON := If( (cAlias)->DXK_TIPCON == '1', STR0049 /*"Bom"*/, If( (cAlias)->DXK_TIPCON == '2', STR0050 /*"Médio"*/,  If( (cAlias)->DXK_TIPCON == '3', STR0051 /*"Fraco"*/,  " " )))
		EndIf
		MsUnlock()
		AGRAC003TA()
		(cAlias)->(dbSkip())
	End	
	(cAlias)->(dbCloseArea())
	nTotFardos := nRegl
	AGRAC003ME()
	AGRMOSTOTAIS(aMatCam,vVetDPar,,@oBrw)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AGC003Stat
Função para verificar se o fardo está disponivel, reservado ou entregue
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------
Static Function AGC003Stat()
	Local cStatus := ""
	If Empty( &(aArqTemp[12,1]))
		cStatus := "Disponível"
	ElseIf Empty(&(aArqTemp[28,1]))
		cStatus := "Reservado"
	Else
		cStatus := "Entregue"
	EndIf 
Return cStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRMMToPol
Função para converter milimetros para polegadas
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------
Function AGRMMToPol(nMili)
	Local nPol := nMili

	If NN1->(ColumnPos('NN1_CODSAF' )) > 0
		If mv_par21 == 2
			nPol := nMili * 0.03937
		EndIf
	Else
		If mv_par20 == 2
			nPol := nMili * 0.03937
		EndIf
	EndIf
		
Return nPol

/*
###################################################################################
# Função   : AGRAC003RT                                                           #
# Descrição: Recalcula os totalizadores após confirmar o(s) filtro(s)             #
# Autor    : Inácio Luiz Kolling                                                  #
# Data     : 17/09/2014                                                           #  
###################################################################################
*/
Function AGRAC003RT()
	oBrw:ExecuteFilter(.t.)
	oBrw:SetUseFilter(.T.)
	nTotFardos := 0
	vVetDPar   := {}
	AGRCRIAMATOT(aMatCam,@vVetDPar)
	ARGSETIFARQUI(cAliasTRB)
	While !Eof()
		AGRAC003TA()	
		nTotFardos ++
		DbSkip()
	End	
	AGRAC003ME()
	AGRMOSTOTAIS(aMatCam,vVetDPar,,@oBrw)	
	ARGSETIFARQUI(cAliasTRB)		
Return

/*
###################################################################################
# Função   : AGRAC003TA                                                           #
# Descrição: Totaliza os itens                                                    #
# Autor    : Inácio Luiz Kolling                                                  #
# Data     : 17/09/2014                                                           #  
###################################################################################
*/
Function AGRAC003TA()
	vVetDPar[2]  += (cAliasTRB)->DX7_MIC
	vVetDPar[3]  += (cAliasTRB)->DX7_RES
	vVetDPar[4]  += (cAliasTRB)->DX7_FIBRA
	vVetDPar[5]  += (cAliasTRB)->DX7_UI
	vVetDPar[6]  += (cAliasTRB)->DX7_SFI
	vVetDPar[7]  += (cAliasTRB)->DX7_ELONG
	vVetDPar[8]  += (cAliasTRB)->DX7_LEAF
	vVetDPar[9]  += (cAliasTRB)->DX7_AREA
	vVetDPar[10] += (cAliasTRB)->DX7_CSP
	vVetDPar[11] += (cAliasTRB)->DX7_SCI
	vVetDPar[12] += (cAliasTRB)->DX7_RD
	vVetDPar[13] += (cAliasTRB)->DX7_COUNT
	vVetDPar[14] += (cAliasTRB)->DX7_UHM
	vVetDPar[15] += (cAliasTRB)->DX7_MATU
	vVetDPar[16] += (cAliasTRB)->DX7_MAISB
Return
 
/*
###################################################################################
# Função   : AGRAC003ME                                                           #
# Descrição: Calcula as médias                                                    #
# Autor    : Inácio Luiz Kolling                                                  #
# Data     : 17/09/2014                                                           #  
###################################################################################
*/
Function AGRAC003ME()
	vVetDPar[1]  := nTotFardos
	vVetDPar[2]  := vVetDPar[2] / nTotFardos 
	vVetDPar[3]  := vVetDPar[3] / nTotFardos 
	vVetDPar[4]  := vVetDPar[4] / nTotFardos 
	vVetDPar[5]  := vVetDPar[5] / nTotFardos 
	vVetDPar[6]  := vVetDPar[6] / nTotFardos
	vVetDPar[7]  := vVetDPar[7] / nTotFardos  
	vVetDPar[8]	:= vVetDPar[8] / nTotFardos 
	vVetDPar[9]	:= vVetDPar[9] / nTotFardos 
	vVetDPar[10] := vVetDPar[10] / nTotFardos 
	vVetDPar[11] := vVetDPar[11] / nTotFardos 
	vVetDPar[12] := vVetDPar[12] / nTotFardos 
	vVetDPar[13] := vVetDPar[13] / nTotFardos 
	vVetDPar[14] := vVetDPar[14] / nTotFardos 
	vVetDPar[15] := vVetDPar[15] / nTotFardos 
	vVetDPar[16] := vVetDPar[16] / nTotFardos
Return
