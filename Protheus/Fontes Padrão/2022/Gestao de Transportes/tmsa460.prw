#INCLUDE "Tmsa460.ch"
#INCLUDE "PROTHEUS.CH"

#DEFINE _LIMCREDM 1,1
#DEFINE _LIMCRED  1,2
#DEFINE _SALDUPM  2,1
#DEFINE _SALDUP   2,2
#DEFINE _SALPEDLM 3,1
#DEFINE _SALPEDL  3,2
#DEFINE _MCOMPRAM 4,1
#DEFINE _MCOMPRA  4,2
#DEFINE _SALDOLCM 5,1
#DEFINE _SALDOLC  5,2
#DEFINE _MAIDUPLM 6,1
#DEFINE _MAIDUPL  6,2
#DEFINE _ITATUM   7,1
#DEFINE _ITATU    7,2
#DEFINE _PEDATUM  8,1
#DEFINE _PEDATU   8,2
#DEFINE _SALPEDM  9,1
#DEFINE _SALPED   9,2
#DEFINE _VALATRM  10,1
#DEFINE _VALATR   10,2
#DEFINE _LCFINM   11,1
#DEFINE _LCFIN    11,2
#DEFINE _SALFINM  12,1
#DEFINE _SALFIN   12,2
#DEFINE _STRASALDOS 12,2
#DEFINE  CSERIECOL 'COL'

Static lTmsa029 := FindFunction("TMSA029USE")
Static cCodNeg  := ""

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSA460  ³ Autor ³Patricia A. Salomao    ³ Data ³04.07.2002  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Solicitacao de Coleta                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA460()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA460(xAutoCab,xAutoItens,xAutoTpVei,xAutoCuba,nOpcAuto,cDDDSol,cTelSol,cCodSol)

Local aCores        := {}
Local aSetKey       := {}
Local lExec         := .T.
Local cFilMbrPE     := ""
local cFiltro       := ""
Local lPainel       := .F.

Private l460Auto    := xAutoCab <> Nil
Private aAutoCab    := {}  // Cabecalho Solic. Coleta (Rotina Automatica)
Private aAutoItens  := {}  // Itens Solic. Coleta (Rotina Automatica)
Private aAutoTpVei  := {}  // Tipo Veiculo (Rotina Automatica)
Private aAutoCuba   := {}  // Cubagem Mercadorias (Rotina Automatica)
Private nOpcxAuto   := 0
Default xAutoCab    := {}
Default xAutoItens  := {}
Default xAutoTpVei  := {}
Default xAutoCuba   := {}
Default nOpcAuto    := 3
Private cCadastro	  := STR0001 //"Solicitacao de Coleta"
Private aRotina	  := {}

Default cCodSol     := ""
Default cDDDSol     := ""
Default cTelSol     := ""

Static cMV_TMSRRE  := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
Static cMV_TMSINCO := SuperGetMv("MV_TMSINCO",.F.,"") // Controla Incompatibilidade de Produtos (ONU).
If Type("aPanAgeTMS") == "U"
	aPanAgeTMS := Array(6)
EndIf
lPainel := IsInCallStack("TMSAF76") .And. !Empty(aPanAgeTMS)
aRotina := MenuDef(!Empty(cCodSol)) 

If l460Auto
	lMsHelpAuto := .T.

	nOpcxAuto   := nOpcAuto

	aAutoCab    := xAutoCab
	aAutoItens  := xAutoItens
	aAutoTpVei  := xAutoTpVei
	aAutoCuba   := xAutoCuba

	If nOpcAuto == 6 //-- Liberacao
		lExec := SeekAuto("DT5",Aclone(aAutoCab))
	EndIf

	If lExec
		MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"DT5")
	EndIf
Else
	AAdd(aSetKey, { VK_F12 , { || Pergunte("TMA460",.T.) } } )
	aCores := Tmsa460Cor()

	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)

	If ExistBlock("TM460FBR") //-- PE - Permite ao usuario filtrar a mbrowse
		cFilMbrPE := ExecBlock("TM460FBR",.F.,.F.)
		If ValType(cFilMbrPE) == "C" .And. !Empty(cFilMbrPE)
			cFiltro += cFilMbrPE
		EndIf
	EndIf

	//-- Filtro do Browse por Solicitante. Ex: Utilizado na integração do TMK x TMS.
	If !Empty(cCodSol) 
		cFiltro := "DT5_CODSOL = '" + Padr( cCodSol, TamSx3("DT5_CODSOL")[1] ) + "'"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lPainel
		mBrowse(6,1,22,75,"DT5",,,,,,aCores,,,,,,,,cFiltro)
	Else
		If (at("(",aPanAgeTMS[6])>0)
			&(aPanAgeTMS[6])
		Else
			&(aPanAgeTMS[6] + "('" + aPanAgeTMS[1] + "'," + StrZero(aPanAgeTMS[2],10) + "," + StrZero(aPanAgeTMS[3],2) + ")")
		Endif
	EndIf

	//-- Finaliza Teclas de Atalhos
	TmsKeyOff(aSetKey)
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA460Mnt  ³ Autor ³ Patricia A. Salomao ³ Data ³04.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao da Solicitacao de Coleta                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA460Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA460/TMSA040                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA460Mnt( cAlias, nReg, nOpcx, cDDDSol, cTelSol, cNumAtd, cIteAtd, cCodSol )

Local aAreaAnt    := GetArea()
Local aAlter      := Nil
Local aObjects    := {}
Local aPosObj     := {}
Local aInfo       := {}
Local aSize       := {}
Local aButtons    := {}
Local aSx3Box     := {}
Local aVisual     := {}
Local aSomaButtons:= {}
Local aDelButtons := {}
Local cCampo      := ''
Local cStatus     := ''
Local cCdrOri     := ''
Local InclOld     := Inclui
Local lRet        := .F.
Local nCntFor     := 0
Local nOpca       := 0
Local lTMA460CAN  := ExistBlock('TMA460CAN')
Local lTM460ALT   := ExistBlock('TM460ALT')
Local aAltDUM     := Nil
Local aCpoAlt     := {}
Local cCposCFec   := ""
Local lTMSCFec    := TMSCFec()
Local oRemet 
Local lDT5Remet	  := DT5->(ColumnPos("DT5_CLIREM")) > 0	
Local nCont       := 0
Local aCampos	  := FwFormStruct(2,"DT5")
Local lMV_ITMSDMD := SuperGetMv("MV_ITMSDMD",.F.,.F.) //Parametro que indica se a Gestão de Demandas está ativa ou não.

Local aAreaDT4    := DT4->(GetArea())

Private cCadastro  := STR0001  // Solicitacao de Coleta
Private aHeader    := {}
Private aCols      := {}
Private aHeaderDTE := {}
Private aRatPesM3  := {}
Private aRecDTE    := {}
Private aHeaderDVT := {}
Private aColsDVT   := {}
Private aSetKey    := {}
Private aTela[0][0]
Private aGets[0]
Private o1Get
Private oDlg
Private lSugRemet    := .F.
Private lRepCont     := .F.
Private oEnchoice

If Type("aRotina") <> "A"  //-- Foi necessario mudar a validação do aRotina devido estar impactando na visualização dos campos na consulta de "Solicitação de Coleta" por dentro do TMSAF76
	Private aRotina := MenuDef()
EndIf

Default cCodSol 	 := "" //Informação proveniente de integração (rotina automática). Ex: Integração TMK x TMS
Default cDDDSol 	 := "" //Informação proveniente de integração (rotina automática). Ex: Integração TMK x TMS
Default cTelSol 	 := "" //Informação proveniente de integração (rotina automática). Ex: Integração TMK x TMS

//-- Limpa o filtro por conta do browse utilizando FWBrwRelation()
DT4->(DbClearFilter())
DT4->(DbCloseArea())

//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
If nOpcx <> 2 .And. nOpcx <> 3
	If !TMSAVerAge("3",,,,,,,,,DT5->DT5_FILORI,DT5->DT5_NUMSOL,,"2",.T.,.T.,,)
		Return .F.
	EndIf
EndIf
l460Auto := If (Type("l460Auto") == "U",.F.,l460Auto)
//-- Na INCLUSAO da Cotacao de Frete, depois que a Solicitacao de Coleta for Gerada Automaticamente
//-- a Tela de Solicitacao de Coleta devera' ser exibida em modo de Alteracao, por este motivo,
//-- a variavel Inclui deve ter seu conteudo alterado.
If nOpcx <> 3
	Inclui := .F.
	If IsInCallStack('TMSAF76')
		aRotina[nOpcx,4] := nOpcx
		nOpcx := Iif(nOpcx == 4,5,nOpcx)
	EndIf
ElseIf IsInCallStack('A540RetMer')
	aRotina[nOpcx][4] := nOpcx
EndIf

cCdrOri   := GetMv("MV_CDRORI")
If Empty(cCdrOri)
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help("",1,"TMSA05009")  //-- O Parametro MV_CDRORI esta vazio
	Return( .F. )
EndIf

If nOpcx == 5  .Or.  nOpcx == 4
	If nOpcx == 4 .And. !Empty(DT5->DT5_NUMCOT)
		aAlter  := {'DT5_SEQEND','DT5_OBS','DT5_DATPRV','DT5_HORPRV','DT5_CODNEG','DT5_SERVIC','DT5_SRVENT','DT5_DATENT','DT5_HORENT'}
	EndIf
	//Nao permitir modificacoes na solicitacao de coleta e nao chamar o ponto de entrada "TM460ALT" quando cancelamento ou
	//quando o Status da solicitacao estiver diferente de: "1-Em aberto" ;"2-Indicado para coleta" ou "3= Em transito".
	If nOpcx == 5 .Or. ( DT5->DT5_STATUS <> StrZero(1,Len(DT5->DT5_STATUS)) .And.; 
	 DT5->DT5_STATUS <> StrZero(2,Len(DT5->DT5_STATUS)) .And. DT5->DT5_STATUS <> StrZero(3,Len(DT5->DT5_STATUS)) )
		lTM460ALT := .F.
	EndIf
	If DT5->DT5_STATUS <> StrZero(1,Len(DT5->DT5_STATUS)) .And. Left(FunName(),7) <> "TMSA040" .And. !lTM460ALT .And. !IsInCallStack('TMSA146')
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help("",1,"TMSA46003") //Manutencao permitida somente nas Solicitacoes de Coleta com Status Em Aberto ...
		Return( .F. )
	EndIf
	//-- Verifica se a solicitacao esta relacionada com o agendamento. (Carga Fechada)
	If lTmsCFec .And. nOpcx == 4
		DF1->(DbSetOrder(3))
		If DF1->(MsSeek(xFilial("DF1")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help(' ',1, 'TMSA46020') // As solicitacoes de coletas geradas a partir do agendamento nao podem ser modificadas.
			Return( .F. )
		EndIf
	EndIf
	//Se a integração da Gestão de Demandas com o TMS estiver ativa, não permitir a Exclusão/Alteração da Coleta, caso esteja relacionada a uma Demanda.
	If lMV_ITMSDMD .And.;
		DT5->(ColumnPos("DT5_CODDMD")) > 0 .And. !Empty(DT5->DT5_CODDMD) .And.;
		DT5->(ColumnPos("DT5_SEQDMD")) > 0 .And. !Empty(DT5->DT5_SEQDMD) .And.;
		DT5->(ColumnPos("DT5_ORIDMD")) > 0 .And. !Empty(DT5->DT5_ORIDMD) .And. DT5->DT5_ORIDMD == '1' //1=Demanda; 2=TMS
		If nOpcx == 4 //Modificação
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			
			MsgAlert(STR0095) // Solicitações de coleta geradas a partir da Gestão de Demandas não podem ser modificadas.
			Return( .F. )
		ElseIf nOpcx == 5  .And. !IsInCallStack("TMExVgDmd") .And. !IsInCallStack('TMSA146Exc') //Cancelamento
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			
			MsgAlert(STR0096) // Solicitações de coleta geradas a partir da Gestão de Demandas não podem ser canceladas.
			Return( .F. )
		EndIf	   
	EndIf
	If nOpcx == 4 .And. lTM460ALT
		//Ponto de entrada para identificar os campos que poderao ser alterados na solicitacao de coleta em transito, retornara um array com duas dimensoes, sendo que na primeira servira para os campos do "DT5" e a segunda para os campos da tabela "DUM".	
		aCpoAlt := ExecBlock('TM460ALT',.F.,.F.)
		If ValType(aCpoAlt) != "A" .Or. Len(aCpoAlt) <> 2 
			aCpoAlt := {}
			aAlter  := Nil
			aAltDUM := Nil
		Else
			aAlter := aClone(aCpoAlt[1])
			aAltDUM:= aClone(aCpoAlt[2])
		EndIf
	EndIf
	DUD->(dbSetOrder(1))
	DUD->(MsSeek(xFilial('DUD')+DT5->(DT5_FILDOC+DT5_DOC+DT5_SERIE) ))
	DTQ->(dbSetOrder(2))
	DTQ->(MsSeek(xFilial('DTQ')+DUD->DUD_FILORI+DUD->DUD_VIAGEM))
	aSx3Box := RetSx3Box( Posicione('SX3', 2, 'DTQ_STATUS', 'X3CBox()' ),,, 1 )
	cStatus := AllTrim( aSx3Box[ Ascan( aSx3Box, { |x| x[ 2 ] == DTQ->DTQ_STATUS } ) , 3 ] )

	If !Empty(DUD->DUD_VIAGEM) .And. !lTM460ALT
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help("",1,"TMSA46002",,DUD->DUD_VIAGEM+"("+cStatus+")") // Esta Solicitacao de Coleta esta sendo utilizada pela Viagem
		Return( .F. )
	EndIf
EndIf

If !l460Auto
	AAdd(aSetKey , { VK_F4 ,  {||A460PesoM3()} } )
	AAdd(aButtons, {'BALANCA',{||A460PesoM3()}, STR0014, STR0014 }) //"Peso Cubado - <F4>"

	If nOpcx == 3
		AAdd(aSetKey ,{ VK_F6   ,{|| TmsPrvEnt()} } )
		AAdd(aButtons,{'CLOCK01' ,{|| TmsPrvEnt()} , STR0075 , STR0075 })  //'Previsao Entrega - <F6>'	
	EndIf
	If nOpcx == 2
		bSavKeyF5   := SetKey( VK_F5 , { ||  } )
		AAdd(aSetKey , { VK_F5,		 {||Tmsa460Oco() }} )
		AAdd(aButtons,	{'PEDIDO',	 {||Tmsa460Oco() }, STR0017, STR0017 }) //'Consulta Ocorrencias - <F5>'
		AAdd(aButtons,	{'DEVOLNF',  {||Tmsa460Oc1() }, STR0023, STR0023 }) //'Consulta Operacoes'
		AAdd(aButtons,	{'RELATORIO',{||Tmsa460Oc2() }, STR0024, STR0024 }) //'Consulta Operacoes/Ocorrencias'
		AAdd(aSetKey , { VK_F6,		 {||Tmsa460Viag()}} )
		AAdd(aButtons,	{'CARGA',	 {||Tmsa460Viag()}, STR0020, STR0020 }) //'Viagem - <F6>'
	Endif

	//-- Verifica se o Parametro MV_TMSCFEC (Carga Fechada) esta' habilitado
	If  FindFunction("ALIASINDIC") .And. AliasInDic('DVT') .And. lTMSCFec
		AAdd(aSetKey , { VK_F7    , {|| A460TipVei( nOpcx, M->DT5_NUMSOL, M->DT5_NUMCOT ) } }  )
		AAdd(aButtons, {'RPMNEW', {|| A460TipVei( nOpcx, M->DT5_NUMSOL, M->DT5_NUMCOT  )}, STR0030 , STR0030 }) //'Tipos de Veiculo - <F7>'
	EndIf

	//-- Notas Fiscais
	If nOpcx <> 3
		AAdd(aSetKey , { VK_F8    , {|| TMSA460Doc(M->DT5_FILORI,M->DT5_NUMSOL) } }  )
		AAdd(aButtons, {'DESTINOS', {|| TMSA460Doc(M->DT5_FILORI,M->DT5_NUMSOL)}, STR0032 , STR0032 }) //'Notas Fiscais - <F8>'
	EndIf

	//-- Ponto de entrada para incluir botoes na enchoicebar
	If	ExistBlock("TM460BUT")
		aSomaButtons:=ExecBlock("TM460BUT",.F.,.F.,{nOpcx})
		If	ValType(aSomaButtons) == "A"
			For nCntFor:=1 To Len(aSomaButtons)
				AAdd(aButtons,aSomaButtons[nCntFor])
			Next
		EndIf
	EndIf

	//-- Ponto de Entrada para desabilitar botoes na enchoice
	If (ExistBlock("TM460DSB"))
		aDelButtons := ExecBlock("TM460DSB",.F.,.F.,{aButtons,nOpcx})
		If ValType(aDelButtons) == "A"
			aButtons := aDelButtons
		EndIf
	EndIf

	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)
EndIf

//-- Define os campos utilizados somente na Carga Fechada.
cCposCFec := "DT5_CLIDES|DT5_LOJDES|DT5_NOMDES|DT5_SQEDES|DT5_ENDDES|DT5_BAIDES|DT5_MUNDES|DT5_ESTDES|DT5_CEPDES|"
cCposCFec += "DT5_DATENT|DT5_HORENT|DT5_CDRDCA|DT5_REGDCA|DT5_FILDES"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura variaveis da Enchoice                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M->DT5_CODSOL := Criavar("DT5_CODSOL",INCLUI)
M->DT5_SEQEND := Criavar("DT5_SEQEND",INCLUI)

For nCont := 1 to Len(aCampos:aFields)

	If nOpcx == 2 .And. DT5->DT5_STATUS <> '9' .And. (AllTrim(aCampos:aFields[nCont][1]) == "DT5_OBSCAN" .Or. AllTrim(aCampos:aFields[nCont][1]) == "DT5_DATCAN")
		Loop
	ElseIf (nOpcx <> 5 .And. nOpcx <> 2 .And. (AllTrim(aCampos:aFields[nCont][1]) == "DT5_OBSCAN" .Or. AllTrim(aCampos:aFields[nCont][1]) == "DT5_DATCAN")) .Or.;
		(nOpcx <> 2 .And. AllTrim(aCampos:aFields[nCont][1]) $ "DT5_FILDOC|DT5_DOC|DT5_SERIE")
		Loop
	//-- Não exibe os campos de Carga Fechada, se o parametro estiver desligado.
	ElseIf !TMSCFec() .And. Alltrim(aCampos:aFields[nCont][1]) $ cCposCFec
		Loop
	EndIf

	cCampo := aCampos:aFields[nCont][1]
	If	( GetSx3Cache(aCampos:aFields[nCont][1],"X3_CONTEXT") == "V"  .Or. Inclui )
	  	M->&(cCampo) := CriaVar(aCampos:aFields[nCont][1])
	Else
		M->&(cCampo) := DT5->(FieldGet(FieldPos(aCampos:aFields[nCont][1])))
	EndIf
	AAdd( aVisual,  aCampos:aFields[nCont][1] )
			
Next nCont

If nOpcx == 5
	aAlter := {'DT5_OBSCAN','DT5_DATCAN'}	// Campos que poderao ser Alterados
	M->DT5_DATCAN := dDataBase

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros utilizados pela funcao TMSFillGetDados()                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeekKey   := xFilial( "DUM" ) + M->(DT5_FILORI+DT5_NUMSOL)   //Chave de Seek para montar aCols
bSeekWhile := { ||  DUM->(DUM_FILIAL+DUM_FILORI+DUM_NUMSOL) } //Condicao While para montar o aCols

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader e aCols                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TMSFillGetDados( nOpcx, "DUM", , cSeekKey, bSeekWhile)

If nOpcx <> 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Array contendo o Peso Cubado dos Itens da Solicitacao de Coleta     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	a460VerPesM3()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Array contendo os Tipos de Veiculo informados na Solic. de Coleta   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If FindFunction("ALIASINDIC") .And. AliasInDic('DVT') .And. lTMSCFec   
		a460VerTpVei(nOpcx, M->DT5_FILORI, M->DT5_NUMSOL, M->DT5_NUMCOT, StrZero(1,Len(DVT->DVT_ORIGEM)))
	EndIf
EndIf

If !l460Auto

	Pergunte("TMA460",.F.) //-- MV_PAR02 -> Define Se Informa Divergencias
	aSize := MsAdvSize()

	//-- Dimensoes padroes
	aSize   := MsAdvSize()
	AAdd( aObjects, { 100, 065, .T., .T. } )
	AAdd( aObjects, { 100, 005, .T., .T. } )
	AAdd( aObjects, { 100, 025, .T., .T. } )
	AAdd( aObjects, { 100, 000, .T., .T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	aEval(aCols,{|x| IIf( Empty(x[GdFieldPos('DUM_ITEM')]), x[GdFieldPos('DUM_ITEM')] := StrZero(1,Len(DUM->DUM_ITEM)), .T.) })

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a Enchoice                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oEnchoice:= MsMGet():New("DT5", nReg, Iif( nOpcx==5, 4, nOpcx ) ,,,,aVisual,aPosObj[1],aAlter,3,,,,,,.T. )
		o1Get:=MSGetDados():New( aPosObj[3,1], aPosObj[3,2], aPosObj[3,3], aPosObj[3,4],nOpcx,'TMSA460LinOk','AllWaysTrue','+DUM_ITEM',If(nOpcx<>2.And.nOpcx<>5,.T.,Nil),aAltDUM)
		//-- Nao Deixar alterar a GetDados se a Solicit.Coleta foi gerada por uma Cotacao de Frete
		//If nOpcx <> 3 .And. !Empty(DT5->DT5_NUMCOT)
		//	o1Get:oBrowse:aAlter:= {}
		//EndIf
		
		//-- 'Sugerir solicitante como remetente'
		If lDT5Remet
			@ aPosObj[2,1],aPosObj[2,2] CHECKBOX oRemet VAR lSugRemet PROMPT STR0093 SIZE 100,010 ;
				ON CLICK( If(nOpcx == 3 .Or. nOpcx == 4,( TMSA460Sug(3),,),.T.) ) OF oDlg PIXEL
			oRemet:lReadOnly:= !( nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx == 7 )
		EndIf	

		//-- Somente habilita o evento para Carga Fechada.
		If lTMSCFec
			If Empty(cCodSol) 
				o1Get:oBrowse:bChange := { || Tmsa460Chg() }
			EndIf
		EndIf

	ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||nOpca:=1, If( Obrigatorio( aGets, aTela ) .And. o1Get:ChkObrigat(o1Get:oBrowse:nAt) .And. TMSA460TudOk(nOpcx),oDlg:End(),nOpca := 0)},{||oDlg:End()},, aButtons ), TMSA460Gat(nOpcx,cDDDSol,cTelSol,cNumAtd,cIteAtd,cCodSol))
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas pela rotina de inclusao automatica     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If EnchAuto(cAlias,aAutoCab,{|| Obrigatorio(aGets,aTela)},aRotina[nOpcx][4],aVisual) .And. MsGetDAuto(aAutoItens,"TMSA460LinOk",{|| TMSA460TudOk(nOpcx)},aAutoCab,aRotina[nOpcx][4])
		nOpcA := 1
	EndIf
EndIf

If	nOpca == 1 
	lRet := .T.
	If nOpcx <> 2 //-- Se nao for Visualizacao da Solicitacao de Coleta
		If !l460Auto
			Processa({|| TMSA460Grava(nOpcx)},cCadastro)
		Else
			If nOpcx == 3 
				If Len(aAutoTpVei) > 0
					A460TipVei( nOpcx, M->DT5_NUMSOL, M->DT5_NUMCOT )
				EndIf

				If Len(aAutoCuba) > 0
					A460PesoM3()
				EndIf
			EndIf
			TMSA460Grava(nOpcx,.T.)
		EndIf
	EndIf
Else
	If lTMA460CAN
		ExecBlock('TMA460CAN',.F.,.F.,{nOpcx})
	EndIf
	If __lSX8
		RollBackSX8()
	EndIf
EndIf

Inclui    := InclOld

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

If !l460Auto
	RestArea(aAreaAnt)
	//-- Finaliza Teclas de Atalhos
	TmsKeyOff(aSetKey)
EndIf

//-- Retorna a area por conta da limpeza de filtro
If IsInCallStack("TMSA170")
	RestArea(aAreaDT4)
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA460Val³ Autor ³Patricia A. Salomao    ³ Data ³05.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao dos Campos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA460Val()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA460                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA460Val(cCmpAuto)

Local cCampo    := Iif(cCmpAuto<>Nil,cCmpAuto,ReadVar())
Local cCodPro   := ''
Local lRet      := .T.
Local nA        := 0
Local nPeso     := 0
Local nItDTE    := 0
Local cCdrDes   := ""
Local aTmpEnt   := {}
Local dDataEnt  := Ctod("")
Local cHoraEnt  := ""
Local cDesc     := ""
Local cSeek     := ""
Local cSeekDTE  := ""
Local IncOld    := Inclui
Local nPosItem  := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DUM_ITEM' })
Local nPosCodPro:= Ascan(aHeader, {|x| AllTrim(x[2]) == 'DUM_CODPRO' })
Local lTMSCFec  := TMSCFec()
Local lTMSFilCol:= SuperGetMv("MV_TMSDCOL",,.F.)
Local ny
Local nPerCub   := 0
Local cCliDev   := ''
Local cLojDev   := ''
Local nOpcx     := 0
Local lServic	  := DT5->(ColumnPos("DT5_SERVIC")) > 0
Local aArea 	:= GetArea()
Local aItContrat := {}

Local aContrt   := {}
Local nSeek	  := 0

Local aAreaSA1 := SA1->(GetArea())

l460Auto := If (Type("l460Auto") == "U",.F.,l460Auto)

If cCampo == 'M->DT5_CODSOL'
	M->DT5_SEQEND := CriaVar('DT5_SEQEND')
	lRet          := TMSA460PrvCol() // Calcula a data/hora de previsao de coleta.
	If !Empty(M->DT5_CODSOL)
		TMSA460Prd()
	EndIf
ElseIf cCampo== 'M->DT5_SEQEND'
	If ExistCpo("DUL",M->DT5_CODSOL+AllTrim(M->DT5_SEQEND),3)
		M->DT5_CDRORI := DUL->DUL_CDRDES		
		M->DT5_REGORI := Posicione("DUY",1,xFilial("DUY")+M->DT5_CDRORI,"DUY_DESCRI")
	Else
		lRet := .F.
	EndIf
ElseIf cCampo== 'M->DT5_SQEDES'
	If ExistCpo("DUL",M->DT5_CLIDES+M->DT5_LOJDES+M->DT5_SQEDES,2)
		M->DT5_CDRDCA := DUL->DUL_CDRDES
	Else
		lRet := .F.
	EndIf
ElseIf cCampo == "M->DT5_SQEREM"
	If !ExistCpo("DUL",M->DT5_CLIREM+M->DT5_LOJREM+AllTrim(M->DT5_SQEREM),2)
		lRet := .F.
	EndIf
ElseIf cCampo== 'M->DUM_PESO'
	cCodPro := GdFieldGet('DUM_CODPRO',n)

	If Empty(cCodPro)
		Help("",1,"TMSA46011") // Produto deve estar preenchido...
		lRet := .F.
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso o campo B5_PERCUB esteja preenchido, calcular o percentual a partir   ³
		//³do peso digitado e armazenar o valor obtido no campo DUM_PESOM3.           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TMSA460Cli(@cCliDev,@cLojDev)
		nPerCub := TmsPerCub(cCodPro,cCliDev,cLojDev)
		If !Empty(nPerCub)
			GdFieldPut('DUM_PESOM3',M->DUM_PESO + (M->DUM_PESO * (nPerCub/100)), n)
		EndIf
	EndIf
ElseIf cCampo == 'M->DT5_CDRDCA'
	DUY->( DbSetOrder( 1 ) )
	DUY->( DbSeek( xFilial() + M->DT5_CDRDCA ) )
	M->DT5_FILDES := DUY->DUY_FILDES
ElseIf cCampo == 'M->DUM_CODPRO'
	cCodPro := GdFieldGet('DUM_CODPRO',n)
	TMSA460Cli(@cCliDev,@cLojDev)
	nPerCub := TmsPerCub(cCodPro,cCliDev,cLojDev)
	If !Empty(nPerCub)
		For nA := 1 To Len( aCols )
			nPeso := GDFieldGet('DUM_PESO',nA)
			GDFieldPut('DUM_PESOM3',nPeso + (nPeso * (nPerCub/100)),nA)
		Next
		If !l460Auto
			o1Get:oBrowse:Refresh()
		EndIf
	EndIf
ElseIf cCampo == 'M->DT5_CDRORI'

	If !lTMSFilCol .AND. M->DT5_FILORI != Posicione("DUY", 1, xFilial("DUY") + M->DT5_CDRORI, "DUY_FILDES")
		Help("",1,"TMSA46014") //"Filial origem esta diferente da filial informada para regiao origem"
		lRet := .F.
	EndIf

	If lRet
		// Nao permite que a regiao de origem seja igual a regiao de destino da carga.
		If	lTmscFec .And. M->DT5_CDRDCA == M->DT5_CDRORI
			Help("",1,"TMSA46012") // A regiao de origem nao pode ser igual a regiao de destino da carga.
			Return( .F. )
		EndIf
	EndIf
ElseIf cCampo == 'M->DT5_CLIDES' .Or. cCampo == 'M->DT5_LOJDES'
	
	If !Vazio()

		If !Empty(M->DT5_CLIDES) .And. !Empty(M->DT5_LOJDES)
			lRet := ExistCpo('SA1',M->DT5_CLIDES + M->DT5_LOJDES,1)
		EndIf

		If lRet
			SA1->(DbSetOrder(1))
			If	!SA1->(MsSeek(xFilial("SA1")+M->DT5_CLIDES+AllTrim(M->DT5_LOJDES)))
	
				M->DT5_CDRDCA :=  Space(Len(SA1->A1_CDRDES))
				M->DT5_REGDCA :=  Space(Len(DUY->DUY_DESCRI))
				M->DT5_FILDES :=  Space(Len(DUY->DUY_FILDES))
				
				Help(" ",1,"REGNOIS") //Nao existe registro relacionado a este codigo"
				Return( .F. )
			EndIf
			
			cCdrDes := Posicione("DUY", 1, xFilial("DUY") + SA1->A1_CDRDES, "DUY_DESCRI")
			M->DT5_CDRDCA :=  SA1->A1_CDRDES
			M->DT5_REGDCA :=  cCdrDes
			M->DT5_FILDES :=  DUY->DUY_FILDES	
		
			//-- Calcula tempo de entrega considerando o tempo de coleta ( Regiao Origem - Regiao Destinatario )
			dDataEnt := M->DT5_DATPRV
			cHoraEnt := M->DT5_HORPRV
	
			DUE->(dbSetOrder(1))
			If DUE->(MsSeek(xFilial("DUE") + M->DT5_CODSOL))
				SA1->(dbSetOrder(1))
				If SA1->(MsSeek(xFilial("SA1")+M->DT5_CLIDES+M->DT5_LOJDES))
					aTmpEnt := TmsTmpEntr( M->DT5_TIPTRA, DUE->DUE_CDRSOL, SA1->A1_CDRDES )
	
					If	! Empty( aTmpEnt )
						SomaDiaHor( @dDataEnt, @cHoraEnt, HoraToInt( StrTran(aTmpEnt[ 2 ],':',''), 3 ) )
	
					//-- Atualiza o prazo de entrega.
						M->DT5_DATENT := dDataEnt
						M->DT5_HORENT := StrTran(IntToHora(TmsHrToInt(cHoraEnt, 2), 2), ":", "")
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
ElseIf cCampo == 'M->DT5_SQEDES'

	//-- Verifica se a sequencia de endereco informada e valida!
	If !Empty( M->DT5_SQEDES )
		SA1->(DbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1")+M->DT5_CLIDES+M->DT5_LOJDES))
			DUL->(dbSetOrder(2))
			lRet := DUL->(MsSeek(xFilial("DUL")+SA1->A1_COD+SA1->A1_LOJA+M->DT5_SQEDES))
		Else
			lRet := .F.
		EndIf

		If !lRet
			Help(" ",1,"REGNOIS") //Nao existe registro relacionado a este codigo. 
		EndIf
	EndIf

ElseIf cCampo == 'M->DT5_NUMCOT'
	DT5->(dbSetOrder(5))
	If DT5->(MsSeek(cSeek:=xFilial('DT5')+M->DT5_FILORI+M->DT5_NUMCOT))
		Do While DT5->(!Eof()) .And. DT5->DT5_FILIAL+DT5->DT5_FILORI+DT5->DT5_NUMCOT == cSeek
			If !Empty(DT5->DT5_NUMSOL) .And. DT5->DT5_STATUS <> StrZero(9, Len(DT5->DT5_STATUS)) // Cancelada
				Help('',1,'TMSA46015',,DT5->DT5_NUMSOL,3,1) //-- Esta Cotacao ja esta sendo utilizada na Solicitacao de Coleta No. :
				Return( .F. )
			EndIf
			DT5->(dbSkip())
		EndDo
	EndIf

	DT4->(dbSetOrder(1))
	If DT4->(MsSeek(xFilial('DT4')+M->DT5_FILORI+M->DT5_NUMCOT)) .And. DT4->(ColumnPos('DT4_NUMSOL')) > 0 ;
		   .And. !Empty(DT4->DT4_NUMSOL)
		Help('',1,'TMSA46016',,DT4->DT4_NUMSOL,3,1) //-- Ja Foi informado no cadastro desta Cotacao, a Solicitacao de Coleta No. :
		Return( .F. )
	EndIf

	If DT4->DT4_STATUS <> StrZero(3, Len(DT4->DT4_STATUS))
		Help('',1,'TMSA46017') //-- Informe uma Cotacao de Frete 'Aprovada' ...
		Return( .F. )
	EndIf

	DVF->(dbSetOrder(1))
	If DVF->(MsSeek(cSeek:=xFilial('DVF')+M->DT5_FILORI+M->DT5_NUMCOT ))
		aCols     := {}
		aRatPesM3 := {} //-- Limpar o aCols de Cubagem dos |s
		n:=0
		While DVF->(DVF_FILIAL+DVF_FILORI+DVF_NUMCOT) == cSeek
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz a montagem de uma linha em branco no aCols.              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			n++
			AAdd(aCols,Array(Len(aHeader)+1))
			For ny := 1 to Len(aHeader)
				aCols[n][ny] := CriaVar(aHeader[nY][2])
			Next ny
			aCols[n][Len(aHeader)+1] := .F.

			cDesc := Posicione('SB1',1,xFilial('SB1')+DVF->DVF_CODPRO,'B1_DESC')
			GDFieldPut('DUM_ITEM'  ,  StrZero(n,Len(DUM->DUM_ITEM)), n)
			GdFieldPut('DUM_CODPRO', DVF->DVF_CODPRO, n)
			GdFieldPut('DUM_DESPRO', cDesc          , n)
			GdFieldPut('DUM_CODEMB', DVF->DVF_CODEMB, n)
			GdFieldPut('DUM_DESEMB', Tabela('MG',DVF->DVF_CODEMB), n )
			GdFieldPut('DUM_QTDVOL', DVF->DVF_QTDVOL, n)
			GdFieldPut('DUM_VALMER', DVF->DVF_VALMER, n)
			GdFieldPut('DUM_PESO'  , DVF->DVF_PESO  , n)
			GdFieldPut('DUM_PESOM3', DVF->DVF_PESOM3, n)
			DVF->(dbSkip())
		EndDo

		For nA := 1 To Len(aCols)
			//-- Peso Cubado do Item (informado na Cotacao de Frete)
			DTE->(dbSetOrder(2))
			If DTE->(MsSeek( cSeekDTE := xFilial("DTE")+M->DT5_FILORI+M->DT5_NUMCOT+aCols[nA][nPosCodPro] ) )
				AAdd(aRatPesM3,{aCols[nA][nPosItem],{}})
				AAdd(aRecDTE,{aCols[nA][nPosItem],{}})
				nItDTE++
				While DTE->(!Eof()) .And. DTE->DTE_FILIAL+DTE->DTE_FILORI+DTE->DTE_NUMCOT+DTE->DTE_CODPRO == cSeekDTE
					AAdd(aRatPesM3[nItDTE][2],{DTE->DTE_QTDVOL,DTE->DTE_ALTURA,DTE->DTE_LARGUR,DTE->DTE_COMPRI ,.F.})
					AAdd(aRecDTE[nItDTE][2],{DTE->(Recno())})
					DTE->(dbSkip())
				EndDo
			EndIf
		Next

		If !l460Auto
			o1Get:oBrowse:nAt := n
			o1Get:ForceRefresh()

			nOpcx := o1Get:oBrowse:nOpc
		Else
			nOpcx := nOpcxAuto
		EndIf

		n := 1
		//-- Se o parametro MV_TMSCFEC (Carga Fechada) estiver habilitado, carrega o aCols e o aHeader
		//-- do Botao de 'Tipos de Veiculo'
		If FindFunction("ALIASINDIC") .And. AliasInDic('DVT') .And. lTMSCFec
			//-- Alterar o conteudo da Inclui para .F., para que os campos virtuais sejam
			//-- inicializados corretamente
			Inclui := .F. 
			//-- Limpar o aCols de Tipos de Veiculo
			aColsDVT := {}
			a460VerTpVei(nOpcx, M->DT5_FILORI, Space(Len(DT5->DT5_NUMSOL)), M->DT5_NUMCOT, StrZero(1,Len(DVT->DVT_ORIGEM)))
			Inclui := IncOld
		EndIf

	EndIf
ElseIf	cCampo == 'M->DT5_CLIDEV' .Or. cCampo == 'M->DT5_LOJDEV'
		
	If !Vazio()

		If !Empty(M->DT5_CLIDEV) .And. !Empty(M->DT5_LOJDEV)
			lRet := ExistCpo('SA1',M->DT5_CLIDEV + M->DT5_LOJDEV,1)
		EndIf

		If lRet
			SA1->(DbSetOrder(1))
			If	!SA1->( MsSeek( xFilial('SA1') + M->DT5_CLIDEV + AllTrim(M->DT5_LOJDEV) ))
				Help(' ', 1, 'TMSA04025') //-- Cliente nao encontrado (SA1)
				Return( .F. )
			EndIf	
			//-- Nao permite selecionar cliente generico.
			If ! TmsVldCli( M->DT5_CLIDEV, M->DT5_LOJDEV )
				Return( .F. )
			EndIf
					
	        If !Empty( M->DT5_CLIDEV ) .And. !Empty( M->DT5_LOJDEV )
	            M->DT5_SERVIC := Space(Len(DT5->DT5_SERVIC))
	            DUE->(DbSetOrder(1))
	            If	DUE->(MsSeek( xFilial('DUE') + M->DT5_CODSOL)) 
	                If M->DT5_CLIDEV == DUE->DUE_CODCLI .And. M->DT5_LOJDEV == DUE->DUE_LOJCLI
	                    M->DT5_TIPFRE := "1"
	                Else
	                    M->DT5_TIPFRE := "2"
	                EndIf
	            EndIf
	        EndIf
	        
	        If !Empty(M->DT5_TIPFRE)
	            M->DT5_CODNEG := Space(Len(DT5->DT5_CODNEG))
	            aContrt := TMSContrat(M->DT5_CLIDEV,M->DT5_LOJDEV,,,.F.,M->DT5_TIPFRE,,,,,,,,,,,,,,,,)
	            If Empty(aContrt)
	                Help("",1,"TMSA46026") //-- O cliente está com a vigência do contrato vencida.
	                Return( .F. )
	            Else
	                M->DT5_NCONTR := aContrt[1,1]
	            EndIf
	        EndIf
		EndIf
	EndIf
ElseIf	cCampo == 'M->DT5_CLIREM' .Or. cCampo == 'M->DT5_LOJREM'

	If !Vazio()

		If !Empty(M->DT5_CLIREM) .And. !Empty(M->DT5_LOJREM)
			lRet := ExistCpo('SA1',M->DT5_CLIREM + M->DT5_LOJREM,1)
		EndIf

		If lRet
			SA1->(DbSetOrder(1))
			If	!SA1->( MsSeek( xFilial('SA1') + M->DT5_CLIREM + AllTrim(M->DT5_LOJREM) ))
				Help(' ', 1, 'TMSA04025') //-- Cliente nao encontrado (SA1)
				Return( .F. )
			EndIf	
					
			//-- Nao permite selecionar cliente generico.
			If ! TmsVldCli( M->DT5_CLIREM, M->DT5_LOJREM )
				Return( .F. )
			EndIf
		EndIf
	EndIf	
ElseIf	cCampo == 'M->DT5_CLICAL' .Or. cCampo == 'M->DT5_LOJCAL'
	If	!Empty( M->DT5_CLICAL )
		SA1->(DbSetOrder(1))
		If	SA1->( MsSeek( xFilial('SA1') + M->DT5_CLICAL + AllTrim(M->DT5_LOJCAL), .F. ) )
			M->DT5_NOMCAL := SA1->A1_NOME
		Else
			M->DT5_NOMCAL := Space(Len(SA1->A1_NOME))
			Help(' ', 1, 'TMSA04025') //-- Cliente nao encontrado (SA1)
			Return( .F. )
		EndIf
		//-- Nao permite selecionar cliente generico.
		If ! TmsVldCli( M->DT5_CLICAL, M->DT5_LOJCAL )
			Return( .F. )
		EndIf
	EndIf		
ElseIf cCampo == "M->DT5_CODNEG"
	If lRet
		M->DT5_SERVIC := Space(TamSx3("DT5_SERVIC")[1])
		M->DT5_SRVENT := Space(TamSx3("DT5_SRVENT")[1])
	EndIf	
	If Empty(M->DT5_CODNEG)
		Help("",1,"TMSA46025") //-- Não é permitido que o código da negociação fique em branco.
		lRet := .F.
	EndIf
	If !Empty(M->DT5_SERVIC) .And. !Empty(M->DT5_TIPFRE) .And. !Empty(M->DT5_CODNEG)
		aContrt := TMSContrat(M->DT5_CLIDEV,M->DT5_LOJDEV,,IIf(lServic,M->DT5_SERVIC,""),.F.,M->DT5_TIPFRE,,,,,,,,,,,,,,,,M->DT5_CODNEG)
		If Empty(aContrt)
			Help("",1,"TMSA46026") //-- O cliente está com a vigência do contrato vencida.
			lRet := .F.			 
		EndIf
	EndIf	
	
	If !Empty(M->DT5_SERVIC) .And. !Empty(M->DT5_TIPFRE) .And. !Empty(M->DT5_CODNEG)
        aContrt := TMSContrat(M->DT5_CLIDEV,M->DT5_LOJDEV,,M->DT5_SERVIC,.F.,M->DT5_TIPFRE,,,,,,,,,,,,,,,,M->DT5_CODNEG)
        If Empty(aContrt)
            Help("",1,"TMSA46026") //-- O cliente está com a vigência do contrato vencida.
            Return( .F. )
        Else
            M->DT5_NCONTR := aContrt[1,1]
        EndIf
	Elseif !Empty(M->DT5_CODNEG)
		DDC->(DbSetOrder(2))//DDC_FILIAL+DDC_NCONTR+DDC_CODNEG 
		If !DDC->( MsSeek( xFilial('DDC') + M->DT5_NCONTR + M->DT5_CODNEG) )
			Help("",1,"TMSA050B0") //Verifique negociação no contrato do cliente.
			Return( .F. )
		Endif
	Endif	
ElseIf cCampo == "M->DT5_SERVIC"
	If Empty(M->DT5_CODNEG) .And. Empty(M->DT5_SERVIC) 
		Help("",1,"TMSA46027") //-- Não é permitido que o serviço fique em branco.
		lRet := .F.
	EndIf
    If Empty (M->DT5_NCONTR)
        If !Empty(M->DT5_SERVIC) .And. !Empty(M->DT5_TIPFRE) .And. !Empty(M->DT5_CODNEG)
            aContrt := TMSContrat(M->DT5_CLIDEV,M->DT5_LOJDEV,,M->DT5_SERVIC,.F.,M->DT5_TIPFRE,,,,,,,,,,,,,,,,M->DT5_CODNEG)
            If Empty(aContrt)
                Help("",1,"TMSA46026") //-- O cliente está com a vigência do contrato vencida.
                Return( .F. )
            Else
                M->DT5_NCONTR := aContrt[1,1]
            EndIf
        EndIf
    Else
        TMSPesqServ('DT5', M->DT5_CLIDEV, M->DT5_LOJDEV, "1", M->DT5_TIPTRA, aContrt, .F.,;
                    M->DT5_TIPFRE,.T.,,,,,,,M->DT5_CDRORI, M->DT5_CDRDCA,,,,,,,,M->DT5_CODNEG)
        
        nSeek := Ascan(aContrt, { |x| x[3] == &(ReadVar()) })
        If nSeek == 0 .And. !Empty(M->DT5_SERVIC)
            Help("",1,"TMSA05040") // Servico Invalido ...
            Return( .F. )
        Endif						
    Endif		
ElseIf cCampo == "M->DT5_TIPFRE"
    If Empty (M->DT5_NCONTR) 	
        If !Empty(M->DT5_SERVIC) .And. !Empty(M->DT5_TIPFRE) .And. !Empty(M->DT5_CODNEG)
            aContrt := TMSContrat(M->DT5_CLIDEV,M->DT5_LOJDEV,,M->DT5_SERVIC,.F.,M->DT5_TIPFRE,,,,,,,,,,,,,,,,M->DT5_CODNEG)
            If Empty(aContrt)
                Help("",1,"TMSA46026") //-- O cliente está com a vigência do contrato vencida.
                Return( .F. )
            Else
                M->DT5_NCONTR := aContrt[1,1]
            EndIf
        EndIf
    Endif	
ElseIf cCampo == "M->DT5_SRVENT"
	If !Empty(M->DT5_SRVENT)
		//-- Valida o codigo do servico digitado.
		dbSelectArea("DC5")
		DC5->( DbSetOrder( 1 ) )
		If DC5->( ! MsSeek( xFilial('DC5') + M->DT5_SRVENT, .F. ) )
			Help(' ', 1, 'TMSA04013', , STR0011 + M->DT5_SRVENT , 4, 1 )	//-- Codigo do servico nao encontrado (DC5).  //'Servico: '
			lRet := .F.
		EndIf
		If !Empty(M->DT5_SRVENT)
			dbSelectArea("DC5")
			DC5->(DbSetOrder(1))
			If DC5->(DbSeek(xFilial('DC5')+M->DT5_SRVENT)) 
				If DC5->DC5_SERTMS <> StrZero(3,Len(DC5->DC5_SERTMS)) .Or. DC5->DC5_CATSER <> '1'
					Help("",1,"TMSA46029") //-- O Serviço selecionado não é de entrega. 
					lRet := .F.
				Endif	
			EndIf
		EndIf	
		If lRet 
			TMSPesqServ('DT5', M->DT5_CLIDEV, M->DT5_LOJDEV, StrZero(3,Len(DC5->DC5_SERTMS)),;
				M->DT5_TIPTRA, @aItContrat, .F., M->DT5_TIPFRE,,,,,,,,;
				M->DT5_CDRORI,M->DT5_CDRDES,,,,,,,, M->DT5_CODNEG, cCampo )
		
			nSeek := Ascan(aItContrat, { |x| x[3] == &(ReadVar()) })
			If nSeek == 0
				Help('',1,"TMSA05040") // Servico Invalido ...
				Return( .F. )			
			EndIf
		EndIf			
	EndIf
EndIf

RestArea(aAreaSA1)

RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA460Lin³ Autor ³Patricia A. Salomao    ³ Data ³05.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da Linha Digitada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA460LinOk()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA460                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA460LinOk()

Local aCampos := {}
Local cCodPro := ''
Local lPrdDiv := GetMV('MV_PRDDIV',,.F.)	//-- Verifica se permitira a inclusao de um ou mais produtos
Local lRet    := .T.
Local nCntFor := 0
Local aProds  := {}
Local aVetRRE   := {}
Local cCliRRE   := ""
Local cLojRRE   := ""
Local aRetRRE   := {}
Local nI        := 0
Local aDiverg   := {}
Local nPos      := 0
Local aVetCli   := {}

l460Auto := If (Type("l460Auto") == "U",.F.,l460Auto)
aCampos := { 'DUM_CODPRO' }
//-- Analisa se ha itens duplicados na GetDados
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	lRet := GDCheckKey( aCampos, 4, , , !l460Auto )
EndIf
//-- So podera haver um codigo de produto na getdados
If	lRet .And. !lPrdDiv
	For nCntFor := 1 To Len(aCols)

		//-- Ignora Registros Deletados
		If	! GdDeleted(nCntFor)

			//-- So podera haver um codigo de produto na getdados
			If !lPrdDiv
				//-- Primeiro codigo de produto nao deletado na getdados
				If	Empty(cCodPro)
					cCodPro := GdFieldGet('DUM_CODPRO',nCntFor)
				EndIf
				If	GdFieldGet('DUM_CODPRO',nCntFor)!=cCodPro
					Help('',1,'TMSA46013') //"O parametro MV_PRDDIV esta configurado para informar 1 produto; Sendo assim,sera permitido informar sempre o MESMO PRODUTO.
					lRet:=.F.
					Exit
				EndIf
			EndIf
		EndIf
	Next
EndIf

//-- Controle de Divergencia De Produtos / RRE
If	lRet .And. lTmsa029 .And. Tmsa029Use("TMSA460")
 
	For nCntFor := 1 To Len(aCols)

		//-- Ignora Registros Deletados
		If	! GdDeleted(nCntFor)
			
			If !l460Auto

				aAdd(aProds,GdFieldGet('DUM_CODPRO',nCntFor))

				If "4" $ cMV_TMSRRE 

					cCliRRE:= Iif(Empty(M->DT5_CLIDEV),DUE->DUE_CODCLI,M->DT5_CLIDEV)
					cLojRRE:= Iif(Empty(M->DT5_LOJDEV),DUE->DUE_LOJCLI,M->DT5_LOJDEV)

					If !Empty(cCliRRE) .And. !Empty(cLojRRE)
						nPos:= aScan(aVetRRE, {|x| x[1] + x[2] + x[3] == cCliRRE + cLojRRE+ GdFieldGet('DUM_CODPRO',nCntFor) })
						If nPos > 0
							aVetRRE[nPos][4]+= GdFieldGet('DUM_QTDVOL',nCntFor)
							aVetRRE[nPos][5]+= GdFieldGet('DUM_PESO',nCntFor)
							aVetRRE[nPos][6]+= GdFieldGet('DUM_PESOM3',nCntFor)
							aVetRRE[nPos][7]+= GdFieldGet('DUM_VALMER',nCntFor)
						Else
							Aadd(aVetRRE,{cCliRRE, cLojRRE, GdFieldGet('DUM_CODPRO',nCntFor), GdFieldGet('DUM_QTDVOL',nCntFor), GdFieldGet('DUM_PESO',nCntFor), GdFieldGet('DUM_PESOM3',nCntFor), GdFieldGet('DUM_VALMER',nCntFor),'', 0 })
						EndIf
						//--- Totalizador do Valor da Mercadoria por Cliente
						nPos:= aScan(aVetCli, {|x| x[1] + x[2] == cCliRRE + cLojRRE })
						If nPos > 0
							aVetCli[nPos][3]+= GdFieldGet('DUM_VALMER',nCntFor)
						Else
							Aadd(aVetCli,{cCliRRE, cLojRRE, GdFieldGet('DUM_VALMER',nCntFor)})
						EndIf
					EndIf

				EndIf
			EndIf
		EndIf
	Next
EndIf

If lRet .And. (Len(aProds) > 1 .Or. Len(aVetRRE) > 0)
	If ValType(MV_PAR02) == "N" .And. MV_PAR02 == 1

		If Len(aProds) > 1 .And. ("A" $ cMV_TMSINCO .Or. "D" $ cMV_TMSINCO)
			aProds  := TmsRtDvP(aProds) //-- Calcula Divergencias
			For nI:= 1 To Len(aProds)
				aAdd(aDiverg,{aProds[nI][1],'CR',aProds[nI][2]})
			Next nI
		EndIf

		If Len(aVetRRE) > 0
			For nI:= 1 To Len(aVetCli)
				aEval(aVetRRE, {|x| Iif( x[1]+x[2] == aVetCli[nI][1] + aVetCli[nI][2], x[9]+= aVetCli[nI][3], .T.) })  //Atualiza valor total por Cliente
			Next nI

			aRetRRE:= TmsRetRRE(aVetRRE,,,"TMSA460",)
			For nI:= 1 To Len(aRetRRE)
				aAdd(aDiverg,{aRetRRE[nI][4],'RR',aRetRRE[nI][6]})
			Next nI
		EndIf

		If Len(aDiverg) > 0
			SaveInter()
			//--lRet := TmsListDiv(aDiverg) //-- Monta Dialog Com RRE e Divergencias de Produtos
			TmsListDiv(aDiverg) //-- Monta Dialog Com RRE e Divergencias de Produtos
			RestInter()
		EndIf
	EndIf

EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA460Tud³ Autor ³Patricia A. Salomao    ³ Data ³05.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao Geral da Tela                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA460TudOk(ExpN1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA460                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA460TudOk(nOpcx)

Local lRet 			:= .T.
Local lTM460TudOK 	:= ExistBlock('TM460TUDOK')
Local nAdiDoc 		:= Nil
Local cTipOpe 		:= ""

l460Auto	:= If (Type("l460Auto") == "U",.F.,l460Auto)
lRet		:= IIf(nOpcx==3 .Or. nOpcx == 4, TMSA460LinOk(), .T.)

If lRet .And. nOpcx == 5
	If !ValDatHor( M->DT5_DATCAN, Nil, M->DT5_DATSOL, Nil, .F., STR0012, STR0013,, l460Auto )  //-- 'do Cancelamento' 'da Solicitacao'
		lRet := .F.
	EndIf
EndIf

If lRet .And. !Empty(M->DT5_DATPRV) .And. !Empty(M->DT5_DATENT) .And. (M->DT5_DATPRV > M->DT5_DATENT)
	Help("",1,"TMSA46031") //-- Data de previsão de Entrega deve ser maior que a previsão de Coleta.                   
	lRet := .F.
EndIf

If lRet .And. M->DT5_LOCCOL == '2' .And. (Empty(M->DT5_CLIREM) .Or. Empty(M->DT5_LOJREM))
	Help("",1,"TMSA46029") //-- Para Coletas No Remetente (DT5_LOCCOL = 2) Informar o Código Do Cliente Remetente.
	lRet := .F.
EndIf	

If lRet .And. (nOpcx == 3 .Or. nOpcx == 4) .And. !Empty(M->DT5_CLIDEV)
	//-- Verifica se o Tipo de Frete foi informado
	If Empty(M->DT5_TIPFRE)
		Help("",1,"TMSA46028") //-- Não é permitido que o tipo de frete fique em branco.
		lRet := .F.
	EndIf
	//-- Verifica se o servico foi informado
	If Empty(M->DT5_SERVIC) .And. !Empty(M->DT5_CODNEG) 
		//Help("",1,"TMSA46027") //-- Não é permitido que o serviço fique em branco.
		Help( ,, 'HELP',, "Não é permitido que o serviço fique em branco, pois foi informado um Código de Negociação." , 1, 0)
		lRet := .F.
	EndIf
		
	//-- --------------------------------------------------------------------------------
	//-- Na solicitação de coleta, se o servico informado (DT5_SERVIC) estiver configurado
	//-- no Contrato do Cliente como Valoriza Coleta (Alias_VALCOL) igual a ‘1-Sim’ e com 
	//-- o Tipo de Operação (Alias_TIPOPE) igual a 1= Somente Coleta, deverá ser obrigatório
	//-- a informação do Codigo do Cliente Remetente para que a valorização seja efetuada 
	//-- com sucesso.
	//-- --------------------------------------------------------------------------------
	
    nAdiDoc := Nil
    If TmsSobServ('VALCOL',,.T.,M->DT5_NCONTR,M->DT5_CODNEG,M->DT5_SERVIC,"0",@nAdiDoc)  $ '1/2' //-- 1 = Val. Todas ; 2 = Somente Coletadas
    
        cTipOpe := TmsSobServ('TIPOPE',,.T.,M->DT5_NCONTR,M->DT5_CODNEG,M->DT5_SERVIC,"0",@nAdiDoc)
        
        If cTipOpe $ '1/2' .And. (Empty(M->DT5_CLIREM) .Or. Empty(M->DT5_LOJREM))
                Help( " ", 1, "OBRIGAT2", , RetTitle( "DT5_CLIREM" ), 4, 1 )
                lRet := .F.
        ElseIf cTipOpe == '2' .And. (Empty(M->DT5_CLIDES) .Or. Empty(M->DT5_LOJDES))
                Help( " ", 1, "OBRIGAT2", , RetTitle( "DT5_CLIDES" ), 4, 1 )
                lRet := .F.					
        EndIf			
    EndIf	
EndIf

//-- Executa Ponto de Entrada no Final da TudoOK
If lRet .And. lTM460TudOK
	lRet := ExecBlock('TM460TUDOK',.F.,.F.,{nOpcx})
	If ValType(lRet) # "L"
		lRet :=.F.
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA460Gra³ Autor ³Patricia A. Salomao    ³ Data ³05.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava a Solicitacao de Coleta                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA460Gra(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±³          ³ExpL1 - Verifica se a funcao esta sendo chamada por Rotina  ³±±
±±³          ³        Automatica                                          ³±±
±±³          ³ExpL2 - Valida se a Solic.de Coleta esta sendo gerada a par-³±±
±±³          ³        tir de uma Cotacao de Frete                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA460/TMSA040                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA460Grava(nOpcx, lAutomatic, lCotacao, cSolicit, cCotacao, lImprime )

Local aRota      := {}
Local nQtdVol    := 0
Local nQtdUni	 := 0
Local nPeso      := 0
Local nPesoM3    := 0
Local nValMer    := 0
Local nMetro3    := 0
Local nCntFor    := 0
Local nX         := 0
Local nPosCampo  := 0
Local cNumSol    := ''
Local lGerNum    := .F.
Local lViagem    := .F. 
Local lTMA460GRV := ExistBlock('TMA460GRV')
Local lRTMSR02   := ExistBlock("RTMSR02")
Local lTMSR580   := FindFunction("TMSR580")
Local cCdrDes    := ''
Local lTMSA040   := Left(FunName(),7) == "TMSA040"
Local cAliasQry  := ''
Local cQuery     := ''
Local nValTot    := 0
Local lCredito   := .T.
Local lCliDev    := DT5->(ColumnPos("DT5_CLIDEV")) > 0 .And. !Empty(M->DT5_CLIDEV) .And. !Empty(M->DT5_LOJDEV)
Local aAreaDT6
Local nCnt       :=0
Local cRota      :=''
Local aAreaDA8   :=''
Local aProds     := {} // Vetor Para Controle De Divergencia De Produtos
Local cProd      := ''
Local cMotBlq    := ""
Local aVetRRE   := {}
Local cCliRRE   := ""
Local cLojRRE   := ""
Local aRetRRE   := {}
Local nI        := 0
Local nPos      := 0
Local lBloqDT5  := .F.
Local aVetCli   := {}
Local cMV_TMSINCO:= SuperGetMv("MV_TMSINCO",.F.,"")
Local lServic	:= DT5->(ColumnPos("DT5_SERVIC")) > 0 //Coleta
Local lSrvEnt   := DT5->(ColumnPos("DT5_SRVENT")) > 0 //Entrega
Local aVetDF0   := {}
Local aVetDF1   := {}
Local aVetDF2   := {}
Local nPosDF2   := 0
Local cCodEmb   := ""
Local aContrat  := {}
Local lGerAge   := .F.
Local cSrvCol   := "" //Coleta
Local cServic	:= "" //Entrega
Local lDumM3    := DUM->(ColumnPos("DUM_METRO3")) > 0
Local cTipNFC   := "0"
Local cDocTms   := ""
Local lRet		:= .T.

Default lAutomatic := .F.
Default lCotacao   := .F.
Default cSolicit   := Nil
Default cCotacao   := Nil

//-- Verifica se imprimi a coleta apos a inclusao.
If !IsInCallStack("TMSF76VIA")
	If lImprime == Nil
		Pergunte("TMA460",.F.)
		lImprime := (mv_par01 == 1)
	EndIf
EndIf

aRatPesM3  :=  IIf(Type("aRatPesM3")  =="U", {}, aRatPesM3)
aRecDTE    :=  IIf(Type("aRecDTE")    =="U", {}, aRecDTE)
aHeaderDTE :=  IIf(Type("aHeaderDTE") =="U", {}, aHeaderDTE)
aColsDVT   :=  IIf(Type("aColsDVT")   =="U", {}, aColsDVT)

//-- Determina a rota prevista de coleta   
If !Empty(M->DT5_SEQEND)
	DUL->(dbSetOrder(3))
	If DUL->(DbSeek(xFilial("DUL")+M->DT5_CODSOL+M->DT5_SEQEND))
		aRota := TMSRetRota(,, DUL->DUL_CEP)
	EndIf
EndIf

If Empty(aRota)
	DUE->(dbSetOrder(1))
	If DUE->(MsSeek(xFilial("DUE")+M->DT5_CODSOL))
		If !Empty(DUE->DUE_CODCLI) .And. !Empty(DUE->DUE_LOJCLI)
			aRota := TMSRetRota(DUE->DUE_CODCLI, DUE->DUE_LOJCLI)
		Else
			aRota := TMSRetRota(,, DUE->DUE_CEP)
		EndIf
	EndIf
EndIf

DbSelectArea("DT5")
Begin Transaction 
	If nOpcx == 5 // Cancelar
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza Status da Solicitacao de Coleta                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DT5->( DbSetOrder( 1 ) )
		If DT5->( MsSeek( xFilial('DT5') + M->DT5_FILORI + M->DT5_NUMSOL, .F. ) )
			RecLock('DT5',.F.)
			DT5->DT5_STATUS := StrZero(9,Len(DT5->DT5_STATUS)) // Cancelada
			DT5->DT5_DATCAN := M->DT5_DATCAN
			//-- Se o Cancelamento da Solicitacao de coleta, NAO estiver sendo chamado automaticamente 
			//-- pela Cotacao de Frete
			If !lCotacao
				DT5->DT5_NUMCOT := CriaVar('DT5_NUMCOT',.F.)
			EndIf

			DT5->(MsUnLock())
			MSMM(DT5_CODOBC,,,M->DT5_OBSCAN,1,,,"DT5","DT5_CODOBC")

			DF1->(DbSetOrder(3))
			If DF1->(MsSeek(xFilial("DF1")+DT5->DT5_FILORI+DT5->DT5_NUMSOL+"COL"))
				RecLock('DF1',.F.)
				DF1->DF1_STACOL := StrZero(1,Len(DF1->DF1_STACOL))//Altera o status do grid do agendamento para "A confirmar" 
				DF1->DF1_STAENT := StrZero(1,Len(DF1->DF1_STAENT))//Altera o status do grid do agendamento para "A confirmar" 
				DF1->DF1_FILDOC := Space(Len(DF1->DF1_FILDOC))
				DF1->DF1_DOC := Space(Len(DF1->DF1_DOC))
				DF1->DF1_SERIE := Space(Len(DF1->DF1_SERIE))
				DF1->(MsUnLock())

				DF0->(DbSetOrder(1))
				If DF0->(MsSeek(xFilial("DF0")+DF1->DF1_NUMAGE))
					RecLock('DF0',.F.)
					DF0->DF0_STATUS := StrZero(1,Len(DF0->DF0_STATUS))//Altera o status do cabeçalho do agendamento para "A confirmar"
					DF0->(MsUnLock())
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta Movimento de Viagem                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DUD->(DbSetOrder(1))
			If DUD->(MsSeek(xFilial('DUD')+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
				RecLock('DUD',.F.)
				//--So podemos excluir o DUD se nao estiver relacionado a uma viagem
				If Empty(DUD->DUD_VIAGEM)
					DUD->(dbDelete())
				Else
					//--Se estiver relacionado a uma viagem, mudamos apenas o status
					DUD->DUD_STATUS := StrZero(9,Len(DUD->DUD_STATUS)) //-- Cancelado
				EndIf
				DUD->(MsUnLock())
			EndIf

			//-- Se o Cancelamento da Solicitacao de coleta, NAO estiver sendo chamado automaticamente 
			//-- pela Cotacao de Frete:
			If !Empty(M->DT5_NUMCOT) .And. !lCotacao
				//-- Apaga o no. da Solicitacao de Coleta na Cotacao de Frete 
				DT4->(dbSetOrder(1))
				If DT4->(MsSeek(xFilial('DT4')+M->DT5_FILORI+M->DT5_NUMCOT)) .And. DT4->(ColumnPos("DT4_NUMSOL")) > 0
					RecLock('DT4',.F.)
					DT4->DT4_NUMSOL := CriaVar('DT4_NUMSOL', .F.)
					DT4->(MsUnLock())
				EndIf

				//-- Se a Solicitacao de Coleta tiver Cotacao de Frete informada, limpar o campo
				//-- 'No.Solicitacao Coleta' dos registros do DVT (Tipos de Veiculo)
				If Len(aColsDVT) > 0
					DVT->(dbSetOrder(1))
					Do While DVT->(MsSeek(cSeek:=xFilial('DVT')+M->DT5_FILORI+M->DT5_NUMSOL+M->DT5_NUMCOT+StrZero(1,Len(DVT->DVT_ORIGEM))))
						RecLock("DVT", .F.)
						DVT->DVT_NUMSOL := CriaVar('DVT_NUMSOL', .F.)
						DVT->(MsUnLock())
					EndDo
				EndIf
			EndIf

			//-------------------------------------------------------------------------------------------------
			//-- Deleta Referencias De Bloqueio Da Tabela DDU Caso Existam
			//-------------------------------------------------------------------------------------------------
			If lTmsa029  .And. Tmsa029Use("TMSA460")

				// Caso Existam Bloqueios, Limpa Referencia
				Tmsa029Blq( 5  ,;				// 01 - nOpc
							'TMSA460',;		// 02 - Rotina
							Nil,;				// 03 - Tipo Bloq (Nil Apaga Todos Codigos de Bloqueio da Viagem
							M->DT5_FILORI,;	// 04 - Filial Origem
							'DT5',;			// 05 - Tabela Referencial
							'1',;				// 06 - Indice Da Tabela
							xFilial("DT5") + M->DT5_FILORI + M->DT5_NUMSOL,;	// 07 - Chave Indexação
							"",;				// 08 - Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
							"",; 				// 09 - Detalhes Adicionais a Respeito Do Bloqueio
							nOpcx)				// 10 - Opcao Rotina

			EndIf
		EndIf
	ElseIf nOpcx == 3 .Or. nOpcx == 4	// Incluir ou Alterar

		If	nOpcx == 3
			cNumSol := TmsVldChav('DT5','DT5_NUMSOL',,M->DT5_NUMSOL,,3)
			If cNumSol != M->DT5_NUMSOL
				lGerNum := .T. 
				M->DT5_NUMSOL := cNumSol
			EndIf
		EndIf

		DT5->( DbSetOrder( 1 ) )
		If	DT5->( MsSeek( xFilial('DT5') + M->DT5_FILORI + M->DT5_NUMSOL, .F. ) )
			RecLock('DT5',.F.)
		Else
			RecLock('DT5',.T.)
		EndIf
		For nCntFor := 1 To FCount()
			If AllTrim( FieldName( nCntFor ) ) $ 'DT5_FILDOC|DT5_DOC|DT5_SERIE|DT5_STATUS'
				Loop
			ElseIf FieldName( nCntFor ) == 'DT5_FILIAL'
				FieldPut( nCntFor, xFilial('DT5') )
			Else
				If TYPE("M->"+FieldName(nCntFor)) != "U"
					FieldPut(nCntFor,M->&(FieldName(nCntFor)))
				EndIf
			EndIf
		Next
		If nOpcx == 3
			DT5->DT5_FILDOC := cFilAnt
			DT5->DT5_DOC    := M->DT5_NUMSOL 
			DT5->DT5_SERIE  := CSERIECOL
			DT5->DT5_STATUS := StrZero(1,Len(DT5->DT5_STATUS))  // Em Aberto
		EndIf
		If !Empty(aRota)
			aAreaDA8:=DA8->(GetArea())
			For nCnt:= 1 To Len(aRota)
				cRota:= aRota[nCnt,2]
				DA8->(dbSetOrder(1))
				DA8->(dbSeek(xFilial('DA8')+cRota))
				If DA8->DA8_SERTMS == StrZero(1, Len(DA8->DA8_SERTMS))
					DT5->DT5_ROTPRE:= cRota
					Exit
				EndIf
			Next nCnt
			Restarea(aAreaDA8)
		EndIf
		MSMM(DT5->DT5_CODOBS,,,M->DT5_OBS,1,,,"DT5","DT5_CODOBS")
		MsUnLock()
		If __lSX8
			ConfirmSX8()
		EndIf
		EvalTrigger()

		aProds := {} // Vetor Para Controle De Divergencia De Produtos
		aVetRRE:= {}
		aVetCli:= {}
		DUM->(dbSetOrder(1))
		For nX := 1 To Len(aCols)
			If !GdDeleted(nX) .And. !Empty(GDFieldGet("DUM_CODPRO",nX)) // Verifica se a linha esta' deletada
				If DUM->(MsSeek(xFilial('DUM')+M->DT5_FILORI+M->DT5_NUMSOL+GdFieldGet('DUM_ITEM',nX)))
					RecLock("DUM",.F.)
				Else
					RecLock("DUM",.T.)
				EndIf
				For nCntFor := 1 To Len(aHeader)
					If !Empty( nPosCampo := FieldPos(aHeader[nCntFor,2] ) )
						FieldPut( nPosCampo, aCols[nX,nCntFor])
					EndIf
				Next nCntFor
				DUM->DUM_FILIAL := xFilial("DUM")
				DUM->DUM_FILORI := M->DT5_FILORI
				DUM->DUM_NUMSOL := M->DT5_NUMSOL
				MsUnLock()

				// Carrega Vetor De Produtos Para Testar Incompatibilidade
				If aScan(aProds,DUM->DUM_CODPRO) == 0
					aAdd(aProds,DUM->DUM_CODPRO)
				EndIf

				// Carrega Vetor para a RRE
				If "4" $ cMV_TMSRRE 
					cCliRRE:= Iif(Empty(M->DT5_CLIDEV),DUE->DUE_CODCLI,M->DT5_CLIDEV)
					cLojRRE:= Iif(Empty(M->DT5_LOJDEV),DUE->DUE_LOJCLI,M->DT5_LOJDEV)

					If !Empty(cCliRRE) .And. !Empty(cLojRRE)
						nPos:= aScan(aVetRRE, {|x| x[1] + x[2] + x[3] == cCliRRE + cLojRRE+ GdFieldGet('DUM_CODPRO',nX) })
						If nPos > 0
							aVetRRE[nPos][4]+= GdFieldGet('DUM_QTDVOL',nX)
							aVetRRE[nPos][5]+= GdFieldGet('DUM_PESO',nX)
							aVetRRE[nPos][6]+= GdFieldGet('DUM_PESOM3',nX)
							aVetRRE[nPos][7]+= GdFieldGet('DUM_VALMER',nX)
						Else
							Aadd(aVetRRE,{cCliRRE, cLojRRE, GdFieldGet('DUM_CODPRO',nX), GdFieldGet('DUM_QTDVOL',nX), GdFieldGet('DUM_PESO',nX), GdFieldGet('DUM_PESOM3',nX), GdFieldGet('DUM_VALMER',nX),'',0 })
						EndIf

						//--- Totalizador do Valor da Mercadoria por Cliente
						nPos:= aScan(aVetCli, {|x| x[1] + x[2] == cCliRRE + cLojRRE })
						If nPos > 0
							aVetCli[nPos][3]+= GdFieldGet('DUM_VALMER',nX)
						Else
							Aadd(aVetCli,{cCliRRE, cLojRRE, GdFieldGet('DUM_VALMER',nX)})
						EndIf

					EndIf
				EndIf
				//-- Monta vetor para geracao da DF2 via painel de agendamentos
				cCodEmb := DUM->DUM_CODEMB
				If (nPosDF2 := Ascan(aVetDF2, {|x| x[1] + x[2] + x[3] == M->DT5_FILORI + M->DT5_NUMSOL + DUM->DUM_CODPRO })) == 0
					Aadd(aVetDF2,{"","","",0,0,0,0,0,0,0})
					nPosDF2 := Len(aVetDF2)
				EndIf
				aVetDF2[nPosDF2,01] := M->DT5_FILORI
				aVetDF2[nPosDF2,02] := M->DT5_NUMSOL
				aVetDF2[nPosDF2,03] := DUM->DUM_CODPRO
				aVetDF2[nPosDF2,04] += DUM->DUM_QTDVOL
				aVetDF2[nPosDF2,05] += DUM->DUM_QTDUNI
				aVetDF2[nPosDF2,06] += DUM->DUM_PESO
				aVetDF2[nPosDF2,07] += DUM->DUM_PESOM3
				aVetDF2[nPosDF2,08] += DUM->DUM_VALMER				

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava Peso Cubado dos Itens da Solicitacao de Coleta                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				a460AtuDTE(1,aRatPesM3,aRecDTE,aHeaderDTE,lCotacao)

				nQtdVol += DUM->DUM_QTDVOL
				nQtdUni += DUM->DUM_QTDUNI
				nPeso   += DUM->DUM_PESO
				nPesoM3 += DUM->DUM_PESOM3
				nValMer += If(DUM->(FieldPos("DUM_VALMER")) > 0,DUM->DUM_VALMER,0)
				nMetro3 += Iif(lDumM3,DUM->DUM_METRO3,0)
				
				//- Posições 9-Base Seguro e 10-Metro Cubico
				If DUM->(ColumnPos('DUM_BASSEG')) > 0 .AND.DUM->(ColumnPos('DUM_METRO3')) > 0 
					aVetDF2[nPosDF2,09] += DUM->DUM_BASSEG
					aVetDF2[nPosDF2,10] += DUM->DUM_METRO3
				EndIf
			Else
				//-- Exclui o registro referente a linha marcada para deleção.
				If DUM->(MsSeek(xFilial('DUM')+M->DT5_FILORI+M->DT5_NUMSOL+GdFieldGet('DUM_ITEM',nX)))
					RecLock("DUM",.F.)
					dbDelete()
					MsUnLock()
				EndIf
			EndIf
		Next

		If DT5->(FieldPos("DT5_CDRDCA")) > 0 .And. !Empty(DT5->DT5_CDRDCA)
			cCdrDes := DT5->DT5_CDRDCA
		Else
			cCdrDes := DT5->DT5_CDRORI
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o Numero da Solicitacao no DTE (Peso Cubado)                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DTE->(dbSetOrder( 2 ))
		If !Empty(M->DT5_NUMCOT) .And. DTE->(MsSeek(xFilial("DTE") + M->DT5_FILORI + M->DT5_NUMCOT))
			RecLock("DTE", .F.)
			DTE->DTE_NUMSOL := M->DT5_NUMSOL
			DTE->DTE_ITESOL := StrZero(1,Len(DTE->DTE_ITESOL))
			MsUnLock()
		EndIf

		//-- Grava o no. da Solicitacao de Coleta na Cotacao de Frete 
		If !Empty(M->DT5_NUMCOT)
			DT4->(dbSetOrder(1))
			If DT4->(MsSeek(xFilial('DT4')+M->DT5_FILORI+M->DT5_NUMCOT)) .And. DT4->(ColumnPos('DT4_NUMSOL')) > 0
				RecLock('DT4',.F.)
				DT4->DT4_NUMSOL := M->DT5_NUMSOL
				MsUnLock()
			EndIf
			cAliasQry := GetNextAlias()
			cQuery := " SELECT SUM(DT8_VALTOT) VALTOT "
			cQuery += "   FROM " + RetSqlName("DT8")
			cQuery += "   WHERE DT8_FILIAL = '" + xFilial("DT8") + "' "
			cQuery += "     AND DT8_FILORI = '" + M->DT5_FILORI + "' "
			cQuery += "     AND DT8_NUMCOT = '" + M->DT5_NUMCOT + "' "
			cQuery += "     AND DT8_CODPAS = 'TF' "
			cQuery += "     AND D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .T.)
			If (cAliasQry)->(!Eof())
				nValTot := (cAliasQry)->VALTOT
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o arquivo DVT (Tipos de Veiculo Solic. Coleta/Cotacao/Nota Fiscal)  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aColsDVT) > 0
			a460AtuDVT(nOpcx, M->DT5_FILORI, M->DT5_NUMSOL, M->DT5_NUMCOT, StrZero(1,Len(DVT->DVT_ORIGEM)), "1", cSolicit, cCotacao)
		EndIf

		//-- Verifica limite de credito do cliente solicitante.
		If lCliDev //Utiliza o  cliente devedor do frete informado
			lCredito := MaAvalCred(M->DT5_CLIDEV,M->DT5_LOJDEV,nValTot,,.F.) //-- Avalia credito do devedor
		Else
			DUE->(dbSetOrder(1)) //Utiliza o solicitante da Coleta
			If DUE->(MsSeek(xFilial("DUE") + M->DT5_CODSOL))
				If !Empty(DUE->DUE_CODCLI) .And. !Empty (DUE->DUE_LOJCLI)
					lCredito := MaAvalCred(DUE->DUE_CODCLI,DUE->DUE_LOJCLI,nValTot,,.F.) //-- Avalia credito do devedor
				EndIf
			EndIf
		EndIf
		If !lCredito			
			// Gera Bloqueio Credito
			If lTmsa029  .And. Tmsa029Use("TMSA460")
				lRet := Tmsa029Blq( 3  ,;				//-- 01 - nOpc
						'TMSA460',;		//-- 02 - cRotina
						'LC'  ,;			//-- 03 - cTipBlq   //Limite Credito
						M->DT5_FILORI,;	//-- 04 - cFilOri
						'DT5' ,;			//-- 05 - cTab
						'1' ,;				//-- 06 - cInd
						xFilial("DT5") + M->DT5_FILORI + M->DT5_NUMSOL,; //-- 07 - cChave
						M->DT5_NUMSOL ,;	//-- 08 - cCod
						STR0079 +"#" + DT5->DT5_FILORI + "/" + DT5->DT5_NUMSOL + STR0078 + "|" ,;	//-- 09 - cDetalhe
						nOpcx)				// 10 - Opcao Rotina

				If lRet	
					RecLock("DT5",.F.)
					DT5->DT5_STATUS := StrZero(6,Len(DT5->DT5_STATUS)) //-- Bloqueada
					MsUnlock()
				EndIf
			
			EndIf
			If IsInCallStack("TMSAF76") .And. DF1->DF1_NFBALC != "1"
				Aviso(STR0080,STR0079 + DT5->DT5_FILORI + "/" + DT5->DT5_NUMSOL + STR0078,{"Ok"}) //--"Atenção!"//--"A solicitação de coleta "//--" está bloqueada por crédito."
			EndIf
		EndIf

		//-------------------------------------------------------------------------------------------------
		// INICIO -> Divergencia De Produtos ( Define Bloqueio Da Solicitação De Coleta )
		//-------------------------------------------------------------------------------------------------
		If lTmsa029  .And. Tmsa029Use("TMSA460")

			//-- Verifica Divergencia De Produtos
			If  "A" $ cMV_TMSINCO .Or. "D" $ cMV_TMSINCO
				aProds  := TmsRtDvP(aProds) // Determina Divergencias entre os Produtos Do Vetor
			Else
				aProds  := {}
			EndIf

			//-- Gera Bloqueios Caso Existam
			If Len(aProds) > 0 .Or. Len(aVetRRE) > 0

				If Len(aProds) > 0  //-- Divergencias
					For nX := 1 To Len(aCols)

						cProd   := GDFieldGet("DUM_CODPRO",nX)
						nPos    := Ascan(aProds,{ |x| x[1] == cProd } )

						If nPos > 0 
							DbSelectArea("SB5")
							DbSetOrder(1) //-- B5_FILIAL+B5_COD
							MsSeek(xFilial("SB5") + cProd ,.F.)
	
							DbSelectArea("DY3")
							DbSetOrder(1) //-- DY3_FILIAL+DY3_ONU+DY3_ITEM
							MsSeek(xFilial("DY3") + SB5->B5_ONU + SB5->B5_ITEM ,.F.)
	
							//-- Gera String Com Dados Das Divergencias Dos Produtos (Histórico)
							cMotBlq +=	( 	STR0071 + "#" + DY3->DY3_NRISCO + " " + DY3->DY3_GRPEMB					+"#"+; //-- "Risco"
											STR0084 + "#" + cProd														+"#"+; //-- "Produto"
											STR0044 + "#" + Posicione("SB1",1,xFilial("SB1") + cProd,"B1_DESC")	+"#"+; //-- "Descrição:"
											STR0085 + "#" + Iif(nPos > 0,aProds[nPos,2],"")							+"|" ) //-- "Divergência"
						EndIf
					Next nX

					// Gera Bloqueio Por Divergencia De Produtos
					If Tmsa029Blq( 3  ,;				//-- 01 - nOpc
									'TMSA460',;		//-- 02 - cRotina
									'CR'  ,;			//-- 03 - cTipBlq
									M->DT5_FILORI,;	//-- 04 - cFilOri
									'DT5' ,;			//-- 05 - cTab
									'1' ,;				//-- 06 - cInd
									xFilial("DT5") + M->DT5_FILORI + M->DT5_NUMSOL,; //-- 07 - cChave
									M->DT5_NUMSOL ,;	//-- 08 - cCod
									cMotBlq ,;			//-- 09 - cDetalhe
									nOpcx)				//-- 10 - Opcao Rotina

						lBloqDT5:= .T.
					EndIf
				EndIf

				//-- Bloqueio por Regra e Restrição de Embarque
				If Len(aVetRRE) > 0
					For nI:= 1 To Len(aVetCli)
						aEval(aVetRRE, {|x| Iif( x[1]+x[2] == aVetCli[nI][1] + aVetCli[nI][2], x[9]+= aVetCli[nI][3], .T.) })  //Atualiza valor total por Cliente
					Next nI

					cMotBlq:= ""
					aRetRRE:= TmsRetRRE(aVetRRE,,,"TMSA460",)
					
					If Len(aRetRRE) > 0
					
						For nI:= 1 To Len(aRetRRE)
							cMotBlq +=	( 	"RRE: " + "#" +  aRetRRE[nI,1] + " - "  + aRetRRE[nI,2] + " " + aRetRRE[nI,3]	+;
											"#" + STR0084 + ; //"Produto:"
											"#" + aRetRRE[nI,04] +;
											"#" + STR0094 +; // "Detalhes:"
											"#" + aRetRRE[nI,06] + "|" )					
						Next nI
						
						// Gera Bloqueio Por RRE
						If Tmsa029Blq( 3  ,;				//-- 01 - nOpc
										'TMSA460',;		//-- 02 - cRotina
										'RR'  ,;			//-- 03 - cTipBlq
										M->DT5_FILORI,;	//-- 04 - cFilOri
										'DT5' ,;			//-- 05 - cTab
										'1' ,;				//-- 06 - cInd
										xFilial("DT5") + M->DT5_FILORI + M->DT5_NUMSOL,; //-- 07 - cChave
										M->DT5_NUMSOL ,;	//-- 08 - cCod
											cMotBlq,;			//-- 09 - cDetalhe
											nOpcx)				//-- 10 - Opcao Rotina
	
								lBloqDT5:= .T.
	
						EndIf
					EndIf
				EndIf

				If lBloqDT5
				// Atualiza Status Da Solicitação De Coleta Para 'Bloqueado'.
					RecLock("DT5",.F.)
					DT5->DT5_STATUS := StrZero(6,Len(DT5->DT5_STATUS)) //-- Bloqueada
					MsUnlock()
				EndIf

			Else

				// Caso Existam Bloqueios Antigos, Limpa Referencia
				Tmsa029Blq( 5  ,;				// 01 - nOpc
							'TMSA460',;		// 02 - Rotina
							'CR',;				// 03 - Tipo Bloq (Nil Apaga Todos Codigos de Bloqueio da Viagem
							M->DT5_FILORI,;	// 04 - Filial Origem
							'DT5',;			// 05 - Tabela Referencial
							'1',;				// 06 - Indice Da Tabela
							xFilial("DT5") + M->DT5_FILORI + M->DT5_NUMSOL,;	// 07 - Chave Indexação
							"",;				// 08 - Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
							"",;				// 09 - Detalhes Adicionais a Respeito Do Bloqueio
							nOpcx)				// 10 - Opcao Rotina

				Tmsa029Blq( 5  ,;				// 01 - nOpc
							'TMSA460',;		// 02 - Rotina
							'RR',;				// 03 - Tipo Bloq (Nil Apaga Todos Codigos de Bloqueio da Viagem
							M->DT5_FILORI,;	// 04 - Filial Origem
							'DT5',;			// 05 - Tabela Referencial
							'1',;				// 06 - Indice Da Tabela
							xFilial("DT5") + M->DT5_FILORI + M->DT5_NUMSOL,;	// 07 - Chave Indexação
							"",;				// 08 - Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
							"",;				// 09 - Detalhes Adicionais a Respeito Do Bloqueio
							nOpcx)				// 10 - Opcao Rotina

			EndIf
		EndIf
		//-------------------------------------------------------------------------------------------------
		// FIM -> Divergencia De Produtos
		//-------------------------------------------------------------------------------------------------

		//-- Grava documento de transporte
		If DT5->DT5_STATUS <> StrZero(6,Len(DT5->DT5_STATUS)) //-- Bloqueada
			TMSA460GDc(nQtdVol,nPeso,nPesoM3,nValMer,nMetro3,nQtdUni)
		Else
			cAliasQry := GetNextAlias()
			cQuery := " SELECT 0 TOTAL "
			cQuery += "   FROM " + RetSqlName("DUD")
			cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
			cQuery += "     AND DUD_FILDOC = '" + DT5->DT5_FILDOC + "' "
			cQuery += "     AND DUD_DOC    = '" + DT5->DT5_DOC + "' "
			cQuery += "     AND DUD_SERIE  = '" + DT5->DT5_SERIE + "' "
			cQuery += "     AND DUD_VIAGEM <> ' ' "
			cQuery += "     AND D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .T.)
			If (cAliasQry)->(!Eof())
				lViagem := .T.
			EndIf
			(cAliasQry)->(DbCloseArea())
			
			If !lViagem
				DT6->(DbSetOrder(1))
				If DT6->(MsSeek(xFilial("DT6")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
					RecLock("DT6",.F.)
					DbDelete()
					MsUnlock()
				EndIf
				DUD->(DbSetOrder(1))
				If DUD->(MsSeek(xFilial("DT6")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
					RecLock("DUD",.F.)
					DbDelete()
					MsUnlock()
				EndIf
			Else
				DT6->(DbSetOrder(1))
				If DT6->(MsSeek(xFilial("DT6")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
					RecLock("DT6",.F.)
					DT6->DT6_BLQDOC := StrZero(1,Len(DT6->DT6_BLQDOC))
					MsUnlock()
				EndIf
			EndIf
		EndIf

		//Gera agendamento automaticamente se:
		//- Se não for inclusão de NF nem inclusão de agendamento;
		//- Origem da inclusão da coleta for pelo painel de agendamentos (TMSAF76), ou via menu (TMSAF05) se configurado para agendamento virtual no contrato do cliente.
		If nOpcx == 3 .And. !IsInCallStack("tm050grvag") .And. !IsInCallStack ("TMSAF05Grv")  
			
			lGerAge := IsInCallStack ("TMSAF76")  
			
			If !lGerAge   
				aContrat := TMSContrat(DT5->DT5_CLIDEV, DT5->DT5_LOJDEV,,IIf(lServic,DT5->DT5_SERVIC,""),, DT5->DT5_TIPFRE,,,,,,,,,,,,,,,,DT5->DT5_CODNEG)
				If !Empty(aContrat)
					lGerAge  := ((aContrat[1,43,1,19] == "1") .Or. (aContrat[1,43,1,19] == "0" .And. aContrat[1,44,1,7] == "1"))
				EndIf
			EndIf
			
			If lGerAge
				cDocTms := Posicione("DC5",1,xFilial("DC5") + IIf(lServic,DT5->DT5_SERVIC,""),"DC5_DOCTMS") 
				cSrvCol := IIf(lServic,DT5->DT5_SERVIC,"")
				cServic := IIf(lSrvEnt,DT5->DT5_SRVENT,"")
				aVetDF0 := {DUE->DUE_DDD,DUE->DUE_TEL,DUE->DUE_CODSOL}
				aVetDF1 := {DUE->DUE_CODCLI,DUE->DUE_LOJCLI,DT5->DT5_TIPTRA,"1",DT5->DT5_CDRORI,DT5->DT5_CLIDES,DT5->DT5_LOJDES,;
							DT5->DT5_CDRDCA,DT5->DT5_TIPFRE,DT5->DT5_CLIDEV,DT5->DT5_LOJDEV,DT5->DT5_NCONTR,DT5->DT5_CODNEG,cServic,cSrvCol,DT5->DT5_SQEREM,DT5->DT5_SQEDES}
				TM050GrvAg(,aVetDF2,aVetDF0,aVetDF1,cCodEmb,DT5->DT5_SEQEND,.F.,cTipNFC,cDocTms)				  				
			EndIf
		EndIf
		
	EndIf

End Transaction

// Se gerou um novo numero para a solicitacao
If nOpcx == 3 .And. lGerNum .And. !lAutomatic
	Help('',1,'TMSA46023',, STR0034 + cNumSol,5,1) //"O novo codigo da Solicitacao sera : "
EndIf

If lTMA460GRV
	ExecBlock('TMA460GRV',.F.,.F.,{nOpcx,M->DT5_FILORI,M->DT5_NUMSOL,lCredito})
EndIf

//-- Permite imprimir a coleta na chamada da rotina atraves do programa TMSA040 (Cotacao),
//-- na inclusao da coleta ou na confirmacao do agendamento. 
If !IsInCallStack("TMSF76VIA")
	If lImprime .And. (lRTMSR02 .Or. lTMSR580) .And. !lAutomatic .And. ;
		( ( nOpcx == 3 .And. !lTMSA040 ) .Or. ( nOpcx == 4 .And. lTMSA040 ) .Or. ;
		( Left(FunName(),7) == "TMSAF05" ) )
	
		DT5->( DbSetOrder(1) )
		If DT5->( DbSeek( xFilial('DT5') + cFilAnt + M->DT5_NUMSOL ) )
			aAreaDT6 := DT6->(GetArea())
			DT6->(DbSetOrder(1))
			If DT6->(DbSeek(xFilial('DT6')+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
				
				//--Se chamado pelo TMSAF76 - Painel do Agendamento acumula as solicitações para
				//--imprimir após a confirmação de todos os agendamentos.
				If IsInCallStack("AF76CofAgd")
                         If Type("__VPRINTSC") != "U"
                              AADD(__VPRINTSC,{DT5->DT5_FILDOC,DT5->DT5_DOC,DT5->DT5_SERIE,DT5->( Recno() )})
                         EndIf
				Else
     				//--Nao chama a tela de impressao se o documento ja foi impressa
     				If DT6->DT6_FIMP <> "1" //--Impresso
     					TmsA460Imp(,,,,lImprime)
     				EndIf
				EndIf
			EndIf
			RestArea(aAreaDT6)
		EndIf
	
	EndIf
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA460Leg³ Autor ³ Patricia A. Salomao   ³ Data ³08.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a legenda                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA460Leg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA460                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA460Leg()
Local aRet := {}
Local aLegenda := {}

aLegenda := {{"BR_VERDE"   , STR0009 },;     //"Em Aberto"
  			{ "BR_VERMELHO", STR0018 },;     //"Indicada para Coleta"
  			{ "BR_AMARELO" , STR0019 },;     //"Em Transito"
  			{ "BR_AZUL"    , STR0010 },;     //"Encerrada"
  			{ "BR_LARANJA" , STR0021 },;     //"Documento Informado"
  			{ "BR_CINZA"   , STR0042 },;     //"Bloqueada"
  			{ "BR_MARRON"  , STR0074 },;     //"Em Conferencia"
  			{ "BR_PRETO"   , STR0011 }}		 //-- "Cancelado"

If ExistBlock("TM460LEG")
	aRet := ExecBlock("TM460LEG",.F.,.F., {2,aLegenda})
	If ValType(aRet) == "A" .And. !Empty(aRet)
		aLegenda := aClone(aRet)
	EndIf
EndIf

BrwLegenda(cCadastro,STR0008,aLegenda)	//-- "Status do Lote" ### "Status"

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA460Ver³ Autor ³Patricia A. Salomao    ³ Data ³08.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao colocada no X3_RELACAO dos campos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA460Ver(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Nome do Campo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA460                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA460Ver(cCampo)
Local aAreas := {DUL->(GetArea()),DUE->(GetArea()),SA1->(GetArea()),GetArea()}
Local cRet   := ""

Default cCampo := ""

cCampo := AllTrim(cCampo)

If cCampo == 'M->DT5_END'
	If !Empty(M->DT5_SEQEND)
		cRet := Posicione("DUL",3,xFilial("DUL")+M->DT5_CODSOL+M->DT5_SEQEND,"DUL_END")
	Else
		cRet := Posicione("DUE",1,xFilial("DUE")+M->DT5_CODSOL,"DUE_END")
	EndIf
ElseIf cCampo == 'M->DT5_BAIRRO'
	If !Empty(M->DT5_SEQEND)
		cRet := Posicione("DUL",3,xFilial("DUL")+M->DT5_CODSOL+M->DT5_SEQEND,"DUL_BAIRRO")
	Else
		cRet := Posicione("DUE",1,xFilial("DUE")+M->DT5_CODSOL,"DUE_BAIRRO")
	EndIf
ElseIf cCampo == 'M->DT5_MUN'
	If !Empty(M->DT5_SEQEND)
		cRet := Posicione("DUL",3,xFilial("DUL")+M->DT5_CODSOL+M->DT5_SEQEND,"DUL_MUN")
	Else
		cRet := Posicione("DUE",1,xFilial("DUE")+M->DT5_CODSOL,"DUE_MUN")
	EndIf
ElseIf cCampo == 'M->DT5_EST'
	If !Empty(M->DT5_SEQEND)
		cRet := Posicione("DUL",3,xFilial("DUL")+M->DT5_CODSOL+M->DT5_SEQEND,"DUL_EST")
	Else
		cRet := Posicione("DUE",1,xFilial("DUE")+M->DT5_CODSOL,"DUE_EST")
	EndIf
ElseIf cCampo == 'M->DT5_CEP'
	If !Empty(M->DT5_SEQEND)
		cRet := Posicione("DUL",3,xFilial("DUL")+M->DT5_CODSOL+M->DT5_SEQEND,"DUL_CEP")
	Else
		cRet := Posicione("DUE",1,xFilial("DUE")+M->DT5_CODSOL,"DUE_CEP")
	EndIf

ElseIf cCampo == 'M->DT5_HORCOI'
	cRet := Posicione("DUE",1,xFilial("DUE")+M->DT5_CODSOL,"DUE_HORCOI")

ElseIf cCampo == 'M->DT5_HORCOF'
	cRet := Posicione("DUE",1,xFilial("DUE")+M->DT5_CODSOL,"DUE_HORCOF")

ElseIf cCampo == 'M->DT5_NOMDES'
	cRet := Posicione("SA1",1,xFilial("SA1")+M->DT5_CLIDES+M->DT5_LOJDES,"A1_NOME")

ElseIf cCampo == 'M->DT5_ENDDES'
	If !Empty(M->DT5_SQEDES)
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1")+M->DT5_CLIDES+M->DT5_LOJDES))
			cRet := Posicione("DUL",2,xFilial("DUL")+SA1->A1_COD+SA1->A1_LOJA+M->DT5_SQEDES,"DUL_END")
		EndIf
	Else
		cRet := Posicione("SA1",1,xFilial("SA1")+M->DT5_CLIDES+M->DT5_LOJDESL,"A1_END")
	EndIf
ElseIf cCampo == 'M->DT5_BAIDES'
	If !Empty(M->DT5_SQEDES)
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1")+M->DT5_CLIDES+M->DT5_LOJDES))
			cRet := Posicione("DUL",2,xFilial("DUL")+SA1->A1_COD+SA1->A1_LOJA+M->DT5_SQEDES,"DUL_BAIRRO")
		EndIf
	Else
		cRet := Posicione("SA1",1,xFilial("SA1")+M->DT5_CLIDES+M->DT5_LOJDESL,"A1_BAIRRO")
	EndIf
ElseIf cCampo == 'M->DT5_MUNDES'
	If !Empty(M->DT5_SQEDES)
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1")+M->DT5_CLIDES+M->DT5_LOJDES))
			cRet := Posicione("DUL",2,xFilial("DUL")+SA1->A1_COD+SA1->A1_LOJA+M->DT5_SQEDES,"DUL_MUN")
		EndIf
	Else
		cRet := Posicione("SA1",1,xFilial("SA1")+M->DT5_CLIDES+M->DT5_LOJDESL,"A1_MUN")
	EndIf
ElseIf cCampo == 'M->DT5_ESTDES'
	If !Empty(M->DT5_SQEDES)
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1")+M->DT5_CLIDES+M->DT5_LOJDES))
			cRet := Posicione("DUL",2,xFilial("DUL")+SA1->A1_COD+SA1->A1_LOJA+M->DT5_SQEDES,"DUL_EST")
		EndIf
	Else
		cRet := Posicione("SA1",1,xFilial("SA1")+M->DT5_CLIDES+M->DT5_LOJDESL,"A1_EST")
	EndIf
ElseIf cCampo == 'M->DT5_CEPDES'
	If !Empty(M->DT5_SQEDES)
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1")+M->DT5_CLIDES+M->DT5_LOJDES))
			cRet := Posicione("DUL",2,xFilial("DUL")+SA1->A1_COD+SA1->A1_LOJA+M->DT5_SQEDES,"DUL_CEP")
		EndIf
	Else
		cRet := Posicione("SA1",1,xFilial("SA1")+M->DT5_CLIDES+M->DT5_LOJDESL,"A1_CEP")
	EndIf
ElseIf cCampo == "M->DT5_NOMREM"
		cRet := Posicione("SA1", 1, xFilial("SA1") + M->DT5_CLIREM + M->DT5_LOJREM, "A1_NOME" )
ElseIf cCampo == "M->DT5_NOMDEV"
		cRet := Posicione("SA1", 1, xFilial("SA1") + M->DT5_CLIDEV + M->DT5_LOJDEV, "A1_NOME" )
ElseIf cCampo == "M->DT5_NOME"
		cRet := 	Posicione("DUE",1,Xfilial('DUE')+M->DT5_CODSOL,"DUE_NOME")
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A460PesoM3³ Autor ³Patricia A. Salomao    ³ Data ³16.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o Peso Cubado da Solicitacao de Frete               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A460PesoM3()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA460                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A460PesoM3()

Local cNumSol		:= M->DT5_NUMSOL
Local cNumCot		:= M->DT5_NUMCOT
Local cCodPro		:= ''
Local nPosItem		:= aScan(aHeader,{|x| AllTrim(x[2]) == "DUM_ITEM"})
Local nPosPesoM3	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DUM_PESOM3"})
Local nPosQtdVol	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DUM_QTDVOL"})
Local nPosRat		:= aScan(aRatPesM3,{|x| x[1] == aCols[n][nPosItem]})
Local nFatCub		:= 0
Local nOpca			:= 0
Local nUsado		:= 0
Local nOpc			:= 0
Local oDlgEsp,oGetDados,nY
Local cCliDev     	:= ''
Local cLojDev     	:= ''
Local nPerCub     	:= 0
Local lServic	  	:= DT5->(ColumnPos("DT5_SERVIC")) > 0
Local aContrt 		:= {}
Local nCont     	:= 0
Local aCampos  		:= FwFormStruct(2,"DTE")

Private nTotQtdVol	:= 0
Private nTotPesoM3	:= 0
Private aSavHeader	:= aClone(aHeader)
Private aSavCols	:= aClone(aCols)
Private nSavN		:= n

l460Auto := If (Type("l460Auto") == "U",.F.,l460Auto)
nOpca    := If(l460Auto,nOpcxAuto,o1Get:nOpc)
cCodPro := GdFieldGet('DUM_CODPRO',n)

If Empty(cCodPro)
	Help("",1,"TMSA05025") //-- Informe o Produto ...
	Return( .F. )
EndIf

If Empty(GdFieldGet('DUM_QTDVOL',n) )
	Help("",1,"TMSA46006") //-- Informe a Qtde. de Volumes  ...
	Return( .F. )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso o campo B5_PERCUB esteja preenchido, calcular o percentual a partir   ³
//³do peso digitado e armazenar o valor obtido no campo DUM_PESOM3.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == 3  .Or. nOpca == 4
	TMSA460Cli(@cCliDev,@cLojDev)
	nPerCub := TmsPerCub(cCodPro,cCliDev,cLojDev)
	If !Empty(nPerCub)
		Help("",1,"TMSA05026") //-- O Peso Cubado será calculado automaticacamente, de acordo com o percentual de cubagem (B5_PERCUB) informado no complemento do Produto.
		Return( .F. )
	EndIf
EndIf

If !Empty(nPerCub)
	nFatCub := nPerCub
Else
	nFatCub := GetMV("MV_FATCUB")
	If AT(nFatCub, ".") > 0 .And. AT(nFatCub, ",") > 0
		nFatCub := StrTran(nFatCub, ".", "")
	EndIf 
	nFatCub := Val(StrTran(nFatCub, ",", "."))	 
EndIf

aContrt := TMSContrat(M->DT5_CLIDEV,M->DT5_LOJDEV,,IIf(lServic,M->DT5_SERVIC,""),.F.,M->DT5_TIPFRE,,,,,,,,,,,,,,,,M->DT5_CODNEG)
If !Empty(aContrt) .And. aContrt[1,2] > 0
    nFatCub := aContrt[1,2]
EndIf

If !l460Auto
	//-- Finaliza Teclas de Atalhos
	TmsKeyOff(aSetKey)
EndIf

n       := 1
aCols   := {}
aHeader := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aHeaderDTE) == 0
	For nCont := 1 to Len(aCampos:aFields)

		IF (aCampos:aFields[nCont,1])$"DTE_QTDVOL|DTE_COMPRI|DTE_ALTURA|DTE_LARGUR"

			AAdd(	aHeader, { AllTrim( aCampos:aFields[nCont,3])      			  ,; //| Titulo do Campo
					 		   AllTrim( aCampos:aFields[nCont,1])                 ,; //| X3_Campo
							   X3Picture(aCampos:aFields[nCont][1])	              ,; //| picture
							   TamSX3(aCampos:aFields[nCont][1])[1]				  ,; //| tamanho
							   TamSX3(aCampos:aFields[nCont][1])[2]				  ,; //| decimal
							   GetSx3Cache(aCampos:aFields[nCont][1],"X3_VALID")  ,; //| valid
                        	   GetSx3Cache(aCampos:aFields[nCont][1],"X3_USADO")  ,; //| usado
							   GetSx3Cache(aCampos:aFields[nCont][1],"X3_TIPO")   ,; //| tipo
							   GetSx3Cache(aCampos:aFields[nCont][1],"X3_ARQUIVO"),; //| arquivo
							   GetSx3Cache(aCampos:aFields[nCont][1],"X3_CONTEXT")}) //| context 
			nUsado++
		EndIf
	Next nCont

	aHeaderDTE := Aclone(aHeader)
Else
	aHeader := Aclone(aHeaderDTE)
	nUsado := Len(aHeader)
EndIf

If nPosRat > 0
	aCols := aClone(aRatPesM3[nPosRat][2])
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem de uma linha em branco no aCols.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd(aCols,Array(nUsado+1))
	For ny := 1 to Len(aHeader)
		aCols[1][ny] := CriaVar(aHeader[nY][2])
		aCols[1][nUsado+1] := .F.
	Next ny
EndIf

If !l460Auto
	DEFINE MSDIALOG oDlgEsp FROM 94 ,104 TO 310,590 TITLE STR0014 Of oMainWnd PIXEL  //"Peso Cubado"

	oGetDados := MSGetDados():New(30,2,105,243,IIF(!Empty(cNumCot),2,nOpca),'PesoM3LOk()','AllwaysTrue()',,IIf(nOpca==3.Or.nOpca==4,.T.,Nil),,,,100,,,,If(!Empty(cNumCot),"AlwaysFalse",Nil))
	@ 6  ,116 SAY '' Of oDlgEsp PIXEL SIZE 26 ,9
	@ 18 ,3   SAY STR0015 Of oDlgEsp PIXEL SIZE 56 ,9  //"No.Solicitacao / Item : "
	@ 18 ,60  SAY cNumSol + "/" + aSavCols[nSavN][nPosItem] Of oDlgEsp PIXEL SIZE 50 ,9
	@ 18 ,120 SAY STR0016  Of oDlgEsp PIXEL SIZE 56 ,9  //"Qtd. Volumes : "
	@ 18 ,160 SAY aSavCols[nSavN][nPosQtdVol] Of oDlgEsp PIXEL SIZE 29 ,9

	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||IIF(oGetDados:TudoOk() .And. A460PesM3Ok(),(nOpc:=1,oDlgEsp:End()),(nOpc:=0))},{||oDlgEsp:End()} )
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas pela rotina de inclusao automatica     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MsGetDAuto(aAutoCuba,"PesoM3LOk",{|| A460PesM3Ok()},/*aAutoCab*/,IIF(!Empty(cNumCot),2,nOpca))
		nOpc := 1
	EndIf
EndIf

If nOpc == 1 .And. Empty(cNumCot)
	If nPosRat > 0
		aRatPesM3[nPosRat][2] := aClone(aCols)
	Else
		AAdd(aRatPesM3,{aSavCols[nSavN][nPosItem],aClone(aCols)})
	EndIf
EndIf

aHeader := aClone(aSavHeader)
aCols	:= aClone(aSavCols)
n		:= nSavN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o Peso Cubado do Item                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	nOpc ==1
	If nFatCub == 0 .And. !l460Auto
		Help("",1,"TMSA46004") //O Fator de Cubagem está sem Valor, portanto, o Peso Cubado ficara com valor Zero.
	EndIf
	aCols[ n, nPosPesoM3 ] := (nTotPesoM3) * nFatCub
EndIf

If !l460Auto
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A460PesM3OK³ Autor ³Patricia A. Salomao    ³ Data ³16.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³TudoOk da GetDados de Peso Cubado                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A460PesM3Ok()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA460                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A460PesM3Ok()

Local nx
Local lRet := .T.
Local nPosQtdVol := aScan(aSavHeader,{|x| AllTrim(x[2]) == "DUM_QTDVOL"})

//-- Validacao da Linha Digitada; Esta funcao esta' no programa TMSA050
lRet := PesoM3LOk()
If lRet
	nTotQtdVol := 0
	nTotPesoM3 := 0
	For nx := 1 to Len(aCols)
		If !GdDeleted(nX)
			nTotQtdVol += GdFieldGet('DTE_QTDVOL',nX)
			nTotPesoM3 += GdFieldGet('DTE_QTDVOL',nX) * ( GdFieldGet('DTE_ALTURA',nX) * GdFieldGet('DTE_COMPRI',nX) * GdFieldGet('DTE_LARGUR',nX) )
		EndIf
	Next

	If nTotQtdVol > 0 .And. nTotQtdVol <> aSavCols[nSavN][nPosQtdVol]
		Help("",1,"TMSA46005")//--A somatoria da Qtd. de Volumes esta Diferente da Qtd. de Volumes informada no Item da Solicitacao
		lRet := .F.
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A460VerPesM³ Autor ³Patricia A. Salomao    ³ Data ³17.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica o Peso Cubado dos Itens da Solicitacao de Coleta    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A460VerPesM3()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA460                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function a460VerPesM3()

Local aArea    := GetArea()
Local nItDTE   := 0
Local cSeek , bWhile

If Empty(M->DT5_NUMCOT)
	DTE->(dbSetOrder(3))
	bWhile := {|| !DTE->(Eof()) .And. DTE->DTE_FILIAL+DTE->DTE_FILORI+DTE->DTE_NUMSOL+DTE->DTE_ITESOL == DUM->(DUM_FILIAL+DUM_FILORI+DUM_NUMSOL+DUM_ITEM) }
Else
	DTE->(dbSetOrder(2))
EndIf

dbSelectArea("DUM")
dbSetOrder(1)
MsSeek(xFilial("DUM")+M->DT5_FILORI+M->DT5_NUMSOL)
Do While !Eof() .And. DUM_FILIAL+DUM_FILORI+DUM_NUMSOL == xFilial("DTE")+M->DT5_FILORI+M->DT5_NUMSOL
	If Empty(M->DT5_NUMCOT)
		cSeek := xFilial("DTE")+ DUM->(DUM_FILORI+DUM_NUMSOL+DUM_ITEM)
	Else
		bWhile := {|| DTE->(!Eof()) .And. DTE->DTE_FILIAL+DTE->DTE_FILORI+DTE->DTE_NUMCOT+DTE->DTE_CODPRO== xFilial("DTE")+M->DT5_FILORI+M->DT5_NUMCOT+DUM->DUM_CODPRO}		
		cSeek := xFilial("DTE")+M->DT5_FILORI+M->DT5_NUMCOT+DUM->DUM_CODPRO
	EndIf
	If DTE->(MsSeek( cSeek ) )
		AAdd(aRatPesM3,{DUM->DUM_ITEM,{}})
		AAdd(aRecDTE,{DUM->DUM_ITEM,{}})
		nItDTE++
		While Eval(bWhile)
			AAdd(aRatPesM3[nItDTE][2],{DTE->DTE_QTDVOL,DTE->DTE_ALTURA,DTE->DTE_LARGUR,DTE->DTE_COMPRI ,.F.})
			AAdd(aRecDTE[nItDTE][2],{DTE->(Recno())})
			DTE->(dbSkip())
		EndDo
	EndIf
	DUM->(dbSkip())
EndDo

RestArea(aArea)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A460AtuDTE³ Autor ³Patricia A. Salomao    ³ Data ³06.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza os Campos do Arq. DTE (Cubagem de Mercadorias)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A460AtuDTE(ExpN1,ExpA1,ExpA2,ExpA3)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Opcao selecionada                                   ³±±
±±³          ³ExpA1 : Array contendo Altura/Largura/Comprimento dos Itens ³±±
±±³          ³        da NF.                                              ³±±
±±³          ³ExpA2 : Array contendo os Registros existentes no DTE.      ³±±
±±³          ³ExpA3 : aHeader da GetDados de Peso Cubado.                 ³±±
±±³          ³ExpL2 : Valida se a Solic.de Coleta esta sendo gerada a par-³±±
±±³          ³        tir de uma Cotacao de Frete                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA460                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A460AtuDTE(nOpc,aRatPesM3,aRecDTE,aHeaderDTE,lCotacao)

Local aArea        := GetArea()
Local nX,nZ,nL,nY

Default nOpc       := 1
Default aRatPesM3  := {}
Default aRecDTE    := {}
Default aHeaderDTE := {}
Default lCotacao   := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava DTE se a Solicitacao de Coleta nao estiver sendo gerada a partir de ³
//³ uma Cotacao de Frete. Esta validacao e' feita porque a Cotacao de Frete   ³
//³ ja' grava DTE.                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCotacao 
	dbSelectArea("DTE")
	nX := aScan(aRatPesM3,{|x| x[1] == DUM->DUM_ITEM}) //-- Verifica se foi informado Peso Cubado para o Item
	If nX > 0
		For nZ := 1 to Len(aRatPesM3[nX][2])
			nL := aScan(aRecDTE,{|x| x[1] == DUM->DUM_ITEM}) //-- Verifica se o Item de Peso Cubado, ja existe no DTE
			If  nL > 0  .And.  nZ <= Len(aRecDTE[nL][2])
				MsGoto(aRecDTE[nX][2][nZ][1])  //-- Posiciona no Registro a ser alterado/deletado
				RecLock("DTE",.F.)
				If (nOpc==1 .And. aRatPesM3[nX][2][nZ][Len(aRatPesM3[nX][2][nZ])]) .Or. (nOpc==2)
					dbDelete()
					MsUnlock()
					Loop
				EndIf
			ElseIf !aRatPesM3[nX][2][nZ][Len(aRatPesM3[nX][2][nZ])] //-- Verifica se a linha esta deletada
				RecLock("DTE",.T.)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza os dados contidos na GetDados                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !aRatPesM3[nX][2][nZ][Len(aRatPesM3[nX][2][nZ])] //-- Verifica se a linha esta deletada
				For nY := 1 to Len(aHeaderDTE)
					If aHeaderDTE[nY][10] # "V"
						DTE->(FieldPut(FieldPos(Trim(aHeaderDTE[nY][2])),aRatPesM3[nX][2][nZ][nY]))
					EndIf
				Next
				DTE->DTE_FILIAL := xFilial('DTE')
				DTE->DTE_FILORI := M->DT5_FILORI
				DTE->DTE_NUMSOL := M->DT5_NUMSOL
				DTE->DTE_ITESOL := DUM->DUM_ITEM
				DTE->DTE_CODPRO := DUM->DUM_CODPRO
				MsUnlock()
			EndIf
		Next
	EndIf
EndIf

RestArea(aArea)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA460Whe³ Autor ³Patricia A. Salomao    ³ Data ³13.09.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes antes de editar o campo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA460Whe()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA460                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA460Whe()

Local cCampo	:=ReadVar()
Local cCodPro	:= ''
Local lRet		:= .T.
Local cCliDev  := ''
Local cLojDev  := ''

If cCampo == 'M->DUM_PESOM3'
	cCodPro := GdFieldGet('DUM_CODPRO',n)
	//--Este campo somente sera' editavel quando o campo B5_PERCUB for branco.
	If Empty(cCodPro)
		lRet :=.F.
	Else
		TMSA460Cli(@cCliDev,@cLojDev)
		lRet := Empty(TmsPerCub(cCodPro,cCliDev,cLojDev))
	EndIf
ElseIf cCampo == 'M->DT5_CDRDCA'
	//-- Testa a edicao do campo quando parametro de Carga Fechada estiver ligado.
	If TMSCFec()
		lRet := ( Empty(M->DT5_CLIDES) .And. Empty(M->DT5_LOJDES) )
	EndIf
ElseIf cCampo $ 'M->DT5_CODNEG:M->DT5_TIPFRE'
	If Empty(M->DT5_CLIDEV)
		lRet := .F.
	EndIf
ElseIf cCampo $ 'M->DT5_SERVIC'
	If Empty(M->DT5_CLIDEV) .Or. Empty(M->DT5_CODNEG)
		lRet := .F.
	EndIf
ElseIf cCampo $ 'M->DT5_SRVENT'
	If Empty(M->DT5_CLIDEV) .Or. Empty(M->DT5_CODNEG)
		lRet := .F.
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA460Prv³ Autor ³Robson Alves           ³ Data ³02.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula a data/hora de previsao de coleta.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA460PrvCol()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data Inicio Coleta                                 ³±±
±±³          ³ ExpC1 = Hora Inicio Coleta                                 ³±±
±±³          ³ ExpL1 = Consulta (TMSPRVENT) sem atualizar dados da Memoria³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA460                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA460PrvCol(dDatPrv,cHorPrv,lConsulta)

Local nA
Local cHoraDe   := GetMv("MV_HORCOI") // Hora de coleta inicial.
Local cHoraAte  := GetMv("MV_HORCOF") // Hora de coleta final.
Local cIntCol   := GetMv("MV_TMPCOL") // Intervalo de coleta.
Local aEmptyPar := {}
Local lRet      := .T.
Local aTmpEnt   := {}
Local aAreaDUE  := DUE->(GetArea())
Local cHoraSol  := ""
Local dDataEnt  := Ctod("")
Local cHoraEnt  := ""

Default dDatPrv   := Ctod("")
Default cHorPrv   := ""
Default lConsulta :=.F.

If lConsulta
	cHoraSol  := cHorPrv
Else
	cHoraSol  := M->DT5_HORSOL
	dDataEnt  := M->DT5_DATPRV
	cHoraEnt  := M->DT5_HORPRV
EndIf

//-- Se o parametro de Carga Fechada estiver ligado os parametros de tempo de coleta nao serao obrigatorios.
If !TMSCFec()
	If Empty(cHoraDe)
		AAdd(aEmptyPar, "MV_HORCOI")
	EndIf

	If Empty(cHoraAte)
		AAdd(aEmptyPar, "MV_HORCOF")
	EndIf

	If Empty(cIntCol)
		AAdd(aEmptyPar, "MV_TMPCOL")
	EndIf

	// Verifica se todos os parametros foram preenchidos.
	lRet := Len(aEmptyPar) == 0

	For nA:=1 To Len(aEmptyPar)
		Help("",1,"TMSA46010",,aEmptyPar[nA],5,5) // Este Parametro esta vazio ... E Obrigatorio preenche-lo.
	Next
EndIf

If lRet
	//-- Se o parametro de Carga Fechada estiver ligado, calcula a previsao de coleta considerando a regiao do solicitante.
	If TMSCFec() .And. !lConsulta
		//-- Calcula tempo de coleta( Regiao Origem - Regiao Solicitante )
		DUE->(dbSetOrder(1))
		If DUE->(MsSeek(xFilial("DUE") + M->DT5_CODSOL))
			aTmpEnt := TmsTmpEntr( DUE->DUE_TIPTRA, M->DT5_CDRORI, DUE->DUE_CDRSOL )

			If	! Empty( aTmpEnt )
				SomaDiaHor( @dDataEnt, @cHoraEnt, HoraToInt( StrTran(aTmpEnt[ 2 ],':',''), 3 ) )

				M->DT5_HORPRV := StrTran(IntToHora(TmsHrToInt(cHoraEnt, 2), 2), ":", "") // Hora de previsao de coleta.
				M->DT5_DATPRV := dDataEnt // Data de previsao de coleta
			EndIf

		EndIf
	Else
		//-- Calcula hora e data de previsao de coleta.
		If IntToHora(TmsHrToInt(cHoraSol, 2) + TmsHrToInt(cIntCol, 2), 2) > IntToHora(TmsHrToInt(cHoraAte, 2), 2)
			cHorPrv := StrTran(IntToHora(TmsHrToInt(cHoraDe, 2), 2), ":", "") // Hora de previsao de coleta.
			dDatPrv += 1                                                       // Data de previsao de coleta
		Else
			cHorPrv := StrTran(IntToHora(TmsHrToInt(cHoraSol, 2) + TmsHrToInt(cIntCol, 2), 2), ":", "")
		EndIf

		If !lConsulta
			M->DT5_HORPRV:= cHorPrv 
			If !Empty(dDatPrv)
				M->DT5_DATPRV:= dDatPrv
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aAreaDUE )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA460Oco³ Autor ³Henry Fila             ³ Data ³02.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra ocorrencias                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA460Oco()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA460                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa460Oco()

Local aAreaDT6 := DT6->(GetArea())
Local aArea    := GetArea()

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

DT6->(dbSetOrder(1))
If DT6->(MsSeek(xFilial("DT6")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
	Tmsa500Tr2()
Endif

RestArea(aAreaDT6)
RestArea(aArea)

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa460Viag³ Autor ³ Eduardo de Souza     ³ Data ³ 20/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza todas viagens da solicitacao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa460Viag()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA460                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa460Viag()

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

TmsAllViag(DT5->DT5_FILDOC,DT5->DT5_DOC,DT5->DT5_SERIE)

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa460Seq ³ Autor ³ Robson Alves         ³ Data ³ 06/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza os enderecos do destinatario.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa460Seq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA460                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa460Seq(cAlias, cTipCli)

Local aAreaDUE	:= DUE->(GetArea())
Local cCliente	:= ""
Local cLoja		:= ""
Local cCodSol	:= ""
Local lRet		:= .F.
Local lDT5Remet	:= DT5->(ColumnPos("DT5_CLIREM")) > 0

Default cAlias	:= "DT5"
Default cTipCli	:= "2"
// ------------------------------------------------------------------------------------------
// cTipCli == "1" // Remetente
// cTipCli == "2" // Destinatario
// cTipCli == "3" // Solicitante
// ------------------------------------------------------------------------------------------

VAR_IXB := ""

Do Case
Case cAlias == "DT5"
	If cTipCli == "1" .And. lDT5Remet // Remetente
			cCliente 	:= M->DT5_CLIREM
			cLoja 		:= M->DT5_LOJREM
	ElseIf cTipCli == "2" // Destinatario
			cCliente 	:= M->DT5_CLIDES
			cLoja 		:= M->DT5_LOJDES
	ElseIf cTipCli == "3"
			cCodSol 	:= M->DT5_CODSOL
	EndIf
EndCase
		
If (lRet:= TmsEndSol(cAlias,cCodSol,cCliente,cLoja))
			VAR_IXB := DUL->DUL_SEQEND
EndIf

RestArea( aAreaDUE )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa460Chg ³ Autor ³ Robson Alves         ³ Data ³ 06/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Repetir a região de destino a cada novo item quando o      ³±±
±±³          ³destinatario for informado.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa460Seq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA460                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa460Chg()

Local cCdrDes := ""

If !Empty( M->DT5_CLIDES ) .And. !Empty( M->DT5_CLIDES )

	SA1->(dbSetOrder(1))
	If SA1->(MsSeek(xFilial("SA1")+M->DT5_CLIDES+AllTrim(M->DT5_LOJDES)))
		cCdrDes := Posicione("DUY", 1, xFilial("DUY") + SA1->A1_CDRDES, "DUY_DESCRI")

		M->DT5_CDRDCA :=  SA1->A1_CDRDES
		M->DT5_REGDCA :=  cCdrDes
		M->DT5_FILDES :=  DUY->DUY_FILDES

	EndIf
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A460TipVei³ Autor ³Patricia A. Salomao    ³ Data ³13.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Informar os Tipos de Veiculo que serao utilizados na Coleta ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A460TipVei()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±³          ³ExpC1 - No. da Solicitacao de Coleta                        ³±±
±±³          ³ExpC2 - No. da Cotacao de Frete                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Os Arrays aHeaderDVT e aColsDVT ja' deverao estar declarados³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA460 / TMSA040                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A460TipVei(nOpcx, cNumSol, cNumCot, lAgend)

Local nOpc      := 0
Local oDlgEsp
Local oGetDados
Local nOpcao    := nOpcx
Local lCallCot  := ( Type("M->DT4_NUMSOL") <> "U" .And. Type("M->DT5_NUMSOL") <> "U" )
Local nY
Local nCont     := 0
Local aCampos   := FwFormStruct(2,"DVT")

Default cNumSol := ''
Default cNumCot := ''

l460Auto := If (Type("l460Auto") == "U",.F.,l460Auto)
If Left(FunName(),7) == 'TMSA460' .Or. lCallCot
	If ( nOpcao == 3 .Or. nOpcao == 4 ) .And. !Empty(cNumCot)
		If !l460Auto
			Help("",1,"TMSA46021") //"Os Tipos de Veiculo deverao ser alterados na Cotacao de Frete, para atualizacao da Composicao do Frete"
		EndIf
		nOpcao := 2
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva as variaveis utilizadas na GetDados Anterior.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SaveInter()

If !l460Auto
	//-- Finaliza Teclas de Atalhos
	TmsKeyOff(aSetKey)
EndIf

n       := 1
aCols   := {}
aHeader := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aHeaderDVT) == 0

	For nCont := 1 to Len(aCampos:aFields)

		AAdd(	aHeader, { AllTrim( aCampos:aFields[nCont,3])      		      ,; //| Titulo do Campo
				 		   AllTrim( aCampos:aFields[nCont,1])                 ,; //| X3_Campo
						   X3Picture(aCampos:aFields[nCont][1])	              ,; //| picture
						   TamSX3(aCampos:aFields[nCont][1])[1]				  ,; //| tamanho
						   TamSX3(aCampos:aFields[nCont][1])[2]				  ,; //| decimal
						   GetSx3Cache(aCampos:aFields[nCont][1],"X3_VALID")  ,; //| valid
                       	   GetSx3Cache(aCampos:aFields[nCont][1],"X3_USADO")  ,; //| usado
						   GetSx3Cache(aCampos:aFields[nCont][1],"X3_TIPO")   ,; //| tipo
						   GetSx3Cache(aCampos:aFields[nCont][1],"X3_ARQUIVO"),; //| arquivo
						   GetSx3Cache(aCampos:aFields[nCont][1],"X3_CONTEXT")}) //| context 
							 
		
	Next nCont

	aHeaderDVT := Aclone(aHeader)
Else
	aHeader := Aclone(aHeaderDVT)
EndIf

If Len(aColsDVT)  > 0
	aCols := aClone(aColsDVT)
	Aeval( aCols, {|x| x[Len(x)] := .F. }) // Os Itens do aCols	nao poderao estar deletados 
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem de uma linha em branco no aCols.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd(aCols,Array(Len(aHeader)+1))
	For ny := 1 to Len(aHeader)
		aCols[1][ny] := CriaVar(aHeader[nY][2])
		aCols[1][Len(aHeader)+1] := .F.
	Next ny
	GDFieldPut('DVT_ITEM',StrZero(1,Len(DVT->DVT_ITEM)),1)
EndIf
If !l460Auto
	DEFINE MSDIALOG oDlgEsp FROM 94 ,104 TO 310,590 TITLE STR0040 Of oMainWnd PIXEL //"Tipos de Veiculo"

		oGetDados := MSGetDados():New(30,2,105,243,nOpcao,'A460TipLOk()' ,'AllwaysTrue','+DVT_ITEM'   ,IIf(nOpcao==3.Or.nOpcao==4,.T.,.F.),,,,100)

		//-- Qdo for agendamento, nao permite manutencao na getdados
		If lAgend
			oGetDados:oBrowse:bAdd    := { || .f. } // Nao Permite a inclusao de Linhas
			oGetDados:oBrowse:bDelete := { || .f. } // Nao Permite a deletar Linhas
			oGetDados:oBrowse:AAlter  := {}         // Nao Permite a alteracao de campo
		EndIf

		@ 6  ,116 SAY '' Of oDlgEsp PIXEL SIZE 26 ,9
		@ 18 ,3   SAY STR0039 Of oDlgEsp PIXEL SIZE 56 ,9 //"No.Solic.Coleta : "
		@ 18 ,45  SAY cNumSol Of oDlgEsp PIXEL SIZE 50 ,9

		If !Empty(cNumCot)
			@ 18 ,90  SAY STR0038 Of oDlgEsp PIXEL SIZE 56 ,9 //"No.Cotacao Frete : "
			@ 18 ,140 SAY cNumCot Of oDlgEsp PIXEL SIZE 50 ,9
		EndIf

		//-- Esta Funcao corrige uma falha da GetDados ao mostrar os itens deletados
		TMSA011AjuMin(aColsDVT, aCols)

	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||IIF(oGetDados:TudoOk(),(nOpc:=1,oDlgEsp:End()),(nOpc:=0))},{||oDlgEsp:End()} )
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas pela rotina de inclusao automatica     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MsGetDAuto(aAutoTpVei,"A460TipLOk",{|| .T.},/*aAutoCab*/,nOpcao)
		nOpc := 1
	EndIf
EndIf

If nOpc == 1
	aColsDVT := aClone(aCols)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura as Variaveis da GetDados Anterior                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestInter()

If !l460Auto
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A460TipLOk³ Autor ³Patricia A. Salomao    ³ Data ³13.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao das linhas digitadas na GetDados de Tp. de Veiculo³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A460TipLOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA460 / TMSA040                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A460TipLOk()

Local lRet := .T.

l460Auto := If (Type("l460Auto") == "U",.F.,l460Auto)
//-- Analisa se ha itens duplicados na GetDados
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	lRet := GDCheckKey( { 'DVT_TIPVEI' } , 4,,,!l460Auto )
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A460VerTpV³ Autor ³Patricia A. Salomao    ³ Data ³13.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Visualiza os Tipos de Veiculo informados na Coleta          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A460VerTpVei()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³EXPC1 - Opcao Selecionada                                   ³±±
±±³          ³EXPC2 - Filial de Origem                                    ³±±
±±³          ³EXPC3 - No. da Solicitacao de Coleta                        ³±±
±±³          ³EXPC4 - No. da Cotacao de Frete                             ³±±
±±³          ³EXPC5 - Origem (1-Solic.Coleta / 2-Cotacao / 3-Nota Fiscal) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Os Arrays aHeaderDVT e aColsDVT ja' deverao estar declarados³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA460 / TMSA040                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function a460VerTpVei(nOpcx, cFilOri, cNumSol, cNumCot, cOrigem)

Local cSeek     := ''
Local nCntFor   := 0
Local cSolicit  := ""
Local nPosItem  := 0
Local nCont     := 0
Local aCampos   := FwFormStruct(2,"DVT")

Default nOpcx   := 3
Default cFilOri := ""
Default cNumSol := ""
Default cNumCot := ""
Default cOrigem := ""

If FunName() == 'TMSA460'
	//-- Se for inclusao de Solic. Coleta com No. de Cotacao Informado, a chave para procura no DVT
	//-- sera' : No.de Solicitacao em branco + Cotacao + Origem "1"
	If nOpcx==3 .And. !Empty(M->DT5_NUMCOT)
		cSolicit := CriaVar('DT5_NUMSOL',.F.)
	EndIf
EndIf

If Len(aHeaderDVT) == 0
	For nCont := 1 to Len(aCampos:aFields)

		AAdd(	aHeaderDVT, { AllTrim( aCampos:aFields[nCont,3])      			  ,; //| Titulo do Campo
					 		   AllTrim( aCampos:aFields[nCont,1])                 ,; //| X3_Campo
							   X3Picture(aCampos:aFields[nCont][1])	              ,; //| picture
							   TamSX3(aCampos:aFields[nCont][1])[1]				  ,; //| tamanho
							   TamSX3(aCampos:aFields[nCont][1])[2]				  ,; //| decimal
							   GetSx3Cache(aCampos:aFields[nCont][1],"X3_VALID")  ,; //| valid
                        	   GetSx3Cache(aCampos:aFields[nCont][1],"X3_USADO")  ,; //| usado
							   GetSx3Cache(aCampos:aFields[nCont][1],"X3_TIPO")   ,; //| tipo
							   GetSx3Cache(aCampos:aFields[nCont][1],"X3_ARQUIVO"),; //| arquivo
							   GetSx3Cache(aCampos:aFields[nCont][1],"X3_CONTEXT")}) //| context 
							 
		
	Next nCont
EndIf

nPosItem := Ascan(aHeaderDVT, {|x| AllTrim(x[2]) == 'DVT_ITEM'})

DVT->(dbSetOrder(1))
If DVT->(MsSeek(cSeek:=xFilial("DVT") + cFilOri + cNumSol + cNumCot + cOrigem ))
	aColsDVT := {}
	Do While DVT->(!Eof()) .And. DVT->(DVT_FILIAL+DVT_FILORI+DVT_NUMSOL+DVT_NUMCOT+DVT_ORIGEM) == cSeek
		AAdd(aColsDVT,Array(Len(aHeaderDVT)+1))
		For nCntFor := 1 To Len(aHeaderDVT)
			If	aHeaderDVT[nCntFor,10] != "V"
				aColsDVT[Len(aColsDVT),nCntFor]:=DVT->(FieldGet(FieldPos(aHeaderDVT[nCntFor,2])))
			Else
				aColsDVT[Len(aColsDVT),nCntFor]:=CriaVar(aHeaderDVT[nCntFor,2])
			EndIf
		Next nCntFor

		aColsDVT[Len(aColsDVT),Len(aHeaderDVT)+1]:=.F.

		DVT->(dbSkip())
	EndDo
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem de uma linha em branco no aCols.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsDVT := {}
	AAdd(aColsDVT,Array(Len(aHeaderDVT)+1))
	For nCntFor := 1 to Len(aHeaderDVT)
		aColsDVT[1][nCntFor] := CriaVar(aHeaderDVT[nCntFor][2])
		aColsDVT[1][Len(aHeaderDVT)+1] := .F.
	Next nCntFor
	aColsDVT[1][nPosItem] := StrZero(1,Len(DVT->DVT_ITEM))
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A460AtuDVT³ Autor ³Patricia A. Salomao    ³ Data ³13.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava GetDados de Tipos de Veiculo                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A460AtuDVT()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³EXPC1 - Opcao Selecionada                                   ³±±
±±³          ³EXPC2 - Filial de Origem                                    ³±±
±±³          ³EXPC3 - No. da Solicitacao de Coleta                        ³±±
±±³          ³EXPC4 - No. da Cotacao de Frete                             ³±±
±±³          ³EXPC5 - Origem (1-Solic.Coleta/Cotacao / 2-Nota Fiscal)     ³±±
±±³          ³EXPL1 - Acao a ser executada ( 1-Inclusao / 2-Exclusao )    ³±±
±±³          ³EXPC6 - No  da Solicitacao de Coleta p/ Pesquisa            ³±±
±±³          ³EXPC7 - No. da Cotacao de Frete p/ Pesquisa                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Os Arrays aHeaderDVT e aColsDVT ja deverao estar preenchidos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA460 / TMSA040                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function a460AtuDVT(nOpcx, cFilOri, cNumSol, cNumCot, cOrigem, cAcao, cSolicit, cCotacao)

Local nPosCampo    := 0
Local nPosTipVei   := 0
Local nY           := 0
Local nX           := 0
Local cSeek        := ""
Local lCallCot     := ( Type("M->DT4_NUMSOL") <> "U" .And. Type("M->DT5_NUMSOL") <> "U" )
Default cFilOri    := ""
Default cNumSol    := ""
Default cNumCot    := ""
Default cOrigem    := ""
Default cAcao      := '1' 
Default cSolicit   := cNumSol
Default cCotacao   := cNumCot

//-- Se Funcao estiver sendo chamada pelo programa TMSA460 (Solicitacao de Coleta)
If FunName() == 'TMSA460'
	//-- Se for inclusao de Solic. Coleta com No. de Cotacao Informado, a chave para procura no DVT
	//-- sera' : No.de Solicitacao em branco + No. Cotacao de Frete + Origem "1"
	If nOpcx==3 .And. !Empty(M->DT5_NUMCOT)
		cSolicit := CriaVar('DT5_NUMSOL',.F.)
	EndIf
EndIf

//-- Se Funcao estiver sendo chamada pelo programa TMSA040 (Cotacao de Frete)
If FunName() == 'TMSA040'  
	//-- Se a Cotacao de Frete estiver gerando Solic.de Coleta automaticamente, a chave 
	//-- para procura no DVT sera' :  No.Cotacao de Frete + No. de Solicitacao em branco + Origem "1"
	If nOpcx ==3 .And. lCallCot 
		cSolicit := CriaVar('DT5_NUMSOL',.F.)
	EndIf
	//-- Se for inclusao de Cotacao com Solic. Coleta INFORMADA, a chave para procura no DVT
	//-- sera' : No.Cotacao em branco + No. de Solicitacao + Origem "1"
	If nOpcx==3 .And. !Empty(M->DT4_NUMSOL)
		cCotacao := CriaVar('DT4_NUMCOT',.F.)
	EndIf
EndIf

If FindFunction("ALIASINDIC") .And. AliasInDic('DVT') .And. TMSCFec()
	If cAcao == '1' //-- Inclusao
		nPosCampo  := Ascan(aHeaderDVT, {|x| AllTrim(x[2]) == 'DVT_ITEM'   } )
		nPosTipVei := Ascan(aHeaderDVT, {|x| AllTrim(x[2]) == 'DVT_TIPVEI' } )
		DVT->(dbSetOrder(1))
		For nX := 1 To Len(aColsDVT)
			If !aColsDVT[nX][Len(aColsDVT[nX])] .And. !Empty(aColsDVT[nX][nPosTipVei])
				If DVT->(!MsSeek(xFilial("DVT") + cFilOri + cSolicit + cCotacao + cOrigem + aColsDVT[nX][nPosCampo]))
					RecLock("DVT", .T.)
				Else
					RecLock("DVT", .F.)
				EndIf
				For nY:= 1 To Len(aHeaderDVT)
					If aHeaderDVT[nY][10] # "V"
						DVT->(FieldPut(FieldPos(Trim(aHeaderDVT[nY][2])),aColsDVT[nX][nY]))
					EndIf
					DVT->DVT_FILIAL := xFilial('DVT')
					DVT->DVT_FILORI := cFilOri
					DVT->DVT_NUMSOL := cNumSol
					DVT->DVT_NUMCOT := cNumCot
					DVT->DVT_ORIGEM := cOrigem // 1 = Solic.Coleta / Cotacao
				Next
				DVT->(MsUnLock())
			Else
				If DVT->(MsSeek(xFilial("DVT") + cFilOri + cSolicit + cCotacao + cOrigem + aColsDVT[nX][nPosCampo]))
					RecLock("DVT", .F.)
					dbDelete()
					DVT->(MsUnLock())
				EndIf
			EndIf
		Next
	Else
		DVT->(dbSetOrder(1))
		DVT->(MsSeek(cSeek:=xFilial('DVT')+cFilOri+cSolicit+cCotacao+cOrigem))
		Do While !DVT->(Eof()) .And. DVT->(DVT_FILIAL+DVT_FILORI+DVT_NUMSOL+DVT_NUMCOT+DVT_ORIGEM) == cSeek
			RecLock("DVT", .F.)
			dbDelete()
			DVT->(MsUnLock())
			DVT->(dbSkip())
		EndDo
	EndIf
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA460Cot³ Autor ³ Patricia A. Salomao   ³ Data ³14.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao Chamada pela Consulta SXB (DVN) do campo DT5_NUMCOT; ³±±
±±³          ³Apresentar Tela contendo as Cotacoes de Frete do Solicitante³±±
±±³          ³informado                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA460Cot()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA460Cot()

Local cCadastro  := STR0037 //"Cotacoes de Frete"
Local aRotOld    := aClone(aRotina)
Local cFiltro1   := ""
Local aRotina    := {}

Private nOpcSel  := 0
Private l040Auto := .F. //-- Variavel utilizada pelo TMSA040 na Visualizacao da Cotacao

aRotina	:= {	{ STR0003 , "TMSA040Mnt", 0, 2},; 			//"Visualizar"
				{ STR0036 , "TMSConfSel", 0, 2,,,.T.} } 	//"Confirmar"

DT4->(dbSetOrder(2))

If DT4->(MsSeek(xFilial("DT4")+M->DT5_CODSOL))

	cFiltro1 := '"'+xFilial("DT4")+M->DT5_CODSOL+'"'

	MaWndBrowse(0,0,300,600,cCadastro,"DT4",,aRotina,,cFiltro1,cFiltro1,.T.)

Else
	Help('',1,'TMSA46019') //-- Nao existem Cotacoes de Frete para este Solicitante ...
EndIf

aRotina := aClone(aRotOld)

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA460Imp³ Autor ³ Eduardo de Souza      ³ Data ³ 13/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chama o programa impressao do cliente de acordo com a Soli- ³±±
±±³          ³citacao de coleta posicionada.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1 = Imprime independente do paramentro                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA460Imp( cAlias, nReg, nOpcx, aStruct, lImprime )
Local cFilOri    := ""
Local cNumSol    := ""
Local lRTMSR02   := ExistBlock("RTMSR02")
Local lTMSR580   := FindFunction("TMSR580")
Local lImp       := .F.

Default lImprime := .T.

cFilOri  := DT5->DT5_FILORI
cNumSol  := DT5->DT5_NUMSOL

Pergunte("RTMR02",.F.,,,,.F.)

If lImprime

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TRATAMENTO PARA IMPRESSAO - RELATORIO ESPECIFICO, CUSTOMIZADO ³
	//³PELO USUARIO - FONTE RTMSR02.PRW                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRTMSR02

		//--Atualiza os valores do pergunte conforme registro posicionado no Browse:
		SetMVValue("RTMR02","MV_PAR01",cNumSol)
		SetMVValue("RTMR02","MV_PAR02",cNumSol)
		SetMVValue("RTMR02","MV_PAR03",IIf( DT6->DT6_FIMP <> "1", 1, 2))
		
		//--Executa o relatorio especifico, passando como parametros as perguntas selecionadas...
		ExecBlock("RTMSR02",.F.,.F.)
		lImp:= .T.

	ElseIf lTMSR580 .And. !lImp

		//--Atualiza os valores do pergunte conforme registro posicionado no Browse:
		SetMVValue("TMR580","MV_PAR01",cNumSol)
		DT6->( DbSetOrder(1) )
		If DT6->( DbSeek( xFilial("DT6") + cFilOri + Padr( cNumSol, Len(DT6->DT6_DOC) ) + CSERIECOL ) )
			SetMVValue("TMR580","MV_PAR02",IIf( DT6->DT6_FIMP <> "1", 1, 2)) //-- Impressao ou Reimpressao
		EndIf

		//--Executa relatorio padrao:
		TMSR580( .T. )

	EndIf
EndIf

//--Restaura o ambiente e volta para o
//--grupo de perguntas padrao da rotina

If IsInCallStack( 'TMSAF05' )
	//--Caso a rotina esteja sendo acionada a 
	//--partir do programa de manutencao de agendamentos:
	Pergunte( "TMAF05",.F. )
Else
	//--Caso a rotina esteja sendo acionada a 
	//--partir do programa de manutencao de solicitacoes de coleta:
	Pergunte( "TMA460",.F. )
EndIf

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA460Doc³ Autor ³ Eduardo de Souza      ³ Data ³ 18/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de Visualizacao do Docto atraves da Solicitacao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA460Doc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA460Doc(cFilOri,cNumSol)

Local aAreaDTC := DTC->(GetArea())
Local nCont    := 0
Local cAliasQry:= ""

Private l050Auto := .F.

SaveInter() //-- Salva Area

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

cAliasQry := GetNextAlias()
cQuery := " SELECT DISTINCT DTC_LOTNFC "
cQuery += "   FROM " + RetSqlName("DTC")
cQuery += "   WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
cQuery += "     AND DTC_FILORI = '" + cFilOri + "' "
cQuery += "     AND DTC_NUMSOL = '" + cNumSol + "' "
cQuery += "     AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasQry, .T., .T.)
Do While (cAliasQry)->( !Eof() )
	nCont++
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->( DbCloseArea() )

//Diversas Notas Fiscais para a mesma Solicitação de Coleta

If nCont > 1 
	TMSDocXNf(,,,cFilOri,cNumSol,.T.)
Else
	DTC->(DbSetOrder(8))
	If DTC->(MsSeek(xFilial("DTC")+cFilOri+cNumSol))
		cCadastro := STR0035 //"Notas Fiscais do Cliente - Visualizar"
		TMSA050Mnt("DTC",DTC->(Recno()),2)
	EndIf
EndIf

//-- Restaura Area
RestInter()
RestArea( aAreaDTC )
//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA460Oc1³ Autor ³Valdemar Roberto       ³ Data ³ 15.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra Operacoes                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA460Oc1()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA460                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa460Oc1()

Local aAreaDT6 := DT6->(GetArea())
Local aArea    := GetArea()

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

DT6->(dbSetOrder(1))
If DT6->(MsSeek(xFilial("DT6")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
	Tmsa500Tr1()
Endif

RestArea(aAreaDT6)
RestArea(aArea)

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA460Oc2³ Autor ³Valdemar Roberto       ³ Data ³ 15.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra Ocorrencia e Operacoes                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA460Oc2()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA460                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa460Oc2()

Local aAreaDT6 := DT6->(GetArea())
Local aArea    := GetArea()

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

DT6->(dbSetOrder(1))
If DT6->(MsSeek(xFilial("DT6")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
	Tmsa500Tr3()
Endif

RestArea(aAreaDT6)
RestArea(aArea)

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA460Cli ³ Autor ³ Eduardo de Souza    ³ Data ³ 24/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica quem sera o Cliente de Calculo                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA460Cli()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Cliente Devedor                                    ³±±
±±³          ³ ExpC2 - Loja Devedor                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA460Cli(cCliDev,cLojDev)

Local aAreas := {SA1->(GetArea()),GetArea()}

Default cCliDev := ''
Default cLojDev := '' 

If DT5->(ColumnPos("DT5_CLIDEV")) > 0 .And. !Empty(M->DT5_CLIDEV) .And. !Empty(M->DT5_LOJDEV)
	cClidev := M->DT5_CLIDEV
	cLojDev := M->DT5_LOJDEV
Else
	If SuperGetMV("MV_CLICOT",Nil,.F.)
		//-- Utiliza o cliente informado no Cadastro de Solicitantes
		DUE->( DbSetOrder( 1 ) )
		If DUE->( MsSeek( xFilial('DUE') + M->DT5_CODSOL, .F. ) )
			If !Empty(DUE->DUE_CODCLI) .And. !Empty(DUE->DUE_LOJCLI)
				cCliDev := DUE->DUE_CODCLI+DUE->DUE_LOJCLI
				lCliGen := .F.
			Else
				cCliDev := GetMV('MV_CLIGEN')
			EndIf
		Else
			cCliDev := GetMV('MV_CLIGEN')
		EndIf
		//-- Utiliza o cliente generico.
	Else
		cCliDev := GetMV('MV_CLIGEN')
	EndIf

	SA1->( DbSetOrder( 1 ) )
	If	SA1->( ! MsSeek( xFilial('SA1') + cCliDev, .F. ) )
		Help('',1,'TMSA04005',,": " + cCliDev,4,1)	//-- Cliente generico nao encontrado  (SA1)
		Return( .F. )
	EndIf

	cCliDev := SA1->A1_COD
	cLojDev := SA1->A1_LOJA
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA460Lib ³ Autor ³ Eduardo de Souza    ³ Data ³ 27/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Liberacao da Solicitacao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA460Lib()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA460                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA460Lib(lLibDT5,lAutoDDU)

Local dLimLib   := dDataBase
Local aArea     := GetArea()
Local nValSol   := 0
Local nLimCred  := 0
Local nMoeda    := 0
Local nSalSolL  := 0
Local nSalSol   := 0
Local nSalDup	:= 0
Local nSalDupM	:= 0
Local nValAtraso:= 0
Local nOpca 	:= 0
Local nSalvEmp  := 0
Local cDescri   := ""
Local oDlg
Local nMCusto   := 0
Local nMCustoCli:= 0
Local nDecs		:= 0
Local aSaldos
Local nSalFin   := 0
Local nSalFinM  := 0
Local nLcFin    := 0
Local nLcFinM   := 0
Local aCols     :={}
Local aHeader   :={}
Local cMoeda    := ""
Local cCodSol   := DT5->DT5_CODSOL
Local cNumSol   := DT5->DT5_NUMSOL
Local nQtdVol   := 0
Local nQtdUni	:= 0
Local nPeso     := 0
Local nPesoM3   := 0
Local nValMer   := 0
Local lCliDev   := DT5->(ColumnPos("DT5_CLIDEV")) > 0 .And. !Empty(DT5->DT5_CLIDEV) .And. !Empty(DT5->DT5_LOJDEV)
Local lRet      := .t.
Local lDumM3    := DUM->(ColumnPos("DUM_METRO3")) > 0
Local nMetro3   := 0
Local nMoedaC   := VAL(SuperGetMv("MV_MCUSTO"))
Local cCredCli  := SuperGetMv("MV_CREDCLI",.F.,"")

Default lLibDT5  := .t. //-- Define Se Libera DT5 Ou Somente Visualiza Situação Do Crédito
Default lAutoDDU := .f. //-- Define Se TMSA029 Vai Utilizar Rotina Em Modo Automátina

//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
If !TMSAVerAge("3",,,,,,,,,DT5->DT5_FILORI,DT5->DT5_NUMSOL,,"2",.T.,.T.,,)
	Return .F.
EndIf

lLibDT5  := iIf(ValType(lLibDT5)  <> 'L', .t. , lLibDT5  )
lAutoDDU := iIf(ValType(lAutoDDU) <> 'L', .f. , lAutoDDU )
l460Auto := iIf(ValType(l460Auto) <> 'L', .f. , l460Auto )	//-- Assume .f. Para Chamadas Externas Com a Variável Não Declarada

//-- Altera Variavel l460Auto Quando Solicitado Pelo TMSA029
If lAutoDDU
	l460Auto := .t.
EndIf 

If DT5->DT5_STATUS <> StrZero(6,Len(DT5->DT5_STATUS))
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help(" ",1,"TMSA46022") //-- "Solicitação não está bloqueada"
	Return( .F. )
EndIf

// Tratamento Para Nova Rotina Liberação TMSA029
If !l460Auto .And. lTmsa029 .And. !IsInCallStack("TMSA029") .And. Tmsa029Use("TMSA460")
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help(" ",1,"TMSA46024") //-- "Utilize a Rotina TMSA029 Para Liberação!"
	Return( .F. )
EndIf

If lClidev  //Utiliza o  Cliente Devedor do frete informado
	SA1->(DbSetOrder(1))
	If !SA1->(MsSeek(xFilial("SA1")+DT5->DT5_CLIDEV+DT5->DT5_LOJDEV))
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( .F. )
	EndIf
Else
	//-- Utiliza o cliente informado no Cadastro de Solicitantes
	DUE->( DbSetOrder( 1 ) )
	If DUE->( MsSeek( xFilial('DUE') + DT5->DT5_CODSOL, .F. ) )
		If Empty(DUE->DUE_CODCLI) .Or. Empty(DUE->DUE_LOJCLI)
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return( .F. )
		EndIf
		SA1->(DbSetOrder(1))
		If !SA1->(MsSeek(xFilial("SA1")+DUE->DUE_CODCLI+DUE->DUE_LOJCLI))
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return( .F. )
		EndIf
	EndIf
EndIf

If !l460Auto
	nMCusto:= If (SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, nMoedaC )
	cMoeda := " "+Pad(SuperGetMv("MV_SIMB"+AllTrim(STR(nMCusto))),4)
	nDecs  := MsDecimais(nMcusto)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o tipo de analise a ser efetuado ( Filial ou Matriz )    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCredCli == "L" 
		nLimCred := SA1->A1_LC
		nSalDup  := SA1->A1_SALDUP
		nSalDupM := SA1->A1_SALDUPM
		nSalFin  := SA1->A1_SALFIN
		nLcFin   := SA1->A1_LCFIN
		nLcFinM  := SA1->A1_SALFINM
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Soma-se Todos os Limites de Credito do Cliente          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA1")
		dbSetOrder(1) 
		Iif(lClidev, dbSeek(xFilial("SA1")+DT5->DT5_CLIDEV), dbSeek(xFilial("SA1")+DUE->DUE_CODCLI))
		While ( !Eof() .And. xFilial("SA1") == SA1->A1_FILIAL .And.;
			Iif(lClidev, DT5->DT5_CLIDEV == SA1->A1_COD, DUE->DUE_CODCLI ==  SA1->A1_COD ))

			nMCustoCli := Iif(SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, nMoedaC )
			nLimCred += xMoeda(SA1->A1_LC,nMCustoCli,nMCusto,dDataBase)
			nSalDup  += SA1->A1_SALDUP
			nSalDupM += xMoeda(SA1->A1_SALDUPM,nMCustoCli,nMCusto,dDataBase)
			nSalFin  += SA1->A1_SALFIN
			nLcFin   += xMoeda(SA1->A1_LCFIN,nMCustoCli,nMCusto,dDataBase)
			nSalFinM += xMoeda(SA1->A1_SALFINM,nMCustoCli,nMCusto,dDataBase)
			dbSelectArea("SA1")
			dbSkip()
		EndDo
	EndIf
	nSalvEmp := SM0->(Recno())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Analisar o atraso de Todas as Filiais do Sistema                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SM0")
	dbSeek(cEmpAnt+IIf(!Empty(xFilial("SA1")),xFilial("SA1"),""))
	While !Eof() .and. M0_CODIGO == cEmpAnt
		If cCredCli == "L"
			nValAtraso += FtSomaAtr(FWGETCODFILIAL)
		Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			Iif(lClidev, dbSeek(xFilial("SA1")+DT5->DT5_CLIDEV), dbSeek(xFilial("SA1")+DUE->DUE_CODCLI))
			While ( !Eof() .And. xFilial("SA1")  == SA1->A1_FILIAL .And.;
				Iif(lClidev, DT5->DT5_CLIDEV == SA1->A1_COD, DUE->DUE_CODCLI ==  SA1->A1_COD ))
				nValAtraso += FtSomaAtr(FWGETCODFILIAL)
				dbSelectArea("SA1")
				dbSkip()
			EndDo
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Forca a saida quando o SE1 estiver compartilhado               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( xFilial("SE1") == Space(FWGETTAMFILIAL) .Or. !Empty(xFilial("SA1")))
			Exit
		EndIf
		dbSelectArea("SM0")
		dbSkip()
	EndDo
	dbSelectArea("SM0")
	dbGoto(nSalvEmp)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reposiciona o SA1                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA1")
	dbSetOrder(1)
	Iif(lClidev, dbSeek(xFilial("SA1")+DT5->DT5_CLIDEV+DT5->DT5_LOJDEV), dbSeek(xFilial("SA1")+DUE->DUE_CODCLI+DUE->DUE_LOJCLI))
	cDescri := Substr(SA1->A1_NOME,1,35)

	nValSol  := TM460SdSol(cCodSol,.F.,cNumSol)
	nSalSolL := TM460SdSol(cCodSol,.T.)
	nSalSol  := TM460SdSol(cCodSol,.F.)

	aSaldos	        	   := Array(_STRASALDOS)
	aSaldos[_LIMCREDM] 	:=	nLimCred
	aSaldos[_LIMCRED ] 	:= xMoeda(nLimCred,nMCusto,1)
	aSaldos[_SALDUPM ] 	:=	nSalDupM
	aSaldos[_SALDUP  ] 	:=	nSalDup
	aSaldos[_SALPEDLM] 	:=	nSalSolL
	aSaldos[_SALPEDL ] 	:=	xMoeda(nSalSolL,nMCusto,1)
	aSaldos[_MCOMPRAM] 	:=	SA1->A1_MCOMPRA
	aSaldos[_MCOMPRA ] 	:=	xMoeda(SA1->A1_MCOMPRA,nMCusto,1)
	aSaldos[_SALDOLCM] 	:= nLimCred-nSaldupM-nSalSolL
	aSaldos[_SALDOLC ] 	:= xMoeda(nLimCred-nSaldupM-nSalSolL,nMCusto,1)
	aSaldos[_MAIDUPLM] 	:=	SA1->A1_MAIDUPL
	aSaldos[_MAIDUPL ] 	:=	xMoeda(SA1->A1_MAIDUPL,nMCusto,1)
	aSaldos[_ITATUM  ] 	:=	xMoeda(nValSol,nMoeda,nMcusto)
	aSaldos[_ITATU   ] 	:=	xMoeda(nValSol,nMoeda,1)
	aSaldos[_PEDATUM ] 	:= nValSol
	aSaldos[_PEDATU  ]	:= xMoeda(nValSol ,nMCusto,1)
	aSaldos[_SALPEDM ]	:=	nSalSol
	aSaldos[_SALPED  ]	:= xMoeda(nSalSol ,nMCusto,1)
	aSaldos[_VALATRM ] 	:=	xMoeda(nValAtraso,1,nMCusto)
	aSaldos[_VALATR  ] 	:=	nValAtraso
	aSaldos[_LCFINM  ] 	:=	nLcFin
	aSaldos[_LCFIN   ] 	:= xMoeda(nLCFin,nMcusto,1)
	aSaldos[_SALFINM ] 	:=	nSalFinM
	aSaldos[_SALFIN  ] 	:=	nSalFin

	aHeader  := {STR0044,STR0045,STR0046+AllTrim(cMoeda),STR0044,STR0047} // "Descricao" ### "Valores" ### "Valores Em" ### "Posicao do Cliente"

	//Limite de Credito/"Tit.Protestados"/DT.ULT TIT
	AAdd(aCols,{STR0048,TRansform(aSaldos[_LIMCRED],PesqPict("SA1","A1_LC",17,1)),;
		TRansform(aSaldos[_LIMCREDM],PesqPict("SA1","A1_LC",17,nMcusto)),;
		STR0049,Space(02)+STR(SA1->A1_TITPROT,3)+Space(05)+;
		STR0050+Space(03)+DtoC(SA1->A1_DTULTIT)})

	// Saldo Titulos / Cheques Devolvidos/DT.ULT.CHQ
	AAdd(aCols,{STR0051,TRansform(aSaldos[_SALDUP],PesqPict("SA1","A1_SALDUP",17,1)),;
		TRansform(aSaldos[_SALDUPM],PesqPict("SA1","A1_SALDUPM",17,nMcusto)),;
		STR0052,Space(02)+STR(SA1->A1_CHQDEVO,3)+Space(05)+;
		STR0053+Space(03)+DtoC(SA1->A1_DTULCHQ)})

	// Solicitações Aprovadas/Maior Compra
	AAdd(aCols,{STR0054,TRansform(aSaldos[_SALPEDL],PesqPict("SA1","A1_SALPEDL",17,1)),;
		TRansform(aSaldos[_SALPEDLM],PesqPict("SA1","A1_SALPEDL",17,nMcusto)),STR0055,;
		Transform(aSaldos[_MCOMPRAM],PesqPict("SA1","A1_MCOMPRA",17,nMCusto))}) // Solicitações Aprovadas/Maior Compra

	// Saldo Lim Credito/Maior Duplicata
	AAdd(aCols,{STR0056,TRansform(aSaldos[_SALDOLC],PesqPict("SA1","A1_SALDUP",17,1)),;
		TRansform(aSaldos[_SALDOLCM],PesqPict("SA1","A1_SALDUPM",17,nMcusto)),;
		STR0057,Transform(aSaldos[_MAIDUPLM],PesqPict("SA1","A1_MAIDUPL",17,nMCusto))}) // Saldo Lim Credito/Maior Duplicata

	// Item Solicitação Atual/Media de Atraso
	AAdd(aCols,{STR0058,TRansform(aSaldos[_ITATU],PesqPict("SA1","A1_SALDUP",17,1)),;
		TRansform(aSaldos[_ITATUM],PesqPict("SA1","A1_SALDUP",17,nMcusto)),;
		STR0059,Space(14)+Transform(SA1->A1_METR,PesqPict("SA1","A1_METR",7))+Space(04)+;
		STR0060}) // Item Pedido Atual/Media de Atraso/Dias

	AAdd(aCols,{"","","",;
		STR0061,Space(10)+DtoC(SA1->A1_VENCLC)}) //Pedido Atual/ Vencto.Lim.Credito

	// Saldo de Pedidos / Data Limite Liberação	
	AAdd(aCols,{STR0062,TRansform(aSaldos[_SALPED],PesqPict("SA1","A1_SALPED",17,1)),;
		TRansform(aSaldos[_SALPEDM],PesqPict("SA1","A1_SALPED",17,nMcusto)),;
		STR0063,Space(10)+DtoC(dLimLib)}) // Saldo de Pedidos / Data Limite Liberação

	//Lim. de Cred. Secundario/Atraso Atual
	AAdd(aCols,{STR0064,TRansform(aSaldos[_LCFIN],PesqPict("SA1","A1_LC",17,1)),;
		TRansform(aSaldos[_LCFINM],PesqPict("SA1","A1_LC",17,nMcusto)),;
		STR0065,TRansform(aSaldos[_VALATR],PesqPict("SA1","A1_SALDUP",17,1))}) //Lim. de Cred. em Cheque/Atraso Atual

	AAdd(aCols,{STR0066,TRansform(aSaldos[_SALFIN],PesqPict("SA1","A1_SALDUP",17,1)),;
		TRansform(aSaldos[_SALFINM],PesqPict("SA1","A1_SALDUP",17,nMcusto)),,,}) // Saldo em Cheques

	DEFINE MSDIALOG oDlg FROM  125,3 TO 430,608 TITLE STR0067 PIXEL    //"Libera‡„o de Cr‚dito"

	@ 003, 004  TO 033, 299 LABEL "" OF oDlg  PIXEL
	@ 130, 004  TO 150, 085 LABEL "" OF oDlg  PIXEL

	DEFINE SBUTTON FROM 134, 242 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 134, 272 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	@ 135, 010 BUTTON STR0068 SIZE 34,11 FONT oDlg:oFont ACTION (cCadastro:=STR0068,A030Visual("SA1",SA1->(RecNo()),1),cCadastro:= STR0001 ) OF oDlg PIXEL   	//"Cliente"
	@ 135, 045 BUTTON STR0069 SIZE 34,11 FONT oDlg:oFont ACTION (cCadastro:=STR0001,TMSA460Mnt("DT5",DT5->(Recno()),2),cCadastro:= STR0001 ) OF oDlg PIXEL 	//"Solicitação"

	@ 010, 008 SAY STR0069 + " :"		SIZE 26, 7 OF oDlg PIXEL   //"Solicitacao :"
	@ 010, 040 SAY DT5->DT5_NUMSOL		SIZE 30, 7 OF oDlg PIXEL
	@ 010, 075 SAY STR0070 + " :"		SIZE 35, 7 OF oDlg PIXEL   //"Cond.Pagto. :"
	@ 010, 105 SAY SA1->A1_COND			SIZE 09, 7 OF oDlg PIXEL
	@ 010, 120 SAY STR0071 + " :"		SIZE 21, 7 OF oDlg PIXEL   //"Risco :"
	@ 010, 135 SAY SA1->A1_RISCO		SIZE 11, 7 OF oDlg PIXEL
	@ 010, 150 SAY STR0046+" "+SuperGetMv("MV_SIMB"+Alltrim(STR(nMCusto)))  SIZE 50, 7 OF oDlg PIXEL //"Valores em "
	@ 010, 220 SAY STR0072 + " :"		SIZE 27, 7 OF oDlg PIXEL   //"Bloqueio :"
	@ 010, 250 SAY STR0073 				SIZE 83, 7 OF oDlg PIXEL

	@ 021, 008 SAY STR0068 + " :"		SIZE 23, 7 OF oDlg PIXEL   //"Cliente :"
	@ 021, 032 SAY cDescri				SIZE 96, 7 OF oDlg PIXEL
	@ 021, 153 SAY STR0063 + " :"		SIZE 64, 7 OF oDlg PIXEL   //"Data Limite Libera‡Æo :"
	@ 020.4, 230 MSGET dLimLib			SIZE 52, 7 OF oDlg PIXEL	HASBUTTON

	oLbx := RDListBox(2.48, .5, 295, 95, aCols, aHeader,{65,50,50,55,69})

	ACTIVATE MSDIALOG oDlg CENTERED
Else
	nOpca := 1
EndIf

If nOpca == 1
	If lLibDT5 //-- Define Se Libera DT5 Ou Somente Visualiza Situação Do Crédito

		RecLock("DT5",.F.)
		DT5->DT5_STATUS := StrZero(1,Len(DT5->DT5_STATUS)) //-- Em Aberto
		DT5->DT5_USRLIB := RetCodUsr()
		DT5->DT5_DATLIB := dDataBase
		DT5->DT5_HORLIB := StrTran(Left(Time(),5),":","")
		MsUnLock()
		DUM->(dbSetOrder(1))
		If DUM->(MsSeek(xFilial('DUM')+DT5->DT5_FILORI+DT5->DT5_NUMSOL))
			While DUM->(!Eof()) .And. DUM->DUM_FILIAL + DUM->DUM_FILORI + DUM->DUM_NUMSOL == xFilial('DUM')+DT5->DT5_FILORI+DT5->DT5_NUMSOL
				nQtdVol += DUM->DUM_QTDVOL
				nQtdUni += DUM->DUM_QTDUNI
				nPeso   += DUM->DUM_PESO
				nPesoM3 += DUM->DUM_PESOM3
				nValMer += DUM->DUM_VALMER
				nMetro3 += Iif(lDumM3,DUM->DUM_METRO3,0)
				DUM->(DbSkip())
			EndDo
		EndIf
		TMSA460GDc(nQtdVol,nPeso,nPesoM3,nValMer,nMetro3,nQtdUni)
	EndIf
Else
	lRet := .f.
EndIf

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TM460SdSol ³ Autor ³ Eduardo de Souza    ³ Data ³ 27/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Saldos da Solicitacao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TM460SdSol()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA460                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TM460SdSol(cCodSol,lLiberado,cNumSol)

Local cAliasQry := GetNextAlias()
Local cQuery    := ''
Local aArea     := GetArea()
Local nValTot   := 0
Local cFilBranco:= Space(FWGETTAMFILIAL)
Default cNumSol := ''

cQuery := " SELECT SUM(DT8_VALTOT) VALTOT "
cQuery += "   FROM " + RetSqlName("DT5") + " DT5 "
cQuery += "   JOIN " + RetSqlName("DT8") + " DT8 "
cQuery += "     ON DT8_FILIAL = '" + xFilial("DT8") + "' "
cQuery += "     AND DT8_FILORI = DT5_FILORI " 
cQuery += "     AND DT8_NUMCOT = DT5_NUMCOT "
cQuery += "     AND DT8_CODPAS = 'TF' "
cQuery += "     AND DT8.D_E_L_E_T_ = ' ' "
cQuery += "   WHERE DT5_FILIAL = '" + xFilial("DT5") + "' "
If !Empty(cNumSol)
	cQuery += "  AND DT5_NUMSOL    = '" + cNumSol + "' "
EndIf
cQuery += "     AND DT5_CODSOL    = '" + cCodSol + "' "
If lLiberado
	cQuery += "     AND DT5_STATUS <> '" + StrZero(6,Len(DT5->DT5_STATUS)) + "' "
Else
	cQuery += "     AND DT5_STATUS = '" + StrZero(6,Len(DT5->DT5_STATUS)) + "' "
EndIf
cQuery += "     AND DT5.D_E_L_E_T_ = ' ' "
If lLiberado
	cQuery += "     AND NOT EXISTS ( "
	cQuery += "     SELECT 1 FROM " + RetSqlName("DTC")
	cQuery += "       WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
	cQuery += "         AND DTC_FILORI = DT5_FILORI "
	cQuery += "         AND DTC_NUMSOL = DT5_NUMSOL "
	cQuery += "         AND DTC_FILDOC <> '" + cFilBranco + "' "
	cQuery += "         AND DTC_DOC    <> ' ' "
	cQuery += "         AND DTC_SERIE  <> ' ' "
	cQuery += "         AND D_E_L_E_T_ = ' ' ) "
EndIf
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .T.)
If (cAliasQry)->(!Eof())
	nValTot := (cAliasQry)->VALTOT
EndIf
(cAliasQry)->(DbCloseArea())

RestArea( aArea )

Return( nValTot )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA460GDc ³ Autor ³ Eduardo de Souza    ³ Data ³ 27/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera documento de transporte                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA460GDc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA460                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA460GDc(nQtdVol,nPeso,nPesoM3,nValMer,nMetro3,nQtdUni)

	Local lGrvStatus := .F.
	Local cCdrDes    := ''
	Local lTM460CPO  := ExistBlock('TM460CPO')
	Local cChvCol	 := ''
	Local nTam		 := 0
	Local lDT5Remet  := DT5->(ColumnPos("DT5_CLIREM")) > 0
	Local aArDUL     := DUL->(GetArea())

	Default nMetro3 := 0
	Default nQtdUni := 0

	If DT5->(FieldPos("DT5_CDRDCA")) > 0 .And. !Empty(DT5->DT5_CDRDCA)
		cCdrDes := DT5->DT5_CDRDCA
	Else
		cCdrDes := DT5->DT5_CDRORI
	EndIf

	//-- Grava documento de transporte
	DT6->(DbSetOrder(1))

	cChvCol	:= DToS(DT5->DT5_DATSOL)+ AllTrim(SM0->M0_CGC)+ StrZero(Val(PadR(DT5->DT5_NUMSOL,9)),9)
	nTam	:= Len(DT6->DT6_CHVCTE)
	cChvCol	:= cChvCol + replicate("0", nTam - len(cChvCol))

	If !DT6->(MsSeek(xFilial('DT6')+DT5->(DT5_FILDOC+DT5_DOC+DT5_SERIE)))
		RecLock('DT6',.T.)
		DT6->DT6_FILIAL := xFilial('DT6')
		DT6->DT6_FILDOC := DT5->DT5_FILDOC
		DT6->DT6_DOC    := DT5->DT5_DOC
		DT6->DT6_SERIE  := DT5->DT5_SERIE
		DT6->DT6_FIMP   := StrZero(0,Len(DT6->DT6_FIMP)) //--So grava nao impresso se o registro e novo
	Else
		RecLock('DT6',.F.)
	EndIf
	DT6->DT6_DATEMI := DT5->DT5_DATSOL
	DT6->DT6_HOREMI := DT5->DT5_HORSOL
	DT6->DT6_VOLORI := nQtdVol
	DT6->DT6_QTDVOL := nQtdVol
	DT6->DT6_QTDUNI := nQtdUni
	DT6->DT6_PESO   := nPeso
	DT6->DT6_PESOM3 := nPesoM3
	DT6->DT6_METRO3 := nMetro3
	DT6->DT6_VALMER := nValMer
	DT6->DT6_CDRORI := DT5->DT5_CDRORI
	DT6->DT6_CDRDES := cCdrDes
	DT6->DT6_CDRCAL := cCdrDes
	DT6->DT6_FILORI := DT5->DT5_FILORI
	DT6->DT6_DOCTMS := StrZero(1,Len(DT6->DT6_DOCTMS))
	DT6->DT6_BLQDOC := StrZero(2,Len(DT6->DT6_BLQDOC))
	DT6->DT6_SERTMS := StrZero(1,Len(DT6->DT6_SERTMS))
	DT6->DT6_TIPTRA := DT5->DT5_TIPTRA
	DT6->DT6_CHVCTE := cChvCol
	DT6->DT6_PESCOB := If(nPesoM3 > nPeso, nPesoM3, nPeso)
	DT6->DT6_USRGER := RetCodUsr()

	If lDT5Remet
		DT6->DT6_CLIREM := DT5->DT5_CLIREM  //| Adicionado em 28/06/2016|
		DT6->DT6_LOJREM := DT5->DT5_LOJREM
	EndIf

	DT6->DT6_CLIDES := DT5->DT5_CLIDES
	DT6->DT6_LOJDES := DT5->DT5_LOJDES
	DT6->DT6_CLIDEV := DT5->DT5_CLIDEV
	DT6->DT6_LOJDEV := DT5->DT5_LOJDEV
	DT6->DT6_NUMSOL := DT5->DT5_NUMSOL
	DT6->DT6_NCONTR := DT5->DT5_NCONTR //-- Número Contrato
	DT6->DT6_SERVIC := DT5->DT5_SERVIC //-- Serviço
	DT6->DT6_CODNEG := DT5->DT5_CODNEG //-- Código da Negociação
	
	//Utilizado para a geração do local de coleta do expedidor
	If !(Empty(DT5->DT5_SQEREM)) 
		DUL->(dbSetOrder(1))
		If DUL->(MsSeek(xFilial("DUL")+DT5->DT5_SQEREM))
			If !Empty(DUL->DUL_CODRED) .And. !Empty(DUL->DUL_LOJRED)
				DT6->DT6_CLIEXP := DUL->DUL_CODRED
				DT6->DT6_LOJEXP := DUL->DUL_LOJRED
			EndIf
		EndIf
	EndIf
	
	//Utilizado para o recedor da coleta
	If !(Empty(DT5->DT5_SQEDES))
		DUL->(dbSetOrder(1))
		If DUL->(MsSeek(xFilial("DUL")+DT5->DT5_SQEDES))
			If !Empty(DUL->DUL_CODRED) .And. !Empty(DUL->DUL_LOJRED)
				DT6->DT6_CLIREC := DUL->DUL_CODRED
				DT6->DT6_LOJREC := DUL->DUL_LOJRED
			EndIf
		EndIf
	EndIf
	
	DT6->DT6_SQEDES := DT5->DT5_SQEDES

	DT6->( MsUnLock() )

	If __lSX8
		ConfirmSX8()
	EndIf

	EvalTrigger()

	//-- Grava Movimento de Viagem
	DUD->(dbSetOrder(1))
	If !DUD->(MsSeek(xFilial('DUD')+DT5->(DT5_FILDOC+DT5_DOC+DT5_SERIE)))
		RecLock('DUD',.T.)
		lGrvStatus := .T.
	Else
		RecLock('DUD',.F.)
	EndIf
	DUD->DUD_FILIAL := xFilial('DUD')
	DUD->DUD_FILORI := DT5->DT5_FILORI
	DUD->DUD_FILDOC := DT5->DT5_FILDOC
	DUD->DUD_DOC    := DT5->DT5_DOC
	DUD->DUD_SERIE  := DT5->DT5_SERIE
	DUD->DUD_SERTMS := StrZero( 1, Len( DUD->DUD_SERTMS ) )
	DUD->DUD_TIPTRA := DT5->DT5_TIPTRA
	DUD->DUD_CDRDES := DT5->DT5_CDRORI

	If lGrvStatus
		DUD->DUD_STATUS := StrZero( 1, Len( DUD->DUD_STATUS ) ) //-- Em aberto
	EndIf

	//-- Grava o CEP de entrega
	DUD->DUD_CEPENT := TmsCEPEnt(,,DT5->DT5_CODSOL,DT5->DT5_SEQEND)

	If lTM460CPO
		ExecBlock("TM460CPO",.F.,.F.)
	EndIf

	DUD->( MsUnLock() )

	RestArea(aArDUL)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA460Prd ³ Autor ³ Eduardo de Souza    ³ Data ³ 04/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche os produtos padrao do solicitante                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA460Prd()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA460                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA460Prd()

Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local lNew      := .T.
Local nPos1     := GdFieldPos("DUM_CODPRO")
Local nCont     := 0
Local aArea     := GetArea()

l460Auto := If (Type("l460Auto") == "U",.F.,l460Auto)

Aeval( aCols, { |X| If( !Empty(x[nPos1]) .And. x[Len(aHeader)+1] == .F., nCont ++ , nCont ) } )

//-- Somente sera acrescentado os produtos se no aCols nao tiver nenhum produto informado.
If nCont == 0
	cQuery := " SELECT DVJ_CODPRO, DVJ_CODEMB "
	cQuery += "   FROM " + RetSqlName("DVJ")
	cQuery += "   WHERE DVJ_FILIAL = '" + xFilial("DVJ") + "' "
	cQuery += "     AND DVJ_CODSOL    = '" + M->DT5_CODSOL + "' "
	cQuery += "     AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .T.)
	While (cAliasQry)->(!Eof())
		If lNew
			lNew  := .F.
			aCols := {}
			n     := 1
		Else
			n++
		EndIf
		TMSA210Cols()
		GdFieldPut('DUM_ITEM',StrZero(n,Len(DUM->DUM_ITEM)),n)
		GdFieldPut('DUM_CODPRO',(cAliasQry)->DVJ_CODPRO,n)
		If ExistTrigger("DUM_CODPRO")
			RunTrigger(2,n,,If(!l460Auto,o1Get,Nil),"DUM_CODPRO")
		EndIf
		GdFieldPut('DUM_CODEMB',(cAliasQry)->DVJ_CODEMB,n)
		If ExistTrigger("DUM_CODEMB")
			RunTrigger(2,n,,If(!l460Auto,o1Get,Nil),"DUM_CODEMB")
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	If !l460Auto
		o1Get:oBrowse:nAt := 1
		o1Get:oBrowse:Refresh(.T.)
		o1Get:Refresh(.T.)
	EndIf
	(cAliasQry)->(DbCloseArea())
EndIf

RestArea( aArea )
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef(lVisualiza)

Local lRTMSR02  := ExistBlock("RTMSR02")
Local lTMSR580  := FindFunction("TMSR580")

Private aRotina := {}

Default lVisualiza := .F.

If !lVisualiza

    If IsInCallStack("TMSAF76") //| No Painel não tem alteração
    	aRotina:= {	    {STR0002, "AxPesqui"  , 0, 1,  0, .F.},; //"Pesquisar"
					    {STR0003, "TMSA460Mnt", 0, 2,  0, Nil},; //"Visualizar"
						{STR0004, "TMSA460Mnt", 0, 3,  0, Nil},; //"Incluir"
						{STR0006, "TMSA460Mnt", 0, 5,  0, Nil},; //"Excluir"
						{STR0041, "TMSA460Lib", 0, 6,  0, Nil},; //"Liberar"
						{STR0022, "TMSA460Imp", 0, 6,  0, Nil},; //"Impressao"
						{STR0077, 'TMSPRVENT' , 0, 12, 0, Nil},; //'Previsao de entrega'
						{STR0007, "TmsA460Leg", 0, 7,  0, .F.} } //"Legenda"

	ElseIf lRTMSR02 .Or. lTMSR580
		aRotina:= {	    {STR0002, "AxPesqui"  , 0, 1,  0, .F.},; //"Pesquisar"
						{STR0003, "TMSA460Mnt", 0, 2,  0, Nil},; //"Visualizar"
						{STR0004, "TMSA460Mnt", 0, 3,  0, Nil},; //"Incluir"
						{STR0005, "TMSA460Mnt", 0, 4,  0, Nil},; //"Alterar"
						{STR0006, "TMSA460Mnt", 0, 5,  0, Nil},; //"Excluir"
						{STR0041, "TMSA460Lib", 0, 6,  0, Nil},; //"Liberar"
						{STR0022, "TMSA460Imp", 0, 6,  0, Nil},; //"Impressao"
						{STR0077, 'TMSPRVENT' , 0, 12, 0, Nil},; //'Previsao de entrega'
						{STR0007, "TmsA460Leg", 0, 7,  0, .F.} } //"Legenda"
		
	Else
		aRotina := {    {STR0002, "AxPesqui",   0, 1,  0, .F.},; //"Pesquisar"
						{STR0003, "TMSA460Mnt", 0, 2,  0, Nil},; //"Visualizar"
						{STR0004, "TMSA460Mnt", 0, 3,  0, Nil},; //"Incluir"
						{STR0005, "TMSA460Mnt", 0, 4,  0, Nil},; //"Alterar"
						{STR0006, "TMSA460Mnt", 0, 5,  0, Nil},; //"Excluir"
						{STR0041, "TMSA460Lib", 0, 6,  0, Nil},; //"Liberar"
						{STR0077, "TMSPRVENT" , 0, 12, 0, Nil},; //'Previsao de entrega'
						{STR0007, "TmsA460Leg", 0, 7,  0, .F.}}  //"Legenda"
	EndIf
Else
		aRotina := {    {STR0003, "TMSA460Mnt", 0, 2,  0, Nil},; //"Visualizar"
						{STR0022, "TMSA460Imp", 0, 6,  0, Nil},; //"Impressao"
						{STR0007, "TmsA460Leg", 0, 7,  0, .F.}}  //"Legenda"
EndIf

If ExistBlock("TM460MNU")
	ExecBlock("TM460MNU",.F.,.F.)
EndIf

Return( aRotina )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MyTMSA460 ³ Autor ³ Microsiga             ³ Data ³04.06.2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de teste da rotina automatica do programa TMSA460     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar testes na rotina de    ³±±
±±³          ³Solicitacao de Coleta                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gestao de Transportes                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*
User Function MyTMSA460(nOpcx)

Local aCabec   := {}
Local aItens   := {}
Local aLinha   := {}

Local aVeic    := {}
Local aLinVeic := {}

Local aCuba    := {}
Local aLinCuba := {}

Default nOpcx  := 3

PRIVATE lMsErroAuto := .F.

If nOpcx == 3 //-- Inclusao

	AAdd(aCabec,{"DT5_DDD"   ,"11 "     ,Nil})
	AAdd(aCabec,{"DT5_TEL"   ,"97787196       "  ,Nil})
	AAdd(aCabec,{"DT5_CLIDES","000002"  ,Nil})
	AAdd(aCabec,{"DT5_LOJDES","01"      ,Nil})
	AAdd(aCabec,{"DT5_TIPTRA","1"       ,Nil})
	AAdd(aCabec,{"DT5_CLIDEV","000001"  ,Nil})
	AAdd(aCabec,{"DT5_LOJDEV","01"      ,Nil})

	AAdd(aLinha,{"DUM_ITEM"  ,"01"      ,Nil})
	AAdd(aLinha,{"DUM_CODPRO","PRODCALC"  ,Nil})
	AAdd(aLinha,{"DUM_CODEMB","CX"      ,Nil})
	AAdd(aLinha,{"DUM_QTDVOL",25        ,Nil})
	AAdd(aLinha,{"DUM_PESO"  ,1000      ,Nil})
	AAdd(aLinha,{"DUM_VALMER",2000      ,Nil})
	AAdd(aItens,aLinha)

	AAdd(aLinVeic,{"DVT_ITEM"    ,"01"  ,Nil})
	AAdd(aLinVeic,{"DVT_TIPVEI"  ,"01"  ,Nil})
	AAdd(aLinVeic,{"DVT_QTDVEI"  ,3     ,Nil})
	AAdd(aVeic,aLinVeic)

	AAdd(aLinCuba,{"DTE_QTDVOL"  ,25    ,Nil})
	AAdd(aLinCuba,{"DTE_ALTURA"  ,10    ,Nil})
	AAdd(aLinCuba,{"DTE_LARGUR"  ,10    ,Nil})
	AAdd(aLinCuba,{"DTE_LARGUR"  ,10    ,Nil})
	AAdd(aLinCuba,{"DTE_COMPRI"  ,10    ,Nil})
	AAdd(aCuba,aLinCuba)

ElseIf nOpcx == 4 //-- Alteracao

	AAdd(aCabec,{"DT5_FILIAL",xFilial("DT5")	,Nil})
	AAdd(aCabec,{"DT5_FILORI","01"           	,Nil})
	AAdd(aCabec,{"DT5_NUMSOL","000000013"    	,Nil})
	
	AAdd(aLinha,{"LINPOS"    ,"DUM_ITEM","01"})
	AAdd(aLinha,{"AUTDELETA" ,"N"       ,Nil})
	AAdd(aLinha,{"DUM_ITEM"  ,"01"      ,Nil})
	AAdd(aLinha,{"DUM_CODPRO","000001"  ,Nil})
	AAdd(aLinha,{"DUM_CODEMB","CX"      ,Nil})
	AAdd(aLinha,{"DUM_QTDVOL",33        ,Nil})
	AAdd(aLinha,{"DUM_PESO"  ,1000      ,Nil})
	AAdd(aLinha,{"DUM_VALMER",2000      ,Nil})
	AAdd(aItens,aLinha)

ElseIf nOpcx == 5 //-- Exclusao

	AAdd(aCabec,{"DT5_FILIAL",xFilial("DT5")            ,Nil})
	AAdd(aCabec,{"DT5_FILORI","01"                      ,Nil})
	AAdd(aCabec,{"DT5_NUMSOL","000000014"               ,Nil})
	AAdd(aCabec,{"DT5_OBSCAN","Observacao Cancelamento" ,Nil})

ElseIf nOpcx == 6 //-- Liberacao

	AAdd(aCabec,{"DT5_FILIAL",xFilial("DT5")	,Nil})
	AAdd(aCabec,{"DT5_FILORI","01"          	,Nil})
	AAdd(aCabec,{"DT5_NUMSOL","000000017"   	,Nil})

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Teste de Inclusao                                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MSExecAuto({|x,y,k,w,z| TMSA460(x,y,k,w,z)},aCabec,aItens,aVeic,aCuba,nOpcx)

If lMsErroAuto
	MostraErro()
Else
	Alert("Concluido com sucesso !!!")
EndIf

Return( .T. )

*/

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA460Gat ³ Autor ³ Marcelo Coutinho    ³ Data ³ 17/04/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche os campos gatilhados pelo DDD e Telefone          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA460Gat()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA460                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA460Gat(nOpcx,cDDDSol,cTelSol,cNumAtd,cIteAtd,cCodSol)

If nOpcx == 3 .And. !Empty( cCodSol ) .And. !Empty(cNumAtd) .And. !Empty(cIteAtd)

	M->DT5_CODSOL := Padr( cCodSol, TamSx3("DT5_CODSOL")[1] )
	M->DT5_DDD    := Padr( cDDDSol, TamSx3("DT5_DDD")[1] )
	M->DT5_TEL    := Padr( cTelSol, TamSx3("DT5_TEL")[1] )
	M->DT5_NUMATD := cNumAtd
	M->DT5_ITEATD := cIteAtd

	M->DT5_NOME   := Posicione('DUE', 1, xFilial('DUE')+M->DT5_CODSOL, 'DUE_NOME')
	M->DT5_END    := DUE->DUE_END
	M->DT5_BAIRRO := DUE->DUE_BAIRRO
	M->DT5_MUN    := DUE->DUE_MUN
	M->DT5_EST    := DUE->DUE_EST
	M->DT5_CEP    := DUE->DUE_CEP
	M->DT5_CONTAT := DUE->DUE_CONTAT
	M->DT5_TIPTRA := DUE->DUE_TIPTRA
	M->DT5_DESTPT := TMSValField("M->DT5_TIPTRA",.F.)
	M->DT5_HORCOI := DUE->DUE_HORCOI
	M->DT5_HORCOF := DUE->DUE_HORCOF

	TMSA460Val('M->DT5_CODSOL')
EndIf

Return .t.
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tmsa460Cor³ Autor ³ Leandro Paulino       ³ Data ³30/10/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Legenda do Browser                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tmsa460Cor()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA460	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA460Cor()
Local aRet := {}
Local aCores := {}

	AAdd(aCores,{"DT5_STATUS=='1'",'BR_VERDE'    }) // Em Aberto
	AAdd(aCores,{"DT5_STATUS=='2'",'BR_VERMELHO' }) // Indicada para Coleta
	AAdd(aCores,{"DT5_STATUS=='3'",'BR_AMARELO'  }) // Em Transito
	AAdd(aCores,{"DT5_STATUS=='4'",'BR_AZUL'     }) // Encerrada
	AAdd(aCores,{"DT5_STATUS=='5'",'BR_LARANJA'  }) // Encerrada
	AAdd(aCores,{"DT5_STATUS=='6'",'BR_CINZA'    }) // Bloqueada
	AAdd(aCores,{"DT5_STATUS=='7'",'BR_MARRON'   }) // Em Conferencia
	AAdd(aCores,{"DT5_STATUS=='9'",'BR_PRETO'    }) // Cancelada

	If ExistBlock("TM460LEG")
	aRet := ExecBlock("TM460LEG",.F.,.F., {1,aCores})
		If ValType(aRet) == "A" .And. !Empty(aRet)
			aCores := aClone(aRet)
		EndIf
	EndIf
	
Return aCores

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA460Sug³ Autor ³ Ramon Prado		       ³ Data ³ 23/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Sugere Cliente Remetente                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA460Sug(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - (1=Cliente/2=Loja)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA460Sug(nOpcao)
Local aArea := getArea()
Local cRet := ''
Local lVldCab := .T.

DUE->(DbSetOrder(1))
If DUE->(MsSeek(xFilial("DUE")+M->DT5_CODSOL))
	If nOpcao == 1 //-- Cliente (Inicializador Padrao)
		cRet := DUE->DUE_CODCLI
	ElseIf nOpcao == 2 //-- Loja (Inicializador Padrao)
		cRet := DUE->DUE_LOJCLI
	ElseIf nOpcao == 3 //-- Cliente + Loja (Check Sugestao do Remetente)
		If lSugRemet
			If !Empty(M->DT5_CODSOL)
								
				__readvar := "M->DT5_CLIREM"
				If !CheckSX3("DT5_CLIREM",DUE->DUE_CODCLI) .And. lVldCab
					lVldCab := .F.
				EndIf

				RunTrigger(1,,,oEnchoice,"DT5_CLIREM")

				__readvar := "M->DT5_LOJREM"
				If !CheckSX3("DT5_LOJREM",DUE->DUE_LOJCLI) .And. lVldCab
					lVldCab := .F.
				EndIf
				
				RunTrigger(1,,,oEnchoice,"DT5_LOJREM") 

				//-- Executa Gatilhos
				If !Empty(M->DT5_SEQREM)
					
					//__readvar := "DUE->DUE_SQEREM"
					__readvar := "M->DT5_SEQREM"
					If !CheckSX3("DT5_SQEREM",M->DT5_SEQEND) .And. lVldCab
						lVldCab := .F.
					EndIf
				
					M->DT5_SQEREM := M->DT5_SEQEND
					RunTrigger(1,,,oEnchoice,"DT5_SQEREM")
					
				EndIf
				If !Empty(M->DT5_TIPFRE)
					__ReadVar := "M->DT5_TIPFRE"
					CheckSX3("DT5_TIPFRE",M->DT5_TIPFRE)								
					
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

o1Get:oBrowse:Refresh(.T.)
oEnchoice:Refresh()
oDlg:Refresh()

RestArea(aArea)
Return( cRet )

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa460LC
@autor		: Eduardo Alberti
@descricao	: Tratamento De Gatilhos
@since		: Apr./2015
@using		: Tmsa460
@review	:
@param		:	cCampo	: Campo Origem Do Gatilho (Se Não Informado Utiliza ReadVar())
				cSeq	: Sequencia Do Gatilho	
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa460LC( cCampo , cSeq )

	Local aArea    := GetArea()
	Local aArDUE   := DUE->(GetArea())
	Local aArDUL   := DUL->(GetArea())
	Local aArSA1   := SA1->(GetArea())
	Local cRet     := ""

	Default cCampo := ReadVar()
	Default cSeq   := ""

	//-- Retorna a Região de Origem (DT5_CDRORI)
	If cCampo $ "M->DT5_LOCCOL|M->DT5_CLIREM|M->DT5_LOJREM" //-- Contra Domínio DT5_CDRORI
	
		//-- Se For '1' -> Solicitante
		If M->DT5_LOCCOL == StrZero( 1 , Len(M->DT5_LOCCOL))
		
			cRet := GetMv("MV_CDRORI") 
			
		//-- Se For '2' -> Remetente
		ElseIf M->DT5_LOCCOL == StrZero( 2 , Len(M->DT5_LOCCOL))

			DbSelectArea("SA1")
			DbSetOrder(1) //-- A1_FILIAL+A1_COD+A1_LOJA
			MsSeek(FWxFilial("SA1") + M->DT5_CLIREM + M->DT5_LOJREM , .F. )
				
			cRet := SA1->A1_CDRDES
					
		EndIf
	EndIf

	RestArea(aArDUE)
	RestArea(aArDUL)
	RestArea(aArSA1)
	RestArea(aArea)

Return( cRet )

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa460Can
@autor		: Valdemar Roberto Mognon
@descricao	: Verifica se a coleta pode ser cancelada quando integrada com Gestão de Demandas
@since		: 25/02/2019
@using		: Tmsa460
@review	    :
@param		:
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa460Can(aVetReg)
Local aAreaDT5  := DT5->(GetArea())
Local aArea     := GetArea()
Local aVetRet   := {}
Local nCntFor1  := 0
Local cQuery    := ""
Local cAliasDUA := ""
Local lPode     := .T.

Default aVetReg := {}

DT5->(DbSetOrder(4))

For nCntFor1 := 1 To Len(aVetReg)
	lPode := .T.

	cAliasDUA := GetNextAlias()
	cQuery := " SELECT DUA_DATOCO,DUA_HOROCO,DUA_NUMOCO,DT2_TIPOCO "
	cQuery += "   FROM " + RetSqlName("DUA") + " DUA "
	cQuery += "   JOIN " + RetSqlName("DT2") + " DT2 "
	cQuery += "     ON DT2_FILIAL = '" + xFilial("DT2") + "' "
	cQuery += "    AND DT2_CODOCO = DUA_CODOCO "
	cQuery += "    AND DT2_TIPOCO IN ('02','03') "
	cQuery += "    AND DT2.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE DUA_FILIAL = '" + xFilial("DUA") + "' "
	cQuery += "    AND DUA_FILDOC = '" + aVetReg[nCntFor1,1] + "' "
	cQuery += "    AND DUA_DOC    = '" + aVetReg[nCntFor1,2] + "' "
	cQuery += "    AND DUA_SERIE  = '" + aVetReg[nCntFor1,3] + "' "
	cQuery += "    AND DUA.D_E_L_E_T_ = ' ' "
	cQuery += "  ORDER BY DUA_DATOCO,DUA_HOROCO,DUA_NUMOCO"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDUA, .T., .T.)

	While (cAliasDUA)->(!Eof())
		lPode := Iif((cAliasDUA)->DT2_TIPOCO == StrZero(2,TamSX3("DT2_TIPOCO")[1]),.F.,.T.)
		(cAliasDUA)->(DbSkip())
	EndDo

	Aadd(aVetRet,{aVetReg[nCntFor1,1],aVetReg[nCntFor1,2],aVetReg[nCntFor1,3],lPode})

	(cAliasDUA)->(DbCloseArea())
	RestArea(aArea)
Next nCntFor1

RestArea(aAreaDT5)
RestArea(aArea)

Return Aclone(aVetRet)
