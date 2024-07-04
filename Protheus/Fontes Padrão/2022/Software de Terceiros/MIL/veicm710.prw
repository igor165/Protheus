// �����������������ͻ
// � Versao � 03     �
// �����������������ͼ

#include "PROTHEUS.CH"
#include "VEICM710.CH"

/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    � VEICM710 � Autor � Thiago						    � Data � 30/10/14 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Libera��o de Cr�dito. 								                  ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Function VEICM710()
Local aCores := {{ 'VQB->VQB_STATUS == "0"', 'BR_VERDE'     } ,;  // Aguardando libera��o
				 { 'VQB->VQB_STATUS == "1"', 'BR_VERMELHO' } }   // Liberado para Faturar

Private cFilterTP := ""

Private cCadastro := STR0001 // Libera��o de Cr�dito
Private aRotina   := MenuDef()

cFilterTP := "VQB_STATUS = '0' OR VQB_STATUS = '1'"

mBrowse( 6, 1,22,75,"VQB",,,,,,aCores,,,,,,,,cFilterTP)

return .t.
/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    � VM710L   � Autor � Thiago						    � Data � 30/10/14 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Montagem da Janela de liberacao.						                  ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Function VM710L(cAlias,nReg,nOpc)
Local lRet := .f.
lRet = FS_LIBERA(cAlias,nReg,nOpc)
_oObj := GetObjBrow()
_oObj:Refresh()

If !Empty(VS6->VS6_DATAUT) .and. VS6->VS6_TIPAUT == "2" // Liberacao Oficina
	If VS1->VS1_STATUS == "4"
		DBSelectArea("VS1")
		RecLock("VS1",.f.)
		cVS1StAnt := VS1->VS1_STATUS
		VS1->VS1_STATUS := "F"
		MsUnlock()
		If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
			OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0001 ) // Grava Data/Hora na Mudan�a de Status do Or�amento / Libera��o de Cr�dito
		EndIf
		If FindFunction("FM_GerLog")
			//grava log das alteracoes das fases do orcamento
			FM_GerLog("F",VS1->VS1_NUMORC,,VS1->VS1_FILIAL,cVS1StAnt)
		EndIF
		DBSelectArea("VS6")
	Endif
Endif

/* Skip � necessario por causa do REFRESH do mBrowse ...
dbSelectArea("VS6")
dbSkip()
If EOF()
dbGoTop()
EndIf
*/

Return .t.
/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Thiago						    � Data � 30/10/14 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Menu (AROTINA) - Orcamento de Pecas e Servicos                         ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina := {	{ STR0011, "axPesqui",    0, 1},;    // "Pesquisar"
{ STR0002, "VM710L"  , 0, 2},;    // "Visualizar"
{ STR0003, "VM710L"  , 0, 4},;    // "Liberar"
{ STR0004, "VM710C"  , 0, 4},;    // Cancelar Liberacao
{ STR0005,"VM710LEG" 	, 0 , 2,0,.f.}} && Legenda
Return aRotina

/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    � FS_LIBERA� Autor � Thiago							� Data � 30/10/14 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Libera��o de Cr�dito. 								                  ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Static Function FS_LIBERA(cAlias,nReg,nOpc)
Local aSizeAut	:= MsAdvSize(.t.)
Local aObjects 	:= {}
Local aCpos := {}
Local lMemoria := .t.
Local lColumn := .f.
Local cATela := ""
Local lNoFolder := .t.
Local lProperty := .f.
Local nModelo := 3
Local cTudoOk := ".t."
Local lF3 := .f.       
Local nOpca := 1
Private aCpoEncS := {}   

if nOpc <> 2
	If VQB->VQB_STATUS <> "0"
		MsgStop(STR0006)
		Return(.f.)
	Endif
Endif
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VQB")    
cVQBnMostra := ""
//
While !Eof().and.(x3_arquivo=="VQB")
	If X3USO(x3_usado).and.cNivel>=x3_nivel .and. !(Alltrim(x3_campo)+"," $ cVQBnMostra)
		AADD(acpoEncS,x3_campo)
	EndIf
	If x3_context == "V"
		&("M->"+x3_campo):= CriaVar(x3_campo)
	Else
		&("M->"+x3_campo):= &("VQB->"+x3_campo)
	EndIf
	DbSkip()
Enddo
//################################################################
//# Especifica o espacamento entre os objetos principais da tela #
//################################################################
// Tela Superior - Enchoice do VS1 - Tamanho vertical fixo
AAdd( aObjects, { 0,	360, .T., .t. } )

aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 }// Tamanho total da tela
aPosObj := MsObjSize( aInfo, aObjects ) // Monta objetos conforme especificacoes
 
//####################################################
//# Montagem da tela da liberacao                    #
//####################################################
oDlg := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cCadastro,,,,,,,,,.t.)
//#####################################################
//# Monta a enchoice do VS1 com os campos necessarios #
//#####################################################
aPosEnchoice := aClone(aPosObj[1])
oEnch := MSMGet():New( cAlias ,nReg,nOpc ,,,,aCpoEncS, aPosEnchoice,aCpos,nModelo,,,cTudoOk,oDlg,lF3,lMemoria,lColumn,caTela,lNoFolder, lProperty)
//

oDlg:bInit := {|| EnchoiceBar(oDlg, { || VM710GRA(nOpc,nOpca) } , { || nOpca := 0, oDlg:End() },, )}
oDlg:Activate()
//

Return(.t.)                              

/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    �VM710GRA  � Autor � Thiago							� Data � 30/10/14 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Gravacao da liberacao. 								                  ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Static Function VM710GRA(nOpc,nOpca)

if nOpca == 1
	If VQB->VQB_STATUS == "0"
		DBSelectArea("VQB")
		RecLock("VQB",.f.)
		VQB->VQB_STATUS := "1"
		MsUnlock()
		DBSelectArea("VQB")
	Endif
Endif
oDlg:End()

Return(.t.)

/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    �VM710C    � Autor � Thiago							� Data � 30/10/14 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Cancelamento da liberacao. 							                  ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Function VM710C()

if VQB->VQB_STATUS == "1"
	If MsgYesNo(STR0007)
		DBSelectArea("VQB")
		RecLock("VQB",.f.)
		VQB->VQB_STATUS := "0"
		MsUnlock()
		DBSelectArea("VQB")
	Endif                        
Else
	MsgStop(STR0008)
Endif

Return(.t.)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �VM710LEG   � Autor � Thiago               � Data � 30/10/14 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cria uma janela contendo a legenda da mBrowse              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �ofiom030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VM710LEG()

Local aLegenda  := {{ 'BR_VERDE'	, STR0009 },;	// Aguardando liberacao
{ 'BR_VERMELHO'	, STR0010 } }	// Liberado para faturar

BrwLegenda(cCadastro,STR0005 ,aLegenda)  //Legenda

Return .T.
