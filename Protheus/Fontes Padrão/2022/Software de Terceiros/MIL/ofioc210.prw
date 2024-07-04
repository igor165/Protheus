// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 12     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "protheus.ch"
#Include "OFIOC210.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ OFIOC210 ³ Autor ³ Andre Luis Almeida     ³ Data ³ 28/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Consulta/Retorna CD.SERVICO - Servicos SCANIA Montad/Dealer ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC210()
Private cMarc := VV1->VV1_CODMAR // Marca do Veiculo
Private M->&("VO6_CODMAR") := cMarc // Variavel com o Cod.Marca utilizado no SXB ( Consulta VS6 )
Private cTipV := space(30)	// Tipo de Veiculo
Private cSeri := space(30)	// Serie do Veiculo
Private cCCAI := space(2)	// CAI/Grupo Codigo
Private cDCAI := space(50)	// CAI/Grupo Descricao
Private cCObj := space(6)	// Objeto Codigo
Private cDObj := space(50)	// Objeto Descricao
Private cCAca := space(6)	// Acao Codigo
Private cDAca := space(50)	// Acao Descricao
Private cCGrp := space(2)	// Grupo do Servico
Private cDGrp := space(50)	// Grupo do Servico Descricao
Private cCCod := space(15)	// Codigo do Servico
Private aTMO  := {}			// Vetor com os Servicos (Montadora)
Private aSer  := {}			// Vetor com os Servicos (Dealer)
Private aTMOAux := {}		// Vetor com os Servicos Auxiliar (Montadora)
Private aSerAux := {}		// Vetor com os Servicos Auxiliar (Dealer)
Private cServico:= space(150)	// Pesquisa Descricao do Servico
Private cVarian := space(50)	// Variant
Private cObserv := space(250)	// Observacoes
Private lVO6 := .f.			// Variavel utilizada para ler apenas 1 vez o VO6 (Dealer)
Aadd(aSer,{"","","",""})
Aadd(aTMO,{"","","","","","","",""})
DbSelectArea("VV2")
DbSetOrder(1)
DbSeek( xFilial("VV2") + cMarc + VV1->VV1_MODVEI )
DbSelectArea("VV8")
DbSetOrder(1)
DbSeek( xFilial("VV8") + VV2->VV2_TIPVEI )
cTipV := left(VV8->VV8_DESCRI+space(30),30)
cSeri := left(VV2->VV2_SERIE+space(30),30)
FS_FILTRAR("0")
DEFINE MSDIALOG oTMOSC TITLE STR0001 From 5,08 to 32,127 of oMainWnd
	@ 001,001 FOLDER oFolderTMOSC SIZE 470,153 OF oTMOSC PROMPTS STR0002,STR0003 PIXEL		
	oFolderTMOSC:bChange := {|| If( oFolderTMOSC:nOption == 1, .T., FS_FILTRAR("9")) , FS_OBSTMO("X") }
///////////////////////////////////////
// Folder 1 - Servicos Montadora     //
///////////////////////////////////////
	@ 003,005 SAY STR0004 SIZE 45,40 OF oFolderTMOSC:aDialogs[1] PIXEL COLOR CLR_BLUE
	@ 002,035 MSGET oVeiculo VAR (Alltrim(cMarc)+" - "+Alltrim(cTipV)+" - "+Alltrim(cSeri)+" - "+VV2->VV2_DESMOD) PICTURE "@!" SIZE 195,8 OF oFolderTMOSC:aDialogs[1] PIXEL COLOR CLR_BLUE WHEN .f.
	@ 013,005 SAY STR0005 SIZE 45,40 OF oFolderTMOSC:aDialogs[1] PIXEL COLOR CLR_BLUE
	@ 012,035 MSGET oCCAI VAR cCCAI PICTURE "99" F3 "V21" VALID FS_VALIDAR("CAI") SIZE 30,8 OF oFolderTMOSC:aDialogs[1] PIXEL COLOR CLR_BLUE
	@ 012,070 MSGET oDCAI VAR cDCAI PICTURE "@!" SIZE 160,8 OF oFolderTMOSC:aDialogs[1] PIXEL COLOR CLR_BLUE WHEN .f.
	@ 023,005 SAY STR0006 SIZE 45,40 OF oFolderTMOSC:aDialogs[1] PIXEL COLOR CLR_BLUE
	@ 022,035 MSGET oCObj VAR cCObj PICTURE "@!" F3 "VZH" VALID FS_VALIDAR("OBJ") SIZE 30,8 OF oFolderTMOSC:aDialogs[1] PIXEL COLOR CLR_BLUE
	@ 022,070 MSGET oDObj VAR cDObj PICTURE "@!" SIZE 160,8 OF oFolderTMOSC:aDialogs[1] PIXEL COLOR CLR_BLUE WHEN .f.
	@ 033,005 SAY STR0007 SIZE 45,40 OF oFolderTMOSC:aDialogs[1] PIXEL COLOR CLR_BLUE
	@ 032,035 MSGET oCAca VAR cCAca PICTURE "@!" F3 "VZI" VALID FS_VALIDAR("ACA") SIZE 30,8 OF oFolderTMOSC:aDialogs[1] PIXEL COLOR CLR_BLUE
	@ 032,070 MSGET oDAca VAR cDAca PICTURE "@!" SIZE 160,8 OF oFolderTMOSC:aDialogs[1] PIXEL COLOR CLR_BLUE WHEN .f.
	@ 009,240 BUTTON oFiltrar PROMPT STR0009 OF oFolderTMOSC:aDialogs[1] SIZE 85,10 PIXEL  ACTION (FS_FILTRAR("1"),FS_OBSTMO("1"))
	@ 025,240 SAY STR0010 SIZE 87,08 OF oFolderTMOSC:aDialogs[1] PIXEL COLOR CLR_BLUE
	@ 031,240 MSGET oServico VAR cServico PICTURE "@!" SIZE 60,08 OF oFolderTMOSC:aDialogs[1] PIXEL COLOR CLR_BLUE
	@ 031,300 BUTTON oPesqOK PROMPT OemToAnsi(STR0011) OF oFolderTMOSC:aDialogs[1] SIZE 25,10 PIXEL ACTION (FS_PESQ_OK("1"))
	@ 045,001 LISTBOX oLbTexto FIELDS HEADER OemToAnsi(STR0012),;	// Cod.Servico
                                         OemToAnsi(STR0013),;  	// Descricao
                                         OemToAnsi(STR0014),;  	// Grupo/CAI
                                         OemToAnsi(STR0015),;		// Objeto
                                         OemToAnsi(STR0016),; 		// Acao
                                         OemToAnsi(STR0020),; 		// Tipo Veiculo
                                         OemToAnsi(STR0021); 		// Serie
	COLSIZES 50,80,40,40,40,60,60 SIZE 468,072 OF oFolderTMOSC:aDialogs[1] PIXEL ON CHANGE FS_OBSTMO("1") ON DBLCLICK ( FS_RETORNO("1") , oTMOSC:End() )
	oLbTexto:SetArray(aTMO)
	oLbTexto:bLine := { || {aTMO[oLbTexto:nAt,1] ,;
                         aTMO[oLbTexto:nAt,2] ,;
                         aTMO[oLbTexto:nAt,3] ,;
                         aTMO[oLbTexto:nAt,4] ,;
                         aTMO[oLbTexto:nAt,5] ,;
                         aTMO[oLbTexto:nAt,9] ,;
                         aTMO[oLbTexto:nAt,10] }}
	@ 122,001 MSGET oVarian VAR cVarian PICTURE "@!" SIZE 468,010 OF oFolderTMOSC:aDialogs[1] PIXEL COLOR CLR_BLUE WHEN .f.
//////////////////////////////////////
// Folder 2 - Servicos Dealer       //
//////////////////////////////////////
	@ 003,005 SAY STR0004 SIZE 45,40 OF oFolderTMOSC:aDialogs[2] PIXEL COLOR CLR_BLUE
	@ 002,035 MSGET oVeiculo VAR (Alltrim(cMarc)+" - "+Alltrim(cTipV)) PICTURE "@!" SIZE 195,8 OF oFolderTMOSC:aDialogs[2] PIXEL COLOR CLR_BLUE WHEN .f.
	@ 018,005 SAY STR0005 SIZE 45,40 OF oFolderTMOSC:aDialogs[2] PIXEL COLOR CLR_BLUE
	@ 017,035 MSGET oCGrp VAR cCGrp PICTURE "@!" F3 "VS6" VALID FS_VALIDAR("GRP") SIZE 30,8 OF oFolderTMOSC:aDialogs[2] PIXEL COLOR CLR_BLUE
	@ 017,070 MSGET oDGrp VAR cDGrp PICTURE "@!" SIZE 160,8 OF oFolderTMOSC:aDialogs[2] PIXEL COLOR CLR_BLUE WHEN .f.
	@ 033,005 SAY STR0008 SIZE 45,40 OF oFolderTMOSC:aDialogs[2] PIXEL COLOR CLR_BLUE
	@ 032,035 MSGET oCCod VAR cCCod PICTURE "@!" SIZE 195,8 OF oFolderTMOSC:aDialogs[2] PIXEL COLOR CLR_BLUE
	@ 009,240 BUTTON oFiltrar PROMPT STR0009 OF oFolderTMOSC:aDialogs[2] SIZE 85,10 PIXEL  ACTION (FS_FILTRAR("2"),FS_OBSTMO("2"))
	@ 025,240 SAY STR0010 SIZE 87,08 OF oFolderTMOSC:aDialogs[2] PIXEL COLOR CLR_BLUE			
	@ 031,240 MSGET oServico VAR cServico PICTURE "@!" SIZE 60,08 OF oFolderTMOSC:aDialogs[2] PIXEL COLOR CLR_BLUE
	@ 031,300 BUTTON oPesqOK PROMPT OemToAnsi(STR0011) OF oFolderTMOSC:aDialogs[2] SIZE 25,10 PIXEL ACTION (FS_PESQ_OK("2"))
	@ 045,001 LISTBOX oLbSer FIELDS HEADER OemToAnsi(STR0014),;	// Grupo
														OemToAnsi(STR0012),;	// Cod.Servico
                                       	OemToAnsi(STR0013);	// Descricao
	COLSIZES 40,80,100 SIZE 326,072 OF oFolderTMOSC:aDialogs[2] PIXEL ON CHANGE FS_OBSTMO("2") ON DBLCLICK ( FS_RETORNO("2") , oTMOSC:End() )
	oLbSer:SetArray(aSer)
	oLbSer:bLine := { || {aSer[oLbSer:nAt,1] ,;
                         aSer[oLbSer:nAt,2] ,;
                         aSer[oLbSer:nAt,3] }}
//////////////////////////////////////
	@ 155,001 GET oObserv VAR cObserv OF oTMOSC MEMO SIZE 468,042 PIXEL READONLY MEMO
ACTIVATE MSDIALOG oTMOSC CENTER 
Return()

Static Function FS_VALIDAR(cTip)
Local lRet := .f.
If cTip == "CAI"
	cDCAI := ""
	If !Empty(cCCAI)
		DbSelectArea("VE2")
		DbSetOrder(1)
		If DbSeek(xFilial("VE2")+cMarc+cCCAI)
			lRet := .t.
			cDCAI := VE2->VE2_DESCAI
		EndIf
	Else
		lRet := .t.
	EndIf
ElseIf cTip == "OBJ"
	cDObj := ""
	If !Empty(cCObj)
		DbSelectArea("VZH")
		DbSetOrder(1)
		If DbSeek(xFilial("VZH")+cCObj)
			lRet := .t.
			cDObj := VZH->VZH_DESOBJ
		EndIf
	Else
		lRet := .t.
	EndIf
ElseIf cTip == "ACA"
	cDAca := ""
	If !Empty(cCAca)
		DbSelectArea("VZI")
		DbSetOrder(1)
		If DbSeek(xFilial("VZI")+cCAca)
			lRet := .t.
			cDAca := VZI->VZI_DESACA
		EndIf
	Else
		lRet := .t.
	EndIf
ElseIf cTip == "GRP"
	cDGrp := ""
	If !Empty(cCGrp)
		DbSelectArea("VOS") 
		DbSetOrder(1)
		If DbSeek(xFilial("VOS")+cMarc+cCGrp)
			lRet := .t.
			cDGrp := VOS->VOS_DESGRU
		EndIf
	Else
		lRet := .t.
	EndIf
EndIf
Return(lRet)

Static Function FS_FILTRAR(cTip)
Local ni  := 0
Local lOk := .f.
Local cTpVAux := GetNewPar("MV_USRSERT","")
Local cQuery  := ""
Local cQAlVO6 := "SQLVO6"
Local cQAlVZG := "SQLVZG"
If cTip == "0" // INICIAL - Servicos Montadora
	cCCAI := space(2)
	cCObj := cCAca := space(6)
	cDCAI := cDObj := cDAca := space(50)
	aTMO := {}
	#IFDEF TOP
		cQuery := "SELECT VZG.VZG_CODSER , VZG.VZG_VARIAN , VO6.VO6_DESSER , VO6.VO6_DESMEM , VO6.VO6_TEMFAB , VE2.VE2_DESCAI , VZH.VZH_DESOBJ , VZI.VZI_DESACA , VZG.VZG_TIPVEI , VZG.VZG_SERIE "
		cQuery += "FROM "+RetSqlName("VZG")+" VZG "
        cQuery += "INNER JOIN "+RetSqlName("VO6")+" VO6 ON ( VO6.VO6_FILIAL='"+xFilial("VO6")+"' AND VO6.VO6_CODMAR=VZG.VZG_CODMAR AND VO6.VO6_CODSER=VZG.VZG_CODSER AND VO6.D_E_L_E_T_ = ' ' ) "
        cQuery += "LEFT JOIN "+RetSqlName("VE2")+" VE2 ON ( VE2.VE2_FILIAL='"+xFilial("VE2")+"' AND VE2.VE2_CODMAR=VZG.VZG_CODMAR AND "+FG_CONVSQL("SUBS")+"(VE2.VE2_CODCAI,1,2)="+FG_CONVSQL("SUBS")+"(VZG.VZG_CODSER,1,2) AND VE2.VE2_ITETOT='1' AND VE2.D_E_L_E_T_=' ' ) "
        cQuery += "LEFT JOIN "+RetSqlName("VZH")+" VZH ON ( VZH.VZH_FILIAL='"+xFilial("VZH")+"' AND VZH.VZH_CODOBJ=VZG.VZG_CODOBJ AND VZH.D_E_L_E_T_=' ' ) "
        cQuery += "LEFT JOIN "+RetSqlName("VZI")+" VZI ON ( VZI.VZI_FILIAL='"+xFilial("VZI")+"' AND VZI.VZI_CODACA=VZG.VZG_CODACA AND VZI.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VZG.VZG_FILIAL='"+xFilial("VZG")+"' AND VZG.VZG_CODMAR='"+cMarc+"' AND "
		If !FM_PILHA("OFIXA011")
			If !Empty(M->VO4_GRUSER)
				cQuery += "VO6.VO6_GRUSER='"+M->VO4_GRUSER+"' AND "
			Endif
		Else
			If !Empty(M->VS4_GRUSER)
				cQuery += "VO6.VO6_GRUSER='"+M->VS4_GRUSER+"' AND "
			Endif
		Endif
		cQuery += "VZG.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVZG, .F., .T. ) 
		Do While !( cQAlVZG )->( Eof() ) 
			Aadd(aTMO,{( cQAlVZG )->( VZG_CODSER ),left(( cQAlVZG )->( VO6_DESSER ),40),( cQAlVZG )->( VE2_DESCAI ),left(( cQAlVZG )->( VZH_DESOBJ ),40),left(( cQAlVZG )->( VZI_DESACA ),40),( cQAlVZG )->( VZG_VARIAN ),( cQAlVZG )->( VO6_DESMEM ),Transform(( cQAlVZG )->( VO6_TEMFAB ),"@R 999:99"),( cQAlVZG )->( VZG_TIPVEI ),( cQAlVZG )->( VZG_SERIE )})
		   ( cQAlVZG )->( DbSkip() )
		EndDo
		( cQAlVZG )->( dbCloseArea() ) 
	#ENDIF
	DbSelectArea("VO6")
	If len(aTMO) <= 0 
		Aadd(aTMO,{"","","","","","","","","",""})
	EndIf
	aTMOAux := aClone(aTMO)
	aSort(aTMO,1,,{|x,y| x[1] < y[1] })
ElseIf cTip == "9" // INICIAL - Servicos Dealer
	If ExistBlock("OFC210De")
		If !ExecBlock("OFC210De",.f.,.f.)
			Return
		Endif
	Endif
	If !lVO6 
	   lVO6 := .t.
		aSer := {}
		#IFDEF TOP
			cQuery := "SELECT VO6.VO6_GRUSER , VO6.VO6_CODSER , VO6.VO6_DESSER , VO6.VO6_DESMEM "
			cQuery += "FROM "+RetSqlName("VO6")+" VO6 WHERE VO6.VO6_FILIAL='"+xFilial("VO6")+"' AND "
			cQuery += "VO6.VO6_CODMAR='"+cMarc+"' AND VO6.VO6_SERATI='1' AND VO6.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVO6, .F., .T. ) 
			Do While !( cQAlVO6 )->( Eof() ) 
				Aadd(aSer,{( cQAlVO6 )->(VO6_GRUSER),( cQAlVO6 )->(VO6_CODSER),( cQAlVO6 )->(VO6_DESSER),( cQAlVO6 )->(VO6_DESMEM)})
			   ( cQAlVO6 )->( DbSkip() )
			EndDo
			( cQAlVO6 )->( dbCloseArea() ) 
		#ENDIF
		DbSelectArea("VO6")
		If len(aSer) <= 0 
			Aadd(aSer,{"","","",""})
		EndIf
		aSerAux := aClone(aSer)
		oLbSer:nAt := 1
		oLbSer:SetArray(aSer)
		oLbSer:bLine := { || {aSer[oLbSer:nAt,1] ,;
		                        aSer[oLbSer:nAt,2],;
		                        aSer[oLbSer:nAt,3]}}
		oLbSer:SetFocus()
		oLbSer:Refresh()
	EndIf
ElseIf cTip == "1" // Folder 1 - Servicos Montadora - Filtro
	aTMO := {}
	For ni := 1 to len(aTMOAux)
		lOk := .t.
	  	If !Empty(cCCAI)
	  		If cDCAI # aTMOAux[ni,3]
	  			lOk := .f.
	  		EndIf
	  	EndIf
		If lOk .and. !Empty(cCObj)
	  		If cDObj # aTMOAux[ni,4]
	  			lOk := .f.
	  		EndIf
  		EndIf
	  	If lOk .and. !Empty(cCAca)
			If cDAca # aTMOAux[ni,5]
	  			lOk := .f.
		  	EndIf
		EndIf
		If lOk
			Aadd(aTMO,{aTMOAux[ni,1],aTMOAux[ni,2],aTMOAux[ni,3],aTMOAux[ni,4],aTMOAux[ni,5],aTMOAux[ni,6],aTMOAux[ni,7],aTMOAux[ni,8],aTMOAux[ni,9],aTMOAux[ni,10]})
		EndIf
	Next
	If len(aTMO) <= 0 
		Aadd(aTMO,{"","","","","","","","","",""})
	EndIf
	oLbTexto:nAt := 1
	aSort(aTMO,1,,{|x,y| x[1] < y[1] })
	oLbTexto:SetArray(aTMO)
	oLbTexto:bLine := { || {aTMO[oLbTexto:nAt,1] ,;
	                         aTMO[oLbTexto:nAt,2] ,;
   	                      aTMO[oLbTexto:nAt,3] ,;
      	                   aTMO[oLbTexto:nAt,4] ,;
      	                   aTMO[oLbTexto:nAt,5] ,;
      	                   aTMO[oLbTexto:nAt,9] ,;
         	                aTMO[oLbTexto:nAt,10] }}
	oLbTexto:SetFocus()
	oLbTexto:Refresh()
ElseIf cTip == "2" // Folder 2 - Servicos Dealer - Filtro
	aSer := {}
	For ni := 1 to len(aSerAux)
		lOk := .t.
	  	If !Empty(cCGrp)
	  		If cCGrp # aSerAux[ni,1]
	  			lOk := .f.
	  		EndIf
	  	EndIf
	  	If lOk .and. !Empty(cCCod)
	  		If Alltrim(cCCod) # left(aSerAux[ni,2],len(Alltrim(cCCod)))
	  			lOk := .f.
	  		EndIf
	  	EndIf
		If lOk
			Aadd(aSer,{aSerAux[ni,1],aSerAux[ni,2],aSerAux[ni,3],aSerAux[ni,4]})
		EndIf
	Next
	If len(aSer) <= 0 
		Aadd(aSer,{"","","",""})
	EndIf
	oLbSer:nAt := 1
	aSort(aSer,1,,{|x,y| x[1]+x[2] < y[1]+y[2] })
	oLbSer:SetArray(aSer)
	oLbSer:bLine := { || {aSer[oLbSer:nAt,1] ,;
	                         aSer[oLbSer:nAt,2],;
	                         aSer[oLbSer:nAt,3]}}
	oLbSer:SetFocus()
	oLbSer:Refresh()
EndIf
Return

Static Function FS_PESQ_OK(cTip)
Local nPos := 0
If cTip == "1" // Folder 1 - Servicos Montadora
	If !Empty(cServico)
		aSort(aTMO,1,,{|x,y| x[2] < y[2] })
		nPos := aScan(aTMO,{|x| left(x[2],len(Alltrim(cServico))) == Alltrim(cServico) })
		If nPos == 0
			nPos := 1
		EndIf
	Else
		aSort(aTMO,1,,{|x,y| x[1] < y[1] })
		nPos := 1
	EndIf
  	oLbTexto:nAt := nPos
   oLbTexto:SetFocus()
ElseIf cTip == "2" // Folder 2 - Servicos Dealer
	If !Empty(cServico)
		aSort(aSer,1,,{|x,y| x[3] < y[3] })
		nPos := aScan(aSer,{|x| left(x[3],len(Alltrim(cServico))) == Alltrim(cServico) })
		If nPos == 0
			nPos := 1
		EndIf
	Else
		aSort(aSer,1,,{|x,y| x[1]+x[2] < y[1]+y[2] })
		nPos := 1
	EndIf
  	oLbSer:nAt := nPos
   oLbSer:SetFocus()
EndIf
Return

Static Function FS_OBSTMO(cTip)
cObserv := ""
If cTip == "X"
	If ( oFolderTMOSC:nOption == 1 ) // Folder 1 - Servicos Montadora
		cTip := "1"
	ElseIf ( oFolderTMOSC:nOption == 2 ) // Folder 2 - Servicos Dealer
		cTip := "2"
	EndIf
EndIf
If cTip == "1" // Folder 1 - Servicos Montadora
	cVarian := STR0017+" "+aTMO[oLbTexto:nAt,8]+" - "+aTMO[oLbTexto:nAt,6]
	oVarian:Refresh()
	If !Empty(aTMO[oLbTexto:nAt,7])
		cObserv := MSMM(aTMO[oLbTexto:nAt,7],70)
	EndIf
ElseIf cTip == "2" // Folder 2 - Servicos Dealer
	If !Empty(aSer[oLbSer:nAt,4])
		cObserv := MSMM(aSer[oLbSer:nAt,4],70)
	EndIf
EndIf
oObserv:Refresh()
Return
Static Function FS_RETORNO(cTip)
If FunName() != "OFIOC210"
	DbSelectArea("VO6")
	DbSetOrder(2)
	DbSelectArea("VOS") 
	DbSetOrder(1)
	If cTip == "1" // Folder 1 - Servicos Montadora
		DbSeek(xFilial("VOS")+cMarc+left(aTMO[oLbTexto:nAt,1],2))
		DbSelectArea("VO6")
		DbSeek(xFilial("VO6")+cMarc+aTMO[oLbTexto:nAt,1])
   ElseIf cTip == "2" // Folder 2 - Servicos Dealer
		DbSeek(xFilial("VOS")+cMarc+aSer[oLbSer:nAt,1])
		DbSelectArea("VO6")
		DbSeek(xFilial("VO6")+cMarc+aSer[oLbSer:nAt,2])
   EndIf
	If !fm_pilha("OFIXA011")  
		If cTip == "1" // Folder 1 - Servicos Montadora
			if !Empty(aTMO[oLbTexto:nAt,1])
				aCols[oGetSrv:oBrowse:nAt,FG_POSVAR("VO4_GRUSER")] := M->VO4_GRUSER := left(aTMO[oLbTexto:nAt,1],2)
			endif
			aCols[oGetSrv:oBrowse:nAt,FG_POSVAR("VO4_CODSER")] := M->VO4_CODSER := aTMO[oLbTexto:nAt,1]
		ElseIf cTip == "2" // Folder 2 - Servicos Dealer
			if !Empty(aSer[oLbSer:nAt,2])
				aCols[oGetSrv:oBrowse:nAt,FG_POSVAR("VO4_GRUSER")] := M->VO4_GRUSER := aSer[oLbSer:nAt,1]
			endif
			aCols[oGetSrv:oBrowse:nAt,FG_POSVAR("VO4_CODSER")] := M->VO4_CODSER := aSer[oLbSer:nAt,2]
		EndIf
	Else
		If cTip == "1" // Folder 1 - Servicos Montadora
			if !Empty(aTMO[oLbTexto:nAt,1])
				aCols[oGetServ:oBrowse:nAt,FG_POSVAR("VS4_GRUSER")] := M->VS4_GRUSER := left(aTMO[oLbTexto:nAt,1],2)
			endif
			aCols[oGetServ:oBrowse:nAt,FG_POSVAR("VS4_CODSER")] := M->VS4_CODSER := aTMO[oLbTexto:nAt,1]
		ElseIf cTip == "2" // Folder 2 - Servicos Dealer
			if !Empty(aSer[oLbSer:nAt,2])
				aCols[oGetServ:oBrowse:nAt,FG_POSVAR("VS4_GRUSER")] := M->VS4_GRUSER := aSer[oLbSer:nAt,1]
			endif
			aCols[oGetServ:oBrowse:nAt,FG_POSVAR("VS4_CODSER")] := M->VS4_CODSER := aSer[oLbSer:nAt,2]
		EndIf
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ VLUSRSER ³ Autor ³ Andre Luis Almeida     ³ Data ³ 13/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Valida Usuario Servicos Montadora / Dealer                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VLUSRSER()
Local lRet := .f.
Local cMarc := VV1->VV1_CODMAR // Marca do Veiculo
Local cTipV := space(30)	// Tipo de Veiculo
Local cSeri := space(30)	// Serie do Veiculo
Local cCodSer := space(15)
Local cTpVAux := GetNewPar("MV_USRSERT","")
Private M->&("VO6_CODMAR") := cMarc // Variavel com o Cod.Marca utilizado no SXB ( Consulta VS6 )
DbSelectArea("VV2")
DbSetOrder(1)
DbSeek( xFilial("VV2") + cMarc + VV1->VV1_MODVEI )
DbSelectArea("VV8")
DbSetOrder(1)
DbSeek( xFilial("VV8") + VV2->VV2_TIPVEI )
cTipV := left(VV8->VV8_DESCRI+space(30),30)
cSeri := left(VV2->VV2_SERIE+space(30),30)
If __CUSERID $ GetNewPar("MV_USRSER","000000")
	lRet := .t.
Else
	If alltrim(cSeri) $ GetNewPar("MV_USRSERS","")
		If !fm_pilha("OFIXA011")
			cCodSer := M->VO4_CODSER
			If !(M->VO4_GRUSER $ GetNewPar("MV_USRSERG","00/01/02/03/04/05/06/07/08/09/10/11/12/13/14/15/16/17/18/19/"))
				lRet := .t.
			EndIf
		Else
			cCodSer := M->VS4_CODSER
			If !(M->VS4_GRUSER $ GetNewPar("MV_USRSERG","00/01/02/03/04/05/06/07/08/09/10/11/12/13/14/15/16/17/18/19/"))
				lRet := .t.
			EndIf
		EndIf
		If !lRet
			DbSelectArea("VZG")
			DbSetOrder(2)			
			DbSeek(xFilial("VZG")+cMarc+If(Empty(cTpVAux),cTipV,""))
			Do While !Eof() .and. !lRet .and. VZG->VZG_FILIAL == xFilial("VZG") .and. VZG->VZG_CODMAR == cMarc
				If Empty(cTpVAux)
					If VZG->VZG_TIPVEI # cTipV
						Exit
					EndIf
				Else
					If	VZG->VZG_TIPVEI # cTipV .and. !( Alltrim(VZG->VZG_TIPVEI) $ cTpVAux )
						DbSelectArea("VZG")
					   DbSkip()
					   Loop
					EndIf
				EndIf
				If VZG->VZG_CODSER == cCodSer
					lRet := .t.
				EndIf
				DbSelectArea("VZG")
			   DbSkip()
			EndDo
		EndIf
	Else
		lRet := .t.
	EndIf
EndIf
If !lRet
	MsgAlert(STR0019,STR0018)
EndIf
Return lRet
