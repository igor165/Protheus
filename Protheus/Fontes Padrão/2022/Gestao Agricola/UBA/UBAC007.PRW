#include "ubac007.ch"
#include "protheus.ch"
#include "fwbrowse.ch"
#include "fwmvcdef.ch"

Static oArqTemp := Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} UBAC007
Consulta Resumo de Produção/Beneficiamento por talhao

@author: Aécio Gomes
@since: 23/0/2013
@Uso: SIGAAGR(UBA)
@version MP11.8                
/*/
//-------------------------------------------------------------------------------------
Function UBAC007()

	Local oBrowse	:= Nil
	Local oColumn   := Nil
	Local oDlg      := Nil
	Local aRet		:= {}
	Local aCoors	:= FWGetDialogSize( oMainWnd )
	Local bKeyF12	:= {|| If( Pergunte("UBAC007", .T.), ( cAliasTRB := UBAC007TRB()[1], oBrowse:SetAlias(cAliasTRB) , oBrowse:Refresh()), .T. ) }
	Private cAliasTRB	:= ""

	Private _lNovSafra 	:= .F.
		
	If NN1->(ColumnPos('NN1_CODSAF' )) > 0
		_lNovSafra := .T.
	EndIf
	
	If !Pergunte("UBAC007", .T.)
		Return
	EndIf
	
	aRet := UBAC007TRB()
	cAliasTRB 	:= aRet[1] // Arquivo temporario
	aArqTemp 	:= aRet[2] // Estrutura do arquivo temporario
	If Select(cAliasTRB) > 0

		(cAliasTRB)->(DbSetOrder(1))
		//- Coordenadas da area total da Dialog
		oSize := FWDefSize():New(.T.)
		oSize:AddObject('DLG',100,100,.T.,.T.)
		oSize:SetWindowSize(aCoors)
		oSize:lProp 	:= .T.
		oSize:Process()
		DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] OF oMainWnd PIXEL

		//-------------------------------------------------------------------
		// Define o Browse
		//-------------------------------------------------------------------
		DEFINE FWFORMBROWSE oBrowse DATA TABLE ALIAS cAliasTRB DESCRIPTION STR0001 OF oDlg  //"Consulta Resumo de Produção/Beneficiamento"
		oBrowse:DisableReport()
		oBrowse:AddButton(STR0002,{|| UBAR005(cAliasTRB)}, ,8 ,0)  //"Imprimir"
		oBrowse:AddButton("Sair",{||oDlg:End()},,,,,,'10')
		oBrowse:SetParam(bKeyF12) // Seta tecla F12
		oBrowse:SetTemporary(.T.)
		oBrowse:SetFieldFilter(CriaArray())
		oBrowse:SetdbfFilter(.T.)
		oBrowse:SetuseFilter(.T.)
		oBrowse:DisableDetails()
		ADD COLUMN oColumn DATA { || &(aArqTemp[1,1])  } TITLE STR0003	SIZE  aArqTemp[1,3]  ;
		PICTURE PesqPict("DXL","DXL_PRDTOR") 	TYPE TamSX3("DXL_PRDTOR")[3]		OF oBrowse //"Produtor"
		ADD COLUMN oColumn DATA { || &(aArqTemp[2,1])  } TITLE STR0004	SIZE  aArqTemp[2,3]  ;
		PICTURE PesqPict("DXL","DXL_LJPRO")  	TYPE TamSX3("DXL_LJPRO")[3]			OF oBrowse //"Loja"
		ADD COLUMN oColumn DATA { || &(aArqTemp[3,1])  } TITLE STR0005	SIZE  aArqTemp[3,3]  ;
		PICTURE PesqPict("DXL","DXL_FAZ") 	  	TYPE TamSX3("DXL_FAZ")[3]			OF oBrowse //"Fazenda"
		ADD COLUMN oColumn DATA { || &(aArqTemp[4,1])  } TITLE STR0006	SIZE  aArqTemp[4,3]  ;
		PICTURE PesqPict("DXL","DXL_TALHAO") 	TYPE TamSX3("DXL_TALHAO")[3]		OF oBrowse //"Talhao"
		ADD COLUMN oColumn DATA { || &(aArqTemp[5,1])  } TITLE STR0007	SIZE  aArqTemp[5,3]  ;
		PICTURE PesqPict("NN4","NN4_HECTAR") 	TYPE TamSX3("NN4_HECTAR")[3]		OF oBrowse //"Hectares"
		ADD COLUMN oColumn DATA { || &(aArqTemp[6,1])  } TITLE STR0008	SIZE  aArqTemp[6,3]  ;
		PICTURE PesqPict("DXL","DXL_CODVAR") 	TYPE TamSX3("DXL_CODVAR")[3]		OF oBrowse //"Variedade"
		ADD COLUMN oColumn DATA { || &(aArqTemp[7,1])  } TITLE STR0009	SIZE  aArqTemp[7,3]  ;
		PICTURE PesqPict("NN4","NN4_DESVAR") 	TYPE TamSX3("NN4_DESVAR")[3]		OF oBrowse //"Descrição"
		ADD COLUMN oColumn DATA { || &(aArqTemp[8,1])  } TITLE STR0010	SIZE  aArqTemp[8,3]  ;
		PICTURE "@E 9,999,999,999" 		  		TYPE "N"								OF oBrowse //"Qtde. Fardao"
		ADD COLUMN oColumn DATA { || &(aArqTemp[9,1])  } TITLE STR0011	SIZE  aArqTemp[9,3]  ;
		PICTURE PesqPict("DXS","DXS_PSLIQU") 	TYPE TamSX3("DXS_PSLIQU")[3]		OF oBrowse //"Peso Fardao"
		ADD COLUMN oColumn DATA { || &(aArqTemp[10,1]) } TITLE STR0012	SIZE  aArqTemp[10,3] ;
		PICTURE "@E 9,999,999,999" 		  		TYPE "N"								OF oBrowse //"Fardos"
		ADD COLUMN oColumn DATA { || &(aArqTemp[11,1]) } TITLE STR0013	SIZE  aArqTemp[11,3] ;
		PICTURE PesqPict("DXS","DXS_PSLIQU") 	TYPE TamSX3("DXS_PSLIQU")[3]		OF oBrowse //"Peso Fardos"
		//-------------------------------------------------------------------
		// Ativação do Browse
		//-------------------------------------------------------------------
		ACTIVATE FWFORMBROWSE oBrowse

		ACTIVATE MSDIALOG oDlg CENTER

		(cAliasTRB)->(DbCloseArea())

	EndIf

    //Elimina a tabela temporária, se houver
    AGRDLTPTB(oArqTemp)

Return

Static Function CriaArray()
	Local aCampos := {}
	Local aCmpsTam := {}

	aCmpsTam := TamSx3("NJ0_CODENT");AAdd(aCampos,{"PRODUTOR" , STR0003 ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSx3("NJ0_LOJENT");AAdd(aCampos,{"LOJA"     , STR0004 ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSx3("NN4_FAZ"   );AAdd(aCampos,{"FAZENDA"  , STR0005 ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSx3("NN4_TALHAO");AAdd(aCampos,{"TALHAO"   , STR0006 ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := {10,   2,   "N"    };AAdd(aCampos,{"HECTARES" , STR0007 ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSx3("NN4_CODVAR");AAdd(aCampos,{"VARIEDADE", STR0008 ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSx3("NN4_DESVAR");AAdd(aCampos,{"DESCVAR"  , STR0009 ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := {10,   0,   "N"    };AAdd(aCampos,{"QTD_FDAO" , STR0010 ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSx3("DXS_PSLIQU");AAdd(aCampos,{"PS_FARDAO", STR0011 ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := {10,   0,   "N"    };AAdd(aCampos,{"QTD_FDI"  , STR0012 ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSx3("DXS_PSLIQU");AAdd(aCampos,{"PS_FDI"   , STR0013 ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSx3("NN4_SAFRA");AADD(aArqTemp, {"SAFRA" 	,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
Return aCampos


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} UBAC007TRB
Monta arquivo de trabalho

@author: Aécio Gomes
@since: 23/0/2013
@Uso: SIGAAGR(UBA)
/*/
//-------------------------------------------------------------------------------------
Function UBAC007TRB()
	Local aArqTemp 	:= {}
	Local aIndex    := {}
	Local cArqTemp	:= ""
	Local cQry1		:= ""
	Local cQry2		:= ""
	Private cSafra		:= ""
	Private cProduto    := ""
	Private cProdutor 	:= ""
	Private cLoja			:= ""
	Private cFazenda		:= ""
	Private cVariedade	:= ""
	Private cTalhao		:= ""
	Private nStatus		:= 0
	Private nQtdl        := 0
	Private cAlias	    := ""
    
    If (!(Type("cAliasTRB") = "U"))
	    If (!Empty(cAliasTRB)) .AND. (Select(cAliasTRB) > 0)
	      (cAliasTRB)->(dbCloseArea())
    	EndIf
    EndIf

	// Cria arquivo de trabalho
	aCmpsTam := TamSx3("NJ0_CODENT");AADD(aArqTemp,{"PRODUTOR" ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSx3("NJ0_LOJENT");AADD(aArqTemp,{"LOJA"     ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSx3("NN4_FAZ"   );AADD(aArqTemp,{"FAZENDA"  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSx3("NN4_TALHAO");AADD(aArqTemp,{"TALHAO"   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := {10,   2,   "N"    };AADD(aArqTemp,{"HECTARES" ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSx3("NN4_CODVAR");AADD(aArqTemp,{"VARIEDADE",aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSx3("NN4_DESVAR");AADD(aArqTemp,{"DESCVAR"  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := {10,   0,   "N"    };AADD(aArqTemp,{"QTD_FDAO" ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSx3("DXS_PSLIQU");AADD(aArqTemp,{"PS_FARDAO",aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := {10,   0,   "N"    };AADD(aArqTemp,{"QTD_FDI"  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSx3("DXS_PSLIQU");AADD(aArqTemp,{"PS_FDI"   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSx3("NN4_SAFRA");AADD(aArqTemp, {"SAFRA" 	,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})

	//-- Cria Indice de Trabalho
	cArqTemp := GetNextAlias()
    aAdd(aIndex, {"", "PRODUTOR+LOJA+FAZENDA+TALHAO"})
    aAdd(aIndex, {"", "PRODUTOR+LOJA+FAZENDA+VARIEDADE"})
    oArqTemp := AGRCRTPTB(cArqTemp, {aArqTemp, aIndex })
    cAliasTRB := cArqTemp
   
    If _lNovSafra
		cSafra 	    := MV_PAR01
		cProduto 	:= MV_PAR02
		cProdutor	:= mv_par03
		cLoja		:= mv_par04
		cFazenda	:= mv_par05
		cTalhao	    := mv_par06
		cVariedade	:= mv_par07
		nStatus	    := mv_par08
	Else
		cSafra 	    := MV_PAR01
		cProdutor	:= mv_par02
		cLoja		:= mv_par03
		cFazenda	:= mv_par04
		cTalhao	    := mv_par05
		cVariedade	:= mv_par06
		nStatus	    := mv_par07
	EndIf	

	//Filtro de unidade de beneficiamento
	
	If _lNovSafra
		If !Empty(cProduto)
			cQry1 += "DXL_CODPRO = '"+cProduto+"' AND "
		EndIf
	EndIf	
	
	If _lNovSafra
		If !Empty(mv_par10)
			cQry1 += "DXL.DXL_CODUNB = '"+mv_par10+"' AND "	 
		EndIf
	Else
		If !Empty(mv_par09)
			cQry1 += "DXL.DXL_CODUNB = '"+mv_par09+"' AND "	 
		EndIf
	EndIf	

	//Filtro de somente beneficiados
	If _lNovSafra
		If mv_par09 = 1
			cQry1 += "DXL.DXL_STATUS >= '5' AND "
		EndIf
	Else
		If mv_par08 = 1
			cQry1 += "DXL.DXL_STATUS >= '5' AND "
		EndIf
	EndIf	
	
	If !Empty(cProdutor)
		cQry1 += "DXL_PRDTOR = '"+cProdutor+"' AND "
		If !Empty(cLoja)
			cQry1 += "DXL_LJPRO = '"+cLoja+"' AND "
		EndIf
	EndIf
	If !Empty(cFazenda)
		cQry1 += "DXL_FAZ = '"+cFazenda+"' AND "
		cQry2 += "DXL_FAZ = '"+cFazenda+"' AND "
	EndIf
	If !Empty(cTalhao)
		cQry1 += "DXL_TALHAO = '"+cTalhao+"' AND "
	EndIf
	If !Empty(cVariedade)
		cQry1 += "DXL_CODVAR = '"+cVariedade+"' AND "
	EndIf

	If  nStatus   = 1
		cQry1 += "NN3_FECHAD = 'N' AND "
	ElseIf nStatus =	2
		cQry1 += "NN3_FECHAD = 'S' AND "
	Else

	EndIf
	cQry1 := "%"+cQry1+"%"
	cQry2 := "%"+cQry2+"%"

	#IFDEF TOP
	// Lista fardos por talhao
	cAlias := "AliasQry"

	BeginSql Alias cAlias

	SELECT
	NN4.NN4_SAFRA, DXL.DXL_PRDTOR, DXL.DXL_LJPRO, DXL.DXL_FAZ, NN4.NN4_TALHAO, NN4.NN4_CODVAR, NN4.NN4_DESVAR,
	(SELECT
	SUM(NN4_HECTAR)
	FROM
	%table:NN4%
	WHERE
	NN4_FILIAL = %xFilial:NN4% AND
	NN4_SAFRA = NN4.NN4_SAFRA AND
	NN4_FAZ = DXL.DXL_FAZ AND
	NN4_TALHAO = NN4.NN4_TALHAO AND
	NN4_CODVAR = NN4.NN4_CODVAR AND
	%notDel%) AS HECTARES,
	COUNT(DXL.DXL_CODIGO) AS QTDFDAO,
	SUM(DXL.DXL_PSLIQU) AS PSTOTFDAO
	FROM
	%table:DXL% DXL
	JOIN
	%table:NN4% NN4 ON 	NN4_FILIAL 	= %xFilial:NN4% AND
	NN4_SAFRA 	= DXL_SAFRA AND
	NN4_FAZ		= DXL_FAZ AND
	NN4_TALHAO	= DXL_TALHAO AND
	NN4_CODVAR	= DXL_CODVAR AND
	NN4.%notDel%
	LEFT JOIN
	%table:NN3% NN3 ON 	NN3_FILIAL	= %xFilial:NN3% AND
	NN3_SAFRA	= DXL_SAFRA AND
	NN3_FAZ		= DXL_FAZ AND
	NN3_TALHAO	= DXL_TALHAO AND
	NN3.%notDel% 
	WHERE
	DXL.DXL_FILIAL = %xFilial:DXL% AND
	DXL.DXL_SAFRA = %exp:cSafra% AND
	%Exp:cQry1%
	DXL.%notDel%

	GROUP BY NN4.NN4_SAFRA, DXL.DXL_PRDTOR, DXL.DXL_LJPRO, DXL.DXL_FAZ, NN4.NN4_TALHAO, NN4.NN4_CODVAR, NN4.NN4_DESVAR
	ORDER BY DXL_FAZ, NN4_TALHAO, NN4.NN4_CODVAR

	EndSql
	(cAlias)->(dbGotop())
	Count To nQtdl
	Processa({|| UBAC007PT() },STR0015)
	(cAlias)->(dbCloseArea())

	(cAliasTRB)->(dbGoTop())
	#ENDIF
Return({cAliasTRB, aArqTemp})

/*-------------------------------------------------------------------------------------
UBAC007PT Processamento
@param: Nil
@author: Inácio Luiz Kolling
@since: 18/06/2014
@Uso: UBAC007
-------------------------------------------------------------------------------------
*/
Static Function UBAC007PT()
	ProcRegua(nQtdl)
	nRegl := 0
	(cAlias)->(dbGotop())
	While  (cAlias)->(!Eof())
		nRegl ++
		IncProc(STR0016+Alltrim(Str(nRegl,5))+" / "+Alltrim(Str(nQtdl,5))) //"Processando Bloco -> "
		cAliasDXI := GetNextAlias()

		BeginSql Alias cAliasDXI

		SELECT
		COUNT(DXI.DXI_ETIQ) AS QTDFDI, SUM(DXI.DXI_PSLIQU) AS PSTOTFDI
		FROM
		%table:DXL% DXL, %table:DXI% DXI
		WHERE
		DXI.%notDel% AND
		DXL.%notDel% AND
		DXI.DXI_FILIAL  = %xFilial:DXI% AND
		DXL.DXL_FILIAL  = %xFilial:DXL% AND
		DXI.DXI_FARDAO = DXL.DXL_CODIGO AND
		DXI.DXI_SAFRA = DXL.DXL_SAFRA AND
		DXI.DXI_PRDTOR = DXL.DXL_PRDTOR AND
		DXI.DXI_LJPRO = DXL.DXL_LJPRO AND
		DXI.DXI_FAZ = DXL.DXL_FAZ AND
		DXI.DXI_CODVAR = DXL.DXL_CODVAR AND
		DXL.DXL_PRDTOR = %exp:(cAlias)->(DXL_PRDTOR)% AND
		DXL.DXL_LJPRO = %exp:(cAlias)->(DXL_LJPRO)% AND
		DXL.DXL_SAFRA = %exp:(cAlias)->(NN4_SAFRA)% AND
		DXL.DXL_FAZ = %exp:(cAlias)->(DXL_FAZ)% AND
		DXL.DXL_TALHAO = %exp:(cAlias)->(NN4_TALHAO)% AND
		DXL.DXL_CODVAR = %exp:(cAlias)->(NN4_CODVAR)%

		GROUP BY DXL.DXL_PRDTOR, DXL.DXL_LJPRO, DXL.DXL_FAZ, DXL.DXL_TALHAO, DXL.DXL_CODVAR
		ORDER BY DXL.DXL_FAZ, DXL.DXL_TALHAO, DXL.DXL_CODVAR

		EndSql

		(cAliasDXI)->(dbGoTop())

		While (cAliasDXI)->(!Eof())
			Reclock( cAliasTRB, .T.)
			Replace (cAliasTRB)->PRODUTOR 	With (cAlias)->DXL_PRDTOR
			Replace (cAliasTRB)->LOJA 		With (cAlias)->DXL_LJPRO
			Replace (cAliasTRB)->FAZENDA 	With (cAlias)->DXL_FAZ
			Replace (cAliasTRB)->TALHAO 		With (cAlias)->NN4_TALHAO
			Replace (cAliasTRB)->HECTARES 	With (cAlias)->(HECTARES)
			Replace (cAliasTRB)->VARIEDADE 	With (cAlias)->NN4_CODVAR
			Replace (cAliasTRB)->DESCVAR 	With (cAlias)->NN4_DESVAR
			Replace (cAliasTRB)->QTD_FDAO 	With (cAlias)->(QTDFDAO)
			Replace (cAliasTRB)->PS_FARDAO 	With (cAlias)->(PSTOTFDAO)
			Replace (cAliasTRB)->QTD_FDI 	With (cAliasDXI)->(QTDFDI)
			Replace (cAliasTRB)->PS_FDI 		With (caliasDXI)->(PSTOTFDI)
			MsUnlock()
			(cAliasDXI)->(dbSkip())
		End
		(cAliasDXI)->(dbCloseArea())
		(cAlias)->(dbSkip())
	End
Return
