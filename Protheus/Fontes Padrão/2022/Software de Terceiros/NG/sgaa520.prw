#INCLUDE "SGAA520.ch"
#Include "protheus.ch"
#DEFINE _nVERSAO 1 //Versao do fonte
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGAA520   �Autor  �Roger Rodrigues     � Data �  18/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para hist�rico de cadastro de FMR - Fichas de		  ���
���          �Movimenta��o de Residuos									  ���
�������������������������������������������������������������������������͹��
���Uso       �SIGASGA/SGAA510                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGAA520()
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
Private aRotina   := MenuDef()
Private cCadastro := OemToAnsi(STR0001) //"Hist�rico de FMRs"

//Verifica se o Update de FMR esta aplicado
If !SGAUPDFMR()
	Return .F.
Endif

dbSelectArea("TDF")
If IsInCallStack("SGAA510")
	Set Filter to TDF->TDF_CODFMR == TDC->TDC_CODFMR
Endif

mBrowse( 6, 1,22,75,"TDF",,,,,,SG520SEMAF())

dbSelectArea("TDF")
Set Filter to
NGRETURNPRM(aNGBEGINPRM)

Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Roger Rodrigues       � Data �18/03/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Utilizacao de Menu Funcional.                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaSGA                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina :=	{ { STR0002	, "AxPesqui"	, 0 , 1},; //"Pesquisar"
                      { STR0003	, "SG520VIS"	, 0 , 2},; //"Visualizar"
                      { STR0004	, "SG510LEG"	, 0 , 3}} //"Legenda"

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SG520SEMAF�Autor  �Roger Rodrigues     � Data �  18/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Define as cores de semaforo para as FMRS                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA520                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SG520SEMAF()
Local aCores :={{"NGSEMAFARO('TDF->TDF_STATUS == "+'"1"'+"')" , "BR_VERMELHO" },;
				 {"NGSEMAFARO('TDF->TDF_STATUS == "+'"3"'+" .AND. !EMPTY(TDF->TDF_LIBRES)')" , "BR_AZUL"},;
				 {"NGSEMAFARO('TDF->TDF_STATUS == "+'"2"'+"')" , "BR_AMARELO"},;
				 {"NGSEMAFARO('TDF->TDF_STATUS == "+'"3"'+"')" , "BR_VERDE"},;
				 {"NGSEMAFARO('TDF->TDF_STATUS == "+'"4"'+"')" , "BR_PRETO"},;
				 {"NGSEMAFARO('TDF->TDF_STATUS == "+'"5"'+"')" , "BR_LARANJA"},;
				 {"NGSEMAFARO('TDF->TDF_STATUS == "+'"6"'+"')" , "BR_PINK"},;
 				 {"NGSEMAFARO('TDF->TDF_STATUS == "+'"7"'+"')" , "BR_CINZA"}}

Return aCores

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SG520VIS  �Autor  �Roger Rodrigues     � Data �  18/03/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta Tela para visualiza��o do Hist�rico                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SG520VIS(cAlias,nRecno,nOpcx)
Local cTitulo := cCadastro// Titulo da janela     
Local lOk := .F.
Local i, k
Local aPages:= {},aTitles:= {}

//Variaveis de tamanho de tela e objetos
Local aSize := {}, aObjects := {}, aInfo := {}, aPosObj := {}

//Variaveis da GetDados
Local aColsAcon := {}, aColsResp := {}
Local aHeadAcon := {}, aHeadResp := {}
Local cGetWhlAc := "", cGetWhlRe := ""
Private oGetAc520, oGetRe520

//Variaveis de Tela
Private oDlg520, oFolder520, oEnc520
Private aTela := {}, aGets := {}

//Definicao de tamanho de tela e objetos
aSize := MsAdvSize(,.f.,430)
Aadd(aObjects,{045,045,.t.,.t.})
Aadd(aObjects,{055,055,.t.,.t.})
aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
aPosObj := MsObjSize(aInfo, aObjects,.t.)

//Cria os Folders de acordo com a Rotina que chama
Aadd(aTitles,OemToAnsi(STR0005)) //"Acondicionamento"
Aadd(aPages,"Header 1")
Aadd(aTitles,OemToAnsi(STR0006)) //"Respons�veis"
Aadd(aPages,"Header 2")

//Carrega variaveis de Modo de exibicao
Inclui := (nOpcx == 3)
Altera := (nOpcx == 4)

Define MsDialog oDlg520 Title OemToAnsi(cTitulo) From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel

//������������������������������������������������������Ŀ
//� Parte Superior da tela                               �
//��������������������������������������������������������
Dbselectarea("TDF")
RegToMemory("TDF",(nOpcx == 3))
oEnc520:= MsMGet():New("TDF",nRecno,nOpcx,,,,,aPosObj[1],,,,,,oDlg520,,,.F.)
oEnc520:oBox:Align := CONTROL_ALIGN_TOP

//������������������������������������������������������Ŀ
//� Parte Inferior da tela                               �
//��������������������������������������������������������
oFolder520 := TFolder():New(300,0,aTitles,aPages,oDlg520,,,,.T.,.f.)
oFolder520:aDialogs[1]:oFont := oDlg520:oFont
oFolder520:aDialogs[2]:oFont := oDlg520:oFont   
oFolder520:Align := CONTROL_ALIGN_ALLCLIENT

//������������������������������������������������������Ŀ
//� Folder 01 - Acondicionamentos                        �
//��������������������������������������������������������
aCols := {}
aHeader := {}

cGetWhlAc := "TDG->TDG_FILIAL == '"+xFilial("TDG")+"' .AND. TDG->TDG_CODFMR == '"+TDF->TDF_CODFMR+"' .AND. "+;
								"DTOS(TDG->TDG_DTALT) == '"+DTOS(TDF->TDF_DTALT)+"' .AND. TDG->TDG_HRALT == '"+TDF->TDF_HRALT+"'"
FillGetDados( nOpcx, "TDG", 1, "TDF->TDF_CODFMR", {|| }, {|| .T.},{"TDG_CODFMR","TDG_DTALT","TDG_HRALT"},,,,{|| NGMontaAcols("TDG", TDF->(TDF_CODFMR+DTOS(TDF_DTALT)+TDF_HRALT),cGetWhlAc)})

aColsAcon := aClone(aCols)
aHeadAcon := aClone(aHeader)

If Empty(aColsAcon) .Or. nOpcx == 3
   aColsAcon := BlankGetd(aHeadAcon)
Endif

oGetAc520 := MsNewGetDados():New(005, 005, 100, 200,IIF(!Inclui.And.!Altera,0,GD_INSERT+GD_UPDATE+GD_DELETE),"AllWaysTrue()","AllWaysTrue()",,,,9999,,,,oFolder520:aDialogs[1],aHeadAcon, aColsAcon)
oGetAc520:oBrowse:Default()
oGetAc520:oBrowse:Refresh()
oGetAc520:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
 
//������������������������������������������������������Ŀ
//� Folder 02 - Respons�veis                             �
//��������������������������������������������������������
aCols := {}
aHeader := {}

cGetWhlAc := "TDH->TDH_FILIAL == '"+xFilial("TDH")+"' .AND. TDH->TDH_CODFMR == '"+TDF->TDF_CODFMR+"' .AND. "+;
								"DTOS(TDH->TDH_DTALT) == '"+DTOS(TDF->TDF_DTALT)+"' .AND. TDH->TDH_HRALT == '"+TDF->TDF_HRALT+"'"
FillGetDados( nOpcx, "TDH", 1, "TDF->TDF_CODFMR", {|| }, {|| .T.},{"TDH_CODFMR","TDH_DTALT","TDH_HRALT"},,,,{|| NGMontaAcols("TDH", TDF->(TDF_CODFMR+DTOS(TDF_DTALT)+TDF_HRALT),cGetWhlAc)})

aColsResp := aClone(aCols)
aHeadResp := aClone(aHeader)

If Empty(aColsResp) .Or. nOpcx == 3
   aColsResp := BlankGetd(aHeadResp)
Endif

oGetRe520 := MsNewGetDados():New(005, 005, 100, 200,IIF(!Inclui.And.!Altera,0,GD_INSERT+GD_UPDATE+GD_DELETE),"AllWaysTrue()","AllWaysTrue()",,,,9999,,,,oFolder520:aDialogs[2],aHeadResp, aColsResp)
oGetRe520:oBrowse:Default()
oGetRe520:oBrowse:Refresh()
oGetRe520:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Activate Dialog oDlg520 On Init (EnchoiceBar(oDlg520,{|| lOk:=.T.,lOk := .T., oDlg520:End()},{|| lOk:= .F.,oDlg520:End()})) Centered

Return .T.