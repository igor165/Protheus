#Include "plsa030.ch"
#Include "PLSMGER.CH"
#Include "PROTHEUS.CH"
#Include "COLORS.CH" 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PLSA030 � Autor � Michele Tatagiba     � Data � 11.03.2002 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Complemento para Operadoras de Saude           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSA030
//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis...                                          �
//�����������������������������������������������������������������������
Private aRotina     := MenuDef()
Private cCadastro 	:= STR0002 //"Complemento de Operadora de Saude"
//���������������������������������������������������������������������Ŀ
//� Chama funcao de Browse...                                           �
//�����������������������������������������������������������������������
BA0->(DbSetOrder(1))
BA0->(dbGoTop())
BA0->(mBrowse(06,01,22,75,"BA0"))
//���������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal...                                          �
//�����������������������������������������������������������������������
Return Nil
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PL030MOV � Autor � Tulio                 � Data � 23.02.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Modulo de Manutencao do Cmplemento de Operadora de Saude   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PL030MOV(cAlias,nReg,nOpc)                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PL030MOV(cAlias,nReg,nOpc)

Local I__f          := 0
//���������������������������������������������������������������������Ŀ
//� Uso na enchoice...                                                  �
//�����������������������������������������������������������������������
Local nOpca         := 0
Local nPosCodPad    := 0
Local nPosDesPad    := 0
Local nX	        := 0
Local aButtons      := {}
//���������������������������������������������������������������������Ŀ
//� Uso na Dialog...                                                    �
//�����������������������������������������������������������������������
Local aPosObj       := {}
Local aObjects      := {}
Local aSize         := {}
Local aInfo         := {}
//���������������������������������������������������������������������Ŀ
//� Dados da Enchoice...                                                �
//�����������������������������������������������������������������������
Private aTELA[0][0]
Private aGETS[0]
Private oEncBA0
Private oDlg
Private oFolder
Private aCols       := {}
Private aHeader     := {} 
//���������������������������������������������������������������������Ŀ
//� Intercambio eventual especIfico...                                  �
//�����������������������������������������������������������������������
Private aCabBMP     := {}
Private aDadBMP     := {}
Private aTrbBMP     := {}
Private oBrwBMP         
Private cTipESPSel  := ""
//���������������������������������������������������������������������Ŀ
//� GetDados dos Parametros Pagamento...                                �
//�����������������������������������������������������������������������
Private aCabPPg     := {}
Private aDadPPg     := {}
Private aTrbPPg     := {}
Private oBrwPPg      
Private cTipPreSel  := ""
//���������������������������������������������������������������������Ŀ
//� GetDados dos Parametros Pagamento x Procedimentos...                �
//�����������������������������������������������������������������������
Private aCabPPP     := {}
Private aDadPPP     := {}
Private aTrbPPP     := {}
Private oBrwPPP
//���������������������������������������������������������������������Ŀ
//� GetDados das Tabelas de Pagamento e Recebimento...                  �
//�����������������������������������������������������������������������
Private aCabBH0     := {}
Private aDadBH0     := {}
Private aTrbBH0     := {}
Private oBrwBH0
//���������������������������������������������������������������������Ŀ
//� Genericos...                                                        �
//�����������������������������������������������������������������������
Private cChave      := BA0->(BA0_CODIDE+BA0_CODINT)
Private nOpcx       := nOpc
Private aChave  
//���������������������������������������������������������������������Ŀ
//� GetDados das Tabelas de Reembolso                                   �
//�����������������������������������������������������������������������
Private aCabB7T     := {}
Private aDadB7T     := {}
Private aTrbB7T     := {}
Private oBrwB7T

//���������������������������������������������������������������������Ŀ
//� Monta Dialogo...                                                    �
//�����������������������������������������������������������������������
If nOpc <> K_Incluir
   cCadastro := STR0003+BA0->BA0_NOMINT //"Complemento de Operadora de Saude - "
Else
   cCadastro := STR0002 //"Complemento de Operadora de Saude"
EndIf

If  Existblock("PLA030A1")  
	aButtons := aClone(Execblock("PLA030A1",.f.,.f.,{aButtons} ))
EndIf

aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 100, 100, .t., .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL 

//���������������������������������������������������������������������Ŀ
//� Define Folder...                                                    �
//�����������������������������������������������������������������������
@ aPosObj[1][1],aPosObj[1][2] FOLDER oFolder SIZE aPosObj[1][3],aPosObj[1][4] OF oDlg PIXEL	PROMPTS	STR0004,STR0005,STR0006,STR0007,STR0012 //"Operadora de Saude"###"Intercambio Eventual EspecIfico"###"Parametros para Pagamento"###"Tabelas de Pagamento e Recebimento"###"Tabelas de Reembolso"
//���������������������������������������������������������������������Ŀ
//� Intercambio eventual especIfico...                                  �
//�����������������������������������������������������������������������
If PLSALIASEX("BMP")
   Store Header "BMP" TO aCabBMP For .T.
   If nOpcx == K_Incluir
      Store COLS Blank "BMP" TO aDadBMP FROM aCabBMP
   Else
      BMP->(DbSetOrder(1))
      If ! BMP->(DbSeek(xFilial("BMP")+cChave)) 
          Store COLS Blank "BMP" TO aDadBMP FROM aCabBMP
      Else
          cTipESPSel := BMP->BMP_CODIES
          Store COLS "BMP" TO aDadBMP FROM aCabBMP VETTRAB aTrbBMP While BMP->(BMP_FILIAL+BMP_CODINT) == xFilial("BMP")+cChave
      EndIf                                  
   EndIf
EndIf   

//���������������������������������������������������������������������Ŀ
//� Parametros Pagamento...                                             �
//�����������������������������������������������������������������������
Store Header "BMB" TO aCabPPg For .T.
If nOpcx == K_Incluir
   Store COLS Blank "BMB" TO aDadPPg FROM aCabPPg
Else
   BMB->(DbSetOrder(1))
   If ! BMB->(DbSeek(xFilial("BMB")+cChave)) 
       Store COLS Blank "BMB" TO aDadPPg FROM aCabPPg
   Else
       cTipPreSel := BMB->BMB_TIPPRE
       Store COLS "BMB" TO aDadPPg FROM aCabPPg VETTRAB aTrbPPg While BMB->BMB_CODINT == cChave
   EndIf                                  
EndIf 

//���������������������������������������������������������������������Ŀ
//� Parametros Pagamento x Procedimentos...                             �
//�����������������������������������������������������������������������
Store Header "BMC" TO aCabPPP For .T.
If nOpcx == K_Incluir
   Store COLS Blank "BMC" TO aDadPPP FROM aCabPPP
Else
   BMC->(DbSetOrder(1))
   If ! BMC->(DbSeek(xFilial("BMC")+cChave)) 
       Store COLS Blank "BMC" TO aDadPPP FROM aCabPPP
   Else
       Store COLS "BMC" TO aDadPPP FROM aCabPPP VETTRAB aTrbPPP While BMC->BMC_CODINT == cChave  
   EndIf
   //Acerta de descricao

   nPosCodPad := Ascan(aCabPPP, {|x| Alltrim(x[2]) == "BMC_CODPAD"})          
   If nPosCodPad > 0 
  	  BR4->(dbSetOrder(1))
	  For nX := 1 to Len(aDadPPP)
	  	  If BR4->(dbSeek(xFilial("BR4")+aDadPPP[nX,nPosCodPad]+"01"))
			  nPosDesPad := Ascan(aCabPPP, {|x| Alltrim(x[2]) == "BMC_DESPAD"})
			  If nPosDesPad > 0
				aDadPPP[nX,nPosDesPad]:= BR4->BR4_DESCRI
			  EndIf
	  	  EndIf
	  Next nX
   EndIf    

EndIf
//���������������������������������������������������������������������Ŀ
//� Tipo de Tabela...                                                   �
//�����������������������������������������������������������������������
If PLSALIASEX("BH0")
   Store Header "BH0" TO aCabBH0 For .T.
   If nOpcx == K_Incluir
      Store COLS Blank "BH0" TO aDadBH0 FROM aCabBH0
   Else
      BH0->(DbSetOrder(1))
      If ! BH0->(DbSeek(xFilial("BH0")+cChave)) 
          Store COLS Blank "BH0" TO aDadBH0 FROM aCabBH0
      Else
          Store COLS "BH0" TO aDadBH0 FROM aCabBH0 VETTRAB aTrbBH0 While BH0->BH0_CODINT == cChave
      EndIf                                  
   EndIf
EndIf

//���������������������������������������������������������������������Ŀ
//� Tipo de Tabela de Reembolso                                         �
//�����������������������������������������������������������������������
If PLSALIASEX("B7T")
   Store Header "B7T" TO aCabB7T For .T.
   If nOpcx == K_Incluir
      Store COLS Blank "B7T" TO aDadB7T FROM aCabB7T
   Else
      B7T->(DbSetOrder(1))
      If ! B7T->(DbSeek(xFilial("B7T")+cChave)) 
          Store COLS Blank "B7T" TO aDadB7T FROM aCabB7T
      Else
          Store COLS "B7T" TO aDadB7T FROM aCabB7T VETTRAB aTrbB7T While B7T->B7T_CODINT == cChave
      EndIf                                  
   EndIf
EndIf

//���������������������������������������������������������������������Ŀ
//� ENCHOICE (BD1)                                                      �
//�����������������������������������������������������������������������
If nOpcx <> K_Incluir
   BA0->(DbGoTo(nReg))
EndIf   

If nOpcx == K_Incluir
   Copy "BA0" TO Memory Blank
Else
   Copy "BA0" TO Memory
EndIf
//���������������������������������������������������������������������Ŀ
//� MSMGET -> CONTRATO                                                  �
//�����������������������������������������������������������������������
cAlias:="BA0";oEncBA0 := MSMGet():New(cAlias,nReg,K_Visualizar,,,,,{aPosObj[1][1],aPosObj[1][2],aPosObj[1][4]-15,aPosObj[1][3]-3},,,,,,oFolder:aDialogs[1],,,.F.)
//���������������������������������������������������������������������Ŀ
//� GETDADOS -> Intercambio eventual...                                 �
//�����������������������������������������������������������������������
If PLSALIASEX("BMP")
   oBrwBMP  := TPLSBrw():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][3]-3,aPosObj[1][4]-15,nil  ,oFolder:aDialogs[2], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabBMP,aDadBMP,.F.,"BMP",K_Alterar,STR0005,nil,nil,nil,aTrbBMP) //"Intercambio Eventual EspecIfico"
EndIf   
//���������������������������������������������������������������������Ŀ
//� GETDADOS -> Parametros Pagamento...                                 �
//�����������������������������������������������������������������������
oBrwPPg  := TPLSBrw():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][3]-3,(aPosObj[1][4]/2)-15,nil  ,oFolder:aDialogs[3], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabPPg,aDadPPg,.F.,"BMB",K_Alterar,STR0008,nil,nil,nil,aTrbPPg,'PlsVldBMB()') //"Parametros Pagamento"
oBrwPPg:bLostFocus := { || cTipPreSel := oBrwPPg:aCols[oBrwPPg:Linha(),oBrwPPg:PLRETPOS("BMB_TIPPRE")] }
oBrwPPg:bChange    := { || Eval(oBrwPPg:bLostFocus), oBrwPPP:ForceRefresh(oBrwPPg) }
//���������������������������������������������������������������������Ŀ
//� GETDADOS -> Parametros Pagamento X Procedimento...                  �
//�����������������������������������������������������������������������
bFilter  := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BMC_TIPPRE",aHeader)] == cTipPreSel }
oBrwPPP  := TPLSBrw():New(aPosObj[1][1]+(aPosObj[1][4]/2)-20,aPosObj[1][2],aPosObj[1][3]-3,aPosObj[1][4]-14,nil  ,oFolder:aDialogs[3], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabPPP,aDadPPP,.F.,"BMC" ,K_Alterar,STR0009,nil,nil,nil,aTrbPPP,'PlsVldBMC()',,bFilter) //"Parametros Pagamento  X Procedimentos"
oBrwPPP:oPai       := oBrwPPg
oBrwPPP:aOrigem    := {"BMB_TIPPRE"}
oBrwPPP:aRelac     := {"BMC_TIPPRE"}

If PLSALIASEX("BH0") 
   oBrwBH0  := TPLSBrw():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][3]-3,aPosObj[1][4]-15,nil  ,oFolder:aDialogs[4], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabBH0,aDadBH0,.F.,"BH0",K_Alterar,STR0007,nil,nil,nil,aTrbBH0) //"Tabelas de Pagamento e Recebimento"
EndIf

If PLSALIASEX("B7T") 
   oBrwB7T  := TPLSBrw():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][3]-3,aPosObj[1][4]-15,nil  ,oFolder:aDialogs[5], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabB7T,aDadB7T,.F.,"B7T",K_Alterar,STR0012,nil,nil,nil,aTrbB7T) //"Tabelas de Reembolso"
EndIf
//���������������������������������������������������������������������Ŀ
//� Ativa Dialog                                                        �
//�����������������������������������������������������������������������                            
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||oDlg:End()},NIL,aButtons)
//���������������������������������������������������������������������Ŀ
//� Caso seja confirmada a operacao grava os dados...                   �
//�����������������������������������������������������������������������
If nOpca == K_OK
   //���������������������������������������������������������������������Ŀ
   //� Grava intercambio eventual especIfico...                            �
   //�����������������������������������������������������������������������
   If PLSALIASEX("BMP")
      aChave := {}
      aadd(aChave,{"BMP_CODINT",M->BA0_CODIDE+M->BA0_CODINT})
   
      oBrwBMP:Grava(aChave)
   EndIf   
   //���������������������������������������������������������������������Ŀ
   //� Grava propriedades pagamento...                                     �
   //�����������������������������������������������������������������������
   oBrwPPg:Consiste()         

   aChave := {}
   aadd(aChave,{"BMB_CODINT",M->BA0_CODIDE+M->BA0_CODINT})
   
   oBrwPPg:Grava(aChave)
   //���������������������������������������������������������������������Ŀ
   //� Grava propriedades pagamento x procedimento...                      �
   //�����������������������������������������������������������������������
   oBrwPPP:Consiste()         

   aChave := {}
   aadd(aChave,{"BMC_CODINT",M->BA0_CODIDE+M->BA0_CODINT})

   oBrwPPP:Grava(aChave)   
   //���������������������������������������������������������������������Ŀ
   //� Grava Tabelas de Pagamento e Recebimento...                         �
   //�����������������������������������������������������������������������
   If PLSALIASEX("BH0")
      aChave := {}
      aadd(aChave,{"BH0_CODINT",M->BA0_CODIDE+M->BA0_CODINT})
   
      oBrwBH0:Grava(aChave)
   EndIf   
   
   //���������������������������������������������������������������������Ŀ
   //� Grava Tabelas de Reembolso                                          �
   //�����������������������������������������������������������������������
   If PLSALIASEX("B7T")
      aChave := {}
      aadd(aChave,{"B7T_CODINT",M->BA0_CODIDE+M->BA0_CODINT})
   
      oBrwB7T:Grava(aChave)
   EndIf 
EndIf
//���������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal de Movimentacao                             �
//�����������������������������������������������������������������������
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSCHKBMC �Autor  �Robson Nayland      � Data �  03/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��o para checar os registros na tabela BBM               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PLSCHKBMC(oBrwPPP) 

Local lret	  :=.T.
Local nPosTip := PLRETPOS("BMC_TIPPRE",oBrwPPP:AHEADER)
Local I

For i:=1 to Len(oBrwPPP:ACOLS)
    If Empty(oBrwPPP:ACOLS[i,nPosTip])
       lret:=.F. 
       MsgAlert(STR0010) //"Item n�o poder� ser gravado devido os par�mentros da Operadora vs.Tp.Prest.vs.Pago(BMB) n�o estarem preenchidos."
       Exit
    EndIf
Next i

Return lret     

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �22/12/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
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
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()   

Private aRotina := { { STRPL01 ,'AxPesqui' , 0 ,K_Pesquisar  ,0 ,.F. },; // Pesquisar
                     { STR0001 ,'pl030Mov' , 0 ,K_Visualizar ,0 ,Nil } } //"Visualizar"
Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PlsVldBMB �Autor  �Microsiga           � Data �  30/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para chamada no botao de OK na aba de Horarios      ���
���          � Especiais para validar a Data de Vigencia Inicial.         ���
�������������������������������������������������������������������������͹��
���Uso       � PLS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function PlsVldBMB()

Local lRet     := .T.
Local cDatDe  := ""
Local cDatAte := ""
Local aChave  := {'01',M->BMB_TIPPRE+M->BMB_CODTAB,'BMB_TIPPRE+BMB_CODTAB'}
local nFor	  := 0
local nTip	  := 0
local nCampoAte := 0
local nCampoDe  := 0
local lAdd 	  := .F.


if empty(M->BMB_VIGDE) .and. (!empty(M->BMB_VIGATE) .or. !empty(M->BMB_DATDE))
	MsgAlert(STR0014) // "Por favor, preencha a data de vig�ncia inicial"
	lRet := .F.	
elseif !empty(M->BMB_VIGATE) .and. M->BMB_VIGDE > M->BMB_VIGATE
	MsgAlert(STR0015) // "Data de vig�ncia inicial deve ser menor que vig�ncia final"
	lRet := .F.	
elseif !empty(M->BMB_DATDE) .and.  M->BMB_VIGDE > M->BMB_DATDE
	MsgAlert(STR0016) // "Data de vig�ncia inicial deve ser menor que Ap�s Data"
	lRet := .F.	
elseif !empty(M->BMB_VIGATE) .and. !empty(M->BMB_DATDE) .and.  M->BMB_VIGATE < M->BMB_DATDE
	MsgAlert(STR0017) // "Data de vig�ncia final deve ser maior que Ap�s Data"
	lRet := .F.	
endif

if lRet == .T.
	nTip := aScan(oBrwPPG:aHeader, {|x| Alltrim(x[2]) == "BMB_TIPPRE"})
	nCampoAte := aScan(oBrwPPG:aHeader, {|x| Alltrim(x[2]) == "BMB_VIGATE"})
	nCampoDe := aScan(oBrwPPG:aHeader, {|x| Alltrim(x[2]) == "BMB_VIGDE"})
	For nFor := 1 To len(oBrwPPG:aCols)
		lAdd := iif(len(oBrwPPG:aCols) < len(oBrwPPG:oBrowse:aCols), .T., .F.)
		if M->BMB_TIPPRE == oBrwPPG:aCols[nFor,nTip] .and. !(oBrwPPG:aCols[nFor, len(oBrwPPG:aCols[nFor])]) .and. ( lAdd .or. nFor != oBrwPPG:oBrowse:nAt) 
			if empty(oBrwPPG:aCols[nFor, nCampoAte]) .and. !empty(oBrwPPG:aCols[nFor, nCampoDe])
				MsgAlert(STR0018) // "J� existe uma vig�ncia em aberto"
				lRet := .F.		
			elseif !empty(oBrwPPG:aCols[nFor, nCampoAte]) .and. M->BMB_VIGDE < oBrwPPG:aCols[nFor, nCampoAte]
				MsgAlert(STR0019) // "Data de vig�ncia inicial deve ser maior que a vig�ncia final do ultimo registro"
				lRet := .F.	
			endif
		endif	
	next
endif

Return(lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VldCmpBmc �Autor  �Microsiga           � Data �  06/08/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao criada para substituir e complementar o valid dos cam���
���          �pos BMC_CODPAD e BMC_CODPSA                                 ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAPLS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VldCmpBmc(cCampo,cTipPre,cCodPad,cCodPsa,cNivel) 

Local cCodInt := PlsIntPad()
Local nFor    := 0
Local nCodPad := 0
Local nCodPsa := 0
Local nTipPre := 0
Local lRet    := .T.

oBrwPPP:oBrowse:ForceRefresh()

If Empty(AllTrim(cCodPad)) .Or. Empty(AllTrim(cCodPsa))
	Return .T.
EndIf

If cCampo == "BMC_CODPSA"
	If !(ExistCpo("BR8",cCodPad+cCodPsa,1) .And. PLSGATNIV(cCodPad,cCodPsa,"BMC"))
		Return .F.
	EndIf
EndIf

If lRet .And. cCampo == "BMC_CODPAD"
	If !(ExistCpo("BR4",cCodPad,1) .And. ExistCpo("BR8",cCodPad+cCodPsa,1))
		Return .F.
	EndIf
EndIf

BMC->(dbSetOrder(1))
If lRet .And. BMC->(dbSeek(xFilial("BMC")+cCodInt+cTipPre+cCodPad+cCodPsa+IIf(!Empty(cNivel),cNivel,"")))
	MsgInfo("Procedimento j� cadastrado!")
	Return .F.
EndIf

If lRet 
	nCodPad := IIf(Len(oBrwPPP:aCols) > 0,AsCan(oBrwPPP:aHeader, {|x| Alltrim(x[2]) == "BMC_CODPAD"}),0)
	nCodPsa := IIf(Len(oBrwPPP:aCols) > 0,AsCan(oBrwPPP:aHeader, {|x| Alltrim(x[2]) == "BMC_CODPSA"}),0)
	nTipPre := IIf(Len(oBrwPPP:aCols) > 0,AsCan(oBrwPPP:aHeader, {|x| Alltrim(x[2]) == "BMC_TIPPRE"}),0)
	For nFor := 1 To Len(oBrwPPP:aCols)
		If lRet .And. Len(oBrwPPP:aCols) > 1
			If (oBrwPPP:aCols[nFor,nTipPre] == cTipPre .And. oBrwPPP:aCols[nFor,nCodPsa] == cCodPsa .And. oBrwPPP:aCols[nFor,nCodPad] == cCodPad)
				MsgInfo(STR0011) //Procedimento j� cadastrado
				Return .F.
			EndIf
		EndIf
	Next nFor
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PlsVldBMB �Autor  �Microsiga           � Data �  30/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para chamada no botao de OK na aba de Horarios      ���
���          � Especiais para validar a Data de Vigencia Inicial.         ���
�������������������������������������������������������������������������͹��
���Uso       � PLS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function PlsVldBMC()

Local lRet     := .T.
Local cDatDe  := ""
Local cDatAte := ""
Local aChave  := {'01',M->BMC_CODPAD+M->BMC_CODPSA,'BMC_CODPAD+BMC_CODPSA'}

If BMC->( FieldPos("BMC_VIGDE") ) > 0 .And. BMC->( FieldPos("BMC_VIGATE") ) > 0
	cDatDe  := "BMC_VIGDE"
	cDatAte := "BMC_VIGATE"

	lRet := PLSVLDVIG("BMC",4,oBrwPPP,cDatDe,cDatAte,aChave)
	
	If lRet
		PLSGATNIV(M->BMC_CODPAD,M->BMC_CODPSA,"BMC")
	Endif
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVLDB7T

Fun��o de valida��o que checa se os campos tabela de pre�o e tabela de reembolso est�o preenchidos.
Regra: Somente 1 pode ser preenchido

@author Rodrigo Morgon
@since 25/07/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLSVLDB7T()

Local lRet 	:= .T.
Local nI 		:= 1
Local nCodPad := 0
Local nTabRee := 0
Local nTabPre := 0
Local lTabPreExi := (B7T->(FieldPos("B7T_TABPRE")) > 0)

If lTabPreExi
	If !Empty(M->B7T_TABREE) .and. !Empty(M->B7T_TABPRE)
		MsgStop("Somente um dos campos (tabela de pre�o ou tabela de reembolso) pode ser preenhcido para cada registro.")
		Return (.F.)
	EndIf
EndIf

If lRet
	If Len(oBrwB7T:aCols) > 0
		nCodPad := AsCan(oBrwB7T:aHeader, {|x| Alltrim(x[2]) == "B7T_CODPAD"})
		nTabRee := AsCan(oBrwB7T:aHeader, {|x| Alltrim(x[2]) == "B7T_TABREE"})
		nTabPre := AsCan(oBrwB7T:aHeader, {|x| Alltrim(x[2]) == "B7T_TABPRE"})
		
      if lTabPreExi .And. nTabPre > 0
				
			//Verifica se o registro j� existe na tabela
			For nI := 1 to Len(oBrwB7T:aCols)

				if	M->B7T_CODPAD == oBrwB7T:aCols[nI][nCodPad] .and. ;
					M->B7T_TABREE == oBrwB7T:aCols[nI][nTabRee] .and. ;
				   M->B7T_TABPRE == oBrwB7T:aCols[nI][nTabPre]
					
					lRet := .F.
					exit
				endif
			Next nI		
		else
			//Verifica se o registro j� existe na tabela
			For nI := 1 to Len(oBrwB7T:aCols)
				if	M->B7T_CODPAD == oBrwB7T:aCols[nI][nCodPad] .and. ;
					M->B7T_TABREE == oBrwB7T:aCols[nI][nTabRee]
					
					lRet := .F.
					exit
				endif
			Next nI
		endif			
		
	ElseIf ReadVar() == "M->B7T_TABREE"
		B7T->(dbSetOrder(1))
		lRet := !(B7T->(MsSeek(xFilial("B7T")+BA0->BA0_CODIDE+BA0->BA0_CODINT+M->B7T_CODPAD+M->B7T_TABREE)))
	ElseIf B7T->(FieldPos("B7T_TABPRE")) > 0 .and. ReadVar() == "M->B7T_TABPRE"
		B7T->(dbSetOrder(2))
		lRet := !(B7T->(MsSeek(xFilial("B7T")+BA0->BA0_CODIDE+BA0->BA0_CODINT+M->B7T_CODPAD+M->B7T_TABPRE)))	
	EndIf
EndIf

if !lRet
	MsgStop(STR0013) //"Registro j� existente."
endif

Return (lRet)