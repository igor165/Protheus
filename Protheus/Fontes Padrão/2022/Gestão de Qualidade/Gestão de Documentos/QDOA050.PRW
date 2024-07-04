#INCLUDE "COLORS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "QDOA050.CH"
#INCLUDE "TOTVS.CH"

Static cMayUse   := NIL
Static slViewOLE := NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QDOA050    ³ Autor ³ Newton R. Ghiraldelli   ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Cadastro de Documentos                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QDOA050()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ Siga Quality ( Controle de Documentos )                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacoes³ Opcao Atualizacoes + Documentos do MNU                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³  BOPS ³ Programador ³Alteracao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³04/03/02³ META  ³ Eduardo S.  ³ Alterado para visualizar Doctos no cadastro ³±±
±±³        ³       ³             ³ de Referencias.                             ³±±
±±³18/03/02³ 14283 ³ Aldo Marini ³ Alterado para prever qdo nao houver Matriz  ³±±
±±³        ³       ³             ³ de Responsabilidade Tp.Docto. (nMinResp=99) ³±±
±±³10/04/02³ META  ³ Eduardo S.  ³ Alterado para baixar Etapas tambem Aleatoria³±±
±±³        ³       ³             ³ mente e Alterado para utilizar o novo concei³±±
±±³        ³       ³             ³ to de arquivos de Usuario/Depto/Funcoes.    ³±±
±±³20/05/02³ META  ³ Eduardo S.  ³ Alterado para atualizar os lanc. de Ausencia³±±
±±³        ³       ³             ³ Temporaria na finalizacao do Documentos.    ³±±
±±³24/05/02³ xxxxx ³ Eduardo S.  ³ Acerto na Baixa Aleatoria de Doctos para nao³±±
±±³        ³       ³             ³ permitir a finalizacao da etapa qdo existir ³±±
±±³        ³       ³             ³ responsavel com o status de Inativo.        ³±±
±±³18/06/02³ xxxxx ³ Eduardo S.  ³ Alteracao no cad. responsaveis por docto per³±±
±±³        ³       ³             ³ mitindo somente delecao\alteracao das etapas³±±
±±³        ³       ³             ³ posteriores a etapa\ordem atual.            ³±±
±±³20/06/02³ META  ³ Eduardo S.  ³ Alterado para gerar aviso para Inclusao de  ³±±
±±³        ³       ³             ³ Questionario para os Responsaveis do Docto. ³±±
±±³26/06/02³ META  ³ Eduardo S.  ³ Alterado para visualizar Docto Externo.     ³±±
±±³24/08/02³ ----  ³ Eduardo S.  ³ Acerto na opcao detalhes para retornar o fil³±±
±±³        ³       ³             ³ tro original.                               ³±±
±±³04/09/02³ ----  ³ Eduardo S.  ³ Acerto para retornar corretamente o docto   ³±±
±±³        ³       ³             ³ original na consulta de referencias.        ³±±
±±³25/09/02³ 60298 ³Eduardo S.   ³ Acerto para deletar corretamente registros  ³±±
±±³        ³       ³             ³ na tabela QA4.                              ³±±
±±³16/10/02³ ----- ³Eduardo S.   ³ Acerto para apresentar corretamente o histo-³±±
±±³        ³       ³             ³ rico das revisoes.                          ³±±
±±³23/10/02³ 60606 ³Eduardo S.   ³ Acerto para validar somente itens que nao   ³±±
±±³        ³       ³             ³ estao deletados no cadastro de responsaveis.³±±
±±³03/12/02³ ----- ³Eduardo S.   ³ Alterado para listar textos(QA2) do histori-³±±
±±³        ³       ³             ³ co de revisoes apartir da funcao QA_RecTxt()³±±
±±³09/01/03³ ----- ³Eduardo S.   ³ Alterado para permitir pesquisar usuarios   ³±±
±±³        ³       ³             ³ de outras filiais no cad. de responsaveis.  ³±±
±±³24/01/03³ Meta  ³Eduardo S.   ³ Inclusao da opcao "Duplicar" no browser para³±±
±±³        ³       ³             ³ duplicar os dados de docto existente.       ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MenuDef()

Local aRotina := {	{ OemToAnsi( STR0022 ), "AxPesqui"   ,0, 1,,.F.},; // "Pesquisar"
					{ OemToAnsi( STR0004 ), "QD050Telas" ,0, 2 },; // "Visualizar"
					{ OemToAnsi( STR0005 ), "QD050Telas" ,0, 3 },; // "Incluir"
					{ OemToAnsi( STR0006 ), "QD050Telas" ,0, 4 },; // "Alterar"
					{ OemToAnsi( STR0007 ), "QD050Telas" ,0, 5 },; // "Excluir"
					{ OemToAnsi( STR0008 ), "QD050Telas" ,0, 6 },;  //"Cancelar"
					{ OemToAnsi( STR0129 ), "QD050Dupli" ,0, 6 },; // "Duplicar"
					{ OemToAnsi( STR0122 ), "QD050GerRv" ,0, 6 },; // "Gera Revisao"
					{ OemToAnsi( STR0003 ), "QD050MsDet" ,0, 6 },; // "Detalhe"
					{ OemToAnsi( STR0096 ), "QD050Legen" ,0, 6,,.F.}}  // "Legenda"

Return aRotina

Function QDOA050()

Local aCores := {}
Local aRotAdic:={}

Private aRotina      := MenuDef()
Private aUsrMat      := QA_USUARIO()
Private bBlock       :={|| ""}
Private cCadastro    := OemToAnsi( STR0001 ) // "Cadastro de Documentos"                	
Private cMatCod      := aUsrMat[3]
Private cMatDep      := aUsrMat[4]
Private cMatFil      := aUsrMat[2]
Private lFinalDoc    := .F. // Variavel utilizada para verificar se já foi solicitado a finalização do Documento
Private lGerRev      := .F.
Private lNoCancel    := .T.
Private lNoDelTmp    := .F. // Variavel utilizada para identificar que o usuário não quer deletar o arquivo no Temporarios na tela de Divergencia
Private lSobDocTmp   := .F. // Variavel utilizada para verificar se já foi dada  alguma opção na tela de sobrescrever
Private lSolicitacao := .f.
Private lTrat        := GetMv("MV_QDOQDG",.T.,.F.)
Private nOrdTela     := 1 // Ordem Atual da tela

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta filtro para mbrowse com a seguinte caracteristica:                        ³
//³                                                                                 ³
//³ - Documentos nao obsoletos, nao cancelados e distribuidos     - box verde       ³
//³   ( Documentos ativos em status de leitura )                                    ³
//³ - Documentos nao obsoletos, nao cancelados e nao distribuidos - box amarelo     ³
//³   ( Em elaboracao )                                                             ³
//³ - Documentos osoletos ou nao, cancelados e nao distribuidos   - box preto       ³
//³   ( Em processo de cancelamento )                                               ³
//³ - Documentos obsoletos, nao cancelados e distribuidos         - box vermelho    ³
//³   ( Documento obsoleto ainda ativo, durante procedimento de implantacao da      ³
//³     revisao atual conforme quantidade de dias de transicao limite definidos     ³
//³     em QDH_DTLIM )                                                              ³
//³ Documentos cancelados e distribuidos e documentos obsoletos posteriores a data  ³
//³ de implantacao sao filtrados para nao aparecer no browse.                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("QDH")
DbSetorder(nOrdTela)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
//³ Ponto de Entrada - para desconsiderar o filtro e apresentar o botao "Filtro" na ³
//³ barra de opcoes.                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "QD050FIL" )
		If !ExecBlock( "QD050FIL", .F., .F. )
 			Set Filter to &(Qd050Filtro())
		Endif
	Else
		Set Filter to &(Qd050Filtro())
	Endif

DbGotop()

aCores  := {	{'Qd050DstPd()','BR_AZUL' },;
				{'QDH->QDH_OBSOL == "N" .And. QDH->QDH_STATUS == "L  " .And. QDH->QDH_CANCEL <> "S"','ENABLE' },;
				{'QDH->QDH_OBSOL == "N" .And. QDH->QDH_STATUS <> "L  " .And. QDH->QDH_CANCEL <> "S"','BR_AMARELO'},;
				{'QDH->QDH_CANCEL = "S" .And. QDH->QDH_STATUS <> "L  " ','BR_BRANCO'},; 
				{'QDH->QDH_CANCEL = "S" ','BR_PRETO'},;
				{'QDH->QDH_OBSOL == "S" .And. QDH->QDH_CANCEL <> "S"','DISABLE'}}    

	If ExistBlock( "QDOAP27" )
		DbSetorder(ExecBlock( "QDOAP27", .f., .f.))
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	                                .	.
//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QD050ROT")
		aRotAdic := ExecBlock("QD050ROT", .F., .F.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic,{|x| AAdd(aRotina,x)})
		EndIf
	EndIf

dbSelectArea("QDH")

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( "QDH" )
oBrowse:SetDescription( cCadastro ) // "Cadastro de Documentos" 

If !ExistBlock( "QD050FIL" ) .Or. !ExecBlock( "QD050FIL", .F., .F. )
	oBrowse:SetFilterDefault( Qd050Filtro() )
EndIf	

oBrowse:AddLegend( 'Qd050DstPd()',                                                                      'BR_AZUL',    STR0131) // "Documento em fase de Distribuicao"
oBrowse:AddLegend( 'QDH->QDH_OBSOL == "N" .And. QDH->QDH_STATUS == "L  " .And. QDH->QDH_CANCEL <> "S"', 'ENABLE',     STR0092) // "Documento Normal/Em Leitura"
oBrowse:AddLegend( 'QDH->QDH_OBSOL == "N" .And. QDH->QDH_STATUS <> "L  " .And. QDH->QDH_CANCEL <> "S"', 'BR_AMARELO', STR0094) // "Documento em fase de Elaboracao"
oBrowse:AddLegend( 'QDH->QDH_CANCEL = "S" .And. QDH->QDH_STATUS <> "L  " ',                             'BR_BRANCO',  STR0170) // "Documento em cancelamento"
oBrowse:AddLegend( 'QDH->QDH_CANCEL = "S" ',                                                            'BR_PRETO',   STR0095) // "Documento cancelado"
oBrowse:AddLegend( 'QDH->QDH_OBSOL == "S" .And. QDH->QDH_CANCEL <> "S"',                                'DISABLE',    STR0093) // "Documento Obsoleto"
oBrowse:Activate()

DbSelectArea("QDH")
Set Filter To      

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QD050Telas ³Autor³ Newton R. Ghiraldelli³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta a tela padrao para cadastro de documentos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD050Telas( ExpC1,ExpN1,ExpN2 )                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do Arquivo                                  ³±±
±±³          ³ ExpN1 - Registro Atual                                    ³±±
±±³          ³ ExpN2 - Opcao de selecao do aRotina                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050Telas(cAlias,nReg,nOpc,lSolit,cInterno)

Local aAreaQDH    := {}
Local aArquivos   := {}
Local aCargTxt    := {}
Local aCpos       := {}
Local aData		  := {}
Local aDiretorio  := {}
Local aQDdup      := {}
Local aQPath      := QDOPATH()
Local aRegs       := {}
Local aTipoTxt    := {"OBJ     ","TXT     ","COM     ","REV     ","SUM     ","CRI     ","CRT     ","ITA     ","RED     "} 
Local aUsrMat     := QA_USUARIO()
Local bCancel     := Nil
Local bCbt        := Nil
Local bOk         := Nil
Local bSet15      := Nil
Local bSet24      := Nil
Local cArqTmp     := ""
Local cBtnItnAlt  := GetMV("MV_QBITALT") // Especifico da Johnson
Local cCodAlt     := ""
Local cCpoSup     := "QDH_DEPTOE"
Local cExpFilt    := ""
Local cExt        := ".CEL"
Local cFld        := ""
Local cMvSave     := QDOPswOLE() // "Verifica se insere senha ou nao
Local cQArqTmp    := ""
Local cQPath      := aQPath[1] 
Local cQPathHtm   := aQPath[5] 
Local cQPathTrm   := aQPath[3] 
Local cSiSolCEL   := ""
Local cSvFilAnt   := cFilAnt 
Local cTexto	  := ""
Local cTituloCad  := ""
Local cUltRev     := ""
Local l050Del     := (ExistBlock("Q050DEL"))
Local lApelido    := aUsrMat[1] 
Local lAprovador  := .F.
Local lBtnSol     := .T.
Local lCpyS2T     := .F.
Local lDigitador  := .T.
Local lDocDupli   := .F. //  Variavel utilizada no Ponto de Entrada QDOFINAL
Local lElaborador := .F.
Local lExecuta    := .T.
Local lFimbQAD    := .T.
Local lPen        := .F.
Local lRet        := .F.
Local lSiSol      := .F. //Variavel de Solicitacao de Documento novo
Local lSol        := .F.
Local nC          := 0
Local nDirHtml    := 0
Local nI          := 0
Local nLoATxt     := 0
Local nOpcant     := 0
Local nOpcao      := 0
local nPosCanc    := 0
Local nPosDir     := 0
Local nPosQDH     := QDH->(Recno())
Local nPosREV	  := 0
Local nT          := 0
Local oBtn01      := NIL
Local oBtn02      := NIL
Local oBtn03      := NIL
Local oBtn04      := NIL
Local oBtn05      := NIL
Local oBtn06      := NIL
Local oBtn07      := NIL
Local oBtn08      := NIL
Local oBtn09      := NIL
Local oBtn10      := NIL
Local oBtn11      := NIL
Local oBtn12      := NIL
Local oBtn13      := NIL
Local oBtn14      := NIL
Local oBtn15      := NIL
Local oFolder     := NIL
Local oFont       := NIL
Local oSayM       := NIL
Local oWordTmp    := NIL

Default lSolit    := .F.

Private aArrayBt    := {}
Private aButtons    := {}
Private aCols       := {}
Private aGets[0]
Private aHeader     := {}
Private aHedDoc     := {}
Private aQABDoc     := {}
Private aQD0Doc     := {}
Private aQD4Doc     := {}
Private aQD4Ini     := {}
Private aQD6Doc     := {}
Private aQDBDoc     := {}
Private aQDGDoc     := {}
Private aQDJDoc     := {}
Private aQDRDoc     := {}
Private aQDVDoc     := {}
Private aQDZDoc     := {}
Private aTela[0][0]
Private aTxtREsul   := {}
Private aUsrMail    := {} // Variavel publica para envio de e-mail
Private bCampo      :={|nCPO| Field( nCPO ) }
Private cCampo      := ""
Private cChave      := ""
Private cCodApDes   := Space(06)
Private cCodApSol   := Space(06)
Private cDtEmiss    := CtoD(" / / ", "DDMMYY" )
Private cFilApDes   := Space(FWSizeFilial()) //Space(02)
Private cFilApSol   := Space(FWSizeFilial()) //Space(02)
Private cFilDep     := xFilial("QAD") // Utilizada no SXB
Private cFilMat     := cFilAnt //
Private cMatCod     := aUsrMat[3] //
Private cMatDep     := aUsrMat[4] //
Private cMatFil     := aUsrMat[2] //
Private cNomFilial  := Space(40)
Private cOLD_DATA   := ""
Private cOld_Docto  := ""
Private cOld_Rv     := ""
Private cQDH_DTOIE  := ""
Private cTpCopia    := OemToAnsi(STR0002) // "C¢pia Controlada"
Private lAltDoc     := .t.
Private lColsQDV    := .F.
Private lCritica    := .f.
Private lDocExtOK   := .F.
Private lduDupDe    := .F.
Private lDuplDoc    := .F.
Private lEditou     := .F.
Private lExcExt     := .F.
Private lGeraRev    := .f.
Private lIncDepois  := .f.
Private lNoExc      := .F.
Private lPendencia  := .f.
Private lQdReva     := GetMv("MV_QDREVAL",.F.,"1")=="1" //Define o Uso da Rotina de Revalidacao 1=SIM 2=NAO 
Private lSalvaWhtml := .F.
Private lView       := GetMv("MV_QDVIEW")
Private lVisu       := .F.
Private lWhenIE     := .T.
Private nPosAut     := 0
Private nPosCod     := 0
Private nPosDep     := 0
Private nPosFil     := 0
Private nPosOrd     := 0
Private nUso        := 0
Private nValRefDoc  := GetMV("MV_QREFDC",.F.,1)
Private oDlgFolder  := NIL
Private oGetDoc     := NIL
Private oWord       := NIL


	If ValType(nValRefDoc) == "C"
		nValRefDoc := 1
	EndIf

	If Alltrim(Funname()) <> "QDOA050"
		Private lNoDelTmp   := .F. // Variavel utilizada para identificar que o usuário não quer deletar o arquivo no Temporarios na tela de Divergencia
		Private lSobDocTmp  := .F. // Variavel utilizada para verificar se já foi dada  alguma opção na tela de sobrescrever
	EndIf

	nOrdTela   := QDH->(IndexOrd())

	If Type("lRevisao") <> "L"
		Private lRevisao:= .F.
	Endif

	If Type("lPendBai") == "U"
		lPendbai := .F.
	EndIf


lClose:= .F.

DbSelectArea("QAA")
QAA->(DbSetOrder(1))
DbSelectArea("QAD")
QAD->(DbSetOrder(1))
DbSelectArea("QA2")
QA2->(DbSetOrder(1))
DbSelectArea("QD0")
QD0->(DbSetOrder(1))
DbSelectArea("QD1")
QD1->(DbSetOrder(1))
DbSelectArea("QD2")
QD2->(DbSetOrder(1))
DbSelectArea("QD3")
QD3->(DbSetOrder(1))
DbSelectArea("QD4")
QD4->(DbSetOrder(1))
DbSelectArea("QD5")
QD5->(DbSetOrder(1))
DbSelectArea("QDB")
QDB->(DbSetOrder(1))
DbSelectArea("QDD")
QDD->(DbSetOrder(1))
DbSelectArea("QDG")
QDG->(DbSetOrder(1))
DbSelectArea("QDJ")
QDJ->(DbSetOrder(1))
DbSelectArea("QDS")
QDS->(DbSetOrder(1))
				
DbSelectArea("QDH")
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Solicitacao de Documento novo Com TIPO e .CEL/DOT  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF nOpc==10
		nOpcAnt := nOpc
		lSiSol	:= .T.
		Inclui  := .T.
		nOpc    := 3
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Duplicacao de Documento             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 9
		lDocDupli := .T.	//  Variavel utilizada no Ponto de Entrada QDOFINAL
		lDuplDoc := .T.
		Inclui   := .T. 
		nOpc     := 3
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da Soliciacao de Alteracao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 8
		lSol  := .T.
		nOpc  := 2
		Inclui:= .F.
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se lApelido( indica se o apelido do usuario e igual ao do configurador ) ³
//³ permite utilizar ou nao a rotina                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lApelido
		If nOpc <> 2
			Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
			QDH->(DBSetOrder(nOrdTela))
			QDH->(DbGoto(nPosQDH))
			Return 0
		EndIf
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Consulta Documentos Vencido       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 2 .AND. ( !Empty( QDH->QDH_DTLIM ) .And. QDH->QDH_DTLIM < dDataBase ) .And. !VerSenha(98) .AND. AllTrim(QDH->QDH_STATUS) == "L"
		MsgAlert(OemToAnsi(STR0168),OemToAnsi(STR0026)) //"Usuario nao pode visualizar documento vencido
		QDH->(DBSetOrder(nOrdTela))
		QDH->(DbGoto(nPosQDH))
		Return 0
	EndIf

	If Existblock("QD50MSGAD")
		Execblock("QD50MSGAD",.F.,.F.)
	Endif

	If nOpc <> 3
		For nI:= 1 To FCount()
			M->&(Eval(bCampo,nI)):= FieldGet(nI)
		Next nI
	Else
		For nI:= 1 To FCount()
		M->&(Eval(bCampo,nI)):= FieldGet(nI)
		lInit := .F.
			If ExistIni(Eval(bCampo,nI))
				lInit := .T.
				M->&(Eval(bCampo,nI)):= InitPad(GetSx3Cache(Eval(bCampo,nI),"X3_RELACAO"))
				If ValType(M->&(Eval(bCampo,nI))) == "C"
					M->&(Eval(bCampo,nI)):= Padr(M->&(Eval(bCampo,nI)),GetSx3Cache(Eval(bCampo,nI),"X3_TAMANHO"))
				EndIf
				If M->&(Eval(bCampo,nI)) == NIL
					lInit := .F.
				EndIf
			EndIf
			If !lInit
				If ValType(M->&(Eval(bCampo,nI))) == "C"
					M->&(Eval(bCampo,nI)):= Space(Len(M->&(Eval(bCampo,nI))))
				ElseIf ValType(M->&(Eval(bCampo,nI))) == "N"
					M->&(Eval(bCampo,nI)):= 0
				ElseIf ValType(M->&(Eval(bCampo,nI))) == "D"
					M->&(Eval(bCampo,nI)):= Ctod("  /  /  ", "DDMMYY")
				ElseIf ValType(M->&(Eval(bCampo,nI))) == "L"
					M->&(Eval(bCampo,nI)):= .F.
				EndIf
			EndIf
		Next nI
		M->QDH_FILIAL := xFilial("QDH")
		M->QDH_DESCTP := ""
	EndIf

	If  cFilAnt <> M->QDH_FILIAL .AND. !Empty(AllTrim(xFilial("QDH")))
		cFilAnt	   := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV

		aQPath     := QDOPATH()
		cQPath     := aQPath[1]
		cQPathTrm  := aQPath[3]
		cQPathHtm  := aQPath[5]

		cFilAnt    := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Solicitacao de Documento novo Com TIPO e .CEL/DOT  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lSiSol
		IF !Empty(QDP->QDP_CODTP)
			M->QDH_CODTP	:=QDP->QDP_CODTP
			If ExistTrigger("QDH_CODTP")
				RunTrigger(1) //Executa Gatilhos Primarios e Armazena Estrangeiros 			
				M->QDH_NDEPTO:=QA_NDEPT(M->QDH_DEPTOD,.T.,M->QDH_FILDEP)
				EvalTrigger() //Executa Gatilhos Estrangeiros              		         											
			Endif
		CHKSEQDOC()                                                     
					
			If nOpcAnt == 10 .and. QDP->QDP_DTOBAS <> ' '
		    	cSiSolCEL := StrZero(Val(QA_SEQU("DOCEXT",6,"N")),6)+SubStr(StrZero(year(dDataBase),4),3,2)
				While File(cQPath+cSiSolCEL)
					cSiSolCEL:= StrZero(Val(QA_SEQU("DOCEXT",6,"N")),6)+SubStr(StrZero(year(dDataBase),4),3,2)
				EndDo
				IF QDOCLExt(QDP->QDP_DTOBAS) == 0 // Arquivo nao tem extensao
					M->QDH_NOMDOC:= "DOCEXT"+Alltrim(Str(Day(Date())))+Alltrim(Str(Month(Date())))+Alltrim(Str(Year(Date())))
				Else
					cTexto  := cSiSolCEL+SubStr(QDP->QDP_DTOBAS,QDOCLExt(QDP->QDP_DTOBAS))
					__CopyFile(cQPath+QDP->QDP_DTOBAS,cQPathTrm+cTexto)
   
					If !File(cQPathTrm+cTexto)
			      		Help(" ",1,"QD_DOCNEXT")
					EndIf
					M->QDH_NOMDOC:= cTexto
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³CRIA O CODIGO DO .CEL³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cSiSolCEL := STRZERO( VAL( QA_SEQU( "QDH", 6, "N" ) ), 6 )  + SubStr( StrZero( year( dDataBase ), 4 ),3 ,2 ) + ".CEL"
				While File( cQPath + cSiSolCEL )
					cSiSolCEL := STRZERO( VAL( QA_SEQU( "QDH", 6, "N" ) ), 6 )  + SubStr( StrZero( year( dDataBase ), 4 ),3 ,2 ) + ".CEL"
				EndDo
			
				//ÚÄÄÄÄÄÄÄÄÄÄ¿
				//³CRIA O CEL³
				//ÀÄÄÄÄÄÄÄÄÄÄÙ
				__CopyFile(cQPath+QDP->QDP_DTOBAS,cQPath+cSiSolCEL)
			
				If !File(cQPath+cSiSolCEL)
					Help( " ", 1, "QDCDOCERR" )
				Else
					M->QDH_NOMDOC:=cSiSolCEL
				Endif
			EndIf
		Endif
	Endif

	If lDuplDoc
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza variaveis com dados do Docto origem. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI:= 1 To FCount()
			M->&(Eval(bCampo,nI)):= aDuplDoc[1][nI]
		Next nI

		IF ExistBlock("QDOAP36")
			aQDdup := ExecBlock( "QDOAP36", .F., .F.,{M->QDH_DOCTO,M->QDH_RV})
			M->QDH_DOCTO := aQDdup[1]
			M->QDH_RV    := aQDdup[2]
		Else
			M->QDH_DOCTO := Space(TamSx3("QDH_DOCTO")[1])
			M->QDH_RV    := Space(TamSx3("QDH_RV")[1])   
		Endif
	
		M->QDH_REVINV:= Space(TamSx3("QDH_REVINV")[1])   
		M->QDH_NOMDOC:= Space(TamSx3("QDH_NOMDOC")[1])
		M->QDH_CHAVE := " "
		M->QDH_DESCTP:= QDXFNANTPD(M->QDH_CODTP,lDuplDoc,M->QDH_FILIAL) //DESC TIPO
		M->QDH_DESCAS:= LEFT(QDXFNANASS(M->QDH_CODASS,.T.),30)          //DESC AS GERAL
		M->QDH_NDEPTO:= Qa_nDept( M->QDH_DEPTOD, .t., M->QDH_FILDEP )   //DEPTO DISTRIBUIDOR
		IF !EMPTY(M->QDH_NORMA)
			M->QDH_DESNOR:= QA_NORMA(M->QDH_NORMA,.F.)
		ENDIF

		M->QDH_DTGERA   := dDataBase
		M->QDH_DTIMPL 	:= CTOD("  /  /  ","DDMMYY")
		M->QDH_DTVIG  	:= CTOD("  /  /  ","DDMMYY")
		M->QDH_DTLIM  	:= CTOD("  /  /  ","DDMMYY")
		M->QDH_DTCAD 	:= dDataBase
		M->QDH_HORCAD	:= SubStr(TIME(),1,5)
		M->QDH_OBSOL 	:= "N"
	EndIf
	If Existblock("QD50FLAG")
		Execblock("QD50FLAG",.F.,.F.)
	Else
		If nOpc <> 2
			QD50AJQD0(M->QDH_FILIAL,M->QDH_DOCTO,M->QDH_RV)
		Endif
	Endif

	If !Empty(AllTrim(M->QDH_NOMDOC)) .AND. Substr(M->QDH_STATUS,1,1) $ "E,D,R" .AND. !QD50VDOCT(cQPath, cQPathTrm, M->QDH_NOMDOC) // Verifico se existe o documento
		M->QDH_NOMDOC:= Space(32)
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Atualizacao dos arrays dos sub-cadastros e  dos Departamentos Destinatarios  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LjMsgRun(OemToAnsi(STR0009),OemtoAnsi(STR0079),{|| QDO050CARR(nOpc) ,lFimbQAD:=QD050CDEST(lDuplDoc,nOpc) }) // "Selecionando Documentos" ### "Aguarde..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a integridade da base do responsavel do QAD  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !lFimbQAD
		QDH->(DBSetOrder(nOrdTela))
		Return 0
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se ja existe usuario alterando o Documento.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 4 .And. Substr(M->QDH_STATUS,1,1) $ "E,R,A,H"
		If !SoftLock("QDH")
			QDH->(DBSetOrder(nOrdTela))
			QDH->(DbGoto(nPosQDH))
			Return 0
		EndIf
	EndIf

// Para processos com a Tabela exclusiva, critica deve ser gravada com a filial do usuário pois na  recuperacao 
// eu uso a filial do QD4_FILMAT
	If !(AllTrim(Str(nOpc)) $ "3|7") .And. !Empty(Alltrim(xFilial("QA2"))) .AND. QDH->QDH_FILMAT <> xFilial("QA2")
		cFilAnt := QDH->QDH_FILMAT //Mudo a Variavel publica de Memória como na SuperGetMV	
	EndIf
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega todos os textos Existentes QA2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !EMPTY(M->QDH_CHAVE)
		FOR nI:=1 To Len(aTipoTxt)
			IF Alltrim(aTipoTxt[nI])!="CRI"
				nLoATxt:=ASCAN(aTxtREsul,{|X| x[1]==aTipoTxt[nI] .AND. X[2]==M->QDH_CHAVE})
				IF nLoATxt==0
					aCargTxt:=QA_RecTxt(M->QDH_CHAVE,aTipoTxt[nI])
					IF Alltrim(aCargTxt)!=""
			    		AADD(aTxtREsul,{aTipoTxt[nI],M->QDH_CHAVE, {{1,aCargTxt}},QDH->QDH_CHAVE,nOpc,nReg,""} )	   		 
			    		aCargTxt:=""
					Endif
				Endif
			Else
				QD4->(DbSetOrder(1))
				IF QD4->(DbSEEK(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV))
					While QD4->(!EOF()) .AND. M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV == QD4->QD4_FILIAL+QD4->QD4_DOCTO+QD4->QD4_RV
						nLoATxt:=ASCAN(aTxtREsul,{|X| x[1]==aTipoTxt[nI] .AND. X[2]==QD4->QD4_CHAVE})
						IF nLoATxt==0
							aCargTxt:=QA_RecTxt(QD4->QD4_CHAVE,aTipoTxt[nI])						   				   
							IF Alltrim(aCargTxt)!=""
					    		AADD(aTxtREsul,{aTipoTxt[nI],QD4->QD4_CHAVE, {{1,aCargTxt}},QDH->QDH_CHAVE,nOpc,nReg,""} )	   		 
					    		aCargTxt:=""
							Endif
						Endif
			    		QD4->(DbSkip())
					Enddo
				Endif
			Endif
		NEXT nI
	ENDIF

	If !(AllTrim(Str(nOpc)) $ "3|7") .And. !Empty(AllTrim(xFilial("QA2"))) .AND. QDH->QDH_FILMAT <> cSvFilAnt
		cFilAnt := cSvFilAnt //Mudo a Variavel publica de Memória como na SuperGetMV	
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inclusao / Alteracao de Documento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3 .Or. nOpc == 4
		lAltDoc:= .T.
		If M->QDH_STATUS $ "DC ,EC "
			lCritica := .T.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Visualizacao / Alteracao / Cancelamento de Documento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 2 .Or. nOpc == 4 .Or. nOpc == 6
		If nOpc == 2
			lAltDoc:= .F.
		EndIf
		If nOpc == 4
			If M->QDH_OBSOL = "S"
				Help(NIL, NIL, STR0178, NIL, STR0179, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0180}) //###"Documento obsoleto" ###"Este documento está obsoleto." ###"Escolha outro documento ou gere uma revisão."
				QDH->(DBSetOrder(nOrdTela))
				QDH->(DbGoto(nPosQDH))
				Return 0
			EndIf
			If M->QDH_STATUS == "I  "
				Help(" ",1,"QDSTATDIST") // "Documento em Fase de Distribuicao, Utilize a opcao Distribuicao do menu principal"
				QDH->(DBSetOrder(nOrdTela))
				QDH->(DbGoto(nPosQDH))
				Return 0
			EndIf
			If M->QDH_STATUS == "L  "
				Help(" ",1,"QDSTATLEIT") // "Documento em status de Leitura. Utilize a op‡„o Visualizar"
				QDH->(DBSetOrder(nOrdTela))
				QDH->(DbGoto(nPosQDH))
				Return 0
			EndIf
		EndIf
		If nOpc == 6
			M->QDH_STATUS:= "D  "
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o documento esta disponivel para o usuario atual ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !QD050LiDoc(nOpc)
			MsgAlert(OemToAnsi(STR0025),OemToAnsi(STR0026)) // "Documento n„o liberado" ### "Aviso"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Desbloqueia o Arquivo QDH  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc == 4 .And. Substr(M->QDH_STATUS,1,1) $ "E,R,A,H"
				QDH->(MsUnlock())
			EndIf
			QDH->(DBSetOrder(nOrdTela))
			QDH->(DbGoto(nPosQDH))
			Return 0
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se pode Alterar Documento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc <> 6
			If !QD050AltDc(nOpc)
				lAltDoc := .F.
			EndIf
		Endif
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclusao de Documento              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 5
		lAltDoc   := .F.
		If QDH->QDH_STATUS $ "L  "
			Help(" ",1,"QD050NEDSL") // "Nao podera ser feito a exclusao do Documento em fase de Leitura"
			QDH->(DBSetOrder(nOrdTela))
			QDH->(DbGoto(nPosQDH))
			Return 0
		EndIf
		If !(QDH->QDH_STATUS $ "D  ,DC ,E  ,EC ,A  ")
			MsgAlert(OemToAnsi(STR0025),OemToAnsi(STR0026)) // "Documento n„o liberado" ### "Aviso"
			QDH->(DBSetOrder(nOrdTela))
			QDH->(DbGoto(nPosQDH))
			Return 0
		EndIf
		lDigitador:= .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se situacao do Documeto eh digitacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QDH->QDH_STATUS == "D  "
			lDigitador := .T.
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe elaboradores cadastrados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QD0->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+"E"))
			While !QD0->(Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV+QD0->QD0_AUT == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+"E"
				If QD0->QD0_FLAG == "I" .And. QDH->QDH_OBSOL <> "S"
					QD0->(DbSkip())
					Loop
				EndIf
				If cMatFil+cMatCod+cMatDep == QD0->QD0_FILMAT+QD0->QD0_MAT+QD0->QD0_DEPTO
					lElaborador:= .T.
				Exit
				EndIf
				QD0->(DbSkip())
			EndDo
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe Aprovadores cadastrados  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QD0->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+"A"))
			While !QD0->(Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV+QD0->QD0_AUT == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+"A"
				If QD0->QD0_FLAG == "I" .And. QDH->QDH_OBSOL <> "S"
					QD0->(DbSkip())
					Loop
				Endif
				If cMatFil+cMatCod+cMatDep == QD0->QD0_FILMAT+QD0->QD0_MAT+QD0->QD0_DEPTO
					lAprovador := .t.
					Exit
				EndIf
				QD0->(DbSkip())
			Enddo
		EndIf
		
		cCodAlt := fBuscQD5(QDH->QDH_DOCTO, QDH->QDH_RV, cMatCod) //Chamada da função que retorna QD5_ALT 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se usuario logado não estiver com QD5_ALT == 'S' não libera a exclusão                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !cCodAlt == "S" .Or. Empty(cCodAlt) .And. AllTrim(cMatCod) == AllTrim(QDH->QDH_MAT)
			MsgAlert(OemToAnsi(STR0025),OemToAnsi(STR0026)) // "Documento nao liberado" ### "Aviso"
			QDH->(DBSetOrder(nOrdTela))
			QDH->(DbGoto(nPosQDH))
			Return 0
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se pode Alterar Documento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !QD050AltDc(nOpc) .And. !Empty(cCodAlt) .And. AllTrim(cMatCod) == AllTrim(QDH->QDH_MAT)
			MsgAlert(OemToAnsi(STR0025),OemToAnsi(STR0026)) // "Documento nao liberado" ### "Aviso"
			QDH->(DBSetOrder(nOrdTela))
			QDH->(DbGoto(nPosQDH))
			Return 0
		EndIf

		aArquivos := {{"QD0",1},{"QD4",1},{"QDG",1},{"QD1",1},{"QDE",1},{"QD7",1},{"QD6",1},{"QDB",1},{"QDA",1},{"QDN",1}}
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inclusao / Nova Revisao de Documento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3 .Or. nOpc == 7
		M->QDH_CANCEL:= "N"
		M->QDH_FILMAT:= cMatFil
		M->QDH_MAT   := cMatCod 
		M->QDH_DEPTOE:= cMatDep
		M->QDH_STATUS:= "D  "
		M->QDH_CHAVE := " " 
		IF VALTYPE( cInterno ) == "C" 
			M->QDH_DTOIE := cInterno
		ENDIF

		if nopcant == 10 .and. QDP->QDP_DTOBAS <> ' '
			M->QDH_DTOIE := cInterno
			lWhenIE:=.F.
		EndIf
		If nOpc == 7
			lSol:= .T.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Acerta proximo numero de Revisao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If	!QDXFNCkSRv("QDH",nOpc,Nil,Nil,Iif(lSolit,"SAD",Nil))
				Set Filter to &(Qd050Filtro())
				QDH->(DbGoto(nPosQDH))
				Return 0
			EndIf
			If PROCNAME(2)== "QD052GRVBX"
				QD050EdTxt("REV",nOpc)
			Endif
		EndIf
	EndIf
	If nOpc == 7
		nPosREV := aScan(aTxtResul, {|x| AllTrim(Upper(x[1])) == "REV"})
		If nPosREV == 0 .OR. Empty(aTxtResul[nPosREV][3][1][2])
			Help(" ",1,"QD050MOTRV") // "O campo motivo da revisao e obrigatorio."
			QDH->(DBSetOrder(nOrdTela))
			QDH->(DbGoto(nPosQDH))
			Return 0
		EndIf
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for solicitacao de modificacao ( Especifico ) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSolicitacao
		M->QDH_DOCTO := cSolDocto
		M->QDH_RV    := "000"
		M->QDH_REVINV:= INVERTE(M->QDH_RV)
		lSolicitacao:= .f.
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cancelamento de documento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 6
		IF M->QDH_CANCEL=="S"
			MsgAlert(OemToAnsi(STR0025),OemToAnsi(STR0026)) // "Documento n„o liberado" ### "Aviso"
			QDH->(DBSetOrder(nOrdTela))
			Return 0
		ENDIF
		If !( QDH->QDH_OBSOL == "N" .And. QDH->QDH_STATUS == "L  " .And. QDH->QDH_CANCEL <> "S" )
			MsgStop(OemToAnsi(STR0165),OemToAnsi(STR0023)) // "Documento nao esta em fase de Leitura! Nao sera possivel realizar a opera‡„o!" ### "Aten‡„o"	
			QDH->(DBSetOrder(nOrdTela))
			QDH->(DbGoto(nPosQDH))
		Return 0
		Endif
		aAreaQDH := QDH->(GetArea())
  		QDH->(dbSetOrder(6))
		If QDH->(dbSeek(xFilial("QDH")+M->QDH_DOCTO))
			If QDH->QDH_RV <> M->QDH_RV
				MsgStop(OemToAnsi(STR0166),OemToAnsi(STR0023)) // "Este documento possui revisão, não poderá ser cancelado !" ### "Aten‡„o"
				QDH->(DBSetOrder(nOrdTela))
				QDH->(DbGoto(nPosQDH))
				Return 0
			Endif
		Endif
		QDH->(RestArea(aAreaQDH))
		If !MsgYesNo(OemToAnsi(STR0082),OemToAnsi(STR0023)) // "Confirma Cancelamento deste Documento?" ### "Aten‡„o"
			QDH->(DBSetOrder(nOrdTela))
			QDH->(DbGoto(nPosQDH))
			Return 0
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acerta proximo numero de Revisao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !QDXFNCkSRv("QDH",nOpc,QDH->(Recno()),.T.,"SAD")
			MsgAlert(OemToAnsi(STR0027),OemToAnsi(STR0023)) // "Nao foi poss¡vel realizar a opera‡„o" ### "Aten‡„o"
			Set Filter to &(Qd050Filtro())
			QDH->(DbGoto(nPosQDH))
			Return 0
		EndIf
	
		QD050EdTxt("REV",nOpc)  //chama o campo para digitação do motivo da revisão
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclui Motivo Rev. no Cancelamento  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Ascan(aTxtREsul,{|x| alltrim(x[1])="REV" }) == 0
			Help(" ",1,"QD050MOTRV") // "O campo motivo da revisao e obrigatorio."
			QDH->(DBSetOrder(nOrdTela))
			QDH->(DbGoto(nPosQDH))
			Return 0
		EndIf
		M->QDH_CANCEL := "S"
	EndIf

	If nOpc == 2
		cTituloCad:= OemToAnsi(STR0004) // "Visualizar"
	ElseIf nOpc == 3
		cTituloCad:= OemToAnsi(STR0005) // "Incluir"
	ElseIf nOpc == 4
		cTituloCad:= OemToAnsi(STR0006) // "Alterar"
	ElseIf nOpc == 5
		cTituloCad:= OemToAnsi(STR0007) // "Excluir"
	ElseIf nOpc == 6
		cTituloCad:= OemToAnsi(STR0008) // "Cancelar"
	ElseIf nOpc == 7
		cTituloCad:= OemToAnsi(STR0122) // "Gera Revisao"
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New()

oSize:AddObject( "FOLDER"   ,  100, 100, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  
DEFINE MSDIALOG oDlgFolder FROM oSize:aWindSize[1],oSize:aWindSize[2];
							 TO oSize:aWindSize[3],oSize:aWindSize[4]  STYLE nOr(DS_MODALFRAME,WS_POPUP,WS_CAPTION) TITLE cCadastro+" - "+cTituloCad OF oMainWnd PIXEL
                            
@ 015,000 FOLDER oFolder PROMPTS OemToAnsi(STR0018),OemToAnsi(STR0019) SIZE 317,147 OF oDlgFolder PIXEL // "Documentos" ###  "Op‡”es"
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botoes definidos apenas para o folder nao perder o Foco na troca de Folders     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON FROM 5000,5000 TYPE 6 ACTION .T. ENABLE OF oFolder:aDialogs[1] // botao oculto Folder 1
DEFINE SBUTTON FROM 5000,5000 TYPE 6 ACTION .T. ENABLE OF oFolder:aDialogs[2] // botao oculto Folder 2

oFolder:bChange := {|| IF(QDO050ChFo(oFolder:nOption,lDuplDoc),"",oFolder:nOption:=1) } 
dbSelectArea("QDH")
aCpos := {}
For nI:= 1 to FCount()
    cFld := Alltrim(FieldName(nI))
    If cFld <> Alltrim(cCpoSup)
        AADD(aCpos,cFld)
    EndIf
Next

oGetDoc:=MsMGet():New("QDH",nReg,If(nOpc == 7,3,nOpc),,,,,{oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI"),oSize:GetDimension("ENCHOICE","LINEND"),oSize:GetDimension("ENCHOICE","COLEND")},aCpos,,,,,oFolder:aDialogs[1])
oGetDoc:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Objetivo						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 010,020 BTNBMP oBtn01 RESOURCE "OBJETIVO" SIZE 172,24 OF oFolder:aDialogs[2] PIXEL;
				ACTION QD050EdTxt("OBJ",If(nOpc == 7,3,nOpc))
oBtn01:cCaption:= PADR(OemToAnsi(STR0028),25)	// "OBJETIVO"
oBtn01:cToolTip:= OemToAnsi(STR0097) // "Digite/Visualize o objetivo da existencia/criacao do Documento..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Responsaveis      			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 040,020 BTNBMP oBtn04 RESOURCE "RESPONSA" SIZE 172,24 OF oFolder:aDialogs[2] PIXEL;
				ACTION If((Empty(M->QDH_DOCTO) .Or. Empty(M->QDH_RV) .Or. Empty(M->QDH_CODTP)),.f.,(QD050MtGet("QD0",If(nOpc == 6 .Or. nOpc == 7,3,nOpc))))
oBtn04:cCaption:= PADR(OemToAnsi(STR0029),20)	// "RESPONSAVEIS"
oBtn04:cToolTip:= OemToAnsi(STR0098) // "Digite/Visualize os Usuarios Responsaveis pelas Etapas de Criacao/Elaboracao..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Destinatarios     			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 070,020 BTNBMP oBtn03 RESOURCE "DESTINOS" SIZE 172,24 OF oFolder:aDialogs[2] PIXEL;
				ACTION If((Empty(M->QDH_DOCTO) .Or. Empty(M->QDH_RV)), .f., QDOA053(If(nOpc==6 .Or. nOpc==7,3,nOpc),lAltDoc))
oBtn03:cCaption:= PADR(OemToAnsi(STR0030),20)	// "DESTINATARIOS"
oBtn03:cToolTip:= OemToAnsi(STR0099) // "Digite/Visualize os Usuarios/Pastas que recebem os Documentos impressos ou eletronicamente..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sumario           			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 100,020 BTNBMP oBtn10 RESOURCE "SUMARIO"  SIZE 172,24 OF oFolder:aDialogs[2] PIXEL;
				ACTION QD050EdTxt("SUM",If(nOpc==7,3,nOpc))
oBtn10:cCaption:= PADR(OemToAnsi(STR0031),25)	// "SUMARIO"
oBtn10:cToolTip:= OemToAnsi(STR0100) // "Digite/Visualize o Sumario do Documento para auxiliar na busca/leitura..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Referencias       			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 130,020 BTNBMP oBtn05 RESOURCE "S4WB014B" SIZE 172,24 OF oFolder:aDialogs[2] PIXEL;
				ACTION QD050MtGet("QDB",If(nOpc==6 .Or. nOpc==7,3,nOpc))
oBtn05:cCaption:= PADR(OemToAnsi(STR0032),20)	// "REFERENCIAS"
oBtn05:cToolTip:= OemToAnsi(STR0101) // "Digite/Visualize as referencias do Documento sendo Internas/Externas para possiveis verificacoes..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Localizadores     			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 160,020 BTNBMP oBtn06 RESOURCE "PESQUISA" SIZE 172,24 OF oFolder:aDialogs[2] PIXEL;
				ACTION QD050MtGet("QD6",If(nOpc==6 .Or. nOpc==7,3,nOpc),"P")
oBtn06:cCaption:= PADR(OemToAnsi(STR0033),20)	// "LOCALIZADORES"
oBtn06:cToolTip:= OemToAnsi(STR0102) // "Digite/Visualize as palavras chaves/localizadores deste Documento..."

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Norma           				   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 190,020 BTNBMP oBtn15 RESOURCE "AUTOM" SIZE 172,24 OF oFolder:aDialogs[2] PIXEL ;
						ACTION (lColsQDV := .T.,QD050MtGet("QDV",If(nOpc==6 .Or. nOpc==7,3,nOpc)))
	
	oBtn15:cCaption:= PADR(OemToAnsi(STR0169),20)	// "NORMAS"
	oBtn15:cToolTip:= OemToAnsi(STR0171) // "Digite/Visualize as normas deste documento"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Documento         		       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QDOAP11")
		@ 220,020 BTNBMP oBtn02 RESOURCE "SDUPROP" SIZE 172,24 OF oFolder:aDialogs[2] PIXEL ;
						ACTION ((lCpyS2T:=ExecBlock("QDOAP11",.f.,.f.,{lCpyS2T,cMatFil,cMatCod,lSol})),If(lCpyS2T==NIL,lCpyS2T:=.F.,""),lRevisao:= .F.)
	Else
		@ 220,020 BTNBMP oBtn02 RESOURCE "SDUPROP" SIZE 172,24 OF oFolder:aDialogs[2] PIXEL ;
						ACTION (QD50VBtDoc(@lCpyS2T,cMatFil,cMatCod,lSol,nOpc),lRevisao:=.F.)
	EndIf
	oBtn02:cCaption:= PADR(OemToAnsi(STR0111),20)	// "DOCUMENTO"
	oBtn02:cToolTip:= OemToAnsi(STR0103) // "Digite/Visualize o conteudo do Documento..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Motivo da Revisao 			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 010,370 BTNBMP oBtn09 RESOURCE "NOTE" SIZE 196,24 OF oFolder:aDialogs[2] PIXEL;
				ACTION QD050EdTxt("REV",If(nOpc==6 .Or. nOpc==7,3,nOpc))
oBtn09:cCaption:= PADR(OemToAnsi(STR0035),34)	// "MOTIVO DA REVISAO"
oBtn09:cToolTip:= OemToAnsi(STR0104) // "Digite/Visualize o Motivo da geracao da Revisao deste Documento..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criticas          			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 040,370 BTNBMP oBtn08 RESOURCE "CRITICA" SIZE 196,24 OF oFolder:aDialogs[2] PIXEL;
				ACTION QDOA051("QD4",If(nOpc == 6 .Or. nOpc==7, 3, nOpc))
oBtn08:cCaption:= PADR(OemToAnsi(STR0036),45)	// "CRITICAS"
oBtn08:cToolTip:= OemToAnsi(STR0105) // "Digite/Visualize as Criticas/Sugestoes deste Documento..."
	If (nOpc <> 2 .Or. nOpc <> 4) .And. M->QDH_STATUS == "D  "
		oBtn08:Disable()
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Solicitacao de Alteracao        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cBtnItnAlt == "S" .And. M->QDH_STATUS <> "L  "
		lBtnSol:= .F.
	EndIf
	If lBtnSol
		If ExistBlock("QDOAP18")
		@ 070,370 BTNBMP oBtn07 RESOURCE "SUGESTAO" SIZE 196,24  OF oFolder:aDialogs[2] PIXEL ;
						ACTION If((Empty(M->QDH_DOCTO) .Or. Empty(M->QDH_RV) .Or. M->QDH_STATUS <> "L  "),.f.,(ExecBlock("QDOAP18",.f.,.f.),nOpc:= 2))
		Else
		@ 070,370 BTNBMP oBtn07 RESOURCE "SUGESTAO" SIZE 196,24 OF oFolder:aDialogs[2] PIXEL ;
						ACTION  If((Empty(M->QDH_DOCTO) .Or. Empty(M->QDH_RV) .Or. M->QDH_STATUS <> "L  "),.f.,(QD052Telas("QDP",,7),nOpc:= 2))
		EndIf
		oBtn07:cCaption:= PADR(OemToAnsi(STR0037),28) // "SOLICITACAO DE ALTERACAO"
		oBtn07:cToolTip:= OemToAnsi(STR0106) // "Digite as Solicitacoes de Alteracoes deste Documento..."
		If M->QDH_STATUS <> "L  " .Or. lSol
			oBtn07:Disable()
		EndIf
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Itens Alterados                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cBtnItnAlt == "S"
		@ 100,370 BTNBMP oBtn14 RESOURCE "SUMARIO" SIZE 196,24 OF oFolder:aDialogs[2] PIXEL;
						ACTION QD050EdTxt( "ITA",If(nOpc == 6 .Or. nOpc == 7,3,nOpc))
		oBtn14:cCaption:= PADR(OemToAnsi(STR0081),40)	// "ITENS ALTERADOS"
		oBtn14:cToolTip:= OemToAnsi(STR0107) // "Digite/Visualize os Itens Alterados deste Documento..."
	EndIf

	If nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6 .Or. nOpc == 7
		If cBtnItnAlt == "N"
			@ 050,183 SAY OemToAnsi(STR0038) SIZE 120,10 OF oFolder:aDialogs[2] PIXEL // "Op‡”es de Fechamento"
		Else
			If M->QDH_STATUS <> "L  "
			@ 035,183 SAY OemToAnsi(STR0038) SIZE 120,10 OF oFolder:aDialogs[2] PIXEL // "Op‡”es de Fechamento"
			EndIf
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Finalizar Documento             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 130,370 BTNBMP oBtn13 RESOURCE "OK" SIZE 196,24 OF oFolder:aDialogs[2] PIXEL ;
					ACTION  If ((nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6 .Or. nOpc == 7) .And. FreeForUse("QDH",xFilial("QDH")+M->QDH_DOCTO+M->QDH_RV) .AND. Obrigatorio(aGets,aTela),;
								(If( lRet := QD050Final(bCampo,nOpc),(QD050BtOff(,,.T., .T.),nOpcao:= 1,lPen:=.F.,QD050PENOK(lPen,nOpcao,nOpc),If (lRet,oDlgFolder:End(),.F.)),.F.)),.F.)
	oBtn13:cCaption:= PADR(OemToAnsi(STR0039),32)	// "&FINALIZAR DOCUMENTO"
	oBtn13:cToolTip:= OemToAnsi(STR0108) // "Pressione para Finalizar a Etapa/Leitura deste Documento..."

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Deixar Documento Pendente       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	@ 160,370 BTNBMP oBtn12 RESOURCE "PENDENTE" SIZE 196,24 OF oFolder:aDialogs[2] PIXEL ;
					ACTION  (lduDupDe:=.T.,If(QD050MsgYN(OemToAnsi( STR0040 ), OemToAnsi( STR0023 ) ),; // "Deixar documento pendente ?" ###"Aten‡„o" 
		If( FreeForUse("QDH",xFilial("QDH")+M->QDH_DOCTO+M->QDH_RV) .AND. Obrigatorio( aGets, aTela ),;
							  				(QD050GrDoc(bCampo,nOpc,.T.),QD050BtOff(,,.T., .T.),nOpcao:= 1,lPen:=.T.,QD050PENOK(lPen,nOpcao,nOpc),oDlgFolder:End()),.F.), .F. ) )

	oBtn12:cCaption:= PADR(OemToAnsi(STR0041),28)	// "DEIX&AR DOCUMENTO PENDENTE"
	oBtn12:cToolTip:= OemToAnsi(STR0109) // "Pressione para deixar pendente a Etapa/Leitura deste Documento..."
	
				If M->QDH_CANCEL == "S"  //Desabilita o Botao quando em fase de Cancelamento
					oBtn12:Disable()
				EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Devolver Documento              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	@ 190,370 BTNBMP oBtn11 RESOURCE "RECALC" SIZE 196,24 OF oFolder:aDialogs[2] PIXEL ;
					ACTION  If(QD050DvDoc(nOpc),(Eval( {|| If( Obrigatorio( aGets, aTela ),(nOpcao:= 1,;
				 				QD050BtOff(,,.T., .T.), oDlgFolder:End() ),.F.)},;
				 				{ || nOpcao := 2,oDlgFolder:End()})),.t.)
	oBtn11:cCaption:= PADR(OemToAnsi(STR0042),30)	// "DEV&OLVER DOCUMENTO"
	oBtn11:cToolTip:= OemToAnsi(STR0110) // "Pressione para devolver a Etapa deste Documento apos ter digitado uma Critica..."
			If Substr(M->QDH_STATUS,1,1) == "D"
				oBtn11:Disable()
			EndIf
		EndIf

		If ExistBlock("QDODESCR")
			ExecBlock("QDODESCR", .f., .f., {oBtn01,oBtn04,oBtn03,oBtn10,oBtn05,oBtn06,oBtn15,oBtn02,oBtn09,oBtn08,oBtn07,oBtn14,oBtn13,oBtn12,oBtn11})
		Endif

@ 122,055 SAY OemToAnsi(STR0043) OF oFolder:aDialogs[2] PIXEL // "Selecione a op‡„o clicando sobre os botoes"

		If nOpc == 2
			If lPendBai
				bCbt:= ({||(nOpcao:= 1,oDlgFolder:End())}, {|| nOpcao := 2,oDlgFolder:End()})
			Else
				bCbt:= ({||oDlgFolder:End() }, {|| oDlgFolder:End() } )
			EndIf
		Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento diferenciado para MDI e normal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SetMDIChild()
			oFolder:Align := CONTROL_ALIGN_ALLCLIENT 
		EndIf

aAdd(aButtons,{"DEPENDENTES",{|| (QD050MtGet("QDZ",If(nOpc == 6 .Or. nOpc == 7,3,nOpc))) } ,OemtoAnsi(STR0130),OemtoAnsi(STR0142) } )  //"Distribuidores" //"Distrib"

		If ExistBlock( "QDOBT050" )
			aArrayBt := ExecBlock( "QDOBT050", .f., .f.,{nOpc,M->QDH_DOCTO,M->QDH_RV})
			If Len(aArrayBt) > 0
				aAdd(aButtons,{aArrayBt[1,1],{|| FQD050BTF(aArrayBt[1,2])} ,aArrayBt[1,3],aArrayBt[1,3] } )
			Endif
			If Len(aArrayBt) > 1
				aAdd(aButtons,{aArrayBt[2,1],{|| FQD050BTF(aArrayBt[2,2])} ,aArrayBt[2,3],aArrayBt[2,3] } ) 
			Endif
			If Len(aArrayBt) > 2
				aAdd(aButtons,{aArrayBt[3,1],{|| FQD050BTF(aArrayBt[3,2])} ,aArrayBt[3,3],aArrayBt[3,3] } )
			Endif
		Endif

		IF lQdReva
			aAdd(aButtons,{"DESTINOS",{|| (QD050EdTxt("RED",2))} ,OemToAnsi(STR0148),OemToAnsi(STR0148) } )
		Endif

oDlgFolder:bSet15:= {|| If(!lPendBai,(QD050BtOff(bSet15,bSet24,.T., .T.),Eval(bOk)),If(QD050Final(bCampo,2),(QD050BtOff(bSet15,bSet24,.T.,.T.),Eval(bOk)),""))}
oDlgFolder:bSet24:= {|| (QD050BtOff(bSet15,bSet24,.F., .T.)),lNoCancel:=.F.,Eval(bCancel)}	

DEFINE FONT oFont NAME "Arial" BOLD SIZE 14,28

nPosCanc := Int(oSize:aWindSize[4]/3) 
@ 37,nPosCanc SAY oSayM;
PROMPT If(M->QDH_CANCEL=="S",UPPER(OemToAnsi(STR0095)),If(M->QDH_OBSOL=="S",UPPER(OemToAnsi(STR0093))," "));
COLOR CLR_HRED,CLR_WHITE OF oFolder FONT oFont CENTER SIZE 150,8 PIXEL
		If M->QDH_CANCEL=="S" .Or. M->QDH_OBSOL=="S"
			oSayM:Show()
		Else
			oSayM:Hide()
		Endif

		If nOpc == 2 .Or. nOpc == 5

	ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder,{|| (nOpcao:= 1,If(!lPendBai,(QD050BtOff(bSet15,bSet24,.T., .T.),""),If(QD050Final(bCampo,2),(QD050BtOff(bSet15,bSet24,.T.,.T.),),nOpcao:=2)),oDlgFolder:End())},{|| (nOpcao:= 2,QD050BtOff(bSet15,bSet24,.F.,.T.),lNoCancel:=.F.,oDlgFolder:End()),2,lPendBai,@nOpcao},,aButtons)
		
		EndIf

		If nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6 .Or. nOpc == 7
			ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder,{|| },{|| nOpcao:= 2,lnoCancel:=.F.,QD050BtOff(bSet15,bSet24,.F., .T.),lNoCancel:=.F.,oDlgFolder:End()},,aButtons,,,,,,.F.)  
		EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Diferente de Exclusao de revisao ou Cancelamento de Documento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If nOpcao == 2
			If nOpc <> 5 .And. nOpc <> 6
				If M->QDH_STATUS <> "I  "
					If Inclui .Or. nOpc == 7
						If !Empty( M->QDH_NOMDOC )
							If File( cQPath + "\" + Alltrim( M->QDH_NOMDOC ) )
								FErase( cQPath + "\" + Alltrim( M->QDH_NOMDOC ) )
							EndIf
						EndIf
					Endif
				EndIf
			EndIf
		EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclusao de Documento              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == 5
			If l050Del
				lExecuta := ExecBlock("Q050DEL",.f.,.f.,{nOpcao})
				If !lExecuta
					Return .T.
				Endif
			Endif
	
			If nOpcao == 1     //botão OK
				Begin Transaction
				cChave:= M->QDH_CHAVE
				QD050ApAll()        //apaga todos os textos
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apaga os Questionario e Respostas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QAG->(DbSetOrder(2))
							If QAG->(DbSeek(xFilial("QAG")+M->QDH_DOCTO+M->QDH_RV))
								While QAG->(!Eof()) .And. QAG->QAG_FILIAL+QAG->QAG_DOCTO+QAG->QAG_RVDOC == xFilial("QAG")+M->QDH_DOCTO+M->QDH_RV
									QAH->(DbSetOrder(1))
									If QAH->(DbSeek(xFilial("QAH")+QAG->QAG_QUEST+QAG->QAG_RV))
										While QAH->(!Eof()) .And. QAH->QAH_FILIAL+QAH->QAH_QUEST+QAH->QAH_RV == xFilial("QAH")+QAG->QAG_QUEST+QAG->QAG_RV
											RecLock("QAH",.F.)
											QAH->(DbDelete())
											QAH->(MsUnlock())
											FKCOMMIT()
											QAH->(DbSkip())
										EndDo
									ENDIF
									RecLock("QAG",.F.)
									QAG->(DbDelete())
									QAG->(MsUnlock())
									FKCOMMIT()
									QAG->(DbSkip())
								EndDo
							EndIf
				
				RecLock("QDH",.F.)
				QDH->(DbDelete())
				QDH->(MsUnlock())
				FKCOMMIT()
						End Transaction
				
						If !Empty(M->QDH_NOMDOC)
							If File(cQPath + "\" + Alltrim(M->QDH_NOMDOC))
						FErase(cQPath + "\" + Alltrim(M->QDH_NOMDOC))
							EndIf
						EndIf
				
				QDH->(DbSetOrder(6)) //Revisao invertida 
				QDH->(DbClearFilter())
						If QDH->(DbSeek(xFilial("QDH")+M->QDH_DOCTO))
							cUltRev:= QDH->QDH_REVINV 
						EndIf
						If QDH->(DbSeek(xFilial("QDH")+M->QDH_DOCTO+cUltRev)) .AND. Alltrim(QDH->QDH_CANCEL) == 'S'
							RecLock("QDH",.F.)
							QDH->QDH_OBSOL := 'N'
							QDH->(MsUnLock())               
						EndIf
				QDH->(DbSetOrder(1)) 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso o documento anterior seja uma revisão cancelada |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			EndIf
		EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cancelamento de documento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == 6
			If nOpcao == 1
				cChave := QDH->QDH_CHAVE
				aElabs:= QDXFNObRep("E",QDH->QDH_FILIAL,QDH->QDH_DOCTO,QDH->QDH_RV)
				For nC := 1 To Len(aElabs)
					If QAA->(DbSeek(aElabs[nC,1]+aElabs[nC,2]))
						If QAA->QAA_TPRCBT <> "4" .And. QA_SitFolh()
							If QAA->QAA_TPRCBT $ "2,3"
							aReg:= Array(13)
							aReg[02]:= QAA->QAA_NOME
							aReg[03]:= QA_NDEPT(QAA->QAA_CC,.T.,xFilial("QAD"))
							aReg[10]:= QAA->QAA_FILIAL
							aReg[11]:= QAA->QAA_CC
							aReg[12]:= QAA->QAA_MAT
							Aadd(aRegs,aReg)
							EndIf
							QD110GrLog(.T.,OemToAnsi(STR0078),"U",1,cMatFil,cMatCod,QAA->QAA_FILIAL, QAA->QAA_MAT,QAA->QAA_TPRCBT) //"Distribui‡„o - Cancelamento de Documento"
						EndIf
					EndIf
				Next nC
			ElseIf nOpcao == 2
				If !Empty(M->QDH_NOMDOC)
					If File(cQPath + "\" + Alltrim(M->QDH_NOMDOC))
						FErase(cQPath + "\" + Alltrim(M->QDH_NOMDOC))
					EndIf
				EndIf
		
				QDH->(DbSetOrder(6)) //Revisao Invertida
				If QDH->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO))
					cUltRev:= QDH->QDH_REVINV
				EndIf
				QDH->(DbSetOrder(1))
			EndIf
		EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desbloqueia o Arquivo QDH     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == 4 .And. Substr(M->QDH_STATUS,1,1) $ "E,R,A,H"
			QDH->(MsUnlock())
		EndIf

cExpFilt := Qd050Filtro()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada criado para mudar o Filtro ou realizar alguma tarefa especifica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("QDOAP17")
			cExpFilt := ExecBlock("QDOAP17", .f., .f., {nOpc})
		EndIf
DbSelectArea("QDH") 
		If ExistBlock( "QD050FIL" )                  // execblock para funcionar de acordo com execblock de entrada da tela
			If !ExecBlock( "QD050FIL", .F., .F. )
				Set Filter To &(cExpFilt)
			Endif
		Else
			Set Filter To &(cExpFilt)
		EndIf
		If File(cQPathTrm+AllTrim(M->QDH_NOMDOC))
			If lCpyS2T .And. nOpcao == 1
				If M->QDH_DTOIE == "E"
					cExt := Right(AllTrim(M->QDH_NOMDOC), 4)
				Endif
				_CopyFile( cQPath + AllTrim(M->QDH_NOMDOC), cQPath + StrTran(AllTrim(M->QDH_NOMDOC), cExt, ".XYZ"))		// Copia do Arquivo anterior
				Ferase(cQPath + AllTrim(M->QDH_NOMDOC))
				CpyT2S(cQPathTrm+AllTrim(M->QDH_NOMDOC),cQPath,.T.)     
				QDX_CPYT2S(cQPathTrm+AllTrim(M->QDH_NOMDOC), cQPath, AllTrim(M->QDH_NOMDOC))
				If ! File(cQPath + AllTrim(M->QDH_NOMDOC))
					_CopyFile( cQPath + StrTran(AllTrim(M->QDH_NOMDOC), ".XYZ", cExt), cQPath + AllTrim(M->QDH_NOMDOC))		// Volta o numero anterior
				Else
					Ferase(cQPath + StrTran(AllTrim(M->QDH_NOMDOC), cExt, ".XYZ"))
				Endif
		
		lCpyS2T := .F.
			EndIf
			If !lNoDelTmp
				FErase(cQPathTrm+AllTrim(M->QDH_NOMDOC))
				cQArqTmp := Left(cQPathTrm+AllTrim(M->QDH_NOMDOC),Len(cQPathTrm+AllTrim(M->QDH_NOMDOC))-4)+"_TMP.CEL"
				If File(cQArqTmp)
					FErase(cQArqTmp)
				EndIf
			EndIf
		EndIf

aData  := DIRECTORY(cQPathTrm+"*.DOT")
		For nT:= 1 to Len(aData)
			If File(cQPathTrm+AllTrim(aData[nT,1]))
				FErase(cQPathTrm+AllTrim(aData[nT,1]))
			EndIf
		Next nT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apaga Arquivos Html do Diretorio Temporario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If File(cQPathTrm+Substr(Alltrim(M->QDH_NOMDOC),1,8)+".HTM")
			QDRemDirHtm(AllTrim(M->QDH_NOMDOC))
		EndIf

		IF Len(aUsrMail) > 0
			QaEnvMail(aUsrMail,,,,aUsrMat[5],"2")
		Endif

		If lSalvaWHtml
					    
			If !File(cQPathTrm+Alltrim(M->QDH_NOMDOC))
				CpyS2T(cQPath+Alltrim(M->QDH_NOMDOC),cQPathTrm,.T.)
			Endif

			If File(cQPathTrm+Alltrim(M->QDH_NOMDOC))
				oWordTmp := OLE_CreateLink("TMsOleWord97")
				OLE_SetProperty( oWordTmp, oleWdVisible,   .f. )
				OLE_SetProperty( oWordTmp, oleWdPrintBack, .f. )
				OLE_OpenFile( oWordTmp, ( cQPathTrm + Alltrim(M->QDH_NOMDOC) ),.F., cMvSave, cMvSave )
				cArqTmp := Left(AllTrim(M->QDH_NOMDOC),Len(AllTrim(M->QDH_NOMDOC))-3)+"HTM"
				OLE_SaveAsFile( oWordTmp, (cQPathTrm+cArqTmp), "", "", .f., oleWdFormatHTML )
				OLE_CloseFile( oWordTmp )
				OLE_CloseLink( oWordTmp )

				If File(cQPathTrm+cArqTmp)
					CpyT2S(cQPathTrm+cArqTmp,cQPathHtm,.T.)  
					aDiretorio:= QDocDirc(cQpathTrm,"D") //DIRECTORY				
					If Len(aDiretorio) > 0
						nPosDir:= ASCAN(aDiretorio,{|X| Substr(AllTrim(M->QDH_NOMDOC),1,8)+"_" $ X[1] })
						If nPosDir > 0
							If (nDirHtml:= MakeDir(cQPathHtm+aDiretorio[nPosDir,1])) == 0
								aData  := QDocDirc(cQPathTrm+aDiretorio[nPosDir,1]) //DIRECTORY							
								For nT:= 1 to Len(aData)
									If File(cQPathTrm+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nT,1]))
						      			CpyT2S(cQPathTrm+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nT,1]),cQPathHtm+aDiretorio[nPosDir,1],.T.)
									Endif
								Next nT
							EndIf
						EndIf
					EndIf
					QDRemDirHtm(AllTrim(M->QDH_NOMDOC))
				EndIf
			Endif
		Endif

		If ExistBlock("QDOFINAL")
			ExecBlock("QDOFINAL", .f., .f., {nOpc,nOpcao,lDocDupli,lPen})
		EndIf

		If ExistBlock( "QDOAP27" )
			DbSetorder(ExecBlock( "QDOAP27", .f., .f.))
		Else
			QDH->(DBSetOrder(nOrdTela))
		Endif

lSobDocTmp := .F.

Return nOpcao

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QD050MsgYN ³Autor ³ Newton R Ghiraldelli³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta tela de mensagem de escolha                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD050MsgYN(ExpC1,ExpC2)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Texto1                                            ³±±
±±³          ³ ExpC2 - Texto2                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA050.PRW                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050MsgYN(cText1,cText2)

Local lRet   := .F.
Local aUsrMat:= QA_USUARIO()
Local cMatFil:= aUsrMat[2]
Local cMatCod:= aUsrMat[3]
Local cMatDep:= aUsrMat[4]

	If Empty(M->QDH_DOCTO) .Or. Empty(M->QDH_RV)
	Return lRet
	EndIf

	If M->QDH_STATUS <> "L  "
	lRet:= MsgYesNo(cText1,cText2)
	Else
	QD1->(DbSetOrder(1))
		If QD1->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+cMatDep+cMatFil+cMatCod))
			While QD1->(!Eof()) .And. M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+cMatDep+cMatFil+cMatCod == ;
											 QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_DEPTO+QD1->QD1_FILMAT+QD1->QD1_MAT
					If QD1->QD1_SIT <> "I"
					If QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND == "L  "
					lRet:= MsgYesNo(cText1,cText2)
					Exit
					EndIf
				EndIf
			QD1->(DbSkip())
			EndDo
		EndIf
	EndIf

Return lRet

Function FQD050BTF(cFuncBtn)
&(cFuncBtn)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QD050EBOpc ³Autor³ Newton R Ghiraldelli ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta tela de getdados( Responsaveis/destinatarios )      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD050EBOpc( ExpO1,ExpB1,ExpB2,ExpN1,ExpL1 )               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto Tela                                       ³±±
±±³          ³ ExpB1 - bOk                                               ³±±
±±³          ³ ExpB2 - bCancel                                           ³±±
±±³          ³ ExpN1 - Opcao do Browse                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050EBOpc(oDlg,bOk,bCancel,nOpc,cAlias3)

Local oBar
Local oBtOk
Local oBtCan
Local oBtDoc
Local bSet15
Local bSet24
Local lOk    := .F.
Local nPosQDH:= QDH->(RecNo())
Local nOrdQDH:= QDH->(IndexOrd())
Local nI     := ""
Local aQDH   := {}

DbSelectArea("QDH")
	For nI := 1 To FCount()
	aADD(aQDH,M->&(Eval(bCampo,nI)))
	Next nI

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

DEFINE BUTTON RESOURCE "S4WB005N" OF oBar ACTION NaoDisp() TOOLTIP  OemToAnsi(STR0010) //"Recortar"
DEFINE BUTTON RESOURCE "S4WB006N" OF oBar ACTION NaoDisp() TOOLTIP  OemToAnsi(STR0011) //"Copiar"
DEFINE BUTTON RESOURCE "S4WB007N" OF oBar ACTION NaoDisp() TOOLTIP  OemToAnsi(STR0012) //"Colar"
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP OemToAnsi(STR0013)  PROMPT OemToAnsi(STR0139) //"Calculadora..." //"Calc"
DEFINE BUTTON RESOURCE "S4WB009N" OF oBar ACTION Agenda()   TOOLTIP  OemToAnsi(STR0014) //"Agenda..."
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar ACTION OurSpool() TOOLTIP  OemToAnsi(STR0015)  PROMPT OemToAnsi(STR0140) //"Gerenciador de Impress„o..." //"Spool"
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar GROUP ACTION HelProg() TOOLTIP OemToAnsi(STR0016)  PROMPT OemToAnsi(STR0141) //"Ajuda de Programa..." //"Ajuda"

	If cAlias3 == "QDB"
	DEFINE BUTTON oBtDoc  RESOURCE "RELATORIO" OF oBar GROUP TOOLTIP OemToAnsi(STR0034)  PROMPT OemToAnsi(STR0143) ; // "Documento"
	ACTION QD50DocRef()
	EndIf

DEFINE BUTTON oBtOk  RESOURCE "OK" OF oBar GROUP ACTION QD050BotOk(lOk,bOk,aCols,aQDH,nOrdQDH,nPosQDH) ;
 		TOOLTIP OemToAnsi(STR0017) PROMPT OemToAnsi(STR0021) // "Ok - <Ctrl-O>" //"OK"
 		
SetKey( 15, oBtOk:bAction )

DEFINE BUTTON oBtCan RESOURCE "CANCEL" OF oBar ; 
	ACTION (If(cAlias3 == "QDB",QD050ApQA4(aQDH,nOrdQDH,nPosQDH),.F.),QD050BtOff(bSet15,bSet24,.F.),Eval(bCancel));
	TOOLTIP OemToAnsi( STR0008 ) //"Cancelar"

SetKey(24,oBtCan:bAction)
oDlg:bSet15:= oBtOk:bAction
oDlg:bSet24:= oBtCan:bAction
oBar:bRClicked:= { || AllwaysTrue() }

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD050BtOff ³ Autor ³ Aldo Marini Junior³ Data ³ 07/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Habilita/desabilita CRTL O e CTRL X                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD050BtOff( ExpB1,ExpB2,ExpL1 )                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpB1 - Bloco com valor ASCII para CTRL 0                ³±±
±±³           ³ ExpB2 - Bloco com valor ASCII para CTRL X                ³±±
±±³           ³ ExpL1 - Valor logico que permite habilitar ou desabilitar³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA050                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050BtOff(bSet15,bSet24,lOk, lQd050Fim)

Default lOk := .T.
DEFAULT lQd050Fim := .F.

	If bSet15 # Nil
	SetKey( 15, bSet15 )
	Endif
	If bSet24 # Nil
	SetKey( 24, bSet24 )
	Endif
	If lQd050Fim .And. ExistBlock("QD050FIM")
	ExecBlock("QD050FIM", .f., .f., lOk)
	EndIf
	If lQd050Fim .And. Type("oWord") <> "U"
		If !Empty(oWord) .And. oWord <> "-1"
		OLE_CloseFile( oWord )
		OLE_CloseLink( oWord )
		EndIf
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QD050BotOk ³Autor³Newton R Ghiraldelli  ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava / Visualiza (Responsaveis / Destinatarios)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD050BotOk(ExpL1,ExpL2,ExpB1,ExpA1,ExpA1,ExpN1,ExpN2)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Loop (.T. / .F.)                                  ³±±
±±³          ³ ExpL2 - lOk                                               ³±±
±±³          ³ ExpB1 - Bloco de Codigo bOk                               ³±±
±±³          ³ ExpA1 - Acols (Responsaveis / Destinatarios)              ³±±
±±³          ³ ExpA1 - Array com as variaveis de memoria do cad.principal³±±
±±³          ³ ExpN1 - Ordem original do Documento                       ³±±
±±³          ³ ExpN2 - Posicao Original do Cadastro de Documento         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050BotOk(lOk,bOk,aCols,aQDH,nOrdQDH,nPosQDH)

Local nCt    := 0
Local nIt    := 0
Local lFim   := .T.
Local aNiveis:= {}
Local nI      
Local lMsg   := .T.
Local lRet 	 := .T.
Default bOk  := {|| }

Private nQD0Aut := GdFieldPos("QD0_AUT",aHedDoc[1])

DbSelectArea("QDH")
	For nI := 1 To FCount()
	aADD(aQDH,M->&(Eval(bCampo,nI)))
	Next nI

	If cAlias3 == "QD0" .And. M->QDH_STATUS <> "L  "
		For nCt:= 1 to Len(aCols)
			If aCols[nCt,nUso+1] == .F.
			nIt:= Ascan(aNiveis,{|X| X[1] == aCols[nCt, nQD0Aut]})
				If nIt > 0
				aNiveis[nIt,2]++
				Else
				aAdd(aNiveis,{aCols[nCt,nQD0Aut],1})
				EndIf
				If lMsg
				lMsg:= QA_CHKNIV(nCt, Nil, .T. )
				EndIf
			EndIf
		Next
   
	lFim:= QDXFNCkRes(aNiveis,.t.)
    
		If lFim
	    //Validar se existe usuario cadastrado para a Filial informada
	    DbSelectArea("QAA")
	    QAA->(DbSetOrder(1))
			For nCt:= 1 to Len(aCols)
				If  ( aCols[nCt,nUso+1] == .F. .AND. QAA->(!DbSeek(aCols[nCt,03]+aCols[nCt,04])) )
				MSGAlert(STR0157+aCols[nCt,05]+STR0158+aCols[nCt,03],STR0023)//"O usuario "##" nao esta cadastrado para a filial "##"Atencao")	
				lFim:= .F. 
				Endif
			Next
		Endif
		
	ElseIf cAlias3 == "QDB"
	DbSelectArea("QDH")
	QDH->(DbSetOrder(nOrdQDH))
	QDH->(DbGoto(nPosQDH))
		For nI := 1 To Len(aQDH)
		M->&(Eval(bCampo,nI)):= aQDH[nI]
		Next nI
	EndIf

	If lFim .AND. lMsg
	lOk:= Eval(bOk)
	Else
	lOk:= .F.
	EndIf

	If !lFim .OR. !lMsg
	lRet := .F.
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD050MtGet ³Autor ³ Programacao Quality³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Monta Tela de Responsaveis                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD050MtGet( ExpC1,ExpN1,ExpC2 )                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 - Alias do Arquivo                                 ³±±
±±³           ³ ExpN1 - Opcao do MBrowse                                 ³±±
±±³           ³ ExpC1 - Tamanho do GetDados                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA050                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050MtGet(cAlias2B,nOpc,cTam)

Local aButtoes := {}
Local aQDH     := {}
Local bCancel  := {|| }
Local bOk      := {|| }
Local bSet15   := {|| }
Local bSet24   := {|| }
Local lOk      := .F.
Local nOpca1   := 0
Local nOrdQDH  := QDH->(IndexOrd())
Local nPosQDH  := QDH->(RecNo())
Local nT       := 1
Local oCodDoc  := Nil
Local oDesTit  := Nil
Local oDlg1    := Nil
Local oRvDoc   := Nil

Private aCols     := {}
Private aColsAux  := {}
Private aGETS	  := {}
Private aHeader	  := {}
Private aTELA	  := {}
Private cAlias3   := cAlias2B
Private cCodDoc   := ""
Private cDesTit   := ""
Private cFilDoc   := ""
Private Continua  := .F.
Private cRvDoc    := ""
Private cTpTXT    := ""
Private nCnt      := 0
Private nLenCol   := 1
Private nPosOri   := 1
Private nPQD4     := 0
Private nQaConpad := 1
Private nUsado    := 0
Private oGetMt	  := NIL

	If Empty(M->QDH_DOCTO) .Or. Empty(M->QDH_RV)
		Return .F.
	EndIf

	cFil       := cAlias3 + "_FILIAL"
	cCod       := cAlias3 + "_DOCTO"
	cRv        := cAlias3 + "_RV"
	QD050Field := {cFil,cCod,cRv}
	cFilDoc    := M->QDH_FILIAL
	cCodDoc    := M->QDH_DOCTO
	cRvDoc     := M->QDH_RV
	cDesTit    := M->QDH_TITULO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ARRAY de AHEADERS ³
	//³aHedDoc[1] = QD0  ³
	//³aHedDoc[2] = QD6  ³
	//³aHedDoc[3] = QDB  ³
	//³aHedDoc[4] = QDZ  ³
	//³aHedDoc[5] = QD4  ³
	//³aHedDoc[6] = QDV  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If cAlias3 == "QD6"
    	aHeader	:= aHedDoc[2]
    	aCols	:= aClone(aQD6Doc)
    	cCad1  	:= OemToAnsi( STRTRAN(STR0033,"&","") ) //"&LOCALIZADORES"
	ElseIf cAlias3 == "QDB"
    	aHeader	:= aHedDoc[3]  
    	aCols	:= aClone(aQDBDoc)
    	nPosOri	:= GdFieldPos("QDB_ORIGEM",aHeader)
    	nPosSEq	:= GdFieldPos("QDB_SEQ"   ,aHeader)    
		IF Empty(aCols[1,1])
			aCols[1,nPosSEq]:= "0001"
		Endif
    	cCad1  	:= OemToAnsi( STRTRAN(STR0032,"&","") ) //"R&EFERENCIAS"
	ElseIf cAlias3 == "QD0"
    	aHeader	:= aHedDoc[1]  
		If !Empty(aQD0Doc)
			IF  Empty(aQD0Doc[1,1])
				IF ExistBlock("QDOAP35")
					ExecBlock("QDOAP35", .f., .f.)                
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Carrega Array com os Usuarios do QDD³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
					QDO050CQDD()
				Endif
			Endif
		EndIf

		QDO050CQDD() //Chamada da função que recarrega os arrays dos Usuários/Responsáveis
		
      	aCols	:= aClone(aQD0Doc)    
      	aColsAux:= aClone(aCols)        
	  	nPosAut := GdFieldPos("QD0_AUT"   ,aHeader)
	  	nPosOrd := GdFieldPos("QD0_ORDEM" ,aHeader)
	  	nPosFil := GdFieldPos("QD0_FILMAT",aHeader)
	  	nPosCod := GdFieldPos("QD0_MAT"   ,aHeader)
	  	nPosDep := GdFieldPos("QD0_DEPTO" ,aHeader)
   	  	cCad1 	:= OemToAnsi( STRTRAN(STR0029,"&","") ) //"&RESPONSAVEIS"   	
	ElseIf cAlias3 == "QDZ"
		nQaConpad:= 9      
    	aHeader	:= aHedDoc[4]
    	aCols	:= aClone(aQDZDoc)
		nPosFil	:= GdFieldPos("QDZ_FILMAT",aHeader)
		nPosCC 	:= GdFieldPos("QDZ_DEPTO" ,aHeader)
		IF Empty(aCols[1,nPosFil]) .OR. Empty(aCols[1,nPosCC])
			aCols[1,nPosFil]:= CriaVar("QDZ_FILMAT") 
			aCols[1,nPosCC] := CriaVar("QDZ_DEPTO")
		Endif
		cCad1	:= STR0130 //"Distribuidores"
		N		:= 1	   
		nLenCol := Len(aCols)
		nUsado  := Len(aHeader)  
		QA_CHKDIST(.T.)
	ElseIf cAlias3 == "QDV"
    	aHeader	:= aHedDoc[6]
    	aCols	:= aClone(aQDVDoc)
    	cCad1  	:= OemToAnsi( STR0169 ) // "NORMAS"
	EndIf

	nUsado:= Len(aHeader)  
	nUso  := nUsado

	If cTam == "P"
		DEFINE MSDIALOG oDlg1 TITLE cCad1 FROM 015,000 TO 032,060 
		@ 033,005 SAY OemToAnsi(STR0034) + ": " + cCodDoc OF oDlg1 PIXEL // "Documento"
		@ 033,128 SAY OemToAnsi(STR0044) + ": " + cRvDoc OF oDlg1 PIXEL // "Revis„o"
	Else
		DEFINE MSDIALOG oDlg1 TITLE cCad1 FROM 100,100 TO 120,180 OF oMainWnd
		@ 35,005 TO 65,311 OF oDlg1 PIXEL

		@ 040,008 SAY OemToAnsi(STR0034)+": " SIZE 030,007 OF oDlg1 PIXEL // "Documento"
		@ 040,040 MSGET oCodDoc VAR cCodDoc SIZE 060,008 OF oDlg1 PIXEL // CAMPO DOCUMENTO
		oCodDoc:lReadOnly:= .T.
		@ 040,100 MSGET oRvDoc VAR cRvDoc SIZE 012,008 OF oDlg1 PIXEL // CAMPO REVISAO
		oRvDoc:lReadOnly:= .T.
		@ 052,008 SAY OemToAnsi(STR0045)+": " SIZE 030,007 OF oDlg1 PIXEL // "T¡tulo"
		@ 052,040 MSGET oDesTit VAR cDesTit SIZE 240,008 OF oDlg1 PIXEL
		oDesTit:lReadOnly:= .T.
	EndIf




	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Erro no Binario de Deletar a primeira linha do aCols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aCols) > 0
		IF aCols[1,Len(aCols[1])]
			aCols[1,Len(aCols[1])]:=.F.
			lErroDel:= .T.
		Else
			lErroDel:= .F.	
		Endif
	Else
		lErroDel:= .F.	
	EndIf

	If (nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6 .Or. nOpc ==7) .And. (M->QDH_STATUS $ "D  ,E  ,DC ,EC " .Or. lAltDoc)
		IF cAlias3 <> "QDB"
			If cTam == "P"
	      		oGetMt := MSGetDados():New(045,005,115,230,004,"QD050LinOk('" + cAlias3 + "')","","",.t.,,,,300,,,,"QD050RspExc")
			Else
	      		oGetMt := MSGetDados():New(067,005,136,312,004,"QD050LinOk('" + cAlias3 + "')","","",.t.,,,,300,,,,"QD050RspExc")
			EndIf
		Else
      		oGetMt := MSGetDados():New(067,005,136,312,004,"QD050LinOk('" + cAlias3 + "')","","+QDB_SEQ",.t.,,,,300,,,,"QD050RspExc")
		Endif
		oGetMt:ForceRefresh()
		IF lErroDel
			aCols[1,Len(aCols[1])]:=.T.
		Endif

		If cAlias3 == "QDB"
			aAdd(aButtoes,{"RELATORIO",{|| QD50DocRef()} ,OemtoAnsi(STR0143),OemtoAnsi(STR0034) } )  //"Documento"
		EndIf

		bOk		:= {|| If(Obrigatorio(aGets,aTela), (nOpca1 := 1, If(QD050LinOk(cAlias3) .And. QD050TudOk(cAlias3) .And. QD050BotOk(lOk,Nil,aCols,aQDH,nOrdQDH,nPosQDH), oDlg1:End(), nOpca1 := 0)),.F.)}
		bCancel	:= {|| nOpca1:= 3, oDlg1:End(), nOpc, cAlias3}

		SetKey(15,bOk)	
		SetKey(24,bCancel)

		oDlg1:bSet15:= bOk
		oDlg1:bSet24:= bCancel

		if isinCallStack('QD030BXPEN')
			cFilmat:=QDH->QDH_FILMAT
		EndiF

		ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, bOk,;
			{||nOpca1:= 3,(If(cAlias3 == "QDB",QD050ApQA4(aQDH,nOrdQDH,nPosQDH),.F.),QD050BtOff(bSet15,bSet24,.F.),""),oDlg1:End(),nOpc,cAlias3},,aButtoes) CENTERED
	Else
		If cTam == "P"
			oGetMt := MSGetDados():New(50,005,120,230,002)
		Else
			oGetMt := MSGetDados():New(067,005,136,312,004)
		EndIf
		oGetMt:ForceRefresh()
		IF lErroDel
			aCols[1,Len(aCols[1])]:=.T.
		Endif

		If cAlias3 == "QDB"
			aAdd(aButtoes,{"RELATORIO",{|| QD50DocRef()} ,OemtoAnsi(STR0143),OemtoAnsi(STR0034) } )  //"Documento"
		EndIf

		ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| (nOpca1:= 1,oDlg1:End())},{|| (nOpca1:= 2,oDlg1:End(),nOpc,cAlias3)},,aButtoes) CENTERED

	EndIf

	If nOpc <> 2
		If Inclui .Or. nOpc == 7
		lIncDepois:= .T.
		EndIf
		If nOpca1 == 1	
			If !(lAltDoc)
				MsgAlert(OemToAnsi(STR0181), OemToAnsi(STR0175)) //Nao foi possivel incluir o responsável. 
				//Verifique no Cadastro de Tipo de Documento quais usuarios possuem a permissão Alterar documento = Sim
			Endif

			If (M->QDH_STATUS $ "D  ,E  ,DC ,EC " .Or. lAltDoc)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os lactos dos cadastros de acordo com a opcao em ARRAY    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DO CASE
				CASE cAlias3 == "QD0"
					For nt := 1 to Len( aCols )
						If aCols[nt][nPosAut] == "E"
						aCols[nt][nPosAut] := "1"
						ElseIf aCols[nt][nPosAut] == "R"
						aCols[nt][nPosAut] := "2"
						ElseIf aCols[nt][nPosAut] == "A"
						aCols[nt][nPosAut] := "3"
						ElseIf aCols[nt][nPosAut] == "H"
						aCols[nt][nPosAut] := "4"   
						ElseIf Empty(aCols[nt][nPosAut])
						aCols[nt][nPosAut] := "5"   					
						EndIf
					Next
				aCols := aSort( aCols, , , { |x,y| x[nPosAut] + x[nPosOrd] < y[nPosAut] + y[nPosOrd] } )
					For nt :=1 to Len( aCols )
						If aCols[nt][nPosAut] == "1"
						aCols[nt][nPosAut] := "E"
						ElseIf aCols[nt][nPosAut] == "2"
						aCols[nt][nPosAut] := "R"
						ElseIf aCols[nt][nPosAut] == "3"
						aCols[nt][nPosAut] := "A"
						ElseIf aCols[nt][nPosAut] == "4"
						aCols[nt][nPosAut] := "H"
						ElseIf aCols[nt][nPosAut] == "5"
						aCols[nt][nPosAut] := ""							
						EndIf
					Next
				aQD0Doc := aClone(aCols)
				CASE cAlias3 == "QD6"
				aQD6Doc := aClone(aCols)
				CASE cAlias3 == "QDB"
				aQDBDoc := aClone(aCols)                                   
				CASE cAlias3 == "QDZ"
				aQDZDoc := aClone(aCols)
				CASE cAlias3 == "QDV"
				aQDVDoc := aClone(aCols)
				EndCASE
			Endif
		Endif
	Endif

QDH->(DbSetOrder(nOrdQDH))
QDH->(DbGoto(nPosQDH))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QDVNORMA ³ Autor ³ Equipe Quality  ³ Data ³ 09/04/2015     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Norma									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QDOA050 - E' cham. no X3_VALID do QDV_NORMA                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QdvNorma()
	Local lRetorno := .T.
	Local cVar     := &(ReadVar()) // Conteudo da variavel do Norma
	Local nPosNorm := Ascan(aHeader, { |X| Upper( Alltrim( X[2])) == "QDV_NORMA" })
	Local nPosDesc := Ascan(aHeader, { |X| Upper( Alltrim( X[2])) == "QDV_DESC" })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se mudou a Norma (Alterou o campo ja' digitado)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aCols[N,nPosNorm]) .And. !Empty(cVar) .And. aCols[N,nPosNorm] != cVar
		Help(" ",1,"A010ALTCHA")   // Campo nao pode ser alterado
		lRetorno := .F.
	EndIf

	If !Empty(aCols[N,nPosNorm])
		aCols[N,nPosDesc] := QA_NORMA(aCols[N,nPosNorm])
	EndIF

Return (lRetorno)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD050ACols ³Autor ³ Programacao Quality³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Carrega Acols                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD050ACols( ExpF1,ExpC1,ExpC2,ExpC3,ExpC4)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpF1 - Funcao QD050Field                                ³±±
±±³           ³ ExpC1 - Alias do Arquivo                                 ³±±
±±³           ³ ExpC2 - Filial do Documento                              ³±±
±±³           ³ ExpC3 - Documento                                        ³±±
±±³           ³ ExpC4 - Revisao do Documento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA050                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050ACols(QD050Field,cAlias2,cFil,cCod,cRv)

Local cArqCpo    := ""
Local nCt
Local aStruAlias := FWFormStruct(3, cAlias2)[3]
Local nX

nCnt := 0
DbSelectArea(cAlias2)
	If Dbseek(cFilDoc+cCodDoc+cRvDoc)
		While !Eof() .And. &cFil + &cCod + &cRv == cFilDoc + cCodDoc + cRvDoc
			If cAlias2 == "QD0"
				If ( QD0->QD0_FLAG == "T" .And. M->QDH_STATUS == "L  " ) .Or. ;
				( QD0->QD0_FLAG == "I" .And. M->QDH_STATUS <> "L  " )
				DbSkip()
				Loop
					EndIf
			EndIf
		nCnt++
		nCampo := 0
		nUsado := 0
		nArray := 0
			For nX := 1 To Len(aStruAlias)
				If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") .and. ! Ascan( QD050Field, Trim( aStruAlias[nX,1] ) ) > 0
				nUsado++
					If aStruAlias[nX,1] $ "QD0_FILMAT"
					nCampo   := nUsado
					nArray   := nCnt
					EndIf
					If GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT") == "V"
						If Upper( Alltrim( aStruAlias[nX,1] ) ) == "QD0_NOME"
						aCols[nCnt, nUsado] := Padr( QA_NUSR( aCols[nArray, nCampo], aCols[nArray, nCampo + 1] ), 40 )
						Else
						aCols[nCnt, nUsado] := CriaVar( AllTrim( aStruAlias[nX,1] ) )
						EndIf
					Else
					cArqCpo := cAlias2+"->"+aStruAlias[nX,1]
					aCols[nCnt][nUsado] := &( cArqCpo )
					EndIf
				EndIf
			Next nX
		aCols[nCnt][nUsado + 1] := .f.
		DbSelectArea( cAlias2 )
		DbSkip()
		EndDo
	Else
	nUsado := 0
		For nX := 1 To Len(aStruAlias)
			If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") .and. ! Ascan( QD050Field, Trim( aStruAlias[nX,1] ) ) > 0
				nUsado++
				aCols[1, nUsado] := CriaVar( AllTrim( aStruAlias[nX,1] ) )
			EndIf
		Next nX
	aCols[1,(nUsado+1)] := .f. 
	EndIf

	If cAlias3 == "QD0"
	nPosA := Ascan( aHeader, { |X| Upper( Alltrim( X[2] ) ) == "QD0_AUT" } )
	nPosB := Ascan( aHeader, { |X| Upper( Alltrim( X[2] ) ) == "QD0_ORDEM" } )
	aAux  := aClone( aCols )
		For nCt := 1 to Len( aAux )
			If aAux[nCt][nPosA] == "E"
			aAux[nCt][nPosA] := "1"
			ElseIf aAux[nCt][nPosA] == "R"
			aAux[nCt][nPosA] := "2"
			ElseIf aAux[nCt][nPosA] == "A"
			aAux[nCt][nPosA] := "3"
			ElseIf aAux[nCt][nPosA] == "H"
			aAux[nCt][nPosA] := "4"
			EndIf
		Next
	aAux := aSort( aAux, , , { |x,y| x[nPosA] + x[nPosB] < y[nPosA] + y[nPosB] } )
		For nCt :=1 to Len( aAux )
			If aAux[nCt][nPosA] == "1"
			aAux[nCt][nPosA] := "E"
			ElseIf aAux[nCt][nPosA] == "2"
			aAux[nCt][nPosA] := "R"
			ElseIf aAux[nCt][nPosA] == "3"
			aAux[nCt][nPosA] := "A"
			ElseIf aAux[nCt][nPosA] == "4"
			aAux[nCt][nPosA] := "H"
			EndIf
		Next
	aCols := aAux
	EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD050LinOk ³Autor ³ Programacao Quality³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Verifica os campos obrigatorios da GetDados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD050LinOk()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA050                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050LinOk(cAlias3)

Local nx      := 0
Local nPos1   := 0
Local nPos2   := 0
Local nPos3   := 0
Local nPos4   := 0
Local nPos5   := 0
Local nPos6   := 0
Local nCont   := 0
Local nContA  := 0
Local nContB  := 0
Local lRet    := .t.
Local cCod    := QDH->QDH_DOCTO + "  RV:" + QDH->QDH_RV
Local nContC  := 0                       
Local aReAuse := {}
Local nPos7	  := 0
Local nPos8	  := 0
Local nPos9	  := 0
Local nPos11  := 0

	If aCols[n, nUsado + 1]  == .f.
	nPos1 := GdfieldPos("QD6_CHAVE" ,aHeader)
	nPos2 := GdfieldPos("QDB_SEQ"   ,aHeader)
	nPos3 := GdfieldPos("QD0_AUT"   ,aHeader)
	nPos4 := GdfieldPos("QD0_FILMAT",aHeader)
	nPos5 := GdfieldPos("QD0_MAT"   ,aHeader)
	nPos6 := GdfieldPos("QD0_ORDEM" ,aHeader)
	nPos7 := GdfieldPos("QDB_DOCREF",aHeader)
	nPos8 := GdfieldPos("QD0_NOME"  ,aHeader)
	nPos9 := GdfieldPos("QD0_DEPTO" ,aHeader)		
	nPos10 := GdfieldPos("QDV_NORMA" ,aHeader)
    nPos11:= GdFieldPos("QDB_ORIGEM",aHeader)

		If nPos1 <> 0 .Or. nPos2 <> 0 .Or. ( nPos3 <> 0 .And. nPos4 <> 0 .And. nPos5 <> 0 ) .Or. ( nPos3 <> 0 .And. nPos6 <> 0 ) .or. nPos10 <> 0
			If nPos1 <> 0
			Aeval( aCols, { |X| If( X[nPos1] == aCols[N, nPos1] .And. X[nUsado+1] == .F., nCont ++ , nCont ) } )
			EndIf
			If nPos2 <> 0
			Aeval( aCols, { |X| If( X[nPos2] == aCols[N, nPos2] .And. X[nUsado+1] == .F., nCont ++ , nCont ) } )
			EndIf
			If nPos3 <> 0 .And. nPos4 <> 0 .And. nPos5 <> 0
			Aeval( aCols, { |X| If( X[nPos3] == aCols[N, nPos3] .And. X[nPos4] == aCols[N, nPos4] .And. X[nPos5]==aCols[N, nPos5] .And. X[nUsado+1] == .F., nContA ++ , nContA ) } )
			EndIf
			If nPos3 <> 0 .And. nPos6 <> 0
			Aeval( aCols, { |X| If( X[nPos3] == aCols[N, nPos3] .And. X[nPos6] == aCols[N, nPos6] .And. X[nUsado+1] == .F., nContB ++ , nContB ) } )
			EndIf
			If cAlias3 == "QDB"
				If nPos7 <> 0
				Aeval( aCols, { |X| If( X[nPos11] == "I" .And. X[nPos7] == aCols[N, nPos7] .And. X[nUsado+1] == .F., nContC ++ , nContC ) } )
				EndIf
			Else
				If nPos7 <> 0
				Aeval( aCols, { |X| If( X[nPos7] == aCols[N, nPos7] .And. X[nUsado+1] == .F., nContC ++ , nContC ) } )
				EndIf
			EndIf
			If nPos10 <> 0
			Aeval( aCols, { |X| If( X[nPos10] == aCols[N, nPos10] .And. X[nUsado+1] == .F., nCont ++ , nCont ) } )
			EndIf

			If nCont > 1 .Or. nContA > 1 .Or. nContB > 1 .Or. nContC > 1
			Help(" ",1,"QALCTOJAEX") // "Informacao ja cadastrada."
			Return .f.
			EndIf
		EndIf
	
		If cAlias3 == "QDZ"
		nPos1 := GdfieldPos("QDZ_FILMAT",aHeader)
		nPos2 := GdfieldPos("QDZ_DEPTO" ,aHeader)
		nPos3 := GdfieldPos("QDZ_MAT"   ,aHeader)

			IF !QA_CHKDIST(.T.)
		    Return .F.
			Endif

			If nPos1 <> 0 .And. nPos2 <> 0 .And. nPos3 <> 0
			nCont  := 0
			nContA := 0
			Aeval( aCols, { |X| If( 	X[nPos1] == aCols[N, nPos1] .And.;
										X[nPos2] == aCols[N, nPos2] .And.;
										Empty(X[nPos3]) .And.;
									 	X[nUsado+1] == .F., nCont ++ , nCont ) } )
			Aeval( aCols, { |X| If( 	X[nPos1] == aCols[N, nPos1] .And.;
										X[nPos2] == aCols[N, nPos2] .And.;
										X[nPos3] == aCols[N, nPos3] .And.;
									 	X[nUsado+1] == .F., nContA ++ , nContA ) } )
				If nCont > 1 .Or. nContA > 1
				Help(" ",1,"QALCTOJAEX") // "Informacao ja cadastrada."
				Return .f.
				EndIf
			EndIf
		Aeval( aCols, { |X| If( Empty(X[nPos3]) .And. X[nUsado+1] == .F., lRet:=.F. ,"" ) } ) 
			IF !lRet
	   		Help(" ",1,"QDA050BRA") // "Campo Obrigatorio nao preenchido."				
			Return .F.		
			Endif
		Endif

		If nValRefDoc == 1
			If cAlias3 == "QDB"
			lRet:= QD050RefDc(n,aCols[n,nPos7])
			Endif
		Endif
	
		If cAlias3 == "QDB" .AND. aCols[n,GdFieldPos( "QDB_ORIGEM" ,aHeader)]	== "E"
		aAllCpo := { "QD6_CHAVE", "QDB_SEQ", "QDB_ORDEM", "QDB_DESC", "QD0_AUT", "QD0_FILMAT", "QD0_ORDEM", "QD0_MAT", "QDV_NORMA" }
		Else
		aAllCpo := { "QD6_CHAVE", "QDB_SEQ", "QDB_ORDEM", "QDB_DOCREF", "QDB_DESC", "QD0_AUT", "QD0_FILMAT", "QD0_ORDEM", "QD0_MAT", "QDV_NORMA" }
		EndIf

		For nx := 1 To Len( aHeader )
			If Empty( aCols[n][nx] )
			nItem := Ascan( aAllCpo, { |X| Upper( Alltrim( X ) ) == Upper( Alltrim( aHeader[nx][2] ) ) } )
				If nItem > 0
					If Lastkey() <> 27
					Help(" ",1,"QDA050BRA",, Alltrim(TitSx3(aHeader[nx][2])[1]),2,2) // "Campo Obrigatorio nao preenchido."
					lRet := .f.
					EndIf
				Exit
				EndIf
			EndIf
		Next nx
	EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD050TudOk ³Autor ³ Programacao Quality³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Verifica os campos obrigatorios da GetDados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD050TudOk()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA050                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050TudOk(cAlias3)

Local nx      := 0
Local nPos3   := 0
Local nPos4   := 0
Local nPos5   := 0
Local nPos7   := 0
Local nCont   := 0
Local lRet    := .t.
Local aReAuse := {}

	If cAlias3 == "QD0"
	nPos3 := GdfieldPos("QD0_AUT"   ,aHeader)
	nPos4 := GdfieldPos("QD0_FILMAT",aHeader)
	nPos5 := GdfieldPos("QD0_MAT"   ,aHeader)

		For nx:= 1 To Len(aCols)
			If aCols[nx, nUsado + 1]  == .f.
			aReAuse:= QA_SitAuse(aCols[nx][nPos4],aCols[nx][nPos5],aCols[nx][nPos3])
				IF aReAuse[1]
		        nCont:=0
				Aeval( aCols, { |X| If( X[nPos3] == aCols[nx][nPos3] .AND. X[nPos4] == aReAuse[2] .AND.  X[nPos5] == aReAuse[3] .And. X[nUsado+1] == .F., nCont ++ , nCont ) } )
					
					If nCont > 0
					Help(" ",1,"QX040JEAP",,; // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."
					OemToAnsi(STR0153)+chr(13)+chr(10)+;   //"Inconsistencia na "
					OemToAnsi(STR0154)+chr(13)+chr(10)+;  //"Ausencia Temporaria entre Usuarios "
					OemToAnsi(STR0155)+chr(13)+chr(10)+;	  //"de mesma Responsabilidade. "
					OemToAnsi( If( SubStr(aCols[nx][nPos3],1,1) == "E",STR0087,;		// "Elaborador"
						If( SubStr(aCols[nx][nPos3],1,1) == "R",STR0088,;		// "Revisor"
							If( SubStr(aCols[nx][nPos3],1,1) == "A",STR0083,;		// "Aprovador"
								If( SubStr(aCols[nx][nPos3],1,1) == "H",STR0084, "")))))+chr(13)+chr(10)+; // "Homologador"
					OemToAnsi(STR0156)+chr(13)+chr(10)+;   //"Usuario Atual:"
					"(" + Alltrim(aCols[nx][nPos4]+"-"+aCols[nx][nPos5]) + " : " + AllTrim(QA_NUSR(aCols[nx][nPos4],aCols[nx][nPos5])) + ")"+chr(13)+chr(10)+; 
					OemToAnsi(STR0150)+chr(13)+chr(10)+; //"Para o Usuario da Ausencia Temporaria:" 
					"(" + Alltrim(aReAuse[2] +"-"+aReAuse[3] ) + " : " + AllTrim(QA_NUSR(aReAuse[2] ,aReAuse[3] )) + ")",04,00) 
					Return .F.
								Endif
							Endif
						Endif
					Next
					If ExistBlock("QDOAP32")
		lRet := ExecBlock("QDOAP32", .f., .f.)
					Endif
				ElseIf cAlias3 == "QDB"
	nPos7 := GdfieldPos("QDB_DOCREF",aHeader)
					For nx:= 1 To Len(aCols)
						If aCols[nx, nUsado + 1]  == .f.
							If nValRefDoc == 1
								IF !QD050RefDc(nx,aCols[nx,nPos7], .T.)
					lRet:= .F.	
					Exit	
								Endif
							Endif
						Endif
					Next
				EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD050EdTxt ³Autor ³ Programacao Quality³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Textos do Documento                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³QD050EdTxt(ExpC1,ExpN1,ExpC2,ExpA1,ExpC3,ExpC4,ExpC5,ExpC6³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 - Tipo                                             ³±±
±±³           ³ ExpN1 - Opcao do MBrowse                                 ³±±
±±³           ³ ExpC2 - cArq                                             ³±±
±±³           ³ ExpA1 - Cabecalho                                        ³±±
±±³           ³ ExpC3 - Documento                                        ³±±
±±³           ³ ExpC4 - Revisao do Documento                             ³±±
±±³           ³ ExpC5 - Etapa do Documento                               ³±±
±±³           ³ ExpC6 - Chave do Documento                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA050                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050EdTxt(cTipo,nOpc,cArq,aHeader,cDocto,cRv,cStatus,cChaveQDH)

Local axTextos  := {}
Local cCabec    := ""
Local cChave    := ""
Local cCod      := ""
Local cEspecie  := ""
Local cSvFilAnt := cFilAnt
Local cTitulo   := ""
Local lEdit     := .F.
Local lRet      := .T.
Local nLocTxt   := 0
Local nReg      := QDH->(Recno())
Local nTamLin   := TamSX3( "QA2_TEXTO" )[1]
 
Default cArq      := ""
Default cChaveQDH := M->QDH_CHAVE
Default cDocto    := M->QDH_DOCTO
Default cRv       := M->QDH_RV
Default cStatus   := M->QDH_STATUS
Default cTipo     := " "


cCod  := cDocto + "  RV:" + cRv
cChave:= xFilial( "QDH" ) + cCod

If Empty( cDocto ) .Or. Empty( cRv )
	Return .f.
EndIf

If (nOpc == 3 .or. nOpc == 4 .Or. nOpc == 7 ) .And. ( cStatus $ "D  ,E  ,DC ,EC " .Or. lAltDoc )
	lEdit := .t.
EndIf

If nOpc == 6 .Or. (nOpc == 4 .And. (QDH->QDH_CANCEL == "S" .And. cStatus $ "D  ,E  ,DC ,EC " ))
	If cTipo == "REV"
		lEdit:= .t.
	Else
		lEdit:= .f.
	EndIf
EndIf

If cTipo == "OBJ"
	cEspecie := "OBJ     "
	cTitulo  := OemtoAnsi( STRTRAN(STR0028,"&","") )  // "O&BJETIVO"
	cCabec   := OemtoAnsi(STR0046)  // "Objetivo do Documento"
ElseIf cTipo == "REV"
	cEspecie := "REV     "
	cTitulo  := OemtoAnsi(STR0044)  // "Revis„o"
	cCabec   := OemtoAnsi( STRTRAN(STR0035,"&","") )  // "&MOTIVO DA REVISAO"
ElseIf cTipo == "SUM"
	cEspecie := "SUM     "
	cTitulo  := OemtoAnsi( STRTRAN(STR0031,"&","") )  // "S&UMARIO"
	cCabec   := OemtoAnsi( STRTRAN(STR0031,"&","") )  // "S&UMARIO"
ElseIf cTipo == "TXT"
	cEspecie := "TXT     "
	cTitulo  := OemtoAnsi(STR0047)  // "Texto"
	cCabec   := OemtoAnsi(STR0047)  // "Texto"
ElseIf cTipo == "ITA"
	cEspecie := "ITA     "
	cTitulo  := OemtoAnsi( STRTRAN(STR0081,"&","") )  // "I&TENS ALTERADOS"
	cCabec   := OemtoAnsi( STRTRAN(STR0081,"&","") )  // "I&TENS ALTERADOS"
ElseIf cTipo == "RED"
	cEspecie := "RED     "
	cTitulo  := OemtoAnsi(STR0147)    //"Revalidação"
	cCabec   := OemtoAnsi(STR0147)        //"Revalidação"
EndIf

If Empty(cChaveQDH)
	cChave := QA_CvKey( cChave, "QDH", 2, "QDP", 2, .T., {"OBJ","TXT","COM","REV","SUM","CRI","CRT","ITA","RED"} )
	cChaveQDH := cChave
	M->QDH_CHAVE:= cChaveQDH
	If !Inclui .And. !(nOpc == 7)
		RecLock("QDH", .f. )
			QDH->QDH_CHAVE := cChave
		MsUnlock()          
		FKCOMMIT()
	EndIf
Else
	cChave := cChaveQDH
EndIf

nLocTxt:=ASCAN(aTxtREsul,{|X| x[1]==cEspecie .AND. X[2]==cChave})

IF nLocTxt==0
	If  cFilAnt <> M->QDH_FILIAL .AND. !Empty(AllTrim(xFilial("QDH")))
		cFilAnt := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV
		If QA_TEXTO( cChave, cEspecie, nTamlin, cTitulo, cCod, @axtextos, 1, cCabec,lEdit,,IIF(IsInCallStack("QD050Final"),.F.,.T.))
			AADD(aTxtREsul,{cEspecie,cChave, axtextos,QDH->QDH_CHAVE,nOpc,nReg,""} )
		EndIf
		cFilAnt := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
	Else                                                                                    
		If QA_TEXTO( cChave, cEspecie, nTamlin, cTitulo, cCod, @axtextos, 1, cCabec, lEdit,,IIF(cTipo == "OBJ" .And. !SuperGetMv("MV_QDOOBJO",.F.,.F.), .F., NIL))
			AADD(aTxtREsul,{cEspecie,cChave,axtextos,QDH->QDH_CHAVE,nOpc,nReg,""} )
		EndIf
	EndIf
Else
	axtextos := aTxtREsul[nLocTxt,3]
	If QA_TEXTO( cChave, cEspecie, nTamlin, cTitulo, cCod, @axtextos, 1, cCabec,lEdit,,IIF(IsInCallStack("QD050Final"),.F.,.T.))
		aTxtREsul[nLocTxt,3]:= axtextos 
	Endif
Endif

If Inclui .Or. nOpc == 7
	lIncDepois:=.T.
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD050Final³ Autor ³ Newton R. Ghiraldelli ³ Data ³ --/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Confirma o cadastramento de um documento                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QDO50Final(ExpB1,ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpB1 - Bloco de Codigo bCampo                              ³±±
±±³          ³ExpN1 - Opcao do MBrowse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³QDOA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050Final( bCampo, nOpc )

Local aOrdem     := {{"D  ","E  ",0}, {"DC ","E  ",0}, {"E  ","R  ",0}, {"EC ","D  ",0}, {"R  ","A  ",0}, {"RC ","E  ",0}, {"A  ","H  ",0}, {"AC ","E  ",0}, {"H  ","I  ",0}, {"HC ","E  ",0}, {"L  ","L  ",0}}
Local aQPath     := QDOPATH()
Local aUsrMat    := QA_USUARIO()
Local cMatCod    := aUsrMat[3]
Local cMatDep    := aUsrMat[4]
Local cMatFil    := aUsrMat[2]
Local cMvQAQuest := GetMv("MV_QAQUEST",.F.,"N")
Local cMvQDBxAle := GetMv("MV_QDBXALE",.F.,"N")
Local cQLeuDoc   := GetMV("MV_QLEUDOC",.F.,"S")
Local cQPath     := aQPath[1]
Local cQPathTrm  := aQPath[3]
Local cStatus    := M->QDH_STATUS
local ic         := 0
Local lBloqMsg   := If(GetMv("MV_QBLQMSG",.T.,"1") == "1",.T.,.F.) //Bloqueia a finalizacao de doc. externo, quando nao informado. 1=Sim /2=Nao                          
Local lContinua  := .T.
Local lCritica   := .F.
Local lDestinos  := .F.
Local lFim       := .F.
Local lGrava     := .T.
Local nHandle    := 0
Local nPontoAt   := 0
Local nPosOBJ	 := 0
Local nPosREV	 := 0
Local nQD4Chave  := GdFieldPos("QD4_CHAVE" ,aHedDoc[5])
Local nQD4Pend   := GdFieldPos("QD4_PENDEN",aHedDoc[5])
Local nQDG       := 0
Local nT         := 0

Private cChave   := M->QDH_FILIAL + M->QDH_DOCTO + " RV:" + M->QDH_RV
Private cOrdResp := "00" // Ordem de Responsavel do Usuario Logado
Private nBaixa   := 1
Private nPend    := 0
Private nQD0Aut  := GdFieldPos("QD0_AUT" ,aHedDoc[1])
Private nQD0Dept := GdFieldPos("QD0_DEPTO" ,aHedDoc[1])
Private nQD0Film := GdFieldPos("QD0_FILMAT",aHedDoc[1])
Private nQD0Flag := GdFieldPos("QD0_FLAG" ,aHedDoc[1])
Private nQD0Mat  := GdFieldPos("QD0_MAT" ,aHedDoc[1])
Private nQD0Ord  := GdFieldPos("QD0_ORDEM" ,aHedDoc[1])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tenta Criar arquivo teste para ver se diretorio existe³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nHandle := fCreate(cQPath+"SIGATST.CEL")
	If nHandle <> -1  // Consegui criar e vou fechar e apagar novamente...
		fClose(nHandle)
		fErase(cQPath+"SIGATST.CEL")
	Else
		Help(" ",1,"QDO50DNE") // "Diretorio para gravacao do Documento nao existe, solicite o administrador do sistema"
		Return .f.
	EndIf

	M->QDH_DOCTO := Left(M->QDH_DOCTO+Space(16),16)
	M->QDH_STATUS:= Left(M->QDH_STATUS+Space(3),3)

	If M->QDH_DTOIE == "I"
		If Empty( M->QDH_NOMDOC )
			Help(" ",1,"QD050DND") // "Documento nao foi criado."
			Return .F.
		EndIf
		If INCLUI
			If !File(cQPath+Alltrim(M->QDH_NOMDOC))	.AND. File(cQPathTrm+AllTrim(M->QDH_NOMDOC))
				//CpyT2S(cQPathTrm+AllTrim(M->QDH_NOMDOC),cQPath,.T.)	   
				QDX_CPYT2S(cQPathTrm+AllTrim(M->QDH_NOMDOC), cQPath, AllTrim(M->QDH_NOMDOC))							
			EndIf
		EndIf
		If !File(cQPathTrm+Alltrim(M->QDH_NOMDOC))
			CpyS2T(cQPath+Alltrim(M->QDH_NOMDOC),cQPathTrm,.T.)
			If !File(cQPathTrm+Alltrim(M->QDH_NOMDOC))
				If M->QDH_STATUS  == "D  "
					M->QDH_NOMDOC:= Criavar("QDH_NOMDOC",.F.)
				EndIf
				Help(" ",1,"QDDOCGERR") //"Nao foi encontrada a referencia do arquivo na base de dados."
				Return .F.
			EndIf
		EndIf
	Else
		If M->QDH_DTOIE == "E"
			If lBloqMsg
				If Empty( M->QDH_NOMDOC )
					Help(" ",1,"QD050DND") // "Documento nao foi criado."
					Return .F.
				EndIf
				if nopc == 4 .AND. AllTrim(M->QDH_STATUS) $ "E|R|EC"    // salva no servidor documento alterado que estava com elaboração e critica.
					QDX_CPYT2S(cQPathTrm+AllTrim(M->QDH_NOMDOC), cQPath, AllTrim(M->QDH_NOMDOC))							
				Endif
				If !File(cQPathTrm+Alltrim(M->QDH_NOMDOC))
					CpyS2T(cQPath+Alltrim(M->QDH_NOMDOC),cQPathTrm,.T.)
					If !File(cQPathTrm+Alltrim(M->QDH_NOMDOC))
						M->QDH_NOMDOC:= "DOCEXT"+Alltrim(Str(Day(Date())))+Alltrim(Str(Month(Date())))+Alltrim(Str(Year(Date())))
					EndIf
				EndIf
			Endif
		Endif
	EndIf

	If Empty(M->QDH_DOCTO) .Or. Empty(M->QDH_RV)
		Return .F.
	EndIf

	If M->QDH_STATUS == "I  "
		Return .F.
	EndIf
	QD1->(DbSetOrder(1))
	If QD1->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+cMatDep+cMatFil+cMatCod))
		While QD1->(!Eof()) .And. M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+cMatDep+cMatFil+cMatCod ==	QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_DEPTO+QD1->QD1_FILMAT+QD1->QD1_MAT
			If QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND == M->QDH_STATUS .And. QD1->QD1_SIT <> "I"
				If QD1->QD1_LEUDOC == "S" .Or. cQLeuDoc == "N" .Or. (M->QDH_DTOIE == "E" .And. (At("DOCEXT",M->QDH_NOMDOC) > 0 .Or. M->QDH_STATUS == "D  "))
					lContinua := .T.
				Else
					If M->QDH_DTOIE == "E" .And. !lBloqMsg
						lContinua := .T.
					Else
						Help(" ",1,"QD050LER") // "Nao e permitido baixar o documento sem antes ler.""
						lContinua := .F.
					Endif
				EndIf
			EndIf
			QD1->(DbSkip())
		EndDo
	EndIf

	If lRevisao
		If QD1->QD1_LEUDOC == "S" .Or. cQLeuDoc == "N" .Or. (M->QDH_DTOIE == "E" .And. (At("DOCEXT",M->QDH_NOMDOC) > 0 .Or. M->QDH_STATUS == "D  "))
			lContinua := .T.
		Else
			If M->QDH_DTOIE == "E" .And. !lBloqMsg
				lContinua := .T.
			Else
				Help(" ",1,"QD050LER") // "Nao e permitido baixar o documento sem antes ler.""
				lContinua := .F.
			Endif
		EndIf
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se foi digitado Motivo da Revisao       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(M->QDH_CHAVE)
   		cChave:= QA_CvKey(cChave,"QDH",2)
   		M->QDH_CHAVE:= cChave
	Else
   		cChave:= M->QDH_CHAVE
	EndIf

	If lContinua .And. (lAltDoc .Or. cValToChar(nOpc) $ '4|6|7') 
		//Carrega/recarrega o conteúdo do Motiv. Revisão, não abre a telinha de digitação
		QD050EdTxt("REV",nOpc)
		nPosREV := aScan(aTxtResul, {|x| AllTrim(Upper(x[1])) == "REV"})
		If nPosREV == 0 .Or. Empty(aTxtResul) .Or. Empty(aTxtResul[nPosREV][3][1][2])
			Help(" ",1,"QD050MOTRV") // "O campo motivo da revisao e obrigatorio."
			lContinua := .F.
		EndIf
		//Carrega/recarrega o conteúdo do Objetivo
		QD050EdTxt("OBJ",nOpc)
		nPosOBJ := aScan(aTxtResul, {|x| AllTrim(Upper(x[1])) == "OBJ"})
		If SuperGetMv("MV_QDOOBJO",.F.,.F.) .And. lContinua .And. (nPosOBJ == 0 .Or. Empty(aTxtResul) .Or. Empty(aTxtResul[nPosOBJ][3][1][2]) .And. nOpc!=6)
			//STR0182 "Campo Obrigatório"
			//STR0183 "O campo Objetivo é obrigatório"
			//STR0184 "Clique no botão OBJETIVO e preencha o campo"
			Help(NIL, NIL, STR0182, NIL, STR0183, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0184}) 
			lContinua := .F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se responsaveis estao respeitando o cadastro de tipo de documentos    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua .AND. (M->QDH_STATUS == "D  " .OR. M->QDH_STATUS == "E  ") .AND. (nOpc==3 .Or. nOpc==6 .Or. nOpc==4)//Valida apenas na inclusão ou revisão 
		If !QD050CHKRES() 
			lContinua:= .F.
		EndIf
	EndIf  

	If !lContinua
		Return .F.
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe Destinatarios Cadastrados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aQDJDoc) > 0
		For nT := 1 to Len(aQDJDoc)
			aEval(aQDJDoc[nT,9],{|x| nQDG += If(x[9] == "S" .And. x[12]<> "I",1,0) })
			If nQDG > 0
				lDestinos := .T.
				Exit
			Endif
		Next
	EndIf

	If !lDestinos
			Help(" ",1,"QD050DBR") // "E obrigatorio o cadastramento dos destinos do documento." 
			Return .f.
	EndIf

	If SubsTr(M->QDH_STATUS,1,1) == "E"
		cStatus := "DC "
	ElseIf M->QDH_STATUS $ "R  /A  /H  "
		cStatus := "EC "
	EndIf

	cEspecie  := Left("CRI"+Space(8),8)

	For ic:=1 To LEN(aQD4Doc)
		If !aQD4Doc[ic,Len(aQD4Doc[ic])]
			If M->QDH_STATUS == "EC " .OR. M->QDH_STATUS == "DC "
				IF aQD4Doc[ic,nQD4Pend]=="P"
					lCritica:= .T.     
					Exit
				Endif
			Else
				IF aQD4Doc[ic,nQD4Pend]=="P"
					IF ASCAN(aTxtResul,{|X| x[1]==cEspecie .AND. X[2]==aQD4Doc[ic][nQD4Chave]})!=0
						lCritica:= .T.
						Exit
					EndIf
				Endif
			Endif
		Endif
	Next

	If lCritica
		Help(" ",1,"QD050ECP") // "Existem criticas pendentes para este documento."
		Return .F.
	EndIf

	If cStatus <> "L  "
		If !QDA050CKDT(aOrdem)
			Help(" ",1,"QD050CCNER")	// Nao existe Responsavel para Depto ou esta Demitido
			Return .F.
		Endif
	Endif

	If !MsgYesNo(OemtoAnsi(STR0048),OemToAnsi(STR0023)) // "Finalizar Documento ?"  ### "Aten‡„o"
		Return .F.
	Else
		// Incluido tratamento para finalizacao do documento
		If Type("INCLUI") == "L" .And. INCLUI .AND. nOpc <> 3
			INCLUI := .F.
		EndIf
		
		lFinalDoc := .T.
	EndIf

	If ExistBlock( "QDOAPPSW" )
		llPassW := .T.
		ExecBlock( "QDOAPPSW", .f., .f. )
		If !llPassW
			Return .f.
		EndIf
	EndIf

	IF ExistBlock( "QD050TOK" )
		lGrava := ExecBlock( "QD050TOK", .F., .F. )
		If lGrava == NIL
			lGrava := .F.
		EndIf
	Else
		lGrava := .T.
	EndIf

	IF ExistBlock( "QDOAP12" )
	lFim := ExecBlock( "QDOAP12", .f., .f. )
		If lFim == NIL
			lFim := .F.
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o Questionario devera ser respondido. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If M->QDH_STATUS == "L  " .And. M->QDH_QUEST == "1"
			If cMvQAQuest == "S"
			nPontoAt := 0
				If !QX050QRes(M->QDH_FILIAL,M->QDH_DOCTO,M->QDH_RV,@nPontoAt)
				Return .F.
				EndIf
			EndIf
		EndIf

		If cMvQdBxAle == "S"
			lFim:= Qd050FAlea(nOpc,cMatFil,cMatCod,cMatDep,aOrdem)		
		Else
			lFim:= Qd050FOrd(nOpc,cMatFil,cMatCod,cMatDep,aOrdem)
		EndIf
                                                              
		IF lFim .And. lGrava
			QD050GrDoc(bCampo,nOpc,,aOrdem,,nPontoAt)			    
		Endif
    
	EndIf

	IF lFim
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza Lancamentos de Ausencia Temporaria  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CursorWait()
		QDX040Atu()
		CursorArrow()
	Endif

Return lFim .And. lGrava

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD050GrDoc³ Autor ³ Programacao Quality   ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava Documento                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD050GrDoc( ExpB1,ExpN1,ExpL1)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpB1 - Bloco de Codigo bCampo                             ³±±
±±³          ³ ExpN1 - Opcao do MBrowse                                   ³±±
±±³          ³ ExpL1 - Opcao do Devolucao 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050GrDoc(bCampo,nOpc,lPen,aOrdem,lDev,nPontoAt)
Local aARea		 := {}
Local aQPath     := QDOPATH()
Local cAliasQry  := ""
Local cAVREF     := GetMv("MV_QDAVREF",.F.,"1") //Define se gera aviso de Referencia na inclusao ou na revisao do documento 1=SIM;2=NAO
Local cBscStatus := ""                          
Local cDepQD0    := "" 
Local cFilQad	 := If(FWModeAccess("QAD")=="C",xFilial("QAD"), M->QDH_FILDEP) //Space(2) Empty(xFilial("QAD"))
Local cFilQD0    := ""
Local cMatQD0    := ""
Local cMvQDRefIn := GetMv("MV_QDREFIN",.F.,"1") //Define a Referencia do Documento Invertida 1-PaisxFilhos,2-FilhosXPais,3-AMBAS)
Local cNumOrd    := "00"
Local cOldStatus := M->QDH_STATUS
Local cQPath     := aQPath[1]
Local cQPathTrm  := aQPath[3]
Local cQuery	 := ""
Local cSaveWFHTM := GetMV("MV_QDWHTML",.F.,"2") // "Grava Html para Workflow"
Local cStatus    := M->QDH_STATUS
Local cStatusAnt := ""                 
Local cSvFilAnt	 := cFilAnt
Local i          := NIL
Local lBxMinR    := .T. 
Local lGRDoc	 := .T.
Local lIncQd1    := .F.
Local lPula      := .T.
Local lQDBxAle 	 := GetMv("MV_QDBXALE") == "S"
Local lRec		 := If(nOpc == 3 .Or. nOpc == 7 .Or. nOpc == 6,.T.,.F.)
Local lRespons   := .F.
Local lTemNrMin  := .F. 
Local lTermina   := .T.
Local nC         := 0
Local nItem      := NIL
Local nMinResp   := 99
Local nOrdQAA    := QAA->(IndexOrd())
Local nOrdQD1    := QD1->(IndexOrd())
Local nOrdQDS    := QDS->(IndexOrd())

Default aOrdem   := { {"D  ","E  ",0}, {"DC ","E  ",0}, {"E  ","R  ",0}, {"EC ","D  ",0}, {"R  ","A  ",0}, {"RC ","E  ",0}, {"A  ","H  ",0}, {"AC ","E  ",0}, {"H  ","I  ",0}, {"HC ","E  ",0}, {"L  ","L  ",0} }
Default lDev	 := .F.  //Documento Pendente
Default lPen	 := .F.  //Documento Devolvido com Critica
Default nPontoAt := 0

	If QD5->(DbSeek(xFilial("QD5")+M->QDH_CODTP+If(SubStr(M->QDH_STATUS,1,1) == "D","E",SubStr(M->QDH_STATUS,1,1))))
		nMinResp  := If(QD5->QD5_NMIN == 0,1,QD5->QD5_NMIN) //Numero minimo
		lBxMinR   := If(QD5->QD5_BXP == "S",.T.,.F.)        //Baixa Pendencia
		lTemNrMin := .T.                                    //Existe Numero minimo de responsáveis pela etapa.
	EndIf

	If ExistBlock("QDOGRDOC")
		lGRDoc:=ExecBlock("QDOGRDOC", .f., .f., {nOpc,!lPen}) 
		IF !lGRDoc
			Return .T.
		Endif
	EndIf

	CursorWait()
	Begin Transaction

		If nOpc!=2
			DbSelectArea("QDH")
			RecLock("QDH",lRec)
			For nC := 1 TO FCount()
				FieldPut( nC, M->&( Eval( bCampo, nC ) ) )
			Next nC
			if nOpc == 7
				QDH->QDH_DTFIM := ctod('  /  /  ')
			EndIf
			QDH->QDH_REVINV:=INVERTE(QDH->QDH_RV) //Revisao Invertida
			MsUnLock()
			FKCOMMIT()
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³GRAVA O FILHOS DO QDH ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QD050GRFL({"QD0","QD6","QDB","QDZ","QD4","QDV"},nOpc)
		
			IF lAltDoc
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³GRAVA O FILHOS DO QDH QDJ-QDG³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QD050GRFL1(nOpc)
			Endif
    
			// Para processos com a Tabela exclusiva, critica deve ser gravada com a filial do usuário pois na  recuperacao 
			// eu uso a filial do QD4_FILMAT
			If   FWModeAccess("QA2") == "E" .AND. QDH->QDH_FILMAT <> xFilial("QA2") //!Empty(xFilial("QA2"))
				cFilAnt		 := QDH->QDH_FILMAT //Mudo a Variavel publica de Memória como na SuperGetMV	
			EndIf
    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³GRAVA NO QA2 os texto da(s) "OBJ","TXT","COM","REV","SUM","CRI","CRT","ITA","RED","JUS"³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For i:=1 to  LEN(aTxtResul)
				QA_GrvTxt( aTxtResul[i,2], aTxtResul[i,1], 1,aTxtResul[i,3] )
				FKCOMMIT()
			Next

			If  !Empty(Alltrim(xFilial("QA2"))) .AND. QDH->QDH_FILMAT <> cSvFilAnt
				cFilAnt := cSvFilAnt //Mudo a Variavel publica de Memória como na SuperGetMV	
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³GRAVA DISTRIBUICAO QD1       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M->QDH_STATUS == "D  "
				QD1->(DbSetOrder(2))
				If !QD1->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+QDH->QDH_STATUS))
					QD050GrDst( .f.,,,,,,,,nOpc)
				EndIf
				QD1->(DbSetOrder(nOrdQD1))
			Endif
	
			If M->QDH_DTOIE == "E" .And. nOpc == 4 .And.  AllTrim(M->QDH_STATUS) $ "D|E|R|EC" .And. File(cQPathTrm+AllTrim(M->QDH_NOMDOC))
				QDX_CPYT2S(cQPathTrm+AllTrim(M->QDH_NOMDOC), cQPath, AllTrim(M->QDH_NOMDOC))
			EndIf

		Endif

		If !lPen
			If !lDev
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³GRAVA DISTRIBUICAO PROXIMO PASSO DO STATUS E QD1 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF lQDBxAle
					If SubStr(M->QDH_STATUS,1,1) == "D"
						nBaixa := 1
						cStatus:= "E  "
					Else
						cStatus:= M->QDH_STATUS
					EndIf
					QD0->(DbsetOrder(1))
					If QD0->(DbSeek(M->(QDH_FILIAL+QDH_DOCTO+QDH_RV)+SubsTr(cStatus,1,1)))
						While QD0->(!Eof()) .And. QD0->(QD0_FILIAL+QD0_DOCTO+QD0_RV+QD0_AUT) == M->(QDH_FILIAL+QDH_DOCTO+QDH_RV)+SubsTr(cStatus,1,1)
							If QD0->QD0_FLAG <> "I"
								If QD0->(QD0_FILMAT+QD0_DEPTO+QD0_MAT) == cMatFil+cMatDep+cMatCod
									If ((!lBxMinR .And. nBaixa < nPend) .Or. (lBxMinR .And. nBaixa < nMinResp)) .And. (lTemNrMin)
										lPula := .F.
									EndIf
									lRespons:= .T.							
									Exit
								EndIf
							EndIf
							QD0->(DbSkip())
						EndDo
					EndIf
			
					If !lRespons
						cStatus := M->QDH_STATUS
					Endif
			
					If lRespons .And. SubStr(M->QDH_STATUS,1,1) == "D"
						RecLock("QD1",.T.)
							QD1->QD1_FILIAL := M->QDH_FILIAL
							QD1->QD1_DOCTO  := M->QDH_DOCTO
							QD1->QD1_RV     := M->QDH_RV
							QD1->QD1_TPPEND := "E  "
							QD1->QD1_FILMAT := cMatFil
							QD1->QD1_MAT    := cMatCod
							QD1->QD1_DEPTO  := cMatDep
							QD1->QD1_FMATBX := cMatFil
							QD1->QD1_MATBX  := cMatCod
							QD1->QD1_DEPBX  := cMatDep
							QD1->QD1_DISTNE := "N"
							QD1->QD1_PENDEN := "B"
							QD1->QD1_DTGERA := dDataBase
							QD1->QD1_HRGERA := SubStr( Time(), 1, 5 )
							QD1->QD1_DTBAIX := dDataBase
							QD1->QD1_HRBAIX := Substr( Time(), 1, 5 )
							QD1->QD1_LEUDOC := "S"
							QD1->QD1_CHAVE  := M->QDH_CHAVE
							nOrdQAA := QAA->(IndexOrd())
							nRegQAA := QAA->(Recno())
							QAA->(dbSetOrder(1))
							If QAA->(DbSeek(cMatFil+cMatCod))
								QD1->QD1_CARGO  := QAA->QAA_CODFUN
								QD1->QD1_TPDIST := QAA->QAA_TPRCBT
							EndIf
							QAA->(DbSetOrder(nOrdQAA))
							QAA->(DbGoTo(nRegQAA))
						QD1->(MsUnlock())
						FKCOMMIT()
						lIncQD1:= .T.
					EndIf

					If M->QDH_STATUS <> "L  " .And. lPula
						QD1->(DbSetOrder(2))
						If QD1->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+M->QDH_STATUS))
							While QD1->(!Eof()) .And. QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_TPPEND == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+M->QDH_STATUS
								If QD1->QD1_PENDEN == "P"
									RecLock("QD1",.F.)
										QD1->QD1_DTBAIX := dDataBase
										QD1->QD1_PENDEN := "B"
										QD1->QD1_HRBAIX := SubStr( Time(), 1, 5 )
										QD1->QD1_LEUDOC := "S"
										QD1->QD1_FMATBX := cMatFil
										QD1->QD1_MATBX  := cMatCod
										QD1->QD1_DEPBX  := cMatDep
										QD1->QD1_DISTNE := "N"
									QD1->(MsUnlock())
									FKCOMMIT()
									If QD1->QD1_FILMAT+QD1->QD1_MAT+QD1->QD1_DEPTO <> cMatFil+cMatCod+cMatDep
										If QD1->QD1_TPPEND <> "D"
											If QAA->(DbSeek(QD1->QD1_FILMAT+QD1->QD1_MAT))
												If !EMPTY(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1"
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³Avisa responsavel que documento ja esta baixado ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													fQdoTpMail(@aUsrMail,QD1->QD1_DOCTO,QD1->QD1_RV,M->QDH_TITULO,QAA->QAA_EMAIL,M->QDH_STATUS,QAA->QAA_FILIAL,QAA->QAA_APELID,,,"BX",,M->QDH_CODTP,QDH->QDH_DTVIG)
												EndIf
											EndIf
										EndIf
									EndIf
								EndIf
								QD1->(DbSkip())
							Enddo
						EndIf
						lIncQD1:= .T.
					Else
						QD1->(DbSetOrder(1))
						If QD1->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+cMatDep+cMatFil+cMatCod))
							While QD1->(!Eof()) .And. QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_DEPTO+QD1->QD1_FILMAT+QD1->QD1_MAT == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+cMatDep+cMatFil+cMatCod
								If QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND == M->QDH_STATUS
									RecLock("QD1",.F.)
										QD1->QD1_DTBAIX := dDataBase
										QD1->QD1_PENDEN := "B"
										QD1->QD1_HRBAIX := SubStr( Time(), 1, 5 )
										QD1->QD1_LEUDOC := "S"
										QD1->QD1_FMATBX := cMatFil
										QD1->QD1_MATBX  := cMatCod
										QD1->QD1_DEPBX  := cMatDep
										QD1->QD1_DISTNE := "N"
										
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Grava a nota da questao caso exista o campo QD1_NTRESP  ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If QD1->QD1_TPPEND == "L  "
											QD1->QD1_NTRESP := nPontoAt
										Endif
									
									QD1->(MsUnlock())
									FKCOMMIT()
									Exit
								EndIf
								QD1->(DbSkip())
							Enddo
						EndIf
					EndIf
			
					If cStatus <> "L  "
						For nC:= AScan( aOrdem, {|x| x[1] == cStatus } ) To Len( aOrdem )
							If (nItem := Ascan( aOrdem, {|x| x[1] == aOrdem[nC, 2] } )) > 0
								If aOrdem[nItem, 3] > 0
									Exit
								EndIf
							Else
								Exit
							EndIf
							nC:= nItem - 1
						Next nC
				
						If lPula
							cStatusAnt:= M->QDH_STATUS
							M->QDH_STATUS := If( nItem == 0, "I  ", aOrdem[nItem, 1] )
							RecLock("QDH",.F.)
								QDH->QDH_STATUS:= M->QDH_STATUS
							QDH->(MsUnlock())
							FKCOMMIT()
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Salva Documento em Html                       ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If cSaveWFHTM == "1" .And. M->QDH_DTOIE == "I"	.And. ;
								(SubStr(cStatusAnt,1,1)="E" .Or. nItem >= 5)
								lSalvaWhtml := .T.
							Endif
						EndIf
				
						If M->QDH_STATUS == "I  "
							RecLock("QDH",.F.)
								QDH->QDH_DTFIM := dDataBase
							MsUnlock()
							FKCOMMIT()
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Atualizado o QD1 quando for distribuicao conforme QDZ e QAA ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							QD50DSTATU(cFilQAD,nOpc,nOrdQAA)
						Else
							If lRespons .And. SubStr(M->QDH_STATUS,1,1) == "D"
								M->QDH_STATUS := "E  "
								RecLock("QDH",.F.)
									QDH->QDH_STATUS:= "E  "
									QDH->(MsUnLock())
								FKCOMMIT()
							EndIf
							If lIncQD1
								If QD0->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+SubStr(M->QDH_STATUS,1,1)))
									While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV+QD0->QD0_AUT == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+SubStr(M->QDH_STATUS,1,1)
										If QD0->QD0_FLAG <> "I" .And. !(SubStr(M->QDH_STATUS,1,1) == "E" .And. QD0->QD0_FILMAT+QD0->QD0_MAT+QD0->QD0_DEPTO == cMatFil+cMatCod+cMatDep)
											QD050GrDst(.F., QD0->QD0_FILMAT, QD0->QD0_DEPTO, QD0->QD0_MAT,,,,,nOpc)
										EndIf
										QD0->(DbSkip())
									Enddo
								EndIf
							EndIf
						EndIf
					EndIf
			
					QD1->(DbSetOrder(nOrdQD1))
				Else
					If SubStr(M->QDH_STATUS,1,1) == "D"
						nPend  := 1
						cStatus:= "E  "
					Else
						cStatus:= M->QDH_STATUS
					EndIf
			
					If cOrdResp == "00"
						cBscStatus:= SubStr(cStatus,1,1)
					Else
						cBscStatus:= SubStr(cStatus,1,1)+cOrdResp
					EndIf
					QD0->(DbSetOrder(1))
			
					If QD0->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+cBscStatus))
						While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV+QD0->QD0_AUT == QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+SubStr(cBscStatus,1,1)
							If QD0->QD0_FLAG <> "I"
								If SubStr(M->QDH_STATUS,1,1) == "D" .And. (QD0->QD0_FILMAT+QD0->QD0_DEPTO+QD0->QD0_MAT <> cMatFil+cMatDep+cMatCod)
									cNumOrd:= QD0->QD0_ORDEM
									Exit
								Else
									If QD0->QD0_FILMAT + QD0->QD0_DEPTO + QD0->QD0_MAT == cMatFil + cMatDep + cMatCod
										cNumOrd := QD0->QD0_ORDEM
										QD0->(DbSkip())
										While !QD0->(Eof()) .And. QD0->QD0_FLAG == "I"
											QD0->(DbSkip())
										Enddo
										If QD0->QD0_FILIAL + QD0->QD0_DOCTO + QD0->QD0_RV + QD0->QD0_AUT == QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV + SubStr( cStatus, 1, 1 )
											If !lBxMinR .Or. ( lBxMinR .And. nPend < nMinResp )
												lPula := .F.
											EndIf
										EndIf
										lRespons:= .T.
										Exit
									EndIf
								EndIf
							EndIf
							QD0->(DbSkip())
						EndDo
					EndIf
			
					If !lRespons
						cStatus := M->QDH_STATUS
					Endif
			
					If lRespons .And. SubStr(M->QDH_STATUS,1,1) == "D"
						RecLock("QD1",.T.)
							QD1->QD1_FILIAL := M->QDH_FILIAL
							QD1->QD1_DOCTO  := M->QDH_DOCTO
							QD1->QD1_RV     := M->QDH_RV
							QD1->QD1_TPPEND := "E  "
							QD1->QD1_FILMAT := cMatFil
							QD1->QD1_MAT    := cMatCod
							QD1->QD1_DEPTO  := cMatDep
							QD1->QD1_FMATBX := cMatFil
							QD1->QD1_MATBX  := cMatCod
							QD1->QD1_DEPBX  := cMatDep
							QD1->QD1_DISTNE := "N"
							QD1->QD1_PENDEN := "B"
							QD1->QD1_DTGERA := dDataBase
							QD1->QD1_HRGERA := SubStr( Time(), 1, 5 )
							QD1->QD1_DTBAIX := dDataBase
							QD1->QD1_HRBAIX := Substr( Time(), 1, 5 )
							QD1->QD1_LEUDOC := "S"
							QD1->QD1_CHAVE  := M->QDH_CHAVE
							nOrdQAA := QAA->(IndexOrd())
							nRegQAA := QAA->(Recno())
							QAA->(dbSetOrder(1))
							If QAA->(DbSeek(cMatFil+cMatCod))
								QD1->QD1_CARGO  := QAA->QAA_CODFUN
								QD1->QD1_TPDIST := QAA->QAA_TPRCBT
							EndIf
							QAA->(DbSetOrder(nOrdQAA))
							QAA->(DbGoTo(nRegQAA))
						QD1->(MsUnlock())
						FKCOMMIT()
					EndIf
					QD1->(DbSetOrder(1))
					If QD1->(DbSeek( M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod ))
						While QD1->(!Eof()) .And. M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod == QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_DEPTO + QD1->QD1_FILMAT + QD1->QD1_MAT
							If QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND == M->QDH_STATUS
								RecLock("QD1",.F.)
									QD1->QD1_DTBAIX := dDataBase
									QD1->QD1_PENDEN := "B"
									QD1->QD1_HRBAIX := SubStr( Time(), 1, 5 )
									QD1->QD1_LEUDOC := "S"
									QD1->QD1_FMATBX := cMatFil
									QD1->QD1_MATBX  := cMatCod
									QD1->QD1_DEPBX  := cMatDep
									QD1->QD1_DISTNE := "N"
									
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Grava a nota da questao caso exista o campo QD1_NTRESP  ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If QD1->QD1_TPPEND == "L  "
										QD1->QD1_NTRESP := nPontoAt
									Endif
								
								QD1->(MsUnlock())
								FKCOMMIT()
								Exit
							EndIf
							QD1->(DbSkip())
						Enddo
					EndIf
			
					QD1->(DbSetOrder(2))
					If QD1->(DbSeek( QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV + QDH->QDH_STATUS ))
						While QD1->(!Eof()) .And. QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV + QDH->QDH_STATUS == QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_TPPEND
							If QD1->QD1_PENDEN == "P"
								lTermina:= .F.
								Exit
							EndIf
							QD1->(DbSkip())
						Enddo
					EndIf
			
					nItem:= Ascan( aOrdem, { |X| X[1] == M->QDH_STATUS } )
					If lTermina .And. cStatus <> "L  "
						For nC:= AScan( aOrdem, {|x| x[1] == cStatus } ) To Len( aOrdem )
							If (nItem := Ascan( aOrdem, {|x| x[1] == aOrdem[nC, 2] } )) > 0
								If aOrdem[nItem, 3] > 0
									Exit
								EndIf
							Else
								Exit
							EndIf
							nC:= nItem - 1
						Next nC
						If lPula
							M->QDH_STATUS := If( nItem == 0, "I  ", aOrdem[nItem, 1] )
							cNumOrd:= "00"
							RecLock("QDH",.F.)
								QDH->QDH_STATUS:= M->QDH_STATUS
							QDH->(MsUnlock())
							FKCOMMIT()
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Salva Documento em Html                       ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If cSaveWFHTM == "1" .And. M->QDH_DTOIE == "I"	.And. ;
								(SubStr(cStatusAnt,1,1)="E" .Or. nItem >= 5)
								lSalvaWhtml := .T.
							Endif
						EndIf
						If QDH->QDH_STATUS == "I  "
							RecLock("QDH",.F.)
								QDH->QDH_DTFIM := dDataBase
							MsUnlock()
							FKCOMMIT()
							//ÚÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Atualizado o QD1 quando for distribuicao conforme QDZ e QAA ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							QD50DSTATU(cFilQAD,nOpc,nOrdQAA)
						Else
							If lRespons .And. SubStr(M->QDH_STATUS,1,1) == "D"
								M->QDH_STATUS := "E  "
								RecLock("QDH",.F.)
									QDH->QDH_STATUS:= "E  "
								QDH->(MsUnLock())
								FKCOMMIT()
							EndIf
							If QD0->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+SubStr(QDH->QDH_STATUS,1,1)))
								While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV+QD0->QD0_AUT == QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+SubStr(QDH->QDH_STATUS,1,1)
									If QD0->QD0_FLAG <> "I" .And. QD0->QD0_ORDEM > cNumOrd
										QD050GrDst(.F.,QD0->QD0_FILMAT,QD0->QD0_DEPTO,QD0->QD0_MAT,,,,,nOpc)
										Exit
									EndIf
									QD0->(DbSkip())
								Enddo
							EndIf
						EndIf
					EndIf
					QD1->(DbSetOrder(nOrdQD1))
				Endif
		
				If cOldStatus == "D  "
			       
					aArea:=GetARea()                  

					IF cMvQDRefIn=="1"  .or. cMvQDRefIn =="3"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se existem referencias Normais PAIxFILHOS³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
						cQuery := " SELECT QDH.QDH_FILIAL,QDH.QDH_DOCTO,QDH.QDH_RV,QDH.QDH_TITULO,QDH.QDH_CODTP,QDH.QDH_DTVIG, "
						cQuery += " QAA.QAA_EMAIL,QAA.QAA_RECMAI,QAA.QAA_APELID,QAA.QAA_FILIAL,QAA.QAA_MAT,QAA.QAA_CC "
						cQuery += " FROM " 
						cQuery +=  RetSqlName("QDB") +" QDB, " 
						cQuery +=  RetSqlName("QDH") +" QDH, "
						cQuery +=  RetSqlName("QD0") +" QD0, "         					
						cQuery +=  RetSqlName("QAA") +" QAA "

						cQuery += " WHERE QDB.QDB_FILIAL = '" + M->QDH_FILIAL +"'"
						cQuery += " AND QDB.QDB_DOCTO = '"+ M->QDH_DOCTO +"'"
						cQuery += " AND QDB.QDB_RV	  = '"+ M->QDH_RV +"'"
						cQuery += " AND QDB.QDB_REVIS = 'S' "
						cQuery += " AND QDB.D_E_L_E_T_ <> '*' "

						cQuery += " AND QDH.QDH_FILIAL = QDB.QDB_FILIAL "
						cQuery += " AND QDH.QDH_DOCTO = QDB.QDB_DOCREF "
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³SubSelect para garantir a ultima revisao do QDH   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
						cQuery += " AND QDH.QDH_RV = ( SELECT  MAX(QDH2.QDH_RV) FROM "+RetSqlName("QDH") +" QDH2"  
						cQuery += " WHERE QDH2.QDH_FILIAL = QDB.QDB_FILIAL AND QDH2.QDH_DOCTO =  QDB.QDB_DOCREF "
						cQuery += " AND QDH2.QDH_CANCEL <> 'S' AND QDH2.QDH_OBSOL <> 'S' AND QDH2.QDH_STATUS = 'L  ' "
						cQuery += "	AND QDH2.D_E_L_E_T_ <> '*') "
						
						cQuery += " AND QD0.QD0_FILIAL = QDH.QDH_FILIAL "
						cQuery += " AND QD0.QD0_DOCTO = QDH.QDH_DOCTO "
						cQuery += " AND QD0.QD0_RV = QDH.QDH_RV "
						cQuery += " AND QD0.QD0_AUT = 'E' "
						cQuery += " AND QD0.QD0_FLAG <> 'I' "
						cQuery += " AND QD0.D_E_L_E_T_ <> '*' "

						cQuery +=" AND QAA.QAA_FILIAL= QD0.QD0_FILMAT "
						cQuery +=" AND QAA.QAA_MAT = QD0.QD0_MAT "
						cQuery +=" AND QAA.QAA_CC	= QD0.QD0_DEPTO "
						cQuery +=" AND "+ QA_FilSitF(.T.,.T.) 
						cQuery +=" AND QAA.D_E_L_E_T_ <> '*'  "
						
						cQuery := ChangeQuery(cQuery)
						cAliasQry  := GetNextAlias()
						
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

						TcSetField(cAliasQry,"QDH_DTVIG","D")					
						
						(cAliasQry)->(DBGotop())  
						While (cAliasQry)->(!EOF())
							If !Empty((cAliasQry)->QAA_EMAIL) .And. (cAliasQry)->QAA_RECMAI == "1"
								aDiv:={M->QDH_DOCTO,M->QDH_RV}
								FQDOTPMAIL(aUsrMail,(cAliasQry)->QDH_DOCTO,(cAliasQry)->QDH_RV,(cAliasQry)->QDH_TITULO,(cAliasQry)->QAA_EMAIL,"REF",cMatFil,(cAliasQry)->QAA_APELID,(cAliasQry)->QAA_MAT,,,aDiv,(cAliasQry)->QDH_CODTP,(cAliasQry)->QDH_DTVIG)
							EndIf
							IF cAVREF = "1"
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Grava Aviso de Referencia para o Elaborador                 ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								QDS->(DbSetOrder(1))
								If !QDS->(DbSeek((cAliasQry)->QAA_FILIAL+(cAliasQry)->QAA_MAT+"P"+"REF"+(cAliasQry)->QDH_DOCTO+(cAliasQry)->QDH_RV))
									QDXGvAviso("REF",(cAliasQry)->QAA_FILIAL,(cAliasQry)->QAA_MAT,(cAliasQry)->QAA_CC,(cAliasQry)->QDH_DOCTO,(cAliasQry)->QDH_RV,,(cAliasQry)->QDH_FILIAL)
								EndIf
							Else
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Gravar Aviso de Referencia para o Elaborador somente quando  for a primeira revisao do documento usado como referencia.³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								IF !Empty(QDUltRvDoc(M->QDH_DOCTO))
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Grava Aviso de Referencia para o Elaborador                 ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
									QDS->(DbSetOrder(1))
									If !QDS->(DbSeek((cAliasQry)->QAA_FILIAL+(cAliasQry)->QAA_MAT+"P"+"REF"+(cAliasQry)->QDH_DOCTO+(cAliasQry)->QDH_RV))
                						QDXGvAviso("REF",(cAliasQry)->QAA_FILIAL,(cAliasQry)->QAA_MAT,(cAliasQry)->QAA_CC,(cAliasQry)->QDH_DOCTO,(cAliasQry)->QDH_RV,,(cAliasQry)->QDH_FILIAL)
									EndIf
								Endif
							Endif
    					  (cAliasQry)->(DBSKIP())						
						Enddo
						DBCLOSEAREA()       
						RestArea(aArea)									
					EndIf
					IF cMvQDRefIn=="2" .or. cMvQDRefIn =="3"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se existem referencias Invertidas FILHOSxPAI³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
						cQuery := " SELECT QDH.QDH_FILIAL,QDH.QDH_DOCTO,QDH.QDH_RV,QDH.QDH_TITULO,QDH.QDH_CODTP,QDH.QDH_DTVIG, "
						cQuery += " QAA.QAA_EMAIL,QAA.QAA_RECMAI,QAA.QAA_APELID,QAA.QAA_FILIAL,QAA.QAA_MAT,QAA.QAA_CC "
						cQuery += " FROM " 
						cQuery +=  RetSqlName("QDB") +" QDB, " 
						cQuery +=  RetSqlName("QDH") +" QDH, "
						cQuery +=  RetSqlName("QD0") +" QD0, "         					
						cQuery +=  RetSqlName("QAA") +" QAA "

						cQuery += " WHERE QDB.QDB_FILIAL = '" + M->QDH_FILIAL +"'"
						cQuery += " AND QDB.QDB_DOCREF = '"+ M->QDH_DOCTO +"'"
						cQuery += " AND QDB.QDB_REVIS = 'S' "
						cQuery += " AND QDB.D_E_L_E_T_ <> '*' "

						cQuery += " AND QDH.QDH_FILIAL = QDB.QDB_FILIAL "
						cQuery += " AND QDH.QDH_DOCTO = QDB.QDB_DOCTO "
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³SubSelect para garantir a ultima revisao do QDH   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
						cQuery += " AND QDH.QDH_RV = ( SELECT  MAX(QDH2.QDH_RV) FROM "+RetSqlName("QDH") +" QDH2"  
						cQuery += " WHERE QDH2.QDH_FILIAL = QDB.QDB_FILIAL AND QDH2.QDH_DOCTO =  QDB.QDB_DOCTO "
						cQuery += " AND QDH2.QDH_CANCEL <> 'S' AND QDH2.QDH_OBSOL <> 'S' AND QDH2.QDH_STATUS = 'L  ' "
						cQuery += "	AND QDH2.D_E_L_E_T_ <> '*') "
						
						cQuery += " AND QD0.QD0_FILIAL = QDH.QDH_FILIAL "
						cQuery += " AND QD0.QD0_DOCTO = QDH.QDH_DOCTO "
						cQuery += " AND QD0.QD0_RV = QDH.QDH_RV "
						cQuery += " AND QD0.QD0_AUT = 'E' "
						cQuery += " AND QD0.QD0_FLAG <> 'I' "
						cQuery += " AND QD0.D_E_L_E_T_ <> '*' "

						cQuery +=" AND QAA.QAA_FILIAL= QD0.QD0_FILMAT "
						cQuery +=" AND QAA.QAA_MAT = QD0.QD0_MAT "
						cQuery +=" AND QAA.QAA_CC	= QD0.QD0_DEPTO "
						cQuery +=" AND "+ QA_FilSitF(.T.,.T.) 
						cQuery +=" AND QAA.D_E_L_E_T_ <> '*'  "
						
						cQuery := ChangeQuery(cQuery)
						cAliasQry  := GetNextAlias()
						
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

						TcSetField(cAliasQry,"QDH_DTVIG","D")					
						
						(cAliasQry)->(DBGotop())  
						While (cAliasQry)->(!EOF())
							If !Empty((cAliasQry)->QAA_EMAIL) .And. (cAliasQry)->QAA_RECMAI == "1"
								aDiv:={M->QDH_DOCTO,M->QDH_RV}
								FQDOTPMAIL(aUsrMail,(cAliasQry)->QDH_DOCTO,(cAliasQry)->QDH_RV,(cAliasQry)->QDH_TITULO,(cAliasQry)->QAA_EMAIL,"REF",cMatFil,(cAliasQry)->QAA_APELID,(cAliasQry)->QAA_MAT,,,aDiv,(cAliasQry)->QDH_CODTP,(cAliasQry)->QDH_DTVIG)
							EndIf
							IF cAVREF = "1"
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Grava Aviso de Referencia para o Elaborador                 ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								QDS->(DbSetOrder(1))
								If !QDS->(DbSeek((cAliasQry)->QAA_FILIAL+(cAliasQry)->QAA_MAT+"P"+"REF"+(cAliasQry)->QDH_DOCTO+(cAliasQry)->QDH_RV))
								QDXGvAviso("REF",(cAliasQry)->QAA_FILIAL,(cAliasQry)->QAA_MAT,(cAliasQry)->QAA_CC,(cAliasQry)->QDH_DOCTO,(cAliasQry)->QDH_RV,,(cAliasQry)->QDH_FILIAL,M->QDH_DOCTO,M->QDH_RV)
								EndIf
							Else
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Gravar Aviso de Referencia para o Elaborador somente quando  for a primeira revisao do documento usado como referencia.³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								IF !Empty(QDUltRvDoc(M->QDH_DOCTO))
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Grava Aviso de Referencia para o Elaborador                 ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
									QDS->(DbSetOrder(1))
									If !QDS->(DbSeek((cAliasQry)->QAA_FILIAL+(cAliasQry)->QAA_MAT+"P"+"REF"+(cAliasQry)->QDH_DOCTO+(cAliasQry)->QDH_RV))
  		    							QDXGvAviso("REF",(cAliasQry)->QAA_FILIAL,(cAliasQry)->QAA_MAT,(cAliasQry)->QAA_CC,(cAliasQry)->QDH_DOCTO,(cAliasQry)->QDH_RV,,(cAliasQry)->QDH_FILIAL,M->QDH_DOCTO,M->QDH_RV)
									EndIf
								Endif
							Endif
							(cAliasQry)->(DBSKIP())						
						Enddo
					Endif
					DBCLOSEAREA()       
					RestArea(aArea)
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Baixa todos Avisos de Referencia da Revisao Anterior³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					QDS->(DbSetOrder(1))
					If QDS->(DbSeek(cMatFil+cMatCod+"P"+"REF"+QDH->QDH_DOCTO))
						cRv:= QDS->QDS_RV
						QDS->(DbSetOrder(2))
						If QDS->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+cRv+"REF"+Space(20)+"P"))
							While QDS->(!Eof()) .And. QDS->QDS_FILIAL+QDS->QDS_DOCTO+QDS->QDS_RV+QDS->QDS_TPPEND+QDS->QDS_CHAVE+QDS->QDS_PENDEN == QDH->QDH_FILIAL+QDH->QDH_DOCTO+cRv+"REF"+Space(20)+"P"
								RecLock("QDS",.F.)
									QDS->QDS_PENDEN := "B"
									QDS->QDS_DTBAIX:= dDataBase
									QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
									QDS->QDS_FMATBX := cMatFil
									QDS->QDS_MATBX  := cMatCod
									QDS->QDS_DEPBX  := cMatDep
								QDS->(MsUnlock())
								FKCOMMIT()
								QDS->(DbSkip())
							EndDo
						EndIf
						QDS->(DbSetOrder(nOrdQDS))
					EndIf
				Endif
				If lAltDoc .AND. M->QDH_CANCEL <> "S" .AND. M->QDH_STATUS <> "L  "
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Gera Aviso "Incluir Questionario", para os responsaveis ³
					//³que possuem permicao para alterar o Documento.          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					QAG->(DbSetOrder(2))
					If !QAG->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV))
						If QD0->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV))
							While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
								If QD0->QD0_FLAG <> "I"
									If QD5->(DbSeek(xFilial("QD5")+M->QDH_CODTP+QD0->QD0_AUT))
										If QD5->QD5_ALT == "S"
											If M->QDH_QUEST == "1"  // Inclui Questionario
												//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
												//³Grava Aviso de Inclusao de Questionario. ³
												//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
												QDS->(DbSetOrder(1))
												If !QDS->(DbSeek(QD0->QD0_FILMAT+QD0->QD0_MAT+"P"+"QUE"+M->QDH_DOCTO+M->QDH_RV))
													QDXGvAviso("QUE",QD0->QD0_FILMAT,QD0->QD0_MAT,QD0->QD0_DEPTO,M->QDH_DOCTO,M->QDH_RV,,M->QDH_FILIAL)
												EndIf
											Else
												//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
												//³Grava Aviso a Baixa de Questionario. ³
												//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
												QDS->(DbSetOrder(1))
												If QDS->(DbSeek(QD0->QD0_FILMAT+QD0->QD0_MAT+"P"+"QUE"+M->QDH_DOCTO+M->QDH_RV))
													RecLock("QDS",.F.)
														QDS->QDS_PENDEN := "B"
														QDS->QDS_DTBAIX:= dDataBase
														QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
														QDS->QDS_FMATBX := cMatFil
														QDS->QDS_MATBX  := cMatCod
														QDS->QDS_DEPBX  := cMatDep
													QDS->(MsUnlock())
												EndIf
											EndIf
										EndIf
									Endif
								EndIf
								QD0->(DbSkip())
							EndDo
						EndIf
					Endif
				EndIf
	
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Devolucao Grava e Baixa QD1              |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lQdBxAle
					QD1->(DbSetOrder(2))
					If QD1->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+M->QDH_STATUS))
						While QD1->(!Eof()) .And. QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_TPPEND == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+M->QDH_STATUS
							If QD1->QD1_PENDEN == "P"
								RecLock("QD1",.F.)
									QD1->QD1_PENDEN := "B"
									QD1->QD1_DTBAIX := dDataBase
									QD1->QD1_HRBAIX := SubStr( Time(), 1, 5 )
									QD1->QD1_FMATBX := cMatFil
									QD1->QD1_MATBX  := cMatCod
									QD1->QD1_DEPBX  := cMatDep
									QD1->QD1_DISTNE := "N"
								QD1->(MsUnlock())
								FKCOMMIT()
							EndIf
							QD1->(DbSkip())
						EndDo
					EndIf
					QD1->(DbSetOrder(nOrdQD1))
				Else
					QD1->(DbSetOrder(1))
					If QD1->(DbSeek(M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod))
						While QD1->(!Eof()) .And. M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod == QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_DEPTO + QD1->QD1_FILMAT + QD1->QD1_MAT
							If QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND == M->QDH_STATUS
								RecLock("QD1",.F.)
									QD1->QD1_PENDEN := "B"
									QD1->QD1_DTBAIX := dDataBase
									QD1->QD1_HRBAIX := SubStr( Time(), 1, 5 )
									QD1->QD1_FMATBX := cMatFil
									QD1->QD1_MATBX  := cMatCod
									QD1->QD1_DEPBX  := cMatDep
									QD1->QD1_DISTNE := "N"
								QD1->(MsUnlock())
								FKCOMMIT()
								Exit
							EndIf
							QD1->(DbSkip())
						EndDo
					EndIf
				EndIf
		
				If M->QDH_STATUS $ "E  ,EC "
					cStatus := "DC "
				ElseIf M->QDH_STATUS $ "R  /A  /H  "
					cStatus := "EC "
				EndIf
		
				M->QDH_STATUS := cStatus
				RecLock("QDH",.F.)
					QDH->QDH_STATUS:= M->QDH_STATUS
				QDH->(MsUnlock())
				FKCOMMIT()
				
				cFilQD0 := ""
				QD0->(DbSetOrder(1))
				If QD0->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+Left(M->QDH_STATUS,1)))
					While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV+QD0->QD0_AUT == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+Left(M->QDH_STATUS,1)
						If QD0->QD0_FLAG <> "I"
							IF Empty(cFilQD0)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Localiza o Primeiro Elaborador           ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
								cFilQD0 := QD0->QD0_FILMAT
								cMatQD0 := QD0->QD0_MAT
								cDepQD0 := QD0->QD0_DEPTO
							Endif
		
							If lQdBxAle .Or. QD0->QD0_FILMAT+QD0->QD0_DEPTO+QD0->QD0_MAT == cFilQD0+cDepQD0+cMatQD0
						  		QD050GrDst(.T.,,,,,,,,nOpc )	// Grava Distrib Pendente
							EndIf
						EndIf
						QD0->(DbSkip())
					EndDo
				Else
					QD050GrDst(,,,,,,,,nOpc)
				EndIf
			Endif
		Endif
	End Transaction
CursorArrow()

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD050GrDst³ Autor ³ Programacao Quality   ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava Distribuicao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD050GrDst(ExpL1,ExpC1,ExpC2,ExpC3,ExpL2,ExpC4,ExpN1,ExpC5,³±±
±±³       	 ³ ExpN2)                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Devolucao de Documento (.T. / .F.)                 ³±±
±±³          ³ ExpC1 - Filial do Usuario                                  ³±±
±±³          ³ ExpC2 - Depto do Usuario                                   ³±±
±±³          ³ ExpC3 - Matricula do Usuario                               ³±±
±±³          ³ ExpL2 - Solicitacao de Documento (.T. / .F.)               ³±±
±±³          ³ ExpC4 - Tipo de Recebimento                                ³±±
±±³          ³ ExpN1 - Numero de Copias                                   ³±±
±±³          ³ ExpC5 - Chave do Docto                                     ³±±
±±³          ³ ExpN2 - Opcao do MBrowse                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050GrDst(lDevol,cFilMat,cDepMat,cCodMat,lSolDoc,cTpRcbt,nCopias,cChave,nOpc)

Local nOrdQAA   := QAA->(IndexOrd())
Local nRegQAA   := QAA->(Recno())
Local lIncQD1   := .F.
Local aUsrMat   := QA_USUARIO()
Local cMatFil   := aUsrMat[2]
Local cMatCod   := aUsrMat[3]
Local cMatDep   := aUsrMat[4]
Local nOpBrowse := 0
Local aQaa		:= {}

Default lDevol := .F.
Default lSolDoc:= .F.
Default cTpRcbt:= " "
Default nCopias:= 0
Default cFilMat:= cMatFil
Default cDepMat:= cMatDep
Default cCodMat:= cMatCod
Default cChave := " "

	If !lSolDoc
		If lDevol .And. (!Inclui .Or. nOpc <> 7)
		cFilMat := QD0->QD0_FILMAT
		cDepMat := QD0->QD0_DEPTO
		cCodMat := QD0->QD0_MAT
		EndIf
		If ((Inclui .Or. nOpc == 7) .And. cFilmat == Nil .And. cDepMat == Nil .And. cCodMat == Nil ) .Or. Substr( M->QDH_STATUS, 1, 1 ) == "D"
		cFilMat := M->QDH_FILMAT
		cDepMat := M->QDH_DEPTOE
		cCodMat := M->QDH_MAT
		EndIf
	EndIf

	If !lSolDoc
	QD1->(DbSetOrder(1))
		If QD1->(DbSeek(M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cDepMat + cFilMat + cCodMat + DtoS( M->QDH_DTCAD ) + M->QDH_STATUS))
			If QD1->QD1_PENDEN == "B"
			lIncQD1 := .T.
			EndIf
		Else
		lIncQD1:= .T.
		EndIf
	EndIf

	If lIncQD1 .And. fVerRecLei(M->QDH_FILIAL, M->QDH_DOCTO, M->QDH_RV, cFilMat, cDepMat, cCodMat, M->QDH_STATUS)
		If M->QDH_CANCEL == "S"
		nOpBrowse:= 6
		Else
		nOpBrowse:= 3
		EndIf
				
   	QAA->(DbSetOrder(1))
	QAA->(DbSeek(cFilMat + cCodMat))
	aQaa := { QAA->QAA_FILIAL, QAA->QAA_CODFUN,;
		If(Empty(cTpRcbt),QAA->QAA_TPRCBT,cTpRcbt), QAA->QAA_APELID,;
			  QAA->QAA_EMAIL,  QAA->QAA_RECMAI }
	RecLock( "QD1",.T.)
	QD1->QD1_FILIAL := M->QDH_FILIAL
	QD1->QD1_DOCTO  := M->QDH_DOCTO
	QD1->QD1_RV     := M->QDH_RV
	QD1->QD1_TPPEND := M->QDH_STATUS
	QD1->QD1_FILMAT := cFilMat
	QD1->QD1_MAT    := cCodMat
	QD1->QD1_DEPTO  := cDepMat
	QD1->QD1_FMATBX := cMatFil
	QD1->QD1_MATBX  := cMatCod
	QD1->QD1_DEPBX  := cMatDep
	QD1->QD1_DISTNE := "N"
				If M->QDH_DTOIE == "E"  .And. M->QDH_STATUS == "L  "
		QD1->QD1_PENDEN := "B"
		QD1->QD1_DTBAIX := dDataBase
		QD1->QD1_HRBAIX := SubStr( Time(), 1, 5 )
			ElseIf nOpBrowse == 6 .and. M->QDH_STATUS == "L  "
		QD1->QD1_PENDEN := "B"
		QD1->QD1_DTBAIX := dDataBase
		QD1->QD1_HRBAIX := SubStr( Time(), 1, 5 )
			Else
		QD1->QD1_PENDEN := "P"
		QD1->QD1_DTBAIX := CTOD("  /  /  ","DDMMYY")
			EndIf
	QD1->QD1_DTGERA := dDataBase
	QD1->QD1_HRGERA := SubStr( Time(), 1, 5 )
	QD1->QD1_LEUDOC := "N"
	QD1->QD1_CHAVE  := cChave
	QD1->QD1_CARGO := aQaa[2]
	QD1->QD1_TPDIST:= aQaa[3]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica na gravacao e se Documento Pendente e se o Tipo da Pendencia e          ³
	//³diferente de Digitacao pois nao Existe a necessidade de enviar um eMail para o   ³
	//³Digitador sendo que o mesmo ja esta logado.                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND <> "D") .And. ;
		(! Empty(aQaa[5]) .And. aQaa[6] == "1")
		fQdoTpMail(@aUsrMail,QD1->QD1_DOCTO,QD1->QD1_RV,M->QDH_TITULO,aQaa[5],M->QDH_STATUS,aQaa[1],aQaa[4],,,,,M->QDH_CODTP,M->QDH_DTVIG)
				EndIf
	QD1->(MsUnLock())    
	FKCOMMIT()
	QAA->(DbSetOrder(nOrdQAA))
	QAA->(DbGoTo(nRegQAA))
		EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD050DvDoc³ Autor ³ Programacao Quality   ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Devolucao de Documentos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD050DvDoc(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao do mBrowse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050DvDoc(nOpc)

Local cNumOrd    := "00"
//Local cStatus    := M->QDH_STATUS
Local aUsrMat    := QA_USUARIO()
Local cMatFil    := aUsrMat[2]
Local cMatCod    := aUsrMat[3]
Local cMatDep    := aUsrMat[4]
Local cMatQD1    := ""
Local cDepQD1    := "" 
Local cFilQD1    := ""
Local lElaborador:= .f.
Local lDigitador := ( QDH->QDH_FILMAT + QDH->QDH_MAT == cMatFil + cMatCod )
Local cProxSta	 := ""
Local cMatElab01 := ""
Local nOrdQd1    := QD1->(IndexOrd())
Local lPendente  := .F.
Local cQLeuDoc   := GetMV("MV_QLEUDOC",.F.,"S")
Local cMvQDBxAle := GetMv("MV_QDBXALE",.F.,"N")
Local lRet       := .F.
Local i			 := 0
Local nQD4Pend   := GdFieldPos("QD4_PENDEN",aHedDoc[5])
Local nQD4Chave  := GdFieldPos("QD4_CHAVE" ,aHedDoc[5])
Local nQD4Seq    := GdFieldPos("QD4_SEQ"   ,aHedDoc[5])
Local nPosQD0    := 0                   
Local lBloqMsg   := If(GetMv("MV_QBLQMSG",.T.,"1") == "1",.T.,.F.) //Bloqueia a finalizacao de doc. externo, quando nao informado. 1=Sim /2=Nao                          
Local lRetorno   :=.T.

Private nQD0Aut  := GdFieldPos("QD0_AUT"   ,aHedDoc[1])
Private nQD0Film := GdFieldPos("QD0_FILMAT",aHedDoc[1])
Private nQD0Mat  := GdFieldPos("QD0_MAT"   ,aHedDoc[1])
Private nQD0Dept := GdFieldPos("QD0_DEPTO" ,aHedDoc[1])
Private nQD0Flag := GdFieldPos("QD0_FLAG"  ,aHedDoc[1])
Private nQD0Ord  := GdFieldPos("QD0_ORDEM" ,aHedDoc[1])

	If Empty(M->QDH_DOCTO) .Or. Empty(M->QDH_RV) .Or. M->QDH_STATUS $ "D  ,I  "
	Return .F.
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o responsavel pela proxima etapa existe e nao esta demitido.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Substr(M->QDH_STATUS,1,1) == "E"
	cProxSta := "DC "
	ElseIf Substr(M->QDH_STATUS,1,1) $ "R,A,H"
	cProxSta := "EC "
	EndIf

QD1->(DbSetOrder(2))
	If QD1->(DbSeek(M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV))
		While QD1->(!Eof()) .And. QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV == M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV
			If QD1->QD1_SIT <> "I"
				If AllTrim(QD1->QD1_TPPEND) == SubStr(cProxSta,1,1) .and. QD1->QD1_PENDEN == "B"
				cFilQD1:= QD1->QD1_FILMAT
				cMatQD1:= QD1->QD1_MAT
				cDepQD1:= QD1->QD1_DEPTO
				Exit
				EndIf
			EndIf
		QD1->(DbSkip())
		Enddo
	EndIf
QD1->(DbSetOrder(nOrdQD1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se usuario do QD1 existe no cadastro de responsaveis  ³
//³se nao busca o primeiro elaborador.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SubStr(cProxSta,1,1) <> "D"
	nPosQD0:=Ascan(aQD0Doc,{|x| x[nQD0Film]+x[nQD0Mat]+x[nQD0Dept]+x[nQD0Aut]==cFilQD1+cMatQD1+cDepQD1+SubStr(cProxSta,1,1)} )
		For i:=1 To Len(aQD0Doc)
			If aQD0Doc[i,Len(aQD0Doc[i])]==.F.
				If aQD0Doc[i,nQD0Aut] == SubStr(cProxSta,1,1)
					If !(QD050ResND(aQD0Doc[i,nQD0film],aQD0Doc[i,nQD0Mat],cProxSta))
					lRet:= .F.
					Return .F.
					EndIf
				Exit                                                   
				Endif
			Endif
		Next
		IF nPosQD0==0 .And. (Ascan(aQD0Doc,{|x| Alltrim(x[nQD0Aut])=="E" }))<>0
		nPosQD0:= Ascan(aQD0Doc,{|x| Alltrim(x[nQD0Aut])=="E" })
		cFilQD1:= aQD0Doc[nPosQD0,nQD0Film]
		cMatQD1:= aQD0Doc[nPosQD0,nQD0Mat]
		cDepQD1:= aQD0Doc[nPosQD0,nQD0Dept]
		Endif
	EndIf

	If cMVQdBxAle == "S" .And. SubStr(cProxSta,1,1) <> "D"
		IF QD050ResND(cFilQD1,cMatQD1)
		lRet:= .T.
		Endif
   
		If !lRet
		Help(" ",1,"QDELABINAT") // "O Elaborador do Documento encontra-se Inativo, nao sera possivel a devolucao do Documento."
		Return .F.
		EndIf
	Else
		If !QD050ResND(cFilQD1,cMatQD1,cProxSta)
		Return .F.
		EndIf
	EndIf

	If M->QDH_STATUS == "EC "
	nPosQD0:=Ascan(aQD0Doc,{|x| x[nQD0Film]+x[nQD0Mat]+x[nQD0Dept]+Alltrim(x[nQD0Aut])==cMatFil + cMatCod + cMatDep+"E" .and. x[nQD0Flag]<>"I" } )
		IF nPosQD0!=0
    	lElaborador := .t.
		Endif
	EndIf

	If lElaborador .And. lDigitador
	Return .F.
	EndIf

QD1->(DbSetOrder(1))
	If QD1->(DbSeek(M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod))
		While QD1->(!Eof()) .And. M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod == QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_DEPTO + QD1->QD1_FILMAT + QD1->QD1_MAT
			If QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND == M->QDH_STATUS .And. QD1->QD1_SIT <> "I"
				If !(QD1->QD1_LEUDOC == "S" .Or. cQLeuDoc == "N" .Or. (M->QDH_DTOIE == "E" .And. (At("DOCEXT",M->QDH_NOMDOC) > 0 .Or. M->QDH_STATUS == "D  ")))
					If (M->QDH_DTOIE == "E" .And. lBloqMsg) .OR. M->QDH_DTOIE == "I"
					Help(" ",1,"QD050LER") // "Nao e permitido baixar o documento sem antes ler.""
					Return .F.
					Endif
				EndIf
			EndIf
		QD1->(DbSkip())
		EndDo
	EndIf

cEspecie  := Left("CRI"+Space(8),8)
QD4->(DbSetOrder(1))

	For i:=1 To LEN(aQD4Doc)
		If !aQD4Doc[i,Len(aQD4Doc[i])] .And. aQD4Doc[i,nQD4Pend]=="P"
			If M->QDH_STATUS == "EC " .OR. M->QDH_STATUS == "DC "
				IF aQD4Ini[i,Len(aQD4Doc[i])+1]==M->QDH_STATUS
				Exit
				Endif
			Endif
			IF ASCAN(aTxtResul,{|X| x[1]==cEspecie .AND. X[2]==aQD4Doc[i][nQD4Chave]})!=0
				If cMVQdBxAle == "S"
					IF aQD4Ini[i,Len(aQD4Doc[i])+1] == cProxSta .AND. cMatFil+cMatcod==aQD4Ini[i,Len(aQD4Doc[i])+2]+aQD4Ini[i,Len(aQD4Doc[i])+3]
					lPendente := .T.
					Exit
					ENDIF
				Else
					IF aQD4Ini[i,Len(aQD4Doc[i])+1] == cProxSta
					lPendente := .T.
					Exit
					Endif
				Endif
			Endif
		Endif
	Next


	If !lPendente
	Help(" ",1,"QD050NDV") // "Nao e permita a devolucao do documento se nao existir critica cadastrada."
	Return .F.
	EndIf

	If !MsgYesNo(OemtoAnsi(STR0049),OemToAnsi(STR0023)) // "Confirma a Devolu‡„o do Docto?" ### "Aten‡„o"
	Return .F.
	EndIf

	If ExistBlock( "QD50DvDoc" )
	lRetorno:=ExecBlock( "QD50DvDoc", .f., .f.,{M->QDH_DOCTO,M->QDH_RV})
	Endif

	If lRetorno
	QD050GrDoc(bCampo,nOpc,,,.T.)  
	Endif

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD050LiDoc³ Autor ³Programacao Quality    ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se usuario pode ter acesso ao documento           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD050LiDoc( ExpN1 )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050LiDoc(nOpc)

Local lLiberado:= .F.
Local cStatus  := M->QDH_STATUS
Local aUsrMat  := QA_USUARIO()
Local cMatDep  := aUsrMat[4]
Local cMatFil  := aUsrMat[2]
Local cMatCod  := aUsrMat[3]
Local cMVLIBLEI:= GetMV("MV_QLIBLEI")

	If Inclui .Or. nOpc == 7 .Or. nOpc == 6 .Or. QD050ChkUsr(cStatus,cMatFil,cMatCod,cMatDep,nOpc)
	lLiberado := .t.
	Else
		If !(cMVLIBLEI == "S" .And. cStatus == "L  " )
		QD1->(DbSetOrder(1))
			If QD1->(DbSeek(M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod))
				While QD1->(!Eof()) .And. M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod == QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_DEPTO + QD1->QD1_FILMAT + QD1->QD1_MAT
					If QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND == cStatus
					lLiberado := .T.
					Exit
					EndIf
					If QD1->QD1_TPPEND == "I  " .Or. (cMVLIBLEI == "S" .And. cStatus == "L  ")
					lAltDoc   := .F.
					lLiberado := .T.
					Exit
					EndIf
				QD1->(DbSkip())
				EndDo
			EndIf
		
		Else
		lAltDoc  := .F.
			If QDH->QDH_SIGILO == "2"
			lLiberado := .t.
			EndIf
		EndIf

		If !lLiberado
			If QDG->(DbSeek( M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV ))
				While QDG->(!Eof()) .And. M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV == QDG->QDG_FILIAL + QDG->QDG_DOCTO + QDG->QDG_RV
					If QDG->QDG_SIT == "I" .And. M->QDH_OBSOL <> "S"
					QDG->(DbSkip())
					Loop
					EndIf
					If QDG->QDG_FILMAT + QDG->QDG_DEPTO + QDG->QDG_MAT == cMatFil + cMatDep + cMatCod .And. QDG->QDG_RECEB  == "S" .And. cStatus == "L  "
					lLiberado := .T.
					EndIf
				QDG->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

	If M->QDH_OBSOL == "S" // para garantir que documento eh obsoleto
		If !Chkpsw(96)
		lLiberado := .F.
		EndIf
	EndIf

Return lLiberado



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD050LiD  ³ Autor ³Adalberto Mendes Neto  ³ Data ³ 07/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se usuario pode ter acesso ao documento           ³±±
±±³          ³ Esta funcao serve apenas para o botao VISUALIZA DOCTO      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD050LiD( ExpN1 )                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050LiD(nOpc)

Local lLiberado:= .F.
Local cStatus  := M->QDH_STATUS
Local aUsrMat  := QA_USUARIO()
Local cMatDep  := aUsrMat[4]
Local cMatFil  := aUsrMat[2]
Local cMatCod  := aUsrMat[3]
Local cMVLIBLEI:= GetMV("MV_QLIBLEI")

	If Inclui .Or. nOpc == 7 .Or. nOpc == 6 .Or. QD050ChkUsr(cStatus,cMatFil,cMatCod,cMatDep,nOpc)
	lLiberado := .t.
	Else
		If !(cMVLIBLEI == "S" .And. cStatus == "L  " )
		QD1->(DbSetOrder(1))
			If QD1->(DbSeek(M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod))
				While QD1->(!Eof()) .And. M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod == QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_DEPTO + QD1->QD1_FILMAT + QD1->QD1_MAT
					If QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND == cStatus
					lLiberado := .T.
					Exit
					EndIf
					If QD1->QD1_TPPEND == "I  " .Or. (cMVLIBLEI == "S" .And. cStatus == "L  ")
					lAltDoc   := .F.
					lLiberado := .T.
					Exit
					EndIf
				QD1->(DbSkip())
				EndDo
			EndIf
		
		Else
		lAltDoc  := .F.
			If QDH->QDH_SIGILO == "2"
			lLiberado := .t.
			EndIf
		EndIf

		If !lLiberado
			If QDG->(DbSeek( M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV ))
				While QDG->(!Eof()) .And. M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV == QDG->QDG_FILIAL + QDG->QDG_DOCTO + QDG->QDG_RV
					If QDG->QDG_SIT == "I" .And. M->QDH_OBSOL <> "S"
					QDG->(DbSkip())
					Loop
					EndIf
					If QDG->QDG_FILMAT + QDG->QDG_DEPTO + QDG->QDG_MAT == cMatFil + cMatDep + cMatCod .And. QDG->QDG_RECEB  == "S" .And. cStatus == "L  "
					lLiberado := .T.
					EndIf
				QDG->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

	If M->QDH_OBSOL == "S" // para garantir que documento eh obsoleto
		If !Chkpsw(96)
		lLiberado := .F.
		EndIf
	EndIf

	If !lLiberado
		If QD0->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV))
			While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
				If QD0->QD0_FILMAT+QD0->QD0_MAT == cMatFil+cMatCod
				lLiberado:= .T.    
				Exit
				EndIf
		   QD0->(DbSkip())
			EndDo
		EndIf
	Endif

Return lLiberado


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD050AltDc³ Autor ³ Programacao Quality   ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se pode Alterar Documento                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD050AltDc( ExpN1 )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050AltDc(nOpc)

Local lRet    := .t.
Local aUsrMat := QA_USUARIO()
Local cMatFil := aUsrMat[2]
Local cMatCod := aUsrMat[3]
Local cCodDep := aUsrMat[4]
Private cPreview := GetMv("MV_QDPRVW",.T.,"1")

	If nOpc <> 2
		If !(M->QDH_STATUS $ "D  ,DC ,E  ,EC " .And. M->QDH_FILMAT + M->QDH_MAT == cMatFil + cMatCod )
		lRet := .F.
		DbSelectArea("QD0")
		DbSetOrder(2) 
			If QD0->(DbSeek(xFilial("QD0")+M->QDH_DOCTO+M->QDH_RV+SubStr(M->QDH_STATUS, 1, 1 )+cMatFil+cCodDep+cMatCod))
				If cPreview == "2" .And. cPaisLoc == "BRA"
					if !Empty(QD0->QD0_EDITDO)
						   lRet:= IF(QD0->QD0_EDITDO == "S",.T.,.F.)
					Else
						If QD5->(DbSeek(xFilial("QD5")+M->QDH_CODTP+SubStr(M->QDH_STATUS, 1, 1 )))
							lRet := If(QD5->QD5_ALT <> "S",.F.,.T.)
						EndIf
					Endif
				Else
					If QD5->(DbSeek(xFilial("QD5")+M->QDH_CODTP+SubStr(M->QDH_STATUS, 1, 1 )))
						lRet := If(QD5->QD5_ALT <> "S",.F.,.T.)
					Endif
				Endif
			Else
				lRet := iif(fBuscQD5(M->QDH_DOCTO, M->QDH_RV, cMatCod) <> "S", .F. , .T.) //Chamada da função fBuscQD5 que retorna QD5_ALT
			EndIf
		EndIf
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD050LsAlt³ Autor ³ Programacao Quality   ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD050LsAlt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050LsAlt()

Local lLiberado:= .f.
Local aUsrMat  := QA_USUARIO()
Local cMatFil  := aUsrMat[2]
Local cMatCod  := aUsrMat[3]
Local cMatDep  := aUsrMat[4]

	If M->QDH_STATUS == "L  "
	QD1->(DbSetOrder(1))
		If QD1->(DbSeek(M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod ))
			While QD1->(!Eof()) .And. M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod == QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_DEPTO + QD1->QD1_FILMAT + QD1->QD1_MAT
				If QD1->QD1_SIT <> "I"
					If QD1->QD1_TPPEND == M->QDH_STATUS .Or. QD1->QD1_TPPEND $ "E  ,EC "
					lLiberado := .T.
					Exit
					EndIf
				Endif
			QD1->(DbSkip())
			EndDo
		EndIf
	EndIf

Return lLiberado

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD050ApAll³ Autor ³ Programacao Quality   ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Apaga Dados referente ao Documento                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD050ApAll( ExpC1 )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050ApAll(cExce)

Local aArquivos	:= { }
Local aEspecie 	:= { "OBJ", "TXT", "COM", "REV", "SUM", "ITA", "RED" }
Local nCt      	:= 0
Local cEspecie 	:= ""
Local cCod     	:= ""
Local cAliasQA4	:= If(FWModeAccess("QA4")=="C", xFilial("QA4"), M->QDH_FILIAL) //Empty(xFilial("QA4"))
Local nC

aArquivos	:= {"QD6", "QDB", "QD0", "QD4", "QDG", "QDJ", "QD1", "QDN", "QDZ" ,"QDR" , "QDS", "QDV" }

Default cExce := "XXX"

	For nCt:= 1 To Len(aArquivos)
	cCod:= aArquivos[nCt] + "->" + aArquivos[nCt] + "_FILIAL+" + aArquivos[nCt] + "->" + aArquivos[nCt] + "_DOCTO+" + aArquivos[nCt] + "->" + aArquivos[nCt] + "_RV"
		If Select(aArquivos[nCt]) == 0
		Loop
		Endif
	DbSelectArea(aArquivos[nCt])
		IF aArquivos[nCt] == "QDS"
		DbSetOrder(2)  
		Else
		DbSetOrder(1)  		
		Endif
		If DbSeek(M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV)
			While !Eof() .And. M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV == &cCod
				If aArquivos[nCt] == "QD4"
				cEspecie := "CRT   "
				QA_DelTxt( QD4->QD4_CHAVE, cEspecie )
				cEspecie := "JUS   "					// Justificativa das Criticas
				QA_DelTxt( QD4->QD4_CHAVE, cEspecie )
				cEspecie := "CRI   "
				QA_DelTxt( QD4->QD4_CHAVE, cEspecie )
				EndIf
				If aArquivos[nCt] == "QDB"
				cEspecie := "REF   "
				EndIf
				If aArquivos[nCt] == "QD4" .or. aArquivos[nCt] == "QDB"
					If QA4->(DbSeek(cAliasQA4+M->QDH_DOCTO+M->QDH_RV+cEspecie))
					Reclock("QA4",.F.)
					QA4->(DbDelete())
					QA4->(MsUnlock())
					FKCOMMIT()
					EndIf
				EndIf
			DbSelectArea(aArquivos[nCt])
			RecLock(aArquivos[nCt],.F.)
			DbDelete()
			MsUnlock()        
			FKCOMMIT()
			DbSkip()
			EndDo
		EndIf
	Next nCt

	For nC:= 1  To Len( aEspecie )
		If !aEspecie[nC] $ cExce
		cEspecie := Left(aEspecie[nC]+Space(8),8)
		QA_DelTxt( M->QDH_CHAVE, cEspecie )
		EndIf
	Next nC

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD050MsDet³ Autor ³ Programacao Quality   ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Tela de Detalhes                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD050MsDet()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050MsDet()

Local aData     := {}
Local aQPath    := QDOPATH()
Local cFilQD1   := ""
Local cFilQDH   := QDH->(DbFilter())
Local cQPathTrm := aQPath[3]
Local nOrdQD1   := QD1->(IndexOrd())
Local nPosQDH   := QDH->(Recno())
Local nT        := 0
Local oDta      := Nil
Local oFnt      := Nil
Local oNo       := LoadBitmap( GetResources(), "DISABLE" )
Local oOK       := LoadBitmap( GetResources(), "ENABLE" )
Local oUso      := Nil

Private bCampo   := {|nCPO| Field( nCPO ) }
Private cMvpar   := " "
Private nCombOrd := QDH->(IndexOrd())
Private nCombQD2 := 1
Private nCombQD3 := 1
Private nItem    := 2
Private nItemRv  := 1
Private nOpca    := 0
Private oDlg     := Nil
Private oGet     := Nil
Private oWord    := Nil

QDH->(RegToMemory("QDH",,,.F.))

Inclui := .F.

DbSelectArea("QD1")
QD1->(DbSetorder(4))
cFilQD1:= 'QD1_SIT <> "I"'
Set Filter to &cFilQD1

DEFINE MSDIALOG oDlg FROM 00,00 TO 35,127 TITLE OemToAnsi(STR0050) OF oMainWnd  //"Detalhe de Documentos"

@ 033,002 SAY OemToAnsi(STR0018) COLOR CLR_HRED SIZE 070,007 OF oDlg PIXEL  //"Documentos"
@ 146,002 SAY OemToAnsi(STR0056) COLOR CLR_HRED SIZE 070,007 OF oDlg PIXEL  //"Hist¢rico"

oUso := TCBrowse():New(155,002,500,105,,,,oDlg,,,,,,,,,,,,.F.,"QD1",.T.,,.F.)
oUso:AddColumn(TCColumn():New(" "                 , {|| If( QD1->QD1_PENDEN == "P", oNo , oOk )},,,,"LEFT",14, .T., .F.,,,, .F., ) )
oUso:AddColumn(TCColumn():New(OemToAnsi( STR0057 ), {|| Left( Qa_nSit( QD1->QD1_TPPEND ),20 ) },,,,"LEFT",, .F., .F.,,,, .F., ) )
oUso:AddColumn(TCColumn():New(OemToAnsi( STR0058 ), {|| QD1->QD1_FILMAT },,,,"LEFT",, .F., .F.,,,, .F., ) )
oUso:AddColumn(TCColumn():New(OemToAnsi( STR0059 ), {|| Left( Qa_nDept( QD1->QD1_DEPTO, .t., QD1->QD1_FILMAT ), 30 ) },,,,"LEFT",, .F., .F.,,,, .F., ) )
oUso:AddColumn(TCColumn():New(OemToAnsi( STR0060 ), {|| Qa_nUsr( QD1->QD1_FILMAT, QD1->QD1_MAT, .t. ) },,,,"LEFT",, .F., .F.,,,, .F., ) )
oUso:AddColumn(TCColumn():New(OemToAnsi( STR0061 ), {|| QDXFNDsDtr( QD1->QD1_TPDIST ) },,,,"LEFT",, .F., .F.,,,, .F., ) )
oUso:AddColumn(TCColumn():New(OemToAnsi( STR0062 ), {|| DtoC( QD1->QD1_DTGERA )+" "+QD1->QD1_HRGERA },,,,"LEFT",, .F., .F.,,,, .F., ) )
oUso:AddColumn(TCColumn():New(OemToAnsi( STR0063 ), {|| DtoC( QD1->QD1_DTBAIX )+" "+QD1->QD1_HRBAIX },,,,"LEFT",, .F., .F.,,,, .F., ) )
oUso:AddColumn(TCColumn():New(OemToAnsi( STR0080 ), {|| Qa_nUsr( QD1->QD1_FMATBX, QD1->QD1_MATBX, .t. ) },,,,"LEFT",, .F., .F.,,,, .F., ) )
oUso:AddColumn(TCColumn():New(OemToAnsi( TitSx3("QD1_NTRESP")[1]), {|| QD1->QD1_NTRESP },,,,"LEFT",, .F., .F.,,,, .F., ) )

oUso:SetFilter("QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV",QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV,QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV)
oUso:UpStable()
oUso:Refresh()

@ 042,002 LISTBOX oDta;
					FIELDS  QDH->QDH_DOCTO,;
						QDH->QDH_RV,;
						Left( Qa_nSit( QDH->QDH_STATUS ), 20 ),;
						DtoC( QDH->QDH_DTVIG ),;
						DtoC( QDH->QDH_DTLIM ),;
						QDXFNANASS( QDH->QDH_CODASS, .f. ),;
						QDH->QDH_TITULO ;
					HEADER  OemToAnsi( STR0034 ),; //"Documento"
						OemToAnsi( STR0064 ),; //"Rv"
						OemToAnsi( STR0065 ),; //"Status"
						OemToAnsi( STR0066 ),; //"Dt Vigˆncia"
						OemToAnsi( STR0067 ),; //"Dt Limite"
						OemToansi( STR0068 ),; //"Assunto"
						OemToAnsi( STR0045 );  //"T¡tulo"
					ON CHANGE ( (oUso:SetFilter("QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV",;
									QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV ,;
									QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV)),;
									oUso:GoTop(), oUso:UpStable(), oUso:Refresh());
					SIZE 500,100 OF oDlg PIXEL;
					ALIAS "QDH"

oDta:UpStable()
oDta:Refresh()
oDta:SetFocus(.T.)

aButtons:= {{"PESQUISA"  ,{ || DbSelectArea("QDH"),AxPesqui(),oDta:UpStable(),oDta:Refresh(),oDta:SetFocus(.t.),oUso:SetFilter("QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV",QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV,QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV ),oUso:UpStable(),oUso:Refresh()},OemToAnsi(STR0022)},;  // "Pesquisar"
			{"SDUPROP",{ || QD050ParDlg(@oDta),oDta:UpStable(),oDta:Refresh(),oDta:SetFocus(.t.),oUso:SetFilter("QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV",QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV,QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV),oUso:GoTop(),oUso:UpStable(),oUso:Refresh()},OemToAnsi(STR0112),OemToAnsi(STR0144)},;  // "SDUPROP" ### "Param."
			{"PMSDOC"    ,{ || QD50HistRev(QDH->QDH_FILIAL,QDH->QDH_DOCTO)},OemToAnsi(STR0123),OemToAnsi(STR0145)},; // "Historico de Revisoes" ### "Hist.Rev"
			{"RELATORIO" ,{ || QD50DlgVis()},OemToAnsi(STR0004)}} // "Visualizar"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,aButtons) CENTERED

DbSelectArea("QD1")
QD1->(DbSetOrder(nOrdQD1))
Set Filter To

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada criado para mudar o Filtro ou realizar alguma tarefa especifica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "QDOAP17" )
		ExecBlock( "QDOAP17", .f., .f., { 1 })
	Else
		DbSelectArea( "QDH" )
		DbSetorder( 1 )
		Set Filter to &(Qd050Filtro())
	EndIf

	If Type("oWord") <> "U"
		If !Empty(oWord) .And. oWord <> "-1"
		OLE_CloseFile( oWord )
		OLE_CloseLink( oWord )
		EndIf
	EndIf

	aData  := DIRECTORY(cQPathTrm+"*.CEL")
	For nT:= 1 to Len(aData)
		If File(cQPathTrm+AllTrim(aData[nT,1]))
			FErase(cQPathTrm+AllTrim(aData[nT,1]))
		Endif
	Next

	aData  := DIRECTORY(cQPathTrm+"*.DOT")
	For nT:= 1 to Len(aData)
		If File(cQPathTrm+AllTrim(aData[nT,1]))
			FErase(cQPathTrm+AllTrim(aData[nT,1]))
		Endif
	Next

	aData  := DIRECTORY(cQPathTrm+"*.HTM")
	For nT:= 1 to Len(aData)
		If File(cQPathTrm+AllTrim(aData[nT,1]))
			QDRemDirHtm(AllTrim(aData[nT,1]))
		Endif
	Next

	DbSelectArea("QDH")
	Set Filter To &(cFilQDH)
	QDH->(DbGoto(nPosQDH))

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD050FtDoc³ Autor ³ Programacao Quality   ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Filtra Documentos selecionados na opcao "Detalhes"         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD050FtDoc( ExpA1,ExpA2,ExpN1,ExpN2,ExpA3,ExpN3 )          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo os Tipos de Documentos              ³±±
±±³          ³ ExpA2 - Array contendo os Assuntos                         ³±±
±±³          ³ ExpN1 - Ordem do Combo Tipo de Documentos                  ³±±
±±³          ³ ExpN2 - Ordem do Combo Assuntos                            ³±±
±±³          ³ ExpA3 - Array contendo as Etapas                           ³±±
±±³          ³ ExpN3 - Ordem da Revisao (1 - Ultima 2 - Todas)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050FtDoc(aCombQD2,aCombQD3,nAtQD2,nAtQD3,aNiv,nAtOrd)


Local cFiltro := ""

Local nFor    := 1
Local cAuxFilt:= " "


nCombQD2:= nAtQD2
nCombQD3:= nAtQD3
nCombOrd:= nAtOrd

QDH->(DbSetorder(nAtOrd))

	If !Empty( aCombQD2[nAtQD2][2] )
	cFiltro:='QDH_CODTP =="'+aCombQD2[nAtQD2][2]+'"'
	EndIf

	If !Empty( aCombQD3[nAtQD3][2] )
	cFiltro += If( !Empty( cFiltro ),' .AND. '," ")+'QDH_CODASS =="'+aCombQD3[nAtQD3][2]+'"'
	EndIf

	If nItemRv == 1
	cFiltro += If( !Empty( cFiltro ),' .AND. '," ")+'QDH_OBSOL  <> "S" .And. QDH_CANCEL <> "S"'
	EndIf

cMvPar:= " "
	For nFor:= 1 To Len(aNiv)
		If Empty(cAuxFilt)
		cAuxFilt += If(aNiv[nFor,1],If( !Empty( cFiltro ),' .AND. '," ")+"("+'QDH_STATUS =="'+aNiv[nFor,3]+'"'," ")
		cMvpar   += If(aNiv[nFor,1],aNiv[nFor,3]," ")
		Else
		cAuxFilt += If(aNiv[nFor,1],If( !Empty( cAuxFilt ),' .OR. '," ")+'QDH_STATUS =="'+aNiv[nFor,3]+'"'," ")
		cMvpar   += If(aNiv[nFor,1],aNiv[nFor,3]," ")
		EndIf
	Next nFor

cAuxFilt+= If(!Empty(cAuxFilt),")"," ")
cFiltro += cAuxFilt

DbSelectArea("QDH")
Set Filter to &cFiltro
QDH->(DbGotop())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ Qa_PriEla³ Autor ³ Programacao Quality   ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se exite elaboradores cadastrados                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Qa_PriEla( ExpC1 )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Qa_PriEla(cTipo)

Local cRet:= If(cTipo == "F", Space(2),Space(10))

	If Empty(M->QDH_DOCTO) .Or. Empty(M->QDH_RV)
	Return .F.
	EndIf

	If !QD0->(DbSeek(M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + "E"))
	Help(" ",1,"QD050NEE") // "Nao existem elaboradores cadastrados"
	Return cRet
	Else
		If cTipo == "F"
		cRet:= QD0->QD0_FILMAT
		Else
		cRet:= QD0->QD0_MAT
		EndIf
	EndIf

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD050ApQA4³ Autor ³ Programacao Quality   ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna a sequencia nao utilizada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD050ApQA4(ExpA1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array com as variaveis de memoria do cad. principal³±±
±±³          ³ ExpN1 - Ordem original do Documento                        ³±±
±±³          ³ ExpN2 - Posicao Original do Cadastro de Documento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050ApQA4(aQDH,nOrdQDH,nPosQDH)

Local nTam  := 0
Local nValor:= 0
Local cValor:= ""
Local nI
	If QA4->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+"REF"))
	cValor:= Space(04)
	nValor:= Val(Alltrim(QA4->QA4_CHAVE))
	nTam  := Len(Alltrim(QA4->QA4_CHAVE))
		If nValor > 0
		nValor --
		EndIf
	cValor := "0000"
		If QDB->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+SubStr(cValor,1,(Len(cValor)-nTam))+Alltrim(Str(nValor))))
		nValor ++
		EndIf
	cValor:= Space(5)
	Reclock("QA4")
	QA4->QA4_CHAVE:= SubStr(cValor,1,(Len(cValor)-nTam)) + Alltrim(Str(nValor))
	MsUnlock()
	FKCOMMIT()
	EndIf

DbSelectArea("QDH")
QDH->(DbSetOrder(nOrdQDH))
QDH->(DbGoto(nPosQDH))
	For nI := 1 To Len(aQDH)
	M->&(Eval(bCampo,nI)):= aQDH[nI]
	Next nI

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD050EPxRe³ Autora³ Iuri Seto             ³ Data ³ 08/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se o proximo resp. existe e nao esta Inativo.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QD050EPxRe(ExpA1,ExpC1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - ordem das etapas do documento            			  ³±±
±±³          ³ExpC1 - autorizacao atual         						  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³QDOA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050EPxRe(aOrdem,cProxSta)

Local nItem   := AScan( aOrdem, {|x| AllTrim(x[1]) == cProxSta } )
Local lRet	  := .F.
Local cAntSta := ""
Local lInativo:= .F.
Local ic

cProxSta:= AllTrim(If(nItem <> 0, aOrdem[nItem][2], " "))

	While nItem <> 0

		For ic:=1 To Len(aQD0Doc)
			If aQD0Doc[ic,Len(aQD0Doc[ic])]==.F.
				If aQD0Doc[ic,nQD0Aut] == SubStr(cProxSta,1,1)
					If QD050ResND(aQD0Doc[ic,nQD0film],aQD0Doc[ic,nQD0Mat])
					lRet := .T.
					Else
					lInativo := .T.
					EndIf
				Exit                                                   
				Endif
			Endif
		Next
	cAntSta := cProxSta
	nItem   := AScan( aOrdem, {|x| AllTrim(x[1]) == cProxSta } )
	cProxSta:= AllTrim(If(nItem <> 0, aOrdem[nItem][2]," "))	
		If cProxSta == cAntSta .OR. nItem == 0
		nItem := 0
		lRet := .T.
		EndIf
	EndDo

	If !lRet
	MsgStop(OemToAnsi(STR0085)+;														// "Nao sera possivel finalizar, pois o proximo "
				OemToAnsi( If( SubStr(cProxSta,1,1) == "E",STR0087,;								// "Elaborador"
		If( SubStr(cProxSta,1,1) == "R",STR0088,;								// "Revisor"
			If( SubStr(cProxSta,1,1) == "A",STR0083,;								// "Aprovador"
				If( SubStr(cProxSta,1,1) == "H",STR0084, ""))))) +;				// "Homologador"
					If(lInativo," (" + AllTrim(QAA->QAA_MAT) + "-" + AllTrim(QAA->QAA_NOME) + ")" +OemToAnsi(STR0086),;	//"  esta Inativo."
				OemToAnsi(STR0089))+; 											// "nao foi encontrado."
				OemToAnsi(STR0090),OemToAnsi(STR0023))									// "Favor entrar em contato com o responsavel pelo cadastro de usuarios." ### "Atencao"
					EndIf
				
Return lRet
				
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD050ResND³ Autora³ Iuri Seto             ³ Data ³ 08/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se o responsavel esta Inativo                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QD050ResND(ExpC1,ExpC2,ExpC3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Filial do responsavel                               ³±±
±±³          ³ExpC2 - Matricula do responsavel                            ³±±
±±³          ³ExpC3 - Proxima Etapa                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³QDOA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050ResND(cFilBsc,cMat,cProxSta)

Local lRet   := .F.
Local nOrdQAA:= QAA->(IndexOrd())
Local aReAuse := {}

Default cProxSta:= " "

QAA->(DbSetOrder(1))
If QAA->(DbSeek(cFilBsc+cMat))
	If QA_SitFolh()
		lRet:= .T.
	Else
		If !Empty(cProxSta) .AND.;
			QDH->QDH_STATUS <> "L" // Caso o Estado atual seja Leitura nao exibo a mensagem
			MsgStop(OemToAnsi(STR0085)+;												// "Nao sera possivel finalizar, pois o proximo "
			OemToAnsi(If( SubStr(cProxSta,1,1) == "E",STR0087,;	// "Elaborador"
			If( SubStr(cProxSta,1,1) == "R",STR0088,;			// "Revisor"
				If( SubStr(cProxSta,1,1) == "A",STR0083,;			// "Aprovador"
					If( SubStr(cProxSta,1,1) == "H",STR0084, ""))))) +;	// "Homologador"
						" (" + AllTrim(QAA->QAA_MAT) + "-" + AllTrim(QAA->QAA_NOME) + ")" +OemToAnsi(STR0086)+;	//" esta demitido."
						OemToAnsi(STR0090),OemToAnsi(STR0023))													// "Favor entrar em contato com o responsavel pelo cadastro de usuarios." ### "Atencao"
					EndIf
				EndIf
				IF lRet .and. cProxSta != " "	.AND.;
					QDH->QDH_STATUS <> "L" // Caso o Estado atual seja Leitura nao exibo a mensagem
					aReAuse:= QA_SitAuse(cFilBsc,cMat,SubStr(cProxSta,1,1))
					IF aReAuse[1]
						Help(" ",1,"QX040JEAP",,OemToAnsi(If( SubStr(cProxSta,1,1) == "E",STR0087,;  // "Elaborador"
						If( SubStr(cProxSta,1,1) == "R",STR0088,; // "Revisor"
							If( SubStr(cProxSta,1,1) == "A",STR0083,; // "Aprovador"
								If( SubStr(cProxSta,1,1) == "H",STR0084,""))))) +;	// "Homologador"
									" (" + Alltrim(cFilBsc+"-"+cMat) + " : " + AllTrim(QAA->QAA_NOME) + ")"+chr(13)+chr(10)+;
									OemToansi(STR0150)+chr(13)+chr(10)+; //"Para o Usuario da Ausencia Temporaria:"
									"(" + Alltrim(aReAuse[2]+"-"+aReAuse[3]) + " : " + AllTrim(QA_NUSR(aReAuse[2],aReAuse[3]))+") ",05,00) // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."									 
								Endif
							Endif
						EndIf
								
QAA->(DbSetOrder(nOrdQAA))
			
Return lRet
			
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD050CKDT ³Autor  ³ Carlos A. Rodrigues   ³ Data ³ 30/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se o responsavel esta Inativo/transferido/Branco   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QDA050CKDT(ExpA1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Array contendo a Ordem da proxima Etapa             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³QDOA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDA050CKDT(aOrdem)

Local lRet		:= .T.
Local lDistCC	:= .F.
Local nItem		:= 0
Local nC		:= 0
Local nOrdQAA  	:= QAA->(IndexOrd())
Local cFilQad	:= If(FWModeAccess("QAD") == "C", xFilial("QAD"), M->QDH_FILDEP)
Local nPos1  	:= GdFieldPos("QDZ_DEPTO" ,aHedDoc[4])
Local nPos2  	:= GdFieldPos("QDZ_MAT"   ,aHedDoc[4])
Local nPos3  	:= GdFieldPos("QDZ_FILMAT",aHedDoc[4])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ARRAY de AHEADERS ³
//³aHedDoc[1] = QD0  ³
//³aHedDoc[2] = QD6  ³
//³aHedDoc[3] = QDB  ³
//³aHedDoc[4] = QDZ  ³
//³aHedDoc[5] = QD4  ³
//³aHedDoc[6] = QDV  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If M->QDH_STATUS <> "L  "
		For nC := AScan( aOrdem, {|x| x[1] == M->QDH_STATUS } ) To Len( aOrdem )
			If ( nItem := Ascan( aOrdem, {|x| x[1] == aOrdem[nC, 2] } ) ) > 0
				If aOrdem[nItem, 3] > 0
				Exit
				EndIf
			Else
			Exit
			EndIf
		nC := nItem - 1
		Next nC
	
		If nItem == 0 .Or. aOrdem[nItem,1] == "I  "
		lRet := .F.
		QAA->(DbSetOrder(2))
			IF !EMPTY(aQDZDOC[1,1])
				For nC:=1 TO Len(aQDZDOC)
					IF !aQDZDOC[nC,len(aQDZDOC[nC])]
						If Empty(aQDZDOC[nC,nPos2]) .And. QAA->(DbSeek(aQDZDOC[nC,nPos3]+aQDZDOC[nC,nPos1]))
							While QAA->(!Eof()) .And. QAA->QAA_FILIAL+QAA->QAA_CC == aQDZDOC[nC,nPos3]+aQDZDOC[nC,nPos1]
								If QA_SitFolh() .And. QAA->QAA_DISTSN == "1"
								lDistCC := .T.
								lRet := .T.
								Exit
								EndIf
							QAA->(DbSkip())
							EndDo
						ElseIf 	! Empty(aQDZDOC[nC,nPos2]) .And.;
						QAA->(DbSeek(aQDZDOC[nC,nPos3]+aQDZDOC[nC,nPos1]+aQDZDOC[nC,nPos2])) .And. QA_SitFolh()
							lDistCC := .T.
							lRet := .T.
							Exit
						
							Endif
					Endif
				Next
			Else
				IF QAA->(DbSeek(M->QDH_FILDEP+M->QDH_DEPTOD))
					While QAA->(!Eof()) .And. QAA->QAA_FILIAL+QAA->QAA_CC == M->QDH_FILDEP+M->QDH_DEPTOD
						If QA_SitFolh() .And. QAA->QAA_DISTSN == "1"
						lDistCC := .T.
						lRet := .T.
						Exit
						EndIf
					QAA->(DbSkip())
					EndDo
				Endif
			EndIf
		
			If !lDistCC
				If QAD->(DbSeek(cFilQad + M->QDH_DEPTOD))
					If !Empty(QAD->QAD_MAT)   // Verifica se o Centro de Custo possui responsavel
					QAA->(DbSetOrder(1))
						IF QAA->(DbSeek(QAD->QAD_FILMAT+QAD->QAD_MAT)) .And. QA_SitFolh()
						lRet := .T.
						Endif
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

QAA->(DbSetOrder(nOrdQAA))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD0A050Leg ³ Autor ³ Aldo Marini Junior   ³ Data ³ 30/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD050Legen                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050Legen

Local aLegenda := { 	{'BR_AZUL'   , STR0131 },; //"Documento em fase de Distribuicao"
						{'ENABLE'    , OemtoAnsi(STR0092) },;	// "Documento Normal/Em Leitura"
						{'DISABLE'   , OemtoAnsi(STR0093)},;	// "Documento Obsoleto"
						{'BR_AMARELO', OemtoAnsi(STR0094)},;  // "Documento em fase de Elaboracao"
						{'BR_PRETO'  , OemtoAnsi(STR0095)},;   // "Documento cancelado"
						{'BR_BRANCO'  ,OemtoAnsi(STR0170)} }  // "Documento em cancelamento"

BrwLegenda(cCadastro,STR0096,aLegenda) 	// "Legenda"

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD050ParDlg³ Autor ³ Eduardo de Souza  ³ Data ³ 06/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Monta tela de parametros                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD050ParDlg( ExpO1 )                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpO1 - Objeto ListBox Documentos                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOAO5O.PRW                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050ParDlg(oDta)

Local oDlgPar
Local oItem
Local oBtn1
Local oBtn2
Local oCombQD2
Local oCombQD3
Local oListSt
Local oCombOrd
Local	oOk 	 := LoaDbitmap( GetResources(), "LBOK" )
Local	oNo 	 := LoaDbitmap( GetResources(), "LBNO" )
Local aCombQD2	 := {}
Local aCombOrQD2 := {}
Local aCombQD3	 := {}
Local aCombOrQD3 := {}
Local aNiv		 := {}
Local aCombOrd   := {}
Local cCombQD2	 := " "
Local cCombQD3	 := " "
Local cCombOrd	 := " "
Local cListSt	 := " "
Local nCnt		 := 1
Local aRetSX5
Local nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega array aCombOrd com a Ordem que eh utilizado no ComboBox³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SIX")
	If DbSeek("QDH")
		While INDICE == "QDH"
		cTexto := Capital(SixDescricao())
		AADD(aCombOrd," "+cTexto)
		DbSkip()
		Enddo
	Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega array Tipo de Documento que eh utilizado no ComboBox³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QD2->(DbSeek(xFilial("QD2")))
	nCnt:= 2
	Aadd(aCombQD2, {OemtoAnsi(STR0113), " "})
	Aadd(aCombOrQD2, aCombQD2[1][1])
		While QD2->(!Eof()) .And. QD2->QD2_FILIAL == xFilial("QD2")
		Aadd(aCombQD2, {QD2->QD2_CODTP+" - "+QD2->QD2_DESCTP, QD2->QD2_CODTP})
		Aadd(aCombOrQD2, aCombQD2[nCnt][1])
		nCnt++
		QD2->(DbSkip())
		Enddo
	Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega array Assunto do Documento que eh utilizado no ComboBox³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QD3->(DbSeek(xFilial("QD3")))
nCnt:= 2
Aadd(aCombQD3, {OemtoAnsi(STR0113), " "})
Aadd(aCombOrQD3, aCombQD3[1][1])
	While QD3->(!Eof()) .And. QD3->QD3_FILIAL == xFilial("QD3")
	Aadd(aCombQD3, {QD3->QD3_CODASS+" - "+QD3->QD3_DESCAS, QD3->QD3_CODASS})
	Aadd(aCombOrQD3, aCombQD3[nCnt][1])
	nCnt++
	QD3->(DbSkip())
	EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega Status³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aNiv, {If ( "O  " $ cMvpar, .T., .F. ), OemToAnsi( STR0113 ), "O  "} ) //"Todos"
aRetSX5 := FWGetSX5("Q7")
	If !Empty(aRetSX5)
		For nX := 1 To Len(aRetSX5)
			If !Empty(aRetSX5[nX,3])
				If Substr(aRetSX5[nX,3],1,3) $ cMvpar
				Aadd(aNiv,{.T.,Alltrim(aRetSX5[nX,4]),Substr(aRetSX5[nX,3],1, 3)})
				Else
				Aadd(aNiv,{.F.,Alltrim(aRetSX5[nX,4]),Substr(aRetSX5[nX,3],1, 3)})
				EndIf
			EndIf
		Next nX
	Else
	Help(" ",1,"QDOR050SIT") // "Parametros Default nao existem."
	AADD(aNiv,{If("D  "$cMvpar,.T.,.F.),OemToAnsi(STR0114),"D  "}) //"Digita‡„o"
	AADD(aNiv,{If("E  "$cMvpar,.T.,.F.),OemToAnsi(STR0115),"E  "}) //"Elabora‡„o"
	AADD(aNiv,{If("R  "$cMvpar,.T.,.F.),OemToAnsi(STR0116),"R  "}) //"Revis„o"
	AADD(aNiv,{If("A  "$cMvpar,.T.,.F.),OemToAnsi(STR0117),"A  "}) //"Aprova‡„o"
	AADD(aNiv,{If("H  "$cMvpar,.T.,.F.),OemToAnsi(STR0118),"H  "}) //"Homologa‡„o"
	AADD(aNiv,{If("I  "$cMvpar,.T.,.F.),OemToAnsi(STR0119),"I  "}) //"Distribui‡„o"
	AADD(aNiv,{If("L  "$cMvpar,.T.,.F.),OemToAnsi(STR0120),"L  "}) //"Leitura"
	EndIf

	If Empty(cMvPar)
		For nCnt:=1 to Len(aNiv)
		aNiv[nCnt,1] := .T.
		Next nCnt
	EndIf

DEFINE MSDIALOG oDlgPar FROM 00,00 TO 27,52 TITLE OemToAnsi(STR0112) //"Parametros"

@ 003,003 TO 203,204 LABEL OemToAnsi(STR0071) OF oDlgPar PIXEL

@ 010,009 SAY OemToAnsi(STR0051) SIZE 035,006 OF oDlgPar PIXEL //"Tipo Docto"
@ 032,009 SAY OemToAnsi(STR0052) SIZE 135,006 OF oDlgPar PIXEL //"C¢d. Assunto"

@ 018,009 COMBOBOX oCombQD2 VAR cCombQD2 ITEMS aCombOrQD2 SIZE 190,008 PIXEL OF oDlgPar // Tipo de Documento

@ 040,009 COMBOBOX oCombQD3 VAR cCombQD3 ITEMS aCombOrQD3 SIZE 190,008 PIXEL OF oDlgPar // Codigo Assunto

@ 055,009 TO 077,198 LABEL OemToAnsi(STR0121) OF oDlgPar PIXEL // Ordem
@ 063,014 COMBOBOX oCombOrd VAR cCombOrd ITEMS aCombOrd SIZE 178,008 PIXEL OF oDlgPar

@ 083,009 TO 197,127 LABEL OemToAnsi(STR0065)+" "+OemToAnsi(STR0034) OF oDlgPar PIXEL
@ 090,013 LISTBOX oListSt VAR cListSt Fields HEADER " ", " " SIZE 110, 103 PIXEL OF oDlgPar;
ON DbLCLICK QDO050Cl(@oListSt,@aNiv)

oListSt:SetArray(aNiv)
oListSt:bLine := { || {If(aNiv[oListSt:nAt,1],oOk,oNo),aNiv[oListSt:nAt,2]}}

@ 083,133 TO 110,198 LABEL OemToAnsi(STR0053) OF oDlgPar PIXEL //"Ultima Revis„o"
@ 091,137 RADIO oItem VAR nItemRv ITEMS OemToAnsi( STR0054 ), OemToAnsi( STR0055 );  //"Sim" ### "N„o"
3D SIZE 025,007 OF oDlgPar PIXEL

oCombQD2:nAt:= nCombQD2
oCombQD3:nAt:= nCombQD3
oCombOrd:nAt:= QDH->(IndexOrd())

DEFINE SBUTTON oBtn1 FROM 164, 170 TYPE 1 ENABLE OF oDlgPar;
			ACTION ( MsgRun(OemToAnsi(STR0009),OemtoAnsi(STR0079),{||QD050FtDoc(aCombQD2,aCombQD3,oCombQD2:nAt,oCombQD3:nAt, aNiv, oCombOrd:nAt)}),;
						oDta:UpStable(), oDta:Refresh(), oDta:SetFocus(.t.), oDlgPar:End() )  //"Selecionando Documentos" ### "Aguarde..."

DEFINE SBUTTON oBtn2 FROM 179, 170 TYPE 2 ENABLE OF oDlgPar;
			ACTION  oDlgPar:End()

ACTIVATE MSDIALOG oDlgPar CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QDO050Cl  ³ Autor ³ Eduardo de Souza   ³ Data ³ 03/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Tratar o click da pergunte                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDO050Cl(ExpO1,ExpA1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto Lista Status                             ³±±
±±³          ³ ExpA1 - Array contendo Status                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDO050Cl(oListSt,aNiv)

Local nI:= 0

aNiv[oListSt:nAt,1] := !aNiv[oListSt:nAt,1]
	If oListSt:nAt == 1	// Todos
		For nI:=2 to Len(aNiv)
		aNiv[nI,1] := aNiv[1,1]
		Next nI
	Else
		If !aNiv[oListSt:nAt,1]
		aNiv[1,1]:= .F.
		EndIf
	EndIf

oListSt:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD050GerRv ³ Autor ³ Eduardo de Souza  ³ Data ³ 24/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Gera Nova Revisao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD050GerRv()                                              ±±
±±³Parametros³ ExpC1 - Alias do Arquivo                                  ³±±
±±³          ³ ExpN1 - Registro Atual                                    ³±±
±±³          ³ ExpN2 - Opcao de selecao do aRotina                       ³±±
                lSolit -Verifica se esta sendo executado pela rotina 
                QDOA052                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA050.PRW                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050GerRv(cAlias,nReg,nOpca,cUnd,lSolit)
Local cOldAlias := Alias()
Local lRet      := .F.
Local nI        := 0
Local nOrdem    := IndexOrd()
Local nRegistro := Recno()

Default lSolit := .F.

Private bCampo  := { |nCPO| Field( nCPO ) }

	lGerRev:= .T.

	If Procname(1)=="QD052GRVBX"
		If M->QDP_TPSOL == "SAD"
			lSolit:=.T.
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se ja existe usuario alterando o Documento.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !SoftLock("QDH")
		DbSelectArea(cOldAlias)
		DbSetOrder(nOrdem)
		DbGoto(nRegistro)
		Return lRet
	Endif

	DbSelectArea("QDH")
	QDH->(DbSetOrder(1))
	For nI := 1 To FCount()
		M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
	Next nI

	M->QDH_REVINV:=INVERTE(M->QDH_RV)

	If ExistBlock("QDOAP38")
		ExecBlock("QDOAP38",.f.,.f.,{M->QDH_DOCTO,M->QDH_RV}) 
	Endif

	If QD050Telas("QDH",QDH->(Recno()),7,lSolit) == 1
		lRet:= .T.
	EndIf

	IF !lRet
		DbSelectArea("QDH")	
		MSUnLock()
	Endif

	lGerRev := .F.	

DbSelectArea(cOldAlias)
(cOldAlias)->(DbSetOrder(nOrdem))
(cOldAlias)->(DbGoto(nRegistro))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD050ChkDoc³ Autor ³ Eduardo de Souza  ³ Data ³ 27/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se Documento existe                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QD050ChkDoc(ExpC1,ExpC2)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Filial                                ³±±
±±³          ³ ExpC2 = Codigo do Documento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050ChkDoc(cFil, cDocto, cRevisao, lDuplDoc, lNoFree)

Local aAreaQDH	:= QDH->(GetArea())
Local lRet		:= .T.
Local lTemLetra	:= .F.                     
Local cRev		:= ""
Local cRevIn	:= SuperGetMv("MV_QDREVIN",.F.,"00") 
Local cTipoDoc  := M->QDH_CODTP
Local nI       


Default lNoFree := .F.    
Default lFinalDoc := .F.

DbSelectArea("QDH")
Set Filter To
DbSetOrder(4)
                      
	If cRevisao <> Nil
	cRev := AllTrim(cRevisao)
		If Empty(cRev)
		cRev := cRevIn
		EndIf
    nX := 1
		While nX <= Len(cRev)
			If !IsDigit(Substr(cRev,nX,1))
			lTemLetra := .T.
			Exit
			EndIf
		nX ++			
		EndDo
		If !lTemLetra
		cRevisao := STRZERO(Val(cRev),TamSX3("QDH_RV")[1],0)
		Else
		cRevisao := cRev
		EndIf
	Else
		If !lDuplDoc
		M->QDH_RV    := "   "	
		EndIf
	EndIf

	If cMayUse == Nil .Or. cMayUse != xFilial("QDH")+cDocto .OR. cRevisao <> Nil
	FreeUsedCode()
	cMayUse := xFilial("QDH")+cDocto
		If cRevisao <> Nil
		cMayUse := xFilial("QDH")+cDocto+cRevisao
		EndIf
	EndIf

	If QDH->(DbSeek(cFil+cDocto+cRevisao)) .AND. QDH->QDH_DOCTO==cDocto .AND. QDH->QDH_CANCEL == "S"
	Help(" ",1,"QD050CANCEL")
	lRet := .F.
	EndIf


	If lRet .And. QDH->(DbSeek(cFil+cTipoDoc+cDocto)) .AND. QDH->QDH_DOCTO==cDocto .And. !lduDupDe .And. !lFinalDoc
	Help(" ",1,"QD050DOCEX") // "Documento ja existe, para Gerar Revisao escolha a opcao no Menu"
	lRet:=.F.
	EndIf

	If lRet
		for nI:= 1 to len(M->QDH_DOCTO)
			If ASC(Substr(M->QDH_DOCTO,nI,1)) == 39 // ASC(" ' ") Aspas simples
	   	    Help(" ",1,"QD050CARES") // "Foi digitado um caracter de controle, use outro caracter, evite aspas simples"
			lRet:=.F.  
			exit
			EndIf
		Next nI
	EndIf

	If lRet .And. !Empty(cDocto) .And. Iif(lNoFree,.F.,!FreeForUse("QDH",cMayUse)	)
	lRet:=.F.
	EndIf

QDH->(RestArea(aAreaQDH))

	If lRet
	nCtrl1 := aScan( oDlgFolder:aControls, { |x| ( Upper( AllTrim( x:cReadVar ) ) == "M->QDH_RV" ) } )
	nCtrl2 := aScan( oDlgFolder:aControls, { |x| ( Upper( AllTrim( x:cReadVar ) ) == "M->QDH_DOCTO" ) } )
		If cRevisao == Nil // Caso venha do valid do Docto forço a passagem pela revisão.
			If lRet .AND. nCtrl2 > 0 .AND. nCtrl1 > 0
		    bBlock  := &("{|| oDlgFolder:aControls[ "+alltrim(str(nCtrl1))+" ]:lModified = .T., oDlgFolder:aControls[ "+alltrim(str(nCtrl1))+" ]:SetFocus()}")
			oDlgFolder:aControls[ nCtrl2 ]:bLostFocus := bBlock
			EndIf
		Else
	    M->QDH_RV := cRevisao
		oDlgFolder:aControls[ nCtrl1 ]:Refresh() 
		EndIf
	EndIf

	If lRet
	lRet := QDXVLREV(cRevisao)
	EndIf

lFinalDoc := .F.

Return (lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD050CHKRES³ Autor ³ Eduardo de Souza     ³ Data ³ 31/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ VerIfica o Func. p/ ver esta habilitado a ser responsavel  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD050CHKRES()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050CHKRES()

Local ic       := 0
Local nIt	   := 0
Local lReturn  := .T.
Local aNiveis  := {}
Local aArea	   := GetArea()
Local aAreaQAA := QAA->(GetArea())

Local aStruCad := FWFormStruct(3,"QD0")[3]

Private cFil    := "QD0_FILIAL"
Private cCod    := "QD0_DOCTO"
Private cRv     := "QD0_RV"
Private aHeader := GetEstrTab(aStruCad, "QD0", )

// Inclui coluna de registro atraves de funcao generica
ADHeadRec("QD0", aHeader)

If !Empty(aQD0Doc)
	IF  Empty(aQD0Doc[1,1])
		IF ExistBlock("QDOAP35")
			ExecBlock("QDOAP35", .f., .f.)                
		Else
			QDO050CQDD() //Carrega Array com os Usuarios do QDD
		Endif
	Endif
EndIf

QDO050CQDD()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validar se os usuarios estao ativos	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For ic:=1 TO Len(aQD0Doc)
		IF aQD0Doc[ic,Len(aQD0doc[ic])]==.F.
			If QD050ResND(aqd0Doc[ic,nQD0Film],aqd0Doc[ic,nQD0Mat],aqd0Doc[ic,nQD0Aut])
				If QDD->(DbSeek(xFilial("QDD")+M->QDH_CODTP+aqd0Doc[ic,nQD0Aut]))
					lAchouQDD := .F.
					While QDD->(!Eof()) .And. M->QDH_FILIAL+M->QDH_CODTP+aqd0Doc[ic,nQD0Aut] == QDD->QDD_FILIAL+QDD->QDD_CODTP+QDD->QDD_AUT
						If QDD->QDD_FILA == aqd0Doc[ic,nQD0Film] .And. ;
							QDD->QDD_DEPTOA == aqd0Doc[ic,nQD0Dept] .And. ;
							QDD->QDD_CARGOA == QAA->QAA_CODFUN
							lAchouQDD := .T.
							Exit
						Endif
						QDD->(dbSkip())
					Enddo
					If lAchouQDD
						Loop
					Else
						lReturn:= .f.
					Endif
				EndIf
			Else
				lReturn:= .f.
			EndIf
			If !lReturn
				Help(" ",1,"QDFUNCNP") // Funcionario nao tem permissao p/ responsavel
				Exit
			EndIf
		EndIf
	Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a matriz de responsabilidade esta de acordo com o tipo de documento	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lReturn .And. M->QDH_STATUS <> "L  "
		For iC:= 1 to Len(aQD0Doc)
			If aQD0Doc[iC,Len(aHedDoc[1])+1] == .F.
			nIt:= Ascan(aNiveis,{|x| x[1] == aQD0Doc[iC, nQD0Aut]})
				If nIt > 0
				aNiveis[nIt,2]++
				Else
				aAdd(aNiveis,{aQD0Doc[iC,nQD0Aut],1})
				EndIf
			EndIf
		Next

		lReturn := QDXFNCkRes(aNiveis,.t.)
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validar se existe usuario cadastrado para a filial informada	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lReturn .And. M->QDH_STATUS <> "L  "
    DbSelectArea("QAA")
    QAA->(DbSetOrder(1))
		For iC:= 1 to Len(aQD0Doc)
			If (aQD0Doc[iC,Len(aHedDoc[1])+1] == .F. .And. QAA->(!DbSeek(aQD0Doc[iC,03]+aQD0Doc[iC,04])))
			MsgAlert(STR0157+aQD0Doc[iC,05]+STR0158+aQD0Doc[iC,03],STR0023)//"O usuario "##" nao esta cadastrado para a filial "##"Atencao")	
			lReturn := .F. 
			Endif
		Next
	Endif

	If lReturn
		If !QDHTipDoc() // Verifique o Tipo de documento se existe distribuidor para o documento
		lReturn := .F.
		EndIf
	EndIf

RestArea(aArea)
QAA->(RestArea(aAreaQAA))

Return lReturn

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD050ChkUsr³ Autor ³ Eduardo de Souza  ³ Data ³ 31/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se usuario faz parte dos responsaveis do Docto ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD050ChkUsr(cExpC1,cExpC2,cExpC3,cExpN1)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExpC1 = Status do Documento                            ³±±
±±³          ³ cExpC2 = Filial do usuario Logado                       ³±±
±±³          ³ cExpC3 = Matricula do usuario Logado                    ³±±
±±³          ³ cExpN1 = Opcao do Browse                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050ChkUsr(cStatus,cMatFil,cMatCod,cMatDep,nOpc)

Local lReturn:= .F.

	If	cStatus $ "D  ,DC " .And. cMatFil + cMatCod == M->QDH_FILMAT + M->QDH_MAT
	lReturn:= .T.
	Else
		If nOpc == 2
			If QD0->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV))
				While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
					If QD0->QD0_FILMAT+QD0->QD0_MAT == cMatFil+cMatCod
					lReturn:= .T.
					Exit
					EndIf
			   QD0->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

Return lReturn

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QD50DlgVis ³ Autor ³ Eduardo de Souza   ³ Data ³ 20/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela de Visualizacao de Docto e Cadastro da opcao Detalhes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD50DlgVis()									             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD50DlgVis()

Local oDlgVis
Local oVisDoc
Local oBtn1
Local oBtn2
Local nVisDoc:= 1
Local cFiltro:= QDH->(DbFilter())

DEFINE MSDIALOG oDlgVis TITLE OemToAnsi(STR0004)+" ?" FROM 000, 000 TO 085, 342 PIXEL
	
@ 010,010 RADIO oVisDoc VAR nVisDoc ITEMS OemToAnsi( STR0034 ), OemToAnsi( STR0001 );  //"Documento" ### "Cadastro de Documentos"
				3D SIZE 070,010 OF oDlgVis PIXEL

DEFINE SBUTTON oBtn1 FROM 025, 105 TYPE 1 ENABLE OF oDlgVis;
			ACTION (QD50VisDoc(nVisDoc),oDlgVis:End())
	
DEFINE SBUTTON oBtn2 FROM 025, 137 TYPE 2 ENABLE OF oDlgVis;
			ACTION  oDlgVis:End()
	
ACTIVATE MSDIALOG oDlgVis CENTERED	

DbSelectArea("QDH")
Set Filter To
Set Filter To &(cFiltro)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD50VisDoc ³ Autor ³ Eduardo de Souza   ³ Data ³ 21/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualizacao de Docto e Cadastro na opcao detalhes        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD50VisDoc(ExpN1)          				                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Escolha da Visualizacao (1-Docto/2-Cadastro)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD50VisDoc(nVisDoc)

Local nOrdQD1:= QD1->(IndexOrd())
Local nPosQD1:= QD1->(Recno())

	If !QD050LiDoc(2)
	MsgAlert(OemToAnsi(STR0025),OemToAnsi(STR0026)) // "Documento n„o liberado" ### "Aviso"
	return
	EndiF

	If nVisDoc == 1
		If QDH->QDH_OBSOL == "S"
			If ChkPsw(96)
			QdoDocCon()
			EndIf
		Else
		QdoDocCon()
		EndIf
	Else
		If QDH->QDH_OBSOL == "S"
			If ChkPsw(96)
			QD050Telas("QDH",QDH->(Recno()),8)
			EndIf
		Else
		QD050Telas("QDH",QDH->(Recno()),8)
		EndIf
	EndIf

QD1->(DbSetOrder(nOrdQD1))
QD1->(DbGoTo(nPosQD1))

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD50HistRev³ Autor ³ Eduardo de Souza   ³ Data ³ 29/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Historico de Revisoes                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD50HistRev(ExpC1,ExpC2)    				                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                               ³±±
±±³          ³ ExpC2 - Documento                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD50HistRev(cFilDoc,cDocto)

Local oTree
Local nPosQDH:= QDH->(Recno())
Local nOrdQDH:= QDH->(IndexOrd())
Local cFiltro:= QDH->(DbFilter())

DbSelectArea("QDH")
Set Filter To
	IF QDH->(DbSeek(cFilDoc+cDocto))
	
	DEFINE MSDIALOG oDlgHRv FROM 000,000 TO 287,574 TITLE OemToAnsi(STR0123)+" - "+OemToAnsi(STR0034)+": "+QDH->QDH_DOCTO PIXEL // "Historico de Revisoes"
	oTree := DbTree():New(045,003,140,285, oDlgHrv,,,.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta Objetos Tree                      						    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsgRun(OemToAnsi(STR0125),OemToAnsi(STR0079),{|| QD50TreeRv(@oTree,cFilDoc,cDocto)}) // "Carregando Lancamentos..." ### "Aguarde..."
		
	ACTIVATE MSDIALOG oDlgHRv ON INIT EnchoiceBar(oDlgHrv,{ ||oDlgHrv:End() },{ ||oDlgHrv:End() }) CENTERED	
	Endif

DbSelectArea("QDH")
DbSetOrder(nOrdQDH)
Set Filter To &(cFiltro)
DbGoto(nPosQDH)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD50TreeRv ³ Autor ³ Eduardo de Souza   ³ Data ³ 29/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Tree de Historico de Revisoes                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD50TreeRv(ExpO1,ExpC1)       		                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto Tree                                       ³±±
±±³          ³ ExpC1 - Filial do Documento                               ³±±
±±³          ³ ExpC2 - Documento                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD50TreeRv(oTree,cFilDoc,cDocto)

Local nSeqTree:= 0
Local cTexto  := ""
Local nTexto  := 0
Local nTamLin := TamSX3( "QA2_TEXTO" )[1]
Local nCnt    := 0

DbSelectArea("QA2")

	While QDH->(!Eof()) .And. QDH->QDH_FILIAL+QDH->QDH_DOCTO == cFilDoc+cDocto
		If QA2->(DbSeek(xFilial("QA2")+"REV     "+QDH->QDH_CHAVE))

		cTexto:= QA_RecTxt(QDH->QDH_CHAVE,"REV     ")

		nTexto:= MlCount(cTexto,nTamLin)

		oTree:AddTree(Padr(Upper(OemToAnsi(STR0116))+": "+QDH->QDH_RV,075),.T.,"PMSDOC",,,,StrZero(nSeqTree++,4))  // "Revisao"

			For nCnt:= 1 To nTexto
			oTree:AddTreeItem(Padr(MemoLine(cTexto,nTamLin,nCnt),nTamLin),"FOLDER9",,StrZero(nSeqTree++,4))
			Next nCnt

		oTree:EndTree()

		EndIf
	QDH->(DbSkip())
	EndDo

	If nSeqTree == 0
	oTree:AddTree(Padr(OemToAnsi(STR0124),075),.T.,"FOLDER9",,,,StrZero(nSeqTree++,4))  // "Nao existe Motivo de Revisao"
	Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD50VBtDoc ³ Autor ³ Eduardo de Souza   ³ Data ³ 28/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida Botao Documentos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD50VBtDoc(ExpL1,ExpC1,ExpC2)     		                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Define se Copia .Cel para Terminal                ³±±
±±³          ³ ExpC1 - Filial do Usuario                                 ³±±
±±³          ³ ExpC2 - Matricula do Usuario                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD50VBtDoc(lCpyS2T,cMatFil,cMatCod,lSolAtr,nOpc)

Local lVisHtml := .F.
Local lWordView:= .F.
Local lReturn  := .T.
Local lAbreDoc 

Default lSolAtr:=.F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para Permitir  Abrir o Documento 				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QDOAP31")
	lAbreDoc:= ExecBlock("QDOAP31",.f.,.f.) //Retorna .T./.F.
		IF !lAbreDoc
		Return
		Endif
	Endif

	If !Empty(M->QDH_DOCTO) .And. !Empty(M->QDH_RV) .And. !Empty(M->QDH_CODTP) .And. !Empty(M->QDH_DTOIE)
		If M->QDH_DTOIE == "I"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o Tipo de Visualizacao do Usuario (Html/WordView) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QDTPVisuEd(@lVisHtml,@lWordView,cMatFil,cMatCod)
			If (lWordView .Or.(lVisHtml .And. M->QDH_STATUS == "L  ")) .And. !lAltDoc .And.;
			   (M->QDH_CANCEL <> "S"  .Or. (M->QDH_CANCEL == "S" .And. ;
			   (Substr(M->QDH_STATUS,1,1) <> "D" .And.	 Substr(M->QDH_STATUS,1,1) <> "E")))		
				slViewOLE := Iif(slViewOLE == Nil, FindFunction(Upper("QDOViewOLE")), slViewOLE)
				If !slViewOLE .OR. !QDOViewOLE(M->QDH_NOMDOC, M->QDH_DOCTO, M->QDH_RV)
					ProcessaView(.T.,lVisHtml)
				EndIf
			Else
				ProcessaDoc( { || QdoDocImp( lAltDoc,,.f.,@lCpyS2T,lSolAtr,nOpc ) })
			EndIf
		ElseIf M->QDH_DTOIE == "E"
			If lAltDoc .And. At("DOCEXT",M->QDH_NOMDOC) > 0 .And. M->QDH_CANCEL <> "S"
				If MsgYesNo(STR0132,OemToAnsi(STR0023)) // "Nao existe documento externo relacionado neste documento, deseja relacionar ?" ### "Aten‡„o" //"Nao existe documento externo relacionado neste documento, deseja relacionar ?"
				M->QDH_NOMDOC:= Space(32)
				Else
				lReturn:= .F.
				EndIf
			EndIf
			If lReturn
			ProcessaDoc({ || QdoDocExt(lAltDoc,.F.,@lCpyS2T,@lDocExtOK) })
			EndIf
		EndIf
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD50DocRef ³ Autor ³ Eduardo de Souza   ³ Data ³ 01/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza Documento Referenciado                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD50DocRef()               				                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD50DocRef()

Local cFilDoc 		:= ""
Local cDocto  		:= ""
Local cRv     		:= ""
Local cDToIE  		:= ""
Local nPosDoc   	:= Ascan(aHeader, { |x| x[2] == "QDB_DOCREF" })
Local cQDH_DOCTO	:= M->QDH_DOCTO
Local cQDH_RV		:= M->QDH_RV
Local cQDH_FILIAL	:= M->QDH_FILIAL
Local nQdhRecno		:= QDH->(Recno())
Local nDel			:= len(aHeader)+1
	If !(acols[n,nDel])
		If Acols[n,nPosOri] == "I" // "Documento Interno"
			If !empty(Acols[n,nPosDoc])
				If QDH->(DbSeek(xFilial("QDH")+Acols[n,nPosDoc]))
					While QDH->(!Eof()) .And. QDH->QDH_FILIAL+QDH->QDH_DOCTO == xFilial("QDH")+Acols[n,nPosDoc]
						If QDH->QDH_STATUS == "L  "
						cFilDoc:= QDH->QDH_FILIAL
						cDocto := QDH->QDH_DOCTO
						cRv    := QDH->QDH_RV
						cDtoIE := QDH->QDH_DTOIE
						EndIf
					QDH->(DbSkip())
					EndDo
					If QDH->(DbSeek(cFilDoc+cDocto+cRv))
					QD50VisDoc(1)
					EndIf
				EndIf
			QDH->(DbGoto(nQdhRecno))
			M->QDH_DOCTO	:= cQDH_DOCTO
			M->QDH_RV		:= cQDH_RV
			M->QDH_FILIAL	:= cQDH_FILIAL
			Else
			MessageDlg(STR0161,,3)//"Não foi preenchido o campo documento de referência"
			Endif
		Elseif Acols[n,nPosOri] == "E"
		MsgStop(OemToAnsi(STR0069),OemToAnsi(STR0023)) // "Documento ‚ de Controle Externo. N„o ‚ poss¡vel sua visualiza‡„o" ### "Atencao"
		Else
		MessageDlg(STR0162,,3)//"Não foi preenchido o campo Origem do Documento"
		EndIf
	Else
	MessageDlg(STR0163,,3) //"O item selecionado está deletado"
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Qd050FAlea ³ Autor ³ Eduardo de Souza   ³ Data ³ 08/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Finaliza Documento em ordem Aleatoria                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Qd050FAlea()               				                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Qd050FAlea(nOpc,cMatFil,cMatCod,cMatDep,aOrdem)

Local lRespons  := .F.
Local aPend     := {}
Local aQPath    := QDOPATH()
Local cQPath    := aQPath[1]
Local cQPathTrm := aQPath[3]
Local cBuscaSts	:= ""
Local nPosPend	:= 0
Local nX		:= 0
Local nCnt
Local nC
Local ic
Local nItem     := Ascan(aOrdem,{ |X| X[1] == M->QDH_STATUS})
Local nMinResp  := 99
Local lBxMinR   := .T.            
Local nOrdQD1 := QD1->(IndexOrd())

	If QD5->(DbSeek(xFilial("QD5")+M->QDH_CODTP+If(SubStr(M->QDH_STATUS,1,1) == "D","E",SubStr(M->QDH_STATUS,1,1))))
		nMinResp:= If(QD5->QD5_NMIN == 0,1,QD5->QD5_NMIN)
		lBxMinR := If(QD5->QD5_BXP == "S",.T.,.F.)
	EndIf

	If(SubStr(M->QDH_STATUS,1,1) <> "D")
		QD1->(DbSetOrder(4))
		If QD1->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV))
			While QD1->(!Eof()) .And. QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
				If QD1->QD1_SIT <> "I" .And. QD1->QD1_TPPEND == M->QDH_STATUS
					If (nPosPend := Ascan(aPend, { |x| 	X[1] == QD1->QD1_FILMAT .And.;
													X[2] == QD1->QD1_MAT })) > 0
						aPend[nPosPend][4] := QD1->QD1_PENDEN													
						aPend[nPosPend][5] := DTOS(QD1->QD1_DTGERA)
						aPend[nPosPend][6] := QD1->QD1_HRGERA
					Else
						Aadd(aPend,{QD1->QD1_FILMAT,QD1->QD1_MAT,QD1->QD1_TPPEND,QD1->QD1_PENDEN,DTOS(QD1->QD1_DTGERA),QD1->QD1_HRGERA})
					Endif
				EndIf
			QD1->(DbSkip())
			EndDo
		EndIf
	Else
		For nX := 1 To Len(aQD0DOC)
			If aQD0Doc[nX,1] == "E"
				Aadd(aPend,{aQD0Doc[nX,3],aQD0Doc[nX,4],aQD0Doc[nX,1],"P",DTOS(dDataBase),Time()})
			Endif
		Next nX
	EndIf
	QD1->(DbSetOrder(nOrdQD1))

	aPend:= aSort(aPend,,,{ |x,y| x[5]+x[6] > y[5]+y[6]})

	For nCnt:= 1 To Len(aPend)
		If(SubStr(M->QDH_STATUS,1,1) <> "D")
			If aPend[nCnt,3] == M->QDH_STATUS
				If aPend[nCnt,4] == "B"
					nBaixa++
				EndIf
				nPend++
			Else
				Exit
			EndIf
		Else
			If aPend[nCnt,3] == "E"
				If aPend[nCnt,4] == "B"
					nBaixa++
				EndIf
				nPend++
			Else
				Exit
			EndIf
		EndIf
	Next nCnt

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso nao exista na matriz de responsabilidade, assumi a qtde pendente. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nMinResp == 99
		nMinResp:= nPend
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe responsavel inativo na Baixa Aleatoria. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QDH->QDH_STATUS <> "L  " .And. !QD050VldEAle(lBxMinR,nBaixa,nPend,nMinResp,aOrdem)
		Return .F.
	EndIf

	For ic:=1 TO Len(aQD0Doc)
		IF aQD0Doc[ic,Len(aQD0Doc[ic])]==.F.
			IF aQD0Doc[ic,nQD0Flag]<>"I"
				cBuscaSts := If(aQD0Doc[ic,nQD0Aut] == Left(M->QDH_STATUS, 1), M->QDH_STATUS, aQD0Doc[ic,nQD0Aut] + Space(2))
				If (nItem := AScan( aOrdem, {|x| x[1] == cBuscaSts } ) ) > 0
					aOrdem[nItem,3]++
				EndIf
			Endif
		Endif
	Next

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Qd050FOrd  ³ Autor ³ Eduardo de Souza   ³ Data ³ 08/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Finaliza Documento pela ordem definida na matriz de resp. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Qd050FOrd()                				                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Qd050FOrd(nOpc,cMatFil,cMatCod,cMatDep,aOrdem)

Local cStatus   := M->QDH_STATUS
Local cProxSta  := ""
Local nOrdQD1   := QD1->(IndexOrd())
Local lTemResp  := .F.
Local aQPath    := QDOPATH()
Local cQPath    := aQPath[1]
Local cQPathTrm := aQPath[3]
Local cBuscaSts := ""
Local nC
Local ic 		:= 0
Local nItem     := 0
Local nMinResp  := 99
Local lBxMinR   := .T.
Local cStatusPen:= ""
Local cStatuAPen:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o responsavel pela proxima etapa existe e nao esta demitido.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cProxSta:= AllTrim(M->QDH_STATUS)
	If QD5->(DbSeek(xFilial("QD5")+M->QDH_CODTP+If(SubStr(cProxSta,1,1) == "D","E",SubStr(cProxSta,1,1))))
	nMinResp:= If(QD5->QD5_NMIN == 0,1,QD5->QD5_NMIN)
	lBxMinR := If(QD5->QD5_BXP == "S",.T.,.F.)
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a contagem das pendencias existentes para atender a quantidade minima (nMinResp)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cStatusPen:= If(SubStr(cProxSta,1,1) == "D","E  ",cStatus)
QD1->(DbSetOrder(4))
	If QD1->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV))
		While QD1->(!Eof()) .And. M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV == QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV
			IF QD1->QD1_TPPEND=="EC "
				IF cStatusPen=="EC "
					IF cStatuAPen<>"EC "
					nPend:=0
					Endif
				Else
				nPend:=0
				Endif
			Endif
			If QD1->QD1_TPPEND==cStatusPen .AND. QD1->QD1_SIT <> "I"
			nPend++
			EndIf
		cStatuAPen:=QD1->QD1_TPPEND
		QD1->(DbSkip())
		EndDo
	EndIf
QD1->(DbSetOrder(nOrdQD1))

	If M->QDH_STATUS <> "L  "
		If Empty(cProxSta) .Or. SubStr(cProxSta,1,1) == "D"
		lTemResp:= QD050EPxRe(aOrdem,@cProxSta)
		Else
			For ic:=1 To Len(aQD0DOC)
				IF aQD0Doc[ic,Len(aQD0doc[ic])]==.F.
					If aQD0Doc[ic,nQD0Aut]==SubStr(cProxSta,1,1)
						IF aQD0Doc[ic,nQD0Flag]<>"I".and. aQD0Doc[ic,nQD0film]+aQD0Doc[ic,nQD0dept]+aQD0Doc[ic,nQD0Mat]==cMatFil+cMatDep+cMatCod
							IF !lBxMinR .Or. (lBxMinR .And. nPend < nMinResp)
			   				lTemResp:= QD050ResND(aQD0Doc[ic,nQD0film],aQD0Doc[ic,nQD0Mat],cProxSta)
							Else
			   				lTemResp:= QD050EPxRe(aOrdem,@cProxSta)
							Endif
						Endif
					Endif
				Endif
			Next
		EndIf
		If !lTemResp
		Return .F.
		EndIf
	EndIf

QD1->(dbSetOrder(7))
	For ic:=1 To Len(aQD0DOC)
		IF aQD0Doc[ic,Len(aQD0doc[ic])]==.F.
			If aQD0Doc[ic,nQD0Flag]<>"I"
			cBuscaSts := If(aQD0Doc[ic,nQD0Aut] == Left(cStatus, 1), cStatus, aQD0Doc[ic,nQD0Aut] + Space(2))
				If (nItem := AScan( aOrdem, {|x| x[1] == cBuscaSts } ) ) > 0
				aOrdem[nItem,3]++
					If aQD0Doc[ic,nQD0Aut] == Substr(M->QDH_STATUS,1,1) .And. ( cMatDep + cMatFil + cMatCod == aQD0Doc[ic,nQD0Dept] + aQD0Doc[ic,nQD0film] + aQD0Doc[ic,nQD0mat] )
						If QD1->(DbSeek( M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + aQD0Doc[ic,nQD0Dept] + aQD0Doc[ic,nQD0film] + aQD0Doc[ic,nQD0mat] + cBuscaSts ))
							While !QD1->(Eof()) .And. M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+aQD0Doc[ic,nQD0Dept]+aQD0Doc[ic,nQD0film]+aQD0Doc[ic,nQD0mat]+aQD0Doc[ic,nQD0AUT] == QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_DEPTO+QD1->QD1_FILMAT+QD1->QD1_MAT+Left(QD1->QD1_TPPEND,1)
								If QD1->QD1_PENDEN <> "B"
								cOrdResp := aQD0Doc[ic,nQD0Ord] // Ordem de Responsavel do Usuario Logado
								Exit
								Endif
							QD1->(DbSkip())
							EndDo
						EndIf
					Endif
				Endif
			Endif
		Endif
	Next
QD1->(dbSetOrder(nOrdQD1))

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD050VldEAle³ Autor ³ Eduardo de Souza   ³ Data ³ 08/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verfica se existe Responsavel Inativo na Baixa Aleatoria. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD050VldEAle()              				                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050VldEAle(lBxMinR,nBaixa,nPend,nMinResp,aOrdem)

Local cProxSta:= ""
Local nItem   := Ascan(aOrdem,{ |X| X[1] == SuBStr(M->QDH_STATUS,1,1)+Space(2)})
Local nOrdQD1 := QD1->(IndexOrd())
Local lRet    := .T.
Local ic	  := 0             

	If (!lBxMinR .And. nBaixa < nPend) .Or. (lBxMinR .And. nBaixa < nMinResp)
	cProxSta:= AllTrim(M->QDH_STATUS)
	Else
	cProxSta:= aOrdem[nItem,2]
	EndIf

QD1->(DbSetOrder(7))	
	For ic:=1 TO Len(aQD0Doc)
		IF aQD0Doc[ic,Len(aQD0Doc[ic])]==.F.
			IF aQD0Doc[ic,nQD0Flag] <> "I"
				If QD1->(DbSeek( M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+ aQD0Doc[ic,nQD0Dept] +aQD0Doc[ic,nQD0Film] +aQD0Doc[ic,nQD0Mat] + Left(cProxSta,1)))
					While QD1->(!Eof()) .And. M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+ aQD0Doc[ic,nQD0Dept] + aQD0Doc[ic,nQD0Film] + aQD0Doc[ic,nQD0Mat]+ Left(cProxSta,1) == QD1->(QD1_FILIAL+QD1_DOCTO+QD1_RV+QD1_DEPTO+QD1_FILMAT+QD1_MAT) + Left(QD1->QD1_TPPEND,1)
						If QD1->QD1_SIT <> "I" .And. QD1->QD1_PENDEN == "P"
							If !QD050ResND(aQD0Doc[ic,nQD0Film],aQD0Doc[ic,nQD0Mat],aQD0Doc[ic,nQD0Aut])
							lRet := .F.
							Exit
							Endif
						Endif
					QD1->(DbSkip())
					Enddo
				Else
					If !QD050ResND(aQD0Doc[ic,nQD0Film],aQD0Doc[ic,nQD0Mat],aQD0Doc[ic,nQD0Aut])
					lRet := .F.
					Endif
				EndIf
			Endif
			If !lRet
			Exit
			Endif
		Endif
	Next
QD1->(DbSetOrder(nOrdQD1))

   
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD050RspExc³ Autor ³ Eduardo de Souza    ³ Data ³ 13/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Valida exclusao de responsaveis                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD050RspExc()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA050()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050RspExc()

	If cAlias3 == "QD0"
		If Acols[n,nUsado+1] .And. n <= Len(aColsAux)
			If SubStr(M->QDH_STATUS,1,1) == aColsAux[n,nPosAut] .And. ;
			aColsAux[n,nPosFil]+aColsAux[n,nPosCod]+aColsAux[n,nPosDep] == cMatFil+cMatCod+cMatDep
			Acols[n,nUsado+1]:= .F.
			Help(" ", 1, "QDO50NDRSP")	// "Responsavel pela etapa nao pode ser deletado."
				Else
				If !QD050RspEta()
				Acols[n,nUsado+1]:= .F.	
				EndIf
			EndIf
		EndIf
	EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD050RspEta³ Autor ³ Eduardo de Souza     ³ Data ³ 13/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se usuario podera alterar as etapas/responsaveis  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD050RspEta()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050RspEta()


Local nNivel    := 1
Local lReturn   := .T.

	If n <= Len(AcolsAux)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Colocado a verificacao desmembrada para facilitar o entendimento das condicoes  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If M->QDH_STATUS $ "D  ,DC"
		nNivel := 1
		ElseIf M->QDH_STATUS $ "E  ,EC "
		nNivel := 2
		ElseIf M->QDH_STATUS $ "R  "
		nNivel := 3
		ElseIf M->QDH_STATUS $ "A  "
		nNivel := 4
		EndIf
	
		If SubStr(M->QDH_STATUS,1,1) == aCols[n,nPosAut]
			If (nOrd:= Ascan( aColsAux, { |X| X[nPosFil]+X[nPosCod]+X[nPosDep] == cMatFil+cMatCod+cMatDep } )) > 0
				If aCols[n,nPosOrd] <= aCols[nOrd,nPosOrd]
				lReturn:= .F.
				EndIf
			Else
			lReturn:= .F.
			EndIf
		Else
			If aCols[n,nPosAut] == "E" .And. nNivel > 2 .Or. ;
			aCols[n,nPosAut] == "R" .And. nNivel > 3 .Or. ;	
			aCols[n,nPosAut] == "A" .And. nNivel > 4 .Or. ;
			aCols[n,nPosAut] == "H" .And. nNivel > 5
			lReturn := .F.
				EndIf
		EndIf
	
		If !lReturn
		Help(" ", 1,"QDO50NARSP")	// "Nao podera ser alterado os responsaveis das etapas anteriores ou igual a etapa atual"
		EndIf
	EndIf

Return lReturn

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD050Dupli ³ Autor ³ Eduardo de Souza     ³ Data ³ 23/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Duplicacao de Documentos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD050Dupli()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050Dupli()

Local aQD0Dupl := {}
Local aQD6Dupl := {}
Local aQDBDupl := {}
Local aQDHDupl := {}
Local aQDZDupl := {}
Local aQDVDupl := {}
Local nI       := 0

Private aDuplDoc := {}
Private lDupl  := .T.

QD0->(DbSetOrder(1))
QD6->(DbSetOrder(1))
QDB->(DbSetOrder(1))
QDG->(DbSetOrder(1))
QDH->(DbSetOrder(1))
QDJ->(DbSetOrder(1))
QDZ->(DbSetOrder(1))
QDV->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura do Array aDuplDoc (Duplicacao de Documento) ³
//³                                                       ³
//³ aDuplDoc[1] - QDH (Documentos)                        ³
//³ aDuplDoc[2] - QD0 (Responsaveis)                      ³
//³ aDuplDoc[3] - QD6 (Palavras Chaves)                   ³
//³ aDuplDoc[4] - QDB (Referencias)                       ³
//³ aDuplDoc[5] - QDZ (Distribuicao)                      ³
//³ aDuplDoc[6] - QDV (Normas)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("QDH")
	For nI := 1 To FCount()
	aAdd(aQDHDupl,FieldGet(nI))
	Next nI
Aadd(aDuplDoc,aQDHDupl)

	If QD0->(DbSeek(xFilial("QDH")+QDH->QDH_DOCTO+QDH->QDH_RV))
		While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV == xFilial("QDH")+QDH->QDH_DOCTO+QDH->QDH_RV
			If QD0->QD0_FLAG <> "I" .And. cPaisLoc == "BRA"
				aAdd(aQD0Dupl,{QD0->QD0_AUT,QD0->QD0_ORDEM,QD0->QD0_FILMAT,QD0->QD0_MAT,QD0->QD0_FLAG,QD0->QD0_DEPTO,QD0->QD0_EDITDO})
			EndIf
		QD0->(DbSkip())
		EndDo
	EndIf
Aadd(aDuplDoc,aQD0Dupl)

	If QD6->(DbSeek(xFilial("QDH")+QDH->QDH_DOCTO+QDH->QDH_RV))
		While QD6->(!Eof()) .And. QD6->QD6_FILIAL+QD6->QD6_DOCTO+QD6->QD6_RV == xFilial("QDH")+QDH->QDH_DOCTO+QDH->QDH_RV
		aAdd(aQD6Dupl,{QD6->QD6_CHAVE})
		QD6->(DbSkip())
		EndDo
	EndIf
Aadd(aDuplDoc,aQD6Dupl)

	If QDB->(DbSeek(xFilial("QDH")+QDH->QDH_DOCTO+QDH->QDH_RV))
		While QDB->(!Eof()) .And. QDB->QDB_FILIAL+QDB->QDB_DOCTO+QDB->QDB_RV == xFilial("QDH")+QDH->QDH_DOCTO+QDH->QDH_RV
		aAdd(aQDBDupl,{QDB->QDB_SEQ,QDB->QDB_ORIGEM,QDB->QDB_REVIS,QDB->QDB_DOCREF,QDB->QDB_DESC})
		QDB->(DbSkip())
		EndDo
	EndIf
Aadd(aDuplDoc,aQDBDupl)	

	If QDZ->(DbSeek(xFilial("QDH")+QDH->QDH_DOCTO+QDH->QDH_RV))
		While QDZ->(!Eof()) .And. QDZ->QDZ_FILIAL+QDZ->QDZ_DOCTO+QDZ->QDZ_RV == xFilial("QDH")+QDH->QDH_DOCTO+QDH->QDH_RV
		aAdd(aQDZDupl,{QDZ->QDZ_FILMAT,QDZ->QDZ_DEPTO,QDZ->QDZ_MAT,QDZ->QDZ_DIGITA})
		QDZ->(DbSkip())
		EndDo
	EndIf
Aadd(aDuplDoc,aQDZDupl)

	If QDV->(DbSeek(xFilial("QDH")+QDH->QDH_DOCTO+QDH->QDH_RV))
		While QDV->(!Eof()) .And. QDV->QDV_FILIAL+QDV->QDV_DOCTO+QDV->QDV_RV == xFilial("QDH")+QDH->QDH_DOCTO+QDH->QDH_RV
		aAdd(aQDVDupl,{QDV->QDV_NORMA})
		QDV->(DbSkip())
		EndDo
	EndIf
Aadd(aDuplDoc,aQDVDupl)                                     



QD050Telas("QDH",QDH->(Recno()),9)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD50AtuDupl³ Autor ³ Eduardo de Souza     ³ Data ³ 24/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza dados de duplicacao do documento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD50AtuDupl()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QD50AtuDupl()

Local ic      := 0
Local nCnt    := 0
Local nCntQD0 := 0
Local nPos1   := 0
Local nPos2   := 0
Local nPos3   := 0
Local nPos4   := 0
Local nPos5   := 0
Local nPos6   := 0
Local nPos7   := 0
Local nPos8   := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ARRAY de AHEADERS ³
	//³aHedDoc[1] = QD0  ³
	//³aHedDoc[2] = QD6  ³
	//³aHedDoc[3] = QDB  ³
	//³aHedDoc[4] = QDZ  ³
	//³aHedDoc[5] = QD4  ³
	//³aHedDoc[6] = QDV  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	lIncDepois := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Responsaveis 						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aQD0Doc := {}
	
	nPos1 := GdFieldPos("QD0_AUT"   ,aHedDoc[1])
	nPos2 := GdFieldPos("QD0_ORDEM" ,aHedDoc[1])
	nPos3 := GdFieldPos("QD0_FILMAT",aHedDoc[1])
	nPos4 := GdFieldPos("QD0_MAT"   ,aHedDoc[1])
	nPos5 := GdFieldPos("QD0_FLAG"  ,aHedDoc[1])
	nPos6 := GdFieldPos("QD0_DEPTO" ,aHedDoc[1])
	nPos7 := GdFieldPos("QD0_NOME"  ,aHedDoc[1])

	If cPaisLoc == "BRA"
		nPos8 := GdFieldPos("QD0_EDITDO"  ,aHedDoc[1])
	EndIf
	For nCnt := 1 To Len(aDuplDoc[2])
		If POSICIONE("QAA", 1, aDuplDoc[2][nCnt][3] + aDuplDoc[2][nCnt][4], "QAA_STATUS") <> '1'
			Loop
		EndIf
		nCntQD0++
		AADD(aQD0Doc,{'','','','','','','','',Nil,Nil,.F.})

		If aDuplDoc[2][nCnt][1] == "E"
			aQD0Doc[nCntQD0,nPos1] := "1"
		ElseIf aDuplDoc[2][nCnt][1] == "R"
			aQD0Doc[nCntQD0,nPos1] := "2"
		ElseIf aDuplDoc[2][nCnt][1] == "A"
			aQD0Doc[nCntQD0,nPos1] := "3"
		ElseIf aDuplDoc[2][nCnt][1] == "H"
			aQD0Doc[nCntQD0,nPos1] := "4"
		EndIf
		
		aQD0Doc[nCntQD0,nPos2] := aDuplDoc[2][nCnt][2]
		aQD0Doc[nCntQD0,nPos3] := aDuplDoc[2][nCnt][3]
		aQD0Doc[nCntQD0,nPos4] := aDuplDoc[2][nCnt][4]
		aQD0Doc[nCntQD0,nPos5] := aDuplDoc[2][nCnt][5]
		aQD0Doc[nCntQD0,nPos6] := aDuplDoc[2][nCnt][6]
		aQD0Doc[nCntQD0,nPos7] := Padr( QA_NUSR( aQD0Doc[nCntQD0,nPos3], aQD0Doc[nCntQD0,nPos4] ),40 )	
		If nPos8 > 0 .And. cPaisLoc == "BRA"
			aQD0Doc[nCntQD0,nPos8] := aDuplDoc[2][nCnt][7]	
		Endif

	Next nCnt

	aQD0Doc := aSort( aQD0Doc, , , { |x,y| x[nPos1] + x[nPos2] < y[nPos1] + y[nPos2] } )
	
	For nCnt :=1 to Len( aQD0Doc )
		If aQD0Doc[nCnt][nPos1] == "1"
			aQD0Doc[nCnt][nPos1] := "E"
		ElseIf aQD0Doc[nCnt][nPos1] == "2"
			aQD0Doc[nCnt][nPos1] := "R"
		ElseIf aQD0Doc[nCnt][nPos1] == "3"
			aQD0Doc[nCnt][nPos1] := "A"
		ElseIf aQD0Doc[nCnt][nPos1] == "4"
			aQD0Doc[nCnt][nPos1] := "H"
		EndIf
	Next
	
	aQD0Doc := aClone(aQD0Doc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Palavras Chaves      				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	For nCnt:= 2 To Len(aDuplDoc[3])
		AADD(aQD6Doc,Aclone(aQD6Doc[1]))
	Next

	nPos1:= GdFieldPos("QD6_CHAVE",aHedDoc[2])
	For nCnt:= 1 To Len(aDuplDoc[3])
		aQD6Doc[nCnt,nPos1] := aDuplDoc[3][nCnt][1]
	Next nCnt

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Referencias  						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCnt:= 2 To Len(aDuplDoc[4])
		AADD(aQDBDoc,Aclone(aQDBDoc[1]))
	Next

	nPos1:= GdFieldPos("QDB_SEQ"   ,aHedDoc[3])
	nPos2:= GdFieldPos("QDB_ORIGEM",aHedDoc[3])
	nPos3:= GdFieldPos("QDB_REVIS" ,aHedDoc[3])
	nPos4:= GdFieldPos("QDB_DOCREF",aHedDoc[3])
	nPos5:= GdFieldPos("QDB_DESC"  ,aHedDoc[3])
	For nCnt:= 1 To Len(aDuplDoc[4])
		aQDBDoc[nCnt,nPos1]	:= aDuplDoc[4][nCnt][1]
		aQDBDoc[nCnt,nPos2]	:= aDuplDoc[4][nCnt][2]
		aQDBDoc[nCnt,nPos3]	:= aDuplDoc[4][nCnt][3]
		aQDBDoc[nCnt,nPos4]	:= aDuplDoc[4][nCnt][4]
		aQDBDoc[nCnt,nPos5]	:= aDuplDoc[4][nCnt][5]
	Next nCnt

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Distribuicao  						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCnt:= 2 To Len(aDuplDoc[5])
		AADD(aQDZDoc,aClone(aQDZDoc[1]))
	Next

	nPos1:= GdFieldPos("QDZ_FILMAT",aHedDoc[4])
	nPos2:= GdFieldPos("QDZ_DEPTO" ,aHedDoc[4])
	nPos3:= GdFieldPos("QDZ_MAT"   ,aHedDoc[4])
	nPos4:= GdFieldPos("QDZ_DIGITA",aHedDoc[4])
	nPos5:= GdFieldPos("QDZ_NOME"  ,aHedDoc[4])
	For nCnt:= 1 To Len(aDuplDoc[5])
		aQDZDoc[nCnt,nPos1]	:= aDuplDoc[5][nCnt][1]
		aQDZDoc[nCnt,nPos2]	:= aDuplDoc[5][nCnt][2]
		aQDZDoc[nCnt,nPos3]	:= aDuplDoc[5][nCnt][3]
		aQDZDoc[nCnt,nPos4]	:= aDuplDoc[5][nCnt][4]
		aQDZDoc[nCnt,nPos5]	:= Padr( QA_NUSR( aQDZDoc[nCnt,nPos1], aQDZDoc[nCnt,nPos3] ),40 )	
	Next nCnt

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Normas               				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	For nCnt:= 2 To Len(aDuplDoc[6])
		AADD(aQDVDoc,Aclone(aQDVDoc[1]))
	Next

	nPos1:= GdFieldPos("QDV_NORMA",aHedDoc[6])
	nPos2:= GdFieldPos("QDV_DESC",aHedDoc[6])

	For nCnt:= 1 To Len(aDuplDoc[6])
		aQDVDoc[nCnt,nPos1] := aDuplDoc[6][nCnt][1]
		aQDVDoc[nCnt,nPos2] := QA_NORMA(aDuplDoc[6][nCnt][1])
	Next nCnt


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Destinos     						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Array aQDJDoc
	//1 - QDJ->QDJ_FILIAL
	//2 - QDJ->QDJ_DOCTO
	//3 - QDJ->QDJ_RV
	//4 - QDJ->QDJ_FILMAT
	//5 - QDJ->QDJ_DEPTO
	//6 - QDJ->QDJ_TIPO,

	//9 -Array aQDjDoc
	// 1 - QDG->QDG_FILIAL
	// 2 - QDG->QDG_DOCTO
	// 3 - QDG->QDG_RV
	// 4 - QDG->QDG_FILMAT
	// 5 - QDG->QDG_DEPTO
	// 6 - QDG->QDG_MAT
	// 7 - QDG->QDG_NCOP,
	// 8 - QDG->QDG_TPRCBT
	// 9 - QDG->QDG_RECEB
	//10 - QDG->QDG_TIPO
	//11 - QDG->QDG_CODMAN
	//12 - QDG->QDG_SIT,

	For nCnt:= 1 To Len(aQDJDoc)
		aQDJDoc[nCnt,1]	:= M->QDH_FILIAL
		aQDJDoc[nCnt,2]	:= M->QDH_DOCTO
		aQDJDoc[nCnt,3]	:= M->QDH_RV
			For ic:= 1 To Len(aQDJDoc[nCnt,9])
				aQDJDoc[nCnt,9,ic,1]:= M->QDH_FILIAL
				aQDJDoc[nCnt,9,ic,2]:= M->QDH_DOCTO
				aQDJDoc[nCnt,9,ic,3]:= M->QDH_RV
			Next ic
	Next nCnt

Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD050Filtro³ Autor ³ Wagner Mobile Costa³ Data ³ 06/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o filtro do cadastro de documentos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD050Filtro()             				                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Qd050Filtro

cFiltro := 'QDH->QDH_FILIAL == "'+xFilial("QDH")+'" .And. ((QDH->QDH_CANCEL != "S" .Or. ( QDH->QDH_CANCEL == "S" .And. QDH->QDH_STATUS!="L  " )) .And. ((QDH->QDH_OBSOL !="S" .And. Dtos(QDH->QDH_DTVIG) <= "'+Dtos(dDataBase)+'" .And. QDH->QDH_FUTURA <> "G") .Or. (QDH->QDH_OBSOL == "S" .And. Dtos(QDH->QDH_DTLIM) >= "'+Dtos(dDataBase)+'" )))'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada criado para mudar o Filtro ou realizar alguma tarefa especifica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QDOFILBR")
		cFiltro := ExecBlock("QDOFILBR", .f., .f.,{cFiltro})
	EndIf

Return cFiltro
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Qd050DstPd ³ Autor ³ Wagner Mobile Costa³ Data ³ 26/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se existem distribuicoes pendentes               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Qd050DstPd()             				                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Qd050DstPd

Local lRet := .F.
Local nOrdQD1 := QD1->(IndexOrd())

QD1->(DbSetOrder(8))
	If QDH->QDH_OBSOL == "N" .And. (QDH->QDH_STATUS == "L  " .OR. QDH->QDH_STATUS == "I  ") .And. QDH->QDH_CANCEL <> "S"
		If QD1->(DBSeek(QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV + "I  P"))
		lRet := .T.
		Endif
	Endif
QD1->(DbSetOrder(nOrdQD1))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QA_CHKDIST³ Autor ³ Wagner Mobile Costa   ³ Data ³ 26.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica o Usuario/Departamento possibilita distribuicao   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QA_CHKDIST()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA_CHKDIST(lTudoOk)

Local lRet := .F.
Local nPos0:= Ascan(aHeader,{ |X| Upper(ALLTRIM(X[2])) == "QDZ_FILMAT"})
Local nPos1:= Ascan(aHeader,{ |X| Upper(ALLTRIM(X[2])) == "QDZ_DEPTO" })
Local nPos2:= Ascan(aHeader,{ |X| Upper(ALLTRIM(X[2])) == "QDZ_MAT"   })
Local nPos3:= Ascan(aHeader,{ |X| Upper(ALLTRIM(X[2])) == "QDZ_NOME"  })
Local nPos4:= Ascan(aHeader,{ |X| Upper(ALLTRIM(X[2])) == "QDZ_DIGITA"})
Local nPos5:= Ascan(aHeader,{ |X| Upper(ALLTRIM(X[2])) == "QDZ_REC_WT"})
Local nPos6:= 0 // Posicao de exclusao do aCols
Local lPrim:=.T., lGerQdz := .F.
Local cDepto, cMat
Local nCont	:= 0
Local AcolsA := {}               


DEFAULT lTudoOk := .F.

	If !lAltDoc
	Return .T.
	Endif

	If ! lTudoOk .And. ReadVar() == "M->QDZ_DEPTO"
	cDepto := M->QDZ_DEPTO
	cMat := aCols[n][nPos2]
	Else
	cDepto := aCols[n][nPos1] 
	cMat := If(lTudoOk, aCols[n][nPos2], M->QDZ_MAT)
	Endif

Aeval( aCols, { |X| Iif( 	X[nPos0] == aCols[N, nPos0] .And.;
							X[nPos1] == cDepto .And.;
						 	X[nUsado+1] == .F., nCont ++ , nCont ) } )

	If nCont > 1 .And. lTudoOk .And. Empty(cMat)
	MsgAlert(STR0133,OemToAnsi(STR0026)) // "Aviso" //"Centro de custo ja informado eh obrigatorio o preenchimento do usuario !"
	Return .F.
	ElseIf ! Empty(cMat)
	nCont := 0
	Aeval( aCols, { |X| If( 	X[nPos0] == aCols[N, nPos0] .And.;
								X[nPos1] == cDepto .And. Empty(X[nPos2]) .And.;
							 	X[nUsado+1] == .F., nCont ++ , nCont ) } )
		If nCont > 1
		MsgAlert(STR0134,OemToAnsi(STR0026)) // "Aviso" //"Centro de custo ja informado para preenchimento na distribuicao !"
		Return .F.
		Endif
	Endif

	If Empty(cMat)
	QAA->(DbSetOrder(2))
	QAA->(DbSeek(aCols[n][nPos0] + cDepto))
		While 	! QAA->(Eof()) .And. QAA->QAA_FILIAL == aCols[n][nPos0] .And.;
			QAA->QAA_CC == cDepto
				If QAA->QAA_DISTSN == "1" .AND. QA_SITFOLH()
				If lPrim .And. aCols[n][nPos4] == "1" .And. nCont < 2 .And. Procname(1)=="QD050MTGET"
				lGerQdz := MsgYesNo(STR0135,OemToAnsi(STR0023)) // "Aten‡„o" //"Deseja preencher a lista de distribuidores baseado no cadastro ?"
					If ! lGerQdz
						aCols[n][nPos4] := "3" //Não faz de forma  automática
					Endif
				Endif
				If lGerQdz
					If lPrim
					aCols[n][nPos2] := QAA->QAA_MAT
					aCols[n][nPos3] := Left(QAA->QAA_NOME, 40)
					Else
					Aadd(aCols, AClone(aCols[Len(aCols)]))
					aCols[Len(aCols)][nPos0] := QAA->QAA_FILIAL
					aCols[Len(aCols)][nPos1] := QAA->QAA_CC
					aCols[Len(aCols)][nPos2] := QAA->QAA_MAT
					aCols[Len(aCols)][nPos3] := Left(QAA->QAA_NOME, 40)
					Endif
				aCols[n][nPos4] := "2"
				lRet := .T.
				Else
				lRet := .T.
				Exit
				Endif
			lPrim := .F.
			Endif
		QAA->(DbSkip())
		EndDo
	Else
	QAA->(DbSetOrder(1))
		If QAA->(DbSeek(aCols[n][nPos0] + cMat)) .And. QAA->QAA_DISTSN == "1" .And.;
		QAA->QAA_CC == cDepto .AND. QA_SITFOLH()
		aCols[n][nPos4] := "2"
		lRet := .T.
			Endif
	Endif

	If ! lRet
		If Empty(cMat)
		MsgAlert(STR0136,OemToAnsi(STR0026)) // "Aviso" //"O departamento informado deve ter no minimo um distribuidor indicado !"
		ElseIf QAA->QAA_CC <> cDepto
		MsgAlert(STR0137,OemToAnsi(STR0026)) // "Aviso" //"O usuario informado nao eh do departamento indicado !"
		ElseIf QAA->QAA_DISTSN == "2"
		MsgAlert(STR0138,OemToAnsi(STR0026)) // "Aviso" //"O usuario informado nao esta indicado como um distribuidor no cadastro !"
		Endif
	Endif

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD50DSTATU³ Autor ³ Wagner Mobile Costa   ³ Data ³ 24.09.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza os lancamentos dos usuarios distribuidores        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD50DSTATU(cFilQAD,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD50DSTATU(cFilQAD,nOpc,nOrdQAA)
	Local lDistCC := .F.
	Local lDistrQdz := SuperGetMV("MV_DISQDZ",.F.,.F.) //Define se o distribuidor do documento não irá receber a pendência de leitura

	QDZ->(DbSetOrder(1))
	If QDZ->(DbSeek(M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV))
		While !QDZ->(Eof());
			.And. QDZ->QDZ_FILIAL == M->QDH_FILIAL;
			.And. QDZ->QDZ_DOCTO  == M->QDH_DOCTO;
			.And. QDZ->QDZ_RV     == M->QDH_RV

			QAA->(DbSetOrder(2))
			If Empty(QDZ->QDZ_MAT)  .And. QAA->(DbSeek(QDZ->QDZ_FILMAT+QDZ->QDZ_DEPTO))
				While QAA->(!Eof()) .And. QAA->QAA_FILIAL+QAA->QAA_CC == QDZ->QDZ_FILMAT+QDZ->QDZ_DEPTO
					If QA_SitFolh() .And. QAA->QAA_DISTSN == "1"
						lDistCC := .T.
						If lDistrQdz .OR. !IsInCallStack("QDOA110")
							QD050GrDst( .f., QAA->QAA_FILIAL, QAA->QAA_CC, QAA->QAA_MAT, , QAA->QAA_TPRCBT, 1 ,,nOpc)
						EndIf
						If M->QDH_TREINA == "1" .And. M->QDH_CANCEL <> "S"
							//³Grava Aviso Necessidade de realizar Treinamento
							If IsInCallStack("QDOA110")
								QDS->(DbSetOrder(1))
								If !QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"+"TRE"+M->QDH_DOCTO+M->QDH_RV))
									QDXGvAviso("TRE",QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,M->QDH_DOCTO,M->QDH_RV,,M->QDH_FILIAL)
								Endif
							EndIF
						EndIf
					EndIf
				QAA->(DbSkip())
				EndDo

			ElseIf !Empty(QDZ->QDZ_MAT);
				.And. QAA->(DbSeek(QDZ->QDZ_FILMAT+QDZ->QDZ_DEPTO+QDZ->QDZ_MAT));
				.And. QA_SitFolh()

				lDistCC := .T.
				If lDistrQdz .OR. !IsInCallStack("QDOA110")
					QD050GrDst( .f., QAA->QAA_FILIAL, QAA->QAA_CC, QAA->QAA_MAT, , QAA->QAA_TPRCBT, 1 ,,nOpc)
				EndIf
				If M->QDH_TREINA == "1" .And. M->QDH_CANCEL <> "S"
					//³Grava Aviso Necessidade de realizar Treinamento
					If IsInCallStack("QDOA110")
						QDS->(DbSetOrder(1))
						If !QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"+"TRE"+M->QDH_DOCTO+M->QDH_RV))
							QDXGvAviso("TRE",QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,M->QDH_DOCTO,M->QDH_RV,,M->QDH_FILIAL)
						Endif
					EndIf
				EndIf
			EndIf
			QDZ->(DbSkip())
		EndDo
	EndIf

	QAA->(DbSetOrder(nOrdQAA))
	If !lDistCC
		QAD->(DbSetOrder(1))
		If QAD->(DbSeek(cFilQad+M->QDH_DEPTOD))
			If lDistrQdz .OR. !IsInCallStack("QDOA110")
				QD050GrDst( .f., QAD->QAD_FILMAT, QAD->QAD_CUSTO, QAD->QAD_MAT, , "1", 1 ,,nOpc)
			Endif
			If M->QDH_TREINA == "1" .And. M->QDH_CANCEL <> "S"
				//³Grava Aviso Necessidade de realizar Treinamento
				If IsInCallStack("QDOA110")
					QDS->(DbSetOrder(1))
					If !QDS->(DbSeek(QAD->QAD_FILMAT+QAD->QAD_MAT+"P"+"TRE"+M->QDH_DOCTO+M->QDH_RV))
						QDXGvAviso("TRE",QAD->QAD_FILMAT,QAD->QAD_MAT,QAD->QAD_CUSTO,M->QDH_DOCTO,M->QDH_RV,,M->QDH_FILIAL)
					Endif
				EndIf
			EndIf
		EndIf
	EndIf

Return             

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDO050ChFo³ Autor ³ Telso Carneiro        ³ Data ³ 30.12.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controla a Troca de Folder do documento e Duplicacao do DOC³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDO050ChFo()					                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function QDO050ChFo(nFolder,lDuplDoc)
Local lRet:=.F.                        
Local nPosDoc
Local nPosRev                  
Local nPosTpDoc
Local nPosDocIE                  
Local lRmtlnx:=.T.

	IF nFolder <> 1 .AND. INCLUI
		IF QDOChkRmt() .AND. M->QDH_DTOIE =="I" //Checa se o Remote e Linux
       lRmtlnx:=.F.
		Endif
		IF Obrigatorio(aGets,aTela) .AND. lRmtlnx
			IF QD050ChkDoc(M->QDH_FILIAL,M->QDH_DOCTO, M->QDH_RV, lDuplDoc)
		 	lRet:=.T.
			Endif
			IF lDuplDoc .AND. lRet
			MsgRun(OemToAnsi(STR0128),OemToAnsi(STR0079),{|| QD50AtuDupl()}) // "Duplicando Documento..." ### "Aguarde..."			
			ENDIF
		Endif
	Else
		IF INCLUI
		nPosDoc:=Ascan(aGets,{|X| "QDH_DOCTO"$X } )
		nPosRev:=Ascan(aGets,{|X| "QDH_RV"$X } )
		nPosTpDoc:=Ascan(aGets,{|X| "QDH_CODTP"$X } )
		nPosDocIE:=Ascan(aGets,{|X| "QDH_DTOIE"$X } )
		        
			IF !EMPTY(M->QDH_DOCTO) .AND. !EMPTY(M->QDH_RV) .AND. FreeForUse("QDH",M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV)
			oGetDoc:AENTRYCTRLS[nPosDoc]:BWHEN:={|X| .F. }
			oGetDoc:AENTRYCTRLS[nPosRev]:BWHEN:={|X| .F. }
			oGetDoc:AENTRYCTRLS[nPosTpDoc]:BWHEN:={|X| .F. }
			oGetDoc:AENTRYCTRLS[nPosDocIE]:BWHEN:={|X| .F. }
			ENDIF
		ENDIF
	lRet:=.T.		   	
	Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDO050CARR³ Autor ³ Aldo Marini Junior    ³ Data ³ 26/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Atualizacao dos arrays dos sub-cadastros	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDO050CARR()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDO050CARR                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QDO050CARR(nOpc, lRespQD0)

Local aCad        := {}
Local aColsAux    := {}
Local aHeaderQD0  := {}
Local aHeaderTemp := {}
Local aStruCad    := {}
Local lNaoGerRv   := .T.
Local nCnt        := 0
Local nCt         := 0
Local nPosA       := 0
Local nPosAli     := 0
Local nPosRec     := 0
Local nT          := 0
Local nUsado      := 0
local nX          := 0
Local QD050Field  := ""

Private aHeader := {}
Private cCod    := ""
Private cFil    := ""
Private cRv     := ""

Default lRespQD0 := .F.

aCad := {"QD0","QD6","QDB","QDZ","QD4","QDV"}

	For nT := 1 to Len(aCad)
	
		cFil := aCad[nT]+"_FILIAL"
		cCod := aCad[nT]+"_DOCTO"
		cRv  := aCad[nT]+"_RV"
		QD050Field := {cFil,cCod,cRv}
		
		aHeader:={}
		aStruCad := FWFormStruct(3,aCad[nT])[3]

		aHeader := GetEstrTab(aStruCad, aCad[nT], )
	
		// Inclui coluna de registro atraves de funcao generica
		ADHeadRec(aCad[nT], aHeader)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ VerIfica se existe algum dado no arquivo                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCnt:= 0
		DbSelectArea( aCad[nT] )
		If DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV) .And. !(aCad[nT] == "QD0" .And. lRespQD0)
			While !EOF() .And. &(cFil+"+"+cCod+"+"+cRv) == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
				If aCad[nT] == "QD0"
					If nOpc == 7 .OR. nOpc == 6  //Gera Revisao  - Cancelamento de Documento
						If QD0->QD0_FLAG == "I"
							DbSkip()
							Loop
						Endif
					Else
						If  QD0->QD0_FLAG == "I" .And. M->QDH_STATUS <> "L  " 
							DbSkip()
							Loop
						Endif
					Endif
				Endif
				nCnt++
				DbSkip()
			EndDo
		EndIf

		aColsAux := ARRAY( If(nCnt == 0,1,nCnt) ,Len(aHeader)+1)
	
		If aCad[nT] == "QD0"
			nPosA := GdFieldPos( "QD0_AUT" ,aHeader)
			nPosB := GdFieldPos( "QD0_ORDEM" ,aHeader)
		ElseIF aCad[nT]=="QDZ"
			N		:= 1
			nLenCol := Len(aColsAux)
		Endif
	
		If aCad[nT] == "QD4"
			aQD4Ini := ARRAY( If(nCnt == 0,1,nCnt) ,Len(aHeader)+4)		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gera Revisao / Cancelamento de Documento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF nOpc == 7 .OR. nOpc == 6
				lNaoGerRv:=.F.
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gerar o array com os Lancamentos                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea(aCad[nT])
		If DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV) .AND. lNaoGerRv .And. !(aCad[nT] == "QD0" .And. lRespQD0)
			nCnt := 0
			While !EOF() .And. &(cFil+"+"+cCod+"+"+cRv) == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
				If aCad[nT] == "QD0"
					If nOpc == 7 .OR. nOpc == 6  //Gera Revisao  - Cancelamento de Documento
						If QD0->QD0_FLAG == "I"
							DbSkip()
							Loop
						Endif
					Else
						If QD0->QD0_FLAG == "I" .And. M->QDH_STATUS <> "L  " 
							DbSkip()
							Loop
						Endif
					Endif
				Endif
				nCnt++
				nUsado:=0
				N := nCnt		
				For nX := 1 To Len(aStruCad)
					If cNivel >= GetSx3Cache(aStruCad[nX, 1], 'X3_NIVEL') .and. ! ASCAN({cFil,cCod,cRv},{|x| x == Trim(aStruCad[nX, 1])}) > 0
						nUsado++
						If GetSx3Cache(aStruCad[nX, 1], 'X3_CONTEXT') == "V"
							If aCad[nT] == "QD0"
								IF Upper( Alltrim( aStruCad[nX, 1] ) ) == "QD0_NOME"
									aColsAux[nCnt,nUsado] := Padr( QA_NUSR( QD0->QD0_FILMAT, QD0->QD0_MAT ), 40 )
								Else
									aColsAux[nCnt,nUsado] := CriaVar(AllTrim(aStruCad[nX, 1]))
								EndIf
							ElseIF aCad[nT] == "QD4"
								IF Upper( Alltrim( aStruCad[nX, 1] ) ) == "QD4_NOME"
									aColsAux[nCnt,nUsado] := Padr( QA_NUSR( QD4->QD4_FILMAT, QD4->QD4_MAT ), 40 )
								Endif
							Else
								aColsAux[nCnt,nUsado] := CriaVar(AllTrim(aStruCad[nX, 1]))
							Endif
						Else
							IF aCad[nT] == "QD4"
								IF  GdFieldPos(Upper(Alltrim(aStruCad[nX, 1])),aHeader)!=0
									aColsAux[nCnt,nUsado] := &(aCad[nT]+"->"+Alltrim(aStruCad[nX, 1]))
								Else
									nUsado--
								Endif
							Else
								aColsAux[nCnt,nUsado] := &(aCad[nT]+"->"+Alltrim(aStruCad[nX, 1]))
							Endif
						EndIf
					EndIf
				Next nX
				nPosAli := Ascan(aHeader,{|x| AllTrim(x[2]) == aCad[nT]+"_ALI_WT"})
				nPosRec := Ascan(aHeader,{|x| AllTrim(x[2]) == aCad[nT]+"_REC_WT"})
				If nPosAli > 0 .And. nPosRec > 0
					AcolsAux[nCnt,nPosAli] := (aCad[nT])->(Alias())
					If IsHeadRec(aHeader[nPosRec,2])
     					AcolsAux[nCnt,nPosRec] := (aCad[nT])->(RecNo())
					EndIf
				Endif
				aColsAux[nCnt,Len(aColsAux[nCnt])] := .F.

				If aCad[nT] == "QD4"
					aQD4Ini[nCnt] := aClone(aColsAux[nCnt])
					aAdd(aQD4Ini[nCnt],QD4->QD4_TPPEND)
					aAdd(aQD4Ini[nCnt],QD4->QD4_FILMAT)
					aAdd(aQD4Ini[nCnt],QD4->QD4_MAT)
				Endif

			DbSelectArea( aCad[nT] )
			DbSkip() 
			EndDo
		Else
			// Inicializa os arrays caso nao encontre conforme tabelas
			If aCad[nT] == "QD4"
				lNaoGerRv:=.T.
				nUsado:= 0   
				For nX := 1 To Len(aStruCad)
					If GdFieldPos(Upper(Alltrim(aStruCad[nX, 1])),aHeader)!=0
					nUsado++
					aColsAux[1, nUsado] := CriaVar(allTrim(aStruCad[nX, 1]))
					aQD4Ini[1, nUsado] := CriaVar(allTrim(aStruCad[nX, 1]))
					EndIf
				Next nX
				nPosAli := Ascan(aHeader,{|x| AllTrim(x[2]) == aCad[nT]+"_ALI_WT"})
				nPosRec := Ascan(aHeader,{|x| AllTrim(x[2]) == aCad[nT]+"_REC_WT"})
				If nPosAli > 0 .And. nPosRec > 0
					AcolsAux[1,nPosAli] := (aCad[nT])->(Alias())
					If IsHeadRec(aHeader[nPosRec,2])
						AcolsAux[1,nPosRec] := 0
					EndIf
				Endif
				aColsAux[1, Len(aColsAux[1])] := .F.

				If M->QDH_STATUS $ "E  ,EC "
					aQD4Ini[1][Len(aColsAux[1])+1] := "DC "
				ElseIf M->QDH_STATUS $ "R  ,A  ,H  "
					aQD4Ini[1][Len(aColsAux[1])+1] := "EC "
				Else
					aQD4Ini[1][Len(aColsAux[1])+1] := M->QDH_STATUS
				EndIf

				aQD4Ini[1][Len(aColsAux[1])+2] := cMatFil
				aQD4Ini[1][Len(aColsAux[1])+3] := cMatCod
			
			ElseIf aCad[nT] == "QDB"
				nUsado:= 0          
				For nX := 1 To Len(aStruCad)
					If GdFieldPos(Upper(Alltrim(aStruCad[nX, 1])),aHeader)!=0
						nUsado++
						IF  Upper(Alltrim(aStruCad[nX, 1])) == "QDB_SEQ"
							aColsAux[1, nUsado] := CriaVar(allTrim(aStruCad[nX, 1]),.F.)
						Else
							aColsAux[1, nUsado] := CriaVar(allTrim(aStruCad[nX, 1]))
						Endif
					EndIf
				Next nX
				nPosAli := Ascan(aHeader,{|x| AllTrim(x[2]) == aCad[nT]+"_ALI_WT"})
				nPosRec := Ascan(aHeader,{|x| AllTrim(x[2]) == aCad[nT]+"_REC_WT"})
				If nPosAli > 0 .And. nPosRec > 0
					AcolsAux[1,nPosAli] := (aCad[nT])->(Alias())
					If IsHeadRec(aHeader[nPosRec,2])
						AcolsAux[1,nPosRec] := 0
					EndIf
				Endif
				aColsAux[1, Len(aColsAux[1])] := .F.
			Endif
			IF aColsAux[1,1]==NIL
				nUsado := 0
				For nX := 1 To Len(aStruCad)
					If cNivel >= GetSx3Cache(aStruCad[nX, 1], 'X3_NIVEL') .and. ! Ascan( QD050Field, Trim( aStruCad[nX, 1] ) ) > 0
						nUsado++
						aColsAux[1, nUsado] := CriaVar( AllTrim( aStruCad[nX, 1] ) )
					EndIf
				Next nX
				nPosAli := Ascan(aHeader,{|x| AllTrim(x[2]) == aCad[nT]+"_ALI_WT"})
				nPosRec := Ascan(aHeader,{|x| AllTrim(x[2]) == aCad[nT]+"_REC_WT"})
				If nPosAli > 0 .And. nPosRec > 0
					AcolsAux[1,nPosAli] := (aCad[nT])->(Alias())
					If IsHeadRec(aHeader[nPosRec,2])
						AcolsAux[1,nPosRec] := 0
					EndIf
				Endif
				aColsAux[1,Len(aColsAux[1])] := .f. 
			Endif
		
		Endif

		If aHeader[1,9] == "QD0"
			aHeaderQD0 := aHeader
		EndIf

		If !Empty(aQD0Doc)
			IF  Empty(aQD0Doc[1,1])
				IF ExistBlock("QDOAP35")
					ExecBlock("QDOAP35", .f., .f.)                
				Else
					aheaderTemp := aHeader
					aHeader     := aHeaderQD0	
					QDO050CQDD() //Carrega Array com os Usuarios do QDD
					aHeader := aheaderTemp
				Endif
			Endif
		EndIf

		DO CASE
			CASE aCad[nT] =="QD0"
				For nCt := 1 to Len( aColsAux )
					If aColsAux[nCt][nPosA] == "E"
						aColsAux[nCt][nPosA] := "1"
					ElseIf aColsAux[nCt][nPosA] == "R"
						aColsAux[nCt][nPosA] := "2"
					ElseIf aColsAux[nCt][nPosA] == "A"
						aColsAux[nCt][nPosA] := "3"
					ElseIf aColsAux[nCt][nPosA] == "H"
						aColsAux[nCt][nPosA] := "4"
					EndIf
				Next
				aColsAux := aSort( aColsAux, , , { |x,y| x[nPosA] + x[nPosB] < y[nPosA] + y[nPosB] } )
				For nCt :=1 to Len( aColsAux )
					If aColsAux[nCt][nPosA] == "1"
						aColsAux[nCt][nPosA] := "E"
					ElseIf aColsAux[nCt][nPosA] == "2"
						aColsAux[nCt][nPosA] := "R"
					ElseIf aColsAux[nCt][nPosA] == "3"
						aColsAux[nCt][nPosA] := "A"
					ElseIf aColsAux[nCt][nPosA] == "4"
						aColsAux[nCt][nPosA] := "H"
					EndIf
				Next
				aQD0Doc := aClone(aColsAux)
			CASE aCad[nT] =="QD6"
				aQD6Doc := aClone(aColsAux)
			CASE aCad[nT] =="QDB"
				aQDBDoc := aClone(aColsAux)
			CASE aCad[nT] =="QDZ"
				aQDZDoc := aClone(aColsAux)
			CASE aCad[nT] =="QD4"
				aQD4Doc := aClone(aColsAux)
			CASE aCad[nT] =="QDV"
				aQDVDoc := aClone(aColsAux)	

		EndCASE
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ARRAY de AHEADERS ³
		//³aHedDoc[1] = QD0  ³
		//³aHedDoc[2] = QD6  ³
		//³aHedDoc[3] = QDB  ³
		//³aHedDoc[4] = QDZ  ³
		//³aHedDoc[5] = QD4  ³
		//³aHedDoc[6] = QDV  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aHedDoc,aHeader)
	
	Next

	If nOpc == 7 .And. Len(aQD0Doc) > 0 .And. !lRespQD0
		QDD->(DbSetOrder(1))
		For nCt := Len(aQD0Doc) To 1 Step -1
			If (aQD0Doc[nCt][1] == Nil) .Or.!QDD->(DbSeek(xFilial("QDD") + M->QDH_CODTP + aQD0Doc[nCt][1] + aQD0Doc[nCt][3] + aQD0Doc[nCt][6] ))
				aDel(aQD0Doc, nCt)
            	aSize(aQD0Doc,Len(aQD0Doc)-1)
			EndIf
		Next
		QDO050CARR(nOpc, .T.)
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ao gerar revisáo, atualiza o vetor de distribuidores ³
//³ validando se o usuário pode distribuir documentos	 ³
//³ (QAA_DISTSN) e a situação em folha					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 7
		DbSelectArea( "QAA" )
		DbSetOrder(1)	
		For nCt := 1 to Len(aQDZDoc)
			If !(QAA->(DbSeek(aQDZDoc[nCt,1]+aQDZDoc[nCt,3]))) .Or. !(QA_SitFolh()) .Or. QAA->QAA_DISTSN == "2"
	   			aQDZDOC[nCt,Len(aQDZDOC[nCt])] :=.T.
			EndIf
		Next
	EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD050CDEST ³ Autor ³ Aldo Marini Junior         ³ Data ³ 15/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Carrega os lancamentos dos Departamentos Destinatarios            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD050CDEST()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ Nenhum                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA050/QDOA053                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050CDEST(lDuplDoc,nOpc)

Local aAuxQDG := {}
LocaL cChave  := ""
Local cDocCod := ""
Local cDocFil := ""
Local cDocRv  := ""
Local cFilDep := xFilial("QAD")
Local cMatQAD := Space(TamSx3("QAD_MAT")[1])
LocaL cQuery  := ""
Local lAltPer := QD050AltDc(nOpc)
Local lRet    := .T.

aQDJDoc := {}
aQDGDoc := {}
                 

	IF !lDuplDoc
		cChave	:= M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
		cDocFil := M->QDH_FILIAL	
		cDocCod := M->QDH_DOCTO
		cDocRv  := M->QDH_RV
	Else
		cChave	:= QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV
		cDocFil := QDH->QDH_FILIAL	
		cDocCod := QDH->QDH_DOCTO
		cDocRv  := QDH->QDH_RV
	Endif

//Array aQDJDoc
//1 - QDJ->QDJ_FILIAL
//2 - QDJ->QDJ_DOCTO
//3 - QDJ->QDJ_RV
//4 - QDJ->QDJ_FILMAT
//5 - QDJ->QDJ_DEPTO
//6 - QDJ->QDJ_TIPO,
//7 - Descricao Tipo do Usuario
//8 - Descricao do Depto

	cQuery := " SELECT QDJ.QDJ_FILIAL, "
	cQuery +=        " QDJ.QDJ_DOCTO, "
	cQuery +=        " QDJ.QDJ_RV, "
	cQuery +=        " QDJ.QDJ_FILMAT, "
	cQuery +=        " QDJ.QDJ_DEPTO, "
	cQuery +=        " QDJ.QDJ_TIPO, "
	cQuery +=        " QAD.R_E_C_N_O_ "
	cQuery += " FROM ( "
	cQuery +=       " SELECT QDJ_FILIAL, "
	cQuery +=              " QDJ_DOCTO, "
	cQuery +=              " QDJ_RV, "
	cQuery +=              " QDJ_FILMAT, "
	cQuery +=              " QDJ_DEPTO, "
	cQuery +=              " QDJ_TIPO "
	cQuery +=       " FROM " + RetSqlName("QDJ")
	cQuery +=       " WHERE QDJ_FILIAL = '" + cDocFil + "' "
	cQuery +=         " AND QDJ_DOCTO  = '" + cDocCod + "' " 
	cQuery +=         " AND QDJ_RV     = '" + cDocRv  + "' "
	cQuery +=         " AND D_E_L_E_T_ = ' ' "
	cQuery +=        " ) QDJ " 	
	cQuery += " INNER JOIN "
	cQuery +=        " ( "
	cQuery +=         " SELECT QAD_FILIAL,
	cQuery +=                " QAD_CUSTO, "
	cQuery +=                " R_E_C_N_O_ "
	cQuery +=         " FROM " + RetSqlName("QAD")
	cQuery +=         " WHERE D_E_L_E_T_ = ' ' "
	cQuery +=         ") QAD "
	cQuery += " ON QAD.QAD_CUSTO = QDJ.QDJ_DEPTO "

	If FindFunction("QLTQCmpFil")
		cQuery +=    " AND " + QLTQCmpFil("QAD", "QDJ", "QAD", "QDJ")
	EndIf

	If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
		cQuery += " ORDER BY 1,2,6,4,5"
	Else
		cQuery += " ORDER BY " + SqlOrder("QDJ_FILIAL+QDJ_DOCTO+QDJ_TIPO+QDJ_FILMAT+QDJ_DEPTO")
	Endif

	cQuery := ChangeQuery(cQuery)			
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQDJ",.T.,.T.)	

	While TMPQDJ->(!Eof())
		If FWModeAccess("QAD") == "E" //! Empty(xFilial("QAD"))
   			cFilDep := TMPQDJ->QDJ_FILMAT
		EndIf
		IF TMPQDJ->QDJ_TIPO == "P"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Garante o Responsavel pelo Depto quando tipo pasta³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If QAD->(DBSeek(cFilDep+TMPQDJ->QDJ_DEPTO))
				cMatQAD:= QAD->QAD_MAT
				IF Empty(cMatQAD)
					Help(" ",1,"QD050CCNER",,TMPQDJ->QDJ_DEPTO,5,0)	// Nao existe Responsavel para Depto ou esta Demitido
					IF lAltPer .AND. M->QDH_STATUS != "L  "
						IF Empty(cMatQAD)
							cMatQAD:= QD053InQDG('',cFilDep,TMPQDJ->QDJ_DEPTO,QAD->QAD_FILMAT)
						EndIF
					Endif
					IF Empty(cMatQAD)
						lRet:= .F.		                            
					EndIF
				Endif
			EndIf
		Endif
		aAuxQDG := QD050CDQDG()
		If Len(aAuxQDG) > 0
		   	Aadd(aQDJDoc,{TMPQDJ->QDJ_FILIAL,TMPQDJ->QDJ_DOCTO,TMPQDJ->QDJ_RV,TMPQDJ->QDJ_FILMAT,TMPQDJ->QDJ_DEPTO,TMPQDJ->QDJ_TIPO,;
			If(TMPQDJ->QDJ_TIPO == "D",OemToAnsi(STR0060),If(TMPQDJ->QDJ_TIPO == "P",OemToAnsi(STR0146),Space(5))),;  //"Usuario"###"Pasta"
		                 QA_NDEPT(TMPQDJ->QDJ_DEPTO,.T.,cFilDep),aAuxQDG, TMPQDJ->R_E_C_N_O_})
		Endif
   		TMPQDJ->( DbSkip() )
	Enddo
   	TMPQDJ->(DBCLOSEAREA())
DbSelectArea("QDJ")  	    

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD050CDQDG ³ Autor ³ Aldo Marini Junior         ³ Data ³ 15/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Carrega os lancamentos dos Usuarios Destinatarios                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD050CDQDG()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ Nenhum                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA050/QDOA053                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050CDQDG()

	Local cFilDep := xFilial("QAD")
	Local cNomUsr := Space(30)
	Local cMatQAD := Space(TamSx3("QAD_MAT")[1])
	Local cFilMat := xFilial("QAA")
	Local cFilQDC := Space(FWSizeFilial())//" "
	Local cMatFil := Space(FWSizeFilial())//Space(2) 
	Local lTrat := GetMv("MV_QDOQDG",.T.,.F.)
	Local nFiNum  := FWSizeFilial()+3
	Local lDepx   := .F.

	aQDGDoc := {}
	//Array aQDGDoc
	// 1 - QDG->QDG_FILIAL
	// 2 - QDG->QDG_DOCTO
	// 3 - QDG->QDG_RV
	// 4 - QDG->QDG_FILMAT
	// 5 - QDG->QDG_DEPTO
	// 6 - QDG->QDG_MAT
	// 7 - QDG->QDG_NCOP,
	// 8 - QDG->QDG_TPRCBT
	// 9 - QDG->QDG_RECEB
	//10 - QDG->QDG_TIPO
	//11 - QDG->QDG_CODMAN
	//12 - QDG->QDG_SIT,
	//13 - cNomUsr,
	//14 - QDXFNANMAN(QDG->QDG_CODMAN,.T.,If(!Empty(xFilial("QDC")),QDG->QDG_FILMAT,))

	cQuery :="SELECT QDG.QDG_FILIAL,QDG.QDG_DOCTO,QDG.QDG_RV,QDG.QDG_TIPO,QDG.QDG_FILMAT,QDG.QDG_MAT,QDG.QDG_CODMAN, "
	cQuery +="QDG.QDG_DEPTO,QDG.QDG_NCOP,QDG.QDG_TPRCBT,QDG.QDG_RECEB,QDG.QDG_SIT,QAA.QAA_NOME,QAA.QAA_CODFUN "		
	cQuery +="FROM " + RetSqlName("QDG")+" QDG, "+ RetSqlName("QAA")+" QAA " 		
	cQuery +="WHERE "
	cQuery +="QDG.QDG_FILIAL='"+TMPQDJ->QDJ_FILIAL+"' AND "
	cQuery +="QDG.QDG_DOCTO='"+TMPQDJ->QDJ_DOCTO+"' AND "
	cQuery +="QDG.QDG_RV='"+TMPQDJ->QDJ_RV+"' AND "
	cQuery +="QDG.QDG_TIPO='"+TMPQDJ->QDJ_TIPO+"' AND "
	cQuery +="QDG.QDG_FILMAT='"+TMPQDJ->QDJ_FILMAT+"' AND "
	cQuery +="QDG.QDG_DEPTO='"+TMPQDJ->QDJ_DEPTO+"' AND "
	cQuery +="QDG.QDG_SIT <> 'I' AND "
	cQuery +="QDG.D_E_L_E_T_ <> '*' AND "
	cQuery +="QAA.QAA_FILIAL = QDG.QDG_FILMAT AND " 
	cQuery +="QAA.QAA_MAT = QDG.QDG_MAT AND "

	If TMPQDJ->QDJ_TIPO == "D"
		cQuery +="QAA.QAA_CC = QDG.QDG_DEPTO AND "
	EndIf

	If lTrat
		cQuery +="QAA.QAA_TPRCBT <> '4' AND "			
	Endif
	cQuery +="QAA.D_E_L_E_T_ <> '*' "

	If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
		cQuery += " ORDER BY 1,2,3,4,5,8,7"
	Else
		cQuery += " ORDER BY " + SqlOrder("QDG_FILIAL+QDG_DOCTO+QDG_RV+QDG_TIPO+QDG_FILMAT+QDG_DEPTO+QDG_MAT+QDG_CODMAN")
	Endif

	cQuery := ChangeQuery(cQuery)			
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQDG",.T.,.T.)
	DbGotop()  
	IF TMPQDG->(!EOF())
		While TMPQDG->(!EOF())
	
			Aadd(aQDGDoc,{TMPQDG->QDG_FILIAL,TMPQDG->QDG_DOCTO,TMPQDG->QDG_RV,TMPQDG->QDG_FILMAT,TMPQDG->QDG_DEPTO,TMPQDG->QDG_MAT,TMPQDG->QDG_NCOP,;
			TMPQDG->QDG_TPRCBT,TMPQDG->QDG_RECEB,TMPQDG->QDG_TIPO,TMPQDG->QDG_CODMAN,iif (Posicione("QAA",1,xFilial("QAA")+TMPQDG->QDG_MAT,"QAA_STATUS")=='2','I',' ')  ,TMPQDG->QAA_NOME,If(TMPQDG->QDG_TIPO=="P" ,QDXFNANMAN(TMPQDG->QDG_CODMAN,.T.,If(FWModeAccess("QDC")=="E",TMPQDG->QDG_FILMAT,)),""),TMPQDG->QAA_CODFUN})

			TMPQDG->(DbSkip())
		Enddo
        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega possiveis usuarios novos 				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TMPQDJ->QDJ_TIPO == "D"
			
			cQuery :="SELECT QAA.QAA_FILIAL,QAA.QAA_CC,QAA.QAA_MAT,QAA.QAA_TPRCBT,QAA.QAA_NOME,QAA.QAA_CODFUN "
			cQuery +="FROM " + RetSqlName("QAA")+" QAA "
			cQuery +="WHERE "                             
			cQuery +="QAA.QAA_FILIAL='"+TMPQDJ->QDJ_FILMAT+"' AND "
			cQuery +="QAA.QAA_CC='"+TMPQDJ->QDJ_DEPTO+"' AND "
			cQuery +="QAA.QAA_TPRCBT <> '4' AND "         				
			cQuery += QA_FilSitF(.T.,.T.) + " AND "
			cQuery +=" QAA.D_E_L_E_T_ <> '*' AND " 
							
			cQuery +="(NOT EXISTS (SELECT R_E_C_N_O_ "
			cQuery +="FROM " + RetSqlName("QDG")+" QDG " 		
			cQuery +="WHERE "
			cQuery +="QDG.QDG_FILIAL='"+TMPQDJ->QDJ_FILIAL+"' AND "
			cQuery +="QDG.QDG_DOCTO='"+TMPQDJ->QDJ_DOCTO+"' AND "
			cQuery +="QDG.QDG_RV='"+TMPQDJ->QDJ_RV+"' AND "
			cQuery +="QDG.QDG_TIPO='"+TMPQDJ->QDJ_TIPO+"' AND "
			cQuery +="QDG.QDG_SIT <> 'I' AND "
			cQuery +="QDG.D_E_L_E_T_ <> '*' AND " 
			cQuery +="QAA.QAA_FILIAL=QDG.QDG_FILMAT AND "
			cQuery +="QAA.QAA_MAT=QDG.QDG_MAT AND "				
			cQuery +="QAA.QAA_CC=QDG.QDG_DEPTO ))"	

			If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
				cQuery += " ORDER BY 1,2,3"
			Else
				cQuery += " ORDER BY " + SqlOrder("QAA_FILIAL+QAA_CC+QAA_MAT")
			Endif
		
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQAA",.T.,.T.)

			DbGotop()
			While TMPQAA->(!Eof())
				Aadd( aQDGDoc,{TMPQDJ->QDJ_FILIAL,TMPQDJ->QDJ_DOCTO,TMPQDJ->QDJ_RV,TMPQAA->QAA_FILIAL,TMPQAA->QAA_CC,TMPQAA->QAA_MAT,1,TMPQAA->QAA_TPRCBT,"N","D"," ",iif (Posicione("QAA",1,xFilial("QAA")+TMPQAA->QAA_MAT,"QAA_STATUS")=='2','I',' '),TMPQAA->QAA_NOME," ",TMPQAA->QAA_CODFUN})
				TMPQAA->(DbSkip())
			EndDo
			TMPQAA->(DbCLOSEAREA())
		Endif
	Else
		If TMPQDJ->QDJ_TIPO == "D"
			cQuery :="SELECT QAA.QAA_FILIAL,QAA.QAA_CC,QAA.QAA_MAT,QAA.QAA_TPRCBT,QAA.QAA_NOME, QAA.QAA_CODFUN "
			cQuery +="FROM " + RetSqlName("QAA")+" QAA "
			cQuery +="WHERE "
			cQuery +="QAA.QAA_FILIAL='"+TMPQDJ->QDJ_FILMAT +"' AND "
			cQuery +="QAA.QAA_CC='"+TMPQDJ->QDJ_DEPTO+"' AND "
			cQuery +="QAA.QAA_TPRCBT <> '4' AND "
			cQuery += QA_FilSitF(.T.,.T.)+" AND "
			cQuery +="QAA.D_E_L_E_T_ <> '*' "
		
			If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
				cQuery += " ORDER BY 1,2,3"
			Else
				cQuery += " ORDER BY " + SqlOrder("QAA_FILIAL+QAA_CC+QAA_MAT")
			Endif
		
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQAA",.T.,.T.)
		
			DbGotop()
			While TMPQAA->(!Eof())
				Aadd( aQDGDoc,{TMPQDJ->QDJ_FILIAL,TMPQDJ->QDJ_DOCTO,TMPQDJ->QDJ_RV,TMPQAA->QAA_FILIAL,TMPQAA->QAA_CC,TMPQAA->QAA_MAT,1,TMPQAA->QAA_TPRCBT,"N","D"," ",iif (Posicione("QAA",1,xFilial("QAA")+TMPQAA->QAA_MAT,"QAA_STATUS")=='2','I',' '),TMPQAA->QAA_NOME," ",TMPQAA->QAA_CODFUN})
				TMPQAA->(DbSkip())
			EndDo
			TMPQAA->(DbCLOSEAREA())
		Endif
	Endif
    TMPQDG->(DBCLOSEAREA())

	IF TMPQDJ->QDJ_TIPO == "P"
		cFilQDC:= xFilial("QDC")
		If FWModeAccess("QDC")== "E" //!Empty(cFilQDC)
			cFilQDC:= TMPQDJ->QDJ_FILMAT
		EndIf
	
		cQuery :="SELECT QDC.QDC_FILIAL,QDC.QDC_CODMAN,QDC.QDC_CODASS,QDC.QDC_CODTP,QDC.QDC_DESC "
		cQuery +="  FROM " + RetSqlName("QDC")+" QDC "
		cQuery +=" WHERE "
		cQuery +="QDC.QDC_FILIAL='"+cFilQDC +"' AND "
		cQuery +="QDC.D_E_L_E_T_ <> '*' "
	
		If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
			cQuery += " ORDER BY 1,2"
		Else
			cQuery += " ORDER BY " + SqlOrder("QDC_FILIAL+QDC_CODMAN")
		Endif
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQDC",.T.,.T.)
	
		While TMPQDC->(!Eof())
			If !Empty(TMPQDC->QDC_CODASS) //Assunto
				If M->QDH_CODASS <> TMPQDC->QDC_CODASS 
					TMPQDC->(DbSkip())
					Loop
				EndIf
			EndIf
		
			If !Empty(TMPQDC->QDC_CODTP) //Tipo Docto
				If M->QDH_CODTP <> TMPQDC->QDC_CODTP
					TMPQDC->(DbSkip())
					Loop
				EndIf
			EndIf
		
			If FWModeAccess("QAD")=="E" //!Empty(xFilial("QAD")
				cFilDep:= TMPQDJ->QDJ_FILMAT
			EndIf
			cMatFil:= TMPQDJ->QDJ_FILMAT
			cMatQAD:= Space(TamSx3("QAD_MAT")[1])
			cNomUsr:= Space(30)
			If QAD->(DBSeek(cFilDep+TMPQDJ->QDJ_DEPTO))
				cMatFil:= QAD->QAD_FILMAT
				cMatQAD:= QAD->QAD_MAT
				cNomUsr:= QA_NUSR(cMatFil,cMatQAD,.T.)
			EndIf
			If QDT->(DbSeek(cFilDep+TMPQDJ->QDJ_DEPTO+TMPQDC->QDC_FILIAL+TMPQDC->QDC_CODMAN))
				lDepx:= .T.
			ELse
				lDepx:= .F.
			EndIf
			If lDepx
				If aScan(aQDGDoc,{|x| x[4] + x[5] + x[11] == TMPQDJ->QDJ_FILMAT + TMPQDJ->QDJ_DEPTO + TMPQDC->QDC_CODMAN } ) == 0
					Aadd(aQDGDoc,{TMPQDJ->QDJ_FILIAL,TMPQDJ->QDJ_DOCTO,TMPQDJ->QDJ_RV,cMatFil,TMPQDJ->QDJ_DEPTO,cMatQAD,1,"2","N","P",TMPQDC->QDC_CODMAN," ",cNomUsr,TMPQDC->QDC_DESC," "})
				EndIf
			EndIf
			TMPQDC->(DbSkip())
		EndDo
		TMPQDC->(DBCLOSEAREA())		
	Endif
	
	If TMPQDJ->QDJ_TIPO == "D"
		aQDGDoc:= aSort( aQDGDoc,,,{ |x,y| x[13] + x[6]+ x[14] + x[11] < y[13] + y[6] + y[14] + y[11] } )
	Else
		aQDGDoc:= aSort( aQDGDoc,,,{ |x,y| x[11] < y[11] } )
	EndIf

Return aQDGDoc


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD050GRFL  ³ Autor ³ Telso Carneiro             ³ Data ³ 07/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Grava as tabelas fichas da tabela QDH(QD0,QD6,QDB,QDZ,QD4,QDV)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD050GRFL(aArq,nOpc)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array cotendo as tabelas a serem gravadas                 ³±±
±±³           ³ ExpN1 - Numerico contendo a opcao do cadastro                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA050                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function QD050GRFL(aArq,nOpc)

Local i		:=0 
Local y		:=0
Local nPos1	:=0
Local nPos2	:=0
Local nPos3	:=0
Local nPos4	:=0
Local nPos5	:=0                      
Local nCont	:=0
Local nY    :=0   
Local lGraQDZ:=.F.
Local lQadComp	:= FWModeAccess("QAD")=="C" //Empty(xFilial("QAD")) //QAD - Compartilhado
Local cQuery	:= ""       
Local aArea		:= GetArea() 

Private aHeader := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ARRAY de AHEADERS ³
//³aHedDoc[1] = QD0  ³
//³aHedDoc[2] = QD6  ³
//³aHedDoc[3] = QDB  ³
//³aHedDoc[4] = QDZ  ³
//³aHedDoc[5] = QD4  ³
//³aHedDoc[6] = QDV  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	For i:=1 To Len(aArq)
		DO CASE
		CASE aArq[i]=="QD0" .AND. !Empty(aQD0DOC) .AND. !EMPTY(aQD0DOC[1,1]) .AND. lAltDoc
		aHeader:= aHedDoc[1]
		aCols  := aClone(aQD0Doc)
		nPos1  := GdFieldPos("QD0_AUT"   ,aHeader)
		nPos2  := GdFieldPos("QD0_ORDEM" ,aHeader)
		nPos3  := GdFieldPos("QD0_FILMAT",aHeader)
		nPos4  := GdFieldPos("QD0_MAT"   ,aHeader)
		nPos5  := GdFieldPos("QD0_DEPTO" ,aHeader)
		
		QD0->(DbSetOrder(1))
			If QD0->(DbSeek( M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV ))
				While QD0->(!Eof()) .And.  QD0->(QD0_FILIAL+QD0_DOCTO+QD0_RV)==M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
					If ( QD0->QD0_FLAG == "T" .And. M->QDH_STATUS == "L  " ) .Or. ;
					( QD0->QD0_FLAG == "I" .And. M->QDH_STATUS <> "L  " ) .Or. ;
					(!Empty(QD0->QD0_ANO) .And. !Empty(QD0->QD0_NUMERO)) // Verifica se eh responsavel por ausencia temporaria
					QD0->(DbSkip())
					Loop
						EndIf
				RecLock("QD0",.F.)
				QD0->(DbDelete())
				QD0->(MsUnLock())
				FKCOMMIT()
				QD0->(DbSkip())
				Enddo
			EndIf
		
			For Y:=1 TO Len(aQD0DOC)
				IF aQD0DOC[Y,len(aQD0DOC[Y])]==.F.
					If !QD0->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+aQD0DOC[Y,nPos1]+;
					aQD0DOC[Y,nPos2]+aQD0DOC[Y,nPos3]+aQD0DOC[Y,nPos4]))
					RecLock( "QD0",.T.)
					QD0->QD0_FILIAL := M->QDH_FILIAL
					QD0->QD0_DOCTO  := M->QDH_DOCTO
					QD0->QD0_RV     := M->QDH_RV
					QA_GRAVCPS( Y )
					MsUnLock()
					FKCOMMIT()
						EndIf
				Endif
			Next
		CASE aArq[i]=="QD6"  .AND. lAltDoc
		aHeader:= aHedDoc[2]
		aCols  := aClone(aQD6Doc)
		nPos1  := GdFieldPos("QD6_CHAVE",aHeader)
		
			If QD6->(DbSeek( M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV ))
				While QD6->(!Eof()) .And.  QD6->QD6_FILIAL+QD6->QD6_DOCTO+QD6->QD6_RV==M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
				RecLock("QD6",.F.)
				QD6->(DbDelete())
				QD6->(MsUnLock())
				FKCOMMIT()
				QD6->(DbSkip())
				Enddo
			Endif
			For Y:=1 TO Len(aQD6DOC)
				IF aQD6DOC[Y,len(aQD6DOC[Y])]==.F. .AND. !EMPTY(aQD6DOC[Y,nPos1])
					If !QD6->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+aQD6DOC[Y,nPos1]))
					RecLock( "QD6",.T.)
					QD6->QD6_FILIAL := M->QDH_FILIAL
					QD6->QD6_DOCTO  := M->QDH_DOCTO
					QD6->QD6_RV     := M->QDH_RV
					QA_GRAVCPS( Y )
					MsUnLock()
					FKCOMMIT()
					EndIf
				Endif
			Next
		CASE aArq[i]=="QDB" .And. !EMPTY(aQDBDOC[1,1]) .AND. lAltDoc
		aHeader:= aHedDoc[3]
		aCols  := aClone(aQDBDoc)
		nPos1  := GdFieldPos("QDB_SEQ"   ,aHeader)
		nCont  := 0		
		
			If QDB->(DbSeek( M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV ))
				While QDB->(!Eof()) .And.  QDB->(QDB_FILIAL+QDB_DOCTO+QDB_RV)==M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
				RecLock("QDB",.F.)
				QDB->(DbDelete())
				QDB->(MsUnLock())
				FKCOMMIT()
				QDB->(DbSkip())
				Enddo
			Endif

			For Y:=1 TO Len(aQDBDOC)
				IF aQDBDOC[Y,len(aQDBDOC[Y])]==.F.
								
		 		aCols[Y,nPos1]:=STRZERO(++nCont,4) //Recria os Codigos Sequencia

				RecLock( "QDB",.T.)
				QDB->QDB_FILIAL := M->QDH_FILIAL
				QDB->QDB_DOCTO  := M->QDH_DOCTO
				QDB->QDB_RV     := M->QDH_RV
				QA_GRAVCPS( Y )
				MsUnLock()
				FKCOMMIT()

				Endif
			Next
		CASE aArq[i]=="QDZ" .AND. lAltDoc
		aHeader:= aHedDoc[4]
		aCols  := aClone(aQDZDoc)
			If QDZ->(DbSeek( M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV ))
				While QDZ->(!Eof()) .And.  QDZ->QDZ_FILIAL+QDZ->QDZ_DOCTO+QDZ->QDZ_RV==M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
				RecLock("QDZ",.F.)
				QDZ->(DbDelete())
				QDZ->(MsUnLock())
				FKCOMMIT()
				QDZ->(DbSkip())
				Enddo
			Endif
		nPos1  := GdFieldPos("QDZ_DEPTO" ,aHeader)
		nPos2  := GdFieldPos("QDZ_MAT"   ,aHeader)
		nPos3  := GdFieldPos("QDZ_FILMAT",aHeader)
		lGraQDZ:= .F.
		
			For Y:=1 TO Len(aQDZDOC)
				IF aQDZDOC[Y,len(aQDZDOC[Y])]==.F. .AND. !EMPTY(aQDZDOC[Y,nPos2])
					If !QDZ->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+aQDZDOC[Y,nPos1]+aQDZDOC[Y,nPos2]+aQDZDOC[Y,nPos3]))
					RecLock( "QDZ",.T.)
					QDZ->QDZ_FILIAL := QDH->QDH_FILIAL
					QDZ->QDZ_DOCTO  := QDH->QDH_DOCTO
					QDZ->QDZ_RV     := QDH->QDH_RV
					QA_GRAVCPS( Y )
					MsUnLock()
					FKCOMMIT()                       
					lGraQDZ:=.T.
					EndIf
				Endif
			Next
			IF !lGraQDZ
				If lQadComp //QAD - Compartilhado
	
				cQuery :="SELECT DISTINCT QAA.QAA_MAT,QAA.QAA_CC,QAA.QAA_FILIAL "
				cQuery +="FROM " + RetSqlName("QAA")+" QAA "
				cQuery +="WHERE "                             
				cQuery +="QAA.QAA_CC='"+QDH->QDH_DEPTOD+"' AND "
				cQuery +="QAA.QAA_DISTSN = '1' AND "         				
				cQuery += QA_FilSitF(.T.,.T.) + " AND "
				cQuery +=" QAA.D_E_L_E_T_ <> '*' " 

					If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
					cQuery += " ORDER BY 1"
					Else
					cQuery += " ORDER BY " + SqlOrder("QAA_FILIAL")
					Endif
				
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQAA",.T.,.T.)

				DbGotop()
					While TMPQAA->(!Eof())
						If !QDZ->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+TMPQAA->QAA_CC+TMPQAA->QAA_MAT+TMPQAA->QAA_FILIAL))
						RecLock( "QDZ",.T.)
						QDZ->QDZ_FILIAL := QDH->QDH_FILIAL
						QDZ->QDZ_DOCTO  := QDH->QDH_DOCTO
						QDZ->QDZ_RV     := QDH->QDH_RV
						QDZ->QDZ_FILMAT := TMPQAA->QAA_FILIAL
						QDZ->QDZ_DEPTO  := TMPQAA->QAA_CC
						QDZ->QDZ_MAT	:= TMPQAA->QAA_MAT
						QDZ->QDZ_DIGITA	:= "2"
						MsUnLock()
						FKCOMMIT()				
						Endif
     					TMPQAA->(DbSkip())                         
					Enddo
				TMPQAA->(DbCLOSEAREA())										
				RestARea(aArea)
                         
				Else
				QAA->(DbSetOrder(2))
					IF QAA->(DBSEEK(QDH->QDH_FILDEP+QDH->QDH_DEPTOD))
						While QAA->(!Eof()) .And. QAA->QAA_FILIAL+QAA->QAA_CC == QDH->QDH_FILDEP+QDH->QDH_DEPTOD
							If QA_SitFolh() .And. QAA->QAA_DISTSN == "1"
								If !QDZ->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+QAA->QAA_CC+QAA->QAA_MAT+QAA->QAA_FILIAL))
								RecLock( "QDZ",.T.)
								QDZ->QDZ_FILIAL := QDH->QDH_FILIAL
								QDZ->QDZ_DOCTO  := QDH->QDH_DOCTO
								QDZ->QDZ_RV     := QDH->QDH_RV
								QDZ->QDZ_FILMAT := QAA->QAA_FILIAL
								QDZ->QDZ_DEPTO  := QAA->QAA_CC
								QDZ->QDZ_MAT	:= QAA->QAA_MAT
								QDZ->QDZ_DIGITA	:= "2"
								MsUnLock()
								FKCOMMIT()
								Endif
							EndIf
						QAA->(DbSkip())
						Enddo
					Endif
				Endif
			Endif
		CASE aArq[i]=="QD4"	.And. !EMPTY(aQD4DOC[1,1])
		QD051Grav(aQD4DOC)
		CASE aArq[i]=="QDV" .And. !EMPTY(aQDVDOC[1,1])
		aHeader:= aHedDoc[6]
		aCols  := aClone(aQDVDoc)
		
			For nY:=1 TO Len(aQDVDOC)
				If QDV->(DbSeek( M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + aQDVDOC[nY,1]))
					IF aQDVDOC[nY,len(aQDVDOC[nY])]==.T.
					RecLock("QDV",.F.)
					QDV->(DbDelete())
					QDV->(MsUnLock())
					FKCOMMIT()
					EndIf
				Else
					IF aQDVDOC[nY,len(aQDVDOC[nY])]==.F.
						RecLock( "QDV",.T.)
						QDV->QDV_FILIAL := M->QDH_FILIAL
						QDV->QDV_DOCTO  := M->QDH_DOCTO
						QDV->QDV_RV     := M->QDH_RV
						QDV->QDV_NORMA  := aQDVDOC[nY,1]
						MsUnLock()
						FKCOMMIT()	
					EndIf
				EndIF
			Next nY

		ENDCASE
	Next
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD050GRFL1 ³ Autor ³ Aldo Marini Junior         ³ Data ³ 10/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Grava as tabelas fichas da tabela QDH(QDJ,QDG)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD050GRFL1(nOpc)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpN1 - Numerico contendo a opcao do cadastro                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA050                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050GRFL1(nOpc)

Local n1	:=0 
Local n2	:=0

dbSelectArea("QDG")
dbSetOrder(1)
	If DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV)
		While !Eof() .And. QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
		RecLock("QDG",.F.)
		DbDelete()
		MsUnLock()
		FKCOMMIT()
		dbSkip()
		Enddo
	Endif

dbSelectArea("QDJ")
dbSetOrder(1)
	If DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV)
		While !Eof() .And. QDJ->QDJ_FILIAL+QDJ->QDJ_DOCTO+QDJ->QDJ_RV == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
		dbSelectArea("QDJ")
		RecLock("QDJ",.F.)
		DbDelete()
		MsUnLock()
		FKCOMMIT()
		dbSkip()
		Enddo
	Endif
	
//Array aQDJDoc
//1 - QDJ->QDJ_FILIAL
//2 - QDJ->QDJ_DOCTO
//3 - QDJ->QDJ_RV
//4 - QDJ->QDJ_FILMAT
//5 - QDJ->QDJ_DEPTO
//6 - QDJ->QDJ_TIPO,

//Array aQDJDoc[9]
// 1 - QDG->QDG_FILIAL
// 2 - QDG->QDG_DOCTO
// 3 - QDG->QDG_RV
// 4 - QDG->QDG_FILMAT
// 5 - QDG->QDG_DEPTO
// 6 - QDG->QDG_MAT
// 7 - QDG->QDG_NCOP,
// 8 - QDG->QDG_TPRCBT
// 9 - QDG->QDG_RECEB
//10 - QDG->QDG_TIPO
//11 - QDG->QDG_CODMAN
//12 - QDG->QDG_SIT,

	For n1:=1 TO Len(aQDJDoc)
		If !QDJ->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+aQDJDoc[n1,6]+aQDJDoc[n1,4]+aQDJDoc[n1,5]))
			RecLock("QDJ",.T.)
				QDJ->QDJ_FILIAL := M->QDH_FILIAL
				QDJ->QDJ_DOCTO  := M->QDH_DOCTO
				QDJ->QDJ_RV     := M->QDH_RV
				QDJ->QDJ_FILMAT := aQDJDoc[n1,4]
				QDJ->QDJ_DEPTO  := aQDJDoc[n1,5]
				QDJ->QDJ_TIPO   := aQDJDoc[n1,6]
			MsUnLock()
			FKCOMMIT()

			For n2:=1 TO Len(aQDJDoc[n1,9])
				If aQDJDoc[n1,9,n2,9] = "S" .Or. aQDJDoc[n1,9,n2,12] == "I" // Recebe Docto ou Usuario Inativo
					If !QDG->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+aQDJDoc[n1,9,n2,10]+aQDJDoc[n1,9,n2,4]+aQDJDoc[n1,9,n2,5]+aQDJDoc[n1,9,n2,6]+aQDJDoc[n1,9,n2,11]))
						RecLock("QDG",.T.)
							QDG->QDG_FILIAL := M->QDH_FILIAL
							QDG->QDG_DOCTO  := M->QDH_DOCTO
							QDG->QDG_RV     := M->QDH_RV
							QDG->QDG_FILMAT := aQDJDoc[n1,9,n2,4]
							QDG->QDG_DEPTO  := aQDJDoc[n1,9,n2,5]
							QDG->QDG_MAT    := aQDJDoc[n1,9,n2,6]
							QDG->QDG_NCOP   := aQDJDoc[n1,9,n2,7]
							QDG->QDG_TPRCBT := aQDJDoc[n1,9,n2,8]
							QDG->QDG_RECEB  := aQDJDoc[n1,9,n2,9]
							QDG->QDG_TIPO   := aQDJDoc[n1,9,n2,10]
							QDG->QDG_CODMAN := aQDJDoc[n1,9,n2,11]
							QDG->QDG_SIT    := aQDJDoc[n1,9,n2,12]						
						MsUnLock()
						FKCOMMIT()
					EndIf
				Endif
			Next
		EndIf
	Next

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDO050CQDDºAutor  ³Telso Carneiro      º Data ³  19/05/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡…o ³ Programa para Atualizacao dos arrays dos cadastros QD0	  º±±
±±º          ³ Responsaveis do QDD (RESPONSAVEIS POR TIPO DOCTO)          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QDO050CQDD()
	Local oResponsaveis := QDO050CQDDClass():New(aQD0DOC)
	aQD0DOC := oResponsaveis:RecarregaArraysResponsaveis()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QD050RefDcºAutor  ³Telso Carneiro      º Data ³  21/05/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida os Documentos Referenciados                         º±±
±±º          ³                       									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ x3_valid QDB_DOCREF e QD050LinOk                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QD050RefDc(N,cDocRef, lOK)
	Local lRet:=.F.
	Local aColsAux	:= AClone(aCols)
	Local nPosOrig	:= GdFieldPos( "QDB_ORIGEM" ,aHedDoc[3])
	Local nPosDRef	:= GdFieldPos( "QDB_DOCREF" ,aHedDoc[3])
	Local nPosRev 	:= GdFieldPos( "QDB_REVIS"  ,aHedDoc[3])
	Local nValRefDoc	:= GetMV("MV_QREFDC",.F.,1)
	Local cIndQDH 	:= QDH->(IndexOrd())

	Default cDocRef := M->QDB_DOCREF
	Default lOK := .F.

	If nValRefDoc == 2
		Return .T.
	Endif

	IF !aColsAux[N,Len(aColsAux[N])]
		IF aColsAux[N,nPosOrig]	== "I"
			QDH->(DbSetOrder(6)) //Revisao invertida
			IF QDH->(DBSEEK(M->QDH_FILIAL+cDocRef))
				While !QDH->(EOF()) .AND. QDH->QDH_FILIAL+QDH->QDH_DOCTO == M->QDH_FILIAL+cDocRef
					IF QDH->QDH_CANCEL<>"S" .AND. QDH->QDH_OBSOL<>"S" .AND. QDH->QDH_STATUS=="L  "
						lRet:=.T.
						Exit
					Endif
					QDH->(DbSKIP())
				Enddo
			Else
				Help(" ",1,"QDO50DND") // "Documento nao foi criado."
			Endif 
			QDH->(DbSetOrder(cIndQDH))
		ElseIF aColsAux[N,nPosOrig]	== "E"
			lRet := .T.
			If !lOK .AND. !Empty(Alltrim(cDocRef))// So mostro se nao vier do TudoOK ou do LinOk
				MsgAlert(OemToAnsi(STR0167),OemToAnsi(STR0026))// "Este campo não deve ser preenchido cado o docuemnto seja externo"###"Aviso"
			EndIf     
			aCols[N,nPosDRef] := Space(TamSx3("QDB_DOCREF")[1]) // Este campo não deve ser preenchido cado o docuemnto seja externo
			aCols[N,nPosRev]  := "N" // Não gera revisão
			M->QDB_DOCREF := ""
			M->QDB_REVIS  := "N"
		Endif
	Endif

	IF !lRet
		Help(" ",1,"QDNEDOCTO") // "Não existe nenhum documento disponivel."
	Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDOA050   ºAutor  ³Denis Martins       º Data ³  11/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada utilizado nos botoes Finalizar / Deixar penº±±
±±º          ³dente os documentos                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDOA050                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QD050PENOK(lPen,nOpcao,nOpc)

	If ExistBlock("QD050PNK")
		ExecBlock("QD050PNK", .f., .f., {lPen,nOpcao,nOpc})
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QD50AJQD0 ºAutor  ³Telso Carneiro      º Data ³  07/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Manipulacao do Flag de transferencia dos responsaveis       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDOA050                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QD50AJQD0(cFilDoc,cCodDoc,cRvDoc)
	Local aAreaQAA  := QAA->(GetArea())
	Local lFlag		:= " "
	Local ljaTrans  := .F.
	Local aCtrlQD0	:= {}
	Local nI		:= 0
	Local nContE	:= 0
	Local nContR	:= 0
	Local nContA	:= 0
	Local nContH	:= 0
	Local nPos		:= 0

	QAE->(DbSetOrder(1))
	QAA->(DbSetOrder(2))
	QD0->(DbSetOrder(1))
	If QD0->(Dbseek(cFilDoc+cCodDoc+cRvDoc))
		While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV == cFilDoc + cCodDoc + cRvDoc
			Aadd(aCtrlQD0,{QD0->QD0_FILIAL,QD0->QD0_DOCTO,QD0->QD0_RV,QD0->QD0_AUT,QD0->QD0_ORDEM,;
				QD0->QD0_FILMAT,QD0->QD0_MAT,QD0->QD0_FLAG,QD0->(Recno())} )
			IF QD0->QD0_FLAG=="T"
				IF !EMPTY(QD0->QD0_ANO) .AND. !EMPTY(QD0->QD0_NUMERO)
					lFlag:="T"
					IF QAE->(DbSeek(xFilial("QAE")+QD0->QD0_ANO+QD0->QD0_NUMERO))
						IF QAE->QAE_STATUS == "2"
							IF !QAF->(DbSeek(xFilial("QAF")+QD0->QD0_ANO+QD0->QD0_NUMERO+QD0->QD0_AUT+"  "+QD0->QD0_FILMAT+QD0->QD0_MAT))
								lFlag:=" "
							Endif
						Endif
					Endif
				Else
					IF QAA->(DbSeek(QD0->QD0_FILMAT+QD0->QD0_DEPTO+QD0->QD0_MAT))
						IF QA_SitFolh()
							QDR->(DbSetOrder(3)) //PARA
							IF QDR->(DbSeek(QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV+QD0->QD0_FILMAT+QD0->QD0_MAT+QD0->QD0_DEPTO))
								ljaTrans:=.F.
								While QDR->(!EOF()) .AND. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV+QD0->QD0_FILMAT+QD0->QD0_MAT+QD0->QD0_DEPTO==;
										QDR->QDR_FILIAL+QDR->QDR_DOCTO+QDR->QDR_RV+QDR->QDR_FILPAR+QDR->QDR_MATPAR+QDR->QDR_DEPPAR
									IF QD0->QD0_AUT==Alltrim(QDR->QDR_TPPEND) .AND. QD0->QD0_FILMAT+QD0->QD0_MAT+QD0->QD0_DEPTO!=QDR->QDR_FILDE+QDR->QDR_MATDE+QDR->QDR_DEPDE
										ljaTrans:=.T.
									Endif
									QDR->(DbSkip())
								Enddo
								IF ljaTrans
									lFlag:="T"
								Else
									lFlag:=" "
								Endif
							Endif
						Else
							lFlag:="I"
						Endif
					Else
						lFlag:="I"
					Endif
				Endif
				RecLock("QD0",.F.)
				QD0->QD0_FLAG:=lFlag
				MsUnlock()
				FKCOMMIT()

			ELSEIF QD0->QD0_FLAG=="I"
				IF !EMPTY(QD0->QD0_ANO) .AND. !EMPTY(QD0->QD0_NUMERO)
					lFlag:="I"
					IF QAE->(DbSeek(xFilial("QAE")+QD0->QD0_ANO+QD0->QD0_NUMERO))
						IF QAE->QAE_STATUS == "2"
							IF !QAF->(DbSeek(xFilial("QAF")+QD0->QD0_ANO+QD0->QD0_NUMERO+QD0->QD0_AUT+"  "+QD0->QD0_FILMAT+QD0->QD0_MAT))
								lFlag:=" "
							Endif
						Endif
					Endif
				Else
					IF QAA->(DbSeek(QD0->QD0_FILMAT+QD0->QD0_DEPTO+QD0->QD0_MAT))
						IF QA_SitFolh()
							QDR->(DbSetOrder(2)) //DE
							IF QDR->(DbSeek(QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV+QD0->QD0_FILMAT+QD0->QD0_MAT+QD0->QD0_DEPTO))
								ljaTrans:=.F.
								While QDR->(!EOF()) .AND. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV+QD0->QD0_FILMAT+QD0->QD0_MAT+QD0->QD0_DEPTO==;
										QDR->QDR_FILIAL+QDR->QDR_DOCTO+QDR->QDR_RV+QDR->QDR_FILDE+QDR->QDR_MATDE+QDR->QDR_DEPDE
									IF QD0->QD0_AUT==Alltrim(QDR->QDR_TPPEND) .AND. QD0->QD0_FILMAT+QD0->QD0_MAT+QD0->QD0_DEPTO!=QDR->QDR_FILPAR+QDR->QDR_MATPAR+QDR->QDR_DEPPAR
										ljaTrans:=.T.
									Endif
									QDR->(DbSkip())
								Enddo
								IF ljaTrans
									lFlag:="I"
								Else
									lFlag:=" "
								Endif
							Endif
						Else
							lFlag:="I"
						Endif
					Else
						lFlag:="I"
					Endif
				Endif
				RecLock("QD0",.F.)
				QD0->QD0_FLAG:=lFlag
				MsUnlock()
				FKCOMMIT()
			ENDIF
			QD0->(DbSkip())
		EndDo
	Endif

//Aadd(aCtrlQD0,{QD0->QD0_FILIAL,QD0->QD0_DOCTO,QD0->QD0_RV,QD0->QD0_AUT,QD0->QD0_ORDEM,;
//	QD0->QD0_FILMAT,QD0->QD0_MAT,QD0->QD0_FLAG,QD0->(Recno())} )

	nContE:=0
	aEval(aCtrlQD0,{|x| If(x[4]=="E",nContE++,"")})
	IF nContE == 1
		nPos:=Ascan(aCtrlQD0,{|x| x[4]=="E"})
		IF !Empty(aCtrlQD0[nPos,8])
			QD0->(DbGoto(aCtrlQD0[nPos,9]))
			RecLock("QD0",.F.)
			QD0->QD0_FLAG:=" "
			MsUnlock()
			FKCOMMIT()
		Endif
	Endif
	nContR:=0
	aEval(aCtrlQD0,{|x| IF(x[4]=="R",nContR++,"")})
	IF nContR == 1
		nPos:=Ascan(aCtrlQD0,{|x| x[4]=="R"})
		IF !Empty(aCtrlQD0[nPos,8])
			QD0->(DbGoto(aCtrlQD0[nPos,9]))
			RecLock("QD0",.F.)
			QD0->QD0_FLAG:=" "
			MsUnlock()
			FKCOMMIT()
		Endif
	Endif
	nContA:=0
	aEval(aCtrlQD0,{|x| IF(x[4]=="A",nContA++,"")})
	IF nContA == 1
		nPos:=Ascan(aCtrlQD0,{|x| x[4]=="A"})
		IF !Empty(aCtrlQD0[nPos,8])
			QD0->(DbGoto(aCtrlQD0[nPos,9]))
			RecLock("QD0",.F.)
			QD0->QD0_FLAG:=" "
			MsUnlock()
			FKCOMMIT()
		Endif
	Endif
	nContH:=0
	aEval(aCtrlQD0,{|x| IF(x[4]=="H",nContH++,"")})
	IF nContH == 1
		nPos:=Ascan(aCtrlQD0,{|x| x[4]=="H"})
		IF !Empty(aCtrlQD0[nPos,8])
			QD0->(DbGoto(aCtrlQD0[nPos,9]))
			RecLock("QD0",.F.)
			QD0->QD0_FLAG:=" "
			MsUnlock()
			FKCOMMIT()
		Endif
	Endif

	QAA->(RestArea(aAreaQAA))

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDOA050   ºAutor  ³Cicero Cruz         º Data ³  04/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se os acessos ao diretório de documentos está ok.    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Controle de Documentos                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QD50VDOCT(cQPath, cQPathTrm, cDocto)
	Local lRet := .T.

// Verifico o acesso ao diretório.
	If File( cQPath+"9999999.DOC" ) // Limpo o lixo caso haja
		fErase( cQPath+"9999999.DOC"  )
	EndIf
	nHandle := fCreate(cQPath + "9999999.DOC")//Tenta Criar arquivo teste para ver se diretorio existe
	If nHandle <> -1  // Consegui criar arquivo no diretorio do server
		fClose(nHandle)
		fErase(cQPath+"9999999.DOC" )
		If !File( cQPath + cDocto )
			If !File( cQPathTrm + cDocto )
				lRet := .F.
			Endif
		Endif
	Else
		// Mensagem de acesso
		Help(" ",1,"QACEQPATH")
	Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QD050VLDIE   ºAutor  ³Iolanda Vilanova º Data ³  06/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação do campo QDH_DTOIE                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Controle de Documentos                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßß
*/
Function Qd050VldIE

	Local lret :=.T.
	lWhenIE:=.F.

Return lret

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCALDOCTO   ºAutor  ³Sandra Ribeiro   º Data ³  19/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gatilho do campo QDB_DOCTO (Documento Referenciado)         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Controle de Documentos                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßß
*/
Function LocalDocto(cCodDoc)

	Local cTitulo := " "
	Local cRevDoc := Replicate("z", Len(QDH->QDH_RV))

	DbSelectArea("QDH")
	DbSetOrder(1)

	QDH->(MsSeek(xFilial("QDH")+cCodDoc+cRevDoc, .T.))
	dbSkip(-1)
	If QDH->QDH_DOCTO == cCodDoc
		cTitulo:= AllTrim(QDH->QDH_TITULO)
	EndIf

Return cTitulo
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldDocRef ºAutor  ³Sandra Ribeiro      º Data ³  19/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação se o documento é do tipo externo.                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Controle de Documentos                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßß
*/
Function VldDocRef(cTipo)

	Local cRet     := .F.
	Local nPosDRef := GdFieldPos( "QDB_DOCREF" ,aHedDoc[3])
	Local nPosDesc := GdFieldPos( "QDB_DESC"   ,aHedDoc[3])

	Default cTipo := ""

	If cTipo == "I"
		cRet := .T.
	Else
		aCols[n,nPosDRef] := Space(TamSx3("QDB_DOCREF")[1])
		aCols[n,nPosDesc] := Space(TamSx3("QDB_DESC")[1])
		cRet := .T.
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QDHTipDoc()
Realiza Validação do Tipo de Documento
@author André.Maximo
@since 11/04/2016
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Function QDHTipDoc()

Local lRet := .F.
Local lVerDP := .F.
Local aArea:= GetArea()
Local cFilQAD:=xFilial("QAD")                                  
	
	#IFDEF TOP
	Local cQuery:= ""
	#ENDIF

// Localiza dados do Tipo do documento
QD2->(DbSetOrder(1))
QD2->(DbSeek(xFilial("QD2")+M->QDH_CODTP))

		If !empty(QD2->QD2_CODTP)
			lVerDP := .T.
		Else
			lRet := .T.
		EndIf
	

		If lVerDP
			IF FWModeAccess("QAD") == "E" //!Empty(cFilQAD)
				cFilQAD:= QD2->QD2_FILDEP	
			ENDIF
	
			QAD->(DbSetOrder(1))
			If QAD->(DbSeek(cFilQAD+QD2->QD2_DEPTO))
	   			 lRet := .F.      
	
				#IFDEF TOP
					If TcSrvType() <> "AS/400"
						cQuery :="SELECT QAA.QAA_FILIAL,QAA.QAA_CC,QAA.QAA_MAT "
						cQuery +="FROM " + RetSqlName("QAA")+" QAA "
						cQuery +="WHERE "       
						cQuery +="QAA.QAA_FILIAL='"+QD2->QD2_FILDEP+"' AND "	
						cQuery +="QAA.QAA_CC='"+QD2->QD2_DEPTO+"' AND "
						cQuery +="QAA.QAA_DISTSN = '1' AND "
						cQuery += QA_FilSitF(.T.,.T.)+" AND "
						cQuery +="QAA.D_E_L_E_T_ <> '*' "
						
						If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
							cQuery += " ORDER BY 1,2,3"
						Else
							cQuery += " ORDER BY " + SqlOrder("QAA_FILIAL+QAA_CC+QAA_MAT")
						Endif
					
						cQuery := ChangeQuery(cQuery)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQAA",.T.,.T.)
					
						DbGotop()
						lRet:= TMPQAA->(!Eof())
						TMPQAA->(DbCLOSEAREA())			
					Else
				#ENDIF
			    DbSelectArea("QAA")
				DbSetOrder(2)
						IF QAA->(MsSeek(QD2->QD2_FILDEP+QD2->QD2_DEPTO))
							WHILE !QAA->(EOF()) .AND. QAA->(QAA_FILIAL+QAA_CC)==QD2->QD2_FILDEP+QD2->QD2_DEPTO
								IF QAA->QAA_DISTSN == "1" .AND. QA_SITFOLH()
									lRet := .T.
									EXIT
								ENDIF
								QAA->(DBSKIP())
							ENDDO
						Endif
						#IFDEF TOP
						Endif
					#ENDIF
	
						IF !lRet
							MsgAlert(OemToAnsi(STR0174),STR0175)  
						Endif
					Else
						lRet := .F.
						Help(" ",1,"QD050CCNE")		                                    	
					EndIf
				EndIF

RestArea(aArea)

Return lRet

/*/{Protheus.doc} fVerRecLei
Fun?o para verificar se o usuário deve receber pendencia de leitura conforme Destinatáios(QDG)
@type  Static Function
@author rafael.kleestadt
@since 24/05/2019
@version 1.0
@param cFilQDH, caractere, filial do documento posicionado
@param cCodDoc, caractere, código do documento posicionado
@param cRevDoc, caractere, revisão do documento posicionado
@param cFilMat, caractere, filial da matríula do usuáio que vai receber a pendêcia
@param cDepMat, caractere, departamento do usuáio que vai receber a pendêcia
@param cCodMat, caractere, matriula do usuáio que vai receber a pendêcia
@param cStatusPen, caractere, tipo de pendêcia a ser gerada
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function fVerRecLei(cFilQDH, cCodDoc, cRevDoc, cFilMat, cDepMat, cCodMat, cStatusPen)
Local aAreaQDG := QDG->(GetARea())
Local lRet     := .T.

DbSelectArea("QDG")
DbSetOrder(1) //QDG_FILIAL+QDG_DOCTO+QDG_RV+QDG_TIPO+QDG_FILMAT+QDG_DEPTO+QDG_MAT+QDG_CODMAN
	If QDG->(DbSeek(cFilQDH+cCodDoc+cRevDoc+"D"+cFilMat+cDepMat+cCodMat))
		If QDG->QDG_RECEB = 'N' .And. 'L' $ cStatusPen
		lRet := .F.
		EndIf
	EndIf
QDG->(DbCloseArea())

RestARea(aAreaQDG)
Return lRet


/*/{Protheus.doc} GetEstrTab
Monta o aheader conforme a tabela solicitada.
@type  Static Function
@author rafael.kleestadt
@since 21/02/2020
@version 1.0
@param aStruCad, array, estrutura da tabela solicitada
@param cCad, caracter, alias da tabela solicitada
@return aHeader, array, estrutura dos campos da tabela solicitada.
@example
(examples)
@see (links_or_references)
/*/
Static Function GetEstrTab(aStruCad, cCad)
Local nX := 0


For nX := 1 To Len(aStruCad)
	If cCad == "QD4"
		If	Trim( aStruCad[nX, 1] ) != "QD4_FILIAL" .And.;
			Trim( aStruCad[nX, 1] ) != "QD4_DOCTO"  .And.;
			Trim( aStruCad[nX, 1] ) != "QD4_RV"     .And.;
			Trim( aStruCad[nX, 1] ) != "QD4_FILMAT" .And.;
			Trim( aStruCad[nX, 1] ) != "QD4_TPPEND" .And.;
			Trim( aStruCad[nX, 1] ) != "QD4_FMATBX" .And.;
			Trim( aStruCad[nX, 1] ) != "QD4_MATBX"  .And.;
			Trim( aStruCad[nX, 1] ) != "QD4_DTBAIX" .And.;
			Trim( aStruCad[nX, 1] ) != "QD4_HRBAIX" .And.;
			Trim( aStruCad[nX, 1] ) != "QD4_DEPBX"  .And.;
		cNivel >= GetSx3Cache(aStruCad[nX, 1], 'X3_NIVEL')
		Aadd( aHeader, { Trim( QAGetX3Tit(aStruCad[nX, 1]) ),;
						 aStruCad[nX, 1], ;
						 GetSx3Cache(aStruCad[nX, 1], 'X3_PICTURE'), ;
						 GetSx3Cache(aStruCad[nX, 1], 'X3_TAMANHO'), ;
						 GetSx3Cache(aStruCad[nX, 1], 'X3_DECIMAL'), ;
						 GetSx3Cache(aStruCad[nX, 1], 'X3_VALID'), ;
						 GetSx3Cache(aStruCad[nX, 1], 'X3_USADO'), ;
						 GetSx3Cache(aStruCad[nX, 1], 'X3_TIPO'), ;
						 GetSx3Cache(aStruCad[nX, 1], 'X3_ARQUIVO'), ;
						 GetSx3Cache(aStruCad[nX, 1], 'X3_CONTEXT')} )
			EndIf
	Else
		If cNivel >= GetSx3Cache(aStruCad[nX, 1], 'X3_NIVEL') .and. ! ASCAN({cFil,cCod,cRv},{|x| x == Trim(aStruCad[nX, 1])}) > 0
			AADD(aHeader,{ TRIM( QAGetX3Tit(aStruCad[nX, 1]) ), ;
						   aStruCad[nX, 1], ; 
						   GetSx3Cache(aStruCad[nX, 1], 'X3_PICTURE'), ;
						   GetSx3Cache(aStruCad[nX, 1], 'X3_TAMANHO'), ;
						   GetSx3Cache(aStruCad[nX, 1], 'X3_DECIMAL'), ;
						   GetSx3Cache(aStruCad[nX, 1], 'X3_VALID'), ;
						   GetSx3Cache(aStruCad[nX, 1], 'X3_USADO'), ;
						   GetSx3Cache(aStruCad[nX, 1], 'X3_TIPO'), ;
						   GetSx3Cache(aStruCad[nX, 1], 'X3_ARQUIVO') } )
		EndIf
	Endif
Next nX
	
Return aHeader


/*/{Protheus.doc} fBuscQD5
Função que valida e retorna o valor correspondente a QD5
@type function
@version  
@author thiago.rover
@since 18/03/2021
@return return_type, return_description
/*/
Static Function fBuscQD5(cCodDoc, cRevDoc, cMatrcod)

Local cAliasQry := GetNextAlias()
Local cQry      := ""
Local cResult := "N"
	
		cQry := "SELECT * From " +RetSqlName("QDH") +" QDH "
		cQry += "    INNER JOIN "+RetSqlName("QD0") +" QD0 " 
		cQry += " ON QD0.QD0_DOCTO = QDH.QDH_DOCTO AND QD0.QD0_RV = QDH.QDH_RV "
		cQry += "    INNER JOIN "+RetSqlName("QD5") +" QD5 "
		cQry += " ON QD5.QD5_CODTP = QDH.QDH_CODTP "
		cQry += " WHERE QDH.QDH_DOCTO = '"+cCodDoc+"' and QDH.QDH_RV = '"+cRevDoc+"' and QD0.QD0_MAT = '"+cMatrCod+"' and QD0.QD0_AUT = QD5.QD5_AUT "
		cQry += " AND QD5.QD5_ALT ='S' "
		cQry += " AND QDH.D_E_L_E_T_ <> '*' AND QD0.D_E_L_E_T_ <> '*' AND QD5.D_E_L_E_T_ <> '*'"
		cQry := ChangeQuery( cQry )
		
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
		//Tratamento para quando o cAliasQry retorna mais que uma linha
		//Quando o mesmo usuário possui permissão "S" e "N", prevalece sempre "S"
		If (cAliasQry)->(!Eof())
		cResult:= "S"
		EndIf

Return cResult


/*/{Protheus.doc} QDOA050ResponsaveisClass
Regras de Negocio - Controle dos Responsáveis do Documento
@author    brunno.costa
@since     14/02/2022
/*/
CLASS QDO050CQDDClass FROM LongNameClass

	DATA aAnterior            as Array    //RESPONSÁVEIS ANTERIORES 
	DATA aInativos            as Array
    DATA aRespTipoDeDocumento as Array
	DATA aStruQD0             as Array
	DATA nPosOrdem            as Integer
	DATA nPosResponsabilidade as Integer
	DATA nPosUsuario          as Integer
	DATA nPosFILMAT           as Integer

	//METODOS PUBLICOS
	METHOD new(aResponsaveis) CONSTRUCTOR
    METHOD RecarregaArraysResponsaveis()

	//METODOS AUXILIARES
	METHOD AdicionaPosicionado(aResponsaveis, cResponsabilidade)
	METHOD AdicionaResponsaveisTipoDeDocumento(aResponsaveis)
	METHOD AdicionaResponsavelDepartamento(cDepartamento, cResponsavel, cResponsabilidade, aResponsaveis, cFilQAA)
	METHOD AdicionaResponsavelDepartamentoPorCargo(cDepartamento, cCargo, cRespTpDoc, cRespDoc, aResponsaveis, cFilaQDD)
	METHOD CampoValido(cCampo)
	METHOD CriaArrayResponsaveisVazioQuandoNecessario(aResponsaveis)
	METHOD EliminaResponsavelVazio(aResponsaveis)
	METHOD IdentificaResponsaveisDocumento(cDocumento, cRevisao)
	METHOD IdentificaResponsaveisTipoDeDocumento(cDocumento)
	METHOD OrdenaResponsaveis(aResponsaveis)
	METHOD ProximaOrdemPorResponsabilidade(aResponsaveis, cResponsabilidade)
	METHOD ReadicionaInclusoesManuaisUsuariosAtivos(aResponsaveis)
	METHOD ValidaSeEhPrimeiraCarga()
	METHOD ValidaUsuarioAtivo(cMatricula, cFilQAA)
	METHOD ValidaUsuarioAtivoQD0()

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author    brunno.costa
@since     14/02/2022
@param 01 - aResponsaveis, array, Array com os dados da tela de responsáveis atual
@return Self, objeto, instancia da Classe QDO050CQDDClass
/*/
METHOD new(aResponsaveis) CLASS QDO050CQDDClass
	Self:aAnterior            := aClone(aResponsaveis)
	Self:aInativos            := {}
	Self:aStruQD0             := FWFormStruct(3, 'QD0' )[FORM_STRUCT_TABLE_VIEW]
	Self:nPosOrdem            := GdFieldPos("QD0_ORDEM" , aHeader)
	Self:nPosResponsabilidade := GdFieldPos("QD0_AUT"   , aHeader)
	Self:nPosUsuario          := GdFieldPos("QD0_MAT"   , aHeader)
	Self:nPosFILMAT           := GdFieldPos("QD0_FILMAT", aHeader)
Return Self

/*/{Protheus.doc} RecarregaArraysResponsaveis
Recarrega Arrays de Responsáveis do QDOA050
@author    brunno.costa
@since     14/02/2022
@return aResponsaveis, array, array com os dados dos responsáveis para exibição em tela
/*/
METHOD RecarregaArraysResponsaveis() CLASS QDO050CQDDClass

	Local aResponsaveis := Nil

	If Inclui

		aResponsaveis := aClone(Self:aAnterior)

		If Self:ValidaSeEhPrimeiraCarga()

			Self:aRespTipoDeDocumento := Self:IdentificaResponsaveisTipoDeDocumento(M->QDH_CODTP)

			IF Len(Self:aRespTipoDeDocumento) > 0

				aResponsaveis := Self:EliminaResponsavelVazio(@aResponsaveis)
				aResponsaveis := Self:AdicionaResponsaveisTipoDeDocumento(@aResponsaveis)

			Endif

		EndIf
	Else

		aResponsaveis := Self:ReadicionaInclusoesManuaisUsuariosAtivos(@aResponsaveis)

		If Self:ValidaSeEhPrimeiraCarga(aResponsaveis)

			aResponsaveis := Self:IdentificaResponsaveisDocumento(QDH->QDH_DOCTO, QDH->QDH_RV)

			If Len(Self:aInativos) > 0
				aResponsaveis := Self:ReadicionaInclusoesManuaisUsuariosAtivos(@aResponsaveis)
				aResponsaveis := Self:CriaArrayResponsaveisVazioQuandoNecessario(@aResponsaveis)
			EndIf

		EndIf

		If Len(aResponsaveis) > 0
			aResponsaveis := Self:OrdenaResponsaveis(aResponsaveis)
			aResponsaveis := Self:EliminaResponsavelVazio(@aResponsaveis)
		EndIf

	EndIf

Return aResponsaveis

/*/{Protheus.doc} ValidaSeEhPrimeiraCarga
Retorna .T. quando deve realizar a primeira carga dos responsáveis
@author    brunno.costa
@since     14/02/2022
@param 01 - aResponsaveis, array, array para validação se é a primeira carga (array vazio)
@return lPrimeiraCarga, lógico, indica se deve realizar a carga inicial dos responsáveis
/*/
METHOD ValidaSeEhPrimeiraCarga(aResponsaveis) CLASS QDO050CQDDClass
	Local lPrimeiraCarga  := .F.
	Default aResponsaveis := Self:aAnterior
	lPrimeiraCarga := (aResponsaveis == Nil .OR.;
					  Empty(aResponsaveis) .OR.;
					  Len(aResponsaveis) == 0 .OR.;
					  (Len(aResponsaveis) == 1 .AND. Empty(aResponsaveis[1][Self:nPosUsuario])))
Return lPrimeiraCarga


/*/{Protheus.doc} IdentificaResponsaveisTipoDeDocumento
Identifica os Responsáveis por Tipo de Documento
@author    brunno.costa
@since     14/02/2022
@param 01 - cDocumento, caracter, código do documento para identificação dos responsáveis do tipo de documento
@return Self:aRespTipoDeDocumento, array, array com os responsáveis do tipo de documento do documento cDocumento
/*/
METHOD IdentificaResponsaveisTipoDeDocumento(cDocumento) CLASS QDO050CQDDClass
	
	Local cFilQDD := xFilial("QDD")

	Self:aRespTipoDeDocumento := {}

	QDD->(DbSetOrder(1))
	If QDD->(DbSeek(cFilQDD + cDocumento))
		QAA->(DbSetOrder(2))
		While QDD->(!Eof());
			.And. QDD->QDD_FILIAL == cFilQDD;
			.And. QDD->QDD_CODTP  == cDocumento

			Self:AdicionaResponsavelDepartamentoPorCargo(;
				QDD->QDD_DEPTOA,;
				QDD->QDD_CARGOA,;
				QDD->QDD_AUT,;   //Responsabilidade [QDD - Responsáveis por Tipo de Documento]
				QD0->QD0_AUT,;   //Responsabilidade [QD0 - Responsáveis pelo Documento]
				@Self:aRespTipoDeDocumento,;
				QDD->QDD_FILA)
			QDD->(DbSkip())
		Enddo
		Self:aRespTipoDeDocumento := Self:OrdenaResponsaveis(@Self:aRespTipoDeDocumento)
	EndIf

Return Self:aRespTipoDeDocumento

/*/{Protheus.doc} AdicionaResponsavelDepartamentoPorCargo
Adiciona os Responsáveis do Departamento Pelo Cargo
@author    brunno.costa
@since     14/02/2022
@param 01 - cDepartamento, caracter, código do departamento para análise 
@param 02 - cCargo       , caracter, código do cargo para análise
@param 03 - cRespTpDoc   , caracter, código da responsabilidade do tipo de documento - QDD_AUT - [QDD - Responsáveis por Tipo de Documento]
@param 04 - cRespDoc     , caracter, código da responsabilidade do documento -         QD0_AUT - [QD0 - Responsáveis pelo Documento]
@param 05 - aResponsaveis, array   , retorna por referência o array com os dados dos responsáveis atualizado
/*/
METHOD AdicionaResponsavelDepartamentoPorCargo(cDepartamento, cCargo, cRespTpDoc, cRespDoc, aResponsaveis,cFilaQDD) CLASS QDO050CQDDClass
	Local aAreaQAA	 := QAA->(GetArea())
	Local aInativos  := {}
	Local cAliasQAA  := GetNextAlias()
	Local cFilQAAQAD := ""
	Local cQuery     := ""
	Local oExec      := Nil
	Local oQltQryMng := Iif( FindClass(Upper("QLTQueryManager")) , QLTQueryManager():New() , Nil )

	Default lFwExecSta := FindClass(Upper("FwExecStatement")) //Default para facilitar na cobertura

	cFilQAAQAD := Iif(oQltQryMng <> Nil, oQltQryMng:MontaQueryComparacaoFiliaisComValorReferencia("QAA", "QAA_FILIAL", "QAD", cFilaQDD) , "")
	
	cQuery := " SELECT "
	cQuery += 		" QAA.QAA_CODFUN, "
	cQuery += 		" QAA.QAA_MAT, "
	cQuery += 		" QAA.QAA_FILIAL,
	cQuery += 		" QAA.QAA_STATUS "
	cQuery += " FROM " + RetSqlName("QAA") + " QAA "
	cQuery += " WHERE QAA.QAA_CC = '" + cDepartamento + "' "
	cQuery += " AND " + Iif( cFilQAAQAD <> "", cFilQAAQAD, " QAA.QAA_FILIAL = '" + xFilial("QAA") + "' ")
	cQuery += " AND QAA.D_E_L_E_T_ = ' ' "
	
	If lFwExecSta
		oExec := FwExecStatement():New(cQuery)
		cAliasQAA := oExec:OpenAlias()
		oExec:Destroy()
		oExec := nil 
	else
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQAA)
	EndIf

	Self:aInativos  := aInativos //Ponteiro do Array
	DbSelectArea("QAA")
	QAA->(DbSetOrder(1))
	While (cAliasQAA)->(!Eof())
		If QAA->(DbSeek((cAliasQAA)->(QAA_FILIAL+QAA_MAT)))
			If (cAliasQAA)->QAA_CODFUN == cCargo .And. Self:ValidaUsuarioAtivo((cAliasQAA)->QAA_MAT, (cAliasQAA)->QAA_FILIAL)

				Self:AdicionaPosicionado(@aResponsaveis, cRespTpDoc)

			Elseif (cAliasQAA)->QAA_STATUS == '2'//USUARIO INATIVO
					
				Self:AdicionaPosicionado(@aInativos    , cRespDoc)

			EndIf
		EndIf
		(cAliasQAA)->(DbSkip())
	Enddo
	RestArea(aAreaQAA)
	(cAliasQAA)->(DbCloseArea())
Return

/*/{Protheus.doc} IdentificaResponsaveisDocumento
Identifica os Responsáveis do Documento
@author    brunno.costa
@since     14/02/2022
@param 01 - cDocumento, caracter, código do documento para identificação
@param 02 - cRevisao  , caracter, código da revisão do documento para identificação
@return aResponsaveis, array, array com os responsáveis do documento
/*/
METHOD IdentificaResponsaveisDocumento(cDocumento, cRevisao) CLASS QDO050CQDDClass
	
	Local aResponsaveis := {}

	DbSelectArea("QD0")
	QD0->(DbSetOrder(1))
	If QD0->(DbSeek(xFilial("QD0")+cDocumento+cRevisao))  
		QAA->(DbSetOrder(1))
		While QD0->(!Eof());
			.And. QD0->QD0_FILIAL == xFilial("QD0");  
			.And. QD0->QD0_DOCTO  == cDocumento;
			.And. QD0->QD0_RV     == cRevisao

			Self:AdicionaResponsavelDepartamento(;
				QD0->QD0_DEPTO,;
				QD0->QD0_MAT,;
				QD0->QD0_AUT,;
				@aResponsaveis,;
				Iif(Empty(QD0->QD0_FILMAT), NIL, QD0->QD0_FILMAT))
			QD0->(DbSkip())
		Enddo
	Endif

Return aResponsaveis

/*/{Protheus.doc} AdicionaResponsavelDepartamento
Adiciona Responsável do Departamento
@author    brunno.costa
@since     14/02/2022
@param 01 - cDepartamento    , caracter, código do departamento para análise 
@param 02 - cResponsavel     , caracter, código do responsável para análise
@param 03 - cResponsabilidade, caracter, código da responsabilidade do usuário - QD0_AUT - [QD0 - Responsáveis pelo Documento]
@param 04 - aResponsaveis    , array   , retorna por referência o array com os dados dos responsáveis atualizado
@param 05 - cFilQAA          , caracter, filial da QAA para considerar o registro
/*/
METHOD AdicionaResponsavelDepartamento(cDepartamento, cResponsavel, cResponsabilidade, aResponsaveis, cFilQAA) CLASS QDO050CQDDClass

	Local aInativos := {}
	Local nLenDpto  := Len(QD0->QD0_DEPTO)
	
	Default cFilQAA   := xFilial("QAA")

	Self:aInativos  := aInativos //Ponteiro do Array

	If QAA->(DbSeek(cFilQAA + cResponsavel)) //QAA->(DbSetOrder(1))
		While QAA->(!Eof());
			.And. cFilQAA       == QAA->QAA_FILIAL;
			.And. cDepartamento == Padr(QAA->QAA_CC, nLenDpto);
			.And. cResponsavel  == QAA->QAA_MAT

			If Self:ValidaUsuarioAtivo(QAA->QAA_MAT, QAA->QAA_FILIAL)

				If Self:ValidaUsuarioAtivoQD0()
					Self:AdicionaPosicionado(@aResponsaveis, cResponsabilidade)
				EndIf
				
			Elseif QAA->QAA_STATUS == '2'

				Self:AdicionaPosicionado(@aInativos    , cResponsabilidade)

			EndIf
			QAA->(DbSkip())
		Enddo
	EndIf

Return

/*/{Protheus.doc} ValidaUsuarioAtivoQD0
Se é uma nova revisão e se o usuário está inativo na revisão anterior não será enviado para próxima revisão.
@author    rafael.hesse
@since     30/08/2022
@return lRet, Lógico, indica se é uma nova revisão e está inativo na QD0
/*/
METHOD ValidaUsuarioAtivoQD0() CLASS QDO050CQDDClass
Local lNovaRevi := isInCallStack("QD050GERRV")
Local lRet      := .T.

	If (lNovaRevi .And. QD0->QD0_FLAG=='I')
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} ProximaOrdemPorResponsabilidade
Retorna a Próxima Ordem do Responsável neste Nível de cResponsabilidade
@author    brunno.costa
@since     14/02/2022
@param 01 - aResponsaveis    , array   , array com os dados dos responsáveis para consulta
@param 02 - cResponsabilidade, caracter, código da responsabilidade para consulta
@return cProxOrdem, caracter, string de dois caracteres indicando a próxima ordem do responsável na responsabilidade
/*/
METHOD ProximaOrdemPorResponsabilidade(aResponsaveis, cResponsabilidade) CLASS QDO050CQDDClass
	Local cProxOrdem    := ""
	Local nIndice       := 0
	Local nOrdQD0       := 0
	Local nResponsaveis := Len(aResponsaveis)

	If aScan(aResponsaveis,{|x| x[Self:nPosResponsabilidade] == cResponsabilidade}) != 0
		For nIndice := 1 to nResponsaveis
			If aResponsaveis[nIndice, Self:nPosResponsabilidade] == cResponsabilidade
				If nOrdQD0 < Val(aResponsaveis[nIndice, Self:nPosOrdem])
					nOrdQD0 := Val(aResponsaveis[nIndice, Self:nPosOrdem])
				EndIf
			EndIf
		Next
	EndIf
	nOrdQD0    := If(nOrdQD0 == 0, 1, nOrdQD0+1)
	cProxOrdem := StrZero(nOrdQD0, 2)

Return cProxOrdem

/*/{Protheus.doc} AdicionaPosicionado
Adiciona Responsavel Posicionado da QAA no Array de Responsáveis
@author    brunno.costa
@since     14/02/2022
@param 01 - aResponsaveis    , array   , retorna por referência array com os dados dos responsáveis
@param 02 - cResponsabilidade, caracter, código da responsabilidade para adicionar
/*/
METHOD AdicionaPosicionado(aResponsaveis, cResponsabilidade) CLASS QDO050CQDDClass
	
	Local cCampo    := ""
	Local cProxOrd  := Self:ProximaOrdemPorResponsabilidade(aResponsaveis, cResponsabilidade)
	Local nIndice   := 0
	Local nPosCampo := 0

	aAdd(aResponsaveis, Array(Len(aHeader)+1))
	nIndResp := Len(aResponsaveis)

	For nIndice := 1 To Len(Self:aStruQD0)
		cCampo := Upper(Alltrim(Self:aStruQD0[nIndice, MVC_VIEW_IDFIELD]))

		If Self:CampoValido(cCampo)
			
			nPosCampo := aScan(aHeader, {|X| Upper(Alltrim(X[2])) == cCampo})

			If GetSx3Cache(cCampo, 'X3_CONTEXT') == "V"
				If cCampo == "QD0_NOME"
					aResponsaveis[nIndResp, nPosCampo] := Padr( QAA->QAA_NOME, 40 )
				Else
					aResponsaveis[nIndResp, nPosCampo] := CriaVar(cCampo)
				EndIf

			Else
				If cCampo == "QD0_AUT"
					aResponsaveis[nIndResp, nPosCampo] := cResponsabilidade
				ElseIf cCampo == "QD0_ORDEM"
					aResponsaveis[nIndResp, nPosCampo] := cProxOrd
				ElseIf cCampo == "QD0_FILMAT"
					aResponsaveis[nIndResp, nPosCampo] := QAA->QAA_FILIAL
				ElseIf cCampo == "QD0_MAT"
					aResponsaveis[nIndResp, nPosCampo] := QAA->QAA_MAT
				ElseIf cCampo == "QD0_DEPTO"
					aResponsaveis[nIndResp, nPosCampo] := QAA->QAA_CC
				Else
					aResponsaveis[nIndResp, nPosCampo] := CriaVar(cCampo)
				Endif

			EndIf

		EndIf
	Next nIndice
	
	//Marca Registro não Deletado
	aResponsaveis[nIndResp, Len(aHeader)+1] := .F.

Return


/*/{Protheus.doc} CampoValido
Verifica se o Campo é Válido por Nível (X3_NIVEL) e se Não é Campo de _FILIAL, _DOCTO nem _RV
@author    brunno.costa
@since     14/02/2022
@param 01 - cCampo, caracter, campo para checagem d evalidade
@return lValido, lógico, indica se o campo é válido para exibição
/*/
METHOD CampoValido(cCampo) CLASS QDO050CQDDClass

	Local lNivelOk := cNivel >= GetSx3Cache(cCampo, 'X3_NIVEL')
	Local lNaoEh   := !aScan({cFil,cCod,cRv},{|x| x == Trim(cCampo)}) > 0 //Não é Campo de _FILIAL, _DOCTO nem _RV
	Local lValido  := lNivelOk .AND. lNaoEh

Return lValido

/*/{Protheus.doc} OrdenaResponsaveis
Ordena os Responsáveis no Array por Responsabilidade + Ordem
@author    brunno.costa
@since     14/02/2022
@param 01 aResponsaveis, array, array com os dados dos responsaveis para ordenação
@return aResponsaveis, array, array com os dados dos responsáveis ordenados
/*/
METHOD OrdenaResponsaveis(aResponsaveis) CLASS QDO050CQDDClass

	Local nIndice := 0

	For nIndice := 1 to Len( aResponsaveis )
		If aResponsaveis[nIndice][Self:nPosResponsabilidade] == "E"
			aResponsaveis[nIndice][Self:nPosResponsabilidade] := "1"
		ElseIf aResponsaveis[nIndice][Self:nPosResponsabilidade] == "R"
			aResponsaveis[nIndice][Self:nPosResponsabilidade] := "2"
		ElseIf aResponsaveis[nIndice][Self:nPosResponsabilidade] == "A"
			aResponsaveis[nIndice][Self:nPosResponsabilidade] := "3"
		ElseIf aResponsaveis[nIndice][Self:nPosResponsabilidade] == "H"
			aResponsaveis[nIndice][Self:nPosResponsabilidade] := "4"
		EndIf
	Next

	aResponsaveis := aSort( aResponsaveis, , , { |x,y| x[Self:nPosResponsabilidade] + x[Self:nPosOrdem] < y[Self:nPosResponsabilidade] + y[Self:nPosOrdem] } )

	For nIndice :=1 to Len( aResponsaveis )
		If aResponsaveis[nIndice][Self:nPosResponsabilidade] == "1"
			aResponsaveis[nIndice][Self:nPosResponsabilidade] := "E"
		ElseIf aResponsaveis[nIndice][Self:nPosResponsabilidade] == "2"
			aResponsaveis[nIndice][Self:nPosResponsabilidade] := "R"
		ElseIf aResponsaveis[nIndice][Self:nPosResponsabilidade] == "3"
			aResponsaveis[nIndice][Self:nPosResponsabilidade] := "A"
		ElseIf aResponsaveis[nIndice][Self:nPosResponsabilidade] == "4"
			aResponsaveis[nIndice][Self:nPosResponsabilidade] := "H"
		EndIf
	Next

Return aResponsaveis

/*/{Protheus.doc} EliminaResponsavelVazio
Elimina Posição do Array Com Responsável Vazio
@author    brunno.costa
@since     14/02/2022
@param 01 - aResponsaveis, array, retorna por referência array com os dados dos responsáveis sem código de responsável vazio
@return aResponsaveis, array, array com os dados dos responsáveis sem código de responsável vazio
/*/
METHOD EliminaResponsavelVazio(aResponsaveis) CLASS QDO050CQDDClass

	Local nIndice := 0
	Local nTotal  := Len(aResponsaveis)

	Default aResponsaveis := {}

	For nIndice := 1 To nTotal
		If aResponsaveis != Nil .AND.;
		   Len(aResponsaveis) > 0 .AND.;
		   Len(aResponsaveis[nIndice]) > 0 .AND.;
		   Empty(aResponsaveis[nIndice][Self:nPosUsuario]) //Código do Responsável Vazio

			aDel(aResponsaveis, nIndice)
			aSize(aResponsaveis, Len(aResponsaveis)-1)
			nIndice--
			nTotal  := Len(aResponsaveis)

		EndIf
	Next nIndice

Return aResponsaveis

/*/{Protheus.doc} AdicionaResponsaveisTipoDeDocumento
Adiciona Responsáveis do Tipo de Documento
@author    brunno.costa
@since     14/02/2022
@param 01 aResponsaveis, array, retorna por referência array com os dados do responsáveis para adicionar os responsáveis por tipo de documento
@return aResponsaveis, array, array com os dados dos responsáveis por tipo de documentos adicionados;
/*/
METHOD AdicionaResponsaveisTipoDeDocumento(aResponsaveis) CLASS QDO050CQDDClass
	
	Local   nIndice       := 0
	Default aResponsaveis := {}
	
	For nIndice   := 1 To Len(Self:aRespTipoDeDocumento)
		If !(aScan(aResponsaveis,{|x| x[Self:nPosUsuario]          == Self:aRespTipoDeDocumento[nIndice][Self:nPosUsuario];
		                        .And. x[Self:nPosResponsabilidade] == Self:aRespTipoDeDocumento[nIndice][Self:nPosResponsabilidade]}))

			Aadd(aResponsaveis, aClone(Self:aRespTipoDeDocumento[nIndice]) )

		Endif
	Next

Return aResponsaveis

/*/{Protheus.doc} ReadicionaInclusoesManuaisUsuariosAtivos
Readiciona Inclusões Manuais de Usuários Ativos
@author    brunno.costa
@since     14/02/2022
@param 01 aResponsaveis, array, retorna por referência array com os dados do responsáveis para adicionar os responsáveis inclusos manualmente ainda ativos
@return aResponsaveis, array, array com os dados dos responsáveis adicionados
/*/
METHOD ReadicionaInclusoesManuaisUsuariosAtivos(aResponsaveis) CLASS QDO050CQDDClass
	
	Local aAnterior       := Self:aAnterior
	Local nIndice         := 0

	Default aResponsaveis := {}
	
	If !Empty(aAnterior)
		If aTail(aAnterior)[1] != NIL 
			For nIndice := 1 to Len(aAnterior)
				If Self:ValidaUsuarioAtivo(aAnterior[nIndice][Self:nPosUsuario], aAnterior[nIndice][Self:nPosFILMAT])
					aAdd(aResponsaveis, aAnterior[nIndice]) 
				Endif
			Next nIndice
		Endif
	Endif

Return aResponsaveis

/*/{Protheus.doc} ValidaUsuarioAtivo
Valida se o usuário está ativo
@author    brunno.costa
@since     14/02/2022
@param 01 - cMatricula, caracter, matricula do usuário para validar se está ativo
@param 02 - cFilQAA   , caracter, filial da QAA para considerar o registro
@return lAtivo, lógico, indica se o usuário está ativo
/*/
METHOD ValidaUsuarioAtivo(cMatricula, cFilQAA) CLASS QDO050CQDDClass

	Local aArea    := GetArea()
	Local aAreaQAA := QAA->(GetArea())
	Local cStatus  := "2"
	Local dFim     := ""
	Local dInicio  := ""
	Local lAtivo   := .F.

	Default cFilQAA  := xFilial("QAA")

	If QAA->(QAA_FILIAL+QAA_MAT) == cFilQAA + cMatricula
		cStatus := QAA->QAA_STATUS
		dFim    := QAA->QAA_FIM
		dInicio := QAA->QAA_INICIO
	Else
		QAA->(DbSetOrder(1))
		If QAA->(DbSeek(cFilQAA + cMatricula))
			cStatus := QAA->QAA_STATUS
			dFim    := QAA->QAA_FIM
			dInicio := QAA->QAA_INICIO
		EndIf
	EndIf

	If 	( (Empty(dFim) .And. cStatus <> "2") .Or. (!Empty(dFim) .And. dFim >= dDataBase) ) .And.;
		(Empty(dInicio) .Or. dDataBase >= dInicio)
		lAtivo := .T.
	Endif

	RestArea(aAreaQAA)
	RestArea(aArea)

Return lAtivo


/*/{Protheus.doc} CriaArrayResponsaveisVazioQuandoNecessario
Cria Array de Responsáveis Vazio Quando for o Caso
@author    brunno.costa
@since     14/02/2022
@param 01 aResponsaveis, array, retorna por referência relação de responsáveis atuais com array vazio ou recebidos, quando for o caso
@return aResponsaveis, array, retorna relação de responsáveis atuais com array vazio ou recebidos, quando for o caso
/*/
METHOD CriaArrayResponsaveisVazioQuandoNecessario(aResponsaveis) CLASS QDO050CQDDClass

	Local lCriaVazio := .F.
	Local nIndice    := 0

	If Empty(aResponsaveis) .OR. aTail(aResponsaveis)[1] == Nil .Or. Empty(aTail(aResponsaveis)[1])
		lCriaVazio := .T.
	Endif
	
	If lCriaVazio
		aResponsaveis := Array(1, Len(aHeader)+1)
		
		For nIndice := 1 to Len(Self:aInativos[1])
			IF nIndice == (Len(Self:aInativos[1]) -2)
				aResponsaveis[1][nIndice] := Space(3) 
			ELseIf nIndice == (Len(Self:aInativos[1]) -1)
				aResponsaveis[1][nIndice] := 0 
			ElseIf 	nIndice == Len(Self:aInativos[1])
				aResponsaveis[1][nIndice] := .F.
			Else 
				aResponsaveis[1][nIndice] := Space(Len(Self:aInativos[1][nIndice]))
			Endif	
		Next nIndice    

	Endif

Return aResponsaveis
