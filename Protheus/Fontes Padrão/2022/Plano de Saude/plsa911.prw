#include "plsa911.ch"
#include "protheus.ch"
#include "plsmger.ch"

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA911 ³ Autor ³ Sandro Hoffman Lopes   ³ Data ³ 16/05/2006 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Atualiza BXS - Regras p/ Composicao Base Calculo Comissão    ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSA911()                                                    ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                            ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSA911()

	Private cCodInt := ""

	Private aRotina   := MenuDef()                    	   
	Private cCadastro := Fundesc()	
	Private cAlias    := "BXS"
		
	DbSelectArea("BXS")

	BXS->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,"BXS",,,,,,,,,,, .T. ))

Return 


Function PLSA911Mov(cAlias, nReg, nOpc)

	Local I__f  := 0
	Local oDlg
	Local oEnc
	Local nOpca := 0
	Local aPosObj   := {}
	Local aObjects  := {}
	Local aSize     := {}
	Local aInfo     := {}

    If (nOpc == K_Alterar .OR. nOpc == K_Excluir) .And. ! Empty(BXS->BXS_VLDFIM)
	   MsgStop("Nao permitido alteracao/exclusao com termino de vigencia preenchido!")
	   Return
	EndIf

	If nOpc == K_Incluir
	   Copy "BXS" TO Memory Blank
	Else
	   Copy "BXS" TO Memory
	EndIf

	aSize := MsAdvSize()
	aObjects := {}       
	AAdd( aObjects, { 1, 1, .T., .T., .F. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd Pixel

	oEnc := MSMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Iif(Obrigatorio(oEnc:aGets,oEnc:aTela),(nOpca := 1,oDlg:End()),NIL)},{|| nOpca := 0,oDlg:End()})

	If nOpca == 1 // confirmou
		If nOpc == K_Incluir
			ConfirmSX8()
		EndIf
		PLUPTENC("BXS",nOpc)
	 Else
		If nOpc == K_Incluir
			RollBackSX8()
		EndIf
	EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS911LF   ³ Autor ³ Sandro Hoffman Lopes  ³ Data ³ 16.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta um "markbrowse" para marcar/desmarcar quais lancamen-  ³±±
±±³          ³ tos de faturamento deverao ser retornados pela funcao.       ³±±
±±³          ³ Exemplo de retorno: "102,104,123,130"                        ³±±
±±³          ³ Parametros:                                                  ³±±
±±³          ³ - cDados:  Inicializador (conteudo anterior do campo)        ³±±
±±³          ³ - cCampo:  Campo que devera ser atualizado                   ³±±
±±³          ³ - nTam:    Tamanho maximo da string que sera retornada       ³±±
±±³          ³            (Se nao passado ou passar zero, considera a       ³±±
±±³          ³             string completa)                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS911LF(cDado,cCampo,nTam,cCond)

	Static objCENFUNLGP := CENFUNLGP():New()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define variaveis...                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local oDlg
	Local nOpca     := 0
	Local bOK       := { || nOpca := K_OK, oDlg:End() }
	Local bCancel   := { || oDlg:End() }
	Local oCritica
	Local cSQL
	Local aCritica  := {}
	Local nInd                     
	Local aPosObj   := {}
	Local aObjects  := {}
	Local aSize     := {}
	Local aInfo     := {}
	Default cCampo  := ""           
	Default nTam    := 0
	Default cCond   := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Coloca virgula no inicio da string (caso tenha inicializador padrao)     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDado := AllTrim(cDado)   
	If  SubStr(cDado, Len(cDado), 1) != "," .And. cDado != ""
		cDado += ","
	EndIf

    BFQ->(DbSetOrder(2))
    BFQ->(DbGoTop())
	While ! BFQ->(Eof())
	    If ! Empty(cCond)
	       If ! &cCond
	          BFQ->(DbSkip())
	          Loop
           EndIf 
        EndIf
	    aAdd(aCritica, { BFQ->BFQ_PROPRI+BFQ->BFQ_CODLAN, BFQ->BFQ_DESCRI, IIf(BFQ->BFQ_PROPRI+BFQ->BFQ_CODLAN $ cDado, .T., .F.) })
		BFQ->(DbSkip())
	Enddo

	aSize := MsAdvSize()
	aSize[7] := Round(aSize[7] * 0.75, 0)
	aSize[6] := Round(aSize[6] * 0.75, 0)
	aSize[5] := Round(aSize[5] * 0.75, 0)
	aSize[4] := Round(aSize[4] * 0.75, 0)
	aSize[3] := Round(aSize[3] * 0.75, 0)
	aObjects := {}       
	AAdd( aObjects, { 1, 10, .T., .F., .T. } )
	AAdd( aObjects, { 1, 1, .T., .T., .T. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE STR0006 FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel // "Lancamentos de Faturamento"

	@ aPosObj[1][1],aPosObj[1][2]+5 SAY oSay PROMPT STR0007 SIZE aPosObj[1][3],aPosObj[1][4] OF oDlg PIXEL COLOR CLR_HBLUE // "Selecione o(s) Lancamento(s)"

	oCritica := TcBrowse():New( aPosObj[2][1], aPosObj[2][2], aPosObj[2][3], aPosObj[2][4],,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
                                            
	oCritica:AddColumn(TcColumn():New(" ",{ || IF(aCritica[oCritica:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
         "@!",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))     

	oCritica:AddColumn(TcColumn():New(STR0008,{ || OemToAnsi(aCritica[oCritica:nAt,1]) },; // "Codigo"
         "@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))     
	
	oCritica:AddColumn(TcColumn():New(STR0009,{ || OemToAnsi(aCritica[oCritica:nAt,2]) },; // "Descricao"
         "@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))     

	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {.F.,"BFQ_PROPRI+BFQ_CODLAN","BFQ_DESCRI"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oCritica:aObfuscatedCols := aBls
	endif	

	oCritica:SetArray(aCritica)         
	oCritica:bLDblClick := { || aCritica[oCritica:nAt,3] := IF(aCritica[oCritica:nAt,3],.F.,.T.) }

	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{}) Center

	If nOpca == K_OK
                  
	   cDado := ""
	   For nInd := 1 To Len(aCritica)
	       If aCritica[nInd,3]
	          cDado += aCritica[nInd,1]+","
	       Endif 
	   Next nInd

	EndIf
                                  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tira a virgula do final da string                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SubStr(cDado, Len(cDado), 1) == ","
		cDado := SubStr(cDado, 1, Len(cDado) - 1)
	EndIf                

    If nTam > 0
		cDado := SubStr(cDado, 1, nTam)
	EndIf

	If ! Empty(cCampo)
		cCampo  := "M->" + cCampo
		&cCampo := cDado 
	EndIf

Return(nOpca==K_OK)
                  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PL911VldLF ³ Autor ³ Sandro Hoffman Lopes  ³ Data ³ 16.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o conteudo de "cConteudo" que foi digitado ou retor-  ³±±
±±³          ³ nado pela funcao "PLSLF". Devera conter os codigos dos lan-  ³±±
±±³          ³ camentos de faturamento separados por virgula e validos.     ³±±
±±³          ³ Ex.: "102,104,123,130"                                       ³±±
±±³          ³ Parametros:                                                  ³±±
±±³          ³ - cCodInt:   Codigo da Operadora                             ³±±
±±³          ³ - cConteudo: Codigos dos Lancamentos de Faturamento          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL911VldLF(cCodInt, cConteudo)

   Local nPos
   Local lRet  := .T.
   
   BFQ->(DbSetOrder(1)) 
   
   Do While !Empty(cConteudo)
      nPos := At(",", cConteudo)
      If nPos == 0
         nPos := Len(cConteudo) + 1
      EndIf
      If ! BFQ->(MsSeek(xFilial("BFQ")+cCodInt+SubStr(cConteudo, 1, nPos - 1)))
         lRet := .F.
         Exit
       Else
         cConteudo := SubStr(cConteudo, nPos + 1)
      EndIf
   EndDo

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PL911AVig  ³ Autor ³ Sandro Hoffman Lopes  ³ Data ³ 16.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua o encerramento da vigencia de uma determinada regra   ³±±
±±³          ³ e, conforme parametro, gera novo registro com base nos da-   ³±±
±±³          ³ dos da regra que esta sendo encerrada.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL911AVig(cAlias,nReg,nOpc)

	Local nOpca   := 0
	Local aSays   := {}, aButtons := {}
	Local cPerg   := "PLS903"
	Local dDatAnt 
	Local bAltDat := {||If(Aviso(STR0011 + DtoC(dDatAnt) + STR0012 + DTOC(mv_par01),; //"Data Alterada de "###" para "
 									STR0013, ; //"Confirma a data de encerramento da Vigencia ?"
 									{ STR0014, STR0015}, 2 )==1,; //"Sim"###"Nao"
 									 (FechaBatch(),1), 0)}

	If ! Empty(BXS->BXS_VLDFIM)
	   	MsgStop(STR0016) //"Registro ja possui termino de validade das regras."
	ElseIf Pergunte(cPerg, .T.)
	   	dDatAnt := mv_par01
	   	If dDatAnt < BXS->BXS_VLDINI //Valida a data de vigência em vigor.
	   		MsgStop(STR0022) //"Data de Vigência em Vigor inválida, a mesma deve ser maior que a data de Validade Inicial."
	   	Else
			aAdd(aSays, STR0017) //"Encerramento da Vigencia das Regras para Composicao da Base de Calculo"
			aAdd(aSays, STR0018) //"das Comissoes"
			aAdd(aSays, STR0019 + DtoC(mv_par01)) //"Vigorar Ate: "
			aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )    
			aAdd(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(),;
								 If( dDatAnt==mv_par01, FechaBatch(), nOpca:=Eval(bAltDat)),;
								 nOpca:=0 ) }} )
			aAdd(aButtons, { 2,.T.,{|| FechaBatch() }} )
	
			FormBatch( cCadastro, aSays, aButtons,, 160 )
	
			If nOpca == 1
				Processa( { || PL911VigReg(cAlias,nReg,nOpc)},,STR0020) //"Processando...."
			EndIf
		EndIf
	
	EndIf	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PL911VigReg³ Autor ³ Sandro Hoffman Lopes  ³ Data ³ 16.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Altera o vencimento da vigencia de uma determinada regra     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PL911VigReg(cAlias,nReg,nOpc)

	Local nRecBXS
	Local cChave
	Local aDatasVig
	Local dNewVigIni
	Local nX
	Local aDadosBXS := {}
	Local nNewRec   := 0

	nRecBXS := BXS->(Recno())
	cChave  := BXS->(BXS_FILIAL+BXS_CODINT+BXS_CODEQU+BXS_GRUCOM+BXS_CODPRO+BXS_ID_VEN+BXS_CODVEN)
   
	aDatasVig := {}
	BXS->(DbSetOrder(1))
	BXS->(MsSeek(xFilial("BXS")+cChave))

	Do While ! BXS->(Eof()) .And. ;
	            BXS->(BXS_FILIAL+BXS_CODINT+BXS_CODEQU+BXS_GRUCOM+BXS_CODPRO+BXS_ID_VEN+BXS_CODVEN) == cChave
	   If BXS->(Recno()) <> nRecBXS
			aAdd(aDatasVig, { BXS->BXS_VLDINI, BXS->BXS_VLDFIM })
	   Else
		   	aAdd(aDatasVig, { BXS->BXS_VLDINI, mv_par01 })
	   EndIf	
	   BXS->(dbSkip())
	EndDo
   				
	BXS->(DbGoto(nRecBXS))
	dNewVigIni := mv_par01+1
   
	If AvFaixaData(dNewVigIni, CtoD(Space(8)), aDatasVig)
	
		For nX := 1 To BXS->(FCount())
	   		aAdd(aDadosBXS, { BXS->(FieldName(nX)), BXS->(FieldGet(nX)) })
		Next nX
	                         
		If mv_par02 == 1
		    //Copia das regras de comissoes por equipe
    		A911Copia(aDadosBXS, dNewVigIni, @nNewRec)
	    EndIf
		//Colocar validade final nos registros encontrados
		A911VldFim(nRecBXS, mv_par01, "BXS_VLDFIM", "BXS")
	
		If mv_par03 == 1  .And. nNewRec > 0 //Editar a Copia
		   dbSelectArea("BXS")
		   dbGoto(nNewRec)
		   PLSA911Mov("BXS", BXS->(Recno()), K_Alterar)
		EndIf
	   
	Else

	 	MsgStop(STR0021) //"Vigencia nao Efetuada - Verifique a data informada!"
   
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A911Copia  ³ Autor ³ Sandro Hoffman Lopes  ³ Data ³ 16.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Copia a regra atual para um novo registro                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A911Copia(aDadosBXS, dNewVig, nNewRec) 

	Local nX
	
	RecLock("BXS", .T.)
	nNewRec := BXS->(Recno())
	For nX := 1 To BXS->(FCount())
		If aDadosBXS[nX][1] == "BXS_VLDINI"
			BXS->(FieldPut(nX, dNewVig))
		ElseIf aDadosBXS[nX][1] == "BXS_VLDFIM"
			BXS->(FieldPut(nX, CtoD(Space(8))))
		ElseIf aDadosBXS[nX][1] == "BXS_SEQ"
			BXS->(FieldPut(nX, GetSX8Num("BXS","BXS_SEQ")))
			ConfirmSX8()
		Else
			BXS->(FieldPut(nX, aDadosBXS[nX][2]))
		EndIf	
	Next
	BXS->(MsUnLock())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A911VldFim ³ Autor ³ Sandro Hoffman Lopes  ³ Data ³ 16.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava no registro a data de encerramento da vigencia         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A911VldFim(nRecNo, uValor, cCampo, cAlias)

	Local nPosCpo
	Local cAliasAnt := Alias()

	dbSelectArea(cAlias)
	nPosCpo := FieldPos(cCampo)

	If nPosCpo > 0 .And. nRecNo > 0
		   dbGoto(nRecNo)
		   RecLock(cAlias, .F.)
		   FieldPut(nPosCpo, uValor)
		   MsUnLock()
	EndIf
	dbSelectArea(cAliasAnt)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³08/01/2007³±±
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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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
Private aRotina := {	{ STR0001, 'AxPesqui'  , 0, K_Pesquisar  , 0, .F.} ,; // "Pesquisar"
						{ STR0002, 'PLSA911MOV', 0, K_Visualizar , 0, Nil} ,; // "Visualizar"
						{ STR0003, 'PLSA911MOV', 0, K_Incluir    , 0, Nil} ,; // "Incluir"
						{ STR0004, 'PLSA911MOV', 0, K_Alterar    , 0, Nil} ,; // "Alterar"
						{ STR0005, 'PLSA911MOV', 0, K_Excluir    , 0, Nil} ,; // "Excluir"
						{ STR0010, 'PL911AVIG' , 0, K_Alterar    , 0, Nil} }  // "Vigencia"
Return(aRotina)
