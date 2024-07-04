#INCLUDE "TMSA142.ch"
#INCLUDE 'PROTHEUS.CH'
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA142  ³ Autor ³ Robson Alves          ³ Data ³ 30/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Confirmacao de Viagem - Carga Fechada.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS142()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA142( cSerTms, cTipTra, lMnuViag )
//--- MarkBrowse
Local lInverte	 := .F.
//-- Controles Gerais
Local aAreaDTQ	 := DTQ->( GetArea() )
Local cCondicao := ""    

Local lTM142Fil := ExistBlock("TM142FIL") //--Ponto de entrada para filtro especifico do usuario...
Local cCondUsr  := ''
Local aRotinaOld := aClone(aRotina)

Local aHlpPor1  :=  {"Todos os Veículos e Motoristas foram ","liberados ou não existe ","Complemento de Viagem"}
Local aHlpIng1  :=  {"All the Vehicles and Drivers were ","released or do not exist","Trip Complement"}
Local aHlpEsp1  :=  {"Todos los Vehiculos y Motoristas fueron ","liberados o no existen ","Complemento de Viaje"}

Local aHlpPor2  :=  {"Essa opção só é necessária quando o ","controle de veículos estiver ligado"}
Local aHlpIng2  :=  {"This option is only necessary when ","control of vehicles is linked"}
Local aHlpEsp2  :=  {"Este espacio solo es necesario cuando el","control de vehiculos este anexado"} 

Local aHlpPor3  :=  {"Informar se deseja que seja realizado ", "o fechamento automatico da viagem."}
Local aHlpEsp3  :=  {"Informar si desea que sea realizado el", " cierre automatico de la viaje.   "}
Local aHlpIng3  :=  {"Enter if to be accomplished the       ", " automatic closing the trip.      "}


//Ajuste de Novos Helps
PutHelp("PTMSA14201",aHlpPor1,aHlpIng1,aHlpEsp1,.F.)
PutHelp("PTMSA14202",aHlpPor2,aHlpIng2,aHlpEsp2,.F.)

//-- IndRegua
cIndDTQ := ""
nIndDTQ := 0              

Default cSerTms   := ""
Default lMnuViag	:= .F.

//-- MsDialog
Private cCadastro	:= STR0001 //"Confirmação de Viagens"
//--- MarkBrowse
Private cMarca    := GetMark()

Private aRotina := MenuD142()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa               ³
//³ ----------- Elementos contidos por dimensao ------------              ³
//³ 1. Nome a aparecer no cabecalho                                       ³
//³ 2. Nome da Rotina associada                                           ³
//³ 3. Usado pela rotina                                                  ³
//³ 4. Tipo de Transa‡„o a ser efetuada                                   ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados                      ³
//³    2 - Simplesmente Mostra os Campos                                  ³
//³    3 - Inclui registros no Bancos de Dados                            ³
//³    4 - Altera  o registro corrente do Banco de Dados                  ³
//³    5 - Exclui  o registro corrente do Banco de Dados                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas como parametros                                  ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ mv_par01	// Fil. Origem De ?                                        ³
//³ mv_par02	// Viagem De ?                                             ³
//³ mv_par03	// Fil. Origem Ate ?                                       ³
//³ mv_par04	// Viagem Ate ?                                            ³
//³ mv_par05	// Data Inicio De ?                                        ³
//³ mv_par06	// Data Inicio Ate ?                                       ³
//³ mv_par07	// Efetua Fechamento da Viagem ?  1=Sim;  2=Nao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//-- Exibe pergunta para identificar se realiza o Fechamento da Viagem.      
// -- Se a rotina de Confirmacao sendo executada pelo menu da viagem
If LockByName("TM142A",.T.,.F.)
	
	SetMvValue("TM142A","MV_PAR01",DTQ->DTQ_FILORI)
	SetMvValue("TM142A","MV_PAR03",DTQ->DTQ_FILORI)
	SetMvValue("TM142A","MV_PAR02",DTQ->DTQ_VIAGEM)
	SetMvValue("TM142A","MV_PAR04",DTQ->DTQ_VIAGEM)
	SetMvValue("TM142A","MV_PAR05",DTQ->DTQ_DATINI)
	SetMvValue("TM142A","MV_PAR06",DTQ->DTQ_DATINI)
	
	UnLockByName("TM142A",.T.,.F.) // Libera Lock				

EndIf
	
If !Pergunte( "TM142A", .T. )
	Return Nil
EndIf        

dbSelectArea("DTQ")
dbSetOrder( 2 )

cCondicao := " DTQ->DTQ_FILIAL == '" + xFilial("DTQ") + "'"
cCondicao += " .And. DTQ->DTQ_FILORI >= '" + mv_par01 + "'"
cCondicao += " .And. DTQ->DTQ_FILORI <= '" + mv_par03 + "'"
cCondicao += " .And. DTQ->DTQ_VIAGEM >= '" + mv_par02 + "'"
cCondicao += " .And. DTQ->DTQ_VIAGEM <= '" + mv_par04 + "'"
cCondicao += " .And. Dtos( DTQ->DTQ_DATINI ) >= '" + Dtos( mv_par05 ) + "'"
cCondicao += " .And. Dtos( DTQ->DTQ_DATINI ) <= '" + Dtos( mv_par06 ) + "'"
If FindFunction('TmsVgeMod3') .And. !TmsVgeMod3() 
	cCondicao += " .And. DTQ->DTQ_SERTMS == '" + cSerTms + "'"
	cCondicao += " .And. DTQ->DTQ_TIPTRA == '" + cTipTra + "'"
EndIf
cCondicao += " .And. DTQ->DTQ_TIPVIA == '" + StrZero( 3, Len( DTQ->DTQ_TIPVIA ) ) + "'"   

If AliasInDic('DF8')
	cCondicao += " .And. DTQ->DTQ_VIAGEM <> Posicione( 'DF8', 2, xFilial('DF8')+DTQ->(DTQ_FILORI+DTQ_VIAGEM),'DF8_VIAGEM')"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PONTO DE ENTRADA PARA ACRESCENTAR FILTRO³
//³ESPECIFICO DO USUARIO                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTM142Fil
   cCondUsr := ExecBlock("TM142FIL",.F.,.F.)
   If ValType(cCondUsr) == "C" .And. !Empty( cCondUsr )
      cCondicao += " .And. " + cCondUsr
   EndIf
EndIf

DTQ->( DbSetFilter( { || &cCondicao },  cCondicao ) )

//-- Endereca a funcao de MARKBROWSE.
MarkBrow( "DTQ","DTQ_OK",,, lInverte, cMarca, "Tm142MkAll()",,,,"Tm142Mk()")

If !Empty( DTQ->( dbFilter() ) ) 
	DTQ->(dbClearFilter())
EndIf	

RestArea( aAreaDTQ )        
aRotina := aRotinaOld

Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA142Mn³ Autor ³ Robson Alves          ³ Data ³ 02/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao da Confirmacao de Viagens.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS142Mnt( EXpC1, ExpN1, ExpN2 )                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 = Alias( MarkBrowse )                                ³±±
±±³          ³ ExpN1 = Registro( MarkBrowse )                             ³±±
±±³          ³ ExpN1 = Opcao do aRotina                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa142Mnt( cAlias, nReg, nOpcx)
//-- FormBatch
Local aSays		:= {}
Local aButtons	:= {}
Local nOpca    := 0
Local lContVei := GetMV('MV_CONTVEI',,.T.) // Parametro para verificar se o sistema devera' controlar veiculo/motorista

If nOpcx == 2
	TmsVisViag( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, DTQ->DTQ_SERTMS, DTQ->DTQ_TIPTRA )
ElseIf nOpcx == 3	
	Aadd( aSays, STR0006 )  //"Este programa tem como objetivo, confirmar as viagens planejadas, "
	Aadd( aSays, STR0007 )  //"de acordo com os parâmetros definidos pelo usuário. "
	
	Aadd( aButtons, { 1, .T., {|o| nOpca := 1, o:oWnd:End() } } )
	Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
	
	FormBatch( cCadastro, aSays, aButtons )
	
	If nOpca == 1
		Processa( { | lEnd | Tmsa142Prc( @lEnd, lContVei ) }, cCadastro,STR0008, .T. ) //"Confirmando Viagens..."
	EndIf
ElseIf nOpcx == 4	
	If lContVei
		Processa( { | lEnd | Tmsa142Con( @lEnd ) }, cCadastro, STR0009, .T. ) //"Montando Consulta..."
	Else
		Help(' ', 1, 'TMSA14202') //"Essa opcao so e necessaria quando o controle de veiculos estiver ligado"
	EndIf
EndIf

Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA142Pr³ Autor ³ Robson Alves          ³ Data ³ 02/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de Processamento.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS142Mnt( ExpL1 )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpL1 = Flag para cancelar o processo.                     ³±±
±±³Parametro ³ ExpL2 = Controle de Veiculo( Ligado ou Desligado ).        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa142Prc( lEnd, lContVei )
//-- Tela de Log.
Local aMsgErr     := {}
//-- Controle Gerais.
Local aAreaAnt	  := GetArea()
Local cAliasDTQ   := ""
Local cAliasQry   := ""
Local cQuery      := ""
Local aVeiErr     := {}
Local aMotErr     := {}
Local aVeiculos   := {}
Local aMotoristas := {}
Local lOk         := .T.
Local lTM142ATZ   := ExistBlock("TM142ATZ")
Local lTM142VLD   := ExistBlock("TM142VLD")
Local lTM142GRV   := ExistBlock("TM142GRV")
Local na
Local cFilUsado   := ""
Local cVgeUsado   := ""
Local lMV_EmViag  := GetMV("MV_EMVIAG",,.F.) // Utilizado para verificar se o veiculo esta em uso em outra viagem.		   	
Local aViagem     := {}
Local aRet        := {}
Local lTercRbq    := DTR->(ColumnPos("DTR_CODRB3")) > 0

Pergunte("TM142A",.F.)

dbSelectArea("DTQ")
dbGoTop()
ProcRegua( RecCount() )

DTR->( dbSetOrder( 1 ) ) //-- Veiculos da Viagem.
DTU->( dbSetOrder( 2 ) ) //-- Movimentos de Veiculos.
DUP->( dbSetOrder( 1 ) ) //-- Motoristas da Viagem.
DTO->( dbSetOrder( 2 ) ) //-- Movimentos de Motoristas.

cQuery := "SELECT R_E_C_N_O_ RECNODTQ FROM "+RetSqlName("DTQ") + " DTQ "
cQuery += "WHERE DTQ_FILIAL  = '" + xFilial("DTQ") + "'"
cQuery += "  AND DTQ_FILORI >= '" + mv_par01 + "'"
cQuery += "  AND DTQ_FILORI <= '" + mv_par03 + "'"
cQuery += "  AND DTQ_VIAGEM >= '" + mv_par02 + "'"
cQuery += "  AND DTQ_VIAGEM <= '" + mv_par04 + "'"
cQuery += "  AND DTQ_DATINI >= '" + Dtos( mv_par05 ) + "'"
cQuery += "  AND DTQ_DATINI <= '" + Dtos( mv_par06 ) + "'"
If FindFunction('TmsVgeMod3') .And. !TmsVgeMod3()
	cQuery += "  AND DTQ_SERTMS  = '" + cSerTms + "'"
	cQuery += "  AND DTQ_TIPTRA  = '" + cTipTra + "'"
EndIf
cQuery += "  AND DTQ_TIPVIA  = '" + StrZero( 3, Len( DTQ->DTQ_TIPVIA ) ) + "'"   
cQuery += "  AND DTQ_OK      = '" + cMarca + "'" //-- Verifica se a Viagem foi marcada.
cQuery += "  AND DTQ.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery( cQuery )
cAliasDTQ := GetNextAlias()
dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasDTQ, .T., .T. )
While (cAliasDTQ)->(!Eof())
	DTQ->(MsGoTo((cAliasDTQ)->RECNODTQ))
	aVeiErr     := {}
	aMotErr     := {}
	aVeiculos   := {}
	aMotoristas := {}

	IncProc()
	//-- Cancelado pelo operador.
	If lEnd
		Exit
	EndIf

	cQuery := " SELECT DISTINCT DTR.DTR_CODVEI,DTR.DTR_CODRB1,DTR.DTR_CODRB2 "
	If lTercRbq
		cQuery += ", DTR.DTR_CODRB3 "
	EndIf
	If lContVei 
		cQuery += ", DTU.DTU_STATUS "
	EndIf	
	cQuery += "   FROM "
	cQuery += RetSqlName("DTR") + " DTR, "
	If lContVei
		cQuery += RetSqlName("DTU") + " DTU "
	EndIf	
	cQuery += "   WHERE DTR.DTR_FILIAL = '" + xFilial("DTR")  + "'"
	cQuery += "     AND DTR.DTR_FILORI = '" + DTQ->DTQ_FILORI + "'"
	cQuery += "     AND DTR.DTR_VIAGEM = '" + DTQ->DTQ_VIAGEM + "'"
	cQuery += "     AND DTR.D_E_L_E_T_ = ' '"
	If lContVei 
		cQuery += "     AND DTU.DTU_FILIAL = '" + xFilial("DTU")  + "'"
		cQuery += "     AND ( DTU.DTU_CODVEI = DTR.DTR_CODVEI"
		cQuery += "        OR DTU.DTU_CODVEI = DTR.DTR_CODRB1"
		cQuery += "        OR DTU.DTU_CODVEI = DTR.DTR_CODRB2"
		If lTercRbq
			cQuery += "     OR DTU.DTU_CODVEI = DTR.DTR_CODRB3 )"
		Else
			cQuery +=" )"
		EndIf
		cQuery += "     AND DTU.DTU_STATUS = '" + StrZero(2,Len(DTU->DTU_STATUS)) + "' "
		cQuery += "     AND DTU.D_E_L_E_T_ = ' '"
	EndIf	
	cQuery    := ChangeQuery( cQuery )
	cAliasQry := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	(cAliasQry)->( dbGoTop() )

	//-- Verifica se existe o Complemento de Viagem.
	If ( cAliasQry )->( Eof() )
		AAdd( aMsgErr, { STR0016 + DTQ->DTQ_VIAGEM + ".", "00", "" } ) //"Complemento de Viagen não encontrado para viagem : "
		lOk := .F.
	EndIf
		
	While ( cAliasQry )->( !Eof() )
		//-- Verifica se o Veiculo foi liberado.
		If lContVei .And. !Empty( ( cAliasQry )->DTR_CODVEI ) .And. ( cAliasQry )->DTU_STATUS != StrZero( 2, Len( DTU->DTU_STATUS ) )
			AAdd( aVeiErr, { STR0010 + ( cAliasQry )->DTR_CODVEI + STR0011 + DTQ->DTQ_VIAGEM + STR0012, "00", "" } ) //"O veículo : "###" utilizado na viagem : "###" não está liberado."
		EndIf

		//-- Verifica se o 1o Reboque foi liberado.
		If lContVei .And. !Empty( ( cAliasQry )->DTR_CODRB1 ) .And. ( cAliasQry )->DTU_STATUS != StrZero( 2, Len( DTU->DTU_STATUS ) )
			AAdd( aVeiErr, { STR0013 + ( cAliasQry )->DTR_CODRB1 + STR0011 + DTQ->DTQ_VIAGEM + STR0012, "00", "" } ) //"O 1o Reboque : "###" utilizado na viagem : "###" não está liberado."
		EndIf

		//-- Verifica se o 2o Reboque foi liberado.
		If lContVei .And. !Empty( ( cAliasQry )->DTR_CODRB2 ) .And. ( cAliasQry )->DTU_STATUS != StrZero( 2, Len( DTU->DTU_STATUS ) )
			AAdd( aVeiErr, { STR0014 + ( cAliasQry )->DTR_CODRB2 + STR0011 + DTQ->DTQ_VIAGEM + STR0012, "00", "" } ) //"O 2o Reboque : "###" utilizado na viagem : "###" não está liberado."
		EndIf
		
		If lMV_EmViag
			//Verifica se o Veiculo esta sendo utilizandos em uma viagem
			If !TMSEmViag(,,(cAliasQry)->DTR_CODVEI,1,.F.,@cFilUsado,@cVgeUsado)
				AAdd( aVeiErr,{STR0010 + (cAliasQry)->DTR_CODVEI + ' - ' + AllTrim(Posicione("DA3",1,xFilial("DA3")+(cAliasQry)->DTR_CODVEI,"DA3_DESC")) + STR0018 + '(' + cFilUsado + ' - ' + cVgeUsado + ')',"00",""} ) //"O veículo : " ### " esta sendo utilizado em uma Viagem."
			EndIf
		
			//Verifica se o 1o Reboque esta sendo utilizandos em uma viagem
			If !Empty((cAliasQry)->DTR_CODRB1) .And. !TMSEmViag(,,(cAliasQry)->DTR_CODRB1,1,.F.,@cFilUsado,@cVgeUsado)
				AAdd( aVeiErr,{STR0013 + (cAliasQry)->DTR_CODRB1 + ' - ' + AllTrim(Posicione("DA3",1,xFilial("DA3")+(cAliasQry)->DTR_CODRB1,"DA3_DESC")) + STR0018 + '(' + cFilUsado + ' - ' + cVgeUsado + ')',"00",""} ) //"O 1o Reboque : " ### " esta sendo utilizado em uma Viagem."
			EndIf
		
			//Verifica se o 2o Reboque esta sendo utilizandos em uma viagem
			If !Empty((cAliasQry)->DTR_CODRB2) .And. !TMSEmViag(,,(cAliasQry)->DTR_CODRB2,1,.F.,@cFilUsado,@cVgeUsado)
				AAdd( aVeiErr,{STR0014 + (cAliasQry)->DTR_CODRB2 + ' - ' + AllTrim(Posicione("DA3",1,xFilial("DA3")+(cAliasQry)->DTR_CODRB2,"DA3_DESC")) + STR0018 + '(' + cFilUsado + ' - ' + cVgeUsado + ')',"00",""} ) //"O 2o Reboque : " ### " esta sendo utilizado em uma Viagem."
			EndIf
			//Verifica se o 3o Reboque esta sendo utilizandos em uma viagem
			If lTercRbq
				If !Empty((cAliasQry)->DTR_CODRB3) .And. !TMSEmViag(,,(cAliasQry)->DTR_CODRB3,1,.F.,@cFilUsado,@cVgeUsado)
					AAdd( aVeiErr,{STR0019 + (cAliasQry)->DTR_CODRB3 + ' - ' + AllTrim(Posicione("DA3",1,xFilial("DA3")+(cAliasQry)->DTR_CODRB3,"DA3_DESC")) + STR0018 + '(' + cFilUsado + ' - ' + cVgeUsado + ')',"00",""} ) //"O 3o Reboque : " ### " esta sendo utilizado em uma Viagem."
				EndIf
			EndIf
		EndIf 
		If lTercRbq
			Aadd( aVeiculos, { ( cAliasQry )->DTR_CODVEI, ( cAliasQry )->DTR_CODRB1, ( cAliasQry )->DTR_CODRB2, ( cAliasQry )->DTR_CODRB3 } )
			( cAliasQry )->( dbSkip() )
		Else 
			Aadd( aVeiculos, { ( cAliasQry )->DTR_CODVEI, ( cAliasQry )->DTR_CODRB1, ( cAliasQry )->DTR_CODRB2} )
			( cAliasQry )->( dbSkip() )
		EndIf
	EndDo
	(cAliasQry)->( dbCloseArea() )
		
	cQuery := "SELECT DISTINCT DUP.DUP_CODMOT, DTO.DTO_STATUS FROM " + RetSqlName("DUP") + " DUP"
	cQuery += " LEFT JOIN " + RetSqlName("DTO") + " DTO ON"
	cQuery += " DTO.DTO_FILIAL = '" + xFilial("DTO") + "'"
	cQuery += " AND DTO.DTO_CODMOT = DUP.DUP_CODMOT"
	cQuery += " AND DTO.DTO_STATUS = '2'"
	cQuery += " AND DTO.D_E_L_E_T_ = ' '"
	cQuery += " WHERE DUP.DUP_FILIAL = '" + xFilial("DUP")  + "'"
	cQuery += " AND   DUP.DUP_FILORI = '" + DTQ->DTQ_FILORI + "'"
	cQuery += " AND   DUP.DUP_VIAGEM = '" + DTQ->DTQ_VIAGEM + "'"
	cQuery += " AND   DUP.D_E_L_E_T_ = ' '"
	cQuery    := ChangeQuery( cQuery )
	cAliasQry := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	(cAliasQry)->( dbGoTop() )
	While ( cAliasQry )->( !Eof() )
		//-- Verifica se o Motorista foi liberado.
		If lContVei .And. (cAliasQry)->DTO_STATUS != StrZero( 2, Len( DTO->DTO_STATUS ) )
			AAdd( aMotErr, { STR0015 + (cAliasQry)->DUP_CODMOT + STR0011 + DTQ->DTQ_VIAGEM + STR0012, "00", "" } ) //"O motorista : "###" utilizado na viagem : "###" não está liberado."
		EndIf
		If lMV_EmViag
			//Verifica se o Motorista esta sendo utilizandos em uma viagem
			If !TMSEmViag(,,(cAliasQry)->DUP_CODMOT,2,.F.,@cFilUsado,@cVgeUsado)
				AAdd( aMotErr,{STR0015 + (cAliasQry)->DUP_CODMOT + ' - ' + AllTrim(Posicione("DA4",1,xFilial("DA4")+(cAliasQry)->DUP_CODMOT,"DA4_NREDUZ")) + STR0018 + '(' + cFilUsado + ' - ' + cVgeUsado + ')',"00",""} ) //"O motorista : " ###
			EndIf
		EndIf
		Aadd( aMotoristas, (cAliasQry)->DUP_CODMOT )
		(cAliasQry)->( dbSkip() )
	EndDo
	(cAliasQry)->( dbCloseArea() )

	//-- Ponto de Entrada para validação dos Veiculos e Motoristas da viagem.
	If lTM142VLD
		aRet := ExecBlock("TM142VLD",.F.,.F.,{aVeiculos, aMotoristas})
		If ValType( aRet ) == "A"
			For nA := 1 To Len( aRet )
				Aadd( aVeiErr, AClone( aRet[nA] ) )
			Next nA
		EndIf
	EndIf     
	
	//-- Somente altera os status dos Veiculos e Motoristas, se todos foram liberados.
	If Empty( aVeiErr ) .And. Empty( aMotErr )
		If lContVei
			For nA := 1 To Len( aVeiculos )
				//-- Altera Status do Veiculo para Reservado
				aAltStaDTU( "2", aVeiculos[ nA, 1 ], DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM )
		
				//-- Altera Status do 1o. Reboque para Reservado
				If !Empty( aVeiculos[ nA, 2 ] )
					aAltStaDTU( "2", aVeiculos[ nA, 2 ], DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM )
				EndIf
		
				//-- Altera Status do 2o. Reboque para Reservado
				If !Empty( aVeiculos[ nA, 3 ] )
					aAltStaDTU("2", aVeiculos[ nA, 3 ], DTR->DTR_FILORI, DTR->DTR_VIAGEM)
				EndIf
			Next nA
		
			For nA := 1 To Len( aMotoristas )
				//-- Altera Status do Motorista	p/ Reservado
				aAltStaDTO( "2",DTR->DTR_FILORI,DTR->DTR_VIAGEM,aMotoristas[ nA ] )
			Next nA
		EndIf
	
		If lOk
			If lTM142ATZ
			  lOk :=	ExecBlock("TM142ATZ",.F.,.F.)
			  If ValType(lOk) <> "L"
				  lOk := .T.
			  EndIf
			EndIf 
			If lOk
				//-- Efetua o fechamento da Viagem.  
				If mv_par07 == 1
                    TMSA310Mnt('DTQ', 0, 3, , .F.)
				EndIf
				//-- Altera o tipo da Viagem para 1( Normal ).
				RecLock( "DTQ", .F. )
				DTQ->DTQ_TIPVIA := StrZero( 1, Len( DTQ->DTQ_TIPVIA ) )
				MsUnLockAll()
				//-- Atualiza os status dos Itens do Agendamento.
				Tmsa142Atz()  

				aAdd(aViagem, {DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM})	
		   EndIf	
		EndIf
	Else
		//-- Gera o array de Log.
		For nA := 1 To Len( aVeiErr )
			Aadd( aMsgErr, AClone( aVeiErr[nA] ) )
		Next nA
	
		For nA := 1 To Len( aMotErr )
			Aadd( aMsgErr, AClone( aMotErr[nA] ) )
		Next nA
	EndIf

	(cAliasDTQ)->(dbSkip())
EndDo

(cAliasDTQ)->(dbCloseArea())
dbSelectArea("DTQ")
	
//-- Exibe a tela de Log.
If !Empty( aMsgErr )
	TmsMsgErr( aMsgErr )
EndIf						

MsUnLockAll()
RestArea(aAreaAnt)

If lTM142GRV
	ExecBlock("TM142GRV",.F.,.F., aViagem)
EndIf

Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TM142MkAll³ Autor ³ Robson Alves          ³ Data ³ 02/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca todos os registro do Browse.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TM142MkAll()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tm142MkAll()
//-- Controles Gerais
Local aAreaAnt	:= GetArea()
Local lMarca	:=  NIL

dbSelectArea('DTQ')
dbGoTop()

While !Eof()                

	//-- Confirmar a viagem somente na filial de origem.
	If DTQ->DTQ_FILORI <> cFilAnt 
		dbSkip()
		Loop
	EndIf 

	//-- Confirmar a viagem que não provem da Programação de Carregamento.
	If !Empty(Posicione('DF8',2,xFilial('DF8')+DTQ->(DTQ_FILORI+DTQ_VIAGEM),'DF8_NUMPRG'))
		dbSkip()
		Loop
	EndIf 

	If	(lMarca == NIL)
		lMarca := ( DTQ->DTQ_OK == cMarca )
	EndIf

	/* Verifica se o registro n„o est  em uso por outra esta‡„o. */   
	If SoftLock("DTQ")
	   DTQ->DTQ_OK := If( lMarca," ",cMarca )
	EndIf

   dbSkip()
EndDo

RestArea(aAreaAnt)

Return NIL
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA142Co³ Autor ³ Robson Alves          ³ Data ³ 02/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consultas os Veiculos e Motoristas não liberados.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS142Con( ExpL1 )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpL1 = Flag para cancelar o processo.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa142Con( lEnd )
//-- ListBox
Local aListVei  := {}
Local aListMot  := {}
Local oListVei, oListMot, oDlgCon
Local aHVei     := {}
Local aHMot     := {}
//-- Folder
Local aPages	 := {"HEADER","HEADER"}
Local aTitles	 := {"&Veiculos","&Motoristas"}
//-- Controle de dimensoes de objetos
Local aSize		 := {}
Local aObjects	 := {}
Local aInfo		 := {}
Local aPosObjH	 := {}
//-- Controles Gerais
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cCodVei   := ""
Local cModVei   := ""
Local cCodRB1   := ""
Local cModRB1   := ""
Local cCodRB2   := ""
Local cModRB2   := ""
Local cCodRB3	  := ""
Local cModRB3	  := ""
Local cCodMot   := ""
Local lExibeCon := .T.
Local lTercRbq  := DTR->(ColumnPos("DTR_CODRB3")) > 0

//-- Header do ListBox de Veiculos.
Aadd( aHVei, Posicione('SX3', 2, 'DTQ_FILORI', 'X3Titulo()') )
Aadd( aHVei, Posicione('SX3', 2, 'DTQ_VIAGEM', 'X3Titulo()') )
Aadd( aHVei, Posicione('SX3', 2, 'DTR_CODVEI', 'X3Titulo()') )
Aadd( aHVei, Posicione('SX3', 2, 'DTR_MODVEI', 'X3Titulo()') )
Aadd( aHVei, Posicione('SX3', 2, 'DTR_CODRB1', 'X3Titulo()') )
Aadd( aHVei, Posicione('SX3', 2, 'DTR_MODRB1', 'X3Titulo()') )
Aadd( aHVei, Posicione('SX3', 2, 'DTR_CODRB2', 'X3Titulo()') )
Aadd( aHVei, Posicione('SX3', 2, 'DTR_MODRB2', 'X3Titulo()') )
If lTercRbq
	Aadd( aHvei, Posicione('SX3', 2, 'DTR_CODRB3', 'X3Titulo()') )
	Aadd( aHvei, Posicione('SX3', 2, 'DTR_MODRB3', 'X3Titulo()') )
EndIf
//-- Header do ListBox de Motoristas.
Aadd( aHMot, Posicione('SX3', 2, 'DTQ_FILORI', 'X3Titulo()') )
Aadd( aHMot, Posicione('SX3', 2, 'DTQ_VIAGEM', 'X3Titulo()') )
Aadd( aHMot, Posicione('SX3', 2, 'DUP_CODMOT', 'X3Titulo()') )
Aadd( aHMot, Posicione('SX3', 2, 'DA4_NOME'  , 'X3Titulo()') )

dbSelectArea("DTQ")
dbGoTop()
ProcRegua( RecCount() )

DTR->( dbSetOrder( 1 ) ) //-- Veiculos da Viagem.
DTU->( dbSetOrder( 2 ) ) //-- Movimentos de Veiculos.
DUP->( dbSetOrder( 1 ) ) //-- Motoristas da Viagem.
DTO->( dbSetOrder( 2 ) ) //-- Movimentos de Motoristas.

While !Eof()

	IncProc()
	
	//-- Cancelado pelo operador.
	If lEnd
		Exit
	EndIf
	
	//-- Verifica se a Viagem foi marcada.
	If DTQ->DTQ_OK != cMarca
		dbSelectArea("DTQ")
		dbSkip()
		Loop
	EndIf

	cQuery := "SELECT DISTINCT DTR.DTR_CODVEI, ( SELECT DA3_DESC FROM " + RetSqlName("DA3") + " DA3"
	cQuery += " WHERE  DA3.DA3_FILIAL = '" + xFilial("DA3") + "'"
	cQuery += " AND DA3.DA3_COD = DTR.DTR_CODVEI"
	cQuery += " AND DA3.D_E_L_E_T_ = ' ' ) MODVEI,"
	cQuery += " DTR.DTR_CODRB1, ( SELECT DA3_DESC FROM " + RetSqlName("DA3") + " DA3"
	cQuery += " WHERE DA3.DA3_FILIAL = '" + xFilial("DA3") + "'"
	cQuery += " AND DA3.DA3_COD = DTR.DTR_CODRB1"
	cQuery += " AND    DA3.D_E_L_E_T_ = ' ' ) MODRB1,"
	cQuery += " DTR.DTR_CODRB2, ( SELECT DA3_DESC FROM " + RetSqlName("DA3") + " DA3"
	cQuery += " WHERE DA3.DA3_FILIAL = '" + xFilial("DA3") + "'"
	cQuery += " AND DA3.DA3_COD = DTR.DTR_CODRB2"
	cQuery += " AND DA3.D_E_L_E_T_ = ' ' ) MODRB2"
	If lTercRbq
		cQuery += " ,DTR.DTR_CODRB3, ( SELECT DA3_DESC FROM " + RetSqlName("DA3") + " DA3"
		cQuery += " WHERE DA3.DA3_FILIAL = '" + xFilial("DA3") + "'"
		cQuery += " AND DA3.DA3_COD = DTR.DTR_CODRB3"
		cQuery += " AND DA3.D_E_L_E_T_ = ' ' ) MODRB3"
	EndIf
	cQuery += " FROM " + RetSqlName("DTR") + " DTR"
	cQuery += " WHERE EXISTS( SELECT 1 FROM " + RetSqlName("DTU") + " DTU"
	cQuery += " WHERE DTU.DTU_FILIAL = '" + xFilial("DTU") + "'"
	cQuery += " AND ( DTU.DTU_CODVEI = DTR.DTR_CODVEI"
	cQuery += " OR    DTU.DTU_CODVEI = DTR.DTR_CODRB1"
	cQuery += " OR    DTU.DTU_CODVEI = DTR.DTR_CODRB2"
	If lTercRbq
		cQuery += " OR	DTU.DTU_CODVEI = DTR.DTR_CODRB3 )"
	Else
		cQuey += " ) "
	EndIf
	cQuery += " AND   DTU.DTU_STATUS != '2'"
	cQuery += " AND   DTU.D_E_L_E_T_ = ' ' )"
	cQuery += " AND   DTR.DTR_FILIAL = '" + xFilial("DTR") + "'"
	cQuery += " AND   DTR.DTR_FILORI = '" + DTQ->DTQ_FILORI + "'"
	cQuery += " AND   DTR.DTR_VIAGEM = '" + DTQ->DTQ_VIAGEM + "'"
	cQuery += " AND   DTR.D_E_L_E_T_ = ' '"
	cQuery    := ChangeQuery( cQuery )
	cAliasQry := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	(cAliasQry)->( dbGoTop() )
	While ( cAliasQry )->( !Eof() )
		If lTercRbq
			If !Empty( (cAliasQry)->DTR_CODVEI ) .Or. !Empty( (cAliasQry)->DTR_CODRB1 ) .Or. !Empty( (cAliasQry)->DTR_CODRB2 ) .Or. !Empty( (		cAliasQry)->DTR_CODRB3 )
				Aadd( aListVei, { DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, (cAliasQry)->DTR_CODVEI, (cAliasQry)->MODVEI, (cAliasQry)->DTR_CODRB1, (cAliasQry)->MODRB1, (cAliasQry)->DTR_CODRB2, (cAliasQry)->MODRB2, (cAliasQry)->DTR_CODRB3, (cAliasQry)->MODRB3 } )
			EndIf
		Else
			If !Empty( (cAliasQry)->DTR_CODVEI ) .Or. !Empty( (cAliasQry)->DTR_CODRB1 ) .Or. !Empty( (cAliasQry)->DTR_CODRB2 )
				Aadd( aListVei, { DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, (cAliasQry)->DTR_CODVEI, (cAliasQry)->MODVEI, (cAliasQry)->DTR_CODRB1, (cAliasQry)->MODRB1, (cAliasQry)->DTR_CODRB2, (cAliasQry)->MODRB2 } )
			EndIf
		EndIf
		( cAliasQry )->( dbSkip() )
	EndDo

	(cAliasQry)->( dbCloseArea() )

	cQuery := " SELECT DUP_CODMOT, ( SELECT DA4_NOME FROM " + RetSqlName("DA4") + " DA4"
	cQuery += " WHERE DA4.DA4_FILIAL = '" + xFilial("DA4") + "'"
	cQuery += " AND DA4.DA4_COD = DUP.DUP_CODMOT"
	cQuery += " AND DA4.D_E_L_E_T_ = ' ' ) NOME  FROM " + RetSqlName("DUP") + " DUP"
	cQuery += " WHERE EXISTS( SELECT 1 FROM " + RetSqlName("DTO") + " DTO"
	cQuery += " WHERE DTO.DTO_FILIAL = '" + xFilial("DTO") + "'"
	cQuery += " AND DTO.DTO_CODMOT = DUP.DUP_CODMOT"
	cQuery += " AND DTO.DTO_STATUS != '2'"
	cQuery += " AND DTO.D_E_L_E_T_ = ' ' )"
	cQuery += " AND DUP.DUP_FILIAL = '" + xFilial("DUP") + "'"
	cQuery += " AND DUP.DUP_FILORI = '" + DTQ->DTQ_FILORI + "'"
	cQuery += " AND DUP.DUP_VIAGEM = '" + DTQ->DTQ_VIAGEM + "'"
	cQuery += " AND DUP.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery( cQuery )
	cAliasQry := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
	(cAliasQry)->( dbGoTop() )
	While ( cAliasQry )->( !Eof() )
		Aadd( aListMot, { DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, (cAliasQry)->DUP_CODMOT, (cAliasQry)->NOME } )
		( cAliasQry )->( dbSkip() )
	EndDo
	(cAliasQry)->( dbCloseArea() )
	dbSelectArea("DTQ")
	dbSkip()
EndDo

If Empty( aListMot ) .And. Empty( aListVei )
	Help(' ', 1, 'TMSA14201') //-- "Todos os Veículos e Motoristas foram liberados ou não existe Complemento de Viagem."
	lExibeCon := .F.
EndIf

If lExibeCon

	//-- Inicializa o array, caso esteja em branco.
	If Empty( aListVei )
		Aadd( aListVei, Array( 8 ) )
	EndIf
	
	//-- Inicializa o array, caso esteja em branco.
	If Empty( aListMot )
		Aadd( aListMot, Array( 4 ) )
	EndIf
	
	//-- Calcula as dimensoes dos objetos.
	aSize    := MsAdvSize( .T. )
	aObjects	:= {}
	AAdd(aObjects,{100,50,.T.,.T.,.T.})
	aInfo	   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObjH	:= MsObjSize(aInfo,aObjects,.T.,.F.)
	
	DEFINE MSDIALOG oDlgCon TITLE STR0017 FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL //"Veículos e Motoristas não Liberados."
		//-- Monta o Objeto Folder.
		oFolder:=TFolder():New( aPosObjH[1,1],aPosObjH[1,2],aTitles,aPages,oDlgCon,,,,.T.,.T.,aPosObjH[1,3],aPosObjH[1,4])
	   
		//-- Folder Motoristas.
		@  aPosObjH[1,1]-10, aPosObjH[1,2] LISTBOX oListMot VAR cVar Fields HEADER aHMot[ 1 ], aHMot[ 2 ], aHMot[ 3 ], aHMot[ 4 ] SIZE aPosObjH[1,3], aPosObjH[1,4]-25 Of oFolder:aDialogs[2] PIXEL
		oListMot:SetArray( aListMot )
		oListMot:bLine := { || {	aListMot[oListMot:nAT,1],;
		                          	aListMot[oListMot:nAT,2],;
											aListMot[oListMot:nAT,3],;
											aListMot[oListMot:nAT,4] } }
		//-- Folder Veiculos
		@  aPosObjH[1,1]-10, aPosObjH[1,2] LISTBOX oListVei VAR cVar Fields HEADER aHVei[ 1 ], aHVei[ 2 ], aHVei[ 3 ], aHVei[ 4 ], aHVei[ 5 ], aHVei[ 6 ], aHVei[ 7 ], aHVei[ 8 ], aHVei[ 9 ], aHVei[ 10 ] SIZE aPosObjH[1,3], aPosObjH[1,4]-25 Of oFolder:aDialogs[1] PIXEL
		oListVei:SetArray( aListVei )
		oListVei:bLine := { || {	aListVei[oListVei:nAT,1],;
		                          	aListVei[oListVei:nAT,2],;
											aListVei[oListVei:nAT,3],;
											aListVei[oListVei:nAT,4],;
											aListVei[oListVei:nAT,5],;
											aListVei[oListVei:nAT,6],;
											aListVei[oListVei:nAT,7],;
											aListVei[oListVei:nAT,8],;
											aListVei[oListVei:nAT,9],;
											aListVei[oListVei:nAT,10] } }
	ACTIVATE MSDIALOG oDlgCon ON INIT EnchoiceBar(oDlgCon,{ || ( nOpca:=1, oDlgCon:End() ), nOpca := 0 }, { || oDlgCon:End() })
EndIf

RestArea( aAreaAnt )

Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA142At³ Autor ³ Robson Alves          ³ Data ³ 02/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza os status dos Itens do Agendamento.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS142Atz()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa142Atz()
//-- Controle Gerais.
Local aAreaAnt := GetArea()
Local cSeekDUD := ""

DUD->( dbSetOrder( 2 )  )
DUD->( MsSeek( cSeekDUD := xFilial("DUD") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM ) )

DF1->( dbSetOrder( 3 ) )

While DUD->( !Eof() .And. DUD_FILIAL + DUD_FILORI + DUD_VIAGEM == cSeekDUD )

	If DUD->DUD_STATUS == StrZero( 4, Len( DUD->DUD_STATUS ) ) .Or.;	//-- Encerrado.
		DUD->DUD_STATUS == StrZero( 9, Len( DUD->DUD_STATUS ) ) 		//-- Cancelado.

		DUD->( dbSkip() )
		Loop
	EndIf
	
	If DF1->( MsSeek( xFilial("DF1") + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE ) )
		RecLock( "DF1", .F. )
		DF1->DF1_STACOL := StrZero( 4, Len( DF1->DF1_STACOL ) )
		
		If !Empty( DF1->DF1_CLIDES ) .And. !Empty( DF1->DF1_LOJDES )
			DF1->DF1_STAENT := StrZero( 4, Len( DF1->DF1_STAENT ) )
		EndIf
	EndIf
	DUD->( dbSkip() )
EndDo

RestArea( aAreaAnt )

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TM142Mk  ³ Autor ³ Gilson da Silva       ³ Data ³ 04/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca  registro do Browse.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TM142Mk()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tm142Mk()

Local aArea := GetArea()     

//-- Confirmar a viagem somente na filial de origem.
If DTQ->DTQ_FILORI <> cFilAnt 
	Help(' ', 1,'TMSXFUNA18',,DTQ->DTQ_FILORI,02,22) //-- Manutencoes nesta viagem, somente serao permitidas na filial  
	RestArea(aArea)
	Return 
EndIf

//-- Confirmar a viagem que não provem da Programação de Carregamento.
If AliasInDic("DF8") .And. !Empty(Posicione('DF8',2,xFilial('DF8')+DTQ->(DTQ_FILORI+DTQ_VIAGEM),'DF8_NUMPRG'))
	RestArea(aArea)
	Return 
EndIf 

If IsMark('DTQ_OK', cMarca)
	Reclock('DTQ', .F.)
	DTQ->DTQ_OK := Space(Len(DTQ_OK))
	MsUnlock()
Else
	/* Verifica se o registro n„o est  em uso por outra esta‡„o. */   
	If SoftLock("DTQ")
		DTQ->DTQ_OK := cMarca
	EndIf
EndIf
RestArea(aArea)
Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA142_V  ³ Autor ³ Telso Carneiro       ³ Data ³ 02/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para verificar a ultima versao do fonte   ³±±
±±³			 ³ TMSA142.PRW aplicado no rpo do cliente, assim verificando  ³±±
±±³			 ³ a necessidade de uma atualizacao neste fonte.			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA144Sub 	                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA142_V()
Local nRet := 20061002 // 02 de outubro de 2006
Return nRet 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MenuD142   ³ Autor ³ Telso Carneiro       ³ Data ³ 02/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotinas de menu                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA144Sub 	                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MenuD142()

Local aRotina	:= {	{ STR0002 , "AxPesqui"   ,0, 1},; //"Pesquisar"
								{ STR0003, "TMSA142Mnt" ,0, 2},; //"Visualizar"
								{ STR0004 , "TMSA142Mnt" ,0, 3},; //"Confirmar"
								{ STR0005 , "TMSA142Mnt" ,0, 4} } //"Consultar"
Return(aRotina)
