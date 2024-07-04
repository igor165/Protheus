#INCLUDE "ubac008.ch"
#INCLUDE "protheus.CH"
#INCLUDE "fwmvcdef.CH"
#INCLUDE "report.ch"

Static oArqTemp1 := Nil
Static oArqTemp2 := Nil


/* -------------------------------------------------------------------------------------
UBAC008 Consulta Geral de Bloco
@param: Nil
@author: Inácio Luiz Kolling
@since: 10/06/2014
@Uso: UBA
-------------------------------------------------------------------------------------
*/
Function UBAC008()
	Local oBrowse	  	:= Nil
	Local oColumn		:= Nil
	Local oDlg     		:= Nil
	Local aRet		  	:= {}
	Local cPerg	  		:= "UBAC008"
	
	//variavel de unidade de beneficiamento
	Private cAliasTRB     := ""
	Private cAliasTRB2     := ""
	Private lRet		:= .F.	
	Private bKeyF12  	    := {|| If( Pergunte("UBAC008", .T.), ( cAliasTRB := UBAC008TRB()[1], oBrowse:SetAlias(cAliasTRB), oBrowse:Refresh()), .T. ) }
	
	Private cQry 		:= ""
	Private nQtdl  		:= 0
	Private aCoors  	:= FWGetDialogSize( oMainWnd )
	SetKey( VK_F12, bKeyF12)

	If !Pergunte(cPerg, .T.)
		Return
	EndIf

	aRet := UBAC008TRB()
	cAliasTRB := aRet[1] // Arquivo temporario
	aArqTemp  := aRet[2] // Estrutura do arquivo temporario
	If nQtdl = 0
		MsgInfo(STR0027,STR0028)
	Else
		(cAliasTRB)->(DbSetOrder(1))
		//- Coordenadas da area total da Dialog
		oSize := FWDefSize():New(.T.)
		oSize:AddObject('DLG',100,100,.T.,.T.)
		oSize:SetWindowSize(aCoors)
		oSize:lProp 	:= .T.
		oSize:Process()
		
		DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] OF oMainWnd PIXEL
		DEFINE FWFORMBROWSE oBrowse DATA TABLE ALIAS cAliasTRB DESCRIPTION STR0001 OF oDlg  //"Consulta de Bloco"
		oBrowse:AddButton(STR0047,{||UBAC008I()},,,,,,'10')
		oBrowse:AddButton("Sair",{||oDlg:End()},,,,,,'10')
		oBrowse:SetTemporary(.T.)
		oBrowse:SetFieldFilter(CriaArray())
		oBrowse:bHeaderClick := {|| OrdenaBrowse(oBrowse) }
		oBrowse:SetdbFFilter(.T.)
		oBrowse:SetUseFilter(.T.)
		oBrowse:DisableDetails()
	
		ADD COLUMN oColumn DATA { || &(aArqTemp[1,1]) } TITLE STR0002 SIZE  aArqTemp[1,3]  ;
			PICTURE PesqPict("DXI","DXI_BLOCO") 	TYPE TamSX3("DXI_BLOCO")[3]			OF oBrowse //"Numero do Bloco"
		ADD COLUMN oColumn DATA { || &(aArqTemp[3,1]) } TITLE STR0003 SIZE  aArqTemp[3,3]  ;
			PICTURE PesqPict("DXD","DXD_ENDXYZ")	TYPE TamSX3("DXD_ENDXYZ")[3]		OF oBrowse //"Endereco"
		ADD COLUMN oColumn DATA { || &(aArqTemp[4,1]) } TITLE STR0004 SIZE  aArqTemp[4,3]  ;
			PICTURE PesqPict("DXI","DXI_DATA")   	TYPE TamSX3("DXI_DATA")[3]			OF oBrowse //"data"
		ADD COLUMN oColumn DATA { || &(aArqTemp[5,1]) } TITLE STR0005 SIZE  aArqTemp[5,3]  ;
			PICTURE PesqPict("DXI","DXI_CLACOM") 	TYPE TamSX3("DXI_CLACOM")[3]		OF oBrowse //"tipo"
		ADD COLUMN oColumn DATA { || &(aArqTemp[6,1]) } TITLE STR0006 SIZE  aArqTemp[6,3]  ;
			PICTURE PesqPict("DXD","DXD_QTDVNC") 	TYPE TamSX3("DXD_QTDVNC")[3]		OF oBrowse //"quantidade vinculada
		ADD COLUMN oColumn DATA { || &(aArqTemp[7,1]) } TITLE STR0007 SIZE  aArqTemp[7,3]  ;
			PICTURE PesqPict("DXD","DXD_QTDVNC")	TYPE TamSX3("DXD_QTDVNC")[3]		OF oBrowse //"saida"
		ADD COLUMN oColumn DATA { || &(aArqTemp[8,1]) } TITLE STR0008 SIZE  aArqTemp[8,3]  ;
			PICTURE PesqPict("DXD","DXD_QTDVNC") 	TYPE TamSX3("DXD_QTDVNC")[3]		OF oBrowse //"reserva"
		ADD COLUMN oColumn DATA { || &(aArqTemp[8,1]) } TITLE STR0009 SIZE  aArqTemp[9,3]  ;
			PICTURE PesqPict("DXD","DXD_QTDVNC") 	TYPE TamSX3("DXD_QTDVNC")[3]		OF oBrowse //"saldo"
		ADD COLUMN oColumn DATA { || &(aArqTemp[10,1]) } TITLE STR0010 SIZE  aArqTemp[10,3]  ;
			PICTURE PesqPict("DXF","DXF_QTDPRO") 	TYPE TamSX3("DXF_QTDPRO")[3]		OF oBrowse //"peso total"
		ADD COLUMN oColumn DATA { || &(aArqTemp[11,1])} TITLE STR0011 SIZE  aArqTemp[11,3] ;
			PICTURE PesqPict("DXF","DXF_QTDPRO")	TYPE TamSX3("DXF_QTDPRO")[3]		OF oBrowse //"saida peso"
		ADD COLUMN oColumn DATA { || &(aArqTemp[12,1])} TITLE STR0012 SIZE  aArqTemp[12,3] ;
			PICTURE PesqPict("DXF","DXF_QTDPRO")	TYPE TamSX3("DXF_QTDPRO")[3]		OF oBrowse //"reserva peso"
		ADD COLUMN oColumn DATA { || &(aArqTemp[13,1])} TITLE STR0013 SIZE  aArqTemp[13,3] ;
			PICTURE PesqPict("DXF","DXF_QTDPRO") 	TYPE TamSX3("DXF_QTDPRO")[3]		OF oBrowse //"saldo"
		oBrowse:SetDoubleClick({|| ViewFard(cAliasTRB)})
		
		
		ACTIVATE FWFORMBROWSE oBrowse
		ACTIVATE MSDIALOG oDlg CENTER
	EndIf	
	(cAliasTRB)->(DbCloseArea())
	SetKey( VK_F12, Nil)
	
    //Elimina a tabela temporária, se houver
    AGRDLTPTB(oArqTemp1)
    AGRDLTPTB(oArqTemp2)	
	
Return

/*
CriaArray Cria matriz para o browse
@param: Nil
@author: Inácio Luiz Kolling
@since: 10/06/2014
@Uso: UBA
-------------------------------------------------------------------------------------
*/
Static Function CriaArray()
	Local aCampos := {}
	AAdd(aCampos,{"BLOCO"    ,"BLOCO"    ,"C",TamSX3("DXI_CODIGO")[1],0,})
	AAdd(aCampos,{"ENDEREC"  ,"ENDEREC"  ,"C",6,0,})
	AAdd(aCampos,{"DATAEMB"  ,"DATAEMB"  ,"D",8,0,})
	AAdd(aCampos,{"TIPO"     ,"TIPO"      ,"C",4,0,})
	AAdd(aCampos,{"FARDOS"   ,"FARDOS"   ,"N",10,0,})
	AAdd(aCampos,{"SAIDA1"   ,"SAIDA1"   ,"N",10,0,})
	AAdd(aCampos,{"RESERVA"  ,"RESERVA"  ,"N",10,0,})
	AAdd(aCampos,{"SALDO1"   ,"SALDO1"   ,"N",10,0,})
	AAdd(aCampos,{"PESOT"    ,"PESOT"    ,"N",10,2,})
	AAdd(aCampos,{"SAIDA2"   ,"SAIDA2"   ,"N",10,2,})
	AAdd(aCampos,{"RESERVA2" ,"RESERVA2","N",10,2,})
	AAdd(aCampos,{"SALDOF"   , "SALDOF"  ,"N",10,2,})
Return aCampos

/*
UBAC008TRB  Cria arquivo de trabalho com dados para exibição da consulta
@param: Nil
@author: Inácio Luiz Kolling
@since: 10/06/2014
@Uso: UBA
-------------------------------------------------------------------------------------
*/
Function UBAC008TRB()
	Local cArqTemp	  := ""

	Private aArqTemp := {}
	If (!Empty(cAliasTRB)) .AND. (Select(cAliasTRB) > 0)
		(cAliasTRB)->(dbCloseArea())
	EndIf

	// Cria arquivo de trabalho
	AAdd(aArqTemp,{"BLOCO"    ,"C",TamSX3("DXI_CODIGO")[1],0,})
	AAdd(aArqTemp,{"SAFRA"    ,"C",TamSX3("DXI_SAFRA")[1],0,})
	AAdd(aArqTemp,{"ENDEREC"  ,"C",6,0,})
	AAdd(aArqTemp,{"DATAEMB"  ,"D",8,0,})
	AAdd(aArqTemp,{"TIPO"     ,"C",4,0,})
	AAdd(aArqTemp,{"FARDOS"   ,"N",10,0,})
	AAdd(aArqTemp,{"SAIDA1"   ,"N",10,0,})
	AAdd(aArqTemp,{"RESERVA"  ,"N",10,0,})
	AAdd(aArqTemp,{"SALDO1"   ,"N",10,0,})
	AAdd(aArqTemp,{"PESOT"    ,"N",10,2,})
	AAdd(aArqTemp,{"SAIDA2"   ,"N",10,2,})
	AAdd(aArqTemp,{"RESERVA2" ,"N",10,2,})
	AAdd(aArqTemp,{"SALDOF"   ,"N",10,2,})

//-- Cria Indice de Trabalho
    cArqTemp  := GetNextAlias()
    oArqTemp1 := AGRCRTPTB(cArqTemp, {aArqTemp, {} })
    cAliasTRB := cArqTemp
        
	cAlias := GetNextAlias()

	cQry := " SELECT DXD.DXD_CODIGO,DXD_SAFRA,DXD.DXD_ENDXYZ,DXD.DXD_QTDVNC,DXD.DXD_CLACOM,DXD.DXD_DATAEM,DXI.DXI_PSLIQU,DXI.DXI_BLOCO,DXI.DXI_CODRES,DXI.DXI_ROMSAI"
	cQry +=   " FROM " +RetSqlName("DXD")+ " DXD "
	cQry +=  " INNER JOIN " +RetSqlName("DXI")+ " DXI ON DXI.D_E_L_E_T_ <> '*'"
	cQry +=    " AND DXD.DXD_CODIGO = DXI.DXI_BLOCO AND DXD.DXD_SAFRA = DXI.DXI_SAFRA "
	cQry +=  " WHERE DXD_FILIAL = '"+xFilial("DXD")+"'"
	cQry +=    " AND DXI_FILIAL = '"+xFilial("DXI")+"'"
	cQry +=    " AND DXD_QTDVNC > 0 AND DXD.D_E_L_E_T_ = ' '"
	
	//Filtro de unidade de beneficiamento
	If !Empty(mv_par06)
		cQry += " AND DXD.DXD_CODUNB = '"+mv_par06+"'" 
	EndIf	
	
	If !Empty(mv_par01)
		cQry +=	" AND DXD.DXD_SAFRA = '"+mv_par01+"'"
	EndIf
	If !Empty(mv_par02)
		cQry +=	" AND DXD.DXD_PRDTOR = '"+mv_par02+"'"
	EndIf
	If !Empty(mv_par03)
		cQry +=	" AND DXD.DXD_LJPRO  = '"+mv_par03+"'"
	EndIf
	If !Empty(mv_par04)
		cQry +=	" AND DXD.DXD_FAZ = '"+mv_par04+"'"
	EndIf
	If !Empty(mv_par05)
		cQry +=	" AND DXD.DXD_CODIGO = '"+mv_par05+"'"
	EndIf
   
	cQry += " Order by DXD.DXD_CODIGO"
	cQry := ChangeQuery(cQry)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cAlias,.F.,.T.)
 
	Count To nQtdl
	Processa({|| UBAC008P() },STR0015)

	(cAlias)->(dbCloseArea())
	DbselectArea(cArqTemp)
	dbGoTop()
Return({cArqTemp, aArqTemp})

/* -------------------------------------------------------------------------------------
UBAC008P Processamento
@param: Nil
@author: Inácio Luiz Kolling
@since: 10/06/2014
@Uso: UBAC008
-------------------------------------------------------------------------------------
*/
Static Function UBAC008P()
	(cAlias)->(dbGotop())
	ProcRegua(nQtdl)
	nRegl := 0
	While (cAlias)->(!Eof())
		cBloco := (cAlias)->DXD_CODIGO
		cTipo  := (cAlias)->DXD_CLACOM
		cEnder := (cAlias)->DXD_ENDXYZ
		nQTDFr := (cAlias)->DXD_QTDVNC
		dData  := (cAlias)->DXD_DATAEM
		nPesoL := (cAlias)->DXI_PSLIQU
		cSafra	:= (cAlias)->DXD_SAFRA
		nQTDRe := 0
		nQTDSa := 0
		While (cAlias)->(!Eof()) .AND. (cAlias)->DXD_CODIGO = cBloco
			nRegl ++
			nQTDRe += If((!Empty((cAlias)->DXI_CODRES) .And.  Empty((cAlias)->DXI_ROMSAI)),1,0)
			nQTDSa += If((!Empty((cAlias)->DXI_CODRES) .And. !Empty((cAlias)->DXI_ROMSAI)),1,0)
			IncProc(STR0016+Alltrim(Str(nRegl,5))+" / "+Alltrim(Str(nQtdl,5))) //"Processando Bloco -> "
			(cAlias)->(dbSkip())
		End
		DbselectArea(cAliasTRB)
		Reclock(cAliasTRB,.T.)
		Replace BLOCO		With cBloco
		Replace SAFRA 	With cSafra
		Replace DATAEMB 	With If(ValType(dData) = "C",StoD(dData),dData)
		Replace TIPO		With cTipo
		Replace FARDOS	With nQTDFr
		Replace SAIDA1	With nQTDSa
		Replace RESERVA	With nQTDRe
		Replace SALDO1	With nQTDFr - (nQTDSa + nQTDRe)
		Replace PESOT		With nPesoL * nQTDFr
		Replace SAIDA2	With nQTDSa * nPesoL
		Replace RESERVA2	With nQTDRe * nPesoL
		Replace SALDOF	With nPesoL * nQTDFr - (nQTDSa + nQTDRe) * nPesoL
		(cAliasTRB)->ENDEREC		:= cEnder // Não mexer essa linha
		Msunlock()
		DbselectArea(cAlias)
	Enddo
Return

/* -------------------------------------------------------------------------------------
ViewFard Mostra os fardos do bloco selecionado (Posicionado na consulta dos blocos quando
         é dado um duplo click no item
@param: Nil
@author: Inácio Luiz Kolling
@since: 17/06/2014
@Uso: UBAC008
-------------------------------------------------------------------------------------
*/
Static Function ViewFard(cAliasTmp)
	Private aArqTemp1 := {}
	
	SetKey( VK_F12, Nil)
	
	aRet := UBAC0082T()
	cAliasTRB2 := aRet[1] // Arquivo temporario
	aArqTemp1  := aRet[2] // Estrutura do arquivo temporario
	
	If nQtdl = 0
		MsgInfo(STR0027,STR0028)
	Else
		(cAliasTRB2)->(DbSetOrder(1))
	//- Coordenadas da area total da Dialog
		oSize := FWDefSize():New(.T.)
		oSize:AddObject('DLG',100,100,.T.,.T.)
		oSize:SetWindowSize(aCoors)
		oSize:lProp 	:= .T.
		oSize:Process()
		DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] OF oMainWnd PIXEL
		DEFINE FWFORMBROWSE oBrowse DATA TABLE ALIAS cAliasTRB2 DESCRIPTION STR0042 OF oDlg  //"Consulta dos fardos do Bloco"
		oBrowse:SetTemporary(.T.)
		oBrowse:SetFieldFilter(CriaArra2())
		oBrowse:SetdbFFilter(.T.)
		oBrowse:SetUseFilter(.T.)
		oBrowse:bHeaderClick := {|| OrdenaBrowse(oBrowse) }
		oBrowse:DisableDetails()
		oBrowse:AddButton("Sair",{||oDlg:End()},,,,,,'10')
		ADD COLUMN oColumn DATA { || &(aArqTemp1[1,1]) } TITLE STR0037 					SIZE  aArqTemp1[1,3]  PICTURE PesqPict("DXI","DXI_ETIQ") 		TYPE TamSX3("DXI_ETIQ")[3]   OF oBrowse //"Etiqueta"
		ADD COLUMN oColumn DATA { || &(aArqTemp1[2,1]) } TITLE STR0006 					SIZE  aArqTemp1[2,3]  PICTURE PesqPict("DXI","DXI_CODIGO")		TYPE TamSX3("DXI_CODIGO")[3] OF oBrowse //"Fardo"
		ADD COLUMN oColumn DATA { || &(aArqTemp1[3,1]) } TITLE STR0038 					SIZE  aArqTemp1[3,3]  PICTURE PesqPict("DXL","DXL_PRDTOR")    	TYPE TamSX3("DXL_PRDTOR")[3] OF oBrowse //"Status"
		ADD COLUMN oColumn DATA { || &(aArqTemp1[4,1]) } TITLE STR0039 					SIZE  aArqTemp1[4,3]  PICTURE PesqPict("DXI","DXI_ROMSAI") 		TYPE TamSX3("DXI_ROMSAI")[3] OF oBrowse //"Romaneio"
		ADD COLUMN oColumn DATA { || &(aArqTemp1[5,1]) } TITLE STR0008 					SIZE  aArqTemp1[5,3]  PICTURE PesqPict("DXI","DXI_CODRES") 		TYPE TamSX3("DXI_CODRES")[3] OF oBrowse //"Reserva
		ADD COLUMN oColumn DATA { || &(aArqTemp1[6,1]) } TITLE STR0040 					SIZE  aArqTemp1[5,3]  PICTURE PesqPict("DXI","DXI_PSLIQU") 		TYPE TamSX3("DXI_PSLIQU")[3] OF oBrowse //"Peso Liquido
		ADD COLUMN oColumn DATA { || &(aArqTemp1[7,1]) } TITLE AGRTITULO("DXI_COSTEL")	SIZE  aArqTemp1[5,3]  PICTURE PesqPict("DXL","DXI_COSTEL") 		TYPE TamSX3("DXI_COSTEL")[3] OF oBrowse //"COSTELADO
		ACTIVATE FWFORMBROWSE oBrowse
		
		ACTIVATE MSDIALOG oDlg CENTER
	EndIf
	(cAliasTRB2)->(DbCloseArea())
	SetKey( VK_F12, bKeyF12)
Return

/*
CriaArray Cria matriz para o browse
@param: Nil
@author: Inácio Luiz Kolling
@since: 10/06/2014
@Uso: UBA
-------------------------------------------------------------------------------------
*/
Static Function CriaArra2()
	Local aCampos := {}
	AAdd(aCampos,{"ETIQUETA"    ,"ETIQUETA"   ,"C",TamSX3("DXI_ETIQ")[1],0,})
	AAdd(aCampos,{"CODIGO"      ,"CODIGO"      ,"C",6,0,})
	AAdd(aCampos,{"STATUSP"      ,"STATUSP"      ,"C",10,0,})
	AAdd(aCampos,{"ROMANEIO"    ,"ROMANEIO"   ,"C",TamSX3("DXI_ROMSAI")[1],0,})
	AAdd(aCampos,{"RESERVA"     ,"RESERVA"    ,"C",,TamSX3("DXI_CODRES")[1],0,})
	AAdd(aCampos,{"PESOL"        ,"PESOL"        ,"N",10,2,})
	AAdd(aCampos,{"COSTELADO" ,"COSTELADO" ,"C",3,0,})
Return aCampos

/*
UBAC008TRB  Cria arquivo de trabalho com dados para exibição da consulta
@param: Nil
@author: Inácio Luiz Kolling
@since: 10/06/2014
@Uso: UBA
-------------------------------------------------------------------------------------
*/
Function UBAC0082T()
	Local aArqTemp1	  := {} 
	Local cArqTemp1	  := ""
          
	If (!Empty(cAliasTRB2)) .AND. ( Select(cAliasTRB2) > 0 )
		(cAliasTRB2)->(dbCloseArea())
	EndIf

	// Cria arquivo de trabalho
	AAdd(aArqTemp1,{"ETIQUETA","C",TamSX3("DXI_ETIQ")[1],0,})
	AAdd(aArqTemp1,{"CODIGO"   ,"C",TamSX3("DXI_CODIGO")[1],0,})
	AAdd(aArqTemp1,{"STATUSP"  ,"C",10,0,})
	AAdd(aArqTemp1,{"ROMANEIO" ,"C",TamSX3("DXI_ROMSAI")[1],0,})
	AAdd(aArqTemp1,{"RESERVA"  ,"C",TamSX3("DXI_CODRES")[1],0,})
	AAdd(aArqTemp1,{"PESOL"    ,"N",10,2,})
	AAdd(aArqTemp1,{"COSTELADO" ,"C",3,0,})

	//-- Cria Indice de Trabalho
    If !Empty(oArqTemp2)
       AGRDLTPTB(oArqTemp2)
    EndIf 
    cArqTemp1  := GetNextAlias()
    oArqTemp2  := AGRCRTPTB(cArqTemp1, {aArqTemp1, {}} )
    cAliasTRB2 := cArqTemp1

	cAlias := GetNextAlias()

	cQuery := " SELECT DXI_ETIQ,DXI_CODIGO,DXI_CODRES,DXI_ROMSAI,DXI_PSLIQU,DXI_COSTEL "
	cQuery += " FROM " +RetSqlName("DXI")+ " DXI "
	cQuery += " WHERE DXI_FILIAL = '"+xFilial("DXI")+"'"
	cQuery += " AND DXI.DXI_BLOCO = '"+(cAliasTRB)->&(aArqTemp[1][1])+"'"
	cQuery += " AND DXI.DXI_SAFRA = '"+(cAliasTRB)->&(aArqTemp[2][1])+"'"
	cQuery += " AND DXI.D_E_L_E_T_ <> '*'"
	cQuery += " Order by DXI.DXI_CODIGO"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., 'TOPCONN', TcGenQry( , , cQuery), cAlias, .F., .T. )
	Count To nQtdl
	Processa({|| UBAC0082P() },STR0015)

	DbselectArea(cArqTemp1)
	dbGoTop()
Return({cArqTemp1, aArqTemp1})

/*-------------------------------------------------------------------------------------
UBAC008P Processamento
@param: Nil
@author: Inácio Luiz Kolling
@since: 10/06/2014
@Uso: UBAC008
-------------------------------------------------------------------------------------
*/
Static Function UBAC0082P()

	ProcRegua(nQtdl)
	nRegl := 0
	DbSelectArea((cAlias))
	(cAlias)->(dbGotop())
	
	While (cAlias)->(!Eof())
		nRegl ++
		IncProc(STR0016+Alltrim(Str(nRegl,5))+" / "+Alltrim(Str(nQtdl,5))) //"Processando  -> "
		
		DbSelectArea(cAliasTRB2)
		Reclock(cAliasTRB2,.T.)
		(cAliasTRB2)->ETIQUETA := (cAlias)->DXI_ETIQ
		(cAliasTRB2)->CODIGO   := (cAlias)->DXI_CODIGO
		(cAliasTRB2)->ROMANEIO := (cAlias)->DXI_ROMSAI
		(cAliasTRB2)->RESERVA  := (cAlias)->DXI_CODRES
		(cAliasTRB2)->PESOL    := (cAlias)->DXI_PSLIQU
		(cAliasTRB2)->COSTELADO := X3CBOXDESC("DXI_COSTEL",(cAlias)->DXI_COSTEL)
		If Empty((cAlias)->DXI_ROMSAI) .And. Empty((cAlias)->DXI_CODRES)
			(cAliasTRB2)->STATUSP := STR0032
		ElseIf !Empty((cAlias)->DXI_ROMSAI)
			(cAliasTRB2)->STATUSP := STR0033
		Else
			(cAliasTRB2)->STATUSP := STR0034
		EndIf
   
		(cAliasTRB2)->( Msunlock() )
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())
Return


Function UBAC008I()
	Local oReport

	If FindFunction("TRepInUse") .And. TRepInUse()
	//-------------------------
	// Interface de impressão    
	//-------------------------
		oReport:= ReportDef()
		oReport:PrintDialog()
	EndIf

Return

Static Function UBARCabec(oReport, cSafra)
	Local aCabec := {}
	Local cNmEmp	:= ""
	Local cNmFilial	:= ""
	Local cChar		:= CHR(160)  // caracter dummy para alinhamento do cabeçalho

	Default cSafra := ""

	If SM0->(Eof())
		SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
	Endif

	cNmEmp	 := AllTrim( SM0->M0_NOME )
	cNmFilial:= AllTrim( SM0->M0_FILIAL )

// Linha 1
	AADD(aCabec, "__LOGOEMP__") // Esquerda

// Linha 2 
	AADD(aCabec, cChar) //Esquerda
	aCabec[2] += Space(9) // Meio
	aCabec[2] += Space(9) + RptFolha + TRANSFORM(oReport:Page(),'999999') // Direita

// Linha 3
	AADD(aCabec, "SIGA /" + oReport:ReportName() + "/v." + cVersao) //Esquerda
	aCabec[3] += Space(9) + oReport:cRealTitle // Meio
	aCabec[3] += Space(9) + "Dt.Ref:" + Dtoc(dDataBase)   // Direita

// Linha 4
	AADD(aCabec, RptHora + oReport:cTime) //Esquerda
	aCabec[4] += Space(9) // Meio
	aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

// Linha 5
	AADD(aCabec, "Empresa:" + cNmEmp) //Esquerda
	aCabec[5] += Space(9) // Meio
	If !Empty(cSafra)
		aCabec[5] += Space(9)+ "Safra:"+cSafra   // Direita
	EndIf

// Linha 6
	AADD(aCabec, "Filial:" + cNmFilial) //Esquerda

Return aCabec

Static Function PrintReport(oReport)
	Local oSec1		:= oReport:Section(1)
	Local cAlias	:= cAliasTRB
	
	
	#IFDEF TOP
		oSec1:calias := cAlias
		(cAlias)->(dbGoTop())
		If (cAlias)->(!Eof())
			oSec1:Init()
			oSec1:Print()
			oSec1:Finish()
		EndIf
	#ENDIF

Return Nil

Return

Static Function ReportDef()
	Local oReport	:= NIL
	Local oSec1	:= NIL
	Local oFunc1	:= NIL

	DEFINE REPORT oReport NAME "UBAC008" TITLE STR0043 ACTION {|oReport| PrintReport(oReport)} //"Fardos por Bloco"
	oReport:nFontBody 	:= 8 //Aumenta o tamanho da fonte
	oReport:SetCustomText( {|| UBARCabec(oReport, mv_par01) } ) // Cabeçalho customizado
	
	oReport:SetLandscape()      //Define a orientação de página do relatório como paisagem.
	oReport:SetTotalInLine(.F.)//Define que o acumulador será impresso em linhas.
//---------
// Seção 1
//---------
	DEFINE SECTION oSec1 OF oReport TITLE STR0044 TABLES "TRB" AUTO SIZE
	oSec1:SetTotalInLine(.F.)   // Define se imprime o total por linha
	oSec1:SetReadOnly(.F.) 		// Define que o usuário não poderá alterar informações da seção, ou seja, não poderá remover as células pré-definidas.
	oSec1:ShowHeader()			// Define se apresenta titulo da seção

	DEFINE CELL NAME "BLOCO"		OF oSec1 TITLE STR0002 SIZE  TamSX3("DXI_BLOCO")[1] + 2  	PICTURE PesqPict("DXI","DXI_BLOCO")
	DEFINE CELL NAME "ENDEREC"	OF oSec1 TITLE STR0003 SIZE  TamSX3("DXD_ENDXYZ")[1]  	PICTURE PesqPict("DXD","DXD_ENDXYZ")
	DEFINE CELL NAME "DATAEMB"	OF oSec1 TITLE STR0004 SIZE  TamSX3("DXI_DATA")[1]  		PICTURE PesqPict("DXI","DXI_DATA")
	DEFINE CELL NAME "TIPO"		OF oSec1 TITLE STR0005 SIZE  TamSX3("DXI_CLACOM")[1]  	PICTURE PesqPict("DXI","DXI_CLACOM")
	DEFINE CELL NAME "FARDOS"	OF oSec1 TITLE STR0006 Header Align Right SIZE  TamSX3("DXD_QTDVNC")[1]  	PICTURE PesqPict("DXD","DXD_QTDVNC")
	DEFINE CELL NAME "SAIDA1"	OF oSec1 TITLE STR0007 Header Align Right SIZE  TamSX3("DXD_QTDVNC")[1]  	PICTURE PesqPict("DXD","DXD_QTDVNC")
	DEFINE CELL NAME "RESERVA"	OF oSec1 TITLE STR0008 Header Align Right SIZE  TamSX3("DXD_QTDVNC")[1]  	PICTURE PesqPict("DXD","DXD_QTDVNC")
	DEFINE CELL NAME "SALDO1"	OF oSec1 TITLE STR0009 Header Align Right SIZE  TamSX3("DXD_QTDVNC")[1]  	PICTURE PesqPict("DXD","DXD_QTDVNC")
	DEFINE CELL NAME "PESOT"		OF oSec1 TITLE STR0010 Header Align Right SIZE  TamSX3("DXF_QTDPRO")[1] 	PICTURE PesqPict("DXF","DXF_QTDPRO")
	DEFINE CELL NAME "SAIDA2"	OF oSec1 TITLE STR0011 Header Align Right SIZE  TamSX3("DXF_QTDPRO")[1]		PICTURE PesqPict("DXF","DXF_QTDPRO")
	DEFINE CELL NAME "RESERVA2"	OF oSec1 TITLE STR0012 Header Align Right SIZE  TamSX3("DXF_QTDPRO")[1]		PICTURE PesqPict("DXF","DXF_QTDPRO")
	DEFINE CELL NAME "SALDOF"	OF oSec1 TITLE STR0013 Header Align Right SIZE  TamSX3("DXF_QTDPRO")[1] 	PICTURE PesqPict("DXF","DXF_QTDPRO")
		
	
	oSec1:SetTotalText(STR0046) // Texto da seção totalizadora //"Total Geral"
	
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("FARDOS")		OF oSec1 FUNCTION SUM  NO END REPORT
	DEFINE FUNCTION oFunc2 FROM oSec1:Cell("SAIDA1") 	OF oSec1 FUNCTION SUM  NO END REPORT
	DEFINE FUNCTION oFunc3 FROM oSec1:Cell("RESERVA")   	OF oSec1 FUNCTION SUM  NO END REPORT
	DEFINE FUNCTION oFunc4 FROM oSec1:Cell("SALDO1")   	OF oSec1 FUNCTION SUM  NO END REPORT
	DEFINE FUNCTION oFunc5 FROM oSec1:Cell("PESOT")  	OF oSec1 FUNCTION SUM  NO END REPORT
	DEFINE FUNCTION oFunc6 FROM oSec1:Cell("SAIDA2")   	OF oSec1 FUNCTION SUM  NO END REPORT
	DEFINE FUNCTION oFunc7 FROM oSec1:Cell("RESERVA2") 	OF oSec1 FUNCTION SUM  NO END REPORT
	DEFINE FUNCTION oFunc8 FROM oSec1:Cell("SALDOF")   	OF oSec1 FUNCTION SUM  NO END REPORT
 	
Return oReport

// --------------------------------------------------------------------- 
/*{Protheus.doc} Ordena Browse
Ordena Browse conforme a coluna clicada

@author.: Joaquim Burjack
@since..: 21/07/2015
@Uso....: UBAC004
/*
Static Function OrdenaBrowse(oBrw )
	Local  nColuna	:= oBrw:ColPos()
	local  nIndice	:= 0
	Local  cAlias		:= oBrw:Alias()
	Local  aField		:= {}
	Static nclick		:= 0
	dbSelectArea(cAlias)
	aField	:= Dbstruct()

	For nIndice := 1 to len(aField)
		if nIndice = nColuna
			cArqInd	:=    CriaTrab(Nil,.F.)
			cChave		:= aField[nIndice][1]
			if  (nclick == nColuna)
				cChave		:= 'Descend('+ cChave + ')'
				nclick := 0
			else
				nclick := nColuna
			endif
			IndRegua(cAlias,cArqInd,cChave,,,"Ordenando Registros")
			#IFNDEF TOP
				DbSetIndex(cArqInd+OrdBagExt())
			#ENDIF
			oBrw:Refresh()
			oBrw:GoColumn(nColuna)
		endif
	Next nIndice
Return
*/
Static Function OrdenaBrowse(oBrw )
    //A Classe fwTemporaryTable não preve a criação de indices decrescente
    Local  nColuna  := oBrw:ColPos()
    local  nIndice  := 0
    Local  cAlias       := oBrw:Alias()
    Local  aField       := {}
    dbSelectArea(cAlias)
    aField  := Dbstruct()

    For nIndice := 1 to len(aField)
        if nIndice = nColuna
           (cAlias)->(DbSetOrder(nIndice))
           oBrw:Refresh()
           oBrw:GoColumn(nColuna)
           Exit
        endif
    Next nIndice
Return