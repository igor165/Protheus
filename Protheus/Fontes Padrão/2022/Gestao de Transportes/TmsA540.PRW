#INCLUDE "TMSA540.ch"
#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

Static lTM540FIL   := ExistBlock("TM540FIL") // Ponto de Entrada executado na Opcao de Encerrar Pendencia para Validar Filial da Pendencia
Static aSX3DUU     := {}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA540  ³ Autor ³ Alex Egydio           ³ Data ³09.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Registro de Pendencias                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA540()
//-- Define variaveis
Local aCores		:= {}
Local aSetKey     := {}
Local lNFEntr 		  := DTC->(FieldPos("DTC_NFENTR")) > 0	
Private cCadastro	:= STR0001 //'Registro de Pendencias'

Private aRotina	:= MenuDef()
								
Aadd(aCores,{"DUU_STATUS=='1'",'BR_VERDE'		})		// Em Aberto
Aadd(aCores,{"DUU_STATUS=='2'",'BR_AMARELO'	})		// Indenização Solicitada
Aadd(aCores,{"DUU_STATUS=='3'",'BR_VERMELHO'	})		// Indenizada 
Aadd(aCores,{"DUU_STATUS=='4'",'BR_AZUL'		})		// Encerrada

If lNFEntr
	Aadd(aSetKey, { VK_F12 , { || Pergunte("TMA540",.T.) } } )   
	TmsKeyOn(aSetKey)
EndIf
//-- Endereca a funcao de BROWSE
mBrowse( 6,1,22,75,'DUU',,,,,,aCores )
//-- Devolve os indices padroes do SIGA
RetIndex('DUU')
If lNfEntr
	TmsKeyOff(aSetKey)
EndIf

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA540Mnt³ Autor ³ Alex Egydio           ³ Data ³09.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao de registro de pendencias                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA540Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA540Mnt( cAlias, nReg, nOpcx )

Local aAreaAnt	    := GetArea()
//-- Controle de dimensoes de objetos
Local aSize		    := {}
Local aObjects	    := {}
Local aInfo		    := {}
Local aPosObj	    := {}
//-- MSDialog
Local oDlgEsp
//-- EnchoiceBar
Local nOpca		    := 0
//-- Enchoice
Local nOpcxMnt     := nOpcx
Local aVisual	    := {}
Local aButtons     := {}
Local bSavKeyF4    := SetKey(VK_F4,Nil)
Local bSavKeyF5    := SetKey(VK_F5,Nil)
Local aNoFields    := {}

Local lRet       := .T.
Local lRetPE     := .F.
Local lTm540Vld  := ExistBlock('TM540VLD')
Local lTm540BUT  := ExistBlock('TM540BUT')
Local aButTmp    := {}
Local nCntFor    := 0
Local cAliasQry  := ""
Local cQuery     := ""
Local cFilPnd    := ""
Local cNumPnd    := ""
Local nContDUU   := 0
Local lDocRee	 := SuperGetMV('MV_DOCREE',,.F.) .And. TMSChkVer('11','R7')
Local lReent	 := .F.

//-- Enchoice
Private aAltera	 := {}
Private aMemos	    := {}
//-- Variaveis criadas para utilizar as funcoes do Registro de Ocorrencias
Private aCols  	 := {}                         
Private aHeader    := {}
Private aNFAvaria  := {}
Private aHeaderDV4 := {}
Private n          := 1
Private aTela[0][0]
Private aGets[0]
Private oEnch           
Private aIdProduto := {}
Private aHeaderDYM := {}

If IsInCallStack("TMSA510")
	Private cCadastro	:= STR0001 //'Registro de Pendencias'
EndIf

If Type("aRotina") == "U"
	Private aRotina	:= MenuDef()
EndIf
                                       
nOpcx := aRotina[nOpcx][4]
If IsInCallStack ("TMSA500PEN")
	nOpcx := aRotina[2][4]
EndIf

Aadd( aMemos, { 'DUU_CODMTV', 'DUU_MOTIVO' } )
Aadd( aMemos, { 'DUU_CODENC', 'DUU_OBSENC' } )

//-- Configura variaveis da Enchoice.
RegToMemory(cAlias,.F.)

//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
If nOpcx <> 2
	If !TMSAVerAge("1",DUU->DUU_FILDOC,DUU->DUU_DOC,DUU->DUU_SERIE,,,,,,,,,"2",.T.,.T.)
		Return .F.
	EndIf
EndIf

If M->DUU_STATUS == StrZero( 4, Len( DUU->DUU_STATUS ) ) .And. nOpcx != 2 .And. nOpcx != 7
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help(' ', 1, 'TMSA54001')	//-- Pendencia ja encerrada !
	Return( nOpca )
EndIf

If M->DUU_STATUS == StrZero( 2, Len( DUU->DUU_STATUS ) ) .And. nOpcx == 5
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help(' ', 1, 'TMSA54002')	//-- Indenização ja Solicitada !
	Return( nOpca )
EndIf

         
If nOpcx == 4 .Or. nOpcx == 6    
	If M->DUU_STATUS == StrZero( 2, Len( DUU->DUU_STATUS ) )
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help(' ', 1, 'TMSA54016')	//-- Documento com indenizacao Solicitada.
		Return( nOpca )
	EndIf
	
	If M->DUU_STATUS == StrZero( 3, Len( DUU->DUU_STATUS ) )
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help(' ', 1, 'TMSA54017')	//-- Documento com pendencia indenizada.
		Return( nOpca )
	EndIf
EndIf

If (M->DUU_STATUS == StrZero( 3, Len( DUU->DUU_STATUS ) ) .And. nOpcx == 5) .Or. ;
   ( nOpcx == 5 .And. Empty(M->DUU_FILDOC) .And. Empty(M->DUU_DOC) .And. Empty(M->DUU_SERIE))
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help(' ', 1, 'TMSA54012')	//-- A Indenização não podera ser efetuada para este documento ...
	Return( nOpca )
EndIf
                                
// Carrega aCols e aHeader para que possa ser utilizada a Funcao de Notas Fiscais com Avaria utilizada
// pelo programa de Registro de Ocorrencias
DUA->(dbSetOrder(6))
DUA->(MsSeek(xFilial('DUA')+M->DUU_FILPND+M->DUU_NUMPND))
cFilOco := DUA->DUA_FILOCO
cNumOco := DUA->DUA_NUMOCO
cFilOri := DUA->DUA_FILORI
cViagem := DUA->DUA_VIAGEM
cFilDoc := DUA->DUA_FILDOC
cDoc    := DUA->DUA_DOC
cSerie  := DUA->DUA_SERIE	                         
cCodOco := DUA->DUA_CODOCO
cFilPnd := DUA->DUA_FILPND
cNumPnd := DUA->DUA_NUMPND
                         
AAdd( aNoFields, 'DUA_ESTOCO' )
Aadd( aNoFields, 'DUA_FILORI' )
Aadd( aNoFields, 'DUA_VIAGEM' )
Aadd( aNoFields, 'DUA_FILOCO' )
Aadd( aNoFields, 'DUA_NUMOCO' )

//-- Configura variaveis da GetDados
TMSFillGetDados( 3, 'DUA', 1, xFilial( 'DUA' ) + cFilOco + cNumOco + cFilOri + cViagem, { ||  DUA->(DUA_FILIAL + DUA->DUA_FILOCO + DUA->DUA_NUMOCO +DUA_FILORI + DUA_VIAGEM) },;
{ || .T. }, aNoFields )
                     
GdFieldPut('DUA_FILDOC', cFilDoc, 1)	
GdFieldPut('DUA_DOC'   , cDoc   , 1)
GdFieldPut('DUA_SERIE' , cSerie , 1)
GdFieldPut('DUA_CODOCO', cCodOco, 1)         
GdFieldPut('DUA_FILPND', cFilPnd, 1)   
GdFieldPut('DUA_NUMPND', cNumPnd, 1)

// Carregar o Array contendo as Notas Fiscais com Avaria
TMSA360CarNF(cFilOco, cNumOco,,M->DUU_FILPND, M->DUU_NUMPND)

bSavKeyF4   := SetKey( VK_F4 , { || TMSA360NF(cFilOco, cNumOco, 2) } )
Aadd(aButtons	, {'S4WB005N',{||TMSA360NF(cFilOco, cNumOco, 2)}, STR0009 , STR0010 })  //"Notas Fiscais com Avaria"
                                                                   
bSavKeyF5:= SetKey( VK_F5 , { || TMSA540CON()  })
Aadd(aButtons	, {'S4WB005N',{|| TMSA540CON()  }, STR0018 , STR0018 })  //"Vis.Conciliacao"
TMSA540DUU(aNoFields)

For nContDUU := 1 to Len(aSx3DUU)
	 //-- Permitir manipular os campos de Usuario 
      If ( nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx == 5 ) .And. aSx3DUU[nContDUU, 2] == 'U'
			AAdd( aAltera, aSx3DUU[nContDUU, 1] )      
      EndIf

	//-- Nao apresenta os campos do folder encerramento.
		If	aSx3DUU[nContDUU, 3] != StrZero( 2, Len( aSx3DUU[nContDUU, 3] ) )
			AAdd( aVisual, aSx3DUU[nContDUU, 1] )
		EndIf
	
	//-- Apresenta os campos do folder encerramento.
		If	nOpcx == 2 .Or. nOpcx == 6
			If	aSx3DUU[nContDUU, 3] == StrZero( 2, Len( aSx3DUU[nContDUU, 3] ) )
				AAdd( aVisual, aSx3DUU[nContDUU, 1] )
				AAdd( aAltera, aSx3DUU[nContDUU, 1] )
			EndIf
		EndIf


Next nContDUU 

AAdd( aAltera, 'DUU_MOTIVO' )

If	nOpcx == 4 //-- Alterar
	AAdd( aAltera, 'DUU_CODCLI' )
	AAdd( aAltera, 'DUU_LOJCLI' )
	AAdd( aAltera, 'DUU_VALPRE' )
	nOpcxMnt := 3
ElseIf nOpcx == 5 //-- Indenizar	
	If M->DUU_TIPPND == "04"
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help('',1, 'TMSA54018') 
		Return(nOpca)
	EndIf 
	AAdd( aAltera, 'DUU_VALPRE' )
	nOpcxMnt := 3
ElseIf nOpcx == 6 //-- Encerrar
	AAdd( aAltera, 'DUU_CODMTC' )
	AAdd( aAltera, 'DUU_DESMTC' )
	If	dDataBase < M->DUU_DATPND 
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help(' ', 1, 'TMSA54003')	//-- Data / Hora do encerramento menor que Data / Hora da pendencia.
		Return( nOpca )
	EndIf

	// Ponto de Entrada executado na Opcao de Encerrar Pendencia para Validar Filial da Pendencia
	If lTM540FIL
		lRetPE := .F.
		lRetPE := ExecBlock("TM540FIL",.F.,.F.,{ M->DUU_FILPND, M->DUU_FILDOC, M->DUU_DOC, M->DUU_SERIE })

		If ValType(lRetPE) != "L"
			lRetPE := .F.
		EndIf
	EndIf

	If !lRetPE .And. M->DUU_FILPND <> cFilAnt
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		MsgAlert("A pendência "+M->DUU_NUMPND+" só pode ser encerrada pela filial "+M->DUU_FILPND) 
		Return(nOpca)
	EndIf      
	
	cAliasQry := GetNextAlias()
	cQuery := " SELECT MAX(R_E_C_N_O_) REC"
	cQuery += " FROM " + RetSqlName("DUD")
	cQuery += " WHERE DUD_FILIAL='" + xFilial("DUD") + "'"
	cQuery += "   AND DUD_FILDOC='" + M->DUU_FILDOC + "'"
	cQuery += "   AND DUD_DOC='" + M->DUU_DOC + "'"
	cQuery += "   AND DUD_SERIE='" + M->DUU_SERIE + "'"
	
	If lTM540FIL
		cQuery += " AND DUD_FILORI='" + M->DUU_FILPND + "'"
	Else
		cQuery += " AND DUD_FILORI='" + cFilant + "'"
	EndIf

	cQuery += "   AND D_E_L_E_T_<>'*'"
		
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		
	If (cAliasQry)->(!Eof()) .And. (cAliasQry)->REC > 0
		DUD->( DbGoto( (cAliasQry)->REC ) )
		(cAliasQry)->( dbCloseArea() )     
		If !DUD->DUD_STATUS $ "1/4/9" .And. M->DUU_TIPPND != StrZero(5,TamSx3('DT2_TIPPND')[1])
			DTQ->(DbSetOrder(2))
			If DTQ->(MsSeek(xFilial("DTQ")+ DUD->DUD_FILORI + DUD->DUD_VIAGEM )) 
				If !DTQ->DTQ_STATUS $ "1/3/4/9"
					MsgAlert("A Pendência não pode ser encerrada. Parte do documento esta em viagem. A pendencia so podera ser encerrada "+;
								"quando a viagem for finalizada.")
					//-- Limpa marcas dos agendamentos
					//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
					If !IsInCallStack("TMSAF76")
						TMSALimAge(StrZero(ThreadId(),20))
					EndIf
					Return(nOpca)
				EndIf
			EndIf
		EndIf
	EndIf
	M->DUU_DATENC := dDataBase
	M->DUU_HORENC := StrTran(Left(Time(),5),':','')
	nOpcxMnt := 3
ElseIf nOpcx == 7 //-- Estornar
	If M->DUU_TIPPND == '04'
		If lDocRee
			cAliasQry := GetNextAlias()
			cQuery := " SELECT DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE, DT6.DT6_DATEMI, DT6.DT6_HOREMI,DT6.DT6_DOCTMS"
			cQuery += " FROM " + RetSqlName("DT6") + " DT6 "
			cQuery += " WHERE DT6_FILIAL='" + xFilial("DT6") + "'"
			cQuery += "   AND DT6_FILDCO='" + M->DUU_FILDOC + "'"
			cQuery += "   AND DT6_DOCDCO='" + M->DUU_DOC + "'"
			cQuery += "   AND DT6_SERDCO='" + M->DUU_SERIE + "'"
			cQuery += "   AND DT6.D_E_L_E_T_ = ''"			
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			
			While (cAliasQry)->(!Eof()) 				
				If Stod((cAliasQry)->DT6_DATEMI) >=  M->DUU_DATENC .And. (cAliasQry)->DT6_HOREMI >=  M->DUU_HORENC
					Help(' ', 1, 'TMSA54022') //-- É necessário estornar o documento de reentrega gerado por essa ocorrência
					(cAliasQry)->( dbCloseArea() ) 
					//-- Limpa marcas dos agendamentos
					//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
					If !IsInCallStack("TMSAF76")
						TMSALimAge(StrZero(ThreadId(),20))
					EndIf
					Return( nOpca )				
				EndIf
				If !lReent .And. (cAliasQry)->DT6_DOCTMS == '7' //Documento de reentrega
					lReent := .T.
				EndIf
				(cAliasQry)->( dbSkip() )
			EndDo
			(cAliasQry)->( dbCloseArea() )
		EndIf

		If !lReent
			cAliasQry := GetNextAlias()
			cQuery := " SELECT MAX(R_E_C_N_O_) REC"
			cQuery += " FROM " + RetSqlName("DUD")
			cQuery += " WHERE DUD_FILIAL='" + xFilial("DUD") + "'"
			cQuery += "   AND DUD_FILDOC='" + M->DUU_FILDOC + "'"
			cQuery += "   AND DUD_DOC='" + M->DUU_DOC + "'"
			cQuery += "   AND DUD_SERIE='" + M->DUU_SERIE + "'"
			cQuery += "   AND DUD_FILORI='" + cFilant + "'"
			cQuery += "   AND DUD_VIAGEM<>''"
			cQuery += "   AND D_E_L_E_T_<>'*'"
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			
			If (cAliasQry)->(!Eof()) .And. (cAliasQry)->REC > 0
				DUD->( DbGoto( (cAliasQry)->REC ) )
				If DUD->DUD_VIAGEM <> M->DUU_VIAGEM
					Help(' ', 1, 'TMSA54020') //-- Existem viagens mais recentes para este documento
					(cAliasQry)->( dbCloseArea() ) 
					//-- Limpa marcas dos agendamentos
					//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
					If !IsInCallStack("TMSAF76")
						TMSALimAge(StrZero(ThreadId(),20))
					EndIf
					Return( nOpca )				
				EndIf
			EndIf
			(cAliasQry)->( dbCloseArea() ) 			
		EndIf
	EndIf

	If DUU->DUU_STATUS == StrZero( 1, Len( DUU->DUU_STATUS ) )
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help(' ', 1, 'TMSA54005')	//-- Pendência está em aberto
		Return( nOpca )
	ElseIf DUU->DUU_STATUS == StrZero( 2, Len( DUU->DUU_STATUS ) ) //-- Indenização Solicitada
		DUB->( DbSetOrder( 2 ) )
		If DUB->( !MsSeek( xFilial('DUB')+DUU->(DUU_FILRID+DUU_NUMRID) ) )
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help(' ', 1, 'TMSA54006')	//-- Erro ao localizar Registro de Indenização
			Return( nOpca )
		EndIf
		If DUB->DUB_STATUS != StrZero( 1, Len( DUB->DUB_STATUS ) ) //-- Em Aberto
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help(' ', 1, 'TMSA54007')	//-- Registro de Indenização já está em andamento
			Return( nOpca )
		EndIf			
	ElseIf DUU->DUU_STATUS == StrZero( 3, Len( DUU->DUU_STATUS ) ) //-- Indenizada
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help(' ', 1, 'TMSA54008')	//-- Pendência já indenizada. 
		Return( nOpca )
	ElseIf DUU->DUU_STATUS == StrZero( 4, Len( DUU->DUU_STATUS ) ) //-- Encerrada
		If !Empty( DUU->(DUU_FILDOC+DUU_DOC+DUU_SERIE) )
			DT6->( DbSetOrder( 1 ) )
			If DT6->( !MsSeek( xFilial('DT6')+DUU->(DUU_FILDOC+DUU_DOC+DUU_SERIE) ) )
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Help(' ', 1, 'TMSA54009',,DUU->(DUU_FILDOC+DUU_DOC+DUU_SERIE),2,15)	//-- Erro ao localizar documento que originou a pendência
				Return( nOpca )
			EndIf
		EndIf			
	EndIf	
	nOpcxMnt := 2
EndIf
                          
If lTm540Vld
	lRet := ExecBlock("TM540VLD",.F.,.F.,{nOpcx})
	If ValType(lRet) # "L"
		lRet := .T.
	EndIf	

	If !lRet
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return(nOpca)
	EndIf
EndIf     

//-- Ponto de Entrada para adicionar botoes
If lTm540BUT
	aButTmp := ExecBlock("TM540BUT",.F.,.F.,{nOpcx})
	If ValType(aButTmp) == "A" .And. Len(aButTmp) > 0
		For nCntFor := 1  To Len(aButTmp)
			AAdd(aButtons,aButTmp[nCntFor])
		Next
	EndIf
EndIf

//-- Calcula as dimensoes dos objetos.
aSize  := MsAdvSize( .T. )

AAdd( aObjects, { 100,100,.T.,.T. } )

aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
aPosObj:= MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a Enchoice.
	oEnch := MsMGet():New( cAlias, nReg, nOpcxMnt,,,, aVisual, aPosObj[1], aAltera, , , , , , ,.T. )

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| Iif( TmsA540TOk( nOpcx ), ( nOpca:= 1, oDlgEsp:End() ), nOpca:=0 ) }, {|| oDlgEsp:End() },, aButtons )
//-- Apos confirmar.
If	nOpca == 1 .And. nOpcx != 2
	TmsA540Grv( nOpcx )
Else
	If	__lSX8
		RollBackSX8()
	EndIf
EndIf

SetKey(VK_F4,bSavKeyF4)
SetKey(VK_F5,bSavKeyF5)
RestArea(aAreaAnt)     

//--- Retorna posição no vetor aRotina, para posicionar o cursor no registro selecionado.
If nOpcx > 4
	If (nPos1 := Ascan( aRotina, { |x| x[4] == nOpcx } ) ) > 0
		aRotina[nPos1][4]:= 2
	EndIf   
EndIf      

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

Return ( nOpca )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA540Leg³ Autor ³ Alex Egydio           ³ Data ³09.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a legenda.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
Function TmsA540Leg()

BrwLegenda( cCadastro, STR0011  ,; 		//"Status"
{ { 'BR_VERDE'	   	, STR0012 },; 		//"Em Aberto"
  { 'BR_AMARELO'  	, STR0013 },; 		//"Indenização Solicitada"
  { 'BR_VERMELHO'	   , STR0014 },; 		//"Indenizada"
  { 'BR_AZUL'	      , STR0015 } } ) 	//"Encerrada"
	
Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA540TOk³ Autor ³ Alex Egydio           ³ Data ³12.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tudo Ok                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA540TOk( nOpcx )

Local lRet  	 := .T.
Local lRet2		:= .T.
Local lTM540TOK := ExistBlock('TM540TOK')
Local lTM540TEN := ExistBlock('TM540TEN')
Local cSeek     := ''
Local lHelp     := .T.
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local nTotalPre := 0
Local cFDocDUU	:= DUU->DUU_FILDOC
Local cDocDUU	:= DUU->DUU_DOC
Local cSDocDUU	:= DUU->DUU_SERIE    
Local cNumDUU	:= DUU->DUU_NUMPND    
Local nHorBloq	:= Val(DUU->DUU_HORPND)
Local dDatBloq  := DUU->DUU_DATPND
Local nTMSDIND  := SuperGetMv('MV_TMSDIND',.F.,0) // Dias permitidos para indenizacao apos o documento entregue
Local lDocEntre := .F.
Local cTMSCOSB	:= SuperGetMV('MV_TMSCOSB',,'0')
Local cAtvChgCli	:= SuperGetMV('MV_ATVCHGC',,'')
Local cCliDes		:= ""
Local cLojDes		:= ""
Local aArea			:= GetArea()

//-- Analisa se os campos obrigatorios da Enchoice foram informados.
If nOpcx <> 2 //Visualizar
	lRet := Obrigatorio( aGets, aTela )    
EndIf	

If lRet .And. nOpcx == 5
	//-- Indenizar
	If Empty( M->DUU_VALPRE )
		Help('',1,'OBRIGAT',,RetTitle('DUU_VALPRE'),4) //Um ou alguns campos obrigatorios nao foram preenchidos.xxxxxxxxxxxxxxxxxx -> xxxxxxxxxx Pasta
		lRet := .F.
	EndIf
	
	If lRet
		cQuery := " SELECT DUB_VALPRE FROM "+RetSqlName("DUB")+" WHERE DUB_FILDOC = '"+cFDocDUU+"' AND DUB_DOC = '"+cDocDUU+"' AND DUB_SERIE = '"+cSDocDUU+"' AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)   							
		While (cAliasQry)->( !Eof() )
			nTotalPre += (cAliasQry)->DUB_VALPRE
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->( dbCloseArea() )	
		
		If nTotalPre + M->DUU_VALPRE > M->DUU_VALMER
			Help(' ', 1, 'TMSA54015')
			lRet := .F.			 
		EndIf	
	EndIf			
EndIf

//estorno
If lRet .and. nOpcx == 7	
	If (lTM540TEN) //-- Ponto de entrada para validar o encerramento de uma pendência
		lRet2 := ExecBlock('TM540TEN',.F.,.F.,{nOpcx})
		If( ValType(lRet2) == "L")
			lRet := lRet2
		EndIf
	Else
		lParcial := Posicione("DT6",1,xFilial("DT6") + M->DUU_FILDOC+M->DUU_DOC+M->DUU_SERIE,"DT6_VOLORI") <> M->DUU_QTDOCO
		If lParcial .And. M->DUU_STATUS == StrZero( 4, Len( DUU->DUU_STATUS ) )//se for pendencia encerrada
					lDocEntre:= .F.
			//-- Verifica se a ultima ocorrencia apontada para o documento Entregue, e' de Gera Pendencia/Indenizacao 
			//-- Se sim, permite estornar o encerramento da pendencia.
			If nTMSDIND > 0 .And. DT6->DT6_STATUS ==  StrZero(7,Len(DT6->DT6_STATUS))
				aArea  := GetArea()
				cQuery :=" SELECT MAX(DUA.DUA_NUMOCO) NUMOCO "
				cQuery += "     FROM " + RetSqlName('DUA') + " DUA, " + RetSqlName("DT2") + " DT2"
				cQuery +=" 		WHERE DUA.DUA_FILIAL = '" + xFilial('DUA') + "' "
				cQuery +=" 		  AND DUA.DUA_FILDOC = '" + M->DUU_FILDOC + "' "
				cQuery +=" 		  AND DUA.DUA_DOC	   = '" + M->DUU_DOC + "' "
				cQuery +=" 		  AND DUA.DUA_SERIE  = '" + M->DUU_SERIE + "' "
				cQuery +=" 		  AND DT2.DT2_FILIAL = '" + xFilial('DT2') + "' "
				cQuery +=" 		  AND DT2.DT2_CODOCO = DUA.DUA_CODOCO "
				cQuery +=" 		  AND DT2.DT2_TIPOCO <>'05'"	// Tem que ser diferente de informativa.
				cQuery +=" 		  AND DT2.D_E_L_E_T_ = ' '"
				cQuery +=" 		  AND DUA.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
				If (cAliasQry)->(!Eof())
					cNumOco := (cAliasQry)->NUMOCO
				EndIf
				(cAliasQry)->(DbCloseArea())
				
				DUA->(DbSetOrder( 5 ))
				If DUA->( dBSeek( xFilial( "DUA" ) + cNumOco ) ) .And. Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_TIPOCO") $ "06/09" //Gera Pendencia ou Indenizacao
					lDocEntre:= .T.
				EndIf            
				RestArea(aArea)     
			EndIf  
			
			aArea  := GetArea()
			DUU->(DbSetOrder(3))       //-- Validacao p/ bloqueios
			If DUU->(MsSeek(cSeek := xFilial('DUU')+M->DUU_FILDOC+M->DUU_DOC+M->DUU_SERIE)) 
				Do While DUU->(!EoF()) .And. DUU->(cSeek == DUU_FILIAL+DUU_FILDOC+DUU_DOC+DUU_SERIE) 
						If DUU->DUU_NUMPND <> cNumDUU  .And. DUU->DUU_TIPPND == '99'  //-- verifica a pendencia de bloqueio selecionada
														//-- Confere com os registros de bloquios anteriores
								If DUU->DUU_DATPND >  dDatBloq .OR. (Val(DUU->DUU_HORPND) > nHorBloq .AND. DUU->DUU_DATPND == dDatBloq)
								Help("",1,"TMSA54021")  //-- Existem pendências de bloqueio mais recentes
							lRet := .F.			     
							Exit
								EndIf
						EndIf  
				DUU->(dbSkip())
				Enddo         
			EndIf
			RestArea(aArea) 
			
				//Se houve um apontamento de entrega parcial para este documento, gera DUD para entrega da quantidade que falta ser entregue
			//se este DUD estiver em transito nao e possivel estornar.
			DUA->( DbSetOrder(4) )
			If DUA->( MsSeek( cSeek := xFilial("DUA") + M->DUU_FILDOC+M->DUU_DOC+M->DUU_SERIE + M->DUU_FILORI+M->DUU_VIAGEM ) ) ;
				.And. DUA->DUA_SERTMS <> StrZero(1,Len(DUA->DUA_SERTMS))
				Do While DUA->( cSeek == DUA_FILIAL + DUA_FILDOC + DUA_DOC + DUA_SERIE + DUA_FILORI + DUA_VIAGEM)
					//verifica se existe alguma viagem de ou transporte entrega em aberto para o documento
					cQuery := " SELECT DUD_FILORI,DUD_VIAGEM FROM " + RetSqlName("DUD") + " DUD "
					cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
					cQuery += " AND DUD_FILDOC   = '" + M->DUU_FILDOC  + "' "
					cQuery += " AND DUD_DOC      = '" + M->DUU_DOC     + "' "
					cQuery += " AND DUD_SERIE    = '" + M->DUU_SERIE   + "' "
					//se a viagem a qual gerou a pendencia esta na filial de destino (final) entao verifica se a uma viagem de entrega se ela for de transporte gerada para o documento
					cQuery += " AND DUD_VIAGEM   <> '" + Space(Len(DUD->DUD_VIAGEM)) + "' "
					cQuery += " AND DUD_FILVGE     = '" + M->DUU_FILORI + "' "
					cQuery += " AND DUD_NUMVGE     = '" + M->DUU_VIAGEM + "' "
					cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
					cQuery := ChangeQuery(cQuery)
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)   							
					If (cAliasQry)->( !Eof() ) .Or. ( DT6->DT6_STATUS ==  StrZero(7,Len(DT6->DT6_STATUS)) .And. !lDocEntre)
						Help("",1,"TMSA54013",,(cAliasQry)->DUD_FILORI+"/"+(cAliasQry)->DUD_VIAGEM) //O estorno nao pode ser efetuado pois existe uma viagem para este documento
						lRet := .F.			
						Exit
					EndIf
					(cAliasQry)->( dbCloseArea() )

					DUA->( DbSkip() )
				EndDo
			EndIf				
		EndIf
	EndIf
EndIf
                          
//-- Encerrar
If lRet .And. nOpcx == 6
	If (lTM540TEN) //-- Ponto de entrada para validar o encerramento de uma pendência
		lRet2 := ExecBlock('TM540TEN',.F.,.F.,{nOpcx})
		If( ValType(lRet2) == "L")
			lRet := lRet2
		EndIf
	Else
		DT6->(dbSetOrder(1))
		If DT6->(MsSeek(xFilial('DT6')+M->DUU_FILDOC+M->DUU_DOC+M->DUU_SERIE)) .And. DT6->DT6_STATUS == StrZero(7, Len(DT6->DT6_STATUS)) //Entregue
			
			cSeek := xFilial("DUA") + M->DUU_FILDOC + M->DUU_DOC + M->DUU_SERIE

			//Antes de considerar que nao pode encerrar devido o status do ctrc estar como entregue,
			//verifica se a entrega esta apontada juntamente com a ocorrencia que gera pendencia.
			DUA->( DbSetOrder(4) )
			If DUA->( MsSeek( cSeek ) )
				Do While cSeek == DUA->( DUA_FILIAL + DUA_FILDOC + DUA_DOC + DUA_SERIE )
					If DUA->DUA_CODOCO == M->DUU_CODOCO
						DUA->( DbSkip() )
						Loop
					EndIf
					If Posicione('DT2',1,xFilial('DT2') + DUA->DUA_CODOCO,'DT2_TIPOCO')	== StrZero( 1, Len( DT2->DT2_TIPOCO ) )
						lHelp := .F.
					EndIf
					DUA->( DbSkip() )
				EndDo
			EndIf
			If lHelp
				Help("",1,"TMSA54004") //O Encerramento Nao podera ser efetuado, pois este Documento ja foi Entregue ...
				lRet := .F.
			EndIf
		EndIf
		//verificar se ja existe um movimento de viagem ja carregado, se houver nao permite encerrar essa pendencia ate se desfazer esse carregamento, ou encerrar essa viagem
		If lRet
			cQuery := " SELECT DUD_FILORI,DUD_VIAGEM FROM " + RetSqlName("DUD") + " DUD "
			cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
			cQuery += " AND DUD_FILDOC   = '" + M->DUU_FILDOC  + "' "
			cQuery += " AND DUD_DOC      = '" + M->DUU_DOC     + "' "
			cQuery += " AND DUD_SERIE    = '" + M->DUU_SERIE   + "' "
			If DUA->DUA_SERTMS == StrZero(2,Len(DUA->DUA_SERTMS)) .And. ;
				Posicione("DTQ",2,xFilial("DTQ") + M->DUU_FILORI + M->DUU_VIAGEM,"DTQ_FILATU") == DT6->DT6_FILDES
				cQuery += " AND DUD_SERTMS   = '" + StrZero(3,Len(DUA->DUA_SERTMS)) + "' "
			Else
				cQuery += " AND DUD_SERTMS   = '" + DUA->DUA_SERTMS+ "' "
			EndIf
			cQuery += " AND DUD_FILVGE     = '" + M->DUU_FILORI + "' "
			cQuery += " AND DUD_NUMVGE     = '" + M->DUU_VIAGEM + "' "
			cQuery += " AND DUD_STATUS     IN ('" + StrZero(2,Len(DUD->DUD_STATUS)) + "','" + StrZero(3,Len(DUD->DUD_STATUS)) + "')"
			cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			If (cAliasQry)->( !Eof() )
				Help("",1,"TMSA54014",,(cAliasQry)->DUD_FILORI+"/"+(cAliasQry)->DUD_VIAGEM) //Esta pendencia nao podera ser encerrada ate a viagem atual ter seu carregamento estornado ou ser encerrada
				lRet := .F.
			EndIf
			(cAliasQry)->( dbCloseArea() )
		EndIf
 
		If lRet .And. M->DUU_TIPPND == "05" //-- Retirada Mercadoria
			If Posicione("DTQ", 2, xFilial("DTQ")+M->DUU_FILORI+M->DUU_VIAGEM, "DTQ_STATUS") <> "2"
				lRet		:= .F. 
				Help("",1,"TMSA54025") //-- Esta pendencia não pode ser encerrada pois para pendencia do tipo 05=Retirada de mercadoria, a viagem necessita estar com o status 2=Em trânsito.                                        
			EndIf

			If lRet
				
				DT6->( dbSetOrder(1))
				If DT6->( dbSeek( xFilial("DT6") + M->DUU_FILDOC + M->DUU_DOC + M->DUU_SERIE ) )					
					If !Empty(DT6->DT6_SQEDES)
						DUL->(dbSetOrder(2))
						If DUL->( dbSeek( xFilial("DUL") + DT6->DT6_CLIDES + DT6->DT6_LOJDES + DT6->DT6_SQEDES )) .And. ( !Empty(DUL->DUL_CODRED) .And. !Empty( DUL->DUL_LOJRED)  ) 
							cCliDes	:= DUL->DUL_CODRED
							cLojDes	:= DUL->DUL_LOJRED
						EndIf
					Else
						cCliDes		:= DT6->DT6_CLIDES
						cLojDes		:= DT6->DT6_LOJDES
					EndIf
				EndIf

				cAliasQry	:= GetNextAlias()

				cQuery	:= " SELECT DTW_CODCLI , DTW_LOJCLI , DTW_ATIVID "
				cQuery	+= " FROM " + RetSQLName("DTW") + " DTW "
				cQuery	+= " WHERE DTW_FILIAL 	= '" + xFilial("DTW") + "' "
				cQuery	+= " AND DTW_FILORI 	= '" + M->DUU_FILORI  + "' " 
				cQuery	+= " AND DTW_VIAGEM		= '" + M->DUU_VIAGEM  + "' "
				cQuery	+= " AND DTW_STATUS		= '2' " //-- 2=Encerrado
				cQuery	+= " AND DTW_DATREA		<> '' "
				cQuery	+= " AND DTW_HORREA		<> '' "
				cQuery	+= " AND DTW.D_E_L_E_T_ = '' "
				cQuery	+= " ORDER BY DTW.R_E_C_N_O_ DESC "

				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

				If (cAliasQry)->( !Eof() )
					If (cAliasQry)->DTW_ATIVID == cAtvChgCli .And. ( (cAliasQry)->DTW_CODCLI == cCliDes .And. (cAliasQry)->DTW_LOJCLI == cLojDes )
						lRet	:= .T. 
					Else						
						lRet	:= .F. 
						Help("",1,"TMSA54026")	//-- Esta pendência não pode ser encerrada pois para pendência do tipo 05=Retirada de mercadoria, a operação de chegada no respectivo cliente deve estar corretamente apontada e a operação de saída desse respectivo cliente deve estar em aberto.
					EndIf
				EndIf

			EndIf

		EndIf

	EndIf
EndIf    

If lRet .And. nOpcx == 6
	If DUU->DUU_TIPPND $ ("01/03") .And. cTMSCOSB <> '0'           
		lRet:= TMS540DYZ()
		If !lRet .Or. (DUU->DUU_QTDCON > 0)   //Nao encontrou Pendente ou Existe conciliacao efetuada
		 	If Empty(M->DUU_CODMTC)
				Help(' ', 1, 'TMSA54024')	//Informe o Codigo do Motivo da Conciliação
				lRet:= .F.
			EndIf
		EndIf
		If !lRet .And. !Empty(M->DUU_CODMTC)
			If MsgYesNo( STR0019 ) //Existem Conciliacoes pendentes e serão encerradas automaticamente. Confirma?
				lRet:= .T.
			EndIf 
		EndIf
	EndIf	
EndIf

If	lRet .And. lTM540TOK
	lRet := ExecBlock('TM540TOK',.F.,.F.,{nOpcx})
EndIf

RestArea(aArea)
DbSelectArea("DUU")

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA540Grv³ Autor ³ Alex Egydio           ³ Data ³12.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA540Grv( nOpcx )

Local bCampo		:= { |nCpo| Field(nCpo) }
Local cMemo			:= ''
Local nCntFor		:= 0
Local nQuant		:= 0
Local lTM540GRV		:= ExistBlock('TM540GRV')                        
Local lRet			:= .T.
Local aCampos		:= {}
Local aAreaDUD		:= {}
Local cQuery		:= ''
Local cAliasQry		:= GetNextAlias()
Local lGeraDud		:= .T.
Local nRecnoDUU		:= DUU->( Recno() )
Local nRadio		:= 1
Local lDTCNNEntr	:= DTC->(FieldPos('DTC_NFENTR')) > 0 
Local nOpca			:= 0
Local oRadio		:= Nil
Local oBut1			:= Nil
Local oDlgRet		:= Nil
Local lManut_Doc	:= .F.
Local lDesbloDoc	:= .T.
Local lVigVazia		:= .F.
Local aAreaBlq		:= {}
Local nTMSDIND      := SuperGetMv('MV_TMSDIND',.F.,0) // Dias permitidos para indenizacao apos o documento entregue
Local lDocEntre     := .F.
Local lMv_TmsPNDB   := SuperGetMv("MV_TMSPNDB",.F.,.F.) //-- Permite informar a ocorrencia de Pendencia para um Docto Bloqueado
Local lBloqueado    := .F.
Local lDocRee	 	:= SuperGetMV('MV_DOCREE',,.F.) .And. TMSChkVer('11','R7')
Local cTMSCOSB	    := SuperGetMV('MV_TMSCOSB',,'0')
Local lRetMer		:= .F.

Local lITmsDmd    := SuperGetMv("MV_ITMSDMD",,.F.)
Local lTransito   := .F.
Local cDUDStat	  := '1'

Private aHeader		:= {}
Private aCols		:= {}
// Variaveis utilizadas no TMSA500
Private cLoteAut	:= ""
Private lTmsCFec	:= .F.	//-- Desabilita nas funcoes do tmsa200 o tratamento de carga fechada
Private nDiaArm		:= 0
Private lPenArm		:= .F.

If lDTCNNEntr
	Pergunte("TMA540",.F.)

	lManut_Doc:= Iif(mv_par01 == 1,.T.,.F.)  
EndIf

If lMv_TmsPNDB
	lMv_TmsPNDB:= FindFunction('TM360BLOQ')
EndIf  
If nOpcx == 6 //-- Encerrar	
	M->DUU_STATUS := StrZero( 4, Len( DUU->DUU_STATUS ) ) //-- Encerrada
ElseIf nOpcx == 7 //-- Estornar
	M->DUU_STATUS := StrZero( 1, Len( DUU->DUU_STATUS ) ) //-- Em Aberto
	M->DUU_FILRID := Space( Len( DUU->DUU_FILRID ) )
	M->DUU_NUMRID := Space( Len( DUU->DUU_NUMRID ) )
	M->DUU_DATENC := Ctod( '' )
	M->DUU_HORENC := Space( Len( DUU->DUU_HORENC ) )
	M->DUU_CODMTC := ""
	M->DUU_OBSENC := ""
EndIf

If nTMSDIND > 0        
	DT6->( DbSetOrder( 1 ) )
	If DT6->( DbSeek( xFilial('DT6')+M->DUU_FILDOC+M->DUU_DOC+M->DUU_SERIE ) ) .And. DT6->DT6_STATUS == StrZero( 7, Len( DUU->DUU_STATUS ) ) .And.;
		DT6->DT6_BLQDOC == StrZero( 2, Len( DT6->DT6_BLQDOC ) )                         
			lDocEntre:= .T.				
	EndIf
EndIf	
If lMv_TmsPNDB
	lBloqueado:= TM360BLOQ(M->DUU_FILDOC, M->DUU_DOC, M->DUU_SERIE)
EndIf					
Begin Transaction
	If nOpcx == 5 //indenizar
		M->DUU_NUMRID := TmsA360DUB( M->DUU_FILORI, M->DUU_VIAGEM, M->DUU_FILDOC, M->DUU_DOC, M->DUU_SERIE, M->DUU_CODCLI, M->DUU_LOJCLI, M->DUU_CODOCO, M->DUU_MOTIVO, M->DUU_QTDOCO, M->DUU_VALPRE, 3 )
		
		If !Empty(M->DUU_NUMRID)
			M->DUU_FILRID := cFilAnt
			M->DUU_STATUS := StrZero( 2, Len( DUU->DUU_STATUS ) ) //-- Indenização Solicitada
			//chama a rotina de atualizacao de saldo apenas para indicar a entrega se encerrou o saldo do documento
			nQuant        := 0
			If !lDocEntre
				lRet          := TM360AtuSal(M->DUU_FILDOC,M->DUU_DOC,M->DUU_SERIE,@nQuant, '01',Iif(Empty(M->DUU_DATENC),dDataBase,M->DUU_DATENC),.F. , M->DUU_FILORI, M->DUU_VIAGEM, .T. , nRecnoDUU )
			EndIf
			If lDTCNNEntr .And. DT6->DT6_DOCTMS != "6"  .And. !lDocEntre//--Documento de devolução não possui DTC logo help não pode ser apresentado para devolução.
		  		If !Tms540ASts(M->DUU_FILPND,M->DUU_NUMPND,nOpcx) 
		  			lRet := .F.
		  			Help('',1, 'TMSA54019' ) // Nota Fiscal não encontrada
		   		EndIf			
	 		EndIf
			//---- Encerra as conciliacoes
			If cTMSCOSB <> '0' .And. DUU->DUU_TIPPND $ ("01/03") 
				TMS540DYZ(nOpcx)
			EndIf
		Else
			lRet := .F.
		EndIf						
	ElseIf nOpcx == 6 	//-- Encerrar
		
		lRetMer := Posicione('DT2',1,FwxFilial('DT2')+M->DUU_CODOCO,'DT2_TIPPND') == StrZero(5,TamSx3('DT2_TIPPND')[1])
		If M->DUU_TIPPND == "04"
			
			If lManut_Doc // MsgYesNo("Deseja gerar o Documento de Re-entrega ou Devoulução?","Atenção") // "Deseja gerar o Documento de Re-entrega ou Devoulução?","Atenção"
				While nOpca == 0
					DEFINE MSDIALOG oDlgRet TITLE 'Opção' FROM 09,0 TO 18,37 OF oMainWnd // "Tela"
					DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
				
					@ 03, 14 SAY 'Selecione a opção desejada:' FONT oBold PIXEL //Pergunta
					@ 14, 00 TO 16 ,400 LABEL '' OF oDlgRet   PIXEL // Linha
					@ 20, 40 RADIO oRadio VAR nRadio 3D SIZE 70, 11 PROMPT 'Somente Encerrar','Re-Entregar','Devolver' of oDlgRet PIXEL // Opcoes
				
					oRadio:SetEnable( .T. )
					
					DEFINE SBUTTON oBut1 FROM 055, 061 TYPE 1 ACTION ( nOpca := 1, oDlgRet:End() )  ENABLE of oDlgRet
				   
					oBut1:SetFocus()
					
			  		ACTIVATE MSDIALOG oDlgRet CENTERED  
			  		
			  		If nOpca == 1
			  		 	Exit
			  		EndIf
			 	EndDo
			EndIf
		EndIf
		DT6->( DbSetOrder( 1 ) )
		If DT6->( DbSeek( xFilial('DT6')+M->DUU_FILDOC+M->DUU_DOC+M->DUU_SERIE ) ) .And. !lDocEntre
		
			cQuery := " SELECT COUNT(*) AS PNDABERTA "
			cQuery += " FROM " + RetSqlName("DUU") + " DUU "
			cQuery += " WHERE DUU_FILIAL = '"+xFilial("DUU")+"' "
			cQuery += " AND DUU_FILDOC   = '"+M->DUU_FILDOC+"' "
			cQuery += " AND DUU_DOC      = '"+M->DUU_DOC+"' "
			cQuery += " AND DUU_SERIE    = '"+M->DUU_SERIE+"' "
			cQuery += " AND DUU_STATUS   = '1' "
			//-- Incluido este trecho pois o tipo 02 de pendências de AVARIA não
			//-- precisa ser considerado pois pode ficar em aberto eaconteçer
			//-- encerramento do bloqueio liberando o documento para entrega
			cQuery += " AND DUU_TIPPND NOT IN ('02')"
			cQuery += " AND D_E_L_E_T_   = '' "
			cQuery := ChangeQuery(cQuery) 			
			
 			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)   							
			If (cAliasQry)->( !Eof() ) .And. (cAliasQry)->(PNDABERTA) > 1
				lDesbloDoc := .F.
			EndIf
			(cAliasQry)->( dbCloseArea() )

			//volta saldo para o documento no encerramento
 			nQuant   := M->DUU_QTDOCO
			lRet  := TM360AtuSal(M->DUU_FILDOC,M->DUU_DOC,M->DUU_SERIE,-nQuant, '01',M->DUU_DATENC,.F. , M->DUU_FILORI, M->DUU_VIAGEM, .T. , nRecnoDUU )			

			If lDesbloDoc
				If !lBloqueado								
					RecLock("DT6",.F.)
					DT6->DT6_BLQDOC := StrZero( 2, Len( DT6->DT6_BLQDOC ) ) //-- Nao bloqueado
					DT6->( MsUnLock() )
				EndIf	

				If lDTCNNEntr .And. DT6->DT6_DOCTMS != "6" 
					If !Tms540ASts(M->DUU_FILPND,M->DUU_NUMPND,nOpcx)
						Help('',1, 'TMSA54019' ) // Nota Fiscal não encontrada
						lRet := .F.
					EndIf
				EndIf
				If lRet .And. !lRetMer
					//verifica se existe alguma viagem de entrega em aberto para o documento
					cQuery := " SELECT DUD_FILORI,DUD_VIAGEM FROM " + RetSqlName("DUD") + " DUD "
					cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
					cQuery += " AND DUD_FILDOC   = '" + M->DUU_FILDOC  + "' "
					cQuery += " AND DUD_DOC      = '" + M->DUU_DOC     + "' "
					cQuery += " AND DUD_SERIE    = '" + M->DUU_SERIE   + "' "
					cQuery += " AND (DUD_SERTMS   = '" + StrZero(3,Len(DUD->DUD_SERTMS)) + "' "
					cQuery += " OR DUD_SERTMS   = '" + StrZero(2,Len(DUD->DUD_SERTMS)) + "') "
					cQuery += " AND DUD_STATUS   < '" + StrZero(4,Len(DUD->DUD_STATUS)) + "' "
					cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
					cQuery := ChangeQuery(cQuery)
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)   							
					If (cAliasQry)->( !Eof() )
						lGeraDud := .F.			
					EndIf
					(cAliasQry)->( dbCloseArea() )

					If lGeraDud
						dbSelectArea("DUD")
						aAreaDUD := DUD->(GetArea())
						DUD->(DbSetOrder(1))
						
						lVigVazia := DUD->(MsSeek(xFilial('DUD') + M->DUU_FILDOC + M->DUU_DOC + M->DUU_SERIE + M->DUU_FILORI + Space(TamSx3("DUU_VIAGEM")[1]) ))
						
						If DUD->(MsSeek(xFilial('DUD') + M->DUU_FILDOC + M->DUU_DOC + M->DUU_SERIE + M->DUU_FILORI + M->DUU_VIAGEM )) .And. DUD->DUD_STATUS != StrZero(9,Len(DUD->DUD_STATUS))
							RecLock("DUD",.F.)
							DUD->DUD_STATUS := StrZero(9, Len(DUD->DUD_STATUS))
							DUD->(MsUnLock())
						EndIf					 
						
						If !lVigVazia
							aCampos  := {}
							If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) .And. DT6->DT6_FILDES == cFilAnt
								lTransito := .F.
								cDUDStat := TMS540DUDS(DUD->DUD_VIAGEM, @lTransito)
								Aadd( aCampos, { 'DUD_SERTMS', StrZero( 3, Len( DUD->DUD_SERTMS ) ) } )
							ElseIf (DUD->DUD_SERTMS == StrZero(3,Len(DUD->DUD_SERTMS))) .Or. (M->DUU_TIPPND == "99" .And. DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)))
								lTransito := .F.
								If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS))
									cDUDStat := TMS540DUDS(DUD->DUD_VIAGEM, @lTransito)
								EndIf
								Aadd( aCampos, { 'DUD_FILORI', Iif(lTransito,DUD->DUD_FILORI,cFilAnt) } )
							EndIf
							Aadd( aCampos, { 'DUD_FILATU', Iif(lTransito,DUD->DUD_FILATU,cFilAnt) } )
							Aadd( aCampos, { 'DUD_STATUS', cDUDStat } )
							Aadd( aCampos, { 'DUD_MANIFE', Iif(lTransito,DUD->DUD_MANIFE,CriaVar('DUD_MANIFE', .F.)) } )
							Aadd( aCampos, { 'DUD_SERMAN', Iif(lTransito,DUD->DUD_SERMAN,CriaVar('DUD_SERMAN', .F.)) } )
							Aadd( aCampos, { 'DUD_FILMAN', Iif(lTransito,DUD->DUD_FILMAN,CriaVar('DUD_FILMAN', .F.)) } )
							Aadd( aCampos, { 'DUD_VIAGEM', Iif(lTransito,DUD->DUD_VIAGEM,CriaVar('DUD_VIAGEM', .F.)) } )
							Aadd( aCampos, { 'DUD_SEQUEN', Iif(lTransito,DUD->DUD_SEQUEN,CriaVar('DUD_SEQUEN', .F.)) } )
							// Limpa campos de não previsto
							If DUD->(ColumnPos("DUD_DTRNPR")) > 0
								AAdd( aCampos, { 'DUD_DTRNPR',  CriaVar("DUD_DTRNPR", .F.) } )
								AAdd( aCampos, { 'DUD_HRRNPR',  CriaVar("DUD_HRRNPR", .F.) } )	
								AAdd( aCampos, { 'DUD_USURNP',  CriaVar("DUD_USURNP", .F.) } )
								AAdd( aCampos, { 'DUD_NOMUSU',  CriaVar("DUD_NOMUSU", .F.) } )	
							EndIf
					   		//-- Se a entrega do aereo for feita no rodoviario
							If	GetMv( 'MV_ENTAER',, '2' ) == '1'
								Aadd( aCampos, { 'DUD_TIPTRA', StrZero( 1, Len( DUD->DUD_TIPTRA ) ) } )
							EndIf
							If  ALLTRIM(aCampos[1][1]) == 'DUD_FILORI' .And. ALLTRIM(aCampos[1][2]) != '' .And. ALLTRIM(aCampos[1][2]) != Nil .And. !lTransito
							
								TmsCopyReg( aCampos ) 
							EndIf

							If lTransito
								RecLock("DT6",.F.)
								DT6->DT6_STATUS := StrZero( 3, Len( DT6->DT6_BLQDOC ) ) //-- Em Transito
								DT6->(MsUnLock())

								If DUD->(MsSeek(xFilial('DUD') + M->DUU_FILDOC + M->DUU_DOC + M->DUU_SERIE + M->DUU_FILORI + M->DUU_VIAGEM )) .And. DUD->DUD_STATUS = StrZero(9,Len(DUD->DUD_STATUS))
									RecLock("DUD",.F.)
									DUD->DUD_STATUS := cDUDStat
									DUD->(MsUnLock())
								EndIf
							EndIf
	         			EndIf
	         			RestArea(aAreaDUD)
					EndIf
				EndIf
			EndIf

			//-- Incluido tratamento para que ao encerrar uma pendência de BLOQUEIO gerado por uma ocorrência
			//-- de GERA PENDÊNCIA parcial o campo o seu DT6 seja liberado no campo BLQDOC, alteração feita
			//-- de acordo com alinhamento entre analista especialista em TMS e IP, mais informações no chamado: SDMQII.
			If(M->DUU_TIPPND == "01" .Or. M->DUU_TIPPND == "02" .Or. M->DUU_TIPPND == "03" .Or. M->DUU_TIPPND == "99") .And. !lDocEntre
				aAreaBlq	:= (GetArea())
				If !lBloqueado
					If(DT6->DT6_VOLORI > DUA->DUA_QTDOCO)
						RecLock("DT6",.F.)
						DT6->DT6_BLQDOC := StrZero( 2, Len( DT6->DT6_BLQDOC ) ) //--Nao bloqueado
						DT6->(MsUnLock())
					EndIf
				EndIf
				RestArea(aAreaBlq)
			EndIf			

			//-- Atualiza Gestão de Demandas
			If nRadio == 1 .And. lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
				TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,.F.,,,.T.,.F.)
			EndIf
		EndIf
		//---- Encerra as conciliacoes
		If cTMSCOSB <> '0' .And. DUU->DUU_TIPPND $ ("01/03") 
			TMS540DYZ(nOpcx)
		EndIf		
	ElseIf nOpcx == 7 	//-- Estornar    

		If DUU->DUU_STATUS == StrZero( 2, Len( DUU->DUU_STATUS ) ) //-- Indenização Solicitada
			nQuant := 0
			If !lDocEntre
				lRet   := TM360AtuSal(M->DUU_FILDOC,M->DUU_DOC,M->DUU_SERIE,nQuant, 'ES',, .F.,M->DUU_FILORI ,M->DUU_VIAGEM ,.T., nRecnoDUU )
			EndIf
			DUB->( DbSetOrder( 2 ) )
			If DUB->( MsSeek( xFilial('DUB')+DUU->(DUU_FILRID+DUU_NUMRID) ) )
				//-- Exclui motivo
				MSMM(DUB->DUB_CODMTV,,,,2)
				//-- Exclui registro de indenizacao
				RecLock( 'DUB', .F. )
				DbDelete()
				MsUnLock()
			EndIf

		ElseIf DUU->DUU_STATUS == StrZero( 4, Len( DUU->DUU_STATUS ) ) //-- Encerrada
			DT6->( DbSetOrder( 1 ) )
			If DT6->( MsSeek( xFilial('DT6')+M->DUU_FILDOC+M->DUU_DOC+M->DUU_SERIE ) ) .And. !lDocEntre
				nQuant:= DUU->DUU_QTDOCO
				lRet  := TM360AtuSal(M->DUU_FILDOC,M->DUU_DOC,M->DUU_SERIE,@nQuant, StrZero(6,Len(DT2->DT2_TIPOCO)) ,, .F.,M->DUU_FILORI ,M->DUU_VIAGEM , .T., nRecnoDUU,,nOpcx )
				If lRet .And. nQuant == 0
					If !lBloqueado
						RecLock("DT6",.F.)
						DT6->DT6_BLQDOC := StrZero( 1, Len( DT6->DT6_BLQDOC ) ) //-- Sim
						DT6->( MsUnLock()	)
					EndIf	
				EndIf
				//-- Atualiza Gestão de Demandas
				If nRadio == 1 .And. lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
					TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,.T.,,,.T.,.F.)
				EndIf

			EndIf
		EndIf			
		If lDTCNNEntr
		   If !Tms540ASts(M->DUU_FILPND,M->DUU_NUMPND,nOpcx) 
		   	lRet := .F.
		   	Help('',1, 'TMSA54019' ) // Nota Fiscal não encontrada
			EndIf
		EndIf			
		//---- Encerra as conciliacoes
		If cTMSCOSB <> '0' .And. DUU->DUU_TIPPND $ ("01/03") 
			TMS540DYZ(nOpcx)
		EndIf		

	EndIf              	
	If lRet
		RecLock('DUU',.F.)
		For nCntFor := 1 To FCount()
			If FieldName( nCntFor ) == 'DUU_FILIAL'
				FieldPut( nCntFor, xFilial('DUU') )
			ElseIf FieldGet( nCntFor ) != M->&( Eval( bCampo, nCntFor ) )
				FieldPut( nCntFor, M->&( Eval( bCampo, nCntFor ) ) )
			EndIf
		Next
	
		//-- Grava campos memo.
		If Type('aMemos') == 'A'
			For nCntFor := 1 To Len( aMemos )
				cMemo := aMemos[ nCntFor, 2 ]
				MSMM( &( aMemos[ nCntFor, 1 ] ), TamSx3( aMemos[ nCntFor, 2 ] )[ 1 ],, &cMemo, 1,,, 'DUU', aMemos[ nCntFor, 1 ] )
			Next
		EndIf
		MsUnLock()
	
		If	lTM540GRV
			ExecBlock('TM540GRV',.F.,.F.,{nOpcx})
		EndIf									
	Else
		DisarmTransaction()
	EndIf	
End Transaction
	
	If lRet
		If nOpca == 1 .and. nOpcx == 6 
			If nRadio == 1
				lRet := .T.
			ElseIf nRadio == 2 //Re-entrega
				SaveInter()
				cCadastro   := 'Manutencao de Documentos'
				lRet:= TMSA500Mnt( "DT6", DT6->(Recno()) , 5 ) <> 0   

				If lDocRee  .And. lRet .And. !lRetMer  //-- pendencia de reentrega encerra movimento de viagem
					DbSelectArea("DUD")
					DbSetOrder(1)	
					If DUD->(MsSeek(xFilial("DUD")+DUU->(DUU_FILDOC+DUU_DOC+DUU_SERIE)))
						RecLock("DUD",.F.)
						DUD->DUD_STATUS := StrZero(4,Len(DUD->DUD_STATUS)) //--Encerrado
						DUD->(MsUnLock())
					EndIf
				EndIf
				RestInter()
			ElseIf nRadio == 3 // Devolucao
				SaveInter()
				cCadastro   := 'Manutencao de Documentos'				
				lRet:= TMSA500Mnt( "DT6", DT6->(Recno()) , 4 ) <> 0
				RestInter()
			EndIf
		EndIf
		If lRetMer 
			//--Rotina que exibe tela para permitir o usuário escolher se incluiurá uma documento de entreda (TMSA050) ou uma solicitação de Coleta(TMSA460)
			A540RetMER()
		EndIf
	EndIf

Return NIL

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
     
Private aRotina	:= {	{ STR0002,'AxPesqui'  ,0,1,0,.F.},; 	//"Pesquisar"
								{ STR0003,'TmsA540Mnt',0,2,0,NIL},; 		//"Visualizar"
								{ STR0004,'TmsA540Mnt',0,4,0,NIL},; 		//"Alterar"
								{ STR0005,'TmsA540Mnt',0,5,0,NIL},; 		//"Indenizar"
								{ STR0006,'TmsA540Mnt',0,6,0,NIL},; 		//"Encerrar"
								{ STR0007,'TmsA540Mnt',0,7,0,NIL},; 		//"Estornar"
								{ STR0018,'TmsA540Con',0,8,0,NIL},; 		//"Vis. Conciliacao"
								{ STR0008,'TmsA540Leg',0,9,0,.F.} } 		//"Legenda"


If ExistBlock("TM540MNU")
	ExecBlock("TM540MNU",.F.,.F.)
EndIf

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tms540ASts³ Autor ³ TOTVS S.A             ³Data ³29.OUT.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera Status da NF                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function Tms540ASts(cFilPnd,cNumPnd,nOpcx)

Local aArea			:= GetArea()
Local lRet      := .F.
Local cQuery	  := ""
Local cAliasQry  := "" 
Local lDocRee	 := SuperGetMV('MV_DOCREE',,.F.) .And. TMSChkVer('11','R7')

Default cFilPnd := ''
Default cNumPnd := ''
Default nOpcx   := 0

//-- A tela de Notas fiscais pendentes não é exibida para tipos de pendência diferentes de 01, 02 e 04
//-- com isso a validação abaixo é feita apenas para pendências tipo 01,02,04 e 06.
If ( DT2->DT2_TIPOCO == "01" .Or. DT2->DT2_TIPOCO == "02" .Or. DT2->DT2_TIPOCO == "04" .Or. DT2->DT2_TIPOCO == "06" )
	cAliasQry := GetNextAlias()
	
	cQuery:= " SELECT DTC.R_E_C_N_O_ RECDTC "
	cQuery+= " FROM " +RetSqlName("DV4")+ " DV4 "
	cQuery+= " INNER JOIN " +RetSqlName("DTC")+ " DTC ON "
	cQuery+= " DTC_FILIAL = '"+xFilial("DTC")+"' "
	cQuery+= " AND DTC_DOC = DV4_DOC "
	cQuery+= " AND DTC_SERIE = DV4_SERIE "
	cQuery+= " AND DTC_FILDOC = DV4_FILDOC "
	cQuery+= " AND DTC_NUMNFC = DV4_NUMNFC "
	cQuery+= " AND DTC_SERNFC = DV4_SERNFC "
	cQuery+= " WHERE DV4_FILIAL = '"+xFilial("DV4")+"' "
	cQuery+= " AND DV4_FILPND = '"+cFilPnd+"' "
	cQuery+= " AND DV4_NUMPND = '"+cNumPnd+"' "
	cQuery+= " AND DV4.D_E_L_E_T_ = '' "
	cQuery+= " AND DTC.D_E_L_E_T_ = '' "
	
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
	If (cAliasQry)->(Eof()) .And. lDocRee .And. (DT2->DT2_TIPOCO == "04" .Or. DT2->DT2_TIPOCO == "06")
		 //-- Caso a query padrao nao localize registros, eh chamada uma segunda exclusiva para casos de reentrega
		cAliasQry := GetNextAlias()
		
		cQuery:= " SELECT DTC.R_E_C_N_O_ RECDTC "
		cQuery+= " FROM " +RetSqlName("DUU")+ " DUU,  "+RetSqlName("DTC")+ " DTC"
		cQuery+= " WHERE DTC_FILIAL = '"+xFilial("DTC")+"' "
		cQuery+= " AND DUU_FILIAL = '"+xFilial("DUU")+"' "
		cQuery+= " AND DUU_FILPND = '"+cFilPnd+"' "
		cQuery+= " AND DUU_NUMPND = '"+cNumPnd+"' "  
		cQuery+= " AND DTC_FILDOC = DUU_FILDOC "
		cQuery+= " AND DTC_DOC    = DUU_DOC "
		cQuery+= " AND DTC_SERIE  = DUU_SERIE "
		cQuery+= " AND DUU.D_E_L_E_T_ = '' "
		cQuery+= " AND DTC.D_E_L_E_T_ = '' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
	EndIf		
	While (cAliasQry)->(!Eof())
		
		DTC->(DbGoTo((cAliasQry)->(RECDTC)))
		RecLock("DTC",.F.)
		If nOpcx == 5
			DTC->DTC_NFENTR := "1"
		ElseIf (nOpcx == 6) .And. DTC->DTC_NFENTR <> "1" 
			DTC->DTC_NFENTR := "2"
			If DT2->DT2_TIPOCO == "06" .And. DT2->DT2_TIPPND == "04"
				DTC->DTC_DOCREE := "2"
			EndIf
		ElseIf nOpcx == 7 .And. DTC->DTC_NFENTR <> "1" 
			DTC->DTC_NFENTR := "3"
			If DT2->DT2_TIPOCO == "06" .And. DT2->DT2_TIPPND == "04"
				DTC->DTC_DOCREE := "1"
			EndIf
		EndIf
		DTC->(MsUnlock())
		lRet := .T.
		
		(cAliasQry)->(DbSkip())
	EndDo
	
	(cAliasQry)->(DbCloseArea())

	RestArea(aArea)
Else
	lRet := .T.
EndIf

If !lRet
	If DT2->DT2_TIPOCO == "06" .And. DT2->DT2_TIPPND $ '03/02'  //Pendencia Sobra ou Avaria
		lRet:= .T.
	EndIf
EndIf
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA540Con³ Autor ³ Katia                 ³ Data ³21.02.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza Conciliacao de Sobras e Faltas                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA540Con(cAlias, nReg, nOpcx,cNumNfc,cSerNfc)           

Local aArea   := GetArea()  
Local cQuery  := ""
Local cFilCon := ""
Local cNumCon := "" 
Local cAliasQry:= ""
Local lRet     := .F.
   
Default cNumNfc:= ""
Default cSerNfc:= ""

//--- Para visualizar a conciliação, busca sempre a ultima Conciliação efetuada da Pendencia,
//--- No caso de Notas, deve-se utilizar a opção Visualizar Conciliação dentro da opção NF Avaria.          
cAliasQry := GetNextAlias()
cQuery := " SELECT R_E_C_N_O_ REC, DYZ_DATCON"
cQuery += " FROM " + RetSqlName("DYZ") 
cQuery += " WHERE DYZ_FILIAL ='" + xFilial("DYZ") + "'"
cQuery += "   AND DYZ_FILPND ='" + DUU->DUU_FILPND + "'"
cQuery += "   AND DYZ_NUMPND ='" + DUU->DUU_NUMPND + "'"
If !Empty(cNumNfc)
	cQuery += "   AND DYZ_NUMNFC ='" + cNumNfc + "'"
	cQuery += "   AND DYZ_SERNFC ='" + cSerNfc + "'"
EndIf	
cQuery += "   AND D_E_L_E_T_=' '"
cQuery += "   ORDER BY DYZ_DATCON DESC "		
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		
If (cAliasQry)->(!Eof()) .And. (cAliasQry)->REC > 0
	DYZ->( DbGoto( (cAliasQry)->REC ) )
	lRet:= .T.     
EndIf          
(cAliasQry)->( dbCloseArea() )
          
If lRet     
	If DYZ->DYZ_STACON == '4'              //Conciliado Item
		cStaCon:= '3'                      //Conciliado
	Else
		cStaCon:= DYZ->DYZ_STACON
	EndIf    
	cFilCon:= DYZ->DYZ_FILCON
	cNumCon:= DYZ->DYZ_NUMCON

	If cStaCon == '3'    ////Posiciona no registro principal 
		DYZ->(DbSetOrder(2))  
		DYZ->(DbSeek(xFilial("DYZ")+ cFilCon + cNumCon + cStaCon ))
	EndIf	
	
	//Enviar Recno para que nao haja problema na visualizacao da ID. Produto da rotina. 
	TMSA541Mnt('DYZ',DYZ->(RECNO()),2)    
EndIf

RestArea(aArea)     
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA540DYZ³ Autor ³ Katia                 ³ Data ³14.07.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualizacao dos registros de Conciliacao                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function Tms540DYZ(nOpcSel)           

Local aArea    := GetArea()  
Local lRet     := .T.
Local cQuery   := ""

Default nOpcSel:= 0
          
cAliasQry := GetNextAlias()

If nOpcSel == 5 .Or. nOpcSel == 6  //Indenizar ou Encerrar 
	cQuery := " UPDATE " + RetSqlName("DYZ")
	cQuery += " SET DYZ_STACON = '5', DYZ_CODMTC ='" +  M->DUU_CODMTC + "'" + ", DYZ_DATCON = " + Dtos(dDataBase) + ""
	cQuery += " WHERE DYZ_FILIAL ='" + xFilial("DYZ") + "'"
	cQuery += "   AND DYZ_FILPND ='" + M->DUU_FILPND + "'"
	cQuery += "   AND DYZ_NUMPND ='" + M->DUU_NUMPND + "'"
	cQuery += "   AND DYZ_STACON = '1' "  //Pendente
	cQuery += "   AND D_E_L_E_T_ = ' ' "		
	TCSqlExec( cQuery )
ElseIf nOpcSel == 7 //Estornar
	cQuery := " UPDATE " + RetSqlName("DYZ")
	cQuery += " SET DYZ_STACON = '1', DYZ_CODMTC = ' ', DYZ_DATCON = ' ' "
	cQuery += " WHERE DYZ_FILIAL ='" + xFilial("DYZ") + "'"
	cQuery += "   AND DYZ_FILPND ='" + M->DUU_FILPND + "'"
	cQuery += "   AND DYZ_NUMPND ='" + M->DUU_NUMPND + "'"
	cQuery += "   AND DYZ_STACON = '5' "  //Encerrado
	cQuery += "   AND D_E_L_E_T_ = ' ' "		
	TCSqlExec( cQuery )
Else
	cQuery := " SELECT COUNT(*) NTOTREG"
	cQuery += " FROM " + RetSqlName("DYZ")
	cQuery += " WHERE DYZ_FILIAL ='" + xFilial("DYZ") + "'"
	cQuery += "   AND DYZ_FILPND ='" + M->DUU_FILPND + "'"
	cQuery += "   AND DYZ_NUMPND ='" + M->DUU_NUMPND + "'"
	cQuery += "   AND DYZ_STACON = '1' "  //Pendente
	cQuery += "   AND D_E_L_E_T_ = ' ' "		
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)		
	If (cAliasQry)->(!Eof()) .And. (cAliasQry)->NTOTREG > 0
		lRet:= .F.
	EndIf
	(cAliasQry)->( dbCloseArea() )     		
EndIf	

RestArea(aArea)     
Return lRet

/*
/====================================================================================================================
{Protheus.doc} A540RetMER
//           - Exibição da Tela Para Escolha de uma ação após a ocorrência de Retorno de Mercadoria
@author  : Leandro Paulino
@since   : 28/04/2017
@version : 1.000
@type function
/====================================================================================================================
*/
Function  A540RetMER()

Local oDlgRet 	:= NIL
Local oBut1		:= NIL
Local oBut2		:= NIL
Local oBut3		:= NIL

//Variáveis Privates para uso no TMSA050
Private cNumLotUso  := CriaVar('DTC_LOTNFC',.F.)
Private Inclui		:= .T.


DEFINE MSDIALOG oDlgRet TITLE STR0022 FROM 06,0 TO 20,61 OF oMainWnd  //--Pendência de Retorno de Mercadoria...// "Tela"
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

@ 01, 01 SAY STR0020 + chr(13)+chr(10) + ;			 //--'A Pendência de "Retorno de Mercadoria" foi encerrada com sucesso.' 
			 STR0021								//--' Escolha a ação a ser realizada realizada para a mercadoria, através dos botões abaixo.'
@ 02, 01 TO 87,243 LABEL '' OF oDlgRet   PIXEL // Linha

oBut2:= TButton():New( 090, 156, STR0023		,oDlgRet, {||TMSA050Mnt('DTC',0,3,.T.)}	, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. )		//--"Entrada Dc.Cli."
oBut1:= TButton():New( 090, 111, STR0024		,oDlgRet, {||Tmsa460Mnt('DT5',0,3 )}	, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. ) 		//--"Solict.Coleta"
oBut3:= TButton():New( 090, 201, STR0025		,oDlgRet, {||oDlgRet:End()}	, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. )					//--"Fechar"

oBut1:SetFocus()

ACTIVATE MSDIALOG oDlgRet CENTERED  

Return NIL

/*/{Protheus.doc} TMSA540DUU
//TODO Função para carregamento dos campos da DUU no array para performance. 
@author Alessandra.Cavalcante
@since 21/05/2018
@param aNoFields
@type function
/*/
Static Function TMSA540DUU(aNoFields)
Local nCont     := 0
Local aDUUStru  := FwFormStruct(2,"DUU")
      
Default aSx3DUU := {}
Default aNoFields := {}
 
If Len(aSx3DUU) == 0

	For nCont := 1 to Len(aDUUStru:aFields)	
		If	Ascan(aNoFields, { |x| x == AllTrim(aDUUStru:aFields[nCont][1]) } ) == 0   
				aAdd(aSx3DUU, { aDUUStru:aFields[nCont][1], GetSX3Cache(aDUUStru:aFields[nCont][1], "X3_PROPRI"), GetSX3Cache(aDUUStru:aFields[nCont][1],"X3_FOLDER" )  })					
		
		EndIf				
	Next nCont
EndIf

Return aSx3DUU


/*/{Protheus.doc} TMS540DUDS
//TODO Função para retornar Status da DUD.
@author Felipe Barbiere
@since 27/0/2020
@param cViagem, lTransito
@type function
/*/
Static Function TMS540DUDS(cViagem, lTransito)

Local aArea    := GetArea()
Local aAreaDTQ := DTQ->(GetArea())
Local cDUDStat := "1"

Default cViagem := ""
Default lTransito := .F.

DTQ->(DbSetOrder(1))
If DTQ->(DbSeek(xFilial("DTQ") + cViagem)) .And. (DTQ->DTQ_STATUS $  "1,2,5" )
	lTransito := .T.
	If DTQ->DTQ_STATUS = '2'
		cDUDStat := '2'
	ElseIf DTQ->DTQ_STATUS $ '1/5'
		cDUDStat := '3'
	Else
		cDUDStat := '1'
	EndIf
EndIf

RestArea(aAreaDTQ) 
RestArea(aArea)

Return cDUDStat
