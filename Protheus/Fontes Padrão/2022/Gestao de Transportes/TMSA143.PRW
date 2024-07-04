#INCLUDE "TMSA143.ch"
#INCLUDE 'PROTHEUS.CH'
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA143  ³ Autor ³ Robson Alves          ³ Data ³ 12/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grafico de Gantt - Carga Fechada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS143()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA143()
//-- FormBatch
Local cPerg     := "TMX143"
Local aSays		 := {}
Local aButtons	 := {}
Local nOpca     := 0
Local lExistCpo := ( DTR->( FieldPos("DTR_DATINI") ) > 0 )
Local aHlpPor1     :=  {"Não foram encontrados alguns campos ","utilizados por esse programa, favor ","atualizar a base"}
Local aHlpEsp1     :=  {"No fueron encontrado algunos campos","utilizados por este programa, favor ","actualizar la base"}
Local aHlpIng1     :=  {"Some fields were not found ","used by this program, please ","update the base"}
Local aHlpPor2     :=  {"Não é permitido manutenções em Viagens","com o Serv. Transp. diferente de : "}
Local aHlpEsp2     :=  {"No es permitido mantencion en viajes","con el Serv. Transporte diferente de :"}
Local aHlpIng2     :=  {"Maintenance in Trips is not allowed","with Transp. Serv. different from: "}
Local aHlpPor3     :=  {"Informe se o tipo da frota para o ","processamento será Todas, "," Própria, Terceiro ou Agregado." } 
Local aHlpSpa3     :=  {"Informe is el tipo de flota "," para el proceso sera Todos, "," Propios, Terceros o Agregados." }
Local aHlpEng3     :=  {"Enter if the fleet type for processing ","will be all, own, third parties"," or added." }
Local aHlpPor4     :=  {"Recalcula o Tempo das Viagens" } 
Local aHlpSpa4     :=  {"Recalcula Tempo de los Viajes" }
Local aHlpEng4     :=  {"Recalculate Period the trip" }
Local aHlpPor5     :=  {"Informe o modelo de viagem que deseja  ","utilizar ao selecionar a rotina"," de operações de viagem." } 
Local aHlpSpa5     :=  {"Informe el modelo de viaje que desea   "," utilizar al seleccionar la rutina"," de operación de viaje." }
Local aHlpEng5     :=  {"Informe o modelo de viagem que deseja  ","utilizar ao selecionar a rotina"," de operações de viagem." }
Local aHlpPor6     :=  {"Informe o metodo de apresentação dos veículos"}
Local aHlpEng6     :=  {"Informe el modelo de Presentacion" }
Local aHlpSpa6     :=  {"Informe o metodo de apresentação dos veículos"}

//Ajuste de Novos Helps
PutHelp("PTMSA14301",aHlpPor1,aHlpIng1,aHlpEsp1,.F.)
PutHelp("PTMSA14302",aHlpPor2,aHlpIng2,aHlpEsp2,.F.)

//-- MsDialog
Private cCadastro  := STR0001 //"Gráfico de Gantt"
Private lContVei   := GetMV('MV_CONTVEI',,.T.) // Parametro para verificar se o sistema devera' controlar veiculo/motorista
Private nModViagem := 1
Private cFiltro    := '' // Nao retirar ( Usado na TMSA144 )

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}

aAdd(aHelpPor,"Para a opção Veículos liberados ter ")
aAdd(aHelpPor,"efeito é necessário ter o parâmentro")
aAdd(aHelpPor," MV_CONTVEI ativado")

aAdd(aHelpSpa,"Para opcion vehiculos liberados tenga ")
aAdd(aHelpSpa,"efecto es necesario tener paramentro")
aAdd(aHelpSpa," MV_CONTVEI activado")

aAdd(aHelpEng,"For the option Released Vehicles to be")
aAdd(aHelpEng," effective, the parameter MV_CONTVEI ")
aAdd(aHelpEng,"must be enabled.")
   
Pergunte(cPerg,.F.)
If lExistCpo
	Aadd( aSays, STR0002 ) //"Este programa tem como objetivo, montar o Gráfico de Gantt, "
	Aadd( aSays, STR0003 ) //"com os dados das Viagens cadastradas no sistema. "
		
	Aadd( aButtons, { 5, .T., {|| Pergunte(cPerg) } } )
	Aadd( aButtons, { 1, .T., {|o| nOpca := 1, o:oWnd:End() } } )
	Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
		
	FormBatch( cCadastro, aSays, aButtons )
	
	nModViagem := mv_par04  //Indica o modelo de viagem ue sera utilizado ao selecionar o botao que acessa as rotinas de viagem	

	If nOpca == 1
		If mv_par06 == 2 // Todos Servicos de Transporte ?
			cCadastro += " - " + TMSValField( "cSerTms",.F.,,.F. ) + " - " + TMSValField( "cTipTra",.F.,,.F. )
		EndIf
		Processa( { | lEnd | Tmsa143Prc( @lEnd ) }, cCadastro, STR0004, .T. ) //"Montando Gráfico de Gantt..."
	EndIf
Else
	Help(" ",1,"TMSA14301") //"Nao foram encontrados alguns campos utilizados por esse programa, favor atualizar a base"
EndIf

Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA143Pr³ Autor ³ Robson Alves          ³ Data ³ 12/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de Processamento.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS143Prc( ExpL1 )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpL1 = Flag para cancelar o processo.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa143Prc( lEnd )
//-- Controle de Dimensoes
Local aSize    := {}
Local aObjects := {}
Local aPosObj  := {}
Local aInfo    := {}
//-- Controle da funcao PmsGantt
Local nTsk
Local dIni := dDataBase
Local aButtons := {}
Local aConfig  := {-1,.T.,.T.,.T.,.F.,.F.,"1","1",.T.}
Local oDlg, oBold
Local lTm143BUT  := ExistBlock('TM143BUT')
Local aButTmp    := {}    
Local nCntFor    := 0

Private aGantt   := {}
Private oGantt
Private bRfshGantt //variavel utilizada no PMSGANTT para fazer o refresh
Private bOldRfGnt  //variavel utilizada no PMSGANTT para fazer o refresh

DEFINE FONT oBold NAME "Arial" BOLD

//-- Gera o array utilizado na funcao PmsGantt.


Aadd(aButtons, { 'NOCHECKED' ,{ || TmsA140Leg() }, STR0013 , STR0008 } )		//"Legenda da Viagem"
Aadd(aButtons,	{ 'BMPINCLUIR',{ || Tmsa143Mnt( ,3 ) }, STR0009 , STR0007 } )	//"Incluir Viagem"

//-- Ponto de Entrada para adicionar botoes
If lTm143BUT
	aButTmp := ExecBlock("TM143BUT",.F.,.F.)
	If ValType(aButTmp) == "A" .And. Len(aButTmp) > 0
		For nCntFor := 1  To Len(aButTmp)
			AAdd(aButtons,aButTmp[nCntFor])
		Next
	EndIf
EndIf

//-- Calcula as dimensoes da tela.
aSize    := MsAdvSize( .T. )
aObjects	:= {}
AAdd(aObjects,{100,50,.T.,.T.,.T.})
aInfo	   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
aPosObjH	:= MsObjSize(aInfo,aObjects,.T.,.F.)

DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM aSize[7],00 TO aSize[6],aSize[5]-30
	Tmsa143Atz( ,, oBold )                                                                                                   
	PmsGantt(aGantt,aConfig,@dIni,,oDlg,{14,1,(aSize[6]/2)-40,(aSize[5]/2)-4},{{If(mv_par05==1,STR0014,STR0022),30},{"",75}},@nTsk,,"" ,@oGantt) //"VEICULOS - MODELO - PLACA"

	//-- Atualiza os dados aGantt quando é utilizado o botao Refresh
	bOldRfGnt  := bRfshGantt 
	bRfshGantt := {|| (aGantt:={}),Tmsa143Atz( ,, oBold ), Eval(bOldRfGnt)} 

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End() },{|| oDlg:End() },,aButtons)

Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA143Co³ Autor ³ Robson Alves          ³ Data ³ 16/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem a cor da tarefa do Gantt.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS143Cor( ExpC1 )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 = Status da Viagem.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa143Cor( cStatus )
//-- Controles Gerais.
Local aCores := {}
Local cCor   := {}
Local nSeek  := 0
If Empty(cStatus)
	cStatus := StrZero( 1, Len( DTQ->DTQ_STATUS ) )
EndIf
Aadd( aCores, { StrZero( 1, Len( DTQ->DTQ_STATUS ) ), RGB(0,255,0)	} )		//'Em Aberto'
Aadd( aCores, { StrZero( 5, Len( DTQ->DTQ_STATUS ) ), RGB(255,74,74) 	} )	//"Fechada"
Aadd( aCores, { StrZero( 2, Len( DTQ->DTQ_STATUS ) ), RGB(255,255,4)	} )	//'Em Transito'
Aadd( aCores, { StrZero( 4, Len( DTQ->DTQ_STATUS ) ), RGB(255,128,0) } )		//"Chegada em Filial"

If ( nSeek := Ascan( aCores, { |x| x[1] == cStatus } ) ) > 0
	cCor   := aCores[ nSeek, 2 ]
EndIf

Return ( cCor )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA143Mn³ Autor ³ Robson Alves          ³ Data ³ 16/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Habilita o Menu para manutenção na Viagem.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS143Prc( ExpN1 )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 = Recno da Viagem - DTQ.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa143Mnu( nReg )
//-- CheckBox
Local lVis := .F.
Local lAlt := .F.
Local lExc := .F.
Local oVis, oAlt, oExc
//-- Dialog
Local oDlgMnu
//-- Controles Gerais
Local nOpcA := 0

//-- Posiciona a Viagem para montar o Caption.
DTQ->( MsGoTo( nReg ) )
DTQ->( dbSetOrder( 2 ) )

DEFINE MSDIALOG oDlgMnu FROM 00,00 TO 128,195 PIXEL TITLE STR0015 + DTQ->DTQ_FILORI + "-" + DTQ->DTQ_VIAGEM //"Viagem : "
	@ 005,005 TO 50, 94 LABEL STR0016 OF oDlgMnu PIXEL //'Escolha a opção desejada :'
	
	@ 013,015 CHECKBOX oVis VAR lVis PROMPT STR0017 OF oDlgMnu PIXEL SIZE 60,09 ON CLICK( ( lAlt := .F.,lExc := .F., oAlt:Refresh(), oExc:Refresh() ),.T.) //"&Visualizar"
	@ 023,015 CHECKBOX oAlt VAR lAlt PROMPT STR0018    OF oDlgMnu PIXEL SIZE 60,09 ON CLICK( ( lVis := .F.,lExc := .F., oVis:Refresh(), oExc:Refresh() ),.T.) //"&Alterar"
	@ 033,015 CHECKBOX oExc VAR lExc PROMPT STR0019    OF oDlgMnu PIXEL SIZE 60,09 ON CLICK( ( lVis := .F.,lAlt := .F., oVis:Refresh(), oAlt:Refresh() ),.T.) //"&Excluir"

	DEFINE SBUTTON FROM 51,068 TYPE 1 OF oDlgMnu ENABLE ACTION (nOpcA := 1, oDlgMnu:End())
ACTIVATE MSDIALOG oDlgMnu CENTERED

If nOpcA == 1
	Do Case
		Case lVis
			Tmsa143Mnt( nReg, 2 )
		Case lAlt
			Tmsa143Mnt( nReg, 4 )
		Case lExc
			Tmsa143Mnt( nReg, 5 )
	EndCase
EndIf

Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA143Mn³ Autor ³ Robson Alves          ³ Data ³ 16/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao nas Viagens do Gantt.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS143Mnt( ExpN1, ExpN2 )                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 = Registro do Viagem - DTQ.                          ³±±
±±³          ³ ExpN2 = Opcao.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa143Mnt( nReg, nOpcx )
//-- Controles Gerais.
Local aAreaDTQ  := DTQ->( GetArea() )
Local lRet      := .T.
//-- Variavel utiliza pela rotina de Viagem.
Private nCarreg	 := 0
Private nTipVia	 := 0
Private cRotaDe	 := ""
Private cRotaAte   := ""
Private cCdrDesDe  := ""
Private cCdrDesAte := ""
Private lDoctoEnd  := .F.

//-- Variavel utilizada pela rotina de Complemento de Viagem.
Private lRefresh	 := .T.	

//--Variaveis utilizadas na rotina de viagem Modelo 2
Private aIndex     := {}                          
Private bFiltraBrw := {|| }
Private aRotina    := {} 
Private lLocaliz   := GetMv('MV_LOCALIZ') == 'S'  

DbSelectArea("DTQ")
DbSetOrder(3)

If nModViagem == 1
	aRotina    := {	{ STR0020,'TmsXPesqui'	,0,1},; //'Pesquisar'
		  					{ STR0021,'TMSA141Mnt'	,0,2},; //'Visualizar'
							{ STR0022,'TMSA141Mnt'	,0,3},; //'Incluir'
							{ STR0012,'TMSA141Mnt'	,0,4},; //'Alterar'
							{ STR0011,'TMSA141Mnt'	,0,5},; //'Excluir'
							{ STR0010,'TMSA140Leg'	,0,6} } //'Legenda'	
Else
	aRotina    := {	{ STR0020,'TmsXPesqui'	,0,1},; //'Pesquisar'
		  					{ STR0021,'TMSA144Mnt'	,0,2},; //'Visualizar'
							{ STR0022,'TMSA144Mnt'	,0,3},; //'Incluir'
							{ STR0012,'TMSA144Mnt'	,0,4},; //'Alterar'
							{ STR0011,'TMSA144Mnt'	,0,5},; //'Excluir'
							{ STR0010,'TMSA140Leg'	,0,6} } //'Legenda'
EndIf

If nOpcX <> 3 .And. mv_par06 == 1 //-- Todos Servicos de Transporte ?
	DTQ->( MsGoTo( nReg ) )
	DTQ->( dbSetOrder( 2 ) )
	cSerTms := DTQ->DTQ_SERTMS
	cTipTra := DTQ->DTQ_TIPTRA
EndIf

If nOpcX == 2 .And. nModViagem == 1
	Altera := .F.
	Inclui := .F.
	DTQ->( MsGoTo( nReg ) )
	DTQ->( dbSetOrder( 2 ) )
	TmsVisViag( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, DTQ->DTQ_SERTMS, DTQ->DTQ_TIPTRA )
ElseIf nOpcX == 2 .And. nModViagem == 2 
	Altera := .F.
	Inclui := .F.
	TMSA144Mnt("DTQ", nReg, 2 )
Else	
	Inclui := ( nOpcx == 3 )
	Altera := ( nOpcx == 4 )
	
	//-- Alteracao e Exclusao.
	If nOpcx != 3
		DTQ->( MsGoTo( nReg ) )
		
		If mv_par06 == 2 .And. ( DTQ->DTQ_SERTMS != cSerTms .Or. DTQ->DTQ_TIPTRA != cTipTra ) // Todos Servicos de Transporte ?
			Help(" ",1,"TMSA14302",,cSerTms + " - " + TMSValField( "cSerTms",.F.,,.F. ) + CHR(13) + CHR(10) + STR0006 + CHR(13) + CHR(10) + cTipTra + " - " + TMSValField( "cTipTra",.F.,,.F. ),2,30) //"Nao e permitido manutencoes em Viagens com o Serv. Transp. diferente de : "###", ou Tipo de Transp. diferente de : "
			lRet := .F.
		EndIf
	EndIf
	
	If lRet
		//-- Coleta ou Entrega.
		If cSerTms == StrZero( 1, Len( DC5->DC5_SERTMS ) ) .Or. cSerTms == StrZero( 3, Len( DC5->DC5_SERTMS ) )
			If nModViagem == 1
				aRet := TmsA141Mnt( "DTQ", nReg, nOpcx )
			Else 
				aRet := TmsA144Mnt( "DTQ", nReg, nOpcx )
				If ValType(aRet) <> "A"
					lRet := .F.
				EndIf
			EndIf
		Else
			If nOpcx != 3                                                    
				Pergunte('TMA144', .F.)
				nCarreg		:= mv_par01
				nTipVia		:= mv_par02
				cRotaDe		:= mv_par03
				cRotaAte		:= mv_par04
				cCdrDesDe	:= mv_par05
				cCdrDesAte	:= mv_par06
				lDoctoEnd   := mv_par07 == 1 //Mostra somente documentos enderecados? 1- Sim 2- Nao
			EndIf
			
			//-- Transporte.
			If nModViagem == 1
				aRet := TmsA140Mnt( "DTQ", nReg, nOpcx )
			Else	
				aRet := TmsA144Mnt( "DTQ", nReg, nOpcx )
				If ValType(aRet) <> "A"
					lRet := .F.
				EndIf
			EndIf	
		EndIf
	EndIf

	Pergunte("TMX143",.F.)
	If nModViagem == 1
		If lRet .And. aRet[1] == 1
			//-- Alteracao e Exclusao.
			If nOpcx != 3
				Tmsa143Del( aRet[2], aRet[3] )
			EndIf
		
			//-- Inclusao e Alteracao.
			If nOpcx != 5
				Tmsa143Atz( aRet[2], aRet[3] )
			EndIf
		EndIf
	ElseIf lRet
		//-- Alteracao e Exclusao.
		If nOpcx != 3
			Tmsa143Del( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM )
		EndIf
	
		//-- Inclusao e Alteracao.
		If nOpcx != 5
			Tmsa143Atz( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM )
		EndIf
	EndIf	
EndIf

Pergunte("TMX143",.F.)

RestArea( aAreaDTQ )

Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA143De³ Autor ³ Robson Alves          ³ Data ³ 16/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui o elemento do array utilizado pela rotina PmsGantt. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS143Del( ExpC1, ExpC2 )                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 = Filial da Viagem.                                  ³±±
±±³          ³ ExpN2 = Numero da Viagem.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa143Del( cFilOri, cViagem )
//-- Controles Gerais.
Local nSeek     := 0
Local nFor      := 0
Local nCountDel := 0

For nFor:=1 To Len(aGantt)
	nSeek := Ascan( aGantt[nFor,2], {  | aTar|  aTar[10] + aTar[11] == cFilOri + cViagem } )

	If nSeek > 0
		aDel( aGantt[nFor,2], nSeek )
		aSize( aGantt[nFor,2], Len( aGantt[nFor,2] ) - 1 )
		nCountDel++
	EndIf         

	If nCountDel == 3
		Exit	
	EndIf
Next nFor

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA143At³ Autor ³ Robson Alves          ³ Data ³ 17/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o array utilizado pela rotina PmsGantt.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS143Atz( ExpC1, ExpC2, ExpO1 )                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 = Filial da Viagem.                                  ³±±
±±³          ³ ExpN2 = Numero da Viagem.                                  ³±±
±±³          ³ ExpO1 = Objeto para definir a fonte.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa143Atz( cFilOri, cViagem, oBold )
//-- Query.
Local cQuery     := ""
Local cAliasQry  := ""
Local cQry2      := ""
//-- Controles Gerais.
Local cVeiculo   := ""
Local cModVei    := ""
Local cReboque1  := ""
Local cModRB1    := ""
Local cReboque2  := ""
Local cModRB2    := ""
Local cReboque3  := ""
Local cModRB3    := ""
Local cStatus    := ""
Local nSeek      := 0
Local cRint      := ""
Local cCodRB1    := ""
Local cCodRB2    := ""
Local cCodRB3	 := ""
Local cNumLib    := ""
Local cTmp       := ""
Local dDatIni    := ""
Local cHorIni	  := ""	 
Local dDatFim    := ""
Local cHorFim	  := ""	 
Local lRecalc    := .F.
Local nQtdVge    := 0
Local nCnt       := 0
Local aReboque   := {}
Local lTercRbq   := DTR->(ColumnPos("DTR_CODRB3")) > 0
//-- IndRegua
Local cIndDTQ    := ""
Local nIndDTQ    := 0
Local cIndDTU    := ""
Local nIndDTU    := 0
Local cCond      := ""
Local cPlcVei    := ""
Local cPlcRb1    := ""
Local cPlcRb2    := ""
Local cPlcRb3	 := ""
Local cDescr     := ""
Local aAreaAnt   := GetArea()

Default oBold    := Nil

If Empty( oBold )
	DEFINE FONT oBold NAME "Arial" BOLD
EndIf

If mv_par01 <> 2 .Or. !lContVei
	cAliasQry := GetNextAlias()
	cQuery := "SELECT DTQ.DTQ_FILORI, DTQ.DTQ_VIAGEM, DTQ.DTQ_TIPVIA, DTQ.DTQ_DATINI, DTQ.DTQ_HORINI,"
	cQuery += " DTQ.DTQ_DATFIM, DTQ.DTQ_HORFIM, DTQ.DTQ_STATUS, DTQ.DTQ_SERTMS, DTQ.R_E_C_N_O_ RECNO, DTR.DTR_CODVEI, DTR.DTR_CODRB1, DTR.DTR_CODRB2"
	If lTercRbq
		cQuery += " ,DTR.DTR_CODRB3 ,"
	EndIf
	If !("DB2" $ TCGetDB())
		cQuery += " NULL NUMLIB, DA3_PLACA PLACAVEI, "	
	Else	
		cQuery += " '" + Space(Len(DTU->DTU_NUMLIB)) + "' NUMLIB, DA3_PLACA PLACAVEI, "
	EndIf	
	cQuery += " DA4.DA4_NOME "
	
	cQuery += " FROM " + RetSqlName("DTQ") + " DTQ, " + RetSqlName("DTR") + " DTR"  
	cQuery += " JOIN " + RetSqlName("DA3") + " DA3 ON " 
	cQuery += " DA3.DA3_FILIAL = '" +xFilial("DA3") + "'"
	cQuery += " AND DA3.DA3_COD = DTR.DTR_CODVEI" 
	If mv_par02 == 2 // Frota Propria
		cQuery += " AND DA3.DA3_FROVEI = '1'" 
	ElseIf mv_par02 == 3 // Frota Terceiro
		cQuery += " AND DA3.DA3_FROVEI = '2'"		 
	ElseIf mv_par02 == 4 // Frota Agregado
		cQuery += " AND DA3.DA3_FROVEI = '3'"
    EndIf	
	cQuery += " AND DA3.DA3_ATIVO ='"+ StrZero(1, Len(DA3->DA3_ATIVO)) +"'"	
	
	cQuery += " 		JOIN "
	cQuery += " 		" +RetSqlName("DUP") + " DUP ON "
	cQuery += " 			DUP_FILIAL     = '"+xFilial("DUP")+"' "
	cQuery += " 			AND DUP_FILORI = DTR.DTR_FILORI "
	cQuery += " 			AND DUP_VIAGEM = DTR.DTR_VIAGEM "
	cQuery += " 			AND DUP_CODVEI = DA3.DA3_COD "
	cQuery += " 	JOIN "
	cQuery += " 		" +RetSqlName("DA4") + " DA4 ON "
	cQuery += " 			DA4_FILIAL  = '"+xFilial("DA4")+"' "
	cQuery += " 			AND DA4_COD = DUP.DUP_CODMOT "
	
	cQuery += " WHERE DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "'"
	If !Empty( cFilOri ) .And. !Empty( cViagem )
		cQuery += " AND DTQ.DTQ_FILORI = '" + cFilOri + "'"
		cQuery += " AND DTQ.DTQ_VIAGEM = '" + cViagem + "'"
	EndIf
	If mv_par06 == 2 //-- Todos Servicos de Transporte
		cQuery += " AND DTQ.DTQ_SERTMS  =  '" + cSerTms + "'"
		cQuery += " AND DTQ.DTQ_TIPTRA  =  '" + cTipTra + "'"
	EndIf
	cQuery += " AND DTQ.DTQ_STATUS != '3'"
	cQuery += " AND DTQ.DTQ_STATUS != '9'"
	cQuery += " AND DTQ.DTQ_DATINI != ' '"
	cQuery += " AND DTQ.DTQ_HORINI != ' '"
	cQuery += " AND DTQ.DTQ_DATFIM != ' '"
	cQuery += " AND DTQ.DTQ_HORFIM != ' '"
	cQuery += " AND DTQ.D_E_L_E_T_ = ' '"
	cQuery += " AND DTR.DTR_FILIAL = '" + xFilial("DTR") + "'"
	cQuery += " AND DTR.DTR_FILORI = DTQ.DTQ_FILORI"
	cQuery += " AND DTR.DTR_VIAGEM = DTQ.DTQ_VIAGEM"
	cQuery += " AND DTR.D_E_L_E_T_ = ' '"
EndIf
If mv_par01 <> 1 .And. lContVei
	If mv_par01 <> 2
		cQuery += " UNION ALL"
	EndIf
	If !("DB2" $ TCGetDB())
		cQuery += " SELECT NULL DTQ_FILORI, NULL DTQ_VIAGEM, "
		cQuery += " NULL DTQ_TIPVIA, " 
		cQuery += " NULL DTQ_DATINI, NULL DTQ_HORINI, " 
		cQuery += " NULL DTQ_DATFIM, NULL DTQ_HORFIM, "
		cQuery += " NULL DTQ_STATUS, NULL DTQ_SERTMS, " + Str(0) + " RECNO , "
		cQuery += " DTU.DTU_CODVEI DTR_CODVEI, NULL DTR_CODRB1, NULL DTR_CODRB2, "
		If lTercRbq
			cQuery += " NULL DTR_CODRB3,"
		EndIf
		cQuery += " DTU.DTU_NUMLIB NUMLIB, DA3_PLACA PLACAVEI, "
		cQuery += " NULL DA4_NOME "
	Else 
		cQuery += " SELECT '"+Space(Len(DTQ->DTQ_FILORI)) +"' DTQ_FILORI, '" + Space(Len(DTQ->DTQ_VIAGEM)) + "' DTQ_VIAGEM, '"
		cQuery += Space(Len(DTQ->DTQ_TIPVIA)) + "' DTQ_TIPVIA, '" 
		cQuery += Space(8) + "' DTQ_DATINI, '" + Space(Len(DTQ->DTQ_HORINI)) +"' DTQ_HORINI, '" 
		cQuery += Space(8) + "' DTQ_DATFIM, '" + Space(Len(DTQ->DTQ_HORFIM)) +"' DTQ_HORFIM, '"
		cQuery += Space(Len(DTQ->DTQ_STATUS)) + "' DTQ_STATUS, '" + Space(Len(DTQ->DTQ_SERTMS)) +"' DTQ_SERTMS, " + Str(0) + " RECNO , "
		cQuery += "DTU.DTU_CODVEI DTR_CODVEI,'"+ Space(Len(DTR->DTR_CODRB1)) + "' DTR_CODRB1, '" + Space(Len(DTR->DTR_CODRB2))+ "' DTR_CODRB2, '" 
		If lTercRbq
			cQuery += + Space(Len(DTR->DTR_CODRB3))+ "' DTR_CODRB3, "
		EndIf
		cQuery += "DTU.DTU_NUMLIB NUMLIB, DA3_PLACA PLACAVEI, '"
		cQuery += Space(40) + "' DA4_NOME "
	EndIf
	
	cQuery += " FROM " + RetSqlName("DTU") + " DTU JOIN " + RetSqlName("DA3") + " DA3 ON"
	cQuery += " DTU_FILIAL = '" + xFilial("DTU") + "' " 
	cQuery += " AND DTU_CODVEI = DA3_COD "
	cQuery += " AND DA3_FILIAL = '" + xFilial("DA3") + "' " 	
	If mv_par02 == 2 // Frota Propria
		cQuery += " AND DA3.DA3_FROVEI = '1'" 
	ElseIf mv_par02 == 3 // Frota Terceiro
		cQuery += " AND DA3.DA3_FROVEI = '2'"		 
	ElseIf mv_par02 == 4 // Frota Agregado
		cQuery += " AND DA3.DA3_FROVEI = '3'"
    EndIf		
	cQuery += " AND DA3_ATIVO  = '" + StrZero(1,Len(DA3->DA3_ATIVO)) + "' " 			
	cQuery += " AND DA3.D_E_L_E_T_ = ' '"
	cQuery += " AND DTU.D_E_L_E_T_ = ' '"
	cQuery += " AND DTU_STATUS     = '" + StrZero(2,Len(DTU->DTU_STATUS) ) + "' " // movimento de veiculos liberados
	cQuery += " JOIN " + RetSqlName("DUT") + " DUT ON "
	cQuery += " DUT_FILIAL = '" + xFilial("DUT") + "' " 
	cQuery += " AND DA3_TIPVEI = DUT_TIPVEI "                                  
	cQuery += " AND DUT_CATVEI <> '" + StrZero(3,Len(DUT->DUT_CATVEI)) + "' " //tipo de veiculo reboque
	cQuery += " AND DUT.D_E_L_E_T_ = ' '"
EndIf
cQuery += " ORDER BY PLACAVEI, DTQ_DATINI, DTQ_HORINI"

cQuery    := ChangeQuery( cQuery )
cAliasQry := GetNextAlias()
dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
		
TCSetField(cAliasQry,"DTQ_DATINI","D",8,0)
TCSetField(cAliasQry,"DTQ_DATFIM","D",8,0)
	
(cAliasQry)->( dbGoTop() )     
While ( cAliasQry )->( !Eof() )
   cVeiculo   := ( cAliasQry )->DTR_CODVEI 
   cReboque1  := ""
	cReboque2  := ""    
	cReboque3	:= ""    
	lRecalc    := .F.                          
	nQtdVge    := 0
   dDatIni    := ( cAliasQry )->DTQ_DATINI 
   cHorIni    := ( cAliasQry )->DTQ_HORINI 
   dDatFim    := ( cAliasQry )->DTQ_DATFIM 
   cHorFim    := ( cAliasQry )->DTQ_HORFIM 
	
	If mv_par03 == 1 //-- Recalcula o Tempo das Viagens
	   cTmp:=Left(StrTran(Time(),":",""),4)
	   //-- Se a Data + Hora Atual forem maior que a Data + Hora Final da Viagem
		If  Dtos(dDataBase)+cTmp > Dtos( dDatFim )+ cHorFim
			lRecalc := .T.   //-- Recalcula a data / hora Final da viagem
		EndIf	
	
		If lRecalc 
		   //-- Diferenca de Tempo 
			cDifTmp := TmsTotHora(dDatFim,cHorFim,dDataBase,cTmp, PesqPict( "DTQ", "DTQ_HORINI"))
			cHorFim := Transform( cHorFim, PesqPict( "DTQ", "DTQ_HORINI" ) )
			//-- Soma a diferenca de tempo 
			SomaDiaHor( @dDatFim, @cHorFim, TmsHrToInt( cDifTmp ) )		
			nQtdVge+=1
		EndIf	
	EndIf
	
	While ( cAliasQry )->DTR_CODVEI == cVeiculo
		If DA3->( MsSeek( xFilial("DA3") + ( cAliasQry )->DTR_CODVEI ) )		
			If Empty( DA3->DA3_DESC )
				cModVei := STR0005 //"Não Informado"
			Else
				cModVei := AllTrim( Left( DA3->DA3_DESC, 20 ) )
			EndIf
			cPlcVei := DA3->DA3_PLACA
			If !Empty((cAliasQry)->NUMLIB )//veiculos sem viagem
				cQry2   := GetNextAlias()
				cQuery := " SELECT DTU_CODVEI FROM " + RetSqlName("DTU")
				cQuery += " WHERE DTU_FILIAL = '" + xFilial("DTU")    + "' "
				cQuery += " AND   DTU_NUMLIB = '" + (cAliasQry)->NUMLIB + "' "
				cQuery += " AND   DTU_CODVEI <>'" + (cAliasQry)->DTR_CODVEI + "' "
				cQuery += " AND   D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cQry2, .T., .T. )
				If (cQry2)->( !Eof() )
					cCodRB1 := ( cQry2 )->DTU_CODVEI
				EndIf
				(cQry2)->( DbSkip() )
				If (cQry2)->( !Eof() )
					cCodRB2 := ( cQry2 )->DTU_CODVEI
				EndIf
				(cQry2)->( DbSkip() )
				If lTercRbq	
					If (cQry2)->( !Eof() )
						cCodRB3 := ( cQry2 )->DTU_CODVEI
					EndIf
				EndIf
				(cQry2)->( DbCloseArea() )
			Else
				cCodRB1 := ( cAliasQry )->DTR_CODRB1
				cCodRB2 := ( cAliasQry )->DTR_CODRB2
				If lTercRbq
					cCodRB3 := ( cAliasQry )->DTR_CODRB3
				EndIf
			EndIf
		EndIf
		If !Empty(cCodRB1) .And. DA3->( MsSeek( xFilial("DA3") + cCodRB1 ) )
			cReboque1 := ( cAliasQry )->DTR_CODRB1
			If Empty( DA3->DA3_DESC )
				cModRb1 := STR0005 //"Não Informado"
			Else
				cModRb1 := AllTrim( Left( DA3->DA3_DESC, 20 ) )
			EndIf
			cPlcRb1 := DA3->DA3_PLACA
		EndIf
			
		If !Empty(cCodRB2) .And. DA3->( MsSeek( xFilial("DA3") + cCodRB2 ) )
			cReboque2 := ( cAliasQry )->DTR_CODRB2
			If Empty( DA3->DA3_DESC )
				cModRb2 := STR0005 //"Não Informado"
			Else
				cModRb2 := AllTrim( Left( DA3->DA3_DESC, 20 ) )
			EndIf
			cPlcRb2 := DA3->DA3_PLACA
		EndIf
		
		If lTercRbq
			If !Empty(cCodRB3) .And. DA3->( MsSeek( xFilial("DA3") + cCodRB3 ) )
				cReboque3 := ( cAliasQry )->DTR_CODRB3
				If Empty( DA3->DA3_DESC )
					cModRb3 := STR0005 //"Não Informado"
				Else
					cModRb3 := AllTrim( Left( DA3->DA3_DESC, 20 ) )
				EndIf
				cPlcRb3 := DA3->DA3_PLACA
			EndIf
		EndIf
		cStatus   := ( cAliasQry )->DTQ_STATUS
		cRint     := ( cAliasQry )->DTQ_FILORI + "-" + ( cAliasQry )->DTQ_VIAGEM + " / " + AllTrim( TMSValField( ( cAliasQry ) + "->DTQ_SERTMS",.F.,,.F. ) );
						 + " - " + ( cAliasQry )->DA4_NOME
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Formato do vetor aGantt                                                ³
		//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		//³ aGantt[1] = Array - Veiculos Alocados                                  ³
		//³ 	aGantt[1,1] = Veiculo/1o Reboque ou 2o Reboque + Modelo              ³
		//³ 	aGantt[1,2] = Texto para exibir ao lado esquedo da tarefa( Viagem )  ³
		//³ 	aGantt[1,3] = Filial Origem da Viagem                                ³
		//³ 	aGantt[1,4] = Numero da Viagem                                       ³
		//³ aGantt[2] = Intervalos das Tarefas( Viagem )                           ³
		//³ 	aGantt[2,1] = Data Inicio da Tarefa( Viagem )                        ³
		//³ 	aGantt[2,2] = Hora Inicio da Tarefa( Viagem )                        ³
		//³ 	aGantt[2,3] = Data Fim da Tarefa( Viagem )                           ³
		//³ 	aGantt[2,4] = Hora Fim da Tarefa( Viagem )                           ³
		//³ 	aGantt[2,5] = Texto para exibir sobre a Tarefa( Viagem )             ³
		//³ 	aGantt[2,6] = Cor da Tarefa( Viagem )                                ³
		//³ 	aGantt[2,7] = Ação ao clicar na Tarefa( Viagem )                     ³
		//³ 	aGantt[2,8] = Indica onde o texto do 5o elemento sera exibido        ³
		//³ 		1 = Ao lado da Tarefa( Viagem ) ou 2 = Sobre a Tarefa( Viagem ).  ³
		//³ 	aGantt[2,9] = Cor do cabecalho do Grafico                            ³
		//³ aGantt[3] = Elemento nao utilizado                                     ³
		//³ aGantt[4] = Tipo da Font utilizada                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  	If lTercRbq  
			cChave  := cVeiculo + cReboque1 + cReboque2 + cReboque3
		Else 
			cChave  := cVeiculo + cReboque1 + cReboque2
		EndIf
		nSeek   := Ascan( aGantt, {  | aTar|  aTar[1,3] == cChave } )
		dDatIni := ( cAliasQry )->DTQ_DATINI
		cHorIni := ( cAliasQry )->DTQ_HORINI						
		
		If !lRecalc 
			dDatFim := ( cAliasQry )->DTQ_DATFIM
			cHorFim := ( cAliasQry )->DTQ_HORFIM		
		EndIf	                            
		
		//-- So' recalcula o tempo a partir da 2a. Viagem do veiculo, pois a diferenca de tempo
		//-- da 1a. Viagem ja' foi recalculada anteriormente	
		If mv_par03 == 1 .And. lRecalc .And. nQtdVge > 1           
			dDatFim := ( cAliasQry )->DTQ_DATFIM
			cHorFim := Transform( ( cAliasQry )->DTQ_HORFIM, PesqPict( "DTQ", "DTQ_HORINI" ) )
			//-- Soma a diferenca de tempo da 1a. Viagem 
			SomaDiaHor( @dDatFim, @cHorFim, TmsHrToInt( cDifTmp ) )				
		EndIf	                                                         
		cHorFim:=Left(StrTran(cHorFim,":",""),4)
		nQtdVge+=1
			                                     		
		If nSeek == 0
			//-- Adiciona o Veiculo e sua tarefa.
			If mv_par05 == 1 //-- Veiculo + Placa
				cDescr := SubStr((cVeiculo + " - " + cModVei + " - " + cPlcVei),1,35)
			Else //-- Placa + Veiculo
				cDescr := SubStr((cPlcVei + " - " + cVeiculo + " - " + cModVei),1,35)
			EndIf
			If Empty( (cAliasQry)->NUMLIB )
				Aadd( aGantt,	{ { cDescr, "", cChave },;
								{ {dDatIni,cHorIni,dDatFim,cHorFim,cRint,Tmsa143Cor( cStatus ),"Tmsa143Mnu(" + Str( ( cAliasQry )->RECNO ) + ",aGantt)",3,CLR_GRAY, ( cAliasQry )->DTQ_FILORI, ( cAliasQry )->DTQ_VIAGEM } },, oBold } )
	
			Else
				Aadd( aGantt,	{ { cDescr, "", cChave },;
								{ {dDatIni,cHorIni,dDatFim,cHorFim,cRint,Tmsa143Cor( cStatus ),"Tmsa143Mnu(" + Str( ( cAliasQry )->RECNO ) + ",aGantt)",3,CLR_GRAY, ( cAliasQry )->DTQ_FILORI, ( cAliasQry )->DTQ_VIAGEM } },, oBold } )
			EndIf
			If !Empty( cReboque1 )
				If mv_par05 == 1 //-- Veiculo + Placa
					cDescr := SubStr((cReboque1 + " - " + cModRB1 + " - " + cPlcRB1),1,35)
				Else //-- Placa + Veiculo
					cDescr := SubStr((cPlcRB1 + " - " + cReboque1 + " - " + cModRB1),1,35)
				EndIf
				//-- Adiciona o 1o Reboque e sua tarefas.
				Aadd( aGantt,	{ { Space( 3 ) + cDescr  , "", ( cAliasQry )->DTQ_FILORI, ( cAliasQry )->DTQ_VIAGEM, "" },;
							   { {dDatIni,cHorIni,dDatFim,cHorFim,cRint,Tmsa143Cor( cStatus ),"Tmsa143Mnu(" + Str( ( cAliasQry )->RECNO ) + ",aGantt)",3,CLR_GRAY, ( cAliasQry )->DTQ_FILORI, ( cAliasQry )->DTQ_VIAGEM } },,} )
			EndIf
	
			If !Empty( cReboque2 )
				If mv_par05 == 1 //-- Veiculo + Placa
					cDescr := SubStr((cReboque2 + " - " + cModRB2 + " - " + cPlcRB2),1,35)
				Else //-- Placa + Veiculo
					cDescr := SubStr((cPlcRB2 + " - " + cReboque2 + " - " + cModRB2),1,35)
				EndIf
				//-- Adiciona o 2o Reboque e sua tarefas.
				Aadd( aGantt,	{ { Space( 3 ) + cDescr  , "", ( cAliasQry )->DTQ_FILORI, ( cAliasQry )->DTQ_VIAGEM, "" },;
									{ {dDatIni,cHorIni,dDatFim,cHorFim,cRint,Tmsa143Cor( cStatus ),"Tmsa143Mnu(" + Str( ( cAliasQry )->RECNO ) + ",aGantt)",3,CLR_GRAY, ( cAliasQry )->DTQ_FILORI, ( cAliasQry )->DTQ_VIAGEM } },,} )
			EndIf
			If !Empty( cReboque3 )
				If mv_par05 == 1 //-- Veiculo + Placa
					cDescr := SubStr((cReboque3 + " - " + cModRB3 + " - " + cPlcRB3),1,35)
				Else //-- Placa + Veiculo
					cDescr := SubStr((cPlcRB3 + " - " + cReboque3 + " - " + cModRB3),1,35)
				EndIf
				//-- Adiciona o 3o Reboque e sua tarefas.
				Aadd( aGantt,	{ { Space( 3 ) + cDescr  , "", ( cAliasQry )->DTQ_FILORI, ( cAliasQry )->DTQ_VIAGEM, "" },;
									{ {dDatIni,cHorIni,dDatFim,cHorFim,cRint,Tmsa143Cor( cStatus ),"Tmsa143Mnu(" + Str( ( cAliasQry )->RECNO ) + ",aGantt)",3,CLR_GRAY, ( cAliasQry )->DTQ_FILORI, ( cAliasQry )->DTQ_VIAGEM } },,} )
			EndIf
		Else
			//-- Adiciona nova tarefa ao Veiculo.
			Aadd( aGantt[nSeek, 2], { dDatIni,cHorIni,dDatFim,cHorFim,cRint,Tmsa143Cor( cStatus ),"Tmsa143Mnu(" + Str( ( cAliasQry )->RECNO ) + ",aGantt)",3,CLR_GRAY, ( cAliasQry )->DTQ_FILORI, ( cAliasQry )->DTQ_VIAGEM }  )
			
			//-- Adiciona nova tarefa ao 1o Reboque.
			If !Empty( cReboque1 )
				nSeek += 1
				Aadd( aGantt[nSeek, 2], {dDatIni,cHorIni,dDatFim,cHorFim,cRint,Tmsa143Cor( cStatus ),"Tmsa143Mnu(" + Str( ( cAliasQry )->RECNO ) + ",aGantt)",3,CLR_GRAY, ( cAliasQry )->DTQ_FILORI, ( cAliasQry )->DTQ_VIAGEM }  )
			EndIf
	
			//-- Adiciona nova tarefa ao 2o Reboque.
			If !Empty( cReboque2 )
				nSeek += 1
				Aadd( aGantt[nSeek, 2], {dDatIni,cHorIni,dDatFim,cHorFim,cRint,Tmsa143Cor( cStatus ),"Tmsa143Mnu(" + Str( ( cAliasQry )->RECNO ) + ",aGantt)",3,CLR_GRAY, ( cAliasQry )->DTQ_FILORI, ( cAliasQry )->DTQ_VIAGEM }  )
			EndIf
			//-- Adiciona nova tarefa ao 3o Reboque.
			If !Empty( cReboque3 )
				nSeek += 1
				Aadd( aGantt[nSeek, 2], {dDatIni,cHorIni,dDatFim,cHorFim,cRint,Tmsa143Cor( cStatus ),"Tmsa143Mnu(" + Str( ( cAliasQry )->RECNO ) + ",aGantt)",3,CLR_GRAY, ( cAliasQry )->DTQ_FILORI, ( cAliasQry )->DTQ_VIAGEM }  )
			EndIf
		EndIf
	
		( cAliasQry )->( dbSkip() )
	EndDo
EndDo
(cAliasQry)->( dbCloseArea() )

If Empty( aGantt )
	//-- Adiciona um elemento em branco, somente para exibir o Gantt sem nenhuma tarefa.
	Aadd( aGantt,	{ { "", "", "" },;
						{ {Ctod(""),"", Ctod(""),"","","","",3,CLR_GRAY, "", "" } },, oBold } )
EndIf

RestArea(aAreaAnt)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA143A ³ Autor ³ Robson Alves          ³ Data ³16.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gantt - Coleta Rodoviario .                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA143A()

Private cSerTms := StrZero(1,Len(DC5->DC5_SERTMS))
Private cTipTra := StrZero(1,Len(DC5->DC5_TIPTRA))

TmsA143( cSerTms, cTipTra )

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA143B ³ Autor ³ Robson Alves          ³ Data ³16.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gantt - Transporte Rodoviario                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA143B()

Private cSerTms := StrZero(2,Len(DC5->DC5_SERTMS))
Private cTipTra := StrZero(1,Len(DC5->DC5_TIPTRA))

TmsA143( cSerTms, cTipTra )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA143C ³ Autor ³ Robson Alves          ³ Data ³16.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gantt - Entrega Rodoviario                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA143C()

Private cSerTms := StrZero(3,Len(DC5->DC5_SERTMS))
Private cTipTra := StrZero(1,Len(DC5->DC5_TIPTRA))

TmsA143( cSerTms, cTipTra )

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA143D ³ Autor ³ Robson Alves          ³ Data ³16.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gantt - Coleta Aereo                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA143D()

Private cSerTms := StrZero(1,Len(DC5->DC5_SERTMS))
Private cTipTra := StrZero(2,Len(DC5->DC5_TIPTRA))

TmsA143( cSerTms, cTipTra )

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA143E ³ Autor ³ Robson Alves          ³ Data ³17.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gantt - Transpote Aereo                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA143E()

Private cSerTms := StrZero(2,Len(DC5->DC5_SERTMS))
Private cTipTra := StrZero(2,Len(DC5->DC5_TIPTRA))

TmsA143( cSerTms, cTipTra )

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA143F ³ Autor ³ Robson Alves          ³ Data ³17.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gantt - Entrega Aereo                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA143F()

Private cSerTms := StrZero(3,Len(DC5->DC5_SERTMS))
Private cTipTra := StrZero(2,Len(DC5->DC5_TIPTRA))

TmsA143( cSerTms, cTipTra )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA143G ³ Autor ³ Vitor Raspa           ³ Data ³ 22.Dez.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gantt - Entrega Fluvial                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA143G()

Private cSerTms := StrZero(3,Len(DC5->DC5_SERTMS))
Private cTipTra := StrZero(3,Len(DC5->DC5_TIPTRA))

TmsA143( cSerTms, cTipTra )

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA143De³ Autor ³ Robson Alves          ³ Data ³ 27/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a descricao e a placa do veiculo, 1o Reboque ou    ³±±
±±³          ³2o Reboque.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS143Desc( ExpC1 )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 = Codigo do Veiculo, 1o Reboque ou 2o Reboque.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa143Desc( cCodigo )
//-- Controles Gerais.
Local cDescri  := ""

DA3->( dbSetOrder( 1 ) )
If DA3->( MsSeek( xFilial("DA3") + cCodigo ) )
	cDescri := AllTrim( DA3->DA3_DESC ) + '-' + DA3->DA3_PLACA
EndIf

Return( cDescri )
