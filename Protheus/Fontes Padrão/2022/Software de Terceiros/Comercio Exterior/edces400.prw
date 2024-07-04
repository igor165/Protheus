#INCLUDE 'EDCES400.CH'
#INCLUDE 'Average.CH'
#INCLUDE 'DBTREE.CH'

STATIC lPCPREVTAB	:= FindFunction('PCPREVTAB')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
STATIC lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MATA200  ³ Autor ³ Fernando Joly/Eduardo ³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manuten‡„o na Estrutura dos produtos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Fernando J. ³22.06.99³XXXXXX³Gravar Estrutura Similar antes da Confirm.³±±
±±³Fernando J. ³01.07.99³XXXXXX³Gravar B1_QB na confirma‡„o da Inclus„o.  ³±±
±±³Fernando J. ³20.09.99³23216A³Posicionar-se sempre no Pai apos Inclus„o.³±±
±±³Fernando J. ³19.10.99³14496a³Incluir opcao de Pesquisa na Estrutura.   ³±±
±±³Fernando J. ³19.10.99³XXXXXX³Executar o EndEstrut2 fora da Transacao.  ³±±
±±³Rubens Pante³18/10/01³xxxxxx³Criado STR0030 - "Pesquisar..."           ³±±
** Alex Wallauer - 06/05/2014 - Programacao para a chamda do MSEXECAUTO()  **
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Static lLeadTime := .F. - AOM NOPADO 28/09/2011 - foi declarada como Private pois há funcoes que sao chamadas de outros fontes.

Function EDCES400(xAutoCab,xAutoItens,nOpcAuto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAreaAnt := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Private                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oTree
Private cCadastro  := OemToAnsi(STR0001) // 'Estruturas'
Private cCodAtual  := Replicate('ú', Len(SG1->G1_COD))
Private cValComp   := Replicate('ú', Len(SG1->G1_COD)) + 'ú'
Private ldbTree    := .F.
Private cInd5      := ''
Private nNAlias    := 0
Private cMarca     := GetMark(), lInverte := .F.
Private l010Auto   := .F. //AAF 14/08/2006 - Para funcionamento do botão incluir no F3 do SB1.
Private lCopia     := .F. //AAF 14/08/2006 - Para funcionamento do botão incluir no F3 do SB1.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()

Private lMSExecAuto := ( ValType(xAutoCab)=="A" .And. (ValType(xAutoItens)=="A" .Or. nOpcAuto==5))
Private aAutoCab	:= {}
Private aAutoItens	:= {}    
Private lLT_EIJ     := .F.
Private lLT_SB1     := .F.

Default	nOpcAuto	:= 3

dbSelectArea('SG1')
dbSetOrder(1)

IF EYJ->(FieldPos("EYJ_LEADTI")) > 0  //LRS - 11/02/2014 - Validação para o lead time dentro da tabela EYJ 
	lLeadTime := EDC->(FieldPos("EDC_LEADTI")) > 0 .and. EYJ->(FieldPos("EYJ_PRODUC")) > 0 .AND.;
						 EDC->(FieldPos("EDC_PRODUC")) > 0 .and. EasyGParam("MV_AVG0184",.F.,.F.)
   lLT_EIJ   := lLeadTime
Else
	lLeadTime := SB1->(FieldPos("B1_LEADTI")) > 0 .AND. EDC->(FieldPos("EDC_LEADTI")) > 0 .and.;
                         SB1->(FieldPos("B1_PRODUC")) > 0 .AND. EDC->(FieldPos("EDC_PRODUC")) > 0 .and.;
                         EasyGParam("MV_AVG0184",.F.,.F.)
   lLT_SB1   := lLeadTime
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Se atualiza a data de revisÆo B1_UREV  ³
//³ mv_par02 - Atualiza arquivo de revisoes           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte('MTA200', .F.)

If !lMSExecAuto

   SetKey( VK_F12, { || Pergunte('MTA200', .T.) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   mBrowse( 6, 1,22,75,'SG1')

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recalcula os Niveis                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// 15.mai.2009 - ED719582 - Retirada do recálculo das estruturas - HFD
If EasyGParam('MV_NIVALT') == 'S'
	MA320Nivel()
EndIf
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desativa tecla que aciona pergunta            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Set Key VK_F12 To
Else //lMSExecAuto - Executa a rotina automatica

	aAutoCab	:= aClone(xAutoCab)
	aAutoItens	:= aClone(xAutoItens)

	AVa200Proc("SG1",RecNo(),nOpcAuto)

ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Area de trabalho.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaAnt)

Return Nil                  

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 23/01/07 - 14:51
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina :=  {{ STR0002, 'AxPesqui'   , 0, 1}, ;    // 'Pesquisar'
                   { STR0003, 'Ava200Proc' , 0, 2}, ;    //'Visualizar'
                   { STR0004, 'AVa200Proc' , 0, 3}, ;    //'Incluir'
                   { STR0005, 'AVa200Proc' , 0, 4, 13}, ;//'Alterar'
                   { STR0006, 'AVa200Proc' , 0, 5, 14}}  //'Excluir'
   
   // P.E. utilizado para adicionar itens no Menu da mBrowse
   If EasyEntryPoint("DES400MNU")
	  aRotAdic := ExecBlock("DES400MNU",.f.,.f.)
	  If ValType(aRotAdic) == "A"
         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
      EndIf
   EndIf

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  AVa200Proc ³Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Processamento da Estrutura                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVA200Proc(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVa200Proc(cAlias,nRecno,nOpcX)

Local oDlg
Local oUm,nJ,nI
Local oRevisao
Local oQtdBase
Local oButPosic
Local cTitulo	  := STR0001 + ' - ' // 'Estruturas'
Local cGetRevIni := ''
Local cAutRevIni := ''
Local lGetRevisa := .T. 
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local aUndo      := {}
Local lMudou     := .F.
Local aAltEstru  := {}
Local aPaiEstru	 := {}
Local aKey       := {}
Local aBkey      := {}
Private nIndex   := 1
Private cCodigo  := CriaVar('G1_COD')

Private cRevisao := CriaVar('B1_REVATU')
Private cProduto := CriaVar('G1_COD')
Private cCodSim  := CriaVar('G1_COD')
Private cUm      := CriaVar('B1_UM')
Private nQtdBase := CriaVar('B1_QB')

// Verifica se esta no SIGAEDC
Private cFilSB1Aux  := xFilial("SB1")
Private cAliasSB1 := 'SB1'
Private cAliasEYJ := 'EYJ'
Private cF3       := 'SB1'
Private lAbriuExp := .F.

// Verifica se esta no SIGAEDC
If AmIin(50)   
   If Select("SB1EXP") = 0
      lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"  ")),cFilSB1Aux,"SB1EXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
   Else   
      lAbriuExp := .T.
   Endif    
   If lAbriuExp      
      cAliasSB1    := 'SB1EXP'
      cFilSB1Aux   := If(Empty(ALLTRIM(EasyGParam("MV_FILEXP",,"  "))), Space(02), ALLTRIM(EasyGParam("MV_FILEXP",,"  ")))
   Endif
EndIf

If nOpcX == 2
	cTitulo += OemToAnsi(STR0018) // 'Visualisa‡„o'
	ldbTree := .T.                // NCF - 01/08/2019 - Habilita a navegação nos nós do tree 
ElseIf nOpcX == 3
	cTitulo += OemToAnsi(STR0016) // 'Inclus„o'
ElseIf nOpcX == 4
	ldbTree := .T.
	cTitulo += OemToAnsi(STR0015) // 'Altera‡„o'
ElseIf nOpcX == 5
	ldbTree := .T.
	cTitulo += OemToAnsi(STR0017) // 'Exclus„o'
EndIf

If nOpcX == 3
	cUm       := Space(Len(SB1->B1_UM))//'' //JVR - 28/03/10 - Revisão para continuar com o tamanho adequado.
	cRevisao  := Space(Len(SB1->B1_REVATU))//''//JVR 
	cCodigo   := Space(Len(SG1->G1_COD))
	cCodAtual := Replicate('ú', Len(SG1->G1_COD))
	cValComp  := Replicate('ú', Len(SG1->G1_COD)) + 'ú'
	nQtdBase	 := 0
	If lLeadTime
	   IF EYJ->(FieldPos("EYJ_LEADTI")) > 0  //LRS - 11/02/2014 - Validação para o lead time dentro da tabela EYJ	 
	       M->EYJ_LEADTI := 0
	       M->EYJ_PRODUC := 0
       ELSE
	       M->B1_LEADTI := 0
	       M->B1_PRODUC := 0
	   ENDIF    
    EndIf
Else

	If (nOpcX == 4 .OR. nOpcX == 5) .And. lMSExecAuto
		SG1->(dbSetOrder(1))
		If !SG1->(dbSeek(xFilial("SG1")+aAutoCab[ProcP(aAutoCab,"G1_COD"),2]))
			Help(" ",1,"REGNOIS")
			lRet := .F.
		EndIf
	EndIf

	(cAliasSB1)->(dbSetOrder(1))
	SB1->(DbSetOrder(1))
	If lRet .And. !(cAliasSB1)->(dbSeek(cFilSB1Aux + SG1->G1_COD, .F.)) .And. !SB1->(dbSeek(xFilial() + SG1->G1_COD, .F.))
		Help('  ', 1, 'NOFOUNDSB1')
		lRet := .F.
	EndIf
	cUm       := If((cAliasSB1)->(!Eof()), (cAliasSB1)->B1_UM, SB1->B1_UM)
	cRevisao  := If((cAliasSB1)->(!Eof()), IIF(lPCPREVATU, PCPREVATU((cAliasSB1)->B1_COD), (cAliasSB1)->B1_REVATU) , IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU) )
	cCodigo   := SG1->G1_COD
	cCodAtual := SG1->G1_COD
	cValComp  := SG1->G1_COD + 'ú'
	nQtdBase  := If((cAliasSB1)->(!Eof()), (cAliasSB1)->B1_QB, SB1->B1_QB)
	 //MFR 09/12/2019
	(cAliasEYJ)->(dbSetOrder(1))
	(cAliasEYJ)->(dbSeek(xFilial("EYJ") + SG1->G1_COD))

   If EYJ->(FieldPos("EYJ_ESTSIM")) > 0
       cCodSim   := (cAliasEYJ)->EYJ_ESTSIM
   ElseIf SB1->(FieldPos("B1_ESTSIM")) > 0
	    cCodSim   := (cAliasSB1)->B1_ESTSIM
	EndIf

	If lLeadTime
	   IF EYJ->(FieldPos("EYJ_LEADTI")) > 0  //LRS - 11/02/2014 - Validação para o lead time dentro da tabela EYJ	
           M->EYJ_LEADTI := (cAliasEYJ)->EYJ_LEADTI
	       M->EYJ_PRODUC := (cAliasEYJ)->EYJ_PRODUC
       ELSE
	       M->B1_LEADTI := (cAliasSB1)->B1_LEADTI
	       M->B1_PRODUC := (cAliasSB1)->B1_PRODUC
	   EndIF    
    EndIf
EndIf

If lRet
   
   If !lMSExecAuto

      DEFINE MSDIALOG oDlg FROM  015, 006 TO If(lLeadTime,314,299), 537 TITLE cTitulo PIXEL

      @ 008, 008 SAY   OemToAnsi(STR0019) SIZE 037, 007 OF oDlg PIXEL // 'C¢digo:'

      // Verifica se esta no SIGAEDC
      If AmIin(50)
         If lAbriuExp
            SETKEY(VK_F4,{||EDCAC400HLP(@cCodigo)})
            @ 008, 105 SAY   STR0035 SIZE 037, 007 OF oDlg PIXEL // (F4-Help)
            @ 006, 025 MSGET cCodigo            SIZE 100, 010 OF oDlg PIXEL PICTURE PesqPict('SG1','G1_COD') ;
      	         WHEN (!ldbTree .And. nOpcX==3) VALID AVA200Codigo(cCodigo, @cUm, @cRevisao, @nQtdBase, oUm, oRevisao, oQtdBase, oDlg, cAliasSB1)

         Else
            @ 006, 025 MSGET cCodigo            SIZE 100, 010 OF oDlg PIXEL PICTURE PesqPict('SG1','G1_COD') ;
      	         WHEN (!ldbTree .And. nOpcX==3) VALID AVA200Codigo(cCodigo, @cUm, @cRevisao, @nQtdBase, oUm, oRevisao, oQtdBase, oDlg) ;
        	         F3 cF3
         Endif
      Else
          @ 006, 025 MSGET cCodigo            SIZE 100, 010 OF oDlg PIXEL PICTURE PesqPict('SG1','G1_COD') ;
      	       WHEN (!ldbTree .And. nOpcX==3) VALID AVA200Codigo(cCodigo, @cUm, @cRevisao, @nQtdBase, oUm, oRevisao, oQtdBase, oDlg) ;
        	       F3 cF3
      Endif

      @ 008, 130 SAY   STR0032             SIZE 037, 007 OF oDlg PIXEL //## Descrição
      @ 006, 160 MSGET AVA200Desc(cCodigo) SIZE 100, 010 OF oDlg PIXEL WHEN .F.

      @ 020, 008 SAY   OemToAnsi(STR0021) SIZE 054, 007 OF oDlg PIXEL // 'Estrutura Similar'
      @ 020, 064 MSGET cCodSim            SIZE 061, 010 OF oDlg PIXEL PICTURE PesqPict('SG1','G1_COD') ;
      	WHEN (!ldbTree .And. nOpcX==3) VALID AVA200CodSim(cCodigo, cCodSim, @aUndo) ;
      	F3 'SG1'

      @ 020, 130 SAY   OemToAnsi(STR0022)    SIZE 053, 007 Of oDlg PIXEL //HFD 'Quantidade Base:'
      @ 020, 160 MSGET oQtdBase Var nQtdBase SIZE 013, 010 Of oDlg PIXEL PICTURE PesqPictQt('B1_QB',20) ;
      	WHEN (nOpcX==3.Or.nOpcX==4) VALID AVA200QBase(nQtdBase, nOpcX, cCodigo, cCodSim, oTree, oDlg)

      @ 020, 195 SAY   OemToAnsi(STR0020) SIZE 040, 007 OF oDlg PIXEL	//'Unid.'
      @ 020, 210 MSGET oUm Var cUm        SIZE 010, 010 OF oDlg PIXEL ;
      	WHEN .F.

      @ 033, 008 SAY   OemToAnsi(STR0023)    SIZE 030, 007 OF oDlg PIXEL // 'Rev.'
      @ 033, 021 MSGET oRevisao Var cRevisao SIZE 013, 010 OF oDlg PIXEL PICTURE PesqPict('SB1','B1_REVATU',3) ;
      	WHEN (!ldbTree .And. nOpcX == 2 .And. lGetRevisa) VALID AVA200GetRev(@lGetRevisa, oDlg, oTree, cCodigo, cRevisao, nOpcX)

      //AAF 23/07/09
      If lLeadTime
         IF EYJ->(FieldPos("EYJ_LEADTI")) > 0  //LRS - 11/02/2014 - Validação para o lead time dentro da tabela EYJ
      	   @ 033, 069 SAY   OemToAnsi("Lead Time")    SIZE 030, 007 OF oDlg PIXEL
      	   @ 033, 101 MSGET oLeadTime Var M->EYJ_LEADTI Valid Eval(AVSX3("EYJ_LEADTI",AV_VALID)) SIZE 013, 010 OF oDlg PIXEL PICTURE PesqPict('EYJ','EYJ_LEADTI',3)
      	   @ 033, 130 SAY   OemToAnsi("Produção")    SIZE 030, 007 OF oDlg PIXEL
      	   @ 033, 160 MSGET oLeadTime Var M->EYJ_PRODUC Valid Eval(AVSX3("EYJ_PRODUC",AV_VALID)) SIZE 060, 010 OF oDlg PIXEL PICTURE PesqPict('EYJ','EYJ_PRODUC',10)
         ELSE
         	@ 033, 069 SAY   OemToAnsi("Lead Time")    SIZE 030, 007 OF oDlg PIXEL
      	   @ 033, 101 MSGET oLeadTime Var M->B1_LEADTI Valid /*NaoVazio(M->B1_LEADTI) .AND. - AOM - 13/10/2011*/Eval(AVSX3("B1_LEADTI",AV_VALID)) SIZE 013, 010 OF oDlg PIXEL PICTURE PesqPict('SB1','B1_LEADTI',3)
      	   @ 033, 130 SAY   OemToAnsi("Produção")    SIZE 030, 007 OF oDlg PIXEL
      	   @ 033, 160 MSGET oLeadTime Var M->B1_PRODUC Valid /*NaoVazio(M->B1_PRODUC) .AND. - AOM - 13/10/2011*/Eval(AVSX3("B1_PRODUC",AV_VALID)) SIZE 060, 010 OF oDlg PIXEL PICTURE PesqPict('SB1','B1_PRODUC',10)
         ENDIF
      EndIf

      If lLeadTime
         nLinTree := 043
      Else
         nLinTree := 033
      EndIf

      nLinBut  := 122
      If lLeadTime
         nLinTree := 047
         nLinBut  := 135
      EndIf

      If lLeadTime
         @ nLinTree , 008 TO 130, 258  LABEL '' OF oDlg  PIXEL
      Else
         @ nLinTree , 008 TO 115, 258  LABEL '' OF oDlg  PIXEL
      EndIf

      oTree := DbTree():New(nLinTree+7, 012, nLinTree+79, 252, oDlg,,,.T.)

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Defini‡„o dos Bot”es Utilizados                                        ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      //-- Inclus„o
      If nOpcX == 2 .Or. nOpcX == 5
      	DEFINE SBUTTON FROM nLinBut, 087 TYPE 4 DISABLE OF oDlg //-- Desabilita Inlus„o
      Else
      	DEFINE SBUTTON FROM nLinBut, 087 TYPE 4 ENABLE OF oDlg ;
      		ACTION If(!ldbTree .And. nOpcX < 4, .T., AVMa200Edita(nOpcX, oTree:GetCargo(), oTree, 3, @aUndo, @lMudou, @aAltEstru))
      EndIf

      //-- Altera‡„o
      If nOpcX == 2 .Or. nOpcX == 5  // PLB 04/10/06
      	DEFINE SBUTTON FROM nLinBut, 115 TYPE 11 DISABLE OF oDlg //-- Desabilita Alteração
      Else
         DEFINE SBUTTON FROM nLinBut, 115 TYPE 11 ENABLE OF oDlg ;
               ACTION If(!ldbTree .And. nOpcX < 4, .T., AVMa200Edita(nOpcX, oTree:GetCargo(), oTree, 4, {}, @lMudou, @aAltEstru))
      EndIf

      //-- Exclus„o
      If nOpcX == 2 .Or. nOpcX == 5
      	DEFINE SBUTTON FROM nLinBut, 143 TYPE 3 DISABLE OF oDlg //-- Desabilita Exclus„o
      Else
      	DEFINE SBUTTON FROM nLinBut, 143 TYPE 3 ENABLE OF oDlg ;
      		ACTION If(!ldbTree .And. nOpcX < 4, .T., AVMa200Edita(nOpcX, oTree:GetCargo(), oTree, 5, @aUndo, @lMudou, @aAltEstru))
      EndIf

      // 14.mai.2009 - UD719569 - Tratamento para botão 'visualizar'/'pesquisar' - HFD
      If nOpcX == 2 .or. nOpcX == 5 //#Visualizar
         DEFINE SBUTTON oButPosic FROM nLinBut, 171 TYPE 15 ENABLE OF oDlg ;
               ACTION If(!ldbTree .And. nOpcX < 4, .T., AVMa200Edita(nOpcX, oTree:GetCargo(), oTree))
            oButPosic:cToolTip:=OemToAnsi(STR0003) // 'Visualizar...'
      Else
         //-- Pesquisa e Posiciona
         DEFINE SBUTTON oButPosic FROM nLinBut, 171 TYPE 15 ENABLE OF oDlg ;
            	ACTION If(!ldbTree .And. nOpcX < 4, .T., AVMa200Posic(nOpcX, oTree:GetCargo(), oTree))
            oButPosic:cToolTip:=OemToAnsi(STR0030) // 'Pesquisar...'
            oButPosic:cCaption := "Pesquisa"
      EndIf

      //-- Confirma
      IF EYJ->(FieldPos("EYJ_LEADTI")) > 0  //LRS - 11/02/2014 - Validação para o lead time dentro da tabela EYJ
      	If nOpcX == 5
      		DEFINE SBUTTON FROM nLinBut, 199 TYPE 1 ENABLE OF oDlg ;
      		ACTION (AVMa200Del(cCodAtual), AVMa200Fecha(oDlg, oTree, nOpcX, .T., cUm, cCodigo, nQtdBase, cRevisao,If(lLeadTime,M->EYJ_LEADTI,), If(lLeadTime,M->EYJ_PRODUC,), .T., aAltEstru,cCodSim))
      	Else
      		DEFINE SBUTTON FROM nLinBut, 199 TYPE 1 ENABLE OF oDlg ;
        	ACTION If(AVBtn200Ok(aUndo, cCodigo) .And. ldbTree, AVMa200Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cCodigo, nQtdBase, cRevisao,If(lLeadTime,M->EYJ_LEADTI,), If(lLeadTime,M->EYJ_PRODUC,), .T., aAltEstru,cCodSim), .T.)
      	EndIf
      Else
        If nOpcX == 5
      		DEFINE SBUTTON FROM nLinBut, 199 TYPE 1 ENABLE OF oDlg ;
      		ACTION (AVMa200Del(cCodAtual), AVMa200Fecha(oDlg, oTree, nOpcX, .T., cUm, cCodigo, nQtdBase, cRevisao,If(lLeadTime,M->B1_LEADTI,), If(lLeadTime,M->B1_PRODUC,), .T., aAltEstru,cCodSim))
      	Else
      		DEFINE SBUTTON FROM nLinBut, 199 TYPE 1 ENABLE OF oDlg ;
      		ACTION If(AVBtn200Ok(aUndo, cCodigo) .And. ldbTree, AVMa200Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cCodigo, nQtdBase, cRevisao,If(lLeadTime,M->B1_LEADTI,), If(lLeadTime,M->B1_PRODUC,), .T., aAltEstru,cCodSim), .T.)
      	EndIf
      EndIF
		oTree:SetFocus()
      //-- Abandona
      IF EYJ->(FieldPos("EYJ_LEADTI")) > 0  //LRS - 11/02/2014 - Validação para o lead time dentro da tabela EYJ
      	 DEFINE SBUTTON FROM nLinBut, 227 TYPE 2 ENABLE OF oDlg ;
      	 ACTION (If(Len(aUndo)>0,AVMa200Undo(aUndo),.T.), AVMa200Fecha(oDlg, oTree, nOpcX, .F., cUm, cCodigo, nQtdBase, cRevisao,If(lLeadTime,M->EYJ_LEADTI,), If(lLeadTime,M->EYJ_PRODUC,), .F., aAltEstru))
      	 ACTIVATE MSDIALOG oDlg CENTERED ON INIT AVMa200Monta(oTree, oDlg, cCodAtual, cCodSim, cRevisao, nOpcX)
      ELSE
      	 DEFINE SBUTTON FROM nLinBut, 227 TYPE 2 ENABLE OF oDlg ;
      	 ACTION (If(Len(aUndo)>0,AVMa200Undo(aUndo),.T.), AVMa200Fecha(oDlg, oTree, nOpcX, .F., cUm, cCodigo, nQtdBase, cRevisao,If(lLeadTime,M->B1_LEADTI,), If(lLeadTime,M->B1_PRODUC,), .F., aAltEstru))
      	 ACTIVATE MSDIALOG oDlg CENTERED ON INIT AVMa200Monta(oTree, oDlg, cCodAtual, cCodSim, cRevisao, nOpcX)
      EndIF

      // Desabilita o F4 caso esteja ativo
      SETKEY(VK_F4,NIL)

   ELSE//lMSExecAuto

      lConfirma := .T.
      If Type('aEndEstrut')=="U"
      	Private aEndEstrut := {}
      EndIf
      aValidGet := {}
      cProduto  := aAutoCab[ProcP(aAutoCab,"G1_COD"),2]
      If nOpcx # 4
      	aAdd(aValidGet,{"cProduto"    ,cProduto+Space(Len(SG1->G1_COD)-Len(cProduto)),"AVA200Codigo(cProduto, @cUm, @cRevisao, @nQtdBase)",.t.})
      EndIf
      If nOpcx # 5 .And. !Empty(nPos := ProcP(aAutoCab,"G1_QUANT"))
      	Aadd(aValidGet,{"nQtdBase"    ,aAutoCab[nPos,2],"AVA200QBase(nQtdBase,"+Str(nOpcX)+", cProduto)",.t.})
      EndIf
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Faz a conistencia dos gets do cabecalho.                     ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If !SG1->(MsVldGAuto(aValidGet)) // consiste os gets
      	lRet := .f.
      EndIf

      Do Case
      //-- Inclusao
      Case lRet .And. nOpcx == 3
      	cCodAtual	:= cProduto
      	cCargo		:= cProduto + Space(TamSx3("G1_TRT")[1]) + cProduto + '000000000' + '000000000' + 'NOVO'
        IF LEN(aAutoItens) = 0
           EasyHelp("Na inclusao deve existir pelo menos um item.","Array aAutoItens vazia.")  
           lRet := .F.
        ENDIF
      	For nI:=1 To Len(aAutoItens)
      		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      		//³ Faz a validacao dos gets dos NOs(itens)                      ³
      		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      		lDbTree := .T. //Esta variavel somente foi setada para .T. para nao ser necessario alterar as validacoes dos gets
      		aValidGet := SG1->(MSArrayXDB(aAutoItens[nI],.T.,nOpcX))
            ///AWF - 07/07/2014 - Precisa iniciadas aqui as variaveis de memoria para ser usada na rotina MsVldGAuto(), senao ela usa os valores do item anterior para os campos em branco
            For nJ:=1 To Len(aValidGet)
               CriaVar(aValidGet[nJ,1],.F.)
               &('M->'+aValidGet[nJ,1]) := aValidGet[nJ,2]
            Next
            ///AWF - 07/07/2014
            If Empty(aValidGet) .Or. !SG1->(MsVldGAuto(aValidGet)) // consiste os gets
               lRet := .f.
               Exit
            EndIf
            lDbTree := .F. //Restaurada para false para evitar problemas de atualizacao de objetos

            // Atualiza Revisao Inicial
            nPosGet := aScan(aValidGet , {|x| Alltrim(x[1])=="G1_REVINI"})
            If nPosGet > 0
               cGetRevIni := aValidGet[nPosGet,2]
            EndIf
            nPosAut := aScan(aAutoItens[nI], {|x| Alltrim(x[1])=='G1_REVINI'})
            If nPosAut > 0
               cAutRevIni := aAutoItens[nI][nPosAut,2]
            EndIf
            If cGetRevIni <> cAutRevIni
               aValidGet[nPosGet,2] := Trim(cAutRevIni)
            EndIf

            // Atualiza Sequencia
            nPosGet := aScan(aValidGet , {|x| Alltrim(x[1])=="G1_TRT"})
            If nPosGet > 0
               cGetTrt := aValidGet[nPosGet,2]
            EndIf
            nPosAut := aScan(aAutoItens[nI], {|x| Alltrim(x[1])=='G1_TRT'})
            If nPosAut > 0
               cAutTrt := aAutoItens[nI][nPosAut,2]
            EndIf
            If nPosGet > 0 .And. nPosAut > 0 .And. cGetTrt <> cAutTrt
               aValidGet[nPosGet,2] := cAutTrt
            EndIf

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Cria variaveis de memoria para ser usada nas rotinas posteriores ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            ///AWF - 07/07/2014 - dexei aqui tb a inicializacao da memoria pq o aValidGet é alterado depois da validacao
            For nJ:=1 To Len(aValidGet)
               CriaVar(aValidGet[nJ,1],.F.)
               &('M->'+aValidGet[nJ,1]) := aValidGet[nJ,2]
            Next
            If nI > 1
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³ Emula o possicionamento do Gargo(GetGargo)do objeto dbTree   ³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               DbSelectArea("SG1")
               DbSetOrder(1)
               If MsSeek(xFilial("SG1")+M->G1_COD)
                  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                  //³ Caso encontre, possiciona o NO pai, capturando o Recno()     ³
                  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                  cCargo  := M->G1_COD + M->G1_TRT + M->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) +'CODI'
               Else
                  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                  //³ Se o pai nao existir informa um cargo com caracteristicas de ³
                  //³ um NO novo para ser usada a variavel cCodAtual como NO pai.  ³
                  //³ Neste caso as informacoes importantes sao: Recno Zero e stri-³
                  //³ ng 'NOVO', para utilizar a logica ja existente no Ma200Edita.³
                  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                  cCargo  := M->G1_COD + M->G1_TRT + M->G1_COMP + StrZero(0, 9) + StrZero(nIndex ++, 9) +'NOVO'
               EndIf
               cCodAtual := M->G1_COD
            EndIf
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Faz a inclusao do NO na estrutura a partir do cargo informado³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If !AVMa200Edita(nOpcX,cCargo,NIL,nOpcX,@aUndo,@lMudou,@aAltEstru,,,,@aPaiEstru)
               lRet := .f.
               Exit
            EndIf
         Next nI
		//-- Alteracao
		Case lRet .And. nOpcx == 4
			cCodAtual := cProduto
			cCargo 	  := SG1->(G1_COD+G1_TRT+G1_COMP+StrZero(Recno(),9)+StrZero(nIndex++,9)+'CODI')

			//-- Deleta componentes do primiero nivel nao recebidos na nova estrutura
            A200Auto4E(SG1->G1_COD,@aUndo,@lMudou,@aAltEstru,@aPaiEstru,.F.)

			For nI := 1 To Len(aAutoItens)
			
			    For nJ := 1 To Len(aAutoItens[nI])
			    	CriaVar(aAutoItens[nI,nJ,1],.F.)
			    	&('M->'+aAutoItens[nI,nJ,1]) := aAutoItens[nI,nJ,2]
				Next nJ

				//-- Para nao permitir o cadastro de itens que nao sejam da estrutura
				If cProduto # M->G1_COD .And.; //-- Verifica se o item pai neste no e o pai da estrutura
					aScan(aAutoItens,{|x| x[ProcP(aAutoItens[nI],"G1_COMP"),2] == M->G1_COD}) == 0 //-- Verifica se e componente em outro no
					EasyHelp("Estrutura incosistente: produto " +AllTrim(M->G1_COD) +" sem elo.","Atenção")
					lRet := .F.
					Exit
				EndIf

				//-- Seta nOpcx para execucao de axInclui ou axAltera
				SG1->(dbSetOrder(1))
				If SG1->(MsSeek(xFilial("SG1")+M->G1_COD+M->G1_COMP+M->G1_TRT))//AWF - 23/05/2014
					nOpcx := 4
					//-- Emula preenchimento da cCargo (ja que nao ha tree) para uso das funcoes
					cCargo  := SG1->(G1_COD+G1_TRT+G1_COMP+StrZero(Recno(),9)+StrZero(nIndex++,9)+'COMP')
					T_CARGO := SG1->(G1_COD+G1_TRT+G1_COMP+StrZero(Recno(),9)+StrZero(nIndex++,9)+'COMP')
				Else
					nOpcx := 3
					//-- Emula preenchimento da cCargo (ja que nao ha tree) para uso das funcoes
					cCargo  := M->G1_COD+M->G1_TRT+M->G1_COMP+StrZero(0,9)+StrZero(nIndex++,9)+'NOVO'
					T_CARGO := M->G1_COD+M->G1_TRT+M->G1_COMP+StrZero(0,9)+StrZero(nIndex++,9)+'NOVO'
				EndIf

				//-- Monta array com os campos da SG1 a serem validados
				AADD(aAutoItens[nI],{"INDEX",2,NIL})//AWF - 07/05/2014 - Essa linha a mais no aAutoItens é para a funcao MSArrayXDB() validar a chave da tebela pelo indice 2 G1_COD+G1_COMP somente
				aValidGet := SG1->(MSArrayXDB(aAutoItens[nI],.T.,nOpcX))

				//-- Cria variaveis de memoria para serem usadas nas rotinas posteriores
				For nJ := 1 To Len(aValidGet)
				   CriaVar(aValidGet[nJ,1],.F.)
					&('M->'+aValidGet[nJ,1]) := aValidGet[nJ,2]
				Next nJ

				//-- Faz a validacao dos gets dos NOs(itens)
				lDbTree := .T. //Esta variavel somente foi setada para .T. para nao ser necessario alterar as validacoes dos              
				If Empty(aValidGet) .Or. !SG1->(MsVldGAuto(aValidGet))
					lRet := .F.
					Exit
				EndIf
				lDbTree := .F. //Restaurada para false para evitar problemas de atualizacao de objetos

				cCodAtual := M->G1_COD

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Faz a inclusao do NO na estrutura a partir do cargo informado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !AVMa200Edita(nOpcX,cCargo,NIL,nOpcX,@aUndo,@lMudou,@aAltEstru,,,,@aPaiEstru,aAutoItens[nI])
					lRet := .f.
					Exit
				EndIf
			Next nI
		//-- Exclusao
		Case lRet .And. nOpcx == 5
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui todos os G1_COD iguais ao cProduto (alimentado somente³
			//³ pelo array do cabecalho, onde sera obrigatorio apenas passar |
			//³ o codigo do Produto (G1_COD) que deseja excluir.             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRet := AVMa200Del(cProduto)
		EndCase
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao ocorreu nenhum erro, finaliza o processo, caso contra-³
		//³ rio restaura a situacao anterior a execucao da rotina automa-|
		//³ tica.                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
          //AVMa200Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cCodigo , nQtdBase, cRevisao, nLeadTime                                     , nProduc                                           , lConfirma, aAltEstru,cCodSim,aKey, aBKey, aUndo,aPaiEstru)
          //AVMa200Fecha(oDlg, oTree, nOpcX, .F., cUm, cCodigo, nQtdBase, cRevisao,If(lLeadTime,M->EYJ_LEADTI,)                       ,If(lLeadTime,M->EYJ_PRODUC,)                       , .F.      , aAltEstru)
			AVMA200Fecha(oDlg, oTree, nOpcX, .T., cUm, cCodigo, nQtdBase, cRevisao,If(lLT_EIJ,M->EYJ_LEADTI,IF(lLT_SB1,M->B1_LEADTI,)),If(lLT_EIJ,M->EYJ_PRODUC,IF(lLT_SB1,M->B1_LEADTI,)), .F.      , aAltEstru,cCodSim,    ,      , aUndo,aPaiEstru)
		Else
			AVMA200Undo(aUndo)
		EndIf

      EndIf//lMSExecAuto

EndIf//lRet

//-- Reinicializa Variaveis
cInd5     := ''
ldbTree   := .F.
cValComp  := Replicate('ú', Len(SG1->G1_COD)) + 'ú'
cCodAtual := Replicate('ú', Len(SG1->G1_COD))

RestArea(aAreaAnt)

Return .T.

*=====================================================*
Static Function ProcP(aPilha,cCampo)
*=====================================================*
Return aScan(aPilha,{|x|Trim(x[1])== cCampo })

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AVMa200Monta ³Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Montagem do Arquivo Temporario para o Tree(Func.Recurssiva)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVMa200Monta(ExpO1, ExpO2, ExpC1, ExpN1, ExpC2)             ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False se o Codigo do Produto nao existir, e True em C.C.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto Tree                                        ³±±
±±³          ³ ExpO2 = Objeto Dlg                                         ³±±
±±³          ³ ExpC1 = Codigo do Produto                                  ³±±
±±³          ³ ExpN1 = Numero da Op‡„o Escolhida                          ³±±
±±³          ³ ExpC2 = Cargo do Produto no Tree                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVMa200Monta(oTree, oDlg, cCodigo, cCodSim, cRevisao, nOpcX, cCargo, cTRTPai)

Local nRecAnt    := 0
Local cComp      := ''
Local cPrompt    := ''
Local cFolderA   := 'FOLDER5'
Local cFolderB   := 'FOLDER6'
Local nRecCargo  := 0
Local dValIni    := CtoD('  /  /  ')
Local dValFim    := CtoD('  /  /  ')

nOpcX := If(nOpcX==Nil, 0, nOpcX) // LRS - 7/4/2014 - Atualizar a estrutura ao clicar em visualizar
If !ldbTree .And. nOpcX < 4 .And. oTree:Total()>0
   oDlg:SetFocus() 
   Return .F. 
EndIf
//If !ldbTree .And. nOpcX < 4 
	//oDlg:SetFocus()
    //Return .F.
//EndIf

//-- Posiciona no SB1
cPrompt := cCodigo + Space(33)
(cAliasSB1)->(dbSetOrder(1))
If (cAliasSB1)->(dbSeek(xFilial() + cCodigo, .F.))
	cPrompt := AllTrim(cCodigo)
	cPrompt += ' - ' + PadR(AllTrim((cAliasSB1)->B1_DESC), 30)
	cPrompt += Space((Len(AllTrim(cCodigo))-Len(cCodigo)) + (Len(AllTrim((cAliasSB1)->B1_DESC)) - 30))
Endif	

SG1->(dbSetOrder(1))
If nOpcX == 3 .And. cCodigo # Replicate('ú', Len(SG1->G1_COD)) .And. Empty(cCodSim) //alterando .F.

	//-- Cria‡„o de uma nova estrutura
	DBADDTREE oTree PROMPT AVA200Prompt(cPrompt, "") OPENED RESOURCE cFolderA, cFolderB CARGO cCodigo + Space(3) + cCodigo + '000000000' + '000000000' + 'NOVO'
	DBENDTREE oTree
	oTree:Refresh()
	oTree:SetFocus()
	Return .T.

ElseIf !SG1->(dbSeek(xFilial('SG1') + cCodigo, .F.))
	If ldbTree
		oTree:Refresh()
		oTree:SetFocus()
	Else
		oDlg:SetFocus()
	EndIf
	Return .F.
EndIf

cTRTPai := If(cTRTPai==Nil,SG1->G1_TRT,cTRTPai)

dValIni := SG1->G1_INI
dValFim := SG1->G1_FIM
If cCargo == Nil
	cCargo := SG1->G1_COD + cTRTPai + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'CODI'
ElseIf (nRecCargo := Val(SubStr(cCargo,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))) > 0
	nRecAnt := SG1->(Recno())
	SG1->(dbGoto(nRecCargo))
	dValIni := SG1->G1_INI
	dValFim := SG1->G1_FIM
	SG1->(dbGoto(nRecAnt))
EndIf

//-- Define as Pastas a serem usadas
cFolderA := 'FOLDER5'
cFolderB := 'FOLDER6'
If Right(cCargo, 4) == 'COMP' .And. ;
	(dDataBase < dValIni .Or. dDataBase > dValFim)
	cFolderA := 'FOLDER7'
	cFolderB := 'FOLDER8'
EndIf


//-- Adiciona o Pai na Estrutura
DBADDTREE oTree PROMPT AVA200Prompt(cPrompt, cCargo) OPENED RESOURCE cFolderA, cFolderB CARGO cCargo

Do While !SG1->(Eof()) .And. SG1->G1_COD == cCodigo .AND. xFilial('SG1') == SG1->G1_FILIAL

	//-- Nao Adiciona Componentes fora da Revis„o
	If nOpcX == 2 .And. (cRevisao # Nil) .And. ;
		!(SG1->G1_REVINI <= cRevisao .And. SG1->G1_REVFIM >= cRevisao)
		SG1->(dbSkip())
		Loop
	EndIf

	nRecAnt := SG1->(Recno())
	cComp   := SG1->G1_COMP
	cCargo  := SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'

	//-- Define as Pastas a serem usadas
	cFolderA := 'FOLDER5'
	cFolderB := 'FOLDER6'
	If dDataBase < SG1->G1_INI .Or. dDataBase > SG1->G1_FIM
		cFolderA := 'FOLDER7'
		cFolderB := 'FOLDER8'
	EndIf

	//-- Posiciona no SB1
	cPrompt := cComp + Space(33)
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial('SB1') + cComp, .F.))
		cPrompt := AllTrim(cComp)
		cPrompt += ' - ' + PadR(AllTrim(SB1->B1_DESC), 30)
		cPrompt += Space((Len(AllTrim(cComp))-Len(cComp)) + (Len(AllTrim(SB1->B1_DESC)) - 30))
	EndIf

	If SG1->(dbSeek(xFilial('SG1') + SG1->G1_COMP, .F.))
		//-- Adiciona um Nivel a Estrutura
		AVMa200Monta(oTree, oDlg, SG1->G1_COD, '', IIF(lPCPREVATU, PCPREVATU(SB1->B1_COD), SB1->B1_REVATU), If(nOpcX==3,0,nOpcX), cCargo, cTRTPai)
	Else
		//-- Adiciona um Componente a Estrutura
		DBADDITEM oTree PROMPT AVA200Prompt(cPrompt, cCargo) RESOURCE cFolderA CARGO cCargo
	EndIf

	SG1->(dbGoto(nRecAnt))
	SG1->(dbSkip())
EndDo

DBENDTREE oTree

If ldbTree
	oTree:Refresh()
	oTree:SetFocus()
Else
	oDlg:SetFocus()
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AVMa200ATree³Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Adiciona Componentes ao Tree existente (Func.Recurssiva)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVMa200ATree(ExpO1, ExpO2, ExpC1, ExpN1, ExpC2)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False se o Codigo do Produto nao existir, e True em C.C.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto Tree                                        ³±±
±±³          ³ ExpO2 = Objeto Dlg                                         ³±±
±±³          ³ ExpC1 = Codigo do Produto                                  ³±±
±±³          ³ ExpN1 = Numero da Op‡„o Escolhida                          ³±±
±±³          ³ ExpC2 = Cargo do Produto no Tree                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVMa200ATree(oTree, cCodigo, cCargo, cTRTPai)

Local aAreaAnt   := GetArea()
Local nRecAnt    := 0
Local cComp      := ''
Local cPrompt    := ''
Local cFolderA   := 'FOLDER5'
Local cFolderB   := 'FOLDER6'
Local dValIni    := CtoD('  /  /  ')
Local dValFim    := CtoD('  /  /  ')
Local nRecCargo  := 0
Local cCargoPai  := ''

cTRTPai := If(cTRTPai==Nil,SG1->G1_TRT,cTRTPai)

dValIni := SG1->G1_INI
dValFim := SG1->G1_FIM
If cCargo == Nil
	cCargo := SG1->G1_COD + cTRTPai + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'
ElseIf (nRecCargo := Val(SubStr(cCargo,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))) > 0
	nRecAnt := SG1->(Recno())
	SG1->(dbGoto(nRecCargo))
	dValIni := SG1->G1_INI
	dValFim := SG1->G1_FIM
	SG1->(dbGoto(nRecAnt))
EndIf

//-- Define as Pastas a serem usadas
cFolderA := 'FOLDER5'
cFolderB := 'FOLDER6'
If Right(cCargo, 4) == 'COMP' .And. ;
	(dDataBase < dValIni .Or. dDataBase > dValFim)
	cFolderA := 'FOLDER7'
	cFolderB := 'FOLDER8'
EndIf

//-- Posiciona no SB1
cPrompt := cCodigo + Space(33)
(cAliasSB1)->(dbSetOrder(1))
SB1->(dbSetOrder(1))

If (cAliasSB1)->(dbSeek(xFilial() + cCodigo, .F.))
	cPrompt := AllTrim(cCodigo)
	cPrompt += ' - ' + PadR(AllTrim((cAliasSB1)->B1_DESC), 30)
	cPrompt += Space((Len(AllTrim(cCodigo))-Len(cCodigo)) + (Len(AllTrim((cAliasSB1)->B1_DESC)) - 30))
Elseif SB1->(dbSeek(xFilial() + cCodigo, .F.))
	cPrompt := AllTrim(cCodigo)
	cPrompt += ' - ' + PadR(AllTrim(SB1->B1_DESC), 30)
	cPrompt += Space((Len(AllTrim(cCodigo))-Len(cCodigo)) + (Len(AllTrim(SB1->B1_DESC)) - 30))
EndIf

//-- Adiciona o Componente na Estrutura
oTree:AddItem(AVA200Prompt(cPrompt, cCargo), cCargo, cFolderA, cFolderB,,, 2)
oTree:TreeSeek(cCargo)
cCargoPai := cCargo

//-- Se o Componente for Pai, Adiciona sua Estrutura
SG1->(dbSetOrder(1))
If SG1->(dbSeek(xFilial('SG1') + cCodigo, .F.))
	Do While !SG1->(Eof()) .And. SG1->G1_COD == cCodigo
		nRecAnt := SG1->(Recno())
		cComp   := SG1->G1_COMP
		cCargo  := SG1->G1_COD + cTRTPai + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'

		//-- Define as Pastas a serem usadas
		cFolderA := 'FOLDER5'
		cFolderB := 'FOLDER6'
		If dDataBase < SG1->G1_INI .Or. dDataBase > SG1->G1_FIM
			cFolderA := 'FOLDER7'
			cFolderB := 'FOLDER8'
		EndIf

		//-- Posiciona no SB1
		cPrompt := cComp + Space(33)
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial('SB1') + cComp, .F.))
			cPrompt := AllTrim(cComp)
			cPrompt += ' - ' + PadR(AllTrim(SB1->B1_DESC), 30)
			cPrompt += Space((Len(AllTrim(cComp))-Len(cComp)) + (Len(AllTrim(SB1->B1_DESC)) - 30))
		EndIf

		If SG1->(dbSeek(xFilial('SG1') + SG1->G1_COMP, .F.))
			//-- Adiciona um Nivel a Estrutura
			AVMa200ATree(oTree, SG1->G1_COD, cCargo, cTRTPai)
			oTree:TreeSeek(cCargoPai)
		Else
			//-- Adiciona um Componente a Estrutura
			oTree:AddItem(AVA200Prompt(cPrompt, cCargo), cCargo, cFolderA, cFolderB,,, 2)
		EndIf

		SG1->(dbGoto(nRecAnt))
		SG1->(dbSkip())
	EndDo
EndIf

oTree:Refresh()
oTree:SetFocus()

RestArea(aAreaAnt)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AVMa200Edita ³Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Edi‡„o dos Itens da Estrutura                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVMa200Edita(ExpN1, ExpC1, ExpO1, ExpN2, ExpA1)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Op‡„o da Edi‡„o                                    ³±±
±±³          ³ ExpC1 = Chave do Registro                                  ³±±
±±³          ³ ExpO1 = Objeto Tree                                        ³±±
±±³          ³ ExpN2 = Op‡„o escolhida no Bot„o                           ³±±
±±³          ³ ExpA1 = Array com os Recnos dos Componentes Incl/Excl      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Function AVMa200Edita(nOpcX, cCargo, oTree, nOpcY, aUndo, lMudou, aAltEstru, nQtdBase)
Function AVMa200Edita(  nOpcX, cCargo, oTree, nOpcY, aUndo, lMudou, aAltEstru, nQtdBase, aKey, aBKey, aPaiEstru , aAuto)

Local aAreaAnt   := GetArea()
Local aAreaSG1   := SG1->(GetArea())
Local nRecno	 := 0
Local nPos       := 0
Local nX         := 0
Local lInclui    := (nOpcY==3 .And. nOpcX#2)
Local lAltera    := (nOpcY==4 .And. nOpcX#2)
Local lExclui    := (nOpcY==5 .And. nOpcX#2)
Local lRet       := .T.
Local cTipo      := ''
Local nUndoRecno := 0
Local cFolderA   := 'FOLDER5'
Local cFolderB   := 'FOLDER6'
Local aDescend   := {}
Local cCargoPai  := ''
Local aOrd       := SaveOrd({"ED7"})
Local nCont
Local nCont2
Local nQtdProd   := 0
Local aAtuEstrut := {}
Local aReplic    := {}

//-- Variaveis utilizadas nos Ax's
Private aAlter     := {}
Private aAcho      := {}
Private cDelFunc   := 'AVa200TudoOk("E")'
Private lDelFunc   := .T.
Private cCodPai    := ''
If Type('aEndEstrut')=="U"
	Private aEndEstrut := {}
EndIf

aUndo := If(aUndo==Nil,{},aUndo)

//-- Variaveis do Componente Tree referentes ao registro Atual
nRecno := Val(SubStr(cCargo,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))
cTipo  := Right(cCargo,4)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta do Array aAcho os campos que n„o devem aparecer       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AVa200Fields(@aAcho)
If (nPos := aScan(aAcho, {|x| 'G1_FILIAL' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_COD'    $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_NIV'    $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_NIVINV' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf                                                      

// 14.mai.2009 - UD719636/37 - Campos que não devem aparecer - HFD
If (nPos := aScan(aAcho, {|x| 'G1_GROPC' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_OPC' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
If (nPos := aScan(aAcho, {|x| 'G1_OK' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf
/*
// 15.mai.2009 - ED719578 - Campo descrição deve aparecer sempre - HFD
If !lInclui
	If (nPos := aScan(aAcho, {|x| 'G1_DESC' $ Upper(x)})) > 0
		aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
	EndIf
EndIf
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta do Array aAlter os campos que n„o devem ser alterados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAlter := aClone(aAcho)
If lAltera .And. (nPos := aScan(aAlter, {|x| 'G1_COMP' $ Upper(x)})) > 0
	aDel(aAlter, nPos); aSize(aAlter, Len(aAlter)-1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona o SG1 no registro a ser editado                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo # 'NOVO' .And. nRecno <= 0
	Help(' ', 1, 'CODNEXIST')
	RestArea(aAreaAnt)
	lRet:= .F.
EndIf

dbSelectArea('SG1')
dbSetOrder(1)
dbGoto(If(nRecno>0,nRecno,aAreaSG1[3]))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³N„o edita o Pai                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. !lInclui .And. (cTipo == 'CODI' .Or. cTipo == 'NOVO')
	Help(' ',1,'REGNOIS') //-- Help NAO PODE EDITAR O PAI
	RestArea(aAreaAnt)
	lRet	:= .F.
EndIf

If lRet
   cCodPai   := If(nRecno>0,If(cTipo=='CODI',SG1->G1_COD,SG1->G1_COMP),cCodAtual)
   If lMSExecAuto
		If lInclui
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SetStartMod(.T.)
			If AxIncluiAuto(Alias(), 'AVa200TudoOk("I")') == 1
				lMudou := .T.
				Begin Transaction
					RecLock('SG1', .F.)
					Replace G1_COD With cCodPai
					MsUnlock()
				End Transaction
				If aScan(aUndo, {|x| x[1]==Recno()}) == 0
					aAdd(aUndo, {Recno(), 1}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
				EndIf
				//-- Carrega o array para efetuar a revisao inicial e final de forma automatica
/*		If lRevAut
					For nX := 1 To IIF(Len(aPaiEstru)=0,1,Len(aPaiEstru))
						If aScan(aPaiEstru, {|x| x[1]==SG1->G1_COD}) == 0
							aAdd(aPaiEstru,{SG1->G1_COD,.T.})
						ElseIF aPaiEstru[nX][1] == SG1->G1_COD
							aPaiEstru[nX][2] := .T.
						EndIf
					Next nX
				EndIf*/
			Else
				lRet	:= .F.
			EndIf
		ElseIf lAltera
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Guarda o Status inicial do Registro ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCampos := {}
			If aScan(aUndo, {|x| x[1]==Recno()}) == 0
				For nX := 1 To FCount()
					aAdd(aCampos, FieldGet(nX))
				Next nX
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SetStartMod(.T.)
			If AxAltera(Alias(),Recno(),4,aAcho,aAlter,,,'AVa200TudoOk("A")',,,,,aAuto) == 1

				If aScan(aUndo, {|x| x[1]==Recno()}) == 0
					aAdd(aUndo, {Recno(), 3, aCampos}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
				EndIf

				//-- Alimenta Array com a Descendˆncia dos Produtos Alterados
				If Len(aDescend) > 0
					For nX := 1 to Len(aDescend)
						If aScan(aAltEstru, aDescend[nX]) == 0
							aAdd(aAltEstru, aDescend[nX])
						EndIf
					Next nX
				EndIf
			Else
				lRet	:= .F.
			EndIf
		ElseIf lExclui
			nUndoRecno := Recno()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SetStartMod(.T.)
			//If !lRevAut
				If AxDeleta(Alias(),Recno(),5,,,,,aAuto) == 2
					If lDelFunc
						lMudou := .T.
						If (nPos := aScan(aUndo,{|x| x[1] == nUndoRecno})) == 0
							aAdd(aUndo,{nUndoRecno,2}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
						Else
							aUndo[nPos,2] := 2
						EndIf
						//-- Alimenta Array com a Descendˆncia dos Produtos Alterados
						If Len(aDescend) > 0
							For nX := 1 to Len(aDescend)
								If aScan(aAltEstru, aDescend[nX]) == 0
									aAdd(aAltEstru, aDescend[nX])
								EndIf
							Next nX
						EndIf
					EndIf
				Else
					lRet := .F.
				EndIf
			//EndIf
		EndIf

	Else

           cCargoPai := oTree:GetCargo()

           If nOpcX == 3 .Or. nOpcX == 4	//-- Inclui ou Altera
           	aDescend := {}
           	AVa200enDesc(@cValComp, @aDescend, oTree)
           	If lInclui
           		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
           		//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
           		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           		SetStartMod(.T.)
           		If AxInclui(Alias(), Recno(), 3, aAcho,, aAlter, 'AVa200TudoOK("I")') == 1
           			lMudou := .T.
           			Begin Transaction
           				RecLock('SG1', .F.)
           				Replace G1_COD With cCodPai
           				MsUnlock()
           			End Transaction
//         			aAdd(aUndo, Recno())
					If aScan(aUndo, {|x| x[1]==Recno()}) == 0
						aAdd(aUndo, {Recno(), 1}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
					EndIf
           			If cTipo == 'NOVO'
           				oTree:DelItem()
           				AVMa200ATree(oTree, SG1->G1_COD, SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()),9) + StrZero(nIndex ++, 9) + 'CODI')
           			Else
           				AVMa200ATree(oTree, SG1->G1_COMP, SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()),9) + StrZero(nIndex ++, 9) + 'COMP')
           			EndIf
           			oTree:TreeSeek(cCargoPai)
           		EndIf
           	ElseIf lAltera
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Guarda o Status inicial do Registro ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCampos := {}
				If aScan(aUndo, {|x| x[1]==Recno()}) == 0
					For nX := 1 To FCount()
						aAdd(aCampos, FieldGet(nX))
					Next nX
				EndIf
           		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
           		//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
           		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   M->G1_DESC := AVA200Desc(SG1->G1_COMP)
           		SetStartMod(.T.)
           		If AxAltera(Alias(), Recno(), 4, aAcho, aAlter,,, 'AVa200TudoOk("A")') == 1

					If aScan(aUndo, {|x| x[1]==Recno()}) == 0
						aAdd(aUndo, {Recno(), 3, aCampos}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
					EndIf
           			//-- Alimenta Array com a Descendˆncia dos Produtos Alterados
           			If Len(aDescend) > 0
           				For nX := 1 to Len(aDescend)
           					If aScan(aAltEstru, aDescend[nX]) == 0
           						aAdd(aAltEstru, aDescend[nX])
           					EndIf
           				Next nX
           			EndIf

           			//-- Define as Pastas a serem usadas
           			cFolderA := 'FOLDER5'
           			cFolderB := 'FOLDER6'
           			If Right(oTree:GetCargo(), 4) == 'COMP' .And. ;
           				(dDataBase < SG1->G1_INI .Or. dDataBase > SG1->G1_FIM)
           				cFolderA := 'FOLDER7'
           				cFolderB := 'FOLDER8'
           			EndIf
           			oTree:ChangeBMP(cFolderA, cFolderB)

           			//WFS 09/10/09 - tratamento para atualizar o produto da estrutura que consta no cadastro de Itens Alternativos
           			If EasyGParam("MV_AVG0185",.F.,.F.)
           			   //Armazena a quantidade do item
                          //nQtdProd:= SG1->G1_QUANT

           			   aReplic := {}
           			   For nCont:= 1 to Len(aAlter)
                             aAdd(aReplic,{aAlter[nCont],SG1->&(aAlter[nCont])})
           			   Next

                          //Procura o produto principal na tabela ED7 e armazena os produtos com a estrutura dependente
           			   //Itens alternativos do tipo Exportação
                          ED7->(DBSetOrder(2)) //ED7_FILIAL + ED7_TPITEM + ED7_DE + ED7_PD
                          If ED7->(DBSeek(xFilial() + "E" + AvKey(ATail(aDescend), "ED7_DE")))
           			      While ED7->(!Eof()) .And.;
           			            ED7->(xFilial()) == ED7->ED7_FILIAL .And.;
           			            AllTrim(ATail(aDescend)) == AllTrim(ED7->ED7_DE)

            			         If aScan(aAtuEstrut, ED7->ED7_PARA) == 0
           			            AAdd(aAtuEstrut, ED7->ED7_PARA)
           			         EndIf

                                ED7->(DBSkip())
            			      EndDo
           			   EndIf

           			   //SG1 ordem 1: G1_FILIAL + G1_COD + G1_COMP + G1_TRT
           			   //Atualizando a tabela SG1
           			   For nCont:= 1 To Len(aAtuEstrut)
           			      If SG1->(DBSeek(xFilial() + AvKey(aAtuEstrut[nCont], "G1_COD") + AvKey(aDescend[1], "G1_COMP")))
           			         SG1->(RecLock("SG1", .F.))
              			         For nCont2:=1 To Len(aReplic)
              			            FieldPut(FieldPos(aReplic[nCont2][1]),aReplic[nCont2][2])
           			         Next
           			         SG1->(MsUnlock())
           			      EndIf
           			   Next
           		    EndIf
           		EndIf

           	ElseIf lExclui
           		nUndoRecno := Recno()
           		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
           		//³Comando utilizado para habilitar chamada do PE generico em cada chamada ³
           		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           		M->G1_DESC := AVA200Desc(SG1->G1_COMP)
           		SetStartMod(.T.)

           	    // 15.mai.2009 - ED719561 - Confirmação de exclusão e redefinição dos campos visíveis - HFD
           	    If AxDeleta(Alias(), Recno(), 5, aAcho, aAlter) == 2
                      if MsgYesNo(STR0037,STR0038)
           		      If lDelFunc
           				lMudou := .T.
//         				aAdd(aUndo, nUndoRecno)
							nPos:=aScan(aUndo, {|x| x[1]==nUndoRecno})
							If nPos == 0
								aAdd(aUndo, {nUndoRecno, 2}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
							Else
								aUndo[nPos,2]:=2
							EndIf
           				oTree:DelItem()
           				oTree:Refresh()
           				oTree:SetFocus()
           			  EndIf
           		   EndIf
           		EndIf
           	EndIf

           ElseIf nOpcX == 2 .Or. nOpcX == 5 //-- Visualiza ou Exclui
           	M->G1_DESC := AVA200Desc(SG1->G1_COMP)
           	AxVisual(Alias(), Recno(), 2, aAcho)
           EndIf

   ENDIF

ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua o EndEstrut2 apos o End Transaction                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. Len(aEndEstrut) > 0
	For nX := 1 to Len(aEndEstrut)
		AvFimEstrut2(aEndEstrut[nX,1],aEndEstrut[nX,2])
   Next nX
   aEndEstrut := {}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Area de trabalho.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaAnt)
RestOrd(aOrd)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±³                   ROTINAS DE CRITICA DE CAMPOS                        ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AVa200Codigo ³Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡„o do C¢digo do Produto na Estrutura                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVA200Codigo(ExpC1, ExpC2, ExpC3)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True para C¢digos Validos e False para C¢digos Inv lidos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = C¢digo a ser Validado                              ³±±
±±³          ³ ExpC2 = Unidade de Medida a ser Atualizada                 ³±±
±±³          ³ ExpC3 = Numero da Revis„o a ser atualizado                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVA200Codigo(cCodigo, cUm, cRevisao, nQtdBase, oUm, oRevisao, oQtdBase, oDlg, cAlias)

Local aAreaAnt   := GetArea()
Local aAreaSB1   := (cAliasSB1)->(GetArea())
//Local aAreaEYJ   := (cAliasEYJ)->(GetArea()) //LRS 11/02/2014 - Validação para o lead time dentro da tabela EYJ
Local aAreaSG1   := SG1->(GetArea())
Local cSeek      := ''
Local lRet       := .T.
Local cAliasSB1Exp := cAliasSB1 
Local cFilSB1Exp   := cFilSB1Aux

If cAlias = NIL
   aAreaSB1         := SB1->(GetArea())
   cAliasSB1Exp     := 'SB1'
   cFilSB1Exp       := xFilial('SB1')	
Endif

(cAliasSB1Exp)->(dbSetOrder(1))
If !(cAliasSB1Exp)->(dbSeek(cFilSB1Exp + cCodigo, .F.))
	Help(' ',1, 'NOFOUNDSB1')
	lRet := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura Area de trabalho.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea(aAreaSG1)
	RestArea(aAreaSB1)
	RestArea(aAreaAnt)

	Return lRet
Else
	cUm      := (cAliasSB1Exp)->B1_UM
	cRevisao :=  IIF(lPCPREVATU, PCPREVATU((cAliasSB1Exp)->B1_COD), (cAliasSB1Exp)->B1_REVATU )
	nQtdBase := (cAliasSB1Exp)->B1_QB
	If oUm # Nil
		oUm:Refresh()
	EndIf
	If oRevisao # Nil
		oRevisao:Refresh()
	EndIf
	If oQtdBase # Nil
		oQtdBase:Refresh()
	EndIf
EndIf

If !ldbTree
	If oDlg # Nil
		oDlg:Refresh()
	EndIf
	SG1->(dbSetOrder(1))
	If SG1->(dbSeek(xFilial('SG1') + cCodigo, .F.))
		Help(' ',1, 'CODEXIST')
		lRet := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura Area de trabalho.                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RestArea(aAreaSG1)
		RestArea(aAreaSB1)
		RestArea(aAreaAnt)

		Return lRet
	EndIf

	SG1->(dbSetOrder(2))
	If SG1->(dbSeek(cSeek := xFilial('SG1') + cCodigo, .F.))
		Do While !SG1->(Eof()) .And. SG1->G1_FILIAL + SG1->G1_COMP == cSeek
			If SG1->G1_QUANT < 0 //.And. !EasyGParam('MV_NEGESTR')
				Help(' ',1,'A200NAOINC')
				lRet := .F.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Restaura Area de trabalho.                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RestArea(aAreaSG1)
				RestArea(aAreaSB1)
				RestArea(aAreaAnt)

				Return lRet
			EndIf
			SG1->(dbSkip())
		EndDo
	EndIf
EndIf

If lRet
	If EasyEntryPoint("MT200PAI")
		lRet:=ExecBlock("MT200PAI",.F.,.F.,cCodigo)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Area de trabalho.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSG1)
RestArea(aAreaSB1)
RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AVa200CodSim ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Estrutura Similar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVa200CodSim(ExpC1, ExpC2)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True se a Estrutura Silinar for Validada, ou False ne n„o. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = C¢digo do Produto                                  ³±±
±±³          ³ ExpC2 = C¢digo do Produto Similar                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVA200CodSim(cCodigo, cCodSim, aUndo)


Local aAreaAnt   := GetArea()
Local aAreaSB1   := SB1->(GetArea())
Local aAreaSG1   := SG1->(GetArea())
Local cNomeArq   := ''
// Local lRet       := .T., nAchou     := 0 -- ACSJ - 01/12/2004 - Variavel não é usada.

Private nEstru     := 0

If Empty(cCodSim)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura Area de trabalho.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea(aAreaSG1)
	RestArea(aAreaSB1)
	RestArea(aAreaAnt)

	Return .T.
EndIf

SB1->(dbSetOrder(1))
If !SB1->(dbSeek(xFilial('SB1') + cCodSim))
	Help(' ',1,'NOFOUNDSB1')
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura Area de trabalho.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea(aAreaSG1)
	RestArea(aAreaSB1)
	RestArea(aAreaAnt)

	Return .F.
EndIf

SG1->(dbSetOrder(1))
If !SG1->((dbSeek(xFilial('SG1') + cCodSim)))
	Help(' ',1,'ESTNEXIST')
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura Area de trabalho.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea(aAreaSG1)
	RestArea(aAreaSB1)
	RestArea(aAreaAnt)

	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o produto similar n„o contem o      ³
//³ produto principal em sua estrutura.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeArq := AVEstrut2(cCodSim)
dbSelectArea('ESTRUT')
ESTRUT->(dbGotop())
Do While !ESTRUT->(Eof())
	If ESTRUT->COMP == cCodigo
		Help(' ',1,'SIMINVALID')
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura Area de trabalho.                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RestArea(aAreaSG1)
		RestArea(aAreaSB1)
		RestArea(aAreaAnt)

		Return .F.
	EndIf
	ESTRUT->(dbSkip())
EndDo
AvFimEstrut2(Nil,cNomeArq)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Area de trabalho.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSG1)
RestArea(aAreaSB1)
RestArea(aAreaAnt)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera Registros da Estrutura Similar                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AVMa200GrSim(cCodigo, cCodSim, @aUndo)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AVa200GetRev  ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Indica se d  Get na revisÆo da estrutura ou n„o            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVa200GetRev(ExpL1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Variavel Làgica a ser atualizada na fun‡„o         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVA200GetRev(lGetRevisao, oDlg, oTree, cCodigo, cRevisao, nOpcX)

lGetRevisao := !lGetRevisao

If oTree:Total()>0 // LRS - 7/4/2014 - Atualizar a estrutura ao clicar em visualizar
   oTree:Reset()
EndIf 

ldbTree   := .T.
cCodAtual := cCodigo
cValComp  := cCodigo + 'ú'
AVMa200Monta(oTree, oDlg, cCodAtual, '', cRevisao, nOpcX)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AVA200QBase ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consiste a Quantidade Basica da Estrutura                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVA200QBase(ExpN1, ExpN2, ExpO1, ExpO2)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True se a Quantidade Base for Maior que Zero, ou False C.C.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Quantidade Basica Digitada                         ³±±
±±³          ³ ExpN2 = Op‡„o Escolhida                                    ³±±
±±³          ³ ExpN1 = Objeto Tree                                        ³±±
±±³          ³ ExpN1 = Objeto Dlg                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVA200QBase(nQtdBase, nOpcX, cCodigo, cCodSim, oTree, oDlg)

If QtdComp(nQtdBase) < QtdComp(0) //.And. !EasyGParam('MV_NEGESTR')
	Help(' ',1,'MA200QBNEG')
	Return .F.
EndIf

M->G1_QUANT := nQtdBase

If !ldbTree .AND. !lMSExecAuto
	ldbTree := .T.
	If nOpcX < 5
		cCodAtual := cCodigo
		cValComp  := cCodigo + 'ú'
		AVMa200Monta(oTree, oDlg, cCodAtual, cCodSim,, nOpcX)
		oTree:TreeSeek(oTree:GetCargo())
	EndIf
EndIf	

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  AVA200Comp  ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o c¢digo do componente na Estrutura                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVA200Comp()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True caso o c¢digo seja validado e False em caso contr rio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVA200Comp()

Local lRet := .T.

lRet := AVA200ChkNod(M->G1_COMP, cValComp)
If lRet
	lRet := AVA200Codigo(M->G1_COMP, '', 0, 0)
	If lRet
		lRet := AVA200OutPai(M->G1_COMP, cValComp)
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AVA200ChkNod  ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica existencia de um mesmo c¢digo em um n¢ da estrutur³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVA200ChkNod(ExpN1, ExpC1, ExpO1)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = C¢digo a ser pesquisado                            ³±±
±±³          ³ ExpC2 = Lista de C¢digos a ser pesquizada                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVA200ChkNod(cCodigo, cLista)

Local aAreaAnt := GetArea()
Local aAreaSG1 := SG1->(GetArea())
Local cNomeArq := ''
Local cNomeAli := ''
// Local nX       := 0 -- ACSJ - 01/12/2004 - Variavel não é usada.
Local lRet     := .T.

Private nEstru     := 0

If cCodigo $(cLista)
	Help(' ',1,'A200NODES')
	lRet := .F.
EndIf

//-- Verifica se o Produto possui Estrutura
If lRet
	dbSelectArea('SG1')
	dbSetorder(1)
	If dbSeek(xFilial('SG1') + cCodigo, .F.)
		nNAlias ++
		cNomeAli := "ES"+StrZero(nNAlias,3)
		cNomeArq := AVEstrut2(cCodigo, 1,cNomeAli)
		dbSelectArea(cNomeAli)
		dbGoTop()
		Do While !Eof() .And. lRet
			If COMP $(cLista)
				Help(' ',1,'A200NODES')
				lRet := .F.
				Exit
			EndIf
			dbSkip()
		EndDo
		If Type('aEndEstrut') == 'A'
			aAdd(aEndEstrut,{cNomeAli,cNomeArq})
		Else
			AvFimEstrut2(Nil, cNomeArq)
		EndIf
	EndIf
EndIf

RestArea(aAreaSG1)
RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AVA200OutPai  ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica a existencia de uma mesmo c¢digo em um n¢ da estru³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVA200OutPai(ExpN1, ExpC1, ExpO1)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso encontre um c¢digo repetido e True em C.C.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = C¢digo a ser pesquizado                            ³±±
±±³          ³ ExpC2 = Lista de C¢gigos a ser pesquizada                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVA200OutPai(cCodigo, cLista)

Local cPai   := Substr(cLista,1,15)
Local nRecno := Recno()
Local nOrdem := IndexOrd()
Local lRet   := .T.

SG1->(dbSetOrder(2))
SG1->(dbSeek(xFilial('SG1')+cPai))
Do While !SG1->(Eof())
	If SG1->G1_COD == cCodigo
		Help(' ',1,'A200NODES')
		lRet := .F.
		Exit
	EndIf
	SG1->(dbSeek(xFilial('SG1')+SG1->G1_COD))
EndDo
dbSetOrder(1)

dbSetOrder(nOrdem)
dbGoto(nRecno)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  AVA200Desc  ³ Autor ³Rodrigo de A.Sartorio³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ True                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVA200Desc(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso encontre um c¢digo repetido e True em C.C.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Produto a ser pesquizado                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVA200Desc(cCod)

Local aAreaAnt := GetArea()
Local lRet     := .T.
Local cRet     := ""

cCod := If(cCod==Nil,M->G1_COMP,cCod)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no produto desejado e preenche descricao      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cAliasSB1)->(dbSeek(cFilSB1Aux+cCod, .F.)) .Or. SB1->(dbSeek(xFilial('SB1')+cCod, .F.))
//	M->G1_DESC := If( (cAliasSB1)->(!Eof()), (cAliasSB1)->B1_DESC, SB1->B1_DESC )
    cRet := If( (cAliasSB1)->(!Eof()), (cAliasSB1)->B1_DESC, SB1->B1_DESC )
    M->G1_DESC := cRet
ElseIf !Empty(cCod)
	Help(' ', 1, 'NOFOUNDSB1')
    lRet := .F.
EndIf
RestArea(aAreaAnt)

IF lMSExecAuto//AWF- 06/05/2014 - Essa Funcao é chamada do X3_VALID do G1_COMP onde deve devolver .T. ou .F. quando for lMSExecAuto = .T.
   RETURN lRet
ENDIF

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AVMA200Quant ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡„o da quantidade do Produto na Estrutura            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVMa200Quant(ExpN1, ExpC1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso o valor nao possa ser negativo, e True em C.C.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Quantidade a ser validada                          ³±±
±±³          ³ ExpC1 = Codigo do Produto                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVMA200Quant(nQuant,cCod)

Local nVar       := 0
Local lRet       := .T.
Local cAlias     := ''
Local nRecno     := 0
Local nOrder     := 0

nVar := If(nQuant==Nil,&(ReadVar()),nQuant)

// PLB 09/08/07 - Validações utilizadas somente no modulo de Materiais
/*
If IsProdMod(cCod) .And. EasyGParam('MV_TPHR') == 'N'
	nVar := nVar - Int(nVar)
	If nVar > .5999999999
		HELP(' ',1,'NAOMINUTO')
		lRet := .F.
	EndIf
ElseIf QtdComp(nVar) < QtdComp(0) .And. !EasyGParam('MV_NEGESTR')
	Help(' ',1,'A200NAONEG')
	lRet := .F.
EndIf
*/

lRet := Positivo()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AVMA200Fecha ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a Integridade do Sistema apos a finaliza‡„o        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVMa200Fecha(ExpO1, ExpO2)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema no fechamento, True C.C.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto Dlg                                         ³±±
±±³          ³ ExpO2 = Objeto Tree                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Function AVMa200Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cCodigo , nQtdBase, cRevisao, nLeadTime, nProduc, lConfirma, aAltEstru,cCodSim)
//Function   Ma200Fecha(oDlg, oTree, nOpcX, lMudou, cUm, cProduto, nQtdBase, cRevisao,                                                   aKey, aBKey, aUndo,aPaiEstru)
Function AVMa200Fecha(  oDlg, oTree, nOpcX, lMudou, cUm, cCodigo , nQtdBase, cRevisao, nLeadTime, nProduc, lConfirma, aAltEstru,cCodSim, aKey, aBKey, aUndo,aPaiEstru)

Local lRet       := .T.
Local cLinha1    := STR0024+CHR(13)	//"Cada altera‡„o em uma estrutura pode gerar uma nova revis„o para"
Local cLinha2    := STR0025+CHR(13)	//"o controle hist¢rico de altera‡”es em determinado produto."
Local cLinha3    := STR0026+CHR(13)	//"A altera‡„o deve gerar uma nova revis„o para esta estrutura ?"
Local cTitulo    := STR0027	//"Revis„o Estrutura"
//Local aAreaTRB   := {}
Local aAreaSB1   := {}
//Local cCod       := ''
//Local cCodPai    := ''
//Local cTipo      := ''
Local cAliasAnt  := ''
//Local aExplode   := {}
//Local aPai       := {}
Local nX         := 0
//Local nY         := 0
//Local nPos       := 0
//Local nQuant     := 0
//Local nQuant1    := 0
//Local nQtdNivel  := 0
//Local lMap       := .F.
//Local nCount     := 0
//Local nBarra     := 0
//Local cFile      := ''
Local cArqTrab   := ''
Local nCont
Local cUnidDe:= ""
Local aAtuEstrut := {}
Local aOrd       := SaveOrd({"ED7"})
If lConfirma
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o campo B1_QB na Confirma‡„o da Inclus„o/Altera‡Æo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcX == 3 .Or. nOpcX == 4
		cAliasAnt := Alias()

      IF EYJ->(FieldPos("EYJ_LEADTI")) > 0 //.And. (cAliasEYJ)->(dbSetOrder(1),dbSeek(xFilial() + cCodigo)) //LRS - 11/02/2014 - Validação para o lead time dentro da tabela EYJ
			
         dbSelectArea(cAliasEYJ)
         aAreaEYJ := (cAliasEYJ)->(GetArea())
         dbSetOrder(1)

         dbSelectArea(cAliasSB1)
         aAreaSB1 := (cAliasSB1)->(GetArea())
         dbSetOrder(1)

         If (cAliasSB1)->B1_QB # nQtdBase .OR. (lLeadTime .AND. ((cAliasEYJ)->EYJ_LEADTI # nLeadTime .Or. (cAliasEYJ)->EYJ_PRODUC # nProduc) .OR. if(EYJ->(FieldPos("EYJ_ESTSIM"))>0,(cAliasEYJ)->EYJ_ESTSIM#cCodSim,.F.))
            Begin Transaction
					(cAliasEYJ)->(DbSetOrder(1))
               If !((cAliasEYJ)->(dbSeek(xFilial("EYJ") + cCodigo)))
			         (cAliasEYJ)->(RecLock("EYJ", .t.))
				      Replace (cAliasEYJ)->EYJ_FILIAL With xFilial("EYJ")
				      Replace (cAliasEYJ)->EYJ_COD With cCodigo
					Else
				      (cAliasEYJ)->(RecLock(cAliasEYJ, .F.))					
			      EndIf

               //** AAF 20/08/2009
               If EYJ->(FieldPos("EYJ_ESTSIM")) > 0
                  Replace (cAliasEYJ)->EYJ_ESTSIM With cCodSim
               EndIf
               //**

               IF lLeadTime
                  Replace (cAliasEYJ)->EYJ_LEADTI With nLeadTime
                  Replace (cAliasEYJ)->EYJ_PRODUC With nProduc
               ENDIF
               (cAliasEYJ)->(MsUnlock())

					cUnidDe:= (cAliasSB1)->B1_UM
					(cAliasSB1)->(RecLock(cAliasSB1, .F.))
               (cAliasSB1)->B1_QB:= AVTransUnid(cUnidDe, (cAliasSB1)->B1_UM, (cAliasSB1)->B1_COD, nQtdBase, .F.)
					(cAliasSB1)->(MsUnlock())

               //WFS 09/10/09 - tratamento para atualizar o produto da estrutura que consta no cadastro de Itens Alternativos
               If EasyGParam("MV_AVG0185",.F.,.F.)                   

                  //Itens alternativos do tipo Exportação
                  ED7->(DBSetOrder(2)) //ED7_FILIAL + ED7_TPITEM + ED7_DE + ED7_PD
                  If ED7->(DBSeek(xFilial("ED7") + "E" + AvKey(cCodigo, "ED7_DE")))
                     While ED7->(!Eof()) .And.;
                        ED7->(xFilial("ED7")) == ED7->ED7_FILIAL .And.;
                        AvKey(cCodigo, "ED7_DE") == ED7->ED7_DE

                        If aScan(aAtuEstrut, ED7->ED7_PARA) == 0
                           AAdd(aAtuEstrut, ED7->ED7_PARA)
                        EndIf

                        ED7->(DBSkip())
                     EndDo
                  EndIf

                  For nCont:= 1 To Len(aAtuEstrut)
                     If (cAliasSB1)->(DBSeek(xFilial() + AvKey(aAtuEstrut[nCont], "B1_COD")))
                        (cAliasSB1)->(RecLock(cAliasSB1, .F.))
                        (cAliasSB1)->B1_QB:= AVTransUnid(cUnidDe, (cAliasSB1)->B1_UM, (cAliasSB1)->B1_COD, nQtdBase, .F.)
                        If lLeadTime
                           (cAliasEYJ)->EYJ_LEADTI := nLeadTime
                           (cAliasEYJ)->EYJ_PRODUC := AVTransUnid(cUnidDe, (cAliasSB1)->B1_UM, (cAliasSB1)->B1_COD, nProduc, .F.)
                        Endif
                        (cAliasSB1)->(MsUnlock())
                        (cAliasEYJ)->(MsUnlock())
                     EndIf
                  Next

               EndIf

            End Transaction
         EndIf

			RestArea(aAreaSB1)
			dbSelectArea(cAliasAnt)
			
			RestArea(aAreaEYJ)
			dbSelectArea(cAliasAnt)
	   ELSE
	   		dbSelectArea(cAliasSB1)
			aAreaSB1 := (cAliasSB1)->(GetArea())
			dbSetOrder(1)
			If (cAliasSB1)->(dbSeek(xFilial() + cCodigo))
				If (cAliasSB1)->B1_QB # nQtdBase .OR. (lLeadTime .AND. ((cAliasSB1)->B1_LEADTI # nLeadTime .Or. (cAliasSB1)->B1_PRODUC # nProduc) .OR. if(SB1->(FieldPos("B1_ESTSIM"))>0,(cAliasSB1)->B1_ESTSIM#cCodSim,.F.))
					Begin Transaction
				       	(cAliasSB1)->(RecLock(cAliasSB1, .F.))
						Replace (cAliasSB1)->B1_QB With nQtdBase					
	      
	                    //** AAF 20/08/2009
	                	If SB1->(FieldPos("B1_ESTSIM")) > 0
	                       Replace (cAliasSB1)->B1_ESTSIM With cCodSim
	                    EndIf
						//**
						IF lLeadTime
	                	Replace (cAliasSB1)->B1_LEADTI With nLeadTime
	                  Replace (cAliasSB1)->B1_PRODUC With nProduc
	               ENDIF
						(cAliasSB1)->(MsUnlock())
						
						//WFS 09/10/09 - tratamento para atualizar o produto da estrutura que consta no cadastro de Itens Alternativos
	             		If EasyGParam("MV_AVG0185",.F.,.F.)                   
	                    
	                       //Itens alternativos do tipo Exportação
	                       ED7->(DBSetOrder(2)) //ED7_FILIAL + ED7_TPITEM + ED7_DE + ED7_PD
			               If ED7->(DBSeek(xFilial("ED7") + "E" + AvKey(cCodigo, "ED7_DE")))
	                          While ED7->(!Eof()) .And.;
	                                ED7->(xFilial("ED7")) == ED7->ED7_FILIAL .And.;
	                                AvKey(cCodigo, "ED7_DE") == ED7->ED7_DE
	
	                             If aScan(aAtuEstrut, ED7->ED7_PARA) == 0
	                                AAdd(aAtuEstrut, ED7->ED7_PARA)
	                             EndIf
	   
	                             ED7->(DBSkip())
	                          EndDo
	                       EndIf
	                    
	                       cUnidDe:= (cAliasSB1)->B1_UM
						   For nCont:= 1 To Len(aAtuEstrut)
						      If (cAliasSB1)->(DBSeek(xFilial() + AvKey(aAtuEstrut[nCont], "B1_COD")))
	                             (cAliasSB1)->(RecLock(cAliasSB1, .F.))
	                             (cAliasSB1)->B1_QB:= AVTransUnid(cUnidDe, (cAliasSB1)->B1_UM, (cAliasSB1)->B1_COD, nQtdBase, .F.)
	            				 If lLeadTime
	            				    (cAliasSB1)->B1_LEADTI := nLeadTime
	                                (cAliasSB1)->B1_PRODUC := AVTransUnid(cUnidDe, (cAliasSB1)->B1_UM, (cAliasSB1)->B1_COD, nProduc, .F.)
	                             Endif
	                             (cAliasSB1)->(MsUnlock())
						      EndIf
						   Next
	    
	                    EndIf
	                    
	                End Transaction
				EndIf
			Else
				Help(' ', 1, 'NOFOUNDSB1')
			EndIf
			RestArea(aAreaSB1)
			dbSelectArea(cAliasAnt)
	EndIf
ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o campo B1_UREV                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par01 == 1 .And. nOpcX > 2 .And. Len(aAltEstru) > 0
		Begin Transaction
			For nX := 1 to Len(aAltEstru)
				If SB1->(dBSeek(xFilial('SB1') + aAltEstru[nX], .F.))
					RecLock('SB1')
					Replace B1_UREV With dDataBase
					MsUnlock()
				EndIf
			Next nX
		End Transaction
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Revisao Estrutura caso atualize arquivo de revisoes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par02 == 1 .And. nOpcX > 2
		TONE(3500,1)
		lGravaRev := (MsgYesNo(OemToAnsi(cLinha1+cLinha2+cLinha3),OemToAnsi(cTitulo)))
		If lGravaRev
			cRevisao := AVA200Revis(cCodigo)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seta o parametro MV_NIVALT                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMudou .And. (nOpcX > 2 .And. nOpcX <= 5)
		If lMudou .And. nOpcx == 4
			SG2->(dbSetOrder(3))
			If SG2->(dbSeek(xFilial("SG2")+cCodigo))
				Help(" ",1,"A200ALTROT")
			EndIf
		EndIf
		AVa200NivAlt()
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mapa de Divergencias                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//NOPADO POR AOM - 01/11/2010 - Nao é necessario efetuar a validação
	/*If nOpcX < 5 .And. (AllTrim(Upper(cUm)) == 'KG' .or. AllTrim(Upper(cUm)) == '10')

		AVa200IniMap(nQtdBase, oTree)

		aExplode := {}
		Explode(cCodigo, @aExplode, cRevisao, @nCount, oTree)

		aPai := {}
		For nX := 1 to Len(aExplode)
			If (nPos := aScan(aPai, {|x| x[2] == aExplode[nX, 2]})) == 0
				aAdd(aPai, {1, aExplode[nX, 2]})
			ElseIf nPos > 0
				aPai[nPos, 1]++
			EndIf
		Next nX

		cCodPai   := cCodigo
		nQtdNivel := CriaVar('B1_QB')
		For nX:=1 to Len(aPai)
			nQuant1 := CriaVar('B1_QB')
			If aPai[nX, 2] # cCodPai
				nPos   := aScan(aExplode,{|x| x[3] == aPai[nX, 2]})
				nQuant := If(nPos>0,aExplode[nPos, 4],0)
				For nY := 1 to Len(aExplode)
					If aExplode[nY, 2] == aPai[nX, 2]
						nQuant1 += aExplode[nY, 4]
					EndIf
				Next nY
				If nQuant1 # nQuant
					lMap := .T.
					nQtdNivel -= nQuant
					nQtdNivel += nQuant1
				Else
					nQtdNivel += nQuant1
				EndIf
			Else
				For nY := 1 to Len(aExplode)
					If aExplode[nY, 2] == cCodPai
						nQuant1 += aExplode[nY, 4]
					EndIf
				Next nY
				If nQuant1 # nQtdBase
					lMap := .T.
					nQtdNivel += nQuant1
					Exit
				Else
					nQtdNivel += nQuant1
				EndIf
			EndIf
		Next nX

		If lMap
		  	If !AVA200ShowMap(nQtdNivel)
				Return .T.
			EndIf
		EndIf

	EndIf*/
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa Ponto de Entrada na Grava‡„o da Estrutura         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If EasyEntryPoint('ES400GRVE')		
		Execblock('ES400GRVE',.F.,.F.,{nOpcx})
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o 5o Indice de Trabalho do arquivo dbTree                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cInd5) .And. File(cInd5+TEOrdBagExt())
	cArqTrab := oTree:cArqTree
	dbSelectArea(cArqTrab)
	dbClearIndex()
	fErase(cInd5+TEOrdBagExt())
	cInd5 := ''
	dbSetIndex(SubStr(cArqTrab,2)+'A'+TEOrdBagExt())
	dbSetIndex(SubStr(cArqTrab,2)+'B'+TEOrdBagExt())
	dbSetIndex(SubStr(cArqTrab,2)+'C'+TEOrdBagExt())
	dbSetIndex(SubStr(cArqTrab,2)+'D'+TEOrdBagExt())
	dbSetOrder(1)	
EndIf

If oDlg # Nil .And. oTree # Nil
   Release Object oTree
   oDlg:End()
ENDIF
RestOrd(aOrd)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AVMA200Del   ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Deleta a Estrutura Atual                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVMa200Del(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema na Dele‡„o, True C.C.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Produto                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVMa200Del(cCodigo)

Local aAreaAnt   := GetArea()
Local cSeek      := ''

dbSelectArea('SG1')
dbSetOrder(1)
If !dbSeek(cSeek := xFilial('SG1') + cCodigo, .F.)
	Help(' ', 1, 'REGNOIS')
	Return .F.
EndIf

Begin Transaction
    
    // 15.mai.2009 - ED719561 - Confirmação de exclusão - HFD
    if lMSExecAuto .OR. MsgYesNo(STR0039,STR0040)
 	   Do While !SG1->(Eof()) .And. SG1->G1_FILIAL + SG1->G1_COD == cSeek
		  RecLock('SG1', .F., .T.)
		  dbDelete()
		  MsUnlock()
		  SG1->(dbSkip())
	   EndDo
    endIf
End Transaction

RestArea(aAreaAnt)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AVMA200Undo  ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Desfaz as Inclus”es/Exclus”es                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVMa200Undo(ExpA1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema na Dele‡„o, True C.C.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os recnos                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVMa200Undo(aUndo)

Local lRet       := .T.,nY
Local nX         := 0
Local aAreaAnt   := GetArea()

If Len(aUndo) == 0
	Return lRet
EndIf

Begin Transaction

	dbSelectArea('SG1')
	For nX := 1 to Len(aUndo)
		If aUndo[nX,1] > 0 .And. aUndo[nX,1] <= EasyRecCount("SG1")
			dbGoto(aUndo[nX,1])
			If (lRet:=RecLock('SG1', .F.))
				If aUndo[nX, 2] == 1 //-- O Registro foi Incluido
					//-- Deleta o Registro
					If !Deleted()
						dbDelete()
					EndIf
				ElseIf aUndo[nX, 2] == 2 //-- O Registro foi Excluido
					//-- Restaura O REGISTRO
					If Deleted()
						dbRecall()
					EndIf
				ElseIf aUndo[nX, 2] == 3 //-- O Registro foi Alterado
					//-- Restaura OS DADOS do Registro
					For nY := 1 to Len(aUndo[nX, 3])
						FieldPut(nY, aUndo[nX, 3, nY])
					Next nY
				EndIf
				MsUnlock()
			Else
				Exit
			EndIf
		EndIf

	Next nX

End Transaction

RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o  ³ AVA200enDesc ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche a Variavel cValComp com a Descendencia do Produto ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVA200enDesc(ExpC1, ExpO1)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema na Montagem, True C.C.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Variavel Caracter com a Descendˆncia do Produto    ³±±
±±³          ³ ExpO1 = Objeto Tree                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AVA200enDesc(cValComp, aDescend, oTree)

Local aAreaAnt   := GetArea()
Local aAreaTRE   := {}, nx
Local cPai       := ''
Local cCod       := ''
Local lRet       := .T.

cValComp := ''
aDescend := {}

dbSelectArea(oTree:cArqTree)
aAreaTRE := GetArea()
cPai     := T_IDTREE
cCod     := If(Right(T_CARGO, 4)=='COMP',SubStr(T_CARGO, Len(SG1->G1_COD) + Len(SG1->G1_TRT) + 1, Len(SG1->G1_COD) ),Left(T_CARGO, Len(SG1->G1_COD)))
aAdd(aDescend, cCod)

Do While .T.
	dbSetOrder(3) //-- Ordem de T_IDCODE (Filho)
	If Val(cPai) # 0 .And. dbSeek(cPai, .F.)
		cCod   := If(Right(T_CARGO, 4)=='COMP',SubStr(T_CARGO, Len(SG1->G1_COD) + Len(SG1->G1_TRT) + 1, Len(SG1->G1_COD) ),Left(T_CARGO, Len(SG1->G1_COD)))
		aAdd(aDescend, cCod)
		cPai := T_IDTREE
		Loop
	Else
		Exit
	EndIf
EndDo

If Len(aDescend) > 0
	For nX := Len(aDescend) to 1 Step -1
		cValComp += aDescend[nX] + 'ú'
	Next nX
EndIf

//-- Restaura a Area de Trabalho
dbSetOrder(aAreaTRE[2])
dbGoto(aAreaTRE[3])
RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AVA200TudoOk ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡„o Final da Inclus„o/Altera‡„o                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVA200TudoOk(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema na Valida‡„o, True C.C.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Variavel Caracter com o a Origem da Chamada (I/A/E)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVA200TudoOk(cOpc)

Local aAreaAnt   := GetArea()
Local aAreaTRE   := {}
Local cSeek      := ''
// Local cCargo     := oTree:GetCargo() -- ACSJ - 01/12/2004 - Variavel não é usada.
Local lRet       := .T.
Local lRetPE     := .T.
Local nRecno     := 0

cOpc := If(cOpc==Nil,Space(1),cOpc) //-- "I" = Inclus„o / "A" = Altera‡„o / "E" = Exclus„o

If !(cOpc=='E')



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida grupo de opcionais e item de opcionais   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!Empty(M->G1_GROPC).And.Empty(M->G1_OPC)) .Or. (!Empty(M->G1_OPC).And.Empty(M->G1_GROPC))
		Help(' ',1,'A200OPCOBR')
		lRet := .F.
	EndIf
	
	If !lMSExecAuto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida a Existencia de Similaridade na Estrutura³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If lRet
		  dbSelectArea(oTree:cArqTree)
		  aAreaTRE := GetArea()
		  dbSetOrder(4)
	  	  nRecno := Recno()
		  dbSeek(cSeek := cCodPai + M->G1_TRT + M->G1_COMP, .T.)
		  If ! Eof()
			Do While !Eof() .And. cSeek == Left(T_CARGO, Len(cSeek))
				If !(nRecno==Recno()) .And. !(Right(T_CARGO,4)$'CODIúNOVO')
					Help(' ',1,'MESMASEQ')                                                    	
					lRet := .F.
					Exit
				EndIf
				dbSkip()
			EndDo				
	  	  EndIf
		  dbSetOrder(aAreaTRE[2])
		  dbGoto(aAreaTRE[3])
	   EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //** PLB - 05/10/2006
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida a Existencia de Perda do Componente      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet  .And.  SG1->( FieldPos("G1_VLCOMPE") ) > 0
       If M->G1_VLCOMPE $ cSim  .And.  Empty(M->G1_PERDA)
          EasyHelp(STR0036)  //"O componente possui Valor Comercial a Perda, preencha o campo Indice de Perda."
          lRet := .F.
       EndIf
	EndIf

EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Execblock MTA200 ap¢s Conf.da InclusÆo/Altera‡„o/Dele‡„o          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If EasyEntryPoint('MTA200')
		lRet := If(ValType(lRetPE:=ExecBlock('MTA200',.F.,.F.,cOpc))=='L',lRetPE,.T.)
	EndIf
EndIf

If cOpc == 'E' .And. Type('lDelFunc') == 'L'
	lDelFunc := lRet
EndIf

RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AVMa200GrSim ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava‡„o das Estruturas Similares                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVA200TudoOk(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema na Valida‡„o, True C.C.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Variavel Caracter com o Codigo do Produto          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVMa200GrSim(cCodigo, cCodSim, aUndo)

Local lRet       := .T.
Local aAreaAnt   := GetArea()
// Local aAreaTRE   := {} -- ACSJ - 01/12/2004 - Variavel não é usada.
Local aRecnos    := {}
Local nX         := 0
Local i          := 0
Local aCampos    := {}

If Empty(cCodSim)
	Return lRet
EndIf

dbSelectArea('SG1')
dbSetOrder(1)

If dbSeek(xFilial('SG1') + cCodSim, .F.)
	Do While !Eof() .And. SG1->G1_COD == cCodSim
		aAdd(aRecnos, Recno())
		dbSkip()
	EndDo
EndIf

If Len(aRecnos) > 0
	For nX := 1 to Len(aRecnos)
		dbGoto(aRecnos[nX])
		//-- Grava o Campo Atual
		aCampos := {}
		For i := 1 To FCount()
			aAdd(aCampos, FieldGet(i))
		Next i

		//-- Cria o Novo Registro
		Begin Transaction
			RecLock('SG1', .T.)
//          aAdd(aUndo, Recno())
			If aScan(aUndo, {|x| x[1]==Recno()}) == 0
				aAdd(aUndo, {Recno(), 1}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
			EndIf
			For i:=1 To FCount()
				FieldPut(i,aCampos[i])
			Next 1
			Replace G1_COD With cCodigo
			MsUnlock()
		End Transaction

	Next nX
EndIf

//-- Restaura a Area de Trabalho
RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AVA200Revis ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 05/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza cadastro de revisao de componentes                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVA200Revis(cProduto)

Local cRevisao   := CriaVar("G1_REVINI")
Local aArea      := {}
Local aAreaSG5   := {}
Local aAreaSB1   := {}
Local aRevisoes  := {}

aArea := GetArea()
dbSelectArea("SG5")
aAreaSG5 := GetArea()
dbSetOrder(1)
If dbSeek(xFilial()+cProduto)
	Do While !Eof() .And. G5_FILIAL+G5_PRODUTO == xFilial()+cProduto
		AADD(aRevisoes,{.F.,G5_REVISAO,DTOC(G5_DATAREV)})
		cRevisao:=G5_REVISAO
		dbSkip()
	EndDo
EndIf

cRevisao:=Soma1(cRevisao)
RecLock("SG5",.T.)
Replace G5_FILIAL With xFilial()
Replace G5_PRODUTO With cProduto
Replace G5_REVISAO With cRevisao
Replace G5_DATAREV With dDataBase
AADD(aRevisoes,{.T.,G5_REVISAO,DTOC(G5_DATAREV)})
MsUnlock()

cRevisao:=AVA200SelRev(aRevisoes)
If !Empty(cRevisao)
	dbSelectArea(cAliasSB1)
	aAreaSB1:=GetArea()
	dbSetOrder(1)
	If dbSeek(xFilial()+cProduto)
		IF lPCPREVTAB 
			PCPREVTAB(cProduto,cRevisao) 
		Else
			RecLock(cAliasSB1,.F.)
			Replace B1_REVATU With cRevisao
			MsUnlock()
		EndIf

	EndIf
	RestArea(aAreaSB1)
EndIf
RestArea(aAreaSG5)
RestArea(aArea)
Return cRevisao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ AVA200SelRev                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor     ³ Rodrigo de Almeida Sartorio              ³ Data ³ 05/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Seleciona revisao atual do produto                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVA200SelRev(aRevisoes)
Local aPer:={},oQual,nOpca:=1,cVarQ:="   "
Local cRevisao:=CriaVar("B1_REVATU")
Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")
Local oDlg,cTitle:=OemToAnsi(STR0028)	//"Sele‡„o da Revis„o Atual"
Local i:=0,nAchou:=0
If Len(aRevisoes) > 0
	If !lMSExecAuto
	DEFINE MSDIALOG oDlg TITLE cTitle From 145,70 To 400,340 OF oMainWnd PIXEL
	@ 10,13 TO 90,122 LABEL "" OF oDlg  PIXEL
	@ 20,18 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi(STR0023),STR0029  SIZE 100,62 ON DBLCLICK (aRevisoes:=AVMA200Troca(oQual:nAt,@aRevisoes),oQual:Refresh()) NOSCROLL OF oDlg PIXEL	//"Revis„o"###"Data"
	oQual:SetArray(aRevisoes)
	oQual:bLine := { || {If(aRevisoes[oQual:nAt,1],oOk,oNo),aRevisoes[oQual:nAt,2],aRevisoes[oQual:nAt,3]}}
	DEFINE SBUTTON FROM 110,042 TYPE 1 Action (nOpca:=2,oDlg:End()) ENABLE OF oDlg PIXEL
	DEFINE SBUTTON FROM 110,069 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg PIXEL
	ACTIVATE MSDIALOG oDlg
	ElseIf aScan(aAutoCab,{|x| x[1] == "ATUREVSB1" .And. x[2] == "S"}) > 0
		nOpca := 2
	EndIf
	If nOpca == 2
		nAchou:=ASCAN(aRevisoes,{|x| x[1] })
		If nAchou > 0
			cRevisao:=aRevisoes[nAchou,2]
		EndIf
	EndIf
EndIf
Return cRevisao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ AVMA200Troca                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor     ³ Rodrigo de Almeida Sartorio              ³ Data ³ 05/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ MarcaXDesmarca revisao utilizada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AVMA200Troca(nx,aRevisoes)
Local i:=0
aRevisoes[nx,1]:=!aRevisoes[nx,1]
For i:=1 to Len(aRevisoes)
	If nx # i
		aRevisoes[i,1] := .F.
	EndIf
Next i
Return aRevisoes

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AVA200NivAlt ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seta o Parametro MV_NIVALT para 'S'                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVA200NivAlt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema na Valida‡„o, True C.C.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVa200NivAlt()

Local aAreaAnt   := GetArea()
Local lRet       := .F.

//-- Seta o Parametro para Altera‡Æo de Niveis
If !(EasyGParam('MV_NIVALT')=='S')
	lRet := .T.
	PutMV('MV_NIVALT','S')
EndIf

RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AVA200Fields ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria um Array com os Campos do SG1                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AVA200Fields(ExpA1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ False caso ocorra algum problema na Valida‡„o, True C.C.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os campos do SG1                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AVA200Fields(aAcho)

Local aAreaAnt   := GetArea()
Local aAreaSX3   := {}
Local lRet       := .T.

dbSelectArea('SX3')
aAreaSX3 := GetArea()
dbSetOrder(1)
If dbSeek('SG1' + '01', .F.)
	aAcho := {}
	Do While !Eof() .And. X3_ARQUIVO == 'SG1'
		aAdd(aAcho, X3_CAMPO)
		dbSkip()
	EndDo
Else
	aAcho := Array(SG1->(fCount()))
	SG1->(aFields(aAcho))
EndIf

RestArea(aAreaSX3)
RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AVA200IniMap³ Autor ³ Jose Lucas            ³ Data ³ 11.08.93³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta arquivo binario para armazenar divergencias nas Qtd. ³±±
±±³          ³ dos Componentes em relacao a Qtd. Basica do Produto.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void := AVA200IniMap(ExpN1)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Quantidade do Componente                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AVA200IniMap(nQtdBase, oTree)

Local aAreaSG1   := SG1->(GetArea())
Local aAreaAnt   := GetArea()
// Local aAreaSX2   := {} -- ACSJ - 01/12/2004 - Variavel não é usada.
Local aAreaTRE   := {}
Local cMapaFile  := ''
Local nMapaHdl   := 0
Local nQuant     := 0
Local nSeq       := 0
Local cText      := ''
Local nRecno     := 0
Local nQuantSG1  := 0

cMapaFile := 'MAPA.DIV'
If File(cMapaFile)
	fErase(cMapaFile)
EndIf
nMapaHdl := MSFCREATE(cMapaFile, 0)

dbSelectArea(oTree:cArqTree)
aAreaTRE := GetArea()
dbSetOrder(1)
dbGoTop()
nSeq := 1
Do While !Eof()
	nRecno := Val(SubStr(T_CARGO,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))
	If nRecno > 0
		SG1->(dbGoto(nRecno))
		nQuantSG1 := SG1->G1_QUANT
	Else
		nQuantSG1 := 0
	EndIf
	If nSeq == 1
		fSeek(nMapaHdl,0,2)
		cText := '  Produto                   Qtd. Basica' + CHR(13) + CHR(10)
		fWrite(nMapaHdl,cText,Len(cText))
		fSeek(nMapaHdl,0,2)
		nQtdBase += CriaVar('B1_QB')
		cText := '  ' + SG1->G1_COD + Space(2+(20-Len(Str(nQtdBase)))) + Str(nQtdBase) + CHR(13) + CHR(10)
		fWrite(nMapaHdl,cText,Len(cText))
		fSeek(nMapaHdl,0,2)
		cText := '  ' + 'Componentes                Quantidade' + CHR(13) + CHR(10)
		fWrite(nMapaHdl,cText,Len(cText))
	Else
		nQuant := nQuantSG1
		fSeek(nMapaHdl,0,2)
		cText := '  ' + SG1->G1_COMP  + '          ' + Str(nQuant) + CHR(13) + CHR(10)
		fWrite(nMapaHdl,cText,Len(cText))
	EndIf
	nSeq++
	dbSkip()
End

RestArea(aAreaTRE)
RestArea(aAreaSG1)
RestArea(aAreaAnt)
FClose(nMapaHdl)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AVA200ShowMap³ Autor ³ Jose Lucas            ³ Data ³ 11.08.93³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Totalizar e Exibir Mapa de Divergencias nas quantidades    ³±±
±±³          ³ dos ProdutoxElementos.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpN1 := AVA200ShowMap(ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor da Opcao da Confirmacao da Operacao          ³±±
±±³Parametros³ ExpN2 = Valor Total da Quantidade dos Componentes          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AVA200ShowMap(nQtdNivel)

Local oGet
Local oDlg
Local oFontLoc
Local aAreaAnt   := GetArea()
Local aAreaSX2   := {}
Local cMapaFile  := ''
Local cString    := ''
Local cText      := ''
Local nNumLinhas := 0
Local cAlias     := Alias()
Local nOpcA      := 2
Local aString    := {}

cMapaFile := 'MAPA.DIV'
If !File(cMapaFile)
	cString    := STR0012 // '  Nenhuma Divergencia...'
	nNumLinhas := 1
Else
	nMapaHdl := EasyOpenFile(cMapaFile,2+64)
	FSeek(nMapaHdl,0,2)
	cText := STR0013 + Space(5+(27-Len(Str(nQtdNivel)))) + Str(nQtdNivel)+ CHR(13)+CHR(10) // '  Total'
	FWrite(nMapaHdl,cText,Len(cText))
	FClose(nMapaHdl)
	cString := MEMOREAD(cMapaFile)
EndIf

oFontLoc := TFont():New( 'Mono AS', 6, 15 )
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0014) FROM 15,20 to 25,62 // 'Mapa de Divergencias'
DEFINE SBUTTON FROM 52, 101.8 TYPE 1  ENABLE OF oDlg ACTION (nOpca := 1,oDlg:End())
DEFINE SBUTTON FROM 52, 128.9 TYPE 2  ENABLE OF oDlg ACTION (nOpca := 2,oDlg:End())
@ 0.5,0.7  GET oGet VAR cString OF oDlg MEMO size 150,40 READONLY COLOR CLR_BLACK,CLR_HGRAY
oGet:oFont     := oFontLoc
oGet:bRClicked := {||AllwaysTrue()}
ACTIVATE MSDIALOG oDlg
oFontLoc:End()

RestArea(aAreaAnt)

Return (nOpcA==1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ Explode  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 03/08/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Faz a explosao de uma estrutura                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ Explode(ExpC1,ExpA1,ExpC2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do produto a ser explodido                  ³±±
±±³          ³ ExpA1 = Array com estrutura                                ³±±
±±³          ³ ExpC2 = Revisao da Estrutura Utilizada                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Explode(cProduto, aExplode, cRevisao, nCount, oTree)

Local aAreaAnt   := GetArea()
Local aAreaSG1   := SG1->(GetArea())
Local aAreaTRE   := {}
Local cCod       := cProduto
Local cSeq       := ''
Local cComp      := ''
Local nRecno     := 0
Local cFilSG1    := xFilial('SG1')

nCount++
SG1->(dbSetOrder(1))

dbSelectArea(oTree:cArqTree)
aAreaTRE := GetArea()
dbSetOrder(1)
dbGoTop()

Do While !Eof()
	cCod   := Left(T_CARGO, Len(SG1->G1_COD))
	cSeq   := SubStr(T_CARGO, Len(SG1->G1_COD) + 1, Len(SG1->G1_TRT))
	cComp  := SubStr(T_CARGO, Len(SG1->G1_COD + SG1->G1_TRT) + 1, Len(SG1->G1_COMP))
	nRecno := Val(SubStr(T_CARGO,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))

	If cCod # cProduto
		dbSkip()
		Loop
	EndIf

	If nRecno > 0
		SG1->(dbGoto(nRecno))
	Else
		Exit
	EndIf
	If cCod # cComp .And. SG1->G1_REVINI <= cRevisao .And. SG1->G1_REVFIM >= cRevisao
		nPos := aScan(aExplode,{|x| x[1] == nCount .And. x[2] == cCod .And. x[3] == cComp .And. x[5] == cSeq})
		If nPos == 0
			aAdd(aExplode,{nCount, cCod, cComp, SG1->G1_QUANT, cSeq, SG1->G1_REVINI, SG1->G1_REVFIM})
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe sub-estrutura                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRecno := SG1->(Recno())
		If SG1->(dbSeek(cFilSG1+cComp, .F.))
			Explode( SG1->G1_COD, @aExplode, cRevisao, @nCount, oTree)
			nCount --
		Else
			SG1->(dbGoto(nRecno))
			nPos := aScan(aExplode,{|x| x[1] == nCount .And. x[2] == cCod .And. x[3] == cComp .And. x[5] == cSeq})
			If nPos == 0
				aAdd(aExplode,{nCount, cCod, cComp, SG1->G1_QUANT, cSeq, SG1->G1_REVINI, SG1->G1_REVFIM})
			EndIf
		Endif
	EndIf
	dbSkip()
Enddo

RestArea(aAreaTRE)
RestArea(aAreaSG1)
RestArea(aAreaAnt)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³AVMa200PosicºAutor  ³Fernando Joly       º Data ³  10/15/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Posiciona sobre o Item desejado na Estrutura                º±±
±±º          ³Esta fun‡„o  cria o  5o  indice  do dbTree , atualizando  a º±±
±±º          ³variavel cInd5. Para  tal  assume-se  como  nomes para os 4 º±±
±±º          ³primeiros : SubStr(oTree:cArqTree,2) + "A", "B", "C" e "D". º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpN1 = Op‡„o da Edi‡„o                                    º±±
±±º          ³ ExpC1 = Chave do Registro                                  º±±
±±º          ³ ExpO1 = Objeto Tree                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA200.PRW                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AVMa200Posic(nOpcX, cCargo, oTree)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa Variaveis Locais                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAreaAnt   := GetArea()
Local aAreaTRB   := ''
Local cComp      := Space(Min(TamSX3('G1_COMP')[1],AVSX3("G1_COMP",3)))
Local cCompAnt   := Subs(cCargo,Len(SG1->G1_COD+SG1->G1_TRT)+1,Len(SG1->G1_COMP))
Local cOrdem     := ''
Local cTarget    := ''
Local cArqTrab   := oTree:cArqTree
Local nRecno     := 0

Private cA200ICod := AllTrim(Str(Len(SG1->G1_COD+SG1->G1_TRT)+1))
Private cA200TCod := AllTrim(Str(Len(SG1->G1_COMP)))

If MsgGet2(STR0002,STR0010,@cComp,,{|| .T.})
	If !Empty(cComp)
		dbSelectArea(cArqTrab)
		aAreaTRB  := GetArea()
		cOrdem    := T_IDCODE
		nRecno    := Recno()
		If cComp==cCodAtual
			dbGoto(1)
			cTarget := T_CARGO
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria o 5o Indice de Trabalho do arquivo dbTree                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cInd5) .Or. !File(cInd5+TEOrdBagExt())
				cInd5 := CriaTrab('', .F.)
				IndRegua(Alias(),cInd5+TEOrdBagExt(),'Subs(T_CARGO,'+cA200ICOD+', '+cA200TCOD+')',,,STR0007)
				dbClearIndex()
				dbSetIndex(SubStr(cArqTrab,2)+'A'+TEOrdBagExt())
				dbSetIndex(SubStr(cArqTrab,2)+'B'+TEOrdBagExt())
				dbSetIndex(SubStr(cArqTrab,2)+'C'+TEOrdBagExt())
				dbSetIndex(SubStr(cArqTrab,2)+'D'+TEOrdBagExt())
				dbSetIndex(cInd5+TEOrdBagExt())
			EndIf	
			dbSetOrder(5)
			dbGoto(nRecno)
			If dbSeek(cComp, .F.)
				
				//-- Desconsidera a linha do Produto Pai
				If !(Right(T_CARGO,4)=='COMP')
					Do While !Eof() .And. Subs(T_CARGO,Len(SG1->G1_COD+SG1->G1_TRT)+1,Len(SG1->G1_COMP)) == cComp
						If	Right(T_CARGO,4)=='COMP'
							cTarget := T_CARGO
							Exit
						EndIf
						dbSkip()
					EndDo
				Else
					cTarget := T_CARGO
				EndIf
				
				//-- Caso J  esteja posicionado procura a Pr¢xima ocorrˆncia
				If !Empty(cTarget) .And. T_IDCODE <= cOrdem
					Do While !Eof() .And. Subs(T_CARGO,Len(SG1->G1_COD+SG1->G1_TRT)+1,Len(SG1->G1_COMP)) == cComp
						If Right(T_CARGO,4) == 'COMP' .And. T_IDCODE > cOrdem
							cTarget := T_CARGO
							Exit
						EndIf
						dbSkip()
					EndDo
				EndIf	
				
			EndIf
		EndIf	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorna Integridade do Sistema                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RestArea(aAreaTRB)
		RestArea(aAreaAnt)

		//-- Posiciona o dbTree sobre o Componente Encontrado
		If !Empty(cTarget)
			oTree:TreeSeek(cTarget)
		Else	
			Help(' ',1, 'REGNOIS')
		EndIf
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATA200   ºAutor  ³Marcelo Iuspa       º Data ³  10/04/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ FUNCAO ACIONADA NO BOTAO DE CONFIRMACAO DA ESTRUTURA       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AVBtn200Ok(aUndo, c200Cod)
Local lRet := .T.
Local aArea := {SG1->(IndexOrd()), SG1->(RecNo()), Alias()}

IF EYJ->(FieldPos("EYJ_LEADTI")) > 0  //LRS - 11/02/2014 - Validação para o lead time dentro da tabela EYJ
	lRet := !lLeadTime .OR. Empty(M->EYJ_PRODUC) .OR. NaoVazio(M->EYJ_LEADTI)
ELSE
	lRet := !lLeadTime .OR. Empty(M->B1_PRODUC) .OR. NaoVazio(M->B1_LEADTI)//- AOM - 13/10/2011
ENDIF

If lRet .AND. EasyEntryPoint('A200BOK')
	lRet := If(ValType(lRet:=ExecBlock('A200BOK',.F.,.F.,{aUndo, c200Cod}))=='L',lRet,.T.)
	SG1->(dbSetOrder(aArea[1]))
	SG1->(dbGoto(aArea[2]))
	dbSelectArea(aArea[3])
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATA200   ºAutor  ³Marcelo Iuspa       º Data ³  24/04/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Acrescenta TRT ao prompt do dbtree baseado no conteudo     º±±
±±º          ³ da propriedade cargo                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AVA200Prompt(cPrompt, cCargo)
Local cTRT := Space(Len(SG1->G1_TRT)+3)
If ! (cCargo == Nil .Or. Empty(cCargo) .Or. Right(cCargo, 4) $ "CODI,NOVO")
	If ! Empty(cTRT := SubStr(cCargo, Len(SG1->G1_COD)+1,Len(SG1->G1_TRT)))
		cTRT := " - " + cTRT
	Endif
Endif
Return(Pad(AllTrim(cPrompt) + cTRT, Len(cPrompt+cTRT)))

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ Estrut2  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 04/02/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Faz a explosao de uma estrutura a partir do SG1            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ AVEstrut(ExpC1,ExpN1,ExpC2,ExpC3)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do produto a ser explodido                  ³±±
±±³          ³ ExpN1 = Quantidade a ser explodida                         ³±±
±±³          ³ ExpC2 = Alias do arquivo de trabalho                       ³±±
±±³          ³ ExpC3 = Nome do arquivo criado                             ³±±
±±³          ³ ExpL1 = Monta a Estrutura exatamente como se ve na tela    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observa‡„o³ Como e uma funcao recursiva precisa ser criada uma variavel³±±
±±³          ³ private nEstru com valor 0 antes da chamada da fun‡„o.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function AVEstrut2(cProduto,nQuant,cAliasEstru,cArqTrab,lAsShow,lIntegra)
LOCAL nRegi:=0,nQuantItem:=0
LOCAL aCampos:={},aTamSX3:={},lAdd:=.F.
LOCAL nRecno
Local lTemVLCOMPE := SG1->( FieldPos("G1_VLCOMPE") ) > 0//AAF 02/06/05 - Valor Comercial a Perda.
Default lIntegra := .F.

cAliasEstru:=IF(cAliasEstru == NIL,"ESTRUT",cAliasEstru)
nQuant:=IF(nQuant == NIL,1,nQuant)
lAsShow:=IF(lAsShow==NIL,.F.,lAsShow)
nEstru++
If nEstru == 1
	// Cria arquivo de Trabalho
	AADD(aCampos,{"NIVEL","C",6,0})
	aTamSX3:=TamSX3("G1_COD")
	AADD(aCampos,{"CODIGO","C",aTamSX3[1],0})
	aTamSX3:=TamSX3("G1_COMP")
	AADD(aCampos,{"COMP","C",aTamSX3[1],0})
	aTamSX3:=TamSX3("G1_QUANT")
	AADD(aCampos,{"QUANT","N",Max(aTamSX3[1],18),aTamSX3[2]})
	aTamSX3:=TamSX3("G1_TRT")
	AADD(aCampos,{"TRT","C",aTamSX3[1],0})
	aTamSX3:=TamSX3("G1_GROPC")
	AADD(aCampos,{"GROPC","C",aTamSX3[1],0})
	aTamSX3:=TamSX3("G1_OPC")
	AADD(aCampos,{"OPC","C",aTamSX3[1],0})
	aTamSX3:=TamSX3("G1_PERDA")
	AADD(aCampos,{"PERC","N",Max(aTamSX3[1],18),aTamSX3[2]})
	
	//** AAF 02/06/05 - Valor Comercial a Perda.
	If lTemVLCOMPE
       aTamSX3:=TamSX3("G1_VLCOMPE")
       AADD(aCampos,{"VLCOMPE","C",1,0})
    Endif
    //**
    
    If lLeadTime
       
       IF EYJ->(FieldPos("EYJ_LEADTI")) > 0  //LRS - 11/02/2014 - Validação para o lead time dentro da tabela EYJ
		    aTamSX3:=TamSX3("EYJ_LEADTI")
			 AADD(aCampos,{"LEADTIME","N",aTamSX3[1],aTamSX3[2]})
          aTamSX3:=TamSX3("EYJ_PRODUC")
			 AADD(aCampos,{"PRODUC","N",aTamSX3[1],aTamSX3[2]})
       ELSE
		    aTamSX3:=TamSX3("B1_LEADTI")
			 AADD(aCampos,{"LEADTIME","N",aTamSX3[1],aTamSX3[2]})
          aTamSX3:=TamSX3("B1_PRODUC")
			 AADD(aCampos,{"PRODUC","N",aTamSX3[1],aTamSX3[2]})
       ENDIF 
         
       
    EndIf
	
	If Select(cAliasEstru) > 0
		dbSelectArea(cAliasEstru)
		dbCloseArea()
	EndIf    
	cArqTrab := E_CriaTrab(, aCampos, cAliasEstru)
	IndRegua(cAliasEstru,cArqtrab+TEOrdBagExt(),"NIVEL+CODIGO+COMP+TRT",,,STR0002) //"Selecionando Registros..."
	dbSetIndex(cArqtrab+TEOrdBagExt())
EndIf

SB1->(dbSetOrder(1))

dbSelectArea("SG1")
dbSetOrder(1)
dbSeek(xFilial()+cProduto)
While !Eof() .And. G1_FILIAL+G1_COD == xFilial()+cProduto
	nRegi:=Recno()

	//JVR - 23/03/10 - Tratamento para não utilizar itens da estrutura quando declarados como 'não importar'
	If !SB1->(DbSeek(xFilial("SB1") + SG1->G1_COMP)) //.or. (!(SB1->B1_IMPORT $ "S") .And. !lIntegra)   - NOPADO POR AOM - Nao considera o tratamento pois com a nova rotina de compras nacionais o produto nao precisa ser importado.
        SG1->(dbSkip())
	    Loop
	EndIf

	If G1_COD != G1_COMP
		lAdd:=.F.
		If !(&(cAliasEstru)->(dbSeek(StrZero(nEstru,6)+SG1->G1_COD+SG1->G1_COMP+SG1->G1_TRT))) 
		    
		    nQuantItem:=AvExplEstr(nQuant)
		    //AOM - 17/04/2012 - Verifica se o item tem subestrutura pois só irao compor os insumos os ultimos itens da raiz
		    IF SG1->(dbSeek(xFilial("SG1")+SG1->G1_COMP))
			   AVEstrut2(SG1->G1_COD,nQuantItem,cAliasEstru,cArqTrab,lAsShow,lIntegra)
			   nEstru -- 
			   dbGoto(nRegi)
	           dbSkip()
	           Loop
		    EndIf 
		    dbGoto(nRegi)
			RecLock(cAliasEstru,.T.)
			Replace NIVEL With StrZero(nEstru,6)
			Replace CODIGO With SG1->G1_COD
			Replace COMP With SG1->G1_COMP
			Replace QUANT With nQuantItem
			Replace TRT With SG1->G1_TRT
			Replace GROPC With SG1->G1_GROPC
			Replace OPC With SG1->G1_OPC
			Replace PERC With SG1->G1_PERDA
			
            //** AAF 02/06/05 - Valor Comercial a Perda.
            If lTemVLCOMPE
    			   Replace VLCOMPE With SG1->G1_VLCOMPE
            Endif
            //**
            If lLeadTime
               IF EYJ->(FieldPos("EYJ_LEADTI")) > 0 
					   If EYJ->(dbSeek(xFilial("EYJ")+cProduto))  //LRS - 11/02/2014 - Validação para o lead time dentro da tabela EYJ            	 
               	   Replace LEADTIME With EYJ->EYJ_LEADTI
                	   Replace PRODUC With EYJ->EYJ_PRODUC
						EndIf	 
            	ElseIf SB1->(dbSeek(xFilial("SB1")+cProduto))
               	Replace LEADTIME With SB1->B1_LEADTI
                	Replace PRODUC With SB1->B1_PRODUC
            	EndIf            
            ENDIF
            
			MsUnlock()
			lAdd:=.T.
			dbSelectArea("SG1")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe sub-estrutura                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRecno:=Recno()
		IF dbSeek(xFilial()+G1_COMP)
			AVEstrut2(G1_COD,nQuantItem,cAliasEstru,cArqTrab,lAsShow,lIntegra)
			nEstru --
		Else
			dbGoto(nRecno)
			If !(&(cAliasEstru)->(dbSeek(StrZero(nEstru,6)+SG1->G1_COD+SG1->G1_COMP+SG1->G1_TRT))) .Or. (lAsShow.And.!lAdd)
				nQuantItem:=AvExplEstr(nQuant)
				RecLock(cAliasEstru,.T.)
				Replace NIVEL With StrZero(nEstru,6)
				Replace CODIGO With SG1->G1_COD
				Replace COMP With SG1->G1_COMP
				Replace QUANT With nQuantItem
				Replace TRT With SG1->G1_TRT
				Replace GROPC With SG1->G1_GROPC
				Replace OPC With SG1->G1_OPC
				Replace PERC With SG1->G1_PERDA
				
				//** AAF 02/06/05 - Valor Comercial a Perda.
                If lTemVLCOMPE
    			    Replace VLCOMPE With SG1->G1_VLCOMPE
                Endif
                //**
                
				MsUnlock()
				dbSelectArea("SG1")
			EndIf
		Endif
	EndIf
	dbGoto(nRegi)
	dbSkip()
Enddo
Return cArqTrab

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AvExplEstr ³ Autor ³ Eveli Morasco       ³ Data ³ 20/08/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula a quantidade usada de um componente da estrutura   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpN1 := AvExplEstr(ExpN2,ExpD1,ExpC1,ExpC2)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Quantidade utilizada pelo componente               ³±±
±±³          ³ ExpN2 = Quantidade do pai para calcular neces. do filho    ³±±
±±³          ³ ExpD1 = Data para validacao do componente na estrutura     ³±±
±±³          ³ ExpC1 = String contendo os opcionais utilizados            ³±±
±±³          ³ ExpC2 = Revisao da estrutura utilizada                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AvExplEstr(nQuant,dDataStru,cOpcionais,cRevisao,nDecimal)

LOCAL nQuantItem:=0,cUnidMod,nG1Quant,nQBase,nBack
LOCAL aTamSX3:={}
LOCAL cAlias:=Alias(),nRecno:=Recno(),nOrder:=IndexOrd()
LOCAL lOk:=.T.
LOCAL nDecOrig:=Set(3,8)
LOCAL cAliasSB1Exp:=If(cAliasSB1<>NIL, If(Select(cAliasSB1)<>0, cAliasSB1, 'SB1'), 'SB1') 

aTamSX3:=TamSX3("G1_QUANT")

Default nDecimal:= AVSX3("ED4_QTD",4) //aTamSX3[2] //AAF 22/08/05 - Arredondar para casas decimais de quantidade do Drawback.

// Verifica os opcionais cadastrados na Estrutura
cOpcionais:= If((cOpcionais == NIL),"",cOpcionais)

// Verifica a Revisao Atual do Componente
cRevisao:= If((cRevisao == NIL),"",cRevisao)
   
dbSelectArea(cAliasSB1Exp)
dbSetOrder(1)

If dbSeek(xFilial()+SG1->G1_COD)

   If Empty(cOpcionais) .And. !Empty(B1_OPC)
      cOpcionais:=B1_OPC
   EndIf     

   If Empty(cRevisao) .And. !Empty(B1_REVATU)
      cRevisao:= IIF(lPCPREVATU, PCPREVATU(B1_COD), B1_REVATU) 
   EndIf
           
   If !Empty(cOpcionais) .And. !Empty(SG1->G1_GROPC+SG1->G1_OPC) .And. !(SG1->G1_GROPC+SG1->G1_OPC $  cOpcionais)
      lOk:=.F.
   EndIf

   If !Empty(cRevisao) .And. (SG1->G1_REVINI > cRevisao .Or. SG1->G1_REVFIM < cRevisao)
      lOk:=.F.
   EndIf
Else   // Procura no Arquivo de Itens
   
   cAliasSB1Exp := 'SB1'
   dbSelectArea(cAliasSB1Exp)
   dbSetOrder(1)

   If dbSeek(xFilial()+SG1->G1_COD)

      If Empty(cOpcionais) .And. !Empty(B1_OPC)
         cOpcionais:=B1_OPC
      EndIf     

      If Empty(cRevisao) .And. !Empty(B1_REVATU)
         cRevisao:=  IIF(lPCPREVATU,PCPREVATU(B1_COD), B1_REVATU) 
      EndIf
           
      If !Empty(cOpcionais) .And. !Empty(SG1->G1_GROPC+SG1->G1_OPC) .And. !(SG1->G1_GROPC+SG1->G1_OPC $  cOpcionais)
         lOk:=.F.
      EndIf

      If !Empty(cRevisao) .And. (SG1->G1_REVINI > cRevisao .Or. SG1->G1_REVFIM < cRevisao)
         lOk:=.F.
      EndIf
   Endif
EndIf


dbSelectArea(cAlias)
dbSetOrder(nOrder)
dbGoto(nRecno)

// Verifica a data de validade

dDataStru := If((dDataStru == NIL),dDataBase,dDataStru)

If dDataStru >= SG1->G1_INI .And. dDataStru <= SG1->G1_FIM .And. lOk

   cUnidMod := EasyGParam("MV_UNIDMOD")

   dbSelectArea(cAliasSB1Exp)
   dbSeek(xFilial()+SG1->G1_COD)

   nQBase := B1_QB
   dbSeek(xFilial()+SG1->G1_COMP)

   dbSelectArea("SG1")
   nG1Quant := G1_QUANT

   If SubStr(G1_COMP,1,3)=="MOD"

      cTpHr := EasyGParam("MV_TPHR")

      If cTpHr == "N"
         nG1Quant := Int(nG1Quant)
         nG1Quant += ((G1_QUANT-nG1Quant)/60)*100
      EndIf

   EndIf

   If G1_FIXVAR $ " V"
      If SubStr(G1_COMP,1,3)=="MOD" .And. cUnidMOD != "H"
         nQuantItem := ((nQuant / nG1Quant) / (100 - G1_PERDA)) * 100
      Else
         nQuantItem := (nQuant * nG1Quant) / (1-(G1_PERDA / 100)) //(nQuant * nG1Quant) + ((G1_PERDA * (nQuant * nG1Quant)) / 100)
      EndIf
      nQuantItem := nQuantItem / Iif(nQBase <= 0,1,nQBase)
   Else
      If SubStr(G1_COMP,1,3)=="MOD" .And. cUnidMOD != "H"
         nQuantItem := (nG1Quant / (100 - G1_PERDA)) * 100
      Else
         nQuantItem := nG1Quant / (1-(G1_PERDA / 100)) //nG1Quant + ((G1_PERDA * nG1Quant) / 100)
      EndIf
   Endif
   nQuantItem:=Round(nQuantitem,nDecimal)
EndIf

Do Case
   Case ((cAliasSB1Exp)->B1_TIPODEC == "A")
      nBack := Round( nQuantItem,0 )
   Case ((cAliasSB1Exp)->B1_TIPODEC == "I")
      nBack := Int(nQuantItem)+If(((nQuantItem-Int(nQuantItem)) > 0),1,0)
   Case ((cAliasSB1Exp)->B1_TIPODEC == "T")
      nBack := Int( nQuantItem )
   OtherWise
      nBack := nQuantItem
EndCase

Set(3,nDecOrig)

Return( nBack )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A200Auto4EºAutor  ³ Andre Anjos		 º Data ³  18/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Processa exclusao de componentes nao recebidos na nova     º±±
±±º          ³ estrutura alterada por rotina automatica.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200Auto4E(cCod,aUndo,lMudou,aAltEstru,aPaiEstru,lPriNivel)
Local nRecno := 0
Local nPCOD  := aScan(aAutoItens[1],{|x| AllTrim(x[1]) == "G1_COD"})
Local nPTRT  := aScan(aAutoItens[1],{|x| AllTrim(x[1]) == "G1_TRT"})//AWF - 23/05/2014
Local nPCOMP := aScan(aAutoItens[1],{|x| AllTrim(x[1]) == "G1_COMP"})

SG1->(dbSetOrder(1))//G1_FILIAL+G1_COD+G1_COMP+G1_TRT
DO While !SG1->(EOF()) .And. SG1->(G1_FILIAL+G1_COD) == xFilial("SG1")+cCod
	//-- Se nao achou item no array da ExecAuto, deleta
   If aScan(aAutoItens,{|x| x[nPCOD,2]  == SG1->G1_COD  .And.;
	  					    x[nPCOMP,2] == SG1->G1_COMP .And.;//}) = 0 //
						  	x[nPTRT,2]  == SG1->G1_TRT }) = 0  //AWF - 23/05/2014
		cCargo  := SG1->(G1_COD+G1_TRT+G1_COMP+StrZero(Recno(),9)+StrZero(nIndex++,9)+'COMP')
		T_CARGO := SG1->(G1_COD+G1_TRT+G1_COMP+StrZero(Recno(),9)+StrZero(nIndex++,9)+'COMP')
		AVMa200Edita(5,cCargo,NIL,5,@aUndo,@lMudou,@aAltEstru,,,,@aPaiEstru,{})
   ElseIf !lPriNivel
		nRecno := SG1->(Recno())
		If SG1->(dbSeek(xFilial("SG1")+SG1->G1_COMP))
			A200Auto4E(SG1->G1_COD,@aUndo,@lMudou,@aAltEstru,@aPaiEstru)
		EndIf
		SG1->(dbGoTo(nRecno))
   EndIf
   SG1->(dbSkip())
ENDDO

Return


/* ====================================================*
* Função: IntegDefK
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Auto: Alex Wallauer - AWF - 08/05/2014
* =====================================================*/
*--------------------------------------------------------------------*
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
*--------------------------------------------------------------------*
Local oEasyIntEAI
Local cAlias:="SG1"
Private aOrderAuto
   
    aOrderAuto := {{"SG1",2}}//Para mudar a ordem da validacao da chave

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("SG1")
	oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EDCES400(oEasyMessage:GetEAutoArray("SG1"),oEasyMessage:GetEAutoArray("SG1_Item"),oEasyMessage:GetOperation())} )
	oEasyIntEAI:SetModule("EDC",50)
	// Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "ES400RECB") //RECEBIMENTO DE BUSINESS MESSAGE     (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "ES400RESB") //RESPOSTA SOBRE O RECEBIMENTO        (<-Response)
	//
	oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult() 

*------------------------------------------------*
Function ES400RECB(oMessage) 
*------------------------------------------------* 
Local oBusinesEvent := oMessage:GetEvtContent(),nCont
Local oBusinessCont := oMessage:GetMsgContent()//,cCampo,cConteudo
Local aItemComponent,aItens,aSeq
Local cEvento := Upper(EasyGetXMLinfo(,oBusinesEvent,"_Event"))
      
Local oBatch    := EBatch():New()
Local oRec      := ERec():New()//Registros da Capa
Local oItens    := ETab():New()//Registros da Itens
Local oItem     := ERec():New()//Arrays com os Registros dos Itens

Local oExecAuto := EExecAuto():New()

   oRec:SetField("G1_COD"  , EasyGetXMLinfo("G1_COD"  , oBusinessCont, "_ItemCode"   ) ) //Codigo do Produto Pai
   oRec:SetField("G1_COMP" , EasyGetXMLinfo("G1_COMP" , oBusinessCont, "_ItemComponentCode"   ) ) //Componente (G1_COMP)
// oRec:SetField("G1_TRT"  , EasyGetXMLinfo("G1_TRT"  , oBusinessCont, "_ItemSequence"        ) ) //Sequencia  (G1_TRT)
   oRec:SetField("G1_QUANT", EasyGetXMLinfo("G1_QUANT", oBusinessCont, "_ItemAmount" ) ) //Quantidade Base”
    
   oExecAuto:SetField("SG1",oRec)//Registros da Capa

   oParams := ERec():New()

   cCodItemPai:=oRec:GetFieldCont("G1_COD")
   cComponente:=oRec:GetFieldCont("G1_COMP")
// lTemItem:=.F.

   IF cEvento == "DELETE"//oMessage:GetOperation() = 5 

      oParams:SetField("nOpc",5)//Exclusao

   ELSE

      SG1->(DBSETORDER(1))
      IF SG1->(DBSEEK(xFilial()+cCodItemPai))
         oParams:SetField("nOpc",4)//Alteracao
      ELSE
         oParams:SetField("nOpc",3)//Inclusao
      ENDIF


      aItemComponent:= oBusinessCont:_ListOfItensStructure:_ITEMCOMPONENT

      If ValType(aItemComponent) <> "A"
         aItens := {aItemComponent}
      Else
         aItens := aItemComponent
      EndIf
      aSeq:={}
      FOR nCont := 1 TO LEN(aItens)

         oaItens:=aItens[nCont]

         cCod_I:=EasyGetXMLinfo("G1_COMP" , oaItens, "_ItemComponentCode"   )

         IF (nPos:=ASCAN(aSeq, {|S| S[1] == cCod_I})) = 0
            AADD(aSeq,{cCod_I,1})
            nPos:=LEN(aSeq)
         ELSE
            aSeq[nPos,2]++
         ENDIF
         cTRT:=STRZERO(aSeq[nPos,2],LEN(SG1->G1_TRT))
         
         oItem:= ERec():New()//Arrays com os Registros dos Itens
         oItem:SetField("G1_COD"  , EasyGetXMLinfo("G1_COD"  , oBusinessCont, "_ItemCode"      ) ) //Codigo do Produto Pai
//       oItem:SetField("G1_TRT"  , EasyGetXMLinfo("G1_TRT"  , oaItens, "_ItemSequence"        ) ) //Sequencia  (G1_TRT)
         oItem:SetField("G1_TRT"  , cTRT                                                               ) //Sequencia  (G1_TRT)
         oItem:SetField("G1_COMP" , EasyGetXMLinfo("G1_COMP" , oaItens, "_ItemComponentCode"   ) ) //Componente (G1_COMP)
         oItem:SetField("G1_INI"  , EasyGetXMLinfo("G1_INI"  , oaItens, "_InitialDate"         ) ) //DT Inicial (G1_INI)
         oItem:SetField("G1_FIM"  , EasyGetXMLinfo("G1_FIM"  , oaItens, "_FinalDate"           ) ) //DT Final   (G1_FIM)
         oItem:SetField("G1_QUANT", EasyGetXMLinfo("G1_QUANT", oaItens, "_ItemComponentAmount" ) ) //Quantidade   (G1_QUANT)
         oItem:SetField("G1_PERDA", EasyGetXMLinfo("G1_PERDA", oaItens, "_LossFactor"          ) ) //Indice Perda (G1_PERDA)

         oItens:AddRec(oItem)//Arrays com os Registros dos Itens
   
      NEXT
   
   ENDIF   

   oExecAuto:SetField("SG1_Item",oItens)//Arrays com os Registros dos Itens

   oExecAuto:SetField("PARAMS"  ,oParams)
   
   oBatch:AddRec(oExecAuto) 

Return oBatch

*-------------------------------------------------*
Function ES400RESB(oMessage) 
*-------------------------------------------------*
Local oXml      := EXml():New()

    If oMessage:HasErrors()     

//      VARINFO("oMessage:aContent-AWF",oMessage:aContent)

       oXMl := oMessage:GetContentList("RESPONSE")
    EndIf

//VARINFO("oXml-AWF",oXml)
 
Return oXml

Function AvFimEstrut2(cAliasEstru,cArqTrab)
	cAliasEstru:=IF(cAliasEstru == NIL,"ESTRUT",cAliasEstru)
	dbSelectArea(cAliasEstru)
	
	/*
	dbCloseArea()
	FErase(AllTrim(cArqTrab)+GetDBExtension())
	FErase(AllTrim(cArqTrab)+TEOrdBagExt())
	*/
	(cAliasEstru)->(E_EraseArq(cArqTrab))
Return
