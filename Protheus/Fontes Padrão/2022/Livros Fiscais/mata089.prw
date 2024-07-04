#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA089.ch"
#INCLUDE "FWMVCDEF.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MATA089  ³ Autor ³ Aline Correa do Vale  ³ Data ³ 07.08.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de TES Inteligente                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Mata089(xRotAuto,nOpcAuto)
Local nQtdFMID	:= 0 
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.) 

Private aAchoSFM := fCamposSFM()

PRIVATE aRotAuto  := xRotAuto

nOpcAuto := If (nOpcAuto == Nil,3,nOpcAuto)
//Verifica se a tabela SFM deverá ser atualizada
nQtdFMID	:=  ProcFMID()

If lVerpesssen
	If nQtdFMID > 0 .AND. LockByName("A089ChkIdSFM",.T.,.T.)
		
		Begin Transaction
		
		Processa({|| ChkIdSFM(nQtdFMID)},,,.T.)	
		
		End Transaction
		
		UnLockByName( 'A089ChkIdSFM', .T. , .T. )
		
	EndIF					

	dbSelectArea("SFM")
	SFM->(dbSetOrder(1))

	If GetRpoRelease() >= "R9"
		If	xRotAuto <> NIL
			Private aRotina := MenuDef()
			FWMVCRotAuto(ModelDef(),"SFM",nOpcAuto,{{"SFMMASTER",aRotAuto}})	
		Else
			DEFINE FWMBROWSE oMBrowse ALIAS "SFM"
			ACTIVATE FWMBROWSE oMBrowse
		EndIf
	Else
		PRIVATE aRotina := MenuDef()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define o cabecalho da tela de atualizacoes                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PRIVATE cCadastro := OemtoAnsi(STR0001)	//"TES Inteligente"
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Endereca a funcao de BROWSE                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType(aRotAuto) == "A"
			MsRotAuto(nOpcAuto,aRotAuto,"SFM")
		Else
			mBrowse( 6, 1,22,75,"SFM")
		EndIf
	EndIf
EndIf

Return .t.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A089Inclui³ Autor ³ Aline Correa do Vale  ³ Data ³ 13/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao de Tes Inteligente                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA089()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A089Inclui(cAlias,nReg,nOpc)

Local nOpca := 0
Local lCopySFM	 := Iif('SFM' $ Upper(GetNewPar("MV_FISCOPY",'')), .T.,.F.)
INCLUI := .T.
ALTERA := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpcA:=0

//Controle de Transaction movido para função CopySFM
//Begin Transaction
	nOpcA:=AxInclui( cAlias, nReg, nOpc, aAchoSFM,,,"A089TudOk()",,,,,aRotAuto)
	
	//Trecho que irá replicar a inclusão do tes inteligente para as demais filiais
	If lCopySFM .AND. nOpcA == 1		
		CopySFM(QrySFM(SFM->(Recno())))		 
	EndIF
	
//End Transaction
	
dbSelectArea(cAlias)
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A089Altera³ Autor ³ Aline Correa do Vale  ³ Data ³ 13/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao de Tes Inteligente                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA089()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A089Altera(cAlias,nReg,nOpc)

Local nOpca := 0
INCLUI := .F.
ALTERA := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpcA:=0

Begin Transaction
	nOpcA:=AxAltera( cAlias, nReg, nOpc, aAchoSFM,,,,"A089TudOk()",,,,,aRotAuto)
End Transaction

dbSelectArea(cAlias)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A089Deleta³ Autor ³Alexandre Inacio Lemes ³ Data ³27/04/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exclusao da TES Inteligente                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A089Deleta(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ COMA035                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A089Deleta(cAlias,nReg,nOpc)

Local aArea	   := GetArea()
Local aButtons := {}
Local nOpcA    := 1  
Local oDlg
Local aObjects := {}                  
Local aInfo    := {}
Local aSize    := MsAdvSize(,.F.,400)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTELA[0][0],aGETS[0]

If SoftLock("SFM")  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajusta a largura para o tamanho padrao Protheus ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If !FWIsInCallStack("MSEXECAUTO")
		aObjects := {}
		AAdd( aObjects, { 100, 100, .T., .T. } )
		aInfo    := { aSize[1], aSize[2], aSize[3], aSize[4], 2, 2 } 
		aPosObj := MsObjSize( aInfo, aObjects ) 

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL	
			nOpcA:=Enchoice( "SFM", nReg, nOpc,,,,aAchoSFM,aPosObj[1])	
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 0,oDlg:End()},,aButtons)
	EndIf

	If nOpcA == 1  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apos passar por todas as verificacoes , deleta o registro    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If A089VldEx()                                                                                                     
			Begin Transaction
			dbSelectArea("SFM")
			RecLock("SFM",.F.)
			dbDelete()
			End Transaction
		EndIf
	EndIf

	MsUnLockAll()
	
EndIf

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A089VLDEX ³ Autor ³Alexandre Inacio Lemes ³ Data ³27/04/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida se pode ser feita a exclusao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A089VldEx()

Local aArea	:= GetArea()
Local lRet	:= .T.

If lRet
	If (ExistBlock("MT089DEL"))
		lRet := ExecBlock("MT089DEL",.F.,.F.)
		If Valtype( lRet ) <> "L"
			lRet := .T.
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet  

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A089TudOk ³ Autor ³ Aline Correa do Vale ³ Data ³ 13/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o registro esta com chave duplicada            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A089TudOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA089                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A089TudOk()
Local lRet			:= .T.
Local cWhere		:= "%"
Local cCPO			:= ""
Local cCPO1			:= ""
Local cUnico		:= ""
Local nOpcX			:= Iif(INCLUI, 3 , 4)
Local nRecContr	:= SFM->(Recno())
Local cAlias		:= "SFM"
Local cIndex		:= ""
Local cFiltro		:= ""
local nIndex		:= 0
Local lAchou		:= .F.
Local lCopySFM		:= Iif('SFM' $ Upper(GetNewPar("MV_FISCOPY",'')), .T.,.F.)
Local cMsg			:= ''
Local aEstrut		:= {}
Local nCont 		:= 0
Local cAliasSFM	:= 	''

Static nRecno		:= 0 

//Localiza a chame primaria
cUnico := FWX2Unico("SFM")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada que permite alterar a regra da chave unica.   ³
//³Isso permite que possa ser usado um campo customizado na regra.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock("MT089UNC"))
	cUnico  :=  ExecBlock("MT089UNC",.F.,.F.,{cUnico})
EndIf

IF !Empty(cUnico) .AND. SFM->(FieldPos("FM_ID")) == 0
	
	If ALTERA
		If nRecno == 0
			nRecno := SFM->(Recno())
		Endif 
		SFM->(dbGoTo(nRecno))
	EndIf
	
	#IFDEF TOP
	    	If (TcSrvType ()<>"AS/400")
	    		cAlias	:=	GetNextAlias()
	    		
				//Monta where com base na chame primaria
				cUnico	+= "+"
				nPos		:= 1
				While nPos>0
					nPos := At("+",cUnico) 
					cCpo := AllTrim(Substr(cUnico,1,nPos-1))
					If cCpo<>"FM_FILIAL" .And. !Empty(cCPO)
				      cCpo1	:= "M->" + cCPO
						cWhere+= "SFM." + cCPO + "=" + "'" + &cCPO1 + "'" + " AND " 
					Endif		
					cUnico := AllTrim(Substr(cUnico,nPos+1,Len(cUnico)))
				Enddo       
				cWhere := AllTrim(cWhere) + "%"
	    		
				BeginSql Alias cAlias		
					SELECT 
						SFM.R_E_C_N_O_ SFMRECNO
					FROM 
						%Table:SFM% SFM
					WHERE 
						SFM.FM_FILIAL=%xFilial:SFM% AND 
						%Exp:cWhere%		
						SFM.%NotDel%
				EndSql
			
			If (cAlias)->(!EoF())
				lAchou	:=	IIf(INCLUI, .T., Iif(ALTERA, nRecContr<>(cAlias)->SFMRECNO, .F.))
			Else
				lAchou	:= .F.
			EndIf
		Else
	#ENDIF	
		   cIndex  := 	CriaTrab(Nil,.F.)
	
			//Monta filtro com base na chame primaria
			cUnico	+= "+"
			nPos		:= 1
			While nPos>0
				nPos := At("+",cUnico) 
				cCpo := AllTrim(Substr(cUnico,1,nPos-1))
				If cCpo<>"FM_FILIAL" .And. !Empty(cCPO)
			      cCpo1	 := "M->" + cCPO
					cFiltro+= cCPO + "==" + "'" + &cCPO1 + "'" + " .AND. " 
				Endif		
				cUnico := AllTrim(Substr(cUnico,nPos+1,Len(cUnico)))
			Enddo       
			cFiltro := AllTrim(Substr(cFiltro,1,Len(cFiltro)-6))
			cFiltro := 'FM_FILIAL=="'+xFilial("SFM")+'" .And. ' + cFiltro
	
		   IndRegua (cAlias,cIndex,,,cFiltro,,.F.)
		   nIndex := RetIndex(cAlias)
		
			#IFNDEF TOP
				DbSetIndex(cIndex+OrdBagExt())
			#ENDIF
			
			DbSelectArea(cAlias)
		   (cAlias)->(DbSetOrder(nIndex+1))
			(cAlias)->(DbGoTop())
			
			If (cAlias)->(!EoF())
				lAchou	:=	IIf( INCLUI, .T., Iif (ALTERA, nRecContr<>(cAlias)->(Recno()) , .F. ) )
			Else
				lAchou	:= .F.
			EndIf
			
	#IFDEF TOP
		EndIf
	#ENDIF
Else

	aEstrut	:= SFM->(dbStruct()) //Monta estrutura da SFM

	For nCont := 1 to Len(aEstrut)
		If aEstrut[nCont][2] <> 'M' .AND. !( "USERLGI" $ aEstrut[nCont][1] .OR. "USERLGA" $ aEstrut[nCont][1] )

			//Campo Filial não será copiado, já foi gravado anteriormente com conteúdo do xFilial
			If ! aEstrut[nCont][1] $ "FM_FILIAL/FM_ID/FM_DESCR"  
				IF  aEstrut[nCont][2] == 'C'
					cWhere	+= "SFM."+aEstrut[nCont][1]+ " = '" + &("M->"+aEstrut[nCont][1]) + "' AND "
				Else
					If aEstrut[nCont][2] == 'N' 
						cWhere	+= "SFM."+aEstrut[nCont][1]+ " = " + cValToChar(&("M->"+aEstrut[nCont][1])) + " AND "
					Else
						If aEstrut[nCont][2] == 'D'
							cWhere	+= "SFM."+aEstrut[nCont][1]+ " = '" + DtoS(&("M->"+aEstrut[nCont][1])) + "' AND "
						EndIf
					EndIf
				EndIF  				
			EndIF			

		EndIf
	Next nCont
	
	cWhere := alltrim(cWhere) + "%"
	
	//Valida todos os campos da SFM
	cAliasSFM	:=	GetNextAlias()
	BeginSql Alias cAliasSFM		
		SELECT 
			SFM.R_E_C_N_O_ SFMRECNO
		FROM 
			%Table:SFM% SFM
		WHERE 
			SFM.FM_FILIAL=%xFilial:SFM% AND 
			%Exp:cWhere%		
			SFM.%NotDel%
	EndSql

	If (cAliasSFM)->(!EoF())
		lAchou	:=	IIf(INCLUI, .T., Iif(ALTERA, nRecContr<>(cAliasSFM)->SFMRECNO, .F.))
	Else
		lAchou	:= .F.
	EndIf

	(cAliasSFM)->(DbCloseArea())
	
EndIF

If lAchou
	Help(" ",1,"JAGRAVADO")
	lRet := .F.
EndIf

#IFDEF TOP
	If (TcSrvType ()<>"AS/400")
		If Select(cAlias)<>0
			(cAlias)->(DbCloseArea())
		EndIf
	Else
#ENDIF
		RetIndex(cAlias)
#IFDEF TOP
	EndIf
#ENDIF


If !Empty(M->FM_CLIENTE) .Or. !Empty(M->FM_LOJACLI)
	SA1->(dbSetOrder(1))
	If !SA1->(MsSeek(xFilial("SA1")+M->FM_CLIENTE+M->FM_LOJACLI ))
		Help(" ",1,"FT089CLI") //O cliente e a loja informados no cadastro não é valido.
		lRet := .F.
	Endif
Endif

If lRet
	If !Empty(M->FM_FORNECE) .Or. !Empty(M->FM_LOJAFOR)
		SA2->(dbSetOrder(1))
		If !SA2->(MsSeek(xFilial("SA2")+M->FM_FORNECE+M->FM_LOJAFOR ))
			Help(" ",1,"FT089FOR") //O fornecedor e a loja informados no cadastro não é válido.
			lRet := .F.
		Endif
	Endif
Endif

If lRet
	If (ExistBlock("MT089TOK"))
		lRet := ExecBlock("MT089TOK",.F.,.F.,{nOpcX})
		If Valtype( lRet ) <> "L"
			lRet := .T.
		EndIf
	EndIf
EndIf

If lRet .AND. INCLUI .AND. lCopySFM 

	cMsg	:=VldReplica()
	
	IF Len(Alltrim(cMsg)) > 0
		IF !IsBlind()
			MSGSTOP('TES Inteligente não será gravado, pois já está cadastrado na(s) filial(ais) abaixo:'  +  chr(13)+chr(10) + chr(13)+chr(10)+   cMsg,'Atenção')
		EndIF
		lRet	:= .F.
	Endif

EndIF

If lRet .AND. INCLUI  .AND. SFM->(FieldPos("FM_ID")) > 0 .AND. SX5->( dbSeek(xFilial('SX5')+"RV"+'SFM'))
	//Atualizar SX5 com o último ID utilizado
	FwPutSX5(,"RV","SFM",M->FM_ID, M->FM_ID, M->FM_ID)
EndIF

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MATA089  ³ Autor ³ Aline Correa do Vale  ³ Data ³ 09.08.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MaTesInt(ExpN1,ExcC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,ExpC7,    ³±±
±±																	  ExpC8)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ExpN1 = Documento de 1-Entrada / 2-Saida                     ³±±
±±³          ³ ExpC1 = Tipo de Operacao Tabela "DF" do SX5                  ³±±
±±³          ³ ExpC2 = Codigo do Cliente ou Fornecedor                      ³±±
±±³          ³ ExpC3 = Codigo da Loja do Cli/Forn                           ³±±
±±³          ³ ExpC4 = Tipo Cliente / Fornecedor                            ³±±
±±³          ³ ExpC5 = Codigo do produto	                                ³±±
±±³          ³ ExpC6 = Campo que contem a TES                               ³±±
±±³          ³ ExpC7 = Tipo Cliente (F=Cons.Final;L=Prod.Rural;R=Revendedor;³±±
±±³                                  S=Solidario;X=Exportacao/Importacao)   ³±±
±±³          ³ ExpC8 = Estado de Origem do documento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MaTesInt(nEntSai,cTpOper,cClieFor,cLoja,cTipoCF,cProduto,cCampo,cTipoCli,cEstOrig,cOrigem)
Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSA2	:= SA2->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSX3	:= SX3->(GetArea())
Local aTes		:= {}
Local aDadosCfo	:= {}
Local cTesRet	:= "   "
Local cGrupo	:= ""
Local cGruProd	:= ""
Local cQuery	:= ""
Local cQuery1	:= ""
Local cProg		:= "MT100"
Local cNCM		:= ""
Local cEstado	:= ""
Local cAliasSFM	:= "SFM"
Local cTabela	:= ""
Local lQuery	:= .F.
Local nPosCpo	:= 0
Local nPosCfo	:= 0
Local nFM_POSIPI:= SFM->(FieldPos("FM_POSIPI"))
Local nFM_EST	:= SFM->(FieldPos("FM_EST"))
Local nFM_MSBLQL:= SFM->(FieldPos("FM_MSBLQL"))
Local nFM_TIPOMO:= SFM->(FieldPos("FM_TIPOMOV"))
Local cAlias	:= ""	//Tabela a ser utiliza para informacoes do produto
Local c_GRTRIB	:= ""	//SBI->BI_GRTRIB	/	SB1->B1_GRTRIB
Local c_POSIPI	:= ""	//SBI->BI_POSIPI	/	SB1->B1_POSIPI
Local c_TS		:= ""
Local c_TE		:= ""
Local cSb1Sbz	:= SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local lArqProp	:= SuperGetMV("MV_ARQPROP",.F.,.F.)
Local bCond		:= {||.T.}
Local bCondAux	:= {||.T.}
Local lAddTes	:= .F.
Local bSort		:= {||}
Local bAddTes	:= {||.T.}
Local bAtTes	:= {||.T.}
Local bIFWhile	:= {||.T.}
Local aRet		:= {}
Local lRet		:= .T.
Local cTesSaiB1	:= ""
Local cTesEntB1	:= ""
Local lGrade	:= MaGrade()
Local nFM_GRPTI	:= SFM->(ColumnPos("FM_GRPTI"))
Local nFM_TPCLI	:= IIF(cPaisLoc == "BRA",SFM->(ColumnPos("FM_TIPOCLI")),0)
Local nB1_GRPTI	:= IIF(cPaisLoc == "BRA",SB1->(ColumnPos("B1_GRPTI")),0)
Local nFM_GRPCST:= SFM->(ColumnPos("FM_GRPCST"))
Local nB1_GRPCST:= IIF(cPaisLoc == "BRA",SB1->(ColumnPos("B1_GRPCST")),0)
Local cGrpcst	:= ""
Local c_GRPCST 	:= "" 
Local cGrupoTI	:= ""
Local cTpCliFor	:= ""
Local c_GRPTI	:= ""
Local cGrpTi	:= ""
Local cTipFrete := Iif(Type("M->C5_TPFRETE")<>"U",M->C5_TPFRETE,"")
Local lTipPed	:= Type("M->C5_TIPO") <> "U"
Local cMVA089FAC := GetNewPar("MV_A089FAC","")
Local aCndTesInt	:= {} //Array com informações da condição do Tes inTeligente.
Local nQtdeEnq	:= 0
Local cPrOrdClie	:= "{1,2,3,4,5,6,7,8,9,10,11,12}" 
Local cPrOrdForn	:= "{1,2,3,4,5,6,7,8,9,10}" 
Local cOrdClie	:= GetNewPar("MV_OTICLI",cPrOrdClie) //Ordem dos campos da SFM Cliente
Local cOrdForn	:= GetNewPar("MV_OTIFOR",cPrOrdForn) //Ordem dos campos da SFM Fornecedor
Local aOrdSFM	:= {}
Local aOrdForn	:= {}
Local nCont		:= 0
Local cLogTes	:= ""
Local nQtdEmp	:= 0
Local nPosQtdEnq	:= 0
Local lFmId			:= SFM->(FieldPos("FM_ID")) > 0
Local cIdFM		:= '' 
Local cRecno	:= ''
Local nFM_ORIGEM:= SFM->(FieldPos("FM_ORIGEM"))
Local lOrigLote := FindFunction("OrigemLote") .And. SuperGetMV("MV_ORILOTE",.F.,.F.)
Local oStatement 
Local cFinalQuery
Local aSetParam := {}
Local nJ := 0

DEFAULT cTpOper  := &(ReadVar())
DEFAULT cClieFor := ""
DEFAULT cProduto := ""
DEFAULT nEntSai  := 0
DEFAULT cTipoCF  := "C"
DEFAULT cCampo   := ""
DEFAULT cTipoCli := Iif(Type("M->C5_TIPOCLI")<>"U",M->C5_TIPOCLI,"")
DEFAULT cEstOrig := ""
DEFAULT cOrigem  := "" 	



//---------------------------------------------------
//Para nova regra irá buscar ordem dos campos da SFM.
//---------------------------------------------------
If cTipoCF	== 'C'
	If len(cOrdClie) >= 3 .AND. substr(cOrdClie,1,1) == '{' .AND. substr(cOrdClie,Len(cOrdClie),1) == '}'
		aOrdSFM	:= &(cOrdClie)
	EndIF
	
ElseIf len(cOrdForn) >= 3 .AND. substr(cOrdForn,1,1) == '{' .AND. substr(cOrdForn,Len(cOrdForn),1) == '}'
	aOrdSFM	:= &(cOrdForn)	
EndIF

If !Empty(cCampo) .AND. ValType(aHeader) == "A"
	nPosCpo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim(cCampo)})
	If nPosCpo > 0
		cTabela := GetSx3Cache(AllTrim(aHeader[nPosCpo,2]),"X3_ARQUIVO")
		RestArea(aAreaSX3)
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o grupo de tributacao do cliente/fornecedor         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea(IIf(cTipoCF == "C","SA1","SA2"))
dbSetOrder(1)
MsSeek(xFilial()+cClieFor+cLoja)
If cTipoCF == "C"
	cGrupo  := SA1->A1_GRPTRIB
	cEstado := SA1->A1_EST
	If Empty(cTipoCli)
		cTipoCli := SA1->A1_TIPO
	EndIf	
Else
	cGrupo  := SA2->A2_GRPTRIB
	cEstado := SA2->A2_EST
EndIf
//Verifica se cEstOrig foi carregado na chamada da função. Se sim substitui o valor que há em cEstado pelo valor de cEstOrig
If !Empty(cEstOrig) .and. cEstado <> cEstOrig
	cEstado := cEstOrig
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o codigo do produto informado eh de grade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGrade
	MatGrdPrrf(@cProduto)
EndIf

If nModulo == 23 .AND. !(FindFunction("STFIsPOS") .AND. STFIsPOS()) // Se não for Totvs PDV 
	dbSelectArea("SBI")
	dbSetOrder(1)
	If dbSeek(xFilial("SBI") + cProduto)
		cGruProd := SBI->BI_GRTRIB
			cNCM := SBI->BI_POSIPI
	Endif
Else
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1") + cProduto)
		cAlias   := "SB1"
		c_GRTRIB := "SB1->B1_GRTRIB"
		c_POSIPI := "SB1->B1_POSIPI"
		c_TS     := "SB1->B1_TS"
		c_TE     := "SB1->B1_TE"
		If nB1_GRPTI > 0
			c_GRPTI := "SB1->B1_GRPTI"
		EndIf
		If nB1_GRPCST > 0
			c_GRPCST := "SB1->B1_GRPCST"
		EndIf
		
		If cSb1Sbz == "SBZ"
			// Se existir registro no SBZ (Indicadores de Produtos) busca as informacoes desta tabela 
			c_GRTRIB  := "SBZ->BZ_GRTRIB"
			dbSelectArea("SBZ")
			SBZ->(dbSetOrder(1)) //BZ_FILIAL+BZ_PRODUTO
			If DbSeek(xFilial("SBZ") + cProduto) .And. lArqProp .And.!Empty(SBZ->BZ_GRTRIB)//O parametro eh true e o campo esta preenchido?
				// sim
				cGruProd := &(c_GRTRIB)
			ElseIf !lArqProp  // O parametro eh false busca o conteudo vazio da tabela SBZ
				cGruProd := &(c_GRTRIB)
			Else // Neste caso o parametro eh true e busca as informacoes na Tabela SB1
				c_GRTRIB := "SB1->B1_GRTRIB"
				cGruProd := &(c_GRTRIB)
			EndIf
		Else // neste caso busca as informacoes na tabela SB1 apenas
			cGruProd := &(c_GRTRIB)
			cTesSaiB1:= &(c_TS)
			cTesEntB1:= &(c_TE)
			If nB1_GRPTI > 0
				cGrpTI := &(c_GRPTI)
			EndIf
			If nB1_GRPCST > 0
				cGrpcst := &(c_GRPCST)
			EndIf
		EndIf
		// Como não existe o campo NCM na SBZ, não sendo o módulo 23, será verificado na SB1
		If !Empty(c_POSIPI)
			cNCM := &(c_POSIPI)
		Endif
		//Tratamento para Preencher a origem quando a mesma não vem por parâmetro. 
		//Para esse tratamento o parâmetro MV_A410OPE está como .T. (que habilita o campo FM_ORIGEM).
		//também é levado em consideração o parâmetro MV_ORILOTE que quando .T. (Traz a origem 
		//do produto na ultima NF de entrada levando em consideração lote e/ou sublote).
		IF Empty(cOrigem) .And. nFM_ORIGEM > 0 .AND. IsInCallStack("MATA410") .AND. lOrigLote
				cOrigem  := A890Origem()
			EndIf
		// Como não existe o campo GRUPO TI na SBZ, não sendo o módulo 23, será verificado na SB1
		If !Empty(c_GRPTI)
			cGrpTI := &(c_GRPTI)
		Endif

	EndIf
EndIf

If cTipoCF == "C" 	
	#IFDEF TOP
		bAddTes		:=	{||aAdd(aTes, {(cAliasSFM)->FM_PRODUTO,;
					(cAliasSFM)->FM_GRPROD,;
					IIf(nFM_POSIPI>0,(cAliasSFM)->FM_POSIPI,""),;
					(cAliasSFM)->FM_CLIENTE,;
					(cAliasSFM)->FM_LOJACLI,;
					(cAliasSFM)->FM_GRTRIB,;
					IIf(nFM_EST>0,(cAliasSFM)->FM_EST,""),;
					(cAliasSFM)->FM_TE,;
					(cAliasSFM)->FM_TS,;
					Iif(lGrade,(cAliasSFM)->FM_REFGRD,""),;
					Iif(nFM_GRPTI > 0, (cAliasSFM)->FM_GRPTI, ""),;
					Iif(nFM_TPCLI > 0, (cAliasSFM)->FM_TIPOCLI, ""),;
					Iif(nFM_GRPCST > 0, (cAliasSFM)->FM_GRPCST, ""),;
					nQtdeEnq,;
					Iif(nFM_TIPOMO > 0, (cAliasSFM)->FM_TIPOMOV, ""),;
					Iif(lFmId,(cAliasSFM)->FM_ID ,''),;
					(cAliasSFM)->R_E_C_N_O_,;
					Iif(nFM_ORIGEM > 0, (cAliasSFM)->FM_ORIGEM, "")})}
	#ELSE
		bAddTes		:=	{||aAdd(aTes, {(cAliasSFM)->FM_PRODUTO,;
						(cAliasSFM)->FM_GRPROD,;
						IIf(nFM_POSIPI>0,(cAliasSFM)->FM_POSIPI,""),;
						(cAliasSFM)->FM_CLIENTE,;
						(cAliasSFM)->FM_LOJACLI,;
						(cAliasSFM)->FM_GRTRIB,;
						IIf(nFM_EST>0,(cAliasSFM)->FM_EST,""),;
						(cAliasSFM)->FM_TE,;
						(cAliasSFM)->FM_TS,;
						Iif(lGrade,(cAliasSFM)->FM_REFGRD,""),;
						Iif(nFM_GRPTI > 0, (cAliasSFM)->FM_GRPTI, ""),;
						Iif(nFM_TPCLI > 0, (cAliasSFM)->FM_TIPOCLI, ""),;
						Iif(nFM_GRPCST > 0, (cAliasSFM)->FM_GRPCST, ""),;
						nQtdeEnq,;
						Iif(nFM_TIPOMO > 0, (cAliasSFM)->FM_TIPOMOV, ""),;
						Iif(lFmId,(cAliasSFM)->FM_ID ,''),;
						(cAliasSFM)->(Recno()),;
						Iif(nFM_ORIGEM > 0, (cAliasSFM)->FM_ORIGEM, "") })}	
	#ENDIF
					
					

		bSort		:=	{|x,y| x[14] > y[14]}
Else
	#IFDEF TOP
		bAddTes		:=	{|| aAdd(aTes,{(cAliasSFM)->FM_PRODUTO,;
					(cAliasSFM)->FM_GRPROD,;
					IIf(nFM_POSIPI>0,(cAliasSFM)->FM_POSIPI,""),;
					(cAliasSFM)->FM_FORNECE,;
					(cAliasSFM)->FM_LOJAFOR,;
					(cAliasSFM)->FM_GRTRIB,;
					IIf(nFM_EST>0,(cAliasSFM)->FM_EST,""),;
					(cAliasSFM)->FM_TE,;
					(cAliasSFM)->FM_TS,;
					Iif(lGrade,(cAliasSFM)->FM_REFGRD,""),;
					Iif(nFM_GRPTI > 0, (cAliasSFM)->FM_GRPTI, ""),;
					Iif(nFM_GRPCST > 0, (cAliasSFM)->FM_GRPCST, ""),;
					nQtdeEnq,;
					Iif(lFmId,(cAliasSFM)->FM_ID ,''),;
					(cAliasSFM)->R_E_C_N_O_,;
					Iif(nFM_ORIGEM > 0, (cAliasSFM)->FM_ORIGEM, "")})}									
	#ELSE
		bAddTes		:=	{|| aAdd(aTes,{(cAliasSFM)->FM_PRODUTO,;
						(cAliasSFM)->FM_GRPROD,;
						IIf(nFM_POSIPI>0,(cAliasSFM)->FM_POSIPI,""),;
						(cAliasSFM)->FM_FORNECE,;
						(cAliasSFM)->FM_LOJAFOR,;
						(cAliasSFM)->FM_GRTRIB,;
						IIf(nFM_EST>0,(cAliasSFM)->FM_EST,""),;
						(cAliasSFM)->FM_TE,;
						(cAliasSFM)->FM_TS,;
						Iif(lGrade,(cAliasSFM)->FM_REFGRD,""),;
						Iif(nFM_GRPTI > 0, (cAliasSFM)->FM_GRPTI, ""),;
						Iif(nFM_GRPCST > 0, (cAliasSFM)->FM_GRPCST, ""),;
						nQtdeEnq,;
						Iif(lFmId,(cAliasSFM)->FM_ID ,''),;
						(cAliasSFM)->(Recno()),;
						Iif(nFM_ORIGEM > 0, (cAliasSFM)->FM_ORIGEM, "")})}
	#ENDIF
	bSort		:=	{|x,y| x[13] > y[13]}
EndIf

bIRWhile		:=	{||((cAliasSFM)->(!Empty(FM_GRTRIB) .And. !Empty(FM_GRPROD)) .And. AllTrim(cGrupo)+AllTrim(cGruProd)==(cAliasSFM)->(AllTrim(FM_GRTRIB)+AllTrim(FM_GRPROD))) .Or.;
					(cAliasSFM)->(Empty(FM_GRTRIB) .Or. Empty(FM_GRPROD))}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada que permite alterar a regra de selecao do TES,³
//³alterar a ordem do array com os elementos encontrados pela     ³
//³rotina e alterar o conteudo do array com os campos do SFM.     ³
//³Todos os retornos tem que ser em forma de CodBlock.            ³
//³Caso seja incluido campo novo para ser tratado na regra, se faz³
//³necessario incluir no X2_UNICO do SFM.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT089CD")
	aRet		:= Execblock("MT089CD",.T.,.T.,{bCond,bSort,bIRWhile,bAddTes,cTabela,cTpOper})
	bCondAux	:= aRet[1]
	bSort		:= aRet[2]
	bIFWhile	:= aRet[3]
	bAtTes		:= aRet[4]
	If Len(aRet) > 4
		cTpOper	:= aRet[5]
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa por todas as regras validas para este caso          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para tratar seleção da tes inteligente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (ExistBlock("MT089TES"))
		cRet := ExecBlock("MT089TES",.F.,.F.,{nEntSai,cTpOper,cClieFor,cLoja,cProduto})
		If Valtype( cRet ) == "C"
			cQuery := cRet
			lQuery := .T.
			lRet := .F.
		EndIf
	EndIf
	If(lRet)
		lQuery := .T.
		cAliasSFM := GetNextAlias()
		oStatement := FwPreparedStatement():new()
		cQuery += "SELECT  
		If !Empty(cProduto)
			cQuery1 += Iif(EMPTY(cQuery1)," ( ","")+" (CASE "
			cQuery1 += "		WHEN SFM.FM_PRODUTO = ?"
			cQuery1 += "		THEN 1
			cQuery1 += "		ELSE 0
			cQuery1 += "	END)
			Aadd(aSetParam, cProduto)
		EndIf
		If !Empty(cGruProd)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE
			cQuery1 += "	  WHEN SFM.FM_GRPROD = ?"
			cQuery1 += "	  THEN 1
			cQuery1 += "	  ELSE 0
			cQuery1 += "  END)
			Aadd(aSetParam, cGruProd)
		EndIf
		If !Empty(cGrupo)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE
			cQuery1 += "  WHEN SFM.FM_GRTRIB = ?"
			cQuery1 += "  THEN 1
			cQuery1 += "  ELSE 0
			cQuery1 += " END)
			Aadd(aSetParam, cGrupo)
		EndIf
		If cTipoCF == "C" .And. !Empty(cClieFor) .And. !Empty(cLoja)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE
			cQuery1 += "	WHEN SFM.FM_CLIENTE = ? AND SFM.FM_LOJACLI = ?"
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
			Aadd(aSetParam, cClieFor)
			Aadd(aSetParam, cLoja)
		EndIf
		If cTipoCF == "F" .And. !Empty(cClieFor) .And. !Empty(cLoja)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE
			cQuery1 += "	WHEN SFM.FM_FORNECE = ? AND SFM.FM_LOJAFOR = ?"
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
			Aadd(aSetParam, cClieFor)
			Aadd(aSetParam, cLoja)
		EndIf
		If !Empty(cEstado)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_EST = ?"
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
			Aadd(aSetParam, cEstado)
		EndIf
		If lTipPed .And. !Empty(M->C5_TIPO) .And. nFM_TIPOMO > 0
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_TIPOMOV = ?"
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
			Aadd(aSetParam, M->C5_TIPO)
		EndIf
		If !Empty(cNCM)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_POSIPI = ?"
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
			Aadd(aSetParam, cNCM)
		EndIf
		If !Empty(cGrpTi)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_GRPTI = ?"
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
			Aadd(aSetParam, cGrpTi)
		EndIf
		If !Empty(cTipoCli)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_TIPOCLI = ?"
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
			Aadd(aSetParam, cTipoCli)
		EndIf
		If !Empty(cGrpcst)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_GRPCST = ?"
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
			Aadd(aSetParam, cGrpcst)
		EndIf
		If !Empty(cOrigem)
			cQuery1 += Iif(!EMPTY(cQuery1)," + "," ( ")+" (CASE 
			cQuery1 += "	WHEN SFM.FM_ORIGEM = ?"
			cQuery1 += "	THEN 1
			cQuery1 += "	ELSE 0
			cQuery1 += " END)
			Aadd(aSetParam, cOrigem)
		EndIf

		cQuery += Iif(!Empty(cQuery1),cQuery1+") QTDREGRA, ","")+"SFM.* FROM " + RetSqlName("SFM") + " SFM "
		cQuery += "WHERE SFM.FM_FILIAL = '" + xFilial("SFM") + "' "
		If nFM_MSBLQL > 0
			cQuery += "AND FM_MSBLQL <> '1'"
		EndIf
		cQuery += "AND SFM.FM_TIPO = ?"
		cQuery += "AND SFM.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY "+Iif(!Empty(cQuery1),"QTDREGRA DESC,","")+SqlOrder(SFM->(IndexKey()))
		Aadd(aSetParam, cTpOper)
	
		cAliasSFM := GetNextAlias()

		oStatement:SetQuery(cQuery)

		for nJ := 1 to LEN(aSetParam)
			oStatement:SetString(nJ,aSetParam[nJ])
		next


		cQuery:= oStatement:GetFixQuery()

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFM,.T.,.T.)
	
	else
		cAliasSFM := GetNextAlias()
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFM,.T.,.T.)
	EndIf
#ELSE
	dbSelectArea("SFM")
	dbSetOrder(1)
	MsSeek(xFilial("SFM")+cTpOper)
#ENDIF

lQuery1 := Iif(!Empty(cQuery1), .T., .F.) 
nQTDREGRA := Iif(lQuery1,(cAliasSFM)->QTDREGRA,0)

If ValType(nQTDREGRA) == "C"
	nQTDREGRA := Val(nQTDREGRA)
EndIf

While (cAliasSFM)->(!Eof()) .And. (cAliasSFM)->FM_TIPO==cTpOper
	// Caso a quantidade de regras atendidas seja igual a zero, significa que
	// não existe regra de TES Inteligente que atenda ao cenário informado.
	If ( lQuery1 .AND. (cAliasSFM)->QTDREGRA == 0 ) .AND. ( !Empty( aTes ) .OR. ( Empty( aTes ) .AND. !RegraGener( cAliasSFM ) ) )
		If Empty( aTes )
			(cAliasSFM)->( dbSkip() )
			Loop
		else
			Exit
		EndIf
	EndIf

	If (cPaisLoc == "RUS")
		// Verificar se possui Tipo do Contrato
		If (cTabela == "SC7")
			nPosContra := aScan(aHeader, {|x| AllTrim(x[2]) == AllTrim("C7_CONTRA")})
			nPosContRev := aScan(aHeader, {|x| AllTrim(x[2]) == AllTrim("C7_CONTREV")})
			
			If (nPosContra > 0 .And. nPosContRev > 0)
				DbSelectArea("CN9")
				CN9->(DbSetOrder(1))
				If (CN9->(DbSeek(xFilial("CN9") + aCols[n][nPosContra] + aCols[n][nPosContRev])))
					cTpContra := CN9->CN9_TPCTO
				Endif
			Endif
		Elseif (cTabela == "SD1")
			nPosPedido := aScan(aHeader, {|x| AllTrim(x[2]) == AllTrim("D1_PEDIDO")})
			nPosItem := aScan(aHeader, {|x| AllTrim(x[2]) == AllTrim("D1_ITEMPC")})
			
			If (nPosPedido > 0 .And. nPosItem > 0)
				DbSelectArea("SC7")
				SC7->(DbSetOrder(1))
				If (SC7->(DbSeek(xFilial("SC7") + aCols[n][nPosPedido] + aCols[n][nPosItem])))
					DbSelectArea("CN9")
					CN9->(DbSetOrder(1))
					If (CN9->(DbSeek(xFilial("CN9") + SC7->C7_CONTRA + SC7->C7_CONTREV)))
						cTpContra := CN9->CN9_TPCTO
					Endif
				Endif
			Endif
		Elseif (cTabela == "SC6")
			DbSelectArea("CN9")
			CN9->(DbSetOrder(1))
			If (CN9->(DbSeek(xFilial("CN9") + M->C5_MDCONTR)))
				cTpContra := CN9->CN9_TPCTO
			Endif
		Endif
		
		
		If (nFM_TPCTO > 0 .And. AllTrim(cTpContra) != AllTrim((cAliasSFM)->FM_TPCTO))
			dbSelectArea(cAliasSFM)
			dbSkip()
			LOOP
		Endif
	Endif

	//Será considerado como prioridade a maior quantidade de campos enquadrados
	lAddTes	:= .F.
	nQtdeEnq	:= 0			
	If !Empty((cAliasSFM)->FM_TS) .Or. !Empty((cAliasSFM)->FM_TE)

		aCndTesInt	:= Condicao(cAliasSFM,	nFM_EST,	nFM_TIPOMO,	nFM_POSIPI,	nFM_GRPTI,;
								nFM_TPCLI,	nFM_GRPCST,	lGrade,		cTipoCF,	cProduto,;
								cGruProd,	cClieFor,	cLoja,		cGrupo,		cEstado,;
								cNCM,		cGrpTi,		cTipoCli,	cGrpcst,	lTipPed,;
								nFM_ORIGEM, cOrigem)

		nQtdeEnq	:= aCndTesInt[2]
		lAddTes	:= aCndTesInt[1]
	EndIF

	IF lAddTes .AND. Eval(bCondAux)
		If Eval(bIRWhile) .And. Eval(bIFWhile)
			Eval(bAddTes)//Adiciono o conteudo original da rotina
			Eval(bAtTes) //Caso o ponto de entrada MT089CD esteja ativo, adiciono o retorno dele
		EndIf
	EndIf

	(cAliasSFM)->( dbSkip() )
EndDo

If ( lQuery )
	(cAliasSFM)->( dbCloseArea() )
	dbSelectArea("SFM")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa por todas as regras validas para este caso          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSort(aTES,,,bSort) //Ordena o array conforme passado na regra do bSort, podendo ser alterardo pelo PE MT089CD

//Caso utilize ponto de entrada, mantenho o legado do sistema
If !ExistBlock("MT089CD")	
	//------------------------------------------------------------------
	//Para nova regra, deverá verificar se houve empate de enquadramento
	//------------------------------------------------------------------
	//Verifica se existe empate, se existir irá desempatar pela regra do cliente	
	If !Desempate(@aTes,cTipoCF,aOrdSFM, Iif(cTipoCF == 'C',cPrOrdClie ,cPrOrdForn ))
		
		//Se não conseguiu desempatar pela regra do cliente irá tentar desempatar pela regra padrão
		IF !Desempate(@aTes,cTipoCF,,Iif(cTipoCF == 'C',cPrOrdClie ,cPrOrdForn ))
			//Se ainda assim não conseguiu desempatar, pela regra do cliente e pela regra padrão
			//é porque existem regras cadastradas na SFM somente com tipo de movimento igual copm TES diferente ou
			//regras com mesmo campos chaves iguais, neste caso não irei sugerir nenhum TES pois este cadastro está duplicado.
			//Por este motivo irei zerar o aTES  
			//Abaixo trecho de LOG para incidar regras de TES que estão empatadas e que a rotina não irá sugerir por falta de critério
			//o usuário deverá analisar estes empates para rever as regras e eliminar regras conflitantes.			
			
			nPosQtdEnq	:= Iif(cTipoCF == "C",14,13)			
			nQtdEmp	:= aTES[1][nPosQtdEnq]  
			
			ProcLogIni({})
			ProcLogAtu("INICIO",STR0009,,'MATA089')
			For nCont := 1 to len(aTES)
				
				cIdFM	:= ''
				If lFmId
					cIdFM	:= aTES[nCont][Iif(cTipoCF == "C",16,14)]					
				EndIF
				
				cRecno	:= cvaltochar(aTES[nCont][Iif(cTipoCF == "C",17,15)]) 			
							
				//Somente irei guardar LOG dos empates com maior número de enquadramento
				IF nQtdEmp ==  aTES[nCont][nPosQtdEnq]
					cLogTes	+= Iif(!Empty(cIdFM),'Código da Regra de TES Inteligente: ' + cIdFM ,'' ) + " TES: " + aTES[nCont][ Iif(nEntSai==1,8,9) ] + " Tipo de Movimentação: " +  cTpOper +" Rotina: " + FunName() + " RECNO: " + cRecno +  CHR(10)+CHR(13)	+  CHR(10)+CHR(13)				
				Else					 
					Exit
				EndIF 
				
			Next nCont			
			
			ProcLogAtu("ERRO",STR0013,cLogTes,'MATA089')			
			ProcLogAtu("FIM",STR0014,,'MATA089')
			aTES	:= {}
		EndIF		
	EndIF
EndIF

If Len(aTes) <> 0
	cTesRet := If(nEntSai==1,aTes[1][8],aTes[1][9])
EndIf

If nPosCpo > 0 .And. !Empty(cTesRet) .And. Type('aCols') <> "U"
	aCols[n][nPosCpo] := cTesRet
	Do Case
		Case cTabela == "SD1"
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("D1_CF") })
		Case cTabela == "SD2"
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("D2_CF") })
		Case cTabela == "SC6"
			dbSelectArea("SF4")
			dbSetOrder(1)
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("C6_CF") })
			If nPosCfo > 0 .And. MsSeek(xFilial("SF4")+cTesRet)
				aDadosCfo := {}
				AAdd(aDadosCfo,{"OPERNF","S"})
				AAdd(aDadosCfo,{"TPCLIFOR",If(cTipoCF == "C", cTipoCli     , SA2->A2_TIPO )})
				AAdd(aDadosCfo,{"UFDEST"  ,If(cTipoCF == "C", SA1->A1_EST  , SA2->A2_EST  )})
				AAdd(aDadosCfo,{"INSCR"   ,If(cTipoCF == "C", SA1->A1_INSCR, SA2->A2_INSCR)})
				AAdd(aDadosCfo,{"CONTR"   ,If(cTipoCF == "C", SA1->A1_CONTRIB, "")})
				Aadd(aDadosCfo,{"FRETE"   ,cTipFrete})
				aCols[n][nPosCfo] := MaFisCfo( ,SF4->F4_CF,aDadosCfo )
			EndIf
			nPosCfo := 0
		Case cTabela == "SC7"
			cProg := "MT120"
		Case cTabela == "SC8"
			cProg := "MT150"
		Case cTabela == "SUB"
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("UB_CF") })
			cProg := "TK273"
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Agroindustria  		   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cTabela == "NKO"  
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("NKO_TES") })
		
	EndCase
	If nPosCfo > 0
		aCols[n][nPosCfo] := Space(Len(aCols[n][nPosCfo]))
	EndIf
	If MaFisFound("IT",N)
		MaFisAlt("IT_TES",cTesRet,n)
		MaFisRef("IT_TES",cProg,cTesRet)
	EndIf
EndIf
If !Empty(cTesRet)
	dbSelectArea("SF4")
	If SF4->( MsSeek(xFilial("SF4")+cTesRet) )
		If !RegistroOK("SF4")
			cTesRet := Space(Len(cTesRet))
		EndIf
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso NENHUMA regra tenha sido aplicada, ao inves de retornar uma TES em ³
	//³branco, a instrucao a seguir MANTEM a TES existente no aCols, ANTES da  ³
	//³execucao do gatilho do campo ??_OPER que executou esta funcao MaTesInt()³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	If Type("aCols") == "A" .AND. !(nModulo == 12)  .And. (!Empty(cTesSaiB1) .Or. !Empty(cTesEntB1))
		nPosTes := aScan(aHeader,{|x| AllTrim( Substr( x[2] , AT("_TES" , x[2] ) , AT("_TES" , x[2] )+ 4  ))  == AllTrim("_TES") } )
		If nPosTes > 0
			cTesRet := aCols[N,nPosTes]
		EndIf
	ElseIf cCampo == 'CK_TES'
		cTesRet := TMP1->CK_TES
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da rotina                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSA2)
RestArea(aAreaSA1)
RestArea(aAreaSB1)
RestArea(aArea)
Return(cTesRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
Local aRotAdic:= {}
If GetRpoRelease() >= "R9"
	aRotina := {}
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.MATA089"	OPERATION MODEL_OPERATION_VIEW		ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.MATA089"	OPERATION MODEL_OPERATION_INSERT	ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.MATA089"	OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.MATA089"	OPERATION MODEL_OPERATION_DELETE	ACCESS 3 //"Excluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "A089WizFac"		OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //"Wizard"
	ADD OPTION aRotina TITLE STR0008 ACTION 'ProcLogView("","MATA089")'	OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //"Wizard"
	ADD OPTION aRotina TITLE STR0015 ACTION 'COPYTESINT'		OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //"Replicar TES"
	ADD OPTION aRotina TITLE STR0016 ACTION 'A089Copy'			OPERATION MODEL_OPERATION_INSERT	ACCESS 0 //"Copiar TES"

	If ExistBlock("MA089MNU")
		aRotAdic := ExecBlock("MA089MNU",.F.,.F.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic,{|x| AAdd(aRotina,x)})
		EndIf
	EndIf
Else
	Private aRotina := {	{ STR0002, "AxPesqui"  , 0 , 1,0,.F.},; //"Pesquisar"
							{ STR0003, "AxVisual"  , 0 , 2,0,NIL},; //"Visualizar"
							{ STR0004, "A089Inclui", 0 , 3,0,NIL},; //"Incluir"
							{ STR0005, "A089Altera", 0 , 4,0,NIL},; //"Alterar"
							{ STR0006, "A089Deleta", 0 , 5,0,NIL} } //"Excluir"

	aAdd(aRotina,{OemtoAnsi(STR0007), "A089WizFac", 0, 4, 2, .F.}) //"Facilitador"
	aAdd(aRotina,{OemtoAnsi(STR0008), 'ProcLogView("","MATA089")', 0, 4, 2, .F.}) //"Facilitador"
	aAdd(aRotina,{OemtoAnsi(STR0015), 'COPYTESINT', 0, 4, 2, .F.}) //"Replicar TES"	
	aAdd(aRotina,{OemtoAnsi(STR0016), 'A089Copy', 0, 3, 2, .F.}) //"Copiar TES"	
	If ExistBlock("MA089MNU")
		ExecBlock("MA089MNU",.F.,.F.)
	EndIf
EndIf
Return(aRotina)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A089WizFac³ Autor ³ Gustavo G. Rueda      ³ Data ³27/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada da rotina que permite uma manutencao facil no      ³±±
±±³          ³ cadastro.                                                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A089WizFac()
Local cCmps := ""
Local aPar  := {}
Local cMVA089FAC := GetNewPar("MV_A089FAC","")

dbSelectArea("SFM")
SFM->(dbSetOrder(1))

cCmps := "FM_TE/FM_TS/FM_EST/FM_GRTRIB/FM_GRPROD/FM_POSIPI/FM_REFGRD/FM_DESREF/FM_TIPOMOV/FM_GRPCST"
cCmps += cMVA089FAC

cPosiciona := "Posicione('SX5',1,xFilial('SX5')+'DJ'+FM_TIPO,'X5_DESCRI')"

aAdd(aPar,{"SFM","FM_TIPO", cCmps, cPosiciona})

MATA984(aPar[1,1],aPar[1,2],aPar[1,3],,aPar[1,4])

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A089Client³ Autor ³Alexandre Inacio Lemes ³ Data ³31/10/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avaliacao do fornecedor                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar a validacao do codigo  ³±±
±±³          ³e loja do fornecedor                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A089Client()

Local aArea		:= GetArea()
Local lRetorno	:= .T.

dbSelectArea("SA1")
If !Empty(M->FM_CLIENTE)
	If Empty(M->FM_LOJACLI)
		SA1->(dbSetOrder(1))
		SA1->(MsSeek(xFilial("SA1")+M->FM_CLIENTE))
		If SA1->(Found())
			M->FM_LOJACLI := SA1->A1_LOJA
			lRetorno := .T.
		EndIf
	Else
		lRetorno := ExistCpo("SA1",M->FM_CLIENTE+M->FM_LOJACLI)
	EndIf
Endif

RestArea(aArea)

Return(lRetorno)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A089Fornec³ Autor ³Alexandre Inacio Lemes ³ Data ³31/10/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avaliacao do fornecedor                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar a validacao do codigo  ³±±
±±³          ³e loja do fornecedor                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A089Fornec()

Local aArea		:= GetArea()
Local lRetorno	:= .T.

dbSelectArea("SA2")
If !Empty(M->FM_FORNECE)
	If Empty(M->FM_LOJAFOR) 
		SA2->(dbSetOrder(1))
		SA2->(MsSeek(xFilial("SA2")+M->FM_FORNECE))
		If SA2->(Found())
			M->FM_LOJAFOR := SA2->A2_LOJA
			lRetorno := .T.
		EndIf
	Else
		lRetorno := ExistCpo("SA2",M->FM_FORNECE+M->FM_LOJAFOR)
	EndIf
Endif

RestArea(aArea)

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A089Valid ºAutor  ³Rodrigo Aguilar     º Data ³  19/06/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao utilizada para realizar a conferencia do         º±±
±±º          ³ codigo de Grade Informado                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A089Valid()
Local lRet        := .T.
Local lReferencia := .F.
Local cNomeCampo  := ReadVar()
Local lGrade      := MaGrade()
Local cProdRef    := " "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ATENCAO -> Sempre que o campo de Grade (FM_REFGRD) for informado              ³
//³os campos que sao amarrados diretamente ao produto como (Código, NCM, e Grupo ³
//³de tributacao) devem ser vazios.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para o campo FM_REFGRD verifica-se o codigo do produto ³
//³para identificar se o mesmo se trata de Grade          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cNomeCampo=='M->FM_REFGRD'
	cProdRef:=&(ReadVar())
	If !Empty(cProdRef)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o produto possui grade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGrade
			lReferencia:=MatGrdPrrf(@cProdRef)
			If !lReferencia
				Help(" ",1,"REFGRADEFM")
				lRet :=.F.
			Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso nao tenha grade zera conteudo do campo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else
			Help(" ",1,"NOGRADEFM")
			M->FM_REFGRD := SPACE(TamSx3("FM_REFGRD")[1])
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. lGrade
		M->FM_DESREF  := DescPrRf(cProdRef) 
		M->FM_PRODUTO := SPACE(TamSx3("FM_PRODUTO")[1])
		M->FM_GRPROD  := SPACE(TamSx3("FM_GRPROD")[1])
		M->FM_POSIPI  := SPACE(TamSx3("FM_POSIPI")[1])
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando os campos abaixos forem preechidos deve-se apagar ³
//³o conteudo da Grade                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cNomeCampo=='M->FM_PRODUTO' .Or. cNomeCampo=='M->FM_GRPROD' .Or. cNomeCampo=='M->FM_POSIPI'	

		M->FM_REFGRD := Iif(cPaisLoc == "BRA", SPACE(TamSx3("FM_REFGRD")[1]), SPACE(TamSx3("FM_PRODUTO")[1]))
		M->FM_DESREF := Iif(cPaisLoc == "BRA", SPACE(TamSx3("FM_DESREF")[1]), SPACE(TamSx3("FM_PRODUTO")[1]))

EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Modelo do Programa de TES inteligente

@since 11/06/2012
@version P11.6 
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruSFM := FWFormStruct(1,'SFM')
Local oModel := MPFormModel():New('MATA089',,{|oModel|MT089PreVal(oModel)})

oModel:AddFields('SFMMASTER',,oStruSFM)
oModel:SetPrimarykey({'FM_ID'})
oModel:GetModel('SFMMASTER'):SetDescription(STR0001)

Return oModel
//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Interface do modelo de dados de TES inteligente

@since 11/06/2012
@version P11.6
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel	:= FWLoadModel('MATA089') 
Local oStruSFM 	:= FWFormStruct(2, 'SFM')
Local oView		:= FWFormView():New() 

oStruSFM:RemoveField('FM_CFO_O')
oStruSFM:RemoveField('FM_CFO_I')

oStruSFM:SetProperty('FM_ID',MVC_VIEW_ORDEM,'01')
oStruSFM:SetProperty('FM_DESCR',MVC_VIEW_ORDEM,'02')

oView:SetModel(oModel)
oView:CreateHorizontalBox("MAIN",100)
oView:AddField('VIEW_SFM', oStruSFM, 'SFMMASTER')
oView:SetOwnerView('VIEW_SFM','MAIN')

Return oView
//-------------------------------------------------------------------
/*{Protheus.doc} prevalA089
prevalidação do TES inteligente

@since 11/06/2012
@version P11.6
*/
//-------------------------------------------------------------------
Static Function MT089PreVal(oModel)
local lRet :=.T.
local nOpcX:= oModel:GetOperation()

If nOpcX==5
	If (ExistBlock("MT089DEL"))
		lRet := ExecBlock("MT089DEL",.F.,.F.)
		If Valtype( lRet ) <> "L"
			lRet := .T.
		EndIf
	EndIf
ElseIf nOpcX==4 .OR. nOpcX ==3
	If (ExistBlock("MT089TOK"))
		lRet := ExecBlock("MT089TOK",.F.,.F.,{nOpcX})
		If Valtype( lRet ) <> "L"
			lRet := .T.
		EndIf
	EndIf
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Condicao
 
Esta função irá definir se as regras da SFM processada deverá ou não ser considerada
para sugestão de TES.
Serão consideradas as regras que tiverem informações IGUAIS da nota  


@return	{lRet , nQtdeEnq}   - Array onde a primeira posição é se SFM deverá ou não ser considerada			
@return	{lRet , nQtdeEnq}   - Array onde a segunda posição é a quantidade de campos enquadrados
@author Erick G. Dias
@since 12/05/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function Condicao(cAliasSFM,	nFM_EST,	nFM_TIPOMO,	nFM_POSIPI,	nFM_GRPTI,;
						nFM_TPCLI,	nFM_GRPCST,	lGrade,		cTipoCF,	cProduto,;
						cGruProd,	cClieFor,	cLoja,		cGrupo,		cEstado,;
						cNCM,		cGrpTi,		cTipoCli,	cGrpcst,	lTipPed,;
						nFM_ORIGEM, cOrigem)

Local lPRODUTO := .F.
Local lREFGRD  := .F.
Local lGRPROD  := .F.
Local lCLILOJA := .F.
Local lFORLOJA := .F.
Local lGRTRIB  := .F.
Local lEST     := .F.
Local lTIPOMOV := .F.
Local lPOSIPI  := .F.
Local lGRPTI   := .F.
Local lTIPOCLI := .F.
Local lGRPCST  := .F.
Local lRet     := .F.
Local lORIGEM  := .F. 
Local nQtdeEnq := 0

//---------------------------------------------------------------------------
//INICIALIZA AS TODAS VARIÁVEIS COM .T. CASO A INFORMAÇÃO DA SFM ESTEJA VAZIA
//---------------------------------------------------------------------------
lPRODUTO := Empty((cAliasSFM)->FM_PRODUTO)
lGRPROD  := Empty((cAliasSFM)->FM_GRPROD)
lGRTRIB  := Empty((cAliasSFM)->FM_GRTRIB)
lCLILOJA := Empty((cAliasSFM)->(FM_CLIENTE+FM_LOJACLI))
lFORLOJA := Empty((cAliasSFM)->(FM_FORNECE+FM_LOJAFOR))
lREFGRD  := Iif (cPaisLoc == "BRA" .And. Empty((cAliasSFM)->FM_REFGRD),.T.,.F.)
lEST     := Iif((nFM_EST    > 0 .AND. Empty((cAliasSFM)->FM_EST))     .OR. nFM_EST    == 0,.T.,.F.)
lTIPOMOV := Iif((cPaisLoc == "BRA" .And. nFM_TIPOMO > 0 .AND. Empty((cAliasSFM)->FM_TIPOMOV)) .OR. nFM_TIPOMO == 0,.T.,.F.)
lPOSIPI  := IIf((nFM_POSIPI > 0 .AND. Empty((cAliasSFM)->FM_POSIPI))  .OR. nFM_POSIPI == 0,.T.,.F.)
lGRPTI   := Iif((nFM_GRPTI  > 0 .AND. Empty((cAliasSFM)->FM_GRPTI))   .OR. nFM_GRPTI  == 0,.T.,.F.)
lTIPOCLI := Iif((cPaisLoc == "BRA" .And. nFM_TPCLI  > 0 .AND. EmptY((cAliasSFM)->FM_TIPOCLI)) .OR. nFM_TPCLI  == 0,.T.,.F.)
lGRPCST  := Iif((nFM_GRPCST > 0 .AND. Empty((cAliasSFM)->FM_GRPCST))  .OR. nFM_GRPCST == 0,.T.,.F.)
lREFGRD  := Iif (cPaisLoc <> "BRA" ,.T.,lREFGRD)
lORIGEM  := Iif(nFM_ORIGEM > 0,Iif(Empty((cAliasSFM)->FM_ORIGEM),.T.,.F.),.T.)

//----------------------------------------------------------------------------------------------------------------------
//SE TODOS OS CAMPOS DA SFM ESTIVEREM VAZIOS, ENTÃO IRÁ ADICIONAR E NÃO TERÁ NENHUM ENQUADRAMENTO, É UMA REGRA GENÉRICA
//----------------------------------------------------------------------------------------------------------------------
If lCLILOJA .AND. lFORLOJA .AND. lEST   	.AND. lGRTRIB  .AND. lPRODUTO .AND. lGRPROD  .AND. ;
	lPOSIPI .AND. lREFGRD  .AND. lTIPOMOV  .AND. lGRPTI  .AND. lTIPOCLI .AND. lGRPCST .AND. lORIGEM
	lRet	:= .T.
EndIF
//------------------------------------------------------------------------
//VERIFICA CAMPO POR CAMPO DA SFM COMPARANDO COM INFORMAÇÃO DA NOTA FISCAL
//SOMENTE SE ALGUM CAMPO DA SFM ESTIVER PREENCHIDO
//------------------------------------------------------------------------

If !lRet

	If !lPRODUTO .And. Alltrim(cProduto) == Alltrim((cAliasSFM)->FM_PRODUTO)
		nQtdeEnq	++
		lPRODUTO	:= .T.
	EndIF
	
	If lGrade .AND. !lREFGRD .And. Alltrim((cAliasSFM)->FM_REFGRD) 	== Alltrim(cProduto)
		nQtdeEnq	++
		lREFGRD	:= .T.
	EndIF
	
	If !lGRPROD .AND. Alltrim(cGruProd) == Alltrim((cAliasSFM)->FM_GRPROD)
		nQtdeEnq	++
		lGRPROD	:= .T.
	EndIF
	
	If cTipoCF == 'C'
		If !lCLILOJA .AND. Alltrim(cClieFor+cLoja)  == Alltrim((cAliasSFM)->(FM_CLIENTE+FM_LOJACLI))
			nQtdeEnq	++
			lCLILOJA	:= .T.
		EndIF
	Else
		If !lFORLOJA .AND. Alltrim(cClieFor+cLoja) == Alltrim((cAliasSFM)->(FM_FORNECE+FM_LOJAFOR)) 
			nQtdeEnq	++
			lFORLOJA	:= .T.
		EndIF
	EndIF
	
	If !lGRTRIB .And. AllTrim(cGrupo) == AllTrim((cAliasSFM)->FM_GRTRIB)
		nQtdeEnq	++
		lGRTRIB	:= .T.
	EndIF
	
	If nFM_EST> 0 .And. !lEST .And. Alltrim(cEstado) == Alltrim((cAliasSFM)->FM_EST)
		nQtdeEnq	++
		lEST	:= .T.
	EndIF
	
	If !lTipPed .Or.(nFM_TIPOMO > 0 .And. lTipPed .And. !lTIPOMOV .And. Alltrim(M->C5_TIPO) == Alltrim((cAliasSFM)->FM_TIPOMOV))
		nQtdeEnq	++
		lTIPOMOV	:= .T.
	EndIF
	
	If nFM_POSIPI >0 .And. !lPOSIPI .And. Alltrim(cNCM) == Alltrim((cAliasSFM)->FM_POSIPI)
		nQtdeEnq	++
		lPOSIPI	:= .T.
	EndIF
	
	If nFM_GRPTI > 0 .And. !lGRPTI .And. Alltrim(cGrpTi) == Alltrim((cAliasSFM)->FM_GRPTI)
		nQtdeEnq	++
		lGRPTI	:= .T.
	EndIF
	
	If cTipoCF == 'C'
		If nFM_TPCLI > 0 .And. !lTIPOCLI .And. Alltrim(cTipoCli) == Alltrim((cAliasSFM)->FM_TIPOCLI)
			nQtdeEnq	++  
			lTIPOCLI	:= .T.
		EndIF
	EndIF
	
	If nFM_GRPCST > 0 .And. !lGRPCST .And. Alltrim(cGrpcst) == Alltrim((cAliasSFM)->FM_GRPCST)
		nQtdeEnq	++
		lGRPCST	:= .T.
	EndIF

	If nFM_ORIGEM > 0 .And. !lORIGEM .And. Alltrim(cOrigem) == Alltrim((cAliasSFM)->FM_ORIGEM) 
		nQtdeEnq	++
		lORIGEM	:= .T.
	EndIF

	//------------------------------------------------------------
	//FAZ VERIFICAÇÃO SE AS INFORMAÇÕES DA SFM PODERÁ SER SUGERIDA
	//------------------------------------------------------------
	If (Iif(cTipoCF == 'C',lCLILOJA,lFORLOJA)).AND. lEST   .AND. lGRTRIB  .AND. lPRODUTO .AND. lGRPROD  .AND. ;
		lPOSIPI .AND. lREFGRD  .AND. Iif(cTipoCF == 'C',lTIPOMOV,.T.) .AND. lGRPTI  .AND. Iif(cTipoCF == 'C',lTIPOCLI,.T.) .AND. lGRPCST .AND. lORIGEM 
		
		lRet	:= .T.	
	EndIF
	
EndIF

Return {lRet , nQtdeEnq}

//-------------------------------------------------------------------
/*/{Protheus.doc} Desempate
 
Esta função é responsável por resolver possível empate das regras,
caso existam duas ou mais Tes com a mesma quantidade de campos enquadrados,
caso exista, irá definir a Tes considerando ordem dos campos prioritários da SFM,
seja pela ordem padrão ou pela ordem definida pelo cliente 
  
@param  	aTes      - Array com informações dos Tes enquadrados
			cTipoCF   -Indca operação com Cliente 'C' ou fornecedor 'F'
			lRet      - Booleano indicando que houve desempate.
			

@return	lRet 	   - Retornar booleano, indicando que campo em questão está preenchido no aTes			
@author Erick G. Dias
@since 12/05/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function Desempate(aTes,cTipoCF,aOrdemTes, cOrdSFM)

Local nCont		:= 0
Local nQtde		:= 0
Local nContTes	:= 0
Local bSort		:=	Iif(cTipoCF == 'C',{|x,y| x[14] > y[14]},{|x,y| x[13] > y[13]})
Local lAlt			:= .F.
Local lRet			:= .F.
Local nPosATes	:= Iif(cTipoCF == 'C',14,13)

Default aOrdemTes	:= &(cOrdSFM)  //Ordem padrão do sistema

//Verifica se existem regras empatadas no array aTes
//A variável nQtde terá a quantidade de TES empatadas
If CheckEmpate(aTes,@nQtde,cTipoCF)

	//Aqui existem pelo menos duas regras empatadas.	Irá então processar a ordem dos campos de prioridade para desempatar e sugerir o TES
	For nCont := 1 to Len(aOrdemTes)
		lAlt	:= .F.
		//Irá verificar em todos os tes empatados a ordem dos campos
		For nContTes	:= 1 to nQtde		
			
			If ChkOrdSFM(aTes[nContTes],aOrdemTes[nCont],cTipoCF)
				//Se atendeu a regra da ordem prioritária, irá incrementar o número de enquadramento
				aTes[nContTes][nPosATes] ++
				lAlt	:= .T.
			EndIF
		
		Next nContTes
		
		//Somente irá processar se houve alteração em alguma regra 
		If lAlt		
			//Após verificar o campo em todos as regras empatadas, irá então ordenar novamente para ver se
			//ainda resta regras empatadas
			aSort(aTES,,,bSort)
			//Deverá verificar aqui se desempatou
			If !CheckEmpate(aTes,,cTipoCF)
				//Não há mais empate, foi resolvido com o processamento da ordem dos campos e não deverá mais verificar os
				//demais campos da ordem de prioridade
				lRet	:= .T.
				Exit
			Endif
		EndIF	
									
	Next nCont		
Else
	//Não houve empate, não será necessário processar ordem prioritária dos campos
	lRet	:= .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckEmpate
 
Função que irá percorrer o array aTes, verifica se existe regras com o 
mesmo número de campos enquadrados, ou seja, estão empatados.
  
@param  	aTes      - Array com informações dos Tes enquadrados
			nQtde     - Quantidade de Tes empatadas
			cTipoCF   -Indca operação com Cliente 'C' ou fornecedor 'F'
@return	(nQtde>1)  - Retornar booleano, indicando que existem Tes empatadas			
@author Erick G. Dias
@since 12/05/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function CheckEmpate(aTes,nQuantidad,cTipoCF)
Local nContEmp		:= 0
Local nQtdeEnq	:= 0
Local nPosATes	:= Iif(cTipoCF == 'C',14,13)
Default nQuantidad		:= 0

//Verifica se existem regras empatadas
For nContEmp	:= 1 to Len(aTes)	
	If  aTes[nContEmp][nPosATes] >= nQtdeEnq
		nQtdeEnq	:= aTes[nContEmp][nPosATes]
		nQuantidad++
	Else
		Exit
	EndIF
	
Next nContEmp

Return (nQuantidad>1)


//-------------------------------------------------------------------
/*/{Protheus.doc} ChkOrdSFM
 
Função que faz a verificação se determinado campo do aTes está preenhido.
Esta função é utilizada para processar ´critério de desempate,
verificando campo por campo se está prenhido, considerando ordem de 
prioridade dos campos da SFM, seja ordem padrão ou ordem definida pelo Cliente
  
@param  	aTes      - Array com informações dos Tes enquadrados
			nOrdem    - Número que corresponde ao campo da tabela SFM
			cTipoCF   -Indca operação com Cliente 'C' ou fornecedor 'F'

@return	lRet 	   - Retornar booleano, indicando que campo em questão está preenchido no aTes			
@author Erick G. Dias
@since 12/05/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function ChkOrdSFM(aTes,nOrdem,cTipoCF)

Local lRet	:= .F.

If cTipoCF == 'C'
	//CLIENTE
	//1==FM_PRODUTO				 	== aTes 01
	//2==FM_GRPROD  					== aTes 02
	//3==FM_POSIPI 					== aTes 03
	//4==FM_CLIENTE+FM_LOJACLI		== aTes4 + aTes5  
	//5==FM_GRTRIB 				 	== aTes6
	//6==FM_EST 					 	== aTes7
	//7==FM_REFGRD 			     	== aTes10
	//8==FM_GRPTI                  == aTes11
	//9==FM_TIPOCLI                == aTes 12
	//10==FM_GRPCST                == aTes 13	
	//11==FM_TIPOMOV				   ==aTes 15
	//12==FM_ORIGEM                == aTes 18
	
	Do Case
		Case nOrdem == 1	
			lRet	:= !Empty(aTes[1]) //FM_PRODUTO 				
		Case nOrdem == 2
			lRet	:= !Empty(aTes[2]) //FM_GRPROD				
		Case nOrdem == 3
			lRet	:= !Empty(aTes[3]) //FM_POSIPI								
		Case nOrdem == 4
			lRet	:= !Empty(aTes[4]+aTes[5]) //FM_CLIENTE+FM_LOJACLI
		Case nOrdem == 5
			lRet	:= !Empty(aTes[6]) //FM_GRTRIB			
		Case nOrdem == 6
			lRet	:= !Empty(aTes[7])//FM_EST				
		Case nOrdem == 7
			lRet	:= !Empty(aTes[10])//FM_REFGRD				
		Case nOrdem == 8
			lRet	:= !Empty(aTes[11])//FM_GRPTI				
		Case nOrdem == 9
			lRet	:= !Empty(aTes[12])//FM_TIPOCLI
		Case nOrdem == 10
			lRet	:= !Empty(aTes[13])//FM_GRPCST
		Case nOrdem == 11
			lRet	:= !Empty(aTes[15])//FM_TIPOMOV						
		Case nOrdem == 12 
			lRet	:= !Empty(aTes[18])//FM_ORIGEM 				
	EndCase
Else	
	//FORNECEDOR
	//1==FM_PRODUTO 			  	  	== aTes 01
	//2==FM_GRPROD  			   		== aTes 02
	//3==FM_POSIPI  			  	    == aTes 03
	//4==FM_FORNECE+FM_LOJAFOR  	== aTes 4 + aTes 5  
	//5==FM_GRTRIB 			   		== aTes 6
	//6==FM_EST                   	== aTes 7
	//7==FM_REFGRD              	== aTes 10
	//8==FM_GRPTI               	== aTes 11
	//9==FM_GRPCST              	== aTes 12
	//10==FM_ORIGEM                 == aTes 16
		
	Do Case
		Case nOrdem == 1	
			lRet	:= !Empty(aTes[1]) //FM_PRODUTO				
		Case nOrdem == 2
			lRet	:= !Empty(aTes[2]) //FM_GRPROD				
		Case nOrdem == 3
			lRet	:= !Empty(aTes[3]) //FM_POSIPI								
		Case nOrdem == 4
			lRet	:= !Empty(aTes[4]+aTes[5]) //FM_FORNECE+FM_LOJAFOR				
		Case nOrdem == 5
			lRet	:= !Empty(aTes[6]) //FM_GRTRIB				
		Case nOrdem == 6
			lRet	:= !Empty(aTes[7]) //FM_EST				
		Case nOrdem == 7
			lRet	:= !Empty(aTes[10]) //FM_REFGRD				
		Case nOrdem == 8
			lRet	:= !Empty(aTes[11]) //FM_GRPTI				
		Case nOrdem == 9
			lRet	:= !Empty(aTes[12]) //FM_GRPCST		
		Case nOrdem == 10 
			lRet	:= !Empty(aTes[16]) //FM_ORIGEM
	EndCase
EndIF

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CopySFM

@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@param cAliasQry, Caracter, Alias da Query executada na SFM, com TES selecionados para realizar a cópia
@description Função que irá realizar a cópia da SFM para demais filiais 

/*/
//----------------------------------------------------------------------------------------------------
Static Function CopySFM(cAliasQry,lMark)
Local aDados	:= {}
Local aEstrut	:= SFM->(dbStruct()) //Monta estrutura da SFM
Local aAreaSM0  := SM0->(GetArea())
Local aSm0		:= {}
Local cTabela	:= 'SFM'
Local cFilCad	:= cFilAnt
Local cEmpCad	:= cEmpAnt
Local nCont		:= 0
Local cMensagem	:= ''
Local lProc		:= .T.
Local nHandle	:= CriaTxtLog()

Default lMark := .F.

If lMark	
	aSm0 	:= MatFilCalc( .T.,,,,,,.T. ) //Seleciona Filial
	IndRegua (cAliasQry,cAliasQry,"FM_TIPO",,"MARK=='X'")	// Filtra somente registros marcados
Else	
	aSm0 	:= MatFilCalc( .F.,,,,,,.T. )
Endif

//Inicia transação
Begin Transaction

//Laço nas filiais da empresa logada
For nCont := 1 to Len(aSm0)

	If lMark
		//Processa somente Filiais Marcadas
		lProc := aSm0[nCont][1]
	Else
		//Processa Todas Filiais
		lProc := .T.
	Endif

	
	If lProc
		SM0->(DbGoTop ())
		SM0->(MsSeek (cEmpCad+aSm0[nCont][2],.T.))	//Pego a filial mais proxima
		cFilAnt := FWGETCODFILIAL
		
		IF cFilAnt <> cFilCad
			//Laço de TES que serão copiados para as filiais
			(cAliasQry)->(DbGoTop ())
			Do While !(cAliasQry)->(Eof ())
				
				//Verifica se o TES já existe na filial de destino, somente irá incluir se não existir
				IF ! ChkSFM(cAliasQry)	
					//Função que realizar cópia para filial de destino
					GrvTab(aEstrut, cAliasQry, cTabela, nHandle,lMark )
				Else
					//TODO Deverá gravar log indicando o código do TES + Descrição + Filial de destino que não foi possível realizar a cópia
				EndiF
						
				(cAliasQry)->(dbSkip())
				Loop
			EndDo
		EndIF
	EndIF
	
Next nCont

//Fecha alias e restaura filial logada
//Fecha alias e restaura filial logada
IF lMark
	//Limpa Objeto e Arquivo Temporario
	If !Empty(cAliasQry)    
		Ferase(cAliasQry+GetDBExtension())
		Ferase(cAliasQry+OrdBagExt())
		cAliasQry := ""
	Endif	
Else
	(cAliasQry)->(DbCloseArea ())
Endif

RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL

If (nHandle>=0)
	FClose (nHandle)
Endif

//Fecha transação 		
End Transaction

Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GrvTab
 
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@param aEstrut, Array, Estrutura da tabela que será copiada
@param cAliasQry, Caracter, Alias da Query executada da tabela que será copiada
@param cTabela, Caracter, Nome da tabela que será copiada
@description Função que irá realizar a cópia da SFM para demais filiais 

/*/
//----------------------------------------------------------------------------------------------------
Static Function GrvTab(aEstrut, cAliasQry, cTabela, nHandle,lMark )

Local nCont		:= 0
Local cLinha	:= ''

//Inclui nova linha na tabela
RecLock(cTabela,.T.)

//Gravação do campo _FILIAL será sempre com retorno do xFilial()
&(cTabela + "->" + Iif(Substr(cTabela,1,1) == 'S', Substr(cTabela,2,2) ,cTabela )   + "_FILIAL" ) := xFilial(cTabela)

//Laço nos campos da tabela estrutura do SX3
For nCont := 1 to Len(aEstrut)

	//Ignora campo de Marcação
	If lMark .And. aEstrut[nCont][1] =='MARK'
		Loop
	Endif
	
	If aEstrut[nCont][2] <> 'M'
		//Campo Filial não será copiado, já foi gravado anteriormente com conteúdo do xFilial
		If ! "FILIAL"  $ aEstrut[nCont][1]
			//Para campo tipo Date preciso utilizar a função TcSetField para que não ocorra erro de Type Mismatch
			If aEstrut[nCont][2] == 'D'
				&(cTabela + "->" +aEstrut[nCont][1] ) := StoD((cAliasQry)->&(aEstrut[nCont][1]))
			Else
				If aEstrut[nCont][2] == 'L'
					If (cAliasQry)->&(aEstrut[nCont][1]) == "T"
						&(cTabela + "->" +aEstrut[nCont][1] ) := .T.
					Else
						&(cTabela + "->" +aEstrut[nCont][1] ) := .F.
					EndIf	
				Else
					&(cTabela + "->" +aEstrut[nCont][1] ) := (cAliasQry)->&(aEstrut[nCont][1])	
				EndIf
			EndIF
		EndIf
	EndIf

	
Next nCont

MsUnLock()

cLinha	:= 'TES Inteligente replicada para Grupo de Empresa: ' + FWGrpCompany()
cLinha += Iif(FWModeAccess("SFM",1) == 'C' .OR. Empty(Alltrim(FWCompany())),''    , ', Empresa: ' + FWCompany()  )
cLinha += Iif(FWModeAccess("SFM",2) == 'C' .OR. Empty(Alltrim(FWUnitBusiness())),''  , ', Unidade de Negócio: ' + FWUnitBusiness()  )
cLinha += Iif(FWModeAccess("SFM",3) == 'C' .OR. Empty(Alltrim(FWFilial())),''  , ' e Filial ' + FWFilial()  )   
cLinha	+=' : Tipo de Operação = '					+ (cAliasQry)->FM_TIPO   
cLinha	+=', Produto = ' 							+ (cAliasQry)->FM_PRODUTO  
cLinha	+=', Cliente/Loja = ' 						+ (cAliasQry)->FM_CLIENTE+'/'+(cAliasQry)->FM_LOJACLI
cLinha	+=', Fornecedor/Loja = ' 					+ (cAliasQry)->FM_FORNECE+'/'+(cAliasQry)->FM_LOJAFOR
cLinha	+=', Estado = ' 							+ (cAliasQry)->FM_EST 
cLinha	+=', Grupo de Tributação = ' 				+ (cAliasQry)->FM_GRTRIB
cLinha	+=', Grupo de Produto = ' 					+ (cAliasQry)->FM_GRPROD 
cLinha	+=', NCM = ' 								+ (cAliasQry)->FM_POSIPI 
cLinha	+=', TES de Entrada = ' 					+ (cAliasQry)->FM_TE
cLinha	+=', TES de Saída = ' 						+ (cAliasQry)->FM_TS
cLinha	+=', Grupo de TES Inteligente = '			+ (cAliasQry)->FM_GRPTI
cLinha	+=', Tipo de Cliente = ' 					+ (cAliasQry)->FM_TIPOCLI + ' ' 
cLinha	+= Chr (13)+Chr (10)

FWrite (nHandle, cLinha, Len (cLinha))

Return


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QrySFM
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@param cCodSFM, Caracter, Estrutura da tabela que será copiada
@return	cAliasSFM, Caracter, Query realizada na SFM
@description Função que faz seleção do código de TES Inteligente que deverá ser copiado 

/*/
//----------------------------------------------------------------------------------------------------
Static Function QrySFM(nRecnoSFM)

Local cAliasSFM	:= "SFM"
Local cSlctSFM	:= ''

cSlctSFM :='%'
cSlctSFM += 'SFM.* ' //Preciso trazer todos os campos da SFM, por este motivo utilizo asterísco.
cSlctSFM +='%'
   	
cAliasSFM	:=	GetNextAlias()

BeginSql Alias cAliasSFM	
	SELECT			    
		%Exp:cSlctSFM%
	FROM 
		%Table:SFM% SFM
	WHERE
		SFM.FM_FILIAL=%xFilial:SFM% AND
		SFM.R_E_C_N_O_= %Exp:nRecnoSFM% and
		SFM.%NotDel%	
EndSql
Return cAliasSFM

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkSFM
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Função que verifica se regra de tes inteligente já existe 

/*/
//----------------------------------------------------------------------------------------------------
Static Function ChkSFM(cAliasSFM2)

Local cAliasSFM	:= "SFM"
Local cSlctSFM	:= ''
Local lExiste	:= .F.

cSlctSFM :='%'
cSlctSFM += 'SFM.FM_TIPO ' //Preciso trazer todos os campos da SFM, por este motivo utilizo asterísco.
cSlctSFM +='%'
   	
cAliasSFM	:=	GetNextAlias()
  	
BeginSql Alias cAliasSFM	
	SELECT			    
		%Exp:cSlctSFM%
	FROM 
		%Table:SFM% SFM
	WHERE
		SFM.FM_FILIAL		=%xFilial:SFM% AND		
		SFM.FM_TIPO 		= %Exp:(cAliasSFM2)->FM_TIPO% 		AND
		SFM.FM_PRODUTO 		= %Exp:(cAliasSFM2)->FM_PRODUTO%	AND 
		SFM.FM_CLIENTE 		= %Exp:(cAliasSFM2)->FM_CLIENTE% 	AND
		SFM.FM_LOJACLI 		= %Exp:(cAliasSFM2)->FM_LOJACLI% 	AND
		SFM.FM_FORNECE 		= %Exp:(cAliasSFM2)->FM_FORNECE% 	AND
		SFM.FM_LOJAFOR 		= %Exp:(cAliasSFM2)->FM_LOJAFOR% 	AND
		SFM.FM_EST 			= %Exp:(cAliasSFM2)->FM_EST% 		AND
		SFM.FM_GRTRIB 		= %Exp:(cAliasSFM2)->FM_GRTRIB% 	AND
		SFM.FM_GRPROD 		= %Exp:(cAliasSFM2)->FM_GRPROD% 	AND
		SFM.FM_POSIPI 		= %Exp:(cAliasSFM2)->FM_POSIPI% 	AND
		SFM.FM_TE 			= %Exp:(cAliasSFM2)->FM_TE% 		AND
		SFM.FM_TS 			= %Exp:(cAliasSFM2)->FM_TS% 		AND		 
		SFM.FM_GRPTI 		= %Exp:(cAliasSFM2)->FM_GRPTI% 		AND
 		SFM.FM_TIPOCLI 		= %Exp:(cAliasSFM2)->FM_TIPOCLI% 	AND		
		SFM.%NotDel%	
EndSql


(cAliasSFM)->(DbGoTop ())
Do While !(cAliasSFM)->(Eof ())
	
	//Se entrou nesta linha significa que já existe esta regra cadastrada em outra filial
	lExiste	:= .T.	
	exit
	(cAliasSFM)->(dbSkip())
	Loop
EndDo

(cAliasSFM)->(DbCloseArea ())

Return lExiste

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldReplica
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Função que faz validação se regra de tes inteligente já existe em alguma filial 

/*/
//----------------------------------------------------------------------------------------------------
Static Function VldReplica()

Local aAreaSM0  := SM0->(GetArea())
Local aSm0		:= MatFilCalc( .F.,,,,,,.T. )
Local nCont		:= 0
Local cMsg		:= ''
Local cEmpCad	:= cEmpAnt
Local cFilCad	:= cFilAnt

For nCont := 1 to Len(aSm0)

	SM0->(DbGoTop ())
	SM0->(MsSeek (cEmpCad+aSm0[nCont][2], .T.))	//Pego a filial mais proxima
	cFilAnt := FWGETCODFILIAL	
	
	//A filial logada é desconsiderada
	IF cFilAnt <> cFilCad
				
		//Verifica se o TES Inteligente já existe na filial de destino, somente irá incluir se não existir
		IF PreChkSFM()	
			cMsg	+= 'TES Inteligente já existe na filial: ' + cFilAnt 	+ chr(13)+chr(10)
		EndiF
		
	EndIF

Next nCont

RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL

Return cMsg


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PreChkSFM
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Função que verifica se regra de tes inteligente já existe, considernado os campos digitados pelo 
	         usuário.		  

/*/
//----------------------------------------------------------------------------------------------------
Static Function PreChkSFM()

Local cAliasSFM	:= "SFM"
Local cSlctSFM	:= ''
Local lExiste	:= .F.

cSlctSFM :='%'
cSlctSFM += 'SFM.FM_TIPO ' //Preciso trazer todos os campos da SFM, por este motivo utilizo asterísco.
cSlctSFM +='%'
   	
cAliasSFM	:=	GetNextAlias()
  	
BeginSql Alias cAliasSFM	
	SELECT			    
		%Exp:cSlctSFM%
	FROM 
		%Table:SFM% SFM
	WHERE
		SFM.FM_FILIAL		=%xFilial:SFM% AND		
		SFM.FM_TIPO 		= %Exp:M->FM_TIPO% 		AND
		SFM.FM_PRODUTO 		= %Exp:M->FM_PRODUTO%	AND 
		SFM.FM_CLIENTE 		= %Exp:M->FM_CLIENTE% 	AND
		SFM.FM_LOJACLI 		= %Exp:M->FM_LOJACLI% 	AND
		SFM.FM_FORNECE 		= %Exp:M->FM_FORNECE% 	AND
		SFM.FM_LOJAFOR 		= %Exp:M->FM_LOJAFOR% 	AND
		SFM.FM_EST 			= %Exp:M->FM_EST% 		AND
		SFM.FM_GRTRIB 		= %Exp:M->FM_GRTRIB% 	AND
		SFM.FM_GRPROD 		= %Exp:M->FM_GRPROD% 	AND
		SFM.FM_POSIPI 		= %Exp:M->FM_POSIPI% 	AND
		SFM.FM_TE 			= %Exp:M->FM_TE% 		AND
		SFM.FM_TS 			= %Exp:M->FM_TS% 		AND		 
		SFM.FM_GRPTI 		= %Exp:M->FM_GRPTI% 	AND
 		SFM.FM_TIPOCLI 		= %Exp:M->FM_TIPOCLI% 	AND		
		SFM.%NotDel%	
EndSql

(cAliasSFM)->(DbGoTop ())
Do While !(cAliasSFM)->(Eof ())
	
	//Se entrou nesta linha significa que já existe esta regra cadastrada em outra filial
	lExiste	:= .T.	
	exit
	(cAliasSFM)->(dbSkip())
	Loop
EndDo

(cAliasSFM)->(DbCloseArea ())

Return lExiste

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTxtLog
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Função responsável por criar diretório e arquivo de log.	  

/*/
//----------------------------------------------------------------------------------------------------
Static Function CriaTxtLog()

Local cDiretorio	:=  GetSrvProfString("Startpath","") + 'FISCOPY'

IF ! ExistDir( cDiretorio ) 
	MakeDir( cDiretorio )
EndIf

Return FCREATE(cDiretorio + '\FISCOPY_SFM_' + StrTran(DtoC(dDataBase), "/","")+'_'+ StrTran(Time(), ":","" )+'.TXT', 0)


//-------------------------------------------------------------------
/*/{Protheus.doc} ChkIdSFM
 
Função que irá verificar se o campo FM_ID já existe, se existir irá popular
a base legado preenchendo este campo.
			
@author Erick G. Dias
@since 04/09/2017
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function ChkIdSFM(nQtde)

Local cChave	:= ''
Local lAtuSx5	:= .F.
Local cAliasSFM	:= ''
Local nCont		:= 0

If SFM->(FieldPos("FM_ID")) > 0 .AND. SX5->( dbSeek(xFilial('SX5')+"RV"+'SFM'))
	//Verifica se existe algum ID preenchido
	cChave	:= Substr(X5Descri(),1,6)
	
	ProcRegua (nQtde/10000)
	
	//Chama query para trazer as linhas com FM_ID com conteúdo vazio
	cAliasSFM	:= QrySFMID(.F.)
	DbSelectArea (cAliasSFM)
	(cAliasSFM)->(DbGoTop ())
		
	Do While !(cAliasSFM)->(Eof ())
		
		IF mod(nCont,10000) == 0
			IncProc('Atualizando Regra: ' + Alltrim(str(nCont)) + ' de : ' + Alltrim(str(nQtde)))
		EndiF
		
		//Aqui significa que existe linha na SFM com ID em branco que precisa ser alterado
		SFM->(dbGoto( (cAliasSFM)->RECNO  ))
		
		cChave	:= Soma1(cChave,6)	
		
		RecLock("SFM",.F.)
		SFM->FM_ID		:= cChave
		SFM->FM_DESCR	:= 'Regra de TES Inteligente ' + cChave
		MsUnlock()			
		lAtuSx5	:= .T.
		nCont++
		(cAliasSFM)->(DbSkip ())			
	EndDo

	DbSelectArea( cAliasSFM )
	( cAliasSFM )->( dbCloseArea () )
	
	
	If lAtuSx5 .AND. SX5->(dbSeek(xFilial("SX5")+"RV"+'SFM'))
		FwPutSX5(,"RV","SFM",cChave, cChave, cChave)
	EndIF	
	
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QrySFMID
 
Função que realiza a query na SFM em busca de linhas com o campo FM_ID
com conteúdo vazio 
			
@author Erick G. Dias
@since 11/09/2017
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function QrySFMID(lCount)

Local cSlctSFM		:= ''

IF lCount
	cSlctSFM :='%'
	cSlctSFM += 'Count(R_E_C_N_O_)  as QTDE'	
	cSlctSFM +='%'
Else
	cSlctSFM :='%'
	cSlctSFM += 'R_E_C_N_O_  as RECNO'	
	cSlctSFM +='%'
EndIF
  	
cAliasSFM	:=	GetNextAlias()
   	
BeginSql Alias cAliasSFM		
	SELECT			    
		%Exp:cSlctSFM%
	FROM 
		%Table:SFM% SFM
	WHERE
		SFM.FM_FILIAL = %xFilial:SFM% AND
		SFM.FM_ID = ' ' AND			  
		SFM.%NotDel%	
EndSql

Return cAliasSFM

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcFMID
 
Função que retorna a quantidade de linhas na SFM com o campo FM_ID vazio
			
@author Erick G. Dias
@since 11/09/2017
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function ProcFMID()

Local nQtde		:= 0
Local cAliasSFM	:= ''

If SFM->(FieldPos("FM_ID")) > 0 .AND. SX5->( dbSeek(xFilial('SX5')+"RV"+'SFM'))

	dbSelectArea("SFM")
	SFM->(dbSetOrder(3))
	
	cAliasSFM	:= QrySFMID(.T.)
	
	DbSelectArea (cAliasSFM)
	(cAliasSFM)->(DbGoTop ())
	
	If !(cAliasSFM)->(Eof ())
		nQtde	:= (cAliasSFM)->QTDE	
	EndIF
	
	DbSelectArea( cAliasSFM )
	( cAliasSFM )->( dbCloseArea () )
EndIF

Return nQtde  
                                
//-------------------------------------------------------------------
/*/{Protheus.doc} MTA089ID
 
Função que irá retornar o próximo ID da regra de TES Inteligente
			
@author Erick G. Dias
@since 11/09/2017
@version 11.80

/*/
//-------------------------------------------------------------------
Function MTA089ID()

Local cRet	:= ''

If  SX5->( dbSeek(xFilial('SX5')+"RV"+'SFM'))

	cRet	:= Soma1(Substr(X5Descri(),1,6),6)
EndIF

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} COPYTESINT
função para Marcar TES INteligente e copiar para diversas Filiais

@author Rafael dos Santos
@since 20.12.2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function COPYTESINT()

Local aColumns		:= {}
Local nX			:= 0 
Local cAliasFM		:= GetNextAlias()
Local oDialogMK	 	:= Nil
Local oMrkBrowse 	:= Nil
Local cAliasTemp	:= GetNextAlias()
Local cSlctSFM		:= "% "
Local lMarcar  		:= .F.
Local aStructTrb 	:= SFM->(DbStruct())
Local aCampoGrid 	:= fCamposSFM() 
Local cIndice1		:= ""
Local aFiltro		:= {}
Local aRetCopy   	:= If(Type("aRotina")=="A",ACLONE(aRotina),{})
Local oTmpTable		:= Nil

//Define Menu
aRotina := {}

For nX:=1 To Len(aStructTrb)  //Colunas que serão exibidas no browse
    If !aStructTrb[nX][1]=="MARK" .And. Ascan(aCampoGrid,aStructTrb[nX][1])>0
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||"+aStructTrb[nX][1]+"}") )
        aColumns[Len(aColumns)]:SetTitle(RetTitle(aStructTrb[nX][1])) 
        aColumns[Len(aColumns)]:SetSize(aStructTrb[nX][3]) 
        aColumns[Len(aColumns)]:SetDecimal(aStructTrb[nX][4])
        aColumns[Len(aColumns)]:SetPicture(PesqPict("SFM",aStructTrb[nX][1]))		
		
		aAdd(aFiltro	,{aStructTrb[nX][1];
			,aStructTrb[nX][1];
			,aStructTrb[nX][2];
			,aStructTrb[nX][3];
			,aStructTrb[nX][4];
			,PesqPict("SFM",aStructTrb[nX][1])})
    EndIf
	//Query SFM
	cSlctSFM += aStructTrb[nX,1]+", "	
	
Next nX

//Query SFM
cSlctSFM += " SFM.*,' ' AS MARK "
cSlctSFM +='%'

BeginSql Alias cAliasFM		
	SELECT
		%Exp:cSlctSFM%
	FROM 
		%Table:SFM% SFM
	WHERE
		SFM.FM_FILIAL=%xFilial:SFM% AND
		SFM.%NotDel%
	ORDER BY SFM.FM_TIPO,SFM.FM_PRODUTO,SFM.FM_CLIENTE,SFM.FM_LOJACLI
EndSql

aAdd(aStructTrb, {'MARK', 'C', 1, 0})
oTmpTable := FWTemporaryTable():New(cAliasTemp, aStructTrb)
oTmpTable:AddIndex("IN1", {'FM_TIPO', 'FM_PRODUTO', 'FM_CLIENTE', 'FM_LOJACLI', 'FM_ID'})
oTmpTable:Create()

While !(cAliasFM)->(Eof()) 
	dbSelectArea(cAliasTemp)
	RecLock(cAliasTemp, .T. )
		For nX := 1 To fCount()
			If (cAliasTemp)->(FieldName(nX)) != "MARK"
				(cAliasTemp)->(FieldPut(nX, (cAliasFM)->(FieldGet(nX)))) // Grava todos os campos do SF4 no TRB 
			EndIf	
		Next
	(cAliasTemp)->(MsUnlock())
	(cAliasFM)->(dbSkip())	
EndDO

//Fecha query
If Select(cAliasFM) > 0
    DbSelectArea(cAliasFM)
    DbCloseArea()
EndIf

//Inicia Browse
If !(cAliasTemp)->(Eof())	
	
	oMrkBrowse := FWMarkBrowse():New()	
	oMrkBrowse:SetOwner(oDialogMK)
	oMrkBrowse:SetDescription("Replicar TES Inteligente para outras Filiais")	
	
	oMrkBrowse:SetMenuDef("")
	oMrkBrowse:ForceQuitButton()
	oMrkBrowse:DisableConfig(.F.)
	oMrkBrowse:DisableReport(.F.)
	oMrkBrowse:DisableDetails(.T.)
	oMrkBrowse:SetWalkThru(.F.)

	oMrkBrowse:oBrowse:SetUseFilter(.T.)
	oMrkBrowse:oBrowse:SetDBFFilter() 
	oMrkBrowse:oBrowse:SetFieldFilter(aFiltro)	

	oMrkBrowse:SetAlias(cAliasTemp)	
	oMrkBrowse:SetColumns(aColumns)

	oMrkBrowse:SetFieldMark("MARK")
	oMrkBrowse:SetMark('X', cAliasTemp, "MARK")
	oMrkBrowse:SetAllMark( { || .T. } )
	oMrkBrowse:bAllMark := { || InvertSel(cAliasTemp,oMrkBrowse:Mark(),lMarcar := !lMarcar,.F. ), oMrkBrowse:Refresh(.T.)  }

	oMrkBrowse:AddButton("Copiar", { || FwMsgRun(,{|oSay|CopySFM(cAliasTemp,.T.)},'Processando',"",),Alert("Processo Finalizado"),oMrkBrowse:GetOwner():End()},,2 )
	oMrkBrowse:AddButton("Inverter Seleção", { || InvertSel(cAliasTemp,oMrkBrowse:Mark(),lMarcar := !lMarcar,.T. ),oMrkBrowse:Refresh(.T.)},,2 )	
	oMrkBrowse:AddButton("Cancelar", { || oMrkBrowse:GetOwner():End()},,2 )

	oMrkBrowse:Activate()	
	
Else
	Help(" ",1,"RECNO")
EndIf

//Restaura Menu
aRotina:=AClone(aRetCopy)
oTmpTable:Delete()

Return


/*-------------------------------------------------------------------
{Protheus.doc} InvertSel
Regra para marcação dos registros de notas

@author Rafael S Oliveira
@since 20/12/2017
@version 1.0
-------------------------------------------------------------------*/
Static Function InvertSel(cAlias,cMarca,lMarcar, lInvert)
Local aAreaSFM  := (cAlias)->( GetArea() )

(cAlias)->( dbGoTop() )
While !(cAlias)->( Eof() )
	RecLock( (cAlias), .F. )
	
	If lInvert
		(cAlias)->MARK := IIf( (cAlias)->MARK == cMarca , '  ',cMarca )
	Else
		(cAlias)->MARK := IIf( lMarcar, cMarca, '  ' )
	Endif
	
	MsUnlock()
	(cAlias)->( dbSkip() )
EndDo

RestArea( aAreaSFM )
Return .T.

/*/{Protheus.doc} fCamposSFM
Função para retornar os campos que serão utilizados nas telas.

@author Vitor Ribeiro
@since 28/12/2017

@return array, contém os campos da SFM.
/*/
Static Function fCamposSFM()
	
	Local aArea := GetArea()
	Local aAreaSX3 := SX3->(GetArea()) 
	Local aRetorno := {}
	Local aSX3Fields := {}
	Local lValOp   := GetNewPar("MV_A410OPE",.F.)
	Local cCampoExc:= ""
	Local nCount := 0


	if !lValOp
		cCampoExc+="|FM_ORIGEM"
	endif

	DbSelectArea("SX3")		// Dicionario de campos
	SX3->(DbSetOrder(1))	// X3_ARQUIVO+X3_ORDEM
	
	// Se os campos FM_ID e FM_DESCR existirem, coloca eles em primeiro no array.
	If SFM->(FieldPos("FM_ID")) > 0
		Aadd(aRetorno,"FM_ID")
	EndIf
	
	If SFM->(FieldPos("FM_DESCR")) > 0
		Aadd(aRetorno,"FM_DESCR")
	EndIf
	
	aSX3Fields := FWSX3Util():GetAllFields( "SFM" )

	For nCount := 1 To Len( aSX3Fields )
		If !(AllTrim(aSX3Fields[nCount]) $ "FM_ID|FM_DESCR|FM_CFO_O|FM_CFO_I"+cCampoExc) .And. X3USO(GetSx3Cache(aSX3Fields[nCount],"X3_USADO"))
			Aadd(aRetorno,aSX3Fields[nCount])
		EndIf
	Next
	
	RestArea(aAreaSX3)
	RestArea(aArea)
Return aRetorno


/*-------------------------------------------------------------------
{Protheus.doc} A089Copy
Função de copiar TES selecionado.

@author Rafael S Oliveira
@since 16/03/2018
@version 1.0
-------------------------------------------------------------------*/
Function A089Copy(cAlias,nReg,nOpc)
	
	AxInclui( "SFM",SFM->(Recno()),3,/*<aAcho>*/,"COPIARSFM",/*<aCpos>*/,"A089TudOk()",.F.,/*<cTransact>*/,/*<aButtons>*/,/*<aParam>*/,/*<aAuto>*/,/*<lVirtual>*/,.T.)

Return

//Função para carregamento dos campos em variáveis de memória
Function COPIARSFM()

	Local bCampo 	:= { |nCPO| Field(nCPO) }
	Local nCountCpo	:= 0
	
	DbSelectArea("SFM")
	
	For nCountCpo := 1 TO SFM->(FCount())		
		
		If (AllTrim(FieldName( nCountCpo )) <> "FM_ID")
			//Inputa o valor do campo posicionado, na variável de memória
			M->&(EVAL(bCampo, nCountCpo)) := FieldGet(nCountCpo)		
		Endif		

	Next nCountCpo

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RegraGener
Retorna se a regra de TES Inteligente é uma regra genérica
@author  Yuri F. Palacio
@since   07.05.2021
@version v1.0
/*/
//-------------------------------------------------------------------
Static Function RegraGener( cAliasSFM )
	Local lRet := .F.

	If Empty( (cAliasSFM)->FM_PRODUTO ) .AND.;
		Empty( (cAliasSFM)->FM_REFGRD ) .AND.;
		Empty( (cAliasSFM)->FM_GRPROD ) .AND.;
		Empty( (cAliasSFM)->( FM_CLIENTE + FM_LOJACLI) ) .AND.;
		Empty( (cAliasSFM)->( FM_FORNECE + FM_LOJAFOR) ) .AND.;
		Empty( (cAliasSFM)->FM_GRTRIB ) .AND.;
		Empty( (cAliasSFM)->FM_EST ) .AND.;
		Empty( (cAliasSFM)->FM_TIPOMOV ) .AND.;
		Empty( (cAliasSFM)->FM_POSIPI ) .AND.;
		Empty( (cAliasSFM)->FM_GRPTI ) .AND.;
		Empty( (cAliasSFM)->FM_TIPOCLI ) .AND.;
		Empty( (cAliasSFM)->FM_GRPCST ) .AND.;
		Empty( (cAliasSFM)->FM_ORIGEM )

		lRet := .T.
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RegraGener
Função Estática usada para retornar a Origem do Produto caso o campo nFM_ORIGEM, eseja em uso e esteja diferente de vazio.
@author  r.cavalcante
@since   05.04.22
@version v1.0
/*/
//-------------------------------------------------------------------
Static Function A890Origem()
	Local cOrigem	:= ""
	Local cProduto	:= SB1->B1_COD
	Local nItem		:= n
	Local nPFciCod	:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_FCICOD'})
	Local nPLote 	:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_LOTECTL'})
	Local nPSubLot	:= aScan(aHeader, { |x| AllTrim(Upper(x[2])) == 'C6_NUMLOTE'})
	Local cLote		:= aCols[nItem][nPLote]
	Local cSubLot	:= aCols[nItem][nPSubLot]
	Local cFCICod	:= aCols[nItem][nPFciCod] 
		
	
	If Empty(cFCICod) .AND. Rastro(cProduto) .AND. (!Empty(cLote) .OR. !Empty(cSubLot))
		cOrigem := OrigemLote(cProduto,clote,cSubLot)
	Endif

Return(cOrigem)
