#INCLUDE 'TMSA370.CH'
#INCLUDE 'PROTHEUS.CH'

Static lEAIFunOK  := (FindFunction("GETROTINTEG") .And. FindFunction("FwHasEAI") .And. Len(GetSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0) 
Static cTmsErp    := SuperGetMV("MV_TMSERP",,'0') //  // Parametro assume 0=Integração Nativa TMS Protheus; ou '1'- TMS X DATASUL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA370  ³ Autor ³ Antonio C Ferreira    ³ Data ³30.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Registro de Indenizacoes                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA370()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                  ATUALIZACOES - VIDE SOURCE SAFE                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA370()

Local aCores    := {}
Local aSetKey   := {}
Local cFilMbrow := ""

Private cCadastro := STR0001 //'Registro de Indenizacoes'
Private aRotina	  := MenuDef()

AAdd( aCores,{ "DUB_STATUS=='1'" ,'BR_VERDE'   } )	//-- Em Aberto
AAdd( aCores,{ "DUB_STATUS=='2'" ,'BR_AMARELO' } )	//-- Autorizacao de Pagto
AAdd( aCores,{ "DUB_STATUS=='3'" ,'BR_AZUL'    } )	//-- Encerrada - Indenizado
AAdd( aCores,{ "DUB_STATUS=='4'" ,'BR_MARROM'  } )	//-- Encerrada - Nao Indenizado

AAdd( aSetKey, { VK_F12 , { || Pergunte("TMA370",.T.) } } )		

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)	
If ExistBlock("TM370FIL")
	cFilMbrow := ExecBlock("TM370FIL",.F.,.F.)
	If(Valtype(cFilMbrow) != "C")
		cFilMbrow := ""
	EndIf
EndIf

mBrowse( 6,1,22,75,'DUB',,,,,,aCores,,,,,,,,cFilMBrow)

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)	

RetIndex('DUB')

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA370Mnt³ Autor ³ Antonio C Ferreira    ³ Data ³30.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Registro de Indenizacoes                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA370Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA370Mnt( cTmsAlias, nTmsReg, nTmsOpcz, aEstrutura )

Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local lViagem
Local aAreaDUB    := DUB->(GetArea())
Local nNumDec     := TamSX3("C6_VALOR")[2]
Local nGetLin     := 0
Local aTmsVisual  := {}
Local aTmsAltera  := {}
Local bVerViagem  := {|| TmsVisViag(M->DUB_FILORI,M->DUB_VIAGEM) }
Local aTmsButtons := { {"CARGA", bVerViagem, STR0026 , STR0027 } } //"Viagem - <F4>"
Local aTelOld     := Iif( Type('aTela') == 'A', aClone( aTela ), {} )
Local aGetOld     := Iif( Type('aGets') == 'A', aClone( aGets ), {} )
Local nOpca       := 0
Local nOpcGet     := If(INCLUI.Or.ALTERA, 3, 2)
Local oTmsEnch

//-- Dialog
Local cCadOld     := Iif( Type('cCadastro') == 'C', cCadastro, '' )
Local oTmsDlgEsp
//-- GetDados
Local aHeaOld	  := Iif( Type('aHeader') == 'A', aClone( aHeader ), {} )
Local aColOld	  := Iif( Type('aCols') == 'A', aClone( aCols ), {} )
Local aNoFields	  := {}
Local aYesFields  := {}
Local bSeekFor
Local nMaximoLinhas
//-- Controle de dimensoes de objetos
Local aObjects	  := {}
Local aInfo		  := {}
//-- Checkbox
Local oAllMark

Private nTmsOpcx
Private cViagem   := Space(Len(DUB->DUB_VIAGEM))

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]
//-- GetDados
Private aHeader	  	:= {}
Private aCols		:= {}
Private oTmsGetD
Private aTmsPosObj	:= {}
Private aAlter		:= {}                       

If Type("aRotina") == "U"
	Private aRotina	:= MenuDef()
EndIf

Default cTmsAlias   := 'DUB'
Default nTmsReg		:= 1
Default nTmsOpcz	:= 2
Default aEstrutura  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Informe se mostrara os lancamentos contabeis para o processamento   ³
//³ mv_par02 - Informe se aglutinara os lancamentos contabeis para o processamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cCadastro:= STR0001 //'Registro de Indenizacoes'

nTmsOpcx := aRotina[nTmsOpcz,4] 

nTmsOpcz := If(nTmsOpcz >= 5 .And. nTmsOpcz <= 7, 4, nTmsOpcz)   // Para poder alterar na GetDados

//-- Configura variaveis da Enchoice
RegToMemory( cTmsAlias, INCLUI )

//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
If nTmsOpcx <> 2
	If !TMSAVerAge("1",DUB->DUB_FILDOC,DUB->DUB_DOC,DUB->DUB_SERIE,,,,,,,,,"2",.T.,.T.)
		Return .F.
	EndIf
EndIf

If (nTmsOpcx == 4 .Or. nTmsOpcx == 7) .And. !Empty(M->DUB_NUMLRB)
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help("",1,"TMSA37015") // Alteracao nao permitida pois ja foi solicitado reembolso para esta Indenizacao ... 
	Return ( .F. )
EndIf

AAdd( aTmsVisual, 'DUB_NUMRID' )  
AAdd( aTmsVisual, 'DUB_DATRID' ) 
AAdd( aTmsVisual, 'DUB_HORRID' )
AAdd( aTmsVisual, 'DUB_COMSEG' )
AAdd( aTmsVisual, 'DUB_DESSEG' )
AAdd( aTmsVisual, 'DUB_MOTIVO' )
If!(SuperGetMv("MV_TMSFATU",,.F.,))//Parametro para a geração de títulos a partir de um registro de indenização seja o mesmo da filial do registro utilizando o campo DUB_FILRID como referência e não a filial atual.
	AAdd( aTmsVisual, 'DUB_FILRID' )
Endif
AAdd( aTmsVisual, 'DUB_FILORI' )
AAdd( aTmsVisual, 'DUB_VIAGEM' )
AAdd( aTmsVisual, 'DUB_CODOCO' )
AAdd( aTmsVisual, 'DUB_DESOCO' ) 
AAdd( aTmsVisual, 'DUB_NUMPRO' ) 

aTmsAltera := {}
If INCLUI .Or. (ALTERA .And. Empty(M->DUB_VIAGEM))
   	aTmsAltera := {}
   	AAdd( aTmsAltera, 'DUB_DATRID' ) 
   	AAdd( aTmsAltera, 'DUB_HORRID' )
   	AAdd( aTmsAltera, 'DUB_COMSEG' )
   	AAdd( aTmsAltera, 'DUB_MOTIVO' )
   	AAdd( aTmsAltera, 'DUB_CODOCO' )
   	AAdd( aTmsAltera, 'DUB_NUMPRO' )
ElseIf nTmsOpcx == 6 // Autoriza Pagamento
   	AAdd( aTmsAltera, 'DUB_NUMPRO' )
ElseIf nTmsOpcx == 9
	AAdd( aTmsAltera, "DUB_MOTIVO")	
EndIf	        

aNoFields := aClone( aTmsVisual )

If nTmsOpcx <> 6  
   	AAdd( aNoFields, "DUB_AUTPAG" )
EndIf
If nTmsOpcx <> 7
   	AAdd( aNoFields, "DUB_ESTORN" )
EndIf
If nTmsOpcx <> 2                                                                            
	AAdd( aNoFields, "DUB_NUMLRB" ) 
   	AAdd( aNoFields, "DUB_DATLRB" )
   	AAdd( aNoFields, "DUB_DATREB" ) 
   	AAdd( aNoFields, "DUB_VALREB" ) 
EndIf            

If nTmsOpcx == 4 
   	aAlter := {}
	AAdd( aAlter, "DUB_CODCLI" )
	AAdd( aAlter, "DUB_LOJCLI" )
	AAdd( aAlter, "DUB_VALPRE" )
	AAdd( aAlter, "DUB_DATVEN" )
	AAdd( aAlter, "DUB_CERVIS" )	 
	aTMSAltera :=  {}
ElseIf nTmsOpcx == 6 //-- Autoriza Pagto
   	aAlter := {}
	AAdd( aAlter, "DUB_AUTPAG" )
	AAdd( aAlter, "DUB_VALPRE" )
	AAdd( aAlter, "DUB_DATVEN" )
	AAdd( aAlter, "DUB_CERVIS" )	 
ElseIf nTmsOpcx == 7 //-- Estorno Pagto
	aAlter := {}
	AAdd( aAlter, "DUB_ESTORN" )
EndIf       

If Existblock('TM370CPO')
	ExecBlock('TM370CPO',.F.,.F.,{nTMSOpcx})
EndIf

SE2->(DbSetOrder(6)) 

If nTmsOpcx == 4 // Alterar
	bSeekFor := {|| DUB->DUB_STATUS == "1" .And. DUB->DUB_STAREB == "1"}       		
ElseIf nTmsOpcx == 6  // Autorizar Pagto.
    bSeekFor := {|| DUB->DUB_STATUS == "1" }
ElseIf nTmsOpcx == 7  // Estornar Pagto.
    If cTmsErp == "0"
         bSeekFor := {|| DUB->DUB_STATUS == "2" .And. SE2->(MsSeek(xFilial("SE2")+DUB->(DUB_CODFOR+DUB_LOJCLI+DUB_PREIND+DUB_NUMIND) )) .And.;
                        !Empty(DUB->(SaldoTit(DUB_PREIND,DUB_NUMIND,'1',DUB_TIPIND,,"P",DUB_CODFOR,,,,DUB_LOJCLI,))) }
    Else
         bSeekFor := {|| DUB->DUB_STATUS == "2" .And. !Empty(DUB->(SaldoTit(DUB_PREIND,DUB_NUMIND,'1',DUB_TIPIND,,"P",DUB_CODFOR,,,,DUB_LOJCLI,))) }
    EndIf
ElseIf nTmsOpcx == 9
	bSeekFor := {|| DUB->DUB_STATUS== "1" }
ElseIf nTmsOpcx == 10
	bSeekFor := {|| DUB->DUB_STATUS== "4" }
EndIf    

//-- Configura variaveis da GetDados
TMSFillGetDados( nTmsOpcx, 'DUB', 1, xFilial( 'DUB' ) + M->DUB_NUMRID, { ||  DUB->(DUB_FILIAL + DUB_NUMRID) },;
											bSeekFor, aNoFields, aYesFields )

If Len(aCols)==1 .And. Empty(aCols[1,1]) .And. nTmsOpcx != 3 // Nao Registrar
	If nTmsOpcx == 4 // Alterar
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
 		Help(' ', 1, 'TMSA37008')	//-- Nenhum registro encontrado para Alterar!
      	Return .T.
   	ElseIf nTmsOpcx == 6 // Autorizar Pagto
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
     	Help(' ', 1, 'TMSA37005')	//-- Nenhum registro encontrado para Autorizar Pagamento!
      	Return .T.
   	ElseIf nTmsOpcx == 7 // Estornar Pagto
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
     	Help(' ', 1, 'TMSA37006')	//-- Nenhum registro encontrado para Estornar Pagamento!
      	Return .T.
   	ElseIf nTmsOpcx == 9 // Encerrar
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
      	Help(' ', 1, 'TMSA37018') //-- Nenhum registro encontrado para Encerrar!
      	Return .T.
   	ElseIf nTmsOpcx == 10 // Estornar Encerr.
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
      	Help(' ', 1, 'TMSA37019') //-- Nenhum registro encontrado para Estornar!
      	Return .T.
   	EndIf
EndIf   																			 

//-- Inicializa o item da getdados se a linha estiver em branco.
If Len( aCols ) == 1 .And. Empty( GDFieldGet( 'DUB_ITEM', 1 ) )
	GDFieldPut( 'DUB_ITEM', StrZero(1,Len(DUB->DUB_ITEM)), 1 )
EndIf

// Forca EOF() para exibir somente documentos sem viagem na funcao TMSCtrc() no SXB DL4
DTQ->(DbSetOrder(1))
DTQ->(DbGoBottom())
DTQ->(DbSkip())

nMaximoLinhas := Len(aCols)  // Limitar linhas

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 110, 140, .T., .T. } )
AAdd( aObjects, { 160, 160, .T., .T. } ) 
AAdd( aObjects, { 030, 030, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)

SetKey( VK_F4 , bVerViagem )

DEFINE MSDIALOG oTmsDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oTmsEnch := MsMGet():New( cTmsAlias, nTmsReg,If(nTmsOpcx == 6 .Or. nTmsOpcx == 9,4,nOpcGet),,,, aTmsVisual, aTmsPosObj[1], aTmsAltera,,,,,,,.T. )
	
   	oPanel := tPanel():New(aTmsPosObj[3,1],aTmsPosObj[3,2],"",oTmsDlgEsp,,,,,CLR_WHITE,(aTmsPosObj[3,4]-aTmsPosObj[3,2]), (aTmsPosObj[3,3]-aTmsPosObj[3,1]), .T.) 
    
	nGetLin := 005
	@ nGetLin,005  SAY STR0016 SIZE 050,009 OF oPanel 	PIXEL COLOR CLR_BLUE	//"Total Carga :"
	@ nGetLin,040  SAY oSAY1 VAR 0 PICTURE TM(0,16,nNumDec) SIZE 050,009 OF oPanel 	PIXEL
	@ nGetLin,095  SAY STR0017 SIZE 050,009 OF oPanel 	PIXEL COLOR CLR_BLUE	//"Total Indenizacao :"
	@ nGetLin,135  SAY oSAY2 VAR 0 PICTURE TM(0,16,nNumDec) SIZE 050,009 OF oPanel	PIXEL
	@ nGetLin,195  SAY STR0018 SIZE 050,009 OF oPanel 	PIXEL COLOR CLR_BLUE	//"Total Indenizado :"
	@ nGetLin,245  SAY oSAY3 VAR 0 PICTURE TM(0,16,nNumDec) SIZE 050,009 OF oPanel	PIXEL
	@ nGetLin,295  SAY STR0019 SIZE 050,009 OF oPanel 	PIXEL COLOR CLR_BLUE	//"Saldo a Indenizar :"
	@ nGetLin,345  SAY oSAY4 VAR 0 PICTURE TM(0,16,nNumDec) SIZE 050,009 OF oPanel	PIXEL

	oTmsDlgEsp:Cargo := {|n1,n2,n3,n4| oSay1:SetText(n1), oSay2:SetText(n2), oSay3:SetText(n3), oSay4:SetText(n4) }
	
	oTmsGetD :=	MSGetDados():New(aTmsPosObj[ 2, 1 ], aTmsPosObj[ 2, 2 ],aTmsPosObj[ 2, 3 ], aTmsPosObj[ 2, 4 ], If(nTmsOpcx == 2 .Or. nTmsOpcx == 9 .Or. nTmsOpcx == 10, 2, 3), 'TMSA370LinOk','AllWaysTrue',"+DUB_ITEM",  (nTmsOpcx==2 .Or. nTmsOpcx==9 .Or. nTmsOpcx==10) .Or. Empty(M->DUB_VIAGEM) , aAlter ,  ,  ,nMaximoLinhas,  ,  ,  ,  ,  )
	oTmsGetD:oBrowse:bDelete := { || .F. } //-- Nao permitir deletar na getdados
    
   	TMSA370Tot(oTmsDlgEsp, aCols, nTmsOpcx)
     
ACTIVATE MSDIALOG oTmsDlgEsp ON INIT EnchoiceBar(oTmsDlgEsp,{||Iif(oTmsGetD:TudoOk() .And. TmsA370TOk(nTmsOpcx), (nOpca := 1,oTmsDlgEsp:End()), (nOpca :=0, .F.))},{||nOpca:=0,oTmsDlgEsp:End()},, aTmsButtons )

SetKey( VK_F4 , NIL )                          

If (nTmsOpcx != 2) .And. (nOpcA == 1)
	TMSA370Grv( M->DUB_NUMRID, nTmsOpcx )
	If __lSX8
		ConfirmSX8()
	EndIf		
ElseIf __lSX8
	RollBackSX8()	
EndIf

If !Empty( cCadOld )
	cCadastro := cCadOld
EndIf

If !Empty( aTelOld )
	aTela	:= aClone( aTelOld )
	aGets := aClone( aGetOld )
EndIf

If !Empty( aHeaOld )
	aHeader := aClone( aHeaOld )
	aCols	  := aClone( aColOld )
EndIf

RestArea( aAreaDUB )

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

Return nOpcA

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA370Tot³ Autor ³ Antonio C Ferreira    ³ Data ³03.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Totalizar o Rodape do Dialogo                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA370Tot(Exp1, Exp2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto da Dialog                                   ³±± 
±±³          ³ ExpC1 = aCols                                              ³±±
±±³          ³ ExpN1 = Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA370Tot(oTmsDlgEsp, aCols, nTmsOpcx)

Local nA
Local nTValInde	 := 0
Local nTValCar	 := 0
Local nTValRid	 := 0
Local nTValPre	 := 0
Local lTM370COLS := ExistBlock('TM370COLS')

Default nTmsOpcx := oTmsGetD:oBrowse:nOpc
                          
If oTmsDlgEsp == NIL
	oTmsDlgEsp := GetWndDefault()
	If ValType(oTmsDlgEsp:Cargo) != "B" 
		oTmsDlgEsp := oTmsDlgEsp:oWnd
	EndIf
EndIf

If ValType(oTmsDlgEsp:Cargo) != "B" 
   	Return .F.
EndIf

For nA := 1 to Len(aCols)   

   //-- Ponto de Entrada permite alterar o conteudo dos campos do aCols		
   	If lTM370COLS
		ExecBlock('TM370COLS',.F.,.F.,{aCols,nTmsOpcx,nA})   	
   	EndIf
   
	GDFieldPut( 'DUB_VALIND', TMSA370Val( nA ), nA )

   	nTValCar += GDFieldGet( 'DUB_VALCAR', nA ) 
   	nTValRid += GDFieldGet( 'DUB_VALIND', nA ) 	 
   	nTValPre += GDFieldGet( 'DUB_VALPRE', nA )
   
   	If GDFieldGet( 'DUB_STATUS', nA ) == "3" 
		nTValInde += GDFieldGet( 'DUB_VALIND', nA )
	EndIf
Next

If (nTmsOpcx == 7) //-- Estorno
	Eval(oTmsDlgEsp:Cargo, nTValCar, nTValPre, nTValPre, (nTValCar-nTValPre))
Else
	Eval(oTmsDlgEsp:Cargo, nTValCar, (nTValRid-nTValInde), nTValInde, (nTValCar-nTValRid))
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA370Whe³ Autor ³ Antonio C Ferreira    ³ Data ³06.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao dos Campos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA370Whe()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA370Whe()

Local cCampo := ReadVar()
Local lRet   := .T.

If (cCampo $ "M->DUB_FILDOC|M->DUB_DOC|M->DUB_SERIE") .And. !Empty(M->DUB_VIAGEM)
	lRet := .F.
ElseIf (cCampo $ "M->DUB_DATVEN") .And. !ALTERA .And. !INCLUI .And. (nTmsOpcx != 6) // Autoriza Pagto
   	lRet := .F.   
EndIf   

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA370Vld³ Autor ³ Antonio C Ferreira    ³ Data ³02.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes do sistema                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA370Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA370Vld(lGrava_aCols)

Local cTipoFrete, cBusca
Local cCampo	:= If(lGrava_aCols != NIL .And. lGrava_aCols, "M->DUB_SERIE", ReadVar())
Local lRet		:= .T.
Local nPFilDoc  := GDFieldPos( 'DUB_FILDOC' )
Local nPDoc     := GDFieldPos( 'DUB_DOC'    )
Local nPSerie   := GDFieldPos( 'DUB_SERIE'  )
Local nPCliente := GDFieldPos( 'DUB_CODCLI' )
Local nPLoja    := GDFieldPos( 'DUB_LOJCLI' )  
Local nPosVlr   := GDFieldPos( 'DUB_VALPRE' )  

// Caso nao seja a Validacao e sim gravacao dos dados no acols...
If (lGrava_aCols!=NIL .And. lGrava_aCols)
	M->DUB_SERIE := aCols[n][nPSerie]
EndIf
	
If cCampo $ "M->DUB_CODCLI|M->DUB_LOJCLI"
	If cCampo == "M->DUB_CODCLI"
		cCodCli := M->DUB_CODCLI
		cLojCli := aCols[n][nPLoja]
		cBusca  := cCodCli
	Else
		cCodCli := aCols[n][nPCliente]
		cLojCli := M->DUB_LOJCLI
		cBusca  := cCodCli + cLojCli
	EndIf
	
	If (cCodCli + cLojCli != SA1->(A1_COD + A1_LOJA))
		SA1->(DbSetOrder(1))
		lRet := SA1->(MsSeek(xFilial("SA1") + cBusca))
		
		cLojCli := If(cCampo == "M->DUB_CODCLI", SA1->A1_LOJA, cLojCli)
	EndIf
	
	If (cCodCli + cLojCli == GetMV("MV_CLIGEN"))
		Help(' ', 1, 'TMSA37010')    // Nao pode selecionar o Cliente Generico neste cadastro!
		lRet := .F.
	EndIf
	
	If lRet
		aCols[n][nPLoja] := cLojCli
		
		cTipoFrete := DT6->DT6_TIPFRE    // Ja posicionado pelo DUB_FILDOC / DUB_DOC / DUB_SERIE.
		
		DTC->(DbSetOrder(3))   // DTC_FILIAL + DTC_FILDOC + DTC_DOC + DTC_SERIE
		
		If DTC->(MsSeek(xFilial("DTC") + aCols[n][nPFilDoc] + aCols[n][nPDoc] + aCols[n][nPSerie]))
			
			// Verifica se o Cliente e Loja corresponde ao 4 (Quatros) Clientes e Lojas possiveis do documento.
			If .NOT. ( ((cTipoFrete == "1") .And. ((cCodCli + cLojCli) == DTC->(DTC_CLIREM + DTC_LOJREM))) /* CIF */ .Or.;
				((cTipoFrete == "2") .And. ((cCodCli + cLojCli) $ DTC->(DTC_CLICON + DTC_LOJCON + "|" + DTC_CLIDES + DTC_LOJDES))) /* FOB */ .Or.;
				((cCodCli + cLojCli) == DTC->(DTC_CLIDPC + DTC_LOJDPC)) )  // Despachante
				
				Help(' ', 1, 'TMSA37002',,STR0014 + cCodCli + STR0015 + cLojCli,5,11)		//-- Cliente e Loja nao encontrado no Documento informado ! //'Cliente : '###' Loja : '
				
				lRet := .F.
			EndIf
			
		EndIf
		
	EndIf
	
ElseIf cCampo $ "M->DUB_AUTPAG"
	// Obtem o CGC para pesquisar o Fornecedor
	SA1->(DbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1") + GDFieldGet('DUB_CODCLI',N) + GDFieldGet('DUB_LOJCLI',N)))
	
	If Empty(SA1->A1_CGC)
		Help(' ', 1, 'TMSA37009',,STR0014 + GDFieldGet('DUB_CODCLI',N) + STR0015 + GDFieldGet('DUB_LOJCLI',N),5,11) //"CGC no Cadastro do Cliente esta em branco!"###"Cliente: "###"Loja: "
		lRet := .F.
	EndIf
ElseIf cCampo == "M->DUB_VALPRE"
	If GdFieldPos("DUB_VALCAR") > 0
		lRet := M->DUB_VALPRE <= GdFieldGet("DUB_VALCAR", n)
	EndIf        
	
	If lRet 
		aCols[n][nPosVlr]:= M->DUB_VALPRE
		TMSA370Tot(NIL, aCols, nTmsOpcx)    // Totaliza     
	EndIf 
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSSomaRid³ Autor ³ Antonio C Ferreira    ³ Data ³30.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Soma as Notas para obter o Valor da Indeniz. menos seguro. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSSomaSin(Exp1, Exp2, Exp3, Exp4, Exp5)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  Exp1 = Filial Documento                                   ³±±
±±³          ³  Exp2 = Numero Documento                                   ³±± 
±±³          ³  Exp3 = Serie  Documento                                   ³±±
±±³          ³  Exp4 = Valor                                              ³±±
±±³          ³  Exp5 = Seguro                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSSomaRid(cFilDoc, cDoc, cSerie, nTValor, nSeguro)

Local aArea, aAreaDTC, nValor

aArea    := GetArea()
aAreaDTC := DTC->(GetArea())

DbSelectArea("DTC")
DbSetOrder(3)   // DTC_FILIAL + DTC_DOC + DTC_SERIE
MsSeek(xFilial("DTC") + cFilDoc + cDoc + cSerie)

nValor  := 0
nSeguro := 0

DbEval({||  (nValor += DTC_VALOR) },, {|| !eof() .And. (DTC_FILDOC==cFilDoc) .And. (DTC_DOC==cDoc) .And. (DTC_SERIE==cSerie) })

nTValor := nValor

// Obtem o desconto do seguro pago pelo cliente.
DU7->(DbSetOrder(1))
nSeguro := Posicione("DU7",1,xFilial("DU7") + cFilDoc + cDoc + cSerie, "DU7_SEGCLI")

nValor *= (100 - nSeguro)/100  // Subtrai no Valor a porcentagem do seguro

RestArea( aAreaDTC ) 
RestArea( aArea )

Return nValor

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA370Lin³ Autor ³ Antonio C Ferreira    ³ Data ³30.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes da linha da GetDados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA370Lin()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA370LinOk()

Local lRet     := .T.                   
Local nTmsOpcx := oTmsGetD:oBrowse:nOpc                      

If nTmsOpcx <> 2 .And. nTmsOpcx <> 9 .And. nTmsOpcx <> 10
	//-- Nao avalia linhas deletadas.
	If !GDdeleted(n) 
		If nTmsOpcx != 7 //-- Estorno
			lRet := MaCheckCols(aHeader,aCols,n)
		EndIf		
		If lRet
			//-- Analisa se ha itens duplicados na GetDados.
			lRet := GDCheckKey( { 'DUB_FILDOC', 'DUB_DOC', 'DUB_SERIE' }, 4 )
			If lRet .And. GDFieldPos('DUB_AUTPAG') > 0 .And. GDFieldGet('DUB_AUTPAG', n) == "1"
				If Empty(GDFieldGet('DUB_VALPRE', n))
					Help(' ', 1, 'TMSA37016')    // Valor do Prejuizo tem que estar preenchido!
		   		   	lRet := .F.
				ElseIf Empty(GDFieldGet('DUB_DATVEN', n)) .And. cTMSERP == "0"
					Help(' ', 1, 'TMSA37003')    // Data de Vencimento tem que estar preenchido!
			   	   	lRet := .F.
				EndIf			
			EndIf
		EndIf		  
	EndIf
	If lRet
		TMSA370Tot(NIL, aCols, nTmsOpcx)    // Totaliza     
	EndIf
EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA370TOk³ Autor ³ Antonio C Ferreira    ³ Data ³25.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tudo Ok da GetDados                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tmsa370TOk(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA370TOk(nTmsOpcx)

Local lRet	    := .T.      
Local nAchou    := 0
Local lTM370TOK := ExistBlock('TM370TOK')

If nTmsOpcx <> 2 .And. nTmsOpcx <> 9 .And. nTmsOpcx <> 10
	//-- Analisa se os campos obrigatorios da Enchoice foram informados.
	lRet := Obrigatorio( aGets, aTela )

	//-- Analisa o linha ok.
	If lRet
		lRet := TMSA370LinOk()
	EndIf
	//-- Analisa se todas os itens da GetDados estao deletados.
	If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
		Help( ' ', 1, 'OBRIGAT2') //Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
		lRet := .F.
	EndIf       

	If lRet .And. nTmsOpcx == 6
		nAchou := Ascan(aCols, {|x| GdFieldGet('DUB_AUTPAG') == '1'})
	   	If nAchou == 0
    		Help('',1,'TMSA37011') // Pagamento nao efetuado, pois nenhum item foi autorizado para pagto.
	   	EndIf
	EndIf   

	If lRet .And. nTmsOpcx == 7
	   	nAchou := Ascan(aCols, {|x| GdFieldGet('DUB_ESTORN') == '1'})
	   	If nAchou == 0
    	   	Help('',1,'TMSA37012') // Estorno nao efetuado, pois nenhum item foi marcado do para Estorno
	   	EndIf
	EndIf
	If lRet .And. lTM370TOK
		lRet := ExecBlock('TM370TOK',.F.,.F.,{nTmsOpcx})
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA370Grv³ Autor ³ Antonio C Ferreira   ³ Data ³30.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravar dados                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA370Grv( cNumRid, nTmsOpcx )

Local nCntFor
Local cCodForn, cTipo, aAreaSE2,cCondPag, cLojForn := ""
Local nA         	:= 0
Local nCntFo1    	:= 0
Local nX         	:= 0
Local lRet       	:= .T.
Local cSeek      	:= ""
Local cPreInd    	:= ""
Local cNumInd    	:= ""
Local lTM370GRV  	:= ExistBlock('TM370GRV')
Local aDadExcSE2 	:= {}
Local lExibeLanc 	:= .F.
Local lOnline    	:= .F.
Local lBcoPag    	:= .F.
Local aAreaDUU   	:= ''
Local nPosDUUVPR 	:= 0
Local aEAIRet    	:= {}
Local lConfirm   	:= .F.
Local lTmsFAtu		:= SuperGetMv("MV_TMSFATU",,.F.,)

Local lITmsDmd      := SuperGetMv("MV_ITMSDMD",,.F.)
Local aAreaDT6   	:= DT6->(GetArea())
        
Private lMsErroAuto := .F.
Private oDTClass    := Nil

//|
//| Valida se existe a classe de integração EAI Contas Pagar
If Len(GetSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0
   oDTClass := TransportDocumentClass():New()
EndIf 

//--Atualiza as Perguntas
Pergunte('TMA370',.F.)
lExibeLanc := Iif(mv_par01 == 2,.F.,.T.)
lOnline    := Iif(mv_par02 == 2,.F.,.T.)


CursorWait()

DUB->( DbSetOrder( 1 ) )

If	nTmsOpcx == 3 .Or. nTmsOpcx == 4  // Registrar / Alterar
	Begin Transaction
	
	For nA := 1 To Len( aCols )
		If	!GdDeleted(nA)
			
			If	DUB->( MsSeek( xFilial('DUB') + cNumRid + GDFieldGet( 'DUB_ITEM', nA ), .F. ) )
				RecLock('DUB', .F.)
			Else
				RecLock('DUB', .T.)
			EndIf
			
			For nX := 1 To FCount()
				If "FILIAL"$Field(nX)
					FieldPut(nX, xFilial('DUB'))
				Else
					If TYPE("M->"+FieldName(nX)) <> "U"
						FieldPut(nX, M->&(FieldName(nX)))
					EndIf
				EndIf
			Next nX
			
			For nCntFor := 1 To Len(aHeader)
				If	aHeader[nCntFor,10] != 'V'
					FieldPut(FieldPos(aHeader[nCntFor,2]), aCols[nA,nCntFor])
				EndIf
			Next
			
			MSMM(DUB->DUB_CODMTV,,,M->DUB_MOTIVO,1,,,'DUB','DUB_CODMTV')
			
			MsUnLock()
		
			If lTM370GRV
				ExecBlock('TM370GRV',.F.,.F.,{nTmsOpcx})
			EndIf
					
			aAreaDUU := DUU->(GetArea())
			dbSelectArea("DUU")
			dbSetOrder(5)
			If dbSeek(xFilial("DUU")+DUB->DUB_FILRID+DUB->DUB_NUMRID+DUB->DUB_FILDOC+DUB->DUB_DOC+DUB->DUB_SERIE) .And. DUB->DUB_VALIND == 0
				nPosDUUVPR := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DUB_VALPRE' })
				If nPosDUUVPR > 0 
					RecLock( 'DUU', .F.)				
					DUU->DUU_VALPRE := aCols[nA,nPosDUUVPR]
					MsUnlock()
				EndIf
			EndIf			
			RestArea(aAreaDUU)
		Else
			If DUB->( MsSeek( xFilial('DUB') + cNumRid + GDFieldGet( 'DUB_ITEM', nA ), .F. ) )
				RecLock('DUB', .F., .T.)
				DUB->(DbDelete())
				MsUnLock()
				
				MSMM(DUB->DUB_CODMTV,,,,2)
			EndIf
		EndIf
	Next
	End Transaction
	
ElseIf nTmsOpcx == 5  // Estornar (Chamada atraves do Registro de Ocorrencias)

	For nA := 1 To Len( aCols )
		If GDFieldGet( 'DUB_ESTORN', nA ) == "1"
			If DUB->( MsSeek( xFilial('DUB') + cNumRid + GDFieldGet( 'DUB_ITEM', nA ), .F. ) )
				RecLock('DUB', .F., .T.)
				DUB->(DbDelete())
				MsUnLock()
				MSMM(DUB->DUB_CODMTV,,,,2)
				If	lTM370GRV
					ExecBlock('TM370GRV',.F.,.F.,{nTmsOpcx})
				EndIf				
			EndIf
		EndIf
	Next
	
ElseIf nTmsOpcx == 6 // Autoriza Pagamento

	cNatureza := Posicione("DU3",1,xFilial("DU3")+M->DUB_COMSEG,"DU3_NATIND")
	cPrefixo  := DU3->DU3_PREIND
	cTipo     := DU3->DU3_TIPIND
	
	Begin Transaction
	
	Pergunte("FIN050",.F.)
	
	For nA := 1 To Len( aCols )

		If DUB->( MsSeek( xFilial('DUB') + cNumRid + GDFieldGet( 'DUB_ITEM', nA ), .F. ) )

			If GDFieldGet('DUB_AUTPAG',nA) == "1"
					
				// Verifica, cria e posiciona o Cadastro de Fornecedor (SA2)
				TMSA370Frn(GDFieldGet('DUB_CODCLI',nA), GDFieldGet('DUB_LOJCLI',nA), @cCodForn, ,@cLojForn)

				//|
				//| Usa Integração Financeira Protheus quando cTMSERP=="0" ou utiliza a integração com outra Marca
				//| utilizando model de Mensagem Unica EAI para cTMSERP == "1" 
				//|
				If cTMSERP == "0"
				
                     cCondPag := SA2->A2_COND
                     cNumInd  := GetSxENum("SE2", "E2_NUM")
                     ConfirmSX8()
                     
					If !lTmsFAtu //Parametro para a geração de títulos a partir de um registro de indenização seja o mesmo da filial do registro utilizando o campo DUB_FILRID como referência e não a filial atual.
						lRet := A050ManSE2(, cNumInd, cPrefixo, cTipo, , GDFieldGet( 'DUB_VALPRE', nA ) , 0, cCodForn,;
									cLojForn, cNatureza, 1, ,"SIGATMS", date(),,GDFieldGet('DUB_DATVEN',nA),;
									,,,lExibeLanc,lOnline, lBcoPag)
					Else
						lRet := A050ManSE2(, cNumInd, cPrefixo, cTipo, , GDFieldGet( 'DUB_VALPRE', nA ) , 0, cCodForn,;
									cLojForn, cNatureza, 1, ,"SIGATMS", date(),,GDFieldGet('DUB_DATVEN',nA),;
									,GDFieldGet('DUB_FILRID',nA),,lExibeLanc,lOnline, lBcoPag)
			   		EndIf
			   	
			   	//|
			   	//| Dispara Integracao EAI 
			   	//|
				Else
	                  If lEAIFunOK == .T.
	                        If FwHasEAI("TMSA370",.T.,,.T.) == .T.
	
	                             oDTClass:cVIAGEM      := M->(DUB_FILORI+DUB_VIAGEM)
	                             oDTClass:cFILORI      := M->DUB_FILDOC
	                             oDTClass:cTITULO      := M->DUB_DOC + M->DUB_SERIE
	                             oDTClass:nVALORDOC    := GDFieldGet( 'DUB_VALPRE', nA )
	                             oDTClass:nVALORPDG    := 0
	                             oDTClass:nVALORADTO   := 0
	                             oDTClass:cCODCLIENTE  := cCodForn
	                             oDTClass:cLOJCLIENTE  := GdFieldGet( "DUB_LOJCLI", nA )
	                             oDTClass:cFILDEBITO   := cFilAnt
	                             oDTClass:dEMISSAO     := dDataBase
	                             If !Empty(M->DUB_DATVEN)
	                                 oDTClass:dVENCIMENTO  := M->DUB_DATVEN
	                             EndIf
	                             oDTClass:dTRANSACAO   := dDataBase
	                             oDTClass:cHISTORICO   := "Titulo de Indenização de Seguro. Referente a filial/documento " + DUB->DUB_FILDOC + " /" + DUB->DUB_DOC + " /" + DUB->DUB_SERIE + "." 
	                             oDTClass:cEventType   := "upsert"
	                             oDTClass:cTipoMsg     := "3"
	                             oDTClass:cSubTipoMsg  := "301"
	                             
	                             aEAIRet := FwIntegDef("TMSA370",,,,"TMSA370")
	
	                             IF Len(aEAIRet) >=2
	                                  If ("WSCERR" $ aEAIRET[2]) //| Falha na Integração EAI com marca externa.
	                                       aEAIRet[2] := STR0035
	                                  EndIf
	                             EndIf
	                             lRet    := Iif(ValType(aEAIRet) == "U",.F.,aEAIRet[1])
	                             If lRet == .F.
	                                  Aviso(STR0036,aEAIRET[2],{STR0037},2)
	                             Else
	                                  cNumInd := oDTClass:oResultSet:cDocumentNumber
	                                  cTipo   := oDTClass:oResultSet:cDocumentType
	                                  cPrefixo:= Space(TamSx3("DUB_PREIND")[1])
	                             EndIf
	                        Else
	                             lRet    := .F.
	                             Aviso(STR0036,STR0034,{STR0037},2)
	                        EndIf
	                   Else
	                        lRet := .F.
	                        Aviso(STR0036,STR0035,{STR0037},2)
	                   Endif
				
				Endif
				//|
				//| Atualiza DUB com a informação do titulo gerado.
				//|
				If lRet
					DUB->( RecLock('DUB', .F.) )
					For nCntFor := 1 To Len(aHeader)
						If	aHeader[nCntFor,10] != 'V'
							DUB->(FieldPut(FieldPos(aHeader[nCntFor,2]), aCols[nA,nCntFor]))
						EndIf
					Next
					DUB->DUB_STATUS := "2"   // Autorizado Pagto
					DUB->DUB_NUMIND := cNumInd
					DUB->DUB_PREIND := cPrefixo
					DUB->DUB_TIPIND := cTipo
					DUB->DUB_CODFOR := cCodForn
					DUB->DUB_NUMPRO := M->DUB_NUMPRO
					DUB->( MsUnLock() )
					
					// status para exibir mensagem de integração
					lConfirm := .T.

					If	lTM370GRV
						ExecBlock('TM370GRV',.F.,.F.,{nTmsOpcx})
					EndIf
				Else
					DisarmTransaction()
					lConfirm := .F.
					Exit
				EndIf
			EndIf
		EndIf
	Next
	
	End Transaction
	
	//| Aviso de Integração Realizada com Sucesso.
	If cTMSERP == "1"
	     If lRet == .T. .And. lConfirm == .T.
	          Aviso(STR0012,STR0038,{STR0037})
	     EndIf
	EndIf
	
ElseIf nTmsOpcx == 7 //-- Estorna Pagamento

	Begin Transaction
	
	For nA := 1 To Len( aCols )

		If GDFieldGet('DUB_ESTORN',nA) == "1"

			//-- Atualiza status da indenizacao
			If DUB->( MsSeek( xFilial('DUB') + cNumRid + GDFieldGet( 'DUB_ITEM', nA ), .F. ) )			

		        //+--------------------------------------------------------------------
		        //| Integração EAI desligada...
		        //+--------------------------------------------------------------------
		        If cTMSERP == "0"
        
                    cPreInd := DUB->DUB_PREIND
                    cNumInd := DUB->DUB_NUMIND

					//-- Exclui titulo de indenizacao a pagar			
					aAreaSE2  := SE2->(GetArea())
					dbSelectArea("SE2")
					dbSetOrder(6)
					If MsSeek( cSeekSE2 := xFilial("SE2")+DUB->DUB_CODFOR+DUB->DUB_LOJCLI+cPreInd+cNumInd )
						Do While !Eof() .And. E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == cSeekSE2
							//-- Apagar titulo
							aDadExcSE2 := {}
							AAdd( aDadExcSE2 ,{ "E2_FILIAL"  ,SE2->E2_FILIAL  ,Nil } )
							AAdd( aDadExcSE2 ,{ "E2_PREFIXO" ,SE2->E2_PREFIXO ,Nil } )
							AAdd( aDadExcSE2 ,{ "E2_NUM"     ,SE2->E2_NUM     ,Nil } )
							AAdd( aDadExcSE2 ,{ "E2_PARCELA" ,SE2->E2_PARCELA ,Nil } )
							AAdd( aDadExcSE2 ,{ "E2_TIPO"    ,SE2->E2_TIPO    ,Nil } )
							AAdd( aDadExcSE2 ,{ "E2_FORNECE" ,SE2->E2_FORNECE ,Nil } )
							AAdd( aDadExcSE2 ,{ "E2_LOJA"    ,SE2->E2_LOJA    ,Nil } )
							MSExecAuto({| a,b,c,d,e,f,g| FINA050(a,b,c,d,e,f,g)} ,aDadExcSE2, , 5,,,lExibeLanc,lOnline)
							If lMsErroAuto         
								MostraErro()
								DisarmTransaction()
								lRet := .F. 
								Break 
							EndIf						          
							SE2->(DbSkip())
						EndDo
					EndIf
					RestArea(aAreaSE2)
			
                    //+---------------------------------------------------------------
                    //| Envio da Integração de Estorno - Mensagem Unica
                    //+---------------------------------------------------------------
				Else
					   If lEAIFunOK == .T.
					         If FwHasEAI("TMSA370",.T.,,.T.) == .T.

					              oDTClass:cVIAGEM      := DUB->(DUB_FILORI+DUB_VIAGEM)
					              oDTClass:cFILORI      := DUB->DUB_FILORI
					              oDTClass:cTITULO      := DUB->DUB_DOC + DUB->DUB_SERIE
					              oDTClass:nVALORDOC    := 0
					              oDTClass:nVALORPDG    := 0
					              oDTClass:nVALORADTO   := 0
					              oDTClass:cCODCLIENTE  := DUB->DUB_CODFOR
					              oDTClass:cLOJCLIENTE  := DUB->DUB_LOJCLI
					              oDTClass:cFILDEBITO   := ""
					              oDTClass:dEMISSAO     := dDataBase

					              oDTClass:dTRANSACAO   := dDataBase
					              oDTClass:cHISTORICO   := "Titulo de Indenização de Seguro. Ref. a Filial/Documento/Serie: " + DUB->DUB_FILDOC + " /" + DUB->DUB_DOC + " /" + DUB->DUB_SERIE + "."      
					              oDTClass:cEventType   := "delete"
		                          oDTClass:cTipoMsg     := "3"
		                          oDTClass:cSubTipoMsg  := "301"
					              
					              aEAIRet := FwIntegDef("TMSA370",,,,"TMSA370")

					              lRet    := Iif(ValType(aEAIRet) == "U",.F.,aEAIRet[1])
					         Else
					              lRet    := .F.
					              Aviso(STR0036,STR0034,{STR0037},2)
					         EndIf
					   Else
					         lRet := .F.
					         Aviso(STR0036,STR0035,{STR0037},2)
					   Endif //[FECHA If lEAIFunOK == .T.]
					    
					   If lRet == .F.
					       Aviso(STR0036,aEAIRet[2],{STR0037},2)
					       DisarmTransaction()
					   EndiF
				 EndIf		
				 
				If lRet == .T.
     				RecLock( 'DUB', .F.) 
     				DUB->DUB_STATUS := StrZero( 1, Len( DUB->DUB_STATUS ) ) //-- Em Aberto
     				DUB->DUB_PREIND := CriaVar("DUB_PREIND",.F.)
     				DUB->DUB_NUMIND := CriaVar("DUB_NUMIND",.F.)
     				DUB->DUB_TIPIND := CriaVar("DUB_TIPIND",.F.)
     				DUB->DUB_DATVEN := CriaVar("DUB_DATVEN",.F.)
     				MsUnLock() 
     				lConfirm := .T.

     				If	lTM370GRV
     					ExecBlock('TM370GRV',.F.,.F.,{nTmsOpcx})
     				EndIf
     			EndIf	
			EndIf //[FIM] If DUB->( MsSeek( xFilial('DUB') + cNumRid + GDFieldGet( 'DUB_ITEM', nA ), .F. ) )

		EndIf //[FIM] If GDFieldGet('DUB_ESTORN',nA) == "1"

	Next
	
	End Transaction
	If !lRet
		Return(.F.)
	EndIf
     //| Aviso de Integração Realizada com Sucesso.
     If cTMSERP == "1" .And. lConfirm == .T.
          If lRet == .T.
               Aviso(STR0007,STR0038,{STR0037})
          EndIf
     EndIf
     
ElseIf nTmsOpcx == 9

	dbSelectArea("DUU")
	dbSetOrder(5)
	If dbSeek(xFilial("DUU")+DUB->DUB_FILRID+DUB->DUB_NUMRID+DUB->DUB_FILDOC+DUB->DUB_DOC+DUB->DUB_SERIE) .And. DUB->DUB_VALIND == 0
		RecLock( 'DUU', .F.)
		DUU->DUU_STATUS := StrZero( 4, Len( DUU->DUU_STATUS ) )
		MsUnlock()
	EndIf

	//-- Grava as Observacoes Realizadas
	MSMM(DUB->DUB_CODMTV,,,M->DUB_MOTIVO,1,,,'DUB','DUB_CODMTV')

	//-- Realiza o encerramento
	RecLock( 'DUB', .F.) 
	DUB->DUB_STATUS := StrZero( 4, Len( DUB->DUB_STATUS ) ) //-- Encerrado - Nao Indenizado
	DUB->DUB_DATENC := dDataBase
	DUB->DUB_RESPON := SubStr(cUsuario, 7, 15)
	MsUnLock()
	
ElseIf nTmsOpcx == 10   

	dbSelectArea("DUU")
	dbSetOrder(5)
	If dbSeek(xFilial("DUU")+DUB->DUB_FILRID+DUB->DUB_NUMRID+DUB->DUB_FILDOC+DUB->DUB_DOC+DUB->DUB_SERIE) .And. DUB->DUB_VALIND == 0
		RecLock( 'DUU', .F.)
		DUU->DUU_STATUS := StrZero( 2, Len( DUU->DUU_STATUS ) )
		MsUnlock()
	EndIf

	//-- Estorna o Encerramento
	RecLock( 'DUB', .F.) 
	DUB->DUB_STATUS := StrZero( 1, Len( DUB->DUB_STATUS ) ) //-- Em Aberto
	DUB->DUB_DATENC := CtoD(Space(08))
	DUB->DUB_RESPON := CriaVar('DUB_RESPON')
	MsUnLock()

EndIf

RestArea(aAreaDT6)

CursorArrow()

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA370Frn³ Autor ³ Antonio C Ferreira    ³ Data ³09.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica, cria e posiciona o Cadastro de Fornecedor        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA370Frn(Exp1, Exp2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Cliente                                  ³±± 
±±³          ³ ExpC2 = Loja do Cliente                                    ³±±
±±³          ³ ExpC3 = Codigo do Novo Fornecedor                          ³±±
±±³          ³ ExpA4 = Array com os Dados do Fornecedor. Neste caso nao   ³±±
±±³          ³         copia os dados do cliente para o fornecedor        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA370Frn(cCodCli, cLojCli, cCodForn, aDadosForn, cLojForn)

Local cCGC, aStrSA1, aStrSA2, nA, cA1pA2, cTipo, nTamanho, nPos,cNewForn
Local aCampos   := {}
Local lTM370COD := ExistBlock("TM370COD")
Local lTM370FRN := ExistBlock("TM370FRN")
Local lExiste   := .F.

Default cCodCli    := ''
Default cLojCli    := ''
Default cCodForn   := ''
Default aDadosForn := {}
Default cLojForn   := ''

If Empty( aDadosForn )
	// Obtem o CGC para pesquisar o Fornecedor
	SA1->(DbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1") + cCodCli + cLojCli))
	cCGC := SA1->A1_CGC

	//Verifica se tem no Cadastro do Fornecedor este Cliente cadastrado.
	SA2->(DbSetOrder(3))  // A2_FILIAL+A2_CGC
	If SA2->(MsSeek(xFilial("SA2") + cCGC))
	   cCodForn := SA2->A2_COD
	   cLojForn := SA2->A2_LOJA  
	   SA2->(DbSetOrder(1))
   
	   Return .T.  // Encontrado
	EndIf   

	//*** INICIO DA CRIACAO DO NOVO CADASTRO DO FORNECEDOR PELO CLIENTE.

	aStrSA1 := SA1->(dbStruct())   // Cliente
	aStrSA2 := SA2->(dbStruct())   // Fornecedor

	For nA := 1 to len(aStrSA1)
	If (alltrim(aStrSA1[nA][1]) $ "A1_FILIAL|A1_COD|A1_TIPO")
	      loop
	   EndIf
      
	   cA1pA2   := StrTran(aStrSA1[nA][1], "A1_", "A2_")   // Pega do Cliente para ver se tem no Fornecedor
	   cTipo    := aStrSA1[nA][2]
	   nTamanho := aStrSA1[nA][3]
   
	   If !Empty(nPos := Ascan(aStrSA2, {|x| x[1]==cA1pA2 .And. x[2]==cTipo .And. x[3]==nTamanho }))
    	  AAdd( aCampos, { aStrSA2[nPos][1], SA1->(FieldGet(nA)) } )  // Salva o Campo do Fornecedor com o Valor do Cliente
	   EndIf
	Next
Else
	aCampos := aClone(aDadosForn)
	cCGC	:= aDadosForn[6][2]	 
EndIf
//Obter o Codigo do Fornecedor
cCodForn := NextNumero("SA2",1,"A2_COD",.T.)

If lTM370COD
	cNewForn := ExecBlock( 'TM370COD', .F., .F., cCGC )
	If !Empty(cNewForn) .And. Valtype(cNewForn) == "C"
		cCodForn := Substr(cNewForn,1,Len(SA2->A2_COD))
		If Len(cNewForn) > Len (SA2->A2_COD)
			cLojCli:= Substr(cNewForn ,(Len(SA2->A2_COD)+1),Len(SA2->A2_LOJA))		
		EndIf
	EndIf
	SA2->(DbSetOrder(1))  // A2_FILIAL+A2_COD+A2_LOJA
	If SA2->(MsSeek(xFilial("SA2") + cCodForn + cLojCli ))
		lExiste := .T.
	EndIf
EndIf

If !lExiste
	SA2->(RecLock("SA2", .T.))
	SA2->A2_FILIAL := xFilial("SA2")
	SA2->A2_COD    := cCodForn
	SA2->A2_LOJA   := IF(!Empty(cLojCli), cLojCli, StrZero(1,Len(SA2->A2_LOJA)))
	If Empty(aDadosForn)
		SA2->A2_BANCO := SA1->A1_BCO1
		SA2->A2_COND  := SA1->A1_COND
	EndIf
	For nA := 1 to len(aCampos)
	   SA2->( FieldPut(FieldPos(aCampos[nA][1]), aCampos[nA][2]) )
	Next
	
	SA2->( MsUnlock() )
	
	If lTM370FRN
		ExecBlock( 'TM370FRN', .F., .F., {cCGC ,SA2->A2_COD ,SA2->A2_LOJA} )
	EndIf
EndIf 

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA370VBx³ Autor ³ Antonio C Ferreira    ³ Data ³09.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica baixa dos Titulos e encerra a Indenizacao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA370VBx()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1 = Codigo do Cliente                                   ³±± 
±±³          ³ Exp2 = Loja do Cliente                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA370VBx()

Local nOpca    := 0 
Local nBaixas  := 0
Local aSays    := {}
Local aButtons := {}
    
AAdd( aSays, STR0028 ) //"Este programa tem como finalidade atualizar o Status dos Registros de Indenizacao"
AAdd( aSays, STR0025 ) //"ja Pagos ... "
AAdd( aButtons, { 1, .T., {|o| nOpca := 1, o:oWnd:End() } } )
AAdd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
	
FormBatch( cCadastro, aSays, aButtons )
	
If nOpca == 1
	Begin Transaction
		Processa({|lEnd| TMSA370PBx(@nBaixas)},cCadastro,STR0024,.T.) //'Verificando Baixas...'
	End Transaction			
EndIf

If nBaixas > 0
	MsgInfo(STR0032+" "+Alltrim(Str(nBaixas)),"TMSA37017")//"Qtd. de registros de indenizações atualizados "
Else 
	MsgInfo(STR0033,"TMSA37017")//"Não há registro de indenização a ser atualizado"
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA370PBx³ Autor ³ Antonio C Ferreira    ³ Data ³09.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica baixa dos Titulos e encerra a Indenizacao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA370PBx(Exp1, Exp2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1 = Total de Baixas                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA370PBx(nBaixas)

Local nIndex    := 0
Local aAreaDUU  := DUU->(GetArea())
Local aAreaDUB  := DUB->(GetArea())
Local cAliasDUB := ''
Local cSeekSE2  := ''
Local cQuery    := ''
Local lBxInde   := .F.
Local cKeyDUB   := ''
Local cIndex    := ''

cIndex  := ''
cKeyDUB := 'DUB_FILIAL+DUB_STATUS'
nIndex  := 0

cAliasDUB := GetNextAlias()
cQuery := "SELECT DUB_FILIAL,DUB_CODFOR, DUB_LOJCLI, DUB_PREIND, DUB_NUMIND, DUB_TIPIND,  "
cQuery += " DUB_QTDOCO, DUB_CODOCO, DUB_STATUS, DUB_FILRID, DUB_NUMRID, DUB_FILDOC, DUB_DOC, DUB_SERIE, R_E_C_N_O_ NRECNO "
cQuery += " FROM "+RetSqlName("DUB")+ " DUB "
cQuery += " WHERE DUB_FILIAL = '"+xFilial("DUB")+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDUB)

While (cAliasDUB)->(!Eof())
	IncProc()     
	lBxInde := .F.
	SE2->(dbSetOrder(6))
	If SE2->(MsSeek(cSeekSE2 := xFilial("SE2")+(cAliasDUB)->DUB_CODFOR+(cAliasDUB)->DUB_LOJCLI+(cAliasDUB)->DUB_PREIND+(cAliasDUB)->DUB_NUMIND))
		While SE2->(!Eof()) .And. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == cSeekSE2
			If SE2->E2_TIPO == (cAliasDUB)->DUB_TIPIND
				If SE2->E2_SALDO > 0
					lBxInde := .F.
					Exit
				Else
					lBxInde := .T.
				EndIf
			EndIf														
			SE2->(dbSkip())
		EndDo
		If lBxInde
			DUB->(DbGoto((cAliasDUB)->NRecno))
			If DUB->DUB_STATUS <> "3" 
				RecLock("DUB", .F.)
				DUB->DUB_STATUS := "3" //-- Encerrada
				DUB->DUB_DATENC := dDataBase
				DUB->DUB_RESPON := SubStr(cUsuario, 7, 15)
				MsUnlock()            
				//-- Verificar se indenizacao eh proveniente de uma pendencia
				DUU->( DbSetOrder( 5 ) )
				DUU->( MsSeek( cSeekDUU := xFilial( 'DUU' ) + (cAliasDUB)->( DUB_FILRID+DUB_NUMRID+DUB_FILDOC+DUB_DOC+DUB_SERIE ) ) )
				While DUU->( !Eof() .And. DUU_FILIAL+DUU_FILRID+DUU_NUMRID+DUU_FILDOC+DUU_DOC+DUU_SERIE == cSeekDUU )
					If DUU->DUU_CODOCO == (cAliasDUB)->DUB_CODOCO .And. DUU->DUU_QTDOCO == (cAliasDUB)->DUB_QTDOCO
						RecLock( 'DUU', .F. )
		      			DUU->DUU_STATUS := StrZero( 3, Len( DUU->DUU_STATUS ) ) //-- Indenizada
		      			MsUnlock()
						
	      				Exit
					EndIf  
					DUU->( DbSkip() )
				EndDo			    				
	    	  ++nBaixas      
			EndIf	   
	   EndIf
	   If !lBxInde
			DUB->(DbGoto((cAliasDUB)->NRecno))
			RecLock("DUB", .F.)
			If DUB->DUB_STATUS <> "1" .And. Empty(DUB->DUB_NUMIND)
				DUB->DUB_STATUS := "1"
				DUB->DUB_DATENC := CtoD('')
				DUB->DUB_RESPON :=  Space(Len(DUB->DUB_RESPON))
				++nBaixas 
			ElseIf DUB->DUB_STATUS <> "2" .And. !Empty(DUB->DUB_NUMIND)
				DUB->DUB_STATUS := "2" 
				++nBaixas 
			EndIf				
			MsUnlock()                  

			//-- Verificar se indenizacao eh proveniente de uma pendencia
			DUU->( DbSetOrder( 5 ) )
			DUU->( MsSeek( cSeekDUU := xFilial( 'DUU' ) + (cAliasDUB)->( DUB_FILRID+DUB_NUMRID+DUB_FILDOC+DUB_DOC+DUB_SERIE ) ) )
			While DUU->( !Eof() .And. DUU_FILIAL+DUU_FILRID+DUU_NUMRID+DUU_FILDOC+DUU_DOC+DUU_SERIE == cSeekDUU )
				If DUU->DUU_CODOCO == (cAliasDUB)->DUB_CODOCO .And. DUU->DUU_QTDOCO == (cAliasDUB)->DUB_QTDOCO
					RecLock( 'DUU', .F. )
		     		DUU->DUU_STATUS := StrZero( 2, Len( DUU->DUU_STATUS ) ) //-- Indenizacao solicitada
		     		MsUnlock()
	      			Exit
				EndIf  
				DUU->( DbSkip() )
			EndDo
	   EndIf		   	   
	EndIf
	(cAliasDUB)->(dbSkip())
EndDo
(cAliasDUB)->(DbCloseArea())

RestArea( aAreaDUU )
RestArea( aAreaDUB )

Return .T.
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA370Leg³ Autor ³ Antonio C Ferreira    ³ Data ³30.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a legenda de status                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA370Leg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA370Leg()

Local aStatus

aStatus := {	{ 'BR_VERDE'	, STR0011 },; 	//'Em Aberto'
				{ 'BR_AMARELO'	, STR0012 },; 	//'Autorizado Pagto'
			    { 'BR_AZUL'		, STR0013 },; 	//'Encerrado - Indenizado'
			    { 'BR_MARROM'	, STR0031 }}	//'Encerrado - Nao Indenizado'

BrwLegenda( STR0001,STR0010, aStatus ) //'Registro de Indenizacoes'

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA370Val³ Autor ³Patricia A. Salomao    ³ Data ³14.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gatilha o Valor da Indenizacao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA370Val()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA370Val( nI )

Local nValInd := 0
Local nValPre := 0
Local nPerSeg := 0
Local nRet    := 0

Default nI    := n

If nTmsOpcx == 2//se for visualizacao nao gatilha, apenas mostra o que esta gravado
	nRet := GdFieldGet("DUB_VALPRE",nI)
Else                    
	If nTmsOpcx == 6 //Autorizacao de Pagamento
		nValPre := GdFieldGet("DUB_VALPRE",nI)
		nPerSeg := GdFieldGet("DUB_SEGCLI",nI)
	EndIf
	
	nValInd := Round( (nValPre * ( nPerSeg / 100) ) , TamSX3("DUB_VALIND")[2] ) 
	
	nRet := nValPre - nValInd
EndIf 

Return ( nRet )
  
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
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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
     
Private aRotina :=  {	{ STR0002 ,'AxPesqui'  ,0,1,0,.F.},;	//'Pesquisar'
								{ STR0003 ,'TMSA370Mnt',0,2,0,NIL},; 	//'Visualizar'
								{ STR0023 ,'TMSA370Mnt',0,4,0,NIL},; 	//'Alterar' 
								{ STR0006 ,'TMSA370Mnt',0,6,0,NIL},; 	//'Autoriza Pagto' 
								{ STR0007 ,'TMSA370Mnt',0,7,0,NIL}} 	//'Estornar Pagto'
								
//| Status financeiro será liberado somente para integração nativa Financeira.
If cTMSERP == "0"
    AAdd( aRotina, { STR0008 ,'TMSA370VBx' ,0 ,8  ,0 ,NIL } )   //'Status Financeiro'
EndIf

AAdd( aRotina, { STR0029 ,'TMSA370Mnt' ,0 ,9  ,0 ,NIL } )	//'Encerrar'
AAdd( aRotina, { STR0030 ,'TMSA370Mnt' ,0 ,10 ,0 ,NIL } )	//'Estornar Encerr.'
AAdd( aRotina, { STR0009 ,'TMSA370Leg' ,0 ,11 ,0 ,.F. } )	//'Legenda'

If ExistBlock("TM370MNU")
	ExecBlock("TM370MNU",.F.,.F.)
EndIf

Return(aRotina)

/*
 ===========================================================================================
/{Protheus.doc} IntegDef
//TODO   Rotina para chamada da integracao Financeira via EAI - utilizando a transação 
         TransportDocument
@author  tiago.dsantos
@since   30/09/2016
@version 1.000
@param   cXml        , characters, descricao
@param   nType       , numeric   , descricao
@param   cMessageType, characters, descricao
@param   cVersion    , characters, descricao
@type    function
 ===========================================================================================
/*/
Static Function IntegDef(cXml,nType,cMessageType,cVersion)
Return TMSI370ABP(cXml,nType,cMessageType,cVersion)

