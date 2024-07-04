#include "Mata100.ch"
#include "TOTVS.ch"
#include "Folder.ch"
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� FUNCAO   � MATA100  � AUTOR � Claudinei M. Benzi    � DATA �            ���
���������������������������������������������������������������������������Ĵ��
��� DESCRICAO� Entrada de Notas Fiscais de Compra                           ���
���������������������������������������������������������������������������Ĵ��
��� USO      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
���Rodrigo Sarto.�19/10/98�18049A�Acerto na verificacao da localizacao      ���
��� Edson        �27/10/98�XXXXXX� Correcao no rateio do desconto do PC.    ���
���Rodrigo Sarto.�28/10/98�18385A�Acerto na exclusao de NFs com Rastro      ���
���Rodrigo Sarto.�24/09/98�17699A�Acerto na funcao A100F4  p/ NF tipo "C"   ���
��� Edson        �15/11/98�XXXXXX� Implementacao do calculo do IRRF e ISS.  ���
��� Bruno        �24/11/98�XXXXXX� Modi.da tela de entrada da NF (argentina)���
��� Fernando Joly�29/12/98�19082A� Deletar registros do SD5 na BaixaLote(). ���
���Rodrigo Sarto.�25/02/99�META  �Revisao Rastreabilidade                   ���
��� Edson        �19/03/99�XXXXXX� Implementacao da DoContabil Dos&Windows. ���
��� Fernando Joly�27/04/99�XXXXXX� Passar a LOJA para a QAIMPENT.           ���
���Fernando Joly �18/05/99�21722A� Possibilitar Consulta F4 no D1_LOTECTL.  ���
���Rodrigo Sart. �09/06/99�PROTHE�Verificar permissao programa              ���
���Rodrigo Sart. �28/06/99�xxxxxx� Incluir VALIDACAO do usuario nos gets dos���
���              �        �      � campos de fornecedor e loja do fornecedor���
���Jose Lucas    �01/07/99�21075A� Incluir #IFNDEF para a cham. AliqIcms(). ���
���Bruno Sobieski�14.07.99�Melhor� Tirar os blocos exclusivos das localiza- ���
���              �        �      �coes (foi gerada especifica MATA101.PRW). ���
���Julio Wittwer �05.08.99�META  �Interpretar MV_CRNEG                      ���
���Cesar Valadao �22/11/99�25057A�Correcao de Duplicidade de Regs no SD3.   ���
���              �        �      �Revisao de Entradas e Saidas no CQ.       ���
���Kleber        �17/01/00�xxxxxx�Incl.dos Modulos 11,14 na funcao AMiIn.   ���
���Leonardo      �18/02/00�xxxxxx�Substituir diretiva SPANISH por cPaisLoc  ���
���Patricia Sal. �01/03/00�xxxxxx�Util. os campos D7_PRODUTO+D7_DOC+D7_SERIE���
���              �        �      �+D7_FORNECE+D7_LOJA ao inves do D7_CHAVE  ��� 
���Paulo Emidio  �22/05/01�META  �Substituicao da funcao QAIMPENT() pela    ���
���              �        �      �QATUMATQIE(), que realiza a integracao com���
���              �        �      �o SIGAQIE (Inspecao de Entradas)          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function MatA100(xAutoCab,xAutoItens,nOpc103)
//��������������������������������������������������������������Ŀ
//� Define Array contendo os campos do arquivo que sempre deverao�
//� aparecer no browse. (funcao mBrouse)                         �
//� ----------- Elementos contidos por dimensao ---------------- �
//� 1. Titulo do campo (Este nao pode ter mais de 12 caracteres) �
//� 2. Nome do campo a ser editado                               �
//����������������������������������������������������������������
Local aFixe := {{ OemToAnsi(STR0001),"D1_DOC    " },; //"Numero da NF"
               {  OemToAnsi(STR0002),"D1_SERIE  " },; //"Serie da NF "
               {  OemToAnsi(STR0003),"D1_FORNECE" }}  //"Fornecedor  "

Local nx := 0
//��������������������������������������������������������������Ŀ
//� Verifica a permissao do programa em relacao aos modulos      �
//����������������������������������������������������������������
If AMIIn(2,4,11,12,14,17,72)
	PRIVATE l100Auto := ( xAutoCab <> NIL  .and. xAutoItens <> NIL )
	PRIVATE aAutoCab:={} , aAutoItens :={}
	PRIVATE lDigita, lAglutina,lGeraLanc, lAbandona := .F.
	PRIVATE cIdentB6 := ""
	PRIVATE cSB6Ant:=""
	PRIVATE lA100CLAS:= (ExistBlock("A100CLAS"))      // Internacionaliza��o
	PRIVATE lA100GRAV:= (ExistBlock("A100GRAV"))      // Internacionaliza��o
	PRIVATE cCalcImpV:= GETMV("MV_GERIMPV")           // Internacionaliza��o
	PRIVATE cMarca   := " "
	PRIVATE lLoja    := .F.
	PRIVATE cTipoNF:='E' 									// Flag utilizada na AliqIcm()
	PRIVATE lIntegracao := IF(GetMV("MV_EASY")=="S",.T.,.F.)
        PRIVATE lEicFin     := IF(GetNewPar("MV_EASYFIN","N")=="S",.T.,.F.) 
	PRIVATE lF1Import := IF(SF1->F1_Import=="S",.T.,.F.)
	PRIVATE lConFrete2:=.F.
	PRIVATE lConFrete :=.F.
	PRIVATE lConImp   := .F.
	PRIVATE lConImp2:=.F., nTotImpos := 0

	If l100Auto
	   if Type("lMsHelpAuto") =="U"
  		   lMsHelpAuto := .T.
  		Endif   
	   aAutoCab := SF1->(MSArrayXDB(xAutoCab))
	   For nX := 1 To Len(xAutoItens)
	      aadd(aAutoItens,SD1->(MSArrayXDB(xAutoItens[nX])))
	   Next
	EndIf

	If cPaisLoc <> "BRA"
			If ! lA100CLAS
					Help(" ",1,"NO_IX",,"A100CLAS",1,30)
					Return
			EndIf
			If ! lA100GRAV
					Help(" ",1,"NO_IX",,"A100GRAV",1,30)
					Return
			EndIf
	EndIf

	If (ExistBlock("MT100F4"))
		__cExpF4 := ExecBlock("MT100F4",.F.,.F.)
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Define Array contendo as Rotinas a executar do programa      �
	//� ----------- Elementos contidos por dimensao ------------     �
	//� 1. Nome a aparecer no cabecalho                              �
	//� 2. Nome da Rotina associada                                  �
	//� 3. Usado pela rotina                                         �
	//� 4. Tipo de Transa��o a ser efetuada                          �
	//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
	//�    2 - Simplesmente Mostra os Campos                         �
	//�    3 - Inclui registros no Bancos de Dados                   �
	//�    4 - Altera o registro corrente                            �
	//�    5 - Remove o registro corrente do Banco de Dados          �
	//����������������������������������������������������������������
	PRIVATE aRotina := {    { STR0004,"AxPesqui"  , 0 , 1},;          //"Pesquisar"
									{ STR0005,"A100Visual", 0 , 2},;          //"Visualizar"
									{ STR0006,"A100Incl", 0 , 3},;            //"Incluir"
									{ STR0007,"A100Classi", 0 , 4},;          //"Classificar"
									{ STR0008,"A100Deleta", 0 , 5}    } 		//"Excluir"

	PRIVATE lRecebto:= .F., lReajuste := .T.,cArquivo:= ""
	PRIVATE lLancPad40:=lLancPad50:=lLancPad95:=lLancPad60:=.F.
	PRIVATE lLancPad55:=lLancPad65:=.F.
	PRIVATE nHdlPrv:=1,nTotal:=0,cLoteCom,nLinha:=2,nMoedaCor:=1
	PRIVATE cCadastro:= OemToAnsi(STR0009)+If(nOpc103<>Nil," - SIGAEIC","")          //"Notas Fiscais de Entrada"
	PRIVATE cTit, cNome

	Set Key VK_F12 To FAtiva()

	//�����������������������������������������������������Ŀ
	//� Carrega as perguntas selecionadas                   �
	//�������������������������������������������������������
	//��������������������������������������������������������������Ŀ
	//� mv_par01 - Se mostra e permite alterar lancamentos contabeis �
	//� mv_par02 - Se deve aglutinar os lancamentos contabeis        �
	//� mv_par03 - Se deve verificar o arquivo de cotacoes           �
	//� mv_par04 - Se deve aplicacar o reajuste                      �
	//� mv_par05 - Incluir na Amarracao ProdxFornecedor              �
	//� mv_par06 - Lancto Contabil On-Line                           �
	//� mv_par07 - Considera Loja no PC          Sim Nao             �
	//� mv_par08 - Utiliza Op. Triangular        Sim Nao             �
	//����������������������������������������������������������������
    If nOpc103 == Nil
		pergunte("MTA100",.F.)
	Else
		Pergunte("MTA103",.F.)	
	EndIf	
	lDigita  := (mv_par01==1)
	lAglutina:= (mv_par02==1)
	lReajuste:= (mv_par04==1)
	lAmarra  := (mv_par05==1)
	lGeraLanc:= (mv_par06==1)
	lConsLoja:= (mv_par07==1)
	IsTriangular((mv_par08==1))
	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//� Obs.: O parametro aFixe nao e' obrigatorio e pode ser omitido�
	//����������������������������������������������������������������
	If l100Auto
	   dbSelectArea("SD1")
	   a100Inclui("SD1",Recno(),3,,.F.,.F.)
	   lMsHelpAuto := .F.
	Else
		If nOpc103 <> Nil
			bBlock := &( "{ |x,y,z,k| " + aRotina[ nOpc103,2 ] + "(x,y,z,k) }" )
			Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc103)
		Else
			#IFDEF SHELL
					mBrowse( 6, 1,22,75,"SD1",aFixe,"D1_CANCEL" )
			#ELSE
					mBrowse( 6, 1,22,75,"SD1",aFixe,"D1_TES" )
			#ENDIF
		EndIf
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Recupera a Integridade dos dados                             �
	//����������������������������������������������������������������
	dbSelectArea("SC7")
	dbSetOrder(1)

	dbSelectArea("SB8")
	dbSetOrder(1)

	dbSelectArea("SF3")
	dbSetOrder(1)

	Set Key VK_F12 To
EndIf
RETURN

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A100Visual� Autor � Claudinei M. Benzi    � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de visualizacao das notas fiscais de entrada.     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A100Visual(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A100Visual(cAlias,nReg,nOpcx)
Local cSeek ,nCnt
Local oDlg ,oGet
Local cConhecNBM := If(lintegracao,SD1->D1_CONHEC,"")
Local cCampo:="",i
Local aArea 		:= GetArea()
Local cSavAlias	:= cAlias
PRIVATE nIcmImp := 0
Set Key VK_F12 To
//��������������������������������������������������������������Ŀ
//� Padronizacao do cAlias para Browsers no SF1                  �
//����������������������������������������������������������������
If cAlias == "SF1"
	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	cAlias := "SD1"
EndIf

dbSelectArea(cAlias)
If D1_FILIAL != xFilial()
      HELP(" ",1,"A000FI")
      Return (.T.)
Endif

PRIVATE dDatCont := dDataBase ,nUsado := 0 ,nOpcA

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aHeader[0],Continua:=.F.,nOpc:=3,aDUPL[0]

//��������������������������������������������������������������Ŀ
//� Montagem do aHeader                                          �
//����������������������������������������������������������������
dbSelectArea("Sx3")
dbSeek(cAlias)
While !Eof() .And. (x3_arquivo == cAlias)
      IF x3uso(x3_usado) .AND. cNivel >= x3_nivel
            nUsado++
            AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
                  x3_tamanho, x3_decimal, x3_valid,;
                  x3_usado, x3_tipo, x3_arquivo, x3_context } )
      Endif
      dbSkip()
End

//��������������������������������������������������������������Ŀ
//� Posiciona ponteiro do arquivo cabeca e inicializa variaveis  �
//����������������������������������������������������������������
cSeek := SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
dbSelectArea("SF1")
dbSetOrder(1)
dbSeek( xFilial()+cSeek )
PRIVATE cTipo  :=F1_TIPO ,cNFiscal :=F1_DOC     ,cSerie   :=SerieNfId("SF1",2,"F1_SERIE"),;
      dDEmissao:=F1_EMISSAO ,nTotNot  :=F1_VALBRUT ,cA100For :=F1_FORNECE,;
      cLoja    :=F1_LOJA    ,nTotMerc :=F1_VALMERC ,nValFrete:=F1_FRETE,;
      nValDesp :=F1_DESPESA ,nTotIcm  :=F1_VALICM  ,nTotIpi  :=F1_VALIPI,;
      nValDesc :=F1_DESCONT ,nBRetIcms:=F1_BRICMS  ,nIcmsRet :=F1_ICMSRET,;
      nBaseFrete :=F1_BASEFD,nTotBase2 :=F1_BASEICM ,nBaseItem:=0.00,;
      nlIcmsRet:=.F.        ,nValFun  :=F1_CONTSOC ,cFormul  :=F1_FORMUL,;
      dDigit      := F1_DTDIGIT ,cEspecie :=F1_ESPECIE

PRIVATE aLivro:={}, lDesc:=.F.

//��������������������������������������������������������������Ŀ
//� Montagem do aCols                                            �
//����������������������������������������������������������������
dbSelectArea(cAlias)
dbSetOrder(1)
dbSeek(xFilial()+cSeek)
aCols:={}
nCnt := 0
Do While !Eof() .And. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == xFilial()+cSeek
      nCnt++
      nUsado:=0
      AADD(aCols,Array(Len(aHeader)))
      For i:=1 to Len(aHeader)
            cCampo:=Alltrim(aHeader[i,2])
            If aHeader[i,10] # "V"
                  aCOLS[Len(aCols)][i] := FieldGet(FieldPos(cCampo))
            ElseIF aHeader[i,10] == "V"
                  aCOLS[Len(aCols)][i] := CriaVar(cCampo)
            EndIf
      Next i
      dbSelectArea(cAlias)
      dbSkip()
EndDo

//������������������������������������������������������Ŀ
//� Caso nao ache nenhum item , abandona rotina.         �
//��������������������������������������������������������
If nCnt == 0
      dbSetOrder(1)
      Return .T.
EndIf

DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 28,80 OF oMainWnd         //"Nota de Entrada de Mercadorias"

@ 11, 005 TO 48, 310 LABEL "" OF oDlg  PIXEL
@ 18, 010 SAY OemtoAnsi(STR0011) SIZE 15,7 OF oDlg PIXEL          //"Tipo"
@ 18, 030 MSGET cTipo           SIZE 9,10 OF oDlg PIXEL WHEN (.F.)
@ 18, 050 SAY OemtoAnsi(STR0012) SIZE 50, 7 OF oDlg PIXEL         //"Formul�rio Pr�prio"
@ 18, 105 MSGET cFormul         SIZE 9,10 OF oDlg PIXEL WHEN (.F.)
@ 18, 125 SAY OemtoAnsi(STR0013) SIZE 40, 7 OF oDlg PIXEL         //"Nota Fiscal"
If Len(cNFiscal)>6
		@ 18, 155 MSGET cNFiscal        SIZE 45,10 OF oDlg PIXEL PICTURE "@R 9999-99999999";
																						WHEN (.F.)
Else
		@ 18, 170 MSGET cNFiscal        SIZE 25,10 OF oDlg PIXEL WHEN (.F.)
Endif
@ 18, 205 SAY OemtoAnsi(STR0014)SIZE 15,7 OF oDlg PIXEL           //"S�rie"
@ 18, 225 MSGET cSerie          SIZE 16,10 OF oDlg PIXEL WHEN (.F.)
@ 18, 250 SAY OemtoAnsi(STR0015) SIZE 16,7 OF oDlg PIXEL          //"Data"
@ 18, 265 MSGET dDEmissao       SIZE 39,10 OF oDlg PIXEL WHEN (.F.)
If cTipo $ "DB"
		@ 33, 010 SAY OemtoAnsi(STR0016) SIZE 40, 7 OF oDlg PIXEL         //"Cliente   "
Else
		@ 33, 010 SAY OemtoAnsi(STR0017) SIZE 40, 7 OF oDlg PIXEL         //"Fornecedor"
Endif
@ 33, 050 MSGET cA100For          SIZE 30, 10 OF oDlg PIXEL WHEN (.F.)
@ 33, 085 MSGET cLoja             SIZE 14, 10 OF oDlg PIXEL WHEN (.F.)
If lIntegracao
		If SF1->F1_IMPORT == "S"
				@ 33,125 SAY OemtoAnsi(STR0018) SIZE 40, 7 OF oDlg PIXEL          //"Conhecimento :"
				@ 33,170 MSGET cConhecNBM     SIZE 40, 10 OF oDlg PIXEL WHEN (.F.)
		Endif
Endif
@ 33, 225 SAY OemtoAnsi(STR0019) SIZE 50,7 OF oDlg PIXEL          //"Tipo de Documento"
@ 33, 272 MSGET cEspecie              SIZE 25,10 OF oDlg PIXEL WHEN (.F.)
dbSelectArea(IIF(cTipo$"DB","SA1","SA2"))
dbSeek(xFilial()+SubStr(cA100For,1,Len(SA2->A2_COD))+cLoja)

@ 122, 005 TO 143, 310 LABEL "" OF oDlg  PIXEL
cTit := IIF(cTipo$'DB',STR0020,STR0021)         //'Cliente: '###'Fornecedor: '
@ 129,010 SAY OemToAnsi(STR0022)+DtoC(dDigit)+" "+OemtoAnsi(cTit)+IIf(cTipo$'DB',SA1->A1_NOME,SA2->A2_NOME) SIZE 150,7 OF oDlg PIXEL            //"Dt Entr:"
@ 129,200 SAY OemtoAnsi(STR0023) SIZE 45,7 OF oDlg PIXEL                //'Total da Nota'
@ 129,250 MSGET nTotNot PICTURE "@E 999,999,999,999.99" SIZE 50,10 OF oDlg PIXEL RIGHT WHEN (.F.)

oGet := MSGetDados():New(50,5,124,310,nOpcx,"A100LinOk","A100TudOk","",.F.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,A100Rodape(.f.),oDlg:End()},{||oDlg:End()})

dbSelectArea(cAlias)
dbSeek(xFilial()+cSeek)

Set Key VK_F12 To FAtiva()

cAlias := cSavAlias

RestArea(aArea)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A100Incl  � Autor � Cristina Ogura        � Data � 20.10.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de inclusao de notas fiscais de entrada.          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A100Incl(cAlias,nReg,nOpcx,aCposx,lConFrete,lConImp)
Local xRet

Set Key VK_F12 To

xRet:=  A100INCLUI(cAlias,nReg,nOpcx,aCposx,lConFrete,lConImp)

Set Key VK_F12 To FAtiva()

Return xRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A100Inclui� Autor � Claudinei M. Benzi    � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de inclusao de notas fiscai de entrada.           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A100Inclui(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A100Inclui(cAlias,nReg,nOpcx,aCposx,lConFrete,lConImp)
Static lExistRDGr := NIL
Static lExistRDGT := NIL
Local nCnt:=0,aCusto[0],oDlg,nOpca
Local nTotNot2,nDifIPI := 0,nDifIcm:=0
Local aCpos[0]
Local nTotMercTp:=0
Local bCHAVE:={ || x:=xFILIAL()+dtos(dDataBase)+cDipi+cCFOP+cPOSFIS+cUM }
Local dDataFec := MVUlmes(),lLanctOk:=.F.
Local dDataSav := dDataBase, aSema := {}, bOK, bVoltaIcm
Local oCliFor, oLoja, oForn, bGotAnt, cTipAnt, lRet
Local oNfProv  // Fernando 10/06/99
Local cCampo:="",i
Local lIntACD	:= SuperGetMV("MV_INTACD",.F.,"0") == "1"
LOCAL l100Itens:= (ExistBlock("A100ITNF"))     // Pto de entrada - retorna nro itens da NF
LOCAL nItens:=400,nAuxItens:=0
Local nx := 0
Local aCtbDia := {}

//-- Celerina
Local lQualiCQ   := .F.
Local nPosItem   := 0

lExistRDGT := If(lExistRDGT == NIL,ExistTemplate("MT100AGR"),lExistRDGT)
lExistRDGr := If(lExistRDGr == NIL,ExistBlock("MT100AGR"),lExistRDGr)
l100 := .T.

If lAbandona
      lAbandona:=.F.
      Return
EndIf

Private oGet

If Type("l100Auto") == "U"
	l100Auto	:= .F.
EndIf

lConFrete:=IIF(lConFrete==NIL,.F.,lConFrete)
lConImp     :=IIF(lConImp==NIL,.F.,lConImp)
lConfrete2:=lConfrete
lConImp2:=lConImp
lMat115:=.F.
lMat118:=.F.

PRIVATE nBaseISS:=0.00,nValISS := 0, lBaseISS  := .T.,nValFun:=0
PRIVATE cDipi:="", cPosFis:="", cUM:="",nDQuant:=0, cCFOP:="", nPorBase:=1
PRIVATE dDEmissao:=dDataBase  ,  nTotNot:= 0    ,;
      dDatCont :=dDataBase  , nFatConv:=0       , lDupl:=.F.     ,;
      nTotPeso :=0          , lRatValor:=.F.    , aFixos:=MatxAfixos() ,;
      cCondicao:="   "      , nValIcmAnt:=0     , nTotBase:=0.00 ,;
      nBaseItem:=0.00       , nBaseAnt:=0       , nBaseFrete:=0.00,;
      nBsFrete1:=0.00       , nTotbase1:=0      ,;
      nTotBase2:=0.00       , nBsFretG:=0       , nBaseIRRF := 0,nBaseInss:=0,;
      cEspecie:=CriaVar("F1_ESPECIE"),cNaturez :="",nIrrf:=0,nResIRRF:=0,nTotIss:=0,;
		nValInss := 0

PRIVATE aSalvaBase, aSalvaIpi
PRIVATE aSavaCols
PRIVATE nIcmImp := 0
lRecebto:=.F.

nTotBaseISS:=0
nTotValISS:=0
cSB6Ant:=""
PRIVATE aRegLock := {}
//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������

PRIVATE CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999,;
      nTotMerc:=0,nValFrete:=0,nValDesp:=0,nValDesc:=0,;
      nBaseDup:=0,nBaseIpi :=0,nBaseIcm:=0,nTotIcm:=0,nTotIpi:=0,;
      nAdiantamento:=0,cSeekAdto, nBRetIcms:=0, nIcmsRet:=0,;
      lIcmsRet:=.F.,nValTotItem:=0,nBIcmsRet:=0,nVlrIcmRet:=0,;
      nBaseIcmRet:=0,nBTotIcmRet:=0, aIcmsSolid:={},nElemLivro:=0 ,;
      nRatIpiFre:=0,nRatIpiDes:=0,nRatIpiCon:=0,nBaseDup2:=0,nTotServ:=0

PRIVATE nPosCod,nPosLocal,nPosTes,nPosLote,nPosLotCTL,nPosDValid

//��������������������������������������������������������������Ŀ
//� Verificar data do ultimo fechamento em SX6.                  �
//����������������������������������������������������������������
If dDataFec >= dDataBase
      Help( " ", 1, "FECHTO" )
      Return
EndIf
//��������������������������������������������������������������Ŀ
//� Verifica parametro MV_DATAFIS pela data de digitacao.        �
//����������������������������������������������������������������
If !FisChkDt(dDatabase)
	Return
Endif

If !lConFrete .and. !lConImp
	PRIVATE aHeader[0],Continua,nOpc:=3,aDUPL[0],nUsado:=0
	PRIVATE cA100For	:= CriaVar("F1_FORNECE")
	PRIVATE cLoja		:= CriaVar("F1_LOJA")
	PRIVATE cTipo		:= CriaVar("F1_TIPO")
	PRIVATE cNFiscal	:= CriaVar("F1_DOC")
	PRIVATE cFormul 	:= CriaVar("F1_FORMUL")
	PRIVATE cSerie		:= SerieNfId("SF1",5,"F1_SERIE")
Endif

PRIVATE aLivro:={}, lDesc:=.F.

If lConFrete
      If lForm115                   // Variavel usada pelo MATA115 p/definir
            cFormul := "S"          // se utiliza Formulario proprio
      Else
            cFormul := "N"
      Endif
Endif

//������������������������������������������������������������������������Ŀ
//� Carrega as perguntas selecionadas para saber se deve verificar cotacao �
//��������������������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01 - Se mostra e permite alterar lancamentos contabeis �
//� mv_par02 - Se deve aglutinar os lancamentos contabeis        �
//� mv_par03 - Se deve verificar o arquivo de cotacoes           �
//� mv_par04 - Se deve aplicacar o reajuste                      �
//� mv_par05 - Incluir na Amarracao ProdxFornecedor              �
//� mv_par06 - Lancto Contabil On-Line                           �
//����������������������������������������������������������������
If __TTSInUse .And. mv_par06 == 1 .And. cPaisLoc <> "PTG"
      //��������������������������������������������������������������Ŀ
      //� Nao e' permitido utilizar Lancamento On-Line com TTS ativado �
      //����������������������������������������������������������������
      Help(" ",1,"460TTSLANC")
      Return(.T.)
EndIf

lDigita  := IIF(mv_par01==1,.T.,.F.)
lAglutina:= IIF(mv_par02==1,.T.,.F.)
lReajuste:= IIF(mv_par04==1,.T.,.F.)
lAmarra  := IIF(mv_par05==1,.T.,.F.)
lGeraLanc:= IIF(mv_par06==1,.T.,.F.)
lConsLoja:= IIF(mv_par07==1,.T.,.F.)
IsTriangular((mv_par08==1))

//����������������������������������������������������������������������Ŀ
//� Pto. de entrada que retorna o nro de itens da NF.                    �
//������������������������������������������������������������������������
If l100Itens
      nAuxItens:= ExecBlock("A100ITNF",.F.,.F.)
      If Valtype(nAuxItens)=="N".And.nAuxItens>0
            nItens:=nAuxItens
      Endif
Endif

aSalvaBase:=Array(nItens)
aSalvaIpi:=Array(nItens)
Afill(aSalvaBase,0)
Afill(aSalvaIpi,0)

If !lConFrete .and. !lConImp
      //��������������������������������������������������������������Ŀ
      //� Montagem do aHeader                                          �
      //����������������������������������������������������������������
      dbSelectArea("Sx3")
      dbSeek(cAlias)
      While !Eof() .And. (x3_arquivo == cAlias)
            IF x3uso(x3_usado) .AND. cNivel >= x3_nivel
                  nUsado++
                  AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
                        x3_tamanho, x3_decimal, x3_valid,;
                        x3_usado, x3_tipo, x3_arquivo, x3_context } )
                  IF ! Trim(x3_campo) $ "D1_QUANT/D1_QTSEGUM/D1_COD"
                        AADD(aCpos,x3_campo)
                  Endif
            Endif
            dbSkip()
      End

      //��������������������������������������������������������������Ŀ
      //� Montagem do aCols                                            �
      //����������������������������������������������������������������
      PRIVATE aCOLS[1][Len(aHeader)+1]

      For i:=1 to Len(aHeader)
            cCampo:=Alltrim(aHeader[i,2])
            //���������������������������Ŀ
            //� Monta Array de 1 elemento �
            //� vazio. Se inclus�o.       �
            //�����������������������������
            IF nOpc == 3
                  If cCampo == "D1_COD"
                        nPosCod := i
                  ElseIf cCampo == "D1_LOCAL"
                        nPosLocal := i
                  ElseIf cCampo == "D1_TES"
                        nPosTes := i
                  ElseIf cCampo == "D1_NUMLOTE"
                        nPosLote := i
                  ElseIf cCampo == "D1_LOTECTL"
                        nPosLotCTL := i
                  EndIf
                  IF aHeader[i,8] == "C"
                        aCOLS[1][i] := SPACE(aHeader[i,4])
                  Elseif aHeader[i,8] == "N"
                        aCOLS[1][i] := 0
                  Elseif aHeader[i,8] == "D" .And. cCampo != "D1_DTVALID"
                        aCOLS[1][i] := dDataBase
                  Elseif aHeader[i,8] == "D" .And. cCampo == "D1_DTVALID"
                        nPosDValid:=i
                        aCOLS[1][i] := CriaVar("D1_DTVALID")
                  Elseif aHeader[i,8] == "M"
                        aCOLS[1][i] := ""
                  Else
                        aCOLS[1][i] := .F.
                  Endif
            Endif
      Next i
      aCOLS[1][Len(aHeader)+1] := .F.
EndIf

If (l100Auto)
   // Atualiza o aHeader e o aCols conforme aAutoItens
   MsAuto2aCols()
EndIf

Set Key VK_F12 To
aLivro	:=	{}
aIcm  	:=	{}
nTotIpi 	:= 0
nTotIcm 	:= 0
nValIcm 	:= 0
nRatIpiFre:= 0
nRatIpiDes:= 0
nRatIpiCon:= 0
nValTotItem:= 0
nValFun := 0
Continua := .F.

dDataSav := dDataBase
aSema := {}

If lConFrete .Or. lConImp
	//�������������������������������������������������������������Ŀ
	//� Inicializa campos necessarios dos itens da Nota Fiscal      �
	//���������������������������������������������������������������
	A100Clas(.F.,lConFrete)
EndIf

//����������������������������������������������������������������Ŀ
//� Ativa tecla F4 para comunicacao com pedidos de compra em aberto�
If !lConfrete.and.!lConImp
	If (ExistBlock("A100F4PC"))
		SetKey( VK_F4, { || ExecBlock("A100F4PC",.F.,.F.) } )
	Else
		SetKey( VK_F4, { || A100F4() } )
	EndIf
EndIf

cF3:='SA2'
cForn:=OemtoAnsi(STR0024)           //'Fornecedor'
nOpca := 0
cTipAnt := cTipo

If !l100Auto
	If (Type("l115Auto") == "U") .or. !(l115Auto)
		DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 28,80 OF oMainWnd         //"Nota de Entrada de Mercadorias"
	
		@ 11, 005 TO 48, 310 LABEL "" OF oDlg  PIXEL
	
		@ 18, 010 SAY OemtoAnsi(STR0011) SIZE 15, 7 OF oDlg PIXEL         //"Tipo"
		@ 18, 030 MSGET cTipo   PICTURE '!' ;
																	WHEN (!lConFrete .And. !lConImp);
																	VALID (lRet:=A100cTipo(cTipo,oCliFor,oForn,cTipAnt),cTipAnt:= IF(lRet,cTipo,cTipAnt),lRet);
																	SIZE 9, 10 OF oDlg PIXEL
	
		@ 18, 050 SAY OemtoAnsi(STR0012)   SIZE 50, 7 OF oDlg PIXEL       //"Formul�rio Pr�prio"
	
		If cFormul$"S" .And. lConFrete
				@ 18, 105 MSGET cFormul PICTURE "@!";
												WHEN .F.;
												SIZE 9, 10 OF oDlg PIXEL
		Else
				@ 18, 105 MSGET cFormul PICTURE "@!";
												WHEN !lConFrete .And. !(cFormul=='S');
												VALID A100VerForm(cFormul,oNFiscal,oSerie);
												SIZE 9, 10 OF oDlg PIXEL
		Endif
	
		If cFormul == "S"
				cNFiscal:= CriaVar("F1_DOC")
				cSerie  := SerieNfId("SF1",5,"F1_SERIE")
				cEspecie:= CriaVar("F1_ESPECIE")
		Endif
	
		@ 18, 125 SAY OemtoAnsi(STR0013) SIZE 40, 7 OF oDlg PIXEL         //"Nota Fiscal"
		If Len(cNFiscal)>6
				@ 18, 155 MSGET oNFiscal VAR cNFiscal     PICTURE PesqPict("SF1","F1_DOC");
																		VALID A100cNFis(cNFiscal) .And. CheckSX3("F1_DOC");
																		WHEN !lConFrete .And. !lConImp .And. !(cFormul=='S');
																		SIZE 45, 10 OF oDlg PIXEL
		Else
				@ 18, 170 MSGET oNFiscal VAR cNFiscal     PICTURE PesqPict("SF1","F1_DOC");
																		VALID A100cNFis(cNFiscal) .And. CheckSX3("F1_DOC");
																		WHEN !lConFrete .And. !lConImp .And. !(cFormul=='S');
																		SIZE 25, 10 OF oDlg PIXEL
		Endif
		@ 18, 205 SAY OemtoAnsi(STR0014) SIZE 15, 7 OF oDlg PIXEL         //"S�rie"
		@ 18, 225 MSGET oSerie VAR cSerie   PICTURE "!!!";
									WHEN (!lConFrete .And. !lConImp) .And.;
									cFormul $ " N" .And. cTipo $ "NCPIDB";
									SIZE 16, 10 OF oDlg PIXEL
	
		@ 18, 250 SAY OemtoAnsi(STR0015) SIZE 16, 7 OF oDlg PIXEL         //"Data"
		@ 18, 265 MSGET dDEmissao     VALID A100dDEmissao();
												SIZE 41, 10 OF oDlg PIXEL
	
		@ 33, 010 SAY oForn VAR cForn SIZE 40, 7 OF oDlg PIXEL
		@ 33, 050 MSGET oCliFor VAR cA100For      PICTURE "@K!";
										VALID A100Fornec(oLoja,@cLoja);
										WHEN (!lConFrete .And. !lConImp);
										F3 cF3 ;
										SIZE 30, 10 OF oDlg PIXEL
	
		@ 33, 090 MSGET oLoja   VAR cLoja PICTURE "@!";
										VALID A100Loja(oDlg,cTipo);
										WHEN (!lConFrete .And. !lConImp);
										SIZE 14, 10 OF oDlg PIXEL
	
		@ 33, 225 SAY OemtoAnsi(STR0019) SIZE 50,7 OF oDlg PIXEL          //"Tipo de Documento"
		@ 33, 272 MSGET cEspecie      PICTURE "@!" VALID CheckSx3("F1_ESPECIE");
																				F3 "42";
																				SIZE 17,10 OF oDlg PIXEL
		@ 122, 005 TO 143, 310 LABEL "" OF oDlg  PIXEL
		oGet := MSGetDados():New(50,5,124,310,nOpcx,"A100LinOk","A100TudOk","",.T.,IIF(lConImp.Or.lConFrete,aCPOS2,),,,nItens)
		bVoltaIcm := {|| nOpca:=0, IIf(Len(aSavaCols)>0,aCols:=aClone(aSavaCols),)}
		bOK := { || a100TudOk() .And. a100BOK(@nOpca,@oGet,lConFrete,lConImp,@lDesc,@aLivro,@aCusto,@cCondicao,@lDupl,@bVoltaIcm,@oDlg) }
	
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,{||nOpca :=0,oDlg:End()})
	EndIf
	If (Type("l115Auto") <> "U")
		If l115Auto
			n := Len(aCols)
			a100LinOk()
			a100TudOk()
			bVoltaIcm := {|| nOpca:=0, IIf(Len(aSavaCols)>0,aCols:=aClone(aSavaCols),)}
			a100BOK(@nOpca,@oGet,lConFrete,lConImp,@lDesc,@aLivro,@aCusto,@cCondicao,@lDupl,@bVoltaIcm,@oDlg)
			nOpca := 1
		EndIf
	EndIf

	If dDataSav != dDataBase
    	  Help( " ", 1, "ALTDATA" )
	EndIf

	Set Key VK_F4 To

	If nOpca==0
    	  Return
	EndIf

	If lAbandona
    	  lAbandona := .F.
	EndIf
Else
	aValidGet := {}
	Aadd(aValidGet,{"cTipo"    ,aAutoCab[SF1->(FieldPos("F1_TIPO"   )),2],"a100cTipo(cTipo )",.t.})
	Aadd(aValidGet,{"cFormul"  ,aAutoCab[SF1->(FieldPos("F1_FORMUL" )),2] ,"Pertence(' SN')" ,.f.})
	Aadd(aValidGet,{"cNFiscal" ,aAutoCab[SF1->(FieldPos("F1_DOC"    )),2] ,"A100cNFis(cNfiscal)",.t.})
	Aadd(aValidGet,{"cSerie"   ,aAutoCab[SF1->(FieldPos("F1_SERIE"  )),2] ,".t.",.t.})
	Aadd(aValidGet,{"dDEmissao",aAutoCab[SF1->(FieldPos("F1_EMISSAO")),2] ,"A100dDEmissao()",.t.})
	Aadd(aValidGet,{"ca100for" ,aAutoCab[SF1->(FieldPos("F1_FORNECE")),2] ,"A100Fornec(,@cLoja)",.t.})
	Aadd(aValidGet,{"cLoja"    ,aAutoCab[SF1->(FieldPos("F1_LOJA"   )),2] ,"A100Loja(,cTipo)",.t.})
	Aadd(aValidGet,{"cEspecie" ,aAutoCab[SF1->(FieldPos("F1_ESPECIE")),2] ,"CheckSX3('F1_ESPECIE')",.f.})
	dDataSav := dDataBase
	If ! SF1->(MsVldGAuto(aValidGet)) // consiste os gets
		Return .f.
	EndIf
	If ! SD1->(MsVldAcAuto(aValidGet,"A100LinOk(o)","A100TudOk(o)"))   // consiste o campos do Acols
		Return .f.
	EndIf
	nDifIPI	:= 0
	nDIfIcm	:= 0
	A100Rodape(.t.,lConfrete,lConImp,lDesc,@aLivro,@aCusto)
EndIf

lMat115:=.T.
lMat118:=.T.

//��������������������������������������������������������������Ŀ
//� Verifica a existencia de lanc. Padronizados p/ Importacao    �
//����������������������������������������������������������������
If lIntegracao
      lLancPad95:=VerPadrao("950")    // Itens de Importacao
Endif

//��������������������������������������������������������������Ŀ
//� Verifica a existencia de lanc. Padronizados p/ Compras       �
//����������������������������������������������������������������
lLancPad40:=VerPadrao("640")    // Devolucao de Vendas
lLancPad50:=VerPadrao("650")    // Debito de Estoque ou Debito de Despesas
lLancPad60:=VerPadrao("660")    // Credito de Forn. / Debito de IPI / Debito de ICMS

If cTipo $ "DB" .and. lLancPad40
      lLancPad50:=.F.
      lLancPad60:=.F.
Endif

If !lGeraLanc
      //�����������������������������������������������������Ŀ
      //� Nao Gerar os lancamento Contabeis On-Line           �
      //�������������������������������������������������������
      lLancPad40:=.F.
      lLancPad50:=.F.
      lLancPad60:=.F.
Endif

If (lLancPad40.Or.lLancPad50.Or.lLancPad60 .Or. lLancPad95) .And. (!__TTSInUse .OR. cPaisLoc == "PTG")
      //��������������������������������������������������������������Ŀ
      //� Posiciona numero do Lote para Lancamentos do Compras         �
      //����������������������������������������������������������������
      dbSelectArea("SX5")
      dbSeek(xFilial()+"09COM")
      cLoteCom:=IIF(Found(),Trim(X5Descri()),"COM ")
      nHdlPrv:=HeadProva(cLoteCom,"MATA100",Subs(cUsuario,7,6),@cArquivo)
      If nHdlPrv <= 0
            // Nao foi possivel criar o arquivo contra prova para esta nota,
            // para tal devera' ser utilizada a rotina de Lancto Off-Line.
            HELP(" ",1,"A100NOPRV")
      Endif
Endif

//��������������������������������������������������������������Ŀ
//� Verifica se algum produto utiliza CQ Quality (QIE)           �
//����������������������������������������������������������������
lQualiCQ := .F.
nPosCod  := aScan(aHeader,{|x|AllTrim(x[2])=='D1_COD'})
nPosItem := aScan(aHeader,{|x|AllTrim(x[2])=='D1_ITEM'})
nPosTES  := aScan(aHeader,{|x|AllTrim(x[2])=='D1_TES'})
For nX := 1 to Len(aCols)
	If AvalTes(aCols[nX,nPosTES],'S')
		If (lQualiCQ:=	A100CQQIE(If(nPosCod>0,aCols[nX,nPosCod],''),If(nPosItem>0,aCols[nX,nPosItem],''), cTipo, cNFiscal, cSerie, cA100For, cLoja, lConFrete, lConImp, lIntegracao))
			Exit
		EndIf
	EndIf	
Next nX

Begin Transaction
      A100Grava(cAlias,aCusto,aLivro,.F.,cCondicao,lConFrete,lConImp)
      // Processa Gatilhos
      EvalTrigger()
End Transaction

//������������������������������������������������������������������������������������������Ŀ
//�Para a localizacao Mexico, sera processada a funcao do ponto de entrada MT100AGR no padrao�
//��������������������������������������������������������������������������������������������
If cPaisLoc == "MEX"
	PgComMex()
Endif

//��������������������������������������������������������������������������Ŀ
//� Integracao com o ACD - Realiza o enderecamento automatico p/ o CQ 		 �
//� na classificacao da nota						  						 �
//����������������������������������������������������������������������������
If lIntACD
	CBMT100AGR()
//��������������������-��Ŀ
//� Pontos de Entrada     �
//���������������������-���
ElseIf lExistRDGT
	ExecTemplate("MT100AGR",.F.,.F.)
EndIf	

//���������������������������������������������������������������Ŀ
//� Agroindustria  	           					                 �
//�����������������������������������������������������������������
If FindFunction("OGXUtlOrig") //Encontra a fun��o
	If OGXUtlOrig()
	   If FindFunction("OGX140")
	      OGX140()
	   EndIf
	EndIf
EndIf

If lExistRDGr
	ExecBlock("MT100AGR",.F.,.F.)
EndIf	

If nHdlPrv > 0 .and. (lLancPad40.Or.lLancPad50.Or.lLancPad60 .Or. lLancPad95) .And. (!__TTSInUse .Or. cPaisLoc == "PTG")
      //�����������������������������������������������������Ŀ
      //� Envia para Lancamento Contabil, se gerado arquivo   �
      //�������������������������������������������������������
      RodaProva(nHdlPrv,nTotal)
      //�����������������������������������������������������Ŀ
      //� Envia para Lancamento Contabil, se gerado arquivo   �
      //�������������������������������������������������������
      If UsaSeqCor() 
        aCtbDia := {{"SF1",SF1->(RECNO()),SF1->F1_DIACTB,"F1_NODIA","F1_DIACTB"}}
      Else
        aCtbDia := {}
      EndIF    

      lLanctOk := cA100Incl(cArquivo,nHdlPrv,3,cLoteCom,lDigita,lAglutina,,,,,,aCtbDia)

      If lLanctOk
            RecLock("SF1",.F.)
            Replace F1_DTLANC With dDataBase            // Gravar a Dt.Lancto.Cont.
            MsUnLock()
      Endif
Endif

//����������������������������������������������������������������Ŀ
//� Ativa tecla F12 para ativar parametros de lancamentos contab.  �
//������������������������������������������������������������������
If !lConImp .And. !lConFrete
      Set Key VK_F12 To FAtiva()
EndIf

dbSelectArea(cAlias)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A100Classi� Autor � Claudinei M. Benzi    � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa para classificacao de notas ja' digitadas.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A100Classi(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A100Classi(cAlias,nReg,nOpcx)
Static lExistRDGr := NIL
Static lExistRDGT := NIL
Local nCnt:=0 ,i:=0,aCusto[0],oDlg,nOpca,oGet
Local nTotNot2
Local bCHAVE:={ || x:=xFILIAL()+dtos(dDataBase)+cDipi+cCFOP+cPOSFIS+cUM }
Local nPosSort:=0,lLancOk:=.F.,nRegSD1
Local dDataFec := MVUlmes()
Local aCpos[0], nTotMercTp:=0, aSortCols:={},nDifIPI := 0,nDifICM:=0
Local dDataSav := dDataBase, aSema := {}, bOK, bVoltaIcm
Local lConFrete:=.f., lConImp:=.f.
Local lIntACD	:= SuperGetMV("MV_INTACD",.F.,"0") == "1"
Local cCampo:=""
Local aCtbDia := {}

//-- Celerina
Local nX         := 0
Local lQualiCQ   := .F.
Local nPosItem   := 0
PRIVATE nIcmImp := 0
PRIVATE cTipo     := " "            ,cSerie := SerieNfId("SF1",5,"F1_SERIE"),cFormul:= " ",;
      dDEmissao:= dDataBase, nUsado   :=0              , nTotNot := 0,;
      dDatCont := dDataBase, nFatConv := 0,;
      lDupl:= .F.       , nTotPeso := 0          ,lRatValor := .F.,aFixos:=MatxAfixos(),;
      nValIcmAnt:= 0, nValFun := 0,;
      nPorBase:=1, nBaseIRRF := 0, cEspecie:=CriaVar("F1_ESPECIE"), dDigit:=dDataBase,;
		cMarca,nBaseInss:=0
PRIVATE  cNFiscal := CriaVar("F1_DOC"),cNaturez:="",nIrrf:=0,nResIRRF:=0,nTotIss :=0, nValInss := 0
PRIVATE aRegLock := {}       && Registra Registros Locados p/ MsUnLock
PRIVATE cDipi:="", cPosFis:="", cUM:="",nDQuant:=0, cCFOP:=""
PRIVATE nPosCod,nPosLocal,nPosTes,nPosLote,nPosLotCTL,nPosDValid

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0],aHeader[0],Continua,nOpc:=3,aDUPL[0]
PRIVATE CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999,;
      nTotMerc:=0,nValFrete:=0,nValDesp:=0,nValDesc:=0,;
      nBaseDup:=0,nBaseIpi :=0,nBaseIcm:=0,nTotIcm:=0,nTotIpi:=0,;
      nAdiantamento:=0,cSeekAdto,nBRetIcms:=0, nIcmsRet:=0,;
      lIcmsRet:=.F.,nValTotItem:=0,nBIcmsRet:=0,nVlrIcmRet:=0,;
      nBaseIcmRet:=0,nBTotIcmRet:=0,aIcmsSolid:={},nElemLivro:=0 ,;
      nRatIpiFre:=0,nRatIpiDes:=0,nRatIpiCon:=0,nBaseDup2:=0, nTotServ:=0   
PRIVATE cA100For := CriaVar("F1_FORNECE")
PRIVATE cLoja 	 := CriaVar("F1_LOJA")       
      
PRIVATE nTotBase:=0.00   , nBaseItem:=0.00, nBaseAnt:=0 , nBaseFrete:=0.00,;
      nBsFrete1:=0.00, aSalvaBase[300] , nTotbase1:=0, nTotBase2,nBsFretG:=0,;
      aSalvaIpi[300]
PRIVATE aSavaCols
PRIVATE aLivro:= {} , lDesc:=.F.
cSB6Ant:=""
l100 := .T.

lExistRDGT := If(lExistRDGT == NIL,ExistTemplate("MT100AGR"),lExistRDGT)
lExistRDGr := If(lExistRDGr == NIL,ExistBlock("MT100AGR"),lExistRDGr)

//��������������������������������������������������������������Ŀ
//� Inicializa array para Header da GetDados dos Itens NBM       �
//����������������������������������������������������������������
If lIntegracao
      PRIVATE aHeadNBM[0],lLancPad95,nUsadoNBM:=0
      //��������������������������������������������������������������Ŀ
      //� Abre arquivo SWN apenas nesta rotina                         �
      //����������������������������������������������������������������
      IF !ChkFile("SWN",.F.)
            HELP(" ",1,"SWNEmUso")
            Return .t.
      Endif
Endif


//��������������������������������������������������������������Ŀ
//� Verificar data do ultimo fechamento em SX6.                  �
//����������������������������������������������������������������
If dDataFec >= dDataBase
      Help( " ", 1, "FECHTO" )
      Return
EndIf

Afill(aSalvaBase,0)
Afill(aSalvaIpi,0)
lRecebto := .T.
dbSelectArea("SD1")
nReg := Recno()

If D1_FILIAL != xFilial()
      HELP(" ",1,"A000FI")
      Return (.T.)
Endif

//��������������������������������������������������������������Ŀ
//� Verifica se e' nota de recebimento para nao dar get na cabeca�
//����������������������������������������������������������������
IF Empty(D1_TES)
      cTipo    := IF( D1_TIPO == "R", "N",D1_TIPO )
      cNFiscal := D1_DOC
      cSerie   := D1_SERIE
      dDEmissao:= D1_EMISSAO
      cA100For := D1_FORNECE
      cLoja    := D1_LOJA
      dDigit   := D1_DTDIGIT
      //��������������������������������������������������������������Ŀ
      //� Posiciona ponteiro do arquivo cabeca e inicializa variaveis  �
      //����������������������������������������������������������������
      cSeek := SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
      dbSelectArea("SF1")
      dbSetOrder(1)
      dbSeek(xFilial()+cSeek)
      cFormul := F1_FORMUL
      cEspecie:= F1_ESPECIE
      SoftLock("SF1")
      Aadd(aRegLock,{"SF1",Recno()})
Else
      cSeek := SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
      If cPaisLoc == "BRA"
            HELP(" ",1,"A100CLASSI")
            Return (.T.)
      EndIf
Endif

//������������������������������������������������������������������������Ŀ
//� Carrega as perguntas selecionadas para saber se deve verificar cotacao �
//��������������������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01 - Se mostra e permite alterar lancamentos contabeis �
//� mv_par02 - Se deve aglutinar os lancamentos contabeis        �
//� mv_par03 - Se deve verificar o arquivo de cotacoes           �
//� mv_par04 - Se deve aplicacar o reajuste                      �
//� mv_par05 - Incluir na Amarracao ProdxFornecedor              �
//� mv_par06 - Lancto Contabil On-Line                           �
//����������������������������������������������������������������
lDigita  := IIF(mv_par01==1,.T.,.F.)
lAglutina:= IIF(mv_par02==1,.T.,.F.)
lReajuste:= IIF(mv_par04==1,.T.,.F.)
lAmarra  := IIF(mv_par05==1,.T.,.F.)
lGeraLanc:= IIF(mv_par06==1,.T.,.F.)
lConsLoja:= IIF(mv_par07==1,.T.,.F.)
IsTriangular((mv_par08==1))

//��������������������������������������������������������������Ŀ
//� Monta o aHeader da Nova GetDados dos Itens da NBM            �
//����������������������������������������������������������������
If lIntegracao
      If SF1->F1_IMPORT == "S"
            dbSelectArea("Sx2")
            dbSeek("SWN")
            dbSelectArea("Sx3")
            dbSeek("SWN")
            While !Eof() .And. (x3_arquivo == "SWN")
                  IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
                        nUsadoNBM++
                        AADD(aHeadNBM,{ OemToAnsi(TRIM(X3Titulo())), x3_campo, x3_picture,;
                              x3_tamanho, x3_decimal, x3_valid,;
                              x3_usado, x3_tipo, x3_arquivo, x3_context } )
                  Endif
                  dbSkip()
            End
            PRIVATE aColsNBM:={}
      Endif
Endif

//��������������������������������������������������������������Ŀ
//� Montagem do aHeader                                          �
//����������������������������������������������������������������
dbSelectArea("Sx3")
dbSeek(cAlias)
While !Eof() .And. (x3_arquivo == cAlias)
      IF x3uso(x3_usado) .AND. cNivel >= x3_nivel
            nUsado++
            AADD(aHeader,{ OEmtoAnsi(TRIM(X3Titulo())), x3_campo, x3_picture,;
                  x3_tamanho, x3_decimal, x3_valid,;
                  x3_usado, x3_tipo, x3_arquivo, x3_context } )
            IF ! Trim(x3_campo) $ "D1_QUANT/D1_QTSEGUM/D1_COD"
                  AADD(aCpos,x3_campo)
            Endif
      Endif
      dbSkip()
End

//��������������������������������������������������������������Ŀ
//� Montagem do aCols                                            �
//����������������������������������������������������������������
dbSelectArea(cAlias)
dbSetOrder(1)
dbSeek(xFilial()+cSeek)
nRegSD1 := Recno()

PRIVATE aCOLS:={}

nCnt := 0
While !Eof() .And. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == xFilial()+cSeek
	If !Empty(D1_TES)
      dbSelectArea(cAlias)
      dbSkip()
      Loop
   EndIf
      SoftLock("SD1")
      Aadd(aRegLock,{"SD1",Recno()})
      nCnt++
      AADD(aCols,Array(Len(aHeader)+1))
      For i:=1 to Len(aHeader)
            cCampo:=Alltrim(aHeader[i,2])
            If cCampo == "D1_COD"
                  nPosCod := i
            ElseIf cCampo == "D1_LOCAL"
                  nPosLocal := i
            ElseIf cCampo == "D1_TES"
                  nPosTes := i
            ElseIf cCampo == "D1_NUMLOTE"
                  nPosLote := i
            ElseIf cCampo == "D1_LOTECTL"
                  nPosLotCTL := i
            ElseIf cCampo == "D1_DTVALID"
                  nPosDValid := i
            ElseIf cCampo == "D1_ITEM"
                  nPosSort := i
            EndIf
            If aHeader[i,10] # "V"
                  aCOLS[Len(aCols)][i] := FieldGet(FieldPos(cCampo))
            ElseIf aHeader[i,10] == "V"
                  aCols[Len(aCols)][i] := CriaVar(cCampo)
            Endif
      Next i
      dbSelectArea(cAlias)
      dbSkip()
      aCOLS[Len(aCols)][Len(aHeader)+1] := .F.
End

//������������������������������������������������������Ŀ
//� Caso nao ache nenhum item , abandona rotina.         �
//��������������������������������������������������������
If nCnt == 0
      dbSetOrder(1)
      Return .T.
EndIf

//�������������������������������������������������������������Ŀ
//� Sortear o array aCols para que a digitacao na classificacao �
//� seja na mesma ordem que a digitacao do Recebimento Mata140. �
//���������������������������������������������������������������
aSortCols := ASort(aCols,,,{ |x, y| x[nPosSort] < y[nPosSort] })
aCols := AClone(aSortCols)

dbGoTo(nRegSD1)

//�������������������������������������������������������������Ŀ
//� Posiciona no arquivo de clientes ou fornecedores.           �
//���������������������������������������������������������������
If cTipo$'DB'
		SA1->(dbSetOrder(1))
      SA1->(dbSeek(xFilial("SA1")+cA100For+cLoja))
      cForn:=OemToAnsi(STR0025)           //'Cliente   '
      cTit:=OemToAnsi(STR0026)            //'Cliente: '
      cCondicao:=SA1->A1_COND
Else
		SA2->(dbSetOrder(1))
      SA2->(dbSeek(xFilial("SA2")+cA100For+cLoja))
      cForn:=OemToAnsi(STR0027)           //'Fornecedor'
      cTit:=OemToAnsi(STR0028)            //'Fornecedor: '
      cCondicao:=SA2->A2_COND
Endif

//�������������������������������������������������������������Ŀ
//� Inicializa campos necessarios dos itens da Nota Fiscal      �
//���������������������������������������������������������������
A100Clas(,,SF1->F1_IMPORT=="S")

//��������������������������������������������������������������Ŀ
//� Ponto de entrada na Classificacao.                           �
//����������������������������������������������������������������
IF (ExistBlock("MT100CLA"))
	ExecBlock("MT100CLA",.F.,.F.)
Endif

lEditCab := .F.

Set Key VK_F12 To

aLivro:={}
aIcm  :={}
nTotIpi := 0
nTotIcm := 0
nValTotItem:=0
nValFun := 0
Continua := .F.

dDataSav := dDataBase
aSema := {}

//��������������������������������������������������������������Ŀ
//� Utilizadas como parametro para consulta padrao F3            �
//����������������������������������������������������������������
// PRIVATE cArqF3 := "SF1",cCampoF3 := "F1_FORNECE"

//����������������������������������������������������������������Ŀ
//� Ativa tecla F4 para comunicacao com pedidos de compra em aberto�
//������������������������������������������������������������������
If (!lConfrete.and.!lConImp)
      SetKey( VK_F4,{ || A100F4()} )
Endif


nOpca := 0
DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 28,80 OF oMainWnd         //"Nota de Entrada de Mercadorias"

@ 11, 005 TO 48, 310 LABEL "" OF oDlg  PIXEL

@ 18, 010 SAY OemtoAnsi(STR0011) SIZE 15, 7 OF oDlg PIXEL         //"Tipo"
@ 18, 030 MSGET cTipo   PICTURE '@!' ;
																WHEN ( lEditCab );
																SIZE 9, 10 OF oDlg PIXEL

@ 18, 050 SAY OemtoAnsi(STR0012)   SIZE 50, 7 OF oDlg PIXEL       //"Formul�rio Pr�prio"
@ 18, 105 MSGET cFormul       PICTURE "@!";
																		WHEN ( lEditCab );
																		SIZE 9, 10 OF oDlg PIXEL
@ 18, 125 SAY OemtoAnsi(STR0013) SIZE 40, 7 OF oDlg PIXEL         //"Nota Fiscal"
If Len(cNFiscal)>6
		@ 18, 155 MSGET cNFiscal      PICTURE PesqPict("SF1","F1_DOC");
																				WHEN ( lEditCab );
																				SIZE 45, 10 OF oDlg PIXEL
Else
		@ 18, 170 MSGET cNFiscal      PICTURE PesqPict("SF1","F1_DOC");
																				WHEN ( lEditCab );
																				SIZE 25, 10 OF oDlg PIXEL
Endif
@ 18, 205 SAY OemtoAnsi(STR0014)SIZE 15, 7 OF oDlg PIXEL                //"S�rie"
@ 18, 225 MSGET cSerie  PICTURE "!!!";
																WHEN ( lEditCab );
																SIZE 16, 10 OF oDlg PIXEL

@ 18, 250 SAY OemtoAnsi(STR0015) SIZE 16, 7 OF oDlg PIXEL         //"Data"
@ 18, 265 MSGET dDEmissao           SIZE 39, 10 OF oDlg PIXEL

@ 33, 010 SAY cForn                 SIZE 40, 7 OF oDlg PIXEL
@ 33, 050 MSGET cA100For      PICTURE "@K!";
																		WHEN (.F.);
																		SIZE 30, 10 OF oDlg PIXEL
@ 33, 090 MSGET cLoja   PICTURE "@!";
																WHEN (.F.);
																SIZE 14, 10 OF oDlg PIXEL

If lIntegracao
		If SF1->F1_IMPORT == "S"
				@ 33,125 SAY OemtoAnsi(STR0018)     SIZE 40, 7 OF oDlg PIXEL            //"Conhecimento :"
				@ 33,170 MSGET SD1->D1_CONHEC PICTURE "@!";
																								WHEN ( lEditCab ) SIZE 40, 10 OF oDlg PIXEL
		Endif
Endif

@ 33, 225 SAY OemToAnsi(STR0019) SIZE 50,7 OF oDlg PIXEL          //"Tipo de Documento"
@ 33, 272 MSGET cEspecie      PICTURE "@!" WHEN ( lEditCab ) SIZE 25,10 OF oDlg PIXEL

@ 122,005 TO 143, 310 LABEL "" OF oDlg  PIXEL

@ 129,010 SAY OemToAnsi(STR0022)+DtoC(dDigit)+" "+OemtoAnsi(cTit)+IIf(cTipo$'DB',SA1->A1_NOME,SA2->A2_NOME) SIZE 150,7 OF oDlg PIXEL            //"Dt Entr:"

oGet := MSGetDados():New(50,5,124,310,nOpcx,"A100LinOk","A100TudOk","",.T.,aCpos)
If lIntegracao
		If SF1->F1_IMPORT == "S"
				oGet:oBrowse:bKeyDown:={|nKey,nFlags|A100F4(,,,nKey,nFlags,oGet)}
		Endif
Endif

bVoltaIcm := {|| nOpca:=0, IIf(Len(aSavaCols)>0,aCols:=aClone(aSavaCols),)}
bOK := { || a100BOK(@nOpca,@oGet,lConFrete,lConImp,@lDesc,@aLivro,@aCusto,@cCondicao,@lDupl,@bVoltaIcm,@oDlg) }

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,{||nOpca:=0,oDlg:End()})

If dDataSav != dDataBase
      Help( " ", 1, "ALTDATA" )
End

Set Key VK_F4 To

If lAbandona
      lAbandona := .F.
      //������������������������������������������������������Ŀ
      //� libera os registros locados pelo softlock()          �
      //��������������������������������������������������������
      LibLock(aRegLock)
      aRegLock := {}
      Return .f.
EndIf

If nOpcA == 1                                   // Confirma a Tela de Duplicatas
      //��������������������������������������������������������������Ŀ
      //� Verifica a existencia de lanc. Padronizados p/ Importacao    �
      //����������������������������������������������������������������
      If lIntegracao
            lLancPad95:=VerPadrao("950")    // Itens de Importacao
      Endif

      //��������������������������������������������������������������Ŀ
      //� Verifica a existencia de lanc. Padronizados p/ Compras       �
      //����������������������������������������������������������������
      lLancPad40:=VerPadrao("640")    // Devolucao de Vendas
      lLancPad50:=VerPadrao("650")    // Debito de Estoque ou Debito de Despesas
      lLancPad60:=VerPadrao("660")    // Credito de Forn. / Debito de IPI / Debito de ICMS

      If !lGeraLanc .OR. __TTSINUSE .Or. cPaisLoc <> "PTG"
            //�����������������������������������������������������Ŀ
            //� Nao Gerar os lancamento Contabeis On-Line           �
            //�������������������������������������������������������
            lLancPad40:=.F.
            lLancPad50:=.F.
            lLancPad60:=.F.
            lLancPad95:=.F.
            lGeraLanc :=.F.
      Endif

      If (lLancPad40 .Or. lLancPad50 .Or. lLancPad60 .Or. lLancPad95) .And. (!__TTSInUse .Or. cPaisLoc == "PTG")
            //��������������������������������������������������������������Ŀ
            //� Posiciona numero do Lote para Lancamentos do Compras         �
            //����������������������������������������������������������������
            dbSelectArea("SX5")
            dbSeek(xFilial()+"09COM")
            cLoteCom:=IIF(Found(),Trim(X5Descri()),"COM ")
            nHdlPrv:=HeadProva(cLoteCom,"MATA100",Subs(cUsuario,7,6),@cArquivo)
            If nHdlPrv <= 0
                  // Nao foi possivel criar o arquivo contra prova para esta nota,
                  // para tal devera' ser utilizada a rotina de Lancto Off-Line.
                  HELP(" ",1,"A100NOPRV")
            Endif
      Endif
      
		//��������������������������������������������������������������Ŀ
		//� Verifica se algum produto utiliza CQ Quality (QIE)           �
		//����������������������������������������������������������������
		lQualiCQ := .F.
		nPosCod  := aScan(aHeader,{|x|AllTrim(x[2])=='D1_COD'})
		nPosItem := aScan(aHeader,{|x|AllTrim(x[2])=='D1_ITEM'})
		nPosTES  := aScan(aHeader,{|x|AllTrim(x[2])=='D1_TES'})
		For nX := 1 to Len(aCols)
			If AvalTes(aCols[nX,nPosTES],'S')
				If (lQualiCQ:=	A100CQQIE(If(nPosCod>0,aCols[nX,nPosCod],''),If(nPosItem>0,aCols[nX,nPosItem],''), cTipo, cNFiscal, cSerie, cA100For, cLoja, lConFrete, lConImp, lIntegracao))
					Exit
				EndIf
			EndIf	
		Next nX
		
		Begin Transaction

		A100Grava(cAlias,aCusto,aLivro,.T.,cCondicao,lConFrete,lConImp)
		// Processa Gatilhos
		EvalTrigger()

		End Transaction

		//������������������������������������������������������������������������������������������Ŀ
		//�Para a localizacao Mexico, sera processada a funcao do ponto de entrada MT100AGR no padrao�
		//��������������������������������������������������������������������������������������������
		If cPaisLoc == "MEX"
			PgComMex()
		Endif

		//��������������������������������������������������������������������������Ŀ
		//� Integracao o modulo ACD - Realiza o enderecamento automatico p/ o CQ 	 �
		//� na classificacao da nota						  						 �
		//����������������������������������������������������������������������������
		If lIntACD
			CBMT100AGR()
		//��������������������-��Ŀ
		//� Pontos de Entrada     �
		//���������������������-���
		ElseIf lExistRDGT
			ExecTemplate("MT100AGR",.F.,.F.)
		EndIf	

		If lExistRDGr
			ExecBlock("MT100AGR",.F.,.F.)
		EndIf
       //���������������������������������������������������������������Ŀ
       //� Agroindustria  									          �
		//�����������������������������������������������������������������
		If FindFunction("OGXUtlOrig") //Encontra a fun��o
			If OGXUtlOrig()
			   If FindFunction("OGX140")
			      OGX140()
			   EndIf
			EndIf                
      EndIf                       
		
      If nHdlPrv > 0 .And. (lLancPad40.Or.lLancPad50.Or.lLancPad60 .Or. lLancPad95) .And. (!__TTSInUse .Or. cPaisLoc == "PTG")

            //�����������������������������������������������������Ŀ
            //� Envia para Lancamento Contabil, se gerado arquivo   �
            //�������������������������������������������������������
            RodaProva(nHdlPrv,nTotal)

            //�����������������������������������������������������Ŀ
            //� Envia para Lancamento Contabil, se gerado arquivo   �
            //�������������������������������������������������������
            If UsaSeqCor() 
          		aCtbDia := {{"SF1",SF1->(RECNO()),SF1->F1_DIACTB,"F1_NODIA","F1_DIACTB"}}
				Else
          		aCtbDia := {}
        		EndIF    

            lLanctOk := cA100Incl(cArquivo,nHdlPrv,3,cLoteCom,lDigita,lAglutina,,,,,,aCtbDia)

            If lLanctOk
                  RecLock("SF1",.F.)
                  Replace F1_DTLANC With dDataBase            // Gravar a Dt.Lancto.Cont.
                  MsUnLock()
            Endif
      Endif
Else
      //������������������������������������������������������Ŀ
      //� libera os registros locados pelo softlock()          �
      //��������������������������������������������������������
      LibLock(aRegLock)
      aRegLock := {}
Endif

Set Key VK_F12 To FAtiva()
//������������������������������������������������������Ŀ
//� Fechar o arq. de Itens da NBM se Integracao          �
//��������������������������������������������������������
If Select("SWN") > 0
      dbSelectArea("SWN")
      dbCloseArea()
Endif
dbSelectArea(cAlias)
dbGoTo(nReg)

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A100Deleta� Autor � Claudinei M. Benzi    � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de exclusao de notas fiscai de entrada.           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A100Deleta(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A100Deleta(cAlias,nReg,nOpcx,lImpFrete)
Local cSeek, nCnt, oDlg,nOpca,oGet
LOCAL cSeek1,cChave,cCompara
Local nMultiplic := -1, cPref, nResiduo,lLanctOk:=.F.
Local nRegSD1
Local cSaveArea:="" , nSaveOrd:=0
Local nQtPD3 :=0, nSaldo := 0, aSaldo:= {}
Local dDataFec := MVUlmes()
Local lExit:=.F.,zi:=0,nPosCod,nPosLocal,nPosQtd,nPosTES
Local cCampo:="",i
Local lIntACD	 := SuperGetMV("MV_INTACD",.F.,"0") == "1"
Local l100DeletT := ExistTemplate("A100DEL") 
Local l100Deleta := ExistBlock("A100DEL")
Local lEstNeg    := (GetMV('MV_ESTNEG')=='S')
Local nSaldoB2   := 0
Local lAborta    := .F.
Local aAreaSD7   := {}
Local aAreaSD7a  := {}
Local aAreaSC7   := {}
Local cSeekSD7   := ''
Local cSeekSD3   := ''
Local cSeekSWN   := ''
Local nRecSD7    := 0
Local nX         := 0
Local cLocOrigB6 := ''
Local l100ExcluT := ExistTemplate("A100EXC") 
Local l100Exclus := ExistBlock("A100EXC")
Local lDclNew 	 := SuperGetMv("MV_DCLNEW",.F.,.F.)
Local cMV_2DUPREF:= GetMV("MV_2DUPREF")
Local lSD1100E 	 := ExistBlock("SD1100E")
Local lTSD1100E  := ExistTemplate("SD1100E")
Local cMV_FATDIST:= GetMV("MV_FATDIST")

//-- Variaveis utilizadas pela funcao da Celerina
Local nAtraso    := 0
Local aEnvCele   := {}
Local aRecCele   := {}
Local aAOpen     := {}
Local aAlias     := {}
Local aStru      := {}
Local lQualiCQ   := .F.
Local aRecSE2    := {}
Local nPosItem   := 0
Local aAreaSB2   := {}
Local cLocCQ     := GetMV('MV_CQ')
Local cLotCtlQie := ''
Local cNumLotQie := ''

Local aInfoIRRF := {},;
      cMVUniao  := GetMV( "MV_UNIAO" ),;
      nAux01    := 0
Local aInfoISS := {},;
	cMVMUNIC := GetMV("MV_MUNIC"),;
	nAuxIss	 := 0
Local aInfoINSS := {},;
      cMVForIns := GetMV( "MV_FORINSS" ),;
      nAuxInss  := 0

LOCAL cTpTit := Substr(MVNOTAFIS,1,3)
LOCAL l100TpTit := (ExistBlock("A100TPTI"))
PRIVATE nIcmImp := 0
//�������������������������������������������������������������������������Ŀ
//� Variavel usada para informar se a rotina foi chamada do MATA115/MATA118.�
//���������������������������������������������������������������������������
lImpFrete:=IIF(lImpFrete==NIL,.f.,lImpFrete)
lImpFrete:=IIF(ValType(lImpFrete) != "L",.F.,lImpFrete)

//��������������������������������������������������������������Ŀ
//� Verificar data do ultimo fechamento em SX6.                  �
//����������������������������������������������������������������
If dDataFec >= dDataBase  .Or.;
            dDataFec >= D1_DTDIGIT
      Help( " ", 1, "FECHTO" )
      Return (.F.)
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica ultima data para operacoes fiscais                  �
//����������������������������������������������������������������
If !FisChkExc(D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA)
	Return(.F.)
Endif

//��������������������������������������������������������������Ŀ
//� Validacao quando utilizado o modulo de Distribuicao          �
//����������������������������������������������������������������
If GetMV("MV_FATDIST") == "S" // Apenas quando utilizado pelo modulo de Distribuicao
	If !D100Deleta()
		Return.F.
    Endif
EndIf 
					  
//���������������������������������������������������Ŀ
//� integracao com o modulo ACD		  				  �
//�����������������������������������������������������
If lIntACD
	If !(CBA100DEL())
		Return .f.
	EndIf	
//��������������������������������������������������������������Ŀ
//� Ponto de entrada para permitir ou nao a exclusao             �
//����������������������������������������������������������������
ElseIf l100DeletT
	If !(ExecTemplate("A100DEL",.F.,.F.))
		Return .F.
	Endif
Endif
If l100ExcluT
	If !(ExecTemplate("A100EXC",.F.,.F.))
		Return .F.
	Endif
Endif   
If l100Deleta
	If !(Execblock("A100DEL",.F.,.F.))
		Return .F.
	Endif
Endif   
If l100Exclus
	If !(Execblock("A100EXC",.F.,.F.))
		Return .F.
	Endif
Endif

Set Key VK_F12 To

dbSelectArea(cAlias)
IF D1_FILIAL != xFilial()
	HELP(" ",1,"A000FI")
   Return (.F.)
Endif

#IFDEF SHELL
      IF D1_CANCEL == "S"
            HELP(" ",1,"NFCANC")
            Return (.F.)
      EndIf

      //���������������������������������������������������������������Ŀ
      //� Verifica se a exclusao deixara os produtos com saldo negativo �
      //� Ana Claudia - 26/03/98                                                            �
      //�����������������������������������������������������������������
      If VerifProd(SD1->D1_DOC,SD1->D1_SERIE)
            Help(" ",1,"SLDNEGZERO")
      EndIf
#ENDIF

//��������������������������������������������������������������Ŀ
//� mv_par01 - Se mostra e permite alterar lancamentos contabeis �
//� mv_par02 - Se deve aglutinar os lancamentos contabeis        �
//� mv_par03 - Se deve verificar o arquivo de cotacoes           �
//� mv_par04 - Se deve aplicacar o reajuste                      �
//� mv_par05 - Incluir na Amarracao ProdxFornecedor              �
//� mv_par06 - Lancto Contabil On-Line                           �
//� mv_par07 - Considera Loja no PC          Sim Nao             �
//����������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Nao excluir nota de recebimento para nao dar get na cabeca   �
//����������������������������������������������������������������
IF Empty(D1_TES)
      HELP(" ",1,"A100NOCLAS")
      Return (.F.)
EndIf
//��������������������������������������������������������������Ŀ
//� Nao excluir nota de Conhecimento de Frete / Desp. Importacao �
//����������������������������������������������������������������
If D1_TIPO == "C" .And. (D1_ORIGLAN == "FR" .Or. D1_ORIGLAN == "DP") .And. !lImpFrete
      If D1_ORIGLAN == "FR"
            HELP(" ",1,"A100NDELFR")
      Else
            HELP(" ",1,"A100NDELDP")
      EndIf
      Return (.F.)
EndIf

PRIVATE dDatCont := dDataBase ,nUsado := 0,  aRegLock := {}
//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aHeader[0],Continua,nOpc:=3,aDUPL[0]

//��������������������������������������������������������������Ŀ
//� Montagem do aHeader                                          �
//����������������������������������������������������������������
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)
While !Eof() .And. (x3_arquivo == cAlias)
      IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
            nUsado++
            AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
                  x3_tamanho, x3_decimal, x3_valid,;
                  x3_usado, x3_tipo, x3_arquivo, x3_context } )
            If Trim(x3_campo) == "D1_COD"
                  nPosCod := nUsado
            ElseIf Trim(x3_campo) == "D1_LOCAL"
                  nPosLocal := nUsado 
            ElseIf Trim(x3_campo) == "D1_TES"      
                  nPosTES   := nUsado 
            EndIf                          
      Endif
      dbSkip()
End

//��������������������������������������������������������������Ŀ
//� Posiciona ponteiro do arquivo cabeca e inicializa variaveis  �
//����������������������������������������������������������������
cSeek    := SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
dbSelectArea("SF1")
dbSetOrder(1)
dbSeek(xFilial()+cSeek)
SoftLock("SF1")
Aadd(aRegLock,{"SF1",Recno()})
PRIVATE cTipo    :=F1_TIPO  ,cNFiscal :=F1_DOC     ,cSerie  :=F1_SERIE,;
      dDEmissao:=F1_EMISSAO ,nTotNot  :=F1_VALBRUT ,cA100For:=F1_FORNECE,;
      nTotMerc :=F1_VALMERC ,nValFrete:=F1_FRETE   ,nValDesp:=F1_DESPESA,;
      nTotIcm  :=F1_VALICM  ,nTotIpi  :=F1_VALIPI  ,nValDesc:=F1_DESCONT,;
      cLoja    :=F1_LOJA    ,nBRetIcms:=F1_BRICMS  ,nIcmsRet :=F1_ICMSRET,;
      nBaseFrete:=F1_BASEFD ,nTotBase2 :=F1_BASEICM ,nBaseItem:=0.00,;
      nlIcmsRet:=.F.        ,aCampos  :={}         ,nValFun:=F1_CONTSOC,;
      cFormul  :=F1_FORMUL ,dDigit   := F1_DTDIGIT, cEspecie:=F1_ESPECIE
PRIVATE aLivro:={}, lDesc:=.F.

//��������������������������������������������������������������Ŀ
//� Montagem do aCols                                            �
//����������������������������������������������������������������
dbSelectArea(cAlias)
dbSetOrder(1)
dbSeek(xFilial()+cSeek)
nRegSD1 := Recno()

PRIVATE aCols:={}

nCnt := 0
While !Eof() .And. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == xFilial("SD1")+cSeek

      SoftLock("SD1")
      Aadd(aRegLock,{"SD1",Recno()})

      //��������������������������������������������������������������Ŀ
      //� Locar todos os registros pertinentes a cada item da NF       �
      //����������������������������������������������������������������
      If !Empty(SD1->D1_PEDIDO+SD1->D1_ITEMPC)
				If a100SeekPC(SD1->D1_PEDIDO,SD1->D1_ITEMPC,SD1->D1_COD,xFilial("SC7"),SD1->D1_FORNECE)
                  SoftLock("SC7")
                  Aadd(aRegLock,{"SC7",Recno()})
            Endif
      Endif

		dbSelectArea('SD7')
		dbSetOrder(1)
		If dbSeek(cSeekSD7:=(xFilial('SD7')+SD1->D1_NUMCQ+SD1->D1_COD+SD1->D1_LOCAL), .F.)
			Do While !SD7->(Eof()) .And. cSeekSD7 == D7_FILIAL+D7_NUMERO+D7_PRODUTO+D7_LOCAL
				SoftLock('SD7')
				aAdd(aRegLock,{'SD7', Recno()})
				//-- Movimentacoes Internas Referentes a CQ
				dbSelectArea('SD3')
				dbSetOrder(4)
				If dbSeek(cSeekSD3:=(xFilial('SD3')+SD7->D7_NUMSEQ), .F.)
					Do While !SD3->(Eof()) .And. cSeekSD3 == D3_FILIAL+D3_NUMSEQ
						If aScan(aRegLock, {|x|x[1]=='SD3'.And.x[2]==Recno()}) == 0
							SoftLock('SD3')
							aAdd(aRegLock,{'SD3', Recno()})
						EndIf	
						dbSkip()
					EndDo
				EndIf
				dbSelectArea('SD7')
				dbSkip()
			EndDo
		EndIf

      dbSelectArea("SA5")
      dbSetOrder(1)
      dbSeek(xFilial()+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD)
      If Found()
            SoftLock("SA5")
            Aadd(aRegLock,{"SA5",Recno()})
      Endif

      aInfoIRRF := {}
		aInfoISS  := {}
      aInfoINSS := {}
      cPref:=&(cMV_2DUPREF)
      cPref+=Space(Len(SE2->E2_PREFIXO) - Len(cPref))
		//����������������������������������������������������������Ŀ
		//� Verifica o tipo dos titulos gerados                      �
		//������������������������������������������������������������
		If l100TpTit
			cTpTit := ExecBlock("A100TPTI",.F.,.F.)
		Else
			cTpTit := Substr(MVNOTAFIS,1,3)
		EndIf

      dbSelectArea("SE2")
      dbSetOrder(1)
      dbSeek( xFilial()+cPref+SD1->D1_DOC )
      While !Eof() .And. xFilial()+cPref+SD1->D1_DOC == E2_FILIAL+E2_PREFIXO+E2_NUM
            If SD1->D1_FORNECE+SD1->D1_LOJA == E2_FORNECE+E2_LOJA .And. E2_TIPO == cTpTit
                  SoftLock("SE2")
                  Aadd(aRegLock,{"SE2",Recno()})
						aAdd(aRecSE2,SE2->(RecNo()))
                  If (SE2->E2_IRRF # 0)
                        AAdd( aInfoIRRF,{ SE2->E2_PREFIXO,;
                              SE2->E2_NUM,;
                              SE2->E2_PARCIR,;
                              PadR( MVTAXA,Len( SE2->E2_TIPO ) ),;
                              PadR( cMVUniao,Len( SE2->E2_FORNECE ) ),;
                              "00" } )
                  EndIf
						If (SE2->E2_ISS # 0)
							AAdd( aInfoISS,{ SE2->E2_PREFIXO,;
								SE2->E2_NUM,;
								SE2->E2_PARCISS,;
								PadR( MVISS,Len( SE2->E2_TIPO ) ),;
								PadR( cMVMUNIC,Len( SE2->E2_FORNECE ) ),;
								"00" } )
						EndIf
                  If (SE2->E2_INSS # 0)
                        AAdd( aInfoINSS,{ SE2->E2_PREFIXO,;
                              SE2->E2_NUM,;
                              SE2->E2_PARCINS,;
                              PadR( MVINSS,Len( SE2->E2_TIPO ) ),;
                              PadR( cMVForIns,Len( SE2->E2_FORNECE ) ),;
                              "00" } )
                  EndIf
            Endif
            dbSkip()
      End

      For nAux01 := 1 To Len( aInfoIRRF )
			If DbSeek( xFilial( "SE2" )+aInfoIRRF[ nAux01,1 ];
         				               +aInfoIRRF[ nAux01,2 ];
                     				   +aInfoIRRF[ nAux01,3 ];
				                        +aInfoIRRF[ nAux01,4 ];
            				            +aInfoIRRF[ nAux01,5 ];
                        				+aInfoIRRF[ nAux01,6 ],.F. )

					SoftLock( "SE2" )
					AAdd( aRegLock,{ "SE2",Recno() } )
					aAdd(aRecSE2,SE2->(RecNo()))
            EndIf
      Next
		For nAuxIss := 1 To Len( aInfoISS )
			If dbSeek(xFilial("SE2")+aInfoISS[nAuxIss,1];
					+aInfoISS[ nAuxIss,2 ];
					+aInfoISS[ nAuxIss,3 ];
					+aInfoISS[ nAuxIss,4 ];
					+aInfoISS[ nAuxIss,5 ];
					+aInfoISS[ nAuxIss,6 ],.F. )
				SoftLock( "SE2" )
				AAdd( aRegLock,{ "SE2",Recno() } )
				aAdd(aRecSE2,SE2->(RecNo()))
			EndIf
		Next
		For nAuxInss := 1 To Len( aInfoINSS )
      	If DbSeek( xFilial( "SE2" )+aInfoINSS[ nAuxInss,1 ];
          				            	+aInfoINSS[ nAuxInss,2 ];
                     				   +aInfoINSS[ nAuxInss,3 ];
				                        +aInfoINSS[ nAuxInss,4 ];
            				            +aInfoINSS[ nAuxInss,5 ];
                        				+aInfoINSS[ nAuxInss,6 ],.F. )

  				SoftLock( "SE2" )
            AAdd( aRegLock,{ "SE2",Recno() } )
				aAdd(aRecSE2,SE2->(RecNo()))
  			EndIf
      Next

		//������������������������������������������������������Ŀ
		//� Integracao do Ativo Fixo -  Travamento.              �
		//��������������������������������������������������������
		If ( !Empty(SD1->D1_CBASEAF) )
			dbSelectArea("SN1")
			dbSetOrder(1)
			If ( dbSeek(xFilial("SN1")+SD1->D1_CBASEAF) )
				SoftLock( "SN1" )
				AAdd( aRegLock,{ "SN1",Recno() } )
			EndIf
		EndIf

      dbSelectarea("SD1")
      nCnt++
      AADD(aCols,Array(Len(aHeader)))
      For i:=1 to Len(aHeader)
            cCampo:=Alltrim(aHeader[i,2])
            If aHeader[i,10] # "V"
                  aCOLS[Len(aCols)][i] := FieldGet(FieldPos(cCampo))
            ElseIF aHeader[i,10] == "V" // vsi x3_context == "V"
                  aCOLS[Len(aCols)][i] := CriaVar(cCampo)
            Endif
      Next i
      //��������������������������������������������������������������Ŀ
      //� Verifica a existencia do CIAP                                �
      //����������������������������������������������������������������
      If ( !Empty(SD1->D1_CODCIAP ) )
			dbSelectArea("SF9")
			dbSetOrder(1)
			If ( dbSeek(xFilial("SF9")+SD1->D1_CODCIAP) )   
				If !Empty( SN1->N1_CODCIAP )             
            
					If  (((!Empty(SD1->D1_CBASEAF) .And. SF9->F9_ICMIMOB != SN1->N1_ICMSAPR).Or.(Empty(SD1->D1_CBASEAF) .And.SF9->F9_ICMIMOB != 0)).Or.;
								 SF9->F9_BXICMS != 0 .Or. SF9->F9_MOTIVO != " ")
						Help(" ",1,"A100CIAPDE")
						dbSelectArea(cAlias)
						dbGoto(nReg)
						Return(.F.)
					EndIf
				EndIf
			EndIf
		EndIf 	
      dbSelectArea(cAlias)
      dbSkip()
End
dbGoto(nRegSD1)

//������������������������������������������������������Ŀ
//� Caso nao ache nenhum item , abandona rotina.         �
//��������������������������������������������������������
If nCnt == 0
      dbSetOrder(1)
      Return .F.
EndIf

//�����������������������������������������������������Ŀ
//� Verifica se algum produto est� sendo inventariado.  �
//�������������������������������������������������������
For zi:=1 to Len(aCols)
      If BlqInvent(aCols[zi,nPosCod],aCols[zi,nPosLocal])
            Help(" ",1,"BLQINVENT",,aCols[zi,nPosCod]+STR0064+aCols[zi,nPosLocal],1,11) //" Almox: "
            lExit:=.T.
      EndIf
	 //�����������������������������������������������������Ŀ
	 //� Analisa se o tipo do armazem permite a movimentacao |
	 //�������������������������������������������������������
	 If !lExit .And. AvalBlqLoc(aCols[zi,nPosCod],aCols[zi,nPosLocal],aCols[zi,nPosTES])
	 	lExit := .T.
	 EndIf
	
Next i

If lExit
      //��������������������������������������������������������������Ŀ
      //� Restaura a integridade da janela. Nao Processar a Exclusao.  �
      //����������������������������������������������������������������
      dbSelectArea(cAlias)
      dbGoto(nReg)
      Return .F.
EndIf

//�����������������������������������������������������Ŀ
//� Carrega as perguntas selecionadas                   �
//�������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01 - Se mostra e permite alterar lancamentos contabeis �
//� mv_par02 - Se deve aglutinar os lancamentos contabeis        �
//� mv_par03 - Se deve verificar o arquivo de cotacoes           �
//� mv_par04 - Se deve aplicacar o reajuste                      �
//� mv_par05 - Incluir na Amarracao ProdxFornecedor              �
//� mv_par06 - Lancto Contabil On-Line                           �
//����������������������������������������������������������������
If lImpFrete
	Pergunte("MTA100",.F.)
EndIf	
lDigita  := IIF(mv_par01==1,.T.,.F.)
lAglutina:= IIF(mv_par02==1,.T.,.F.)
lReajuste:= IIF(mv_par04==1,.T.,.F.)
lAmarra  := IIF(mv_par05==1,.T.,.F.)
lGeraLanc:= IIF(mv_par06==1,.T.,.F.)
//lAjustCom:= IIF(mv_par07==1,.T.,.F.)
lConsLoja:= IIF(mv_par07==1,.T.,.F.)
IsTriangular((mv_par08==1))

nopca := 0

DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 28,80 OF oMainWnd         //"Nota de Entrada de Mercadorias"

@ 11, 005 TO 48, 310 LABEL "" OF oDlg  PIXEL

@ 18, 010 SAY OemtoAnsi(STR0011) SIZE 15,7 OF oDlg PIXEL          //"Tipo"
@ 18, 030 MSGET cTipo           SIZE 9,10 OF oDlg PIXEL WHEN (.F.)
@ 18, 050 SAY OemtoAnsi(STR0012) SIZE 50, 7 OF oDlg PIXEL         //"Formul�rio Pr�prio"
@ 18, 105 MSGET cFormul         SIZE 9,10 OF oDlg PIXEL WHEN (.F.)
@ 18, 125 SAY OemtoAnsi(STR0013) SIZE 40, 7 OF oDlg PIXEL         //"Nota Fiscal"
If Len(cNFiscal)>6
		@ 18, 155 MSGET cNFiscal        SIZE 45,10 OF oDlg PIXEL PICTURE"@R 9999-99999999";
																			 WHEN (.F.)
Else
		@ 18, 170 MSGET cNFiscal        SIZE 25,10 OF oDlg PIXEL WHEN (.F.)
Endif
@ 18, 205 SAY OemtoAnsi(STR0014)SIZE 15,7 OF oDlg PIXEL           //"S�rie"
@ 18, 225 MSGET cSerie          SIZE 16,10 OF oDlg PIXEL WHEN (.F.)
@ 18, 250 SAY OemtoAnsi(STR0015) SIZE 16,7 OF oDlg PIXEL          //"Data"
@ 18, 265 MSGET dDEmissao       SIZE 39,10 OF oDlg PIXEL WHEN (.F.)

If cTipo $ "DB"
		@ 33, 010 SAY OemtoAnsi(STR0016) SIZE 40, 7 OF oDlg PIXEL         //"Cliente   "
Else
		@ 33, 010 SAY OemtoAnsi(STR0017) SIZE 40, 7 OF oDlg PIXEL         //"Fornecedor"
Endif
@ 33, 050 MSGET cA100For          SIZE 30, 10 OF oDlg PIXEL WHEN (.F.)
@ 33, 085 MSGET cLoja             SIZE 14, 10 OF oDlg PIXEL WHEN (.F.)
If lIntegracao
		If SF1->F1_IMPORT == "S"
				@ 33,125 Say STR0018 SIZE 40, 7 OF oDlg PIXEL         //"Conhecimento :"
				@ 33,170 MSGET SD1->D1_CONHEC SIZE 40, 10 OF oDlg PIXEL WHEN (.F.)
		Endif
Endif
@ 33, 225 SAY OemtoAnsi(STR0019) SIZE 50,7 OF oDlg PIXEL          //"Tipo de Documento"
@ 33, 272 MSGET cEspecie              SIZE 25,10 OF oDlg PIXEL WHEN (.F.)

dbSelectArea(IIF(cTipo$"DB","SA1","SA2"))
dbSeek(xFilial()+SubStr(cA100For,1,Len(SA2->A2_COD))+cLoja)

@ 122, 005 TO 143, 310 LABEL "" OF oDlg  PIXEL
cTit := IIF(cTipo$'DB',STR0020,STR0021)         //'Cliente: '###'Fornecedor: '
@ 129,010 SAY OemToAnsi(STR0022)+DtoC(dDigit)+" "+OemtoAnsi(cTit)+IIf(cTipo$'DB',SA1->A1_NOME,SA2->A2_NOME) SIZE 150,7 OF oDlg PIXEL            //"Dt Entr:"
@ 129,200 SAY OemtoAnsi(STR0023) SIZE 45,7 OF oDlg PIXEL          //'Total da Nota'
@ 129,250 MSGET nTotNot PICTURE "@E 999,999,999,999.99" SIZE 50,10 OF oDlg PIXEL RIGHT WHEN (.F.)

oGet := MSGetDados():New(50,5,124,310,nOpcx,"A100LinOk","A100TudOk","",.F.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nopca:=1,If(A100Rodape(.F.),oDlg:End(),nopca:=0)},{||oDlg:End()})

If nOpcA == 1
      If lIntegracao
            If SF1->F1_IMPORT == "S"
                  If CloseOpen({"SC5","SC6"},{"SWN","SW6","SWD"})
                        dbSelectArea(cAlias)
                        dbGoto(nReg)
                        Return .F.
                  Endif
            Endif
      Endif
      lmat115:=.T.
      lmat118:=.T.
		//��������������������������������������������������������������Ŀ
		//� Verifica se podemos excluir o lote e a Localizacao           �
		//����������������������������������������������������������������
		If A100Lote() .Or. A100Localiz()
         //��������������������������������������������������������������Ŀ
         //� Restaura a integridade da janela. Nao Processar a Exclusao.  �
         //����������������������������������������������������������������
         dbSelectArea(cAlias)
         dbGoTo( nReg )
         Return .F.
      Endif

      dbSelectArea("SF1")    // cabecalho das notas de entrada
      dbSeek(xFilial()+cSeek)
      //��������������������������������������������������������������Ŀ
      //� Verifica a existencia de lanc. no contas a Pagar             �
      //����������������������������������������������������������������

		For nx := 1 to Len(aRecSE2)
				dbSelectArea("SE2")
				dbGoto(aRecSE2[nx])

				//��������������������������������������������������������������Ŀ
				//� Verifica a exstencia de cheques para o titulo.               �
				//����������������������������������������������������������������
				dbSelectArea("SEF")
				SEF->( dbSetOrder( 3 ) )
				If SEF->(dbSeek(cFilial+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO))
					While !Eof() .and. EF_FILIAL==cFilial .and. ;
							 SE2->E2_PREFIXO+SE2->E2_NUM+;
							 SE2->E2_PARCELA+SE2->E2_TIPO==;
							 SEF->EF_PREFIXO+SEF->EF_TITULO+;
							 SEF->EF_PARCELA+SEF->EF_TIPO
						IF SEF->EF_FORNECE+SEF->EF_LOJA == SE2->E2_FORNECE+SE2->E2_LOJA .And. SEF->EF_IMPRESS != "C"
							Help(" ",1,"FA050DELPA")
							//��������������������������������������������������������������Ŀ
							//� Restaura a integridade da janela. Nao Processar a Exclusao.  �
							//����������������������������������������������������������������
							SEF->( dbSetOrder(1) )
							dbSelectArea(cAlias)
							dbGoto(nReg)
							Return .F.
						Endif
						SEF->( dbSkip() )
					Enddo
					dbSelectArea( "SEF" )
					SEF->( dbSkip( ) )
				EndIf
				SEF->( dbSetOrder(1) )
				dbSelectArea("SE2")

            If SE2->E2_SALDO # SE2->E2_VALOR
                  HELP(" ",1,"A100FINBX")
                  //��������������������������������������������������������������Ŀ
                  //� Restaura a integridade da janela. Nao Processar a Exclusao.  �
                  //����������������������������������������������������������������
                  dbSelectArea(cAlias)
                  dbGoto(nReg)
                  Return .F.
            ElseIf !Empty(SE2->E2_NUMBOR)
                  Help(" ",1,"A100JABOR",,SE2->E2_NUMBOR,02,25)
                  //��������������������������������������������������������������Ŀ
                  //� Restaura a integridade da janela. Nao Processar a Exclusao.  �
                  //����������������������������������������������������������������
                  dbSelectArea(cAlias)
                  dbGoto(nReg)
                  Return .F.
            Endif
		Next
		
      //���������������������������������������������������������Ŀ
      //� Verifica a existencia de  Titulo de Credito Cliente     �
      //�����������������������������������������������������������
      If cTipo == "D"                // Devolucao de Venda
            dbSelectArea("SE1")
            dbSetOrder(2)
            dbSeek(xFilial()+ca100For+cLoja+cPref+cNFiscal)
            While !Eof() .And. xFilial()+ca100For+cLoja+cPref+cNFiscal ==;
                        E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM

                  If !(SE1->E1_TIPO $ MV_CRNEG)
                        dbSelectArea("SE1")
                        dbSkip()
                  Else
                        If E1_SALDO != E1_VALOR
                              HELP(" ",1,"A100FINBX")
                              //��������������������������������������������������������������Ŀ
                              //� Restaura a integridade da janela. Nao Processar a Exclusao.  �
                              //����������������������������������������������������������������
                              dbSelectArea(cAlias)
                              dbGoto(nReg)
                              Return .F.
                        EndIf
                        Exit
                  EndIf
            End
      Endif

      //��������������������������������������������������Ŀ
      //� Verifica a existencia de Poder de Terceiro       �
      //����������������������������������������������������
      dbSelectArea("SD1")
      dbSeek(xFilial()+cNFiscal+cSerie+ca100For+cLoja)
      While !Eof() .And. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA ==;
                  xFilial()+cNFiscal+cSerie+ca100For+cLoja

            If D1_QTDEDEV # 0 .Or. D1_VALDEV # 0
                  Help(" ",1,"NAOEXCL")
                  //��������������������������������������������������������������Ŀ
                  //� Restaura a integridade da janela. Nao Processar a Exclusao.  �
                  //����������������������������������������������������������������
                  dbSelectArea(cAlias)
                  dbGoto(nReg)
                  Return .F.
            EndIf
            
            dbSelectArea("SF4")
            dbSeek(xFilial()+SD1->D1_TES)
				//-- Verifica se a NF Original ja Movimentou CQ
				If !lImpFrete .And. !(cTipo $'C� ') .And. SF4->F4_ESTOQUE == "S"
					If lIntegracao .And. SF1->F1_IMPORT == 'S' .And. !Empty(SD1->D1_CONHEC) .And. SF4->F4_ESTOQUE == "S"
						//��������������������������������������������������������������Ŀ
						//� Nas NF importadas verificar todos os registros do SD3.       �
						//����������������������������������������������������������������
						dbSelectArea('SWN')
						dbSetOrder(1)
						If dbSeek(cSeekSWN:=xFilial('SWN')+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_TEC, .F.)
							Do While !Eof() .And. cSeekSWN==WN_FILIAL+WN_DOC+WN_SERIE+WN_TEC+WN_EX_NCM+WN_EX_NBM
								//��������������������������������������������������������������Ŀ
								//� Verifica se Sld no B2 ficar� Neg. ou Menor que Sld em Reserva�
								//����������������������������������������������������������������
								dbSelectArea('SD3')
								dbSetOrder(4)
								If dbSeek(cSeekSD3:=xFilial('SD3')+SD1->D1_NUMSEQ+'E9'+SWN->WN_PRODUTO, .F.)
									Do While !Eof() .And. cSeekSD3==D3_FILIAL+D3_NUMSEQ+D3_CHAVE+D3_COD
										//��������������������������������������������������������������Ŀ
										//�Desconsidera registros estornados OU qtd/doc invalidos        �
										//����������������������������������������������������������������
										If !Empty(D3_ESTORNO) .Or. !(SWN->WN_QUANT==D3_QUANT) .Or. QtdComp(SWN->WN_QUANT)==QtdComp(0) .Or.!(D3_DOC==SD1->D1_DOC)
											dbSkip()
											Loop
										EndIf
										If SB2->(dbSeek(xFilial('SB2')+SWN->WN_PRODUTO+SD3->D3_LOCAL, .F.))
											nSaldoB2 := (SB2->B2_QATU-SWN->WN_QUANT)
											lAborta  := .F.
											If QtdComp(nSaldoB2)<QtdComp(0) .And. (!lEstNeg .Or. Rastro(SWN->WN_PRODUTO) .Or. Localiza(SWN->WN_PRODUTO))
												Aviso(STR0054,STR0055 + AllTrim(SWN->WN_PRODUTO) + '/'+SD3->D3_LOCAL + STR0056 + AllTrim(Str(nSaldoB2)) + ').',{STR0058}) //'Aten��o'###'O Saldo do Prod/Loc '###' ficaria negativo caso a Exclus�o fosse executada('###'Aborta'
												lAborta := .T.
											ElseIf QtdComp(nSaldoB2)<QtdComp(SB2->B2_RESERVA)
												lAborta := (Aviso(STR0054,STR0055 + AllTrim(SWN->WN_PRODUTO) + '/' + SD3->D3_LOCAL + STR0060 + AllTrim(Str(nSaldoB2)) + STR0057,{STR0058,STR0059}) == 1) //'Aten��o'###'O Saldo do Prod/Loc '###' ficar� Menor que o Saldo em Reserva ap�s a Exclus�o ('###'). Continua?''###'Aborta'###'Continua'
											EndIf
											If lAborta
												Return(.F.)
											EndIf
										EndIf	
										dbSkip()
									EndDo
								EndIf
								dbSelectArea('SD3')
								dbSetOrder(4)
								If dbSeek(cSeekSD3:=xFilial('SD3')+SD1->D1_NUMSEQ+'E9'+SWN->WN_PRODUTO)
									Do While !Eof() .And. cSeekSD3==D3_FILIAL+D3_NUMSEQ+D3_CHAVE+D3_COD
										//��������������������������������������������������������������Ŀ
										//�Desconsidera registros estornados OU qtd/doc invalidos        �
										//����������������������������������������������������������������
										If D3_ESTORNO=='S' .Or. !(SWN->WN_QUANT==D3_QUANT) .Or. QtdComp(SWN->WN_QUANT)==QtdComp(0) .Or.!(D3_DOC==SD1->D1_DOC)
											dbSkip()
											Loop
										EndIf
										If Localiza(SD3->D3_COD)
											dbSelectArea('SDA')
											dbSetOrder(1)
											If dbSeek(xFilial('SDA')+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ+SD3->D3_DOC)
												If !(DA_QTDORI==DA_SALDO)
													Help(' ', 1, 'SDAJADISTR')
													dbSelectArea(cAlias)
													dbGoto(nReg)
													Return .F.
												EndIf
											EndIf
											dbSelectArea('SD3')
										EndIf
										If D3_LOCAL==cLocCQ
											dbSelectArea('SD7')
											dbSetOrder(3)
											If dbSeek(xFilial('SD7')+SD3->D3_COD+SD3->D3_NUMSEQ, .F.) .And. D7_ORIGLAN=='IM'
												cSeekSD7 := xFilial('SD7')+D7_NUMERO+D7_PRODUTO
												dbSetOrder(1)
												If dbSeek(cSeekSD7, .F.)
													Do While !Eof() .And. cSeekSD7==D7_FILIAL+D7_NUMERO+D7_PRODUTO
														If (D7_TIPO==1.Or.D7_TIPO==2) .And. Empty(D7_ESTORNO)
															Help(' ', 1, 'A100CQ')
															dbSelectArea(cAlias)
															dbGoto(nReg)
															Return .F.
														EndIf	
														dbSkip()
													EndDo
												EndIf	
											EndIf
											dbSelectArea('SD3')
										EndIf
										dbSkip()
									EndDo
								Else	
									Help(' ', 1, 'NAOEXCL')
									dbSelectArea(cAlias)
									dbGoto(nReg)
									Return .F.
								EndIf	
								dbSelectArea('SWN')
								dbSkip()
							EndDo
						Else
							Help(' ', 1, 'NAOEXCL')
							dbSelectArea(cAlias)
							dbGoto(nReg)
							Return .F.
						EndIf
					Else
						dbSelectArea('SD7')
						dbSetOrder(1)
						If dbSeek(cSeekSD7:=(xFilial('SD7')+SD1->D1_NUMCQ+SD1->D1_COD+SD1->D1_LOCAL), .F.)
							Do While !Eof() .And. cSeekSD7==D7_FILIAL+D7_NUMERO+D7_PRODUTO+D7_LOCAL
								If (D7_TIPO==1.Or.D7_TIPO==2) .And. Empty(D7_ESTORNO)
									Help(' ', 1, 'A100CQ')
									dbSelectArea(cAlias)
									dbGoto(nReg)
									Return .F.
								EndIf
								dbSkip()
							EndDo
						EndIf
					EndIf
				EndIf

      		If !(SF4->(Eof())) .And. SF4->F4_PODER3 == 'R'
                  dbSelectArea("SB6")
                  dbSetOrder(3)
                  dbGotop()
                  If dbSeek(xFilial()+SD1->D1_IDENTB6+SD1->D1_COD+"R",.F.)
                        nQtPD3 := B6_QUANT
                        nSaldo := B6_SALDO
                        IF nSaldo # nQtPd3
                              Help(" ",1,"A520NPODER")
                              //��������������������������������������������������������������Ŀ
                              //� Restaura a integridade da janela. Nao Processar a Exclusao.  �
                              //����������������������������������������������������������������
                              dbSelectArea(cAlias)
                              dbGoto(nReg)
                              Return .F.
                        Endif
                        Exit
                  Endif
            Endif

				//��������������������������������������������������������������Ŀ
				//� Deleta a Integracao com o Ativo Fixo                         �
				//����������������������������������������������������������������
				If ( !Empty(SD1->D1_CBASEAF) )
               If Af010VldDel("SN3",.T.)
						dbSelectArea("SN1")
						dbSetOrder(1)
						If ( dbSeek(xFilial("SN1")+SD1->D1_CBASEAF))
							Af010DelAtu("SN3")
                  EndIf
					EndIf
				Endif
            dbSelectArea("SD1")
            dbSkip()
      End
      //��������������������������������������������������������������Ŀ
      //� Verifica a existencia de lanc. Padronizados p/ Compras       �
      //����������������������������������������������������������������
      lLancPad55:=VerPadrao("655")    // Debito de Estoque ou Debito de Despesas para exclusao
      lLancPad65:=VerPadrao("665")    // Credito de Forn. / Debito de IPI / Debito de ICMS para exclusao
      lLancPad95:=VerPadrao("955").And. SF1->F1_IMPORT=="S" // Lancamento de Importacao

      If Empty(SF1->F1_DTLANC) .Or. !lGeraLanc
            //�����������������������������������������������������Ŀ
            //� Nao Gerar os lancamento Contabeis On-Line           �
            //�������������������������������������������������������
            lLancPad55:=.F.
            lLancPad65:=.F.
            lLancPad95:=.F.
      Endif

      If (lLancPad55.or.lLancPad65.Or.lLancPad95)
            //��������������������������������������������������������������Ŀ
            //� Posiciona numero do Lote para Lancamentos do Compras         �
            //����������������������������������������������������������������
            dbSelectArea("SX5")
            dbSeek(xFilial()+"09COM")
            cLoteCom:=IIF(Found(),Trim(X5Descri()),"COM ")
            nHdlPrv:=HeadProva(cLoteCom,"MATA100",Subs(cUsuario,7,6),@cArquivo)
            If nHdlPrv <= 0
                  // Nao foi possivel criar o arquivo contra prova para esta nota,
                  // para tal devera' ser utilizada a rotina de Lancto Off-Line.
                  HELP(" ",1,"A100NOPRV")
            Endif
      Endif

		//��������������������������������������������������������������Ŀ
		//� Verifica�oes:                                                �
		//� 1.Se algum produto utiliza CQ Qualy (Celerina);              �
		//� 2.Se  a  Exclusao ir�  deixar  Saldo Negativo ou Menor que o �
		//�   Saldo em reserva para algum Produto.                       �
		//����������������������������������������������������������������
		aAreaSB2  := SB2->(GetArea())
		lQualiCQ  := .F.
		lAborta   := .F.
		nPosCod   := aScan(aHeader,{|x|AllTrim(x[2])=='D1_COD'})
		nPosItem  := aScan(aHeader,{|x|AllTrim(x[2])=='D1_ITEM'})
		nPosLocal := aScan(aHeader,{|x|AllTrim(x[2])=='D1_LOCAL'})
		nPosQtd   := aScan(aHeader,{|x|AllTrim(x[2])=='D1_QUANT'})
		nPosTES   := aScan(aHeader,{|x|AllTrim(x[2])=='D1_TES'})
		nSaldoB2  := 0
		For nX := 1 to Len(aCols)
			If AvalTes(aCols[nx,nPosTES],'S')
				//��������������������������������������������������������������Ŀ
				//� Verifica se algum produto utiliza CQ Quality (QIE)           �
				//����������������������������������������������������������������
				If !lQualiCQ
					lQualiCQ := A100CQQIE(If(nPosCod>0,aCols[nX,nPosCod],''),If(nPosItem>0,aCols[nX,nPosItem],''), cTipo, cNFiscal, cSerie, cA100For, cLoja, lImpFrete, lImpFrete, lIntegracao)
				EndIf
				//��������������������������������������������������������������Ŀ
				//� Verifica se Sld no B2 ficar� Neg. ou Menor que Sld em Reserva�
				//����������������������������������������������������������������
				If SB2->(dbSeek(xFilial('SB2')+aCols[nX,nPosCod]+aCols[nX,nPosLocal], .F.))
					nSaldoB2 := (SB2->B2_QATU-aCols[nX,nPosQtd])
					lAborta  := .F.
					If QtdComp(nSaldoB2)<QtdComp(0) .And. (!lEstNeg .Or. Rastro(aCols[nX, nPosCod]) .Or. Localiza(aCols[nX, nPosCod]))
						Aviso(STR0054,STR0055 + AllTrim(aCols[nX, nPosCod]) + '/' + aCols[nX, nPosLocal] + STR0056 + AllTrim(Str(nSaldoB2)) + ').',{STR0058}) //'Aten��o'###'O Saldo do Prod/Loc '###' ficaria negativo caso a Exclusao fosse processada ('###'Aborta'
						lAborta := .T.
					ElseIf QtdComp(nSaldoB2)<QtdComp(SB2->B2_RESERVA)
						lAborta := (Aviso(STR0054,STR0055 + AllTrim(aCols[nX, nPosCod]) + '/' + aCols[nX, nPosLocal] + STR0060 + AllTrim(Str(nSaldoB2)) + STR0057,{STR0058,STR0059}) == 1) //'Aten��o'###'O Saldo do Prod/Loc '###' ficar� Menor que o Saldo em Reserva ap�s a Exclus�o ('###'). Continua?''###'Aborta'###'Continua'
					EndIf
					If lAborta
						Return(.F.)
					EndIf
				EndIf	
			EndIf	
		Next nX      
		SB2->(dbSetOrder(aAreaSB2[2]))
		SB2->(dbGoto(aAreaSB2[3]))

      Begin Transaction
            //���������������������������������������������������������Ŀ
            //� Registro de cancelamento no Livro Fiscal                �
            //�����������������������������������������������������������
            dbSelectArea("SF3")
            dbSetOrder(4)
            cSeek1:=(SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE)
            dbSeek(xFilial()+cSeek1)
            // Deletar todos os registros no livro pois foi um lancamento errado.
            While !Eof() .And. xFilial()+cSeek1 == (F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)
					  If Substr(SF3->F3_CFO,1,1) < "5"
	                  RecLock("SF3",.F.,.T.)
   	               dbDelete()
					  EndIf
     	           dbSkip()
            End

            cPref:=&(GetMV("mv_2dupref"))
            cPref+=Space(Len(SE2->E2_PREFIXO) - Len(cPref))
            //��������������������������������������������������Ŀ
            //� Gera lancamento Contab. a nivel de total         �
            //����������������������������������������������������
            If lLancPad65
               nTotal+=DetProva(nHdlPrv,"665","MATA100",cLoteCom,@nLinha)
            Endif
            If lLancPad95
               nTotal+=DetProva(nHdlPrv,"955","MATA100",cLoteCom,@nLinha)
            Endif
				//���������������������������������������������������������Ŀ
            //� Cancela,no caso de Devolucao o Titulo de Credito Cliente�
            //�����������������������������������������������������������
            If cTipo == "D"                // Devolucao de Venda
					dbSelectArea("SE1")
               dbSetOrder(2)
               dbSeek(xFilial()+ca100For+cLoja+cPref+cNFiscal)
               While !Eof() .And. xFilial()+ca100For+cLoja+cPref+cNFiscal ==;
											E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM
						If !(E1_TIPO $ MV_CRNEG)
							dbSelectArea("SE1")
                     dbSkip()
						Else
                     dbSelectArea("SA1")
                     dbSetOrder(1)
                     dbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA)
							If Found()
					AtuSalDup("+",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,,SE1->E1_EMISSAO)
								dbSelectArea("SE1")
							Endif
							//������������������������������������������������������������������������Ŀ
							//� Estorna os valores comissionados pela NCC                              �
							//��������������������������������������������������������������������������
							Fa440DeleE("MATA100")
							RecLock("SE1",.F.,.T.)
							dbDelete()
							Exit
                  EndIf
               EndDo
            Endif
            #IFDEF SHELL
                  RecLock("SF1",.F.)
                  If F1_FORMUL == "S"
                        Replace F1_CANCEL With "S"
                  Else
                        dbDelete()
                  Endif
                  MSUNLOCK()
            #ELSE
                  RecLock("SF1",.F.,.t.)
					
				  //��������������������������������������������������������������������������������������������Ŀ
				  //� Integracao com o ACD - Faz ajuste do CB0 apos a exclusao da Nota - Somente Protheus		 �
				  //����������������������������������������������������������������������������������������������
				  If lIntACD
					CBSF1100E()
				  //�������������������������������������������������������������-Ŀ
				  //� Pontos de Entrada 										   �
				  //������������������������������������������������������������-���
                  ElseIf (ExistTemplate("SF1100E"))
                        ExecTemplate("SF1100E",.f.,.f.)
                  Endif

                  IF (ExistBlock("SF1100E"))
                        ExecBlock("SF1100E",.f.,.f.)
                  Endif

                  dbDelete()
            #ENDIF

            dbSelectArea(cAlias)   // itens das notas de entrada
            dbSeek(xFilial()+cSeek)
            nCnt := 0
            While !Eof() .And. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == xFilial()+cSeek
                  nCnt++
                  IF !Empty(D1_PEDIDO+D1_ITEMPC)
								If a100SeekPC(SD1->D1_PEDIDO,SD1->D1_ITEMPC,SD1->D1_COD,xFilial("SC7"),SD1->D1_FORNECE)
                              RecLock("SC7",.F.)
                              Replace C7_QUJE With (C7_QUJE - SD1->D1_QUANT)
                              Replace C7_ENCER with IIF(C7_QUANT-C7_QUJE>0," ","E")
                        Endif
                  Endif

                  //�������������������������������������������������������Ŀ
                  //� Estornar este lancamento no arquivo de Resumo da DIPI �
                  //���������������������������������������������������������
                  aCampos:={ SD1->D1_CF,SD1->D1_COD,SD1->D1_TOTAL,0,nTotMerc,;
                        SD1->D1_TES,(nValFrete+nValDesp),SD1->D1_QUANT,;
                        SD1->D1_PESO,SD1->D1_DTDIGIT,SD1->D1_IPI,SD1->D1_VALIPI}

                  dbSelectArea("SF4")
                  dbSeek( xFilial()+SD1->D1_TES )

                  If F4_ESTOQUE != "N"
				
								//-- Em caso de Devolu��o, atualiza o Local de onde saiu a Remessa.
								cLocOrigB6 := SD1->D1_LOCAL
								If SF4->F4_PODER3 == 'D'
									SB6->(dbSetOrder(3))
									If SB6->(dbSeek(xFilial('SB6')+SD1->D1_IDENTB6+SD1->D1_COD+'R', .F.))
										cLocOrigB6 := SB6->B6_LOCAL
									EndIf
								EndIf
						
                        dbSelectArea("SB2")
                        dbSeek(xFilial()+SD1->D1_COD+cLocOrigB6)
                        //��������������������������������������������������Ŀ
                        //� Elimina  lancto no SB6 (Poder de/em Terceiros)   �
                        //����������������������������������������������������
                        dbSelectArea("SB6")
                        dbSetOrder(3)
                        dbGotop()
                        If dbSeek(xFilial()+SD1->D1_IDENTB6+SD1->D1_COD+"R",.F.)
                              If SF4->F4_PODER3=='R'
                                    RecLock("SB6",.F.,.T.)
                                    dbDelete()
                                    dbSelectArea("SB2")
                                    RecLock("SB2",.F.)
                                    Replace B2_QTNP With B2_QTNP-SD1->D1_QUANT
                              ElseIf SF4->F4_PODER3=='D'
                                    RecLock("SB2",.F.)
                                    Replace B2_QNPT With B2_QNPT+SD1->D1_QUANT
                                    RecLock("SB6",.F.)
                                    Replace B6_UENT   With cTod('  /  /  ')
                                    Replace B6_SALDO  With B6_SALDO + SD1->D1_QUANT
                                    If B6_SALDO <= 0
                                          Replace B6_ATEND With "S"
                                    Else
                                          Replace B6_ATEND With "N"
                                    Endif
                                    //��������������������������������������������������Ŀ
                                    //� Reposiciona ponteiro no primeiro registro        �
                                    //����������������������������������������������������
                                    dbSeek(xFilial()+SD1->D1_IDENTB6+SD1->D1_COD,.F.)
                                    While !Eof() .And. B6_IDENT == SD1->D1_IDENTB6
                                          If SD1->D1_DOC+SD1->D1_SERIE == B6_DOC+B6_SERIE
                                                RecLock("SB6",.F.,.T.)
                                                dbDelete()
                                                Exit
                                          Endif
                                          dbSkip()
                                    End

                              Endif
                              MsUnlock()
                        Endif
                        //���������������������������������������������������������Ŀ
                        //� Inverter o TES para que a funcao B2AtuComD1 entenda que �
                        //� este movimento deve retirar do estoque e nao adicionar  �
                        //�����������������������������������������������������������
                        dbSelectArea(cAlias)
                        RecLock(cAlias,.F.)
                        Replace D1_TES With Str(IIF((Val(D1_TES)+500)>=1000,999,Val(D1_TES)+500),LEN(D1_TES))
                        //�������������������������������������������������������Ŀ
                        //� Atualiza o saldo atual (VATU) com os dados do SD1     �
                        //���������������������������������������������������������
                        B2AtuComD1(nMultiplic,SD1->D1_SKIPLOT)
                        nResiduo := 0
                        If !Empty(SD1->D1_PEDIDO)
                              //�������������������������������������������������������Ŀ
                              //� Estorna o Residuo eliminado na Opcao de El. de Res.   �
                              //���������������������������������������������������������
                              If !Empty(SC7->C7_RESIDUO)
                                    nResiduo := SC7->C7_QUANT - (SC7->C7_QUJE + SD1->D1_QUANT)
                                    RecLock("SC7",.F.)
                                    Replace C7_RESIDUO With " "
                              Endif
                              dbSelectArea("SB2")
							  dbSetOrder(1)
							  If dbSeek(xFilial()+SD1->D1_COD+SC7->C7_LOCAL)										
                                RecLock("SB2",.F.)                              
									If SD1->D1_QUANT > SC7->C7_QUANT
										Replace B2_SALPEDI With B2_SALPEDI + SC7->C7_QUANT + nResiduo
			                      	Else
										Replace B2_SALPEDI With B2_SALPEDI + SD1->D1_QUANT + nResiduo
			                       	EndIf                                                            
                              EndIf  
							  SB2->(dbSetOrder(aAreaSB2[2]))
							  SB2->(dbGoto(aAreaSB2[3]))		                       		                         	                                                              
                        EndIf
                  Endif

                  #IFDEF SHELL
                        //������������������������������������������������Ŀ
                        //� Estorno de saldos ref. (Shell-Distribuidores). �
                        //��������������������������������������������������
                        lAcerta := EstShell()
                  #ENDIF

                  //�������������������������������������������������������Ŀ
                  //� Estornar Poder Terceiro quando nao Afeta Estoque      �
                  //���������������������������������������������������������
                  If SF4->F4_ESTOQUE = "N"
                        dbSelectArea("SB6")
                        dbSetOrder(3)
                        dbGotop()
                        dbSeek(xFilial()+SD1->D1_IDENTB6+SD1->D1_COD+"R")
                        If SF4->F4_PODER3=='R'
                              dbSelectArea("SB2")
                              dbSeek(xFilial()+SD1->D1_COD+SD1->D1_LOCAL)
                              RecLock("SB2",.F.)
                              Replace B2_QTER With B2_QTER-SD1->D1_QUANT
                              RecLock("SB6",.F.,.T.)
                              dbDelete()
                        Elseif SF4->F4_PODER3=='D'
                              //���������������������������������������������������������Ŀ
                              //� Estorno de Devolucao de Beneficiamento                  �
                              //�����������������������������������������������������������
                              dbSelectArea("SB2")
                              dbSeek(xFilial()+SD1->D1_COD+SD1->D1_LOCAL)
                              RecLock("SB2",.F.)
                              Replace B2_QTER With B2_QTER+SD1->D1_QUANT

                              RecLock("SB6",.F.)
                              Replace B6_UENT   With cTod('  /  /  ')
                              Replace B6_SALDO  With B6_SALDO + SD1->D1_QUANT
                              If B6_SALDO <= 0
                                    Replace B6_ATEND With "S"
                              Else
                                    Replace B6_ATEND With "N"
                              Endif
                              //��������������������������������������������������Ŀ
                              //� Reposiciona ponteiro no primeiro registro        �
                              //����������������������������������������������������
                              dbSeek(xFilial()+SD1->D1_IDENTB6+SD1->D1_COD,.F.)
                              While !Eof() .And. B6_IDENT == SD1->D1_IDENTB6
                                    If SD1->D1_DOC+SD1->D1_SERIE == B6_DOC+B6_SERIE
                                          RecLock("SB6",.F.,.T.)
                                          dbDelete()
                                          Exit
                                    Endif
                                    dbSkip()
                              End
                        Endif
                  Endif

				  //-- Exclui Movimenta��es Referentes ao CQ
				  If !lImpFrete .And. !(lIntegracao.And.SF1->F1_IMPORT=='S')
					  nRecSD7  := 0	
					  aAreaSD7 := SD7->(GetArea())
					  dbSelectArea('SD7')
					  dbSetOrder(1)
					  If dbSeek(cSeekSD7:=(xFilial('SD7')+SD1->D1_NUMCQ+SD1->D1_COD+SD1->D1_LOCAL), .F.)
					      nRecSD7 := Recno()
						  //-- Exclui as Despesas Agregadas em aberto do CQ
						  fEstoCQ8(SD1->D1_NUMCQ, SD1->D1_COD, SD1->D1_LOCAL, Nil)
								
						  //-- Deleta as Movimenta��es no SD7
						  If !(cTipo $'C� ')
						      dbSelectArea('SD7')
							  dbSetOrder(1)
							  dbGoto(nRecSD7)
							  While !Eof() .And. cSeekSD7 == D7_FILIAL+D7_NUMERO+D7_PRODUTO+D7_LOCAL
									
								  //��������������������������������������������������������������Ŀ
								  //� Exclusao da Entrada gerada na Inspecao do Material		   �
								  //����������������������������������������������������������������
								  If D7_TIPO==0 .And. D7_ORIGLAN=='CP' .And. SB1->B1_TIPOCQ=='Q' .And. lQualiCQ 
																
									  nAtraso   := 0
								      aAreaSC7  := SC7->(GetArea())
									  aAreaSD7a := SD7->(GetArea())
									  
									  If a100SeekPC(SD1->D1_PEDIDO, SD1->D1_ITEMPC, SD1->D1_COD, xFilial('SC7'), SD1->D1_FORNECE)
										  nAtraso := SD1->D1_DTDIGIT-SC7->C7_DATPRF
									  Endif
									  
									  SC7->(dbSetOrder(aAreaSC7[2]))
									  SC7->(dbGoto(aAreaSC7[3]))

									  //��������������������������������������������������������������Ŀ
									  //�Posiciona o registro no SD5 para que o LOTECTL+NUMLOTE seja en�
									  //�viado para qAtuMatQie()									   �
									  //����������������������������������������������������������������
								      cLotCtlQie := ''
									  cNumLotQie := ''
								   	  If Rastro(SB1->B1_COD,"L") .Or. Rastro(SB1->B1_COD,"S")
										  aAreaSD5 := SD5->(GetArea())
									  	  SD5->(dbSetOrder(3))	                                          
										  If SD5->(dbSeek(xFilial('SD5')+SD1->D1_NUMSEQ+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_LOTECTL, .F.))
										      cLotCtlQie := SD5->D5_LOTECTL
											  cNumLotQie := SD5->D5_NUMLOTE
        	                              EndIf	
						 				  SD5->(dbSetOrder(aAreaSD5[2]))
										  SD5->(dbGoto(aAreaSD5[3]))
									  EndIf

									  aEnvCele := {SD1->D1_DOC,;  	 	  //Numero da Nota Fiscal 	 		
									  			    SD1->D1_SERIE,;   				  //Serie da Nota Fiscal           	
												    SD1->D1_TIPO,;    				  //Tipo da Nota Fiscal   		 	
													SD1->D1_EMISSAO,; 				  //Data de Emissao da Nota Fiscal   
													SD1->D1_DTDIGIT,; 				  //Data de Entrada da Nota Fiscal   
													"NF",; 	  						  //Tipo de Documento
													SD1->D1_ITEM,; 				  //Item da Nota Fiscal			
													SD1->D1_REMITO,; 				  //Numero do Remito (Localizacoes)  
													SD1->D1_PEDIDO,; 				  //Numero do Pedido de Compra       
													SD1->D1_ITEMPC,; 				  //Item do Pedido de Compra         
													SD1->D1_FORNECE,; 				  //Codigo Fornecedor/Cliente        
													SD1->D1_LOJA,; 				  //Loja Fornecedor/Cliente          
													SD1->D1_LOTEFOR,; 				  //Numero do Lote do Fornecedor     
													Space(6),; 					  //Codigo do Solicitante            
													SD1->D1_COD,; 					  //Codigo do Produto                
													SD1->D1_LOCAL,; 				  //Local Origem    				  
													cLotCtlQie,;		  //Numero do Lote             	
													cNumLotQie,; 		  //Sequencia do Sub-Lote         
													SD1->D1_NUMSEQ,; 				  //Numero Sequencial             
									  				SD7->D7_NUMERO,; 				  //Numero do CQ					
													SD1->D1_QUANT,; 				  //Quantidade             		
													SD1->D1_TOTAL,; 				  //Preco             			
													nAtraso,;					      //Dias de atraso		
													SD1->D1_TES,;					  //TES		
													AllTrim(FunName()),;		  	  //Origem						
													" ",;                            //Origem TXT
													0}							      //Quantidade do Lote Original
									                                                  
									  //��������������������������������������������������������������Ŀ
									  //� Realiza a exclusao do material enviado para Inspecao no QIE  �
									  //����������������������������������������������������������������
				    				  aRecCele := qAtuMatQie(aEnvCele,2)                                            
	    
									  RestArea(aAreaSD7a)
											
								  EndIf
									
								  RecLock('SD7', .F.)
								  dbDelete()
								  MsUnlock()
								  dbSkip()
								  
							  EndDo
						  EndIf	
						  
					  EndIf	
					  RestArea(aAreaSD7)
					  
				  EndIf

                  //����������������������������������������������������Ŀ
                  //� Estornar este lancamento nos arquivos de Importacao�
                  //������������������������������������������������������
                  A100DelConhe()

                  //���������������������������������������������������������Ŀ
                  //� Apagar Preco, Quant., Cond. Pgto e Data da Compra do    �
                  //� registro de ProdutoxFornecedores SA5.                   �
                  //�����������������������������������������������������������
                  A100DelSA5(SD1->D1_COD,dDEmissao)

                  //�������������������������������������������������������Ŀ
                  //� Estornar lancamento no arquivo SD3  (RE5)             �
                  //���������������������������������������������������������
                  If !Empty(SD1->D1_OP) .And. SF4->F4_ESTOQUE == "S"
                        A100EstRE5()
                  Endif

                  //��������������������������������������������������Ŀ
                  //� Gera lancamento Contab. a nivel de Itens         �
                  //����������������������������������������������������
                  IF lLancPad55
                        nTotal+=DetProva(nHdlPrv,"655","MATA100",cLoteCom,@nLinha)
                  Endif

                  If !Empty(SD1->D1_NFORI)
                        If cTipo == "D"
                              cSaveArea:= Alias()
                              nSaveOrd  := IndexOrd()
                              dbSelectArea("SD2")
                              dbSetOrder(3)
                              dbSeek(xFilial()+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD)

                              While !Eof() .And. (xFilial()+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD) == ;
                                          D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD

                                    If !Empty(SD1->D1_ITEMORI) .AND. SD1->D1_ITEMORI != D2_ITEM
                                       dbSkip()
                                       Loop
                                    Endif
                                    RecLock("SD2",.F.)
                                    Replace D2_QTDEDEV With IIf( D2_QTDEDEV - SD1->D1_QUANT > 0 , D2_QTDEDEV - SD1->D1_QUANT , 0 )
                                    Replace D2_VALDEV  With IIf( D2_VALDEV  - SD1->D1_TOTAL > 0 , D2_VALDEV  - SD1->D1_TOTAL , 0 )
                                    Exit
                              End
                              dbSelectArea(cSaveArea)
                              dbSetOrder(nSaveOrd)
                        Endif
                  Endif
                  //��������������������������������������������������������������Ŀ
                  //� Deleta o CIAP                                                �
                  //����������������������������������������������������������������
                  If ( !Empty(SD1->D1_CODCIAP) )
                        dbSelectArea("SF9")
                        dbSetOrder(1)
                        If ( dbSeek(xFilial("SF9")+SD1->D1_CODCIAP) )
                              dbSelectArea("SFA")
                              dbSetOrder(1)
                              If ( dbSeek(xFilial("SFA")+SF9->F9_CODIGO) )
                                    While ( !Eof() .And. xFilial("SFA")==SFA->FA_FILIAL .And.;
                                                      SFA->FA_CODIGO==SF9->F9_CODIGO )
                                          RecLock("SFA")
                                          dbdelete()
                                          dbSkip()
                                    EndDo
                              EndIf
                              RecLock("SF9")
                              dbDelete()
                        EndIf
                  EndIf
                  dbSelectArea(cAlias)
                  RecLock(cAlias,.F.,.t.)
                  #IFDEF SHELL
                        If SF1->F1_FORMUL == "S"
                              Replace SD1->D1_CANCEL With 'S'
                        Else
                              dbDelete()
                        Endif
                        MSUNLOCK()
                  #ELSE
			
					If GetNewPar("MV_NGMNTES","N") == "S"
						NGSD1100E()
					EndIf

					//�������������������������������������������������������������-Ŀ
					//� Pontos de Entrada 											 �
					//������������������������������������������������������������-���
					If lDclNew
						DCLSD1100E()
					ElseIf (lTSD1100E)
						ExecTemplate("SD1100E",.F.,.F.)
					Endif

					If (lSD1100E)
						ExecBlock("SD1100E",.F.,.F.)
					Endif
					//�����������������������������������������������������������������������������������Ŀ
					//�EXECUTAR CHAMADA DE FUNCAO p/ integracao com sistema de Distribuicao - NAO REMOVER �
					//�������������������������������������������������������������������������������������
					If cMV_FATDIST == "S" // Apenas quando utilizado pelo modulo de Distribuicao
						DS100SD1E()
					EndIf
            		dbDelete()
                  #ENDIF
                  dbSkip()

            End                         // While no SD1 (itens da N.F. Entrada)


            //������������������������������������������������������Ŀ
            //� Deleta as Duplicatas no arquivo SE2                  �
            //��������������������������������������������������������
            dbSelectArea("SE2")
            dbSetOrder(1)
            dbSeek( xFilial()+cPref+cNFiscal )
            nCnt := 0
            While !Eof() .And. xFilial()+cPref+cNFiscal == E2_FILIAL+E2_PREFIXO+E2_NUM.and.!cTipo$"DB"
                  If (cA100For+cLoja+cTpTit == E2_FORNECE+E2_LOJA+E2_TIPO).or.;
                              (nValFun>0.and.Alltrim(E2_FORNECE)=="UNIAO".and.E2_TIPO==MVTAXA)
                        //���������������������������������������������������������Ŀ
                        //� Atualizacao do campo A2_SALDUPM e A2_SALDUP             �
                        //�����������������������������������������������������������
                        dbSelectArea("SA2")
                        dbSetOrder(1)
                        dbSeek( xFilial() + cA100For + cLoja )
                        If Found()
                              RecLock("SA2", .F.)
                              SA2->A2_SALDUP -= xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,1,SE2->E2_EMISSAO)
                              SA2->A2_SALDUPM-= xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,Val(GetMv("MV_MCUSTO")),SE2->E2_EMISSAO)
                              SA2->A2_NROCOM-= If(nCnt==0,1,0)
                        EndIf
                        dbSelectArea("SE2")
                        nCnt++
                        RecLock("SE2",.F.,.t.)
                        dbDelete()
                  Endif
                  dbSkip()
            End
            For nAux01 := 1 To Len( aInfoIRRF )
                  If DbSeek( xFilial( "SE2" )+aInfoIRRF[ nAux01,1 ];
                              +aInfoIRRF[ nAux01,2 ];
                              +aInfoIRRF[ nAux01,3 ];
                              +aInfoIRRF[ nAux01,4 ];
                              +aInfoIRRF[ nAux01,5 ];
                              +aInfoIRRF[ nAux01,6 ],.F. ) .And. ;
                              Empty(SE2->E2_BAIXA) .And. SE2->E2_SALDO == SE2->E2_VALOR
                        RecLock( "SE2",.F.,.T. )
                        DbDelete()
                  EndIf
            Next
				For nAuxIss := 1 To Len( aInfoISS )
					If DbSeek( xFilial( "SE2" )+aInfoISS[ nAuxIss,1 ];
							+aInfoISS[ nAuxIss,2 ];
							+aInfoISS[ nAuxIss,3 ];
							+aInfoISS[ nAuxIss,4 ];
							+aInfoISS[ nAuxIss,5 ];
							+aInfoISS[ nAuxIss,6 ],.F. ) .And. ;
							Empty(SE2->E2_BAIXA) .And. SE2->E2_SALDO == SE2->E2_VALOR
						RecLock( "SE2",.F.,.T. )
						DbDelete()
					EndIf
				Next
            For nAuxInss := 1 To Len( aInfoInss )
					If DbSeek( xFilial( "SE2" )+aInfoInss[ nAuxInss,1 ];
               				               +aInfoInss[ nAuxInss,2 ];
                           				   +aInfoInss[ nAuxInss,3 ];
				                              +aInfoInss[ nAuxInss,4 ];
            				                  +aInfoInss[ nAuxInss,5 ];
                        				      +aInfoInss[ nAuxInss,6 ],.F. ) .And. ;
			           Empty(SE2->E2_BAIXA) .And. SE2->E2_SALDO == SE2->E2_VALOR
						RecLock( "SE2",.F.,.T. )
                  DbDelete()
              	EndIf
            Next
      End Transaction


      If lIntegracao
            If SF1->F1_IMPORT == "S"
                  CloseOpen({"SWN","SW6","SWD"},{"SC5","SC6"})
            Endif
      Endif

      #IFDEF SHELL
            //��������������������������������������������������������������Ŀ
            //� Exibir Help solicitando rodar a rotina de acerto de Pedidos. �
            //����������������������������������������������������������������
            Help(" ",1,"ACERTO")
      #ENDIF

Else
      LibLock(aRegLock)
      aRegLock:={}

      dbSelectArea(cAlias)
      dbSeek(xFilial()+cSeek)
Endif

IF nHdlPrv > 0 .and. (lLancPad55.or.lLancPad65.Or.lLancPad95)
      //�����������������������������������������������������Ŀ
      //� Envia para Lancamento Contabil, se gerado arquivo   �
      //�������������������������������������������������������
      RodaProva(nHdlPrv,nTotal)
      //�����������������������������������������������������Ŀ
      //� Envia para Lancamento Contabil, se gerado arquivo   �
      //�������������������������������������������������������
      If UsaSeqCor() 
        aCtbDia := {{"SF1",SF1->(RECNO()),SF1->F1_DIACTB,"F1_NODIA","F1_DIACTB"}}
      Else
        aCtbDia := {}
      EndIF    

      cA100Incl(cArquivo,nHdlPrv,3,cLoteCom,lDigita,lAglutina,,,,,,aCtbDIa)

Endif

dbSelectArea(cAlias)

Set Key VK_F12 To FAtiva()

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A100F4   � Autor � Claudinei M. Benzi    � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a consulta aos pedidos de compra em aberto.            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A100F4(a,b,c)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� a,b,c = parametros padroes quando utiliza-se o Set Key     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A100F4(a,b,c,nKey,nFlags,oGet)
Local aArrayF4[0],aArrSldo[0]
Local nQuant := nPercIPI := nPercICM := nValTotal := nValUnit := 0
Local nOpt1 := 1,nX,cQual := ReadVar()
Local cVar, cSeek,cProd,cLocal,cTes,cAreaAnt, cVar1
Local oDlg, nOpca:= 0, cCadastro, oQual, bLine, cCond,nSavQual
Local lContinue := .F.,cAlias:=""
Local nFreeQT := 0,;
	nPosPRD := 0,;
	nPosPDD := 0,;
	nPosITM := 0,;
	nPosQTD := 0,;
	nAuxCNT := 0

Local bKeyF4  		:= SetKey( VK_F4 )
Local lFatDist 		:= Iif(GetNewPar("MV_FATDIST", "N") == "S", .T., .F.)
Local aCab, aNew, cDet, nAuxNew
Local cMV_RESTNFE	:= GetMV("MV_RESTNFE")
Static lMt100C7D 	:= Nil, lMt100C7C := Nil

If lMt100C7D == Nil .Or. lMt100C7C == Nil
	lMt100C7D := ExistBlock("MT100C7D")
	lMt100C7C := ExistBlock("MT100C7C")
Endif	

//�����������������������������������������������������������������������Ŀ
//� Verifica se foi pressionado F4 sobre o Fornecedor                     �
//�������������������������������������������������������������������������
A100ForF4()

//�����������������������������������������������������������������������Ŀ
//� Pesquisar Itens de Importacao para esta NBM                           �
//�������������������������������������������������������������������������
If lIntegracao
	if SF1->F1_IMPORT == "S" .and. nKey!=Nil
		If nKey == VK_F4
			A100NBMItens(oGet)
		Endif
		SetKey(VK_F4,bKeyF4)
		Return
	endif
Endif


If !(Alltrim(cQual)$"M->D1_NFORI/M->D1_NUMLOTE/M->D1_LOTECTL/M->D1_COD/M->D1_QUANT")
	SetKey(VK_F4,bKeyF4)
	Return
Endif


cCpoQtd := Alltrim(ReadVar())
cPedido := &(ReadVar())
cVar  := &(ReadVar())
cCpoPrc := "M->D1_VUNIT"

For nx:=1 to Len(aHeader)
	Do Case
		Case Trim(aHeader[nX][2]) == "D1_COD"
			cProd:=aCols[n][nx]
			nPosPRD := nX
		Case Trim(aHeader[nX][2]) == "D1_LOCAL"
			cLocal:=aCols[n][nx]
		Case Trim(aHeader[nX][2]) == "D1_TES"
			cTES  :=aCols[n][nx]
		Case Trim(aHeader[nX][2]) == "D1_PEDIDO"
			nPosPDD := nX
		Case Trim(aHeader[nX][2]) == "D1_ITEMPC"
			nPosITM := nX
		Case Trim(aHeader[nX][2]) == "D1_QUANT"
			nPosQTD := nX
	EndCase
Next

cAlias:=Alias()
dbSelectArea("SF4")
dbSeek(xFilial("SF4")+cTes)

If (SF4->F4_PODER3=="D")
	lContinue := .T.
EndIf

If (cTipo=="D")
	lContinue := .T.
EndIf

If lRecebto .And. !lContinue
	Return
Endif
dbSelectArea(cAlias)
//�����������������������������������������������������������������������Ŀ
//� Pesquisar Notas Fiscais de Saida quando Devolucao de Venda            �
//�������������������������������������������������������������������������
IF cCpoQtd == "M->D1_NFORI"
	If cTipo == "D"
		SetKey( VK_F4,Nil )
		F4NFORI(,,,Substr(ca100For,1,Len(SA2->A2_COD)),cLoja,cProd,"A100")
		SetKey( VK_F4,bKeyF4 )
		Return
	Endif
	//�����������������������������������������������������������������������Ŀ
	//� Pesquisar Notas Fiscais de Entrada quando Complemento IPI   .         �
	//�������������������������������������������������������������������������
	If cTipo $ "CPI"
		SetKey( VK_F4,Nil )
		F4Compl(,,,Substr(ca100For,1,Len(SA2->A2_COD)),cLoja,cProd,"A100")
		SetKey( VK_F4,bKeyF4 )
		Return
	Endif

	If (cTipo $ "NB") .And. lRecebto
		dbSelectArea("SF4")
		If DbSeek( xFilial()+cTes ) .And. (SF4->F4_PODER3 == "D")
			SetKey( VK_F4,Nil )
			M->D1_NFORI := A440F4( "SB6",cProd,cLocal,"B6_PRODUTO","E",SubStr( ca100For,1,Len(SA2->A2_COD)),cLoja,Altera,lRecebto)
			SetKey( VK_F4,bKeyF4 )
		EndIf
	EndIf
Endif
//�����������������������������������������������������������������������Ŀ
//� Pesquisar pelo Lote somente se Devolucao de Venda e Usa Rastreamento  �
//�������������������������������������������������������������������������
IF cCpoQtd=="M->D1_NUMLOTE" .Or. cCpoQtd=="M->D1_LOTECTL"
	If cTipo == "D"
		SetKey( VK_F4,Nil )
		F4Lote(,,,"A100",cProd,cLocal)
		SetKey( VK_F4,bKeyF4 )
		Return
	Endif
Endif

If cCpoQtd == "M->D1_QUANT" .And. !lRecebto
	cAreaAnt:=Alias()
	dbSelectArea("SF4")

	If dbSeek(xFilial()+cTes) .and. SF4->F4_PODER3=="D" .And. cTipo $ ("NB")
		SetKey( VK_F4,Nil )
		M->D1_QUANT := A440F4( "SB6",cProd,cLocal,"B6_PRODUTO","E",SubStr( ca100For,1,Len(SA2->A2_COD)),cLoja,Altera,lRecebto)
	Endif
	SetKey(VK_F4,bKeyF4)
	Return
Endif

IF Empty(cVar)
	SetKey(VK_F4,bKeyF4)
	Return
Endif

SetKey( VK_F4,Nil )

//��������������������������������������������������������������Ŀ
//� Verifica o arquivo a ser pesquisado                          �
//����������������������������������������������������������������
dbSelectArea("SC7")
dbSetOrder(6)     // Filial de Entrega
If lConsLoja
	cSeek := cVar+SA2->A2_COD+SA2->A2_LOJA
	dbSeek(xFilEnt(cFilial)+cSeek)
Else
	cSeek := cVar+SA2->A2_COD
	dbSeek(xFilEnt(cFilial)+cSeek)
EndIf

If Eof()
	HELP(" ",1,"A100F4")
	dbSetOrder(1)
	SetKey( VK_F4,bKeyF4 )
	Return
Endif

If lConsLoja
	cCond := "C7_FILENT+C7_PRODUTO+C7_FORNECE+C7_LOJA"
Else
	cCond := "C7_FILENT+C7_PRODUTO+C7_FORNECE"
EndIf

While !Eof() .And. xFilEnt(cFilial)+cSeek == &(cCond)
	//����������������������������������������������������������Ŀ
	//� Filtra os Pedidos Bloqueados e Previstos.                �
	//������������������������������������������������������������
	If (cMV_RESTNFE == "S" .And. C7_CONAPRO == "B") .Or. C7_TPOP == "P"
		dbSkip()
		Loop
	EndIf
	If Empty(C7_RESIDUO)
		nFreeQT := 0
		For nAuxCNT := 1 To Len( aCols )
			If (nAuxCNT # n) .And. ;
					(aCols[ nAuxCNT,nPosPRD ] == C7_PRODUTO) .And. ;
					(aCols[ nAuxCNT,nPosPDD ] == C7_NUM) .And. ;
					(aCols[ nAuxCNT,nPosITM ] == C7_ITEM) .And. ;
					!ATail( aCols[ nAuxCNT ] )

				nFreeQT += aCols[ nAuxCNT,nPosQTD ]
			EndIf
		Next
		If ((nFreeQT := (C7_QUANT-C7_QUJE-C7_QTDACLA-nFreeQT)) > 0)
			AAdd( aArrayF4,{C7_LOJA,C7_NUM,C7_ITEM,PADR(nFreeQT,11),Dtoc(C7_DATPRF),Substr(C7_DESCRI,1,20),IIF(C7_TIPO==2,"AE","PC"),C7_LOCAL,C7_OBS})
			AAdd( aArrSldo,{nFreeQT,RecNo()} )
			If lMT100C7D
				aNew := ExecBlock("MT100C7D", .f., .f., aArrayF4[Len(aArrayF4)])
				If ValType(aNew) = "A"
					aArrayF4[Len(aArrayF4)] := aNew
				Endif
			Endif		
		EndIf
	Endif
	dbSkip()
End

If !Empty(aArrayF4)
	cCadastro:= OemToAnsi(STR0032)      //"Pedidos de Compras"
	nOpca := 0
	DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 15,50 OF oMainWnd

	aCab := {OemToAnsi(STR0033),OemToAnsi(STR0034),OemToAnsi(STR0035),OemToAnsi(STR0036),OemToAnsi(STR0037),OemToAnsi(STR0038),OemToAnsi(STR0039),OemToAnsi(STR0061),OemToAnsi(STR0062)} //"Loja"###"Pedido"###"Item"###"Saldo"###"Entrega"###"Descri��o"###"Tipo"###"Local"###"Observa��o"

	If lMT100C7C
		aNew := ExecBlock("MT100C7C", .f., .f., aCab)
		If ValType(aNew) == "A"
			aCab := aNew
		Endif
	Endif		

    oQual := TWBrowse():New( 0, .7, 150, 42,,aCab,,,,,,,{|nRow,nCol,nFlags|(nOpca := 1,nSavQual:=oQual:nAT,oDlg:End())},,,,,,, .F.,, .F.,, .F.,,, )         

	cDet := "{|| {"
	For nAuxNew := 1 to Len(aArrayF4[1])
		cDet+="aArrayF4[oQual:nAt, " + AllTrim(Str(nAuxNew)) + "]"+If(nAuxNew<Len(aArrayF4[1]),",","}}")
	Next	

	oQual:SetArray(aArrayF4)
	oQual:bLine := &cDet
	
	DEFINE SBUTTON FROM 5   ,166  TYPE 1 ACTION (nOpca := 1,nSavQual:=oQual:nAT,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 17.5,166  TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg

	If nOpca == 1
		dbSelectArea("SC7")
		dbGoto(aArrSldo[nSavQual][2])
		SoftLock("SC7")
		Aadd(aRegLock,{"SC7",Recno()})
		For nX := 1 To Len(aHeader)
			Do Case
				Case Trim(aHeader[nX][2]) == "D1_PEDIDO"
					aCols[n][nX] := SC7->C7_NUM
				Case Trim(aHeader[nX][2]) == "D1_ITEMPC"
					aCols[n][nX] := SC7->C7_ITEM
				Case Trim(aHeader[nX][2]) == "D1_LOCAL"
					aCols[n][nX] := SC7->C7_LOCAL
				Case Trim(aHeader[nX][2]) == "D1_IPI"
					nPercIPI := aCols[n][nX] := SC7->C7_IPI
				Case Trim(aHeader[nX][2]) == "D1_QUANT"
					nQuant   := aCols[n][nX] := aArrSldo[nSavQual][1]
				Case lFatDist .And. Trim(aHeader[nX][2]) == "D1_QTEMB"					
					aCols[n][nX] := FUniToEmb( aArrSldo[nSavQual][1], SC7->C7_PRODUTO )
				Case lFatDist .And. Trim(aHeader[nX][2]) == "D1_TERUM"					
					aCols[n][nX] := SB1->B1_TERUM
				Case Trim(aHeader[nX][2]) == "D1_VUNIT"
					nValUnit := aCols[n][nX] := A100CReaj(SC7->C7_REAJUST,lReajuste)
				Case Trim(aHeader[nX][2]) == "D1_PICM"
					If cPaisLoc == "BRA"
						nPercICM := aCols[n][nX] := aliqicms(cTipo,cTipoNF)
					EndIf
				Case Trim(aHeader[nX][2]) == "D1_CC"
					aCols[n][nX] := SC7->C7_CC
				Case Trim(aHeader[nX][2]) == "D1_CONTA"		
					aCols[n][nX] := Iif( Empty(SC7->C7_CONTA), SB1->B1_CONTA, SC7->C7_CONTA )
				Case Trim(aHeader[nX][2]) == "D1_ITEMCTA"  		// Item Contabil - SIGACTB
					aCols[n][nX] := Iif(Empty(SC7->C7_ITEMCTA),SB1->B1_ITEMCC,SC7->C7_ITEMCTA)
				Case Trim(aHeader[nX][2]) == "D1_CLVL"     		// Classe Valor - SIGACTB
					aCols[n][nX] := Iif(Empty(SC7->C7_CLVL),SB1->B1_CLVL,SC7->C7_CLVL)
				Case Trim(aHeader[nX][2]) == "D1_VALDESC"
					aCols[n][nX] := IIF(SC7->C7_VLDESC==0,CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3),SC7->C7_VLDESC)
				Case Trim(aHeader[nX][2]) == "D1_DESC"
					aCols[n][nX] := IIF(SC7->C7_VLDESC==0,(CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)/SC7->C7_TOTAL)*100,0)
			EndCase
		Next nX
		For nX := 1 To Len(aHeader)
			If Trim(aHeader[nX][2]) == "D1_TOTAL"
				nValTotal := aCols[n][nX] := NoRound(nQuant * nValUnit,2)
			Endif
		Next nX
		For nX := 1 To Len(aHeader)
			Do Case
				Case Trim(aHeader[nX][2]) == "D1_VALIPI"
					aCols[n][nX] := (nPercIPI * nValTotal)/100
				Case Trim(aHeader[nX][2]) == "D1_VALICM"
					aCols[n][nX] := (nPercICM * nValTotal)/100
			EndCase
		Next nX
	Endif
Else
	HELP(" ",1,"A100F4")
Endif

SetKey( VK_F4,bKeyF4 )

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A100FormulProprio()   �Autor�Juan J.Pereira�Data � 24.08.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Busca numero da nota fiscal no SX5 quando formul. proprio  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATA100, MATA910, MATA140                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A100FormulProprio(cNFiscal,cNfSerie)
Local lFormul
Local nItensNf := 0
Local cSaveAlias  := Alias(), cSaveOrd:= IndexOrd()

vNumero:= ""
cNumero:= ""
cSerie := ""
lFormul:= Sx5NumNota()

//��������������������������������������������������������������Ŀ
//� Validacao da NF informada pelo usuario                       �
//����������������������������������������������������������������
If lFormul
	SF1->(dbSetOrder(1))
	If SF1->(dbSeek(xFilial("SF1")+cNumero+cSerie+cA100For+cLoja,.F.))
		HELP(" ",1,"EXISTNF")
		lFormul := .F.
	Endif
EndIf

If lFormul
	//��������������������������������������������������������������Ŀ
	//� Verifica o numero de maximo de itens da serie.               �
	//����������������������������������������������������������������
	aEval(aCols,{|x| nItensNf+=If(x[Len(x)],0,1)})
	If nItensNf > 0 .And. If(cModulo=="FIS",.F.,cFormul=="S") ;
		.And. nItensNf > a460NumIt(cSerie) .And. (nModulo <> 12 .OR. nModulo <> 72)
		HELP(" ",1,"A100NITENS")
		lFormul := .F.
	Else
		cNumero := NxtSX5Nota(cSerie)
	EndIf
EndIf

cNFiscal:=cNumero
cNFSerie:=cSerie

dbSelectArea(cSaveAlias)
dbSetOrder(cSaveOrd)

Return lFormul

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FAtiva   � Autor � Cristina Ogura        � Data � 18.10.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chama a&pergunte                                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FAtiva()
pergunte("MTA100",.T.)
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   � A100VerForm� Autor � Juan Jose Pereira   � Data � 12.01.96 ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Controla Get da variavel cFormul na inclusao do MATA100    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mata100,Mata910                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION A100VerForm(cFormul,oNFiscal,oSerie)
Local lRet:=.F.

If Pertence(' SN',cFormul)
      If cFormul == "S"
            cNFiscal:= "      "
            cSerie  := SerieNfId("SF1",5,"F1_SERIE")
            If oNFiscal != NIL   //Fernando Dourado 10/06/99
   	         oNFiscal:Refresh()
            Endif
	         If oSerie != NIL    //Fernando Dourado  10/06/99
	            oSerie:Refresh()
            Endif
      Endif
      lRet:=.T.
EndIf

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   � A100BOk    � Autor �   Marcos Simidu     � Data � 07.04.97 ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Controla Telas de Notas e Duplicacatas do MATA100.         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mata100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION A100BOk(nOpca,oGet,lConFrete,lConImp,lDesc,aLivro,aCusto,cCondicao,lDupl,bVoltaIcm,oDlg)
aSavaCols := aClone(aCols)
l115auto := If (Type("l115Auto") == "U",.f.,l115Auto)
If l115auto .or. oGet:TudoOk()
	nOpca := 1
	If A100Rodape(.t.,lConfrete,lConImp,lDesc,@aLivro,@aCusto)
				If lIntegracao .and. lF1Import  .and. lEicFin
					oDlg:End()
				ElseIf cFormul=="S".And.!lRecebto
					If A100FormulProprio(@cNFiscal,@cSerie)
							If DoContabil(@cCondicao,lDupl,cTipo,oGet)
									oDlg:End()
							Endif
					Endif
			Else
					If DoContabil(@cCondicao,lDupl,cTipo,oGet)
							oDlg:End()
					Else
							Eval(bVoltaIcm)
					Endif
			Endif
	Else
			Eval(bVoltaIcm)
	EndIf
Else
      nOpca:=0
Endif

Return(.T.)
