#include "Tmsa240.ch"
#include "PROTHEUS.CH"
#Include "XMLXFUN.CH"
#Include "FWMVCDEF.CH"
#Include "FWADAPTEREAI.CH"

Static lDelOk
Static nDelItem
Static lTM240BCO   := ExistBlock('TM240BCO'  )
Static lTM240TudOK := ExistBlock('TM240TUDOK')
Static lTMA240Adt  := ExistBlock('TMA240ADT' )
Static lTM240OPE   := ExistBlock('TM240OPE'  )	//-- Ponto de Entrada para alimentar automaticamente o codigo da Operadora
Static lTM240ADCPO := ExistBlock('TM240ADCPO')
Static lTM240ADTO  := ExistBlock('TM240ADTO' )
Static lTM240XML   := ExistBlock('TM240XML'  )
Static lTMS240VLD  := ExistBlock('TMS240VLD' )
Static lTM240MOTOK := ExistBlock('TM240MOTOK')
Static lTmsA2402   := ExistBlock( 'TMSA2402' )	//-- Adiciona campos no vetor aaltera / aalter da enchoice
Static lEAIFunOK  := (FindFunction("GETROTINTEG") .And. FindFunction("FwHasEAI") .And. Len(getSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0)
Static cTmsErp    := SuperGetMV("MV_TMSERP",,'0') //  // Parametro assume 0=Integração Nativa TMS Protheus; ou '1'- TMS X DATASUL
Static lViagem     := IsInCallStack("TMSA140") .Or. IsInCallStack("TMSA141") .Or. IsInCallStack("TMSA144") .Or. IsInCallStack("TMSA146") .Or. ;
					  IsInCallStack("TMSA146") .Or. IsInCallStack("TMSF76VIA")
Static lHerdaFrt  := .F.
Static aDoctosVge := {}
Static lViagem3   := FindFunction("TMSAF60") .And. AliasInDic("DM3")
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSA240  ³ Autor ³Patricia A. Salomao    ³ Data ³ 22.07.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Complemento de Viagem                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA240()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA240()

Private cCadastro := STR0001 //"Complemento de Viagem"
Private aRotina   := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6 ,1 ,22 ,75 ,"DTR")

Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA240Mnt  ³ Autor ³ Patricia A. Salomao ³ Data ³22.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao do Complemento de Viagem                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA240Mnt(ExpC1,ExpN1,ExpN2,ExpC2,ExpC3,ExpA1)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±³          ³ ExpC2 = Filial Origem da Viagem                            ³±±
±±³          ³ ExpC3 = Viagem                                             ³±±
±±³          ³ ExpA1 = Array contendo os Dados do Compl. de Viagem        ³±±
±±³          ³ ExpC4 = Rota da Viagem                                     ³±±
±±³          ³ ExpC5 = Servico de Transporte                              ³±±
±±³          ³ ExpC6 = Tipo de Transporte                                 ³±±
±±³          ³ ExpC7 = Observacao digitada na Viagem                      ³±±
±±³          ³ ExpA2 = Array com os Tipos de Veiculos                     ³±±
±±³          ³ ExpA3 = Array com os documentos marcados na Viagem         ³±±
±±³          ³ ExpL1 = Define se apresenta Telas                          ³±±
±±³          ³ ExpN3 = Tipo da Viagem                                     ³±±
±±³          ³ ExpL2 = Habilita edicao de GetDados                        ³±±
±±³          ³ ExpL3 = .T. Complemento de Viagem Vazio Prog. Carregamento ³±±
±±³          ³ ExpD1 = Data de Início da viagem                           ³±±
±±³          ³ ExpC8 = Hora de Início da viagem                           ³±±
±±³          ³ ExpL4 = Alteração da Rota			                      ³±±
±±³          ³ ExpC9 = Filial da Viagem Coligada                          ³±±
±±³          ³ ExpC10 = Numero da Viagem coligada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function TMSA240Mnt(cAlias,nReg,nOpcx,cFilOri,cViagem,aCompl,cRotaAtu,cSerTms,cTipTra,;
cObs,aTipVei,aDoctosMrk,lMostra,nTipVia,lEdita,aDoctos,aPosicao,lCalcFrt,lCompVazio, ;
dDatIni, cHorIni, lAltRota,cFilVge,cNumVge,lAltTipOpVg)

Local cNum         := ""
Local cCodUser     := ""
Local cCusMed      := GetMv("MV_CUSMED")
Local lContVei     := GetMv("MV_CONTVEI")
Local lMV_EmViag   := GetMv("MV_EMVIAG",,.F.)
Local nOpca        := 0
Local aAreaAnt     := GetArea()
Local aObjects     := {}
Local aPosObj      := {}
Local aInfo        := {}
Local aSize        := {}
Local aButtons     := {}
Local aAltera      := {}
Local aVisual  	   := {}
Local lParamViagem := .F.
Local aAreaDTR     := DTR->(GetArea())
Local aAreaDTA     := {}
Local nCntFor      := 0
Local aRotOld      := Iif( Type('aRotina') == 'A', aClone( aRotina ), {} )
//-- EnchoiceBar
Local oDlg, oEnchoice
Local aTelOld	   := Iif( Type('aTela') == 'A', aClone( aTela ), {} )
Local aGetOld	   := Iif( Type('aGets') == 'A', aClone( aGets ), {} )
//-- Dialog
Local cCadOld	   := Iif( Type('cCadastro') == 'C', cCadastro, '' )
//-- GetDados
Local aHeaOld	   := Iif( Type('aHeader') == 'A', aClone( aHeader ), {} )
Local aColOld	   := Iif( Type('aCols')   == 'A', aClone( aCols ), {} )
Local nOld   	   := Iif( Type('N')   == 'N', N, 1 )
//-- Pontos de entrada
Local lTmsA2401	   := ExistBlock( 'TMSA2401' )	//-- Adiciona campos no vetor avisual da enchoice
Local lTmsA2403	   := ExistBlock( 'TMSA2403' )	//-- Adiciona campos na getdados da pasta veiculo
Local lTmsA2404	   := ExistBlock( 'TMSA2404' )	//-- Retira campos na getdados da pasta veiculo
Local lGrava       := ValType(aCompl)!="A"
Local aComPlBkp    := {}
Local aAlter       := NIL
Local aNoFields    := {}
Local aYesFields   := {}
Local lValInf      := AliasInDic("DVW")
Local nCont        := 0
Local aSomaButtons := {}
//-- Operadoras de Frota/Vale-Pedagio
Local cTMSOPdg     := SuperGetMV( 'MV_TMSOPDG',, '0' )
Local cVsRepom     := SuperGetMV( 'MV_VSREPOM',, '1' ) 
Local bRetorno     := {||If(lGrava, nOpca, Iif(nOpcA == 0 .And. Empty(aComPlBkp),{},{ aHeader, aCols, aHeaderDUP, aMotViag, aHeaderDUQ, aAjuViag, aHeaderDVB, aLacrVei, aHeaderSDG, aAdtoViag,;
						 {M->DTR_FILVGE,M->DTR_NUMVGE,M->DTR_DATINI, M->DTR_HORINI, M->DTR_DATFIM, M->DTR_HORFIM,Iif(cTMSOPdg <> '0', M->DTR_CODOPE, ''),;
						  If(cTMSOPdg <> '0', M->DTR_PERADI, 0), M->DTR_TIPCRG ,If(cTMSOPdg <> '0' .And.lDTRTPSPDG, M->DTR_TPSPDG, 0),If(cTMSOPdg <> '0' .And.lDTRTPSPDG, M->DTR_QTDSAQ, 0),If(cTMSOPdg <> '0' .And.lDTRTPSPDG, M->DTR_QTDTRA, 0),M->DTR_PRCTRA,},;
						  aValInf, {} , {} , aHeaderDJA, aLibSeg,;
						  aHeaderDLD, aPagtoVge }) ) }
Local aVeiculos	   := {}
Local aCliDev	   := {}
Local nVei         := 0
Local lTipCrg      := DTR->(FieldPos("DTR_TIPCRG")) > 0
Local aAreaDUD     := {}
Local lTercRbq     := DTR->(ColumnPos("DTR_CODRB3")) > 0 
Local cMV_TMSRRE   := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
Local lTabRRE      := "3" $ cMV_TMSRRE
Local lTabDLD      := TableInDic('DLD')
Local lDTRTPSPDG   := DTR->(ColumnPos("DTR_TPSPDG")) > 0
Local lEfetOk      := .T.
Local lTransito		:= .F.
Local cFunction		:= 'TMSA240'

Local lRetorna := .F.

Private aHeader    := {}
Private aCols      := {}
Private n          := 1
Private aMotViag   := {}
Private aAjuViag   := {}
Private aLacrVei   := {}
Private aAdtoViag  := {}
Private aHeaderDVB := {}
Private aHeaderDUP := {}
Private aHeaderDUQ := {}
Private aHeaderSDG := {}
Private aHeaderDJA := {}
Private cNumLiber  := ""
Private aTela := {}
Private aGets := {}
Private oGet
Private aFilOri    := Array(5)
Private cRota      := cRotaAtu
Private cSerTMSVge := cSerTMS
Private cTipTraVge := cTipTra
Private aSetKey    := {}
//-- Identifica se as funcionalidades de Carga Fechada estao ativas.
Private lTmsCFec   := TmsCFec()
Private aValInf	   := {}
//-- Variavel para identificacao da necessidade de validacao do Id do Motorista
Private aVldId     := {}
Private lEixVolta  := .T. //Controla a Qtde de Eixos para a Repom se o Campo estiver no Ponto de Entrada TMS2404
Private lCalPedg   := .T. 
Private cNatuCarg  := '' //Natureza da carga informada na validacao do contrato (Operadora de Frota)
Private lTrocaMot  := .F.
Private aLibSeg    := {}
Private aHeaderDLD := {}
Private aPagtoVge  := {}

If IsInCallStack('TmsA144TRM') .Or. IsInCallStack('TmsA141TRM')
   lTrocaMot  := .T.
EndIf

If Type('aRetRbq') == 'U'
	Private aRetRbq := {}
EndIf


Default cAlias     := 'DTR'
Default nReg       := 1
Default nOpcx      := 2
Default cObs       := ""
Default aTipVei    := {}
Default aDoctosMrk := {}
Default lMostra    := .T.
Default lEdita     := .T.
Default aDoctos	   := {}
Default lCalcFrt   := .F.
Default lCompVazio := .F.
Default lAltRota   := .F.
Default cFilVge    := ""
Default cNumVge    := ""
Default lAltTipOpVg:= .F.

Iif(ExistFunc('FwPDLogUser'), FWPDLogUser(cFunction) , )

aFill( aFilOri,"")
aDoctosVge := aClone(aDoctos)

If cCusMed == 'O'
	
	Aadd(aSetKey, { VK_F12 , {|| Pergunte("TMA240",.T.), lF12 := .T. } } )
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)
EndIf

//-- Posiciona no complemento da viagem
If	Valtype(cFilOri) == 'C' .And. ValType(cViagem) == 'C'
	DTR->(DbSetOrder(1))
	DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))
	aAreaDTR     := DTR->(GetArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura variaveis da Enchoice                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("DTR", nOpcx == 3)

If cTMSOPdg <> '0' .And. cVsRepom $ '2|2.2'
	DT6->(DbSetOrder(1)) //-- Posiciona no Doc. de Viagem para obter os Devedores
	If !Empty(aDoctos)
		If IsInCallStack('TMSA144VIAG') .And. Len(aPosicao)>0 .And. aPosicao[2] > 0 //-- Viagem modelo 2
		   For nCont := 1 to Len(aDoctos)
		   	   If DT6->(DbSeek(xFilial("DT6")+aDoctos[nCont][aPosicao[2]]+aDoctos[nCont][aPosicao[3]]+aDoctos[nCont][aPosicao[4]]))  // fil.doc + doc + serie
		   	   		Aadd(aCliDev,{DT6->DT6_CLIDEV,DT6->DT6_LOJDEV})
		   	   		cNatuCarg := TmsTpCrg('', '', aDoctos[nCont][aPosicao[2]],aDoctos[nCont][aPosicao[3]],aDoctos[nCont][aPosicao[4]],.F.) //-- Valor da natureza para Lotacao
		   	   EndIF
		   Next    
		ElseIf Len(aPosicao)>0 .And. aPosicao[2] > 0
		   	For nCont := 1 to Len(aDoctos)
			   	If aDoctos[nCont][aPosicao[1]]      //-- Verifica se o doc esta marcado
			   	   If DT6->(DbSeek(xFilial("DT6")+aDoctos[nCont][aPosicao[2]]+aDoctos[nCont][aPosicao[3]]+aDoctos[nCont][aPosicao[4]]))  // fil.doc + doc + serie
			   	   		Aadd(aCliDev,{DT6->DT6_CLIDEV,DT6->DT6_LOJDEV})
			   	   		cNatuCarg := TmsTpCrg('', '', aDoctos[nCont][aPosicao[2]],aDoctos[nCont][aPosicao[3]],aDoctos[nCont][aPosicao[4]],.F.) //-- Valor da natureza para Lotacao
			   	   EndIf
			   	EndIf
		   Next  
		EndIf
	EndIf 
	
	If !Empty(aCliDev) 
		DUO->(DbSetOrder(1)) //-- Posiciona no Perfil do Cliente
		For nCont := 1 to Len(aCliDev)
			If DUO->(DbSeek(xFilial("DUO")+aCliDev[nCont][1]+aCliDev[nCont][2])) 
				If DUO->DUO_PGPEDG == '1' //-- Se algum cliente pagar pedagio
					lCalPedg := .F.      //-- ele nao sera pago pela Repom
				EndIF
			EndIF	
		Next
	EndIf  
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura do Array aCompl (Complemento de Viagem):              ³
//³ aCompl[1]  - aHeader Complemento de Viagem                      ³
//³ aCompl[2]  - aCols Complemento de Viagem                        ³
//³ aCompl[3]  - aHeader Auxiliar Getdados de Motoristas da Viagem  ³
//³ aCompl[4]  - Array contendo os Motoristas da Viagem             ³
//³ aCompl[5]  - aHeader Auxiliar Getdados de Ajudantes da Viagem   ³
//³ aCompl[6]  - Array contendo os Ajudantes da Viagem              ³
//³ aCompl[7]  - aHeader Auxiliar Getdados de Lacre de Veiculos     ³
//³ aCompl[8]  - Array contendo os Lacres do Veiculo                ³
//³ aCompl[9]  - aHeader Auxiliar Getdados de Adiantamentos         ³
//³ aCompl[10] - Array contendo os Adiantamentos da Viagem          ³
//³ aCompl[11] - Data / Hora Inicial e Final                        ³
//³ aCompl[12] - Array Contendo os componentes 'Valor Informado'    ³
//³ aCompl[13] - aHeader contendo os vinculos com o carreg.grafico .³
//³ aCompl[14] - Array Contendo os vinculos com o carregamento graf.³
//³ aCompl[15] - aHeader contendo os vinculos Liberacao Seguro RRE .³
//³ aCompl[16] - Array Contendo os vinculos Liberacao Seguro RRE   .³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If	Valtype(cFilOri) == 'C' .And. ValType(cViagem) == 'C'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tem que montar novamente o aRotina qdo. a funcao e' chamada por  ³
	//³ outro programa.                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aFilOri[1] := cFilOri
	aFilOri[2] := cViagem
	
	cCadastro := STR0001 //"Complemento de Viagem"
	aRotina	 := {	{ STR0002 ,'AxPesqui'  ,0,1},; //'Pesquisar'
	{ STR0003 ,'TMSA240Mnt',0,2},; //'Visualizar'
	{ STR0004 ,'TMSA240Mnt',0,3},; //'Incluir'
	{ STR0005 ,'TMSA240Mnt',0,4},; //'Alterar'
	{ STR0006 ,'TMSA240Mnt',0,5} } //'Excluir'
	
	lParamViagem	:= .T.
	M->DTR_FILORI 	:= cFilOri
	M->DTR_VIAGEM 	:= cViagem
	M->DTR_OBS    	:= cObs
	
	// Atualização de Campos da Viagem Coligada
	If !Empty(cFilVge) .AND.  !Empty(cNumVge)
		M->DTR_FILVGE := cFilVge
		M->DTR_NUMVGE	:= cNumVge
	
		If ValType(aCompl) == "A" .And. Len(aCompl)>0
			aCompViag[11, 1] := cFilVge
			aCompViag[11, 2] := cNumVge
		EndIf
	EndIf
	
	//-- Carrega os campos do planejamento e Operadoras de Frota,
	//-- caso os mesmos ja tenham sido informados uma vez.
	If ValType(aCompl) == "A" .And. Len(aCompl)>0
		M->DTR_FILVGE := aCompViag[11, 1]
		M->DTR_NUMVGE := aCompViag[11, 2]
		M->DTR_DATINI := aCompViag[11, 3]
		M->DTR_HORINI := aCompViag[11, 4]
		M->DTR_DATFIM := aCompViag[11, 5]
		M->DTR_HORFIM := aCompViag[11, 6]
		If lTipCrg
			Iif(Type('M->DTR_TIPCRG') != 'U', M->DTR_TIPCRG := aCompViag[11, 9],)
		EndIf
		M->DTR_TMPVGE := TmsTotHora(M->DTR_DATINI,M->DTR_HORINI,M->DTR_DATFIM,M->DTR_HORFIM, "@R 999:99")
		If cTMSOPdg <> '0'
			M->DTR_CODOPE := aCompViag[11, 7]
			TMSValField('M->DTR_CODOPE',.F.,'DTR_NOMOPE')
			If lDTRTPSPDG
				M->DTR_TPSPDG := aCompViag[11, 10]
				M->DTR_QTDSAQ := aCompViag[11, 11]
				M->DTR_QTDTRA := aCompViag[11, 12]
			EndIf
		EndIf

		M->DTR_PRCTRA := aCompViag[11, 13]
	Else
		If nOpcx == 3
			TMSA240TVge( 1, M->DTQ_SERTMS, M->DTQ_TIPTRA, cRotaAtu, aDoctosMrk, dDatIni, cHorIni )
		Else
			//-- Inicializa os campos do Planejamento
			DTQ->( dbSetOrder( 2 ) )
			If DTQ->( MsSeek( xFilial('DTQ') + M->DTR_FILORI + M->DTR_VIAGEM ) )
				M->DTR_DATINI := Iif( !Empty( DTQ->DTQ_DATINI ), DTQ->DTQ_DATINI, M->DTR_DATINI )
				M->DTR_HORINI := Iif( !Empty( DTQ->DTQ_HORINI ), DTQ->DTQ_HORINI, M->DTR_HORINI )
				M->DTR_DATFIM := Iif( !Empty( DTQ->DTQ_DATFIM ), DTQ->DTQ_DATFIM, M->DTR_DATFIM )
				M->DTR_HORFIM := Iif( !Empty( DTQ->DTQ_HORFIM ), DTQ->DTQ_HORFIM, M->DTR_HORFIM )
				M->DTR_TMPVGE := TmsTotHora(M->DTR_DATINI,M->DTR_HORINI,M->DTR_DATFIM,M->DTR_HORFIM, "@R 999:99")
			EndIf

			If DF8->(ColumnPos("DF8_DATINI"))
				If isInCallStack("TMSA153")
					M->DTR_DATINI := DF8->DF8_DATINI
					M->DTR_HORINI := DF8->DF8_HORINI
					M->DTR_DATFIM := DF8->DF8_DATFIM
					M->DTR_HORFIM := DF8->DF8_HORFIM 
					M->DTR_TMPVGE := TmsTotHora(M->DTR_DATINI,M->DTR_HORINI,M->DTR_DATFIM,M->DTR_HORFIM, "@R 999:99")
				Endif
			EndIf
		EndIf
	EndIf

	If lMostra .and. DTR->(FieldPos('DTR_TIPCRG')) > 0 
		If Empty(M->DTR_TIPCRG)
			M->DTR_TIPCRG := '2'
		EndIf
	EndIf

	If nOpcx == 2	//-- Visualizar
		DTR->( DbSetOrder( 1 ) )
		If  DTR->( ! MsSeek( xFilial('DTR') + cFilOri + cViagem, .F. ) )
			If lMostra
				Help( ' ', 1, 'TMSA24002', , STR0007 + cFilOri + ' ' + cViagem, 4, 1 ) //-- Complemento de viagem nao encontrado (DTR).	//'Viagem : '
			EndIf
			Return(Eval(bRetorno))
		EndIf
	ElseIf nOpcx == 3
		lTransito		:= M->DTQ_STATUS == StrZero( 2, Len(DTQ->DTQ_STATUS) )
		//-- Ponto de Entrada para alimentar automaticamente o codigo da Operadora
		If lTM240OPE
			cTM240OPE := ExecBlock('TM240OPE',.F.,.F.,{cFilOri, cViagem, cSerTMS})
			If !Empty(cTM240OPE) .And. ValType(cTM240OPE) == 'C'
				M->DTR_CODOPE := cTM240OPE
				If TMSValField('M->DTR_CODOPE',.T.)
					TMSValField('M->DTR_CODOPE',.F.,'DTR_NOMOPE')
				EndIf
			EndIf
		EndIf
	EndIf
Else
	DTQ->(DbSetOrder(2))
	If DTQ->(MsSeek(xFilial("DTQ")+M->DTR_FILORI+M->DTR_VIAGEM))
		M->DTR_OBS := MsMM(DTQ->DTQ_CODOBS,80)
	EndIf
EndIf

If	nOpcx == 4 .Or. nOpcx == 5	 //-- Alterar ou Excluir
	lTransito	:= DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS))
	If !lTrocaMot
	   If !TMSChkViag( M->DTR_FILORI, M->DTR_VIAGEM, .T., .F., .T., lMostra, , , lTransito, , , , .T. )  //-- Manutencoes serao permitidas somente em viagens em aberto ou chegada em filial
		   Return(Eval(bRetorno))
	   EndIf
	EndIf   
	
	If	DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) .And. M->DTR_FILORI <> cFilAnt
		If lMostra
			Help( ' ', 1, 'TMSA24029', , STR0022 + M->DTR_FILORI ,5 ,11) //-- Manutencao permitida somente na filial de origem  //'Filial Origem : '
		EndIf
		Return(Eval(bRetorno))
	EndIf
	
	If nOpcx == 4 
		//-- Posiciona para o caso de ter sido acionado atraves da viagem
		DTR->( DbSetOrder( 1 ) )
		If DTR->( MsSeek( xFilial( 'DTR' ) + M->DTR_FILORI + M->DTR_VIAGEM ) ) .And. ! Empty( DTR->DTR_FILVGE+DTR->DTR_NUMVGE )
			//-- Se for Viagem Interligada, permitir alterar somente os campos abaixo
			If lTercRbq
				aAlter := ({'DTR_VALFRE','DTR_VALPDG','DTR_VALRB1','DTR_VALRB2','DTR_VALRB3'})
			Else
				aAlter := ({'DTR_VALFRE','DTR_VALPDG','DTR_VALRB1','DTR_VALRB2'})
			EndIf

			If lTmsA2402
				aAlter := ExecBlock('TMSA2402',.F.,.F.,aAlter)
			EndIf

		EndIf
	EndIf
	
	//-- Somente permite alterar o complemento se nao existir Carregamento para a Viagem
	If !IsInCallStack('TmsA190Mnt')
		lRetorna := .F.
		aAreaDTA := DTA->(GetArea())
		aAreaDUD := DUD->(GetArea())
		DTA->( DbSetOrder ( 2 ) )
		DUD->( DbSetOrder ( 2 ) )
		DUD->(dBSeek(xFilial('DUD')+ DTR->DTR_FILORI + DTR->DTR_VIAGEM))
		If !lTrocaMot .And. DTA->( MsSeek ( xFilial("DTA") + M->DTR_FILORI + M->DTR_VIAGEM ) )
			If DUD->DUD_STATUS == StrZero(3, Len(DUD->DUD_STATUS)) .And. !Empty(DTR->DTR_ADIFRE).Or. !Empty(DTR->DTR_CODOPE) 
				If lMostra
					Help(" ",1,"TMSA24075") // Existe Carregamento para a Viagem,com Adiantamento ou Integração com Operadoras de Frota ,estorne o carregamento para permitir a alteração do Complemento de Viagem
				EndIf				
				lRetorna := .T.
			EndIf											
		EndIf		
		RestArea( aAreaDTA )
		RestArea( aAreaDUD )
		If lRetorna
			Return (Eval(bRetorno))
		EndIf
	EndIf

	If !DTR->(Eof()) .And. !SoftLock("DTR")
		Return (Eval(bRetorno))
	EndIf
EndIf

If Valtype(cSerTms) == 'C' .And. ValType(cTipTra) == 'C'
	aFilOri[3] := cSerTms
	aFilOri[4] := cTipTra
EndIf

//-- Verifica se foi informado o tipo de viagem
aFilOri[5] := 0
If Valtype(nTipVia) == 'N'
	aFilOri[5] := nTipVia
EndIf

Aadd(aSetKey, { VK_F4 , {|| IIf(!aCols[n, Len(aCols[n]) ], TMSA240Mot(nOpcx,,,,aDoctos,aPosicao), Help('',1,'TMSA24057')) } } )
Aadd(aSetKey, { VK_F5 , {|| TMSA240Ajud(nOpcx) } } )
Aadd(aSetKey, { VK_F6 , {||TA240Lacre(nOpcx,M->DTR_FILORI, M->DTR_VIAGEM, GDFieldGet("DTR_CODVEI",N)) } } )
Aadd(aSetKey, { VK_F7 , {||TA240Adto( nOpcx,M->DTR_FILORI, M->DTR_VIAGEM, GDFieldGet("DTR_CODVEI",n),,, GDFieldGet("DTR_CODFOR",n), GDFieldGet("DTR_LOJFOR",n)) } } )

AAdd(aButtons , {'USER',{|| IIf(!aCols[n, Len(aCols[n]) ], TMSA240Mot(nOpcx,,,,aDoctos,aPosicao), Help('',1,'TMSA24057')) }, STR0016 , STR0023 })      //"Motoristas da Viagem - <F4>" // Caso o veiculo esteja excluido, nao sera permitido acesso aos motoristas.
AAdd(aButtons , {'BMPUSER',{||TMSA240Ajud(nOpcx)}, STR0017 , STR0024 })  //"Ajudantes da Viagem - <F5>"
AAdd(aButtons , {'BMPINCLUIR',{||TA240Lacre(nOpcx,M->DTR_FILORI, M->DTR_VIAGEM, GDFieldGet("DTR_CODVEI",n))}, STR0018, STR0025 })//"Lacre de Veiculos - <F6>"
AAdd(aButtons , {'PRECO',{||TA240Adto(nOpcx,M->DTR_FILORI, M->DTR_VIAGEM, GDFieldGet("DTR_CODVEI",n),,, GDFieldGet("DTR_CODFOR",n), GDFieldGet("DTR_LOJFOR",n))}, STR0026 , STR0027 }) //"Adiantamentos - <F7>"

If lTmsCFec
	//-- Habilita botão para visualizar os tipos de veiculos Agendados.
	AAdd(aButtons , {'RPMNEW', {|| TMSA240TpVei( aTipVei, lParamViagem ) }, STR0028, STR0029 } ) //"Tipos de Veiculos Agendados"
EndIf

If	lValInf
	//-- Habilita botao do valor informado
	Aadd(aSetKey , { VK_F9    ,{|| TmsValInf(aValInf,'9',M->DTR_FILORI,,,,,,,,,,,nOpcx,M->DTR_VIAGEM) } } )
	AAdd(aButtons, {'COMPTITL',{|| TmsValInf(aValInf,'9',M->DTR_FILORI,,,,,,,,,,,nOpcx,M->DTR_VIAGEM) }, STR0030 , STR0031 }) //'Valor Informado - <F9>'
EndIf

If lContVei .And. TmsAcesso(,'TMSA430',@cCodUser,,.F.)
	Aadd(aSetKey , { VK_F10   ,{|| TMSA430('DTO') } } )
	AAdd(aButtons, {'BMPGROUP',{|| TMSA430('DTO') }, STR0032 , STR0033 }) //'Movto. Motoristas - <F10>'
	Aadd(aSetKey , { VK_F11   ,{|| TMSA430('DTU') } } )
	AAdd(aButtons, {'CARGASEQ',{|| TMSA430('DTU') }, STR0034 , STR0035}) //'Movto. Veiculos - <F11>'
EndIf

AAdd(aButtons, {'RELOAD',{|| TMSA240RetRbq(nOpcx,M->DTR_FILORI, M->DTR_VIAGEM) }, STR0061 , STR0062 }) //'Retorno de Reboque' ### 'Ret.Rbq.'

If lTabDLD .And. cTMSOPdg <> '0'
	Aadd(aSetKey , { VK_F2  ,{|| TA240PagV(nOpcx,M->DTR_FILORI, M->DTR_VIAGEM,GDFieldGet("DTR_ITEM",n),GDFieldGet("DTR_CODVEI",n),M->DTR_CODOPE,GDFieldGet("DTR_TPCIOT",n)) } } )
	AAdd(aButtons, {'RELOAD',{|| TA240PagV(nOpcx,M->DTR_FILORI, M->DTR_VIAGEM,GDFieldGet("DTR_ITEM",n),GDFieldGet("DTR_CODVEI",n),M->DTR_CODOPE,GDFieldGet("DTR_TPCIOT",n)) }, ,STR0094,STR0094  }) //'Formas de Pagto'
EndIf	

//-- Inicializa aValInf na alteracao do complemento da viagem
If lValInf .And. nOpcx <> 3
	TmsValInf(aValInf,'10',M->DTR_FILORI,,,,,,,,,,,nOpcx,M->DTR_VIAGEM)
EndIf

If lTabRRE
	Aadd(aButtons, {'RELOAD',{||TA240Segur(nOpcx,M->DTR_FILORI, M->DTR_VIAGEM, "DA3", Iif(!GDDeleted( n ),GDFieldGet("DTR_CODVEI",n),''),;
								Iif(!Empty(GDFieldGet("DTR_CODRB1",N)),GDFieldGet("DTR_CODRB1",n),''),;
								Iif(!Empty(GDFieldGet("DTR_CODRB2",N)),GDFieldGet("DTR_CODRB2",n),''),.T.	) }, STR0075,STR0075 } ) //Lib.Seguro
EndIf
//-- Iniciliza as Teclas de Atalhos
TmsKeyOn(aSetKey)

//-- Ponto de entrada para incluir botoes na enchoicebar
If	ExistBlock('TM240BUT')
	aSomaButtons:=ExecBlock('TM240BUT',.F.,.F.,{nOpcx})
	If	ValType(aSomaButtons) == 'A'
		For nCont:=1 To Len(aSomaButtons)
			AAdd(aButtons,aSomaButtons[nCont])
		Next
	EndIf
EndIf

//-- Adiciona campos no vetor avisual da enchoice.
AAdd( aVisual, 'DTR_FILORI' )
AAdd( aVisual, 'DTR_VIAGEM' )
AAdd( aVisual, 'DTR_FILVGE' )
AAdd( aVisual, 'DTR_NUMVGE' )
AAdd( aVisual, 'DTR_OBS'    )
AAdd( aVisual, 'DTR_DATINI' )
AAdd( aVisual, 'DTR_HORINI' )
AAdd( aVisual, 'DTR_DATFIM' )
AAdd( aVisual, 'DTR_HORFIM' )
AAdd( aVisual, 'DTR_TMPVGE' )

AAdd( aVisual, 'DTR_CODOPE' )
AAdd( aVisual, 'DTR_NOMOPE' )
AAdd( aVisual, 'DTR_PRCTRA' )
AAdd( aVisual, 'DTR_OPERPC' )

If lTipCrg
	AAdd( aVisual, 'DTR_TIPCRG' )  
EndIf

If lTabDLD
	AAdd( aVisual, 'DTR_TPSPDG' )  
	AAdd( aVisual, 'DTR_QTDSAQ' )  
	AAdd( aVisual, 'DTR_QTDTRA' )  
EndIf

If lTmsA2401
	aVisual := ExecBlock('TMSA2401',.F.,.F.,aVisual)
EndIf

If !lParamViagem // Se o complemento de Viagem NAO estiver sendo chamado pela rotina de Viagem
	//-- Campos que poderao ser Alterados na Enchoice
	aAltera := aClone( aVisual )
Else
	//-- Campos que poderao ser Alterados na Enchoice
	AAdd( aAltera, 'DTR_FILVGE' )
	AAdd( aAltera, 'DTR_NUMVGE' )
	AAdd( aAltera, 'DTR_DATINI' )
	AAdd( aAltera, 'DTR_HORINI' )
	AAdd( aAltera, 'DTR_DATFIM' )
	AAdd( aAltera, 'DTR_HORFIM' )
	AAdd( aAltera, 'DTR_CODOPE' )
	If lTipCrg
		AAdd( aAltera, 'DTR_TIPCRG' ) 
	EndIf

	If lTabDLD
		AAdd( aAltera, 'DTR_TPSPDG' ) 
		AAdd( aAltera, 'DTR_QTDSAQ' ) 
		AAdd( aAltera, 'DTR_QTDTRA' ) 
	EndIf
	AAdd( aAltera, 'DTR_PRCTRA' ) 
EndIf

If lTmsA2402
	aAltera := ExecBlock('TMSA2402',.F.,.F.,aAltera)
EndIf

If lTmsA2403
	aYesFields := ExecBlock('TMSA2403',.F.,.F.,aYesFields)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros utilizados pela funcao TMSFillGetDados()                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aNoFields  := {"DTR_FILORI","DTR_VIAGEM","DTR_FILVGE","DTR_NUMVGE","DTR_OBS","DTR_CODFOR","DTR_LOJFOR"} //Campos que Nao Deverao aparecer na Getdados

Aadd( aNoFields, "DTR_DATINI" )
Aadd( aNoFields, "DTR_HORINI" )
Aadd( aNoFields, "DTR_DATFIM" )
Aadd( aNoFields, "DTR_HORFIM" )
Aadd( aNoFields, "DTR_TMPVGE" )
AAdd( aNoFields, "DTR_CODOPE" )
AAdd( aNoFields, "DTR_NOMOPE" )
AAdd( aNoFields, "DTR_PRCTRA" )
AAdd( aNoFields, "DTR_OPERPC" )

If lTipCrg
	AAdd( aNoFields, "DTR_TIPCRG" )
EndIf

If lTabDLD
	AAdd( aNoFields, 'DTR_TPSPDG' )  
	AAdd( aNoFields, 'DTR_QTDSAQ' )  
	AAdd( aNoFields, 'DTR_QTDTRA' )  
EndIf

If lTmsA2404
	aNoFields := ExecBlock('TMSA2404',.F.,.F.,aNoFields)
	If Ascan(aNoFields,{|x|x == 'DTR_QTEIXV'}) <> 0
		lEixVolta := .F.
	EndIf
EndIf

If ValType(aCompl) == "A" .And. !Empty(aCompl)
	aHeader    := AClone(aCompl[1])  // aHeader
	aCols      := AClone(aCompl[2])  // aCols
	aHeaderDUP := AClone(aCompl[3])  // aHeader da GetDados Motorista da Viagem
	aMotViag   := AClone(aCompl[4])  // aCols da GetDados Motorista da Viagem
	aHeaderDUQ := AClone(aCompl[5])  // aHeader da GetDados Ajudantes da Viagem
	aAjuViag   := AClone(aCompl[6])  // aCols da GetDados Ajudantes da Viagem
	aHeaderDVB := AClone(aComPl[7])  // aHeader da GetDados Lacre de Veiculos
	aLacrVei   := AClone(aComPl[8])  // aCols da GetDados Lacre de Veiculos
	aHeaderSDG := AClone(aCompl[9])  // aHeader da GetDados de Adiantamentos
	aAdtoViag  := AClone(aCompl[10]) // aCols da GetDados de Adiantamentos
	aValInf    := AClone(aCompl[12]) // aCols da GetDados de Valor Informado
	aHeaderDJA := Iif( lTabRRE .And. Len(aCompl) >= 15, AClone(aCompl[15]),{})  // aHeader da GetDados da Liberacao do Seguro
	aLibSeg    := Iif( lTabRRE .And. Len(aCompl) >= 16, AClone(aCompl[16]),{})  // aCols da GetDados da Liberacao do Seguro
	aHeaderDLD := Iif( lTabDLD .And. Len(aCompl) >= 17, AClone(aCompl[17]),{})  // aHeader da GetDados do Pagamento da Viagem
	aPagtoVge  := Iif( lTabDLD .And. Len(aCompl) >= 18, AClone(aCompl[18]),{})  // aCols da GetDados do Pagamento da Viagem
	aComPlBkp  := AClone(aCompl)     // Salva os dados do complemento
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aHeader e aCols                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TMSFillGetDados( nOpcx, 'DTR', 1,xFilial( 'DTR' ) + M->DTR_FILORI + M->DTR_VIAGEM , {|| DTR->DTR_FILIAL + DTR->DTR_FILORI + DTR->DTR_VIAGEM}, ;
	{|| .T. }, aNoFields,	aYesFields )
EndIf

For nVei := 1 to Len(aCols)	
	aAdd( aVeiculos, {  GdFieldGet("DTR_CODVEI",nVei),;
						  GdFieldGet("DTR_QTDEIX",nVei),;
						  GdFieldGet("DTR_QTEIXV",nVei)})
	If nOpcx <> 2 .And. (lAltRota .Or. lAltTipOpVg)
		aCalFreCar(aVeiculos,/*lAtualiza*/,lCalPedg,nVei,lAltRota,nOpcx,lAltTipOpVg)
	EndIf
	aVeiculos := {}
Next nVei

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi informado Motoristas / Ajudantes por Viagem / Lacre de Veiculo / Adiantamentos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx <> 3
	aComplViag(M->DTR_FILORI, M->DTR_VIAGEM, lCompVazio)
	If lParamViagem
		If nOpcx == 4
			nCont := 0
			Aeval( aCols, { |X| If( Empty(AllTrim(x[GdFieldPos("DTR_CODVEI")])) .And. x[Len(aHeader)+1] == .F., nCont ++ , nCont ) } )
			If nCont > 0
				nOpcx := 3
			EndIf
		EndIf 
	EndIf
	If nOpcx == 4 .And. lCalcFrt
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Forca validacao do veiculo para realizar o calculo do frete a pagar, qdo terceiro             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TmsA240Vld("M->DTR_CODVEI")
	EndIf
EndIf

aSize := MsAdvSize()
AAdd( aObjects, { 100, 50, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T.} )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

aEval(aCols, {|x| IIF( Empty(x[GdFieldPos('DTR_ITEM')]), x[GdFieldPos('DTR_ITEM')]:= StrZero(1, Len(DTR->DTR_ITEM)), .T.) })

If lMostra
	
	//-- Ajuste do Ponteiro da tabela da GetDados para nao
	//-- preencher indevidamente campos virtuais na adicao de novas linhas,
	//-- quando a operacao for de alteracao de registro.
	DTR->(DbGoTo(0))
	DUP->(DbGoTo(0))
	DUQ->(DbGoTo(0))
	SDG->(DbGoTo(0))
	DVB->(DbGoTo(0))
	If lTabRRE
		DJA->(DbGoTo(0))
	EndIf

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a Enchoice                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Se a chamada da rotina originar do Contrato ou Transportes ou Entrega e alteracao, nao deixa incluir/modificar/excluir linha do aCols do Complemento
	oEnchoice:= MsMGet():New(cAlias, nReg, Iif(lEdita .AND. !lTransito .AND. !lTrocaMot, nOpcx, 2),,,,aVisual,aPosObj[1],aAltera,3,,,,,,.T. )

	oGet:=MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], Iif(lEdita .AND. !lTransito .AND. !lTrocaMot, nOpcx, 2), 'TMSA240LOk','AllWaysTrue','+DTR_ITEM', nOpcx<>2,aAlter,,,,,,,'TMSA240Del(1)')

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(Obrigatorio(aGets,aTela) .And. (lEfetOk:=TMSA240TOk(nOpcx,lCalPedg)),oDlg:End(),nOpca := 0)}, ;
	  {|| IIf(IsInCallStack('TMSA140Grv') .Or. IsInCallStack('TMSA141Grv'),IIf(MsgYesNo(OemToAnsi(Iif(lAltTipOpVg,STR0098,STR0063))),oDlg:End(),),oDlg:End()) },, aButtons )	
Else
	nOpca := 1
	//-- Quando é Complemento Vazio, é utilizado para inicializar os arrays, apresenta erro na TOK
	If nOpcx == 3 .And. lCompVazio .And. !lGrava 
		lEfetOk := .T.
	Else
		lEfetOk := TMSA240TOk(nOpcx,lCalPedg, .F.)
	EndIf
EndIf
If lEfetOk

	If nOpca == 1 .And. nOpcx <> 2
		cObs := M->DTR_OBS
		If (lGrava .OR. lAltRota .Or. lAltTipOpVg) .AND. lEfetOk
		
			Begin Transaction
				If TMSA240Grv(nOpcx,, M->DTR_FILORI, M->DTR_VIAGEM, M->DTR_FILVGE, M->DTR_NUMVGE, 1)
					If	lValInf
						TmsGrvInf(aValInf,'4',M->DTR_FILORI,,,,,,,,nOpcx,M->DTR_VIAGEM)
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se Alteracao, Verifica se existem viagens Interligadas 'a Viagem Original.³
					//³ Caso Exista, altera automaticamente todas as viagens Interligadas.        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nOpcx == 4
						DTR->(dbSetOrder(2)) // DTR_FILVGE + DTR_NUMVGE
						DTR->(MsSeek(xFilial('DTR')+M->DTR_FILORI+M->DTR_VIAGEM))
						Do While !DTR->(Eof()) .And. DTR->DTR_FILIAL+DTR->DTR_FILVGE+DTR->DTR_NUMVGE == xFilial('DTR')+M->DTR_FILORI+M->DTR_VIAGEM
							If cNum <> DTR->DTR_FILVGE+DTR->DTR_NUMVGE
								If !TMSA240Grv(nOpcx,, DTR->DTR_FILORI, DTR->DTR_VIAGEM, DTR->DTR_FILVGE , DTR->DTR_NUMVGE, 2, lAltRota)
									DisarmTransaction()
									Break
								EndIf
								cNum := DTR->DTR_FILVGE+DTR->DTR_NUMVGE
							EndIf
							DTR->(dbSkip())
						EndDo
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se rotina for chamada pelo cadastro de manifesto, nao permite manifestar  ³
						//³ a carga quando existir bloqueio de viagem.         						  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !TmsBlqViag( M->DTR_FILORI, M->DTR_VIAGEM)
							nOpca := 0
						EndIf
						
					ElseIf nOpcx == 3 .Or. nOpcx == 5
						TmsBlqViag( M->DTR_FILORI, M->DTR_VIAGEM)
					EndIf
				Else
					DisarmTransaction()
					Break
				EndIf
			End Transaction
		EndIf
	ElseIf nOpca == 0 //--Cancelamento
		//--Ao pressionar o botao cancelar com o controle de veiculos ativo, e necessario
		//--varrer o aCols para destravar os veiculos, motoristas e ajudantes caso tenha sido digitado
		If (lContVei .Or. lMV_EmViag)
			If Len(aCols) > 0 //-- Veiculos e Reboques
				For nCntFor := 1 To Len(aCols)
					UnLockByName("VGEVEI" + aCols[nCntFor][GdFieldPos('DTR_CODVEI')],.T.,.F.)
					UnLockByName("VGERB1" + aCols[nCntFor][GdFieldPos('DTR_CODRB1')],.T.,.F.)
					UnLockByName("VGERB2" + aCols[nCntFor][GdFieldPos('DTR_CODRB2')],.T.,.F.)
					If lTercRbq
						UnLockByName("VGERB3" + aCols[nCntFor][GdFieldPos('DTR_CODRB3')],.T.,.F.)
					EndIf	
				Next nCntFor
			EndIf
			
			If Len(aMotViag) > 0 //--Motoristas
				For nCntFor := 1 To Len(aMotViag)
					For nCont := 1 To Len(aMotViag[nCntFor][2])
						UnLockByName("VGEMOT" + aMotViag[nCntFor][2][nCont][Ascan(aHeaderDUP,{|x| x[2] == 'DUP_CODMOT'})],.T.,.F.)
					Next nCont
				Next nCntFor
			EndIf
		EndIf
		
		If Len(aAjuViag) > 0 //--Ajudantes
			For nCntFor := 1 To Len(aAjuViag)
				For nCont := 1 To Len(aAjuViag[nCntFor][2])
					UnLockByName("VGEAJU" + aAjuViag[nCntFor][2][nCont][Ascan(aHeaderDUQ,{|x| x[2] == 'DUQ_CODAJU'})],.T.,.F.)
				Next nCont
			Next nCntFor
		EndIf
	EndIf

	If  !Empty( aRotOld )
		aRotina := aClone( aRotOld )
	EndIf

	// Restaura os dados do complemento, caso a manutencao tenha sido cancelada( nOpca == 0 ).
	// Essa verificacao e' necessaria qdo. o complemento e' chamado por outra rotina(Ex. TMSA140(Geracao de Viagens).
	If !Empty(aComPlBkp) .And. nOpca == 0
		aHeader    := AClone(aComPlBkp[1])  // aHeader
		aCols      := AClone(aComPlBkp[2])  // aCols
		aHeaderDUP := AClone(aComPlBkp[3])  // aHeader da GetDados Motorista da Viagem
		aMotViag   := AClone(aComPlBkp[4])  // aCols da GetDados Motorista da Viagem
		aHeaderDUQ := AClone(aComPlBkp[5])  // aHeader da GetDados Ajudantes da Viagem
		aAjuViag   := AClone(aComPlBkp[6])  // aCols da GetDados Ajudantes da Viagem
		aHeaderDVB := AClone(aComPlBkp[7])  // aHeader da GetDados Ajudantes da Viagem
		aLacrVei   := AClone(aComPlBkp[8])  // aCols da GetDados Ajudantes da Viagem
		aHeaderSDG := AClone(aComplBkp[9])  // aHeader da GetDados de Adiantamentos
		aAdtoViag  := AClone(aComplBkp[10]) // aCols da GetDados de Adiantamentos
		aValInf    := AClone(aComplBkp[12]) // aCols da GetDados de Adiantamentos
		aHeaderDJA := Iif( Len(aComplBkp) >= 15 , AClone(aComplBkp[15]), {} ) // aHeader da GetDados da Liberação do Seguro
		aLibSeg    := Iif( Len(aComplBkp) >= 16 , AClone(aComplBkp[16]), {} ) // aCols da GetDados da Liberacao do Seguro
		aHeaderDLD := Iif( Len(aComplBkp) >= 17 , AClone(aComplBkp[17]), {} ) // aHeader da GetDados da Liberação do Seguro
		aPagtoVge  := Iif( Len(aComplBkp) >= 18 , AClone(aComplBkp[18]), {} ) // aCols da GetDados da Liberacao do Seguro
		aComPlBkp  := AClone(aCompl)     	 // Salva os dados do complemento
		DTR->(dbSetOrder(1)) // DTR_FILVGE + DTR_NUMVGE
		DTR->(MsSeek(xFilial('DTR')+cFilOri+cViagem))
		RegToMemory("DTR", .F.)
	EndIf
	
	If !Empty( cCadOld )
		cCadastro := cCadOld
	EndIf
	
	If !Empty( aTelOld )
		aTela	:= aClone( aTelOld )
		aGets	:= aClone( aGetOld )
	EndIf

	If	!Empty( aHeaOld )
		aHeader	:= aClone( aHeaOld )
		aCols	:= aClone( aColOld )
		n		:= nOld
	EndIf

	RestArea( aAreaDTR )
	RestArea( aAreaAnt )

	//-- Finaliza as Teclas de Atalhos
	TmsKeyOff(aSetKey) 
EndIf

If lEfetOk
	aRet := Eval(bRetorno)
Else
	aRet := {}
EndIf

Return(aRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA240Vld³ Autor ³ Patricia A. Salomao  ³ Data ³22.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes do sistema                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA240Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA240Vld(cCampo)

Local nCntFor, x
Local cVeiGen    := GetMV('MV_VEIGEN')
Local aAreaAnt	 := GetArea()
Local aAreaDA3	 := DA3->( GetArea() )
Local aAreaDA4	 := DA4->( GetArea() )
Local aAreaDTQ   := DTQ->( GetArea() )
Local aAreaDUD   := {}
Local aAreaDTR   := DTR->( GetArea() )
Local cAjuda     := ""
Local cCodMot    := ""
Local aVeiculos  := {}
Local nVeiReb    := 0
Local nPosMot    := 0
Local nAux       := 0
Local aAlter     := NIL
Local nPosRb1    := Ascan(aHeader, {|x|  x[2] == "DTR_CODRB1" })
Local nPosRb2    := Ascan(aHeader, {|x|  x[2] == "DTR_CODRB2" })
Local lTercRbq   := DTR->(ColumnPos("DTR_CODRB3")) > 0
Local nPosRb3    := IIf(lTercRbq,Ascan(aHeader, {|x|  x[2] == "DTR_CODRB3" }),0)
Local lSinc      := TmsSinc() //-- Chamada do Sincronizador
Local lContVei   := GetMV('MV_CONTVEI',,.T.) // Parametro para verificar se o sistema devera' controlar veiculo/motorista
Local dDatFim    := Ctod("")
Local cHorFim    := ""
Local nValor     := 0
Local nPosValBai := 0
Local nY         := 0
Local nX         := 0
Local nZ         := 0
Local aAreaDT3   := {}
Local lLoadDrv   := !lContVei
Local lGerAdf    := GetMV("MV_GERADF",,.F.) // Gera Titulo de Adiantamento de Frete com valor superior ao Valor do Frete+Pedagio
Local lMV_EmViag := GetMV("MV_EMVIAG",,.F.) // Utilizado para verificar se o veiculo esta em uso em outra viagem.
Local nQtdEix    := 0
Local nQtdEixV   := 0
Local lRet       := .T.
Local lRepom     := SuperGetMV('MV_TMSOPDG',,'0') == '2' //-- Integracao com Operadoras de Frota
Local lPlanejada := .F.
Local lRetPE     := .T.
Local aColsDUP	 := {}	//-- ACols contendo os motoristas da viagem.
Local nDUP		 := 0
Local nMot		 := 0
Local nCount	 := 0
Local cCodForn  := ''
Local cLojaForn := ''
Local cReboque  := ''
Local cChaveDJA := ""
Local cMV_TMSRRE := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
Local lTabRRE   := "3" $ cMV_TMSRRE   //2-Viagem;3-Todos
Local lTMS3GFE  := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local cCdTpVeic	:= "" // Código do tipo do veículo a ser alterado (DUT_TIPVEI)
Local cCatVei	:= "" // Categoria do veículo a ser alterado (DUT_TIPVEI) 
Local aYesCampo := {}
Local aHerCampo := {} 
Local aAreaDTR2 := {}
Local lRetCmp   := .F.
Local lTabDLD   := TableInDic('DLD')
Local cCondut	:= ''
Local cCNPJPg	:= ""
Local cCNPJFil	:= ""
Local aFilSM0	:= {}
//--Validações Frete Mínimo
Local nKmDista	:= 0
Local cCargaTipo:= ""
Local aCEPeDist	:= {}
Local lVgeMod3  := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)

Default cCampo	:= ReadVar()

If !lVgeMod3
	DTQ->(DbSetOrder(2))
	
	If lContVei
		//-- Quando a Viagem for planejada, trata como se o controle de veiculos estivesse desligado.
		TMSA240Off( @lContVei, @lPlanejada )
	Else                                                                                            
		//-- Se o controle de veiculos estiver desligado, verifica apenas se a Viagem é planejada.
		TMSA240Off( lContVei, @lPlanejada )
	EndIf
	
	If cCampo $ 'M->DTR_FILORI|M->DTR_VIAGEM'
		If	lRet .And. M->DTR_FILORI <> cFilAnt
			Help( ' ', 1, 'TMSA24029', , STR0022 + M->DTR_FILORI ,5 ,11) //-- Manutencao permitida somente na filial de origem  //'Filial Origem : '
			lRet := .F.
		EndIf
		
		If lRet .And. !ExistChav("DTR",M->DTR_FILORI+M->DTR_VIAGEM) .Or. !ExistCpo("DTQ",M->DTR_FILORI+AllTrim(M->DTR_VIAGEM),2)
			lRet := .F.
		EndIf
		
		If lRet
			DTQ->( MsSeek(xFilial("DTQ")+M->DTR_FILORI+AllTrim(M->DTR_VIAGEM)) )
			If (DTQ->DTQ_VIAGEM == M->DTR_VIAGEM) .And. (DTQ->DTQ_STATUS > "2")  // Status != 1 - Em Aberto / 2 - Em Transito.
				Help(' ', 1, 'TMSA24003')  //-- Viagem nao esta Em Aberto e nem Em Transito!
				lRet := .F.
			Else
				M->DTR_OBS := MsMM(DTQ->DTQ_CODOBS,80)
				TMSA240TVge( 2, DTQ->DTQ_SERTMS, DTQ->DTQ_TIPTRA, DTQ->DTQ_ROTA )
			EndIf
		EndIf
	
		//-- Ponto de Entrada para preenchimento automatico da Operadora de Frotas
		If INCLUI
		    If lTM240OPE
				cTM240OPE := ExecBlock('TM240OPE',.F.,.F.,{DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, DTQ->DTQ_SERTMS})
	            If !Empty(cTM240OPE) .And. ValType(cTM240OPE) == 'C'
		           M->DTR_CODOPE := cTM240OPE
					If TMSValField('M->DTR_CODOPE',.T.)
	    	        	TMSValField('M->DTR_CODOPE',.F.,'DTR_NOMOPE')
	    	        EndIf
	 			EndIf
	 		EndIf
		EndIf
		
	ElseIf cCampo $ 'M->DTR_FILVGE|M->DTR_NUMVGE'
		If cCampo == "M->DTR_NUMVGE" .And. Empty(M->DTR_FILVGE)
			Help('',1,'REGNOIS')
			lRet := .F.
		EndIf
		If lRet .And. !ExistCpo("DTQ",M->DTR_FILVGE+AllTrim(M->DTR_NUMVGE),2)
			lRet := .F.
		EndIf
		If lRet .And. M->DTR_FILVGE+M->DTR_NUMVGE == M->DTR_FILORI+M->DTR_VIAGEM
			Help("",1,"TMSA24013") // A Viagem Original Nao Podera ser igual a Viagem ...
			lRet := .F.
		EndIf

		If lRet .And. FindFunction("ColEntAtiv")
			lRet := !ColEntAtiv(M->DTR_FILVGE,M->DTR_NUMVGE,"1")
		EndIf
				
		If lRet
			DTR->(dbSetOrder(1))
			If !DTR->(MsSeek(xFilial("DTR")+M->DTR_FILVGE+AllTrim(M->DTR_NUMVGE)))
				Help("",1,"TMSA24016") // Nao existe Complemento de Viagem para esta Viagem ...
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			DTQ->( MsSeek(xFilial("DTQ")+M->DTR_FILVGE+AllTrim(M->DTR_NUMVGE)) )
			If (DTQ->DTQ_VIAGEM == M->DTR_NUMVGE) .And. (DTQ->DTQ_STATUS > "2")  // Status != 1 - Em Aberto / 2 - Em Transito.
				Help(' ', 1, 'TMSA24003')  //-- Viagem nao esta Em Aberto e nem Em Transito!
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
	      If TA240MNCOL(+M->DTR_FILVGE,AllTrim(M->DTR_NUMVGE)) .And. M->DTQ_SERTMS != StrZero(1, Len( DTQ->DTQ_SERTMS ) ) //Viagens de Coleta não precisam validar se a viagem original está manifestada.       
	         Help(' ', 1, 'TMSA24081')  //-- Nao e possivel informar uma viagem vinculada a um manifesto.
	         lRet := .F.
	      EndIF
		EndIF
		
		If lRet
			lHerdaFrt:= .F.
	
			DTR->(dbSetOrder(1))
			If DTR->(MsSeek(xFilial('DTR')+M->DTR_FILVGE+M->DTR_NUMVGE))
				If cCampo == "M->DTR_NUMVGE"
					lRetCmp:= A240CmpDTR(,,oGet:nOpc,@aYesCampo,@aHerCampo)
					If lRetCmp .And. DTR->DTR_VALFRE > 0
						If MsgYesNo( STR0087 ,STR0020)  //"Deseja replicar o Valor do Frete da Viagem Principal para a Viagem Coligada? " 
							lHerdaFrt:= .T.
						EndIf
					EndIf	
						
					//--Se for informada Viagem Original deverao ser gatilhados os veiculos, os motoristas e os ajudantes.
					aCols      := {}
					aMotViag   := {}
					aAjuViag   := {}
					Do While !DTR->(Eof()) .And. DTR->DTR_FILIAL+DTR->DTR_FILORI+DTR->DTR_VIAGEM == xFilial('DTR')+M->DTR_FILVGE+M->DTR_NUMVGE
						AAdd(aCols,Array(Len(aHeader)+1))
						For nCntFor := 1 To Len(aHeader)
							If	aHeader[nCntFor,10] != "V" .And. ( Ascan(aYesCampo, {|x| x == aHeader[nCntFor,2] }) >  0  .Or.  ( lHerdaFrt .And. Ascan(aHerCampo, {|x| x == aHeader[nCntFor,2] }) >  0 ) )
								aCols[Len(aCols),nCntFor]:= DTR->(FieldGet(FieldPos(aHeader[nCntFor,2])))
							Else
								aCols[Len(aCols),nCntFor]:= CriaVar(aHeader[nCntFor,2])
							EndIf
						Next nCntFor
						aCols[Len(aCols),Len(aHeader)+1]:=.F.
						DTR->(dbSkip())
					EndDo
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Executa os gatilhos                                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For x:=1 to Len(aCols)
						If ExistTrigger("DTR_CODVEI")
							RunTrigger(2,x,Nil,"DTR_CODVEI")
						Endif
						If ExistTrigger("DTR_CODRB1")
							RunTrigger(2,x,Nil,"DTR_CODRB1")
						Endif
						If ExistTrigger("DTR_CODRB2")
							RunTrigger(2,x,Nil,"DTR_CODRB2")
						Endif
						If lTercRbq
							If ExistTrigger("DTR_CODRB3")
								RunTrigger(2,x,Nil,"DTR_CODRB3")
							Endif
						EndIf
						If oGet:nOpc <> 2 .And. !lHerdaFrt 
							aAdd( aVeiculos, {  GdFieldGet("DTR_CODVEI",x),;
	                                         GdFieldGet("DTR_QTDEIX",x),;
	                                         GdFieldGet("DTR_QTEIXV",x)})
							
							aCalFreCar(aVeiculos,/*lAtualiza*/,lCalPedg,x,.F.,oGet:nOpc)
	
							aVeiculos := {}
						EndIf
					Next x
					
					//-- Altera o Valor da Inclui para que os campos Virtuais do Motorista/Ajudante
					//-- sejam preenchidos no acols (X3_RELACAO)
					Inclui:=IIf(oGet:nOpc == 3, .F., Inclui)
					aComplViag(M->DTR_FILVGE, M->DTR_NUMVGE)
					
					//-- Volta o Valor Anterior
					Inclui := IIf(oGet:nOpc == 3, .T., Inclui)
					If lTercRbq
						aAlter  := ({'DTR_VALFRE','DTR_VALPDG','DTR_VALRB1','DTR_VALRB2','DTR_VALRB3','DTR_CIOT'})
					Else
						aAlter  := ({'DTR_VALFRE','DTR_VALPDG','DTR_VALRB1','DTR_VALRB2','DTR_CIOT'})
					EndIf
					
					If lTmsA2402
						aAlter := ExecBlock('TMSA2402',.F.,.F.,aAlter)
					EndIf	
	
					oGet:oBrowse:bAdd    := {|| .F. } // Nao Permite a inclusao de Linhas
					oGet:oBrowse:bDelete := {|| .F. }	// Nao Permite a deletar Linhas
					oGet:oBrowse:AAlter  := aAlter     // Permite a alteracao de alguns campos
					oGet:oBrowse:Refresh(.T.)
				EndIf	
			EndIf
		EndIf
		
	ElseIf cCampo $ 'M->DTR_DATINI'
		If lRet .And. !( ValDatHor( M->DTR_DATINI, StrTran( Left( Time(), 5 ), ":", "" ), dDataBase, StrTran( Left( Time(), 5 ), ":", "" ),,,,.F. ) )
			lRet := .F.
		Else
			//-- Como a data e hora inicio podem ser alteradas, calcula a data e hora fim de acordo com o tempo da Viagem( DTR_TMPVGE ).
			dDatFim := M->DTR_DATINI
			cHorFim := Transform( M->DTR_HORINI, PesqPict( "DTR", "DTR_HORINI" ) )
			
			SomaDiaHor( @dDatFim, @cHorFim, TmsHrToInt( M->DTR_TMPVGE ) )
			
			M->DTR_DATFIM := dDatFim
			M->DTR_HORFIM := StrTran( cHorFim, ":", "" )
		EndIf
		
	ElseIf cCampo $ 'M->DTR_HORINI'
		If lRet .And. !( ValDatHor( M->DTR_DATINI, M->DTR_HORINI, dDataBase, StrTran( Left( Time(), 5 ), ":", "" ),,,,.F. ) )
			lRet := .F.
		Else
			//-- Como a data e hora inicio podem ser alteradas, calcula a data e hora fim de acordo com o tempo da Viagem( DTR_TMPVGE ).
			dDatFim := M->DTR_DATINI
			cHorFim := Transform( M->DTR_HORINI, PesqPict( "DTR", "DTR_HORINI" ) )
			
			SomaDiaHor( @dDatFim, @cHorFim, TmsHrToInt( M->DTR_TMPVGE ) )
			
			M->DTR_DATFIM := dDatFim
			M->DTR_HORFIM := StrTran( cHorFim, ":", "" )
		EndIf
		
	ElseIf cCampo $ 'M->DTR_DATFIM'
		If !( ValDatHor( M->DTR_DATFIM, StrTran( Left( Time(), 5 ), ":", "" ), M->DTR_DATINI, StrTran( Left( Time(), 5 ), ":", "" ),,,,.F. ) )
			lRet := .F.
		EndIf
		
	ElseIf cCampo $ 'M->DTR_HORFIM'
		If !( ValDatHor( M->DTR_DATFIM, M->DTR_HORFIM, M->DTR_DATINI, M->DTR_HORINI,,,,.F. ) )
			lRet := .F.
		EndIf
		
	ElseIf cCampo == 'M->DVW_CODPAS' //-- DVW - Digitacao valor informado x complemento
		If !Inclui .And. !Empty(GDFieldGet('DVW_CODPAS',n))
			Help(" ",1,"TMSAF0520") //-- Codigo do componente nao podera ser alterado.
			lRet := .F.
		Else
			aAreaDT3:=DT3->(GetArea())
			DT3->(DbSetOrder(1))
			If	DT3->(MsSeek(xFilial('DT3')+M->DVW_CODPAS))
				If	DT3->DT3_TIPFAI != StrZero(61,Len(DT3->DT3_TIPFAI))
					Help('',1,'TMSA04045')		//-- O campo 'Calcula Sobre' deste componente esta diferente de 'Valor Informado'
					RestArea( aAreaDT3 )
					lRet := .F.
				EndIf
			Else
				Help('',1,'REGNOIS')
				RestArea( aAreaDT3 )
				lRet := .F.
			EndIf
			RestArea( aAreaDT3 )
		EndIf
	ElseIf cCampo == 'M->DUQ_CODAJU' //Ajudante
		If !Empty(M->DUQ_CODAJU)
			If !LockByName("VGEAJU" + M->DUQ_CODAJU,.T.,.F.)
				Help( ' ', 1, 'TMSA24048', , STR0060 + M->DUQ_CODAJU ,3 ,0) //"O Ajudante esta sendo utilizado por outra viagem." ### "Ajudante: "
				lRet := .F.
			EndIf
			//--Sempre que for efetuado a troca de motorista preciso liberar o motorista anterior
			//que esta no aCols e bloquear o novo motorista que esta na variavel de memoria
			If lRet .And. M->DUQ_CODAJU <> GdFieldGet('DUQ_CODAJU',n)
				LockByName("VGEAJU" + M->DUQ_CODAJU,.T.,.F.)
				If !Empty(GdFieldGet('DUQ_CODAJU',n))
					UnLockByName("VGEAJU" + GdFieldGet('DUQ_CODAJU',n),.T.,.F.)
				EndIf
			EndIf
		EndIf
	ElseIf cCampo == "M->DTR_CODOPE" 
		If !Empty(aMotViag)
			For nMot := 1 To Len(aMotViag)
				If aMotViag[nMot][2][1][Len(aMotViag[nMot][2][1])] == .F.
					aColsDUP := AClone(aMotViag[nMot][2])
					For nDUP := 1 To Len(aColsDUP)
						If Empty(GDFieldGet('DUP_IDOPE',nDUP,,aHeaderDUP,aColsDUP))
							GDFieldPut('DUP_IDOPE',Posicione("DEL",2,xFilial("DEL")+GDFieldGet('DUP_CODMOT',nDUP,,aHeaderDUP,aColsDUP)+M->DTR_CODOPE,"DEL_IDOPE"),nDUP,aHeaderDUP,aColsDUP)
						EndIf					
					Next nDUP
					aMotViag[nMot][2] := aClone(aColsDUP) 
				EndIf
			Next nMot
		EndIf
		If lTMS3GFE 
			If !Empty(M->DTR_CODOPE) .And. M->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))  //Sim
				Help(" ",1,"TMSA24091")   //Pagamento da viagem via SIGAGFE. Não é permitido informar a Operadora de Frotas.  
				lRet:= .F.
			EndIf 
		EndIf
	ElseIf cCampo == "M->DLD_RECEB" 
		If !Empty(GdFieldGet("DLD_IDOPE", n))
			GdFieldPut("DLD_IDOPE", Space( Len( DLD->DLD_IDOPE ) ), n)
		EndIf
		If AllTrim(M->DLD_RECEB) == '2'
			nZ := aScan(aMotViag,{|x| x[1] == GDFieldGet('DLD_ITEDTR',n)}) 
			If nZ > 0							
				For nCount := 1 To Len(aMotViag[nZ][2])
					If !aMotViag[nZ][2][nCount][Len(aMotViag[nZ][2][nCount])] //-- Verifica se a linha esta deletada
						cCodMot := aMotViag[nZ][2][nCount][1]
						cCondut := aMotViag[nZ][2][nCount][Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_CONDUT" })]
						If cCondut == "1" //Condutor principal										
							If lRet	
								dbSelectArea("DA4")
								dbSetOrder(1)
								If MsSeek(xFilial("DA4")+cCodMot) .And. !Empty(DA4->DA4_FORNEC)
									dbSelectArea("DA3")
									DA3->(dbSetOrder(1)) 
									If MsSeek(xFilial("DA3")+GDFieldGet('DLD_CODVEI',n)) .And. !Empty(DA3->DA3_CODFOR)
										If Alltrim(DA4->DA4_FORNEC+DA4->DA4_LOJA) == Alltrim(DA3->DA3_CODFOR+DA3->DA3_LOJFOR)
											Help(' ', 1, 'TMSA240A2') //-- "O motorista só pode ser informado, quando o mesmo não for o proprietário do veículo"
											lRet := .F.
											Exit
										EndIf
									EndIf										
								EndIf	
							EndIf					
						EndIf
					EndIf
				Next nCount
			EndIf
		Endif
	ElseIf cCampo == "M->DLD_FORPAG" 
		If !Empty(GdFieldGet("DLD_IDOPE", n))
			GdFieldPut("DLD_IDOPE", Space( Len( DLD->DLD_IDOPE ) ), n)
		EndIf
	ElseIf cCampo == "M->DJA_DTFVSG"
	 	If M->DJA_DTFVSG < GDFieldGet("DJA_DTIVSG",n)
			Help(" ",1,"TMSA24079")   //Data de Validade do Seguro Invalida!
			lRet:= .F.
		EndIf
		
	ElseIf	!GDDeleted( n )
	
		If Empty( M->DTR_VIAGEM )
			Help( ' ', 1, 'TMSA24008')   // 'Viagem tem que estar preenchida!'
			lRet := .F.
		EndIf
		
		If lRet .And. !lSinc .And. !Empty(aFilOri[1]) .And. !Empty(aFilOri[2])
			DTQ->( MsSeek(xFilial("DTQ")+aFilOri[1] + aFilOri[2] ) )
		Else
			If DTQ->( MsSeek(xFilial("DTQ")+M->DTR_FILORI+AllTrim(M->DTR_VIAGEM)) )
				aFilOri[5] := Val(DTQ->DTQ_TIPVIA)
			EndIf
		EndIf
		
		If lRet .And. (cCampo == 'M->DTR_CODVEI')
	
			If !lPlanejada //Viagem Planejada
				lRet := TMSA240Blq(M->DTR_CODVEI)
			EndIf
	
			If M->DTR_CODVEI == GdFieldGet('DTR_CODRB1',n) .Or.  M->DTR_CODVEI == GdFieldGet('DTR_CODRB2',n)  .Or. IIf(lTercRbq,M->DTR_CODVEI == GdFieldGet('DTR_CODRB3',n),.F.)
				lRet := .F.
			EndIf
	
	          If lRet .And. (!Empty(M->DTR_CODRB1) .Or. !Empty(M->DTR_CODRB2) .Or. !Empty(M->DTR_CODRB3)) .And.  DA3->(MsSeek(xFilial("DA3") + M->DTR_CODVEI) )  .And.;
	               DUT->(MsSeek(xFilial("DUT") + DA3->DA3_TIPVEI)) .And. (DUT->DUT_CATVEI == StrZero(1, Len(DUT->DUT_CATVEI)) .Or. DUT->DUT_CATVEI == StrZero(5, Len(DUT->DUT_CATVEI)))
	               Help(' ', 1, 'TMSA240VEI', , STR0085, 3, 0) //-- Não é permitida a escolha de um Semi Reboque, quando o Cod.Veículo não for Cavalo Mecânico.
	                                         
	               lRet := .F.
	          EndIf
	          
			If lRet .And. lContVei
				If !Empty(aFilOri[3]) .And. !Empty(aFilOri[4])  .And. !Empty(cCodMot)
					If aFilOri[3] == StrZero( 2, Len( aFilOri[3] )) .And. aFilOri[4] == StrZero( 1, Len( aFilOri[4] ) )
						If !Ta240VrfRot(M->DTR_CODVEI)
							lRet := .F.
						EndIf
					EndIf
				Else
					If DTQ->DTQ_SERTMS == StrZero( 2, Len( DTQ->DTQ_SERTMS ) ) .And. DTQ->DTQ_TIPTRA == StrZero( 1, Len( DTQ->DTQ_TIPTRA ) ) .And. !Empty(cCodMot)
						If !Ta240VrfRot(M->DTR_CODVEI)
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
	
			//-- Nao pode selecionar o mesmo veiculo em mais
			//de uma viagem ao mesmo tempo
			If lRet .And. (lContVei .Or. lMV_EmViag)
				If !LockByName("VGEVEI" + M->DTR_CODVEI,.T.,.F.)
					Help( ' ', 1, 'TMSA24050', , STR0009 + M->DTR_CODVEI ,3 ,0) //"O Veiculo esta sendo utilizado por outra viagem." ### "Veiculo: "
					lRet := .F.
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a viagem for de Transferencia e existir motorista informado, verifica ³
			//³se o motorista atende alguma regiao da rota da Viagem                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				nPosMot := Ascan(aMotViag, {|x|  x[1] == GdFieldGet('DTR_ITEM',n)})
				If nPosMot > 0
					cCodMot := aMotViag[nPosMot][2][1][1]	//Verifica se foi informado pelo menos 1 motorista
				EndIf
				DA3->( DbSetOrder( 1 ) )
				If	DA3->( ! MsSeek( xFilial('DA3') + M->DTR_CODVEI, .F. ) )
					Help(' ', 1, 'TMSA24025',,STR0009 + M->DTR_CODVEI,5,11)	 //"Veiculo não cadastrado ..." ### "Veiculo : "
					lRet := .F.
				EndIf
				
				If	lRet .And. DA3->DA3_ATIVO != "1"
					Help(' ', 1, 'TMSA24001',,STR0009 + M->DTR_CODVEI,5,11)	//-- Este veiculo nao esta ativo (DA3)	//'Veiculo : ' //'Veiculo : '
					lRet := .F.
				EndIf
				
				If !Empty(DA3->DA3_CODFOR+DA3->DA3_LOJFOR).And. lRet
					SA2->(DbSetOrder(1))								
					If SA2->(MsSeek(xFilial("SA2")+DA3->DA3_CODFOR+DA3->DA3_LOJFOR))
						If SA2->A2_MSBLQL == "1"
							HELP(" ",1,"TMSA24088") //Proprietário do veículo esta bloqueado, Verificar o campo Bloqueado no Cadastro de Fornecedor
							lRet := .F.
						EndIf	
					EndIf				
				EndIf
				
			EndIf
			
			//-- Se for veiculo proprio zera os campos de Frete/Pedagio.
			If lRet .And. DA3->DA3_FROVEI == StrZero(1, Len(DA3->DA3_FROVEI))
				GdFieldPut("DTR_INSRET", 0, n)
				GdFieldPut("DTR_VALFRE", 0, n)
			EndIf
			
			If lRet
				DUT->(dbSetOrder(1))
				DUT->(MsSeek(xFilial('DUT')+DA3->DA3_TIPVEI))
				If DUT->(Eof())
					Help('',1,'TMSA24011') //-- Nao foi encontrado Categoria de Veiculo para este Tipo de Veiculo
					lRet := .F.
				Else
					cCdTpVeic 	:= DUT->DUT_TIPVEI
					cCatVei		:= DUT->DUT_CATVEI
					
				EndIf
			EndIf
			
			If lRet .And. lViagem .And. DUT->DUT_CATVEI == '3' .And. IiF(!Empty(cVeiGen),M->DTR_CODVEI <> cVeiGen,.T.)
				Help('',1,'TMSA24009') //-- Nao poderao ser Informados Veiculos com categoria igual a "3" (Carreta)
				lRet := .F.
			EndIf
			
			// Verifica se o Veiculo esta sendo utilizado em outra Viagem
			If lRet .And. ( lContVei .Or. lMV_EmViag ) .And. aFilOri[5] <> 3 .And. !TMSEmViag(M->DTR_FILORI,M->DTR_VIAGEM , M->DTR_CODVEI, 1)
				lRet := .F.
			EndIf
			
			//-- Verifica se o Veiculo esta Liberado
			DTU->( DbSetOrder(2) )
			If lRet .And. lContVei .And. (M->DTR_CODVEI <> cVeiGen .And. M->DTR_CODVEI <> DTU->DTU_CODVEI;
				.And. DTU->( ! MsSeek(xFilial("DTU")+M->DTR_CODVEI+"2") ))
				Help(' ', 1, 'TMSA24006',,STR0009 + M->DTR_CODVEI ,5,11)	//"Veiculo sem Entrada Liberada!" ### "Veiculo : "
				lRet := .F.
			EndIf
			
			//-- Se o codigo do veiculo for alterado
			If lRet .And. M->DTR_CODVEI <> GdFieldGet('DTR_CODVEI',n)
				//-- Verifica se o veiculo anterior tinha Lacre Informado
				nAux := aScan( aLacrVei,{|ExpA1| ExpA1[1] == GdFieldGet('DTR_CODVEI',n) } )
				If nAux > 0
					//"Existe um Lacre do Veiculo cadastrado, deseja realmente efetuar a alteracao do codigo? (os dados de Lacre do Veiculo serao perdidos)"
					If MsgYesNo( STR0021 ,STR0020)
						aDel(aLacrVei,nAux)
						aSize(aLacrVei,Len(aLacrVei)-1)
					Else
						lRet := .F.
					EndIf
				EndIf
				
				If lRet .And. lTabRRE
					cChaveDJA:= "DA3" + Padr(xFilial("DA3") + GdFieldGet('DTR_CODVEI',n), Len(DJA->DJA_CHAVE) ) 
					nAux := aScan( aLibSeg,{|ExpA1| ExpA1[1] == cChaveDJA } )
					If nAux > 0  
						//"Existe uma Liberacao de Seguro cadastrada, deseja realmente efetuar a alteracao do codigo? (os dados de Liberação serão perdidos)"
						If MsgYesNo( STR0076 ,STR0020	)
							aDel(aLibSeg,nAux)
							aSize(aLibSeg,Len(aLibSeg)-1)
				
							cChaveDJA:= "DA4" + Padr(xFilial("DA4") + cCodMot, Len(DJA->DJA_CHAVE)) 
							nAux := aScan( aLibSeg,{|ExpA1| ExpA1[1] == cChaveDJA } )
							If nAux > 0  
								aDel(aLibSeg,nAux)
								aSize(aLibSeg,Len(aLibSeg)-1)
							EndIf
				
						Else
							lRet:= .F.
						EndIf
					EndIf
				EndIf
				
				If lRet
					//-- Verifica se o veiculo anterior tinha Adiantamentos informados
					nAux := Ascan( aAdtoViag,{|ExpA1| ExpA1[1] == GdFieldGet('DTR_CODVEI',n) } )
					If nAux > 0
						If MsgYesNo( STR0040 + GdFieldGet('DTR_CODVEI',n) + STR0041 , STR0020 ) //"Os Adiantamentos feitos para o Veiculo " ### " serao perdidos ... Continua ?" ### "Atencao"
							//-- Marca como deletados adiantamentos do array aAdtoViag - Daniel Leme 21/Set/17
							aEval(aAdtoViag[nAux][2],{|x,y| x[Len(x)] := .T. }) 
							GdFieldPut('DTR_ADIFRE', 0, n)
						Else
							lRet := .F.
						EndIf
					EndIf
				EndIf
				If lRet .And. lTabDLD 
					//-- Verifica se o veiculo anterior tem Formas de Pagto de Viagem
					nAux := Ascan( aPagtoVge,{|ExpA1| ExpA1[2] == GdFieldGet('DTR_CODVEI',n) } )
					If nAux > 0
						If MsgYesNo( STR0095 ,STR0020) //"Existem Formas de Pagto informado para a viagem, deseja realmente efetuar a alteração do código? (Os dados da Formas de Pagto da Viagem serão perdidos)"
							aDel(aPagtoVge,nAux)
							aSize(aPagtoVge,Len(aPagtoVge)-1)
						Else
							lRet := .F.
						EndIf
					EndIf	
				EndIf
							
		EndIf
			
			If lRet .And. lContVei
				cNumLiber := DTU->DTU_NUMLIB
				//-- Quando selecionar um veiculo, gatilhar os Reboques com o mesmo numero de liberacao.
				DTU->( DbSetOrder(4) )
				DTU->(MsSeek(xFilial("DTU")+cNumLiber+"2"))
				Do While !DTU->(Eof()) .And. DTU->(DTU_FILIAL+DTU_NUMLIB+DTU_STATUS) == xFilial("DTU") + cNumLiber + "2"
					DA3->(MsSeek(xFilial("DA3")+DTU->DTU_CODVEI))
					If DUT->(MsSeek(xFilial('DUT')+DA3->DA3_TIPVEI)) .And. DUT->DUT_CATVEI == '3'
						If nVeiReb == 0
							GdFieldPut("DTR_CODRB1", DTU->DTU_CODVEI, n)
							If ExistTrigger("DTR_CODRB1")
								RunTrigger(2,n,Nil,"DTR_CODRB1")
							Endif
						ElseIf nVeiReb == 1 
							GdFieldPut("DTR_CODRB2", DTU->DTU_CODVEI, n)
							If ExistTrigger("DTR_CODRB2")
								RunTrigger(2,n,Nil,"DTR_CODRB2")
							Endif
						ElseIf nVeiReb == 2 .And. lTercRbq 
							GdFieldPut("DTR_CODRB3", DTU->DTU_CODVEI, n)
							If ExistTrigger("DTR_CODRB3")
								RunTrigger(2,n,Nil,"DTR_CODRB3")
							Endif
						EndIf
						nVeiReb++
					EndIf
					DTU->(dbSkip())
				EndDo
			EndIf
			
			//-- Quando selecionar um veiculo, gatilhar os motoristas com o mesmo numero de liberacao.
			If lRet .And. M->DTR_CODVEI <> GdFieldGet('DTR_CODVEI',n)
				
				If lTabRRE
					TA240Segur(oGet:nOpc,M->DTR_FILORI, M->DTR_VIAGEM, "DA3",M->DTR_CODVEI,'','', .F. )
				EndIf
							
				If TMSA240Mot(oGet:nOpc, cNumLiber, .F.,lLoadDrv,lTabRRE)
					nZ := aScan(aMotViag,{|x| x[1] == GDFieldGet('DTR_ITEM',n)}) // -- Verifica se foi informado o Motorista para o Item
					If nZ > 0
						For nX := 1 To Len(aMotViag[nZ][2])
							cCodMot := aMotViag[nZ][2][nX][1]
							If lTabRRE
								TA240Segur(oGet:nOpc,M->DTR_FILORI, M->DTR_VIAGEM, "DA4",cCodMot,'','', .F. )
							EndIf	
							If lContVei .Or. lMV_EmViag
								LockByName("VGEMOT" + cCodMot,.T.,.F.)
							EndIf
							dbSelectArea("DA4")
							dbSetOrder(1)
							MsSeek(xFilial("DA4")+cCodMot)
							//-- Se no cadastro do motorista (DA4) foi informado Ajudante(s), gatilhar os codigos
							//-- automaticamente no aCols de Ajudantes
							For nY := 1 to 3
								aArea := GetArea()
								cAjuda:= AllTrim(Str(nY))
								TMSA240Ajud(oGet:nOpc, DA4->(DA4_AJUDA&cAjuda), .F., (nY==1))
								RestArea( aArea )
							Next nY
						Next nX
					EndIf
					//--Verificar RNTRC Quando for integração com operadora de frota Pamcard.
					If lRet .And. M->DTR_CODOPE == '02' //--Pamcard 
						cCodForn  := Posicione("DA3",1,xFilial("DA3")+M->DTR_CODVEI,"DA3_CODFOR")
						cLojaForn := Posicione("DA3",1,xFilial("DA3")+M->DTR_CODVEI,"DA3_LOJFOR")
						
						SA2->(DbSetOrder(1))
					   	SA2->(!DbSeek(xFilial("SA2") + cCodForn + cLojaForn))
					
						lRet := PamFdRNTRC(cCodForn, cLojaForn)
						
						If !lRet
							Help("",1,"TMSA24065") //'RNTRC Inválido no Sistema Pamcard!!!'
						EndIf	
						
					EndIf				
				EndIf
	
				//--Sempre que for efetuado a troca de veiculo preciso liberar o veiculo anterior
				//que esta no aCols e bloquear o novo veiculo que esta na variavel de memoria
				If lMV_EmViag
					LockByName("VGEVEI" + M->DTR_CODVEI,.T.,.F.)
					If !Empty(GdFieldGet('DTR_CODVEI',n))
						UnLockByName("VGEVEI" + GdFieldGet('DTR_CODVEI',n),.T.,.F.)
					EndIf
				EndIf
			EndIf
			
			//-- Gatilha somando a quantidade de eixos
			If lRet //-- Qtde. de Eixos (IDA)
				GdFieldPut("DTR_QTDEIX", DA3->DA3_QTDEIX, n)
			EndIf
	
			If lRet .And. lEixVolta //-- Qtde. de Eixos (VOLTA)
				GdFieldPut("DTR_QTEIXV", DA3->DA3_QTDEIX, n)
			EndIf
	
			If lRet
				AAdd(aVeiculos, {	M->DTR_CODVEI, ;
									GdFieldGet("DTR_QTDEIX",n),;
									GdFieldGet("DTR_QTEIXV",n) })
			EndIf
			
			//--Sempre que for efetuado a troca do 1o.Reboque preciso liberar o Reboque anterior
			//que esta no aCols e bloquear o novo Reboque que esta na variavel de memoria
			If lRet .And. M->DTR_CODRB1 <> GdFieldGet('DTR_CODRB1',n)
				If lMV_EmViag .Or. lContVei
					LockByName("VGERB1" + M->DTR_CODRB1,.T.,.F.)
					If !Empty(GdFieldGet('DTR_CODRB1',n))
						UnLockByName("VGERB1" + GdFieldGet('DTR_CODRB1',n),.T.,.F.)
					EndIf
				EndIf
			EndIf
			
			If lRet .And. !Empty(GdFieldGet('DTR_CODRB1',n))
				// -- Soma a quantidade de eixos do codigo do veiculo com o codigo do reboque 1 (Ida)
				nQtdEix := Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB1',n),"DA3_QTDEIX")
				GdFieldPut("DTR_QTDEIX",Posicione("DA3",1,xFilial("DA3")+M->DTR_CODVEI,"DA3_QTDEIX")+nQtdEix,n)
				If Len(aVeiculos) > 0
					aVeiculos[1,2] := GdFieldGet("DTR_QTDEIX",n)
				EndIf
				// -- Soma a quantidade de eixos do codigo do veiculo com o codigo do reboque 1 (volta)
				If	lEixVolta 
					nQtdEixV := Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB1',n),"DA3_QTDEIX")
					GdFieldPut("DTR_QTEIXV",Posicione("DA3",1,xFilial("DA3")+M->DTR_CODVEI,"DA3_QTDEIX")+nQtdEix,n)
					If Len(aVeiculos) > 0
						aVeiculos[1,3] := GdFieldGet("DTR_QTEIXV",n)
					EndIf
				EndIf
				AAdd(aVeiculos, { GdFieldGet('DTR_CODRB1',n), 0, 0 })
			EndIf
			
			//--Sempre que for efetuado a troca do 2o.Reboque preciso liberar o Reboque anterior
			//que esta no aCols e bloquear o novo Reboque que esta na variavel de memoria
			If lRet .And. M->DTR_CODRB2 <> GdFieldGet('DTR_CODRB2',n)
				If lMV_EmViag .Or. lContVei
					LockByName("VGERB2" + M->DTR_CODRB2,.T.,.F.)
					If !Empty(GdFieldGet('DTR_CODRB2',n))
						UnLockByName("VGERB2" + GdFieldGet('DTR_CODRB2',n),.T.,.F.)
					EndIf
				EndIf
			EndIf
			
			If lRet .And. !Empty(GdFieldGet('DTR_CODRB2',n))
				// -- Soma as quantidades de eixos do codigo do veiculo,codigo do reboque 1 e codigo do reboque 2
				nQtdEix := Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB2',n),"DA3_QTDEIX")
				GdFieldPut("DTR_QTDEIX",Posicione("DA3",1,xFilial("DA3")+M->DTR_CODVEI,"DA3_QTDEIX")+;
				Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB1',n),"DA3_QTDEIX")+nQtdEix,n)
				If Len(aVeiculos) > 0
					aVeiculos[1,2] := GdFieldGet("DTR_QTDEIX",n)
				EndIf
				// -- Soma a quantidade de eixos do codigo do veiculo com o codigo do reboque 1 (volta)
				If lEixVolta
					nQtdEix := Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB2',n),"DA3_QTDEIX")
					GdFieldPut("DTR_QTEIXV",Posicione("DA3",1,xFilial("DA3")+M->DTR_CODVEI,"DA3_QTDEIX")+;
					Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB1',n),"DA3_QTDEIX")+nQtdEix,n)
					If Len(aVeiculos) > 0
						aVeiculos[1,3] := GdFieldGet("DTR_QTEIXV",n)
					EndIf
				EndIf
				AAdd(aVeiculos, { GdFieldGet('DTR_CODRB2',n), 0 ,0 })
			EndIf
			
			//--Sempre que for efetuado a troca do 3o.Reboque preciso liberar o Reboque anterior
			//que esta no aCols e bloquear o novo Reboque que esta na variavel de memoria
			If lTercRbq .And. lRet .And. M->DTR_CODRB3 <> GdFieldGet('DTR_CODRB3',n)
				If lContVei .Or. lMV_EmViag
					LockByName("VGERB3" + M->DTR_CODRB3,.T.,.F.)
					If !Empty(GdFieldGet('DTR_CODRB3',n))
						UnLockByName("VGERB3" + GdFieldGet('DTR_CODRB3',n),.T.,.F.)
					EndIf
				EndIf
			EndIf
			
			If lRet .And. lTercRbq .And. !Empty(GdFieldGet('DTR_CODRB3',n))
				// -- Soma as quantidades de eixos do codigo do veiculo,codigo do reboque 1, codigo do reboque 2 e codigo do reboque 3
				nQtdEix := Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB3',n),"DA3_QTDEIX")
				GdFieldPut("DTR_QTDEIX",Posicione("DA3",1,xFilial("DA3")+M->DTR_CODVEI,"DA3_QTDEIX")+;
				Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB1',n),"DA3_QTDEIX")+;
				Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB2',n),"DA3_QTDEIX")+nQtdEix,n)
				If Len(aVeiculos) > 0
					aVeiculos[1,2] := GdFieldGet("DTR_QTDEIX",n)
				EndIf
				// -- Soma a quantidade de eixos do codigo do veiculo com o codigo do reboque 1 e 2(volta)
				If lEixVolta 
					nQtdEix := Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB3',n),"DA3_QTDEIX")
					GdFieldPut("DTR_QTEIXV",Posicione("DA3",1,xFilial("DA3")+M->DTR_CODVEI,"DA3_QTDEIX")+;
					Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB1',n),"DA3_QTDEIX")+;
					Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB2',n),"DA3_QTDEIX")+nQtdEix,n)
					If Len(aVeiculos) > 0
						aVeiculos[1,3] := GdFieldGet("DTR_QTEIXV",n)
					EndIf
				EndIf
				AAdd(aVeiculos, { GdFieldGet('DTR_CODRB3',n), 0 ,0 })
			EndIf
			If lRet
				//-- Calcula Frete Carreteiro
				lRet := aCalFreCar(aVeiculos,,lCalPedg,n,,Iif(Type('oGet') == 'U',, oGet:nOpc) ) 
			EndIf
	
			aAreaDUD := DUD->(GetArea())		
			DUD->( DbSetOrder ( 2 ) )		
			DUD->(dBSeek(xFilial('DUD')+M->DTR_FILORI+M->DTR_VIAGEM))
			// Validações para troca de veículo quando o documento estiver carregado
			If !Empty(M->DTR_CODVEI) .And. DUD->DUD_STATUS == StrZero(3, Len(DUD->DUD_STATUS)) .And. FunName() <> 'TMSA190'
				// Só permite trocar o veículo se o novo for do tipo Cavalo OU se o que está gravado for o genérico
				If cCatVei != "2"			
					DTR->(dbSetOrder(1))
					If DTR->(dbSeek(xFilial("DTR") + M->DTR_FILORI + M->DTR_VIAGEM + M->DTR_ITEM))
						If AllTrim(DTR->DTR_CODVEI) != cVeiGen 
							Help( " ",1, "TMSA24077") //--Não é permitido alteração do Veiculo, pois existe Carregamento para a Viagem
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf lRet .And. cCampo $ "M->DTR_QTDEIX"
			// -- Verifica se existe o codigo do veiculo e os reboques para preencher o array
			// -- aVeiculos para calculo do frete e pedagio
			If lRet .And. !Empty(GdFieldGet('DTR_CODVEI',n))
				AAdd(aVeiculos, {	GdFieldGet('DTR_CODVEI',n), ;
									M->DTR_QTDEIX, ;
									GdFieldGet("DTR_QTEIXV",n) })
				
				nQtdEix := Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODVEI',n),"DA3_QTDEIX")
				If !Empty(GdFieldGet('DTR_CODRB1',n))
					AAdd(aVeiculos, { GdFieldGet('DTR_CODRB1',n), 0, 0 } )
					nQtdEix += Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB1',n),"DA3_QTDEIX")
				EndIf
				If !Empty(GdFieldGet('DTR_CODRB2',n))
					AAdd(aVeiculos, { GdFieldGet('DTR_CODRB2',n), 0, 0 } )
					nQtdEix += Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB2',n),"DA3_QTDEIX")
				EndIf
				If lTercRbq .And. !Empty(GdFieldGet('DTR_CODRB3',n))
					AAdd(aVeiculos, { GdFieldGet('DTR_CODRB3',n), 0, 0 } )
					nQtdEix += Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB3',n),"DA3_QTDEIX")
				EndIf 
				// -- A quantidade digitada nao pode ser maior que a quantidade anterior
				If M->DTR_QTDEIX > nQtdEix .Or. M->DTR_QTDEIX == 0
					lRet := .F.
				Else
					//-- Calcula Frete Carreteiro
					lRet := aCalFreCar(aVeiculos,,lCalPedg,n,,Iif(Type('oGet') == 'U',, Iif(Type('oGet') != 'U', oGet:nOpc,)))
				EndIf
			EndIf
			
		ElseIf lRet .And. cCampo $ 'M->DTR_QTEIXV'
			If M->DTR_QTEIXV > GdFieldGet('DTR_QTDEIX')
				Help("",1,"TMSA24044") // A Qtde. de Eixos para Volta nao deve ser maior que a Qtde. de eixos na Ida.
				lRet := .F.
			EndIf
			// -- Veifica se existe o codigo do veiculo e os reboques para preencher o array
			// -- aVeiculos para calculo do frete e pedagio
			If lRet .And. !Empty(GdFieldGet('DTR_CODVEI',n))
				AAdd(aVeiculos, {	GdFieldGet('DTR_CODVEI',n),;
									GdFieldGet('DTR_QTDEIX',n),;
									M->DTR_QTEIXV })
	
				If lRepom .And. ExistFunc('RepRetCod') //Funcionalidade de eixos suspensos
					nQtdEix := Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODVEI',n),"DA3_QTDEIX")
	
					If !Empty(GdFieldGet('DTR_CODRB1',n))
						AAdd(aVeiculos, { GdFieldGet('DTR_CODRB1',n), 0, 0 } )	
						nQtdEix += Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB1',n),"DA3_QTDEIX")
					EndIf
					If !Empty(GdFieldGet('DTR_CODRB2',n))
						AAdd(aVeiculos, { GdFieldGet('DTR_CODRB2',n), 0, 0 } )	
						nQtdEix += Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB2',n),"DA3_QTDEIX")
					EndIf
					If !Empty(GdFieldGet('DTR_CODRB3',n))
						AAdd(aVeiculos, { GdFieldGet('DTR_CODRB3',n), 0, 0 } )	
						nQtdEix += Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB3',n),"DA3_QTDEIX")
					EndIf
	
					// -- A quantidade digitada nao pode ser maior que a quantidade anterior
					If M->DTR_QTEIXV > nQtdEix .Or. M->DTR_QTDEIXV == 0
						lRet := .F.
					EndIf	
				EndIf
	
	
				//-- Calcula Frete Carreteiro
				lRet := aCalFreCar(aVeiculos,,lCalPedg,n,,Iif(Type('oGet') == 'U',, oGet:nOpc))
			EndIf
			
		ElseIf lRet .And. cCampo $ 'M->DTR_CODRB1.M->DTR_CODRB2.M->DTR_CODRB3'
	
			If !lPlanejada //Viagem Planejada
				cReboque := &cCampo
				lRet := TMSA240Blq(cReboque)	
			EndIf	
	
			If !Empty( GdFieldGet("DTR_CODVEI",n) )
				AAdd(aVeiculos, {	GdFieldGet("DTR_CODVEI",n),;
									GdFieldGet("DTR_QTDEIX",n),;
									GdFieldGet("DTR_QTEIXV",n)} )
			EndIf
			
			If cCampo $ 'M->DTR_CODRB1' .And. Empty(M->DTR_CODRB1)
				If !Empty(GdFieldGet("DTR_CODRB1",n))
					GdFieldPut("DTR_QTDEIX",GdFieldGet("DTR_QTDEIX",n)-Posicione("DA3",1,xFilial("DA3")+GdFieldGet("DTR_CODRB1",n),"DA3_QTDEIX"),n)
					If Len(aVeiculos) > 0
						aVeiculos[1,2] := GdFieldGet("DTR_QTDEIX",n)
					EndIf
				EndIf
				If lEixVolta .And. !Empty(GdFieldGet("DTR_CODRB1",n)) 
					GdFieldPut("DTR_QTEIXV",GdFieldGet("DTR_QTEIXV",n)-Posicione("DA3",1,xFilial("DA3")+GdFieldGet("DTR_CODRB1",n),"DA3_QTDEIX"),n)
					If Len(aVeiculos) > 0
						aVeiculos[1,3] := GdFieldGet("DTR_QTEIXV",n)
					EndIf
				EndIf
				//-- Calcula Frete Carreteiro
				lRet := aCalFreCar(aVeiculos,,lCalPedg,n,,Iif(Type('oGet') == 'U',, oGet:nOpc))
	
			ElseIf lRet .And. cCampo $ 'M->DTR_CODRB2' .And. Empty(M->DTR_CODRB2)
				If !Empty(GdFieldGet("DTR_CODRB2",n))
					GdFieldPut("DTR_QTDEIX",GdFieldGet("DTR_QTDEIX",n)-Posicione("DA3",1,xFilial("DA3")+GdFieldGet("DTR_CODRB2",n),"DA3_QTDEIX"),n)
					If Len(aVeiculos) > 0
						aVeiculos[1,2] := GdFieldGet("DTR_QTDEIX",n)
					EndIf
				EndIf
				If lEixVolta .And. !Empty(GdFieldGet("DTR_CODRB2",n)) 
					GdFieldPut("DTR_QTEIXV",GdFieldGet("DTR_QTEIXV",n)-Posicione("DA3",1,xFilial("DA3")+GdFieldGet("DTR_CODRB2",n),"DA3_QTDEIX"),n)
					If Len(aVeiculos) > 0
						aVeiculos[1,3] := GdFieldGet("DTR_QTEIXV",n)
					EndIf
				EndIf
				//-- Calcula Frete Carreteiro
				lRet := aCalFreCar(aVeiculos,,lCalPedg,n,,Iif(Type('oGet') == 'U',, oGet:nOpc))
			ElseIf lRet .And. lTercRbq .And. cCampo $ 'M->DTR_CODRB3' .And. Empty(M->DTR_CODRB3)
				If !Empty(GdFieldGet("DTR_CODRB3",n))
					GdFieldPut("DTR_QTDEIX",GdFieldGet("DTR_QTDEIX",n)-Posicione("DA3",1,xFilial("DA3")+GdFieldGet("DTR_CODRB3",n),"DA3_QTDEIX"),n)
					If Len(aVeiculos) > 0
						aVeiculos[1,2] := GdFieldGet("DTR_QTDEIX",n)
					EndIf
				EndIf
				If lEixVolta .And. !Empty(GdFieldGet("DTR_CODRB3",n)) 
					GdFieldPut("DTR_QTEIXV",GdFieldGet("DTR_QTEIXV",n)-Posicione("DA3",1,xFilial("DA3")+GdFieldGet("DTR_CODRB3",n),"DA3_QTDEIX"),n)
					If Len(aVeiculos) > 0
						aVeiculos[1,3] := GdFieldGet("DTR_QTEIXV",n)
					EndIf
				EndIf
				//-- Calcula Frete Carreteiro
				lRet := aCalFreCar(aVeiculos,,lCalPedg,n,,Iif(Type('oGet') == 'U',, oGet:nOpc))	
			EndIf
			
			If lRet
				DA3->( DbSetOrder( 1 ) )
				If	DA3->( ! MsSeek( xFilial('DA3') + &(cCampo), .F. ) )
					Help(' ', 1, 'TMSA24025',,STR0009 + &(cCampo),5,11)	 //"Veiculo não cadastrado ..." ### "Veiculo : "
					lRet := .F.
				EndIf
			EndIf
			
			If	lRet .And. DA3->DA3_ATIVO != "1"
				Help(' ', 1, 'TMSA24001',,STR0009 + &(cCampo),5,11)	//-- Este veiculo nao esta ativo (DA3)	//'Veiculo : ' //'Veiculo : '
				lRet := .F.
			EndIf
			
			If lRet .And. cCampo == 'M->DTR_CODRB1'
				If !Empty(M->DTR_CODRB1)
					//-- Verifica se o Veiculo esta Liberado
					DTU->( DbSetOrder(2) )
					If lContVei .And. M->DTR_CODRB1 <> cVeiGen .And. DTU->( ! MsSeek(xFilial("DTU")+M->DTR_CODRB1+"2") )
						Help(' ', 1, 'TMSA24006',,STR0009 + M->DTR_CODRB1,5,11)	//"Veiculo sem Entrada Liberada!" ### "Veiculo : "
						lRet := .F.
					EndIf
					If  lRet .And. M->DTR_CODRB1 <> cVeiGen .And. Ascan(aCols, {|x|  !(x[Len(aHeader)+1]) .And. x[nPosRb2] == M->DTR_CODRB1 }) > 0
						Help(" ", 1, 'TMSA24028',,STR0009 + M->DTR_CODRB1,5,11)	//"Reboque informado para outro Veiculo!"	### "Veiculo : "
						lRet := .F.
					EndIf
					
					If lTercRbq
						If  lRet .And. M->DTR_CODRB1 <> cVeiGen .And. Ascan(aCols, {|x|  !(x[Len(aHeader)+1]) .And. x[nPosRb3] == M->DTR_CODRB1 }) > 0
							Help(" ", 1, 'TMSA24028',,STR0009 + M->DTR_CODRB1,5,11)	//"Reboque informado para outro Veiculo!"	### "Veiculo : "
							lRet := .F.
						EndIf
					EndIF 
					//--Nao e permitido selecionar o 1o.Reboque em duas viagens simultaneamente
					If (lContVei .Or. lMV_EmViag) .And. M->DTR_CODRB1 <> cVeiGen .And. !LockByName("VGERB1" + M->DTR_CODRB1,.T.,.F.)
						Help( ' ', 1, 'TMSA24050', , STR0009 + M->DTR_CODRB1,3 ,0) //"O Veiculo esta sendo utilizado por outra viagem." ### "Veiculo: "
						lRet := .F.
					EndIf
					
					// -- Soma na quantidade de eixos o codigo do veiculo com o codigo reboque 1 e o codigo do reboque 2 se existir
					If lRet
						nQtdEix := Posicione("DA3",1,xFilial("DA3")+M->DTR_CODRB1,"DA3_QTDEIX")
						nQtdEix += Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODVEI',n),"DA3_QTDEIX")
						nQtdEix += IIf(!Empty(GdFieldGet('DTR_CODRB2',n)),Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB2',n),"DA3_QTDEIX"),0)
						GdFieldPut("DTR_QTDEIX",nQtdEix,n)
						If Len(aVeiculos) > 0
							aVeiculos[1,2] := nQtdEix
						EndIf
						
						nQtdEixV := Posicione("DA3",1,xFilial("DA3")+M->DTR_CODRB1,"DA3_QTDEIX")
						nQtdEixV += Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODVEI',n),"DA3_QTDEIX")
						nQtdEixV += IIf(!Empty(GdFieldGet('DTR_CODRB2',n)),Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB2',n),"DA3_QTDEIX"),0)
						GdFieldPut("DTR_QTEIXV",nQtdEixV,n)
						If Len(aVeiculos) > 0
							aVeiculos[1,3] := nQtdEixV
						EndIf
						AAdd(aVeiculos, {	M->DTR_CODRB1, 0, 0 } )
					EndIf
	
					If lRet .And. !Empty(GdFieldGet('DTR_CODRB2',n))
						AAdd(aVeiculos, {GdFieldGet('DTR_CODRB2',n), 0, 0 })
					EndIf
				EndIf
				
			ElseIf lRet .And. cCampo == 'M->DTR_CODRB2'
				If !Empty(M->DTR_CODRB2)
					//-- Verifica se o Veiculo esta Liberado
					DTU->( DbSetOrder(2) )
					If lContVei .And. M->DTR_CODRB2 <> cVeiGen .And. DTU->( ! MsSeek(xFilial("DTU")+M->DTR_CODRB2+"2") )
						Help(' ', 1, 'TMSA24006',,STR0009 + M->DTR_CODRB2,5,11)	//"Veiculo sem Entrada Liberada!" ### "Veiculo : "
						lRet := .F.
					EndIf
					If lRet .And. M->DTR_CODRB2 <> cVeiGen .And. Ascan(aCols, {|x|  !(x[Len(aHeader)+1]) .And.  x[nPosRb1] == M->DTR_CODRB2 }) > 0
						Help(" ", 1, 'TMSA24028',,STR0009 + M->DTR_CODRB2,5,11)	//"Reboque ja informado para a viagem!" ### "Veiculo : "
						lRet := .F.
					EndIf
					
					//--Nao e permitido selecionar o 2o.Reboque em duas viagens simultaneamente
					If (lContVei .Or. lMV_EmViag) .And. M->DTR_CODRB2 <> cVeiGen .And. !LockByName("VGERB2" + M->DTR_CODRB2,.T.,.F.)
						Help( ' ', 1, 'TMSA24050', , STR0009 + M->DTR_CODRB2,3 ,0) //"O Veiculo esta sendo utilizado por outra viagem." ### "Veiculo: "
						lRet := .F.
					EndIf
					
					If lRet
						// -- Soma as quantidades de eixos do codigo do veiculo,codigo do reboque 1 e codigo do reboque 2
						nQtdEix := Posicione("DA3",1,xFilial("DA3")+M->DTR_CODRB2,"DA3_QTDEIX")
						nQtdEix += Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODVEI',n),"DA3_QTDEIX")
						nQtdEix += IIf(!Empty(GdFieldGet('DTR_CODRB1',n)),Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB1',n),"DA3_QTDEIX"),0)
						GdFieldPut("DTR_QTDEIX",nQtdEix,n)
						If Len(aVeiculos) > 0
							aVeiculos[1,2] := nQtdEix
						EndIf
						If	lEixVolta 
							nQtdEixV := Posicione("DA3",1,xFilial("DA3")+M->DTR_CODRB2,"DA3_QTDEIX")
							nQtdEixV += Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODVEI',n),"DA3_QTDEIX")
							nQtdEixV += IIf(!Empty(GdFieldGet('DTR_CODRB1',n)),Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB1',n),"DA3_QTDEIX"),0)
							GdFieldPut("DTR_QTEIXV",nQtdEixV,n)
							If Len(aVeiculos) > 0
								aVeiculos[1,3] := nQtdEixV
							EndIf
						EndIf
						AAdd(aVeiculos, { M->DTR_CODRB2,0, 0 })
	
					EndIf
				EndIf
				
				If lRet .And. !Empty(GdFieldGet('DTR_CODRB1',n))
					AAdd(aVeiculos, {GdFieldGet('DTR_CODRB1',n), 0, 0 })
				EndIf
			ElseIf lRet .And. lTercRbq .And. cCampo == 'M->DTR_CODRB3'
				If !Empty(M->DTR_CODRB3)
					//-- Verifica se o Veiculo esta Liberado
					DTU->( DbSetOrder(2) )
					If lContVei .And. M->DTR_CODRB3 <> cVeiGen .And. DTU->( ! MsSeek(xFilial("DTU")+M->DTR_CODRB3+"2") )
						Help(' ', 1, 'TMSA24006',,STR0009 + M->DTR_CODRB3,5,11)	//"Veiculo sem Entrada Liberada!" ### "Veiculo : "
						lRet := .F.
					EndIf
					If lRet .And. M->DTR_CODRB3 <> cVeiGen .And. Ascan(aCols, {|x|  !(x[Len(aHeader)+1]) .And.  x[nPosRb1] == M->DTR_CODRB3 }) > 0
						Help(" ", 1, 'TMSA24028',,STR0009 + M->DTR_CODRB3,5,11)	//"Reboque ja informado para a viagem!" ### "Veiculo : "
						lRet := .F.
					EndIf
					
					If lRet .And. M->DTR_CODRB3 <> cVeiGen .And. Ascan(aCols, {|x|  !(x[Len(aHeader)+1]) .And.  x[nPosRb2] == M->DTR_CODRB3 }) > 0
						Help(" ", 1, 'TMSA24028',,STR0009 + M->DTR_CODRB3,5,11)	//"Reboque ja informado para a viagem!" ### "Veiculo : "
						lRet := .F.
					EndIf
					
					
					//--Nao e permitido selecionar o 3o.Reboque em duas viagens simultaneamente
					If (lContVei .Or. lMV_EmViag) .And. M->DTR_CODRB3 <> cVeiGen .And. !LockByName("VGERB3" + M->DTR_CODRB3,.T.,.F.)
						Help( ' ', 1, 'TMSA24050', , STR0009 + M->DTR_CODRB3,3 ,0) //"O Veiculo esta sendo utilizado por outra viagem." ### "Veiculo: "
						lRet := .F.
					EndIf
					
					If lRet
						// -- Soma as quantidades de eixos do codigo do veiculo,codigo do reboque 1, codigo do reboque 2 e codigo do reboque 3
						nQtdEix := Posicione("DA3",1,xFilial("DA3")+M->DTR_CODRB3,"DA3_QTDEIX")
						nQtdEix += Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODVEI',n),"DA3_QTDEIX")
						nQtdEix += IIf(!Empty(GdFieldGet('DTR_CODRB1',n)),Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB1',n),"DA3_QTDEIX"),0)
						nQtdEix += IIf(!Empty(GdFieldGet('DTR_CODRB2',n)),Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB2',n),"DA3_QTDEIX"),0)
						GdFieldPut("DTR_QTDEIX",nQtdEix,n)
						If Len(aVeiculos) > 0
							aVeiculos[1,2] := nQtdEix
						EndIf
						If	lEixVolta 
							nQtdEixV := Posicione("DA3",1,xFilial("DA3")+M->DTR_CODRB3,"DA3_QTDEIX")
							nQtdEixV += Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODVEI',n),"DA3_QTDEIX")
							nQtdEixV += IIf(!Empty(GdFieldGet('DTR_CODRB1',n)),Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB1',n),"DA3_QTDEIX"),0)
							nQtdEixV += IIf(!Empty(GdFieldGet('DTR_CODRB2',n)),Posicione("DA3",1,xFilial("DA3")+GdFieldGet('DTR_CODRB2',n),"DA3_QTDEIX"),0)
							GdFieldPut("DTR_QTEIXV",nQtdEixV,n)
							If Len(aVeiculos) > 0
								aVeiculos[1,3] := nQtdEixV
							EndIf
						EndIf
						AAdd(aVeiculos, { M->DTR_CODRB3,0, 0 })
	
					EndIf
				EndIf
				
				If lRet .And. !Empty(GdFieldGet('DTR_CODRB1',n))
					AAdd(aVeiculos, {GdFieldGet('DTR_CODRB1',n), 0, 0 })
				EndIf
				
				If lRet .And. !Empty(GdFieldGet('DTR_CODRB2',n))
					AAdd(aVeiculos, {GdFieldGet('DTR_CODRB2',n), 0, 0 })
				EndIf
			EndIf
			
			//-- Verifica se o 1o.Reboque e' igual ao Veiculo / 2o.Reboque e 3o.Reboque
			If lRet .And. cCampo == 'M->DTR_CODRB1' .And.  (M->DTR_CODRB1 == GdFieldGet('DTR_CODVEI',n) .Or.;
				M->DTR_CODRB1 == GdFieldGet('DTR_CODRB2',n) .Or. IIf(lTercRbq,M->DTR_CODRB1 == GdFieldGet('DTR_CODRB3',n),.F.))
				lRet := .F.
			EndIf
			
			//-- Verifica se o 1o.Reboque esta em viagem, para viagens diferente de 'Planejada'
			If lRet .And. cCampo == 'M->DTR_CODRB1' .And. ( lContVei .Or. lMV_EmViag ) .And. aFilOri[5] <> 3;
				.And. !TMSEmViag(M->DTR_FILORI,M->DTR_VIAGEM, M->DTR_CODRB1, 1)
				lRet := .F.
			EndIf
			
			//-- Nao permite a escolha de um reboque se a categoria do veiculo for comum (DUT_CATVEI == "1").
			If lRet .And. (GdFieldGet('DTR_CODVEI',n) <> cVeiGen) .And. cCampo $ 'M->DTR_CODRB1/M->DTR_CODRB2/M->DTR_CODRB3' .And.  DA3->(MsSeek(xFilial("DA3") + GdFieldGet('DTR_CODVEI',n) ) )  .And.;
				DUT->(MsSeek(xFilial("DUT") + DA3->DA3_TIPVEI)) .And. (DUT->DUT_CATVEI == StrZero(1, Len(DUT->DUT_CATVEI)) .Or. DUT->DUT_CATVEI == StrZero(5, Len(DUT->DUT_CATVEI)))
				Help(' ', 1, 'TMSA240VEI', , STR0085, 3, 0) //-- Não é permitida a escolha de um Semi Reboque, quando o Cod.Veículo não for Cavalo Mecânico.
				lRet := .F.
			EndIf
			
			//-- Verifica se o 2o.Reboque e' igual ao Veiculo / 1o.Reboque 3o.Reboque
			If lRet .And. cCampo == 'M->DTR_CODRB2' .And.  (M->DTR_CODRB2 == GdFieldGet('DTR_CODVEI',n) .Or.;
				M->DTR_CODRB2 == GdFieldGet('DTR_CODRB1',n) .Or. IIf(lTercRbq,M->DTR_CODRB2 == GdFieldGet('DTR_CODRB3',n),.F.))
				lRet := .F.
			EndIf
			
			//-- Verifica se o 2o.Reboque esta em viagem, para viagens diferente de 'Planejada'
			If lRet .And. cCampo == 'M->DTR_CODRB2' .And. ( lContVei .Or. lMV_EmViag ) .And. aFilOri[5] <> 3;
				.And. !TMSEmViag(M->DTR_FILORI,M->DTR_VIAGEM, M->DTR_CODRB2, 1)
				lRet := .F.
			EndIf
			
			If lRet .And. cCampo == 'M->DTR_CODRB2' .And. Empty(GdFieldGet('DTR_CODRB1',n))
				Help('',1,'TMSA24017')  //-- Informe o 1o. Reboque
				lRet := .F.
			EndIf
			
			//-- Verifica se o 3o.Reboque e' igual ao Veiculo / 1o.Reboque 2o.Reboque
			If lTercRbq
				If lRet .And. cCampo == 'M->DTR_CODRB3' .And.  (M->DTR_CODRB3 == GdFieldGet('DTR_CODVEI',n) .Or.;
					M->DTR_CODRB3 == GdFieldGet('DTR_CODRB1',n) .Or. M->DTR_CODRB3 == GdFieldGet('DTR_CODRB2',n))
					lRet := .F.
				EndIf
			
				//-- Verifica se o 3o.Reboque esta em viagem, para viagens diferente de 'Planejada'
				If lRet .And. cCampo == 'M->DTR_CODRB3' .And. ( lContVei .Or. lMV_EmViag ) .And. aFilOri[5] <> 3;
					.And. !TMSEmViag(M->DTR_FILORI,M->DTR_VIAGEM, M->DTR_CODRB3, 1)
					lRet := .F.
				EndIf
				
				If lRet .And. cCampo == 'M->DTR_CODRB3' .And. Empty(GdFieldGet('DTR_CODRB2',n))
					Help('',1,'TMSA24080')  //-- Informe o 2o. Reboque 
					lRet := .F.
				EndIf
			EndIf
			If lRet .And. (&(ReadVar()) <> cVeiGen )
				DA3->( DbSetOrder( 1 ) )
				If DA3->( MsSeek( xFilial('DA3') + &(ReadVar()) ))
					DUT->(dbSetOrder(1))
					DUT->(MsSeek(xFilial('DUT')+DA3->DA3_TIPVEI))
					If DUT->(Eof())
						Help('',1,'TMSA24011') //-- Nao foi encontrado Categoria de Veiculo para este Tipo de Veiculo
						lRet := .F.
					EndIf
					If lRet .And. DUT->DUT_CATVEI <> '3'
						Help('',1,'TMSA24010')	//--Os veiculos do reboque deverao ser de categoria igual "3" (Carreta).
						lRet := .F.
					EndIf
				EndIf
			EndIf
			
			If lRet.And. lTabRRE   
				If cCampo == 'M->DTR_CODRB1' .And. !Empty(M->DTR_CODRB1)
					If lRet .And. GdFieldGet('DTR_CODRB1',n) <> M->DTR_CODRB1
						cChaveDJA:= "DA3" + Padr(xFilial("DA3") + GdFieldGet('DTR_CODRB1',n), Len(DJA->DJA_CHAVE)) 
						nAux := aScan( aLibSeg,{|ExpA1| ExpA1[1] == cChaveDJA } )
						If nAux > 0  
							//"Existe uma Liberacao de Seguro cadastrada, deseja realmente efetuar a alteracao do codigo? (os dados de Liberação serão perdidos)"
							If MsgYesNo( STR0076 ,STR0020	)
								aDel(aLibSeg,nAux)
								aSize(aLibSeg,Len(aLibSeg)-1)
							Else
								lRet:= .F.
							EndIf
						EndIf
					EndIf 
					If lRet
						TA240Segur(oGet:nOpc,M->DTR_FILORI, M->DTR_VIAGEM, "DA3",GdFieldGet('DTR_CODVEI',n),M->DTR_CODRB1, '',.F. )         
					EndIf	
				ElseIf cCampo == 'M->DTR_CODRB2' .And. !Empty(M->DTR_CODRB2)  
					If lRet .And. GdFieldGet('DTR_CODRB2',n) <> M->DTR_CODRB2
						cChaveDJA:= "DA3" + Padr(xFilial("DA3") + GdFieldGet('DTR_CODRB2',n), Len(DJA->DJA_CHAVE))   
						nAux := aScan( aLibSeg,{|ExpA1| ExpA1[1] == cChaveDJA } )
						If nAux > 0  
							//"Existe uma Liberacao de Seguro cadastrada, deseja realmente efetuar a alteracao do codigo? (os dados de Liberação serão perdidos)"
							If MsgYesNo( STR0076 ,STR0020	)
								aDel(aLibSeg,nAux)
								aSize(aLibSeg,Len(aLibSeg)-1)
							Else
								lRet:= .F.
							EndIf
						EndIf
					EndIf  
					If lRet
						TA240Segur(oGet:nOpc,M->DTR_FILORI, M->DTR_VIAGEM, "DA3",GdFieldGet('DTR_CODVEI',n),,M->DTR_CODRB2,.F. )         
					EndIf	
				EndIf	
			EndIf
			If lRet
				//-- Calcula Frete Carreteiro
				lRet := aCalFreCar(aVeiculos,,lCalPedg,n,,Iif(Type('oGet') == 'U',, oGet:nOpc))
			EndIf
			
		ElseIf lRet .And. cCampo $ "M->DTR_CREADI.M->DTR_LOJCRE"
			If cCampo == 'M->DTR_CREADI'
				cChave := M->DTR_CREADI+GdFieldGet('DTR_LOJCRE',n)
			Else
				cChave := GdFieldGet('DTR_CREADI',n)+M->DTR_LOJCRE
			EndIf
			SA2->(dbSetOrder(1))
			If !SA2->(MsSeek(xFilial("SA2")+cChave))
				Help('',1,'REGNOIS') //Nao existe registro relacionado a este codigo"
				lRet := .F.
			EndIf
			
		ElseIf lRet .And. cCampo $ "M->DTR_VALFRE"
			If M->DTR_VALFRE > 0
				lHerdaFrt:= .F.
				nPosValBai := Ascan(aHeaderSDG, {|x| AllTrim(x[2]) == "DG_VALBAI" })
				nPosAdto   := Ascan(aAdtoViag, {|x| x[1] == GDFieldGet("DTR_CODVEI",n) })
				If ( nPosAdto > 0 ) .And. ( nPosValBai > 0 )
					For nX := 1 To Len(aAdtoViag[nPosAdto][2])
						If !aAdtoViag[nPosAdto,2,nX,Len(aHeaderSDG)+1]
							nValor += aAdtoViag[nPosAdto,2,nX,nPosValBai]
						EndIf
					Next nX
					If !lGerAdf .And. nValor > M->DTR_VALFRE
						Help("",1,"TMSA24038") //"O total dos adiantamentos nao podera ser maior o valor do frete"
						lRet := .F.
					EndIf
				EndIf
				If lRet 
					//--- Somente Atualizar a Coligada se a Viagem estiver OK
					aAreaDTR2:= DTR->(GetArea())
					DTR->(dbSetOrder(2)) // DTR_FILVGE + DTR_NUMVGE
					If DTR->(MsSeek(xFilial('DTR')+M->DTR_FILORI+M->DTR_VIAGEM))
						lRetCmp:= A240CmpDTR(DTR->DTR_FILORI,DTR->DTR_VIAGEM,Iif(Type('oGet') == 'U',, oGet:nOpc), @aYesCampo,@aHerCampo)
						If lRetCmp
							If MsgYesNo( STR0087 ,STR0020)  //"Deseja replicar o Valor do Frete da Viagem Principal para a Viagem Coligada? "
								lHerdaFrt:= .T.
							EndIf
						EndIf	
					EndIf	
					RestArea(aAreaDTR2)
				EndIf
				If lRet .And. M->DTR_CODOPE == '02' .And. ExistFunc('PamFrtMin')
					cCatVei := cValToChar(PamCatVeic(M->DTR_QTDEIX))
					If ExistFunc('TMSCEOrDes') .And. Len(aCEPeDist:= TMSCEOrDes(M->DTQ_FILORI,M->DTQ_VIAGEM,M->DTQ_SERTMS, M->DTQ_ROTA, aDoctosVge)) > 0
						If Len(aCEPeDist) > 2						
							nKmDista := aCEPeDist[3]
						EndIf
					EndIf
					If DTQ->(ColumnPos('DTQ_TPOPVG')) > 0 .And. DLO->(ColumnPos('DLO_CODTPC')) > 0
						cCargaTipo := Posicione('DLO',1,FwxFilial('DLO')+M->DTQ_TPOPVG,'DLO_CODTPC')
					EndIf						
					PamFrtMin(cCatVei, nKmDista, cCargaTipo, M->DTR_VALFRE)
				EndIf
			EndIf
		ElseIf lRet .And. cCampo $ "M->DTR_CNPJPG"
			aFilSM0		:= FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_CGC"} )
			cCNPJPg		:= M->DTR_CNPJPG
			cCNPJFil	:= aFilSM0[1][2]
			If cCNPJPg == cCNPJFil  
				HELP(" ",1,"TMSA240A6") // O CNPJ do responsável pelo pagamento do pedágio deve ser diferente do emitente do MDF-E. 
				lRet := .F.
			EndIf 
		EndIf
	EndIf
	
	//-- Tratamento Rentabilidade/Ocorrencia
	If lRet .And. cCampo $ "M->DTR_CODVEI|M->DTR_CODRB1|M->DTR_CODRB2|M->DTR_CODRB3" .And. Type('oGet') == 'O' .And. oGet:nOpc == 4 //-- Alteração
		If DUA->(ColumnPos('DUA_CODFOR')) > 0
			lRet := Tmsa240VFor( oGet:nOpc == 4 )
		EndIf
	
	EndIf
	
	//-- Ponto de Entrada para validacao de usuario final
	If	lTMS240VLD
		lRetPE := ExecBlock('TMS240VLD',.F.,.F.,{cCampo, lRet})
		If ValType(lRetPE) == "L"
			lRet := lRetPE
		EndIf
	EndIf
EndIf

RestArea( aAreaDA4 )
RestArea( aAreaDA3 )
RestArea( aAreaAnt )
RestArea( aAreaDTR )
RestArea( aAreaDTQ )

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA240Whe³ Autor ³ Patricia A. Salomao  ³ Data ³23.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes p/ edicao do campo (X3_WHEN)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA240Whe()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA240Whe( cCampo )
Local aAreaDA3   := DA3->(GetArea())
Local aAreaDF8   := DF8->(GetArea())
Local aAreaDUP   := DUP->(GetArea())
Local lRet       := .T.
Local cRepom     := GetMV("MV_TMSOPDG",,"0")
Local cMV_TMSRRE := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
Local lMVITMSDMD := SuperGetMv("MV_ITMSDMD",.F.,.F.) //Parametro que indica se a Gestão de Demandas está ativa ou não.
Local lDTR_FOROPE:= ColumnPos("DTR_FOROPE")
Local lVgeMod3  := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)

Default cCampo   := ReadVar()

If !lVgeMod3
	If cCampo $'DA3_CODRB2'
		lRet := !Empty(GdFieldGet('DTR_CODRB1',n))
	EndIf
	If cCampo $'DA3_CODRB3'
		lRet := !Empty(GdFieldGet('DTR_CODRB2',n))
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente permitir a digitacao do 1o. 2o. e 3o Reboque caso o veiculo seja de    ³
	//³categoria 2=Cavalo ou 3=Especial.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. cCampo $ 'DA3_CODRB1.DA3_CODRB2.DA3_CODRB3'
		DA3->(DbSetOrder(1))
		DA3->(MsSeek( xFilial('DA3') + M->DTR_CODVEI))
		DUT->(dbSetOrder(1))
		DUT->(MsSeek(xFilial('DUT')+DA3->DA3_TIPVEI))
		lRet := (DUT->DUT_CATVEI == '2' .Or. DUT->DUT_CATVEI == '4')
	EndIf
	
	// Nao permite a digitacao dos campos Frete para veiculo proprio.
	If lRet .And. cCampo $ "M->DTR_INSRET.M->DTR_VALFRE"
		lRet := !(DA3->(MsSeek(xFilial("DA3") + GdFieldGet("DTR_CODVEI", n))) .And.;
		DA3->DA3_FROVEI == StrZero(1, Len(DA3->DA3_FROVEI)))
	EndIf
	
	// Nao permite a digitacao do campo Valor Frete do primeiro Reboque para veiculo proprio.
	If DTR->(ColumnPos("DTR_VALRB1")) > 0
		If lRet .And. cCampo $ "M->DTR_VALRB1"
			lRet := !(DA3->(MsSeek(xFilial("DA3") + GdFieldGet("DTR_CODRB1", n))) .And.;
			DA3->DA3_FROVEI == StrZero(1, Len(DA3->DA3_FROVEI)))
		EndIf
	EndIf
	
	// Nao permite a digitacao do campo Valor Frete do segundo Reboque para veiculo proprio.
	If DTR->(ColumnPos("DTR_VALRB2")) > 0
		If lRet .And. cCampo $ "M->DTR_VALRB2"
			lRet := !(DA3->(MsSeek(xFilial("DA3") + GdFieldGet("DTR_CODRB2", n))) .And.;
			DA3->DA3_FROVEI == StrZero(1, Len(DA3->DA3_FROVEI)))
		EndIf
	EndIf
	
	// Nao permite a digitacao do campo Valor Frete do terceiro Reboque para veiculo proprio.
	If DTR->(ColumnPos('DTR_VALRB3')) > 0
		If lRet .And. cCampo $ "M->DTR_VALRB3"
			lRet := !(DA3->(MsSeek(xFilial("DA3") + GdFieldGet("DTR_CODRB3", n))) .And.;
			DA3->DA3_FROVEI == StrZero(1, Len(DA3->DA3_FROVEI)))
		EndIf
	EndIf
	If lRet .And. cCampo $'DUP_CONDUT' .And. cRepom == "0"
		lRet := .F.
	EndIF
	
	If lRet .And. "3" $ cMV_TMSRRE   
		If cCampo $ 'M->DUP_LIBSEG' //2-Viagem; 3=Todos
			lRet := .F.
		ElseIf cCampo $ 'M->DJA_DTIVSG'
			lRet := !Empty(GdFieldGet('DJA_LIBSEG',n))
		ElseIf cCampo $ 'M->DJA_DTFVSG'
			lRet := !Empty(GdFieldGet('DJA_DTIVSG',n))
		EndIf 
	EndIf 
	
	//Se vier da Gestão de Demandas não permite alterar.
	If lRet .AND. lMVITMSDMD .AND. DF8->(ColumnPos("DF8_PLNDMD")) > 0  //SUAVIZAÇÃO DEMANDAS
		If cCampo $ 'DTR_CODVEI ; DTR_CODRB1 ; DTR_CODRB2 ; DTR_CODRB3 ; DUP_CODMOT' 
			If IsInCallStack('TMSA146')
				If cCampo == 'DUP_CODMOT' 
					DUP->(DbSetOrder(2))
					If DUP->(MsSeek( xFilial('DUP') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM + M->DUP_CODMOT))
						lRet := .F.
					EndIf
				Else
					lRet := .F.
				EndIf
			Else
				If ALTERA
					DF8->(DbSetOrder(2))
					DF8->(MsSeek( xFilial('DF8') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))
					If !Empty(DF8->DF8_PLNDMD) 
						If cCampo == 'DUP_CODMOT' 
							DUP->(DbSetOrder(2))
							If DUP->(MsSeek( xFilial('DUP') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM + M->DUP_CODMOT))
								lRet := .F.
							EndIf
						Else
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	If lRet .And. (cCampo $ "M->DTR_PRCTRA") 
		lRet := Empty(M->DTR_CODOPE)
	EndIf
	
	If lRet .And. lDTR_FOROPE .And. (cCampo $ "M->DTR_CNPJOP;M->DTR_CNPJPG") 
		lRet := .F.
	EndIf
EndIf

RestArea( aAreaDUP )
RestArea( aAreaDA3 )
RestArea( aAreaDF8 )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA240LOk³ Autor ³ Patricia A. Salomao  ³ Data ³23.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da linha da getdados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA240LOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA240LOk()

Local lRet	  := .T.
Local cVeiGen := GetMV('MV_VEIGEN')
Local nxTipVia
Local lTercRbq := DTR->(ColumnPos("DTR_CODRB3")) > 0
Local aContrFor:= {}
Local cDesADF  := SuperGetMv("MV_DESADF",,"")
Local aAreaDA3 := DA3->( GetArea() )
Local cSerTms2 := ""
Local cTipTra2 := ""
Local lTipOpVg := DTQ->(ColumnPos("DTQ_TPOPVG")) > 0
Local cTipOpVg := ""

If Type('nTipVia') == 'N'
	nxTipVia := nTipVia
Else
	If DTQ->( MsSeek(xFilial("DTQ")+M->DTR_FILORI+AllTrim(M->DTR_VIAGEM)) )
		nxTipVia := Val(DTQ->DTQ_TIPVIA)
	EndIf
EndIf
If lTipOpVg
	If Upper(AllTrim(FunName())) == "TMSA240"
		cTipOpVg:= DTQ->DTQ_TPOPVG
	Else
		cTipOpVg:= M->DTQ_TPOPVG
	EndIf
EndIf

DA3->( DbSetOrder(1) )

//-- Nao avalia linhas deletadas.
If	!GDDeleted( n )
	
	lRet := MaCheckCols( aHeader, aCols, n )
	
	//-- Se for Veiculo Generico nao valida se existe itens duplicados
	If lRet .And. GdFieldGet('DTR_CODVEI',n) <> cVeiGen
		//-- Analisa se ha itens duplicados na GetDados.
		lRet := GDCheckKey( {'DTR_CODVEI'}, 4 )
	EndIf
	
	If lRet .And. !Empty(GdFieldGet('DTR_CODRB1',n))
		If GdFieldGet('DTR_CODRB1',n) <> cVeiGen
			lRet := GDCheckKey( {'DTR_CODRB1'}, 4 )
		EndIf
	EndIf
	
	If lRet .And. !Empty(GdFieldGet('DTR_CODRB2',n))
		If GdFieldGet('DTR_CODRB2',n) <> cVeiGen
			lRet := GDCheckKey( {'DTR_CODRB2'}, 4 )
		EndIf
	EndIf
	
	If lRet .And. lTercRbq .And. !Empty(GdFieldGet('DTR_CODRB3',n))
		If GdFieldGet('DTR_CODRB3',n) <> cVeiGen
			lRet := GDCheckKey( {'DTR_CODRB3'}, 4 )
		EndIf
	EndIf
	If lRet .And. Iif(!Empty(cVeiGen),GdFieldGet('DTR_CODVEI',n) <> cVeiGen,.T.)
		//-- Nao permite a escolha de um reboque se a categoria do veiculo for comum (DUT_CATVEI == "1").
		If DA3->(MsSeek(xFilial("DA3") + GdFieldGet('DTR_CODVEI',n))) .And. DUT->(MsSeek(xFilial("DUT")+DA3->DA3_TIPVEI))
			If DUT->DUT_CATVEI == StrZero(1, Len(DUT->DUT_CATVEI))
				If !Empty(GdFieldGet('DTR_CODRB1',n)) .Or. !Empty(GdFieldGet('DTR_CODRB2',n)) .Or. IIf(lTercRbq,!Empty(GdFieldGet('DTR_CODRB3',n)),.F.)
					Help('',1,'TMSA24019') // Nao e permitido a escolha de um reboque, quando a categoria do veiculo por comum.
					lRet := .F.
				EndIf
			ElseIf DUT->DUT_CATVEI == StrZero(2, Len(DUT->DUT_CATVEI))
				If nxTipVia != 4 .And. nxTipVia != 2 //-- Socorro (4) e Vazia (2)
					If Empty(GdFieldGet('DTR_CODRB1',n))
						Help('',1,'TMSA24027') // A escolha do primeiro reboque e obrigatorio para um veiculo do tipo cavalo.
						lRet := .F.
					EndIf					
					If lTercRbq .And. Empty(GdFieldGet('DTR_CODRB2',n)) .And. !Empty(GdFieldGet('DTR_CODRB3',n))
						Help('',1,'TMSA24080') // Informe o 2° Reboque
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	//--Validação para não permitir o uso de comboio (Mais de Um DTR_CODVEI), quando utilizar integração com ERP Datasul ou Operador de Frete
	If lRet .And. n > 1 
		If !Empty(M->DTR_CODOPE)
			Help('',1,'TMSA24086') //--Não é possível utilizar comboio quando a viagem for integrada com Operadora de Frete!
			lRet := .F.
		ElseIf cTmsErp == '1' 
			Help('',1,'TMSA24087') //--Não é possível utilizar comboio quando o SIGATMS estiver integrado com ERP Datasul!
			lRet := .F.
		EndIf
	
	EndIf

	//--- Validação do Percentual de Adiantamento ---
	If lRet
		If GdFieldGet("DTR_PERADI",n) > 0  
			If Empty(M->DTR_CODOPE) .And. cTmsErp <> '1'  
		  		Help(' ', 1,'TMSA240025A',,STR0091,1,4,)  // 'Permitido informar o Percentual de Adiantamento somente para Viagens com Operadora de Frotas ou Integração com ERP Datasul.'
            	lRet := .F.
			Else
				If Empty(cDesADF)
               		Help(' ', 1,'TMSA240025A',,STR0089,2,4,/*lPop*/,,,,,{{STR0090}})  //'Fornecedor configurado com um percentual de adiantamento e o parâmetro MV_DESADF encontra-se sem preenchimento'
                	                                								  //"Preencher o parâmetro MV_DESADF com o código da despesa relativa ao Adiantamento de frete de Carreteiro"
               		lRet := .F.
				ElseIf !Empty(M->DTR_CODOPE)	
					If DA3->(MsSeek(xFilial("DA3") + GdFieldGet('DTR_CODVEI',n)))  .And.  !Empty(DA3->DA3_CODFOR) 
						If Type('cSerTms') == 'U' .Or. Empty(cSerTms) .Or. Type('cTipTra') == 'U' .Or. Empty(cTipTra)
							A240SerTms(@cSerTms2,@cTipTra2)
						Else
							cSerTms2 := cSerTms
							cTipTra2 := cTipTra
						EndIf
						
						aContrFor := TMSContrFor(DA3->DA3_CODFOR,DA3->DA3_LOJFOR,,cSerTms2,cTipTra2,.F.,DA3->DA3_TIPVEI,cTipOpVg)
						If Empty(aContrFor)
							aContrFor := TMSContrFor(DA3->DA3_CODFOR,DA3->DA3_LOJFOR,,cSerTms2,cTipTra2,.F.,"",cTipOpVg)
						EndIf

						If  Len(aContrFor) > 0 .And. (Empty(aContrFor[1][13]) .Or. aContrFor[1][13] == '0')  //Momento Geração Adiantamento, somente permitido Fechamento e ou Geração CTC
							Help(' ', 1,'TMSA240025A',,STR0092,2,4,/*lPop*/,,,,,{{STR0093}})    //'Contrato do fornecedor configurado com o 'Momento da geração do adiantamneto' (DUJ_TITADI) invalido para calculo do percentual de adiantamento.
                                                                                                //"No contrato do fornecedor, configure o campo com as opções 1 ou 2 para uso do percentual de adiantamento."
           					lRet := .F.
						EndIf
					EndIf
				EndIf	
			EndIf
		EndIf
	EndIf

	If lRet .And. M->DTR_CODOPE == '01'  //Repom
		lRet	:= VldShipRep(GdFieldGet('DTR_CODVEI',n) ,GdFieldGet('DTR_CODRB1',n),GdFieldGet('DTR_CODRB2',n),GdFieldGet('DTR_CODRB3',n))
	EndIf 
Else
	//-- Tratamento Rentabilidade/Ocorrencia
	//-- Verifica Se a Linha Pode Ser Deletada
	If DUA->(ColumnPos('DUA_CODFOR')) > 0	   
		lRet := Tmsa240VFor( .f. )	
	EndIf
EndIf

RestArea(aAreaDA3)
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA240TOk³ Autor ³ Patricia A. Salomao  ³ Data ³23.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao Geral da Tela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA240TOk(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA240TOk(nOpcx, lCalPedg, lMostra)

Local lRet         := .T.
Local lContVei     := GetMV('MV_CONTVEI',,.T.)
Local lMV_EmViag   := GetMV("MV_EMVIAG",,.F.) // Utilizado para verificar se o veiculo esta em uso em outra viagem.
Local nA           := 0
Local nX           := 0
Local nZ           := 0
Local nY		   := 0
Local aVeiculos    := {}
Local nDel         := 0
Local nTotMotor    := 0
Local lTercRbq     := DTR->(ColumnPos("DTR_CODRB3")) > 0
//-- Verifica Posicoes dos campos no aHeader (DTR e DUP)
Local nPosNomMot   := Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_NOMMOT" })
Local nPosTipMot   := Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_TIPMOT" })
Local nPosCodMot   := Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_CODMOT" })
Local nPosIdOpe    := Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_IDOPE" })
Local nPosForPag   := Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_FORPAG" })
Local nPosForAdt   := Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_FORADT" })

Local nPosCodVei   := Ascan(aHeader, {|x| AllTrim(x[2]) == "DTR_CODVEI" })
Local nPosCodRb1   := Ascan(aHeader, {|x| AllTrim(x[2]) == "DTR_CODRB1" })
Local nPosCodRb2   := Ascan(aHeader, {|x| AllTrim(x[2]) == "DTR_CODRB2" })
Local nPosCodRb3   := Ascan(aHeader, {|x| AllTrim(x[2]) == "DTR_CODRB3" })

//-- Operadoras de Frota/Vale-Pedagio
Local cTMSOPdg     := SuperGetMV( 'MV_TMSOPDG',, '0' )
Local aCodigos     := {}
Local cVeiGen      := GetMV('MV_VEIGEN')//Veiculo generico.
Local nMotViag     := 0
Local cTipVeic     := ''
Local lCatEspe     := .F. //--Motorista sempre obrigatorio ( Exceto:Veiculos Categoria Especial )
Local lRepom       := SuperGetMV('MV_TMSOPDG',,'0') == '2' //-- Integracao com Operadoras de Frota
Local lMotAux      := lRepom 
Local lValMot      := .T.
Local lMVTMSAloc   := GetMv("MV_TMSALOC",.F.,.T.) 
Local nAdtoAux 		:= 0 
Local cVsRepom     := SuperGetMV( 'MV_VSREPOM',, '1' )  //-- Versao 2- Contempla nova Legislacao (Encerramento viagem no Posto)  
Local cCodForn     := ''
Local cLojaForn    := ''
Local nCount       := 0
Local lFrotaProp   := .T. 
Local lTipCrg      := DTR->(FieldPos("DTR_TIPCRG")) > 0 
Local cQuery       := ""
Local cAliasQry    := ""
Local dDataIni	   := dDataBase
Local dDataFim	   := dDataBase
Local aAreaAux     := {}
Local lTabDLD      := TableInDic('DLD')
Local lDUPIdOpe    := .F.
Local lDTRTPSPDG   := DTR->(ColumnPos("DTR_TPSPDG")) > 0
Local cSerTms2     := ""
Local nPosDLD	   := 0
Local cIdOpe	   := ""
Local lCartao      := .F.
Local aAreaDTQ	   := DTQ->(GetArea())
Local aAreaDF8     := DF8->(GetArea())
Local aVeic   	   := {}
Local cCodVei      := ''
Local cCodRbq1     := ''
Local cCodRbq2     := ''
Local cCodRbq3     := ''
Local cCodMot      := ''
Local cCodRebq     := ''
Local lLotacao     := .F.  //Controle Pamcard - CIOT para Todos
Local lUmDocVge    := .F.
Local lTabDL9      :=  AliasInDic('DL9') .AND. FindFunction('TMSVldVei') 	
Local lVldVeic     := .T.

Default lCalPedg   := .T.
Default lMostra    := .T.

If lContVei
	//-- Quando a Viagem por planejada, trata como se o controle de veiculos estivesse desligado.
	TMSA240Off( @lContVei, .F. )
EndIf

//-- Analisa se os campos obrigatorios da GetDados foram preenchidos.
If lRet .AND. lMostra
	lRet := oGet:ChkObrigat(oGet:oBrowse:nAt)  .And. IIf(nOpcx == 3 .Or. nOpcx == 4, TMSA240LOk(),.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VERIFICA O aCOLS PRINCIPAL ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. lMostra
	For nA := 1 To Len(aCols)
		If aCols[nA,Len(aHeader)+1]
			nDel++
		EndIf
    Next
	If nDel == Len(aCols)
		Help(' ', 1, 'TMSA24025') //"Veiculo não cadastrado ..." ### "Veiculo : "
		lRet := .F.
	EndIf
EndIf

If DTQ->( MsSeek(xFilial("DTQ")+M->DTR_FILVGE+AllTrim(M->DTR_NUMVGE)) ) 
	If (DTQ->DTQ_VIAGEM != M->DTR_NUMVGE)  
		Help('',1,'TMSA24070')
		lRet := .F.
	EndIf
EndIf	

RestArea(aAreaDTQ)

If Type('cSerTms') == 'U' 
	A240SerTms(@cSerTms2)
Else
	cSerTms2 := cSerTms
EndIf

If lRet .And. cSerTms2 == StrZero( 1, Len( DC5->DC5_SERTMS ) )
	If !Empty(M->DTR_DATINI) .And. !( ValDatHor( M->DTR_DATINI, M->DTR_HORINI, dDataBase, StrTran( Left( Time(), 5 ), ":", "" ),,,,.F.,.T. ) ) 
		Help('',1,'TMSA24097')	//--//--A data inicial do planejamento da viagem não pode ser menor que a data atual.
		lRet := .F.	
	ElseIf !Empty(M->DTR_DATFIM) .And. !( ValDatHor( M->DTR_DATFIM, M->DTR_HORFIM, dDataBase, StrTran( Left( Time(), 5 ), ":", "" ),,,,.F.,.T. ) ) 
		Help('',1,'TMSA24098') //--A data final do planejamento da viagem não pode ser menor que a data atual.
		lRet := .F.			
	EndIf
EndIf

If lRet .And. lDTRTPSPDG .And. cTMSOPdg <> '0' .And. M->DTR_CODOPE == '02' 
	If  Empty(M->DTR_TPSPDG) 
		lRet := .F.
		Help(' ', 1, 'TMSA24069') //É necessário informar o Tipo do Pagto do Pedágio para integração com Pamcard.//--Informe o campo Tp Pgt Pedag
	Else
		If M->DTR_TPSPDG == StrZero( 6, Len( DTR->DTR_TPSPDG ) )
			lRet := .F.
			HELP(" ",1,"TMSA240A7") // A funcionalidade de pagamento de pedágio via 'TAG' está disponível somente para a Viagem Modelo 3.
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VERIFICA O aCOLS DE MOTORISTAS ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. lMostra
	nDel := 0
	For nA := 1 To Len(aCols)
		If !aCols[nA,Len(aHeader)+1]
			nX := aScan(aMotViag,{|x| x[1] == GDFieldGet('DTR_ITEM',nA)}) //-- Verifica se foi informado Motorista para o Item
			If nX > 0
				For nZ := 1 to Len(aMotViag[nX][2])
					If aMotViag[nX][2][nZ][Len(aMotViag[nX][2][nZ])] //-- Verifica se a linha esta deletada
						nDel++
					EndIf
				Next
				IF nDel < Len(aMotViag[nX][2])
					nDel := 0
				EndiF
			EndIf
		EndIf
	Next
	
	For nA := 1 To Len(aCols)
		nMotViag := 0
		If !GDDeleted(nA)
			cTipVeic := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODVEI",nA)),"DA3_TIPVEI")
			lCatEspe := IIF(Posicione("DUT",1,xFilial("DUT")+cTipVeic,"DUT_CATVEI") == '4' ,.T. ,.F.)
			nX := aScan(aMotViag,{|x| x[1] == GDFieldGet('DTR_ITEM',nA)}) //-- Verifica se foi informado Motorista para o Item
			If nX > 0
				For nZ := 1 To Len(aMotViag[nX][2])
					If !lCatEspe
						If !lContVei //Com Controle de Veiculos desligado
							If !Empty(aMotViag[nX][2][nZ][nPosCodMot]) .And. !aMotViag[nX][2][nZ][Len(aMotViag[nX][2][nZ])] //Motorista nao esta vazio nem deletado
								nMotViag += 1
							EndIf
						Else
							If !Empty(aMotViag[nX][2][nZ][nPosCodMot]) .And. !aMotViag[nX][2][nZ][Len(aMotViag[nX][2][nZ])] //Motorista nao esta vazio nem deletado
								nMotViag += 1
							EndIf
						EndIf
					Else
						nMotViag += 1
					EndIf
					nTotMotor := nTotMotor + nMotViag
				Next nZ
				If nMotViag == 0
					Help("",1,"TMSA24047", , STR0009 + AllTrim(GdFieldGet("DTR_CODVEI",nX)) ,3 ,0) //"E necessario informar pelo menos um motorista." ### "Veiculo : "
					lRet := .F.
					Exit
				EndIf
			EndIf
		EndIf
	Next
	
	If lRet .And. nDel == nTotMotor
		Help('',1,'TMSA24041') //"Informe um Motorista para esta viagem ..."
		lRet := .F.
	EndIf
EndIf

//-- Verifica se o Motorista nao esta sendo utilizado em outra viagem
 If lRet .And. nOpcx != 5
	For nA := 1 To Len(aCols)
		If !GDDeleted(nA)
			cTipVeic := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODVEI",nA)),"DA3_TIPVEI")
			lCatEspe := IIF(Posicione("DUT",1,xFilial("DUT")+cTipVeic,"DUT_CATVEI") == '4' ,.T. ,.F.)
			If !lCatEspe
				nX := aScan(aMotViag,{|x| x[1] == GDFieldGet('DTR_ITEM',nA)}) //-- Verifica se foi informado Motorista para o Item
				If nX > 0
					For nZ := 1 To Len(aMotViag[nX][2])
						If lRet .And. !Empty(aMotViag[nX][2][nZ][nPosCodMot]) .And. !aMotViag[nX][2][nZ][Len(aMotViag[nX][2][nZ])]                   
							If !Empty(M->DTR_FILVGE+M->DTR_NUMVGE)
								If lMV_EmViag .And. aFilOri[5] <> 3 .And. !TMSEmViag(M->DTR_FILORI, M->DTR_VIAGEM, aMotViag[nX][2][nZ][nPosCodMot], 2, .T.,,, M->DTR_FILVGE, M->DTR_NUMVGE)
									lRet := .F.
								EndIf							
							Else
								If lMV_EmViag .And. aFilOri[5] <> 3 .And. !TMSEmViag(M->DTR_FILORI, M->DTR_VIAGEM, aMotViag[nX][2][nZ][nPosCodMot], 2, .T.)
									lRet := .F.
								EndIf
							EndIf
							
							If !lContVei .And. lMVTMSAloc .And. !aMotPlanej( M->DTR_FILORI, M->DTR_VIAGEM, aMotViag[nX][2][nZ][nPosCodMot], {M->DTR_DATINI, M->DTR_HORINI, M->DTR_DATFIM, M->DTR_HORFIM} )
								lRet := .F.
							EndIf
							
							If lRet							
								DA4->(DbSetOrder(1)) //DA4_FILIAL+DA4_COD
								If DA4->(DbSeek(xFilial("DA4") + aMotViag[nX][2][nZ][nPosCodMot]))
									dDataIni := If(!Empty(M->DTR_DATINI),M->DTR_DATINI,dDataBase)
									dDataFim := If(!Empty(M->DTR_DATFIM),M->DTR_DATFIM,dDataBase)
									
									lRet := TMSVldFunc(DA4->DA4_MAT, DA4->DA4_FILBAS, dDataIni, dDataFim)
								EndIf
							EndIf
							
						EndIf
					Next
				EndIf
			EndIf
		EndIf
	Next
EndIf

If lRet .And. nOpcx != 5 .And. !lContVei
	For nA := 1 To Len( aCols )
		If !GDDeleted( nA )
			lVldVeic:= .T.

			If lTabDL9					
				If GDFieldGet( "DTR_CODVEI", nA ) <> cVeiGen .OR. GDFieldGet( "DTR_CODRB1", nA ) <> cVeiGen;
				 .OR. GDFieldGet( "DTR_CODRB2", nA ) <> cVeiGen .OR. GDFieldGet( "DTR_CODRB3", nA ) <> cVeiGen
									
					DF8->(DbSetOrder(2))
					If DF8->(DbSeek( xFilial('DF8') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))
						aAdd(aVeic, GDFieldGet( "DTR_CODVEI", nA ))
						aAdd(aVeic, GDFieldGet( "DTR_CODRB1", nA ))
						aAdd(aVeic, GDFieldGet( "DTR_CODRB2", nA ))
						aAdd(aVeic, GDFieldGet( "DTR_CODRB3", nA ))

						// Função que valida se veículo e/ou reboques estão sendo utilizados em outro planejamento, programação ou viagem
						lRet := TMSVldVei( DF8->DF8_PLNDMD, DF8->DF8_NUMPRG, IIF( !Empty(DTQ->DTQ_VIAGEM),DTQ->DTQ_VIAGEM, DF8->DF8_VIAGEM ), DF8->DF8_DATINI, DF8->DF8_HORINI, DF8->DF8_DATFIM, DF8->DF8_HORFIM, aVeic )
						lVldVeic:= .F.   
					EndIf
				EndIf
			EndIf

			If lVldVeic
				//-- Veiculo
				If GDFieldGet( "DTR_CODVEI", nA ) <> cVeiGen
					lRet := Tmsa240DtVld( GDFieldGet( "DTR_CODVEI", nA ), STR0047 )		//"Veiculo" 
					
				EndIf
				//-- 1o Reboque
				If lRet .And. !Empty( GDFieldGet( "DTR_CODRB1", nA ) )
					If GDFieldGet( "DTR_CODRB1", nA ) <> cVeigen
						lRet := Tmsa240DtVld( GDFieldGet( "DTR_CODRB1", nA ), STR0048 )	//"1o Reboque"
						If lRet
							lRet := Tmsa240DtVld( GDFieldGet( "DTR_CODRB1", nA ), STR0048 )	//"Verifica se 1o Reboque esta sendo utilizado como 2o Reboque em outra viagem."
						EndIf
					Endif
				EndIf
				//-- 2o Reboque
				If lRet .And. !Empty( GDFieldGet( "DTR_CODRB2", nA ) )
					If GDFieldGet( "DTR_CODRB2", nA ) <> cVeiGen
						lRet := Tmsa240DtVld( GDFieldGet( "DTR_CODRB2", nA ), STR0049 )	//"2o Reboque"
						If lRet
							lRet := Tmsa240DtVld( GDFieldGet( "DTR_CODRB2", nA ), STR0049 )	//"Verifica se 2o Reboque esta sendo utilizado como 1o Reboque em outra viagem."					
						EndIf
					EndIf
				EndIf
				//-- 3o Reboque
				If lTercRbq .And. lRet .And. !Empty( GDFieldGet( "DTR_CODRB3", nA ) )
					If GDFieldGet( "DTR_CODRB3", nA ) <> cVeiGen
						lRet := Tmsa240DtVld( GDFieldGet( "DTR_CODRB3", nA ), STR0049 )	//"3o Reboque"
						If lRet
							lRet := Tmsa240DtVld( GDFieldGet( "DTR_CODRB3", nA ), STR0049 ) //"Verifica se 3o Reboque esta sendo utilizado como 1o Reboque em outra viagem."					
						EndIf
					EndIf
				EndIf 
			EndIf

			If !lRet
				Exit
			EndIf
		EndIf
	Next nA
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VALIDA O ID DO MOTORISTA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. (nOpcx == 3 .Or. nOpcx == 4) .And. cTMSOPdg <> '0'.And. !(cVsRepom $ '2|2.2')
	If Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_IDOPE" }) > 0 .And. !Empty(M->DTR_CODOPE)
		For nA := 1 To Len(aCols)
			If !aCols[nA,Len(aHeader)+1]
				nX := aScan(aMotViag,{|x| x[1] == GDFieldGet('DTR_ITEM',nA)}) //-- Verifica se foi informado Motorista para o Item
				If nX > 0
					For nZ := 1 to Len(aMotViag[nX][2])
						If lMotAux
							cCondut := aMotViag[nX][2][nZ][Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_CONDUT" })]
						Else
    						cCondut := "1"
						EndIf

						If !aMotViag[nX][2][nZ][Len(aMotViag[nX][2][nZ])] //-- Verifica se a linha esta deletada
							//se o parametro que obriga informar o motorista principal e auxiliar esta habilitado e
							//se o motorista e o auxiliar, e o id do cartao esta em branco, nao valido na operadora
							If lMotAux .And. cCondut == "2" //.And. Empty(aMotViag[nX][2][nZ][Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_IDOPE" })]) 
								lValMot := .F.
							Else
								lValMot := .T.
							EndIf
							
							If lValMot
								If !Empty(aMotViag[nX][2][nZ][Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_IDOPE" })]) //-- Verifica se foi informado o N.o do Cartao para o Motorista
									CursorWait()
									//-- Validando Id do Motorista
									MsgRun( STR0055 + aMotViag[nX][2][nZ][nPosNomMot],;
									STR0054,;
									{||lRet := TMS240VlId(	M->DTR_CODOPE,;
									AllTrim(aMotViag[nX][2][nZ][nPosIdOpe]),;
									AllTrim(aMotViag[nX][2][nZ][nPosTipMot]),;
									AllTrim(aMotViag[nX][2][nZ][nPosCodMot]))})  
									CursorArrow()
								ElseIf aMotViag[nX][2][nZ][Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_FORPAG" })] <> '2'
									If M->DTR_CODOPE == '02' .And. lTabDLD .And. Len(aPagtoVge) > 0 //Pamcard
										lRet:= .T.
									Else
										Help('',1,'TMSA24046') //-- Id. do Motorista não Informado!
										lRet:= .F.
									EndIf
								EndIf
							EndIf
							
							If !lRet
								Exit
							EndIf
							
						EndIf
					Next
				EndIf
			EndIf
			
			If !lRet
				Exit
			EndIf
			
		Next
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VALIDA ABERTURA CONTRATO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. (nOpcx == 3 .Or. nOpcx == 4) .And. cVsRepom == '2' .And. cTMSOPdg <> '0' .And. M->DTR_CODOPE == '01'
	For nA := 1 To Len(aCols)
		If !aCols[nA,Len(aHeader)+1]
			nX := aScan(aMotViag,{|x| x[1] == GDFieldGet('DTR_ITEM',nA)}) //-- Verifica se foi informado Motorista para o Item
			If nX > 0
				For nZ := 1 to Len(aMotViag[nX][2])
					If lMotAux
						cCondut := aMotViag[nX][2][nZ][Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_CONDUT" })]
					Else
   						cCondut := "1"
					EndIf

					If !aMotViag[nX][2][nZ][Len(aMotViag[nX][2][nZ])] //-- Verifica se a linha esta deletada
						//se o parametro que obriga informar o motorista principal e auxiliar esta habilitado e
						//se o motorista e o auxiliar, e o id do cartao esta em branco, nao valido na operadora
						If lMotAux .And. cCondut == "2" //.And. Empty(aMotViag[nX][2][nZ][Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_IDOPE" })]) 
							lValMot := .F.
						Else
							lValMot := .T.
						EndIf
							
						If lValMot .And. !Empty(aMotViag[nX][2][nZ][Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_IDOPE" })]) //-- Verifica se foi informado o N.o do Cartao para o Motorista

							If !Empty(GdFieldGet("DTR_CODRB3",nA))
								cCodRebq:= GdFieldGet("DTR_CODRB3",nA)
							ElseIf !Empty(GdFieldGet("DTR_CODRB2",nA))
								cCodRebq:= GdFieldGet("DTR_CODRB2",nA)
							Else
								cCodRebq:= GdFieldGet("DTR_CODRB1",nA)
							EndIf	

							CursorWait()
							nAdtoAux := GdFieldGet("DTR_VALFRE",nA) * GdFieldGet("DTR_PERADI",nA)
							iif(nAdtoAux > 0, nAdtoAux := nAdtoAux / 100, nAdtoAux := 0 )
							MsgRun( STR0065,;
							'',;
							{||lRet := TMS240VlAb(	M->DTR_CODOPE,;
							AllTrim(aMotViag[nX][2][nZ][nPosIdOpe]),;
							AllTrim(aMotViag[nX][2][nZ][nPosTipMot]),;
							GdFieldGet("DTR_CODVEI",nA),;
							AllTrim(aMotViag[nX][2][nZ][nPosCodMot]),;
							cCodRebq,;  
							GdFieldGet("DTR_VALFRE",nA),; 
					    	nAdtoAux,;
					   		Iif(lTipCrg,M->DTR_TIPCRG,'1')   )})
							CursorArrow()
						ElseIf lValMot
							Help('',1,'TMSA24046') //-- Id. do Motorista não Informado!
							lRet := .F.
						EndIf
						
						If !lRet
							Exit
						EndIf
						
					EndIf
				Next
			EndIf
			
		EndIf			                                               
	Next
EndIf               

//-- Verifica o calculo do Pedagio X Operadora de Frotas
If lRet .And. (cTMSOPdg <> '0' .And. (nOpcx == 3 .Or. nOpcx == 4))
	For nA := 1 To Len(aCols)
		If !aCols[nA,Len(aHeader)+1]
			AAdd(aVeiculos, {	GDFieldGet("DTR_CODVEI",nA),;
								GdFieldGet("DTR_QTDEIX",nA),;
								GdFieldGet("DTR_QTEIXV",nA) })
			If lRepom 
				If !Empty(GDFieldGet("DTR_CODRB1",nA))
					AAdd(aVeiculos, { GDFieldGet("DTR_CODRB1",nA), 0, 0 })
				EndIf
				
				If !Empty(GDFieldGet("DTR_CODRB2",nA))
					AAdd(aVeiculos, { GDFieldGet("DTR_CODRB2",nA), 0, 0 })
				EndIf
				If lTercRbq
					If !Empty(GDFieldGet("DTR_CODRB3",nA))
						AAdd(aVeiculos, { GDFieldGet("DTR_CODRB3",nA), 0, 0 })
					EndIf
				EndIf    
			EndIf
			lRet := aCalFreCar(aVeiculos,.T.,lCalPedg,nA,,nOpcx)   //Parametro ".F." para nao atualizar o valor do frete na aCols.
			aVeiculos := {}
			If !lRet
				Exit
			EndIf
		EndIf
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando for utilizada Operadoras de Frota/Vale-Pedagio,³
//³atualiza os dados da base de dados da Operadora.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. FunName() == 'TMSA240' .And. (nOpcx == 3 .Or. nOpcx == 4) .And. cTMSOPdg <> '0'
	For nA := 1 To Len(aCols)
		If !aCols[nA,Len(aHeader)+1]
			nX := aScan(aMotViag,{|x| x[1] == GDFieldGet('DTR_ITEM',nA)}) //-- Verifica se foi informado Motorista para o Item
			If nX > 0
				For nZ := 1 to Len(aMotViag[nX][2])
					If !aMotViag[nX][2][nZ][Len(aMotViag[nX][2][nZ])] //-- Verifica se a linha esta deletada
						cCodVei := aCols[nA][nPosCodVei]
						cCodMot := aMotViag[nX][2][nZ][nPosCodMot]
						cCodRbq1:= aCols[nA][nPosCodRb1]
						cCodRbq2:= aCols[nA][nPosCodRb2]
						cCodRbq3:= aCols[nA][nPosCodRb3]

						If ExistFunc('RepRetCod')
							RepRetCod(cCodVei, cCodRbq1, cCodRbq2, cCodRbq3, cCodMot, @aCodigos)
						Else
							lRet:= .F.
							Exit
						EndIf	

					EndIf
				Next

				If !lRet
					Help( ,, 'HELP',, 'Favor atualizar o Fonte TMSREPOM.PRW !' , 1, 0)	
				Else
					CursorWait()
					MsgRun( STR0059, STR0058, {||  lRet := TMSAtualOp( M->DTR_CODOPE, '5', aCodigos )}) //-- "Aguarde comunicação com a Operadora..."##"Atualizando dados da Operadora. Por favor Aguarde..."
					CursorArrow()
				EndIf	
			EndIf
		EndIf
	Next
EndIf

If lRet .And. M->DTR_CODOPE == '02' 
	If ExistFunc('PamQtDocVg') 
		If PamQtDocVg(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_SERTMS) == 1
			lUmDocVge:= .T.						
		EndIf
	EndIf		

	For nCount := 1 To Len(aCols)
		lFrotaProp := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODVEI",nCount)),"DA3_FROVEI") == '1' //Verifica se eh frota própria

		//---- Verifica se a viagem é do Tipo Lotacao (um único CTE na Viagem)
		lLotacao:= .F.
		If lFrotaProp .And. lUmDocVge
			lLotacao:= .T.						
		EndIf

		If !lFrotaProp
			cCodForn := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODVEI",nCount)),"DA3_CODFOR")
			cLojaForn := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODVEI",nCount)),"DA3_LOJFOR")
			SA2->(dbSetOrder(1))
			If SA2->(MsSeek(xFilial('SA2')+cCodForn+cLojaForn))
				If (SA2->A2_TIPO == 'J')
					If !MsgYesNo(STR0066 + Chr(10) + Chr(13) + STR0067 )	//--''Integração com PAMCARD não é obrigatória quando o proprietário do veículo é Pessoa Jurídica!'';'Desejar efetuar a integração mesmo assim?'
						lRet := .F.
						Exit
					EndIf	
				EndIf	
			Else
				Help("",1,"TMSA24067" )//--O Proprietário do veículo não foi encontrado no cadastro de Fornecedores!	
			EndIf			                          	
			If lRet 
				lRet := PamFdRNTRC(cCodForn, cLojaForn)
			EndIf	
			
			If !Empty(GdFieldGet("DTR_CODRB1",nCount)) .And. lRet				
				cCodFor := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODRB1",nCount)),"DA3_CODFOR")
				cLojaFor := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODRB1",nCount)),"DA3_LOJFOR")
				lRet := PamFdRNTRC(cCodForn, cLojaForn)
					
				If !Empty(GdFieldGet("DTR_CODRB2",nCount)) .And. lRet
					cCodFor := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODRB2",nCount)),"DA3_CODFOR")
					cLojaFor := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODRB2",nCount)),"DA3_LOJFOR")
					lRet := PamFdRNTRC(cCodForn, cLojaForn)
				EndIf
				
				If lTercRbq .And. !Empty(GdFieldGet("DTR_CODRB3",nCount)) .And. lRet
					cCodFor := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODRB3",nCount)),"DA3_CODFOR")
					cLojaFor := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODRB3",nCount)),"DA3_LOJFOR")
					lRet := PamFdRNTRC(cCodForn, cLojaForn)
				EndIf 
			EndIf
			
			If !lRet
				Help("",1,"TMSA24065") //'RNTRC Inválido no Sistema Pamcard!!!'
			EndIf	
			
		EndIf
		
		If lRet .And. !Empty(GdFieldGet("DTR_VALPDG",nCount))
			
			cIdOpe  := aMotViag[1][2][nCount][nPosIdOpe]
			If aMotViag[1][2][nCount][nPosForPag] == '1' .Or. aMotViag[1][2][nCount][nPosForAdt] == '1'   //Cartao
				lCartao:= .T.
			EndIf	

			If lTabDLD //Se o DUP_IDOPE esta em branco indica q houve alteração na Formas de pagamento, neste caso valida os dados da DLD
				nPosDLD := Ascan(aPagtoVge, {|x|  x[1]+x[2] == GdFieldGet("DTR_ITEM",nCount) + GdFieldGet("DTR_CODVEI",nCount) })
				If nPosDLD > 0 .And. Empty(cIdOpe) 
					For nY:= 1 to Len(aPagtoVge[nPosDLD][3])
						If !Empty(aPagtoVge[nPosDLD] [3] [nY] [Ascan(aHeaderDLD,{|x| x[2] = 'DLD_IDOPE'})] )
							cIdOpe  := aPagtoVge[nPosDLD] [3] [nY] [Ascan(aHeaderDLD,{|x| x[2] = 'DLD_IDOPE'})]
						EndIf

						If aPagtoVge[nPosDLD] [3] [nY] [Ascan(aHeaderDLD,{|x| x[2] = 'DLD_FORPAG'})] == '1'  //Cartão
							lCartao:= .T.
						EndIf
					Next nY	
				EndIf	
			EndIf

			If !lLotacao   //Quando Lotacao, dados do cartao nao é Obrigatorio
				If !lCartao 
					Help( ' ', 1, 'TMSA240A4') //A forma de pagamento da parcela de pedagio deve ser Cartão.
					lRet:= .F.
				EndIf

				If lRet .And. Empty(cIdOpe) 
					Help('', 1, "TMSA24064") //'Viagem com valor de pedágio.', 'Informe um Cartão para o motorista!!'
					lRet := .F.
				EndIf
			EndIf	
		EndIf

		If lRet .And. AliasInDic("DJL") .And. DTR->(ColumnPos("DTR_TPCIOT")) > 0 .And. GdFieldGet("DTR_TPCIOT",nCount) != "2"
			cQuery := " SELECT DJL_CIOT," 
			cQuery += "        DJL_CODVEI, "
			cQuery += "        DJL_DATINI, "
			cQuery += "        DJL_DATFIM, "
			cQuery += "        DJL_STATUS  "
			cQuery += " FROM " + RetSqlName("DJL") 
			cQuery += " WHERE  DJL_CODVEI = '"+GdFieldGet("DTR_CODVEI",nCount)+"'" 
			cQuery += " AND    DJL_STATUS = '"+StrZero(1,Len(DJL->DJL_STATUS))+"'" 
			cQuery += " AND    DJL_DATINI <= '"+DtoS(dDataBase)+"'" 
			cQuery += " AND    DJL_DATFIM >= '"+DtoS(dDataBase)+"'" 
			cQuery += " AND    DJL_FILIAL = '" +xFilial("DJL") +"'"
			cQuery += " AND    D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			
			cAliasQry := GetNextAlias()
			aAreaAux := GetArea()
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			If (cAliasQry)->(!Eof() .And. !Empty((cAliasQry)->DJL_CIOT))
				Help('',1,"TMSA24089") //-- "O veículo possui CIOT por período em Aberto. Não é possível gerar CIOT por viagem"
				lRet:= .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
			RestArea(aAreaAux)
		EndIf		

		//---- Verifica se informado DUP_IDOPE e DLD. Se nao informado, é permitido quando DUP_FORPAG e DUP_FORADT serem do tipo 'Deposito'
		If lRet  
			If lTabDLD .And. (!Empty(aMotViag[1][2][nCount][nPosIdOpe]) .Or. ;
				Empty(GdFieldGet("DTR_VALPDG",nCount)) .And. aMotViag[1][2][nCount][nPosForPag]='2' .And. aMotViag[1][2][nCount][nPosForAdt] ='2' )
					lDUPIdOpe:= .T.
			EndIf
		EndIf
	Next nCount
	
	If lRet 
		If lTipCrg .And. Empty(M->DTR_TIPCRG)
			Help('', 1, "TMSA24066") //'Informe o Tipo de Carga,' '1=Lotacao; 2=Fracionada!!!'
			lRet := .F.
		EndIf
		//--- Verifica se foi informado o cartao do motorista, devido a retirada da obrigatoriedade do DUP_IDOPE
		If lRet 
			If lTabDLD .And. Len(aPagtoVge) == 0  .And. !lDUPIdOpe  
				Help('',1,'TMSA24046') //-- Id. do Motorista não Informado!
				lRet:= .F.
			EndIf	
		EndIf
	EndIf

EndIf

If lRet .And. !Empty( M->DTR_CODOPE )  
	DEG->(DbSetOrder(1)) //-- DEG_FILIAL+DEG_CODOPE
	If lRet .And. DEG->(MsSeek(xFilial('DEG')+M->DTR_CODOPE))
		//-- Valida SDG que movimenta banco contra o banco do cadastro da operadora
		For nCount := 1 to Len(aAdtoViag)
			//-- Se encontrar despesa em bco que não seja da operadora, exibe alerta pois não irá transmitir adto de outro bco
			If lRet .And.;
			   aScan(aAdtoViag[nCount][2],{|x|  ; 	
					!x[Len(aHeaderSDG)+ 1] .And. ;
					( !Empty(x[GdFieldPos("DG_BANCO",aHeaderSDG)])) .And.   ;
					(x[GdFieldPos("DG_BANCO",aHeaderSDG)]              + ;
					 x[GdFieldPos("DG_AGENCIA",aHeaderSDG)]            + ;
					 x[GdFieldPos("DG_NUMCON",aHeaderSDG)]) <>           ; 
					DEG->(DEG_BANCO+DEG_AGENCI+DEG_NUMCON)}) > 0

				Help("",1,"TMSA24084") //-- "Existe despesa apontada em Banco/Ag/Cta divergente ao da Operadora."
				lRet := .F.
				Exit
			EndIf
		Next nCount
	EndIf
EndIf

//-- Executa Ponto de Entrada no Final da TudoOK
If lRet .And. lTM240TudOK
	lRet := ExecBlock('TM240TUDOK',.F.,.F.,{nOpcx})
	If ValType(lRet) # "L"
		lRet :=.F.
	EndIf
EndIf

RestArea(aAreaDF8) 

Return( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA240Mot³ Autor ³Patricia A. Salomao   ³ Data ³23.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Motoristas da Viagem                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA240Mot(ExpC1, ExpC2, ExpC3)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao Selecionada                                  ³±±
±±³          ³ ExpC1 - Numero da Liberacao do Veiculo (DTU)               ³±±
±±³          ³ ExpL1 - Verifica se mostra ou nao a GetDados               ³±±
±±³          ³ ExpL2 - Carrega motorista do cadastro de veiculos .T./.F.  ³±±
±±³          ³ ExpA1 = Documentos                                         ³±±
±±³          ³ ExpA2 = Posicao dos campos referente aos documentos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA240Mot(nOpcx, cNumLiber, lMostraGet, lLoadDrv, aDoctos, aPosicao, lAutoMot, lTrocaMot, aMotPrg)

Local oDlg,oGetDados,nCntFor
Local nOpc         := 0
Local nPosVei      := 0
Local nPosMot      := 0
Local aSavaRotina  := aClone(aRotina)
Local l240Visual   := .F.
Local lContVei     := GetMV('MV_CONTVEI',,.T.) // Parametro para verificar se o sistema devera' controlar veiculo/motorista
Local cNoFields    := ''
Local aButtons     := {}
Local aAlter  	   := {}
Local aSetKeyOld   := aClone(aSetKey)
Local lVldFunc     := .T.
Local aArea        := GetArea()
Local aAreaDA4     := DA4->( GetArea() )
//-- Operadoras de Frota/Vale-Pedagio
Local cTMSOPdg    := SuperGetMV( 'MV_TMSOPDG',, '0' )
Local nMaxLin     := 99
Local cMV_TMSRRE  := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
Local lTabRRE     := "3" $ cMV_TMSRRE 

Local dDataIni    := If(!Empty(M->DTR_DATINI),M->DTR_DATINI,dDataBase)
Local dDataFim    := If(!Empty(M->DTR_DATFIM),M->DTR_DATFIM,dDataBase)

Local lDTRTPSPDG 	  := DTR->(ColumnPos("DTR_TPSPDG")) > 0
Local lProgram	  := IsInCallStack('TMSA146Eft') 
Local lTabDLS	  := TableInDic('DLS')
Local nY		  := 0
Local x	          := 0
Local lTransito	:= .F.

Default aDoctos   := {}
Default aPosicao  := {}
Default lAutoMot  := .F.
Default lTrocaMot := IsInCallStack('TmsA144TRM') .OR. IsInCallStack('TmsA141TRM')
Default aMotPrg    := {}

Private nSavN      := n
Private cDTR_ITEM  := Iif(lAutoMot,,GdFieldGet('DTR_ITEM',n))
Private nPosItem   := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTR_ITEM" })
Private aSavCols   := aClone(aCols)
Private aSavHeader := aClone(aHeader)

Default cNumLiber  :=  ""
Default lMostraGet :=  .T.
Default lLoadDrv   :=  .F.//carrega motorista do cadastro de motorista


nPosVei := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTR_CODVEI" })
nPosMot := Ascan(aMotViag,{|x| x[1] == cDTR_ITEM })

If lContVei
	//-- Quando a Viagem por planejada, trata como se o controle de veiculos estivesse desligado.
	TMSA240Off( @lContVei, .F. )
EndIf

//-- Finaliza as Teclas de Atalhos
TmsKeyOff(aSetKey)

If nOpcx == 2 .Or. nOpcx == 5
	l240Visual := .T.
Else
	Aadd(aSetKey, { VK_F4 , {|| TMSMotLib(M->DTR_FILORI, M->DTR_VIAGEM,,,,aDoctos,aPosicao,@oGetDados) } } )
	AAdd(aButtons , {'BMPUSER',{||TMSMotLib(M->DTR_FILORI, M->DTR_VIAGEM,,,,aDoctos,aPosicao,@oGetDados )}, STR0050 , STR0053 }) //"Motoristas Liberados"
EndIf

If lTabRRE
	Aadd(aButtons, {'RELOAD',{||TA240Segur(nOpcx,M->DTR_FILORI, M->DTR_VIAGEM, "DA4", Iif(!GDDeleted( n ),GDFieldGet("DUP_CODMOT",n),'')) }, STR0075,STR0075 } ) //Lib.Seguro
EndIf
If !lAutoMot .And. !Empty(M->DTR_FILVGE+M->DTR_NUMVGE)
	l240Visual := .T.
EndIf
If nOpcx == 4
	lTransito	:= DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS))
	If lTransito .AND. !lTrocaMot
		l240Visual := .T.
	EndIf
EndIf
n       := 1
aCols   := {}
aHeader := {}
aRotina[2][4] := 2
aRotina[3][4] := 3
If lContVei
	cNoFields := 'DUP_FILORI.DUP_VIAGEM.DUP_ITEDTR.DUP_CODVEI.DUP_LIBSEG.DUP_VALSEG'
Else
	cNoFields := 'DUP_FILORI.DUP_VIAGEM.DUP_ITEDTR.DUP_CODVEI'
EndIf

//-- Tratamento para Operadoras de Frota / Vale-Pedagio
cNoFields += '.DUP_CODOPE.DUP_NOMOPE'
If cTMSOPdg == '0'
	cNoFields += '.DUP_FORPAG.DUP_TPSPDG'
EndIf

If lDTRTPSPDG
	aAlter := ({'DUP_CODMOT','DUP_TIPMOT','DUP_LIBSEG','DUP_VALSEG','DUP_IDOPE','DUP_CONDUT','DUP_FORPAG','DUP_FORADT','DUP_PAGDIA'})

	If M->DTR_CODOPE = '02' //Pamcard, verifica se permite ou nao alteração do campo DUP_IDOPE. Uma vez confirmado a tela de Formas de pagamento, nao sera permitido edicao do campo
		If Len(aPagtoVge) > 0 .And. (Empty(TMSIDPAM(M->DTR_FILORI, M->DTR_VIAGEM,,.T.)) .Or. Empty(TmDUDIdOpe(M->DTR_ITEM,M->DTR_CODVEI,.F.)) )
			aAlter := ({'DUP_CODMOT','DUP_TIPMOT','DUP_LIBSEG','DUP_VALSEG','DUP_CONDUT'})		
		EndIf
	EndIf
Else
	aAlter := ({'DUP_CODMOT','DUP_TIPMOT','DUP_LIBSEG','DUP_VALSEG','DUP_IDOPE','DUP_CONDUT','DUP_FORPAG','DUP_QTDSAQ','DUP_TPSPDG','DUP_QTDTRA','DUP_FORADT','DUP_PAGDIA'})
EndIf

If lTmsA2402
	aAlter := ExecBlock('TMSA2402',.F.,.F.,aAlter)
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aHeaderDUP) == 0
	aHeader := ApBuildHeader("DUP", Strtokarr2( cNoFields, "."))

	aHeaderDUP := Aclone(aHeader)
Else
	aHeader := Aclone(aHeaderDUP)
EndIf

If	nPosMot > 0
	If Empty(cNumLiber)
		aCols := aClone(aMotViag[nPosMot][2])
	Else
		aCols := {}
		aMotViag[nPosMot][2] := aClone(aCols)
	EndIf
EndIf

// So' verifica os motoristas liberados, se o parametro MV_CONTVEI for igual a .T.
If lContVei .And. !Empty(cNumLiber)
	
	//-- Desconsidera o Motorista, se o mesmo ja estiver sendo utilizado nesta viagem
	DTO->(dbSetOrder(4))
	DTO->(MsSeek(xFilial('DTO')+cNumLiber+'2'))
	Do While !DTO->(Eof()) .And. DTO->(DTO_FILIAL+DTO_NUMLIB+DTO_STATUS) == xFilial('DTO')+cNumLiber+'2'
		//--Valida o Motorista X Integracao GPE
		DA4->( DbSetOrder(1) )
		If DA4->( DbSeek( xFilial('DA4') + DTO->DTO_CODMOT ) )
			lVldFunc := TMSVldFunc( DA4->DA4_MAT, DA4->DA4_FILBAS, dDataIni, dDataFim )
		Else
			lVldFunc := .F.
		EndIf
		
		If !TMSA240Ver("1", DTO->DTO_CODMOT, aMotViag, .F.) .Or. !lVldFunc
			DTO->(dbSkip())
			Loop
		EndIf
		AAdd(aCols,Array(Len(aHeader)+1))
		For nCntFor := 1 To Len(aHeader)
			aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
		Next
		aCols[Len(aCols), GdFieldPos("DUP_CODMOT")] := DTO->DTO_CODMOT
		aCols[Len(aCols), GdFieldPos("DUP_NOMMOT")] := Posicione("DA4",1,xFilial("DA4")+DTO->DTO_CODMOT,"DA4_NOME")
		aCols[Len(aCols), GdFieldPos("DUP_TIPMOT")] := DA4->DA4_TIPMOT
		
		If GDFieldPos('DUP_CONDUT') > 0
			aCols[Len(aCols), GdFieldPos("DUP_CONDUT")] := '1'
		EndIf
				
		If cTMSOPdg <> '0' .And. GDFieldPos('DUP_IDOPE') > 0
			DEL->( DbSetOrder(2) )
			If DEL->( MsSeek(xFilial('DEL') + DTO->DTO_CODMOT + M->DTR_CODOPE ))
				aCols[Len(aCols), GDFieldPos('DUP_IDOPE')] := DEL->DEL_IDOPE
			EndIf
		EndIf
		aCols[Len(aCols),Len(aHeader)+1] := .F.
		DTO->(dbSkip())
	EndDo
ElseIf lLoadDrv .And. !Empty(DA3->DA3_MOTORI)
	aCols := {}
	If	nPosMot > 0
		aMotViag[nPosMot][2] := {}
	EndIf
	DA4->( DbSetOrder(1) )
	DA4->( MsSeek(xFilial("DA4") + DA3->DA3_MOTORI, .F. ))
	If DA4->DA4_BLQMOT == StrZero(2,Len(DA4->DA4_BLQMOT))
		If TMSA240Ver("1", DA3->DA3_MOTORI, aMotViag, .F.) .And. TMSVldFunc( DA4->DA4_MAT, DA4->DA4_FILBAS, dDataIni, dDataFim )
			nRecDA4 := DA4->(Recno())
			nRecDA3 := DA3->(Recno())
			AAdd(aCols,Array(Len(aHeader)+1))
			For nCntFor := 1 To Len(aHeader)
				aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
			Next
			DA4->(dbGoTo(nRecDA4))
			DA3->(dbGoTo(nRecDA3))
			aCols[Len(aCols), GdFieldPos("DUP_CODMOT")] := DA3->DA3_MOTORI
			aCols[Len(aCols), GdFieldPos("DUP_NOMMOT")] := DA4->DA4_NOME
			aCols[Len(aCols), GdFieldPos("DUP_TIPMOT")] := DA4->DA4_TIPMOT

			If GDFieldPos('DUP_CONDUT') > 0
				aCols[Len(aCols), GdFieldPos("DUP_CONDUT")] := '1'
			EndIf

			If cTMSOPdg <> '0' .And. GDFieldPos('DUP_IDOPE') > 0
				DEL->( DbSetOrder(2) )
				If !lAutoMot .And. DEL->( MsSeek(xFilial('DEL') + DA3->DA3_MOTORI + M->DTR_CODOPE ))
					aCols[Len(aCols), GDFieldPos('DUP_IDOPE')] := DEL->DEL_IDOPE
				ElseIf AliasIndic('DDQ')
					DDQ->(dbSetOrder(2))
					If DDQ->( MsSeek(xFilial('DDQ') + DA3->DA3_CODFOR+ DA3->DA3_LOJFOR ))
						aCols[Len(aCols), GDFieldPos('DUP_IDOPE')] := DDQ->DDQ_IDCART
					EndIf
				EndIf
			EndIf
			aCols[Len(aCols),Len(aHeader)+1] := .F.
		EndIf
	Else
		Help( ' ', 1, 'TMSA24053', , STR0051 + ":" + DA3->DA3_MOTORI + " - " + DA4->DA4_NOME, 4, 1 ) //-- O motorista que esta vinculado ao veiculo esta bloqueado.
	EndIf
ElseIf lProgram .And. lTabDLS //--Montagem do acols do Motorista da tabela DLS para DUP
	If nOpcx == 3
		aCols := {}
		If	nPosMot > 0		
			aMotViag[nPosMot][2] := {}
		EndIf
		DA4->( DbSetOrder(1) )		
		For nY := 1 To Len(aMotPrg)
			If !Empty(aMotPrg[nY][1][6]) .AND. DA4->( MsSeek(xFilial("DA4") + aMotPrg[nY][1][6], .F. ))
                If DA4->DA4_BLQMOT == StrZero(2,Len(DA4->DA4_BLQMOT))
                    If TMSA240Ver("1", aMotPrg[nY][1][6], aMotViag, .F.) .And. TMSVldFunc( DA4->DA4_MAT, DA4->DA4_FILBAS, dDataIni, dDataFim )
                        nRecDA4 := DA4->(Recno())
                        nRecDA3 := DA3->(Recno())
                        AAdd(aCols,Array(Len(aHeader)+1))
                        For nCntFor := 1 To Len(aHeader)
                            aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
                        Next
                        DA4->(dbGoTo(nRecDA4))
                        DA3->(dbGoTo(nRecDA3))
                        aCols[Len(aCols), GdFieldPos("DUP_CODMOT")] := aMotPrg[nY][1][6]
                        aCols[Len(aCols), GdFieldPos("DUP_NOMMOT")] := DA4->DA4_NOME 
                        aCols[Len(aCols), GdFieldPos("DUP_TIPMOT")] := DA4->DA4_TIPMOT
                        
                        cCondut := aMotPrg[nY][1][8]//--Condutor				
                        If GDFieldPos('DUP_CONDUT') > 0 .And. aMotPrg[nY][1][8] == '1' //--Se for Condutor Principal
                            aCols[Len(aCols), GdFieldPos("DUP_CONDUT")] := cCondut //--Principal
                        Else
                            aCols[Len(aCols), GdFieldPos("DUP_CONDUT")] := cCondut //--Auxiliar
                        EndIf
                        
                        If !Empty(aMotPrg[nY][1][9])//Meio de pag. ADTO
                            aCols[Len(aCols), GdFieldPos("DUP_FORADT")] := aMotPrg[nY][1][9]
                        EndIf
                        
                        If !Empty(aMotPrg[nY][1][11])//Meio de pag. frete 
                            aCols[Len(aCols), GdFieldPos("DUP_FORPAG")] := aMotPrg[nY][1][11]
                        EndIf				
                        
                        If !Empty(aMotPrg[nY][1][12])//Quantidade Transferencia
                            aCols[Len(aCols), GdFieldPos("DUP_QTDTRA")] := aMotPrg[nY][1][12]	
                        EndIf				
                        
                        If cTMSOPdg <> '0' .And. GDFieldPos('DUP_IDOPE') > 0
                            DEL->( DbSetOrder(2) )
                            If !lAutoMot .And. DEL->( MsSeek(xFilial('DEL') + aMotPrg[nY][1][6] + M->DTR_CODOPE ))
                                aCols[Len(aCols), GDFieldPos('DUP_IDOPE')] := DEL->DEL_IDOPE
                            ElseIf AliasIndic('DDQ')
                                DDQ->(dbSetOrder(2))
                                If DDQ->( MsSeek(xFilial('DDQ') + DA3->DA3_CODFOR+ DA3->DA3_LOJFOR ))
                                    aCols[Len(aCols), GDFieldPos('DUP_IDOPE')] := DDQ->DDQ_IDCART
                                EndIf
                            EndIf
                        EndIf
                        aCols[Len(aCols),Len(aHeader)+1] := .F.
                    EndIf
                Else
                    Help( ' ', 1, 'TMSA24053', , STR0051 + ":" + aMotPrg[nY][1][6] + " - " + DA4->DA4_NOME, 4, 1 ) //-- O motorista que esta vinculado ao veiculo esta bloqueado.
                EndIf
            EndIf
		Next nY
	ElseIf !Empty(aCols)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa os gatilhos                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For x := 1 to Len(aCols)	
			If ExistTrigger("DUP_CODMOT")
				RunTrigger(2,x,NIL,,'DUP_CODMOT')
			EndIf	
		Next x	
	EndIf	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a montagem de uma linha em branco no aCols.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	Empty(aCols)
	AAdd(aCols,Array(Len(aHeader)+1))
	For nCntFor := 1 To Len(aHeader)
		aCols[1,nCntFor] := CriaVar(aHeader[nCntFor,2])
	Next
	aCols[1,Len(aHeader)+1] := .F.
EndIf

If lTrocaMot
   nMaxLin := Len(aCols) + 1
EndIf

If lMostraGet
	//-- Iniciliza as Teclas de Atalhos
	TmsKeyOn(aSetKey)
	DEFINE MSDIALOG oDlg FROM 94 ,15 TO 430,1200 TITLE STR0014 Of oMainWnd PIXEL  //'Motoristas Viagem'
	oGetDados := MSGetDados():New(30,4,160,590,IIF(l240Visual,2,3),'aMotLinOk','AllwaysTrue',,.T.,aAlter,,,nMaxLin,,,,If(l240Visual,"AlwaysFalse",'TMSA240Del(2)'))

	@ 6  ,116 SAY ''		Of oDlg PIXEL SIZE 26 ,9
	@ 18 ,3   SAY STR0007	Of oDlg PIXEL SIZE 56 ,9 //"Viagem : "
	@ 18 ,96  SAY STR0009	Of oDlg PIXEL SIZE 60 ,9 //"Veiculo : "
	@ 18 ,36  SAY M->DTR_FILORI+"/"+M->DTR_VIAGEM	Of oDlg PIXEL SIZE 50 ,9
	@ 18 ,125 SAY aSavCols[nSavN][nPosVei]			Of oDlg PIXEL SIZE 140 ,9

	ACTIVATE MSDIALOG oDlg ON INIT (oGetdados:Refresh(),EnchoiceBar(oDlg, {||Iif(aMotTudOk(Iif(l240Visual,2,3)) ,(nOpc:=1,oDlg:End()),(nOpc:=0))},{||oDlg:End()},,aButtons) )
	//-- Finaliza as Teclas de Atalhos
	TmsKeyOff(aSetKey)
EndIf

If (!lMostraGet) .Or. (nOpc == 1 .And. !l240Visual)
	If nPosMot > 0
		aMotViag[nPosMot][2] := aClone(aCols)
	Else
		AAdd(aMotViag,{aSavCols[nSavN][nPosItem], aClone(aCols)})
	EndIf
EndIf

aRotina := aClone(aSavaRotina)
aHeader := aClone(aSavHeader)
aCols   := aClone(aSavCols)
n       := nSavN
aSetKey := aSetKeyOld

//-- Iniciliza as Teclas de Atalhos
TmsKeyOn(aSetKey)

RestArea( aArea )
RestArea( aAreaDA4 )
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³aMotLinOk  ³ Autor ³Patricia A. Salomao   ³ Data ³23.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da Linha da GetDados de Motoristas da Viagem     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ aMotLinOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function aMotLinOk()

Local lRet       := .T.
Local cCodMot    := ""
Local lMV_EmViag := GetMV("MV_EMVIAG",,.F.) // Utilizado para verificar se o veiculo esta em uso em outra viagem.
Local lContVei   := GetMv("MV_CONTVEI")
Local cRepom     := GetMV("MV_TMSOPDG",,"0")
Local lCondut    := DUP->(FieldPos("DUP_CONDUT")) > 0
Local nPosCondut := Ascan(aHeader, {|x| AllTrim(x[2]) == "DUP_CONDUT" })
Local nCondP     := 0 // Contador de Condutores Principais
Local nCount     := 0
Local aRetCNPJ   := {}
Local aConsCard  := {}
Local nPosChaveO  
Local nLenaMotViag 	:= 0
Local lVldIDOPE     := .T.
Local lTabDLD       := TableInDic('DLD')
Local lDTRTPSPDG    := DTR->(ColumnPos("DTR_TPSPDG")) > 0
Local cInValePdg	:= '4198'
//-- Analisa se ha itens duplicados na GetDados.
If !GdDeleted(n)

	If !MaCheckCols(aHeader,aCols,n)
		Return ( .F. )
	EndIf

	If !GDCheckKey( {'DUP_CODMOT'}, 4 )
		Return ( .F. )
	EndIf

	If lCondut
		If cRepom <> "0"
			If Empty(aCols[n,nPosCondut])
				Help("",1,"GETOBG",,aHeader[nPosCondut][1],2)
				Return ( .F. )
			Else
				For nCount := 1 To Len(aCols)
					If (AllTrim(aCols[nCount,GDFieldPos('DUP_CONDUT')]) == '1') .And. (!aCols[nCount,Len(aHeader)+1])
						nCondP += 1
					EndIf
				Next

				If (nCondP > 1)
					Help('',1,'TMSA24056') //-- Permitido apenas um Condutor Principal por Viagem
					Return ( .F. )
				EndIf
			EndIf
		EndIf
	EndIf

	//-- Verifica se o Motorista esta sendo utilizado em outra viagem.
	//-- Verificacao realizada quando o parametro MV_CONVEI ou o parametro MV_EMVIAG estivem ativos e a viagem
	//-- for diferente de 'Planejada'
	If ( lContVei .Or. lMV_EmViag ) .And. aFilOri[5] <> 3
		If !TMSEmViag(M->DTR_FILORI, M->DTR_VIAGEM, GDFieldGet('DUP_CODMOT',n), 2, .T.)
			lRet := .F.
		EndIf
	EndIf
	
	If lTrocaMot
		nPosChaveO := Ascan(aHeader, {|x|AllTrim(x[2])== 'DUP_CODMOT'})
		If( Len(aMotViag) > 0 ) 
			nLenaMotViag := Len(aMotViag[nsavn][2])
		EndIf
		If n <= nLenaMotViag .And. nLenaMotViag >= 1
	   		If (aCols[n, nPosChaveO] <> aMotViag[nsavn, 2, n, 1])   
	  	 		aCols[n, 1] := aMotViag[nsavn, 2, n, 1]
	  	 		aCols[n, 2] := aMotViag[nsavn, 2, n, 2] 
	  	 		aCols[n, 3] := aMotViag[nsavn, 2, n, 3]  	 
	  	 		Help(' ', 1, 'TMSA24076') //Não é permitido alteração de dados através desta rotina.
	   		EndIf
		EndIf	
   EndIf

	//-- Verifica se o Motorista esta sendo utilizado em outra viagem (Planejada)
	If lRet .And. ( lContVei .Or. lMV_EmViag) .And. aFilOri[5] == 3
		If !aMotPlanej( M->DTR_FILORI, M->DTR_VIAGEM, GDFieldGet('DUP_CODMOT',n), {M->DTR_DATINI, M->DTR_HORINI, M->DTR_DATFIM, M->DTR_HORFIM} )
			lRet := .F.
		EndIf
	EndIf

	If lRet
		cCodMot := GdFieldGet("DUP_CODMOT", n)
		//-- Desconsidera o Motorista, se o mesmo ja estiver sendo utilizado nesta viagem
		lRet := TMSA240Ver("1", cCodMot, aMotViag, .T., aSavCols[nSavN][nPosItem])
	EndIf
	If lRet .And. M->DTR_CODOPE == '02' .And. GDFieldPos('DUP_IDOPE') > 0 .And. (GdFieldGet("DUP_CONDUT", n) == '1')
		If lTabDLD .And. Empty(GdFieldGet("DUP_IDOPE",n))
			lVldIDOPE:= .F. //Permite informar o campo em Branco, quando informado o cartao no Pagamento da Viagem (DLD)
		EndIf

		If lVldIDOPE  
			aRetCNPJ   := PamCNPJEmp(M->DTR_CODOPE, 	M->DTR_FILORI) //Função para obter CNPJ da contrante e filial de origem 
			//-- Montagem Array para Integração com PamCard
			AAdd(aConsCard,{'viagem.contratante.documento.numero',aRetCNPJ[1]})
			AAdd(aConsCard,{'viagem.unidade.documento.tipo'      ,aRetCNPJ[2]})
			AAdd(aConsCard,{'viagem.unidade.documento.numero'    ,aRetCNPJ[3]}) 
			AAdd(aConsCard,{'viagem.cartao.numero',AllTrim(GdFieldGet("DUP_IDOPE",n))} )
			DA4->(DbSetOrder(1))
			If DA4->(MsSeek(xFilial('DA4')+AllTrim(GDFieldGet('DUP_CODMOT',n))) ) .And. cInValePdg <> PADR(GdFieldGet("DUP_IDOPE",n),4)
				lRet := PamFindCar(aConsCard, .T.)
			EndIf
		EndIf
		If lRet .And. Empty(GdFieldGet("DUP_FORPAG", n))
			lRet := .F.
			Help(' ', 1, 'TMSA24068') //É necessário informar o meio de pagamento do frete para integração com Pamcard.//-Informe o campo Meio Pg.Frt.							
		EndIf
		If lRet .And. !lDTRTPSPDG .And. Empty(GdFieldGet("DUP_TPSPDG", n)) 
			lRet := .F.
			Help(' ', 1, 'TMSA24069') //É necessário informar o Tipo do Pagto do Pedágio para integração com Pamcard.//--Informe o campo Tp Pgt Pedag
		EndIf
	EndIf

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³aMotTudOk  ³ Autor ³Patricia A. Salomao   ³ Data ³23.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao Geral da Tela de Motoristas da Viagem             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³aMotTudOk(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function aMotTudOk(nOpcx)
Local nAux
Local lRet        := .T.
Local lMV_EmViag  := GetMV("MV_EMVIAG",,.F.) // Utilizado para verificar se o veiculo esta em uso em outra viagem.
Local lContVei    := GetMv("MV_CONTVEI")
Local nColsCAux   := 0 // Numero do aCols do Condutor Auxiliar
Local nColsCPri   := 0 // Numero do aCols do Condutor Principal
Local cVsRepom    := SuperGetMV( 'MV_VSREPOM',, '1' )  //-- Versao 2- Contempla nova Legislacao (Encerramento viagem no Posto)
Local aFindAcc    := {}
Local lFindAcc    := .T.
Local lFindFav    := .T.
Local aFindFav    := {}
Local aInsFav     := {}
Local lFrotaProp  := Posicione('DA3',1,xFilial('DA3')+ M->DTR_CODVEI,'DA3_FROVEI') == '1'
Local cTipoCGC    := ''
Local cQtdeDoc    := ''
Local cRNTRC      := ''
Local cTMSOPdg    := SuperGetMV( 'MV_TMSOPDG',, '0' )
Local cCodFor     := ''
Local cLojFor     := ''
Local lFavorec    := .T.
Local lValida     := .T.
Local lTabDLD     := TableInDic('DLD')
Local lDvcta	  := SA2->(ColumnPos("A2_DVCTA")) > 0 
Local cDvCta	  := ""

lRet := IIf(nOpcx == 3 .Or. nOpcx == 4, aMotLinOk(), .T.)

If nOpcx == 3 .Or. nOpcx == 4

	If lRet .And. GDFieldPos('DUP_IDOPE') > 0 .And. !Empty(M->DTR_CODOPE) .And.; 
			DUP->(FieldPos("DUP_CONDUT")) > 0 .And. cTMSOPdg <> '0'
		For nAux := 1 To Len(aCols)
			If (AllTrim(aCols[nAux,GDFieldPos('DUP_CONDUT')]) == '1') .And. (!aCols[nAux,Len(aHeader)+1])
				nColsCPri := nAux
			ElseIf (AllTrim(aCols[nAux,GDFieldPos('DUP_CONDUT')]) == '2') .And. (!aCols[nAux,Len(aHeader)+1])
				nColsCAux := nAux
			EndIf
		Next
		// CASO A ROTINA ANTERIOR NAO TENHA ENCONTRADO O CONDUTOR PRINCIPAL,
		// MAS ENCONTROU O AUXILIAR, ESSE PASSARA A SER O PRINCIPAL.
		If (nColsCPri == 0) .And. (nColsCAux > 0)
			aCols[nColsCAux,GDFieldPos('DUP_CONDUT')] := '1'
		EndIf
	EndIf

	//--Valida o Id dos Motoristas...
	If M->DTR_CODOPE == '01' .And. !(cVsRepom $ '2|2.2') //Qdo versao 2, a validacao do cartao é executada pelo metodo Valida Abertura

		For nAux := 1 To Len(aCols)
			If !aCols[nAux,Len(aHeader)+1]
				CursorWait()

				If DUP->( FieldPos("DUP_CONDUT") ) == 0 .Or.; 
					( DUP->( FieldPos("DUP_CONDUT") ) > 0 .And. GDFieldGet('DUP_CONDUT', nAux) == '1' )
					MsgRun( STR0055 + GDFieldGet('DUP_NOMMOT',nAux),;
							STR0054,;
							{||lRet := TMS240VlId(	M->DTR_CODOPE,;
													AllTrim(aCols[nAux,GDFieldPos('DUP_IDOPE')]),;
													AllTrim(aCols[nAux,GDFieldPos('DUP_TIPMOT')]),;
													AllTrim(aCols[nAux,GDFieldPos('DUP_CODMOT')]))})
				EndIf
				//--Falha na validacao do Id...
				If !lRet
					Exit
				EndIf
				CursorArrow()
			EndIf
		Next
		
	ElseIf ( M->DTR_CODOPE == '02' )

		For nAux := 1 To Len(aCols)
			If !aCols[nAux,Len(aHeader)+1]
				CursorWait()
				
				If GDFieldPos('DUP_CONDUT') > 0 .And. aCols[nAux,GdFieldPos('DUP_CONDUT')] == '1'
					//Posicionar na tabela de Motoristas - DA4
					DA4->( DbSetOrder(1) )
					DA4->( DbSeek( xFilial('DA4')+GDFieldGet('DUP_CODMOT',nAux) ) )   
					Exit
				EndIf
			EndIf
		Next
		// Valida se existe um Favorecido para o proprietario do veiculo e ou no SA2
		DA3->(dbSetOrder(1))
		If FieldPos("DA3_CODFAV") > 0
			DA3->(DbSeek(xFilial('DA3') + M->DTR_CODVEI))
			If !Empty(DA3->DA3_CODFAV) .And. !Empty(DA3->DA3_LOJFAV)
				cCodFor := DA3->DA3_CODFAV
				cLojFor := DA3->DA3_LOJFAV
				lFavorec  := .F.
			Else
				cCodFor := DA3->DA3_CODFOR
				cLojFor := DA3->DA3_LOJFOR
			EndIf
		Else
			cCodFor := DA3->DA3_CODFOR
			cLojFor := DA3->DA3_LOJFOR
		EndIf
		//Posicionar na tabela de Fornecedores - SA2
		SA2->( DbSetOrder(1) )                      		
		If SA2->( !DbSeek(xFilial("SA2") + cCodFor + cLojFor ) )
			// tem que mudar a msg colocando Favorecido
			Help(' ', 1, 'TMSA24061') //'Não foi encontrado fornecedor', 'para este motorista.'
			lRet := .F.
		ElseIf lFavorec .And. !Empty(SA2->A2_CODFAV) .And. !Empty(SA2->A2_LOJFAV)
			If SA2->( !DbSeek(xFilial("SA2") + SA2->(A2_CODFAV+A2_LOJFAV) ) )                  
				Help(' ', 1, 'TMSA24061') //'Não foi encontrado fornecedor', 'para este motorista.'
				lRet := .F.			
			EndIf                                                                              
		EndIf

		If lRet
			If SA2->A2_TIPO == 'F'
				cTipoCGC := "2"
				cQtdeDoc := "3"
				cRNTRC   := "5"
			ElseIf SA2->A2_TIPO == 'J'
				cTipoCGC := "1"
				cQtdeDoc := "2"
				cRNTRC   := "6"
			Else
				Help(' ', 1, 'TMSA24062') //'O tipo do fornecedor está preenchido incorretamente na tabela de Fornecedores.'
				lRet := .F.
			EndIf
		EndIf
		
		lValida:= .T.
		//---- Permite DUP_IDOPE em branco, caso existir a tabela DLD
		If lRet .And. lTabDLD .And. Empty(GdFieldGet('DUP_IDOPE',n))
			lValida:= .F.
		EndIf

		If lValida
			If lRet .And. !lFrotaProp 
				aRetCNPJ := PamCNPJEmp('02', cFilAnt)

				AAdd (aFindFav,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
				AAdd (aFindFav,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
				AAdd (aFindFav,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
				AAdd (aFindFav,{'viagem.favorecido.documento.tipo', cTipoCGC} )
				AAdd (aFindFav,{'viagem.favorecido.documento.numero', AllTrim(SA2->A2_CGC) })

				If cTipoCGC == "1" .And. !Empty(DA4->DA4_CGC)
					AAdd (aFindFav,{'viagem.favorecido.documento.tipo', '2' } )
					AAdd (aFindFav,{'viagem.favorecido.documento.numero', AllTrim(DA4->DA4_CGC) })
				EndIf

				lFindFav := PamFindFav(aFindFav)

				If !lFindFav

					AAdd (aInsFav,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
					AAdd (aInsFav,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
					AAdd (aInsFav,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
					AAdd (aInsFav,{'viagem.favorecido.documento.qtde', cQtdeDoc } )
					AAdd (aInsFav,{'viagem.favorecido.documento1.tipo', cTipoCGC } )
					AAdd (aInsFav,{'viagem.favorecido.documento1.numero', AllTrim(SA2->A2_CGC) } )
					AAdd (aInsFav,{'viagem.favorecido.documento2.tipo', cRNTRC } )
					AAdd (aInsFav,{'viagem.favorecido.documento2.numero', AllTrim(SA2->A2_RNTRC) } )

					If cTipoCGC == "2"
						AAdd (aInsFav,{'viagem.favorecido.documento3.tipo', '3' } )
						AAdd (aInsFav,{'viagem.favorecido.documento3.numero', AllTrim(DA4->DA4_RG) })
						AAdd (aInsFav,{'viagem.favorecido.documento3.uf', AllTrim(DA4->DA4_RGEST) })
					EndIf

					AAdd (aInsFav,{'viagem.favorecido.nome', AllTrim(SA2->A2_NOME) } )
					AAdd (aInsFav,{'viagem.favorecido.data.nascimento', SubStr(DtoS(DA4->DA4_DATNAS),7,2) + '/' + SubStr(DtoS(DA4->DA4_DATNAS),5,2) + '/' + SubStr(DtoS(DA4->DA4_DATNAS),1,4) } )
					AAdd (aInsFav,{'viagem.favorecido.endereco.logradouro', AllTrim(SA2->A2_END) })
					AAdd (aInsFav,{'viagem.favorecido.endereco.numero', '1'} )
					AAdd (aInsFav,{'viagem.favorecido.endereco.bairro', AllTrim(SA2->A2_BAIRRO) } )
					AAdd (aInsFav,{'viagem.favorecido.endereco.cidade.ibge', TMS120CDUF(SA2->A2_EST, '1') + AllTrim(SA2->A2_COD_MUN) } )
					AAdd (aInsFav,{'viagem.favorecido.endereco.cep', AllTrim(SA2->A2_CEP) } )
					AAdd (aInsFav,{'viagem.favorecido.telefone.ddd', StrZero(Val(SA2->A2_DDD),3) } )
					AAdd (aInsFav,{'viagem.favorecido.telefone.numero', AllTrim(StrTran(SA2->A2_TEL,"-","")) } )

					lRet := PamInsFav(aInsFav)
				EndIf
			EndIf

			If lRet .And. GDFieldPos('DUP_FORPAG') > 0
				If (lFrotaProp .And. AllTrim(aCols[nAux,GDFieldPos('DUP_FORPAG')]) <> '1')
					Help('', 1, 'TMSA24063') //'Veículos de Frota Própria só poderão', 'ter viagens com meio de pagamento', '1=Cartão!'
					lRet := .F.
				Else
					If AllTrim(aCols[nAux,GDFieldPos('DUP_FORPAG')]) == '1' .Or. AllTrim(aCols[nAux,GDFieldPos('DUP_FORPAG')]) == '3' ;
						.Or. IIf(DUP->( FieldPos('DUP_FORADT')>0 ),AllTrim(aCols[nAux,GDFieldPos('DUP_FORADT')]) == '1',.F.)
						
						If DUP->( FieldPos("DUP_CONDUT") ) == 0 .Or.; 
							( DUP->( FieldPos("DUP_CONDUT") ) > 0 .And. GDFieldGet('DUP_CONDUT', nAux) == '1' )
								MsgRun( STR0055 + GDFieldGet('DUP_NOMMOT',nAux),;
								STR0054,;
								{||lRet := TMS240VlId(	M->DTR_CODOPE,;
									AllTrim(aCols[nAux,GDFieldPos('DUP_IDOPE')]),;
									AllTrim(aCols[nAux,GDFieldPos('DUP_TIPMOT')]),;
									AllTrim(aCols[nAux,GDFieldPos('DUP_CODMOT')]))})
							EndIf
					EndIf
					
					If lRet .And. AllTrim(aCols[nAux,GDFieldPos('DUP_FORPAG')]) == '2' .Or. AllTrim(aCols[nAux,GDFieldPos('DUP_FORPAG')]) == '3'		
									
					
						If !Empty(SA2->A2_BANCO) .And. !Empty(SA2->A2_AGENCIA) .And. !Empty(SA2->A2_NUMCON) .And. !Empty(SA2->A2_TPCONTA)
							aRetCNPJ := PamCNPJEmp('02', cFilAnt)
							
							If SA2->A2_TIPO  == 'F'
								cTipoCGC := "2"
							Else
								cTipoCGC := "1"
							EndIf

							If lDvcta
								cDvCta := SA2->A2_DVCTA 
							EndIf 

							AAdd (aFindAcc,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
							AAdd (aFindAcc,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
							AAdd (aFindAcc,{'viagem.unidade.documento.numero', aRetCNPJ[3]} ) 
							AAdd (aFindAcc,{'viagem.favorecido.documento.tipo', cTipoCGC} )
							AAdd (aFindAcc,{'viagem.favorecido.documento.numero', AllTrim(SA2->A2_CGC) })
							AAdd (aFindAcc,{'viagem.favorecido.conta.banco', AllTrim(SA2->A2_BANCO) } )
							AAdd (aFindAcc,{'viagem.favorecido.conta.agencia', AllTrim(SA2->A2_AGENCIA) } )
							AAdd (aFindAcc,{'viagem.favorecido.conta.numero', AllTrim(SA2->A2_NUMCON) + AllTrim(cDvCta) } )
							AAdd (aFindAcc,{'viagem.favorecido.conta.tipo', AllTrim(SA2->A2_TPCONTA) } )
							
							lFindAcc := PamFindAcc(aFindAcc)
							
							If !lFindAcc
								PamInsAcc(aFindAcc)
							EndIf	 
						Else
							Help(' ', 1, 'TMSA24060') //'Não foi encontrado Banco, Agência', 'e Conta Corrente para este motorista.'
							lRet := .F.
						EndIf	 	
					EndIf
				EndIf	
			EndIf						
		EndIf	
	EndIf	
EndIf

//-- Verifica se o Motorista esta sendo utilizado em outra viagem.
//-- Verificacao realizada quando o parametro MV_CONVEI ou o parametro MV_EMVIAG estivem ativos e a viagem
//-- for diferente de 'Planejada'
If lRet .And. ( lContVei .Or. lMV_EmViag ) .And. aFilOri[5] <> 3
	For nAux := 1 To Len(aCols)
		If !GDDeleted( nAux ) .And. !TMSEmViag(M->DTR_FILORI, M->DTR_VIAGEM, GDFieldGet('DUP_CODMOT',nAux), 2, .T.)
			lRet := .F.
		EndIf
	Next
EndIf

//-- Verifica se o Motorista esta sendo utilizado em outra viagem (Planejada)
If lRet .And. !lContVei 
	For nAux := 1 To Len(aCols)
		If !GDDeleted( nAux ) .And. !aMotPlanej( M->DTR_FILORI, M->DTR_VIAGEM, GDFieldGet('DUP_CODMOT',nAux), {M->DTR_DATINI, M->DTR_HORINI, M->DTR_DATFIM, M->DTR_HORFIM} )
			lRet := .F.
		EndIf
	Next
EndIf

If lRet .And. lTM240MOTOK
	lRet := ExecBlock('TM240MOTOK',.F.,.F.)
	If ValType(lRet) # "L"
		lRet := .F.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA240Ajud³ Autor ³Patricia A. Salomao   ³ Data ³23.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ajudantes da Viagem                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA240Ajud(ExpN1,ExpC1,ExpL1)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao Selecionada                                  ³±±
±±³          ³ ExpC1 - Cod.Ajudante                                       ³±±
±±³          ³ ExpL1 - Verifica se mostra ou nao a GetDados               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA240Ajud(nOpcx, cCodAju, lMostraGet, lFirst, lAutoAju)

Local oDlg,oGetDados,nCntFor
Local nOpc         := 0
Local nPosVei      := 0
Local nPosAju      := 0
Local aSavHeader   := aClone(aHeader)
Local aSavaRotina  := aClone(aRotina)
Local l240Visual   := .F.
Local lConsid      := .F.

Private nSavN      := n
Private aSavCols   := aClone(aCols)

//-- Variaveis criada somente se informado motorista, caso informado veiculo variaveis criada anteriormente.
If Type("cDTR_ITEM") <> "C"
	Private cDTR_ITEM  := GdFieldGet('DTR_ITEM',n)
EndIf
If Type("nPosItem") <> "N"
	Private nPosItem   := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTR_ITEM" })
EndIf

Default lMostraGet := .T.
Default lFirst     := .F.
Default lAutoAju   := .F. //Carrega acols do Ajudante mas nao exibe a tela

//-- Finaliza as Teclas de Atalhos
TmsKeyOff(aSetKey)

nPosVei := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTR_CODVEI" })
nPosAju := Ascan(aAjuViag,{|x| x[1] == cDTR_ITEM })

If nOpcx == 2 .Or. nOpcx == 5
	l240Visual := .T.
EndIf

If !lAutoAju
	If !Empty(M->DTR_FILVGE+M->DTR_NUMVGE)
		l240Visual := .T.
	EndIf
EndIf	

n       := 1
aCols	:= {}
aHeader := {}
aRotina[2][4] := 2
aRotina[3][4] := 3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aHeaderDUQ) == 0
	aHeader := ApBuildHeader("DUQ", Strtokarr2('DUQ_FILORI.DUQ_VIAGEM.DUQ_ITEDTR.DUQ_CODVEI', "."))
	
	aHeaderDUQ := Aclone(aHeader)
Else
	aHeader := Aclone(aHeaderDUQ)
EndIf

If	nPosAju  > 0
	If lFirst
		aAjuViag[nPosAju][2] := {}
	Else
		aCols := aClone(aAjuViag[nPosAju][2])
	EndIf
EndIf

If !Empty(cCodAju)
	//-- Desconsidera o Ajudante, se o mesmo ja estiver sendo utilizado nesta viagem
	lConsid := TMSA240Ver("2", cCodAju, aAjuViag, .F.)

	//--Bloqueia o ajudante para nao ser utilizado em outra viagem
	If !LockByName("VGEAJU" + cCodAju,.T.,.F.)
		lConsid := .F.
		Help( ' ', 1, 'TMSA24048', , STR0060 + cCodAju ,3 ,0) //"O Ajudante esta sendo utilizado por outra viagem." ### "Ajudante: "
	EndIf

	If lConsid
		AAdd(aCols,Array(Len(aHeader)+1))
		For nCntFor := 1 To Len(aHeader)
			aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
		Next
		aCols[Len(aCols), GdFieldPos("DUQ_CODAJU")] := cCodAju
		aCols[Len(aCols), GdFieldPos("DUQ_NOMAJU")] := Posicione("DAU",1,xFilial("DAU")+cCodAju,"DAU_NOME")
		aCols[Len(aCols),Len(aHeader)+1] := .F.
		//--Bloqueia o ajudante para nao ser utilizado em outra viagem
		LockByName("VGEAJU" + cCodAju,.T.,.F.)
	EndIf
ElseIf lMostraGet .Or. lAutoAju
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem de uma linha em branco no aCols.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aCols)
		AAdd(aCols,Array(Len(aHeader)+1))
		For nCntFor := 1 To Len(aHeader)
			aCols[1,nCntFor] := CriaVar(aHeader[nCntFor,2])
		Next
		aCols[1,Len(aHeader)+1] := .F.
	EndIf
EndIf

If lMostraGet
	DEFINE MSDIALOG oDlg FROM 94 ,104 TO 330,650 TITLE STR0015 Of oMainWnd PIXEL  //'Ajudantes Viagem'
	oGetDados := MSGetDados():New(30,2,118,271,IIF(l240Visual,2,3),'aAjuLinOk','AllwaysTrue()',,.T.,,,,100,,,,If(l240Visual,"AlwaysFalse",'TMSA240Del(3)'))
	@ 6  ,116 SAY ''      Of oDlg PIXEL SIZE 26 ,9
	@ 18 ,3   SAY STR0007 Of oDlg PIXEL SIZE 56 ,9  //"Viagem : "
	@ 18 ,96  SAY STR0009 Of oDlg PIXEL SIZE 60 ,9  //"Veiculo : "
	@ 18 ,36  SAY M->DTR_FILORI+"/"+M->DTR_VIAGEM Of oDlg PIXEL SIZE 50 ,9
	@ 18 ,125 SAY aSavCols[nSavN][nPosVei] Of oDlg PIXEL SIZE 140 ,9
	
	ACTIVATE MSDIALOG oDlg ON INIT (oGetdados:Refresh(),EnchoiceBar(oDlg, {||Iif(aAjuTudOk(IIF(l240Visual,2,3)),(nOpc:=1,oDlg:End()),(nOpc:=0))},{||oDlg:End()}) )
Else
	nOpc := 1
EndIf

If nOpc == 1 .And. !l240Visual
	If nPosAju  > 0
		aAjuViag[nPosAju][2] := aClone(aCols)
	Else
		AAdd(aAjuViag,{ cDTR_ITEM, aClone(aCols)})
	EndIf
EndIf

aRotina := aClone(aSavaRotina)
aHeader := aClone(aSavHeader)
aCols   := aClone(aSavCols)
n       := nSavN

//-- Iniciliza as Teclas de Atalhos
TmsKeyOn(aSetKey)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³aAjuLinOk  ³ Autor ³Patricia A. Salomao   ³ Data ³23.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da Linha da GetDados de Ajudantes  da Viagem     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ aAjuLinOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function aAjuLinOk()

Local lRet       := .T.
Local cCodAju    := ""
Local lContVei   := GetMv("MV_CONTVEI")
Local lMV_EmViag := GetMV("MV_EMVIAG",,.F.) // Utilizado para verificar se o veiculo esta em uso em outra viagem.

//-- Analisa se ha itens duplicados na GetDados.
If !GdDeleted(n)
	If !MaCheckCols(aHeader,aCols,n)
		Return ( .F. )
	EndIf
	
	If !GDCheckKey( {'DUQ_CODAJU'}, 4 )
		Return ( .F. )
	EndIf
	
	cCodAju := GdFieldGet("DUQ_CODAJU",n)
	//-- Desconsidera o Ajudante, se o mesmo ja estiver sendo utilizado nesta viagem
	If !TMSA240Ver("2", cCodAju, aAjuViag, .T., aSavCols[nSavN][nPosItem])
		Return ( .F. )
	EndIf
	
	//-- Valida se o Ajudante, esta sendo utilizado em outra Viagem
	If ( lContVei .Or. lMV_EmViag ) .And. aFilOri[5] <> 3 .And. !TMSEmViag(M->DTR_FILORI, M->DTR_VIAGEM, cCodAju, 3)
		Return ( .F. )
	EndIf
	
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³aAjuTudOk  ³ Autor ³Patricia A. Salomao   ³ Data ³23.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao da Tela  da GetDados de Ajudantes  da Viagem      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³aAjuTudOk(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function aAjuTudOk(nOpcx)

Local lRet := .T.

lRet := IIf(nOpcx == 3, aAjuLinOk(), .T.)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³aComplViag ³ Autor ³Patricia A. Salomao   ³ Data ³23.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Preenche os acols auxiliares com os Motoristas/Ajudantes/   ³±±
±±³          ³Lacres/Adiantamentos informados na viagem                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³aComplViag(ExpC1, ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Filial Origem                                       ³±±
±±³          ³ExpC2 - Viagem                                              ³±±
±±³          ³ExpL1 - Complemento de Viagem vazio (Progr. Carregamento)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function aComplViag(cFilOri, cViagem, lCompVazio)

Local nPosValBai := 0
Local aSavHeader := aClone(aHeader)
Local aSavCols   := aClone(aCols)
Local nPosAju    := 0
Local nPosMot    := 0
Local nPosLacre  := 0
Local nPosAdto   := 0
Local cSeek      := ''
Local cNoFields  := ''
Local lContVei   := GetMV('MV_CONTVEI',,.T.) // Parametro para verificar se o sistema devera' controlar veiculo/motorista
Local nCntFor    := 0
Local aAdCpo     := {}
Local nI         := 0
Local cCpo       := ''
//-- Operadoras de Frota/Vale-Pedagio
Local cTMSOPdg   := SuperGetMV( 'MV_TMSOPDG',, '0' )

//VInculo Carregamento Grafico
Local aAreaDTR		:= DTR->(GetArea())
Local nXX         	:= 0
Local cChaveDTR   	:= ""
Local cMV_TMSRRE   := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
Local lTabRRE      := "3" $ cMV_TMSRRE 
Local lTabDLD      := TableInDic('DLD')
Local nPosDLD      := 0
Local aFldTmp	   := {}

Local lGerador     := SDG->(ColumnPos("DG_GERADOR") > 0)

If lContVei
	//-- Quando a Viagem por planejada, trata como se o controle de veiculos estivesse desligado.
	TMSA240Off( @lContVei, .F. )
EndIf
//
//-- Verifica se foi informado Motoristas para esta Viagem
//
If lContVei
	cNoFields := 'DUP_FILORI.DUP_VIAGEM.DUP_ITEDTR.DUP_CODVEI.DUP_LIBSEG.DUP_VALSEG'
Else
	cNoFields := 'DUP_FILORI.DUP_VIAGEM.DUP_ITEDTR.DUP_CODVEI'
EndIf

//-- Tratamento para Operadoras de Frota/Vale-Pedagio
cNoFields += '.DUP_CODOPE.DUP_NOMOPE'
If cTMSOPdg == '0'
	cNoFields += '.DUP_FORPAG.DUP_TPSPDG'
EndIf

If Empty(aMotViag)
	aHeader := ApBuildHeader("DUP", Strtokarr2( cNoFields, "."))
	
	aHeaderDUP := Aclone(aHeader)
	DTR->(dbSetOrder(1))
	If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))
		Do While !DTR->(Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) ==  xFilial("DTR")+cFilOri+cViagem
			DUP->(dbSetOrder(1))
			If DUP->(MsSeek(xFilial("DUP")+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_ITEM))
				aCols := {}
				//-- Verifica se foi informado Motoristas da Viagm para o Item de Veiculo (DTR_CODVEI)
				Do While !DUP->(Eof()) .And. DUP->(DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_ITEDTR) == xFilial("DUP")+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_ITEM
					AAdd(aCols,Array(Len(aHeaderDUP)+1))
					For nCntFor := 1 To Len(aHeaderDUP)
						If	aHeaderDUP[nCntFor,10] != "V"
							aCols[Len(aCols),nCntFor]:=DUP->(FieldGet(FieldPos(aHeaderDUP[nCntFor,2])))
						Else
							aCols[Len(aCols),nCntFor]:=CriaVar(aHeaderDUP[nCntFor,2])
						EndIf
					Next nCntFor
					aCols[Len(aCols),Len(aHeaderDUP)+1]:=.F.
					DUP->(dbSkip())
				EndDo
				nPosMot := Ascan(aMotViag, {|x|  x[1] == DTR->DTR_ITEM })
				If nPosMot > 0
					AAdd(aMotViag[nPosMot][2], aClone(aCols))
				Else
					AAdd(aMotViag,{ DTR->DTR_ITEM, aClone(aCols)})
				EndIf
			EndIf
			DTR->(dbSkip())
		EndDo
	Else
		If lCompVazio
			AAdd(aCols,Array(Len(aHeaderDUP)+1))
			For nCntFor := 1 To Len(aHeaderDUP)
				If	aHeaderDUP[nCntFor,10] != "V"
					aCols[Len(aCols),nCntFor]:=DUP->(FieldGet(FieldPos(aHeaderDUP[nCntFor,2])))
				Else
					aCols[Len(aCols),nCntFor]:=CriaVar(aHeaderDUP[nCntFor,2])
				EndIf
			Next nCntFor
			aCols[Len(aCols),Len(aHeaderDUP)+1]:=.F.
			AAdd(aMotViag,{ StrZero( 1, TamSx3("DTR_ITEM")[1] ), aClone(aCols)})
		EndIf
	EndIf
EndIf

//
//-- Verifica se foi informado Ajudantes para esta Viagem
//
If Empty(aAjuViag)
	aHeader := ApBuildHeader("DUQ", Strtokarr2('DUQ_FILORI.DUQ_VIAGEM.DUQ_ITEDTR.DUQ_CODVEI', "."))
	
	aHeaderDUQ := Aclone(aHeader)
	DTR->(dbSetOrder(1))
	If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))
		Do While !DTR->(Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) ==  xFilial("DTR")+cFilOri+cViagem
			aCols := {}
			DUQ->(dbSetOrder(1))
			If DUQ->(MsSeek(xFilial("DUQ")+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_ITEM))
				//-- Verifica se foi informado Motoristas da Viagem para o Item de Veiculo (DTR_CODVEI)
				Do While !DUQ->(Eof()) .And. DUQ->(DUQ_FILIAL+DUQ_FILORI+DUQ_VIAGEM+DUQ_ITEDTR) == xFilial("DUQ")+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_ITEM
					AAdd(aCols,Array(Len(aHeaderDUQ)+1))
					For nCntFor := 1 To Len(aHeaderDUQ)
						If	aHeaderDUQ[nCntFor,10] != "V"
							aCols[Len(aCols),nCntFor]:=DUQ->(FieldGet(FieldPos(aHeaderDUQ[nCntFor,2])))
						Else
							aCols[Len(aCols),nCntFor]:=CriaVar(aHeaderDUQ[nCntFor,2])
						EndIf
					Next nCntFor
					aCols[Len(aCols),Len(aHeaderDUQ)+1]:=.F.
					DUQ->(dbSkip())
				EndDo
				nPosAju := Ascan(aAjuViag, {|x|  x[1] == DTR->DTR_ITEM })
				If nPosAju > 0
					AAdd(aAjuViag[nPosAju][2], aClone(aCols))
				Else
					AAdd(aAjuViag,{ DTR->DTR_ITEM, aClone(aCols)})
				EndIf
			EndIf
			DTR->(dbSkip())
		EndDo
	EndIf
EndIf

//
//-- Verifica se foi informado o Lacre dos Veiculos da Viagem
//
If Empty(aLacrVei)
	aHeader := ApBuildHeader("DVB", Strtokarr2('DVB_FILORI.DVB_VIAGEM.DVB_CODVEI', "."))
	
	aHeaderDVB := Aclone(aHeader)
	DTR->(dbSetOrder(1))
	If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))
		Do While !DTR->(Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == xFilial("DTR")+cFilOri+cViagem
			DVB->(dbSetOrder(1))
			If DVB->(MsSeek(xFilial("DVB")+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_CODVEI))
				aCols := {}
				//-- Verifica se foi informado Motoristas da Viagm para o Item de Veiculo (DTR_CODVEI)
				Do While !DVB->(Eof()) .And. DVB->(DVB_FILIAL+DVB_FILORI+DVB_VIAGEM+DVB->DVB_CODVEI) == xFilial("DVB")+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_CODVEI
					AAdd(aCols,Array(Len(aHeaderDVB)+1))
					For nCntFor := 1 To Len(aHeaderDVB)
						If	aHeaderDVB[nCntFor,10] != "V"
							aCols[Len(aCols),nCntFor]:=DVB->(FieldGet(FieldPos(aHeaderDVB[nCntFor,2])))
						Else
							aCols[Len(aCols),nCntFor]:=CriaVar(aHeaderDVB[nCntFor,2])
						EndIf
					Next nCntFor
					aCols[Len(aCols),Len(aHeaderDVB)+1]:=.F.
					DVB->(dbSkip())
				EndDo
				nPosLacre := Ascan(aLacrVei, {|x|  x[1] == DTR->DTR_CODVEI })
				If nPosLacre > 0
					AAdd(aLacrVei[nPosLacre][2], aClone(aCols))
				Else
					AAdd(aLacrVei,{ DTR->DTR_CODVEI, aClone(aCols)})
				EndIf
			EndIf
			DTR->(dbSkip())
		EndDo
	EndIf
EndIf

//
//-- Verifica se foi informado Adiantamentos para esta Viagem
//
If Empty(aAdtoViag)

	If lTM240ADCPO
		aAdCpo:= ExecBlock("TM240ADCPO",.F.,.F.,)
		If ValType(aAdCpo)  == "A"
				For nI:= 1 to len(aAdCpo)
				cCpo += AllTrim("."	+ aAdCpo[nI,1])
			Next nI
		EndIf
	EndIf

	aHeader := {}
	aFldTmp := ApBuildHeader("SDG")
	For nI := 1 To Len(aFldTmp)
		If AllTrim(aFldTmp[nI][2]) $ 'DG_CODDES.DG_DESCRI.DG_TOTAL.DG_VALCOB.DG_VALBAI.DG_SALDO.DG_DATVENC.DG_NUMSEQ.DG_TIPDES.DG_BANCO.DG_AGENCIA.DG_NUMCON.DG_NUMCHEQ' + Iif(lGerador,'.DG_GERADOR.DG_TIPGER',"") + cCpo
			aAdd(aHeader, aFldTmp[nI])
		EndIf
	Next

	aSize(aFldTmp, 0)
	aFldTmp := Nil

	nPosValBai := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DG_VALBAI' })
	aHeaderSDG := Aclone(aHeader)
	DTR->(dbSetOrder(1))
	If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem)) .And. !IsInCallStack('TMSA240Vld')
		Do While !DTR->(Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == xFilial("DTR")+cFilOri+cViagem
			aCols := {}
			SDG->(dbSetOrder(5))
			If SDG->(MsSeek(cSeek:=xFilial("SDG")+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_CODVEI)   )
				Do While !SDG->(Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM+DG_CODVEI) == cSeek
					AAdd(aCols,Array(Len(aHeaderSDG)+1))
					For nCntFor := 1 To Len(aHeaderSDG)
						If	aHeaderSDG[nCntFor,10] != "V"
							aCols[Len(aCols),nCntFor] := SDG->(FieldGet(FieldPos(aHeaderSDG[nCntFor,2])))
						Else
							aCols[Len(aCols),nCntFor] := CriaVar(aHeaderSDG[nCntFor,2])
						EndIf
					Next nCntFor
					aCols[Len(aCols),nPosValBai] := SDG->DG_VALCOB - SDG->DG_SALDO  //-- Valor baixado
					aCols[Len(aCols),Len(aHeaderSDG)+1]:=.F.
					SDG->(dbSkip())
				EndDo
				nPosAdto := Ascan(aAdtoViag, {|x|  x[1] == DTR->DTR_CODVEI })
				If nPosAdto > 0
					AAdd(aAdtoViag[nPosAdto][2], aClone(aCols))
				Else
					AAdd(aAdtoViag,{ DTR->DTR_CODVEI, aClone(aCols)})
				EndIf
			EndIf
			DTR->(dbSkip())
		EndDo
	EndIf
EndIf

//-- Verifica se foi informado o Numero de Liberação de Seguro
//
If lTabRRE .And. Empty(aLibSeg)
	aHeader :=  ApBuildHeader("DJA", Strtokarr2('DJA_FILORI.DJA_VIAGEM', "."))
	
	aHeaderDJA := Aclone(aHeader)
	DTR->(dbSetOrder(1))
	If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))
		Do While !DTR->(Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == xFilial("DTR")+cFilOri+cViagem
			
			//--- Veiculo
			For nXX:= 0 To 2   //Veiculo + Reboque1 + Reboque 2
				If nXX == 0
					cChaveDTR:= xFilial("DA3") + DTR->DTR_CODVEI
				ElseIf nXX == 1
					cChaveDTR:= xFilial("DA3") + DTR->DTR_CODRB1
				ElseIf nXX == 2
					cChaveDTR:= xFilial("DA3") + DTR->DTR_CODRB2
				EndIf
				If !Empty(cChaveDTR)
					cChaveDTR:= Padr(cChaveDTR,Len(DJA->DJA_CHAVE))
					A240CarDJA('DA3',cChaveDTR,aHeaderDJA,cFilOri,cViagem)
				EndIf
				If Empty(DTR->DTR_CODRB1)
					Exit
				EndIf
			Next nXX
			
			//---- Motorista
			DUP->(dbSetOrder(1))
			If DUP->(MsSeek(xFilial("DUP")+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_ITEM))
				aCols := {}
				Do While !DUP->(Eof()) .And. DUP->(DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_ITEDTR) == xFilial("DUP")+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_ITEM
					cChaveDTR:= Padr(xFilial("DA4") + DUP->DUP_CODMOT,Len(DJA->DJA_CHAVE)) 
					A240CarDJA('DA4',cChaveDTR,aHeaderDJA,cFilOri,cViagem)
					DUP->(dbSkip())
				EndDo
			EndIf
			
			DTR->(dbSkip())
		EndDo
	EndIf
EndIf

If lTabDLD .And. Empty(aPagtoVge)

	aHeader := ApBuildHeader("DLD", Strtokarr2('DLD_FILORI.DLD_VIAGEM.DLD_TAGID', "."))
	
	aHeaderDLD := Aclone(aHeader)
	
	DTR->(dbSetOrder(1))
	If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem)) .And. !IsInCallStack('TMSA240Vld')
		Do While !DTR->(Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == xFilial("DTR")+cFilOri+cViagem
			aCols := {}
			DLD->(dbSetOrder(1))
			If DLD->(MsSeek(cSeek:=xFilial("DLD")+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_ITEM)   )
				Do While !DLD->(Eof()) .And. DLD->(DLD_FILIAL+DLD_FILORI+DLD_VIAGEM+DLD_ITEDTR) == cSeek
					AAdd(aCols,Array(Len(aHeaderDLD)+1))
					For nCntFor := 1 To Len(aHeaderDLD)
						If	aHeaderDLD[nCntFor,10] != "V"
							aCols[Len(aCols),nCntFor] := DLD->(FieldGet(FieldPos(aHeaderDLD[nCntFor,2])))
						Else
							aCols[Len(aCols),nCntFor] := CriaVar(aHeaderDLD[nCntFor,2])
						EndIf
					Next nCntFor				
					aCols[Len(aCols),Len(aHeaderDLD)+1]:=.F.
					DLD->(dbSkip())
				EndDo
				nPosDLD := Ascan(aPagtoVge, {|x|  x[1]+x[2] == DTR->DTR_ITEM + DTR->DTR_CODVEI })
				If nPosDLD > 0
					AAdd(aPagtoVge[nPosDLD][3], aClone(aCols))
				Else
					AAdd(aPagtoVge,{ DTR->DTR_ITEM, DTR->DTR_CODVEI, aClone(aCols)})
				EndIf									
			EndIf
			DTR->(dbSkip())
		EndDo
	EndIf
EndIf

aHeader := aClone(aSavHeader)
aCols   := aClone(aSavCols)

RestArea(aAreaDTR)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA240Adto  ³ Autor ³Patricia A. Salomao   ³ Data ³22.09.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Adiantamentos de Viagem                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TA240Adto(ExpC1, ExpC2, ExpC3, EXPC4)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±³          ³ExpC1 - Filial de Origem Viagem                             ³±±
±±³          ³ExpC2 - No. da Viagem                                       ³±±
±±³          ³ExpC3 - Veiculo                                             ³±±
±±³          ³ExpA1 - ARRAY contendo os campos editaveis                  ³±±
±±³          ³ExpN2 - Qtde de linhas na GETDADOS                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TA240Adto(nOpcx, cFilOri, cViagem, cCodVei, aAltCpo, nQtdLin,cCodFor,cLojFor )

Local oDlg,nCntFor
Local nOpc		   := 0
Local nPosVei      := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTR_CODVEI" })
Local nPosDesp     := Ascan(aAdtoViag,{|x| x[1] == cCodVei})
Local aSavHeader   := aClone(aHeader)
Local aSavaRotina  := aClone(aRotina)
Local l240Visual   := .F.
Local aButtons     := {}
Local lAchou       := .F.
Local aAdCpo       := {}
Local cCpo         := "" 
Local nI           := 0
Local aAdTo        := {}

Local aSize        := {}
Local aObjects     := {}
Local aInfo        := {}
Local lTMS3GFE     := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local lPagGfe      := .F.
Local aFldTmp	   := {}

Local lGerador     := SDG->(ColumnPos("DG_GERADOR") > 0)

Private nSavN	   := n
Private aSavCols   := aClone(aCols)
Private nPosValFre := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTR_VALFRE" })
Private nPosValAdi := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTR_ADIFRE" })
Private nPosValAbt := Ascan(aHeader,{|x| AllTrim(x[2]) == "DTR_VLABST" })
Private oGDados

Default aAltCpo    := NIL
Default nQtdLin    := 100 //-- Qtde de linhas na GETDADOS

If Empty(cCodVei)
	Help('',1,'TMSA24037') //"Informe o Veiculo"
	Return(.F.)
EndIf

If lTMS3GFE 
	If Upper(AllTrim(FunName())) == "TMSA240"
		lPagGfe:= DTQ->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))  //Sim 
	Else
		lPagGfe:= M->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))  //Sim
	EndIf 
	If lPagGfe
		Help(" ",1,"TMSA24085")   //Pagamento da viagem via SIGAGFE. Não é permitido informar os Adiantamentos da Viagem.
		Return(.F.)
	EndIf	
EndIf 
aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2}
aPosObj := MsObjSize( aInfo, aObjects,.T.)  

If lTM240ADCPO
	aAdCpo:= ExecBlock("TM240ADCPO",.F.,.F.,)
	If ValType(aAdCpo)  == "A"
			For nI:= 1 to len(aAdCpo)
			cCpo += AllTrim("."	+ aAdCpo[nI,1])
		Next nI
	EndIf
EndIf
//-- Finaliza as Teclas de Atalhos
TmsKeyOff(aSetKey)

If nOpcx == 2 .Or. nOpcx == 5
	l240Visual := .T.
EndIf

If !Empty(M->DTR_FILVGE+M->DTR_NUMVGE)
	l240Visual := .T.
EndIf

n       := 1
aCols	:= {}
aHeader := {}
aRotina[2][4] := 2
aRotina[3][4] := 3

If nOpcx == 3 .Or. nOpcx == 4
	AAdd(aButtons , {'PRECO', {|| TMSA240Mrk(nOpcx, cCodVei,cCodFor,cLojFor) }, STR0036 , STR0037 }) //'Despesas em Aberto'
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aHeaderSDG) == 0
	aFldTmp := ApBuildHeader("SDG")
	For nI := 1 To Len(aFldTmp)
		If AllTrim(aFldTmp[nI][2]) $ 'DG_CODDES.DG_DESCRI.DG_TOTAL.DG_VALCOB.DG_VALBAI.DG_SALDO.DG_DATVENC.DG_NUMSEQ.DG_TIPDES.DG_BANCO.DG_AGENCIA.DG_NUMCON.DG_NUMCHEQ' + Iif(lGerador,'.DG_GERADOR.DG_TIPGER',"") + cCpo
			aAdd(aHeader, aFldTmp[nI])
		EndIf
	Next

	aSize(aFldTmp, 0)
	aFldTmp := Nil

	aHeaderSDG := Aclone(aHeader)
Else
	aHeader := Aclone(aHeaderSDG)
EndIf

If	nPosDesp > 0
	lAchou := .T.
	aCols  := aClone(aAdtoViag[nPosDesp][2])
	For nCntFor := 1 To Len(aCols)
		aCols[nCntFor,Len(aHeader)+1] := .F.
	Next nCntFor
EndIf

If lTM240ADTO .And. nOpcx == 3 .And. Empty(aCols)
	aAdTo:= ExecBlock("TM240ADTO",.F.,.F.)
	If ValType(aAdTo) == "A"   
		aCols:= aClone(aAdto)		
	EndIf              
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a montagem de uma linha em branco no aCols.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	Empty(aCols)
	AAdd(aCols,Array(Len(aHeader)+1))
	For nCntFor := 1 To Len(aHeader)
		aCols[1,nCntFor] := CriaVar(aHeader[nCntFor,2])
	Next
	aCols[1,Len(aHeader)+1] := .F.
EndIf

DEFINE MSDIALOG oDlg FROM aSize[7],0 TO aSize[6],aSize[5] TITLE STR0045 Of oMainWnd PIXEL //"Adiantamentos/Despesas"

oGDados := MSGetDados():New(30,2,aPosObj[1,3],aPosObj[1,4],IIF(l240Visual,2,3),'aAdtoLinOk()','AlwaysTrue', ,.T.,aAltCpo,,,nQtdLin,,,,If(l240Visual,"AlwaysFalse","TM240DelDG()"))

@  6 ,116 SAY ''								Of oDlg PIXEL SIZE  26 ,9
@ 18 ,  3 SAY STR0007							Of oDlg PIXEL SIZE  56 ,9  //"Viagem : "
@ 18 , 96 SAY STR0009							Of oDlg PIXEL SIZE  60 ,9  //"Veiculo : "
@ 18 , 36 SAY M->DTR_FILORI+"/"+M->DTR_VIAGEM	Of oDlg PIXEL SIZE  50 ,9
@ 18 ,125 SAY aSavCols[nSavN][nPosVei]			Of oDlg PIXEL SIZE 140 ,9
//-- Atualiza aCols corrigindo a falha na GetDados
If(lAchou,aCols := aClone(aAdtoViag[nPosDesp][2]),.T.)
	oGDados:Refresh(.T.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {||Iif( aAdtoTudOk(IIf(l240Visual,2,3)),(nOpc:=1,oDlg:End()),(nOpc:=0))},{||oDlg:End()},, aButtons )

If nOpc == 1 .And. !l240Visual
	If nPosDesp > 0
		aAdtoViag[nPosDesp][2] := aClone(aCols)
	Else
		AAdd(aAdtoViag,{aSavCols[nSavN][nPosVei], aClone(aCols)})
	EndIf
EndIf

aRotina	:= aClone(aSavaRotina)
aHeader := aClone(aSavHeader)
aCols	:= aClone(aSavCols)
n		:= nSavN

//-- Iniciliza as Teclas de Atalhos
TmsKeyOn(aSetKey)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³aAdtoLinOk ³ Autor ³Patricia A. Salomao   ³ Data ³22.09.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao da Linha da GetDados de Adiantamentos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³aAdtoLinOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function aAdtoLinOk()

Local lRet := .T.
Local cBco := GdFieldGet('DG_BANCO',  n)
Local cAge := GdFieldGet('DG_AGENCIA',n)
Local cCta := GdFieldGet('DG_NUMCON', n)

Local lGerTit     := GetMV('MV_GERTIT' ,,.T.)
Local cCodFornec  := ""
Local cLjFornec   := ""
Local cNomFornec  := ""
Local cCodVenc    := ""
Local cDesABST    := Padr( SuperGetMV('MV_DESABST',,''), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Abastecimento

If !GdDeleted(n)
	If !MaCheckCols(aHeader,aCols,n)
		Return ( .F. )
	EndIf

	DT7->(dbSetOrder(1))
	If DT7->(MsSeek(xFilial('DT7')+GdFieldGet('DG_CODDES',n) ))

		If !Empty(cDesABST)
			If GdFieldGet('DG_CODDES',n) == cDesABST
				Help('',1,'TMSA240A9', , STR0044 + AllTrim(Str(n)), 3, 1 ) //"Desepesa de abastecimento somente pode ser informada no complemento da viagem " ### "Linha :"
				Return ( .F. )
			EndIf
		EndIf

		//-- Se no cadastro da despesa o campo 'Movimento bancario' tiver conteudo igual a 'Sim'
		If DT7->DT7_MOVBCO == '1' .And. cTmsErp <> '1'
			If	Empty(cBco) .Or. ;
				Empty(cAge) .Or. ;
				Empty(cCta)
				Help('',1,'TMSA24035')	//-- Informe o Banco / Agencia / No. da Conta ...
				Return ( .F. )
			EndIf
			If	!Empty(cBco) .And. ;
				!Empty(cAge) .And. ;
				!Empty(cCta)
				//-- Verifica se Banco/Agencia/Conta encontra-se bloqueado.
				If !CarregaSA6(cBco,cAge,cCta,.T.,,.T.)
					Return ( .F. )
				EndIf
			EndIf
		EndIf
	EndIf
	If	Empty(GdFieldGet('DG_TOTAL', n)) .Or. ;
		Empty(GdFieldGet('DG_VALCOB',n)) 
		Help('',1,'TMSA24007', , STR0044 + AllTrim(Str(n)), 3, 1 ) //"Existem campos com valores zerados" ### "Linha :"
		Return ( .F. )
	EndIf
	
	if lGerTit	
		If !Empty(cBco)		
			IF !Empty(M->DTR_CODOPE)
				cCodFornec  := Posicione("DA3",1,xFilial("DA3")+M->DTR_CODVEI,"DA3_CODFOR")
				cLjFornec := Posicione("DA3",1,xFilial("DA3")+M->DTR_CODVEI,"DA3_LOJFOR")		
				cCodVenc:= Posicione('SA2',1,FwxFilial('SA2')+cCodFornec+cLjFornec,'A2_COND')		
				IF Empty(cCodVenc)
			   		cNomFornec := Posicione('SA2',1,FwxFilial('SA2')+cCodFornec+cLjFornec,'A2_NOME')
					Help('',1,'HELP',,STR0078,1,0)	
					Return .F.
				EndIF
			EndIF
		EndIF
	EndIF
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³aAdtoTudOk ³ Autor ³Patricia A. Salomao   ³ Data ³22.09.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao da Tela da GetDados de Adiantamentos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³aAdtoTudOk(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function aAdtoTudOk(nOpcx)

Local lRet     := .T.
Local nX       := 0
Local nTotal   := 0
Local lGerAdf  := GetMV("MV_GERADF",,.F.)  // Gera Titulo de Adiantamento de Frete com valor superior ao Valor do Frete+Pedagio
Local cBanco   := GdFieldGet('DG_BANCO', 1)
Local cAgencia := GdFieldGet('DG_AGENCIA', 1)
Local cConta   := GdFieldGet('DG_NUMCON', 1)
Local cCheque  := GdFieldGet('DG_NUMCHEQ', 1)

lRet := IIf(nOpcx == 3, aAdtoLinOk(), .T.)

//-- Analisa se ha itens duplicados na GetDados.
If lRet
	For nX:=1 To Len(aCols)
		If !GDDeleted(nX)
			If Empty(GdFieldGet('DG_TOTAL',nX)) .Or. Empty(GdFieldGet('DG_VALCOB',nX))
				Help('',1,'TMSA24007', , STR0044 + AllTrim(Str(nX)), 3, 1 ) //"Existem campos com valores zerados" ### "Linha :"
				Return ( .F. )
			EndIf
			If !Empty(GdFieldGet('DG_BANCO',nX)) .Or. cTMSERP == "1"
				nTotal  += GdFieldGet('DG_VALBAI', nX)
			EndIf

		EndIf
	Next
EndIf

//-- Verifica se o valor cobrado e maior que valor do adiantamento.
If !lGerADF .And. !Empty(aSavCols[nSavN][nPosValFre]) .And. nTotal > aSavCols[nSavN][nPosValFre]
	Help("",1,"TMSA24038") //"O total dos adiantamentos nao podera ser maior o valor do frete"
	Return .F.
Else
	aSavCols[nSavN][nPosValAdi] := nTotal
EndIf

If FunName() == "TMSA250"
	For nX:=1 To Len(aCols)
		If !GDDeleted(nX)
			If GdFieldGet('DG_BANCO'  , nX) != cBanco   .Or.;
				GdFieldGet('DG_AGENCIA', nX) != cAgencia .Or.;
				GdFieldGet('DG_NUMCON' , nX) != cConta   .Or.;
				GdFieldGet('DG_NUMCHEQ', nX) != cCheque
				Help(' ', 1, 'TMSA24043')  //-- "Informe o mesmo numero de Banco, Agencia,  Conta e cheque para pagamento de todas as despesas!"
				Return ( .F. )
			EndIf
		EndIf
	Next
EndIf

//-- Ponto de Entrada apos confirmar os Adiantamentos
If lRet .And. lTMA240Adt
	lRet := ExecBlock('TMA240ADT',.F.,.F.,{nOpcx,nTotal,aSavCols[nSavN][nPosValFre]})
	If	ValType(lRet) <> 'L'
		lRet := .T.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA240Grv ³ Autor ³Patricia A. Salomao   ³ Data ³23.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava o Complemento de Viagem                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA240Grv(ExpC1,ExpA1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Opcao Selecionada                                   ³±±
±±³          ³ExpA1 - array contendo os Dados do Complemento de Viagem    ³±±
±±³          ³ExpC2 - Filial Origem                                       ³±±
±±³          ³ExpC3 - Viagem                                              ³±±
±±³          ³ExpC4 - Filial da Viagem Original                           ³±±
±±³          ³ExpC5 - No. da Viagem Original                              ³±±
±±³          ³ExpC6 - Ordem do DTR                                        ³±± 
±±³          ³Expl1 - Controle para gravacao das despesas (Viagem Express)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA240Grv( nOpc, aCompl, cFilOri, cViagem, cFilVGE, cNumVGE, nOrder, lGrvExp, lAltRota, lHerda, lAltTipOpVg )

Local aAreaDTR  := DTR->(GetArea())
Local aAreaDTR2 := {}
Local nCntFor   := 0
Local nCntFo1   := 0
Local i         := 0
Local cCampo    := ""
Local cCodVei   := ""
Local cCodRB1   := ""
Local cCodRB2   := ""
Local cCodRB3   := ""
Local cSeek     := ""
Local cCodForn  := ""
Local cLojForn  := ""
Local cCusMed   := GetMv("MV_CUSMED")
Local nItem     := 0
Local lRet		:=.T.
Local lContVei  := GetMV('MV_CONTVEI',,.T.) // Parametro para verificar se o sistema devera' controlar veiculo/motorista
Local lMV_EmViag:= GetMV('MV_EMVIAG',,.F.) 
Local lDigita   := .F.  //-- Mostra Lanctos. Contabeis ?
Local lAglutina := .F.  //-- Aglutina Lanctos. Contabeis ?
Local lValInf   := TableInDic("DVW")
Local cTMSOPdg  := SuperGetMV( 'MV_TMSOPDG',, '0' )
Local nOpcDF7   := nOpc
Local nAux      := 0
Local lIdenDTQ  := DTQ->(FieldPos("DTQ_IDENT")) > 0 .And. nModulo<>43
Local cIdent    := Iif(lIdenDTQ,Posicione('DTQ',2,xFilial('DTQ')+cFilOri+cViagem,'DTQ_IDENT'),'')
Local cTipUso   := IIf(nModulo == 43 ,"1" ,"2")
Local lTipCrg   := DTR->(FieldPos("DTR_TIPCRG")) > 0
Local cAliasSDG := ""
Local lTercRbq  := DTR->(ColumnPos("DTR_CODRB3")) > 0	
Local cChaveDJA := ""
Local cChaveDJA1:= ""
Local cChaveDJA2:= ""
Local lTabRRE   := TableInDic('DJA')
Local lDelTit	:= .T.
Local lMovBco	:= .T.
Local aSX5		:= {}
Local lM_OBS := Type("M->DTR_OBS") <> "U"
Local lM_TIPCRG := Type('M->DTR_TIPCRG') <> "U"
Local cQuery    := ""
Local aYesCampo := {}
Local aHerCampo := {}
Local cSeekDTR  := ""
Local lTabDLD   := TableInDic('DLD')
Local lDTRTPSPDG:= DTR->(ColumnPos("DTR_TPSPDG")) > 0
Local lDTRCodFav:= DTR->(ColumnPos("DTR_CODFAV")) > 0
Local cCodFavDTR:= ""
Local cLojFavDTR:= ""
Local aAreaDUD := DUD->(GetArea())
Local aCabSDG	:= {}
Local lGerador  := SDG->(ColumnPos("DG_GERADOR") > 0)

Private nHdlPrv     :=  0   // Endereco do arquivo de contra prova dos lanctos cont.
Private lCriaHeader := .T. // Para criar o header do arquivo Contra Prova
Private cLote       := ''  // Numero do lote para lancamentos do TMS
Private nTotal      := 0 	// Total dos lancamentos contabeis
Private cArquivo    := ''  // Nome do arquivo contra prova
Private aRecnoSDG   := {}                                                      
Default lGrvExp     := .F.
Default lHerda      := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o custo medio e' calculado On Line               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCusMed == "O"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona numero do Lote para Lancamentos do Estoque         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aSX5  := FWGetSX5("09","TMS")
	cLote := IIF (Empty(aSX5),"TMS ",aSX5[1][4])

EndIf

Default aCompl  := {}
Default cFilOri := ""
Default cViagem := ""
Default cFilVGE := ""
Default cNumVGE := ""
Default nOrder  := 1
Default lAltRota   := .F.
Default lAltTipOpVg:= .F.

If lContVei
	//-- Quando a Viagem por planejada, trata como se o controle de veiculos estivesse desligado.
	TMSA240Off( @lContVei, .F. )
EndIf

If Len(aCompl) > 0
	aHeader    := AClone(aCompl[1])  // aHeader
	aCols      := AClone(aCompl[2])  // aCols
	aHeaderDUP := AClone(aCompl[3])  // aHeader da GetDados Motorista da Viagem
	aMotViag   := AClone(aCompl[4])  // aCols da GetDados Motorista da Viagem
	aHeaderDUQ := AClone(aCompl[5])  // aHeader da GetDados Ajudantes da Viagem
	aAjuViag   := AClone(aCompl[6])  // aCols da GetDados Ajudantes da Viagem
	aHeaderDVB := AClone(aCompl[7])  // aHeader da GetDados Lacre de Veiculo
	aLacrVei   := AClone(aCompl[8])  // aCols da GetDados Lacre de Veiculo
	aHeaderSDG := AClone(aCompl[9])  // aHeader da GetDados de Adiantamentos
	aAdtoViag  := AClone(aCompl[10]) // aCols da GetDados de Adiantamentos
	cFilVGE    := aCompl[11,1]       // Filial da Viagem Interligada
	cNumVGE    := aCompl[11,2]       // Viagem Interligada
	aValInf    := AClone(aCompl[12]) // aCols da GetDados de Valor Informado
	aHeaderDJA := Iif( lTabRRE .And. Len(aCompl) >= 15, AClone(aCompl[15]),{})  // aHeader da GetDados da Liberacao do Seguro
	aLibSeg    := Iif( lTabRRE .And. Len(aCompl) >= 16, AClone(aCompl[16]),{})  // aCols da GetDados da Liberacao do Seguro
	aHeaderDLD := Iif( lTabDLD .And. Len(aCompl) >= 17, AClone(aCompl[17]),{})  // aHeader da GetDados da Liberacao do Seguro
	aPagtoVge  := Iif( lTabDLD .And. Len(aCompl) >= 18, AClone(aCompl[18]),{})  // aCols da GetDados da Liberacao do Seguro
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o custo medio e' calculado On Line               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCusMed == 'O'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se necessario cria o cabecalho do arquivo de prova           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCriaHeader
		lCriaHeader := .F.
		nHdlPrv := HeadProva(cLote,"TMSA240",cUserName,@cArquivo)
		If nHdlPrv < 0
			Help(" ",1,"SEM_LANC") //"Nao foi possivel abrir o arquivo de Contra Prova"
			Return .F.
		EndIf
	EndIf
EndIf


If nOpc == 5

	//-- Limpa as Datas Inicio/Fim na Viagem.
	DTQ->( dbSetOrder( 2 ) )
	If DTQ->( MsSeek( xFilial('DTQ') + M->DTR_FILORI + M->DTR_VIAGEM ) )
		RecLock( "DTQ", .F. )
		DTQ->DTQ_DATINI := Ctod("")
		DTQ->DTQ_HORINI := Space( Len( DTQ->DTQ_HORINI ) )
		DTQ->DTQ_DATFIM := Ctod("")
		DTQ->DTQ_HORFIM := Space( Len( DTQ->DTQ_HORFIM ) )
		MsUnlock()
	EndIf

	//-- Verifica se existe SDG criado por outras rotinas
	If lGerador .And. ExisteSDG(M->DTR_FILORI,M->DTR_VIAGEM,M->DTR_CODVEI,"TMSA240","2")
		Help(" ",1,"TMSA240A8")	//-- Existe SDG gerado por outra rotina. O Estorno não será permitido.
		lRet := .F.
	EndIf
		
	//-- Somente permite deletar o complemento se nao existir Carregamento para a Viagem
	If lRet
		DTA->( DbSetOrder ( 2 ) )
		If !DTA->( MsSeek ( xFilial("DTA") + M->DTR_FILORI + M->DTR_VIAGEM ) )
			
			
			DTR->( DbSetOrder( 1 ) )
			While DTR->( MsSeek( xFilial('DTR') + M->DTR_FILORI + M->DTR_VIAGEM, .F. ) )
				
				If lContVei
					//-- Altera Status de Veiculo para Liberado
					aAltStaDTU("3", DTR->DTR_CODVEI)
					
					//-- Altera Status do 1o. Reboque para Liberado
					If !Empty(DTR->DTR_CODRB1)
						aAltStaDTU("3", DTR->DTR_CODRB1)
					EndIf
					
					//-- Altera Status do 2o. Reboque para Liberado
					If !Empty(DTR->DTR_CODRB2)
						aAltStaDTU("3", DTR->DTR_CODRB2)
					EndIf
					//-- Altera Status do 3o. Reboque para Liberado
					If lTercRbq .And. !Empty(DTR->DTR_CODRB3)
						aAltStaDTU("3", DTR->DTR_CODRB3)
					EndIf 
				EndIf
				
				//-- Deletar os SDG's com origem igual a DTR e estornar a Baixa dos que tiverem
				//-- origem diferente de DTR
				cAliasSDG := GetNextAlias()                        
				cQuery := 'SELECT R_E_C_N_O_ RECNOSDG FROM '
				cQuery += RetSqlName("SDG")
				cQuery += "  WHERE DG_FILIAL = '"  + xFilial("SDG") + "' "
				cQuery += "    AND DG_FILORI = '"  + DTR->DTR_FILORI + "' "
				cQuery += "    AND DG_VIAGEM = '"  + DTR->DTR_VIAGEM + "' "
				cQuery += "    AND DG_CODVEI = '"  + DTR->DTR_CODVEI + "' "
				cQuery += "    AND D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSDG, .F., .T.)
				While (cAliasSDG)->(!Eof())
					SDG->(dbGoTo((cAliasSDG)->RECNOSDG))
					lMovBco := Posicione('DT7',1,xFilial('DT7')+SDG->DG_CODDES,"DT7_MOVBCO") == '1'
					lDelTit:=  (!SDG->(ColumnPos('DG_ORITIT')) > 0 .Or. AllTrim(SDG->DG_ORITIT) == 'TMSA240') .And. (!Empty(SDG->DG_BANCO)  .Or. (cTmsErp == '1' .And. lMovBco))
					If SDG->DG_ORIGEM == 'DTR'
						If cCusMed == "O" .And. SDG->(FieldPos('DG_DTLAEMI')) > 0 .And. !Empty(SDG->DG_DTLAEMI)
							nTotal += DetProva(nHdlPrv,"904","TMSA240",cLote)
							AAdd(aRecnoSDG, SDG->(Recno()) )
						EndIf
						//-- Se for uma Despesa que movimenta financeiro, deleta o Titulo a Pagar gerado
						If lDelTit
							lRet := TMA240DelTit(DTR->DTR_CODVEI,SDG->DG_HISTOR,Iif(lDTRCodFav,DTR->DTR_CODFAV,''),Iif(lDTRCodFav,DTR->DTR_LOJFAV,''))
						EndIf
						If lRet 							
							AtuTabSDG( , 5 )							
						EndIf
					Else
						TMSA070Bx('2', SDG->DG_NUMSEQ)
					EndIf
					(cAliasSDG)->(DbSkip())
				EndDo
				(cAliasSDG)->(DbCloseArea())
				
				RecLock('DTR',.F.,.T.)
				DTR->(dbDelete())
				MsUnLock()
				DTR->(dbSkip())
			EndDo
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta os Motoristas informados para a Viagem                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DUP->( DbSetOrder( 1 ) )
			While DUP->( MsSeek( xFilial('DUP') + M->DTR_FILORI + M->DTR_VIAGEM, .F. ) )
				//-- Altera Status do Motorista	p/ Liberado
				If lContVei
					aAltStaDTO("3")
				EndIf
				RecLock('DUP',.F.,.T.)
				DUP->(dbDelete())
				MsUnLock()
				DUP->(dbSkip())
			EndDo
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta os Ajudantes informados para a Viagem                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DUQ->( DbSetOrder( 1 ) )
			While DUQ->( MsSeek( xFilial('DUQ') + M->DTR_FILORI + M->DTR_VIAGEM, .F. ) )
				RecLock('DUQ',.F.,.T.)
				DUQ->(dbDelete())
				MsUnLock()
				DUQ->(dbSkip())
			EndDo
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui Valor Informado X Viagem. 				                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DVW->( DbSetOrder( 1 ) )
			While DVW->( MsSeek( xFilial('DVW') + M->DTR_FILORI + M->DTR_VIAGEM, .F. ) )					
				RecLock('DVW',.F.,.T.)
				DVW->(DbDelete())
				MsUnLock()
			EndDo	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta os Lacres de Veiculos                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DVB->( DbSetOrder( 1 ) )
			While DVB->( MsSeek( xFilial('DVB') + M->DTR_FILORI + M->DTR_VIAGEM, .F. ) )
				DVB->(RecLock('DVB',.F.,.T.))
				DVB->(dbDelete())
				DVB->(MsUnLock())
				DVB->(dbSkip())
			EndDo
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta as Liberações de Seguro                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTabRRE
				DJA->( DbSetOrder( 1 ) )
				While DJA->( MsSeek( xFilial('DJA') + M->DTR_FILORI + M->DTR_VIAGEM, .F. ) )
					DJA->(RecLock('DJA',.F.,.T.))
					DJA->(dbDelete())
					DJA->(MsUnLock())
					DJA->(dbSkip())
				EndDo
			EndIf	
			
			If lTabDLD
				DLD->( DbSetOrder( 1 ) )
				While DLD->( MsSeek( xFilial('DLD') + M->DTR_FILORI + M->DTR_VIAGEM, .F. ) )
					DLD->(RecLock('DLD',.F.,.T.))
					DLD->(dbDelete())
					DLD->(MsUnLock())
					DLD->(dbSkip())
				EndDo
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta todas as Viagens Interligadas.                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DTR->(dbSetOrder(2)) // DTR_FILVGE + DTR_NUMVGE
			DTR->(MsSeek(xFilial('DTR')+M->DTR_FILORI+M->DTR_VIAGEM))
			Do While !DTR->(Eof()) .And. DTR->DTR_FILIAL+DTR->DTR_FILVGE+DTR->DTR_NUMVGE == xFilial('DTR')+M->DTR_FILORI+M->DTR_VIAGEM
				
				DUP->( DbSetOrder( 1 ) )
				While DUP->( MsSeek( xFilial('DUP') + DTR->DTR_FILORI+DTR->DTR_VIAGEM, .F. ) )
					//-- Altera Status do Motorista	p/ Liberado
					RecLock('DUP',.F.,.T.)
					DUP->(dbDelete())
					MsUnLock()
					DUP->(dbSkip())
				EndDo
				
				DUQ->( DbSetOrder( 1 ) )
				While DUQ->( MsSeek( xFilial('DUQ') + DTR->DTR_FILORI+DTR->DTR_VIAGEM, .F. ) )
					RecLock('DUQ',.F.,.T.)
					DUQ->(dbDelete())
					MsUnLock()
					DUQ->(dbSkip())
				EndDo
				
				SDG->(DbSetOrder(5))
				While SDG->( MsSeek(xFilial('SDG')+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_CODVEI  ) )
					//-- Deletar os SDG's com origem igual a DTR e estornar a Baixa dos que tiverem
					//-- origem diferente de DTR
					If SDG->DG_ORIGEM == 'DTR'
						If cCusMed == "O" .And. SDG->(FieldPos('DG_DTLAEMI')) > 0 .And. !Empty(SDG->DG_DTLAEMI)
							nTotal += DetProva(nHdlPrv,"904","TMSA240",cLote)
							AAdd(aRecnoSDG, SDG->(Recno()) )
						EndIf
						//-- Se for uma Despesa que movimenta financeiro, deleta o Titulo a Pagar gerado
						If !Empty(SDG->DG_BANCO)
							lRet := TMA240DelTit(DTR->DTR_CODVEI,SDG->DG_HISTOR,Iif(lDTRCodFav,DTR->DTR_CODFAV,''),Iif(lDTRCodFav,DTR->DTR_LOJFAV,''))
						EndIf
						If lRet
							AtuTabSDG(,5)							
						EndIf
					Else
						TMSA070Bx('2', SDG->DG_NUMSEQ)
					EndIf
					SDG->(dbSkip())
				EndDo
				
				RecLock("DTR", .F.)
				dbDelete()
				MsUnLock()
				DTR->(dbSkip())
			EndDo
			
			//-- Trata o Retorno de Reboque
			If Upper(AllTrim(FunName())) == "TMSA240" .Or.  Upper(AllTrim(FunName())) == "TMSA141A" 
				DF7->(DbSetOrder(3))
				If DF7->(MsSeek(xFilial('DF7') + M->(DTR_FILORI+DTR_VIAGEM)))
					RegToMemory('DF7',.F.)
					TMSAF15Grv( 5 )
				EndIf
			EndIf
	
			//-- Se o complemento de Viagens NÃO estiver sendo chamado via Rotina de 'Viagem'
			//-- Atualiza dados do Recurso da Viagem Modelo 3
			If Len(aCompl) == 0 
				If  lViagem3 .And. FindFunction('TmsAjuMod3')
					TmsAjuMod3(M->DTR_FILORI,M->DTR_VIAGEM,nOpc,.F.) 
				EndIf
			EndIf
		Else
			Help(" ",1,"TMSA24026") // Existe Carregamento para a Viagem, estorne o carregamento para permitir a exclusao do Complemento de Viagem 	
			lRet:=.F.
		EndIf
	EndIf
EndIf


If	nOpc == 3 .Or. nOpc == 4

	//-- Atualiza as Datas Inicio/Fim na Viagem.
	DTQ->( dbSetOrder( 2 ) )
	If DTQ->( MsSeek( xFilial('DTQ') + M->DTR_FILORI + M->DTR_VIAGEM ) )
		RecLock( "DTQ", .F. )
		DTQ->DTQ_DATINI := M->DTR_DATINI
		DTQ->DTQ_HORINI := M->DTR_HORINI
		DTQ->DTQ_DATFIM := M->DTR_DATFIM
		DTQ->DTQ_HORFIM := M->DTR_HORFIM
		MsUnlock()
	EndIf
		                    	
	If nOrder == 2
		A240CmpDTR(cFilOri,cViagem,nopc,@aYesCampo,@aHerCampo)
	EndIf 
	For nCntFor := 1 To Len( aCols )
		
		//-- Proprietario do Veiculo Atual
		DA3->(dbSetOrder(1))
		DA3->(MsSeek(xFilial('DA3')+ GDFieldGet("DTR_CODVEI",nCntFor) ))
		cCodForn := DA3->DA3_CODFOR
		cLojForn := DA3->DA3_LOJFOR
		If !GDDeleted( nCntFor )
		
			DTR->(dbSetOrder( nOrder ) )
			If nOrder == 2 .And. nOpc == 4
				DTR->(dbSetOrder( 1 ) )
				cSeekDTR:= xFilial('DTR')+cFilOri+cViagem+GdFieldGet('DTR_ITEM',nCntFor)
			Else
				cSeekDTR:= xFilial('DTR')+M->DTR_FILORI+M->DTR_VIAGEM+GdFieldGet('DTR_ITEM',nCntFor)
			EndIf
			
			If DTR->(MsSeek(cSeekDTR ))
				RecLock('DTR',.F.)
			Else
				RecLock('DTR',.T.)
			EndIf
			cCodVei   := DTR->DTR_CODVEI
			cCodRB1   := DTR->DTR_CODRB1
			cCodRB2   := DTR->DTR_CODRB2
			If lDTRCodFav
				cCodFavDTR:= DTR->DTR_CODFAV
				cLojFavDTR:= DTR->DTR_LOJFAV
			EndIf	

			If lTercRbq
				cCodRB3 := DTR->DTR_CODRB3
			EndIf
			
			For i := 1 TO FCount()
				If "FILIAL"$Field(i)
					FieldPut(i,xFilial('DTR'))
				Else
					cCampo :=  FieldName(i)
					If TYPE("M->"+cCampo) <> "U"
					 	If nOrder == 2 
					 		If  Ascan(aYesCampo, {|x| x == cCampo }) >  0 .Or.  ( lHerdaFrt .And. Ascan(aHerCampo, {|x| x == cCampo }) >  0 )
					 			FieldPut(i,M->&(cCampo))
					 		EndIf
					 	Else	 
							FieldPut(i,M->&(cCampo))
						EndIf	
					EnDIf
				EndIf
			Next i
			DTR->DTR_FILORI := cFilOri
			DTR->DTR_VIAGEM := cViagem
			DTR->DTR_FILVGE := cFilVGE
			DTR->DTR_NUMVGE := cNumVGE
			DTR->DTR_FRECAL := '2' //-- O Valor do Frete NAO foi Calculado
			DTR->DTR_CALRB1 := '2' //-- O Valor do Frete NAO foi Calculado	
			DTR->DTR_CALRB2 := '2' //-- O Valor do Frete NAO foi Calculado
			If DTR->(ColumnPos( 'DTR_CODRB3' )) > 0
				DTR->DTR_CALRB3 := '2' // -- O Valor do Frete NAO foi Calculado
			EndIf
			
			//salva os dados do complemento de viagem referentes ao veículo			
			For nCntFo1 := 1 To Len( aHeader )
				If	aHeader[nCntFo1,10] != 'V'
					If nOrder == 2
						If Ascan(aYesCampo, {|x| x == aHeader[nCntFo1,2] }) >  0  .Or.  ( lHerdaFrt .And. Ascan(aHerCampo, {|x| x == aHeader[nCntFo1,2] }) >  0 )
							FieldPut(FieldPos(aHeader[nCntFo1,2]), GDFieldGet( aHeader[nCntFo1,2], nCntFor ))
						EndIf
					Else
						FieldPut(FieldPos(aHeader[nCntFo1,2]), GDFieldGet( aHeader[nCntFo1,2], nCntFor ))
					EndIf	
				EndIf
			Next

			DTR->DTR_CODFOR := cCodForn
			DTR->DTR_LOJFOR := cLojForn

			//-- Grava Dados da Operadora
			If cTMSOPdg <> '0'
				DTR->DTR_CODOPE := M->DTR_CODOPE  
				If lDTRTPSPDG	  
					DTR->DTR_TPSPDG := M->DTR_TPSPDG 
					DTR->DTR_QTDTRA := M->DTR_QTDTRA 
					DTR->DTR_QTDSAQ := M->DTR_QTDSAQ 
				EndIf
			EndIf 
				
			If lTipCrg
			 	DTR->DTR_TIPCRG := IIF(lM_TIPCRG, M->DTR_TIPCRG,"")
		  	EndIf
				
			If lAltRota .Or. lAltTipOpVg
				DTR->DTR_VALFRE := M->DTR_VALFRE
				DTR->DTR_VALPDG := M->DTR_VALPDG				
			EndIf
			
			DTR->DTR_PRCTRA := M->DTR_PRCTRA 
			MsUnLock()			
						
			//-- Grava Observacao da Viagem na chamada efetuada atraves do menu.
			If lM_OBS .And. Left(FunName(1),7) == "TMSA240"
				DTQ->(dbSetOrder(2))
				DTQ->(MsSeek(xFilial('DTQ')+M->DTR_FILORI+M->DTR_VIAGEM))
				MSMM(DTQ->DTQ_CODOBS,,,M->DTR_OBS,1,,,"DTQ","DTQ_CODOBS")
			EndIf
			
			//-- Controla Motoristas / Veiculos da Viagem
			If lContVei
				//-- Se Alterou o Codigo do Veiculo, tem que Alterar o Status do Veic. Anterior p/Liberado
				If !Empty(cCodVei) .And. cCodVei <> GdFieldGet('DTR_CODVEI',nCntFor)
					//-- Altera Status de Veiculo para Liberado
					aAltStaDTU("3", cCodVei)
				EndIf
				
				//-- Se Alterou o Codigo do 1o.Reboque, tem que Alterar o Status do 1o.Reboque.Anterior p/Liberado
				If !Empty(cCodRB1) .And. cCodRB1 <> GdFieldGet('DTR_CODRB1',nCntFor)
					//-- Altera Status do 1o. Reboque para Liberado
					aAltStaDTU("3", cCodRB1)
				EndIf
				
				// Se Alterou o Codigo do 2o.Reboque, tem que Alterar o Status do 2o.Reboque.Anterior p/Liberado
				If !Empty(cCodRB2) .And. cCodRB2 <> GdFieldGet('DTR_CODRB2',nCntFor)
					//-- Altera Status do 2o. Reboque para Liberado
					aAltStaDTU("3", cCodRB2)
				EndIf
				
				// Se Alterou o Codigo do 3o.Reboque, tem que Alterar o Status do 3o.Reboque.Anterior p/Liberado
				If lTercRbq .And. !Empty(cCodRB3) .And. cCodRB3 <> GdFieldGet('DTR_CODRB3',nCntFor)
					//-- Altera Status do 3o. Reboque para Liberado
					aAltStaDTU("3", cCodRB3)
				EndIf 
				//-- Altera Status do Veiculo para Reservado
				aAltStaDTU("2", DTR->DTR_CODVEI, M->DTR_FILORI, M->DTR_VIAGEM, cTipUso, cIdent)
				
				//-- Altera Status do 1o. Reboque para Reservado
				If !Empty(DTR->DTR_CODRB1)
					aAltStaDTU("2", DTR->DTR_CODRB1, M->DTR_FILORI, M->DTR_VIAGEM, cTipUso, cIdent)
				EndIf
				
				//-- Altera Status do 2o. Reboque para Reservado
				If !Empty(DTR->DTR_CODRB2)
					aAltStaDTU("2", DTR->DTR_CODRB2, M->DTR_FILORI, M->DTR_VIAGEM, cTipUso, cIdent)
				EndIf
				//-- Altera Status do 3o. Reboque para Reservado
				If lTercRbq .And. !Empty(DTR->DTR_CODRB3)
					aAltStaDTU("2", DTR->DTR_CODRB3, M->DTR_FILORI, M->DTR_VIAGEM, cTipUso, cIdent)
				EndIf
			EndIf

			If lContVei .Or. lMV_EmViag
				//Apos mudar o status do veiculo ja pode destravar, pois os proximos
				//usuarios nao poderao mais escolher o veiculo, utilizado quando
				//o controle de veiculos esta ligado
				UnLockByName("VGEVEI" + DTR->DTR_CODVEI,.T.,.F.)
				UnLockByName("VGERB1" + DTR->DTR_CODRB1,.T.,.F.)
				UnLockByName("VGERB2" + DTR->DTR_CODRB2,.T.,.F.)
				If lTercRbq
					UnLockByName("VGERB3" + DTR->DTR_CODRB3,.T.,.F.)
				EndIf	
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os Motoristas da Viagem                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			A240AtuDUP(aHeaderDUP, aMotViag)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os Ajudantes da Viagem                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			A240AtuDUQ(aHeaderDUQ, aAjuViag)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os Lacres de Veiculos                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			A240AtuDVB(aHeaderDVB, aLacrVei)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os Adiantamentos da Viagem                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//-- Se Alterou o Codigo do Veiculo, atualizar SDG do veiculo anterior
			If !Empty(cCodVei) .And. cCodVei <> GdFieldGet('DTR_CODVEI',nCntFor)
				SDG->(DbSetOrder(5))
				SDG->(MsSeek( xFilial('SDG') + DTR->DTR_FILORI+DTR->DTR_VIAGEM+cCodVei ) )
				While lRet .And. !SDG->(Eof()) .And. SDG->DG_FILIAL+SDG->DG_FILORI+SDG->DG_VIAGEM+SDG->DG_CODVEI == xFilial('SDG')+DTR->DTR_FILORI+DTR->DTR_VIAGEM+cCodVei
					//-- Deletar os SDG's com origem igual a DTR e estornar a Baixa dos que tiverem
					//-- origem diferente de DTR
					If SDG->DG_ORIGEM == 'DTR'
						If cCusMed == "O" .And. SDG->(FieldPos('DG_DTLAEMI')) > 0  .And. !Empty(SDG->DG_DTLAEMI)
							nTotal += DetProva(nHdlPrv,"904","TMSA240",cLote)
							AAdd(aRecnoSDG, SDG->(Recno()) )
						EndIf
						//-- Se for uma Despesa que movimenta financeiro, deleta o Titulo a Pagar gerado
						If !Empty(SDG->DG_BANCO)
							lRet := TMA240DelTit(cCodVei,SDG->DG_HISTOR,cCodFavDTR,cLojFavDTR)
						EndIf
						If lRet							
							AtuTabSDG(,5)
						EndIf
					Else
						TMSA070Bx('2', SDG->DG_NUMSEQ)
					EndIf
					SDG->(dbSkip())
				EndDo
			EndIf
			
			//-- Atualizar SDG do Veiculo Atual
			nItem := Ascan(aAdtoViag,{|x| x[1] == DTR->DTR_CODVEI })
			If lRet
				If nItem > 0 .And. !lGrvExp 
					lRet := A240AtuSDG(nOpc, aHeaderSDG, aAdtoViag, M->DTR_FILORI, M->DTR_VIAGEM, DTR->DTR_CODVEI, nItem,;
				             DTR->DTR_CREADI, DTR->DTR_LOJCRE, cCodForn, cLojForn, M->DTR_CODOPE,0/*DTR->DTR_PRVFRE*/,Iif(lDTRCodFav,DTR->DTR_CODFAV,''),Iif(lDTRCodFav,DTR->DTR_LOJFAV,''))
				EndIf
			EndIf
			
			//-- Tratamento do Retorno de Reboque
			If lRet .And. (Upper(AllTrim(FunName())) == "TMSA240" .Or. Upper(AllTrim(FunName())) == "TMSA141A")
				If Len(aRetRbq) == 0
					DF7->(DbSetOrder(3)) //-- DF7_FILIAL+DF7_FILDTR+DF7_VGEDTR+DF7_CODVEI
					If DF7->(MsSeek(xFilial('DF7') + M->(DTR_FILORI + DTR_VIAGEM) + GdFieldGet('DTR_CODVEI',nCntFor) ))
						For nAux := 1 To DF7->(FCount())
							AAdd( aRetRbq, { DF7->(FieldName(nAux)), DF7->&(DF7->(FieldName(nAux))) } )
						Next
					EndIf
				EndIf
				
				If Len(aRetRbq) > 0
					aRetRbq[ aScan(aRetRbq, {|x| x[1] == 'DF7_FILDTR'}), 2] := M->DTR_FILORI
					aRetRbq[ aScan(aRetRbq, {|x| x[1] == 'DF7_VGEDTR'}), 2] := M->DTR_VIAGEM
					If nOpc == 4
						DF7->(DbSetOrder(3))
						If !DF7->(MsSeek(xFilial('DF7') + M->(DTR_FILORI+DTR_VIAGEM)))
							nOpcDF7 := 3
						EndIf
					EndIf
					TMSAF15Grv( nOpcDF7, aRetRbq )
				EndIf
			EndIf
		
			//-- Tratamento para carregamento por veiculo (Internacional)
			If lRet .And. !Empty(cCodVei)
				DTA->(dbSetOrder(5))
				DTA->(dbSeek(cSeekDTA := xFilial('DTA')+M->DTR_FILORI+M->DTR_VIAGEM+cCodVei))
				While DTA->(!Eof()) .And. DTA->(DTA_FILIAL+DTA_FILORI+DTA_VIAGEM+DTA_CODVEI) == cSeekDTA
					DTA->(dbSkip())
					nRecAux := DTA->(Recno())
					DTA->(dbSkip(-1))
					If DTA->DTA_FILATU == cFilAnt
						RecLock('DTA',.F.)
						DTA->DTA_CODVEI := GdFieldGet('DTR_CODVEI',nCntFor)
						MsUnLock()
					EndIf
					DTA->(dbGoTo(nRecAux))
				EndDo
				DTX->(dbSetOrder(5))
				DTX->(dbSeek(cSeekDTX := xFilial('DTX')+M->DTR_FILORI+M->DTR_VIAGEM+cCodVei))
				While DTX->(!Eof()) .And. DTX->(DTX_FILIAL+DTX_FILORI+DTX_VIAGEM+DTX_CODVEI) == cSeekDTX
					DTX->(dbSkip())
					nRecAux := DTX->(Recno())
					DTX->(dbSkip(-1))
					If DTX->DTX_FILMAN == cFilAnt
						RecLock('DTX',.F.)
						DTX->DTX_CODVEI := GdFieldGet('DTR_CODVEI',nCntFor)
						MsUnLock()
					EndIf
					DTX->(dbGoTo(nRecAux))
				EndDo
			EndIf															

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os dados da Liberacao do Seguro	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTabRRE .And. nCntFor == Len(aCols)   //Atualiza Tabela DJA somente no final
				A240AtuDJA(aHeaderDJA, aLibSeg)
			EndIf	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os Vinculos do Pagamento da Viagem
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTabDLD .And. DTR->DTR_CODOPE == '02'  //Pamcard
				A240AtuDLD(aHeaderDLD, aPagtoVge)
			EndIf
		Else
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se Deletar a Linha, Atualizar todos os Arquivos ...          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			DTR->(dbSetOrder( nOrder ) )
			If nOrder == 2 .And. nOpc == 4
				DTR->(dbSetOrder( 1 ) )
				cSeekDTR:= xFilial('DTR')+cFilOri+cViagem+GdFieldGet('DTR_ITEM',nCntFor)
			Else
				cSeekDTR:= xFilial('DTR')+M->DTR_FILORI+M->DTR_VIAGEM+GdFieldGet('DTR_ITEM',nCntFor)
			EndIf
			
			If DTR->(MsSeek(cSeekDTR ))
				lRet := .T.
				If DTA->(FieldPos('DTA_CODVEI')) > 0
					DTA->(dbSetOrder(5))
					If DTA->(dbSeek(xFilial('DTA')+M->DTR_FILORI+M->DTR_VIAGEM+cCodVei))
						aAreaDTR2:= DTR->(GetArea()) 
						lRet:= TMSA210Mnt( 'DTA', DTA->(Recno()), 4,,,,.F. )
						RestArea(aAreaDTR2)
					EndIf  
				EndIf	
				//-- Se Controla Motorista/Veiculo da Viagem
				If lRet .And. lContVei
					//-- Altera Status do Veiculo para Liberado
					aAltStaDTU("3", DTR->DTR_CODVEI)
					
					//-- Altera Status do 1o. Reboque para Liberado
					If !Empty(DTR->DTR_CODRB1)
						aAltStaDTU("3", DTR->DTR_CODRB1)
					EndIf
					
					//-- Altera Status do 2o. Reboque para Liberado
					If !Empty(DTR->DTR_CODRB2)
						aAltStaDTU("3", DTR->DTR_CODRB2)
					EndIf
					//-- Altera Status do 3o. Reboque para Liberado
					If lTercRbq .And. !Empty(DTR->DTR_CODRB3)
						aAltStaDTU("3", DTR->DTR_CODRB3)
					EndIf 
				EndIf
				
				DUP->(DbSetOrder(1))
				While lRet .And. DUP->( MsSeek( xFilial('DUP') + DTR->DTR_FILORI + DTR->DTR_VIAGEM + GdFieldGet('DTR_ITEM',nCntFor), .F. ) )
					//-- Altera Status do Motorista	p/ Liberado
					If lContVei
						aAltStaDTO("3")
					EndIf
					If lTabRRE
						DJA->( DbSetOrder( 1 ) )
						If DJA->(MsSeek(cSeek := xFilial('DJA') + DTR->DTR_FILORI+DTR->DTR_VIAGEM+'DA4'  ) )
							While !DJA->(Eof()) .And. DJA->(DJA_FILIAL+DJA_FILORI+DJA_VIAGEM+DJA_ALIAS) == cSeek
								If AllTrim(DJA->DJA_CHAVE) == AllTrim(xFilial("DA4")+DUP->DUP_CODMOT)
									RecLock('DJA',.F.,.T.)                 
									DJA->(dbDelete())
									MsUnLock()
								EndIf	
								DJA->(dbSkip())
							EndDo
						EndIf
					EndIf
					RecLock('DUP',.F.,.T.)
					DUP->(dbDelete())
					MsUnLock()
					DUP->(dbSkip())
				EndDo
				
				DUQ->(DbSetOrder(1))
				While lRet .And. DUQ->( MsSeek( xFilial('DUQ') + DTR->DTR_FILORI + DTR->DTR_VIAGEM+GdFieldGet('DTR_ITEM',nCntFor), .F. ) )
					RecLock('DUQ',.F.,.T.)
					DUQ->(dbDelete())
					MsUnLock()
					DUQ->(dbSkip())
				EndDo
				
				SDG->(DbSetOrder(5))
				If lRet .And. SDG->(MsSeek(cSeek := xFilial('SDG') + DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_CODVEI  ) )
					While !SDG->(Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM+DG_CODVEI) == cSeek
						//-- Deletar os SDG's com origem igual a DTR e estornar a Baixa dos que tiverem
						//-- origem diferente de DTR
						If SDG->DG_ORIGEM == 'DTR'
							If cCusMed == "O" .And. SDG->(FieldPos('DG_DTLAEMI')) > 0 .And. !Empty(SDG->DG_DTLAEMI) .And. !Empty(SDG->DG_DTLAEMI)
								nTotal += DetProva(nHdlPrv,"904","TMSA240",cLote)
								AAdd(aRecnoSDG, SDG->(Recno()) )
							EndIf
							//-- Se for uma Despesa que movimenta financeiro, deleta o Titulo a Pagar gerado
							If !Empty(SDG->DG_BANCO)
								lRet := TMA240DelTit(DTR->DTR_CODVEI,SDG->DG_HISTOR,Iif(lDTRCodFav,DTR->DTR_CODFAV,''),Iif(lDTRCodFav,DTR->DTR_LOJFAV,''))
							EndIf
							If lRet							
								AtuTabSDG(,5)
							EndIf
						Else
							TMSA070Bx('2', SDG->DG_NUMSEQ)
						EndIf
						SDG->(dbSkip())
					EndDo
				EndIf
				
				DVB->( DbSetOrder( 1 ) )
				While lRet .And. DVB->( MsSeek( xFilial('DVB') + DTR->DTR_FILORI + DTR->DTR_VIAGEM+GdFieldGet('DTR_CODVEI',nCntFor), .F. ) )
					RecLock('DVB',.F.,.T.)
					DVB->(dbDelete())
					MsUnLock()
					DVB->(dbSkip())
				EndDo
				
				If lRet .And. lTabRRE
				   	cChaveDJA:= AllTrim(xFilial("DA3") + GdFieldGet('DTR_CODVEI',nCntFor))
				   	If !Empty(GdFieldGet('DTR_CODRB1',nCntFor)) 
					   	cChaveDJA1:= AllTrim(xFilial("DA3") + GdFieldGet('DTR_CODRB1',nCntFor))
				   	EndIf
				   	If !Empty(GdFieldGet('DTR_CODRB2',nCntFor))
				   		cChaveDJA2:= AllTrim(xFilial("DA3") + GdFieldGet('DTR_CODRB2',nCntFor))
				   	EndIf
				   	
					DJA->( DbSetOrder( 1 ) )
					If DJA->(MsSeek(cSeek := xFilial('DJA') + DTR->DTR_FILORI+DTR->DTR_VIAGEM+'DA3'  ) )
						While !DJA->(Eof()) .And. DJA->(DJA_FILIAL+DJA_FILORI+DJA_VIAGEM+DJA_ALIAS) == cSeek
							If AllTrim(DJA->DJA_CHAVE) == cChaveDJA .Or. AllTrim(DJA->DJA_CHAVE) == cChaveDJA1 .Or. AllTrim(DJA->DJA_CHAVE) == cChaveDJA2
								RecLock('DJA',.F.,.T.)                 
								DJA->(dbDelete())
								MsUnLock()
							EndIf	
							DJA->(dbSkip())
						EndDo
					EndIf
				EndIf
				If lRet
					RecLock("DTR", .F.)
					dbDelete()
					MsUnLock()
				EndIf
			EndIf
			
		EndIf
	Next nCntFor
	
	//-- Se o complemento de Viagens estiver sendo chamado via Rotina de 'Viagem', gravar o Valor Informado digitado
	If lRet .And. Len(aCompl) > 0 .And. lValInf
		TmsGrvInf(aValInf,'4',M->DTR_FILORI,,,,,,,,nOpc,M->DTR_VIAGEM)
	EndIf
	//Altera veículo caso configurado no contrato
	If lRet
		dbSelectArea("DTQ")
		DTQ->(dbSetOrder(2)) //Filial + Fil.Origem + Viagem + Rota
		If MsSeek(xFilial("DTQ")+M->DTR_FILORI+M->DTR_VIAGEM)
			dbSelectArea("DUD")
			DUD->(dbSetOrder(2)) //Filial + Fil.Origem + Viagem + Sequencia + Fil.Docto. + No.Docto. + Serie Docto
			If MsSeek(xFilial("DUD")+DTQ->(DTQ_FILORI+DTQ_VIAGEM))
				DbSelectArea("DTC")
				DTC->(dbSetOrder(3)) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Servico + Cod. Produto
				If MsSeek(xFilial("DTC")+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE))				
					While DTC->(!EOF() .And. DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE == xFilial("DTC")+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE)				 
						TmsAltVeic(DTC->DTC_NCONTR,DTC->DTC_CODNEG,DTC->DTC_FILORI,DTC->DTC_LOTNFC,DTC->DTC_NUMNFC,DTC->DTC_SERNFC,DTC->DTC_CLIREM,;
							DTC->DTC_LOJREM,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTC->DTC_SERTMS,DTC->DTC_TIPTRA,DTC->DTC_SERVIC)
						DTC->(DbSkip())
					EndDo	
				EndIf	
			EndIf	
		EndIf
	EndIf	

	//-- Se o complemento de Viagens NÃO estiver sendo chamado via Rotina de 'Viagem'
	//-- Atualiza dados da Viagem Modelo 3
	If lRet .And. Len(aCompl) == 0 
		If lViagem3 .And. FindFunction('TmsAjuMod3')
			TmsAjuMod3(M->DTR_FILORI,M->DTR_VIAGEM,nOpc,.F.)
		EndIf
	EndIf

EndIf
//-- Ponto de Entrada apos gravacao do complemento de viagem
If	ExistBlock('TMA240GRV')
	ExecBlock('TMA240GRV',.F.,.F.,{nOpc,lRet})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o custo medio e' calculado On Line               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. cCusMed == "O" .And. nTotal > 0
	
	Pergunte("TMA240",.F.)
	lDigita   := Iif(mv_par01 == 1,.T.,.F.)  //-- Mostra Lanctos. Contabeis ?
	lAglutina := Iif(mv_par02 == 1,.T.,.F.)  //-- Aglutina Lanctos. Contabeis ?
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se ele criou o arquivo de prova ele deve gravar o rodape'    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RodaProva(nHdlPrv,nTotal)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para Lan‡amento Cont bil 							  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglutina)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Data da Contabilizacao no SDG      			  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCntFor := 1 To Len(aRecnoSDG)
		SDG->(dbGoTo(aRecnoSDG[nCntFor]))
		
		If nOpc == 5
			FwFreeArray( aCabSDG )
			aCabSDG		:= {} 
			//-- Se exclusao, limpa o campo
			Aadd( aCabSDG , { "DG_DTLAEMI" , Ctod("")  , Nil })
			
			AtuTabSDG( aCabSDG , 4 )
  
		Else
			//-- Data de lancamento contabil a partir da Emissao da Despesa
			FwFreeArray( aCabSDG )
			aCabSDG		:= {} 
			
			Aadd( aCabSDG , { "DG_DTLAEMI" , dDataBase  , Nil })
			
			AtuTabSDG( aCabSDG , 4 )
		EndIf
	
	Next
EndIf
RestArea( aAreaDTR )

RestArea(aAreaDUD)

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A240AtuDUQ³ Autor ³Patricia A. Salomao    ³ Data ³23.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza os Campos do Arq. DUQ (Ajudantes da Viagem)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A240AtuDUQ(ExpA1,ExpA2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - aHeader Auxiliar Getdados de Ajudantes  da Viagem   ³±±
±±³          ³ExpA2 - Array contendo os Ajudantes  da Viagem              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A240AtuDUQ(aHeaderDUQ, aAjuViag, cFilOri, cViagem, cIteDTR, cCodVei)

Local aArea     := GetArea()
Local aAreaDTR := DTR->( GetArea() )
Local nX,nZ,nY

Default cFilOri := DTR->DTR_FILORI
Default cViagem := DTR->DTR_VIAGEM
Default cIteDTR := DTR->DTR_ITEM
Default cCodVei := DTR->DTR_CODVEI


dbSelectArea("DUQ")
nX := aScan(aAjuViag,{|x| x[1] == cIteDTR}) //-- Verifica se foi informado Ajudante  para o Item
If nX > 0
	DUQ->(dbSetOrder(1))
	While DUQ->(MsSeek(xFilial('DUQ')+cFilOri+cViagem+cIteDTR))
		RecLock("DUQ",.F.)
		DUQ->(dbDelete())
		MsUnLock()
		DUQ->(dbSkip())
	EndDo
	
	For nZ := 1 to Len(aAjuViag[nX][2])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os dados contidos na GetDados                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !aAjuViag[nX][2][nZ][Len(aAjuViag[nX][2][nZ])] //-- Verifica se a linha esta deletada
			RecLock("DUQ",.T.)
			For nY := 1 to Len(aHeaderDUQ)
				If aHeaderDUQ[nY][10] # "V"
					DUQ->(FieldPut(FieldPos(Trim(aHeaderDUQ[nY][2])),aAjuViag[nX][2][nZ][nY]))
				EndIf
			Next nY
			DUQ->DUQ_FILIAL := xFilial('DUQ')
			DUQ->DUQ_FILORI := cFilOri
			DUQ->DUQ_VIAGEM := cViagem
			DUQ->DUQ_ITEDTR := cIteDTR
			DUQ->DUQ_CODVEI := cCodVei
			MsUnlock()
			//-- Destrava o Ajudante apos a gravacao
			UnLockByName("VGEAJU" + DUQ->DUQ_CODAJU,.T.,.F.)
		EndIf
	Next
EndIf

RestArea(aAreaDTR)
RestArea( aArea )

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A240AtuDUP³ Autor ³Patricia A. Salomao    ³ Data ³23.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza os Campos do Arq. DUP (Motorista da Viagem)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A240AtuDUP(ExpA1,ExpA2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - aHeader Auxiliar Getdados de Motoristas da Viagem  ³±±
±±³          ³ ExpA2 - Array contendo os Motoristas da Viagem             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A240AtuDUP(aHeaderDUP, aMotViag, cFilOri, cViagem, cIteDTR, cCodVei)

Local aArea    := GetArea()
Local aAreaDA4 := DA4->( GetArea() )
Local aAreaDTR := DTR->( GetArea() )
Local lContVei := GetMV('MV_CONTVEI',,.T.)
Local lMV_EmViag := GetMV('MV_EMVIAG',,.F.)
Local cSeekDUP := ""
Local nX,nZ,nY,nLibSeg,nValSeg,nCodMot,nTipMot
Local cMV_TMSRRE   := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
Local lTabRRE      := "3" $ cMV_TMSRRE 

Default cFilOri := DTR->DTR_FILORI
Default cViagem := DTR->DTR_VIAGEM
Default cIteDTR := DTR->DTR_ITEM
Default cCodVei := DTR->DTR_CODVEI

If lContVei
	//-- Quando a Viagem por planejada, trata como se o controle de veiculos estivesse desligado.
	TMSA240Off( @lContVei, .F. )
EndIf

dbSelectArea("DUP")
nX := aScan(aMotViag,{|x| x[1] == cIteDTR}) //-- Verifica se foi informado Motorista para o Item
If nX > 0
	DUP->(dbSetOrder(1))
	DUP->(MsSeek(cSeekDUP := xFilial('DUP')+cFilOri+cViagem+cIteDTR))
	While DUP->(!Eof() .And. DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_ITEDTR == cSeekDUP)
		//-- Altera Status do Motorista	para Liberado
		If lContVei
			aAltStaDTO("3")
		EndIf
		RecLock("DUP",.F.)
		DUP->(dbDelete())
		DUP->(MsUnLock())
		DUP->(dbSkip())
	EndDo
	
	For nZ := 1 to Len(aMotViag[nX][2])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os dados contidos na GetDados                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !aMotViag[nX][2][nZ][Len(aMotViag[nX][2][nZ])] //-- Verifica se a linha esta deletada
			RecLock("DUP",.T.)
			For nY := 1 to Len(aHeaderDUP)
				If aHeaderDUP[nY][10] # "V"
					If aHeaderDUP[nY][8] == ValType(aMotViag[nX][2][nZ][nY])
						DUP->(FieldPut(FieldPos(Trim(aHeaderDUP[nY][2])),aMotViag[nX][2][nZ][nY]))
					EndIf
				EndIf
			Next nY
			DUP->DUP_FILIAL := xFilial('DUP')
			DUP->DUP_FILORI := cFilOri
			DUP->DUP_VIAGEM := cViagem
			DUP->DUP_ITEDTR := cIteDTR
			DUP->DUP_CODVEI := cCodVei

			//--- Se informado a Forma de Pagamento, permanecer os IDs somente da DLD

			MsUnlock()
			//--Destrava o Motorista apos a gravacao
			If lContVei .Or. lMV_EmViag
				UnLockByName("VGEMOT" + DUP->DUP_CODMOT,.T.,.F.)
			EndIf
			
			//-- Altera Status do Motorista	p/ Reservado
			If lContVei
				aAltStaDTO("2",cFilOri,cViagem)
			Else
				nLibSeg := Ascan(aHeaderDUP, {|x|  x[2] == "DUP_LIBSEG" })
				nValSeg := Ascan(aHeaderDUP, {|x|  x[2] == "DUP_VALSEG" })
				nTipMot := Ascan(aHeaderDUP, {|x|  x[2] == "DUP_TIPMOT" })
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava dados do seguro no cadastro de motorista            ³
				//|Somente se houver dados do seguro e se o motorista nao for|
				//|proprio                                                   |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nLibSeg > 0 .And. nValSeg > 0
					nCodMot := Ascan(aHeaderDUP, {|x|  x[2] == "DUP_CODMOT" })
					DA4->(dbSetOrder(1))
					If DA4->(MsSeek(xFilial("DA4")+aMotViag[nX][2][nZ][nCodMot]))
						RecLock("DA4",.F.)
						If !Empty(aMotViag[nX][2][nZ][nLibSeg]) .And. !lTabRRE   
							DA4->DA4_LIBSEG := aMotViag[nX][2][nZ][nLibSeg]
						EndIf
						If Iif( ValType(aMotViag[nX][2][nZ][nValSeg]) == 'C', Val( aMotViag[nX][2][nZ][nValSeg] ), aMotViag[nX][2][nZ][nValSeg])> 0
							DA4->DA4_VALSEG := Iif( ValType(aMotViag[nX][2][nZ][nValSeg]) == 'C', Val( aMotViag[nX][2][nZ][nValSeg] ), aMotViag[nX][2][nZ][nValSeg])
						EndIf
						DA4->(MsUnlock())
					EndIf
				EndIf
			EndIf
		EndIf
	Next
EndIf

RestArea(aAreaDTR)
RestArea(aAreaDA4)
RestArea(aArea)
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A240AtuSDG³ Autor ³Patricia A. Salomao    ³ Data ³22.09.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o arquivo SDG (Custos da Viagem)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A240AtuSDG(ExpA1,ExpA2,ExpC1,ExpC2,ExpC3,ExpN1)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±³          ³ExpA1 - aHeader Auxiliar Getdados de Adiantamentos          ³±±
±±³          ³ExpA2 - Array contendo os Adiantamentos da Viagem           ³±±
±±³          ³ExpC1 - Filial de Origem da Viagem                          ³±±
±±³          ³ExpC2 - No. da Viagem                                       ³±±
±±³          ³ExpC3 - Codigo do Veiculo                                   ³±±
±±³          ³ExpN2 - Item do DTR                                         ³±±
±±³          ³ExpC4 - Credor do Adiantamento                              ³±±
±±³          ³ExpC5 - Loja do Credor                                      ³±±
±±³          ³ExpC6 - Proprietario do Veiculo                             ³±±
±±³          ³ExpC7 - Loja do Proprietario                                ³±±
±±³          ³ExpC8 - Codigo do Operador de Frete                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A240AtuSDG(nOpcx, aHeaderSDG, aAdtoViag, cFilOri, cViagem, cCodVei, nItem,;
cCreAdi, cLojCre, cCodForn, cLojForn, cCodOpe,nValProvi,cCodFavDTR,cLojFavDTR)

Local aArea      := GetArea()
Local cNumSeq    := ''
Local cTipoDoc   := Padr( "PA", Len( SE5->E5_TIPODOC ) )
Local cDoc       := NextNumero("SDG",1,"DG_DOC",.T.)
Local cPrefixo   := TMA250GerPrf(cFilAnt)
Local cParcela   := StrZero(1, Len(SE2->E2_PARCELA))
Local cParc      := StrZero(1, Len(SE2->E2_PARCELA))
Local cCusMed    := GetMv("MV_CUSMED")
Local aCotacao   := {1,RecMoeda(dDataBase,2),RecMoeda(dDataBase,3),RecMoeda(dDataBase,4),RecMoeda(dDataBase,5)}
Local aDadosBco  := {}
Local aHistor    := {}
Local nPosNSeq   := Ascan( aHeaderSDG, { | e | AllTrim(e[2]) == "DG_NUMSEQ" } )
Local nPosVBai   := Ascan( aHeaderSDG, { | e | AllTrim(e[2]) == "DG_VALBAI" } )
Local nPosTDes   := Ascan( aHeaderSDG, { | e | AllTrim(e[2]) == "DG_TIPDES" } )
Local nValBai    := 0
Local nItemSDG   := 0
Local nZ         := 0
Local nY         := 0
Local nSeek      := 0
Local lRet       := .T.
Local lNewSDG    := .F.
Local lNewSDGPA  := .F.
Local lDelTit    := .F.
Local lMovBcoChq := .T. //-- Gera movimento bancario sem cheque?    
Local lMsBlQl    := .F.
Local cHistory 	 := "" 
Local aContrat   := {}
Local lPaMovBco	 := .T.
Local cHistory2	 := "" 
Local cChaveSDG	 := ''
Local lForn      := SDG->(ColumnPos("DG_CODFOR") > 0 )
Local lDesMovBco := .F.
Local cSerTms2   := ''
Local cTipTra2   := ''
Local cTipVei	:= ""
Local cTipOpVg	:= ""
Local aCabSDG	:= {}
Local lGerador  := SDG->(ColumnPos("DG_GERADOR") > 0)
Local nPosGer   := 0 

Private lMsHelpAuto := .T.
Private oDTClass    := NIL

Default cCodope	 := ""    
Default cCodForn := ''
Default cLojForn := ''                             
Default nValProvi   := 0  //| valor do frete pagar de provisão
Default cCodFavDTR  := ""
Default cLojFavDTR  := ""

cHistory := STR0022 + cFilOri + '/' + STR0007 + cViagem//--Filial de Origem//--'Viagem: '

If !Empty(cCodOpe)
	xCodOpe  := cCodOpe
	If xCodOpe == "02"
		lMsBlQl  := .T.
	EndIf	
	cHistory += ' / ' + STR0086 + TmsValField("xCodOpe",.F.,"DTR_NOMOPE") //--"Operadora de Frota:"
EndIf	

//| verifica se a função de integração está compilada.
If Len(getSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0
   oDTClass:= TransportDocumentClass():NEW()
EndIf

If cTmsErp == '0'
	SE5->(dbSetOrder(2))
	If SE5->(MsSeek(cSeek:=xFilial('SE5')+cTipoDoc+cPrefixo+cViagem))
		Do While !SE5->(Eof()) .And. SE5->(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO) == cSeek
			cParc:=Soma1(SE5->E5_PARCELA)
			SE5->(dbSkip())
		EndDo
	EndIf
EndIf
cParcela := cParc

If Type('cSerTms') == 'U' .Or. Empty(cSerTms) .Or. Type('cTipTra') == 'U' .Or. Empty(cTipTra)
	A240SerTms(@cSerTms2,@cTipTra2)
Else
	cSerTms2 := cSerTms
	cTipTra2 := cTipTra
EndIf

A240TipVV( cFilOri, cViagem, cCodVei, @cTipVei, @cTipOpVg )

aContrat := TmsContrFor( cCodForn, cLojForn, , cSerTms2, cTipTra2, , cTipVei, cTipOpVg)
If !Empty(aContrat) .And. Len(aContrat[1]) > 10
	lPaMovBco := aContrat[1,12] <> '2'
EndIf
For nZ := 1 to Len(aAdtoViag[nItem][2])
	lDesMovBco := .F.
	cChaveSDG	:= ''
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza os dados contidos na GetDados                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aAdtoViag[nItem][2][nZ][Len(aAdtoViag[nItem][2][nZ])] //-- Verifica se a linha esta deletada
		//-- Se a Despesa foi 'Informada', INCLUIR SDG com origem igual a 'DTR' e Status igual a baixado;
		//-- Se a Despesa foi 'Selecionada', BAIXAR o SDG
		If aAdtoViag[nItem][2][nZ][nPosTDes] == "1" //-- Despesa Informada
			cNumSeq := aAdtoViag[nItem][2][nZ][nPosNSeq] //-- Numero da Sequencia
			SDG->(dbSetOrder(3))
			If SDG->(!MsSeek(xFilial("SDG")+cNumSeq))
				FwFreeArray( aCabSDG )
				aCabSDG		:= {} 
				Aadd( aCabSDG , { "DG_FILIAL"	, xFilial("SDG") , Nil })
				Aadd( aCabSDG , { "DG_DOC"		, cDoc , Nil })
				Aadd( aCabSDG , { "DG_EMISSAO"	, dDataBase , Nil })
				Aadd( aCabSDG , { "DG_NUMSEQ"	, ProxNum() , Nil })
				Aadd( aCabSDG , { "DG_ORIGEM"	, "DTR" , Nil })
				If lGerador
					nPosGer := Ascan( aHeaderSDG, { | e | AllTrim(e[2]) == "DG_GERADOR" } )
					aAdtoViag[nItem][2][nZ][nPosGer] := "TMSA240"
				EndIf 		
				lNewSDG         := .T.
			Else
				lNewSDG         := .F.
			EndIf
			For nY := 1 To Len(aHeaderSDG)
				If aHeaderSDG[nY][10] <> "V" .And. AllTrim(aHeaderSDG[nY][2]) <> "DG_NUMSEQ"
					Aadd( aCabSDG , { Trim(aHeaderSDG[nY][2]) , aAdtoViag[nItem][2][nZ][nY] , nIL })
				EndIf
			Next nY
			nItemSDG++
			nValor         := SDG->DG_TOTAL
			
			Aadd( aCabSDG , { "DG_FILORI", cFilOri , Nil })
			Aadd( aCabSDG , { "DG_VIAGEM", cViagem , Nil })
			Aadd( aCabSDG , { "DG_CODVEI", cCodVei , Nil })
			If lForn
				dbSelectArea("DA3")
				DA3->(dbSetOrder(1))
				If DA3->(dbSeek(FwxFilial("DA3") + cCodVei ))
					Aadd( aCabSDG , { "DG_CODFOR", DA3->DA3_CODFOR , Nil })
					Aadd( aCabSDG , { "DG_LOJFOR", DA3->DA3_LOJFOR , Nil })
				EndIf
			EndIf

			Aadd( aCabSDG , { "DG_ITEM"	,  StrZero(nItemSDG, Len(SDG->DG_ITEM)) , Nil })
			Aadd( aCabSDG , { "DG_CUSTO1", nValor , Nil })
			Aadd( aCabSDG , { "DG_CUSTO2", If(aCotacao[2]>0,nValor/aCotacao[2],0) , Nil })
			Aadd( aCabSDG , { "DG_CUSTO3", If(aCotacao[3]>0,nValor/aCotacao[3],0) , Nil })
			Aadd( aCabSDG , { "DG_CUSTO4", If(aCotacao[4]>0,nValor/aCotacao[4],0) , Nil })
			Aadd( aCabSDG , { "DG_CUSTO5", If(aCotacao[5]>0,nValor/aCotacao[5],0) , Nil })

			If SDG->(FieldPos("DG_MOTBAI")) > 0 .And. SDG->DG_SALDO = 0
				Aadd( aCabSDG , { "DG_SEQORI", SDG->DG_NUMSEQ , Nil })
				Aadd( aCabSDG , { "DG_DATBAI", dDataBase , Nil })
				Aadd( aCabSDG , { "DG_MOTBAI", StrZero(1,Len(SDG->DG_MOTBAI)) , Nil }) //-- Normal
				Aadd( aCabSDG , { "DG_STATUS", StrZero(3,Len(SDG->DG_STATUS)) , Nil }) //-- Baixa Total
			ElseIf  SDG->DG_SALDO =  SDG->DG_VALCOB
				Aadd( aCabSDG , { "DG_STATUS", StrZero(1,Len(SDG->DG_STATUS)) , Nil }) //-- Em aberto
			EndIf
			
			DT7->(dbSetOrder(1))
			If DT7->(MsSeek(xFilial('DT7')+SDG->DG_CODDES))
				If DT7->(FieldPos("DT7_CLVL")) > 0 .And. SDG->(FieldPos("DG_CLVL")) > 0
					Aadd( aCabSDG , { "DG_CLVL", DT7->DT7_CLVL , Nil })
					Aadd( aCabSDG , { "DG_ITEMCTA", DT7->DT7_ITEMCT , Nil })
					Aadd( aCabSDG , { "DG_CONTA", DT7->DT7_CONTA , Nil })
					Aadd( aCabSDG , { "DG_CC", DT7->DT7_CC , Nil })					
				EndIf
				
				If DT7->DT7_MOVBCO == '2'
					Aadd( aCabSDG , { "DG_ORIGEM", "SDG ", Nil })
				ElseIf DT7->DT7_MOVBCO == '1'
					lDesMovBco := .T.
				EndIf
				cHistory2 := DT7->DT7_DESCRI
			EndIf
			AtuTabSDG(aCabSDG , Iif(lNewSDG,3,4) )
		
			If lNewSDG .And. cCusMed == "O" .And. SDG->(FieldPos('DG_DTLAEMI')) > 0
				nTotal += DetProva(nHdlPrv,"903","TMSA240",cLote)
				AAdd(aRecnoSDG, SDG->(Recno()) )
			EndIf
		Else
			cNumSeq := aAdtoViag[nItem][2][nZ][nPosNSeq] //-- Numero da Sequencia
			SDG->(dbSetOrder(3))
			If SDG->(MsSeek(xFilial("SDG")+cNumSeq))
				
				FwFreeArray(aCabSDG)
				aCabSDG	:= {} 
				Aadd( aCabSDG , { "DG_FILORI", cFilOri , Nil })
				Aadd( aCabSDG , { "DG_VIAGEM", cViagem , Nil })
				Aadd( aCabSDG , { "DG_CODVEI", cCodVei , Nil })
				If lForn
					dbSelectArea("DA3")
					DA3->(dbSetOrder(1))
					If DA3->(dbSeek(FwxFilial("DA3") + cCodVei ))
						Aadd( aCabSDG , { "DG_CODFOR", DA3->DA3_CODFOR , Nil })
						Aadd( aCabSDG , { "DG_LOJFOR", DA3->DA3_LOJFOR , Nil })
					EndIf
				EndIf
				AtuTabSDG(aCabSDG , 4 )
				
			EndIf
		EndIf
		
		//-- Se tiver sido informada uma nova Despesa que Movimenta Financeiro
		If !Empty(SDG->DG_BANCO) .Or. (cTMsErp =='1' .And. lDesMovBco)
			cChaveSDG := SDG->(DG_DOC+DG_CODDES+DG_ITEM)	 //--Chave utilizada para atualizar o SDG com a informação de título gerado.
			If lNewSDG
				lNewSDGPA := .T.   //-- A Nova Despesa Incluida e' do Tipo "PA"
			EndIf
			
			//-- Se na Alteracao tiver sido incluido uma nova despesa tipo "PA", deletar o Titulo a Pagar gerado anteriormente
			//-- e gera-lo novamente com o novo valor
			If nOpcx == 4 .And. lNewSDGPA
				lDelTit := .T.
			EndIf
			
			//-- A Quebra na geracao dos titulos sera' por Dados Bancarios; Motivo: Geracao do SE5
			nSeek := Ascan(aDadosBco, {|x| x[1]+x[2]+x[3]+x[4] == SDG->(DG_BANCO+DG_AGENCIA+DG_NUMCON+DG_NUMCHEQ) })
			If nSeek == 0
				//-- Parcela do Titulo que sera' gerado
				If Empty(aDadosBco)
					cParc := cParcela
				Else
					cParc := Soma1(cParc)
				EndIf
				AAdd(aDadosBco, {SDG->DG_BANCO, SDG->DG_AGENCIA, SDG->DG_NUMCON, SDG->DG_NUMCHEQ, SDG->DG_VALCOB, cParc, lMovBcoChq, SDG->DG_TITGER, cChaveSDG })
			Else
				aDadosBco[nSeek][5] += SDG->DG_VALCOB
			EndIf
			
			//-- Armazena no array o no. da Parcela do titulo correspondente a cada Despesa
			AAdd(aHistor, {SDG->DG_NUMSEQ, cParc })
			
		EndIf
		
		//-- Se a Linha estiver deletada
	Else
		cNumSeq := aAdtoViag[nItem][2][nZ][nPosNSeq] //-- Numero da Sequencia
		nValBai := aAdtoViag[nItem][2][nZ][nPosVBai] //-- Valor da Baixa
		//-- Se a Despesa foi Informada (origem == 'DTR') , deletar SDG
		If aAdtoViag[nItem][2][nZ][nPosTDes] == "1"
			SDG->(dbSetOrder(3))
			If SDG->(MsSeek(xFilial("SDG")+cNumSeq))
				If cCusMed == "O" .And. SDG->(FieldPos('DG_DTLAEMI')) > 0 .And. !Empty(SDG->DG_DTLAEMI)
					nTotal += DetProva(nHdlPrv,"904","TMSA240",cLote)
					AAdd(aRecnoSDG, SDG->(Recno()) )
				EndIf
				//-- Se na alteracao do Complemento, o usuario deletar alguma despesa do Tipo 'PA',
				//-- o titulo de Adiantamento devera' ser deletado e gerado novamente com o novo valor
				If nOpcx == 4 .And. !Empty(SDG->DG_BANCO)
					lRet := TMA240DelTit(cCodVei,SDG->DG_HISTOR,cCodFavDTR,cLojFavDTR)
					lDelTit := .T.
				EndIf
				If lRet 
					AtuTabSDG(,5)
				EndIf
			EndIf
			//-- Se a Despesa foi Selecionada (origem <> 'DTR') , estornar Baixa
		Else
			cNumSeq := aAdtoViag[nItem][2][nZ][nPosNSeq] //-- Numero da Sequencia
			SDG->(dbSetOrder(3))
			If SDG->(MsSeek(xFilial("SDG")+cNumSeq))
				FwFreeArray(aCabSDG)
				aCabSDG	:= {} 
				Aadd( aCabSDG , { "DG_FILORI", "" , Nil })
				Aadd( aCabSDG , { "DG_VIAGEM", "" , Nil })
				AtuTabSDG(aCabSDG,4)
			EndIf
		EndIf
	EndIf
	
Next

//-- Gera Titulo a Pagar das Despesas que Movimentam Financeiro (Tipo "PA");
//-- PS: O Titulo a Pagar das Depesas do Tipo 'NDF' (que nao Movimentam Financeiro),
//--     serao geradas no Contrato de Carreteiro
If lRet .And. !Empty(aDadosBco) .And. ( lNewSDGPA .Or. lDelTit) 
	
	//-- Gravar no campo DG_HISTOR a Parcela do Titulo que sera' gerado
	//-- A Atualizacao deste campo deve ser feita aqui e nao na gravacao acima:
	//-- Ex: Suponhamos que exista no SDG, 3 despesas com a Parcela do Titulo == 1; Se na Alteracao
	//-- do complemento, deletarmos a 3a. Despesa, sera gerado um novo SE2 com parcela '2'; Sendo assim,
	//-- o campo DG_HISTOR da 1a. e 2a. despesa, devera' ser atualizado com o no. da parcela do novo titulo;
	SDG->(dbSetOrder(5))
	If SDG->(MsSeek(cSeek:=xFilial("SDG")+cFilOri+cViagem))
		Do While !SDG->(Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM) == cSeek
			nSeek:= Ascan(aHistor, {|x| x[1] == SDG->DG_NUMSEQ })
			If nSeek > 0
				//-- Se foi incluida ou excluida alguma despesa, os titulos gerados anteriormente
				//-- deverao ser excluidos, pois serao gerados novamente com o novo valor e nova parcela
				If lDelTit
					lRet := TMA240DelTit(SDG->DG_CODVEI,SDG->DG_HISTOR,cCodFavDTR,cLojFavDTR)
				EndIf
				If lRet 
					cParcela := aHistor[nSeek][2]
					FwFreeArray(aCabSDG)
					aCabSDG	:= {} 
					Aadd( aCabSDG , { "DG_PARC", cParcela , Nil })
					Aadd( aCabSDG , { "DG_HISTOR", STR0043 + cParcela , Nil })//"PARCELA TITULO = "
					AtuTabSDG(aCabSDG,4)
					
				EndIf
			EndIf
			SDG->(dbSkip())
		EndDo
		If lRet 
			If Len(aDadosBco) > 0
				//-- Se o Credor do Adiantamento nao for o proprietario do veiculo
				If cCreAdi+cLojCre <> cCodForn+cLojForn
					cCodForn := cCreAdi
					cLojForn := cLojCre
				Else
					aCodFav := T250BscFav(cCodVei,cCodForn,cLojForn,cFilOri,cViagem)	// retorna o codigo do Favorecido
					If !Empty(aCodFav)
						cCodForn := aCodFav[1][1]
						cLojForn := aCodFav[1][2]
					EndIf	
					
				EndIf
				
				aContrat :=  TMSContrFor( cCodForn, cLojForn, ddatabase, cSerTms2, cTipTra2, , cTipVei, cTipOpVg )
				If !Empty(aContrat) .And. Len(aContrat[1]) > 11
					lPaMovBco := aContrat[1,12] <> '2' //Despesa/Adiantamento Movimenta Banco?
					If Len(aContrat[1]) > 12
						If Empty(aContrat[1][13]) .Or.  aContrat[1][13] == '0'  // Se DUJ_TITADI = Gera Adiantamento na(o): 0-Viagem;1-Fechamento Viagem;2-Contrato Carreteiro
							lRet := A240GerAdt(cFilOri,cViagem,cCodVei,aDadosBco,cCodOpe,cCodForn,cLojForn,cHistory,cHistory2,'TMSA240',lPaMovBco,0,nValProvi)
						EndIf
					EndIf
				EndIf
				
			EndIf
		EndIf 		
	EndIf	
	
EndIf

//-- Apresenta as Mensagens de Erro ocorridas durante o processamento da Rotina Automatica
If !lRet .And. !InTransact()   
	MostraErro()
EndIf

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A240AtuDVB³ Autor ³Fernando Salvatori     ³ Data ³26/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza os Campos do Arq. DVB (Motorista da Viagem)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A240AtuDVB(ExpA1,ExpA2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - aHeader Auxiliar Getdados de Lacre de Veiculos     ³±±
±±³          ³ ExpA2 - Array contendo os Lacres de Veiculos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A240AtuDVB(aHeaderDVB, aLacrVei, cFilOri, cViagem, cIteDTR, cCodVei)

Local aArea     := GetArea()
Local aAreaDTR := DTR->( GetArea() )
Local nX,nZ,nY
Local cSeek 	:= ""

Default cFilOri := DTR->DTR_FILORI
Default cViagem := DTR->DTR_VIAGEM
Default cIteDTR := DTR->DTR_ITEM
Default cCodVei := DTR->DTR_CODVEI

dbSelectArea("DVB")
nX := aScan(aLacrVei,{|x| x[1] == cCodVei}) //-- Verifica se foi informado o Lacre para o Veiculo
If nX > 0
	DVB->(dbSetOrder(1))
	If DVB->(DbSeek(cSeek := xFilial('DVB')+cFilOri+cViagem+cCodVei))	
		While DVB->(!EoF()) .And. cSeek == DVB->DVB_FILIAL+DVB->DVB_FILORI+DVB->DVB_VIAGEM+DVB->DVB_CODVEI
			If !aScan(aLacrVei[nX][2],{|x| x[1]+x[2] == DVB->DVB_ITEM + DVB->DVB_LACRE})
				RecLock("DVB",.F.)
				DVB->(dbDelete())
				MsUnLock()
			EndIf
			DVB->(dbSkip())
		EndDo
	EndIf

	For nZ := 1 to Len(aLacrVei[nX][2])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os dados contidos na GetDados                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !aLacrVei[nX][2][nZ][Len(aLacrVei[nX][2][nZ])] .And. !DVB->(DbSeek(xFilial('DVB')+cFilOri+cViagem+cCodVei+aLacrVei[1][2][nZ][1])) //-- Verifica se a linha esta deletada
			RecLock("DVB",.T.)
			For nY := 1 to Len(aHeaderDVB)
				If aHeaderDVB[nY][10] # "V"
					DVB->(FieldPut(FieldPos(Trim(aHeaderDVB[nY][2])),aLacrVei[nX][2][nZ][nY]))
				EndIf
			Next nY
			DVB->DVB_FILIAL := xFilial('DVB')
			DVB->DVB_FILORI := cFilOri
			DVB->DVB_VIAGEM := cViagem
			DVB->DVB_CODVEI := cCodVei
			MsUnlock()
		EndIf
	Next
EndIf

RestArea( aArea )
RestArea( aAreaDTR )

Return



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³aAltStaDTO³ Autor ³Patricia A. Salomao    ³ Data ³23.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Altera Status do Motorista                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³aAltStaDTO(ExpC1,ExpC2,ExpC3,xExpC4)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Status Atual                                        ³±±
±±³          ³ExpC2 - Filial Origem da Viagem                             ³±±
±±³          ³ExpC3 - Viagem                                              ³±±
±±³          ³ExpC4 - Codigo do Motorista                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function aAltStaDTO(cAtuStatus,cFilOri,cViagem, cCodMot,cTipUso,cIdent)

Local cNewStatus := IIF(cAtuStatus == '2','3','2')
Default cCodMot  := DUP->DUP_CODMOT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Descricao do Status do Motorista :                       ³
//³ 1 - Em Aberto                                            ³
//³ 2 - Liberado                                             ³
//³ 3 - Reservado                                            ³
//³ 4 - Baixado                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DTO->( DbSetOrder(2) )
If DTO->( MsSeek(xFilial("DTO") + cCodMot + cAtuStatus ) )
	DTO->( RecLock("DTO", .F.) )
	DTO->DTO_STATUS :=  cNewStatus
	If cNewStatus == "2"
		DTO->DTO_FILVGS := CriaVar("DTO_FILVGS",.F.)
		DTO->DTO_NUMVGS := CriaVar("DTO_NUMVGS",.F.)
	Else
		DTO->DTO_FILVGS := cFilOri
		DTO->DTO_NUMVGS := cViagem
	EndIf
	DTO->( MsUnLock() )
EndIf

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³aAltStaDTU³ Autor ³Patricia A. Salomao    ³ Data ³23.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Altera Status do Veiculo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³aAltStaDTU(ExpC1,ExpC2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Status Atual                                        ³±±
±±³          ³ExpC2 - Codigo do Veiculo                                   ³±±
±±³          ³ExpC3 - Filial Origem da Viagem                             ³±±
±±³          ³ExpC4 - Viagem                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function aAltStaDTU(cAtuStatus, cCodVei, cFilOri, cViagem, cTipUso, cIdent)

Local cNewStatus := IIF(cAtuStatus == '2','3','2')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Descricao do Status do Veiculo:                          ³
//³ 1 - Em Aberto                                            ³
//³ 2 - Liberado                                             ³
//³ 3 - Reservado                                            ³
//³ 2 - Baixado                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DTU->( DbSetOrder(2) )
If DTU->( MsSeek(xFilial("DTU") + cCodVei + cAtuStatus ))
	DTU->( RecLock("DTU", .F.) )
	DTU->DTU_STATUS := cNewStatus
	If cNewStatus == "2"
		DTU->DTU_FILVGS := CriaVar("DTU_FILVGS",.F.)
		DTU->DTU_NUMVGS := CriaVar("DTU_NUMVGS",.F.)
	Else
		DTU->DTU_FILVGS := cFilOri
		DTU->DTU_NUMVGS := cViagem
	EndIf
	DTU->( MsUnLock() )
EndIf


Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³aCalFreCar³ Autor ³Patricia A. Salomao    ³ Data ³23.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula Frete Carreteiro                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³aCalFreCar(ExpA1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Veiculos Infor.(Veic./1o. Reboq/2o. Reboq e 3Reb)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function aCalFreCar(aVeiculos,lAtualiza,lCalcPdg,n,lAltRota,nOpc,lAltTipOpVg)

Local cChave  := ""
Local cCampo  := ReadVar()
Local cCodVei := GdFieldGet('DTR_CODVEI',n)
Local cCodRb1 := GdFieldGet('DTR_CODRB1',n)
Local cCodRb2 := GdFieldGet('DTR_CODRB2',n)
Local lTercRbq := DTR->(ColumnPos("DTR_CODRB3")) > 0
Local cCodRb3 := IIf(lTercRbq,GdFieldGet('DTR_CODRB3',n),'')
Local cVeiRas := ""  //Veiculo Rastreado
Local cFrovei := ""
Local lRet    := .T.
//-- Operadoras de Frota/Vale-Pedagio
Local cTMSOPdg  := SuperGetMV( 'MV_TMSOPDG',, '0' )
Local cVsRepom  := SuperGetMV( 'MV_VSREPOM',, '1' )
Local aAreaDTR  := DTR->(GetArea())
Local aYesCampo := {}
Local aHerCampo := {}
Local lAtFre    := .F.
Local lRetCmp   := .F.
Local lTipOpVg  := DTQ->(ColumnPos("DTQ_TPOPVG")) > 0
Local cTipOpVg  := ""

Default aVeiculos   := {}    
Default lAtualiza   := .T. 
Default lCalcPdg    := .T.
Default lAltRota    := .F.
Default nOpc        := 0
Default lAltTipOpVg := .F.

//-- Se o complemento de viagem, estiver sendo chamado pelo programa de Viagens, as variaveis cSerTmsVge
//-- e cTipTraVge, sao passadas como parametro por este programa ... Caso contrario, assumir os valores
//-- dos campos DTQ_SERTMS / DTQ_TIPTRA
If Empty(cSerTMSVge)
	cSerTMSVge := DTQ->DTQ_SERTMS
EndIf

If Empty(cTipTraVge)
	cTipTraVge := DTQ->DTQ_TIPTRA
EndIf

If lTipOpVg
	If Upper(AllTrim(FunName())) == "TMSA240"
		cTipOpVg:= DTQ->DTQ_TPOPVG
	Else
		cTipOpVg:= M->DTQ_TPOPVG
	EndIf
EndIf

If cCampo == 'M->DTR_CODVEI'
	cCodVei := M->DTR_CODVEI
ElseIf cCampo == 'M->DTR_CODRB1'
	cCodRb1 := M->DTR_CODRB1
ElseIf cCampo == 'M->DTR_CODRB2'
	cCodRb2 := M->DTR_CODRB2
ElseIf cCampo == 'M->DTR_CODRB3'
	cCodRb3 := M->DTR_CODRB3
EndIf

If !lCalcPdg .And. cTMSOPdg == '2' .And. cVsRepom $ '2|2.2' .And. Empty(M->DTR_CODOPE)  
	lCalcPdg  := .T.
EndIf
DA3->(MsSeek(xFilial('DA3')+ cCodVei))
cFrovei := DA3->DA3_FROVEI
cChave 	:= DA3->DA3_TIPVEI
cCodFor	:= DA3->DA3_CODFOR
cLojFor := DA3->DA3_LOJFOR
cVeiRas := DA3->DA3_VEIRAS

If M->DTR_TPSPDG = "4" .And. DA3->DA3_FROVEI = "1"
	lCalcPdg  := .F.
EndIf
If cCodRb1 <> NIL .And. DA3->(MsSeek(xFilial('DA3')+ cCodRb1))
	cChave += DA3->DA3_FROVEI
Else
	cChave += StrZero(0, Len(DA3->DA3_FROVEI))
EndIf

If cCodRb2 <> NIL .And. DA3->(MsSeek(xFilial('DA3')+cCodRb2 ))
	cChave += DA3->DA3_FROVEI
Else
	cChave += StrZero(0, Len(DA3->DA3_FROVEI))
EndIf
If lTercRbq 
	If DA3->(MsSeek(xFilial('DA3')+ cCodRb3))
		cChave += DA3->DA3_FROVEI
	Else
		cChave += StrZero(0, Len(DA3->DA3_FROVEI))
	EndIf
EndIf 
cChave += cVeiRas

If DTT->(FieldPos("DTT_TIPVIA")) > 0
	If Type("M->DTQ_TIPVIA") <> "U" // -- Viagem
		cChave += M->DTQ_TIPVIA
	Else //Complemento de Viagem
		cChave += DTQ->DTQ_TIPVIA
	EndIf
EndIf

//- Estrutura do Array de retorno da funcao TMSFretCar:
//- Verificar fonte TMSXFUNA
aRet := TMSFretCar(IIf(Empty(cRota),DTQ->DTQ_ROTA,cRota), cCodFor, cLojFor, aVeiculos, cChave,;
cSerTMSVge, cTipTraVge,,,IIF(cTMSOPdg <> '0', M->DTR_CODOPE, ''),lCalcPdg,,cTipOpVg)

If aRet[4]
	//-- Houve falha no calculo do pedagio por parte
	//-- da Operadora de Frotas/Vale-Pedagio
	lRet := .F.
Else
	If lAtualiza
		If !Empty(aRet)
			If aRet[1] > 0 
				GDFieldPut( 'DTR_VALPDG', aRet[1], n ) //-- Atualiza Valor de Pedagio.   
			Else
				If !lCalcPdg .And. aRet[1] == 0 .And. !Empty(GDFieldGet('DTR_VALPDG',n))
					GDFieldPut( 'DTR_VALPDG', aRet[1], n ) //-- Atualiza Valor de Pedagio.   				
				EndIf
			EndIf
			If aRet[2] > 0 .OR. lAltRota .Or. lAltTipOpVg 
				If cFrovei <> "1" //-- Se a Frota do Veiculo NAO for "Propria"					 				
					If TA240AltFt(aRet[2],lAltRota,lAltTipOpVg)  
					  GDFieldPut( 'DTR_VALPDG', aRet[1], n )  //-- Atualiza Valor de Pedagio.
					  GDFieldPut( 'DTR_VALFRE', aRet[2], n )  //-- Atualiza Valor de Frete.
					  GDFieldPut( 'DTR_TABCAR', aRet[3], n )  //-- Atualiza Tabela de Carreteiro
					  lAtFre:= .T.
					EndIf
				EndIf
			ElseIf aCols[n][2] <> aVeiculos[1][1]
				GDFieldPut( 'DTR_TABCAR',CriaVar('DTR_TABCAR',.F.), n )  //-- Atualiza Tabela de Carreteiro
				GDFieldPut( 'DTR_VALFRE',CriaVar('DTR_VALFRE',.F.), n )  //-- Limpa o valor do frete 
			EndIf
		EndIf
	
		If nOpc == 4 .And. lAtFre .And. !lHerdaFrt
			DTR->(dbSetOrder(2)) // DTR_FILVGE + DTR_NUMVGE  
			If DTR->(MsSeek(xFilial('DTR')+M->DTR_FILORI+M->DTR_VIAGEM))
				lHerdaFrt:= .F.
				lRetCmp:= A240CmpDTR(DTR->DTR_FILORI,DTR->DTR_VIAGEM,Iif(Type('oGet') == 'U',, oGet:nOpc), @aYesCampo,@aHerCampo)
				If lRetCmp
					If MsgYesNo( STR0087 ,STR0020)  //"Deseja replicar o Valor do Frete da Viagem Principal para a Viagem Coligada? "
						lHerdaFrt:= .T.
					EndIf	
				EndIf	
			EndIf
		EndIf
		
	EndIf
EndIf

RestArea(aAreaDTR)
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TA240VlMotºAutor  ³Fernando Salvatori  º Data ³  25/02/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a validacao do codigo do motorista                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TA240VlMot()

Local lContVei := GetMV('MV_CONTVEI',,.T.)
Local lMV_EmViag := GetMV('MV_EMVIAG',,.F.)

Local lRet     := .T.
Local cCodMot  := &(ReadVar())
Local lValFunc := FindFunction("TMSVldFunc")
Local aArea    := GetArea()
Local nY       := 0
Local dDataIni := dDataBase
Local dDataFim := dDataBase
Local lDLS     := IsInCallStack('TMSA146')
Local lVgeMod3 := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)

If !lVgeMod3
	If Posicione("DA4",1,xFilial("DA4")+cCodMot,"DA4_BLQMOT") == StrZero(1,Len(DA4->DA4_BLQMOT))
		Help("",1,"TMSA24055", , STR0051 + ":" + cCodMot + " - " + DA4->DA4_NOME , 4, 1) //"O Motorista esta bloqueado"
		lRet := .F.
	EndIf
	//-- Valida Motorista Funcionario (SRA)
	If lRet .And. lValFunc
		DA4->(DbSetOrder(1)) //DA4_FILIAL+DA4_COD
		If DA4->(DbSeek(xFilial("DA4") + cCodMot))
			If lRet .And. Alltrim(FunName()) <> "TMSAF15"
				dDataIni := If(!Empty(M->DTR_DATINI),M->DTR_DATINI,dDataBase)
				dDataFim := If(!Empty(M->DTR_DATFIM),M->DTR_DATFIM,dDataBase)
				
				lRet := TMSVldFunc(DA4->DA4_MAT, DA4->DA4_FILBAS, dDataIni, dDataFim)
			Else
				lRet := TMSVldFunc(DA4->DA4_MAT, DA4->DA4_FILBAS)
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
	
	If lRet .And. (lContVei .Or. lMV_EmViag)
		If lContVei
		//-- Quando a Viagem por planejada, trata como se o controle de veiculos estivesse desligado.
		TMSA240Off( @lContVei, .F. )
			lRet := Ta240VrfRot(,cCodMot)
		EndIf
		If lRet .And. (lContVei .Or. lMV_EmViag)
			//--Nao pode selecionar um motorista em duas viagens
			If lRet .And. !Empty(cCodMot)
				If !LockByName("VGEMOT" + cCodMot,.T.,.F.)
					Help( ' ', 1, 'TMSA24049', , STR0010 + cCodMot,3 ,0) //"O Motorista esta sendo utilizado por outra viagem." ### "Motorista: "
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	
	//--Sempre que for efetuado a troca de motorista preciso liberar o motorista anterior
	//que esta no aCols e bloquear o novo motorista que esta na variavel de memoria
	If !lDLS .And. lRet .And. (lContVei .Or. lMV_EmViag) .And. M->DUP_CODMOT <> GdFieldGet('DUP_CODMOT',n) 
		LockByName("VGEMOT" + M->DUP_CODMOT,.T.,.F.)
		If !Empty(GdFieldGet('DUP_CODMOT',n))
			UnLockByName("VGEMOT" + GdFieldGet('DUP_CODMOT',n),.T.,.F.)
		EndIf
	EndIf
	
	//-- Se no cadastro do motorista (DA4) foi informado Ajudante(s), gatilhar os codigos
	//-- automaticamente no aCols de Ajudantes
	If !lDLS .And. lRet .And. Alltrim(FunName()) <> "TMSAF15"//-- Não utilizado no Retorno de Reboques
		dbSelectArea("DA4")
		For nY := 1 to 3
			aArea := GetArea()
			cAjuda:= AllTrim(Str(nY))
			TMSA240Ajud(oGet:nOpc, DA4->(DA4_AJUDA&cAjuda), .F., (nY==1))
			RestArea( aArea )
		Next nY
	EndIf
EndIf

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA240Ver³ Autor ³Patricia A. Salomao    ³ Data ³14.01.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Nao permite utilizar o Motorista/Ajudante, se o mesmo ja es-³±±
±±³          ³tiver sendo utilizado por outro veiculo nesta viagem        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA240Ver(ExpC1,ExpC2,ExpA1,ExpL1,ExpC3)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Tipo: 1- Motorista / 2- Ajudante                    ³±±
±±³          ³ExpC2 - Codigo do Motorista/Ajudante                        ³±±
±±³          ³ExpA1 - Array Contendo os Motoristas OU Ajudantes da Viagem ³±±
±±³          ³ExpL1 - Mostra/Nao o Help na Tela                           ³±±
±±³          ³ExpC3 - Item da Nota Fiscal (GetDados)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. - O Motorista/Ajudante devera ser considerado           ³±±
±±³          ³.F. - O Motorista/Ajudante Nao devera ser considerado       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA240Ver(cTipo, cCodAjuMot, aArray, lHelp, cItem)

Local nCntFor1     := 0
Local nCntFor2     := 0
Local lConsid      := .T.
Local nPosDel	   := If( cTipo == '1', Len(aHeaderDUP) + 1, Len(aHeaderDUQ) + 1 )

Default cTipo      := "1"
Default cCodAjuMot := ""
Default aArray     := {}
Default lHelp      := .F.
Default cItem      := ""

For nCntFor1 := 1 To Len(aArray)
	For nCntFor2 := 1 To Len(aArray[nCntFor1][2])
		If aArray[nCntFor1][2][nCntFor2][1] == cCodAjuMot .And. IIf(!Empty(cItem),cItem <> aArray[nCntFor1][1],.T.) .And. aArray[nCntFor1][2][nCntFor2][nPosDel] == .F.
			lConsid := .F. //-- Este Motorista/Ajudante ja esta sendo utilizado nesta Viagem
			Exit
		EndIf
	Next nCntFor2
	If !lConsid
		Exit
	EndIf
Next nCntFor1

If !lConsid .And. lHelp
	If cTipo == "1"
		Help("",1,"TMSA24021") //-- Este Motorista ja esta sendo utilizado nesta Viagem ...
	Else
		Help("",1,"TMSA24022") //-- Este Ajudante ja esta sendo utilizado nesta Viagem ...
	EndIf
EndIf

Return lConsid

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TA240VrfRoºAutor  ³Fernando Salvatori  º Data ³  02/25/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica a rota do Motorista atual                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.    ³ ExpC1 -> Numero da Liberacao                               º±±
±±º          ³ ExpC2 -> Codigo do Veiculo                                 º±±
±±º          ³ ExpC3 -> Codigo do Motorista                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpL1 -> True para Motorista Liberado para a regiao        º±±
±±º          ³          selecionada pelo usuario;                         º±±
±±º          ³          False para motorista que nao faz parte da regiao  º±±
±±º          ³          selecionada pelo usuario.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ta240VrfRot(cCodVei, cCodMot)

Local lAchouRota := .F.
Local aArea      := GetArea()
Local aAreaDtu   := DTU->( GetArea() )
Local aAreaDto   := DTO->( GetArea() )
Local aAreaDtb   := DTB->( GetArea() )
Local cNumLib    := ""
Local cSeek      := ""
Local aRegRot	 := {}
Local lCodMot    := (!Empty(cCodMot))
Local cCpos      := ""
Local nCntFo1    := 0
Local nCntFor    := 0
Local cMotGen    := GetMV('MV_MOTGEN')
Local aRegInf	 := {}
Local aRegSup 	 := {}

Default cNumLib := ""
Default cCodVei := ""
Default cCodMot := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciono no arquivo de Movimentos de Veiculos                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCodMot
	DTU->( dbSetOrder( 2 ) )
	DTU->( MsSeek( xFilial( "DTU" ) + cCodVei + "2" )) //Pesquisar por codigo do Motorista Liberado
	cNumLib := DTU->DTU_NUMLIB
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciono no arquivo de Movimentos de Motoristas.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "DTO" )
	dbSetOrder( 4 )
	MsSeek( cSeek := xFilial( "DTO" ) + cNumLib + "2" ) //Pesquisar por codigo da liberacao
	cCpos := "DTO_FILIAL + DTO_NUMLIB + DTO_STATUS"
Else
	dbSelectArea( "DTO" )
	dbSetOrder( 2 )
	MsSeek( cSeek := xFilial( "DTO" ) + cCodMot + "2" ) //Pesquisar por codigo do Motorista Liberado
	cCpos := "DTO_FILIAL + DTO_CODMOT + DTO_STATUS"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico todos os motoristas daquele veiculo.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do While !Eof() .And. &cCpos == cSeek
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Consistir apenas movimentos liberados                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If DTO->DTO_STATUS == "2"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifico todas as regioes do motorista selecionado.                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea( "DTB" )
		dbSetOrder( 1 )
		If MsSeek( xFilial( "DTB" ) + DTO->DTO_NUMLIB + DTO->DTO_CODMOT )
			
			Do While !Eof() .And. ;
				xFilial( "DTB" )+DTO->DTO_NUMLIB+DTO->DTO_CODMOT == DTB_FILIAL+DTB_NUMLIB+DTB_CODMOT
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifico todas as regioes superiores e regioes de origem/destino da rota.       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRegSup := TmsNivSup(DTB->DTB_CDRDES)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Retorna as Filiais / Regioes de Descarga da Rota                      ³
				//³ Elementos contidos por dimensao:                                      ³
				//³ 1. Regiao Origem da Rota                                              ³
				//³ 2. Regioes de Descarga da Rota                                        ³
				//³ 3. Filiais de Descarga da Rota                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRegRot := TMSRegDca(IIf(Empty(cRota),DTQ->DTQ_ROTA,cRota))
				
				For nCntFor := 2 To Len( aRegSup )
					aRegInf := {}
					TmsNivInf( aRegSup[ nCntFor ], @aRegInf )
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Caso as regioes da Rota nao estiverem disponiveis na regiao inferior,nao liberar³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nCntFo1 := 1 To Len( aRegRot )
						If AScan( aRegInf, {|ExpA1| ExpA1[1] == aRegRot[ nCntFo1, 2 ]} ) > 0
							lAchouRota := .T.
							Exit
						EndIf
					Next
					
					If lAchouRota
						Exit
					EndIf
				Next
				
				If lAchouRota
					Exit
				EndIf
				
				dbSelectArea( "DTB" )
				dbSkip()
			EndDo
		Else
			lAchouRota := .T.
		EndIf
		
		If lAchouRota
			Exit
		EndIf
		
		dbSelectArea("DTO")
		dbSkip()
	EndIf
	
EndDo

If !lAchouRota .And. ( cCodMot <> cMotGen )
	If !Empty(cRota) .And. !Empty(DTQ->DTQ_ROTA)
		Help(' ', 1, 'TMSA24023')	//-- O Motorista cadastrado nao pode ser utilizado para essa viagem, pois nao tem regioes validas cadastradas no complemento de viagem ou o motorista nao esta liberado.
		RestArea( aAreaDtu )
		RestArea( aAreaDto )
		RestArea( aAreaDtb )
		RestArea( aArea )
		Return( .F. )
	EndIf
EndIf

RestArea( aAreaDtu )
RestArea( aAreaDto )
RestArea( aAreaDtb )
RestArea( aArea )

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TA240LacreºAutor  ³Fernando Salvatori  º Data ³  02/25/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Manutencao de Lacre de Veiculos                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.    ³ ExpN1 -> Opcao selecionada                                 º±±
±±º          ³ ExpC1 -> Filial da Viagem                                  º±±
±±º          ³ ExpC2 -> Viagem                                            º±±
±±º          ³ ExpC3 -> Codigo do Veiculo                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ .T.                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TA240Lacre(nOpcx, cFilOri, cViagem, cCodVei)

Local nPosLacre    := Ascan(aLacrVei,{|x| x[1] == GdFieldGet('DTR_CODVEI',n) })
Local nAux         := 0
Local nOpc         := 0
Local aLimpCols    := {}
Local aNoFields    := {}
Local aYesFields   := {}
Local nSavN	       := n
Local aSavCols     := aClone(aCols)
Local aSavHeader   := aClone(aHeader)
Local aSavaRotina  := aClone(aRotina)
Local oDlg,oGetD
Local nX           := 0

Default cCodVei    :=  ""

If Empty(cFilOri+cViagem) .Or. Empty(cCodVei)
	Return .T.
EndIf

//-- Finaliza as Teclas de Atalhos
TmsKeyOff(aSetKey)

n       := 1
aCols	:= {}
aHeader := {}
aRotina[2][4] := 2
aRotina[3][4] := 3

RegToMemory( "DVB" , .T. )

AAdd( aNoFields, "DVB_FILIAL" )
AAdd( aNoFields, "DVB_FILORI" )
AAdd( aNoFields, "DVB_VIAGEM" )
AAdd( aNoFields, "DVB_CODVEI" )

nAux := aScan( aLacrVei, {|ExpA1| ExpA1[1] == cCodVei } )

If nAux <= 0
	TMSFillGetDados( nOpcx, 'DVB', 1,xFilial( 'DVB' ) + cFilOri + cViagem + cCodVei, {|| DVB->DVB_FILIAL + DVB->DVB_FILORI + DVB->DVB_VIAGEM + DVB->DVB_CODVEI }, ;
	{|| .T. }, aNoFields,	aYesFields )
	aHeaderDVB := AClone( aHeader )
Else
	aCols := AClone( aLacrVei[nAux][2] )
	aHeader := AClone( aHeaderDVB )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso exista dados cadastrados para o motorista selecionado, traze-los    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Len( aCols ) == 1 .And. Empty( GDFieldGet( 'DVB_ITEM', 1 ) )
	GDFieldPut( 'DVB_ITEM', StrZero(1,Len(DVB->DVB_ITEM)), 1 )
EndIf

DEFINE MSDIALOG oDlg FROM 94 ,104 TO 330,650 TITLE STR0018 Of oMainWnd PIXEL //"Lacre de Veiculos"
oGetD := MSGetDados():New(30,2,118,271,IIf(nOpcx == 2 ,2 ,3),"TA240LLinOk()",,"+DVB_ITEM",.T.,,,.F.)
@ 6  ,116 SAY '' Of oDlg PIXEL SIZE 26 ,9
@ 18 ,3   SAY STR0007  Of oDlg PIXEL SIZE 56 ,9  //"Viagem : "
@ 18 ,96  SAY STR0009 Of oDlg PIXEL SIZE 60 ,9  //"Veiculo : "
@ 18 ,36  SAY cFilOri+"/"+cViagem Of oDlg PIXEL SIZE 50 ,9
@ 18 ,125 SAY cCodVei Of oDlg PIXEL SIZE 140 ,9

ACTIVATE MSDIALOG oDlg    ON INIT (oGetD:Refresh(),EnchoiceBar(oDlg,   {||IIF(oGetD:TudoOk(),(nOpc:=1,oDlg:End()),(nOpc:=0))},{||oDlg:End()}) )

If nOpc == 1 .And. nOpcx != 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpando registros deletados                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len( aCols )
		If !aTail(aCols[nX])
			AAdd(aLimpCols,aCols[nX])
		EndIf
	Next nX
	
	aCols := {}
	aCols := aClone( aLimpCols )
	
	If nPosLacre > 0
		aLacrVei[nPosLacre][2] := aClone(aCols)
	Else
		AAdd(aLacrVei,{cCodVei, aClone(aCols)})
	EndIf
EndIf

aRotina	:= aClone(aSavaRotina)
aHeader := aClone(aSavHeader)
aCols   := aClone(aSavCols)
n		:= nSavN

//-- Iniciliza as Teclas de Atalhos
TmsKeyOn(aSetKey)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TA240LLinOºAutor  ³Fernando Salvatori  º Date ³  27/02/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida linha do aCols de Lacre de Veiculos                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TA240LLinOk(cTipVld,cTpCiot)

Local lRet     	 := .T.
Local cChaveDJA	 := ""
Local lTerc    	 := .F.
Local aConsCard  := {}
Local aMotCiot	 := {}
Local cCodMot	 := ""
Local cCondut 	 := ""
Local cCiotPer 	 := ""
Local nZ		 := 0
Local nCount 	 := 0
Local cInValePdg := '4198'

Default cTipVld:= ""
Default cTpCiot:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao avaliar caso a linha esteja deletada                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	!GDDeleted( n )
	
	lRet := MaCheckCols(aHeader,aCols,n)
	
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe itens duplicados na GetDados                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cTipVld)
			lRet := GDCheckKey( { 'DVB_LACRE' }, 4 )
		ElseIf cTipVld == "DJA"
			If AllTrim(GDFieldGet("DJA_ALIAS",n)) == 'DA3'
				cChaveDJA:= xFilial("DA3") + AllTrim(GDFieldGet("DJA_CHAVE",n))
				If Posicione("DA3",1,cChaveDJA,"DA3_FROVEI") == '2' //Terceiro
					lTerc:= .T.
				EndIf	
			ElseIf AllTrim(GDFieldGet("DJA_ALIAS",n)) == 'DA4'
				cChaveDJA:= xFilial("DA4") + AllTrim(GDFieldGet("DJA_CHAVE",n))
				If Posicione("DA4",1,cChaveDJA,"DA4_TIPMOT") == '2' //Terceiro
					lTerc:= .T.
				EndIf
			EndIf	
			If lTerc
				lRet := GDCheckKey( { 'DJA_LIBSEG' }, 4 )
			EndIf	
		ElseIf cTipVld == "DLD"
			lRet := GDCheckKey( { 'DLD_CODVEI','DLD_TIPPAR' }, 4 )
			
			If lRet 
				aRetCNPJ   := PamCNPJEmp(M->DTR_CODOPE, M->DTR_FILORI) //Função para obter CNPJ da contrante e filial de origem 
				//-- Montagem Array para Integração com PamCard
				AAdd(aConsCard,{'viagem.contratante.documento.numero',aRetCNPJ[1]})
				AAdd(aConsCard,{'viagem.unidade.documento.tipo'      ,aRetCNPJ[2]})
				AAdd(aConsCard,{'viagem.unidade.documento.numero'    ,aRetCNPJ[3]}) 
				AAdd(aConsCard,{'viagem.cartao.numero',AllTrim(GdFieldGet("DLD_IDOPE",n))} )
				
				If AllTrim(GdFieldGet("DLD_RECEB",n)) == '2' //Motorista	
					If cTpCiot == '2' .Or. AllTrim(GdFieldGet("DLD_FORPAG",n)) == '1' //Só valida se for CIOT por periodo ou pagamento com cartão
						nZ := aScan(aMotViag,{|x| x[1] == GDFieldGet('DLD_ITEDTR',n)}) 
						If nZ > 0							
							For nCount := 1 To Len(aMotViag[nZ][2])
								If !aMotViag[nZ][2][nCount][Len(aMotViag[nZ][2][nCount])] //-- Verifica se a linha esta deletada
									cCodMot := aMotViag[nZ][2][nCount][1]
									cCondut := aMotViag[nZ][2][nCount][Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_CONDUT" })]
									If cCondut == "1" //Condutor principal										
										If  cTpCiot == '2' //Ciot por periodo
										 	cCiotPer := TmsCiotPer(GdFieldGet("DLD_CODVEI",n))
											aMotCiot := TmsMotCiot(cCiotPer, cCodMot,GdFieldGet("DLD_FORPAG",n),GdFieldGet("DLD_IDOPE",n))
											If Len(aMotCiot) > 0 
												Help(' ', 1, 'TMSA24096') //-- Para viagens que possuem CIOT por período, por limitação da Operadora Pamcard, não é possível informar o Motorista como Recebedor.
												lRet := .F.
											EndIf											
										Endif											
										If lRet .And. AllTrim(GdFieldGet("DLD_FORPAG",n)) == '1' //forma de pagamento cartão
											dbSelectArea("DA4")
											dbSetOrder(1)
											If MsSeek(xFilial("DA4")+cCodMot) .And. cInValePdg <> PADR(GdFieldGet("DLD_IDOPE",n),4)
												If !Empty(DA4->DA4_FORNEC)									
													lRet := PamFindCar(aConsCard,,.T.,,,DA4->DA4_FORNEC,DA4->DA4_LOJA)										
												Else
													lRet := PamFindCar(aConsCard, .T.)
												EndIf	
											EndIf							
										Endif
									EndIf
								EndIf
							Next nCount
						Endif
					Endif
				ElseIf AllTrim(GdFieldGet("DLD_RECEB",n)) == '1' .And. AllTrim(GdFieldGet("DLD_FORPAG",n)) == '1' .And. cInValePdg <> PADR(GdFieldGet("DLD_IDOPE",n),4) //Proprietario  //--Não fazer a chamada do método FindCard, quando o cartão for Vale Pedágio (4195)//--Já que este cartão não precisa estar cadastrado na Pamcard para ser utilizado.
					If Empty(GDFieldGet('DLD_CODFAV',n))
						dbSelectArea("DA3")
						DA3->(dbSetOrder(1)) 
						If MsSeek(xFilial("DA3")+GDFieldGet('DLD_CODVEI',n)) .And. !Empty(DA3->DA3_CODFOR)
							lRet := PamFindCar(aConsCard,,.T.,,,DA3->DA3_CODFOR,DA3->DA3_LOJFOR)
						Endif
					Else
						lRet := PamFindCar(aConsCard,,.T.,,,GDFieldGet('DLD_CODFAV',n),GDFieldGet('DLD_LOJFAV',n))
					EndIf
				EndIf
			EndIf

			If lRet .And. AllTrim(GdFieldGet("DLD_TIPPAR",n)) == '3' .And.  AllTrim(GdFieldGet("DLD_FORPAG",n)) <> '1'  
				Help( ' ', 1, 'TMSA240A4') //A forma de pagamento da parcela de pedagio deve ser Cartão.
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TA240DelOkºAutor  ³Fernando Salvatori  º Data ³  27/02/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida linha de delecao do aCols                           º±±
±±º          ³ Dados do Motorista (MsGetDados Principal                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TA240DelOk()

Local lRet := .T.         //Retorno da Funcao
Local nAux := 0           //Var Auxiliar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Devido a um problema contido no BIN, a funcao DelOk eh     ³
//³executada 2 vezes, sendo assim, foi declarada uma variavel ³
//³Estatica para controlar se ja foi executada ou nao a funcao³
//³Variavel "lDelOk"                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lDelOk == Nil
	lDelOk := .F.
EndIf

If !lDelOk
	nAux := aScan( aLacrVei,{|ExpA1| ExpA1[1] == aCols[N][aScan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DTR_CODVEI"})]} )
	If ( lRet ) .And. ( nAux > 0 )
		////"Existe um Lacre cadastrado para este veiculo, deseja realmente efetuar a exclusao do registro? (os dados de Lacre do Veiculo serão perdidos)"
		If MsgYesNo( STR0019 ,STR0020)//"Existe um Lacre cadastrado para este veiculo, deseja realmente efetuar a exclusao do registro? (os dados de Lacre do Veiculo serão perdidos)"//"Atenção"
			aDel(aLacrVei,nAux)
			aSize(aLacrVei,Len(aLacrVei)-1)
		Else
			lRet := .F.
		EndIf
	EndIf
	lDelOk := .T.
Else
	lDelOk := .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA240Tp³ Autor ³ Robson Alves          ³ Data ³ 26/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe os tipos de veiculos Agendados.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa240TpVei()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os tipos de veiculos                     ³±±
±±³          ³ ExpL1 = Indica de onde o Complemento esta sendo executado. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa240TpVei( aTipVei, lParamViagem )

Local oDlgTpVei, oListTpVei
Local aHTipVei := {}
Local lOk      := .T.
Local aAreaDTQ := DTQ->( GetArea() )

If !Empty( M->DTR_FILORI ) .And. !Empty( M->DTR_VIAGEM )
	If lParamViagem .And. Type("M->DTQ_SERTMS") <> "U"
		//-- Se o Complemento for executado pela rotina de Viagem.
		If M->DTQ_SERTMS != StrZero( 1, Len( DTQ->DTQ_SERTMS ) ) //-- Viagem de Coleta.
			lOk := .F.
		EndIf
	Else
		//-- Se o Complemento for executado pelo manu.
		DTQ->( dbSetOrder( 2 ) )
		DTQ->( MsSeek( xFilial("DTQ") + M->DTR_FILORI + M->DTR_VIAGEM ) )
		If DTQ->DTQ_SERTMS != StrZero( 1, Len( DTQ->DTQ_SERTMS ) ) //-- Viagem de Coleta.
			lOk := .F.
		EndIf
	EndIf
	
	If !lOk
		Help(' ', 1, 'TMSA24030') //-- Essa opcao so e permitida para viagens de Coleta.
	EndIf
	
Else
	Help(' ', 1, 'TMSA24031') //-- Informe o numero da viagem.
	
	lOk := .F.
EndIf

If lOk
	If Empty( aTipVei )
		//-- Se o Complemento for executado pela rotina de Viagem, o array ja deveria vir preenchido.
		If lParamViagem
			Help(' ', 1, 'TMSA24032') //-- Nenhum documento selecionado.
			
			lOk := .F.
		Else
			//-- Se o Complemento for executado pelo menu, monta o array com os tipos de veículo na hora.
			Tmsa240Add( @aTipVei )
			
			If Empty( aTipVei )
				Help(' ', 1, 'TMSA24033') //-- Nao foi informado nenhum tipo de veiculo para viagem.
				
				lOk := .F.
			EndIf
		EndIf
	EndIf
	
	If lOk
		//-- Ordena por tipo de veiculo.
		Asort( aTipVei,,,{ |x,y| x[1] < y[1] } )
		
		Aadd( aHTipVei, Posicione('SX3', 2, 'DUT_TIPVEI', 'X3Titulo()') )
		Aadd( aHTipVei, Posicione('SX3', 2, 'DUT_DESCRI', 'X3Titulo()') )
		Aadd( aHTipVei, Posicione('SX3', 2, 'DVT_QTDVEI', 'X3Titulo()') )
		
		DEFINE MSDIALOG oDlgTpVei TITLE STR0028 From 220, 163 To 525, 763 OF oMainWnd PIXEL //"Tipos de Veículos Agendados "
		
		@  05,  10 LISTBOX oListTpVei VAR cVar Fields HEADER aHTipVei[ 1 ], aHTipVei[ 2 ], aHTipVei[ 3 ] SIZE 280, 130 Of oDlgTpVei PIXEL
		oListTpVei:SetArray( aTipVei )
		oListTpVei:bLine := {|| { aTipVei[oListTpVei:nAT,1],;
		aTipVei[oListTpVei:nAT,2],;
		aTipVei[oListTpVei:nAT,3] } }
		
		@ 140,247 BUTTON STR0042 SIZE 045,010  FONT oDlgTpVei:oFont ACTION ( oDlgTpVei:End() ) OF oDlgTpVei PIXEL //"Voltar"
		
		ACTIVATE MSDIALOG oDlgTpVei CENTERED
	EndIf
EndIf

RestArea( aAreaDTQ )

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA240Ad³ Autor ³ Robson Alves          ³ Data ³ 27/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta array com os tipos de veiculos Agendados.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa240Add(ExpA1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array para adicionar os tipos de veiculos          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa240Add( aTipVei )

Local aAreaDUD  := DUD->( GetArea() )
Local aAreaDT5  := DT5->( GetArea() )
Local aAreaDVT  := DVT->( GetArea() )
Local cQuery    := ""
Local cAliasNew := ""
Local nSeek     := 0

cQuery := "SELECT DVT.DVT_TIPVEI, DVT.DVT_QTDVEI"
cQuery += " FROM " + RetSqlName("DUD") + " DUD, " + RetSqlName("DT5") + " DT5, " + RetSqlName("DVT") + " DVT"
cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "'"
cQuery += " AND DUD.DUD_FILORI = '" + M->DTR_FILORI + "'"
cQuery += " AND DUD.DUD_VIAGEM = '" + M->DTR_VIAGEM + "'"
cQuery += " AND DUD.D_E_L_E_T_ = ''"
cQuery += " AND DT5.DT5_FILIAL = '" + xFilial("DT5") + "'"
cQuery += " AND DT5.DT5_FILDOC = DUD.DUD_FILDOC"
cQuery += " AND DT5.DT5_DOC = DUD.DUD_DOC"
cQuery += " AND DT5.DT5_SERIE = DUD.DUD_SERIE"
cQuery += " AND DT5.D_E_L_E_T_ = ''"
cQuery += " AND DVT.DVT_FILIAL = '" + xFilial("DVT") + "'"
cQuery += " AND DVT.DVT_FILORI = DT5.DT5_FILORI"
cQuery += " AND DVT.DVT_NUMSOL = DT5.DT5_NUMSOL"
cQuery += " AND DVT.D_E_L_E_T_ = ''"

cQuery := ChangeQuery(cQuery)

cAliasNew := GetNextAlias()
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)

TCSetField(cAliasNew,"DVT_QTDVEI","N",TamSx3("DVT_QTDVEI")[1],TamSx3("DVT_QTDVEI")[2])

dbSelectArea( cAliasNew )
( cAliasNew )->( dbGoTop() )

While ( cAliasNew )->( !Eof() )
	
	If ( nSeek := Ascan( aTipVei, { |x| x[1] == ( cAliasNew )->DVT_TIPVEI } ) ) == 0
		Aadd( aTipVei, { ( cAliasNew )->DVT_TIPVEI, Posicione( "DUT", 1, xFilial("DUT") + ( cAliasNew )->DVT_TIPVEI, "DUT_DESCRI" ), ( cAliasNew )->DVT_QTDVEI } )
	Else
		aTipVei[ nSeek, 3 ] += ( cAliasNew )->DVT_QTDVEI
	EndIf
	
	( cAliasNew )->( dbSkip() )
EndDo

( cAliasNew )->( dbCloseArea() )

RestArea( aAreaDUD )
RestArea( aAreaDT5 )
RestArea( aAreaDVT )

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA240TV³ Autor ³ Robson Alves          ³ Data ³ 27/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Sugere o tempo da Viagem.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa240TVge(ExpN1, ExpC1, ExpC2, ExpC3, ExpA1 )            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Acao, de acordo com a chamada do Complemento.      ³±±
±±³          ³ ExpC1 = Servico de Transporte.                             ³±±
±±³          ³ ExpC2 = Tipo de Transporte.                                ³±±
±±³          ³ ExpC3 = Rota da Viagem.                                    ³±±
±±³          ³ ExpA1 = Documentos marcados na Viagem de Coleta.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA240TVge( nAcao, cSerTms, cTipTra, cRotaAtu, aDoctosMrk, dDatIni, cHorIni )

Local nA         := 0
Local aAreaDT5   := DT5->( GetArea() )
Local aAreaDUD   := DUD->( GetArea() )
Local aAreaDA8   := DA8->( GetArea() )
Local aAreaDC5   := DC5->( GetArea() )
Local aAreaDC6   := DC6->( GetArea() )
Local cQuery     := ""
Local cAliasNew  := ""
Local aDtaPlan   := {}
Local lColeta    := cSerTms == StrZero( 1, Len( DC5->DC5_SERTMS ) )
Local dDatFim    := Ctod("")
Local cHorFim    := ""
Local cAtivRta   := AllTrim( GetMv( "MV_ATIVRTA",,"" ) ) //-- Atividade de retorno do Aeroporto.
Local cAtivRtp   := AllTrim( GetMv( "MV_ATIVRTP",,"" ) ) //-- Atividade de retorno do Porto

Default aDoctosMrk := {}
Default dDatIni    := dDataBase
Default cHorIni    := Left(Time(),5)

//-- Quando o Complemento for executado pela rotina de Viagem.
If nAcao == 1
	If lColeta
		DT5->( dbSetOrder( 4 ) )
		For nA := 1 To Len( aDoctosMrk )
			//-- Obtem as datas de Coleta e Entrega dos documentos.
			If DT5->( MsSeek( xFilial("DT5") + aDoctosMrk[nA, 1] + aDoctosMrk[nA, 2] + aDoctosMrk[nA, 3] ) )
				Aadd( aDtaPlan, { DT5->DT5_DATPRV, DT5->DT5_HORPRV, DT5->DT5_DATENT, DT5->DT5_HORENT  } )
			EndIf
		Next nA
	EndIf
	//-- Quando o Complemento for executado pelo menu( TMSA240 ).
ElseIf nAcao == 2
	If lColeta
		cQuery := "SELECT DT5.DT5_DATPRV, DT5.DT5_HORPRV, DT5.DT5_DATENT, DT5.DT5_HORENT"
		cQuery += " FROM " + RetSqlName("DUD") + " DUD, " + RetSqlName("DT5") + " DT5"
		cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "'"
		cQuery += " AND DUD.DUD_FILORI = '" + M->DTR_FILORI + "'"
		cQuery += " AND DUD.DUD_VIAGEM = '" + M->DTR_VIAGEM + "'"
		cQuery += " AND DUD.D_E_L_E_T_ = ''"
		cQuery += " AND DT5.DT5_FILIAL = '" + xFilial("DT5") + "'"
		cQuery += " AND DT5.DT5_FILDOC = DUD.DUD_FILDOC"
		cQuery += " AND DT5.DT5_DOC = DUD.DUD_DOC"
		cQuery += " AND DT5.DT5_SERIE = DUD.DUD_SERIE"
		cQuery += " AND DT5.D_E_L_E_T_ = ''"
		
		cQuery := ChangeQuery(cQuery)
		
		cAliasNew := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
		
		TCSetField(cAliasNew,"DT5_DATPRV","D",8,0)
		TCSetField(cAliasNew,"DT5_DATENT","D",8,0)
		
		dbSelectArea( cAliasNew )
		( cAliasNew )->( dbGoTop() )
		
		While ( cAliasNew )->( !Eof() )
			Aadd( aDtaPlan, { ( cAliasNew )->DT5_DATPRV, ( cAliasNew )->DT5_HORPRV, ( cAliasNew )->DT5_DATENT, ( cAliasNew )->DT5_HORENT  } )
			( cAliasNew )->( dbSkip() )
		EndDo
		
		( cAliasNew )->( dbCloseArea() )
	EndIf
EndIf

If lColeta
	//-- Preenche o tempo da Viagem Coleta.
	If !Empty( aDtaPlan )
		//-- Ordena o array para obter a menor data prevista de coleta.
		Asort( aDtaPlan,,,{ |x,y| Dtos( x[1] ) + x[2] < Dtos( y[1] ) + y[2] } )
		
		M->DTR_DATINI := aDtaPlan[1,1]
		M->DTR_HORINI := aDtaPlan[1,2]
		
		//-- Ordena o array para obter a maior data prevista de entrega.
		Asort( aDtaPlan,,,{ |x,y| Dtos( x[3] ) + x[4] > Dtos( y[3] ) + y[4] } )
		
		M->DTR_DATFIM := aDtaPlan[1,3]
		M->DTR_HORFIM := aDtaPlan[1,4]
		
		//-- Se o prazo de entrega nao estiver preenchido, considera a maior data prevista de coleta como data/hora final.
		If Empty( M->DTR_DATFIM ) .Or. Empty( M->DTR_HORFIM )
			//-- Ordena o array para obter a maior data prevista de coleta.
			Asort( aDtaPlan,,,{ |x,y| Dtos( x[1] ) + x[2] > Dtos( y[1] ) + y[2] } )
			
			M->DTR_DATFIM := aDtaPlan[1,1]
			M->DTR_HORFIM := aDtaPlan[1,2]
		EndIf
		
		M->DTR_TMPVGE := TmsTotHora(M->DTR_DATINI,M->DTR_HORINI,M->DTR_DATFIM,M->DTR_HORFIM, "@R 999:99")
	Else
		M->DTR_DATINI := Ctod("")
		M->DTR_HORINI := Space( Len( DTQ->DTQ_HORINI ) )
		M->DTR_DATFIM := Ctod("")
		M->DTR_HORFIM := Space( Len( DTQ->DTQ_HORFIM ) )
	EndIf
	RestArea( aAreaDT5 )
	RestArea( aAreaDUD )
Else
	//-- Preenche o tempo da Viagem Entrega/Transferencia.
	DA8->( dbSetOrder( 1 ) )
	DC5->( dbSetOrder( 1 ) )
	DC6->( dbSetOrder( 1 ) )
	
	dDatFim := dDatIni
	cHorFim := cHorIni
	
	//-- Soma o tempo da Viagem, de acordo com as atividades da Viagem.
	If DA8->( MsSeek( xFilial( 'DA8' ) + cRotaAtu ) )
		DC5->( MsSeek( cSeekDC5 := xFilial('DC5') + DA8->DA8_SERVIC ) )
		While DC5->( !Eof() .And. DC5_FILIAL + DC5_SERVIC == cSeekDC5 )
			DC6->( MsSeek( xFilial("DC6") + DC5->DC5_TAREFA ) )
			While DC6->( !Eof() .And. DC6->DC6_TAREFA == DC5->DC5_TAREFA )
				SomaDiaHor( @dDatFim, @cHorFim, HoraToInt( DC6->DC6_DURAC, 3 ) )
				
				//-- Quando for Aereo soma o tempo até encontrar a atividade de retorno do aeroporto.
				If cTipTra == StrZero( 2, Len( DC5->DC5_TIPTRA ) ) .And. Alltrim( DC6->DC6_ATIVID ) == cAtivRta
					Exit
				EndIf
				
				//-- Quando for Fluvial soma o tempo até encontrar a atividade de retorno do porto
				If cTipTra == StrZero( 3, Len( DC5->DC5_TIPTRA ) ) .And. Alltrim( DC6->DC6_ATIVID ) == cAtivRtp
					Exit
				EndIf
				
				DC6->( dbSkip() )
			EndDo
			
			DC5->( dbSkip() )
		Enddo
	EndIf
	//-- Preenche o tempo da Viagem Entrega / Transferencia.
	M->DTR_TMPVGE := TmsTotHora(dDatIni,StrTran(cHorIni, ":", ""),dDatFim,StrTran(cHorFim, ":", ""), PesqPict( "DTR", "DTR_TMPVGE") )
	If Val( M->DTR_TMPVGE ) > 0
		M->DTR_DATINI := dDatIni
		M->DTR_HORINI := StrTran( cHorIni, ":", "" )
		M->DTR_DATFIM := dDatFim
		M->DTR_HORFIM := StrTran( cHorFim, ":", "" )
	EndIf
	
	RestArea( aAreaDA8 )
	RestArea( aAreaDC5 )
	RestArea( aAreaDC6 )
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA240Off³ Autor ³ Robson Alves          ³ Data ³ 27/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Se o controle de veiculos estiver habilitado e a viagem    ³±±
±±³          ³ for planejada, o controle de veiculos sera desabilitado    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa240Off(ExpL1,ExpL2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Indica se controle de veiculos esta ligado.        ³±±
±±³          ³ ExpL2 = Indica se É viagem do tipo planejada               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA240Off( lContVei, lPlanejada )
Default lPlanejada:= .F.

//-- Quando a Viagem por planejada, trata como se o controle de veiculos estivesse desligado.

If Alltrim( FunName() ) == "TMSA240" //-- Complemento de Viagem.
	If DTQ->( MsSeek( xFilial("DTQ") + M->DTR_FILORI + M->DTR_VIAGEM ) ) .And.;
		DTQ->DTQ_TIPVIA == StrZero( 3, Len( DTQ->DTQ_TIPVIA ) ) 		 	//-- Viagem Planejada.
		
		lContVei  := .F.
		lPlanejada:= .T.
	EndIf
ElseIf Left( FunName(), 7 ) $ "TMSA140|TMSA141|TMSA143|TMSA144" //-- Viagem de Coleta.
	If	M->DTQ_TIPVIA == StrZero( 3, Len( DTQ->DTQ_TIPVIA ) ) 			//-- Viagem Planejada.
		
		lContVei  := .F.
		lPlanejada:= .T.
	EndIf
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA240DtV³ Autor ³ Robson Alves          ³ Data ³ 24/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o tempo da Viagem não coincide com outras      ³±±
±±³          ³Viagens do mesmo veiculo.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa240DtVld(ExpN1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Ordem para pesquisa                                ³±±
±±³          ³ ExpC1 = Inicio da Chave de pesquisa                        ³±±
±±³          ³ ExpC2 = Titulo do Campo( Veiculo, 1o Reboque ou 2o Reboque.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa240DtVld( cCodVei, cTitCpo )
Local lDataValida := .T.
Local lMVTMSAloc  := GetMv("MV_TMSALOC",.F.,.T.)
Local cQuery      := ''
Local cAliasQry   := ''
Local cNumVge 	  := ''
Local cStatEnc    := StrZero(3,Len(DTQ->DTQ_STATUS)) //-- Encerrado
Local cStatCan    := StrZero(9,Len(DTQ->DTQ_STATUS)) //-- Cancelado

If lMVTMSAloc .And. Empty(M->DTR_NUMVGE)
                                                                                     
	//-- Verifica se a viagem referente ao complemento esta cancelada,encerrada ou o veiculo esta em uso.
	cAliasQry := GetNextAlias()
	cQuery := "SELECT DTR.DTR_CODVEI, DTR.DTR_DATINI, DTR.DTR_HORINI, DTR.DTR_DATFIM, DTR.DTR_HORFIM, "
	cQuery += "       DTQ_FILORI, DTQ_VIAGEM, DTQ_STATUS "
	
	cQuery += "FROM " + RetSQLTab('DTR')
	
	cQuery += "JOIN " + RetSQLTab('DTQ')
	cQuery += "  ON DTQ.DTQ_FILIAL = '" + xFilial('DTQ') + "' AND "
	cQuery += "     DTQ.DTQ_FILORI = DTR.DTR_FILORI AND "
	cQuery += "     DTQ.DTQ_VIAGEM = DTR.DTR_VIAGEM AND "
	cQuery += "     DTQ_STATUS NOT IN ('"+cStatEnc+"','"+cStatCan+"') AND "
	cQuery += "     DTQ.D_E_L_E_T_ = '' "
             
	cQuery += "WHERE DTR.DTR_FILIAL = '" + xFilial('DTR') + "' "
	cQuery += "		AND DTR.DTR_CODVEI = '" + cCodVei + "' AND "
	cQuery += "		    DTR.DTR_VIAGEM <> '" + M->DTR_VIAGEM + "' AND "
	cQuery += "		    DTR.DTR_NUMVGE <> '" + M->DTR_VIAGEM + "' AND "
	cQuery += "  	 	( ('" + DtoS( M->DTR_DATINI ) + "' BETWEEN DTR.DTR_DATINI AND DTR.DTR_DATFIM AND "
	cQuery += "  	 	'" + M->DTR_HORINI + "' BETWEEN DTR.DTR_HORINI AND DTR.DTR_HORFIM) OR "        
	cQuery += "      	('" + Dtos( M->DTR_DATFIM ) + "' BETWEEN DTR.DTR_DATINI AND DTR.DTR_DATFIM AND "
	cQuery += "       	'" + M->DTR_HORFIM + "' BETWEEN DTR.DTR_HORINI AND DTR.DTR_HORFIM) OR"
	cQuery += "			( (DTR.DTR_DATINI BETWEEN '" + DtoS( M->DTR_DATINI ) + "' AND '" + Dtos( M->DTR_DATFIM ) + "') AND "
	cQuery += "			(DTR.DTR_DATFIM BETWEEN '" + DtoS( M->DTR_DATINI ) + "' AND '" + Dtos( M->DTR_DATFIM ) + "') AND "
	cQuery += "	  		(DTR.DTR_HORINI BETWEEN '" + M->DTR_HORINI + "' AND '" + M->DTR_HORFIM + "') AND "
	cQuery += "			(DTR.DTR_HORFIM BETWEEN '" + M->DTR_HORINI + "' AND '" + M->DTR_HORFIM + "') ))"
	cQuery += "  		AND DTR.D_E_L_E_T_ = '' "
                                     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

	If !(cAliasQry)->(Eof())           
		cNumVge := (cAliasQry)->DTQ_VIAGEM
		Help("",1,"TMSA24039", , cTitCpo + ": " + cCodVei + ", " + CHR(13) + CHR(10) + STR0039 + CHR(13) + CHR(10) + STR0038 + cNumVge + ".", 1, 1) //"ja esta sendo utilizado no mesmo periodo para Viagem: "
		lDataValida := .F.
	End If
	
	(cAliasQry)->(DbCloseArea())

End If

Return( lDataValida )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA240Mrk ³ Autor ³ Patricia A. Salomao³ Data ³ 26/08/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³MarkBrowse para mostrar os custos em aberto do veiculo posi ³±±
±±³          ³cionado.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA240Mrk(ExpN1,ExpC1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±³          ³ExpC1 - Codigo do Veiculo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSA240Mrk(nOpcx, cCodVei,cCodFor,cLojFor)
Local oTempTable:=  NIL
Local nOpc      := 0
Local nCntFor   := 0
Local aStru     := {}
Local aCampos   := {}
Local lInvert   := .F.
Local aAreaSDG  := SDG->(GetArea())
Local oDlg
Local lForn     := SDG->(ColumnPos("DG_CODFOR") > 0 )

Default cCodFor := Posicione("DA3",1,FwxFilial("DA3") + cCodVei, "DA3_CODFOR" )
Default cLojFor := Posicione("DA3",1,FwxFilial("DA3") + cCodVei, "DA3_LOJFOR" )

Private cMark, oMark

//-- Antes de mostrar a MarkBrowse(), valida os dados da linha posicionada
If !GdDeleted(n) .And. !Empty(GdFieldGet('DG_CODDES',n)) .And. !aAdtoLinOk()
	Return(.F.)
EndIf

//-- Aguarde...
CursorWait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos Campos da MarkBrowse                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := { {"MARK"   ,"A240Marca", "Ok"},;
{"DOC"    ,"A240Marca", AllTrim(FwX3Titulo('DG_DOC')), GetSX3Cache('DG_DOC', "X3_PICTURE") },;
{"CODDES" ,"A240Marca", AllTrim(FwX3Titulo('DG_CODDES')), GetSX3Cache('DG_CODDES', "X3_PICTURE") },;
{"DESCRI" ,"A240Marca", AllTrim(FwX3Titulo('DG_DESCRI')), GetSX3Cache('DG_DESCRI', "X3_PICTURE") }}

If lforn
	AADD(aCampos,{"CODFOR" ,"A240Marca", AllTrim(FwX3Titulo('DG_CODFOR')), GetSX3Cache('DG_CODFOR', "X3_PICTURE") })
	AADD(aCampos,{"LOJFOR" ,"A240Marca", AllTrim(FwX3Titulo('DG_LOJFOR')), GetSX3Cache('DG_LOJFOR', "X3_PICTURE") })
	AADD(aCampos,{"NOMFOR" ,"A240Marca", AllTrim(FwX3Titulo('DG_NOMFOR')), GetSX3Cache('DG_NOMFOR', "X3_PICTURE") })
	AADD(aCampos,{"CODVEI" ,"A240Marca", AllTrim(FwX3Titulo('DG_CODVEI')), GetSX3Cache('DG_CODVEI', "X3_PICTURE") })
Endif

AADD(aCampos,{"TOTAL"  ,"A240Marca", AllTrim(FwX3Titulo('DG_TOTAL')), GetSX3Cache('DG_TOTAL', "X3_PICTURE") })
AADD(aCampos,{"VALCOB" ,"A240Marca", AllTrim(FwX3Titulo('DG_VALCOB')), GetSX3Cache('DG_VALCOB', "X3_PICTURE") })
AADD(aCampos,{"SALDO"  ,"A240Marca", AllTrim(FwX3Titulo('DG_SALDO')), GetSX3Cache('DG_SALDO', "X3_PICTURE") })
AADD(aCampos,{"VENCTO" ,"A240Marca", AllTrim(FwX3Titulo('DG_DATVENC')), GetSX3Cache('DG_DATVENC', "X3_PICTURE") })
AADD(aCampos,{"NUMSEQ" ,"A240Marca", AllTrim(FwX3Titulo('DG_NUMSEQ')), GetSX3Cache('DG_NUMSEQ', "X3_PICTURE") })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao da estrutura do arquivo de Trabalho                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aStru,{ "MARK"   , "C", 2                   	, 0 })
AADD(aStru,{ "DOC"    , "C", Len(SDG->DG_DOC)    	, 0 })
AADD(aStru,{ "CODDES" , "C", Len(SDG->DG_CODDES) 	, 0 })
AADD(aStru,{ "DESCRI" , "C", 30                  	, 0 })

If lForn
	AADD(aStru,{ "CODFOR" , "C", Len(SDG->DG_CODFOR) 	, 0 })
	AADD(aStru,{ "LOJFOR" , "C", Len(SDG->DG_LOJFOR) 	, 0 })
	AADD(aStru,{ "NOMFOR" , "C", 30 	                , 0 })
	AADD(aStru,{ "CODVEI" , "C", Len(SDG->DG_CODVEI) 	, 0 })
EndIf
AADD(aStru,{ "TOTAL"  , "N", 14                  	, 2 })
AADD(aStru,{ "VALCOB" , "N", 14                  	, 2 })
AADD(aStru,{ "SALDO"  , "N", 14                  	, 2 })
AADD(aStru,{ "VENCTO" , "D", 8                   	, 0 })
AADD(aStru,{ "NUMSEQ" , "C", Len(SDG->DG_NUMSEQ)	, 0 })

oTempTable := FWTemporaryTable():New("TRB")
oTempTable:SetFields( aStru )
oTempTable:AddIndex("01", {"DOC","CODDES"} )
oTempTable:Create()

//-- So' considerar os custos do veiculo com status 'Em Aberto' / 'Baixa Parcial'
SDG->(dbSetOrder(6))
SDG->(MsSeek(xFilial('SDG')+cCodVei+StrZero(1,Len(SDG->DG_STATUS)) ,.T.))
While !SDG->(Eof()) .And. SDG->DG_CODVEI == cCodVei .And. SDG->DG_STATUS <= StrZero(2,Len(SDG->DG_STATUS))
	If SDG->DG_ORIGEM = 'SDG' .And. Empty(SDG->DG_VIAGEM) .AND. Iif(lForn, (SDG->DG_CODFOR+SDG->DG_LOJFOR == cCodFor + cLojFor) .OR. Empty(SDG->DG_CODFOR)  ,.T.)
		//-- Verifica se a Despesa ja' foi selecionada; Se ja' tiver sido, nao mostra-la novamente
		//-- na MarkBrowse()
		If (Ascan(aCols, { |x| x[GdFieldPos('DG_NUMSEQ')] == SDG->DG_NUMSEQ} )) == 0
			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			Replace MARK   With cMark
			Replace DOC    With SDG->DG_DOC
			Replace CODDES With SDG->DG_CODDES
			Replace DESCRI With Posicione('DT7',1,xFilial('DT7')+SDG->DG_CODDES,"DT7_DESCRI")
			Replace TOTAL  With SDG->DG_TOTAL
			Replace VALCOB With SDG->DG_VALCOB
			Replace SALDO  With SDG->DG_SALDO
			Replace VENCTO With SDG->DG_DATVENC
			Replace NUMSEQ With SDG->DG_NUMSEQ
		
			If lForn
				Replace CODFOR With SDG->DG_CODFOR
				Replace LOJFOR With SDG->DG_LOJFOR
				Replace NOMFOR With Posicione('SA2',1,xFilial('SA2')+SDG->DG_CODFOR+SDG->DG_LOJFOR,"A2_NOME")
				Replace CODVEI With SDG->DG_CODVEI
			EndIf
			TRB->(MsUnlock())
		EndIf
	EndIf
	SDG->(dbSkip())
EndDo

If lForn
	SDG->(dbSetOrder(9))
	SDG->(MsSeek(xFilial('SDG') + cCodFor + cLojFor ,.T.))
	While !SDG->(Eof()) .And. SDG->DG_CODFOR+SDG->DG_LOJFOR == cCodFor + cLojFor
		If SDG->DG_ORIGEM = 'SDG' .And. Empty(SDG->DG_VIAGEM) .AND. Empty(SDG->DG_CODVEI) 
			//-- Verifica se a Despesa ja' foi selecionada; Se ja' tiver sido, nao mostra-la novamente
			//-- na MarkBrowse()
			If (Ascan(aCols, { |x| x[GdFieldPos('DG_NUMSEQ')] == SDG->DG_NUMSEQ} )) == 0
				dbSelectArea("TRB")
				RecLock("TRB",.T.)
				Replace MARK   With cMark
				Replace DOC    With SDG->DG_DOC
				Replace CODDES With SDG->DG_CODDES
				Replace DESCRI With Posicione('DT7',1,xFilial('DT7')+SDG->DG_CODDES,"DT7_DESCRI")
				Replace CODFOR With SDG->DG_CODFOR
				Replace LOJFOR With SDG->DG_LOJFOR
				Replace NOMFOR With Posicione('SA2',1,xFilial('SA2')+SDG->DG_CODFOR+SDG->DG_LOJFOR,"A2_NOME")
				Replace CODVEI With SDG->DG_CODVEI
				Replace TOTAL  With SDG->DG_TOTAL
				Replace VALCOB With SDG->DG_VALCOB
				Replace SALDO  With SDG->DG_SALDO
				Replace VENCTO With SDG->DG_DATVENC
				Replace NUMSEQ With SDG->DG_NUMSEQ
				TRB->(MsUnlock())
			EndIf
		EndIf
		SDG->(dbSkip())
	EndDo
EndIf

dbSelectArea("TRB")
dbGoTop()

//-- Desliga Aguarde...
CursorArrow()

If TRB->(!Eof())
	DEFINE MSDIALOG oDlg TITLE STR0036 From 2,0 To 24,75 OF oMainWnd //"Despesas em Aberto"
	
	@ 017,005 SAY STR0009 SIZE 100,15 COLOR CLR_HBLUE PIXEL //"Veiculo :"
	@ 017,030 SAY  cCodVei    SIZE 200,15 PIXEL
	
	oMark := MsSelect():New("TRB","MARK",,aCampos,@lInvert,@cMark,{30,02,160,295})
	
	oMark:oBrowse:lHasMark		:= .T.
	oMark:oBrowse:lCanAllMark 	:= .T.
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IIF(Obrigatorio(aGets,aTela),(nOpc:=1,oDlg:End()),(nOpc:=0))},{||oDlg:End()} ) CENTERED
	
	If nOpc == 1
		n:= Len(aCols) //-- Ultima linha do aCols
		dbSelectArea( "TRB" )
		dbGoTop()
		//-- Carrega a GetDados de Adiantamento com as Depesas Selecionadas
		Do While !TRB->(Eof())
			If	!TRB->( IsMark( 'MARK', ThisMark(), ThisInv() ) ) .Or. TRB->( Eof() )
				TRB->(dbSkip())
				Loop
			EndIf
			
			//-- Se a ultima linha do aCols estiver preenchida ou deletada, adiciona uma linha em branco
			If !Empty(GdFieldGet('DG_CODDES',n)) .Or. GdDeleted(n)
				n++
				Aadd(aCols,Array(Len(aHeader)+1))
				For nCntFor := 1 To Len(aHeader)
					aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
				Next
				aCols[Len(aCols),Len(aHeader)+1] := .F.
			EndIf
			GdFieldPut('DG_CODDES' , TRB->CODDES , n)
			GdFieldPut('DG_DESCRI' , TRB->DESCRI , n)
			GdFieldPut('DG_TOTAL'  , TRB->TOTAL  , n)
			GdFieldPut('DG_VALCOB' , TRB->VALCOB , n)
			GdFieldPut('DG_SALDO'  , TRB->SALDO  , n)
			GdFieldPut('DG_DATVENC', TRB->VENCTO , n)
			GdFieldPut('DG_NUMSEQ' , TRB->NUMSEQ , n)
			GdFieldPut('DG_TIPDES' , StrZero(2,Len(SDG->DG_STATUS)) , n)	//-- Despesa Selecionada
			If lForn
				If Empty( GdFieldGet('DG_CODVEI' , n) )
					GdFieldPut('DG_CODVEI' , cCodVei , n)
				EndIf

				If Empty( GdFieldGet('DG_CODFOR' , n) )
					dbSelectArea("DA3")
					DA3->(dbSetOrder(1))
					If DA3->(dbSeek(FwxFilial("DA3") + cCodVei ))
						GdFieldPut('DG_CODFOR' , DA3->DA3_CODFOR , n)
						GdFieldPut('DG_LOJFOR' , DA3->DA3_LOJFOR , n)
					EndIf			
				EndIf
			EndIf
			TRB->(dbSkip())
		EndDo
		oGDados:oBrowse:nAt := n
		oGDados:oBrowse:Refresh(.T.)
	EndIf
Else
	Help("",1,"TMSA24040") //"Nao existem despesas em aberto para serem selecionadas"
EndIf

oTempTable:Delete() //-- Deleta arquivo temporario do banco

RestArea(aAreaSDG)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA240Chq ³ Autor ³ Patricia A. Salomao³ Data ³ 27/08/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o Cheque Informado                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA240Chq()

Local lRet     := .T.
Local cBanco   := GdFieldGet('DG_BANCO'  , n)
Local cAgencia := GdFieldGet('DG_AGENCIA', n)
Local cConta   := GdFieldGet('DG_NUMCON' , n)
Local cNumChq  := M->DG_NUMCHEQ

lRet := ExistChav("SEF",cBanco+cAgencia+cConta+cNumChq,1,"JaTemCheq" )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA240Con ³ Autor ³ Patricia A. Salomao³ Data ³ 27/08/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o Banco/Agencia/Conta Informada                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA240Con()

Local cBanco   := GdFieldGet('DG_BANCO'  , n)
Local cAgencia := GdFieldGet('DG_AGENCIA', n)
Local cConta   := M->DG_NUMCON

IF !Empty(cBanco) .Or. !Empty(cAgencia) .Or. !Empty(cConta)
	SA6->(dbSetOrder(1))
	If !SA6->(MsSeek(xFilial('SA6')+cBanco+cAgencia+cConta))
		Help(" ",1,"BCONOEXIST") //"Verifique Codigo/Agencia/Conta do Banco,pois o mesmo nao se encontra cadastrado"
		Return(.F.)
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMA240DelTi³ Autor ³ Patricia A. Salomao³ Data ³ 27/09/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Deleta o Titulo gerado para as Despesas que movimentam finan³±±
±±³          ³ceiro (Tipo "PA")                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo do Veiculo                                   ³±±
±±³          ³ExpC2 - Historico (DG_HISTOR)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMA240DelTit(cCodVei, cHistor, cCodFavDTR, cLojFavDTR)

Local cPrefixo 		:= TMA250GerPrf(cFilAnt)
Local cCodFav  		:= ''
Local cLojFav  		:= ''
Local cParcela 		:= ''
Local lRet     		:= .T.
Local cTypeMsg 		:= '1'
Local cSubTipMsg	:= '101'
Local lDTRCodFav    := DTR->(ColumnPos("DTR_CODFAV")) > 0

Default cCodFavDTR  := ""
Default cLojFavDTR  := ""

//-- Proprietario do Veiculo
DA3->(dbSetOrder(1))
DA3->(MsSeek(xFilial('DA3')+ cCodVei ))   

If lDTRCodFav .And. !Empty(cCodFavDTR)
	cCodFav:= cCodFavDTR
	cLojFav:= cLojFavDTR
Else
	//--Busca o favorecido do veículo
	If !Empty(cCodVei)
		cCodFav := Posicione('DA3',1,xFilial("DA3")+cCodVei,"DA3_CODFAV")  
		cLojFav := DA3->DA3_LOJFAV
	EndIf 

	//-- Se nao encontrou favorecido no veiculo, procura no cadastro do proprietario (fornecedor)
	If Empty(cCodFav)
		SA2->(dbSetOrder(1))
		SA2->(MsSeek(xFilial('SA2')+DA3->DA3_CODFOR+DA3->DA3_LOJFOR))
		cCodFav := If(SA2->(FieldPos("A2_CODFAV"))>0,SA2->A2_CODFAV,"")
		cLojFav := If(SA2->(FieldPos("A2_LOJFAV"))>0,SA2->A2_LOJFAV,"")
	EndIf 
EndIf
If SDG->(FieldPos('DG_PARC')) > 0
	cParcela := SDG->DG_PARC
Else
	If !Empty(cHistor)
		cParcela := Substr(cHistor, AT('=',cHistor)+2, Len(SE2->E2_PARCELA))
	EndIf
EndIf

lRet := TMA250DelTit(cPrefixo, M->DTR_VIAGEM, ,DA3->DA3_CODFOR, DA3->DA3_LOJFOR, cCodFav, cLojFav, cParcela, ,cTypeMsg, cSubTipMsg)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSMotLib ³ Autor ³ Eduardo de Souza      ³ Data ³ 03/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna os motorista aptos a transportar                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSMotLib()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Filial Origem                                       ³±±
±±³          ³ExpC2 - Viagem                                              ³±±
±±³          ³ExpL1 - Bloqueados                                          ³±±
±±³          ³ExpL2 - Carga Perigosa                                      ³±±
±±³          ³ExpL3 - Seguro                                              ³±±
±±³          ³ExpA1 - Documentos da Viagem                                ³±±
±±³          ³ExpA2 - Posicoes [1-Marca/2-FilDoc/3-Docto/4-Serie/5-Delete]³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSMotLib(cFilOri,cViagem,lBlq,lCarPer,lSeguro,aDoctos,aPosicao,oGetDados)

Local oDlgEsp
Local cHDlgEsp    := STR0050 // 'Motoristas Liberados'
Local cAliasQry   := GetNextAlias()
Local cQuery      := ''
Local nValor      := 0
Local cCarPer     := ''
Local aSize       := {}
Local aInfo       := {}
Local aObjects    := {}
Local aPosObj     := {}
Local aButtons    := {}
Local aHMot       := {}
Local nOpcA       := 0
Local lColeta     := .F.
Local nCnt        := 0
Local aArea       := GetArea()
Local aAreaDF8    := DF8->(GetArea())
Local lContVei    := GetMV('MV_CONTVEI',,.T.)
Local lMVITMSDMD  := SuperGetMv("MV_ITMSDMD",.F.,.F.) //Parametro que indica se a Gestão de Demandas está ativa ou não.
Local lGestDeman  := .F. 
Local lLGPD		  := ExistFunc('FWPDCanUse') .And. FWPDCanUse(.T.)
Local cNomeMot	  := ""
Local cNreduz	  := ""	
Local cCGCMot	  := ""
Local cTipMot   := ''

Default lBlq      := .T.
Default lCarPer   := .T.
Default lSeguro   := .T.
Default aDoctos   := {}
Default aPosicao  := {}

Private aMotLib   := {}
Private oNoMarked := LoadBitmap( GetResources(),'LBNO' )
Private oMarked	  := LoadBitmap( GetResources(),'LBOK' )

If lCarPer .Or. lSeguro
	
	//-- Verifica se eh viagem de coleta
	If Type('M->DTQ_SERTMS') == 'C'
		lColeta := ( M->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS)) )
	Else
		DTQ->( dbSetOrder( 2 ) )
		If DTQ->( MsSeek( xFilial('DTQ') + M->DTR_FILORI + M->DTR_VIAGEM ) )
			lColeta := ( DTQ->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS)) )
		EndIf
	EndIf
	
	If !Empty(aDoctos) .And. !Empty(aPosicao)
		For nCnt := 1 To Len(aDoctos)
			If aPosicao[1] == 0 .Or. aDoctos[nCnt,aPosicao[1]]
				//-- Verifica se a linha esta deletada
				If Len(aPosicao) > 4 .And. aDoctos[nCnt,aPosicao[5]]
					Loop
				EndIf
				If lColeta
					cQuery := " SELECT MAX(B5_CARPER) CARPER, SUM(DUM_VALMER) VALOR "
					cQuery += "   FROM " + RetSqlName("DT5") + " DT5 "
					cQuery += "   JOIN " + RetSqlName("DUM") + " DUM "
					cQuery += "     ON DUM_FILIAL = '" + xFilial("DUM") + "' "
					cQuery += "     AND DUM_FILORI = DT5_FILORI "
					cQuery += "     AND DUM_NUMSOL = DT5_NUMSOL "
					cQuery += "     AND DUM.D_E_L_E_T_ = ' ' "
					cQuery += "   LEFT JOIN " + RetSqlName("SB5") + " SB5 "
					cQuery += "     ON B5_FILIAL = '" + xFilial("SB5") + "' "
					cQuery += "     AND B5_COD    = DUM_CODPRO "
					cQuery += "     AND B5_CARPER = '1' "
					cQuery += "     AND SB5.D_E_L_E_T_ = ' ' "
					cQuery += "   WHERE DT5_FILIAL = '" + xFilial("DT5") + "' "
					cQuery += "     AND DT5_FILDOC = '" + aDoctos[nCnt,aPosicao[2]] + "' "
					cQuery += "     AND DT5_DOC    = '" + aDoctos[nCnt,aPosicao[3]] + "' "
					cQuery += "     AND DT5_SERIE  = '" + aDoctos[nCnt,aPosicao[4]] + "' "
					cQuery += "     AND DT5.D_E_L_E_T_ = ' ' "
				Else
					cQuery := " SELECT MAX(B5_CARPER) CARPER, SUM(DTC_VALOR) VALOR "
					cQuery += "   FROM " + RetSqlName("DTC") + " DTC "
					cQuery += "   LEFT JOIN " + RetSqlName("SB5") + " SB5 "
					cQuery += "     ON B5_FILIAL = '" + xFilial("SB5") + "' "
					cQuery += "     AND B5_COD   = DTC_CODPRO "
					cQuery += "     AND B5_CARPER = '1' "
					cQuery += "     AND SB5.D_E_L_E_T_ = ' ' "
					cQuery += "   WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
					cQuery += "     AND DTC_FILDOC = '" + aDoctos[nCnt,aPosicao[2]] + "' "
					cQuery += "     AND DTC_DOC    = '" + aDoctos[nCnt,aPosicao[3]] + "' "
					cQuery += "     AND DTC_SERIE  = '" + aDoctos[nCnt,aPosicao[4]] + "' "
					cQuery += "     AND DTC.D_E_L_E_T_ = ' ' "					
					cQuery += "     UNION "
					cQuery += " SELECT MAX(B5_CARPER) CARPER, SUM(DTC_VALOR) VALOR "
					cQuery += "   FROM " + RetSqlName("DY4") + " DY4 "									
					cQuery += "   INNER JOIN " + RetSqlName("DT6") + " DT6 "
					cQuery += "   	ON DT6_FILIAL		= DY4_FILIAL"						
					cQuery += "   	AND DT6_FILDOC	= DY4_FILDOC"
					cQuery += "   	AND DT6_DOC		= DY4_DOC"
					cQuery += "   	AND DT6_SERIE		= DY4_SERIE"
					cQuery += "   INNER JOIN " + RetSqlName("DTC") + " DTC "
					cQuery += "   	ON DTC_FILIAL		= DY4_FILIAL"
					cQuery += "   	AND DTC_NUMNFC		= DY4_NUMNFC"
					cQuery += "   	AND DTC_LOTNFC		= DY4_LOTNFC"
					cQuery += "   	AND DTC_SERNFC		= DY4_SERNFC"
					cQuery += "   LEFT JOIN " + RetSqlName("SB5") + " SB5 "
					cQuery += "     ON B5_FILIAL = '" + xFilial("SB5") + "' "
					cQuery += "     AND B5_COD   = DTC_CODPRO "
					cQuery += "     AND B5_CARPER = '1' "
					cQuery += "     AND SB5.D_E_L_E_T_ = ' ' "					
					cQuery += "   WHERE DY4_FILIAL = '" + xFilial("DY4") + "' "
					cQuery += "     AND DY4_FILDOC = '" + aDoctos[nCnt,aPosicao[2]] + "' "
					cQuery += "     AND DY4_DOC    = '" + aDoctos[nCnt,aPosicao[3]] + "' "
					cQuery += "     AND DY4_SERIE  = '" + aDoctos[nCnt,aPosicao[4]] + "' "
					cQuery += "     AND DY4.D_E_L_E_T_ = ' ' "					
				EndIf
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				If !(cAliasQry)->(Eof())
					If cCarPer <> StrZero(1,Len(SB5->B5_CARPER)) //-- Sim
						cCarPer := (cAliasQry)->CARPER
					EndIf
					nValor  += (cAliasQry)->VALOR
				EndIf
				(cAliasQry)->(DbCloseArea())
			EndIf
		Next nCnt
	Else
		If lColeta
			cQuery := " SELECT MAX(B5_CARPER) CARPER, SUM(DUM_VALMER) VALOR "
			cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
			cQuery += "   JOIN " + RetSqlName("DT5") + " DT5 "
			cQuery += "     ON DT5_FILIAL = '" + xFilial("DT5") + "' "
			cQuery += "     AND DT5_FILDOC = DUD_FILDOC "
			cQuery += "     AND DT5_DOC    = DUD_DOC "
			cQuery += "     AND DT5_SERIE  = DUD_SERIE "
			cQuery += "     AND DT5.D_E_L_E_T_ = ' ' "
			cQuery += "   JOIN " + RetSqlName("DUM") + " DUM "
			cQuery += "     ON DUM_FILIAL = '" + xFilial("DUM") + "' "
			cQuery += "     AND DUM_FILORI = DT5_FILORI "
			cQuery += "     AND DUM_NUMSOL = DT5_NUMSOL "
			cQuery += "     AND DUM.D_E_L_E_T_ = ' ' "
			cQuery += "   LEFT JOIN " + RetSqlName("SB5") + " SB5 "
			cQuery += "     ON B5_FILIAL  = '" + xFilial("SB5") + "' "
			cQuery += "     AND B5_COD    = DUM_CODPRO "
			cQuery += "     AND B5_CARPER = '1' "
			cQuery += "     AND SB5.D_E_L_E_T_ = ' ' "
			cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
			cQuery += "     AND DUD_FILORI = '" + cFilOri + "' "
			cQuery += "     AND DUD_VIAGEM = '" + cViagem + "' "
			cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
			cQuery += "   GROUP BY DUD_FILORI, DUD_VIAGEM "
		Else
			cQuery := " SELECT MAX(B5_CARPER) CARPER, SUM(DTC_VALOR) VALOR "
			cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
			cQuery += "   JOIN " + RetSqlName("DTC") + " DTC "
			cQuery += "     ON DTC_FILIAL = '" + xFilial("DTC") + "' "
			cQuery += "     AND DTC_FILDOC = DUD_FILDOC "
			cQuery += "     AND DTC_DOC    = DUD_DOC "
			cQuery += "     AND DTC_SERIE  = DUD_SERIE "
			cQuery += "     AND DTC.D_E_L_E_T_ = ' ' "
			cQuery += "   LEFT JOIN " + RetSqlName("SB5") + " SB5 "
			cQuery += "     ON B5_FILIAL = '" + xFilial("SB5") + "' "
			cQuery += "     AND B5_COD   = DTC_CODPRO "
			cQuery += "     AND B5_CARPER = '1' "
			cQuery += "     AND SB5.D_E_L_E_T_ = ' ' "
			cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
			cQuery += "     AND DUD_FILORI = '" + cFilOri + "' "
			cQuery += "     AND DUD_VIAGEM = '" + cViagem + "' "
			cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
			cQuery += "   GROUP BY DUD_FILORI, DUD_VIAGEM "
		EndIf
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		If !(cAliasQry)->(Eof())
			cCarPer := (cAliasQry)->CARPER
			nValor  := (cAliasQry)->VALOR
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
EndIf

cQuery := " SELECT DA4_COD   , DA4_NOME  , DA4_NREDUZ, DA4_CGC   , "
cQuery += "        DA4_TIPMOT, DA4_CARPER, DA4_BLQMOT, DA4_VALSEG, "
cQuery += "        DA4_FORNEC, DA4_LOJA "
cQuery += "   FROM " + RetSqlName("DA4") + " DA4 "
cQuery += "   WHERE DA4_FILIAL = '" + xFilial("DA4") + "' "
//-- Filtra Motoristas Bloqueados
If lBlq
	cQuery += "   AND DA4_BLQMOT <> '1' "
EndIf
//-- Filtra Motoristas que estao aptos a carga perigosa
If lCarPer .And. cCarPer == '1'
	cQuery += "   AND DA4_CARPER = '1' "
EndIf
//-- Filtra Motoristas com valor do seguro inferior ao valor total da viagem
If lSeguro .And. nValor > 0
	cQuery += "   AND DA4_VALSEG >= " + Alltrim(Str(nValor))
EndIf
//-- Filtra Motorista Liberados
If lContVei
	cQuery += "   AND EXISTS ( "
	cQuery += "   			SELECT 1 FROM " + RetSqlName("DTO")
	cQuery += "   			  WHERE DTO_FILIAL = '" + xFilial("DTO") + "' "
	cQuery += "   			  AND DTO_CODMOT = DA4_COD "
	cQuery += "   			  AND DTO_STATUS = '2' "
	cQuery += "   			  AND D_E_L_E_T_ = ' ' ) "
EndIf
cQuery += "   AND DA4.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
While (cAliasQry)->(!Eof())
	
	aSx3Box := RetSx3Box( Posicione('SX3', 2, 'DA4_TIPMOT', 'X3CBox()' ),,, 1 )
	cTipMot := AllTrim( aSx3Box[ Ascan( aSx3Box, { |x| x[ 2 ] == (cAliasQry)->DA4_TIPMOT } ) , 3 ] )
	
	aSx3Box := RetSx3Box( Posicione('SX3', 2, 'DA4_CARPER', 'X3CBox()' ),,, 1 )
	cCarPer := AllTrim( aSx3Box[ Ascan( aSx3Box, { |x| x[ 2 ] == (cAliasQry)->DA4_CARPER } ) , 3 ] )
	
	aSx3Box := RetSx3Box( Posicione('SX3', 2, 'DA4_BLQMOT', 'X3CBox()' ),,, 1 )
	cBloq   := AllTrim( aSx3Box[ Ascan( aSx3Box, { |x| x[ 2 ] == (cAliasQry)->DA4_BLQMOT } ) , 3 ] )
	
	If lLGPD 
		If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"DA4_NOME"} )) > 0		
			cNomeMot 	:= (cAliasQry)->DA4_NOME
			cNreduz		:= (cAliasQry)->DA4_NREDUZ
			cCGCMot		:= (cAliasQry)->DA4_CGC
		Else				
			cNomeMot 	:= Replicate('*',TamSX3('DA4_NOME')[1])
			cNreduz		:= Replicate('*',TamSX3('DA4_NREDUZ')[1])
			cCGCMot		:= Replicate('*',TamSX3('DA4_CGC')[1])
		EndIf	
	Else	
		cNomeMot 	:= (cAliasQry)->DA4_NOME
		cNreduz		:= (cAliasQry)->DA4_NREDUZ
		cCGCMot		:= (cAliasQry)->DA4_CGC
	EndIf


	Aadd( aMotLib, { 	.F., (cAliasQry)->DA4_COD, cNomeMot, cNreduz, ;
	cCGCMot, cTipMot, cCarPer, cBloq, (cAliasQry)->DA4_VALSEG,;
	(cAliasQry)->DA4_FORNEC, (cAliasQry)->DA4_LOJA, (cAliasQry)->DA4_TIPMOT } )
	
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())
RestArea( aArea )

If !Empty(aMotLib)
	//-- Dimensoes padroes
	aSize   := MsAdvSize()
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo   := { aSize[ 1 ]/2, aSize[ 2 ]/2, aSize[ 3 ]/2, aSize[ 4 ]/2, 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)
	
	aAdd(aButtons,{"PESQUISA",{||MotLibPes(oLbx)}, STR0052 , STR0052 }) // "Pesquisa"
	aAdd(aButtons,{"BMPUSER" ,{||MotLibVis(oLbx)}, STR0051 , STR0051 }) // "Motorista"
	
	Aadd( aHMot, " "                    )
	Aadd( aHMot, RetTitle("DA4_COD"   ) )
	Aadd( aHMot, RetTitle("DA4_NOME"  ) )
	Aadd( aHMot, RetTitle("DA4_NREDUZ") )
	Aadd( aHMot, RetTitle("DA4_CGC"   ) )
	Aadd( aHMot, RetTitle("DA4_TIPMOT") )
	Aadd( aHMot, RetTitle("DA4_CARPER") )
	Aadd( aHMot, RetTitle("DA4_BLQMOT") )
	Aadd( aHMot, RetTitle("DA4_VALSEG") )
	Aadd( aHMot, RetTitle("DA4_FORNEC") )
	Aadd( aHMot, RetTitle("DA4_LOJA"  ) )
	
	DEFINE MSDIALOG oDlgEsp FROM aSize[7]/2,00 TO aSize[6]/2,aSize[5]/2 TITLE cHDlgEsp	OF oMainWnd PIXEL
	oLbx := TWBrowse():New( 30,10,aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1], NIL, ;
	aHMot, NIL, oDlgEsp, NIL, NIL, NIL,,,,,,,,,, "ARRAY", .T. )
	oLbx:SetArray( aMotLib )
	oLbx:bLine := &('{ || TMSAMotLine(oLbx:nAt) }')
	
	//Se vier da Gestão de Demandas não permite alterar.
	If lMVITMSDMD .AND. DF8->(ColumnPos("DF8_PLNDMD")) > 0  //SUAVIZAÇÃO DEMANDAS
		If IsInCallStack('TMSA146')
			lGestDeman := .T.
		Else
			If ALTERA
				DF8->(DbSetOrder(2))
				DF8->(MsSeek( xFilial('DF8') + cFilOri + cViagem))
				If !Empty(DF8->DF8_PLNDMD) 
					lGestDeman := .T.
				EndIf
			EndIf
		EndIf
	EndIf
		
	If !lGestDeman
		oLbx:blDblClick := {|| aMotLib[oLbx:nAt,1] := !aMotLib[oLbx:nAt,1] }
	EndIf
	
	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| nOpcA := 1,oDlgEsp:End() },{|| oDlgEsp:End() },, aButtons ) CENTERED
	
	If nOpcA == 1
		MotLibAtu(@oGetDados)
	EndIf
	
EndIf

RestArea( aAreaDF8 )

Return aMotLib

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAMotLine³ Autor ³ Eduardo de Souza     ³ Data ³ 03/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao da bLine                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAMotLine(ExpN1,ExpCA)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Posicao da linha no listbox                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSMOTLIB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAMotLine(nAt)

Local abLine := {}

Aadd( abLine, If(aMotLib[nAt,1],oMarked,oNoMarked) )
Aadd( abLine, aMotLib[nAt,02] )
Aadd( abLine, aMotLib[nAt,03] )
Aadd( abLine, aMotLib[nAt,04] )
Aadd( abLine, Transform(aMotLib[nAt,05],PesqPict('DA4','DA4_CGC')) )
Aadd( abLine, aMotLib[nAt,06] )
Aadd( abLine, aMotLib[nAt,07] )
Aadd( abLine, aMotLib[nAt,08] )
Aadd( abLine, Transform(aMotLib[nAt,09],PesqPict('DA4','DA4_VALSEG')) )
Aadd( abLine, aMotLib[nAt,10] )
Aadd( abLine, aMotLib[nAt,11] )

Return abLine

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MotLibPes ³ Autor ³Eduardo de Souza       ³ Data ³ 06/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³	Pesquisa	Motorista Liberado		      				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MotLibPes()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSMOTLIB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MotLibPes(oLbx)

Local oDlg
Local oCbx
Local oBigGet
Local cOrd	  :=""
Local aOrd	  :={}
Local cCampo  :=Space(14)
Local aArea	  :=GetArea()
Local lSeek	  :=.F.
Local nSeek	  := 0
Local nOrdem  := 1

Aadd(aOrd,AllTrim(RetTitle("DA4_COD")))
Aadd(aOrd,AllTrim(RetTitle("DA4_NOME")))
Aadd(aOrd,AllTrim(RetTitle("DA4_CGC")))
Aadd(aOrd,AllTrim(Alltrim(RetTitle("DA4_FORNECE"))+"+"+RetTitle("DA4_LOJA")))

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0052 // "Pesquisa"

@05,05 COMBOBOX oCBX VAR cOrd ITEMS aOrd SIZE 206,36 PIXEL OF oDlg FONT oDlg:oFont ON CHANGE nOrdem := oCbx:nAt
@22,05 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek:=.T.,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If lSeek
	If nOrdem == 1
		aMotLib := aSort( aMotLib,,,{ |x,y| x[2] < y[2] } )
		nSeek   := Ascan(aMotLib, {|x| AllTrim(x[2]) = AllTrim(cCampo)})
	ElseIf nOrdem == 2
		aMotLib := aSort( aMotLib,,,{ |x,y| x[3] < y[3] } )
		nSeek   := Ascan(aMotLib, {|x| AllTrim(x[3]) = AllTrim(cCampo)})
	ElseIf nOrdem == 3
		aMotLib := aSort( aMotLib,,,{ |x,y| x[5] < y[5] } )
		nSeek   := Ascan(aMotLib, {|x| AllTrim(x[5]) = AllTrim(cCampo)})
	ElseIf nOrdem == 4
		aMotLib := aSort( aMotLib,,,{ |x,y| x[10]+x[11] < y[10]+y[11] } )
		nSeek   := Ascan(aMotLib, {|x| AllTrim(x[10]+x[11]) = AllTrim(cCampo)})
	EndIf
	If nSeek > 0
		oLbx:nAt := nSeek
		oLbx:Refresh()
	EndIf
EndIf

RestArea( aArea )

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MotLibVis ³ Autor ³Eduardo de Souza       ³ Data ³ 06/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³	Visualiza Motorista Liberado		      				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MotLibVis()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSMOTLIB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MotLibVis(oLbx)

Local aAreaDA4 := DA4->(GetArea())
Local cCadOld  := cCadastro
cCadastro := STR0051 // 'Motoristas'

DA4->(DbSetOrder(1))
If DA4->(MsSeek(xFilial('DA4')+aMotLib[oLbx:nAt,2]))
	AxVisual('DA4',DA4->(RecNo()),2)
EndIf

cCadastro := cCadOld
RestArea( aAreaDA4 )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MotLibAtu ³ Autor ³ Eduardo de Souza      ³ Data ³ 06/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza aCols de motoristas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MotLibAtu()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA144                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MotLibAtu(oGetDados)

Local nCnt     := 0
Local lAddNew  := .F.
Local nPosCod  := GDFieldPos("DUP_CODMOT")
//-- Operadoras de Frota/Vale-Pedagio
Local cTMSOPdg := SuperGetMV( 'MV_TMSOPDG',, '0' )

ASort( aMotLib,,,{|x,y| x[1] > y[1] })

For nCnt := 1 To Len(aMotLib)
	
	//-- Somente marcados
	If !aMotLib[nCnt,1]
		Exit
	EndIf
	
	//-- Verifica se o motorista ja foi informado
	If Ascan( aCols, { |x| x[nPosCod] == aMotLib[nCnt,2] } ) <> 0
		Loop
	EndIf
	
	//-- Inclui nova linha na aCols
	If lAddNew
		TMSA210Cols()
		n := Len(aCols)
	Else
		lAddNew := .T.
	EndIf
	
	GDFieldPut( 'DUP_CODMOT', aMotLib[nCnt,02] , n )
	GDFieldPut( 'DUP_NOMMOT', aMotLib[nCnt,03] , n )
	GDFieldPut( 'DUP_TIPMOT', aMotLib[nCnt,12] , n )
	
	If cTMSOPdg <> '0'
		If GDFieldPos('DUP_IDOPE') > 0
			DEL->( DbSetOrder(2) )
			If DEL->( MsSeek(xFilial('DEL') + GDFieldGet('DUP_CODMOT', n)  + M->DTR_CODOPE ))
				GDFieldPut( 'DUP_IDOPE', DEL->DEL_IDOPE, n )
			EndIf
		EndIf
	EndIf
	
	If !aMotLinOk()
		lAddNew := .F.
	EndIf
	
Next nCnt

//-- Posiciona no item posicionado para validacao
n := oGetDados:oBrowse:nAt

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMS240VlId ³ Autor ³ Vitor Raspa        ³ Data ³ 22.Jun.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o Id. do Motorista junto a Operadora de Frotas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo da Operadora                                 ³±±
±±³          ³ExpC2 - Id. Informado                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMS240VlId(cCodOpe, cIdOpe,  cTipMot, cCodMot)
Local aArea     := GetArea()
Local aAreaDA4  := DA4->(GetArea())
Local lRet      := .T.
Local aConsCard := {}
Local cCodFor 	 := ""
Local cLojFor	 := ""
Local lRespCart := .F.
Local lTabDLD   := TableInDic('DLD')
Local cInValePdg:= '4198'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ POSICIONA NO CADASTRO DA OPERADORA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEG->( DbSetOrder(1) )
DEG->( MsSeek(xFilial('DEG') + cCodOpe) )

If cCodOpe == '01' //--REPOM
	
	//-- Verifica se o Id informado ja foi validado na secao atual
	If AScan( aVldId, {|x| x[3] == cIdOpe} ) == 0
		
		//-- Código movido para TMSRepom.prw
		If (lRet := RepVldId(cTipMot,cIdOpe))
			AAdd( aVldId, {cCodOpe, cTipMot, cIdOpe} )
		EndIf
	EndIf
ElseIf cCodOpe == '02' 

	aRetCNPJ := PamCNPJEmp(cCodOpe, cFilAnt) //Função para obter CNPJ da contrante e filial de origem
	
	//-- Montagem Array para Integração com PamCard
	AAdd(aConsCard,{'viagem.contratante.documento.numero',aRetCNPJ[1]})
	AAdd(aConsCard,{'viagem.unidade.documento.tipo'      ,aRetCNPJ[2]})
	AAdd(aConsCard,{'viagem.unidade.documento.numero'    ,aRetCNPJ[3]}) 
	AAdd(aConsCard,{'viagem.cartao.numero', cIdOpe } )
		
	//Verifica os dados do fornecedor portador do cartão(conceito novo) ou do fornecedor do motorista(conceito antigo)
	If AliasIndic('DDQ')
		DDQ->(dbSetOrder(1))	
		If DDQ->(MsSeek(xFilial('DDQ')+cIdOpe))
			cCodFor   := DDQ->DDQ_CODFOR
			cLojFor   := DDQ->DDQ_LOJFOR
			lRespCart := .T.
		Else                                     
			DA4->( DbSetOrder(1) )
			If DA4->( MsSeek(xFilial("DA4") + cCodMot, .F. ))
				cCodFor := DA4->DA4_FORNEC
				cLojFor := DA4->DA4_LOJA
			EndIf	
		EndIf      
	Else
		DA4->( DbSetOrder(1) )
		If DA4->( MsSeek(xFilial("DA4") + cCodMot, .F. ))	
			cCodFor := DA4->DA4_FORNEC
		  	cLojFor := DA4->DA4_LOJA
		EndIf
	EndIf
	
	lRet := PamVldFor(cCodFor, cLojFor, lRespCart) //Valida dados do contratado
	If !lRet .And. lRespCart
		Help('',1,'TMSA240A5',,,6,0) //"RNTRC não foi informado para o fornecedor"
	ElseIf !lRet
		Help('',1,'OMSA04009',,,6,0) //"Itens obrigatorios para inclusão não foram preenchidos na tabela de Fornecedores"
	ElseIf lRet .And. lTabDLD .And. !Empty(cIdOpe)	.And. cInValePdg <> Padr(cIdOpe,4)	 		
		
		If !PamFindCar(aConsCard, .T.) //-- Montagem Array Pamcard - Inserir Cartão Portador Frete - InsertCardFreight  
			lRet := PamInsCtPF(aRetCNPJ, cCodFor, cLojFor, cIdOpe, lRespCart)
		EndIf	
	
	EndIf
EndIf

RestArea( aAreaDA4 )
RestArea( aArea )

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ aMotPlanej ³ Autor ³ Vitor Raspa       ³ Data ³ 18.Set.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se o Motorista esta esta em alguma viagem planejada ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExpC1 - Filial de Origem                                  ³±±
±±³          ³ cExpC2 - Numero da Viagem                                  ³±±
±±³          ³ cExpC3 - Codigo do Motorista                               ³±±
±±³          ³ aExpA1 - Array com o periodo de planejamento:              ³±±
±±³          ³          aExpA1[1] - Data Inicio                           ³±±
±±³          ³          aExpA1[2] - Hora de Inicio                        ³±±
±±³          ³          aExpA1[3] - Data Final                            ³±±
±±³          ³          aExpA1[4] - Hora Final                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA240                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function aMotPlanej( cFilOri, cViagem, cCodMot, aPlanej )

Local lRet       := .T.
Local cNumVge    := ''
Local aAreaDTR   := DTR->(GetArea())
Local cQuery     := ''
Local cAliasQry  := GetNextAlias()
Local cPeriodIni := DtoS(aPlanej[1]) + aPlanej[2]
Local cPeriodFim := DtoS(aPlanej[3]) + aPlanej[4]
Local lTmsExp    := TmsExp() .And. Substr(FunName(),1,7) == "TMSA144"  
Local cOcorCan   := SuperGetMv('MV_OCORCAN',,'') //-- Ocorrencia de Cancelamento p/ Viagem de Coleta Planejada em aberto
Local lMVTMSAloc := GetMv("MV_TMSALOC",.F.,.T.)

Local lMVITMSDMD := SuperGetMv("MV_ITMSDMD",.F.,.F.) //Parametro que indica se a Gestão de Demandas está ativa ou não.

If AliasInDic('DL9') .AND. FindFunction('TMSVldMotP') .And. lMVITMSDMD
	lRet := TMSVldMotP('',cViagem, cCodMot, aPlanej) //Código Planejamento/Código Viagem/Código Motorista/Datas planejadas 
Else
	If lMVTMSAloc .And. ( Empty( M->DTR_FILVGE ) .And. Empty( M->DTR_NUMVGE ) )
		cQuery := "SELECT DUP.DUP_FILORI, DUP.DUP_VIAGEM, DUP.DUP_CODMOT, "
		cQuery += "DTR.DTR_DATINI, DTR.DTR_HORINI, DTR.DTR_DATFIM, DTR.DTR_HORFIM,DTR_FILVGE, DTR_NUMVGE "
		cQuery += "FROM " + RetSQLName('DUP') + " DUP, " + RetSQLName('DTR') + " DTR, " + RetSQLName('DTQ') + " DTQ "
		cQuery += "WHERE DUP.DUP_FILIAL = '" + xFilial('DUP') + "' AND "
		cQuery += "DTR.DTR_FILIAL = '" + xFilial('DTR') + "' AND "
		cQuery += "DTQ.DTQ_FILIAL = '" + xFilial('DTQ') + "' AND "
		cQuery += "DUP.DUP_CODMOT = '" + cCodMot + "' AND "
		cQuery += "DUP.DUP_FILORI = DTR.DTR_FILORI AND "
		cQuery += "DUP.DUP_VIAGEM = DTR.DTR_VIAGEM AND "
		cQuery += "DUP.DUP_FILORI = DTQ.DTQ_FILORI AND "
		cQuery += "DUP.DUP_VIAGEM = DTQ.DTQ_VIAGEM AND "
		cQuery += "DTQ.DTQ_STATUS <> '3' AND "
		cQuery += "DTQ.DTQ_STATUS <> '9' AND "
		If lTmsExp .And. !Empty( cOcorCan ) 
			cQuery += "DTQ.DTQ_TIPVIA <> '3' AND "
			cQuery += "DTQ.DTQ_SERTMS <> '1' AND "
		EndIf
		cQuery += "DUP.D_E_L_E_T_ = '' AND DTR.D_E_L_E_T_ = '' AND DTQ.D_E_L_E_T_ = '' AND "
		cQuery += "NOT EXISTS (SELECT DF7_FILORI,DF7_VIAGEM "
		cQuery += "FROM " + RetSQLName('DF7') + " DF7 "
		cQuery += "WHERE DF7.DF7_FILIAL = '" + xFilial('DF7') + "' AND "
		cQuery += "((DF7.DF7_FILORI = DUP.DUP_FILORI AND DF7.DF7_VIAGEM = DUP.DUP_VIAGEM) OR "
		cQuery += "(DF7.DF7_FILDTR = DUP.DUP_FILORI AND DF7.DF7_VGEDTR = DUP.DUP_VIAGEM)) AND "
		cQuery += "DF7.D_E_L_E_T_  = '') "
		
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
		
		While !(cAliasQry)->(EoF()) .And. Empty(cNumVge)
			If ( ((cAliasQry)->(DUP_FILORI+DUP_VIAGEM) <> cFilOri + cViagem) .AND. ((cAliasQry)->(DTR_FILVGE+DTR_NUMVGE) <> cFilOri + cViagem) )	    
				If cPeriodIni >= (cAliasQry)->(DTR_DATINI + DTR_HORINI) .And. cPeriodIni <= (cAliasQry)->(DTR_DATFIM + DTR_HORFIM)
					lRet := .F.
					cNumVge := (cAliasQry)->(DUP_FILORI + '/' + DUP_VIAGEM)
					
				ElseIf 	cPeriodFim >= (cAliasQry)->(DTR_DATINI + DTR_HORINI) .And. cPeriodFim <= (cAliasQry)->(DTR_DATFIM + DTR_HORFIM)
					lRet := .F.
					cNumVge := (cAliasQry)->(DUP_FILORI + '/' + DUP_VIAGEM)
					
				ElseIf (cAliasQry)->(DTR_DATINI + DTR_HORINI) >= cPeriodIni .And. (cAliasQry)->(DTR_DATINI + DTR_HORINI) <= cPeriodFim
					lRet := .F.
					cNumVge := (cAliasQry)->(DUP_FILORI + '/' + DUP_VIAGEM)
					
				ElseIf (cAliasQry)->(DTR_DATFIM + DTR_HORFIM) >= cPeriodIni .And. (cAliasQry)->(DTR_DATFIM + DTR_HORFIM) <= cPeriodFim
					lRet := .F.
					cNumVge := (cAliasQry)->(DUP_FILORI + '/' + DUP_VIAGEM)
					
				EndIf
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
		
		If !lRet
			Help(" ",1,"TMSXFUNB16",, STR0010 + cCodMot + ' - ' + STR0007 + cNumVge, 3, 00) // O Motorista informado esta sendo utilizado na viagem :
		EndIf
	EndIf
EndIf

RestArea( aAreaDTR )
Return(lRet)

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

Private aRotina	:= {	{STR0002 ,"AxPesqui"   ,0, 1,0,.F.},;  //"Pesquisar"
{STR0003 ,"TMSA240Mnt" ,0, 2,0,NIL},;  //"Visualizar"
{STR0004 ,"TMSA240Mnt" ,0, 3,0,NIL},;  //"Incluir"
{STR0005 ,"TMSA240Mnt" ,0, 4,0,NIL},;  //"Alterar"
{STR0006 ,"TMSA240Mnt" ,0, 5,0,NIL} }  //"Excluir"


If ExistBlock("TMA240MNU")
	ExecBlock("TMA240MNU",.F.,.F.)
EndIf

Return(aRotina)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA240Del ³ Autor ³ Rodolfo K. Rosseto ³ Data ³ 09/11/06   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a exclusao das linhas da GetDados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExpN1 - Opcao de chamada da exclusao                       ³±±
±±³			 ³			  (1 - Veiculo, 2 - Motoristas, 3 - Ajudantes)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico - T-permite excluir a linha do aCols, F-nao permite  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA240Del(nOpcao)
Local lRet      	:= .T.
Local lContVei  	:= GetMV('MV_CONTVEI',,.T.)
Local lMV_EmViag    := GetMV("MV_EMVIAG",,.F.)
Local nCount		:= 0
Local lAchou 		:= .F.
Local nLenaMotViag := 0
Local lTercRbq   := DTR->(ColumnPos("DTR_CODRB3")) > 0
Local lMVITMSDMD := SuperGetMv("MV_ITMSDMD",.F.,.F.) //Parametro que indica se a Gestão de Demandas está ativa ou não.
Local aAreaDL9   := {}
Local aAreaDF8   := DF8->(GetArea())

Local lGerador   := SDG->(ColumnPos("DG_GERADOR") > 0)

If AliasInDic("DL9")
	aAreaDL9   := DL9->(GetArea())
EndIf

If( Len(aMotViag) > 0 ) .And. (Len(aMotViag) >= n)
	nLenaMotViag := Len(aMotViag[n][2])
EndIf

// CHECAR SE O VEICULO ESTIVER SENDO EXCLUIDO ==> EXCLUIR SEU RESPECTIVO MOTORISTA
If (Len(aCols) > 0) .And. (nOpcao == 1)
	// MARCAR O STATUS DO VEICULO AOS MOTORISTAS VINCULADOS AO MESMO
	// QUANDO EXCLUIR O VEICULO, O(S) MOTORISTA(S) SERA PASSADO PARA EXCLUIDO TAMBEM.
	For nCount := 1 to nLenaMotViag
		aMotViag[n][2][nCount][ len(aMotViag[n][2][nCount]) ] := aCols[n, Len(aCols[n]) ]
		lRet := .T.
	Next			
EndIf

If lTrocaMot .And. (nOpcao == 2)
	If( Len(aMotViag) > 0 )
		nLenaMotViag := Len(aMotViag[1][2])
	EndIf
	For nCount := 1 to nLenaMotViag
			If aMotViag[1][2][nCount][1] = aCols[n, 1]
			   lAchou := .T.
			EndIf
	Next	
	If lAchou 
	   lRet := .F.
	EndIf
EndIf

If lRet .AND. lMVITMSDMD .AND. DF8->(ColumnPos("DF8_PLNDMD")) > 0  //SUAVIZAÇÃO DEMANDAS
	If nOpcao == 2 .AND. !GDDeleted(n) .AND. !Empty(aCols[n,GdFieldPos('DUP_CODMOT')])
		DF8->(DbSetOrder(2))
		If DF8->(MsSeek( xFilial('DF8') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))
			DL9->(DbSetOrder(1))
			If DL9->(MsSeek( xFilial('DL9') + DF8->DF8_PLNDMD))
				If aCols[n,GdFieldPos('DUP_CODMOT')] ==  DL9->DL9_CODMOT    
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
If Len(aCols) > 0 .And. lRet
	If (lContVei .Or. lMV_EmViag) .And. nOpcao == 1 //-- Veiculos e Reboques

		//-- Verifica se existe SDG criado por outras rotinas
		If lGerador .And. ExisteSDG(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,aCols[n,GdFieldPos("DTR_CODVEI")],"TMSA240","2")
			Help(" ",1,"TMSA240A8")	//-- Existe SDG gerado por outra rotina. O Estorno não será permitido.
			lRet := .F.
		Else
			If !Empty(aCols[n,GdFieldPos('DTR_CODVEI')]) //-- Veiculo
				If !GDDeleted(n) //--Se nao estiver deletado
					If !LockByName("VGEVEI" + aCols[n,GdFieldPos('DTR_CODVEI')],.T.,.F.)
						Help( ' ', 1, 'TMSA24050', , STR0009 + aCols[n,GdFieldPos('DTR_CODVEI')] ,3 ,0) //"O Veiculo esta sendo utilizado por outra viagem." ### "Veiculo: "
						lRet := .F.
					EndIf
				Else //--Se estiver deletado
					UnLockByName("VGEVEI" + aCols[n,GdFieldPos('DTR_CODVEI')] ,.T.,.F.)
				EndIf
			EndIf
			If !Empty(aCols[n,GdFieldPos('DTR_CODRB1')]) //-- 1o. Reboque
				If !GDDeleted(n) //--Se nao estiver deletado
					If !LockByName("VGERB1" + aCols[n,GdFieldPos('DTR_CODRB1')],.T.,.F.)
						Help( ' ', 1, 'TMSA24050', , STR0009 + aCols[n,GdFieldPos('DTR_CODRB1')] ,3 ,0) //"O Veiculo esta sendo utilizado por outra viagem." ### "Veiculo: "
						lRet := .F.
					EndIf
				Else //--Se estiver deletado
					UnLockByName("VGERB1" + aCols[n,GdFieldPos('DTR_CODRB1')] ,.T.,.F.)
				EndIf
			EndIf
			If !Empty(aCols[n,GdFieldPos('DTR_CODRB2')]) //-- 2o. Reboque
				If !GDDeleted(n) //--Se nao estiver deletado
					If !LockByName("VGERB2" + aCols[n,GdFieldPos('DTR_CODRB2')],.T.,.F.)
						Help( ' ', 1, 'TMSA24050', , STR0009 + aCols[n,GdFieldPos('DTR_CODRB2')],3 ,0) //"O Veiculo esta sendo utilizado por outra viagem." ### "Veiculo: "
						lRet := .F.
					EndIf
				Else //--Se estiver deletado
					UnLockByName("VGERB2" + aCols[n,GdFieldPos('DTR_CODRB2')] ,.T.,.F.)
				EndIf
			EndIf
			If lTercRbq .And. !Empty(aCols[n,GdFieldPos('DTR_CODRB3')]) //-- 3o. Reboque
				If !GDDeleted(n) //--Se nao estiver deletado
					If !LockByName("VGERB3" + aCols[n,GdFieldPos('DTR_CODRB3')],.T.,.F.)
						Help( ' ', 1, 'TMSA24050', , STR0009 + aCols[n,GdFieldPos('DTR_CODRB3')],3 ,0) //"O Veiculo esta sendo utilizado por outra viagem." ### "Veiculo: "
						lRet := .F.
					EndIf
				Else //--Se estiver deletado
					UnLockByName("VGERB3" + aCols[n,GdFieldPos('DTR_CODRB3')] ,.T.,.F.)
				EndIf
			EndIf
		EndIf
	ElseIf (lContVei .Or. lMV_EmViag) .And. nOpcao == 2 //--Motoristas
		If !Empty(aCols[n,GdFieldPos('DUP_CODMOT')])
			If !GDDeleted(n) //--Se nao estiver deletado
				If !LockByName("VGEMOT" + aCols[n,GdFieldPos('DUP_CODMOT')],.T.,.F.)
					Help( ' ', 1, 'TMSA24049', , STR0010 + aCols[n,GdFieldPos('DUP_CODMOT')] ,3 ,0) //"O Motorista esta sendo utilizado por outra viagem." ### "Motorista: "
					lRet := .F.
				EndIf
			Else //--Se estiver deletado
				UnLockByName("VGEMOT" + aCols[n,GdFieldPos('DUP_CODMOT')],.T.,.F.)
			EndIf
		EndIf
	ElseIf nOpcao == 3 //--Ajudantes
		If !Empty(aCols[n,GdFieldPos('DUQ_CODAJU')])
			If !GDDeleted(n) //--Se nao estiver deletado
				If !LockByName("VGEAJU" + aCols[n,GdFieldPos('DUQ_CODAJU')],.T.,.F.)
					Help( ' ', 1, 'TMSA24048', , STR0060 + aCols[n,GdFieldPos('DUQ_CODAJU')] ,3 ,0) //"O Ajudante esta sendo utilizado por outra viagem." ### "Ajudante: "
					lRet := .F.
				EndIf
			Else //--Se estiver deletado
				UnLockByName("VGEAJU" + aCols[n,GdFieldPos('DUQ_CODAJU')],.T.,.F.)
			EndIf
		EndIf
	EndIf
EndIf

If !Empty(aAreaDL9)
	RestArea( aAreaDL9 )
EndIf

RestArea( aAreaDF8 )
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA240RetRbq³ Autor ³ Vitor Raspa       ³ Data ³ 26.Dez.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Lancamento do retorno de reboque                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExpN1 - Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSA240RetRbq(nOpcx, cFilOri, cViagem)
Local aArea      := GetArea()
Local aAreaDUT   := DUT->(GetArea())
Local aAreaDA3   := DA3->(GetArea())
Local aAreaDF7   := DF7->(GetArea())
Local nOpcao     := nOpcx
Local lRet       := .T.
Local aColsDTR   := {}
Local aHeaderDTR := aClone(aHeader)
Local cCadOld    := cCadastro

cCadastro := STR0061 //-- Retorno de Reboque

//-- Verifica a Categoria do Veiculo
DA3->(DbSetOrder(1))
If DA3->(MsSeek(xFilial('DA3') + GDFieldGet('DTR_CODVEI')))
	DUT->(dbSetOrder(1))
	If !DUT->(MsSeek(xFilial('DUT')+DA3->DA3_TIPVEI))
		Help('',1,'TMSA24011') //-- Nao foi encontrado Categoria de Veiculo para este Tipo de Veiculo
		lRet := .F.
	Else
		If DUT->DUT_CATVEI <> '2'
			Help('',1,'TMSA24010')	//--Os veiculos do reboque deverao ser de categoria igual "3" (Carreta).
			lRet := .F.
		EndIf
	EndIf
EndIf

//-- Acessa a tela para o lancamento do retorno de reboque
If lRet
	If nOpcao <> 3
		DF7->(DbSetOrder(3))
		If DF7->(DbSeek(xFilial('DF7') + DTQ->(DTQ_FILORI+DTQ_VIAGEM)))
			If nOpcao == 2 .And. DF7->DF7_CODVEI <> GDFieldGet('DTR_CODVEI')
				Help('',1,'TMSA24051') //-- 'O retorno de reboque nao esta amarrado a este veiculo.'
				lRet := .F.
			EndIf
		Else
			If nOpcao == 4
				nOpcao := 3
			Else
				Help('',1,'TMSA24052') //-- 'Nao existe retorno de reboque amarrado a esta viagem!'
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

If lRet
	aColsDTR := {}
	AAdd( aColsDTR, aCols[n] )
	TMSAF15Mnt('DF7', If(nOpcao <> 3, DF7->(RecNo()), NIL), nOpcao,, .T., aHeaderDTR, aColsDTR)
EndIf

RestArea( aArea )
RestArea( aAreaDUT )
RestArea( aAreaDA3 )
RestArea( aAreaDF7 )

cCadastro := cCadOld
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA240BlqºAutor  ³Raphael Zampieri    º Data ³ 17/06/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ FUNCAO RESPONSAVEL POR BLOQUEAR VEICULO CASO EXISTA O.S.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA240Blq(cCodVei)
Local lMntTms := (GetMV('MV_NGMNTMS',,'N') == 'S') //Ativa integracao TMS X MNT
Local lRet    := .T.
Local cCodBem := ''

If lMntTms 

	cCodBem := Posicione("DA3",1,xFilial("DA3")+cCodVei,"DA3_CODBEM")

	cAliasNew := GetNextAlias()

	cQuery := " SELECT COUNT(TJ_TIPO) NQTDE FROM " + RetSqlName("STJ") + " STJ "
	cQuery += " INNER JOIN " + RetSqlName("STE") + " STE ON "
	cQuery += " STE.TE_FILIAL = '" + xFilial("STE") + "' AND "
	cQuery += " STE.TE_TIPOMAN = STJ.TJ_TIPO "
	cQuery += " WHERE STJ.TJ_FILIAL = '" + xFilial("STJ") + "' AND "
	cQuery += " STJ.TJ_CODBEM = '" + PADR(cCodBem,Len(STJ->TJ_CODBEM)) + "' AND "
	cQuery += " STJ.TJ_SITUACA = 'P' AND "
	cQuery += " STE.TE_CARACTE = 'C' AND "
	cQuery += " STJ.D_E_L_E_T_ = ' ' AND "
	cQuery += " STE.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)

	cAliasNew := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
	
	If (cAliasNew)->NQTDE > 0
		If !IsInCallStack('TMSA153')
			Help(' ', 1, 'TMSA24058')  //-- Existe ordem de serviço para o veículo informado, utilize outro veículo.
		EndIf
		lRet := .F.		
	EndIf
	
	( cAliasNew )->( dbCloseArea() )			
EndIf	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMS240VlAb ³ Autor ³ Katia              ³ Data ³ 10.Out.11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Abertura do Contrato								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo da Operadora                                 ³±±
±±³          ³ExpC2 - Id. Informado                                       ³±±
±±³          ³ExpC3 - Tipo Motorista                                      ³±±
±±³          ³ExpC4 - Codigo do Veiculo                                   ³±±
±±³          ³ExpC5 - Codigo do Motorista                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMS240VlAb(cCodOpe, cIdOpe,  cTipMot, cCodVei, cCodMot, cCodReb, nValFre, nValAdi, cTipCarga)
Local aArea		:= GetArea()
Local lRet 		:= .T.                                
Local cTipVia     := ''

Default cCodReb   := ''  
Default nValFre   := 0
Default nValAdi   := 0  
Default cTipCarga := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ POSICIONA NO CADASTRO DA OPERADORA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEG->( DbSetOrder(1) )
DEG->( MsSeek(xFilial('DEG') + cCodOpe) )

If Empty(cRota)
	If Upper(AllTrim(FunName())) == "TMSA240" 
		cRota:= DTQ->DTQ_ROTA
	Else
		cRota:= M->DTQ_ROTA
	EndIf
EndIf	
If cCodOpe == '01' //--REPOM
	If Upper(AllTrim(FunName())) == "TMSA240" 
		cTipVia:= DTQ->DTQ_TIPVIA
	Else
		cTipVia:= M->DTQ_TIPVIA
	EndIf
	//-- Código movido para TMSRepom.prw
	lRet := RepVldAber(@cCodOpe, @cIdOpe,  @cTipMot, @cCodVei, @cCodMot, @cCodReb, @nValFre, @nValAdi, @cTipCarga)
EndIf

RestArea( aArea )
Return( lRet )  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TM240CardºAutor  ³Leandro Paulino     º Data ³ 26/12/2013   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³ Consulta F3( DDQDEL ) para obter os Cartoes atraves da     ³±±
±±³          ³ da tabela DEL e DDQ                                        ³±± 		
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TM240Card()

Local aArea     := {}
Local aAreaDUP  := {}
Local aAreaDA3  := {}
Local aAreaDA4  := {}
Local cAliasQry := ''
Local cQuery    := ''
Local aCodFav	:= {}
Local aFornec   := {}
Local nCount    := 0  
Local nZ		:= 0
Local aCartoes  := {}   
Local aTitulo	:= {}
Local aRet		:= {}
Local nPosVei   := 0
Local nPosID    := 0
Local cRecebedor:='2'
Local cCodMot	:= ""
Local cCampo	:= ReadVar()
Local cCodReceb := ""
Local cCodVei	:= ""
Local cCondut	:= ""
Local cCodOpe	:= ""
Local lRet 		:= .T.
Local cFilVgeDTR:= ""
Local cVgeDTR   := ""
Local lVgeMod3  := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)

If lVgeMod3 
	TM64PCard()
Else
	aArea     := GetArea()
	aAreaDUP  := DUP->(GetArea())
	aAreaDA3  := DA3->(GetArea())
	aAreaDA4  := DA4->(GetArea())

	If cCampo $ 'M->DLD_IDOPE,CCARD'
		If cCampo == "M->DLD_IDOPE"
			cCodReceb := GDFieldGet('DLD_RECEB',n)
			cCodVei := GDFieldGet('DLD_CODVEI',n)
			cCodOpe	:= M->DTR_CODOPE
			If Empty(cCodReceb)
				lRet := .F.
				Help( ' ', 1, 'TMSA240A3', , ,5 ,11) //-- Recebedor da parcela não informado
			EndIf
		Else
			cCodReceb 	:= cReceb
			cCodVei 	:= cCodVeic
			cCodMot 	:= cCodMoto
			cCondut		:= cCondutor
			cCodOpe		:= DTR->DTR_CODOPE
			cFilVgeDTR  := DTR->DTR_FILORI
			cVgeDTR     := DTR->DTR_VIAGEM
		EndIf
		If lRet
			If cCodReceb = '1'  //Proprietário
				cRecebedor:='1'	
					
				dbSelectArea("DA3")
				DA3->(dbSetOrder(1)) 
				If MsSeek(xFilial("DA3")+cCodVei) .And. !Empty(DA3->DA3_CODFOR)
					aCodFav := T250BscFav(DA3->DA3_COD,DA3->DA3_CODFOR,DA3->DA3_LOJFOR,cFilVgeDTR,cVgeDTR)
					If Len(aCodFav) > 0
						aAdd(aFornec, {aCodFav[1][1], aCodFav[1][2] })
					Else
						aAdd(aFornec, {DA3->DA3_CODFOR, DA3->DA3_LOJFOR })
					EndIf
				Endif
				
			ElseIf cCodReceb = '2' //Motorista
				cRecebedor:='2'

				If cCampo == "CCARD"
					dbSelectArea("DA4")
					dbSetOrder(1)
					If cCondut == "1"			
						If MsSeek(xFilial("DA4")+cCodMot) .And. !Empty(DA4->DA4_FORNEC)
							aAdd(aFornec, {DA4->DA4_FORNEC, DA4->DA4_LOJA })
						Endif
					EndIf
				Else
					nZ := aScan(aMotViag,{|x| x[1] == GDFieldGet('DLD_ITEDTR',n)}) 
					
					If nZ > 0
						dbSelectArea("DA4")
						dbSetOrder(1)
						For nCount := 1 To Len(aMotViag[nZ][2])
							If !aMotViag[nZ][2][nCount][Len(aMotViag[nZ][2][nCount])] //-- Verifica se a linha esta deletada
								cCodMot := aMotViag[nZ][2][nCount][1]
								cCondut := aMotViag[nZ][2][nCount][Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_CONDUT" })]
								
								If cCondut == "1"			
									If MsSeek(xFilial("DA4")+cCodMot) .And. !Empty(DA4->DA4_FORNEC)
										aAdd(aFornec, {DA4->DA4_FORNEC, DA4->DA4_LOJA })
									Endif
								EndIf
							EndIf
						Next nCount
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		cRecebedor:='2'
		cCodOpe	  := M->DTR_CODOPE
		If cCampo == "CCARD"
			aAdd(aFornec, {DTR->DTR_CODFOR, DTR->DTR_LOJFOR})
		Else
			nPosVei := Ascan(aSavHeader,{|x| AllTrim(x[2]) == "DTR_CODVEI" })  
			cCodMot := GDFieldGet('DUP_CODMOT',n)
			
			dbSelectArea("DA3")
			DA3->(dbSetOrder(1))       
			For nCount := 1 To Len(aSavCols)                                                                                             
				If MsSeek(xFilial("DA3")+aSavCols[nCount,nPosVei]) .And. !Empty(DA3->DA3_CODFOR)
					aAdd(aFornec, {DA3->DA3_CODFOR, DA3->DA3_LOJFOR })
				EndIf
			Next
		EndIf
	EndIf

	If lRet
		If Len(aFornec) > 0
			cAliasQry := GetNextAlias()
			cQuery := "SELECT DDQ.DDQ_IDCART, DDQ.DDQ_STATUS"
			cQuery += "	FROM " + RetSqlName("DDQ") + " DDQ "
			cQuery += "		WHERE "
			cQuery += "			DDQ.DDQ_FILIAL = '" + xFilial("DDQ") + "' AND "
			For nCount := 1 To Len(aFornec)
				If nCount > 1
					cQuery += " OR "
				EndIf
				cQuery += "		(DDQ.DDQ_CODFOR = '" + aFornec[nCount,1] + "' AND "
				cQuery += "		DDQ.DDQ_LOJFOR = '" + aFornec[nCount,2] +  "'	  ) "			
			Next
			cQuery += " 		AND DDQ.DDQ_STATUS IN ('1', '2') " 
			cQuery += " 	 	AND DDQ.D_E_L_E_T_ = ''"
				
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				
			While !(cAliasQry)->(EoF())	
				nPosID:= Ascan(aCartoes,{|x| AllTrim(x[3]) == Alltrim((cAliasQry)->DDQ_IDCART)})
				If nPosID = 0
					AAdd(aCartoes, {'02','POWERED BY PAMCARD',(cAliasQry)->DDQ_IDCART, (cAliasQry)->DDQ_STATUS,BSCXBOX('DEL_STATUS',(cAliasQry)->DDQ_STATUS),'','' })
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
		EndIf
			
		If cRecebedor == '2'
			
			cAliasQry := GetNextAlias()
			cQuery := "SELECT DEL.DEL_CODMOT, DEL.DEL_IDOPE, DEL.DEL_STATUS, DEL_TIPOID, DEL_CODOPE"
			cQuery += "	FROM " + RetSqlName("DEL") + " DEL "
			cQuery += "		WHERE "
			cQuery += "			DEL.DEL_FILIAL = '" + xFilial("DEL") + "' AND "
			cQuery += "			DEL.DEL_CODMOT = '" + cCodMot + "' AND "
			cQuery += "			DEL.DEL_CODOPE = '" + cCodOpe + "'"
			If cCodOpe != "01"
				cQuery += "		AND DEL.DEL_STATUS IN ('1', '2') "
			EndIf 
			cQuery += "			AND  DEL.D_E_L_E_T_ = ''"
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

			AAdd( aRet, {'01', 'REPOM TECNOLOGIA'   })
			AAdd( aRet, {'02', 'POWERED BY PAMCARD' })                                                                        

			While !(cAliasQry)->(EoF())	             
				nPos  := Ascan(aRet,{|x| AllTrim(x[1]) == (cAliasQry)->DEL_CODOPE})
				nPosID:= Ascan(aCartoes,{|x| AllTrim(x[3]) == Alltrim((cAliasQry)->DEL_IDOPE)})
				If nPosID = 0
					AAdd(aCartoes, {(cAliasQry)->DEL_CODOPE,aRet[nPos,2],(cAliasQry)->DEL_IDOPE, ;
						(cAliasQry)->DEL_STATUS,BSCXBOX('DEL_STATUS',(cAliasQry)->DEL_STATUS),(cAliasQry)->DEL_TIPOID,Tabela('ME', (cAliasQry)->DEL_TIPOID, .F.) })
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo		
		EndIf

		If Len(aCartoes) > 0        
			Aadd( aTitulo, RetTitle('DEL_CODOPE') )
			Aadd( aTitulo, RetTitle('DEL_NOMOPE') )
			Aadd( aTitulo, STR0069 ) //--'Numero Cartão'
			Aadd( aTitulo, RetTitle('DEL_STATUS') )
			Aadd( aTitulo, STR0070) //--'Desc. Status '
			Aadd( aTitulo, RetTitle('DEL_TIPOID'))
			Aadd( aTitulo, STR0071) //--'Desc. Tp. Id'
			
			nItem := TmsF3Array( aTitulo, aCartoes, STR0068, .T. ) //--'Cartoes Operadoras de Frota'
			
			If	nItem > 0
				If cCampo == "CCARD"
					&(cCampo) := aCartoes[ nItem, 3 ]
				Else
					//-- VAR_IXB eh utilizada como retorno da consulta F3
					VAR_IXB := aCartoes[ nItem, 3 ]
				EndIf
			EndIf                   
			(cAliasQry)->(DbCloseArea())
		Else
			Help( ' ', 1, 'TMSA24072', , ,5 ,11) //-- Não existe cartão para o motorista nem cartão para o proprietário do veículo
			VAR_IXB := Space(TamSX3('DUP_IDOPE')[1])
		EndIf
	Else
		VAR_IXB := Space(TamSX3('DUP_IDOPE')[1])
	EndIf

	RestArea(aAreaDA3)
	RestArea(aAreaDA4)
	RestArea(aArea)
	RestArea(aAreaDUP)
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TT240VeiVinºAutor  ³Leandro Paulino     º Data ³ 04/12/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao resposavel para retornar o veiculo que podera ser   º±±
±±º          ³ utilizado no vinculo do carregamento grafico               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function T240VeiVin()

Local cRet := Space(Len(DTR->DTR_CODVEI))
	//Se só existir um veículo (Truck) este será utilizado
	//Se existir O conjunto cavalo + carreta a carreta será utilizada para o vínculo
	//Se exitir o conjunto cavalor + carreta1+ carreta 2 o usuário deverá informar uma das duas carretas para vínculo...
If Type('M->DTR_CODRB2') == 'C' .And. !Empty(M->DTR_CODRB2)
	cRet := Space(Len(DTR->DTR_CODRB2))
ElseIf Type('M->DTR_CODRB1') == 'C' .And. !Empty(M->DTR_CODRB1)
	cRet := M->DTR_CODRB1
ElseIf	Type('M->DTR_CODVEI') == 'C' .And. !Empty(M->DTR_CODVEI)
	cRet := M->DTR_CODVEI	
EndIf	

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TA240SegurºAutor  ³Katia               º Data ³  22/09/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Manutencao de Controle de Liberacao de Seguro              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.    ³ ExpN1 -> Opcao selecionada                                 º±±
±±º          ³ ExpC1 -> Filial da Viagem                                  º±±
±±º          ³ ExpC2 -> Viagem                                            º±±
±±º          ³ ExpC3 -> Alias  (DA3=Veiculo;DA4=Motorista)                º±±
±±º          ³ ExpC4 -> Chave  (Filial+Motorista;Filial+Veiculo)          º±±
±±º          ³ ExpC5 -> Chave  (Filial+Reboque1)  				           º±±
±±º          ³ ExpC6 -> Chave  (Filial+Reboque3)  				           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ .T.                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TA240Segur(nOpcx, cFilOri, cViagem, cAliasDJA, cChaveDJA, cChaveDJA1, cChaveDJA2, lExibe,cChaveCav)

Local nPosTipo     := 0
Local nAux         := 0
Local nOpc         := 0
Local aLimpCols    := {}
Local aNoFields    := {}
Local aYesFields   := {}
Local nSavN	       := n
Local aSavCols     := aClone(aCols)
Local aSavHeader   := aClone(aHeader)
Local aSavaRotina  := aClone(aRotina)
Local oDlg
Local nX           := 0
Local nSav         := n
Local nItem        := 0
Local nPosCodVei   := 0
Local nPosModVei   := 0
Local nPosCodRB1   := 0
Local nPosModRB1   := 0
Local nPosCodRB2   := 0
Local nPosModRB2   := 0
Local nPosCodMot   := 0
Local nPosNomMot   := 0
Local aArea        := GetArea()
Local cChave       := ""
Local nAuxRbq      := 0
Local cChaveRbq    := ""
Local cFilAlias    := ""
Local nTamDA3      := TamSx3("DA3_FILIAL")[1] + TamSx3("DA3_COD")[1] 
Local nTamDA4      := TamSx3("DA4_FILIAL")[1] + TamSx3("DA4_COD")[1]

Private oGetD1     := Nil

Default cAliasDJA	:= ""
Default cChaveDJA   := ""
Default cChaveDJA1  := ""  
Default cChaveDJA2  := ""
Default lExibe     := .T.
Default cChaveCav   := ""   

If Empty(cFilOri+cViagem) .Or. Empty(cChaveDJA+cChaveDJA1+cChaveDJA2)
	Return .T.
EndIf

SaveInter()

//-- Finaliza as Teclas de Atalhos
TmsKeyOff(aSetKey)

n       := 1
aCols   := {}
aHeader := {}

aRotina[3][4] := 3

RegToMemory( "DJA" , .T. )

AAdd( aNoFields, "DJA_FILIAL" )
AAdd( aNoFields, "DJA_FILORI" )
AAdd( aNoFields, "DJA_VIAGEM" )

If cAliasDJA == 'DA3'
	cFilAlias:= xFilial('DA3')
ElseIf cAliasDJA=='DA4'
	cFilAlias:= xFilial('DA4')
EndIf

If !Empty(cChaveDJA)
	cChaveDJA   := Padr(cFilAlias+cChaveDJA,Len(DJA->DJA_CHAVE))
	cChave		  := cChaveDJA 
EndIf

//----Reboques
If !Empty(cChaveDJA1)
	cChaveDJA1 := Padr(cFilAlias+cChaveDJA1,Len(DJA->DJA_CHAVE))
	cChaveRbq  := cChaveDJA1 
EndIf
	 	
If !Empty(cChaveDJA2)
	cChaveDJA2 := Padr(cFilAlias+cChaveDJA2,Len(DJA->DJA_CHAVE))
	cChaveRbq  := cChaveDJA2 	
EndIf	

If !Empty(cChaveRbq) //Verifica se existe a carreta
	nAuxRbq := aScan( aLibSeg, {|ExpA1| ExpA1[1] == cAliasDJA + cChaveRbq } )   
EndIf
//-----
	
nAux := aScan( aLibSeg, {|ExpA1| ExpA1[1] == cAliasDJA + cChave } )

If nAux <= 0
	TMSFillGetDados( nOpcx, 'DJA', 1,xFilial( 'DJA' ) + cFilOri + cViagem + cAliasDJA + cChave, {|| DJA->DJA_FILIAL + DJA->DJA_FILORI + DJA->DJA_VIAGEM + DJA->DJA_ALIAS + DJA->DJA_CHAVE }, ;
	{ || .T.  }, aNoFields,	aYesFields )
	aHeaderDJA := AClone( aHeader )
Else
	For nX:= 1 To Len(aLibSeg)
		If SubStr(aLibSeg[nX][1] ,1,3) == cAliasDJA     
			If SubStr(aLibSeg[nX][1],4,40) == cChave .Or. SubStr(aLibSeg[nX][1],4,40)  == cChaveDJA1 .Or.;
			 	SubStr(aLibSeg[nX][1],4,40)  == cChaveDJA2
				AAdd(aCols,aLibSeg[nX][2][1])
			EndIf
						
		EndIf	
	Next nX
	
	aHeader := AClone( aHeaderDJA )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso exista dados cadastrados , traze-los 									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cAliasDJA == 'DA3' //Veiculo
	nPosCodVei   := Ascan(aSavHeader, {|x| AllTrim(x[2]) == "DTR_CODVEI" })
	nPosModVei   := Ascan(aSavHeader, {|x| AllTrim(x[2]) == "DTR_MODVEI" })
	nPosCodRB1   := Ascan(aSavHeader, {|x| AllTrim(x[2]) == "DTR_CODRB1" })
	nPosModRB1   := Ascan(aSavHeader, {|x| AllTrim(x[2]) == "DTR_MODRB1" })
	nPosCodRB2   := Ascan(aSavHeader, {|x| AllTrim(x[2]) == "DTR_CODRB2" })
	nPosModRB2   := Ascan(aSavHeader, {|x| AllTrim(x[2]) == "DTR_MODRB2" })
ElseIf cAliasDJA == 'DA4' //Motorista
	nPosCodMot   := Ascan(aSavHeader, {|x| AllTrim(x[2]) == "DUP_CODMOT" })
	nPosNomMot   := Ascan(aSavHeader, {|x| AllTrim(x[2]) == "DUP_NOMMOT" })
EndIf

If Len( aCols ) == 1 .And. (Empty( GDFieldGet( 'DJA_ITEM', 1 ) )  .Or. (cAliasDJA == 'DA4' .And. !lExibe))  //Mudanca de veiculo, atualiza o motorista
	If cAliasDJA == 'DA3'  //Veiculos 
		If !Empty(cChaveDJA) //!Empty(aSavCols[nSav,nPosCodVei]) .Or. !Empty(cChaveDJA) 
			DA3->( DbSetOrder(1) )
			If DA3->( DbSeek( Iif(lExibe,xFilial('DA3')+aSavCols[nSav,nPosCodVei],Padr(cChaveDJA,nTamDA3) ) ) )
				TA240SgVei(@aCols,aHeader,DA3->DA3_COD,DA3->DA3_DESC,.F.)
			EndIf
		EndIf
	ElseIf cAliasDJA == 'DA4'  //Motoristas
		nItem:=Len(aCols)
		GDFieldPut( 'DJA_ALIAS'  , 'DA4', nItem ) ///
		GDFieldPut( 'DJA_ITEM'  , StrZero(nItem,Len(DJA->DJA_ITEM)), nItem )
		
		DA4->( DbSetOrder(1) )
		If DA4->( DbSeek( Iif(!lExibe,Padr(cChaveDJA,nTamDA4),xFilial('DA4')+AllTrim(aSavCols[nSav,nPosCodMot])) ) )     
			GDFieldPut( 'DJA_CHAVE' , DA4->DA4_COD, nItem )
			GDFieldPut( 'DJA_DESCHV', DA4->DA4_NOME, nItem )
			GDFieldPut( 'DJA_LIBSEG', DA4->DA4_LIBSEG, nItem )
			GDFieldPut( 'DJA_DTIVSG', DA4->DA4_DTIVSG, nItem )
			GDFieldPut( 'DJA_DTFVSG', DA4->DA4_DTFVSG, nItem )
		EndIf	
		
		aCols[ nItem, Len( aHeader ) + 1 ] := .F.
	EndIf	
	
ElseIf  nAuxRbq <= 0

 //-- Reboque 1
	If !Empty(cChaveDJA1) //!Empty(aSavCols[nSav,nPosCodRb1]) .Or. !Empty(cChaveDJA1)
		DA3->( DbSetOrder(1) )
		If DA3->( DbSeek( Iif(lExibe,xFilial('DA3')+aSavCols[nSav,nPosCodRb1],Padr(cChaveDJA1,nTamDA3)) ) )  
    	 	TA240SgVei(@aCols,aHeader,DA3->DA3_COD,DA3->DA3_DESC,.T.)
       EndIf	
 	EndIf
                      
	//-- Reboque 2
    If !Empty(cChaveDJA2) //!Empty(aSavCols[nSav,nPosCodRb2]) .Or. !Empty(cChaveDJA2)
      	DA3->( DbSetOrder(1) )
	    If DA3->( DbSeek( Iif(lExibe,xFilial('DA3')+aSavCols[nSav,nPosCodRb2],Padr(cChaveDJA2,nTamDA3)) ) ) 
      		TA240SgVei(@aCols,aHeader,DA3->DA3_COD,DA3->DA3_DESC,.T.)
       	EndIf
	EndIf
EndIf

If lExibe
	DEFINE MSDIALOG oDlg FROM 94 ,104 TO 330,650 TITLE STR0074 Of oMainWnd PIXEL //"Controle Liberação de Seguro"
	oGetD1 := MSGetDados():New(30,2,118,271,IIf(nOpcx == 2 ,2 ,3),"TA240LLinOk('DJA')","TA240SGTOk()","+DJA_ITEM",.F.,,,.F.,Len(aCols))
	@ 6  ,116 SAY '' Of oDlg PIXEL SIZE 26 ,9
	@ 18 ,3   SAY STR0007  Of oDlg PIXEL SIZE 56 ,9  //"Viagem : "
	@ 18 ,36  SAY cFilOri+"/"+cViagem Of oDlg PIXEL SIZE 50 ,9
	
	ACTIVATE MSDIALOG oDlg    ON INIT (oGetD1:Refresh(),EnchoiceBar(oDlg,   {||IIF(oGetD1:TudoOk(),(nOpc:=1,oDlg:End()),(nOpc:=0))},{||oDlg:End()}) )
Else
	nOpc:= 1
EndIf	

If nOpc == 1 .And. nOpcx != 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpando registros deletados                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len( aCols )
		If !aTail(aCols[nX])
			AAdd(aLimpCols,aCols[nX])
		EndIf
	Next nX
	
	aCols   := {}
	aCols   := aClone( aLimpCols )
	
	nPosTipo:= Ascan(aLibSeg,{|x| x[1] == cAliasDJA + cChave })
	
	If nPosTipo > 0  
		If Len(aCols) > 0 
			For nX:= 1 to Len(aCols)                               
				If cAliasDJA == "DA3"
					cChaveCols:= aCols[nX][2] + Padr(xFilial("DA3")+aCols[nX][3],Len(DJA->DJA_CHAVE))
				ElseIf cAliasDJA == "DA4"      
					cChaveCols:= aCols[nX][2] + Padr(xFilial("DA4")+aCols[nX][3],Len(DJA->DJA_CHAVE))
				EndIf        
				
			    //--- Reboque		
   		    	//If !Empty(cChaveRbq)
				nPosTipo:= Ascan(aLibSeg,{|x| x[1] == cChaveCols })    
				If nPosTipo == 0  
					AAdd(aLibSeg,{cChaveCols, { aClone(aCols[nX]) } })
				Else
					If nOpcx == 4
						If nPosTipo > 0
						   aLibSeg[nPosTipo][2][1][5]:= aCols[nX][5]   //Lib.Seguro
						   aLibSeg[nPosTipo][2][1][6]:= aCols[nX][6]   //Data Inicio
						   aLibSeg[nPosTipo][2][1][7]:= aCols[nX][7]   //Data Fim
						EndIf
				 	EndIf
				EndIf	
			Next nX                                                         
		EndIf	
	Else
		AAdd(aLibSeg,{cAliasDJA + cChave, aClone(aCols)})
	EndIf
EndIf

aRotina	:= aClone(aSavaRotina)
aHeader := aClone(aSavHeader)
aCols   := aClone(aSavCols)
n		:= nSavN
RestInter()
//-- Iniciliza as Teclas de Atalhos
TmsKeyOn(aSetKey)
RestArea(aArea)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A240AtuDJA³ Autor ³Katia                  ³ Data ³01/10/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza os Campos do Arq. DJA (Liberacao Seguro)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A240AtuDJA(ExpA1,ExpA2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - aHeader Auxiliar Getdados de Liberacao Seguro      ³±±
±±³          ³ ExpA2 - Array contendo as Liberacoes de Seguro             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A240AtuDJA(aHeaderDJA, aLibSeg)

Local aArea := GetArea()
Local nX       := 0
Local nZ       := 0     
Local cAliasDJA:= ""
Local cChaveDJA:= ""        
Local nY       := 0
Local nDadosLib:= 0             
Local cFilDJA  := ""
Local nTamDA3  := TamSx3("DA3_FILIAL")[1] + TamSx3("DA3_COD")[1]
Local nTamDA4  := TamSx3("DA4_FILIAL")[1] + TamSx3("DA4_COD")[1]

dbSelectArea("DJA")
nDadosLib:= Len(aLibSeg)
If nDadosLib > 0
	DJA->(dbSetOrder(1))
	While DJA->(MsSeek(xFilial('DJA')+DTR->DTR_FILORI+DTR->DTR_VIAGEM))
		RecLock("DJA",.F.)
		DJA->(dbDelete())
		MsUnLock()
		DJA->(dbSkip())
	EndDo
	
	For nX:= 1 To nDadosLib
		cAliasDJA:= SubStr(aLibSeg[nX][1],1,3)
		cChaveDJA:= SubStr(aLibSeg[nX][1],Len(cAliasDJA)+1,Len(DJA->DJA_CHAVE) - Len(cAliasDJA))
		
		For nZ := 1 to Len(aLibSeg[nX][2])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza os dados contidos na GetDados                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !aLibSeg[nX][2][nZ][Len(aLibSeg[nX][2][nZ])] //-- Verifica se a linha esta deletada
				If cAliasDJA == 'DA3'
					cFilDJA  := xFilial("DA3")
				ElseIf cAliasDJA == "DA4"
					cFilDJA  := xFilial("DA4")
				EndIf		  

				RecLock("DJA",.T.)
				For nY := 1 to Len(aHeaderDJA)
					If aHeaderDJA[nY][10] # "V" 
						If !(aHeaderDJA[nY][2] $ ("DJA_CHAVE")) 
							DJA->(FieldPut(FieldPos(Trim(aHeaderDJA[nY][2])),aLibSeg[nX][2][nZ][nY]))
						Else 
							cChaveDJA:= cFilDJA + aLibSeg[nX][2][nZ][nY]
						EndIf	
					EndIf 
				Next nY
				DJA->DJA_FILIAL := xFilial('DJA')
				DJA->DJA_FILORI := DTR->DTR_FILORI
				DJA->DJA_VIAGEM := DTR->DTR_VIAGEM
				DJA->DJA_ALIAS  := cAliasDJA
				DJA->DJA_CHAVE  := Padr(cChaveDJA,Len(DJA->DJA_CHAVE))
				MsUnlock()
				
				
				//-- Grava os dados da liberação do Seguro no Veiculo e Motorista
				If cAliasDJA == "DA3"
					DA3->(dbSetOrder(1))
					If DA3->(MsSeek(Padr(DJA->DJA_CHAVE,nTamDA3) ))
						RecLock("DA3",.F.)
						DA3->DA3_LIBSEG := DJA->DJA_LIBSEG
						DA3->DA3_DTIVSG := DJA->DJA_DTIVSG
						DA3->DA3_DTFVSG := DJA->DJA_DTFVSG
						DA3->(MsUnlock())
					EndIf
				ElseIf cAliasDJA == "DA4"
					DA4->(dbSetOrder(1))
					If DA4->(MsSeek(Padr(DJA->DJA_CHAVE,nTamDA4) ))
						RecLock("DA4",.F.)
						DA4->DA4_LIBSEG:= DJA->DJA_LIBSEG
						DA4->DA4_DTIVSG:= DJA->DJA_DTIVSG
						DA4->DA4_DTFVSG:= DJA->DJA_DTFVSG
						DA4->(MsUnlock())					
					EndIf
				EndIf
			EndIf

		Next
		
	Next	
EndIf

RestArea( aArea )
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA240DJA³ Autor ³Katia                  ³ Data ³01/10/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializador Padrao Tabela DJA                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A240CarDJA(ExpA1,ExpA2,ExpA3,ExpA4,ExpA5                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA240DJA()
Local cRet    := ""
Local nTamDA3 := TamSx3("DA3_FILIAL")[1] + TamSx3("DA3_COD")[1] 
Local nTamDA4 := TamSx3("DA4_FILIAL")[1] + TamSx3("DA4_COD")[1]

If DJA->DJA_ALIAS == 'DA3'
	cRet:= Posicione("DA3",1,Padr(DJA->DJA_CHAVE,nTamDA3),"DA3_DESC")

ElseIf DJA->DJA_ALIAS =='DA4'
	cRet:= Posicione("DA4",1,Padr(DJA->DJA_CHAVE,nTamDA4),"DA4_NOME")
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA240SgVei³ Autor ³Katia                  ³ Data ³01/10/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega Dados da Tabela DJA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A240CarDJA(ExpA1,ExpA2,ExpA3,ExpA4,ExpA5                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A240CarDJA(cAliasDJA, cChaveDJA, aHeaderDJA, cFilOri, cViagem)
Local lRet   := .F.
Local aCols  := {}
Local nCntFor:= 0
Local cCodDJA:= ""

DJA->(dbSetOrder(1))
If DJA->(MsSeek(xFilial("DJA")+cFilOri+cViagem+cAliasDJA+cChaveDJA))
	aCols := {}
	Do While !DJA->(Eof()) .And. DJA->(DJA_FILIAL+DJA_FILORI+DJA_VIAGEM+DJA_ALIAS+DJA->DJA_CHAVE) == xFilial("DJA")+cFilOri+cViagem+cAliasDJA+cChaveDJA
		AAdd(aCols,Array(Len(aHeaderDJA)+1))

		For nCntFor := 1 To Len(aHeaderDJA)
			If	aHeaderDJA[nCntFor,10] != "V"
				If AllTrim(aHeaderDJA[nCntFor,2])  $ ("DJA_CHAVE")
					cCodDJA:= DJA->(FieldGet(FieldPos(aHeaderDJA[nCntFor,2])))
										
					aCols[Len(aCols),nCntFor]:= SubStr(cCodDJA,Len(DJA->DJA_FILIAL)+1,(Len(DJA->DJA_CHAVE) - Len(DJA->DJA_FILIAL)))
				Else
					aCols[Len(aCols),nCntFor]:=DJA->(FieldGet(FieldPos(aHeaderDJA[nCntFor,2])))
				EndIf	
			Else
				aCols[Len(aCols),nCntFor]:=TMSA240DJA()
			EndIf
		Next nCntFor
			
		aCols[Len(aCols),Len(aHeaderDJA)+1]:=.F.
		DJA->(dbSkip())
	EndDo
	nPos := Ascan(aLibSeg, {|x|  x[1] == cAliasDJA + cChaveDJA  })
	If nPos > 0
		AAdd(aLibSeg[nPos][2], aClone(aCols))
	Else
		AAdd(aLibSeg,{ cAliasDJA + cChaveDJA , aClone(aCols)})
	EndIf
	lRet:= .T.
EndIf	
		
Return lRet 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA240SgVei³ Autor ³Katia                  ³ Data ³01/10/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega Dados do Veiculo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TA240SgVei(ExpA1,ExpA2,ExpA3,ExpA4,ExpA5                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TA240SgVei(aCols,aHeader,cCodVei,cModelo,lReboque)
Local nCntFor:= 0
Local aArea  := GetArea()

Default cCodVei := ""
Default cModelo := ""
Default lReboque:= .F.
			
DA3->( DbSetOrder( 1 ) )
If DA3->( MsSeek( xFilial('DA3') + cCodVei, .F. ) )
	If lReboque //Adiciona linha no acols			
		AAdd(aCols,Array(Len(aHeader)+1))
		For nCntFor := 1 To Len(aHeader)
			aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
		Next
	EndIf 		 
				
	nItem:=Len(aCols)
	GDFieldPut( 'DJA_ALIAS'  , 'DA3', nItem ) ///
	GDFieldPut( 'DJA_ITEM'  , StrZero(nItem,Len(DJA->DJA_ITEM)), nItem )
	GDFieldPut( 'DJA_CHAVE' , cCodVei, nItem )
	GDFieldPut( 'DJA_DESCHV', cModelo, nItem )
	GDFieldPut( 'DJA_LIBSEG', DA3->DA3_LIBSEG, nItem )
	GDFieldPut( 'DJA_DTIVSG', DA3->DA3_DTIVSG, nItem )
	GDFieldPut( 'DJA_DTFVSG', DA3->DA3_DTFVSG, nItem )
	aCols[ nItem, Len( aHeader ) + 1 ] := .F.
EndIf
	
RestArea(aArea)
Return       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TA240SGTOkºAutor  ³Katia					º Date ³  06/10/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao Geral da Tela                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TA240SGTOk()

Local lRet := .T.

//-- Analisa se os campos obrigatorios da GetDados foram informados.
lRet := oGetD1:ChkObrigat( n )

//-- Analisa o linha ok.
If lRet
	lRet := TA240LLinOk('DJA')
EndIf


Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TA240AltFtºAutor  ³Marcelo Nunes 		º Date ³  25/05/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se deve atualizar frete a pagar ao alterar veiculoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TA240AltFt(vFrete,lAltRota,lAltTipOpVg)
Local lAltFrete := .F.
 
Default lAltRota    := .F.  
Default lAltTipOpVg := .F.
				
If Empty(GDFieldGet('DTR_VALFRE',n))
	lAltFrete := .T.
Else
	If (GdFieldGet("DTR_VALFRE",n) <> vFrete)
		If ((GdFieldGet("DTR_CODVEI",n) <> M->DTR_CODVEI) .OR.;
			(GdFieldGet("DTR_CODRB1",n) <> M->DTR_CODRB1) .OR.;
			(GdFieldGet("DTR_CODRB2",n) <> M->DTR_CODRB2) .OR.;
			(GdFieldGet("DTR_CODRB3",n) <> M->DTR_CODRB3) .OR.;
			lAltRota )
				If MsgYesNo( STR0077 ,STR0020  ) //O frete a pagar foi recalculado. Deseja assumir o novo valor?"
			    	lAltFrete := .T.
        		EndIf
		ElseIf lAltTipOpVg  //Sempre recalcula
			lAltFrete := .T.
    	EndIf
	EndIf					  					  
EndIf

Return	lAltFrete				

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TA240MNCOLºAutor  ³Marcelo Nunes 		º Date ³  25/05/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe manifesto em aberto para viagem coligadaº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TA240MNCOL(FILVGE,NUMVGE)
Local cQuery    := ""
Local cAliasNew := ""
Local lPossuiMan := .F.

cQuery := "SELECT 1"
cQuery += " FROM " + RetSqlName("DUD") + " DUD, " + RetSqlName("DTX") + " DTX "
cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "'"
cQuery += " AND DUD.DUD_FILORI = '" +FILVGE + "'"
cQuery += " AND DUD.DUD_VIAGEM = '" +NUMVGE + "'"
cQuery += " AND DUD.D_E_L_E_T_ = ''"
cQuery += " AND DTX.DTX_FILIAL = '" + xFilial("DTX") + "'"
cQuery += " AND DTX.DTX_FILMAN = DUD.DUD_FILMAN"
cQuery += " AND DTX.DTX_MANIFE = DUD.DUD_MANIFE"
cQuery += " AND DTX.DTX_SERMAN = DUD.DUD_SERMAN"
cQuery += " AND DTX.D_E_L_E_T_ = ''"
cQuery += " AND DTX.DTX_STATUS <> '" + StrZero(3,Len(DTX->DTX_STATUS)) + "' "

cAliasNew := GetNextAlias()
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)

dbSelectArea( cAliasNew )
(cAliasNew)->( dbGoTop() )

if (cAliasNew)->(!Eof())
  lPossuiMan := .T.
EndIF
(cAliasNew)->(DbCloseArea())	

Return lPossuiMan
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa240VFor - Valida Alteração Do Fornecedor Dos Veículos
@owner  Eduardo Alberti
@author Eduardo Alberti
@since 05/Jan/2017
@param Params
		lAltera = Verifica Se Trata-Se De Alteração Do Campo Ou Exclusão Da Linha
		
@return Booleano
/*/
//---------------------------------------------------------------------------------------------------
Function Tmsa240VFor( lAltera, lHelp )

	Local aArea   := {DA3->(GetArea()),DTR->(GetArea()),SA2->(GetArea()),GetArea()}
	Local lRet    := .t.
	Local cQuery  := ""
	Local cAliasT := GetNextAlias()
	Local cForAnt := ""
	Local cLojAnt := ""
	Local nX      := 0
	
	Default lAltera := .f.
	Default lHelp   := .t.

	//--  Inicializa Controle De Sequence
	Begin Sequence
	
		DbSelectArea("DA3")
		DbSetOrder(1) //-- DA3_FILIAL+DA3_COD
		If MsSeek( FWxFilial("DA3") + GDFieldGet("DTR_CODVEI",n), .f. )
			cForAnt := DA3->DA3_CODFOR  //-- Valor Digitado Atual
			cLojAnt := DA3->DA3_LOJFOR
		EndIf
		
		If !Empty(cForAnt)
			//---- Verifica se existe ocorrencia para o Fornecedor da Viagem 
			cQuery += " SELECT COUNT(*) nTotReg "
			cQuery += " FROM    " + RetSqlName("DUA") + " DUA "
			
			cQuery += " INNER JOIN " + RetSqlName("DT2") + " DT2 "
			cQuery += " 	ON DT2.DT2_FILIAL = '" + xFilial("DT2") + "' "
			cQuery += "    AND DT2.DT2_CODOCO = DUA.DUA_CODOCO  "
			cQuery += "    AND DT2.DT2_TIPOCO IN ('" + StrZero(17, Len(DT2->DT2_TIPOCO)) + "','" + StrZero(18, Len(DT2->DT2_TIPOCO)) + "') "   //Despesa e ou Receita/Despesa
			cQuery += "    AND DT2.D_E_L_E_T_ = ' ' "
			
			cQuery += " WHERE  DUA.DUA_FILIAL  =  '" + FWxFilial("DUA") + "' "
			cQuery += " AND    DUA.DUA_FILORI  =  '" + M->DTR_FILORI    + "' "
			cQuery += " AND    DUA.DUA_VIAGEM  =  '" + M->DTR_VIAGEM    + "' "
			cQuery += " AND    DUA.DUA_CODFOR  =  '" + DA3->DA3_CODFOR    + "' "
			cQuery += " AND    DUA.DUA_LOJFOR  =  '" + DA3->DA3_LOJFOR    + "' "
			cQuery += " AND    DUA.D_E_L_E_T_  =  ' ' "				
			
			cQuery := ChangeQuery(cQuery)
				
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasT,.F.,.T.)
			If (cAliasT)->(!Eof()) .And. (cAliasT)->nTotReg > 0
			
				//-- Na Alteração Não Permite Alterar o Campo Com Fornecedor Relacionado a Menos Que 
				//-- Exista Outro Veículo Com Mesmo Fornecedor ("DTR_CODVEI", "DTR_CODRB1", "DTR_CODRB2", "DTR_CODRB3")
				If lAltera  
					DbSelectArea("DA3")
					DbSetOrder(1) //-- DA3_FILIAL+DA3_COD
					If MsSeek( FWxFilial("DA3") + M->DTR_CODVEI, .f. )
						If DA3->DA3_CODFOR + DA3->DA3_LOJFOR <> cForAnt + cLojAnt
							If lHelp
								FwClearHLP()
								Help('',1,'TMSA24082',,cForAnt + " - " + cLojAnt + Space(1) + Posicione("SA2",1, FWxFilial("SA2") + cForAnt + cLojAnt ,"A2_NOME") ,4,15)  //-- "Para Alterar Este Campo Exclua Os Apontamentos De Ocorrencias Para O Fornecedor: "
							EndIf	
							lRet:= .F.
						EndIf
					EndIf
				ElseIf !lAltera  //-- Exclusão De Linha -> Não Permite Excluir a Linha Caso Existam Fornecedores Relacionado
				    lRet := .F.	
				    //-- Verifica de Mostra Help
				    If lHelp
				    	FwClearHLP()
						Help('',1, 'TMSA24083',,,5,11)  //-- "Para Excluir a Linha, Exclua Os Apontamentos De Ocorrencias (Receita/Despesa) Que Utilizam Fornecedores. "
					EndIf	
				EndIf
			EndIf
		EndIf		
		//-- Finaliza Controle De Sequence
	End Sequence
	
	//-- Fecha Arquivos Temporários
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf	

	//-- Reposiciona Arquivos
	For nX := 1 To Len(aArea)
		RestArea(aArea[nX])
	Next nX

Return lRet
/*
====================================================================================================
/{Protheus.doc} IntegDef
//TODO Chamada da Rotina de Integracao modelo Mensagem Unica
@author tiago.dsantos
@since 26/09/2016
@version 1.000
@param cXml, characters, Xml referente as informações para Integracao EAI
@param nType, numeric, Tipo da Mensagem se é: 0=TRANS_RECEIVE ou 1=TRANS_SEND
@param cTypeMessage, characters, Informa se o Recebimento da Mensagem é do tipo: EAI_MESSAGE_BUSINESS,EAI_MESSAGE_WHOIS,EAI_MESSAGE_RECEIPT ou EAI_MESSAGE_RESPONSE
@type function
/===================================================================================================
*/
Static Function IntegDef(cXml,nType,cTypeMessage,cVersion)
Local  aResult := {}
       aResult := TMSI240ABP(cXml,nType,cTypeMessage,cVersion)    
Return aResult

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  TmsBscSDG
@autor		: Leandro Paulino
@descricao	: Busca todos os SDG de uma determinada viagem que movimentam banco.
@since		: Dez./2016
@review	:

@Argumentos	: cFilOri,cViagem
@Uso		: TMSA240/TMSA310

/*/
//-------------------------------------------------------------------------------------------------
Function A240BscSDG(cFilOri,cViagem,cCodVei,nVlrAdiEx,cTipBsc,nVlrNDF)

Local aDadosSDG	 := {}
Local cQuery	 := ''
Local cAliasSDG	 := GetNextAlias()
Local nSeek		 := 0
Local cParcela   := StrZero(1, Len(SE2->E2_PARCELA))
Local cParc      := StrZero(1, Len(SE2->E2_PARCELA))
Local cTipoDoc   := Padr( "PA", Len( SE5->E5_TIPODOC ) )
Local cPrefixo   := TMA250GerPrf(cFilAnt)
Local cSeek		 := ''
Local lMovBcoChq := .T. //-- Gera movimento bancario sem cheque?    
Local cChaveSDG	 := ''
Local cCodDesCTC := Padr( GetMV("MV_DESCTC"), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de contrato de carreteiro
Local cCodDesPDG := Padr( GetMV("MV_DESPDG"), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de pedágio
Local cDesABST   := Padr( SuperGetMV('MV_DESABST',,''), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Abastecimento

Default cFilOri	:= ''
Default cViagem := ''
Default cCodVei := ''
Default cTipBsc := '1'
Default nVlrNDF := 0
Default nVlrAdiEx := 0
If cTmsErp == '0'
	SE5->(dbSetOrder(2))
	If SE5->(MsSeek(cSeek:=FwxFilial('SE5')+cTipoDoc+cPrefixo+cViagem))
		Do While !SE5->(Eof()) .And. SE5->(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO) == cSeek
			cParc:=Soma1(SE5->E5_PARCELA)
			SE5->(dbSkip())
		EndDo
	EndIf
	cParcela := cParc
EndIf

//--Busca todas as despesas da viagem que movimentam banco
cQuery := "	SELECT 	SDG.DG_BANCO, 	"
cQuery += "			SDG.DG_AGENCIA,	"
cQuery += "			SDG.DG_NUMCON, 	"
cQuery += "			SDG.DG_NUMCHEQ,	"
cQuery += "			SDG.DG_VALCOB, 	"
cQuery += "			SDG.DG_TITGER, 	"
cQuery += "			SDG.DG_DOC,	 	"
cQuery += "			SDG.DG_CODDES,	"
cQuery += "			SDG.DG_ITEM 	"
cQuery += "	FROM 	" + RetSqlName ("SDG") + " SDG "
If cTmsErp == '1' 
	cQuery += " INNER JOIN " + RetSqlName('DT7') + " DT7 " //--despesas
	cQuery += " ON 			DT7.DT7_CODDES = SDG.DG_CODDES"
	cQuery += " AND			DT7.DT7_FILIAL = '" + FwxFilial('DT7') + "'"
	If cTipBsc == '1' //--Busca informações das despesas que movimentam banco, mesmo que este não seja informado.
		cQuery += " AND  DT7.DT7_MOVBCO = '1'"
		cQuery += " AND  SDG.DG_CODDES NOT IN ('"+cCodDesPDG+"')" 
	ElseIf cTipBsc == '2' //--Busca informações de despesas que não movimentam banco
		cQuery += " AND 		DT7.DT7_MOVBCO = '2'"
	EndIf
	cQuery += " AND 		DT7.D_E_L_E_T_ = ' ' "
EndIf
cQuery += ""
cQuery += " WHERE 	SDG.DG_FILIAL = '" + FwxFilial('SDG') + "'"
cQuery += " 	AND SDG.DG_FILORI = '" + cFilOri + "'"
cQuery += " 	AND SDG.DG_VIAGEM = '" + cViagem + "'"
cQuery += " 	AND SDG.DG_CODVEI = '" + cCodVei + "'"
If !Empty(cDesABST)
	cQuery += " AND SDG.DG_CODDES !='" + cDesABST + "'"  // cDesABST Despesa de Abastecimento não faz parte do Adto de Frete
EndIf
IF cTipBsc == '2'
	cQuery += " 	AND SDG.DG_CODDES NOT IN ('"+cCodDesCTC+"','"+cCodDesPDG+"')" 		
ElseIf cTmsErp <> '1'
	cQuery += "		AND SDG.DG_BANCO  <> ' ' "
EndIf
cQuery += "		AND SDG.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea (.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSDG , .F., .T. )

While (cAliasSDG)->(!Eof()) 
	cChaveSDG := ''
	//-- A Quebra na geracao dos titulos sera' por Dados Bancarios; Motivo: Geracao do SE5
	nSeek := Ascan(aDadosSDG, {|x| x[1]+x[2]+x[3]+x[4] == (cAliasSDG)->(DG_BANCO+DG_AGENCIA+DG_NUMCON+DG_NUMCHEQ) })
	If nSeek == 0
		cChaveSDG := (cAliasSDG)->(DG_DOC+DG_CODDES+DG_ITEM)
		//-- Parcela do Titulo que sera' gerado
		If Empty(aDadosSDG)
			cParc := cParcela
		Else
			cParc := Soma1(cParc)
		EndIf
		AAdd(aDadosSDG, {(cAliasSDG)->DG_BANCO, (cAliasSDG)->DG_AGENCIA, (cAliasSDG)->DG_NUMCON, (cAliasSDG)->DG_NUMCHEQ, (cAliasSDG)->DG_VALCOB, cParc, lMovBcoChq, (cAliasSDG)->DG_TITGER, cChaveSDG})
	Else
		aDadosSDG[nSeek][5] += (cAliasSDG)->DG_VALCOB
	EndIf
	nVlrNDF	+= (cAliasSDG)->DG_VALCOB
	(cAliasSDG)->(dbSkip())
EndDo

(cAliasSDG)->(dbCloseArea())
//+---------------------------------------------------------------------------------------------------------------------------------------
//| Valor Extra de Adiantamento, implementado para gerar o valor
//| do Adiantamento calculado por % sobre o frete provisório.
//| Necessário para o envio ao Datasul na chamado pelo TMSA310.
//| Situação: Contrato do Fornecedor indica que Valor do Adiantamento será enviado ao Datasul na confirmação da viagem.
//|           porem no contrato do fornecedor existe percentual de adiantamento e não foi informado adiantamento pela tela de despesas/adiantamento
//|           Nesta situação não envia adiantamento, já que o valor da provisão e adiantamento sobre esse valor é realizado no fechamento da viagem,
//|           neste momento o adiantamento é integrado, pois deveria ser feito na geração. 
//+---------------------------------------------------------------------------------------------------------------------------------------
If nVlrAdiEx > 0
     AAdd(aDadosSDG, {"" /*DG_BANCO*/,""/*DG_AGENCIA*/,""/*DG_NUMCON*/,""/*DG_NUMCHEQ*/,nVlrAdiEx/*DG_VALCOB*/, cParc, lMovBcoChq,"2"/*DG_TITGER*/,""/*cChaveSDG*/})
EndIf

Return aDadosSDG

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  A240SDGABS
@autor		: 
@descricao	: Busca todos os SDG de uma determinada viagem que movimentam banco. Para TAG de Abastecimento para operadora de frota
@since		: Dez./2016
@review	:

@Argumentos	: cFilOri,cViagem
@Uso		: TMSA240/TMSA310

/*/
//-------------------------------------------------------------------------------------------------
Function A240SDGABS(cFilOri,cViagem,cCodVei)

Local aDadosSDG	 := {}
Local cQuery	 := ''
Local cAliasSDG	 := GetNextAlias()
Local cChaveSDG	 := ''
Local cDesABST   := Padr( SuperGetMV('MV_DESABST',,''), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Abastecimento

Default cFilOri	:= ''
Default cViagem := ''
Default cCodVei := ''

//--Busca todas as despesas da viagem que movimentam banco
cQuery := "	SELECT 	SDG.DG_BANCO, 	"
cQuery += "			SDG.DG_AGENCIA,	"
cQuery += "			SDG.DG_NUMCON, 	"
cQuery += "			SDG.DG_NUMCHEQ,	"
cQuery += "			SDG.DG_VALCOB, 	"
cQuery += "			SDG.DG_TITGER, 	"
cQuery += "			SDG.DG_DOC,	 	"
cQuery += "			SDG.DG_CODDES,	"
cQuery += "			SDG.DG_ITEM 	"
cQuery += "	FROM 	" + RetSqlName ("SDG") + " SDG "

cQuery += " WHERE 	SDG.DG_FILIAL = '" + FwxFilial('SDG') + "'"
cQuery += " 	AND SDG.DG_FILORI = '" + cFilOri + "'"
cQuery += " 	AND SDG.DG_VIAGEM = '" + cViagem + "'"
cQuery += " 	AND SDG.DG_CODVEI = '" + cCodVei + "'"
cQuery += "     AND SDG.DG_CODDES = '" + cDesABST + "'"  // cDesABST Despesa de Abastecimento não faz parte do Adto de Frete
cQuery += "		AND SDG.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea (.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSDG , .F., .T. )

While (cAliasSDG)->(!Eof()) 

	cChaveSDG := ''
	cChaveSDG := (cAliasSDG)->(DG_DOC+DG_CODDES+DG_ITEM)

	AAdd(aDadosSDG, {(cAliasSDG)->DG_BANCO, (cAliasSDG)->DG_AGENCIA, (cAliasSDG)->DG_NUMCON, (cAliasSDG)->DG_NUMCHEQ, (cAliasSDG)->DG_VALCOB, (cAliasSDG)->DG_TITGER, cChaveSDG})

	(cAliasSDG)->(dbSkip())
EndDo

(cAliasSDG)->(dbCloseArea())

Return aDadosSDG

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  A240GerAdt
@autor		: Leandro Paulino
@descricao	: Gera títulos de adiantamento (PA/NDF) no Financeiro Protheus/Datasul
@since		: Dez./2016
@review	:

@Argumentos	: cFilOri,cViagem,aDadosBco,cCodOpe
@Uso		: TMSA240/TMSA310

/*/
//-------------------------------------------------------------------------------------------------

Function A240GerAdt(cFilOri,cViagem,cCodVei,aDadosBco,cCodOpe,cCodForn,cLojForn,cHistory,cHistory2,cOrigemTit, lPaMovBco, nValorPdg,nValFrete, lSeparaMsg, aSDGPDG, aRecDTR)		

Local nCntFor 		:= 0
Local nTotAdiPA 	:= 0
Local cParcela  	:= ''
Local lTM240BCO   	:= ExistBlock('TM240BCO'  ) 
Local lMovBcoChq	:= .T.
Local lRet			:= .T.
Local cPrefixo   	:= TMA250GerPrf(cFilAnt)
Local cTipAdtoPA 	:= Padr( "PA", Len( SE2->E2_TIPO ) )    // Gera Titulo de Adiantamento do Tipo "PA"
Local cTipAbstVL 	:= Padr( "VL", Len( SE2->E2_TIPO ) )    // Gera Titulo de Abastecimento Tipo Vale
Local lDTRAbast     := DTR->(ColumnPos("DTR_VLABST")) > 0
Local cNatuDeb   	:= Padr( GetMV("MV_NATDEB"), Len( SE2->E2_NATUREZ ) ) // Natureza Utilizada nos Titulos Gerados
Local lMsBlQl		:= .F.
Local aAreaSDG		:= SDG->(GetArea())
Local aAreaDA3		:= DA3->(GetArea())
Local aAreaDTR		:= DTR->(GetArea())
Local cCnpjForn		:= ''
Local cSubType		:= IIF(IsInCallStack('TMSA310GRV'),'102','101')
Local cAdaptRot     := "TMSA240"
Local lTM250Par  	:= ExistBlock('TM250PAR')
Local nQtdPdg		:= 0
Local nVlrPdgBKP	:= 0
Local nVlrFrtBKP	:= 0
Local nCntDTR		:= 0
Local aCabSDG		:= {} 
Local aDadosDEG     := {}
Local aSDGABS       := {}
Local nQtdABS		:= 0
Local nQtdSDG       := 0
Private oDTClass    := NIL

Default cFilOri		:= ''
Default cViagem		:= ''
Default cCodVei		:= ''
Default aDadosBco 	:= {}
Default cCodOpe		:= ''
Default cCodForn	:= ''
Default cLojForn	:= ''
Default cHistory	:= ''
Default cHistory2	:= ''
Default cOrigemTit	:= "TMSA240"
Default lPaMovBco	:= .T.
Default nValorPdg	:= 0
Default nValFrete   := 0
Default lSeparaMsg	:= .F. //--Indica se será gerado uma mensagem para o fornecedor do adiantamento e uma mensagem para o fornecedor do pedágio (só ocorrerá quando os fornecedores forem diferentes. )
Default aSDGPDG		:= {} //NUmeros das despesas criadas para o(s) pedágio(s) da viagem.
Default aRECDTR		:= {} //Recnos dos DTRS que devem ser atualizados.

//| verifica se a função de integração está compilada.
If Len(getSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0
	oDTClass := TransportDocumentClass():NEW()
	
	//-- verifica se chama adapter do TMSA240 ou TMSA310
	If IsInCallStack("TMSA310Grv") .And. FwHasEAI("TMSA310",.T.,,.T.)
	    cAdaptRot := "TMSA310"
	EndIf
EndIf

If lTM250Par
	cNatuDeb := ExecBlock('TM250PAR',.F.,.F.,{3})
	If ValType(cNatuDeb) <> 'C'
		cNatuDeb := Padr( GetMV("MV_NATDEB"), Len( SE2->E2_NATUREZ ) ) // Natureza Utilizada nos Titulos Gerados para a Filial de Debito
	EndIf
Else
	cNatuDeb := Padr( GetMV("MV_NATDEB"), Len( SE2->E2_NATUREZ ) ) // Natureza Utilizada nos Titulos Gerados para a Filial de Debito
EndIf

cHistory := STR0022 + cFilOri + '/' + STR0007 + cViagem//--Filial de Origem//--'Viagem: '

If !Empty(cCodOpe)
	xCodOpe  := cCodOpe
	If xCodOpe == "02"
		lMsBlQl  := .T.
	EndIf	
	cHistory +=  ' / ' + STR0086 + TmsValField("xCodOpe",.F.,"DTR_NOMOPE") //--"Operadora de Frota:"
EndIf	

If lDTRAbast
	If DTR->DTR_VLABST > 0 .And. cCodOpe = "02"
		
		aSDGABS :=	A240SDGABS(cFilOri,cViagem,cCodVei)
		//-- Recebe informacoes do banco do fornecedor
		For nQtdSDG := 1 To Len(aSDGABS)
			AAdd(aDadosDEG, aSDGABS[nQtdSDG][1])
			AAdd(aDadosDEG, aSDGABS[nQtdSDG][2])
			AAdd(aDadosDEG, aSDGABS[nQtdSDG][3] )
			AAdd(aDadosDEG, '')  // cheque

			//Sera Gerado um Tilulo no SE2 para a TAG de Abdastecimento quando houver operadora de frota
			lRet := A050ManSE2(,cViagem,cPrefixo,cTipAbstVL,cParcela,DTR->DTR_VLABST,0,cCodForn,cLojForn,;
			cNatuDeb,1, , "SIGATMS", dDataBase,cHistory , dDataBase, , cFilAnt,aDadosDEG,,;
			,,,,,,,lMsBlQl,cCodOpe,lPaMovBco)

			If lRet	.And. SDG->(ColumnPos("DG_TITGER")) > 0 .And. SDG->(ColumnPos("DG_ORITIT")) > 0
			    For nQtdABS := 1 To Len(aSDGABS)
					If SDG->(MsSeek(FwxFilial('SDG')+aSDGABS[nQtdABS][7]))
						FwFreeArray( aCabSDG )
						aCabSDG		:= {} 

						Aadd( aCabSDG , { "DG_TITGER" , '1' , Nil })
						Aadd( aCabSDG , { "DG_ORITIT" , cOrigemTit , Nil })
						AtuTabSDG( aCabSDG , 4 )
					EndIf
				Next
			EndIf	
		Next
	EndIf
EndIf 

SDG->(dbSetOrder(1))
DTR->(dbSetOrder(3))
nVlrPdgBKP := nValorPDG
nVlrFrtBKP := nValFrete
For nCntFor := 1 To Len(aDadosBco)
	nTotAdiPA := aDadosBco[nCntFor][5]
	cParcela  := aDadosBco[nCntFor][6]
	
	If lTM240BCO
		//-- aDadosBco[1] == Banco
		//-- aDadosBco[2] == Agencia
		//-- aDadosBco[3] == No.Conta
		//-- aDadosBco[4] == No.Cheque
		//-- aDadosBco[5] == Valor adiantamento
		//-- aDadosBco[6] == Parcela
		//-- aDadosBco[7] == Movto. bancario sem cheque
		//-- aDadosBco[8] == Título já gerado???
		//-- aDadosBco[9] == Chave SDG
		lMovBcoChq := ExecBlock('TM240BCO',.F.,.F.,{ aDadosBco[nCntFor][1],aDadosBco[nCntFor][2],aDadosBco[nCntFor][3],aDadosBco[nCntFor][4],aDadosBco[nCntFor][5] })
		If ValType(lMovBcoChq) <> "L"
			lMovBcoChq := .T.
		EndIf
		aDadosBco[nCntFor][7] := lMovBcoChq
	EndIf
	
	If aDadosBco[nCntFor][8] == '1' .AND. cTmsErp == '1' //--Validações ref. ao título de PA
		//Zera o valor do título de PA Para que não seja gerado no Datasul
		//nTotAdiPA := 0
	EndIf

	If nTotAdiPa > 0 .Or. nValorPdg > 0
		If cTmsErp == '0'
			// Verifico se o contrato do Fornecedor está confingurado para o Titulo de PA (SE2) não gerar Movimentação Bancaria (SE5)
			// altero o conteudo da posição 7 do array para que seja possivel a inclusão do titulo de PA no financeiro
			If !lPaMovBco
				aDadosBco[nCntFor][7] := lPaMovBco
				lPaMovBco := .T.
			EndIf
			
			lRet := A050ManSE2(,cViagem,cPrefixo,cTipAdtoPA,cParcela,nTotAdiPA,0,cCodForn,cLojForn,;
								cNatuDeb,1, , "SIGATMS", dDataBase,cHistory , dDataBase, , cFilAnt,aDadosBco[nCntFor],,;
								,,,,,,,lMsBlQl,cCodOpe,lPaMovBco)
		
		ElseIf cTmsErp == '1' .And. lEAIFunOK == .T. //| Se a integracao estiver ligada, dispara envio da mensagem unica			
			//--Efetua tratamento para não gerar mais de um título de pedágio/provisao para o mesmo veículo no ERP DATASUL
			If nCntFor > 1 .Or. lSeparaMsg		
				nValorPDG := 0
				nValFrete := 0
			EndIf
			//| Se existir contrato de carreteiro não envia valor da provisão
			//| ** Validação somente para quando entrar o envio da provisão pelo fechamento da viagem.
			If IsInCallStack("TMSA310")
			     DTY->(DbSetOrder(2))
                 If DTY->(MsSeek( xFilial("DTY") + cFilOri + cViagem ))
                 	nValFrete := 0
			     EndIf
			EndIf
			cCnpjForn := Posicione('SA2',1,FwxFilial('SA2')+cCodForn+cLojForn,'A2_CGC')
			//---Chama Rotina que Dispara INtegração com ERP Datasul
			If FindFunction("TmA240Clas")
				//--Instacia as variáveis 
				lRet := TmA240Clas(cFilOri, cViagem, cViagem,nValFrete,nVALORPDG,nTotAdiPA,/*nINSSRet*/,/*nAliqISS*/, cCodForn,cLojForn, cCnpjForn, /*cFilDeb*/, dDataBase, dDataBase, cHistory, "1"/*Tipo*/, cSubType, .T., .F., .F., .F.,cAdaptRot,DTR->DTR_CODOPE)								
			EndIf
						
		EndIf
		If lRet	.And. SDG->(ColumnPos("DG_TITGER")) > 0 .And. SDG->(ColumnPos("DG_ORITIT")) > 0
			//--Atualiza os SDG's ref. ao pedágio gerado
			For nQtdPdg:=1 To Len(aSDGPDG)
				If SDG->(MsSeek(FwxFilial('SDG')+aSDGPDG[nQtdPdg]))
					FwFreeArray( aCabSDG )
					aCabSDG		:= {} 

					Aadd( aCabSDG , { "DG_TITGER" , '1' , Nil })
					Aadd( aCabSDG , { "DG_ORITIT" , cOrigemTit , Nil })
					AtuTabSDG( aCabSDG , 4 )
				EndIf
			Next	
			//--Atualiza o SDG ref. ao adiantamento da viagem
			If SDG->(MsSeek(FwxFilial('SDG')+aDadosBco[nCntFor,9]))
				FwFreeArray( aCabSDG )
				aCabSDG		:= {} 
				
				Aadd( aCabSDG , { "DG_TITGER" , '1' , Nil })
				Aadd( aCabSDG , { "DG_ORITIT" , cOrigemTit , Nil })
				AtuTabSDG( aCabSDG , 4 )
				
			EndIf			
			If !lSeparaMsg 
				If Len(aRecDTR) > 0
					For nCntDTR := 1 To Len(aRecDTR)
						DTR->(DbGoTo(aRecDTR[nCntDTR]))
						RecLock('DTR',.F.)
						If nTotAdiPa > 0
							DTR->DTR_TITADI := '1' //--Atualiza DTR, informando que o título com o adiantamento já foi gerado.
						EndIf	
						If nVALORPDG > 0
							DTR->DTR_TITPDG := '1'
							DTR->DTR_ORIPDG := 'TMSA310'
						EndIf				
						MsUnLock()	
					Next
				Else
					If DTR->(MsSeek(FwxFilial('DTR')+cFilOri+cViagem+cCodVei))
						RecLock('DTR',.F.)
						If nTotAdiPa > 0
							DTR->DTR_TITADI := '1' //--Atualiza DTR, informando que o título com o adiantamento já foi gerado.
						EndIf	
						If nVALORPDG > 0
							DTR->DTR_TITPDG := '1'
							DTR->DTR_ORIPDG := 'TMSA310'
						EndIf				
						MsUnLock()
					EndIf
				EndIf
				
			EndIf															
		Else
			Exit	
		EndIf
	EndIf		
	
Next
//--Se a variável lSepara == .T., deve ser restaurado o valor do pedágio para que seja gerado um título de pedágio no ERp Datasul.
nValorPDG := nVlrPdgBKP
nValFrete := nVlrFrtBKP
//--Chama Integração com ERP Datasul se o fornecedor do pedágio for diferente do Fornecedor do adiantamento lSeparaMsg == .T.
//--Chama Integração com ERP Datasul se não existe adiantamento Empty(aDadosBco)
If lRet .And. cTmsErp == '1'  .And. (lSeparaMsg .Or. Empty(aDadosBco) .And. lEAIFunOK .And. (nValorPDG > 0 .Or. nValFrete > 0)) //| Se a integracao estiver ligada, dispara envio da mensagem unicanValorPDG > 0 //--Verifica se o título de pedágio deve ser gerado no ERP Datasul	
	//---Chama Rotina que Dispara INtegração com ERP Datasul
	DTR->(dbSetOrder(3))
	If FindFunction("TmA240Clas") .And. DTR->(MsSeek(FwxFilial('DTR')+cFilOri+cViagem+cCodVei))
		cCodForn := DTR->DTR_CODFOR
		cLojForn := DTR->DTR_LOJFOR
		cCnpjForn := Posicione('SA2',1,FwxFilial('SA2')+cCodForn+cLojForn,'A2_CGC')		
		//--Instacia as variáveis
 		lRet := TmA240Clas(cFilOri, cViagem, cViagem,nValFrete,nVALORPDG,0,/*nINSSRet*/,/*nAliqISS*/, cCodForn,cLojForn, cCnpjForn, /*cFilDeb*/, dDataBase, dDataBase, cHistory, "1"     , cSubType  , .T., .F., .F., .F., cAdaptRot,DTR->DTR_CODOPE)				
		  
		If lRet .And. DTR->(ColumnPos('DTR_TITPDG')) > 0 .And. nValorPDG > 0
			RecLock('DTR',.F.)			
			DTR->DTR_TITPDG := '1'
			If DTR->(ColumnPos("DTR_ORIPDG")) > 0
				DTR->DTR_ORIPDG := 'TMSA310'
			EndIf
			MsUnLock()
		EndIf	
		If lRet
			For nQtdPdg:=1 To Len(aSDGPDG)
				If SDG->(MsSeek(FwxFilial('SDG')+aSDGPDG[nQtdPdg]))
					FwFreeArray( aCabSDG )
					aCabSDG		:= {} 
					
					Aadd( aCabSDG , { "DG_TITGER" , '1' , Nil })
					Aadd( aCabSDG , { "DG_ORITIT" , cOrigemTit , Nil })
					AtuTabSDG( aCabSDG , 4 )
				EndIf
			Next				
		EndIf
	EndIf
	
EndIf

RestArea(aAreaSDG)
RestArea(aAreaDA3)
RestArea(aAreaDTR)

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TmA240Clas()
Seta os atributos do método para comnicação com o EAI

Uso: TMSA240/TMSA310

@sample
//TmA250Clas()

@author Leandro Paulino        
@since 26/10/2016
@version 1.0
-----------------------------------------------------------/*/
Function TmA240Clas(cFilOri, cViagem , cTitulo, nValorDoc, nValorPdg, nValorAdto, nINSSRet, nAliqISS, cCodForn,cLojForn , cCnpjForn, cFilDeb, dDataEmi, dDataTrans, cHistory, cTipoMsg , cSubTipMsg, lGerTitulo, lPreview, lBloqPagto,lExcluir,cRotina,cCodOper)
Local lRet			:= .T.
Local aEAIRet		:= {}

Default cFilori		:= ""
Default cViagem		:= ""
Default nValorDoc	:= 0
Default nValorPdg	:= 0
Default nValorAdto	:= 0
Default nINSSRet    := 0
Default nAliqISS    := 0
Default cCodForn	:= ""
Default cLojForn	:= ""
Default cCNPJForn	:= ""
Default cFilDeb		:= ""
Default dDataEmi	:= ddatabase
Default dDataTrans  := ddatabase
Default cHistory 	:= ""
Default cRotina     := "TMSA240"
Default cTipoMsg	:= "1"   //Viagem
Default cSubTipMsg	:= "101" //Titulo Normal
Default lGerTitulo  := GetMV('MV_GERTIT' ,,.T.)
Default lPreview    := .F.
Default lBloqPagto	:= .F. // Bloqueia Pagamento? .T.=SIM;.F.=NÃO
Default lExcluir    := .F.
Default cCodOper    := ""

Private oDtClass := TransportDocumentClass():New()

oDTClass:reset()
oDTClass:cVIAGEM          := cViagem
oDTClass:cFILORI          := cFilori
oDTClass:cTITULO          := cTitulo
oDTClass:nVALORDOC        := nValorDoc
oDTClass:nVALORPDG        := nValorPdg
oDTClass:nVALORADTO       := nValorAdto
oDTClass:nAliqISS         := nAliqISS
oDTClass:nINSSRetido      := nINSSRet      
oDTClass:cCODCLIENTE      := cCodForn
oDTClass:cLOJCLIENTE      := cLojForn
oDTClass:cDSCCLIENTE      := ""
oDTClass:cCNPJCPFCLI      := cCnpjForn
oDTClass:cFILDEBITO       := cFilDeb
oDTClass:dEMISSAO         := dDataEmi
oDTClass:dTRANSACAO       := dDataTrans
oDTClass:dVENCIMENTO      := CTOD("")
oDTClass:cHISTORICO       := cHistory
oDTClass:cEventType       := Iif(lExcluir == .F.,"upsert","delete")
oDTClass:cTIPOMSG         := cTipoMsg   //| Tipo Viagem
oDTClass:cSUBTIPOMSG      := cSubTipMsg //| Geração Viagem
oDTClass:lPreview         := lPreview // default .F.
oDTClass:cStatusPag       := Iif(SuperGetMv("MV_LIBCTC",,.F.)==.T.,"1","2") // Quando .T. a mensagem é enviada com o status do pagamento bloqueado
oDTClass:cOperatorCode    := cCodOper

oDTClass:AddTrip(cFilOri,cViagem)

If FwHasEAI(cRotina,.T.,,.T.) == .T. //| Existe cadastrado do Adapter EAI; 
	aEAIRet := FwIntegDef(cRotina,,,,cRotina)  //| [1] logico(integrou ou não);[2] XML Retorno Erro; [3]-Nome Transacao
	lRet := IIf(ValType(aEAIRet) != "U",aEAIRet[1],.F.)
	
	If lRet .And. !InTransact()
		Aviso(STR0020,STR0079,{STR0046})
    ElseIf !lRet
        Aviso(STR0020,IIf(ValType(aEAIRet) != "U",aEAIRet[2],''),{STR0046},2)
	EndIf
Else
	Aviso(STR0020,STR0084 + " " + cRotina,{STR0046},2) //Atençao;Nao Foi localizada a configuração da Mensagem Unica para a Rotina TMSA240...;OK
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³a240PerAdt ºAutor  ³Daniel Leme 		º Date ³  25/02/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho para o % de adiantamento                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function a240PerAdt()
Local nPercent   := 0
Local cCodFor
Local cLojaFor
Local aContrFor := {}
Local cTipVei   := ""
Local cSerTms2  := ""
Local cTipTra2  := ""
Local cTMSOPdg  := SuperGetMV( 'MV_TMSOPDG',, '0' )
Local cTipOpVg   := ""
Local lTipOpVg   := DTQ->(ColumnPos("DTQ_TPOPVG")) > 0
Local lVgeMod3  := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)

If lTipOpVg 
	If Upper(AllTrim(FunName())) == "TMSA240"
		cTipOpVg:= DTQ->DTQ_TPOPVG
	Else
		cTipOpVg:= M->DTQ_TPOPVG
	EndIf	
EndIf

If cTMSOPdg <> '0' .Or. cTmsErp == '1'   //Somente com Operadora de Frotas ou Datasul
	If lVgeMod3
		cSerTms2	:= FwFldGet("DTQ_SERTMS")
		cTipTra2	:= FwFldGet("DTQ_TIPTRA")	
	Elseif Type('cSerTms') == 'U' .Or. Empty(cSerTms) .Or. Type('cTipTra') == 'U' .Or. Empty(cTipTra)
		A240SerTms(@cSerTms2,@cTipTra2)
	Else
		cSerTms2 := cSerTms
		cTipTra2 := cTipTra
	EndIf
		
	If !lVgeMod3 .And. Type("aCols") == "A" .And. GdFieldPos("DTR_CODVEI") > 0 .And. DUJ->(ColumnPos("DUJ_PERADT")) > 0 
		cCodFor  := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODVEI",n)),"DA3_CODFOR")
		cLojaFor := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODVEI",n)),"DA3_LOJFOR")
		cTipVei  := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODVEI",n)),"DA3_TIPVEI")

		If !Empty(cCodFor) 
			aContrFor := TMSContrFor(cCodFor,cLojaFor,,cSerTms2,cTipTra2,.F.,"",cTipOpVg)
			If Empty(aContrFor)
				aContrFor := TMSContrFor(cCodFor,cLojaFor,,cSerTms2,cTipTra2,.F.,cTipVei,cTipOpVg)
			EndIf
			If !Empty(aContrFor) .And. Len(aContrFor[1]) >= 17 
				nPercent := aContrFor[1][17]
			EndIf
		EndIf
	ElseIf lVgeMod3
		cCodFor  := Posicione("DA3",1,xFilial("DA3")+ FwFldGet("DTR_CODVEI") ,"DA3_CODFOR")
		cLojaFor := Posicione("DA3",1,xFilial("DA3")+ FwFldGet("DTR_CODVEI") ,"DA3_LOJFOR")
		cTipVei  := Posicione("DA3",1,xFilial("DA3")+ FwFldGet("DTR_CODVEI") ,"DA3_TIPVEI")

		If !Empty(cCodFor) 
			aContrFor := TMSContrFor(cCodFor,cLojaFor,,cSerTms2,cTipTra2,.F.,cTipVei,cTipOpVg)
			If Empty(aContrFor)
				aContrFor := TMSContrFor(cCodFor,cLojaFor,,cSerTms2,cTipTra2,.F.,"",cTipOpVg)
			EndIf
			If !Empty(aContrFor) .And. Len(aContrFor[1]) >= 17 
				nPercent := aContrFor[1][17]
			EndIf
		EndIf
	EndIf
EndIf

Return nPercent
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³a240TpCiot ºAutor  ³Daniel Leme 		º Date ³  25/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho para o Tipo de Ciot por periodo                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function a240TpCiot()
Local cRet    	:= ""
Local cCodFor	:= ""
Local cLojaFor	:= ""
Local lVgeMod3  := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)

If lVgeMod3
	cCodFor  := Posicione("DA3",1,xFilial("DA3")+ FwFldGet("DTR_CODVEI") ,"DA3_CODFOR")
	cLojaFor := Posicione("DA3",1,xFilial("DA3")+ FwFldGet("DTR_CODVEI") ,"DA3_LOJFOR")
Else 
	If Type("aCols") == "A" .And. GdFieldPos("DTR_CODVEI") > 0 .And. DUJ->(FieldPos("DUJ_TPCIOT")) > 0 
		cCodFor  := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODVEI",n)),"DA3_CODFOR")
		cLojaFor := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODVEI",n)),"DA3_LOJFOR")
	EndIf
EndIf 

If !Empty(cCodFor) .And. !Empty(cLojaFor) .And. a240ContrF(cCodFor,cLojaFor)
	cRet := DUJ->DUJ_TPCIOT
EndIf

Return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³a240DtCiot ºAutor  ³Daniel Leme 		º Date ³  25/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho para o Tipo de Ciot por periodo                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function a240DtCiot()
Local dRet    	:= dDatabase
Local cCodFor	:= ""
Local cLojaFor	:= ""
Local lVgeMod3  := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)

If lVgeMod3
	cCodFor  := Posicione("DA3",1,xFilial("DA3")+ FwFldGet("DTR_CODVEI") ,"DA3_CODFOR")
	cLojaFor := Posicione("DA3",1,xFilial("DA3")+ FwFldGet("DTR_CODVEI") ,"DA3_LOJFOR")
ELse 
	If Type("aCols") == "A" .And. GdFieldPos("DTR_CODVEI") > 0 .And. DUJ->(FieldPos("DUJ_PRCIOT")) > 0 
		cCodFor  := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODVEI",n)),"DA3_CODFOR")
		cLojaFor := Posicione("DA3",1,xFilial("DA3")+AllTrim(GdFieldGet("DTR_CODVEI",n)),"DA3_LOJFOR")
	EndIf
EndIf 

If  !Empty(cCodFor) .And. !Empty(cLojaFor) .And. a240ContrF(cCodFor,cLojaFor)
	dRet := DUJ->(dDatabase + DUJ_PRCIOT)
EndIf

Return dRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³a240ContrF ºAutor  ³Daniel Leme 		º Date ³  25/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pòsiciona Contrato de Fornecedor para CIOT por periodo     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function a240ContrF(cCodFor,cLojaFor,lForGen)
Local lAchou  := .F.
Local cForGen := GetMV("MV_FORGEN")
Local aAreaDUJ := DUJ->(GetArea())

Default cCodFor  := ""
Default cLojaFor := "" 
Default lForGen  := .F.

If !Empty(cCodFor)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe contrato em vigencia para o fornecedor em questao      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("DUJ")
	DbSetOrder(2)
	If DUJ->(MsSeek(xFilial("DUJ")+cCodFor+cLojaFor))
		While DUJ->(!Eof()) .And. DUJ->DUJ_FILIAL == xFilial("DUJ") .And. DUJ->DUJ_CODFOR + DUJ->DUJ_LOJFOR  == cCodFor + cLojaFor
			If Empty(DUJ->DUJ_FIMVIG) .Or. (DUJ->DUJ_INIVIG <= dDataBase .And. DUJ->DUJ_FIMVIG >= dDataBase)
				lAchou := .T.
				Exit
			EndIf
			DUJ->(DbSkip())
		EndDo
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao existir contrato em vigencia para o fornecedor em questao, verifica³
	//³ se existe contrato em vigencia para o Fornecedor Generico (MV_FORGEN)     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lAchou
		If DUJ->(MsSeek(xFilial("DUJ")+cForGen))
			While DUJ->(!Eof()) .And. DUJ->DUJ_FILIAL == xFilial("DUJ") .And. DUJ->DUJ_CODFOR + DUJ->DUJ_LOJFOR  == cForGen
				If Empty(DUJ->DUJ_FIMVIG) .Or. (DUJ->DUJ_INIVIG <= dDataBase .And. DUJ->DUJ_FIMVIG >= dDataBase)
					lAchou := .T.
					lForGen:= .T.
					Exit
				EndIf
				DUJ->(DbSkip())
			EndDo
		EnDif
	EndIf
EndIf

RestArea(aAreaDUJ)

Return lAchou

/*/-----------------------------------------------------------
{Protheus.doc} A240SerTms()
//Caso a rotina de Complemento de viagem seja chamada direto pelo menu, as variaveis cSerTms e cTipTra não estão declaradas como Private.
//Isto só ocorre caso a rotina de Complemento seja chamada pela rotina principal de Viagens (TMSA144).
//Para corrigir o problema, foram criadas 2 variáveis locais, que assumem o valor das variáveis Private, quando estas existirem.
//Caso contrário, é selecionado o Serviço e o Tipo de Transporte da viagem.

Uso: TMSA144/TMSA240

@author Katia 
@since 07/03/2018
@version 1.0
-----------------------------------------------------------/*/
Static Function A240SerTms(cSerTms2,cTipTra2)

Local aAreaDTQ  := DTQ->(GetArea())

Default cSerTms2:= ""
Default cTipTra2:= ""

DTQ->(dbSetOrder(2))
If DTQ->( MsSeek( xFilial('DTQ') + M->DTR_FILORI + M->DTR_VIAGEM ) )
	If Type('cSerTms') == 'U' .Or. Empty(cSerTms)
		cSerTms2 := DTQ->DTQ_SERTMS 
	Else
		cSerTms2 := cSerTms
	EndIf
		
	If Type('cTipTra') == 'U' .Or. Empty(cTipTra)
		cTipTra2 := DTQ->DTQ_TIPTRA
	Else
		cTipTra2 := cTipTra
	EndIf
EndIf

RestArea( aAreaDTQ )

Return Nil

/*/-----------------------------------------------------------
{Protheus.doc} A240CmpDTR()
//Determina os campos que serao gatilhados para uma viagem coligada
//aYesCampo- Campos serao sempre gatilhados na coligada
//aHerCampo- Campos serao gatilhados conforme o Pergunte
Uso: TMSA240

@author Katia 
@since 14/03/2018
@version 1.0
-----------------------------------------------------------/*/	
Static Function A240CmpDTR(cFilViag, cNumViag, nOpc, aYesCampo,aHerCampo)
Local lRet      := .T.
Local aAreaDTX  := DTX->(GetArea())
Local aAreaDTQ  := DTQ->(GetArea())
Local lDTRCodFav:= DTR->(ColumnPos("DTR_CODFAV")) > 0

Default cFilViag	:= ""
Default cNumViag	:= ""
Default nOpc    	:= 0

aYesCampo := {'DTR_ITEM', 'DTR_CODVEI', 'DTR_PROVEI', 'DTR_CODRB1', 'DTR_CODRB2', 'DTR_CODRB3', 'DTR_QTDEIX', 'DTR_CREADI', 'DTR_LOJCRE', 'DTR_NOMCRE', 'DTR_QTEIXV', 'DTR_CODCPO', 'DTR_ORIPDG', 'DTR_TITPDG' }
aHerCampo := {'DTR_VALFRE','DTR_TABCAR','DTR_TABFRE', 'DTR_TIPTAB', 'DTR_VALRB1', 'DTR_VALRB2', 'DTR_VALRB3','DTR_PERADI'  }

If lDTRCodFav
	aAdd(aYesCampo, 'DTR_CODFAV')
	aAdd(aYesCampo, 'DTR_LOJFAV')
	aAdd(aYesCampo, 'DTR_NOMFAV')
EndIf

If !Empty(cNumViag)
	DTY->( DbSetOrder( 2 ) ) //Verifica se existe Contrato Carreteiro gerado para a coligada
	If	DTY->(MsSeek(xFilial('DTY') + cFilViag + cNumViag)) 
		lRet:= .F.
	EndIf	
	
	If lRet //Verifica se existe Manifesto gerado para a coligada	
		DTX->(DbSetOrder(3))
		If	DTX->(MsSeek(xFilial('DTX') + cFilViag + cNumViag))
			lRet:= .F.
		EndIf	
	EndIf
	
	If !lRet
		aYesCampo:= {}
		aHerCampo:= {}
	EndIf	
EndIf	

RestArea(aAreaDTX)
RestArea(aAreaDTQ)
Return lRet	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A240AtuDLD³ Autor ³Katia                  ³ Data ³08/05/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza os Campos do Arq. DLD (Pagamento Viagem)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A240AtuDLD(ExpA1,ExpA2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - aHeader Auxiliar Getdados do Pagto Viagem          ³±±
±±³          ³ ExpA2 - Array contendo os Pagamentos da Viagem             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A240AtuDLD(aHeaderDLD, aPagtoVge)

Local aArea      := GetArea()
Local nX         := 0
Local nZ         := 0 
Local lAtuDLD    := .F.
Local aCodFav    := {}
Local nPosIDOPE  := Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_IDOPE" })
Local nPosForPag := Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_FORPAG" })
Local nPosForAdt := Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_FORADT" })
Local nPosCondut := Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_CONDUT" })
Local nY         := 1
Local lFavorec   := .F.
Local nPosDLD    := 0
Local cTipPar    := ""
Local cForPag    := ""
Local cRetIdOpe  := ""

Default aHeaderDLD:= {}
Default aPagtoVge := {}

dbSelectArea("DLD")
DLD->(dbSetOrder(1))
While DLD->(MsSeek(xFilial('DLD')+DTR->(DTR_FILORI+DTR_VIAGEM+DTR_ITEM)))
	RecLock("DLD",.F.)
	DLD->(dbDelete())
	MsUnLock()
	DLD->(dbSkip())
EndDo

nPosDLD := aScan(aPagtoVge,{|x| x[1]+x[2] == DTR->DTR_ITEM+DTR->DTR_CODVEI}) 

If nPosDLD > 0 .And. Empty(TmDUDIdOpe(DTR->DTR_ITEM,DTR->DTR_CODVEI,.F.))  //--- Verifica se o DUP_IDOPE está preenchido
	For nZ := 1 to Len(aPagtoVge[nPosDLD][3])
		// Atualiza os dados contidos na GetDados                   
		If !aPagtoVge[nPosDLD][3][nZ][Len(aPagtoVge[nPosDLD][3][nZ])] //-- Verifica se a linha esta deletada
			RecLock("DLD",.T.)
			DLD->DLD_FILIAL := xFilial('DLD')
			DLD->DLD_FILORI := DTR->DTR_FILORI
			DLD->DLD_VIAGEM := DTR->DTR_VIAGEM
			DLD->DLD_ITEDTR := DTR->DTR_ITEM
			For nY := 1 to Len(aHeaderDLD)
				If aHeaderDLD[nY][10] # "V"
					DLD->(FieldPut(FieldPos(Trim(aHeaderDLD[nY][2])),aPagtoVge[nPosDLD][3][nZ][nY]))
				EndIf
			Next nY
			DLD->(MsUnlock())

			lAtuDLD:= .T.  
		EndIf
	Next
EndIf

//-- Se não informado o DUP_IDOPE, considera os dados da Forma de pagamento (DLD)
If !lAtuDLD 
	nX := aScan(aMotViag,{|x| x[1] == DTR->DTR_ITEM}) 
	If nX > 0
		For nZ := 1 to Len(aMotViag[nX][2])
			If !aMotViag[nX][2][nZ][Len(aMotViag[nX][2][nZ])] //-- Verifica se a linha esta deletada
				If aMotViag[nX][2][nZ][nPosCondut] == '1'  //Condutor Principal
					//Sera gerado 2 registros na DLD, um para o Pagamento e outro para o Adiantamento
					For nY:= 1 To 2   
						lFavorec:= .T.
						cTipPar := ""
						cForPag := ""
						If nY == 1  //Pagamento, somente se DUP_FORPAG <> '0' //Nao Utiliza
							cTipPar:= Padr(2, Len(DLD->DLD_TIPPAR))   //2- Saldo Frete
							cForPag:= Iif(aMotViag[nX][2][nZ][nPosForPag] <> '0', aMotViag[nX][2][nZ][nPosForPag], '1')  //1-Cartao; 2-Deposito
						Else	 //Adiantamento, somente se DUP_FORADT <> '' e existir um Valor de Adiantamento
						 	If !Empty(aMotViag[nX][2][nZ][nPosForAdt]) .And. DTR->DTR_ADIFRE <> 0
								cTipPar:= Padr(1, Len(DLD->DLD_TIPPAR))   //1- Adiantamento 
								cForPag:= aMotViag[nX][2][nZ][nPosForAdt] //1-Cartao; 2-Deposito
								lFavorec:= .F.
							EndIf	
						EndIf	
						If !Empty(cTipPar) .And. !Empty(cForPag)
							RecLock("DLD",.T.)
							DLD->DLD_FILIAL := xFilial('DLD')
							DLD->DLD_FILORI := DTR->DTR_FILORI
							DLD->DLD_VIAGEM := DTR->DTR_VIAGEM
							DLD->DLD_ITEDTR := DTR->DTR_ITEM
							DLD->DLD_CODVEI := DTR->DTR_CODVEI
							DLD->DLD_FORPAG := cForPag
							DLD->DLD_TIPPAR := cTipPar
							DLD->DLD_RECEB  := '1'  //1-Proprietario; 2-Motorista
							
							DA3->( DbSetOrder( 1 ) )
							If DA3->( MsSeek( xFilial('DA3') + DTR->DTR_CODVEI ) ) .And. !Empty( DA3->DA3_CODFOR )
								cRetIdOpe := A240IdPam( DA3->DA3_CODFOR, DA3->DA3_LOJFOR )
								If !Empty(cRetIdOpe)
									DLD->DLD_IDOPE  := cRetIdOpe
								Else
									DLD->DLD_IDOPE  := aMotViag[nX][2][nZ][nPosIDOPE]
								EndIf
								//---- Recebedor = Proprietario, grava os dados do Favorecido
								If lFavorec
									aCodFav := T250BscFav(DA3->DA3_COD,DA3->DA3_CODFOR,DA3->DA3_LOJFOR,,)
									If Len(aCodFav) > 0
										DLD->DLD_CODFAV := aCodFav[1][1]
										DLD->DLD_LOJFAV := aCodFav[1][2]
									EndIf
								EndIf
								DLD->(MsUnlock())
							EndIf
						EndIf
					Next nY
				EndIf
			EndIf
		Next nZ
	EndIf
EndIf

RestArea( aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TA240PagV  ³Katia º Data ³                       07/25/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Manutencao de Pagamento de Viagem PAMCARD                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.    ³ ExpN1 -> Opcao selecionada                                 º±±
±±º          ³ ExpC1 -> Filial da Viagem                                  º±±
±±º          ³ ExpC2 -> Viagem                                            º±±
±±º          ³ ExpC3 -> Item DTR                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ .T.                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TA240PagV(nOpcx, cFilOri, cViagem, cItemDTR, cCodVei, cCodOpe,cTpCiot)

Local nPosDLD      := Ascan(aPagtoVge,{|x| x[1]+x[2] == GdFieldGet('DTR_ITEM',n)+GdFieldGet('DTR_CODVEI',n) })
Local nAux         := 0
Local nOpc         := 0
Local aLimpCols    := {}
Local aNoFields    := {}
Local aYesFields   := {}
Local aAlter	   := {}
Local nSavN	       := n
Local aSavCols     := aClone(aCols)
Local aSavHeader   := aClone(aHeader)
Local aSavaRotina  := aClone(aRotina)
Local oDlg         := Nil
Local oGetD        := Nil
Local nX           := 0
Local lContinua    := .T.

Default cItemDTR    := ""
Default cCodVei     := ""
Default cCodOpe     := ""
Default cTpCiot     := ""

If Empty(cCodVei)
	Help('',1,'TMSA24037') //"Informe o Veiculo"
	lContinua:= .F.
ElseIf cCodOpe <> '02' 
	Help('',1,'TMSA24093') //"Opção disponível para operadora Pamcard "
	lContinua:= .F.
ElseIf (Empty(cFilOri+cViagem) .Or. Empty(cItemDTR))
	lContinua:= .F.
EndIf

If lContinua
	//-- Finaliza as Teclas de Atalhos
	TmsKeyOff(aSetKey)
	
	n       := 1
	aCols	:= {}
	aHeader := {}
	aRotina[2][4] := 2
	aRotina[3][4] := 3
	
	RegToMemory( "DLD" , .T. )
		
	AAdd( aAlter, "DLD_FORPAG" )
	AAdd( aAlter, "DLD_TIPPAR" )
	AAdd( aAlter, "DLD_RECEB" )
	AAdd( aAlter, "DLD_IDOPE" )
		
	AAdd( aNoFields, "DLD_FILIAL" )
	AAdd( aNoFields, "DLD_FILORI" )
	AAdd( aNoFields, "DLD_VIAGEM" )
	AAdd( aNoFields, "DLD_TAGID" )
		
	nAux := aScan( aPagtoVge, {|ExpA1| ExpA1[1]+ExpA1[2] == cItemDTR+cCodVei } )
	If nAux > 0 .And. Len(aPagtoVge[nAux][3]) == 0
		nAux:= 0
	EndIf
	
	If nAux <= 0
		TMSFillGetDados( nOpcx, 'DLD', 1,xFilial( 'DLD' ) + cFilOri + cViagem + cItemDTR + cCodVei, {|| DLD->DLD_FILIAL + DLD->DLD_FILORI + DLD->DLD_VIAGEM + DLD->DLD_ITEDTR + DLD->DLD_CODVEI }, ;
		{|| .T. }, aNoFields,	aYesFields )
		aHeaderDLD := AClone( aHeader )
	Else
		aCols := AClone( aPagtoVge[nAux][3] )
		aHeader := AClone( aHeaderDLD )
	EndIf
	If Len( aCols ) == 1 .And. Empty( GDFieldGet( 'DLD_CODVEI', 1 ) )		
		GDFieldPut( 'DLD_CODVEI', cCodVei , 1 )
		GDFieldPut( 'DLD_ITEDTR', cItemDTR, 1 )
	EndIf
	
	DEFINE MSDIALOG oDlg FROM 94 ,15 TO 430,1300 TITLE STR0088 Of oMainWnd PIXEL //"Formas de Pagamento da Viagem"
	oGetD := MSGetDados():New(30,4,160,640,IIf(nOpcx == 2 ,2 ,3),{ ||TA240LLinOk('DLD',cTpCiot)},"TA240TudOk()",'DLD_CODVEI/DLD_ITEDTR',.T.,aAlter,,.F.)
	@ 6  ,116 SAY '' Of oDlg PIXEL SIZE 26 ,9
	@ 18 ,3   SAY STR0007  Of oDlg PIXEL SIZE 56 ,9  //"Viagem : "
	@ 18 ,36  SAY cFilOri+"/"+cViagem Of oDlg PIXEL SIZE 50 ,9
	@ 18 ,125 SAY cItemDTR Of oDlg PIXEL SIZE 140 ,9
	
	ACTIVATE MSDIALOG oDlg    ON INIT (oGetD:Refresh(),EnchoiceBar(oDlg, {||IIF(oGetD:TudoOk(),(nOpc:=1,oDlg:End()),(nOpc:=0))},{||oDlg:End()}) )
	
	If nOpc == 1 
		If nOpcx != 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Limpando registros deletados                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 To Len( aCols )
				If !aTail(aCols[nX])
					AAdd(aLimpCols,aCols[nX])
				EndIf
			Next nX
			
			aCols := {}
			aCols := aClone( aLimpCols )
			
			If nPosDLD > 0
				aPagtoVge[nPosDLD][3] := aClone(aCols)
			Else
				AAdd(aPagtoVge,{cItemDTR,cCodVei, aClone(aCols)})
			EndIf
		
			//----- Se houver alteração na Forma de Pagamento e DUP_IDOPE preenchido, considera dados da DUP e limpa o DUP_IDOPE
			TmDUDIdOpe(cItemDTR,cCodVei,.T.)   //Limpa o campo dup_idope
			
		EndIf	
	EndIf
	
	aRotina := aClone(aSavaRotina)
	aHeader := aClone(aSavHeader)
	aCols   := aClone(aSavCols)
	n		:= nSavN
	
	//-- Iniciliza as Teclas de Atalhos
	TmsKeyOn(aSetKey)
EndIf
	
aSize(aSavCols,0)
aSize(aSavHeader,0)
aSize(aSavaRotina,0)
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TA240TudOkºAutor  ³Katia Bianchi       º Date ³  15/04/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a tela de formas de pagto da viagem                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ TMSA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TA240TudOk()  

Local lRet     	 := .T.
Local nPosAdifre := 0
Local nPosValBai := 0
Local nValor 	 := 0
Local nX		 := 0
Local nPosTipPar := Ascan(aHeader, {|x| AllTrim(x[2]) == "DLD_TIPPAR" })  //1-Adiantamento,2-SaldoFrete,3-Pedagio
Local nPosAdto	 := AScan(aCols, { |x| !x[Len(aHeader)+ 1] .And. Alltrim(x[nPosTipPar]) == '1'}) //Adiantamento de Frete
Local nPosSld	 := AScan(aCols, { |x| !x[Len(aHeader)+ 1] .And. Alltrim(x[nPosTipPar]) == '2'}) //Saldo de Frete

If Len(aCols) > 0 
	If AScan(aCols, { |x| !x[Len(aHeader)+ 1] }) > 0 
		If nPosAdto = 0 		
			nPosValBai  := Ascan(aHeaderSDG, {|x| AllTrim(x[2]) == "DG_VALBAI" })
			nPosAdifre  := Ascan(aAdtoViag, {|x| x[1] == GDFieldGet("DLD_CODVEI",n) })
			If ( nPosAdifre > 0 ) .And. ( nPosValBai > 0 )
				For nX := 1 To Len(aAdtoViag[nPosAdifre][2])
					If !aAdtoViag[nPosAdifre,2,nX,Len(aHeaderSDG)+1]
						nValor += aAdtoViag[nPosAdifre,2,nX,nPosValBai]
					EndIf
				Next nX
			EndIf

			If nValor > 0
				lRet := .F.
				Help(' ', 1, 'TMSA24095') //-- Nao foi informado tipo de parcela adiantamento
			EndIf
		EndIf	
				
		If lRet .And. nPosSld = 0
			lRet := .F.
			Help(' ', 1, 'TMSA24094') //-- Nao foi informado tipo de parcela saldo de frete
		EndIf				
		
		If lRet
			If  !Empty(TmDUDIdOpe(GDFieldGet("DLD_ITEDTR",n) ,GDFieldGet("DLD_CODVEI",n),.F.))  
				If !MsgNoYes( STR0096, STR0020)  //'O Id.Motorista informado em "Motoristas da Viagem" será ignorado e bloqueado para ediçã. Confirma ? '
					lRet:= .F.
				EndIf
			EndIf
		EndIf
	Else  //Todos registros
		lRet := .F.
		Help(' ', 1, 'TMSA24094') //-- Nao foi informado tipo de parcela saldo de frete
	EndIf
EndIf


Return lRet
/*/-----------------------------------------------------------
{Protheus.doc} A240TipVV
Função para retornar o tipo do veiculo e o tipo de operação 
da viagem para que a execução da função TMSContrFor ocorra
sem erro.

Uso: TMSA144/TMSA240

@author Rodrigo.Pirolo 
@since 30/06/2020
@version 1.0
-----------------------------------------------------------/*/

Static Function A240TipVV( cFilOri, cViagem, cCodVei, cTipVei, cTipOpVg )

Local aAreaDTQ  := DTQ->(GetArea())
Local aAreaDA3  := DA3->(GetArea())

Default cFilOri	:= DTR->DTR_FILORI
Default cViagem	:= DTR->DTR_VIAGEM
Default cCodVei	:= DTR->DTR_CODVEI
Default cTipVei	:= ""
Default cTipOpVg:= ""

DTQ->( DbSetOrder( 2 ) )
If DTQ->( MsSeek( xFilial('DTQ') + cFilOri + cViagem ) )
	cTipOpVg	:= M->DTQ_TPOPVG
EndIf

DA3->( DbSetOrder( 1 ) )
If DA3->( MsSeek( xFilial("DA3") + cCodVei ) )
	cTipVei	:= DA3->DA3_TIPVEI
EndIf

RestArea( aAreaDA3 )
RestArea( aAreaDTQ )

Return Nil

/*/-----------------------------------------------------------
{Protheus.doc} A240IdPam
Função para retornar o numero do cartão do proprietario de 
acordo com a tabela DDQ.

Uso: TMSA144/TMSA240

@author Rodrigo.Pirolo 
@since 11/11/2020
@version 1.0
-----------------------------------------------------------/*/

Static Function A240IdPam( cFornec, cLoja )

	Local cRet		:= ""
	Local aArea		:= GetArea()
	Local aAreaDLD	:= DLD->( GetArea() )
	Local aAreaDDQ	:= DDQ->( GetArea() )
	
	Default cFornec	:= ""
	Default cLoja	:= ""

	DbSelectArea("DDQ")
	DDQ->( DbSetOrder(2) )//DDQ_FILIAL, DDQ_CODFOR, DDQ_LOJFOR

	If DDQ->( DbSeek( xFilial("DDQ") + cFornec + cLoja ) ) .AND. DDQ->DDQ_STATUS == "1" 
		cRet	:= DDQ->DDQ_IDCART
	EndIf

	RestArea( aAreaDDQ )
	RestArea( aAreaDLD )
	RestArea( aArea )

Return cRet
//--------------------------------
/*{Protheus.doc} VldShipRep
Validações do Shipping Repom 2.2
@type Static Function
@author Katia
@since 19/11/2020
@version 12.1.31
@return lRet
*/
//----------------------------------
Static Function VldShipRep(cCodVei,cCodRbq1,cCodRbq2,cCodRbq3)
Local lRet    		:= .T.
Local aMsgErr 		:= {}
Local lRestRepom 	:= SuperGetMV('MV_VSREPOM',,"1") == "2.2"
Local cMsg			:= ""

Default cCodVei:= ""
Default cCodRbq1:= ""
Default cCodRbq2:= ""
Default cCodRbq3:= ""

If lRestRepom .And. !Empty(cCodVei)
	
	DA3->(DbSetOrder(1))
	If DA3->(MsSeek( xFilial('DA3')+cCodVei)) .And. DA3->DA3_FROVEI <> '1'

		VldVeicRep( cCodVei , @cMsg, @aMsgErr )

		If !Empty(cCodRbq1)
			VldVeicRep( cCodRbq1 , @cMsg, @aMsgErr )
			
			If !Empty(cCodRbq2)
				VldVeicRep( cCodRbq2 , @cMsg, @aMsgErr )
						
				If !Empty(cCodRbq3)
					VldVeicRep( cCodRbq3 , @cMsg, @aMsgErr )
				EndIf
			EndIf
		EndIf

		If !Empty(aMsgErr)
			lRet:= .F.
		EndIf
	EndIf 

EndIf

If !lRet
	Help(' ', 1, 'TMSXFUNC18') // "Ocorreram erros ou validações do processo pela Operadora de Frotas e o processo não foi realizado com sucesso."
	If Len(aMsgErr)> 0
		TmsMsgErr( aMsgErr, cMsg )
	EndIf
EndIf

Return lRet

//--------------------------------
/*{Protheus.doc} VldVeicRep
Validações do Shipping Repom 2.2
@type Static Function
@author Caio
@since 27/01/2021
@version 12.1.31
@return lRet
*/
//----------------------------------
Static Function VldVeicRep( cCodVei , cMsg, aMsgErr )
Local lRet		:= .T. 
Local aForDA3	:= {} 
Local aCodigos	:= {} 
Local cFornVei	:= ""
Local cCodMot	:= ""

Default cCodVei		:= ""
Default cMsg		:= ""
Default aMsgErr		:= {} 

DA3->(DbSetOrder(1))
If DA3->(MsSeek( xFilial('DA3')+cCodVei)) .And. DA3->DA3_FROVEI <> '1'

	aForDA3:= RetCodForn(cCodVei)
	If Len(aForDA3) > 0 .And. !Empty(aForDA3[1]) .And. !Empty(aForDA3[2])
		cFornVei	:= aForDA3[1] + aForDA3[2]
	EndIf 
	
	cCodMot		:=  RTrim( DA3->DA3_MOTORI )

	lRet:= TM15VldVei(cCodVei,@aMsgErr)

	If !lRet
		If Len(aMsgErr) > 1   //Problemas em mais de um veiculo
			cMsg	:= STR0100 + " - " + STR0102  //-- "Verifique o cadastro do Veiculo
		Else
			cMsg	:= STR0100 + " - " + STR0102 + ": " + cCodVei //-- "Verifique o cadastro " + "veículo"
		EndIf

		AAdd(aCodigos, { "" ,;                    //Fornecedor Veiculo
					""   ,;                    //Motorista  
					cCodVei   ,;                    //Veiculo
					''        })                    //Reboque

		TMSAtualOp( "01", "5", aCodigos, .F. )
	EndIF 

	If lRet
		If Len(aForDA3) > 0 .And. !Empty(aForDA3[1]) .And. !Empty(aForDA3[2])
			lRet:= TM15VldHir(aForDA3[1],aForDA3[2],@aMsgErr)			
		
			If !lRet
				cMsg	:= STR0100 + " - " + STR0101 + ": " + aForDA3[1] + "/" + aForDA3[2] //-- "Verifique o cadastro " + "fornecedor"

				aCodigos	:= {} 

				AAdd(aCodigos, { cFornVei ,;                    //Fornecedor Veiculo
								""   ,;                    //Motorista  
								""   ,;                    //Veiculo
								''        })                    //Reboque

				TMSAtualOp( "01", "5", aCodigos, .F. )
			EndIF 
		Else 
			lRet	:= .F. 
			cMsg	:= STR0102 + ": " + cCodVei + " " + STR0103  //-- "Veiculo" + "não possui proprietario"
		EndIf
	EndIf
	
EndIf 

Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} RetCodForn
Retorna código/loja do proprietario do veiculo
@type Static Function
@author Caio Murakami
@since 14/08/2020
@version 12.1.30
@param cCampo
@return lRet
*/
//------------------------------------------------------------------
Static Function RetCodForn(cCodVei)
Local aAreaDA3	:= DA3->( GetArea() )
Local cCodForn	:= ""
Local cLojForn	:= ""

Default cCodVei	:= ""

DA3->( dbSetOrder(1) )
If DA3->( MsSeek( xFilial("DA3") + cCodVei ))
	cCodForn	:= DA3->DA3_CODFOR
	cLojForn	:= DA3->DA3_LOJFOR
EndIf 

RestArea( aAreaDA3 )
Return { cCodForn , cLojForn } 

//-------------------------------------------------------------------
/*{Protheus.doc} TM240DelDG
Verifica se pode deletar linha do SDG
@type Function
@author Valdemar Roberto Mognon
@since 25/05/2021
@version 12.1.30
@param
@return lRet
*/
//------------------------------------------------------------------
Function TM240DelDG()
Local lRet     := .T.
Local lGerador := SDG->(ColumnPos("DG_GERADOR") > 0)

If lGerador .And. AllTrim(GdFieldGet("DG_GERADOR",n)) != "TMSA240" .And. !INCLUI
	Help(" ",1,"TMSA240A8")	//-- Existe SDG gerado por outra rotina. O Estorno não será permitido.
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} AtuTabSDG
Atualiza SDG
@type Function
@author CAio Murakami
@since 10/06/2021
@version 12.1.30
@param
@return lRet
*/
//------------------------------------------------------------------
Static Function AtuTabSDG( aCab , nOpc )
Local nCount	:= 1 
Local lExclui	:= .F. 
Local aArea		:= GetArea()

Default aCab	:= {}
Default nOpc	:= 3 

If FindFunction("TMSA070Aut")
	TMSA070Aut( aCab , nOpc )
Else 

	If nOpc == 3 
		RecLock("SDG",.T.)
	ElseIf nOpc == 4 .Or. nOpc == 5 
		RecLock("SDG",.F.)
		If nOpc == 5 
			lExclui	:= .T. 
		EndIf 
	EndIf 

	If lExclui
		SDG->(DbDelete())
	Else	
		For nCount := 1 To Len(aCab )
			SDG->&(aCab[nCount,1])	:= aCab[nCount,2]
		Next nCount 
	EndIf 

	SDG->(MsUnlock())
EndIf 

RestArea(aArea)
Return 
