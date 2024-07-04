#Include "Protheus.ch"
#Include "TmsA210.ch"
#INCLUDE "FWMVCDEF.CH"

Static lTM210Est  := ExistBlock('TM210EST')
Static lTM210Grv  := ExistBlock('TM210GRV')
Static lTM210VCte := ExistBlock('TM210VCTE')
Static lIntTPR    := SuperGetMV("MV_ROTAINT",,.F.)  .And. AliasInDic("DMR")
Static lDocVge    := SuperGetMV('MV_DOCVGE',,.F.)    //-- Determina se os enderecos/documentos podem ser ser vinculados a uma viagem atraves do carregamento

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA210  ³ Autor ³ Robson Alves          ³ Data ³15.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao no Carregamento de transporte.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA210(ExpC1, ExpC2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tipo do Servico                                    ³±±
±±³          ³ ExpC2 = Tipo do Transporte                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA210(cServico, cTransp)

Local   cTop210    := ''
Local   cBot210    := ''
Local   aCampos    := {}

Private cSerTms    := cServico // Tipo do Servico
Private cTipTra    := cTransp  // Tipo do Transporte
If Type("aRotina") != "A"
	Private aRotina	:= MenuD210()
EndIf

cTop210 := 'xFilial("DTA") + cSerTms + cTipTra'
cBot210 := 'xFilial("DTA") + cSerTms + cTipTra' 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("DTA")
DbSetOrder(4)

If GetMv("MV_LOCALIZ",,"N") == "S"
	Aadd( aCampos, { Posicione('SX3', 2,'DTA_LOCAL' ,'X3Titulo()'), 'DTA_LOCAL'  } ) 
	Aadd( aCampos, { Posicione('SX3', 2,'DTA_LOCALI','X3Titulo()'), 'DTA_LOCALI' } ) 
		Aadd( aCampos, { Posicione('SX3', 2,'DTA_UNITIZ','X3Titulo()'), 'DTA_UNITIZ'  } ) 
		Aadd( aCampos, { Posicione('SX3', 2,'DTA_CODANA','X3Titulo()'), 'DTA_CODANA'  } ) 	
	mBrowse( 6,1,22,75,'DTA', aCampos , , , , , , cTop210, cBot210 )
Else	
	mBrowse( 6,1,22,75,'DTA', , , , , , , cTop210, cBot210 )
EndIf	

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA210Mnt³ Autor ³ Robson Alves          ³ Data ³15.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua manutencoes no DTA(Operacoes de Transporte).        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA210Mnt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA210Mnt( cAlias, nRecno, nOpc,  cFilOri, cViagem, lConfirma, cCodVei )

Local   oDlg, oEnchoice
Local   aAreaDTA   := DTA->( GetArea() )
Local   aSize      := {}
Local   aObjects   := {}
Local   aInfo      := {}
Local   aPosObj    := {}
Local   aVisual    := {}
Local   aNoFields  := {}
Local   aYesFields := {}
Local   aAlter     := {}
Local   nOpca      := 0
Local   aCpos      := If(aRotina[nOpc][4] == 3,NIL,{}) //Se Nao for Inclusao, Nao Edita campos da enchoice
Local   lLocaliza  := GetMV('MV_LOCALIZ')=="S"
Local   bVerViagem := {|| Tmsa210Viag() }
Local   bLimite    := {|| TmsA210Lim()  }
Local   bCodBar	  := {|| TM210CodBr()} 
Local   bSeekFor   := {|| .T. }							  
Local   cTes	   := GetMV("MV_TESDR",,"")         
Local   lAtuEst    := .F.
Local   aButtons   := {	{"CARGA"  , bVerViagem, STR0015 , STR0016 },; 	//"Viagem - <F4>"
							{"CODBAR"  , bCodBar, STR0072, STR0073 },; 		// "Leitura Por código de barras - <F8>"
							{"BMPVISUAL", bLimite   , STR0017 , STR0018 }} 	//"Limite - <F5>"
Local   oAllMark
Local   lRet       := .T.
Local   lCarregPar := SuperGetMv('MV_TMSCPAR',,.F.)
Local   lPesLiq    := .F.
Local   lTercRbq   := DTR->(ColumnPos("DTR_CODRB3")) > 0
Local   aManifes   := {}

Private lAlianca   := TmsAlianca() //-- Verifica se utiliza Alianca
Private lCarreg    := ( nOpc == 3 )
Private lEstorno   := ( nOpc == 4 )  //| É estorno
Private aHeader    := {}
Private aCols      := {}
Private aFilDca    := {}
Private __nDelItem := 0
Private cServEnt   := Padr(GetMV("MV_SVCENT",,""),Len(DC5->DC5_SERVIC))
Private aTela[0][0],aGets[0]
Private oGetD,oPanel
Private aSetKey    := {}
Private lAllMark   := .T.
//-- Variaveis do Rodape da Tela (Dados dos Doctos.)
Private nVolumes  := 0
Private nPesReal  := 0
Private nPesCub   := 0
Private nValMerc  := 0
Private nDoctos   := 0
Private oVolumes  := 0
Private oPesReal  := 0
Private oPesCub   := 0
Private oValMerc  := 0
Private oDoctos   := 0

DEFAULT cFilOri		:= ''
DEFAULT cViagem		:= ''
DEFAULT lConfirma := .T.   
DEFAULT cCodVei	:= Space(TamSx3('DTA_CODVEI')[1])


SX3->(DbSetOrder(2))
If SX3->(DbSeek("DTA_PESLIQ"))
	lPesLiq := .T.
EndIf

SF4->( DbSetOrder( 1 ) )
If	!SF4->( MsSeek( xFilial('SF4') + cTes, .F. ) ) 
	Help( ' ', 1, 'TMSA20015',, STR0019 + cTes,5,11)	//"Tipo de entrada/saida informado no parametro MV_TESDR nao encontrado (SF4)" ### "TES"
	Return ( .F. )
EndIf

//--So habilita carregamento parcial em transporte internacional
If lCarregPar .And. !(IsInCallStack(AllTrim('TMSA210I'))) .And. !(IsInCallStack(AllTrim('TMSA140D'))) .And. !(IsInCallStack(AllTrim('TMSA144I'))) ;
	.And. !(IsInCallStack(AllTrim('TMSA144J')))
	lCarregPar := .F.
EndIf

lAtuEst := (SF4->F4_ESTOQUE == "S")

If nOpc == 4 //Estorno
	//-- Verifica se permite o estorno do carregamento
	If !TMSChkViag( DTA->DTA_FILORI, DTA->DTA_VIAGEM,.T.,.F.,.F.,,.F.,.F.,,.T.,,,.F.,.T. )
		Return .F.
	EndIf                                           

	// Verifica se possui manifestos com cancelamento não transmitidos.
	If  A210VCnMan(M->DTQ_FILORI,M->DTQ_VIAGEM,@aManifes,.T.)
		Return .F.
	EndIf

	// Verifica se possui manifestos com encerramento não transmitidos.
	A210VEnMan(M->DTQ_FILORI,M->DTQ_VIAGEM,@aManifes,.F.)

	//-- Ponto de Entrada utilizado para validar o estorno do carregamento
	If lTM210Est
		lRet := ExecBlock('TM210EST',.F.,.F.)
		If ValType(lRet) # "L"
			lRet := .T.
		EndIf	
		If !lRet
			Return .F.
		EndIf
	EndIf
	// So' devera' ser estornado o carregamento efetuado na Filial Atual
	bSeekFor := {|| DTA->DTA_FILATU == cFilAnt }	
EndIf

//-- Array das Teclas de Atalhos
Aadd(aSetKey, { VK_F4 ,  bVerViagem } )
Aadd(aSetKey, { VK_F5 ,  bLimite    } )
Aadd(aSetKey, { VK_F8 ,  bCodBar    } )

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

//-- Seta a variavel "Inclui" como .T. quando for Painel do Agendamento 
If nOpc == 3 .And. IsInCallStack("TMSAF76")
	Inclui := .T.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria ou carregas as variaveis de memoria.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory(cAlias, nOpc == 3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campo para visualizacao na Enchoice.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aVisual, "DTA_FILORI")
Aadd(aVisual, "DTA_VIAGEM")
Aadd(aVisual, "DTA_CODVEI")
Aadd(aVisual, "DTA_MODVEI")
Aadd(aVisual, "DTA_CODRB1")
Aadd(aVisual, "DTA_MODRB1")
Aadd(aVisual, "DTA_CODRB2")
Aadd(aVisual, "DTA_MODRB2")
If lTercRbq
	Aadd(aVisual, "DTA_CODRB3")	
	Aadd(aVisual, "DTA_MODRB3")
EndIf
Aadd(aVisual, "DTA_VEICAR")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campos que nao deverao aparecer na GetDados.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aNoFields, "DTA_FILORI")
Aadd(aNoFields, "DTA_VIAGEM")
Aadd(aNoFields, "DTA_CODVEI")
Aadd(aNoFields, "DTA_MODVEI")
Aadd(aNoFields, "DTA_CODRB1")
Aadd(aNoFields, "DTA_MODRB1")
Aadd(aNoFields, "DTA_CODRB2")
Aadd(aNoFields, "DTA_MODRB2")
If lTercRbq
	Aadd(aNoFields, "DTA_CODRB3")
	Aadd(aNoFields, "DTA_MODRB3")
EndIf	
Aadd(aNoFields, "DTA_VEICAR")

If !lAlianca
	Aadd(aNoFields, "DTA_FILDPC")
EndIf

If nOpc <> 4
	Aadd(aNoFields, "DTA_ESTCAR")
Else
	Aadd(aAlter, "DTA_ESTCAR")
EndIf

If !lLocaliza 
	Aadd(aNoFields, "DTA_LOCAL")
	Aadd(aNoFields, "DTA_LOCALI")
	Aadd(aNoFields, "DTA_UNITIZ")
	Aadd(aNoFields, "DTA_CODANA")
EndIf

If !lCarregPar
	Aadd(aNoFields, "DTA_PESOM3")
	Aadd(aNoFields, "DTA_METRO3")
	Aadd(aNoFields, "DTA_VALMER")
	Aadd(aNoFields, "DTA_VALFRE")
	If lPesLiq
		Aadd(aNoFields, "DTA_PESLIQ")
	EndIf
EndIf	

If nOpc == 3 .Or. !lCarregPar
	Aadd(aNoFields, "DTA_FILMAN")
	Aadd(aNoFields, "DTA_MANIFE")
EndIf	

If ValType(cFilOri) == 'C' .And. (!Empty(cFilOri) .Or. !Empty(cViagem))
	M->DTA_FILORI := cFilOri
	M->DTA_VIAGEM := cViagem
	If !Empty(cCodVei)
		M->DTA_CODVEI := cCodVei
	Else
		DTR->(dbSetOrder(1))
		If DTR->(MsSeek(xFilial('DTR')+M->DTA_FILORI+M->DTA_VIAGEM))
			M->DTA_CODVEI := DTR->DTR_CODVEI
			M->DTA_MODVEI := Posicione("DA3",1,xFilial("DA3")+M->DTA_CODVEI,"DA3_DESC")
		EndIf
	EndIf		
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aHeader e aCols.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TMSFillGetDados(nOpc, "DTA", 5, xFilial("DTA")+M->DTA_FILORI+M->DTA_VIAGEM+M->DTA_CODVEI, Iif(nOpc != 3,;
{ || DTA->(DTA_FILIAL+DTA_FILORI+DTA_VIAGEM+DTA_CODVEI) }, {|| ""}), bSeekFor, aNoFields, aYesFields )

If nOpc == 4 .And. Empty(GdFieldGet("DTA_DOC",1)) // Se for estorno e o aCols esta Vazio
   Help("",1,"TMSA21013") // Nao ha Registros para serem estornados nesta Filial ...
	//-- Finaliza Teclas de Atalhos
	TmsKeyOff(aSetKey)
	Return .F.
EndIf

If lConfirma
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula as dimensoes dos objetos.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize   := MsAdvSize()

	AAdd( aObjects, { 035, 070, .T., .T. } )
	AAdd( aObjects, { 235, 235, .T., .T. } )
	AAdd( aObjects, { 50, 30, .T., .T. } )
	
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	
	oEnchoice := MsMGet():New( cAlias, nRecno, nOpc,,,, aVisual  , aPosObj[1],aCpos, 3,,,,,,.T.)
	
	oGetD := MSGetDados():New(aPosObj[2,1], aPosObj[2,2],aPosObj[2,3], aPosObj[2,4],nOpc,'TmsA210LOk()', 'TmsA210TOk()',,(nOpc<>4 .And. nOpc<>2),If (nOpc==4,aAlter,NIL),,,If(nOpc == 4, Len(aCols),nil),,,,IIF( (nOpc <> 4 .And. nOpc <> 2),"TMSA210Del()",Nil))
	
	oPanel:= TPanel():New(aPosObj[3,1],aPosObj[3,2],"",oDlg,,,,,CLR_WHITE,(aPosObj[3,4]-aPosObj[3,2]), (aPosObj[3,3]-aPosObj[3,1])+10, .T.)
	If nOpc == 4
		@ 002,005 CHECKBOX oAllMark VAR lAllMark PROMPT STR0013 SIZE 168, 08;
		ON CLICK(TmsA210rep(@oGetD, @lAllMark)) OF oPanel PIXEL
	EndIf
	
	@ 015,005 SAY STR0031 SIZE 40,9 OF oPanel PIXEL //--Volumes
	@ 012,030 MSGET oVolumes VAR nVolumes WHEN .F. SIZE 30,9 OF oPanel PIXEL
	
	@ 015,070 SAY STR0032 SIZE 40,9 OF oPanel PIXEL //--Peso Real
	@ 012,100 MSGET oPesReal VAR nPesReal PICTURE PesqPict("DT6","DT6_PESO") WHEN .F. SIZE 50,9 OF oPanel PIXEL
	
	@ 015,160 SAY STR0033 SIZE 40,9 OF oPanel PIXEL //--Peso Cubado
	@ 012,195 MSGET oPesCub VAR nPesCub PICTURE PesqPict("DT6","DT6_PESOM3") WHEN .F. SIZE 50,9 OF oPanel PIXEL
	
	@ 015,255 SAY STR0034 SIZE 40,9 OF oPanel PIXEL //--Vlr. Merc.
	@ 012,285 MSGET oValMerc VAR nValMerc PICTURE PesqPict("DT6","DT6_VALMER") WHEN .F. SIZE 50,9 OF oPanel PIXEL
	
	@ 015,345 SAY STR0035 SIZE 50,9 OF oPanel PIXEL //--Doctos.
	@ 012,365 MSGET oDoctos VAR nDoctos WHEN .F. SIZE 20,9 OF oPanel PIXEL
	
	If nOpc <> 3

		If nOpc == 4 
			A210InitVal(aHeader , aCols ,  M->DTA_FILORI , M->DTA_VIAGEM )
		EndIf

		//-- Atualizando dados do Rodape
		TmsA210Rdp()

	EndIf
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1, If(oGetD:TudoOk(), oDlg:End(), nOpca := 0)},{||oDlg:End()},, aButtons )
ElseIf TmsA210TOk(nOpc, .F.)
	nOpca := 1	
EndIf

If nOpca == 1 .And. nOpc != 2	
	FwMsgRun( ,{|| TmsA210Grv(aVisual, nOpc, lLocaliza)} ,STR0007 , STR0007 )
EndIf   

RestArea( aAreaDTA )

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA210LOk³ Autor ³ Richard Anderson      ³ Data ³18.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da linha de GetDados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA210LOk()

Local aAreas    := {}
Local lRet		:= .T.
Local lLocaliza := SuperGetMv("MV_LOCALIZ",.F.,"") == "S"
Local cSeek     := ""
Local cSeekCar  := ""
Local nValFre   := 0
Local nQtdTot   := 0
Local nFreCar   := 0
Local nQtdCar   := 0
Local lRetPE    :=.F.
Local lTM210LOK := ExistBlock('TM210LOK')
Local cQuery	:= ""
Local cAlias	:= ""
Local lDTAOrigem:= DTA->(ColumnPos('DTA_ORIGEM')) > 0
Local cErro     := ""

Local lAgdEntr  := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.) //-- Agendamento de Entrega
Local aValAgend := {}

If	!GDDeleted( n )
	//-- Ponto de Entrada
	If lTM210LOK
		lRetPE := ExecBlock('TM210LOK',.F.,.F.,{oGetD:nOpc})      
		If ValType(lRetPE)=="L" 
			lRet:=lRetPE
		EndIf
	EndIf	

	If lRet .And. !lEstorno
		lRet := MaCheckCols( aHeader, aCols, n )
	EndIf	
           
	If lRet
		If lLocaliza	
			lRet := GDCheckKey( { 'DTA_LOCAL', 'DTA_LOCALI', 'DTA_UNITIZ' ,'DTA_CODANA', 'DTA_FILDOC', 'DTA_DOC', 'DTA_SERIE' }, 4 )			
		Else
			lRet := GDCheckKey( { 'DTA_FILDOC', 'DTA_DOC', 'DTA_SERIE' }, 4 )       
		EndIf			
	EndIf

	//Validacoes para o valor do Frete, a mesma logica e utilizada na 210Val, as correcoes precisam refletir nos dois trechos
	//--Transporte Internacional
	If lRet .And. ((IsInCallStack(AllTrim('TMSA210I'))) .Or. (IsInCallStack(AllTrim('TMSA140D'))) .Or. (IsInCallStack(AllTrim('TMSA144I'))) .Or. (IsInCallStack(AllTrim('TMSA144J'))) ) .And. Inclui
		cSeek    := GDFieldGet('DTA_FILDOC',n) + GDFieldGet('DTA_DOC',n) + GDFieldGet('DTA_SERIE',n)
		cSeekCar := cSeek
		
		DT6->(dbSetOrder(1))
		If DT6->(dbSeek(xFilial('DT6')+cSeek))
			If Empty(DT6->DT6_DOCDCO) //--Se nao tiver documento original, alimenta com o valor do frete
				nValFre := DT6->DT6_VALFRE //--Valor Total do Frete
				nQtdTot := DT6->DT6_VOLORI //--Quantidade Total de Volumes
			Else
				cSeek := DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO //--Posiciona no documento original
				cSeekCar := DT6->DT6_FILDCO+DT6->DT6_DOCDCO //--Somente Filial e Documento para pesquisar o carregamento, devido ao carregamento parcial
				If DT6->(dbSeek(xFilial('DT6')+cSeek))
					nValFre := DT6->DT6_VALFRE //--o Valor do Frete tem que ser o do documento original
					nQtdTot := DT6->DT6_VOLORI //--Quantidade Total de Volumes
				EndIf
			EndIf
		EndIf
		
		//------- Posiciona no carregamento referente ao documento Original
		DTA->(dbSetOrder(1))
		If DTA->(dbSeek(cSeekDTA := xFilial('DTA')+cSeek))
			nFreCar += DTA->DTA_VALFRE //Soma os valores de frete ja carregados
			nQtdCar += DTA->DTA_QTDVOL //Soma os volumes ja carregados
		EndIf  
		
		//---- Soma os valores referente ao Carregamento Parcial - P01,P02,....///  
		cSeekDT6 := DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO 
		If !Empty(cSeekDT6)    
			aAreaDTA := DTA->(GetArea()) 
			aAreaDT6 := DT6->(GetArea())
			DT6->(dbSetOrder(8))
			If DT6->(dbSeek(cSeekDT6 := xFilial('DT6')+cSeekDT6)) 
				While DT6->( !Eof() ) .And. DT6->DT6_FILIAL+DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO == cSeekDT6
					DTA->(dbSetOrder(1))
					If DTA->(dbSeek(cSeekDTA := xFilial('DTA')+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE ))
						nFreCar += DTA->DTA_VALFRE //Soma os valores de frete ja carregados
						nQtdCar += DTA->DTA_QTDVOL //Soma os volumes ja carregados
					EndIf	                                                               
					DT6->(DbSkip())
				EndDo
			EndIf 
			RestArea(aAreaDTA)  
			RestArea(aAreaDT6)  
		EndIf
	
	
		//--Valor do Frete Digitado + o valor ja carregado
		//--nao pode ultrapassar o frete do documento original
		If nValFre > 0 .AND. GDFieldGet('DTA_VALFRE',n) <> Nil
			If (GDFieldGet('DTA_VALFRE',n) + nFreCar) > nValFre
				MsgAlert(STR0052 + CHR(13)+CHR(10)+; //--"O Valor do Frete informado no carregamento e maior que o do documento."
							STR0053 + AllTrim(Transform(nValFre,'@E 999,999,999.99')) + CHR(13)+CHR(10)+; //--"Frete Total: "
							STR0054 + AllTrim(Transform(nFreCar,'@E 999,999,999.99')) + CHR(13)+CHR(10)+; //--"Frete Carregado: "
							STR0055 + AllTrim(Transform(nValFre-nFreCar,'@E 999,999,999.99'))) //--"Frete Restante: "
				lRet := .F.
			ElseIf GDFieldGet('DTA_VALFRE',n) == 0 //Validar na tok ou linok, pois o usuario pode nao digitar o campo
				MsgAlert(STR0056) //--"E necessario informar o valor do frete"
				lRet := .F.
			ElseIf GdFieldGet('DTA_QTDVOL') + nQtdCar == nQtdTot //--Ultimo documento, o valor precisa ser do restante do frete
				If GDFieldGet('DTA_VALFRE',n) < (nValfre - nFreCar)
					MsgAlert(STR0057 + CHR(13)+CHR(10)+ ; //--"Este documento precisa receber o valor restante do frete"
								STR0055 + AllTrim(Transform(nValFre-nFreCar,'@E 999,999,999.99'))) //--"Frete Restante: "
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet .And. lDTAOrigem .And. GdFieldGet('DTA_ORIGEM', n) == "3" //Local de Coleta
		cQuery := "SELECT DTC.DTC_NUMSOL "
		cQuery += "FROM " + RetSqlName("DTC") + " DTC "
		cQuery += "WHERE DTC.DTC_FILIAL = '" + xFilial("DTC") + "' "
		cQuery +=	"AND DTC.DTC_FILDOC = '" + GdFieldGet('DTA_FILDOC', n) + "' "
		cQuery += 	"AND DTC.DTC_DOC = '" + GdFieldGet('DTA_DOC', n) + "' "
		cQuery += 	"AND DTC.DTC_SERIE = '" + GdFieldGet('DTA_SERIE', n) + "' "
		cQuery += 	"AND DTC.D_E_L_E_T_ = ' ' "
		cQuery += 	"AND DTC.DTC_NUMSOL <> ''"
		cQuery := ChangeQuery(cQuery)
		cAlias := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)
		If (cAlias)->(Eof())
			(cAlias)->(dbCloseArea())
			Help(" ", 1, "TMSA14448") //Esta opção é valida somente para Documentos de Transporte gerados a partir de Notas Fiscais vinculadas a uma Solicitação de Coleta - Selecione outra opção.
			Return .F.
		EndIf
		(cAlias)->(dbCloseArea())
	EndIf
		
	If GdFieldGet('DTA_ESTCAR', n) == "1" 

		lRet := A210VldMCa( M->DTA_FILORI , M->DTA_VIAGEM  , GdFieldGet('DTA_FILDOC', n) , GdFieldGet('DTA_DOC', n) , GdFieldGet('DTA_SERIE', n) )

		If !lRet
			Help( ' ', 1, 'HELP',, STR0091 + " " + cErro ,3,0) //-- "Não poderá ser realizado o estorno do carregamento, pois os seguintes manifestos possuem encerramento não transmitido:"
        EndIf

	EndIf

    If !lEstorno .And. lRet .And. lAgdEntr
        aAreas := {DUD->(GetArea()),GetArea()}
        DUD->(DbSetOrder(1))
        If DUD->(MsSeek(xFilial("DUD")+GdFieldGet('DTA_FILDOC',n)+GdFieldGet('DTA_DOC',n)+GdFieldGet('DTA_SERIE',n)))
            If DUD->DUD_SERTMS == StrZero( 3, Len( DUD->DUD_SERTMS ) )
                aValAgend := TMSAgdVgVl( GdFieldGet('DTA_FILDOC',n), GdFieldGet('DTA_DOC',n), GdFieldGet('DTA_SERIE',n), dDataBase, SubStr(Time(),1,5), .F. )
                If !aValAgend[1]
                    If !MsgNoYes( aValAgend[2] + CRLF + "Deseja continuar ?" , "Documento: " + GdFieldGet('DTA_FILDOC',n) +"/"+ GdFieldGet('DTA_DOC',n) +"/"+ GdFieldGet('DTA_SERIE',n) )
                        lRet := .F.
                    Endif
                EndIf
            EndIf
        EndIf
        AEval(aAreas,{|aArea| RestArea(aArea) })
    EndIf

EndIf

If lRet
	//-- Atualizando dados do Rodape
	TmsA210Rdp()
EndIf

Return lRet				

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA210TOk³ Autor ³ Alex Egydio           ³ Data ³25.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tudo Ok da GetDados                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA210TOk(nOpcx, lTela)

Local nX, cDoc,cFilDoc,cSerie, nSeek
Local lRet		 := .T.
Local lLocaliza := SuperGetMv("MV_LOCALIZ",.F.,"") == "S"
Local cSeekDUH  := ""
Local cSeekDTC  := ""
Local lRetPE    :=.F.
Local lTM210TOK := ExistBlock('TM210TOK')
Local cQuery	:= ""
Local cAlias	:= ""
Local lDTAOrigem:= DTA->(ColumnPos('DTA_ORIGEM')) > 0

Default nOpcx     := oGetD:nOpc 
Default lTela		:= .T.	
      
//-- Ponto de Entrada
If lTM210TOK
	lRetPE := ExecBlock('TM210TOK',.F.,.F.,{nOpcx})  
	If ValType(lRetPE)=="L" 
		lRet:=lRetPE
	EndIf
EndIf	

//-- Analisa se os campos obrigatorios da Enchoice foram informados.
If lRet
	lRet := Obrigatorio( aGets, aTela )
EndIf
	
//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet .And. lTela
	lRet := TmsA210LOk()
EndIf
//-- Analisa se todas os itens da GetDados estao deletados.
If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
	Help( ' ', 1, 'OBRIGAT2') //Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
	lRet := .F.
EndIf

If lRet 
	For nX := 1 To Len(aCols)
		If GDDeleted( nX )
			Loop
		EndIf			
		cFilDoc := GdFieldGet('DTA_FILDOC',nX) 
		cDoc    := GdFieldGet('DTA_DOC',nX)    
		cSerie  := GdFieldGet('DTA_SERIE',nX)       		
		If lLocaliza .And. nOpcx == 3                   
			//-- Posiciona no documento
			DT6->(dbSetOrder(1))
			DT6->(MsSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
				    
		   cSeekDTC := cFilDoc+cDoc+cSerie                                                        
		   //-- Se for documento de Devolucao, posiciona na Nota Fiscal de Origem
			If DT6->DT6_DOCTMS == StrZero(6,Len(DT6->DT6_DOCTMS)) .And. !Empty(DT6->DT6_DOCDCO)
				cSeekDTC := DT6->(DT6_FILDCO + DT6_DOCDCO + DT6_SERDCO)
		   EndIf
		
			DUH->(dbSetOrder(1))
						
			If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc, cDoc, cSerie)
				DTC->(dbSetOrder(3)) //Fil.Docto. + No.Docto. + Serie Docto. + Servico + Cod. Produto
				DTC->(MsSeek(xFilial("DTC")+cSeekDTC))			
				Do While DTC->( !Eof() ) .And. DTC->DTC_FILIAL+DTC->DTC_FILDOC+DTC->DTC_DOC+DTC->DTC_SERIE == xFilial("DTC")+cSeekDTC
					
					If DTC->DTC_SERIE == 'PED' .Or. Empty(DTC->DTC_DOC)
						DTC->(dbSkip())
						Loop
					EndIf
																
					DUH->(MsSeek( cSeekDUH := xFilial("DUH")+cFilAnt+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM ) )
					Do While DUH->( !Eof() .And. DUH_FILIAL+DUH_FILORI+DUH_NUMNFC+DUH_SERNFC+DUH_CLIREM+DUH_LOJREM == cSeekDUH )
						nSeek := Ascan(aCols,{ |x| x[GdFieldPos('DTA_LOCAL')]+ x[GdFieldPos('DTA_LOCALI')] + x[GdFieldPos('DTA_UNITIZ')]+;
							 		x[GdFieldPos('DTA_CODANA')] == DUH->DUH_LOCAL+DUH->DUH_LOCALI+DUH->DUH_UNITIZ+DUH->DUH_CODANA } )
						If nSeek == 0
							Aviso( STR0020 , STR0021 + DUH->DUH_LOCAL+"/"+AllTrim(DUH->DUH_LOCALI) + STR0022 + AllTrim(cDoc) + "/" + AllTrim(cSerie) + STR0023 , { STR0024 } ) //"AVISO" ### "O Armazem/Endereco" ### " do Documento/Serie " ### " nao foram carregados ..." ### "OK"
							Return .F.
						EndIf	
						DUH->(dbSkip())
					EndDo
					DTC->(dbSkip())
					Loop
				EndDo
			
			Else
				DbSelectArea("DY4")
				DbSetOrder(1) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
				If DY4->(MsSeek(xFilial("DY4")+cFilDoc+cDoc+cSerie))
					Do While DY4->( !Eof() ) .And. DY4->DY4_FILIAL+DY4->DY4_FILDOC+DY4->DY4_DOC+DY4->DY4_SERIE == xFilial("DY4")+cSeekDTC
						
						If DY4->DY4_SERIE == 'PED' .Or. Empty(DY4->DY4_DOC)
							DY4->(dbSkip())
							Loop
						EndIf
				
						DUH->(MsSeek( cSeekDUH := xFilial("DUH")+cFilAnt+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM ) )
						Do While DUH->( !Eof() .And. DUH_FILIAL+DUH_FILORI+DUH_NUMNFC+DUH_SERNFC+DUH_CLIREM+DUH_LOJREM == cSeekDUH )
							nSeek := Ascan(aCols,{ |x| x[GdFieldPos('DTA_LOCAL')]+ x[GdFieldPos('DTA_LOCALI')] + x[GdFieldPos('DTA_UNITIZ')]+;
							 		x[GdFieldPos('DTA_CODANA')] == DUH->DUH_LOCAL+DUH->DUH_LOCALI+DUH->DUH_UNITIZ+DUH->DUH_CODANA } )
							If nSeek == 0
								Aviso( STR0020 , STR0021 + DUH->DUH_LOCAL+"/"+AllTrim(DUH->DUH_LOCALI) + STR0022 + AllTrim(cDoc) + "/" + AllTrim(cSerie) + STR0023 , { STR0024 } ) //"AVISO" ### "O Armazem/Endereco" ### " do Documento/Serie " ### " nao foram carregados ..." ### "OK"
								Return .F.
							EndIf	
							DUH->(dbSkip())
						EndDo						
						DY4->(dbSkip())						
					EndDo
				Endif						
			Endif
			If lDTAOrigem .And. GdFieldGet('DTA_ORIGEM', n) == "3" //Local de Coleta
				cQuery := "SELECT DTC.DTC_NUMSOL "
				cQuery += "FROM " + RetSqlName("DTC") + " DTC "
				cQuery += "WHERE DTC.DTC_FILIAL = '" + xFilial("DTC") + "' "
				cQuery +=	"AND DTC.DTC_FILDOC = '" + cFilDoc + "' "
				cQuery += 	"AND DTC.DTC_DOC = '" + cDoc + "' "
				cQuery += 	"AND DTC.DTC_SERIE = '" + cSerie + "' "
				cQuery += 	"AND DTC.D_E_L_E_T_ = ' ' "
				cQuery += 	"AND DTC.DTC_NUMSOL <> ''"
				cQuery := ChangeQuery(cQuery)
				cAlias := GetNextAlias()
				dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)
				If (cAlias)->(Eof())
					(cAlias)->(dbCloseArea())
					Help(" ", 1, "TMSA14448") //Esta opção é valida somente para Documentos de Transporte gerados a partir de Notas Fiscais vinculadas a uma Solicitação de Coleta - Selecione outra opção.
					Return .F.
				EndIf
				(cAlias)->(dbCloseArea())
			EndIf
		ElseIf nOpcx == 4 //-- Estorno
			If GdFieldGet('DTA_ESTCAR',nX) == '2' 		
				Loop
			EndIf	
			If !A210DoctOk( cFilDoc, cDoc, cSerie )		
				Return ( .F. )
			EndIf					
			DUD->(dbSetOrder(1))
			If DUD->( !MsSeek(xFilial('DUD')+cFilDoc+cDoc+cSerie+M->DTA_FILORI+M->DTA_VIAGEM) )
				Help("", 1, "TMSA21011",,cFilDoc+cDoc+cSerie,2,18) // "Erro ao localizar movimento de viagem para o documento
				Return( .F. )
			EndIf					
			DC5->(dbSetOrder(1))
			If !Empty(DUD->DUD_SERVIC) .And. DC5->(! MsSeek(xFilial('DC5')+DUD->DUD_SERVIC))
				Help("", 1, "TMSA21012",,cFilDoc+cDoc+cSerie,2,01) // Erro ao localizar servico operacional
				Return( .F. )
			EndIf			
		EndIf
	Next nX
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA210Val³ Autor ³ Alex Egydio           ³ Data ³22.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes do sistema                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA210Val()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA210Val(cCampo,nOpcx,aAgendPend)

Local lAchou
Local lLocaliza    := SuperGetMv("MV_LOCALIZ",.F.,"") == "S" //-- Indica se produtos utilizam controle de localizacao fisica
Local cSeek	       := ''
Local lRet         := .T.
Local nSeek        := 0
Local cChvDUH      := ''
Local lAAddACols   := .F.
Local aRegiao      := {}
Local aRegRot      := {}
Local nCntFor      := 0
Local cSeekDUD     := ''
Local cSeekDUH     := ''
Local cSeekDTC     := ''
Local cSeekDT6     := ''
Local cSeekDTA     := ''
Local cSeekCar     := ''
Local cFilDoc      := ''
Local cDoc         := ''
Local cSerie       := ''
Local lCarregEnd   := .F.
Local lMovtoVge    := .F.
Local lProduto     := (DUH->(ColumnPos('DUH_CODPRO'))>0)
Local bWhile       := {||.F.}
Local cSequen      := ''
Local aAreaDF1     := {}
Local lCarregPar   := SuperGetMv('MV_TMSCPAR',,.F.) //-- Habilita carregamento parcial em transporte internacional
Local aDoctosCar   := {}
Local aDoctosPar   := {}
Local nB           := 0
Local cCpoDT6      := ''
Local cCpoSX3      := ''
Local lCarMult     := GetMv('MV_TMSCMUL',,.F.) //-- Carregamento Multiplos servicos de transporte e tipo de transporte
Local cLocUni      := 'M->DTA_LOCAL|M->DTA_LOCALI|M->DTA_UNITIZ|M->DTA_CODANA'
Local cLocIni      := ""//--Endereço do primeiro documento
Local lRetDTC      := .F.
Local lRetDY4      := .F.
 
//-- Redespacho

//-- CTe
Local lTMSCTe      := SuperGetMv( "MV_TMSCTE", .F., .F. )

//-- Variaveis utilizadas a partir do TMSA144 (Viagem Modelo2)
Local lVgeMod2     := (Left(FunName(),7) == 'TMSA144' .Or. Left(FunName(),7) == 'TMSA143' .Or. Left(FunName(),7) == 'TMSA145' .Or. Left(FunName(),7) == 'TMSAF76' .OR. Left(FunName(),7) == 'TMSA153' )
Local lTmsCFec     := TmsCFec()
Local lColeta      := (cSerTms == StrZero(1,Len(DUD->DUD_SERTMS)))
Local cRota        := Iif(!IsInCallStack("AF76VldAgd"),If(lVgeMod2,M->DTQ_ROTA  ,DTQ->DTQ_ROTA),"")
Local cFilOri      := Iif(!IsInCallStack("AF76VldAgd"),If(lVgeMod2,M->DTQ_FILORI,M->DTA_FILORI),"")
Local cViagem      := Iif(!IsInCallStack("AF76VldAgd"),If(lVgeMod2,M->DTQ_VIAGEM,M->DTA_VIAGEM),"")
Local lAlianca     := TmsAlianca() //-- Verifica se utiliza Alianca
Local lExistDUH    := .T.
Local nQtdVol      := 0
Local nValFre      := 0
Local nFreCar      := 0
Local nQtdTot      := 0
Local nQtdCar      := 0
Local lPesLiq      := .F.
Local aAreaDT6     := {}
Local aAreaDTA     := {}    
Local cAgenRem     := ''  //-- del126 - rementente do agendamento                                                                  
Local cAgenDes     := ''  //-- Destinatario do agendamento
Local lAgdEntr     := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)   //-- Agendamento de Entrega.
Local cSerPar      := ""   
Local cSerAdi      := ""
Local lTercRbq     := DTR->(ColumnPos("DTR_CODRB3")) > 0
Local cAliasQry    := GetNextAlias()
Local aVgaColg     := {}
Local lAchouDTX    := .F.
Local lCONTDOC     := SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran") //--Parametro para controle de Transações da Viagem mod2,
					//-- o documento ficara locado até confirmar ou fechar a viagem impossibilitando o uso do documento por outras Estações.
Local cFilDF8      := ""
Local cNumDF8      := ""
Local lTMSItCt     := Iif(FindFunction("TmsUniNeg"),TmsUniNeg(),.F.)
Local lTMS3GFE     := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local lMDFEAut     := GetMV("MV_MDFEAUT",,.F.) .And. ExistFunc("TmsMDFeAut")
Local cPagGFE      := Iif(!IsInCallStack("AF76VldAgd") .And. lTMS3GFE, If(lVgeMod2,M->DTQ_PAGGFE,DTQ->DTQ_PAGGFE),"")

Local lTMSDCol     := SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.
Local aAreaAnt     := {}

Default cCampo     := ReadVar()
Default nOpcx	   := oGetD:nOpc       
Default aAgendPend := {}

if Type("aCols") == 'U'
  aCols := {}
endif 

//--Verifica se a variavel "lVgeExpr"
//--esta declarada
If Type("lVgeExpr") <> 'L'
	PRIVATE	lVgeExpr := .F.
EndIf
Private cCriRat    := ""

SX3->(DbSetOrder(2))
If SX3->(DbSeek("DTA_PESLIQ"))
	lPesLiq := .T.
EndIf

//--So habilita carregamento parcial em transporte internacional
If lCarregPar .And. !(IsInCallStack(AllTrim('TMSA210I'))) .And. !(IsInCallStack(AllTrim('TMSA140D'))) .And. !(IsInCallStack(AllTrim('TMSA144I')));
	.And. !(IsInCallStack(AllTrim('TMSA144J')))
	lCarregPar := .F.
EndIf

If	cCampo == 'M->DTA_FILORI' .Or. cCampo == 'M->DTA_VIAGEM'
	
	If Empty(M->DTA_FILORI) .Or. Empty(M->DTA_VIAGEM)
		Return .T.
	EndIf
		
	//-- Posiciona o DTQ(Geracao de Viagem).
	If !TMSChkViag( M->DTA_FILORI, M->DTA_VIAGEM,.T.,.F.,.F., , .F., .F., , .T., , , ,.T. )
		Return(.F.)
	EndIf	

	If	!TmsA210Srv(DTQ->DTQ_SERTMS)
		Return(.F.)
	EndIf
	
	// Verifica se existe complemento de viagem
	DTR->(dbSetOrder(1))
	If !DTR->(MsSeek(xFilial('DTR')+M->DTA_FILORI+M->DTA_VIAGEM))
		Help( " ", 1, "TMSA24002",, STR0016 + ' : '+ M->DTA_FILORI + " " + M->DTA_VIAGEM, 4, 1 ) //"Complemento de viagem nao encontrado (DTR)" ### "Viagem : "
		Return(.F.)
	EndIf
	
	If DTQ->DTQ_TIPTRA <> cTipTra .Or. DTQ->DTQ_SERTMS <> cSerTms
		Help("",1,"TMSA21001") //O Servico de Transporte / Tipo de Transporte desta Viagem nao e valido para esta opcao de Carregamento ...
		Return(.F.)
	EndIf

	M->DTA_CODVEI := DTR->DTR_CODVEI
	M->DTA_MODVEI := Posicione("DA3",1,xFilial("DA3")+M->DTA_CODVEI,"DA3_DESC")
	M->DTA_CODRB1 := DTR->DTR_CODRB1
	M->DTA_MODRB1 := Posicione("DA3",1,xFilial("DA3")+M->DTA_CODRB1,"DA3_DESC")
	M->DTA_CODRB2 := DTR->DTR_CODRB2
	M->DTA_MODRB2 := Posicione("DA3",1,xFilial("DA3")+M->DTA_CODRB2,"DA3_DESC")

	If lTercRbq
		M->DTA_CODRB3 := DTR->DTR_CODRB3
		M->DTA_MODRB3 := Posicione("DA3",1,xFilial("DA3")+M->DTA_CODRB3,"DA3_DESC")
	EndIf	
	
	If Empty(M->DTA_CODRB1) .And. Empty(M->DTA_CODRB2) .And. Iif(lTercRbq,Empty(M->DTA_CODRB3),.T.) 
		M->DTA_VEICAR := '0'
	Else
		M->DTA_VEICAR := '1'
	EndIf

EndIf

If cSerTms = '3'	
   Pergunte("TMB144",.F.)
	cSerPar := MV_PAR02        	//-- Serv. Adicional presente no Pergunte   
  	If DTQ->(FieldPos('DTQ_SERADI')) > 0
  		cSerAdi := DTQ->DTQ_SERADI 
  	EndIf 
  	If Type("cSerAdi") == "U" .Or. Empty(cSerAdi) .Or. cSerAdi == '0' 
  		cSerAdi := cSerPar
  	EndIf
Else
	cSerAdi := '0'
EndIf

If lRet .And. Type("M->DTA_VIAGEM") == "C" .And. Empty(M->DTA_VIAGEM)
	Help("",1,"TMSA21002") // Informe a Viagem
	Return(.F.)
EndIf

DUD->(dbSetOrder(1))
If	cCampo $ cLocUni                
	
	//-- Se um dos campos estiverem vazios nao faz a procura nos arquivos
	If (cCampo == 'M->DTA_LOCAL' .And. Empty(GDFieldGet('DTA_LOCALI',n))) .Or. (cCampo == 'M->DTA_LOCALI' .And. Empty(GDFieldGet('DTA_LOCAL',n))) .Or.;
		(cCampo == 'M->DTA_UNITIZ'.And. Empty(GDFieldGet('DTA_CODANA',n))) .Or. (cCampo == 'M->DTA_CODANA' .And. Empty(GDFieldGet('DTA_UNITIZ',n))) 
		Return(.T.)
	EndIf
	
	If cCampo == 'M->DTA_LOCAL'
		cSeekDUH := M->DTA_LOCAL +  GDFieldGet( 'DTA_LOCALI', n )
	ElseIf cCampo == 'M->DTA_LOCALI'
		cSeekDUH := GDFieldGet( 'DTA_LOCAL', n ) + M->DTA_LOCALI
	ElseIf cCampo == 'M->DTA_UNITIZ'		
		cSeekDUH := M->DTA_UNITIZ + GDFieldGet( 'DTA_CODANA', n )
	ElseIf cCampo == 'M->DTA_CODANA'
		cSeekDUH := GDFieldGet( 'DTA_UNITIZ', n ) + M->DTA_CODANA 
	EndIf
	DC5->(dbSetOrder(1))
	//-- Verifica se a Filial Documento + Documento + Serie ja foram Informados
	If cCampo == 'M->DTA_UNITIZ' .Or. cCampo == 'M->DTA_CODANA' 
		DUH->(dbSetOrder(4))
	Else
		DUH->(dbSetOrder(2))
	EndIf	
			
	If DUH->(dbSeek(xFilial("DUH")+cFilAnt+StrZero(1,Len(DUH->DUH_STATUS))+cSeekDUH))				
	
		If lVgeMod2 .And. cSerTms != StrZero(2,Len(DC5->DC5_SERTMS)) //-- Se não for transporte
			cSequen := GdFieldGet("DUD_SEQUEN",n)
		EndIf			
		If cCampo == 'M->DTA_UNITIZ' .Or. cCampo == 'M->DTA_CODANA' 
			cChvDUH := 'DUH_FILIAL+DUH_FILORI+DUH_STATUS+DUH_UNITIZ+DUH_CODANA'
		Else
			cChvDUH := 'DUH_FILIAL+DUH_FILORI+DUH_STATUS+DUH_LOCAL+DUH_LOCALI'
		EndIf	
		
		While DUH->(!Eof()) .And. DUH->(&cChvDUH) == xFilial("DUH")+cFilAnt+StrZero(1,Len(DUH->DUH_STATUS))+cSeekDUH
			cSeek := DUH->DUH_NUMNFC+DUH->DUH_SERNFC+DUH->DUH_CLIREM+DUH->DUH_LOJREM+DUH->DUH_CODPRO
			DTC->(dbSetOrder(2))
			If DTC->(dbSeek(xFilial('DTC')+cSeek))
				
				If DTC->DTC_SERIE == 'PED' .Or. Empty(DTC->DTC_DOC)
					DUH->(dbSkip())
					Loop
				EndIf

				aDoctosCar := { { DTC->DTC_FILDOC, DTC->DTC_DOC, DTC->DTC_SERIE } }
				
				If lCarregPar
					DT6->(dbSetOrder(8))
					DT6->(dbSeek(cSeekDT6 := xFilial('DT6')+DTC->(DTC_FILDOC+DTC_DOC+DTC_SERIE)))
					While DT6->(!Eof()) .And. DT6->(DT6_FILIAL+DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO) == cSeekDT6
						If DT6->DT6_DOCTMS == 'K' //-- Docto. de carregamento em partes
							Aadd(aDoctosCar,{ DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE })
						EndIf
						DT6->(dbSkip())
					EndDo													
				EndIf					

				lMovtoVge := .F.

				For nB := 1 To Len(aDoctosCar)

					cSeek := aDoctosCar[nB,1]+aDoctosCar[nB,2]+aDoctosCar[nB,3]

					DT6->(dbSetOrder(1))
					If DT6->(dbSeek(xFilial("DT6")+cSeek))

						//-- Checar o Status do Documento no Processo CT-e
						//-- DT6_IDRCTE == 100 ("Autorizado o uso do CT-e")
						//-- DTP_TIPLOT == 3 (Eletronico) 4 Para CT-e Unico
						If lTMSCTe
							DTP->(dbSetOrder(2))
							If DTP->(MsSeek(xFilial("DTP") + DT6->DT6_FILORI + DT6->DT6_LOTNFC)) .And.;
							   ( DTP->DTP_TIPLOT == StrZero(3,Len(DTP->DTP_TIPLOT)) .Or.;
							     DTP->DTP_TIPLOT == StrZero(4,Len(DTP->DTP_TIPLOT)))
								
								lRet := Alltrim(DT6->DT6_IDRCTE) == "100" .Or. ! Empty(DT6->DT6_CHVCTG) .Or. Alltrim(DT6->DT6_IDRCTE) == "136" //Documento Autorizado; Contigencia FSDA; Contingencia EPEC

								If ! lRet .And. (Alltrim(DT6->DT6_DOCTMS) ==   StrZero( 5 , Len( DT6->DT6_DOCTMS)) .Or.; //--Nota Fiscal de Serv. de Transp.
												 Alltrim(DT6->DT6_DOCTMS) == Replicate('D', Len( DT6->DT6_DOCTMS)) .Or.; //--Nota Fiscal de Reentrega
												 Alltrim(DT6->DT6_DOCTMS) == Replicate('F', Len( DT6->DT6_DOCTMS)) .Or.; //--Nota Fiscal de Armazenagem
												 Alltrim(DT6->DT6_DOCTMS) == Replicate('G', Len( DT6->DT6_DOCTMS)) )     //--Nota Fiscal de Complemento
									lRet := .T.
								EndIf
								If ! lRet
									Help("", 1, "TMSA21025", , cSeek, 2, 1) //"CT-e não autorizado ou não enviado para Sefaz."
									Loop
								EndIf
							EndIf
						EndIf 

						If DT6->DT6_BLQDOC == '1'
							Help("",1,"TMSA21003",,cSeek,2,1) // Documento Bloqueado ...
							Return(.F.)
						ElseIf DT6->DT6_PRIPER == '1'
							Help("",1,"TMSA21004",,cSeek,3,1) // Este Documento nao podera ser carregado pois esta configurado como sendo de 1o. percurso
							Return(.F.)
						EndIf
					EndIf
					
					cSeekDUD := (cSeek + Iif(lTMSDCol,"",cFilAnt))
					dbSelectArea("DUD")
					dbSetOrder(1)
					If !dbSeek(xFilial("DUD")+cSeekDUD) 
						cSeekDUD := cSeek + Iif(lTMSDCol,"",cFilOri)
						dbSeek(xFilial("DUD")+cSeekDUD)
					EndIf					
					While !Eof() .And. DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+Iif(lTMSDCol,"",DUD_FILORI) == xFilial("DUD")+cSeekDUD
						If lCarMult .And. (cSerAdi <> '1' .Or. (cSerAdi == '1' .And. DUD->DUD_SERTMS <> StrZero(1, Len (DUD->DUD_SERTMS))) )   //Servico Adicional de Coleta
							If (!Empty(DUD->DUD_VIAGEM) .And. DUD->DUD_FILORI+DUD->DUD_VIAGEM != cFilOri+cViagem ) .Or. DUD->DUD_STATUS != StrZero(1,Len(DUD->DUD_STATUS))
								dbSkip()
								Loop	
							EndIf
						Else						
							If DUD->DUD_SERTMS != cSerTms .Or. DUD->DUD_TIPTRA != cTipTra .Or. ( !Empty( DUD->DUD_VIAGEM ) .And. DUD->DUD_FILORI+DUD->DUD_VIAGEM != cFilOri+cViagem ) .Or. ;
								DUD->DUD_STATUS != StrZero(1,Len(DUD->DUD_STATUS))
								dbSkip()
								Loop	
							EndIf
						EndIf
						//-- Indica que um documento nao pode ser vinculado a uma viagem pelo carregamento
						If	!lVgeMod2 .And. Empty(DUD->DUD_VIAGEM) .And. !lDocVge
							MsgAlert(STR0038) //"Documentos não podem ser vinculados a viagem pelo carregamento!"
							Return(.F.)
						EndIf
						lMovtoVge := .T.
						DC5->(dbSetOrder(1))
						If !Empty(DUD->DUD_SERVIC) .And. DC5->(! MsSeek(xFilial('DC5')+DUD->DUD_SERVIC))
							Help("", 1, "TMSA21012",,cSeek,2,1) // Erro ao localizar serviço operacional
							Return(.F.)
						EndIf		
													
						If lCarMult .And. (DUD->DUD_SERTMS != cSerTms .Or. DUD->DUD_TIPTRA != cTipTra)
						 	If (cSerAdi <> '1' .Or. (cSerAdi == '1' .And. DUD->DUD_SERTMS <> StrZero(1, Len (DUD->DUD_SERTMS))) )   //Servico Adicional de Coleta
								If MsgYesNo(STR0039) //'O Documento não pertence ao serviço de transporte e ou tipo de transporte da viagem. Deseja continuar?'###'Sim'###'Não'
									RecLock('DUD',.F.)
									DUD->DUD_SERTMS := cSerTms
									DUD->DUD_TIPTRA := cTipTra
									DUD->DUD_CARMUL := '1' //-- Sim
									MsUnLock()	
								Else
									Return(.F.)								
								EndIf
							EndIf	
						EndIf							
						nSeek := Ascan(aCols, {|x| !x[Len(x)] .And. x[GdFieldPos('DTA_LOCAL')] + x[GdFieldPos('DTA_LOCALI')] + x[GdFieldPos('DTA_UNITIZ')] + x[GdFieldPos('DTA_CODANA')] +;
							x[GdFieldPos('DTA_FILDOC')] + x[GdFieldPos('DTA_DOC')] + x[GdFieldPos('DTA_SERIE')] == DUH->DUH_LOCAL+DUH->DUH_LOCALI+DUH->DUH_UNITIZ+DUH->DUH_CODANA+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE} ) 
						If nSeek > 0  
							GdFieldPut('DTA_QTDVOL',aCols[nSeek][GdFieldPos('DTA_QTDVOL')]+DUH->DUH_QTDVOL,nSeek)
							lMovtoVge := .F.  
							If lCarregPar .And. DT6->DT6_DOCTMS == 'K' //-- Docto. Carregamento em Partes
								If Ascan(aDoctosPar,{ | e | e[1]+e[2]+e[3]+e[4]+e[5] == DUH->(DUH_LOCAL+DUH_LOCALI)+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE) }) == 0
									Aadd(aDoctosPar, { DUH->DUH_LOCAL, DUH->DUH_LOCALI, DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE, (DT6->DT6_VOLORI - DT6->DT6_QTDVOL) })
								EndIf								
							EndIf								
						EndIf
						Exit
					EndDo		

				Next nB
				
				If !lMovtoVge
	   				DUH->(DbSkip())
	       			Loop
				EndIf

				If cSerTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) //-- Entrega
					aFilDca := TMSRegDca(cRota,,.T.)
				Else            
					aFilDca := TMSRegDca(cRota,DT6->DT6_CDRCAL,.F.)
	            If Empty(aFilDca) 
						aFilDca := TMSRegDca(cRota,,.F.)
					EndIf
				EndIf
				
				If lAAddACols
					n++
					TMSA210Cols()
				Else
					lAAddACols := .T.
				EndIf
				
				A210Trigger(lVgeMod2)
				If lVgeMod2 .And. cSerTms != StrZero(2,Len(DC5->DC5_SERTMS)) //-- Se não for transporte
					GdFieldPut("DUD_SEQUEN",cSequen,n)
					cSequen := Soma1(cSequen)
				EndIf			
				lCarregEnd := .T.

				aRegiao := TMSNivSup(DUD->DUD_CDRCAL) // Obtem os niveis superiores da regiao de destino.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Retorna as Regioes / Filiais de Destino da Rota                       ³
				//³ Elementos contidos por dimensao:                                      ³
				//³ 1. Regiao Origem da Rota                                              ³
				//³ 2. Regioes de Destino da Rota                                         ³
				//³ 3. Filiais de Destino da Rota                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
				aRegRot := TMSRegDes(cRota)   // Obtem as regioes da rota.
				For nCntFor := 1 To Len(aRegiao)
					/* Verifica se a regiao de destino do CTRC pertence a regiao da rota. */
					lAchou := Ascan(aRegRot, {|x| x[2] == aRegiao[nCntFor]}) > 0
					If lAchou
						Exit
					EndIf
				Next nCntFor				
				
   				If lAchou
					If lVgeMod2
						GDFieldPut('DUD_STROTA','1',n)
					EndIf
				Else											
					If lVgeMod2
						If MsgYesNo( STR0025 + DUD->DUD_FILDOC + ' ' + DUD->DUD_DOC + ' ' + DUD->DUD_SERIE + ; //"Documento "
							STR0026 +Chr(13)+Chr(10) + STR0027 )  //" nao pertence a esta rota." ### "Confirma a utilização do documento ?"
							GDFieldPut('DUD_STROTA','3',n)
						Else
							If lCarMult .And. DUD->DUD_CARMUL == '1' //-- Sim
								If (cSerAdi <> '1' .Or. (cSerAdi == '1' .And. DUD->DUD_SERTMS <> StrZero(1, Len (DUD->DUD_SERTMS))) )   //Servico Adicional de Coleta
									RecLock('DUD',.F.)
									DUD->DUD_SERTMS := DT6->DT6_SERTMS
									DUD->DUD_TIPTRA := DT6->DT6_TIPTRA
									DUD->DUD_CARMUL := '2' //-- Nao
									MsUnLock()
								EndIf	
							EndIf					
							Return(.F.)
						EndIf
					EndIf						
				EndIf				
				
			EndIf
			DUH->(dbSkip())
		EndDo
		If	(cCampo == 'M->DUH_CODANA' .Or. cCampo == 'M->DUH_UNITIZ') .And. !Empty(cLocFim).And. cLocIni <> cLocFim
			Help(1,'','TMSA21026') //'O Unitizador está endereçado em endereços diferentes.' //--Verifique o endereçamento de documentos, através da rotina Endereçamento de Doctos (TMSA590).
		EndIf
		oGetD:oBrowse:nAt := n
		oGetD:oBrowse:Refresh(.T.)
		If !lCarregEnd
			If (cCampo == 'M->DTA_CODANA' .Or. cCampo == 'M->DTA_UNITIZ')
				GdFieldPut("DTA_CODANA",'',n)
				GdFieldPut("DTA_UNITIZ",'',n)				
			EndIf
			Help(' ', 1, 'TMSA21005') //-- Nao ha Documento para serem carregados neste Endereco / Local
			Return(.F.)
		ElseIf nSeek > 0
			GdFieldPut('DTA_QTDVOL',aCols[nSeek][GdFieldPos('DTA_QTDVOL')]+DUH->DUH_QTDVOL,nSeek)		
		EndIf
		For nB := 1 To Len(aDoctosPar)
			nSeek := Ascan(aCols, {|x| !x[Len(x)] .And. x[GdFieldPos('DTA_LOCAL')] + x[GdFieldPos('DTA_LOCALI')] + x[GdFieldPos('DTA_FILDOC')] +;
						x[GdFieldPos('DTA_DOC')] + x[GdFieldPos('DTA_SERIE')] == aDoctosPar[nB,1]+aDoctosPar[nB,2]+aDoctosPar[nB,3]+aDoctosPar[nB,4]+aDoctosPar[nB,5] } ) 
			If nSeek > 0
				GdFieldPut('DTA_QTDVOL',aCols[nSeek][GdFieldPos('DTA_QTDVOL')]-aDoctosPar[nB,6],nSeek)
			EndIf
		Next nB
	Else
		If (cCampo == 'M->DTA_CODANA' .Or. cCampo == 'M->DTA_UNITIZ')
			GdFieldPut("DTA_CODANA",'',n)
			GdFieldPut("DTA_UNITIZ",'',n)				
		EndIf
		Help(' ', 1, 'TMSA21005') //-- Nao ha Documento para serem carregados neste Endereco / Local
		Return(.F.)
	EndIf

	Return(.T.)
	
ElseIf cCampo == 'M->DTA_FILDOC' .Or. cCampo == 'M->DTA_DOC' .Or. cCampo == 'M->DTA_SERIE'
	If IsInCallStack("AF76VldAgd")
		cSeek := M->DTA_FILDOC + M->DTA_DOC + M->DTA_SERIE
	Else
		//-- Se um dos campos estiverem vazios nao faz a procura nos arquivos
		If	(cCampo == 'M->DTA_FILDOC' .And. (Empty(GDFieldGet( 'DTA_DOC'   , n )) .Or. Empty(GDFieldGet( 'DTA_SERIE', n )) ) ) .Or. ;
			(cCampo == 'M->DTA_DOC'    .And. (Empty(GDFieldGet( 'DTA_FILDOC', n )) .Or. Empty(GDFieldGet( 'DTA_SERIE', n )) ) ) .Or. ;
			(cCampo == 'M->DTA_SERIE'  .And. (Empty(GDFieldGet( 'DTA_FILDOC', n )) .Or. Empty(GDFieldGet( 'DTA_DOC'  , n )) ) )
			Return .T.
		EndIf
	
		//-- Verifica se o Filial Documento + Documento + Serie ja foram Informados
		If cCampo == 'M->DTA_FILDOC'
			cSeek  :=  M->DTA_FILDOC + GDFieldGet( 'DTA_DOC', n ) + GDFieldGet( 'DTA_SERIE', n )
		ElseIf cCampo == 'M->DTA_DOC'
			cSeek  :=  GDFieldGet( 'DTA_FILDOC', n ) + M->DTA_DOC + GDFieldGet( 'DTA_SERIE', n )
		ElseIf cCampo == 'M->DTA_SERIE'
			cSeek  :=  GDFieldGet( 'DTA_FILDOC', n ) + GDFieldGet( 'DTA_DOC', n ) + M->DTA_SERIE
		EndIf
	EndIf

	//-- Posiciona no documento
	DT6->(dbSetOrder(1))
	DT6->(dbSeek(xFilial("DT6")+cSeek))

	If lCONTDOC .And. !TmsConTran(SubStr(cSeek,1,TamSx3("DTA_FILDOC")[1]),;
								  SubStr(cSeek,TamSx3("DTA_FILDOC")[1] + 1,TamSx3("DTA_DOC")[1]),;
								  SubStr(cSeek,TamSx3("DTA_FILDOC")[1] + TamSx3("DTA_DOC")[1] + 1,TamSx3("DTA_SERIE")[1]),.T.)
		Return (.F.)
	EndIf

	If lTMS3GFE .And. DT6->DT6_SERTMS == StrZero(1,Len(DT6->DT6_SERTMS))  .And. cPagGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE)) 
		If DT6->DT6_QTDVOL == 0 .And.  DT6->DT6_PESO == 0 .And. DT6->DT6_PESOM3 == 0 .And. DT6->DT6_VALMER == 0
			Help(' ', 1, 'TMSA21062') //-- Para a viagem com pagamento pelo SIGAGFE, é necessario que um dos dados da Solicitação de Coleta esteja 
			Return(.F.)               //--  preenchido:  Volume, Peso, Peso Cubado, Valor da Mercadoria. 
		EndIf
	EndIf

	//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
	If !IsInCallStack("AF76VldAgd")
		If lColeta
			If !TMSAVerAge("3",,,,,,,,,DT6->DT6_FILDOC,DT6->DT6_DOC,,"2",.T.,.T.,,,StrZero(ThreadId(),20))
				GDFieldPut( 'DTA_FILDOC', Criavar("DTA_FILDOC")		, n )
				GDFieldPut( 'DTA_DOC' 	, Criavar("DTA_DOC") 		, n )
				GDFieldPut( 'DTA_SERIE' , Criavar("DTA_SERIE") 		, n )
				Return .F.
			EndIf
		Else
			If !TMSAVerAge("1",DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,,,,,,,,"2",.T.,.T.,,,StrZero(ThreadId(),20))
				GDFieldPut( 'DTA_FILDOC', Criavar("DTA_FILDOC")		, n )
				GDFieldPut( 'DTA_DOC' 	, Criavar("DTA_DOC") 		, n )
				GDFieldPut( 'DTA_SERIE' , Criavar("DTA_SERIE") 		, n )
				Return .F.
			EndIf
		EndIf
	EndIf

	If Empty(DT6->DT6_DOCDCO) //--Carregamento Total
		nValFre := DT6->DT6_VALFRE //--Valor do Frete Total
	Else
		aAreaDT6 := DT6->(GetArea())
		DT6->(dbSeek(xFilial("DT6")+DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO))
		nValFre := DT6->DT6_VALFRE //--Valor do Frete Total
		RestArea(aAreaDT6)
		
		cSeekCar := DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO //--Filial e Documento no Carregamento Parcial
		aAreaDTA := DTA->(GetArea())
		DTA->(dbSetOrder(1))
		If DTA->(dbSeek(cSeekDTA := xFilial('DTA')+cSeekCar))  
			nFreCar += DTA->DTA_VALFRE //Soma os valores de frete ja carregados
		EndIf	
		RestArea(aAreaDTA)  
		
		//---- Soma os valores referente ao Carregamento Parcial - P01,P02,....///  
	 	cSeekDT6 := DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO 
		If !Empty(cSeekDT6)
			aAreaDTA := DTA->(GetArea()) 
			aAreaDT6 := DT6->(GetArea())	
			DT6->(dbSetOrder(8))
			If DT6->(dbSeek(cSeekDT6 := xFilial('DT6')+cSeekDT6)) 
				While DT6->( !Eof() ) .And. DT6->DT6_FILIAL+DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO == cSeekDT6
					DTA->(dbSetOrder(1))
					If DTA->(dbSeek(cSeekDTA := xFilial('DTA')+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE ))
			  			nFreCar += DTA->DTA_VALFRE //Soma os valores de frete ja carregados
					EndIf	                                                               
					DT6->(DbSkip())
				EndDo
			EndIf 
			RestArea(aAreaDTA)  
			RestArea(aAreaDT6)  
		EndIf
	EndIf
		
	//--No Transporte Internacional, nao podemos ter valor do frete zerado, desde que não seja uma sol. de coleta.
	If DT6->DT6_TIPTRA == "4" .And. nValFre == 0  .And.  DT6->DT6_DOCTMS != StrZero(1,Len(DT6->DT6_DOCTMS)) //Transporte Internacional
		If IsInCallStack("AF76VldAgd")
			If !Empty(aAgendPend)
				Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0058})
			EndIf
		Else
			MsgAlert(STR0058) //--"O CRT esta com valor de frete zerado, verifique antes de prosseguir a operacao"
		EndIf
		Return(.F.)
	EndIf
	
	DTP->(dbSetOrder(2))
	If DTP->(MsSeek(xFilial("DTP") + DT6->DT6_FILORI + DT6->DT6_LOTNFC)) 
        // Viagem de entrega, status em transito e viagem com o mesmo do lote da viagem 
        If DT6->DT6_SERTMS == StrZero(3,Len(DT6->DT6_SERTMS)) .AND. DTQ->DTQ_STATUS == "2" 
			If DTP->DTP_VIAGEM <> DTQ->DTQ_VIAGEM
            	Help("", 1, "TMSA21067") // Para viagens em trânsito, só é permitido incluir documentos que tenham sido gerados em lotes vinculados à Viagem, ou seja, o campo Viagem (DTP_VIAGEM) deve estar preenchido com o mesmo número da viagem em que o documento está sendo inserido!
            	Return .F.
			Else
				If ExistFunc("Tm350Apoio")  
					aAreaAnt:= GetArea()
					lRet:= Tm350Apoio(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)
					RestArea(aAreaAnt)
					If !lRet
						Return .F.
					EndIf						
				EndIf
			EndIf	
        EndIf
		If !Empty(DTQ->DTQ_VIAGEM) .and. !TMS210VLOT(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, DT6->DT6_LOTNFC)
			If IsInCallStack("AF76VldAgd")
				If !Empty(aAgendPend)
					Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0076})
				EndIf
			Else
				Help("", 1, "TMSA21067") // Para viagens em trânsito, só é permitido incluir documentos que tenham sido gerados em lotes vinculados à Viagem, ou seja, o campo Viagem (DTP_VIAGEM) deve estar preenchido com o mesmo número da viagem em que o documento está sendo inserido!
			EndIf
			Return( .F. )
		EndIf
	EndIf
	
	//--- Verifica se o documento de coleta é com criterio de Rateio
	If lTMSItCt .And. !Empty(M->DTQ_ROTA)  .And. !F11RotRote(M->DTQ_ROTA) .And. FindFunction("F11RotRote")  
		If DT6->DT6_SERTMS == StrZero(1,Len(DT6->DT6_SERTMS))
			If !Empty(DT6->DT6_CODNEG) .And. !Empty(DT6->DT6_SERVIC)  
				cCriRat:= TMSA144DcR(DT6->DT6_NCONTR,DT6->DT6_CODNEG,DT6->DT6_SERVIC)	
				If cCriRat == "A" //-- 'A' = Origem/Destino Vge
					If IsInCallStack("AF76VldAgd")
						If !Empty(aAgendPend)
							Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0074 + cCriRat + " = " + ;
									TMSValField('cCriRat',.F.) + " " + STR0075})
						EndIf
					Else
						MsgAlert(STR0074 + cCriRat + " = " + TMSValField('cCriRat',.F.) + " " + ; 
						         STR0075)	//-- "Documentos com criterio de Rateio - " # " não podem ser vinculados a uma Rota por Cep/Cliente."
					EndIf
					Return (.F.)
				EndIf								
			EndIf
		EndIf
	
	EndIf
	/////////////////////////////////////////////////////////////////////
	// EXECUTAR PROCESSO DO CTe APENAS COM PARAMETRO HABILITADO			 //
	/////////////////////////////////////////////////////////////////////

	//-- Ponto de Entrada utilizado desabilitar a validacao se o CTE está autorizado
	If lTM210VCte
		lRetPE := ExecBlock('TM210VCTE',.F.,.F.)
		If ValType(lRetPE) # "L"
			lRetPE := .T.
		EndIf	
	Else
		lRetPE := .T.
	EndIf


	If (lTMSCTe) .And. lRetPE .And. !IsInCallStack("TMSAF76")
		/////////////////////////////////////////////////////////////////////
		// Checar o Status do Documento no Processo CT-e.                  //
		// 	DT6_IDRCTE == 100 ("Autorizado o uso do CT-e")	             //
		// 	DTP_TIPLOT == 3 (Eletronico) 4 Para CT-e Unico                 //
		/////////////////////////////////////////////////////////////////////
		DTP->(dbSetOrder(2))
		If DTP->(MsSeek(xFilial("DTP") + DT6->DT6_FILORI + DT6->DT6_LOTNFC)) .And. (DTP->DTP_TIPLOT == StrZero(3,Len(DTP->DTP_TIPLOT)) .Or. DTP->DTP_TIPLOT == StrZero(4,Len(DTP->DTP_TIPLOT)))
			lRet:= Iif( DT6->(FieldPos("DT6_CHVCTG")) > 0,  Alltrim(DT6->DT6_IDRCTE) == "100"  .Or. Alltrim(DT6->DT6_IDRCTE) == "136" .Or. !Empty(DT6->DT6_CHVCTG) , Alltrim(DT6->DT6_IDRCTE) == "100" .Or. Alltrim(DT6->DT6_IDRCTE) == "136" .OR. DT6->DT6_SITCTE<>"2")
    	    // Documento Nao estando com alguma das Nao Conformidades Validadas acima		//
    	    // mas Eh um dos seguintes tipos, o processo sera Autorizado a dar continuidade //
    	    If !lRet .And. ( Alltrim(DT6->DT6_DOCTMS) == StrZero( 5, Len( DT6->DT6_DOCTMS ) ) .Or.;    //--Nota Fiscal de Serv. de Transp.
                             Alltrim(DT6->DT6_DOCTMS) == Replicate('D', Len( DT6->DT6_DOCTMS ) ) .Or.; //--Nota Fiscal de Reentrega
                             Alltrim(DT6->DT6_DOCTMS) == Replicate('F', Len( DT6->DT6_DOCTMS ) ) .Or.; //--Nota Fiscal de Armazenagem
                             Alltrim(DT6->DT6_DOCTMS) == Replicate('G', Len( DT6->DT6_DOCTMS ) ) )     //--Nota Fiscal de Complemento
				lRet := .T.
    	    EndIf
    	    If !lRet
				If IsInCallStack("AF76VldAgd")
					If !Empty(aAgendPend)
						Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0077})
					EndIf
				Else
					Help('',1,'TMSA21025') //"CT-e não autorizado ou não enviado para Sefaz."
				EndIf
				Return(.F.)
			EndIf
		EndIf
	EndIf	
	//-- Valida se o doc e' de Redespacho e se o Status do DT6 esta diferente de 1-aberto ou 5-Chegada em Filial.
	DFV->( DbSetOrder ( 2 ) )          
	If DFV->(  dBSeek( xFilial("DFV") + cSeek ) ) .And. DFV->DFV_STATUS<>StrZero(1,Len(DFV->DFV_STATUS))
		If !(DT6->DT6_STATUS==StrZero( 1, Len( DT6->DT6_STATUS ) ) .Or. DT6->DT6_STATUS==StrZero( 5,Len( DT6->DT6_STATUS ) ))
			If IsInCallStack("AF76VldAgd")
				If !Empty(aAgendPend)
					Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0078})
				EndIf
			Else
				Help(" ", 1, "TMSA21024") //"Documento com Status diferente de","1-Aberto ou 5-Chegada em Filial"
			EndIf
			Return( .F. )			
	   EndIf
	EndIf

	cSeekDUD  += (cSeek + Iif(lTMSDCol,"",cFilAnt))
	lMovtoVge := .F.
	
	dbSelectArea("DUD") 
	dbSetOrder(1)
	If !MsSeek(xFilial("DUD")+cSeekDUD)
		cSeekDUD := cSeek + Iif(lTMSDCol,"",cFilOri)
		MsSeek(xFilial("DUD")+cSeekDUD)
	EndIf
	While !Eof() .And. DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+Iif(lTMSDCol,"",DUD_FILORI) == xFilial("DUD")+cSeekDUD
		If lCarMult .And. (cSerAdi <> '1' .Or. (cSerAdi == '1' .And. DUD->DUD_SERTMS <> StrZero(1, Len (DUD->DUD_SERTMS))) )   //Servico Adicional de Coleta
			If ( !Empty(DUD->DUD_VIAGEM) .And. DUD->DUD_FILORI+DUD->DUD_VIAGEM != cFilOri+cViagem ) .Or. DUD->DUD_STATUS != StrZero(1,Len(DUD->DUD_STATUS))
				dbSkip()
				Loop
			EndIf
		Else
			If (DUD->DUD_SERTMS != cSerTms .And. Iif(!Empty(cSerAdi),DUD->DUD_SERTMS != cSerAdi,.T.)) .Or. DUD->DUD_TIPTRA != cTipTra .Or. (!Empty(DUD->DUD_VIAGEM) .And. DUD->DUD_FILORI+DUD->DUD_VIAGEM != cFilOri+cViagem .And. !lVgeExpr) .Or. ;
				 DUD->DUD_STATUS != StrZero(1,Len(DUD->DUD_STATUS)) .And. !lVgeExpr
				DbSkip()    
				Loop	
			EndIf
		EndIf			
		lMovtoVge := .T.
		//-- !VgeExpr utilizado pois caso uma viagem TMSEXPRESS gerencia o carregamento
		//--  e o serviço operacional.
		If !lColeta .And. !lVgeExpr
			If DUD_STATUS != StrZero( 1, Len( DUD_STATUS ) ) // Em Aberto
				If IsInCallStack("AF76VldAgd")
					If !Empty(aAgendPend)
						Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0079})
					EndIf
				Else
					Help("", 1, "TMSA21010",,cSeek,2,1) // "Documento ja carregado
				EndIf
				Return(.F.)
			EndIf				
			DC5->(dbSetOrder(1))
			If !Empty(DUD->DUD_SERVIC) .And. DC5->(! MsSeek(xFilial('DC5')+DUD->DUD_SERVIC))
				If IsInCallStack("AF76VldAgd")
					If !Empty(aAgendPend)
						Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0080})
					EndIf
				Else
					Help("", 1, "TMSA21012",,cSeek,2,1) // Erro ao localizar serviço operacional
				EndIf
				Return(.F.)
			EndIf			
		EndIf			
		If lCarMult .And. (DUD->DUD_SERTMS != cSerTms .Or. DUD->DUD_TIPTRA != cTipTra)
			If (cSerAdi <> '1' .Or. (cSerAdi == '1' .And. DUD->DUD_SERTMS <> StrZero(1, Len (DUD->DUD_SERTMS))) )   //Servico Adicional de Coleta
				If MsgYesNo(STR0039) //'O Documento não pertence ao serviço de transporte e ou tipo de transporte da viagem. Deseja continuar?'###'Sim'###'Não'
					RecLock('DUD',.F.)
					DUD->DUD_SERTMS := cSerTms
					DUD->DUD_TIPTRA := cTipTra
					DUD->DUD_CARMUL := '1' //-- Sim
					MsUnLock()	
				Else
					Return(.F.)			
				EndIf
			EndIf	
		EndIf							
		//-- Para viagem modelo 2, verifica se o documento pertence a rota informada
		If lVgeMod2 
			If cSerTms != StrZero(2,Len(DC5->DC5_SERTMS)) .And. ;
				!TmsA144DPC(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE) .And. ;
				!TmsA144DA7(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,,,,,,,,@aAgendPend)
				If lCarMult .And. DUD->DUD_CARMUL == '1' //-- Sim
					If (cSerAdi <> '1' .Or. (cSerAdi == '1' .And. DUD->DUD_SERTMS <> StrZero(1, Len (DUD->DUD_SERTMS))) )   //Servico Adicional de Coleta
						RecLock('DUD',.F.)
						DUD->DUD_SERTMS := DT6->DT6_SERTMS
						DUD->DUD_TIPTRA := DT6->DT6_TIPTRA
						DUD->DUD_CARMUL := '2' //-- Nao
						MsUnLock()
					EndIf	
				EndIf					
				Return(.F.)
			EndIf				
		Else			
			//-- Indica que um documento nao pode ser vinculado a uma viagem pelo carregamento
			If	Empty(DUD->DUD_VIAGEM) .And. !lDocVge
				If IsInCallStack("AF76VldAgd")
					If !Empty(aAgendPend)
						Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0081})
					EndIf
				Else
					Help('',1,'TMSA21014')	//-- Este documento nao pode ser vinculado a uma viagem atraves do carregamento
				EndIf
				If lCarMult .And. DUD->DUD_CARMUL == '1' //-- Sim
					If (cSerAdi <> '1' .Or. (cSerAdi == '1' .And. DUD->DUD_SERTMS <> StrZero(1, Len (DUD->DUD_SERTMS))) )   //Servico Adicional de Coleta
						RecLock('DUD',.F.)
						DUD->DUD_SERTMS := DT6->DT6_SERTMS
						DUD->DUD_TIPTRA := DT6->DT6_TIPTRA
						DUD->DUD_CARMUL := '2' //-- Nao
						MsUnLock()
					EndIf	
				EndIf					
				Return(.F.)
			EndIf
		EndIf
		
		If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) //-- Transporte
			If lVgeMod2 .Or. (lDocVge .And. DUD->DUD_GERROM == StrZero(2,Len(DUD->DUD_GERROM))) //-- Nao gera romaneio.
				//--Passamos Regiao de Calculo pois se nao sofreu alteracao e a mesma da regiao de destino,
				//--se alterar precisamos sempre considerar a Regiao de Calculo
				aRegiao := TMSNivSup(DUD->DUD_CDRCAL) // Obtem os niveis superiores da regiao de destino.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Retorna as Regioes / Filiais de Destino da Rota                       ³
				//³ Elementos contidos por dimensao:                                      ³
				//³ 1. Regiao Origem da Rota                                              ³
				//³ 2. Regioes de Destino da Rota                                         ³
				//³ 3. Filiais de Destino da Rota                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
				aRegRot := TMSRegDes(cRota)   // Obtem as regioes da rota.
				For nCntFor := 1 To Len(aRegiao)
					/* Verifica se a regiao de destino do CTRC pertence a regiao da rota. */
					lAchou := Ascan(aRegRot, {|x| x[2] == aRegiao[nCntFor]}) > 0
					If lAchou
						Exit
					EndIf
				Next nCntFor
				If lAchou
					If lVgeMod2
						GDFieldPut('DUD_STROTA','1',n)
					EndIf
				Else											
					If lVgeMod2
						If MsgYesNo( STR0025 + DUD->DUD_FILDOC + ' ' + DUD->DUD_DOC + ' ' + DUD->DUD_SERIE + ; //"Documento "
							STR0026 +Chr(13)+Chr(10) + STR0027 )  //" nao pertence a esta rota." ### "Confirma a utilização do documento ?"
							GDFieldPut('DUD_STROTA','3',n)
						Else
							If lCarMult .And. DUD->DUD_CARMUL == '1' //-- Sim
								If (cSerAdi <> '1' .Or. (cSerAdi == '1' .And. DUD->DUD_SERTMS <> StrZero(1, Len (DUD->DUD_SERTMS))) )   //Servico Adicional de Coleta
									RecLock('DUD',.F.)
									DUD->DUD_SERTMS := DT6->DT6_SERTMS
									DUD->DUD_TIPTRA := DT6->DT6_TIPTRA
									DUD->DUD_CARMUL := '2' //-- Nao
									MsUnLock()
								EndIf	
							EndIf					
							If IsInCallStack("AF76VldAgd")
								If !Empty(aAgendPend)
									Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0025 + STR0026})
								EndIf
							EndIf
							Return(.F.)
						EndIf
					Else													
						If IsInCallStack("AF76VldAgd")
							If !Empty(aAgendPend)
								Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0082})
							EndIf
						Else
							Help("",1,"TMSA21007") // A regiao de destino do CTRC nao pertence a regiao da rota.
						EndIf
						If lCarMult .And. DUD->DUD_CARMUL == '1' //-- Sim
							If (cSerAdi <> '1' .Or. (cSerAdi == '1' .And. DUD->DUD_SERTMS <> StrZero(1, Len (DUD->DUD_SERTMS))) )   //Servico Adicional de Coleta
								RecLock('DUD',.F.)
								DUD->DUD_SERTMS := DT6->DT6_SERTMS
								DUD->DUD_TIPTRA := DT6->DT6_TIPTRA
								DUD->DUD_CARMUL := '2' //-- Nao
								MsUnLock()
							EndIf	
						EndIf					
						Return( .F. )
					EndIf						
				EndIf
			EndIf
		EndIf			
		Exit
	EndDo		
	
	If !lMovtoVge
		
		If lCarMult .And. DUD->DUD_CARMUL == '1' //-- Sim
			If (cSerAdi <> '1' .Or. (cSerAdi == '1' .And. DUD->DUD_SERTMS <> StrZero(1, Len (DUD->DUD_SERTMS))) )   //Servico Adicional de Coleta
				RecLock('DUD',.F.)
				DUD->DUD_SERTMS := DT6->DT6_SERTMS
				DUD->DUD_TIPTRA := DT6->DT6_TIPTRA
				DUD->DUD_CARMUL := '2' //-- Nao
				MsUnLock()
			EndIf	
		EndIf
		If !IsInCallStack ("TMSA144NFC") .And. !IsInCallStack("TMSAF76")
			If IsInCallStack("AF76VldAgd")
				If !Empty(aAgendPend)
					Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0083})
				EndIf
			Else
  				Help("", 1, "TMSA21011",,cSeek,2,18) // "Erro ao localizar movimento de viagem para o documento
			EndIf
			Return(.F.)
		EndIf
	EndIf

	//-- Posiciona no documento
	DT6->(dbSetOrder(1))
	DT6->(MsSeek(xFilial("DT6")+cSeek))
	If FindFunction("TMSA146Prg") .And. !IsInCallStack(AllTrim('TMSA146'))
		DbSelectArea("DF8")
		If DF8->(ColumnPos("DF8_SEQPRG")) > 0
			lRet:= TMSA146Prg(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,@cFilDF8,@cNumDF8)
			If !lRet
				If IsInCallStack("AF76VldAgd")
					If !Empty(aAgendPend)
						Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0084})
					EndIf
				Else
					Help("",1,"TMSA21061",,cFilDF8 + ' - ' + cNumDF8 ,2,18) // Documento já está em uma Programação de Carregamento: 	
				EndIf
				Return lRet
			EndIf
		EndIf	
	EndIf

	//--- Valida se o Docto está em um Roteirização - Planejamento de Rotas (TPR)
	If lRet .And. lIntTPR .And. FindFunction('T146DocTPR') 
		lRet:= T146DocTPR(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
		If !lRet
			Return lRet
		EndIf
	EndIf
	
	If lColeta .Or. (cSerAdi == '1' .And. DUD->DUD_SERTMS == StrZero(1, Len (DUD->DUD_SERTMS)) )
		If DT6->DT6_BLQDOC == '1'
			If IsInCallStack("AF76VldAgd")
				If !Empty(aAgendPend)
					Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0085})
				EndIf
			Else
				Help("",1,"TMSA21003") // Documento Bloqueado ...
			EndIf
			If lCarMult .And. DUD->DUD_CARMUL == '1' //-- Sim
				If (cSerAdi <> '1' .Or. (cSerAdi == '1' .And. DUD->DUD_SERTMS <> StrZero(1, Len (DUD->DUD_SERTMS))) )   //Servico Adicional de Coleta
					RecLock('DUD',.F.)
					DUD->DUD_SERTMS := DT6->DT6_SERTMS
					DUD->DUD_TIPTRA := DT6->DT6_TIPTRA
					DUD->DUD_CARMUL := '2' //-- Nao
					MsUnLock()
				EndIf	
			EndIf					
			Return .F.
		EndIf
		
		//-- Posiciona na ordem de coleta
		DT5->(dbSetOrder(1))
		DT5->(MsSeek(xFilial('DT5')+cSeek))
		//-- Posiciona no solicitante    
		DUE->(dbSetOrder(1))
		DUE->(MsSeek(xFilial('DUE')+DT5->(DT5_CODSOL)))
		//-- Obtem o endereco da coleta
		If Empty(DT5->DT5_SEQEND)
			cBaiCol := DUE->DUE_BAIRRO
			cMunCol := DUE->DUE_MUN
			cEstCol := DUE->DUE_EST
		Else
			DUL->(dbSetOrder(3))
			DUL->(MsSeek(xFilial('DUL')+DT5->(DT5_CODSOL+DT5_SEQEND)))
			cBaiCol := DUL->DUL_BAIRRO
			cMunCol := DUL->DUL_MUN
			cEstCol := DUL->DUL_EST
		EndIf
		If lTmsCFec
			aAreaDF1 := DF1->(GetArea())
			DF1->(dbSetOrder(3))
			If DF1->(MsSeek(xFilial('DF1')+DT5->(DT5_FILDOC+DT5_DOC+DT5_SERIE))) .And. !Empty(DF1->DF1_DOC)
				If !IsInCallStack("AF76VldAgd")
					GdFieldPut('DF1_NUMAGE',DF1->DF1_NUMAGE,n)
					GdFieldPut('DF1_ITEAGE',DF1->DF1_ITEAGE,n)
				EndIf
				cAgenRem := Posicione("SA1",1,xFilial("SA1")+DF1->(DF1_CLIREM+DF1_LOJREM),"A1_NREDUZ")      
				cAgenDes := Posicione("SA1",1,xFilial("SA1")+DF1->(DF1_CLIDES+DF1_LOJDES),"A1_NREDUZ")
			EndIf
			RestArea( aAreaDF1 )
		EndIf
		If lColeta							
			If !IsInCallStack("AF76VldAgd")
				GdFieldPut('DUE_NOME'  ,DUE->DUE_NOME  ,n) //-- Solicitante   
			EndIf
		ElseIf !Empty(cAgenRem) .Or. !Empty(cAgenDes) 	//-- Agendamento del126 
			If !IsInCallStack("AF76VldAgd")
				GDFieldPut( 'DT6_NOMREM', cAgenRem, n )    
				GDFieldPut( 'DT6_NOMDES', cAgenDes, n )   
				GdFieldPut( 'DT6_VOLORI', DT6->DT6_QTDVOL , n )	  
			EndIf
		Else
			If !IsInCallStack("AF76VldAgd")
				GDFieldPut( 'DT6_NOMREM', DUE->DUE_NREDUZ, n )    // Remetente
				GDFieldPut( 'DT6_NOMDES', Posicione("SA1",1,xFilial("SA1")+DT5->(DT5_CLIDES+DT5_LOJDES),"A1_NREDUZ"), n )  
				GdFieldPut( 'DT6_VOLORI', DT6->DT6_QTDVOL , n )	  // Valor Original
			EndIf
		EndIf
		If !IsInCallStack("AF76VldAgd")
			GdFieldPut('DUE_BAIRRO',cBaiCol        ,n) //-- Bairro      
			GdFieldPut('DUE_MUN'   ,cMunCol        ,n) //-- Municipio
			GdFieldPut('DUE_EST'   ,cEstCol        ,n) //-- Estado
			GdFieldPut('DT5_DATPRV',DT5->DT5_DATPRV,n) //-- Data Pre.Col
			GdFieldPut('DT5_HORPRV',DT5->DT5_HORPRV,n) //-- Hora Pre.Col
			GdFieldPut('DTA_QTDVOL',DT6->DT6_QTDVOL,n) //-- Qtde.Volume
			GdFieldPut('DT6_PESO'  ,DT6->DT6_PESO  ,n) //-- Peso
			GdFieldPut('DT6_PESOM3',DT6->DT6_PESOM3,n) //-- Peso Cubado
			GdFieldPut('DT6_VALMER',DT6->DT6_VALMER,n) //-- Vlr. Mercadoria
			GDFieldPut('DTA_SERIE' ,DT6->DT6_SERIE ,n) //-- Serie (Ainda em memoria, efetivado no campo)
			//--- Preenche campos para integracao GFE
			If lTMS3GFE .And. lVgeMod2 .And. M->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))  //Sim
				Tmsa210GFE(n, cSerTms, cFilOri, cViagem)
			EndIf
			
			//-- Atualizando valores do Rodape
			TmsA210Rdp()
			//
			oGetD:oBrowse:Refresh(.T.)	
		EndIf
		Return(.T.)
	ElseIf cSerTms == '3' //-- Entrega
		If lAgdEntr .And. !Empty(DT6->DT6_NUMAGD)
			DYD->(dbSetOrder(1))
			DYD->(dbSeek(xFilial('DYD')+DT6->(DT6_NUMAGD+DT6_ITEAGD)))
			If !IsInCallStack("AF76VldAgd")
				GdFieldPut('DTA_TIPAGD',DYD->DYD_TIPAGD,n)
				GdFieldPut('DTA_DATAGD',DYD->DYD_DATAGD,n)
				GdFieldPut('DTA_PRDAGD',DYD->DYD_PRDAGD,n)
				GdFieldPut('DTA_INIAGD',DYD->DYD_INIAGD,n)
				GdFieldPut('DTA_FIMAGD',DYD->DYD_FIMAGD,n)
			EndIf
		EndIf			
	EndIf		
     
   cSeekDTC := cSeek                                                                  
   //-- Se for documento de Devolucao, posiciona na tabela DY4 para achar os vínculos entre DT6 X DTC      
	If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
		If DT6->DT6_TIPTRA == StrZero(4, Len(DT6->DT6_TIPTRA)) .And.  !Empty(DT6->DT6_DOCDCO) 
			cSeekDTC := DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO
		EndIf	 
		DbSelectArea("DTC")
		DTC->(DbSetOrder(3)) //Fil.Docto. + No.Docto. + Serie Docto. + Servico + Cod. Produto   		
   		lRetDTC := MsSeek(xFilial("DTC")+cSeekDTC)   			
   	Else
   		DbSelectArea("DY4")
   		DY4->(DbSetOrder(1)) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
		lRetDY4 := MsSeek(xFilial("DY4")+cSeekDTC)		
	Endif
	
	If lRetDTC
		If !(DTC->DTC_SERIE <> 'PED' .And. !Empty(DTC->DTC_DOC))		
			lRet := .F.
		Endif		
	Elseif lRetDY4
		If !(DY4->DY4_SERIE <> 'PED' .And. !Empty(DY4->DY4_DOC))
			lRet := .F.
		Endif
	Else
		lRet := .F.	
	Endif	
	
	If lRet
					
		If DT6->DT6_BLQDOC == '1'
			If IsInCallStack("AF76VldAgd")
				If !Empty(aAgendPend)
					Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0085})
				EndIf
			Else
				Help("",1,"TMSA21003") // Documento Bloqueado ...
			EndIf
			Return .F.
		ElseIf DT6->DT6_PRIPER == '1'
			If IsInCallStack("AF76VldAgd")
				If !Empty(aAgendPend)
					Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0087})
				EndIf
			Else
				Help("",1,"TMSA21004") // Este Documento nao podera ser carregado pois esta configurado como sendo de 1o. percurso
			EndIf
			Return .F.
		EndIf
		
		If !lVgeMod2
			If cSerTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) // Viagem de Entrega
				aFilDca := TMSRegDca(cRota,,.T.)
			Else            
				aFilDca := TMSRegDca(cRota,DT6->DT6_CDRCAL,.F.)
			Endif	
      	   If Empty(aFilDca) 
				aFilDca := TMSRegDca(cRota,,.F.)				
			EndIf
		EndIf	
		
		If lLocaliza .AND. lRetDTC .And. !IsInCallStack("AF76VldAgd")
			lExistDUH := .F.
			While DTC->(!Eof()) .And. DTC->DTC_FILIAL+DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE == xFilial('DTC')+cSeekDTC 					

				cSeekDUH := cFilAnt + DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM+DTC->DTC_CODPRO
				bWhile	:= {|| DUH->(! Eof() .And. DUH->DUH_FILORI+DUH->DUH_NUMNFC+DUH->DUH_SERNFC+DUH->DUH_CLIREM+DUH->DUH_LOJREM+DUH->DUH_CODPRO == cSeekDUH) }

				DbSelectArea('DUH')
				DbSetOrder(1)
				If MsSeek(xFilial('DUH')+cSeekDUH) .And. DUH->DUH_STATUS == StrZero(1,Len(DUH->DUH_STATUS))
					lExistDUH := .T.
					While Eval(bWhile)
						nSeek:=AScan(aCols, {|x| !x[Len(x)] .And. x[GdFieldPos('DTA_UNITIZ')]+  x[GdFieldPos('DTA_CODANA')] + IIf(lLocaliza,x[GdFieldPos('DTA_LOCAL')]+  x[GdFieldPos('DTA_LOCALI')],"") + ;
							x[GdFieldPos('DTA_FILDOC')] + x[GdFieldPos('DTA_DOC')] + x[GdFieldPos('DTA_SERIE')] == DUH->DUH_UNITIZ + DUH->DUH_CODANA + IIf(lLocaliza,DUH->DUH_LOCAL + DUH->DUH_LOCALI,"")+cSeek } )
						If (nSeek > 0) .Or. (DUH_STATUS <> '1')
							GdFieldPut('DTA_QTDVOL', aCols[nSeek][GdFieldPos('DTA_QTDVOL')]+DUH->DUH_QTDVOL, nSeek)					
							GdFieldPut('DT6_VOLORI',DT6->DT6_VOLORI,nSeek)	
							dbSkip()
							Loop
						EndIf
						If lAAddACols
							n++
							TMSA210Cols()
						Else
							lAAddACols := .T.
						EndIf
						
						aRegiao := TMSNivSup(DUD->DUD_CDRCAL) // Obtem os niveis superiores da regiao de destino.
						
						For nCntFor := 1 To Len(aRegiao)
							/* Verifica se a regiao de destino do CTRC pertence a regiao da rota. */
							lAchou := Ascan(aRegRot, {|x| x[2] == aRegiao[nCntFor]}) > 0
							If lAchou
								Exit
							EndIf
						Next nCntFor
						
						If lAchou .And. lVgeMod2
							GDFieldPut('DUD_STROTA','1',n)
						Else
							GDFieldPut('DUD_STROTA','3',n)
						EndIf							
						A210Trigger(lVgeMod2)
						dbSelectArea("DUH")
						dbSkip()
					EndDo
				EndIf
				DTC->(dbSkip())
			EndDo
		ElseIf lLocaliza .AND. lRetDY4 .And. !IsInCallStack("AF76VldAgd")
			lExistDUH := .F.
			While DY4->(!Eof()) .And. DY4->DY4_FILIAL+DY4->DY4_FILDOC + DY4->DY4_DOC + DY4->DY4_SERIE == xFilial('DTC')+cSeekDTC 					

				If	lProduto
					cSeekDUH := cFilAnt + DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM+DY4->DY4_CODPRO
					bWhile	:= {|| DUH->(! Eof() .And. DUH->DUH_FILORI+DUH->DUH_NUMNFC+DUH->DUH_SERNFC+DUH->DUH_CLIREM+DUH->DUH_LOJREM+DUH->DUH_CODPRO == cSeekDUH) }
				Else
					cSeekDUH := cFilAnt + DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM
					bWhile	:= {|| DUH->(! Eof() .And. DUH->DUH_FILORI+DUH->DUH_NUMNFC+DUH->DUH_SERNFC+DUH->DUH_CLIREM+DUH->DUH_LOJREM == cSeekDUH) }
				EndIf

				DbSelectArea('DUH')
				DbSetOrder(1)
				If MsSeek(xFilial('DUH')+cSeekDUH) .And. DUH->DUH_STATUS == StrZero(1,Len(DUH->DUH_STATUS))
					lExistDUH := .T.
					While Eval(bWhile)
						nSeek:=AScan(aCols, {|x| !x[Len(x)] .And. x[GdFieldPos('DTA_UNITIZ')]+  x[GdFieldPos('DTA_CODANA')] + IIf(lLocaliza,x[GdFieldPos('DTA_LOCAL')]+  x[GdFieldPos('DTA_LOCALI')],"") + ;
							x[GdFieldPos('DTA_FILDOC')] + x[GdFieldPos('DTA_DOC')] + x[GdFieldPos('DTA_SERIE')] == DUH->DUH_UNITIZ + DUH->DUH_CODANA + IIf(lLocaliza,DUH->DUH_LOCAL + DUH->DUH_LOCALI,"")+cSeek } )
						If (nSeek > 0) .Or. (DUH_STATUS <> '1')
							GdFieldPut('DTA_QTDVOL', aCols[nSeek][GdFieldPos('DTA_QTDVOL')]+DUH->DUH_QTDVOL, nSeek)					
							GdFieldPut('DT6_VOLORI',DT6->DT6_VOLORI,nSeek)	
							dbSkip()
							Loop
						EndIf
						If lAAddACols
							n++
							TMSA210Cols()
						Else
							lAAddACols := .T.
						EndIf
						
						aRegiao := TMSNivSup(DUD->DUD_CDRCAL) // Obtem os niveis superiores da regiao de destino.
						
						For nCntFor := 1 To Len(aRegiao)
							/* Verifica se a regiao de destino do CTRC pertence a regiao da rota. */
							lAchou := Ascan(aRegRot, {|x| x[2] == aRegiao[nCntFor]}) > 0
							If lAchou
								Exit
							EndIf
						Next nCntFor
						
						If lAchou .And. lVgeMod2
							GDFieldPut('DUD_STROTA','1',n)
						Else
							GDFieldPut('DUD_STROTA','3',n)
						EndIf							
						A210Trigger(lVgeMod2)
						dbSelectArea("DUH")
						dbSkip()
					EndDo
				EndIf
				DY4->(dbSkip())
			EndDo		
		EndIf
		If (!lLocaliza .Or. !lExistDUH) .And. !IsInCallStack("AF76VldAgd")
			If !lExistDUH
				GDFieldPut( 'DTA_LOCAL' , Criavar("DUH_LOCAL") , n )
				GDFieldPut( 'DTA_LOCALI', Criavar("DUH_LOCALI"), n )
				GDFieldPut( 'DTA_UNITIZ', Criavar("DUH_UNITIZ") , n )
				GDFieldPut( 'DTA_CODANA', Criavar("DUH_CODANA"), n )	
			EndIf				
			GDFieldPut( 'DTA_FILDOC', DT6->DT6_FILDOC , n )
			GDFieldPut( 'DTA_DOC'   , DT6->DT6_DOC    , n )
			GDFieldPut( 'DTA_SERIE' , DT6->DT6_SERIE  , n )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verificando os Produtos da Nota Fiscal para obter a Qtde. de Volumes  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)	
				DTC->(DbSetOrder(3))
				If DTC->(MsSeek(xFilial("DTC")+cSeekDTC))
					While DTC->(!Eof()) .And. DTC->DTC_FILIAL+DTC->DTC_FILDOC+DTC->DTC_DOC+DTC->DTC_SERIE == xFilial('DTC')+cSeekDTC
						nQtdVol += DTC->DTC_QTDVOL
						DTC->(DbSkip())
					EndDo
					If DT6->DT6_DOCTMS == 'K' //-- Carregamento em Partes
						nQtdVol := nQtdVol - (DT6->DT6_VOLORI - DT6->DT6_QTDVOL)

					EndIf
					GDFieldPut( 'DTA_QTDVOL', nQtdVol, n )
				EndIf
			Else
				DY4->(DbSetOrder(1))
				If DY4->(MsSeek(xFilial("DTC")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
					While DY4->(!Eof()) .And. DY4->DY4_FILIAL+DY4->DY4_FILDOC+DY4->DY4_DOC+DY4->DY4_SERIE == xFilial('DY4')+cSeekDTC
						nQtdVol += DY4->DY4_QTDVOL
						DY4->(DbSkip())
					EndDo
					If DT6->DT6_DOCTMS == 'K' //-- Carregamento em Partes
						nQtdVol := nQtdVol - (DT6->DT6_VOLORI - DT6->DT6_QTDVOL)
					EndIf
					GDFieldPut( 'DTA_QTDVOL', nQtdVol, n )
				EndIf	
			Endif	
			
			//- Atualiza os campos virtuais da grid relacionada ao carregamento/movimento da viagem. 				
			If !lVgeMod2
					GDFieldPut( 'DTA_PESO'	, DT6->DT6_PESO   , n )
					GDFieldPut( 'DTA_FILDCA', IIf( Len(aFilDca) == 1, aFilDca[1][3], Space(Len(DTA->DTA_FILDCA)) ), n )
					//-- Atualiza a Filial de Redespacho
					If DTA->(FieldPos('DTA_FILDPC')) > 0 .And. lAlianca
		   				If !TmsDocAli(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE) .Or. ;
		   					TmsPercAli(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE) == 2 //-- Segundo Percurso
							GDFieldPut( 'DTA_FILDPC', GDFieldGet( 'DTA_FILDCA', n ) , n )						
						EndIf
					EndIf
					If lCarregPar
						GDFieldPut( 'DTA_PESOM3', DT6->DT6_PESOM3, n )
						GDFieldPut( 'DTA_METRO3', DT6->DT6_METRO3, n )
						GDFieldPut( 'DTA_VALMER', DT6->DT6_VALMER, n )
						If lPesLiq
							GDFieldPut( 'DTA_PESLIQ', DT6->DT6_PESLIQ, n )
						EndIf
						If DT6->DT6_DOCTMS == 'J' //--Carregamento Total
							GDFieldPut( 'DTA_VALFRE', nValFre, n )
						ElseIf DT6->DT6_DOCTMS == 'K' //--Carregamento em Partes, o valor e o que ja foi carregado menos o total
							GDFieldPut( 'DTA_VALFRE', nValFre-nFreCar, n )
						EndIf
					EndIf
			Else
					GDFieldPut( 'DT6_PESO'	, DT6->DT6_PESO   , n )
					GDFieldPut( 'DT6_PESOM3', DT6->DT6_PESOM3 , n )
					GDFieldPut( 'DT6_VALMER', DT6->DT6_VALMER , n )
					GDFieldPut( 'DTA_QTDVOL', DT6->DT6_QTDVOL , n )
					GdFieldPut( 'DT6_VOLORI', DT6->DT6_VOLORI , n )	
					If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) .Or. cSerTms == StrZero(3,Len(DC5->DC5_SERTMS))
						GDFieldPut( 'DT5_DATENT', DT6->DT6_PRZENT , n )
					EndIf
					If cSerTms == StrZero(3,Len(DC5->DC5_SERTMS))
						GDFieldPut( 'DT6_NOMREM', Posicione("SA1",1,xFilial("SA1")+DT6->(DT6_CLIREM+DT6_LOJREM),"A1_NREDUZ"), n )
						GDFieldPut( 'DT6_NOMDES', Posicione("SA1",1,xFilial("SA1")+DT6->(DT6_CLIDES+DT6_LOJDES),"A1_NREDUZ"), n )
						If Empty(SA1->A1_CEPE)
							GDFieldPut( 'DUE_BAIRRO', SA1->A1_BAIRRO , n )
							GDFieldPut( 'DUE_MUN'   , SA1->A1_MUN    , n )
							GDFieldPut( 'DUE_EST'   , SA1->A1_EST    , n )
						Else									
		   					GDFieldPut( 'DUE_BAIRRO', SA1->A1_BAIRROE, n )
							GDFieldPut( 'DUE_MUN'   , SA1->A1_MUNE   , n )
							GDFieldPut( 'DUE_EST'   , SA1->A1_ESTE   , n )
						EndIf
					EndIf
					//--- Preenche campos para integracao GFE
					If lTMS3GFE .And. lVgeMod2 .And. M->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))  //Sim
						Tmsa210GFE(n, cSerTms, cFilOri, cViagem)
					EndIf
			EndIf	
			oGetD:oBrowse:nAt:= n
			oGetD:oBrowse:Refresh(.T.)
		EndIf
	Else
		If !IsInCallStack("TMSAF76")
			If IsInCallStack("AF76VldAgd")
				If !Empty(aAgendPend)
					Aadd(aAgendPend[Len(aAgendPend),22],{StrZero(Len(aAgendPend[Len(aAgendPend),22]) + 1,3),STR0088})
				EndIf
			Else
				Help(" ",1,"TMSA21019") //"Nota fiscal não encontrada !!!"
			EndIf
			lRet := .F.
		EndIf
	EndIf
	
	If nOpcx == 4 .And. M->DTQ_STATUS != StrZero(2,Len(M->DTQ_STATUS)) .and. M->DTQ_STATUS != StrZero(4,Len(M->DTQ_STATUS)) //--Alteracao e status da viagem diferente de em transito / Chegada em filial 
		DTX->(DbSetOrder(3))
		aVgaColg := TM210COLIG(cFilOri, cViagem,@lMdfeAut)
		For nCntFor := 1 To Len(aVgaColg)	
			If DTX->(MsSeek(xFilial('DTX') + aVgaColg[nCntFor][1] + aVgaColg[nCntFor][2]))		
				lAchouDTX := .T.
				Exit
			EndIf						
		NEXT nCntFor
		
		//-- Verifica se ha manifesto 
		//-- Verifica se a Região de origem e destino dos documetos da viagem alterada pertence a mesma UF de origem e destino.
		//-- Caso pertença, deverá mostrar um help informando.
		//-- Nesta verificação também está contemplando as viagens coligadas.	
		//-- ADD: Com Mdf-e Automático, não executará esta validação, pois obrigará no fechamento ou saída de viagem
		If	lAchouDTX .And. !lMdfeAut 
			//-- Verifica DUD DIPONIVEL PARA MANIFESTAR	
			cQuery := " SELECT COALESCE(COUNT(DUD.DUD_MANIFE), 0) QTD_DISPON "		
			cQuery += "   FROM " + RetSQLName("DUD") + " DUD "
			cQuery += "   INNER JOIN " + RetSQLName("DTX") + " DTX "
			cQuery += " 	ON DTX_VIAGEM = DUD.DUD_VIAGEM "	
			cQuery += "   INNER JOIN " + RetSQLName("DTR") + " DTR "
			cQuery += "   ON DTR.DTR_VIAGEM = DUD.DUD_VIAGEM "
			cQuery += "	WHERE DTX_FILIAL = '" + xFilial("DTX") +"'"	
			cQuery += "     AND DTX_FILMAN = '" + cFilAnt  + "' "	
			cQuery += "     AND DTX_FILORI = '" + cFilori  + "' "
			cQuery += "     AND (DTR.DTR_VIAGEM = '" + cViagem  + "' "
			For nCntFor := 1 To Len(aVgaColg)	//-- Verifica as viagens coligadas,a Principal + Coligada.		
				If aVgaColg[nCntFor][3] = .F. 
					cQuery += "   OR DTR.DTR_VIAGEM = '" + aVgaColg[nCntFor][2]  + "' " //--Coligada	
				Else
					cQuery += "   OR DTR.DTR_VIAGEM = '" + aVgaColg[nCntFor][2]  + "' " //--Principal
				EndIf					
			NEXT nCntFor
			cQuery += ")"
			cQuery += "     AND DTR.D_E_L_E_T_ =  ' ' "			
			cQuery += "     AND DTX_TIPMAN =  '2'  "
			cQuery += "     AND DTX_IDFMDF <> '132'"	
			cQuery += "     AND DUD.DUD_MANIFE <> ' ' "	
			cQuery += "     AND DTX.D_E_L_E_T_ =  ' ' "
			cQuery += "     AND DUD.D_E_L_E_T_ =  ' ' "
			cQuery += "     AND NOT EXISTS "
			cQuery += " (SELECT DUD_DOC   "
			cQuery += "   FROM " + RetSQLName("DUD") "
			cQuery += "	WHERE DUD_FILIAL = '" + xFilial("DUD") +"'"	
			cQuery += "     AND DUD_FILDOC = '" +  GDFieldGet('DTA_FILDOC',n)+ "' "	
			cQuery += "     AND DUD_DOC    = '" +  GDFieldGet('DTA_DOC',n)   + "' "
			cQuery += "     AND DUD_SERIE  = '" +  GDFieldGet('DTA_SERIE',n) + "' "
			cQuery += "     AND DUD_MANIFE = '' "
			cQuery += "     AND (DUD_CDRDES = DUD.DUD_CDRDES OR DUD_FILDCA = DUD.DUD_FILDCA)"		
			cQuery += "     AND D_E_L_E_T_ =  ' ' ) "				
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )		
				
			//-- Verifica DUD DIPONIVEL PARA MANIFESTAR		
			If (cAliasQry)->QTD_DISPON == 0
				Help('',1,'TMSA21064')  
				lRet := .F.	
			EndIf		
			(cAliasQry)->(DbCloseArea())	
		EndIf
	EndIf
ElseIf cCampo	$ "M->DTA_FILDCA"              
   
   cFilDoc 		:= GDFieldGet('DTA_FILDOC',n) 
   cDoc    		:= GDFieldGet('DTA_DOC'	 ,n) 
   cSerie  		:= GDFieldGet('DTA_SERIE' ,n)
   
	If Empty(cFilDoc) .Or. Empty(cDoc) .Or. Empty(cSerie)
		Help(" ",1,"TMSA21020") //"Informe a Filial do Docto./No.Docto/Serie Docto ..."
		Return(.F.)
	EndIf

	//-- Posiciona no documento
	DT6->(dbSetOrder(1))
	DT6->(MsSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
   
	If cSerTMS == StrZero(3, Len(DTQ->DTQ_SERTMS)) // Viagem de Entrega
		aFilDca := TMSRegDca(DTQ->DTQ_ROTA,,.T.)
	Else
		aFilDca := TMSRegDca(DTQ->DTQ_ROTA,DT6->DT6_CDRCAL,.F.)
	   If Empty(aFilDca) 
			aFilDca := TMSRegDca(DTQ->DTQ_ROTA,,.F.)
		EndIf	
	EndIf
	                                                           
	//-- Se a Filial destino do documento for uma das filiais de descarga, sera' obrigatorio
	//-- informar na Filial de Descarga a 'Filial de Destino' (DT6_FILDES) do documento;
	//-- Se a Filial de destino do documento NAO for nenhuma das filiais de descarga, podera' 
	//-- ser informado no campo 'Filial de Descarga', qualquer uma das filiais de descarga (aFildca)
	If ( Ascan(aFilDca, {|x| x[3] == DT6->DT6_FILDES } ) > 0 ) 
	   If  M->DTA_FILDCA <> DT6->DT6_FILDES
			Help(" ", 1, "TMSA21021",,+ DT6->DT6_FILDES,1,32)//"Informe a filial de Descarga : "
			Return( .F. )		
		EndIf
	Else
		If Ascan(aFilDca, {|x| x[3] == M->DTA_FILDCA } ) == 0
			Help(" ", 1, "TMSA21022") //"Filial de Descarga Invalida ... "
			Return( .F. )			
		EndIf
	EndIf
	
	//-- Atualiza a Filial de Redespacho
	If lAlianca
		If !TmsDocAli(GDFieldGet( 'DTA_FILDOC', n ),GDFieldGet( 'DTA_DOC', n ),GDFieldGet( 'DTA_SERIE', n )) .Or. ;
  				TmsPercAli(GDFieldGet( 'DTA_FILDOC', n ),GDFieldGet( 'DTA_DOC', n ),GDFieldGet( 'DTA_SERIE', n )) == 2 //-- Segundo Percurso   			
			GDFieldPut( 'DTA_FILDPC', M->DTA_FILDCA , n )
		EndIf
	EndIf
	
ElseIf cCampo	$ "M->DTA_FILDPC"

	If M->DTA_FILDPC $ GetMv("MV_FILDPC",.F.,"")
		If Posicione("DVL",1,xFilial("DVL")+M->DTA_FILDPC,"DVL_ALIANC") <> ;
			Posicione("DTC",3,xFilial("DTC")+GDFieldGet("DTA_FILDOC",n)+GDFieldGet("DTA_DOC",n)+GDFieldGet("DTA_SERIE",n),"DTC_ALIANC")
			Help(" ",1,"TMSA21017") // A Filial informada nao pertence ao Parceiro responsavel pelo documento.
			lRet := .F.
		EndIf
	Else
		Help(" ",1,"TMSA21018") // A Filial informada nao esta configurada no parametro MV_FILDPC.
		lRet := .F.		
	EndIf
	
ElseIf cCampo == "M->DTA_CODVEI"
	If Empty(M->DTA_FILORI)
		SX3->(dbSetOrder(2))
		SX3->(dbSeek("DTA_FILORI"))
		MsgAlert(STR0042+X3Titulo()) //"Informe o campo "
		lRet := .F.
	ElseIf Empty(M->DTA_VIAGEM)
		SX3->(dbSetOrder(2))
		SX3->(dbSeek("DTA_VIAGEM"))
		MsgAlert(STR0042+X3Titulo()) //"Informe o campo "
		lRet := .F.
	EndIf	
	If lRet
		lRet := ExistCpo("DA3",M->DTA_CODVEI,1)
		If lRet
			DTR->(dbSetOrder(3))
			If DTR->(!dbSeek(xFilial("DTR")+M->DTA_FILORI+M->DTA_VIAGEM+M->DTA_CODVEI))
				MsgAlert(STR0043) //"Veículo inválido ou não está sendo utilizado na viagem"
				lRet := .F.
			EndIf
			If lRet
				M->DTA_MODVEI := Posicione("DA3",1,xFilial("DA3")+M->DTA_CODVEI,"DA3_DESC")
				M->DTA_CODRB1 := DTR->DTR_CODRB1
				M->DTA_MODRB1 := Posicione("DA3",1,xFilial("DA3")+M->DTA_CODRB1,"DA3_DESC")
				M->DTA_CODRB2 := DTR->DTR_CODRB2
				M->DTA_MODRB2 := Posicione("DA3",1,xFilial("DA3")+M->DTA_CODRB2,"DA3_DESC")
				If lTercRbq
					M->DTA_CODRB3 := DTR->DTR_CODRB3
					M->DTA_MODRB3 := Posicione("DA3",1,xFilial("DA3")+M->DTA_CODRB3,"DA3_DESC")
				EndIf	
				If Empty(M->DTA_CODRB1) .And. Empty(M->DTA_CODRB2) .And. Iif(lTercRbq,Empty(M->DTA_CODRB3),.T.)
					M->DTA_VEICAR := '0'
				Else
					M->DTA_VEICAR := '1'
				EndIf				
			EndIf
		EndIf
	EndIf									
ElseIf AllTrim(cCampo) $ "M->DTA_QTDVOL.M->DTA_PESO.M->DTA_PESOM3.M->DTA_METRO3.M->DTA_VALMER"
	cSeek := GDFieldGet( "DTA_FILDOC", n )+GDFieldGet( "DTA_DOC", n )+GDFieldGet( "DTA_SERIE", n )
	If Empty(cSeek)
		lRet := .F.
	EndIf
	If lRet 
		lRet := Positivo()
	EndIf
	If lRet		
		DT6->(dbSetOrder(1))
		DT6->(dbSeek(xFilial('DT6')+cSeek))
		cCpoDT6 := "DT6->DT6_"+Right(cCampo,Iif(cCampo $ "M->DTA_PESO",4,6))
		cCpoSX3 := Right(cCampo,Iif(cCampo $ "M->DTA_PESO",8,10))
		If &cCampo > &cCpoDT6
			MsgAlert(Posicione('SX3',2,cCpoSX3,'AllTrim(X3Titulo())')+STR0044+AllTrim(X3Titulo())+STR0045) //' é superior a(ao) '###' do documento!'
			lRet := .F.
		ElseIf cCampo $ "M->DTA_QTDVOL" .And. DT6->DT6_QTDVOL == M->DTA_QTDVOL
			GDFieldPut( 'DTA_PESO'  , DT6->DT6_PESO  , n )
			GDFieldPut( 'DTA_PESOM3', DT6->DT6_PESOM3, n )
			GDFieldPut( 'DTA_METRO3', DT6->DT6_METRO3, n )
			GDFieldPut( 'DTA_VALMER', DT6->DT6_VALMER, n )
		EndIf
	EndIf

ElseIf cCampo	$ "M->DTA_VALFRE"	
	cSeek    := GDFieldGet('DTA_FILDOC',n) + GDFieldGet('DTA_DOC',n) + GDFieldGet('DTA_SERIE',n)
	cSeekCar := cSeek
	
	DT6->(dbSetOrder(1))
	If DT6->(dbSeek(xFilial('DT6')+cSeek))
		If Empty(DT6->DT6_DOCDCO) //--Se nao tiver documento original, alimenta com o valor do frete
			nValFre := DT6->DT6_VALFRE //--Valor Total do Frete
			nQtdTot := DT6->DT6_VOLORI //--Quantidade Total de Volumes
		Else
			cSeek := DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO //--Posiciona no documento original
			cSeekCar := DT6->DT6_FILDCO+DT6->DT6_DOCDCO //--Somente Filial e Documento para pesquisar o carregamento, devido ao carregamento parcial
			If DT6->(dbSeek(xFilial('DT6')+cSeek))
				nValFre := DT6->DT6_VALFRE //--o Valor do Frete tem que ser o do documento original
				nQtdTot := DT6->DT6_VOLORI //--Quantidade Total de Volumes
			EndIf
		EndIf
	EndIf
	
	DTA->(dbSetOrder(1))
	If DTA->(dbSeek(cSeekDTA := xFilial('DTA')+cSeek))  
		nFreCar += DTA->DTA_VALFRE //Soma os valores de frete ja carregados
		nQtdCar += DTA->DTA_QTDVOL //Soma os volumes ja carregados
	EndIf  
		
	//---- Soma os valores referente ao Carregamento Parcial - P01,P02,....///  
	cSeekDT6 := DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO 
	If !Empty(cSeekDT6)
		aAreaDTA := DTA->(GetArea()) 
		aAreaDT6 := DT6->(GetArea())
		DT6->(dbSetOrder(8))
		If DT6->(dbSeek(cSeekDT6 := xFilial('DT6')+cSeekDT6))
			While DT6->( !Eof() ) .And. DT6->DT6_FILIAL+DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO == cSeekDT6
				DTA->(dbSetOrder(1))
				If DTA->(dbSeek(cSeekDTA := xFilial('DTA')+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE ))
		  			nFreCar += DTA->DTA_VALFRE //Soma os valores de frete ja carregados
					nQtdCar += DTA->DTA_QTDVOL //Soma os volumes ja carregados
				EndIf	                                                               
				DT6->(DbSkip())
			EndDo
		EndIf 
		RestArea(aAreaDTA)  
		RestArea(aAreaDT6)  
	EndIf

	//--Valor do Frete Digitado + o valor ja carregado
	//--nao pode ultrapassar o frete do documento original
	If nValFre > 0
		If (M->DTA_VALFRE + nFreCar) > nValFre
			MsgAlert(STR0052 + CHR(13)+CHR(10)+; //--"O Valor do Frete informado no carregamento e maior que o do documento."
						STR0053 + AllTrim(Transform(nValFre,'@E 999,999,999.99')) + CHR(13)+CHR(10)+; //--"Frete Total: "
						STR0054 + AllTrim(Transform(nFreCar,'@E 999,999,999.99')) + CHR(13)+CHR(10)+; //--"Frete Carregado: "
						STR0055 + AllTrim(Transform(nValFre-nFreCar,'@E 999,999,999.99'))) //--"Frete Restante: "
			lRet := .F.
		ElseIf M->DTA_VALFRE == 0 //Validar na tok ou linok, pois o usuario pode nao digitar o campo
			MsgAlert(STR0056) //--"E necessario informar o valor do frete"
			lRet := .F.
		ElseIf GdFieldGet('DTA_QTDVOL') + nQtdCar == nQtdTot //--Ultimo documento, o valor precisa ser do restante do frete
			If M->DTA_VALFRE < (nValfre - nFreCar)
				MsgAlert(STR0057 + CHR(13)+CHR(10)+ ; //--"Este documento precisa receber o valor restante do frete"
							STR0055 + AllTrim(Transform(nValFre-nFreCar,'@E 999,999,999.99'))) //--"Frete Restante: "
				lRet := .F.
			EndIf
		EndIf
	EndIf
ElseIf cCampo == 'M->DTA_VEICAR'
	If M->DTA_VEICAR == '0' .And. !Empty(M->DTA_CODRB1)	
		Help("",1,"TMSA21504") //--Quando existir reboque, o carregamento nao pode ser feito no veiculo.
		lRet := .F.	                                    
	EndIf	
ElseIf cCampo == 'M->DTA_ORIGEM'
	If M->DTA_ORIGEM == "1" .And. DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) // 2-Viagem Em trânsito
		Help("",1,"TMSA21066") // Para viagens com status em trânsito, não é permitido o uso da opção 1-Rota/Transp 
		lRet := .F. 
	EndIf 
ElseIf cCampo == "M->DTA_ESTCAR" .AND. M->DTQ_STATUS == "2"
	// Verifica no estorno do carregamento, caso o documento fazer parte de um lote de rateio, todos os documentos do lote devem ser estornados juntos, e vice-versa.
	lRet := A210EstCar(M->DTA_ESTCAR)
EndIf

If !IsInCallStack("AF76VldAgd")
	oGetD:oBrowse:Refresh(.T.)
	//-- Atualizando dados do Rodape
	TmsA210Rdp()
EndIf
	
Return( lRet )
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMS210VLOT ³ Autor ³ Felipe Barbieri    ³ Data ³ 11/05/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se Lote possui e Viagem e se Doc. Pertence a Viagem³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMS210VLOT(cFil, cViagem, cLote)
Local lRet := .F.	
Local cQuery := ""
Local cAliasNew := ""

If !Empty(cViagem)
	cQuery := 	"SELECT DTP_LOTNFC, DTP_VIAGEM FROM "
	cQuery +=	RetSQLName("DTP") + " DTP WHERE DTP.DTP_VIAGEM = '" + cViagem + "'"
	cQuery += " AND DTP.DTP_TIPLOT <> '5' "
	cQuery += " AND DTP.DTP_FILORI = '" + cFil + "' AND DTP.DTP_FILIAL = '" + xFilial("DTP") + "' AND DTP.D_E_L_E_T_ = ' ' " 
	cAliasNew := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
	
	If Empty((cAliasNew)->DTP_LOTNFC)
		lRet := .T.
	Else
		(cAliasNew)->(DbGoTop())
		While (cAliasNew)->(!Eof())
			If cLote == (cAliasNew)->DTP_LOTNFC .And. !Empty((cAliasNew)->DTP_VIAGEM)  
				lRet := .T.
			EndIf 
			(cAliasNew)->(DbSkip())
		EndDo
	EndIf
	(cAliasNew)->(dbCloseArea())
EndIf
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA210Agd ³ Autor ³ Marcelo Coutinho   ³ Data ³ 13/01/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna valores do agendamento de entrega                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA210Agd(cCampo)

Local   xRet    := ""
Local   cCpoRet := ""
Default cCampo  := ""

DT6->(dbSetOrder(1))
DYD->(dbSetOrder(1))

If !Empty(cCampo)
	xRet    := Criavar(UPPER(cCampo),.F.,,.F.)
	If DT6->(dbSeek(xFilial('DT6')+DTA->(DTA_FILDOC+DTA_DOC+DTA_SERIE))) .And. ;
		DYD->(dbSeek(xFilial('DYD')+DT6->(DT6_NUMAGD+DT6_ITEAGD)))
		cCpoRet := "DYD->"+StrTran(cCampo,"DTA","DYD")
		xRet    := &(cCpoRet)
	EndIf
EndIf

Return xRet	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A210DoctOk³ Autor ³ Richard Anderson      ³ Data ³15.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o documento pode ser estornado                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A210DoctOk( ExpC1, ExpC2, ExpC3 )                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - Numero do Documento                                ³±±
±±³          ³ ExpC3 - Serie do Documento                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
Static Function A210DoctOk( cFilDoc, cDoc, cSerie )

Local lRet       := .T.
Local aAreas     := { DUD->(GetArea()), DT6->(GetArea()), DTA->(GetArea()), DTQ->(GetArea()), GetArea() }
Local lCarregPar := SuperGetMv('MV_TMSCPAR',,.F.)
Local aDocsDUA	 := {}
Local aDocs      := {}
Local nX         := 0
Local cDocs      := ""
Local cSerAdi    := "0"

PutHelp("PTMSA21058",{"Somente documentos com o status ","carregado podem ser estornados"},{},{},.F.)

//--So habilita carregamento parcial em transporte internacional
If lCarregPar .And. !(IsInCallStack(AllTrim('TMSA210I'))) .And. !(IsInCallStack(AllTrim('TMSA140D'))) .And. !(IsInCallStack(AllTrim('TMSA144I')));
	.And. !(IsInCallStack(AllTrim('TMSA144J'))) 
	lCarregPar := .F.
EndIf

DUD->(dbSetOrder(1))
If DUD->(dbSeek(xFilial("DUD")+cFilDoc+cDoc+cSerie+M->DTA_FILORI+M->DTA_VIAGEM)) .And. !Empty(DUD->DUD_MANIFE)
	Help("", 1, "TMSA21008",,cFilDoc+' '+cDoc+' '+cSerie,3,1) // "Documento ja manifestado, nao e permitido efetuar o estorno."
	lRet := .F.
EndIf

// Verifica se existe(m) manifesto(s) encerrado(s).
If lRet .AND. ExistFunc("TMSManEnc") .AND. TMSManEnc(M->DTA_FILORI, M->DTA_VIAGEM, @aDocs, cFilDoc, cDoc, cSerie)
    For nX := 1 To Len(aDocs)
        cDocs += aDocs[nX][1] + " " + aDocs[nX][2] + " " + aDocs[nX][3] +  chr(10) + chr(13)
    Next
    Help("", 1, "TMSA21008", , cDocs, 3, 1) // "Documento ja manifestado, nao e permitido efetuar o estorno."
    lRet := .F.
EndIf

//Verifica serviço adicional da viagem
If !Empty(M->DTA_FILORI+M->DTA_VIAGEM)
	DTQ->(DbSetORder(2))
	If DTQ->(DbSeek(xFilial("DTQ")+M->DTA_FILORI+M->DTA_VIAGEM)) .And. !Empty(DTQ->DTQ_SERADI)
		cSerAdi := DTQ->DTQ_SERADI
	EndIf
EndIf

DT6->(dbSetOrder(1))
DT6->(dbSeek(cSeekDT6 := xFilial('DT6')+cFilDoc+cDoc+cSerie))
If lRet .And. DUD->DUD_STATUS <> StrZero(3,Len(DUD->DUD_STATUS))  .And. DT6->DT6_SERTMS != StrZero(1,Len(DT6->DT6_SERTMS)) .And. cSerAdi != StrZero(1,Len(DT6->DT6_SERTMS))
	Help("", 1, "TMSA21058",,cFilDoc+' '+cDoc+' '+cSerie,3,1) // "Somente documentos com o status "carregado" podem ser estornados"
	lRet := .F.
EndIf
If lRet .And. DUD->DUD_STATUS == StrZero(4,Len(DUD->DUD_STATUS))  .And. DT6->DT6_SERTMS == StrZero(1,Len(DT6->DT6_SERTMS))  
	Help("", 1, "TMSA21065",,cFilDoc+' '+cDoc+' '+cSerie,3,1) // "Coleta com status 'Encerrada' não pode ter carregamento estornado."
	lRet := .F.
EndIf

If lRet .And. lCarregPar
	DTA->(dbSetOrder(1))
	DT6->(dbSetOrder(8))
	DT6->(dbSeek(cSeekDT6 := xFilial('DT6')+cFilDoc+cDoc+cSerie))
	While DT6->(!Eof()) .And. DT6->(DT6_FILIAL+DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO) == cSeekDT6
		If DT6->DT6_DOCTMS == 'K' .And. DTA->(dbSeek(xFilial('DTA')+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)+cFilAnt))
			MsgAlert(STR0046+Transform(cFilDoc+cDoc+cSerie,'@R XX XXXXXX/XXX')) //"Existem documentos de carregamento em partes carregados para o documento "
			lRet := .F.
			Exit
		EndIf
		DT6->(dbSkip())
	EndDo
EndIf	

//Verifica se existe uma ocorrência apontada para o documento.
If lRet .AND. ExistFunc("TMSDocOcor")
	aAdd(aDocsDUA, {cFilDoc, cDoc, cSerie})
	lRet := TMSDocOcor(aDocsDUA, M->DTA_FILORI, M->DTA_VIAGEM)
EndIf

AEval( aAreas, { |aArea| RestArea(aArea) } )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA210Leg³ Autor ³ Robson Alves          ³ Data ³15.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a legenda do status do Carregamento.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA210Leg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
Function TmsA210Leg()

BrwLegenda( cCadastro	  , STR0008 ,; 	//"Status"
{ { "BR_VERDE"  , STR0009},; 			//"Em Aberto"
{ "BR_VERMELHO" , STR0010} } )			//"Carregado"

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA210Grv³ Autor ³ Robson Alves          ³ Data ³15.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua as manutencoes no DTA(Operacoes de Transporte).     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA210Mnt(ExpA1, ExpN1, ExpL1)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array coms os campos da Enchoice.                  ³±±
±±³          ³ ExpN1 = Opcao do aRotina.                                  ³±±
±±³          ³ ExpL1 = Unitizador(Sim ou Nao).                            ³±±
±±³          ³ ExpL2 = Apresenta Help(Sim ou Nao).                        ³±±
±±³          ³ ExpC1 = Versao do carregamento grafico.                    ³±±
±±³          ³ ExpL3 = Executa TmsBlqViag				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA210Grv(aVisual, nOpc, lLocaliza, lHelp, cVersao, lBlqViag )

Local nA			:= 0
Local nB			:= 0
Local nC			:= 0
Local bCampo		:= { |nCpo| Field(nCpo) }
Local cAtivSai		:= GetMV("MV_ATIVSAI",,"")
Local cAtvSaiCli	:= SuperGetMv('MV_ATVSAIC',,'')//-- Atividade de Saída do cliente
Local cAtvChgCli	:= SuperGetMv('MV_ATVCHGC',,'')//-- Atividade de Chegada em Cliente
Local cAtvChgApo    := SuperGetMv('MV_ATVCHPA',,'')//-- Atividade de Chegada no Ponto de Apoio
Local cAtvSaiApo    := SuperGetMv('MV_ATVSAPA',,'')//-- Atividade de Saida do Ponto de Apoio

Local aServic		:= {}
Local cSeek			:= ""
Local cSeekDTC		:= ""
Local cLocal		:= ""
Local cLocali		:= ""
Local lGerOper		:= GetMV('MV_GEROPER',,.T.) //-- Verifica se devera gerar as operacoes
Local lRet			:= .T.
Local lRet2			:= .F.
//-- Controle de carregamento em partes
Local nI			:= 0
Local lCarregPar	:= SuperGetMv("MV_TMSCPAR",,.F.)
Local cDocTms		:= ''
Local cFilDoc		:= ''
Local cDoc			:= ''
Local cSerie		:= ''
Local cSerCar		:= ''
Local cStatus		:= ''
Local aAreaDUD		:= {}
Local aAreaDT6		:= {}
Local aAreaDTA		:= {}
Local cSeekDT6		:= ''
Local lStatusDUH	:= .T.
Local aEstCar		:= Array(6)
Local cSerEst		:= ""
Local aDoctosPar	:= {}
Local cAliasQry		:= ""
Local cQuery		:= ""
Local cZona			:= ""
Local cSetor		:= ""
Local nSeqDud		:= 0
Local nSalVol		:= 0
Local nValfre		:= 0
Local cSeekCar		:= ""
Local nFreCar		:= 0
Local cAliasNew		:= ""
Local cSequen		:= "0"
Local nQutDoc		:= 0
Local nEntreg		:= 0
Local aRegiao		:= {}
Local aRegRot		:= {}
Local lPertence	:= .F.
Local lRetPE		:= .T.
Local nCntFor		:= 0
Local cUnitiz		:= ""
Local cCodAna		:= ""
//-- Redespacho.
Local cSeekDFV		:= ""
//-- Posicoes aCols
Local nFilDoc		:= GdFieldPos('DTA_FILDOC')
Local nDoc			:= GdFieldPos('DTA_DOC'   )
Local nSerie		:= GdFieldPos('DTA_SERIE' )
Local nEstCar		:= GdFieldPos('DTA_ESTCAR')
Local nLocal		:= GdFieldPos('DTA_LOCAL' )
Local nLocali		:= GdFieldPos('DTA_LOCALI')
Local nUnitiz		:= GdFieldPos('DTA_UNITIZ')
Local nCodAna		:= GdFieldPos('DTA_CODANA')
Local nPosValFre	:= GdFieldPos('DTA_VALFRE')
Local cSeekDUD		:= ""
Local lAtuDF8		:= .F.
Local lTMS3GFE		:= Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)

Local lITmsDmd  	:= SuperGetMv("MV_ITMSDMD",,.F.)
Local lTMSDCol		:= SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.
Local cCliDes		:= ""
Local cLojDes		:= ""
Local cCliRem		:= ""
Local cLojRem		:= ""
Local cOrigem		:= ""
Local aCabDTW		:= {}
Local lAtvApoio     := .F.

//-- Variáveis utilizadas para instanciamento do carregamento da viagem modelo 3
Local aAreas     := {}
Local aDadosDM6  := {}
Local aCamposDM6 := {}
Local aDadosDTA  := {}
Local aCamposDTA := {}
Local aLinhaDTA  := {}
Local nCntFor1   := 0
Local nCntFor2   := 0
Local nCntFor3   := 0
Local nItErrDTA  := 0
Local lCont      := .T.
Local lExistDM6  := .T.
Local oModelCar  
Local oMdlFldDM6
Local oStruDM6
Local oMdlGrdDM7
Local oMdlGrdDTA
Local oStruDTA

Local lVgeAntiga := (Left(FunName(),7) == "TMSA140" .Or. Left(FunName(),7) == "TMSA141" .Or. ;
					 Left(FunName(),7) == "TMSA143" .Or. Left(FunName(),7) == "TMSA144") .Or. ;
					 Left(FunName(),7) == "TMSA210"

Local lCarreg3   := FindFunction("TMSAF90") .And. AliasInDic("DM6")
Local lAlianca	 := TmsAlianca() //-- Verifica se utiliza Alianca
Local cFilDTA    := ""
Local cDocDTA    := ""
Local cSerDTA    := ""

Local lAchou     := .T.
Local nLinha     := 0
Local oMdGridDTA
Local oModelVia, oMdGridDM3

//-- Utilizada pelo TMSA144, para viagens de Coleta e Entrega
Private lColeta		:= .F.

DEFAULT lLocaliza	:= .F.
DEFAULT lHelp		:= .T.
DEFAULT cVersao		:= ''
DEFAULT lBlqViag	:= .T. 

//--Verifica se a variavel "lVgeExpr"
//--esta declarada
If Type("lVgeExpr") <> 'L'
	PRIVATE	lVgeExpr := .F.
EndIf

//--So habilita carregamento parcial em transporte internacional
//--Carregamento, viagem modelo 1 ou 2 somente internacional
If	lCarregPar .And. !(IsInCallStack(AllTrim('TMSA210I'))) .And. !(IsInCallStack(AllTrim('TMSA140D'))) .And. !(IsInCallStack(AllTrim('TMSA144I')));
	.And. !(IsInCallStack(AllTrim('TMSA144J'))) 
	lCarregPar := .F.
EndIf

//--Verifica se a variavel "lVgeExpr" esta declarada
If Type("lVgeExpr") <> 'L'
	PRIVATE	lVgeExpr := .F.
EndIf

cServEnt := IIf(Type('cServEnt')=='C', cServEnt, Padr(GetMV("MV_SVCENT",,""),Len(DC5->DC5_SERVIC)))        
If nOpc == 4 // Estornar
	ProcRegua(RecCount())

	If lRet
		//-- Quando já existirem as rotinas de viagem modelo 3, utiliza o instanciamento do carregamento para atualizar as tabelas
		For nA := 1 To Len(aCols)
			If !(GdDeleted(nA)) // Verifica se a linha nao esta deletada.
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona o DTA(Carregamento) para efetuar o estorno.                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("DTA")
				dbSetOrder(1) //DTA_FILIAL+DTA_FILDOC+DTA_DOC+DTA_SERIE+DTA_FILORI+DTA_VIAGEM
				If aCols[nA][nEstCar] == "1"  .And. MsSeek(xFilial("DTA") + aCols[nA][nFilDoc] + aCols[nA][nDoc] + aCols[nA][nSerie] + M->DTA_FILORI + M->DTA_VIAGEM )
					If !lCarreg3

						//-- Carregamento por endereco
						If lLocaliza
							//-- Posiciona no documento
							cSeek  := aCols[nA][nFilDoc] + aCols[nA][nDoc] + aCols[nA][nSerie]
							cLocal := aCols[nA][nLocal ]
							cLocali:= aCols[nA][nLocali]
							cUnitiz:= aCols[nA][nUnitiz]
							cCodAna:= aCols[nA][nCodAna]						
							DT6->(dbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
							DT6->(MsSeek(xFilial("DT6")+cSeek))
							cSeekDTC := cSeek
							If DT6->DT6_DOCTMS == StrZero(6,Len(DT6->DT6_DOCTMS)) .And. !Empty(DT6->DT6_DOCDCO)
								cSeekDTC := DT6->(DT6_FILDCO + DT6_DOCDCO + DT6_SERDCO)
							EndIf
	
							DUH->(dbSetOrder(1)) //DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM
							
							If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
								DTC->(dbSetOrder(3)) //DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
								DTC->(MsSeek(xFilial("DTC")+cSeekDTC))
								While DTC->(!Eof()) .And. DTC->DTC_FILIAL+DTC->DTC_FILDOC+DTC->DTC_DOC+DTC->DTC_SERIE == xFilial('DTC')+cSeekDTC
		
									If DTC->DTC_SERIE == 'PED' .Or. Empty(DTC->DTC_DOC)
										DTC->(dbSkip())
										Loop
									EndIf
		
									DUH->(MsSeek(xFilial("DUH")+ cFilAnt +DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM))
									Do While !DUH->(Eof()) .And. xFilial("DUH")+DUH->DUH_FILORI+DUH->DUH_NUMNFC+DUH->DUH_SERNFC+DUH->DUH_CLIREM+DUH->DUH_LOJREM == ;
										DTC->DTC_FILIAL+ cFilAnt +DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM
										If DUH->DUH_STATUS <> StrZero(1, Len(DUH->DUH_STATUS))							
											If lLocaliza
												If DUH->DUH_LOCAL+DUH->DUH_LOCALI+DUH->DUH_UNITIZ+DUH->DUH_CODANA == cLocal+cLocali+cUnitiz+cCodAna
													RecLock("DUH",.F.)
													DUH->DUH_STATUS := StrZero(1, Len(DUH->DUH_STATUS))
													If DUH->(FieldPos('DUH_VERINC')) > 0
														DUH->DUH_VERINC := ''
													EndIf 																							
													MsUnLock()
												Else
													DUH->(dbSkip())
												EndIf
											Endif											
										Else
											RecLock("DUH",.F.)
											DUH->DUH_STATUS := StrZero(1, Len(DUH->DUH_STATUS))
											MsUnLock()
										EndIf
										DUH->(dbSkip())
									EndDo
									DTC->(dbSkip())
								EndDo
							Else						
								While DY4->(!Eof()) .And. DY4->DY4_FILIAL+DY4->DY4_FILDOC+DY4->DY4_DOC+DY4->DY4_SERIE == xFilial('DY4')+cSeekDTC
			
										If DY4->DY4_SERIE == 'PED' .Or. Empty(DY4->DY4_DOC)
											DY4->(dbSkip())
											Loop
										EndIf
			
										DUH->(MsSeek(xFilial("DUH")+ cFilAnt +DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM))
										Do While !DUH->(Eof()) .And. xFilial("DUH")+DUH->DUH_FILORI+DUH->DUH_NUMNFC+DUH->DUH_SERNFC+DUH->DUH_CLIREM+DUH->DUH_LOJREM == ;
											DY4->DY4_FILIAL+ cFilAnt +DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM
											If DUH->DUH_STATUS <> StrZero(1, Len(DUH->DUH_STATUS))							
												If lLocaliza
													If DUH->DUH_LOCAL+DUH->DUH_LOCALI+DUH->DUH_UNITIZ+DUH->DUH_CODANA == cLocal+cLocali+cUnitiz+cCodAna
														RecLock("DUH",.F.)
														DUH->DUH_STATUS := StrZero(1, Len(DUH->DUH_STATUS))
														MsUnLock()
													Else
														DUH->(dbSkip())
													EndIf
												Else
													RecLock("DUH",.F.)
													DUH->DUH_STATUS := StrZero(1, Len(DUH->DUH_STATUS))
													MsUnLock()
												EndIf
											EndIf
											DUH->(dbSkip())
										EndDo
										DY4->(dbSkip())
								EndDo							
							Endif	
						EndIf
	
						//-- Movimento de viagem
						DUD->(dbSetOrder(1)) //DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM
						If DUD->(MsSeek(xFilial("DUD")+DTA->DTA_FILDOC+DTA->DTA_DOC+DTA->DTA_SERIE+DTA->DTA_FILORI+DTA->DTA_VIAGEM))
							RecLock("DUD",.F.)
							If DUD->DUD_STATUS == '3' //-- Carregado
								DUD->DUD_STATUS := StrZero(1, Len(DUD->DUD_STATUS))
								DUD->DUD_FILDCA := Space(Len(DUD->DUD_FILDCA))
								//Para estorno da condição de documento transferido, que é utilizado no controle da chegada eventual.
								If (DUD->DUD_DOCTRF == "1")
									DUD->DUD_DOCTRF := "2"
								EndIf 
								//--Verificar se para o problema da Martins este tratamento no tipvia nao traz problemas em outros clientes
								If DUD_GERROM == StrZero(2, Len(DUD->DUD_GERROM)) .And. DTQ->DTQ_TIPVIA != "4" .And. !IsInCallStack("TMSAF76")
									DUD->DUD_FILORI := DUD->DUD_FILATU
									DUD->DUD_VIAGEM := Space(Len(DUD->DUD_VIAGEM))
									DUD->DUD_ZONA   := Space(Len(DUD->DUD_ZONA))
									DUD->DUD_SETOR  := Space(Len(DUD->DUD_SETOR))
									DUD->DUD_SEQUEN := Space(Len(DUD->DUD_SEQUEN))
									DUD->DUD_STROTA := Space(Len(DUD->DUD_STROTA))
									DUD->DUD_FILDPC := Space(Len(DUD->DUD_FILDPC))
								EndIf
								If DUD->DUD_FILDOC <> DUD->DUD_FILORI
									//-- Adiciona servicos dos doctos
									If Ascan( aServic, DUD->DUD_SERVIC ) == 0
										Aadd( aServic, DUD->DUD_SERVIC )
									EndIf
									DUD->DUD_SERVIC := CriaVar('DUD_SERVIC', .F.)
								EndIf
								
								//--- Dados Integração TMS x GFE 
								If lTMS3GFE 
									If Empty(DUD->DUD_NUMRED) .And. cSerTms == StrZero(2, Len(DUD->DUD_SERTMS) )
										DUD->DUD_UFDES  := Space(Len(DUD->DUD_UFDES))
										DUD->DUD_CDMUND := Space(Len(DUD->DUD_CDMUND))
										DUD->DUD_CEPDES := Space(Len(DUD->DUD_CEPDES))
									EndIf									
								EndIf
								
								//-- Adiciona servicos dos doctos
								If Ascan( aServic, DUD->DUD_SERVIC ) == 0
									Aadd( aServic, DUD->DUD_SERVIC )
								EndIf
								DT6->(dbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
								If DT6->(dbSeek(xFilial("DT6")+aCols[nA][nFilDoc] + aCols[nA][nDoc] + aCols[nA][nSerie]))
									RecLock("DT6",.F.)
									If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) // Viagem Transporte
										DT6->DT6_STATUS := StrZero(1, Len(DT6->DT6_STATUS)) // Em Aberto
										DT6->DT6_FILVGA := Space(Len(DT6->DT6_FILVGA))
										DT6->DT6_NUMVGA := Space(Len(DT6->DT6_NUMVGA))
									ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) // Viagem Entrega
										If DT6->DT6_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) // Doc de entrega
											If !Empty(DT6->DT6_FILDCO) .And. !Empty(DT6->DT6_DOCDCO) .And.!Empty(DT6->DT6_SERDCO)
												nEntreg := TM360RTST(DT6->DT6_FILDCO, DT6->DT6_DOCDCO, DT6->DT6_SERDCO)
											Else
												nEntreg := TM360RTST(DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE)
											EndIf
											DT6->DT6_STATUS := IIF(nEntreg == 3 .Or. nEntreg == 0, StrZero( 1, Len(DT6->DT6_STATUS)), StrZero( 8, Len(DT6->DT6_STATUS))) // Em Aberto ou Entrega parcial
										Else
											DT6->DT6_STATUS := StrZero(5, Len(DT6->DT6_STATUS)) // Chegada Final
										EndIf
										DT6->DT6_FILVGA := Space(Len(DT6->DT6_FILVGA))
										DT6->DT6_NUMVGA := Space(Len(DT6->DT6_NUMVGA))
									EndIf
									MsUnLock()
									//-- Tratamento para carregamento em partes
									If lCarregPar
										Afill(aEstCar,0)
										If Empty(DT6->DT6_DOCDCO)
											cFilDoc := DT6->DT6_FILDOC
											cDoc    := DT6->DT6_DOC
											cSerie  := DT6->DT6_SERIE
										Else
											cFilDoc := DT6->DT6_FILDCO
											cDoc    := DT6->DT6_DOCDCO
											cSerie  := DT6->DT6_SERDCO
										EndIf
										cSerEst  := DT6->DT6_SERIE
										cDocTMS  := DT6->DT6_DOCTMS
										aAreaDT6 := DT6->(GetArea())
										aAreaDUD := DUD->(GetArea())
										DT6->(dbSetOrder(8))  
										DT6->(dbSeek(cSeekDT6 := xFilial('DT6')+cFilDoc+cDoc+cSerie))
										While DT6->(!Eof()) .And. DT6->(DT6_FILIAL+DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO) == cSeekDT6
											If DT6->DT6_DOCTMS == 'K' //-- Docto. com carregamento em partes
												Aadd(aDoctosPar,{ DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE })
											EndIf
											DT6->(dbSkip())
										EndDo
										If Len(aDoctosPar) > 0
											aDoctosPar := Asort(aDoctosPar,,,{ | x, y | x[1]+x[2]+x[3] <= y[1]+y[2]+y[3] })
											For nI := 1 To Len(aDoctosPar)
												If cDocTMS != 'K' .Or. cSerEst < aDoctosPar[nI,3]
													DT6->(dbSetOrder(1))
													If DT6->(dbSeek(xFilial('DT6')+aDoctosPar[nI,1]+aDoctosPar[nI,2]+aDoctosPar[nI,3]))
														aEstCar[1] := DT6->DT6_QTDVOL
														aEstCar[2] := DT6->DT6_PESO
														aEstCar[3] := DT6->DT6_PESOM3
														aEstCar[4] := DT6->DT6_METRO3
														aEstCar[5] := DT6->DT6_VALMER
														aEstCar[6] := DT6->DT6_PESLIQ
														RecLock('DT6',.F.)
														dbDelete()
														MsUnLock()
														DUD->(dbSetOrder(1))
														If DUD->(dbSeek(xFilial("DUD")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE+cFilAnt))
															RecLock('DUD',.F.)
															dbDelete()
															MsUnLock()
														EndIf
													EndIf
													Exit
												EndIf
											Next nI
											RestArea(aAreaDT6)
											RestArea(aAreaDUD)
											If Ascan(aEstCar,{ | e | e > 0 }) > 0
												//-- Atualiza volumes dos documentos de carregamento em partes
												RecLock('DT6',.F.)
												DT6->DT6_QTDVOL := DT6->DT6_QTDVOL + aEstCar[1]
												DT6->DT6_PESO   := DT6->DT6_PESO   + aEstCar[2]
												DT6->DT6_PESOM3 := DT6->DT6_PESOM3 + aEstCar[3]
												DT6->DT6_METRO3 := DT6->DT6_METRO3 + aEstCar[4]
												DT6->DT6_VALMER := DT6->DT6_VALMER + aEstCar[5]
												DT6->DT6_PESLIQ := DT6->DT6_PESLIQ + aEstCar[6]
												MsUnLock()
											EndIf
										Else
											RestArea(aAreaDT6)
											RestArea(aAreaDUD)
										EndIf
									EndIf
								EndIf
							EndIf
							DUD->(MsUnLock())
	
							//-- Atualiza Gestão de Demandas
							If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
								If TMA144CVg(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,M->DTA_VIAGEM)
									//-- Quando o documento está na mesma viagem da coleta
									TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,.T.,,DTA->DTA_VIAGEM,.F.,.T.)
								Else                                                                                                     
									//-- Quando o documento não está na mesma viagem da coleta
									TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,.T.,,DTA->DTA_VIAGEM,.F.,.F.)
								Endif
							EndIf
	
						EndIf
	
						//-- ( 01 ) Verificando se existe algum documento relacionado com a operação que foi gerada de acordo com a sequência.
						DTW->(dbSetOrder(1)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_SEQUEN
						DTW->(MsSeek(cSeek := xFilial('DTW')+DTA->DTA_FILORI+M->DTA_VIAGEM+DTA->DTA_SEQDTW))
						cQuery := " SELECT COUNT(DTA_VIAGEM) DTA_VIAGEM  "
						cQuery += " From " + RetSqlTab('DTA')
						cQuery += " WHERE DTA_FILIAL = '"+xFilial("DTA")+"' "
						cQuery += " AND DTA_FILORI = '"+DTW->DTW_FILORI+"' "
						cQuery += " AND DTA_VIAGEM = '"+DTW->DTW_VIAGEM+"' "
						cQuery += " AND DTA_SEQDTW = '"+DTW->DTW_SEQUEN+"' "
						cQuery += " AND D_E_L_E_T_ = ' ' "
						cQuery := ChangeQuery(cQuery)
						cAliasNew := GetNextAlias()
						DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
						For nB := 1 To Len(aCols)//-- Verifica quantos documentos estão sendo estornados.
							If(aCols[nB][1] == "1")
								nQutDoc++
							EndIf
						Next nB
						If ( (cAliasNew)->DTA_VIAGEM == 1 .Or. (cAliasNew)->DTA_VIAGEM == nQutDoc)	//-- Se estiver estornando o último documento ou 
							lRet2 := .T.															//-- todos documentos da com mesma SEQDTW limpa 
						EndIf																		//-- as ocorrências geradas.
						(cAliasNew)->(DbCloseArea())
						//--Caso não exista mais carregamentos para aquela sequência a operação é apagada.
						If (lRet2)
							While ( DTW->DTW_SEQUEN <= DTA->DTA_SEQDTW .And. DTW->DTW_STATUS == "1" )
								//o Estorno da atividade de Chegada ou Saida de Cliente somente pelo Estorno do Fechamento e ou Estorno do Calculo do Frete
								If !DTW->DTW_ATIVID $ (cAtvSaiCli + ',' + cAtvChgCli)  
									RecLock("DTW", .F.)
									dbDelete()
									MsUnLock()
								EndIf	
								DTW->(DbSkip(-1))
							EndDo
						EndIf
						//-- Apaga Carregamento
						RecLock("DTA", .F.)
						dbDelete()
						MsUnLock() 
						//--Atualiza Status do Unitizador
						If lLocaliza
							DLGA010Sta(2 , cUnitiz, cCodAna, cLocal, cLocali,,,,,.T.)
						EndIf
					Else
						aAreas := {DM3->(GetArea()),DM6->(GetArea()),DTQ->(GetArea()),GetArea()}
					
						DTQ->(DbSetOrder(2))
						If DTQ->(DbSeek(xFilial("DTQ") + M->(DTA_FILORI + DTA_VIAGEM)))
							//-- Verifica se existe carregamento
							DM6->(DbSetOrder(1))
							If DM6->(DbSeek(xFilial("DM6") + M->(DTA_FILORI + DTA_VIAGEM)))
								//-- Carrega vetor da viagem
								Aadd(aDadosDM6,{"DM6_FILORI",DTQ->DTQ_FILORI})
								Aadd(aDadosDM6,{"DM6_VIAGEM",DTQ->DTQ_VIAGEM})
					
								//-- Carrega o Model de Carregamento
								oModelCar := FWLoadModel("TMSAF90")
								oModelCar:SetOperation(4)	//-- Alteração
							
								//-- Ativa o Model de Carregamento
								oModelCar:Activate()
		
								//-- Captura o modelo do grid da DTA
								oMdGridDTA := oModelCar:GetModel("MdGridDTA")
		
								//-- Localiza a linha com o documento que será descarregado e se encontrá-la exclui
								lAchou := oMdGridDTA:SeekLine( { {"DTA_FILDOC", aCols[nA,nFilDoc] },;
															   	 {"DTA_DOC"   , aCols[nA,nDoc   ] },;
															   	 {"DTA_SERIE" , aCols[nA,nSerie ] } } ) 

								If lAchou
									nLinha := oMdGridDTA:GetLine()
									oMdGridDTA:GoLine(nLinha)
									oMdGridDTA:DeleteLine()
								EndIf
				
								//-- Valida os Dados
								If ( lCont := oModelCar:VldData() )
									oModelCar:CommitData()
									//-- Verifica se existe alguma linha ativa no Grid do carregamento. Se não existir exclui todo o carregamento
									If oMdGridDTA:Length(.T.) == 0
										oModelCar:DeActivate()
										oModelCar:SetOperation(5)	//-- Exclusão
										oModelCar:Activate()
										If ( lCont := oModelCar:VldData() )
											oModelCar:CommitData()
										EndIf
									EndIf
								EndIf
					
								//-- Se Ocorreu Algum Erro Exibe Mensagem
								If !lCont
									//-- Monta mensagem de erro
									TF67MntErr(oModelCar)
									//-- Verifica se o Erro Ocorreu no Grid dos Documentos
									If nItErrDTA > 0
										AutoGrLog(STR0013 + " [" + AllTrim(AllToChar(nItErrDTA)) + "]")	//-- "Erro no Item do Documento:"
									EndIf
									MostraErro()
								EndIf
								
								//-- Desativa o Model do Carregamnto
								oModelCar:DeActivate()
								FreeObj(oModelCar)

								//Se exibiu erro sai do Loop após desativar o Modelo
								If !lCont
									Exit

								//-- Se MV_DOCVGE ativo e chamada na viagem antiga ou direto de carregamento
								ElseIf lVgeAntiga .AND. FwIsInCallStack("TMSAF76")
									//-- Carrega o Model da Viagem
									oModelVia := FWLoadModel("TMSAF60")
									oModelVia:SetOperation(4)	//-- Alteração
									oModelVia:Activate()

									//-- Captura o modelo do grid da DM3
									oMdGridDM3 := oModelVia:GetModel("MdGridDM3")
		
									//-- Localiza a linha com o documento que será descarregado e se encontrá-la exclui
									DM3->( DbSetOrder(1) )
									If DM3->( MSSeek(xFilial("DM3")+aCols[nA,nFilDoc]+aCols[nA,nDoc]+aCols[nA,nSerie] )  )
										If oMdGridDM3:SeekLine( { {"DM3_SEQUEN", DM3->DM3_SEQUEN },;
																  {"DM3_FILDOC", DM3->DM3_FILDOC },;
																  {"DM3_DOC"   , DM3->DM3_DOC    },;
																  {"DM3_SERIE" , DM3->DM3_SERIE  } } ) 
										
											nLinha := oMdGridDM3:GetLine()
											oMdGridDM3:GoLine(nLinha)
											oMdGridDM3:DeleteLine()
											If ( lCont := oModelVia:VldData() )
												oModelVia:CommitData()
											EndIf

											//-- Se Ocorreu Algum Erro Exibe Mensagem
											If !lCont
												//-- Monta mensagem de erro
												TF67MntErr(oModelCar)
												//-- Verifica se o Erro Ocorreu no Grid dos Documentos
												If nItErrDTA > 0
													AutoGrLog(STR0013 + " [" + AllTrim(AllToChar(nItErrDTA)) + "]")	//-- "Erro no Item do Documento:"
												EndIf
												MostraErro()
											EndIf

										EndIf
									EndIf

									//-- Desativa o Model da Viagem
									oModelVia:DeActivate()
									FreeObj(oModelVia)
									
									//Se exibiu erro sai do Loop após desativar o Modelo
									If !lCont
										Exit
									EndIf

								EndIf
							EndIf
						EndIf
				
						AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
					EndIf
				EndIf
			EndIf
		Next nA

		// Verifica bloqueio de documentos carregados não exibindo help
		If lBlqViag			
			TmsBlqViag( M->DTA_FILORI, M->DTA_VIAGEM,,,,, .F. )			
		EndIf	

	EndIf
Else
	
	For nA := 1 To Len(aCols)
		
        nValFre := 0

		If !(GdDeleted(nA))  // Verifica se a linha nao esta deletada.

            //-- Quando já existirem as rotinas de viagem modelo 3, utiliza o instanciamento do carregamento para atualizar as tabelas
            If lCarreg3 .And. GdFieldGet("DTA_SERIE",nA) != "COL"
                aLinhaDTA := {}
                Aadd(aLinhaDTA,{"DTA_FILDOC",GdFieldGet("DTA_FILDOC",nA)})
                Aadd(aLinhaDTA,{"DTA_DOC"   ,GdFieldGet("DTA_DOC",nA)})
                Aadd(aLinhaDTA,{"DTA_SERIE" ,GdFieldGet("DTA_SERIE",nA)})
                Aadd(aLinhaDTA,{"DTA_SERTMS",DTQ->DTQ_SERTMS})
                Aadd(aLinhaDTA,{"DTA_TIPTRA",DTQ->DTQ_TIPTRA})
                Aadd(aLinhaDTA,{"DTA_FILATU",cFilAnt})
                Aadd(aLinhaDTA,{"DTA_TIPCAR","2"})
                Aadd(aLinhaDTA,{"DTA_CODVEI",M->DTA_CODVEI})
                Aadd(aLinhaDTA,{"DTA_SEQDTW",StrZero(1,Len(DTA->DTA_SEQDTW))})
                Aadd(aLinhaDTA,{"DTA_VEICAR",M->DTA_VEICAR})
                Aadd(aLinhaDTA,{"DTA_ORIGEM",GdFieldGet("DTA_ORIGEM",nA)})
                If DTQ->DTQ_TIPTRA = '4' // Para viagem internacional
                    Aadd(aLinhaDTA,{"DTA_FILDCA",GdFieldGet("DTA_FILDCA",nA)})
                EndIf
                Aadd(aDadosDTA,Aclone(aLinhaDTA))
            EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o CT-e foi autorizado                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//-- Ponto de Entrada utilizado desabilitar a validacao se o CTE está autorizado
			If lTM210VCte
				lRetPE := ExecBlock('TM210VCTE',.F.,.F.)
				If ValType(lRet) # "L"
					lRetPE := .T.
				EndIf	
			Else
				lRetPE := .T.
			EndIf
			
			If lRetPE
				DT6->(dbSetOrder(1))
				If DT6->(MsSeek(xFilial("DT6")+aCols[nA][nFilDoc]+aCols[nA][nDoc]+aCols[nA][nSerie]))
					DTP->(dbSetOrder(2))
					If DTP->(MsSeek(xFilial("DTP") + DT6->DT6_FILORI + DT6->DT6_LOTNFC)) .And. (DTP->DTP_TIPLOT == StrZero(3,Len(DTP->DTP_TIPLOT)) .Or. (DTP->DTP_TIPLOT == StrZero(4,Len(DTP->DTP_TIPLOT))))
						lRet:= Alltrim(DT6->DT6_IDRCTE) == "100" .Or. !Empty(DT6->DT6_CHVCTG) .Or. Alltrim(DT6->DT6_IDRCTE) == "136" //Documento Autorizado; Contigencia FSDA; Contingencia EPEC
						// Documento Nao estando com alguma das Nao Conformidades Validadas acima		//
						// mas Eh um dos seguintes tipos, o processo sera Autorizado a dar continuidade //
						If !lRet .And. ( Alltrim(DT6->DT6_DOCTMS) == StrZero( 5, Len( DT6->DT6_DOCTMS ) ) .Or.;    //--Nota Fiscal de Serv. de Transp.
										Alltrim(DT6->DT6_DOCTMS) == Replicate('D', Len( DT6->DT6_DOCTMS ) ) .Or.; //--Nota Fiscal de Reentrega
										Alltrim(DT6->DT6_DOCTMS) == Replicate('F', Len( DT6->DT6_DOCTMS ) ) .Or.; //--Nota Fiscal de Armazenagem
										Alltrim(DT6->DT6_DOCTMS) == Replicate('G', Len( DT6->DT6_DOCTMS ) ) )     //--Nota Fiscal de Complemento
							lRet := .T.
						EndIf
						If !lRet
							Help('',1,'TMSA21025',, DT6->DT6_FILDOC +"-"+ DT6->DT6_DOC +"-"+ DT6->DT6_SERIE,2,18) //"CT-e não autorizado ou não enviado para Sefaz."
							If lVgeExpr
								SaveInter() //-- Salva o aCols atual para correta exibição no refresh de tela.
							EndIf
							Loop
						EndIf
					EndIf
				EndIf
			EndIf

			//-- Quando já existirem as rotinas de viagem modelo 3, utiliza o instanciamento do carregamento para atualizar as tabelas
			If !lCarreg3
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava o cabecalho das Operacoes de transporte.                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lLocaliza
					cLocal  := Left(GdFieldGet('DTA_LOCAL' ,nA)+Space(Len(DTA->DTA_LOCAL )),Len(DTA->DTA_LOCAL ))
					cLocali := Left(GdFieldGet('DTA_LOCALI',nA)+Space(Len(DTA->DTA_LOCALI)),Len(DTA->DTA_LOCALI))
					cUnitiz := Left(GdFieldGet('DTA_UNITIZ',nA)+Space(Len(DTA->DTA_UNITIZ)),Len(DTA->DTA_UNITIZ))
					cCodAna := Left(GdFieldGet('DTA_CODANA',nA)+Space(Len(DTA->DTA_CODANA)),Len(DTA->DTA_CODANA))				
	
					DTA->(DbSetOrder(3))
					If	DTA->(MsSeek(xFilial('DTA') + cLocal + cLocali +cUnitiz + cCodAna + GdFieldGet('DTA_FILDOC',nA) + GdFieldGet('DTA_DOC',nA) + GdFieldGet('DTA_SERIE',nA) + M->DTA_FILORI + M->DTA_VIAGEM ))
						RecLock('DTA',.F.)
					Else
						RecLock('DTA',.T.)
					EndIf				
				Else
					DTA->(DbSetOrder(1))
					If	DTA->(MsSeek(xFilial('DTA') + GdFieldGet('DTA_FILDOC',nA) + GdFieldGet('DTA_DOC',nA) + GdFieldGet('DTA_SERIE',nA) + M->DTA_FILORI + M->DTA_VIAGEM ))
						RecLock('DTA',.F.)
					Else
						RecLock('DTA',.T.)
					EndIf
				EndIf
	
				For nB := 1 To FCount()
					If FieldName(nB) == "DTA_FILIAL"
						FieldPut(nB, xFilial("DTA"))
					ElseIf FieldName(nB) == 'DTA_SERTMS'
						FieldPut(nB, cSerTms )
					ElseIf FieldName(nB) == 'DTA_TIPTRA'
						FieldPut(nB, cTipTra  )
					Else
						If Ascan(aVisual, AllTrim(FieldName(nB))) != 0
							FieldPut(nB, M->&(Eval(bCampo, nB)))
						EndIf
					EndIf
				Next nB
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava o itens das Operacoes de transporte.                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lAlianca
					If Len(aCols[nA]) >= 24 .AND. Empty(aCols[nA][24])
						aCols[nA][24] := Space(TamSX3('DTA_DATAGD')[1])
					EndIf
				EndIf
				For nC := 1 To Len(aHeader)
					If	aHeader[nC,10] != 'V'
						FieldPut(FieldPos(aHeader[nC][2]), IIf (aHeader[nC,8] == 'D' .And. ValType(aCols[nA][nC]) != 'D' .And. Empty(aCols[nA][nC]), CToD(aCols[nA][nC]), aCols[nA][nC]))
					EndIf
				Next nC
	
				DT6->(dbSetOrder(1))
				If DT6->(MsSeek(xFilial("DT6")+aCols[nA][nFilDoc]+aCols[nA][nDoc]+aCols[nA][nSerie]))
					nValFre := DT6->DT6_VALFRE
					RecLock("DT6",.F.)
					If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) // Viagem Transporte
						DT6->DT6_STATUS := StrZero(2, Len(DT6->DT6_STATUS)) // Carregado
						DT6->DT6_FILVGA := M->DTA_FILORI
						DT6->DT6_NUMVGA := M->DTA_VIAGEM
					ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) // Viagem Entrega
						DT6->DT6_STATUS := StrZero(6, Len(DT6->DT6_STATUS)) // Indicado para Entrega
						DT6->DT6_FILVGA := M->DTA_FILORI
						DT6->DT6_NUMVGA := M->DTA_VIAGEM
					EndIf
					DT6->(MsUnLock())
				EndIf
				
				//--Gravacao do Carregamento Parcial do Internacional
				If !Empty(DT6->DT6_DOCDCO)
					aAreaDT6 := DT6->(GetArea())
					DT6->(dbSeek(xFilial('DT6')+DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO))
					nValFre := DT6->DT6_VALFRE //--o Valor do Frete tem que ser o do documento original
					RestArea(aAreaDT6)
					cSeekCar := DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO
					//------- Posiciona no carregamento referente ao documento Original
					aAreaDTA := DTA->(GetArea())
					DTA->(dbSetOrder(1))
					If DTA->(dbSeek(cSeekDTA := xFilial('DTA')+cSeekCar))
						nFreCar += DTA->DTA_VALFRE //Soma os valores de frete ja carregados
					EndIf
					RestArea(aAreaDTA)
					//---- Soma os valores referente ao Carregamento Parcial - P01,P02,....///
					cSeekDT6 := DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO
					If !Empty(cSeekDT6)
						aAreaDTA := DTA->(GetArea())
						aAreaDT6 := DT6->(GetArea())
						DT6->(dbSetOrder(8))
						If DT6->(dbSeek(cSeekDT6 := xFilial('DT6')+cSeekDT6))
							While DT6->( !Eof() ) .And. DT6->DT6_FILIAL+DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO == cSeekDT6
								DTA->(dbSetOrder(1))
								If DTA->(dbSeek(cSeekDTA := xFilial('DTA')+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE ))
									nFreCar += DTA->DTA_VALFRE //Soma os valores de frete ja carregados
								EndIf
								DT6->(DbSkip())
							EndDo
						EndIf
						RestArea(aAreaDTA)
						RestArea(aAreaDT6)
					EndIf
					nValFre := nValFre - nFreCar
				EndIf
	
				//--Valor do Frete, utilizado no Transporte Internacional, so gravo se o usuario nao digitou
				If nPosValFre > 0 .And. aCols[nA][nPosValFre] == 0
					DTA->DTA_VALFRE := nValFre
				EndIf
				DTA->(MsUnLock())
				//-- Forca Commit para leitura da tabela DTA
				//-- Problema do TOPCONNECT
				DTA->(dbCommit())
	
				//-- Atualiza Gestão de Demandas
				If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
					If TMA144CVg(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,M->DTA_VIAGEM)
						//-- Quando o documento está na mesma viagem da coleta
						TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,.F.,,M->DTA_VIAGEM,.F.,.T.)
					Else
						//-- Quando o documento não está na mesma viagem da coleta
						TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,.F.,,M->DTA_VIAGEM,.F.,.F.)
					Endif
				EndIf
	
				cSeekDUD := xFilial("DUD")+aCols[nA][nFilDoc]+aCols[nA][nDoc]+aCols[nA][nSerie]+Iif(lTMSDCol,"",cFilAnt)
	
				//-- Monta o Seek do Redespacho.
				cSeekDFV := xFilial("DFV")+aCols[nA][nFilDoc]+aCols[nA][nDoc]+aCols[nA][nSerie]
	
				lStatusDUH := .T.
				DUD->(dbSetOrder(1)) //DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM
				If DUD->(!dbSeek(cSeekDUD))
					cSeekDUD := xFilial("DUD")+aCols[nA][nFilDoc]+aCols[nA][nDoc]+aCols[nA][nSerie]+Iif(lTMSDCol,"",M->DTA_FILORI)
					cSeekDFV := xFilial("DFV")+aCols[nA][nFilDoc]+aCols[nA][nDoc]+aCols[nA][nSerie]
					DUD->(dbSeek(cSeekDUD))
				EndIf
				
				//-- Doc. inserido atravez do carregamento, rotina para selecionar a sequencia dos doc.
				cAliasQry := GetNextAlias()
				cQuery	:= " SELECT MAX(DUD_SEQUEN) DUD_SEQUEN FROM "
				cQuery	+= RetSqlName("DUD")
				cQuery	+= " WHERE DUD_FILIAL ='" + xFilial("DUD") + "'"
				cQuery	+= "   AND DUD_FILORI ='" + M->DTA_FILORI + "' "
				cQuery	+= "   AND DUD_VIAGEM ='" + M->DTA_VIAGEM + "' "
				cQuery 	+= "   AND D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				If (cAliasQry)->(!EOF())
					nSeqDud	:=	Val ( (cAliasQry)->DUD_SEQUEN )
					nSeqDud++
				EndIf
				(cAliasQry)->(DbCloseArea())
	
				While DUD->(!Eof()) .And. DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+Iif(lTMSDCol,"",DUD_FILORI)) == cSeekDUD
	
					DFV->(DbSetOrder(2)) //DFV_FILIAL+DFV_FILDOC+DFV_DOC+DFV_SERIE+DFV_STATUS
					If DFV->(dBSeek(cSeekDFV)) .And. DUD->DUD_STATUS==StrZero(9,Len(DUD->DUD_STATUS))
						DUD->(dbSkip())
						Loop
					EndIf
	
					If DUD->DUD_SERTMS == cSerTms .And. DUD->DUD_TIPTRA == cTipTra .And.;
						If(Empty(DUD->DUD_VIAGEM),.T.,(DUD->DUD_FILORI+DUD->DUD_VIAGEM == M->DTA_FILORI+M->DTA_VIAGEM)) .And.;
						DUD->DUD_STATUS == StrZero(1,Len(DUD->DUD_STATUS)) .Or. DUD->DUD_STATUS == StrZero(3,Len(DUD->DUD_STATUS))
	
						RecLock("DUD", .F.)
						DUD->DUD_STATUS := StrZero(3,Len(DUD->DUD_STATUS)) //-- Carregado
						DUD->DUD_FILORI := M->DTA_FILORI
						DUD->DUD_VIAGEM := M->DTA_VIAGEM
						DUD->DUD_FILDCA := GDFieldGet('DTA_FILDCA',nA)
	
						//VERIFICA SE DOCUMENTO PERTENCE A ROTA.
						aRegiao := TMSNivSup(DUD->DUD_CDRCAL) // Obtem os niveis superiores da regiao de destino.
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Retorna as Regioes / Filiais de Destino da Rota                       ³
						//³ Elementos contidos por dimensao:                                      ³
						//³ 1. Regiao Origem da Rota                                              ³
						//³ 2. Regioes de Destino da Rota                                         ³
						//³ 3. Filiais de Destino da Rota                                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aRegRot := TMSRegDes(DTQ->DTQ_ROTA)   // Obtem as regioes da rota.
						For nCntFor := 1 To Len(aRegiao)
							/* Verifica se a regiao de destino do CTRC pertence a regiao da rota. */
							lPertence := Ascan(aRegRot, {|x| x[2] == aRegiao[nCntFor]}) > 0
							If lPertence
								Exit
							EndIf
						Next nCntFor
	
						If lPertence
							DUD->DUD_STROTA := StrZero(1,Len(DUD->DUD_STROTA)) //-- Da Rota
						Else
							DUD->DUD_STROTA := StrZero(3,Len(DUD->DUD_STROTA)) //-- De Outra Rota
						EndIf
						//----------------
						//Para carregamento
						cQuery := " Select COUNT(DTW_VIAGEM) DTW_VIAGEM "
						cQuery += " From " + RetSqlTab('DTW')
						cQuery += " Where DTW_FILIAL = '"+xFilial("DTW")+"' And "
						cQuery += " DTW_FILORI = '"+DUD->DUD_FILORI+"' And "
						cQuery += " DTW_VIAGEM = '"+DUD->DUD_VIAGEM+"' And "
						cQuery += " DTW_DATREA <> ' ' And " 
						cQuery += " DTW_HORREA <> ' ' And "
						cQuery += " DTW_ATIVID = '"+cAtivSai+"' And "
						cQuery += " D_E_L_E_T_ = '  ' And "
						cQuery += " DTW_FILATI = '"+DUD->DUD_FILORI+"' "
						cQuery := ChangeQuery(cQuery)
						cAliasNew := GetNextAlias()
						DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
						If (cAliasNew)->DTW_VIAGEM > 0
							DUD->DUD_DOCTRF := "1"
						EndIf
						(cAliasNew)->(DbCloseArea())
						//----------------
						cZona  := DUD->DUD_ZONA
						cSetor := DUD->DUD_SETOR
						If TmsA144DA7(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,DTQ->DTQ_ROTA,@cZona,@cSetor,.F.)
							DUD->DUD_ZONA  := cZona
							DUD->DUD_SETOR := cSetor
						EndIf
						DUD->DUD_SEQUEN	:= Iif(Empty(DUD->DUD_SEQUEN), StrZero(nSeqDud, Len(DUD->DUD_SEQUEN)), DUD->DUD_SEQUEN)					
						DUD->DUD_SEQENT := DUD->DUD_SEQUEN
						DUD->DUD_FILDPC := GDFieldGet('DTA_FILDPC',nA)
						If DUD->DUD_FILDOC <> DUD->DUD_FILORI
							DUD->DUD_SERVIC := cServEnt
						EndIf
						//--- Dados Integração TMS x GFE 
						If lTMS3GFE 
							If DTQ->DTQ_PAGGFE == StrZero(1, Len(DTQ->DTQ_PAGGFE) ) .And. Empty(DUD->DUD_NUMRED) .And. cSerTms == StrZero(2, Len(DUD->DUD_SERTMS) )
								Tmsa210DUD()
							EndIf
						EndIf
						MsUnLock()
						//-- Adiciona servicos a serem executados
						If Ascan( aServic, DUD->DUD_SERVIC ) == 0
							Aadd( aServic, DUD->DUD_SERVIC )
						EndIf
						//-- Verifica saldo de carregamento
						If lCarregPar .And. !lCarreg3
							nSalVol := DT6->DT6_QTDVOL - GdFieldGet('DTA_QTDVOL',nA)
							If nSalVol > 0
								//-- Gera Documento de Carregamento em Partes
								dbSelectArea("DT6")
								lStatusDUH := .F.
								aAreaDT6   := DT6->(GetArea())
								cFilDoc    := DT6->DT6_FILDOC
								cDoc       := DT6->DT6_DOC
								cSerie     := DT6->DT6_SERIE
								cDocTms    := DT6->DT6_DOCTMS
								cSerCar    := 'P01'
								If DT6->DT6_STATUS == '2' //-- Carregado
									cStatus := '1' //-- Em Aberto
								ElseIf DT6->DT6_STATUS == '6' //-- Indicado para entrega
									cStatus := '5' //-- Chegada em filial
								EndIf
								DT6->(dbSetOrder(1))
								While .T.
									If DT6->(!dbSeek(xFilial('DT6')+cFilDoc+cDoc+cSerCar))
										Exit
									EndIf
									cSerCar := Soma1(cSerCar)
								EndDo
								aCampos := {}
								RestArea(aAreaDT6)
	
								Aadd( aCampos, { 'DT6_FILDOC', cFilDoc } )
								Aadd( aCampos, { 'DT6_DOC'   , cDoc    } )
								Aadd( aCampos, { 'DT6_SERIE' , cSerCar } )
								Aadd( aCampos, { 'DT6_DATEMI', dDataBase } )
								Aadd( aCampos, { 'DT6_HOREMI', Left(StrTran(Time(),':',''),4) } )
								Aadd( aCampos, { 'DT6_DOCTMS', 'K'     } )
								Aadd( aCampos, { 'DT6_QTDVOL', nSalVol } )
								Aadd( aCampos, { 'DT6_PESO'  , (DT6->DT6_PESO   - GdFieldGet('DTA_PESO'  ,nA)) } )
								Aadd( aCampos, { 'DT6_PESOM3', (DT6->DT6_PESOM3 - GdFieldGet('DTA_PESOM3',nA)) } )
								Aadd( aCampos, { 'DT6_PESLIQ', (DT6->DT6_PESLIQ - GdFieldGet('DTA_PESLIQ',nA)) } )
								Aadd( aCampos, { 'DT6_METRO3', (DT6->DT6_METRO3 - GdFieldGet('DTA_METRO3',nA)) } )
								Aadd( aCampos, { 'DT6_VALMER', (DT6->DT6_VALMER - GdFieldGet('DTA_VALMER',nA)) } )
								Aadd( aCampos, { 'DT6_FILVGA', CriaVar('DT6_FILVGA',.F.) } )
								Aadd( aCampos, { 'DT6_NUMVGA', CriaVar('DT6_NUMVGA',.F.) } )
								If cDocTms != 'K' //-- Carregamento em Partes
									Aadd( aCampos, { 'DT6_FILDCO', cFilDoc } )
									Aadd( aCampos, { 'DT6_DOCDCO', cDoc    } )
									Aadd( aCampos, { 'DT6_SERDCO', cSerie  } )
								EndIf
								Aadd( aCampos, { 'DT6_VALFRE', 0       } )
								Aadd( aCampos, { 'DT6_VALIMP', 0       } )
								Aadd( aCampos, { 'DT6_VALTOT', 0       } )
								Aadd( aCampos, { 'DT6_VALFAT', 0       } )
								Aadd( aCampos, { 'DT6_STATUS', cStatus } )
	
								TmsCopyReg( aCampos )
								RestArea(aAreaDT6)
								//-- Atualiza valores carregados
								RecLock('DT6',.F.)
								DT6->DT6_QTDVOL := GdFieldGet('DTA_QTDVOL',nA)
								DT6->DT6_PESO   := GdFieldGet('DTA_PESO'  ,nA)
								DT6->DT6_PESOM3 := GdFieldGet('DTA_PESOM3',nA)
								DT6->DT6_PESLIQ := GdFieldGet('DTA_PESLIQ',nA)
								DT6->DT6_METRO3 := GdFieldGet('DTA_METRO3',nA)
								DT6->DT6_VALMER := GdFieldGet('DTA_VALMER',nA)
								MsUnLock()
	
								//-- Movimento de viagem
								dbSelectArea("DUD")
								aAreaDUD := DUD->(GetArea())
								aCampos  := {}
	
								Aadd( aCampos, { 'DUD_VIAGEM', CriaVar('DUD_VIAGEM',.F.) } )
								Aadd( aCampos, { 'DUD_SERIE' , cSerCar } )
								Aadd( aCampos, { 'DUD_STATUS', '1'     } )
	
								// Limpa campos de não previsto
								If DUD->(ColumnPos("DUD_DTRNPR")) > 0
									AAdd( aCampos, { 'DUD_DTRNPR',  CriaVar("DUD_DTRNPR", .F.) } )
									AAdd( aCampos, { 'DUD_HRRNPR',  CriaVar("DUD_HRRNPR", .F.) } )	
									AAdd( aCampos, { 'DUD_USURNP',  CriaVar("DUD_USURNP", .F.) } )
									AAdd( aCampos, { 'DUD_NOMUSU',  CriaVar("DUD_NOMUSU", .F.) } )	
								EndIf
								TmsCopyReg( aCampos )
	
								RestArea(aAreaDUD)
							EndIf
						EndIf
						Exit
					EndIf
					DUD->(dbSkip())
				EndDo
	
				If lStatusDUH
					DT6->(dbSetOrder(1))
					DT6->(MsSeek(xFilial("DT6")+DTA->DTA_FILDOC+ DTA->DTA_DOC + DTA->DTA_SERIE))
					cSeekDTC := DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)
					If DT6->DT6_DOCTMS == StrZero(6,Len(DT6->DT6_DOCTMS)) .And. !Empty(DT6->DT6_DOCDCO)
						cSeekDTC := DT6->(DT6_FILDCO + DT6_DOCDCO + DT6_SERDCO)
					EndIf
					DUH->(dbSetOrder(1)) //DUH_FILIAL+DUH_FILORI+DUH_NUMNFC+DUH_SERNFC+DUH_CLIREM+DUH_LOJREM+DUH_CODPRO+DUH_LOCAL+DUH_LOCALI
					If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE) 
						DTC->(dbSetOrder(3)) //DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
						DTC->(dbSeek(xFilial("DTC")+ cSeekDTC))
						Do While !DTC->(Eof()) .And. DTC->DTC_FILIAL+DTC->DTC_FILDOC+DTC->DTC_DOC+DTC->DTC_SERIE == xFilial("DTC")+ cSeekDTC
							If DTC->DTC_SERIE == 'PED' .Or. Empty(DTC->DTC_DOC)
								DTC->(dbSkip())
								Loop
							EndIf
							DUH->(dbSeek(xFilial("DUH")+ cFilAnt +DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM))
							Do While !DUH->(Eof()) .And. xFilial("DUH")+DUH->DUH_FILORI+DUH->DUH_NUMNFC+DUH->DUH_SERNFC+DUH->DUH_CLIREM+DUH->DUH_LOJREM ==;
								DTC->DTC_FILIAL+ cFilAnt +DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM
								If DUH->DUH_STATUS <> StrZero(2, Len(DUH->DUH_STATUS))
									If lLocaliza
										If DUH->DUH_LOCAL+DUH->DUH_LOCALI+DUH->DUH_UNITIZ+DUH->DUH_CODANA == cLocal+cLocali+cUnitiz+cCodAna
											RecLock("DUH",.F.)
											DUH->DUH_STATUS := StrZero(2, Len(DUH->DUH_STATUS))
											If DUH->(FieldPos('DUH_VERINC')) > 0
												DUH->DUH_VERINC := cVersao
											EndIf 
											MsUnLock()
											//--Atualiza o Status do Unitizador
											DLGA010Sta(2 , DUH->DUH_UNITIZ, DUH->DUH_CODANA,,, GdFieldGet('DTA_FILDCA',nA) , M->DTA_FILORI , M->DTA_VIAGEM)
										EndIf	
									EndIf
								Else
									RecLock("DUH",.F.)
									DUH->DUH_STATUS := StrZero(2, Len(DUH->DUH_STATUS))
									MsUnLock()
								EndIf
								DUH->(dbSkip())
							EndDo
							DTC->(dbSkip())
						EndDo
					Else
						DbSelectArea("DY4")
						DY4->(DbSetOrder(1)) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
						If DY4->( dbSeek( FwxFilial("DY4")+ cSeekDTC ) )				
							Do While !DY4->(Eof()) .And. DY4->DY4_FILIAL+DY4->DY4_FILDOC+DY4->DY4_DOC+DY4->DY4_SERIE == xFilial("DY4")+ cSeekDTC
								If DY4->DY4_SERIE == 'PED' .Or. Empty(DY4->DY4_DOC)
									DY4->(dbSkip())
									Loop
								EndIf
								DUH->(dbSeek(xFilial("DUH")+ cFilAnt +DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM))
								Do While !DUH->(Eof()) .And. xFilial("DUH")+DUH->DUH_FILORI+DUH->DUH_NUMNFC+DUH->DUH_SERNFC+DUH->DUH_CLIREM+DUH->DUH_LOJREM ==;
									DY4->DY4_FILIAL+ cFilAnt +DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM
									If DUH->DUH_STATUS <> StrZero(2, Len(DUH->DUH_STATUS))
										If lLocaliza
											If DUH->DUH_LOCAL+DUH->DUH_LOCALI+DUH->DUH_UNITIZ+DUH->DUH_CODANA == cLocal+cLocali+cUnitiz+cCodAna
												RecLock("DUH",.F.)
												DUH->DUH_STATUS := StrZero(2, Len(DUH->DUH_STATUS))
												MsUnLock()
												//--Atualiza o Status do Unitizador
												DLGA010Sta(2 , DUH->DUH_UNITIZ, DUH->DUH_CODANA,,, GdFieldGet('DTA_FILDCA',nA) , M->DTA_FILORI , M->DTA_VIAGEM)
											Else
												DUH->(dbSkip())
											EndIf
										Else
											RecLock("DUH",.F.)
											DUH->DUH_STATUS := StrZero(2, Len(DUH->DUH_STATUS))
											MsUnLock()
										EndIf
									EndIf
									DUH->(dbSkip())
								EndDo
								DY4->(dbSkip())
							EndDo					
						Endif	
					Endif	
				EndIf
			EndIf
		EndIf
		
		If lGerOper
			//-- Gera operacoes de transporte
			//-- Obtendo sequencia para operaçôes de "carregamento"
			DTW->(dbSetOrder(1))
			DTW->(MsSeek(cSeek := xFilial('DTW')+M->DTA_FILORI+M->DTA_VIAGEM))
			If(!Empty(DTW->DTW_SEQUEN))	
				While DTW->( DTW_VIAGEM == M->DTA_VIAGEM )
					If DTW->(DTW_STATUS == "1")
						DTW->(DbSkip(-1))
						cSequen := DTW->DTW_SEQUEN
						DTW->(DbSkip())
						Exit
					EndIf
					DTW->(DbSkip())
				EndDo
				DTW->(DbSkip())
			EndIf
			
			DA8->(dbSetOrder(1))
			If DA8->( MsSeek( xFilial( 'DA8' ) + DTQ->DTQ_ROTA,.F. ) )
				DC5->(dbSetOrder(1))
                If DC5->( MsSeek( cSeek := xFilial('DC5') + DA8->DA8_SERVIC, .F.) )
                    While DC5->( !Eof() .And. (DC5_FILIAL + DC5_SERVIC == cSeek) )
                        DC6->( MsSeek( xFilial("DC6") + DC5->DC5_TAREFA, .F.) )
                        While DC6->( !Eof() .And. DC6->DC6_TAREFA == DC5->DC5_TAREFA )
                            If DC6->DC6_ATIVID == cAtvChgApo .OR. DC6->DC6_ATIVID == cAtvSaiApo
                                lAtvApoio := .T.
                                Exit
                            EndIf
                            DC6->(dbSkip())
                        EndDo
                        If lAtvApoio
                            Exit
                        EndIf
                        DC5->(dbSkip())
                    EndDo
                EndIf
            EndIf
            
			//-- Quando é carregamento3, não gravou DTA
			cFilDTA:= If (!lCarreg3,DTA->DTA_FILDOC, GdFieldGet('DTA_FILDOC',nA) )
			cDocDTA:= If (!lCarreg3,DTA->DTA_DOC   , GdFieldGet('DTA_DOC'   ,nA) )
			cSerDTA:= If (!lCarreg3,DTA->DTA_SERIE , GdFieldGet('DTA_SERIE' ,nA) )
			If lCarreg3
				TF64AltVia()
			EndIf
						
			DT6->(dbSetOrder(1))
            If DT6->(MsSeek(xFilial("DT6")+ cFilDTA + cDocDTA + cSerDTA ))

                cCliDes	:= DT6->DT6_CLIDES	
                cLojDes	:= DT6->DT6_LOJDES
                If DTQ->DTQ_STATUS == "2" .AND. !Empty(DT6->DT6_CLIEXP) .AND. !Empty(DT6->DT6_LOJEXP)
                    cCliRem	:= DT6->DT6_CLIEXP
                    cLojRem	:= DT6->DT6_LOJEXP
                Else
                    cCliRem	:= DT6->DT6_CLIREM
                    cLojRem	:= DT6->DT6_LOJREM
                EndIf
                //-- Verifica sequência de endereço
                If DT6->(ColumnPos("DT6_SQEDES")) > 0
                    If !Empty(DT6->DT6_SQEDES)
                        DUL->(dbSetOrder(2))
                        If DUL->(MsSeek( xFilial("DUL") + cCliDes + cLojDes + DT6->DT6_SQEDES )) .And. !Empty(DUL->DUL_CODRED)
                            cCliDes		:= DUL->DUL_CODRED
                            cLojDes		:= DUL->DUL_LOJRED
                        EndIf	
                    EndIf
                EndIf

            EndIf

            If lAtvApoio
                cAliasNew := GetNextAlias()
                cQuery := 	"SELECT DTW.DTW_IDDTW "
                cQuery += 	"FROM " + RetSqlName("DTW") + " DTW "
                cQuery += 	"WHERE DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
                cQuery += 	"AND DTW.DTW_FILORI = '" + DTQ->DTQ_FILORI + "' "
                cQuery += 	"AND DTW.DTW_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
                cQuery += 	"AND DTW.DTW_ATIVID = '" + cAtvChgApo + "' "
                cQuery += 	"AND DTW.DTW_STATUS = '2' "
                cQuery += 	"AND DTW.D_E_L_E_T_ = ' ' "
                cQuery +=   "ORDER BY DTW.DTW_IDDTW DESC"
                cQuery := ChangeQuery(cQuery)
                DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)

                If (cAliasNew)->(!Eof()) .AND. ExistFunc("Tmsa351DLT")
                    Aadd( aCabDTW, { 'DTW_FILORI'	, DTQ->DTQ_FILORI	, Nil } )
                    Aadd( aCabDTW, { 'DTW_VIAGEM'	, DTQ->DTQ_VIAGEM	, Nil } ) 
                    Aadd( aCabDTW, { 'DTW_IDDTW'	, (cAliasNew)->DTW_IDDTW	, Nil } ) 
                    cOrigem	:= "2" // Viagem em Trânsito
                    cOpeDoc	:= "2" // Emissão
                    Tmsa351DLT(aCabDTW, 4, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, (cAliasNew)->DTW_IDDTW, cFilDTA, cDocDTA, cSerDTA, cOrigem, cOpeDoc)
                EndIf
                (cAliasNew)->(dbCloseArea())
			Else 
				//-- Verifica a existência de Operação de chegada em cliente apontada e cria DLT para o Remetente 
				If DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) // Viagem em Trânsito 
					cAliasNew := GetNextAlias()
					cQuery := 	"SELECT DTW.DTW_IDDTW "
					cQuery += 	"FROM " + RetSqlName("DTW") + " DTW "
					cQuery += 	"WHERE DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
					cQuery += 	"AND DTW.DTW_FILORI = '" + DTQ->DTQ_FILORI + "' "
					cQuery += 	"AND DTW.DTW_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
					cQuery += 	"AND DTW.DTW_ATIVID = '" + cAtvChgCli + "' "
					cQuery += 	"AND DTW.DTW_CODCLI = '" + cCliRem + "' "
					cQuery += 	"AND DTW.DTW_LOJCLI = '" + cLojRem + "' "
					cQuery += 	"AND DTW.DTW_STATUS = '2' "
					cQuery += 	"AND DTW.D_E_L_E_T_ = ' ' "
					cQuery +=   "ORDER BY DTW.DTW_IDDTW DESC"
					cQuery := ChangeQuery(cQuery)
					DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)

					If (cAliasNew)->(!Eof()) .AND. ExistFunc("Tmsa351DLT")
						Aadd( aCabDTW, { 'DTW_FILORI'	, DTQ->DTQ_FILORI	, Nil } )
						Aadd( aCabDTW, { 'DTW_VIAGEM'	, DTQ->DTQ_VIAGEM	, Nil } ) 
						Aadd( aCabDTW, { 'DTW_IDDTW'	, (cAliasNew)->DTW_IDDTW	, Nil } ) 
						cOrigem	:= "2" // Viagem em Trânsito
						If cSerDTA == 'COL'
							cOpeDoc	:= "3" // Coleta
						Else 
							cOpeDoc	:= "2" // Emissão
						EndIf 
						Tmsa351DLT(aCabDTW, 4, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, (cAliasNew)->DTW_IDDTW, cFilDTA, cDocDTA, cSerDTA, cOrigem, cOpeDoc)
					EndIf
					(cAliasNew)->(dbCloseArea())
				EndIf 

                If !Empty(cCliRem) .And. !Empty(cLojRem)
                    A210GerDTW( cFilDTA, cDocDTA, cSerDTA, DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM  , cCliRem , cLojRem , .T. )
                EndIf

                If !((Empty(cCliDes) .OR. Empty(cLojDes)) .AND. cSerDTA == "COL" .AND. !Empty(cSequen) .AND. Len(cSequen) > 1) .AND. Empty(DT6->DT6_CLIEXP) .AND. Empty(DT6->DT6_LOJEXP)
                    A210GerDTW( cFilDTA, cDocDTA, cSerDTA , DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM  , cCliDes , cLojDes , .F.  )
                EndIf
            EndIf
		EndIf
	Next nA

	//-- Quando já existirem as rotinas de viagem modelo 3, utiliza o instanciamento do carregamento para atualizar as tabelas
	If lCarreg3
	
		//Se o parâmetro MV_DOCVGE ativo e em tela de viagem antiga ou direto na tela de carregamento gera tabelas do planejamento de viagens antes
		If lDocVge .And. lVgeAntiga
			lCont := PlanViagem( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, @aDadosDTA )
		EndIf

       	If lCont .And. !Empty(aDadosDTA)
			aAreas := {DTR->(GetArea()),DM6->(GetArea()),GetArea()}
	
			//-- Verifica se existe carregamento
			DM6->(DbSetOrder(1))
			lExistDM6 := (DM6->(DbSeek(xFilial("DM6") + M->(DTA_FILORI + DTA_VIAGEM))))

			//-- Carrega vetor da viagem
			Aadd(aDadosDM6,{"DM6_FILORI",DTQ->DTQ_FILORI})
			Aadd(aDadosDM6,{"DM6_VIAGEM",DTQ->DTQ_VIAGEM})

			//-- Carrega o Model de Carregamento
			oModelCar := FWLoadModel("TMSAF90")
			oModelCar:SetOperation(Iif(lExistDM6,4,3))	//-- Alteração ou inclusão
		
			//-- Ativa o Model de Carregamento
			oModelCar:Activate()

			//-- Carrega o Modelo da Viagem
			oMdlFldDM6 := oModelCar:GetModel("MdFieldDM6")
			oStruDM6   := oMdlFldDM6:GetStruct()
			aCamposDM6 := oStruDM6:GetFields()

			//-- Carrega o Modelo dos Veículos
			oMdlGrdDM7 := oModelCar:GetModel("MdGridDM7")

			//-- Carrega o Model dos Documentos
			oMdlGrdDTA := oModelCar:GetModel("MdGridDTA")
			oStruDTA   := oMdlGrdDTA:GetStruct()
			aCamposDTA := oStruDTA:GetFields()

			//-- Preenche os Valores no Cabeçalho do Carregamento
			If !lExistDM6
				For nCntFor1 := 1 To Len(aDadosDM6)
					If AScan(aCamposDM6,{|x| AllTrim(x[3]) == AllTrim(aDadosDM6[nCntFor1,1])}) > 0
						If !oMdlFldDM6:SetValue(aDadosDM6[nCntFor1,1],aDadosDM6[nCntFor1,2])
							lCont := .F.
							Exit
						EndIf
					EndIf
				Next nCntFor1
			EndIf
			
			//-- Carrega os Documentos do Carregamento
			If lCont
				If Empty(aDadosDTA[1,AScan(aDadosDTA[1],{|x| AllTrim(x[1]) == "DTA_CODVEI"}),2])
					DTR->(DbSetOrder(1))
					If DTR->(DbSeek(xFilial("DTR") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
						aDadosDTA[1,AScan(aDadosDTA[1],{|x| AllTrim(x[1]) == "DTA_CODVEI"}),2] := DTR->DTR_CODVEI
					EndIf
				EndIf
				If oMdlGrdDM7:SeekLine({{"DM7_CODVEI",aDadosDTA[1,AScan(aDadosDTA[1],{|x| AllTrim(x[1]) == "DTA_CODVEI"}),2]}},,.T.)
					//-- Monta Grid de Documentos
					For nCntFor2 := 1 To Len(aDadosDTA)

						If !lExistDM6
							If nCntFor2 > 1
								If (nItErrDTA := oMdlGrdDTA:AddLine()) != nCntFor2
									lCont := .F.
									Exit
								EndIf
							EndIf
						Else
							If !oMdlGrdDTA:IsEmpty()
								oMdlGrdDTA:AddLine()
							EndIf
						EndIf
				
						//-- Preenche os Valores nos Documentos do Carregamento
						If lCont
							For nCntFor3 := 1 To Len(aDadosDTA[nCntFor2])
								If AScan(aCamposDTA,{|x| AllTrim(x[3]) == AllTrim(aDadosDTA[nCntFor2,nCntFor3,1])}) > 0
									If !oMdlGrdDTA:SetValue(aDadosDTA[nCntFor2,nCntFor3,1],aDadosDTA[nCntFor2,nCntFor3,2])
										lCont := .F.
										nItErrDTA := nCntFor3
										Exit
									EndIf
								EndIf
							Next nCntFor3
						EndIf
					
					Next nCntFor2
				Else
					lCont := .F.
				EndIf
			EndIf

			//-- Grava os Dados
			If lCont
				If (lCont := oModelCar:VldData())
					oModelCar:CommitData()
				EndIf
			EndIf

			//-- Se Ocorreu Algum Erro Exibe Mensagem
			If !lCont
				//-- Monta mensagem de erro
				TF67MntErr(oModelCar)
			
				//-- Verifica se o Erro Ocorreu no Grid dos Documentos
				If nItErrDTA > 0
					AutoGrLog(STR0013 + " [" + AllTrim(AllToChar(nItErrDTA)) + "]")	//-- "Erro no Item do Documento:"
				EndIf
			
				MostraErro()
			EndIf
			
			//-- Desativa o Model do Carregamnto
			oModelCar:DeActivate()
				
			AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
		EndIf
	EndIf

	If lGerOper //-- Verifica se devera gerar as Operacoes (MV_GEROPER)
		
		//-- Executa servicos operacionais dos documentos
		For nA := 1 To Len( aServic )

			//--  ( 02 ) Verifica DTW buscando última operação para gravar sequencia na DTA 
			DTW->(dbSetOrder(1))
			If ( DTW->(MsSeek(xFilial('DTW')+M->DTA_FILORI+M->DTA_VIAGEM+PADL(cSequen,TAMSX3("DTW_SEQUEN")[1],"0"))) )
				cQuery := " SELECT DTA_VIAGEM, DTA_FILORI, DTA_FILDOC, DTA_DOC, DTA_SERIE "
				cQuery += " FROM " + RetSqlTab('DTA')
				cQuery += " WHERE DTA_FILORI = '"+DTW->DTW_FILORI+"' "
				cQuery += " AND DTA_VIAGEM = '"+DTW->DTW_VIAGEM+"' "
				cQuery += " AND DTA_SEQDTW = ' ' "
				cQuery += " AND D_E_L_E_T_ = ' ' "
				cQuery += " ORDER BY DTA_FILDOC, DTA_DOC "
				cQuery := ChangeQuery(cQuery)
				cAliasNew := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
				DTA->(dbSetOrder(2))
				If (DTA->(MsSeek(xFilial('DTA') + (cAliasNew)->DTA_FILORI + (cAliasNew)->DTA_VIAGEM + (cAliasNew)->DTA_FILDOC + ;
																										(cAliasNew)->DTA_DOC    + ;
																										(cAliasNew)->DTA_SERIE  )))
					While ( (cAliasNew)->( !Eof() ) .And. (cAliasNew)->(DTA_FILDOC) == DTA->DTA_FILDOC .And. (cAliasNew)->(DTA_DOC) == DTA->DTA_DOC)
						//-- Grava sequência na DTA
						RecLock("DTA", .F.)
						DTA->DTA_SEQDTW := PADL(cSequen,TAMSX3("DTW_SEQUEN")[1],"0")
						MsUnLock()
						(cAliasNew)->(DbSkip())
						DTA->(DbSkip())
					EndDo
				EndIf
				(cAliasNew)->(DbCloseArea())
			EndIf

		Next nA
	EndIf

	//-- Atualiza Status da Programacao de Carregamento. Quando status da Programação for 'Documentos nao efetivados', indica que
	//-- os documentos nao foram transmitidos. O carregamento da viagem so é permitido quando o documento
	//-- for autorizado, portanto se todos os doctos foram carregados atualizamos o status da Prog. para Efetivada. 
	DbSelectArea("DF8")
	If DF8->(ColumnPos("DF8_SEQPRG")) > 0
		DF8->( DbSetOrder( 2 ) ) //-- DF8_FILIAL+DF8_FILORI+DF8_VIAGEM
		If DbSeek(xFilial("DF8") + M->DTA_FILORI + M->DTA_VIAGEM) .And. DF8->DF8_STATUS == StrZero(3,Len(DF8->DF8_STATUS))  //Doctos Nao efetivados
			lAtuDF8:= .T.
			//--- Verificar se todos os documentos foram carregados.
			cSeekDUD:= M->DTA_FILORI + StrZero(1,Len(DUD->DUD_STATUS)) + M->DTA_VIAGEM
			DUD->(dbSetOrder(4))
			If DUD->(MsSeek(xFilial('DUD') + cSeekDUD ))
				While DUD->( !Eof() ) .And. DUD->(DUD_FILORI+DUD_STATUS+DUD_VIAGEM) == cSeekDUD   
					If DUD->DUD_SERTMS <> '1' 
						lAtuDF8:= .F.
						Exit
					EndIf
					DUD->(DbSkip())
				EndDo
			EndIf	
					 
			If lAtuDF8
				RecLock("DF8",.F.)
				DF8->DF8_STATUS:= StrZero(2,Len(DF8->DF8_STATUS))  //Efetivada
				DF8->(MsUnLock())
			EndIf
				
		EndIf
	EndIf

	If lBlqViag
		// Verifica bloqueio de documentos carregados exibindo help
		TmsBlqViag( M->DTA_FILORI, M->DTA_VIAGEM, Nil, Nil, Nil, Nil, lHelp )
		
	EndIf	

EndIf

//-- Ponto de Entrada utilizado para gravacao complementar do carregamento
If lTM210Grv
	ExecBlock("TM210GRV",.F.,.F., { nOpc, M->DTA_FILORI, M->DTA_VIAGEM })
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA210Cols  ³ Autor ³Patricia A. Salomao ³ Data ³06.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta aCols                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA210Cols()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TMSA210Cols()
Local aAreaDT6 := DT6->(GetArea())
Local nCntFor  := 0

Aadd(aCols,Array(Len(aHeader)+1))
For nCntFor := 1 To Len(aHeader)
	aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
Next
aCols[Len(aCols),Len(aHeader)+1] := .F.

RestArea(aAreaDT6)
Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA210Del() ³ Autor ³Patricia A. Salomao ³ Data ³ 23/05/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Deleta todos os elementos do aCols que tenham o mesmo no. de  ³±±
±±³          ³Documento / Serie                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA210Del()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.F.                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA210Del()

Local nLoop, nSeek
Local lLocaliza  := GetMV('MV_LOCALIZ')=="S"        
Local lColeta    := (cSerTms == StrZero(1,Len(DUD->DUD_SERTMS)))

Local lCONTDOC   := SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran")

//Condicao para nao chamar o delOk duas vezes
If __nDelItem == 1
	__nDelItem := 0
	Return .F.
EndIf

__nDelItem := 1

If !aCols[n,Len(aHeader) + 1] //-- Está deletando a linha
	//-- Limpa marcas dos agendamentos
	TMSALimAge(StrZero(ThreadId(),20))

	If lCONTDOC
		TmsConTran(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,.F.)
	EndIf

Else //-- Está reativando a linha
	//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos

	If lCONTDOC .And. !TmsConTran(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,.T.)				
		lRet := .F.	
	EndIf

	If lRet
		If lColeta
			If !TMSAVerAge("3",,,,,,,,,DT6->DT6_FILDOC,DT6->DT6_DOC,,"2",.T.,.T.,,,StrZero(ThreadId(),20))
				Return .F.
			EndIf
		Else
			If !TMSAVerAge("1",DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,,,,,,,,"2",.T.,.T.,,,StrZero(ThreadId(),20))
				Return .F.
			EndIf
		EndIf
	EndIf
EndIf

If !lLocaliza
	Aeval( aCols, { |x|  IIF(  x[GdFieldPos('DTA_FILDOC')]+ x[GdFieldPos('DTA_DOC')]+x[GdFieldPos('DTA_SERIE')] == GdFieldGet('DTA_FILDOC',n) + GdFieldGet('DTA_DOC',n)+ GdFieldGet('DTA_SERIE',n) , x[Len(x)] := .T. , .T.) })
Else
	Aeval( aCols, { |x|  IIF( x[GdFieldPos('DTA_LOCAL')]+x[GdFieldPos('DTA_LOCALI')]+ x[GdFieldPos('DTA_UNITIZ')]+x[GdFieldPos('DTA_CODANA')]+x[GdFieldPos('DTA_FILDOC')]+ x[GdFieldPos('DTA_DOC')]+x[GdFieldPos('DTA_SERIE')] == ;
	GdFieldGet('DTA_LOCAL',n) + GdFieldGet('DTA_LOCALI',n)+GdFieldGet('DTA_UNITIZ',n)+GdFieldGet('DTA_CODANA',n)+GdFieldGet('DTA_FILDOC',n) + GdFieldGet('DTA_DOC',n)+ GdFieldGet('DTA_SERIE',n) , x[Len(x)] := .T. , .T.) })
EndIf

For nLoop := 1 to Len( aCols )
	nSeek := Ascan(aCols,{|x| x[Len(x)] })
	If nSeek > 0
		aCols:= ADel( aCols, nSeek )
		aCols:= ASize( aCols, Len( aCols ) - 1)
	EndIf
Next nLoop

If Empty(aCols)
	AAdd(aCols,Array(Len(aHeader)+1))
	Aeval( aHeader, { |e, nI | aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2]) } )
	aCols[Len(aCols),Len(aHeader)+1] := .F.
EndIf
//-- Atualizando dados do Rodape
TmsA210Rdp()
oGetD:oBrowse:Refresh(.T.)
Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA210Whe() ³ Autor ³Patricia A. Salomao ³ Data ³ 23/05/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao dos campos (X3_WHEN)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA210Whe()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA210Whe()

Local lLocaliza := SuperGetMv("MV_LOCALIZ",.F.,"") == "S"
Local cCampo    := ReadVar()
Local lRet      := .T.
Local cSeek     := ''
Local lVgeMod2  := (Left(FunName(),7) == 'TMSA144' .Or. Left(FunName(),7) == 'TMSA143' .Or. Left(FunName(),7) == 'TMSA153')

Local cQuery	:= ""
Local cAliasQry := GetNextAlias()					    
Local lVgeMod3  := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)

If !lVgeMod3
	If cCampo $ 'M->DTA_LOCAL.M->DTA_LOCALI.M->DTA_FILDOC.M->DTA_DOC.M->DTA_SERIE.M->DTA_UNITIZ.M->DTA_CODANA'
	   //-- Somente sera permitido alterar documento com status "Em Aberto".
	   If lVgeMod2
	      lRet := GDFieldGet("DUD_STATUS",n) == StrZero(1,Len(DUD->DUD_STATUS))
	   EndIf
		If lLocaliza .And. !lRet
			If !Empty(GDFieldGet('DTA_LOCAL',n)) .And. !Empty(GDFieldGet('DTA_LOCALI',n)) .And. !Empty(GDFieldGet('DTA_QTDVOL',n))
				Help("",1,"TMSA21009")  //-- O Armazem / Endereco nao pode ser alterado
				lRet := .F.
			EndIf
		EndIf
		
	ElseIf cCampo $ 'M->DTA_FILDPC'
		//-- Somente permite alterar a filial despacho se o Documento for alianca
		If !TmsDocAli(GDFieldGet( 'DTA_FILDOC', n ),GDFieldGet( 'DTA_DOC', n ),GDFieldGet( 'DTA_SERIE', n )) .Or. ;
			TmsPercAli(GDFieldGet( 'DTA_FILDOC', n ),GDFieldGet( 'DTA_DOC', n ),GDFieldGet( 'DTA_SERIE', n )) == 2 //-- Segundo Percurso
			lRet := .F.
		EndIf
	ElseIf AllTrim(cCampo) $ 'M->DTA_QTDVOL.M->DTA_PESO.M->DTA_PESOM3.M->DTA_METRO3.M->DTA_VALMER.M->DTA_VALFRE.M->DTA_PESLIQ'
		//--Nao permite editar estes campos, senao for Transporte Internacional
		lRet := SuperGetMv('MV_TMSCPAR',,.F.) .And. ((IsInCallStack(AllTrim('TMSA210I'))) .Or. (IsInCallStack(AllTrim('TMSA140D'))) .Or. (IsInCallStack(AllTrim('TMSA144I'))) .Or. (IsInCallStack(AllTrim('TMSA144J'))) ) 
		If lRet
			cSeek := GDFieldGet( "DTA_FILDOC", n )+GDFieldGet( "DTA_DOC", n )+GDFieldGet( "DTA_SERIE", n )
			If Empty(cSeek)
				lRet := .F.
			EndIf
			If lRet
				DT6->(dbSetOrder(1))
				If DT6->(dbSeek(xFilial('DT6')+cSeek))
					//--Nao pode ter carregamento parcial no Transporte Nacional
					If DT6->DT6_TIPTRA != StrZero(4,Len(DC5->DC5_TIPTRA)) //Transporte Internacional
						MsgAlert(STR0059) //--"Nao e permitido efetuar carregamento parcial no transporte nacional"
						lRet := .F.
					ElseIf !(cCampo $ 'M->DTA_QTDVOL') .And. DT6->DT6_QTDVOL == GDFieldGet( "DTA_QTDVOL", n )
						lRet := .F.
						//--Editar o campo DTA_VALFRE para ser digitado o valor do frete,
						If cCampo $ 'M->DTA_VALFRE'
							lRet := .T.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf cCampo $ 'M->DTA_CODVEI'
		//-- So informar o veiculo se filial de origem e viagem estiverem preenchidas.
		lRet := !Empty(M->DTA_FILORI) .And. !Empty(M->DTA_VIAGEM)
	ElseIf cCampo $ 'M->DTA_VEICAR'
		lRet := !Empty(M->DTA_FILORI) .And. !Empty(M->DTA_VIAGEM) .And. !Empty(M->DTA_CODRB1)
	ElseIf cCampo $ 'M->DTA_ORIGEM'
		
			cQuery := " SELECT DUD.DUD_MANIFE, DUD.DUD_FILDOC, DUD.DUD_DOC, DUD.DUD_SERIE, DTX.DTX_VIAGEM, DTX.DTX_IDIMDF "		
			cQuery += "   FROM " + RetSQLName("DUD") + " DUD "
			cQuery += "   INNER JOIN " + RetSQLName("DTX") + " DTX "
			cQuery += " 	ON  DTX.DTX_FILIAL = '" + xFilial("DUD") +"' "	
			cQuery += "     AND DTX.DTX_FILORI = DUD.DUD_FILORI "
			cQuery += "     AND DTX.DTX_VIAGEM = DUD.DUD_VIAGEM"
			cQuery += "	WHERE   DTX.DTX_FILIAL = '" + xFilial("DTX") +"'"	
			cQuery += "     AND DTX.DTX_FILMAN = '" + cFilAnt  + "' "	
			cQuery += "     AND DTX.DTX_FILORI = '" + DTQ->DTQ_FILORI + "' "
			cQuery += "     AND DTX.DTX_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
			cQuery += "     AND DTX.DTX_TIPMAN =  '2' "			
			cQuery += "     AND DTX.DTX_IDIMDF =  '100' "
			cQuery += "     AND DTX.D_E_L_E_T_ =  ' ' "
			cQuery += "     AND DUD.D_E_L_E_T_ =  ' ' "
			cQuery += "     AND DUD_FILDOC = '" +  GDFieldGet('DTA_FILDOC',n)+ "' "	
			cQuery += "     AND DUD_DOC    = '" +  GDFieldGet('DTA_DOC',n)   + "' "
			cQuery += "     AND DUD_SERIE  = '" +  GDFieldGet('DTA_SERIE',n) + "' "	
			cQuery += "     AND DUD_MANIFE <> ' ' "				
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )		
				
			If (cAliasQry)->(!Eof()) 
				lRet := .F.	
			EndIf		
			(cAliasQry)->(DbCloseArea())
		
	Else
		lRet := !lLocaliza
	EndIf
	oGetD:oBrowse:Refresh(.T.)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA210Lim³ Autor ³ Patricia A. Salomao   ³ Data ³13.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Analisa as informacoes dos documentos selecionados para a   ³±±
±±³          ³consulta de limites                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA210Lim(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Opcao Selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA210Lim( nOpcx )

Local aLimite	  	:= {}
Local nTotFreRec 	:= 0
Local nCntFor	  	:= 0
Local cSeek      	:= ''
Local cSeekDTC   	:= ''
Local cFilDoc    	:= ''
Local cDoc       	:= ''
Local cSerie     	:= ''
Local aCheckDoc  	:= {} //-- Array para verificar se o documento jah foi incluido no calculo do limite


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formato do vetor aLimite                                              ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ [01] = Codigo do cliente remetente                                    ³
//³ [02] = Loja do cliente remetente                                      ³
//³ [03] = Codigo do produto                                              ³
//³ [04] = Valor da Mercadoria                                            ³
//³ [05] = Peso Real                                                      ³
//³ [06] = Peso Cubado                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DT6->(DbSetOrder(1))
DTC->(DbSetOrder(3))
DTA->(dbSetOrder(2))

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

DTA->(MsSeek( cSeek := xFilial("DTA") + M->DTA_FILORI + M->DTA_VIAGEM ))
nTotFreRec := 0
Do While DTA->( !Eof() .And. DTA_FILIAL+DTA_FILORI+DTA_VIAGEM == cSeek )
	//-- Documentos
	If DT6->( MsSeek( xFilial( 'DT6' ) + DTA->DTA_FILDOC + DTA->DTA_DOC + DTA->DTA_SERIE ) )	
   	nTotFreRec += DT6->DT6_VALFRE
		cSeekDTC   := DTA->DTA_FILDOC + DTA->DTA_DOC + DTA->DTA_SERIE
		If DT6->DT6_DOCTMS == StrZero(6,Len(DT6->DT6_DOCTMS)) .And. !Empty(DT6->DT6_DOCDCO)
			cSeekDTC := DT6->(DT6_FILDCO + DT6_DOCDCO + DT6_SERDCO)
	   EndIf
	
		//-- Nota fiscais
		If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(DTA->DTA_FILDOC, DTA->DTA_DOC, DTA->DTA_SERIE)
			If DTC->( MsSeek( xFilial( 'DTC' ) + cSeekDTC ) )
				While DTC->(!Eof()) .And. DTC->DTC_FILIAL + DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE == xFilial( 'DTC' ) +  cSeekDTC
					If Ascan( aCheckDoc, { |x| x[1] + x[2] + x[3] + x[4] + x[5] + x[6] == DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE + DTC->DTC_CLIREM + DTC->DTC_LOJREM + DTC->DTC_CODPRO } ) == 0
						Aadd( aLimite,{ DTC->DTC_CLIREM, DTC->DTC_LOJREM, DTC->DTC_CODPRO, DTC->DTC_VALOR, DTC->DTC_PESO, DTC->DTC_PESOM3 } )
						AAdd( aCheckDoc, { DTC->DTC_FILDOC, DTC->DTC_DOC, DTC->DTC_SERIE, DTC->DTC_CLIREM, DTC->DTC_LOJREM, DTC->DTC_CODPRO })
					EndIf
					DTC->(DbSkip())
				EndDo
			EndIf
		Else
			DbSelectArea("DY4")
			DY4->(DbSetOrder(1)) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto		
			If DY4->( MsSeek( xFilial( 'DY4' ) + cSeekDTC ) )
				While DY4->(!Eof()) .And. DY4->DY4_FILIAL + DY4->DY4_FILDOC + DY4->DY4_DOC + DY4->DY4_SERIE == xFilial( 'DY4' ) +  cSeekDTC
					DbSelectArea("DTC")
					DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto
					//Posiciona na DTC a partir da DY4				
					If DTC->(MsSeek(xFilial("DTC")+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM+DY4->DY4_CODPRO+DY4->DY4_FILORI+DY4->DY4_LOTNFC))
						If Ascan( aCheckDoc, { |x| x[1] + x[2] + x[3] + x[4] + x[5] + x[6] == DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE + DTC->DTC_CLIREM + DTC->DTC_LOJREM + DTC->DTC_CODPRO } ) == 0
							Aadd( aLimite,{ DTC->DTC_CLIREM, DTC->DTC_LOJREM, DTC->DTC_CODPRO, DTC->DTC_VALOR, DTC->DTC_PESO, DTC->DTC_PESOM3 } )
							AAdd( aCheckDoc, { DTC->DTC_FILDOC, DTC->DTC_DOC, DTC->DTC_SERIE, DTC->DTC_CLIREM, DTC->DTC_LOJREM, DTC->DTC_CODPRO })
						EndIf
					Endif	
					DY4->(DbSkip())
				EndDo
			EndIf				
		Endif	
	EndIf
	DTA->(dbSkip())
EndDo

If lCarreg //-- Carregar
	For nCntFor:= 1 To Len( aCols )
		cFilDoc    := GDFieldGet('DTA_FILDOC',nCntFor)
		cDoc       := GDFieldGet('DTA_DOC'   ,nCntFor)
		cSerie     := GDFieldGet('DTA_SERIE' ,nCntFor)
		nTotFreRec := 0               
		//-- Documentos
		If DT6->( MsSeek( xFilial( 'DT6' ) + cFilDoc + cDoc + cSerie ) )
			cSeekDTC := cFilDoc + cDoc + cSerie
			If DT6->DT6_DOCTMS == StrZero(6,Len(DT6->DT6_DOCTMS)) .And. !Empty(DT6->DT6_DOCDCO)
				cSeekDTC := DT6->(DT6_FILDCO + DT6_DOCDCO + DT6_SERDCO)
		   EndIf		
			//-- Nota fiscais
			If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc,cDoc,cSerie)
				If DTC->( MsSeek( xFilial( 'DTC' ) + cSeekDTC ) )
					While DTC->(!Eof()) .And. DTC->DTC_FILIAL + DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE == xFilial( 'DTC' ) + cSeekDTC
						If Ascan( aCheckDoc, { |x| x[1] + x[2] + x[3] + x[4] + x[5] + x[6] == DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE + DTC->DTC_CLIREM + DTC->DTC_LOJREM + DTC->DTC_CODPRO } ) == 0
							Aadd( aLimite,{ DTC->DTC_CLIREM, DTC->DTC_LOJREM, DTC->DTC_CODPRO, DTC->DTC_VALOR, DTC->DTC_PESO, DTC->DTC_PESOM3 } )
							AAdd( aCheckDoc, { DTC->DTC_FILDOC, DTC->DTC_DOC, DTC->DTC_SERIE, DTC->DTC_CLIREM, DTC->DTC_LOJREM, DTC->DTC_CODPRO })
						EndIf
						DTC->(DbSkip())
					EndDo
				EndIf
			Else
				If DY4->( MsSeek( xFilial( 'DY4' ) + cSeekDTC ) )
					While DY4->(!Eof()) .And. DY4->DY4_FILIAL + DY4->DY4_FILDOC + DY4->DY4_DOC + DY4->DY4_SERIE == xFilial( 'DY4' ) + cSeekDTC
						DbSelectArea("DTC")
						DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto
						//Posiciona na DTC a partir da DY4				
						If DTC->(MsSeek(xFilial("DTC")+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM+DY4->DY4_CODPRO+DY4->DY4_FILORI+DY4->DY4_LOTNFC))
							If Ascan( aCheckDoc, { |x| x[1] + x[2] + x[3] + x[4] + x[5] + x[6] == DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE + DTC->DTC_CLIREM + DTC->DTC_LOJREM + DTC->DTC_CODPRO } ) == 0
								Aadd( aLimite,{ DTC->DTC_CLIREM, DTC->DTC_LOJREM, DTC->DTC_CODPRO, DTC->DTC_VALOR, DTC->DTC_PESO, DTC->DTC_PESOM3 } )
								AAdd( aCheckDoc, { DTC->DTC_FILDOC, DTC->DTC_DOC, DTC->DTC_SERIE, DTC->DTC_CLIREM, DTC->DTC_LOJREM, DTC->DTC_CODPRO })
							EndIf
							DTC->(DbSkip())
						Endif						
					EndDo
				EndIf
			Endif	
			nTotFreRec += DT6->DT6_VALFRE
		EndIf
	Next
EndIf
          
TmsBlqViag( M->DTA_FILORI, M->DTA_VIAGEM, aLimite,,,,,,,,,, nTotFreRec )

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA210DUH³ Autor ³ Alex Egydio           ³ Data ³13.05.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta os enderecos vinculados a viagem                 ³±±
±±³          ³ Utilizado pela consulta F3( DLL ) do campo DTA_LOCAL       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de origem                                   ³±±
±±³          ³ ExpC2 = Viagem                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA210DUH(cFilOri,cViagem)

Local nI         := 0
Local aEnder	  := {}
Local cSeekDUD	  := ''
Local cSeekDUH	  := ''
Local cSeekDTC	  := ''
Local nRet		  := 0
Local nQtdVol    := 0 
Local nSeek      := 0
Local lCarregPar := SuperGetMv('MV_TMSCPAR',,.F.)
Local aDoctosPar := {}
Local lVgeMod2   := (Left(FunName(),7) == 'TMSA144' .Or. Left(FunName(),7) == 'TMSA143' .Or. Left(FunName(),7) == 'TMSA153')

Default cFilOri  := If(lVgeMod2,'',M->DTA_FILORI)
Default cViagem  := If(lVgeMod2,'',M->DTA_VIAGEM)

//--So habilita carregamento parcial em transporte internacional
If lCarregPar .And. !(IsInCallStack(AllTrim('TMSA210I'))) .And. !(IsInCallStack(AllTrim('TMSA140D'))) .And. !(IsInCallStack(AllTrim('TMSA144I')));
	.And. !(IsInCallStack(AllTrim('TMSA144J'))) 
	lCarregPar := .F.
EndIf

If !lVgeMod2
	DUD->(DbSetOrder(2))
	If	DUD->(MsSeek(cSeekDUD := xFilial('DUD') + cFilOri + cViagem))
		While DUD->( ! Eof() .And. DUD->DUD_FILIAL + DUD->DUD_FILORI + DUD->DUD_VIAGEM == cSeekDUD )

			//-- Documento já carregado
			If DUD->DUD_STATUS != StrZero(1,Len(DUD->DUD_STATUS))
				DUD->(dbSkip())
				Loop
			EndIf

			//-- Posiciona no documento
			DT6->(dbSetOrder(1))
			DT6->(dbSeek(xFilial("DT6")+DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE))
				    
		   cSeekDTC := DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)
		   //-- Se for documento de Devolucao, posiciona na Nota Fiscal de Origem
			If DT6->DT6_DOCTMS == StrZero(6,Len(DT6->DT6_DOCTMS)) .And. !Empty(DT6->DT6_DOCDCO)
				cSeekDTC := DT6->(DT6_FILDCO + DT6_DOCDCO + DT6_SERDCO)
		   EndIf
		   
			If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE)
				DTC->(DbSetOrder(3))
				DTC->(dbSeek(cSeekDTC := xFilial('DTC') + cSeekDTC))
				Do While !DTC->(Eof()) .And. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) == xFilial("DTC")+cSeekDTC
					DUH->(DbSetOrder(1))
					If	DUH->(dbSeek(cSeekDUH := xFilial('DUH') + cFilAnt + DTC->DTC_NUMNFC + DTC->DTC_SERNFC))
						While DUH->( ! Eof() .And. DUH->DUH_FILIAL + DUH->DUH_FILORI + DUH->DUH_NUMNFC + DUH->DUH_SERNFC == cSeekDUH )
						   nSeek := Ascan( aEnder,{|x| x[1] + x[2] == DUH->DUH_LOCAL + DUH->DUH_LOCALI })
							If nSeek > 0					
							   aEnder[nSeek][3] += DUH->DUH_QTDVOL // Adiciona a Qtde. de Volumes existentes no Endereco
								DUH->(DbSkip())
								Loop
							EndIf
							//-- Apresenta enderecos em aberto
							If	DUH->DUH_STATUS == StrZero(1,Len(DUH->DUH_STATUS))
							   If lCarregPar .And. DT6->DT6_DOCTMS == 'K' //-- Docto. com carregamento em Partes
							   	If Ascan(aDoctosPar,{ | e | e[1]+e[2]+e[3]+e[4]+e[5] == DUH->(DUH_LOCAL+DUH_LOCALI)+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE) }) == 0
							   		AAdd(aDoctosPar, { DUH->DUH_LOCAL, DUH->DUH_LOCALI, DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE, (DT6->DT6_VOLORI - DT6->DT6_QTDVOL) })
									EndIf
							   EndIf
							   nQtdVol := DUH->DUH_QTDVOL
								AAdd(aEnder,{ DUH->DUH_LOCAL, DUH->DUH_LOCALI, nQtdVol, DUH->DUH_FILORI, DUH->DUH_STATUS})
							EndIf
							DUH->(DbSkip())
						EndDo
					EndIf
					DTC->(dbSkip())
				EndDo
			Else			
				DbSelectArea("DY4")
				DY4->(DbSetOrder(1)) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
				DY4->( dbSeek( FwxFilial("DY4")+ cFilDoc + cDoc + cSerie ) )
				Do While !DY4->(Eof()) .And. DY4->(DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE) == xFilial("DY4")+cSeekDTC
					DUH->(DbSetOrder(1))
					If	DUH->(dbSeek(cSeekDUH := xFilial('DUH') + cFilAnt + DY4->DY4_NUMNFC + DY4->DY4_SERNFC))
						While DUH->( ! Eof() .And. DUH->DUH_FILIAL + DUH->DUH_FILORI + DUH->DUH_NUMNFC + DUH->DUH_SERNFC == cSeekDUH )
						   nSeek := Ascan( aEnder,{|x| x[1] + x[2] == DUH->DUH_LOCAL + DUH->DUH_LOCALI })
							If nSeek > 0					
							   aEnder[nSeek][3] += DUH->DUH_QTDVOL // Adiciona a Qtde. de Volumes existentes no Endereco
								DUH->(DbSkip())
								Loop
							EndIf
							//-- Apresenta enderecos em aberto
							If	DUH->DUH_STATUS == StrZero(1,Len(DUH->DUH_STATUS))
							   If lCarregPar .And. DT6->DT6_DOCTMS == 'K' //-- Docto. com carregamento em Partes
							   	If Ascan(aDoctosPar,{ | e | e[1]+e[2]+e[3]+e[4]+e[5] == DUH->(DUH_LOCAL+DUH_LOCALI)+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE) }) == 0
							   		AAdd(aDoctosPar, { DUH->DUH_LOCAL, DUH->DUH_LOCALI, DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE, (DT6->DT6_VOLORI - DT6->DT6_QTDVOL) })
									EndIf
							   EndIf
							   nQtdVol := DUH->DUH_QTDVOL
								AAdd(aEnder,{ DUH->DUH_LOCAL, DUH->DUH_LOCALI, nQtdVol, DUH->DUH_FILORI, DUH->DUH_STATUS})
							EndIf
							DUH->(DbSkip())
						EndDo
					EndIf
					DY4->(dbSkip())
				EndDo			
			Endif	
			DUD->(DbSkip())
		EndDo                           	
	EndIf                              
	If lCarregPar .And. Len(aDoctosPar) > 0
		For nI := 1 To Len(aDoctosPar)
			If (nSeek := Ascan(aEnder,{ | e | e[1]+e[2] = aDoctosPar[nI,1]+aDoctosPar[nI,2] })) > 0
				aEnder[nSeek,3] -= aDoctosPar[nI,6]
			EndIf
		Next nI
	EndIf									
	//-- Consulta F3 baseada em vetor apresentando os enderecos da viagem
	If !Empty(aEnder)
		nRet := TmsF3Array( {RetTitle('DUH_LOCAL'),RetTitle('DUH_LOCALI'),RetTitle('DUH_QTDVOL')}, aEnder, STR0047 ) //'Endereco'
		If !Empty(nRet) 
			DbSelectArea('DUH')
			DbSetOrder(2)
			MsSeek(xFilial('DUH') + aEnder[nRet,4] + aEnder[nRet,5] + aEnder[nRet,1] + aEnder[nRet,2])
		EndIf
	EndIf
Else
	If ConPad1(,,,"DBE")
		nRet := 1
	EndIf		
EndIf

Return IIf(nRet > 0, .T., .F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA210Dca³ Autor ³ Patricia A. Salomao   ³ Data ³25.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Apresenta as Filiais de Descarga vinculadas a Rota da Viagem³±±
±±³          ³Utilizado pela consulta F3( DLM ) do campo DTA_FILDCA       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA210Dca()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA210Dca()
Local cFilNome := ""
Local aFiliais := {}
Local nSeek    := 0 
Local nRet     := 0
Local NX
Local aAreaSM0	:= SM0->( GetArea() )
Local lVgeMod3  := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)
Local oModel    := Nil
Local oMdlFldDM6:= Nil

If lVgeMod3
    oModel     := FWModelActive()
	oMdlFldDM6 := oModel:GetModel("MdFieldDM6")
	cFilOri    := oMdlFldDM6:GetValue("DM6_FILORI")
	cViagem    := oMdlFldDM6:GetValue("DM6_VIAGEM")			
Else
	If Type('M->DTA_VIAGEM') <> 'U'
		cFilOri := M->DTA_FILORI
		cViagem := M->DTA_VIAGEM
	ElseIf Type('M->DDK_VIAGEM') <> 'U'
		cFilOri := M->DDK_FILORI
		cViagem := M->DDK_VIAGEM
	EndIf	

EndIf

DTQ->(dbSetOrder(2))
DTQ->(MsSeek(xFilial("DTQ")+cFilOri+cViagem))

If Type('M->DDK_VIAGEM') <> 'U'
	aFilDca := TMSRegDca(DTQ->DTQ_ROTA,,.F.)
ElseIf DTQ->DTQ_SERTMS == StrZero(3, Len(DTQ->DTQ_SERTMS))  // Viagem de Entrega
	aFilDca := TMSRegDca(DTQ->DTQ_ROTA,,.T.)
Else
	aFilDca := TMSRegDca(DTQ->DTQ_ROTA,,.F.)
EndIf

If !Empty(aFilDca)

	For nX:=1 To Len(aFilDca)
		cFilNome := Posicione('SM0',1,cEmpAnt+aFilDca[nX][3],'M0_FILIAL')
		AADD(aFiliais, {aFilDca[nX,3], cFilNome} )
	Next

EndIf
If !Empty(aFiliais)
	nRet := TmsF3Array( { STR0030 , STR0029 }, aFiliais, STR0028 ) //'Fil. Descarga' ### "Descricao" ### "Filiais de Descarga"

	If !Empty(nRet)
		// Verifica qual e' o Codigo da Regiao de Descarga
		nSeek:=Ascan(aFilDca, { |x| x[3] == aFiliais[nRet,1] } )
		If nSeek > 0
			DUY->(DbSetOrder(1))
			If !DUY->(DbSeek(xFilial('DUY')+aFilDca[nSeek,2]))
				Help('', 1, "REGNOIS")
				nRet := 0
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aAreaSM0)
Return( nRet > 0 )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA210Srv³ Autor ³ Alex Egydio           ³ Data ³19.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o servico informado no parametro MV_SVCENT, apenas  ³±±
±±³          ³ p/viagens de entrega.                                      ³±±
±±³          ³ Utilizado por TmsA140 e TmsA210                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tipo do servico de transporte                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA210Srv(cSrvTms)

Local aAreaAnt	:= GetArea()
Local aAreaDC5	:= DC5->(GetArea())
Local aAreaDC6	:= DC6->(GetArea())
Local cAtivChg	:= GetMv('MV_ATIVCHG',,'')
Local cAtivSai	:= GetMv('MV_ATIVSAI',,'')
Local cSeekDC5	:= ''
Local cSeekDC6	:= ''
Local cSvCent	:= ''

cSvCent := Iif(Type('cServEnt')=='C',cServEnt,Padr(GetMV('MV_SVCENT',,''),Len(DC5->DC5_SERVIC)))

//-- Valida o servico informado no parametro MV_SVCENT, somente para viagens de entrega ou reprocesso
DC5->(DbSetOrder( 1 ))
If Empty( cSvCent ) .Or. DC5->( ! MsSeek( cSeekDC5 := xFilial('DC5') + cSvCent ) )
	Help('',1,'TMSA21016') //"Parametro de servico de entrega ou reprocesso invalido ..."
	Return(.F.)
Else
	While DC5->( !Eof() .And. DC5->DC5_FILIAL + DC5->DC5_SERVIC == cSeekDC5 )
		DC6->(DbSetOrder( 1 ))
		If	DC6->(MsSeek( cSeekDC6 := xFilial('DC6') + DC5->DC5_TAREFA ))
			While DC6->( !Eof() .And. DC6->DC6_FILIAL + DC6->DC6_TAREFA == cSeekDC6 )
				If DC6->DC6_ATIVID == cAtivChg  .Or. DC6->DC6_ATIVID == cAtivSai
					Help('',1,'TMSA21015') //-- O Servico especificado no parametro MV_SVCENT esta incorreto ...
					Return(.F.)
				EndIf
				DC6->(DbSkip())
			EndDo
		EndIf
		DC5->(DbSkip())
	EndDo
EndIf
RestArea(aAreaDC6)
RestArea(aAreaDC5)
RestArea(aAreaAnt)

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmsa210Viag³ Autor ³ Eduardo de Souza     ³ Data ³ 20/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza a viagem                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa210Viag()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa210Viag()

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

TmsVisViag(M->DTA_FILORI,M->DTA_VIAGEM,cSerTms,cTipTra)

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A210Trigger³ Autor ³ Richard Anderson     ³ Data ³ 04/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa gatilho de campos a partir do enderecamento        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A210Trigger(ExpL1)                                         ³±±
±±³          ³ ExpL1 = Indica se a chamada foi a partir da viagem modelo 2³±±
±±³          ³ ExpN1 = Item do aCols                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A210Trigger(lVgeMod2,nItem)

Local   lCarregPar := SuperGetMv('MV_TMSCPAR',,.F.)
Local   lPesLiq    := .F.

Default nItem      := n

SX3->(DbSetOrder(2))
If SX3->(DbSeek("DTA_PESLIQ"))
	lPesLiq := .T.
EndIf

//--So habilita carregamento parcial em transporte internacional
If lCarregPar .And. !(IsInCallStack(AllTrim('TMSA210I'))) .And. !(IsInCallStack(AllTrim('TMSA140D'))) .Or. !(IsInCallStack(AllTrim('TMSA144I'))) .Or. !(IsInCallStack(AllTrim('TMSA144J'))) 
	lCarregPar := .F.
EndIf

GDFieldPut( 'DTA_LOCAL' , DUH->DUH_LOCAL  , nItem )
GDFieldPut( 'DTA_LOCALI', DUH->DUH_LOCALI , nItem )
GDFieldPut( 'DTA_FILDOC', DT6->DT6_FILDOC , nItem )
GDFieldPut( 'DTA_DOC'   , DT6->DT6_DOC    , nItem )
GDFieldPut( 'DTA_SERIE' , DT6->DT6_SERIE  , nItem )
GDFieldPut( 'DTA_QTDVOL', DUH->DUH_QTDVOL , nItem )
GDFieldPut( 'DTA_UNITIZ' , DUH->DUH_UNITIZ  , nItem )
GDFieldPut( 'DTA_CODANA' , DUH->DUH_CODANA  , nItem )
If !lVgeMod2
	GDFieldPut( 'DTA_PESO'  , DT6->DT6_PESO, nItem )
	GDFieldPut( 'DTA_FILDCA', IIf( Len(aFilDca) == 1, aFilDca[1][3], Space(Len(DTA->DTA_FILDCA)) ), nItem )
	//-- Atualiza a Filial de Redespacho
	If lAlianca
		If !TmsDocAli(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE) .Or. ;
			TmsPercAli(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE) == 2 //-- Segundo Percurso
			GDFieldPut( 'DTA_FILDPC', GDFieldGet( 'DTA_FILDCA', nItem ) , nItem )
		EndIf
	EndIf
	If lCarregPar
		GDFieldPut( 'DTA_PESOM3', DT6->DT6_PESOM3, nItem )
		GDFieldPut( 'DTA_METRO3', DT6->DT6_METRO3, nItem )
		GDFieldPut( 'DTA_VALMER', DT6->DT6_VALMER, nItem )
		If lPesLiq
			GDFieldPut( 'DTA_PESLIQ', DT6->DT6_PESLIQ, nItem )
		EndIf
	EndIf
Else
	GdFieldPut( 'DT6_VOLORI', DT6->DT6_VOLORI, nItem )
	GDFieldPut( 'DT6_PESO'  , DT6->DT6_PESO  , nItem )
	GDFieldPut( 'DT6_PESOM3', DT6->DT6_PESOM3, nItem )
	GDFieldPut( 'DT6_VALMER', DT6->DT6_VALMER, nItem )
	If cSerTms == StrZero(3,Len(DC5->DC5_SERTMS))
		GDFieldPut( 'DT6_NOMREM', Posicione("SA1",1,xFilial("SA1")+DT6->(DT6_CLIREM+DT6_LOJREM),"A1_NREDUZ"), nItem )
		GDFieldPut( 'DT6_NOMDES', Posicione("SA1",1,xFilial("SA1")+DT6->(DT6_CLIDES+DT6_LOJDES),"A1_NREDUZ"), nItem )
		If Empty(SA1->A1_CEPE)
			GDFieldPut( 'DUE_BAIRRO', SA1->A1_BAIRRO , nItem )
			GDFieldPut( 'DUE_MUN'   , SA1->A1_MUN    , nItem )
			GDFieldPut( 'DUE_EST'   , SA1->A1_EST    , nItem )
		Else
			GDFieldPut( 'DUE_BAIRRO', SA1->A1_BAIRROE, nItem )
			GDFieldPut( 'DUE_MUN'   , SA1->A1_MUNE   , nItem )
			GDFieldPut( 'DUE_EST'   , SA1->A1_ESTE   , nItem )
		EndIf
	EndIf
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA210Rep³ Autor ³Wellington A Santos    ³ Data ³24.11.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Inverte selecao do carregamento na opcao estorna sim/nao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA210Rep()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
STATIC Function TmsA210Rep(oGetD, lAllMark)

Local nCount := 0

For nCount := 1 To Len(aCols)
	
	If GdFieldGet("DTA_ESTCAR",nCount) == "1"
		GdFieldPut("DTA_ESTCAR","2",nCount) 
	ElseIf GdFieldGet("DTA_ESTCAR",nCount) == "2"
		If A210VldMCa( M->DTA_FILORI , M->DTA_VIAGEM ,  GdFieldGet("DTA_FILORI",nCount) , GdFieldGet("DTA_DOC",nCount) , GdFieldGet("DTA_SERIE",nCount) )
		    GdFieldPut("DTA_ESTCAR","1",nCount) 
	    EndIf
	EndIf

Next

oGetD:oBrowse:Refresh(.T.)

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA210Rdp ³ Autor ³ Vitor Raspa          ³ Data ³ 16/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao dos campos do Rodape da tela de Carregamento   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA210Rdp()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA210                                                    ³±±
±±³          ³ TMSA144 - VIAGEM MOD. 2                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA210Rdp()
Local nAux        := 0
Local cDocto      := ''
Local aAreaDT6    := DT6->(GetArea())
Local aColsAux    := aClone( aCols )
Local nPosFilDoc  := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTA_FILDOC' })
Local nPosDoc     := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTA_DOC'    })
Local nPosSerie   := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTA_SERIE'  })
Local nPosQtdVol  := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DTA_QTDVOL' })
//--Verifica se a variavel "lVgeExpr"
//--esta declarada
If Type("lVgeExpr") <> 'L'
	PRIVATE	lVgeExpr := .F.
EndIf
//
nVolumes := 0
nPesReal := 0
nPesCub  := 0
nValMerc := 0
nDoctos  := 0
//
aSort(aColsAux,,,{ |x,y| x[nPosFilDoc]+x[nPosDoc]+x[nPosSerie] < y[nPosFilDoc]+y[nPosDoc]+y[nPosSerie] })
//
If	Len(aColsAux) > 0
	nAux := 1
	Do While nAux <= Len(aColsAux)
		If !(aColsAux[nAux,Len(aColsAux[nAux])])
			If (lVgeExpr)
				If ( DT6->(dbSeek(cDocto)) )
					nDoctos++
					nPesReal += DT6->DT6_PESO
					nPesCub  += DT6->DT6_PESOM3
					nValMerc += DT6->DT6_VALMER
				EndIf
				nVolumes += aColsAux[nAux,nPosQtdVol]
			Else
				If !(aColsAux[nAux,Len(aHeader)+1])
					If	cDocto <> aColsAux[nAux,nPosFilDoc]+aColsAux[nAux,nPosDoc]+aColsAux[nAux,nPosSerie]
						cDocto := aColsAux[nAux,nPosFilDoc]+aColsAux[nAux,nPosDoc]+aColsAux[nAux,nPosSerie]
						DT6->(dbSetOrder(1))
						If DT6->(dbSeek(xFilial('DT6')+cDocto))
							nDoctos++
							nPesReal += DT6->DT6_PESO
							nPesCub  += DT6->DT6_PESOM3
							nValMerc += DT6->DT6_VALMER
						EndIf
					EndIf
					If	nPosQtdVol > 0
						nVolumes += aColsAux[nAux,nPosQtdVol]
					EndIf
				EndIf
			EndIf
		EndIf
		nAux++
	EndDo
EndIf
//
oDoctos:Refresh()
oVolumes:Refresh()
oPesReal:Refresh()
oPesCub:Refresh()
oValMerc:Refresh()
//
RestArea(aAreaDT6)
Return(Nil)

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
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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

Function MenuD210()

Private aRotina	:= {	{ STR0002 ,"TMSXPesqui",0,1,0,.F.},;  // "Pesquisar"
						{ STR0003 ,"TmsA210Mnt",0,2,0,NIL},;  // "Visualizar"
						{ STR0004 ,"TmsA210Mnt",0,3,0,NIL},;  // "Carregar"
						{ STR0005 ,"TmsA210Mnt",0,4,0,NIL} }  // "Estornar"

If ExistBlock("TM210MNU")
	ExecBlock("TM210MNU",.F.,.F.)
EndIf

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA210Vei³ Autor ³Richard Anderson       ³ Data ³02.12.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta veiculos da viagem em carregamento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA210Vei()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA210Vei()

Local cAliasQry := GetNextAlias()
Local cQuery    := ""
Local aCodVei   := {}
Local cCodVei   := ""
Local cModVei   := ""
Local cModRb1   := ""
Local cModRb2   := ""
Local cModRb3	:= ""
Local aAreaDTR  := DTR->(GetArea())
Local lRet      := .T.
Local cCpoFilOri:= ""
Local cCpoViagem:= ""
Local cFilOri   := ""
Local cViagem   := ""                         
Local lTercRbq  := DTR->(ColumnPos("DTR_CODRB3")) > 0

If Type('M->DTA_VIAGEM') <> 'U'
	cCpoViagem:= 'M->DTA_VIAGEM'
	cCpoFilOri:= 'M->DTA_FILORI'
	cFilOri 	 := M->DTA_FILORI
	cViagem 	 := M->DTA_VIAGEM
ElseIf Type('M->DDK_VIAGEM') <> 'U'
	cCpoViagem:= 'M->DDK_VIAGEM'
	cCpoFilOri:= 'M->DDK_FILORI'
	cFilOri 	 := M->DDK_FILORI
	cViagem 	 := M->DDK_VIAGEM
ElseIf Type('M->DTQ_VIAGEM') <> 'U'
	cCpoViagem:= 'M->DTQ_VIAGEM'
	cCpoFilOri:= 'M->DTQ_FILORI'
	cFilOri 	 := M->DTQ_FILORI
	cViagem 	 := M->DTQ_VIAGEM
EndIf	

If Empty(cFilOri)     
	SX3->(dbSetOrder(2))
	SX3->(dbSeek(cCpoFilOri))
	MsgAlert(STR0042+X3Titulo()) //"Informe o campo "
	lRet := .F.
ElseIf Empty(cViagem)          
	SX3->(dbSetOrder(2))
	SX3->(dbSeek(cCpoViagem))
	MsgAlert(STR0042+X3Titulo()) //"Informe o campo "
	lRet := .F.
EndIf	

If lRet
	DTR->(dbSetOrder(3))
	If lTercRbq
		cQuery := "SELECT DTR_CODVEI, DTR_CODRB1, DTR_CODRB2, DTR_CODRB3 FROM "
	Else
		cQuery := "SELECT DTR_CODVEI, DTR_CODRB1, DTR_CODRB2 FROM "
	EndIf	
	cQuery += RetSqlName("DTR")
	cQuery += " WHERE DTR_FILIAL = '"+xFilial("DTR")+"'"
	cQuery += "   AND DTR_FILORI = '"+cFilOri+"'"
	cQuery += "   AND DTR_VIAGEM = '"+cViagem+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY "+SqlOrder(DTR->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
	While (cAliasQry)->(!Eof())
		cModVei := Posicione("DA3",1,xFilial("DA3")+(cAliasQry)->DTR_CODVEI,"DA3_DESC")
		cModRb1 := Posicione("DA3",1,xFilial("DA3")+(cAliasQry)->DTR_CODRB1,"DA3_DESC")
		cModRb2 := Posicione("DA3",1,xFilial("DA3")+(cAliasQry)->DTR_CODRB2,"DA3_DESC")
		If lTercRbq
			cModRb3 := Posicione("DA3",1,xFilial("DA3")+(cAliasQry)->DTR_CODRB3,"DA3_DESC")
		EndIf	
		Aadd( aCodVei, { .F., (cAliasQry)->DTR_CODVEI, cModVei, (cAliasQry)->DTR_CODRB1, cModRb1, (cAliasQry)->DTR_CODRB2, cModRb2, Iif(lTercRbq,(cAliasQry)->DTR_CODRB3, ''), Iif(lTercRbq,cModRb3,'') })
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaDTR)
	If Len(aCodVei) > 0
		lRet := TMSABrowse(aCodVei,STR0048,,,,.T.,{ STR0049, STR0050 }) //-- Veiculos da viagem //"Veículos da viagem"###'Cód.Veículo'###'Modelo'
		If lRet
			cCodVei := aCodVei[Ascan(aCodVei,{ | e | e[1] == .T. })][2]
			DTR->(dbSetOrder(3))
			If DTR->(dbSeek(xFilial('DTR')+cFilOri+cViagem+cCodVei))
				DA3->(dbSetOrder(1))
				DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODVEI))
			EndIf	
		EndIf
	Else
		MsgAlert(STR0051) //"Veículos da viagem não encontrados"
		lRet := .F.
	EndIf	
EndIf

RestArea(aAreaDTR)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TM210CodBr
Leitura Cód Barras dos Documentos da Viagem

@class
@author 	Rafael Souza
@version	1.0
@since		08/12/2014

/*/
//-------------------------------------------------------------------
Function TM210CodBr()

Local cCodbar  := Space(Len(DT6->DT6_CHVCTE)+1)
Local cCodbar2 := Space(Len(DT6->DT6_CHVCTE)+1)
Local oGetBar
Local lRet := .T.

Local oDlgBar := NIl

DEFINE DIALOG oDlgBar FROM 0,0 TO 100,400 TITLE STR0070 Of oMainWnd PIXEL  //--"Leitura do Cód. de Barras por Documento"

@ 16,10 SAY STR0071 Of oDlgBar PIXEL SIZE 100,10 //--Cód de barras"
@ 26,10 MSGET oGetBar VAR cCodbar SIZE 160,10 Picture '@!' VALID (Tmsa210Pre(@cCodBar,@oGetBar)) PIXEL
@ 25,11 MSGET oGetBar2 VAR cCodbar2 SIZE 1,1 //-- campo para mudanca de foco e execucao do valid

ACTIVATE DIALOG oDlgBar CENTERED 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Tmsa210Pre
Função que realiza a consulta se a chave informada na leitura do Doc.
existe. 
@class
@author    Rafael Souza	
@version	1.0
@since		12/12/2014

/*/
//-------------------------------------------------------------------
Static Function Tmsa210Pre(cCodBar,oGetBar)

Local 		lRet 		:= .T.
Local 		nI 			:= 1
Local		lAddRow	:= .F.
Default 	cCodBar	:= ""

If !Empty(cCodbar)
  dbSelectArea("DT6")

  If FindFunction('TmsVLDSIX') .And. TmsVLDSIX("DT6","I")
	  DT6->(dbSetOrder(18)) //DT6_FILIAL+DT6_CHVCTE
	
	  If !Empty(cCodBar) .And. DT6->(dbSeek(xFilial("DT6") + cCodBar))
		
		  If Ascan(aCols,{ |x| x[DTA->(GdFieldPos('DTA_FILDOC'))]+x[DTA->(GdFieldPos('DTA_DOC'))]+x[DTA->(GdFieldPos('DTA_SERIE'))] == DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE}) == 0
			
			  nI := Len(aCols)
						
			  If !Empty( aCols[nI][DTA->(GdFieldPos('DTA_FILDOC'))] ) .And.;
				  !Empty( aCols[nI][DTA->(GdFieldPos('DTA_DOC'   ))] ) .And.;
				  !Empty( aCols[nI][DTA->(GdFieldPos('DTA_SERIE' ))] )
				
				  // Adiciona uma nova linha no Acols
					lAddRow := .T.
				  aAdd(aCols, Array(Len(aHeader)+1))
				  For nI := 1 To Len(aHeader)
					  aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
				  Next nI
				
				  nI := Len(aCols)
				
				  If cSerTms != StrZero(2,Len(DC5->DC5_SERTMS)) .And. !IsInCallStack("TMSA210MNT")//-- Nao for Transporte (Mesma logica utilizada na montagem do aCols no fonte tmsa144)
			  		aCols[nI][DTA->(GdFieldPos('DUD_SEQUEN'))] := StrZero(nI, Len(DUD->DUD_SEQUEN))
				  EndIf
				  aCols[nI][Len(aHeader)+1] := .F.
				
				  oGetD:oBrowse:nAt := nI
				  n:= nI
				
			  EndIf
			
			  GdFieldPut( 'DTA_FILDOC', DT6->DT6_FILDOC, nI )
			  GdFieldPut( 'DTA_DOC'   , DT6->DT6_DOC, nI )
			  GdFieldPut( 'DTA_SERIE' , DT6->DT6_SERIE, nI )
			
			  M->DTA_FILDOC := DT6->DT6_FILDOC
			
			  If !TmsA210Val( 'M->DTA_FILDOC' )
				If lAddRow	  
				  aDel(aCols,nI)
				  aSize(aCols,Len(aCols)-1)
				  nI--
				  oGetD:oBrowse:nAt := nI
				  n:= nI			
				Else
					GdFieldPut( 'DTA_FILDOC', '', nI )
					GdFieldPut( 'DTA_DOC'   , '', nI )
					GdFieldPut( 'DTA_SERIE' , '', nI )
				EndIf			
			  Endif
									
			  cCodBar := Space(Len(DT6->DT6_CHVCTE)+1)				
			  oGetBar:SetFocus()
		
		  Else
			  Help ("",1,"TMSA21060") // Documento informado anteriormente.
			  lRet := .F.
			  cCodBar := Space(Len(DT6->DT6_CHVCTE)+1)
		  Endif	
			
	  ElseIf !Empty(cCodBar)
		  Help ("",1,"TMSA21059") // Chave de Documento não localizada ou inválida
		  lRet := .F.
		  cCodBar := Space(Len(DT6->DT6_CHVCTE)+1)
	  EndIf
	
	  oGetD:oBrowse:Refresh(.T.)
  EndIf
Else 
  cCodBar := Space(Len(DT6->DT6_CHVCTE)+1)
  lRet := .F.
EndIF


Return lRet 
//-------------------------------------------------------------------
/*/{Protheus.doc} Tmsa210GFE
Função preenche os campos da integracao TMS x GFE
@class
@author    Katia
@version	1.0
@since		14/11/2016

/*/
//-------------------------------------------------------------------

Function Tmsa210GFE(nLinha, cServico, cFilOri, cViagem, lTMA200, cCampo )
Local cCdrOri	:= ""
Local cUfDes	:= Criavar("DUD_UFDES")
Local cCdMunD	:= Criavar("DUD_CDMUND")
Local cCdrDes	:= ""
Local cDsMunD 	:= ""

Local cDTQTipVia:= ""
Local cDTQFilOri:= ""
Local aRet      := { '','','','','','','','','','','',''  }
Local cCdTpOP   := ""
Local cCdClFr   := ""
Local cTipVei   := ""
Local cCliDes	:= ""
Local cLojDes	:= ""
Local cCEPDes	:= ""

//--- Posicao do aRet
//-- aRet[1] - UF Origem
//-- aRet[2] - Cod.Municipio Origem
//-- aRet[3] - Desc.Municipio Origem
//-- aRet[4] - UF Destino
//-- aRet[5] - Cod.Municipio Destino
//-- aRet[6] - Desc.Municipio Destino
//-- aRet[7] - Tipo Operacao
//-- aRet[8] - Descricao Tipo Operacao
//-- aRet[9] - Classificacao Frete
//-- aRet[10] - Descricao Classificacao Frete
//-- aRet[11] - Tipo Veiculo
//-- aRet[12] - Descricao Veiculo

Default nLinha   := 0
Default cServico := ""
Default cFilOri  := ""
Default cViagem  := ""
Default lTMA200  := .F.   //Calculo do Frete TMSA200 - express
Default cCampo   := ""   //Somente determinado campo devera ser atualizado

If lTMA200
	cDTQTipVia:= DTQ->DTQ_TIPVIA
	cDTQFilOri:= DTQ->DTQ_FILORI
	cCdTpOP   := DTQ->DTQ_CDTPOP
	cCdClFr   := DTQ->DTQ_CDCLFR
	cTipVei   := DTQ->DTQ_TIPVEI
Else
	cDTQTipVia:= M->DTQ_TIPVIA
	cDTQFilOri:= M->DTQ_FILORI
	cCdTpOP   := M->DTQ_CDTPOP
	cCdClFr   := M->DTQ_CDCLFR
	cTipVei   := M->DTQ_TIPVEI
EndIf

If DUD->(ColumnPos("DUD_CDMUNO")) > 0 
	If Empty(cCampo)		                                                          
		//---------- Estado e Municipio de Origem do Documento		
		If cDTQFilOri == DT6->DT6_FILDOC
			cCdrOri:= DT6->DT6_CDRORI
		Else
			cCdrOri:= PadR(SuperGetMv('MV_CDRORI'),Len(DA8->DA8_CDRORI))
		EndIf
			
		DUY->(DbSetOrder(1))
		If DUY->(MsSeek(xFilial("DUY")+cCdrOri))
			If nLinha > 0
				GDFieldPut('DUD_UFORI' ,DUY->DUY_EST   , nLinha)
				GDFieldPut('DUD_CDMUNO',DUY->DUY_CODMUN, nLinha)
				GDFieldPut('DUD_MUNORI',DUY->DUY_DESCRI, nLinha)
			Else	
				aRet[1]:= DUY->DUY_EST
				aRet[2]:= DUY->DUY_CODMUN
				aRet[3]:= DUY->DUY_DESCRI
			EndIf	
		EndIf	
		
		//---------- Estado e Municipio de Origem do Documento
		If cServico == StrZero(2,Len(DUD->DUD_SERTMS))  //Transferencia, UF/Cod.Mun Destino serao preenchidos conforme DUD_FILDCA da viagem. (tmsa140grv)
			cCdrDes:= ''
		Else
			cCdrDes		:= DT6->DT6_CDRCAL

			//-- Tratamento para encontrar o CEP Destino
			cCliDes		:= DT6->DT6_CLIDES
			cLojDes		:= DT6->DT6_LOJDES
			cCEPDes		:= Posicione("SA1",1,xFilial("SA1")+cCliDes+cLojDes,"A1_CEP")

			//-- DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC
			DTC->(dbSetOrder(3))
			If DTC->(MsSeek(xFilial("DTC") + DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE + DT6_SERVIC )))
				If !Empty(DTC->DTC_SQEDES)
					//-- DUL_FILIAL+DUL_CODCLI+DUL_LOJCLI+DUL_SEQEND
					DUL->(dbSetOrder(2))
					If DUL->(dbSeek(xFilial("DUL") + cCliDes + cLojDes + DTC->DTC_SQEDES ))
						If !Empty(DUL->DUL_CEP)
							cCEPDes		:= DUL->DUL_CEP
						EndIf
					EndIf
				EndIF
			EndIf
		EndIf
		
		//Transferencia, UF/Cod.Mun Destino serao preenchidos conforme DUD_FILDCA da viagem. (tmsa140grv)
		If cServico <> StrZero(2,Len(DUD->DUD_SERTMS))  
			If Empty(cUfDes) .And. Empty(cCdMunD) 
				DUY->(DbSetOrder(1))
				If DUY->(MsSeek(xFilial("DUY")+cCdrDes))
					cUfDes := DUY->DUY_EST
					cCdMunD:= DUY->DUY_CODMUN
					cDsMunD:= DUY->DUY_DESCRI
				EndIf
			EndIf
			
			If nLinha > 0	
				GDFieldPut('DUD_UFDES' ,cUfDes   , nLinha)
				GDFieldPut('DUD_CDMUND',cCdMunD  , nLinha)
				GDFieldPut('DUD_MUNDES',cDsMunD  , nLinha)
				If !Empty(cCEPDes)
					GDFieldPut('DUD_CEPDES',cCEPDes  , nLinha)
				EndIf
			Else
				aRet[4]:= cUfDes
				aRet[5]:= cCdMunD
				aRet[6]:= cDsMunD
			EndIf	
		EndIf
	EndIf
	
	If nLinha > 0
		If Empty(cCampo) .Or. 'DTQ_CDTPOP' $ cCampo  
			GDFieldPut('DUD_CDTPOP',cCdTpOp, nLinha)
			GDFieldPut('DUD_DSTPOP',Posicione("GV4",1,xFilial("GV4")+cCdTpOp,"GV4_DSTPOP"), nLinha )
		EndIf	                           
		If Empty(cCampo) .Or.  'DTQ_CDCLFR' $ cCampo  
			GDFieldPut('DUD_CDCLFR',cCdClFr, nLinha)
			GDFieldPut('DUD_DSCLFR',Posicione("GUB",1,xFilial("GUB")+cCdClFr,"GUB_DSCLFR"), nLinha )
		EndIf	
		If Empty(cCampo) .Or. 'DTQ_TIPVEI' $ cCampo 
			GDFieldPut('DUD_TIPVEI',cTipVei, nLinha)
			GDFieldPut('DUD_DESTPV',Posicione("DUT",1,xFilial("DUT")+cTipVei,'DUT_DESCRI') , nLinha )
		EndIf		
	Else
		If Empty(cCampo) .Or. 'DTQ_CDTPOP' $ cCampo  
			aRet[7] := cCdTpOp
			aRet[8] := Posicione("GV4",1,xFilial("GV4")+cCdTpOp,"GV4_DSTPOP")
		EndIf	
		If Empty(cCampo) .Or. 'DTQ_CDCLFR' $ cCampo 	
			aRet[9] := cCdClFr 
			aRet[10]:= Posicione("GUB",1,xFilial("GUB")+cCdClFr,"GUB_DSCLFR")
		EndIf	
		If Empty(cCampo) .Or. 'DTQ_TIPVEI' $ cCampo 	
			aRet[11] := cTipVei
			aRet[12] := Posicione("DUT",1,xFilial("DUT")+cTipVei,'DUT_DESCRI')
		EndIf	
	EndIf

EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Tmsa210DUD
Preenche campos do Destino com base na Filial de Descarga do Docto de 
Transferencia (DUD_FILDCA)
@class
@author    Katia
@version	1.0
@since		14/11/2016

/*/
//-------------------------------------------------------------------

Function Tmsa210DUD()
Local aArea:= GetArea()

	DUD->DUD_UFDES  := NoAcentoCte(Posicione("SM0",1,cEmpAnt+DUD->DUD_FILDCA,"M0_ESTENT"))
	DUD->DUD_CDMUND := Substr(NoAcentoCte(Posicione("SM0",1,cEmpAnt+DUD->DUD_FILDCA,"M0_CODMUN")),3)
	DUD->DUD_CEPDES := NoAcentoCte(Posicione("SM0",1,cEmpAnt+DUD->DUD_FILDCA,"M0_CEPENT"))

RestArea(aArea)	
Return	

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Função que retorna o valor do Array com Viagem Principal e Coligada.
@class
@author	Alex Amaral
@version	1.0
@since		24/01/2017
@return	
@sample
/*/
//------------------------------------------------------------------- 
Function TM210COLIG(cFilOri, cViagem,lMdfeAut)

Local aVgaPrinc   := {}
Local aVgaColig   := {}
Local lMDFeSrv    := .F.

Default lMDFEAut  := GetMV("MV_MDFEAUT",,.F.) .And. ExistFunc("TmsMDFeAut")

	DbSelectArea("DTR")
	DbSetOrder(2)
	MsSeek(xFilial("DTR") + cFilOri + cViagem)
	If !Empty(DTR->DTR_FILVGE+DTR->DTR_NUMVGE)
		//Não e a Viagem Principal, acha viagem principal
		aVgaPrinc := VgaPrincial(cFilOri, cViagem)			
	Else	
		DbSetOrder(1)	
		If MsSeek(xFilial("DTR") + cFilOri + cViagem)
			//Achou viagem coligada, procura a principal	
			aVgaPrinc := VgaPrincial(cFilOri, cViagem)
		EndIf
	EndIf
		
	//Procura Viagens Coligadas
	If Len(aVgaPrinc) > 0 
		
		//--- Verifica se Serviço de transporte da viagem esta configurado para MDFe Automatico.
		If (lMDFEAut .Or. ExistFunc("TmsAutViag")) .And. FindFunction('TMA190Srv')
			lMDFeSrv:= TMA190Srv(aVgaPrinc[1][1], aVgaPrinc[1][2])
			If !lMDFeSrv
				lMDFEAut:= .F.
			EndIf			
		EndIf
		
		If !lMDFeSrv
			aVgaColig := VgaColigada(aVgaPrinc[1][1], aVgaPrinc[1][2] )
		EndIf
	EndIf

Return(aVgaColig)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A210VCnMan
Busca se a viagem possui manifestos com cancelamento não transmitido
@type function
@author Paulo Henrique Corrêa Cardoso
@version 12
@param  cFilOri  -> Filial de Origem da viagem
		cViagem  -> Viagem
		aManifes -> Array deve ser passado por referencia 
	                {[Filial do Manifesto],[Manifesto],[Serie do Manifesto],[Situação do Canc.]}
		lMstrErro -> Exibe a mensagem de erro
@since 28/12/2017
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Function A210VCnMan(cFilOri, cViagem, aManifes, lMstrErro, nLoop, cFilMan)
	Local lRet        := .F.
	Local cQuery      := ""
	Local cAliasQry   := GetNextAlias()
	Local cErro       := ""
	Local cTitFilMan  := ""
	Local cTitManife  := ""
	Local cTitSerMan  := ""
	Local cTitRTCMDF  := ""
	Local lMDFeAut    := SuperGetMV("MV_MDFEAUT",,.F.)  .And. ExistFunc("TmsMDFeAut") //--MDFe Automatico
	Local aMDFeCan    := {}
	Local lContinua   := .F.
	Local cFilBack    := cFilAnt
	Local aAreaSM0    := {}
	
	Default cFilOri   := ""
	Default cViagem   := ""
	Default aManifes  := {}
	Default lMstrErro := .T.
	Default nLoop     := 1
	Default cFilMan   := ""

	// Busca os titulos dos campos 
	cTitFilMan  := FWX3Titulo('DTX_FILMAN')
	cTitManife  := FWX3Titulo('DTX_MANIFE')
	cTitSerMan  := FWX3Titulo('DTX_SERMAN')
	cTitRTCMDF  := FWX3Titulo('DYN_RTCMDF') 

	If (lMdfeAut .Or. ExistFunc("TmsAutViag")) .And. FindFunction("TMA190Srv")  //Verifica o serviço de transporte da viagem
		lMdfeAut:= TMA190Srv(cFilOri,cViagem)
	EndIf

	cQuery += " SELECT DYN_FILMAN, " + CRLF
	cQuery += "        DYN_MANIFE, " + CRLF
	cQuery += "        DYN_SERMAN, " + CRLF
	cQuery += "        DYN_VIAGEM, " + CRLF
	cQuery += "        DYN_RTCMDF  " + CRLF
	cQuery += " FROM " + RetSQLName("DYN") + CRLF 
	cQuery += " WHERE DYN_FILIAL = '"+ FwxFilial("DYN") + "' " + CRLF
	cQuery += "       AND DYN_FILORI = '" + cFilOri + "' " + CRLF
	cQuery += "       AND DYN_VIAGEM = '" + cViagem + "' " + CRLF
	cQuery += "       AND DYN_STCMDF <> '2' "  + CRLF //2=Autorizado
    cQuery += "       AND D_E_L_E_T_ = ' ' " + CRLF
    If !Empty(cFilMan)
    	cQuery += "       AND DYN_FILMAN = '" + cFilMan + "' " 
    EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)

	While (cAliasQry)->(!Eof())
	    lRet := .T.
		
		If lMDFeAut .And. nLoop == 1
			Aadd(aMDFeCan,{(cAliasQry)->DYN_FILMAN,;
							(cAliasQry)->DYN_MANIFE,;
							(cAliasQry)->DYN_MANIFE,;
							(cAliasQry)->DYN_SERMAN,;
							(cAliasQry)->DYN_VIAGEM,;
							''})
		Else

			// Monta o array de retorno
			AADD(aManifes,{ (cAliasQry)->DYN_FILMAN,;
							(cAliasQry)->DYN_MANIFE,;
							(cAliasQry)->DYN_SERMAN,;
							(cAliasQry)->DYN_RTCMDF })
			
			// Monta a mensagem de erro				
			If lMstrErro
				cErro += cTitFilMan +  " : " + (cAliasQry)->DYN_FILMAN + " | "
				cErro += cTitManife +  " : " + (cAliasQry)->DYN_MANIFE + " | "
				cErro += cTitSerMan +  " : " + (cAliasQry)->DYN_SERMAN + " | "
				cErro += cTitRTCMDF +  " : " + (cAliasQry)->DYN_RTCMDF + CRLF + CRLF
			EndIf
		EndIf
		(cAliasQry)->(dbSkip())			
	EndDo
	(cAliasQry)->(dbCloseArea())

	If Len(aMDFeCan) > 0
		//-- Alterar o conteudo da variavel cFilAnt		
			aAreaSM0  := SM0->( GetArea() )											
			cFilAnt   := Posicione('SM0',1,cEmpAnt+aMDFeCan[Len(aMDFeCan),1],'FWCODFIL()')														
			lContinua := TmsMDFeAut(aMDFeCan, 3) //--Transmite o cancelamento do MDF-e   
			If lContinua
				TmsLimpDUD(cFilOri, cViagem, aMDFeCan)	//--Limpar a DUD
			EndIf 								         
			cFilAnt := Posicione('SM0',1,cEmpAnt+cFilBack,'FWCODFIL()') 
			RestArea(aAreaSM0)
	EndIf 
	
	If !lMDFeAut .Or. nLoop > 1
		// Exibe a mensagem de erro.
		If lRet .AND. lMstrErro
			AutoGrLog(STR0090 + CRLF) //"Não poderá ser realizado o estorno do carregamento, pois os seguintes manifestos possuem cancelamento não transmitido:"
			AutoGrLog( cErro )
			MostraErro() 
		EndIf
	Else
		lRet := A210VCnMan(cFilOri,cViagem,aManifes,lMstrErro,++nLoop)
	EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A210VEnMan
Busca se a viagem possui manifestos com encerramento não transmitido
@type function
@author Felipe Barbiere
@version 12
@param  cFilOri  -> Filial de Origem da viagem
		cViagem  -> Viagem
		aManifes -> Array deve ser passado por referencia 
	                {[Filial do Manifesto],[Manifesto],[Serie do Manifesto],[Situação do Canc.]}
		lMstrErro -> Exibe a mensagem de erro
@since 16/10/2018
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Function A210VEnMan(cFilOri, cViagem, aManifes, lMstrErro, nLoop, cFilMan)
	Local lRet        := .F.
	Local cQuery      := ""
	Local cAliasQry   := GetNextAlias()
	Local cErro       := ""
	Local cTitFilMan  := ""
	Local cTitManife  := ""
	Local cTitSerMan  := ""
	Local cTitSTFMDF  := ""
	Local lMDFeAut    := SuperGetMV("MV_MDFEAUT",,.F.)  .And. ExistFunc("TmsMDFeAut") //--MDFe Automatico
	Local aMDFeEnc    := {}
	Local lContinua   := .F.
	Local cFilBack    := cFilAnt
	Local aAreaSM0    := {}
	Local lUFAtiv     := DTX->(ColumnPos("DTX_UFATIV")) > 0
	
	Default cFilOri   := ""
	Default cViagem   := ""
	Default aManifes  := {}
	Default lMstrErro := .T.
	Default nLoop     := 1
	Default cFilMan   := ""

	// Busca os titulos dos campos 
	cTitFilMan  := FWX3Titulo('DTX_FILMAN')
	cTitManife  := FWX3Titulo('DTX_MANIFE')
	cTitSerMan  := FWX3Titulo('DTX_SERMAN')
	cTitSTFMDF  := FWX3Titulo('DTX_STFMDF') 

	If (lMdfeAut .Or. ExistFunc("TmsAutViag")) .And. FindFunction("TMA190Srv")  //Verifica o serviço de transporte da viagem
		lMdfeAut:= TMA190Srv(cFilOri,cViagem)
	EndIf

	cQuery += " SELECT DTX_FILMAN, " + CRLF
	cQuery += "        DTX_MANIFE, " + CRLF
	cQuery += "        DTX_SERMAN, " + CRLF
	cQuery += "        DTX_VIAGEM, " + CRLF
	cQuery += "        DTX_STFMDF " + CRLF
	If lUfAtiv 							
		cQuery += ", DTX_UFATIV"	
	EndIf
	cQuery += " FROM " + RetSQLName("DTX") + CRLF 
	cQuery += " WHERE DTX_FILIAL = '"+ FwxFilial("DTX") + "' " + CRLF
	cQuery += "       AND DTX_FILORI = '" + cFilOri + "' " + CRLF
	cQuery += "       AND DTX_VIAGEM = '" + cViagem + "' " + CRLF
	cQuery += "       AND DTX_STFMDF <> '2' "  + CRLF //--Encerramento não Autorizado
	cQuery += "       AND DTX_STIMDF =  '2' "  + CRLF //-- Envio Autorizado
	If !Empty(cFilMan)
    	cQuery += "       AND DTX_FILMAN = '" + cFilMan + "' " 
    EndIf
    cQuery += "       AND D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "       AND NOT EXISTS (SELECT 1 FROM " + RetSqlName("DYN") + " DYN " 
	cQuery += " WHERE DYN.DYN_FILIAL = '" + xFilial("DYN") + "'"
	cQuery += "       AND DYN.DYN_FILORI = '" + cFilOri + "' " + CRLF
	cQuery += "       AND DYN.DYN_VIAGEM = '" + cViagem + "' " + CRLF
	cQuery += "       AND DYN.DYN_STCMDF <> '2' "  + CRLF //-- Cancelamento não Autorizado
	If !Empty(cFilMan)
    	cQuery += "       AND DYN.DYN_FILMAN = '" + cFilMan + "' " 
    EndIf
    cQuery += "       AND DYN.D_E_L_E_T_ = ' ' )" + CRLF

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)

	While (cAliasQry)->(!Eof())
	    lRet := .T.
		
		If lMDFeAut .And. nLoop == 1
			Aadd(aMDFeEnc,{(cAliasQry)->DTX_FILMAN,;
							(cAliasQry)->DTX_MANIFE,;
							(cAliasQry)->DTX_MANIFE,;
							(cAliasQry)->DTX_SERMAN,;
							(cAliasQry)->DTX_VIAGEM,;
							Iif(lUFAtiv, (cAliasQry)->DTX_UFATIV, '')})
		Else

			// Monta o array de retorno
			AADD(aManifes,{ (cAliasQry)->DTX_FILMAN,;
							(cAliasQry)->DTX_MANIFE,;
							(cAliasQry)->DTX_SERMAN,;
							(cAliasQry)->DTX_STFMDF })
							
			// Monta a mensagem de erro				
			If lMstrErro
				cErro += cTitFilMan +  " : " + (cAliasQry)->DTX_FILMAN + " | "
				cErro += cTitManife +  " : " + (cAliasQry)->DTX_MANIFE + " | "
				cErro += cTitSerMan +  " : " + (cAliasQry)->DTX_SERMAN + " | "
				cErro += cTitSTFMDF +  " : " + (cAliasQry)->DTX_STFMDF + CRLF + CRLF
			EndIf
		EndIf
		(cAliasQry)->(dbSkip())			
	EndDo
	(cAliasQry)->(dbCloseArea())
	
	If Len(aMDFeEnc) > 0
		//-- Alterar o conteudo da variavel cFilAnt		
			aAreaSM0  := SM0->( GetArea() )											
			cFilAnt   := Posicione('SM0',1,cEmpAnt+aMDFeEnc[Len(aMDFeEnc),1],'FWCODFIL()')														
			lContinua := TmsMDFeAut(aMDFeEnc, 2) //--Transmite o Encerramento do MDF-e   
			If lContinua
				TmsLimpDUD(cFilOri, cViagem, aMDFeEnc)	//--Limpar a DUD
			EndIf 								         
			cFilAnt := Posicione('SM0',1,cEmpAnt+cFilBack,'FWCODFIL()') 
			RestArea(aAreaSM0)
	EndIf 
	
	If !lMDFeAut .Or. nLoop > 1
		// Exibe a mensagem de erro.
		If lRet .AND. lMstrErro
			AutoGrLog(STR0091 + CRLF) //"Não poderá ser realizado o estorno do carregamento, pois os seguintes manifestos possuem encerramento não transmitido:"
			AutoGrLog( cErro )
	    	MostraErro() 
		EndIf
	Else
		lRet := A210VEnMan(cFilOri,cViagem,aManifes,lMstrErro,++nLoop)
	EndIf

Return lRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A210InitVal
Inicializa valores 
@type function
@author Caio Murakami
@version 12
@param  
@since 11/03/2019
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function A210InitVal( aHeader , aCols , cFilOri , cViagem  )
Local nCount	:= 1 
Local cFilDoc	:= ""
Local cDoc		:= ""
Local cSerie	:= ""

Default aHeader		:= {}
Default aCols			:= {}
Default cFilOri		:= ""
Default cViagem		:= ""

For nCount := 1 To Len(aCols)

	If aCols[nCount][DTA->(GdFieldPos('DTA_ESTCAR'))] == "1" 

		cFilDoc	:= aCols[nCount][DTA->(GdFieldPos('DTA_FILDOC'))] 
		cDoc		:= aCols[nCount][DTA->(GdFieldPos('DTA_DOC'))]
		cSerie	:= aCols[nCount][DTA->(GdFieldPos('DTA_SERIE'))] 

		//-- Valida se existe cancelamento de manifesto não transmitido
		If !A210VldMCa(cFilOri , cViagem , cFilDoc , cDoc , cSerie )
			aCols[nCount][DTA->(GdFieldPos('DTA_ESTCAR'))]	:= "2" //-- Não
		EndIf

	EndIf

Next nCount

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A210VldMCa
Valida individualmente se existem manifestos com encerramento não transmitido
@type function
@author Caio Murakami
@version 12
@param  
@since 11/03/2019
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function A210VldMCa(cFilOri , cViagem ,  cFilDoc , cDoc , cSerie )
Local lRet				:= .T. 
Local aArea				:= GetArea()
Local cQuery			:= ""
Local cAliasQry		:= GetNextAlias()
Local cTitFilMan 	:= ""
Local cTitManife	:= ""
Local cTitSerMan	:= ""
Local cTitSTFMDF	:= ""

Default cFilOri		:= ""
Default cViagem		:= ""
Default cFilDoc		:= ""
Default cDoc			:= ""
Default cSerie	  := ""
Default cErro			:= ""

cQuery 	:= " 	SELECT DTX_FILMAN, "
cQuery 	+= "        DTX_MANIFE, " 
cQuery 	+= "        DTX_SERMAN, " 
cQuery 	+= "        DTX_VIAGEM, " 
cQuery 	+= "        DTX_STFMDF " 
cQuery 	+= " 	FROM " + RetSQLName("DUD") + " DUD "
cQuery	+= "	INNER JOIN " + RetSqlName("DYN") + " DYN " 
cQuery 	+= "		 	 	ON DYN_FILIAL = '" + xFilial("DYN") + "'"
cQuery 	+= "       			AND DYN_FILORI = '" + cFilOri + "' " 
cQuery 	+= "       			AND DYN_VIAGEM = '" + cViagem + "' " 
cQuery 	+= "       			AND DYN_STCMDF <> '2' "  //-- Cancelamento não Autorizado
cQuery 	+= "       			AND DYN_FILMAN = DUD_FILMAN " 
cQuery 	+= "			 			AND DYN_MANIFE = DUD_MANIFE "
cQuery 	+= "       			AND DYN.D_E_L_E_T_ = ' ' " 
cQuery 	+= " 	INNER JOIN "  + RetSQLName("DTX") +" DTX "
cQuery	+= " 			 ON DTX_FILIAL = '"+ FwxFilial("DTX") + "' " 
cQuery 	+= "       AND DTX_FILORI = '" + cFilOri + "' " 
cQuery 	+= "       AND DTX_VIAGEM = '" + cViagem + "' " 
cQuery 	+= "       AND DTX_STFMDF <> '2' "  //--Encerramento não Autorizado
cQuery 	+= "       AND DTX_STIMDF =  '2' "   //-- Envio Autorizado
cQuery 	+= "       AND DTX_FILMAN = DUD_FILMAN " 
cQuery	+= "			 AND DTX_MANIFE = DUD_MANIFE " 
cQuery 	+= "       AND DTX.D_E_L_E_T_ = ' ' " 
cQuery	+= " 	WHERE DUD_FILIAL 		= '" + xFilial("DUD") + "' "
cQuery	+= "			AND DUD_FILORI	= '" + cFilOri + "' "
cQuery	+= "			AND DUD_VIAGEM	= '" + cViagem + "' "
cQuery	+= "			AND DUD_FILDOC	= '" + cFilDoc + "' "
cQuery	+= "			AND DUD_DOC			= '" + cDoc 	 + "' "
cQuery	+= "			AND DUD_SERIE		= '" + cSerie	 + "' "
cQuery	+= "			AND DUD.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)

While (cAliasQry)->( !Eof() )
	
	//-- Busca os titulos dos campos 
	cTitFilMan  := FWX3Titulo('DTX_FILMAN')
	cTitManife  := FWX3Titulo('DTX_MANIFE')
	cTitSerMan  := FWX3Titulo('DTX_SERMAN')
	cTitSTFMDF  := FWX3Titulo('DTX_STFMDF') 

	lRet	:= .F. 

	cErro += cTitFilMan +  " : " + (cAliasQry)->DTX_FILMAN + " | "
	cErro += cTitManife +  " : " + (cAliasQry)->DTX_MANIFE + " | "
	cErro += cTitSerMan +  " : " + (cAliasQry)->DTX_SERMAN + " | "
	cErro += cTitSTFMDF +  " : " + (cAliasQry)->DTX_STFMDF + CRLF + CRLF

	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->( dbCloseArea() )

RestArea( aArea )
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A210EstCar
Verifica no estorno do carregamento, caso o documento fazer parte de um lote de rateio, todos os documentos do lote devem ser estornados juntos.
@type function
@author arume.alexandre
@version 12
@param cEstCar
@since 21/03/2019
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function A210EstCar(cEstCar)

Local lRet			:= .T.
Local aAreaDT6	:= {}
Local aAreaDTP	:= {}
Local cLotNfc		:= ""
Local cSeekDT6	:= ""
Local nBkp			:= 0
Local nPosDT6		:= 0
Local aPosDT6		:= {}
Local nI				:= 0

Default cEstCar	:= ""

If !Empty(cEstCar)
		aAreaDT6 := DT6->(GetArea())
		DT6->(dbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
		If DT6->(dbSeek(xFilial("DT6")+GDFieldGet('DTA_FILDOC',n)+GDFieldGet('DTA_DOC',n)+GDFieldGet('DTA_SERIE',n)))
				cLotNfc := DT6->DT6_LOTNFC
				If !Empty(cLotNfc)
						aAreaDTP := DTP->(GetArea())
						DTP->(dbSetOrder(1)) //DTP_FILIAL+DTP_LOTNFC
						If DTP->(dbSeek(xFilial("DTP")+cLotNfc))
								If DTP->DTP_RATEIO == "1" //1=Sim;2=Não
										DT6->(dbSetOrder(2)) //DT6_FILIAL+DT6_FILORI+DT6_LOTNFC+DT6_FILDOC+DT6_DOC+DT6_SERIE
										DT6->(dbSeek(cSeekDT6 := xFilial('DT6')+M->DTA_FILORI+cLotNfc))
										nBkp := n
										While DT6->(!Eof()) .AND. DT6->(DT6_FILIAL+DT6_FILORI+DT6_LOTNFC) == cSeekDT6
												nPosDT6 := aScan(aCols, {|x| x[4]+x[5]+x[6] == DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)})
												If nPosDT6 > 0 .AND. !(GdDeleted(nPosDT6))
														GDFieldPut('DTA_ESTCAR', cEstCar, nPosDT6)
														aAdd(aPosDT6, nPosDT6)
														n := nPosDT6
														If !TmsA210LOk()
																lRet := .F.
																Exit
														EndIf
												EndIf
												DT6->(dbSkip())
										EndDo
										n := nBkp
										// Se algum documento não puder estornar, retorna o status de todos.
										If !lRet
												cEstCar := Iif(cEstCar == "1", "2", "1")
												For nI := 1 To Len(aPosDT6)
														GDFieldPut('DTA_ESTCAR', cEstCar, aPosDT6[nI])
												Next
										EndIf
										aPosDT6 := {}
										aSize(aPosDT6, 0)
								EndIf
						EndIf
						RestArea(aAreaDTP)
				EndIf
		EndIf
		RestArea(aAreaDT6)
EndIf

Return lRet
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A210GerDTW
Realiza geração das operações (DTW)
@type function
@author Caio Murakami
@version 12
@param  
@since 11/03/2019
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------

Static Function A210GerDTW( cFilDoc , cDoc , cSerie , cFilOri , cViagem  , cCodCli , cLojCli , lRemet )
Local cQuery			:= ""
Local cAliasNew		:= ""
Local cAtivChg		:= SuperGetMv("MV_ATIVCHG",,"")
Local cAtvSaiCli	:= SuperGetMv('MV_ATVSAIC',,'')//-- Atividade de Saída do cliente
Local cAtvChgCli	:= SuperGetMv('MV_ATVCHGC',,'')//-- Atividade de Chegada em Cliente
Local cAtivOld  	:= ""
Local cServic			:= ''
Local cSequen			:= "0"
Local aSequen			:= {}
Local nSequen			:= 0
Local lTM210Car		:= ExistBlock("TM210CAR")
Local lGeraCar		:= .F. 
Local cHoraPre		:= ""
Local dDataPre		:= dDataBase
Local nA					:= 0 
Local nContr			:= 0
Local lUFAtiv   	:= DTW->(ColumnPos("DTW_UFATIV")) > 0
Local lRet				:= .T.
Local lcriaDLT		:= .F.
Local lIdDTW			:= DTW->(ColumnPos("DTW_IDDTW")) > 0 
Local cOpeDoc			:= ""
Local cIdDTW			:= ""
Local cOrigem			:= ""
Local cAliasDTW		:= ""
Local cQueryDTW		:= ""
Local aCabDTW			:= {}
Local aArea				:= GetArea()
Local lContinua		:= .F. 
Local aDocs		    := {}
Local nPStatus      := 0
Local nPCliExp      := 0
Local nPLojExp      := 0
Local nPCliRem      := 0
Local nPLojRem      := 0
Local nPCliDes      := 0
Local nPLojDes      := 0
Local nPFilDoc      := 0
Local nPDoc         := 0
Local nPSerie       := 0
Local lGeraDados	:= .F. 

Static _oDadosViag   

Default cFilDoc		:= ""
Default cDoc			:= ""
Default cSerie		:= ""
Default cFilOri		:= ""
Default cViagem		:= ""
Default cCodCli		:= ""
Default cLojCli		:= ""
Default lRemet		:= .F. 

DTW->(dbSetOrder(1))
If DTW->(MsSeek(xFilial('DTW')+ cFilOri + cViagem ))
	If(!Empty(DTW->DTW_SEQUEN))	
		While DTW->( DTW_VIAGEM == cViagem )
			If DTW->(DTW_STATUS == "1")
				DTW->(DbSkip(-1))
				cSequen := DTW->DTW_SEQUEN
				DTW->(DbSkip())
				Exit
			EndIf
			DTW->(DbSkip())
		EndDo
		DTW->(DbSkip())
	EndIf
EndIf

lContinua	:=	A210VldDTW( cFilOri , cViagem , cCodCli , cLojCli , lRemet )

If lContinua

	If _oDadosViag == Nil 
		lGeraDados	:= .T. 
	Else
		If RTrim(_oDadosViag:cFilOri) <> RTrim(cFilOri) .oR.  RTrim(_oDadosViag:cViagem) <> RTrim(cViagem) 
			lGeraDados	:= .T. 
			_oDadosViag:Destroy()
			_oDadosViag	:= Nil
		EndIf 
	EndIf 
	
	If lGeraDados 
		_oDadosViag	:= TMSBCADadosTMS():New(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,,.F.)
		_oDadosViag:AddCustomerTrip(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)			
		_oDadosViag:AddDocs(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)
	EndIf 

    aDocs 		:= _oDadosViag:GetDocs()

    cQuery := "SELECT DC5.DC5_SERVIC, DC5.DC5_TAREFA, DC6.DC6_ATIVID "
    cQuery += "FROM " + RetSqlName("DC5") + " DC5 "
    cQuery += "INNER JOIN " + RetSqlName("DC6") + " DC6 "
    cQuery += "ON DC5.DC5_FILIAL = '" + xFilial("DC5") + "' "
    cQuery += "AND DC6.DC6_FILIAL = '" + xFilial("DC6") + "' "
    cQuery += "AND DC5.DC5_TAREFA = DC6.DC6_TAREFA "
    cQuery += "AND DC5.D_E_L_E_T_ = ' ' "
    cQuery += "AND DC6.D_E_L_E_T_ = ' ' "
    cQuery += "WHERE DC5.DC5_SERVIC = '" + Iif(Empty(cSequen) .OR. cSequen == "0" .OR. DTQ->DTQ_STATUS == "1", cServEnt, DA8->DA8_SERVIC) + "' "

    If !Empty(cSequen) .AND. Len(cSequen) > 1
        cQuery += "AND DC6.DC6_ATIVID IN ('" + cAtvSaiCli + "', '" + cAtvChgCli + "') "
        DTW->(dbSetOrder(4))
        If DTW->(MsSeek(xFilial('DTW')+ cFilOri + cViagem + cAtivChg))
            nSequen := Val(DTW->DTW_SEQUEN)
            nSequen -= 10
            cSequen := StrZero(nSequen, Len(DTW->DTW_SEQUEN) )
        EndIf
    EndIf

    cQuery += "AND NOT EXISTS ("
    cQuery += 	"SELECT DTW.DTW_VIAGEM "
    cQuery += 	"FROM " + RetSqlName("DTW") + " DTW "
    cQuery += 	"WHERE DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
    cQuery += 	"AND DTW.DTW_FILORI = '" + cFilOri + "' "
    cQuery += 	"AND DTW.DTW_VIAGEM = '" + cViagem + "' "
    cQuery += 	"AND DTW.DTW_SERVIC = DC5.DC5_SERVIC "
    cQuery += 	"AND DTW.DTW_TAREFA = DC5.DC5_TAREFA "
    cQuery += 	"AND DTW.DTW_ATIVID = DC6.DC6_ATIVID "
    cQuery += 	"AND DTW.DTW_CODCLI = '" + cCodCli + "' "
    cQuery += 	"AND DTW.DTW_LOJCLI = '" + cLojCli + "' "
    cQuery += 	"AND DTW.DTW_STATUS = '1' "
    cQuery += 	"AND DTW.D_E_L_E_T_ = ' ')"

    cQuery := ChangeQuery(cQuery)

    cAliasNew := GetNextAlias()
    DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)

    // Caso já existam as operações do cliente e não estejam apontadas.
    If (cAliasNew)->(Eof()) .AND. lRemet .AND. DTQ->DTQ_STATUS == StrZero(2, Len(DTQ->DTQ_STATUS))
        (cAliasNew)->(dbCloseArea())
        // Não for uma solicitação de coleta.
        If cSerie <> "COL"
            cQuery := 	"SELECT DTW.R_E_C_N_O_ DTWRECNO "
            cQuery += 	"FROM " + RetSqlName("DTW") + " DTW "
            cQuery += 	"WHERE DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
            cQuery += 	"AND DTW.DTW_FILORI = '" + cFilOri + "' "
            cQuery += 	"AND DTW.DTW_VIAGEM = '" + cViagem + "' "
            cQuery += 	"AND DTW.DTW_CODCLI = '" + cCodCli + "' "
            cQuery += 	"AND DTW.DTW_LOJCLI = '" + cLojCli + "' "
            cQuery += 	"AND DTW.DTW_ATIVID = '" + cAtvChgCli + "' "
            cQuery += 	"AND DTW.DTW_STATUS = '1' "
            cQuery += 	"AND DTW.D_E_L_E_T_ = ' '"
            cAliasNew := GetNextAlias()
            DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)

            If (cAliasNew)->(!Eof())
                DTW->(dbGoto((cAliasNew)->DTWRECNO))
                RecLock("DTW", .F.)
                DTW->DTW_DATINI := dDataBase
                DTW->DTW_HORINI := StrTran(Left(Time(), 5), ":", "")
                DTW->DTW_DATREA := dDataBase
                DTW->DTW_HORREA := StrTran(Left(Time(), 5), ":", "")
                DTW->DTW_STATUS := StrZero(2, Len(DTW->DTW_STATUS))
                    
                If DTW->(ColumnPos("DTW_SYSDAT")) > 0 .AND. DTW->(ColumnPos("DTW_SYSHOR")) > 0
                    DTW->DTW_SYSDAT := dDataBase
                    DTW->DTW_SYSHOR := StrTran(Time(), ":", "")
                EndIf
                cIdDTW := DTW->DTW_IDDTW
                DTW->(MsUnlock())
            EndIf
            (cAliasNew)->(dbCloseArea())

            If TableInDic("DLT") .And. ExistFunc("Tmsa351DLT") .AND. Len(aDocs) > 0 .And. !Empty(cIdDTW)
                // Monta os dados para montar a DLT
                If IsInCallStack("TMSA141Grv") .Or. Left(FunName(),7) == "TMSA210" 
                    cOrigem	:= "2" //-- Viagem em Trânsito
                Else
                    cOrigem	:= "1" //-- Fechamento
                EndIf

                Aadd( aCabDTW, {'DTW_FILORI'	, cFilOri   , Nil})
                Aadd( aCabDTW, {'DTW_VIAGEM'	, cViagem   , Nil}) 
                Aadd( aCabDTW, {'DTW_IDDTW'	    , cIdDTW    , Nil}) 

                For nA := 1 To Len(aDocs)
                    nPStatus := aScan(aDocs[nA], {|x| x[1] == "DT6_STATUS"})
                    nPCliExp := aScan(aDocs[nA], {|x| x[1] == "DT6_CLIEXP"})
                    nPLojExp := aScan(aDocs[nA], {|x| x[1] == "DT6_LOJEXP"})
                    nPCliRem := aScan(aDocs[nA], {|x| x[1] == "DT6_CLIREM"})
                    nPLojRem := aScan(aDocs[nA], {|x| x[1] == "DT6_LOJREM"})
                    nPCliDes := aScan(aDocs[nA], {|x| x[1] == "DT6_CLIDES"})
                    nPLojDes := aScan(aDocs[nA], {|x| x[1] == "DT6_LOJDES"})
                    nPFilDoc := aScan(aDocs[nA], {|x| x[1] == "DT6_FILDOC"})
                    nPDoc    := aScan(aDocs[nA], {|x| x[1] == "DT6_DOC"})
                    nPSerie  := aScan(aDocs[nA], {|x| x[1] == "DT6_SERIE"})
                    If nPStatus > 0 .AND. nPCliExp > 0 .AND. nPLojExp > 0 .AND.; 
                        nPCliRem > 0 .AND. nPLojRem > 0 .AND.; 
                        nPCliDes > 0 .AND. nPLojDes > 0 .AND.; 
                        nPFilDoc > 0 .AND. nPDoc > 0 .AND. nPSerie > 0 .AND.; 
                        aDocs[nA][nPStatus][2] $ "1,6" .AND.; 
                        (cCodCli + cLojCli == aDocs[nA][nPCliRem][2] + aDocs[nA][nPLojRem][2] .OR.; 
                        cCodCli + cLojCli == aDocs[nA][nPCliDes][2] + aDocs[nA][nPLojDes][2] .OR.; 
                        cCodCli + cLojCli == aDocs[nA][nPCliExp][2] + aDocs[nA][nPLojExp][2]) //Documento em aberto
                        If aDocs[nA][nPSerie][2] == "COL"
                            cOpeDoc	:= "3" // Coleta
                        ElseIf cCodCli + cLojCli == aDocs[nA][nPCliRem][2] + aDocs[nA][nPLojRem][2] .OR. cCodCli + cLojCli == aDocs[nA][nPCliExp][2] + aDocs[nA][nPLojExp][2]
                            cOpeDoc	:= "2" // Emissão
                        Else
                            cOpeDoc	:= "1" // Entrega
                        EndIf 
                        
                        Tmsa351DLT(aCabDTW, 4, cFilOri , cViagem, cIdDTW, aDocs[nA][nPFilDoc][2], aDocs[nA][nPDoc][2], aDocs[nA][nPSerie][2], cOrigem, cOpeDoc)
                        
                    EndIf
                Next nAux
                aSize(aCabDTW,0)
                lcriaDLT := .F.
            EndIf
        EndIf
    Else
        While (cAliasNew)->(!Eof())

            //-- Como utilizamos o mesmo servico de carregamento para transporte e entrega, este ponto de entrada
            //-- permite ao cliente escolher em qual servico quer gerar a operacao de carregamento.
            If lTM210Car
                lGeraCar := ExecBlock("TM210CAR",.F.,.F.,{cServic})
                If	ValType(lGeraCar) <> "L"
                    lGeraCar := .T.
                EndIf
            EndIf

            //-- Nao gera operacoes de "Carregamento" nas "Viagens de Socorro"
            //-- pois o carregamento ja ocorreu na viagem original.
            If DTQ->DTQ_TIPVIA == "4" .And. (cServEnt == cServic .Or. !lGeraCar)
                (cAliasNew)->(dbSkip())
                Loop
            EndIf
            
            cHoraPre := Time()
            cAtivOld := ""
            
            // Viagem criada pelo painel, chama a rotina de carregamento duas vezes
            // Verifica se as operações desta Tarefa x Atividade já foram criadas
            IF IsInCallStack("TMSF76Via") .And. IsInCallStack("TMSF76Crg")
                DTW->(dbSetOrder(2))  // DTW_FILIAL + DTW_SERTMS + DTW_TIPTRA + DTW_FILORI + DTW_VIAGEM + DTW_SEQUEN
                If DTW->(MsSeek(xFilial('DTW') + cSerTms + cTipTra + cFilOri +  cViagem ))
                    (cAliasNew)->(dbSkip())
                    Loop
                EndIf
            Endif
                
            //-- Calcula a data e hora prevista
            SomaDiaHor( @dDataPre, @cHoraPre, TmsHrToInt(DC6->DC6_DURAC) )
            //-- Verificando se a sequencia obtida pode ser utilizada sem duplicidade.
            cSequen := Soma1(cSequen)
            DTW->(dbSetOrder(1))
            DTW->(MsSeek(xFilial('DTW')+cFilOri + cViagem +cSequen))
            If Empty(aSequen)
                If( cSequen == DTW->DTW_SEQUEN )					//-- Monta o array aSequen com sequencia inicial
                    While ( DTW->DTW_VIAGEM == M->DTA_VIAGEM )
                        Aadd( aSequen, { Soma1(DTW->DTW_SEQUEN)	, DTW->(RECNO()) } )
                        DTW->(DbSkip())
                    EndDo
                    nContr++
                EndIf
            Else
                For nA := 1 To Len(aSequen)								//-- Adciona no array aSequen a quantidade de ocorrências
                    aSequen[nContr][1] := Soma1(aSequen[nContr][1])	//-- que foram incluidas para que elas sejam incluidas 
                    DTW->(DbSkip())										//-- entre as ocorrências que já existiam.
                    nContr++
                Next nA
                nContr := 1
            EndIf

            If cAtivOld != (cAliasNew)->DC6_ATIVID	
                cAtivOld := (cAliasNew)->DC6_ATIVID	
                //-- Gravando DTW
                aCab := {}
                Aadd( aCab, { 'DTW_FILORI'	, cFilOri										, Nil } )
                Aadd( aCab, { 'DTW_VIAGEM'	, cViagem										, Nil } )
                Aadd( aCab, { 'DTW_SEQUEN'	, PADL(cSequen,TAMSX3("DTW_SEQUEN")[1],"0"), Nil } )
                Aadd( aCab, { 'DTW_DATPRE'	, dDataPre									, Nil } )
                Aadd( aCab, { 'DTW_HORPRE'	, StrTran(Left(cHoraPre,5),':','')			, Nil } )
                Aadd( aCab, { 'DTW_SERVIC'	, (cAliasNew)->DC5_SERVIC					, Nil } )
                Aadd( aCab, { 'DTW_TAREFA'	, (cAliasNew)->DC5_TAREFA					, Nil } )
                Aadd( aCab, { 'DTW_ATIVID'	, (cAliasNew)->DC6_ATIVID					, Nil } )
                Aadd( aCab, { 'DTW_SERTMS'	, cSerTms									, Nil } )
                Aadd( aCab, { 'DTW_TIPTRA'	, cTipTra									, Nil } )
                Aadd( aCab, { 'DTW_TIPOPE'	, StrZero(1,TAMSX3("DTW_STATUS")[1])		, Nil } ) // Tipo de Operacao == "Carregamento"
                
                If (cAliasNew)->DC6_ATIVID $ cAtvChgCli .And. lRemet .AND. cSerie <> "COL"

                    Aadd( aCab, { 'DTW_DATINI'	, dDataBase			, Nil } )
                    Aadd( aCab, { 'DTW_HORINI'	, StrTran(Left(Time(),5),':','')	, Nil } )
                    Aadd( aCab, { 'DTW_DATREA'	, dDataBase			, Nil } )
                    Aadd( aCab, { 'DTW_HORREA'	, StrTran(Left(Time(),5),':','')	, Nil } )
                    Aadd( aCab, { 'DTW_STATUS'	, StrZero(2,Len(DTW->DTW_STATUS))	, Nil } ) //-- 2 = Encerrada
                        
                    If DTW->(ColumnPos("DTW_SYSDAT")) > 0 .And. DTW->(ColumnPos("DTW_SYSHOR")) > 0
                        AAdd(aCab, {'DTW_SYSDAT', dDataBase})
                        AAdd(aCab, {'DTW_SYSHOR', StrTran(Time(), ":", "")})
                    EndIf

                Else
                    Aadd( aCab, { 'DTW_DATREA'	, Ctod('')							, Nil } )
                    Aadd( aCab, { 'DTW_HORREA'	, ''										, Nil } )
                    Aadd( aCab, { 'DTW_STATUS'	, StrZero(1,TAMSX3("DTW_STATUS")[1])		, Nil } )
                EndIf
                
                If lIdDTW .And. ExistFunc("Tm351IdDTW")
                    cIdDTW := Tm351IdDTW( cFilOri , cViagem 	)
                    Aadd( aCab, { 'DTW_IDDTW'	, cIdDTW																		, Nil } )
                EndIf

                If (cAliasNew)->DC6_ATIVID $ (cAtvSaiCli + "," + cAtvChgCli)
                    
                    Aadd( aCab, { 'DTW_CODCLI'	, cCodCli						, Nil } )
                    Aadd( aCab, { 'DTW_LOJCLI'	, cLojCli						, Nil } )

                    If lUFAtiv
                        DUY->( dbSetOrder(1) )
                        If DUY->(MsSeek(xFilial("DUY")+ Iif(lRemet,DT6->DT6_CDRORI,DT6->DT6_CDRCAL) ))   
                            Aadd( aCab, { 'DTW_UFATIV'	, DUY->DUY_EST						, Nil } )
                        EndIf
                    EndIf

                    If (cAliasNew)->DC6_ATIVID == cAtvChgCli .And. TableInDic("DLT")
                        lcriaDLT := .T.
                    EndIF 

                EndIf

                //--Cria a DTW
                lRet := TMSCriaDTW( aCab )

                If lRet .And. ExistFunc("Tmsa351DLT") .And. lcriaDLT .AND. Len(aDocs) > 0
                    // Monta os dados para montar a DLT
                    If IsInCallStack("TMSA141Grv") .Or. Left(FunName(),7) == "TMSA210" 
                        cOrigem	:= "2" //-- Viagem em Trânsito
                    Else
                        cOrigem	:= "1" //-- Fechamento
                    EndIf
                    
                    Aadd( aCabDTW, { 'DTW_FILORI'	, DTQ->DTQ_FILORI	, Nil } )
                    Aadd( aCabDTW, { 'DTW_VIAGEM'	, DTQ->DTQ_VIAGEM	, Nil } ) 
                    Aadd( aCabDTW, { 'DTW_IDDTW'	, cIdDTW					, Nil } ) 

                    For nA := 1 To Len(aDocs)
                        nPStatus := aScan(aDocs[nA], {|x| x[1] == "DT6_STATUS"})
                        nPCliExp := aScan(aDocs[nA], {|x| x[1] == "DT6_CLIEXP"})
                        nPLojExp := aScan(aDocs[nA], {|x| x[1] == "DT6_LOJEXP"})
                        nPCliRem := aScan(aDocs[nA], {|x| x[1] == "DT6_CLIREM"})
                        nPLojRem := aScan(aDocs[nA], {|x| x[1] == "DT6_LOJREM"})
                        nPCliDes := aScan(aDocs[nA], {|x| x[1] == "DT6_CLIDES"})
                        nPLojDes := aScan(aDocs[nA], {|x| x[1] == "DT6_LOJDES"})
                        nPFilDoc := aScan(aDocs[nA], {|x| x[1] == "DT6_FILDOC"})
                        nPDoc    := aScan(aDocs[nA], {|x| x[1] == "DT6_DOC"})
                        nPSerie  := aScan(aDocs[nA], {|x| x[1] == "DT6_SERIE"})
                        If nPStatus > 0 .AND. nPCliExp > 0 .AND. nPLojExp > 0 .AND.; 
                            nPCliRem > 0 .AND. nPLojRem > 0 .AND.; 
                            nPCliDes > 0 .AND. nPLojDes > 0 .AND.; 
                            nPFilDoc > 0 .AND. nPDoc > 0 .AND. nPSerie > 0 .AND.; 
                            aDocs[nA][nPStatus][2] $ "1,6" .AND.; 
                            (cCodCli + cLojCli == aDocs[nA][nPCliRem][2] + aDocs[nA][nPLojRem][2] .OR.; 
                            cCodCli + cLojCli == aDocs[nA][nPCliDes][2] + aDocs[nA][nPLojDes][2] .OR.; 
                            cCodCli + cLojCli == aDocs[nA][nPCliExp][2] + aDocs[nA][nPLojExp][2]) //Documento em aberto
                            If aDocs[nA][nPSerie][2] == "COL"
                                cOpeDoc	:= "3" // Coleta
                            ElseIf cCodCli + cLojCli == aDocs[nA][nPCliRem][2] + aDocs[nA][nPLojRem][2] .OR. cCodCli + cLojCli == aDocs[nA][nPCliExp][2] + aDocs[nA][nPLojExp][2]
                                cOpeDoc	:= "2" // Emissão
                            Else
                                cOpeDoc	:= "1" // Entrega
                            EndIf 
                            
                            Tmsa351DLT(aCabDTW, 4, cFilOri , cViagem, cIdDTW, aDocs[nA][nPFilDoc][2], aDocs[nA][nPDoc][2], aDocs[nA][nPSerie][2], cOrigem, cOpeDoc)
                            
                        EndIf
                    Next nAux
                    aSize(aCabDTW,0)
                    lcriaDLT := .F.
                EndIf 
            EndIf

            //-- Grava nas ocorrências exixtentes da DTW a nova sequencia.
            For nA := 1 To Len(aSequen)
                DbSelectArea ("DTW")
                DbGoTo(aSequen[nA][2])
                RecLock("DTW", .F.)
                DTW->DTW_SEQUEN := aSequen[nA][1]
                MsUnLock()
            Next nA
                
            (cAliasNew)->(dbSkip())
        EndDo

        (cAliasNew)->(dbCloseArea())

    EndIf

    oDadosViag := Nil
    FreeObj(oDadosViag)
    aSize(aDocs, 0)
	aDocs := Nil

EndIf

//--Verifica o ID da DTW do Cliente destinatário caso já exista e seja inclusão de novo documento na viagem em trânsito para gravar o ponto de entrega da DLT.
If TableInDic("DLT") .And. ExistFunc("Tmsa351DLT") .And. DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS))
	
	cAliasDTW := GetNextAlias()
	cQueryDTW := 	"SELECT DTW.DTW_IDDTW "
	cQueryDTW += 	"FROM " + RetSqlName("DTW") + " DTW "
	cQueryDTW += 	"WHERE DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
	cQueryDTW += 	"AND DTW.DTW_FILORI = '" + cFilOri + "' "
	cQueryDTW += 	"AND DTW.DTW_VIAGEM = '" + cViagem + "' "
	cQueryDTW += 	"AND DTW.DTW_ATIVID = '" + cAtvChgCli + "' "
	cQueryDTW += 	"AND DTW.DTW_CODCLI = '" + cCodCli + "' "
	cQueryDTW += 	"AND DTW.DTW_LOJCLI = '" + cLojCli + "' "
	cQueryDTW += 	"AND DTW.DTW_STATUS = '1' "
	cQueryDTW += 	"AND DTW.D_E_L_E_T_ = ' ' "
	cQueryDTW := ChangeQuery(cQueryDTW)
	cAliasDTW := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQueryDTW),cAliasDTW,.F.,.T.)

	DLT->(DbSetOrder(1))
	If !DLT->(MsSeek(xFilial("DLT") + cFilOri + cViagem+ (cAliasDTW)->DTW_IDDTW + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE )) 
		DTW->(DbSetOrder(9))
		If DTW->(MsSeek(xFilial("DTW") + cFilOri + cViagem + (cAliasDTW)->DTW_IDDTW )) 
			Aadd( aCabDTW, { 'DTW_FILORI'	, cFilOri		, Nil } )
			Aadd( aCabDTW, { 'DTW_VIAGEM'	, cViagem		, Nil } ) 
			Aadd( aCabDTW, { 'DTW_IDDTW'	, (cAliasDTW)->DTW_IDDTW	, Nil } ) 

			Tmsa351DLT(aCabDTW, 4, cFilOri, cViagem, (cAliasDTW)->DTW_IDDTW , DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE, "2", "1") // Entrega
			(cAliasDTW)->(dbSkip())	
			//--Limpa o Array
			aSize(aCabDTW,0)
		EndIf  
	EndIf 

	(cAliasDTW)->( dbCloseArea() )

EndIf 

					
RestArea(aArea)
Return
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A210VldDTW
Realiza validações para verificar se será permitido o apontamento
@type function
@author Caio Murakami
@version 12
@param  
@since 27/03/2019
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function A210VldDTW( cFilOri , cViagem , cCodCli , cLojCli , lRemet )
Local lRet				:= .T. 
Local aAreaDTW		:= DTW->(GetArea())
Local aArea				:= GetArea()
Local cAtvSaiCli	:= SuperGetMv('MV_ATVSAIC',,'')//-- Atividade de Saída do cliente
Local cAtvChgCli	:= SuperGetMv('MV_ATVCHGC',,'')//-- Atividade de Chegada em Cliente
Local cQuery			:= ""
Local cAliasQry		:= ""
Local nContChg		:= 0
Local nContSai		:= 0

Default cFilOri		:= ""
Default cViagem		:= ""
Default cCodCli		:= ""
Default cLojCli		:= ""
Default lRemet		:= .F. 

cAliasQry		:= GetNextAlias()

cQuery	:= " SELECT DTW_ATIVID , COUNT(*) CONTADOR "
cQuery	+= " FROM " + RetSQLName("DTW") + " DTW "
cQuery	+= " WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
cQuery	+= " 	AND DTW_FILORI	= '" + cFilOri + "' "
cQuery	+= " 	AND DTW_VIAGEM 	= '" + cViagem + "' "
cQuery	+= "	AND DTW_CODCLI	= '" + cCodCli + "' "
cQuery	+= "	AND DTW_LOJCLI  = '" + cLojCli + "' "
cQuery	+= " 	AND DTW_ATIVID	IN ('" + cAtvChgCli + "' , '" + cAtvSaiCli + "'  ) " 
cQuery	+= "	AND DTW_STATUS = '2' "
cQuery	+= "	AND DTW_DATREA <> '' "
cQuery 	+= " 	AND DTW.D_E_L_E_T_ = '' "
cQuery	+= " 	GROUP BY DTW_ATIVID "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

While (cAliasQry)->( !Eof() )
	
	If (cAliasQry)->DTW_ATIVID == cAtvChgCli
		nContChg += (cAliasQry)->CONTADOR  
	ElseIf (cAliasQry)->DTW_ATIVID == cAtvSaiCli
		nContSai +=  (cAliasQry)->CONTADOR  
	EndIf
	
	(cAliasQry)->( dbSkip() )
EndDo

(cAliasQry)->( dbCloseArea() )

If nContSai <> nContChg 
	lRet	:= .F. 
EndIf

RestArea(aAreaDTW)
RestArea(aArea)
Return lRet


/*{Protheus.doc} AltViagem
Quando MV_DOCVGE ativo gera planejamento para poder carregar
@type Function
@author Carlos Alberto Gomes Junior
@since 28/12/2021
*/
Static Function PlanViagem( cFilOri, cViagem, aDadosDTA )

    Local lRet       := .T.
    Local aAreas     := { DTA->(GetArea()), DM3->(GetArea()), GetArea() }
	Local aMaster    := {}
	Local aGrid      := {}
    Local aDadosDM3  := {}
	Local cSequen    := StrZero(0,Len(DM3->DM3_SEQUEN))
	Local cAliasDM3  := GetNextAlias()
	Local lVazio     := .T.
	Local nPosFilDoc := 0
	Local nPosDoc    := 0
	Local nPosSerie  := 0
	Local aMVParBkp  := {Nil,Nil}
	Local lCarAut   := .F.
	Local aDTATMPCar := {}
	Local nDTA

    Default cFilOri   := ""
    Default cViagem   := ""
	Default aDadosDTA := {}
	

	If Type("MV_PAR01") != "U"
		aMVParBkp[1] := MV_PAR01
	EndIf
	If Type("MV_PAR02") != "U"
		aMVParBkp[2] := MV_PAR02
	EndIf
	Pergunte("TMSAF60",.F.)
	lCarAut := ( MV_PAR01 != 1)

	If Len(aDadosDTA) >= 1
		nPosFilDoc := AScan( aDadosDTA[1], {|x| x[1] == "DTA_FILDOC" } )
		nPosDoc    := AScan( aDadosDTA[1], {|x| x[1] == "DTA_DOC"    } )
		nPosSerie  := AScan( aDadosDTA[1], {|x| x[1] == "DTA_SERIE"  } )
	EndIf

	If nPosFilDoc > 0 .And. nPosDoc > 0 .And. nPosSerie > 0

		BeginSql alias cAliasDM3
			SELECT
				MAX(DM3_SEQUEN) AS MAXSEQ
			FROM
				%table:DM3% DM3
			WHERE
				DM3.DM3_FILIAL= %xfilial:DM3% AND
				DM3.DM3_FILORI= %exp:cFilOri% AND
				DM3.DM3_VIAGEM= %exp:cViagem% AND
				DM3.%notDel% 
			GROUP BY DM3.DM3_FILIAL,DM3.DM3_FILORI,DM3.DM3_VIAGEM
			ORDER BY DM3.DM3_FILIAL,DM3.DM3_FILORI,DM3.DM3_VIAGEM
		EndSql

		If !(cAliasDM3)->( lVazio := Eof() )
			cSequen := (cAliasDM3)->MAXSEQ
		EndIf
		(cAliasDM3)->(DbCloseArea())
		cSequen := Soma1(cSequen)
		
		DM3->( DbSetOrder(1) )
		For nDTA := 1 To Len( aDadosDTA )
			If lVazio .Or. !DM3->( MSSeek(xFilial("DM3")+aDadosDTA[nDTA][nPosFilDoc][2]+aDadosDTA[nDTA][nPosDoc][2]+aDadosDTA[nDTA][nPosSerie][2] )  )
				Aadd( aDadosDM3, { } )
				Aadd( aDadosDM3[Len(aDadosDM3)],{"DM3_SEQUEN", cSequen , Nil })
				Aadd( aDadosDM3[Len(aDadosDM3)],{"DM3_FILDOC", aDadosDTA[nDTA][nPosFilDoc][2] , Nil })
				Aadd( aDadosDM3[Len(aDadosDM3)],{"DM3_DOC"   , aDadosDTA[nDTA][nPosDoc   ][2] , Nil })
				Aadd( aDadosDM3[Len(aDadosDM3)],{"DM3_SERIE" , aDadosDTA[nDTA][nPosSerie ][2] , Nil })
				cSequen := Soma1(cSequen)
			EndIf
		Next

		If !Empty(aDadosDM3)
			Aadd( aMaster, {} )
			Aadd( aMaster[Len(aMaster)] , { {"DTQ_FILIAL", xFilial("DTQ"), Nil }, {"DTQ_FILORI", cFilOri, Nil }, {"DTQ_VIAGEM", cViagem       , Nil } } )
			Aadd( aMaster[Len(aMaster)] , "MdFieldDTQ" )
			Aadd( aMaster[Len(aMaster)] , "DTQ" )
			Aadd( aGrid, {} )
			Aadd( aGrid[Len(aGrid)], aClone(aDadosDM3) )
			Aadd( aGrid[Len(aGrid)], "MdGridDM3" )
			Aadd( aGrid[Len(aGrid)], "DM3" )

			lRet := TMSExecAuto( "TMSAF60", aMaster, aGrid, 4, .T. )
		
			//Se carregamento automatico verifica retira do vetor documentos já carregados
			If lRet .And. lCarAut
				DTA->(DbSetOrder(1))
				aDTATMPCar := AClone(aDadosDTA)
				aDadosDTA := {}
				For nDTA := 1 To Len( aDTATMPCar )
					If !DTA->( MSSeek(xFilial("DTA")+aDTATMPCar[nDTA][nPosFilDoc][2]+aDTATMPCar[nDTA][nPosDoc][2]+aDTATMPCar[nDTA][nPosSerie][2] )  )
						AAdd(aDadosDTA, AClone( aDTATMPCar[nDTA] ) )
					EndIf
				Next
			EndIf

		EndIf

		AEval( aAreas, { |aArea| RestArea(aArea) })

	EndIf

	MV_PAR01 := aMVParBkp[1]
	MV_PAR02 := aMVParBkp[2]

Return lRet

