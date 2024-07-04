// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 128    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#Include "OFIOM350.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFIOM350 º Autor ³ Andre Luis Almeida º Data ³  09/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Agendamento da Oficina                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM350(lAutomatic,lNoMBrowse)
Local cNIdentif := ""
Local aFilAtu    := FWArrFilAtu()
Private aSM0     := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Filiais Todas
Private aRotina  := MenuDef()
Private cCadastro:= STR0001 // Agendamento Oficina
Private nAgeMax  := 1
Private cFilBox  := ""
Private cAgParam := left(GetNewPar("MV_AGPARAM",("0"+"2"+"1"+"07"+"08"+"18"+" XXXXX 1"))+space(17),17) // (0=SemControleHoras/1=ComControleHoras)(1=1Hr/2=30min) (1=Filial/2=Todas) (QtdDias) (HrIni) (HrFin) (Dom) (2a.) (3a.) (4a.) (5a.) (6a.) (Sab) (Ordem Vetor)
Private cOrdVet  := IIf(!Empty(substr(cAgParam,17,1)),substr(cAgParam,17,1),"1") // Ordem do Vetor
Private aOS   := {}
Default lAutomatic := .f.
Default lNoMBrowse := .f.
DbSelectArea("VAI")
DbSetOrder(4)
If Empty(Alltrim(cAgParam))
	cAgParam := "0"+"2"+"1"+"07"+"08"+"18"+" XXXXX 1" // (0=SemControleHoras/1=ComControleHoras) (1=1Hr/2=30min) (1=Filial/2=Todas) (QtdDias) (HrIni) (HrFin) (Dom) (2a.) (3a.) (4a.) (5a.) (6a.) (Sab) (Ordem Vetor)
EndIf
VAI->(DbSetOrder(4))      
VAI->(MsSeek( xFilial("VAI") + __CUSERID ))
nAgeMax := VAI->VAI_AGEMAX
cFilBox := VAI->VAI_BOXAGE
If lNoMBrowse
	dbSelectArea("VSO")
	If ( nOpc <> 0 ) .And. !Deleted()		
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
	EndIf
Else
	SetKey(VK_F7,{|| OM350DTHRA(0) })
	If lAutomatic // Incluir sem precisar entrar no Browse (ex: chamado pelo VEICC500)
		cNIdentif := OM350("VSO",0,3)
	Else
		DbSelectArea("VSO")
		dbSetOrder(1)
		If !Empty(cFilBox)
			If !Empty(VAI->VAI_STAAGE)
				FilBrowse("VSO",{},"VSO->VSO_FILIAL=='"+xFilial("VSO")+"' .and. VSO->VSO_NUMBOX=='"+cFilBox+"' .and. VSO->VSO_STATUS$'"+Alltrim(VAI->VAI_STAAGE)+"'" ) 	// Filtra Box do Usuario e Status
			Else
				FilBrowse("VSO",{},"VSO->VSO_FILIAL=='"+xFilial("VSO")+"' .and. VSO->VSO_NUMBOX=='"+cFilBox+"'" ) 	// Filtra Box do Usuario
			EndIf
			mBrowse( 6, 1,22,75,"VSO",,,,,,OM350L())
			DbSelectArea("VSO")
			dbClearFilter()
		Else
			If !Empty(VAI->VAI_STAAGE)
				FilBrowse("VSO",{},"VSO->VSO_STATUS$'"+Alltrim(VAI->VAI_STAAGE)+"'" ) // Status
				mBrowse( 6, 1,22,75,"VSO",,,,,,OM350L())
				DbSelectArea("VSO")
				dbClearFilter()
			Else
				mBrowse( 6, 1,22,75,"VSO",,,,,,OM350L())
			EndIf
		EndIf
	EndIf
	SetKey(VK_F7,{|| Nil })
EndIf
Return(cNIdentif)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento do menu aRotina							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {}  
Local aRecebe := {}
if ExistBlock("OM350PRO")
	aRotina := {  		{ STR0002 , "AxPesqui" , 0 , 1 },;     // Pesquisar
						{ STR0003 , "OM350V"   , 0 , 2 },;     // Vizualizar
						{ STR0004 , "OM350I"   , 0 , 3 },;     // Incluir
						{ STR0005 , "OM350A"   , 0 , 4 },;     // Alterar
						{ STR0006 , "OM350C"   , 0 , 5 },;     // Cancelar
						{ STR0007 , "OM350L"   , 0 , 0 , 2 },; // Legenda
						{ STR0008 , "OFIOC380" , 0 , 2 },;     // Pesquisa Avancada
						{ STR0009 , "OM350ORC" , 0 , 2 },;     // Orcamento
						{ STR0105 , "OM350OS"  , 0 , 2 },;     // Consulta O.S.
						{ STR0106 , "OM350CONF", 0 , 2 },;     // Confirma Agendam.
						{ STR0176 , "U_OM350PRO" , 0 , 2 },;   // Relatorio de Pré-Ordem de servico.
						{ STR0177 , "OM460PROG"   , 0 , 2},;   // Consulta
						{ STR0178 , "OM460P"   , 0 , 4},;	   // Programação
						{ STR0163 , "OFIXC006" , 0 , 2 }}      // Confirma Presenca
Else
	aRotina := {  		{ STR0002 , "AxPesqui" , 0 , 1 },;     // Pesquisar
						{ STR0003 , "OM350V"   , 0 , 2 },;     // Vizualizar
						{ STR0004 , "OM350I"   , 0 , 3 },;     // Incluir
						{ STR0005 , "OM350A"   , 0 , 4 },;     // Alterar
						{ STR0006 , "OM350C"   , 0 , 5 },;     // Cancelar
						{ STR0007 , "OM350L"   , 0 , 0 , 2 },; // Legenda
						{ STR0008 , "OFIOC380" , 0 , 2 },;     // Pesquisa Avancada
						{ STR0009 , "OM350ORC" , 0 , 2 },;     // Orcamento
						{ STR0105 , "OM350OS"  , 0 , 2 },;     // Consulta O.S.
						{ STR0106 , "OM350CONF", 0 , 2 },;     // Confirma Agendam.
						{ STR0177 , "OM460PROG"   , 0 , 2},;   // Consulta
						{ STR0178 , "OM460P"   , 0 , 4},;	   // Programação
						{ STR0163 , "OFIXC006" , 0 , 2 }}      // Confirma Presenca
Endif              

If ExistBlock("OM350ROT")
	aRecebe := ExecBlock("OM350ROT",.f.,.f.,{aRotina} )
	If ( ValType(aRecebe) == "A" )
		aRotina := aClone(aRecebe)
	EndIf
Endif

Return aRotina

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  OM350?  ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada da Visualizacao, Inclusao, Alteracao e Cancelamento³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM350V(cAlias,nReg,nOpc)   // Visualizacao
	OM350(cAlias,nReg,2)
Return()
Function OM350I(cAlias,nReg,nOpc)   // Inclusao
	OM350(cAlias,nReg,3)
Return()
Function OM350A(cAlias,nReg,nOpc)   // Alteracao
	OM350(cAlias,nReg,4)
Return()
Function OM350C(cAlias,nReg,nOpc)   // Cancelamento
	OM350(cAlias,nReg,5)
Return()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³   OM350  ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Trata Visualizacao, Inclusao, Alteracao e Cancelamento     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM350(cAlias,nReg,nOpc)
Local cNIdentif:= ""
Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor  := 0
Local _ni	   := 0
Local cEnchNView := "VSO_NUMOSV/VSO_NUMIDE/VSO_SEGMOD/VSO_DATREG/VSO_HORREG/VSO_FUNAGE/VSO_NOMAGE/VSO_NUMORC/VSO_DATFIN/VSO_HORFIN"
Local cGetDNView := "VST_CODIGO/VST_TIPO/VST_EXPPEC/VST_EXPSRV/VST_CODMAR/VST_CHASSI/VST_INFREP"
Local aRetPossAge:= {}
Private aMemos := {{"VSO_OBSMEM","VSO_OBSERV"}}
Private oAuxEnchoice
Private oAuxGetDados
Private oAuxDlg
Private aNewBot := {}
If FindFunction("FGX_ALTVEI")
	if GetMv("MV_INCORC") <> "N"
		aNewBot := {{"S4WB007N",{|| OFIOC330() } , STR0158 } ,; // Historico do Veículo na Oficina 
					{"EDITABLE",{|| FS_ALTVEI(nOpc,M->VSO_GETKEY) } , STR0160 } ,; // Alterar Dados do Veiculo
					{"BMPVISUAL",{|| aRetPossAge := FS_POSSAGE(IIf(nOpc==3.or.nOpc==4,1,0)) } , STR0012 } ,; // Possiveis Agendas
					{"CLOCK02",{|| OM350DTHRA(IIf(nOpc==3.or.nOpc==4,1,0)) } , STR0013 + " - <F7>" } ,; // Hrs Disponioveis
					{"INSTRUME",  {|| Processa( {|| OM350INCPR(nOpc) } )  }, STR0143 } } // Inconvenientes / Plano de Revisao
    Else
		aNewBot := {{"S4WB007N",{|| OFIOC330() } , STR0158 } ,; // Historico do Veículo na Oficina 
					{"EDITABLE",{|| FS_ALTVEI(nOpc,M->VSO_GETKEY) } , STR0160 } ,; // Alterar Dados do Veiculo
					{"BMPVISUAL",{|| aRetPossAge := FS_POSSAGE(IIf(nOpc==3.or.nOpc==4,1,0)) } , STR0012 } ,; // Possiveis Agendas
					{"CLOCK02",{|| OM350DTHRA(IIf(nOpc==3.or.nOpc==4,1,0)) } , STR0013 + " - <F7>"  } } // Hrs Disponioveis
    Endif
Else
	if GetMv("MV_INCORC") <> "N"
		aNewBot := {{"S4WB007N",{|| OFIOC330() } , STR0158 } ,; // Historico do Veículo na Oficina 
					{"BMPVISUAL",{|| aRetPossAge := FS_POSSAGE(IIf(nOpc==3.or.nOpc==4,1,0)) } , STR0012 } ,; // Possiveis Agendas
					{"CLOCK02",{|| OM350DTHRA(IIf(nOpc==3.or.nOpc==4,1,0)) } , STR0013 + " - <F7>" } ,; // Hrs Disponioveis
					{"INSTRUME",  {|| Processa( {|| OM350INCPR(nOpc) } )  }, STR0143 } } // Inconvenientes / Plano de Revisao
    Else
		aNewBot := {{"S4WB007N",{|| OFIOC330() } , STR0158 } ,; // Historico do Veículo na Oficina 
					{"BMPVISUAL",{|| aRetPossAge := FS_POSSAGE(IIf(nOpc==3.or.nOpc==4,1,0)) } , STR0012 } ,; // Possiveis Agendas
					{"CLOCK02",{|| OM350DTHRA(IIf(nOpc==3.or.nOpc==4,1,0)) } , STR0013 + " - <F7>" } } // Hrs Disponioveis
    Endif
EndIf
If ( ExistBlock("OM350ABT") )
	aNewBot := ExecBlock("OM350ABT",.f.,.f.,{aNewBot})
EndIf
If FindFunction("FM_NEWBOT")
	FM_NEWBOT("POM350AGE","aNewBot") // Ponto de Entrada de Manutencao da aNewBot - Definicao de Novos Botoes na EnchoiceBar
	// Exemplo de PE
	// Local aRet := {}
	//	aadd(aRet,{"FILTRO",{|| U_FS_teste1()},"BOTAO1"})
	//	return(aRet)
Endif
//
If nOpc == 4 .and. VSO->VSO_STATUS <> "1"
	MsgStop(STR0016+" ( "+UPPER(Alltrim(X3CBOXDESC("VSO_STATUS",VSO->VSO_STATUS)))+" )",STR0015) // Impossivel ALTERAR Agendamento da Oficina com STATUS / Atencao
	Return()
EndIf
If nOpc == 5 .and. VSO->VSO_STATUS <> "1"
	MsgStop(STR0017+" ( "+UPPER(Alltrim(X3CBOXDESC("VSO_STATUS",VSO->VSO_STATUS)))+" )",STR0015) // Impossivel CANCELAR Agendamento da Oficina com STATUS / Atencao
	Return()
EndIf
SetKey(VK_F7,{|| OM350DTHRA(IIf(nOpc==3.or.nOpc==4,1,0)) })

DbSelectArea("VSO")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VSO",.t.) // .t. para carregar campos virtuais
RegToMemory("VST",.t.) // .t. para carregar campos virtuais
aCpoEnchVSO := {}
nOpcE   := nOpc
nOpcG   := nOpc
aHeadAg := {}
aColsAg := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a Modelo 3                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo        := STR0001 // Agendamento Oficina
cAliasEnchoice := "VSO"
cAliasGetD     := "VST"
nOpca          := 0
cLinOk         := "OM350LINHAOK().and.OM350TEMPO(2).and.FG_OBRIGAT()"
cFieldOk       := "OM350FIELDOK().and.OM350TEMPO(2)"
FM_Mod3(cTitulo,cAliasEnchoice,cAliasGetD,@aCpoEnchVSO,,@aHeadAg,@aColsAg,cFieldOk,cLinOk,,,nOpcE,nOpcG,,oMainWnd,@oAuxDlg,@oAuxEnchoice,@oAuxGetDados,cEnchNView,cGetDNView,1,"VST->VST_FILIAL+VST->VST_TIPO+VST->VST_CODIGO",xFilial("VST")+"3"+VSO->VSO_NUMIDE,)
oAuxGetDados:oBrowse:bChange := {|| FG_MEMVAR(oAuxGetDados:aHeader,oAuxGetDados:aCols,oAuxGetDados:nAt)}
oAuxGetDados:oBrowse:bDelete := {|| OM350DELGET().and.OM350TEMPO(2) }
If nOpc <> 3
	VV1->(DbSetOrder(2))
	VV1->(DbSeek(xFilial("VV1")+M->VSO_GETKEY))
	M->VSO_CHAINT := VV1->VV1_CHAINT
	VV1->(DbSetOrder(1))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rubens - 24/03/2010                             ³
	//³Se nao for inclusao, inicializar o M->VST_CODMAR³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	M->VST_CODMAR := VV1->VV1_CODMAR
EndIf
ACTIVATE MSDIALOG oAuxDlg ON INIT EnchoiceBar(oAuxDlg,{ || IIf(FS_TUDOOKTELA(nOpc),(oAuxDlg:End(),nOpca := 1),.f.) }, { || oAuxDlg:End(),nOpca := 0 },,aNewBot)
If nOpca <> 0
	cNIdentif := FS_GRAVAR(nOpc,aRetPossAge)
EndIf
SetKey(VK_F7,{|| OM350DTHRA(0) })
Return(cNIdentif)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OM350FIELDOK³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento FIELDOK		        					        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM350FIELDOK()
If ReadVar()== "M->VST_GRUINC" // Qdo digitar Grupo do Inconveniente, limpar demais campos
	M->VST_CODINC := space(len(VST->VST_CODINC))
	M->VST_DESINC := space(len(VST->VST_DESINC))
	oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VST_CODINC","oAuxGetDados:aHeader")] := M->VST_CODINC
	oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VST_DESINC","oAuxGetDados:aHeader")] := M->VST_DESINC
ElseIf ReadVar()== "M->VST_CODINC" // Qdo Digitar Codigo do Inconveniente, verificar se o mesmo Inconveniente ja foi digitado
	If OM350LINHAOK()
		M->VST_DESINC := Posicione("VSL",1,xFilial("VSL")+VE1->VE1_CODMAR+M->VST_GRUINC+M->VST_CODINC,"VSL_DESINC") 
		if Empty(M->VST_DESINC)
			M->VST_DESINC := Posicione("VSL",1,xFilial("VSL")+space(TamSX3("VE1_CODMAR")[1])+M->VST_GRUINC+M->VST_CODINC,"VSL_DESINC") 
		Endif
		oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VST_DESINC","oAuxGetDados:aHeader")] := M->VST_DESINC
		oAuxGetDados:oBrowse:Refresh()
	Else
		Return(.f.)
	EndIf
ElseIf ReadVar()== "M->VST_DESINC" // Qdo Digitar Descricao do Inconveniente, verificar se a mesma esta vazia
	If Empty(M->VST_DESINC)
		MsgStop(STR0018,STR0015) // Inconveniente sem descricao! / Atencao
		Return(.f.)
	EndIf
	Return(OM350LINHAOK())
EndIf
Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OM350DELGET ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento ao deletar a linha do acols    			        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM350DELGET()
oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[oAuxGetDados:nAt])] := !oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[oAuxGetDados:nAt])]
oAuxGetDados:oBrowse:Refresh()
Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OM350LINHAOK³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento do linhaOK				    			        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM350LINHAOK()
Local ni := 0
Local cGruInc := ""
Local cCodInc := ""
Local cDesInc := ""
For ni := 1 to len(oAuxGetDados:aCols)
	If !oAuxGetDados:aCols[ni,len(oAuxGetDados:aCols[ni])] // Verificar se a Duplicidade entre as Linhas do aCols
		If ReadVar() == "M->VST_GRUINC"
			cGruInc := M->VST_GRUINC
		Else
			cGruInc := oAuxGetDados:aCols[n,FG_POSVAR("VST_GRUINC","oAuxGetDados:aHeader")]
		EndIf
		If ReadVar() == "M->VST_CODINC"
			cCodInc := M->VST_CODINC
		Else
			cCodInc := oAuxGetDados:aCols[n,FG_POSVAR("VST_CODINC","oAuxGetDados:aHeader")]
		EndIf
		If ReadVar() == "M->VST_DESINC"
			cDesInc := M->VST_DESINC
		Else
			cDesInc := oAuxGetDados:aCols[n,FG_POSVAR("VST_DESINC","oAuxGetDados:aHeader")]
		EndIf
		If !Empty(oAuxGetDados:aCols[ni,FG_POSVAR("VST_GRUINC","oAuxGetDados:aHeader")]) .or. !Empty(oAuxGetDados:aCols[ni,FG_POSVAR("VST_CODINC","oAuxGetDados:aHeader")])
			If  ni <> oAuxGetDados:nAt .and. oAuxGetDados:aCols[ni,FG_POSVAR("VST_GRUINC","oAuxGetDados:aHeader")] == cGruInc .and. oAuxGetDados:aCols[ni,FG_POSVAR("VST_CODINC","oAuxGetDados:aHeader")] == cCodInc
				MsgStop(STR0019,STR0015) // Inconveniente ja digitado! / Atencao
				oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[oAuxGetDados:nAt])] := .t.
			EndIf
		Else
			If  ni <> oAuxGetDados:nAt .and. oAuxGetDados:aCols[ni,FG_POSVAR("VST_GRUINC","oAuxGetDados:aHeader")] == cGruInc .and. oAuxGetDados:aCols[ni,FG_POSVAR("VST_CODINC","oAuxGetDados:aHeader")] == cCodInc .and. oAuxGetDados:aCols[ni,FG_POSVAR("VST_DESINC","oAuxGetDados:aHeader")] == cDesInc
				MsgStop(STR0019,STR0015) // Inconveniente ja digitado! / Atencao
				oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[oAuxGetDados:nAt])] := .t.
			EndIf
		EndIf
		oAuxGetDados:oBrowse:Refresh()
	EndIf
Next
Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_TUDOOKTELA³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento do tudoOK				        			         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TUDOOKTELA(nOpc)
Local cQuery  := ""
Local cQAlSQL := "SQLVSO"
Local ni      := 0
Local nj      := 0
Local nResp   := 0
Local lRet    := .t.
Local nQtde   := 0
Local nHorPad := 0
Local nTemPad := 0
Local nCountE := 0
Local dDatRef := dDataBase
Local nHora   := 0
Local nHoraIni:= 0
Local nTempos := 0
Local lOk     := .f.
Local nH      := 0
Local nM      := 0
Local nTmp    := 0
Local aVetDis := {}
If nOpc != 2
	DbSelectArea("VSO")
	For nj:=1 to Len(aCpoEnchVSO)
		If X3Obrigat(aCpoEnchVSO[nj]) .and. Empty(&("M->"+aCpoEnchVSO[nj]))
			Help(" ",1,"OBRIGAT2",,RetTitle(aCpoEnchVSO[nj]),4,1 ) // Campos Obrigatorios
			Return(.f.)
		EndIf
	Next
	For nj:=1 to Len(oAuxGetDados:aCols)
		If !oAuxGetDados:aCols[nj,len(oAuxGetDados:aCols[nj])]
			For ni := 1 to len(oAuxGetDados:aCols) // Verificar se a Duplicidade entre as Linhas do aCols
				If nj <> ni
					If !oAuxGetDados:aCols[ni,len(oAuxGetDados:aCols[ni])]
						If  oAuxGetDados:aCols[nj,FG_POSVAR("VST_GRUINC","oAuxGetDados:aHeader")] == oAuxGetDados:aCols[ni,FG_POSVAR("VST_GRUINC","oAuxGetDados:aHeader")] .and. ;
							oAuxGetDados:aCols[nj,FG_POSVAR("VST_CODINC","oAuxGetDados:aHeader")] == oAuxGetDados:aCols[ni,FG_POSVAR("VST_CODINC","oAuxGetDados:aHeader")] .and. ;
							oAuxGetDados:aCols[nj,FG_POSVAR("VST_DESINC","oAuxGetDados:aHeader")] == oAuxGetDados:aCols[ni,FG_POSVAR("VST_DESINC","oAuxGetDados:aHeader")]
							oAuxGetDados:aCols[ni,len(oAuxGetDados:aCols[ni])] := .t.
							lRet :=.f.
						EndIf
					EndIf
				EndIf
			Next
			If !Empty(oAuxGetDados:aCols[nj,FG_POSVAR("VST_GRUINC","oAuxGetDados:aHeader")]) .and. Empty(oAuxGetDados:aCols[nj,FG_POSVAR("VST_CODINC","oAuxGetDados:aHeader")])
				oAuxGetDados:aCols[nj,len(oAuxGetDados:aCols[nj])] := .t.
				lRet := .f.
			EndIf
			If Empty(oAuxGetDados:aCols[nj,FG_POSVAR("VST_GRUINC","oAuxGetDados:aHeader")]) .and. !Empty(oAuxGetDados:aCols[nj,FG_POSVAR("VST_CODINC","oAuxGetDados:aHeader")])
				oAuxGetDados:aCols[nj,len(oAuxGetDados:aCols[nj])] := .t.
				lRet := .f.
			EndIf
			If Empty(oAuxGetDados:aCols[nj,FG_POSVAR("VST_DESINC","oAuxGetDados:aHeader")]) // Verificar Descricao vazia
				oAuxGetDados:aCols[nj,len(oAuxGetDados:aCols[nj])] := .t.
				lRet := .f.
			EndIf
		EndIf
	Next
	If !lRet
		lRet := .t.
		oAuxGetDados:oBrowse:Refresh()
	EndIf
	If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
		If left(cAgParam,1) == "0" // Sem Controle de Hrs
			While .t.
				cQuery := "SELECT COUNT(*) AS QTDE FROM "+RetSqlName("VSO")+" VSO WHERE VSO.VSO_FILIAL='"+M->VSO_FILIAL+"' AND VSO.VSO_NUMBOX='"+M->VSO_NUMBOX+"' AND "
				cQuery += "VSO.VSO_DATAGE='"+dtos(M->VSO_DATAGE)+"' AND VSO.VSO_HORAGE='"+M->VSO_HORAGE+"' AND VSO.VSO_STATUS IN ('1','2') AND "
				If nOpc == 4 // Altera
					cQuery += "VSO.R_E_C_N_O_<>"+Alltrim(str(VSO->(RecNo())))+" AND "
				EndIf
				cQuery += "VSO.D_E_L_E_T_=' ' "
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
				If !( cQAlSQL )->( Eof() )
					nQtde := ( cQAlSQL )->( QTDE )
				EndIf
				( cQAlSQL )->( DbCloseArea() )
				If nQtde >= nAgeMax
					lRet := .f.
					nResp := Aviso(STR0015,STR0020+": "+M->VSO_FILIAL+CHR(13)+CHR(10)+STR0021+": "+Transform(M->VSO_DATAGE,"@D")+CHR(13)+CHR(10)+STR0022+": "+Transform(M->VSO_HORAGE,"@R 99:99")+STR0023+CHR(13)+CHR(10)+STR0024+": "+M->VSO_NUMBOX+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"1-"+STR0025+CHR(13)+CHR(10)+"2-"+STR0026,{"1-"+STR0090,"2-"+STR0003},3,STR0027) // Atencao / Filial / Data / Hora / hs / Box / Agendar na FILIAL, DATA, HORA e BOX selecionado. / Visualizar o(s) outro(s) agendamento(s) existente(s). / Agendar / Visualizar / Existe(m) outro(s) agendamento(s) para:
					If nResp > 0
						If nResp == 1
							OM350DTHRA(1)
						Else
							FS_VEREXIST(M->VSO_DATAGE,M->VSO_HORAGE,M->VSO_NUMBOX,M->VSO_FILIAL)
						EndIf
					Else
						Exit
					EndIf
				Else
					M->VSO_DATFIN := M->VSO_DATAGE
					M->VSO_HORFIN := Val(M->VSO_HORAGE)+1
					lRet := .t.
					Exit
				EndIf
			EndDo
		Else// If left(cAgParam,1) == "1" // Com Controle de Hrs
			// Verificar turno do tecnico
			// Calcular data e hora final
			// Valida se existe algum agendamento no meio ( DATAGE / HORAGE ate DATFIN / HORFIN )
			DbSelectArea("VON")
			DbSetOrder(1)
			DbSeek( xFilial("VON") + M->VSO_NUMBOX )
			cCodPro := VON->VON_CODPRO
			dDatRef := ( M->VSO_DATAGE - 1 )
			nHora   := Val(M->VSO_HORAGE)
			nHoraIni:= nHora
			nTempos := M->VSO_TEMPAD
			While nTempos > 0 .and. ( dDatRef - M->VSO_DATAGE ) < 30
				dDatRef++
				DbSelectArea("VOE")
				DbSetOrder(1)
				If !DbSeek(xFilial("VOE")+cCodPro+Dtos(dDatRef),.t.)
					If Eof()
						Dbskip(-1)
					EndIf
					While xFilial("VOE") == VOE->VOE_FILIAL .And. !Bof()
						If (( VOE->VOE_FILIAL+VOE->VOE_CODPRO # xFilial("VOE")+cCodPro ) .or. ( VOE->VOE_FILIAL+VOE->VOE_CODPRO == xFilial("VOE")+cCodPro .and. VOE->VOE_DATESC > (dDatRef) ))
							DbSkip(-1)
							Loop
						EndIf
						Exit
					EndDo
				EndIf
				If VOE->VOE_CODPRO == cCodPro
					DbSelectArea("VOH")
					DbSetOrder(1)
					If DbSeek(xFilial("VOH")+VOE->VOE_CODPER)
						For nCountE := 1 To VOH->(FCount())
							If ( "INI" $ VOH->(FieldName(nCountE)) .Or. "FIN" $ VOH->(FieldName(nCountE)) ) .and. !Empty( &( VOH->(FieldName(nCountE)) ) )
								If ( Len(aVetDis) == 0 .Or. !Empty(aVetDis[Len(aVetDis),2]) )
									Aadd( aVetDis, { 0 , 0 , dDatRef })
								EndIf
								If Empty(aVetDis[Len(aVetDis),1])
									aVetDis[Len(aVetDis),1] := &( VOH->(FieldName(nCountE)) )
								ElseIf Empty(aVetDis[Len(aVetDis),2])
									aVetDis[Len(aVetDis),2] := &( VOH->(FieldName(nCountE)) )
								EndIf
							EndIf
						Next
					EndIf
				EndIf
				If Len(aVetDis) # 0 // Adiciona tempo de intervalo
					For ni := 1 to 24
						nHora := nHoraIni + ( ni * 100 ) - 100
						If nHora > 2359
							Exit
						EndIf
						nHorPad := Val( Substr(StrZero(nHora,4),1,2)+StrZero(Val(Substr(StrZero(nHora,4),3,2))/0.6,2) )
						nHorPad := Val( Substr(StrZero(nHorPad,4),1,2)+StrZero(Val(Substr(StrZero(nHorPad,4),3,2))*0.6,2) )
						nTemPad := FS_INCINTERVALO(aVetDis,dDatRef,nHora,dDatRef,nHorPad,nTemPad)
						nHorPad := Val( Substr(StrZero(nHora,4),1,2)+StrZero(Val(Substr(StrZero(nHora,4),3,2))/0.6,2) )
						nHorPad += nTemPad
						nHorPad := Val( Substr(StrZero(nHorPad,4),1,2)+StrZero(Val(Substr(StrZero(nHorPad,4),3,2))*0.6,2) )
						lOk := .t.
						For nCountE := 1 To Len(aVetDis)
							If nHora >= aVetDis[nCountE,1] .And. nHora < aVetDis[nCountE,2]
								lOk := .t.
							Else
								lOk := .f.
							EndIf
							If nHorPad >= aVetDis[nCountE,1] .And. nHorPad <= aVetDis[nCountE,2]
								lOk := .t.
							Else
								lOk := .f.
							EndIf
							If lOk
								If nHora < aVetDis[nCountE,1]
									nHora := aVetDis[nCountE,1]
								EndIf
								// Calculo de Horas / Minutos //
								nH := (Val(left(strzero(aVetDis[nCountE,2],4),2))-Val(left(strzero(nHora,4),2)))
								nM := (Val(right(strzero(aVetDis[nCountE,2],4),2))-Val(right(strzero(nHora,4),2)))
								If nM < 0
									nH -= 1
									nM += 60
								EndIf
								If nM >= 60
									nH += 1
									nM -= 60
								EndIf
								nTmp := val(strzero(nH,2)+strzero(nM,2))
								nH := (Val(left(strzero(nTempos,4),2))-Val(left(strzero(nTmp,4),2)))
								nM := (Val(right(strzero(nTempos,4),2))-Val(right(strzero(nTmp,4),2)))
								If nM < 0
									nH -= 1
									nM += 60
								EndIf
								If nM >= 60
									nH += 1
									nM -= 60
								EndIf
								nTempos := val(strzero(nH,2)+strzero(nM,2))
								ni += Val(left(strzero(aVetDis[nCountE,2],4),2))-Val(left(strzero(nHora,4),2))
								M->VSO_DATFIN := dDatRef
								nH := (Val(left(strzero(aVetDis[nCountE,2],4),2))+IIf(nTempos<0,Val(left(strzero(nTempos,4),2)),0))
								nM := (Val(right(strzero(aVetDis[nCountE,2],4),2))+IIf(nTempos<0,Val(right(strzero(nTempos,4),2)),0))
								If nM < 0
									nH -= 1
									nM += 60
								EndIf
								If nM >= 60
									nH += 1
									nM -= 60
								EndIf
								If val(substr(cAgParam,2,1)) == 1 // ( 1=1 Hora / 2=30 minutos )
									If nM > 0
										nH++
										nM := 0
									EndIf
								Else
									If nM > 30
										nH++
										nM := 0
									EndIf
									If nM > 0
										nM := 30
									EndIf
								EndIf
								M->VSO_HORFIN := val(strzero(nH,2)+strzero(nM,2))
								Exit
							EndIf
							If nTempos < 0
								Exit
							EndIf
						Next
						If nTempos < 0 .or. nHora > 2359
							Exit
						EndIf
					Next
					nHoraIni := 0
				EndIf
			EndDo
			lOk := .t.
			cQuery := "SELECT VSO.VSO_DATAGE , VSO.VSO_HORAGE , VSO.VSO_DATFIN , VSO.VSO_HORFIN FROM "+RetSqlName("VSO")+" VSO WHERE VSO.VSO_FILIAL='"+M->VSO_FILIAL+"' AND "
			cQuery += "VSO.VSO_NUMBOX='"+M->VSO_NUMBOX+"' AND VSO.VSO_STATUS IN ('1','2') AND "
			If nOpc == 4 // Altera
				cQuery += "VSO.R_E_C_N_O_<>"+Alltrim(str(VSO->(RecNo())))+" AND "
			EndIf
			cQuery += "VSO.D_E_L_E_T_=' ' "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
			While !( cQAlSQL )->( Eof() ) .and. lOk
				If dtos(M->VSO_DATAGE)+strzero(val(M->VSO_HORAGE),4) == ( cQAlSQL )->( VSO_DATAGE )+strzero(Val(( cQAlSQL )->( VSO_HORAGE )),4)
					lOk := .f.
					dDatRef := stod(( cQAlSQL )->( VSO_DATAGE ))
					nHora   := Val(( cQAlSQL )->( VSO_HORAGE ))
				ElseIf dtos(M->VSO_DATAGE)+strzero(val(M->VSO_HORAGE),4) < ( cQAlSQL )->( VSO_DATAGE )+strzero(Val(( cQAlSQL )->( VSO_HORAGE )),4)
					If dtos(M->VSO_DATFIN)+strzero(M->VSO_HORFIN,4) > ( cQAlSQL )->( VSO_DATAGE )+strzero(Val(( cQAlSQL )->( VSO_HORAGE )),4)
						lOk := .f.
						dDatRef := stod(( cQAlSQL )->( VSO_DATAGE ))
						nHora   := Val(( cQAlSQL )->( VSO_HORAGE ))
					EndIf
				ElseIf dtos(M->VSO_DATAGE)+strzero(val(M->VSO_HORAGE),4) > ( cQAlSQL )->( VSO_DATAGE )+strzero(Val(( cQAlSQL )->( VSO_HORAGE )),4)
					If dtos(M->VSO_DATAGE)+strzero(val(M->VSO_HORAGE),4) < ( cQAlSQL )->( VSO_DATFIN )+strzero(( cQAlSQL )->( VSO_HORFIN ),4)
						lOk := .f.
						dDatRef := stod(( cQAlSQL )->( VSO_DATAGE ))
						nHora   := Val(( cQAlSQL )->( VSO_HORAGE ))
					EndIf
				EndIf
				( cQAlSQL )->( DbSkip() )
			EndDo
			( cQAlSQL )->( DbCloseArea() )
			If !lOk
				lRet := .f.
				nResp := Aviso(STR0015,STR0020+": "+M->VSO_FILIAL+CHR(13)+CHR(10)+STR0024+": "+M->VSO_NUMBOX+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"1-OK"+CHR(13)+CHR(10)+"2-"+STR0026,{"1-OK","2-"+STR0003},3,STR0027) // Atencao / Filial / Box / OK / Visualizar o(s) outro(s) agendamento(s) existente(s). / OK / Visualizar / Existe(m) outro(s) agendamento(s) para:
				If nResp > 1
					FS_VEREXIST(dDatRef,strzero(nHora,4),M->VSO_NUMBOX,M->VSO_FILIAL)
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
DbSelectArea("VSO")
Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GRAVAR   ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para gravacao do agendamento        			         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAVAR(nOpc,aRetPossAge)
Local cNIdentif := ""
Local lOk := .f.
Local nCont
Private aMotCancel := {}
If nOpc == 3  // Incluir
	Inclui := .t.
	Altera := .f.
ElseIf nOpc == 4 // Alterar
	Inclui := .f.	
	Altera := .t.
EndIf
If nOpc != 2
	DbSelectArea("VSO")
	If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
		RecLock("VSO",IIf(nOpc==3,.t.,.f.))
		FG_GRAVAR("VSO")
		VSO->VSO_FILIAL := xFilial("VSO")
		If nOpc == 3 // Incluir
			VSO->VSO_NUMIDE := GetSXENum("VSO","VSO_NUMIDE")
			ConfirmSX8()
			cNIdentif := VSO->VSO_NUMIDE
		EndIf
		MSMM(VSO->VSO_OBSMEM,TamSx3("VSO_OBSERV")[1],,&(aMemos[1][2]),1,,,"VSO","VSO_OBSMEM")
		MsUnlock()
		OM420GRAVA( oAuxGetDados:aCols , oAuxGetDados:aHeader , "3" , VSO->VSO_NUMIDE , VSO->VSO_CODMAR , VSO->VSO_GETKEY ) // GRAVAR INCONVENIENTE
		If len(aRetPossAge) > 0
			If !Empty(VSO->VSO_GETKEY) .and. Alltrim(aRetPossAge[3]) == Alltrim(VSO->VSO_GETKEY)
				lOk := .t.
			Else
				If MsgYesNo(STR0028+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // O Agendamento
					STR0020+": "+xFilial("VSO")+CHR(13)+CHR(10)+; // Filial
					STR0024+": "+VSO->VSO_NUMBOX+CHR(13)+CHR(10)+; // Box
					STR0021+"/"+STR0022+": "+Transform(dtos(VSO->VSO_DATAGE),"@D")+" "+Transform(VSO->VSO_HORAGE,"@R 99:99")+STR0023+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Data/Hora hs
					STR0029+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Corresponde a possivel agenda
					STR0030+": "+aRetPossAge[4]+"-"+aRetPossAge[5]+" "+aRetPossAge[6]+CHR(13)+CHR(10)+; // Cliente
					STR0031+": "+aRetPossAge[7]+CHR(13)+CHR(10)+; // Fone
					STR0032+": "+aRetPossAge[8]+" - "+Alltrim(aRetPossAge[9])+" - "+Alltrim(aRetPossAge[10])+CHR(13)+CHR(10)+; // Veiculo
					STR0033+": "+aRetPossAge[11]+CHR(13)+CHR(10)+; // Placa
					STR0034+": "+aRetPossAge[3],STR0015) // Chassi / Atencao
					lOk := .t.
				EndIf
			EndIf
			If lOk
				DbSelectArea("VZB")
				DbGoTo(aRetPossAge[1])
				Reclock("VZB",.f.)
				VZB->VZB_STATUS := "2"
				MsUnLock()
			EndIf
			aRetPossAge := {}
		EndIf
		
		// Verifica se deve excluir alguma programaca
		If AliasInDic("VDO")
			VDO->(dbSetOrder(1))
			For nCont := 1 to Len(oAuxGetDados:aCols)
				// Registro Excluido 
				If oAuxGetDados:aCols[nCont,Len(oAuxGetDados:aCols[nCont])]
					dbSelectArea("VDO")
					VDO->(dbSeek(xFilial("VDO") + VSO->VSO_NUMIDE + oAuxGetDados:aCols[nCont,FG_POSVAR("VST_SEQINC","oAuxGetDados:aHeader")]))
					While !VDO->(Eof()) .and. VDO->VDO_NUMAGE == VSO->VSO_NUMIDE .and. VDO->VDO_SEQINC == oAuxGetDados:aCols[nCont,FG_POSVAR("VST_SEQINC","oAuxGetDados:aHeader")]
						RecLock("VDO",.f.,.t.)
						VDO->(dbDelete())
						MsUnLock()
						VDO->(dbSkip())
					End
				EndIf
			Next nCont
			DbSelectArea("VSO")
		EndIf
		//
		
		FS_OM350EMAIL()
	Else // Cancelar
		aMotCancel := OFA210MOT("000003","3","","",.f.) // Filtro da consulta do motivo
		If Len(aMotCancel) > 0 
			M->VSO_OBSERV += IIf(!Empty(M->VSO_OBSERV),CHR(13)+CHR(10),"")+STR0153+": "+aMotCancel[1]+" - "+aMotCancel[2] // Motivo do Cancelamento
			DbSelectArea("VSO")
			RecLock("VSO",.f.)
			VSO->VSO_STATUS := "4" // Cancelado
			VSO->VSO_AGCONF := "3" // Cancelado
			//MSMM(,TamSx3("VSO_OBSERV")[1],,&(aMemos[1][2]),1,,,"VSO","VSO_OBSMEM")
			MSMM(VSO->VSO_OBSMEM,TamSx3("VSO_OBSERV")[1],,&(aMemos[1][2]),1,,,"VSO","VSO_OBSMEM")
			MsUnlock()

			///////////////////////////////////
			// Gravar Motivo de Cancelamento //
			///////////////////////////////////
			OFA210VDT("000003",aMotCancel[1],"3",VSO->VSO_FILIAL,VSO->VSO_NUMIDE,aMotCancel[4])
		EndIf
	EndIf
EndIf
Return(cNIdentif)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³   OM350L    ³ Autor ³ Andre Luis Almeida ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda do browse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM350L(nReg)

Local uRetorno := .t.
Local aLegenda := {{'BR_VERDE'     ,STR0035},; // Agendado
					{'BR_LARANJA'  ,STR0036},; // Orcamento Aberto
					{'BR_AZUL'     ,STR0037},; // OS Aberta
					{'BR_PRETO'    ,STR0038},; // Finalizado
					{'BR_VERMELHO' ,STR0039}}  // Cancelado
If nReg == NIL 	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	AADD( uRetorno , {'VSO->VSO_STATUS=="1"',aLegenda[1,1],aLegenda[1,2]} ) // 1 = Agendado
	AADD( uRetorno , {'VSO->VSO_STATUS=="5"',aLegenda[2,1],aLegenda[2,2]} ) // 5 = Orcamento Aberto
	AADD( uRetorno , {'VSO->VSO_STATUS=="2"',aLegenda[3,1],aLegenda[3,2]} ) // 2 = OS Aberta
	AADD( uRetorno , {'VSO->VSO_STATUS=="3"',aLegenda[4,1],aLegenda[4,2]} ) // 3 = Finalizado
	AADD( uRetorno , {'VSO->VSO_STATUS=="4"',aLegenda[5,1],aLegenda[5,2]} ) // 4 = Cancelado
Else
	BrwLegenda(cCadastro,STR0040,aLegenda) //Legenda
EndIf
Return uRetorno
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_OM350EMAIL³ Autor ³ Andre Luis Almeida ³ Data ³ 13/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envia E-mail confirmando o Agendamento OFICINA             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OM350EMAIL()
Local lOk := .f., lSendOK := .f.
Local cError := ""
Local nCount := 0
Local cMailConta := GETMV("MV_EMCONTA") // Usuario/e-mail de envio
Local cMailServer:= GETMV("MV_RELSERV") // Server de envio
Local cMailSenha := GETMV("MV_EMSENHA") // Senha e-mail de envio
Local lAutentica := GetMv("MV_RELAUTH",,.f.)          // Determina se o Servidor de E-mail necessita de Autenticacao
Local cUserAut   := Alltrim(GetMv("MV_RELAUSR",," ")) // Usuario para Autenticacao no Servidor de E-mail
Local cPassAut   := Alltrim(GetMv("MV_RELAPSW",," ")) // Senha para Autenticacao no Servidor de E-mail
Local cEmail	 := ""
Private cTitulo  := STR0041 // Confirmacao do Agendamento
Private cMensagem := ""
If !Empty(M->VSO_EMAIL)
	cEmail := alltrim(M->VSO_EMAIL)
EndIf
If !Empty(M->VSO_GESTOR)
	DbSelectArea("VAI")
	DbSetOrder(1)
	DbSeek(xFilial("VAI")+M->VSO_GESTOR)
	cEmail += ";"+alltrim(VAI->VAI_EMAIL)
EndIf

If !Empty(M->VSO_EMAIL)
	If !MsgYesNo(STR0042,STR0015) // Deseja enviar e-mail de confirmacao para o cliente? / Atencao
		Return(.t.)
	EndIf
	DbSelectArea("VON")
	DbSetOrder(1)
	DbSeek( xFilial("VON") + M->VSO_NUMBOX )
	DbSelectArea("VAI")
	DbSetOrder(1)
	DbSeek( xFilial("VAI") + VON->VON_CODPRO )
	If ExistBlock("O350EMAIL")                       // Ponto de Entrada para formatacao do email
		ExecBlock("O350EMAIL",.f.,.f.)
	Else // HTML Padrao //
		cMensagem+= "<center><table border=0 width=80%><tr>"
		If !Empty( GetNewPar("MV_ENDLOGO","") )
			cMensagem+= "<td width=20%><img src='" + GetNewPar("MV_ENDLOGO","") + "'></td>"
		EndIf
		cMensagem+= "<td align=center width=80%><font size=3 face='verdana,arial' Color=#0000cc><b>"
		cMensagem+= FWFilialName()+"<br></font></b>"
		cMensagem+= "</td></tr></table><hr width=80%>"
		cMensagem+= "<font size=3 face='verdana,arial' Color=black><b>"+cTitulo+"<br></font></b><hr width=80%><br>"
		cMensagem+= "<table border=0 width=80%><tr>"
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+STR0021+":"+"</font></td>" // Data
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+Transform(M->VSO_DATAGE,"@D")+" - "+FG_CDOW(M->VSO_DATAGE)+"</b></font></td>"
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+STR0022+":"+"</font></td>" // Hora
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+Transform(M->VSO_HORAGE,"@R 99:99")+STR0023+"</b></font></td>"
		cMensagem+= "</tr><tr>"
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+STR0043+":"+"</font></td>" // Tecnico
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+VAI->VAI_NOMTEC+"</b></font></td>"
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+STR0024+":"+"</font></td>" // Box
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+M->VSO_NUMBOX+"</b></font></td>"
		cMensagem+= "</tr></table><br>"
		cMensagem+= "<table border=0 width=80%><tr>"
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+STR0034+":"+"</font></td>" // Chassi
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+M->VSO_GETKEY+"</b></font></td>"
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+STR0033+":"+"</font></td>" // Placa
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+Transform(M->VSO_PLAVEI,VV1->(x3Picture("VV1_PLAVEI")))+"</b></font></td>"
		cMensagem+= "</tr><tr>"
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+STR0044+":"+"</font></td>" // Proprietario
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+M->VSO_NOMPRO+"</b></font></td>"
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+STR0031+":"+"</font></td>" // Fone
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+M->VSO_FONPRO+"</b></font></td>"
		cMensagem+= "</tr><tr>"
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+STR0045+":"+"</font></td>" // Endereco
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+M->VSO_ENDPRO+"</b></font></td>"
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=black>"+STR0046+":"+"</font></td>" // Cidade
		cMensagem+= "<td><font size=3 face='verdana,arial' Color=#0000cc><b>"+M->VSO_CIDPRO+" - "+M->VSO_ESTPRO+"</b></font></td>"
		cMensagem+= "</tr></table><br>"
		If GetNewPar("MV_MOBSEMA","N") == "S" .and. !Empty(M->VSO_OBSERV)
			cMensagem+= "<table border=0 width=80%><tr><td>"
			cMensagem+= "<pre><font size=3 face='verdana,arial' Color=black>"+STR0047+":"+"</font><br>" // Observacao
			cMensagem+= "<font size=2 face='verdana,arial' Color=#0000cc><b>" + M->VSO_OBSERV + "</b></font></pre>"
			cMensagem+= "</td></tr></table>"
		EndIf
		cMensagem+= "<table border=1 width=80%><tr>"
		cMensagem+= "<td bgcolor=#0000cc><font size=1 face='verdana,arial' color=white><b>"+STR0048+"</font></b></td>" // Servicos Agendados
		cMensagem+= "</tr>"
		For nCount := 1 to Len(oAuxGetDados:aCols)
			If !oAuxGetDados:aCols[nCount,Len(oAuxGetDados:aCols[nCount])]
				cMensagem+= "<tr><td><font size=2 face='verdana,arial' color=#0000cc><b>"
				cMensagem+= oAuxGetDados:aCols[nCount,FG_POSVAR("VST_DESINC","oAuxGetDados:aHeader")]
				cMensagem+= "</font></b></td></tr>"
			EndIf
		Next
		cMensagem+= "</table><br><hr width=80%><table border=0 width=80%><tr>"
		cMensagem+= "<td><p align=justify><font size=1 face='verdana,arial' Color=black>"
		cMensagem+= STR0148+" "
		cMensagem+= STR0149+" "
		cMensagem+= STR0150+" "
		cMensagem+= STR0151+".<br>"
		cMensagem+= "A"+" "+FWFilialName()+STR0152+"</p>"
		cMensagem+= "</font></td></tr></table><hr width=80%><table border=0 width=80%><tr>"
		cMensagem+= "<td><font size=1 face='verdana,arial' Color=black>"+STR0035+":"+"</font></td>" // Agendado
		cMensagem+= "<td><font size=1 face='verdana,arial' Color=black>"+M->VSO_NOMAGE+"</font></td>"
		cMensagem+= "<td><font size=1 face='verdana,arial' Color=black>"+STR0021+":"+"</font></td>" // Data
		cMensagem+= "<td><font size=1 face='verdana,arial' Color=black>"+Transform(M->VSO_DATREG,"@D")+"</font></td>"
		cMensagem+= "<td><font size=1 face='verdana,arial' Color=black>"+STR0022+":"+"</font></td>" // Hora
		cMensagem+= "<td><font size=1 face='verdana,arial' Color=black>"+Transform(M->VSO_HORREG,"@R 999:99")+STR0023+"</font></td>" // hs
		cMensagem+= "</tr></table><br></center>"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia e-mail do Evento 003                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cMailConta) .And. !Empty(cMailServer) .And. !Empty(cMailSenha)
		// Conecta uma vez com o servidor de e-mails
		CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk
		If lOk
			lOk := .f.
			If lAutentica
				If !MailAuth(cUserAut,cPassAut)
					MsgStop(STR0049,STR0015) // Erro no envio de e-mail / Atencao
					DISCONNECT SMTP SERVER
				Else
					lOk := .t.
				EndIf
			Else
				lOk := .t.
			EndIf
			If lOk
				// Envia e-mail com os dados necessarios
				SEND MAIL FROM cMailConta to Alltrim(cEmail) SUBJECT (cTitulo) BODY cMensagem FORMAT TEXT RESULT lSendOk
				If !lSendOk
					//Erro no Envio do e-mail
					GET MAIL ERROR cError
					MsgStop(cError,STR0049) // Erro no envio de e-mail
				EndIf
				// Desconecta com o servidor de e-mails
				DISCONNECT SMTP SERVER
			EndIf
		Else
			MsgStop(OemToAnsi(STR0050+" "+chr(13)+chr(10)+cMailServer),STR0015) // Nao foi possivel conectar no servidor de e-mail / Atencao
		EndIf
	EndIf
EndIf
Return(.t.)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OM350VEIC ³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza os Dados do Veiculo no Agendamento da Oficina     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM350VEIC()
Local cSlvAlias := Alias()
Local oVeiculos := DMS_Veiculo():New()

Private aTELA[0][0],aGETS[0]

If Empty(M->VSO_GETKEY)
	Return(.t.)
EndIf

If !FG_POSVEI("M->VSO_GETKEY",)
	return(.t.)
EndIf

lValCampAge := .f.
DBSelectArea("VV1")

// Chassi Bloqueado
If oVeiculos:Bloqueado(VV1->VV1_CHAINT)
	Return .f. // A mensagem já é exibida dentro da função Bloqueado()
EndIf

M->VSO_GETKEY := VV1->VV1_CHASSI

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU)
if SA1->A1_MSBLQL == "1"
	MsgStop(STR0184+CHR(13)+ CHR(10)+SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+SA1->A1_NOME)
    Return(.f.)
Endif    

If !FM_PILHA("FS_POSSAGE")
	If FindFunction("FGX_ALTVEI")
		FGX_ALTVEI("A") // 28/02/2012 - VEIXFUNA - FGX_ALTVEI 
	Else
		FS_ALINVEI("A")
	EndIf
EndIf

If FindFunction("OFA1100016_PesquisaCampanha") .And. VOU->(FieldPos("VOU_SERINT")) > 0
	OFA1100016_PesquisaCampanha(VV1->VV1_CHASSI)
EndIf

DBSelectArea("VV1")
FS_CARREGA()

If Empty(cSlvAlias)
	cSlvAlias := "VSO"
EndIf

dbSelectArea(cSlvAlias)
Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CARREGA³ Autor ³ Andre Luis Almeida    ³ Data ³ 07/03/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega M-> do VSO e VST                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CARREGA()
M->VSO_CHAINT := VV1->VV1_CHAINT
M->VSO_PLAVEI := VV1->VV1_PLAVEI
M->VSO_CODFRO := VV1->VV1_CODFRO
dbSelectArea("VSO")
VV2->(DbSelectArea(1))
VV2->(DbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
VVC->(DbSelectArea(1))
VVC->(DbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))
SA1->(DbSelectArea(1))
SA1->(DbSeek(xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU))
DbSelectArea("VE1")
DbSetOrder(1)
DbSeek(xFilial("VE1") + VV1->VV1_CODMAR)
M->VSO_CODMAR := VE1->VE1_CODMAR
M->VSO_DESMAR := VE1->VE1_DESMAR
M->VSO_MODVEI := VV2->VV2_MODVEI
M->VSO_DESMOD := VV2->VV2_DESMOD
M->VSO_DESCOR := VVC->VVC_DESCRI
M->VSO_PROVEI := SA1->A1_COD
M->VSO_NOMPRO := SA1->A1_NOME
M->VSO_LOJPRO := SA1->A1_LOJA
M->VSO_ENDPRO := SA1->A1_END
M->VSO_CIDPRO := SA1->A1_MUN
M->VSO_ESTPRO := SA1->A1_EST
M->VSO_FONPRO := SA1->A1_TEL
M->VSO_EMAIL  := Left(SA1->A1_EMAIL+space(Len(VSO->VSO_EMAIL)),Len(VSO->VSO_EMAIL))
M->VST_CODMAR := VE1->VE1_CODMAR
Return()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OM350DTHRA³ Autor ³ Andre Luis Almeida    ³ Data ³ 09/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ F7 - Consulta e Retorno dos Horarios Disponiveis           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM350DTHRA(nTipo)
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local aFil    := {}
Private oVerd := LoadBitmap( GetResources(), "BR_VERDE" )
Private oVerm := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private cFil  := IIf(substr(cAgParam,3,1)=="1",xFilial("VSO"),space(len(VSO->VSO_FILIAL)))
Private dDtI  := dDataBase
Private dDtF  := dDataBase+IIf(!Empty(substr(cAgParam,4,2)),Val(substr(cAgParam,4,2)),10)-1
Private lDom  := IIf(!Empty(substr(cAgParam,10,1)),.t.,.f.)
Private lSeg  := IIf(!Empty(substr(cAgParam,11,1)),.t.,.f.)
Private lTer  := IIf(!Empty(substr(cAgParam,12,1)),.t.,.f.)
Private lQua  := IIf(!Empty(substr(cAgParam,13,1)),.t.,.f.)
Private lQui  := IIf(!Empty(substr(cAgParam,14,1)),.t.,.f.)
Private lSex  := IIf(!Empty(substr(cAgParam,15,1)),.t.,.f.)
Private lSab  := IIf(!Empty(substr(cAgParam,16,1)),.t.,.f.)
Private lDST  := .f. // Dia Semana Total
Private lDTT  := .t. // Datas Total
Private lHRT  := .t. // Horas Total
Private lBXT  := .t. // Box's Total
Private nHrI  := IIf(!Empty(substr(cAgParam,6,2)),Val(substr(cAgParam,6,2)),8)
Private nHrF  := IIf(!Empty(substr(cAgParam,8,2)),Val(substr(cAgParam,8,2)),18)
Private aDat  := {} // Data
Private aHor  := {} // Hora
Private aBox  := {} // Box
Private aDisp := {} // Horarios Disponiveis
Private aBoxT := {} // Box Todos
If Empty(cFil)
	aFil := aClone(aSM0)
	aAdd(aFil,"")
	aSort(aFil)
Else
	aAdd(aFil,cFil)
EndIf
If lDom .and. lSeg .and. lTer .and. lQua .and. lQui .and. lSex .and. lSab
	lDST := .t. // Dia Semana Total
EndIf
MENU oOrdMenu POPUP  // Menu Ordem
MENUITEM ("1 - "+STR0021+" + "+STR0022+" + "+STR0020+" + "+STR0024) Action FS_ORDENA("1",.t.) // Data + Hora + Filial + Box
MENUITEM ("2 - "+STR0021+" + "+STR0022+" + "+STR0024+" + "+STR0020) Action FS_ORDENA("2",.t.) // Data + Hora + Box + Filial
MENUITEM ("3 - "+STR0063+" + "+STR0021+" + "+STR0022+" + "+STR0020+" + "+STR0024) Action FS_ORDENA("3",.t.) // Qtde.Utilizada + Data + Hora + Filial + Box
ENDMENU
SetKey(VK_F7,{|| Nil })
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,  20 , .T. , .F. } ) // Topo (Filtros)
aAdd( aObjects, { 0 , 120 , .T. , .F. } ) // Meio (Filtros)
aAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox dos Horarios Disponiveis
aPos := MsObjSize( aInfo, aObjects )
FS_LEVANTA("INICIAL",.f.)
DEFINE MSDIALOG oHoraAgOfi FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0014 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Horarios Disponiveis para o Agendamento Oficina
oHoraAgOfi:lEscClose := .F.
// FILIAL //
@ aPos[1,1]-002,aPos[1,2]+000 TO aPos[1,1]+18,050 LABEL STR0020 OF oHoraAgOfi PIXEL // Filial
@ aPos[1,1]+005,aPos[1,2]+002 MSCOMBOBOX oFil VAR cFil SIZE 40,08 COLOR CLR_BLACK ITEMS aFil OF oHoraAgOfi ON CHANGE FS_LEVANTA("BOX",.t.) PIXEL COLOR CLR_BLUE
// PERIODO //
@ aPos[1,1]-002,aPos[1,2]+047 TO aPos[1,1]+18,aPos[1,2]+138 LABEL STR0051 OF oHoraAgOfi PIXEL // Periodo
@ aPos[1,1]+005,aPos[1,2]+049 MSGET oDtI VAR dDtI PICTURE "@D" VALID( dDtI >= dDataBase .and. FS_LEVANTA("DATA",.t.) ) SIZE 40,06 OF oHoraAgOfi PIXEL COLOR CLR_BLUE
@ aPos[1,1]+005,aPos[1,2]+089 SAY STR0053 SIZE 30,08 OF oHoraAgOfi PIXEL COLOR CLR_BLUE // ate
@ aPos[1,1]+005,aPos[1,2]+097 MSGET oDtF VAR dDtF PICTURE "@D" VALID( dDtF >= dDtI .and. FS_LEVANTA("DATA",.t.) ) SIZE 40,06 OF oHoraAgOfi PIXEL COLOR CLR_BLUE
// HORARIO //
@ aPos[1,1]-002,aPos[1,2]+138 TO aPos[1,1]+18,aPos[1,2]+179 LABEL STR0052 OF oHoraAgOfi PIXEL // Horario
@ aPos[1,1]+005,aPos[1,2]+141 MSGET oHrI VAR nHrI PICTURE "99" VALID( nHrI >= 0 .and. nHrI <= 23 .and. FS_LEVANTA("HORA",.t.) ) SIZE 13,06 OF oHoraAgOfi PIXEL COLOR CLR_BLUE
@ aPos[1,1]+005,aPos[1,2]+155 SAY STR0053 SIZE 30,08 OF oHoraAgOfi PIXEL COLOR CLR_BLUE // ate
@ aPos[1,1]+005,aPos[1,2]+163 MSGET oHrF VAR nHrF PICTURE "99" VALID( nHrF >= nHrF .and. nHrF <= 23 .and. FS_LEVANTA("HORA",.t.) ) SIZE 13,06 OF oHoraAgOfi PIXEL COLOR CLR_BLUE
// DIA DA SEMANA //
@ aPos[1,1]-002,aPos[1,2]+179 TO aPos[1,1]+18,aPos[1,2]+385 LABEL STR0054 OF oHoraAgOfi PIXEL // Dia da Semana
@ aPos[1,1]+005,aPos[1,2]+182 CHECKBOX oDom VAR lDom PROMPT STR0055 OF oHoraAgOfi ON CLICK FS_LEVANTA("DATA",.t.) SIZE 25,08 PIXEL // Dom
@ aPos[1,1]+005,aPos[1,2]+208 CHECKBOX oSeg VAR lSeg PROMPT STR0056 OF oHoraAgOfi ON CLICK FS_LEVANTA("DATA",.t.) SIZE 25,08 PIXEL // Seg
@ aPos[1,1]+005,aPos[1,2]+233 CHECKBOX oTer VAR lTer PROMPT STR0057 OF oHoraAgOfi ON CLICK FS_LEVANTA("DATA",.t.) SIZE 25,08 PIXEL // Ter
@ aPos[1,1]+005,aPos[1,2]+258 CHECKBOX oQua VAR lQua PROMPT STR0058 OF oHoraAgOfi ON CLICK FS_LEVANTA("DATA",.t.) SIZE 25,08 PIXEL // Qua
@ aPos[1,1]+005,aPos[1,2]+283 CHECKBOX oQui VAR lQui PROMPT STR0059 OF oHoraAgOfi ON CLICK FS_LEVANTA("DATA",.t.) SIZE 25,08 PIXEL // Qui
@ aPos[1,1]+005,aPos[1,2]+308 CHECKBOX oSex VAR lSex PROMPT STR0060 OF oHoraAgOfi ON CLICK FS_LEVANTA("DATA",.t.) SIZE 25,08 PIXEL // Sex
@ aPos[1,1]+005,aPos[1,2]+333 CHECKBOX oSab VAR lSab PROMPT STR0061 OF oHoraAgOfi ON CLICK FS_LEVANTA("DATA",.t.) SIZE 25,08 PIXEL // Sab
@ aPos[1,1]+005,aPos[1,2]+359 CHECKBOX oDST VAR lDST PROMPT STR0062 OF oHoraAgOfi ON CLICK FS_LEVANTA("SEMANA",.t.) SIZE 45,08 PIXEL // Todos
// DATA //
@ aPos[2,1]-003,aPos[2,2]+000 TO aPos[3,1]-003,119 LABEL STR0021 OF oHoraAgOfi PIXEL // Data
@ aPos[2,1]+004,aPos[2,2]+001 LISTBOX oLbDat FIELDS HEADER "",STR0054,STR0021 COLSIZES 10,40,40 SIZE 115,aPos[2,3]-aPos[1,3]-8 OF oHoraAgOfi PIXEL ON DBLCLICK FS_TIK("DATA",oLbDat:nAt) // Dia da Semana / Data
oLbDat:SetArray(aDat)
oLbDat:bLine := { || { 	IIf(aDat[oLbDat:nAt,1],oVerd,oVerm) , aDat[oLbDat:nAt,2] , Transform(aDat[oLbDat:nAt,3],"@D") }}
@ aPos[2,1]+004,aPos[2,2]+002 CHECKBOX oDTT VAR lDTT PROMPT "" OF oHoraAgOfi ON CLICK FS_TIK("DATA",0) SIZE 10,08 PIXEL COLOR CLR_BLUE
// HORARIO //
@ aPos[2,1]-003,aPos[2,2]+119 TO aPos[3,1]-003,195 LABEL STR0052 OF oHoraAgOfi PIXEL // Horario
@ aPos[2,1]+004,aPos[2,2]+120 LISTBOX oLbHor FIELDS HEADER "",STR0022 COLSIZES 10,30 SIZE 71,aPos[2,3]-aPos[1,3]-8 OF oHoraAgOfi PIXEL ON DBLCLICK FS_TIK("HORA",oLbHor:nAt) // Hora
oLbHor:SetArray(aHor)
oLbHor:bLine := { || { 	IIf(aHor[oLbHor:nAt,1],oVerd,oVerm) , Transform(aHor[oLbHor:nAt,2],"@R 99:99")+STR0023 }} // hs
@ aPos[2,1]+004,aPos[2,2]+121 CHECKBOX oHRT VAR lHRT PROMPT "" OF oHoraAgOfi ON CLICK FS_TIK("HORA",0) SIZE 10,08 PIXEL COLOR CLR_BLUE
// BOX //
@ aPos[2,1]-003,aPos[2,2]+194 TO aPos[3,1]-003,aPos[3,4]+001 LABEL STR0024 OF oHoraAgOfi PIXEL // Box
@ aPos[2,1]+004,aPos[2,2]+195 LISTBOX oLbBox FIELDS HEADER "",STR0024,STR0043,STR0020 COLSIZES 10,90,100,100 SIZE aPos[3,4]-198,aPos[2,3]-aPos[1,3]-8 OF oHoraAgOfi PIXEL ON DBLCLICK FS_TIK("BOX",oLbBox:nAt) // Box / Tecnico / Filial
oLbBox:SetArray(aBox)
oLbBox:bLine := { || { 	IIf(aBox[oLbBox:nAt,1],oVerd,oVerm) , aBox[oLbBox:nAt,2]+" - "+aBox[oLbBox:nAt,3] , aBox[oLbBox:nAt,4] , aBox[oLbBox:nAt,5]+" - "+aBox[oLbBox:nAt,6] }}
@ aPos[2,1]+004,aPos[2,2]+196 CHECKBOX oBXT VAR lBXT PROMPT "" OF oHoraAgOfi ON CLICK FS_TIK("BOX",0) SIZE 10,08 PIXEL COLOR CLR_BLUE
// HORARIOS DISPONIVEIS //
@ aPos[3,1],aPos[3,2] LISTBOX oLbDisp FIELDS HEADER STR0054,STR0021,STR0022,STR0063,STR0064,STR0024,STR0043,STR0020 COLSIZES 40,40,30,35,35,90,100,100 SIZE aPos[3,4]-2,aPos[3,3]-aPos[2,3]-2 OF oHoraAgOfi PIXEL ON DBLCLICK IIf(FS_RETDTHR(nTipo),oHoraAgOfi:End(),.t.) // Dia da Semana / Data / Hora / Qtd.Utilizada / Qtd.Permitida / Box / Tecnico / Filial
oLbDisp:SetArray(aDisp)
oLbDisp:bLine := { || {	aDisp[oLbDisp:nAt,3] ,;
						Transform(aDisp[oLbDisp:nAt,4],"@D") ,;
						Transform(aDisp[oLbDisp:nAt,5],"@R 99:99")+STR0023 ,; // hs
						FG_AlinVlrs(Transform(aDisp[oLbDisp:nAt,1],"@E 999")) ,;
						FG_AlinVlrs(Transform(aDisp[oLbDisp:nAt,2],"@E 999")) ,;
						aDisp[oLbDisp:nAt,6]+" - "+aDisp[oLbDisp:nAt,7] ,;
						aDisp[oLbDisp:nAt,8] ,;
						aDisp[oLbDisp:nAt,9]+" - "+aDisp[oLbDisp:nAt,10] }}
// ORDEM VETOR (HORARIOS DISPONIVEIS) //
if cVersao == "P10"
	@ aPos[1,1]+005,aPos[1,2]+390 BUTTON oOrd PROMPT (STR0084+": "+cOrdVet) OF oHoraAgOfi SIZE 30,10 PIXEL ACTION FS_MENUORD( oOrd , aPos[1,1] , 10 , oOrdMenu ) // Ordem
	@ aPos[1,1]+005,aPos[1,2]+425 BUTTON oLeg PROMPT (STR0127) OF oHoraAgOfi SIZE 30,10 PIXEL ACTION FS_LEG( oOrd , aPos[1,1] , 10 , oOrdMenu ) // Ordem
	//		@ aPos[1,1]+005,aPos[1,4]-060 BUTTON oSAIR PROMPT STR0074 OF oHoraAgOfi SIZE 30,10 PIXEL ACTION oHoraAgOfi:End() // SAIR
	@ aPos[1,1]+005,aPos[1,2]+460 BUTTON oSAIR PROMPT STR0074 OF oHoraAgOfi SIZE 30,10 PIXEL ACTION oHoraAgOfi:End() // SAIR
Else
	@ aPos[1,1]+005,aPos[1,2]+386 BUTTON oOrd PROMPT (STR0084+": "+cOrdVet) OF oHoraAgOfi SIZE 30,10 PIXEL ACTION FS_MENUORD( oOrd , aPos[1,1] , 10 , oOrdMenu ) // Ordem
	@ aPos[1,1]+005,aPos[1,2]+417 BUTTON oLeg PROMPT (STR0127) OF oHoraAgOfi SIZE 30,10 PIXEL ACTION FS_LEG( oOrd , aPos[1,1] , 10 , oOrdMenu ) // Ordem
	@ aPos[1,1]+005,aPos[1,2]+448 BUTTON oSAIR PROMPT STR0074 OF oHoraAgOfi SIZE 30,10 PIXEL ACTION oHoraAgOfi:End() // SAIR
Endif
oLbDisp:SetFocus()
ACTIVATE MSDIALOG oHoraAgOfi
SetKey(VK_F7,{|| OM350DTHRA(nTipo) })
DbSelectArea("VSO")
Return()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LEVANTA  ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para levantamento dos horarios disponiveis.	         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVANTA(cTipo,lRefresh)
Local nd      := 0
Local nt      := 0
Local ni      := 0
Local dDatRef := ctod("")
Local cQuery  := ""
Local cQAlSQL := "ALIASSQL"
If cTipo == "INICIAL"
	// Levanta Todos Box //
	aBoxT := {}
	cQuery := "SELECT VON.VON_NUMBOX , VOD.VOD_DESSEC , VON.VON_FILIAL , VAI.VAI_CODTEC , VAI.VAI_NOMTEC FROM "+RetSqlName("VON")+" VON "
	cQuery += "LEFT JOIN "+RetSqlName("VOD")+" VOD ON ( VOD.VOD_FILIAL=VON.VON_FILIAL AND VOD.VOD_CODSEC=VON.VON_CODSEC AND VOD.D_E_L_E_T_=' ' ) "
	If ( xFilial("SD2") <> xFilial("VAI") ) // VAI Comparilhado
		cQuery += "LEFT JOIN "+RetSqlName("VAI")+" VAI ON ( VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODTEC=VON.VON_CODPRO AND VAI.D_E_L_E_T_=' ' ) WHERE "
	Else // VAI Exclusivo
		cQuery += "LEFT JOIN "+RetSqlName("VAI")+" VAI ON ( VAI.VAI_FILIAL=VON.VON_FILIAL AND VAI.VAI_CODTEC=VON.VON_CODPRO AND VAI.D_E_L_E_T_=' ' ) WHERE "
	EndIf	
	If !Empty(cFilBox)
		cQuery += "VON.VON_FILIAL='"+xFilial("VON")+"' AND VON.VON_NUMBOX='"+cFilBox+"' AND "
	EndIf
	cQuery += "VON.D_E_L_E_T_=' ' ORDER BY VON.VON_FILIAL , VON.VON_NUMBOX "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	Do While !( cQAlSQL )->( Eof() )
		aAdd(aBoxT,{ ( cQAlSQL )->( VON_NUMBOX ) , ( cQAlSQL )->( VOD_DESSEC ) , ( cQAlSQL )->( VAI_CODTEC )+" - "+left(( cQAlSQL )->( VAI_NOMTEC ),20) , ( cQAlSQL )->( VON_FILIAL ) , FWFilialName() })
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	FS_LEVANTA("DATA",.f.)
	FS_LEVANTA("HORA",.f.)
	FS_LEVANTA("BOX",.f.)
	FS_HORADISP(.f.)
ElseIf cTipo == "SEMANA"
	lSeg := lDST
	lTer := lDST
	lQua := lDST
	lQui := lDST
	lSex := lDST
	lSab := lDST
	lDom := lDST
	If lRefresh
		oSeg:Refresh()
		oTer:Refresh()
		oQua:Refresh()
		oQui:Refresh()
		oSex:Refresh()
		oSab:Refresh()
		oDom:Refresh()
	EndIf
	FS_LEVANTA("DATA",lRefresh)
ElseIf cTipo == "DATA"
	aDat := {}
	If dDtI > dDtF
		dDtF := dDtI
		If lRefresh
			oDtF:Refresh()
		EndIf
	EndIf
	nt := ( dDtF - dDtI )
	For ni := 0 to nt
		dDatRef := (dDtI+ni)
		nd := dow(dDatRef)
		If (nd==1.and.lDom) .or. (nd==2.and.lSeg) .or. (nd==3.and.lTer) .or. (nd==4.and.lQua) .or. (nd==5.and.lQui) .or. (nd==6.and.lSex) .or. (nd==7.and.lSab)
			aAdd(aDat,{lDTT,DIASEMANA(dDatRef),dDatRef})
		EndIf
	Next
	If len(aDat) <= 0
		aAdd(aDat,{.f.,"",ctod("")})
	EndIf
	If lRefresh
		oLbDat:nAt := 1
		oLbDat:SetArray(aDat)
		oLbDat:bLine := { || { 	IIf(aDat[oLbDat:nAt,1],oVerd,oVerm) , aDat[oLbDat:nAt,2] , Transform(aDat[oLbDat:nAt,3],"@D") }}
		oLbDat:Refresh()
		FS_HORADISP(.t.)
	EndIf
ElseIf cTipo == "HORA"
	aHor := {}
	If nHrI > nHrF
		nHrF := nHrI
		If lRefresh
			oHrF:Refresh()
		EndIf
	EndIf
	For ni := nHrI to nHrF
		aAdd(aHor,{lHRT,ni*100})
	Next
	If len(aHor) <= 0
		aAdd(aHor,{.f.,0})
	EndIf
	If lRefresh
		oLbHor:nAt := 1
		oLbHor:SetArray(aHor)
		oLbHor:bLine := { || { 	IIf(aHor[oLbHor:nAt,1],oVerd,oVerm) , Transform(aHor[oLbHor:nAt,2],"@R 99:99")+STR0023 }} // hs
		oLbHor:Refresh()
		FS_HORADISP(.t.)
	EndIf
ElseIf cTipo == "BOX"
	aBox := {}
	For ni := 1 to len(aBoxT)
		If Empty(cFil) .or. cFil==aBoxT[ni,4]
			aAdd(aBox,{lBXT,aBoxT[ni,1],aBoxT[ni,2],aBoxT[ni,3],aBoxT[ni,4],aBoxT[ni,5]})
		EndIf
	Next
	If len(aBox) <= 0
		aAdd(aBox,{.f.,"","","","",""})
	EndIf
	If lRefresh
		oLbBox:nAt := 1
		oLbBox:SetArray(aBox)
		oLbBox:bLine := { || { 	IIf(aBox[oLbBox:nAt,1],oVerd,oVerm) , aBox[oLbBox:nAt,2]+" - "+aBox[oLbBox:nAt,3] , aBox[oLbBox:nAt,4] , aBox[oLbBox:nAt,5]+" - "+aBox[oLbBox:nAt,6] }}
		oLbBox:Refresh()
		FS_HORADISP(.t.)
	EndIf
EndIf
Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK      ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para marcar ou desmarcar horario para agendar.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(cTipo,nLinha)
Local ni := 0
If cTipo == "DATA"
	If len(aDat) > 1 .or. !Empty(aDat[1,2])
		If nLinha == 0
			For ni := 1 to len(aDat)
				aDat[ni,1] := lDTT
			Next
		Else
			aDat[nLinha,1] := !aDat[nLinha,1]
		EndIf
		oLbDat:Refresh()
	EndIf
ElseIf cTipo == "HORA"
	If nLinha == 0
		For ni := 1 to len(aHor)
			aHor[ni,1] := lHRT
		Next
	Else
		aHor[nLinha,1] := !aHor[nLinha,1]
	EndIf
	oLbHor:Refresh()
ElseIf cTipo == "BOX"
	If len(aBox) > 1 .or. !Empty(aBox[1,2])
		If nLinha == 0
			For ni := 1 to len(aBox)
				aBox[ni,1] := lBXT
			Next
		Else
			aBox[nLinha,1] := !aBox[nLinha,1]
		EndIf
		oLbBox:Refresh()
	EndIf
EndIf
FS_HORADISP(.t.)
Return()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_HORADISP ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Horas Disponiveis        						     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_HORADISP(lRefresh)
Local ni := 0
Local nd := 0
Local nh := 0
Local nb := 0
Local aAux := {}
Local nQtdPer := 0
Local nQtde   := 0
Local cQuery  := ""
Local cQAlSQL := "SQLVSO"
aDisp := {}
For nd := 1 to len(aDat) // Data
	If aDat[nd,1]
		For nh := 1 to len(aHor) // Hora
			If aHor[nh,1] .and. ( dDataBase <> aDat[nd,3] .or. left(Time(),2) <= left(strzero(aHor[nh,2],4),2) )
				For nb := 1 to len(aBox) // Box
					If aBox[nb,1]
						For nQtdPer := 1 to val(substr(cAgParam,2,1)) // ( 1=1 Hora / 2=30 minutos )
							If dDataBase <> aDat[nd,3] .or. ( (substr(Time(),1,2)+IIf(substr(Time(),4,2)>="30","30","00")) <= strzero((aHor[nh,2]+((nQtdPer-1)*30)),4) )
								If left(cAgParam,1) == "0" // Sem Controle de Hrs
									nQtde  := 0
									cQuery := "SELECT COUNT(*) AS QTDE FROM "+RetSqlName("VSO")+" VSO WHERE VSO.VSO_FILIAL='"+aBox[nb,5]+"' AND VSO.VSO_NUMBOX='"+aBox[nb,2]+"' AND "
									cQuery += "VSO.VSO_DATAGE='"+dtos(aDat[nd,3])+"' AND VSO.VSO_HORAGE='"+strzero((aHor[nh,2]+((nQtdPer-1)*30)),4)+"' AND "
									cQuery += "VSO.VSO_STATUS IN ('1','2') AND VSO.D_E_L_E_T_=' ' "
									dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
									If !( cQAlSQL )->( Eof() )
										nQtde := ( cQAlSQL )->( QTDE )
									EndIf
									( cQAlSQL )->( DbCloseArea() )
									If nQtde < nAgeMax
										aAdd(aDisp,{nQtde,nAgeMax,aDat[nd,2],aDat[nd,3],aHor[nh,2]+((nQtdPer-1)*30),aBox[nb,2],aBox[nb,3],aBox[nb,4],aBox[nb,5],aBox[nb,6]})
									EndIf
								Else //If left(cAgParam,1) == "1" // Com Controle de Hrs
									aAdd(aDisp,{0,1,aDat[nd,2],aDat[nd,3],aHor[nh,2]+((nQtdPer-1)*30),aBox[nb,2],aBox[nb,3],aBox[nb,4],aBox[nb,5],aBox[nb,6]})
								EndIf
							EndIf
						Next
					EndIf
				Next
			EndIf
		Next
	EndIf
Next
If left(cAgParam,1) == "1" // Com Controle de Hrs
	For ni := 1 to len(aDisp) // Verificar se esta sendo utilizado o horario
		lOk := .t.
		cQuery := "SELECT VSO.VSO_DATAGE , VSO.VSO_HORAGE , VSO.VSO_DATFIN , VSO.VSO_HORFIN FROM "+RetSqlName("VSO")+" VSO WHERE VSO.VSO_FILIAL='"+aDisp[ni,9]+"' AND "
		cQuery += "VSO.VSO_NUMBOX='"+aDisp[ni,6]+"' AND VSO.VSO_DATAGE<='"+dtos(aDisp[ni,4])+"' AND VSO.VSO_STATUS IN ('1','2') AND "
		If Altera
			cQuery += "VSO.R_E_C_N_O_<>"+Alltrim(str(VSO->(RecNo())))+" AND "
		EndIf
		cQuery += "VSO.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() ) .and. lOk
			If dtos(aDisp[ni,4]) == ( cQAlSQL )->( VSO_DATAGE ) .and. dtos(aDisp[ni,4]) == ( cQAlSQL )->( VSO_DATFIN )
				If ( cQAlSQL )->( VSO_HORAGE ) <= strzero(aDisp[ni,5],4) .and. ( cQAlSQL )->( VSO_HORFIN ) > aDisp[ni,5]
					lOk := .f.
				EndIf
			ElseIf dtos(aDisp[ni,4]) == ( cQAlSQL )->( VSO_DATAGE ) .and. dtos(aDisp[ni,4]) <> ( cQAlSQL )->( VSO_DATFIN )
				If ( cQAlSQL )->( VSO_HORAGE ) <= strzero(aDisp[ni,5],4)
					lOk := .f.
				EndIf
			ElseIf dtos(aDisp[ni,4]) == ( cQAlSQL )->( VSO_DATFIN )
				If ( cQAlSQL )->( VSO_HORFIN ) > aDisp[ni,5]
					lOk := .f.
				EndIf
			EndIf
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		If lOk
			aAdd(aAux,aClone(aDisp[ni]))
		EndIf
	Next
	aDisp := aClone(aAux)
EndIf
If len(aDisp) <= 0
	aAdd(aDisp,{0,0,"",ctod(""),0,"","","","",""})
EndIf
FS_ORDENA(cOrdVet,lRefresh)
Return()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_MENUORD  ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu com Ordem do Vetor          						     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MENUORD( oObj , nX , nY , oOrdMenu )
oOrdMenu:Activate( nX, nY, oObj )
Return()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ORDENA   ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ordenar Vetor de Disponibilidade	   						     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ORDENA(cTipo,lRefresh)
cOrdVet := cTipo
Do Case
	Case cTipo == "1" // Data + Hora + Filial + Box
		aSort(aDisp,1,,{|x,y| dtos(x[4])+strzero(x[5],4)+x[9]+x[6] < dtos(y[4])+strzero(y[5],4)+y[9]+y[6] })
	Case cTipo == "2" // Data + Hora + Box + Filial
		aSort(aDisp,1,,{|x,y| dtos(x[4])+strzero(x[5],4)+x[6]+x[9] < dtos(y[4])+strzero(y[5],4)+y[6]+y[9] })
	Case cTipo == "3" // Utilizado + Data + Hora + Filial + Box
		aSort(aDisp,1,,{|x,y| strzero(x[1],3)+dtos(x[4])+strzero(x[5],4)+x[9]+x[6] < strzero(y[1],3)+dtos(y[4])+strzero(y[5],4)+y[9]+y[6] })
EndCase
If lRefresh
	oOrd:cCaption := (STR0084+": "+cOrdVet) // Ordem
	oOrd:Refresh()
	oLbDisp:nAt := 1
	oLbDisp:SetArray(aDisp)
	oLbDisp:bLine := { || {	aDisp[oLbDisp:nAt,3] ,;
							Transform(aDisp[oLbDisp:nAt,4],"@D") ,;
							Transform(aDisp[oLbDisp:nAt,5],"@R 99:99")+STR0023 ,; // hs
							FG_AlinVlrs(Transform(aDisp[oLbDisp:nAt,1],"@E 999")) ,;
							FG_AlinVlrs(Transform(aDisp[oLbDisp:nAt,2],"@E 999")) ,;
							aDisp[oLbDisp:nAt,6]+" - "+aDisp[oLbDisp:nAt,7] ,;
							aDisp[oLbDisp:nAt,8] ,;
							aDisp[oLbDisp:nAt,9]+" - "+aDisp[oLbDisp:nAt,10] }}
	oLbDisp:Refresh()
EndIf
Return()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_RETDTHR  ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorno da FILIAL/DATA/HORA/BOX Disponivel				     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RETDTHR(nTipo)
Local cFilSalva := cFilAnt
Local nResp := 0
Local lRet  := .f.  
if Len(aDisp) == 1 .and. Empty(aDisp[1,3])
   Return(.f.)
Endif   
If nTipo == 0 // Visualizando
	If aDisp[oLbDisp:nAt,1] > 0
		FS_VEREXIST(aDisp[oLbDisp:nAt,4],strzero(aDisp[oLbDisp:nAt,5],4),aDisp[oLbDisp:nAt,6],aDisp[oLbDisp:nAt,9])
	EndIf
Else // Incluindo/Alterando
	cFilAnt := aDisp[oLbDisp:nAt,9]
	If FS_ESCALA(aDisp[oLbDisp:nAt,6],left(aDisp[oLbDisp:nAt,8],At("-",aDisp[oLbDisp:nAt,8])-2),aDisp[oLbDisp:nAt,4],aDisp[oLbDisp:nAt,5],aDisp[oLbDisp:nAt,6]+" - "+aDisp[oLbDisp:nAt,7],aDisp[oLbDisp:nAt,8]) // Box / Tecnico / Data / Hora / Obs.Box / Obs.Tecnico / Dt.Referencia / Hr.Referencia
		If aDisp[oLbDisp:nAt,1] > 0
			nResp := Aviso(STR0015,STR0020+": "+aDisp[oLbDisp:nAt,9]+" - "+aDisp[oLbDisp:nAt,10]+CHR(13)+CHR(10)+STR0021+": "+Transform(aDisp[oLbDisp:nAt,4],"@D")+CHR(13)+CHR(10)+STR0022+": "+Transform(aDisp[oLbDisp:nAt,5],"@R 99:99")+STR0023+CHR(13)+CHR(10)+STR0024+": "+aDisp[oLbDisp:nAt,6]+" - "+aDisp[oLbDisp:nAt,7]+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"1-"+STR0025+CHR(13)+CHR(10)+"2-"+STR0026,{"1-"+STR0090,"2-"+STR0003},3,STR0027) // Atencao / Filial / Data / Hora / hs / Box / Agendar na FILIAL, DATA, HORA e BOX selecionado. / Visualizar o(s) outro(s) agendamento(s) existente(s). / Agendar / Visualizar / Existe(m) outro(s) agendamento(s) para:
		Else
			nResp := 1
		EndIf
		If nResp > 0
			If nResp == 1
				lRet := .t.
				M->VSO_FILIAL := xFilial("VSO")
				M->VSO_DATAGE := aDisp[oLbDisp:nAt,4]
				M->VSO_HORAGE := strzero(aDisp[oLbDisp:nAt,5],4)
				M->VSO_NUMBOX := aDisp[oLbDisp:nAt,6]
				M->VSO_STATUS := "1"
			Else
				FS_VEREXIST(aDisp[oLbDisp:nAt,4],strzero(aDisp[oLbDisp:nAt,5],4),aDisp[oLbDisp:nAt,6],xFilial("VSO"))
			EndIf
		EndIf
	EndIf
EndIf    
cFilAnt := cFilSalva
Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_RETDTHR  ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica a Escala do Tecnico/Box  	    				     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ESCALA(cNumBox,cCodPro,dData,nHora,cObsBox,cObsPro,dRefDt,nRefHr)
Local aVetDis := {}
Local nPosEsc := 0
Local nCountE := 0
Local lOk     := .t.
Local lOk1    := .f.
Local lOk2    := .f.
Local nHorPad := 0
Local nTemPad := 0
Local cTurno  := ""
If !Empty(cCodPro)
	If FS_AUSENCIA(cCodPro,dData,nHora) // Verificar Ausencia do produtivo
		DbSelectArea("VOE")
		DbSetOrder(1)
		If lOk
			lOk  := .f.
			If !DbSeek(xFilial("VOE")+cCodPro+Dtos(dData),.t.)
				If Eof()
					Dbskip(-1)
				EndIf
				While xFilial("VOE") == VOE->VOE_FILIAL .And. !Bof()
					If (( VOE->VOE_FILIAL+VOE->VOE_CODPRO # xFilial("VOE")+cCodPro ) .or. ( VOE->VOE_FILIAL+VOE->VOE_CODPRO == xFilial("VOE")+cCodPro .and. VOE->VOE_DATESC > (dData) ))
						DbSkip(-1)
						Loop
					EndIf
					Exit
				EndDo
			EndIf
			If VOE->VOE_CODPRO == cCodPro
				DbSelectArea("VOH")
				DbSetOrder(1)
				If DbSeek(xFilial("VOH")+VOE->VOE_CODPER)
					For nCountE := 1 To VOH->(FCount())
						If ( "INI" $ VOH->(FieldName(nCountE)) .Or. "FIN" $ VOH->(FieldName(nCountE)) ) .and. !Empty( &( VOH->(FieldName(nCountE)) ) )
							If ( Len(aVetDis) == 0 .Or. !Empty(aVetDis[Len(aVetDis),2]) )
								Aadd( aVetDis, { 0, 0 })
							EndIf
							If Empty(aVetDis[Len(aVetDis),1])
								aVetDis[Len(aVetDis),1] := &( VOH->(FieldName(nCountE)) )
							ElseIf Empty(aVetDis[Len(aVetDis),2])
								aVetDis[Len(aVetDis),2] := &( VOH->(FieldName(nCountE)) )
							EndIf
						EndIf
					Next
				EndIf
			EndIf
			If Len(aVetDis) # 0 // Adiciona tempo de intervalo
				cTurno  := CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0105+":" // Turno
				nHorPad := Val( Substr(StrZero(nHora,4),1,2)+StrZero(Val(Substr(StrZero(nHora,4),3,2))/0.6,2) )
				nHorPad := Val( Substr(StrZero(nHorPad,4),1,2)+StrZero(Val(Substr(StrZero(nHorPad,4),3,2))*0.6,2) )
				nTemPad := FS_INCINTERVALO(aVetDis,dData,nHora,dData,nHorPad,nTemPad)
				nHorPad := Val( Substr(StrZero(nHora,4),1,2)+StrZero(Val(Substr(StrZero(nHora,4),3,2))/0.6,2) )
				nHorPad += nTemPad
				nHorPad := Val( Substr(StrZero(nHorPad,4),1,2)+StrZero(Val(Substr(StrZero(nHorPad,4),3,2))*0.6,2) )
				lOk1 := .f.
				lOk2 := .f.
				For nCountE := 1 To Len(aVetDis)
					If nHora >= aVetDis[nCountE,1] .And. nHora < aVetDis[nCountE,2]
						lOk1 := .t.
					EndIf
					If nHorPad >= aVetDis[nCountE,1] .And. nHorPad <= aVetDis[nCountE,2]
						lOk2 := .t.
					EndIf
					cTurno += CHR(13)+CHR(10)+Transform(aVetDis[nCountE,1],"@R 99:99")+STR0023+" "+STR0053+" "+Transform(aVetDis[nCountE,2],"@R 99:99")+STR0023 // hs / ate / hs
				Next
				lOk := .t.
				If ( !lOk1 .Or. !lOk2 )
					lOk := .f.
					If GetNewPar("MV_VPROAGE","N") == "S"
						MsgStop(STR0102+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0024+": "+cObsBox+CHR(13)+CHR(10)+STR0043+": "+cObsPro+cTurno,STR0015) // Tecnico fora de turno! / Box / Tecnico / Atencao
					Else
						lOk := MsgYesNo(STR0102+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0024+": "+cObsBox+CHR(13)+CHR(10)+STR0043+": "+cObsPro+cTurno+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0104+CHR(13)+CHR(10)+Alltrim(DIASEMANA(dRefDt))+"    "+Transform(dRefDt,"@D")+"    "+Transform(nRefHr,"@R 99:99")+STR0023,STR0015) // Tecnico fora de turno! / Box / Tecnico / Confirma Horario? / hs / Atencao
					EndIf
				EndIf
			Else
				lOk := .f.
				If GetNewPar("MV_VPROAGE","N") == "S"
					MsgStop(STR0103+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0024+": "+cObsBox+CHR(13)+CHR(10)+STR0043+": "+cObsPro,STR0015) // Tecnico sem escala cadastrada! / Box / Tecnico / Atencao
				Else
					lOk := MsgYesNo(STR0103+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0024+": "+cObsBox+CHR(13)+CHR(10)+STR0043+": "+cObsPro+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0104+CHR(13)+CHR(10)+Alltrim(DIASEMANA(dRefDt))+"    "+Transform(dRefDt,"@D")+"    "+Transform(nRefHr,"@R 99:99")+STR0023,STR0015) // Tecnico sem escala cadastrada! / Box / Tecnico / Confirma Horario? / hs / Atencao
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
Return( lOk )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_AUSENCIA ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verificar Ausencia do Tecnico      	    				     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AUSENCIA(cCodPro,dData,nHora)
Local lOk     := .t.
Local cQuery  := ""
Local cQAlVO4 := "SQLVO4"
cQuery := "SELECT VO4.VO4_TIPAUS , VO4.VO4_DATINI , VO4.VO4_HORINI , VO4.VO4_DATFIN , VO4.VO4_HORFIN FROM "+RetSqlName("VO4")+" VO4 WHERE "
cQuery += "VO4.VO4_FILIAL='"+xFilial("VO4")+"' AND VO4.VO4_NOSNUM='99999999' AND VO4.VO4_SEQUEN='99999999' AND VO4.VO4_CODPRO='"+cCodPro+"' AND "
cQuery += "VO4.VO4_DATINI<='"+dtos(dData)+"' AND VO4.VO4_DATFIN>='"+dtos(dData)+"' AND VO4.D_E_L_E_T_=' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVO4 , .F., .T. )
While !( cQAlVO4 )->( Eof() ) .and. lOk
	If dtos(dData) == ( cQAlVO4 )->( VO4_DATINI ) .and. dtos(dData) == ( cQAlVO4 )->( VO4_DATFIN )
		If ( cQAlVO4 )->( VO4_HORINI ) <= nHora .and. ( cQAlVO4 )->( VO4_HORFIN ) > nHora
			lOk := .f.
		EndIf
	ElseIf dtos(dData) == ( cQAlVO4 )->( VO4_DATINI ) .and. dtos(dData) <> ( cQAlVO4 )->( VO4_DATFIN )
		If ( cQAlVO4 )->( VO4_HORINI ) <= nHora
			lOk := .f.
		EndIf
	ElseIf dtos(dData) <> ( cQAlVO4 )->( VO4_DATINI ) .and. dtos(dData) == ( cQAlVO4 )->( VO4_DATFIN )
		If ( cQAlVO4 )->( VO4_HORFIN ) > nHora
			lOk := .f.
		EndIf
	Else
		lOk := .f.
	EndIf
	If !lOk
		MsgStop(STR0107+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cCodPro+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
		STR0051+": "+Transform(stod(( cQAlVO4 )->( VO4_DATINI )),"@D")+" "+Transform(( cQAlVO4 )->( VO4_HORINI ),"@R 99:99")+STR0023+" "+STR0053+" "+Transform(stod(( cQAlVO4 )->( VO4_DATFIN )),"@D")+" "+Transform(( cQAlVO4 )->( VO4_HORFIN ),"@R 99:99")+STR0023+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
		Posicione("SX5",1,xFilial("SX5")+"TA"+( cQAlVO4 )->( VO4_TIPAUS ),"X5_DESCRI")	,STR0015) // Tecnico ausente! / Periodo / hs / ate / hs / Atencao
	EndIf
	( cQAlVO4 )->( DbSkip() )
EndDo
( cQAlVO4 )->( DbCloseArea() )
Return(lOk)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_INCINTERVALO³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Adiciona tempo de intervalo (cafe) no tempo padrao		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function FS_INCINTERVALO(aVetPeriodo,dDtIni,nHrIni,dDtFin,nHrFin,nTempoRet)
Local nTemIntervalo := 0, nPer := 0
If Len(aVetPeriodo) > 1
	For nPer := 1 To (Len(aVetPeriodo)-1)
		If ( aVetPeriodo[nPer,2] >= nHrIni .and. aVetPeriodo[nPer,2] <= nHrFin ) .or. ( aVetPeriodo[nPer+1,1] > nHrIni .and. aVetPeriodo[nPer+1,1] <= nHrFin )
			nTemIntervalo := FS_VLSERTP(dDtIni,aVetPeriodo[nPer,2], dDtFin,aVetPeriodo[nPer+1,1] )
			nTempoRet := ( nTempoRet + nTemIntervalo )
		EndIf
	Next
EndIf
Return(nTempoRet)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_VEREXIST ³ Autor ³ Rafael Goncalves     ³ Data ³ 13/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Agendamentos Existentes                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VEREXIST(dData,cHora,cBox,cFilVSO)
Local cFilSalv := cFilAnt
Local cBoxDesc := ""
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cQuery   := ""
Local cAliasVSO:= "SQLVSO"
Local aGrpTot  := {}
Private aInconvAg := {}
cFilAnt := cFilVSO
DbSelectArea("VON")
DbSetOrder(1)
If DbSeek(xFilial("VON")+cBox)
	DbSelectArea("VOD")
	DbSetORder(1)
	If DbSeek(xFilial("VOD")+VON->VON_CODSEC)
		cBoxDesc := cBox+" - "+alltrim(VOD->VOD_DESSEC)
	EndIf
EndIf
aObjects := {}
AAdd( aObjects, { 0, 15 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 0, 42, .T. , .T. } )  //list box superior
AAdd( aObjects, { 0, 42, .T. , .T. } )  //list box inferior
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)
//LEVANTAMENTO DAS INFORMACOES
cQuery := "SELECT DISTINCT VSO.VSO_GETKEY , VSO.VSO_PROVEI , VSO.VSO_LOJPRO , VSO.VSO_NOMPRO , VSO.VSO_FONPRO , VSO.VSO_EMAIL , VSO.VSO_PLAVEI , VSO.VSO_CODMAR , VSO.VSO_MODVEI , VSO.VSO_NUMIDE , VSO.VSO_STATUS , VSO.VSO_DATAGE , VSO.VSO_HORAGE , VSO.VSO_DATFIN , VSO.VSO_HORFIN , VV2.VV2_DESMOD "
cQuery += "FROM "+RetSqlName("VSO")+" VSO LEFT JOIN "+RetSqlName("VV2")+" VV2 ON (VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VSO.VSO_CODMAR AND VV2.VV2_MODVEI=VSO.VSO_MODVEI AND VV2.D_E_L_E_T_=' ') "
cQuery += "WHERE VSO.VSO_FILIAL='"+xFilial("VSO")+"' AND VSO.VSO_DATAGE='"+dtos(dData)+"' AND VSO.VSO_HORAGE='"+cHora+"' AND VSO.VSO_NUMBOX='"+cBox+"' AND VSO.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVSO, .F., .T. )
// 1o Elemento - Chassi
// 2o Elemento - Loja
// 3o Elemento - Proprietario
// 4o Elemento - Nome Cliente
// 5o Elemento - Fone
// 6o Elemento - Email
// 7o Elemento - Placa
// 8o Elemento - Codigo Marca
// 9o Elemento - Modelo + descricao
//10o Elemento - Num Ide
//11o Elemento - Status
While ( cAliasVSO )->(!Eof())
	If dtos(dData)+cHora >= ( cAliasVSO )->( VSO_DATAGE )+( cAliasVSO )->( VSO_HORAGE ) .and. dtos(dData)+cHora < ( cAliasVSO )->( VSO_DATFIN )+strzero(( cAliasVSO )->( VSO_HORFIN ),4)
		aadd(aGrpTot,{( cAliasVSO )->(VSO_GETKEY) , ( cAliasVSO )->(VSO_LOJPRO) , ( cAliasVSO )->(VSO_PROVEI) , ( cAliasVSO )->(VSO_NOMPRO) , ( cAliasVSO )->(VSO_FONPRO) , ( cAliasVSO )->(VSO_EMAIL) , Transform(( cAliasVSO )->(VSO_PLAVEI),VV1->(x3Picture("VV1_PLAVEI"))) , ( cAliasVSO )->(VSO_CODMAR) , alltrim(( cAliasVSO )->(VSO_MODVEI)) +" - " + ( cAliasVSO )->(VV2_DESMOD) , ( cAliasVSO )->(VSO_NUMIDE) , Alltrim(X3CBOXDESC("VSO_STATUS",( cAliasVSO )->(VSO_STATUS))) })
	EndIf
	( cAliasVSO )->(DbSkip())
Enddo
( cAliasVSO )->(dbCloseArea())
If Len(aGrpTot)<=0
	aAdd(aGrpTot,{ "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" })
	aAdd(aInconvAg,{ "" , "" , "" , "" })
Else
	FS_LEVINC(aGrpTot[1,10])
EndIf
DEFINE MSDIALOG oAgExist TITLE STR0065 From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL // Agendamentos Existentes
//Objeto 01 cabecalho
@ aPosObj[1,1]+4,aPosObj[1,2]+002 SAY oTDat VAR (STR0021+":") SIZE 150,08 OF oAgExist PIXEL COLOR CLR_BLUE  // Data
@ aPosObj[1,1]+2,aPosObj[1,2]+017 get oData VAR Transform(dData,"@D")  SIZE 35,08 OF oAgExist PIXEL COLOR CLR_BLACK WHEN .f.
@ aPosObj[1,1]+4,aPosObj[1,2]+060 SAY oTHor VAR (STR0022+":") SIZE 150,08 OF oAgExist PIXEL COLOR CLR_BLUE  // Hora
@ aPosObj[1,1]+2,aPosObj[1,2]+075 get oHora VAR (Transform(cHora, "@R 99:99")+STR0023) SIZE 20,08 OF oAgExist PIXEL COLOR CLR_BLACK WHEN .f. // hs
@ aPosObj[1,1]+4,aPosObj[1,2]+115 SAY oTBox VAR (STR0024+":") SIZE 150,08 OF oAgExist PIXEL COLOR CLR_BLUE  // Box
@ aPosObj[1,1]+2,aPosObj[1,2]+133 get oBoxd VAR cBoxDesc SIZE 90,08 OF oAgExist PIXEL COLOR CLR_BLACK WHEN .f.
@ aPosObj[1,1]+4,aPosObj[1,2]+233 SAY oTFil VAR (STR0020+":") SIZE 150,08 OF oAgExist PIXEL COLOR CLR_BLUE // Filial
@ aPosObj[1,1]+2,aPosObj[1,2]+250 get oFilial VAR cFilVSO SIZE 90,08 OF oAgExist PIXEL COLOR CLR_BLACK WHEN .f.
@ aPosObj[1,1]+3,aPosObj[1,4]-50 BUTTON oSair PROMPT STR0074 OF oAgExist SIZE 45,10 PIXEL ACTION oAgExist:End() // SAIR
// 1 LIST BOX SUPERIOR
@ aPosObj[2,1],aPosObj[2,2] LISTBOX oLbExistAg FIELDS HEADER STR0066 ,; // Agendamento
STR0030 ,; // Cliente
STR0031 ,; // Fone
STR0067 ,; // E-mail
STR0034 ,; // Chassi
STR0033 ,; // Placa
STR0032  ; // Veiculo
COLSIZES 50,100,45,80,80,40,110 SIZE aPosObj[2,4]-2,aPosObj[2,3]-20 OF oAgExist PIXEL ON CHANGE ( FS_LEVINC(aGrpTot[oLbExistAg:nAt,10],0))
oLbExistAg:SetArray(aGrpTot)
oLbExistAg:bLine := { || { aGrpTot[oLbExistAg:nAt,11],;
							aGrpTot[oLbExistAg:nAt,3]+"-"+aGrpTot[oLbExistAg:nAt,2]+" - "+aGrpTot[oLbExistAg:nAt,4] ,;
							aGrpTot[oLbExistAg:nAt,5],;
							aGrpTot[oLbExistAg:nAt,6],;
							aGrpTot[oLbExistAg:nAt,1] ,;
							aGrpTot[oLbExistAg:nAt,7],;
							aGrpTot[oLbExistAg:nAt,8]+"-"+aGrpTot[oLbExistAg:nAt,9]}}
oLbExistAg:SetFocus()
oLbExistAg:Refresh()
// 2 LIST BOX INFERIOR INCONVENIENTES NO BOX
@ aPosObj[3,1],aPosObj[3,2] LISTBOX oInconvAg FIELDS HEADER STR0068 ,; // Grupo
STR0069 ,; // Codigo
STR0070  ; // Descricao
COLSIZES 50,70,250 SIZE aPosObj[3,4]-2,aPosObj[3,3]-aPosObj[2,3]-2 OF oAgExist PIXEL
oInconvAg:SetArray(aInconvAg)
oInconvAg:bLine := { || {  aInconvAg[oInconvAg:nAt,1] ,;
							aInconvAg[oInconvAg:nAt,2] ,;
							aInconvAg[oInconvAg:nAt,3]}}
ACTIVATE MSDIALOG oAgExist
cFilAnt := cFilSalv
Return()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LEVINC     ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lista Inconvenientes do Agendamento Existente (selecionado)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVINC(cNumVSO,nTipo)
Local cQuery2 := ""
Local cAliasVST := "SQLVST"
Default nTipo := 1
aInconvAg := {}
//LEVANTAMENTO DAS INFORMACOES
cQuery2 := "SELECT VST.VST_GRUINC , VST.VST_CODINC , VST.VST_DESINC FROM "+RetSqlName("VST")+" VST WHERE "
cQuery2 += "VST.VST_FILIAL='"+xFilial("VST")+"' AND VST.VST_TIPO='3' AND VST.VST_CODIGO='"+cNumVSO+"' AND VST.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery2 ), cAliasVST, .F., .T. )
// 1o Elemento - Grupo Inconveniente
// 2o Elemento - Codigo Inconveniente
// 3o Elemento - Descricao  Inconveniente
While ( cAliasVST )->(!Eof())
	aadd(aInconvAg,{ ( cAliasVST )->(VST_GRUINC) , ( cAliasVST )->(VST_CODINC) , ( cAliasVST )->(VST_DESINC) })
	( cAliasVST )->(DbSkip())
Enddo
( cAliasVST )->(dbCloseArea())
If Len(aInconvAg)<=0
	aAdd(aInconvAg,{ "" , "" , "" , "" })
EndIf
If nTipo <> 1
	oInconvAg:nAt := 1
	oInconvAg:SetArray(aInconvAg)
	oInconvAg:bLine := { || {  aInconvAg[oInconvAg:nAt,1] ,;
								aInconvAg[oInconvAg:nAt,2] ,;
								aInconvAg[oInconvAg:nAt,3]}}
	oInconvAg:Refresh()
EndIf
Return()
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_POSSAGE ³ Autor ³ Rafael Goncalves     ³ Data ³ 13/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Lista Possiveis Agendas                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_POSSAGE()
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nPos := 0
Local nh := 0
Local nOrd := 0
Local cFilVZB := ""
Local cFilLev := IIf(substr(cAgParam,3,1)=="1",xFilial("VZB"),space(len(VZB->VZB_FILIAL)))
Private aRetPossAge := {}
Private aTotPos  := {}
Private aTotDesc := {}
Private aFilDesc := {}
Private oVerd := LoadBitmap( GetResources(), "BR_VERDE" )
Private oVerm := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private lBXT := .f. // Box's Total
If !Empty(cFilLev)
	cFilVZB := cFilLev
Else
	cFilVZB := STR0071 // Todas Filiais
EndIf
cChaPAG := ""
nRegPAG := 0
aObjects := {}
AAdd( aObjects, { 0, 15 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 0, 42, .T. , .T. } )  //list box superior
AAdd( aObjects, { 0, 42, .T. , .T. } )  //list box inferior
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)
FS_PAGEPAI(.f.) // Carrega PAI das Possiveis Agendas
DEFINE MSDIALOG oPossAgend TITLE STR0012 From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL // Possiveis Agendas
//Objeto 01 cabecalho
@ aPosObj[1,1]+4,aPosObj[1,2]+002 SAY oFil VAR (STR0020+": "+cFilVZB) SIZE 200,08 OF oPossAgend PIXEL COLOR CLR_BLUE // Filial
@ aPosObj[1,1]+3,aPosObj[1,4]-260 BUTTON oBlqP PROMPT STR0157 OF oPossAgend SIZE 100,10 PIXEL ACTION IIf(FS_BLQVEI(aFilDesc[oLbPosA:nAt,4]),FS_CANPAGE(aFilDesc[oLbPosA:nAt,12],oLbPosA:nAt,aFilDesc[oLbPosA:nAt,8]+"-"+aFilDesc[oLbPosA:nAt,9] +" - "+ aFilDesc[oLbPosA:nAt,10],Alltrim(aFilDesc[oLbPosA:nAt,5])+"-"+Alltrim(aFilDesc[oLbPosA:nAt,6])+" - "+Alltrim(aFilDesc[oLbPosA:nAt,7]) ),.t.) // Bloqueia Prospeccao do Veiculo
@ aPosObj[1,1]+3,aPosObj[1,4]-150 BUTTON oCanc PROMPT STR0073 OF oPossAgend SIZE 090,10 PIXEL ACTION FS_CANPAGE(aFilDesc[oLbPosA:nAt,12],oLbPosA:nAt,aFilDesc[oLbPosA:nAt,8]+"-"+aFilDesc[oLbPosA:nAt,9] +" - "+ aFilDesc[oLbPosA:nAt,10],Alltrim(aFilDesc[oLbPosA:nAt,5])+"-"+Alltrim(aFilDesc[oLbPosA:nAt,6])+" - "+Alltrim(aFilDesc[oLbPosA:nAt,7]) ) // CANCELAR POSSIVEL AGENDA
@ aPosObj[1,1]+3,aPosObj[1,4]-050 BUTTON oSair PROMPT STR0074 OF oPossAgend SIZE 045,10 PIXEL ACTION oPossAgend:End() // SAIR
// 1 LIST BOX SUPERIOR
@ aPosObj[2,1],aPosObj[2,2] LISTBOX oLbPosATot FIELDS HEADER "" ,;
							STR0072 ,; // Nome do Filtro
							STR0021 ,; // Data
							STR0020  ; // Filial
							COLSIZES 20,300,50,10 SIZE aPosObj[2,4]-2,aPosObj[2,3]-20 OF oPossAgend PIXEL ON DBLCLICK FS_TIKPAG(oLbPosATot:nAt)
oLbPosATot:SetArray(aTotPos)
oLbPosATot:bLine := { || { IIf(aTotPos[oLbPosATot:nAt,2],oVerd,oVerm),;
							aTotPos[oLbPosATot:nAt,3],;
							aTotPos[oLbPosATot:nAt,4],;
							aTotPos[oLbPosATot:nAt,5]}}
@ aPosObj[2,1],aPosObj[2,2]+1 CHECKBOX oBXT VAR lBXT PROMPT "" OF oPossAgend ON CLICK FS_TIKPAG(0) SIZE 10,08 PIXEL COLOR CLR_BLUE
// 2 LIST BOX INFERIOR INCONVENIENTES NO BOX
@ aPosObj[3,1],aPosObj[3,4]-220 BUTTON oBlqP PROMPT STR0190 OF oPossAgend SIZE 100,10 PIXEL ACTION FS_PASVEI(aFilDesc[oLbPosA:nAt,4])  // "Hist. Passagens do veiculo"
@ aPosObj[3,1],aPosObj[3,4]-100 BUTTON oBlqP PROMPT STR0197 OF oPossAgend SIZE 60,10 PIXEL ACTION FS_MUDSTA(aFilDesc,oLbPosA:nAt)  // Mudar Status Usuario
@ aPosObj[3,1]+012,aPosObj[3,2] LISTBOX oLbPosA FIELDS HEADER STR0072 ,; // Nome do Filtro
							STR0021 ,; // Data
							STR0030 ,; // Cliente
							STR0031 ,; // Fone
							STR0032 ,; // Veiculo
							STR0034 ,; // Chassi
							STR0033 ,; // Placa
							STR0020 ,; // Filial
							STR0195 ,; //  Status Usuario 
							STR0196  ; // Obs. do Status Usuario 
							COLSIZES 50,40,120,50,140,90,20,30,50,200 SIZE aPosObj[3,4]-2,aPosObj[3,3]-aPosObj[2,3]-12 OF oPossAgend PIXEL ON DBLCLICK ( FS_VALIDLBOX() )
oLbPosA:SetArray(aFilDesc)
oLbPosA:bLine := { || { aFilDesc[oLbPosA:nAt,3] ,;
						aFilDesc[oLbPosA:nAt,2] ,;
						aFilDesc[oLbPosA:nAt,8]+"-"+aFilDesc[oLbPosA:nAt,9] +" - "+ aFilDesc[oLbPosA:nAt,10] ,;
						aFilDesc[oLbPosA:nAt,11] ,;
						Alltrim(aFilDesc[oLbPosA:nAt,5])+"-"+Alltrim(aFilDesc[oLbPosA:nAt,6])+" - "+Alltrim(aFilDesc[oLbPosA:nAt,7]) ,;
						aFilDesc[oLbPosA:nAt,4] ,;
						aFilDesc[oLbPosA:nAt,14] ,;
						aFilDesc[oLbPosA:nAt,13]+aFilDesc[oLbPosA:nAt,15],;
						aFilDesc[oLbPosA:nAt,16],;
						aFilDesc[oLbPosA:nAt,17];
						}}
ACTIVATE MSDIALOG oPossAgend
DbSelectArea("VSO")
Return(aRetPossAge)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ATUPOSS    ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza VARIAVEIS MEMORIA com a Possivel Agenda                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ATUPOSS(aRetPossAge)
Local cFilSalv := cFilAnt
If len(aRetPossAge) > 0
	M->VSO_CHAINT := space(len(VV1->VV1_CHAINT))
	M->VSO_EMAIL  := space(len(VSO->VSO_EMAIL))
	M->VSO_DESMAR := space(len(VE1->VE1_DESMAR))
	M->VSO_CODFRO := space(len(VSO->VSO_CODFRO))
	M->VSO_DESCOR := space(len(VVC->VVC_DESCRI))
	M->VSO_ENDPRO := space(len(VSO->VSO_ENDPRO))
	M->VSO_CIDPRO := space(len(VSO->VSO_CIDPRO))
	M->VSO_ESTPRO := space(len(VSO->VSO_ESTPRO))
	M->VSO_CODMAR := space(len(VV1->VV1_CODMAR))
	M->VSO_MODVEI := space(len(VV2->VV2_MODVEI))
	M->VSO_DESMOD := space(len(VV2->VV2_DESMOD))
	M->VSO_GETKEY := space(len(VSO->VSO_GETKEY))
	M->VSO_PLAVEI := space(len(VV1->VV1_PLAVEI))
	M->VSO_PROVEI := space(len(VSO->VSO_PROVEI))
	M->VSO_LOJPRO := space(len(VSO->VSO_LOJPRO))
	M->VSO_NOMPRO := space(len(VSO->VSO_NOMPRO))
	M->VSO_FONPRO := space(len(VSO->VSO_FONPRO))
	cFilAnt := aRetPossAge[2]
	M->VSO_GETKEY := aRetPossAge[3]
	If !Empty(M->VSO_GETKEY)
		OM350VEIC()
	Else
		M->VSO_CHAINT := space(len(VV1->VV1_CHAINT))
		M->VSO_EMAIL  := space(len(VSO->VSO_EMAIL))
		M->VSO_DESMAR := space(len(VE1->VE1_DESMAR))
		M->VSO_CODFRO := space(len(VSO->VSO_CODFRO))
		M->VSO_DESCOR := space(len(VVC->VVC_DESCRI))
		M->VSO_ENDPRO := space(len(VSO->VSO_ENDPRO))
		M->VSO_CIDPRO := space(len(VSO->VSO_CIDPRO))
		M->VSO_ESTPRO := space(len(VSO->VSO_ESTPRO))
	EndIf
	If Empty(M->VSO_CODMAR)
		M->VSO_CODMAR := left(aRetPossAge[8]+space(50),len(VV1->VV1_CODMAR))
	EndIf
	If Empty(M->VSO_MODVEI) .and. Empty(M->VSO_DESMOD)
		M->VSO_MODVEI := left(aRetPossAge[9]+space(50),len(VV2->VV2_MODVEI))
		M->VSO_DESMOD := left(aRetPossAge[10]+space(50),len(VV2->VV2_DESMOD))
	EndIf
	If Empty(M->VSO_GETKEY)
		M->VSO_GETKEY := left(aRetPossAge[3]+space(50),len(VSO->VSO_GETKEY))
		M->VSO_PLAVEI := left(aRetPossAge[11]+space(50),len(VV1->VV1_PLAVEI))
	EndIf
	If Empty(M->VSO_PLAVEI)
		M->VSO_PLAVEI := left(aRetPossAge[11]+space(50),len(VV1->VV1_PLAVEI))
	EndIf
	If Empty(M->VSO_PROVEI).or.Empty(M->VSO_LOJPRO).or.Empty(M->VSO_NOMPRO)
		M->VSO_PROVEI := left(aRetPossAge[4]+space(50),len(VSO->VSO_PROVEI))
		M->VSO_LOJPRO := left(aRetPossAge[5]+space(50),len(VSO->VSO_LOJPRO))
		M->VSO_NOMPRO := left(aRetPossAge[6]+space(50),len(VSO->VSO_NOMPRO))
		M->VSO_FONPRO := left(aRetPossAge[7]+space(50),len(VSO->VSO_FONPRO))
	EndIf
EndIf
cFilAnt := cFilSalv
Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_PAGEPAI    ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta PAI das Possiveis agendas ( filtro )                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PAGEPAI(lRefresh)
Local cQuery    := ""
Local cAliasVZB := "SQLVZB"
Local cFilLev   := IIf(substr(cAgParam,3,1)=="1",xFilial("VZB"),space(len(VZB->VZB_FILIAL)))
Local nOrd      := 0
Local nh        := 0
Local cBkpFilAnt:= cFilAnt
Local nCont     := 0
Local cFilVZB   := xFilial("VZB")      
Local _VZB_STACON := (VZB->(FieldPos("VZB_STACON")) > 0)

//aTotDesc
// 1o Elemento - Relacinamento PAI
// 2o Elemento - VZB_DATA 	- Data
// 3o Elemento - VZB_NOMFIL - Nome Filtro
// 4o Elemento - VZB_CHASSI - Chassi
// 5o Elemento - VV1_CODMAR - Codigo da Marca
// 6o Elemento - VV2_MODVEI - Codigo Modelo
// 7o Elemento - VV2_DESMOD - Descricao do Modelo
// 8o Elemento - VZB_CODCLI	- Codigo Cliente
// 9o Elemento - VZB_LOJA	- Loja
//10o Elemento - VZB_NOMCLI - nome cliente
//11o Elemento - VZB_TEL 	- Fone
//12o Elemento - VZB_R_E_C_N_O_
//13o Elemento - Filial
//14o Elemento - Placa
//15o Elemento - Descricao da Filial
aTotPos := {}
If !Empty(cFilLev)
	cFilVZB := cFilLev
Else
	cFilVZB := STR0071 // Todas Filiais
EndIf

For nCont := 1 to Len(aSM0)

	cFilAnt := aSM0[nCont]

	If !Empty(cFilLev) // Utilizar somente registros da Filial corrente
		If cFilVZB <> xFilial("VZB")
			Loop
		EndIf
	EndIf

	cQuery  := "SELECT VZB.VZB_DATA , VZB.VZB_NOMFIL , VZB.VZB_CHASSI , "
	if _VZB_STACON
		cQuery  += "VZB.VZB_STACON , "
	Endif	
	cQuery  += "VZB.VZB_STAOBS , VV1.VV1_PLAVEI , VV1.VV1_CODMAR , VV2.VV2_MODVEI , VV2.VV2_DESMOD , VZB.VZB_CODCLI , VZB.VZB_LOJA , VZB.VZB_NOMCLI , VZB.VZB_TEL , VZB.R_E_C_N_O_ NRECNO , VZB.VZB_FILIAL FROM "+RetSqlName("VZB")+" VZB "
	cQuery  += "LEFT JOIN "+RetSqlName("VV1")+" VV1 ON (VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHASSI=VZB.VZB_CHASSI AND VV1.D_E_L_E_T_=' ' ) "
	cQuery  += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON (VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' ) "
	cQuery  += "WHERE VZB.VZB_FILIAL='"+xFilial("VZB")+"' AND "
	cQuery += "VZB.VZB_STATUS='1' AND VZB.VZB_NOMFIL<>' ' AND VZB.D_E_L_E_T_=' ' ORDER BY VZB.VZB_NOMFIL"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVZB, .F., .T. )
	Do While !( cAliasVZB )->( Eof() )
		nPos := Ascan(aTotPos,{|x| x[3] == Iif(!Empty(( cAliasVZB )->( VZB_NOMFIL )),( cAliasVZB )->( VZB_NOMFIL ),( cAliasVZB )->( VZB_DATA ))  })
		If nPos == 0
			nOrd:= nOrd+1
			Aadd(aTotPos, {nOrd, .f. ,Iif(!Empty(( cAliasVZB )->( VZB_NOMFIL )),( cAliasVZB )->( VZB_NOMFIL ),( cAliasVZB )->( VZB_DATA )) , stod( ( cAliasVZB )->( VZB_DATA ) ) , ( cAliasVZB )->( VZB_FILIAL ) } )
		EndIf 
		if _VZB_STACON
			cStatU := X3CBOXDESC("VZB_STACON",( cAliasVZB )->( VZB_STACON))   
		Else
			cStatU := ""
		Endif	
		Aadd(aTotDesc, {nOrd , stod( ( cAliasVZB )->( VZB_DATA ) ) , ( cAliasVZB )->( VZB_NOMFIL ) , ( cAliasVZB )->( VZB_CHASSI ) , ( cAliasVZB )->( VV1_CODMAR ) , ( cAliasVZB )->( VV2_MODVEI ) , ( cAliasVZB )->( VV2_DESMOD ) , ( cAliasVZB )->( VZB_CODCLI ) , ( cAliasVZB )->( VZB_LOJA ) , ( cAliasVZB )->( VZB_NOMCLI ) , ( cAliasVZB )->( VZB_TEL ) , ( cAliasVZB )->( NRECNO) , ( cAliasVZB )->( VZB_FILIAL ) , Transform(( cAliasVZB )->( VV1_PLAVEI ),VV1->(x3Picture("VV1_PLAVEI"))) , "" , cStatU , ( cAliasVZB )->(VZB_STAOBS)  } )
		( cAliasVZB )->( DbSkip() )
	EndDo
	( cAliasVZB )->( dbCloseArea() )
	
Next
cFilAnt := cBkpFilAnt
	
If Len(aTotPos) <=0
	aAdd(aTotPos,{ 0 , .f. , "" , "" , "" })
Else
	Asort(aTotPos,1,,{ |x,y| x[3]+Dtos(x[4]) > y[3]+Dtos(y[4]) })
EndIf
If lRefresh
	oLbPosATot:nAt := 1
	oLbPosATot:SetArray(aTotPos)
	oLbPosATot:bLine := { || { IIf(aTotPos[oLbPosATot:nAt,2],oVerd,oVerm),;
								aTotPos[oLbPosATot:nAt,3],;
								aTotPos[oLbPosATot:nAt,4],;
								aTotPos[oLbPosATot:nAt,5]}}
	oLbPosATot:Refresh()
EndIf
aAdd(aFilDesc,{ 0 , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , 0 , "" , "" , "" , "" , "" })
Return()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LEVPAG     ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lista Possiveis agenda para o filtro selecionado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVPAG()
Local nj := 0
Local nk := 0
aFilDesc := {}
For nj=1 to len(aTotPos)
	If aTotPos[nj,2]
		For nk = 1 to len(aTotDesc)
			If aTotPos[nj,1] == aTotDesc[nk,1]
				aAdd(aFilDesc,aTotDesc[nk])
			EndIf
		Next
	EndIf
Next
If len(aFilDesc) <= 0
	aAdd(aFilDesc,{ 0 , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , 0 , "" , "" , "" , "" , "" })
Else
	Asort(aFilDesc,1,,{ |x,y| x[3]+Dtos(x[2]) > y[3]+Dtos(y[2]) })
EndIf
If len(aFilDesc) > 0
	oLbPosA:nAt := 1
	oLbPosA:SetArray(aFilDesc)
	oLbPosA:bLine := { || {	aFilDesc[oLbPosA:nAt,3] ,;
							aFilDesc[oLbPosA:nAt,2] ,;
							aFilDesc[oLbPosA:nAt,8]+"-"+aFilDesc[oLbPosA:nAt,9] +" - "+ aFilDesc[oLbPosA:nAt,10] ,;
							aFilDesc[oLbPosA:nAt,11] ,;
							Alltrim(aFilDesc[oLbPosA:nAt,5])+"-"+Alltrim(aFilDesc[oLbPosA:nAt,6])+" - "+Alltrim(aFilDesc[oLbPosA:nAt,7]) ,;
							aFilDesc[oLbPosA:nAt,4] ,;
							aFilDesc[oLbPosA:nAt,14] ,;
							aFilDesc[oLbPosA:nAt,13]+aFilDesc[oLbPosA:nAt,15],;
							aFilDesc[oLbPosA:nAt,16],;
							aFilDesc[oLbPosA:nAt,17];
							}}
	oLbPosA:Refresh()
EndIf
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIKPAG     ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tika os itens pendentes e chama funcao para listar os filhos    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIKPAG(nLinha)
Local ni := 0
If len(aTotPos) > 1 .or. !Empty(aTotPos[1,1])
	If nLinha == 0
		For ni := 1 to len(aTotPos)
			aTotPos[ni,2] := lBXT
		Next
	Else
		aTotPos[nLinha,2] := !aTotPos[nLinha,2]
	EndIf
	oLbPosATot:Refresh()
EndIf
FS_LEVPAG()
Return()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CANPAGE     ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cancela a possivel agenda  									   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CANPAGE(nRecVZB,nPos,cCodCliente,cModDesc)
Local ni := 0
Local aAux:={} 
Local cAliasVZB := "SQLVZB"
If Empty(nRecVZB)
	MsgAlert(STR0076,STR0015) // Possivel agenda nao selecionada! / Atencao
	Return
EndIf

nAviso := Aviso( STR0181 , STR0185  , { STR0186 , STR0187 , STR0188 } )
if nAviso == 1
	If MsgYesNo(STR0189+CHR(13)+CHR(10)+CHR(13)+CHR(10)+aFilDesc[nPos,3],STR0015) // Tem certeza que deseja cancelar todas as possíveis agendas?  Atencao
		//gotop para mudar status para 3
		cQuery  := "SELECT VZB.R_E_C_N_O_ NRECNO FROM "+RetSqlName("VZB")+" VZB "
		cQuery  += "WHERE VZB.VZB_FILIAL='"+xFilial("VZB")+"' AND "
		cQuery  += "VZB.VZB_STATUS='1' AND "
		if !Empty(aTotPos[oLbPosATot:nAt,3])
			cQuery  += "VZB.VZB_NOMFIL <> ' ' AND VZB.VZB_NOMFIL = '"+aTotPos[oLbPosATot:nAt,3]+"' AND "
      Else                                         
			cQuery  += "VZB.VZB_DATA = '"+aTotPos[oLbPosATot:nAt,4]+"' AND "
      Endif
		cQuery  += "VZB.D_E_L_E_T_=' ' ORDER BY VZB.VZB_NOMFIL"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVZB, .F., .T. )
		Do While !( cAliasVZB )->( Eof() )

			dbSelectArea("VZB")
			DbGoTo(( cAliasVZB )->(NRECNO))
			Reclock("VZB",.f.)
			VZB->VZB_STATUS := "3"
			MsUnLock()
			
			( cAliasVZB )->( DbSkip() )
		EndDo
		( cAliasVZB )->( dbCloseArea() )
	
		aFilDesc := {}
		aTotDesc := {}
		FS_PAGEPAI(.t.)
		oLbPosA:nAt := 1
		oLbPosA:SetArray(aFilDesc)
		oLbPosA:bLine := { || {	aFilDesc[oLbPosA:nAt,3] ,;
								aFilDesc[oLbPosA:nAt,2] ,;
								aFilDesc[oLbPosA:nAt,8]+"-"+aFilDesc[oLbPosA:nAt,9] +" - "+ aFilDesc[oLbPosA:nAt,10] ,;
								aFilDesc[oLbPosA:nAt,11] ,;
								Alltrim(aFilDesc[oLbPosA:nAt,5])+"-"+Alltrim(aFilDesc[oLbPosA:nAt,6])+" - "+Alltrim(aFilDesc[oLbPosA:nAt,7]) ,;
								aFilDesc[oLbPosA:nAt,4] ,;
								aFilDesc[oLbPosA:nAt,14] ,;
								aFilDesc[oLbPosA:nAt,13]+aFilDesc[oLbPosA:nAt,15],;
								aFilDesc[oLbPosA:nAt,16],;
								aFilDesc[oLbPosA:nAt,17];
								}}
		oLbPosA:Refresh()
   Endif
Elseif nAviso == 2
	If MsgYesNo(STR0075+CHR(13)+CHR(10)+CHR(13)+CHR(10)+aFilDesc[nPos,3]+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0030+": "+cCodCliente+CHR(13)+CHR(10)+STR0032+": "+cModDesc,STR0015) // Deseja cancelar a possivel agenda? / Cliente / Veiculo / Atencao
		//gotop para mudar status para 3
		DbSelectArea("VZB")
		DbGoTo(nRecVZB)
		Reclock("VZB",.f.)
		VZB->VZB_STATUS := "3"
		MsUnLock()
		aAux:=aClone(aFilDesc)
		aFilDesc := {}
		For ni := 1 to Len(aAux)
			If nPos <> ni
				aAdd(aFilDesc,aAux[ni])
			EndIf
		Next
		If len(aFilDesc) <= 0
			FS_PAGEPAI(.t.)
		EndIf
		oLbPosA:nAt := 1
		oLbPosA:SetArray(aFilDesc)
		oLbPosA:bLine := { || {	aFilDesc[oLbPosA:nAt,3] ,;
								aFilDesc[oLbPosA:nAt,2] ,;
								aFilDesc[oLbPosA:nAt,8]+"-"+aFilDesc[oLbPosA:nAt,9] +" - "+ aFilDesc[oLbPosA:nAt,10] ,;
								aFilDesc[oLbPosA:nAt,11] ,;
								Alltrim(aFilDesc[oLbPosA:nAt,5])+"-"+Alltrim(aFilDesc[oLbPosA:nAt,6])+" - "+Alltrim(aFilDesc[oLbPosA:nAt,7]) ,;
								aFilDesc[oLbPosA:nAt,4] ,;
								aFilDesc[oLbPosA:nAt,14] ,;
								aFilDesc[oLbPosA:nAt,13]+aFilDesc[oLbPosA:nAt,15],;
								aFilDesc[oLbPosA:nAt,16],;
								aFilDesc[oLbPosA:nAt,17];
								}}
		oLbPosA:Refresh()
	EndIf
Endif

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OM350STATUS ³ Autor ³ Andre Luis Almeida ³ Data ³ 19/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Muda STATUS do Agendamento Oficina                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _cNumAge = Numero do Agendamento                           ³±±
±±³          ³ _cTipo   = Tipo de Chamada                                 ³±±
±±³          ³ _cStatus = Novo Status                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM350STATUS(_cNumAge,_cTipo,_cStatus)
Local cSlvAlias := "VO1"
Local cQuery    := ""
Local cQAlias   := "SQLAGENDAMENTO"
Local lOK       := .f.
If _cTipo == "1" // Nao Valida e Atualiza STATUS
	lOk := .t.
ElseIf _cTipo == "2" // Valida Cancelamento do Orcamento
	cQuery := "SELECT COUNT(*) AS QTDE FROM "+RetSqlName("VS1")+" VS1 WHERE VS1.VS1_FILIAL ='"+xFilial("VS1")+"' AND VS1.VS1_STATUS<>'C' AND VS1.VS1_NUMAGE='"+_cNumAge+"' AND VS1.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	If !(cQAlias)->( Eof() )
		If(cQAlias)->( QTDE ) <= 0
			lOk := .t.
		EndIf
	EndIf
	(cQAlias)->(dbCloseArea())
	cSlvAlias := "VS1"
EndIf
If lOk
	cQuery := "SELECT VSO.R_E_C_N_O_ FROM "+RetSqlName("VSO")+" VSO WHERE VSO.VSO_FILIAL ='"+xFilial("VSO")+"' AND VSO.VSO_NUMIDE='"+_cNumAge+"' AND VSO.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	If !(cQAlias)->( Eof() )
		DbSelectArea("VSO")
		DbGoTo((cQAlias)->( R_E_C_N_O_ ))
		RecLock("VSO",.f.)
		VSO->VSO_STATUS := _cStatus // 1=Agendado / 2=OS Aberta / 3=Finalizado / 4=Cancelado / 5=Orcamento Aberto
		MsUnLock()
	EndIf
	(cQAlias)->(dbCloseArea())
EndIf
DbSelectArea(cSlvAlias)
Return()
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³OM350TEMPO³ Autor ³ Andre Luis Almeida    ³ Data ³ 04/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Validacao do Tempo / Calculo do Tempo Padrao (Agendamento) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function OM350TEMPO(nTp)
Local cHr := strzero(M->VSO_TEMPAD,4)
Local nj  := 0
Local nHoras := 0
Local nMinut := 0
If left(cAgParam,1) == "1" // Com Controle de Hrs
	If nTp == 1 // Validar Tempo 30m/1Hr
		If cHr == "0000"
			cHr := "0001"
		EndIf
		If substr(cAgParam,2,1) == "1" // 1Hr
			If right(cHr,2) > "00"
				M->VSO_TEMPAD := val(left(cHr,2)+"00")+100
			EndIf
		Else // 30m
			If right(cHr,2) > "00"
				If right(cHr,2) <= "30"
					M->VSO_TEMPAD := val(left(cHr,2)+"00")+030
				Else
					M->VSO_TEMPAD := val(left(cHr,2)+"00")+100
				EndIf
			EndIf
		EndIf
	ElseIf nTp == 2 // Calcular Tempo Padrao
		M->VSO_TEMPAD := 0
		VSL->(DbSetOrder(1))
		For nj:=1 to Len(oAuxGetDados:aCols)
			If !oAuxGetDados:aCols[nj,len(oAuxGetDados:aCols[nj])]
				If oAuxGetDados:nAt == nj
					If !Empty(M->VST_GRUINC) .and. !Empty(M->VST_CODINC)
						VSL->(DbSeek(xFilial("VSL")+VE1->VE1_CODMAR+M->VST_GRUINC+M->VST_CODINC))
						M->VSO_TEMPAD += VSL->VSL_TEMPAD
					EndIf
				Else
					If !Empty(oAuxGetDados:aCols[nj,FG_POSVAR("VST_GRUINC","oAuxGetDados:aHeader")]) .and. !Empty(oAuxGetDados:aCols[nj,FG_POSVAR("VST_CODINC","oAuxGetDados:aHeader")])
						VSL->(DbSeek(xFilial("VSL")+VE1->VE1_CODMAR+oAuxGetDados:aCols[nj,FG_POSVAR("VST_GRUINC","oAuxGetDados:aHeader")]+oAuxGetDados:aCols[nj,FG_POSVAR("VST_CODINC","oAuxGetDados:aHeader")]))
						M->VSO_TEMPAD += VSL->VSL_TEMPAD
					EndIf
				EndIf
			EndIf
		Next
		nHoras := Val(left(strzero(M->VSO_TEMPAD,4),2))
		nMinut := Val(right(strzero(M->VSO_TEMPAD,4),2))
		M->VSO_TEMPAD := ( nHoras * 100 ) + nMinut
		OM350TEMPO(1)
		oAuxEnchoice:Refresh()
	EndIf
EndIf
Return(.t.)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ OM350ORC ³ Autor ³ Rubens                ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Abrir orcamentos ou exibir orcamentos gerados a partir do  ³±±
±±³          ³ agendamento                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function OM350ORC()
Local lAltSalva := Altera
Local lIncSalva := Inclui
If VSO->VSO_STATUS <> "1" .and. VSO->VSO_STATUS <> "2" .and. VSO->VSO_STATUS <> "5"
	MsgStop(STR0091+" ( "+UPPER(Alltrim(X3CBOXDESC("VSO_STATUS",VSO->VSO_STATUS)))+" )",STR0015)
	Return()
EndIf
If VSO->VSO_STATUS == "1" // 1-Em Aberto
	OFM350GERAORC()
ElseIf VSO->VSO_STATUS == "2" .or. VSO->VSO_STATUS == "5"  // 2-OS Aberta  /  5-Orcamento Aberto
	OFIXA011(VSO->VSO_NUMIDE)
EndIf
Altera := lAltSalva
Inclui := lIncSalva
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ OFM350GERAORC ³ Autor ³ Rubens           ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Abrir Orcamento VS1/VS3/VS4 atraves do Agendamento Oficina ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function OFM350GERAORC()
Local aPosListbox, wVar, nCntFor, cTTInc
Local oDlgExport
Local oEncExport
Local aCpoEnchoice := {}
Local aNewBot := {{"PARAMETROS",{|| FS_ALTTTFATPAR() },STR0111 }}//Altera TT e Faturar Para
Local cTTPadPec := AllTrim(GetNewPar("MV_INCTTPA","")) // TT padrao para Pecas para inconvenientes manuais
Local cTTPadSer := cTTPadPec // TT padrao para Servicos para inconvenientes manuais
Local aTTCliente, cNomeCliente
Local cIncCpo  := ""
Local lIncSalva := Inclui
Local lAltSalva := Altera
Private aIncAg := {}
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oVerm := LoadBitmap( GetResources(), "BR_VERMELHO" )

If Empty(VSO->VSO_CODMAR) .or. Empty(VSO->VSO_PROVEI+VSO->VSO_LOJPRO) .or. Empty(VSO->VSO_GETKEY)
	MsgInfo(STR0092,STR0015) // Não é possivel gerar orcamento do agendamento selecionado. Cadastro do Cliente e/ou Veiculo incompleto! / Atencao
	Return
EndIf

nCntFor := AT(";",cTTPadPec)
if nCntFor <> 0 .and. nCntFor <> Len(cTTPadPec)
	cTTPadPec := PadR(Left(cTTPadPec,(nCntFor-1)),TamSX3("VOI_TIPTEM")[1]," ")
	cTTPadSer := PadR(SubStr(cTTPadSer,(nCntFor+1),Len(cTTPadSer)),TamSX3("VOI_TIPTEM")[1]," ")
else
	cTTPadPec := StrTran(cTTPadPec,";","")
	cTTPadPec := PadR(cTTPadPec,TamSX3("VOI_TIPTEM")[1]," ")
	cTTPadSer := cTTPadPec
endif

DbSelectArea("VOI")
DbSetOrder(1)
If DbSeek(xFilial("VOI")+cTTPadPec)
	If FieldPos("VOI_TTRELA")>0
		If !Empty(VOI->VOI_TTRELA)
			cTTPadSer := VOI->VOI_TTRELA
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configuracao para a Enchoice dos dados do Agendamento ³
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
dbSelectArea("SX3")
dbSetOrder(1)
dbgotop()
DbSeek("VSO")
While !Eof().and.(SX3->X3_ARQUIVO == "VSO")
	If X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. (AllTrim(SX3->X3_CAMPO) $ "VSO_PROVEI,VSO_LOJPRO,VSO_NOMPRO,VSO_PLAVEI,VSO_CODMAR,VSO_NUMIDE")
		AADD(aCpoEnchoice,SX3->X3_CAMPO)
	EndIf
	wVar := "M->"+SX3->X3_CAMPO
	&wVar:= CriaVar(SX3->X3_CAMPO,.f.)
	dbSkip()
EndDo

DbSelectArea("VSO")
For nCntFor := 1 TO FCount()
	&("M->"+Field(nCntFor)) := FieldGet(nCntFor)
Next
//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta matriz q sera utilizada no listbox ³
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
dbSelectArea("VST")
dbSetOrder(1)
dbSeek(xFilial("VST")+"3"+VSO->VSO_NUMIDE)
do While !VST->(Eof()) .and. VST->VST_FILIAL == xFilial("VST") .and. VST->VST_TIPO == "3" .and. VST->VST_CODIGO == VSO->VSO_NUMIDE
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ P E C A S ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
	
	// Inicializa com o Tipo de Tempo Padrao e Cliente do Agendamento
	aTTCliente := { cTTPadPec , VSO->VSO_PROVEI, VSO->VSO_LOJPRO }
	
	// Se informado grupo e codigo do inconveniente, verifica qual TT e Cliente deve ser selecionado
	If !Empty(VST->VST_GRUINC) .and. !Empty(VST->VST_CODINC)
		aTTCliente := OM420FATPAR("P", VSO->VSO_CODMAR, VST->VST_GRUINC, VST->VST_CODINC, VSO->VSO_PROVEI, VSO->VSO_LOJPRO, VSO->VSO_GETKEY)
	EndIf
	
	cNomeCliente := FM_SQL("SELECT A1_NOME FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = '"+aTTCliente[2]+"' AND A1_LOJA = '"+aTTCliente[3]+"' AND D_E_L_E_T_ = ' '")
	
	AADD( aIncAg , { IIF(VST->VST_EXPPEC == "1" , "1" , " " ) ,; // 01 - " " - Pode Garar OS / "1" - OS Ja Gerada / "2" - Selecionado para Gerar OS
	VST->VST_GRUINC,; 	// 02 - Grupo de Inconveniente
	VST->VST_CODINC,; 	// 03 - Codigo do Inconveniente
	VST->VST_DESINC,; 	// 04 - Descricao do Inconveniente
	PadR(STR0093,15," ")  ,; 	// 05 - Orcamento de ???
	aTTCliente[1],; 	// 06 - Tipo de Tempo
	aTTCliente[2],; 	// 07 - Cliente Faturar Para
	aTTCliente[3],; 	// 08 - Loja Faturar Para
	aTTCliente[2] + "-" + aTTCliente[3] + " " + cNomeCliente,;// 09 - Nome Faturar Para
	VST->VST_SEQINC,; 	// 10 - Seq do Inconveniente
	"1"; 				// 11 - Tipo de Registro - 1 = Peca
	})
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ S E R V I C O S ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	// Inicializa com o Tipo de Tempo Padrao e Cliente do Agendamento
	aTTCliente := { cTTPadSer , VSO->VSO_PROVEI, VSO->VSO_LOJPRO }
	
	// Se informado grupo e codigo do inconveniente, verifica qual TT e Cliente deve ser selecionado
	If !Empty(VST->VST_GRUINC) .and. !Empty(VST->VST_CODINC)
		aTTCliente := OM420FATPAR("S", VSO->VSO_CODMAR, VST->VST_GRUINC, VST->VST_CODINC, VSO->VSO_PROVEI, VSO->VSO_LOJPRO, VSO->VSO_GETKEY)
	EndIf
	
	cNomeCliente := FM_SQL("SELECT A1_NOME FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = '"+aTTCliente[2]+"' AND A1_LOJA = '"+aTTCliente[3]+"' AND D_E_L_E_T_ = ' '")
	
	AADD( aIncAg , { IIF(VST->VST_EXPSRV == "1" , "1" , " " ) ,; // 01 - " " - Pode Garar OS / "1" - OS Ja Gerada / "2" - Selecionado para Gerar OS
	VST->VST_GRUINC,; 	// 02 - Grupo de Inconveniente
	VST->VST_CODINC,; 	// 03 - Codigo do Inconveniente
	VST->VST_DESINC,; 	// 04 - Descricao do Inconveniente
	PadR(STR0094,15," ")	,; 	// 05 - Orcamento de ???
	aTTCliente[1],; 	// 06 - Tipo de Tempo
	aTTCliente[2],; 	// 07 - Cliente Faturar Para
	aTTCliente[3],; 	// 08 - Loja Faturar Para
	aTTCliente[2] + "-" + aTTCliente[3] + " " + cNomeCliente,;// 09 - Nome Faturar Para
	VST->VST_SEQINC,; 	// 10 - Seq do Inconveniente
	"2"; 				// 11 - Tipo de Registro - 2 = Servico
	})
	
	VST->(dbSkip())
end

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Esta sendo exportado um agendamento sem inconveniente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aIncAg) == 0
	cNomeCliente := FM_SQL("SELECT A1_NOME FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = '"+VSO->VSO_PROVEI+"' AND A1_LOJA = '"+VSO->VSO_LOJPRO+"' AND D_E_L_E_T_ = ' '")
	For nCntFor := 1 to 2
		AADD( aIncAg , { " " ,; // 01 - Indica se esta marcado para gerar OS
		Space(TamSX3("VST_GRUINC")[1]),; 	// 02 - Grupo de Inconveniente
		Space(TamSX3("VST_CODINC")[1]),; 	// 03 - Codigo do Inconveniente
		Space(TamSX3("VST_DESINC")[1]),; 	// 04 - Descricao do Inconveniente
		PadR(iif(nCntFor==1,STR0093,STR0094),15," ")	,;	// 05 - Orcamento de ???
		iif(nCntFor==1,cTTPadPec,cTTPadSer),; 				// 06 - Tipo de Tempo
		VSO->VSO_PROVEI,; 					// 07 - Cliente Faturar Para
		VSO->VSO_LOJPRO,; 					// 08 - Loja Faturar Para
		VSO->VSO_PROVEI + "-" + VSO->VSO_LOJPRO + " " + cNomeCliente,;// 09 - Nome Faturar Para
		Space(TamSX3("VST_SEQINC")[1]),;	// 10 - Sequencia do Inconveniente
		Str(nCntFor,1); 					// 11 - Tipo de Registro
		})
	Next nCntFor
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VSO",.t.)	// .t. para carregar campos virtuais
nOpcE   := 2 			// Visualizacao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a Modelo 3                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo        := STR0095
cAliasEnchoice := "VSO"

FM_Mod3(cTitulo,"VSO",/*cAlias2*/,aCpoEnchoice,/*aAltEnchoice*/,/*aAuxAHeader*/,/*aAuxACols*/,/*cFieldOk*/,/*cLinOk*/,/*cTudoOk*/,;
/*cDelOk*/,nOpcE,/*nOpcG*/,/*lVirtual*/,oMainWnd,@oDlgExport,@oEncExport,/*_oGetDados*/,/*cEnchNView*/,/*cGetDNView*/,;
/*nOrdGet2*/,/*cChvGet2*/,/*cVlChvGet2*/,@aPosListBox,/*nPercTela*/,30)

@ aPosListBox[1],aPosListBox[2] LISTBOX oIncAg FIELDS HEADER "",;
					AllTrim(RetTitle("VST_GRUINC")),;
					AllTrim(RetTitle("VST_CODINC")),;
					AllTrim(RetTitle("VST_DESINC")),;
					STR0096 ,;
					AllTrim(RetTitle("VOI_TIPTEM")),;
					AllTrim(RetTitle("VS1_CLIFAT")),;
					COLSIZES 7,30,30,60,40,30,100 ;
					SIZE aPosListBox[4]-aPosListBox[2], aPosListBox[3]-aPosListBox[1] OF oDlgExport PIXEL ON DBLCLICK FS_MARCAINC()
oIncAg:SetArray(aIncAg)
oIncAg:bLine := { || { IIF(Empty(aIncAg[oIncAg:nAt,1]),oNo,IIF(aIncAg[oIncAg:nAt,1] == "1", oVerm , oOk )) ,;
						aIncAg[oIncAg:nAt,2] ,;
						aIncAg[oIncAg:nAt,3] ,;
						aIncAg[oIncAg:nAt,4] ,;
						aIncAg[oIncAg:nAt,5] ,;
						aIncAg[oIncAg:nAt,6] ,;
						aIncAg[oIncAg:nAt,9] } }
nOpca := 0
ACTIVATE MSDIALOG oDlgExport ON INIT EnchoiceBar(oDlgExport,{ || if(FS_TUDOOKEXP(),(FS_EXPAGEND(),nOpca := 1,oDlgExport:End()),.F.)  }, { || oDlgExport:End() } ,, aNewBot)

If nOpca == 1
	OFIXA011(VSO->VSO_NUMIDE)
EndIf
Inclui := lIncSalva
Altera := lAltSalva

Return()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_MARCAINC ³ Autor ³ Rubens             ³ Data ³ 18/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Marca os Inconvenientes para Gerar Orcamento               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function FS_MARCAINC()
Local nCntFor

If Empty(aIncAg[oIncAg:nAt,1])
	aIncAg[oIncAg:nAt,1] := "2"
ElseIf aIncAg[oIncAg:nAt,1] == "2"
	aIncAg[oIncAg:nAt,1] := " "
EndIf

oIncAg:SetArray(aIncAg)
oIncAg:bLine := { || { IIF(Empty(aIncAg[oIncAg:nAt,1]),oNo,IIF(aIncAg[oIncAg:nAt,1] == "1", oVerm , oOk )) ,;
						aIncAg[oIncAg:nAt,2] ,;
						aIncAg[oIncAg:nAt,3] ,;
						aIncAg[oIncAg:nAt,4] ,;
						aIncAg[oIncAg:nAt,5] ,;
						aIncAg[oIncAg:nAt,6] ,;
						aIncAg[oIncAg:nAt,9] } }
oIncAg:Refresh()

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_TUDOOKEXP ³ Autor ³ Rubens            ³ Data ³ 18/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Verifica se pode exportar o agendamento                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function FS_TUDOOKEXP()
Local lRetorno := .t.
Local nCntFor

If Len(aIncAg) > 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se todos os TT e Fat Para foram informados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	for nCntFor := 1 to Len(aIncAg)
		If Empty(aIncAg[nCntFor,6])
			MsgAlert(STR0097,STR0015) // Atencao
			lRetorno := .f.
		EndIf
		If Empty(aIncAg[nCntFor,7]) .or. Empty(aIncAg[nCntFor,8])
			MsgAlert(STR0098,STR0015) // Atencao
			lRetorno := .f.
		EndIf
	next nCntFor
else
	// So sera criado orcamento sem inconveniente, se o agendamento estiver sem inconveniente
	If !Empty(aIncAg[1,4]) // Descricao do inconveniente
		lRetorno := .f.
	EndIf
EndIf

Return lRetorno

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_EXPAGEND ³ Autor ³ Rubens             ³ Data ³ 18/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Verifica se pode exportar o agendamento                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function FS_EXPAGEND()

Local nCntFor, nCntFor2, nAuxPos
Local aTTFatPar := {} // Matriz contendo todos os TT e Faturar Para { TT Peca , TT Servico , Cliente, Loja }
Local lAddFatPar
Local cAuxSeqInc, nAuxSeqVS3, nAuxSeqVS4
Local nValPec, nMarLuc
Local lKilometragem, nValHor
Local aTempPro, cCenCus
Local lVAJGRUMOD := (VAJ->(FieldPos("VAJ_GRUMOD")) > 0)
Local lVAJAPLICA := (VAJ->(FieldPos("VAJ_APLICA")) > 0)
Local lVS4SEQSER := (VS4->(FieldPos("VS4_SEQSER")) > 0 .and. VO7->(FieldPos("VO7_SEQSER")) > 0)
Local cSeqSer
Local lIncItem := .f.
Local cGruMod := ""
Private cFormulPeca := ""

// Levanta todos os TT e Fat. Para possiveis
For nCntFor := 1 to Len(aIncAg)
	// Pecas
	If aIncAg[nCntFor,11] == "1"
		nAuxPos := aScan(aTTFatPar,{ |x| x[1] == aIncAg[nCntFor,6] .and. x[3] == aIncAg[nCntFor,7] .and. x[4] == aIncAg[nCntFor,8] } )
		// Servicos
	ElseIf aIncAg[nCntFor,11] == "2"
		nAuxPos := aScan(aTTFatPar,{ |x| x[2] == aIncAg[nCntFor,6] .and. x[3] == aIncAg[nCntFor,7] .and. x[4] == aIncAg[nCntFor,8] } )
	EndIf
	
	lAddFatPar := .t. // Adiciona na matriz ...
	If nAuxPos == 0
		For nAuxPos := 1 to Len(aTTFatPar)
			// Se for o mesmo faturar para ...
			If aTTFatPar[nAuxPos,3] == aIncAg[nCntFor,7] .and. aTTFatPar[nAuxPos,4] == aIncAg[nCntFor,8]
				// Pecas
				If aIncAg[nCntFor,11] == "1" .and. empty(aTTFatPar[nAuxPos,1])
					aTTFatPar[nAuxPos,1] := aIncAg[nCntFor,6]
					lAddFatPar := .f.
					exit
				EndIf
				
				// Servicos
				If aIncAg[nCntFor,11] == "2" .and. empty(aTTFatPar[nAuxPos,2])
					aTTFatPar[nAuxPos,2] := aIncAg[nCntFor,6]
					lAddFatPar := .f.
					exit
				EndIf
			EndIf
		Next nAuxPos
		
		If lAddFatPar
			AADD( aTTFatPar, { "", "", aIncAg[nCntFor,7], aIncAg[nCntFor,8] } )
			// Atualiza TT de Peca ou Servico ...
			aTTFatPar[Len(aTTFatPar), Val(aIncAg[nCntFor,11])] := aIncAg[nCntFor,6]
		EndIf
		
	EndIf
	
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera Orcamentos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction

For nAuxPos := 1 to Len(aTTFatPar)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se nao ficou algum TT em branco, e atualiza ele..³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Se o TT de Peca estiver vazio, grava o TT de Servico
	If empty(aTTFatPar[nAuxPos,1])
		aTTFatPar[nAuxPos,1] := aTTFatPar[nAuxPos,2]
	EndIf
	// Se o TT de Servico estiver vazio, grava o TT de Peca
	If empty(aTTFatPar[nAuxPos,2])
		aTTFatPar[nAuxPos,2] := aTTFatPar[nAuxPos,1]
	EndIf

	// Posiciona Cliente
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+aTTFatPar[nAuxPos,3]+aTTFatPar[nAuxPos,4])
	
	// Posiciona Veiculo
	dbSelectArea("VV1")
	dbSetOrder(2)
	dbSeek(xFilial("VV1")+VSO->VSO_GETKEY)
	
	// Procura Modelo do veiculo
	cGruMod := FM_SQL("SELECT VV2_GRUMOD FROM "+RetSQLName("VV2")+" WHERE VV2_FILIAL = '"+xFilial("VV2")+"' AND VV2_CODMAR = '"+VV1->VV1_CODMAR+"' AND VV2_MODVEI = '"+VV1->VV1_MODVEI+"' AND D_E_L_E_T_ = ' '")
	
	// Posiciona o TT de Peca
	dbSelectArea("VOI")
	dbSetOrder(1)
	dbSeek(xFilial("VOI")+aTTFatPar[nAuxPos,1])
	
	// Formula para calculo do valor das pecas
	cFormulPeca := iif( !Empty(VOI->VOI_VALPEC) , VOI->VOI_VALPEC , &(GETMV("MV_FMLPECA")) )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cabecalho do Orcamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("VS1")
	RecLock("VS1",.T.)
	VS1->VS1_FILIAL := xFilial("VS1")
	VS1->VS1_NUMORC := GetSXENum("VS1","VS1_NUMORC")
	VS1->VS1_TIPORC := "2" // Orcamento de Oficina
	VS1->VS1_NUMAGE := VSO->VSO_NUMIDE
	
	VS1->VS1_CLIFAT := aTTFatPar[nAuxPos,3]
	VS1->VS1_LOJA   := aTTFatPar[nAuxPos,4]
	VS1->VS1_NCLIFT := SA1->A1_NOME
	VS1->VS1_TIPCLI := SA1->A1_TIPO
	
	VS1->VS1_OBSMEM := VSO->VSO_OBSMEM
	VS1->VS1_CODMAR := VSO->VSO_CODMAR
	
	VS1->VS1_DATORC := CriaVar("VS1_DATORC")
	VS1->VS1_HORORC := CriaVar("VS1_HORORC")
	VS1->VS1_CODVEN := CriaVar("VS1_CODVEN")
	VS1->VS1_DATVAL := CriaVar("VS1_DATVAL")
	VS1->VS1_TIPTEM := aTTFatPar[nAuxPos,1]  // TT de Peca
	VS1->VS1_TIPTSV := aTTFatPar[nAuxPos,2]  // TT de Servico

	VS1->VS1_FORMUL := cFormulPeca
	VS1->VS1_CHAINT := VV1->VV1_CHAINT
	VS1->VS1_TIPVEN := "1" // Varejo

	VS1->VS1_STATUS := "0"
	VS1->VS1_CFNF   := "1" // Gera Nota Fiscal
	VS1->VS1_KILOME := VSO->VSO_KILOME
	If VSO->(FieldPos("VSO_HORTRI")) <> 0
		VS1->VS1_HORTRI := VSO->VSO_HORTRI
    Endif
	If VS1->(FieldPos("VS1_TPATEN")) <> 0
		VS1->VS1_TPATEN := VSO->VSO_TPATEN
    Endif
	//Ponto de entrada para gravacao do agendamento no orcamento.
	if ExistBlock("OF350GRORC")
		ExecBlock("OF350GRORC",.f.,.f.)
	Endif
	MsUnLock()
	ConfirmSx8()
	If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
		OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0001 ) // Grava Data/Hora na Mudança de Status do Orçamento / Agendamento Oficina
	EndIf
	If FindFunction("FM_GerLog")
		//grava log das alteracoes das fases do orcamento
		FM_GerLog("F",VS1->VS1_NUMORC)
	EndIF
	
	// Variaveis auxiliares para controlar sequencial
	cAuxSeqInc := ""
	nAuxSeqVS3 := 0
	nAuxSeqVS4 := 0
	//
	
	// Importa Inconvenientes Selecionados
	For nCntFor := 1 to Len(aIncAg)
		
		//    Se for o Inconveniente de Peca e o TT de Peca for igual ao TT de Peca de Faturar para
		// ou Se for o Inconveniente de Servico e o TT de Servico for igual ao TT de Servico de Faturar para
		// e  o Cliente e Loja devem ser iguais
		If ( (aIncAg[nCntFor,11] == "1" .and. aIncAg[nCntFor,6] == aTTFatPar[nAuxPos,1]) ;
			.or. (aIncAg[nCntFor,11] == "2" .and. aIncAg[nCntFor,6] == aTTFatPar[nAuxPos,2]) ) ;
			.and. aIncAg[nCntFor,7] == aTTFatPar[nAuxPos,3] .and. aIncAg[nCntFor,8] == aTTFatPar[nAuxPos,4]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava Inconveniente³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cAuxSeq := OM420IMPINC("3", VSO->VSO_NUMIDE, aIncAg[nCntFor,10], "1", VS1->VS1_NUMORC)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Importa pecas e Servicos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aIncAg[nCntFor,2]) .and. !Empty(aIncAg[nCntFor,3])
				dbSelectArea("VAJ")
				dbSetOrder(1) // VAJ_FILIAL+VAJ_CODMAR+VAJ_CODGRU+VAJ_CODINC+VAJ_TIPTEM+VAJ_CODMOD+VAJ_CODSEG+VAJ_TIPSER+VAJ_CODSER+VAJ_GRUPEC+VAJ_CODPEC
				if !dbSeek(xFilial("VAJ") + VS1->VS1_CODMAR + aIncAg[nCntFor,2] + aIncAg[nCntFor,3] )
					dbSelectArea("VAJ")
					dbSetOrder(1) // VAJ_FILIAL+VAJ_CODMAR+VAJ_CODGRU+VAJ_CODINC+VAJ_TIPTEM+VAJ_CODMOD+VAJ_CODSEG+VAJ_TIPSER+VAJ_CODSER+VAJ_GRUPEC+VAJ_CODPEC
					dbSeek(xFilial("VAJ") + Space(TamSX3("VS1_CODMAR")[1]) + aIncAg[nCntFor,2] + aIncAg[nCntFor,3] )
					cMarca := Space(TamSX3("VS1_CODMAR")[1])
				Else
					cMarca := VS1->VS1_CODMAR
				Endif
				Do While !VAJ->(Eof()) .and. VAJ->VAJ_FILIAL == xFilial("VAJ") .and. VAJ->VAJ_CODMAR == cMarca .and. VAJ->VAJ_CODGRU == aIncAg[nCntFor,2] .and. VAJ->VAJ_CODINC == aIncAg[nCntFor,3]
					
					// Posiciona Veiculo, pois algumas funcoes estavam desposicionando VV1
					VV1->(DbSetOrder(1))
					VV1->(MsSeek(xFilial("VV1")+VS1->VS1_CHAINT))
					 
					lIncItem := .f.
					// Existe os campos de Grupo de Modelo e Aplicacao ...
					If lVAJGRUMOD .and. lVAJAPLICA
						If ( Empty(VAJ->VAJ_CODMOD) .and. Empty(VAJ->VAJ_GRUMOD) .and. Empty(VAJ->VAJ_APLICA)) ;
							.OR. ( VAJ->VAJ_CODMOD == VV1->VV1_MODVEI ) ;
							.OR. ( VAJ->VAJ_GRUMOD == cGruMod ) ;
							.OR. ( AllTrim(VAJ->VAJ_APLICA) == SubStr(VV1->VV1_CHASSI,4,4) )
							
							lIncItem := .t.
							
						EndIf
					Else
						If Empty(VAJ->VAJ_CODMOD) .or. VAJ->VAJ_CODMOD == VV1->VV1_MODVEI
							lIncItem := .t.
						EndIf
					EndIf
					
					If !lIncItem
						VAJ->(dbSkip())
						Loop
					EndIf
					
					
					// Pecas
					If aIncAg[nCntFor,11] == "1" .and. !Empty(VAJ->VAJ_GRUPEC) .and. !Empty(VAJ->VAJ_CODPEC) .and. VAJ->VAJ_QTDPEC > 0
						
						dbSelectArea("SB1")
						dbSetOrder(7)
						dbSeek(xFilial("SB1")+VAJ->VAJ_GRUPEC+VAJ->VAJ_CODPEC)
						
						if SB1->B1_MSBLQL == "1"
							HELP(" ",1,"REGBLOQ")
						else
							
							DBSelectArea("VAI")
							DBSetOrder(6)
							If DBSeek(xFilial("VAI")+VS1->VS1_CODVEN)
								cCenCus := VAI->VAI_CC
							else
								cCenCus := Space(TamSX3("VS1_CENCUS")[1])
							EndIf

							SBM->(dbSetOrder(1))
							SBM->(dbSeek(xFilial("SBM")+VAJ->VAJ_GRUPEC))
							// a Primeira Chamada é apenas para se ter o Valor da Peça (Promocao)
							aTempPro := OX005PERDES(SBM->BM_CODMAR,;
													cCenCus,;
													VAJ->VAJ_GRUPEC,;
													VAJ->VAJ_CODPEC,;
													VAJ->VAJ_QTDPEC,;
													0,;
													.f.,;
													VS1->VS1_CLIFAT,;
													VS1->VS1_LOJA,;
													"3",; // OFICINA É SEMPRE "3" (1 = ATACADO, 2 = VAREJO, 3 = OFICINA)
													0,;
													2)
							nValPec  := aTempPro[1]
							//
							If nValPec == 0
								nValPec := FG_VALPEC(VS1->VS1_TIPTEM,"cFormulPeca",VAJ->VAJ_GRUPEC,VAJ->VAJ_CODPEC,,.f.,.t.)
							EndIf
							
							++nAuxSeqVS3
							
							dbSelectArea("VS3")
							RecLock("VS3",.T.)
							nRecVS3 := recno()
							VS3->VS3_FILIAL := xFilial("VS3") 	// Filial
							VS3->VS3_NUMORC := VS1->VS1_NUMORC 	// Numero do Orcamento
							VS3->VS3_SEQUEN := STRZERO(nAuxSeqVS3,TamSX3("VS3_SEQUEN")[1]) // Sequencia
							VS3->VS3_SEQINC := cAuxSeq 			// Sequencia Inconveniente
							VS3->VS3_GRUITE := VAJ->VAJ_GRUPEC 	// Grupo do Item
							VS3->VS3_CODITE := VAJ->VAJ_CODPEC 	// Codigo do Item
							
							VS3->VS3_FORMUL := cFormulPeca 		// Formula do Calculo Valor

							if !Empty(VOI->VOI_CODOPE)
								VS3->VS3_OPER := VOI->VOI_CODOPE
								VS3->VS3_CODTES := MaTesInt(2,VOI->VOI_CODOPE,VS1->VS1_CLIFAT,VS1->VS1_LOJA,"C",SB1->B1_COD)
							else							
								VS3->VS3_CODTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS") 		// T.E.S.
							endif
							
							VS3->VS3_LOCAL  := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") 	// Armazem
							
							If VS3->(FieldPos("VS3_CODSIT")) <> 0
								VS3->VS3_CODSIT := CriaVar("VS3_CODSIT") // Codigo Si
							EndIf
							VS3->VS3_QTDINI := VAJ->VAJ_QTDPEC	// Quantidade Inicial
							VS3->VS3_QTDITE := VAJ->VAJ_QTDPEC 	// Qtde Requisitada
							VS3->VS3_VALPEC := nValPec 			// Valor da Peca
							VS3->VS3_VALTOT := VAJ->VAJ_QTDPEC * nValPec  // Vl Total // Valor Total M->VS3_VALTOT := (M->VS3_QTDITE * M->VS3_VALPEC) - M->VS3_VALDES
							
							//							VS3->VS3_MODVEI :=  // Modelo do Veiculo
							//							VS3->VS3_GRUKIT :=  // Grupo do Kit ???
							//							VS3->VS3_CODKIT :=  // Codigo do Kit ???
							//							VS3->VS3_ITESUB :=  // Cod. Ite Sub ???
							//							VS3->VS3_OPER   :=  // Tipo de Operacao ???
							MsUnLock()

							SBM->(dbSetOrder(1))
							SBM->(dbSeek(xFilial("SBM")+VAJ->VAJ_GRUPEC))
							// Chama novamente apenas para calcular Margem de Lucro
							aTempPro := OX005PERDES(SBM->BM_CODMAR,;
													cCenCus,;
													VAJ->VAJ_GRUPEC,;
													VAJ->VAJ_CODPEC,;
													VAJ->VAJ_QTDPEC,;
													0,;
													.f.,;
													VS1->VS1_CLIFAT,;
													VS1->VS1_LOJA,;
													"3",; // OFICINA É SEMPRE "3" (1 = ATACADO, 2 = VAREJO, 3 = OFICINA)
													0,;
													2)
							nMarLuc  := aTempPro[2]
							//
							dbSelectArea("VS3")
							Dbgoto(nRecVS3)
							RecLock("VS3",.f.)

							VS3->VS3_MARLUC := nMarLuc 			// Margem de Lucro

							MsUnLock()

						endif
						
					EndIf
					
					// Servicos
					If aIncAg[nCntFor,11] == "2" .and. !Empty(VAJ->VAJ_TIPSER) .and. !Empty(VAJ->VAJ_CODSER) 
						
						++nAuxSeqVS4
						
						// Posiciona o TT de Servico
						dbSelectArea("VOI")
						dbSetOrder(1)
						dbSeek(xFilial("VOI")+aTTFatPar[nAuxPos,2])
						
						// Posiciona na tabela de servicos
						DBSelectArea("VOK")
						DBSetOrder(1)
						DBSeek(xFilial("VOK")+VAJ->VAJ_TIPSER)
						//
						lKilometragem := .f.
						If VOK->VOK_INCMOB == "5"
							lKilometragem := .t.
						EndIf
						//
						
						If lKilometragem
							nValHor := VOK->VOK_PREKIL
							nTemPad := 0
							nValSer := 0
						else
							nValHor := If(VOK->VOK_INCMOB $ "0/2/5/6",0,FG_VALHOR(VOI->VOI_TIPTEM,dDataBase,,,VS1->VS1_CODMAR,VAJ->VAJ_CODSER,VAJ->VAJ_TIPSER,VS1->VS1_CLIFAT,VS1->VS1_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD))
							cSeqSer := ""
							if lVS4SEQSER .AND. VS1->VS1_CODMAR == FG_MARCA("CHEVROLET",,.f.)
								cQryAl001 := GetNextAlias()
								cQuery := "SELECT VO7_SEQSER, VO7.R_E_C_N_O_ RECVO7 FROM " + RetSQLName("VO7") + " VO7 "
								cQuery += " WHERE VO7_FILIAL = '" + xFilial("VO7") + "'"
								cQuery +=   " AND VO7_CODMAR = '" + VS1->VS1_CODMAR + "'"
								cQuery +=   " AND VO7_CODSER = '" + VAJ->VAJ_CODSER + "'"
								cQuery +=   " AND VO7_APLICA = '" + substr(VV1->VV1_CHASSI,4,4) + "'"
								cQuery +=   " AND D_E_L_E_T_ = ' '"
								dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
								If !(cQryAl001)->(Eof())
									cSeqSer := (cQryAl001)->VO7_SEQSER
									DBSelectArea("VO7")
									DBGoto((cQryAl001)->(RECVO7))
								EndIf
								(cQryAl001)->(dbCloseArea())
								nTemPad := OX001TemPad(VV1->VV1_CODMAR,VAJ->VAJ_CODSER,if(VOK->VOK_INCTEM == "3","1",VOK->VOK_INCTEM),,VO7->VO7_APLICA,VO7->VO7_CONTRO)
							else
								nTemPad := FG_TEMPAD(VV1->VV1_CHAINT,VAJ->VAJ_CODSER,if(VOK->VOK_INCTEM == "3","1",VOK->VOK_INCTEM),,VS1->VS1_CODMAR)
							endif
							nValSer := (nTemPad /100) * nValHor
						EndIf
						
						dbSelectArea("VS4")
						Reclock("VS4",.t.)
						VS4->VS4_FILIAL := xFilial("VS4") 	// Filial
						VS4->VS4_SEQINC := cAuxSeq 			// Sequencia Inconveniente
						VS4->VS4_NUMORC := VS1->VS1_NUMORC 	// Numero do Orcamento
						VS4->VS4_SEQUEN := STRZERO(nAuxSeqVS4,TamSX3("VS4_SEQUEN")[1]) // Sequencia
						VS4->VS4_GRUSER := VAJ->VAJ_GRUSER 	// Grupo de Servico
						VS4->VS4_CODSER := VAJ->VAJ_CODSER 	// Codigo do Servico
						VS4->VS4_TIPSER := VAJ->VAJ_TIPSER 	// Tipo de Servico
						VS4->VS4_TEMPAD := nTemPad 			// Tempo Padrao
						VS4->VS4_VALHOR := nValHor 			// Vlr da Hora
						VS4->VS4_KILROD := 0 				// Kilometro Rodado
						VS4->VS4_VALSER := nValSer 			// Valor do Servico
						VS4->VS4_CODSEC := VAJ->VAJ_CODSEC 	// Secao da Oficina
						VS4->VS4_VALTOT := nValSer 			// Valor Total
						
						if lVS4SEQSER
							VS4->VS4_SEQSER := cSeqSer
						endif
						MsUnLock()
						
					EndIf
					
					VAJ->(dbSkip())
				EndDo
			EndIf
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Marca o Inconveniente do Agendamento como Exportado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("VST")
			dbSetOrder(1)
			If dbSeek(xFilial("VST")+"3"+VSO->VSO_NUMIDE+aIncAg[nCntFor,10])
				
				aIncAg[nCntFor,1] := "1"
				
				RecLock("VST",.f.)
				// Pecas
				If aIncAg[nCntFor,11] == "1"
					VST->VST_EXPPEC := "1"
					// Servicos
				ElseIf aIncAg[nCntFor,11] == "2"
					VST->VST_EXPSRV := "1"
				EndIf
				MsUnLock()
			EndIf
		EndIf
		//
	Next nCntFor
	
Next nCntFor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza Status do Agendamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OM350STATUS(VSO->VSO_NUMIDE,"1","5")
End Transaction

oIncAg:SetArray(aIncAg)
oIncAg:bLine := { || { IIF(Empty(aIncAg[oIncAg:nAt,1]),oNo,IIF(aIncAg[oIncAg:nAt,1] == "1", oVerm , oOk )) ,;
						aIncAg[oIncAg:nAt,2] ,;
						aIncAg[oIncAg:nAt,3] ,;
						aIncAg[oIncAg:nAt,4] ,;
						aIncAg[oIncAg:nAt,5] ,;
						aIncAg[oIncAg:nAt,6] ,;
						aIncAg[oIncAg:nAt,9] } }
oIncAg:Refresh()

MsgAlert(STR0099,STR0015) // Atencao

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ FS_ALTTTFATPAR ³ Autor ³ Rubens          ³ Data ³ 18/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Altera TT e Faturar Para                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function FS_ALTTTFATPAR()
Local aRet := {}
Local aParamBox := {}
Local nCntFor
Local cTT, cCliente, cLoja, cNomeCliente

If (aScan(aIncAg, { |x| x[1] == "2"} ) == 0)
	MsgAlert(STR0100,STR0015) // Atencao
	return
EndIf

// Inicializa os Parametros da ParamBOX
cTT 	 := Space(TamSX3("VS1_TIPTEM")[1])                   
cCliente := Space(TamSX3("VS1_CLIFAT")[1])
cLoja    := Space(TamSX3("VS1_LOJA")[1])
for nCntFor := 1 to Len(aIncAg)
	If aIncAg[nCntFor,1] == "2"
		If empty(cTT)
			cTT := PadR(aIncAg[nCntFor,6],TamSX3("VS1_TIPTEM")[1])
		EndIf
		If empty(cCliente)
			cCliente := PadR(aIncAg[nCntFor,7],TamSX3("VS1_CLIFAT")[1])
			cLoja    := PadR(aIncAg[nCntFor,8],TamSX3("VS1_LOJA")[1])
		EndIf
	EndIf
next
//

// Configura e exibe Parambox
aAdd(aParamBox,{1,RetTitle("VS1_TIPTEM"),cTT     ,"@!","ExistCpo('VOI',MV_PAR01)","VOI","",0,.T.}) // Tipo caractere
aAdd(aParamBox,{1,RetTitle("VS1_CLIFAT"),cCliente,"","","VSA","",0,.T.}) // Tipo caractere
aAdd(aParamBox,{1,RetTitle("VS1_LOJA")  ,cLoja   ,"","",""   ,"",0,.T.}) // Tipo caractere

While .T.
	If ParamBox(aParamBox,STR0101,@aRet,,,,,,,,.F.)
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+aRet[2]+aRet[3]))
			Exit
		EndIf
	Else
		Return
	EndIf
EndDo


// Altera e atualiza Matriz do Listbox
cNomeCliente := Posicione("SA1",1,xFilial("SA1")+aRet[2]+aRet[3],"A1_NOME")
For nCntFor := 1 to Len(aIncAg)
	If aIncAg[nCntFor,1] == "2"
		aIncAg[nCntFor,1] := " "     // Desmarca Item
		aIncAg[nCntFor,6] := aRet[1] // Tipo de Tempo
		aIncAg[nCntFor,7] := aRet[2] // Cliente Faturar Para
		aIncAg[nCntFor,8] := aRet[3] // Loja Faturar Para
		aIncAg[nCntFor,9] := aRet[2]+"-"+aRet[3]+" "+cNomeCliente // Nome Faturar Para
	EndIf
Next

oIncAg:SetArray(aIncAg)
oIncAg:bLine := { || { IIF(Empty(aIncAg[oIncAg:nAt,1]),oNo,IIF(aIncAg[oIncAg:nAt,1] == "1", oVerm , oOk )) ,;
						aIncAg[oIncAg:nAt,2] ,;
						aIncAg[oIncAg:nAt,3] ,;
						aIncAg[oIncAg:nAt,4] ,;
						aIncAg[oIncAg:nAt,5] ,;
						aIncAg[oIncAg:nAt,6] ,;
						aIncAg[oIncAg:nAt,9] } }
oIncAg:Refresh()

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ OM350OS        ³ Autor ³ Thiago          ³ Data ³ 13/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Visualiza Ordem de Servicos relacionadas ao Agendamento    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function OM350OS()

//Local aOS := {{"","","","","","",ctod("  /  /  ")}}
Local cQAlVS1 := "SQLVS1"
Local lIncSalva := Inclui
Local lAltSalva := Altera

cQuery := "SELECT VS1.VS1_FILIAL,VS1.VS1_NUMOSV "
cQuery += "FROM "+RetSqlName("VS1")+" VS1 WHERE "
cQuery += "VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND VS1.VS1_NUMAGE='"+VSO->VSO_NUMIDE+"' AND "
cQuery += "VS1.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS1, .F., .T. )
aOS := {}
Do While !( cQAlVS1 )->( Eof() )
	
	dbSelectArea("VO1")
	dbSetOrder(1)
	dbSeek(xFilial("VO1")+( cQAlVS1 )->VS1_NUMOSV)
	While !Eof() .and. xFilial("VO1") == ( cQAlVS1 )->VS1_FILIAL .and. ( cQAlVS1 )->VS1_NUMOSV == VO1->VO1_NUMOSV
		
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+VO1->VO1_PROVEI+VO1->VO1_LOJPRO)
		if Len(aOS) == 1 .and. Empty(aOS[1,1])
			aOS := {}
		Endif
		nPos := aScan(aOS,{|x| x[1] == VO1->VO1_NUMOSV })
		if nPos == 0
			AAdd( aOS, { VO1->VO1_NUMOSV, VO1->VO1_CHASSI, VO1->VO1_PLAVEI , VO1->VO1_PROVEI,VO1->VO1_LOJPRO,SA1->A1_NOME,VO1->VO1_DATABE} )
		Endif
		dbSelectArea("VO1")
		dbSkip()
		
	Enddo
	dbSelectArea(cQAlVS1)
	( cQAlVS1 )->(dbSkip())
Enddo
( cQAlVS1 )->( dbCloseArea() )
if Len(aOS) == 0
	MsgInfo(STR0112,STR0015) //Nao existe dados para esta consulta ## ATENCAO
	Return(.f.)
Endif
if Len(aOS) > 1
	DEFINE MSDIALOG oDlg1 FROM 000,000 TO 028,100 TITLE STR0113 OF oMainWnd //Consulta Ordem de Servico
	@ 001,001 LISTBOX oLbx1 FIELDS HEADER  OemToAnsi(STR0114),OemToAnsi(STR0115),OemToAnsi(STR0116),OemToAnsi(STR0117),OemToAnsi(STR0118),OemToAnsi(STR0119),OemToAnsi(STR0120);//Nro O.S. ###"Chassi"##"Placa"##"Proprietario"##"Loja"##"Nome##Data Abert O.S.
	COLSIZES 30,60,30,40,20,130,40 SIZE 394,197 OF oDlg1 PIXEL ON DBLCLICK FS_SELECT()
	oLbx1:SetArray(aOS)
	oLbx1:bLine := { || {  aOS[oLbx1:nAt,1],;
							aOS[oLbx1:nAt,2],;
							aOS[oLbx1:nAt,3],;
							aOS[oLbx1:nAt,4],;
							aOS[oLbx1:nAt,5],;
							aOS[oLbx1:nAt,6],;
							transform(aOS[oLbx1:nAt,7],"@D") }}
	@ 199,340 BUTTON oSair PROMPT OemToAnsi(STR0121) OF oDlg1 SIZE 40,10 PIXEL  ACTION (FS_SAIR())//"SAIR"
	ACTIVATE MSDIALOG oDlg1 CENTER //ON INIT EnchoiceBar(oDlg1, {|| (FS_CHAMABAIXA(),If(lFecha,oDlg1:End(),lFecha:=.f.)) } , {|| oDlg1:End() })
Else
	dbSelectArea("VO1")
	dbSetOrder(1)
	dbSeek(xFilial("VO1")+aOS[1,1])
	OC060()
Endif
Inclui := lIncSalva
Altera := lAltSalva

Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_SELECT     ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada da consulta da Ordem de servico       				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SELECT()

dbSelectArea("VO1")
dbSetOrder(1)
dbSeek(xFilial("VO1")+aOS[oLbx1:nAt,1])
OC060()

Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_SAIR       ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fechar tela								       				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SAIR()
oDlg1:End()
Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ OM350CONF      ³ Autor ³ Thiago          ³ Data ³ 13/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Confirma agendamento                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function OM350CONF()
local cMsgAge := ""
If VSO->VSO_STATUS != "1"
	If VSO->VSO_STATUS == "5"
		cMsgAge := STR0122 // "com Orcamento Aberto!"
	ElseIf VSO->VSO_STATUS=="2"
		cMsgAge := STR0123 // "com OS Aberta!"
	ElseIf VSO->VSO_STATUS=="3"
		cMsgAge := STR0124 // "Finalizado!"
	ElseIf VSO->VSO_STATUS=="4"
		cMsgAge := STR0125 // "Cancelado!"
	Endif
	MsgStop(STR0126 + cMsgAge,STR0015)//Impossivel confirmar Agendamento ## atencao
	Return(.f.)
Else
	if VSO->VSO_AGCONF == "1" .or. VSO->VSO_AGCONF == "2"
		MsgStop(STR0108,STR0015)//Agendamento ja confirmado ## atencao
		Return(.f.)
	Endif
	if MsgYesNo(STR0109,STR0015)//Confirma agendamento? ## atencao
		dbSelectArea("VSO")
		RecLock("VSO",.f.)
		VSO->VSO_AGCONF := "1"
		MsUnlock()
		if MsgYesNo(STR0110,STR0015)//Deseja fazer CheckList? ## atencao
			OFIOA280()
		Endif
	Endif
Endif

// Ponto de entrada para impressao do relatorio no momento da confirmacao do agendamento
If ExistBlock("OM350CON")
	ExecBlock("OM350CON",.f.,.f.,{VSO->VSO_NUMIDE})
Endif

Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LEG        ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda    								       				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEG()
aLegenda := {{'BR_VERDE',STR0128},{'BR_VERMELHO',STR0129}}
BrwLegenda(STR0007,STR0006,aLegenda)
Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OM350KIL      ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do campo kilometragem  			       			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM350KIL(cChassi)
Local nUltKil := 0
dbSelectArea("VV1")
dbSetOrder(2)
if dbSeek(xFilial("VV1")+cChassi)
	nUltKil := FG_ULTKIL(VV1->VV1_CHAINT)
	if nUltKil > M->VSO_KILOME
		MsgStop( STR0146+" ("+Transform(M->VSO_KILOME,"@E 999,999,999")+" ) "+STR0147+" ("+Transform(nUltKil,"@E 999,999,999")+" )!",STR0015) //KM/hora informada # menor que da OS anterior
		Return .f. // ERRO: KILOMETRAGEM MENOR
	Endif
Else
	Return .f.
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³OM350INCPR³ Autor ³ Andre Luis Almeida    ³ Data ³ 25/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Utilizacao de Plano de Revisao / Inconvenientes            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Agendamento Oficina                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM350INCPR(nOpc)
Local lOk     := .t.
Local ni      := 0
Local nj      := 0
Local aIncSel := {}
If Empty(M->VSO_GETKEY) // Verifica se o Veiculo foi digitado (chassi)
	MsgStop(STR0077,STR0015) // Veiculo nao selecionado! / Atencao
	Return()
EndIf
If M->VSO_KILOME == 0 // Verifica se a KM do Veiculo foi digitada
	MsgStop(STR0145,STR0015) // KM/Hora nao informada!
	Return()
EndIf
n := oAuxGetDados:nAt
OM350LINHAOK()
dbSelectArea("VV1")
dbSetOrder(2)
dbSeek(xFilial("VV1")+M->VSO_GETKEY)
aIncSel := FG_PLAREV(VV1->VV1_CHAINT,M->VSO_KILOME,nOpc) // Chamada da Funcao para Visualizar Inconvenientes / Plano de Revisao do Veiculo
If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
	ProcRegua(len(aIncSel))
	For ni := 1 to len(aIncSel) // Carregar Pecas/Servicos do Inconveniente
		lOk := .t.
		IncProc(STR0144) // Analisando Inconvenientes...
		For nj := 1 to len(oAuxGetDados:aCols)
			If !oAuxGetDados:aCols[nj,len(oAuxGetDados:aHeader)+1]
				If oAuxGetDados:aCols[nj,FG_POSVAR("VST_GRUINC","oAuxGetDados:aHeader")] == aIncSel[ni,1] .and. oAuxGetDados:aCols[nj,FG_POSVAR("VST_CODINC","oAuxGetDados:aHeader")] == aIncSel[ni,2] .and. oAuxGetDados:aCols[nj,FG_POSVAR("VST_DESINC","oAuxGetDados:aHeader")] == aIncSel[ni,3]
					lOk := .f.
					MsgStop(STR0019,STR0015) // Inconveniente ja digitado! / Atencao
					Exit
				EndIf
			EndIf
		Next
		If lOk
			M->VST_GRUINC := aIncSel[ni,1]
			M->VST_CODINC := aIncSel[ni,2]
			M->VST_DESINC := aIncSel[ni,3]
			If !Empty(oAuxGetDados:aCols[n,FG_POSVAR("VST_GRUINC","oAuxGetDados:aHeader")]+oAuxGetDados:aCols[n,FG_POSVAR("VST_CODINC","oAuxGetDados:aHeader")]+oAuxGetDados:aCols[n,FG_POSVAR("VST_DESINC","oAuxGetDados:aHeader")])
				AADD(oAuxGetDados:aCols,Array(len(oAuxGetDados:aHeader)+1))
				oAuxGetDados:aCols[Len(oAuxGetDados:aCols),len(oAuxGetDados:aHeader)+1] := .F.
				oAuxGetDados:nAt := n := Len(oAuxGetDados:aCols)
			Else
				oAuxGetDados:aCols[Len(oAuxGetDados:aCols),len(oAuxGetDados:aHeader)+1] := .F.
				oAuxGetDados:nAt := n
				oAuxGetDados:lNewLine := .f.
			EndIf
			oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VST_GRUINC","oAuxGetDados:aHeader")] := M->VST_GRUINC
			oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VST_CODINC","oAuxGetDados:aHeader")] := M->VST_CODINC
			oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VST_DESINC","oAuxGetDados:aHeader")] := M->VST_DESINC
		EndIf
	Next
	oAuxGetDados:oBrowse:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FS_VALIDLBOX³ Autor ³ Thiago                ³ Data ³ 27/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao se a listbox esta com conteudo.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Agendamento Oficina                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALIDLBOX()
Local lRet := .t.
if Len(aFilDesc) > 0 .and. !Empty(aFilDesc[1,3])
	aRetPossAge := {aFilDesc[oLbPosA:nAt,12],aFilDesc[oLbPosA:nAt,13],aFilDesc[oLbPosA:nAt,4],aFilDesc[oLbPosA:nAt,8],aFilDesc[oLbPosA:nAt,9],aFilDesc[oLbPosA:nAt,10],aFilDesc[oLbPosA:nAt,11],aFilDesc[oLbPosA:nAt,5],aFilDesc[oLbPosA:nAt,6],aFilDesc[oLbPosA:nAt,7],aFilDesc[oLbPosA:nAt,14]}
	oPossAgend:End()
	FS_ATUPOSS(aRetPossAge)
Else
	lRet := .f.
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³  FS_BLQVEI  ³ Autor ³ Andre Luis Almeida  ³ Data ³ 29/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Bloqueia Prospeccao do Veiculo                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_BLQVEI(cChassi)
Local lOk      := .f.
If !Empty(cChassi)
	DbSelectArea("VV1")
	DbSetOrder(2)
	If DbSeek(xFilial("VV1")+cChassi)
		lOk := .t.
	EndIf
	If lOk
		If VV1->VV1_BLQPRO == "1" // Veiculo ja Bloqueado
			MsgInfo(STR0162,STR0015) // Veiculo ja esta Bloqueado para Listas de Prospeccao! / Atencao
		Else
			If MsgYesNo(STR0159+CHR(13)+CHR(10)+CHR(13)+CHR(10)+VV1->VV1_CHASSI,STR0015) // Confirma o Bloqueio do Veiculo para Listas de Prospeccao? / Atencao
				DbSelectArea("VV1")
				RecLock("VV1",.f.)
					VV1->VV1_BLQPRO := "1" // 1=Sim
				MsUnLock()
				MsgInfo(STR0161,STR0015) // Veiculo Bloqueado com sucesso! / Atencao
			Else
				lOk := .f.
			EndIf
		EndIf
	EndIf
EndIf
Return(lOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³  FS_ALTVEI  ³ Autor ³ Andre Luis Almeida  ³ Data ³ 06/03/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Altera Dados do Veiculo                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ALTVEI(nOpc,cChassi)
If !Empty(cChassi) .and. ( nOpc == 3 .or. nOpc == 4 )
	DbSelectArea("VV1")
	DbSetOrder(2)
	If DbSeek(xFilial("VV1")+cChassi)
		FGX_ALTVEI("A") // 28/02/2012 - VEIXFUNA - FGX_ALTVEI 
		FS_CARREGA()
	EndIf
EndIf
Return()

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OM350HOR    |Autor  | Thiago		          | Data | 29/12/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Verifica horas de trilha                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM350HOR(cChassi)
Local nUltHor := 0
If INCLUI .or. ALTERA

	cValHor := Subs(GetNewPar("MV_VKILHOR","SN"),2,1)
	if cValHor == "N" .or. (cValHor == "P" .and. Empty(M->VSO_HORTRI))
		return .t.
	endif
	DbSelectArea("VV1")
	DbSetOrder(2)
	If DbSeek(xFilial("VV1")+cChassi)
		nUltHor := FG_ULTHOR(VV1->VV1_CHAINT)
		If nUltHor > M->VSO_HORTRI
			MsgStop( STR0179+" ("+Transform(M->VSO_HORTRI,"@E 99,999,999")+" ) "+STR0180+" ("+Transform(nUltHor,"@E 99,999,999")+" )!",STR0181)
			Return .f. 
		EndIf
		If M->VSO_HORTRI > M->VSO_KILOME
			MSGINFO(STR0181;
			+Chr(13)+STR0182;
			+Chr(13)+STR0179+" "+Transform(M->VSO_HORTRI,"@E 99,999,999");
			+Chr(13)+STR0183+" "+Transform(M->VSO_KILOME,"@E 99,999,999"))
			return .f.		
		Endif

	Else
		Return(.f.)
	EndIf
EndIf
Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OM350BLQ    |Autor  | Thiago		          | Data | 22/01/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Verifica cliente bloqueado.                                  |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM350BLQ()

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+M->VSO_PROVEI+M->VSO_LOJPRO)
if SA1->A1_MSBLQL == "1"
	MsgStop(STR0184+CHR(13)+ CHR(10)+SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+SA1->A1_NOME)
    Return(.f.)
Endif    
           
Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |FS_PASVEI   |Autor  | Thiago		          | Data | 20/01/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Hist. Passagens do veiculo.                                  |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_PASVEI(cChassi)
          
dbSelectArea("VV1")
dbSetOrder(2)
dbSeek(xFilial("VV1")+cChassi)
OFIOC330(VV1->VV1_CHAINT)

Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |FS_MUDSTA   |Autor  | Thiago		          | Data | 27/01/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Muda Status do Usuario.                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_MUDSTA(aFilDesc,nLinha)
Local aParamBox := {}           
Local aRet      := {} 
Local aStatus   := X3CBOXAVET("VZB_STACON","1")    
Local cStatus   := "" 
Local _VZB_STACON := (VZB->(FieldPos("VZB_STACON")) > 0)


if aFilDesc[nLinha,16] == STR0191 
	cStatus := "1"
Elseif aFilDesc[nLinha,16] == STR0192 
	cStatus := "2"
Elseif aFilDesc[nLinha,16] == STR0193 
	cStatus := "3" 
Elseif aFilDesc[nLinha,16] == STR0194 
	cStatus := "4" 
Endif
cObs    := aFilDesc[nLinha,17]

aAdd(aParamBox,{2,STR0195,cStatus,aStatus,60,"",.f.}) 
aAdd(aParamBox,{1,STR0196 ,cObs  ,"","",""   ,"",100,.F.}) // Obs Status Usuario

If !ParamBox(aParamBox,STR0197,@aRet,,,,,,,,.F.)
	Return(.f.)
Endif	

cStatU := X3CBOXDESC("VZB_STACON",aRet[1]) 

aFilDesc[nLinha,16] := cStatU
aFilDesc[nLinha,17] := aRet[2]        


if _VZB_STACON
	dbSelectArea("VZB")
	DbGoTo(aFilDesc[nLinha,12])
	Reclock("VZB",.f.)
	VZB->VZB_STACON := aRet[1]
	VZB->VZB_STAOBS := aRet[2]
	MsUnLock()
Endif

Return(.t.)
