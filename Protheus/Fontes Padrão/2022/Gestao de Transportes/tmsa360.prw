#INCLUDE 'TMSA360.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWLIBVERSION.CH"
#DEFINE aPos  {  35,  3, 130, 315 }

//-- Diretivas indicando as colunas dos documentos da viagem

#define CTSTATUS	1
#define CTMARCA		3
#define CTARMAZE	5
#define CTLOCALI	6
#define CTFILDOC	7
#define CTDOCTO		8 
#define CTSERIE		9
#define CTQTDVOLET	15
#define CTQTDVOLTP	16
#define CTPLIQUIET	17
#define CTPLIQUITP	18

Static lEncViag
Static nMaxL		:= 0
Static n01			:= 0 //-- Compatibilização TDS
Static n02			:= 0 //-- Compatibilização TDS

//-- Tratamento Rentabilidade/Ocorrencia
Static aRecDep    := { '16',; //-- Rec. CTe Complemento
                       '17',; //-- Desp. Compl.
                       '18',; //-- Rec./Desp.
                       '19',; //-- Rec. CTe Reentrega
                       '20',; //-- Rec. CTe Devolução
                       '21' } //-- Trecho GFE

Static cInicPos		:= ""
Static cItem		:= ""
Static lTM360TOK	:= ExistBlock('TM360TOK')
Static lTM360LOK	:= ExistBlock('TM360LOK')
Static lTM360EST	:= ExistBlock('TM360EST') //-- Pto de Entrada no Estorno de Ocorrencia, linha a linha de Doc.
Static lTM360DOC	:= ExistBlock('TM360DOC') //-- Permite a modificacao da ordem do vetor aDoc
Static lTM360BUT	:= ExistBlock('TM360BUT') //-- Permite a inclusão de novos botões na ENCHOICEBAR
Static cTmsRdpU		:= SuperGetMV( 'MV_TMSRDPU',.F., 'N' )   //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho
Static lTmsRdpU		:= !Empty(cTmsRdpU) .And. cTmsRdpU <> 'N'

Static lAjusta		:= .F.
Static nRecursivo	:= 0
Static aColsAnt		:= {}
Static aColsNew		:= {}

Static lDM0			:= TableInDic("DM0")
Static lViagem3		:= FindFunction("TMSAF60") .And. AliasInDic("DM3")
Static lRestRepom	:= SuperGetMV('MV_VSREPOM',,"1") == "2.2"
Static aMailPre		:= {}
Static lMetrica		:= FindFunction('TMSMetrica') .And. FindFunction('FWLsPutAsyncInfo') .And. FwLibVersion() >= "20200727" 
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA360  ³ Autor ³ Antonio C Ferreira    ³ Data ³09.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Registro de Ocorrencias                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA360(ExpA1,ExpA2,ExpA3,ExpN1)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Cabecalho do Reg. Ocorrencia (DUA)                 ³±±
±±³          ³ ExpA2 - Itens do Reg. Ocorrencia (DUA)                     ³±±
±±³          ³ ExpA3 - aCols de NF's com Avaria (DV4)                     ³±±
±±³          ³ ExpN1 - Opcao Rotina Automatica (Incl./Est.)     )         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360(xAutoCab, xAutoItens, xAutoNFAva, nOpcAuto)

Local oBrowse		:= Nil

Private cCadastro	:= STR0001 //'Registro de Ocorrencias'
Private l360Auto	:= xAutoCab <> Nil  .And. xAutoItens <> Nil
Private aAutoCab	:= {}  // Cabecalho da Nota Fiscal (Rotina Automatica)
Private aAutoItens	:= {}  // Itens da NF (Rotina Automatica)
Private aNFAvaria	:= {}
Private lCiaAerea	:= .F.
Private aRotina		:= MenuDef()
Private aIdProduto	:= {}
Default xAutoCab	:= {}
Default xAutoItens	:= {}
Default xAutoNFAva	:= {}
Default nOpcAuto	:= 3

If Type("aPanAgeTMS") == "U"
	aPanAgeTMS := Array(6)
EndIf

lPainel := IsInCallStack("TMSAF76") .And. !Empty(aPanAgeTMS)
TMA360Ini()

If lMetrica
    //Zera o contador (variaveis statics)
    TMSSetMet()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas          ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ MV_PAR01 - Edita e-mail?                   ³
//³ MV_PAR02 - Conciliação de Sobras e Faltas ?³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey( VK_F12, { || pergunte("TMA360",.T.) } )

If !l360Auto
	DbSelectArea('DUA')
	DbSetOrder(1)
	If lPainel
		If (at("(",aPanAgeTMS[6])>0)
			&(aPanAgeTMS[6])
		Else
			&(aPanAgeTMS[6] + "('" + aPanAgeTMS[1] + "'," + StrZero(aPanAgeTMS[2],10) + "," + StrZero(aPanAgeTMS[3],2) + ")")
		Endif
	Else
		oBrowse := FWMBrowse():New()

		oBrowse:SetAlias( 'DUA' )
		oBrowse:SetDescription( cCadastro ) // Cadastro de Prioridades
		oBrowse:Activate()
	EndIf
Else

	lMsHelpAuto := .T.
	aAutoCab    := xAutoCab
	aAutoItens  := xAutoItens
	aNFAvaria   := xAutoNFAva

	//Verifica se a Estrutura do Array de Notas Fiscais com Avaria esta' correta
	If Len(aNFAvaria) > 0 .And. !TMA360VerArr(aNFAvaria)
		Return( .F. )
	EndIf
	MBrowseAuto( nOpcAuto, Aclone(aAutoCab), "DUA" )
EndIf

//---- Envio da Métrica ao finalizar a rotina
If lMetrica 
	T360EnvMet(l360Auto,.F.,0)
EndIf

SetKey( VK_F12, Nil )
RetIndex('DUA')

Return( Nil )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA360Ini   ³ Autor ³ Helio Novais        ³ Data ³ 12/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa os Ajustes Help                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA360Ini()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA360                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA360Ini()

SetKey( VK_F12, { || pergunte("TMA360",.T.) } )

CheckHLP("PTMSA360F6",{"Documento vinculado à demanda. A informação da"," viagem é obrigatória.",""},{""},{""},.T.)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360Mnt³ Autor ³ Antonio C Ferreira    ³ Data ³09.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Registro de Ocorrencias                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA360Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360Mnt( cTmsAlias, nTmsReg, nTmsOpcx, cFilOri, cViagem, cTipUso, cIdent )

Local aArea := getArea()
Local lChamadaExterna 	:= .F.

//-- EnchoiceBar
Local aTmsVisual	:= {}
Local aTmsAltera	:= {}
Local aTelOld		:= Iif( Type('aTela') == 'A', aClone( aTela ), {} )
Local aGetOld		:= Iif( Type('aGets') == 'A', aClone( aGets ), {} )
Local nOpca
Local nOpc 			:= nTmsOpcx

//-- Dialog
Local cCadOld		:= Iif( Type('cCadastro') == 'C', cCadastro, '' )
Local oTmsDlgEsp
//-- GetDados
Local aHeaOld		:= Iif( Type('aHeader') == 'A', aClone( aHeader ), {} )
Local aColOld		:= Iif( Type('aCols') == 'A', aClone( aCols ), {} )
Local nOld			:= Iif( Type('N') == 'N', n, 0 )
Local aNoFields		:= {}
Local aYesFields	:= {}

//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}
//-- Checkbox
Local oAllMark
Local aButtons    	:= {}
Local bSavKeyF4   	:= SetKey(VK_F4,Nil)
Local lAlianca    	:= TMSAlianca() //-- Indica se utiliza Alianca
Local aDocArm     	:= {}
Local aDocImp     	:= {}
Local nCnt        	:= 0
Local lDocOk      	:= .T.
Local nPosLot     	:= 0
Local lInfKm      	:= .F. //Indica se foi informada a Quilometragem.
Local lGravou     	:= .F.
Local lTm360Cpo   	:= ExistBlock('TM360CPO') //-- Permite ao usuario, Inibir campos na enchoice
Local aCpos       	:= {}
Local nCntFor     	:= 0
Local lKmObrig	    := SuperGetMv('MV_KMOBRIG',,.T.) // Obriga informar a Quilometragem do veículo.
Local lTabDFI     	:= AliasIndic("DFI")
Local lRet        	:= .T.
Local aDocEnc     	:= {}
Local lDocEntre		:= .F.
Local cTMSCOSB		:= SuperGetMV('MV_TMSCOSB',,'0')
Local cAliasDUA		:= ""
Local cQuery		:= ""
Local cSeek			:= ""
Local cFilPend		:= ""
Local cNumPend		:= ""
Local nREg			:= 0
Local nI            := 0
Local cLockKeyVG    := ""

Local aAlter    := {}
Local aOcoAju   := {}
Local aCabAju   := {}
Local aItensAju := {}

Local aColsBak  := {}

Local nPosEstOco := 0
Local nPosFilDoc := 0
Local nPosDoc    := 0
Local nPosSerie  := 0
Local nCntFor2   := 0
Local nDUAPOS    := 0
Local lExistCE   := .F.
Local lDUAPrzEnt := DUA->(ColumnPos("DUA_PRZENT")) > 0
Local lProc360   := .F.

Local lEncerra   := .T.

Local aAreaDT6   := DT6->(GetArea())

Local lIncBak    := .T.

If Type( "cCadastro" ) == "U"
	Private cCadastro	:= STR0001 //'Registro de Ocorrencias'
EndIf

Private nBaseACols  := 1

lEncViag := SuperGetMv("MV_ENCVIAG",.F.,"2") == "1" //-- Define se devera encerrar a viagem com ocorrencia para todos documentos.

//-- EnchoiceBar
Private oTmsEnch
Private aTela 	:= {}
Private aGets 	:= {}
//-- GetDados
Private aHeader     := {}
Private aCols       := {}
Private aColsDef    := {}
Private oTmsGetD
Private aTmsPosObj  := {}
//-- Checkbox
Private lAllMark    := .T.   // Usado para o controle da repeticao do campo memo DUA_MOTIVO. NAO TROQUE PARA LOCAL!!!
Private aHeaderDV4  := {}
Private aDadosDVH   := {}
Private aDadosDW4   := {}
Private aHeaderDYM  := {}

//Utilizado para estornar os apontamentos caso encerre a viagem sem efetuar os apontamentos
Private lCancelaDTW := .F.
Private lPendente   := .F.
Private lCancelaDTQ := .T.

If Type("lCiaAerea") == "U"
	Private lCiaAerea := .F.
EndIf

If Type("aRotina") == "U"
	Private aRotina := MenuDef()
EndIf

If IsInCallStack("TMSAF76")
	cLockKeyVG := "OCORXOPER" + DTQ->DTQ_VIAGEM
EndIf

M->DUA_MOTIVO := " "   // Usado para o controle da repeticao do campo memo DUA_MOTIVO. NAO EXCLUA!!!

DEFAULT cTmsAlias   := 'DUA'
DEFAULT nTmsReg		:= 1
DEFAULT nTmsOpcx    := 2
DEFAULT cFilOri     := ''
DEFAULT cViagem     := ''
DEFAULT cTipUso     := IIf(nModulo==39,"2","1")
DEFAULT cIdent      := ''

//-- Limpa o filtro por conta do browse utilizando FWBrwRelation()
DT6->(DbClearFilter())
DT6->(DbCloseArea())

If nRecursivo == 0
	lAjusta := (nTmsOpcx == 5)
EndIf

Pergunte('TMA360',.F.)
l360Auto := If (Type("l360Auto") == "U",.F.,l360Auto)

If	ValType( cViagem ) == 'C' .And. !Empty( cViagem ) .And. cTipUso == "1" //--TMS
	Inclui := nTmsOpcx == 3
	lChamadaExterna := .T.
ElseIf ValType( cTipUso ) == 'C' .And. !Empty( cTipUso ) .And. cTipUso == "2" //--OMS com Frete Embarcador
	Inclui := nTmsOpcx == 3
	lChamadaExterna := .T.
EndIf

If !l360Auto
	aNFAvaria := {}
	aIdProduto:= {}
EndIf

//-- Configura variaveis da Enchoice
RegToMemory( cTmsAlias, INCLUI )

If INCLUI .And. nRecursivo > 0
	M->DUA_FILORI := aAutoCab[Ascan(aAutoCab,{ |e| e[1] $ "DUA_FILORI"}),2]
	M->DUA_VIAGEM := aAutoCab[Ascan(aAutoCab,{ |e| e[1] $ "DUA_VIAGEM"}),2]
EndIf

If nTmsOpcx == 4 .And. !l360Auto  //--Estorno
	If !TMSAVerAge("1",DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,,,,,,,,"2",.T.,.T.)
		Return .F.
	EndIf
	If M->DUA_FILOCO != cFilAnt
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( ,, 'HELP',, "Não é permitido estornar ocorrências em filial diferente a que foi apontada.", 1, 0)
		Return( .F. )
	EndIf
EndIf

//-- Verifica a situacao da viagem.
If	ValType( cViagem ) == 'C' .And. !Empty( cViagem ) .And. cTipUso == "1" //--TMS
	If !TMSChkViag( cFilOri, cViagem, .F., .F., .F., , .F., .F., .F.,,,,,.F.,,, .T. )
		Return( .F. )
	EndIf
	If !Empty(M->DUA_FILORI) .And. !Empty(M->DUA_VIAGEM)
		cFilOri := M->DUA_FILORI
		cViagem := M->DUA_VIAGEM
	EndIf
	If !Empty(cFilOri) .And. !Empty(cViagem)
		M->DUA_FILORI := cFilOri
		M->DUA_VIAGEM := cViagem
	EndIf
ElseIf ValType( cTipUso ) == 'C' .And. !Empty( cTipUso )
	If cTipUso == "2" .And. lTabDFI
		If !Empty(cIdent) //--OMS com Frete Embarcador
			M->DUA_CODCAR := Posicione("DAK",4,xFilial("DAK")+cIdent,"DAK_COD")
			M->DUA_SEQCAR := DAK->DAK_SEQCAR
		ElseIf !Empty(DUA->DUA_IDENT) .And. nTmsOpcx != 3 //--OMS
			M->DUA_CODCAR := Posicione("DAK",4,xFilial("DAK")+DUA->DUA_IDENT,"DAK_COD")
			M->DUA_SEQCAR := DAK->DAK_SEQCAR
		EndIf
	EndIf
EndIf

//-- Trava o uso do processo para a viagem posicionada em manutenção pelo usuario.
//-- Implementado para impedir a esclusao de operacoes(TMSA350) quando houver uma
//-- manutencao de ocorrencias.
If !Empty(cLockKeyVG) .And. !LockByName(cLockKeyVG,.T.,.F.)
	Help('',1,"TMSA360LOCK1",,"Registro sendo utilizado por outro usuário.",3,1)
	Return .F.
EndIf

AAdd( aTmsVisual, 'DUA_FILOCO' )
AAdd( aTmsVisual, 'DUA_NUMOCO' )
If lTabDFI .And. cTipUso == "2" //--OMS com Frete Embarcador
	AAdd( aTmsVisual, 'DUA_CODCAR' )
	AAdd( aTmsVisual, 'DUA_SEQCAR' )
	AAdd( aTmsVisual, 'DUA_TIPUSO' )
	AAdd( aTmsVisual, 'DUA_IDENT'  )
ElseIf cTipUso == "1" //--TMS
	AAdd( aTmsVisual, 'DUA_FILORI' )
	AAdd( aTmsVisual, 'DUA_VIAGEM' )
	If __lPyme
		AAdd( aTmsVisual, 'DUA_NUMROM' )
	EndIf
EndIf

If !lChamadaExterna .And. nTmsOpcx <> 4
	If cTipUso == "1" //--TMS
		If !__lPyme //--TMS
			AAdd( aTmsAltera, 'DUA_FILORI' )
			AAdd( aTmsAltera, 'DUA_VIAGEM' )
		EndIf
		AAdd( aTmsAltera, 'DUA_NUMROM' )
		AAdd( aTmsAltera, 'DUA_FILOCO' )
		AAdd( aTmsAltera, 'DUA_NUMOCO' )
	EndIf
EndIf

If lTabDFI .And. cTipUso == "2" //--OMS com Frete Embarcador
	AAdd( aTmsAltera, 'DUA_CODCAR' )
	AAdd( aTmsAltera, 'DUA_SEQCAR' )
	AAdd( aTmsAltera, 'DUA_IDENT'  )
EndIf

aNoFields := aClone( aTmsVisual )

//-- Campos do Frete Embarcador (OMS), nao pode aparecer no TMS.
If lTabDFI .And. cTipUso == "1" //--TMS com Frete Embarcador (Tabela DFI)
	AAdd( aNoFields, 'DUA_IDENT' )
	AAdd( aNoFields, 'DUA_CODCAR')
	AAdd( aNoFields, 'DUA_SEQCAR')
	AAdd( aNoFields, 'DUA_TIPUSO')
EndIf

If nTmsOpcx == 3 .Or. nTmsOpcx == 5
	AAdd( aNoFields, 'DUA_ESTOCO' )
EndIf

If lTm360Cpo
	aCpos := ExecBlock("TM360CPO",.F.,.F. )
	If ValType(aCpos) =="A"
		For nCntFor:=1 to Len(aCpos)
			AAdd(aNoFields,aCpos[nCntFor]) // Identifica se existe algum campo criado pelo usuario e nao exibe na getdados
		Next nCntFor
		AAdd(aTmsVisual,'NOUSER') // Identifica se existe algum campo criado pelo usuario e nao exibe na enchoice
	EndIf
EndIf

If cTipUso == "2" .And. lTabDFI //--OMS com Frete Embarcador
	AAdd( aNoFields, 'DUA_QTDVOL' )
	AAdd( aNoFields, 'DUA_VOLORI' )
	AAdd( aNoFields, 'DUA_PESO' )
	AAdd( aNoFields, 'DUA_FILVTR' )
	AAdd( aNoFields, 'DUA_NUMVTR' )
	AAdd( aNoFields, 'DUA_FILPND' )
	AAdd( aNoFields, 'DUA_CODCAR' )
	AAdd( aNoFields, 'DUA_SEQCAR' )
	AAdd( aNoFields, 'DUA_CODMOT' )
	AAdd( aNoFields, 'DUA_NUMPND' )
	AAdd( aNoFields, 'DUA_FILORI' )
	AAdd( aNoFields, 'DUA_VIAGEM' )
	AAdd( aNoFields, 'DUA_IDENTR' )
EndIf

//-- Indiferente do Modulo nao carrega o DUA_SERTMS.
AAdd( aNoFields, 'DUA_SERTMS' )
AAdd( aNoFields, 'DUA_NUMROM' )

If lAjusta
	Aadd(aAlter, "DUA_CODOCO")
	If lDUAPrzEnt 
		Aadd(aAlter, "DUA_PRZENT")
	EndIf	
EndIf

//-- Configura variaveis da GetDados
If lTabDFI .And. cTipUso == "2" //--OMS com Frete Embarcador
	TMSFillGetDados( nTmsOpcx, 'DUA', 8, xFilial( 'DUA' ) + M->DUA_FILOCO + M->DUA_NUMOCO + M->DUA_TIPUSO + M->DUA_IDENT + M->DUA_SEQOCO, { ||  DUA->(DUA_FILIAL + DUA->DUA_FILOCO + DUA->DUA_NUMOCO +DUA_TIPUSO + DUA_IDENT + DUA_SEQOCO) },;
		{ || .T. }, aNoFields,	aYesFields )
ElseIf cTipUso == "1" //--TMS
	TMSFillGetDados( nTmsOpcx, 'DUA', 1, xFilial( 'DUA' ) + M->DUA_FILOCO + M->DUA_NUMOCO + M->DUA_FILORI + M->DUA_VIAGEM, { ||  DUA->(DUA_FILIAL + DUA->DUA_FILOCO + DUA->DUA_NUMOCO +DUA_FILORI + DUA_VIAGEM) },;
		{ || .T. }, aNoFields,	aYesFields )
EndIf

//-- Verifica se existem NFs com Avarias
If nTmsOpcx <> 3 .And. !lAjusta
	TMSA360CarNF(M->DUA_FILOCO, M->DUA_NUMOCO, , M->DUA_FILPND, M->DUA_NUMPND)
EndIf

If !INCLUI .Or. ( lChamadaExterna .And. ( Len(aCols)>1 .Or. !Empty(GDFieldGet( 'DUA_SEQOCO', 1 ))) )
	nBaseACols := Len(aCols) + 1
EndIf

//-- Inicializa o item da getdados se a linha estiver em branco.
If Len( aCols ) == 1 .And. Empty( GDFieldGet( 'DUA_SEQOCO', 1 ) )
	GDFieldPut( 'DUA_SEQOCO', StrZero(1,Len(DUA->DUA_SEQOCO)), 1 )
	GDFieldPut( 'DUA_MOTVO' , " ", 1 )
	aColsDef := aClone(aCols)
EndIf

AAdd(aButtons,	{'PESQUISA', {|| TmsA360Psq() }, STR0014 , STR0014 }) //"Pesquisa"

If cTipUso == "1" //--Viagem
	DTQ->(DbSetOrder(2))   // DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
	DTQ->(DbSeek(xFilial("DTQ")+M->( DUA_FILORI+DUA_VIAGEM )))   // Posiciona na alteracao.
EndIf

If nTmsOpcx <> 3
	If cTipUso == "1" //Viagem
		If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS))
			//-- Tranporte Aereo
			If DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))
				bSavKeyF4 := SetKey( VK_F4 ,{||TA360ConfEmb(nTmsOpcx)})
				AAdd(aButtons	, {'AVIAO'  ,{||TA360ConfEmb(nTmsOpcx)}, STR0015 , STR0016 }) //"Confirmação de Embarque Aéreo - <F4>"
			//-- Transporte Fluvial
			ElseIf DTQ->DTQ_TIPTRA == StrZero(3,Len(DTQ->DTQ_TIPTRA)) .And. FindFunction("ALIASINDIC") .And. AliasIndic("DW4")
				bSavKeyF4 := SetKey( VK_F4 ,{||TA360EmbFlu(nTmsOpcx)})
				AAdd(aButtons	, {'DEVOLNF',{||TA360EmbFlu(nTmsOpcx)}, STR0017 , STR0016 }) //"Confirmação de Embarque Fluvial - <F4>"
			EndIf
		EndIf
	EndIf
	//-- Botao para envio de e-mail atraves da visualizacao da Ocorrencia
	If nTmsOpcx == 2
		AAdd(aButtons,{'BMPPOST',{||TMSA360Mail(cFilOri,cViagem)},STR0032,STR0032}) //"E-mail"
	EndIf
EndIf

If lAjusta .And. nRecursivo == 0
	aColsAnt := Aclone(aCols)
EndIf

If !l360Auto
	//-- Ponto de entrada para incluir botao na enchoicebar
	If lTM360BUT
		aUsrButtons := ExecBlock("TM360BUT",.F.,.F.,{nTmsOpcx})
		If ValType(aUsrButtons) == "A"
			For nCntFor := 1 To Len(aUsrButtons)
				AAdd(aButtons,aUsrButtons[nCntFor])
			Next
		EndIf
	EndIf

	AAdd(aButtons, {'CODBR', {||TM360CodBr()} , STR0088 , STR0088 }) //-- Leitura por cod. barras
	bSavKeyF5:=	SetKey(VK_F5,{|| TM360CodBr()})

	AAdd(aButtons, {'CODBR', {|| TMSA360NF(M->DUA_FILOCO, M->DUA_NUMOCO,nTmsOpcx,Posicione("DT2",1,xFilial("DT2")+ GdFieldGet("DUA_CODOCO",n),"DT2->DT2_TIPPND"),.F.,.T.,Posicione("DT2",1,xFilial("DT2")+ GdFieldGet("DUA_CODOCO",n),"DT2->DT2_TIPOCO"))} , STR0023 , STR0023 }) //-- "Notas Fiscais"
	bSavKeyF6:=	SetKey(VK_F6,{|| TMSA360NF(M->DUA_FILOCO, M->DUA_NUMOCO,nTmsOpcx,Posicione("DT2",1,xFilial("DT2")+ GdFieldGet("DUA_CODOCO",n),"DT2->DT2_TIPPND"),.F.,.T.,Posicione("DT2",1,xFilial("DT2")+ GdFieldGet("DUA_CODOCO",n),"DT2->DT2_TIPOCO"))})

	AAdd(aButtons, {'CODBR', {|| TMSA360Vis(M->DUA_FILDOC,M->DUA_DOC,M->DUA_SERIE)},STR0136,STR0136})	//-- "Imagem"
	bSavKeyF7:=	SetKey(VK_F7,{|| TMSA360Vis(M->DUA_FILDOC,M->DUA_DOC,M->DUA_SERIE)})

	//-- Dimensoes padroes
	aSize := MsAdvSize()
	AAdd( aObjects, { 35, 50, .T., .T. } )
	AAdd( aObjects, { 235, 235, .T., .T. } )
	AAdd( aObjects, { 30, 30, .T., .T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)

	DEFINE MSDIALOG oTmsDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oTmsEnch		:= MsMGet():New( cTmsAlias, nTmsReg, nTmsOpcx,,,, aTmsVisual, aTmsPosObj[1],aTmsAltera, 3,,,,,,.T. )


	//        MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oTmsGetD := MSGetDados():New(aTmsPosObj[ 2, 1 ], aTmsPosObj[ 2, 2 ],aTmsPosObj[ 2, 3 ], aTmsPosObj[ 2, 4 ], Iif(nTmsOpcx == 5,4,nTmsOpcx),{||TMSA360LinOk(,nTmsOpcx)},'AllwaysTrue',"+DUA_SEQOCO/DUA_DATOCO/DUA_HOROCO/DUA_CODMOT/DUA_MOTIVO/DUA_CODOCO/DUA_DESOCO",.T.,If(nTmsOpcx == 5,aAlter,Nil),  ,  ,  ,  ,  ,  ,  ,  )

	oPanel   := TPanel():New(aTmsPosObj[3,1],aTmsPosObj[3,2],"",oTmsDlgEsp,,,,,CLR_WHITE,(aTmsPosObj[3,4]-aTmsPosObj[3,2]), (aTmsPosObj[3,3]-aTmsPosObj[3,1]), .T.)

	@ 005,005 CHECKBOX oAllMark VAR lAllMark PROMPT STR0018 SIZE 168, 08; //"Repetir o conteúdo na proxima sequencia"
	ON CLICK(TmsA360Rep(@oTmsGetD, @lAllMark)) OF oPanel PIXEL

	ACTIVATE MSDIALOG oTmsDlgEsp ON INIT EnchoiceBar(oTmsDlgEsp,{||Iif( oTmsGetD:TudoOk() .And. TMSA360TOk(nTmsOpcx), (nOpca := 1,oTmsDlgEsp:End()), (nOpca :=0, .F.))},{||nOpca:=0,oTmsDlgEsp:End()},,aButtons )
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validando dados para rotina automatica                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTmsOpcx == 4
		nOpc := 5
	EndIf

	If lAjusta .And. nRecursivo == 1
		aColsBak := Aclone(aCols)
	EndIf

	If EnchAuto(cTMSAlias,aAutoCab,,nOpc,aTMSVisual,{|| Obrigatorio(aGets,aTela)}) .And. MsGetDAuto(aAutoItens,{||TMSA360LinOk(,nTmsOpcx)},{|| TMSA360TOk(nTmsOpcx)},aAutoCab,nOpc)

		If lAjusta .And. nRecursivo == 1
			aCols := Aclone(aColsBak)
		EndIf

		If nOpc == 5 .And. !TMSA360VLD('M->DUA_ESTOCO')
			lMsErroAuto := .T.
		Else
			n := 1
			nOpca := 1
		EndIf

	EndIf
EndIf

If	nOpca == 1 .And. nTmsOpcx <> 2
	//-- Quando for ajuste da ocorrência estorna a ocorrência anterior e lança a nova ocorrência
	If lAjusta .And. nRecursivo == 0
		aColsNew := Aclone(aCols)
		//-- Monta vetor das ocorrências que serão canceladas
		aOcoAju   := TMA360Vet(1)
		aCabAju   := aOcoAju[1]
		aItensAju := aOcoAju[2]
		If !Empty(aCabAju) .And. !Empty(aItensAju)
			//-- Estorna a ocorrência anterior
			nRecursivo := 1
			lProc360 := ProcIteOco(aCabAju,aItensAju,aNFAvaria,6,.F.,Iif(l360Auto,.F.,.T.))   
		EndIf		
		If lProc360  //Estorno efetuado com sucesso
			//-- Monta vetor das ocorrências que serão lançadas
			aOcoAju   := TMA360Vet(2)
			aCabAju   := aOcoAju[1]
			aItensAju := aOcoAju[2]
			If !Empty(aCabAju) .And. !Empty(aItensAju)
				//-- Lança a nova ocorrência
				nRecursivo := 2
				lProc360 := ProcIteOco(aCabAju,aItensAju,aNFAvaria,3,.F.,Iif(l360Auto,.F.,.T.))
			EndIf
		EndIf	
		lAjusta    := .F.
		nRecursivo := 0
		aColsAnt   := {}
		aColsNew   := {}
		aNFAvaria  := {}
	Else
		Begin Transaction
			If	nTmsOpcx == 4  //--Estorno
				If cTipUso == "1" //--TMS

					If lAjusta .And. nRecursivo == 1
						nPosFilDoc := Ascan(aHeader,{|x| x[2] == "DUA_FILDOC"})
						nPosDoc    := Ascan(aHeader,{|x| x[2] == "DUA_DOC"})
						nPosSerie  := Ascan(aHeader,{|x| x[2] == "DUA_SERIE"})
						nPosEstOco := Ascan(aHeader,{|x| x[2] == "DUA_ESTOCO"})
						If (nPosEstOco := Ascan(aHeader,{|x| x[2] == "DUA_ESTOCO"})) > 0 .And. (nPosFilDoc := Ascan(aHeader,{|x| x[2] == "DUA_FILDOC"})) > 0 .And. ;
						   (nPosDoc    := Ascan(aHeader,{|x| x[2] == "DUA_DOC"})) > 0 .And. (nPosSerie  := Ascan(aHeader,{|x| x[2] == "DUA_SERIE"})) > 0
							aEval(aCols,{|x| x[nPosEstOco] := "2"})
							For nCntFor2 := 1 To Len(aAutoItens)
								 If (nDUAPos := Ascan(aCols,{|x| x[nPosFilDoc] + x[nPosDoc] + x[nPosSerie] == aAutoItens[nCntFor2,6,2] + aAutoItens[nCntFor2,7,2] + aAutoItens[nCntFor2,8,2]})) > 0
								 	aCols[nDUAPos,nPosEstOco] := "1"
								 EndIf
							Next nCntFor2
						EndIf
					EndIf

					lRet:= TmsA360Est( M->DUA_FILOCO, M->DUA_NUMOCO, M->DUA_FILORI, M->DUA_VIAGEM, @aDocEnc, M->DUA_NUMROM )
					If Ascan(aCols,{ | e | e[GDFieldPos('DUA_ESTOCO')]=='1'}) > 0  //-- Sempre que uma ocorrencia for estornada executa o Pto TM360GRV
						lGravou := .T.
						If !lRet
							lGravou:= .F.
						EndIf
					EndIf
				ElseIf cTipUso == "2" .And. lTabDFI //--OMS com Frete Embarcador
					DT2->(DbSetOrder(1))
					DT2->(DbSeek(xFilial("DT2")+M->DUA_NUMOCO))
					If DT2->DT2_TIPOCO == '04' //--Retorna Documento
						MsgAlert("Operacao nao permitida, carga de reentrega ja gerada")
					Else
						TA360EsOMS( M->DUA_FILOCO, M->DUA_NUMOCO, M->DUA_IDENT )
					EndIf
				EndIf
			Else
				If lTabDFI .And. cTipUso == "2" //--OMS com Frete Embarcador
					lGravou := TA360GrOms(nTmsOpcx, M->DUA_IDENT, M->DUA_TIPUSO, M->DUA_FILOCO, M->DUA_NUMOCO)
				ElseIf cTipUso == "1" //--TMS
					// Verficar se é redespacho, se sim, nao deixa caso status esteja em aberto
					// o mesmo tem q estar com status indicado p/ entrega.
					lGravou := TMSA360Grv(M->DUA_FILOCO, M->DUA_NUMOCO, M->DUA_FILORI, M->DUA_VIAGEM, nTmsOpcx, nBaseACols, aDocArm, @aDocImp, @aDocEnc, @lDocEntre, M->DUA_NUMROM,@lExistCE )
				EndIf
	
				If lGravou
					If cTipUso == "1" //TMS
						If !lDocEntre      //Apontamento de ocorrencia Gera Pendencia/Indenizacao para um documento ja entregue, nao atualiza dados
							lInfKm := TMSA360KmVei()
						EndIf
						If (lKmObrig .And. !lInfKm) .And. !lDocEntre // Km Obrigatorio e nao preencheu km estorna a gravacao da Ocorrencia
							nTmsOpcx := 4   // Forcando como estorno para nao gerar documentos de armazenagem.
							lGravou  := .F. // Forcando status de nao gravacao do item para nao executar o ponto de entrada
							If	__lSX8
								RollBackSX8()
							EndIf
							DisarmTransaction()
						Else//-- Verifica se devera encerrar a viagem.
							If DTQ->(ColumnPos("DTQ_CODAUT")) > 0
								If !Empty(M->DUA_VIAGEM) .And. DTQ->(DbSeek(xFilial("DTQ") + M->DUA_FILORI + M->DUA_VIAGEM))
									lEncerra := TMSA360Aut(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_CODAUT,"TMSA340",lEncViag)
								Else
									lEncerra := lEncViag
								EndIf
							Else
								lEncerra := lEncViag
							EndIf

							DTQ->(DbSetOrder(2))
							If !IsInCallStack("TMSAE81") .And. lEncerra .And. DTQ->(DbSeek(xFilial("DTQ")+M->DUA_FILORI+M->DUA_VIAGEM)) .And. TMSA360Enc(M->DUA_FILORI,M->DUA_VIAGEM,lInfKm) .And. !lDocEntre
								If (IsInCallStack("TMSAF76") .And. DTQ->DTQ_STATUS == StrZero(4,Len(DTQ->DTQ_STATUS))) .Or. (!IsInCallStack("TMSAF76") .And. DTQ->DTQ_STATUS <> StrZero(3,Len(DTQ->DTQ_STATUS)))
									TMSA340Grv(.T.)
								EndIf
							EndIf
							If __lSX8
								ConfirmSX8()
							EndIf
						EndIf
					EndIf
				Else
					If	__lSX8
						RollBackSX8()
					EndIf
					DisarmTransaction()
				EndIf
			EndIf
		End Transaction

		//-- Chama tela de manutenção dos dados de comprovante de entrega para gerar o evento para a SEFAZ
		//-- Essa tela permite que o usuário ao gravar o apontamento de ocorrência do tipo '01-Encerra processo'
		//-- atualize os dados da tabela DLY com o nome do recebedor da carga, rg/cpf e endereço(URL\Link) da imagem do comprovante.
		If !l360Auto .And. lGravou .And. nTmsOpcx == 3 .And. lExistCE .And. ExistFunc("TMSAE71")
			If Aviso(STR0055,STR0130,{STR0131,STR0132},2) == 1 //-- ## Atenção ### "Existe(m) registro(s) de evento de comprovante de entrega para serem atualizado(s). Deseja Realizá-lo agora?" ### SIM ### NAO
				lIncBak := Inclui
				TMSAE71(1,M->({DUA_FILOCO,DUA_FILOCO,DUA_NUMOCO,DUA_NUMOCO}))
				Inclui  := lIncBak
			EndIf
		EndIf

		//-- Gera documentos de armazenagem.
		If	nTmsOpcx <> 4
			For nCnt := 1 To Len(aDocArm)
				//-- Posiciona no documento original
				DT6->(DbGoto(aDocArm[nCnt,2]))
				If lAlianca
					lDocOk := Tmsa500(.F.,aDocArm[nCnt,1],10) // Quando utiliza Alianca
				Else
					lDocOk := Tmsa500(.F.,aDocArm[nCnt,1],9) // Quando nao utiliza Alianca
				EndIf
				If !lDocOk
					DTP->(DbSetOrder(2))
					If DTP->(DbSeek(xFilial("DTP")+cFilAnt+aDocArm[nCnt,1]))
						RecLock("DTP",.F.)
						DTP->DTP_QTDLOT -= 1
						DTP->DTP_QTDDIG -= 1
						If DTP->DTP_QTDLOT == 0
							DTP->(dbDelete())
							nPosLot := Ascan(aDocImp, { | e | aDocArm[nCnt,1] $ e[1] })
							If nPosLot > 0
								Adel(aDocImp[nPosLot],1)
								Asize(aDocImp,Len(aDocImp)-1)
								AAdd(aDocImp,{STR0030}) //"Foram encontrados problemas durante a geracao dos documentos de armazenagem."
								AAdd(aDocImp,{STR0031}) //"Recomendamos verificar as mensagens, estornar as ocorrencias e efetuar o processo novamente."
							EndIf
						EndIf
						MsUnLock()
					EndIf
				EndIf
			Next nCnt
			If !Empty(aDocImp)
				TmsMsgErr(aDocImp)
			EndIf
		EndIf
		If lGravou
			TMS360ADCE(aDocEnc,nTmsOpcx)
	
			For nI:= 1 To Len(aDocEnc)
				//Atualiza status de entrega de doctos de reentrega/devolucao
				If FindFunction("TmsPsqDY4") .And. TmsPsqDY4(aDocEnc[nI,1], aDocEnc[nI,2], aDocEnc[nI,3])
					A360AtuNf(aDocEnc)
				Endif
			Next
	
			If ExistBlock('TM360GRV')
				ExecBlock('TM360GRV',.F.,.F.,{nTmsOpcx,M->DUA_FILOCO,M->DUA_NUMOCO,M->DUA_FILORI,M->DUA_VIAGEM})
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se a funcionalidade de e-mail esta ativa³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TMSA360Mail(cFilOri,cViagem)
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza Status da tabela de Redespacho  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Tmsa360Red( nTmsOpcx )
	
		   	//Conciliacao Automatica Sobras e Faltas
		   	If cTMSCOSB <> '0' .And. MV_PAR02 == 2 .And. !l360Auto .And. nTmsOpcx <> 4 .And. Len(aIdProduto) > 0
		   		nReg    := 0
		   		cFilPend:= ""
		   		cNumPend:= ""
	
		   		cAliasDUA := GetNextAlias()
				cQuery := " SELECT DUA.DUA_FILPND, DUA.DUA_NUMPND "
				cQuery += "   FROM  " + RetSqlName("DUA") + " DUA "
	
				cQuery += " INNER JOIN " + RetSqlName("DT2") + " DT2 "
				cQuery += " 	ON DT2.DT2_FILIAL = '" + xFilial("DT2") + "' "
				cQuery += "    AND DT2.DT2_CODOCO = DUA.DUA_CODOCO  "
				cQuery += "    AND DT2.DT2_TIPPND IN ('" + StrZero(1, Len(DT2->DT2_TIPPND)) + "','" + StrZero(3, Len(DT2->DT2_TIPPND)) + "') "   //Sobra ou Falta
				cQuery += "    AND DT2.D_E_L_E_T_ = ' ' "
	
				cQuery += " INNER JOIN " + RetSqlName("DYZ") + " DYZ "
				cQuery += " 	ON DYZ.DYZ_FILIAL = '" + xFilial("DYZ") + "' "
				cQuery += "   AND DYZ.DYZ_FILPND = DUA.DUA_FILPND "
				cQuery += "   AND DYZ.DYZ_NUMPND = DUA.DUA_NUMPND "
				cQuery += "   AND DYZ.D_E_L_E_T_ = ' ' "
	
				cQuery += "  WHERE DUA.DUA_FILIAL = '" + xFilial("DUA") + "' "
				cQuery += "    AND DUA.DUA_FILOCO = '" + M->DUA_FILOCO + "' "
				cQuery += "    AND DUA.DUA_NUMOCO = '" + M->DUA_NUMOCO + "' "
				cQuery += "    AND DUA.D_E_L_E_T_ = ' ' "
				cQuery += "    GROUP BY DUA.DUA_FILPND, DUA.DUA_NUMPND  "
	
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDUA, .F., .T.)
				While (cAliasDUA)->(!Eof())
					If Empty(cNumPend)
						cFilPend:= (cAliasDUA)->DUA_FILPND
						cNumPend:=  (cAliasDUA)->DUA_NUMPND
					Else
						cNumPend+= ", " + (cAliasDUA)->DUA_NUMPND
					EndIf
					nReg++
					(cAliasDUA)->(DbSkip())
				EndDo
				(cAliasDUA)->(DbCloseArea())
	
				If nReg > 0 .And. !Empty(cNumPend)
					SaveInter()
					If nReg == 1
						DYZ->(DbSetOrder(1))
						If	DYZ->(DbSeek( cSeek := xFilial('DYZ') + cFilPend + cNumPend ))
							FWExecView(STR0028, 'TMSA541', 4, , { || .T. } )
						EndIf
					Else
						//Quando houver mais de uma pendencia, chamara a rotina Conciliação de Sobras e Faltas com filtro
						TMSA541(,,4,cFilPend,cNumPend )
					EndIf
					RestInter()
		   		EndIf
			EndIf
		EndIf
	EndIf
Else
	If	__lSX8
		RollBackSX8()
	EndIf
EndIf

//---- Envio da Métrica ao clicar no SAIR, onde o TMSA360 é chamada por outra rotina.
If lMetrica //.And. (nTmsOpcx == 3  .Or. nTmsOpcx == 4) 
	T360EnvMet(l360Auto,lChamadaExterna,nTmsOpcx)
EndIf

If !Empty( cCadOld )
	cCadastro := cCadOld
EndIf

If	!Empty( aTelOld )
	aTela		:= aClone( aTelOld )
	aGets		:= aClone( aGetOld )
EndIf

If	!Empty( aHeaOld )
	aHeader	:= aClone( aHeaOld )
	aCols	:= aClone( aColOld )
	n		:= nOld
EndIf

cViagem := Nil    // Usado para resolver um grave problema. NAO EXCLUA.

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf
//-- Libera registro para uso
If !Empty(cLockKeyVG)
	UnLockByName(cLockKeyVG,.T.,.F.)
EndIf

bSavKeyF4 := SetKey(VK_F4,Nil)
bSavKeyF5 := SetKey(VK_F5,Nil)

If nTmsOpcx == 4  .Or. nTmsOpcx == 3 // Estorno ou Apontamento
	SetKey(VK_F6,Nil)  // Remove a opção F6 da tela principal de Ocorrências
EndIf

DbSelectArea("DUA")
RestArea(aArea)

//-- Retorna a area por conta da limpeza de filtro
If IsInCallStack("TMSA170")
	RestArea(aAreaDT6)
EndIf

Return If(lChamadaExterna, nOpcA == 1, nOpca)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA360Rep³ Autor ³ Antonio C Ferreira    ³ Data ³25.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Controla se repete os dados na proxima linha do aCols      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA360Rep()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA360Rep(oTmsGetD, lAllMark)

If Empty(cInicPos)
	cInicPos := oTmsGetD:cInicPos
	cItem    := Substr(cInicPos, 1, At("/",cInicPos)-1)
EndIf

If !lAllMark
	oTmsGetD:cInicPos := cItem
Else
	oTmsGetD:cInicPos := cInicPos
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360Vld³ Autor ³ Antonio C Ferreira    ³ Data ³09.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes do sistema                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA360Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Campo.                                             ³±±
±±³          ³ ExpL1 - Limpa o campo Documento.                           ³±±
±±³          ³ ExpL2 - Exibe Tela Identificacao Produto                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360Vld(cCampo,lLimpaDoc,lIdProd,lTMS360TOk, nOpcVld)
Local aMsgErr	  := {}
Local cTipOco	  := ''
Local cSeek		  := ''
Local lRet		  := .T.
Local cSerTMS     := ''
Local cFilVtr     := ''
Local cNumVtr     := ''
Local cDescri     := ''
Local cFileLog    := ''
Local cOcorCfe    := SuperGetMv('MV_OCORCFE',,"")
Local lEntSoco    := SuperGetMv('MV_ENTSOCO',,.F.) // Gera Contrato de Carreteiro para Viagens de Entrega sem Registro de Ocorrencia (DUA) ?
Local lColSoco    := SuperGetMv('MV_COLSOCO',,.F.) // Gera Contrato de Carreteiro para Viagens de Coleta sem Registro de Ocorrencia (DUA) ?
Local nOpc        := 0
Local nX          := 0
Local aAreaDT6    := DT6->(GetArea())
Local aAreaDUA    := {}
Local aAreaDUD    := {}
Local aDoc        := {}
Local lVgeMod3    := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)
Local cProg       := Iif(lVgeMod3,"TMSAF60",FunName()) //-- Programa que chamou a rotina de ocorrencias
Local lDocFinCanc := .F.
Local lFilDca     := .F.
Local lSobra      := .F.
Local cAtivChg    := SuperGetMV('MV_ATIVCHG',,'')
Local cAtivSai    := SuperGetMV('MV_ATIVSAI',,'')
Local cAliasQry   := ""
Local cHora       := ""
Local aArea       := GetArea()
Local dDataPre    := Ctod("")
Local cHoraPre    := ""
Local dDataChg    := Ctod("")
Local cHoraChg    := ""
Local cQuery      := ""
Local cCatOco     := ''
Local nHorAju     := 0
Local cHoratr     := ''
Local lFoundDF6   := .F.
Local cFilDoc, cDoc, cSerie, cSeekDUD
Local lTabDFI     := AliasIndic("DFI")
Local cSeekDAI    := ""
Local nVolume     := 0
Local nPeso       := 0
Local aRota       := {}
Local lLibVgBlq	  := SuperGetMV('MV_LIBVGBL',,.F.)  //-- Libera Encerramento de viagens com ocorrencia do tipo
Local lEncerr	  := .F.                                                     //-- Bloqueia Documento.
Local lDocRed     := .F.
Local lDocEntre   := .F.
Local nTmsdInd    := SuperGetMv('MV_TMSDIND',.F.,0) // Dias permitidos para indenizacao apos o documento entregue
Local lTMSGFE     := SuperGetMv("MV_TMSGFE",,.F.)
Local lValSerTMS  := .F.		// Valida o serviço TMS
Local lDT5			 := .F.  // Recebe se o documento é de coleta
Local aAreaDT2    := {}
Local lTMS3GFE    := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local cCodFor     := ""
Local cLojFor     := ""
Local aDocSrvAdd  := {}
Local lRotDUD     := Iif(FindFunction('TMSChvDUD'),.T.,.F.)
Local cOcorBx    := SuperGetMv('MV_OCORRDP',,"")
Local lOcoRed     := .F.
Local lRetSel		:= .T.
Local aHelpErr		:= {}
Local cHelpErr		:= ""
Local cSerDoc       := ""
Local lITmsDmd      := SuperGetMv("MV_ITMSDMD",,.F.)
Local aAreaDTA      := DTA->(GetArea())
Local lDUAPrzEnt    := DUA->(ColumnPos("DUA_PRZENT")) > 0
Local aAreaBkp      := {}
Local lJob360       := IsBlind()   

Default cCampo	  := ReadVar()
Default lLimpaDoc := .T.
Default lIdProd   := .T.
Default lTMS360TOk := .F.
Default nOpcVld    := 0

l360Auto := Iif(Type("l360Auto") == "U",.F.,l360Auto)

nOpc     := Iif(cCampo != "M->DUV_ODOENT" .And. !l360Auto,oTMSGetD:oBrowse:nOpc,0)

If	( cCampo == 'M->DUA_VIAGEM' .Or. cCampo == 'M->DUA_FILORI' ) .And. !Empty(M->DUA_VIAGEM)

	If !TMSChkViag( M->DUA_FILORI, M->DUA_VIAGEM, .F., .F., .F., , .F., .F., .F.,,,,,.F.,,, .T. )

		M->DUA_FILORI := Space(FWGETTAMFILIAL)
		M->DUA_VIAGEM := Space(Len(M->DUA_VIAGEM))

		Return( .F. )
	EndIf

	If IsInCallStack('TMSAF76') .And. !IsInCallStack('TMA360VlDoc') .And. !l360Auto
		 lRet := TM360VlPan(M->DUA_FILORI,M->DUA_VIAGEM,,,,,DTQ->DTQ_SERTMS)
		 Return ( lRet )
	EndIf

		//------------------------------------------------------------------------------------------
		//-- Início - Tratamento Rentabilidade/Ocorrência
		//------------------------------------------------------------------------------------------
		If Empty(M->DUA_FILORI) .Or. Empty(M->DUA_VIAGEM)

			DT2->(DbSetOrder(1))
			If	MsSeek(xFilial('DT2') + GdFieldGet('DUA_CODOCO',n),.F.)
				If 	( Empty(DT2->DT2_CDTIPO ) .And.;
				(DT2->DT2_TIPOCO == StrZero(17,Len(DT2->DT2_TIPOCO)) .Or. ;
				 DT2->DT2_TIPOCO == StrZero(18,Len(DT2->DT2_TIPOCO))))

				lRet := .f.
				Help('',1,'TMSA360D3') //"Obrigatório Informar Filial Origem e Número Da Viagem Para Correta Geração Do Contrato De Carreteiro!"

				EndIf
			EndIf
		EndIf
		//------------------------------------------------------------------------------------------
		//-- Fim    - Tratamento Rentabilidade/Ocorrência
		//------------------------------------------------------------------------------------------

ElseIf	cCampo == 'M->DUA_NUMROM'

	If !Empty(M->DUA_NUMROM)
		lRet := ExistCpo("DYB",M->DUA_NUMROM)
	EndIf

	If lRet .and. !l360Auto
		aCols := aClone(aColsDef)
		oTmsGetD:Refresh()
	EndIf
ElseIf cCampo == "M->DUA_CODOCO"

	If nModulo == 43 //--TMS

		//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
		aAreaDT2 := DT2->(GetArea())
		cFilDoc := GDFieldGet("DUA_FILDOC",n)
		cDoc    := GDFieldGet("DUA_DOC"   ,n)
		cSerie  := GDFieldGet("DUA_SERIE" ,n)
		cCodOco := M->DUA_CODOCO
		If !Empty(cFilDoc + cDoc + cSerie) .And. !Empty(cCodOco) .And. DT2->(DbSeek(xFilial("DT2") + cCodOco))
			If DT2->DT2_SERTMS == StrZero(1,Len(DT2->DT2_SERTMS))
				If !TMSAVerAge("3",,,,,,,,,cFilDoc,cDoc,,"2",.T.,.T.)
					Return .F.
				EndIf
			Else
				If !TMSAVerAge("1",cFilDoc,cDoc,cSerie,,,,,,,,,"2",.T.,.T.)
					Return .F.
				EndIf
			EndIf
		EndIf
		RestArea(aAreaDT2)

		DTQ->(DbSetOrder(2))   // DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
		DTQ->(DbSeek(xFilial("DTQ")+M->DUA_FILORI+M->DUA_VIAGEM))

		DT2->(DbSetOrder(1))
		lRet := DT2->(DbSeek(xFilial("DT2")+ &(ReadVar()) ))
		cCatOco := DT2->DT2_CATOCO
		cTipOco := DT2->DT2_TIPOCO
		If !Empty(DT2->DT2_SERTMS)
			cSerTMS := DT2->DT2_SERTMS
		Else
			If !Empty(GdFieldGet("DUA_FILDOC",n)) .AND. !Empty(GdFieldGet("DUA_DOC",n)) .AND. !Empty(GdFieldGet("DUA_SERIE",n))
				cSerTMS:= TMSA360DUD(GdFieldGet("DUA_FILDOC",n),GdFieldGet("DUA_DOC",n),GdFieldGet("DUA_SERIE",n))
			Endif
		Endif
		//-- Viagens encerradas somente poderao receber ocorrencias do tipo "informativa"
		If	DTQ->DTQ_STATUS == StrZero(3,Len(DTQ->DTQ_STATUS)) .And.;
			cTipOco != StrZero(5,Len(DT2->DT2_TIPOCO)) .And.;
		  	!lLibVgBlq .And.;  // Desbloquear viagens com Status de Bloqueado
		  	aScan( aRecDep, cTipOco) == 0 .And. ;	//-- Tratamento Rentabilidade/Ocorrencia
		  	!lAjusta	//-- A rotina de ajuste permite a gravação de nova ocorrencia
		   	If cTipOco $ "06/09" .And. nTmsdInd > 0 //Desbloquear Indenizacao conforme prazo de dias no parametro
		   		lRet:= .T.
		   	ElseIf (lTmsRdpU .And. DTQ->DTQ_TIPVIA == StrZero(5,Len(DTQ->DTQ_TIPVIA)))  .Or. !Empty(DTQ->DTQ_CHVEXT)
		   		lRet:= .T.
		   	Else
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Help('',1,'TMSA36062') //"Viagens encerradas somente poderao receber ocorrencias do tipo "informativa"
				Return( .F. )
			EndIf
		EndIf
		//-- Nao permitir informar ocorrencias de Retorno para viagens em Aberto
		//-- Se viagem de Redespacho nao valida.
		If !Empty(DTQ->DTQ_FILORI) .And. !Empty(DTQ->DTQ_VIAGEM)
			If cTipOco == StrZero(4,Len(DT2->DT2_TIPOCO)) .And. ;
				!(	DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) .Or. ;              //-- Em Viagem
				DTQ->DTQ_STATUS == StrZero(4,Len(DTQ->DTQ_STATUS)) ) .And. !lLibVgBlq ; //-- Chegada Filial
				.And. Empty(DTQ->DTQ_CHVEXT)
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Help("",1,"TMSA36053") //--Nao e permitido informar ocorrências de Retorno para viagens com Status "Encerrado"			
				Return( .F. )
			EndIf
		EndIf
		//-- Nao permitir informar ocorrencias para viagens em Aberto/Fechada
		If !Empty(DTQ->DTQ_FILORI) .And. !Empty(DTQ->DTQ_VIAGEM)
			If (cTipOco <> StrZero(5,Len(DT2->DT2_TIPOCO)) .And. (cTipOco == StrZero(12,Len(DT2->DT2_TIPOCO)) .And. !IsInCallStack("TMSA050MNT"))) .And. ;
				(	DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) .Or. ;
				DTQ->DTQ_STATUS == StrZero(5,Len(DTQ->DTQ_STATUS)) )
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Help("",1,"TMSA360B3") //Não e permitido informar ocorrencias diferente de informativa para viagens com Status "Em Aberto" ou "Fechada"
				Return( .F. )
			EndIf
		EndIf
		//-- Permitir a digitacao de ocorrencias sem viagens, para todos tipos de transporte
		If Empty(M->DUA_FILORI) .And. Empty(M->DUA_VIAGEM)
			If DT2->DT2_TIPOCO == StrZero(8,Len(DT2->DT2_TIPOCO)) .Or. DT2->DT2_TIPOCO == StrZero(13,Len(DT2->DT2_TIPOCO))
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Help(' ',1,'TMSA36034') // Tipo de Ocorrencia Invalido para Registro de Ocorrencia sem Viagem ...
				Return( .F. )
			EndIf

			If ( (DT2->DT2_TIPOCO == StrZero(4,Len(DT2->DT2_TIPOCO)) .And.	!__lPyme) .Or. ;
                 (DT2->DT2_TIPOCO == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND == StrZero(4,Len(DT2->DT2_TIPPND)) ));
			    .And. !Empty(GdFieldGet('DUA_FILDOC',n)) .And. !Empty(GdFieldGet('DUA_DOC',n)) .And. !Empty(GdFieldGet('DUA_SERIE',n))

				lDocRed:= TMA360IDFV(GdFieldGet("DUA_FILDOC",n), GdFieldGet("DUA_DOC",n), GdFieldGet("DUA_SERIE",n), .F., M->DUA_FILORI, M->DUA_VIAGEM )

				// CASO A OCORRENCIA SEJA DO TIPO RETORNA DOCUMENTO E ESTEJA INFORMADO O RESPECTIVO DOCUMENTO //
				// CHECAR A EXISTENCIA DO PROCESSO DE REDESPACHO PARA O MESMO, E CASO NAO ESTEJA VINCULADO A  //
				// UM PROCESSO DESSE TIPO, NAO PERMITIR O APONTAMENTO DA MESMA.                               //
				If !lDocRed .And. Iif(lRotDUD,!TMSChvDUD(GdFieldGet("DUA_FILDOC",n), GdFieldGet("DUA_DOC",n), GdFieldGet("DUA_SERIE",n)),.T.)
					//-- Limpa marcas dos agendamentos
					//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
					If !IsInCallStack("TMSAF76")
						TMSALimAge(StrZero(ThreadId(),20))
					EndIf
					Help(' ',1,'TMSA36034') // Tipo de Ocorrencia Invalido para Registro de Ocorrencia sem Viagem ...
					Return( .F. )
				EndIf
			EndIf
			If DT2->DT2_CATOCO == StrZero(2,Len(DT2->DT2_CATOCO)) // Por viagem
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Help(' ',1,'TMSA36037') // Para apontar ocorrencias por viagem, a viagem devera estar preenchida ...
				Return( .F. )
			EndIf
		EndIf

		//-- Tratamento Receitas/Depesas
		If 	Empty(M->DUA_VIAGEM) .And. ( DT2->DT2_TIPOCO == StrZero(17,Len(DT2->DT2_TIPOCO)) .Or. ;
			DT2->DT2_TIPOCO == StrZero(18,Len(DT2->DT2_TIPOCO)) )
			Help( ,, 'HELP',, STR0110, 1, 0) //-- "Ocorrências Com Tipo 17 ou 18 Devem Ser Apontados Para a Viagem"
			Return( .F. )
		EndIf

		If DT2->DT2_TIPOCO == StrZero(12, Len(DT2->DT2_TIPOCO))
			If DTQ->DTQ_SERTMS <> StrZero(1,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_SERTMS <> StrZero(3,Len(DTQ->DTQ_SERTMS))
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Help(' ',1,'TMSA36051') // O Tipo de Ocorrencia "Cancelamento", so e permitido para Viagens de "Coleta" ou "Entrega".
				Return( .F. )
			ElseIf DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) //-- Em Transito
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				
				//Para Solicitação de coleta é permitido apontar ocorrencia de cancelamento para viagem em transito
				If DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS))  
					If !Empty(GdFieldGet("DUA_FILDOC",n)) .AND. !Empty(GdFieldGet("DUA_DOC",n)) .AND. !Empty(GdFieldGet("DUA_SERIE",n))
						cSerDoc:= TMSA360DUD(GdFieldGet("DUA_FILDOC",n),GdFieldGet("DUA_DOC",n),GdFieldGet("DUA_SERIE",n))
						If cSerDoc <> StrZero(1,Len(DTQ->DTQ_STATUS))  //Coleta
							Help( ,, 'HELP',, STR0128, 1, 0)  //O Tipo de Ocorrência "Cancelamento", só é permitido para Documentos de Coleta.
							Return( .F. )									
						EndIf
					EndIf		
				EndIf

			EndIf
		EndIf

		If DT2->DT2_TIPOCO == StrZero(14, Len(DT2->DT2_TIPOCO))
			If !TMA360PrvAju(M->DUA_FILORI, M->DUA_VIAGEM,,,.T.)
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Help("", 1, "TMSA36084" ) // Não é permitido apontar esta ocorrencia! Não existe operação de chegada na filial em aberto.
				Return( .F. )
			EndIf
		EndIf

		If DT2->DT2_TIPOCO <> StrZero( 8, Len(DT2->DT2_TIPOCO ) ) .And. !Empty(GdFieldGet('DUA_NUMVTR',n))
			GdFieldPut('DUA_FILVTR', Space(FWGETTAMFILIAL), n)
			GdFieldPut('DUA_NUMVTR', Space(Len(DUA->DUA_NUMVTR)), n)
			If !l360Auto
				oTmsGetD:oBrowse:Refresh( .T. )
			EndIf
		EndIf

		If !( cSerTMS == StrZero(3, Len(DT2->DT2_SERTMS)) .And. cTipOco == StrZero(1, Len(DT2->DT2_TIPOCO)) )
			GdFieldPut('DUA_RECEBE', CriaVar('DUA_RECEBE', .F.), n)
		EndIf

		If	lRet
			If DT2->DT2_ATIVO != StrZero( 1, Len( DT2->DT2_ATIVO ) )
				Help(' ', 1, 'TMSA36007')  //-- Ocorrencia nao esta Ativa !
				lRet := .F.
			ElseIf !Empty(DT2->DT2_SERTMS) .AND. !Empty(M->DUA_FILORI) .And. !Empty(M->DUA_VIAGEM) .And. DT2->DT2_SERTMS != DTQ->DTQ_SERTMS  .And. DTQ->DTQ_SERADI != DT2->DT2_SERTMS
				Help(' ', 1, 'TMSA36008')  //-- Servico de Transporte da ocorrencia diferente do servico da Viagem !
				lRet := .F.
			EndIf
		EndIf

		If	lRet
			// Viagem com Status "EM ABERTO" AND Ocorrencia tipo "ENCERRA PROCESSO" AND Servico de Entrega OU Servico de Coleta
			If	DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) .And. cTipOco == StrZero(1,Len(DT2->DT2_TIPOCO )) .And. (cSerTMS  == StrZero(3,Len(DT2->DT2_SERTMS)) .Or. cSerTMS  == StrZero(1,Len(DT2->DT2_SERTMS)))
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
	     	  	Help(' ', 1, 'TMSA36098')  //-- Para o tipo de ocorrencia encerra processo a viagem nao podera estar em aberto
				Return( .F. )
			EndIf
		EndIf

		If	lRet
			// Ocorrencia de confirmação de embarque deve ter categoria por viagem
			If	AllTrim(M->DUA_CODOCO) == cOcorCfe .And. cCatOco <> StrZero(2,Len(DT2->DT2_CATOCO ))
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
	     	  	Help(' ', 1, 'TMSA360B4')  //-- Ocorrência de confirmação de embarque deve possuir categoria por viagem
				Return( .F. )
			EndIf
		EndIf
		//-- Permite lancar um codigo de ocorrencia por documento sem apagar o documento ja digitado.
		If lRet .And.	cCatOco == StrZero( 1, Len( DT2->DT2_CATOCO ) ) .And. cTipOco <> StrZero(5, Len( DT2->DT2_TIPOCO ) );
		    .And. !Empty(GdFieldGet('DUA_FILDOC',n)) .And. !Empty(GdFieldGet('DUA_DOC',n)) .And. !Empty(GdFieldGet('DUA_SERIE',n))

			//-- Nao permite apontar o mesmo codigo de ocorrencia para uma mesma viagem
			cAliasQry := GetNextAlias()
			cQuery := " SELECT DUA_FILIAL "
			cQuery += " 	FROM " + RetSqlName("DUA")
			cQuery += " 	WHERE DUA_FILIAL = '" + xFilial("DUA") + "' "
			cQuery += " 		AND DUA_FILORI = '" + M->DUA_FILORI + "' "
			cQuery += " 		AND DUA_VIAGEM = '" + M->DUA_VIAGEM + "' "
			cQuery += " 		AND DUA_CODOCO = '" + &(ReadVar())  + "' "
			cQuery += " 		AND DUA_FILDOC = '" + GdFieldGet('DUA_FILDOC',n) + "' "
			cQuery += " 		AND DUA_DOC 	= '" + GdFieldGet('DUA_DOC',n) + "' "
			cQuery += " 		AND DUA_SERIE 	= '" + GdFieldGet('DUA_SERIE',n) + "' "
			cQuery += " 		AND D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			If (cAliasQry)->(!Eof())
				Help('',1,'TMSA36064')		//-- Ocorrencia ja informada para essa viagem
				lRet := .F.
			Else
				lLimpaDoc := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
			RestArea( aArea )
	   EndIf

		If !l360Auto .And. lLimpaDoc .And. !lAjusta
			GDFieldPut( 'DUA_FILDOC', Space(FWGETTAMFILIAL)	, n )
			GDFieldPut( 'DUA_DOC'   , Space(Len(DUA->DUA_DOC))		, n )
			GDFieldPut( 'DUA_SERIE' , Space(Len(DUA->DUA_SERIE))	, n )
			GDFieldPut( 'DUA_QTDVOL', 0								, n )
			GDFieldPut( 'DUA_QTDOCO', 0								, n )
			If lDUAPrzEnt
				GDFieldPut( 'DUA_PRZENT', cTod('')					, n )
			EndIf
		EndIf

		//-- Se for ocorrencia por viagem
		If	lRet .And. cTipOco <> StrZero(14, Len( DT2->DT2_TIPOCO ) )  .And. ;// Ajuste Previsao de Chegada
							cTipOco <> StrZero(5, Len( DT2->DT2_TIPOCO ) ) .And. ; // Ocorrencia Informativa
							cCatOco == StrZero( 2, Len( DT2->DT2_CATOCO ) )

			//-- Nao permite apontar o mesmo codigo de ocorrencia para uma mesma viagem
			aAreaDUA := DUA->(GetArea())
			DUA->(DbSetOrder(2))
			If	DUA->(DbSeek( cSeek := xFilial('DUA') + M->DUA_FILORI + M->DUA_VIAGEM))
				While DUA->( ! Eof() .And. DUA->DUA_FILIAL + DUA->DUA_FILORI + DUA->DUA_VIAGEM == cSeek )
					If	DUA->DUA_CODOCO == &(ReadVar())
						If DUA->DUA_FILDOC == GdFieldGet('DUA_FILDOC',n) .And.;
							DUA->DUA_DOC 	  == GdFieldGet('DUA_DOC',n)
							Help('',1,'TMSA36064')		//-- Ocorrencia ja informada para essa viagem
							lRet := .F.
							Exit
						EndIf
					EndIf
					DUA->(DbSkip())
				EndDo
			EndIf
			RestArea(aAreaDUA)
		EndIf
		//-- Somar quantidade de volumes e peso de todos os documentos da viagem e gatilhar nos campos DUA_PESOCO e DUA_QTDOCO
		If	lRet .And. cCatOco == StrZero( 2, Len( DT2->DT2_CATOCO ) )

			If cTipOco == StrZero(5,Len(DT2->DT2_TIPOCO)) // Ocorrencia Informativa
				lDocFinCanc	:= .T. //-- Considerar os documentos 'Cancelados' / 'Encerrados'
				lFilDca     := .T.
			EndIf

			TMSVerMov(M->DUA_FILORI, M->DUA_VIAGEM, , , ,(cTipOco == StrZero(3,  Len(DT2->DT2_TIPOCO  ) )) , @aDoc,Iif(cTipOco == StrZero(5,Len(DT2->DT2_TIPOCO)),.F.,), lDocFinCanc, lFilDca,,Iif(lLibVgBlq .And. DT2->DT2_TIPOCO == StrZero( 3, Len( DT2->DT2_TIPOCO )),.T.,.F.))
			If Len(aDoc) > 0
				MsAguarde({|| lRet := TMA360Cols(aDoc) },STR0035) //"Aguarde! Obtendo os dados..."
				If !lRet
					//-- Limpa marcas dos agendamentos
					//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
					If !IsInCallStack("TMSAF76")
						TMSALimAge(StrZero(ThreadId(),20))
					EndIf
					Return( .F. )
				EndIf
			Else
				//-- Verifica se existem documentos para geracao da indenizacao.
				If  DT2->DT2_TIPOCO == StrZero( 9, Len( DT2->DT2_TIPOCO ) ) //-- Gera Indenizacao
					//-- Limpa marcas dos agendamentos
					//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
					If !IsInCallStack("TMSAF76")
						TMSALimAge(StrZero(ThreadId(),20))
					EndIf
					Help('',1,'TMSA36074') //-- Documento nao encontrado !!!.
					Return( .F. )
				EndIf
			EndIf

			If AllTrim(M->DUA_CODOCO) == cOcorCfe
				If DTQ->DTQ_TIPTRA == StrZero(3,Len(DTQ->DTQ_TIPTRA)) .And. FindFunction("ALIASINDIC") .And. AliasIndic("DW4")
					// Tela de Confirmacao de Embarque Fluvial
					If !TA360EmbFlu(3)
						//-- Limpa marcas dos agendamentos
						//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
						If !IsInCallStack("TMSAF76")
							TMSALimAge(StrZero(ThreadId(),20))
						EndIf
						Return( .F. )
					EndIf
				EndIf
			EndIf
		EndIf


		If lRet .And.	DT2->DT2_TIPOCO == StrZero( 9, Len( DT2->DT2_TIPOCO ) ) .And.;	// Gera Indenizacao.
			DT2->DT2_CATOCO == StrZero( 2, Len( DT2->DT2_CATOCO ) )				// Por Viagem.
			lRet     := .F.
			aAreaDUD := DUD->( GetArea() )
			DUD->( DbSetOrder( 2 ) )
			DUD->( DbSeek( cSeek := xFilial("DUD") + M->DUA_FILORI + M->DUA_VIAGEM ) )
			While DUD->( !Eof() .And. DUD_FILIAL + DUD_FILORI + DUD_VIAGEM == cSeek )
				If ( ( DUD->DUD_STATUS != StrZero( 4, Len( DUD->DUD_STATUS ) ) ) .And. ; // Encerrado
					( DUD->DUD_STATUS != StrZero( 9, Len( DUD->DUD_STATUS ) ) ) )  .Or. ; // Cancelado
					( DUD->DUD_STATUS == StrZero( 4, Len( DUD->DUD_STATUS ) )      .And.;
					DUD->DUD_FILDCA == cFilAnt )
					lRet := .T.
					Exit
				EndIf

				DUD->( dbSkip() )
			EndDo
			RestArea( aAreaDUD )
			If !lRet
				Help("", 1, "TMSA36056" ) // Documento cancelado ou ocorrencia deve ser apontada na filial de descarga.
			EndIf
		EndIf
        
		If lRet
			If DT2->DT2_ODOCHG <> '1' .And. !Empty(GDFieldGet('DUA_ODOCHG',n))
				GDFieldPut('DUA_ODOCHG', 0, n)
			EndIf
		EndIf

	
		//--- Atualiza o campo Prazo de Entrega caso altere o Codigo da Ocorrencia	
		If lRet .And. lDUAPrzEnt .And. nRecursivo == 0 .And. !Empty(GDFieldGet( 'DUA_CODOCO', n )) .And. !Empty(M->DUA_CODOCO) .And. GDFieldGet( 'DUA_CODOCO', n ) <> M->DUA_CODOCO 
			If !Empty(GdFieldGet("DUA_FILDOC",n)) .AND. !Empty(GdFieldGet("DUA_DOC",n)) .AND. !Empty(GdFieldGet("DUA_SERIE",n))
				aAreaBkp:= GetArea()
				If A360OcoPrz(DT2->DT2_CODOCO)  
					If Empty(GDFieldGet( 'DUA_PRZENT', n ))
						DT6->(DbSetOrder(1))
					 	If DT6->(DbSeek(xFilial('DT6')+GdFieldGet('DUA_FILDOC',n)+GdFieldGet('DUA_DOC',n)+GdFieldGet('DUA_SERIE',n))) 
							GDFieldPut('DUA_PRZENT', DT6->DT6_PRZENT, n)
						EndIf	
					EndIf	
				Else
					If !Empty(GDFieldGet( 'DUA_PRZENT', n ))
						GDFieldPut('DUA_PRZENT', cToD(''), n)
					EndIf
				EndIf
				RestArea(aAreaBkp)
			EndIf	
		EndIf 

	ElseIf nModulo == 39 .And. lTabDFI //--OMS com Frete Embarcador

		DT2->(DbSetOrder(1))
		lRet := DT2->(DbSeek(xFilial("DT2")+ &(ReadVar()) ))

		If lRet .And. DT2->DT2_SERTMS != StrZero(3,Len(DT2->DT2_SERTMS)) .And. DT2->DT2_TIPOCO != StrZero(4,Len(DT2->DT2_TIPOCO))
			MsgAlert("So e permitido Ocorrencia de Entrega do Tipo Retorna Documento")
			lRet := .F.
		EndIf

	EndIf

ElseIf	cCampo == 'M->DUA_QTDOCO'
	DT2->(DbSetOrder(1))
	DT2->(DbSeek(xFilial("DT2")+ GdFieldGet("DUA_CODOCO",n)))
	cTipOco := DT2->DT2_TIPOCO
	lSobra  := ( cTipOco == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND == StrZero(3,Len(DT2->DT2_TIPPND)) ) //-- Sobra

	DTQ->( DbSetOrder( 2 ) )
	DTQ->( DbSeek( xFilial('DTQ') + M->DUA_FILORI + M->DUA_VIAGEM ) )

	If DTQ->DTQ_SERTMS == StrZero( 1, Len( DTQ->DTQ_SERTMS ) )
		//-- Se a viagem for de coleta e a solicitacao que originou o documento for do tipo automatica, permitir que o volume seja zero.
		DT5->(DbSetOrder( 4 ))
		If	DT5->(DbSeek(xFilial('DT5') + GDFieldGet('DUA_FILDOC',n) + GDFieldGet('DUA_DOC',n) + GDFieldGet('DUA_SERIE',n))) .And.;
			cTipOco == StrZero( 8, Len( DT2->DT2_TIPOCO ) )
			lRet := M->DUA_QTDOCO >= 0
		Else
			lRet := M->DUA_QTDOCO > 0
		EndIf
	EndIf

	If lRet .And. DT2->DT2_TIPPND == StrZero(3,Len(DT2->DT2_TIPPND)) .And. (("DUA_QTDOCO" $ ReadVar() .And. M->DUA_QTDOCO <= 0 ) .Or. (!"DUA_QTDOCO" $ ReadVar() .And. GdFieldGet('DUA_QTDOCO') <= 0) )
		Help('',1,"OBRIGAT2",,RetTitle('DUA_QTDOCO'),04,01) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse
		lRet := .F.
	EndIf

	// Se a Categoria for por Documento e Tipo for Gera Pendencia
	If lRet .And. !lSobra .And. nOpc <> 6 .And. (DT2->DT2_TIPOCO == StrZero(6, Len(DT2->DT2_TIPOCO) ) .Or. DT2->DT2_TIPOCO == StrZero(19, Len(DT2->DT2_TIPOCO) ) .Or. DT2->DT2_TIPOCO == StrZero(20, Len(DT2->DT2_TIPOCO) ) )
		lRet := TMSA360NF(M->DUA_FILOCO, M->DUA_NUMOCO, ,DT2->DT2_TIPPND,.F.,,DT2->DT2_TIPOCO)
	EndIf

	// Se Tipo Indenização  Sobra
	If lRet .And. lSobra .And. lIdProd .And. nOpc == 3 .And. (("DUA_QTDOCO" $ ReadVar() .And. M->DUA_QTDOCO > 0 ) .Or. (GdFieldGet('DUA_QTDOCO') > 0) )
		lRet := TMSA360SF(M->DUA_FILOCO, M->DUA_NUMOCO,,DT2->DT2_TIPPND,,.F.)
	EndIf
ElseIf cCampo == 'M->DUA_PESOCO'
	DT2->(DbSetOrder(1))
	DT2->(DbSeek(xFilial("DT2")+ GdFieldGet("DUA_CODOCO",n)))
	cTipOco := DT2->DT2_TIPOCO
	lSobra  := ( cTipOco == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND	== StrZero(3,Len(DT2->DT2_TIPPND)) ) //-- Sobra

	DTQ->( DbSetOrder( 2 ) )
	DTQ->( DbSeek( xFilial('DTQ') + M->DUA_FILORI + M->DUA_VIAGEM ) )

	DT5->(DbSetOrder( 4 ))
	lDT5 := DT5->(DbSeek(xFilial('DT5') + GDFieldGet('DUA_FILDOC',n) + GDFieldGet('DUA_DOC',n) + GDFieldGet('DUA_SERIE',n)))

	If (DTQ->DTQ_SERTMS == StrZero( 1, Len( DTQ->DTQ_SERTMS ) )) .OR. lDT5
		//-- Se a viagem for de coleta e a solicitacao que originou o documento for do tipo automatica, permitir que o volume seja zero.

		If	cTipOco == StrZero( 8, Len( DT2->DT2_TIPOCO ) )
			lRet := M->DUA_PESOCO >= 0 // <= GDFieldGet( 'DUA_PESO', n )
		Else
			lRet := M->DUA_PESOCO > 0 //.And. M->DUA_PESOCO <= GDFieldGet( 'DUA_PESO',n )
		EndIf
	ElseIf GDFieldGet( 'DUA_PESO',n ) <> Nil
		lRet := M->DUA_PESOCO > 0 .And. ( lSobra .Or. M->DUA_PESOCO <= GDFieldGet( 'DUA_PESO',n ))
	EndIf

ElseIf cCampo $ "M->DUA_FILDOC.M->DUA_DOC.M->DUA_SERIE"

	If cCampo == 'M->DUA_FILDOC'
		cFilDoc := M->DUA_FILDOC
		cDoc    := Iif( !Empty( GDFieldGet('DUA_DOC'  ,n) ), GDFieldGet('DUA_DOC'  ,n), "" )
		cSerie  := Iif( !Empty( GDFieldGet('DUA_SERIE',n) ), GDFieldGet('DUA_SERIE',n), "" )
	ElseIf cCampo == 'M->DUA_DOC'
		cFilDoc := GDFieldGet('DUA_FILDOC',n)
		cDoc    := M->DUA_DOC
		cSerie  := Iif( !Empty( GDFieldGet('DUA_SERIE',n) ), GDFieldGet('DUA_SERIE',n), "" )
	ElseIf cCampo == 'M->DUA_SERIE'
		cFilDoc := GDFieldGet('DUA_FILDOC',n)
		cDoc    := GDFieldGet('DUA_DOC',n)
		cSerie  := M->DUA_SERIE
	EndIf

	If Empty( cFilDoc ) .Or. Empty( cDoc ) .Or. Empty( cSerie )
		Return( .T. )
	EndIf

	If nModulo == 43 //--TMS

		//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
		aAreaDT2 := DT2->(GetArea())
		cCodOco := GDFieldGet("DUA_CODOCO",n)
		If !Empty(cCodOco) .And. DT2->(DbSeek(xFilial("DT2") + cCodOco))
			If DT2->DT2_SERTMS == StrZero(1,Len(DT2->DT2_SERTMS))
				If !TMSAVerAge("3",,,,,,,,,cFilDoc,cDoc,,"2",.T.,.T.)
					Return .F.
				EndIf
			Else
				If !TMSAVerAge("1",cFilDoc,cDoc,cSerie,,,,,,,,,"2",.T.,.T.)
					Return .F.
				EndIf
			EndIf
		EndIf
		RestArea(aAreaDT2)

		lRet := TMA360VlDoc(cFilDoc, cDoc, cSerie, aDoc , M->DUA_FILORI ,  M->DUA_VIAGEM ) //-- Valida o Documento

		//-- Nao permitir informar ocorrencias para viagens em Aberto/Fechada
		If lRet
			cAliasQry := GetNextAlias()
		   	cQuery := " SELECT (MAX(R_E_C_N_O_)) R_E_C_N_O_"
			cQuery += "   FROM " + RetSqlName("DUD")
			cQuery += "  WHERE DUD_FILIAL = '" + xFilial('DUD') + "' "
			cQuery += "    AND DUD_FILDOC = '" + cFilDoc + "' "
			cQuery += "    AND DUD_DOC = '" + cDoc+ "' "
			cQuery += "    AND DUD_SERIE = '" + cSerie+ "' "
			cQuery += "    AND D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

			If (cAliasQry)->(!Eof())
				If (cAliasQry)->R_E_C_N_O_ > 0
				  aAreaDUD := DUD->( GetArea() )
		   	      DUD->(dbGoto((cAliasQry)->R_E_C_N_O_))

		    		If !Empty(DUD->DUD_VIAGEM)
		    			DbSelectArea("DTQ")
						DbSetOrder(2)
						If DbSeek(xFilial("DTQ")+DUD->DUD_FILORI+DUD->DUD_VIAGEM)
							If ( DT2->DT2_TIPOCO <> StrZero(5,Len(DT2->DT2_TIPOCO)) .And. (DT2->DT2_TIPOCO == StrZero(12,Len(DT2->DT2_TIPOCO)) .And. !IsInCallStack("TMSA050MNT"))) .And. ;
								(	DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) .Or. ;
								DTQ->DTQ_STATUS == StrZero(5,Len(DTQ->DTQ_STATUS)) )
								Help("",1,"TMSA360B3") //Não e permitido informar ocorrencias diferente de informativa para viagens com Status "Em Aberto" ou "Fechada"
								lRet := .F.
							EndIf
							If lRet .And. (DT2->DT2_TIPOCO == StrZero( 1, Len(DT2->DT2_TIPOCO)) .Or. DT2->DT2_TIPOCO == StrZero( 4, Len( DT2->DT2_TIPOCO ) ))  // Encerra processo ou Retorna Documento
								If !Empty(M->DUA_FILORI+M->DUA_VIAGEM) .And. ( ( DUD->(DUD_FILORI+DUD_VIAGEM) != M->DUA_FILORI+M->DUA_VIAGEM .And. !Empty(DUD->DUD_VIAGEM) ) .Or. ;
								(Empty(DUD->DUD_VIAGEM) .And. DUD->(DUD_FILVGE+DUD_NUMVGE) != M->DUA_FILORI+M->DUA_VIAGEM) )
									Help('',1,'TMSA36071',, + CHR(13) + CHR(10) + Alltrim(cFilDoc) + ' - ' + Alltrim(cDoc) + ' - ' + Alltrim(cSerie) + CHR(13) + CHR(10) + STR0028 + CHR(13) + CHR(10) + DUD->(DUD_FILORI+' - '+DUD_VIAGEM),1,12) //"O Documento"###" pertence a viagem: "
									lRet := .F.
								Else
									//Somente ocorrencias por Viagem devem ter a viagem gatilhada.
									If DT2->DT2_CATOCO == StrZero(2, Len(DT2->DT2_CATOCO)) .And. Empty(M->DUA_FILORI) .And. Empty(M->DUA_VIAGEM)
										M->DUA_FILORI := DUD->DUD_FILORI
										M->DUA_VIAGEM := DUD->DUD_VIAGEM
									EndIf
								EndIf
							EndIf

							// Valida se é uma encerra processo para um documento não previsto.
							If lRet .And. !l360Auto .AND. DTQ->DTQ_SERTMS == StrZero( 3, Len( DTQ->DTQ_SERTMS ) ) .AND. DTQ->DTQ_STATUS <> StrZero( 4, Len( DTQ->DTQ_SERTMS ) ) .AND. DUD->(ColumnPos("DUD_DTRNPR")) >0  .AND. !Empty(DUD->DUD_DTRNPR) .AND. !Empty(DUD->DUD_USURNP)
								If DT2->DT2_TIPOCO == StrZero( 1, Len(DT2->DT2_TIPOCO)) // Encerra processo
									lRet := MsgYesNo(STR0108, STR0055) //"Este documento está previsto retornar para a filial de Origem da viagem. Deseja realmente apontar o encerramento de Processo?" ### "Atenção"
								EndIf
							EndIf
						EndIf
					EndIf
					RestArea( aAreaDUD )
				EndIf
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf

		If lRet .And. Len(aDoc) > 0
			TMA360Cols(aDoc)  //-- Monta acols com os documentos da Viagem
		ElseIf l360Auto   
			cFileLog := NomeAutoLog()
			If !Empty(cFileLog) .And. !lJob360
				MostraErro()
			EndIf
		EndIf
		If lRet .And. Empty(M->DUA_FILORI) .And. Empty(M->DUA_VIAGEM) .And.;
			( (DT2->DT2_TIPOCO == StrZero(4,Len(DT2->DT2_TIPOCO)) .And.	!__lPyme) .Or. ;
              (DT2->DT2_TIPOCO == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND == StrZero(4,Len(DT2->DT2_TIPPND)) )) .And. ;
              !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)

			lDocRed:= TMA360IDFV(cFilDoc, cDoc, cSerie,.F., M->DUA_FILORI, M->DUA_VIAGEM )

			// CASO A OCORRENCIA SEJA DO TIPO RETORNA DOCUMENTO E ESTEJA INFORMADO O RESPECTIVO DOCUMENTO //
			// CHECAR A EXISTENCIA DO PROCESSO DE REDESPACHO PARA O MESMO, E CASO NAO ESTEJA VINCULADO A  //
			// UM PROCESSO DESSE TIPO, NAO PERMITIR O APONTAMENTO DA MESMA.                               //
			If !lDocRed .And. Iif(lRotDUD,!TMSChvDUD(cFilDoc, cDoc, cSerie),.T.)
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Help(' ',1,'TMSA36034') // Tipo de Ocorrencia Invalido para Registro de Ocorrencia sem Viagem ...
				Return( .F. )
			EndIf
		EndIf

		//-- Valida integração com Demandas
		If lRet 
			If lITmsDmd .And. FindFunction("TmsDmdXDoc")	//-- Integrado com demandas e existe a função que busca o vínculo com DT5
				If Len(TmsDmdXDoc(,,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,.F.)) > 0	//-- Busca o vínculo com DT5
					DTA->(DbSetOrder(2))
					If !DTA->(DbSeek(xFilial("DTA") + M->(DUA_FILORI + DUA_VIAGEM) + DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)))	//-- Não foi informada a viagem correta
						Help("",1,"TMSA360F6")	//-- //-- "Documento vinculado à demanda. A informação da viagem é obrigatória" ### "atencao"
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf

	ElseIf nModulo == 39 //--OMS
		DAI->(DbSetOrder(3))
		If DAI->(DbSeek(cSeekDAI := xFilial("DAI")+cDoc+cSerie))
			While DAI->(!Eof() .And. DAI->DAI_FILIAL+DAI->DAI_NFISCA+DAI->DAI_SERIE == cSeekDAI )
				nVolume += DAI->DAI_CAPVOL
			 	nPeso   += DAI->DAI_PESO
				DAI->(dbSkip())
			EndDo
			GDFieldPut( 'DUA_QTDOCO', nVolume	, n )
			GDFieldPut( 'DUA_PESOCO', nPeso		, n )
		EndIf
   EndIf

ElseIf cCampo $ 'M->DUA_FILVTR.M->DUA_NUMVTR'

	//-- Valida se o Documento em questao e' da filial corrente.
	If cCampo == 'M->DUA_FILVTR'
		cFilVtr 	:= M->DUA_FILVTR
		cNumVtr 	:= Iif( !Empty( GDFieldGet('DUA_NUMVTR'  ,n) ), GDFieldGet('DUA_NUMVTR'  ,n), M->DUA_NUMVTR )
	ElseIf cCampo == 'M->DUA_NUMVTR'
		cFilVtr	:= Iif( !Empty( GDFieldGet('DUA_FILVTR',n) ), 	GDFieldGet('DUA_FILVTR',n), M->DUA_FILVTR )
		cNumVtr	:= M->DUA_NUMVTR
	EndIf

	If Empty( cFilVtr ) .Or. Empty( cNumVtr )
		Return( .T. )
	EndIf

	cSeekDUD := GDFieldGet( 'DUA_FILDOC', n ) + GDFieldGet( 'DUA_DOC', n )  +  GDFieldGet( 'DUA_SERIE', n ) + 	cFilVtr + cNumVtr
	cSerTMS := Posicione('DTQ',2,xFilial('DTQ')+M->DUA_FILORI+M->DUA_VIAGEM, 'DTQ_SERTMS')

	DTQ->(DbSetOrder(2))
	If DTQ->(DbSeek(xFilial('DTQ')+ cFilVtr + cNumVtr ))
		If !Empty(M->DUA_FILORI+M->DUA_VIAGEM) .And. M->DUA_FILORI+M->DUA_VIAGEM == cFilVtr+cNumVtr
			Return( .F. )
		EndIf

		If DTQ->DTQ_STATUS == StrZero(9, Len(DTQ->DTQ_STATUS)) //Viagem Cancelada
			Help('',1,'TMSA36078') //"Nao e permitido transferir um documento para uma viagem cancelada"
			Return( .F. )
		EndIf

		If DTQ->DTQ_STATUS == StrZero(3, Len(DTQ->DTQ_STATUS)) //Viagem Encerrada
			Help('',1,'TMSA36079') //"Nao e permitido transferir um documento para uma viagem encerrada"
			Return( .F. )
		EndIf

		If lRet .And. DTQ->DTQ_SERTMS <> cSerTMS
			Help('',1,'TMSA36035') //O Servico de Transporte desta Viagem esta diferente do Servico de Transporte da Filial/Viagem Origem"
			Return( .F. )
		EndIf

		DUD->(DbSetOrder(1))
		DVM->(DbSetOrder(1))
		If DUD->(DbSeek(xFilial("DUD") +  cSeekDUD))
			If DUD->DUD_SERTMS == StrZero(2, Len(DUD->DUD_SERTMS))        // Documento Transporte.
				If DVM->(!dbSeek(xFilial('DVM')+DTQ->DTQ_ROTA+DUD->DUD_CDRDES))
					Help("",1,"TMSA36047") // A regiao de destino do CTRC nao pertence a regiao da rota.
					Return( .F. )
				EndIf
			ElseIf DUD->(ColumnPos('DUD_CEPENT')) > 0
				aRota := TMSRetRota(,,DUD->DUD_CEPENT)
				If Ascan(aRota, {|x| x[2] == DTQ->DTQ_ROTA}) == 0
					Help("",1,"TMSA36095") //-- 'Existem documentos de viagem que não é compatível com a rota selecionada'
					lRet := .F.
				EndIf
			EndIf
		EndIf

		If lAllMark .And. lRet
			For nX:=n To Len(aCols)
				GdFieldPut('DUA_FILVTR',cFilVtr,nX)
				GdFieldPut('DUA_NUMVTR',cNumVtr,nX)
			Next
			If !l360Auto
				oTmsGetD:oBrowse:Refresh( .T. )
			EndIf
		EndIf
	Else
		Help('',1,'REGNOIS')
		lRet := .F.
	EndIf
ElseIf cCampo $'M->DUA_DATCHG'
	DT2->(DbSetOrder(1))
	DT2->(DbSeek(xFilial('DT2')+GdFieldGet('DUA_CODOCO',n)))
	If DT2->DT2_TIPOCO <> StrZero(14,Len(DT2->DT2_TIPOCO)) //-- Ajuste Previsao de Chegada
		If ( !Empty(GdFieldGet('DUA_DATSAI',n)) .And. M->DUA_DATCHG > GdFieldGet('DUA_DATSAI',n) )
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If lAllMark
		   cDescri := M->DUA_DATCHG
			For nX:=n To Len(aCols)
				GdFieldPut('DUA_DATCHG',cDescri,nX)
			Next
			If !l360Auto
				oTmsGetD:oBrowse:Refresh( .T. )
			EndIf
		EndIf

		cHoraChg := Transform(GdFieldGet('DUA_HORCHG',n),"@R 99:99")

		If !Empty(HoraToInt(cHoraChg))

			//-- Verifica a ultima saida da viagem
			cAliasQry := GetNextAlias()
			cQuery := " SELECT DTW_DATREA,DTW_HORREA "
			cQuery += " 	FROM " + RetSqlName("DTW")
			cQuery += " 	WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
			cQuery += " 		AND DTW_FILORI = '" + M->DUA_FILORI + "' "
			cQuery += " 		AND DTW_VIAGEM = '" + M->DUA_VIAGEM + "' "
			cQuery += " 		AND DTW_ATIVID = '" + cAtivSai      + "' "
			cQuery += " 		AND DTW_STATUS = '" + StrZero(2,Len(DTW->DTW_STATUS)) + "' "
			cQuery += " 		AND D_E_L_E_T_ = ' ' "
			cQuery += " 		AND DTW_SEQUEN = ( SELECT MAX(DTW_SEQUEN) "
			cQuery += " 									FROM " + RetSqlName("DTW")
			cQuery += " 									WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
			cQuery += " 										AND DTW_FILORI = '" + M->DUA_FILORI + "' "
			cQuery += " 										AND DTW_VIAGEM = '" + M->DUA_VIAGEM + "' "
			cQuery += " 										AND DTW_ATIVID = '" + cAtivSai      + "' "
			cQuery += " 										AND DTW_STATUS = '" + StrZero(2,Len(DTW->DTW_STATUS)) + "' "
			cQuery += " 										AND D_E_L_E_T_ = ' ' ) "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			TcSetField(cAliasQry,"DTW_DATREA","D",8,0)
			If (cAliasQry)->(!Eof())
				dDataSai := (cAliasQry)->DTW_DATREA
				cHoraSai := HoraToInt(Transform((cAliasQry)->DTW_HORREA,"@R 99:99"))
				If ( M->DUA_DATCHG < dDataSai ) .Or. ( dDataSai == M->DUA_DATCHG .And. HoraToInt(cHoraChg) < cHoraSai )
					Help('',1,'TMSA36085') //"Hora invalida e/ou data invalida em relaçao a saida da viagem"
					lRet := .F.
			   EndIf
			EndIf
			(cAliasQry)->(DbCloseArea())
			RestArea( aArea )

			If lRet
				//-- Gatilha a nova previsao de chegada da viagem
				cAliasQry := GetNextAlias()
				cQuery := " SELECT DTW_DATPRE, DTW_HORPRE, DTW_SEQUEN "
				cQuery += " 	FROM " + RetSqlName("DTW")
				cQuery += " 	WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
				cQuery += " 		AND DTW_FILORI = '" + M->DUA_FILORI + "' "
				cQuery += " 		AND DTW_VIAGEM = '" + M->DUA_VIAGEM + "' "
				cQuery += " 		AND DTW_ATIVID = '" + cAtivChg      + "' "
				cQuery += " 		AND DTW_STATUS = '" + StrZero(1,Len(DTW->DTW_STATUS)) + "' "
				cQuery += " 		AND D_E_L_E_T_ = ' ' "
				cQuery += " 		AND DTW_SEQUEN = ( SELECT MIN(DTW_SEQUEN) "
				cQuery += " 									FROM " + RetSqlName("DTW")
				cQuery += " 									WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
				cQuery += " 										AND DTW_FILORI = '" + M->DUA_FILORI + "' "
				cQuery += " 										AND DTW_VIAGEM = '" + M->DUA_VIAGEM + "' "
				cQuery += " 										AND DTW_ATIVID = '" + cAtivChg      + "' "
				cQuery += " 										AND DTW_STATUS = '" + StrZero(1,Len(DTW->DTW_STATUS)) + "' "
				cQuery += " 										AND D_E_L_E_T_ = ' ' ) "
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				TcSetField(cAliasQry,"DTW_DATPRE","D",8,0)
				If (cAliasQry)->(!Eof())

					cHora:="000:00"

					dDataPre := (cAliasQry)->DTW_DATPRE
					dDataChg := M->DUA_DATCHG
					cHoraPre := Transform((cAliasQry)->DTW_HORPRE,"@R 99:99")
					cHoraChg := Transform(cHoraChg,"@R 99:99")

					nHorAju  := Round(SubtHoras(dDataPre,cHoraPre,dDataChg,cHoraChg),3)

					If nHorAju <> 0
						If nHorAju > 0
							If nHorAju > 999.983
								Help('',1,'TMSA36067',,"e/ou data invalida!",2,1) //"Hora Invalida !"
								M->DUA_DATCHG:=CTOD(SPACE(8))
								lRet := .F.
							Else
								cHora:=IntToHora(nHorAju)
								If Len(cHora) < 6
									cHora:="0"+cHora
								EndIf
							EndIf
						ElseIf nHorAju < 0
							If nHorAju < -99.983
								Help('',1,'TMSA36067',,"e/ou data invalida!",2,1) //"Hora Invalida !"
								M->DUA_DATCHG:=CTOD(SPACE(8))
								lRet := .F.
							Else
								cHora:="-"+IntToHora(ABS(nHorAju))
							EndIf
						EndIf
					EndIf

					RecLock("DTW",.F.)
					DTW_HORATR := cHora
					MsUnlock()
				EndIf
				(cAliasQry)->(DbCloseArea())
				RestArea( aArea )
			EndIf
		EndIf
	EndIf
ElseIf cCampo $ 'M->DUA_HORCHG'
	If lAllMark
	   cDescri := M->DUA_HORCHG
		For nX:=n To Len(aCols)
			GdFieldPut('DUA_HORCHG',cDescri,nX)
		Next
		If !l360Auto
			oTmsGetD:oBrowse:Refresh( .T. )
		EndIf
	EndIf

	dDataChg	:= GdFieldGet('DUA_DATCHG',n)
	cHoraChg := Transform(M->DUA_HORCHG,"@R 99:99")

	If !Empty(dDataChg)

		//-- Verifica a ultima saida da viagem
		cAliasQry := GetNextAlias()
		cQuery := " SELECT DTW_DATREA,DTW_HORREA "
		cQuery += " 	FROM " + RetSqlName("DTW")
		cQuery += " 	WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
		cQuery += " 		AND DTW_FILORI = '" + M->DUA_FILORI + "' "
		cQuery += " 		AND DTW_VIAGEM = '" + M->DUA_VIAGEM + "' "
		cQuery += " 		AND DTW_ATIVID = '" + cAtivSai      + "' "
		cQuery += " 		AND DTW_STATUS = '" + StrZero(2,Len(DTW->DTW_STATUS)) + "' "
		cQuery += " 		AND D_E_L_E_T_ = ' ' "
		cQuery += " 		AND DTW_SEQUEN = ( SELECT MAX(DTW_SEQUEN) "
		cQuery += " 									FROM " + RetSqlName("DTW")
		cQuery += " 									WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
		cQuery += " 										AND DTW_FILORI = '" + M->DUA_FILORI + "' "
		cQuery += " 										AND DTW_VIAGEM = '" + M->DUA_VIAGEM + "' "
		cQuery += " 										AND DTW_ATIVID = '" + cAtivSai      + "' "
		cQuery += " 										AND DTW_STATUS = '" + StrZero(2,Len(DTW->DTW_STATUS)) + "' "
		cQuery += " 										AND D_E_L_E_T_ = ' ' ) "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		TcSetField(cAliasQry,"DTW_DATREA","D",8,0)
		If (cAliasQry)->(!Eof())
			dDataSai := (cAliasQry)->DTW_DATREA
			cHoraSai := HoraToInt(Transform((cAliasQry)->DTW_HORREA,"@R 99:99"))
			If ( dDataChg < dDataSai ) .Or. ( dDataSai == dDataChg .And. HoraToInt(cHoraChg) < cHoraSai )
				Help('',1,'TMSA36085') // "Hora invalida e/ou data invalida em relaçao a saida da viagem"
				lRet := .F.
		   EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
		RestArea( aArea )

		If lRet
			//-- Gatilha a nova previsao de chegada da viagem
			cAliasQry := GetNextAlias()
			cQuery := " SELECT DTW_DATPRE, DTW_HORPRE, DTW_SEQUEN "
			cQuery += " 	FROM " + RetSqlName("DTW")
			cQuery += " 	WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
			cQuery += " 		AND DTW_FILORI = '" + M->DUA_FILORI + "' "
			cQuery += " 		AND DTW_VIAGEM = '" + M->DUA_VIAGEM + "' "
			cQuery += " 		AND DTW_ATIVID = '" + cAtivChg      + "' "
			cQuery += " 		AND DTW_STATUS = '" + StrZero(1,Len(DTW->DTW_STATUS)) + "' "
			cQuery += " 		AND D_E_L_E_T_ = ' ' "
			cQuery += " 		AND DTW_SEQUEN = ( SELECT MIN(DTW_SEQUEN) "
			cQuery += " 									FROM " + RetSqlName("DTW")
			cQuery += " 									WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
			cQuery += " 										AND DTW_FILORI = '" + M->DUA_FILORI + "' "
			cQuery += " 										AND DTW_VIAGEM = '" + M->DUA_VIAGEM + "' "
			cQuery += " 										AND DTW_ATIVID = '" + cAtivChg      + "' "
			cQuery += " 										AND DTW_STATUS = '" + StrZero(1,Len(DTW->DTW_STATUS)) + "' "
			cQuery += " 										AND D_E_L_E_T_ = ' ' ) "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			TcSetField(cAliasQry,"DTW_DATPRE","D",8,0)
			If (cAliasQry)->(!Eof())

				dDataPre := (cAliasQry)->DTW_DATPRE
				cHoraPre := Transform((cAliasQry)->DTW_HORPRE,"@R 99:99")

				cHora := "000:00"
				nHorAju  := Round(SubtHoras(dDataPre,cHoraPre,dDataChg,cHoraChg),3)
				If nHorAju <> 0
				   If nHorAju > 0
					   If nHorAju > 999.983
							Help('',1,'TMSA36067',,"e/ou data invalida!",2,1) //"Hora Invalida !"
							M->DUA_HORCHG:=SPACE(5)
					   	lRet := .F.
					   Else
							cHora:=IntToHora(nHorAju)
							If Len(cHora) < 6
								cHora:="0"+cHora
							EndIf
						EndIf
					ElseIf nHorAju < 0
					   If nHorAju < -99.983
							Help('',1,'TMSA36067',,"e/ou data invalida!",2,1) //"Hora Invalida !"
							M->DUA_HORCHG:=SPACE(5)
					   	lRet := .F.
					   Else
							cHora:="-"+IntToHora(ABS(nHorAju))
						EndIf
					EndIf
				EndIf

				RecLock("DTW",.F.)
				DTW_HORATR := cHora
				MsUnlock()

			EndIf
			(cAliasQry)->(DbCloseArea())
			RestArea( aArea )
		EndIf
	EndIf

ElseIf cCampo == "M->DTW_HORATR"
	//-- Gatilha a nova previsao de chegada da viagem
	cHoratr := M->DTW_HORATR
	nPosHorTr := AT("-",M->DTW_HORATR)
	If nPosHorTr <> 0
		cHoratr := Stuff(cHoratr,nPosHorTr,1,"0")
		nHorAju := HoraToInt(Stuff(cHoratr,nPosHorTr,1,""))*-1
	Else
		nHorAju := Val(Subs(cHoratr,1,3))+HoraToInt("00:"+Right(cHoratr,2))
	EndIf
	lRet := AtVldHora(cHoratr,.T.)

	If lRet
		cAliasQry := GetNextAlias()
		cQuery := " SELECT DTW_DATPRE, DTW_HORPRE, DTW_SEQUEN "
		cQuery += " 	FROM " + RetSqlName("DTW")
		cQuery += " 	WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
		cQuery += " 		AND DTW_FILORI = '" + M->DUA_FILORI + "' "
		cQuery += " 		AND DTW_VIAGEM = '" + M->DUA_VIAGEM + "' "
		cQuery += " 		AND DTW_ATIVID = '" + cAtivChg      + "' "
		cQuery += " 		AND DTW_STATUS = '" + StrZero(1,Len(DTW->DTW_STATUS)) + "' "
		cQuery += " 		AND D_E_L_E_T_ = ' ' "
		cQuery += " 		AND DTW_SEQUEN = ( SELECT MIN(DTW_SEQUEN) "
		cQuery += " 									FROM " + RetSqlName("DTW")
		cQuery += " 									WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
		cQuery += " 										AND DTW_FILORI = '" + M->DUA_FILORI + "' "
		cQuery += " 										AND DTW_VIAGEM = '" + M->DUA_VIAGEM + "' "
		cQuery += " 										AND DTW_ATIVID = '" + cAtivChg      + "' "
		cQuery += " 										AND DTW_STATUS = '" + StrZero(1,Len(DTW->DTW_STATUS)) + "' "
		cQuery += " 										AND D_E_L_E_T_ = ' ' ) "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		TcSetField(cAliasQry,"DTW_DATPRE","D",8,0)
		If (cAliasQry)->(!Eof())
			dDataChg := (cAliasQry)->DTW_DATPRE
			cHoraChg := Transform((cAliasQry)->DTW_HORPRE,"@R 99:99")
			TMA360CalAj(@dDataChg,@cHoraChg,nHorAju)
			GDFieldPut("DUA_DATCHG",dDataChg,n)
			GDFieldPut("DUA_HORCHG",cHoraChg,n)
		EndIf
		(cAliasQry)->(DbCloseArea())
		RestArea( aArea )
	EndIf

	dDataChg	:= GdFieldGet('DUA_DATCHG',n)
	cHoraChg := Transform(GdFieldGet('DUA_HORCHG',n),"@R 99:99")

	If !Empty(dDataChg) .And. !Empty(cHoraChg)
		//-- Verifica a ultima saida da viagem
		cAliasQry := GetNextAlias()
		cQuery := " SELECT DTW_DATREA,DTW_HORREA "
		cQuery += " 	FROM " + RetSqlName("DTW")
		cQuery += " 	WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
		cQuery += " 		AND DTW_FILORI = '" + M->DUA_FILORI + "' "
		cQuery += " 		AND DTW_VIAGEM = '" + M->DUA_VIAGEM + "' "
		cQuery += " 		AND DTW_ATIVID = '" + cAtivSai      + "' "
		cQuery += " 		AND DTW_STATUS = '" + StrZero(2,Len(DTW->DTW_STATUS)) + "' "
		cQuery += " 		AND D_E_L_E_T_ = ' ' "
		cQuery += " 		AND DTW_SEQUEN = ( SELECT MAX(DTW_SEQUEN) "
		cQuery += " 									FROM " + RetSqlName("DTW")
		cQuery += " 									WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
		cQuery += " 										AND DTW_FILORI = '" + M->DUA_FILORI + "' "
		cQuery += " 										AND DTW_VIAGEM = '" + M->DUA_VIAGEM + "' "
		cQuery += " 										AND DTW_ATIVID = '" + cAtivSai      + "' "
		cQuery += " 										AND DTW_STATUS = '" + StrZero(2,Len(DTW->DTW_STATUS)) + "' "
		cQuery += " 										AND D_E_L_E_T_ = ' ' ) "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		TcSetField(cAliasQry,"DTW_DATREA","D",8,0)
		If (cAliasQry)->(!Eof())
			dDataSai := (cAliasQry)->DTW_DATREA
			cHoraSai := HoraToInt(Transform((cAliasQry)->DTW_HORREA,"@R 99:99"))
			If ( dDataChg < dDataSai ) .Or. ( dDataSai == dDataChg .And. HoraToInt(cHoraChg) < cHoraSai )
				Help('',1,'TMSA36085') // "Hora invalida e/ou data invalida em relaçao a saida da viagem."
				lRet := .F.
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
		RestArea( aArea )
	EndIf

ElseIf cCampo $ 'M->DUV_ODOENT'
	If M->DUV_ODOENT <= GdFieldGet('DUV_ODOSAI',n)
		lRet := .F.
	EndIf
ElseIf cCampo $ 'M->DUA_DATSAI'
	If ( M->DUA_DATSAI < GdFieldGet('DUA_DATCHG',n) ) .Or. ( M->DUA_DATSAI > dDataBase )
		lRet := .F.
	EndIf
	If lAllMark
	   cDescri := M->DUA_DATSAI
		For nX:=n To Len(aCols)
			GdFieldPut('DUA_DATSAI',cDescri,nX)
		Next
		If !l360Auto
			oTmsGetD:oBrowse:Refresh( .T. )
		EndIf
	EndIf
ElseIf cCampo $ 'M->DUA_HORSAI'
	lRet := AtVldHora(M->DUA_HORSAI)
	If lRet
		lRet := ValDatHor(GdFieldGet('DUA_DATSAI',n),M->DUA_HORSAI,GdFieldGet('DUA_DATCHG',n),GdFieldGet('DUA_HORCHG',n))
	EndIf
	If lAllMark
	   cDescri := M->DUA_HORSAI
		For nX:=n To Len(aCols)
			GdFieldPut('DUA_HORSAI',cDescri,nX)
		Next
		If !l360Auto
			oTmsGetD:oBrowse:Refresh( .T. )
		EndIf
	EndIf
ElseIf cCampo $ 'M->DUA_HOROCO'
	lRet := AtVldHora(M->DUA_HOROCO)
	If lRet .And. Space(1) $ M->DUA_HOROCO
		Help('',1,'TMSA36067') //"Hora Invalida !"
		lRet := .F.
	EndIf
ElseIf cCampo $ 'M->DUA_ESTOCO'
	If M->DUA_ESTOCO == StrZero(1,TamSX3('DUA_ESTOCO')[1]) // Estorna
		aMsgErr := {}
		If !Empty(M->DUA_FILORI) .And. cFilAnt <> M->DUA_FILOCO
			AAdd(aMsgErr,{ STR0033 + M->DUA_FILORI ,'',''} ) // "Ocorrência somente poderá ser estornada na filial: "
			TmsMsgErr( aMsgErr )
			lRet := .F.
		EndIf
		If lRet .And. lTMSGFE
			If !Empty(M->DUA_ORIGEM) .And. M->DUA_ORIGEM == 'SIGAGFE'
				Help('',1,'TMSA360B2',,DUA->DUA_ORIGEM,3,16)  //Não é permitido o estorno da ocorrência. Esta ocorrência foi gerada por outro módulo:
				lRet := .F.
			EndIf
		EndIf
		//-- Não permite estornar se houver documento de serviço adicional relacionado
		If FindFunction("TMSA853OSa")
			aDocSrvAdd := TMSA853OSa(M->DUA_FILOCO, M->DUA_NUMOCO, M->DUA_FILORI, M->DUA_VIAGEM, GdFieldGet('DUA_SEQOCO', n))
			If aDocSrvAdd[1]
				Help(" ", 1, "TMSA360E7", , aDocSrvAdd[5], 2, 1)
				lRet := .F.
			EndIf
		EndIf
		DTQ->(DbSetOrder(2))   // DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
		If DTQ->(DbSeek(xFilial("DTQ")+M->DUA_FILORI+M->DUA_VIAGEM)) .And. DTQ->DTQ_STATUS == StrZero(3,Len(DTQ->DTQ_STATUS))
			lEncerr := .T.
		EndIf
		
		//Valida Comprovante de Entrega
		If lRet .And. DT2->DT2_TIPOCO $ (StrZero(1,Len(DT2->DT2_TIPOCO)) + "|" + StrZero(6,Len(DT2->DT2_TIPOCO)) + "|" + StrZero(7,Len(DT2->DT2_TIPOCO)) )   //-- Tipo de Ocorrência 01 (encerra processo, inicialmente, mas podem entrar 06 e 07 - pendências)
			 If !Empty(GdFieldGet('DUA_FILDOC')) .And. !Empty(GdFieldGet('DUA_DOC')) .And. !Empty(GdFieldGet('DUA_SERIE'))
			 	DT6->(DbSetOrder(1))
			 	If DT6->(DbSeek(xFilial('DT6')+GdFieldGet('DUA_FILDOC')+GdFieldGet('DUA_DOC')+GdFieldGet('DUA_SERIE'))) .And. !Empty(DT6->DT6_CHVCTE)
			 		lRet := A360VldCE(StrTokArr(DT6->DT6_CHVCTE, ""), nOpcVld)
			 		If !lRet			 			
						Help('',1,'TMSA360F7') //Problemas com comprovante de Entrega Eletrôncico. Acesse a rotina de monitoramento (TMSAE71) para maiores detalhes"
					EndIf
			 	EndIf
			 EndIf
		EndIf 
		
		If lRet
			If lAllMark .AND. !lTMS360TOk
				nX := 1
			Else
				nX := n
			EndIf
			While nX < Len(aCols)+1
				
				DT2->(DbSetOrder(1))
				DT2->(DbSeek(xFilial('DT2')+GdFieldGet('DUA_CODOCO',nX)))
				If (DT2->DT2_TIPOCO == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND <> StrZero(3,Len(DT2->DT2_TIPPND)) ).Or. DT2->DT2_TIPOCO == StrZero(1,Len(DT2->DT2_TIPOCO))
					//Verifica se o tipo de ocorrencia e do tipo que gera pendencia e diferente de Sobra , e se for verifica se ja foi indenizado ou encerrado
					DUU->( DbSetOrder(3))
					If DUU->( DbSeek(cSeek := xFilial('DUU')+M->DUA_FILDOC+M->DUA_DOC+M->DUA_SERIE,.F.))
						Do While DUU->( cSeek == DUU_FILIAL+DUU_FILDOC+DUU_DOC+DUU_SERIE ) .AND. (M->DUA_CODOCO == DUU->DUU_CODOCO)
							If DUU->DUU_STATUS > StrZero(1,Len( DUU->DUU_STATUS )) .And. DUU->(DUU_FILORI+DUU_VIAGEM) == M->DUA_FILORI+M->DUA_VIAGEM
								lRet := .F.
								aAdd(aHelpErr, {"TMSA36090", GdFieldGet('DUA_SEQOCO',nX)}) //"Nao é possível estornar essa ocorrência pois existem pendências que não estao em aberto."
								Exit
							EndIf
							DUU->( DbSkip() )
						EndDo
					EndIf
				EndIf
				lDocEntre:= .F.
				If DT2->DT2_TIPOCO $ "06/09" .And. nTmsdInd > 0
					lDocEntre:= .T.
				EndIf
				If !Empty(M->DUA_VIAGEM) .And. lRet
					//-- Se a viagem estiver encerrada permite estornar somente ocorrencias do tipo "informativa", "Transferencia", "Receita", "Despesa", "Receita x Despesa", "Cob.Tent.Entrega","Cob.Retorno"
					If	!(DT2->DT2_TIPOCO $ "05/08/16/17/18/19/20")
						lDocRed:= TMA360IDFV(GdFieldGet("DUA_FILDOC",nX), GdFieldGet("DUA_DOC",nX), GdFieldGet("DUA_SERIE",nX), .F., M->DUA_FILORI, M->DUA_VIAGEM )

						If !lDocEntre .And. !lDocRed .And. !lAjusta
							TMSChkViag( M->DUA_FILORI, M->DUA_VIAGEM,.F.,.F.,.F.,.F., , , ,.F.,.F., aMsgErr,.F.,.T., , ,.F.)
							If !Empty( aMsgErr )
								aAdd(aHelpErr, {"TMSA36088", GdFieldGet('DUA_SEQOCO',nX)}) //"Documento está em uma viagem encerrada. O estorno da ocorrencia nao sera possivel."
								lRet := .F.
							EndIf
						EndIf
						//-- Verifica se ja foi gerado contrato de carreteiro para a viagem.
						//-- Para verificacao do estorno, esta sendo utilizado o mesmo conceito
						//-- para geracao de contrato de carreteiro.
						lValSerTMS := .F.
						If (DT2->DT2_TIPOCO == StrZero(1,Len(DT2->DT2_TIPOCO)) .Or. ;
							DT2->DT2_TIPOCO == StrZero(4,Len(DT2->DT2_TIPOCO)).And. DT2->DT2_RESOCO <> '3')

							If !Empty(DT2->DT2_SERTMS)
								If Iif(DT2->DT2_SERTMS == StrZero(3, Len(DT2->DT2_SERTMS)), !lEntSoco , IIf(DT2->DT2_SERTMS == StrZero(1, Len(DT2->DT2_SERTMS)) , !lColSoco , .F.))
									lValSerTMS := .T.
								EndIf
							Else
								If !Empty(GDFieldGet( 'DUA_FILDOC', nX )) .AND. !Empty(GDFieldGet( 'DUA_DOC', nX )) .AND. !Empty(GDFieldGet( 'DUA_SERIE', nX ))
									cSerTMS:= TMSA360DUD( GdFieldGet("DUA_FILDOC",nX), GdFieldGet("DUA_DOC",nX) , GdFieldGet("DUA_SERIE",nX))
									If Iif(cSerTMS == StrZero(3, Len(DT6->DT6_SERTMS)), !lEntSoco , Iif(cSerTMS == StrZero(1, Len(DT6->DT6_SERTMS)) , !lColSoco , .F.))
										lValSerTMS := .T.
									EndIf
								EndIf
							EndIf

							If lValSerTMS
								DTY->(DbSetOrder(2))
								If DTY->(DbSeek(xFilial('DTY') + M->DUA_FILORI + M->DUA_VIAGEM)) .And. DTY->DTY_FILORI == cFilAnt
									AAdd( aMsgErr, { STR0026 + M->DUA_VIAGEM ,'',''} ) //"Ja foi gerado Contrato de Carreteiro para a Viagem "
									TmsMsgErr( aMsgErr )
									lRet := .F.
								EndIf
							EndIf

						EndIf

						If lRet .And. DT2->DT2_TIPOCO == StrZero(13,Len(DT2->DT2_TIPOCO)) //-- Chegada Eventual
							DUD->(DbSetOrder(1))
							If DUD->(DbSeek(cSeek := xFilial('DUD')+GdFieldGet('DUA_FILDOC',nX)+GdFieldGet('DUA_DOC',nX)+GdFieldGet('DUA_SERIE',nX)+cFilAnt))
								Do While !DUD->(Eof()) .And. DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI) == cSeek
									If DUD->DUD_STATUS == StrZero(9,Len(DUD->DUD_STATUS)) //-- Cancelado
										DUD->(dbSkip())
										Loop
									EndIf
									If !Empty(DUD->DUD_VIAGEM)
										aAdd(aHelpErr, {"TMSA36068", GdFieldGet('DUA_SEQOCO',nX) + " - " + DUD->DUD_FILORI + "/" + DUD->DUD_VIAGEM}) //"Este Documento esta vinculado a Viagem."
										lRet := .F.
										Exit
									EndIf
									DUD->(dbSkip())
								EndDo
							EndIf
						EndIf
					EndIf
				EndIf

				//-- Verifica se ocorrencia do tipo "Indicado para Entrega" e servico "Entrega"
				If lRet .AND. DT2->DT2_TIPOCO == StrZero(5,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_CODOCO == cOcorBx  .And. (M->DUA_SERTMS == StrZero(3,Len(DUA->DUA_SERTMS)) .OR. Empty(M->DUA_SERTMS))
					cSeek	:= M->( DUA_FILDOC + DUA_DOC + DUA_SERIE )
					//-- Verifica se o documento Redespacho
					DFV->( DbSetOrder ( 2 ) )
					If DFV->( DbSeek (xFilial("DFV") + cSeek ) )
						aAreaDT2		:= DT2->( GetArea() )
						aAreDUAR		:= DUA->( GetArea() )
						lOcoRed       := .T.
						//-- Seleciona todos apontamentos deste documento
						DUA->( DbSetOrder ( 7 ) )
						If DUA->( DbSeek (xFilial("DUA") + cSeek ) )
							//-- Se tiver algum apontamento de encerra processo p/ este documento, NAO permite o estorna
							DT2->( DbSetOrder ( 1 ) )
							While DUA->(!EOF()) .And. ( DUA->(DUA_FILDOC + DUA_DOC + DUA_SERIE) == cSeek) .And. ( DUA->DUA_SERTMS == StrZero(3,Len(DUA->DUA_SERTMS)) .OR. Empty(M->DUA_SERTMS) )
								If DT2->( DbSeek ( xFilial("DT2") + DUA->(DUA_CODOCO) ) ) .And. DT2->DT2_TIPOCO == '01'
									aAdd(aHelpErr, {"TMSA36096", GdFieldGet('DUA_SEQOCO',nX)}) //"Documento do tipo 'Redespacho' existe apontamento 'Encerra Processo'."
									lRet := .F.
								EndIf
								DUA->( DbSkip())
							EndDo
						EndIf
						RestArea(aAreaDT2)
						RestArea(aAreDUAR)
					EndIf
				EndIf
				// Verifica se tem contrato de Redespachante p/ o Documento.
				DFV->( DbSetOrder ( 2 ) )
				If lRet .AND. DFV->( DbSeek( xFilial('DFV') + M->( DUA_FILDOC + DUA_DOC + DUA_SERIE )  ) ) .And. ;
					DT2->DT2_TIPOCO == StrZero(1,Len(DT2->DT2_TIPOCO)) .And. !Empty(DFV->DFV_NUMCTC)
					aAdd(aHelpErr, {"TMSA36097", GdFieldGet('DUA_SEQOCO',nX)}) //"Ja foi gerado Contrato de Redespachante para a Viagem."
					lRet := .F.
				EndIf
				If	lRet
					DF6->(DbSetOrder(2))
					If DF6->(DbSeek(xFilial('DF6')+GDFieldGet('DUA_FILDOC',nX)+GDFieldGet('DUA_DOC',nX)+GDFieldGet('DUA_SERIE',nX)))
						lFoundDF6 := .T.
					EndIf

					If !lFoundDF6 .And. !(Alltrim(cProg) $ "TMSA050|TMSAF60")
						If DT2->DT2_CATOCO == StrZero(2,Len(DT2->DT2_CATOCO)) //-- Por viagem
							DT5->(DbSetOrder(4))
							DUD->(DbSetOrder(2))
							DUD->(DbSeek(cSeekDUD := xFilial('DUD')+M->DUA_FILORI+M->DUA_VIAGEM))
							While DUD->(!Eof() .And. DUD_FILIAL+DUD_FILORI+DUD_VIAGEM == cSeekDUD)
								If DT2->DT2_TIPOCO <> StrZero(5, Len(DT2->DT2_TIPOCO)) // Diferente de Informativa
									If DT5->(DbSeek(xFilial('DT5')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))
										If DT5->DT5_STATUS == StrZero(5,Len(DT5->DT5_STATUS)) //-- Documento Informado
											aAdd(aHelpErr, {"TMSA36069", GdFieldGet('DUA_SEQOCO',nX)}) //"Existem ordens de coleta na viagem que ja estão com status Documento Informado."
											lRet := .F.
											Exit
										EndIf
									EndIf
								EndIf
								DUD->(dbSkip())
							EndDo
						Else
							If DT2->DT2_TIPOCO <> StrZero(5, Len(DT2->DT2_TIPOCO))
								DT5->(DbSetOrder(4))
								If DT5->(DbSeek(xFilial('DT5') + GDFieldGet('DUA_FILDOC',nX) + GDFieldGet('DUA_DOC',nX) + GDFieldGet('DUA_SERIE',nX)))
									If DT5->DT5_STATUS == StrZero(5,Len(DT5->DT5_STATUS))
										aAdd(aHelpErr, {"TMSA36058", GdFieldGet('DUA_SEQOCO',nX)}) //"Só será permitido o estorno de solicitação diferente de 'Documento Informado'."
										lRet := .F.
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf

				// EXECUTAR A VALIDACAO APENAS PARA TIPO DE OCORRENCIA RETORNA DOCUMENTO
				If lRet .And. !Empty(DUA->DUA_FILORI) .And. !Empty(DUA->DUA_VIAGEM) .And. DT2->DT2_TIPOCO == StrZero(4,Len(DT2->DT2_TIPOCO))

					// BUSCAR ULTIMO REGISTRO EXISTENTE NA TABELA DUD, CONTENDO NUMERO DE VIAGEM
					cAliasQry := GetNextAlias()
					cQuery := " SELECT (MAX(R_E_C_N_O_)) R_E_C_N_O_"
					cQuery += "   FROM " + RetSqlName("DUD")
					cQuery += "  WHERE DUD_FILIAL = '" + xFilial('DUD') + "' "
					cQuery += "    AND DUD_FILDOC = '" + GdFieldGet('DUA_FILDOC',nX) + "' "
					cQuery += "    AND DUD_DOC = '" + GdFieldGet('DUA_DOC',nX) + "' "
					cQuery += "    AND DUD_SERIE = '" + GdFieldGet('DUA_SERIE',nX) + "' "
					If !Empty(DT2->DT2_SERTMS)
						cQuery += "    AND DUD_SERTMS = '" + DT2->DT2_SERTMS + "' "
					EndIf
					cQuery += "    AND DUD_FILORI = '" + DUA->DUA_FILORI + "' "
					cQuery += "    AND DUD_VIAGEM <> '' "
					cQuery += "    AND D_E_L_E_T_ = ' ' "
					cQuery := ChangeQuery( cQuery )
					dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

					If (cAliasQry)->R_E_C_N_O_ > 0
						aAreaDUD := DUD->( GetArea() )

						DUD->(dbGoto((cAliasQry)->R_E_C_N_O_))

						If DUD->DUD_VIAGEM != DUA->DUA_VIAGEM .And. Empty(DUD->DUD_CHVEXT)
							aAdd(aHelpErr, {"TMSA360A3", GdFieldGet('DUA_SEQOCO',nX) + " - " + DUD->DUD_VIAGEM}) //"Não é possível estornar a ocorrencia do tipo retorna documento que está amarrada à viagem."
							lRet = .F.
						EndIf
						RestArea( aAreaDUD )
					EndIf

					(cAliasQry)->(dbCloseArea())
				EndIf

				If lRet .And. __lPyme .And. DT2->DT2_TIPOCO == StrZero(4,Len(DT2->DT2_TIPOCO))

					If !Empty(DUA->DUA_NUMROM)

						// BUSCAR ULTIMO REGISTRO EXISTENTE NA TABELA DUD, CONTENDO NUMERO DE VIAGEM
						cAliasQry := GetNextAlias()
						cQuery := " SELECT (MAX(R_E_C_N_O_)) R_E_C_N_O_"
						cQuery += "   FROM " + RetSqlName("DUD")
						cQuery += "  WHERE DUD_FILIAL = '" + xFilial('DUD') + "' "
						cQuery += "    AND DUD_FILDOC = '" + GdFieldGet('DUA_FILDOC',nX) + "' "
						cQuery += "    AND DUD_DOC = '" + GdFieldGet('DUA_DOC',nX) + "' "
						cQuery += "    AND DUD_SERIE = '" + GdFieldGet('DUA_SERIE',nX) + "' "
						If !Empty(DT2->DT2_SERTMS)
								cQuery += "    AND DUD_SERTMS = '" + DT2->DT2_SERTMS + "' "
						EndIf
						cQuery += "    AND DUD_NUMROM <> '' "
						cQuery += "    AND D_E_L_E_T_ = ' ' "
						cQuery := ChangeQuery( cQuery )
						dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

						If (cAliasQry)->R_E_C_N_O_ > 0
							aAreaDUD := DUD->( GetArea() )

							DUD->(dbGoto((cAliasQry)->R_E_C_N_O_))

							If DUD->DUD_NUMROM != DUA->DUA_NUMROM
								aAdd(aHelpErr, {"TMSA360A3", GdFieldGet('DUA_SEQOCO',nX) + " - " + DUD->DUD_NUMROM}) //"Não é possível estornar a ocorrencia do tipo retorna documento que está amarrada à viagem."
								lRet = .F.
							EndIf
							RestArea( aAreaDUD )
						EndIf

						(cAliasQry)->(dbCloseArea())
					EndIf
				EndIf

				//-- Permitir excluir ocorrencia apenas do tipo diferente de informativa.
				If lRet .And. lEncerr .And. DT2->(DbSeek(xFilial('DT2')+GdFieldGet('DUA_CODOCO',nX))) .And. DT2->DT2_TIPOCO != StrZero(5,Len(DT2->DT2_TIPOCO))
					aAdd(aHelpErr, {"TMSA36088", GdFieldGet('DUA_SEQOCO',nX)}) //"Documento está em uma viagem encerrada. O estorno da ocorrencia nao sera possivel."
					lRet := .F.
				EndIf

				If lRet
					DT2->(DbSetOrder(1))
					DT2->(DbSeek(xFilial('DT2')+GdFieldGet('DUA_CODOCO',nX)))
					If DT2->DT2_TIPOCO == StrZero(4,Len(DT2->DT2_TIPOCO))  // RETORNA DOCUMENTO
						cAliasQry := GetNextAlias()
						cQuery := " SELECT (MAX(R_E_C_N_O_)) R_E_C_N_O_"
						cQuery += "   FROM " + RetSqlName("DUD")
						cQuery += "  WHERE DUD_FILIAL = '" + xFilial('DUD') + "' "
						cQuery += "    AND DUD_FILDOC = '" + GdFieldGet('DUA_FILDOC',nX) + "' "
						cQuery += "    AND DUD_DOC = '" + GdFieldGet('DUA_DOC',nX) + "' "
						cQuery += "    AND DUD_SERIE = '" + GdFieldGet('DUA_SERIE',nX) + "' "
						If !Empty(DT2->DT2_SERTMS)
							cQuery += "    AND DUD_SERTMS = '" + DT2->DT2_SERTMS + "' "
						EndIf
						cQuery += "    AND DUD_FILORI = '" + DUA->DUA_FILORI + "' "
						cQuery += "    AND DUD_VIAGEM <> '' "
						cQuery += "    AND D_E_L_E_T_ = ' ' "
						cQuery := ChangeQuery( cQuery )
						dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

						If (cAliasQry)->R_E_C_N_O_ > 0
							aAreaDUD := DUD->( GetArea() )

							DUD->(dbGoto((cAliasQry)->R_E_C_N_O_))

							If DUD->DUD_VIAGEM != DUA->DUA_VIAGEM
								lRet := .F.
							EndIf
							RestArea( aAreaDUD )
						EndIf

						(cAliasQry)->(dbCloseArea())
					EndIf
				EndIf

				//-- Impede Estorno De Ocorrencias (Receita/Despesa) Quando Existe Documento Informado Nos Campos De Controle Da Rentabilidade
				DT2->(DbSetOrder(1))
				If lRet .AND. DT2->(DbSeek(xFilial('DT2') + GdFieldGet('DUA_CODOCO',nX))) .And. aScan( aRecDep , DT2->DT2_TIPOCO ) > 0

					If DUA->(ColumnPos("DUA_NUMCTE")) > 0 //-- Verifica Existência Do Campo
						//-- Verifica Se Campo Está Preenchido
						If !Empty(GdFieldGet( 'DUA_NUMCTE',nX ))
							aAdd(aHelpErr, {"TMSA360D7", GdFieldGet('DUA_SEQOCO',nX) + " - " + GdFieldGet('DUA_NUMCTE',nX) + "/" + GdFieldGet('DUA_SERCTE',nX)}) //"Estorno Não Pode Ser Executado Pois Existem CTEs Gerados Para Esta Ocorrência! Documento."
							lRet = .F.
						EndIf
					EndIf

					If lRet .AND. DUA->(ColumnPos("DUA_NUMCTC")) > 0 //-- Verifica Existência Do Campo
						//-- Verifica Se Campo Está Preenchido
						If !Empty(GdFieldGet( 'DUA_NUMCTC',nX ))

							//-- Confirma a Existencia Do Contrato De Carreteiro
							DbSelectArea("DTY")
							DbSetOrder(1) //-- DTY_FILIAL+DTY_NUMCTC
							If MsSeek( FWxFilial("DTY") + GdFieldGet( 'DUA_NUMCTC',nX ), .F. )
								aAdd(aHelpErr, {"TMSA360D8", GdFieldGet('DUA_SEQOCO',nX) + " - " + GdFieldGet('DUA_NUMCTE',nX)}) //"Estorno Não Pode Ser Executado Pois Existe Contrato De Carreteiro Gerado Para Esta Ocorrência! Documento."
								lRet = .F.
							EndIf
						EndIf
					EndIf
				EndIf

				If lRet .And. lDUAPrzEnt  
					If A360OcoPrz(GdFieldGet('DUA_CODOCO',nX)) 
						lRet:= A360EstPrz(GdFieldGet('DUA_FILDOC',nX),GdFieldGet('DUA_DOC',nX),GdFieldGet('DUA_SERIE',nX),M->DUA_FILOCO,M->DUA_NUMOCO,GdFieldGet('DUA_SEQOCO',nX),;
						       M->DUA_FILORI,M->DUA_VIAGEM,@aHelpErr,.T.,.T.,)
					EndIf		   
				EndIf
				
				If lRet
					aCols[nX][GDFieldPos('DUA_ESTOCO')] := StrZero(1,TamSX3('DUA_ESTOCO')[1]) //--Estornar
				ElseIf nX = n
					aCols[nX][GDFieldPos('DUA_ESTOCO')] := "2"
					lRetSel := .F.
				EndIf
				lRet := .T.
				
				If (lAllMark .AND. !lTMS360TOk) .Or. (lTmsRdpU .And. lOcoRed)
					nX++
				Else
					nX := Len(aCols)+1
				EndIf
			End

			For nX := 1 To Len(aHelpErr)
				cHelpErr += aHelpErr[nX][2] + ","
			Next

			If !Empty(cHelpErr)
				Help(" ", 1, aHelpErr[1][1], , STR0011 + ":" + Left(cHelpErr, Len(cHelpErr)-1) + ".", 4, 1)
			EndIf

			cHelpErr := ""
			aHelpErr := {}
			lRet := lRetSel
		EndIf
	Else
		If lTmsRdpU .And. GdFieldGet('DUA_ESTOCO', n)  == '1'  //Lote de Redespacho unico nao podera estornar apenas um documento com ocorrencia MV_OCORRDP
			lDocRed:= TMA360IDFV(GdFieldGet("DUA_FILDOC",n), GdFieldGet("DUA_DOC",n), GdFieldGet("DUA_SERIE",n), .F., M->DUA_FILORI, M->DUA_VIAGEM )

			If lDocRed
				aAreaDT2 := DT2->( GetArea() )
				DT2->(DbSetOrder(1))
				If DT2->(DbSeek(xFilial('DT2')+GdFieldGet('DUA_CODOCO',n)))
					If DT2->DT2_TIPOCO == StrZero(5,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_CODOCO == cOcorBx .And.	M->DUA_SERTMS == StrZero(3,Len(DUA->DUA_SERTMS)) .OR. Empty(DT2->DT2_SERTMS)
			 			For nX := 1 To Len(aCols)
			 				DT2->(DbSeek(xFilial('DT2')+GdFieldGet('DUA_CODOCO',nX)))
							If DT2->DT2_TIPOCO == StrZero(5,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_CODOCO == cOcorBx
								aCols[nX][GDFieldPos('DUA_ESTOCO')] := '2' //Não
							EndIf
						Next nX
						If !l360Auto
							oTmsGetD:oBrowse:Refresh( .T. )
						EndIf
					EndIf
				EndIf
				aAreaDT2 := DT2->( GetArea() )
			EndIf
		EndIf
	EndIf
ElseIf cCampo $ 'M->DUA_DATOCO'
	If !Empty(M->DUA_FILORI) .And. !Empty(M->DUA_VIAGEM)
		DTQ->(DbSetOrder(2))   // DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
		If DTQ->(DbSeek(xFilial("DTQ")+M->DUA_FILORI+M->DUA_VIAGEM)) .And. DTQ->DTQ_DATGER > M->DUA_DATOCO
			Help("",1,"TMSA36070",,STR0011 + ':' + GdFieldGet('DUA_SEQOCO',n),3,01 ) //"Data da Ocorrencia nao pode ser menor que a data de geracao da Viagem"
			Return( .F. )
		EndIf
   Else
      cFilDoc := GDFieldGet('DUA_FILDOC' ,n)
      cDoc    := GDFieldGet('DUA_DOC'    ,n)
      cSerie  := GDFieldGet('DUA_SERIE'  ,n)
      If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
	      DT6->(DbSetOrder(1))
         If DT6->(DbSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie)) .And. DT6->DT6_DATEMI > M->DUA_DATOCO
		  	   Help("",1,"TMSA36075",,STR0011  + ':' + GdFieldGet('DUA_SEQOCO',n),3,01 ) //"Data da Ocorrencia nao pode ser menor que a data do Documento"
			   Return( .F. )
		 EndIf
      EndIf
	EndIf
ElseIf cCampo $ 'M->DUA_RECEBE'
	If lAllMark
	   cDescri := M->DUA_RECEBE
		For nX:=n To Len(aCols)
			GdFieldPut('DUA_RECEBE',cDescri,nX)
		Next
		If !l360Auto
			oTmsGetD:oBrowse:Refresh( .T. )
		EndIf
	EndIf
ElseIf cCampo == "M->DUA_FILPND"
	If DT2->DT2_TIPOCO <> StrZero(5,Len(DT2->DT2_TIPOCO))
		lRet    := TM360FilPnd(M->DUA_FILPND,.T.)
		If !lRet
			Help("",1,"TMSA36080") //"Filial nao esta configurada para descarga da rota."
		EndIf
	EndIf
ElseIf cCampo == "M->DUA_ODOCHG"
	DT2->(DbSetOrder(1))
	If DT2->(DbSeek(xFilial("DT2")+ M->DUA_CODOCO))
		If DT2->DT2_ODOCHG <> '1'
			lRet := .F.
			Help("",1,'TMSA36086') //-- 'Esta ocorrencia nao esta configurada para permitir informar a quilometragem de chegada do veiculo.'
		EndIf
	EndIf
ElseIf cCampo == "M->DUA_PRZENT"   
	If !Empty(DT6->DT6_PRZENT) .And. !Empty(M->DUA_PRZENT) .And. M->DUA_PRZENT < DT6->DT6_DATEMI
		lRet := .F.
		Help("",1,"TMSA360F8") //A Data do Prazo de Entrega informada não pode ser menor que a Data de Emissão do Documento de Transporte (CTe).                  
	EndIf	
EndIf

	//-- Rentabilidade/Ocorrencia -> Tratamento Campo ( Código Fornecedor )
	If cCampo == "M->DUA_CODFOR" .Or. cCampo == "M->DUA_LOJFOR"

		If cCampo == 'M->DUA_CODFOR'
			cCodFor:= M->DUA_CODFOR
			cLojFor:= Iif( !Empty( GDFieldGet('DUA_LOJFOR',n) ), GDFieldGet('DUA_LOJFOR',n), "" )
		ElseIf cCampo == 'M->DUA_LOJFOR'
			cCodFor:= Iif( !Empty( GDFieldGet('DUA_CODFOR',n) ), GDFieldGet('DUA_CODFOR',n), "" )
			cLojFor:= M->DUA_LOJFOR
		EndIf

		//-- Verifica Se Fornecedor Existe
		DbSelectArea("SA2")
		DbSetOrder(1)
		If MsSeek(FWxFilial("SA2") + cCodFor + cLojFor, .F. )

			//----------------------------------------------------------------------------
			//-- Não Permite Fornecedores Relacionados No Complemento Da Viagem
			//----------------------------------------------------------------------------
			//-- Veículos da Viagem
			DbSelectArea("DTR")
			DTR->(DbSetOrder(1)) //-- DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_ITEM
			MsSeek( FWxFilial('DTR') + M->DUA_FILORI + M->DUA_VIAGEM, .F. )

			While DTR->(!Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == FWxFilial('DTR') + M->DUA_FILORI + M->DUA_VIAGEM

				//-- Cadastro De Veículos
				DbSelectArea("DA3")
				DbSetOrder(1) //-- DA3_FILIAL+DA3_COD
				MsSeek( FWxFilial('DA3') + DTR->DTR_CODVEI )

				If ( DA3->DA3_CODFOR + DA3->DA3_LOJFOR == cCodFor + cLojFor ) .And. (!DA3->DA3_FROVEI $ "2/3" )
					lRet := .F.
					Help("",1,'TMSA360C8') //-- 'Fornecedor Não Pode Ser o Mesmo Que o Fornecedor Do Complemento Da Viagem!'
				EndIf

				DTR->(DbSkip())
			EndDo
		Else
			lRet := .f.
			Help( '', 1, 'REGNOIS' ) //"Nao existe registro relacionado a este codigo"
		EndIf

		If lRet .And. (lTMS3GFE .Or. lTmsRdpU)
			//-- Verifica se o documento nao é Redespacho
			DFV->( DbSetOrder ( 2 ) )
			If !DFV->( DbSeek (xFilial("DFV") + GDFieldGet('DUA_FILDOC' ,n) + GDFieldGet('DUA_DOC' ,n) + GDFieldGet('DUA_SERIE' ,n) ) )
				//-- Nao permitir informar o Fornecedor diferente do Redespacho Adicional da Viagem
				If !Empty(cCodFor) .And. !Empty(cLojFor)
					lRet:= TmsRedAdic(M->DUA_FILORI,M->DUA_VIAGEM,GDFieldGet('DUA_FILDOC' ,n),GDFieldGet('DUA_DOC' ,n),GDFieldGet('DUA_SERIE' ,n),cCodFor,cLojFor)
					If !lRet
						Help("",1,'TMSA360D9') //-- 'Fornecedor não pode ser diferente do Fornecedor do Redespacho Adicional da Viagem!'
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	//-- Rentabilidade/Ocorrencia -> Tratamento Campo ( Valor Informado )
	If lRet .And. cCampo == "M->DUA_VALINF"

		//-- Verifica Se Não é Rotina Automática e Se Valor Foi Informado
		If !l360Auto .And. M->DUA_VALINF <= 0
			DT2->(DbSetOrder(1))
			If	MsSeek(xFilial('DT2') + GdFieldGet('DUA_CODOCO',n),.F.)
				If 	( Empty(DT2->DT2_CDTIPO ) .And.;
					(DT2->DT2_TIPOCO == StrZero(16,Len(DT2->DT2_TIPOCO)) .Or. ;
					 DT2->DT2_TIPOCO == StrZero(17,Len(DT2->DT2_TIPOCO)) .Or. ;
					 DT2->DT2_TIPOCO == StrZero(18,Len(DT2->DT2_TIPOCO))))

					lRet := .f.

					HELP('',1,'TMSA360E0',, DT2->DT2_CODOCO +;							//-- Valor Zero Não é Permitido Para Ocorrência: ####
								STR0104 + Alltrim(RetTitle("DUA_VALINF")) + " DUA_VALINF" +;	//-- Campo: ##########
								STR0101 + StrZero(nX,05)  ,4,1)									//-- Linha: #####

				EndIf
			EndIf
		EndIf
	EndIf

	//-- Rentabilidade/Ocorrencia -> Tratamento Campo ( Valor Despesa )
	If lRet .And. cCampo == "M->DUA_VLRDSP"

		//-- Verifica Se Não é Rotina Automática e Se Valor Foi Informado
		If !l360Auto .And. M->DUA_VLRDSP <= 0
			DT2->(DbSetOrder(1))
			If	DT2->(MsSeek(xFilial('DT2') + GdFieldGet('DUA_CODOCO',n),.F.))
				If !Empty(DT2->DT2_CDTIPO)
				 	If M->DUA_VALINF > 0
				 		lRet	:= .T.
					EndIf
				Else
					If DT2->DT2_ALTVLR == '2' //-- Altera Valores Na Liberação = '2' Não

						HELP('',1,'TMSA360E0',, DT2->DT2_CODOCO +;							//-- Valor Zero Não é Permitido Para Ocorrência: ####
							STR0104 + Alltrim(RetTitle("DUA_VLRDSP")) + " DUA_VLRDSP" +;	//-- Campo: ##########
							STR0101 + StrZero(nX,05)  ,4,1)									//-- Linha: #####

						lRet := .F.

					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	//-- Rentabilidade/Ocorrencia -> Tratamento Campo DUA_SERVIC
	If lRet .And. cCampo == "M->DUA_SERVIC"

		DbSelectArea("DT6")
		DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
		MsSeek( xFilial("DT6") + GdFieldGet("DUA_FILDOC") + GdFieldGet("DUA_DOC") + GdFieldGet("DUA_SERIE") , .f. )

		cTipTra := DT6->DT6_TIPTRA
		cSerTMS := DT6->DT6_SERTMS

		If !Empty( M->DUA_SERVIC ) .And. !Empty(DT6->DT6_TIPFRE) //-- .And. !Empty(M->DT5_CODNEG)

			aContrt := TMSContrat( DT6->DT6_CLIDEV, DT6->DT6_LOJDEV, ,M->DUA_SERVIC ,.F.,DT6->DT6_TIPFRE,,,,,,,,,,,,,,,,DT6->DT6_CODNEG)

			If Empty(aContrt)
				Help("",1,"TMSA360C9") //-- Cliente não possui contrato para o serviço informado. / Selecione um Serviço cujo cliente tenha contrato ou cadastre um contrato para o cliente.
				lRet := .f.
			EndIf
		EndIf
	EndIf

RestArea(aAreaDT6)
RestArea(aAreaDTA)
RestArea(aArea)

If !lRet
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA360Vol³ Autor ³ Antonio C Ferreira    ³ Data ³18.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica a Quantidade de Volume do Documento.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA360Vol(cCodOco, cFilDoc, cDoc, cSerie)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo da Ocorrencia.                              ³±±
±±³          ³ ExpC2 - Filial do Documento.                               ³±±
±±³          ³ ExpC3 - Codigo do Documento.                               ³±±
±±³          ³ ExpC4 - Serie do Documento.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA360Vol(cCodOco, cFilDoc, cDoc, cSerie)

Local nA      := 0
Local nQtdOco := 0
Local nPesOco := 0


DT6->( DbSetOrder( 1 ) )
DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )

DT2->(DbSetOrder(1))  // DT2_FILIAL+DT2_CODOCO

If	cCodOco != Nil .And. ! Empty( cCodOco ) .And. DT2->( DbSeek( xFilial('DT2') + cCodOco ) )

	cTipOco := DT2->DT2_TIPOCO

	//-- Se tipo da ocorrencia igual a 3 - Libera documento
	If cTipOco == StrZero( 3, Len( DT2->DT2_TIPOCO ) )

		For nA := 1 to Len(aCols)

			If	nA == n
				Loop
			EndIf

			If	GDFieldGet( 'DUA_FILDOC', nA ) == cFilDoc .And. GDFieldGet( 'DUA_DOC', nA ) == cDoc .And. GDFieldGet( 'DUA_SERIE', nA ) == cSerie
				If !DT2->(DbSeek(xFilial("DT2") + GDFieldGet( 'DUA_CODOCO', nA )))
					Help(' ', 1, 'TMSA36010',,STR0009+" "+GDFieldGet( 'DUA_CODOCO', nA ),5,11)  //-- 'Ocorrencia nao encontrada!'
					Return( 0 )
				ElseIf	cTipOco == StrZero( 3, Len( DT2->DT2_TIPOCO ) ) .And. DT2->DT2_TIPOCO == StrZero( 2, Len( DT2->DT2_TIPOCO ) ) .Or.;
						cTipOco == StrZero( 5, Len( DT2->DT2_TIPOCO ) ) .And. DT2->DT2_TIPOCO == StrZero( 3, Len( DT2->DT2_TIPOCO ) )

					nQtdOco := GDFieldGet( 'DUA_QTDOCO', nA )  // Ok. Encontrado e a Qtde pode ser parcial.
					nPesOco := GDFieldGet( 'DUA_PESOCO', nA )

					Exit
				EndIf
			EndIf

		Next nA

	Else
		// Soh gatilha volume e peso da ocorrencia se o tipo for diferente de 4 - Retorno.
		If cTipOco != StrZero( 4, Len( DT2->DT2_TIPOCO ) )
			//-- Se o Tipo for "Gera Pendencia", a qtde. de Vol. devera ser Informada
			If cTipOco <> StrZero( 6, Len( DT2->DT2_TIPOCO ) )
				nQtdOco := DT6->DT6_QTDVOL  // Se nao for Liberacao pega a Qtdade do Documento.
			EndIf
			nPesOco := DT6->DT6_PESO
		EndIf
	EndIf
EndIf

GDFieldPut( 'DUA_QTDVOL', DT6->DT6_QTDVOL	, n )
GDFieldPut( 'DUA_PESO'  , DT6->DT6_PESO		, n )
GDFieldPut( 'DUA_QTDOCO', nQtdOco	   		, n )
GDFieldPut( 'DUA_PESOCO', nPesOco			, n )
If DUA->(ColumnPos("DUA_PM3OCO")) > 0
	GDFieldPut("DUA_PM3OCO",DT6->DT6_PESOM3, n)
	GDFieldPut("DUA_VLROCO",DT6->DT6_VALMER, n)
	GDFieldPut("DUA_BASOCO",DT6->DT6_BASSEG, n)
	GDFieldPut("DUA_QTUOCO",DT6->DT6_QTDUNI, n)
EndIf

//--- Prazo de Entrega
If DUA->(ColumnPos("DUA_PRZENT")) > 0 .And. DT2->DT2_PRZENT == StrZero(1,Len(DT2->DT2_PRZENT)) 
	GDFieldPut("DUA_PRZENT",DT6->DT6_PRZENT, n)
EndIf	

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA360Vdc³ Autor ³ Antonio C Ferreira    ³ Data ³25.05.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica o Documento da Viagem                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA360Vdc( cFilDoc, cDoc, cSerie, nx, aDoc )              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento.                               ³±±
±±³          ³ ExpC2 - Codigo do Documento.                               ³±±
±±³          ³ ExpC3 - Serie do Documento.                                ³±±
±±³          ³ ExpN1 - Linha.                                             ³±±
±±³          ³ ExpA1 - Array contendo Filial,Documento e Serie.           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA360Vdc( cFilDoc, cDoc, cSerie, nx, aDoc )

Local aIndeniz    := {}
Local aPendenc    := {}
Local cTipOco     := ''
Local cCatOco     := ''
Local cUltOco	  := ''
Local nCntFor	  := 0
Local lRet		  := .T.
Local lValRet     := .F.
Local cCodOco     := ''
Local lOcoDoc     := SuperGetMv("MV_OCODOC",,.F.)   //-- Categoria da Ocorrencia por Docto.: Considera todos os Documentos da Viagem ?
Local lDocFinCanc := .F. //-- Considerar os documentos 'Cancelados' / 'Encerrados'
Local lFilDca     := .F. //-- Considerar somente os documentos com Filial de Descarga igual a Filial Atual
Local lMv_TmsOcoL := SuperGetMv("MV_TMSOCOL",.F.,.F.) //-- Permite informar a ocorrencia do documento de outra filial.
Local lSobra      := .F.
Local lMv_TmsPNDB:= SuperGetMv("MV_TMSPNDB",.F.,.F.) //-- Permite informar a ocorrencia de Pendencia para um Docto Bloqueado
Local lTMSGFE     := SuperGetMv("MV_TMSGFE",,.F.)
Local cOcorBx     := SuperGetMV ( 'MV_OCORRDP' , , ' ' )
Local lDUAPrzEnt  := DUA->(ColumnPos("DUA_PRZENT")) > 0

Default aDoc    := {}

If nx == Nil .Or. Empty(nx)
	nx := n
EndIf

l360Auto := If (Type("l360Auto") == "U",.F.,l360Auto)
cCodOco  := GDFieldGet( 'DUA_CODOCO', nx )

//-- Ocorrencias que geram indenizacoes( DUB ).
AAdd( aIndeniz, StrZero( 9,Len( DT2->DT2_TIPOCO ) ) )

//-- Ocorrencias que geram pendencias( DUU ).
AAdd( aPendenc, StrZero( 6,Len( DT2->DT2_TIPOCO ) ) )

//-- Posiciona na tabela de ocorrencia.
DT2->( DbSetOrder( 1 ) )
If	DT2->( ! DbSeek( xFilial('DT2') + cCodOco ) )
	Return( .F. )
EndIf
cTipOco := DT2->DT2_TIPOCO
cCatOco := DT2->DT2_CATOCO

lSobra:= ( cTipOco == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND == StrZero(3,Len(DT2->DT2_TIPPND)) ) //-- Sobra

If lOcoDoc .And. !Empty(M->DUA_FILORI) .And. !Empty(M->DUA_VIAGEM) //-- Considera todos os Documentos da Viagem
	If cTipOco == StrZero(5,Len(DT2->DT2_TIPOCO)) // Ocorrencia Informativa
		lDocFinCanc	:= .T. //-- Considerar os documentos 'Cancelados' / 'Encerrados'
		lFilDca     := .T. //-- Considerar somente os documentos com Filial de Descarga igual a Filial Atual
	EndIf
	TMSVerMov(M->DUA_FILORI, M->DUA_VIAGEM, , , , , aDoc,Iif(cTipOco == StrZero(5,Len(DT2->DT2_TIPOCO)),.F.,), lDocFinCanc, lFilDca,If(lMv_TmsOcoL,.T.,.F.),Iif(cTipOco == StrZero(3,Len(DT2->DT2_TIPOCO)),.T.,.F.) )
	If Len(aDoc) == 0 //-- Se a TMSVerMov() nao retornou nenhum documento valido, nao preencher a Getdados com nenhum docto.
		GDFieldPut( 'DUA_FILDOC', Space(FWGETTAMFILIAL), nx )
		GDFieldPut( 'DUA_DOC'   , Space(Len(DUA->DUA_DOC))	  , nx )
		GDFieldPut( 'DUA_SERIE' , Space(Len(DUA->DUA_SERIE)) , nx )
		GDFieldPut( 'DUA_QTDVOL', 0								  , nx )
		GDFieldPut( 'DUA_QTDOCO', 0								  , nx )
		If lDUAPrzEnt
			GDFieldPut( 'DUA_PRZENT', cTod('')					  , nx )
		EndIf
		If !l360Auto
			oTmsGetD:oBrowse:Refresh( .T. )
		EndIf
		Return( .F. )
	EndIf
Else
	TMSVerMov(M->DUA_FILORI, M->DUA_VIAGEM, cFilDoc, cDoc, cSerie, (cTipOco == StrZero( 3, Len( DT2->DT2_TIPOCO ) )), aDoc)
EndIf

For nCntFor := 1 to Len(aDoc)
	If cTipOco != StrZero( 5, Len( DT2->DT2_TIPOCO ) ) .And. cTipOco != StrZero( 17, Len( DT2->DT2_TIPOCO ) )
		cFilDoc := aDoc[nCntFor,1]
		cDoc    := aDoc[nCntFor,2]
		cSerie  := aDoc[nCntFor,3]

		DT6->( DbSetOrder( 1 ) )
		DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )

		If	DT6->DT6_PRIPER == StrZero( 1, Len( DT6->DT6_PRIPER ) )
			Help(' ', 1, 'TMSA36019')  //-- 'Documento de 1o Percurso. Nao pode ser informado!'
			lRet := .F.
			Exit
		EndIf

		//-- Nao aceita ocorrencia do tipo 02 - Bloqueia Docto, com o documento bloqueado.
		If cTipOco == StrZero( 2, Len( DT2->DT2_TIPOCO ) ) .And. DT6->DT6_BLQDOC == StrZero( 1, Len( DT6->DT6_BLQDOC ) )
			Help('',1,'TMSA36026',,STR0008 + cDoc + "/" + cSerie,5,11)			//-- Este documento ja esta bloqueado
			lRet := .F.
			Exit
		EndIf

		If	DT6->DT6_BLQDOC == StrZero( 1, Len( DT6->DT6_BLQDOC ) ) .And.;
			cTipOco != StrZero( 3, Len( DT2->DT2_TIPOCO ) ) .And.;
			cTipOco != StrZero( 8, Len( DT2->DT2_TIPOCO ) ) .And.;
			cTipOco != StrZero( 7, Len( DT2->DT2_TIPOCO ) )
				lRet := .F.
				If lMv_TmsPNDB .And. DT6->DT6_BLQDOC == StrZero( 1, Len( DT6->DT6_BLQDOC ) ) .And. cTipOco == StrZero( 6, Len( DT2->DT2_TIPOCO ) )
					lRet:= .T.
				EndIf
				If !lRet
					Help(' ', 1, 'TMSA36001',,STR0008 + cDoc + "/" + cSerie,5,11) //"Documento esta bloqueado !"###"Documento No : "
					Exit
				EndIf
		ElseIf DT6->DT6_BLQDOC != StrZero( 1, Len( DT6->DT6_BLQDOC ) ) .And. cTipOco == StrZero( 3, Len( DT2->DT2_TIPOCO ) )
			Help(' ', 1, 'TMSA36006',,STR0008 + cDoc + "/" + cSerie,5,11) //"Documento nao esta bloqueado !"###"Documento No : "
			lRet := .F.
			Exit
		EndIf

		//-- Ocorrencias que geram indenizacoes( DUB ).
		If	! Inclui .And. Ascan( aIndeniz, cTipOco ) > 0

			DUB->( DbSetOrder( 3 ) )
			If	DUB->( DbSeek( xFilial( 'DUB' ) + cFilDoc + cDoc + cSerie ) ) .And. DUB->DUB_STATUS != StrZero( 1, Len( DUB->DUB_STATUS ) )
				Help('',1,'TMSA36021',, STR0029 + cFilDoc +'/'+ cDoc +'/'+ cSerie,4,1)	//"Registro de indenizacoes nao encontrado ou ja concluido.(DUB)"###"Fil.Doc./Doc./Serie: "
				lRet := .F.
				Exit
			EndIf

			//-- Ocorrencias que geram pendencias( DUU ).
		ElseIf ! Inclui .And. Ascan( aPendenc, cTipOco ) > 0

			DUU->( DbSetOrder( 3 ) )
			If	DUU->( DbSeek( xFilial('DUU') + cFilDoc + cDoc + cSerie ) ) .And. DUU->DUU_STATUS != StrZero( 1, Len( DUU->DUU_STATUS ) )
				Help('',1,'TMSA36022',, STR0029 + cFilDoc +'/'+ cDoc +'/'+ cSerie,4,1)	//Registro de pendencias nao encontrado ou ja concluido.(DUU)"###"Fil.Doc./Doc./Serie: "
				lRet := .F.
				Exit
			EndIf
		EndIf
		If lTMSGFE
			If nModulo == 43 //-- Se o documento está integrado ao GFE, nao permite apontar ocorrencias diferente de Informativa
				If !lTMSRDPU
					lRet:= !TMA360IDFV( GdFieldGet("DUA_FILDOC",n), GdFieldGet("DUA_DOC",n), GdFieldGet("DUA_SERIE",n),.T.)
					If !lRet
						Help(' ', 1, 'TMSA36031') // Utilize uma ocorrencia informativa.
						Exit
					EndIf
				EndIf
	   		EndIf
		EndIf
	Else
		If lTMSGFE //.And. nModulo == 43 //-- Se o documento está integrado ao GFE, nao permite apontar ocorrencia do parametro MV_OCORRDP
			DFV->( DbSetOrder ( 2 ) )
			If DFV->( DbSeek (xFilial("DFV") + GdFieldGet("DUA_FILDOC",n) + GdFieldGet("DUA_DOC",n) + GdFieldGet("DUA_SERIE",n) ) )
				If !Empty(DFV->DFV_CHVEXT) .And. DFV->DFV_STATUS <> StrZero( 1, Len( DFV->DFV_STATUS ) )   //Chamada está sendo executada pelo TMSAR05,incluindo novo trecho
					If !lTMSRDPU .And. DT2->DT2_CODOCO == cOcorBx
						Help(' ', 1, 'TMSA36031') // Utilize uma ocorrencia informativa.
				  		lRet := .F.
				  		Exit
					EndIf
				EndIf
   			EndIf
		EndIf

		If lDUAPrzEnt .And. cTipOco == StrZero( 5, Len( DT2->DT2_TIPOCO ) ) 
			If A360OcoPrz(cCodOco) .And. nRecursivo == 0 
				If DT6->DT6_BLQDOC == StrZero( 1, Len( DT6->DT6_BLQDOC ) ) .And. DT6->DT6_SERTMS <> StrZero( 1, Len( DT6->DT6_SERTMS ) )
					Help(' ', 1, 'TMSA36001',,STR0008 + cDoc + "/" + cSerie,5,11) //"Documento esta bloqueado !"###"Documento No : "
					lRet := .F.
					Exit
				EndIf
			EndIf	
		EndIf
	EndIf
Next

// Verifica se a viagem eh Coleta ou Entrega.
DTQ->(DbSetOrder(2))
DTQ->(DbSeek(xFilial('DTQ') + M->DUA_FILORI + M->DUA_VIAGEM))
lValRet := (DTQ->DTQ_SERTMS == StrZero(1, Len(DTQ->DTQ_SERTMS)) .Or. DTQ->DTQ_SERTMS == StrZero(3, Len(DTQ->DTQ_SERTMS)))

If lRet .And. Posicione('DT2',1,xFilial('DT2') + cCodOco,'DT2_TIPOCO')	!= StrZero( 5, Len( DT2->DT2_TIPOCO ) )
	For nCntFor := nX To 1 Step -1
		If nCntFor == nx .Or. GdDeleted(nCntFor)
			Loop
		EndIf
		//-- Desconsidera tipo de ocorrencia tipo 05 - Informativa e 17 - Despesas
		If	GDFieldGet('DUA_FILDOC', nCntFor) + GDFieldGet('DUA_DOC', nCntFor) + GDFieldGet('DUA_SERIE', nCntFor) == cFilDoc + cDoc + cSerie .And.;
			Posicione('DT2',1,xFilial('DT2') + GDFieldGet('DUA_CODOCO', nCntFor),'DT2_TIPOCO') != StrZero( 5, Len( DT2->DT2_TIPOCO ) ) .And. ;
			Posicione('DT2',1,xFilial('DT2') + GDFieldGet('DUA_CODOCO', nCntFor),'DT2_TIPOCO') != StrZero( 17, Len( DT2->DT2_TIPOCO ) )

			cUltOco := Posicione('DT2',1,xFilial('DT2') + GDFieldGet('DUA_CODOCO', nCntFor),'DT2_TIPOCO')
			cUltTip := DT2->DT2_TIPPND
			//-- Verifica se o processo ja foi encerrado para viagens de coleta
			If	DTQ->DTQ_SERTMS == StrZero(1, Len(DTQ->DTQ_SERTMS)) .And. cUltOco == StrZero( 1, Len( DT2->DT2_TIPOCO ) )
				Help('',1,'TMSA36025')	//-- Encerramento do processo ja efetuado.
				lRet := .F.
				Exit
			//--verifica se o processo ja foi encerrado para viagens de entrega.
			ElseIf DTQ->DTQ_SERTMS == StrZero(3, Len(DTQ->DTQ_SERTMS)) .And. ;
					cUltOco $ StrZero( 1, Len( DT2->DT2_TIPOCO ) ) + "/" + StrZero(6,Len(DT2->DT2_TIPOCO)) .And. ;
					!( cTipOco $ StrZero( 1, Len( DT2->DT2_TIPOCO ) ) + "/" + StrZero(6,Len(DT2->DT2_TIPOCO)) )

				Help('',1,'TMSA36025')	//-- Encerramento do processo ja efetuado.
				lRet := .F.
				Exit
				//-- Apos bloqueio, nao permitir um outro tipo de ocorrencia que nao seja do tipo 03 - Libera Docto.
			ElseIf cUltOco == StrZero( 2, Len( DT2->DT2_TIPOCO ) )
				If	cTipOco != StrZero( 3, Len( DT2->DT2_TIPOCO ) )
					Help(' ', 1, 'TMSA36024')		//-- Informe uma ocorrencia de liberacao.
					lRet := .F.
					Exit
				EndIf
				//-- Apos Retorna Docto, nao permitir um outro tipo de ocorrencia que nao seja do tipo 05 - Informativa.
			ElseIf ( cUltOco == StrZero( 4, Len( DT2->DT2_TIPOCO ) ) .Or. ;
				   (cUltOco == StrZero( 6, Len( DT2->DT2_TIPOCO ) ) .And. cUltTip == StrZero( 4, Len( DT2->DT2_TIPPND ) ) ) ).And. lValRet

				If	cTipOco != StrZero( 5, Len( DT2->DT2_TIPOCO ) ) .And. cTipOco != StrZero( 17, Len( DT2->DT2_TIPOCO ) )  .And. !lSobra
					Help(' ', 1, 'TMSA36031') // Utilize uma ocorrencia informativa.
					lRet := .F.
					Exit
				EndIf

				//-- Somente aceitar digitacao de ocorrencia tipo 03 - Libera Docto, se a ultima ocorrencia for de tipo 02 - Bloqueia Docto.
			ElseIf cTipOco == StrZero( 3, Len( DT2->DT2_TIPOCO ) )
				If	cUltOco != StrZero( 2, Len( DT2->DT2_TIPOCO ) )
					Help(' ', 1, 'TMSA36027')		//-- Ocorrencia do tipo 03 - Libera Docto, somente sera aceita se a ocorrencia anterior for do tipo 02 - Bloqueia Docto.
					lRet := .F.
					Exit
				EndIf
			EndIf
			Exit
		EndIf
	Next
EndIf

If !lRet
	GDFieldPut( 'DUA_FILDOC', Space(FWGETTAMFILIAL), nx )
	GDFieldPut( 'DUA_DOC'   , Space(Len(DUA->DUA_DOC))	  , nx )
	GDFieldPut( 'DUA_SERIE' , Space(Len(DUA->DUA_SERIE)) , nx )
	GDFieldPut( 'DUA_QTDVOL', 0								  , nx )
	GDFieldPut( 'DUA_QTDOCO', 0								  , nx )
	GDFieldPut( 'DUA_PESO  ', 0								  , nx )
	GDFieldPut( 'DUA_PESOCO', 0								  , nx )
	If lDUAPrzEnt
		GDFieldPut( 'DUA_PRZENT', cTod('') 					  , nx )
	EndIf
	If !l360Auto
		oTmsGetD:oBrowse:Refresh( .T. )
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360Whe³ Autor ³ Antonio C Ferreira    ³ Data ³09.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ PreValidacao do sistema                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA360Whe()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360Whe()

Local aArea   := {DFV->(GetArea()),DT2->(GetArea()),DUD->(GetArea()),GetArea()}
Local nX      := 0
Local cCampo  := ReadVar()
Local lRet	  := n >= nBaseACols
Local cCodOco := GDFieldGet( 'DUA_CODOCO', n )
Local cTipOco := " "
Local cSerTMS := " "
Local cCatOco := StrZero( 2, Len( DT2->DT2_CATOCO ) )

If !lRet .And. lAjusta .And. AllTrim(cCampo) $ "M->DUA_CODOCO|M->DUA_PRZENT"
	lRet := .T.
EndIf

If lRet
	If !Empty(cCodOco)
		DT2->(DbSetOrder(1))  // DT2_FILIAL+DT2_CODOCO
		If DT2->(DbSeek(xFilial("DT2")+cCodOco))
			cTipOco := DT2->DT2_TIPOCO
			cCatOco := DT2->DT2_CATOCO
			cSerTMS := DT2->DT2_SERTMS
		EndIf
	EndIf

	If	AllTrim(cCampo) $ "M->DUA_FILDOC|M->DUA_DOC|M->DUA_SERIE"
		lRet := ( cCatOco != StrZero( 2, Len( DT2->DT2_CATOCO ) ) )  // Categoria = 2-Por Viagem / 1-Por Documento
	ElseIf cCampo $ "M->DUA_FILVTR.M->DUA_NUMVTR"
		lRet := ( cTipOco == StrZero(8, Len(DT2->DT2_TIPOCO)) ) // Transferencia
	EndIf
EndIf

If lRet .And. cCampo == "M->DUA_RECEBE"
	If !( cSerTMS == StrZero(3, Len(DT2->DT2_SERTMS)) .And. cTipOco == StrZero(1, Len(DT2->DT2_TIPOCO)) )
		lRet := .F.
	EndIf
EndIf

//-- Estes Campos so' estarao ativos se for Viagem de Coleta ou Entrega
If lRet .And. AllTrim(cCampo) $ "M->DUA_DATCHG|M->DUA_HORCHG|M->DUA_DATSAI|M->DUA_HORSAI"
	If cTipOco <> StrZero(14, Len(DT2->DT2_TIPOCO))
		If DTQ->( Eof() )
			DUD->( DbSetOrder(1) )
			DUD->(DbSeek(xFilial("DUD") + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE + cFilAnt, .F.) )
			If !(DUD->DUD_SERTMS == StrZero(1, Len(DUD->DUD_SERTMS)) .Or. DUD->DUD_SERTMS == StrZero(3, Len(DUD->DUD_SERTMS)))
				lRet := .F.
			EndIf
		Else
			If !(DTQ->DTQ_SERTMS == StrZero(1, Len(DTQ->DTQ_SERTMS)) .Or. DTQ->DTQ_SERTMS == StrZero(3, Len(DTQ->DTQ_SERTMS)))
				lRet := .F.
			EndIf
		EndIf
	EndIf
	// Habilita os campos de acordo com a ordem de digitacao.
	If lRet
		If AllTrim(cCampo) == "M->DUA_HORCHG"
			lRet := !Empty(GDFieldGet('DUA_DATCHG', n ))
		ElseIf AllTrim(cCampo) == "M->DUA_DATSAI"
			lRet := !Empty(GDFieldGet('DUA_HORCHG', n ))
		ElseIf AllTrim(cCampo) == "M->DUA_HORSAI"
			lRet := !Empty(GDFieldGet('DUA_DATSAI', n ))
		EndIf
	EndIf
EndIf

If lRet .And. cCampo == "M->DUA_FILPND"
	DT2->(DbSetOrder(1))
	lRet := .F.
	If DT2->(DbSeek(xFilial('DT2')+GdFieldGet('DUA_CODOCO',n))) .And. ;
		DT2->DT2_TIPOCO == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. ;
		DT2->DT2_TIPPND == StrZero(2,Len(DT2->DT2_TIPPND)) //-- Pendencia de Avaria
		lRet := .T.
	EndIf
EndIf

//-- Rentabilidade/Ocorrencia -> Tratamento Campo ( Vlr. Receita )
If lRet .And. cCampo == "M->DUA_VLRRCT"

	DT2->(DbSetOrder(1))
	If	DT2->(MsSeek(xFilial('DT2') + GdFieldGet('DUA_CODOCO',n),.f.))

		If DT2->DT2_TIPOCO <> StrZero(16,Len(DT2->DT2_TIPOCO)) .And. ;
				DT2->DT2_TIPOCO <> StrZero(18,Len(DT2->DT2_TIPOCO)) .And. ;
				DT2->DT2_TIPOCO <> StrZero(19,Len(DT2->DT2_TIPOCO)) .And. ;
				DT2->DT2_TIPOCO <> StrZero(20,Len(DT2->DT2_TIPOCO))
			lRet := .f.
		EndIf
	Else
		lRet := .f.
	EndIf
EndIf

//-- Rentabilidade/Ocorrencia -> Tratamento Campo ( Tipo Veículo )
If lRet .And. cCampo == "M->DUA_TIPVEI"

	DT2->(DbSetOrder(1))
	If	DT2->(MsSeek(xFilial('DT2') + GdFieldGet('DUA_CODOCO',n),.f.))
		If DT2->DT2_TIPOCO <> StrZero(16,Len(DT2->DT2_TIPOCO)) .And. ;
				DT2->DT2_TIPOCO <> StrZero(18,Len(DT2->DT2_TIPOCO))
			lRet := .f.
		EndIf
	Else
		lRet := .f.
	EndIf
EndIf

//-- Rentabilidade/Ocorrencia -> Tratamento Campo ( Valor Despesa )
If lRet .And. cCampo == "M->DUA_VLRDSP"

	DT2->(DbSetOrder(1))
	If	DT2->(MsSeek(xFilial('DT2') + GdFieldGet('DUA_CODOCO',n),.F.))
		If ( DT2->DT2_TIPOCO <> StrZero(17,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPOCO <> StrZero(18,Len(DT2->DT2_TIPOCO)) )
			lRet := .f.
		EndIf
	Else
		lRet := .f.
	EndIf
EndIf

//-- Rentabilidade/Ocorrencia -> Tratamento Campo ( Código Fornecedor )
If lRet .And. ( cCampo == "M->DUA_CODFOR" .Or. cCampo == "M->DUA_LOJFOR" )

	DT2->(DbSetOrder(1))
	If	DT2->(MsSeek(xFilial('DT2') + GdFieldGet('DUA_CODOCO')))

		If 	DT2->DT2_TIPOCO <> StrZero(17,Len(DT2->DT2_TIPOCO)) .And. ;
			DT2->DT2_TIPOCO <> StrZero(18,Len(DT2->DT2_TIPOCO)) .And. ;
		  	DT2->DT2_TIPOCO <> StrZero(21,Len(DT2->DT2_TIPOCO))

			lRet := .f.
		EndIf

		//-- Tratamento Para Chave Externa
		If !lRet

			If !Empty( GdFieldGet("DUA_DOC"))

				//-- ITENS REDESPACHANTE X DOCTOS.
				DbSelectArea("DFV")
				DbSetOrder(2) //-- DFV_FILIAL+DFV_FILDOC+DFV_DOC+DFV_SERIE+DFV_STATUS
				If MsSeek( FWxFilial("DFV") + GdFieldGet("DUA_FILDOC") + GdFieldGet("DUA_DOC") + GdFieldGet("DUA_SERIE") , .f. )

					If !Empty(DFV->DFV_CHVEXT)

						lRet := .t.

					EndIf
				EndIf
			EndIf
		EndIf

		If !lRet
			If DT2->(ColumnPos("DT2_CDTIPO")) > 0 .And. !Empty( DT2->DT2_CDTIPO )
				lRet	:= .T.
			EndIf
		EndIf

	Else
		lRet := .f.
	EndIf
EndIf

//-- Rentabilidade/Ocorrencia -> Tratamento Campo ( Valor Despesa )
If lRet .And. cCampo == "M->DUA_VALINF"

	DT2->(DbSetOrder(1))
	If	DT2->(MsSeek(xFilial('DT2') + GdFieldGet('DUA_CODOCO',n),.F.))

		If 	(DT2->DT2_TIPOCO <> StrZero(16,Len(DT2->DT2_TIPOCO)) .And. ;
			 DT2->DT2_TIPOCO <> StrZero(17,Len(DT2->DT2_TIPOCO)) .And. ;
			 DT2->DT2_TIPOCO <> StrZero(18,Len(DT2->DT2_TIPOCO)) .And. ;
			 Empty(DT2->DT2_CDTIPO) )
			lRet := .f.
		EndIf
	Else
		lRet := .f.
	EndIf
EndIf

//-- Rentabilidade/Ocorrencia -> Tratamento Campo DUA_SERVIC
If lRet .And. cCampo == "M->DUA_SERVIC"

	DT2->(DbSetOrder(1))
	If	DT2->(MsSeek(xFilial('DT2') + GdFieldGet('DUA_CODOCO',n),.F.))

		If 	( !Empty(DT2->DT2_CDTIPO ) .Or.;
			(DT2->DT2_TIPOCO <> StrZero(16,Len(DT2->DT2_TIPOCO)) .And. ;
			 DT2->DT2_TIPOCO <> StrZero(18,Len(DT2->DT2_TIPOCO)) .And. ;
 			 DT2->DT2_TIPOCO <> StrZero(19,Len(DT2->DT2_TIPOCO)) .And. ;
			 DT2->DT2_TIPOCO <> StrZero(20,Len(DT2->DT2_TIPOCO))))
			lRet := .f.
		EndIf
	Else
		lRet := .f.
	EndIf
EndIf

//-- Rentabilidade/Ocorrencia -> Tratamento Campos DUA_KMDOC, DUA_VLROCO, DUA_PM3OCO, DUA_MT3OCO, DUA_QTUOCO e DUA_BASOCO
If lRet .And. ( cCampo == "M->DUA_KMDOC"  .Or.;
				cCampo == "M->DUA_VLROCO" .Or.;
				cCampo == "M->DUA_PM3OCO" .Or.;
				cCampo == "M->DUA_MT3OCO" .Or.;
				cCampo == "M->DUA_QTUOCO" .Or.;
				cCampo == "M->DUA_BASOCO" )

	DT2->(DbSetOrder(1))
	If	DT2->(MsSeek(xFilial('DT2') + GdFieldGet('DUA_CODOCO',n),.F.))

		//-- 19 (reentrega), 20 (devolução) e 21 (entrega trecho GFE) Desabilita Campos
		If 	(DT2->DT2_TIPOCO == StrZero(19,Len(DT2->DT2_TIPOCO)) .Or. ;
			 DT2->DT2_TIPOCO == StrZero(20,Len(DT2->DT2_TIPOCO)) .Or. ;
			 DT2->DT2_TIPOCO == StrZero(21,Len(DT2->DT2_TIPOCO)))
			lRet := .f.
		EndIf

		//-- 17 (Despesa ) Com Integração GFE (!Empty(DT2->DT2_CDTIPO )) Desabilita Campos
		If 	DT2->DT2_TIPOCO == StrZero(17,Len(DT2->DT2_TIPOCO)) .And. !Empty(DT2->DT2_CDTIPO )
			lRet := .f.
		EndIf

	Else
		lRet := .f.
	EndIf
EndIf

If lRet .And. cCampo == "M->DUA_PRZENT"
	lRet:= .F.
	If GdFieldGet('DUA_SERIE',n) <> 'COL'   //Somente para doctos diferente de Coleta e Doctos não entregue (Data de Entrega)
		If !Empty(GDFieldGet('DUA_FILDOC' ,n)) .And. !Empty(GDFieldGet('DUA_DOC'    ,n)) .And. !Empty(GDFieldGet('DUA_SERIE'  ,n))
			DT6->(DbSetOrder(1))
			If DT6->(DbSeek(xFilial('DT6')+GDFieldGet('DUA_FILDOC' ,n)+GDFieldGet('DUA_DOC'    ,n)+GDFieldGet('DUA_SERIE'  ,n)))  
				If Empty(DT6->DT6_DATENT)
					lRet:= .T.
				EndIf
			EndIf
		EndIf	
		If lRet
			lRet:= A360OcoPrz(GdFieldGet('DUA_CODOCO',n))
		EndIf	
	EndIf	
EndIf

//-- Reposiciona Arquivos
For nX := 1 To Len(aArea)
	RestArea(aArea[nX])
Next nX

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360LinOk³ Autor ³ Antonio C Ferreira  ³ Data ³09.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes da linha da GetDados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA360LinOk()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Linha.                                             ³±±
±±³          ³ ExpN2 - Opcao Selecionada.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360LinOk(nx,nTmsOpcx)

Local lRet	       := .T.
Local lDocEmBranco := .F.
Local lNaoIncluir  := .F.
Local cCodOco      := ""
Local cFilDoc      := ""
Local cDoc         := ""
Local cSerie       := ""
Local cMotivo      := ""
Local aAreaDT6     := {}
Local aAreaDTQ     := {}
Local cVarOld      := ""
Local nCnt         := 0
Local cCposVld     := ""
Local lSobra       := .F.
Local IncluiOld    := Inclui
Local nPosDV4      := 0
Local cTipPnd      := ""
Local nW           := 0
Local cTMSCOSB     := SuperGetMV('MV_TMSCOSB',,'0') //-- 0=Nao Utiliza,1=Obrigatorio,2=Nao Obrigatorio
Local nSeek        := 0
Local cAliasQry    := ""
Local aAreaDUD     := {}
Local lLibVgBlq	 := SuperGetMV('MV_LIBVGBL',,.F.)  //-- Libera Encerramento de viagens com ocorrencia do tipo
Local cSerTMS		:= ""
Local lGFE         := nModulo == 78 .And. DT2->DT2_TIPRDP <> StrZero(2,Len(DT2->DT2_TIPOCO))
Local lDocRed      := .F.
Local lRotDUD      := Iif(FindFunction('TMSChvDUD'),.T.,.F.)
Local lDocApoio    := .F.
Local cStReg       := ""
Local lVaziaInf		:= .F.

Default nX			:= 0
Default nTmsOpcx	:= 0

If Valtype(nx) <> "N" .Or. Empty(nx)
	nx := n
EndIf

cCodOco  := GDFieldGet('DUA_CODOCO',nx)
cFilDoc  := GDFieldGet('DUA_FILDOC',nx)
cDoc     := GDFieldGet('DUA_DOC'   ,nx)
cSerie   := GDFieldGet('DUA_SERIE' ,nx)

l360Auto := If (Type("l360Auto") == "U",.F.,l360Auto)

//-- Nao avalia linhas deletadas.
If !GDdeleted(nx)

	If nModulo == 43 .Or. lGFE //--TMS
		If !Empty(cFilDoc) .Or. !Empty(cDoc) .Or. !Empty(cSerie)
			DT6->(DbSetOrder(1))
			If !DT6->(DbSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie,.F.))
				Help( '', 1, 'REGNOIS' ) //"Nao existe registro relacionado a este codigo"
				Inclui := IncluiOld
				Return( .F. )
			EndIf
		Else
		    //| Se não foi informado Documento, avalia se a ocorrência está configurada com o código de acrescimo ou decrescimo(Cód Acr/Decr)
		    //| se existir a configuração, matem a variável lDocEmBranco com o valor .F. para que seja possível acrescentar mais de um tipo de
		    //| acrescimo ou decrescimo.
		    DT2->(DbSetOrder(1))
		    If DT2->(MsSeek(xFilial("DT2")+GDFieldGet("DUA_CODOCO",n))) .And. Empty(DT2->DT2_CODAED)
			     lDocEmBranco := .T.
			EndIf
		EndIf

		If 	!Empty(M->DUA_FILORI) .or. !Empty(M->DUA_VIAGEM)
			aAreaDTQ := DTQ->( GetArea() )
			DTQ->( DbSetOrder( 2 ) )
			If DTQ->(!DbSeek( xFilial('DTQ') + M->DUA_FILORI + M->DUA_VIAGEM ) )
				Help( '', 1, 'TMSA360B1' ) //"Viagem não encontrada."
				lRet := .F.
			EndIf
			RestArea( aAreaDTQ )
		EndIf
		
		// Verifica se é documento de apoio
		If ExistFunc("FDOCAPOIO")
			lDocApoio := FDocApoio(DT6->DT6_DOCTMS)
		EndIf

		// Nao permite apontar encessa processo para CT-e nao autorizado
		DTP->(DbSetOrder(2))
		DTP->(MsSeek(xFilial("DTP")+DT6->DT6_FILORI+DT6->DT6_LOTNFC))
		If lRet .And. DT2->DT2_TIPOCO == StrZero( 1, Len(DT2->DT2_TIPOCO )) .And. DT2->DT2_CATOCO == StrZero(1,Len(DT2->DT2_CATOCO)) .And.;
			(DTP->DTP_TIPLOT == StrZero(3,Len(DTP->DTP_TIPLOT)) .Or. DTP->DTP_TIPLOT == StrZero(4,Len(DTP->DTP_TIPLOT))) .And.;
			(Alltrim(DT6->DT6_IDRCTE) <> "100" .And. Empty(DT6->DT6_CHVCTG) .And. Alltrim(DT6->DT6_IDRCTE) <> "136") .And. ;
			(DT6->DT6_SERTMS == StrZero(2,Len(DT6->DT6_SERTMS)) .Or. DT6->DT6_SERTMS == StrZero(3,Len(DT6->DT6_SERTMS))) .AND. ;
			DT6->DT6_DOCTMS  <> '5' .And. !lDocApoio
			Help(' ', 1, 'TMSA360F5')  //-- Não poderá ser apontada ocorrência de "Encerra Processo" para Doc. não autorizado na SEFAZ.
			lRet := .F.
		EndIf

		If nTmsOpcx != 4 .And. nTmsOpcx != 2 .And. !lAjusta
			DUD->( DbSetOrder( 1 ) )
			If lRet .And. DUD->( DbSeek( xFilial( 'DUD') + cFilDoc + cDoc + cSerie + M->DUA_FILORI + M->DUA_VIAGEM ) ) .And. !__lPyme
				If	DT2->DT2_TIPOCO <> StrZero(5,Len(DT2->DT2_TIPOCO)) .And. ( DUD->DUD_STATUS == StrZero(9,Len(DUD->DUD_STATUS)) .Or. DUD->DUD_STATUS == StrZero(4,Len(DUD->DUD_STATUS)) ) .And. ;
					!lLibVgBlq .And. aScan( aRecDep, DT2->DT2_TIPOCO) == 0 //-- Tratamento Rentabilidade/Ocorrencia
					//-- Documentos cancelados ou encerrados somente poderao receber ocorrencias do tipo "informativa"
					If	DT2->DT2_TIPOCO != StrZero(5,Len(DT2->DT2_TIPOCO)) .And. Posicione("DT2",1,xFilial("DT2") +  cCodOco , "DT2_TIPOCO") != StrZero(17,Len(DT2->DT2_TIPOCO))
						If DUD->DUD_SERTMS <> StrZero(2,Len(DUD->DUD_SERTMS))
							//-- Docto de Redespacho podera apontar ocorrencia  quando o status do documento estiver encerrado.
							lDocRed:= TMA360IDFV(cFilDoc,cDoc,cSerie, .F. )

							If lDocRed .Or. Iif(lRotDud,TMSChvDUD(cFilDoc,cDoc,cSerie),.T.)
								lRet:= .T.
							Else
								Help('',1,'TMSA36063') //"Documentos cancelados ou encerrados somente poderão receber ocorrências do tipo 'Informativa'"
								lRet := .F.
							EndIf
						EndIf
					EndIf
				EndIf
			ElseIf Empty(M->DUA_FILORI) .And. Empty(M->DUA_VIAGEM) .And.(DT6->DT6_STATUS == StrZero(9,Len(DT6->DT6_STATUS)) .Or. DT6->DT6_STATUS == StrZero(7,Len(DT6->DT6_STATUS))) .And. DT2->DT2_TIPOCO != StrZero(5,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPOCO != StrZero(17,Len(DT2->DT2_TIPOCO))
					Help('',1,'TMSA36063') //"Documentos cancelados ou encerrados somente poderão receber ocorrências do tipo 'Informativa'"
					lRet := .F.
			EndIf
		EndIf

		If lRet .And. !Empty(cFilDoc) .Or. !Empty(cDoc) .Or. !Empty(cSerie)
			aAreaDUD := DUD->( GetArea() )
			cAliasQry := GetNextAlias()
			cQuery := " SELECT (MAX(R_E_C_N_O_)) R_E_C_N_O_"
			cQuery += "   FROM " + RetSqlName("DUD")
			cQuery += "  WHERE DUD_FILIAL = '" + xFilial('DUD') + "' "
			cQuery += "    AND DUD_FILDOC = '" + cFilDoc + "' "
			cQuery += "    AND DUD_DOC = '" + cDoc+ "' "
			cQuery += "    AND DUD_SERIE = '" + cSerie+ "' "
			cQuery += "    AND D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

		   If (cAliasQry)->R_E_C_N_O_ > 0
			  aAreaDUD := DUD->( GetArea() )
	   	      DUD->(dbGoto((cAliasQry)->R_E_C_N_O_))

	    		If lRet .And. !Empty(DUD->DUD_VIAGEM) .And. Empty(M->DUA_VIAGEM) .And. ;
	    			(DT2->DT2_TIPOCO == StrZero(1, Len(DT2->DT2_TIPOCO)) .Or. DT2->DT2_TIPOCO == StrZero(4, Len(DT2->DT2_TIPOCO))) .And. ;
	    			DT2->DT2_CATOCO == StrZero(2, Len(DT2->DT2_CATOCO)) //Somente ocorrencias por Viagem devem ter esta consistencia efetuada.
					HELP('',1,'TMSA360C8',, STR0100 + ' ' + AllTrim(DUD->DUD_VIAGEM) + '/' + AllTrim(DUD->DUD_SERIE) ,4,1) //Documento está em Viagem. Não é permitido apontar ocorrência de encerra processo ou retorna documento sem informar a viagem.
					M->DUA_FILORI := DUD->DUD_FILORI
					M->DUA_VIAGEM := DUD->DUD_VIAGEM
					lRet := .F.
				EndIf
			EndIf
			RestArea( aAreaDUD )
			(cAliasQry)->(dbCloseArea())
		EndIf

		DT2->(DbSetOrder(1))  // DT2_FILIAL+DT2_CODOCO
		DT2->(DbSeek(xFilial("DT2")+cCodOco))

		cTipOco := DT2->DT2_TIPOCO
		cCatOco := DT2->DT2_CATOCO
		cTipPnd := DT2->DT2_TIPPND
		lSobra  := ( cTipOco == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND	== StrZero(3,Len(DT2->DT2_TIPPND)) ) //-- Sobra

		If cTipOco == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. !lSobra .And. ;
		 (Empty(cFilDoc) .Or. Empty(cDoc) .Or. Empty(cSerie))	//--Gera Pendencia, qdo for sobra pode apontar sem Documento.
			Help('',1,'TMSA36074') //"Documento Nao Encontrado !!!"
			lRet := .F.
		EndIf
		//-- Verifica se o volume foi preenchido para ocorrencia de sobra
		If lRet .And. lSobra

			//-- Verifica No Vetor aIdProduto se já existe referencia para doc e serie
			If Empty(cFilDoc+cDoc+cSerie)
				nSeek := Ascan(aIdProduto,{ |x| x[1] == M->DUA_FILOCO + M->DUA_NUMOCO + Space(Len(DUA->DUA_FILDOC))+Space(Len(DUA->DUA_DOC))+Space(Len(DUA->DUA_SERIE)) })
			Else
				nSeek := Ascan(aIdProduto,{ |x| x[1] == M->DUA_FILOCO + M->DUA_NUMOCO + GdFieldGet("DUA_FILDOC",nX) + GdFieldGet("DUA_DOC",nX) + GdFieldGet("DUA_serie",nX) })
			EndIf

			lRet := TMSA360Vld('M->DUA_QTDOCO',,Iif( nSeek == 0 .And. cTMSCOSB <> '0',.T.,.F.)) //-- 0=Nao Utiliza,1=Obrigatorio,2=Nao Obrigatorio

		EndIf

		aAreaDTQ := DTQ->( GetArea() )
		DTQ->( DbSetOrder( 2 ) )
		If DTQ->( DbSeek( xFilial('DTQ') + M->DUA_FILORI + M->DUA_VIAGEM ) )
			// Se doc em branco, Viagem vazia e ocorrencia Informativa permito realizar apontamento de ocorrencia
			If lDocEmBranco .AND. DTQ->DTQ_TIPVIA == '2' .AND. cTipOco == StrZero( 5, Len( DT2->DT2_TIPOCO ) )
				lVaziaInf := .T.
			EndIf
		EndIf
		RestArea( aAreaDTQ )
		//-- Categoria = 1-Por Documento / 2-Por Viagem
		If lRet .And. !lSobra .And. lDocEmBranco .And. cTipOco != StrZero( 14, Len( DT2->DT2_TIPOCO ) ) .And. ( DT2->(ColumnPos('DT2_CODAED')) > 0  .And. Empty(DT2->DT2_CODAED) ) .AND. !lVaziaInf
			Help(' ', 1, 'TMSA36015')  //-- 'Obrigatorio especificar o Documento com esse Tipo de Ocorrencia!'
			lRet := .F.
		EndIf

		If lRet .And.  DT2->DT2_TIPOCO == StrZero( 8, Len(DT2->DT2_TIPOCO ) ) .And.;
			(Empty(GdFieldGet('DUA_FILVTR',nx)) .Or. Empty(GdFieldGet('DUA_NUMVTR',nx)) )
			Help(' ', 1, 'TMSA36036')  //-- Informe a Filial/Viagem de Transferencia
			lRet := .F.
		EndIf

		If !l360Auto
			nMaxL := If(nMaxL==0, oTmsGetD:nMax, nMaxL)
			oTmsGetD:nMax := If( (lDocEmBranco .And. (nx >= nBaseACols)) .Or. lNaoIncluir, Len(aCols), nMaxL)  // Permite ou nao adicionar linhas

			//-- Impede a Utilização Do Botão De Inclusão Por Cód. Barras Qdo Só Puder Incluir Uma Linha (Ex: Sobras Sem Doc. Informado).
			If IsInCallStack("TM360CODBR") .And. ( Len(aCols) >= oTmsGetD:nMax )
				Help('', 1, 'TMSA360AA',, STR0099 ,3,01 )  // Não é Permitido a Inclusão De Novos Itens.
				lRet := .f.
			EndIf
		EndIf

		If lRet .And. !lDocEmBranco

			DTQ->( DbSetOrder( 2 ) )
			DTQ->( DbSeek( xFilial('DTQ') + M->DUA_FILORI + M->DUA_VIAGEM ) )

			//-- Se a viagem for de coleta e nao for retorno, transferencia ou cancelamento.
			If DTQ->DTQ_SERTMS == StrZero( 1, Len( DTQ->DTQ_SERTMS ) ) .And. cTipOco != StrZero( 4, Len( DT2->DT2_TIPOCO ) ) .And.;
				cTipOco != StrZero( 8, Len( DT2->DT2_TIPOCO ) ) .And. cTipOco != StrZero( 12, Len( DT2->DT2_TIPOCO ) ) // Retorno / Transferencia / Cancelamento.
				If Empty(GDFieldGet( 'DUA_QTDOCO', nx )) .Or. Empty(GDFieldGet( 'DUA_PESOCO', nx ))
					Help(' ', 1, 'TMSA36040')   //-- A Quantidade / Peso da Ocorrencia deverao ser Informadas ...
					lRet := .F.
				EndIf
			EndIf

			If lRet .And. Inclui

				If Empty(GDFieldGet('DUA_QTDOCO',nx))
					If GDFieldGet( 'DUA_QTDVOL', nx ) > 0 .And. cTipOco != StrZero(4,Len(DT2->DT2_TIPOCO)) .And. ;
																cTipOco != StrZero(8,Len(DT2->DT2_TIPOCO))
						If !IsInCallStack("TMSAE81A") .And. !IsInCallStack("TMSAE81B")
							Help(' ', 1, 'TMSA36004')   //-- Quantidade de Ocorrencia deve ser preenchida quando a Quantidade de Volume for maior que zero.
							lRet := .F.
						EndIf
					ElseIf cTipOco == StrZero(19,Len(DT2->DT2_TIPOCO)) .Or. cTipOco == StrZero(20,Len(DT2->DT2_TIPOCO))
						Help(' ', 1, 'TMSA360F1')   //-- Qtde da Ocorrencia obrigatório para os tipos de Ocorrência 19/20 (Cobrança Reentrega/Cobrança Retorno)
						lRet := .F.
					EndIF
				EndIf

				DUD->(DbSetOrder(1))
				DUD->(DbSeek(xFilial('DUD')+cFilDoc+cDoc+cSerie))
				While DUD->(!Eof()) .And. DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE) == xFilial('DUD')+cFilDoc+cDoc+cSerie
					If DUD->DUD_STATUS == StrZero(4,Len(DUD->DUD_STATUS)) .Or. ;
					   DUD->DUD_STATUS == StrZero(9,Len(DUD->DUD_STATUS))
					   DUD->(dbSkip())
					   Loop
					EndIf
					If !Empty(DUD->DUD_VIAGEM) .And. (Empty(M->DUA_FILORI) .Or. Empty(M->DUA_VIAGEM))
						//-- Valida os campos ja informados
						cVarOld := __Readvar
						For nCnt := 1 To FCount()
							cCposVld := FieldName(nCnt)
							If !( cCposVld $ "M->DUA_FILDOC.M->DUA_DOC.M->DUA_SERIE" ) .And. !Empty(GDFieldGet(cCposVld,nx))
								__Readvar  := "M->"+cCposVld
								&__ReadVar := GDFieldGet(cCposVld,nx)
								If !TMSA360Vld(,.F.)
									Inclui := IncluiOld
									Return( .F. )
								EndIf
							EndIf
						Next nCnt
						__Readvar     := "M->DUA_VIAGEM"
						If !TMSA360Vld(,.F.)
							M->DUA_FILORI := CriaVar("DUA_FILORI",.F.)
							M->DUA_VIAGEM := CriaVar("DUD_VIAGEM",.F.)
							Inclui := IncluiOld
							Return( .F. )
						EndIf
						If !l360Auto
							oTmsEnch:Refresh(.T.)
						EndIf
						__ReadVar :=  cVarOld
					EndIf
					If !(DT2->DT2_TIPOCO $  "05/19/20")
						If	!Empty(M->DUA_FILORI+M->DUA_VIAGEM) .And. ( ( DUD->(DUD_FILORI+DUD_VIAGEM) != M->DUA_FILORI+M->DUA_VIAGEM .And. !Empty(DUD->DUD_VIAGEM) ) .Or. ;
							(Empty(DUD->DUD_VIAGEM) .And. DUD->(DUD_FILVGE+DUD_NUMVGE) != M->DUA_FILORI+M->DUA_VIAGEM) )
							DFV->( DbSetOrder( 2 ) )
							If DFV->( MsSeek( xFilial('DFV') + DUD->( DUD_FILDOC + DUD_DOC + DUD_SERIE )  ) ) .And. !Empty(DFV->DFV_CHVEXT) //-- Verifica se existe vinculo com o GFE
								Help('',1,'TMSA360F1',,+ DFV->DFV_CHVEXT + ' - ' + CHR(13) + CHR(10) + Alltrim(DFV->DFV_FILDOC) + ' - ' + Alltrim(DFV->DFV_DOC) + ' - ' + Alltrim(DFV->DFV_SERIE),4,6)
								lRet := .F.
							Else
								Help('',1,'TMSA36071',, + CHR(13) + CHR(10) + Alltrim(cFilDoc) + ' - ' + Alltrim(cDoc) + ' - ' + Alltrim(cSerie) + CHR(13) + CHR(10) + STR0028 + CHR(13) + CHR(10) + DUD->(DUD_FILORI+' - '+DUD_VIAGEM),1,12) //"O Documento"###" pertence a viagem: "
							EndIf
							Inclui := IncluiOld
							Return( .F. )
						EndIf
					EndIf
					Exit
				EndDo

				//-- Verifica se a ocorrencia ja existem para o documento/viagem.
				DUA->(DbSetOrder(3))
				If lRet .And. (cTipOco == StrZero(1, Len(DT2->DT2_TIPOCO)) .Or. cTipOco == StrZero(4, Len(DT2->DT2_TIPOCO))) .And. ;
					DUA->(DbSeek(xFilial('DUA')+ cCodOco + cFilDoc + cDoc + cSerie))
					While DUA->(!Eof()) .And. DUA->DUA_FILIAL + DUA->DUA_CODOCO + DUA->DUA_FILDOC + DUA->DUA_DOC + DUA->DUA_SERIE == ;
							xFilial('DUA') + cCodOco + cFilDoc + cDoc + cSerie
						If Empty( DUA->DUA_VIAGEM ) .Or. ( DUA->DUA_FILORI + DUA->DUA_VIAGEM == M->DUA_FILORI + M->DUA_VIAGEM )
							If Posicione("DT6",1,xFilial("DT6")+cFilDoc+cDoc+cSerie,"DT6_QTDVOL") == 0 .Or. DT6->DT6_STATUS == StrZero(5, Len( DT6->DT6_STATUS ))
								lRet := .F.
								Exit
							EndIf
						EndIf
						DUA->(DbSkip())
					EndDo
					If !lRet
						Help("",1,"TMSA36038") //-- Ocorrencia ja informada para este Documento ...
					EndIf
				EndIf
			EndIf

		EndIf

		//-- Analisa se ha itens duplicados na GetDados.
		If	lRet
			lRet := TMSA360Dup( {'DUA_CODOCO', 'DUA_FILDOC', 'DUA_DOC', 'DUA_SERIE'}, cTipOco )
		EndIf

		If lRet .And. nx >= nBaseACols
			lRet  := TMSA360Vdc(cFilDoc, cDoc, cSerie, nx)
		EndIf

		/* Verifica se a mercadoria pode ser transferida. */
		If	lRet .And. cTipOco == StrZero( 11, Len( DT2->DT2_TIPOCO ) ) //  Transferencia de Mercadoria.
			aAreaDT6 := DT6->( GetArea() )
			DT6->( DbSetOrder( 1 ) )
			If DT6->( DbSeek( xFilial( "DT6" ) + cFilDoc + cDoc + cSerie ) ) .And.;
				DT6->DT6_STATUS != StrZero( 5, Len( DT6->DT6_STATUS ) )
				Help("",1,"TMSA36048") // Somente e permitida a Transferencia de Mercadoria para documentos com status de Chegada Final.
				lRet := .F.
			EndIf
			RestArea( aAreaDT6 )
		EndIf
		If cTipOco <> StrZero( 14, Len( DT2->DT2_TIPOCO ) ) //  Ajuste Previsao de Chegada
			aAreaDTQ := DTQ->( GetArea() )
			DTQ->( DbSetOrder( 2 ) )
			If DTQ->( DbSeek( xFilial('DTQ') + M->DUA_FILORI + M->DUA_VIAGEM ) ) .And.;
				(DTQ->DTQ_SERTMS == StrZero(1, Len(DTQ->DTQ_SERTMS))) .Or. (DTQ->DTQ_SERTMS == StrZero(3, Len(DTQ->DTQ_SERTMS)))

				If !Empty(GDFieldGet( 'DUA_DATCHG', nx )) .And. ( Empty(GDFieldGet( 'DUA_HORCHG', nx )) .Or.;
					Empty(GDFieldGet( 'DUA_DATSAI', nx )) .Or. Empty(GDFieldGet( 'DUA_HORSAI', nx )) )

					Help("",1,"TMSA36049") // Os campos data/hora chegada e data/hora saida devem ser preenchidos.
					lRet := .F.
				EndIf
			EndIf
			RestArea( aAreaDTQ )
		Else
			lRet := !Empty(GDFieldGet( 'DUA_DATCHG', nx )) .And. !Empty(GDFieldGet( 'DUA_HORCHG', nx ))
			If !lRet
				Help("",1,"TMSA36082") //'Data/Hora Chegada deverá ser informada.'
			EndIf
		EndIf
		If lAllMark
		   cMotivo := GdFieldGet('DUA_MOTIVO',n)
			For nW:=n To Len(aCols)
				GdFieldPut('DUA_MOTIVO',cMotivo,nW)
			Next
		EndIf
		If !Empty(M->DUA_FILORI) .And. !Empty(M->DUA_VIAGEM)
			DTQ->(DbSetOrder(2))   // DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
			If DTQ->(DbSeek(xFilial("DTQ")+M->DUA_FILORI+M->DUA_VIAGEM)) .And. DTQ->DTQ_DATGER > GdFieldGet('DUA_DATOCO',nx)
				Help("",1,"TMSA36070",,STR0011  + ':' + GdFieldGet('DUA_SEQOCO',n),3,01 ) //"Data da Ocorrencia nao pode ser menor que a data de geracao da Viagem"
				Inclui := IncluiOld
				Return( .F. )
			EndIf
		Else
			If lRet .And. !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
				DT6->(DbSetOrder(1))
				If DT6->(MsSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie)) .And. DT6->DT6_DATEMI > GdFieldGet('DUA_DATOCO',nx)
			  	   Help("",1,"TMSA36075",,STR0011 + ':' + GdFieldGet('DUA_SEQOCO',n),3,01 ) //"Data da Ocorrencia nao pode ser menor que a data do Documento"
			  	   Inclui := IncluiOld
				   Return( .F. )
				EndIf
			EndIf
		EndIf
		If lRet .And. (cTipOco == "06" .And. cTipPnd $ "01/02/04") .And. (nTmsOpcx == 3 .Or. lAjusta)
			If Ascan(aNFAvaria,{ |x| x[1]+x[5] == cFilDoc+cDoc+cSerie + cTipPnd }) == 0
				lRet:= .F.
				Help('', 1, 'TMSA360A7',, STR0098 + GdFieldGet('DUA_SEQOCO',nX),3,01 )  // Selecione o documento do cliente pendente.
			EndIf
		EndIf

		//-- Rentabilidade/Ocorrencia -> Tratamento Ocorrencia Tipo 21 - Entrega Por Trecho
		//-- Não Permite Apontar Tipo De Ocorrencia '21' Com Documento Encerrado
		If 	cTipOco == StrZero(21,Len(DT2->DT2_TIPOCO)) .And.; //-- 21 - Entrega Por Trecho
			GDFieldGet( 'DUA_ESTOCO', nx ) <> StrZero(1,TamSX3('DUA_ESTOCO')[1]) //-- E Não For Estorno

			//-- Posiciona Nos Documentos Da Viagem
			DbSelectArea("DT6")
			DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
			If MsSeek( FWxFilial("DT6") + cFilDoc + cDoc + cSerie , .f. ) .And. DT6->DT6_STATUS == StrZero(7,Len(DT6->DT6_STATUS))

				Help('',1,'TMSA360D0') //"Este Tipo De Ocorrência Não Pode Ser Utilizado Para Documentos Com Status 7 (Encerrado)."
				lRet := .F.

			EndIf
		EndIf

		//-- Rentabilidade/Ocorrencia -> Tratamento Ocorrencia Tipo 21 - Entrega Por Trecho
		//-- Permite apontar registro de ocorrência do tipo receita (DT2_TIPOCO $ '16/17/18/19/20' ) apenas para documento fiscal original (DT6_DOCTMS$'2/5').
		If 	cTipOco == StrZero(16,Len(DT2->DT2_TIPOCO)) .Or. ;
			cTipOco == StrZero(17,Len(DT2->DT2_TIPOCO)) .Or. ;
			cTipOco == StrZero(18,Len(DT2->DT2_TIPOCO)) .Or. ;
			cTipOco == StrZero(19,Len(DT2->DT2_TIPOCO)) .Or. ;
			cTipOco == StrZero(20,Len(DT2->DT2_TIPOCO))

			//-- Posiciona Nos Documentos Da Viagem -- Validação retirada de acordo com solicitação de Fatima e Eduardo Alberti
			/*DbSelectArea("DT6")
			DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
			If MsSeek( FWxFilial("DT6") + cFilDoc + cDoc + cSerie , .f. )

				If DT6->DT6_DOCTMS <> StrZero(2,Len(DT6->DT6_DOCTMS)) .And. DT6->DT6_DOCTMS <> StrZero(5,Len(DT6->DT6_DOCTMS))
					Help('',1,'TMSA360D1') //"Este Tipo De Ocorrência Não Pode Ser Utilizada Para Este Tipo De Documento."
					lRet := .F.
				EndIf
			EndIf*/

			//-- Verifica se a ocorrência 20 já possui devolução ou bloqueio
			If lRet .And. cTipOco == StrZero(20,Len(DT2->DT2_TIPOCO)) ;
					.And. nTmsOpcx != 4; //-- Opção diferente de estorno
 					.And. GDFieldGet( 'DUA_ESTOCO', nx ) <> StrZero(1,TamSX3('DUA_ESTOCO')[1]) //-- E Não For Estorno

				//-- Verifica se há documento de devolução já emitido para a Nf/Documento
				aAreaAux := {DT6->(GetArea()),DY4->(GetArea()),GetArea()}
				DT6->(DbSetOrder(8)) //-- DT6_FILIAL+DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO
				DT6->(MsSeek( FWxFilial("DT6") + cFilDoc + cDoc + cSerie , .f. ))
				Do While lRet .And. DT6->(!Eof()) .And. FWxFilial("DT6") + cFilDoc + cDoc + cSerie == DT6->(DT6_FILIAL+DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO)
					//-- DOCTMS => 6 - Devolução
					If DT6->DT6_DOCTMS == StrZero( 6, Len( DT6->DT6_DOCTMS ) )
						//--Não encontrou DY4, significa devolução do CT-e inteiro
						If !TmsPsqDY4(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
							Help('',1,'TMSA360F2') //-- Já existe documento de devolução emitido para este documento
							lRet := .F.
						Else
							DY4->(DbSetOrder(1)) //-- DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE+DY4_NUMNFC+DY4_SERNFC+DY4_CODPRO
							DY4->(MsSeek(xFilial("DY4")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE), .F.) )
							Do While lRet .And. DY4->(!Eof()) .And. xFilial("DY4")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE) == DY4->(DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE)
								//-- Pesquisa se a(s) nf(s) do documento estão selecionadas na Ocorrência.
								If (nSeek := aScan(aNfAvaria,{ |x| x[1] == cFilDoc + cDoc + cSerie })) > 0 ;
									.And. aScan(aNfAvaria[nSeek][2], {|x| !aTail(x) .And. x[GdFieldPos("DV4_NUMNFC",aHeaderDV4)] + x[GdFieldPos("DV4_SERNFC",aHeaderDV4)] == DY4->(DY4_NUMNFC+DY4_SERNFC)} ) > 0
									Help('',1,'TMSA360F2') //-- Já existe documento de devolução emitido para este documento
									lRet := .F.
								EndIf

								DY4->(DbSkip())
							EndDo
						EndIf
					EndIf
					DT6->(DbSkip())
				Enddo
				aEval(aAreaAux,{|xArea| RestArea(xArea)})

				//-- Verifica se há ocorrencia 20 já apontada para o Documento/NF
				aAreaAux := {DUA->(GetArea()),DT2->(GetArea()),DV4->(GetArea()),GetArea()}
				DUA->(DbSetOrder(4)) //--DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SERIE
				DUA->(MsSeek(FWxFilial("DUA") + cFilDoc + cDoc + cSerie))
				Do While lRet .And. DUA->(!Eof()) .And. DUA->(DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SERIE) == FWxFilial("DUA") + cFilDoc + cDoc + cSerie
					If Posicione("DT2",1,xFilial("DT2")+ DUA->DUA_CODOCO,"DT2_TIPOCO") == StrZero(20,Len(DT2->DT2_TIPOCO))

						//-- Percorrer a DV4, verificando se a NF selecionada está na ocorrência.
						DV4->(DbSetOrder(1)) //-- DV4_FILIAL+DV4_FILOCO+DV4_NUMOCO+DV4_FILDOC+DV4_DOC+DV4_SERIE+DV4_NUMNFC+DV4_SERNFC
						DV4->(DbSeek(xFilial("DV4")+DUA->(DUA_FILOCO+DUA_NUMOCO+DUA_FILDOC+DUA_DOC+DUA_SERIE)))
						Do While lRet .And. DV4->(!Eof()) ;
						              .And. DV4->(DV4_FILIAL+DV4_FILOCO+DV4_NUMOCO+DV4_FILDOC+DV4_DOC+DV4_SERIE) == xFilial("DV4")+DUA->(DUA_FILOCO+DUA_NUMOCO+DUA_FILDOC+DUA_DOC+DUA_SERIE)

							//-- Pesquisa se alguma da(s) nf(s) da Ocorrência anterior estão selecionadas na Ocorrência atual.
							If (nSeek := aScan(aNfAvaria,{ |x| x[1] == cFilDoc + cDoc + cSerie })) > 0 ;
								.And. aScan(aNfAvaria[nSeek][2], {|x| !aTail(x) .And. x[GdFieldPos("DV4_NUMNFC",aHeaderDV4)] + x[GdFieldPos("DV4_SERNFC",aHeaderDV4)] == DV4->(DV4_NUMNFC+DV4_SERNFC)} ) > 0 ;
								.And. FindFunction("TMSA029USE") .And. Tmsa029Use("TMSA360")

								//-- Verifica Status Dos Registros Na Tabela DDU
								cStReg := Tmsa029Blq( 9               ,; //-- 01 - nOpc
													'TMSA360'       ,; //-- 02 - cRotina
													Nil             ,; //-- 03 - cTipBlq
													Nil             ,; //-- 04 - cFilOri
													'DUA'           ,; //-- 05 - cTab
													'1'             ,; //-- 06 - cInd
													xFilial("DUA") + cFilAnt + DUA->DUA_NUMOCO + DUA->DUA_FILORI + DUA->DUA_VIAGEM + DUA->DUA_SEQOCO ,; //-- 07 - cChave
													Nil             ,; //-- 08 - cCod
													Nil             )  //-- 09 - cDetalhe

								If cStReg != "R" //-- Existem ocorrência sem Rejeições
									Help('',1,'TMSA360F3') //-- "Existe ocorrência não-rejeitada para o Docto"
									lRet = .F.
								EndIf
							EndIf
							DV4->(DbSkip())
						Enddo
					EndIf
					DUA->(DbSkip())
				Enddo
				aEval(aAreaAux,{|xArea| RestArea(xArea)})
			EndIf
			//-- Rentabilidade/Ocorrencia -> Tratamento Campo ( Valor Despesa )
			//-- Verifica Se é Lançamento De Despesa
			If lRet .And. ( cTipOco == StrZero(17,Len(DT2->DT2_TIPOCO)) .Or. ;
				           cTipOco == StrZero(18,Len(DT2->DT2_TIPOCO)) )
				//-- Verifica Se Valor Está Zerado
				If GDFieldGet( 'DUA_VLRDSP', nx ) <= 0

					DT2->(DbSetOrder(1))
					If	DT2->(MsSeek( FWxFilial('DT2') + GdFieldGet('DUA_CODOCO',nX),.F.))
						If !Empty(DT2->DT2_CDTIPO)
						 	If GDFieldGet( 'DUA_VALINF', nx ) > 0
						 		lRet	:= .T.
						 	Else
						 		lRet	:= .F.
			 					HELP('',1,'TMSA360E0',, DT2->DT2_CODOCO +;									//-- Valor Zero Não é Permitido Para Ocorrência: ####
											STR0104 + Alltrim(RetTitle("DUA_VALINF")) + " DUA_VALINF" +;	//-- Campo: ##########
											STR0101 + StrZero(nX,05)  ,4,1)									//-- Linha: #####
							EndIf
						Else
							If DT2->DT2_ALTVLR == '2' //-- Altera Valores Na Liberação = '2' Não
								HELP('',1,'TMSA360E0',, DT2->DT2_CODOCO +;												//-- Valor Zero Não é Permitido Para Ocorrência: ####
														STR0104 + Alltrim(RetTitle("DUA_VLRDSP")) + " DUA_VLRDSP" +;	//-- Campo: ##########
														STR0101 + StrZero(nX,05)  ,4,1)									//-- Linha: #####
								lRet := .f.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

               //-- Verifica se é lançamento de receita
               If lRet .And. cTipOco == StrZero(16,Len(DT2->DT2_TIPOCO))
                    //-- Verifica Se Valor Está Zerado
                    If GDFieldGet( 'DUA_VLRRCT', nx ) <= 0

                         DT2->(DbSetOrder(1))
                         If   DT2->(MsSeek( FWxFilial('DT2') + GdFieldGet('DUA_CODOCO',nX),.F.))
                              If !Empty(DT2->DT2_CDTIPO)
                                   If GDFieldGet( 'DUA_VALINF', nx ) > 0
                                        lRet := .T.
                                   Else
                                        lRet := .F.
                                        HELP('',1,'TMSA360E0',, DT2->DT2_CODOCO +;                                           //-- Valor Zero Não é Permitido Para Ocorrência: ####
                                                       STR0104 + Alltrim(RetTitle("DUA_VALINF")) + " DUA_VALINF" +;     //-- Campo: ##########
                                                       STR0101 + StrZero(nX,05)  ,4,1)                                            //-- Linha: #####
                                   EndIf
                              Else
                                   If DT2->DT2_ALTVLR == '2' //-- Altera Valores Na Liberação = '2' Não
                                        HELP('',1,'TMSA360E0',, DT2->DT2_CODOCO +;                                                          //-- Valor Zero Não é Permitido Para Ocorrência: ####
                                                                      STR0104 + Alltrim(RetTitle("DUA_VLRRCT")) + " DUA_VLRRCT" +;     //-- Campo: ##########
                                                                      STR0101 + StrZero(nX,05)  ,4,1)                                            //-- Linha: #####
                                        lRet := .f.
                                   EndIf
                              EndIf
                         EndIf
                    EndIf
               EndIf

			//-- Validações Acréscimo/Decréscimo
			If lRet	.And. DT2->(ColumnPos('DT2_CODAED')) > 0 .And. !Empty(DT2->DT2_CODAED)
				DTQ->(DbSetOrder(2))   // DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
				If DTQ->(DbSeek(xFilial("DTQ")+M->DUA_FILORI+M->DUA_VIAGEM)) .And. DTQ->DTQ_PAGGFE == '1'
					lRet	:= .F.
					Help('',1,'TMSA360D5')//-- Não permitir apontar ocorrência de acréscimo/decréscimo quando a viagem for paga via GFE (DTQ_PAGGFE='1')
				Else
					DTY->(dbSetOrder(2))//-- FILIAL+FILORI+VIAGEM
					If DTY->( MsSeek( xFilial("DTY") + M->DUA_FILORI + M->DUA_VIAGEM ))
						lRet	:= .F.
						If nTmsOpcx <> 4
							Help('',1,'TMSA360D4') //-- Não é possível realizar o apontamento de ocorrências que possuam Acrescimo/Decrescimo (DT2_CODAED), caso o contrato de carreteiro para a viagem já esteja gerada. Os acréscimos/decréscimos não serão gravados.
						Else
							Help('',1,'TMSA360D6') //-- Não é possivel realizar o estorno da ocorrência, pois a mesma possui um acréscimo/decréscimo vinculado ao Contrato de Carreteiro.
						EndIf
					EndIf
				EndIf
			EndIf

			If lRet .And. DT2->(ColumnPos("DT2_CDTIPO")) > 0 .And. !Empty(DT2->DT2_CDTIPO)
				If Empty(GdFieldGet('DUA_CODFOR',nX))
					Help('',1,"OBRIGAT2",,RetTitle('DUA_CODFOR') + STR0101 + Alltrim(Str(nX)),04,01) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse
					lRet := .F.
				EndIf
			EndIf

		EndIf
		If lRet .And. Empty(cSerTMS)
			cSerTMS:= TMSA360DUD(cFilDoc, cDoc, cSerie)

			If cTipOco == '04' .And. cSerTMS == StrZero(2,Len(DT2->DT2_SERTMS))
				Help('',1,'TMSA02001') //O tipo de ocorrência "4-Retrabalho" deve ser utilizado somente para serviços de  transporte "1- Coleta" ou "3-Entrega".
				Return( .F. )
			EndIf

			If (cTipOco == "06" .Or. cTipOco == "09")
				If cSerTMS == StrZero(1,Len(DT2->DT2_SERTMS))
					Help('',1,'TMSA02004') //-- Tipo invalido para servico de coleta
					Return( .F. )
				Else
					If cTipOco == "06" .And. cTipPnd == "04"  .And. cSerTMS <> StrZero(3,Len(DT2->DT2_SERTMS))
				  		Help('',1,'TMSA02008') //O tipo de ocorrência "06-Gera Pendencia"  e Tipo Pendencia "04 - "Retorno Dc. Cliente" deve ser utilizado somente para serviços de  transporte "3-Entrega".
						Return( .F. )
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf nModulo == 39 //--OMS

		If lRet .And. Empty(cFilDoc) .Or. Empty(cDoc) .Or. Empty(cSerie) .Or. Empty(cCodOco)
			MsgAlert("Os campos Filial, Documento, Serie ou Codigo da Ocorrencia nao estao preenchidos")
			lRet := .F.
		EndIf

		If lRet .And. Empty(M->DUA_CODCAR) .Or. Empty(M->DUA_SEQCAR) .Or. Empty(M->DUA_IDENT)
			MsgAlert("Campos Carga, Sequencia e Ident sao obrigatorios, verifique")
			lRet := .F.
		EndIf

		//Verifica se existe a nota digitada
		If lRet
			SF2->(DbSetOrder(1))
			If lRet .And. !SF2->(DbSeek(xFilial("SF2")+cDoc+cSerie))
				MsgAlert("Nao existe a nota selecionada, verifique")
				lRet := .F.
			EndIf
		EndIf

		//--Verifica se existe a nota em um item de carga
//			DAI->(DbSetOrder(1))
//			If lRet .And. !DAI->(DbSeek(xFilial("DAI")+cDoc+cSerie))
// 				MsgAlert("Nao existe a nota selecionada, verifique")
//				lRet := .F.
//			EndIf

		//Checa os Itens Duplicados
		If lRet
			lRet := GDCheckKey( {"DUA_FILDOC","DUA_DOC","DUA_SERIE"}, 4 )
		EndIf

		If !lRet
			Inclui := IncluiOld
			Return( .F. )
		EndIf

	EndIf
Else
	If nModulo == 43 //--TMS
		DT2->(DbSetOrder(1))  // DT2_FILIAL+DT2_CODOCO
		DT2->(DbSeek(xFilial("DT2")+cCodOco))

		If (DT2->DT2_TIPOCO == "06" .And. DT2->DT2_TIPPND $ "01/02/04") .Or. DT2->DT2_TIPOCO $ "19|20"
			If (nPosDV4 := Ascan(aNFAvaria,{ |x| x[1]+x[6] == GdFieldGet('DUA_FILDOC',n)+GdFieldGet('DUA_DOC',n)+GdFieldGet('DUA_SERIE',n) + AllTrim(Str(n)) })) > 0
				aDel(aNFAvaria,nPosDV4)
				aSize(aNFAvaria,Len(aNFAvaria)-1)
			EndIf
		EndIf
	EndIf
EndIf

If !lAllMark
	M->DUA_MOTIVO 	:= " "
EndIf

If lRet .And. lTM360LOK
	lRet := ExecBlock('TM360LOK',.F.,.F.,)
	If	ValType(lRet) <> 'L'
		lRet := .F.
	EndIf
EndIf

Inclui := IncluiOld

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA360Dup³ Autor ³ Antonio C Ferreira    ³ Data ³19.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica a Duplicacao apenas dos Itens Novos.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA360Dup(aColunas, cTipOco)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Colunas.                                           ³±±
±±³          ³ ExpC1 - Tipo da Ocorrencia.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA360Dup(aColunas, cTipOco)

Local nA , nB
Local aColVal    := {}
Local lRet       := .T.
Local nInicio    := If( cTipOco==StrZero( 2, Len( DT2->DT2_TIPOCO ) ), 1, nBaseACols)
Local cDocumento := GDFieldGet("DUA_FILDOC", n) + GDFieldGet("DUA_DOC", n) + GDFieldGet("DUA_SERIE", n)

For nA := 1 to Len(aColunas)
	AAdd(aColVal, {aColunas[nA], GDFieldGet(aColunas[nA], n)})
Next

For nA := 1 to Len(aCols)
	If	nA == n .Or. GDDeleted( nA )
		Loop
	EndIf

	If nA >= nInicio
		For nB := 1 to Len(aColVal)
			If GDFieldGet(aColVal[nB,1], nA) != aColVal[nB,2]
				Exit
			EndIf
		Next

		If nB > Len(aColVal)
			Help('',1,'TMSA36072',, aCols[nA,1] ,1,33) //"Dados duplicados da Sequencia No"
			lRet := .F.
			Exit
		EndIf
	EndIf

	// Verifica se tem Tipo de Ocorrencia Normal para o Documento
	If	nA < n .And. GDFieldGet("DUA_FILDOC", nA) + GDFieldGet("DUA_DOC", nA) + GDFieldGet("DUA_SERIE", nA) = Iif( Empty(cDocumento),'', cDocumento ) ;
		.And. DTQ->DTQ_SERTMS == StrZero(1, Len(DTQ->DTQ_SERTMS))
		If	Posicione("DT2",1,xFilial("DT2") + GDFieldGet("DUA_CODOCO", nA), "DT2_TIPOCO") == StrZero( 1, Len( DT2->DT2_TIPOCO ) )
			Help(' ', 1, 'TMSA36017',,STR0011 + GDFieldGet("DUA_SEQOCO", nA),5,11)  //-- 'Processo ja encerrado para esse Documento!' 'Sequencia No '##
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA360TOk³ Autor ³ Antonio C Ferreira    ³ Data ³25.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tudo Ok da GetDados                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA360TOk(nTmsOpcx)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao Selecionada.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA360TOk(nTmsOpcx)
Local cSeek      := ""
Local lRet       := .T.
Local lAchou     := .F.
Local nSavCols   := n
Local nx         := 0
Local aDocs      := {}
Local aDocsPend	 := {}
Local nPos       := 0
Local cChave     := ''
Local cStatus    := ''
Local lSobra     := .F.
Local lDocRed    := .F.
Local cSeekTrf   := ""
Local nCntFor    := 0
Local nPosFilVtr := Ascan(aHeader, {|x| AllTrim(x[2]) == "DUA_FILVTR"})
Local nPosNumVtr := Ascan(aHeader, {|x| AllTrim(x[2]) == "DUA_NUMVTR"})
Local cFilVtr    := ''
Local cNumVtr    := ''
Local lMaisVig   := .F.
Local aTranVig   := {}
Local nCont      := 0
Local cQuery   	 := ''
Local cAliasDUD  := ''
Local cFilDoc    := ''
Local cNumDoc    := ''
Local cSerie     := ''
Local cAtivDca   := GetMV('MV_ATIVDCA',,'')
Local cAliasQry  := GetNextAlias()
Local nPCanOp    := GetMv('MV_PCANOP',,1) // Opcoes para o param. MV_PCANOP: 0-Cancelar Operacao/1-Pergunta sobre o Canc./2-Nao Cancela
Local nOpcao	 := 0
Local lTmsCdCa	 := GetMv('MV_TMSCDCA',,.T.) // Controla descarregamento.
Local aArea091	 := {}
Local lDocEntre  := .F. //Documento Entregue
Local cOcorCfe    := SuperGetMv('MV_OCORCFE',,"")
Local cCodRB1	 := ''
Local cCodRB2	 := ''
Local cCodRB3	 := ''
Local lTercRbq := DTR->(ColumnPos("DTR_CODRB3")) > 0
Local cSerTMS  := ""
Local lGFE     := nModulo == 78 .And. DT2->DT2_TIPRDP <> StrZero(2,Len(DT2->DT2_TIPOCO))
Local lDocApoio := .F.
Local aMsgErr  := {}
Local nCntFor1 := 0
Local lITmsDmd := SuperGetMv("MV_ITMSDMD",,.F.)
Local aAreaDTA := DTA->(GetArea())
Local lTMSAE81	:= FWIsInCallStack("TMSAE81")

l360Auto := If (Type("l360Auto") == "U",.F.,l360Auto)

//-- Analisa se os campos obrigatorios da Enchoice foram informados.
lRet := Obrigatorio( aGets, aTela )

//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet .And. !l360Auto
	lRet := oTmsGetD:ChkObrigat( nSavCols )
EndIf

If !Empty(DT2->DT2_SERTMS)
	cSerTMS := DT2->DT2_SERTMS
Else
	cSerTMS:= TMSA360DUD(DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE)
EndIf

If DT2->DT2_TIPOCO == StrZero(1,Len(DT2->DT2_TIPOCO)) .And. Empty(M->DUA_FILORI) .And. Empty(M->DUA_VIAGEM)

	If cSerTMS == StrZero(3,Len(DT2->DT2_SERTMS))
		//verifico se a viagem que trouxe o documento ate esta filial ja teve o seu descarregamento apontado,
		//se nao teve, nao deixo apontar encerra processo da viagem de entrega.
		cQuery := " SELECT DUD1.DUD_FILORI, DUD1.DUD_FILDOC, DUD1.DUD_DOC, "
		cQuery += " DUD1.DUD_SERIE, DTW.DTW_FILORI, DTW.DTW_VIAGEM, DTW.DTW_SEQUEN "
		cQuery += " FROM " + RetSqlName("DUD") + " DUD1 "
		cQuery += " JOIN " + RetSqlName("DUD") + " DUD2 "
		cQuery += " ON DUD2.DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "AND DUD2.DUD_FILORI = DUD1.DUD_FILVGE "
		cQuery += "AND DUD2.DUD_VIAGEM = DUD1.DUD_NUMVGE "
		cQuery += "AND DUD2.DUD_FILDOC = DUD1.DUD_FILDOC "
		cQuery += "AND DUD2.DUD_DOC    = DUD1.DUD_DOC    "
		cQuery += "AND DUD2.DUD_SERIE  = DUD1.DUD_SERIE  "
		cQuery += "AND DUD2.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN " + RetSqlName("DTW") + " DTW "
		cQuery += " ON DTW_FILIAL = '" + xFilial("DTW") + "' "
		cQuery += "AND DTW_FILORI = DUD2.DUD_FILORI "
		cQuery += "AND DTW_VIAGEM = DUD2.DUD_VIAGEM "
		cQuery += "AND DTW_ATIVID = '" + cAtivDca + "' "
		cQuery += "AND DTW_FILATI = '" + cFilAnt  + "' "
		//aqui verifico se o status esta em aberto da operacao
		cQuery += "AND DTW_STATUS = '" + StrZero(1,Len(DTW->DTW_STATUS)) + "' "
		cQuery += "AND DTW.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE DUD1.DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "AND DUD1.DUD_FILDOC = '" + DUD->DUD_FILDOC + "' "
		cQuery += "AND DUD1.DUD_DOC    = '" + DUD->DUD_DOC    + "' "
		cQuery += "AND DUD1.DUD_SERIE  = '" + DUD->DUD_SERIE  + "' "
		cQuery += "AND DUD1.DUD_SERTMS = '" + StrZero(3,Len(DT2->DT2_SERTMS)) + "' "
		cQuery += "AND DUD1.DUD_VIAGEM = '" + Space(Len(DUD->DUD_VIAGEM)) + "' "
		cQuery += "AND DUD1.DUD_STATUS = '" + StrZero(1,Len(DUD->DUD_STATUS)) + "' "
		cQuery += "AND DUD1.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAliasQry, .F., .T.)
		If (cAliasQry)->( !Eof() )
			// Opcoes para o param. MV_PCANOP: 0-Cancelar Operacao/1-Pergunta sobre o Canc./2-Nao Cancela
			Do Case
				Case nPCanOp == 0 						// Cancelar a operação de descarregamento.
					nOpcao := 3

				Case nPCanOp == 1						// Perguntar se as Operacoes Anteriores deverao ser canceladas.
					If MsgYesNo(STR0057, STR0055)		// "Existe operacao de descarregamento 'em aberto'. Deseja cancelar essas operacoes ?"
						nOpcao := 3
					ElseIf(lTmsCdCa)
						lRet := .F.
						Help('',1,'TMSA36094',, STR0029 + (cAliasQry)->DUD_FILDOC +'/'+ (cAliasQry)->DUD_DOC +'/'+ (cAliasQry)->DUD_SERIE,4,1)
					EndIf//"Nao e possivel encerrar o processo deste documento quando nao foi efetuado o descarregamento da viagem anterior.

				Case nPCanOp == 2 .And. (lTmsCdCa) 			// Apontamento Obrigatorio das Operacoes de descarregamento anteriores
					lRet := .F.
					Help('',1,'TMSA36094',, STR0029 + (cAliasQry)->DUD_FILDOC +'/'+ (cAliasQry)->DUD_DOC +'/'+ (cAliasQry)->DUD_SERIE,4,1)
					//"Nao e possivel encerrar o processo deste documento quando nao foi efetuado o descarregamento da viagem anterior.

				Case nPCanOp == 3 .And. (lTmsCdCa)			// Apontamento Obrigatorio das Operacoes de descarregamento anteriores
					lRet := .F.
					Help('',1,'TMSA36094',, STR0029 + (cAliasQry)->DUD_FILDOC +'/'+ (cAliasQry)->DUD_DOC +'/'+ (cAliasQry)->DUD_SERIE,4,1)
					//"Nao e possivel encerrar o processo deste documento quando nao foi efetuado o descarregamento da viagem anterior.
			EndCase
			If ( nOpcao == 3)
				//-- Faz o CANCELAMENTO da operação de descarregamento.
				TMSA350COp( (cAliasQry)->DUD_FILDOC,(cAliasQry)->DTW_VIAGEM,(cAliasQry)->DTW_SEQUEN )
			EndIf
		EndIf
		(cAliasQry)->( DbCloseArea() )
	EndIf
EndIf

//-- Analisa o linha ok.
If lRet
	// No caso de poder mudar o Numero da Viagem todos precisam ser verificados.
	DT2->(DbSetOrder(1))
	For nx := 1 To Len(aCols)
		DT2->(DbSeek(xFilial("DT2")+GdFieldGet("DUA_CODOCO",nx) ))

		If !(lRet := TMSA360LinOk(nx,nTmsOpcx))
			Exit
		EndIf
		If nModulo == 43 .Or. lGFE //--TMS
			//-- Valida Estorno de Ocorrencias
			If GDFieldGet( 'DUA_ESTOCO', nx ) == StrZero(1,TamSX3('DUA_ESTOCO')[1]) // Estorna
				lRet := TMSA360Vld('DUA_ESTOCO', , , .T., nTmsOpcx)
			EndIf

			//-- Valida transferencia de viagem
			If lRet .And. nTmsOpcx == 3 //-- Incluir apontamento
				//-- Somente permitir a Transferencia se a Viagem tiver algum Documento com Status "2" (Em Transito)

				lDocRed:= TMA360IDFV(GdFieldGet("DUA_FILDOC",nx), GdFieldGet("DUA_DOC",nx), GdFieldGet("DUA_SERIE",nx), .F., M->DUA_FILORI, M->DUA_VIAGEM )

	    		DUD->(DbSetOrder(1))
				If lGFE .And. DUD->(DbSeek(cSeek := xFilial("DUD") + GdFieldGet("DUA_FILDOC",nx) + GdFieldGet("DUA_DOC",nx) + GdFieldGet("DUA_SERIE",nx) ))
					Do While !DUD->(Eof()) .And. DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE) == cSeek
						If !Empty(DUD->DUD_CHVEXT) .And. !Empty(DUD->DUD_VIAGEM)
							lDocRed := .T.
							Exit
						EndIf
						DUD->(dbSkip())
					EndDo
				EndIf
		  		//-- So valida esta ocorrencia sem viagem para doc. <> de redespacho
				If !lDocRed .And. ( DT2->DT2_TIPOCO == StrZero(4,Len(DT2->DT2_TIPOCO)) .Or. DT2->DT2_TIPOCO == StrZero(13,Len(DT2->DT2_TIPOCO)) .Or. ;
	                (DT2->DT2_TIPOCO == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND == StrZero(4,Len(DT2->DT2_TIPPND)) )) .And.;
					(Empty(M->DUA_FILORI) .Or. Empty(M->DUA_VIAGEM)) .And. !__lPyme
					Help(' ',1,'TMSA36034') // Tipo de Ocorrencia Invalido para Registro de Ocorrencia sem Viagem ...
					Return( .F. )
				EndIf

				If DT2->DT2_CATOCO == StrZero(2,Len(DT2->DT2_CATOCO)) .And. DT2->DT2_TIPOCO == StrZero(8,Len(DT2->DT2_TIPOCO))
					DUD->(DbSetOrder(2))
					If DUD->(DbSeek(cSeek := xFilial("DUD")+M->DUA_FILORI+M->DUA_VIAGEM))
						Do While !DUD->(Eof()) .And. DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM) == cSeek
							If DUD->DUD_STATUS == StrZero(2, Len(DUD->DUD_STATUS))
								lAchou := .T.
								Exit
							EndIf
							DUD->(dbSkip())
						EndDo
						If !lAchou
							Help("",1,"TMSA36044") //-- Esta viagem nao possui nenhum documento em transito ...
							lRet := .F.
							Exit
						EndIf
					EndIf
				EndIf
				If lRet
					// Se Chamado pelo Check-List preciso pular a validação pois não é possivel informar KM pelo JOB CheckList
					If DT2->DT2_ODOCHG == '1' .And. Empty(GdFieldGet('DUA_ODOCHG',nx)) .AND. !lTMSAE81
						Help('',1,'TMSA36087') //-- 'E necessario informar a quilometragem de entrada do veiculo!'
						lRet := .F.
					EndIf
 				EndIf
			EndIf
			aArea091	:= GetArea()
			//-- Verificando se existem ocorrências para o documento.
			//-- Validacao para casos onde nao haja previamente ocorrencia para o documento
	   		DT2->(DbSetOrder(1))
			DT2->(DbSeek(xFilial("DT2")+GdFieldGet('DUA_CODOCO',nx))) //-- Toda ocorrência cadastrada será localizada.
			//-- Se a ocorrência encontrada for do tipo ENCERRA ou GERA PENDENCIA faz tratamento abaixo de acordo com comentário;
			If (DT2->DT2_TIPOCO == StrZero(1,Len(DT2->DT2_TIPOCO)) .Or. DT2->DT2_TIPOCO == StrZero(6,Len(DT2->DT2_TIPOCO)) )
				//se houver ocorrencias encerra processo e gera pendencia para o mesmo documento verifica se a quantidade
				//dos volumes apontadas confere
				If lRet .And. nTmsOpcx == 3 .And. cSerTMS == StrZero(3,Len(DUA->DUA_SERTMS)) .And. !GDdeleted(nx)//-- Incluir apontamento
					cStatus := StrZero( 1, Len( DT2->DT2_TIPOCO ) ) + "/"+ StrZero( 6, Len( DT2->DT2_TIPOCO ) )
					If Posicione('DT2',1,xFilial('DT2') + GdFieldGet('DUA_CODOCO',nx) ,'DT2_TIPOCO') $ cStatus
						//armazena valores por documento da quantidade digitada na ocorrência para verificar se esta de acordo com
						//a quantidade que esta no documento
						cChave := GdFieldGet('DUA_FILDOC',nx) + GdFieldGet('DUA_DOC',nx) + GdFieldGet('DUA_SERIE',nx)
						lSobra := ( DT2->DT2_TIPOCO == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND == StrZero(3,Len(DT2->DT2_TIPPND)) ) //-- Sobra
						If !(lSobra .And. Empty(cChave)) //Se tipo de ocorrencia eh sobra e nao ha documento
							lDocEntre:= (Posicione('DT6',1, xFilial("DT6") + cChave,"DT6_STATUS")  == '7')
							
							If DT2->DT2_TIPOCO == StrZero(1,Len(DT2->DT2_TIPOCO))
								
								If ( nPos := Ascan( aDocs,{ |x| x[1]+x[2]+x[3]  == cChave } ) ) == 0
									AAdd( aDocs, { GdFieldGet('DUA_FILDOC',nx) , ;
									GdFieldGet('DUA_DOC',nx) , ;
									GdFieldGet('DUA_SERIE',nx) , ;
									GdFieldGet('DUA_QTDOCO',nx) , ;
									Iif(!lDocEntre, GdFieldGet('DUA_QTDOCO',nx), Posicione('DT6',1, xFilial("DT6") + cChave,"DT6_QTDVOL") ) } )
								ElseIf aDocs[nPos,4] < DT6->DT6_QTDVOL
									aDocs[nPos,4] += GdFieldGet('DUA_QTDOCO',nx)
								EndIf

							ElseIf DT2->DT2_TIPOCO == StrZero(6,Len(DT2->DT2_TIPOCO)) 

								If ( nPos := Ascan( aDocsPend,{ |x| x[1]+x[2]+x[3]  == cChave } ) ) == 0
									AAdd( aDocsPend, { GdFieldGet('DUA_FILDOC',nx) , ;
									GdFieldGet('DUA_DOC',nx) , ;
									GdFieldGet('DUA_SERIE',nx) , ;
									GdFieldGet('DUA_QTDOCO',nx) , ;
									Iif(!lDocEntre, GdFieldGet('DUA_QTDOCO',nx), Posicione('DT6',1, xFilial("DT6") + cChave,"DT6_QTDVOL") ) } )
								ElseIf aDocsPend[nPos,4] < DT6->DT6_QTDVOL
									aDocsPend[nPos,4] += GdFieldGet('DUA_QTDOCO',nx)
								EndIf

							EndIf

						EndIf
					EndIf
				EndIf

				// Verifica se é documento de apoio
				If ExistFunc("FDOCAPOIO")
					lDocApoio := FDocApoio(DT6->DT6_DOCTMS)
				EndIf

				//Nao permite apontar encessa processo para CT-e nao autorizado
				DTP->(DbSetOrder(2))
				DTP->(MsSeek(xFilial("DTP")+DT6->DT6_FILORI+DT6->DT6_LOTNFC))
				If lRet .And. DT2->DT2_TIPOCO == StrZero( 1, Len(DT2->DT2_TIPOCO )) .And. DT2->DT2_CATOCO == StrZero(1,Len(DT2->DT2_CATOCO)) .And.;
					(DTP->DTP_TIPLOT == StrZero(3,Len(DTP->DTP_TIPLOT)) .Or. DTP->DTP_TIPLOT == StrZero(4,Len(DTP->DTP_TIPLOT))) .And.;
					(Alltrim(DT6->DT6_IDRCTE) <> "100" .And. Empty(DT6->DT6_CHVCTG) .And. Alltrim(DT6->DT6_IDRCTE) <> "136") .And. ;
					(DT6->DT6_SERTMS == StrZero(2,Len(DT6->DT6_SERTMS)) .Or. DT6->DT6_SERTMS == StrZero(3,Len(DT6->DT6_SERTMS))) .AND. ;
					DT6->DT6_DOCTMS  <> '5'  .And. !lDocApoio
					Help(' ', 1, 'TMSA360F5')  //-- Não poderá ser apontada ocorrência de "Encerra Processo" para Doc. não autorizado na SEFAZ.
					lRet := .F.
				EndIf
				
			EndIf
			RestArea(aArea091)

			DT2->(DbSetOrder(1))
			If DT2->(DbSeek(xFilial("DT2")+GdFieldGet("DUA_CODOCO",nx) ))
				//Verifica se estorno eh do tipo Retorna Documento e opcao de Estorno.
				If DT2->DT2_TIPOCO == StrZero(4,Len(DT2->DT2_TIPOCO)) .And. nTmsOpcx == 4 .And. aCols[nX][2] = StrZero(1,TamSX3('DUA_ESTOCO')[1]) //--Estornar
					cFilDoc := GdFieldGet('DUA_FILDOC',nx)
					cNumDoc := GdFieldGet('DUA_DOC',nx)
					cSerie  := GdFieldGet('DUA_SERIE',nx)
					If !Empty(DT2->DT2_SERTMS)
						cSerTms := DT2->DT2_SERTMS
					Else
						cSerTMS:= TMSA360DUD(cFilDoc, cNumDoc, cSerie)
					Endif

					cAliasDUD := GetNextAlias()

					//cQuery := " SELECT DUD_VIAGEM FROM "
					cQuery := " SELECT (MAX(R_E_C_N_O_)) R_E_C_N_O_"
					cQuery += "   FROM " + RetSqlName("DUD")
					cQuery += " WHERE DUD_FILIAL = '" + xFilial('DUD') + "' "
					cQuery += " AND DUD_FILDOC = '" + cFilDoc + "' "
					cQuery += " AND DUD_DOC = '"  + cNumDoc + "' "
					cQuery += " AND DUD_SERIE = '" + cSerie + "' "
					If !Empty(cSerTms)
						cQuery += " AND DUD_SERTMS = '" + cSerTms + "' "
					EndIF
					cQuery += "    AND DUD_FILORI = '" + DUA->DUA_FILORI + "' "
					cQuery += " AND DUD_VIAGEM <> ''
					//cQuery += "    AND DUD_STATUS <> '9'
					cQuery += " AND D_E_L_E_T_ = ' '

					cQuery := ChangeQuery( cQuery )
					dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasDUD, .F., .T. )

					If (cAliasDUD)->(!Eof())
			   		If (cAliasDUD)->R_E_C_N_O_ > 0
				  		aAreaDUD := DUD->( GetArea() )

	    	      		DUD->(dbGoto((cAliasDUD)->R_E_C_N_O_))

		    	  		If DUD->DUD_VIAGEM != DUA->DUA_VIAGEM .And. Empty(DUD->DUD_CHVEXT)
	      		     		HELP('',1,'TMSA360A3',, DUD->DUD_VIAGEM,4,1) //-- Nao é possível estornar a ocorrencia do tipo retorna documento que está amarrada à viagem:
				     		lRet = .F.
			      		EndIf
            	  		RestArea( aAreaDUD )
			   		EndIf
					EndIf

					(cAliasDUD)->(dbCloseArea())

				EndIf
			EndIf
		EndIf
	Next nx
	If nModulo == 43 //--TMS
		
		//-- Carrega os documentos de gera pendencia no array principal
		For nX := 1 To Len(aDocsPend)
			Aadd( aDocs , aClone(aDocsPend[nX]))
		Next
		
		//--Evitar erro no Carregamento e na Transferencia de Reboque
		cFilVtr  := ''
		cNumVtr  := ''
		lMaisVig := .F.
		For nCntFor:=1 To Len(aCols)
			DT2->(DbSeek(xFilial("DT2")+ GdFieldGet("DUA_CODOCO", nCntFor) ))
			If DT2->DT2_TIPOCO == StrZero( 8, Len(DT2->DT2_TIPOCO ) ) //--Transferencia
				If Empty(cFilVtr) .And. Empty(cNumVtr)
					cFilVtr := GdFieldGet('DUA_FILVTR', nCntFor)
					cNumVtr := GdFieldGet('DUA_NUMVTR', nCntFor)
				Else
					If Ascan(aCols,{|x| x[nPosFilVtr]+x[nPosNumVtr]!=cFilVtr+cNumVtr }) > 0
						lMaisVig := .T. //--Verifica se a mais de uma viagem para otimizar a transferencia
					EndIf
					Exit
				EndIf
			EndIf
		Next
		If lMaisVig
			aTranVig := {}
			//-- Nao permite transferencia para duas viagens diferentes sem reboques para nao gerar erro no DTR
			For nCntFor:=1 To Len(aCols)
				cFilVtr := GdFieldGet('DUA_FILVTR', nCntFor)
				cNumVtr := GdFieldGet('DUA_NUMVTR', nCntFor)
				If Ascan( aTranVig, {|x| x[1] == cFilVtr+cNumVtr }) == 0
					DTR->(DbSetOrder(1))
					DTR->( DbSeek( cSeekTrf := xFilial('DTR') + M->DUA_FILORI+M->DUA_VIAGEM ) )
					Do While !DTR->(Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM)==cSeekTrf
						DA3->(DbSeek(xFilial('DA3')+DTR->DTR_CODVEI))
						DUT->(DbSeek(xFilial('DUT')+DA3->DA3_TIPVEI))
						//-- Se for Cavalo ou o Reboque ja estiver preenchido
						If DUT->DUT_CATVEI == StrZero(2,Len(DUT->DUT_CATVEI)) .Or. !Empty(DTR->DTR_CODRB1)
							cCodRB1 := DTR->DTR_CODRB1
							cCodRB2 := DTR->DTR_CODRB2
							If lTercRbq
								cCodRB3 := DTR->DTR_CODRB3
							EndIf
							DTR->( DbSeek( cSeekTrf := xFilial('DTR') + cFilVtr + cNumVtr ) )
							Do While !DTR->(Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM)==cSeekTrf
								DA3->(DbSeek(xFilial('DA3')+DTR->DTR_CODVEI))
								DUT->(DbSeek(xFilial('DUT')+DA3->DA3_TIPVEI))
								// Se nao for Cavalo ou o Reboque ja estiver preenchido
								If DUT->DUT_CATVEI <> StrZero(2,Len(DUT->DUT_CATVEI)) .Or. !Empty(DTR->DTR_CODRB1)
									DTR->(dbSkip())
									Loop
								EndIf
								If (DTR->DTR_CODRB1 != cCodRB1) .Or. (DTR->DTR_CODRB2 != cCodRB2) .Or. (lTercRbq .And. (DTR->DTR_CODRB3 != cCodRB3))
									If Ascan( aTranVig, {|x| x[1] == cFilVtr+cNumVtr }) == 0
										AAdd(aTranVig,{cFilVtr+cNumVtr,.T.})
									EndIf
								EndIf
								DTR->(dbSkip())
							EndDo
						EndIf
						DTR->(dbSkip())
					EndDo
				EndIf
			Next
			nCont := 0
			aEval(aTranVig ,{|x| Iif(x[2],nCont++,'') })
			If nCont > 1
				Help('',1,'TMSA360A0', ,  )
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

If lRet .And. nModulo == 43 //--TMS
	For nx := 1 To Len(aDocs)
		If aDocs[nx,4] > aDocs[nx,5]
			Help('',1,'TMSA36089', , STR0029 + aDocs[nx,1]+'/'+aDocs[nx,2]+'/'+aDocs[nx,3] ) //-- 'A quantidade apontada nas ocorrências nao pode ser maior que a quantidade do ctrc'
			lRet := .F.
			Exit
		EndIf
		If aDocs[nx,4] < aDocs[nx,5] //-- 'A quantidade apontada nas ocorrências nao pode ser menor que a quantidade do ctrc'
	   		DT2->(DbSetOrder(1))
			DT2->(DbSeek(xFilial("DT2")+GdFieldGet('DUA_CODOCO',nx))) //-- Toda ocorrência cadastrada será localizada.
			If DT2->DT2_TIPPND <> StrZero(2,Len(DT2->DT2_TIPPND)) .And. DT2->DT2_TIPPND <> StrZero(1,Len(DT2->DT2_TIPPND)) .And. DT2->DT2_TIPPND <> StrZero(3,Len(DT2->DT2_TIPPND)) //-- 'A quantidade menor será permitida apenas se o tipo de retorno for Avaria'
				Help('',1,'TMSA36091', , STR0029 + aDocs[nx,1]+'/'+aDocs[nx,2]+'/'+aDocs[nx,3] )
				lRet := .F.
			EndIf
			Exit
		EndIf
	Next nx
EndIf

//-- Verifica a existência de demanda
If lRet .And. nModulo == 43 //--TMS
	If lITmsDmd .And. FindFunction("TmsDmdXDoc")	//-- Integrado com demandas e existe a função que busca o vínculo com DT5
		aMsgErr := {}
		DT6->(DbSetOrder(1))
		DTA->(DbSetOrder(2))
		For nCntFor1 := 1 To Len(aCols)
			If !GdDeleted(nCntFor1)
				If DT6->(DbSeek(xFilial("DT6") + GdFieldGet("DUA_FILDOC",n) + GdFieldGet("DUA_DOC",n) + GdFieldGet("DUA_SERIE",n)))
					If !DTA->(DbSeek(xFilial("DTA") + M->(DUA_FILORI + DUA_VIAGEM) + DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)))	//-- Não foi informada a viagem correta
						If Len(TmsDmdXDoc(,,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,.F.)) > 0	//-- Busca o vínculo com DT5
							Aadd(aMsgErr,{DT6->DT6_FILDOC + "/" + DT6->DT6_DOC + "/" + DT6->DT6_SERIE + " - " + STR0127,"00",""})	//-- "Documento vinculado à demanda. A informação da viagem é obrigatória"
						EndIf
					EndIf
				EndIf
			EndIf
		Next nCntFor1
		If !Empty(aMsgErr)
			TmsMsgErr(aMsgErr)
			lRet := .F.
		EndIf
	EndIf
EndIf

//-- Analisa se todas os itens da GetDados estao deletados.
If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
	Help(' ', 1, 'OBRIGAT2') //Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
	lRet := .F.
EndIf

If lRet .And. lTM360TOK
	lRet := ExecBlock('TM360TOK',.F.,.F.,{nTmsOpcx})
	If	ValType(lRet) <> 'L'
		lRet := .F.
	EndIf
EndIf

If lRet .And. DT2->DT2_TIPPND == StrZero(3,Len(DT2->DT2_TIPPND)) .And. (M->DUA_QTDOCO <= 0)
	Help('',1,"OBRIGAT2",,RetTitle('DUA_QTDOCO'),04,01) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse
	lRet := .F.
EndIf

If Ascan(aCols,{ | e | e[GDFieldPos('DUA_CODOCO')] = cOcorCfe}) > 0 //AllTrim(M->DUA_CODOCO) == cOcorCfe
	DbSelectArea("DTQ")
	DbSetOrder(2)
	If DbSeek(xFilial("DTQ")+M->DUA_FILORI+M->DUA_VIAGEM)
		If DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))
		//-- Mesmo sendo ExecAuto, existe a confirmacao de embarque pelo TMSA320 a partir da R11.5
			DTV->(DbSetOrder(2))
			If DTV->(DbSeek(xFilial("DTV")+M->DUA_FILORI+M->DUA_VIAGEM))
				While DTV->(!EOF() .And. xFilial('DTV')+M->DUA_FILORI+M->DUA_VIAGEM == DTV->(DTV_FILIAL+DTV_FILORI+DTV_VIAGEM))

					//--verificacao da existencia de confirma~cao de embarque para o AWB					cAliasDVH := GetNextAlias()
					cAliasDVH := GetNextAlias()
					cQuery := " SELECT * "
					cQuery += "FROM " + RetSqlName("DVH")
					cQuery += " WHERE DVH_FILIAL = '" + xFilial('DVH') + "' "
					cQuery += "   AND DVH_FILORI = '" + DTV->DTV_FILORI + "' "
					cQuery += "   AND DVH_VIAGEM = '" + DTV->DTV_VIAGEM + "' "
					cQuery += "   AND DVH_NUMAWB = '" + DTV->DTV_NUMAWB + "' "
					cQuery += "   AND DVH_DIGAWB = '" + DTV->DTV_DIGAWB + "' "
					cQuery += "   AND D_E_L_E_T_ = ' ' "
					cQuery := ChangeQuery( cQuery )
					dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasDVH, .F., .T. )

					If (cAliasDVH)->(Eof())
						If !TA360ConfEmb(3)
							lCiaAerea := .F.
						EndIf
					EndIf
					(cAliasDVH)->(dbCloseArea())
					DTV->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
EndIf

//-- Rentabilidade/Ocorrencia -> Tratamento Campo ( Código Fornecedor )
//-- Quando Ocorrencia Integrada Ao GFE, o Código Do Fornecedor é Obrigatório
If DUA->(ColumnPos("DUA_CODFOR")) > 0

	//-- Verifica Todo aCols
	For nX := 1 To Len(aCols)

		//-- Não Valida Linhas Deletadas
		If GDdeleted(nX)
			Loop
		EndIf

		If Empty(GdFieldGet('DUA_CODFOR',nX))

			//-- Tabela De Ocorrencias
			DbSelectArea("DT2")
			DbSetOrder(1) //-- DT2_FILIAL+DT2_CODOCO
			If	DT2->(MsSeek(xFilial('DT2') + GdFieldGet('DUA_CODOCO',nX)))

				If 	DT2->DT2_TIPOCO == StrZero(17,Len(DT2->DT2_TIPOCO)) .Or. ;
						DT2->DT2_TIPOCO == StrZero(18,Len(DT2->DT2_TIPOCO))

					If DT2->(ColumnPos("DT2_CDTIPO")) > 0 .And. Empty(DT2->DT2_CDTIPO)
						Help('',1,"OBRIGAT2",,RetTitle('DUA_CODFOR') + STR0101 + Alltrim(Str(nX)),04,01) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf
		EndIf
	Next nX
EndIf

RestArea(aAreaDTA)

n:= nSavCols
Return( lRet )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA360Grv³ Autor ³ Antonio C F          ³ Data ³19.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravar dados                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA360Grv( cFilOco, cNumOco, cFilOri, cViagem, nTmsOpcx,; ³±±
±±³          ³ nBaseACols, aDocArm, aDocImp, aDocEnc, lDocEntre)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360Grv( cFilOco, cNumOco, cFilOri, cViagem, nTmsOpcx, nBaseACols, aDocArm, aDocImp, aDocEnc, lDocEntre, cNumRom,lExistCE)

Local ny,nz,nI
Local aAreaDUA	:= DUA->( GetArea() )
Local aAreaDUD  := {}
Local aAreaDF1  := {}
Local aDoc		:= {}
Local cFilDoc	:= ''
Local cDoc		:= ''
Local cSerie	:= ''
Local cSeek		:= ''
Local cSeekDUD  := ''
Local cFilVtr   := ''
Local cNumVtr   := ''
Local cSequen   := ''
Local cTipPnd   := ''
Local cSertms   := ''
Local cAtivChg  := GetMV('MV_ATIVCHG',,'')
Local nA	    := 0
Local nB	    := 0
Local nX	    := 0
Local nCntFor   := 0
Local nSeek     := 0
Local nQuant    := 0
Local aCampos   := {}
Local lVerBlq   := .F.
Local aDocInden := {}
Local nOpcInden := 0
Local lRet      := .T.
Local lSinc     := Iif(IsInCallStack(AllTrim('TMSA320')) .Or. IsInCallStack(AllTrim('TMSA350GRV')),.F.,TMSSinc())
Local lTmsCFec  := TmsCFec() //-- Carga Fechada
Local cNumAge   := ''
Local cFilDco   := ''
Local cDocDco   := ''
Local cSerDco   := ''
Local cFilVga	:= ''
Local cNumVga	:= ''
Local cItemDTR  := ''
Local dDatPre   := Ctod('')
Local cHorPre   := ''
Local cTotHor   := ''
Local dDatAux   := Ctod('')
Local cHorAux   := ''
Local dDatEmb   := Ctod('')
Local cHorPar   := ''
Local dDatChg   := Ctod('')
Local cHorChg   := ''
Local cNumVoo   := ''
Local aAreaDT6  := DT6->(GetArea())
Local lSobra    := .F.
Local nQtdOco   := 0
Local cTipOco   := ''
Local lEntrega  := .F.
Local aAreaDT2  := {}
Local nConta    := 0
Local cQuery    := ''
Local cAliasQry := ''
Local lTotal    := .F.
Local cTipSald  := StrZero(1,Len(DT2->DT2_TIPOCO)) + "/" + StrZero(6,Len(DT2->DT2_TIPOCO))
Local cCodOco   := ''
Local nQtdVol   := 0
Local aLoteAut  := {}
Local cFilDF0   := xFilial("DF0")
Local cFilDF1   := xFilial("DF1")
Local lIncOld   := Inclui
Local lAltOld   := Iif(type('Altera') == "A",Altera,.F.)
Local nCanViag  := SuperGetMv('MV_TMSCVIA',,0) //-- Opcoes para o param. MV_TMSCVIAG: 0-Nao Utiliza/1- Cancelar Viagem/2-Encerra/3- Pergunta
Local lUnitiz   := FindFunction('TmsChkVer') .And. TmsChkVer('11','R7')
Local lEndUnitiz:= IsInCallStack('DLGA015')//Endereça Unitizador Sse for chamado pelo DLGA015 (Manut.Unitiz.)
Local lDocRedes := .F.
Local aBotoes   := {}
Local nOpcAviso := 0
Local lDTCRee   := DTC->(ColumnPos("DTC_DOCREE")) > 0
Local cServic     := ""
Local lTMSOPdg    := AliasInDic('DEG') .And. SuperGetMV('MV_TMSOPDG',,'0') == '2' //-- Integracao com Operadoras de Frota
Local lEncRepom   := SuperGetMV('MV_ENREPOM',,"1")  //-- Encerra Repom pela Ocorrencia = 2 / Rotina de Encerramento = 1
Local aMsgErr     := {}
Local aNumVtr     := {}
Local lFrotaProp  := .F.
Local nPos        := 0
Local dDtEntr     := ''
Local cHrEntr     := ''
Local lTM360ITE   := ExistBlock('TM360ITE')
Local nPosDoc     := 0
Local lRetorna    := .F.
Local lBloqueio   := .F.
Local nOld        := 0
Local nTmsdInd    := SuperGetMv('MV_TMSDIND',.F.,0) // Dias permitidos para indenizacao apos o documento entregue
Local lMv_TmsPNDB := SuperGetMv("MV_TMSPNDB",.F.,.F.) //-- Permite informar a ocorrencia de Pendencia para um Docto Bloqueado
Local lBloqueado  := .F.
Local lDocRee 	  := SuperGetMV('MV_DOCREE',,.F.) .And. TMSChkVer('11','R7')
Local lGeraDUD	  := .T.
Local lFalta      := .F.
Local cNumNFDV4   := ""
Local cSerNFDV4   := ""
Local lAgdEntr     := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)   //-- Agendamento de Entrega.
Local nZZ         := 0
Local lTrab      := .F.
Local aInfDJI     := {}
Local cValCol     := "" //-- Composição Do Campo DDC_VALCOL/DDA_VALCOL
Local cDetalhe    := "" //-- Detalhes Bloqueio  - Rentabilidade/Ocorrência
Local cDocRD      := "" //-- Documento          - Rentabilidade/Ocorrência
Local cForRD      := "" //-- Cód. Fornecedor    - Rentabilidade/Ocorrência
Local cLojRD      := "" //-- Loja Forn.         - Rentabilidade/Ocorrência
Local cDesRD      := "" //-- Descr. Forn.       - Rentabilidade/Ocorrência
Local cChvRD      := "" //-- Chave De Busca DDU - Rentabilidade/Ocorrência
Local nValRec     := 0  //-- Valor Receita      - Rentabilidade/Ocorrência
Local nValDes     := 0  //-- Valor Despesa      - Rentabilidade/Ocorrência
Local lTMS3GFE    := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)  
Local lBlq029	  := .T.
Local lRetMer	  := .F. //--Pendência do Tipo Retirada de Mercadoria não prevista
Local lRotDUD     := Iif(FindFunction('TMSChvDUD'),.T.,.F.)
Local cEntAer	  := GetMv( 'MV_ENTAER',, '2' )
Local lITmsDmd    := SuperGetMv("MV_ITMSDMD",,.F.)
Local lColViaEnt  := .F.
Local lDUAPrzEnt  := DUA->(ColumnPos("DUA_PRZENT")) > 0
Local nLinha 	  := 0
Local cSeqOco	  := ""
Local lAjustaDUA  := .F.
Local aOcoEncPND  := {} //--Lista de Documentos que se repetem e que possui um apontamento do tipo 06-Pendencia
Local aColsPND    := {}
Local lWriteDLY   := .T.
Local lTMSIntChk  := SuperGetMV("MV_TMAPCKL",,.F.) .And. ExistFunc("TMSIntChk") .And. TMSDLZAti()
Local lCarAut 	  := .F.
Local lSeekDUB    := .F.
Local aAreaDM3    := {}
Local lEncerra    := .T.
Local lDM3Origem  := lViagem3 .And. DM3->(ColumnPos("DM3_ORIGEM")) > 0

Local lCarreg3    := FindFunction("TMSAF90") .And. AliasInDic("DM6")
Local aAreaDTQ    := DTQ->(GetArea())

Default aDocImp   := {}
Default aDocArm   := {}
Default aDocEnc   := {}
Default lDocEntre := .F.  //Documento Entregue
Default cNumRom   := ""
Default lExistCE  := .F.

If lEncViag == Nil
	lEncViag := SuperGetMv("MV_ENCVIAG",.F.,"2") == "1" //-- Define se devera encerrar a viagem com ocorrencia para todos documentos.
EndIf

Pergunte("TMSA141A",.F.)
If mv_par02 > 1 //Carregamento Automatico
	lCarAut := .T.
Endif

If lViagem3
	If DTQ->(ColumnPos("DTQ_CODAUT")) > 0
		If !Empty(M->DUA_VIAGEM) .And. DTQ->(DbSeek(xFilial("DTQ") + M->DUA_FILORI + M->DUA_VIAGEM))
			lCarAut := TMSA360Aut(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_CODAUT,"TMSAF90",lCarAut)
		EndIf
	EndIf
EndIf

If	nTmsOpcx == 3
	
	//--------------------------------------------------------------------------------------------------------
	//-- Coleta os documentos que possuem mais de um apontamento em que um deles é do tipo 06-Gera Pendência
	//-- Use o código abaixo para localizar os pontos relacionados com o controle abaixo
	//-- PNDXCMPENT-202001
	//--------------------------------------------------------------------------------------------------------
	aOcoEncPND := {}
	aColsPND   := aClone(aCols)
	nPosPND    := 1
	aAreaDT2   := DT2->(GetArea())
	For nCntFor := nBaseACols To Len( aColsPND )
		nPosPND := AScanX(aCols,{|x| x[GdFieldPos("DUA_DOC")] == GDFieldGet("DUA_DOC",nCntFor) },nCntFor+1)//,Len(aCols)-nPosPND)
		If nPosPND > 0
			DT2->( DbSetOrder( 1 ) )
			If DT2->(DbSeek( xFilial('DT2') + GDFieldGet('DUA_CODOCO', nPosPND))) .And. DT2->DT2_TIPOCO $ StrZero(6,Len(DT2->DT2_TIPOCO))
				AAdd(aOcoEncPND,{GDFieldGet('DUA_FILDOC',nPosPND), GDFieldGet('DUA_DOC',nPosPND), GDFieldGet('DUA_SERIE',nPosPND) })
			EndIf
		EndIf
	Next nCntFor
	RestArea(aAreaDT2)

	//-- Grava os dados.
	nCntFor := 1
	For nCntFor := nBaseACols To Len( aCols )

		If lPendente
			Exit
		EndIf
		
		If	GDDeleted( nCntFor )
			Loop
		EndIf
		nQtdOco := GDFieldGet('DUA_QTDOCO', nCntFor)
		nQtdVol := GDFieldGet('DUA_QTDVOL', nCntFor)
		DT2->( DbSetOrder( 1 ) )
		DT2->( DbSeek( xFilial('DT2') + GDFieldGet('DUA_CODOCO', nCntFor) ) )
		lSobra   := ( DT2->DT2_TIPOCO == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND == StrZero(3,Len(DT2->DT2_TIPPND)) ) //-- Sobra
		lBloqueio:= ( DT2->DT2_TIPOCO == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND == StrZero(99,Len(DT2->DT2_TIPPND)) ) //-- Bloqueio
		lFalta   := ( DT2->DT2_TIPOCO == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND == StrZero(1,Len(DT2->DT2_TIPPND)) ) //-- Falta
		cTipOco  := DT2->DT2_TIPOCO

		DFV->( DbSetOrder( 2 ) )	//-- Qdo existe doc de redespacho, a viagem pode ser encerrada normalmente.
		If DFV->( DbSeek( xFilial("DFV") + GDFieldGet('DUA_FILDOC', nCntFor) + ;
			GDFieldGet('DUA_DOC'   , nCntFor) + ;
			GDFieldGet('DUA_SERIE' , nCntFor) ) ) .And.;
			DFV->DFV_STATUS == StrZero( 1, Len( DFV->DFV_STATUS ) ) .And. cTipOco == StrZero( 1 , Len(DT2->DT2_TIPOCO) )
			Help('',1,'TMSA360A2') //-- 'Documento em poder do redespachante ','Tipo de ocorrência só é permitido para','documento "Indicado p/ Entrega"!.
			lRet	:= .F.
			Loop
		EndIf
		
		If (nRecursivo == 2) .And. lAjusta
			nLinha := aScan(aColsNew, {|x| x[8]+x[9]+x[10] == GDFieldGet('DUA_FILDOC', nCntFor)+GDFieldGet('DUA_DOC', nCntFor)+GDFieldGet('DUA_SERIE', nCntFor) })
			If nLinha > 0
				cSeqOco := aColsNew[nLinha][1]
				lAjustaDUA := .T.
			EndIf
		Else
			cSeqOco := GDFieldGet( 'DUA_SEQOCO', nCntFor )
		EndIf

		DUA->( DbSetOrder( 1 ) )
		If	DUA->( DbSeek( xFilial('DUA') + cFilOco + cNumOco + cFilOri + cViagem + cSeqOco, .F. ) ) .And. !lAjustaDUA
			RecLock('DUA', .F.)
		Else
			RecLock('DUA', .T.)
			DUA->DUA_FILIAL := xFilial('DUA')
			DUA->DUA_FILORI := cFilOri
			DUA->DUA_VIAGEM := cViagem
			DUA->DUA_FILOCO := cFilOco
			DUA->DUA_NUMOCO := cNumOco
			DUA->DUA_NUMROM := M->DUA_NUMROM

			cSerTMS := Posicione( 'DT2', 1, xFilial('DT2') + GDFieldGet( 'DUA_CODOCO', nCntFor ), 'DT2_SERTMS' )

			If Empty(cSerTMS)
				If !Empty(cFilOri) .And. !Empty(cViagem)
					DT6->( DbSetOrder( 1 ) )
					If DT6->( DbSeek( xFilial('DT6') + GDFieldGet( 'DUA_FILDOC', nCntFor ) + GDFieldGet( 'DUA_DOC', nCntFor ) + GDFieldGet( 'DUA_SERIE', nCntFor ) ) )
						cSerTms := DT6->DT6_SERTMS
					EndIf
				Endif
			Endif			
			DUA->DUA_SERTMS := cSerTMS
		EndIf

		For nA := 1 To Len(aHeader)
			If	aHeader[nA,10] != 'V'
				FieldPut(ColumnPos(aHeader[nA,2]), aCols[nCntFor,nA])
			EndIf
		Next

		MSMM(DUA->DUA_CODMOT,,,GDFieldGet( 'DUA_MOTIVO', nCntFor ),1,,,'DUA','DUA_CODMOT')
		
		If (nRecursivo == 2) .And. lAjusta
			DUA->DUA_SEQOCO := cSeqOco
		EndIf

		//Alimentar a viagem, caso ela esteja nula.
		If Empty(DUA->DUA_FILORI) .And. Empty(DUA->DUA_VIAGEM)
			lTrab := .T.
			cAliasQry := GetNextAlias()
		   	cQuery := " SELECT (MAX(R_E_C_N_O_)) R_E_C_N_O_"
			cQuery += "   FROM " + RetSqlName("DUD")
			cQuery += "  WHERE DUD_FILIAL = '" + xFilial('DUD') + "' "
			cQuery += "    AND DUD_FILDOC = '" + DUA->DUA_FILDOC + "' "
			cQuery += "    AND DUD_DOC    = '" + DUA->DUA_DOC + "' "
			cQuery += "    AND DUD_SERIE  = '" + DUA->DUA_SERIE + "' "
			cQuery += "    AND D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

		   If (cAliasQry)->R_E_C_N_O_ > 0
             aAreaDUD := DUD->( GetArea() )
             DUD->(dbGoto((cAliasQry)->R_E_C_N_O_))

             If !Empty(DUD->DUD_VIAGEM)
                DUA->DUA_FILORI := DUD->DUD_FILORI
                DUA->DUA_VIAGEM := DUD->DUD_VIAGEM
                //--- Tratamento nos casos em que o GFE nao retorna a Viagem. Necessario para o apontamento do REtorna Documento que nao gera o DUD
                If !Empty(DUD->DUD_CHVEXT) .And. Empty(cFilOri) .And. Empty(cViagem)
                	cFilOri:= DUD->DUD_FILORI
                	cViagem:= DUD->DUD_VIAGEM
                EndIf
             EndIf
		   EndIf
		EndIf

		MsUnLock()

		If !Empty(cAliasQry) .And. lTrab = .T.
			(cAliasQry)->( dbCloseArea() )
		EndIf

		lTrab := .F.

		cFilDoc := GDFieldGet('DUA_FILDOC', nCntFor)
		cDoc    := GDFieldGet('DUA_DOC'   , nCntFor)
		cSerie  := GDFieldGet('DUA_SERIE' , nCntFor)

		lVerBlq :=	( DT2->DT2_TIPOCO != StrZero( 7 ,Len( DT2->DT2_TIPOCO ) ) .And.;    	// Estorna Pendencia.
		DT2->DT2_TIPOCO != StrZero( 10,Len( DT2->DT2_TIPOCO ) ) )			  	// Estorna Indenizacao.

		TMSVerMov(cFilOri, cViagem, cFilDoc, cDoc, cSerie, (DT2->DT2_TIPOCO == StrZero( 3,Len(DT2->DT2_TIPOCO))), @aDoc, lVerBlq)

		If lSobra
			If Empty(aDoc)
				AAdd(aDoc, {cFilDoc,cDoc,cSerie,'','','','','','','',''})
			EndIf
		EndIf

		For nA := 1 To Len(aDoc)

			cFilDoc := aDoc[nA,1]
			cDoc    := aDoc[nA,2]
			cSerie  := aDoc[nA,3]
			lRet    := .T.

			If lDocRee .And. (DT2->DT2_TIPOCO == StrZero( 1,Len(DT2->DT2_TIPOCO)) .Or. DT2->DT2_TIPOCO == StrZero( 4,Len(DT2->DT2_TIPOCO)) .Or.;
			  (DT2->DT2_TIPOCO == StrZero( 6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND == StrZero(4,Len(DT2->DT2_TIPPND)))  )

				cAliasDT6 := GetNextAlias()  //-- localiza dados do documento original

				cQuery := " SELECT DT6.DT6_FILDCO, DT6.DT6_DOCDCO, DT6.DT6_SERDCO, DT6.DT6_FILVGA, DT6.DT6_NUMVGA "
				cQuery += " FROM " + RetSqlName("DT6") + " DT6, " + RetSqlName("DUA") + "  DUA "
				cQuery += " WHERE DT6_FILIAL   = '" + xFilial('DT6') + "' "
				cQuery += " AND DT6_FILDOC     = '" + cFilDoc + "' "
				cQuery += " AND DT6_DOC        = '" + cDoc    + "' "
				cQuery += " AND DT6_SERIE      = '" + cSerie  + "' "
				cQuery += " AND DUA_FILDOC     = DT6_FILDCO	 "
				cQuery += " AND DUA_DOC        = DT6_DOCDCO  "
				cQuery += " AND DUA_SERIE      = DT6_SERDCO  "
				cQuery += " AND DT6.D_E_L_E_T_ = ' ' "

				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasDT6, .F., .T. )

				If (cAliasDT6)->(!Eof())
					cFilDco   := (cAliasDT6)->DT6_FILDCO
					cDocDco   := (cAliasDT6)->DT6_DOCDCO
					cSerDco   := (cAliasDT6)->DT6_SERDCO
				EndIf

				(cAliasDT6)->(dbCloseArea())
				DUD->( DbSetOrder( 1 ) )
				If	DUD->( MsSeek( xFilial('DUD') + cFilDco + cDocDco + cSerDco ) )
				 	cFilVga	  := DUD->DUD_FILORI
					cNumVga	  := DUD->DUD_VIAGEM
				EndIf
			EndIf

			lDocRedes:= TMA360IDFV(cFilDoc, cDoc, cSerie, .F.,cFilOri, cViagem )

			If DT2->DT2_TIPOCO == StrZero( 4, Len( DT2->DT2_TIPOCO ) )  .And. (lDocRedes .Or. Iif(lRotDUD,TMSChvDUD(cFilDoc, cDoc, cSerie),.T.) )
				If DT2->DT2_TIPRDP == StrZero( 2, Len( DT2->DT2_TIPRDP ) )
					Loop
				EndIf
			EndIf

			//-- Verifica se a ocorrencia e' Gera Pendencia/Indenizacao para um documento ja entregue,
			//-- e neste caso, somente grava dados na DV4, sem atualizar saldo, bloqueios e novo DUD
			lDocEntre := .F.
			If nTmsdInd > 0
				lDocEntre:= TM360INDE(cFilDoc,cDoc,cSerie,DT2->DT2_TIPOCO,nTmsdInd)
			EndIf
			//-- 01 - Encerra Processo Ou
			//-- 21 - Entrega Trecho GFE ( Tratamento Rentabilidade/Ocorrencia )
			If	DT2->DT2_TIPOCO == StrZero( 1, Len( DT2->DT2_TIPOCO ) ) .Or. DT2->DT2_TIPOCO == StrZero( 21, Len( DT2->DT2_TIPOCO ) )

				DTQ->( DbSetOrder( 2 ) )
				If !Empty(cFilOri) .And. !Empty(cViagem) .and.;
					(lRet := DTQ->( DbSeek( xFilial('DTQ') + cFilOri + cViagem ) ))

					// Verifica se serviço da viagem
					cSerTms := DTQ->DTQ_SERTMS

				Else
					// Verifica serviço por documento
					DT6->( DbSetOrder( 1 ) )
					If  Empty(cSerTms) .AND. DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
						cSerTms := DT6->DT6_SERTMS
					Else
						// Serviço da Orcorrencia
						cSerTms := DT2->DT2_SERTMS
					EndIf
				EndIf

				If lRet
				    //Identifica se a ocorrencia foi apontada em uma coleta inclusa em uma viagem de entrega.
				    lColViaEnt := cSerTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .AND. DTQ->DTQ_SERADI == "1" .AND. !Empty(cViagem) .AND. cSerie = 'COL'

					//-- Viagem de coleta
					If cSerTMS == StrZero(1, Len(DTQ->DTQ_SERTMS)) .OR. lColViaEnt
						DUD->( DbSetOrder( 1 ) )
						If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilOri + cViagem ) )
							RecLock('DUD', .F. )
							DUD->DUD_STATUS := StrZero( 4, Len( DUD->DUD_STATUS ) )	// Encerrado
							MsUnLock()

							//-- Se coleta de doctos de coleta
							If DUD->DUD_SERTMS == StrZero( 1, Len( DUD->DUD_SERTMS ) )
								// Atualiza status da Solicitacao de Coleta
								DT5->( DbSetOrder( 4 ) )
								If	DT5->( DbSeek( xFilial('DT5') + cFilDoc + cDoc + cSerie ) )
									RecLock('DT5',.F.)
									DT5->DT5_STATUS := StrZero( 4, Len(DT5->DT5_STATUS) ) // Encerrada
									MsUnLock()
								EndIf

								DT6->( DbSetOrder( 1 ) )
								If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
									RecLock('DT6',.F.)
									DT6->DT6_STATUS := StrZero( 5, Len(DT6->DT6_STATUS) )  // Chegada Final
									MsUnLock()
								EndIf

								//-- Carga Fechada - Encerra item do Agendamento.
								If lTmsCFec
									If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc,cDoc,cSerie)
										If DTC->( ColumnPos("DTC_FILCFS") ) > 0  .And. !Empty(cFilDF0) .And. !Empty(cFilDF1)
											DTC->( DbSetOrder(3) )  // DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE
											If DTC->( DbSeek( xFilial("DTC") + cFilDoc + cDoc + cSerie ) )
												cFilDF1 := DTC->DTC_FILCFS
												cFilDF0 := DTC->DTC_FILCFS
											Else
												cFilDF1 := cFilDoc
												cFilDF0 := cFilDoc
											EndIf
										EndIf
									Else
										If DTC->( ColumnPos("DTC_FILCFS") ) > 0  .And. !Empty(cFilDF0) .And. !Empty(cFilDF1)
											DbSelectArea("DY4")
											DY4->( DbSetOrder(1) )  //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
											If DY4->( DbSeek( xFilial("DY4") + cFilDoc + cDoc + cSerie ) )
												DbSelectArea("DTC")
												DTC->( DbSetOrder(2) )  //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto + Fil.Ori + Lote
												If DTC->( DbSeek( xFilial("DTC") + DY4->DY4_NUMNFC + DY4->DY4_SERNFC + DY4->DY4_CLIREM + DY4->DY4_LOJREM + DY4->DY4_CODPRO ) )
													cFilDF1 := DTC->DTC_FILCFS
													cFilDF0 := DTC->DTC_FILCFS
												Endif
											Else
												cFilDF1 := cFilDoc
												cFilDF0 := cFilDoc
											EndIf
										EndIf
									Endif
									DF1->(DbSetOrder(3))
									If DF1->(DbSeek(xFilial('DF1',cFilDF1) + cFilDoc + cDoc + cSerie ) )
										RecLock("DF1",.F.)
										DF1->DF1_STACOL := StrZero(5,Len(DF1->DF1_STACOL)) //-- Encerrado
										MsUnLock()
									EndIf
									cNumAge := DF1->DF1_NUMAGE
									DF0->(DbSetOrder(1))
									If DF0->(DbSeek(cFilDF0+cNumAge)) .And. DF0->DF0_STATUS == StrZero(4,Len(DF0->DF0_STATUS)) //-- Encerrado
										RecLock("DF0",.F.)
										DF0->DF0_STATUS := TMSF05Stat(cFilDF0, cNumAge)
										MsUnlock()
									EndIf
								EndIf

							ElseIf DUD->DUD_SERTMS == StrZero( 3, Len( DUD->DUD_SERTMS ) ) .And. ;
								DUD->DUD_TIPTRA == StrZero( 2, Len( DUD->DUD_TIPTRA ) )

								//-- Se coleta de doctos de entrega aerea (Aeroporto)

								lErroNf := .F.
								DTC->( DbSetOrder(3) )  // DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE
								DTC->( DbSeek( cSeek := xFilial("DTC") + cFilDoc + cDoc + cSerie ) )
								Do While !DTC->(Eof()) .And. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) == cSeek
									//-- Gera nota fiscal de entrada.
									If ( lErroNf := !TMSGerNFEnt(3,.F.) )
										Exit
									EndIf
									DTC->(dbSkip())
								EndDo
								If lErroNf .And. !__TTSInUse
									DTC->( DbSetOrder(3) )  // DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE
									DTC->( DbSeek( cSeek := xFilial("DTC") + cFilDoc + cDoc + cSerie ) )
									Do While !DTC->(Eof()) .And. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) == cSeek
										//-- Estorna nota fiscal de entrada.
										TMSGerNFEnt(5,.F.)
										DTC->(dbSkip())
									EndDo
								EndIf

								If !lErroNf
									//-- Gerar um Novo DUD
									DbSelectArea("DUD")
									aAreaDUD := DUD->(GetArea())
									aCampos  := {}

									AAdd( aCampos, { 'DUD_ENDERE', If(cSerTms <> StrZero(1,Len(DTQ->DTQ_SERTMS)) .And. !TMSSldDist( cFilDoc, cDoc, cSerie ),"1","0") } )
									AAdd( aCampos, { 'DUD_SERTMS', StrZero( 3, Len( DUD->DUD_SERTMS ) ) } )
									AAdd( aCampos, { 'DUD_STATUS', StrZero( 1, Len( DUD->DUD_SERTMS ) ) } )
									AAdd( aCampos, { 'DUD_MANIFE', CriaVar('DUD_MANIFE', .F.) } )
									AAdd( aCampos, { 'DUD_SERMAN', CriaVar('DUD_SERMAN', .F.) } )
									AAdd( aCampos, { 'DUD_FILMAN', CriaVar('DUD_FILMAN', .F.) } )
									AAdd( aCampos, { 'DUD_VIAGEM', CriaVar('DUD_VIAGEM', .F.) } )
									AAdd( aCampos, { 'DUD_SEQUEN', CriaVar('DUD_SEQUEN', .F.) } )
									AAdd( aCampos, { 'DUD_FILATU', cFilAnt } )

									// Limpa campos de não previsto
									If DUD->(ColumnPos("DUD_DTRNPR")) > 0
										AAdd( aCampos, { 'DUD_DTRNPR',  CriaVar("DUD_DTRNPR", .F.) } )
										AAdd( aCampos, { 'DUD_HRRNPR',  CriaVar("DUD_HRRNPR", .F.) } )
										AAdd( aCampos, { 'DUD_USURNP',  CriaVar("DUD_USURNP", .F.) } )
										AAdd( aCampos, { 'DUD_NOMUSU',  CriaVar("DUD_NOMUSU", .F.) } )
									EndIf

									//-- Se a entrega do aereo for feita no rodoviario
									If cEntAer == '1'
										AAdd( aCampos, { 'DUD_TIPTRA', StrZero( 1, Len( DUD->DUD_TIPTRA ) ) } )
									EndIf

									TmsCopyReg( aCampos )
									RestArea(aAreaDUD)
								EndIf
							EndIf
						Else
							//-- Atualiza status da Solicitacao de Coleta sem Viagem Encerra processo
							DT5->( DbSetOrder( 4 ) )
							If	DT5->( DbSeek( xFilial('DT5') + cFilDoc + cDoc + cSerie ) ) .And. Empty(cViagem)
								RecLock('DT5',.F.)
								DT5->DT5_STATUS := StrZero( 4, Len(DT5->DT5_STATUS) ) //--Encerrada
								MsUnLock()
							EndIf
						EndIf

						//-- Atualiza Gestão de Demandas
						If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
							If cTipOco == '01' //só atualiza demanda se for ocorrência de encerramento.
								TmMontaDmd(DT6->DT6_DOCTMS,cFilDoc,cDoc,cSerie,"",.F.,DT2->DT2_TIPOCO,,.F.,.F.)
							Endif
						EndIf

                        DT6->(DbSetOrder(1))
                        If DT6->(DbSeek(xFilial('DT6') + cFilDoc + cDoc + cSerie))
                            RecLock('DT6',.F.)
                            Iif(DUA->DUA_QTDOCO > 0,DT6->DT6_QTDVOL := DUA->DUA_QTDOCO,)
                            Iif(DUA->DUA_PESOCO > 0,DT6->DT6_PESO   := DUA->DUA_PESOCO,)
                            Iif(DUA->DUA_PM3OCO > 0,DT6->DT6_PESOM3 := DUA->DUA_PM3OCO,)
                            Iif(DUA->DUA_MT3OCO > 0,DT6->DT6_METRO3 := DUA->DUA_MT3OCO,)
                            Iif(DUA->DUA_VLROCO > 0,DT6->DT6_VALMER := DUA->DUA_VLROCO,)
                            Iif(DUA->DUA_QTUOCO > 0,DT6->DT6_QTDUNI := DUA->DUA_QTUOCO,)
                            Iif(DUA->DUA_BASOCO > 0,DT6->DT6_BASSEG := DUA->DUA_BASOCO,)
                            Iif(Max(DUA->DUA_PESOCO,DUA->DUA_PM3OCO) > 0,DT6->DT6_PESCOB := Max(DUA->DUA_PESOCO,DUA->DUA_PM3OCO),)
                            MsUnLock()
                        EndIf

					ElseIf cSerTms == StrZero( 2, Len( DTQ->DTQ_SERTMS ) ) .Or. cSerTms == StrZero( 3, Len( DTQ->DTQ_SERTMS ) ) // Viagem de Transporte ou Entrega
						lRet   := TM360AtuSal(cFilDoc,cDoc,cSerie,nQtdOco, cTipOco , GdFieldGet("DUA_DATOCO",nCntFor) , l360Auto, cFilOri,cViagem, .F. , , aDocArm,,,cNumRom,lITmsDmd,"4")
						If !lRet .And. !lPendente // retornou falso porem cancelou a exclusao das operacoes
							AAdd(aDocImp,{STR0008 + cFilDoc+"/"+cDoc+"/"+cSerie + STR0034,,}) //"O documento xxxxxx/xxx nao possui mais saldo para ser atualiado
						Else
							TM360ATDC(nTmsOpcx,@aDocEnc,cFilDoc,cDoc,cSerie,DT2->DT2_TIPOCO,,.T.,,M->DUA_FILORI, M->DUA_VIAGEM, .F.,,GdFieldGet("DUA_CODOCO",nCntFor))
						EndIf
						If lRet .And. !Empty(cFilDco+cDocDco+cSerDco) .And. cFilDco+cDocDco+cSerDco != cFilDoc+cDoc+cSerie //-- Atualiza Documento original
					  		TM360AtuSal(cFilDco,cDocDco,cSerDco,nQtdOco, cTipOco , GdFieldGet("DUA_DATOCO",nCntFor) , l360Auto,cFilVga,cNumVga, .F. ,,aDocArm,,,,lITmsDmd,"4")
						EndIf
						// Atualiza o Status do Agendamento
						If lAgdEntr
							dbSelectArea("DYD")
							If !Empty( DYD->( IndexKey(2) ) ) // DYD_FILIAL + DYD_FILDOC + DYD_DOC + DYD_SERIE + DYD_NUMAGD
								DYD->( dbSetOrder(2))

								DYD->( dbSeek( FwxFilial("DYD")+ cFilDoc + cDoc + cSerie + REPLICATE("Z",TamSx3("DYD_NUMAGD")[1]),.T.))
								DYD->(dbSkip(-1))

								If DYD->DYD_STATUS != '6' .AND. DYD->DYD_FILDOC == cFilDoc .AND. DYD->DYD_DOC == cDoc .AND. DYD->DYD_SERIE  == cSerie
									dbSelectArea("DT6")
									DT6->( dbSetOrder(1) )
									If DT6->( dbSeek(FwxFilial("DT6")+ cFilDoc  + cDoc + cSerie ) )
										RecLock("DYD",.F.)
										DYD->DYD_STATUS :=  Iif((DT6->DT6_DATENT - DYD->DYD_DATAGD) > 0 .AND. DYD->DYD_TIPAGD != '4','3','2')
										MsUnlock()
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					//Encerra processo na Viagem Transf.
					If  DT2->DT2_TIPOCO == StrZero(1,Len(DT2->DT2_TIPOCO)) .And.;
						DT2->DT2_CATOCO == StrZero(1,Len(DT2->DT2_CATOCO)) //Encerra Processo / Por Docto

						DT6->( dbSetOrder(1) )
						If DT6->( dbSeek(FwxFilial("DT6")+ cFilDoc  + cDoc + cSerie ))
							RecLock('DT6',.F.)
							If DUA->DUA_QTDOCO != DT6->DT6_VOLORI .And.  DUA->DUA_QTDOCO != 0
								DT6->DT6_STATUS := StrZero(8, Len(DT6->DT6_STATUS)) //-- Entrega Parcial
							Else
								DT6->DT6_STATUS := StrZero(7,Len(DT6->DT6_STATUS))   // Encerrado
							EndIf
							MsUnLock()
						EndIf
						
						DUD->(DbSetOrder(1))
						If DUD->(DbSeek(cSeekDUD := xFilial('DUD')+cFilDoc  + cDoc + cSerie))
					 		Do While !DUD->(Eof()) .And. DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE) == cSeekDUD
					 			If ( Empty(DUD->DUD_VIAGEM) .And. (DUD->DUD_STATUS == StrZero(1, Len(DUD->DUD_STATUS)))) .Or. ;
					 			   (!Empty(DUD->DUD_VIAGEM) .And. (DUD->DUD_STATUS == StrZero(2, Len(DUD->DUD_STATUS))))
						 			RecLock('DUD', .F. )
									DUD->DUD_STATUS := StrZero( 4, Len( DUD->DUD_STATUS ) )	// Encerrado
									MsUnLock()
								EndIf
								DUD->(dbSkip())
						 		Loop
							EndDo
						EndIf

						//--- LS Metrica de Ocorrencia de Encerra Processo
						If lMetrica .And. DT2->DT2_TIPOCO == StrZero(1,Len(DT2->DT2_TIPOCO))
							TMSMet360(2,cFilDoc,cDoc,cSerie,nTmsOpcx) //Contador para Métrica por Encerra Processo
						EndIf

					EndIf
					// Atualiza status da Solicitacao de Coleta. Para o caso de Viagem com servico adicional
					DT5->( DbSetOrder( 4 ) )
					If	DT5->( DbSeek( xFilial('DT5') + cFilDoc + cDoc + cSerie ) )
						RecLock('DT5',.F.)
						DT5->DT5_STATUS := StrZero( 4, Len(DT5->DT5_STATUS) ) // Encerrada
						MsUnLock()

						//-- Atualiza Gestão de Demandas
						If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
							IF DT2->DT2_TIPOCO == '01' //só atualiza demanda se for ocorrência de encerramento.
								TmMontaDmd(DT6->DT6_DOCTMS,cFilDoc,cDoc,cSerie,"",.F.,DT2->DT2_TIPOCO,,.F.,.F.)
							Endif
						EndIf
					EndIf

				EndIf
    

				//-- 02 - Bloqueia Docto.
			ElseIf DT2->DT2_TIPOCO == StrZero( 2, Len( DT2->DT2_TIPOCO ) )
				lBloqueado:= .F.
				If lMv_TmsPNDB
					lBloqueado:= TM360BLOQ(cFilDoc, cDoc, cSerie)
				EndIf

				DT6->( DbSetOrder( 1 ) )
				If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
					RecLock('DT6',.F.)
					DT6->DT6_BLQDOC := StrZero( 1, Len( DT6->DT6_BLQDOC ) )								  	//-- Sim
					MsUnLock()
				EndIf

				//-- Atualiza Gestão de Demandas
				If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
					TmMontaDmd(DT6->DT6_DOCTMS,cFilDoc,cDoc,cSerie,STR0114 + DToC(dDataBase) + " " + Left(Time(),5) + STR0116 + DUA->DUA_FILDOC + "-" + ;
								DUA->DUA_DOC + "/" + DUA->DUA_SERIE + STR0113,.F.,DT2->DT2_TIPOCO,,.F.,.F.)	//-- Bloqueada ## "Demanda bloqueada em " ## " por conta de bloqueio do documento " ## " do TMS"
				EndIf

				//-- 03 - Libera documento
			ElseIf DT2->DT2_TIPOCO == StrZero( 3, Len( DT2->DT2_TIPOCO ) )
				lBloqueado:= .F.
				If lMv_TmsPNDB
					lBloqueado:= TM360BLOQ(cFilDoc, cDoc, cSerie, cFilOco, cNumOco)
					//-- Se existe a pendencia em aberto, o Documento deve permanecer Bloqueado
					If lBloqueado
						lBloqueado:= .F.
						DUU->( DbSetOrder(3))
						If DUU->( DbSeek(cSeek := xFilial('DUU')+cFilDoc+cDoc+cSerie,.F.))
							Do While DUU->( cSeek == DUU_FILIAL+DUU_FILDOC+DUU_DOC+DUU_SERIE )
								If DUU->DUU_STATUS == StrZero(1,Len( DUU->DUU_STATUS )) .And. DUU->(DUU_FILORI+DUU_VIAGEM) == M->DUA_FILORI+M->DUA_VIAGEM
									lBloqueado:= .T.
									Exit
								EndIf
								DUU->( DbSkip() )
							EndDo
						EndIf
					EndIf
				EndIf

				DT6->( DbSetOrder( 1 ) )
				If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
					If !lBloqueado
						RecLock('DT6',.F.)
						DT6->DT6_BLQDOC := StrZero( 2, Len( DT6->DT6_BLQDOC ) )									//-- Nao
						MsUnLock()
					EndIf
				EndIf

				//-- Atualiza Gestão de Demandas
				If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
					TmMontaDmd(DT6->DT6_DOCTMS,cFilDoc,cDoc,cSerie,STR0115 + DToC(dDataBase) + " " + Left(Time(),5) + STR0117 + DUA->DUA_FILDOC + "-" + ;
								DUA->DUA_DOC + "/" + DUA->DUA_SERIE + STR0113,.F.,DT2->DT2_TIPOCO,,.F.,.F.)	//-- Planejada ## "Liberação de demanda em " ## " por conta de liberação do documento " ## " do TMS"
				EndIf

				//-- Caso a viagem ja tenha chegado na filial, executar tmsmovviag para gerar movimento na filial.
				DTW->( DbSetOrder( 4 ) )
				DUD->( DbSetOrder( 1 ) )
				If	DTW->( DbSeek( xFilial('DTW') + cFilOri + cViagem + cAtivChg + cFilAnt) ) .And.; //-- Existir a Operacao de chegada
					DTW->DTW_STATUS==StrZero(2,Len(DTW->DTW_STATUS)) .And.;		//-- Estar apontada a opracao de chegada.
					DUD->( !DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt ) )
					TMSMovViag( cFilOri, cViagem, cAtivChg, aDoc, nA, 3 ) //-- Inclui movto viagem e estoque
				EndIf

			//-- 04 - Retorno de Docto
			ElseIf DT2->DT2_TIPOCO == StrZero( 4, Len( DT2->DT2_TIPOCO ) )

				DTQ->( DbSetOrder( 2 ) )
				DTQ->( DbSeek( xFilial('DTQ') + cFilOri + cViagem ) )

				//- Quando nao tem viagem estava posicionando em DUD ja cancelado, ao gerar um novo tinhas 2 DUD em aberto.
				cAliasQry := GetNextAlias()
				cQuery := " SELECT MAX(R_E_C_N_O_) REC"
				cQuery += " FROM " + RetSqlName("DUD")
				cQuery += " WHERE DUD_FILIAL='" + xFilial("DUD") + "'"
				cQuery += "   AND DUD_FILDOC='" + cFilDoc + "'"
				cQuery += "   AND DUD_DOC   ='" + cDoc    + "'"
				cQuery += "   AND DUD_SERIE ='" + cSerie  + "'"
				If !EmPty(cFilOri)
					cQuery += "   AND DUD_FILORI='" + cFilOri + "'"
					cQuery += "   AND DUD_VIAGEM='" + cViagem + "'"
				Else
					cQuery += "   AND DUD_FILORI='" + cFilAnt + "'"
					cQuery += "   AND DUD_VIAGEM='" + Space(Len(DUD->DUD_VIAGEM)) + "'"
				EndIf
				cQuery += "   AND D_E_L_E_T_ = ' ' "

    			cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				If (cAliasQry)->(!Eof()) .And. (cAliasQry)->REC > 0
					DUD->( DbGoto( (cAliasQry)->REC ) )
					(cAliasQry)->( dbCloseArea() )

					lErroNf := .F.

					If DTQ->DTQ_SERTMS == StrZero( 3, Len( DTQ->DTQ_SERTMS ) ) .Or.; //-- Entrega
						( !Empty( DUD->DUD_NUMRED ))
						If Empty( DUD->DUD_DOCBXE )
							If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc,cDoc,cSerie)
								DTC->( DbSetOrder(3) )  // DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE
								DTC->( DbSeek( cSeek := xFilial("DTC") + cFilDoc + cDoc + cSerie ) )
								Do While !DTC->(Eof()) .And. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) == cSeek
									//-- Gera nota fiscal de entrada.
									If ( lErroNf := !TMSGerNFEnt(3,.F.) )
										Exit
									EndIf
									DUH->(DbSeek(xFilial("DUH")+ cFilAnt +DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM))
									Do While !DUH->(Eof()) .And. xFilial("DUH")+DUH->DUH_FILORI+DUH->DUH_NUMNFC+DUH->DUH_SERNFC+DUH->DUH_CLIREM+DUH->DUH_LOJREM == ;
											DTC->DTC_FILIAL+ cFilAnt +DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM
										RecLock("DUH",.F.)
										DUH->DUH_STATUS := StrZero(1, Len(DUH->DUH_STATUS)) // Em Aberto
										MsUnLock()
										DUH->(dbSkip())
									EndDo
									DTC->(dbSkip())
								EndDo
							Else
								DbSelectArea("DY4")
								DbSetOrder(1) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
								DY4->( DbSeek( cSeek := xFilial("DY4") + cFilDoc + cDoc + cSerie ) )
								Do While !DY4->(Eof()) .And. DY4->(DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE) == cSeek
									//-- Gera nota fiscal de entrada.
									If ( lErroNf := !TMSGerNFEnt(3,.F.) )
										Exit
									EndIf
									DUH->(DbSeek(xFilial("DUH")+ cFilAnt +DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM))
									Do While !DUH->(Eof()) .And. xFilial("DUH")+DUH->DUH_FILORI+DUH->DUH_NUMNFC+DUH->DUH_SERNFC+DUH->DUH_CLIREM+DUH->DUH_LOJREM == ;
											DY4->DY4_FILIAL+ cFilAnt +DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM
										RecLock("DUH",.F.)
										DUH->DUH_STATUS := StrZero(1, Len(DUH->DUH_STATUS)) // Em Aberto
										MsUnLock()
										DUH->(dbSkip())
									EndDo
									DY4->(dbSkip())
								EndDo
							Endif
							If lErroNf .And. !__TTSInUse
								If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc,cDoc,cSerie)
									DTC->( DbSetOrder(3) )  // DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE
									DTC->( DbSeek( cSeek := xFilial("DTC") + cFilDoc + cDoc + cSerie ) )
									Do While !DTC->(Eof()) .And. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) == cSeek
										//-- Estorna nota fiscal de entrada.
										TMSGerNFEnt(5,.F.)
										DTC->(dbSkip())
									EndDo
								Else
									DbSelectArea("DY4")
									DbSetOrder(1) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
									DY4->( DbSeek( cSeek := xFilial("DY4") + cFilDoc + cDoc + cSerie ) )
									Do While !DY4->(Eof()) .And. DY4->(DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE) == cSeek
										//-- Estorna nota fiscal de entrada.
										TMSGerNFEnt(5,.F.,cFilDoc,cDoc,cSerie)
										DY4->(dbSkip())
									EndDo
								Endif
							EndIf
						Else
							//-- Cancela baixa do estoque dos documentos.
							TmsDelBxEst( cFilOri, cViagem, cFilDoc, cDoc, cSerie )
						EndIf
					EndIf

					If !lErroNf
						lGeraDuD := .T.
						// Atualiza status da documento
						If DTQ->DTQ_SERTMS == StrZero( 1, Len( DTQ->DTQ_SERTMS ) )
							DT5->( DbSetOrder( 4 ) )
							If	DT5->( DbSeek( xFilial('DT5') + cFilDoc + cDoc + cSerie ) )
								RecLock('DT5',.F.)
								DT5->DT5_STATUS := StrZero( 1, Len(DT5->DT5_STATUS) ) // Em Aberto
								MsUnLock()
							EndIf
						ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) // Viagem Entrega
							DT6->( DbSetOrder( 1 ) )
							If DT6->( DbSeek( xFilial("DT6") + cFilDoc + cDoc + cSerie ) )
								RecLock("DT6",.F.)
								If DT6->DT6_SERTMS == StrZero(2,Len(DT6->DT6_SERTMS)) //-- Transporte
									DT6->DT6_STATUS := StrZero(5,Len(DT6->DT6_STATUS)) //-- Chegada Final
								ElseIf DUA->DUA_QTDOCO == DT6->DT6_VOLORI .And. lDocRee .And. (DT6->DT6_DOCTMS == StrZero(7,Len(DT6->DT6_DOCTMS)) .Or. DT6->DT6_DOCTMS == Replicate('D', Len( DT6->DT6_DOCTMS ) ))
							   		DT6->DT6_STATUS := PadR('A',len(DT6->DT6_STATUS))  //-- Retorno Total
							   		lGeraDUD := .F.
							 	ElseIf DUA->DUA_QTDOCO != DT6->DT6_VOLORI .And.  DUA->DUA_QTDOCO != 0 .And. lDocRee
							   		DT6->DT6_STATUS := StrZero(8,Len(DT6->DT6_STATUS))  //-- Entrega Parcial
							   		lGeraDUD := .F.
								Else
									DT6->DT6_STATUS := StrZero(1,Len(DT6->DT6_STATUS))
								EndIf
								MsUnLock()
							EndIf
						ElseIf DFV->( DbSeek( xFilial('DFV') + cFilDoc + cDoc + cSerie ))  //-- Documento de Redespacho.
							DT6->( DbSetOrder( 1 ) )
							If DT6->( DbSeek( xFilial("DT6") + cFilDoc + cDoc + cSerie ) )
								RecLock("DT6",.F.)
								DT6->DT6_STATUS := StrZero(1,Len(DT6->DT6_STATUS))	//-- Em Aberto,
								MsUnLock()
							EndIf
						EndIf

						//-- Atualiza Gestão de Demandas
						If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
							TmMontaDmd(Iif(cSerie == "COL","1","2"),DUA->DUA_FILDOC,DUA->DUA_DOC,DUA->DUA_SERIE,,.F.,DT2->DT2_TIPOCO,,.F.,.F.)
						EndIf

					   	//-- Alterar o Status do Documento para "9" (Cancelado)
						RecLock("DUD",.F.)
						DUD->DUD_STATUS := StrZero(9, Len(DUD->DUD_STATUS))
						DUD->(MsUnLock())

					  	If lGeraDUD
							//-- Gerar um Novo DUD
							aAreaDUD := DUD->(GetArea())
						   	aCampos  := {}

							//-- Se for retorno de uma entrega aerea, retorna para um movto. rodoviario
						  	If DUD->DUD_SERTMS == StrZero( 3, Len( DUD->DUD_SERTMS ) ) .And. ;
								DUD->DUD_TIPTRA == StrZero( 2, Len( DUD->DUD_TIPTRA ) ) .And. ;
								cEntAer == '1'
								AAdd( aCampos, { 'DUD_TIPTRA', StrZero( 1, Len( DUD->DUD_TIPTRA ) ) } )
							EndIf

							AAdd( aCampos, { 'DUD_ENDERE', If(DTQ->DTQ_SERTMS<>StrZero(1,Len(DTQ->DTQ_SERTMS)) .And. !TMSSldDist( cFilDoc, cDoc, cSerie ),"1","0") } )
							AAdd( aCampos, { 'DUD_STATUS', StrZero( 1, Len( DUD->DUD_SERTMS ) ) } )
							AAdd( aCampos, { 'DUD_MANIFE', CriaVar('DUD_MANIFE', .F.) } )
							AAdd( aCampos, { 'DUD_SERMAN', CriaVar('DUD_SERMAN', .F.) } )
							AAdd( aCampos, { 'DUD_FILMAN', CriaVar('DUD_FILMAN', .F.) } )
							AAdd( aCampos, { 'DUD_FILORI', cFilAnt } )
							AAdd( aCampos, { 'DUD_VIAGEM', CriaVar('DUD_VIAGEM', .F.) } )
							AAdd( aCampos, { 'DUD_SEQUEN', CriaVar('DUD_SEQUEN', .F.) } )
							AAdd( aCampos, { 'DUD_FILATU', cFilAnt } )
							AAdd( aCampos, { 'DUD_NUMROM', "" } )
							AAdd( aCampos, { 'DUD_NUMRED', CriaVar('DUD_NUMRED', .F.) } )

							// Limpa campos de não previsto
							If DUD->(ColumnPos("DUD_DTRNPR")) > 0
								AAdd( aCampos, { 'DUD_DTRNPR',  CriaVar("DUD_DTRNPR", .F.) } )
								AAdd( aCampos, { 'DUD_HRRNPR',  CriaVar("DUD_HRRNPR", .F.) } )
								AAdd( aCampos, { 'DUD_USURNP',  CriaVar("DUD_USURNP", .F.) } )
								AAdd( aCampos, { 'DUD_NOMUSU',  CriaVar("DUD_NOMUSU", .F.) } )
							EndIf


							If lTMS3GFE .Or. lTmsRdpU
								AAdd( aCampos, { 'DUD_UFORI' , CriaVar('DUD_UFORI' , .F.) } )
								AAdd( aCampos, { 'DUD_CDMUNO', CriaVar('DUD_CDMUNO', .F.) } )
								AAdd( aCampos, { 'DUD_CEPORI', CriaVar('DUD_CEPORI', .F.) } )
								AAdd( aCampos, { 'DUD_UFDES' , CriaVar('DUD_UFDES' , .F.) } )
								AAdd( aCampos, { 'DUD_CDMUND', CriaVar('DUD_CDMUND', .F.) } )
								AAdd( aCampos, { 'DUD_CEPDES', CriaVar('DUD_CEPDES', .F.) } )
								AAdd( aCampos, { 'DUD_TIPVEI', CriaVar('DUD_TIPVEI', .F.) } )
								AAdd( aCampos, { 'DUD_CDCLFR', CriaVar('DUD_CDCLFR', .F.) } )
								AAdd( aCampos, { 'DUD_CHVEXT', CriaVar('DUD_CHVEXT', .F.) } )
							EndIf

							TmsCopyReg( aCampos )
							RestArea(aAreaDUD)
						EndIf
					EndIf
				EndIf

				//Atualiza campo DTC_DOCREE
				If !Empty(DT6->DT6_FILDCO) .AND. !Empty(DT6->DT6_DOCDCO) //verifica se eh doc de reentrega/devolucao
					If FindFunction("TmsPsqDY4") .And. TmsPsqDY4( DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE ) .AND. lDTCRee
						A360AtuRee(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,.T./*Nao eh Estorno da ocorrencia de retorno*/)
					Endif
					If DT6->DT6_STATUS == PadR('A',len(DT6->DT6_STATUS)) .And. (DT6->DT6_DOCTMS == StrZero(7,Len(DT6->DT6_DOCTMS)) .Or. DT6->DT6_DOCTMS == Replicate('D', Len( DT6->DT6_DOCTMS ))).And. !DT6->DT6_STATUS $ "B/C/D"	//-- B- Cancelamento SEFAZ Aguardando, C- Cancelamento SEFAZ Autorizado, D- Cancelamento SEFAZ nao autorizado
						//--- Desmarca a Nota Fiscal para uso em uma próxima Reentrega DTC_DOCREE
						TMSA500DREE(cFilDco,cDocDco,cSerDco)
				   EndIf
				EndIf
			
				If lDUAPrzEnt  .And. !Empty(GDFieldGet( 'DUA_PRZENT', nCntFor )) 
					A360BlqDDU(cNumOco,GDFieldGet( 'DUA_SEQOCO', nCntFor ),Iif(!Empty(cFilOri),cFilOri,DUA->DUA_FILORI), Iif(!Empty(cViagem),cViagem,DUA->DUA_VIAGEM),cFilDoc,cDoc,cSerie,GDFieldGet( 'DUA_PRZENT', nCntFor ))
				EndIf	

			//-- 05 - Informativa
			ElseIf DT2->DT2_TIPOCO == StrZero( 5, Len( DT2->DT2_TIPOCO ) ) .And. (!lSinc .Or. lAjusta)

				//-- Verifica se foi informado Confirmacao de Embarque Aereo
				If Len(aDadosDVH) > 0

					For nX := 1 To Len(aDadosDVH)
						RecLock('DVH', .T.)
						For nB := 1 To FCount()
							cCampo := FieldName(nB)
							If "FILIAL"$Field(nB)
								FieldPut(nB,xFilial("DVH"))
							Else
								nSeek := Ascan(aDadosDVH[nX,1], {|x| x[1] == cCampo})
								If nSeek > 0
									FieldPut(nB,aDadosDVH[nX][1][nSeek][2])
								EndIf
							EndIf
						Next nB
					MsUnLock()
					//-- Armazena data de embarque para atualizar documento
					dDatEmb := DVH->DVH_DATPAR
					cHorPar := DVH->DVH_HORPAR
					dDatChg := DVH->DVH_DATCHG
					cHorChg := DVH->DVH_HORCHG
					cNumVoo := DVH->DVH_NUMVOO

					TMSA360Pre(3,cFilOco,cNumOco,cFilOri,cViagem,dDatEmb,cHorPar,dDatChg,cHorChg,cNumVoo,DVH->DVH_NUMAWB,DVH->DVH_DIGAWB)

					Next nX
				//-- Verifica se foi informado Confirmacao de Embarque Fluvial
				ElseIf Len(aDadosDW4) > 0
					DW4->( DbSetOrder( 1 ) )
					If	DW4->( DbSeek( xFilial('DW4') + cFilOri + cViagem + cFilOco + cNumOco ) )
						RecLock('DW4', .F.)
					Else
						RecLock('DW4', .T.)
					EndIf
					For nB := 1 To FCount()
						cCampo := FieldName(nB)
						If "FILIAL"$Field(nB)
							FieldPut(nB,xFilial("DW4"))
						Else
							nSeek := Ascan(aDadosDW4, {|x| x[1] == cCampo})
							If nSeek > 0
								FieldPut(nB,aDadosDW4[nSeek][2])
							EndIf
						EndIf
					Next nB
					MsUnLock()
					//-- Armazena data de embarque para atualizar documento
					dDatEmb := DW4->DW4_DATSAI
					dDatChg := DW4->DW4_DATCHG
					cHorChg := DW4->DW4_HORCHG
				EndIf
				If !Empty(dDatChg)
					//-- Atualizar a Data/Hora Prevista de Chegada de Viagem na Proxima Filial
					DTW->(DbSetOrder(3))
					If	DTW->(DbSeek(cSeek := xFilial('DTW')+cFilOri+cViagem+StrZero(1,Len(DTW->DTW_STATUS))))
						dDatPre := Ctod('')
						While DTW->(!Eof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_STATUS) == cSeek
							If AllTrim(DTW->DTW_ATIVID) == cAtivChg
								dDatAux := DTW->DTW_DATPRE
								cHorAux := DTW->DTW_HORPRE
								dDatPre := dDatChg
								cHorPre := Transform(cHorChg,"@R 99:99")
								RecLock('DTW',.F.)
								DTW->DTW_DATPRE := dDatPre
								DTW->DTW_HORPRE := StrTran(cHorPre,':','')
								MsUnLock()
							ElseIf !Empty(dDatPre)
								cTotHor := Right(Transform(TmsTotHora(dDatAux,cHorAux,DTW->DTW_DATPRE,DTW->DTW_HORPRE),"@R 999:99"),5)
								dDatAux := DTW->DTW_DATPRE
								cHorAux := DTW->DTW_HORPRE
								//-- Calcula a data e hora prevista
								SomaDiaHor(@dDatPre,@cHorPre,HoraToInt(cTotHor,2))
								RecLock('DTW',.F.)
								DTW->DTW_DATPRE := dDatPre
								DTW->DTW_HORPRE := StrTran(cHorPre,':','')
								MsUnLock()
							EndIf
							DTW->(dbSkip())
						EndDo
						//-- Atualiza Complemento de Viagem
						DTR->(DbSetOrder(1))
						DTR->(DbSeek(xFilial("DTR")+cFilOri+cViagem+"z",.T.))
						DTR->(dbSkip(-1))
						If DTR->(!Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == xFilial("DTR")+cFilOri+cViagem
							cItemDTR := Soma1(DTR->DTR_ITEM)
							DTR->(DbSetOrder(3))
							If DTR->(DbSeek(xFilial("DTR")+cFilOri+cViagem+DW4->DW4_CODVEI))
								RecLock("DTR",.F.)
								RegToMemory("DTR",.F.)
							Else
								RecLock("DTR",.T.)
								RegToMemory("DTR",.T.)
								M->DTR_FILORI := cFilOri
								M->DTR_VIAGEM := cViagem
								M->DTR_ITEM   := cItemDTR
								M->DTR_CODVEI := DW4->DW4_CODVEI
							EndIf
							M->DTR_CODRB1 := DW4->DW4_CODRB1
							M->DTR_DATINI := DW4->DW4_DATSAI
							M->DTR_HORINI := DW4->DW4_HORSAI
							M->DTR_DATFIM := DW4->DW4_DATCHG
							M->DTR_HORFIM := DW4->DW4_HORCHG
							Aeval( dbStruct(), { |aFieldName, nI | FieldPut( nI, If('FILIAL' $ aFieldName[1],xFilial("DTR"),M->&(aFieldName[1]) ) ) } )
							MsUnLock()

							//---- Atualiza Tabela de Planejamento da Viagem Modelo 3
							If TableInDic("DM4")
								DM4->(DbSetOrder(1))
								If DM4->(DbSeek(xFilial("DM4")+cFilOri+cViagem))
									RecLock("DM4",.F.)
								Else	
									RecLock("DM4",.T.)
									DM4->DM4_FILIAL := xFilial("DM4")
									DM4->DM4_FILORI := cFilOri
								    DM4->DM4_VIAGEM := cViagem									
								EndIf
								DM4->DM4_DATINI := DW4->DW4_DATSAI
								DM4->DM4_HORINI := DW4->DW4_HORSAI
								DM4->DM4_DATFIM := DW4->DW4_DATCHG
								DM4->DM4_HORFIM := DW4->DW4_HORCHG
								DM4->(MsUnLock())
							EndIf

						EndIf

					EndIf
				EndIf

				//-- Atualiza data de embarque do documento
				If !Empty(dDatEmb)
					//-- Limpa Array para nao atualizar a viagem novamente
					aDadosDW4 := {}
					aDadosDVH := {}
					dDatChg   := Ctod("")
					DT6->(DbSetOrder(1))
					If DT6->(DbSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
						RecLock("DT6",.F.)
						DT6->DT6_ULTEMB := dDatEmb
						MsUnLock()
					EndIf
				EndIf

				If lDUAPrzEnt .And. !Empty(GDFieldGet( 'DUA_PRZENT', nCntFor )) 
					A360BlqDDU(cNumOco,GDFieldGet( 'DUA_SEQOCO', nCntFor ),Iif(!Empty(cFilOri),cFilOri,DUA->DUA_FILORI), Iif(!Empty(cViagem),cViagem,DUA->DUA_VIAGEM),cFilDoc,cDoc,cSerie,GDFieldGet( 'DUA_PRZENT', nCntFor ))
				EndIf	

				//-- 06 - Gera pendencia
			ElseIf DT2->DT2_TIPOCO == StrZero( 6, Len( DT2->DT2_TIPOCO ) )
				lDocRedes  := TMA360IDFV( cFilDoc,cDoc,cSerie,.F.,cFilOri,cViagem )

				lRetMer :=  DT2->DT2_TIPPND == StrZero(5,TamSx3('DT2_TIPPND')[1])
				//Caso seja ocorrencia de Sobra, verifica se os campos abaixo estão preenchidos, caso nao estejam, sera gerada pendecia sem documento informado.
				If DT2->DT2_TIPPND == StrZero( 3, Len( DT2->DT2_TIPOCO ) ) .And. Empty(GdFieldGet("DUA_FILDOC",nCntFor)) .And.;
				 Empty(GdFieldGet("DUA_DOC",nCntFor)) .And. Empty(GdFieldGet("DUA_SERIE",nCntFor))
					cFilDoc := ''
					cDoc 	:= ''
					cSerie 	:= ''
				EndIf
				If !lDocEntre
					lRet   := TM360AtuSal(cFilDoc,cDoc,cSerie,nQtdOco, cTipOco , GdFieldGet("DUA_DATOCO",nCntFor) , l360Auto, cFilOri,cViagem, .F. , ,aDocArm,nTmsOpcx )
					If lRet .And. lDocRee .And. !Empty(cFilDco) .And. !Empty(cDocDco) .And. !Empty(cSerDco)
			   			TM360AtuSal(cFilDco,cDocDco,cSerDco,nQtdOco,cTipOco,GdFieldGet("DUA_DATOCO",nCntFor),l360Auto,cFilVga,cNumVga, .F. , ,aDocArm,nTmsOpcx )
					EndIf
					If !lRet
						AAdd(aDocImp,{STR0008 + cFilDoc+"/"+cDoc+"/"+cSerie + STR0034,,}) //"O documento xxxxxx/xxx nao possui mais saldo para ser atualiado
					EndIf
				EndIf

				// Verificar se o registro de pendencia lancado possui servico atrelado a uma tabela de seguros
				// nao pode gera registro de indenizacao sem uma tabela de seguros configurada
				If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)

					DT6->( DbSetOrder( 1 ) )
					If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
						cServic := Posicione("DC5",1,xFilial("DC5")+DT6->DT6_SERVIC,"DC5_TABSEG")
						If Empty(cServic)
							MsgAlert(STR0048) // "Tabela de Seguros nao informada no tipo de Servico x Tarefa"
							lRet := .F.
						EndIf
					EndIf
				EndIf

				If lRet
					nPosDoc:= Ascan(aDocEnc,{|x| x[1]==cFilDoc+cDoc+cSerie})
					If DT2->DT2_TIPPND $ "01/02/04"
						TM360ATDC(nTmsOpcx,@aDocEnc,cFilDoc,cDoc,cSerie,DT2->DT2_TIPOCO,DT2->DT2_TIPPND,.T.,nCntFor,M->DUA_FILORI,M->DUA_VIAGEM,@lRetorna,,GdFieldGet("DUA_CODOCO",nCntFor))

						// Se for ocorrência tipo gera pendência(06) e tipo de pendência for 04(Retorna Documento)
						// o status do documento deve ser "Chegada em Filial"

						If lRetorna .And. DT2->DT2_TIPOCO=="06" .And. DT2->DT2_TIPPND=="04" .And.  (DT2->DT2_SERTMS=="3" .OR. ( Empty(DT2->DT2_SERTMS) .AND. DTQ->DTQ_SERTMS == "3") ) .And. DT6->DT6_SERTMS=="2" .And. !lDocEntre
							DT6->( DbSetOrder( 1 ) )
								If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
									RecLock('DT6',.F.)
									DT6->DT6_STATUS := StrZero(5,Len(DT6->DT6_STATUS)) //-- Chegada em Filial
									MsUnLock()
								EndIf
						ElseIf !lRetorna .And. DT2->DT2_TIPOCO == '06' .And. DT2->DT2_TIPPND == "04" .And. !lDocEntre .And. !lTotal
							DT6->( DbSetOrder( 1 ) )
							If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
								RecLock('DT6',.F.)
								DT6->DT6_STATUS := StrZero(1,Len(DT6->DT6_STATUS)) //-- Em Aberto
								MsUnLock()
							EndIf
						EndIf
					EndIf
					//-- Se nao existir pendencia registrada para o documento.
					DUU->( DbSetOrder( 3 ) )
					If	lSobra .Or. ( DUU->( ! DbSeek( xFilial('DUU') + cFilDoc + cDoc + cSerie + StrZero( 1, Len( DUU->DUU_STATUS ) ), .F. ) ) .Or. DUU->DUU_CODOCO <> GdFieldGet("DUA_CODOCO",nCntFor) .Or. DUU->DUU_VIAGEM <> M->DUA_VIAGEM )
						If ( !lSobra .Or. ( !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie) ) ) .And. !lDocEntre .And. !lRetMer

							DT6->( DbSetOrder( 1 ) )
							If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
								lTotal := GdFieldGet("DUA_QTDOCO",nCntFor) = DT6->DT6_VOLORI
								lBloqueado:= .F.
								If lMv_TmsPNDB
									lBloqueado:= TM360BLOQ(cFilDoc, cDoc, cSerie)
								EndIf

								If !lBloqueado
									RecLock('DT6',.F.)
									DT6->DT6_BLQDOC := StrZero( 1, Len( DT6->DT6_BLQDOC ) )	//-- Sim
									MsUnLock()
								EndIf
								If lTotal	.Or. (DT2->DT2_TIPPND $ "04" .And. !lDocRee	)
									//-- Alterar o Status do Documento para "9" (Cancelado)
									DUD->(DbSetOrder(1))
									DUD->(DbSeek(xFilial('DUD')+cFilDoc+cDoc+cSerie+cFilAnt))
									While DUD->(!Eof()) .And. DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI) == xFilial('DUD')+cFilDoc+cDoc+cSerie+cFilAnt
										If DUD->DUD_STATUS == StrZero(4,Len(DUD->DUD_STATUS)) .Or. ;
											DUD->DUD_STATUS == StrZero(9,Len(DUD->DUD_STATUS)) .Or. (!lDocRedes .And. Empty(DUD->DUD_VIAGEM))
											DUD->(dbSkip())
											Loop
										EndIf

										RecLock("DUD",.F.)
										DUD->DUD_STATUS := StrZero(9, Len(DUD->DUD_STATUS))
										DUD->(MsUnLock())

										//-- Gerar um Novo DUD
										aAreaDUD := DUD->(GetArea())
										aCampos  := {}

										//-- Se for retorno de uma entrega aerea, retorna para um movto. rodoviario
										If DUD->DUD_SERTMS == StrZero( 3, Len( DUD->DUD_SERTMS ) ) .And. ;
											DUD->DUD_TIPTRA == StrZero( 2, Len( DUD->DUD_TIPTRA ) ) .And. ;
											cEntAer == '1'
											AAdd( aCampos, { 'DUD_TIPTRA', StrZero( 1, Len( DUD->DUD_TIPTRA ) ) } )
										EndIf

										AAdd( aCampos, { 'DUD_ENDERE', If(DTQ->DTQ_SERTMS<>StrZero(1,Len(DTQ->DTQ_SERTMS)) .And. !TMSSldDist( cFilDoc, cDoc, cSerie ),"1","0") } )
										AAdd( aCampos, { 'DUD_STATUS', StrZero( 1, Len( DUD->DUD_SERTMS ) ) } )
										AAdd( aCampos, { 'DUD_MANIFE', CriaVar('DUD_MANIFE', .F.) } )
										AAdd( aCampos, { 'DUD_SERMAN', CriaVar('DUD_SERMAN', .F.) } )
										AAdd( aCampos, { 'DUD_FILMAN', CriaVar('DUD_FILMAN', .F.) } )
										AAdd( aCampos, { 'DUD_VIAGEM', CriaVar('DUD_VIAGEM', .F.) } )
										AAdd( aCampos, { 'DUD_SEQUEN', CriaVar('DUD_SEQUEN', .F.) } )

										// Limpa campos de não previsto
										If DUD->(ColumnPos("DUD_DTRNPR")) > 0
											AAdd( aCampos, { 'DUD_DTRNPR',  CriaVar("DUD_DTRNPR", .F.) } )
											AAdd( aCampos, { 'DUD_HRRNPR',  CriaVar("DUD_HRRNPR", .F.) } )
											AAdd( aCampos, { 'DUD_USURNP',  CriaVar("DUD_USURNP", .F.) } )
											AAdd( aCampos, { 'DUD_NOMUSU',  CriaVar("DUD_NOMUSU", .F.) } )
										EndIf

										If !lDocRee
											TmsCopyReg( aCampos )
										Endif
										RestArea(aAreaDUD)
										Exit
									EndDo
								ElseIf DT2->DT2_TIPPND $ "02/04" .And. lDocRee
										DUD->(DbSetOrder(1))
										DUD->(DbSeek(xFilial('DUD')+cFilDoc+cDoc+cSerie+cFilAnt))
										While DUD->(!Eof()) .And. DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI) == xFilial('DUD')+cFilDoc+cDoc+cSerie+cFilAnt
											If DUD->DUD_STATUS == StrZero(4,Len(DUD->DUD_STATUS)) .Or. ;
												DUD->DUD_STATUS == StrZero(9,Len(DUD->DUD_STATUS)) .Or. (!lDocRedes .And. Empty(DUD->DUD_VIAGEM))
												DUD->(dbSkip())
												Loop
											EndIf

											If lTotal
												RecLock('DT6',.F.)
												DT6->DT6_STATUS := PadR('A', Len(DT6->DT6_STATUS)) 	//-- Retorno Total
												MsUnLock()
											Else
												RecLock('DT6',.F.)
												DT6->DT6_STATUS := StrZero(8,Len(DT6->DT6_STATUS)) 	//-- Retorno Parcial
												MsUnLock()
											Endif

											cFilDco   := DT6->DT6_FILDCO
											cDocDco   := DT6->DT6_DOCDCO
											cSerDco   := DT6->DT6_SERDCO

											cFilVga	  := DUD->DUD_FILORI
											cNumVga	  := DUD->DUD_VIAGEM

											If lTotal
												RecLock("DUD",.F.)
												DUD->DUD_STATUS := StrZero(9, Len(DUD->DUD_STATUS)) //-- Alterar o Status do Documento para "9" (Cancelado)
												MsUnLock()
											Else
												RecLock("DUD",.F.)
												DUD->DUD_STATUS := StrZero(4, Len(DUD->DUD_STATUS)) //-- Alterar o Status do Documento para "4" (Encerrado).Viagem entregou parcialmente os documentos
												MsUnLock()
											Endif

											Exit
										EndDo
								EndIf
							EndIf
						EndIf
						//-- Gera registro de pendencia
						RegToMemory('DUU',.T.)

						// Grava no DUU a Qtde. Informada na Pendencia
						If GdFieldPos('DUA_FILPND') > 0 .And. !Empty(GdFieldGet('DUA_FILPND',nCntFor))
							M->DUU_FILPND := GdFieldGet('DUA_FILPND',nCntFor)
						EndIf

						nQuant  := GdFieldGet('DUA_QTDOCO', nCntFor)
						cTipPnd := Posicione('DT2',1,xFilial('DT2') + GDFieldGet('DUA_CODOCO', nCntFor),'DT2_TIPPND')
						cCodOco := GDFieldGet('DUA_CODOCO', nCntFor)

						// Gera Registro de Pendencia no DUU
						If !Empty(cFilDco) .And. !Empty(cDocDco) .And. !Empty(cSerDco)   //-- grava pendencia no original
							A360GrvPnd(cFilDco, cDocDco, cSerDco, cFilVga, cNumVga, cTipPnd, nQuant, nCntFor)
						Else
							If !lDocRee
								A360GrvPnd(cFilDoc, cDoc, cSerie, DUA->DUA_FILORI, DUA->DUA_VIAGEM, cTipPnd, nQuant, nCntFor)
							Else
								A360GrvPnd(cFilDoc, cDoc, cSerie, iIf(!Empty(cFilOri),cFilOri,cFilVga), iIf(!Empty(cViagem),cViagem,cNumVga), cTipPnd, nQuant, nCntFor)
							EndIf
						EndIf
						//verifica se houve uma apontamento parcial de entrega para o mesmo documento junto com um apontado de avaria
	                    TM360PNB(1, cFilDoc, cDoc, cSerie, cFilOri, cViagem, cTipPnd, nQuant)


						aAreaDT2 := DT2->( GetArea() )
						For nConta := 1 To Len(aCols)
							If ( cFilDoc+cDoc+cSerie == GdFieldGet('DUA_FILDOC',nConta) + GdFieldGet('DUA_DOC',nConta) + GdFieldGet('DUA_SERIE',nConta) ;
								.And. GDFieldGet('DUA_CODOCO', nConta) <> cCodOco ;
								.And. Posicione('DT2',1,xFilial('DT2') + GDFieldGet('DUA_CODOCO', nConta),'DT2_TIPOCO') $ cTipSald  )
								lEntrega := .T.
							EndIf
							If !lEntrega
								cAliasQry := GetNextAlias() // Ficava travado aguardando liberacao de RecLock / Erro Bops 119599-Qualidade Sandra
								cQuery := " SELECT DUA.DUA_FILIAL "
								cQuery += " FROM " + RetSqlName("DUA") + " DUA, "
								cQuery += RetSqlName("DT2") + " DT2, "
								cQuery += RetSqlName("DUU") + " DUU "
								cQuery += " WHERE DUA_FILIAL = '" + xFilial("DUA") + "' "
								cQuery += " AND DUA_FILDOC = '" + cFilDoc + "' "
								cQuery += " AND DUA_DOC    = '" + cDoc    + "' "
								cQuery += " AND DUA_SERIE  = '" + cSerie  + "' "
								cQuery += " AND DUA_FILORI = '" + cFilOri + "' "
								cQuery += " AND DUA_CODOCO <> '" + cCodOco + "' "
								cQuery += " AND DUA.D_E_L_E_T_ = ' ' "
								cQuery += " AND DT2_FILIAL = '" + xFilial("DT2") + "' "
								cQuery += " AND DUA_CODOCO = DT2_CODOCO "
								cQuery += " AND DT2_TIPOCO IN ('" + StrZero(1,Len(DT2->DT2_TIPOCO)) + "','" +  StrZero(6,Len(DT2->DT2_TIPOCO)) + "')"
								cQuery += " AND DT2.D_E_L_E_T_ = ' ' "
								cQuery += " AND DUA_CODOCO = DUU_CODOCO "
								cQuery += " AND DUU_STATUS <> '4' "  //-- verifica se o bloqueio esta encerrado
								cQuery += " AND DUU_TIPPND = '99'"
								cQuery += " AND DUA_DOC = DUU_DOC "
								cQuery += " AND DUU.D_E_L_E_T_ = ' ' "
								dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
								If (cAliasQry)->( !Eof() )
									lEntrega := .T.
								EndIf
								(cAliasQry)->( dbCloseArea() )
							EndIf
						Next nConta
						DbSelectArea("DUU")
						RestArea(aAreaDT2)
						// Grava o Saldo Restante no DUU como Bloqueio
						If GdFieldGet('DUA_QTDVOL', nCntFor) > nQuant .And. !lEntrega .And. !lDocEntre
							nQuant  := GdFieldGet('DUA_QTDVOL', nCntFor)-nQuant
							lRet    := TM360AtuSal(cFilDoc,cDoc,cSerie,nQuant, cTipOco , GdFieldGet("DUA_DATOCO",nCntFor) , l360Auto, cFilOri,cViagem, .F. ,,aDocArm )
							If !lRet
								AAdd(aDocImp,{STR0008 + cFilDoc+"/"+cDoc+"/"+cSerie + STR0034,,}) //"O documento xxxxxx/xxx nao possui mais saldo para ser atualiado
							Else
								cTipPnd := '99' // Bloqueio
								If !lDocRee
									A360GrvPnd(cFilDoc, cDoc, cSerie, DUA->DUA_FILORI, DUA->DUA_VIAGEM, cTipPnd, nQuant, nCntFor)
								Else
									A360GrvPnd(cFilDoc, cDoc, cSerie, iIf(!Empty(cFilOri),cFilOri,cFilVga), iIf(!Empty(cViagem),cViagem,cNumVga), cTipPnd, nQuant, nCntFor)
								EndIf
							EndIf
						EndIf

						DUA->( DbSetOrder( 1 ) )
						If	DUA->( DbSeek( xFilial('DUA') + cFilOco + cNumOco + cFilOri + cViagem + GDFieldGet( 'DUA_SEQOCO', nCntFor ), .F. ) ) .And. Empty( DUA->DUA_NUMPND )
							RecLock('DUA', .F.)
							DUA->DUA_FILPND := M->DUU_FILPND
							DUA->DUA_NUMPND := M->DUU_NUMPND
							MsUnLock()
						EndIf
					EndIf

					If !lSobra .And. lRet
						nSeek := Ascan(aNFAvaria, {|x| x[1]+x[4] == cFilDoc+cDoc+cSerie+cCodOco})
						//-- Gera Pendencia do tipo 'Bloqueia Documento', gera automatico quando nao e' informada a quantidade avariada.
						If nSeek == 0 .And. lBloqueio
							nOld:= n
							n   := nCntFor
							lRet  := TMSA360NF(M->DUA_FILOCO, M->DUA_NUMOCO,,DT2->DT2_TIPPND,.T.)
							If lRet
								nSeek := Ascan(aNFAvaria, {|x| x[1]+x[4] == cFilDoc+cDoc+cSerie+cCodOco})
							EndIf
							n   := nOld
						EndIf
						If nSeek > 0
							For nZ := 1 to Len(aNFAvaria[nSeek][2])
								// So' Grava se informou Qtde.Avariada
								If !Empty(aNFAvaria[nSeek][2][nZ][4]) .And. !aNFAvaria[nSeek][2][nZ][Len(aNFAvaria[nSeek][2][nZ])]
									If DV4->(DbSeek(xFilial('DV4')+ M->DUA_FILOCO+M->DUA_CODOCO+cFilDoc+cDoc+cSerie))
										RecLock("DV4",.F.)
									Else
										RecLock("DV4",.T.)
									EndIf
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Atualiza os dados contidos na GetDados                   ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									For nY := 1 to Len(aHeaderDV4)
										If aHeaderDV4[nY][10] # "V"
											DV4->(FieldPut(ColumnPos(Trim(aHeaderDV4[nY][2])), aNFAvaria[nSeek][2][nZ][nY]))
										EndIf
									Next
									DV4->DV4_FILIAL := xFilial('DV4')
									DV4->DV4_FILOCO := M->DUA_FILOCO
									DV4->DV4_NUMOCO := M->DUA_NUMOCO
									DV4->DV4_FILDOC := GdFieldGet('DUA_FILDOC', nCntFor)
									DV4->DV4_DOC    := GdFieldGet('DUA_DOC'   , nCntFor)
									DV4->DV4_SERIE  := GdFieldGet('DUA_SERIE' , nCntFor)
									DV4->DV4_FILPND := M->DUU_FILPND
									DV4->DV4_NUMPND := M->DUU_NUMPND
									DV4->(MsUnLock())
									//-- Tabela Identificacao Produto por Nota Avariada
									If Len(aIdProduto) > 0
									    cNumNFDV4:= aNFAvaria[nSeek][2][nZ][1]
									    cSerNFDV4:= aNFAvaria[nSeek][2][nZ][2]
										nPosId:= Ascan(aIdProduto,{ |x| x[1] == M->DUA_FILOCO+M->DUA_NUMOCO+cNumNFDV4+cSerNFDV4 })
										If nPosId > 0
											For nZZ := 1 to Len(aIdProduto[nPosId][2])
												If !(aIdProduto[nPosId][2][nZZ][4])

													DbSelectArea("DYM")
													DbSetOrder(1)

													n01 := nZ  //-- Compatibilidade TDS
													n02 := nZZ //-- Compatibilidade TDS

													//-- Testa Conteudo Da Variável Private (Somente Grava Quando Existe ID Da Pendencia).
													If Type("aIdProduto[n01][2][n02][1]") <> "U"

														If DYM->(DbSeek(xFilial('DYM')+ M->DUU_FILPND+M->DUU_NUMPND+cNumNFDV4+cSerNFDV4+aIdProduto[nZ][2][nZZ][1]))
										   					RecLock("DYM",.F.)
									 					Else
															RecLock("DYM",.T.)
														EndIf

														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
														//³ Atualiza os dados contidos na GetDados                   ³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
														For nY := 1 to Len(aHeaderDYM)
															If aHeaderDYM[nY][10] # "V"
																DYM->(FieldPut(ColumnPos(Trim(aHeaderDYM[nY][2])), aIdProduto[nPosId][2][nZZ][nY]))
															EndIf
														Next
														DYM->DYM_FILIAL := xFilial('DYM')
													   	DYM->DYM_FILPND := M->DUU_FILPND
														DYM->DYM_NUMPND := M->DUU_NUMPND
														DYM->DYM_NUMNFC := cNumNFDV4
														DYM->DYM_SERNFC := cSerNFDV4
														DYM->(MsUnLock())
													EndIf
												EndIf
											Next
									    	TM360DYZ(M->DUU_FILPND,M->DUU_NUMPND,cFilDoc,cDoc,cSerie,cNumNFDV4,cSerNFDV4,DV4->DV4_QTDPND,DT2->DT2_TIPPND)
										EndIf
									EndIf
								EndIf
							Next
						EndIf
					EndIf
					If lSobra
						DYM->( DbSetOrder( 1 ) )
						If Empty(cFilDoc+cDoc+cSerie)
							nSeek := Ascan(aIdProduto,{ |x| x[1] == cFilOco+cNumOco+Space(Len(DUA->DUA_FILDOC))+Space(Len(DUA->DUA_DOC))+Space(Len(DUA->DUA_SERIE)) })
						Else
							nSeek := Ascan(aIdProduto,{ |x| x[1] == cFilOco+cNumOco+cFilDoc+cDoc+cSerie })
						EndIf
						If nSeek > 0
							For nZ := 1 to Len(aIdProduto[nSeek][2])
								If !(aIdProduto[nSeek][2][nZ][4])
									If DYM->(DbSeek(xFilial('DYM')+ M->DUU_FILPND+M->DUU_NUMPND+Space(Len(DYM->DYM_NUMNFC))+Space(Len(DYM->DYM_SERNFC))+aIdProduto[nSeek][2][nZ][1]))
										RecLock("DYM",.F.)
									Else
										RecLock("DYM",.T.)
									EndIf
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Atualiza os dados contidos na GetDados                   ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									For nY := 1 to Len(aHeaderDYM)
										If aHeaderDYM[nY][10] # "V"
											DYM->(FieldPut(ColumnPos(Trim(aHeaderDYM[nY][2])), aIdProduto[nSeek][2][nZ][nY]))
										EndIf
									Next
									DYM->DYM_FILIAL := xFilial('DYM')
									DYM->DYM_FILPND := M->DUU_FILPND
									DYM->DYM_NUMPND := M->DUU_NUMPND
									DYM->(MsUnLock())
								EndIf
							Next
							TM360DYZ(M->DUU_FILPND,M->DUU_NUMPND,cFilDoc,cDoc,cSerie,,,,DT2->DT2_TIPPND)
						EndIf

					EndIf

					//--- LS Metrica de Ocorrencia de Sobras e Faltas
					If lMetrica .AND. (lSobra .OR. lFalta)
						TMSMet360(3,cFilDoc,cDoc,cSerie,nTmsOpcx, DT2->DT2_TIPOCO, DT2->DT2_TIPPND ) //Contador para Métrica por Sobras e Faltas
					EndIf

					//Atualiza campo DTC_DOCREE
					If lRet .AND. !Empty(DT6->DT6_FILDCO) .AND. !Empty(DT6->DT6_DOCDCO) //verifica se eh doc de reentrega/devolucao
						If FindFunction("TmsPsqDY4") .And. TmsPsqDY4( DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE ) .AND. lDTCRee
							A360AtuRee(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE, .T. /*Nao eh estorno de ocorrencia de retorno*/)
						Endif
					EndIf
				EndIf

				//-- Atualiza Gestão de Demandas
				If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
					TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,STR0114 + DToC(dDataBase) + " " + Left(Time(),5) + STR0118 + ;
								DUA->DUA_FILDOC + "-" + DUA->DUA_DOC + "/" + DUA->DUA_SERIE + STR0113,.F.,DT2->DT2_TIPOCO,,.F.,.F.)	//-- Bloqueada ## "Demanda bloqueada em " ## " por conta de pendência no documento " ## " do TMS"
				EndIf

				//-- 07 - Estorna Pendencia.
			ElseIf DT2->DT2_TIPOCO == StrZero( 7, Len( DT2->DT2_TIPOCO ) )
				TM360EPEN(aDocEnc, cFilDoc, cDoc, cSerie, cFilOri, cViagem, cAtivChg, aDoc, nA, lDocEntre)

				//-- Atualiza Gestão de Demandas
				If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
					TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,STR0115 + DToC(dDataBase) + " " + Left(Time(),5) + STR0119 + ;
								DUA->DUA_FILDOC + "-" + DUA->DUA_DOC + "/" + DUA->DUA_SERIE + STR0113,.F.,DT2->DT2_TIPOCO,,.F.,.F.)	//-- Planejada ## "Liberação de demanda em " ## " por conta de estorno de pendência no documento " ## " do TMS"
				EndIf

				//-- 08 - Transferencia
			ElseIf DT2->DT2_TIPOCO == StrZero( 8, Len( DT2->DT2_TIPOCO ) )
				
				cFilVtr := GdFieldGet('DUA_FILVTR', nCntFor)
				cNumVtr := GdFieldGet('DUA_NUMVTR', nCntFor)
				
				DTQ->(DbSetOrder(2))
				If DTQ->(DbSeek(xFilial('DTQ')+M->DUA_FILORI+M->DUA_VIAGEM))
					If DTQ->DTQ_SERTMS $ '1;3' // Coleta e Entrega
						DUD->(DbSetOrder( 2 ))
						DUD->(DbSeek(xFilial('DUD')+cFilVtr+cNumVtr+'zzzzzz',.T.))
						DUD->(dbSkip( -1 ))
						cSequen := Soma1( DUD->DUD_SEQUEN )
					EndIf

					DbSelectArea("DUD")
					DbSetOrder(1)
					If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilOri + cViagem ) ) .And. ;
						DUD->( DUD_STATUS == StrZero(2, Len(DUD_STATUS) ) )

						//-- Gerar um Novo DUD
						aAreaDUD := DUD->(GetArea())
						aCampos  := {}
						AAdd( aCampos, { 'DUD_FILORI', cFilVtr } )
						AAdd( aCampos, { 'DUD_VIAGEM', cNumVtr } )
						AAdd( aCampos, { 'DUD_DOCTRF', StrZero(1,Len(DUD->DUD_DOCTRF)) } ) //-- Sim
						AAdd( aCampos, { 'DUD_MANIFE', CriaVar("DUD_MANIFE", .F.) } )
						AAdd( aCampos, { 'DUD_SERMAN', CriaVar("DUD_SERMAN", .F.) } )
						AAdd( aCampos, { 'DUD_FILMAN', CriaVar("DUD_FILMAN", .F.) } )
						AAdd( aCampos, { 'DUD_FILATU', cFilAnt } )
						If DTQ->DTQ_SERTMS $ '1;3' // Coleta e Entrega
							AAdd( aCampos, { 'DUD_SEQUEN', cSequen } )
							cSequen := Soma1( cSequen )
						EndIf
						//-- Verifica status da nova viagem (1-Em Aberto,5-Fechada)
						If Posicione('DTQ',2,xFilial('DTQ')+cFilVtr+cNumVtr,'DTQ_STATUS') $ '1;5'
							AAdd( aCampos, { 'DUD_STATUS', StrZero(1,Len(DUD->DUD_STATUS)) } )
						EndIf
						TmsCopyReg( aCampos )
						RestArea(aAreaDUD)

						//-- Gerar um Novo DM3
						If lViagem3
							DbSelectArea("DM3")
							DbSetOrder(1)
							If DM3->(DbSeek(xFilial("DM3") + DUD->(DUD_FILDOC + DUD_DOC + DUD_SERIE) + cFilOri + cViagem))
								aAreaDM3 := DM3->(GetArea())
								aCampos  := {}
								AAdd(aCampos,{"DM3_FILORI",cFilVtr})
								AAdd(aCampos,{"DM3_VIAGEM",cNumVtr})
								AAdd(aCampos,{"DM3_SEQUEN",DM3->DM3_SEQUEN})
								AAdd(aCampos,{"DM3_FILDOC",DM3->DM3_FILDOC})
								AAdd(aCampos,{"DM3_DOC"   ,DM3->DM3_DOC})
								AAdd(aCampos,{"DM3_SERIE" ,DM3->DM3_SERIE})
								If lDM3Origem
									AAdd(aCampos,{"DM3_ORIGEM",DM3->DM3_ORIGEM})
								EndIf
								TmsCopyReg(aCampos)
								RestArea(aAreaDM3)
							EndIf
						EndIf

						If lTMSIntChk	//-- Existe Check List configurado, o estorno é no fechamento da viagem !!
							//-- Estorna documentos do check-list
							EstDocChk( M->DUA_FILORI ,M->DUA_VIAGEM  , GdFieldGet("DUA_FILDOC" , nCntFor) , GdFieldGet("DUA_DOC", nCntFor) , GdFieldGet("DUA_SERIE", nCntFor) ) 
						EndIf

						//-- Alterar o Status da Viagem Atual para "9" (Cancelado)
						RestArea(aAreaDUD)
						RecLock("DUD",.F.)

						Do Case
							Case nCanViag == 1  //--  MV_TMSCVIA = 0 - Cancela Viagem
								DUD->DUD_STATUS := StrZero(9, Len(DUD->DUD_STATUS)) //- Cancela DUD
							Case nCanViag == 2  //--  MV_TMSCVIA = 1 - Encerra Viagem
								DUD->DUD_STATUS := StrZero(4, Len(DUD->DUD_STATUS)) //- Encerra DUD
							Case nCanViag == 3  //--  MV_TMSCVIA = 2 - Pergunta sera exibida caso nao seja rotina automatica
								If DTQ->(ColumnPos("DTQ_CODAUT")) > 0
									If !Empty(M->DUA_VIAGEM) .And. DTQ->(DbSeek(xFilial("DTQ") + M->DUA_FILORI + M->DUA_VIAGEM))
										lEncerra := TMSA360Aut(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_CODAUT,"TMSA340",lEncViag)
									Else
										lEncerra := lEncViag
									EndIf
								Else
									lEncerra := lEncViag
								EndIf

							    If l360Auto  //-- Caso seja rotina automatica, mantem verificacao em cima do MV_ENCVIAG
									If lEncerra
										lCancelaDTQ := .F.
										DUD->DUD_STATUS := StrZero(4, Len(DUD->DUD_STATUS)) //- Encerra DUD
									Else
										DUD->DUD_STATUS := StrZero(9, Len(DUD->DUD_STATUS)) //- Cancela DUD
									EndIf
							    Else  //-- Exibe Pergunta
									aBotoes := {STR0054,STR0036}

									If nOpcAviso == 0
										nOpcAviso := Aviso(STR0055, STR0056 + cFilOri + "/" + cViagem, aBotoes, 2)
									Endif 

									If nOpcAviso == 1 //-- CANCELAR
										DUD->DUD_STATUS := StrZero(9, Len(DUD->DUD_STATUS)) //- Cancela DUD
									Else
										If nOpcAviso == 2
											lCancelaDTQ := .F.
											DUD->DUD_STATUS := StrZero(4, Len(DUD->DUD_STATUS)) //- Encerra DUD
										EndIf
									EndIf
								EndIf


							//-- O Default para o parametr MV_TMSCVIA foi definido como 5 para identificar que nao
							//   existe o parametro cadastrado, evitando a utilizacao do comando SEEK
							Otherwise

								If lEncerra
									DUD->DUD_STATUS := StrZero(4, Len(DUD->DUD_STATUS)) //- Encerra DUD
								Else
									DUD->DUD_STATUS := StrZero(9, Len(DUD->DUD_STATUS)) //- Cancela DUD
								EndIf
						EndCase

						DUD->DUD_DOCTRF := StrZero(1, Len(DUD->DUD_DOCTRF))
						DUD->(MsUnLock())

						//-- Efetua o carregamento automatico 
						If lViagem3 .AND. Empty(DTQ->DTQ_CODAUT)
							Pergunte("TMSAF60",.F.)
							If MV_PAR01 == 2
								lCarreg3 := .F.
							EndIf
						EndIf
						If lCarAut .And. !lCarreg3
							TMS360Crr( 3, GdFieldGet('DUA_FILVTR', nCntFor) ,GdFieldGet('DUA_NUMVTR', nCntFor), ;
									  GdFieldGet( 'DUA_FILDOC',nCntFor), GdFieldGet( 'DUA_DOC'   ,nCntFor ), ;
			  						  GdFieldGet( 'DUA_SERIE' ,nCntFor ))
						EndIf
					EndIf

					DT6->( DbSetOrder( 1 ) )
					If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
						RecLock('DT6',.F.)
						//-- Desbloquear o Documento se o mesmo estiver Bloqueado
						If DT6->DT6_BLQDOC == StrZero( 1, Len( DT6->DT6_BLQDOC ) )
							DT6->DT6_BLQDOC := StrZero( 2, Len( DT6->DT6_BLQDOC ) )	//-- Nao
						EndIf
						DT6->DT6_FILVGA := cFilVtr
						DT6->DT6_NUMVGA := cNumVtr
						DT6->(MsUnLock())
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³REALIZA A INTEGRACAO COM OPERADORAS DE FROTA³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				    //-- Utilizando o Parametro para encerrar a Repom na Operacao de Ocorrencia
					If lTMSOPdg	.And. lRet
						//-- Encerramento da Repom é pela Operacoes de Ocorrencia
						If lEncRepom == "2" .And. !lRestRepom 
							If (nPos:= Ascan(aNumVtr, {|x| x[1] =='E' .And. x[2]==M->DUA_FILORI .And. x[3]==M->DUA_VIAGEM})) == 0
								DTR->(DbSetOrder(1))
								If DTR->(DBSeek(xFilial('DTR')+M->DUA_FILORI+M->DUA_VIAGEM)) .And. !Empty(DTR->DTR_CODOPE)
									lFrotaProp := Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODVEI,'DA3_FROVEI') == '1'
									CursorWait()
									MsgRun( If( !lFrotaProp,STR0049 ,STR0050 ) ,STR0051 ,;  //"Quitacao do Contrato junto a Operadora de Frotas..."###"Baixa da Viagem junto a Operadora de Frotas..."###"Aguarde..."
											{|| lRet := TMA340Oper( DTR->DTR_CODOPE, M->DUA_FILORI, M->DUA_VIAGEM, @aMsgErr, lFrotaProp, 3)} )	//onde 3= Apontar
									CursorArrow()

									If !lRet .And. !Empty( aMsgErr )
										TmsMsgErr( aMsgErr )
									EndIf
									AAdd(aNumVtr,{'E',M->DUA_FILORI,M->DUA_VIAGEM,lRet})
								EndIf
							Else
								lRet := aNumVtr[nPos,4]
							EndIf
						EndIf
					EndIf
					
					If lTMSIntChk .And. DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA)) .Or. DTQ->DTQ_TIPTRA == StrZero(4,Len(DTQ->DTQ_TIPTRA)) //-- Existe Check List configurado, o estorno é no fechamento da viagem !! //-- Rodoviario ou Rodoviario Internacional
						//-- Envia documentos do check-list
						EnvDocChk( cFilVtr , cNumVtr , GdFieldGet("DUA_FILDOC", nCntFor) , GdFieldGet("DUA_DOC", nCntFor) , GdFieldGet("DUA_SERIE", nCntFor) ) 
					EndIf

				EndIf

				//-- 09 - Gera Indenizacao
			ElseIf DT2->DT2_TIPOCO == StrZero( 9, Len( DT2->DT2_TIPOCO ) )
				lRet:= .F.
				DUD->( DbSetOrder( 1 ) )
				If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + If( Empty( cFilOri + cViagem ), "", cFilOri + cViagem ) ) ) .Or. ;
					DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt + Space(Len(DUD->DUD_VIAGEM)) ) )
					If ( DUD->DUD_STATUS != StrZero( 4, Len( DUD->DUD_STATUS ) ) ) .Or.;
						( DUD->DUD_STATUS == StrZero( 4, Len( DUD->DUD_STATUS ) )   .And.;
						DUD->DUD_FILDCA == cFilAnt )
							lRet:= .T.
                    EndIf
                Else
                	//Documento entregue, grava apenas a Indenizacao
                	If !lDocEntre
                		lRet:= .T.
                	EndIf
				EndIf

				If lRet
					If !lDocEntre
						RecLock("DUD",.F.)
						DUD->DUD_STATUS := StrZero( 9, Len( DUD->DUD_STATUS ) )
						MsUnLock()

						lBloqueado:= .F.
						If lMv_TmsPNDB
							lBloqueado:= TM360BLOQ(cFilDoc, cDoc, cSerie)
						EndIf
						DT6->( DbSetOrder( 1 ) )
						If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
							If !lBloqueado
								RecLock('DT6',.F.)
								DT6->DT6_BLQDOC := StrZero( 1, Len( DT6->DT6_BLQDOC ) )	//-- Sim
								MsUnLock()
							EndIf

							//-- Atualiza Gestão de Demandas
							If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
								TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,STR0114 + DToC(dDataBase) + " " + Left(Time(),5) + ;
											STR0120 + DUA->DUA_FILDOC + "-" + DUA->DUA_DOC + "/" + DUA->DUA_SERIE + STR0113,.F.,DT2->DT2_TIPOCO,,.F.,.F.)	//-- Planejada ## "Liberação de demanda em " ## " por conta de estorno de pendência no documento " ## " do TMS"
							EndIf

						EndIf
					EndIf

					DUB->( DbSetOrder( 3 ) )
					lSeekDUB := DUB->( DbSeek( xFilial( 'DUB' ) + cFilDoc + cDoc + cSerie ) )
					If	!lSeekDUB .Or. (lSeekDUB .And. DUB->DUB_STATUS $ '2/3/4')  
						If DT2->DT2_CATOCO == StrZero(1,Len(DT2->DT2_CATOCO)) // Por Documento
							TmsA360DUB( cFilOri, cViagem, cFilDoc, cDoc, cSerie, DT6->DT6_CLIDEV, DT6->DT6_LOJDEV, GDFieldGet( 'DUA_CODOCO', nCntFor ), GDFieldGet('DUA_MOTIVO', nCntFor ), GDFieldGet( 'DUA_QTDOCO', nCntFor ),, 3 )
						Else
							AAdd(aDocInden, { cFilOri, cViagem, cFilDoc, cDoc, cSerie, DT6->DT6_CLIDEV, DT6->DT6_LOJDEV, GDFieldGet( 'DUA_CODOCO', nCntFor ), GDFieldGet('DUA_MOTIVO', nCntFor ), GDFieldGet( 'DUA_QTDOCO', nCntFor ), } )
							nOpcInden := 3
						EndIf
					EndIf
				EndIf
				//-- 10 - Estorna Indenizacao.
			ElseIf DT2->DT2_TIPOCO == StrZero( 10, Len( DT2->DT2_TIPOCO ) )

				DUB->( DbSetOrder( 3 ) )
				If	DUB->( DbSeek( xFilial( 'DUB' ) + cFilDoc + cDoc + cSerie ) )
					DTQ->( DbSetOrder( 2 ) )
					If	DTQ->( DbSeek( xFilial('DTQ') + M->DUA_FILORI + M->DUA_VIAGEM ) ) .And. DTQ->DTQ_STATUS == StrZero( 9, Len( DTQ->DTQ_STATUS ) )
						//-- Retornar o status da viagem
						RecLock( "DTQ", .F. )
						DTQ->DTQ_STATUS := MsMM(DTQ->DTQ_CODOBS, Len( DTQ->DTQ_STATUS ) )
						MsUnLock()

						//-- Posiciona nas operacoes de transporte com status Cancelado.
						DTW->( DbSetOrder( 3 ) )
						If	DTW->( DbSeek( cSeek := xFilial('DTW') + M->DUA_FILORI + M->DUA_VIAGEM + StrZero( 9, Len( DTW->DTW_STATUS ) ) ) )
							While DTW->( DbSeek( cSeek ) )
								RecLock('DTW',.F.)
								DTW->DTW_DATREA := Ctod('')
								DTW->DTW_HORREA := Space( Len( DTW->DTW_HORREA ) )
								DTW->DTW_STATUS := StrZero( 1, Len( DTW->DTW_STATUS ) )	//-- Em Aberto
								DTW->( MsUnLock() )
							EndDo
						EndIf
					EndIf

					DUD->( DbSetOrder( 1 ) )
					If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilOri + cViagem ) ) .Or. ;
						DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt + Space(Len(DUD->DUD_VIAGEM)) ) )
						If DUD->DUD_STATUS == StrZero(9, Len(DUD->DUD_STATUS)) // Cancelado
							RecLock("DUD",.F.)
							DUD->DUD_STATUS := Tmsa360Doc( cFilOri, cViagem, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE )
							MsUnLock()
						EndIf
					EndIf

					//-- Se o docto estiver bloqueado e a viagem ja tenha chegado na filial, executar a TmsMovViag().
					DT6->( DbSetOrder( 1 ) )
					If DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) ) .And. ( DT6->DT6_BLQDOC == StrZero( 1, Len( DT6->DT6_BLQDOC ) ) .Or. lDocEntre)

						If DT2->DT2_CATOCO == StrZero(1,Len(DT2->DT2_CATOCO)) // Por Documento
							TmsA360DUB( cFilOri, cViagem, cFilDoc, cDoc, cSerie, DT6->DT6_CLIDEV, DT6->DT6_LOJDEV, GDFieldGet( 'DUA_CODOCO', nCntFor ), GDFieldGet('DUA_MOTIVO', nCntFor ), GDFieldGet( 'DUA_QTDOCO', nCntFor ),, 5 )
						Else
							AAdd(aDocInden, {  cFilOri, cViagem, cFilDoc, cDoc, cSerie, DT6->DT6_CLIDEV, DT6->DT6_LOJDEV, GDFieldGet( 'DUA_CODOCO', nCntFor ), GDFieldGet('DUA_MOTIVO', nCntFor ), GDFieldGet( 'DUA_QTDOCO', nCntFor ), } )
							nOpcInden := 5
						EndIf

						If !lDocEntre
							lBloqueado:= .F.
							If lMv_TmsPNDB
								lBloqueado:= TM360BLOQ(cFilDoc, cDoc, cSerie)
							EndIf
							//-- Desbloqueia documento.
							If !lBloqueado
								RecLock('DT6',.F.)
								DT6->DT6_BLQDOC := StrZero( 2, Len( DT6->DT6_BLQDOC ) )
								MsUnLock()
							EndIf

							//-- Atualiza Gestão de Demandas
							If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
								TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,STR0115 + DToC(dDataBase) + " " + Left(Time(),5) + ;
											STR0121 + DUA->DUA_FILDOC + "-" + DUA->DUA_DOC + "/" + DUA->DUA_SERIE + STR0113,.F.,DT2->DT2_TIPOCO,,.F.,.F.)	//-- Planejada ## "Liberação de demanda em " ## " por conta de estorno de indenização no documento " ## " do TMS"
							EndIf

							//-- Caso a viagem ja tenha chegado na filial, executar tmsmovviag para gerar movimento na filial.
							DTW->( DbSetOrder( 4 ) )
							DUD->( DbSetOrder( 1 ) )
							If	DTW->(  DbSeek( xFilial('DTW') + cFilOri + cViagem + cAtivChg + cFilAnt ) ) .And. DTW->DTW_STATUS == StrZero( 2, Len( DTW->DTW_STATUS ) ) .And. ;
								DUD->( !DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt ) )
								TMSMovViag( cFilOri, cViagem, cAtivChg, aDoc, nA, 3 )	//-- Inclui movto viagem e estoque
							EndIf
						EndIf
					EndIf
				EndIf
				//-- 11 - Transferencia de Mercadoria.
			ElseIf DT2->DT2_TIPOCO == StrZero( 11, Len( DT2->DT2_TIPOCO ) )
				aAreaDUD := DUD->( GetArea() )
				DUD->( DbSetOrder(1) )
				DUD->( DbSeek( cSeek := xFilial("DUD") + cFilDoc + cDoc + cSerie + cFilAnt ) )
				While DUD->( !Eof() .And. DUD_FILIAL + DUD_FILDOC + DUD_DOC + DUD_SERIE + DUD_FILORI == cSeek)
					If DUD->DUD_SERTMS == StrZero(3, Len( DUD->DUD_SERTMS ) )
						RecLock("DUD",.F.)
						DUD->DUD_SERTMS := StrZero(2, Len(DUD->DUD_SERTMS)) // Transporte.
						DUD->DUD_STATUS := StrZero(4, Len(DUD->DUD_STATUS)) // Chegada parcial.
						DUD->(MsUnLock())

						//-- Atualiza Gestão de Demandas
						If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
							TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,.F.,DT2->DT2_TIPOCO,,.F.,.F.)
						EndIf

						Exit
					EndIf

					DUD->( dbSkip() )
				EndDo
				RestArea( aAreaDUD )

			//-- 12 - Cancelamento
			ElseIf DT2->DT2_TIPOCO == StrZero( 12, Len( DT2->DT2_TIPOCO ) )

				cSerTMS := Posicione("DTQ", 2, xFilial('DTQ')+M->DUA_FILORI+M->DUA_VIAGEM, "DTQ_SERTMS")

				DbSelectArea("DUD")
				DbSetOrder(1)
				If DUD->( DbSeek( cSeek:=xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilOri + cViagem ) )
					//-- Alterar o Status da Viagem Atual para "9" (Cancelado)
					RecLock("DUD",.F.)
					DUD->DUD_STATUS := StrZero(9, Len(DUD->DUD_STATUS))
					DUD->(MsUnLock())

					If cSerTMS == StrZero(1, Len(DTQ->DTQ_SERTMS)) .Or. (cSerTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_SERADI == "1")	// Coleta ou Entrega com Serviço Adicional de Coleta
						If DUD->DUD_SERTMS == StrZero( 3, Len( DUD->DUD_SERTMS ) ) .And. ;
							DUD->DUD_TIPTRA == StrZero( 2, Len( DUD->DUD_TIPTRA ) )

							//-- Gerar um Novo DUD
							aAreaDUD := DUD->(GetArea())
							aCampos  := {}

							If cEntAer == '1'
								AAdd( aCampos, { 'DUD_TIPTRA', StrZero( 1, Len( DUD->DUD_TIPTRA ) ) } )
							EndIf

							AAdd( aCampos, { 'DUD_VIAGEM', CriaVar('DUD_VIAGEM', .F.) } )
							AAdd( aCampos, { 'DUD_SEQUEN', CriaVar('DUD_SEQUEN', .F.) } )
							AAdd( aCampos, { 'DUD_FILATU', cFilAnt } )

							// Limpa campos de não previsto
							If DUD->(ColumnPos("DUD_DTRNPR")) > 0
								AAdd( aCampos, { 'DUD_DTRNPR',  CriaVar("DUD_DTRNPR", .F.) } )
								AAdd( aCampos, { 'DUD_HRRNPR',  CriaVar("DUD_HRRNPR", .F.) } )
								AAdd( aCampos, { 'DUD_USURNP',  CriaVar("DUD_USURNP", .F.) } )
								AAdd( aCampos, { 'DUD_NOMUSU',  CriaVar("DUD_NOMUSU", .F.) } )
							EndIf
							TmsCopyReg( aCampos )
							RestArea(aAreaDUD)

						ElseIf DUD->DUD_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS))
							//-- Atualiza Gestão de Demandas
							If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8") .And. DUD->DUD_SERTMS == StrZero(1,Len(DUD->DUD_SERTMS))
								TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,STR0122 + DToC(dDataBase) + " " + Left(Time(),5) + ;
											STR0123 + DUA->DUA_FILDOC + "-" + DUA->DUA_DOC + "/" + DUA->DUA_SERIE + STR0113,.F.,DT2->DT2_TIPOCO,,.F.,.F.)	//-- Cancelada ## "Demanda cancelada em " ## " por conta de cancelamento do documento " ## " do TMS"
							EndIf

							DT5->(DbSetOrder(4))
							If DT5->(DbSeek(xFilial("DT5")+cFilDoc+cDoc+cSerie))
								RecLock("DT5", .F.)
								DT5->DT5_STATUS := StrZero(9, Len(DT5->DT5_STATUS))
								DT5->DT5_DATCAN := dDataBase
		                        MSMM(DT5->DT5_CODOBC,,,GDFieldGet( 'DUA_MOTIVO', nCntFor ),1,,,'DT5','DT5_CODOBC')
								DT5->(MsUnLock())
							EndIf

							DT6->( DbSetOrder( 1 ) )
							If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
								RecLock('DT6',.F.)
								DT6->DT6_STATUS := StrZero( 9, Len(DT6->DT6_STATUS) )  // Cancelado
								MsUnLock()
							EndIf

							//-- Verifica se a viagem devera ser cancelada.
							TMSA360CVge(cFilOri,cViagem,.F.)
							//-- Carga Fechada - Encerra item do Agendamento.
							If lTmsCFec
								If !Empty(cFilDF0) .And. !Empty(cFilDF1)
									DTC->( DbSetOrder(3) )  // DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE
									If DTC->( DbSeek( xFilial("DTC") + cFilDoc + cDoc + cSerie ) )
										cFilDF1 := DTC->DTC_FILCFS
										cFilDF0 := DTC->DTC_FILCFS
									Else
										cFilDF1 := cFilDoc
										cFilDF0 := cFilDoc
									EndIf
								Else
									If DTC->( ColumnPos("DTC_FILCFS") ) > 0  .And. !Empty(cFilDF0) .And. !Empty(cFilDF1)
										DbSelectArea("DY4")
										DbSetOrder(1) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
										If DY4->( DbSeek( xFilial("DY4") + cFilDoc + cDoc + cSerie ) )
											DbSelectArea("DTC")
											DTC->( DbSetOrder(2) )  //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto + Fil.Ori + Lote
											If DTC->( DbSeek( xFilial("DTC") + DY4->DY4_NUMNFC + DY4->DY4_SERNFC + DY4->DY4_CLIREM + DY4->DY4_LOJREM + DY4->DY4_CODPRO ) )
												cFilDF1 := DTC->DTC_FILCFS
												cFilDF0 := DTC->DTC_FILCFS
												dDtEntr := DTC->DTC_DTENTR
												cHrEntr := DTC->DTC_HORENT
											Else
												cFilDF1 := cFilDoc
												cFilDF0 := cFilDoc
											EndIf
										Endif
									EndIf
								Endif
								DF1->(DbSetOrder(3))
								If DF1->(DbSeek(cFilDF1 + cFilDoc + cDoc + cSerie ) )
									RecLock("DF1",.F.)
									DF1->DF1_STACOL := StrZero(9,Len(DF1->DF1_STACOL)) //-- Cancelado

									If DTQ->DTQ_TIPVIA == StrZero(3,Len(DTQ->DTQ_TIPVIA)) .And. ;
										Empty(dDtEntr) .And. Empty(cHrEntr)
											If TmsExp() .And. Substr(FunName(),1,7) == "TMSA144"
												DF1->DF1_STAENT := StrZero(4,Len(DF1->DF1_STAENT))
											Else
												DF1->DF1_STAENT := StrZero(3,Len(DF1->DF1_STAENT))
											EndIf
									ElseIf DTQ->DTQ_TIPVIA == StrZero(1,Len(DTQ->DTQ_TIPVIA)) .And. ;
										(DTQ->DTQ_STATUS == StrZero(9, Len(DTQ->DTQ_STATUS)) .OR. DTQ->DTQ_STATUS == StrZero(1, Len(DTQ->DTQ_STATUS))); // CANCELADO ou EM ABERTO
										.And. Substr(FunName(),1,7) != "TMSA050"
										DF1->DF1_STAENT := StrZero(9,Len(DF1->DF1_STAENT)) //-- Cancelado
									Else
										DTC->(DbSetOrder(8))
										If !DTC->(DbSeek(xFilial("DTC")+cFilDoc+cDoc))
											DF1->DF1_STAENT := StrZero(9,Len(DF1->DF1_STAENT)) //-- Cancelado
										EndIf
									EndIf
									MsUnLock()

									//-- Cancelando a Cotacao de Frete e ajustando o agendamento
									If !Empty(DF1->DF1_FILORI) .And. !Empty(DF1->DF1_NUMCOT)
										aAreaDF1 := DF1->(GetArea())
										DF0->(DbSetOrder(1))
										If DF0->(dbSeek(xFilial('DF0')+DF1->DF1_NUMAGE))
											Inclui  := .F.
											Altera  := .T.
											TMSF05Mnt('DF0',DF0->(Recno()),4,.F.,.T.)
											Inclui  := lIncOld
											Altera  := lAltOld
										EndIf
										RestArea(aAreaDF1)
									EndIf
								EndIf
								cNumAge := DF1->DF1_NUMAGE
								DF0->(DbSetOrder(1))
								DF1->(DbSetOrder(1))
								//--Verifica se deve ser cancelado o cabecalho do agendamento
								If DF1->(DbSeek(cFilDF1+cNumAge))
									lCancela := .T.
									While DF1->(!Eof()) .And. DF1->DF1_FILIAL+DF1->DF1_NUMAGE == cFilDF1+cNumAge
										If DF1->DF1_STAENT <> StrZero(9,Len(DF1->DF1_STAENT)) //-- Cancelado
											lCancela := .F.
											Exit
										EndIf
										DF1->(DbSkip())
									EndDo
									If lCancela .And. DF0->(DbSeek(cFilDF0+cNumAge))
										RecLock("DF0",.F.)
										DF0->DF0_STATUS := TMSF05Stat(cFilDF0, cNumAge)
										MsUnlock()
									EndIf
								EndIf
								//Verifica se deve ser encerrado o cabecalho do agendamento
								If DF1->(DbSeek(cFilDF1+cNumAge))
									lEncerra := .T.
									While DF1->(!Eof()) .And. DF1->DF1_FILIAL+DF1->DF1_NUMAGE == cFilDF1+cNumAge
										If DF1->DF1_STAENT <> StrZero(9,Len(DF1->DF1_STAENT)) .And. ; //-- Cancelado
											DF1->DF1_STAENT <> StrZero(5,Len(DF1->DF1_STAENT)) //-- Encerrado
											lEncerra := .F.
											Exit
										EndIf
										DF1->(DbSkip())
									EndDo
									If lEncerra .And. DF0->(DbSeek(cFilDF0+cNumAge))
										RecLock("DF0",.F.)
										DF0->DF0_STATUS := TMSF05Stat(cFilDF0, cNumAge)
										MsUnlock()
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
         	//-- Chegada Eventual : (Existem casos em que o documento e' incluido em uma rota/viagem errada.
         	//-- Se isto ocorrer, devera ser apontada uma ocorrencia de 'Chegada eventual', para que o documento possa ser
         	//-- incluido na rota/viagem correta)
			ElseIf DT2->DT2_TIPOCO == StrZero(13, Len(DT2->DT2_TIPOCO))

				DbSelectArea("DUD")
				DbSetOrder(1)
				If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilOri + cViagem ) ) .And. ;
					DUD->( DUD_STATUS == StrZero(2, Len(DUD_STATUS) ) )

					//-- Gerar um Novo DUD com Status 'Em Aberto' e viagem 'Em branco', para que possa ser incluido em uma outra viagem
					aAreaDUD := DUD->(GetArea())
					aCampos  := {}
					AAdd( aCampos, { 'DUD_DOCTRF', StrZero(1,Len(DUD->DUD_DOCTRF)) } ) //-- Sim
					AAdd( aCampos, { 'DUD_MANIFE', CriaVar("DUD_MANIFE", .F.) } )
					AAdd( aCampos, { 'DUD_SERMAN', CriaVar("DUD_SERMAN", .F.) } )
					AAdd( aCampos, { 'DUD_FILMAN', CriaVar("DUD_FILMAN", .F.) } )
					AAdd( aCampos, { 'DUD_FILORI', cFilAnt } )
					AAdd( aCampos, { 'DUD_VIAGEM', CriaVar("DUD_VIAGEM", .F.) } )
					AAdd( aCampos, { 'DUD_STATUS', StrZero(1,Len(DUD->DUD_STATUS)) } )
					AAdd( aCampos, { 'DUD_FILATU', cFilAnt } )

					// Limpa campos de não previsto
					If DUD->(ColumnPos("DUD_DTRNPR")) > 0
						AAdd( aCampos, { 'DUD_DTRNPR',  CriaVar("DUD_DTRNPR", .F.) } )
						AAdd( aCampos, { 'DUD_HRRNPR',  CriaVar("DUD_HRRNPR", .F.) } )
						AAdd( aCampos, { 'DUD_USURNP',  CriaVar("DUD_USURNP", .F.) } )
						AAdd( aCampos, { 'DUD_NOMUSU',  CriaVar("DUD_NOMUSU", .F.) } )
					EndIf

					TmsCopyReg( aCampos )
					RestArea(aAreaDUD)

					//-- Cancelar o documento incluido na rota/viagem errada (Alterar o Status do Documento para "9" (Cancelado))
					RestArea(aAreaDUD)
					RecLock("DUD",.F.)
					DUD->DUD_STATUS := StrZero(9, Len(DUD->DUD_STATUS))
					DUD->DUD_DOCTRF := StrZero(1, Len(DUD->DUD_DOCTRF))
					DUD->(MsUnLock())

					//-- Atualiza Gestão de Demandas (Apontamento de chegada eventual)
					If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
						TmMontaDmd(Iif(cSerie == "COL","1","2"),DUA->DUA_FILDOC,DUA->DUA_DOC,DUA->DUA_SERIE,,.F.,DT2->DT2_TIPOCO,,.F.,.F.)
					EndIf

				EndIf
				If lUnitiz
					TMA595Grv(/*nOpc*/,/*cLocal*/,/*cLocaliz*/,cFilDoc,cDoc,cSerie,lEndUnitiz)
				EndIf
			//-- Ajusta previsao de chegada da viagem na filial
			ElseIf DT2->DT2_TIPOCO == StrZero(14, Len(DT2->DT2_TIPOCO))
				TMA360PrvAju(cFilOri,cViagem,GdFieldGet("DUA_DATCHG",nCntFor),GdFieldGet("DUA_HORCHG",nCntFor))
			ElseIf aScan( aRecDep , DT2->DT2_TIPOCO) > 0 //-- Rentabilidade/Ocorrência
				cCodOco := GDFieldGet('DUA_CODOCO', nCntFor)

				//---- Cobrança Tentativa de Entrega, Cobrança de Retorno
				If DT2->DT2_TIPOCO == StrZero(19, Len(DT2->DT2_TIPOCO))  .Or. DT2->DT2_TIPOCO == StrZero(20, Len(DT2->DT2_TIPOCO))
					nSeek := Ascan(aNFAvaria, {|x| x[1]+x[4] == cFilDoc+cDoc+cSerie+cCodOco})
					If nSeek > 0
						For nZ := 1 to Len(aNFAvaria[nSeek][2])
							If !Empty(aNFAvaria[nSeek][2][nZ][4]) .And. !aNFAvaria[nSeek][2][nZ][Len(aNFAvaria[nSeek][2][nZ])]
								If DV4->(DbSeek(xFilial('DV4')+ M->DUA_FILOCO+M->DUA_CODOCO+cFilDoc+cDoc+cSerie))
									RecLock("DV4",.F.)
								Else
									RecLock("DV4",.T.)
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Atualiza os dados contidos na GetDados                   ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								For nY := 1 to Len(aHeaderDV4)
									If aHeaderDV4[nY][10] # "V"
										DV4->(FieldPut(ColumnPos(Trim(aHeaderDV4[nY][2])), aNFAvaria[nSeek][2][nZ][nY]))
									EndIf
								Next
								DV4->DV4_FILIAL := xFilial('DV4')
								DV4->DV4_FILOCO := M->DUA_FILOCO
								DV4->DV4_NUMOCO := M->DUA_NUMOCO
								DV4->DV4_FILDOC := GdFieldGet('DUA_FILDOC', nCntFor)
								DV4->DV4_DOC    := GdFieldGet('DUA_DOC'   , nCntFor)
								DV4->DV4_SERIE  := GdFieldGet('DUA_SERIE' , nCntFor)
								DV4->(MsUnLock())
							EndIf
						Next
					EndIf
				EndIf

				lGeraDDN	:= .T. //-- Gera acrescimos/decrescimos

				If DT2->(ColumnPos("DT2_CDTIPO")) > 0 .And. !Empty(DT2->DT2_CDTIPO)
					If DT2->DT2_TIPOCO == StrZero(17,Len(DT2->DT2_TIPOCO))
						lGeraDDN	:= .F.
					EndIF
				EndIf

				If FindFunction("TMSA029USE") .And. Tmsa029Use("TMSA360")
					lBlq029	:= .T.

					If DT2->(ColumnPos("DT2_CDTIPO")) > 0 .And. !Empty(DT2->DT2_CDTIPO)
						If DT2->DT2_TIPOCO == StrZero(17,Len(DT2->DT2_TIPOCO))
							lBlq029	:= .F.
						EndIF
					EndIf

				Else
					lBlq029	:= .F.
				EndIf

				//------------------------------------------------------------------------------------------
				//-- Início - Tratamento TMSA029 Para Rentabilidade/Ocorrência
				//------------------------------------------------------------------------------------------
				If lBlq029

					cDocRD   :=  Alltrim(GDFieldGet('DUA_DOC', nCntFor )) + Space(1) + Alltrim(GDFieldGet( 'DUA_SERIE', nCntFor ))
					cForRD   :=  GDFieldGet('DUA_CODFOR', nCntFor )
					cLojRD   :=  GDFieldGet('DUA_LOJFOR', nCntFor )
					cDesRD   :=  Alltrim(Posicione("SA2",1, xFilial("SA2") + cForRD + cLojRD ,"A2_NOME"))
					cChvRD   :=  xFilial("DUA") + cFilAnt + cNumOco + cFilOri + cViagem + GDFieldGet( 'DUA_SEQOCO', nCntFor )
					nValRec  :=  GDFieldGet('DUA_VLRRCT', nCntFor )
					nValDes  :=  GDFieldGet('DUA_VLRDSP', nCntFor )

					cDetalhe :=  Alltrim(RetTitle("DUA_DOC")) + ": " 											+ "#" +; //-- No. Docto.
					cDocRD 																		+ "#" +; //-- Docto + Série
					Alltrim(RetTitle("DUA_DESCFO")) + ": " 										+ "#" +; //-- Nome Forn.
					Alltrim(cForRD) + "/" + Alltrim(cLojRD) + " - " + cDesRD 						+ "#" +; //-- Descrição Fornecedor
					Alltrim(RetTitle("DUA_VLRRCT")) + ": " 										+ "#" +; //-- Vlr. Receita
					Transform( GDFieldGet('DUA_VLRRCT', nCntFor ), PesqPict("DUA","DUA_VLRRCT"))	+ "#" +; //-- Vlr. Receita
					Alltrim(RetTitle("DUA_VLRDSP")) + ": " 										+ "#" +; //-- Vlr. Despesa
					Transform( GDFieldGet('DUA_VLRDSP', nCntFor ), PesqPict("DUA","DUA_VLRDSP"))	+ "#" +; //-- Vlr. Despesa
					Alltrim(RetTitle("DUA_MOTIVO")) + ": " 										+ "#" +; //-- Motivo
					Alltrim( GDFieldGet('DUA_MOTIVO', nCntFor ))									+ "|"    //-- Conteúdo Campo DUA_MOTIVO

					//-- Bloqueia Registro Na Tabela DDU
					If Tmsa029Blq(  3                 ,; //-- nOpc
						'TMSA360'          ,; //-- cRotina
						DT2->DT2_TIPOCO    ,; //-- cTipBlq
						cFilDoc            ,; //-- cFilOri
						'DUA'              ,; //-- cTab
						'1'                ,; //-- cInd
						cChvRD             ,; //-- cChave -> DUA_FILIAL+DUA_FILOCO+DUA_NUMOCO+DUA_FILORI+DUA_VIAGEM+DUA_SEQOCO
						cViagem            ,; //-- cCod
						cDetalhe           ,; //-- cDetalhe
						Nil                ,; //-- nOpcRot
						nValDes            ,; //-- Valor Despesa
						nValRec             ) //-- Valor Receita

						//-- Muda Status DUA Para Bloqueada (Receita/Despesa)
						RecLock('DUA', .F.)
						DUA->DUA_RECDEP := '2' //-- Bloqueado
						DUA->(MsUnLock())

						lGeraDDN	:= .F.

						//-- Tratamento Para Liberação Automática Caso Configurado
						If DT2->DT2_LIBAUT == '1'

							//-- Muda Status DUA Para Bloqueada (Receita/Despesa)
							RecLock('DUA', .F.)
							DUA->DUA_RECDEP := '1' //-- Liberado
							DUA->(MsUnLock())

							//-- Regras Para Executar Ou Não A Liberação Automática
							If 	 (( DT2->DT2_TIPOCO == StrZero(16,Len(DT2->DT2_TIPOCO))  .Or. ;
									DT2->DT2_TIPOCO == StrZero(18,Len(DT2->DT2_TIPOCO))) .And.;
									(GDFieldGet('DUA_VLRRCT', nCntFor ) > 0 ));
									.Or.;
									((DT2->DT2_TIPOCO == StrZero(17,Len(DT2->DT2_TIPOCO))  .Or. ;
									DT2->DT2_TIPOCO == StrZero(18,Len(DT2->DT2_TIPOCO))) .And.;
									(GDFieldGet('DUA_VLRDSP', nCntFor ) > 0 ));

									//-- Chama Rotina De Liberação Automática
									If !Tmsa029Lib( Nil , { 'TMSA360',DT2->DT2_TIPOCO,cFilDoc,'DUA','1',cChvRD,cViagem} )
										//-- Mensagem Erro Caso Não Consiga Liberar
										Help('',1,'TMSA360D2') //-- 'A Liberação Automática Não Pôde Ser Realizada Conforme a Parametrização.','Verifique o Status Do Registro Na Rotina De Bloqueios Do TMS (TMSA029).'
									EndIf
							EndIf
						Else
							lGeraDDN	:= .F.
						EndIf
					EndIf

				Else
					//-- Muda Status DUA Para Bloqueada (Receita/Despesa)
					RecLock('DUA', .F.)
					DUA->DUA_RECDEP := '1' //-- Liberado
					DUA->(MsUnLock())
				EndIf

				//------------------------------------------------------------------------------------------
				//-- Tratamento para geração de Acréscimos/Decréscimos
				//------------------------------------------------------------------------------------------
				If lGeraDDN
					TMSA360DDN( .T. , cFilOri , cViagem , cFilOco, cNumOco , GDFieldGet( 'DUA_SEQOCO', nCntFor ), GDFieldGet('DUA_VLRDSP', nCntFor ) , DT2->DT2_CODAED  )
				EndIf

				//------------------------------------------------------------------------------------------
				//-- Fim    - Tratamento TMSA029 Para Rentabilidade/Ocorrência
				//------------------------------------------------------------------------------------------


			EndIf

			// Realiza integração com o GFE
			If  DT2->(ColumnPos("DT2_CDTIPO")) > 0 .AND. !Empty(DT2->DT2_CDTIPO) .And. nModulo <> 78  //Quando executado via rotina automatica pelo SIGAGFE nao executar a chamada do GFEA032 (duplicidade)
				lRet:= TM360OcGFE(cFilDoc,cDoc,cSerie,cFilOri,cViagem,GdFieldGet("DUA_CODOCO",nCntFor),GDFieldGet('DUA_CODFOR', nCntFor ),GDFieldGet('DUA_LOJFOR', nCntFor ), ;
									GDFieldGet( 'DUA_VALINF', nCntFor ),GDFieldGet( 'DUA_SEQOCO', nCntFor ), M->DUA_FILORI, M->DUA_NUMOCO, nQtdOco )			
			EndIf


			//-----------------------------------------------------------------------------------------------
			//-- Inicio - Tratamento Valorização Da Coleta
			//-----------------------------------------------------------------------------------------------
			//-- 4 = RETORNA COLETA ; 12 = CANCELAMENTO DE COLETA
			If DT2->DT2_TIPOCO == StrZero(4, Len(DT2->DT2_TIPOCO)) .Or. DT2->DT2_TIPOCO == StrZero(12, Len(DT2->DT2_TIPOCO))
				//-- Coleta
				If cSerTMS == StrZero(1, Len(DTQ->DTQ_SERTMS))

					//-- Posiciona Na Solicitação De Coleta
					DbSelectArea("DT5")
					DT5->(DbSetOrder( 4 )) //-- DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE
					MsSeek( FWxFilial('DT5') + cFilDoc + cDoc + cSerie , .f. )

					//-- Valoriza Coleta Não Efetivada '1' = SIM; '2' = NAO
					cValCol := TmsSobServ('VALCOL',,.T.,DT5->DT5_NCONTR,DT5->DT5_CODNEG,DT5->DT5_SERVIC,"0", Nil )

					//-- Não Valoriza Coleta
					If cValCol == '2'

						aInfDJI := {} //-- Inicializa Variável
						aAdd( aInfDJI, {'DJI_FILDOC'	, DT5->DT5_FILDOC })
						aAdd( aInfDJI, {'DJI_DOC'		, DT5->DT5_DOC    })
						aAdd( aInfDJI, {'DJI_SERIE'		, DT5->DT5_SERIE  })

						//-- Altera Status Do Último DJI Para Cancelado
						TmsAtuDJI( cFilOri, cViagem, Nil, '2', aInfDJI, .f. )

					EndIf

					If cValCol $ "2|1"
						//-- Limpa Valorização Do Documento No DT6 e Exclui Registros No DT8
						Tmsa310Clr( DT5->DT5_FILDOC, DT5->DT5_DOC, DT5->DT5_SERIE,/*lDT6*/ .T.,/*cDT8*/ "D" )
					EndIf
				EndIf
			EndIf
			//-----------------------------------------------------------------------------------------------
			//-- Fim - Tratamento Valorização Da Coleta
			//-----------------------------------------------------------------------------------------------

			//-- Faz a Chamada à gravação da tabela de monitor do comprovante de entrega
			//-- O array aOcoEncPND indica que o documento em foco possui dois ou mais apontamento de ocorrencia
			//-- sendo que um deles é do tipo 6-Pendencia e a tabela DLY será gravada com base no tipo 6-pendencia.
			//-- PNDXCMPENT-202001
			//-----------------------------------------------------------------------------------------------
			lWriteDLY := .T.
			If (AScan(aOcoEncPND,{|k| k[1]+k[2]+k[3] == cFilDoc+cDoc+cSerie }) > 0) .And. (!DT2->DT2_TIPOCO $ (StrZero(6,Len(DT2->DT2_TIPOCO)) + "|"))
				lWriteDLY := .F.
			EndIf
			If lWriteDLY
				lExistCE := A360ComprE( cFilOco, cNumOco, DT2->DT2_CODOCO, cFilDoc, cDoc, cSerie )
			EndIf

			If lTM360ITE
				ExecBlock('TM360ITE',.F.,.F.,{aDoc,nA})
			EndIf
		Next nA
	Next nCntFor
	If lRet
		For nA := 1 To Len(aLoteAut)
			DTP->(DbSetOrder(2))
			If DTP->(DbSeek(xFilial("DTP")+cFilAnt+aLoteAut[nA][2]))
				RecLock("DTP",.F.)
				DTP->DTP_QTDLOT := aLoteAut[nA][3]
				DTP->DTP_QTDDIG := aLoteAut[nA][4]
				MsUnlock()
				AAdd(aDocImp,{ STR0027 + DTP->DTP_LOTNFC + ", " + STR0024 + " " +; //"Favor imprimir os documentos do lote "###"tipo"
					Iif(aLoteAut[nA][1]==StrZero(5,Len(DT6->DT6_DOCTMS)),STR0012,STR0013)+".",,}) //"Nota Fiscal"###"Conhecimento"
			EndIf
		Next nA
	EndIf
EndIf
If lRet
	//-- Gera / Estorna Indenizacao por Viagem
	If DT2->DT2_CATOCO == StrZero(2,Len(DT2->DT2_CATOCO)) .And. ; // Por Viagem
		( DT2->DT2_TIPOCO == StrZero( 9, Len( DT2->DT2_TIPOCO ) ) .Or. ; // Gera Indenizacao
		DT2->DT2_TIPOCO == StrZero( 10, Len( DT2->DT2_TIPOCO ) ) ) // Estorna Indenizacao

		If !Empty(aDocInden)
			TmsA360DUB(,,,,,,,,,,,nOpcInden,aDocInden )
		EndIf

	EndIf
EndIf

RestArea(aAreaDTQ)
RestArea(aAreaDT6)
If !Empty(aAreaDUA)
	RestArea(aAreaDUA)
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA360DUB³ Autor ³ Antonio C F          ³ Data ³19.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Prepara variaveis para chamar a geracao do registro de     ³±±
±±³          ³ indenizacoes( TmsA370Grv ).                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA360DUB( cFilOri, cViagem, cFilDoc, cDocto, cSerie,;    ³±±
±±³          ³ cCliRem, cLojRem, cCodOco, cMotivo, nQtdOco, nValPre,;     ³±±
±±³          ³ nOpcx, aDocInden )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA360DUB( cFilOri, cViagem, cFilDoc, cDocto, cSerie, cCliRem, cLojRem, cCodOco, cMotivo, nQtdOco, nValPre, nOpcx, aDocInden )

Local aHeaOld    := Iif( Type('aHeader') == 'A', aClone( aHeader ), {} )
Local aColOld    := Iif( Type('aCols') == 'A', aClone( aCols ), {} )
Local aNoFields  := {}
Local aYesFields := {}
Local nCntFor    := 0
Local aRet       := {}
Local aAreaDT6   := DT6->( GetArea() )
Local aAreaDU7   := DU7->( GetArea() )
Local aAreaDUU   := DUU->( GetArea() )
Local aMsgErr    := {}
Local cNumRid    := ""
Local cServic    := ""

Default aDocInden := {}

If Empty(aDocInden)
	AAdd(aDocInden, { cFilOri, cViagem, cFilDoc, cDocto, cSerie, cCliRem, cLojRem, cCodOco, cMotivo, nQtdOco, nValPre } )
EndIf

For nCntFor := 1 To Len(aDocInden)

	If nOpcx == 3 //-- Inclusao
		//-- Efetua a Averbacao do Seguro
		cServic := AllTrim(Posicione("DT6",1,xFilial("DT6")+aDocInden[nCntFor,3]+aDocInden[nCntFor,4]+aDocInden[nCntFor,5],"DT6_SERVIC"))
		DC5->(DbSetOrder(1))
		If DC5->(DbSeek(xFilial("DC5")+cServic)) .And. !Empty(DC5->DC5_TABSEG)
			aRet := TMSSeguro( aDocInden[nCntFor,3], aDocInden[nCntFor,4], aDocInden[nCntFor,5],.F., @aMsgErr, DC5->DC5_TABSEG, DC5->DC5_TPTSEG )
			If !Empty( aMsgErr )
				TmsMsgErr( aMsgErr )
			EndIf
		EndIf
		If Empty( aRet )
			RestArea( aAreaDT6 )
			RestArea( aAreaDU7 )
			RestArea( aAreaDUU )
			Return( Space( Len( DUB->DUB_NUMRID ) ) )
		EndIf
	ElseIf nOpcx == 5 //-- Exclusao
		//-- Se ainda nao fechou o seguro, exclui averbacao
		DT6->( DbSetOrder( 1 ) )
		If DT6->( DbSeek( xFilial( 'DT6' )+aDocInden[nCntFor,3]+aDocInden[nCntFor,4]+aDocInden[nCntFor,5] ) ) .And. Empty( DT6->DT6_DOCSEG )
			DU7->( DbSetOrder( 1 ) )
			While DU7->( DbSeek( xFilial( 'DU7' )+aDocInden[nCntFor,3]+aDocInden[nCntFor,4]+aDocInden[nCntFor,5] ) )
				RecLock( 'DU7', .F. )
				DbDelete()
				MsUnLock()
			EndDo
		EndIf
	EndIf

	aHeader	:= {}
	aCols		:= {}

	AAdd( aNoFields, 'DUB_FILRID' )
	AAdd( aNoFields, 'DUB_NUMRID' )
	AAdd( aNoFields, 'DUB_DATRID' )
	AAdd( aNoFields, 'DUB_HORRID' )

	//-- Gera variaveis para gravacao do registro de indenizacoes
	RegToMemory('DUB',nOpcx==3)

	If nOpcx == 3 .And. nCntFor == 1
		cNumRid := CriaVar("DUB_NUMRID")
	EndIf

	//-- Configura variaveis da GetDados
	TMSFillGetDados(	nOpcx, 'DUB', 3,xFilial( 'DUB' ) + aDocInden[nCntFor,3] + aDocInden[nCntFor,4] + aDocInden[nCntFor,5], { || DUB->DUB_FILIAL + DUB->DUB_FILDOC + DUB->DUB_DOC + DUB->DUB_SERIE }, ;
	{ || .T. }, aNoFields,	aYesFields )

	If nOpcx == 3 //-- Inclusao
		GDFieldPut( 'DUB_ITEM'  , StrZero( nCntFor, Len( DUB->DUB_ITEM ) ), 1 )
		GDFieldPut( 'DUB_COMSEG', Posicione('DT2',1,xFilial('DT2')+aDocInden[nCntFor,8],'DT2_COMSEG'), 1 )
		GDFieldPut( 'DUB_FILORI', aDocInden[nCntFor, 1], 1 )
		GDFieldPut( 'DUB_VIAGEM', aDocInden[nCntFor, 2], 1 )
		GDFieldPut( 'DUB_CODOCO', aDocInden[nCntFor, 8], 1 )
		GDFieldPut( 'DUB_FILDOC', aDocInden[nCntFor, 3], 1 )
		GDFieldPut( 'DUB_DOC'   , aDocInden[nCntFor, 4], 1 )
		GDFieldPut( 'DUB_SERIE' , aDocInden[nCntFor, 5], 1 )
		GDFieldPut( 'DUB_CODCLI', aDocInden[nCntFor, 6], 1 )
		GDFieldPut( 'DUB_LOJCLI', aDocInden[nCntFor, 7], 1 )
		GDFieldPut( 'DUB_QTDOCO', aDocInden[nCntFor,10], 1 )
		GDFieldPut( 'DUB_VALPRE', If(aDocInden[nCntFor,11]<>Nil,aDocInden[nCntFor,11],0), 1 )

		M->DUB_NUMRID := cNumRid
		M->DUB_MOTIVO := aDocInden[nCntFor,9]

	ElseIf nOpcx == 5 //-- Exclui
		cNumRid := M->DUB_NUMRID
		GDFieldPut( 'DUB_ESTORN', StrZero( 1, TamSX3('DUB_ESTORN')[1] ), 1 )
	EndIf

	//-- Gravacao do registro de indenizacoes.
	TMSA370Grv( cNumRid, nOpcx )

	If	__lSX8 .And. Len(aDocInden) == nCntFor
		ConfirmSX8()
	EndIf

Next nCntFor

If	! Empty( aHeaOld )
	aHeader:= aClone( aHeaOld )
	aCols  := aClone( aColOld )
EndIf

RestArea( aAreaDT6 )
RestArea( aAreaDU7 )
RestArea( aAreaDUU )

Return( cNumRid )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA360Est³ Autor ³ Antonio C F          ³ Data ³19.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao do estorno de ocorrencias.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA360Est( cFilOco, cNumOco, cFilOri, cViagem, aDocEnc )  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial da Ocorrencia.                              ³±±
±±³          ³ ExpC2 - Numero da Ocorrencia.                              ³±±
±±³          ³ ExpC1 - Filial de Origem.                                  ³±±
±±³          ³ ExpC1 - Codigo da Viagem.                                  ³±±
±±³          ³ ExpA1 - Array Contendo Informacoes Sobre o Documento.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA360Est( cFilOco, cNumOco, cFilOri, cViagem, aDocEnc, cNumRom )

Local aAreaDTQ 	  := DTQ->( GetArea() )
Local aAreaDUA 	  := DUA->( GetArea() )
Local aAreaDT5 	  := DT5->( GetArea() )
Local aAreaDUM 	  := DUM->( GetArea() )
Local aAreaDT6 	  := DT6->( GetArea() )
Local aIndeniz 	  := {}
Local aPendenc 	  := {}
Local aNoEstor 	  := {}
Local aDoc	   	  := {}
Local cFilDoc 	  := ''
Local cDoc	   	  := ''
Local cSerie   	  := ''
Local cAtivChg 	  := GetMV('MV_ATIVCHG',,'')
Local cOcorCfe 	  := SuperGetMv('MV_OCORCFE',,"")
Local nA       	  := 0
Local nCntFor  	  := 0
Local cFilVge  	  := ""
Local cNumVge  	  := ""
Local cFilVtr  	  := ""
Local cNumVtr  	  := ""
Local cSeek    	  := ""
Local cSerTMS  	  := ""
Local cSeekDUD 	  := ""
Local aAreaDUD 	  := {}
Local cStatus  	  := ""
Local lContinua	  := .T.
Local lRet     	  := .T.
Local lApaga   	  := .T.
Local lTmsCFec 	  := TmsCFec() //-- Carga Fechada
Local lSinc    	  := Iif(IsInCallStack(AllTrim('TMSA350GRV')),.F.,TMSSinc()) //-- Chamada Via Sicronizador
Local dDatEmb  	  := Ctod("")
Local lDocFinCanc := .F.
Local cStatusDUD  := ""
Local cStatusDT5  := ""
Local lSobra      := .F.
Local nQtdOco     := 0
Local cTipOco     := ''
Local cFilDco     := ''
Local cDocDco     := ''
Local cSerDco     := ''
Local cFilVga	  := ''
Local cNumVga	  := ''
Local cFilDF0     := xFilial("DF0")
Local cFilDF1     := xFilial("DF1")
Local cAtivDca    := GetMV('MV_ATIVDCA',,'')
Local l360ARMZ	  := .T.
Local lDelDud     := .F.
Local lDocRedes   := .F.
Local nDudRed     := 0
Local cOcorBx    := SuperGetMv('MV_OCORRDP',,"")
Local lTercRbq    := DTR->(ColumnPos("DTR_CODRB3")) > 0

Local lLibVgBlq   := SuperGetMV('MV_LIBVGBL',,.F.)  //-- Libera Encerramento de viagens com ocorrencia do tipo

//-- Confirmacao de Embarque
Local cHorPar     := ''
Local dDatChg     := Ctod('')
Local cHorChg     := ''
Local cNumVoo     := ''

Local lDocEntre     := .F.
Local nTmsdInd      := SuperGetMv('MV_TMSDIND',.F.,0) // Dias permitidos para indenizacao apos o documento entregue
Local lMv_TmsPNDB	:= SuperGetMv("MV_TMSPNDB",.F.,.F.) //-- Permite informar a ocorrencia de Pendencia para um Docto Bloqueado
Local lBloqueado    := .F.
Local lDocRee	    := SuperGetMV('MV_DOCREE',,.F.) .And. TMSChkVer('11','R7')
Local lDTCRee 	:= DTC->(ColumnPos("DTC_DOCREE")) > 0
Local lFalta        := .F.
Local cFilPnd       := ""
Local cNumPnd       := ""
Local lAgdEntr     := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)   //-- Agendamento de Entrega.
Local aInfDJI     := {}
Local cValCol     := "" //-- Composição Do Campo DDC_VALCOL/DDA_VALCOL
Local aAreaDUA2  := {}
Local lAchou     := .F.
Local aCab       := {}
Local aItens     := {}
Local cSeekDUM   := ""
Local aDadosDUM  := {}
Local nRecRed    := 0
Local lTm360Armz := ExistBlock("TM360ARMZ")
Local lITmsDmd   := SuperGetMv("MV_ITMSDMD",,.F.)
Local lColViaEnt := .F.
Local lDUAPrzEnt := DUA->(ColumnPos("DUA_PRZENT")) > 0
Local lTMSIntChk  := SuperGetMV("MV_TMAPCKL",,.F.) .And. ExistFunc("TMSIntChk") .And. TMSDLZAti()

Local aArea       := {}
Local cQueryDM3   := ""

Default aDocEnc := {}
Default cNumRom := ""
//-- A ocorrencia do tipo "informativa" podera ser excluida se a viagem estiver encerrada

//-- Ocorrencias que geram indenizacoes( DUB ).
AAdd( aIndeniz, StrZero( 9,Len( DT2->DT2_TIPOCO ) ) )

//-- Ocorrencias que geram pendencias( DUU ).
AAdd( aPendenc, StrZero( 6,Len( DT2->DT2_TIPOCO ) ) )

For nCntFor := 1 To Len( aCols )

	If lContinua
		//-- Somente registros selecionados para estorno.
		If	GDDeleted( nCntFor ) .Or. GDFieldGet( 'DUA_ESTOCO', nCntFor ) != StrZero( 1, TamSX3('DUA_ESTOCO')[1] )
			Loop
		EndIf

		//-- Estorna ocorrência integrada ao GFE	
		lContinua:= TM360EsGFE( M->DUA_FILOCO, M->DUA_NUMOCO, GDFieldGet('DUA_SEQOCO', nCntFor), GDFieldGet('DUA_CODOCO', nCntFor)  )
		If !lContinua
			Exit
		EndIf
	EndIf

	If lContinua

		DT2->( DbSetOrder( 1 ) )
		DT2->( DbSeek( xFilial('DT2') + GDFieldGet('DUA_CODOCO', nCntFor) ) )
		lSobra  := ( DT2->DT2_TIPOCO == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND == StrZero(3,Len(DT2->DT2_TIPPND)) ) //-- Sobra
		lFalta  := ( DT2->DT2_TIPOCO == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND == StrZero(1,Len(DT2->DT2_TIPPND)) ) //-- Falta

		//-- Ocorrencias sem permissao para estornar.
		If	Ascan( aNoEstor, DT2->DT2_TIPOCO ) > 0
			Help('',1,'TMSA36023')				//-- Estorno nao permitido, registre a ocorrencia novamente.
			Exit
		EndIf

		cFilDoc := GDFieldGet( 'DUA_FILDOC', nCntFor )
		cDoc    := GDFieldGet( 'DUA_DOC'   , nCntFor )
		cSerie  := GDFieldGet( 'DUA_SERIE' , nCntFor )
		cFilVtr := GDFieldGet( 'DUA_FILVTR', nCntFor )
		cNumVtr := GDFieldGet( 'DUA_NUMVTR', nCntFor )
		nQtdOco := GDFieldGet( 'DUA_QTDOCO', nCntFor )
		cFilPnd := GDFieldGet( 'DUA_FILPND', nCntFor )
		cNumPnd := GDFieldGet( 'DUA_NUMPND', nCntFor )
		cTipOco := DT2->DT2_TIPOCO


		If Empty(cFilVtr) .And. Empty(cNumVtr)
			cFilVge := cFilOri
			cNumVge := cViagem
		Else
			cFilVge := cFilVtr
			cNumVge := cNumVtr
		EndIf

		If DT2->DT2_TIPOCO == StrZero( 1 , Len( DT2->DT2_TIPOCO ) ) .Or. ; //-- Encerra Processo
			DT2->DT2_TIPOCO == StrZero( 12, Len( DT2->DT2_TIPOCO ) ) .Or. ; //-- Cancelamento
			DT2->DT2_TIPOCO == StrZero( 21, Len( DT2->DT2_TIPOCO ) ) .Or. ; //-- Entrega Trecho GFE ( Tratamento Rentabilidade/Ocorrencia )
			DT2->DT2_TIPOCO == StrZero( 9 , Len( DT2->DT2_TIPOCO ) )        //-- Gera Indenizacao
			TMSVerMov( cFilVge, cNumVge, cFilDoc, cDoc, cSerie, (DT2->DT2_TIPOCO == StrZero( 3,Len(DT2->DT2_TIPOCO))), @aDoc, .F. , .T. )
		Else
			//-- lDocFinCanc foi criada para a funcao tmsvermov preencher o vetor aDoc com os documentos encerrados ou cancelados,
			//-- na exclusao de uma ocorrencia do tipo "informativa" ou "retorno de documento", com categoria "por viagem".
			lDocFinCanc := ( 	DT2->DT2_TIPOCO == StrZero(5,Len(DT2->DT2_TIPOCO)) .Or. DT2->DT2_TIPOCO == StrZero(4,Len(DT2->DT2_TIPOCO)) )
			TMSVerMov( cFilVge, cNumVge, cFilDoc, cDoc, cSerie, (DT2->DT2_TIPOCO == StrZero( 3,Len(DT2->DT2_TIPOCO))), @aDoc, .F. , lDocFinCanc )
		EndIf

		For nA := 1 To Len( aDoc )

			cFilDoc := aDoc[ nA, 1 ]
			cDoc    := aDoc[ nA, 2 ]
			cSerie  := aDoc[ nA, 3 ]

			//-- Ocorrencias que geram indenizacoes( DUB ).
			If	Ascan( aIndeniz, DT2->DT2_TIPOCO ) > 0
				DUB->( DbSetOrder( 3 ) )
				If	DUB->( DbSeek( xFilial( 'DUB' ) + cFilDoc + cDoc + cSerie ) ) .And. DUB->DUB_STATUS != StrZero( 1, Len( DUB->DUB_STATUS ) )
					Help('',1,'TMSA36021',, STR0029 + cFilDoc +'/'+ cDoc +'/'+ cSerie,4,1)	//"Registro de indenizacoes nao encontrado ou ja concluido.(DUB)"###"Fil.Doc./Doc./Serie: "
					lContinua := .F.
					Exit
				EndIf

				//-- Ocorrencias que geram pendencias( DUU ).
			ElseIf Ascan( aPendenc, DT2->DT2_TIPOCO ) > 0
				DUU->( DbSetOrder( 3 ) )
				If	DUU->( DbSeek( xFilial('DUU') + cFilDoc + cDoc + cSerie ) ) .And. DUU->DUU_STATUS != StrZero( 1, Len( DUU->DUU_STATUS ) )
					Help('',1,'TMSA36022',, STR0029 + cFilDoc +'/'+ cDoc +'/'+ cSerie,4,1)	//"Registro de pendencias nao encontrado ou ja concluido.(DUU)"###"Fil.Doc./Doc./Serie: "
					lContinua := .F.
					Exit
				EndIf
			EndIf

		Next nA

		If !Empty(cFilPnd) .And. !Empty(cNumPnd) .And. (lSobra .Or. lFalta)
			DUU->( DbSetOrder( 6 ) )
			If	DUU->( DbSeek( xFilial('DUU') + StrZero(3,Len(DUU->DUU_STACON)) + cFilPnd + cNumPnd ) )
				Help('',1,'TMSA360B0')	//"Nao e possivel estornar a ocorrencia pois existe uma conciliacao efetuada.
				lContinua := .F.
			EndIf
		EndIf
		If lContinua
			
			If !A360OcoPrz(DT2->DT2_CODOCO)  //Prazo de Entrega a exclusão será executada apos validação
				//----------------------------------------------------------------------------------------------------
				//-- Início - Deleta Referencias De Bloqueio Da Tabela DDU Caso Existam - ( Rentabilidade/Ocorrência)
				//----------------------------------------------------------------------------------------------------
				If FindFunction("TMSA029USE") .And. Tmsa029Use("TMSA360")

					Tmsa029Blq( 5			,; //-- 01 - nOpc
								'TMSA360'	,; //-- 02 - cRotina
								Nil			,; //-- 03 - cTipBlq
								cFilOri	,; //-- 04 - cFilOri
								'DUA'		,; //-- 05 - cTab
								'1'			,; //-- 06 - cInd
								xFilial("DUA") + cFilAnt + cNumOco + cFilOri + cViagem + GDFieldGet( 'DUA_SEQOCO', nCntFor ),; //-- 07 - cChave
								""			,; //-- 08 - cCod
								""			)  //-- 09 - cDetalhe
				EndIf
			EndIf
			//----------------------------------------------------------------------------------------------------
			//-- Fim   - Deleta Referencias De Bloqueio Da Tabela DDU Caso Existam - ( Rentabilidade/Ocorrência)
			//----------------------------------------------------------------------------------------------------

			For nA := 1 To Len( aDoc )

				cFilDoc   := aDoc[ nA, 1 ]
				cDoc      := aDoc[ nA, 2 ]
				cSerie    := aDoc[ nA, 3 ]
				lRet      := .T.
				lApaga    := .T.

				If lDocRee .And. (DT2->DT2_TIPOCO == StrZero(1,Len(DT2->DT2_TIPOCO)) .Or. DT2->DT2_TIPOCO == StrZero( 4,Len(DT2->DT2_TIPOCO)) .Or. DT2->DT2_TIPOCO == StrZero(21,Len(DT2->DT2_TIPOCO)) .Or. ;
				(DT2->DT2_TIPOCO == StrZero( 6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND == StrZero(4,Len(DT2->DT2_TIPPND)) ) )

					cAliasDT6 := GetNextAlias()  //-- Localiza documento original

					cQuery := " SELECT DT6.DT6_FILDCO, DT6.DT6_DOCDCO, DT6.DT6_SERDCO, DT6.DT6_FILVGA, DT6.DT6_NUMVGA "
					cQuery += " FROM " + RetSqlName("DT6") + " DT6, " + RetSqlName("DUA") + "  DUA "
					cQuery += " WHERE DT6_FILIAL   = '" + xFilial('DT6') + "' "
					cQuery += " AND DT6_FILDOC     = '" + cFilDoc + "' "
					cQuery += " AND DT6_DOC        = '" + cDoc    + "' "
					cQuery += " AND DT6_SERIE      = '" + cSerie  + "' "
					cQuery += " AND DUA_FILDOC     = DT6_FILDCO	 "
					cQuery += " AND DUA_DOC        = DT6_DOCDCO  "
					cQuery += " AND DUA_SERIE      = DT6_SERDCO  "
					cQuery += " AND DT6.D_E_L_E_T_ = ' ' "

					cQuery := ChangeQuery( cQuery )
					dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasDT6, .F., .T. )

					If (cAliasDT6)->(!Eof())
						cFilDco   := (cAliasDT6)->DT6_FILDCO
						cDocDco   := (cAliasDT6)->DT6_DOCDCO
						cSerDco   := (cAliasDT6)->DT6_SERDCO
					EndIf

					(cAliasDT6)->(dbCloseArea())
					DUD->( DbSetOrder( 1 ) )
					If	DUD->( MsSeek( xFilial('DUD') + cFilDco + cDocDco + cSerDco ) )
						cFilVga	  := DUD->DUD_FILORI
						cNumVga	  := DUD->DUD_VIAGEM
					EndIf
				EndIf

				//-- Verifica se existem ocorrencias do mesmo tipo por documentos
				If DT2->DT2_CATOCO == StrZero(2,Len(DT2->DT2_CATOCO)) .And. ; //-- Por Viagem
					TmsA360VDoc(cFilDoc,cDoc,cSerie,DT2->DT2_TIPOCO,M->DUA_FILOCO,M->DUA_NUMOCO)
					Loop
				EndIf

				//-- Verifica se a ocorrencia e' Gera Pendencia/Indenizacao para um documento ja entregue,
				//-- e neste caso, nao atualiza saldo, bloqueios e nao gera novo DUD
				lDocEntre:= .F.
				If nTmsdInd > 0
					lDocEntre:= TM360INDE(cFilDoc, cDoc, cSerie, DT2->DT2_TIPOCO, nTmsdInd)
				EndIf

				lDocRedes  := TMA360IDFV( cFilDoc,cDoc,cSerie,.F.,cFilOri,cViagem )

				If lDocRedes .And. DT2->DT2_TIPOCO == StrZero( 4, Len( DT2->DT2_TIPOCO ) )
					If DT2->DT2_TIPRDP == StrZero( 2, Len( DT2->DT2_TIPRDP ) )
						Loop
					EndIf
				EndIf

				//-- 01 - Encerra Processo
				If	DT2->DT2_TIPOCO == StrZero( 1, Len( DT2->DT2_TIPOCO ) )

					// Serviço da Ocorrencia
					cSerTms := DT2->DT2_SERTMS

					DT6->( DbSetOrder( 1 ) )
					If DT6->( MsSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
						If  Empty(cSerTms) 
							cSerTms := DT6->DT6_SERTMS
						EndIf
						
						RecLock('DT6', .F. )
						DT6->DT6_DATENT := CToD("")
						If DT6->DT6_STATUS == StrZero( 7, Len(DT6->DT6_STATUS) ) //--Entregue
							DT6->DT6_STATUS := StrZero( 3, Len(DT6->DT6_STATUS) ) //--Em Transito
						EndIf
						MsUnLock()

					EndIf
					
					If !Empty(cFilOri) .And. !Empty(cViagem)
						DTQ->( DbSetOrder( 2 ) )
						lRet := DTQ->( DbSeek( xFilial('DTQ') + cFilOri + cViagem ) ) .And. DTQ->DTQ_STATUS != StrZero( 3, Len( DTQ->DTQ_STATUS ))
						// Verifica se serviço da viagem
						If lRet .AND. EMPTY(cSerTms)
							cSerTms := DTQ->DTQ_SERTMS
						EndIf
					EndIf
					
					If IIf(Empty(cViagem), DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt + cViagem)), DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilOri + cViagem))) .And. ;
						DUD->DUD_STATUS <> StrZero( 1, Len( DUD->DUD_STATUS ) )
						RecLock('DUD', .F. )
						If Empty(DUD->DUD_VIAGEM)
							DUD->DUD_STATUS := StrZero( 1, Len( DUD->DUD_STATUS ) ) //--Em Aberto						
						ElseIf DUD->DUD_STATUS == StrZero( 4, Len( DUD->DUD_STATUS ) ) //--Encerrado	
							DUD->DUD_STATUS := StrZero( 2, Len( DUD->DUD_STATUS ) ) //--Em Trânsito
						EndIf
						MsUnLock()
					Else 
						If Empty(cViagem) .And. DT2->DT2_TIPOCO == '01' .And. DT2->DT2_CATOCO = '1'
							If Empty(DUA->DUA_FILORI) .And. Empty(DUA->DUA_VIAGEM)
								cAliasQry := GetNextAlias()
								cQuery := " SELECT (MAX(R_E_C_N_O_)) R_E_C_N_O_"
								cQuery += "   FROM " + RetSqlName("DUD")
								cQuery += "  WHERE DUD_FILIAL = '" + xFilial('DUD') + "' "
								cQuery += "    AND DUD_FILDOC = '" + DUA->DUA_FILDOC + "' "
								cQuery += "    AND DUD_DOC    = '" + DUA->DUA_DOC + "' "
								cQuery += "    AND DUD_SERIE  = '" + DUA->DUA_SERIE + "' "
								cQuery += "    AND D_E_L_E_T_ = ' ' "
								cQuery := ChangeQuery( cQuery )
								dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

								If (cAliasQry)->R_E_C_N_O_ > 0
									aAreaDUD := DUD->( GetArea() )
									DUD->(dbGoto((cAliasQry)->R_E_C_N_O_))
									If Empty(DUD->DUD_VIAGEM)
										RecLock('DUD', .F. )
											DUD->DUD_STATUS := StrZero( 1, Len( DUD->DUD_STATUS ) ) //--Em Aberto						
										MsUnLock()
									EndIf
									RestArea( aAreaDUD )
								EndIf
								(cAliasQry)->( dbCloseArea() )
							EndIf
						EndIf
					
					EndIf			

					If lRet
					    //Identifica se a ocorrencia foi apontada em uma coleta inclusa em uma viagem de entrega.
				    	lColViaEnt := cSerTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .AND. DTQ->DTQ_SERADI == "1" .AND. !Empty(cViagem) .AND. cSerie = 'COL'

						//-- Viagem de coleta
						If cSerTMS == StrZero(1, Len(DTQ->DTQ_SERTMS)) .OR. lColViaEnt 
							DUD->( DbSetOrder( 1 ) )
							If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilOri + cViagem ) ) .And. ;
								DUD->DUD_STATUS <> StrZero( 9, Len( DUD->DUD_STATUS ) ) // Cancelado

								If DUD->DUD_SERTMS == StrZero(1,Len(DUD->DUD_SERTMS)) // Coleta de Doctos. de Coleta

									RecLock('DUD', .F. )
									DUD->DUD_STATUS := StrZero( 2, Len( DUD->DUD_STATUS ) ) // Em Transito
									MsUnLock()

									// Atualiza status da Solicitacao de Coleta
									DT5->( DbSetOrder( 4 ) )
									If	DT5->( DbSeek( xFilial('DT5') + cFilDoc + cDoc + cSerie ) )
										RecLock('DT5',.F.)
										DT5->DT5_STATUS := StrZero( 3, Len(DT5->DT5_STATUS) ) // Em Transito
										MsUnLock()
									EndIf

									DT6->( DbSetOrder( 1 ) )
									If	DT6->( MsSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
										RecLock('DT6',.F.)
										DT6->DT6_STATUS := StrZero( 3, Len(DT6->DT6_STATUS) ) // Em Transito
										MsUnLock()
									EndIf

									//-- Atualiza Gestão de Demandas
									If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
										IF DT2->DT2_TIPOCO == '01' //só atualiza demanda se for ocorrência de encerramento.
											TmMontaDmd(DT6->DT6_DOCTMS,cFilDoc,cDoc,cSerie,,.T.,DT2->DT2_TIPOCO,,.F.,.F.)
										EndIf
									EndIf

									//-- Carga Fechada - Volta o status do Agendamento para 'Em Processo'.
									If lTmsCFec
										If !Empty(cFilDF0) .And. !Empty(cFilDF1)
											If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc,cDoc,cSerie)
												DTC->( DbSetOrder(3) )  // DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE
												If DTC->( DbSeek( xFilial("DTC") + cFilDoc + cDoc + cSerie ) )
													cFilDF1 := DTC->DTC_FILCFS
													cFilDF0 := DTC->DTC_FILCFS
												Else
													cFilDF1 := cFilDoc
													cFilDF0 := cFilDoc
												EndIf
											Else
												DbSelectArea("DY4")
												DY4->( DbSetOrder(1) )  //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
												If DY4->( DbSeek( xFilial("DY4") + cFilDoc + cDoc + cSerie ) )
													DbSelectArea("DTC")
													DTC->( DbSetOrder(2) )  //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto + Fil.Ori + Lote
													If DTC->( DbSeek( xFilial("DTC") + DY4->DY4_NUMNFC + DY4->DY4_SERNFC + DY4->DY4_CLIREM + DY4->DY4_LOJREM + DY4->DY4_CODPRO ) )
														cFilDF1 := DTC->DTC_FILCFS
														cFilDF0 := DTC->DTC_FILCFS
													Else
														cFilDF1 := cFilDoc
														cFilDF0 := cFilDoc
													EndIf
												Endif
											Endif
										EndIf
										DF1->(DbSetOrder(3))
										If DF1->(DbSeek(xFilial("DF1", cFilDF1) + cFilDoc + cDoc + cSerie ) )
											RecLock("DF1",.F.)
											DF1->DF1_STACOL := StrZero(4,Len(DF1->DF1_STACOL)) //-- Em Processo
											MsUnLock()
										EndIf
										DF0->( DbSetOrder(1) )
										If DF0->( DbSeek(cFilDF0 + DF1->DF1_NUMAGE )) .And. DF0->DF0_STATUS <> StrZero(3,Len(DF0->DF0_STATUS ))
											Reclock("DF0",.F.)
											DF0->DF0_STATUS := TMSF05Stat(cFilDF0, DF1->DF1_NUMAGE)
											MsUnLock()
										EndIf
									EndIf

								ElseIf DUD->DUD_SERTMS == StrZero( 3, Len( DUD->DUD_SERTMS ) ) .And. ;
									DUD->DUD_TIPTRA == StrZero( 2, Len( DUD->DUD_TIPTRA ) )

									//-- Se coleta de doctos de entrega aerea (Aeroporto)
									DUD->( DbSetOrder( 1 ) )
									If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilOri + cViagem ) )
										RecLock('DUD', .F. )
										DUD->DUD_STATUS := StrZero( 2, Len( DUD->DUD_STATUS ) ) //-- Em Transito
										MsUnLock()

										//-- Realizar a baixa do estoque.
										TmsBxEstoq( cFilOri, cViagem, cFilDoc, cDoc, cSerie )

									EndIf

									//-- Exclui novo DUD
									If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt + Space(Len(DUD->DUD_VIAGEM)) ) )
										RecLock('DUD', .F. )
										DbDelete()
										MsUnLock()
									EndIf
								EndIf
							Else
								//-- Atualiza status da Solicitacao de Coleta sem Viagem no estorno
								DT5->( DbSetOrder( 4 ) )
								If	DT5->( DbSeek( xFilial('DT5') + cFilDoc + cDoc + cSerie ) ) .And. Empty(cViagem) .And. DT5->DT5_STATUS == StrZero( 4, Len(DT5->DT5_STATUS) )
									RecLock('DT5',.F.)
									DT5->DT5_STATUS := StrZero( 1, Len(DT5->DT5_STATUS) ) // Em Aberto
									MsUnLock()
								EndIf
							EndIf

                            aDadosDUM := {0,0,0,0,0,0,0}
                            DT5->(DbSetOrder(4))
                            If DT5->(DbSeek(xFilial('DT5') + cFilDoc + cDoc + cSerie))
                                DUM->(DbSetOrder(1))
                                If DUM->(DbSeek(cSeekDUM := xFilial('DUM') + DT5->(DT5_FILORI + DT5_NUMSOL)))
                                    While DUM->(!Eof()) .And. DUM->(DUM_FILIAL + DUM_FILORI + DUM_NUMSOL) == cSeekDUM
                                        aDadosDUM[1] += DUM->DUM_QTDVOL
                                        aDadosDUM[2] += DUM->DUM_PESO
                                        aDadosDUM[3] += DUM->DUM_PESOM3
                                        aDadosDUM[4] += DUM->DUM_VALMER
                                        aDadosDUM[5] += DUM->DUM_METRO3
                                        aDadosDUM[6] += DUM->DUM_QTDUNI
                                        aDadosDUM[7] += DUM->DUM_BASSEG
                                        DUM->(DbSkip())
                                    EndDo
                                EndIf
                                DT6->(DbSetOrder(1))
                                If DT6->(DbSeek(xFilial('DT6') + DT5->(DT5_FILDOC + DT5_DOC + DT5_SERIE)))
                                    RecLock('DT6',.F.)
                                    DT6->DT6_QTDVOL := aDadosDUM[1]
                                    DT6->DT6_PESO   := aDadosDUM[2]
                                    DT6->DT6_PESOM3 := aDadosDUM[3]
                                    DT6->DT6_METRO3 := aDadosDUM[5]
                                    DT6->DT6_VALMER := aDadosDUM[4]
                                    DT6->DT6_QTDUNI := aDadosDUM[6]
                                    DT6->DT6_BASSEG := aDadosDUM[7]
                                    DT6->DT6_PESCOB := Max(aDadosDUM[2],aDadosDUM[3])
                                    MsUnLock()
                                EndIf
                            EndIf

						ElseIf cSerTms == StrZero( 2, Len( DTQ->DTQ_SERTMS ) ) .Or. cSerTms == StrZero( 3, Len( DTQ->DTQ_SERTMS ) ) // Viagem Transporte ou Entrega
							//Funcao para atualizar saldo dos volumes
							TM360AtuSal(cFilDoc,cDoc,cSerie,-nQtdOco, 'ES',,l360Auto,cFilOri,cViagem, .F. , , , , ,cNumRom,lITmsDmd,"4")
							If Empty(DT6->DT6_FILDCO) .And. Empty(DT6->DT6_DOCDCO) .and.Empty(DT6->DT6_SERDCO)
								TM360ATDC(4,@aDocEnc,cFilDoc,cDoc,cSerie,DT2->DT2_TIPOCO,,.F.,,M->DUA_FILORI,M->DUA_VIAGEM,.F.,,GdFieldGet("DUA_CODOCO",nCntFor))
							Else
								TM360ATDC(4,@aDocEnc,DT6->DT6_FILDCO,DT6->DT6_DOCDCO,DT6->DT6_SERDCO,DT2->DT2_TIPOCO,,.F.,,M->DUA_FILORI,M->DUA_VIAGEM,.F.,,GdFieldGet("DUA_CODOCO",nCntFor))
								If !Empty(cFilDco) .And. !Empty(cDocDco) .And. !Empty(cSerDco)
									TM360AtuSal(cFilDco,cDocDco,cSerDco,-nQtdOco, cTipOco , GdFieldGet("DUA_DATOCO",nCntFor) , l360Auto,cFilVga,cNumVga, .F. , , , , ,cNumRom,lITmsDmd,"4")
								EndIf
							EndIf
							DT6->( DbSetOrder( 1 ) )
							If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
								RecLock('DT6',.F.)
								DT6->DT6_BLQDOC := StrZero( 2, Len( DT6->DT6_BLQDOC ) )
								MsUnLock()
							EndIf
							//-- Atualiza Gestão de Demandas
							If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
								If DT2->DT2_TIPOCO == '01' //só atualiza demanda se for ocorrência de encerramento.
									TmMontaDmd(DT6->DT6_DOCTMS,cFilDoc,cDoc,cSerie,,.T.,DT2->DT2_TIPOCO,,.F.,.F.)
								Endif
							EndIf
							//-- Tratamento para que seja feito o estorno da operação de descarregamento
							//-- que foi cancelada pois foi lancada uma ocorrência de encerra processo
							//-- para um documento de entrega gerado a partir de uma viagem de transf.
							//-- que não foi apontado a operação de DESCARREGAMENTO.
							DUD->(DbSetOrder(1))
							If( DUD->(DbSeek(xFilial('DUD') + cFildoc + cDoc + cSerie + DUA->DUA_FILOCO)) )
								DTW->(DbSetOrder(4))
								If ( DTW->(DbSeek(xFilial('DTW') + DUD->DUD_FILVGE+ DUD->DUD_NUMVGE + cAtivDca)) )
									RecLock('DTW',.F.)
									DTW->DTW_DATINI := Ctod('')
									DTW->DTW_HORINI := Space(Len(DTW->DTW_HORINI))
									DTW->DTW_DATREA := Ctod('')
									DTW->DTW_HORREA := Space(Len(DTW->DTW_HORREA))
									DTW->DTW_STATUS := StrZero(1, Len(DTW->DTW_STATUS))
									MsUnLock()
								EndIf
							EndIf
							If __lPyme
								DUD->( DbSetOrder( 7 ) )
								If DUD->( DbSeek( xFilial( "DUD" ) + cFilDoc + cDoc + cSerie + cNumRom ) )
									RecLock('DUD', .F. )
									DUD->DUD_STATUS := Tmsa360Doc( cFilOri, cViagem, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE, cNumRom )
									MsUnLock()
								EndIf
							EndIf
							// Atualiza o Status do Agendamento
							If lAgdEntr
								dbSelectArea("DYD")
								If !Empty( DYD->( IndexKey(2) ) ) // DYD_FILIAL + DYD_FILDOC + DYD_DOC + DYD_SERIE + DYD_NUMAGD
									DYD->( dbSetOrder(2))

									DYD->( dbSeek( FwxFilial("DYD")+ cFilDoc + cDoc + cSerie + REPLICATE("Z",TamSx3("DYD_NUMAGD")[1]),.T.))
									DYD->(dbSkip(-1))

									If DYD->DYD_STATUS != '6' .AND. DYD->DYD_FILDOC == cFilDoc .AND. DYD->DYD_DOC == cDoc .AND. DYD->DYD_SERIE  == cSerie
										RecLock("DYD",.F.)
										DYD->DYD_STATUS :=  Iif(Empty(DYD->DYD_DATAGD),'5','1')
										MsUnlock()
									EndIf

								EndIf
							EndIf
						EndIf

						//--- LS Metrica de Ocorrencia de Estorno Encerra Processo
						If lMetrica .And. DT2->DT2_TIPOCO == StrZero(1,Len(DT2->DT2_TIPOCO)) 
							TMSMet360(2,cFilDoc,cDoc,cSerie,4) //Contador para Métrica por Encerra Processo
						EndIf

					EndIf

					//-- 02 - Bloqueia Docto
				ElseIf DT2->DT2_TIPOCO == StrZero( 2, Len( DT2->DT2_TIPOCO ) )

					DT6->( DbSetOrder( 1 ) )
					If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
						RecLock('DT6',.F.)
						//-- Nao.
						DT6->DT6_BLQDOC := StrZero( 2, Len( DT6->DT6_BLQDOC ) )
						MsUnLock()
					EndIf

					//-- Atualiza Gestão de Demandas
					If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
						TmMontaDmd(DT6->DT6_DOCTMS,cFilDoc,cDoc,cSerie,STR0115 + DToC(dDataBase) + " " + Left(Time(),5) + STR0124 + DUA->DUA_FILDOC + "-" + ;
									DUA->DUA_DOC + "/" + DUA->DUA_SERIE + STR0113,.T.,DT2->DT2_TIPOCO,,.F.,.F.)	//-- Planejada ## "Liberação de demanda em " ## " por conta de estorno de bloqueio do documento " ## " do TMS"
					EndIf

					//-- 03 - Libera documento
				ElseIf DT2->DT2_TIPOCO == StrZero( 3, Len( DT2->DT2_TIPOCO ) )

					DT6->( DbSetOrder( 1 ) )
					If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
						RecLock('DT6',.F.)
						DT6->DT6_BLQDOC := StrZero( 1, Len( DT6->DT6_BLQDOC ) ) //-- Sim.
						MsUnLock()
					EndIf

					//-- Atualiza Gestão de Demandas
					If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
						TmMontaDmd(DT6->DT6_DOCTMS,cFilDoc,cDoc,cSerie,STR0114 + DToC(dDataBase) + " " + Left(Time(),5) + STR0125 + DUA->DUA_FILDOC + "-" + ;
									DUA->DUA_DOC + "/" + DUA->DUA_SERIE + STR0113,.T.,DT2->DT2_TIPOCO,,.F.,.F.)	//-- Bloqueada ## "Demanda bloqueada em " ## " por conta de estorno de liberação do documento " ## " do TMS"
					EndIf

					//-- Se o documento nao estiver relacionado a uma viagem.
					DTW->( DbSetOrder( 4 ) )
					DUD->( DbSetOrder( 1 ) )
					If	DTW->( DbSeek( xFilial('DTW') + cFilOri + cViagem + cAtivChg + cFilAnt) ) .And. DTW->DTW_STATUS == StrZero( 2, Len( DTW->DTW_STATUS ) ) .And. ;
						DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt ) ) .And. !lLibVgBlq
						//-- Exclui movto da viagem.
						TMSMovViag( cFilOri, cViagem, cAtivChg, aDoc, nA, 5 )
					EndIf

					//-- 04 - Retorno de Docto
				ElseIf DT2->DT2_TIPOCO == StrZero( 4, Len( DT2->DT2_TIPOCO ) )

					If !TMSA360DY4(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
						Help('',1,'TMSA360C7') //"Não é permitido estornar esta ocorrencia! Existe outro documento de Reentrega gerado"
						lRet := .F.
					Endif

					//-- Verifica se o Doc e' de redespacho
					nDudRed:= TMA360IRD(cFilDoc,cDoc,cSerie,StrZero(9, Len(DUD->DUD_STATUS)),.T.)

					DUD->( DbSetOrder( 1 ) )
					DTQ->( DbSetOrder( 2 ) )
					If	DTQ->( DbSeek( xFilial('DTQ') + cFilOri + cViagem ) ) .And. DTQ->DTQ_STATUS != StrZero( 3, Len( DTQ->DTQ_STATUS ) )  .Or. nDudRed > 0

						DUD->( DbSetOrder( 1 ) )
						If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilOri + cViagem ) ) .Or. ;
							DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt + Space(Len(DUD->DUD_VIAGEM)) ) ) .Or.;
							nDudRed > 0  //-- Documento de Redespacho.

							If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc,cDoc,cSerie)
								DTC->( DbSetOrder(3) )  // DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE
								DTC->( DbSeek( cSeek := xFilial("DTC") + cFilDoc + cDoc + cSerie ) )
								Do While !DTC->(Eof()) .And. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) == cSeek
									DUH->(DbSeek(xFilial("DUH")+cFilAnt+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM))
									Do While !DUH->(Eof()) .And. xFilial("DUH")+DUH->DUH_FILORI+DUH->DUH_NUMNFC+DUH->DUH_SERNFC+DUH->DUH_CLIREM+DUH->DUH_LOJREM == ;
											DTC->DTC_FILIAL+cFilAnt+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM
										RecLock("DUH",.F.)
										DUH->DUH_STATUS := StrZero(2, Len(DUH->DUH_STATUS)) //-- Carregado
										MsUnLock()
										DUH->(dbSkip())
									EndDo
									DTC->(dbSkip())
								EndDo
							Else
								DbSelectArea("DY4")
								DY4->( DbSetOrder(1) )  //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
								If DY4->( DbSeek( xFilial("DY4") + cFilDoc + cDoc + cSerie ) )
									Do While !DY4->(Eof()) .And. DY4->(DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE) == cSeek
										DUH->(DbSeek(xFilial("DUH")+cFilAnt+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM))
										Do While !DUH->(Eof()) .And. xFilial("DUH")+DUH->DUH_FILORI+DUH->DUH_NUMNFC+DUH->DUH_SERNFC+DUH->DUH_CLIREM+DUH->DUH_LOJREM == ;
												DY4->DY4_FILIAL+cFilAnt+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM
											RecLock("DUH",.F.)
											DUH->DUH_STATUS := StrZero(2, Len(DUH->DUH_STATUS)) //-- Carregado
											MsUnLock()
											DUH->(dbSkip())
										EndDo
										DTC->(dbSkip())
									EndDo
								Endif
							Endif

							If nDudRed > 0
								DUD->( DbGoto(nDudRed) )
							EndIf

							RecLock('DUD', .F. )
							DUD->DUD_STATUS := Tmsa360Doc( cFilOri, cViagem, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE)
							cStatusDUD := DUD->DUD_STATUS
							MsUnLock()

							//-- Se viagem de entrega.
							If	DTQ->DTQ_SERTMS == StrZero( 3, Len(DTQ->DTQ_SERTMS) )
								//-- Realizar a baixa do estoque.
								TmsBxEstoq( cFilOri, cViagem, cFilDoc, cDoc, cSerie )
							EndIf
						EndIf

						//-- Se o Doc. de redespacho, procura o DUD relativo em aberto, para exclusao
						If nDudRed > 0
							nRecRed:= TMA360IRD(cFilDoc,cDoc,cSerie,StrZero(1, Len(DUD->DUD_STATUS)),.F.)
							If nRecRed > 0
								DUD->( DbGoto(nRecRed) )
							EndIf

							lDelDud := .T.
						ElseIf DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt + Space(Len(DUD->DUD_VIAGEM)) ) )
							lDelDud := .T.
						EndIf

						//-- Exclui novo DUD
						If lDelDud
							RecLock('DUD', .F. )
							DbDelete()
							MsUnLock()
						EndIf

						If DTQ->DTQ_SERTMS == StrZero( 1, Len( DTQ->DTQ_SERTMS ) ) // Viagem Coleta.
							DT5->( DbSetOrder( 4 ) )
							If	DT5->( DbSeek( xFilial('DT5') + cFilDoc + cDoc + cSerie ) )
								//-- Verifica o Status do Documento
							If cStatusDUD == StrZero(1,Len(DUD->DUD_STATUS)) .Or. cStatusDUD == StrZero(3,Len(DUD->DUD_STATUS)) //-- Em Aberto ## Carregado
									cStatusDT5 := StrZero(2,Len(DT5->DT5_STATUS)) //-- Indicado para Coleta
								ElseIf cStatusDUD == StrZero(2,Len(DUD->DUD_STATUS)) //-- Em Transito
									cStatusDT5 := StrZero(3,Len(DT5->DT5_STATUS)) //-- Em Transito
								ElseIf cStatusDUD == StrZero(4,Len(DUD->DUD_STATUS)) //-- Encerrado
									cStatusDT5 := StrZero(4,Len(DT5->DT5_STATUS)) //-- Encerrada
								EndIf

								If TmsExp() .And. Substr(FunName(),1,7) == "TMSA200" .And. DTQ->DTQ_TIPVIA == StrZero(3, Len(DTQ->DTQ_TIPVIA))
									cStatusDT5 := StrZero(5,Len(DT5->DT5_STATUS)) //-- Documento Informado
								EndIf

								RecLock("DT5",.F.)
								DT5->DT5_STATUS := cStatusDT5
								MsUnlock()

							EndIf
						ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .Or. nDudRed > 0 // Viagem Entrega ou documento de Redespacho.
							DT6->( DbSetOrder( 1 ) )
							If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
								RecLock('DT6',.F.)
								DT6->DT6_STATUS := StrZero( 6, Len(DT6->DT6_STATUS) ) // Indicado para Entrega
								MsUnLock()
							EndIf
						EndIf

						//-- Atualiza Gestão de Demandas
						If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
							TmMontaDmd(Iif(cSerie == "COL","1","2"),DUA->DUA_FILDOC,DUA->DUA_DOC,DUA->DUA_SERIE,,.T.,DT2->DT2_TIPOCO,,.F.,.F.)
						EndIf

					ElseIf __lPyme

						DUD->( DbSetOrder( 7 ) )
						If DUD->( DbSeek( xFilial( "DUD" ) + cFilDoc + cDoc + cSerie + cNumRom ) )
							RecLock('DUD', .F. )
							DUD->DUD_STATUS := Tmsa360Doc( cFilOri, cViagem, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE, cNumRom )
							MsUnLock()
						EndIf

						If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + Space(Len(DUD->DUD_NUMROM)) ) )
							lDelDud := .T.
						EndIf
						//-- Exclui novo DUD
						If lDelDud
							RecLock('DUD', .F. )
							DbDelete()
							MsUnLock()
						EndIf
					EndIf

					//Atualiza campo DTC_DOCREE
					If lRet .AND. !Empty(DT6->DT6_FILDCO) .AND. !Empty(DT6->DT6_DOCDCO) //verifica se eh doc de reentrega/devolucao
						If FindFunction("TmsPsqDY4") .And. TmsPsqDY4( DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE ) .AND. lDTCRee
							A360AtuRee(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE, .F./*Estorno de ocorrencia de retorno*/)
						Endif
					EndIf

					If lDUAPrzEnt .And. A360OcoPrz(DT2->DT2_CODOCO)   
						lRet:= A360AtuPrz(GdFieldGet('DUA_FILDOC',nCntFor),GdFieldGet('DUA_DOC',nCntFor),GdFieldGet('DUA_SERIE',nCntFor),cFilOco,cNumOco,GdFieldGet('DUA_SEQOCO',nCntFor),;
						       cFilOri,cViagem)
						If !lRet
							Loop
						EndIf
					EndIf

					//-- 05 - Informativa
				ElseIf DT2->DT2_TIPOCO == StrZero( 5, Len( DT2->DT2_TIPOCO ) ) .And. (!lSinc .Or. lAjusta)

					If lDUAPrzEnt .And. A360OcoPrz(DT2->DT2_CODOCO)   
						lRet:= A360AtuPrz(GdFieldGet('DUA_FILDOC',nCntFor),GdFieldGet('DUA_DOC',nCntFor),GdFieldGet('DUA_SERIE',nCntFor),cFilOco,cNumOco,GdFieldGet('DUA_SEQOCO',nCntFor),;
						       cFilOri,cViagem)
						If !lRet
							Loop
						EndIf
					EndIf

					//-- Se for redespacho, exclui caso nao tenha "Encerra Processo" p/ este Doc.
					DFV->( DbSetOrder( 2 ) )
					If DFV->( DbSeek( xFilial('DFV') + cFilDoc + cDoc + cSerie ) )
						If DFV->DFV_STATUS =StrZero( 3, Len( DFV->DFV_STATUS ) )
							Aviso("Atencao", STR0052 + DFV->DFV_NUMRED + STR0053, {"Ok"})
							Loop
						Else
							//--- MV_TMSRDPU, desativado permanece o modelo antigo da integração
							If !Empty(DFV->DFV_CHVEXT) .And. AllTrim(DT2->DT2_CODOCO) == AllTrim(cOcorBx) .And. DFV->DFV_STATUS =StrZero( 2, Len( DFV->DFV_STATUS ) );
						    .And. (!lTMSRDPU .Or. (lTMSRDPU .And. Empty(cViagem)) ) //Indicado para Entrega
								If !TMA360IGFE(.T.)    //Estorno
									lRet:= .F.
									Loop
								EndIf
							EndIf
						EndIf
					EndIf
					If AllTrim(DT2->DT2_CODOCO) == cOcorCfe
						If Empty(dDatEmb)
							DTQ->(DbSetOrder(2))
							DTQ->(DbSeek(xFilial('DTQ')+cFilOri+cViagem))
							//-- Embarque Aereo
							If DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))
								DVH->(DbSetOrder(1))
								If DVH->(DbSeek(xFilial("DVH")+cFilOri+cViagem+cFilOco+cNumOco))
									dDatEmb := DVH->DVH_DATPAR
									cHorPar := DVH->DVH_HORPAR
									dDatChg := DVH->DVH_DATCHG
									cHorChg := DVH->DVH_HORCHG
									cNumVoo := DVH->DVH_NUMVOO
									RecLock("DVH",.F.)
									dbDelete()
									MsUnLock()

									TMSA360Pre(4,cFilOco,cNumOco,cFilOri,cViagem,dDatEmb,cHorPar,dDatChg,cHorChg,cNumVoo)

								EndIf
							//-- Embarque Fluvial
							ElseIf DTQ->DTQ_TIPTRA == StrZero(3,Len(DTQ->DTQ_TIPTRA))
								DW4->(DbSetOrder(1))
								If DW4->(DbSeek(xFilial("DW4")+cFilOri+cViagem+cFilOco+cNumOco))
									dDatEmb := DW4->DW4_DATSAI
									//-- Apaga complemento de viagem
									DTR->(DbSetOrder(3))
									If DTR->(DbSeek(xFilial("DTR")+cFilOri+cViagem+DW4->DW4_CODVEI))
										RecLock("DTR",.F.)
										dbDelete()
										MsUnLock()
									EndIf
									//-- Apaga confirmacao de embarque
									RecLock("DW4",.F.)
									dbDelete()
									MsUnLock()
								EndIf
							EndIf
						EndIf
						//-- Atualiza data de embarque dos documentos da viagem
						DT6->(DbSetOrder(1))
						If DT6->(DbSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
							RecLock("DT6",.F.)
							DT6->DT6_ULTEMB := Ctod('')
							MsUnLock()
						EndIf
					EndIf

					//-- 06 - Gera pendencia
				ElseIf DT2->DT2_TIPOCO == StrZero( 6, Len( DT2->DT2_TIPOCO ) )
					If lRet
						TM360EPEN(aDocEnc, cFilDoc, cDoc, cSerie, cFilOri, cViagem, cAtivChg, aDoc, nA, lDocEntre,cFilDco,cDocDco,cSerDco,cFilVga,cNumVga)
					EndIf

					//-- Atualiza Gestão de Demandas
					If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
						TmMontaDmd(DT6->DT6_DOCTMS,cFilDoc,cDoc,cSerie,STR0115 + DToC(dDataBase) + " " + Left(Time(),5) + STR0119 + DUA->DUA_FILDOC + "-" + ;
									DUA->DUA_DOC + "/" + DUA->DUA_SERIE + STR0113,.T.,DT2->DT2_TIPOCO,,.F.,.F.)	//-- Planejada ## "Liberação de demanda em " ## " por conta de estorno de pendência do documento " ## " do TMS"
					EndIf

					//-- 07 - Estorna Pendencia.
				ElseIf DT2->DT2_TIPOCO == StrZero( 7, Len( DT2->DT2_TIPOCO ) )
					//-- Estorno nao permitido, o usuario devera registrar a pendencia novamente.

					//-- Atualiza Gestão de Demandas
					If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
						TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,STR0114 + DToC(dDataBase) + " " + Left(Time(),5) + ;
									STR0118 + DUA->DUA_FILDOC + "-" + DUA->DUA_DOC + "/" + DUA->DUA_SERIE + STR0113,.T.,DT2->DT2_TIPOCO,,.F.,.F.)	//-- Bloqueada ## "Demanda bloqueada em " ## " por conta de pendência no documento " ## " do TMS"
					EndIf

					//-- 08 - Estorna Transferencia
				ElseIf DT2->DT2_TIPOCO == StrZero( 8, Len( DT2->DT2_TIPOCO ) )

					If lTMSIntChk	//-- Existe Check List configurado, o estorno é no fechamento da viagem !!

						//-- Estorna documentos do check-list
						EstDocChk( GdFieldGet('DUA_FILVTR', nCntFor) , GdFieldGet('DUA_NUMVTR', nCntFor) , GdFieldGet("DUA_FILDOC", nCntFor) , GdFieldGet("DUA_DOC", nCntFor) , GdFieldGet("DUA_SERIE", nCntFor) ) 
					
					EndIF

					//--Realiza o Estorno do Carregamento automatico por Documentos
					TMS360Crr( 4, GdFieldGet('DUA_FILVTR', nCntFor) , GdFieldGet('DUA_NUMVTR', nCntFor), ;
									GdFieldGet( 'DUA_FILDOC',nCntFor),  GdFieldGet( 'DUA_DOC'   ,nCntFor ), ;
									GdFieldGet( 'DUA_SERIE' ,nCntFor ))

					//-- Retornar o status da viagem
					DTQ->(DbSetOrder(2))
					If	DTQ->(DbSeek(xFilial('DTQ')+M->DUA_FILORI+M->DUA_VIAGEM)) .And.( DTQ->DTQ_STATUS == StrZero( 9, Len( DTQ->DTQ_STATUS ) ) .Or. DTQ->DTQ_STATUS == StrZero( 3, Len( DTQ->DTQ_STATUS ) ) )
						RecLock( "DTQ", .F. )
						DTQ->DTQ_STATUS := MsMM(DTQ->DTQ_CODOBS, Len(DTQ->DTQ_STATUS))
						MsUnLock()
						//-- Posiciona nas operacoes de transporte com status Cancelado.
						DTW->( DbSetOrder( 3 ) )
						If	DTW->( DbSeek( cSeek := xFilial('DTW') + M->DUA_FILORI + M->DUA_VIAGEM + StrZero( 9, Len( DTW->DTW_STATUS ) ) ) )
							While DTW->( DbSeek( cSeek ) )
								RecLock('DTW',.F.)
								DTW->DTW_DATREA := Ctod('')
								DTW->DTW_HORREA := Space( Len( DTW->DTW_HORREA ) )
								DTW->DTW_STATUS := StrZero( 1, Len( DTW->DTW_STATUS ) )	//-- Em Aberto
								DTW->( MsUnLock() )
							EndDo
						EndIf
					EndIf

					// No estorno da viagem de transferencia, somente excluir
					// os documentos transferidos ( DUD_DOCTRF == "1")
					DUD->( DbSetOrder( 1 ) )
					If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilVtr + cNumVtr )) .And. ;
						DUD->( DUD_DOCTRF == StrZero(1, Len(DUD_STATUS) ) )
						RecLock("DUD",.F.)
						DUD->(dbDelete())
						DUD->(MsUnLock())
					EndIf

					If lViagem3
						aArea := GetArea()
						cQueryDM3 := "DELETE "
						cQueryDM3 += "  FROM " + RetSqlName('DM3') + " "
						cQueryDM3 += " WHERE DM3_FILIAL = '" + xFilial("DM3") + "' "
						cQueryDM3 += "   AND DM3_FILDOC = '" + cFilDoc + "' "
						cQueryDM3 += "   AND DM3_DOC    = '" + cDoc + "' "
						cQueryDM3 += "   AND DM3_SERIE  = '" + cSerie + "' "
						cQueryDM3 += "   AND DM3_FILORI = '" + cFilVtr + "' "
						cQueryDM3 += "   AND DM3_VIAGEM = '" + cNumVtr + "' "
						TCSqlExec(cQueryDM3)
						RestArea(aArea)
					EndIf

					If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + M->DUA_FILORI + M->DUA_VIAGEM ))
						If ( DUD->DUD_STATUS == StrZero(9, Len(DUD->DUD_STATUS)) .Or. DUD->DUD_STATUS == StrZero(4, Len(DUD->DUD_STATUS)) ).And. ;
							DUD->DUD_DOCTRF == StrZero(1, Len(DUD->DUD_STATUS))
							RecLock("DUD",.F.)
							DUD->DUD_STATUS := Tmsa360Doc( cFilOri, cViagem, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE )
							DUD->DUD_DOCTRF := StrZero(2, Len(DUD->DUD_DOCTRF)) //-- Nao
							DUD->(MsUnLock())
							// Verifico se:
							// DUD_STATUS <> StrZero(9, Len(DUD->DUD_STATUS)) e
							// Se o documento está associado a outra viagem e
							// Se naquela viagem o DUD_STATUS <> StrZero(9, Len(DUD->DUD_STATUS)) para aplicar o Status 9.
							If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + M->DUA_FILORI ) )
								Do While DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI)== DUD->(xFilial('DUD')+cFilDoc+cDoc+cSerie+M->DUA_FILORI)
									If (DUD->DUD_VIAGEM <> M->DUA_VIAGEM) .AND.;
										DUD->(DUD_STATUS <> StrZero(9, Len(DUD_STATUS))) .AND.;
										RecLock("DUD",.F.)
										DUD->(DBDELETE())
										DUD->(MsUnLock())
									EndIf
									DUD->( DBSKIP() )
								EndDo
							EndIf
						EndIf
					EndIf

					DTR->( DbSetOrder( 1 ) )
					If DTR->( DbSeek( cSeek := xFilial('DTR') + cFilVtr + cNumVtr ) )
						Do While DTR->( !Eof() .And. DTR_FILIAL+DTR_FILORI+DTR_VIAGEM == cSeek )
							If DTR->DTR_REBTRF == StrZero(1 ,Len(DTR->DTR_REBTRF))
								RecLock("DTR", .F.)
								DTR->DTR_CODRB1 := CriaVar("DTR_CODRB1",.F.)
								DTR->DTR_CODRB2 := CriaVar("DTR_CODRB2",.F.)
								DTR->DTR_REBTRF := StrZero(2 ,Len(DTR->DTR_REBTRF)) //-- Nao
								If lTercRbq
									DTR->DTR_CODRB3 := CriaVar("DTR_CODRB3",.F.)
								EndIf
								DTR->(MsUnLock())
							EndIf
							DTR->(dbSkip())
						EndDo
					EndIf

					DUV->( DbSetOrder(1) )
					If DUV->( DbSeek( xFilial("DUV")+M->DUA_FILORI+M->DUA_VIAGEM+M->DUA_FILOCO) )
						RecLock("DUV", .F.)
						DUV->DUV_ODOENT := 0
						DUV->DUV_FILENT := CriaVar("DUV_FILENT", .F.)
						DUV->DUV_DATENT := CriaVar("DUV_DATENT", .F.)
						DUV->(MsUnLock())
					EndIf

					DT6->( DbSetOrder( 1 ) )
					If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
						RecLock('DT6',.F.)
						DT6->DT6_BLQDOC := StrZero( 2, Len( DT6->DT6_BLQDOC ) ) //-- Nao
						DT6->(MsUnLock())
					EndIf

					If lTMSIntChk .And. DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA)) .Or. DTQ->DTQ_TIPTRA == StrZero(4,Len(DTQ->DTQ_TIPTRA)) //-- Existe Check List configurado, o estorno é no fechamento da viagem !! //-- Rodoviario ou Rodoviario Internacional
						//-- Envia documentos do check-list
						EnvDocChk( M->DUA_FILORI , M->DUA_VIAGEM , GdFieldGet("DUA_FILDOC", nCntFor) , GdFieldGet("DUA_DOC", nCntFor) , GdFieldGet("DUA_SERIE", nCntFor) ) 
					EndIf

				//-- 09 - Gera Indenizacao
				ElseIf DT2->DT2_TIPOCO == StrZero( 9, Len( DT2->DT2_TIPOCO ) )
					DT6->( DbSetOrder( 1 ) )
					If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
						lBloqueado:= .F.
						If lMv_TmsPNDB
							lBloqueado:= TM360BLOQ(cFilDoc, cDoc, cSerie)
						EndIf
						If !lBloqueado
							RecLock('DT6',.F.)
							DT6->DT6_BLQDOC := StrZero( 2, Len( DT6->DT6_BLQDOC ) )
							MsUnLock()
						EndIf

						//-- Atualiza Gestão de Demandas
						If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
							TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,STR0115 + DToC(dDataBase) + " " + Left(Time(),5) + ;
										STR0121 + DUA->DUA_FILDOC + "-" + DUA->DUA_DOC + "/" + DUA->DUA_SERIE + STR0113,.T.,DT2->DT2_TIPOCO,,.F.,.F.)	//-- Planejada ## "Liberação de demanda em " ## " por conta de estorno de indenização do documento " ## " do TMS"
						EndIf

						DTQ->( DbSetOrder( 2 ) )
						If	DTQ->( DbSeek( xFilial('DTQ') + M->DUA_FILORI + M->DUA_VIAGEM ) ) .And. DTQ->DTQ_STATUS == StrZero( 9, Len( DTQ->DTQ_STATUS ) )
							//-- Retornar o status da viagem
							RecLock( "DTQ", .F. )
							DTQ->DTQ_STATUS := MsMM(DTQ->DTQ_CODOBS, Len( DTQ->DTQ_STATUS ) )
							MsUnLock()

							//-- Posiciona nas operacoes de transporte com status Cancelado.
							DTW->( DbSetOrder( 3 ) )
							If	DTW->( DbSeek( cSeek := xFilial('DTW') + M->DUA_FILORI + M->DUA_VIAGEM + StrZero( 9, Len( DTW->DTW_STATUS ) ) ) )
								While DTW->( DbSeek( cSeek ) )
									RecLock('DTW',.F.)
									DTW->DTW_DATREA := Ctod('')
									DTW->DTW_HORREA := Space( Len( DTW->DTW_HORREA ) )
									DTW->DTW_STATUS := StrZero( 1, Len( DTW->DTW_STATUS ) )	//-- Em Aberto
									DTW->( MsUnLock() )
								EndDo
							EndIf
						EndIf
						DUB->( DbSetOrder( 3 ) )
						If	DUB->( DbSeek( xFilial( 'DUB' ) + cFilDoc + cDoc + cSerie ) )
							TmsA360DUB( cFilOri, cViagem, cFilDoc, cDoc, cSerie,,,,,,, 5 )
						EndIf

						DUD->( DbSetOrder( 1 ) )
						If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + M->DUA_FILORI + M->DUA_VIAGEM ) ) .And. DUD->DUD_STATUS == StrZero(9, Len(DUD->DUD_STATUS)) // Cancelado
							RecLock("DUD",.F.)
							DUD->DUD_STATUS := Tmsa360Doc( cFilOri, cViagem, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE )
							MsUnLock()
						EndIf
					EndIf

					//-- Caso a viagem ja tenha chegado na filial, executar tmsmovviag para gerar movimento na filial.
					DTW->( DbSetOrder( 4 ) )
					DUD->( DbSetOrder( 1 ) )
					If	DTW->(  DbSeek( xFilial('DTW') + cFilOri + cViagem + cAtivChg + cFilAnt ) ) .And. DTW->DTW_STATUS == StrZero( 2, Len( DTW->DTW_STATUS ) ) .And. ;
						DUD->( !DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt ) )
						TMSMovViag( cFilOri, cViagem, cAtivChg, aDoc, nA, 3 )	//-- Inclui movto viagem e estoque
					EndIf
					//-- 10 - Estorna Indenizacao.
				ElseIf DT2->DT2_TIPOCO == StrZero( 10, Len( DT2->DT2_TIPOCO ) )
					//-- Estorno nao permitido, o usuario devera registrar a pendencia novamente.

					//-- Atualiza Gestão de Demandas
					If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
						TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,STR0114 + DToC(dDataBase) + " " + Left(Time(),5) + ;
									STR0120 + DUA->DUA_FILDOC + "-" + DUA->DUA_DOC + "/" + DUA->DUA_SERIE + STR0113,.T.,DT2->DT2_TIPOCO,,.F.,.F.)	//-- Bloqueada ## "Demanda bloqueada em " ## " por conta de indenização no documento " ## " do TMS"
					EndIf

					//-- 11 - Transferencia de Mercadoria.
				ElseIf DT2->DT2_TIPOCO == StrZero( 11, Len( DT2->DT2_TIPOCO ) )
					aAreaDUD := DUD->( GetArea() )
					DUD->( DbSetOrder(1) )
					DUD->( DbSeek( cSeek := xFilial("DUD") + cFilDoc + cDoc + cSerie + cFilAnt ) )
					While DUD->( !Eof() .And. DUD_FILIAL + DUD_FILDOC + DUD_DOC + DUD_SERIE + DUD_FILORI == cSeek)
						If DUD->DUD_SERTMS == StrZero(2, Len( DUD->DUD_SERTMS ) )
							RecLock("DUD",.F.)
							DUD->DUD_SERTMS := StrZero(3, Len(DUD->DUD_SERTMS)) // Entrega.
							DUD->DUD_STATUS := StrZero(5, Len(DUD->DUD_STATUS)) // Chegada final.
							DUD->(MsUnLock())

							//-- Atualiza Gestão de Demandas
							If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
								TmMontaDmd(DT6->DT6_DOCTMS,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,.T.,DT2->DT2_TIPOCO,,.F.,.F.)
							EndIf

							Exit
						EndIf
						DUD->( dbSkip() )
					EndDo
					RestArea( aAreaDUD )

					//-- 12 - Cancelamento
				ElseIf DT2->DT2_TIPOCO == StrZero( 12, Len( DT2->DT2_TIPOCO ) )

					//-- Retoma Viagem Cancelada.
					If !TMSA360CVge(cFilOri,cViagem,.T.)
						lApaga := .F.
					Else
						//-- Atualiza status do documento
						DUD->( DbSetOrder(1) )
						If DUD->( DbSeek( xFilial("DUD") + cFilDoc + cDoc + cSerie + cFilOri + cViagem ) ) .And. ;
							DUD->DUD_STATUS == StrZero( 9, Len( DUD->DUD_STATUS ) ) // Cancelada

							RecLock("DUD",.F.)
							DUD->DUD_STATUS := Tmsa360Doc( cFilOri, cViagem, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE )
							DUD->(MsUnLock())

							cSerTMS := Posicione("DTQ", 2, xFilial('DTQ')+M->DUA_FILORI+M->DUA_VIAGEM, "DTQ_SERTMS")

							If DTQ->DTQ_SERTMS == StrZero(1, Len(DTQ->DTQ_SERTMS)) .Or. (DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_SERADI == "1")	// Coleta ou Entrega com Serviço Adicional de Coleta
								If DUD->DUD_SERTMS == StrZero(1,Len(DUD->DUD_SERTMS))
									DT5->(DbSetOrder(4))
									If DT5->(DbSeek(xFilial("DT5")+cFilDoc+cDoc+cSerie))
										If DTQ->DTQ_STATUS == StrZero( 5, Len( DTQ->DTQ_STATUS ) )
											cStatus := StrZero( 2, Len( DTQ->DTQ_STATUS ) )
										Else
											cStatus := StrZero( 3, Len( DTQ->DTQ_STATUS ) )
										EndIf
										RecLock("DT5", .F.)
										DT5->DT5_STATUS := cStatus
										DT5->(MsUnLock())
										//-- Carga Fechada - Volta o status do Agendamento para 'Em Processo'.
										If lTmsCFec
											If !Empty(cFilDF0) .And. !Empty(cFilDF1)
												DTC->( DbSetOrder(3) )  // DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE
												If DTC->( DbSeek( xFilial("DTC") + cFilDoc + cDoc + cSerie ) )
													cFilDF1 := DTC->DTC_FILCFS
													cFilDF0 := DTC->DTC_FILCFS
												Else
													DbSelectArea("DY4")
													DY4->( DbSetOrder(1) )  //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
													If DY4->( DbSeek( xFilial("DY4") + cFilDoc + cDoc + cSerie ) )
														DbSelectArea("DTC")
														DTC->( DbSetOrder(2) )  //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto + Fil.Ori + Lote
														If DTC->( DbSeek( xFilial("DTC") + DY4->DY4_NUMNFC + DY4->DY4_SERNFC + DY4->DY4_CLIREM + DY4->DY4_LOJREM + DY4->DY4_CODPRO ) )
															cFilDF1 := DTC->DTC_FILCFS
															cFilDF0 := DTC->DTC_FILCFS
														Else
															cFilDF1 := cFilDoc
															cFilDF0 := cFilDoc
														Endif
													Endif
												Endif
											EndIf

											DF1->(DbSetOrder(3))
											If DF1->(DbSeek(cFilDF1 + cFilDoc + cDoc + cSerie ) )
												RecLock("DF1",.F.)
												If DTQ->DTQ_TIPVIA == StrZero(3,Len(DTQ->DTQ_TIPVIA))
													DF1->DF1_STACOL := StrZero(3,Len(DF1->DF1_STACOL)) //-- Planejado
													DF1->DF1_STAENT := StrZero(3,Len(DF1->DF1_STAENT)) //-- Planejado
												Else
													DF1->DF1_STACOL := StrZero(4,Len(DF1->DF1_STACOL)) //-- Em Processo
													//DF1->DF1_STAENT := StrZero(4,Len(DF1->DF1_STAENT)) //-- Em Processo
													DF1->DF1_STAENT := StrZero(2,Len(DF1->DF1_STAENT)) //-- Confirmado
												EndIf
												MsUnLock()
											EndIf
											DF0->( DbSetOrder(1) )
											If DF0->( DbSeek(cFilDF0 + DF1->DF1_NUMAGE )) .And. DF0->DF0_STATUS <> StrZero(3,Len(DF0->DF0_STATUS ))
												Reclock("DF0",.F.)
												DF0->DF0_STATUS := TMSF05Stat(cFilDF0, DF1->DF1_NUMAGE)
												MsUnLock()
											EndIf
										EndIf
									EndIf
								ElseIf DUD->DUD_SERTMS == StrZero(3, Len(DUD->DUD_SERTMS)) .And.;
									DUD->DUD_TIPTRA == StrZero(2, Len(DUD->DUD_TIPTRA))
									//-- Exclui novo DUD
									If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt + Space(Len(DUD->DUD_VIAGEM)) ) )
										RecLock('DUD', .F. )
										DbDelete()
										MsUnLock()
									EndIf
								EndIf

								If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8") .And. DUD->DUD_SERTMS == StrZero(1,Len(DUD->DUD_SERTMS))
									TmMontaDmd(Iif(DUA->DUA_SERIE == "COL","1","2"),GdFieldGet('DUA_FILDOC', nCntFor),GdFieldGet('DUA_DOC', nCntFor),;
												GdFieldGet('DUA_SERIE', nCntFor),STR0115 + DToC(dDataBase) + " " + Left(Time(),5) + STR0126 + ;
												GdFieldGet('DUA_FILDOC', nCntFor) + "-" + GdFieldGet('DUA_DOC', nCntFor) + "/" + GdFieldGet('DUA_SERIE', nCntFor) + ;
												STR0113,.T.,DT2->DT2_TIPOCO,,.F.,.F.)	//-- Reprocesso ## "Liberação de demanda em " ## " por conta de estorno de cancelamento do documento " ## " do TMS"
								EndIf

							EndIf
						EndIf
					EndIf
					//-- 13 - Estorna Chegada Eventual
				ElseIf DT2->DT2_TIPOCO == StrZero( 13, Len( DT2->DT2_TIPOCO ) )

					// No estorno, excluir somente os documentos transferidos ( DUD_DOCTRF == "1")
					DUD->( DbSetOrder( 1 ) )
					If DUD->( DbSeek( cSeekDUD := xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt )) //-- Os Documentos em Aberto, estão com viagem em Branco
					Do While !DUD->(Eof()) .And. DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI ) == cSeekDUD
						If DUD->DUD_STATUS == StrZero(1, Len(DUD->DUD_STATUS))  .And. 	DUD->DUD_DOCTRF == StrZero(1, Len(DUD->DUD_DOCTRF) )
								RecLock("DUD",.F.)
								DUD->(dbDelete())
								DUD->(MsUnLock())
							EndIf
							DUD->(dbSkip())
						EndDo
					EndIf

					If DUD->( DbSeek( cSeekDUD := xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilOri + cViagem ))
					Do While !DUD->(Eof()) .And. DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM) == cSeekDUD
							If DUD->DUD_STATUS == StrZero(9, Len(DUD->DUD_STATUS)) .And. DUD->DUD_DOCTRF == StrZero(1, Len(DUD->DUD_DOCTRF))
								RecLock("DUD",.F.)
								DUD->DUD_STATUS := StrZero(2, Len(DUD->DUD_STATUS)) //-- Em Transito
								DUD->DUD_DOCTRF := StrZero(2, Len(DUD->DUD_DOCTRF)) //-- Nao
								DUD->(MsUnLock())
							EndIf
							DUD->(dbSkip())
						EndDo
					EndIf

					//-- Atualiza Gestão de Demandas (Estorno de chegada eventual)
					If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
						TmMontaDmd(Iif(cSerie == "COL","1","2"),DUA->DUA_FILDOC,DUA->DUA_DOC,DUA->DUA_SERIE,,.T.,DT2->DT2_TIPOCO,,.F.,.F.)
					EndIf

					//-- 14 - Ajusta previsao de chegada da viagem na filial
				ElseIf DT2->DT2_TIPOCO == StrZero(14, Len(DT2->DT2_TIPOCO))
					If	!TMA360PrvAju(cFilOri,cViagem)
						lApaga := .F.
						Help('',1,'TMSA36083') //"Não é permitido estornar esta ocorrencia! Não existe operação de chegada na filial em aberto."
					EndIf


				ElseIf DT2->DT2_TIPOCO == StrZero( 17, Len( DT2->DT2_TIPOCO ) )

					//-- Exclusão de Acréscimos/Decréscimos
					lApaga	:= TMSA360DDN( .F. , cFilOri , cViagem , cFilOco, cNumOco , GDFieldGet( 'DUA_SEQOCO', nCntFor ), 0 , DT2->DT2_CODAED )

				ElseIf DT2->DT2_TIPOCO == StrZero( 21, Len( DT2->DT2_TIPOCO ) )

					//Estorna a ocorrencia tipo de encerra processo
					aAreaDUA2  := DUA->(GetArea())
					DUA->(dbSetOrder(4)) //DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SERIE+DUA_FILORI+DUA_VIAGEM
					If 	DUA->(dbSeek(cSeek:=xFilial('DUA')+cFilDoc+cDoc+cSerie))
						While !DUA->(Eof()) .And. DUA->(DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SERIE) == cSeek

							// Encerra Processo
							If Posicione("DT2",1,xFilial('DT2') + DUA->DUA_CODOCO ,"DT2_TIPOCO") == StrZero( 1, Len( DT2->DT2_TIPOCO ) )
								lAchou := .T.
								Exit
							EndIf

							DUA->(dbSkip())
						EndDo

						If lAchou
							//-- Cabecalho da Ocorrencia
							AAdd( aCab, {"DUA_FILOCO", DUA->DUA_FILOCO, Nil} )
							AAdd( aCab, {"DUA_NUMOCO", DUA->DUA_NUMOCO, Nil} )
							AAdd( aCab, {"DUA_FILORI", DUA->DUA_FILORI, Nil} )
							AAdd( aCab, {"DUA_VIAGEM", DUA->DUA_VIAGEM, Nil} )

							//-- Itens da Ocorrencia
							AAdd(aItens,{	{"DUA_SEQOCO", DUA->DUA_SEQOCO , Nil},;
											{"DUA_ESTOCO", StrZero( 1, TamSX3('DUA_ESTOCO')[1]), Nil},;
											{"DUA_DATOCO", DUA->DUA_DATOCO , Nil},;
											{"DUA_HOROCO", DUA->DUA_HOROCO , Nil},;
											{"DUA_CODOCO", DUA->DUA_CODOCO , Nil},;
											{"DUA_SERTMS", DUA->DUA_SERTMS , Nil},;
											{"DUA_FILDOC", DUA->DUA_FILDOC , Nil},;
											{"DUA_DOC"   , DUA->DUA_DOC    , Nil},;
											{"DUA_SERIE" , DUA->DUA_SERIE  , Nil},;
											{"DUA_QTDOCO", DUA->DUA_QTDOCO , Nil},;
											{"DUA_PESOCO", DUA->DUA_PESOCO , Nil}})


							lRet := A360GrvThd(aCab, aItens, {}, 6)
						EndIf

					EndIf
					RestArea(aAreaDUA2)
				EndIf

				If lApaga
					//-- Verifica se existe NF com Avarias
					DV4->(DbSetOrder(1))
					DV4->(DbSeek(cSeek:=xFilial('DV4')+M->DUA_FILOCO+M->DUA_NUMOCO+cFilDoc+cDoc+cSerie))
					Do While !DV4->(Eof()) .And. DV4->(DV4_FILIAL+DV4_FILOCO+DV4_NUMOCO+DV4_FILDOC+DV4_DOC+DV4_SERIE) == cSeek
						RecLock('DV4', .F.)
						DV4->(dbDelete())
						MsUnLock()
						DV4->(dbSkip())
					EndDo

					//-- Confirmacao de Embarque para Viagem Aerea
					DVH->( DbSetOrder( 1 ) )
					DVH->( DbSeek(cSeek:=xFilial('DVH') + cFilOri + cViagem + cFilOco + cNumOco ))
					Do While !DVH->(Eof()) .And. DVH->(DVH_FILIAL+DVH_FILORI+DVH_VIAGEM+DVH_FILOCO+DVH_NUMOCO) == cSeek
						RecLock('DVH', .F.)
						dDatEmb := DVH->DVH_DATPAR
						cHorPar := DVH->DVH_HORPAR
						dDatChg := DVH->DVH_DATCHG
						cHorChg := DVH->DVH_HORCHG
						cNumVoo := DVH->DVH_NUMVOO
						DVH->(dbDelete())
						MsUnLock()
						DVH->(dbSkip())
						//-- Pre Alerta

						TMSA360Pre(4,cFilOco,cNumOco,cFilOri,cViagem,dDatEmb,cHorPar,dDatChg,cHorChg,cNumVoo)

					EndDo

					//-----------------------------------------------------------------------------------------------
					//-- Inicio - Tratamento Valorização Da Coleta <<<(Estorno)>>>
					//-----------------------------------------------------------------------------------------------
					//-- 4 = RETORNA COLETA ; 12 = CANCELAMENTO DE COLETA
					If DT2->DT2_TIPOCO == StrZero(4, Len(DT2->DT2_TIPOCO)) .Or. DT2->DT2_TIPOCO == StrZero(12, Len(DT2->DT2_TIPOCO))

						//-- Determina o Serviço TMS Pelo DT2
						cSerTMS := Posicione( 'DT2', 1, xFilial('DT2') + GDFieldGet( 'DUA_CODOCO', nCntFor ), 'DT2_SERTMS' )

						//-- Coleta
						If cSerTMS == StrZero(1, Len(DTQ->DTQ_SERTMS))

							//-- Posiciona Na Solicitação De Coleta
							DbSelectArea("DT5")
							DT5->(DbSetOrder( 4 )) //-- DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE
							MsSeek( FWxFilial('DT5') + cFilDoc + cDoc + cSerie , .f. )

							//-- Valoriza Coleta Não Efetivada '1' = SIM; '2' = NAO
							cValCol := TmsSobServ('VALCOL',,.T.,DT5->DT5_NCONTR,DT5->DT5_CODNEG,DT5->DT5_SERVIC,"0", Nil )

							//-- Não Valoriza Coleta Não Efetivada
							If cValCol == '2'

								aInfDJI := {} //-- Inicializa Variável
								aAdd( aInfDJI, {'DJI_FILDOC'	, DT5->DT5_FILDOC })
								aAdd( aInfDJI, {'DJI_DOC'		, DT5->DT5_DOC    })
								aAdd( aInfDJI, {'DJI_SERIE'		, DT5->DT5_SERIE  })

								//-- 01 - Altera o Status Do DJI De Cancelado Para Previsto
								//-- 02 - Recria DT8 Conforme DJI
								//-- 03 - Refaz Valorização Dos Dados Da Tabela DT6 Conforme Gravação DJI
								TmsAtuDJI( cFilOri, cViagem, Nil, '5', aInfDJI, .f. )

							EndIf
						EndIf
					EndIf
					//-----------------------------------------------------------------------------------------------
					//-- Fim - Tratamento Valorização Da Coleta
					//-----------------------------------------------------------------------------------------------

					DUA->( DbSetOrder( 1 ) )
					If	DUA->( DbSeek( xFilial('DUA') + cFilOco + cNumOco + cFilOri + cViagem + GDFieldGet('DUA_SEQOCO', nCntFor ), .F. ) )
						//-- Exclui documento de armazenagem
						DT6->( DbSetOrder( 8 ) )
						DT6->( DbSeek(cSeek:=xFilial('DT6') + DUA->(DUA_FILDOC + DUA_DOC + DUA_SERIE) ))
						While !DT6->(Eof()) .And. DT6->(DT6_FILIAL + DT6_FILDCO + DT6_DOCDCO + DT6_SERDCO) == cSeek
							If DT6->DT6_DOCTMS $ "EF"
								If lTm360Armz
									l360ARMZ := ExecBlock("TM360ARMZ",.F.,.F.)
									If ValType(l360ARMZ) <> 'L'
										l360ARMZ := .T.
									EndIf
								Endif
								If l360ARMZ
									TmsA500(.F.,Replicate("9",Len(DTP->DTP_LOTNFC)),6)
								EndIf
							EndIf
							DT6->(dbSkip())
						EndDo
						RecLock('DUA',.F.)
						DUA->( DbDelete() )
						MsUnLock()
					EndIf
				EndIf

			Next

			// Se não houver Doc e Viagem for Vazia
			DTQ->( DbSetOrder( 2 ) )
			If DTQ->( DbSeek( xFilial('DTQ') + cFilOri + cViagem ) ) .AND. Len(aDoc) == 0 .AND. DTQ->DTQ_TIPVIA == '2'
				DUA->( DbSetOrder( 1 ) )
				If DUA->( DbSeek( xFilial('DUA') + cFilOco + cNumOco + cFilOri + cViagem + GDFieldGet('DUA_SEQOCO', nCntFor ), .F. ) )
					RecLock( 'DUA', .F. )
						DUA->( DbDelete() )
					DUA->( MsUnLock() )
				EndIf
			EndIf

			//-- Exclusao de Sobras e Faltas
			If lSobra .Or. lFalta
				DYM->(DbSetOrder(1))
				DYM->(DbSeek(cSeek:=xFilial('DYM')+ cFilPnd+cNumPnd))
				Do While !DYM->(Eof()) .And. DYM->(DYM_FILIAL+DYM_FILPND+DYM_NUMPND) == cSeek
					RecLock('DYM', .F.)
					DYM->(dbDelete())
					MsUnLock()
					DYM->(dbSkip())
				EndDo
				DYZ->(DbSetOrder(1))
				DYZ->(DbSeek(cSeek:=xFilial('DYZ')+cFilPnd+cNumPnd))
				Do While !DYZ->(Eof()) .And. DYZ->(DYZ_FILIAL+DYZ_FILPND+DYZ_NUMPND) == cSeek
					RecLock('DYZ', .F.)
					DYZ->(dbDelete())
					MsUnLock()
					DYZ->(dbSkip())
				EndDo
			EndIf
			//-- Exclui pendencia de sobra sem documento.
			If lSobra .And. Empty(cDoc)
				DUA->( DbSetOrder( 1 ) )
				If	DUA->( DbSeek( xFilial('DUA') + cFilOco + cNumOco + cFilOri + cViagem + GDFieldGet('DUA_SEQOCO', nCntFor ), .F. ) )
					RecLock('DUA',.F.)
					DUA->( DbDelete() )
					MsUnLock()
					DUU->(DbSetOrder(1))
					If	DUU->(DbSeek(xFilial('DUU')+DUA->DUA_FILPND+DUA->DUA_NUMPND))
						If DUU->DUU_STATUS == StrZero(1,Len(DUU->DUU_STATUS))
							RecLock('DUU',.F.)
							DUU->(DbDelete())
							MsUnLock()
						EndIf
					EndIf
				EndIf
			EndIf

			// Exclui a chave de integração com o GFE --> GWU_CHVEXT
			If  GWU->(ColumnPos("GWU_CHVEXT")) > 0
				dbSelectArea("GWU")
				GWU->(dbSetOrder(9))
				If GWU->( dbSeek(FwxFilial("GWU")+M->DUA_NUMOCO + GDFieldGet('DUA_SEQOCO', nCntFor ) ) )
					RecLock("GWU",.F.)
					GWU->GWU_CHVEXT  :=  CriaVar("GWU_CHVEXT", .F.)
					GWU->(MsUnLock())
				EndIf
			EndIf

		EndIf
		If lTM360EST	//-- Pto de Entrada no Estorno de Ocorrencia, linha a linha de Doc.
			ExecBlock("TM360EST",.F.,.F.,{cFilOco, cNumOco, cFilOri, cViagem })
		EndIf
	EndIf
Next

RestArea( aAreaDT6 )
RestArea( aAreaDUM )
RestArea( aAreaDT5 )
RestArea( aAreaDUA )
RestArea( aAreaDTQ )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360Rel    ³ Autor ³ Patricia A. Salomao  ³ Data ³28.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³X3_RELACAO do Campo DUA_DESOCO                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA360Rel()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Descricao da Ocorrencia                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360Rel()

Local cDescri    := ''
Local nPosCodOco := 0
Local nX         := 0

If FunName() == 'TMSA360'
	nPosCodOco := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DUA_CODOCO' })
	nX         := IIf(Type('n') <> 'U', n , 0)

	If !Inclui
		cDescri := Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI")
	Else
		If Len(aCols) >= nX  .And. nX > 0 .And. ValType(aCols[nX][nPosCodOco]) <> 'U'
			cDescri := Posicione("DT2",1,xFilial("DT2")+GdFieldGet("DUA_CODOCO",nX),"DT2_DESCRI")
		EndIf
	EndIf
Else
	cDescri := Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI")
EndIf

Return( cDescri )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360NF     ³ Autor ³ Patricia A. Salomao  ³ Data ³21.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Se o Tipo de Ocorrencia Informada for "Gera Pendencia",monta Te³±±
±±³          ³la contendo as Notas Fiscais dos Documentos digitados, para que³±±
±±³          ³sejam Informadas as Qtdes. Avariadas.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA360NF(ExpC1, ExpC2, ExpN1, ExpL1)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Fil. Ocorrencia                                        ³±±
±±³          ³ExpC2 - Num. Ocorrencia                                        ³±±
±±³          ³ExpN1 - Opcao Selecionada                                      ³±±
±±³          ³ExpL1 - Rot.automatica para gerar qtde avariada - Bloqueio     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360NF(cFilOco, cNumOco, nOpcx, cTipoPnd, lRotAut, lPutQtd, cTipOco)

Local nx
Local oGetD, oDlgEsp
Local oSize
Local nCntFor
Local cCadOld      := cCadastro
Local aColsBack    := AClone(aCols)
Local aHeaderBack  := AClone(aHeader)
Local cFilDoc      := GdFieldGet('DUA_FILDOC', n)
Local cDoc         := GdFieldGet('DUA_DOC'   , n)
Local cSerie       := GdFieldGet('DUA_SERIE' , n)
Local cCodOco      := GdFieldGet('DUA_CODOCO', n)
Local cFilPnd      := GdFieldGet('DUA_FILPND', n)
Local cNumPnd      := GdFieldGet('DUA_NUMPND', n)
Local nPosDV4	   := 0
Local nPosOcor     := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DUA_CODOCO' } )
Local nPosFilDoc   := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DUA_FILDOC' } )
Local nPosDoc      := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DUA_DOC'    } )
Local nPosSerie    := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DUA_SERIE'  } )
Local nOpca        := 0
Local nSavN        := n
Local bSavKeyF4    := SetKey(VK_F4,Nil)
Local lRet         := .T.
Local aNF		   := {}
Local nTotalVol	   := 0
Local nTotalPes	   := 0
Local lTpPend04    := .F.
Local lTpPend99		:= .F.
Local aAlter		:= {}
Local lExNF			:= .T.
Local lDTCEntr		:= .T. //-- DTC_NFENTR - 1=Entregue;2=Nao Entregue;3=Bloqueada
Local aArea    		:= GetArea()
Local l360AutoOld	:= .F.
Local cSeekDTC		:= ""
Local cSeekDV4		:= ""
Local lDocRee	 	:= SuperGetMV('MV_DOCREE',,.F.) .And. TMSChkVer('11','R7')
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes do parametro "MV_TMSCOSB" :                    		 	                    ³
//³ 0 = Não Utiliza. Neste caso, nao será apresentado a tela de Identificação de Produto³
//³ 1 = Obrigatorio informar a identificacao do produto                                 ³
//³ 2 = Nao Obrigatorio informar a identificao do produto                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cTMSCOSB	:= SuperGetMV('MV_TMSCOSB',,'0')
Local cCampoDV4	:= Iif(cTMSCOSB<>'0' .And. nOpcx <> 2,"DV4_NUMNFC.DV4_SERNFC.DV4_QTDVOL.DV4_QTDPND.DV4_IDPRD ","DV4_NUMNFC.DV4_SERNFC.DV4_QTDVOL.DV4_QTDPND")

Local aButtons  := {}
Local aAreaDUU  := {}
Local lFaltDesc := .F.
Local nCont     := 0
Local aFldDV4   := {}
Local oMark, lMark

Local nOpcxBak := 0
Local lRetLoop := .F.

Private cCampo		:= ReadVar()
Private nQtdOco		:= 0

Default nOpcx		:= 3
Default cTipoPnd	:= ""
Default lRotAut		:= .F.
Default lPutQtd     := .F.

If lAjusta
	nOpcxBak := nOpcx
	nOpcx    := 3
EndIf

If nOpcx == 2
	AAdd(aButtons, {'IDPROD', {|| TMSA360SF(cFilOco, cNumOco, 2, cFilPnd, cNumPnd, Iif(Len(aNFAvaria)>0,.T.,.F.) ) }, STR0078 , STR0086 }) //"Id.Produto"
ElseIf nOpcx == 3
	AAdd(aButtons, {'IDPROD', {|| TMSA360SF()} , STR0078, STR0086}) //"Id.Produto"
EndIf

AAdd(aButtons,	{'VISCON', {|| TMSA540CON(,,,GdFieldGet('DV4_NUMNFC', n),GdFieldGet('DV4_SERNFC', n) )}, STR0087 , STR0087 }) //"Vis.Conciliação"

If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc,cDoc,cSerie)
	//-- Pocisionando na DTC para verificar campo DTC_NFENTR
	DTC->(DbSetOrder(3))
	If ( DTC->(DbSeek(xFilial('DTC')+cFilDoc+cDoc+cSerie)) )
		If(DTC->DTC_NFENTR == "2")
			lDTCEntr := .F.
		EndIf
		RestArea(aArea)
	EndIf
Else
	DbSelectArea("DY4")
	DY4->( DbSetOrder(1) )  //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
	If DY4->( DbSeek( xFilial("DY4") + cFilDoc + cDoc + cSerie ) )
		DbSelectArea("DTC")
		DTC->( DbSetOrder(2) )  //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto + Fil.Ori + Lote
		//-- Pocisionando na DTC a partir da DY4 para verificar campo DTC_NFENTR
		If DTC->( DbSeek( xFilial("DTC") + DY4->DY4_NUMNFC + DY4->DY4_SERNFC + DY4->DY4_CLIREM + DY4->DY4_LOJREM + DY4->DY4_CODPRO ) )
			If(DTC->DTC_NFENTR == "2")
				lDTCEntr := .F.
			EndIf
			RestArea(aArea)
		EndIf
	EndIf
Endif


	nPosDV4	    := Ascan(aNFAvaria,{ |x| x[1] == cFilDoc+cDoc+cSerie })


If nPosDV4 > 0 .And. nOpcx != 2
	lExNF        := IIF(nPosDV4>0,aNFAvaria[nPosDV4][4] == aColsBack[nSavN][nPosOcor],.F.)
Else
	nPosDV4	    := Ascan(aNFAvaria,{ |x| x[1] == cFilDoc+cDoc+cSerie })
EndIf

lTpPend04:= (cTipoPnd == "04" .Or. cTipOco == "19" .Or. cTipOco == "20")  //Retorna Docto, Cobrança de Entrega, Cobrança de Retorno
lTpPend99:= (cTipOco == "06" .Or. cTipoPnd == "99")

l360Auto   := If (Type("l360Auto") == "U",.F.,l360Auto)
l360AutoOld:= l360Auto

If lRotAut .And. lTpPend99
	l360Auto   := .T.
EndIf
If !lTpPend04
	AAdd(aAlter,"DV4_QTDPND")
	If cTMSCOSB <> '0'
		AAdd(aAlter,"DV4_IDPRD ")
	EndIf
EndIf

If Empty(cFilDoc) .Or. Empty(cDoc) .Or. Empty(cSerie)
	Return( .F. )
EndIf

// Verif. se a funcao esta sendo chamada pelo Registro de Ocorrencias
If ReadVar() == 'M->DUA_QTDOCO'
	nQtdOco := M->DUA_QTDOCO
EndIf

cCadastro := STR0023 //"Notas Fiscais"
n         := 1
aCols     := {}
aHeader   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aHeaderDV4) == 0
	aFldDV4 := ApBuildHeader("DV4")
	For nCont := 1 To Len(aFldDV4)
		If aFldDV4[nCont][2] $ cCampoDV4
			aAdd(aHeader, aFldDV4[nCont])
		EndIf
	Next nCont
	aHeaderDV4 := Aclone(aHeader)
Else
	aHeader := Aclone(aHeaderDV4)
EndIf

If nPosDV4 > 0 .And. lExNF
	aCols	:= aClone(aNFAvaria[nPosDV4][2])
	If nOpcx == 3
		aNF   := aClone(aNFAvaria[nPosDV4][3])
	EndIf
Else
	If nPosDV4 > 0	.And. !lExNF
		aDel(aNFAvaria,nPosDV4)
		aSize(aNFAvaria,Len(aNFAvaria)-1)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem de uma linha em branco no aCols.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcx == 3
		DT6->(DbSetOrder(1))
		If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc,cDoc,cSerie)
			cTable		:= "DTC"
			cSeekDTC	:= xFilial('DTC')+cFilDoc+cDoc+cSerie
			bWhile		:= {|| !DTC->(Eof()).And. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) == cSeekDTC  }
		Else
			cTable := "DY4"
			cSeekDTC := xFilial('DY4')+cFilDoc+cDoc+cSerie
			bWhile		:= {|| !DY4->(Eof()).And. DY4->(DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE) == cSeekDTC  }
		Endif

		If cTable == "DTC"
			DTC->(DbSetOrder(3))
			If DTC->(DbSeek(cSeekDTC))
				lRetLoop := .T.
			Else
				AAdd(aCols,Array(Len(aHeader)+1))
				For nCntFor := 1 to Len(aHeader)
					aCols[1][nCntFor] := CriaVar(aHeader[nCntFor][2])
					aCols[1][Len(aHeader)+1] := Iif(lAjusta .And. nRecursivo > 0,.F.,lTpPend04)
				Next nCntFor
			EndIf
		Else
			If cTable == "DY4"
				DbSelectArea("DY4")
				DY4->(DbSetOrder(1)) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
				If DY4->( dbSeek( FwxFilial("DY4")+ cFilDoc + cDoc + cSerie ) )
					lRetLoop := .T.
				Else
					AAdd(aCols,Array(Len(aHeader)+1))
					For nCntFor := 1 to Len(aHeader)
						aCols[1][nCntFor] := CriaVar(aHeader[nCntFor][2])
						aCols[1][Len(aHeader)+1] := Iif(lAjusta .And. nRecursivo > 0,.F.,lTpPend04)
					Next nCntFor
				Endif
			Endif
		Endif

		If lRetLoop
			While(Eval(bWhile))
				If lDTCEntr  //-- permite ocorr retorno para reentrega
					If lTpPend04 .And. ( DTC->DTC_NFENTR <> "2" .And. !Empty(DTC->DTC_NFENTR) ).And. nOpcx == 3 .And. !lDocRee
						If cTable == "DTC"
							DTC->(dbSkip())
						Else
							DY4->(dbSkip())
						Endif
						Loop
					EndIf
				EndIf

				If cTable == "DY4"
					DbSelectArea("DTC")
					DTC->( DbSetOrder(2) )  //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto + Fil.Ori + Lote
					DTC->( DbSeek( xFilial("DTC") + DY4->DY4_NUMNFC + DY4->DY4_SERNFC + DY4->DY4_CLIREM + DY4->DY4_LOJREM + DY4->DY4_CODPRO ) )
				Endif

				nPosNota 	:= Ascan(acols,{|x| x[1]+x[2] = DTC->DTC_NUMNFC +  DTC->DTC_SERNFC })
				If nPosNota == 0
					AAdd(aCols,Array(Len(aHeader)+1))
					GdFieldPut('DV4_NUMNFC', DTC->DTC_NUMNFC , Len(aCols) )
					GdFieldPut('DV4_SERNFC', DTC->DTC_SERNFC , Len(aCols) )
					GdFieldPut('DV4_QTDVOL', DTC->DTC_QTDVOL , Len(aCols) )
					If !lTpPend04
						If lTpPend99 .And. l360Auto
							GdFieldPut('DV4_QTDPND', DTC->DTC_QTDVOL , Len(aCols) )
						Else
							GdFieldPut('DV4_QTDPND', 0               , Len(aCols) )
						EndIf
					Else
						GdFieldPut('DV4_QTDPND', DTC->DTC_QTDVOL , Len(aCols) )
					EndIf
					//-- Verifica saldo das NFs
					cSeekDV4 := xFilial('DV4')+DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE + DTC->DTC_NUMNFC + DTC->DTC_SERNFC
					DV4->(DbSetOrder(3))
					If (DV4->(DbSeek(cSeekDV4)) )
						While !DV4->(Eof()) .And. DV4->(xFilial('DV4')+DV4_FILOCO + DV4_DOC + DV4_SERIE + DV4_NUMNFC + DV4_SERNFC) == cSeekDV4
							DUU->(DbSetOrder(1))

							If T360QTDPND(DV4->DV4_FILPND, DV4->DV4_NUMPND, DTC->DTC_FILDOC, DTC->DTC_DOC, DTC->DTC_SERIE)
								//-- Reduz do saldo a quantidade pendente
								aCols[1][4] := aCols[1][4] - DV4->DV4_QTDPND
							EndIf
							DV4->(dbSkip())
						EndDo

					EndIf
					If cTMSCOSB <> '0'
						GdFieldPut('DV4_IDPRD ', '<< Enter >>', Len(aCols) )
					EndIf

					aCols[Len(aCols),Len(aHeader)+1]:= Iif(lAjusta .And. nRecursivo > 0,.F.,lTpPend04)
					AAdd(aNF,{DTC->DTC_NUMNFC,(DTC->DTC_PESO/DTC->DTC_QTDVOL)})
				Else
					If lTpPend04
						aCols[nPosNota, Ascan(aHeader,{ |x| AllTrim(x[2]) == 'DV4_QTDVOL'  }) ] += DTC->DTC_QTDVOL

						//Tentar descontar a Quantidade apontada na Ocorrencia de Falta, do volume original
						//da primeira Nota Fiscal possivel. Caso o volume original da Nota Fiscal seja menor
						//que a quantidade apontada na falta, deixar para tentar descontar na proxima Nota Fiscal.
						//Quando descontar, setar a FLAG para TRUE, de modo que o desconto nao seja efetuado novamente.
						If !lFaltDesc
							aAreaDUU  := DUU->( GetArea() )
							DUU->(DbSetOrder(3))
							If DUU->(MsSeek(xFilial('DUU')+cFilDoc+cDoc+cSerie+StrZero(1, Len(DUU->DUU_STATUS))))
								Do While DUU->(!EoF()) .And. xFilial('DUU')+cFilDoc+cDoc+cSerie+StrZero(1, Len(DUU->DUU_STATUS)) == DUU->DUU_FILIAL+DUU->DUU_FILDOC+DUU->DUU_DOC+DUU->DUU_SERIE+StrZero(1, Len(DUU->DUU_STATUS))
								    //Verifica se eh pendencia de Falta, e se o volume da NF corrente eh maior que a quantidade apontada na Falta.
								    //Se for, desconta do volume da NF e seta a FLAG para nao descontar de outra NF.
								    If DUU->DUU_TIPPND == '01' .And. DTC->DTC_QTDVOL > DUU->DUU_QTDOCO
							    	   aCols[nPosNota, Ascan(aHeader,{ |x| AllTrim(x[2]) == 'DV4_QTDPND'  }) ] += (DTC->DTC_QTDVOL - DUU->DUU_QTDOCO)
							    	   lFaltDesc := .T.
								    EndIf
								DUU->(dbSkip())
								Enddo
							EndIf
							RestArea( aAreaDUU )
							If !lFaltDesc
								aCols[nPosNota, Ascan(aHeader,{ |x| AllTrim(x[2]) == 'DV4_QTDPND'  }) ] += DTC->DTC_QTDVOL
							EndIf
						Else
							aCols[nPosNota, Ascan(aHeader,{ |x| AllTrim(x[2]) == 'DV4_QTDPND'  }) ] += DTC->DTC_QTDVOL
						EndIf
					Else
						aCols[nPosNota, Ascan(aHeader,{ |x| AllTrim(x[2]) == 'DV4_QTDVOL'  }) ] += DTC->DTC_QTDVOL
					EndIf
				EndIf

				If cTable == "DTC"
					DTC->(dbSkip())
				Else
					DY4->(dbSkip())
				Endif

			EndDo
		EndIf
	EndIf
EndIf

If !l360Auto

	oSize := FWDefSize():New(.T.,,,oDlgEsp) //passa para FWDefSize a dialog usada para calcular corretamente as proporções dos objetos
	oSize:lLateral     := .F.  // Calculo vertical

	// adiciona Enchoice
	oSize:AddObject( "GRID", 100, 10, .T., .T. ) // Adiciona enchoice

	// Dispara o calculo
	oSize:Process()

	//define o tamanho da dialog
	DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL //310

	//-- Marcar/Desmarcar todos.
	lMark := .F.
	@ oSize:GetDimension("ENCHOICE","LININI") + 35 ,005 CHECKBOX oMark VAR lMark PROMPT STR0109 SIZE 168, 08; //-- "Selecionar todos"
	ON CLICK(aEval(aCols,{|x| x[Len(aHeader)+1] := !lMark}),oGetD:oBrowse:Refresh(.T.)) OF oDlgEsp PIXEL

	oGetD := MSGetDados():New(oSize:GetDimension("ENCHOICE","LININI") + 45 , oSize:GetDimension("GRID","COLINI"), oSize:GetDimension("GRID","LINEND" ), oSize:GetDimension("GRID","COLEND"),If(nOpcx<>3, 2, nOpcx) ,'TMSA360NFLin','AllwaysTrue()',,.T./*lTpPend04*/,aAlter)

	oGetD:oBrowse:bAdd:={|| .F. }

	ACTIVATE MSDIALOG oDlgEsp CENTERED ON INIT EnchoiceBar(oDlgEsp,{||nOpca:=1, IIf(TMSA360NFTOk(,cCodOco,nOpcx),oDlgEsp:End(),nOpca := 0)},{||oDlgEsp:End()},,aButtons)
	If nOpcx == 3
		For nX:=1 to Len(aCols)
			If !GdDeleted(nX)
				If lTpPend04 .Or. lTpPend99
					nTotalVol += GdFieldGet('DV4_QTDPND',nX)
					nTotalPes += GdFieldGet('DV4_QTDPND',nX) * Iif(Len(aNF) > 0, aNF[nX,2], 0)
				Else
					nTotalVol += GdFieldGet('DV4_QTDVOL',nX)
					nTotalPes += GdFieldGet('DV4_QTDVOL',nX) * Iif(Len(aNF) > 0, aNF[nX,2], 0)
				EndIf
			EndIf
		Next
	EndIf
Else
	//-- Se For Rotina Automatica, executa a Funcao de LinhaOk() e TudoOK(),
	//-- para validar os dados passados pela Rotina Automatica
	For nx:=1 to Len(aCols)
		lRet:=TMSA360NFLin() .And. TMSA360NFTOk(nx,cCodOco,nOpcx)
		If !lRet
			Exit
		EndIf
	Next nx
	If lRet
		nOpca := 1
	EndIf
EndIf

If nOpca == 1 .And. nOpcx <> 2 .And.(lTpPend04 .Or. lTpPend99)
	If nPosDV4 > 0 .And. lExNF
		aNFAvaria[nPosDV4][2]	:= aClone(aCols)
		aNFAvaria[nPosDV4][3]	:= aClone(aNF)
	Else
		AAdd(aNFAvaria,{aColsBack[nSavN][nPosFilDoc]+aColsBack[nSavN][nPosDoc]+aColsBack[nSavN][nPosSerie],aClone(aCols),aClone(aNF),aColsBack[nSavN][nPosOcor],cTipoPnd,AllTrim(Str(nSavN)) })
	EndIf
EndIf

n         := nSavN
cCadastro := cCadOld
aCols     := AClone(aColsBack)
aHeader   := AClone(aHeaderBack)
SetKey(VK_F4,bSavKeyF4)
If !l360Auto .And. nOpca == 1
	Acols[n][ Ascan(aHeader, { |x| AllTrim(x[2]) == 'DUA_QTDOCO' } ) ] := nTotalVol
	Acols[n][ Ascan(aHeader, { |x| AllTrim(x[2]) == 'DUA_PESOCO' } ) ] := nTotalPes
ElseIf !l360Auto .And. nOpca == 0
	Acols[n][ Ascan(aHeader, { |x| AllTrim(x[2]) == 'DUA_QTDOCO' } ) ] := 0
	M->DUA_QTDOCO := 0
	Acols[n][ Ascan(aHeader, { |x| AllTrim(x[2]) == 'DUA_PESOCO' } ) ] := 0
	M->DUA_PESOCO := 0
EndIf

l360Auto:= l360AutoOld

If lAjusta
	nOpcx := nOpcxBak
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360NFLin  ³ Autor ³ Patricia A. Salomao  ³ Data ³21.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao da Linha digitada na GetDados de NF c/ Avarias       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA360NFLin()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360NFLin()

Local lRet := .T.

If !GDdeleted( n )
	//-- Verifica campos obrigatorios
	lRet := MaCheckCols( aHeader, aCols, n )
	If GdFieldGet('DV4_QTDVOL',n) < GdFieldGet('DV4_QTDPND',n)
		Help("",1,"TMSA36042") //A Qtde. Pendente esta maior que a Qtde. de Volumes Informada na Nota Fiscal
		lRet := .F.
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360NFTOK  ³ Autor ³ Patricia A. Salomao  ³ Data ³21.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao Geral (NF c/ Avarias)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA360NFTOk()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Linha.                                                 ³±±
±±³          ³ExpC1 - Codigo da Ocorrencia.                                  ³±±
±±³          ³ExpN1 - Opcao Selecionada.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360NFTOk(nx,cCodOco,nOpcx)

Local lRet		 := .T.
Local nCntFor    := 0
Local nTotQtdPnd := 0
Local nI         := 0
Local nY         := 0
Local nZ         := 0
Local cTMSCOSB	 := SuperGetMV('MV_TMSCOSB',,'0')
Local nPosDYM    := 0
Default cCodOco  := ""
Default nOpcx    := 0

If nx == Nil .Or. Empty(nx)
	nx := n
EndIf
If !GdDeleted(nx) .And. GdFieldGet('DV4_QTDVOL',nx) < GdFieldGet('DV4_QTDPND',nx)
	Help("",1,"TMSA36042") //A Qtde. Pendente esta maior que a Qtde. de Volumes Informada na Nota Fiscal
	lRet := .F.
EndIf

For nCntFor:=1 to Len(aCols)
	If !GdDeleted(nCntfor)
		nTotQtdPnd += GdFieldGet('DV4_QTDPND',nCntFor)
	EndIf
Next

If lRet .And. cCampo == 'M->DUA_QTDOCO' .And. nTotQtdPnd <> nQtdOco
	Help("",1, "TMSA36041")  //A Qtde. Total Pendente esta diferente da Qtde. Informada na Ocorrencia
	lRet := .F.
EndIf

If nOpcx <> 2
	For nY:= 1 To Len(aCols)
		If !GdDeleted(nY) .And. aCols[nY,4] <> 0
			For nI:= 1 To Len(aNFAvaria)
				For nZ:= 1 To Len(aNFAvaria[nI,2])
					nPos:= Ascan(aNFAvaria[nI,2],{|x| x[1]+x[2] == aCols[nY,1]+aCols[nY,2]  })
					If nPos > 0
						If cCodOco <> aNFAvaria[nI,4]
							If !aNFAvaria[ nI,2,nPos,Len(aNFAvaria[nI,2,nZ]) ] .And. aNFAvaria[ nI,2,nPos,4 ] <> 0
								Help('', 1, 'TMSA360A8')  // Documento do cliente já utilizado em ocorrência anterior
								lRet:= .F.
								Return( lRet )
							EndIf
						EndIf
					EndIf
				Next nZ
			Next nI
			//--- Identificacao do Produto
			If cTMSCOSB == '1'  //Obrigatorio
				DT2->(DbSetOrder(1))
				If DT2->(DbSeek(xFilial('DT2')+M->DUA_CODOCO)) .And. DT2->DT2_TIPPND $ "01/03"   //Falta ou Sobra
					nPosDYM := Ascan(aIdProduto,{ |x| x[1] == M->DUA_FILOCO+M->DUA_NUMOCO+aCols[nY,1]+aCols[nY,2] })
					If nPosDYM == 0
						Help('',1,'TMSA360B6',, aCols[nY,1] + '/' + aCols[nY,2] ,4,1)
						lRet := .F.
						Return (lRet)
					EndIf
				EndIf
			EndIf
		EndIf
	Next nY
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360CarNF  ³ Autor ³ Patricia A. Salomao  ³ Data ³21.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Array contendo as Notas Fiscais com Avaria               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA360CarNF(ExpC1, ExpC2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Fil. Ocorrencia                                        ³±±
±±³          ³ExpC2 - Num. Ocorrencia                                        ³±±
±±³          ³ExpA1 - Documentos                                             ³±±
±±³          ³ExpC3 - Fil. Pendencia                                         ³±±
±±³          ³ExpC4 - Num. Pendencia                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360CarNF(cFilOco,cNumOco,aDoc,cFilPnd,cNumPnd)

Local cItemDV4  := ""
Local nItDV4    := 0
Local nCntFor   := 0
Local nQtdVol   := 0
Local cFilDoc, cDoc, cSerie, cSeek
Local aColsBack := {}
Local nItDYM    := 0
Local cSeekDYM  := ""

Default aDoc    := {}
Default cFilPnd := ''
Default cNumPnd := ''

If Len(aDoc) > 0
	aColsBack := aClone(aCols)
	aCols:= {}
	aCols:= aClone(aDoc)
EndIf
DTC->(DbSetOrder(7))
DbSelectArea("DV4")
DbSetOrder(1)

For nCntFor :=1 to Len(aCols)
	If Len(aDoc) > 0
		cFilDoc := aCols[nCntFor,1]
		cDoc    := aCols[nCntFor,2]
		cSerie  := aCols[nCntFor,3]
	Else
	cFilDoc := GdFieldGet('DUA_FILDOC', nCntFor)
	cDoc    := GdFieldGet('DUA_DOC'   , nCntFor)
	cSerie  := GdFieldGet('DUA_SERIE' , nCntFor)
	EndIf
	If DbSeek(cSeek := xFilial("DV4")+cFilOco+cNumOco+cFilDoc+cDoc+cSerie)
		If cItemDV4 <> cFilDoc+cDoc+cSerie
			cItemDV4 := cFilDoc+cDoc+cSerie
			AAdd(aNFAvaria,{cItemDV4,{}})
			nItDV4++
		EndIf
		Do While !DV4->(Eof()) .And. xFilial("DV4")+DV4->(DV4_FILOCO+DV4_NUMOCO+DV4_FILDOC+DV4_DOC+DV4_SERIE) == cSeek
			If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc,cDoc,cSerie)
				If DTC->(DbSeek(xFilial('DTC')+cDoc+cSerie+cFilDoc+DV4->DV4_NUMNFC+DV4->DV4_SERNFC))
					nQtdVol := DTC->DTC_QTDVOL
				Endif
			Else
				DbSelectArea("DY4")
				DbSetOrder(1) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
				If DY4->(DbSeek(xFilial('DY4')+cFilDoc+cDoc+cSerie+DV4->DV4_NUMNFC+DV4->DV4_SERNFC))
					nQtdVol := DY4->DY4_QTDVOL
				EndIf
			EndIf

		   If Empty(cNumPnd)
				AAdd(ANFAvaria[nItDV4][2],{DV4->DV4_NUMNFC,DV4->DV4_SERNFC,nQtdVol,DV4->DV4_QTDPND ,,.F.})
			Else
				If cFilPnd+cNumPnd == DV4->DV4_FILPND + DV4->DV4_NUMPND
					AAdd(ANFAvaria[nItDV4][2],{DV4->DV4_NUMNFC,DV4->DV4_SERNFC,nQtdVol,DV4->DV4_QTDPND ,,.F.})
				EndIf
			EndIf

			DbSelectArea("DYM")
			DYM->(DbSetOrder(1))
			If DbSeek(cSeekDYM := xFilial("DYM")+cFilPnd+cNumPnd+DV4->DV4_NUMNFC+DV4->DV4_SERNFC)
				AAdd(aIdProduto,{cFilPnd+cNumPnd+DV4->DV4_NUMNFC+DV4->DV4_SERNFC,{}})
				nItDYM++
				Do While !DYM->(Eof()) .And. xFilial("DYM")+DYM->(DYM_FILPND+DYM_NUMPND+DYM_NUMNFC+DYM_SERNFC) == cSeekDYM
			  			AAdd(aIdProduto[nItDYM][2],{DYM->DYM_TPIDPD,Posicione("DYL",1,xFilial("DYL")+DYM->DYM_TPIDPD,"DYL_DESCRI"),DYM->DYM_DETALH ,.F.})
					DYM->(dbSkip())
				EndDo
			EndIf
			DV4->(dbSkip())
		EndDo
	Else
		DbSelectArea("DYM")
		DYM->(DbSetOrder(1))
		If DbSeek(cSeek := xFilial("DYM")+cFilPnd+cNumPnd+Space(Len(DYM->DYM_NUMNFC))+Space(Len(DYM->DYM_SERNFC)))
			AAdd(aIdProduto,{cFilPnd+cNumPnd+cFilDoc+cDoc+cSerie,{}})
			nItDYM++
			Do While !DYM->(Eof()) .And. xFilial("DYM")+DYM->(DYM_FILPND+DYM_NUMPND+DYM_NUMNFC+DYM_SERNFC) == cSeek
		   		AAdd(aIdProduto[nItDYM][2],{DYM->DYM_TPIDPD,Posicione("DYL",1,xFilial("DYL")+DYM->DYM_TPIDPD,"DYL_DESCRI"),DYM->DYM_DETALH ,.F.})
				DYM->(dbSkip())
			EndDo
		EndIf
	EndIf
Next
If Len(aDoc) > 0
	aCols:= {}
	aCols:= aClone(aColsBack)
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A360GrvPnd    ³ Autor ³ Patricia A. Salomao  ³ Data ³21.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava a Pendencia no Arquivo DUU (Registro de Pendencias)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A360GrvPnd()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Filial Docto.                                          ³±±
±±³          ³ExpC2 - No. do Docto.                                          ³±±
±±³          ³ExpC3 - Serie  Docto.                                          ³±±
±±³          ³ExpC4 - Fil. Origem Viagem                                     ³±±
±±³          ³ExpC5 - No. da Viagem                                          ³±±
±±³          ³ExpC6 - Tipo da Pendencia                                      ³±±
±±³          ³ExpN1 - Qtde. da Pendencia                                     ³±±
±±³          ³ExpN2 - No. da Linha                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A360GrvPnd(cFilDoc, cDoc, cSerie, cFilOri, cViagem, cTipPnd, nQuant, nCntFor)

Local nB      := 0
Local bCampo  := { |nCpo| Field(nCpo) }
Local cCodCli := ''
Local cLojCli := ''

If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
	DbSelectArea("DT6")
	DbSetOrder(1)
	If DbSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie)
		cCodCli := DT6->DT6_CLIDEV
		cLojCli := DT6->DT6_LOJDEV
	EndIf
EndIf

M->DUU_FILDOC	:= cFilDoc
M->DUU_DOC		:= cDoc
M->DUU_SERIE	:= cSerie
M->DUU_FILORI	:= cFilOri
M->DUU_VIAGEM	:= cViagem
M->DUU_CODCLI	:= cCodCli
M->DUU_LOJCLI	:= cLojCli
M->DUU_CODOCO	:= GDFieldGet('DUA_CODOCO', nCntFor )
M->DUU_TIPPND	:= cTipPnd
M->DUU_QTDOCO	:= nQuant
M->DUU_STATUS	:= StrZero( 1, Len( DUU->DUU_STATUS ) )
M->DUU_MOTIVO	:= GDFieldGet('DUA_MOTIVO', nCntFor )

If Len(aIdProduto) > 0
	M->DUU_STACON:= Iif(cTipPnd $ "01/03", StrZero(2, Len(DUU->DUU_STACON)), StrZero(1, Len(DUU->DUU_STACON)))  //Pendente ou Nao Usado
EndIf
RecLock('DUU',.T.)
For nB := 1 To FCount()
	If FieldName( nB ) == 'DUU_FILIAL'
		FieldPut( nB, xFilial('DUU') )
	Else
		FieldPut( nB, M->&( Eval( bCampo, nB ) ) )
	EndIf
Next

MSMM(DUU->DUU_CODMTV,,, M->DUU_MOTIVO, 1,,, 'DUU', 'DUU_CODMTV')

DUU->(MsUnLock())
If __lSX8
	ConfirmSX8()
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA360VerA³ Autor ³Patricia A. Salomao    ³ Data ³23.12.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a estrutura do array de NF's com Avaria, passado    ³±±
±±³          ³ pela Rotina Automatica                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA360VerArr(ExpA1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array de NF's com Avaria                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA360                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA360VerArr(aArray)

Local nCntFor, nY

For nCntFor:=1 To Len(aArray)
	If Len(aArray[nCntFor]) < 2
		Help("",1,"TMSA36046") // Erro na Estrutura do Array de NF's com Avaria
		Return( .F. )
	EndIf
	If ValType(aArray[nCntFor][1]) <> "C"
		Help("",1,"TMSA36046") // Erro na Estrutura do Array de NF's com Avaria
		Return( .F. )
	EndIf
	If ValType(aArray[nCntFor][2]) <> "A"	.Or. Empty(aArray[nCntFor][2])
		Help("",1,"TMSA36046") // Erro na Estrutura do Array de NF's com Avaria
		Return( .F. )
	EndIf
	For nY:=1 To Len(aArray[nCntFor][2])
		If ValType(aArray[nCntFor][2][nY]) <> "A" .And. ValType(aArray[nCntFor][2][nY]) <> "C"
			Help("",1,"TMSA36046") // Erro na Estrutura do Array de NF's com Avaria
			Return( .F. )
		EndIf
	Next nY
Next nCntFor

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360KmV³ Autor ³Patricia A. Salomao    ³ Data ³24.02.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Informar a  Km de Entrada do Veiculo, apos gravar a Ocorren-³±±
±±³          ³cia de Transferencia                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA360KmVei()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Comentario³Esta Tela so'sera' aberta se a Viagem NAO POSSUIR Documentos³±±
±±³          ³com STATUS diferente de "4" (Encerrado) ou "9" (Cancelado), ³±±
±±³          ³e se o Tipo da Ocorrencia Informada for igual a "8"(Transfe-³±±
±±³          ³rencia) ou "9" (Gera Indenizacao)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA360                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA360KmVei()
Local aArea			:= GetArea()
Local aAreaDUV		:= DUV->(GetArea())
Local cSeek        := ""
Local lMostra      := .T.
Local nCntFor      := 0
Local nPosFilVtr   := Ascan(aHeader, {|x| AllTrim(x[2]) == "DUA_FILVTR"})
Local nPosNumVtr   := Ascan(aHeader, {|x| AllTrim(x[2]) == "DUA_NUMVTR"})
Local cHoraCan
Local lKmObrig     := SuperGetMv('MV_KMOBRIG',,.T.) // Obriga informar a Quilometragem do veículo.
Local lRet         := .T.
Local cSeekTrf     := ""
Local aColsAux     := {}
Local cFilVtr      := ''
Local cNumVtr      := ''
Local lMaisVig     := .F.
Local nCanViag     := SuperGetMv('MV_TMSCVIA',,0) //-- Opcoes para o param. MV_TMSCVIAG: 0-Nao Utiliza/1- Cancelar Viagem/2-Encerra/3- Pergunta
Local lITmsDmd     := SuperGetMv("MV_ITMSDMD",,.F.)
Local lTercRbq 	   := DTR->(ColumnPos("DTR_CODRB3")) > 0

Local lEncerra     := .T.

// Nao Mostrar a Tela, caso tenha algum documento com STATUS diferente de "4" (Encerrado) ou
// "9" (Cancelado)
Begin Sequence
DUD->(DbSetOrder(2))
If DUD->(DbSeek(cSeek := xFilial("DUD")+M->DUA_FILORI+M->DUA_VIAGEM))
	Do While !DUD->(Eof()) .And. DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM) == cSeek
		If DUD->DUD_STATUS <> StrZero(4, Len(DUD->DUD_STATUS)) .And. DUD->DUD_STATUS <> StrZero(9, Len(DUD->DUD_STATUS))
			lMostra := .F.
			Exit
		EndIf
		DUD->(dbSkip())
	EndDo
	If !lMostra
		Return( .T. )
	Else
		//-- Depois de varrer os Documentos (DUD), varrer o acols para Verificar se o Tipo da Ocorrencia
		//-- foi uma Transferencia ou Indenizacao.
		DT2->(DbSetOrder(1))
		For nCntFor:=1 To Len(aCols)
			DT2->(DbSeek(xFilial("DT2")+ GdFieldGet("DUA_CODOCO", nCntFor) ))
			If DT2->DT2_TIPOCO == StrZero( 8, Len(DT2->DT2_TIPOCO ) ) .Or. ;
				DT2->DT2_TIPOCO == StrZero( 9, Len(DT2->DT2_TIPOCO ) )
				lMostra 	:= .T.
				Exit
			EndIf
			lMostra :=.F.
		Next
		If !lMostra
			Break
		EndIf
	EndIf
Else
	Break
EndIf
If lKmObrig .Or. nCanViag <> 0
	If lKmObrig
		TMSA350Km(M->DUA_FILORI,M->DUA_VIAGEM,.F.,lKmObrig)
	EndIf
	cHoraCan := StrTran(Left(Time(),5),':','')
	DTW->( DbSetOrder( 3 ) )
	If	DTW->( DbSeek( cSeek := xFilial('DTW') + M->DUA_FILORI + M->DUA_VIAGEM + StrZero( 1, Len( DTW->DTW_STATUS ) ) ) )
		Do While DTW->( DbSeek( cSeek ) )
			RecLock('DTW',.F.)
			DTW->DTW_DATREA := dDataBase
			DTW->DTW_HORREA := cHoraCan
			DTW->DTW_STATUS := StrZero(9,Len(DTW->DTW_STATUS)) //-- Cancelado
			DTW->( MsUnLock() )
		EndDo
	EndIf

	//-- Posiciona na viagem.
	DTQ->( DbSetOrder( 2 ) )
	If	DTQ->( DbSeek( xFilial('DTQ') + M->DUA_FILORI + M->DUA_VIAGEM ) )
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Utiliza o campo de observacao da viagem, para guardar o status   ³
		³da viagem. Dessa forma serah possivel retornar o status da viagem|
		|no estorno da Ocorrencia.                                        ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		MSMM(DTQ->DTQ_CODOBS,,,DTQ->DTQ_STATUS,1,,,"DTQ","DTQ_CODOBS")

		RecLock('DTQ',.F.)

		Do Case

			Case nCanViag == 1
				DTQ->DTQ_STATUS := StrZero( 9, Len( DTQ->DTQ_STATUS ) )
				
				//Cancela planejamento de demandas
				If lITmsDmd .And. FindFunction("TMSCanPln") .And. TableInDic("DL9")
					TMSCanPln(DTQ->DTQ_VIAGEM, "8")
				EndIf
			Case nCanViag == 2
				DTQ->DTQ_STATUS := StrZero( 3, Len( DTQ->DTQ_STATUS ) )
			Case nCanViag == 3

				If lCancelaDTQ
					DTQ->DTQ_STATUS := StrZero( 9, Len( DTQ->DTQ_STATUS ) )
					
					//Cancela planejamento de demandas
					If lITmsDmd .And. FindFunction("TMSCanPln") .And. TableInDic("DL9")
						TMSCanPln(DTQ->DTQ_VIAGEM, "8")
					EndIf
				Else
					DTQ->DTQ_STATUS := StrZero( 3, Len( DTQ->DTQ_STATUS ) )
				EndIf

			//-- O Default para o parametr MV_TMSCVIA foi definido como 5 para identificar que nao
			//   existe o parametro cadastrado, evitando a utilizacao do comando SEEK
			OtherWise
				If DTQ->(ColumnPos("DTQ_CODAUT")) > 0
					lEncerra := TMSA360Aut(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_CODAUT,"TMSA340",lEncViag)
				Else
					lEncerra := lEncViag
				EndIf

				If lEncerra
					DTQ->DTQ_STATUS := StrZero( 3, Len( DTQ->DTQ_STATUS ) )
				Else
					DTQ->DTQ_STATUS := StrZero( 9, Len( DTQ->DTQ_STATUS ) )
					
					//Cancela planejamento de demandas
					If lITmsDmd .And. FindFunction("TMSCanPln") .And. TableInDic("DL9")
						TMSCanPln(DTQ->DTQ_VIAGEM, "8")
					EndIf
				EndIf

		EndCase


		MsUnLock()
	EndIf

	DUV->(dbSetOrder(1))
	//-- Por viagem.
	If DTR->( DbSeek( cSeek := xFilial('DTR') + M->DUA_FILORI+M->DUA_VIAGEM ) )
		Do While !DTR->(Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM)==cSeek
			DA3->(DbSeek(xFilial('DA3')+DTR->DTR_CODVEI))
			DUT->(DbSeek(xFilial('DUT')+DA3->DA3_TIPVEI))
			// Se for Cavalo ou o Reboque ja estiver preenchido
			If DUT->DUT_CATVEI == StrZero(2,Len(DUT->DUT_CATVEI)) .Or. !Empty(DTR->DTR_CODRB1)
				For nCntFor:=1 To Len(aCols)
					If DTR->( DbSeek( cSeekTrf := xFilial('DTR') + GdFieldGet("DUA_FILVTR", nCntFor)+GdFieldGet("DUA_NUMVTR", nCntFor) ) )
						Do While !DTR->(Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM)==cSeekTrf
							DA3->(DbSeek(xFilial('DA3')+DTR->DTR_CODVEI))
							DUT->(DbSeek(xFilial('DUT')+DA3->DA3_TIPVEI))
							If DUV->( MsSeek( xFilial("DUV") +  GdFieldGet("DUA_FILVTR", nCntFor)+GdFieldGet("DUA_NUMVTR", nCntFor) ))
								If (DTR->DTR_CODRB1 != DUV->DUV_CODRB1) .Or. (DTR->DTR_CODRB2 != DUV->DUV_CODRB2)
									RecLock("DTR", .F.)
									DTR->DTR_CODRB1 := DUV->DUV_CODRB1
									DTR->DTR_CODRB2 := DUV->DUV_CODRB2
									If lTercRbq
										DTR->DTR_CODRB3 := DUV->DUV_CODRB3
									EndIf
									DTR->DTR_REBTRF := "1" //Reboque transferido
									DTR->(MsUnLock())
								EndIf
							EndIf 
						DTR->(dbSkip())
						EndDo
					EndIf
				Next
			EndIf
			DTR->(dbSkip())
		EndDo
	EndIf

	//--Realiza o Carregamento automatico por Documentos
	cFilVtr  := ''
	cNumVtr  := ''
	lMaisVig := .F.
	For nCntFor:=1 To Len(aCols)
		DT2->(DbSeek(xFilial("DT2")+ GdFieldGet("DUA_CODOCO", nCntFor) ))
		If DT2->DT2_TIPOCO == StrZero( 8, Len(DT2->DT2_TIPOCO ) ) //--Transferencia
			If Empty(cFilVtr) .And. Empty(cNumVtr)
				cFilVtr := GdFieldGet('DUA_FILVTR', nCntFor)
				cNumVtr := GdFieldGet('DUA_NUMVTR', nCntFor)
			Else
				If Ascan(aCols,{|x| x[nPosFilVtr]+x[nPosNumVtr]!=cFilVtr+cNumVtr }) > 0
					lMaisVig := .T. //--Verifica se a mais de uma viagem para otimizar a transferencia
				EndIf
				Exit
			EndIf
		EndIf
	Next
	If lMaisVig
		For nCntFor:=1 To Len(aCols)
			DT2->(DbSeek(xFilial("DT2")+ GdFieldGet("DUA_CODOCO", nCntFor) ))
			If DT2->DT2_TIPOCO == StrZero( 8, Len(DT2->DT2_TIPOCO ) ) //--Transferencia
				TMS360Crr( 3, GdFieldGet('DUA_FILVTR', nCntFor) ,GdFieldGet('DUA_NUMVTR', nCntFor), ;
								  GdFieldGet( 'DUA_FILDOC',nCntFor), GdFieldGet( 'DUA_DOC'   ,nCntFor ), ;
			  					  GdFieldGet( 'DUA_SERIE' ,nCntFor ))
			EndIf
		Next
	Else
		For nCntFor:=1 To Len(aCols)
			DT2->(DbSeek(xFilial("DT2")+ GdFieldGet("DUA_CODOCO", nCntFor) ))
			If DT2->DT2_TIPOCO == StrZero( 8, Len(DT2->DT2_TIPOCO ) ) //--Transferencia
				AAdd(aColsAux,{GdFieldGet('DUA_FILVTR', nCntFor) ,GdFieldGet('DUA_NUMVTR', nCntFor), ;
									GdFieldGet( 'DUA_FILDOC',nCntFor), GdFieldGet( 'DUA_DOC'   ,nCntFor ), ;
									GdFieldGet( 'DUA_SERIE' ,nCntFor )})
			EndIf
		Next
		TMS360Crr( 3, cFilVtr ,cNumVtr,'','','', aColsAux)
	EndIf
Else
	lRet := .F.
EndIf
End Sequence

RestArea(aAreaDUV)
RestARea(aArea)
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA360ConfE³ Autor ³Patricia A. Salomao    ³ Data ³12.05.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Tela de Confirmacao de Embarque de Viagens Aereas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TA360ConfEmb(ExpN1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA360                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TA360ConfEmb(nOpcx)

Local aArea      := GetArea()
Local aAreaDTX   := DTX->(GetArea())
Local aAreaDTV   := DTV->(GetArea())
Local bCampo     := { |nCpo| Field(nCpo) }
Local oEnchoice
Local oDlg
Local nB         := 0
Local nOpc       := 0
Local nSeek      := 0
Local lRet       := .T.
Local aGetsOld   := AClone(aGets)
Local aTelaOld   := AClone(aTela)
Local bSavKeyF4  := SetKey(VK_F4,Nil)
Local aRetPE     := {}
Local aDadosDVH1 := {}
Local aPosN      := aPos
Local aDVHStru  := FwFormStruct(2,"DVH")
Local nCont     := 0


aGets := {}
aTela := {}

DbSelectArea("DVH")
DbSetOrder(1)
If nOpcx <> 3 //Posiciona DVH
	DbSeek(xFilial('DVH')+ M->DUA_FILORI+M->DUA_VIAGEM+M->DUA_FILOCO+M->DUA_NUMOCO)
EndIf
//-- Se as Variaveis de Memoria ja foram criadas, NAO criar novamente
If nOpcx==3
	RegToMemory("DVH", nOpcx==3)
	M->DVH_FILOCO := M->DUA_FILOCO
	M->DVH_NUMOCO := M->DUA_NUMOCO
	M->DVH_FILORI := M->DUA_FILORI
	M->DVH_VIAGEM := M->DUA_VIAGEM
Else
	For nCont := 1 to Len(aDVHStru:aFields)
		If GetSX3Cache(aDVHStru:aFields[nCont][1], "X3_CONTEXT") == "V"  .Or. Inclui
			nSeek := Ascan(aDadosDVH, { |x| x[1] == cCampo })
			M->&(aDVHStru:aFields[nCont][1]) := IIF(nSeek>0, aDadosDVH[nSeek][2],CriaVar(aDVHStru:aFields[nCont][1], .F.)	)
		Else
			M->&(aDVHStru:aFields[nCont][1]) := DVH->(FieldGet(ColumnPos(aDVHStru:aFields[nCont][1])))
		EndIf
	Next nCont
EndIf

M->DVH_NUMAWB := DTV->DTV_NUMAWB
M->DVH_DIGAWB := DTV->DTV_DIGAWB
M->DVH_CODCIA := DTV->DTV_CODCIA
M->DVH_LOJCIA := DTV->DTV_LOJCIA
If !Empty(M->DVH_CODCIA) .And. !Empty(M->DVH_LOJCIA)
	lCiaAerea := .T.
EndIf


M->DVH_NOMCIA := Posicione('SA2', 1, xFilial('SA2')+M->DVH_CODCIA+M->DVH_LOJCIA, 'A2_NOME')

//-- Ponto de entrada que permite informar conteudo dos campos da Confirmacao de Embarque
If ExistBlock("TM360CFE")
	aRetPE := ExecBlock("TM360CFE",.F.,.F.)
	If ValType(aRetPE) == "A"
		For nB := 1 To Len(aRetPE)
			cCampo := aRetPE[nB,1]
			M->&(cCampo) := aRetPE[nB,2]
		Next nB
	EndIf
EndIf

DEFINE MSDIALOG oDlg TITLE STR0019 From 2,0 To 20,80 OF oMainWnd //"Confirmacao de Embarque Aereo"

oEnchoice := MsMGet():New('DVH', DVH->(Recno()), IIf(nOpcx==3,nOpcx,2) , , , , , aPosN , , 3,,,,,, .T. )

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpc :=1, If (Obrigatorio(aGets,aTela), oDlg:End(),nOpc := 0)},{||oDlg:End()}) CENTERED

If nOpc == 1
	DTQ->(DbSetOrder(2))
	DTQ->(DbSeek(xFilial("DTQ")+M->DVH_FILORI+M->DVH_VIAGEM))
	lRet := ValDatHor(M->DVH_DATPAR,M->DVH_HORPAR,DTQ->DTQ_DATFEC,DTQ->DTQ_HORFEC,,,,.F.)
	If lRet
		lRet := ValDatHor(M->DVH_DATCHG,M->DVH_HORCHG,M->DVH_DATPAR,M->DVH_HORPAR,,,,.F.)
	EndIf
	If lRet
		For nB :=1 To FCount()
			cCampo := FieldName(nB)
			If Type("M->"+cCampo) <> "U"
				AAdd( aDadosDVH1, { cCampo,M->&( Eval( bCampo, nB ) ) }  )
			EndIf
		Next
		GdFieldPut("DUA_DATOCO",M->DVH_DATPAR,n)
		GdFieldPut("DUA_HOROCO",M->DVH_HORPAR,n)

		AAdd( aDadosDVH, {aDadosDVH1} )
	EndIf
ElseIf "TMSA360" $ FunName()
	lRet := .F.
EndIf

aGets := AClone(aGetsOld)
aTela := AClone(aTelaOld)

SetKey( VK_F4,bSavKeyF4 )

RestArea( aArea    )
RestArea( aAreaDTX )
RestArea( aAreaDTV )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA360EmbFlu³Autor ³ Richard Anderson      ³ Data ³14.06.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Tela de Confirmacao de Embarque Fluvial                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TA360EmbFlu(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA360                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TA360EmbFlu(nOpcx)

Local aArea     := GetArea()
Local bCampo    := { |nCpo| Field(nCpo) }
Local oEnchoice
Local nB
Local oDlg
Local nOpc      := 0
Local lRet      := .T.
Local aGetsOld  := AClone(aGets)
Local aTelaOld  := AClone(aTela)
Local bSavKeyF4 := SetKey(VK_F4,Nil)
Local nSeek     := 0
Local aDW4Stru  := FwFormStruct(2,"DW4")
Local nCont     := 0

aGets := {}
aTela := {}

DbSelectArea("DW4")
DbSetOrder(1)
If nOpcx <> 3 //Posiciona DW4
	DbSeek(xFilial('DW4')+M->DUA_FILORI+M->DUA_VIAGEM+M->DUA_FILOCO+M->DUA_NUMOCO)
EndIf
//-- Se as Variaveis de Memoria ja foram criadas, NAO criar novamente
If Empty(aDadosDW4)
	RegToMemory("DW4", nOpcx==3)
	M->DW4_FILOCO := M->DUA_FILOCO
	M->DW4_NUMOCO := M->DUA_NUMOCO
	M->DW4_FILORI := M->DUA_FILORI
	M->DW4_VIAGEM := M->DUA_VIAGEM
Else

	For nCont := 1 to Len(aDW4Stru:aFields)
		If	( GetSX3Cache(aDTCStru:aFields[nCont][1], "X3_CONTEXT") == "V"  .Or. Inclui )
			nSeek := Ascan(aDadosDW4, { |x| x[1] == aDW4Stru:aFields[nCont][1] })
			M->&(aDW4Stru:aFields[nCont][1]) := IIF(nSeek>0, aDadosDW4[nSeek][2],CriaVar(aDW4Stru:aFields[nCont][1], .F.)	 )
		Else
			M->&(aDW4Stru:aFields[nCont][1]) := DW4->(FieldGet(ColumnPos(aDW4Stru:aFields[nCont][1])))
		EndIf
	Next nCont
EndIf

DEFINE MSDIALOG oDlg TITLE STR0010 From 2,0 To 20,80 OF oMainWnd //"Confirmacao de Embarque Fluvial"

oEnchoice := MsMGet():New('DW4', DW4->(Recno()), IIf(nOpcx==3,nOpcx,2) , , , , , aPos , , 3,,,,,, .T. )

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpc :=1, If (Obrigatorio(aGets,aTela), oDlg:End(),nOpc := 0)},{||oDlg:End()}) CENTERED

If nOpc == 1
	aDadosDW4 := {}
	DTQ->(DbSetOrder(2))
	DTQ->(DbSeek(xFilial("DTQ")+M->DW4_FILORI+M->DW4_VIAGEM))
	lRet := ValDatHor(M->DW4_DATSAI,M->DW4_HORSAI,DTQ->DTQ_DATFEC,DTQ->DTQ_HORFEC)
	If lRet
		For nB :=1 To FCount()
			cCampo := FieldName(nB)
			If Type("M->"+cCampo) <> "U"
				AAdd( aDadosDW4, { cCampo,M->&( Eval( bCampo, nB ) ) }  )
			EndIf
		Next
		GdFieldPut("DUA_DATOCO",M->DW4_DATSAI,n)
		GdFieldPut("DUA_HOROCO",M->DW4_HORSAI,n)
	EndIf
Else
	lRet := .F.
EndIf

aGets := AClone(aGetsOld)
aTela := AClone(aTelaOld)

SetKey( VK_F4,bSavKeyF4 )

RestArea( aArea )

Return( lRet )

//-- DT2_TIPOCO
//-- 01 - Encerra Processo
//-- 02 - Bloqueia Docto
//-- 03 - Libera Docto
//-- 04 - Retorna Docto
//-- 05 - Informativa
//-- 06 - Gera Pendencia s/ Bloqueio de Docto.
//-- 08 - Transferencia
//-- 09 - Gera Indenizacao c/ Bloqueio de Docto.
//-- 11 - Transferencia de Mercadoria
//-- 12 - Cancelamento

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tmsa360Doc³ Autor ³ Robson Alves          ³ Data ³18.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o status do documento.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tmsa360Doc( ExpC1, ExpC2, ExpC3, ExpC4, ExpC5 )             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de Origem                                   ³±±
±±³          ³ ExpC2 = Codigo da viagem                                   ³±±
±±³          ³ ExpC3 = Filial do Documento                                ³±±
±±³          ³ ExpL2 = Documento                                          ³±±
±±³          ³ ExpL3 = Serie do Documento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Status do documento.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³ Esta funcao sera utilizada para analisar se ha restricoes  ³±±
±±³          ³ para a viagem.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa360Doc(cFilOri, cViagem, cFilDoc, cDoc, cSerie, cRomaneio)

Local cRet      := ''
Local aAreaDTA  := {}
Local aAreaDTQ  := {}
Local aAreaDUD  := {}
Local cSeek     := ''
Local cAliasQry := ''
Local cQuery    := ''
Local lTMS3GFE  := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local lRotDUD   := Iif(FindFunction('TMSChvDUD'),.T.,.F.)

Default cRomaneio := ''

aAreaDTQ := DTQ->( GetArea() )
DTQ->( DbSetOrder( 2 ) )
If DTQ->( DbSeek( xFilial("DTQ") + cFilOri + cViagem ) )
	//-- Viagem Em Aberto.
	If DTQ->DTQ_STATUS == StrZero( 1, Len( DTQ->DTQ_STATUS ) )
		aAreaDTA := DTA->( GetArea() )
		DTA->( DbSetOrder( 2 ) )
		If DTA->( DbSeek( xFilial("DTA") + cFilOri + cViagem + cFilDoc + cDoc + cSerie ) ) .And. DUD->DUD_SERTMS != StrZero(1,Len(DUD->DUD_SERTMS))
			cRet := StrZero( 3, Len( DUD->DUD_STATUS ) ) // Carregado.
		Else
			cRet := StrZero( 1, Len( DUD->DUD_STATUS ) ) // Em Aberto.
		EndIf
		RestArea( aAreaDTA )
		//-- Viagem Fechada.
	ElseIf DTQ->DTQ_STATUS == StrZero( 5, Len( DTQ->DTQ_STATUS ) )
		If DUD->DUD_SERTMS == StrZero( 1, Len( DUD->DUD_SERTMS ) ) // Documento de Coleta.
			cRet := StrZero( 1, Len( DUD->DUD_STATUS ) ) // Em Aberto.
		Else
			cRet := StrZero( 3, Len( DUD->DUD_STATUS ) ) // Carregado.
		EndIf
		//-- Viagem Chegada em Filial
	ElseIf DTQ->DTQ_STATUS == StrZero( 4, Len( DTQ->DTQ_STATUS ) )
		aAreaDUD := DUD->( GetArea() )
		DUD->( DbSetOrder( 1 ) )
		cSeek := xFilial("DUD") + cFilDoc + cDoc + cSerie + Iif( Empty( cFilOri ), cFilAnt, cFilOri )
		If DUD->( DbSeek( cSeek ) ) .And. DUD->DUD_FILDCA == cFilAnt
			If DTQ->DTQ_SERTMS == StrZero(3, Len(DTQ->DTQ_STATUS)) // Viagem de Entrega
				cRet := StrZero( 2, Len( DUD->DUD_STATUS ) ) // Em transito.
			Else
				cRet := StrZero( 4, Len( DUD->DUD_STATUS ) ) // Encerrado
			EndIf
		Else
			cRet := StrZero( 2, Len( DUD->DUD_STATUS ) ) // Em transito.
		EndIf
		RestArea( aAreaDUD )
		//-- Viagem Em Transito.
	ElseIf DTQ->DTQ_STATUS == StrZero( 2, Len( DTQ->DTQ_STATUS ) )
		cRet := StrZero( 2, Len( DUD->DUD_STATUS ) ) // Em transito.
	//-- Viagem de Redespacho Encerrado, caso em que é possivel apontar ocorrencia de Retorna Docto com viagem encerrada
	ElseIf DTQ->DTQ_STATUS == StrZero( 3, Len( DTQ->DTQ_STATUS ) ) .And. (lTMS3GFE .Or. lTmsRdpU)
		aAreaDUD := DUD->( GetArea() )
		If lRotDUD .And. TMSChvDUD(cFilDoc,cDoc,cSerie)
			cRet := StrZero( 4, Len( DUD->DUD_STATUS ) ) // Encerrado.
		EndIF
		RestArea( aAreaDUD )
	EndIf

ElseIf !__lPyme
	aAreaDUD := DUD->( GetArea() )
	nRecRed:= TMA360IRD(cFilDoc,cDoc,cSerie,StrZero(9, Len(DUD->DUD_STATUS)),.T.)
	If nRecRed > 0
		cRet := StrZero( 1, Len( DUD->DUD_STATUS ) ) // Em Aberto.
	EndIf
	RestArea( aAreaDUD )
ElseIf __lPyme

	aAreaDUD := DUD->( GetArea() )
	cAliasQry := GetNextAlias()
	cQuery := " SELECT R_E_C_N_O_ REC"
	cQuery += " FROM " + RetSqlName("DUD")
	cQuery += " WHERE DUD_FILIAL ='" + xFilial("DUD") + "'"
	cQuery += "   AND DUD_FILDOC ='" + cFilDoc + "'"
	cQuery += "   AND DUD_DOC    ='" + cDoc + "'"
	cQuery += "   AND DUD_SERIE  ='" + cSerie + "'"
	cQuery += "   AND DUD_NUMROM ='" + cRomaneio + "'"
	cQuery += "   AND DUD_SERTMS ='" + StrZero(3, Len(DUD->DUD_SERTMS))+  "'"
	cQuery += "   AND (DUD_STATUS ='" + StrZero(4, Len(DUD->DUD_STATUS))+  "'"
	cQuery += "   OR DUD_STATUS ='" + StrZero(9, Len(DUD->DUD_STATUS))+  "')"
	cQuery += "   AND D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	If (cAliasQry)->(!Eof())
		cRet := StrZero( 3, Len( DUD->DUD_STATUS ) ) // Carregado.
	EndIf
	(cAliasQry)->( dbCloseArea() )
	RestArea( aAreaDUD )
EndIf

Return( cRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360CVge³ Autor ³ Eduardo de Souza     ³ Data ³ 10/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cancelamento da Viagem                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA360CVge( ExpC1, ExpC2 )                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de Origem                                   ³±±
±±³          ³ ExpC2 = Viagem                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360CVge(cFilOri,cViagem,lEstorno)

Local aAreaDUD  := DUD->(GetArea())
Local aAreaDTQ  := DTQ->(GetArea())
Local lCancViag := !lEstorno
Local cStatus   := ""
Local cSeek     := ""
Local lContVei  := GetMV('MV_CONTVEI',,.T.) // Parametro para verificar se o sistema devera' controlar veiculo/motorista
Local lITmsDmd    := SuperGetMv("MV_ITMSDMD",,.F.)

If !lEstorno
	DUD->(DbSetOrder(2))
	If DUD->(DbSeek(xFilial("DUD")+cFilOri+cViagem))
		While DUD->(!Eof()) .And. DUD->DUD_FILIAL + DUD->DUD_FILORI + DUD->DUD_VIAGEM == xFilial("DUD") + cFilOri + cViagem
		 	If DUD->DUD_STATUS <> StrZero(9,Len(DUD->DUD_STATUS)) //-- Cancelado
				lCancViag := .F. //-- Cancela Viagem
				Exit
			EndIf
			DUD->(DbSkip())
		EndDo
	EndIf
EndIf

DTQ->(DbSetOrder(2))
If DTQ->(DbSeek(xFilial("DTQ")+cFilOri+cViagem))
	If lCancViag
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Utiliza o campo de observacao da viagem, para guardar o status   ³
		³da viagem. Dessa forma serah possivel retornar o status da viagem|
		|no estorno da Ocorrencia.                                        ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		MSMM(DTQ->DTQ_CODOBS,,,DTQ->DTQ_STATUS,1,,,"DTQ","DTQ_CODOBS")
		//-- Cancela as operacoes da viagem em aberto.
		DTW->( DbSetOrder( 3 ) )
		If	DTW->( DbSeek( cSeek := xFilial('DTW') + M->DUA_FILORI + M->DUA_VIAGEM + StrZero( 1, Len( DTW->DTW_STATUS ) ) ) )
			While DTW->( DbSeek( cSeek ) )
				RecLock("DTW",.F.)
				DTW->DTW_DATREA := dDataBase
				DTW->DTW_HORREA := StrTran(Left(Time(),5),":","")
				DTW->DTW_STATUS := StrZero(9,Len(DTW->DTW_STATUS)) //-- Cancelado
				DTW->( MsUnLock() )
			EndDo
		EndIf
		cStatus := StrZero(9,Len(DTQ->DTQ_STATUS)) //-- Cancelada
		//-- Verifica se devera atualizar o status do veiculo/motorista.
		If lContVei .And. A340AtuStat(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)
			TMSA340Sta(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, '3', '1')
		EndIf
	ElseIf lEstorno .And. DTQ->DTQ_STATUS == StrZero(9,Len(DTQ->DTQ_STATUS)) //-- Cancelada
		//-- Verifica se o veiculo/motorista esta disponivel para retomar a viagem.
		If !TMSA340Vei()
			Return( .F. )
		EndIf
		//-- Posiciona nas operacoes de transporte com status Cancelado.
		DTW->( DbSetOrder( 3 ) )
		If	DTW->( DbSeek( cSeek := xFilial('DTW') + M->DUA_FILORI + M->DUA_VIAGEM + StrZero( 9, Len( DTW->DTW_STATUS ) ) ) )
			While DTW->( DbSeek( cSeek ) )
				RecLock('DTW',.F.)
				DTW->DTW_DATREA := Ctod("  /  /  ")
				DTW->DTW_HORREA := Space( Len( DTW->DTW_HORREA ) )
				DTW->DTW_STATUS := StrZero( 1, Len( DTW->DTW_STATUS ) )	//-- Em Aberto
				DTW->( MsUnLock() )
			EndDo
		EndIf
		cStatus := MsMM(DTQ->DTQ_CODOBS, Len( DTQ->DTQ_STATUS ) )
		//-- Verifica se devera atualizar o status do veiculo/motorista.
		If lContVei .And. A340AtuStat(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)
			TMSA340Sta(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, '1', '3')
		EndIf
	EndIf
	//-- Atualiza Status da Viagem
	If !Empty(cStatus)
		RecLock("DTQ",.F.)
		DTQ->DTQ_STATUS := cStatus
		MsUnlock()
		
		If lITmsDmd .And. FindFunction("TMSCanPln") .And. TableInDic("DL9")
			If DTQ->DTQ_STATUS == '9'
				//Cancela planejamento de demandas
				TMSCanPln(DTQ->DTQ_VIAGEM, "8")
			Else
				TMSCanPln(DTQ->DTQ_VIAGEM, "7")
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aAreaDUD )
RestArea( aAreaDTQ )

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA360VDoc³ Autor ³ Eduardo de Souza     ³ Data ³ 14/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe ocorrencias do mesmo tipo por documentos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA360VDoc( ExpC1, ExpC2, ExpC3, ExpC4 )                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial do Documento                                ³±±
±±³          ³ ExpC2 = Documento                                          ³±±
±±³          ³ ExpC3 = Serie Documento                                    ³±±
±±³          ³ ExpC4 = Tipo da Ocorrencia                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA360VDoc(cFilDoc,cDocto,cSerie,cTipOco,cFilOco,cNumOco)

Local lRet     := .F.
Local aAreaDUA := DUA->(GetArea())
Local aAreaDT2 := DT2->(GetArea())

DUA->(DbSetOrder(4))
If DUA->(DbSeek(xFilial("DUA")+cFilDoc+cDocto+cSerie))
	While DUA->(!Eof()) .And. DUA->DUA_FILIAL + DUA->DUA_FILDOC + DUA->DUA_DOC + DUA->DUA_SERIE == xFilial("DUA") + cFilDoc + cDocto + cSerie
		If Empty(DUA->DUA_FILORI) .And. Empty(DUA->DUA_VIAGEM) .And. ;
			( cFilOco + cNumOco <> DUA->DUA_FILOCO + DUA->DUA_NUMOCO )
			If cTipOco == Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_TIPOCO")
				lRet := .T.
				Exit
			EndIf
		EndIf
		DUA->(DbSkip())
	EndDo
EndIf

RestArea( aAreaDUA )
RestArea( aAreaDT2 )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360Enc ³ Autor ³ Eduardo de Souza     ³ Data ³ 09/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se devera encerrar a viagem                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA360Enc(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Origem                                      ³±±
±±³          ³ ExpC2 - Viagem                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360Enc(cFilOri,cViagem,lInfKm)

Local aArea     := GetArea()
Local cAliasNew := ''
Local cQuery    := ''
Local lRet      := .F.
Local lCont	    := .T.
Local lLibVgBlq := SuperGetMV('MV_LIBVGBL',,.F.)  //-- Libera Encerramento de viagens com ocorrencia do tipo
Default lInfKm  := .T. 

//-- Verifica se no transporte nao ha Documento encerrados e ja criados para a entrega em aberto
If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS))
	cAliasNew := GetNextAlias()

	cQuery := " SELECT COUNT(DUD.DUD_FILIAL) CNT "
	cQuery += "   FROM " + RetSqlName("DUD") +" DUD "
	cQuery += " JOIN  "+ RetSqlName("DUD") +" DUD1 ON DUD1.DUD_FILDOC = DUD.DUD_FILDOC	"
	cQuery += "   AND DUD1.DUD_DOC = DUD.DUD_DOC "
	cQuery += "   AND DUD1.DUD_SERIE = DUD.DUD_SERIE	"
	cQuery += "   AND DUD1.DUD_FILIAL = '" + xFilial("DUD") + "' "
	cQuery += "   AND DUD1.DUD_SERTMS = '" + StrZero(3,Len(DUD->DUD_SERTMS)) + "' "
	cQuery += "   AND DUD1.DUD_STATUS <> '" + StrZero(4,Len(DUD->DUD_STATUS)) + "' "
	cQuery += "   AND DUD1.DUD_STATUS <> '" + StrZero(9,Len(DUD->DUD_STATUS)) + "' "
	cQuery += "   AND DUD1.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN " + RetSqlName("DT6") + " DT6 ON DT6.DT6_FILDOC = DUD.DUD_FILDOC "
	cQuery += "   AND DT6.DT6_DOC = DUD.DUD_DOC "
	cQuery += "   AND DT6.DT6_SERIE = DUD.DUD_SERIE "
	cQuery += "   AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
	cQuery += "   AND DT6.DT6_BLQDOC <> '"  + StrZero(1,Len( DT6->DT6_BLQDOC ) ) + "' "
	cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
	cQuery += "   AND DUD.DUD_FILORI = '" + cFilOri + "' "
	cQuery += "   AND DUD.DUD_VIAGEM = '" + cViagem + "' "
	cQuery += "   AND DUD.DUD_SERTMS = '" + StrZero(2,Len(DUD->DUD_SERTMS)) + "' "
	cQuery += "   AND DUD.DUD_STATUS = '" + StrZero(4,Len(DUD->DUD_STATUS)) + "' "
	cQuery += "   AND DUD.DUD_STATUS <> '" + StrZero(9,Len(DUD->DUD_STATUS)) + "' "
	cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )

	If (cAliasNew)->CNT >= 1 .And. lInfKm
		lCont := .F.
	EndIf
	(cAliasNew)->(DbCloseArea())
EndIf

//-- Verifica se a viagem está com chegada em filial
lCont := (DTQ->DTQ_STATUS = StrZero(4,Len(DTQ->DTQ_STATUS)))

If lCont
	cAliasNew := GetNextAlias()

	cQuery := " SELECT COUNT(DUD_FILIAL) CNT "
	cQuery += "   FROM " + RetSqlName("DUD")
	cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
	cQuery += "     AND DUD_FILORI = '" + cFilOri + "' "
	cQuery += "     AND DUD_VIAGEM = '" + cViagem + "' "
	cQuery += "     AND DUD_STATUS <> '" + StrZero(4,Len(DUD->DUD_STATUS)) + "' "
	cQuery += "     AND DUD_STATUS <> '" + StrZero(9,Len(DUD->DUD_STATUS)) + "' "
	cQuery += "     AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )

	If (cAliasNew)->CNT == 0 .And. lInfKm
		lRet := .T.
	EndIf
	(cAliasNew)->(DbCloseArea())

	If !lRet .And. lLibVgBlq
		lRet:= T340VerDoc()
	EndIf
EndIf

RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA360Qry ³ Autor ³ Valdemar Roberto     ³ Data ³ 21/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe ocorrencia que gera armazenagem         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA360Qry( ExpC1, ExpC2, ExpC3 )                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial do Documento                                ³±±
±±³          ³ ExpC2 = Documento                                          ³±±
±±³          ³ ExpC3 = Serie Documento                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA360Qry(cFilDoc,cDoc,cSerie)

Local cAliasQry := ""
Local cQuery    := ""
Local cOcorArm  := SuperGetMv('MV_OCORARM',,'')
Local dDatOco   := CTOD("")
Local aRetPE    := {}

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""

//-- ExecBlock TM360OCO
//-- Ponto               : Apos obter as ocorrencias dos parametros MV_OCORARM
//-- Parametros Enviados : Array com a seguinte informacao:
//--                       PARAMIXB[01] = Codigo das ocorrencias que geram armazenagem.
//--
//-- Retorno Esperado    : Array no seguinte formato:
//--                       aRetPE[01] = Codigo das ocorrencias que geram armazenagem.
If ExistBlock('TM360OCO')
	aRetPE:= ExecBlock("TM360OCO",.F.,.F., {cOcorArm})
	If !Empty(aRetPE) .And. len(aRetPE) = 1
		If !Empty(aRetPE[1])
		   cOcorArm:=aRetPE[1]
		EndIf
	EndIf
EndIf

cAliasQry := GetNextAlias()
cQuery := " SELECT DUA_DATOCO,DUA_HOROCO,DUA_CODOCO"
cQuery += "   FROM  " + RetSqlName("DUA") + " DUA "
cQuery += "  WHERE DUA_FILIAL = '" + xFilial("DUA") + "' "
cQuery += "    AND DUA_FILDOC = '" + cFilDoc + "' "
cQuery += "    AND DUA_DOC    = '" + cDoc    + "' "
cQuery += "    AND DUA_SERIE  = '" + cSerie  + "' "
cQuery += "    AND D_E_L_E_T_ = ' ' "
cQuery += "  ORDER BY DUA_DATOCO,DUA_HOROCO"

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
TCSetField(cAliasQry,"DUA_DATOCO","D",8,0)
While (cAliasQry)->(!Eof())
	If AllTrim((cAliasQry)->DUA_CODOCO) $ cOcorArm
		dDatOco := (cAliasQry)->DUA_DATOCO
		Exit
	EndIf
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())
DbSelectArea("DT6")

Return( dDatOco )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360Psq³ Autor ³ Patricia A. Salomao   ³ Data ³11.07.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa documentos (Botao de Pesquisa)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA360Psq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360Psq()

Local aCbx	 := {}
Local cCampo := Space(40)
Local cOrd   := ''
Local lSeek	 := .F.
Local nOrdem := 1

Local nSeek	 := 0
Local oCbx
Local oDlg
Local oPsqGet

//-- (01) Fil.Docto. + No.Docto. + Serie
AAdd( aCbx,  AllTrim(FWX3Titulo('DUA_FILDOC')) + ' + ' + AllTrim(FWX3Titulo('DUA_DOC')) + ' + ' + AllTrim(FWX3Titulo('DUA_SERIE')) )

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0014 // 'Pesquisa'
	@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg ON CHANGE nOrdem := oCbx:nAt
	@ 22,05 MSGET oPsqGet VAR cCampo SIZE 206,10 PIXEL
	DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
	DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()
ACTIVATE MSDIALOG oDlg CENTERED

If	lSeek
	cCampo := AllTrim( cCampo )
	nSeek := Ascan( aCols,{ | x | PadR( x[GdFieldPos('DUA_FILDOC')]+x[GdFieldPos('DUA_DOC')]+x[GdFieldPos('DUA_SERIE')] , Len( cCampo ) ) == cCampo } )

	If	nSeek > 0
		oTMSGetD:oBrowse:nAT := nSeek
		oTMSGetD:oBrowse:Refresh( .T. )
		oTMSGetD:oBrowse:SetFocus()
	Else
		Help('',1,'TMSA36074') //"Documento Nao Encontrado !!!"
	EndIf
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA360Cols³ Autor ³ Patricia A. Salomao   ³ Data ³04.10.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta aCols Contendo os Documentos da Viagem                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA360Cols()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo informacoes sobre o documento.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA360Cols(aDoc)
Local lAAddACols := .F.
Local cHorOco    := ''
Local cCodOco    := ''
Local cDatOco    := ''
Local nCntFor    := 0
Local nCnt       := 0
Local nOld       := n
Local n1Lin      := n
Local cFileLog   := NomeAutoLog()
Local aDocOld    := {}
Local lRet       := .T.
Local lDUAPrzEnt := DUA->(ColumnPos("DUA_PRZENT")) > 0 
Local lJob360    := IsBlind()   

Private lMsHelpAuto := .F.

lWserver := If (Type("lWserver") == "U",.F.,lWserver)
If lTM360DOC
   aDocOld := aClone(aDoc)
   aDoc    := EXECBLOCK('TM360DOC',.F.,.F.,{aDoc})
   If Valtype(aDoc) <> 'A'
      aDoc := aClone(aDocOld)
   EndIf
EndIf

For nCntFor := 1 to Len(aDoc)
	If ( Ascan(aCols, {|x| !x[Len(x)] .And. x[GdFieldPos('DUA_FILDOC')]+x[GdFieldPos('DUA_DOC')]+x[GdFieldPos('DUA_SERIE')] ==  aDoc[nCntFor][1] + aDoc[nCntFor][2] + aDoc[nCntFor][3] }) == 0 )
		nOld := n

	   If TMA360VlDoc(aDoc[nCntFor][1], aDoc[nCntFor][2], aDoc[nCntFor][3], aDoc, M->DUA_FILORI, M->DUA_VIAGEM ) //-- Valida o Documento
			cItem :=StrZero(n,Len(DUA->DUA_SEQOCO))
			If lAAddACols //-- Adiciona uma linha no aCols
				n++
				AAdd(aCols,Array(Len(aHeader)+1))
				For nCnt := 1 To Len(aHeader)
					aCols[Len(aCols),nCnt] := CriaVar(aHeader[nCnt,2])
				Next
				aCols[Len(aCols),Len(aHeader)+1] := .F.
				cItem := Soma1(cItem)
			Else
				lAAddACols := .T.
				cDatOco := GDFieldGet( 'DUA_DATOCO', n )
				cHorOco := GDFieldGet( 'DUA_HOROCO', n )
			EndIf
			cCodOco := M->DUA_CODOCO

			DT6->( DbSetOrder( 1 ) )
			DT6->( DbSeek( xFilial('DT6') + aDoc[nCntFor][1] + aDoc[nCntFor][2] + aDoc[nCntFor][3]) )

			If Empty(cDatOco) .AND. Empty(cHorOco) .AND. !Empty(GetSx3Cache("DUA_DATOCO","X3_RELACAO"))
				GDFieldPut( 'DUA_DATOCO', dDataBase, n )
				GDFieldPut( 'DUA_HOROCO', Strtran(Left(Time(),5),":",""), n )
			Else
				GDFieldPut( 'DUA_DATOCO', cDatOco, n )
				GDFieldPut( 'DUA_HOROCO', cHorOco, n )
			EndIf
			GDFieldPut( 'DUA_SEQOCO', cItem , n )
			GDFieldPut( 'DUA_CODOCO', cCodOco, n )
			GdFieldPut( 'DUA_DESOCO', Posicione("DT2",1,xFilial("DT2")+cCodOco,"DT2_DESCRI"),n)
			GDFieldPut( 'DUA_FILDOC', aDoc[nCntFor][1] , n )
			GDFieldPut( 'DUA_DOC'   , aDoc[nCntFor][2] , n )
			GDFieldPut( 'DUA_SERIE' , aDoc[nCntFor][3] , n )
			GDFieldPut( 'DUA_QTDVOL', DT6->DT6_QTDVOL  , n )
			GDFieldPut( 'DUA_PESO',   DT6->DT6_PESO    , n )
			GDFieldPut( 'DUA_QTDOCO', DT6->DT6_QTDVOL  , n )
			GDFieldPut( 'DUA_PESOCO', DT6->DT6_PESO    , n )
			GDFieldPut( 'DUA_VOLORI', DT6->DT6_VOLORI  , n )

			//-- Atualiza Campos Conforme Documentos (DT6)
			If DT6->(Found())
				If GdFieldPos('DUA_VALMER') > 0
					GDFieldPut( 'DUA_VALMER', DT6->DT6_VALMER	, n )
					GDFieldPut( 'DUA_VLROCO', DT6->DT6_VALMER	, n )
				EndIf

				If GdFieldPos('DUA_PESOM3') > 0
					GDFieldPut( 'DUA_PESOM3', DT6->DT6_PESOM3	, n )
					GDFieldPut( 'DUA_PM3OCO', DT6->DT6_PESOM3	, n )
				EndIf

				If GdFieldPos('DUA_METRO3') > 0
					GDFieldPut( 'DUA_METRO3', DT6->DT6_METRO3	, n )
					GDFieldPut( 'DUA_MT3OCO', DT6->DT6_METRO3	, n )
				EndIf

				If GdFieldPos('DUA_QTDUNI') > 0
					GDFieldPut( 'DUA_QTDUNI', DT6->DT6_QTDUNI	, n )
					GDFieldPut( 'DUA_QTUOCO', DT6->DT6_QTDUNI	, n )
				EndIf

				If GdFieldPos('DUA_BASSEG') > 0
					GDFieldPut( 'DUA_BASSEG', DT6->DT6_BASSEG	, n )
					GDFieldPut( 'DUA_BASOCO', DT6->DT6_BASSEG	, n )
				EndIf
				//--- Prazo de Entrega
				If lDUAPrzEnt .And. DT2->(ColumnPos("DT2_PRZENT")) > 0 
					If Posicione("DT2",1,xFilial("DT2")+cCodOco,"DT2_PRZENT") == StrZero(1,Len(DT2->DT2_PRZENT)) 
						GDFieldPut("DUA_PRZENT",DT6->DT6_PRZENT,n)
					EndIf	
				EndIf	
			EndIf
		Else
			n := nOld	//-- Volta a linha Anterior
			lRet := .F.
			Exit
		EndIf
	Else
		DT6->( DbSetOrder( 1 ) )
		If DT6->( DbSeek( xFilial('DT6') + aDoc[nCntFor][1] + aDoc[nCntFor][2] + aDoc[nCntFor][3]) )
		   GDFieldPut( 'DUA_VOLORI', DT6->DT6_VOLORI, n)
		EndIf
	EndIf
Next

If Type("oTmsGetD") == "O"
	n := n1Lin
	oTmsGetD:oBrowse:nAt:=n
	oTMSGetD:oBrowse:Refresh( .T. )
EndIf
If l360Auto .And. !lWserver
	cFileLog := NomeAutoLog()
	If !Empty(cFileLog) .And. !lJob360
		MostraErro()
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA360VlDo³ Autor ³ Patricia A. Salomao   ³ Data ³04.10.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao do Documento                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA360VlDoc()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1- Filial do Documento                                 ³±±
±±³          ³ ExpC2- Documento                                           ³±±
±±³          ³ ExpC3- Serie                                               ³±±
±±³          ³ ExpA1- Vetor com os documentos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA360VlDoc(cFilDoc, cDoc, cSerie, aDoc, cFilOri, cViagem) //-- Valida o Documento

Local lRet        := .T.
Local cTipOco     := ""
Local cSerTMS     := ""
Local cCatOco     := ""
Local cSeek       := ""
Local cFilAli     := ""
Local cVarOld     := ""
Local lOcoDoc     := SuperGetMv("MV_OCODOC",,.F.)   //-- Categoria da Ocorrencia por Docto.: Considera todos os Documentos da Viagem ?
Local nCnt        := 0
Local lTmsCFec    := TmsCFec() //-- Carga Fechada
Local cProg       := FunName() //-- Programa que chamou a rotina de ocorrencias
Local cDocTMS     := SuperGetMv('MV_TPDCARM',,'')   //-- Quais doctos geram armazenagem
Local cOcorArm    := SuperGetMv('MV_OCORARM',,'')   //--Ocorrencia que gera armazenagem
Local cSerArm     := SuperGetMv('MV_SERARM',,'')		//-- Qual servico para armazenagem ?
Local cFilPesq    := ''
Local lMv_TmsOcoL := SuperGetMv("MV_TMSOCOL",.F.,.F.) //-- Permite informar a ocorrencia do documento de outra filial.
Local aPerfil     := {}
Local aRetPE      := {}
Local lLibVgBlq   := SuperGetMV('MV_LIBVGBL',,.F.)  //-- Libera Encerramento de viagens com ocorrencia do tipo
Local aFilDca     := {}
Local nSeek       := 0
Local aAreaDTQ    := {}
Local lGrvDUD     := .F.
Local lDocRed     := .F.
Local cTipPen     := ""
Local lDocEntre   := .F.
Local nTmsdInd    := SuperGetMv('MV_TMSDIND',.F.,0) // Dias permitidos para indenizacao apos o documento entregue
Local lMv_TmsPNDB := SuperGetMv("MV_TMSPNDB",.F.,.F.) //-- Permite informar a ocorrencia de Pendencia para um Docto Bloqueado
Local lBloqueado  := .F.
Local lRotDUD     := Iif(FindFunction('TMSChvDUD'),.T.,.F.)

Default cFilDoc	:= ""
Default cDoc	:= ""
Default cSerie	:= ""
Default cFilOri := ''
Default cViagem := ''
Default aDoc    := {}

//-- ExecBlock TM360OCO
//-- Ponto               : Apos obter as ocorrencias dos parametros MV_OCORARM
//-- Parametros Enviados : Array com a seguinte informacao:
//--                       PARAMIXB[01] = Codigo das ocorrencias que geram armazenagem.
//--
//-- Retorno Esperado    : Array no seguinte formato:
//--                       aRetPE[01] = Codigo das ocorrencias que geram armazenagem.
If ExistBlock('TM360OCO')
	aRetPE:= ExecBlock("TM360OCO",.F.,.F., {cOcorArm})
	If !Empty(aRetPE) .And. len(aRetPE) = 1
		If !Empty(aRetPE[1])
		   cOcorArm:=aRetPE[1]
		EndIf
	EndIf
EndIf

DTQ->(DbSetOrder(2))
If DTQ->(DbSeek(xFilial("DTQ")+M->DUA_FILORI+M->DUA_VIAGEM))
	//-- Obtem as filiais de descarga da rota
	aFilDca := TMSRegDca(DTQ->DTQ_ROTA)
EndIf

DT2->(DbSetOrder(1))
DT2->(DbSeek(xFilial("DT2")+ M->DUA_CODOCO ))
cTipOco := DT2->DT2_TIPOCO
cSerTMS := DT2->DT2_SERTMS
cCatOco := DT2->DT2_CATOCO
cTipPen := DT2->DT2_TIPPND
cSeek   := cFilDoc+cDoc+cSerie

// Verifica o serviço da viagem
DTQ->( DbSetOrder( 2 ) )
If Empty(cSerTms) .AND. DTQ->( DbSeek( xFilial('DTQ') + cFilOri + cViagem ) )
	cSerTms := DTQ->DTQ_SERTMS
EndIf

// Verifica serviço por documento
DT6->( DbSetOrder( 1 ) )
If Empty(cSerTms) .AND. DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
	cSerTms := DT6->DT6_SERTMS
EndIf

cSeek := cFilDoc+cDoc+cSerie

If l360Auto .And.;
	(cCatOco == StrZero(2,Len(DT2->DT2_CATOCO)) .Or. ( cCatOco == StrZero(1,Len(DT2->DT2_CATOCO)) .And.;
	lOcoDoc .And. !Empty(M->DUA_FILORI) .And. !Empty(M->DUA_VIAGEM) )) //-- Considera todos os Documentos da Viagem

	lMsHelpAuto := .T.
EndIf

If cTipOco <> StrZero(13, Len(DT2->DT2_TIPOCO)) //-- A ocorrencia de Chegada Eventual pode ser apontada em qualquer filial
	If !lMv_TmsOcoL //-- Permite informar a ocorrencia do documento de outra filial.
	   //-- Somente apontar ocorrencia na filial em que o documento se encontra ou filial parceiro (alianca).
		DUD->(DbSetOrder(1))
		DUD->(DbSeek(xFilial('DUD')+cSeek))
		While DUD->(!Eof()) .And. DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE) == xFilial('DUD')+cSeek
			If DUD->DUD_SERTMS == cSerTMS
				If cTipOco == StrZero(5,Len(DT2->DT2_TIPOCO)) .Or. ;
					DUD->DUD_STATUS == StrZero(4,Len(DUD->DUD_STATUS)) .Or. ;
					DUD->DUD_STATUS == StrZero(9,Len(DUD->DUD_STATUS))
					DUD->(dbSkip())
					Loop
			   EndIf

			   //-- Se DUD de Transferencia E ocorrencia de Bloqueia ou libera Doc.
			   //-- E Filiais de descarga da Rota igual a cFilAnt, permite o apontamento.
			   If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS))
					If (cTipOco == StrZero(2,Len(DT2->DT2_TIPOCO)) .Or. cTipOco == StrZero(3,Len(DT2->DT2_TIPOCO)))
						If Empty(M->DUA_FILORI) .And. Empty(M->DUA_VIAGEM)
							//Verifica a Rota de descarga referente a viagem do documento
							aAreaDTQ:= DTQ->(GetArea())
							DTQ->(DbSetOrder(2))
							If DTQ->(DbSeek(xFilial("DUD")+DUD->DUD_FILORI+DUD->DUD_VIAGEM))
								aFilDca := TMSRegDca(DTQ->DTQ_ROTA)
							EndIf
							RestArea(aAreaDTQ)
					   EndIf

						If !Empty(aFilDca)
							nSeek := 0
							nSeek := Ascan(aFilDca,{|x|x[3] == cFilAnt })
							If	nSeek > 0
								DUD->(dbSkip())
								Loop
							EndIf
						EndIf
					EndIf
				EndIf

				If IIF(!Empty(DUD->DUD_FILATU), DUD->DUD_FILATU, DUD->DUD_FILORI)  <> cFilAnt .And. ;
					Empty(cFilAli := Posicione("DVL",1,xFilial("DVL")+DUD->DUD_FILORI,"DVL_FILALI")) //-- filial parceiro (alianca)
					Help("",1,"TMSA36065",, IIF(!Empty(DUD->DUD_FILATU), DUD->DUD_FILATU, DUD->DUD_FILORI),3,12) //"O Registro de Ocorrencias deste Documento devera ser apontado na Filial: "
					Return( .F. )
				EndIf
				Exit
			Else
				DUD->(dbSkip())
			EndIf
		EndDo
	EndIf
EndIf

//Bloqueia apontamento de ocorrencia do tipo Chegada eventual na filial de origem do documento.
DUD->(DbSetOrder(1))
DUD->(DbSeek(xFilial('DUD')+cSeek))
If 	cTipOco == StrZero(13, Len(DT2->DT2_TIPOCO)) .And. DUD->DUD_SERTMS == cSerTMS .And. ;
	cFilAnt == DUD->DUD_FILORI
		Help('',1, 'TMSA360A5' ) //-- Nao e possível apontar ocorrencia de Chegada Eventual na propria filial do documento.
		Return( .F. )
EndIf

DT6->(DbSetOrder(1))
If !DT6->(DbSeek(xFilial("DT6") + cSeek))
	TmsInfSinc({"DUA","DUA_DOC",Nil,cSeek}) //-- Gera ocorrencia para o sincronizador
	Help( '', 1, 'REGNOIS' ) //Nao existe registro relacionado a este codigo.
	Return( .F. )
EndIf

If cTipOco == StrZero( 9, Len(DT2->DT2_TIPOCO) )	// Gera Indenizacao
	//-- Manutencoes que gerem indenizacoes em doc pertencente a outra filial nao serao permitidas
	If !TMSChkViag( DT6->DT6_FILVGA, DT6->DT6_NUMVGA, .F., .F., .F., , .F., .F., .F.,,,,,.F.,,, .T.,,,,cTipOco )
		M->DUA_FILDOC := Space(Len(M->DUA_FILDOC))
		M->DUA_DOC := Space(Len(M->DUA_DOC))
		M->DUA_SERIE := Space(Len(M->DUA_SERIE))
		Return( .F. )
	Endif
EndIf

//-- Verifica se a ocorrencia e' Gera Pendencia/Indenizacao para um documento ja entregue,
//-- permitindo a digitacao da ocorrencia no prazo determinado pelo parametro MV_TMSDIND
lDocEntre:= .F.
If nTmsdInd > 0 .And. (cTipOco == StrZero(6,Len(DT2->DT2_TIPOCO)) .Or. cTipOco == StrZero(9,Len(DT2->DT2_TIPOCO)) ) .And.;
	cTipPen <> StrZero(4,Len(DT2->DT2_TIPPND))
		If (dDataBase - DT6->DT6_DATENT) <= nTmsdInd
			lDocEntre:= .T.
		EndIf
EndIf

//Validacao para gerar documentos de armazenagem
If DT6->DT6_DOCTMS $ cDocTMS .And. cTipOco == StrZero( 1, Len( DT2->DT2_TIPOCO ) ) // Tipo de documento gera armazenagem?
	aPerfil := TmsPerfil(DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,,,DT6->DT6_CLIREM,DT6->DT6_LOJREM,DT6->DT6_CLIDES,DT6->DT6_LOJDES)
	If Len(aPerfil) >= 38
		If aPerfil[38] == "1" .And. DT6->DT6_VALTOT >= aPerfil[43] // Valor do documento maior ou igual ao minimo do original
			If Empty(cOcorArm)
				Help('',1,'TMSA36076')	//"Preencha o parametro MV_OCORARM"
				Return( .F. )
			EndIf
			If Empty(cSerArm)
				Help('',1,'TMSA36077')	//"Preencha o parametro MV_SERARM"
				Return( .F. )
			EndIf
		EndIf
	EndIf
EndIf

If  lRet
	If Empty(cFilOri)
		cFilPesq := If(!Empty(cFilAli),cFilAli,cFilAnt)
	Else
		cFilPesq := cFilOri
	EndIf

	cVarOld := __Readvar

	//-- Verifica se o documento Redespacho
	lDocRed  := TMA360IDFV( cFilDoc,cDoc,cSerie,.F.,M->DUA_FILORI,M->DUA_VIAGEM )

	DUD->(DbSetOrder(1))
	DUD->(DbSeek(xFilial('DUD')+cFilDoc+cDoc+cSerie+cFilPesq+cViagem))
	While DUD->(!Eof()) .And. DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI) == xFilial('DUD')+cFilDoc+cDoc+cSerie+If(!Empty(cFilAli),cFilAli,cFilAnt)
		If ( DUD->DUD_STATUS == StrZero(4,Len(DUD->DUD_STATUS)) .Or. DUD->DUD_STATUS == StrZero(9,Len(DUD->DUD_STATUS)))
			lGrvDUD:= .T.

			If cTipOco <> StrZero(5,Len(DT2->DT2_TIPOCO))
				lGrvDUD:= .F.
				If cTipOco == StrZero(3,Len(DT2->DT2_TIPOCO)) 	.And. DT6->DT6_BLQDOC=='1'
					lGrvDUD:=.T.
				EndIf
			Else
				//Redespacho, parametro MV_OCORRDP - Ocorrencia "Informativa" para Baixa,
				//documentos somente com status diferente de 4(Encerrado) e 9(Cancelado)
				If lDocRed
					If DUD->DUD_STATUS == StrZero(4,Len(DUD->DUD_STATUS))
						lGrvDUD:=.T.
					Else
						lGrvDUD:= .F.
					EndIf
				EndIf
			EndIf

			If !lGrvDUD
				DUD->(dbSkip())
				Loop
			EndIf
		EndIf
		If DUD->DUD_SERTMS <> cSerTms .AND. !Empty(cSerTms)
			If cSerTMS == StrZero(2,Len(DT2->DT2_SERTMS)) .And. DUD->DUD_SERTMS == StrZero(3,Len(DUD->DUD_SERTMS)) .And. Empty(DUD->DUD_VIAGEM)
				M->DUA_FILORI := DUD->DUD_FILVGE
				M->DUA_VIAGEM := DUD->DUD_NUMVGE
			Else
				If DT2->DT2_TIPOCO != StrZero(5,Len(DT2->DT2_TIPOCO)) .And. DTQ->DTQ_SERADI != '1'
					Help(' ', 1, 'TMSA36060')  //-- 'Servico de Transporte da ocorrencia diferente do servico do documento !!!'
					Return( .F. )
				EndIf
			EndIf
		ElseIf !Empty(DUD->DUD_VIAGEM) .And. (Empty(M->DUA_FILORI) .Or. Empty(M->DUA_VIAGEM))
			//-- Valida os campos ja informados
			For nCnt := 1 To FCount()
				cCposVld := FieldName(nCnt)
				If !( cCposVld $ "M->DUA_FILDOC.M->DUA_DOC.M->DUA_SERIE" ) .And. !Empty(GDFieldGet(cCposVld,n))
					__Readvar  := "M->"+cCposVld
					&__ReadVar := GDFieldGet(cCposVld,n)
					If !TMSA360Vld(,.F.)
						Return( .F. )
					EndIf
				EndIf
			Next nCnt
			//Somente ocorrencias por Viagem devem ter a viagem gatilhada.
			If DT2->DT2_CATOCO == StrZero(2, Len(DT2->DT2_CATOCO)) .And. Empty(M->DUA_FILORI) .And. Empty(M->DUA_VIAGEM)
				M->DUA_FILORI := DUD->DUD_FILORI
				M->DUA_VIAGEM := DUD->DUD_VIAGEM
			EndIf
		EndIf
		__Readvar     := "M->DUA_VIAGEM"
		If !TMSA360Vld(,.F.)
			M->DUA_FILORI := CriaVar("DUA_FILORI",.F.)
			M->DUA_VIAGEM := CriaVar("DUD_VIAGEM",.F.)
			Return( .F. )
		EndIf
		If !l360Auto
			oTmsEnch:Refresh(.T.)
		EndIf
		If(AllTrim(M->DUA_FILORI) == '' .And. AllTrim(M->DUA_VIAGEM) == '' .And. cTipOco == StrZero(3,Len(DT2->DT2_TIPOCO)) .And. DT6->DT6_BLQDOC=='1')
			Exit
		EndIf
		DUD->(DbSkip())
	EndDo
	__ReadVar :=  cVarOld
EndIf

If	lRet .And. cTipOco != StrZero(5,Len(DT2->DT2_TIPOCO)) .And. DT6->DT6_STATUS == StrZero( 7, Len( DT6->DT6_STATUS ) );
	.And. !lDocEntre .And. aScan( aRecDep, cTipOco) == 0 ;
	.And. Iif(lRotDUD,!TMSChvDUD(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE),.T.)  //-- Tratamento Rentabilidade/Ocorrencia
	Help( '', 1, 'TMSA36052' ) //-- Documento ja Entregue
	Return( .F. )
EndIf

//-- Encerra Processo
If cTipOco == StrZero( 1, Len( DT2->DT2_TIPOCO ) ) .And. DTQ->DTQ_SERTMS == StrZero(2, Len(DTQ->DTQ_SERTMS))
	If !(DT6->DT6_STATUS $ "4,5,6") //-- Cheg. Parcial, Cheg. Final ou Indicado para Entrega
		Help('',1, 'TMSA36057' ) //-- Esta ocorrencia somente podera ser lancada para documentos com status de Chegada Parcial, Chegada Final ou Indicado para Entrega
		Return( .F. )
	EndIf
EndIf

//-- Transferencia por Documento
If cTipOco == StrZero(8, Len(DT2->DT2_TIPOCO))
	//-- Nao permite a Transferencia se o Documento nao estiver em transito
	DUD->( DbSetOrder( 1 ) )
	If DUD->( DbSeek( xFilial('DUD') + cSeek+ M->DUA_FILORI+ M->DUA_VIAGEM) )  .And. ;
		DUD->DUD_STATUS <> StrZero(2, Len(DUD->DUD_STATUS))
		Help("",1,"TMSA36043") //-- So e permitido a Transferencia de Documentos com Status 2 (Em Transito)
		Return( .F. )
	EndIf
EndIf

//-- Chegada Eventual
If cTipOco == StrZero(13, Len(DT2->DT2_TIPOCO))
	//-- Nao permite a Transferencia se o Documento nao estiver em transito
	DUD->( DbSetOrder( 1 ) )
	If DUD->( DbSeek( xFilial('DUD') + cSeek + M->DUA_FILORI+ M->DUA_VIAGEM) )  .And. ;
		DUD->DUD_STATUS <> StrZero(2, Len(DUD->DUD_STATUS))
		Help('',1, 'TMSA36066') //"So e permitido a Chegada Eventual de Documentos com Status 2 (Em Transito)"
		Return( .F. )
	EndIf
EndIf

If cCatOco == StrZero(1,Len(DT2->DT2_CATOCO)) .And. !Empty(GDFieldGet( 'DUA_CODOCO', n ))  //-- Se a categoria da Ocorrencia for por 'Documento'
	//-- Esta Funcao valida o Documento e preenche o vetor aDoc
	//-- Esta funcao tambem e' executada na LinhaOk(); Sendo assim, se a ocorrencia for 'por Viagem', nao e' necessario executar esta funcao neste ponto.
	lRet := TMSA360Vdc(cFilDoc, cDoc, cSerie,,aDoc)
	If lRet
		TMSA360Vol(GDFieldGet( 'DUA_CODOCO', n ), cFilDoc, cDoc, cSerie)
	EndIf
EndIf

//-- Ocorrência por viagem com serviço adicional de entrega deve utilizar uma ocorrência com o DT2_SERTMS vazio
If cCatOco == StrZero(2,Len(DT2->DT2_CATOCO)) .And. !Empty(DT2->DT2_SERTMS) .And. DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_SERADI == '1'
	Help('',1, 'TMSA360E9') //"Viagem de entrega com serviço adicional de coleta, não pode receber ocorrências com categoria por viagem, informe uma ocorrência por viagem configurada com o serviço vazio, ou utilize a opção de ocorrência por documento"
	Return( .F. )
EndIf

// 11 - Transferencia de Mercadoria.
If lRet .And. cTipOco == StrZero(11, Len(DT2->DT2_TIPOCO))
	// Nao permite a Transferencia de Mercadoria em viagem.
	DUD->( DbSetOrder( 1 ) )
	If DUD->( DbSeek( xFilial('DUD') + cSeek + cFilAnt ) )  .And. !Empty(DUD->DUD_VIAGEM)
		Help("",1,"TMSA36050") //-- Nao e permitido a Transferencia de Mercadoria em Viagem.
		lRet := .F.
	EndIf
EndIf
/* Nao permite que seja informada uma ocorrencia de encerra processo para viagens com status: Em Aberto ou Fechada. */
aAreaDT6 := DT6->( GetArea() )
DT6->( DbSetOrder( 1 ) )
If lRet .And. DT6->( DbSeek( xFilial("DT6") + cSeek ) ) 
	If  DT6->DT6_SERTMS == StrZero( 1, Len( DT6->DT6_SERTMS ) ) // Coleta
		//-- Nao permite apontar uma ocorrencia para solicitacao com documento informado.
		If cTipOco <> StrZero(5, Len(DT2->DT2_TIPOCO)) // Diferente de Informativa
			DT5->(DbSetOrder( 4 ))
			If DT5->(DbSeek(xFilial('DT5') + cFilDoc + cDoc + cSerie ))
				If DT5->DT5_STATUS == StrZero(5,Len(DT5->DT5_STATUS)) //-- Documento Informado
					If cTipOco == StrZero(12,Len(DT2->DT2_TIPOCO))  //Cancelamento
						lRet:= .F.
						aAreaDTQ := DTQ->( GetArea() )
						DTQ->( DbSetOrder( 2 ) )
						If DTQ->( DbSeek( xFilial("DTQ") + M->DUA_FILORI + M->DUA_VIAGEM ) )
							If	DTQ->DTQ_TIPVIA == StrZero(3, Len(DTQ->DTQ_TIPVIA)) .And.;         //-- Planejada
								DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS))                 //-- Em aberto
								lRet:= .T.
							EndIf
						EndIf
						RestArea( aAreaDTQ )
					Else
						lRet:= .F.
					EndIf

					If !lRet
						Help("",1,"TMSA36059") // Existe Documento Informado para esta solicitacao, o lancamento sera automatico.
					EndIf
				EndIf
			EndIf
		EndIf
		If lRet .And. cTipOco == StrZero(1, Len(DT2->DT2_TIPOCO)) // Encerra processo.
			//-- Na Carga Fechada, qdo a chamada for efetuada a partir da rotina de notas fiscais,
			//   nao valida o status da viagem.
			If !( lTmsCFec .And. AllTrim(cProg) $ 'TMSA050,TMSAE81A,TMSAE81B' )
				aAreaDTQ := DTQ->( GetArea() )
				DTQ->( DbSetOrder( 2 ) )
				If DTQ->( DbSeek( xFilial("DTQ") + M->DUA_FILORI + M->DUA_VIAGEM ) ) .And.;
					( DTQ->DTQ_STATUS == StrZero( 1, Len( DTQ->DTQ_STATUS ) ) .Or. TMSDTQStatus( 5 ) ) // Em aberto ou Fechada.
					Help( "", 1, "TMSA36055" ) // Ocorrencia invalida para viagem com status: Em aberto ou Fechada.
					lRet := .F.
				EndIf
				RestArea( aAreaDTQ )
			EndIf
		EndIf
	Else
		If cTipOco == StrZero(12, Len(DT2->DT2_TIPOCO))  // Cancelamento de Coleta 
			Help( ,, 'HELP',, STR0128, 1, 0)  //O Tipo de Ocorrência "Cancelamento", só é permitido para Documentos de Coleta.
			Return( .F. )  
		EndIf
	EndIf
EndIf
RestArea( aAreaDT6 )

DUD->( DbSetOrder( 1 ) )
If lRet .And. DUD->( DbSeek( xFilial( 'DUD') + cFilDoc + cDoc + cSerie + M->DUA_FILORI + M->DUA_VIAGEM ) ) .And. !__lPyme .And. !lAjusta
	If	cTipOco <> StrZero(5,Len(DT2->DT2_TIPOCO)) .And. cTipOco != StrZero(17,Len(DT2->DT2_TIPOCO)) .And. ( DUD->DUD_STATUS == StrZero(9,Len(DUD->DUD_STATUS)) .Or. DUD->DUD_STATUS == StrZero(4,Len(DUD->DUD_STATUS)) ) .And. ;
		!lLibVgBlq
		//-- Documentos cancelados ou encerrados somente poderao receber ocorrencias do tipo "informativa"
		If	cTipOco != StrZero(5,Len(DT2->DT2_TIPOCO)) .And. aScan( aRecDep, DT2->DT2_TIPOCO) == 0 //-- Tratamento Rentabilidade/Ocorrencia
			If DUD->DUD_SERTMS <> StrZero(2,Len(DUD->DUD_SERTMS)) .And. cTipOco != StrZero(17,Len(DT2->DT2_TIPOCO)) .And. !lDocEntre

				//-- Docto de Redespacho podera apontar ocorrencia quando o status do documento estiver encerrado.
				If lDocRed .Or. !Empty(DUD->DUD_CHVEXT)
					lRet:= .T.
				Else
					Help('',1,'TMSA36063') //"Documentos cancelados ou encerrados somente poderão receber ocorrências do tipo 'Informativa'"
					lRet := .F.
				EndIf
			EndIf

		EndIf
		//-- Nao permite apontar uma ocorrencia para documentos encerrados, se a filial atual nao for a filial de descarga
		If	lRet .And. DUD->DUD_SERTMS != StrZero(1,Len(DUD->DUD_SERTMS)) .And. DUD->DUD_FILDCA != cFilAnt
			Help('',1,'TMSA36056') // Documento cancelado ou ocorrencia deve ser apontada na filial de descarga
			lRet := .F.
		EndIf
	EndIf
ElseIf lRet .And. __lPyme .And. !lAjusta
	DUD->( DbSetOrder( 7 ) )
	If DUD->( DbSeek( xFilial( 'DUD') + cFilDoc + cDoc + cSerie + M->DUA_NUMROM ) )
		If DUD->DUD_STATUS $ "4/9"
			If	cTipOco != StrZero(5,Len(DT2->DT2_TIPOCO)) .And. cTipOco != StrZero(17,Len(DT2->DT2_TIPOCO))
				If DUD->DUD_SERTMS <> StrZero(2,Len(DUD->DUD_SERTMS)) .And. !lDocEntre
					If lDocRed .Or. !Empty(DUD->DUD_CHVEXT)
						lRet:= .T.
					Else
						Help('',1,'TMSA36063') //"Documentos cancelados ou encerrados somente poderão receber ocorrências do tipo 'Informativa'"
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If	lRet
	//-- Se existir uma ocorrencia de Bloqueio Documento em aberto, significa que foi apontado uma pendencia para um docto bloqueado
	//-- e neste caso, deve permitir o Libera Documento, mesmo com pendencia em aberto, pois mesmo assim o documento permancerá bloqueado.
	If lMv_TmsPNDB
		lBloqueado:= TM360BLOQ(cFilDoc,cDoc,cSerie)
	EndIf

	If cTipOco == StrZero(3,Len(DT2->DT2_TIPOCO)) .Or. ;  //-- Libera Documento
		(lMv_TmsPNDB .And. DT6->DT6_BLQDOC == StrZero( 1, Len( DT6->DT6_BLQDOC ) ) .And. cTipOco == StrZero(6,Len(DT2->DT2_TIPOCO))  ) //-- Gera Pendencia
		//Verifica se o tipo de ocorrencia e do tipo que Libera Documento , e se For verifica se ja foi indenizado ou encerrado
		DUU->( DbSetOrder(3))
		If DUU->( DbSeek(cSeek := xFilial('DUU')+cFilDoc+cDoc+cSerie,.F.))
			Do While DUU->( cSeek == DUU_FILIAL+DUU_FILDOC+DUU_DOC+DUU_SERIE )
				If DUU->DUU_STATUS == StrZero(1,Len( DUU->DUU_STATUS )) .And. DUU->(DUU_FILORI+DUU_VIAGEM) == M->DUA_FILORI+M->DUA_VIAGEM
					If !lBloqueado
						lRet := .F.
						Help('',1,'TMSA360A1') //-- 'Para o tipo de ocorrencia "Libera Documento" existem pedencias que,nao podera estar em aberto
						Exit
					EndIf
				EndIf
				DUU->( DbSkip() )
			EndDo
		EndIf
		If lRet .And. cTipOco == StrZero(3,Len(DT2->DT2_TIPOCO)) //-- Libera Documento
			DUB->( DbSetOrder( 3 ) )
			If	DUB->( MsSeek( xFilial( 'DUB' ) + cFilDoc + cDoc + cSerie ) ) .And. DUB->DUB_STATUS != StrZero( 4, Len( DUB->DUB_STATUS ) )
				lRet := .F.
				Help('',1,'TMSA360A1') //-- 'Para o tipo de ocorrencia "Libera Documento" existem pedencias que,nao podera estar em aberto
			EndIf
		EndIf
	EndIf
EndIf
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSConsDW1 ³ Autor ³ Eduardo de Souza     ³ Data ³ 26/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta Filiais de Descarga do documento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSConsDW1()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA360                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSConsDW1()

Local lRet := TM360FilPnd()

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TM360FilPnd³ Autor ³ Eduardo de Souza     ³ Data ³ 26/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta Filiais de Descarga do documento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TM360FilPnd()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA360                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM360FilPnd(cFilPnd,lValid)

Local aArea     := GetArea()
Local aAreaSM0  := SM0->(GetArea())
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local aFilDca   := {}
Local aFilPnd   := {}
Local nCnt      := 0
Local aCampos   := {}
Local oTempTable:= NIL
Local cAliasTRB := GetNextAlias()
Local aRotOld   := aClone(aRotina)
Local cFilDoc   := Iif( Empty( GDFieldGet('DUA_FILDOC' ,n) ),M->DUA_FILDOC,GDFieldGet('DUA_FILDOC' ,n))
Local cDoc      := Iif( Empty( GDFieldGet('DUA_DOC'    ,n) ),M->DUA_DOC   ,GDFieldGet('DUA_DOC'    ,n))
Local cSerie    := Iif( Empty( GDFieldGet('DUA_SERIE'  ,n) ),M->DUA_SERIE ,GDFieldGet('DUA_SERIE'  ,n))
Default cFilPnd := ''
Default lValid  := .F.
Private aRotina := {}
Private nOpcSel := 0

//-- Variaveis declaradas na funcao principal
If Empty(cFilDoc) .And. Empty(cDoc) .And. Empty(cSerie)
	Return( .F. )
EndIf

AAdd(aCampos, { "FILDCA"    , "C", FWGETTAMFILIAL, 0 })
AAdd(aCampos, { "DESCRI"    , "C", 15, 0 })

If !lValid
	oTempTable := FWTemporaryTable():New(cAliasTRB)
	oTempTable:SetFields( aCampos )
	oTempTable:AddIndex("01", {"FILDCA"} )
	oTempTable:Create()
EndIf

cQuery := " SELECT DTQ_ROTA "
cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
cQuery += "   JOIN " + RetSqlName("DTQ") + " DTQ "
cQuery += "     ON DTQ_FILIAL   = '" + xFilial("DTQ") + "' "
cQuery += "     AND DTQ_FILORI  = DUD_FILORI "
cQuery += "     AND DTQ_VIAGEM  = DUD_VIAGEM "
cQuery += "     AND DTQ.D_E_L_E_T_ = ' ' "
cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "     AND DUD_FILDOC = '" + cFilDoc + "' "
cQuery += "     AND DUD_DOC    = '" + cDoc    + "' "
cQuery += "     AND DUD_SERIE  = '" + cSerie  + "' "
cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY DTQ_ROTA "
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
While (cAliasQry)->(!Eof())
	aFilDca := TMSRegDca((cAliasQry)->DTQ_ROTA)
	//-- Verifica se eh validacao do campo DUA_FILPND
	If lValid
		If Ascan(aFilDca,{ |x| x[3] == cFilPnd }) > 0
			Return( .T. )
		EndIf
	Else
		For nCnt := 1 To Len(aFilDca)
			If Ascan(aFilPnd,{ |x| x == aFilDca[nCnt,3] }) == 0
				//-- Atualiza arquivoo de trabalho, utilizado para apresentacao dos dados no MaWndBrowse.
				RecLock(cAliasTRB,.T.)
				(cAliasTRB)->FILDCA := aFilDca[nCnt,3]
				(cAliasTRB)->DESCRI := Posicione("SM0",1,cEmpAnt+aFilDca[nCnt,3],"M0_FILIAL")
				MsUnlock()
			EndIf
			AAdd(aFilPnd, aFilDca[nCnt,3] )
		Next nCnt
	EndIf
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())
RestArea( aArea )

//-- Verifica se eh validacao do campo DUA_FILPND
If lValid
	RestArea( aAreaSM0 )
	Return( .F. )
EndIf

aCampos := {}
AAdd( aCampos, { "FILDCA", "@!", RetTitle("DUN_FILDCA") , FWGETTAMFILIAL } )
AAdd( aCampos, { "DESCRI", "@!", 'Descrição' , 15 } )

aRotina	:= { { "Confirmar", "TMSConfSel",0,2,,,.T.} }

(cAliasTRB)->(DbGotop())
MaWndBrowse(0,0,300,600,'Filial Descarga',cAliasTRB,aCampos,aRotina,,,,.T.,,,,,.F.)

Var_Ixb := (cAliasTRB)->FILDCA

//-- Apaga os arquivos temporarios
oTempTable:Delete()

//-- Restaura Area anteior
aRotina := aClone(aRotOld)
RestArea( aArea )
RestArea( aAreaSM0 )

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA360Mail³ Autor ³Vitor Raspa         ³ Data ³ 26.Abr.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Prepara os dados da Ocorrencia para Envio do e-mail         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA360Mail(cFilOri,cViagem)
Local aArea			:= GetArea()
Local lSendMail		:= .F.
Local aDestE		:= {}
Local aDestI		:= {}
Local lEditMsg		:= .F.
Local cMsgErr		:= ''
Local nAux			:= 0
Local lOk			:= .F.
Local aDocs			:= {}
Local cQbrDoc		:= ''
Local cBody			:= ''
Local lTM360MAIL	:= ExistBlock('TM360MAIL')
Local aTM360MAIL	:= {}
Local cSerTMS		:= "" 	// Recebe o Serviço do TMS
Local lRet			:= .F.

Private cDOCTMS		:= ''

Default cFilOri := ''
Default cViagem := ''

Pergunte('TMA360',.F.)
If MV_PAR01 == 1 .And. !l360Auto
	lEditMsg := .T.
EndIf

For nAux := 1 To Len(aCols)

	If !GDDeleted(nAux)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³SE O DOCUMENTO FOI INFORMADO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty( GDFieldGet('DUA_DOC',nAux) )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³VERIFICA SE A OCORRENCIA ESTA HABILITADA PARA ENVIO DE E-MAIL³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³OCORRENCIA x E-MAIL EXTERNO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DT2->(DbSetOrder(1)) //DT2_FILIAL+DT2_CODOCO
			DT2->( DbSeek(xFilial('DT2') + GDFieldGet('DUA_CODOCO',nAux) ))
			If	DT2->DT2_MAILDV == '1' .Or. DT2->DT2_MAILRE == '1' .Or. DT2->DT2_MAILDT == '1' .Or.;
				DT2->DT2_MAILCS == '1' .Or. DT2->DT2_MAILDP == '1'
				lOk := .T.
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³OCORRENCIA x E-MAIL INTERNO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lOk
				DWU->(DbSetOrder(1)) //DWU_FILIAL+DWU_CODOCO+DWU_ID
				If DWU->( DbSeek(xFilial('DWU') +	GDFieldGet('DUA_CODOCO',nAux) ))
					lOk := .T.
				Else
					DWU->(DbSetOrder(2)) //DWU_FILIAL+DWU_TIPOCO+DWU_ID
					If DWU->( DbSeek(xFilial('DWU') +	DT2->DT2_TIPOCO) )
						lOk := .T.
					EndIf
				EndIf
			EndIf
			If lOk

				DTQ->( DbSetOrder( 2 ) )
				If !Empty(cFilOri) .And. !Empty(cViagem) .and.;
				 	(lRet := DTQ->( DbSeek( xFilial('DTQ') + cFilOri + cViagem ) ) )

					lRet := .T.

					// Verifica se serviço da viagem
					cSerTms := DTQ->DTQ_SERTMS

				Else
					// Verifica serviço por documento
					DT6->( DbSetOrder( 1 ) )
					If  Empty(cSerTms) .AND. DT6->( DbSeek( xFilial('DT6') + GDFieldGet('DUA_FILDOC',nAux) + GDFieldGet('DUA_DOC',nAux) + GDFieldGet('DUA_SERIE',nAux) ) )
						cSerTms := DT6->DT6_SERTMS
					Else
						// Serviço da Orcorrencia
						cSerTms := DT2->DT2_SERTMS
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³VIAGEM DE COLETA³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cSerTMS == StrZero(1,Len(DT2->DT2_SERTMS))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³VERIFICA SE A COLETA POSSUI AGENDAMENTO³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DF1->(DbSetOrder(3))
					If DF1->( DbSeek(xFilial('DF1') + GDFieldGet('DUA_FILDOC',nAux) + GDFieldGet('DUA_DOC',nAux) + GDFieldGet('DUA_SERIE',nAux)) )
						AAdd(aDocs, {	GDFieldGet('DUA_CODOCO',nAux),;
										DtoC(GDFieldGet('DUA_DATOCO',nAux)) + GDFieldGet('DUA_HOROCO',nAux),;
										GDFieldGet('DUA_FILDOC',nAux),;
										GDFieldGet('DUA_DOC',nAux),;
										GDFieldGet('DUA_SERIE',nAux),;
										DF1->DF1_CLIDEV+DF1->DF1_LOJDEV,;
										DF1->DF1_CLIREM+DF1->DF1_LOJREM,;
										DF1->DF1_CLIDES+DF1->DF1_LOJDES,;
										'',;
										'' } )
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³CASO NAO EXISTA AGENDAMENTO PARA A COLETA, VERIFICA OS DADOS DO SOLICITANTE³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DT5->(DbSetOrder(1))
						DT5->(DbSeek(xFilial('DT5') + GDFieldGet('DUA_FILDOC',nAux) + GDFieldGet('DUA_DOC',nAux) + GDFieldGet('DUA_SERIE',nAux)) )

						DUE->(DbSetOrder(1))
						DUE->(DbSeek(xFilial('DUE') + DT5->DT5_CODSOL ) )
						If Empty(DUE->DUE_CODCLI)
							AAdd(aDocs, {	GDFieldGet('DUA_CODOCO',nAux),;
											DtoC(GDFieldGet('DUA_DATOCO',nAux)) + GDFieldGet('DUA_HOROCO',nAux),;
											GDFieldGet('DUA_FILDOC',nAux),;
											GDFieldGet('DUA_DOC',nAux),;
											GDFieldGet('DUA_SERIE',nAux),;
											'',;
											'',;
											'',;
											'',;
											'' } )
						Else
							AAdd(aDocs, {	GDFieldGet('DUA_CODOCO',nAux),;
											DtoC(GDFieldGet('DUA_DATOCO',nAux)) + GDFieldGet('DUA_HOROCO',nAux),;
											GDFieldGet('DUA_FILDOC',nAux),;
											GDFieldGet('DUA_DOC',nAux),;
											GDFieldGet('DUA_SERIE',nAux),;
											'',;
											DUE->DUE_CODCLI+DUE->DUE_LOJCLI,;
											'',;
											'',;
											'' } )
						EndIf
					EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³VIAGEM DE TRANSPORTE E VIAGEM DE ENTREGA³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Else
					DT6->(DbSetOrder(1))
					DT6->(DbSeek(xFilial('DT6')+GDFieldGet('DUA_FILDOC',nAux)+GDFieldGet('DUA_DOC',nAux)+GDFieldGet('DUA_SERIE',nAux)))
					AAdd(aDocs, {	GDFieldGet('DUA_CODOCO',nAux),;
									DtoC(GDFieldGet('DUA_DATOCO',nAux)) + GDFieldGet('DUA_HOROCO',nAux),;
									GDFieldGet('DUA_FILDOC',nAux),;
									GDFieldGet('DUA_DOC',nAux),;
									GDFieldGet('DUA_SERIE',nAux),;
									DT6->DT6_CLIDEV+DT6->DT6_LOJDEV,;
									DT6->DT6_CLIREM+DT6->DT6_LOJREM,;
									DT6->DT6_CLIDES+DT6->DT6_LOJDES,;
									DT6->DT6_CLICON+DT6->DT6_LOJCON,;
									DT6->DT6_CLIDPC+DT6->DT6_LOJDPC } )
				EndIf
			EndIf
		EndIf
	EndIf
Next

If Len(aDocs) > 0
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Array aDocs:                                       ³
	³[01] Codigo da Ocorrencia                          ³
	³[02] Data/Hora da Ocorrencia                       ³
	³[03] Filial do Documento                           ³
	³[04] Numero do Documento                           ³
	³[05] Serie do Documento                            ³
	³[06] Cliente/Loja do cliente DEVEDOR               ³
	³[07] Cliente/Loja do cliente REMETENTE             ³
	³[08] Cliente/Loja do cliente DESTINATARIO          ³
	³[09] Cliente/Loja do cliente CONSIGNATARIO         ³
	³[10] Cliente/Loja do cliente DESPACHANTE           ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ORDENANDO O VETOR EM DEVEDOR/REMETENTE/DESTINATARIO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ASort(aDocs,,,{|x,y| x[1]+x[6]+x[7]+x[8]+x[9]+x[10]+x[3]+x[4]+x[5] < y[1]+y[6]+y[7]+y[8]+y[9]+y[10]+y[3]+y[4]+y[5] })
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DETERMINANDO A QUEBRA DOS E-MAILS:                                     ³
	//³COD.OCORRENCIA+DEVEDOR+REMETENTE+DESTINATARIO+CONSIGNATARIO+DESPACHANTE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQbrDoc := aDocs[1,1] + aDocs[1,6] + aDocs[1,7] + aDocs[1,8] + aDocs[1,9]+ aDocs[1,10]
	If Inclui
		cBody := 'Documento(s) Relacionado(s):' + Chr(13) + Chr(10)
	Else
		cBody := 'Desconsiderar a(s) ocorrência(s) para o(s) documento(s) relacionado(s) neste e-mail.' + Chr(13) + Chr(10)
		cBody += 'Lançamento indevido.'+ Chr(13) + Chr(10)
	EndIf
	cBody += Chr(13) + Chr(10)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MONTAGEM DO E-MAIL³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nAux := 1 To Len(aDocs)

		If cQbrDoc <> aDocs[nAux,1] + aDocs[nAux,6] + aDocs[nAux,7] + aDocs[nAux,8] + aDocs[nAux,9]+ aDocs[nAux,10]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³VERIFICA OS DESTINATARIOS DA MENSAGEM³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TMSA360Dest( @aDestE, @aDestI, cQbrDoc )
			cBody    +=  Chr(13) + Chr(10)
			cBody    +=  Chr(13) + Chr(10)
			cBody    += 'Atenciosamente,' + Chr(13) + Chr(10) + POSICIONE("SM0",1,SM0->M0_CODIGO+M->DUA_FILORI,"M0_NOMECOM")
			cSubject := 'Ocorrencia: ' + Left(cQbrDoc,4) + '-' + Posicione('DT2',1,xFilial('DT2')+Left(cQbrDoc,4),'DT2_DESCRI')

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PONTO DE ENTRADA PARA MANIPULAR O CORPO DA MENSAGEM³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTM360MAIL
				aTM360MAIL := ExecBlock('TM360MAIL',.F.,.F.,{aDestE,aDestI,aDocs})
				If ValType(aTM360MAIL ) == 'A'
					cSubject := aTM360MAIL[1]
					cBody    := aTM360MAIL[2]
					aDestE   := aTM360MAIL[3]
					aDestI   := aTM360MAIL[4]
				EndIf
			EndIf

			lSendMail := TMSMAIL( aDestE, aDestI, cSubject, cBody, lEditMsg, '3', @cMsgErr, lTM360MAIL )

			If !lSendMail .And. !Empty(cMsgErr)
				Help(' ', 1, 'TMSA36081',,cMsgErr,2,11)  //-- Ocorreu um problema no envio do e-mail:
			EndIf

			cQbrDoc := aDocs[nAux,1] + aDocs[nAux,6] + aDocs[nAux,7] + aDocs[nAux,8] + aDocs[nAux,9]+ aDocs[nAux,10]
			cBody   := 'Documento(s) Relacionado(s):' + Chr(13) + Chr(10)
			cBody   += Chr(13) + Chr(10)
		EndIf

		DT6->(DbSetOrder(1))
		DT6->(DbSeek(xFilial('DT6')+aDocs[nAux,3]+aDocs[nAux,4]+aDocs[nAux,5]))
		cDOCTMS	:= DT6->DT6_DOCTMS
		cBody		+= TMSValField("cDOCTMS",.F.) +  ': ' + aDocs[nAux,4] + '/' + aDocs[nAux,5] + Chr(13) + Chr(10)
		cBody		+= 'Data da Ocorrência: ' + Substr(aDocs[nAux,2],1,8) + ' Hora: ' + IIF( __SetCentury(), Substr(aDocs[nAux,2],11,2), Substr(aDocs[nAux,2],09,2)) + ':' + IIF( __SetCentury(), Substr(aDocs[nAux,2],13,2), Substr(aDocs[nAux,2],11,2)) + Chr(13) + Chr(10)
		DT2->(DbSetOrder(1))
		DT2->(DbSeek(xFilial('DT2')+aDocs[nAux,1]))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³OBTEM AS NOTAS FISCAIS PARA SERVICO DE TRANSPORTE E ENTREGA³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If DT2->DT2_SERTMS <> StrZero(1,Len(DT2->DT2_SERTMS))
			If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(aDocs[nAux,3],aDocs[nAux,4],aDocs[nAux,5])
				DTC->(DbSetOrder(3))
				DTC->(DbSeek(xFilial('DTC')+aDocs[nAux,3]+aDocs[nAux,4]+aDocs[nAux,5]))
				While DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) == xFilial('DTC')+aDocs[nAux,3]+aDocs[nAux,4]+aDocs[nAux,5]
					If DTC->DTC_SERTMS != StrZero(1,Len(DT2->DT2_SERTMS))
						cBody += 'Nota Fiscal: ' + DTC->DTC_NUMNFC + '/' + DTC->DTC_SERNFC + ' - Produto: ' + DTC->DTC_CODPRO + Chr(13) + Chr(10)
					EndIf
					DTC->(DbSkip())
				End
			Else
				DbSelectArea("DY4")
				DY4->( DbSetOrder(1) )  //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
				If DY4->( DbSeek( xFilial("DY4")+aDocs[nAux,3]+aDocs[nAux,4]+aDocs[nAux,5] ) )
					While DY4->(DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE) == xFilial('DY4')+aDocs[nAux,3]+aDocs[nAux,4]+aDocs[nAux,5]
						DbSelectArea("DTC")
						DTC->( DbSetOrder(2) )  //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto + Fil.Ori + Lote
						//-- Pocisionando na DTC a partir da DY4 para verificar campo DTC_NFENTR
						If DTC->( DbSeek( xFilial("DTC") + DY4->DY4_NUMNFC + DY4->DY4_SERNFC + DY4->DY4_CLIREM + DY4->DY4_LOJREM + DY4->DY4_CODPRO ) )
							If DTC->DTC_SERTMS != StrZero(1,Len(DT2->DT2_SERTMS))
								cBody += 'Nota Fiscal: ' + DTC->DTC_NUMNFC + '/' + DTC->DTC_SERNFC + ' - Produto: ' + DTC->DTC_CODPRO + Chr(13) + Chr(10)
							EndIf
						Endif
						DY4->(DbSkip())
					End
				Endif
			Endif
		EndIf
		cBody += Chr(13) + Chr(10)
	Next

	nAux := nAux - 1
	If Len(aDocs) > 0 .And. nAux > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³VERIFICA OS DESTINATARIOS DA MENSAGEM³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TMSA360Dest( @aDestE, @aDestI, cQbrDoc )
		cBody    +=  Chr(13) + Chr(10)
		cBody    +=  Chr(13) + Chr(10)
		cBody    += 'Atenciosamente,' + Chr(13) + Chr(10) + POSICIONE("SM0",1,SM0->M0_CODIGO+M->DUA_FILORI,"M0_NOMECOM")
		cSubject := 'Ocorrencia: ' + Left(cQbrDoc,4) + '-' + Posicione('DT2',1,xFilial('DT2')+Left(cQbrDoc,4),'DT2_DESCRI')

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³PONTO DE ENTRADA PARA MANIPULAR O CORPO DA MENSAGEM³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTM360MAIL
			aTM360MAIL := ExecBlock('TM360MAIL',.F.,.F.,{aDestE,aDestI,aDocs})
			If ValType(aTM360MAIL ) == 'A'
				cSubject := aTM360MAIL[1]
				cBody    := aTM360MAIL[2]
				aDestE   := aTM360MAIL[3]
				aDestI   := aTM360MAIL[4]
			EndIf
		EndIf

		lSendMail := TMSMAIL( aDestE, aDestI, cSubject, cBody, lEditMsg, '3', @cMsgErr, lTM360MAIL )
		If !lSendMail .And. !Empty(cMsgErr)
			Help(' ', 1, 'TMSA36081',,cMsgErr,2,11)  //-- Ocorreu um problema no envio do e-mail:
		EndIf

		cQbrDoc := aDocs[nAux,1] + aDocs[nAux,6] + aDocs[nAux,7] + aDocs[nAux,8] + aDocs[nAux,9]+ aDocs[nAux,10]
		cBody   := 'Documento(s) Relacionado(s):' + Chr(13) + Chr(10)
		cBody   +=  Chr(13) + Chr(10)
	EndIf
EndIf

RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA360Dest³ Autor ³Vitor Raspa         ³ Data ³ 26.Abr.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³RETORNA OS DESTINATARIOS DA MENSAGEM                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA360Dest( aDestE, aDestI, cDadosDoc )
Local aArea      	:= GetArea()
Local nTamCodCli 	:= TamSX3('A1_COD')[1] + TamSX3('A1_LOJA')[1]
Local nInicio    	:= 0
Local cNewDest   	:= ''
Local cQuery		:= ""
Local cAliasQry		:= GetNextAlias()

aDestE 	:= {}
aDestI 	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³POSICIONANDO NA OCORRENCIA PARA OBTER OS DADOS PARA ENVIO DO E-MAIL³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DT2->(DbSetOrder(1))
DT2->(DbSeek(xFilial('DT2')+Left(cDadosDoc,4)))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VERIFICANDO OS DESTINATARIOS INTERNOS DA MENSAGEM³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery	:= " SELECT DWU_CODUSR "
cQuery	+= " FROM " + RetSqlName("DWU") + " DWU "
cQuery	+= " WHERE DWU_FILIAL	= '" + xFilial("DWU") + "' "
cQuery	+= " AND ( DWU_CODOCO		= '" + DT2->DT2_CODOCO + "' "
cQuery	+= " OR DWU_TIPOCO			= '" + DT2->DT2_TIPOCO + "' )"
cQuery	+= " AND DWU.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof() )
	If aScan( aDestI , { |x| (cAliasQry)->DWU_CODUSR $ x }  ) == 0 
		AAdd(aDestI, (cAliasQry)->DWU_CODUSR + '-' + FwGetUserName( (cAliasQry)->DWU_CODUSR) )
	Endif 

	(cAliasQry)->( dbSkip() )
EndDo

(cAliasQry)->(dbCloseArea() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VERIFICANDO OS DESTINATARIOS EXTERNOS DA MENSAGEM³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nInicio := 5
/*Devedor*/
If DT2->DT2_MAILDV == '1'
	cNewDest := Posicione('SA1',1,xFilial('SA1')+Substr(cDadosDoc,nInicio,nTamCodCli),'A1_EMAIL')
	If !Empty(cNewDest)
		AAdd(aDestE,cNewDest)
	EndIf
EndIf

nInicio := nInicio + nTamCodCli

/*Remetente*/
If DT2->DT2_MAILRE == '1'
	cNewDest := Lower(Posicione('SA1',1,xFilial('SA1')+Substr(cDadosDoc,nInicio,nTamCodCli),'A1_EMAIL'))
	If !Empty(cNewDest)
		If Ascan(aDestE,AllTrim(Lower(AllTrim(cNewDest)))) == 0
			AAdd(aDestE,cNewDest)
		EndIf
	EndIf
EndIf

nInicio := nInicio + nTamCodCli

/*Destinatario*/
If DT2->DT2_MAILDT == '1'
	cNewDest := Lower(Posicione('SA1',1,xFilial('SA1')+Substr(cDadosDoc,nInicio,nTamCodCli),'A1_EMAIL'))
	If !Empty(cNewDest)
		If Ascan(aDestE,AllTrim(Lower(AllTrim(cNewDest)))) == 0
			AAdd(aDestE,cNewDest)
		EndIf
	EndIf
EndIf

nInicio := nInicio + nTamCodCli

/*Consignatario*/
If DT2->DT2_MAILCS == '1'
	cNewDest := Lower(Posicione('SA1',1,xFilial('SA1')+Substr(cDadosDoc,nInicio,nTamCodCli),'A1_EMAIL'))
	If !Empty(cNewDest)
		If Ascan(aDestE,AllTrim(Lower(AllTrim(cNewDest)))) == 0
			AAdd(aDestE,cNewDest)
		EndIf
	EndIf
EndIf

nInicio := nInicio + nTamCodCli

/*Destinatario*/
If DT2->DT2_MAILDP == '1'
	cNewDest := Lower(Posicione('SA1',1,xFilial('SA1')+Substr(cDadosDoc,nInicio,nTamCodCli),'A1_EMAIL'))
	If !Empty(cNewDest)
		If Ascan(aDestE,AllTrim(Lower(AllTrim(cNewDest)))) == 0
			AAdd(aDestE,cNewDest)
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA360PrvAju³ Autor ³ Eduardo de Souza    ³ Data ³ 27/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ajusta previsao de chegada da viagem                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA360PrvAju(ExpC1,ExpC2,ExpC3)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Origem                                      ³±±
±±³          ³ ExpC2 - Viagem                                             ³±±
±±³          ³ ExpC3 - Quantidade em horas para ajuste                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA360                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA360PrvAju(cFilOri,cViagem,dDatChg,cHorChg,lValid)

Local cAliasQry  := GetNextAlias()
Local dData      := CriaVar("DTW_DATPRE",.F.)
Local cHora      := CriaVar("DTW_HORPRE",.F.)
Local cAtivChg   := SuperGetMV('MV_ATIVCHG',,'')
Local lVerHora   := .T.
Local nHorAju    := 0
Local lRet		 := .F.
Local cAliasQry2 := GetNextAlias()
Local aArea		 := GetArea()
Default dDatChg  := CTOD("")
Default cHorChg  := ""
Default lValid	 := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No Estorno Verifica ha Existencia de outras ocorrencias tipo 14³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dDatChg == CTOD("")
	cQuery := " SELECT DUA_NUMOCO, DUA_DATCHG , DUA_HORCHG "
	cQuery += " 	FROM " + RetSqlName("DUA")
	cQuery += " 	WHERE DUA_FILIAL =   '" + xFilial("DUA") + "' "
	cQuery += " 		AND DUA_FILORI =  '" + cFilOri       + "' "
	cQuery += " 		AND DUA_VIAGEM =  '" + cViagem       + "' "
	cQuery += " 		AND DUA_CODOCO =  '" + M->DUA_CODOCO + "' "
	cQuery += " 		AND DUA_NUMOCO <> '" + M->DUA_NUMOCO + "' "
	cQuery += " 		AND D_E_L_E_T_ = ' ' "
	cQuery += " 		ORDER BY DUA_NUMOCO DESC "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry2, .F., .T.)
	TcSetField(cAliasQry2,"DUA_DATCHG","D",8,0)
	If !Empty((cAliasQry2)->DUA_NUMOCO)
		dDatChg := (cAliasQry2)->DUA_DATCHG
		cHorChg := Transform((cAliasQry2)->DUA_HORCHG,"@R 99:99")
	EndIf
	(cAliasQry2)->(DbCloseArea())
EndIf

cQuery := " SELECT MIN(DTW_SEQUEN) DTW_SEQUEN "
cQuery += " 	FROM " + RetSqlName("DTW")
cQuery += " 	WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
cQuery += " 		AND DTW_FILORI = '" + cFilOri  + "' "
cQuery += " 		AND DTW_VIAGEM = '" + cViagem  + "' "
cQuery += " 		AND DTW_ATIVID = '" + cAtivChg + "' "
cQuery += " 		AND DTW_STATUS = '" + StrZero(1,Len(DTW->DTW_STATUS)) + "' "
cQuery += " 		AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
If !Empty((cAliasQry)->DTW_SEQUEN)
	lRet:=.T.
	If !lValid
		DTW->(DbSetOrder(1))
		If DTW->(DbSeek(xFilial("DTW")+cFilOri+cViagem+(cAliasQry)->DTW_SEQUEN))
			While DTW->(!Eof()) .And. DTW->DTW_FILIAL + DTW->DTW_FILORI + DTW->DTW_VIAGEM == xFilial("DTW") + cFilOri + cViagem
				If DTW->DTW_STATUS == StrZero(1,Len(DTW->DTW_STATUS))
					If lVerHora .And. !Empty(dDatCHG)
						nHorAju  := Round(SubtHoras(DTW->DTW_DATPRE,DTW->DTW_HORPRE,dDatCHG,Strtran(cHorCHG,":","")),3)
						lVerHora := .F.
					EndIf
					If nHorAju <> 0
						dData := DTW->DTW_DATPRE
						cHora := TransForm(DTW->DTW_HORPRE,"@R 99:99")
						TMA360CalAj(@dData,@cHora,nHorAju)
					EndIf
					//-- Grava ajuste da previsao de chegada
					RecLock("DTW",.F.)
					DTW->DTW_DATAJU := dData
					DTW->DTW_HORAJU := Strtran(cHora,":","")
					MsUnLock()
				EndIf
				DTW->(DbSkip())
			EndDo
		EndIf
	EndIf
EndIf
(cAliasQry)->(DbCloseArea())
RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA360_V  ³ Autor ³ Telso Carneiro       ³ Data ³ 02/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para verificar a ultima versao do fonte   ³±±
±±³			 ³ TMSA360.PRW aplicado no rpo do cliente, assim verificando  ³±±
±±³			 ³ a necessidade de uma atualizacao neste fonte.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA144Sub 	                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360_V()
Local nRet := 20061002 // 02 de outubro de 2006
Return( nRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMA360CalAj³ Autor ³ Telso Carneiro       ³ Data ³ 06/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Soma ou Subtrai Dias e Horas para o Ajuste 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 : Data Inicial - Este vai ser modificado             ³±±
±±³          ³ ExpC1 : Hora Inicial - Este vai ser modificado             ³±±
±±³          ³ ExpN1 : Horas a serem Soma ou Subtraidas conforem sinal +/-³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA360 	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA360CalAj(dData,cHora,nTotHs)

Local nDias := 0

If nTotHs > 0
	SomaDiaHor(@dData,@cHora,nTotHs)
Else
	//-- Subtrai
	nTotHs:= ABS(nTotHs)
	If nTotHs < 24
		If ((HoraToInt(cHora) - nTotHs) <= 0)
			nDias := 1
		EndIf
	Else
		nDias	:= (Int(nTotHs/24))
	EndIf
	dData := (dData - nDias)
	cHora := IntToHora(ABS(HoraToInt(cHora) - (ABS(((nDias*24) - nTotHs)))))
EndIf

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
Static Function MenuDef()

Private aRotina	:= {	{ STR0002 ,'AxPesqui'  ,0,1,0,.F.},;	//'Pesquisar'
						{ STR0003 ,'TMSA360Mnt',0,2,0,Nil},;	//'Visualizar'
						{ STR0004 ,'TMSA360Mnt',0,3,0,Nil},;	//'Incluir'
						{ STR0006 ,'TMSA360Mnt',0,6,0,Nil},;	//'Estornar'
						{ STR0111 ,'TMSA360Mnt',0,7,0,Nil},;	//'Ajustar'
						{ STR0136 ,'TMSA360Vis',0,9,0,Nil}}		//'Imagem'

If ExistBlock("TM360MNU")
	ExecBlock("TM360MNU",.F.,.F.)
EndIf

Return( aRotina )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TM360AtuSal³ Autor ³Wellington A Santos   ³ Data ³ 03/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica saldo de apontamento de ocorrencias do tipo        ³±±
±±³          ³encerra processo                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Filial do documento                                ³±±
±±³          ³ ExpC2 : Documento                                          ³±±
±±³          ³ ExpC3 : Serie do documento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 : Retorno se atualizou com sucesso                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA360                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM360AtuSal(cFilDoc,cDoc,cSerie,nQtdOco,cTipOco,dDataEnt,l360Auto,cFilOri,cViagem,lShowHelp,nRecnoDUU,aDocArm,nTmsOpcx,cSerTms,cNumRom,lITmsDmd,cStaDmd)

Local lRet       := .T.
Local aAreaDT6   := DT6->( GetArea() )
Local aAreaDUU   := DUU->( GetArea() )
Local aAreaDTQ   := DTQ->( GetArea() )
Local aAreaDTW   := DTW->( GetArea() )
Local nLen       := Len(DT2->DT2_TIPOCO)
//Na variavel cTipAtu guardo os tipos de ocorrencias que podem ser atualizados no campo de saldo de volumes no DT6
//Os tipos sao - 1=Encerra processo/ES=Estorno de encerra processo/6-Pendencia
Local cTipAtu    := StrZero(1,nLen) + "/" + 'ES/' + StrZero(6,nLen)
Local cFilDco    := ''
Local cDocDco    := ''
Local cSerDco    := ''
Local lTmsCFec   := TmsCFec() //-- Carga Fechada
Local cNumAge    := ''
Local lEncerra   := .F.
Local cDocTMS    := SuperGetMv('MV_TPDCARM',,'')   //-- Quais doctos geram armazenagem
Local lSaldo     := .F.
Local cQuery     := ''
Local cAliasQry  := ""
Local lPendencia := .F.
Local lStatus    := .T.
Local lUsaNfs    := SuperGetMv('MV_TMSUNFS',,.F.)  //-- Filial utiliza nota fiscal ?
Local aPerfil    := {}
Local cCdrOri    := SuperGetMv('MV_CDRORI',,'')
Local aLoteAut   := {}
Local cDocArm    := ""
Local dDatOco    := dDataBase
Local cFilDT5    := xFilial("DT5")
Local cFilDF0    := xFilial("DF0")
Local cFilDF1    := xFilial("DF1")
Local cAtivSai	 := GetMV('MV_ATIVSAI',,'')
Local lAberto	 := .T.
Local nRecnoDFV  := 0
Local nEntreg    := 0
Local lDTCEntr   := DTC->(ColumnPos("DTC_NFENTR")) > 0
Local lDocRed    := .F.
Local cDocTip	 := ''
Local lDocRee	 := SuperGetMV('MV_DOCREE',,.F.) .And. TMSChkVer('11','R7')
Local cSeekRed	 := ""
Local nIndRed    := 1
Local lCmpDFV    := DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0
Local lRetInd    := FindFunction("TMSRetInd")
Local cLoteAut   := ""
Local cDTQStatus := ""
Local dDT6DatEnt := ""
Local cDT6Status := ""

Default l360Auto  := .F.
Default nQtdOco   := 0
Default cTipOco   := ''
Default lShowHelp := .F.
Default nRecnoDUU := 0
Default aDocArm   := {}
Default nTmsOpcx	:= 0
Default cSerTms		:= DT2->DT2_SERTMS
Default cNumRom   := ""
Default lITmsDmd  := .F.
Default cStaDmd   := ""

DbSelectArea("DTQ")
DTQ->( DbSetOrder( 2 ) )
If DTQ->( DbSeek( xFilial("DTQ") + DT6->DT6_FILVGA + DT6->DT6_NUMVGA ) )
	cDTQStatus := DTQ->DTQ_STATUS
EndIf

If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie) .And. cTipOco $ cTipAtu .AND. cSerie <> "COL"
	DbSelectArea("DT6")
	DT6->( DbSetOrder(1) )
	If DT6->( DbSeek( xFilial("DT6") + cFilDoc + cDoc + cSerie ) )

		If  EMPTY(cSerTms)
			cSerTms := DT6->DT6_SERTMS
		EndIf

		If DT6->DT6_VOLORI > 0
			RecLock("DT6",.F.)
			If nQtdOco > 0 .And. DT6->DT6_QTDVOL - nQtdOco >= 0 //se estiver subtraindo
				DT6->DT6_QTDVOL := DT6->DT6_QTDVOL - nQtdOco
				nQtdOco := DT6->DT6_QTDVOL
			ElseIf nQtdOco < 0 .And. DT6->DT6_QTDVOL - nQtdOco <= DT6->DT6_VOLORI//se estiver somando
				DT6->DT6_QTDVOL := DT6->DT6_QTDVOL - nQtdOco
				nQtdOco := DT6->DT6_QTDVOL
			ElseIf nQtdOco <> 0
				If lShowHelp
					Help('',1,'TMSA36092', ,  ) //-- 'Nao e possivel atualizar o saldo de entrega deste documento.
				EndIf
				lRet := .F.
			EndIf
			DT6->( MsUnLock() )
		EndIf
	Else
		If lShowHelp
			Help('',1,'TMSA36093', ,  ) //-- 'O Documento nao foi encontrado para atualizar seu saldo.
		EndIf
		lRet := .F.
	EndIf
	lSaldo := DT6->DT6_QTDVOL > 0		//-- Caso nao tenha mais saldo no ctrc encerra o processo de entrega

	lDocRed:= TMA360IDFV(cFilDoc,cDoc,cSerie,.F.,cFilOri,cViagem )
EndIf

If lRet .And. (cTipOco $ StrZero(1,nLen))
	DTQ->( DbSetOrder(2) )
	If( DTQ->( DbSeek(xFilial("DTQ") + cFilOri + cViagem ) ) )

		If  EMPTY(cSerTms)
			cSerTms := DTQ->DTQ_SERTMS
		EndIf

		//verifico se a viagem de transporte esta em transito, se estiver nao deixo encerrar o DUD antes de apontar a chegada de viagem
		If DTQ->DTQ_SERTMS <> StrZero(2,Len(DTQ->DTQ_SERTMS))
			lStatus := .T.
		ElseIf DTQ->DTQ_STATUS > StrZero(2,Len(DTQ->DTQ_STATUS))
			lStatus := .T.
		Else
			lStatus := .F.
		EndIf
		If lStatus
			cAliasQry := GetNextAlias()
			cQuery := " SELECT MAX(R_E_C_N_O_) REC"
			cQuery += " FROM " + RetSqlName("DUD")
			cQuery += " WHERE DUD_FILIAL='" + xFilial("DUD") + "'"
			cQuery += "   AND DUD_FILDOC='" + cFilDoc + "'"
			cQuery += "   AND DUD_DOC='" + cDoc + "'"
			cQuery += "   AND DUD_SERIE='" + cSerie + "'"
			If !EmPty(cFilOri)
				cQuery += "   AND DUD_FILORI='" + cFilOri + "'"
				cQuery += "   AND DUD_VIAGEM='" + cViagem + "'"
			Else
				cQuery += "   AND DUD_VIAGEM='" + Space(Len(DUD->DUD_VIAGEM)) + "'"
			EndIf
			cQuery += "   AND D_E_L_E_T_ = ' '"

			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

			If (cAliasQry)->(!Eof()) .And. (cAliasQry)->REC > 0
	  			DUD->( DbGoto( (cAliasQry)->REC ) )
				(cAliasQry)->( dbCloseArea() )

				//-- Encerramento de Pendencia Viagem Transferencia, nao deve alterar o status.
				If Upper(AllTrim(FunName())) == "TMSA540"
					If DUD->DUD_SERTMS == StrZero( 2, Len( DUD->DUD_SERTMS ) )	 .And. Empty(DUD->DUD_VIAGEM) // Transferencia
						lStatus:= .F.
					EndIf
				EndIf

				If lStatus .and. DT6->DT6_QTDVOL == 0 // Sera encerrado apenas quando nao houver mais saldo.
					RecLock('DUD', .F. )
					DUD->DUD_STATUS := StrZero( 4, Len( DUD->DUD_STATUS ) )	// Encerrado
					MsUnLock()
					If Upper(AllTrim(FunName())) == "TMSA540"
						DUD->(dbCommit())
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf __lPyme .Or. lDocRed .Or. Empty(cViagem)
		cAliasQry := GetNextAlias()
		cQuery := " SELECT MAX(R_E_C_N_O_) REC"
		cQuery += " FROM " + RetSqlName("DUD")
		cQuery += " WHERE DUD_FILIAL='" + xFilial("DUD") + "'"
		cQuery += "   AND DUD_FILDOC='" + cFilDoc + "'"
		cQuery += "   AND DUD_DOC='" + cDoc + "'"
		cQuery += "   AND DUD_SERIE='" + cSerie + "'"
		If !Empty(cFilOri)
			cQuery += "   AND DUD_FILORI='" + cFilOri + "'"
			cQuery += "   AND DUD_VIAGEM='" + cViagem + "'"
		Else
			cQuery += "   AND DUD_VIAGEM='" + Space(Len(DUD->DUD_VIAGEM)) + "'"
		EndIf
		If __lPyme
			cQuery += "   AND DUD_NUMROM='" + cNumRom + "'"
		EndIf
		cQuery += "   AND D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		If (cAliasQry)->(!Eof()) .And. (cAliasQry)->REC > 0
			DUD->( DbGoto( (cAliasQry)->REC ) )
			(cAliasQry)->( dbCloseArea() )
			
			If lStatus .and. DT6->DT6_QTDVOL == 0 // Sera encerrado apenas quando nao houver mais saldo.
				RecLock('DUD', .F. )
				DUD->DUD_STATUS := StrZero( 4, Len( DUD->DUD_STATUS ) )	// Encerrado
				MsUnLock()
			EndIf
		EndIf

	EndIf

	cAliasQry := GetNextAlias()
	cQuery := " SELECT 1 FROM " + RetSqlName("DUU") + " DUU "
	cQuery += " WHERE DUU_FILIAL = '" + xFilial("DUU") + "' "
	cQuery += "   AND DUU_FILDOC = '" + cFilDoc + "' "
	cQuery += "   AND DUU_DOC    = '" + cDoc    + "' "
	cQuery += "   AND DUU_SERIE  = '" + cSerie  + "' "
	cQuery += "   AND DUU_FILORI = '" + cFilOri + "' "
	cQuery += "   AND DUU_VIAGEM = '" + cViagem + "' "
	cQuery += "   AND DUU_DATENC = '' "
	If nRecnoDUU > 0
		cQuery += "   AND DUU.R_E_C_N_O_ <> " + AllTrim(Str(nRecnoDUU))
	EndIf
	cQuery += "   AND DUU.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	If (cAliasQry)->( !Eof() )
		lPendencia := .T.
	EndIf
	(cAliasQry)->( dbCloseArea() )
	If !lSaldo .And. !lPendencia
		DT6->( DbSetOrder( 1 ) )
		If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
			// Verifica se todas as notas do CTRC foram entregues
			If lDTCEntr
				nEntreg := TM360RTST(cFilDoc,cDoc,cSerie,cFilOri,cViagem)
			EndIf
			//-- Verifica se o Documento eh Entrega na Filial Alianca
			DTC->(DbSetOrder(3))

			If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc,cDoc,cSerie) .And. ;
					!l360Auto .And. DT6->DT6_STATUS <> StrZero( 5, Len(DT6->DT6_STATUS) ) .And. ;  // Chegada Final
					DTC->(DbSeek( xFilial('DTC') + cFilDoc + cDoc + cSerie ) ) .And. ;
					DTC->(ColumnPos("DTC_ALIANC")) > 0 .And. !Empty(DTC->DTC_ALIANC) .And. ;
					TmsPercAli( cFilDoc, cDoc, cSerie ) == 1 //-- Primeiro Percurso

					RecLock('DT6',.F.)
					DT6->DT6_DATENT := CtoD("  /  /  ")
					DT6->DT6_STATUS := StrZero( 5, Len(DT6->DT6_STATUS) )  // Chegada Final
					MsUnLock()
			ElseIf FindFunction("TmsPsqDY4") .And. TmsPsqDY4(cFilDoc,cDoc,cSerie) .And. ;
					!l360Auto .And. DT6->DT6_STATUS <> StrZero( 5, Len(DT6->DT6_STATUS) ) .And. ;
					TmsPercAli( cFilDoc, cDoc, cSerie ) == 1 //-- Primeiro Percurso
						DbSelectArea("DY4")
						DY4->( DbSetOrder(1) )  //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
						If DY4->( DbSeek( xFilial("DY4")+ cFilDoc + cDoc + cSerie  ) )
							DbSelectArea("DTC")
							DTC->( DbSetOrder(2) )  //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto + Fil.Ori + Lote
							//-- Pocisionando na DTC a partir da DY4 para verificar campo DTC_NFENTR
							If DTC->( DbSeek( xFilial("DTC") + DY4->DY4_NUMNFC + DY4->DY4_SERNFC + DY4->DY4_CLIREM + DY4->DY4_LOJREM + DY4->DY4_CODPRO ) ) .And. ;
								DTC->(ColumnPos("DTC_ALIANC")) > 0 .And. !Empty(DTC->DTC_ALIANC)

								RecLock('DT6',.F.)
								DT6->DT6_DATENT := CtoD("  /  /  ")
								DT6->DT6_STATUS := StrZero( 5, Len(DT6->DT6_STATUS) )  // Chegada Final
								MsUnLock()
							Endif
						Endif
			ElseIf cSerTms == "2" .And. cTipOco == StrZero(1,nLen)  //-- Encerra processo de uma viagem de transferencia.

				If (nEntreg == 1 .Or. nEntreg == 0) .AND. cDTQStatus == "3"
					cDT6Status	:= StrZero( 7, Len(DT6->DT6_STATUS)) // Chegada final
					dDT6DatEnt	:= dDataBase
				ElseIf (nEntreg == 1 .Or. nEntreg == 0)
					cDT6Status	:= StrZero( 5, Len(DT6->DT6_STATUS)) // Chegada final
					dDT6DatEnt	:= CtoD("  /  /  ")
				Else
					cDT6Status	:= StrZero( 4, Len(DT6->DT6_STATUS)) // Chegada parcial.
					dDT6DatEnt	:= CtoD("  /  /  ")
				EndIf

				RecLock( 'DT6', .F. )
					DT6->DT6_DATENT := dDT6DatEnt
					DT6->DT6_STATUS := cDT6Status
				MsUnLock()

			ElseIf (cSerTms == "3")
				RecLock('DT6',.F.)
				DT6->DT6_DATENT := IIF(Empty(dDataEnt),DT6->DT6_DATENT,dDataEnt)
				If DT2->DT2_TIPOCO == '06' .And. DT2->DT2_TIPPND == '02' .And. nEntreg == 3 .And. Upper(AllTrim(FunName())) == "TMSA540" .And. DT6->DT6_QTDVOL = 0
					DT6->DT6_STATUS := StrZero( 7, Len(DT6->DT6_STATUS))   // Entregue
				Else
					DT6->DT6_STATUS := IIF(nEntreg == 1 .Or. nEntreg == 0 .Or. cTipOco == StrZero(1,Len(DT2->DT2_TIPOCO)) .And. cSerTms == "3",StrZero( 7, Len(DT6->DT6_STATUS)), StrZero( 8, Len(DT6->DT6_STATUS))) // Entregue ou Entrega parcial
				EndIf
				MsUnLock()

				//-- Atualiza Gestão de Demandas
				If lITmsDmd .And. FindFunction("TmMontaDmd") .And. TableInDic("DL8")
					If DT2->DT2_TIPOCO == '01' //só atualiza demanda se for ocorrência de encerramento.
						TmMontaDmd(DT6->DT6_DOCTMS,cFilDoc,cDoc,cSerie,,.F.,DT2->DT2_TIPOCO,,.F.,.F.)
					Endif
				EndIf

				DFV->(DbSetOrder(2))
				If DFV->(DbSeek( xFilial("DFV")+ cFilDoc + cDoc + cSerie + StrZero(2, Len(DFV->DFV_STATUS)) ))
					RecLock('DFV',.F.)
					DFV->DFV_STATUS = StrZero( 3, Len(DFV->DFV_STATUS))  //-- Entregue
					MsUnLock()

					nRecnoDFV := DFV->(Recno())

					TMSA360DFT( DFV->DFV_NUMRED , nRecnoDFV , Iif(lCmpDFV, DFV->DFV_FILORI, '') )
				EndIf

				If DT6->DT6_DOCTMS == StrZero(6,Len(DT6->DT6_DOCTMS)) //Devolução
					If !Empty(DT6->DT6_DOCDCO)
						cFilDco := DT6->DT6_FILDCO
						cDocDco := DT6->DT6_DOCDCO
						cSerDco := DT6->DT6_SERDCO
						// Verifica se todas as notas do CTRC foram entregues
						If lDTCEntr
							nEntreg := TM360RTST(cFilDco,cDocDco,cSerDco,cFilOri,cViagem)
						EndIf
						DT6->( DbSetOrder(1))
						If DT6->(DbSeek(xFilial('DT6')+cFilDco+cDocDco+cSerDco))
							RecLock('DT6',.F.)
							DT6->DT6_DATENT := IIF(Empty(dDataEnt),DT6->DT6_DATENT,dDataEnt)
							DT6->DT6_STATUS := IIF(nEntreg == 1 .Or. nEntreg == 0 ,StrZero( 7, Len(DT6->DT6_STATUS)), StrZero( 8, Len(DT6->DT6_STATUS))) // Entregue ou Entrega parcial
							MsUnLock()
						EndIf
					EndIf
				EndIf

				DTC->(DbSetOrder(3))
				If DTC->(DbSeek( xFilial('DTC') + cFilDoc + cDoc + cSerie ) )
					// Verifica se todas as notas do CTRC foram entregues
					If lDTCEntr
						nEntreg := TM360RTST(cFilDoc,cDoc,cSerie,cFilOri,cViagem)
					EndIf
					If !Empty(DTC->DTC_DOCPER)
						If DT6->(DbSeek( xFilial('DT6') + cFilDoc + DTC->DTC_DOCPER + cSerie ) )
							RecLock('DT6',.F.)
							DT6->DT6_DATENT := IIF(Empty(dDataEnt),DT6->DT6_DATENT,dDataEnt)
							DT6->DT6_STATUS := IIF(nEntreg == 1 .Or. nEntreg == 0 ,StrZero( 7, Len(DT6->DT6_STATUS)), StrZero( 8, Len(DT6->DT6_STATUS))) // Entregue ou Entrega parcial
							MsUnLock()
						EndIf
					EndIf
					//-- Carga Fechada - Encerra item do Agendamento.
					DT5->(DbSetOrder(1))
					If lTmsCFec .And. !Empty(DTC->DTC_NUMSOL)
					    If !Empty(cFilDF0) .And. !Empty(cFilDF1)
							If !Empty(DTC->DTC_FILCFS)
								cFilDF1 := DTC->DTC_FILCFS
								cFilDF0 := DTC->DTC_FILCFS
							Else
								cFilDF1 := cFilDoc
								cFilDF0 := cFilDoc
							EndIf
						EndIf
						If DT5->(DbSeek(IIf(Empty(cFilDT5),xFilial("DT5")+DTC->DTC_FILORI+DTC->DTC_NUMSOL,DTC->DTC_FILCFS+DTC->DTC_FILORI+DTC->DTC_NUMSOL)))
   						   DF1->(DbSetOrder(3))
						   If DF1->(DbSeek(xFilial("DF1")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
						      RecLock("DF1",.F.)
							  DF1->DF1_STAENT := StrZero(5,Len(DF1->DF1_STAENT)) //-- Encerrado
							  MsUnLock()
							  cNumAge := DF1->DF1_NUMAGE
							  DF0->(DbSetOrder(1))
							  DF1->(DbSetOrder(1))
 							  If DF1->(DbSeek(xFilial('DF1',cFilDF1)+cNumAge))
							     lEncerra := .T.
 								While DF1->(!Eof()) .And. DF1->DF1_FILIAL+DF1->DF1_NUMAGE == xFilial('DF1',cFilDF1)+cNumAge
								  	If DF1->DF1_STAENT <> StrZero(5,Len(DF1->DF1_STAENT)) .And. ;//-- Encerrado
										DF1->DF1_STAENT <> StrZero(9,Len(DF1->DF1_STAENT)) //--Cancelado
										lEncerra := .F.
										Exit
									EndIf
									DF1->(DbSkip())
								 EndDo
								 If lEncerra .And. DF0->(DbSeek(xFilial('DF0',cFilDF0)+cNumAge))
									RecLock("DF0",.F.)
									DF0->DF0_STATUS := StrZero(4,Len(DF0->DF0_STATUS)) //-- Encerrado
									MsUnlock()
								 EndIf
					   		EndIf
						   EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		If DT6->DT6_DOCTMS $ cDocTMS // Tipo de documento gera armazenagem?
			aPerfil := TmsPerfil(DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,,,DT6->DT6_CLIREM,DT6->DT6_LOJREM,DT6->DT6_CLIDES,DT6->DT6_LOJDES)
			If Len(aPerfil) >= 38
				If aPerfil[38] == "1" .And. DT6->DT6_VALTOT >= aPerfil[43] // Valor do documento maior ou igual ao minimo do original
					dDatOco := Tmsa360Qry(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
					If !Empty(dDatOco) // Existe ocorrencia que gera armazenagem?
						If (DUA->DUA_DATOCO - dDatOco) >= aPerfil[39]
							If lUsaNfs .And. cCdrOri == AllTrim(DT6->DT6_CDRDES)
								cDocArm := "F" //-- Nota fiscal de armazenagem
							Else
								cDocArm := "E" //-- CTRC armazenagem
							EndIf
							nSeek := Ascan(aLoteAut,{|x|x[1]==cDocArm})
							If nSeek == 0
								cLoteAut := TmsA500Lot(StrZero(0,Len(DT6->DT6_LOTNFC)))
								AAdd(aLoteAut,{cDocArm,cLoteAut,1,1})
							Else
								cLoteAut := aLoteAut[nSeek][2]
								aLoteAut[nSeek][3] ++
								aLoteAut[nSeek][4] ++
							EndIf
							AAdd( aDocArm, { cLoteAut, DT6->(Recno()) } )
						EndIf
					EndIf
				EndIf
			Else
				Help(' ',1,'TMSA36073') //"Atualize o TMSXFUNB.PRW"
			EndIf
		EndIf
	Else
		If lDTCEntr
			// Verifica se todas as notas do CTRC foram entregues
			// 1 = Todas NF Entregue / CTRC Entregue
			// 2 = Existem NFs a serem entregues / CTRC Entrega Parcial
			// 3 = Nenhuma NF foi entregue / CTRC em aberto
			nEntreg := TM360RTST(cFilDoc,cDoc,cSerie)

			DT6->( DbSetOrder(1))
			If DT6->(DbSeek(xFilial('DT6')+cFilDoc + cDoc + cSerie))
				RecLock('DT6',.F.)
				DT6->DT6_DATENT := IF((nEntreg == 1),DT6->DT6_DATENT,CTOD(""))
				//-- Incluido verificação de SALDO para atribuição deste status.
				If Upper(AllTrim(FunName())) == "TMSA540"
					If lDocRee .And. DT2->DT2_TIPOCO == '06' .And. DT2->DT2_TIPPND == '04' .And. DT6->DT6_VOLORI != DT6->DT6_QTDVOL .And. DT6->DT6_QTDVOL != 0
						DT6->DT6_STATUS := StrZero( 8, Len(DT6->DT6_STATUS)) //-- Entrega Parcial
					ElseIf lDocRee .And. DT2->DT2_TIPOCO == '06' .And. DT2->DT2_TIPPND == '04' .And. DT6->DT6_VOLORI == DT6->DT6_QTDVOL .And. DT6->DT6_QTDVOL != 0
						DT6->DT6_STATUS := PadR('A',len(DT6->DT6_STATUS))  //-- Retorno Total
					ElseIf AllTrim(M->DUU_DESPND) == 'Retorno Dc. Cliente' .And. DT2->DT2_TIPOCO == '06' .And. DT2->DT2_TIPPND == '04'
						DT6->DT6_STATUS := StrZero( 1, Len(DT6->DT6_STATUS)) //-- 1-Em Aberto
					ElseIf ( DT6->DT6_QTDVOL == DT6->DT6_VOLORI )
		   				DT6->DT6_STATUS := StrZero( 5, Len(DT6->DT6_STATUS)) //-- 5-Chegada Final
		   			ElseIf AllTrim(M->DUU_DESPND) == 'Bloqueio' .And. DT2->DT2_TIPOCO == '06' .And. (DT2->DT2_TIPPND == '01' .Or. DT2->DT2_TIPPND == '02' .Or. DT2->DT2_TIPPND == '03')
						DT6->DT6_STATUS := StrZero( 1, Len(DT6->DT6_STATUS)) //-- 1-Em Aberto
					ElseIf lDocRee .And. DT2->DT2_TIPOCO == '06' .And. DT2->DT2_TIPPND == '04' .And. DT6->DT6_VOLORI != DT6->DT6_QTDVOL .And. DT6->DT6_QTDVOL != 0
						DT6->DT6_STATUS := StrZero( 8, Len(DT6->DT6_STATUS)) //-- Entrega Parcial
					Else
						DT6->DT6_STATUS := StrZero( 4, Len(DT6->DT6_STATUS)) //-- 4-Chegada Parcial
					EndIf
				Else
	                If(DUD->DUD_SERTMS == "2") //-- Transporte
	    	            DT6->DT6_STATUS := IF((lSaldo) ,StrZero( 4, Len(DT6->DT6_STATUS)), StrZero( 5, Len(DT6->DT6_STATUS))) // 4-Chegada Parcial ou 5-Chegada Final
	                ElseIf (DUD->DUD_SERTMS == "3") //-- Entrega
		                DT6->DT6_STATUS := IF((nEntreg == 1) .And. !(lSaldo),StrZero( 7, Len(DT6->DT6_STATUS)), StrZero(  	8, Len(DT6->DT6_STATUS))) // 7-Entregue ou 8-Entrega parcial
		   			EndIf
		  		EndIf
				MsUnLock()
			EndIf
		EndIf
	EndIf
	cDocTip := DT6->DT6_DOCTMS
	cFilDco := DT6->DT6_FILDCO
	cDocDco := DT6->DT6_DOCDCO
	cSerDco := DT6->DT6_SERDCO
	RestArea(aAreaDT6)

	If lDocRee .And. nEntreg == 1 .And. (cDocTip == StrZero(7, Len(DT6->DT6_DOCTMS)) .Or. cDocTip == Replicate('D', Len(DT6->DT6_DOCTMS)))//-- entregas notas fiscais do original
   		If DTC->(MsSeek(xFilial('DTC')+cFilDco+cDocDco+cSerDco))
   			Reclock("DTC",.F.)
   			DTC->DTC_NFENTR := StrZero( 1, Len(DTC->DTC_NFENTR))
   			MsUnlock()
   		EndIf
	EndIf
ElseIf cTipOco == 'ES' .And. lRet //Estorno

	DVL->( DbSetOrder( 1 ) )
	DUD->( DbSetOrder( 1 ) )
	If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilOri + cViagem ) ) .Or. ;
		DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt + Space(Len(DUD->DUD_VIAGEM)) ) ) .And. !__lPyme
		RecLock('DUD', .F. )

			DFV->( DbSetOrder ( 2 ) )
			If DFV->( DbSeek ( xFilial('DFV') + cFilDoc + cDoc + cSerie ) ) .And. Empty(DUD->DUD_VIAGEM)
				DUD->DUD_STATUS := StrZero( 1, Len( DUD->DUD_STATUS ) ) // Em Aberto (Caso esteja on redespacho)
			ElseIf Empty(DUD->DUD_VIAGEM)
				DUD->DUD_STATUS := StrZero( 1, Len( DUD->DUD_STATUS ) ) // Em Aberto (Caso nao exista viagem e nao esteja em redespacho)
			Else
				If DTW->( DbSeek( xFilial('DTW') + cFilOri + cViagem ) ) //Operacoes da viagem
					//Logica copiada da parte existente mais abaixo, para validar se a viagem possui operacoes,
					//se alguma delas eh a atividade de saida, e se esta atividade de saida foi apontada.
					DbSelectArea("DTW")
					DbSetOrder(1)
					DTW->(DbSeek(cSeek := xFilial("DTW")+cFilOri+cViagem))

					While DTW->(!EOF()) .And. cSeek == DTW->(DTW_FILIAL + DTW_FILORI + DTW_VIAGEM) .And. !Empty(DTW_DATINI)
						If DTW->DTW_ATIVID == cAtivSai
							lAberto := .F.
							Exit
						EndIf
						DTW->(DbSkip())
					EndDo

					If lAberto
						DTA->( DbSetOrder( 2 ) )
						If DTA->( DbSeek( xFilial('DTA') + cFilOri + cViagem + cFilDoc + cDoc + cSerie) )
							DUD->DUD_STATUS := StrZero( 3, Len( DUD->DUD_STATUS ) ) // Carregado (Caso a viagem tenha sido encerrada sem ter sido fechada, e o documento ja tivesse sido carregado.)
						Else
							DUD->DUD_STATUS := StrZero( 1, Len( DUD->DUD_STATUS ) ) // Em Aberto (Caso a viagem tenha sido encerrada sem ter sido fechada e o documento nao tenha sido carregado.)
						EndIf
					Else
						DUD->DUD_STATUS := StrZero( 2, Len( DUD->DUD_STATUS ) ) // Em Transito
					EndIf
				Else
					DTA->( DbSetOrder( 2 ) )
					If DTA->( DbSeek( xFilial('DTA') + cFilOri + cViagem + cFilDoc + cDoc + cSerie) )
						DUD->DUD_STATUS := StrZero( 3, Len( DUD->DUD_STATUS ) ) // Carregado (Caso a viagem tenha sido encerrada sem ter sido fechada, e o documento ja tivesse sido carregado.)
					Else
						DUD->DUD_STATUS := StrZero( 1, Len( DUD->DUD_STATUS ) ) // Em Aberto (Caso a viagem tenha sido encerrada sem ter sido fechada e o documento nao tenha sido carregado.)
					EndIf
				EndIF
			EndIf

			If Empty(DUD->DUD_VIAGEM)
				DUD->DUD_STATUS := StrZero( 1, Len( DUD->DUD_STATUS ) ) // Em Aberto
			Else
				DbSelectArea("DTW")
				DbSetOrder(1)
				DTW->(DbSeek(cSeek := xFilial("DTW")+cFilOri+cViagem))

				While DTW->(!EOF()) .And. cSeek == DTW->(DTW_FILIAL + DTW_FILORI + DTW_VIAGEM) .And. !Empty(DTW_DATINI)
					If DTW->DTW_ATIVID == cAtivSai
						lAberto := .F.
						Exit
					EndIf
					DTW->(DbSkip())
				EndDo

				If lAberto
					DTA->( DbSetOrder( 2 ) )
					If DTA->( DbSeek( xFilial('DTA') + cFilOri + cViagem + cFilDoc + cDoc + cSerie) )
						DUD->DUD_STATUS := StrZero( 3, Len( DUD->DUD_STATUS ) ) // Carregado (Caso a viagem tenha sido encerrada sem ter sido fechada, e o documento ja tivesse sido carregado.)
					Else
						DUD->DUD_STATUS := StrZero( 1, Len( DUD->DUD_STATUS ) ) // Em Aberto (Caso a viagem tenha sido encerrada sem ter sido fechada e o documento nao tenha sido carregado.)
					EndIf
				Else
					DUD->DUD_STATUS := StrZero( 2, Len( DUD->DUD_STATUS ) ) // Em Transito
				EndIf
			EndIf
		//-- Se for uma viagem de transferência e estornando uma ocorrência de ENCERRA PROCESSO
		If (!Empty(DUD->DUD_VIAGEM) .And. cSerTms == "2" .And. DT2->DT2_TIPOCO == "01" .And. lSaldo)
			DUD->DUD_STATUS := StrZero( 3, Len( DUD->DUD_STATUS ) ) // Carregado
		EndIf

		MsUnLock()
		If Upper(AllTrim(FunName())) == "TMSA540"
			DUD->(dbCommit())
		EndIf
	ElseIf !__lPyme
		//-- Estorno de apontamento de entrega para filial parceiro (alianca).
		DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie ) )
		While DUD->(!Eof()) .And. DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE) == xFilial('DUD') + cFilDoc + cDoc + cSerie
			If DUD->DUD_STATUS == StrZero(4,Len(DUD->DUD_STATUS))
				If DVL->(DbSeek(xFilial("DVL")+DUD->DUD_FILORI))
					RecLock('DUD', .F. )
					DUD->DUD_STATUS := StrZero( 2, Len( DUD->DUD_STATUS ) )	// Em Transito
					MsUnLock()
					If Upper(AllTrim(FunName())) == "TMSA540"
						DUD->(dbCommit())
					EndIf
					Exit
				EndIf
			EndIf
			DUD->(dbSkip())
		EndDo
	ElseIf __lPyme
		DUD->( DbSetOrder( 7 ) )
		If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilOri + cNumRom ) )
			RecLock('DUD', .F. )
			If !Empty( cNumRom )
				DUD->DUD_STATUS := StrZero( 1, Len( DUD->DUD_STATUS ) ) // Em Aberto
			Else
				DUD->DUD_STATUS := StrZero( 3, Len( DUD->DUD_STATUS ) ) // Carregado
			EndIf
		EndIf
	EndIf
	// Verifica se todas as notas do CTRC foram entregues
	If lDTCEntr
		nEntreg := TM360RTST(cFilDoc,cDoc,cSerie,cFilOri,cViagem)
	EndIf
	DT6->( DbSetOrder( 1 ) )
	If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
		RecLock("DT6",.F.)
		DT6->DT6_DATENT := CriaVar("DT6_DATENT",.F.)
		//-- Condição na função TM360AtuSal para que o status da DT6
		//-- quando se estorna uma ocorrência de GERA PENDÊNCIA sem viagem volte para 1 ABERTO.
		If (Empty(DUD->DUD_VIAGEM) .And. IsInCallStack("TM360EPEN"))
			DT6->DT6_STATUS := 	StrZero( 1, Len(DT6->DT6_STATUS))
		Else
			// Incluido tratamento no estorno de ocorrencia de 'Encerra Processo' para que docs sem viagens fiquem com status aberto
			If Empty( DT6->DT6_NUMVGA ) .AND. ( DT2->DT2_TIPOCO == StrZero( 1, Len( DT2->DT2_TIPOCO ) ) )
				DT6->DT6_STATUS := 	StrZero( 1, Len(DT6->DT6_STATUS))
			Else
				If DT6->DT6_STATUS <>	StrZero( 1, Len(DT6->DT6_STATUS))
					If DUD->DUD_STATUS == StrZero(1, Len( DUD->DUD_STATUS))

						If Empty(DUD->DUD_VIAGEM) .And. !Empty(DT6->DT6_NUMVGA) .And. Posicione("DTQ",1,xFilial("DTQ") + DT6->DT6_NUMVGA,"DTQ_SERTMS") == "2"
							DT6->DT6_STATUS := StrZero(5, Len( DT6->DT6_STATUS))//Chegada Final
						Else
							DT6->DT6_STATUS := StrZero(1, Len( DT6->DT6_STATUS))//Em Aberto
						EndIf

					ElseIf DUD->DUD_STATUS == StrZero(2, Len( DUD->DUD_STATUS))
						DT6->DT6_STATUS := StrZero(3, Len( DT6->DT6_STATUS)) //Em trânsito
					ElseIf DUD->DUD_STATUS == StrZero(3, Len( DUD->DUD_STATUS))
						DT6->DT6_STATUS := StrZero(2, Len( DT6->DT6_STATUS)) //Carregado
					ElseIf DUD->DUD_STATUS == StrZero(4, Len( DUD->DUD_STATUS))
						DT6->DT6_STATUS := StrZero(7, Len( DT6->DT6_STATUS)) //Encerrado
					ElseIf DUD->DUD_STATUS == StrZero(5, Len( DUD->DUD_STATUS))
						DT6->DT6_STATUS := StrZero(5, Len( DT6->DT6_STATUS)) //Chegada Final
					Elseif DUD->DUD_STATUS == StrZero(6, Len( DUD->DUD_STATUS))
						DT6->DT6_STATUS := StrZero(9, Len( DT6->DT6_STATUS)) //Cancelado
					ElseIf(cSerTms == "3" .And. nEntreg <> 2 .Or. nEntreg == 0) .And. IIf(lDocRee, DT6->DT6_VOLORI == DT6->DT6_QTDVOL,.T. )
						DT6->DT6_STATUS := 	StrZero( 6, Len(DT6->DT6_STATUS)) //Indicado para Entrega
					Else
						DT6->DT6_STATUS := 	StrZero( 8, Len(DT6->DT6_STATUS))  // Entrega parcial
					EndIf
				EndIf
			EndIf
		EndIf
		//-- Se o documento não estiver vinculado a nenhuma viagem o status volta a ser chegada em filial.
		If ( DUD->(DbSeek(xFilial('DUD') + cFilDoc + cDoc + cSerie + DT6->DT6_FILDES )) )
			If ( Empty(DUD->DUD_VIAGEM) ) .And. DT6->DT6_STATUS <> StrZero(1,Len(DT6->DT6_STATUS))
				DT6->DT6_STATUS := StrZero(5,Len(DT6->DT6_STATUS)) // Chegada em filial.
			ElseIf( Empty(DUD->DUD_VIAGEM) ) .And. DT6->DT6_STATUS <> StrZero(1,Len(DT6->DT6_STATUS)) .AND. nEntreg == 2
				DT6->DT6_STATUS := StrZero(8,Len(DT6->DT6_STATUS)) // Entrega Parcial
			EndIf
		EndIf
		//-- Se for uma viagem de transferência e estornando uma ocorrência de ENCERRA PROCESSO
		If	(cSerTms == "2" .And. DT2->DT2_TIPOCO == "01" .And. lSaldo)
			If ( DT6->DT6_QTDVOL == DT6->DT6_VOLORI )
				If nEntreg == 1 .OR. ( nEntreg == 3 .AND. cDTQStatus == "3" )
					DT6->DT6_STATUS := StrZero( 5, Len(DT6->DT6_STATUS)) //-- 5 - Chegada Final
				Else
					DT6->DT6_STATUS := StrZero( 3, Len(DT6->DT6_STATUS)) //-- 3 - Em transito
				EndIf
			Else
				DT6->DT6_STATUS := StrZero( 4, Len(DT6->DT6_STATUS)) //-- 4-Chegada Parcial
			EndIf
		EndIf

		MsUnLock()

		DFV->(DbSetOrder(2))
		If DFV->(DbSeek( xFilial("DFV")+ cFilDoc + cDoc + cSerie + StrZero(3, Len(DFV->DFV_STATUS)) ))
			RecLock('DFV',.F.)
			DFV->DFV_STATUS = StrZero( 2, Len(DFV->DFV_STATUS))  //-- Indicado para Entrega
			MsUnLock()

			If lRetInd
				cSeekRed:= TMSRetInd('DFT',DFV->DFV_NUMRED,Iif(lCmpDFV, DFV->DFV_FILORI, ''),@nIndRed)
			Else
				cSeekRed:= DFV->(DFV_NUMRED + DFV_CODFOR + DFV_LOJFOR)
			EndIf


			DFT->(DbSetOrder(nIndRed))
			If DFT->(DbSeek( xFilial("DFT") + cSeekRed ))
				RecLock('DFT',.F.)
				DFT->DFT_STATUS = StrZero( 2, Len(DFT->DFT_STATUS))  //-- Indicado para Entrega
				MsUnLock()
			EndIf
		EndIf

		If DT6->DT6_DOCTMS == StrZero(6,Len(DT6->DT6_DOCTMS)) //Devolução
			If !Empty(DT6->DT6_DOCDCO)
				cFilDco := DT6->DT6_FILDCO
				cDocDco := DT6->DT6_DOCDCO
				cSerDco := DT6->DT6_SERDCO
				// Verifica se todas as notas do CTRC foram entregues
				If lDTCEntr
					nEntreg := TM360RTST(cFilDco,cDocDco,cSerDco,cFilOri,cViagem)
				EndIf
				If DT6->(DbSeek(xFilial('DT6')+cFilDco+cDocDco+cSerDco))
					RecLock("DT6",.F.)
					DT6->DT6_DATENT := CriaVar("DT6_DATENT",.F.)
					DT6->DT6_STATUS := IIF(nEntreg <> 2 .Or. nEntreg == 0 ,StrZero( 6, Len(DT6->DT6_STATUS)), StrZero( 8, Len(DT6->DT6_STATUS)))  // Entrega parcial ou Indicado para Entrega
					MsUnLock()
				EndIf
			EndIf
		EndIf		
	EndIf

	//-- Carga Fechada - Retorna o item do Agendamento para 'Em Processo'.
	If lTmsCFec
		DTC->(DbSetOrder(3))
		If DTC->(DbSeek( xFilial("DTC") + cFilDoc + cDoc + cSerie ) )
			If !Empty(cFilDF0) .And. !Empty(cFilDF1)
				If !Empty(DTC->DTC_FILCFS)
					cFilDF1 := DTC->DTC_FILCFS
					cFilDF0 := DTC->DTC_FILCFS
				Else
					cFilDF1 := cFilDoc
					cFilDF0 := cFilDoc
				EndIf
			EndIf
			DT5->(DbSetOrder(1))
			If DT5->(DbSeek(IIf(Empty(cFilDT5),xFilial("DT5")+DTC->DTC_FILORI+DTC->DTC_NUMSOL,DTC->DTC_FILCFS+DTC->DTC_FILORI+DTC->DTC_NUMSOL)))
				DF1->(DbSetOrder(3))
				If DF1->(DbSeek(xFilial("DF1")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
					RecLock("DF1",.F.)
					DF1->DF1_STAENT := StrZero(4,Len(DF1->DF1_STAENT)) //-- Em Processo
					MsUnLock()
					cNumAge := DF1->DF1_NUMAGE
					DF0->(DbSetOrder(1))
					If DF0->(DbSeek(xFilial('DF0',cFilDF0)+cNumAge)) .And. DF0->DF0_STATUS == StrZero(4,Len(DF0->DF0_STATUS)) //-- Encerrado
						RecLock("DF0",.F.)
						DF0->DF0_STATUS := StrZero(3,Len(DF0->DF0_STATUS)) //-- Em Processo
						MsUnlock()
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

//-- Se for um estorno de uma pendência verifica o saldo para determinar o STATUS do documento.
If nTmsOpcx == 7 .And. Upper(AllTrim(FunName())) == "TMSA540"
	If ( DT6->DT6_QTDVOL == DT6->DT6_VOLORI )
		RecLock("DT6",.F.)
		DT6->DT6_STATUS := StrZero( 5, Len(DT6->DT6_STATUS)) //-- 5-Chegada Final
		DT6->( MsUnLock() )
	Else
		RecLock("DT6",.F.)
		DT6->DT6_STATUS := StrZero( 4, Len(DT6->DT6_STATUS)) //-- 4-Chegada Parcial
		DT6->( MsUnLock() )
	EndIf
ElseIf nTmsOpcx == 7 .And. IsInCallStack("TM360EPEN")
	RecLock("DT6",.F.)
	DT6->DT6_STATUS := StrZero( 1, Len(DT6->DT6_STATUS)) //-- Aberto
	DT6->( MsUnLock() )
EndIf
If nTmsOpcx == 4 .And. cTipOco == "ES"  .And. IsInCallStack("tms360adce")  //estorno
	nEntreg := TM360RTST(cFilDoc,cDoc,cSerie,cFilOri,cViagem)
	If(cSerTms == "3" .And. nEntreg <> 2 .Or. nEntreg == 0) .And. IIf(lDocRee, DT6->DT6_VOLORI == DT6->DT6_QTDVOL,.T. )
		cAliasQry := GetNextAlias()
		cQuery := " SELECT DUD_SERTMS, DUD_VIAGEM "
		cQuery += "   FROM " + RetSqlName("DUD")
		cQuery += "  WHERE R_E_C_N_O_ = ( SELECT MAX(R_E_C_N_O_) REC "
		cQuery += " 						    FROM " + RetSqlName("DUD")
		cQuery += "                        WHERE DUD_FILIAL='" + xFilial("DUD") + "'"
		cQuery += "                          AND DUD_FILDOC='" + cFilDoc + "'"
		cQuery += "                          AND DUD_DOC='" + cDoc + "'"
		cQuery += "                          AND DUD_SERIE='" + cSerie + "'"
		If !EmPty(cFilOri)
			cQuery += "                      AND DUD_FILORI='" + cFilOri + "'"
			cQuery += "                      AND DUD_VIAGEM='" + cViagem + "'"
		Else
			cQuery += "                      AND DUD_VIAGEM='" + Space(Len(DUD->DUD_VIAGEM)) + "'"
		EndIf
		cQuery += "                          AND D_E_L_E_T_ = ' ' )"

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		RecLock("DT6",.F.)
		If DUD->DUD_STATUS == StrZero(1, Len( DUD->DUD_STATUS))

			If Empty(DUD->DUD_VIAGEM) .And. !Empty(DT6->DT6_NUMVGA) .And. Posicione("DTQ",1,xFilial("DTQ") + DT6->DT6_NUMVGA,"DTQ_SERTMS") == "2"
				DT6->DT6_STATUS := StrZero(5, Len( DT6->DT6_STATUS))//Chegada Final
			Else
				DT6->DT6_STATUS := StrZero(1, Len( DT6->DT6_STATUS))//Em Aberto
			EndIf

		ElseIf DUD->DUD_STATUS == StrZero(2, Len( DUD->DUD_STATUS))
			DT6->DT6_STATUS := StrZero(3, Len( DT6->DT6_STATUS)) //Em trânsito
		ElseIf DUD->DUD_STATUS == StrZero(3, Len( DUD->DUD_STATUS))
			DT6->DT6_STATUS := StrZero(2, Len( DT6->DT6_STATUS)) //Carregado
		ElseIf DUD->DUD_STATUS == StrZero(4, Len( DUD->DUD_STATUS))
			DT6->DT6_STATUS := StrZero(7, Len( DT6->DT6_STATUS)) //Encerrado
		ElseIf DUD->DUD_STATUS == StrZero(5, Len( DUD->DUD_STATUS))
			DT6->DT6_STATUS := StrZero(5, Len( DT6->DT6_STATUS)) //Chegada Final
		Elseif DUD->DUD_STATUS == StrZero(6, Len( DUD->DUD_STATUS))
			DT6->DT6_STATUS := StrZero(9, Len( DT6->DT6_STATUS)) //Cancelado
		ElseIf (cAliasQry) ->DUD_SERTMS == StrZero(3,Len( DUD->DUD_SERTMS)) .and.;
		   (!Empty((cAliasQry)->DUD_VIAGEM) .or. (cAliasQry)->DUD_VIAGEM <> Space(TamSX3('DUD_VIAGEM')[1]))
			DT6->DT6_STATUS := 	StrZero( 6, Len(DT6->DT6_STATUS))  //Indicado para Entrega
		Else
			DT6->DT6_STATUS := 	StrZero( 5, Len(DT6->DT6_STATUS))  //Chega Final
		EndIf
		DT6->( MsUnLock() )
	Elseif nEntreg == 2 .And. DT6->DT6_VOLORI <> DT6->DT6_QTDVOL
		RecLock("DT6",.F.)
		DT6->DT6_STATUS := 	StrZero( 8, Len(DT6->DT6_STATUS))  //Entrega parcial
		DT6->( MsUnLock() )
	EndIf

	DUD->(DbSetOrder(1))
	If DUD->(DbSeek(xFilial('DUD')+cFilDoc+cDoc+cSerie+cFilOri+cViagem))
		RecLock('DUD', .F. )
		DUD->DUD_STATUS := Tmsa360Doc( cFilOri, cViagem, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE )
		MsUnLock()
	Endif
Endif

RestArea(aAreaDTW)
RestArea(aAreaDT6)
RestArea(aAreaDUU)
RestArea(aAreaDTQ)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMS360Crr ³ Autor ³ Telso Carneiro        ³ Data ³23/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua o carregamento automatico, de viagem ja gravada.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao Selecionada.                                 ³±±
±±³          ³ ExpC1 - Filial de Origem.                                  ³±±
±±³          ³ ExpC1 - Codigo da Viagem.                                  ³±±
±±³          ³ ExpC1 - Filial do Documento.                               ³±±
±±³          ³ ExpC1 - Codigo do Documento.                               ³±±
±±³          ³ ExpC1 - Serie do Documento.                                ³±±
±±³          ³ ExpC1 - Array com Colunas Auxiliares.                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMS360Crr( nOpcx, cFilOri, cViagem , cFilDoc, cDoc, cSerie, aColsAux )

Local aAreaAnt	 := GetArea()
Local aAreaSF4	 := SF4->(GetArea())
Local aAreaDTQ	 := DTQ->(GetArea())
Local aAreaDTR	 := DTR->(GetArea())
Local aNoFields	 := {}
Local aYesFields := {}
Local aVisual	 := {}
Local aFilDca	 := {}
Local nDocto	 := 0
Local nItem		 := 0
Local nCntFor    := 0
Local cCampo     := ''
Local cFilDca	 := ''
Local cTes       := GetMV('MV_TESDR',,'')
Local lAlianca   := TmsAlianca() //-- Verifica se utiliza Alianca
Local lRet       := .T.
Local lLocaliz	 := GetMv('MV_LOCALIZ') == 'S'
Local aDoctoAux  := {}
Local cCodVei	 := ""
Default aColsAux := {}

Private lTmsCFec  := TmsCFec()
Private aDocTo    :={}
Private lColeta   := .F.
Private cSerTMS
Private cTipTra   := DTQ->DTQ_TIPTRA

SaveInter()

Private aHeader	:={}
Private aCols	:={}

If (cFilOri != DTQ->DTQ_FILORI) .Or. (cViagem != DTQ->DTQ_VIAGEM)
	//--Posiciona na viagem destino na Transferencia
	DTQ->(DbSetOrder(2))
	lRet := DTQ->(DbSeek(xFilial("DTQ")+cFilOri+cViagem))

EndIf

If	lRet
	cSerTMS := DTQ->DTQ_SERTMS
	lColeta := (cSerTMS == StrZero( 1, Len( DC5->DC5_SERTMS ) ) )

	If lColeta
		lRet:= .F.
	EndIf

	SF4->( DbSetOrder( 1 ) )
	If !SF4->( DbSeek( xFilial('SF4') + cTes, .F. ) )
		Help( ' ', 1, 'TMSA20015',,'Tipo de entrada/saida informado no parametro MV_TESDR nao encontrado (SF4) '+cTes,5,11)
		lRet:= .F.
	EndIf
EndIf

If lRet .And. !TmsA210Srv(cSerTMS)
	lRet:= .F.
EndIf

DbSelectArea("DTR")
DTR->( DbSetOrder(1) ) // DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_ITEM

If lRet
	//-- Qd for viagem de entrega, a filial de descarga sera a propria filial de origem,
	//-- pois na rota de entrega nao e informado filial de descarga. 3o parametro .T.
	aFilDca := TMSRegDca(DTQ->DTQ_ROTA,,cSerTms==StrZero(3,Len(DC5->DC5_SERTMS)))
	If	! Empty(aFilDca)
		cFilDca := aFilDca[1,3]
	EndIf
	If	Empty(cFilDca)
		lRet:= .F.
	EndIf
	If lRet
		//Gera aDocto
		If Len(aColsAux) > 0 //Quando a viagem e apenas uma
			For nCntFor := 1 To Len(aColsAux)
				TMS360VMov(aColsAux[nCntFor,1], aColsAux[nCntFor,2],  aColsAux[nCntFor,3], aColsAux[nCntFor,4], aColsAux[nCntFor,5], aDocto ,aFilDca, lLocaliz, cSerTMS )
				If nCntFor != Len(aColsAux)
					AAdd(aDoctoAux,aClone(aDocto))
				EndIf
			Next
			For nCntFor := 1 To Len(aDoctoAux)
				AAdd(aDocto,aClone(aDoctoAux[nCntFor,1]))
			Next
		Else  //Quando a viagem e apenas mais de uma
			TMS360VMov(cFilOri, cViagem,  cFilDoc, cDoc, cSerie, aDocto ,aFilDca, lLocaliz, cSerTMS )
		EndIf

		If Len(aDocto) > 0

			//-- Cria variaveis de memoria para operacoes de carregamento
			RegToMemory('DTA',.T.)
			M->DTA_FILIAL	:= xFilial('DTA')
			M->DTA_FILORI	:= cFilAnt
			M->DTA_VIAGEM	:= DTQ->DTQ_VIAGEM

			If DTR->( DbSeek( FWxFilial('DTR') + cFilOri + cViagem ) )
				M->DTA_CODVEI := DTR->DTR_CODVEI
				cCodVei := M->DTA_CODVEI
			EndIf

			AAdd(aVisual, 'DTA_FILORI')
			AAdd(aVisual, 'DTA_VIAGEM')

			AAdd(aNoFields, 'DTA_FILORI')
			AAdd(aNoFields, 'DTA_VIAGEM')

			If !lAlianca
				AAdd(aNoFields, "DTA_FILDPC")
			EndIf

			If	!lLocaliz
				AAdd(aNoFields, 'DTA_LOCAL')
				AAdd(aNoFields, 'DTA_LOCALI')
			EndIf
			//-- Monta o aHeader e aCols
			TMSFillGetDados( 3, 'DTA', 2, xFilial('DTA') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM, {|| ''}, {|| .T. }, aNoFields, aYesFields )

			DTA->( DbSetOrder(1) )
			For nDocto := 1 To Len( aDocto )
				//-- Verifica se marcou um documento
				If	aDocto[ nDocto, CTMARCA ] .And. aDocto[nDocto,CTSTATUS] $ Iif(nOpcx==4,"23","123") //--Carregado ou EmAberto

					If nDocto > 1
						//-- Cria uma linha no aCols
						AAdd( aCols, Array( Len( aHeader ) + 1 ) )
					EndIf
					nItem := Len( aCols )

					For nCntFor := 1 To Len( aHeader )
						cCampo := aHeader[nCntFor,2]
						GdFieldPut( cCampo, CriaVar( cCampo ), nItem )
					Next

					If nOpcx == 4
						aCols[nItem][GdFieldPos('DTA_ESTCAR')] := "1" //--Estorno Sim
					EndIf
					If lLocaliz
						GDFieldPut('DTA_LOCAL' , aDocto[ nDocto, CTARMAZE ], nItem )
						GDFieldPut('DTA_LOCALI', aDocto[ nDocto, CTLOCALI ], nItem )
					EndIf

					If !Empty(cCodVei)
						GDFieldPut('DTA_CODVEI', cCodVei, nItem )
					EndIf

					GDFieldPut('DTA_FILDOC', aDocto[ nDocto, CTFILDOC ], nItem )
					GDFieldPut('DTA_DOC'   , aDocto[ nDocto, CTDOCTO ] , nItem )
					GDFieldPut('DTA_SERIE' , aDocto[ nDocto, CTSERIE ] , nItem )
					GDFieldPut('DTA_TIPCAR', StrZero(2,Len(DTA->DTA_TIPCAR)), nItem )
					
					If cSerTMS == StrZero(2,Len(DC5->DC5_SERTMS)) //--Transporte
						GDFieldPut('DTA_QTDVOL', aDocto[ nDocto, CTQTDVOLTP ], nItem )
						GDFieldPut('DTA_PESO'  , aDocto[ nDocto, CTPLIQUITP ], nItem )
					Else              //--Entrega
						GDFieldPut('DTA_QTDVOL', aDocto[ nDocto, CTQTDVOLET ], nItem )
						GDFieldPut('DTA_PESO'  , aDocto[ nDocto, CTPLIQUIET ], nItem )
					EndIf
					GDFieldPut('DTA_FILDCA', cFilDca, nItem )

					If lAlianca
						GDFieldPut('DTA_FILDPC', cFilDca, nItem )
					EndIf

					aCols[ nItem, Len( aHeader ) + 1 ] := .F.
				EndIf
			Next

			If	!Empty(aCols)
				Processa({|| lRet := TmsA210Grv( aVisual, nOpcx, lLocaliz )},STR0035) //"Aguarde! Obtendo os dados..."
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaDTR)
RestArea(aAreaSF4)
RestArea(aAreaDTQ)
RestArea(aAreaAnt)
RestInter()

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMS360VMov³ Autor ³ Telso Carneiro        ³ Data ³27/02.2002	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem o Documento da Viagem e Gera o aDocto                	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMS360VMov(cFilOri, cViagem, cFilDoc, cDoc, cSerie, aDocto, aFilDca ,lLocaliz, cSerTMS)

Local aArea  := GetArea()
Local cQuery,cAliasNew
Local nSeek  := 0
Local nSeek1 := 0

cAliasNew := GetNextAlias()
cQuery := " SELECT DUD_STATUS,DUD_FILDOC,DUD_DOC,DUD_SERIE,"
cQuery += "        DT6_FILDES,DT6_QTDVOL,DT6_PESO "
If lLocaliz
	cQuery += " ,DUH_LOCAL, DUH_LOCALI  "
EndIf
cQuery += " FROM " + RetSqlName("DUD") + " DUD JOIN " + RetSqlName("DT6") + " DT6 ON"
cQuery += " DUD_FILDOC = DT6_FILDOC AND "
cQuery += " DUD_DOC    = DT6_DOC    AND "
cQuery += " DUD_SERIE  = DT6_SERIE "
If lLocaliz
	cQuery += "   LEFT JOIN " + RetSqlName("DTC") + " DTC  ON"
	cQuery += "   DTC_FILIAL = '" + xFilial("DTC") + "'"
	cQuery += "   AND DTC_FILDOC = DT6_FILDOC "
	cQuery += "   AND DTC_DOC    = DT6_DOC "
	cQuery += "   AND DTC_SERIE  = DT6_SERIE "
	cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
	cQuery += "   		LEFT JOIN  " + RetSqlName("DUH") + " DUH "
	cQuery += "   		  ON DUH_FILIAL = '" + xFilial("DUH") + "'"
	cQuery += "   		  AND DUH_FILORI = '" + cFilAnt + "'"
	cQuery += "   		  AND DUH_NUMNFC = DTC_NUMNFC
	cQuery += "   		  AND DUH_SERNFC = DTC_SERNFC
	cQuery += "   		  AND DUH_CLIREM = DTC_CLIREM
	cQuery += "   		  AND DUH_LOJREM = DTC_LOJREM
	cQuery += "   		  AND DUH_LOCALI <> ' '
	cQuery += "   		  AND DUH.D_E_L_E_T_ = ' '
EndIf
cQuery += " WHERE "
cQuery += " DUD_FILIAL = '" + xFilial("DUD") + "'"
cQuery += " AND DUD_FILORI = '" + cFilOri + "'"
cQuery += " AND DUD_VIAGEM = '" + cViagem + "'"
cQuery += " AND DT6_FILIAL     = '" + xFilial("DT6") + "'"
cQuery += " AND DT6_FILDOC = '" + cFilDoc + "'"
cQuery += " AND DT6_DOC = '" + cDoc + "'"
cQuery += " AND DT6_SERIE = '" + cSerie + "'"
cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
cQuery += " AND DUD_STATUS <> '4' AND DUD_STATUS <> '9' "
cQuery += " AND DUD.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
cQuery := ''

If (cAliasNew)->( !Eof() )
	If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) //--Transporte
		TMSA140ZCt() //Cria o aDocto Zerado
	Else	  			   //--Entrega
		TmsA141Zer(4) //Cria o aDocto Zerado
	EndIf
EndIf

While (cAliasNew)->( !Eof() )
	If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS))  .And. Len(aFilDca) > 0
		nSeek   := Ascan(aFilDca, {|x| x[3] == (cAliasNew)->DT6_FILDES })
		nSeek1  := Ascan(aFilDca, {|x| x[3] == cFilAnt })
		If nSeek1 > nSeek
			(cAliasNew)->(dbSkip())
			Loop
		EndIf
	EndIf

	aDocto[Len(aDocto),CTSTATUS]:=(cAliasNew)->DUD_STATUS
	aDocto[Len(aDocto),CTMARCA] := .T.
	If lLocaliz
		aDocto[Len(aDocto),CTARMAZE]:= (cAliasNew)->DUH_LOCAL
		aDocto[Len(aDocto),CTLOCALI]:= (cAliasNew)->DUH_LOCALI
	EndIf
	aDocto[Len(aDocto),CTFILDOC]:= (cAliasNew)->DUD_FILDOC
	aDocto[Len(aDocto),CTDOCTO] := (cAliasNew)->DUD_DOC
	aDocto[Len(aDocto),CTSERIE] := (cAliasNew)->DUD_SERIE
	If cSerTms == StrZero(2,Len(DC5->DC5_SERTMS)) //--Transporte
		aDocto[Len(aDocto),CTQTDVOLTP]:= (cAliasNew)->DT6_QTDVOL
		aDocto[Len(aDocto),CTPLIQUITP]:= (cAliasNew)->DT6_PESO
	Else 					//--Entrega
		aDocto[Len(aDocto),CTQTDVOLET]:= (cAliasNew)->DT6_QTDVOL
		aDocto[Len(aDocto),CTPLIQUIET]:= (cAliasNew)->DT6_PESO
	EndIf
	(cAliasNew)->( DbSkip() )
EndDo
(cAliasNew)->( DbCloseArea() )

RestArea( aArea )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TA360GrOms ³ Autor ³Rodolfo K. Rosseto    ³ Data ³ 25/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a gravacao do Registro de Ocorrencias no ambiente    ³±±
±±³          ³SIGAOMS, no caso de Reentrega de uma Carga                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : Opcao do aRotina                                   ³±±
±±³          ³ ExpC2 : Identificador de Viagem ou Carga                   ³±±
±±³          ³ ExpC3 : Tipo de Uso - 1=Viagem;2=Carga                     ³±±
±±³          ³ ExpC4 : Filial da Ocorrencia                               ³±±
±±³          ³ ExpN5 : Numero da Ocorrencia                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA360 	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TA360GrOms(nTmsOpcx,cIdent,cTipUso,cFilOco,cNumOco)

Local nCntFor     := 0
Local cFilDoc     := ""
Local cDoc        := ""
Local cSerie      := ""
Local aCarga      := {}
Local cSeek       := ""
Local bWhile      := {||.T.}
Local nVlEntcom   := OsVlEntCom()
Local cFilPv      := ""
Local nRecSC9     := 0
Local aCargaAnt   := {}

If	nTmsOpcx == 3
	//-- Grava os dados.
	For nCntFor := 1 To Len( aCols )

		If	GDDeleted( nCntFor )
			Loop
		EndIf

		cFilDoc  := IIf(!Empty(GDFieldGet( 'DUA_FILIAL'	, nCntFor )),GDFieldGet( 'DUA_FILIAL'	, nCntFor ),cFilAnt)
		cDoc     := GDFieldGet( 'DUA_DOC'   	, nCntFor )
		cSerie   := GDFieldGet( 'DUA_SERIE' 	, nCntFor )

		DUA->( DbSetOrder( 10 ) )
		If	DUA->( DbSeek( xFilial('DUA')+cFilDoc+cDoc+cSerie+cTipUso+cIdent))
			RecLock('DUA', .F.)
		Else
			RecLock('DUA', .T.)
			DUA->DUA_FILIAL := xFilial('DUA')
			DUA->DUA_FILOCO := cFilOco
			DUA->DUA_NUMOCO := cNumOco
			DUA->DUA_IDENT  := cIdent
			DUA->DUA_TIPUSO := cTipUso
		EndIf
		DUA->DUA_SEQOCO := GDFieldGet( 'DUA_SEQOCO'	, nCntFor )
		DUA->DUA_CODOCO := GDFieldGet( 'DUA_CODOCO'	, nCntFor )
		DUA->DUA_SERTMS := "3" //--Entrega
		DUA->DUA_FILDOC := cFilDoc
		DUA->DUA_DOC    := cDoc
		DUA->DUA_SERIE  := cSerie
		DUA->DUA_QTDOCO := GDFieldGet( 'DUA_QTDOCO'	, nCntFor )
		DUA->DUA_PESOCO := GDFieldGet( 'DUA_PESOCO'	, nCntFor )
		DUA->DUA_DATOCO := GDFieldGet( 'DUA_DATOCO'	, nCntFor )
		DUA->DUA_HOROCO := GDFieldGet( 'DUA_HOROCO'	, nCntFor )
		DUA->DUA_RECEBE := GDFieldGet( 'DUA_RECEBE'	, nCntFor )

		//Gravar o Motivo
		MSMM(DUA->DUA_CODMOT,,,GDFieldGet( 'DUA_MOTIVO', nCntFor ),1,,,'DUA','DUA_CODMOT')

		DUA->(MsUnLock())

		DT2->(DbSetOrder(1))
		DT2->(DbSeek(xFilial("DT2")+DUA->DUA_CODOCO))
		If DT2->DT2_TIPOCO == '04'
			DAI->(DbSetOrder(3))
			SA1->(DbSetOrder(1))
			SC9->(DbSetOrder(6))
			If DAI->(DbSeek(cSeek := xFilial("DAI")+cDoc+cSerie))
				bWhile := {|| DAI->( !Eof() .And. DAI->DAI_FILIAL+DAI->DAI_NFISCA+DAI->DAI_SERIE == cSeek )}
				cFilPv := IIf(nVlEntCom<>1,DAI->DAI_FILPV,xFilial("SF2"))
				While Eval(bWhile)

					SA1->(DbSeek(xFilial("SA1")+DAI->DAI_CLIENT+DAI->DAI_LOJA ))
					If SC9->(DbSeek(xFilial("SC9")+DAI->DAI_SERIE+DAI->DAI_NFISCA+DAI->DAI_COD+DAI->DAI_SEQCAR ))
						nRecSC9 := SC9->(Recno())
					EndIf

					AAdd(aCarga,{	DAI->DAI_SEQUEN,;
								DAI->DAI_ROTEIR,;
								DAI->DAI_PERCUR,;
								DAI->DAI_ROTA,;
								DAI->DAI_PEDIDO,;
								Iif(!Empty(SC9->C9_ITEM),SC9->C9_ITEM,""),;
								DAI->DAI_CLIENT,;
								DAI->DAI_LOJA,;
								Iif(Empty(nRecSC9),0,nRecSC9),;
								Iif(!Empty(SC9->C9_ENDPAD),SC9->C9_ENDPAD,""),;
								Iif(!Empty(SC9->C9_FILIAL),SC9->C9_FILIAL,""),;
								OsFilial("SA1",SA1->A1_FILIAL),;
								DAI->DAI_CHEGAD,;
								DAI->DAI_TMSERV,;
								DAI->DAI_DTCHEG,;
								DAI->DAI_DTSAID,;
  								DAI->DAI_VALFRE,;
								DAI->DAI_FREAUT })

					AAdd(aCargaAnt,{ 	DAI->DAI_COD,;
											DAI->DAI_SEQCAR,;
											DAI->DAI_NFISCA,;
											DAI->DAI_SERIE,"","",DAI->(Recno()) })

					DAI->(DbSkip())
				EndDo

			EndIf
		EndIf
	Next nCntFor

	//Funcao para criar uma nova carga de reentrega
	If Len(aCarga) > 0 .And. Len(aCargaAnt) > 0
		Oms200Carga(aCarga,,,Posicione("DAK",4,xFilial("DAK")+cIdent,"DAK_CAMINH"),,,,,,,,,,,aCargaAnt)
	EndIf
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA360EOms³ Autor ³ Kleber Dias Gomes    ³ Data ³06/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao do estorno de ocorrencias (OMS).                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TA360EsOMS( cFilOco, cNumOco, cIdent )                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial de Ocorrencia.                              ³±±
±±³          ³ ExpC1 - Numero da Ocorrencia.                              ³±±
±±³          ³ ExpC1 - Tipo de Uso.                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TA360EsOMS( cFilOco, cNumOco, cIdent )

Local aAreaDUA	:= DUA->( GetArea() )
Local nCntFor   := 0

For nCntFor := 1 To Len( aCols )
	If	GDDeleted( nCntFor ) .Or. GDFieldGet( 'DUA_ESTOCO', nCntFor ) != StrZero( 1, TamSX3('DUA_ESTOCO')[1] )
		Loop
	EndIf
	DUA->( DbSetOrder( 8 ) )
	If	DUA->( DbSeek( xFilial('DUA') + cFilOco + cNumOco + '2' + cIdent + GDFieldGet('DUA_SEQOCO', nCntFor ), .F. ) )
		RecLock('DUA',.F.)
		DUA->(DbDelete())
		MsUnLock()
	EndIf
Next

RestArea( aAreaDUA )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa360Red ³ Autor ³ Andre Godoi			³ Data ³ 15/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o Status da DFV e DFT, de acordo com os Doc.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : opcao (3-Inclusao, 4-Exclusao) da Ocorrencia       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA360Mnt                                              	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa360Red( nTmsOpcx )
Local aArea      := GetArea()
Local cQuery     := ''
Local cAliasDFV  := ''
Local nQtdDocBx  := 0
Local nA         := 0
Local cOcorBx    := SuperGetMv('MV_OCORRDP',,"")
Local cTipOco    := ''
Local aCampos    := {}
Local cStatus    := Space(Len(DT6->DT6_STATUS))
Local lTM360GRED := ExistBlock('TM360GRED')		//-- Ponto de Entrada apos a gravacao do Status dos Documento de Redespacho, executado depois da gravacao de ocorrencia.
Local cSeekRed   := ""
Local nIndRed    := 1
Local lCmpDFV    := DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0
Local lRetInd    := FindFunction("TMSRetInd")
Local aAreaDUD   := DUD->(GetArea())
Local cAliasDUD  := ""

DFT->( DbSetOrder( 1 ) )
DFV->( DbSetOrder( 2 ) )
DT2->( DbSetOrder( 1 ) )
DUD->( DbSetOrder( 1 ) )

For nA := 1 To Len( aCols )

	If	GDDeleted( nA )
		Loop
	EndIf

	cFilDoc := GDFieldGet('DUA_FILDOC', nA )
	cDoc    := GDFieldGet('DUA_DOC'   , nA )
	cSerie  := GDFieldGet('DUA_SERIE' , nA )
	cEstOco := GDFieldGet('DUA_ESTOCO', nA )
	cCodOco := GDFieldGet('DUA_CODOCO', nA )
	aCampos := {}

	// -- Nao e' documento de Redespacho.
	cAliasDFV := GetNextAlias()
	cQuery	 := " SELECT R_E_C_N_O_ REC"
	cQuery	 += " FROM " + RetSqlName("DFV")
	cQuery	 += " WHERE DFV_FILIAL='" + xFilial("DFV") + "'"
	cQuery	 += "   AND DFV_FILDOC='" + cFilDoc + "'"
	cQuery	 += "   AND DFV_DOC   ='" + cDoc + "'"
	cQuery	 += "   AND DFV_SERIE ='" + cSerie + "'"
	cQuery	 += "   AND D_E_L_E_T_ = ' '"

	cQuery	 := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDFV, .F., .T.)
	If (cAliasDFV)->(Eof())
		(cAliasDFV)->( dbCloseArea() )
		Loop
	EndIf
	(cAliasDFV)->( dbCloseArea() )

	If DT2->(DbSeek(xFilial("DT2")+ cCodOco ))
		cTipOco	:= DT2->DT2_TIPOCO
	EndIf

	If lTM360GRED
		ExecBlock('TM360GRED',.F.,.F.,{nTmsOpcx, cFilDoc, cDoc, cSerie, cCodOco})
	EndIf

	If cTipOco == StrZero( 4, Len(DT2->DT2_TIPOCO) )
		If DT2->DT2_TIPRDP == StrZero( 2, Len( DT2->DT2_TIPRDP ) )
			Loop
		EndIf
   EndIf

	If nTmsOpcx == 4 .And. cEstOco == '1' //-- Estorno de ocorrencia

		If AllTrim(cCodOco) == AllTrim(cOcorBx) .And. DFV->( DbSeek( xFilial('DFV') + cFilDoc + cDoc + cSerie + '2' ) )		//-- Indicado p/ entrega, volta em aberto.

				aAreaDUD := DUD->( GetArea() )
				cAliasDUD := GetNextAlias()
				cQuery := " SELECT (MAX(R_E_C_N_O_)) R_E_C_N_O_"
				cQuery += "   FROM " + RetSqlName("DUD")
				cQuery += "  WHERE DUD_FILIAL = '" + xFilial('DUD') + "' "
				cQuery += "    AND DUD_FILDOC = '" + cFilDoc + "' "
				cQuery += "    AND DUD_DOC = '" + cDoc + "' "
				cQuery += "    AND DUD_SERIE = '" + cSerie + "' "
				cQuery += "    AND DUD_FILORI = '" + cFilAnt + "' "
				cQuery += "    AND D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasDUD, .F., .T. )
				If (cAliasDUD)->R_E_C_N_O_ > 0
					DUD->(dbGoto((cAliasDUD)->R_E_C_N_O_))

		        	If !Empty(DUD->DUD_VIAGEM)
					 	RecLock("DUD",.F.)
						DUD->DUD_STATUS := StrZero(2,Len(DUD->DUD_STATUS))   //Em Transito
						MsUnLock()
						cStatus:= 	StrZero(3,Len(DT6->DT6_STATUS))	//-- Em transito
					Else
						If cFilDoc == cFilAnt //-- O documento não foi incluido em nenhuma viagem de transferência
							cStatus:= 	StrZero(1,Len(DT6->DT6_STATUS))  //Em Aberto
						Else //-- O documento já foi incluido em alguma viagem de transferência
							cStatus:= 	StrZero(5,Len(DT6->DT6_STATUS))  //-- Chegada final
						EndIf
					EndIf

					RecLock("DFV",.F.)
					DFV->DFV_STATUS := StrZero(1,Len(DFV->DFV_STATUS))
					MsUnLock()

					If lRetInd
						cSeekRed:= TMSRetInd('DFT',DFV->DFV_NUMRED,Iif(lCmpDFV, DFV->DFV_FILORI, ''),@nIndRed)
					Else
						cSeekRed:=  DFV->DFV_NUMRED
					EndIf
					DFT->(DbSetOrder(nIndRed))
					If DFT->(DbSeek( xFilial("DFT") + cSeekRed ))
						RecLock('DFT', .F.)
						DFT->DFT_STATUS := StrZero(1,Len(DFT->DFT_STATUS))
						MsUnLock()
					EndIf

					DT6->(DbSetOrder(1))
					If DT6->(DbSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie))
						RecLock("DT6",.F.)
						DT6->DT6_STATUS := cStatus
						MsUnLock()
					EndIf
				EndIf
				(cAliasDUD)->(dbCloseArea())
				RestArea( aAreaDUD )

		ElseIf cTipOco == StrZero( 1 , Len(DT2->DT2_TIPOCO) ) .And. DFV->( DbSeek( xFilial('DFV') + cFilDoc + cDoc + cSerie + '3' ) ) //-- Estorno do tipo de Encerra processo, volta p/ indicado p/ entrega

				RecLock("DFV",.F.)
				DFV->DFV_STATUS := StrZero(2,Len(DFV->DFV_STATUS))
				MsUnLock()

				//-- Estornado algum Doc. DFV, altera p/ "Indicado p/ Entrega" o DFT
				If lRetInd
					cSeekRed:= TMSRetInd('DFT',DFV->DFV_NUMRED,Iif(lCmpDFV, DFV->DFV_FILORI, ''),@nIndRed)
				Else
					cSeekRed:= DFV->DFV_NUMRED
				EndIf
				DFT->(DbSetOrder(nIndRed))
				If DFT->( DbSeek( xFilial('DFT') + cSeekRed  ) )
					RecLock('DFT', .F.)
					DFT->DFT_STATUS := StrZero(2,Len(DFT->DFT_STATUS))
					MsUnLock()
				EndIf

		ElseIf cTipOco == StrZero( 4 , Len(DT2->DT2_TIPOCO) ) .And. DFV->( DbSeek( xFilial('DFV') + cFilDoc + cDoc + cSerie + '9' ) ) //-- Estorno do tipo "Retorna Documento"

				//-- Se tiver viagem, volta em aberto, caso contrario, volta como Indicado p/ Entrega.

				If DUD->( DbSeek( xFilial("DUD") + cFilDoc + cDoc + cSerie + cFilAnt )) .And. Empty(DUD->DUD_VIAGEM)
					cStatus	:= StrZero(2,Len(DFV->DFV_STATUS))
					If lRetInd
						cSeekRed:= TMSRetInd('DFT',DFV->DFV_NUMRED,Iif(lCmpDFV, DFV->DFV_FILORI, ''),@nIndRed)
					Else
						cSeekRed:= DFV->DFV_NUMRED
					EndIf
					DFT->(DbSetOrder(nIndRed))
					If DFT->(DbSeek( xFilial("DFT") + cSeekRed ))
						RecLock('DFT', .F.)
						DFT->DFT_STATUS := StrZero(2,Len(DFT->DFT_STATUS))
						MsUnLock()
					EndIf
				Else
					DUA->( DbSetOrder ( 3 ) )
					If DUA->( DbSeek( xFilial('DUA') + Padr( cOcorBx, len( DUA->DUA_CODOCO)) + cFilDoc + cDoc + cSerie ) )
						cStatus	:= StrZero(2,Len(DFV->DFV_STATUS))
					Else
						cStatus	:= StrZero(1,Len(DFV->DFV_STATUS))
					EndIf

					If lRetInd
						cSeekRed:= TMSRetInd('DFT',DFV->DFV_NUMRED,Iif(lCmpDFV, DFV->DFV_FILORI, ''),@nIndRed)
					Else
						cSeekRed:= DFV->DFV_NUMRED
					EndIf

					DFT->(DbSetOrder(nIndRed))
					If DFT->( DbSeek( xFilial("DFT") + cSeekRed ) )
						RecLock('DFT', .F.)
						DFT->DFT_STATUS := StrZero(1,Len(DFT->DFT_STATUS))
						MsUnLock()
					EndIf
				EndIf
				RecLock('DFV', .F.)
				DFV->DFV_STATUS := cStatus
				MsUnLock()

			EndIf

	ElseIf nTmsOpcx == 3 	//-- Apontamento de ocorrencia
		If cTipOco == StrZero( 1, Len(DT2->DT2_TIPOCO) ) .Or. ;	//--Ocorrencia tipo "Entregue", pesquisa "Indicado p/ Entrega"
			cTipOco == StrZero( 4, Len(DT2->DT2_TIPOCO) ) 			//-- Apontamento de Ocorrencia do tipo de "Retorna Documento", pesquisa "Indicado p/ Entrega"
			cStatus := StrZero(2,Len(DFV->DFV_STATUS))
		ElseIf AllTrim(cCodOco) $ AllTrim(cOcorBx)					//-- Ocorrencia de indicado p/ Entrega, pesquisa " Aberto "
			cStatus := StrZero(1,Len(DFV->DFV_STATUS))
		EndIf

		If DFV->( DbSeek( xFilial('DFV') + cFilDoc + cDoc + cSerie + cStatus ) )
			If AllTrim(cCodOco) $ AllTrim(cOcorBx)		//-- Informativa, "Indicado p/ Entrega"
				DT6->(DbSetOrder(1))
				If DT6->(DbSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
					RecLock("DT6",.F.)
					DT6->DT6_STATUS := StrZero(6,Len(DT6->DT6_STATUS)) // Indicado para Entrega
					MsUnLock()
				EndIf
				RecLock('DFV', .F.)
				DFV->DFV_STATUS := StrZero(2,Len(DFV->DFV_STATUS))
				MsUnLock()

				DFV->(dbCommit())

				nQtdDocBx:= TMA360RDP(Iif(lCmpDFV, DFV->DFV_FILORI,'' ),DFV->DFV_NUMRED,'2',.F.,0)

				//-- Qtd de Doc da DFV Indicado p/ Entrega = qtd da DFT, altera o status da DFT p/ Indicado p/ entrega.
				If lRetInd
					cSeekRed:= TMSRetInd('DFT',DFV->DFV_NUMRED,Iif(lCmpDFV, DFV->DFV_FILORI, ''),@nIndRed)
				Else
					cSeekRed:= DFV->DFV_NUMRED
				EndIf
				DFT->(DbSetOrder(nIndRed))
				If DFT->( DbSeek( xFilial("DFT") + cSeekRed ) ) .And. DFT->DFT_QTDDOC == nQtdDocBx
					RecLock('DFT', .F.)
					DFT->DFT_STATUS := StrZero(2,Len(DFT->DFT_STATUS))
					MsUnLock()
				EndIf
			EndIf

			If cTipOco == StrZero( 1, Len(DT2->DT2_TIPOCO) )	//--Ocorrencia tipo "Entregue" - Encerra processo.
				RecLock('DFV', .F.)
				DFV->DFV_STATUS := StrZero( 3, Len(DFV->DFV_STATUS) )
				MsUnLock()

				nQtdDocBx:= TMA360RDP(Iif(lCmpDFV, DFV->DFV_FILORI,'' ),DFV->DFV_NUMRED,'3',.F.,0)

				//-- Qtd de Doc da DFV entregue = qtd da DFT, altera o status da DFT p/ encerrado.
				If lRetInd
					cSeekRed:= TMSRetInd('DFT',DFV->DFV_NUMRED,Iif(lCmpDFV, DFV->DFV_FILORI, ''),@nIndRed)
				Else
					cSeekRed:= DFV->DFV_NUMRED
				EndIf
				DFT->(DbSetOrder(nIndRed))
				If DFT->( DbSeek( xFilial("DFT") + cSeekRed ) ) .And. DFT->DFT_QTDDOC == nQtdDocBx
					RecLock('DFT', .F.)
					DFT->DFT_STATUS := StrZero(3,Len(DFT->DFT_STATUS))
					MsUnLock()

				ElseIf nQtdDocBx < DFT->DFT_QTDDOC
					nQtdDocBx:= TMA360RDP(Iif(lCmpDFV, DFV->DFV_FILORI,'' ),DFV->DFV_NUMRED,'2',.T.,0)

					If DFT->DFT_QTDDOC == nQtdDocBx
						RecLock('DFT', .F.)
						DFT->DFT_STATUS := StrZero(3,Len(DFT->DFT_STATUS))
						MsUnLock()
					EndIf

				EndIf

			EndIf

			//--	Apontamento de Ocorrencia do tipo de "Retorna Documento", cancela a DFV e o DFT, se for o caso.
			If cTipOco == StrZero( 4, Len(DT2->DT2_TIPOCO) )
				RecLock('DFV', .F.)
				DFV->DFV_STATUS := StrZero(9,Len(DFV->DFV_STATUS))
				MsUnLock()

				nQtdDocBx:= TMA360RDP(Iif(lCmpDFV, DFV->DFV_FILORI,'' ),DFV->DFV_NUMRED,'9',.F.,0)

				//-- Qtd de Doc da DFV entregue = qtd da DFT, altera o status da DFT p/ encerrado.
				If lRetInd
					cSeekRed:= TMSRetInd('DFT',DFV->DFV_NUMRED,Iif(lCmpDFV, DFV->DFV_FILORI, ''),@nIndRed)
				Else
					cSeekRed:= DFV->DFV_NUMRED
				EndIf
				DFT->(DbSetOrder(nIndRed))
				If DFT->( DbSeek( xFilial("DFT") + cSeekRed ) ) .And.  DFT->DFT_QTDDOC == nQtdDocBx
					RecLock('DFT', .F.)
					DFT->DFT_STATUS := StrZero(9,Len(DFT->DFT_STATUS))
					MsUnLock()

					DT6->(DbSetOrder(1))
					If DT6->(DbSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
						RecLock("DT6",.F.)
						DT6->DT6_STATUS := StrZero(1,Len(DT6->DT6_STATUS)) //-- Indicado para entrega
						MsUnLock()
					EndIf

				ElseIf nQtdDocBx < DFT->DFT_QTDDOC
					nQtdDocBx:= TMA360RDP(Iif(lCmpDFV, DFV->DFV_FILORI,'' ),DFV->DFV_NUMRED,'2',.T.,0)

					If DFT->DFT_QTDDOC == nQtdDocBx
						RecLock('DFT', .F.)
						DFT->DFT_STATUS := StrZero(3,Len(DFT->DFT_STATUS))
						MsUnLock()
					EndIf

				EndIf
			EndIf
		EndIf
	EndIf

Next nA

RestArea( aArea )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360DFT³ Autor ³ Raphael Zampieri      ³ Data ³26.03.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o Status da DFT, apos alguma alteracao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA360DFT()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA360DFT( cNumRed , nRecnoDFV, cFilOri )
Local nQtdDoc   := 0
Local lCmpDFV   := DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0
Local cSeekRed  := ""
Local nIndRed   := 1
Local lRetInd   := FindFunction("TMSRetInd")

Default cFilOri := ""

//-- Se for redespacho, altera o documento p/ "Indicado p/ Entrega".
nQtdDoc:= TMA360RDP(cFilOri,cNumRed,'3',.T.,nRecnoDFV)

DbSelectArea("DFV")
//-- Qtd de Doc da DFV <> "Entregue" = Zero
If lRetInd
	cSeekRed:= TMSRetInd('DFT',DFV->DFV_NUMRED,Iif(lCmpDFV, DFV->DFV_FILORI, ''),@nIndRed)
Else
	cSeekRed:= DFV->DFV_NUMRED
EndIf
DFT->(DbSetOrder(nIndRed))
If DFT->( DbSeek( xFilial("DFT") + cSeekRed ) )  .And. ( nQtdDoc == 0 )
	RecLock('DFT', .F.)
	DFT->DFT_STATUS := StrZero( 3, Len( DFT->DFT_STATUS ) )
	MsUnLock()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMS360ADCEºAutor  ³Microsiga           º Data ³  07/28/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza os documentos de cliente como entregue, nao        º±±
±±º          ³entregue ou bloqueado                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMS360ADCE(aDocEnc, nTmsOpcx)
Local aArea		:= GetArea()
Local nI		:= 0
Local nPosCTR	:= 0
Local nPosNF	:= 0
Local cEntregue	:= ""
Local cQuery	:= ""
Local cAliasQry	:= ""
Local cRestFil	:= ""
Local lOcorAnt	:= .F.
Local cDoc		:= ""
Local cFilDoc	:= ""
Local cSerie	:= ""
Local cTipoOco	:= ''
Local cFilVga   := ''
Local cNumVga	:= ''
Local nTmsdInd	:= SuperGetMv('MV_TMSDIND',.F.,0) // Dias permitidos para indenizacao apos o documento entregue
Local lDocRee	 := SuperGetMV('MV_DOCREE',,.F.) .And. TMSChkVer('11','R7')
Local lReeDev		:= .F.

Default aDocEnc  := {}
Default nTmsOpcx := 0

SaveInter()

If nTmsOpcx == 4
	cRestFil := DUA->(DbFilter())
	DUA->(dbClearFil())
EndIf

Pergunte("TMA500",.F.)

For nI:= 1 To Len(aDocEnc)

	If nTmsOpcx == 3
		nPosCTR := Ascan(aCols,{|x| x[GdFieldPos("DUA_FILDOC")]+x[GdFieldPos("DUA_DOC")]+x[GdFieldPos("DUA_SERIE")]+x[GdFieldPos("DUA_CODOCO")] == aDocEnc[nI,1]+aDocEnc[nI,2]+aDocEnc[nI,3]+aDocEnc[nI,10] })
		If nPosCTR > 0
			cTipoOco := Posicione( 'DT2', 1, xFilial('DT2') + GdFieldGet("DUA_CODOCO",nPosCTR),"DT2_TIPOCO" )
		EndIf
	Endif
	
	//-- Verifica se a ocorrencia e' Gera Pendencia/Indenizacao para um documento ja entregue,
	//-- e neste caso, nao atualiza saldo, bloqueios e nao gera novo DUD
	If nTmsdInd > 0 .And. cTipoOco <> StrZero(1,Len(DT2->DT2_TIPOCO))
		DT6->(DbSetOrder(1))
		If DT6->(DbSeek(xFilial('DT6')+aDocEnc[nI,1]+aDocEnc[nI,2]+aDocEnc[nI,3])) .And. DT6->DT6_STATUS == StrZero( 7, Len( DT6->DT6_STATUS ) )
			Loop
		EndIf
	EndIf

	If nTmsOpcx == 4
		cAliasQry := GetNextAlias()

		cQuery := "   SELECT MAX(DUA.R_E_C_N_O_) DUARecno "
		cQuery += "   FROM " + RetSqlName("DUA") + " DUA "
		cQuery += "        INNER JOIN " + RetSqlName("DT2") + " DT2 ON "
		cQuery += "          DT2_FILIAL = '" + xFilial("DT2") + "' AND "
		cQuery += "          DT2_CODOCO = DUA_CODOCO AND "
		cQuery += "          DT2_TIPOCO = '01' AND "
		cQuery += "          DT2.D_E_L_E_T_ = ' ' "
		cQuery += "   WHERE "
		cQuery += "        DUA.DUA_FILIAL = '" + xFilial("DUA") + "' AND "
		cQuery += "        DUA.DUA_FILDOC = '" + aDocEnc[nI,1] + "' AND "
		cQuery += "        DUA.DUA_DOC    = '" + aDocEnc[nI,2] + "' AND "
		cQuery += "        DUA.DUA_SERIE  = '" + aDocEnc[nI,3] + "' AND "
		cQuery += "        DUA.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

		If (cAliasQry)->(DUARecno) > 0
			lOcorAnt := .T.
			DUA->(DbGoto((cAliasQry)->(DUARecno)))
		EndIf

		(cAliasQry)->(DbCloseArea())
		cAliasQry := GetNextAlias()
		If lOcorAnt
			cQuery := "   SELECT DTC.R_E_C_N_O_ DtcRecno "
			cQuery += " FROM " + RetSqlName("DV4") + " DV4  "
			cQuery += "     INNER JOIN " + RetSqlName("DUU") + " DUU ON "
			cQuery += "     DUU_FILIAL = '"+xFilial("DUU")+"' "
			cQuery += " AND DUU_FILPND = DV4_FILPND "
			cQuery += " AND DUU_NUMPND = DV4_NUMPND "

			cQuery += " INNER JOIN "+ RetSqlName("DTC") + " DTC ON DTC_FILIAL = '"+xFilial("DTC")+"' "
			cQuery += " AND DTC_FILDOC = DV4_FILDOC "
			cQuery += " AND DTC_DOC = DV4_DOC "
			cQuery += " AND DTC_SERIE = DV4_SERIE "
			cQuery += " AND DTC_NUMNFC = DV4_NUMNFC "
			cQuery += " AND DTC_SERNFC = DV4_SERNFC "

			cQuery += " WHERE "
			cQuery += " DV4_FILIAL = '"+xFilial("DV4")+"' "
			cQuery += " AND DV4_FILOCO = '"+DUA->DUA_FILOCO+"' "
			cQuery += " AND DV4_NUMOCO = '"+DUA->DUA_NUMOCO+"' "
			cQuery += " AND DV4.D_E_L_E_T_ = ' ' "
			cQuery += " AND DUU.D_E_L_E_T_ = ' ' "
			cQuery += " AND DUU_STATUS = '4' "
			cQuery += " AND DTC.D_E_L_E_T_ = ' ' "

		Else
			If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(aDocEnc[nI,1],aDocEnc[nI,2],aDocEnc[nI,3])
				cQuery := "   SELECT DTC.R_E_C_N_O_ DtcRecno "
				cQuery += "  FROM " + RetSqlName("DTC") + " DTC "
				cQuery += "   WHERE "
				cQuery += "        DTC_FILIAL = '" + xFilial("DTC") + "' AND "
				cQuery += "        DTC_FILDOC = '" + aDocEnc[nI,1] + "' AND "
				cQuery += "        DTC_DOC    = '" + aDocEnc[nI,2] + "' AND "
				cQuery += "        DTC_SERIE  = '" + aDocEnc[nI,3] + "' AND "
				cQuery += "        DTC.D_E_L_E_T_ = ' ' "
			Else
				cAliasQry := GetNextAlias()
				cQuery:= " SELECT DY4_NUMNFC AS NUMNFC, DY4_SERNFC AS SERNFC, DY4_FILDOC AS FILDOC, DY4_DOC AS DOC,DY4_SERIE AS SERIE,DY4_CODPRO AS CODPRO, R_E_C_N_O_ "
				cQuery+= " FROM " + RetSqlName("DY4") + " DY4 "
				cQuery+= " WHERE DY4_FILIAL = '"+	xFilial("DY4")	+"' "
				cQuery+= " AND DY4_FILDOC = '"	+	aDocEnc[nI,1]	+"' "
				cQuery+= " AND DY4_DOC = '"		+	aDocEnc[nI,2]	+"' "
				cQuery+= " AND DY4_SERIE = '"	+	aDocEnc[nI,3]	+"' "
				cQuery+= " AND DY4.D_E_L_E_T_ = ' ' "
				lReeDev := .T.
			Endif
		EndIf
		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

		While (cAliasQry)->(!Eof())
		    If !lReeDev
				DTC->(DbGoto((cAliasQry)->(DTCRecno)))
			Else
				DY4->(DbGoTo((cAliasQry)->R_E_C_N_O_))
				DbSelectArea("DTC")
				DbSetOrder(2) //Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto + Fil. Origem + Lote Dc.Cli
				DTC->(MsSeek(xFilial("DTC")+DY4->(DY4_NUMNFC+DY4_SERNFC+DY4_CLIREM+DY4_LOJREM+DY4_CODPRO+DY4_FILORI+DY4_LOTNFC) ))
			Endif

			RecLock("DTC",.F.)
				DTC->DTC_NFENTR := '2'
				DTC->DTC_FILOCO := ''
				DTC->DTC_NUMOCO := ''
			MsUnLock()
			(cAliasQry)->(DbSkip())
		EndDo

		(cAliasQry)->(DbCloseArea())
		TM360AtuSal(aDocEnc[nI,1],aDocEnc[nI,2],aDocEnc[nI,3],0,"ES",CtoD("  /  /  "),l360Auto,aDocEnc[nI,7],aDocEnc[nI,8], .F.,,,nTmsOpcx,,aDocEnc[nI,9])
	ElseIf nTmsOpcx == 3

		DT6->(DbSetOrder(1))
		If DT6->(DbSeek(xFilial('DT6')+aDocEnc[nI,1]+aDocEnc[nI,2]+aDocEnc[nI,3]))
				cFilDoc := DT6->DT6_FILDOC
				cDoc    := DT6->DT6_DOC
				cSerie  := DT6->DT6_SERIE
			If !Empty(DT6->DT6_DOCDCO) .And. !Empty(DT6->DT6_SERDCO)
				cFilDoc := DT6->DT6_FILDCO
				cDoc    := DT6->DT6_DOCDCO
				cSerie  := DT6->DT6_SERDCO
			EndIf
		EndIf
		DUD->(DbSetOrder(1))
		If DUD->(DbSeek(xFilial('DUD')+cFilDoc+cDoc+cSerie))
			cFilVga := DUD->DUD_FILORI
			cNumVga	:= DUD->DUD_VIAGEM
		EndIf
		
		If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc,cDoc,cSerie)
			cAliasQry := GetNextAlias()
			cQuery:= " SELECT DTC_NUMNFC AS NUMNFC, DTC_SERNFC AS SERNFC, DTC_NFENTR AS NFENTR, DTC_FILDOC AS FILDOC, DTC_DOC AS DOC,DTC_SERIE AS SERIE,DTC_CODPRO AS CODPRO, R_E_C_N_O_ "
			cQuery+= " FROM " + RetSqlName("DTC") + " DTC "
			cQuery+= " WHERE DTC_FILIAL = '"+xFilial("DTC")+"' "
			cQuery+= " AND DTC_DOC = '"+cDoc+"' "
			cQuery+= " AND DTC_SERIE = '"+cSerie+"' "
			cQuery+= " AND DTC_FILDOC = '"+cFilDoc+"' "
			cQuery+= " AND DTC_NFENTR <> '3' "
			cQuery+= " AND D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		Else
			cAliasQry := GetNextAlias()
			cQuery:= " SELECT DY4_NUMNFC AS NUMNFC, DY4_SERNFC AS SERNFC, DY4_FILDOC AS FILDOC, DY4_DOC AS DOC,DY4_SERIE AS SERIE,DY4_CODPRO AS CODPRO, R_E_C_N_O_ "
			cQuery+= " FROM " + RetSqlName("DY4") + " DY4 "
			cQuery+= " WHERE DY4_FILIAL = '"+xFilial("DY4")+"' "
			cQuery+= " AND DY4_FILDOC = '"+cFilDoc+"' "
			cQuery+= " AND DY4_DOC = '"+cDoc+"' "
			cQuery+= " AND DY4_SERIE = '"+cSerie+"' "
			cQuery+= " AND D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			lReeDev := .T.
		Endif

		While (cAliasQry)->(!Eof())
			cEntregue   := "1"
			If aDocEnc[nI,5] .And. Len(aDocEnc[nI,6]) > 0
				nPosNF := Ascan(aDocEnc[nI,6], {|x| x[1] == (cAliasQry)->NUMNFC+(cAliasQry)->SERNFC } )
				If nPosNF > 0
					If aDocEnc[nI,6,nPosNF,2] $ "01/02/04"
						cEntregue := "3"
					EndIf
				EndIf
			EndIf
			If !lReeDev
				DTC->(DbGoTo((cAliasQry)->R_E_C_N_O_))
			Else
				DY4->(DbGoTo((cAliasQry)->R_E_C_N_O_))
				DbSelectArea("DTC")
				DbSetOrder(2) //Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto + Fil. Origem + Lote Dc.Cli
				DTC->(MsSeek(xFilial("DTC")+DY4->(DY4_NUMNFC+DY4_SERNFC+DY4_CLIREM+DY4_LOJREM+DY4_CODPRO+DY4_FILORI+DY4_LOTNFC) ))
			Endif
			If cEntregue <> DTC->DTC_NFENTR
				If MV_PAR03 == 1 .Or. cTipoOco == StrZero(1,Len(DT2->DT2_TIPOCO))//Geração por NF ou Tipo de Ocorrencia do tipo encerra processo.
					Reclock("DTC",.F.)
					DTC->DTC_NFENTR := cEntregue
					If cEntregue == "1"
						DTC->DTC_FILOCO := cFilAnt
						DTC->DTC_NUMOCO := M->DUA_NUMOCO
					EndIf
					DTC->(MsUnLock())
				Endif
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo

		TM360AtuSal(aDocEnc[nI,1],aDocEnc[nI,2],aDocEnc[nI,3],0,cTipoOco,CtoD("  /  /  "),l360Auto,aDocEnc[nI,7],aDocEnc[nI,8], .F.,,,,,aDocEnc[nI,9])
		If lDocRee .And. !Empty(aDocEnc[nI,1]+aDocEnc[nI,2]+aDocEnc[nI,3]) .And. !Empty(cFilDoc+cDoc+cSerie) .And. aDocEnc[nI,1]+aDocEnc[nI,2]+aDocEnc[nI,3] != cFilDoc+cDoc+cSerie //--baixa dc original na entrega
			TM360AtuSal(cFilDoc,cDoc,cSerie,0,cTipoOco,CtoD("  /  /  "),l360Auto,cFilVga,cNumVga,.F.,,,,,aDocEnc[nI,9])
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
Next nI

If nTmsOpcx == 4 .And. !Empty(cRestFil)
	DUA->(DbSetFilter({|| &cRestFil}, cRestFil))
EndIf

RestInter()
RestArea(aArea)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA360   ºAutor  ³Microsiga           º Data ³  07/28/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega um array com os CTRCs e as notas fiscais            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TM360ATDC(nTmsOpcx, aDocEnc, cFilDoc, cDoc, cSerie, cTipOco, cTipPnd,lCarNFEst, nCntFor, cFilOri, cViagem, lRetorna, cNumRom, cCodOco)
Local aArea       := GetArea()
Local nPosDoc     := 0
Local nI          := 0
LOcal nPosCTR     := 0

Default nTmsOpcx  := 0
Default aDocEnc   := {}
Default cFilDoc   := ""
Default cDoc      := ""
Default cSerie    := ""
Default cTipOco   := ""
Default cCodOco   := ""
Default cTipPnd   := ""
Default lCarNFEst := .F.
Default cFilOri   := ""
Default cViagem   := ""
Default lRetorna  := .F. //Indica se todos os documentos foram marcados para retorno
Default cNumRom   := ""

SaveInter()

If DTC->(ColumnPos("DTC_NFENTR")) > 0
	nPosDoc:= Ascan(aDocEnc,{|x| x[1]+x[2]+x[3]==cFilDoc+cDoc+cSerie})

	If cTipOco == "01" .And. nPosDOc == 0
		If nPosDoc > 0
			aDocEnc[nPosDoc,4] := .T.
		Else
			AAdd(aDocEnc,{cFilDoc,cDoc,cSerie,.T.,.F.,{},cFilOri, cViagem,cNumRom,cCodOco})
		EndIf
	ElseIf cTipOco == "06" .And. cTipPnd $ "01/02/04"
		If nPosDoc > 0
			aDocEnc[nPosDoc,5] := .T.
		Else
			AAdd(aDocEnc,{cFilDoc,cDoc,cSerie,.F.,.T.,{},cFilOri, cViagem,cNumRom,cCodOco})
		EndIf
		nPosDOc := Ascan(aDocEnc,{|x| x[1]+x[2]+x[3]==cFilDoc+cDoc+cSerie})
		If nTmsOpcx == 3
			lRetorna:= .T.
			If Len(aNFAvaria) > 0
				nPosCTR := Ascan(aNFAvaria,{ |x| x[1]+x[6] == cFilDoc+cDoc+cSerie+Alltrim(Str(nCntFor)) })
				If nPosCTR > 0
					For nI:=1 To len(aNFAvaria[nPosCTR,2])
						If !aNFAvaria[ nPosCTR,2,nI,Len(aNFAvaria[nPosCTR,2,nI]) ] .And. aNFAvaria[ nPosCTR,2,nI,4 ] <> 0
							AAdd(aDocEnc[nPosDOc,6],{aNFAvaria[ nPosCTR,2,nI,1] + aNFAvaria[ nPosCTR,2,nI,2], cTipPnd})
						Else
							lRetorna:= .F.
						EndIf
					Next nI
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestInter()
RestArea(aArea)

Return( aDocEnc )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TM360RTST ºAutor  ³Microsiga           º Data ³  14/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna se todos os documentos de clientes foram:           º±±
±±º          ³1 = Todas NF Entregue / CTRC Entregue                       º±±
±±º          ³2 = Existem NFs a serem entregues / CTRC Entrega Parcial    º±±
±±º          ³3 = Nenhuma NF foi entregue / CTRC em aberto                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM360RTST(cFilDoc,cDoc,cSerie,cFilOri,cViagem)
Local aArea		:= GetArea()
Local aAreaDTQ   := {}
Local aAreaDTW   := {}
Local cQuery	:= ""
Local cAliasQry	:= ""
Local nRet		:= 2  // 1 todas as notas foram entregues / 2 ha notas as serem entregues
Local nTotReg	:= 0
Local nTotEnt	:= 0
Local lVgTrChg   := .F.
Local cAtivChg   := SuperGetMV('MV_ATIVCHG',,'')
Local aAreaDTC   := {}

Default cFilDoc := ""
Default cDoc 	 := ""
Default cSerie  := ""
Default cFilOri  := ''
Default cViagem  := ''

SaveInter()

cAliasQry := GetNextAlias()
If !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc,cDoc,cSerie)
	cQuery:= " SELECT COUNT(*) QTD, DTC_NFENTR "
	cQuery+= " FROM " + RetSqlName("DTC") + " DTC "
	cQuery+= " WHERE DTC_FILIAL = '"+xFilial("DTC")+"' "
	cQuery+= " AND DTC_DOC = '"+cDoc+"' "
	cQuery+= " AND DTC_SERIE = '"+cSerie+"' "
	cQuery+= " AND DTC_FILDOC = '"+cFilDoc+"' "
	cQuery+= " AND D_E_L_E_T_ = ' ' "
	cQuery+= " GROUP BY DTC_NFENTR "
	cTable := "DTC"
Else
	cQuery:= " SELECT DY4_NUMNFC,DY4_SERNFC, DY4_CLIREM, DY4_LOJREM, DY4_CODPRO, DY4_FILORI, DY4_LOTNFC"
	cQuery+= " FROM " + RetSqlName("DY4") + " DY4 "
	cQuery+= " WHERE DY4_FILIAL = '"+xFilial("DY4")+"' "
	cQuery+= " AND DY4_DOC = '"+cDoc+"' "
	cQuery+= " AND DY4_SERIE = '"+cSerie+"' "
	cQuery+= " AND DY4_FILDOC = '"+cFilDoc+"' "
	cQuery+= " AND D_E_L_E_T_ = ' ' "
	cTable := "DY4"
Endif

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY( , , cQuery ), cAliasQry, .F., .T.)

If cTable == "DTC"
	While (cAliasQry)->(!Eof())
		If (cAliasQry)->DTC_NFENTR == "1"
			nTotEnt++
		EndIf
		nTotReg++
		(cAliasQry)->(DbSkip())
	EndDo
Else
	While (cAliasQry)->(!Eof())
		DbSelectArea("DTC")
		DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto
		aAreaDTC := DTC->(getArea())
		If DTC->(MsSeek(xFilial("DTC")+(cAliasQry)->DY4_NUMNFC+(cAliasQry)->DY4_SERNFC+(cAliasQry)->DY4_CLIREM+DY4->DY4_LOJREM+(cAliasQry)->DY4_CODPRO+(cAliasQry)->DY4_FILORI+(cAliasQry)->DY4_LOTNFC))
			If DTC->DTC_NFENTR == "1"
				nTotEnt++
			EndIf
		Endif
		RestArea(aAreaDTC)
		nTotReg++
		(cAliasQry)->(DbSkip())
	EndDo
Endif

(cAliasQry)->(DbCloseArea())


If nTotreg == nTotEnt
	nRet := 1 //todas as notas foram entregues
ElseIf !Empty(cFilOri) .And. !Empty(cViagem)
	DbSelectArea("DTQ")
	DbSetOrder(2) //Filial + Filial Origem + Viagem + Rota
	aAreaDTQ := DTQ->(getArea())
	//Se a Viagem for de Transferencia e possuir apontamento de Chegada,
	//deve considerar que foi tudo entregue, pois ao se apontar a Chegada,
	//o sistema atualiza o DT6_STATUS para "5" (Chegada final).
	If DTQ->(MsSeek(xFilial("DTQ")+cFilOri+cViagem))
		If DTQ->DTQ_SERTMS == StrZero(2, Len(DTQ->DTQ_SERTMS))
			DbSelectArea("DTW")
			DbSetOrder(4) //Filial Origem + Viagem + Sequencia
			aAreaDTW := DTW->(getArea())
			If DTW->(MsSeek(xFilial("DTW")+cFilOri+cViagem+cAtivChg))
				If DTW->DTW_STATUS == StrZero(2, Len(DTW->DTW_STATUS))
					lVgTrChg := .T.
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aAreaDTQ)

	If lVgTrChg
		nRet := 1
	ElseIf nTotEnt == 0
		nRet := 3 //Nenhuma nota foi entregue
	Else
		nRet := 2 //Exitem algumas notas as serem entregues
	EndIf
ElseIf nTotEnt == 0
	nRet := 3 //Nenhuma nota foi entregue
Else
	nRet := 2 //Exitem algumas notas as serem entregues
EndIf

RestInter()
RestArea(aArea)

Return( nRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TM360EPEN ºAutor  ³Adalberto SM        º Data ³  29/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para "Estorno" de Ocorrencias que envolvam PENDENCIA.º±±
±±º          ³	Quando a ocorrencia for do tipo DT2_TIPOCO == 06 (Gera    º±±
±±º          ³	 pendencia), sera executado o ESTORNO DESSA OCORRENCIA.   º±±
±±º          ³	                      									  º±±
±±º          ³	Quando a ocorrencia for do tipo DT2_TIPOCO == 07 (Estorna º±±
±±º          ³	Pendencia), sera APONTADA a ocorrencia e executada a mes- º±±
±±º          ³	ma rotina do estorno do tipo DT2_TIPOCO == 06 (Gera 	  º±±
±±º          ³	pendencia)            									  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM360EPEN(aDocEnc, cFilDoc, cDoc, cSerie, cFilOri, cViagem, cAtivChg, aDoc, nA, lDocEntre, cFilDco,cDocDco,cSerDco,cFilVga,cNumVga)
Local lRet	:= .T.
Local aArea	:= GetArea()
Local lMv_TmsPNDB:= SuperGetMv("MV_TMSPNDB",.F.,.F.) //-- Permite informar a ocorrencia de Pendencia para um Docto Bloqueado
Local lBloqueado := .F.
Local aPnd		 := {}
Local nCnt		 := 0
Local nRec		 := 0
Local cSeekGen   := ''
Local cSeekOri   := ''
Local lDocRee	 := SuperGetMV('MV_DOCREE',,.F.) .And. TMSChkVer('11','R7')

Default lDocEntre:= .F.
Default cFilDco  := ''
Default cDocDco  := ''
Default cSerDco  := ''
Default cFilVga  := ''
Default cNumVga  := ''

If DT2->DT2_TIPPND $ "01/02/04"
	TM360ATDC(4,@aDocEnc,cFilDoc,cDoc,cSerie,DT2->DT2_TIPOCO,DT2->DT2_TIPPND,.F.,,M->DUA_FILORI,M->DUA_VIAGEM,.F.)
EndIf
//-- Se existir pendencia em aberto registrada para o documento.
DUU->( DbSetOrder( 3 ) )
cSeekGen   := xFilial('DUU') + cFilDoc + cDoc + cSerie
cSeekOri   := xFilial('DUU') + cFilDco + cDocDco + cSerDco
If	DUU->( DbSeek( cSeek := xFilial('DUU') + cFilDoc + cDoc + cSerie + StrZero( 1, Len( DUU->DUU_STATUS ) ), .F. ) )
	DT6->( DbSetOrder( 1 ) )
	If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) ) .And. !lDocEntre
		If lMv_TmsPNDB
			lBloqueado:= TM360BLOQ(cFilDoc, cDoc, cSerie)
		EndIf
		If !lBloqueado
			RecLock('DT6',.F.)
			DT6->DT6_BLQDOC := StrZero( 2, Len( DT6->DT6_BLQDOC ) )
			MsUnLock()
		EndIf

		DUD->( DbSetOrder( 1 ) )
		DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilOri + cViagem ) )
		While DUD->(!Eof()) .And. DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM) == xFilial('DUD')+cFilDoc+cDoc+cSerie+cFilOri+cViagem
			If DUD->DUD_STATUS <> StrZero(9,Len(DUD->DUD_STATUS))
				DUD->(dbSkip())
				Loop
			EndIf

			RecLock('DUD', .F. )
			DUD->DUD_STATUS := Tmsa360Doc( cFilOri, cViagem, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE )
			MsUnLock()

			//-- Exclui novo DUD
			If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt + Space(Len(DUD->DUD_VIAGEM)) ) )
				RecLock('DUD', .F. )
				DbDelete()
				MsUnLock()
			EndIf
			Exit
		EndDo
	EndIf
	nRec := DUU->(Recno())
	Do While DUU->( cSeekGen == DUU_FILIAL+DUU_FILDOC+DUU_DOC+DUU_SERIE )
		If DUU->DUU_FILORI + DUU->DUU_VIAGEM == cFilOri + cViagem
			Aadd(aPnd,{DUU->DUU_FILIAL, DUU->DUU_FILDOC, DUU->DUU_DOC, DUU->DUU_SERIE, DUU->DUU_QTDOCO, DUU->DUU_TIPPND, DUU->DUU_CODOCO})
		EndIf
		DUU->( DbSkip() )
	EndDo
    DUU->(DbGoTo(nRec))
	Do While DUU->( cSeekGen == DUU_FILIAL+DUU_FILDOC+DUU_DOC+DUU_SERIE ) .And. Len(aPnd) > 0
		If(nCnt < Len(aPnd), nCnt += 1,)
		If DUU->DUU_FILORI + DUU->DUU_VIAGEM == cFilOri + cViagem  .And.;    //-- evita o estorno de pendencias distintas e estorna bloqueio
				((aPnd[nCnt][6]== "99" .And. aPnd[nCnt][7]== DT2->DT2_CODOCO) .Or. (aPnd[nCnt][6] == DT2->DT2_TIPPND))
			RecLock('DUU',.F.)
				DUU->( DbDelete() )
			MsUnLock()
			If !lDocEntre
				lRet := TM360AtuSal(cFilDoc,cDoc,cSerie,-DUU->DUU_QTDOCO, 'ES',,l360Auto,cFilOri,cViagem, .F.,,,IIF(aPnd[nCnt][6]== "99",7,) )
			EndIf
		EndIf
		DUU->(DbSkip())
	EndDo


	//-- Excluir Nf Avariadas
	DV4->( DbSetOrder( 1 ) )
	If DV4->( MsSeek( xFilial( "DV4" ) + M->DUA_FILOCO + M->DUA_NUMOCO + cFilDoc + cDoc + cSerie ) )
		RecLock( "DV4", .F. )
		DV4->( DbDelete() )
		MsUnLock()
	EndIf

	DYM->(DbSetOrder(1))
	DYM->(DbSeek(cSeek:=xFilial('DYM')+ M->DUA_FILPND+M->DUA_NUMPND))
	Do While !DYM->(Eof()) .And. DYM->(DYM_FILIAL+DYM_FILPND+DYM_NUMPND) == cSeek
		RecLock('DYM', .F.)
		DYM->(dbDelete())
		MsUnLock()
		DYM->(dbSkip())
	EndDo
	DYZ->(DbSetOrder(1))
	DYZ->(DbSeek(cSeek:=xFilial('DYZ')+ M->DUA_FILPND+M->DUA_NUMPND))
	Do While !DYZ->(Eof()) .And. DYZ->(DYZ_FILIAL+DYZ_FILPND+DYZ_NUMPND) == cSeek
		RecLock('DYZ', .F.)
		DYZ->(dbDelete())
		MsUnLock()
		DYZ->(dbSkip())
	EndDo
	If !lDocEntre
		//-- Caso a viagem ja tenha chegado na filial, executar tmsmovviag para gerar movimento na filial.
		DTW->( DbSetOrder( 4 ) )
		DUD->( DbSetOrder( 1 ) )
		If	DTW->(  DbSeek( xFilial('DTW') + cFilOri + cViagem + cAtivChg + cFilAnt ) ) .And. DTW->DTW_STATUS == StrZero( 2, Len( DTW->DTW_STATUS ) ) .And. lDocRee
			DUD->( !DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt ) )
			TMSMovViag( cFilOri, cViagem, cAtivChg, aDoc, nA, 3 )	//-- Inclui movto viagem e estoque
		EndIf
	EndIf
ElseIf DUU->( DbSeek( cSeek := xFilial('DUU') + cFilDco + cDocDco + cSerDco + StrZero( 1, Len( DUU->DUU_STATUS ) ), .F. ) ) .And. lDocRee
	DT6->( DbSetOrder( 1 ) )
	If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie) ) .And. !lDocEntre    //-- desbloqueia documento de reentrega
		If lMv_TmsPNDB
			lBloqueado:= TM360BLOQ(cFilDoc, cDoc, cSerie)
		EndIf
		If !lBloqueado
			RecLock('DT6',.F.)
			DT6->DT6_BLQDOC := StrZero( 2, Len( DT6->DT6_BLQDOC ) )
			MsUnLock()
		EndIf

		DUD->( DbSetOrder( 1 ) )
		DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilOri + cViagem ) )
		While DUD->(!Eof()) .And. DUD->(DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM) == xFilial('DUD')+cFilDoc+cDoc+cSerie+cFilOri+cViagem
			If DUD->DUD_STATUS <> StrZero(9,Len(DUD->DUD_STATUS))
				DUD->(dbSkip())
				Loop
			EndIf

			RecLock('DUD', .F. )
			DUD->DUD_STATUS := Tmsa360Doc( cFilOri, cViagem, DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE )
			MsUnLock()

			//-- Exclui novo DUD
			If DUD->( DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt + Space(Len(DUD->DUD_VIAGEM)) ) )
				RecLock('DUD', .F. )
				DbDelete()
				MsUnLock()
			EndIf
			Exit
		EndDo
	EndIf
	nRec := DUU->(Recno())
	Do While DUU->( cSeekOri == DUU_FILIAL+DUU_FILDOC+DUU_DOC+DUU_SERIE )
		If DUU->DUU_FILORI + DUU->DUU_VIAGEM == cFilOri + cViagem
			Aadd(aPnd,{DUU->DUU_FILIAL, DUU->DUU_FILDOC, DUU->DUU_DOC, DUU->DUU_SERIE, DUU->DUU_QTDOCO, DUU->DUU_TIPPND, DUU->DUU_CODOCO})
		EndIf
		DUU->( DbSkip() )
	EndDo
    DUU->(DbGoTo(nRec))
	Do While DUU->( cSeekOri == DUU_FILIAL+DUU_FILDOC+DUU_DOC+DUU_SERIE ) .And. Len(aPnd) > 0
		Iif (nCnt < Len(aPnd), nCnt += 1,)
			If DUU->DUU_FILORI + DUU->DUU_VIAGEM == cFilOri + cViagem  .And.;    //-- evita o estorno de pendencias distintas e estorna bloqueio
				 ((aPnd[nCnt][6]== "99" .And. aPnd[nCnt][7]== DT2->DT2_CODOCO) .Or. (aPnd[nCnt][6] == DT2->DT2_TIPPND))
				RecLock('DUU',.F.)
			   		DUU->( DbDelete() )        //-- estorna pendencia do documento original
				MsUnLock()
				If !lDocEntre
					lRet := TM360AtuSal(cFilDoc,cDoc,cSerie,-DUU->DUU_QTDOCO, 'ES',,l360Auto,cFilOri,cViagem, .F.,,,IIF(aPnd[nCnt][6]== "99",7,) )
					If lRet
						TM360AtuSal(cFilDoc,cDocDco,cSerDco,-DUU->DUU_QTDOCO, 'ES',,l360Auto,cFilVga,cNumVga, .F.,,,IIF(aPnd[nCnt][6]== "99",7,) )
					EndIf
				EndIf
			EndIf
			DUU->(DbSkip())
		EndDo


	//-- Excluir Nf Avariadas
	DV4->( DbSetOrder( 1 ) )
	If DV4->( MsSeek( xFilial( "DV4" ) + M->DUA_FILOCO + M->DUA_NUMOCO + cFilDoc + cDoc + cSerie ) )
		RecLock( "DV4", .F. )
		DV4->( DbDelete() )
		MsUnLock()
	EndIf

	DYM->(DbSetOrder(1))
	DYM->(DbSeek(cSeek:=xFilial('DYM')+ M->DUA_FILPND+M->DUA_NUMPND))
	Do While !DYM->(Eof()) .And. DYM->(DYM_FILIAL+DYM_FILPND+DYM_NUMPND) == cSeek
		RecLock('DYM', .F.)
		DYM->(dbDelete())
		MsUnLock()
		DYM->(dbSkip())
	EndDo
	DYZ->(DbSetOrder(1))
	DYZ->(DbSeek(cSeek:=xFilial('DYZ')+ M->DUA_FILPND+M->DUA_NUMPND))
	Do While !DYZ->(Eof()) .And. DYZ->(DYZ_FILIAL+DYZ_FILPND+DYZ_NUMPND) == cSeek
		RecLock('DYZ', .F.)
		DYZ->(dbDelete())
		MsUnLock()
		DYZ->(dbSkip())
	EndDo
	If !lDocEntre
		//-- Caso a viagem ja tenha chegado na filial, executar tmsmovviag para gerar movimento na filial.
		DTW->( DbSetOrder( 4 ) )
		DUD->( DbSetOrder( 1 ) )
		If	DTW->(  DbSeek( xFilial('DTW') + cFilOri + cViagem + cAtivChg + cFilAnt ) ) .And. DTW->DTW_STATUS == StrZero( 2, Len( DTW->DTW_STATUS ) ) .And. ;
			DUD->( !DbSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie + cFilAnt ) )
			TMSMovViag( cFilOri, cViagem, cAtivChg, aDoc, nA, 3 )	//-- Inclui movto viagem e estoque
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return( lRet )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360DY7³ Autor ³ Gustavo Almeida       ³ Data ³17/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza Voo da Cia Aerea para o dia na confirmação de    ³±±
±±³          ³	embarque.					                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA360DY7()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360DY7()

Local aItens     := {}
Local aNewButton := {}
Local cQuery     := ""
Local cCadAnt    := cCadastro
Local cAliasQry  := GetNextAlias()
Local lRet       := .T.
Local lCancel    := .T.
Local nSemAtu

Private aTitulo  := {}

If FindFunction('TMSChkVer') .And. !TMSChkVer('11','R5')
	Aviso(STR0066, STR0067 + Chr(10)+Chr(13) + STR0068, {STR0069}, 1) //"Versão Protheus" "Versão do sistema atual é inferior a 11.5" "Atualize o sistema!" "Ok"
	Return Nil
EndIf

cCadastro  := STR0061 //"Escolha o Voo"

cQuery := "SELECT DY7_NUMVOO, DY7_TIPVOO, DY7_AERORI, DY7_AERDES, DY7_AERPAR, DY7.R_E_C_N_O_ "
cQuery += "  FROM " + RetSqlName("DY7") + " DY7, " + RetSqlName("DTV") + " DTV "
cQuery += " WHERE DTV_FILIAL = '" + xFilial("DTV") + "' "
cQuery += "   AND DTV_NUMAWB = '" + M->DVH_NUMAWB + "' "
cQuery += "   AND DTV_DIGAWB = '" + M->DVH_DIGAWB + "' "
cQuery += "   AND DTV_CODCIA = '" + M->DVH_CODCIA + "' "
cQuery += "   AND DTV_LOJCIA = '" + M->DVH_LOJCIA + "' "

cQuery += "   AND DY7_FILIAL = '" + xFilial("DY7") + "' "
cQuery += "   AND DY7_AERORI = DTV_AERORI "
cQuery += "   AND (DY7_AERDES = DTV_AERDES OR DY7_AERPAR = DTV_AERDES)"

//-- Dia da Semana do Voo
nSemAtu := Dow(Date())
cQuery += "   AND DY7_SEMAN" + AllTrim(Str(nSemAtu)) + " = '1' "

cQuery += "   AND DTV.D_E_L_E_T_ = ' ' "
cQuery += "   AND DY7.D_E_L_E_T_ = ' ' "

cQuery += " ORDER BY DY7_TIPVOO, DY7_NUMVOO "


cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

While (cAliasQry)->(!Eof())                                             //"Direto"                                "Escala" "Conexão"
	Aadd(aItens,{ (cAliasQry)->DY7_NUMVOO,Iif((cAliasQry)->DY7_TIPVOO=='1',STR0062,Iif((cAliasQry)->DY7_TIPVOO=='2',STR0063,STR0064)),;
	              (cAliasQry)->DY7_AERORI,(cAliasQry)->DY7_AERDES,(cAliasQry)->DY7_AERPAR,(cAliasQry)->R_E_C_N_O_ } )
	(cAliasQry)->(dbSkip())
EndDo

If Len(aItens) > 0
	Aadd( aTitulo, RetTitSX3('DY7_NUMVOO') )
	Aadd( aTitulo, RetTitSX3('DY7_TIPVOO') )
	Aadd( aTitulo, RetTitSX3('DY7_AERORI') )
	Aadd( aTitulo, RetTitSX3('DY7_AERDES') )
	Aadd( aTitulo, RetTitSX3('DY7_AERPAR') )
	aCabec := aClone(aTitulo)

	nRet := TmsF3Array( aTitulo, aItens, cCadastro, lCancel, aNewButton, aCabec )

	If !Empty(nRet)
		DY7->(dbGoTo(aItens[nRet,Len(aTitulo)+1]))
	Else
		lRet := .F.
	EndIf

Else
	MsgAlert( STR0065 ) //"Não existem voos cadastrados para a região"
	lRet := .F.
EndIf

cCadAnt:= cCadastro
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA360Pre³ Autor ³ Gustavo Almeida    ³ Data ³ 12/05/2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Prepara os dados da Envio do e-mail do Pre-Alerta.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Sintaxe   ³ TMSA360Pre(ExpN1,ExpC1,ExpC2,ExpC3,ExpC4)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao selecionada                                  ³±±
±±³          ³ ExpC1 = Filial da ocorrencia                               ³±±
±±³          ³ ExpC2 = Numero da ocorrencia                               ³±±
±±³          ³ ExpC3 = Filial de origem                                   ³±±
±±³          ³ ExpC4 = Viagem                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360Pre(nOpcx,cFilOco,cNumOco,cFilOri,cViagem,dDatPar,cHorPar,dDatChg,cHorChg,cNumVoo,cNumAWB,cDigAWB)

Local aArea     := {GetArea(),DUA->(GetArea()),DTV->(GetArea()),DTQ->(GetArea()),DUY->(GetArea()),DT2->(GetArea()),DY8->(GetArea())}
Local nX 		 := 0
Local nCntFor1  := 0
Local cTipOco   := ""

//-- Var. Email
Local cPara     := ""
Local cLogo     := ""
Local cRootPath := ""
Local cBarSrv   := Iif( IsSrvUnix(), "/", "\" ) //Checa se o Server e Linux
Local aDestE    := {}
Local aDestI    := {}
Local cAssunto  := Iif( nOpcx == 3, STR0070, STR0071) //"AVISO DE PRE-ALERTA - "###"CANCELAMENTO DE PRE-ALERTA - "
Local cMsg      := ""
Local lSendMail := .F.
Local cMsgErr   := ""
Local nOpca     := nOpcx
Local lFWCodFil := FindFunction( "FWCodFil" )
Local aTM360AWB	:= {}
Local lTM360AWB	:= ExistBlock('TM360AWB')
Local nPos		:= 0 

Private lCancela := Iif( nOpcx == 4,.T.,.F.)
Private cEmpFil  := ""

Default cNumAwb := ""
Default cDigAwb := ""

aAdd(aDestE,cPara)

If IsSrvUnix()
	cRootPath := CurDir() + cBarSrv
Else
	cRootPath := CurDir()
EndIf

//-- Anexo de Logo da Empresa
cLogo:= cRootPath + "LGRL" + SM0->M0_CODIGO + Iif( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) + ".BMP" 	// Empresa+Filial
cEmpFil := SM0->M0_CODIGO+Iif( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

If !File( cLogo )
	cLogo   := cRootPath + "LGRL" + SM0->M0_CODIGO + ".BMP"
	cEmpFil := SM0->M0_CODIGO
Endif

DUA->(DbSetOrder(1)) //DUA_FILIAL+DUA_FILOCO+DUA_NUMOCO+DUA_FILORI+DUA_VIAGEM+DUA_SEQOCO
DTQ->(DbSetOrder(2)) //DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
DUY->(DbSetOrder(1)) //DUY_FILIAL+DUY_GRPVEN
DTV->(DbSetOrder(2)) //DTV_FILIAL+DTV_FILORI+DTV_VIAGEM

If nOpca == 3
	If DUA->(DbSeek(xFilial('DUA')+cFilOco+cNumOco))
		//-- Verifica a existencia do AWB.
		cAliasDTV := GetNextAlias()
		cQuery := " SELECT DTV_NUMAWB,DTV_DIGAWB,DTV_CODCIA, DTV_LOJCIA, DTV_FILDES, R_E_C_N_O_ "
		cQuery += "FROM " + RetSqlName("DTV")
		cQuery += " WHERE DTV_FILIAL = '" + xFilial('DTV') + "' "
		cQuery += "   AND DTV_FILORI = '" + cFilOri + "' "
		cQuery += "   AND DTV_VIAGEM = '" + cViagem + "' "
		cQuery += "   AND DTV_NUMAWB = '" + cNumAWB + "' "
		cQuery += "   AND DTV_DIGAWB = '" + cDigAWB + "' "
		cQuery += "   AND D_E_L_E_T_ = ' '
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasDTV, .F., .T. )

		If (cAliasDTV)->(!Eof())
			DTV->(dbGoto((cAliasDTV)->R_E_C_N_O_))

			DTQ->(DbSeek(xFilial("DTQ")+DUA->( DUA_FILORI+DUA_VIAGEM )))
			//-- viagem de transporte e entrega do tipo Aereo.
			If DTQ->DTQ_SERTMS $ '2/3' .And. DTQ->DTQ_TIPTRA == '2'
				cTipOco	:= Posicione('DT2',1,XFILIAL('DT2')+DUA->DUA_CODOCO,'DT2_TIPOCO')
				//-- Somente para ocorrencia do Tipo informativa
				If cTipOco == '05'
					RegToMemory("DY8",.T.)
					M->DY8_FILIAL := xFilial("DY8")
					M->DY8_NUMAWB := (cAliasDTV)->DTV_NUMAWB
					M->DY8_DIGAWB := (cAliasDTV)->DTV_DIGAWB
					M->DY8_CODCIA := (cAliasDTV)->DTV_CODCIA
					M->DY8_LOJCIA := (cAliasDTV)->DTV_LOJCIA
					M->DY8_FILOCO := cFilOco
					M->DY8_NUMOCO := cNumOco

					//-- Inicio do Envio de E-mail
					nPos	:= aScan( aMailPre , {|x| x[1] == (cAliasDTV)->DTV_FILDES })
					If nPos == 0 
						cPara	:= Lower(SuperGetMv( "MV_MAILPRE",.F.,"", (cAliasDTV)->DTV_FILDES ))
						Aadd( aMailPre , { (cAliasDTV)->DTV_FILDES , cPara })
					Else 
						cPara      := aMailPre[nPos,2]
					EndIf 

					aAdd(aDestE,cPara)
					cAssunto   += M->DY8_NUMPRE
					cMsg       := ExecBlock('RTMSR26',,.F.,{nOpca,cFilOri,cViagem,cFilOco,cNumOco,dDatPar,cHorPar,dDatChg,cHorChg,cNumVoo}) //-- Rdmake da Mensagem

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³PONTO DE ENTRADA PARA MANIPULAR O E-MAIL
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lTM360AWB
						aTM360AWB := ExecBlock('TM360AWB',.F.,.F.,{cAssunto,aDestE})
						If ValType(aTM360AWB ) == 'A'
							cAssunto 	:= aTM360AWB[1]
							aAdd(aDestE,   aTM360AWB[2])
						EndIf
					EndIf
			  		lSendMail  := TMSMAIL( aDestE, aDestI, cAssunto, cMsg, .F., '3', @cMsgErr, .T., cLogo )
					//-- Fim do Envio

					If lSendMail
						M->DY8_STATUS := '1' //-- Aviso Enviado
						M->DY8_OBS    := 'Pre-alerta enviado para: '+cPara
	   				Aviso(STR0072, STR0073,{STR0069}) //"Pre-alerta"###'E-mail de pre-alerta enviado com sucesso'###"Ok"
					Else
						If !Empty(cMsgErr)
		   				Help(' ', 1, 'TMSA36081',,cMsgErr,2,11)  //-- Ocorreu um problema no envio do e-mail:
		   			EndIf
						M->DY8_STATUS := '2' //-- Falha no Envio do Aviso
						M->DY8_OBS    := 'Problemas no envio do Pre-alerta:'+Chr(13)+Chr(10)
						M->DY8_OBS    += cMsgErr
					EndIf

					M->DY8_DATPRE := Date()
					M->DY8_HORPRE := StrTran(Padr(Time(),5),':','')

					RecLock("DY8",.T.)
					For nCntFor1 := 1 To FCount()
						If "FILIAL" $ Field(nCntFor1)
							FieldPut(nCntFor1,xFilial("DY8"))
						Else
							If Type("M->" + FieldName(nCntFor1)) <> "U"
								FieldPut(nCntFor1,M->&(FieldName(nCntFor1)))
							EndIf
						EndIf
					Next nCntFor1

					MSMM(DY8->DY8_CODOBS,,,M->DY8_OBS,1,,,"DY8","DY8_CODOBS")
					DY8->(MsUnLock())

					If __lSX8
						ConfirmSX8()
					EndIf

				Endif
			EndIf
		EndIf
		(cAliasDTV)->(dbCloseArea())
	EndIf

ElseIf nOpca == 4 //-- Estorno da Ocorrencia

	DY8->(DbSetOrder(3))
	If DY8->(dbSeek(xFilial("DY8")+ cFilOco + cNumOco ))
		While DY8->(!Eof()) .And. 	xFilial("DY8")+ cFilOco + cNumOco == DY8->DY8_FILIAL + DY8->DY8_FILOCO + DY8->DY8_NUMOCO
			RegToMemory("DY8",.F.)

			DTV->(DbSetOrder(1))
			DTV->(dbSeek(xFilial("DTV")+ DY8->DY8_NUMAWB + DY8->DY8_DIGAWB + DY8->DY8_CODCIA + DY8->DY8_LOJCIA ))

			//-- Envio de Cancelamento de Pre-Alerta
			cPara      := Lower(SuperGetMv( "MV_MAILPRE",.F.,"", DTV->DTV_FILDES ))
			aAdd(aDestE,cPara)
			M->DY8_OBS := cPara
			cAssunto   += M->DY8_NUMPRE
			cMsg       := ExecBlock('RTMSR26',,.F.,{nOpca,cFilOri,cViagem,cFilOco,cNumOco,dDatPar,cHorPar,dDatChg,cHorChg,cNumVoo}) //-- Rdmake da Mensagem
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PONTO DE ENTRADA PARA MANIPULAR O E-MAIL
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTM360AWB
				aTM360AWB := ExecBlock('TM360AWB',.F.,.F.,{cAssunto,aDestE})
				If ValType(aTM360AWB ) == 'A'
					cAssunto 	:= aTM360AWB[1]
					aAdd(aDestE,   aTM360AWB[2])
				EndIf
			EndIf

			lSendMail  := TMSMAIL( aDestE, aDestI, cAssunto, cMsg, .F., '3', @cMsgErr, .T., cLogo )

			//-- Fim do Envio

			RecLock("DY8",.F.)
			If lSendMail
				DY8->DY8_STATUS := '3' //-- Cancelamento Enviado por e-mail
				Aviso(STR0074, STR0075,{STR0069}) //"Cancelamento de pre-alerta"###'E-mail de cancelamento de pre-alerta enviado com sucesso'###"Ok"
			Else

		   	If !Empty(cMsgErr)
		   		Help(' ', 1, 'TMSA36081',,cMsgErr,2,11)  //-- Ocorreu um problema no envio do e-mail:
		   	EndIf

				DY8->DY8_STATUS := '4' //-- Falha no Envio do Cancelamento por e-mail

			EndIf
			DY8->(MsUnLock())
			DY8->(DbSkip())
		EndDo
	Endif

EndIf

For nX := 1 To Len(aArea)
	RestArea(aArea[nX])
Next nX

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA360   ºAutor  ³Katia               º Data ³  19/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se permite a ocorrencia de Pendencia/Indenizacao   º±±
±±º          ³para o documento ja entregue, conforme prazo determinado    º±±
±±º          ³no parametro MV_TMSDIND                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM360INDE(cFilDoc, cDoc, cSerie, cTipOco, nTmsdInd)
Local lRet	    := .F.
Local aArea	    := GetArea()

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""

If ( cTipOco == StrZero(6,Len(DT2->DT2_TIPOCO)) .Or. cTipOco == StrZero(9,Len(DT2->DT2_TIPOCO)) )
	DT6->(DbSetOrder(1))
	If DT6->(DbSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie)) .And. DT6->DT6_STATUS == StrZero( 7, Len( DT6->DT6_STATUS ) ) //Entregue
		If (dDataBase - DT6->DT6_DATENT) <= nTmsdInd
			lRet:= .T.
		EndIf
	EndIf
EndIf

RestArea( aArea )
Return ( lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA360   ºAutor  ³Katia               º Data ³  01/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe uma ocorrencia de 'Bloqueia Documento'   º±±
±±º          ³em aberto, ou seja, nao houve o apontamento da ocorrencia   º±±
±±º          ³de 'Libera Documento'                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Utilizado nos casos em que o parametro Mv_TmsPNDB está      º±±
±±º          ³ativo e onde há uma digitacao de ocorrencia de Pendencia    º±±
±±º          ³para um Documento Bloqueado.                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM360BLOQ(cFilDoc, cDoc, cSerie, cFilOco, cNumOco)
Local lRet	     := .F.
Local aArea	     := GetArea()
Local nQtdBlq    := 0
Local nQtdLib    := 0
Local cQuery     := ""

Default cFilOco  := ""
Default cNumOco  := ""

cAliasQry := GetNextAlias()
cQuery :=" SELECT DT2_TIPOCO, COUNT(*) NQTDOCO"
cQuery +="  FROM " + RetSqlName('DUA') + " DUA, " + RetSqlName("DT2") + " DT2"
cQuery +="  WHERE DUA.DUA_FILIAL = '" + xFilial('DUA') + "' "
cQuery +=" 	AND DUA.DUA_FILDOC = '" + cFilDoc + "' "
cQuery +=" 	AND DUA.DUA_DOC	   = '" + cDoc + "' "
cQuery +=" 	AND DUA.DUA_SERIE  = '" + cSerie + "' "
If !Empty(cFilOco) .And. !Empty(cNumOco)
	cQuery +=" 	AND DUA.DUA_FILOCO  = '" + cFilOco + "' "
	cQuery +=" 	AND DUA.DUA_NUMOCO <> '" + cNumOco + "' "
EndIf
cQuery +=" 	AND DT2.DT2_FILIAL = '" + xFilial('DT2') + "' "
cQuery +=" 	AND DT2.DT2_CODOCO = DUA.DUA_CODOCO "
cQuery +=" 	AND DT2.DT2_TIPOCO IN ('" + StrZero(2,Len(DT2->DT2_TIPOCO)) + "',"
cQuery +="'"+StrZero(3,Len(DT2->DT2_TIPOCO))+ "')"
cQuery +="  AND DT2.D_E_L_E_T_ = ' '"
cQuery +="  AND DUA.D_E_L_E_T_ = ' '"
cQuery +="  GROUP BY DT2_TIPOCO "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
While (cAliasQry)->(!Eof())
	If (cAliasQry)->(DT2_TIPOCO) == StrZero(2,Len(DT2->DT2_TIPOCO)) //Bloqueia Documento
		nQtdBlq:= (cAliasQry)->nQtdOco
	Else
		nQtdLib:= (cAliasQry)->nQtdOco
	EndIf
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

If nQtdBlq > nQtdLib
	lRet:= .T.
EndIf

RestArea( aArea )
Return ( lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TM360PNB  ºAutor  ³Guilherme Gaiofatto º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe uma ocorrencia de 'Bloqueia Documento'   º±±
±±º          ³e atualiza a quantidade de documentos nessa pendencia de    º±±
±±º          ³bloqueio                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Apos inclusoes e estorno de pendencias que geram bloqueio.  º±±
±±º          ³Usado para reutilizar o registro de bloqueio de documento   º±±
±±º          ³quando a mais de uma pendencia.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM360PNB(nOpcx, cFilDoc, cDoc, cSerie, cFilOri, cViagem, cTipPnd, nQuant)
Local aArea := GetArea()
Local cSeek := ''

Default nOpcx   := 0
Default cFilDoc := ''
Default cDoc 	:= ''
Default cSerie  := ''
Default cFilOri := ''
Default cViagem := ''
Default nQuant  := 0

If cTipPnd <> "99" .And. nQuant > 0
	DbSelectArea("DUU")
	DbSetOrder(3)
	DUU->(DbSeek(cSeek:= xFilial("DUU")+cFilDoc+cDoc+cSerie) )
	Do While DUU->(DUU_FILIAL+DUU_FILDOC+DUU_DOC+DUU_SERIE) == cSeek .And. !DUU->(EoF())	//-- Verifica se ja existe bloqueio para aquele documento
		If DUU->DUU_FILORI + DUU->DUU_VIAGEM == cFilOri + cViagem .AND. DUU->DUU_TIPPND == "99"
			If nOpcx = 1	//-- Inclui
				RecLock('DUU', .F. )			//-- Subtrai da ocorrencia de bloqueio a qtd da nova pendencia
					DUU->DUU_QTDOCO -= nQuant
				MsUnLock()
			ElseIf nOpcx = 2	//-- Estorna
				RecLock('DUU', .F. )		//-- Soma a quantidade estornada ao bloqueio
					DUU->DUU_QTDOCO += nQuant
				MsUnLock()
			EndIf
		EndIf
		DUU->(DbSkip())
	EndDo
EndIf

RestArea(aArea)
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360CBX³ Autor ³ Guilherme R. Gaiofatto³ Data ³ 12/12/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ X3_Box do campo DT6_STATUS                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ³TMSA360CBX()³                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA360                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360CBX()

Local cRet := STR0076	//"1=Em Aberto;2=Carregado;3=Em Transito;4=Chegada Parcial;5=Chegada Final;6=Indicado para Entrega;7=Entregue;8=Entrega Parcial;9=Anulado;A=Retorno Total"

Return cRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360SF     ³ Autor ³ Katia                ³ Data ³08.02.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Se o Tipo de Ocorrencia Informada for "Gera Pendencia" do Tipo ³±±
±±³          ³Sobra ou Falta, monta a tela de identificacao de produtos      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA360SF(ExpC1, ExpC2, ExpN1, ExpC3, ExpC4, ExpL5)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Fil. Ocorrencia                                        ³±±
±±³          ³ExpC2 - Num. Ocorrencia                                        ³±±
±±³          ³ExpN1 - Opcao Selecionada                                      ³±±
±±³          ³ExpC3 - Fil. Pendencia                                         ³±±
±±³          ³ExpC4 - Num. Pendencia                                         ³±±
±±³          ³ExpL5 - NfAvaria                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA360SF(cFilOco, cNumOco, nOpcx, cFilPnd, cNumPnd, lNfAvaria)

Local oGetD, oDlgEsp
Local cCadOld      := cCadastro
Local aColsBack    := AClone(aCols)
Local aHeaderBack  := AClone(aHeader)
Local nOpca        := 0
Local nSavN        := n
Local lRet         := .T.
Local aArea        := GetArea()
Local cCodOco      := GdFieldGet('DUA_CODOCO', n)
Local nPosFilDoc   := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DUA_FILDOC' } )
Local nPosDoc      := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DUA_DOC'    } )
Local nPosSerie    := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DUA_SERIE'  } )
Local nQtdPnd      := GdFieldGet('DV4_QTDPND', n)
Local nPosNfc      := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DV4_NUMNFC' } )
Local nPosSerNfc   := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DV4_SERNFC' } )
Local nPosDYM	     := 0
Local aRetPE       := {}
Local cTMSCOSB	   := SuperGetMV('MV_TMSCOSB',,'0')
Local nCont  	   := 0
Local aFldDYM      := {}

Default nOpcx		:= 3
Default lNfAvaria	:= .T.

If cTMSCOSB == '0' //Não utiliza informação de produto.
	Help('', 1, 'TMSA360F0')	 //-- Parametro MV_TMSCOSB nao definido ou possui indicacao que nao deve ser informado a Identificacao do Produto (Valor igual a "0").
	lRet := .F.
	Return lRet
EndIf

If nOpcx == 3
	If lNfAvaria
		If nQtdPnd == 0
			Help('',1,'TMSA360B5')		//-- Nao e permitido informar detalhes da Identificacao do Produto para quantidade pendente igual a zero.
			RestArea( aArea )
			lRet := .F.
			Return lRet
		EndIf
		nPosDYM := Ascan(aIdProduto,{ |x| x[1] == M->DUA_FILOCO+M->DUA_NUMOCO+aColsBack[nSavN][nPosNfc]+aColsBack[nSavN][nPosSerNfc] })
	Else
		nPosDYM := Ascan(aIdProduto,{ |x| x[1] == M->DUA_FILOCO+M->DUA_NUMOCO+aColsBack[nSavN][nPosFilDoc]+aColsBack[nSavN][nPosDoc]+aColsBack[nSavN][nPosSerie] })
	EndIf
Else
	If lNfAvaria
		nPosDYM := Ascan(aIdProduto,{ |x| x[1] == cFilPnd+cNumPnd+aColsBack[nSavN][nPosNfc]+aColsBack[nSavN][nPosSerNfc] })
	Else
		nPosDYM := Ascan(aIdProduto,{ |x| x[1] == cFilPnd+cNumPnd+aColsBack[nSavN][nPosFilDoc]+aColsBack[nSavN][nPosDoc]+aColsBack[nSavN][nPosSerie] })
	EndIf

	If nPosDYM == 0
		RestArea( aArea )
		lRet := .F.
		Return lRet
	EndIf
EndIf

cCadastro := STR0078 //"Identificacao de Produtos"
n         := 1
aCols     := {}
aHeader   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aHeaderDYM) == 0
	aFldDYM := ApBuildHeader("DYM")
	For nCont := 1 To Len(aFldDYM)
		If aFldDYM[nCont][2] $ "DYM_TPIDPD.DYM_DESCRI.DYM_DETALH"
			aAdd(aHeader, aFldDYM[nCont])
		EndIf
	Next nCont
	aHeaderDYM := Aclone(aHeader)
Else
	aHeader := Aclone(aHeaderDYM)
EndIf

If	nPosDYM > 0
	aCols  := aClone(aIdProduto[nPosDYM][2])
EndIf


//-- Ponto de entrada que permite informar conteudo dos campos da Identificacao do Produto
If nOpcx == 3
	If ExistBlock("TM360CSF",cFilOco,cNumOco)
		aRetPE := ExecBlock("TM360CSF",.F.,.F.)
		If ValType(aRetPE) == "A"
			aCols:= aClone(aRetPE)
		EndIf
	EndIf
EndIf

DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM 85 ,104 TO 370,630 PIXEL

oGetD := MSGetDados():New(30,2,140,262,If(nOpcx<>3, 2, nOpcx),'TM360SFLOk','AllwaysTrue()',, If(nOpcx == 2, .F., .T.),)

ACTIVATE MSDIALOG oDlgEsp CENTERED ON INIT EnchoiceBar(oDlgEsp,{||nOpca:=1, IIf(TM360SFTOk(,cCodOco,nOpcx),oDlgEsp:End(),nOpca := 0)},{||oDlgEsp:End()})

If nOpca == 1 .And. nOpcx <> 2
	If nPosDYM > 0
		aIdProduto[nPosDYM][2]	:= aClone(aCols)
	Else
		If lNfAvaria
			AAdd(aIdProduto,{M->DUA_FILOCO+M->DUA_NUMOCO+aColsBack[nSavN][nPosNfc]+aColsBack[nSavN][nPosSerNfc],aClone(aCols) })
		Else
			AAdd(aIdProduto,{M->DUA_FILOCO+M->DUA_NUMOCO+aColsBack[nSavN][nPosFilDoc]+aColsBack[nSavN][nPosDoc]+aColsBack[nSavN][nPosSerie],aClone(aCols) })
		EndIf
	EndIf
EndIf

n         := nSavN
cCadastro := cCadOld
aCols     := AClone(aColsBack)
aHeader   := AClone(aHeaderBack)

RestArea( aArea )

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TM360SFLOk    ³ Autor ³ Katia                ³ Data ³13.02.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao da Linha digitada na GetDados de Sobra e Faltas      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TM360SFLOk()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM360SFLOk()

Local lRet := .T.

If !GDdeleted( n )
	//-- Verifica campos obrigatorios
	lRet := MaCheckCols( aHeader, aCols, n )

	If lRet
	   lRet := GDCheckKey( { 'DYM_TPIDPD' }, 4 )
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TM360SFTOk    ³ Autor ³ Katia                ³ Data ³13.02.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao Geral (Sobras e Faltas)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TM360SFTOk()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Linha.                                                 ³±±
±±³          ³ExpC1 - Codigo da Ocorrencia.                                  ³±±
±±³          ³ExpN1 - Opcao Selecionada.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM360SFTOk(nx,cCodOco,nOpcx)
Local lRet:= .T.
Local cTMSCOSB := SuperGetMV('MV_TMSCOSB',,'0')

If !GDdeleted( n )
	//-- Verifica campos obrigatorios
	If cTMSCOSB == '1'  //Obrigatorio
		lRet := MaCheckCols( aHeader, aCols, n )
	EndIf

	If lRet
	   lRet := GDCheckKey( { 'DYM_TPIDPD' }, 4 )
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TM360PcVar    ³ Autor ³ Jefferson            ³ Data ³08.02.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Picture da variavel                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TM360PcVar()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Mascara                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM360PcVar()

Local aArea   := GetArea()
Local cMasc	:= ''
Local cRotina := FunName()
Local lVisCon := Iif(!Empty(cRotina),cRotina $ 'TMSA541|TMSA540',.F.)
Local cTpIdPd:=  Iif(lVisCon, FwFldGet('DYM_TPIDPD'), GDFieldGet( 'DYM_TPIDPD', n ) )

If lVisCon
	Return Nil
EndIf

If !Empty(cTpIdPd)
	DYL->( DbSetOrder( 1 ) )
	If DYL->( DbSeek( xFilial('DYL') + cTpIdPd ) )
		cMasc := AllTrim(Tabela("ET",DYL->DYL_CODPIC,.F.))
		If !lVisCon
			cMasc += "%C"
		EndIf
	EndIf
EndIf

RestArea( aArea )
Return( cMasc )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TM360VlPan    ³ Autor ³ Leandro Paulino      ³ Data ³08.02.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o processamento de rotinas do painel de agendamentp     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TM360VlPan()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Loógico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM360VlPan(cFilOri,cViagem,cFilDoc,cDoc,cSerie,nAcao,cSerTms)

Local cAgen 	 := ""
Local cItAge	 := ""
Local aAgend	 := {}
Local aItAge	 := {}
Local aTotAge	 := {}
Local nAgen 	 := 0
Local aArea 	 := GetArea()
Local cQuery	 := ""
Local cAliasQry := ""
Local lAchou	 := .F.

Default cFilOri := ""
Default cViagem := ""
Default cFilDoc := ""
Default cDoc	 := ""
Default cSerie	 := ""
Default cSerTms := "1"
Default nAcao 	 := 1

If (Type("aPanAgeTms") <> "U" .And. Len(aPanAgeTms)>4) .And. aPanAgeTms[4] <> NIL .And. aPanAgeTms[5] <> NIL
	cAgen := aPanAgeTms[4]
	cItAge:= aPanAgeTms[5]
	aAgend := StrTokArr(cAgen ,",")
	aItAge := StrTokArr(cItAge,",")

		//--Total de Agendamentos e Itens Marcados
	For nAgen:= 1 To Len(aAgend)
		AAdd(aTotAge,{aAgend[nAgen],aItAge[nAgen]})
	Next nAgen

	cAliasQry := GetNextAlias()
	cQuery := " SELECT DISTINCT "
	If nAcao == 1 //Validacao Viagem
		cQuery += " 	DF1_NUMAGE, DF1_ITEAGE  "
	ElseIf (nAcao == 2 .And. Len(aTotAge) == 1)
		cQuery += " 	DUD_FILORI, DUD_VIAGEM  "
	EndIf
	cQuery += " 	FROM " + RetSqlName("DUD") + " DUD "
	cQuery += " 		INNER JOIN " + RetSqlName("DT6") + " DT6 "
	cQuery += " 			ON DUD.DUD_FILDOC  = DT6.DT6_FILDOC   "
	cQuery += "				AND DUD.DUD_DOC    = DT6.DT6_DOC 	  "
	cQuery += "				AND DUD.DUD_SERIE  = DT6.DT6_SERIE 	  "
	cQuery += "				AND DUD.D_E_L_E_T_ = ' ' "
	If cSerTms <> '1' //Coleta
		//DUD busca DTC
		cQuery += " 		INNER JOIN " + RetSqlName("DTC") + " DTC "
		cQuery += " 			ON DUD.DUD_FILDOC  = DTC.DTC_FILDOC   "
		cQuery += "				AND DUD.DUD_DOC    = DTC.DTC_DOC 	  "
		cQuery += "				AND DUD.DUD_SERIE  = DTC.DTC_SERIE 	  "
		cQuery += "				AND DTC.D_E_L_E_T_ = ' ' "
		//DTC busca Dt5
		cQuery += " 		INNER JOIN " + RetSqlName("DT5") + " DT5 "
		cQuery += " 			ON DTC.DTC_FILCFS  = DT5.DT5_FILDOC   "
		cQuery += "				AND DTC.DTC_NUMSOL = DT5.DT5_DOC 	  "
		cQuery += "				AND DT5.DT5_SERIE  = 'COL'			 	  "
		cQuery += "				AND DT5.D_E_L_E_T_ = ' '"

		//
		cQuery += " 		INNER JOIN " + RetSqlName("DF1") + " DF1 "
		cQuery += " 			ON DT5.DT5_FILDOC  = DF1.DF1_FILDOC   "
		cQuery += "				AND DT5.DT5_DOC    = DF1.DF1_DOC      "
		cQuery += "				AND DF1.DF1_SERIE  = 'COL'	  "
		cQuery += "				AND DF1.D_E_L_E_T_ = ' ' "

	Else
		cQuery += " 		INNER JOIN " + RetSqlName("DT5") + " DT5 "
		cQuery += " 			ON DUD.DUD_FILDOC  = DT5.DT5_FILDOC   "
		cQuery += "				AND DUD.DUD_DOC    = DT5.DT5_DOC 	  "
		cQuery += "				AND DUD.DUD_SERIE  = DT5.DT5_SERIE 	  "
		cQuery += "				AND DT5.D_E_L_E_T_ = ' ' "
		cQuery += " 		INNER JOIN " + RetSqlName("DF1") + " DF1 "
		cQuery += " 			ON DT5.DT5_FILDOC  = DF1.DF1_FILDOC   "
		cQuery += "				AND DT5.DT5_DOC    = DF1.DF1_DOC      "
		cQuery += "				AND DF1.DF1_SERIE  = 'COL'	  "
		cQuery += "				AND DF1.D_E_L_E_T_ = ' ' "
	EndIf
	If nAcao == 1
		cQuery += " 	WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += " 		AND DUD.DUD_FILORI = '" + cFilOri       + "' "
		cQuery += " 		AND DUD.DUD_VIAGEM = '" + cViagem       + "' "
		cQuery += " 		AND DUD.D_E_L_E_T_ = ' ' "
	ElseIf nAcao == 2
		cQuery += " 	WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
		cQuery += " 		AND DF1.DF1_NUMAGE = '" + aTotAge[1,1]  + "' "
		cQuery += " 		AND DF1.DF1_ITEAGE = '" + aTotAge[1,2]  + "' "
		cQuery += " 		AND DF1.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	If nAcao == 1
		If (cAliasQry)->(!Eof())
			While(cAliasQry)->(!Eof()) .And. !lAchou
				//Pesquisa se os agendamentos da viagem estão marcados.
				If Ascan(aTotAge, { |x| AllTrim(x[1])+AllTrim(x[2]) == (cAliasQry)->(DF1_NUMAGE+DF1_ITEAGE)  } ) > 0
					lAchou:= .T.
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo
			If !lAchou
				lAchou := MsgYesNo(STR0080 + CHR(13) + CHR(10) + STR0081,STR0082) //"A viagem selecionada não será apresentanda no Painel já que seu agendamento não foi marcado."//"Deseja Continuar?"//"Painel Agendamento"
			EndIf
		Else
			lAchou := MsgYesNo (STR0083 + CHR(13) + CHR(10) +STR0081,STR0082)//"A viagem selecionada não possui agendamento."//"Desejar confirmar?"//"Painel Agendamento"
		EndIf


	ElseIf nAcao == 2 .And. Len(aTotAge) == 1
		If !Empty((cAliasQry)->(DUD_FILORI)) .And. !Empty((cAliasQry)->(DUD_VIAGEM))
			cFilOri := 	(cAliasQry)->(DUD_FILORI)
			cViagem := 	(cAliasQry)->(DUD_VIAGEM)
			lAchou := .T.
		EndIf
	EndIf
	(cAliasQry)->(DbCloseArea())
ElseIf nAcao == 1 .Or. !lAchou
	lAchou := MsgYesNo(STR0084 + CHR(13) + CHR(10) + STR0085 + chr(13) + chr(10) + STR0081,STR0082) //"Não existem agendamentos marcados no Painel."//"As ocorrencias apontadas não serão apresentadas no Painel."//"Deseja Confirmar?"//Painel Agendamento
EndIf

RestArea(aArea)

Return (lAchou)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA360IGFE  ³ Autor ³ Katia               ³ Data ³ 17/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica Integracao com o SIGAGFE                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA360IGFE()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA360                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA360IGFE(lEstorno)

Local lRet     := .T.
Local lIntGFE  := SuperGetMv("MV_INTGFE",.F.,.F.)
Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")
Local lTMSGFE  := SuperGetMv("MV_TMSGFE",,.F.)
Local aArea    := GetArea()
Local cCDTPDC  := ""
Local cEmisDc  := ""
Local cAliasDTC:= ""
Local cTPDCTMS := SuperGetMV("MV_TPDCTMS",,"")
Local lNumProp := Iif(FindFunction("GFEEMITMP"),GFEEMITMP(),.F.)      //Parametro Numeracao
Local lCmpDFV  := DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0

Default lEstorno:= .F.

//Integração Protheus com SIGAGFE
If lTMSGFE .And. lIntGFE == .T. .And. cIntGFE2 $ "1"
	If lEstorno
		cAliasDTC:= GetNextAlias()
	    cQuery := " SELECT DTC_FILIAL, DTC_FILDOC, DTC_DOC, DTC_SERIE, DTC_NUMNFC, DTC_SERNFC, DTC_CLIREM, DTC_LOJREM "
		cQuery += "       FROM " + RetSqlName("DTC") + " DTC "
		cQuery += " WHERE DTC.DTC_FILIAL = '" + xFilial('DTC') + "' "
		cQuery += "  AND DTC.DTC_FILDOC   = '" + DFV->DFV_FILDOC + "' "
		cQuery += "  AND DTC.DTC_DOC      = '" + DFV->DFV_DOC    + "' "
		cQuery += "  AND DTC.DTC_SERIE    = '" + DFV->DFV_SERIE  + "' "
		cQuery += "  AND DTC.D_E_L_E_T_   = ' ' "
		cQuery += " UNION "
		cQuery += " SELECT DY4_FILIAL AS DTC_FILIAL, DY4_FILDOC AS DTC_FILDOC, DY4_DOC AS DTC_DOC, DY4_SERIE AS DTC_SERIE, DY4_NUMNFC AS DTC_NUMNFC, "
		cQuery += " DY4_SERNFC AS DTC_SERNFC, DY4_CLIREM AS DTC_CLIREM, DY4_LOJREM AS DTC_LOJREM "
		cQuery += "       FROM " + RetSqlName("DY4") + " DY4 "
		cQuery += " WHERE DY4.DY4_FILIAL = '" + xFilial('DY4') + "' "
		cQuery += "  AND DY4.DY4_FILDOC   = '" + DFV->DFV_FILDOC + "' "
		cQuery += "  AND DY4.DY4_DOC      = '" + DFV->DFV_DOC + "' "
		cQuery += "  AND DY4.DY4_SERIE    = '" + DFV->DFV_SERIE + "' "
		cQuery += "  AND DY4.D_E_L_E_T_   = ' ' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTC)
		While (cAliasDTC)->(!Eof())

			cCDTPDC := Padr(cTPDCTMS,Len(GW1->GW1_CDTPDC))

			If lNumProp
				cEmisDc:= GFEM011COD((cAliasDTC)->DTC_CLIREM,(cAliasDTC)->DTC_LOJREM,1,,)
			Else
				cEmisDc:= Posicione("SA1",1,xFilial("SA1")+(cAliasDTC)->DTC_CLIREM+(cAliasDTC)->DTC_LOJREM,"A1_CGC")
			EndIf

			//---- exclui o GFE
			lRet:= TmsExcGFE(,,cCDTPDC,cEmisDc,(cAliasDTC)->DTC_SERNFC,(cAliasDTC)->DTC_NUMNFC,(cAliasDTC)->DTC_FILDOC,(cAliasDTC)->DTC_DOC,(cAliasDTC)->DTC_SERIE, ;
			Iif(lCmpDFV, DFV->DFV_FILORI,'' ), DFV->DFV_NUMRED )

			If lRet
				RecLock('DFV', .F.)
				DFV->DFV_CHVEXT := ""
				MsUnLock()
			Else
				Exit
			EndIf

			(cAliasDTC)->(DbSkip())
		EndDo
		(cAliasDTC)->(DbCloseArea())

	EndIf
EndIf
RestArea(aArea)
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA360IDFV  ³ Autor ³ Katia               ³ Data ³ 21/02/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica status do documento de redespacho integrados no   ³±±
±±³          ³ SIGAGFE                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA360IDFV()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA360IDFV(cFilDoc, cDoc, cSerie, lChvExt, cFilOri, cViagem)

Local cQuery   := ""
Local cAliasQry:= GetNextAlias()
Local lRet     := .F.
Local aArea    := GetArea()

Default cFilDoc    := ""
Default cDoc       := ""
Default cSerie     := ""
Default lChvExt    := .F.   //Indica se verifica na DFV registro com integração - Chave Externa
Default cFilOri    := ""
Default cViagem    := ""

cQuery := " SELECT 1 QTD "
cQuery += " FROM " + RetSqlName("DFV") + " DFV "
cQuery += " WHERE "
cQuery += " 	 DFV.DFV_FILIAL 	='" + xFilial("DFV") +	"' "
cQuery += " AND DFV.DFV_FILDOC	='" + cFilDoc + "'"
cQuery += " AND DFV.DFV_DOC 	 	='" + cDoc + "'"
cQuery += " AND DFV.DFV_SERIE	 	='" + cSerie + "'"
If lChvExt
	cQuery += " AND DFV.DFV_CHVEXT 	<> ' ' "
	cQuery += " AND DFV.DFV_STATUS 	<>'" + StrZero( 9, Len( DFV->DFV_STATUS ) ) + "'"
EndIf
cQuery += " AND DFV.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
If (cAliasQry)->(!Eof()) .And. (cAliasQry)->QTD==1
	lRet:= .T.
EndIf
(cAliasQry)->( dbCloseArea() )

RestArea(aArea)
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TM360DYZ    ³ Autor ³ Katia               ³ Data ³ 21/02/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava tabela para a conciliacao de Sobras e Faltas     o   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TM360DYZ()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM360DYZ(cFilPnd,cNumPnd,cFilDoc,cDoc,cSerie,cNumNfc,cSerNfc,nQtdNfc,cTipoPnd)

Local aArea     := GetArea()
Local lRet      := .T.

Default cFilDoc := ''
Default cDoc    := ''
Default cSerie  := ''
Default cNumNfc := ''
Default cSerNfc := ''
Default cTipoPnd:= ''
//Default nQtdNfc := 0  //Quantidade da NF avariada


cFilDoc:= Iif(Empty(cFilDoc),Space(Len(DUA->DUA_FILDOC)),cFilDoc)
cDoc   := Iif(Empty(cDoc)   ,Space(Len(DUA->DUA_DOC))   ,cDoc)
cSerie := Iif(Empty(cSerie) ,Space(Len(DUA->DUA_SERIE)) ,cSerie)
cNumNFC:= Iif(Empty(cNumNFC),Space(Len(DV4->DV4_NUMNFC)),cNumNFC)
cSerNFC:= Iif(Empty(cSerNFC),Space(Len(DV4->DV4_SERNFC)),cSerNFC)


	DYZ->(DbSetOrder(1))
	If DYZ->(DbSeek(xFilial("DYZ")+cFilPnd+cNumPnd+Iif(Empty(cFilDoc),Space(Len(DUA->DUA_FILDOC)),cFilDoc)+cDoc+cSerie+cNumNFC+cSerNFC))
		RecLock('DYZ', .F.)
	Else
		RecLock('DYZ', .T.)
		DYZ->DYZ_FILIAL:= xFilial("DYZ")
		DYZ->DYZ_FILPND:= DUU->DUU_FILPND
		DYZ->DYZ_NUMPND:= DUU->DUU_NUMPND
		DYZ->DYZ_NUMNFC:= cNumNFC
		DYZ->DYZ_SERNFC:= cSerNFC
		DYZ->DYZ_DATPND:= DUU->DUU_DATPND
		DYZ->DYZ_HORPND:= DUU->DUU_HORPND
		DYZ->DYZ_TIPPND:= cTipoPnd
		DYZ->DYZ_FILDOC:= DUU->DUU_FILDOC
		DYZ->DYZ_DOC   := DUU->DUU_DOC
		DYZ->DYZ_SERIE := DUU->DUU_SERIE
		DYZ->DYZ_FILORI:= DUU->DUU_FILORI
		DYZ->DYZ_VIAGEM:= DUU->DUU_VIAGEM
		DYZ->DYZ_CODCLI:= DUU->DUU_CODCLI
		DYZ->DYZ_LOJCLI:= DUU->DUU_LOJCLI
		DYZ->DYZ_CODOCO:= DUU->DUU_CODOCO
		DYZ->DYZ_QTDOCO:= Iif(Empty(cNumNFC),DUU->DUU_QTDOCO,nQtdNfc)
		DYZ->DYZ_QTDVOL:= Iif(Empty(cNumNFC),DUU->DUU_QTDOCO,nQtdNfc)
		DYZ->DYZ_STACON:= StrZero(1,Len(DYZ->DYZ_STACON))

		DTC->(DbSetOrder(7))
		If DTC->(DbSeek(xFilial("DTC")+cDoc+cSerie+cFilDoc+cNumNFC+cSerNFC))
			DYZ->DYZ_CLIREM:= DTC->DTC_CLIREM
			DYZ->DYZ_LOJREM:= DTC->DTC_LOJREM
			DYZ->DYZ_CLIDES:= DTC->DTC_CLIDES
			DYZ->DYZ_LOJDES:= DTC->DTC_LOJDES
		EndIf
	EndIf
	DYZ->(MsUnlock())

RestArea(aArea)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TM360CodBr
Tela com as informações da ocorrência.

@class
@author	Alexandre Yukio Arume
@version	1.0
@since		24/10/2014
@return
@Param
@sample

/*/
//-------------------------------------------------------------------
Static Function TM360CodBr()

	Local aColsBkp	:= aClone(aCols)
	Local cCodBar		:= Space(Len(DT6->DT6_CHVCTE))

	Local oGetDados
	Local dGetDat	 	:= dDataBase
	Local cGetHor 	:= Strtran(Left(Time(),5),":","")
	Local oCombo		:= Nil
	Local cCombo		:= ""
	Local aCombo 		:= {}
	Local nOpc			:= 0
	Local lRet 			:= .T.
	Local oDlgOco
	Local bSavKeyF5   	:= SetKey(VK_F5,Nil)

	Private aColsOco 	:= {}
	Private cGetOco 	:= Space(Len(DT2->DT2_CODOCO))
	Private cGetDes 	:= Space(Len(DT2->DT2_DESCRI))
	Private oCodBar
	Private oBtn1

	// Valida Linhas Já Digitas
	If !Empty(GdFieldGet('DUA_CODOCO')) .And. !TMSA360LinOk()
		Return()
	Endif

	aAdd(aCombo, STR0089 ) // "1=Por Documento"
	aAdd(aCombo, STR0090 ) // "2=Por Viagem"

	DEFINE MSDIALOG oDlgOco FROM 50, 80 TO 590, 950 TITLE STR0091 Of oMainWnd PIXEL //"Ocorrência"

		@ 033, 005 SAY STR0092 PIXEL //"Categoria"
		@ 033, 040 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 060, 009 OF oDlgOco PIXEL

		@ 047, 005 SAY AllTrim(FWX3Titulo("DUA_CODOCO")) PIXEL
		@ 045, 040 MSGET cGetOco SIZE 010, 009 PICTURE PesqPict("DUA", "DUA_CODOCO") F3 "DT2" VALID TMSA360Oco(oDlgOco,cCombo) OF oDlgOco PIXEL HASBUTTON
		@ 045, 075 MSGET cGetDes SIZE 165, 009 PICTURE PesqPict("DUA", "DUA_DESOCO") OF oDlgOco WHEN .F. PIXEL

		@ 059, 005 SAY AllTrim(FWX3Titulo("DUA_DATOCO")) PIXEL
		@ 057, 040 MSGET dGetDat SIZE 050,009 PICTURE PesqPict("DUA", "DUA_DATOCO") OF oDlgOco VALID TMSA360Dat(dGetDat) PIXEL HASBUTTON

		@ 059, 100 SAY AllTrim(FWX3Titulo("DUA_HOROCO")) PIXEL
		@ 057, 135 MSGET cGetHor SIZE 030, 009 PICTURE PesqPict("DUA", "DUA_HOROCO") OF oDlgOco VALID AtVldHora(cGetHor) PIXEL

		@ 071, 005 SAY STR0093 PIXEL //"Cod.Barras"
		@ 069, 040 MSGET oCodBar VAR cCodBar SIZE 200, 009 OF oDlgOco PIXEL PICTURE "@!" VALID CodBrValid(cCombo, @cCodBar, cGetOco, cGetDes, dGetDat, cGetHor, oGetDados, aColsOco)
		oBtn1 := TButton():New( -150, -150, "FAKE", oDlgOco,{|| oDlgOco:End()	},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtn1:bGotFocus := {|| oCodBar:SetFocus() }

		oGetDados := MsNewGetDados():New(083, 005, 250, 430, GD_INSERT, , , , , , , , , ,oDlgOco ,aHeader ,aColsOco, )

	ACTIVATE MSDIALOG oDlgOco ON INIT EnchoiceBar(oDlgOco, {|| nOpc := 1, oDlgOco:End()}, {||oDlgOco:End()})

	bSavKeyF5:=	SetKey(VK_F5,{|| TM360CodBr()})

	If nOpc == 1
		TM360Conf(oDlgOco, aColsBkp, aColsOco)
	Else
		aCols := aClone(aColsBkp)
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} CodBrValid
Função que pesquisa e preenche as informações da ocorrencia.

@class
@author	Alexandre Yukio Arume
@version	1.0
@since		24/10/2014
@return
@Param		cCombo: Categoria selecionada
@Param		cCodBar: Codigo de barra
@Param		cGetOco: Codigo da ocorrencia
@Param		cGetDes: Descricao da ocorrencia
@Param		dGetDat: Data da ocorrencia
@Param		cGetHor: Hora da ocorrencia
@Param		oGetDados: Objeto da janela
@Param		aColsOco: Array com as informações das ocorrencias
@sample

/*/
//-------------------------------------------------------------------
Static Function CodBrValid(cCombo, cCodBar, cGetOco, cGetDes, dGetDat, cGetHor, oGetDados, aColsOco)

Local lRet			:= .T.
Local nI			:= 1
Local nJ			:= 0
Local cQuery		:= ""
Local cAliasOco		:= GetNextAlias()
Local cAliasDoc		:= GetNextAlias()
Local lDoc			:= .T.
Local lOcorbip		:= .T.
Local nUltOco		:= 0
Local cChDocant		:=''
Local cChDocatu		:=''
Local lOcorgrid		:= .T.
Local cSerTms		:= ""

// Por Documento
If cCombo == "1"

	dbSelectArea("DT6")

	
	DT6->(dbSetOrder(18)) //DT6_FILIAL+DT6_CHVCTE
	If DT6->(dbSeek(xFilial("DT6") + cCodBar)) .And. !Empty(cCodBar)

		If !Empty(M->DUA_VIAGEM)

			cQuery := "SELECT DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE, DT6.DT6_SERTMS "
			cQuery += "FROM "+ RetSqlName("DUD") + " DUD "
			cQuery += "INNER JOIN " + RetSqlName("DT6") + " DT6 "
			cQuery += "ON  DT6.DT6_FILIAL = '"+FwxFilial('DT6')+"' " 
			cQuery += "AND DUD.DUD_FILDOC  = DT6.DT6_FILDOC   "
			cQuery += "AND DUD.DUD_DOC    = DT6.DT6_DOC 	  "
			cQuery += "AND DUD.DUD_SERIE  = DT6.DT6_SERIE 	  "
			cQuery += "AND DUD.D_E_L_E_T_ = ' ' "
			cQuery += "INNER JOIN " + RetSqlName("DTQ") + " DTQ "
			cQuery += "ON DTQ.DTQ_FILIAL = '"+FwxFilial('DTQ')+"' "
			cQuery += "AND DTQ.DTQ_FILORI  = DUD.DUD_FILORI  "   
			cQuery += "AND DTQ.DTQ_VIAGEM = DUD.DUD_VIAGEM  "
			cQuery += "AND DTQ.D_E_L_E_T_ = ' ' "
			cQuery += "WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
			cQuery += "AND DUD.D_E_L_E_T_ = ' ' "
			cQuery += "AND DUD.DUD_VIAGEM = '" + M->DUA_VIAGEM + "' "
			cQuery += "AND DT6.DT6_CHVCTE = '" + cCodBar + "' "

			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasDoc, .F., .T. )

			(cAliasDoc)->(DbGoTop())

			If Empty((cAliasDoc)->DT6_DOC)
				lDoc := .F.
			Endif

		Endif
		If lDoc
			cSerTms := UltSerTms( DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE )
			//documentos no grid de ocorrencia
			If Ascan(aCols,{ |x| x[DUA->(GdFieldPos('DUA_FILDOC'))]+x[DUA->(GdFieldPos('DUA_DOC'))]+x[DUA->(GdFieldPos('DUA_SERIE'))] == DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE}) > 0
				//If que verifica se o documento ja existe no grid de ocorrencia, se existir nao deixa duplicar o doc de mesma ocorrencia
				//somente ocorrencia informativa que permite duplicar o documento.
				//caso o doc esteja deletado no grid de ocorrencia, sera desconsiderado tambem.
				For nUltOco := 1 to Len(aCols)
					If aCols[nUltOco][DUA->(GdFieldPos('DUA_FILDOC'))]+aCols[nUltOco][DUA->(GdFieldPos('DUA_DOC'))]+aCols[nUltOco][DUA->(GdFieldPos('DUA_SERIE'))] == DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE
						If aCols[nUltOco][Len(aHeader)+1] == .F. .And. Posicione('DT2',1,xFilial('DT2') + aCols[nUltOco][DUA->(GdFieldPos('DUA_CODOCO'))],'DT2_TIPOCO') != StrZero( 5, Len( DT2->DT2_TIPOCO ) )
							cChDocant:=aCols[nUltOco][DUA->(GdFieldPos('DUA_FILDOC'))]+aCols[nUltOco][DUA->(GdFieldPos('DUA_DOC'))]+aCols[nUltOco][DUA->(GdFieldPos('DUA_SERIE'))]+DT2->DT2_TIPOCO
						Endif
						If Posicione('DT2',1,xFilial('DT2') + cGetOco,'DT2_TIPOCO') != StrZero( 5, Len( DT2->DT2_TIPOCO ) )
							cChDocatu:=aCols[nUltOco][DUA->(GdFieldPos('DUA_FILDOC'))]+aCols[nUltOco][DUA->(GdFieldPos('DUA_DOC'))]+aCols[nUltOco][DUA->(GdFieldPos('DUA_SERIE'))]+DT2->DT2_TIPOCO
						Endif
					Endif
				Next nUltOco
				If cChDocant == cChDocatu
					lOcorgrid := .F.
				Endif
			Endif
			//documentos na tela de bipagem
			If Ascan(aColsOco,{ |x| x[DUA->(GdFieldPos('DUA_FILDOC'))]+x[DUA->(GdFieldPos('DUA_DOC'))]+x[DUA->(GdFieldPos('DUA_SERIE'))] == DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE}) > 0
				//verifica se o mesmo documento ja foi bipado, se foi, verifica se o tipo de ocorrencia é diferente de informativa e nao
				//permite incluir o mesmo documento com o mesmo tipo de ocorrencia
				For nUltOco := 1 to Len(aColsOco)
					If aColsOco[nUltOco][DUA->(GdFieldPos('DUA_FILDOC'))]+aColsOco[nUltOco][DUA->(GdFieldPos('DUA_DOC'))]+aColsOco[nUltOco][DUA->(GdFieldPos('DUA_SERIE'))] == DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE
						If Posicione('DT2',1,xFilial('DT2') + aColsOco[nUltOco][DUA->(GdFieldPos('DUA_CODOCO'))],'DT2_TIPOCO') != StrZero( 5, Len( DT2->DT2_TIPOCO ) )
							cChDocant:=aColsOco[nUltOco][DUA->(GdFieldPos('DUA_FILDOC'))]+aColsOco[nUltOco][DUA->(GdFieldPos('DUA_DOC'))]+aColsOco[nUltOco][DUA->(GdFieldPos('DUA_SERIE'))]+DT2->DT2_TIPOCO
						Endif
						If Posicione('DT2',1,xFilial('DT2') + cGetOco,'DT2_TIPOCO') != StrZero( 5, Len( DT2->DT2_TIPOCO ) )
							cChDocatu:=aColsOco[nUltOco][DUA->(GdFieldPos('DUA_FILDOC'))]+aColsOco[nUltOco][DUA->(GdFieldPos('DUA_DOC'))]+aColsOco[nUltOco][DUA->(GdFieldPos('DUA_SERIE'))]+DT2->DT2_TIPOCO
						Endif
					Endif
				Next nUltOco
				If cChDocant == cChDocatu
					lOcorbip := .F.
				Endif
			Endif

			If (Ascan(aColsOco,{ |x| x[DUA->(GdFieldPos('DUA_FILDOC'))]+x[DUA->(GdFieldPos('DUA_DOC'))]+x[DUA->(GdFieldPos('DUA_SERIE'))] == DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE}) == 0;
				.Or. lOcorbip) .And. (Ascan(aCols,{ |x| x[DUA->(GdFieldPos('DUA_FILDOC'))]+x[DUA->(GdFieldPos('DUA_DOC'))]+x[DUA->(GdFieldPos('DUA_SERIE'))] == DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE}) == 0 .Or. lOcorgrid)

				dbSelectArea("DT2")
				DT2->(dbSetOrder(1)) //DT2_FILIAL+DT2_CODOC
				If DT2->(dbSeek(xFilial("DT2") + cGetOco))

					If !Empty(DT2->DT2_SERTMS) .And. DT2->DT2_SERTMS <> cSerTms
						Help(' ', 1, 'TMSA360C3') // Serviço de transporte da Ocorrência difere do Documento.
						lRet := .F.
					Else
					aAdd(aColsOco, Array(Len(aHeader)+1))
					For nI := 1 To Len(aHeader)
						aColsOco[Len(aColsOco),nI] := CriaVar(aHeader[nI,2])
					Next

					//-- Deleta Linha Do aCols Caso Esta Esteja Em Branco
					If Len(aCols) > 0
						If Empty(GdFieldGet('DUA_CODOCO',Len(aCols))) .And. !GdDeleted(Len(aCols))
							aDel( aCols , Len(aCols) )
							aSize( aCols , Len(aCols) - 1 )
						EndIf
					EndIf

					//-- Determina Sequencia
					If Len(aColsOco) == 1
						For nJ := Len(aCols) To 1 Step -1
							If !GdDeleted(nJ)
								nJ ++
								Exit
							EndIf
						Next nJ
						nJ := Iif(nJ == 0,1,nJ)
					Else
						nJ := Val(aColsOco[Len(aColsOco)-1][DUA->(GdFieldPos('DUA_SEQOCO'))]) + 1
					EndIf

					nI := Len(aColsOco)

					aColsOco[nI][DUA->(GdFieldPos('DUA_SEQOCO'))] := StrZero(nJ,Len(DUA->DUA_SEQOCO)) //--StrZero(Iif(Len(aCols)==1,nI,Len(aCols)+1),Len(DUA->DUA_SEQOCO))
					aColsOco[nI][DUA->(GdFieldPos('DUA_DATOCO'))] := Iif (Empty(dGetDat),dDataBase,dGetDat)
					aColsOco[nI][DUA->(GdFieldPos('DUA_HOROCO'))] := cGetHor
					aColsOco[nI][DUA->(GdFieldPos('DUA_CODOCO'))] := cGetOco
					aColsOco[nI][DUA->(GdFieldPos('DUA_DESOCO'))] := cGetDes
					aColsOco[nI][DUA->(GdFieldPos('DUA_FILDOC'))] := DT6->DT6_FILDOC
					aColsOco[nI][DUA->(GdFieldPos('DUA_DOC'   ))] := DT6->DT6_DOC
					aColsOco[nI][DUA->(GdFieldPos('DUA_SERIE' ))] := DT6->DT6_SERIE
					aColsOco[nI][DUA->(GdFieldPos('DUA_QTDVOL'))] := DT6->DT6_QTDVOL
					aColsOco[nI][DUA->(GdFieldPos('DUA_PESO  '))] := DT6->DT6_PESO
					aColsOco[nI][DUA->(GdFieldPos('DUA_VOLORI'))] := DT6->DT6_VOLORI
					aColsOco[nI][DUA->(GdFieldPos('DUA_QTDOCO'))] := DT6->DT6_QTDVOL
					aColsOco[nI][DUA->(GdFieldPos('DUA_PESOCO'))] := DT6->DT6_PESO
					aColsOco[nI][Len(aHeader)+1] := .F.

					oGetDados:aCols := aClone(aColsOco)

					oGetDados:oBrowse:Refresh()
					EndIf
				Endif
			Else
				Help(' ', 1, 'TMSA360B7') // Documento informado anteriormente.
			Endif
		Else
			Help(' ', 1, 'TMSA360C2') // Documento não pertence a viagem.
		Endif

	ElseIf !Empty(cCodbar)
		Help(' ', 1, 'TMSA360B8') //Chave de Documento não localizado.
	EndIf

// Por Viagem
Else
	cQuery := "SELECT DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE, DT6.DT6_QTDVOL, DT6.DT6_PESO, DT6.DT6_VOLORI "
	cQuery += "FROM " + RetSqlName("DTX") + " DTX "
	cQuery += "INNER JOIN " + RetSqlName("DTA") + " DTA "
	cQuery += "ON DTX.DTX_FILIAL = '" + xFilial("DTX") + "' "
	cQuery += "AND DTX.D_E_L_E_T_ = ' ' "
	cQuery += "AND DTX.DTX_VIAGEM = DTA.DTA_VIAGEM "
	cQuery += "AND DTX.DTX_FILORI = DTA.DTA_FILORI "
	cQuery += "INNER JOIN " + RetSqlName("DT6") + " DT6 "
	cQuery += "ON DT6.DT6_FILIAL = '"+FwxFilial('DT6')+"' "
	cQuery += "AND DTA.DTA_FILDOC  = DT6.DT6_FILDOC   "
	cQuery += "AND DTA.DTA_DOC    = DT6.DT6_DOC 	  "
	cQuery += "AND DTA.DTA_SERIE  = DT6.DT6_SERIE 	  "
	cQuery += "AND DTA.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE DTA.DTA_FILIAL = '" + xFilial("DTA") + "' "
	cQuery += "AND DTA.D_E_L_E_T_ = ' ' "
	cQuery += "AND DTX.DTX_FILORI = '" + M->DUA_FILORI  + "' "
	cQuery += "AND DTX.DTX_VIAGEM = '" + M->DUA_VIAGEM  + "' "
	cQuery += "AND DTX.DTX_CHVMDF = '" + cCodBar + "' "

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasOco, .F., .T. )

	(cAliasOco)->(DbGoTop())

	If (cAliasOco)->(!Eof())

		If Ascan(aColsOco,{ |x| x[DUA->(GdFieldPos('DUA_FILDOC'))]+x[DUA->(GdFieldPos('DUA_DOC'))]+x[DUA->(GdFieldPos('DUA_SERIE'))] == (cAliasOco)->DT6_FILDOC+(cAliasOco)->DT6_DOC+(cAliasOco)->DT6_SERIE}) == 0;
			.And. Ascan(aCols,{ |x| x[DUA->(GdFieldPos('DUA_FILDOC'))]+x[DUA->(GdFieldPos('DUA_DOC'))]+x[DUA->(GdFieldPos('DUA_SERIE'))] == (cAliasOco)->DT6_FILDOC+(cAliasOco)->DT6_DOC+(cAliasOco)->DT6_SERIE}) == 0

			dbSelectArea("DT2")
			DT2->(dbSetOrder(1)) //DT2_FILIAL+DT2_CODOC
			If DT2->(dbSeek(xFilial("DT2") + cGetOco)) .And. (Empty(DT2->DT2_SERTMS) .Or. DT2->DT2_SERTMS == DTQ->DTQ_SERTMS)

		    	While !(cAliasOco)->(Eof())

					aAdd(aColsOco, Array(Len(aHeader)+1))
				
					For nI := 1 To Len(aHeader)
						aColsOco[Len(aColsOco),nI] := CriaVar(aHeader[nI,2])
					Next

					nI := Len(aColsOco) 

					aColsOco[nI][DUA->(GdFieldPos('DUA_SEQOCO'))] := StrZero(nI, Len(DUA->DUA_SEQOCO))
					aColsOco[nI][DUA->(GdFieldPos('DUA_DATOCO'))] := Iif (Empty(dGetDat),dDataBase,dGetDat)
					aColsOco[nI][DUA->(GdFieldPos('DUA_HOROCO'))] := cGetHor
					aColsOco[nI][DUA->(GdFieldPos('DUA_CODOCO'))] := cGetOco
					aColsOco[nI][DUA->(GdFieldPos('DUA_DESOCO'))] := cGetDes
					aColsOco[nI][DUA->(GdFieldPos('DUA_FILDOC'))] := (cAliasOco)->DT6_FILDOC
					aColsOco[nI][DUA->(GdFieldPos('DUA_DOC'   ))] := (cAliasOco)->DT6_DOC
					aColsOco[nI][DUA->(GdFieldPos('DUA_SERIE' ))] := (cAliasOco)->DT6_SERIE
					aColsOco[nI][DUA->(GdFieldPos('DUA_QTDVOL'))] := (cAliasOco)->DT6_QTDVOL
					aColsOco[nI][DUA->(GdFieldPos('DUA_PESO  '))] := (cAliasOco)->DT6_PESO
					aColsOco[nI][DUA->(GdFieldPos('DUA_VOLORI'))] := (cAliasOco)->DT6_VOLORI
					aColsOco[nI][DUA->(GdFieldPos('DUA_QTDOCO'))] := (cAliasOco)->DT6_QTDVOL
					aColsOco[nI][DUA->(GdFieldPos('DUA_PESOCO'))] := (cAliasOco)->DT6_PESO
					aColsOco[nI][Len(aHeader)+1] := .F.

					(cAliasOco)->(dbSkip())
				EndDo

			Else

				Help(' ', 1, 'TMSA360C4') // Serviço de transporte da Ocorrência difere do Serviço da Viagem.

			EndIf 

			//-- Deleta Linha Do aCols Caso Esta Esteja Em Branco
			If Len(aCols) > 0
				If Empty(GdFieldGet('DUA_CODOCO',Len(aCols))) .And. !GdDeleted(Len(aCols))
					aDel( aCols , Len(aCols) )
					aSize( aCols , Len(aCols) - 1 )
				EndIf
			EndIf

			oGetDados:aCols := aClone(aColsOco)

			oGetDados:oBrowse:Refresh()

		Else

			Help(' ', 1, 'TMSA360B7') // Documento informado anteriormente.

		EndIf

    ElseIf !Empty(cCodbar)

    	Help(' ', 1, 'TMSA360B8') //Chave de Documento não localizado.

	EndIf 

	    (cAliasOco)->(dbCloseArea())

EndIf

cCodBar:=space(tamsx3("DT6_CHVCTE")[1])	 //Limpa a chave do documento apos ser carregado no grid

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA360Oco
Função que valida a ocorrencia.

@class
@author	Alexandre Yukio Arume
@version	1.0
@since		24/10/2014
@return
@Param		oDlgOco: Objeto da janela
@sample

/*/
//-------------------------------------------------------------------
Static Function TMSA360Oco(oDlgOco,cCombo)

	Local lRet := .T.

	If AllTrim(&(ReadVar())) != ""

		DT2->(DbSetOrder(1))
		If DT2->(DbSeek(xFilial("DT2") + &(ReadVar())))
			If cCombo == "1" .And. DT2->DT2_CATOCO != "1"
				Help(' ', 1, 'TMSA360B9') //"Somente serão aceitas ocorrências por Documento..."
				lRet := .F.
			Elseif cCombo == "2" .And. DT2->DT2_CATOCO != "2"
				Help(' ', 1, 'TMSA360C0') //"Somente serão aceitas ocorrências por Viagem..."
				lRet := .F.
			Else
				cGetDes := Posicione("DT2", 1, xFilial("DT2") + &(ReadVar()), "DT2_DESCRI")
			EndIf

			If DT2->DT2_ATIVO != StrZero( 1, Len( DT2->DT2_ATIVO ) )
				Help(' ', 1, 'TMSA36007')  //-- Ocorrencia nao esta Ativa !
				lRet := .F.
			ElseIf !Empty(DT2->DT2_SERTMS) .AND. !Empty(M->DUA_FILORI) .And. !Empty(M->DUA_VIAGEM) .And. DT2->DT2_SERTMS != DTQ->DTQ_SERTMS  .And. DTQ->DTQ_SERADI != DT2->DT2_SERTMS
				Help(' ', 1, 'TMSA36008')  //-- Servico de Transporte da ocorrencia diferente do servico da Viagem !
				lRet := .F.
			EndIf
		Else
			cGetDes := ""
			Help(' ', 1, 'TMSA360C1')//"Ocorrência não localizada..."
			lRet := .F.
		EndIf

		oDlgOco:Refresh()
	Else
		Help(' ', 1, 'TMSA360C5') // Ocorrência em branco. Informe uma Ocorrência.
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TM360Conf
Função que junta todas as ocorrencias.

@class
@author	Alexandre Yukio Arume
@version	1.0
@since		24/10/2014
@return
@Param		oDlgOco: Objeto da janela
@Param		aColsBkp: Array com as ocorrencias anteriores
@Param		aColsOco: Array com as ocorrencias digitadas.
@sample

/*/
//-------------------------------------------------------------------
Static Function TM360Conf(oDlgOco, aColsBkp, aColsOco)

	Local lRet 		:= .T.
	Local nI		:= 1

	/*
	If Len(aColsBkp) == 1

		If !Empty(aColsBkp[nI][7]) .AND. !Empty(aColsBkp[nI][8])
			aCols := aClone(aColsBkp)
		Else
			aCols := {}
		EndIf

	Else
		aCols := aClone(aColsBkp)
	EndIf
	*/

	For nI := 1 To Len(aColsOco)

   		aAdd(aCols, aColsOco[nI])

	Next

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA360Dat
Função que valida a data informada pelo usuario.

@class
@author	Gianni
@version	1.0
@since		30/04/2014
@return
@Param		dGetDat: Data informada pelo usuario
as.
@sample

/*/
//-------------------------------------------------------------------
Static Function TMSA360Dat(dGetDat)

Local lRet 		:= .T.

If dGetDat > dDataBase
	lRet := .F.
	Help(' ', 1, 'TMSA360C6') // Data informada é maior que a database do sistema.
Endif

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA360DY4 ³ Autor ³ Ramon Prado             ³ Data ³13/03/15  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³Verifica se existe outra Reentrega DY4 para a(s)nota fiscal(is)±±
±±³em questao. 																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA360DY4(cFilDoc,cDoc,cSerie)
Local aArea	:= getArea()
Local lRet		:= .T.
Local lDY4		:= AliasIndic("DY4") .And. FindFunction('TmsPesqSix')
Local cAliasQry := GetNextAlias()
Local nRecDY4	:= 0

If lDY4
	cQuery := " SELECT DY4_FILDOC,DY4_DOC,DY4_SERIE,DY4_LOTNFC,DY4_NUMNFC,DY4_SERNFC,DY4_CODPRO,DY4_CLIREM,DY4_LOJREM"
	cQuery += " FROM " + RetSqlTab("DY4")
	cQuery += " WHERE DY4_FILIAL = '" + xFilial("DY4") + "'"
	cQuery += "   AND DY4_FILDOC = '" + cFilDoc + "'"
	cQuery += "   AND DY4_DOC    = '" + cDoc + "'"
	cQuery += "   AND DY4_SERIE    = '" +cSerie+ "'"
	cQuery += "   AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

	While (cAliasQry)->(!EOF())
		DbSelectArea("DY4")
		If TmsPesqSix('DY4'/*cIndice*/,'2'/*cOrdem*/)
			DbSelectArea("DY4")
			DY4->(DbSetOrder(2)) //Filial+Cod Nf+Serie Nf+Produto+Cliente Rem.+Loja Rem.
			If MsSeek(cSeek := xFilial("DY4")+(cAliasQry)->DY4_LOTNFC+(cAliasQry)->DY4_NUMNFC+(cAliasQry)->DY4_SERNFC+;
				(cAliasQry)->DY4_CODPRO+(cAliasQry)->DY4_CLIREM+(cAliasQry)->DY4_LOJREM)
				While DY4->(!EOF()) .AND. DY4->(DY4_FILIAL+DY4_LOTNFC+DY4_NUMNFC+DY4_SERNFC+DY4_CODPRO+DY4_CLIREM+DY4_LOJREM) == cSeek
					If DY4->DY4_FILDOC == cFilDoc .AND. DY4->DY4_DOC != cDoc .AND. DY4->DY4_SERIE == cSerie
						nRecDY4	:= DY4->(Recno())
					Endif
					DY4->(DbSkip())
				EndDo
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	If nRecDY4 != 0 //verifica se encontrou o registro
		DY4->(DbGoTo(nRecDY4))
		DbSelectArea("DTC")
		DbSetOrder(2) //Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto + Fil. Origem + Lote Dc.Cli
		If MsSeek(xFilial("DTC")+DY4->(DY4_NUMNFC+DY4_SERNFC+DY4_CLIREM+DY4_LOJREM+DY4_CODPRO+DY4_FILORI+DY4_LOTNFC) )
			lRet := .F.
		Endif
	Endif

EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA360DUD
Função que retorna o Servico de Transporte do Docto, quanto utiliza-se
uma Ocorrencia sem o Servico de Transporte

@class
@author	Katia
@version	1.0
@since		01/06/2015
@return
@Param		oDlgOco: Objeto da janela
@sample

/*/
//-------------------------------------------------------------------
Function TMSA360DUD(cFilDoc,cDoc,cSerie)

Local cRet 		:= ""
Local aAreaAnt	:= GetArea()
Local cAliasQryD:= ""
Local cQueryDUD := ""

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""

DT6->( DbSetOrder( 1 ) )
If DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ))
	cRet:= DT6->DT6_SERTMS

	If DT6->DT6_SERTMS == StrZero( 2, Len( DT6->DT6_SERTMS ) )  //Transferencia, verifica o ultimo registro valido do DUD
		cAliasQryD := GetNextAlias()

		cQueryDUD := ""
		cQueryDUD := " SELECT (MAX(R_E_C_N_O_)) R_E_C_N_O_"
		cQueryDUD += " FROM " + RetSqlTab("DUD")
		cQueryDUD += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
		cQueryDUD += "   AND DUD_FILDOC = '" + GdFieldGet("DUA_FILDOC",n) + "'"
		cQueryDUD += "   AND DUD_DOC    = '" + GdFieldGet("DUA_DOC",n) + "'"
		cQueryDUD += "   AND DUD_SERIE  = '" + GdFieldGet("DUA_SERIE",n) + "'"
		cQueryDUD += "   AND DUD_STATUS <> '" + StrZero( 9, Len( DUD->DUD_STATUS ) ) + "'"  //Cancelado
		cQueryDUD += "   AND DUD.D_E_L_E_T_ = ' ' "
		cQueryDUD := ChangeQuery(cQueryDUD)
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryDUD), cAliasQryD, .F., .T. )

		If (cAliasQryD)->R_E_C_N_O_ > 0
			DUD->(dbGoto((cAliasQryD)->R_E_C_N_O_))
			cRet:= DUD->DUD_SERTMS
		EndIf
		(cAliasQryD)->( DbCloseArea() )
	EndIf
EndIf

RestArea(aAreaAnt)
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A360AtuRee ³ Autor ³ Ramon Prado          ³ Data ³12/03/15  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza o campo DTC_DOCREE da(s) Nota(s) Fiscal(is)de Sim   ±±
±±³para Não e vice-versa do documento de reentrega ou Devolucao			  ±±
±±³O campo DTC_DOCREE indica se ha reentrega ou Devolução para a NF   	  ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A360AtuRee(cFilDoc, cDoc, cSerie,lEstorno)
Local cAliasQry := ""
Local cQuery	:= ""
Local aAreaDTC := DTC->(GetArea())

Default lEstorno := .T.

cAliasQry := GetNextAlias()

cQuery := " SELECT DTC_NUMNFC,DTC_SERNFC,DTC_CLIREM,DTC_LOJREM,DTC_CODPRO"
cQuery += "   FROM " + RetSqlName('DTC') + " DTC " + CRLF

cQuery += "    INNER JOIN " + RetSqlName('DY4') + " DY4 ON " + CRLF
cQuery += "    DTC.DTC_FILIAL = DY4.DY4_FILIAL " + CRLF
cQuery += "    AND DTC.DTC_FILORI = DY4.DY4_FILORI " + CRLF
cQuery += "    AND DTC.DTC_NUMNFC = DY4.DY4_NUMNFC " + CRLF
cQuery += "    AND DTC.DTC_SERNFC = DY4.DY4_SERNFC " + CRLF
cQuery += "    AND DTC.D_E_L_E_T_  = ' '" + CRLF

//-- DTC - Documento Cliente para Transporte
cQuery += "  WHERE DY4.DY4_FILIAL	= '" + xFilial('DY4') + "'" + CRLF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o tipo de Conhecimento for de Complemento, seleciona as       ³
//³ informacoes do CTR principal, pois o complemento nao tem DTC     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery += "    AND DY4.DY4_FILDOC   = '" + cFilDoc + "'" + CRLF
cQuery += "    AND DY4.DY4_DOC      = '" + cDoc    + "'" + CRLF
cQuery += "    AND DY4.DY4_SERIE    = '" + cSerie  + "'" + CRLF
cQuery += "    AND DTC.DTC_NFENTR   <> '1' "				 + CRLF

If lEstorno
	cQuery += "    AND DTC.DTC_DOCREE    = '1' " + CRLF
Else
	cQuery += "    AND DTC.DTC_DOCREE    = '2' " + CRLF
Endif

cQuery += "  AND DY4.D_E_L_E_T_ = ' '" + CRLF
cQuery += "  GROUP BY DTC.DTC_NUMNFC, DTC.DTC_SERNFC, DTC_CLIREM,DTC_LOJREM,DTC_CODPRO  " + CRLF

cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

While (cAliasQry)->(!EOF())
	DbSelectArea("DTC")
	DbSetOrder(2) //Filial+Num. NF+Serie NF+Cliente Rem.+Loja Rem.+Produto+Filial Origem+Lote NF
	If DbSeek(xFilial("DTC")+(cAliasQry)->DTC_NUMNFC+(cAliasQry)->DTC_SERNFC+(cAliasQry)->DTC_CLIREM+(cAliasQry)->DTC_LOJREM+(cAliasQry)->DTC_CODPRO )
		RecLock("DTC", .F.)
		If lEstorno
			DTC->DTC_DOCREE := '2'
		Else
			DTC->DTC_DOCREE := '1'
		Endif
		MsUnlock()
	EndIf
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

RestArea(aAreaDTC)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A360AtuNf ³ Autor ³ Ramon Prado          ³ Data ³16/07/15	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza Entrega de Notas Fiscais de Reentrega/Devolucao	  ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A360AtuNf(aDocEnc)
Local aArea		:= getArea()
Local aAreaDT6	:= {}
Local cFilDco		:= ""
Local cDocDco		:= ""
Local cSerDco		:= ""
Local nEntreg		:= 0
Local nI			:= 1
Local cQuery		:= ""
Local cAliasQry	:= GetNextAlias()

For nI:= 1 To Len(aDocEnc)

	DbSelectArea("DT6")
	DT6->( DbSetOrder(1) )
	If DT6->( DbSeek( xFilial("DT6") + aDocEnc[nI,1]+aDocEnc[nI,2]+aDocEnc[nI,3]))
		// Verifica se todas as notas do CTRC foram entregues
		nEntreg := TM360RTST(aDocEnc[nI,1],aDocEnc[nI,2],aDocEnc[nI,3])
		If nEntreg == 1 .AND. DT6->DT6_QTDVOL == 0
			Reclock("DT6",.F.)
			DT6->DT6_STATUS := StrZero(7,Len(DT6->DT6_STATUS)) //Entregue
			DT6->(MsUnLock())
		Elseif nEntreg == 2
			Reclock("DT6",.F.)
			DT6->DT6_STATUS := StrZero(8,Len(DT6->DT6_STATUS)) //Entrega Parcial
			DT6->(MsUnLock())
		Elseif nEntreg == 3
			Reclock("DT6",.F.)
			DT6->DT6_STATUS := PadR('A',len(DT6->DT6_STATUS))  //-- Retorno Total
			DT6->(MsUnLock())
		Endif
	Endif

	If !Empty(DT6->DT6_FILDCO) .AND. !Empty(DT6->DT6_DOCDCO) .AND. !Empty(DT6->DT6_SERDCO)
		cFilDco := DT6->DT6_FILDCO
		cDocDco := DT6->DT6_DOCDCO
		cSerDco := DT6->DT6_SERDCO
		// Verifica se todas as notas do CTRC foram entregues do docto original
		nEntreg := TM360RTST(cFilDco, cDocDco,cSerDco)
		aAreaDT6 := DT6->(getArea())
		DbSelectArea("DT6")
		DT6->( DbSetOrder(1) )
		If DT6->( DbSeek( xFilial("DT6") + cFilDco + cDocDco + cSerDco ) )
			If nEntreg == 1 .AND. DT6->DT6_QTDVOL == 0

				Reclock("DT6",.F.)
				DT6->DT6_STATUS := StrZero(7,Len(DT6->DT6_STATUS)) //entregue
				DT6->(MsUnLock())

				cQuery := " SELECT DT6_FILDOC,DT6_DOC, DT6_SERIE "
				cQuery += " 	FROM " + RetSqlName("DT6")
				cQuery += " 	WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
				cQuery += " 		AND DT6_FILDCO		= '" + cFilDco+	"' "
				cQuery += " 		AND DT6_DOCDCO		= '" + cDocDco +		"' "
				cQuery += " 		AND DT6_SERDCO		= '" +cSerDco+		"' "
				cQuery += " 		AND D_E_L_E_T_		= ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

				While (cAliasQry)->(!EOF())
					If DT6->( DbSeek( xFilial("DT6") + (cAliasQry)->DT6_FILDOC + (cAliasQry)->DT6_DOC + (cAliasQry)->DT6_SERIE ) )
						If DT6->DT6_STATUS <> StrZero(7,Len(DT6->DT6_STATUS)) //entregue
							Reclock("DT6",.F.)
							DT6->DT6_STATUS := StrZero(7,Len(DT6->DT6_STATUS)) //entregue
							DT6->(MsUnLock())
						Endif
					Endif
					(cAliasQry)->(DbSkip())
				EndDo

				(cAliasQry)->(DbCloseArea())

			Elseif nEntreg == 2
				Reclock("DT6",.F.)
				DT6->DT6_STATUS := StrZero(8,Len(DT6->DT6_STATUS)) //Entrega Parcial
				DT6->(MsUnLock())
			Endif
		EndIf
		RestArea(aAreaDT6)
	Endif
Next

RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} UltSerTms
Função que valida o ultimo Servico de Transporte do DUD
@author	Jefferson
@version	1.0
@since		02/10/2015
@sample

/*/
//-------------------------------------------------------------------

Static Function UltSerTms( cFilDoc, cDoc, cSerie)

Local aArea		:= GetArea()
Local cAliasQry	:= GetNextAlias()
Local cQuery		:= ""
Local cSerTms		:= ""

Default cFilDoc	:= ""
Default cDoc		:= ""
Default cSerie	:= ""

cAliasQry := GetNextAlias()

cQuery := " SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE, MAX(DUD.R_E_C_N_O_) DUD_RECNO
cQuery += " 	FROM " + RetSqlName("DUD") + " DUD "
cQuery += " 	WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += " 	AND DUD_FILDOC = '" + cFilDoc + "' "
cQuery += " 	AND DUD_DOC = '" + cDoc + "' "
cQuery += " 	AND DUD_SERIE = '" + cSerie + "' "
cQuery += " 	AND DUD.D_E_L_E_T_ = ' ' "
If !Empty(M->DUA_VIAGEM)
	cQuery += " 	AND DUD_FILORI = '" + M->DUA_FILORI +"' "
	cQuery += " 	AND DUD_VIAGEM = '" + M->DUA_VIAGEM +"' "
EndIf
cQuery += " 	GROUP BY DUD_FILDOC, DUD_DOC, DUD_SERIE "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

If (cAliasQry)->(!Eof())
	DUD->( DbGoto( (cAliasQry)->DUD_RECNO ) )
	cSerTms := DUD->DUD_SERTMS
EndIf

(cAliasQry)->(DbCloseArea())
RestArea(aArea)

Return(cSerTms)

//-------------------------------------------------------------------
/*/{Protheus.doc} TMS360KmDc
Função que retorna o KM dos Documentos
@author	Rafael Souza
@version	1.0
@since		11/12/2015
@sample    Esta função tem por objetivo retornar o KM dos documentos de
			Transporte, para apuração do calculo do Custo de Transportes
			por KM. Caso seja realizado o cadastro de distância do cliente
			será gatilhado automaticamente a KM entre a região de origem e
			a região de calculo.
/*/
//-------------------------------------------------------------------

Function TMS360KmDc(cFilDoc, cDoc, cSerie)

Local aArea := GetArea()
Local nKm := 0

Default cFilDoc	:= ""
Default cDoc 		:= ""
Default cSerie	:= ""

DT6->( DbSetOrder( 1 ) )
If DT6->( DbSeek( xFilial("DT6") + cFilDoc + cDoc + cSerie ))
	nKM := TMSDistRot(,.F.,DT6->DT6_CDRORI,DT6->DT6_CDRCAL,,DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,.F.)
EndIf

RestArea( aArea )
Return( nKM )

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tms360Rent - Gatilho Para Cálculo Da Rentabilidade No Apontamento De Ocorrências.
@owner  Eduardo Alberti
@author Eduardo Alberti
@since 29/Dez/2016
@param Params	cRecDes -> Define Se Calcula Valor "R" Receita ou "D" Despesa

@return Nil
/*/
//---------------------------------------------------------------------------------------------------
Function Tms360Rent(cRecDes)

	Local aArea     := GetArea()
	Local nVal      := 0
	Local aFrete    := {}
	Local cCodOco   := ""
	Local cFilDoc   := ""
	Local cDoc      := ""
	Local cSerie    := ""
	Local aMsgErr   := {}
	Local aTipVei   := {}
	Local aValInf   := {}
	Local aCompCalc := {}
	Local nPeso     := 0
	Local nPesoM3   := 0
    Local nMetro3   := 0
	Local nValMer   := 0
	Local nQtdUni   := 0
	Local nBasSeg   := 0

	Default cRecDes := "R" //-- Default "R" Receita

	//-- Verifica Se Existem Os Campos Para o Cálculo Da Rentabilidade
	If DUA->(ColumnPos("DUA_VLRRCT")) > 0 .And. DUA->(ColumnPos("DUA_VLRDSP")) > 0

		cCodOco := GdFieldGet("DUA_CODOCO",n)

		//-- Tabela Ocorrências
		DbSelectArea("DT2")
		DbSetOrder(1) //-- DT2_FILIAL+DT2_CODOCO
		If MsSeek(FWxFilial("DT2") + cCodOco , .f. )

			cFilDoc := GDFieldGet('DUA_FILDOC' ,n)
			cDoc    := GDFieldGet('DUA_DOC'    ,n)
			cSerie  := GDFieldGet('DUA_SERIE'  ,n)

			//-- Vetor De Tipo De Veiculo
			If !Empty( GDFieldGet('DUA_TIPVEI'  ,n))
				aAdd( aTipVei, {GDFieldGet('DUA_TIPVEI',n),1})
			EndIf

			//-- Vetor De Valor Informado
			If !Empty( GDFieldGet('DUA_VALINF'  ,n))
				aAdd( aValInf, { DT2->DT2_CDPASR ,GDFieldGet('DUA_VALINF',n),.f. })
			EndIf

			If cRecDes == "R" //-- Receita

				If ( DT2->DT2_TIPOCO == StrZero(16,Len(DT2->DT2_TIPOCO))  .Or. ;
					 DT2->DT2_TIPOCO == StrZero(18,Len(DT2->DT2_TIPOCO)))

					DbSelectArea("DT6")
					DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
					If MsSeek( FWxFilial("DT6") + cFilDoc + cDoc + cSerie , .f. )

						DbSelectArea("DTC")
						DbSetOrder(3) //-- DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
						MsSeek( FWxFilial("DTC") + cFilDoc + cDoc + cSerie , .f. )

						cCodPro := Iif( GetMV('MV_PRCPROD',,.T.) , DTC->DTC_CODPRO , Space(Len(SB1->B1_COD)) )
						cServ   := Iif( Empty(GDFieldGet('DUA_SERVIC',n)), DT6->DT6_SERVIC, GDFieldGet('DUA_SERVIC',n))
						nBasSeg := Iif( GDFieldGet('DUA_BASOCO',n) > 0, GDFieldGet('DUA_BASOCO',n) , GDFieldGet('DUA_BASSEG',n)) //-- 05
						nPesoM3 := Iif( GDFieldGet('DUA_PM3OCO',n) > 0, GDFieldGet('DUA_PM3OCO',n) , GDFieldGet('DUA_PESOM3',n)) //-- 02
    					nMetro3 := Iif( GDFieldGet('DUA_MT3OCO',n) > 0, GDFieldGet('DUA_MT3OCO',n) , GDFieldGet('DUA_METRO3',n)) //-- 03
						nValMer := Iif( GDFieldGet('DUA_VLROCO',n) > 0, GDFieldGet('DUA_VLROCO',n) , GDFieldGet('DUA_VALMER',n)) //-- 01
						nQtdUni := Iif( GDFieldGet('DUA_QTUOCO',n) > 0, GDFieldGet('DUA_QTUOCO',n) , GDFieldGet('DUA_QTDUNI',n)) //-- 04
						nPeso   := Iif( GDFieldGet('DUA_PESOCO',n) > 0, GDFieldGet('DUA_PESOCO',n) , GDFieldGet('DUA_PESO'  ,n)) //-- 06

						Aadd(aCompCalc, DT2->DT2_CDPASR)
						Aadd(aCompCalc, {})

					 	//-- *DUA_TIPVEI, *DUA_KMDOC, *DUA_VLROCO, *DUA_PM3OCO, *DUA_MT3OCO, *DUA_QTUOCO, DUA_BASOCO, *DUA_PESOCO, *DUA_VALINF e *DUA_SERVIC , (*DT2_CDPASR)
						aFrete := TmsCalFret(	DT6->DT6_TABFRE,;									//-- 01 * Tabela de Frete
												DT6->DT6_TIPTAB,;									//-- 02 * Tipo da Tabela
												"",;												//-- 03 * Seq. Tabela (DT6->DT6_SEQTAB)
												DT6->DT6_CDRORI,;									//-- 04 * Origem
												DT6->DT6_CDRDES,;									//-- 05 * Destino
												DT6->DT6_CLIDEV,;									//-- 06 * Cod. Cliente
												DT6->DT6_LOJDEV,;									//-- 07 * Loja Cliente
												cCodPro,;											//-- 08 * Produto
												cServ,;												//-- 09 * Servico
												DT6->DT6_SERTMS,;									//-- 10 * Serv. de Transp.
												DT6->DT6_TIPTRA,;									//-- 11 * Tipo Transp.
												DT6->DT6_NCONTR,;									//-- 12 * No. Contrato
												@aMsgErr,;											//-- 13 * Array Mensagens de Erro
												Nil,;												//-- 14 NF's por Conhecimento
												nValMer,;											//-- 15 * Valor da Mercadoria
												nPeso,;												//-- 16 * Peso Real do Docto.
												nPesoM3,;											//-- 17 *Peso Cubado do Docto.
												0,;													//-- 18 Peso Cobrado
												DT6->DT6_QTDVOL,;									//-- 19 * Qtde. de Volumes do Docto.
												0,;													//-- 20 Desconto
												nBasSeg,;											//-- 21 Seguro
												0,;													//-- 22 Metro Cubico
												1,;													//-- 23 Qtde. de Doctos
												Nil,;												//-- 24 No. de Diarias ( Semana )
												GDFieldGet('DUA_KMDOC',n),;							//-- 25 * Km percorridos
												Nil,;												//-- 26 Pernoites
												.T.,; 												//-- 27 Estabelece o valor minimo do componente
												.F.,;												//-- 28 Indica que o contrato e' de um cliente generico
												.F.,;												//-- 29 Ajuste automatico, envia msg se nao encontrar
												Nil,;												//-- 30 Qtde.de Entregas
												DT6->DT6_QTDUNI,;									//-- 31 * Quantidade de Unitizadores
												0,;													//-- 32 Valor do Frete do Despachante
												Nil,;												//-- 33 CTRC sem Impostos
												Nil,;												//-- 34 CTRC com Impostos
												aValInf,;											//-- 35 * Valor Informado
												aTipVei,;											//-- 36 * Tipo de Veiculo
												'',;												//-- 37 Documento de Transporte
												Nil,;												//-- 08 No. de Diarias ( Fim de Semana )
												nPeso,;												//-- 39
												nPesoM3,;											//-- 40
												nMetro3,;											//-- 41
												nValMer,;											//-- 42
												nQtdUni,;											//-- 43
												,;													//-- 44 No. de Dias Armazenagem
												,;													//-- 45 Faixa
												,;													//-- 46 Lote NFC
												,;													//-- 47 Peso Cubado
												,;													//-- 48 Praca Pedagio
												,;													//-- 49 Cliente Devedor
												,;													//-- 50 Loja Devedor
												,;													//-- 51 Moeda
												,;													//-- 52 Excedente TDA
												,;													//-- 53 Devedor TDA
												,;													//-- 55 Remetente TDA
												,;													//-- 56 Destinatario TDA
												,;													//-- 57 Qtde.de Coletas
												,;													//-- 58 Codigo Destinatario
												,;													//-- 59 Loja Destinatario
												,;													//-- 60 Sequencia Destinatario
												,;													//-- 61 Sequencia do Documento
												,;													//-- 62 Rateio? .T. ou .F.
												,;													//-- 63 Vetor com as bases do rateio
												aCompCalc,;							                //-- 64 * Vetor com a composição do cálculo
												DT6->DT6_CODNEG,;									//-- 65 * Codigo Negociacao
												{},;												//-- 66 Taxa Devedor
												{} )                                  				//-- 67 Frete Coleta

						If ValType(aFrete) == "A" .And. Len(aFrete) > 0
							nVal := aFrete[ Len(aFrete) , 2 ]
						EndIf
					EndIf
				EndIf

			ElseIf cRecDes == "D" //-- Despesa

				If ( DT2->DT2_TIPOCO == StrZero(17,Len(DT2->DT2_TIPOCO))  .Or. ;
					 DT2->DT2_TIPOCO == StrZero(18,Len(DT2->DT2_TIPOCO))) .And.;
					 Empty(DT2->DT2_CDTIPO)

					DbSelectArea("DT6")
					DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
					MsSeek( FWxFilial("DT6") + cFilDoc + cDoc + cSerie , .f. )

					DbSelectArea("DTC")
					DbSetOrder(3) //-- DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
					MsSeek( FWxFilial("DTC") + cFilDoc + cDoc + cSerie , .f. )

					cCodPro := Iif( GetMV('MV_PRCPROD',,.T.) , DTC->DTC_CODPRO , Space(Len(SB1->B1_COD)) )

					//-- Veículos da Viagem
					DbSelectArea("DTR")
					DTR->(DbSetOrder(1)) //-- DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_ITEM
					MsSeek( FWxFilial('DTR') + M->DUA_FILORI + M->DUA_VIAGEM, .F. )

					While DTR->(!Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == FWxFilial('DTR') + M->DUA_FILORI + M->DUA_VIAGEM

						//-- Cadastro De Veículos
						DbSelectArea("DA3")
						DbSetOrder(1) //-- DA3_FILIAL+DA3_COD
						MsSeek( FWxFilial('DA3') + DTR->DTR_CODVEI )

						If !Empty(GdFieldGet("DUA_TIPVEI",n))
							If DA3->DA3_TIPVEI == GdFieldGet("DUA_TIPVEI",n)
								cCodVei := DTR->DTR_CODVEI
								Exit
							EndIf
						Else
							cCodVei := DTR->DTR_CODVEI
							Exit
						EndIf

						DTR->(DbSkip())
					EndDo

					aFrete := TMSCalFrePag( M->DUA_FILORI,;
											M->DUA_VIAGEM,;
											cCodVei,;
											aMsgErr,;
											.t., )
											/*
											aFrete,;
											nTipVei,;
											cCodForn,;
											cLojForn,;
											aDiaHist,;
											cSerTms,;
											cTabFre,;
											cTipTab,;
											cTabCar,;
											lTabPag,;
											nMaxCus )
											*/

					If ValType(aFrete) == "A" .And. Len(aFrete) > 0
						nVal := aFrete[1,3]
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return(nVal)

/*/{Protheus.doc} TMSA360DDN
//TODO Essa função realiza a gravação dos Acréscimos/Decréscimos
@author caio.y
@since 24/01/2017
@version 1.0
@param lUpsert, Boolean, Inclusão/Alteração?
@param cFilOri, characters, Filial da Viagem
@param cViagem, characters, Número da Viagem
@param cFilOco, characters, Filial da Ocorrência
@param cNumOco, characters, Código da Ocorrência
@param cSeqOco, characters, Sequencia da Ocorrência
@param nValorDDN, numeric, Valor da Ocorrência
@param cCodAED, characters, Código da Ocorrência
@type function
/*/
Static Function TMSA360DDN( lUpsert , cFilOri , cViagem , cFilOco, cNumOco , cSeqOco, nValorDDN , cCodAed )
Local lRet			:= .F.
Local aArea		:= GetArea()
Local nOpc			:= 3
Local lGrvDDN		:= .F.

Default lUpsert		:= .T.
Default cFilOri		:= ""
Default cViagem		:= ""
Default cFilOco		:= xFilial("DT2")
Default cNumOco		:= ""
Default cSeqOco		:= StrZero(1,Len(DUA->DUA_SEQOCO))
Default nValorDDN	:= 0
Default cCodAed		:= ""

If lUpsert
	lRet	:= .F.

	If DT2->DT2_TIPOCO == StrZero(17, Len(DT2->DT2_TIPOCO))	.Or. DT2->DT2_TIPOCO == StrZero(18, Len(DT2->DT2_TIPOCO))
		If DT2->(ColumnPos('DT2_CODAED')) > 0 .And. !Empty(cCodAed)
			lRet		:= .T.
			lGrvDDN	:= .T.
			DDN->( dbSetOrder(3) ) //-- FILIAL+FILOCO+NUMOCO+SEQOCO
			If DDN->( MsSeek( xFilial("DDN") + cFilOco + cNumOco + cSeqOco ))
				nOpc	:= 4
			Else
				nOpc	:= 3
			EndIf
		EndIf
	EndIf

Else

	lRet	:= .T.
	If DT2->(ColumnPos('DT2_CODAED')) > 0

		DTY->(dbSetOrder(2))//-- FILIAL+FILORI+VIAGEM
		If DTY->( MsSeek( xFilial("DTY") + cFilOri + cViagem ))
			Help(' ', 1, 'TMSA360D6')//-- Não é possivel realizar o estorno da ocorrência, pois a mesma possui um acréscimo/decréscimo vinculado ao Contrato de Carreteiro.
			lRet	:= .F.
		Else
			DDN->( dbSetOrder(3) ) //-- FILIAL+FILOCO+NUMOCO+SEQOCO
			If DDN->( MsSeek( xFilial("DDN") + cFilOco + cNumOco + cSeqOco ))
				nOpc		:= 5
				lGrvDDN	:= .T.
			EndIf
		EndIf
	EndIf

EndIf

//-- Efetua a gravação do histórico de acrescimo/decrescimo
If lGrvDDN .And. lRet
	lRet	:= AF77GrvDDN( nOpc , cFilOri, cViagem , Nil , cCodAed ,  nValorDDN , cFilOco ,cNumOco , cSeqOco  )
EndIf

RestArea(aArea)
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} A360GrvThd()
Executa a ExecAuto do TMSA360 em Job

Uso: TMSA460

@sample
//TMSA360()

@author Paulo Henrique Corrêa Cardoso
@since 02/03/2017

@version 1.0
-----------------------------------------------------------/*/
Function A360GrvThd( aCab, aItens, aNfAva, nOpcAut)

    Local lSucesso  := .T.

	Private lMsErroAuto    := .F.

	MsExecAuto({|a,b,c,d|Tmsa360(a,b,c,d)},aCab,aItens,aNfAva,nOpcAut)
	If lMsErroAuto
        lSucesso := .F.
		MostraErro()
	EndIf

Return lSucesso

/*/-----------------------------------------------------------
{Protheus.doc} TMA360RDP()
Verifica o Documento de Redespacho

Uso: TMSA360

@sample
//TMSA360()

@author Katia
@since 29/09/2017

@version 1.0
-----------------------------------------------------------/*/
Function TMA360RDP(cFilRed,cNumRed,cStatus,lDif,nRecnoDFV)
Local nRet        := 0
Local cAliasDFV   := GetNextAlias()
Local cQuery      := ""
Local cSinal      := "="
Local lCmpDFV     := DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0

Default cFilRed   := ""
Default cNumRed   := ""
Default cStatus   := ""
Default lDif      := .F.
Default nRecnoDFV := 0

If lDif
	cSinal:= "<>"
EndIf

cQuery := "SELECT COUNT(*) QTDDOCBX FROM " + RetSqlName("DFV")
cQuery += " WHERE DFV_FILIAL = '" + xFilial("DFV") + "' AND"
//--- Tratamento do campo DFV_FILORI caso o campo nao esteja com conteudo por ter sido criado depois
If lCmpDFV
	cQuery += " (DFV_FILORI = '" + cFilRed + "' OR DFV_FILORI = ' ')  AND"
EndIf
cQuery += " DFV_NUMRED = '" + cNumRed + "' AND"
cQuery += " DFV_STATUS " + cSinal + " '" + cStatus + "'  AND"
If nRecnoDFV <> 0
	cQuery += " R_E_C_N_O_ <> " + Str(nRecnoDFV) + " AND"
EndIf
cQuery += " D_E_L_E_T_ = ' '"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDFV, .F., .T.)
If (cAliasDFV)->(!Eof())
	nRet := (cAliasDFV)->QTDDOCBX
EndIf
(cAliasDFV)->( dbCloseArea() )

Return nRet

/*/-----------------------------------------------------------
{Protheus.doc} TMA360IRD()
Identifica Documento de Redespacho conforme Status do Doctumento

Uso: TMSA360

@sample
//TMSA360()

@author Katia
@since 29/09/2017

@version 1.0
-----------------------------------------------------------/*/
Function TMA360IRD(cFilDoc,cDoc,cSerie,cStaDUD,lNumRed)
Local nDudRed  := 0
Local cQuery   := ""
Local cAliasQry:= ""
Local aArea    := GetArea()

Default cFilDoc:= ""
Default cDoc   := ""
Default cSerie := ""
Default cStaDUD:= ""
Default lNumRed:= .T.   //Pesquisa com Numero de Redespacho

	cAliasQry := GetNextAlias()
	cQuery := " SELECT R_E_C_N_O_ REC"
	cQuery += " FROM " + RetSqlName("DUD")
	cQuery += " WHERE DUD_FILIAL ='" + xFilial("DUD") + "'"
	cQuery += "   AND DUD_FILDOC ='" + cFilDoc + "'"
	cQuery += "   AND DUD_DOC    ='" + cDoc + "'"
	cQuery += "   AND DUD_SERIE  ='" + cSerie + "'"
	If lNumRed
		cQuery += "   AND DUD_NUMRED <>''"
	Else
		cQuery += "   AND DUD_NUMRED = '' "
	EndIf
	cQuery += "   AND DUD_SERTMS ='" + StrZero(3, Len(DUD->DUD_SERTMS))+  "'"
	cQuery += "   AND DUD_STATUS ='" + cStaDUD +  "'"
	cQuery += "   AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	If (cAliasQry)->(!Eof())
		nDudRed := (cAliasQry)->REC
	EndIf
	(cAliasQry)->( dbCloseArea() )

	RestArea(aArea)

Return nDudRed

/*/-----------------------------------------------------------
{Protheus.doc} TMA360Vet()
Identifica Documento de Redespacho conforme Status do Doctumento

Uso: TMSA360

@sample
//TMSA360()

@author Katia
@since 29/10/2018

@version 1.0
-----------------------------------------------------------/*/

Function TMA360Vet(nAcao)
Local aCab       := {}  
Local aItens     := {}
Local nCntFor1   := 0
Local lDUAPrzEnt := DUA->(ColumnPos("DUA_PRZENT")) > 0
Local nPosSeqOco := Ascan(aHeader,{|x| x[2] == "DUA_SEQOCO"})
Local nPosDatOco := Ascan(aHeader,{|x| x[2] == "DUA_DATOCO"})
Local nPosHorOco := Ascan(aHeader,{|x| x[2] == "DUA_HOROCO"})
Local nPosCodOco := Ascan(aHeader,{|x| x[2] == "DUA_CODOCO"})
Local nPosFilDoc := Ascan(aHeader,{|x| x[2] == "DUA_FILDOC"})
Local nPosDoc    := Ascan(aHeader,{|x| x[2] == "DUA_DOC"})
Local nPosSerie  := Ascan(aHeader,{|x| x[2] == "DUA_SERIE"})
Local nPosQtdOco := Ascan(aHeader,{|x| x[2] == "DUA_QTDOCO"})
Local nPosPesOco := Ascan(aHeader,{|x| x[2] == "DUA_PESOCO"})
Local nPosPrzEnt := Iif(lDUAPrzEnt, Ascan(aHeader,{|x| x[2] == "DUA_PRZENT"}), 0)

For nCntFor1 := 1 To Len(aColsNew)
	If aColsAnt[nCntFor1,nPosCodOco] != aColsNew[nCntFor1,nPosCodOco]
		If lDUAPrzEnt
			Aadd(aItens,{{"DUA_SEQOCO",aColsNew[nCntFor1,nPosSeqOco],NIL},;
					    {"DUA_ESTOCO",Iif(nAcao == 1,"1","2"),NIL},;
					    {"DUA_DATOCO",aColsNew[nCntFor1,nPosDatOco],NIL},;
					    {"DUA_HOROCO",aColsNew[nCntFor1,nPosHorOco],NIL},;
					    {"DUA_CODOCO",Iif(nAcao == 1,aColsAnt[nCntFor1,nPosCodOco],aColsNew[nCntFor1,nPosCodOco]),NIL},;
					    {"DUA_FILDOC",aColsNew[nCntFor1,nPosFilDoc],NIL},;
					    {"DUA_DOC"   ,aColsNew[nCntFor1,nPosDoc]   ,NIL},;
					    {"DUA_SERIE" ,aColsNew[nCntFor1,nPosSerie] ,NIL},;
				    	{"DUA_QTDOCO",aColsNew[nCntFor1,nPosQtdOco],NIL},;					
				    	{"DUA_PESOCO",aColsNew[nCntFor1,nPosPesOco],NIL},;
						{"DUA_PRZENT",Iif(nPosPrzEnt>0,aColsNew[nCntFor1,nPosPrzEnt],cTod("")),NIL} })  
		Else
			Aadd(aItens,{{"DUA_SEQOCO",aColsNew[nCntFor1,nPosSeqOco],NIL},;
					    {"DUA_ESTOCO",Iif(nAcao == 1,"1","2"),NIL},;
					    {"DUA_DATOCO",aColsNew[nCntFor1,nPosDatOco],NIL},;
					    {"DUA_HOROCO",aColsNew[nCntFor1,nPosHorOco],NIL},;
					    {"DUA_CODOCO",Iif(nAcao == 1,aColsAnt[nCntFor1,nPosCodOco],aColsNew[nCntFor1,nPosCodOco]),NIL},;
					    {"DUA_FILDOC",aColsNew[nCntFor1,nPosFilDoc],NIL},;
					    {"DUA_DOC"   ,aColsNew[nCntFor1,nPosDoc]   ,NIL},;
					    {"DUA_SERIE" ,aColsNew[nCntFor1,nPosSerie] ,NIL},;
				    	{"DUA_QTDOCO",aColsNew[nCntFor1,nPosQtdOco],NIL},;					
				    	{"DUA_PESOCO",aColsNew[nCntFor1,nPosPesOco],NIL} }) 
		EndIf				
	EndIf
Next nFntFor1

If !Empty(aItens)
	Aadd(aCab,{"DUA_FILOCO",M->DUA_FILOCO,Nil})
	Aadd(aCab,{"DUA_NUMOCO",M->DUA_NUMOCO,Nil})
	Aadd(aCab,{"DUA_FILORI",M->DUA_FILORI,Nil})
	Aadd(aCab,{"DUA_VIAGEM",M->DUA_VIAGEM,Nil})
EndIf

Return {aCab,aItens}

/*/-----------------------------------------------------------
{Protheus.doc} A360ComprE()
Grava tabela de Monitoramento de Comprovante de entrega

@author Daniel Leme
@since 30/07/2019
-----------------------------------------------------------/*/
Static Function A360ComprE(cFilOco,cNumOco,cCodOco,cFilDoc,cDoc,cSerie)
Local aAreas
Local lComprEnt	 := DT2->(ColumnPos("DT2_CMPENT")) > 0 .And. TableInDic("DLY") .And. ExistFunc('TMSIncDLY')
Local cQuery     := ''
Local cAliasDTC  := ''
Local aDLY		 := {}
Local lRet       := .F.
Local lHasDLYDoc := TableInDic("DLY") .And. DLY->(ColumnPos("DLY_FILDOC")) > 0 .And. DLY->(ColumnPos("DLY_DOC")) > 0 .And. DLY->(ColumnPos("DLY_SERIE")) > 0
Local lExist	 := .F.
Local cDataEnt	 := ""
Local cHoraEnt	 := ""
Local cChvCTE    := Space(Len(DT6->DT6_CHVCTE))
Local cTipOco    := ""
Local cTpOcoAtu  := "" //--Tipo de ocorrencia do documento atual
Local cNotExists := "NOT"
Local cTmpFilOco := cFilOco
Local cTmpNumOco := cNumOco
Local cTmpFilDoc := cFildoc
Local cTmpDoc    := cDoc
Local cTmpSerie  := cSerie
Local lHasDLYVia := TableInDic("DLY") .And. DLY->(ColumnPos("DLY_FILORI")) > 0 .And. DLY->(ColumnPos("DLY_VIAGEM")) > 0
Local lStaDM0    := Iif(lDM0,DM0->(ColumnPos("DM0_STATUS")) > 0,.F.)
Local lHVerao	 := SuperGetMv("MV_HVERAO",,.F.)

If lComprEnt
	//-- Salva as áreas
	aAreas := {DT2->(GetArea()),DT6->(GetArea()), GetArea()}

	DT2->(DbSetOrder(1)) //-- DT2_FILIAL+DT2_CODOCO
	DT6->(DbSetOrder(1)) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
	If DT6->(MsSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie)) ;
	   .And. DT2->(MsSeek(xFilial("DT2") + cCodOco)) ;
	   .And. DT6->DT6_DOCTMS $ StrZero(2,Len(DT6->DT6_DOCTMS)) + "|" + StrZero(7,Len(DT6->DT6_DOCTMS)) ;  //-- Documento CTRC, eletrônico OU de Reentrega
	   .And. (Alltrim(DT6->DT6_IDRCTE) == "100" ;
	          .Or. Alltrim(DT6->DT6_IDRCTE) == "136" ) ;
	          .And. !Empty(DT6->DT6_CHVCTE);                                
	   .And. DT2->DT2_CMPENT == "1"  ;         //-- Controla Comprovante de Entrega
	   .And. DT2->DT2_TIPOCO $ (StrZero(1,Len(DT2->DT2_TIPOCO)) + "|" + StrZero(6,Len(DT2->DT2_TIPOCO)) )  //-- Tipo de Ocorrência 01 (encerra processo, inicialmente, mas podem entrar 06 e 07 - pendências)

		cTipOco		:= DT2->DT2_TIPOCO
		cTpOcoAtu	:= DT2->DT2_TIPOCO
		cChvCTE		:= DT6->DT6_CHVCTE

		//+------------------------------------------------------------------------------------------------------------------------------------
		//-- Quando o documento é do tipo 7-Reentrega, possuir vinculo com documento original e o registro atual não for do tipo 06-pendencia.
		//-- Verifica se existir documento original vinculado e existindo redireciona o processamento da DLY com base neste 
		//-- documento para obter as notas fiscais do original.
		//-- uma vez que o documento pode ser de reentrega e não possui DTC vinculado ao lote.
		//-- aqui é tratado somente o tipo 7-CTR de Reentrega.
		//+------------------------------------------------------------------------------------------------------------------------------------
		If DT6->DT6_DOCTMS $ StrZero(7,Len(DT6->DT6_DOCTMS)) .And. !Empty(DT6->DT6_DOCDCO)
			DocOrigem(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,;
								@cFildoc,@cDoc,@cSerie,@cFilOco,@cNumOco,@cTipOco,@cChvCTE)
		EndIf

		//-- A Tabela DTC permite mais de um Produto por NF na DTC (e, nesta opção, não valida se nas duas linhas digita-se a mesma emissão)
		cQuery := " SELECT DTC_CLIREM,DTC_LOJREM,DTC_NUMNFC,DTC_SERNFC,DTC_NFEID, MAX(DTC_EMINFC) DTC_EMINFC "
		cQuery += " FROM " + RetSqlName("DTC") + " DTC "
		cQuery += " WHERE DTC.DTC_FILIAL = '" + xFilial("DTC") + "' "
		cQuery += "   AND DTC.DTC_FILDOC = '" + cFilDoc + "' "
		cQuery += "   AND DTC.DTC_DOC    = '" + cDoc    + "' "
		cQuery += "   AND DTC.DTC_SERIE  = '" + cSerie  + "' "
		cQuery += "   AND DTC.DTC_NFEID <> '" + Space(Len(DTC->DTC_NFEID)) + "' "
		cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "

		//-- Se tipo de ocorrencia é 06=gera pendência(do documento original), não deve incluir as notas com pendência somente as que serão entregues.
		If cTipOco == StrZero(6,Len(DT2->DT2_TIPOCO))
			//--Invertemos o NOT EXISTS para EXISTS para que seja considerado as notas da DV4 do documento original
			//--entendendo aqui que essa nota está na condição de entregue.
			cNotExists := "NOT"
			If DT6->DT6_DOCTMS $ StrZero(7,Len(DT6->DT6_DOCTMS)) .And. cTpOcoAtu $ StrZero(1,Len(DT2->DT2_TIPOCO))
				cNotExists := ""
			EndIf
			//--se a ocorrencia apontada atual for do tipo 6-pendencia o DV4 deve ser parametrizada com os dados do documento
			//-- que está sendo apontado no momento. Por isso recupera-se os valores do documento que está sendo apontado.
			If cTpOcoAtu $ StrZero(6,Len(DT2->DT2_TIPOCO))
				cFilOco	:= cTmpFilOco
				cNumOco	:= cTmpNumOco
				cFilDoc	:= cTmpFilDoc
				cDoc	:= cTmpDoc
				cSerie	:= cTmpSerie
			EndIf
			//--Se a ocorrencia atual for do tipo 6-pendencia e o documento é de reentrega verifica 
			DV4->(DbCommit()) //-- Força o INSERT e/ou UPDATE do Top para o bco: Ainda que dentro da transação, o dbAccess pode não ter enviado ao banco de dados a gravação recente.
			cQuery += " AND " + cNotExists + " EXISTS( SELECT 1 FROM "+ RetSqlName("DV4") + " DV4 "
			cQuery += "                 WHERE DV4.DV4_FILIAL = '" + xFilial("DV4")  + "' "
			cQuery += "                   AND DV4.DV4_FILOCO = '" + cFilOco + "' "
			cQuery += "                   AND DV4.DV4_NUMOCO = '" + cNumOco + "' "
			cQuery += "                   AND DV4.DV4_FILDOC = '" + cFilDoc + "'"
			cQuery += "                   AND DV4.DV4_DOC    = '" + cDoc    + "'"
			cQuery += "                   AND DV4.DV4_SERIE  = '" + cSerie  + "'"
			cQuery += "                   AND DV4.D_E_L_E_T_ = ' ' "
			cQuery += "                   AND DV4.DV4_NUMNFC = DTC.DTC_NUMNFC "
			cQuery += "                   AND DV4.DV4_SERNFC = DTC.DTC_SERNFC )"
		EndIf
		If cTpOcoAtu $ StrZero(6,Len(DT2->DT2_TIPOCO)) .And. DT6->DT6_DOCTMS $ StrZero(7,Len(DT6->DT6_DOCTMS)) 
			cQuery += " AND NOT EXISTS(SELECT 1 FROM " + RetSqlName("DLY") + " DLY WHERE DLY.D_E_L_E_T_ = ' ' "
			cQuery += " AND DLY.DLY_FILIAL = '" + fwxFilial("DLY") + "' "
			cQuery += " AND DLY.DLY_NUMNFC = DTC.DTC_NUMNFC "
			cQuery += " AND DLY.DLY_SERNFC = DTC.DTC_SERNFC "
			cQuery += " AND DLY.DLY_NFEID  = DTC.DTC_NFEID "
			cQuery += " AND DLY.DLY_EMINFC = DTC.DTC_EMINFC) "
		EndIf
		cQuery += " GROUP BY DTC_CLIREM,DTC_LOJREM,DTC_NUMNFC,DTC_SERNFC,DTC_NFEID"
		cAliasDTC := GetNextAlias()

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDTC, .F., .T.)
		TcSetField(cAliasDTC,"DTC_EMINFC","D",8,0)

		While (cAliasDTC)->(!Eof())

			If ExistFunc("TMSVerDLY")
				lExist := TMSVerDLY(cChvCTE,;
									(cAliasDTC)->DTC_CLIREM,;
									(cAliasDTC)->DTC_LOJREM,;
									(cAliasDTC)->DTC_NUMNFC,;
									(cAliasDTC)->DTC_SERNFC,;
									(cAliasDTC)->DTC_EMINFC) //--cChvCTe,cCliRem,cLojRem,cNumNFc,cSerNFc,dEmiNFc
			EndIf

			If !lExist
				aDLY := {}
				//--Valida fuso horario de acordo com a filial logada.
				DateTimeFS(/*cUF*/, lHVerao ,@cDataEnt,@cHoraEnt)
				
				aAdd(aDLY, {"DLY_CLIREM", (cAliasDTC)->DTC_CLIREM, Nil })
				aAdd(aDLY, {"DLY_LOJREM", (cAliasDTC)->DTC_LOJREM, Nil })
				aAdd(aDLY, {"DLY_NUMNFC", (cAliasDTC)->DTC_NUMNFC, Nil })
				aAdd(aDLY, {"DLY_SERNFC", (cAliasDTC)->DTC_SERNFC, Nil })
				aAdd(aDLY, {"DLY_EMINFC", (cAliasDTC)->DTC_EMINFC, Nil })
				aAdd(aDLY, {"DLY_STATUS", "1"                    , Nil }) //-- 1=Não Apto;2=Apto;3=Transmitido;4=Autorizado;5=Rejeitado
				aAdd(aDLY, {"DLY_IDREVE", ""                     , Nil })
				aAdd(aDLY, {"DLY_RETEVE", ""                     , Nil })
				aAdd(aDLY, {"DLY_NFEID" , (cAliasDTC)->DTC_NFEID , Nil })
				aAdd(aDLY, {"DLY_CHVCTE", DT6->DT6_CHVCTE        , Nil })
				aAdd(aDLY, {"DLY_TIPEVE", "1"                    , Nil }) //-- 1=Envio;2=Cancelamento
				aAdd(aDLY, {"DLY_TIPCAN", "0"                    , Nil }) //-- 0=Não se Aplica;1=Manual;2=Automático
				aAdd(aDLY, {"DLY_DATENT", M->DUA_DATOCO          , Nil })
				aAdd(aDLY, {"DLY_HORENT", cHoraEnt		         , Nil })
				If lHasDLYDoc
					aAdd(aDLY, {"DLY_FILDOC", DT6->DT6_FILDOC    , Nil })
					aAdd(aDLY, {"DLY_DOC"   , DT6->DT6_DOC       , Nil })
					aAdd(aDLY, {"DLY_SERIE" , DT6->DT6_SERIE     , Nil })
				EndIf
				If lHasDLYVia
					aAdd(aDLY, {"DLY_FILORI", DUA->DUA_FILORI    , Nil })
					aAdd(aDLY, {"DLY_VIAGEM", DUA->DUA_VIAGEM    , Nil })
				EndIf

				//-- Inclui os dados na tabela DLY
				If ExistFunc("TMSIntChk")
					TMSIntChk("2",aDLY)
				Else
					TMSIncDLY(aDLY,3)
				EndIf
	
				lRet := .T.
			EndIf
			
			(cAliasDTC)->(DbSkip())
		EndDo

		(cAliasDTC)->(DbCloseArea())
	EndIf

	If lStaDM0
		AtuDM0Int(cFilDoc,cDoc,cSerie,"","","",DUA->DUA_FILORI,DUA->DUA_VIAGEM)
	End
	
	//-- Restaura as Areas
	aEval( aAreas, {|xArea| RestArea(xArea) })
EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} A360VldCE()
Retorna se 
Uso: TMSA360
@author Felipe Barbiere
@since 01/08/2019
-----------------------------------------------------------/*/
Function A360VldCE(aChvCTe, nOpcVld)
Local lRet := .F.
Local aRet := {}

Default aChvCTe := {}
Default nOpcVld := 0

If ExistFunc('TMSVldECmp') .And. !Empty(aChvCTe) .And. TableIndic('DLY')
	aRet := TMSVldECmp({}, aChvCTe )
	If (!Empty(aRet) .And. aRet[1,2]) .Or. Empty(aRet) 
		lRet := .T.	
	EndIf
	If lRet .And. IsInCallStack("TMSA360TOk") .And. nOpcVld == 4 .And. !Empty(aRet)
		TMSCanECmp(aRet,"2")
	EndIf
Else 
	lRet := .T.
EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} A360BlqDDU()
Geração de Bloqueios para o Prazo de Entrega
(Ocorrencias Informativa ou Retorna Documento)
Uso: TMSA360
@author Katia
@since 11/09/2019
-----------------------------------------------------------/*/
Function A360BlqDDU(cNumOco,SeqOco,cFilOri,cViagem,cFilDoc,cDoc,cSerie,dPrzEnt)

Local lBlq029   := .F.
Local cChvRD    := ""
Local cDetalhe  := ""
Local aArea     := GetArea()
Local aAreaAnt  := {}
Local aAreaDT6  := DT6->(GetArea())

Default cNumOco := ""
Default SeqOco  := ""
Default cFilOri := ""
Default cViagem := ""
Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default dPrzEnt := Ctod("")

If FindFunction("TMSA029USE") .And. Tmsa029Use("TMSA360")
	If A360OcoPrz(DT2->DT2_CODOCO)
		DT6->(DbSetOrder(1))
		If DT6->(DbSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie)) .And. Empty(DT6->DT6_DATENT)
			If !Empty(DT6->DT6_PRZENT) .And. DT6->DT6_PRZENT <> dPrzEnt 
				lBlq029:= .T.
			EndIf
			If Empty(DT6->DT6_PRZORI)
				RecLock('DT6',.F.)
				DT6->DT6_PRZORI := DT6->DT6_PRZENT
				MsUnLock()
			EndIf
		EndIf
	EndIf	

	If lBlq029 	
		cChvRD   :=  xFilial("DUA") + cFilAnt + cNumOco + cFilOri + cViagem + SeqOco

		cDetalhe :=  Alltrim(RetTitle("DUA_DOC")) + ": " 							+ "#" +; //-- No. Docto.
		cFilDoc + cDoc + cSerie                                                     + "#" +; //-- cFilDoc + Docto + Série
		Alltrim(RetTitle("DT6_PRZENT")) + " Doc: "									+ "#" +; //-- Data Prazo de Entrega
		SubStr(DTOS(DT6->DT6_PRZENT), 7, 2) + "/" +  SubStr(DTOS(DT6->DT6_PRZENT), 5, 2) + "/" + SubStr(DTOS(DT6->DT6_PRZENT), 1, 4)   + "#" +; //-- Conteúdo Prazo de Entrega
		Alltrim(RetTitle("DUA_NUMOCO")) + ": " 										+ "#" +; //-- Nro Ocorrencia
		cNumOco+SeqOco                                  					    	+ "#" +; //-- Conteúdo Nro Ocorrencia
		Alltrim(RetTitle("DUA_PRZENT")) + " Ocor: " 								+ "#" +; //-- Data Prazo de Entrega
		SubStr(DTOS(dPrzEnt), 7, 2) + "/" +  SubStr(DTOS(dPrzEnt), 5, 2) + "/" + SubStr(DTOS(dPrzEnt), 1, 4) 	+ "|"    //-- Conteúdo Prazo de Entrega  

		
		lBlq029:= .F.
		//-- Bloqueia Registro Na Tabela DDU
		aAreaAnt:= GetArea()
		If Tmsa029Blq(  3      ,; //-- nOpc
			'TMSA360'          ,; //-- cRotina
			'PR'               ,; //-- cTipBlq
			cFilOri            ,; //-- cFilOri
			'DUA'              ,; //-- cTab
			'1'                ,; //-- cInd
			cChvRD             ,; //-- cChave -> DUA_FILIAL+DUA_FILOCO+DUA_NUMOCO+DUA_FILORI+DUA_VIAGEM+DUA_SEQOCO
			cViagem            ,; //-- cCod
			cDetalhe           ,; //-- cDetalhe
			Nil                ,; //-- nOpcRot
			0                  ,; //-- Valor Despesa
			0                  ,; //-- Valor Receita
			dPrzEnt             ) //-- Prazo de Entrega  

			lBlq029:= .T.
		EndIf			
		RestArea(aAreaAnt)

		If lBlq029 
			//-- Tratamento Para Liberação Automática Caso Configurado
			DT6->( DbSetOrder( 1 ) )
			If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
				RecLock('DT6',.F.)
				DT6->DT6_BLQDOC := StrZero( 1, Len( DT6->DT6_BLQDOC ) )
				MsUnLock()
			EndIf
			//-- Chama Rotina De Liberação Automática
			If DT2->DT2_LIBAUT == StrZero( 1, Len( DT2->DT2_LIBAUT ) ) 
				If !Tmsa029Lib( Nil , { 'TMSA360',"PR",cFilDoc,'DUA','1',cChvRD,cViagem} )
					//-- Mensagem Erro Caso Não Consiga Liberar
					Help('',1,'TMSA360D2') //-- 'A Liberação Automática Não Pôde Ser Realizada Conforme a Parametrização.','Verifique o Status Do Registro Na Rotina De Bloqueios Do TMS (TMSA029).'
				EndIf
			EndIf	
		EndIf
	EndIf	
EndIf

RestArea(aArea)
RestArea(aAreaDT6)
Return lBlq029

/*/-----------------------------------------------------------
{Protheus.doc} A360OcoPrz()
Verifica se é ocorrencia de Prazo de Entrega
Uso: TMSA360
@author Katia
@since 11/09/2019
-----------------------------------------------------------/*/
Function A360OcoPrz(cCodOco)
Local lRet     := .F.
Local aAreaDT2 := DT2->(GetArea())
Default cCodOco:= ""

If DT2->(ColumnPos('DT2_PRZENT')) > 0 .And. !Empty(cCodOco)
	DT2->(DbSetOrder(1))
	If DT2->(DbSeek(xFilial("DT2")+cCodOco))
		If DT2->DT2_PRZENT == StrZero(1,Len(DT2->DT2_PRZENT)) .And. DT2->DT2_RESOCO == StrZero(2,Len(DT2->DT2_RESOCO)) .And.;
			(DT2->DT2_TIPOCO == StrZero(4,Len(DT2->DT2_TIPOCO)) .Or. DT2->DT2_TIPOCO == StrZero(5,Len(DT2->DT2_TIPOCO)) )
				lRet:= .T.
		EndIf	
	EndIf
EndIf

RestArea(aAreaDT2)
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} A360EstPrz()
Valida o Estorno da Ocorrencia de Prazo de Entrega
Uso: TMSA360
@author Katia
@since 22/09/2019
-----------------------------------------------------------/*/
Function A360EstPrz(cFilDoc,cDoc,cSerie,cFilOco,cNumOco,cSeqOco,cFilOri,cViagem,aHelpErr,lOcoPost,lPergunta,nRecnoDUA)
Local lRet      := .T.
Local aArea     := GetArea()
Local cAliasQry := ""
Local cQuery    := ""

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default cFilOco  := ""
Default cNumOco  := ""
Default cSeqOco  := ""
Default cFilOri  := ""
Default cViagem  := ""
Default aHelpErr := {}
Default lOcoPost := .F.  //Verifica se existe ocorrencia posterior
Default lPergunta:= .T.
Default nRecnoDUA:= 0

	cAliasQry := GetNextAlias()
	If lOcoPost
		cQuery := " SELECT COUNT(*) NREG "
	Else
		cQuery := " SELECT DUA.R_E_C_N_O_ RECNODUA "
	EndIf	
	cQuery += "   FROM  " + RetSqlName("DUA") + " DUA "
	
	cQuery += " INNER JOIN " + RetSqlName("DT2") + " DT2 "
	cQuery += " 	ON DT2.DT2_FILIAL = '" + xFilial("DT2") + "' "
	cQuery += "    AND DT2.DT2_CODOCO = DUA.DUA_CODOCO  "
	cQuery += "    AND DT2.DT2_TIPOCO IN ('" + StrZero(4, Len(DT2->DT2_TIPOCO)) + "','" + StrZero(5, Len(DT2->DT2_TIPOCO)) + "') "   //Retorna Doc ou Informativa
	cQuery += "    AND DT2.DT2_RESOCO = '" + StrZero(2, Len(DT2->DT2_RESOCO)) + "' "   //Cliente
	cQuery += "    AND DT2.DT2_PRZENT = '" + StrZero(1, Len(DT2->DT2_PRZENT)) + "' "   //Prazo Entrega
	cQuery += "    AND DT2.D_E_L_E_T_ = ' ' "
	
	cQuery += "  WHERE DUA.DUA_FILIAL = '" + xFilial("DUA") + "' "
	cQuery += "    AND DUA.DUA_FILDOC = '" + cFilDoc + "' "
	cQuery += "    AND DUA.DUA_DOC    = '" + cDoc    + "' "
	cQuery += "    AND DUA.DUA_SERIE  = '" + cSerie  + "' "
	cQuery += "    AND DUA.DUA_FILOCO = '" + cFilOco + "' "
	If lOcoPost
		cQuery += "    AND DUA.DUA_NUMOCO > '" + cNumOco + "' "
	Else
		cQuery += "    AND DUA.DUA_NUMOCO < '" + cNumOco + "' "
	EndIf	
	cQuery += "    AND DUA.D_E_L_E_T_ = ' ' "
	If !lOcoPost
		cQuery += "    ORDER BY DUA.DUA_NUMOCO DESC "
	EndIf	

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	If (cAliasQry)->(!Eof()) 
		If lOcoPost
			If (cAliasQry)->NREG > 0
				aAdd(aHelpErr, {"TMSA360F9", cSeqOco}) //""Não será possivel o estorno dessa ocorrência, pois existe Ocorrência posteriores de Prazo de Entrega para este Documento."
				lRet:= .F.
			EndIf
		Else
			nRecnoDUA:= (cAliasQry)->RECNODUA 
			lRet:= .F.
		EndIf	
	EndIf
	(cAliasQry)->(DbCloseArea())  

	If lRet .And. lPergunta .And. !lAjusta
		If !IsInCallStack("TMSA360TOK") 	//Validação para apresentar o pergunte somente uma vez, devido a chamada ser no 360Vld e 360TOK 
			cChave:= xFilial('DUA')+cFilOco+cNumOco+cFilOri+cViagem+cSeqOco
			DbSelectArea("DDU")
			DDU->(DbSetOrder(2)) //-- DDU_FILIAL+DDU_ALIAS+DDU_CHAVE+DDU_TIPBLQ+STR(DDU_NIVBLQ)+DDU_FILORI                                                                                            
			If DDU->(DbSeek(xFilial("DDU") + 'DUA' + Padr(cChave,Len(DDU->DDU_CHAVE)) + 'PR' ))
				If DDU->DDU_STATUS == '2' //Liberado
					lRet    := MsgYesNo(STR0134 +  cSeqOco + " " + STR0135  + " " + STR0081, STR0055)					
				EndIf	
			EndIf
		EndIf	
	EndIf

RestArea(aArea)
Return lRet	 

/*/-----------------------------------------------------------
{Protheus.doc} A360AtuPrz()
Atualiza Prazo de Entrega do Estorno da Ocorrencia 
Uso: TMSA360
@author Katia
@since 23/09/2019
-----------------------------------------------------------/*/
Function A360AtuPrz(cFilDoc,cDoc,cSerie,cFilOco,cNumOco,cSeqOco,cFilOri,cViagem)
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaAnt  := Nil
Local aAreaDT6  := DT6->(GetArea())
Local lLiberado := .F.
Local dDtPrzEnt := cToD("")
Local nRecnoDUA := 0
Local aAreaDUA  := {}
Local aAreaDDU  := {}
Local lRegDDU   := .F.

Default cFilDoc:= ""
Default cDoc   := ""
Default cSerie := ""
Default cFilOco := ""
Default cNumOco := ""
Default cSeqOco := ""
Default cFilOri := ""
Default cViagem := ""

	aAreaDDU := DDU->( GetArea() )

	lUltReg:= A360EstPrz(cFilDoc,cDoc,cSerie,cFilOco,cNumOco,cSeqOco,cFilOri,cViagem,,.F.,.F.,@nRecnoDUA)

	If !lUltReg .And. nRecnoDUA > 0 //Posiciona no bloqueio da ocorrencia anterior
		aAreaDUA := DUA->( GetArea() )		
 	    DUA->(dbGoto(nRecnoDUA))
	
		cChave:= xFilial('DUA')+DUA->DUA_FILOCO+DUA->DUA_NUMOCO+DUA->DUA_FILORI+DUA->DUA_VIAGEM+DUA->DUA_SEQOCO
		DDU->( DbSetOrder( 2 ) )//-- DDU_FILIAL+DDU_ALIAS+DDU_CHAVE+DDU_TIPBLQ+STR(DDU_NIVBLQ)+DDU_FILORI                                                                                            
		lRegDDU:= DDU->(DbSeek(xFilial("DDU") + 'DUA' + Padr(cChave,Len(DDU->DDU_CHAVE)) + 'PR' ))
		If !lRegDDU
			cChave:= xFilial('DUA')+DUA->DUA_FILOCO+DUA->DUA_NUMOCO+Space(Len(DUA->DUA_FILORI))+Space(Len(DUA->DUA_VIAGEM))+DUA->DUA_SEQOCO
			lRegDDU:= DDU->(DbSeek(xFilial("DDU") + 'DUA' + Padr(cChave,Len(DDU->DDU_CHAVE)) + 'PR' ))
		EndIf
		RestArea(aAreaDUA)		
		//Posiciona no bloqueio da Ocorrencia atual para exclusão
		cChave:= xFilial('DUA')+cFilOco+cNumOco+cFilOri+cViagem+cSeqOco  
	Else
		cChave:= xFilial('DUA')+cFilOco+cNumOco+cFilOri+cViagem+cSeqOco   //Posiciona no bloqueio da Ocorrencia atual
		DDU->( DbSetOrder( 2 ) )//-- DDU_FILIAL+DDU_ALIAS+DDU_CHAVE+DDU_TIPBLQ+STR(DDU_NIVBLQ)+DDU_FILORI                                                                                            
		lRegDDU:= DDU->(DbSeek(xFilial("DDU") + 'DUA' + Padr(cChave,Len(DDU->DDU_CHAVE)) + 'PR' ))
	EndIf	

	If lRegDDU
		If DDU->DDU_STATUS == '2' //Liberado
			lLiberado:= .T.
			dDtPrzEnt:= DDU->DDU_DATA
		EndIf
	EndIf
	RestArea(aAreaDDU)

	If lRegDDU
		If Tmsa029Use("TMSA360")
			aAreaAnt:= GetArea()
			If Tmsa029Exc('DUA',;         //-- 01 - cTab
						cChave,;        //-- 02 - cChave
						'1',;           //-- 03 - cInd
						'PR',;          //-- 04 - cTipBlq 
						cFilOri,;       //-- 05 - cFilOri
						'TMSA360',;     //-- 06 - cRotina  
						5)              //-- 07 - nOpcRot
				
				RestArea(aAreaAnt)
				DT6->( DbSetOrder( 1 ) )
				If	DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )
					RecLock('DT6',.F.)
					//-- Desbloquear o Documento se o mesmo estiver Bloqueado
					If !lLiberado 
						If DT6->DT6_BLQDOC == StrZero( 1, Len( DT6->DT6_BLQDOC ) )
							DT6->DT6_BLQDOC := StrZero( 2, Len( DT6->DT6_BLQDOC ) )	//-- Nao
						EndIf	
					Else
						If lUltReg  //Nao há ocorrencias anteriores, volta a Data do Prazo de Entrega Original
							DT6->DT6_PRZENT := DT6->DT6_PRZORI
						Else
							If !Empty(dDtPrzEnt)    //Volta a Data do Prazo de Entrega da Liberação (DDU_DATA)
								DT6->DT6_PRZENT := dDtPrzEnt
							EndIf	
						EndIf	
					EndIf	
					DT6->(MsUnLock())
				EndIf
			Else
				lRet:= .F.
			EndIf	
		EndIf
	Else
		lRet:= .T.   //Nao existe bloqueio 
	EndIf	

RestArea(aArea)
RestArea(aAreaDT6)
Return lRet


/*/-----------------------------------------------------------
{Protheus.doc} TM360OcGFE()
Realiza integração de Ocorrencias com o GFE
Uso: TMSA360
@author Katia
@since 26/11/2019
-----------------------------------------------------------/*/
Function TM360OcGFE(cFilDoc,cDoc,cSerie,cFilOri,cViagem,cCodOco,cCodFor,cLojFor,nValInf,cSeqOco,cDUAFILOCO,cDUANUMOCO,nQtdOco)

Local lRet         := .T.
Local lDocRedes    := .F.
Local aArea        := GetArea()
Local cColGFE      := SuperGetMV( "MV_COLGFE" ,.F., "0" )  //0-Padrão, 1-Encerramento
Local cCdTransp    := ""
Local cSerTMSDTQ   := ""
Local lNumProp     := Iif(FindFunction("GFEEMITMP"),GFEEMITMP(),.F.)      //Parametro Numeracao
Local aCabGFE      := {}
Local aItensGFE    := {}
Local lContinua    := .F.
Local lOkOcoGFE    := .F.
Local aRecGWUEnc   := {}
Local aRecGWU      := {}
Local lEncerProc   := .F.
Local nCount       := 0
Local lColGFE      := .F.
Local cOcorCol 	   := SuperGetMv('MV_OCORCOL',,"")
Local lContGFE     := .F.
Local cOcorEnt 	   := SuperGetMv('MV_OCORENT',,"")
Local aCab         := {}
Local aItens       := {}
Local nPos1        := 0
Local nPos2        := 0
Local cSeqGWU      := ""
Local lGWLSeq      := GWL->(ColumnPos("GWL_SEQ")) > 0

Default cFilDoc    := ""
Default cDoc       := ""
Default cSerie     := ""
Default cFilOri    := ""
Default cViagem    := ""
Default cCodOco    := ""
Default cCodFor    := ""
Default cLojFor    := ""
Default nValInf    := 0
Default cSeqOco    := ""
Default cDUAFILOCO := ""
Default cDUANUMOCO := ""
Default nQtdOco    := 0

If Type("cSerTMS") == "U" .And. Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.T.)
	cSerTMS := DTQ->DTQ_SERTMS
EndIf

DT2->(DbSetOrder(1))
DT2->(DbSeek(xFilial("DT2")+cCodOco))
If  DT2->(ColumnPos("DT2_CDTIPO")) > 0 .AND. !Empty(DT2->DT2_CDTIPO) .And. nModulo <> 78  //Quando executado via rotina automatica pelo SIGAGFE nao executar a chamada do GFEA032 (duplicidade)
	lDocRedes  := TMA360IDFV( cFilDoc,cDoc,cSerie,.T.,cFilOri,cViagem )
	If !lDocRedes
		lColGFE:= .F.
		DUD->( DbSetOrder( 1 ) )
		If	DUD->( MsSeek( xFilial('DUD') + cFilDoc + cDoc + cSerie +  cFilOri + cViagem ) )
			lContGFE:= !Empty(DUD->DUD_CHVEXT)	
			If !lContGFE .And. cColGFE == "1" .And. cSerie == "COL"					
				lColGFE:= .T.

				RecLock('DUA', .F.)
				DUA->DUA_ORIGEM:= 'TMSA360E' //Identifica para que seja gerado a ocorrencia no GFE no Encerramento da Viagem
				DUA->(MsUnLock())
			EndIf
		EndIf
	Else
		lContGFE:= .T.
	EndIf

	If lContGFE
		dbSelectArea("GU5")
		GU5->(dbSetOrder(1))
		If GU5->(dbSeek(FwxFilial("GU5") + DT2->DT2_CDTIPO))
			If cCodOco == GU5->GU5_OCOTMS .OR. Empty(GU5->GU5_OCOTMS)

				// Busca o Transportador da Ocorrencia TMS
				If FindFunction('TMSGBscTra')
					cCdTransp:= TMSGBscTra(cCodFor,cLojFor,cFilOri,cViagem,lNumProp)
				EndIf
				
				//-- Array do Cabecalho
				Aadd( aCabGFE  , {"GWD_DSOCOR" , DT2->DT2_DESCRI	, Nil } )
				Aadd( aCabGFE  , {"GWD_ORIGEM" , '2'	            , Nil } )
				Aadd( aCabGFE  , {"GWD_CDTIPO" , DT2->DT2_CDTIPO	, Nil } )
				Aadd( aCabGFE  , {"GWD_FLOROC" , cDUAFILOCO   	    , Nil } )
				Aadd( aCabGFE  , {"GWD_QTDVOL" , nQtdOco        	, Nil } )
				Aadd( aCabGFE  , {"GWD_QTPERN" , nValInf        	, Nil } )
				Aadd( aCabGFE  , {"GWD_CHVEXT" , cDUANUMOCO + cSeqOco, Nil } )
				Aadd( aCabGFE  , {"GWD_CDTRP"  , cCdTransp        	, Nil } )

				If Len(aItensGFE) == 0 .And. (DT2->DT2_TIPOCO == StrZero( 6, Len( DT2->DT2_TIPOCO ) ) .Or. DT2->DT2_TIPOCO == StrZero( 19, Len( DT2->DT2_TIPOCO ) ) .Or. DT2->DT2_TIPOCO == StrZero( 20, Len( DT2->DT2_TIPOCO ) ) )
					TCRefresh( "DV4" )
				EndIf

				dbSelectArea("GU4")
				GU4->(dbSetOrder(2))
				If GU4->(dbSeek(FwxFilial("GU4")+ GU5->GU5_CDTIPO ))
					Aadd( aCabGFE  , {"GWD_CDMOT" , GU4->GU4_CDMOT    , Nil } )
				EndIf
				Aadd( aCabGFE  , {"GWD_DSPROB"  , IiF(Empty(MSMM(DUA->DUA_CODMOT)), STR0105 ,MSMM(DUA->DUA_CODMOT)) , Nil } ) //-- "Integrado através do SIGATMS"

				DT6->( DbSetOrder( 1 ) )
				If DT6->( DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie ) )

					dbSelectArea("GWE")
					GWE->(dbSetOrder(2))  //GWE_FILIAL+GWE_FILDT+GWE_NRDT+GWE_SERDT
					If GWE->(dbSeek(FwxFilial("GWE") + cFilDoc + cDoc + cSerie    ))
						While  GWE->(!EOF()) .And.  GWE->(GWE_FILIAL+GWE_FILDT+GWE_NRDT+GWE_SERDT) == FwxFilial("GWE") + cFilDoc + cDoc + cSerie

							lContinua := .F.

							If (DT2->DT2_TIPOCO == StrZero( 6, Len( DT2->DT2_TIPOCO ) ) .Or. DT2->DT2_TIPOCO == StrZero( 19, Len( DT2->DT2_TIPOCO ) ) .Or. DT2->DT2_TIPOCO == StrZero( 20, Len( DT2->DT2_TIPOCO ) ) )

								dbSelectArea("DV4")
								DV4->(dbSetOrder(3)) //DV4_FILIAL+DV4_FILDOC+DV4_DOC+DV4_SERIE+DV4_NUMNFC+DV4_SERNFC
								If (DV4->( dbSeek( FwxFilial("DV4") + GWE->(GWE_FILDT+GWE_NRDT+GWE_SERDT+PADR(GWE->GWE_NRDC,LEN(DTC->DTC_NUMNFC))+PADR(GWE->GWE_SERDC,LEN(DTC->DTC_SERNFC)) ) ) ) )
									lContinua := .T.
								EndIf
							ElseIf DT2->DT2_TIPOCO == StrZero( 1, Len( DT2->DT2_TIPOCO ) ) .And. DT6->DT6_SERIE<>"COL"  //Coleta
								DbSelectArea("DTC")
								DTC->(dbSetOrder(7)) //DTC_FILIAL+DTC_DOC+DTC_SERIE+DTC_FILDOC+DTC_NUMNFC+DTC_SERNFC
								If (DTC->( dbSeek( FwxFilial("DTC")+ Iif(Empty(DT6->DT6_DOCDCO),GWE->(GWE_NRDT+GWE_SERDT+GWE_FILDT),DT6->(DT6_DOCDCO+DT6_SERDCO+DT6_FILDCO))+PADR(GWE->GWE_NRDC,LEN(DTC->DTC_NUMNFC))+PADR(GWE->GWE_SERDC,LEN(DTC->DTC_SERNFC)) ) ) )
									//--- Quando aponta uma ocorrencia de Encerra Processo e Gera Pendencia, neste momento da gravação da ocorrencia Encerra Processo (01) nao gravou a tabela DV4.
									//--- A Tabela DV4 será gravada somente no momento da gravação da ocorrencia Gera Pendencia (06). Neste caso é necessario verificar a variavel aNfAvaria
									lContinua:= .T.

									If ValType( aNFAvaria ) == 'A' .And. Len(aNFAvaria) > 0 
										If (nPos1 := Ascan(aNFAvaria,{ |x| x[1] == cFilDoc + cDoc + cSerie })) > 0
											If nPos2:= AScan(aNFAvaria[nPos1][2],{|x|x[1]+x[2]==DTC->DTC_NUMNFC+DTC->DTC_SERNFC})
												If !aNFAvaria[ nPos1,2,nPos2,Len(aNFAvaria[nPos1,2,nPos2]) ]   //Registro Não Deletado
													lContinua:= .F.
												EndIf
											EndIf
										EndIf
									EndIf

								EndIf
							Else
								lContinua := .T.
							EndIf

							If lContinua   
								cSeqGWU:= ""
								If DT2->DT2_TIPOCO == StrZero( 21, Len( DT2->DT2_TIPOCO ) ) .Or. lGWLSeq 
									TMSInfGWU(cDUANUMOCO,cSeqOco,cCdTransp,@cSeqGWU,@aRecGWU,@aRecGWUEnc)  
								EndIf	

								//-- Array de itens
								Aadd( aItensGFE , {} )
								Aadd( aItensGFE [Len(aItensGFE)], {"GWL_NRDC"  , GWE->GWE_NRDC 		, Nil } )
								Aadd( aItensGFE [Len(aItensGFE)], {"GWL_FILDC" , GWE->GWE_FILIAL	, Nil } )
								Aadd( aItensGFE [Len(aItensGFE)], {"GWL_EMITDC", GWE->GWE_EMISDC	, Nil } )
								Aadd( aItensGFE [Len(aItensGFE)], {"GWL_SERDC" , GWE->GWE_SERDC 	, Nil } )
								Aadd( aItensGFE [Len(aItensGFE)], {"GWL_TPDC"  , GWE->GWE_CDTPDC	, Nil } )

								If lGWLSeq
									Aadd( aItensGFE [Len(aItensGFE)], {"GWL_SEQ"   , cSeqGWU , Nil } )
								EndIf	

							EndIf
							GWE->(dbSkip())
						EndDo
					EndIf
				EndIf

				//Grava Registros do GFE
				lOkOcoGFE := TMSMdlAuto( aCabGFE  , aItensGFE  , 3 , "GFEA032" , "GFEA032_GWD" , "GFEA032_GWL" , "GWD" , "GWL" , .T. )
				If ! lOkOcoGFE
					//-- Apontamento Automático de Ocorrência no GFE:
					//-- ocorreram erros durante o apontamento da ocorrência no GFE
					//-- e o processo não será efetivado.
					Help(" ", 1, "TMSA360E3")
					lRet := .F.
				EndIF
				aCabGFE  := {}
				aItensGFE:= {}

				If lRet .And. DT2->DT2_TIPOCO == StrZero( 21, Len( DT2->DT2_TIPOCO ) )

					If lOkOcoGFE
						dbSelectArea("GWU")

						// Atualiza chave da GWU
						For nCount := 1 To Len(aRecGWU)
							GWU->(dbGoTo(aRecGWU[nCount][1]))

							RecLock('GWU', .F.)
							GWU->GWU_CHVEXT  := aRecGWU[nCount][2]
							GWU->(MsUnLock())
						Next nCount

						// Verifica se pode incluir Ocorrencia de Encerra Processo.
						lEncerProc	:= .F.
						For nCount := 1 To Len(aRecGWUEnc)
							GWU->(dbGoTo(aRecGWUEnc[nCount]))
							// Verifica se possui registro de entrega por Trecho
							If !Empty(GWU->GWU_DTENT) .AND. GWU->GWU_PAGAR =='1'
								lEncerProc	:= .T.
							Else
								lEncerProc	:= .F.
								Exit
							EndIf
						Next nCount

						If lEncerProc
							cSerTMSDTQ := Posicione("DTQ", 2, xFilial('DTQ')+cFilOri+cViagem, "DTQ_SERTMS")
							If cSerTMSDTQ <> StrZero(2,Len(DTQ->DTQ_SERTMS))
								aAreaDT2 := DT2->( GetArea() )
								DT2->( DbSetOrder( 1 ) )
								If DT2->( DbSeek( xFilial('DT2') + Iif(cSerTMSDTQ == StrZero(1,Len(DTQ->DTQ_SERTMS)),cOcorCol,cOcorEnt) ))
									// Ocorrencia por Documento
									If DT2->DT2_CATOCO == '1'

										If MsgYesNo(STR0102,STR0103) // "Deseja apontar o Encerramento do Processo do Documento TMS ?" ### "Entrega trecho GFE"
											//-- Cabecalho da Ocorrencia
											AAdd(aCab,{"DUA_FILORI", Space(Len(DUA->DUA_FILORI)) ,Nil})
											AAdd(aCab,{"DUA_VIAGEM", Space(Len(DUA->DUA_VIAGEM)) ,Nil})

											//-- Itens da Ocorrencia
											AAdd(aItens, {	{"DUA_SEQOCO", StrZero(1,Len(DUA->DUA_SEQOCO))   , Nil},;
															{"DUA_DATOCO", dDataBase                         , Nil},;
															{"DUA_HOROCO", StrTran(Left(Time(),5),":","")    , Nil},;
															{"DUA_CODOCO", DT2->DT2_CODOCO                   , Nil},;
															{"DUA_SERTMS", cSerTms						     , Nil},;
															{"DUA_FILDOC", cFilDoc                           , Nil},;
															{"DUA_DOC"   , cDoc                              , Nil},;
															{"DUA_SERIE" , cSerie                            , Nil}})

											lRet := A360GrvThd(aCab, aItens, {}, 3)

										EndIf
									Else
										If cSerTMSDTQ == StrZero(3,Len(DTQ->DTQ_SERTMS))
											Help('',1,'TMSA360E1')//Ocorrência do Parâmentro MV_OCORENT deve ser Categoria por documento (DT2_CATOCO ='1').
										Else	
											Help( ,, 'HELP',, STR0129, 1, 0) //Ocorrência do Parâmentro MV_OCORCOL deve ser Categoria por documento (DT2_CATOCO ='1').
										EndIf	
									EndIf
								EndIf	
							EndIf	
						EndIf
					EndIf
				EndIf
			Else
				//-- Apontamento Automático de Ocorrência no GFE: divergência de informação
				//-- no cadastro da ocorrência no GFE. Código da Ocorrência TMS diferente do
				//-- informado no cadastro (GU5_OCOTMS). A ocorrência não será integrada
				//-- automaticamente no GFE e o processo não será efetivado.
					Help(" ", 1, "TMSA360E4")
					lRet := .F.
			EndIf
		Else
			//-- Apontamento Automático de Ocorrência no GFE: ocorrência não encontrada no
			//-- cadastro de Ocorrências GFE (GU5). A ocorrência não será integrada
			//-- automaticamente no GFE e o processo não será efetivado.
			//-- Ocorrência GFE:
			Help(" ", 1, "TMSA360E5", , DT2->DT2_CDTIPO, 2, 1)
			lRet := .F.
		EndIf
	Else
		//-- Apontamento Automático de Ocorrência no GFE: ocorrência cadastrada com
		//-- Tip.Ocor.GFE (DT2_CDTIPO) informada, porém, o documento não está relacionado
		//-- a um documento de carga. A ocorrência não será integrada automaticamente no GFE
		//-- e o processo não será efetivado.
		//-- Ocorrência TMS:
		If !lColGFE  
			//Quando o MV_COLGFE = 1 a Coleta será integrada no Encerramento da Viagem, portanto o Help nao será apresentado.
			//e a ocorrencia será integrada no momento do Encerramento da viagem
			Help(" ", 1, "TMSA360E6", , DT2->DT2_CODOCO, 2, 1)
			lRet := .F.
		Else
			lRet := .T.	//Permite o apontamento
		EndIf	
		
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TM360EsGFE()
Realiza estorno da integração de Ocorrencias com o GFE
Uso: TMSA360
@author Katia
@since 26/11/2019
-----------------------------------------------------------/*/
Function TM360EsGFE( cFilOco, cNumOco, cSeqOco, cCodOco, lRot340, aErrTms )

Local aArea     := GetArea()
Local lContinua := .F.
Local aErroGFE  := {} 
Local cErroGFE  := ""
Local oModelGFE := Nil

Default cFilOco := ""
Default cNumOco := ""
Default cSeqOco := ""
Default cCodOco := ""
Default lRot340 := .F.
Default aErrTms := {}

DbSelectArea("GWD")
If ! Empty(GWD->(IndexKey(7)))
	GWD->(dbSetOrder(7))
	If GWD->(dbSeek(cNumOco + cSeqOco))
		If GWD->GWD_FILIAL == cFilOco
			//-- Caso chegue neste ponto, somente deve permitir o estorno da ocorrência no TMS
			//-- se for possível estornar a ocorrência no GFE

			lContinua := .F.
			aErroGFE  := {}
			cErroGFE  := ""

			//-- Situação da ocorrência no GFE como: Aprovada (GWD_SIT == '2') ou
			//-- Reprovada (GWD->GWD_SIT == '3'), deve chamar a funcao de cancelamento
			//-- antes de realizar a eliminação da ocorrência
			If GWD->GWD_SIT == '2' .Or. GWD->GWD_SIT == '3'

				aErroGFE := GFEA032CAN(.F.) //-- Cancelamento da aprovação ou reprovação
				If ValType(aErroGFE) == "L"
					lContinua := aErroGFE
					If ! lContinua
						cErroGFE := STR0106
					EndIf
				ElseIf ValType(aErroGFE) == "A"
					lContinua := aErroGFE[1]
					If ! lContinua
						cErroGFE := aErroGFE[2]
					EndIf
				Else
					cErroGFE := STR0107
				EndIf
			Else //-- Pendente
				lContinua := .T.
			EndIf

			//-- Efetiva a exclusão da ocorrência no GFE
			If lContinua

				oModelGFE := FwLoadModel("GFEA032")
				oModelGFE:SetOperation(MODEL_OPERATION_DELETE)

				//-- Funções de validação do Model
					If ! oModelGFE:Activate()             .Or.;
						! oModelGFE:VldData()              .Or.;
						! oModelGFE:VldData("GFEA032_GWD") .Or.;
						! oModelGFE:VldData("GFEA032_GWL")
							lContinua := .F.
							aErroGFE  := oModelGFE:GetErrorMessage()
							cErroGFE  := AllToChar(aErroGFE[6]) + CRLF +;
							AllToChar(aErroGFE[7]) + CRLF + CRLF +;
							AllToChar(aErroGFE[2]) + " / " +;
							AllToChar(aErroGFE[9])
					Else
							oModelGFE:CommitData()
							oModelGFE:DeActivate()
							FreeObj(oModelGFE)
					EndIf
			EndIf

			If !lContinua
				//-- Não foi possível estornar a ocorrência integrada ao GFE. Detalhes:
				If !lRot340
					Help(" ", 1, "TMSA360E8", , cErroGFE, 2, 1)
				EndIf	
				lContinua:= .F.
			EndIf
		EndIf
	Else
		lContinua:= .T.
	EndIf
EndIf

If lRot340 .And. !Empty(cErroGFE)
	Aadd(aErrTms,{cErroGFE})
EndIf	

RestArea(aArea)
Return lContinua

/*/{Protheus.doc} DocOrigem()
	(funcao que retorna por referencia o documento original que possui apontamento de ocorrencia do tipo 6-pendencia.)
	@type  Static Function
	@author Tiago dos Santos
	@since 2020-02-24
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function DocOrigem(cFilDoc,cDocto,cSerie,cFilDco,cDocDco,cSerDco,cFilOco,cNumOco,cTipOco,cChvCTe)
 Local cQuery  := ""
 Local cAlias  := GetNextAlias()
 Local lResult := .F.

		cQuery := "SELECT DUA.DUA_FILOCO,DUA.DUA_NUMOCO,ORIG.DT6_FILDOC,ORIG.DT6_DOC,ORIG.DT6_SERIE,ORIG.DT6_CHVCTE "
		cQuery += " FROM " + RetSqlName("DT6") + " DT6 "

		cQuery += " LEFT JOIN " + RetSqlName("DT6") + " ORIG ON "
		cQuery += " ORIG.D_E_L_E_T_ = ' ' "
		cQuery += " AND ORIG.DT6_FILIAL = '" + fwxFilial("DT6") + "' "
		cQuery += " AND ORIG.DT6_FILDOC = DT6.DT6_FILDCO "
		cQuery += " AND ORIG.DT6_DOC = DT6.DT6_DOCDCO "
		cQuery += " AND ORIG.DT6_SERIE = DT6.DT6_SERDCO "

		cQuery += " LEFT JOIN " + RetSqlName("DTP") + " DTP ON "
		cQuery += " DTP.D_E_L_E_T_ = ' ' "
		cQuery += " AND DTP.DTP_FILIAL = '" + fwxFilial("DTP") + "' "
		cQuery += " AND DTP.DTP_FILORI = ORIG.DT6_FILORI "
		cQuery += " AND DTP.DTP_LOTNFC = ORIG.DT6_LOTNFC "

		cQuery += " LEFT JOIN " + RetSqlName("DUA") + " DUA ON "
		cQuery += " DUA.D_E_L_E_T_ = ' ' "
		cQuery += " AND DUA.DUA_FILIAL = '" + fwxFilial("DUA") + "' "
		cQuery += " AND DUA.DUA_FILDOC = ORIG.DT6_FILDOC "
		cQuery += " AND DUA.DUA_DOC = ORIG.DT6_DOC "
		cQuery += " AND DUA.DUA_SERIE = ORIG.DT6_SERIE "

		cQuery += " LEFT JOIN " + RetSqlName("DT2") + " DT2 ON "
		cQuery += " DT2.D_E_L_E_T_ = ' ' "
		cQuery += " AND DT2.DT2_FILIAL = '" + fwxFilial("DT2") + "' "
		cQuery += " AND DT2.DT2_CODOCO = DUA.DUA_CODOCO "

		cQuery += " WHERE DT6.D_E_L_E_T_ = ' ' "
		cQuery += " AND DT6.DT6_FILIAL = '" + fwxFilial("DT6") + "' "
		cQuery += " AND DT6.DT6_FILDOC = '" + cFilDoc + "' "
		cQuery += " AND DT6.DT6_DOC = '"    + cDocto  + "' "
		cQuery += " AND DT6.DT6_SERIE = '"  + cSerie  + "' "
		cQuery += " AND DT2.DT2_CMPENT = '1' "
		cQuery += " AND DTP.DTP_TIPLOT IN('" + StrZero(3,Len(DTP->DTP_TIPLOT)) + "','" + StrZero(4,Len(DTP->DTP_TIPLOT)) + "') "
		cQuery += " AND DT2.DT2_TIPOCO = '"  + StrZero(6,Len(DT2->DT2_TIPOCO)) + "' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.F.)

		If (cAlias)->(!EOF())
			cFilOco := (cAlias)->DUA_FILOCO
			cNumOco := (cAlias)->DUA_NUMOCO
			cFilDco := (cAlias)->DT6_FILDOC
			cDocDco := (cAlias)->DT6_DOC
			cSerDco := (cAlias)->DT6_SERIE
			cCHVCTE := (cAlias)->DT6_CHVCTE
			cTipOco := StrZero(6,Len(DT2->DT2_TIPOCO))
			lResult := .T.
		EndIf
		(cAlias)->(DbCloseArea())

Return lResult

/*/-----------------------------------------------------------
{Protheus.doc} TMSInfGWU()
Informações do Trecho do GWU 
Uso: TMSA360
@author Katia
@since 02/03/2020
-----------------------------------------------------------/*/
Static Function TMSInfGWU(cDUANUMOCO,cSeqOco,cCdTransp,cSeqGWU,aRecGWU,aRecGWUEnc)   

Local aAreaGWE := GWE->(GetArea())
Local cQuery   := ""
Local cAliasGWU:= ""

Default cDUANUMOCO := ""
Default cSeqOco    := ""
Default cCdTransp  := ""
Default cSeqGWU    := ""
Default aRecGWU    := {}
Default aRecGWUEnc := {}

cAliasGWU := GetNextAlias()
cQuery := " SELECT GWU_DTENT, GWU_PAGAR, GWU_CDTRP, GWU_SEQ, GWU.R_E_C_N_O_ RECNO"
cQuery += "   FROM  " + RetSqlName("GWU") + " GWU "
cQuery += "  WHERE GWU_FILIAL = '" + FwxFilial("GWU") + "' "
cQuery += "    AND GWU_CDTPDC = '" + GWE->GWE_CDTPDC + "' "
cQuery += "    AND GWU_EMISDC    = '" + GWE->GWE_EMISDC    + "' "
cQuery += "    AND GWU_SERDC  = '" + GWE->GWE_SERDC  + "' "
cQuery += "    AND GWU_NRDC  = '" + GWE->GWE_NRDC  + "' "
cQuery += "    AND D_E_L_E_T_ = ' ' "
cQuery += "  ORDER BY GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC, GWU_SEQ  " 
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGWU, .F., .T.)
TCSetField(cAliasGWU,"GWU_DTENT","D",8,0)
While (cAliasGWU)->(!Eof())	

	If (cAliasGWU)->GWU_CDTRP == cCdTransp
		If DT2->DT2_TIPOCO == StrZero( 21, Len( DT2->DT2_TIPOCO ) ) 
			If Empty((cAliasGWU)->GWU_DTENT) 			
				aRecGWU:= {}
				cSeqGWU:= (cAliasGWU)->GWU_SEQ  						  //Ultima Sequencia a ser apontada a ocorrencia por trecho no GFE	
				Aadd(aRecGWU,{ (cAliasGWU)->RECNO, cDUANUMOCO+cSeqOco })  //Recno ref a ultima sequencia
			EndIf
		Else
			cSeqGWU:= (cAliasGWU)->GWU_SEQ  //Ultima Sequencia		
		EndIf
	EndIf

	//--- Guarda os Trechos de todos Transportadores
	If DT2->DT2_TIPOCO == StrZero( 21, Len( DT2->DT2_TIPOCO ) )
		Aadd(aRecGWUEnc,(cAliasGWU)->RECNO)
	EndIf

	(cAliasGWU)->(DbSkip())
EndDo
(cAliasGWU)->(DbCloseArea())

RestArea(aAreaGWE)
Return

/*/-----------------------------------------------------------
{Protheus.doc} EstDocChk()
Estorna documentos do check-list
Uso: TMSA360
@author Caio Murakami
@since 04/05/2020
-----------------------------------------------------------/*/
Static Function EstDocChk( cFilOri , cViagem , cFilDoc , cDoc, cSerie )
Local aArea			:= GetArea()
Local cQuery		:= ""
Local cAliasQry		:= ""

Default cFilOri		:= ""
Default cViagem		:= "" 
Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""

cAliasQry	:= GetNextAlias()

cQuery	:= " SELECT  DM0_IDINTG "
cQuery	+= " FROM " + RetSqlName("DM0") + " DM0 "
cQuery	+= " WHERE DM0_FILIAL 		= '" + xFilial("DM0") + "' "
cQuery	+= " 	AND DM0_FILDOC		= '" + cFilDoc + "' "
cQuery	+= " 	AND DM0_DOC			= '" + cDoc + "' "
cQuery	+= " 	AND DM0_SERIE		= '" + cSerie + "' "
cQuery	+= " 	AND DM0.D_E_L_E_T_ 	= ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->( !Eof() )
	//-- Envia o estorno do Check List
	TMSCanChk( (cAliasQry)->DM0_IDINTG , cFilOri , cViagem  )
			
	(cAliasQry)->( dbSkip() )
EndDo
	
(cAliasQry)->( dbCloseArea() ) 

RestArea( aArea )
Return

/*/-----------------------------------------------------------
{Protheus.doc} EnvDocChk()
Envia documentos ao check-list
Uso: TMSA360
@author Caio Murakami	
@since 04/05/2020
-----------------------------------------------------------/*/
Static Function EnvDocChk( cFilOri , cViagem ,  cFilDoc , cDoc, cSerie )
Local aDocsChk		:= {}
Local aRetEnv		:= {} 

Local lTMIntEv := SuperGetMV("MV_TMINTEV",,"")
Local lCont    := .F.

Default cFilOri		:= ""
Default cViagem		:= "" 
Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""

If DTQ->DTQ_STATUS == "2"	//-- Transito
	lCont := .T.
ElseIf DTQ->DTQ_STATUS $ "5"	//-- Fechada
	If lTMIntEv == "1"	//-- Envia no Fechamento
		lCont := .T.
	EndIf
EndIf

If lCont
	//-- Busca os documentos da viagem
	aDocsChk := TMSLstChk( cFilOri , cViagem,  , cFilDoc , cDoc, cSerie )
	
	//-- Envia Check List
	aRetEnv := TMSEnvChk(Aclone(aDocsChk),cFilOri,cViagem)
EndIf

Return

/*{Protheus.doc} TMSA360Vis
Visualiza imagem do documento
@type Function
@author Valdemar Roberto Mognon
@since 21/10/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSA360Vis(cFilDoc,cDoc,cSerie)

Default cFilDoc := DUA->DUA_FILDOC
Default cDoc    := DUA->DUA_DOC
Default cSerie  := DUA->DUA_SERIE

If ValType(cDoc) == "N"
	cFilDoc := DUA->DUA_FILDOC
	cDoc    := DUA->DUA_DOC
	cSerie  := DUA->DUA_SERIE
EndIf

TMSAE71Img(cFilDoc,cDoc,cSerie)

Return

/*{Protheus.doc} TMSA360Aut
Verifica se o encerramento da viagem será automático
@type Static Function
@author Valdemar Roberto Mognon
@since 09/02/2021
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSA360Aut(cFilOri,cViagem,cCodAut,cRotina,lEncViag)
Local lRet := .T.

Default cFilOri  := ""
Default cViagem  := ""
Default cCodAut  := ""
Default cRotina  := ""
Default lEncViag := .F.

If !Empty(cFilOri) .And. !Empty(cViagem) .And. !Empty(cCodAut) .And. !Empty(cRotina)
	If ExistFunc("TmsAutViag")
		If TmsAutViag(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_CODAUT,cRotina)
			lRet := .T.
		Else
			lRet := lEncViag
		EndIf
	Else
		lRet := lEncViag
	EndIf
Else
	lRet := lEncViag
EndIf

Return lRet

/*{Protheus.doc} T360EnvMet
Envio dados da Métrica 
@type Static Function
@author Katia
@since 18/03/2021
@version 12.1.33
@Função utilizada - TMSA360 e TMSA144
*/
Function T360EnvMet(l360Auto,lChamadaExterna,nTmsOpcx)
Local lEnviaMet:= .F.

If lMetrica  
	If nTmsOpcx == 0 //Sair da rotina TMSA360
		TMSMet360( 1, , , , nTmsOpcx)  //Contabiliza o acesso da rotina 
		lEnviaMet:= .T.

	ElseIf nTmsOpcx == 3  .Or. nTmsOpcx == 4 //Apontar/Estornar
		If lChamadaExterna .Or. l360Auto  //Sair da rotina TMSA360Mnt
			TMSMet360( 1, , , , nTmsOpcx)  //Contabiliza o acesso da rotina 
			lEnviaMet:= .T.
		EndIf
	EndIf

	If lEnviaMet
		TMSMetrica("TMSA360",Iif(!l360Auto .And. !IsBlind(),"S","A"))   //Envio da Métrica A-Assincrono, S-Sincrono
	EndIf
EndIf

Return Nil


/*/{Protheus.doc} nomeFunction
	(long_description)
	@type  Function
	@author Fabio
	@since 11/08/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function T360QTDPND(cDV4_FILPND, cDV4_NUMPND, cDTC_FILDOC, cDTC_DOC, cDTC_SERIE)
	
Local lRet      := .F.
Local cQuery    := ""
Local cAliasDUU := ""
Local aArea     := GetArea()

Default cDV4_FILPND := ""
Default cDV4_NUMPND := "" 
Default cDTC_FILDOC := ""
Default cDTC_DOC    := ""
Default cDTC_SERIE  := ""

cAliasDUU:= GetNextAlias()
cQuery	:= "SELECT DUU_FILPND, DUU_NUMPND, DUU_TIPPND, DUU_FILDOC, DUU_DOC, DUU_SERIE "
cQuery	+= "  FROM " + RetSQLName("DUU") + " DUU "
cQuery	+= " WHERE DUU_FILIAL = '" + xFilial("DUU") + "' "
cQuery	+= "   AND DUU_FILPND = '" + cDV4_FILPND + "' "
cQuery	+= "   AND DUU_NUMPND = '" + cDV4_NUMPND + "' "
cQuery	+= "   AND DUU_TIPPND = '" + StrZero(2, Len(DUU->DUU_TIPPND)) +  " '"
cQuery	+= "   AND DUU_FILDOC = '" + cDTC_FILDOC + "' "
cQuery	+= "   AND DUU_DOC    = '" + cDTC_DOC + "' "
cQuery	+= "   AND DUU_SERIE  = '" + cDTC_SERIE + "' "
cQuery	+= "   AND DUU.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDUU,.F.,.T.)

If (cAliasDUU)->(!Eof())
	lRet := .T.
EndIf

(cAliasDUU)->(DbCloseArea())

RestArea(aArea)

Return lRet
