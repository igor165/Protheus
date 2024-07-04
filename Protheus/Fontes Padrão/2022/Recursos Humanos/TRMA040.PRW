#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBTREE.CH"  
#INCLUDE "HEADERGD.CH"
#INCLUDE "TRMA040.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}  TRMA040
Cadastro de Cursos

@author Rogerio Ribeiro da Cruz
@since 13/04/2010
@version 11.0
@Last Update: 05/12/2013
/*/
//-------------------------------------------------------------------
Function TRMA040
	Local cFiltra	:= ""
	Local aIndFil	:= {}

	Private bFiltraBrw := {|| Nil }
	Private aRotina := MenuDef()
	Private cCadastro := OemtoAnsi(STR0008)	//"Cadastro de Cursos" 
	Private lEPMInt:= SuperGetMv("MV_TRMINTG", .F., .F.) .AND. ExistTables()
	
	dbSelectArea("RA1")
	dbSetOrder(1)

	If lEPMInt
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se as duas tabelas estao com o mesmo modo de compartilhamento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If (FWModeAccess( "RA1", 1) + FWModeAccess( "RA1", 2) + FWModeAccess( "RA1", 3)) <> ;
		   (FWModeAccess( "RAU", 1) + FWModeAccess( "RAU", 2) + FWModeAccess( "RAU", 3))
			//"O Modo de Acesso do relacionamento Curso x Conteudo deve "
			//"seguir o mesmo modo que o cadastro de cursos!"
			//"Altere o Modo de Acesso Atraves do Configurador. Arquivos RA1 e RAU."
			cMsg1 := "O Modo de Acesso do relacionamento Curso x Conteudo deve seguir o mesmo modo que o cadastro de cursos!"             
			cMsg2 := "Altere o Modo de Acesso Atraves do Configurador. Arquivos RA1 e RAU."             
			MsgInfo( oEmToAnsi( cMsg1 ) + CRLF + CRLF + oEmToAnsi( cMsg2 ) )

			Return (.F.)
		EndIf

		If (FWModeAccess( "RA1", 1) + FWModeAccess( "RA1", 2) + FWModeAccess( "RA1", 3)) <> ;
		   (FWModeAccess( "RAY", 1) + FWModeAccess( "RAY", 2) + FWModeAccess( "RAY", 3))
			//"O Modo de Acesso do relacionamento e-learning deve "
			//"seguir o mesmo modo que o cadastro de cursos!"
			//"Altere o Modo de Acesso Atraves do Configurador. Arquivos RA1 e RAY."
			cMsg1 := "O Modo de Acesso do relacionamento e-learning deve seguir o mesmo modo que o cadastro de cursos!"             
			cMsg2 := "Altere o Modo de Acesso Atraves do Configurador. Arquivos RA1 e RAY."             
			MsgInfo( oEmToAnsi( cMsg1 ) + CRLF + CRLF + oEmToAnsi( cMsg2 ) )

			Return (.F.)
		EndIf
	EndIf

	
	cFiltra 	:= ChkRH(FunName(), "RA1", "1")
	bFiltraBrw 	:= {|| FilBrowse("RA1", @aIndFil, @cFiltra) }
	Eval(bFiltraBrw)
	
	dbSelectArea("RA1")
	dbGoTop()
	
	MBrowse(NIL, NIL, NIL, NIL, "RA1")
	    
	EndFilBrw("RA1", aIndFil)
	
	dbSelectArea("RA2")
	dbSetOrder(1)
	
	dbSelectArea("RA1")
	dbSetOrder(1)       
	
	dbSelectArea("RA6")
	dbSetOrder(1)
	
	dbSelectArea("RA9") 
	dbSetOrder(1)
	
	dbSelectArea("RAH") 
	dbSetOrder(1)
	                   
	dbSelectArea("RAM")
	dbSetOrder(1)

	If lEPMInt
		dbSelectArea("RAU")
		dbSetOrder(1)	

		dbSelectArea("RAY")
		dbSetOrder(1)	
	EndIf
Return
 

//-------------------------------------------------------------------
/*/{Protheus.doc}  TR040Rot
Mostra o Tree dos Funcionarios

@author Emerson Grassi Rocha
@since 11/07/2001
@version 11.0

@param cAlias Alias da tabela
@param nReg Numero do registro
@param nOpcx Numero da opcao Selecionada
/*/
//------------------------------------------------------------------- 
Function TR040Rot(cAlias, nReg, nOpcx)
	Local oDlgMain
	Local nOpca			:= 0
	Local lTrDel		:= If(nOpcx=2.Or.nOpcx=5,.F.,.T.)
	Local nOrder		:= 0
	Local aFields		:= {}
	Local i				:= 0
	Local lQGint		:= FlQGint() //Integracao Quality
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aTreeCoords	:= {}
	Local aEnchCoords	:= {}
	Local aGetDCoords	:= {}
	
	Default lEPMInt		:= SuperGetMv("MV_TRMINTG", .F., .F.) .AND. ExistTables()
	
	Private oTree
	Private nOpcao	:= nOpcx
	Private cGet1 := "", cGet2 := ""
	Private lObj1	:= .F.
	Private aListPast:= array(7)
	
	Private aCols  	:= {}
	Private aHeader	:= {}
	Private Continua:= .F.
	
	// Private dos objetos do Curso
	Private oEnchoice
	Private cCod	:= ""
	Private cDesc	:= ""
	Private nEstou	:= 1
	Private nIndo	:= 0

	Private aObjCreated	:= Array(7) 
	Private aGetDados	:= Array(7) 	
	Private aGroups		:= Array(7) 		
	Private oSay1, oGet1
	
	for i:= 1 To Len(aObjCreated)
		aObjCreated[i] := .F.
	Next
	
	If lEPMInt
		dbSelectArea("RAU")
		dbSetOrder(1)	

		dbSelectArea("RAY")
		dbSetOrder(1)	
	EndIf

	dbSelectArea("RA1")
	dbSetOrder(1)
		
	//Private aTELA[0][0], aGETS[0]
	Private nSaveSX8   	:= GetSX8Len()  
	bCampo := {|nCPO| Field(nCPO) }
	           
	If nOpcx != 3		// Diferente de Inclusao
		cCod 	:= RA1->RA1_CURSO
		cDesc	:= RA1->RA1_DESC
		
		If lEPMInt
			RAY->( DBSeek(xFilial("RAY") + RA1->RA1_CURSO) )
		EndIf
	Else
		cDesc	:= CriaVar("RA1_DESC")
	EndIf	

	If lEPMInt
		RegToMemory("RAY", (nOpcx == 3))
	EndIf
	
	// Salva a integridade dos campos de Bancos de Dados
	If nOpcx == 3
		For i := 1 TO FCount()
			cCampo := EVAL(bCampo,i)
			lInit := .f.
	
			If ExistIni(cCampo)
				lInit := .t.
				M->&(cCampo) := InitPad(SX3->X3_RELACAO)
	
				If 	 Alltrim(Upper(cCampo)) ==  ("RA1_CURSO")
					cCod:=M->RA1_CURSO
					While RA1->(dbseek(xFilial('RA1')+M->RA1_CURSO))
						   M->RA1_CURSO:=  InitPad(SX3->X3_RELACAO) 
					      cCod:=M->RA1_CURSO
					EndDo 

					// Atualiza Semaforo com a ultima chave valida
					FreeForUse("RA1", M->RA1_CURSO)
				Endif
				
				If ValType(M->&(cCampo)) = "C"
					M->&(cCampo) := PADR(M->&(cCampo),SX3->X3_TAMANHO)
				EndIf
				
				If M->&(cCampo) == NIL
					lInit := .f.
				EndIf
			EndIf
			
			If !lInit
				M->&(cCampo) := FieldGet(i)
				If ValType(M->&(cCampo)) = "C"
					M->&(cCampo) := SPACE(LEN(M->&(cCampo)))
				ElseIf ValType(M->&(cCampo)) = "N"
					M->&(cCampo) := 0
				ElseIf ValType(M->&(cCampo)) = "D"
					M->&(cCampo) := CtoD("  /  /  ")
				ElseIf ValType(M->&(cCampo)) = "L"
					M->&(cCampo) := .F.
				EndIf
			EndIf
		Next i
	Else
		For i := 1 TO FCount()
			 M->&(EVAL(bCampo,i)) := FieldGet(i)
		Next i
	EndIf
	

	// Monta as Dimensoes dos Objetos
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1], aAdvSize[2], aAdvSize[3], aAdvSize[4], 5, 5 }					 
	aAdd( aObjCoords , { 0, 0, .T., .T.} )
	aObjSize		:= MsObjSize(aInfoAdvSize, aObjCoords)
	 
	aTreeCoords	:= { (aObjSize[1,1]+2),		(aObjSize[1,2]),		(aObjSize[1,3]),	(aObjSize[1,4]*0.2)	}
	aEnchCoords	:= { (aObjSize[1,1]+2),		(aObjSize[1,4]*0.2 +5),	(aObjSize[1,3]), 	(aObjSize[1,4]-5)	}
	aGetDCoords	:= { (aObjSize[1,1]+25),	(aObjSize[1,4]*0.2 +5), (aObjSize[1,3]-10),	(aObjSize[1,4])		}
	
	DEFINE MSDIALOG oDlgMain FROM aAdvSize[7], 0 TO aAdvSize[6], aAdvSize[5] TITLE cCadastro OF oMainWnd PIXEL	                                                     
		o1Group := TGroup():New(aEnchCoords[1]-3, aEnchCoords[2], aGetDCoords[1], aEnchCoords[4], OemToAnsi(STR0010), oDlgMain, NIL, NIL, .T.)
		o1Group:Hide()

		oSay1 := TSay():New(aGetDCoords[1]-15, aGetDCoords[2]+10, {|| OemToAnsi(STR0025)}, o1Group, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, 20, 7)				//"Código"
		oGet1 := TGet():New(aGetDCoords[1]-16, aGetDCoords[2]+30, bSetGet(cGet1), o1Group, 20, 7, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, {|| .F.})

		oSay2 := TSay():New(aGetDCoords[1]-15, aGetDCoords[2]+70, {|| OemToAnsi(STR0026)}, o1Group, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, 30, 7)				//"Descrição"
		oGet2 := TGet():New(aGetDCoords[1]-16, aGetDCoords[2]+100, bSetGet(cGet2), o1Group, 100, 7, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, {|| .F.})

		
		DEFINE DBTREE oTree FROM aTreeCoords[1],aTreeCoords[2] TO aTreeCoords[3],aTreeCoords[4] CARGO OF oDlgMain;
			 ON CHANGE (Tr040Principal(oTree, oDlgMain, nOpcx, aGetDCoords, lTrDel))
							
		oTree:BeginUpdate()
		oTree:AddItem(OemToAnsi(STR0011)+Space(30), "1", "FOLDER5", "FOLDER6", NIL, NIL, 1)	//"Curso"
		oTree:AddItem(OemToAnsi(STR0012), "2", "FOLDER5", "FOLDER6", NIL, NIL, 1)	//"Entidades"
		oTree:AddItem(OemToAnsi(STR0014), "3", "FOLDER5", "FOLDER6", NIL, NIL, 1)	//"Materiais"

        If lQGint
			oTree:AddItem(OemToAnsi(STR0021), "5", "FOLDER5", "FOLDER6", NIL, NIL, 1)		//"Documentos"
		Endif
		
		If lEPMInt
			If RA1->RA1_TIPO == "L"
				oTree:AddItem(OemToAnsi(STR0028), "6", "FOLDER5","FOLDER6", NIL, NIL, 1)	//"E-Learning"
				oTree:AddItem(OemToAnsi(STR0027), "7", "FOLDER5","FOLDER6", NIL, NIL, 1)	//"Conteudo"								
			EndIf
		EndIf

		oTree:EndUpdate()
		oTree:bValid 	:= {|| Tr040VlTree(nOpcx,lQGint) }
		oTree:lValidLost:= .F.
		oTree:lActivated:= .T.
				
		// Curso
		oEnchoice:= MsMGet():New(cAlias, NIL, nOpcx, NIL, NIL, NIL, NIL, aEnchCoords) 	//"Quanto a exclusao"
							 
		aGroups[2] := TGroup():New(aGetDCoords[1], aGetDCoords[2], aGetDCoords[3]+10, aGetDCoords[4]-5, OemtoAnsi(STR0013), oDlgMain, NIL, NIL, .T.)	// " Entidades "
		aGroups[2]:Hide()

		aGroups[3] := TGroup():New(aGetDCoords[1], aGetDCoords[2], aGetDCoords[3]+10, aGetDCoords[4]-5, OemtoAnsi(STR0015), oDlgMain, NIL, NIL, .T.)	// " Materiais "
		aGroups[3]:Hide()

		If lQGint				//Documentos SGA
			aGroups[5] := TGroup():New(aGetDCoords[1], aGetDCoords[2], aGetDCoords[3]+10, aGetDCoords[4]-5, OemtoAnsi(STR0021), oDlgMain, NIL, NIL, .T.)	//"Documentos"
			aGroups[5]:Hide()
		EndIf	

		If lEPMInt		
			aGroups[6] := TGroup():New(aGetDCoords[1], aGetDCoords[2], aGetDCoords[3]+10, aGetDCoords[4]-5, OemtoAnsi(STR0028), oDlgMain, NIL, NIL, .T.)	//"E-Learning"
			aGroups[6]:Hide()		
		
			aGroups[7] := TGroup():New(aGetDCoords[1], aGetDCoords[2], aGetDCoords[3]+10, aGetDCoords[4]-5, OemtoAnsi(STR0027), oDlgMain, NIL, NIL, .T.)	//"Conteudo"
			aGroups[7]:Hide()
		EndIf

	ACTIVATE MSDIALOG oDlgMain ON INIT (EnchoiceBar(oDlgMain,{||nOpca:=1, If(Tr040TudOk(nOpcx), oDlgMain:End(), NIL) },{|| nOpca := 2, oDlgMain:End()}))

	If nOpca == 1
		If nOpcx != 5 .And. nOpcx != 2	// Se nao for Exclusao e visual
			Begin Transaction
			    
				Tr040Grava(nOpcx,lQGint)
				EvalTrigger()    
				
				// Confirmando a Numeracao Automatica
				If __lSX8
					Select('RA1')
					While ( GetSX8Len() > nSaveSx8 )
						ConfirmSX8(.T.)
					End While   
				EndIf
			End Transaction
		ElseIf nOpcx = 5
			Begin Transaction
				Tr040Dele(lQGint, nOpcx)
			End Transaction
		EndIf
	Else
		If __lSX8
			// RollBack da Numeracao Automatica
			While (GetSx8Len() > nSaveSx8)
				RollBackSx8()
			EndDo 
		EndIf			
	EndIf
	
	Release Object oTree
	
	dbSelectArea(cAlias)
	dbGoto(nReg)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc}  Tr040Ok2
Valida a linha da getdados Entidade

@author Emerson Grassi Rocha
@since 11/07/2001
@version 11.0
/*/
//------------------------------------------------------------------- 
Function Tr040Ok2()
	Local nPosCod 	:= GdFieldPos("RA6_ENTIDA")
	
	If nOpcao != 5 .And. nOpcao != 2
		If !GDDeleted()
		//If !aCols[n, Len(aCols[n])]      // Se nao esta Deletado
			If (nPosCod > 0 .And. Empty(aCols[n][nPosCod])) .And. !(Tr040Linha("RA6"))
				Help("", 1, "TR040VAZ2")	  // Entidade deve ser preenchida. 
				Return .F.
			EndIf

			If !GDCheckKey({"RA6_ENTIDA"}, 4)
				Return .F.
			EndIf
		
			/*For nx:=1 To Len(aCols)
				If aCols[n][nPosCod] == aCols[nx][nPosCod] .And.;
					!aCols[nx][Len(aCols[nx])] .And.	n != nx 
					Help(" ", 1, "TR040COD")		// Entidade ja cadastrada.
					Return .F.
					Exit
				EndIf	
			Next nx		
			*/
		EndIf	
	EndIf	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} Tr040Ok3
Valida a linha da getdados Material

@author Emerson Grassi Rocha
@since 11/07/2001
@version 11.0
/*/
//------------------------------------------------------------------- 
Function Tr040Ok3()
	Local nPosMater := GdFieldPos("RAH_MATER")
	Local nPosRefer	:= GdFieldPos("RAH_REFER")
	Local nx		:= 0
	
	If nOpcao != 5 .And. nOpcao != 2
		If !aCols[n,Len(aCols[n])]      // Se nao esta Deletado
			If ((nPosMater > 0 .And. Empty(aCols[n][nPosMater])) .Or.;
				(nPosRefer > 0 .And. Empty(aCols[n][nPosRefer]))) .And. !(Tr040Linha("RAH")) 
				Help("",1,"TR040VAZ3")	  // Verifique os campos Cod. Material e Referencia.
				Return .F.
			EndIf
		
			For nx:=1 To Len(aCols)
				If nPosMater > 0 .And. aCols[n][nPosMater] == aCols[nx][nPosMater] .And. !aCols[nx][Len(aCols[nx])] .And. n != nx 
					Help(" ",1,"TR040MAT")		// Material ja existe.
					Return .F.
					Exit
				EndIf	
			Next nx		
		EndIf	
	EndIf
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc}  Tr040Ok4
Valida a linha da getdados Disciplina

@author Eduardo Ju
@since 21/10/2003
@version 11.0
/*/
//------------------------------------------------------------------- 
Function Tr040Ok4()
	Local nPosDiscip:= GdFieldPos("RAM_DISCIP")
	Local nx		:= 0
	
	If nOpcao != 5 .And. nOpcao != 2
		If !aCols[n,Len(aCols[n])]      // Se nao esta Deletado
			If (nPosDiscip > 0 .And. Empty(aCols[n][nPosDiscip])) .And. !(Tr040Linha("RAM")) 
				Help("",1,"TR040VAZ4")	 // Verifique o Campo Disciplina
				Return .F.
			EndIf
		
			For nx:=1 To Len(aCols)
				If aCols[n][nPosDiscip] == aCols[nx][nPosDiscip] .And.;
					!aCols[nx][Len(aCols[nx])] .And.;
					n != nx 
					Help(" ",1,"TR040DIS")		// Disciplina ja existe.
					Return .F.
					Exit
				EndIf	
			Next nx		
		EndIf	
	EndIf
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc}  Tr040Ok5
Valida a linha da getdados Documentos

@author Telso Carneiro
@since 11/02/2004
@version 11.0
/*/
//------------------------------------------------------------------- 
Function Tr040Ok5()
	Local nPosDoc:= GdFieldPos("RAN_DOCTO")
	Local nx	 := 0
	
	If nPosDoc > 0
		If nOpcao != 5 .And. nOpcao != 2
			If !aCols[n,Len(aCols[n])]      // Se nao esta Deletado
				If (nPosDoc > 0 .And. Empty(ALLTRIM(aCols[n][nPosDoc]))) .And. !(Tr040Linha("RAN")) 
					Help(" ",1,"QDOBRIG") // "Existem campos obrigatorios nao preenchidos"	 
					Return .F.
				EndIf
			
				For nx:=1 To Len(aCols)
					If aCols[n][nPosDoc] == aCols[nx][nPosDoc] .And.;
						!aCols[nx][Len(aCols[nx])] .And. n != nx 
						Help(" ",1,"QALCTOJAEXI") //Informacao ja Cadastrada
						Return .F.
						Exit
					EndIf
					
					IF 	!aCols[nx][Len(aCols[nx])] 
					    IF EMPTY(ALLTRIM(QA_UltRvDc(aCols[n][nPosDoc],,.T.)))   //Verifica o Cod.Documento
					    	Return .F.
					    Endif	
					Endif
				Next nx		
			Else
				RAO->(DbSetOrder(2))
				IF RAO->(DBSeek(xFilial("RAO")+M->RA1_CURSO+aCols[n][nPosDoc]))
				    MsgAlert(STR0022) //"Nao é Possivel a exclusao do Doc., pois ha Cursos encerrados com este Doc."
					Return .F.							
				Endif	
			EndIf	
		EndIf
	EndIf
Return .T.
                   

//-------------------------------------------------------------------
/*/{Protheus.doc}  Tr040Ok6
Valida a enchoice de elearning

@author Rogerio Ribeiro da Cruz
@since 11/02/2004
@version 11.0
/*/
//------------------------------------------------------------------- 
Function Tr040Ok6()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc}  Tr040Ok7
Valida a linha da getdados Conteudo

@author Rogerio Ribeiro da Cruz
@since 11/02/2004
@version 11.0
/*/
//------------------------------------------------------------------- 
Function Tr040Ok7()
	Local nPosSeq, nPosDel
	Local nCount
	Local lRet:= .T.
	                
	If !GdDeleted()
		/*If lRet
			lRet:= GDCheckKey({"RAU_SEQUEN"}, 4)
		EndIf*/
	
		If lRet
			lRet:= GDCheckKey({"RAU_CONTEU"}, 4)
		EndIf
		
		If lRet
			lRet:= GdNoEmpty({"RAU_SEQUEN", "RAU_CONTEU"})
		EndIf
	EndIf		
			    
	If lRet
		nPosDel:= GdFieldPos("GDDELETED")
		nPosSeq:= GDFieldPos("RAU_SEQUEN")
		ASort(aCols, NIL, NIL, {|x, y| If(x[nPosDel], "1", "0") + x[nPosSeq] <= If(y[nPosDel], "1", "0") + y[nPosSeq]})

		For nCount:= 1 To Len(aCols)
			aCols[nCount, nPosSeq]:= StrZero(nCount, aHeader[nPosSeq, __AHEADER_WIDTH__])
		Next

		aGetDados[7]:Refresh()
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}  Tr040Grava
Realiza a gravação dos dados do curso.

@author Emerson Grassi Rocha
@since 11/07/2001
@version 11.0

@param nOpcx Numero da opcao selecionada
@param lQGint Se esta integrado com o Quality
/*/
//------------------------------------------------------------------- 
Static Function Tr040Grava(nOpcx, lQGint)
	Local aColsRec	:= {}
	Local cPrefixo
	Local xConteudo := ""
	Local nt		:= 0
	Local nx 		:= 0
	Local ny 		:= 0
	Local nI		:= 0
	Local nPosEnt	:= 0
	Local nPosMater	:= 0
	Local nPosDiscip:= 0
	Local nPosCampo	:= 0
	Local cDescAnt	:=""    
	Local aAlias 	:= {"RA1", "RA6","RAH", "RAM", "RAN"} 
	Local lGrava	:=.T.
	Local lTravou	:=.F.
	
	Default lEPMInt		:= SuperGetMv("MV_TRMINTG", .F., .F.) .AND. ExistTables()
	
	IF lEPMInt
		AAdd(aAlias, "RAY")
		AAdd(aAlias, "RAU")
	EndIf
	
	// Curso
	dbSelectArea("RA1")
	RecLock("RA1",IIf(nOpcx != 3, .F., .T.))
	cDescAnt := RA1->RA1_DESC
	For nI := 1 To FCount()
		If ( FieldName(nI) == "RA1_FILIAL" )
			FieldPut(nI, cFilial)			
		Else
			FieldPut(nI, M->&(FieldName(nI)))
		EndIf
	Next nI
	MsUnlock()	
	
	If lEPMInt .AND. M->RA1_TIPO == "L"
		dbSelectArea("RAY")
		DBSetOrder(1)
		lInsertRAY:= !DBSeek(xFilial("RAY") + RA1->RA1_CURSO)
	
		RecLock("RAY", lInsertRAY)
		If lInsertRAY
			RAY_FILIAL:= xFilial("RAY")
			RAY_CURSO:= RA1_CURSO	
		EndIf
		
		For nI := 1 To FCount()
			If !(AllTrim(FieldName(nI)) $ "RAY_FILIAL/RAY_CURSO" )
				FieldPut(nI, M->&(FieldName(nI)))
			EndIf
		Next nI
		MsUnlock()
	
		DBSelectArea("RA2")
		DBSetOrder(1)	//RA2_FILIAL, RA2_CALEND, RA2_CURSO, RA2_TURMA, R_E_C_N_O_, D_E_L_E_T_
		
		If !DBSeek(xFilial("RA2") + Space(GetSx3Cache("RA2_CALEND", "X3_TAMANHO")) + RA1->RA1_CURSO + Space(GetSx3Cache("RA2_TURMA", "X3_TAMANHO")) )
			RecLock("RA2", .T.)
			RA2_FILIAL := xFilial("RA2")
			RA2_CURSO:= RA1->RA1_CURSO
			RA2_CALEND:= Space(GetSx3Cache("RA2_CALEND", "X3_TAMANHO"))
			RA2_TURMA:= Space(GetSx3Cache("RA2_TURMA", "X3_TAMANHO"))
			RA2_DESC:= "E-Learning"
			RA2_DATAIN:= dDataBase
			//RA2_DATAFI
			RA2_VAGAS:= 9999
			RA2_DURACA:= RA1_DURACA
			RA2_UNDURA:= RA1_UNDURA
			RA2_HORAS:= RA1_HORAS
			
			MsUnlock()
		EndIf
	EndIf
	
	For nt:= 1 to len(aAlias)    
	    If aListPast[nt] == nil
	    	Loop
	    EndIf
	    
		aHeader		:= aClone(aListPast[nt][1])
		aCols 		:= aClone(aListPast[nt][2])	
	                         
		Do Case
			Case nt = 2
				nPosCampo	:= GdFieldPos("RA6_ENTIDA") 
				lGrava	:=.T.
			Case nt = 3  
				nPosCampo	:= GdFieldPos("RAH_MATER")
				lGrava	:=.T.
			Case nt = 4 
				nPosCampo	:= GdFieldPos("RAM_DISCIP")  
				lGrava	:=.T.
			Case nt = 5                                                          
				If !lQGint   
					lGrava:=.F.
				Endif
		 		nPosCampo	:= GdFieldPos("RAN_DOCTO")  
			Case nt = 6
				Loop		 		
			Case nt = 7
				nPosCampo	:= GdFieldPos("RAU_SEQUEN")  
				lGrava	:=.T.				
		EndCase	 			                                                                                	
	               
	 	cPrefixo := PrefixoCpo(aAlias[nt])		//If (Subs(aAlias[nt],1,1) = "S" ,Subs(aAlias[nt],2,2),Subs(aAlias[nt],1,3))
		cAux1:= aAlias[nt] + "->" + cPrefixo + "_FILIAL"
		cAux2:= aAlias[nt] + "->" + cPrefixo + "_CURSO"  

		nPosRec:= GdFieldPos(cPrefixo + "_REC_WT")            		 
		
		If Len(aCols) == 1 .and. Empty(aCols[1][nPosCampo])
			aCols:={}
		EndIf            
		
		If lGrava
			dbSelectArea(aAlias[nt])
			
			For nx :=1 to Len(aCols)     
				Begin Transaction                  
					lTravou:=.F.
					If aCols[nx][nPosRec]> 0  	
						MsGoto(aCols[nx][nPosRec])	
						RecLock(aAlias[nt],.F.)
						lTravou:= .T.
					Else   
				   		If !aCols[nx][Len(aCols[nx])]  
							RecLock(aAlias[nt],.T.)
							lTravou:= .T.
						EndIf	
					EndIf
					
					If lTravou		
						//--Verifica se esta deletado
						If aCols[nx][Len(aCols[nx])] .And. !Empty(aCols[nx][nPosCampo])
							dbDelete()
						Else
							Replace &cAux1 	WITH xFilial(aAlias[nt])
							Replace &cAux2	WITH cCod	
						EndIf       	
						For nY := 1 To Len(aHeader)
							If aHeader[nY][10] <> "V" 
								(aAlias[nt])->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
							EndIf	
						Next nY   
					EndIf
					MsUnlock()		
				End Transaction                  
			Next nx
		EndIf	                     
	Next nt
	
	If lEPMInt .and. RA1->RA1_TIPO == "L"
		TRMA040IntEPM(nOpcx)
	EndIf
	
	// Ponto de entrada para alterar manutencao nas tabelas de cursos
	// (RA1,RA6,RAH,RAM e RAN) na gravacao do registro
	If ExistBlock("TRMGRV01")
		ExecBlock("TRMGRV01",.F.,.F.,{nOpcx, cDescAnt})
	Endif	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc}  Tr040Dele
Deleta todos os registros referentes ao curso

@author Emerson Grassi Rocha
@since 11/07/2001
@version 11.0

@param lQGint Se esta integrado com o Quality
/*/
//------------------------------------------------------------------- 
Static Function Tr040Dele(lQGint, nOpcx)
	Local aNoChk	:= {"RA6", "RAH", "RAM"}
	Local lChkDelOk	:= .F.
	
	Default lEPMInt		:= SuperGetMv("MV_TRMINTG", .F., .F.) .AND. ExistTables()
	Default	nOpcx		:= 5
	
	If lQGint
		aAdd(aNoChk , "RAN" )
	EndIf
	
	If lEPMInt 				// Integracao EPM
		aAdd(aNoChk, "RAU")
		aAdd(aNoChk, "RAY")
	EndIf
	If RA1->RA1_TIPO == 'L' //E-Learning
		// Podem existir cursos e-learning sem calendario e/ou turma
		// assim a exclusao RA2, deve ser tratado separadamente pelo SetOrder(2)
		aAdd(aNoChk, "RA2")
	Endif
			
	dbSelectArea("RA1")
	
	lChkDelOk  := ChkDelRegs(	"RA1"				,;	//01 -> Alias do Arquivo Principal
								NIL					,;	//02 -> Registro do Arquivo Principal
								NIL					,;	//03 -> Opcao para a AxDeleta
								NIL					,;	//04 -> Filial do Arquivo principal para Delecao
								NIL					,;	//05 -> Chave do Arquivo Principal para Delecao
								NIL					,;	//06 -> Array contendo informacoes dos arquivos a serem pesquisados
								NIL					,;	//07 -> Mensagem para MsgYesNo
								NIL					,;	//08 -> Titulo do Log de Delecao
								NIL					,;	//09 -> Mensagem para o corpo do Log
								NIL				 	,;	//10 -> Se executa AxDeleta
								NIL					,;	//11 -> Se deve Mostrar o Log
								NIL					,;	//12 -> Array com o Log de Exclusao
								NIL		 			,;	//13 -> Array com o Titulo do Log
								NIL					,;	//14 -> Bloco para Posicionamento no Arquivo
								NIL					,;	//15 -> Bloco para a Condicao While
								NIL					,;	//16 -> Bloco para Skip/Loop no While
								.T.					,;	//17 -> Verifica os Relacionamentos no SX9
								aNoChk				 ;	//18 -> Alias que nao deverao ser Verificados no SX9
						    ) 
						    
	If !lChkDelOk
		Return Nil
	Endif  

	TRMA040IntEPM(5)
	
	// Relacionamento Entidade
	dbSelectArea("RA6")
	dbSetOrder(2)

	If dbSeek(xFilial("RA6")+cCod)
		While !Eof() .And.;
				RA6->RA6_FILIAL+RA6->RA6_CURSO == xFilial("RA6")+cCod
			RecLock("RA6",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf	                
	
	// Lista de Materiais
	dbSelectArea("RAH")
	dbSetOrder(1)
	If dbSeek(xFilial("RAH")+cCod)
		While !Eof() .And.;
				RAH->RAH_FILIAL+RAH->RAH_CURSO == xFilial("RAH")+cCod
			RecLock("RAH",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf	
	
	// Disciplinas
	dbSelectArea("RAM")
	dbSetOrder(1)
	If dbSeek(xFilial("RAM")+cCod)
		While !Eof() .And.;
				RAM->RAM_FILIAL+RAM->RAM_CURSO == xFilial("RAM")+cCod
			RecLock("RAM",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf
	
	// Documentos
	If lQGint
		dbSelectArea("RAN")
		dbSetOrder(1)

		If dbSeek(xFilial("RAN")+cCod)
			While !Eof() .And.;
					RAN->RAN_FILIAL == xFilial("RAN") .AND.;
					RAN->RAN_CURSO == cCod
				RecLock("RAN",.F.)
				dbDelete()
				MsUnlock()
				dbSkip()
			EndDo
		EndIf
	Endif


	If lEPMInt
		// Disciplinas
		dbSelectArea("RAU")
		dbSetOrder(1)
		If dbSeek(xFilial("RAU")+cCod)
			While !Eof() .AND.;
					RAU->RAU_FILIAL == xFilial("RAU") .AND.;
					RAU->RAU_CURSO == cCod
				RecLock("RAU", .F.)
				dbDelete()
				MsUnlock()
				dbSkip()
			EndDo
		EndIf
	
		dbSelectArea("RAY")
		DBSetOrder(1)

		If DBSeek(xFilial("RAY") + cCod)
			RecLock("RAY", .F.)
			dbDelete()
			MsUnlock()	
		EndIf
		
	EndIf

	If RA1->RA1_TIPO == 'L' //E-Learning
		dbSelectArea("RA2")
		dbSetOrder(2)
		If dbSeek(xFilial("RA2")+cCod)
			While !Eof() .AND.;
					RA2->RA2_FILIAL == xFilial("RA2") .AND.;
					RA2->RA2_CURSO == cCod
				RecLock("RA2", .F.)
				dbDelete()
				MsUnlock()
				dbSkip()
			EndDo
		EndIf
	EndIf
		
	// Curso
	dbSelectArea("RA1")
	cDescAnt := RA1->RA1_DESC	
	RecLock("RA1", .F.)
	dbDelete()
	MsUnlock()

	// Ponto de entrada para alterar manutencao nas tabelas de cursos
	// (RA1,RA6,RAH,RAM e RAN) na exclusao do registro
	If ExistBlock("TRMGRV01")
		ExecBlock("TRMGRV01",.F.,.F.,{nOpcx, cDescAnt})
	Endif	

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc}  Tr040TudOk
Funcao executada no Ok da enchoicebar

@author Emerson Grassi Rocha
@since 11/07/2001
@version 11.0

@param nOpcx Numero da opcao Selecionada
/*/
//------------------------------------------------------------------- 
Function Tr040TudOk(nOpcx)

Local lRet := .T.


If nOpcx <> 2
	If (nOpcx == 3 .Or. nOpcx == 4) .And. !Ra6Empty(nOpcx)
		Help( ,, STR0030,, STR0031	, 1, 0,,,,,, {STR0032} )//##"Cod.Entidade"##"O Cod.Entidade está vazio!"##"Preencha a Pasta de Entidades"
		lRet := .F.
	Else 
		lRet := Tr040VlTree(nOpcx)
	EndIf
EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}  Tr040Principal
Funcao principal que controla mudanca de arquivo

@author Emerson Grassi Rocha
@since 11/07/2001
@version 11.0

@param oTree
@param oDlgMain
@param lQGint
@param nOpcx Numero da opcao Selecionada
@param aGetDCoords
@param lTrDel
/*/
//------------------------------------------------------------------- 
Static Function Tr040Principal(oTree, oDlgMain, nOpcx, aGetDCoords, lTrDel )
	aHeader := {}
	aCols := {}
	n:= 1
	nIndo := Val(oTree:GetCargo())
	
	If nEstou == 1
		oEnchoice:Hide()
		oGet1:cText:= M->RA1_CURSO
		oGet2:cText:= M->RA1_DESC
	Else
		If nEstou != 6
			aGetDados[nEstou]:oBrowse:Hide()
		EndIf
		
		aGetDados[nEstou]:Hide()
		aGroups[nEstou]:Hide() 
	EndIf	

	If nIndo == 1
		DBSelectArea("RA1")	
		o1Group:Hide()
		oEnchoice:Show()
		oEnchoice:Refresh()		
	Else
		aHeader	:= {}
		aCols	:= {}
		Tr040Obter(nIndo, @aHeader, @aCols, nOpcx)

		If !aObjCreated[nIndo]
			If nIndo == 6
				aGetDados[nIndo]:= MsmGet():New("RAY", NIL, nOpcX, NIL, NIL, NIL, NIL, aGetDCoords, NIL, NIL, NIL, NIL, NIL, aGroups[nIndo])
			Else
				aGetDados[nIndo]:= MSGetDados():New(aGetDCoords[1]+10, aGetDCoords[2]+5, aGetDCoords[3]+5, aGetDCoords[4]-10, nOpcx, "Tr040Ok"+AllTrim(Str(nIndo)), "AllwaysTrue", NIL, lTrDel, NIL, 1, NIL, 5000, NIL, NIL, NIL, NIL, aGroups[nIndo])
			EndIf
			aObjCreated[nIndo] := .T.
		EndIf

		If nIndo != 6
			aGetDados[nIndo]:oBrowse:Default()
			aGetDados[nIndo]:oBrowse:Show()			
		EndIf

		aGetDados[nIndo]:Show()
		aGroups[nIndo]:Show()
			
		o1Group:Show()
	EndIf
		
	nEstou := nIndo		
Return



//-------------------------------------------------------------------
/*/{Protheus.doc}  Tr040VlTree
Validacao do Tree 

@author Emerson Grassi Rocha
@since 11/07/2001
@version 11.0

@param nOpcx Numero da opcao Selecionada
@param lQGint Se esta integrado com o Quality
/*/
//------------------------------------------------------------------- 
Static Function Tr040VlTree(nOpcx, lQGint)
	Local lRet      :=.T. 
	Local nTothor   := 0  
	Local nPos
	Local nx        := 0
	Local nLimHoras	:= Val( Replicate( "9", ( TamSx3("RAM_CARHOR")[1] - ( TamSx3("RAM_CARHOR")[2] + 1 ) ) ) + ".99" )
	
	If nOpcx != 2 .And. nOpcx != 5			// Diferente de visual e delecao
		If nEstou == 1
			lRet:= Obrigatorio(oEnchoice:aGets, oEnchoice:aTela)
		ElseIf nEstou == 2
			lRet:= Tr040Ok2()
		ElseIf nEstou == 3
			lRet:= Tr040Ok3()
		ElseIf nEstou == 4
			lRet:= Tr040Ok4()	
			  
			nPos:= GdFieldPos("RAM_CARHOR")
			
			// Totalizacao da Carga Horaria da Disciplina
			For nx:= 1 to len(aCols)
				If !aCols[nx,Len(aCols[nx])] 
					nTothor+= aCols[nx][nPos]
				EndIf	
			Next nx	
			
			If nTothor > 0
				If M->RA1_HORAS <> nTothor .Or. (M->RA1_DURACA <> nTothor .And. M->RA1_UNDURA == "H")	
					If MsgYesNo(OemtoAnsi(STR0020),OemToAnsi(STR0011))	//"Deseja realmente atualizar Carga Horaria e Duracao do Curso?","Curso"		
					    If nTothor > nLimHoras 
					    	Aviso(OemToAnsi(STR0011),OemToAnsi(STR0023),{"Ok"})	//"O total da carga horária das disciplinas excedeu o limite máximo do curso. Verifique a real carga horária das discplinas e repita a operação"
						Else
							M->RA1_HORAS := nTothor			 
							If M->RA1_UNDURA == "H"
								M->RA1_DURACA := nTothor
							EndIf	
						Endif	                                             
					EndIf	
				EndIf
			EndIf    
		ElseIf nEstou == 5
			If lQGint
				lRet:= Tr040Ok5()
			EndIf					             			
		ElseIf nEstou == 6
			lRet:= Tr040Ok6()
		ElseIf nEstou == 7
			lRet:= Tr040Ok7()			
		EndIf
	EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}  TR040Dref
Retorna a descricao da Referencia

@author Emerson Grassi Rocha
@since 11/07/2001
@version 11.0
/*/
//------------------------------------------------------------------- 
Function TR040Dref()
	Local cVar		:= &(ReadVar())
	Local cDesc		:= ""
	Local nPosDref	:= 0
	
	nPosDref := GdFieldPos("RAH_DESREF")
	
	dbSelectArea("SX5")

	If dbSeek(xFilial("SX5")+"RI"+cVar)
		cDesc := Substr(X5_DESCRI, 1, 30)
	EndIf

	aCols[n][nPosDref] := cDesc
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc}  TR040Desc
Traz a descricao

@author Emerson Grassi Rocha
@since 12/07/2001
@version 11.0

@param nQual 1=Material; 2=Observacao
@param lSx3
/*/
//------------------------------------------------------------------- 
Function TR040Desc(nQual, lSx3)
	Local aSaveArea := GetArea()
	Local nPosCod 	:= 0
	Local nPosDesc	:= 0
	Local cMater  	:= " "
	Local cRetorno	:= ""
	
	If lSx3
		cRetorno := " "
	Else 
		cRetorno := .T.
	EndIf        
	
	nPosCod	:= GdFieldPos("RAH_MATER")
	nPosDesc:= GdFieldPos("RAH_DESC")
	nPosObs := GdFieldPos("RAH_OBS")                                                  
	
	If lSx3
		cMater := aCols[Len(aCols)][nPosCod]
		cRetorno	:= Iif(Inclui, "", Fdesc("RAG",cMater,Iif(nQual==1,"RAG_DESC","RAG_OBS")))
	Else
		cMater := &(ReadVar())          	
		aCols[n][nPosDesc] := Fdesc("RAG",cMater,"RAG_DESC")
		aCols[n][nPosObs]  := Fdesc("RAG",cMater,"RAG_OBS")
	EndIf
	
	RestArea(aSaveArea)
Return cRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc}  Tr040DescDI
Traz a Descricao da Disciplina

@author Eduardo Ju
@since 21/10/2003
@version 11.0

@param nQual 1=Codigo da Discplina; 2=Descricao da Disciplina
@param lSx3 
/*/
//------------------------------------------------------------------- 
Function TR040DescDI(nQual, lSx3)
	Local aSaveArea := GetArea()
	Local nPosCod 	:= 0
	Local nPosDesc	:= 0
	Local nPosCH    := 0
	Local cDiscipl 	:= ""
	Local cRetorno	:= ""
	
	If lSx3
		cRetorno := " "
	Else 
		cRetorno := .T.
	EndIf        
	
	nPosCod	:= GdFieldPos("RAM_DISCIP")
	nPosDesc:= GdFieldPos("RAM_DESCDI")
	nPosCH  := GdFieldPos("RAM_CARHOR")
	
	If lSx3
		cDiscipl	:= aCols[Len(aCols)][nPosCod]   
		cRetorno	:= Iif(Inclui, "", Fdesc("JAE", cDiscipl, "JAE_DESC"))
	Else
		cDiscipl := &(ReadVar()) 
		aCols[n][nPosDesc] := Fdesc("JAE", cDiscipl, "JAE_DESC")
		aCols[n][nPosCH]   := Fdesc("JAE", cDiscipl, "JAE_CARGA")  	
	EndIf                                                      
	
	RestArea(aSaveArea)
Return cRetorno  


//-------------------------------------------------------------------
/*/{Protheus.doc}  FlQGint
Integracao TRM com todos os Modulos do Quality

@author Telso Carneiro
@since 13/12/2005
@version 11.0
/*/
//------------------------------------------------------------------- 
Static Function FlQGint()
	Local lRet := .F.
	Local aArea := GetARea()
	
	IF GETMV("MV_QGINT") == "S" .AND. ChkFile('RAN') .AND. ChkFile('RAO') 
		lRet:=.T.
	Endif
	
	RestArea(aArea)
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}  Ra1GrupoVld
Funcao para Validar o Conteudo do Campo RA1_GRUPO

@author Emerson Grassi Rocha
@since 02/03/2006
@version 11.0
/*/
//------------------------------------------------------------------- 
Function Ra1GrupoVld()
	Local cItEsc	 	:= GetMemVar( "RA1_GRUPO" )
	Local lRa1EscalaVld	:= .F.
	Local cEscala		:= FDesc("SQX",GetMemVar( "RA1_TIPOPP" ),"QX_GRUPO")
	
	Begin Sequence
	   SetMemVar("RA1_GRUPO", cItEsc ) 
	   SetMemVar("RA1_DESGRU", Ra1DesGruInit())
	End Sequence
	lRa1EscalaVld := .T.
Return lRa1EscalaVld   

//-------------------------------------------------------------------
/*/{Protheus.doc}  Ra1DesGruInit
Inicializador padrao para o Campo RA1_DESGRU

@author Emerson Grassi Rocha
@since 02/03/2006
@version 11.0
/*/
//------------------------------------------------------------------- 
Function Ra1DesGruInit()
	Local cDesItGrupo	:= ""
	Local cItEsc		:= GetMemVar("RA1_GRUPO")
    Local cEscala		:= FDesc("SQ0", GetMemVar( "RA1_GRUPO" ), "Q0_GRUPO")
	  
	cDesItGrupo := Fdesc("SQ0", cEscala+cItEsc, "Q0_DESCRIC") 
Return cDesItGrupo

//-------------------------------------------------------------------
/*/{Protheus.doc}  Tr040Obter
Funcao que localiza e retorna o aCols e a Header da pasta
indicada pelo parametro nPasta. Caso o aCols nao tenha sido
carregado, e feita a chamada para a funcao Tr040Fill.

@author Joeudo Santana
@since 09/01/2007
@version 11.0

@param nPasta
@param aHeadAux
@param aColAux
@param nOpcx Numero da opcao selecionada
/*/
//------------------------------------------------------------------- 
Static Function Tr040Obter(nPasta, aHeadAux, aColAux, nOpcx)
	If (aListPast[nPasta] == Nil)  
		aListPast[nPasta]:= TR040FillG(nPasta, nOpcx) 
	EndIf

	aHeadAux:= aListPast[nPasta][1]
	aColAux	:= aListPast[nPasta][2]        
Return 



//-------------------------------------------------------------------
/*/{Protheus.doc}  TR040FillG
Montagem das Getdados aHeader, aCols com adequação à funcionalidade 
do Walk Trhu

@author Joeudo Santana
@since 09/01/2007
@version 11.0

@param nPasta
@param nOpcx Numero da opcao Selecionada
/*/
//------------------------------------------------------------------- 
Function TR040FillG(nPasta,nOpcx)
	Do Case
		Case nPasta = 2  
			cAlias		:="RA6"						 				//2-cAlias - area a ser utilizada;
			nOrder		:=2											//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
		  	bSeekWhile	:={|| RA6->RA6_FILIAL + RA6->RA6_CURSO}	//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			aNoFields	:= {"RA6_FILIAL","RA6_CURSO"}				//7-aNoFields - array contendo os campos que não estarão no aHeader;
	    Case  nPasta = 3       	    
	      	cAlias		:="RAH"						 				//2-cAlias - area a ser utilizada;
			nOrder		:=1											//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
			bSeekWhile	:={|| RAH->RAH_FILIAL + RAH->RAH_CURSO}	//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			aNoFields	:= {"RAH_FILIAL","RAH_CURSO"}				//7-aNoFields - array contendo os campos que não estarão no aHeader;	//aHeader	:= {}        
        Case  nPasta = 4     
           	cAlias		:= "RAM"						 			//2-cAlias - area a ser utilizada;
			nOrder		:= 1										//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
			bSeekWhile	:= {|| RAM->RAM_FILIAL + RAM->RAM_CURSO}  	//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			aNoFields	:= {"RAM_FILIAL","RAM_CURSO"}	  			//7-aNoFields - array contendo os campos que não estarão no aHeader;	//aHeader	:= {}
		Case  nPasta = 5     
         	cAlias		:= "RAN"									//2-cAlias - area a ser utilizada;
			nOrder		:= 1										//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
			bSeekWhile	:= {|| RAN->RAN_FILIAL + RAN->RAN_CURSO}	//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			aNoFields	:= {"RAN_FILIAL","RAN_CURSO"}				//7-aNoFields - array contendo os campos que não estarão no aHeader;	//aHeader	:= {}     		     
		Case  nPasta = 6
			Return {{}, {}}		
		Case  nPasta = 7
         	cAlias		:= "RAU"									//2-cAlias - area a ser utilizada;
			nOrder		:= 1										//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
			bSeekWhile	:= {|| RAU->RAU_FILIAL+RAU->RAU_CURSO}		//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			aNoFields	:= {"RAU_FILIAL","RAU_CURSO"}				//7-aNoFields - array contendo os campos que não estarão no aHeader;	//aHeader	:= {}     		     
    EndCase               

   	cSeekKey := xFilial(cAlias)+ cCod					  			//4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;                         
                                                            
	FillGetDados(nOpcx					,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
				 cAlias					,; //2-cAlias - area a ser utilizada;
				 nOrder					,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				 cSeekKey				,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
			 	 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
				 aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
				 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
				 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
				 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
				 NIL					)  //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}

	// Posiciona no final do arquivo para que o Inicialiazador padrao apresente os campos em branco  
	dbSelectArea(cAlias)
	dbGoBottom()
	dbSkip()	
Return {aHeader, aCols}


//-------------------------------------------------------------------
/*/{Protheus.doc}  Tr040Linha
Verifica se a primeira linha esta toda sem preencher

@author Joeudo Santana
@since 09/01/2007
@version 11.0

@param cAlias Alias da tabela
/*/
//------------------------------------------------------------------- 
Function Tr040Linha(cAlias)
	Local lTree := .T.
	Local nx	:= 0             
	Local nPosAlias
	Local nPosRec
	Local cPrefixo:= PrefixoCpo(cAlias)

	nPosAlias:= GdFieldPos(cPrefixo + "_ALI_WT")
	nPosRec  := GdFieldPos(cPrefixo + "_REC_WT")  
	
	For nx:=1 To Len(aHeader) 
		// Desprezar tamanho = 1   
		If aHeader[nx][4] != 1 	.and.  nx <> nPosAlias .and. nx <> nPosRec  //Exceto campos:  Alias WT  e Recno WT 		 
			If !Empty(aCols[1][nx])
				lTree := .F.
				Exit
			EndIf
		EndIf
	Next nx  
Return lTree              


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Isola opcoes de menu para que as opcoes da rotina possam ser lidas 
pelas bibliotecas Framework da Versao 9.12

@author Luiz Gustavo
@since 22/12/2006
@version 11.0
/*/
//------------------------------------------------------------------- 
Static Function MenuDef()
	Local aRotina :=  { 	{ STR0003, 'PesqBrw',	 0, 1, NIL, .F.},;	//'Pesquisar'
							{ STR0004, 'Tr040Rot',	 0, 2},;			//'Visualizar'
							{ STR0005, 'Tr040Rot',	 0, 3},;			//'Incluir'
							{ STR0006, 'Tr040Rot',	 0, 4},;			//'Alterar'
							{ STR0007, 'Tr040Rot',	 0, 5, 3},;			//'Excluir' 
							{ STR0024, 'MsDocument', 0, 4}		}		//'Conhecimento'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} TRMA040IntEPM

@author Rogerio Ribeiro
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TRMA040IntEPM(nOpcao)
	Local oWSTreinamento, oTreinamento, oConteudo
	Local nOldSet := SetVarNameLen(255)

	Private nTamLayEmp  := len(FWSM0Layout(cEmpAnt,1))
	Private nTamLayUni  := len(FWSM0Layout(cEmpAnt,2))
	Private nTamLayFil  := len(FWSM0Layout(cEmpAnt,3))

	
	If SuperGetMv("MV_TRMINTG", NIL, .F.)
		oWSTreinamento:= EPMWSNew("Treinamento")
	
		If nOpcao == MODEL_OPERATION_UPDATE .OR.;
		   nOpcao == MODEL_OPERATION_INSERT
			oTreinamento:= TreinamentoWSService_TreinamentoWSHolder():New()

			If Empty(RA1->RA1_FILIAL)
				oTreinamento:cCdExterno 			   := RA1->RA1_CURSO
			Else
				oTreinamento:cCdExterno 			   := RA1->RA1_FILIAL+RA1->RA1_CURSO
			EndIf	
			oTreinamento:cSigla 					   := AllTrim(RA1->RA1_DESC)
			oTreinamento:cTitulo 					   := LimpaMemo( RAY->RAY_DESCDT )
			oTreinamento:nSituacao 					   := Val(RAY->RAY_STATUS)
			oTreinamento:nPermissao 				   := 1

			oTreinamento:cCdAvaliacaoReacaoExterno 	   := xFilial("SQQ") + RAY->RAY_AVREAC
			oTreinamento:cCdCertificadoExterno 		   := RAY->RAY_CERTIF
			oTreinamento:cCertificacao		 		   := "" 
			
			oTreinamento:cType 						   := "ASSINCRONO"

			// Foi necessario a inclusao do tratamento dos campos do tipo Memo, pois esta
			// retornando um caracter ASC NULO ao final da edicao //
			oTreinamento:cTexto1 					   := LimpaMemo( RAY->RAY_OBJCUR )
			oTreinamento:cTexto2 					   := LimpaMemo( RAY->RAY_PUBALV )
			oTreinamento:cTexto3 					   := LimpaMemo( RAY->RAY_CNTPRG )

			oTreinamento:cIdNavegadorScorm 			   := ""
			oTreinamento:cIdAlterarLessonStatus 	   := ""
			oTreinamento:cIdTotalTime 				   := ""
			oTreinamento:cIdLessonStatus 			   := ""
			oTreinamento:cIdScoreRaw 				   := ""

			oTreinamento:nScoreAprovacao			   := RAY->RAY_SCRAPV
			oTreinamento:cPeriodo 					   := fGetDuracao(RA1->RA1_DURACA, RA1->RA1_UNDURA)
			
			oTreinamento:nAprovacaoScorm			   := Val(RAY->RAY_CAPVSC)
			oTreinamento:nCargaHora 				   := Int(RA1->RA1_HORAS)
			oTreinamento:nCargaMinuto 				   := (RA1->RA1_HORAS - Int(RA1->RA1_HORAS)) * 100
			
			oTreinamento:cAutor 					   := ""
			oTreinamento:cCdAutorExterno 			   := "1"

			oTreinamento:cPreTestePreRequisito 		   := IIF(RAY->RAY_PREOBG  == "1", "Y", "N")
			oTreinamento:nScoreAprovacaoPre 		   := 0
			oTreinamento:cIdFinalizar 				   := ""

			// Montagem do Unidade
			//-----------------------------------		
			// Prepara relacionamento com unidade
			If Empty(RA1->RA1_FILIAL)
	           cPai   := FWCodEmp() + FWunitBusiness() 
			   cFilho := FWCodFil()	
			else
				//Captura Empresa
				cEmp := substr(RA1->RA1_FILIAL, 1, nTamLayEmp)
				//Captura Unidade
				cUni := substr(RA1->RA1_FILIAL, nTamLayEmp+1, nTamLayUni)
				//Captura Filial
				cFil := substr(RA1->RA1_FILIAL, nTamLayEmp+nTamLayUni+1, nTamLayFil)
		
		        // Tratamento para Gestao de Empresas //
		        If nTamLayEmp > 0 .Or. nTamLayUni > 0
			        //Identifica Pai-Filho para Filial SQ0
					If !Empty(cFil) .and. cFil <> Nil
						cPai   := cEmp+cUni
						cFilho := cEmp+cUni+cFil
					Else 
						If !Empty(cUni) .and. cUni <> Nil
							cPai   := cEmp
							cFilho := cEmp+cUni
						Else
							If !Empty(cEmp) .and. cEmp <> Nil
								cPai   := FWGrpCompany()
								cFilho := cEmp
							EndIf
						EndIf	
			        EndIf
			    Else
			    	cPai	 	:= FWGrpCompany()
		   			cFilho 		:= RA1->RA1_FILIAL
			    Endif     
		    EndIf    
	
				
			oTreinamento:oWSListaUnidade:= TreinamentoWSService_ListaUnidadeWSHolder():New()
			oTreinamento:oWSListaUnidade:oWSUnidade:= {}
			
			AAdd(oTreinamento:oWSListaUnidade:oWSUnidade, TreinamentoWSService_UnidadeWSHolder():New())
			oTreinamento:oWSListaUnidade:oWSUnidade[1]:cCdPaiExterno		:= cPai
			oTreinamento:oWSListaUnidade:oWSUnidade[1]:cCdFilhoExterno		:= cFilho
			oTreinamento:oWSListaUnidade:oWSUnidade[1]:cTipoUnidade			:= "1"
			//----------------------------------------------------------------------
	

			// Montagem do Conteudo
			oTreinamento:oWSListaConteudo:= TreinamentoWSService_ListaConteudoWSHolder():New()
			oTreinamento:oWSListaConteudo:oWSConteudo:= {}
	            
			DBSelectArea("RAU")
			DBSetOrder(1)

			RAU->(DBSeek(xFilial("RAU", RA1->RA1_FILIAL) + RA1->RA1_CURSO))
			While !RAU->(EOF()) .AND.;
					xFilial("RAU", RA1->RA1_FILIAL) == RAU->RAU_FILIAL .AND.;
					RA1->RA1_CURSO 					== RAU->RAU_CURSO
				oConteudo				:= TreinamentoWSService_ConteudoWSHolder():New()
				oConteudo:cCdExterno 	:= RAU->RAU_CONTEU
				oConteudo:cPosicao		:= RAU->RAU_SEQUEN
	
				AAdd(oTreinamento:oWSListaConteudo:oWSConteudo, oConteudo)
				RAU->(DBSkip())
			EndDo
	

			If !oWSTreinamento:InsertTreinamento(oTreinamento)
				Alert("Nao foi possivel gravar o treinamento no EPM!" + Chr(13) + GetWSCError())
			EndIF
		ElseIf nOpcao == MODEL_OPERATION_DELETE
			If Empty(RA1->RA1_FILIAL)
				If !oWSTreinamento:deleteTreinamento( RAY->RAY_CURSO )
					Alert("Nao foi possivel deletar o treinamento no EPM!" + Chr(13) + GetWSCError())
				EndIf
			Else
				If !oWSTreinamento:deleteTreinamento( RAY->RAY_FILIAL+RAY->RAY_CURSO )
					Alert("Nao foi possivel deletar o treinamento no EPM!" + Chr(13) + GetWSCError())
				EndIf
			EndIf
		EndIf
	EndIf		

	SetVarNameLen(nOldSet)
Return


Function RA1TIPOVLD()
	Local cTipo		:= &(ReadVar())
	Local lEPMInt	:= SuperGetMv("MV_TRMINTG", .F., .F.) .AND. ExistTables()
	
	If lEPMInt .AND. Type("oTree") != "U"
		oTree:BeginUpdate()
		
		If cTipo == "L"
			If !oTree:TreeSeek("6")
				oTree:AddItem(OemtoAnsi(STR0028), "6", "FOLDER5","FOLDER6", NIL, NIL, 1)	//"E-Learning"
			EndIf
	
			If !oTree:TreeSeek("7")
				oTree:AddItem(OemToAnsi(STR0027), "7", "FOLDER5","FOLDER6", NIL, NIL, 1)	//"Conteudo"				
			EndIf			    
		Else
			If oTree:TreeSeek("6")
				oTree:DelItem()
			EndIf
	
			If oTree:TreeSeek("7")
				oTree:DelItem()
			EndIf			    
		EndIf

		oTree:EndUpdate()
	EndIf
Return .T.

Static Function fGetDuracao(nDuracao, cUnidade)
	Local nRet:= 1
	
	cUnidade:= AllTrim(cUnidade)
	
	Do Case
		Case (cUnidade == 'A' ); ( nRet := nDuracao * 356)
		Case (cUnidade == 'M' ); ( nRet := nDuracao * 30 )
		Case (cUnidade == 'D' ); ( nRet := nDuracao )
	End Case
Return AllTrim(Str(nRet))

Static Function ExistTables()	
	Local lReturn:= .F.
	Local aArea:= GetArea()
	
	dbSelectArea("SX2")
	dbSetOrder(1)
	
	If SX2->(DBSeek("RAU")) .AND. SX2->(DBSeek("RAY"))
		lReturn := .T.
	EndIf
	
	RestArea(aArea)
Return lReturn

// Funcao criada para retirar um caractere estranho quando e 
// utilizado o campo Memo 
Function LimpaMemo( cTexto )
Local nX     := 0                
Local nAsc   := 0   
Local cChar  := ''             
Local cREt   := ''                 
For nX := 1 To Len( cTexto )
       cChar := Subs( cTexto, nX, 1 )
	   nAsc  := Asc( cChar )
	If nAsc > 31 .and. nAsc < 127
	   cRet += cChar
	Else
		cRet += ' '
	EndIf	   
Next	 

Return AllTrim( cRet )

/*/{Protheus.doc} RA6Empty
	
	Verifica se a RA6 não foi preenchida mesmo que o usuário não passe por ele.

	@type  Static Function
	@author rafaelalmeida

	@param nOpcx, Numeric, Opcao do Menu.

	@since 22/06/2020
	@version version
	
	@return lRet, Logic, Indica se a RA6 está correta.
	
	/*/
Static Function RA6Empty(nOpcX)
Local aHdrAux	:= {}
Local aClsAux	:= {}
Local lAchou	:= .F.
Local lRet 		:= .T.
Local nXi		:= 1

// Realizo copia dos dados que ja estiverem salvos
aHdrAux	:= aClone(aHeader)
aClsAux	:= aClone(aCols)

// Limpo as variaveis
aHeader	:= {}
aCols	:= {}

// Carrega dados da aba de Entidades
Tr040Obter(2,@aHeader,@aCols, nOpcx)

If Empty(aCols)
	lRet := .F.
Else
	For nXi := 1 To Len(aCols)
		If !(aCols[nXi][Len(aCols[nXi])])//Ignoro as linhas deletadas.
			lAchou := .T.
			If	Empty(aCols[1][AScan(aHeader,{|x|AllTrim(x[2]) == "RA6_ENTIDA"})])//O código da entidade tem que estar preenchidi
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next

EndIf

If !lAchou//Se todas as linhas da pasta de Entidades estiverem deletadas ou vazias.
	lRet := .F.
EndIf

// Retorno conteudo dos dados
aHeader := aClone(aHdrAux)
aCols 	:= aClone(aClsAux)

Return lRet
