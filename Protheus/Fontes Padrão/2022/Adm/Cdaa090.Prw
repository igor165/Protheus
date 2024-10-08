#include "CDAA090.ch"
#include "protheus.ch"
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CDAA090  � Autor �Fabio Rogerio Pereira  � Data � 02/05/2002 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Regras Padroes								 			    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function CDAA090(nRotina)

Private cCadastro := STR0006 //"Cadastro de regras padroes"
Private aRotina 	:= MenuDef()


//���������������������������������������������������������Ŀ
//� Salva a Interface                                       �
//�����������������������������������������������������������
If AMIIn(45)
	mBrowse( 6, 1,22,75, "AHC")
EndIf

Return 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �CDAA090Dlg� Autor �Fabio Rogerio Pereira  � Data � 02/05/2002 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Regras Padroes									���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function CDA090Dlg(cAlias,nReg,nOpcx)

Local aSize			:= {}
Local aObjects		:= {}
Local nOpcA			:= 0
Local oDlg
Local oGet
Local ny := 0
PRIVATE aHeader	:= {}
PRIVATE aCols	:= {}

RegToMemory("AHC",IIf(nOpcx == 3,.T.,.F.))

//��������������������������������������������������������������Ŀ
//� Montagem do aHeader                                          �
//����������������������������������������������������������������
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("AHD")
While !EOF() .And. (x3_arquivo == "AHD")
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel
		AADD(aHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal, x3_valid,;
			x3_usado, x3_tipo, x3_arquivo,x3_context } )
	Endif
	dbSkip()
End

If (nOpcx == 3)
	//��������������������������������������������������������������Ŀ
	//� Faz a montagem de uma linha em branco no aCols               �
	//����������������������������������������������������������������
	aadd(aCols,Array(Len(aHeader)+1))
	For ny := 1 to Len(aHeader)
		If Trim(aHeader[ny][2]) == "AHD_ITEM"
			aCols[1][ny] 	:= "01"
		Else
			aCols[1][ny] := CriaVar(aHeader[ny][2])
		EndIf
		aCols[1][Len(aHeader)+1] := .F.
	Next ny
Else
	//��������������������������������������������������������������Ŀ
	//� Faz a montagem do aColsAE2                                   �
	//����������������������������������������������������������������
	dbSelectArea("AHD")
	dbSetOrder(1)
	dbSeek(xFilial("AHD")+AHC->AHC_REGRA)
	While !Eof() .And. AHD->AHD_FILIAL+AHD->AHD_REGRA==xFilial("AHD")+AHC->AHC_REGRA
		aADD(aCols,Array(Len(aHeader)+1))
		
		For ny := 1 to Len(aHeader)
			If ( aHeader[ny][10] != "V")
				aCols[Len(aCols)][ny] := FieldGet(FieldPos(aHeader[ny][2]))
			Else
				aCols[Len(aCols)][ny] := CriaVar(aHeader[ny][2])
			EndIf
			aCols[Len(aCols)][Len(aHeader)+1] := .F.
		Next ny
		dbSkip()
	EndDo

	If Empty(aCols)
		//��������������������������������������������������������������Ŀ
		//� Faz a montagem de uma linha em branco no aCols               �
		//����������������������������������������������������������������
		aadd(aCols,Array(Len(aHeader)+1))
		For ny := 1 to Len(aHeader)
			If Trim(aHeader[ny][2]) == "AHD_ITEM"
				aCols[1][ny] 	:= "01"
			Else
				aCols[1][ny] := CriaVar(aHeader[ny][2])
			EndIf
			aCols[1][Len(aHeader)+1] := .F.
		Next ny
	EndIf
EndIf
	
//������������������������������������������������������Ŀ
//� Faz o calculo automatico de dimensoes de objetos     �
//��������������������������������������������������������
aSize := MsAdvSize(,.F.,400)
aObjects := {} 

AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

EnChoice( cAlias, nReg, nOpcx, , , , , aPosObj[1],, 3 )
oGet:= MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"CA090LinOk","CA090TudOk","+AHD_ITEM",.T.,,1,,300,,,,,oDlg)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(!Empty(M->AHC_REGRA) .And. CA090TudOk(),(nOpcA:=1,oDlg:End()),Nil)},{||oDlg:End()})

If nOpcA == 1 
	Begin Transaction
		A010Grava(nOpcx)
	End Transaction
EndIf

Return


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �A010Grava� Autor � Edson Maricate         � Data � 09-02-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Executa a gravaco da composicao.                             ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � PMSA010.                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function A010Grava(nOpcx)
Local bCampo 	:= {|n| FieldName(n) }
Local nI		:= 0
Local i     := 0

If (nOpcx <> 5)
	//�����������������������������������������������������Ŀ
	//� Grava arquivo AHC (Regras)                          �
	//�������������������������������������������������������
	Do Case
		Case nOpcx == 3  // INCLUSAO
			If __lSX8
				ConfirmSX8()
			EndIf
			
		Case nOpcx == 4 //ALTERACAO
			
			//Apago os itens
			DbSelectArea("AHD")
			DbSetOrder(1)
			DbSeek(xFilial("AHD")+M->AHC_REGRA)
			While !Eof() .AND. (xFilial("AHD") == AHD->AHD_FILIAL) .AND. (M->AHC_REGRA == AHD->AHD_REGRA)
				RecLock("AHD",.F.,.T.)
				DbDelete()
				MsUnlock()
				DbSkip()
			End
			
	EndCase
	
	RecLock("AHC",IIf(nOpcx == 3,.T.,.F.))

	For nI:=1 To FCount()
		If ( FieldName(nI) == "AHC_FILIAL" )
			FieldPut(nI, xFilial("AHC"))
		Else
			FieldPut(nI, M->&(FieldName(nI)))
		EndIf
	Next nI
	
	For nI:=1 To Len(aCols)
		If !aCols[nI,Len(aHeader)+1]
			DbSelectArea("AHD")
			Reclock("AHD",.T.)
			bCampo := {|nCPO| Field(nCPO) }
		
			Replace AHD->AHD_FILIAL  With xFilial("AHD")
			Replace AHD->AHD_REGRA  With M->AHC_REGRA
		
			For i := 1 To AHD->(FCount())
				If (EVAL(bCampo,i) <> "AHD_FILIAL") .AND. (EVAL(bCampo,i) <> "AHD_REGRA")
					nPos:= Ascan(aHeader,{|x| EVAL(bCampo,i) $ x[2]})
				
					If (nPos > 0)
						Replace AHD->&(EVAL(bCampo,i)) With aCols[nI][nPos]
					EndIf
				EndIf
			Next i
		
			MsUnlock()
		EndIf		
	Next nI
Else
	//�����������������������������������������������������Ŀ
	//� Deleta arquivo AHD (Itens)                           �
	//�������������������������������������������������������
	DbSelectArea("AHD")
	DbSetOrder(1)
	DbSeek(xFilial("AHD")+AHC->AHC_REGRA)
	While (!Eof()) .AND. (AHD->AHD_FILIAL == xFilial("AHD")) .AND. (AHD->AHD_REGRA == AHC->AHC_REGRA)
		Reclock( "AHD" ,.F.,.T.)
		DbDelete()
		MsUnlock()
		DbSkip()
	End
	
	DbSelectArea("AHC")
	Reclock( "AHC" ,.F.,.T.)
	DbDelete()
	MsUnlock()
EndIf

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CA090TudOk� Autor �Fabio Rogerio Pereira  � Data � 02/05/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se todo o GetDados esta OK                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CdaA090                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CA090TudOk()
Local lRet := .T.
Local nX   := 0

For nX := 1 To Len(aCols)
	If ! CA090LinOk()
		lRet := .F.
		Exit
	Endif
Next

Return lRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CA090LinOk  � Autor �Fabio Rogerio Pereira� Data � 26/11/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se a linha atual esta correta                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Cdaa090                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CA090LinOk()
Local lRet      := .T.
Local nFaixaFim := 0
Local aColsAux 	:= {}
Local aDescont 	:= {}
Local nElement 	:= 0
Local nPosItem  := Ascan(aHeader, { |x| AllTrim(X[2]) == "AHD_ITEM" })
Local nPerDir	:= Ascan(aHeader, { |x| AllTrim(X[2]) == "AHD_PERCRE" })
Local nValDir 	:= Ascan(aHeader, { |x| AllTrim(X[2]) == "AHD_VALREG" })
Local nPosTpR   := Ascan(aHeader, { |x| AllTrim(X[2]) == "AHD_TIPOR" })
Local nPosFxIni := Ascan(aHeader, { |x| AllTrim(X[2]) == "AHD_FXINIC" })
Local nPosFxFim := Ascan(aHeader, { |x| AllTrim(X[2]) == "AHD_FXFINA" })
Local nPosDesco := Ascan(aHeader, { |x| AllTrim(X[2]) == "AHD_DESCMI" })
Local nx := 0
Local nDesc := 0

If !(aCols[n][Len(aHeader)+1])
	If (Empty(aCols[n][nPosItem]) .Or. (aCols[n][nPosFxIni] == 0))
		Help(" ",1,"DEFINA_FX")
		lRet := .F.
	Else
		For nX := 1 To Len(aCols)
			If 	aCols[nX][nPosFxFim] != 0 .And. ! aCols[nX][Len(aCols[nX])] .And.	aCols[nX][nPosTpr] = "1"
				Aadd( aColsAux, aCols[nx] )
				nElement := Ascan( aDescont, { | x | x[1] == aCols[nX][nPosDesco] } )
				
				If nElement == 0
					Aadd( aDescont, { aCols[nX][nPosDesco], aCols[nX][nPosFxIni] } )
				Else
					If aDescont[nElement][2] > aCols[nX][nPosFxIni]
						aDescont[nElement][2] := aCols[nX][nPosFxIni]
					Endif
				Endif
			Endif
		Next
	
		ASort( aColsAux,,,{ | x,y | x[nPosFxFim] < y[nPosFxFim] } )
	
		If Len(aColsAux) > 0
			For nDesc := 1 To Len(aDescont)
				If nFaixaFim != aDescont[nDesc][2]
					nFaixaFim := aDescont[nDesc][2] - 1
				Endif
				
				For nX := 1 To Len(aColsAux)
					If 	(aColsAux[nX][nPosFxIni] != (nFaixaFim+1) 		.And.;
						 ! Empty(aColsAux[nX][nPosFxFim])					.And.;
						(aColsAux[nX][nPosDesco] == aDescont[nDesc][1]))
					
						Help(" ",1,"FAIXAINCOR")
						Return .F.
					Endif
				
					If 	(aColsAux[nX][nPerDir] > 0.00 .And. aColsAux[nX][nValDir] > 0.00) .Or.;
						(aColsAux[nX][nPerDir] + aColsAux[nX][nValDir] = 0.00)
						Help(" ",1,"CA010DAUT")
						Return .F.
					Endif
							
					nFaixaFim := Iif(aColsAux[nX][nPosDesco] == aDescont[nDesc][1], aColsAux[nX][nPosFxFim], nFaixaFim)
				Next
			Next
		Endif
	Endif
EndIf	
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ca090ConUso� Autor � Wagner Mobile Costa  � Data � 05/09/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se a expressao digitada eh valida                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CdaA090                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ca090ConUso()

Return .T.

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
     
PRIVATE aRotina 	:= {	{ STR0001,"AxPesqui" , 0 , 1, 0, .F.},;		// "Pesquisar"
								{ STR0002,"CDA090Dlg", 0 , 2, 0, NIL},;		// "Visualizar"
								{ STR0003,"CDA090Dlg", 0 , 3, 0, NIL},;		// "Incluir"
								{ STR0004,"CDA090Dlg", 0 , 4, 2, NIL},;		// "Alterar"
								{ STR0005,"CDA090Dlg", 0 , 5, 1, NIL} }		// "Excluir"

If ExistBlock("CD090MNU")
	ExecBlock("CD090MNU",.F.,.F.)
EndIf

Return(aRotina)


