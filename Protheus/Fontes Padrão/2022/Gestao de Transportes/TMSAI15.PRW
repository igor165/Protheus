#include "Protheus.ch"
#include "TMSAI15.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAI15  � Autor � Richard Anderson      � Data � 22.11.06   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Aduanas por Regiao                               ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMS                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function TMSAI15()

Private cCadastro	:= STR0001 //-- Aduanas por Rota
Private aRotina		:= {{ STR0002  , "AxPesqui" , 0, 1 },; //"Pesquisar"
				          { STR0003  , "TMAI15Mnt" , 0, 2 },; //"Visualizar"
 				          { STR0004  , "TMAI15Mnt" , 0, 3 },; //"Incluir"
				          { STR0005  , "TMAI15Mnt" , 0, 4 },; //"Alterar"
				          { STR0006  , "TMAI15Mnt" , 0, 5 }}  //"Excluir"

dbSelectArea("DI2")
dbSetOrder(1)
dbGoTop()

mBrowse(06,01,22,75,"DI2")

Return Nil

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI15Mnt � Autor � Richard Anderson     � Data �19.03.2006 ���
��������������������������������������������������������������������������Ĵ��
���          � Interface do Cadastro de Aduanas por Rota                   ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Alias da tabela                                      ���
���          � ExpN2: Numero do Registro                                   ���
���          � ExpN3: Opcao do aRotina                                     ���
��������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMAI15Mnt(cAlias, nReg, nOpcx)

Local nUsado    := 0
Local nOpcA     := 0
Local aAreaDI2  := DI2->(GetArea())

Local aGet      := {}
Local aPosObj   := {} 
Local aObjects  := {}
Local aRecno    := {}
Local aSize     := MsAdvSize( .F. )             
Local nCntFor   := 0
Local aNoFields := {}
Local oDlg

Private aHeader := {}
Private aCols   := {} 
Private cCodReg := IIf(!Inclui,DI2->DI2_CODREG,CriaVar("DI2_CODREG"))
Private cDesReg := CriaVar("DI2_DESREG")
Private oDesReg := {}
Private oGetD   := {}

Aadd(aNoFields,"DI2_CODREG")
Aadd(aNoFields,"DI2_DESREG")

aadd( aGet,{ GetSx3Cache("DI2_CODREG", "X3_TITULO"), GetSx3Cache("DI2_CODREG", "X3_PICTURE") , GetSx3Cache("DI2_CODREG", "X3_F3") } )
aadd( aGet,{ GetSx3Cache("DI2_DESREG", "X3_TITULO"), GetSx3Cache("DI2_DESREG", "X3_PICTURE") , GetSx3Cache("DI2_DESREG", "X3_F3") } )

//��������������������������������������������������������������Ŀ
//� Monta o Array aHeader.                                       �
//����������������������������������������������������������������
aHeader:= APBuildHeader("DI2", aNoFields)
nUsado := Len(aHeader)
	
//��������������������������������������������������������������Ŀ
//� Monta o Array aCols.                                         �
//����������������������������������������������������������������
If !Inclui
	DI2->(dbSetOrder(1))
	DI2->(dbSeek(xFilial("DI2")+cCodReg))
	While DI2->(!Eof()) .And. DI2->(DI2_FILIAL+DI2_CODREG) == xFilial("DI2")+cCodReg
		Aadd(aCols,Array(nUsado+1))
		For nCntFor := 1 To nUsado
			If ( aHeader[nCntFor][10] != "V" )
				aCols[Len(aCols)][nCntFor] := DI2->(FieldGet(FieldPos(aHeader[nCntFor][2])))
			Else
				aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
			EndIf
		Next
		aCols[Len(aCols)][nUsado+1] := .F.
		DI2->(dbSkip())
	Enddo
Else
	If Empty(aCols)
		Aadd(aCols,Array(nUsado+1))

		For nCntFor := 1 To nUsado
			aCols[1][nCntFor] := CriaVar(aHeader[nCntFor][2])
		Next nCntFor

		aCols[Len(aCols)][nUsado+1] := .F.
	EndIf
EndIf

If	Empty(GDFieldGet('DI2_ITEM',1))
	GDFieldPut('DI2_ITEM',StrZero(1,Len(DI2->DI2_ITEM)),1)
EndIf
		
AAdd( aObjects, { 100,  50, .t., .F. } )
AAdd( aObjects, { 100, 100, .t., .t. } )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 } 
aPosObj := MsObjSize( aInfo, aObjects ) 
	
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 to aSize[6],aSize[5] Of oMainWnd PIXEL

	@ 35,005 SAY   aGet[1][1] SIZE 50,7 OF oDlg PIXEL	
	@ 35,040 MSGET cCodReg    PICTURE aGet[1][2] F3 "DUY"  VALID TMAI15Vld() WHEN Inclui SIZE 0,7 OF oDlg PIXEL	
	@ 35,085 MSGET oDesReg    VAR cDesReg PICTURE "@!"     WHEN .F. SIZE 120,7 OF oDlg PIXEL	
		
	oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"TMAI15LOk()","TMAI15TOk()","+DI2_ITEM",.T.,,,,999)
			
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, If(oGetd:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()})			

If nOpcA == 1 .And. nOpcx <> 2
	Begin Transaction
		TMAI15Grv(nOpcx)
	End Transaction
EndIf	

RestArea(aAreaDI2)
	
Return NIL

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI15LOk � Autor � Richard Anderson     � Data �22.11.2006 ���
��������������������������������������������������������������������������Ĵ��
���          � Validacao de digitacao de linha                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMAI15LOk()
Local lRet := .T.
//-- Nao avalia linhas deletadas.
If	!GDDeleted( n )
   If lRet := MaCheckCols(aHeader,aCols,n)
	   //-- Analisa se ha itens duplicados na GetDados.
	   lRet := GDCheckKey( { 'DI2_CODIAD' }, 4 )
	EndIf   
EndIf
Return(lRet)

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI15TOk � Autor � Richard Anderson     � Data �22.11.2006 ���
��������������������������������������������������������������������������Ĵ��
���          � Validacao de confirmacao para gravacao                      ���
��������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMAI15TOk()

Local lRet := .T.

//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet
	lRet := oGetD:ChkObrigat( n )
EndIf
//-- Analisa o linha ok.
If lRet
	lRet := TMAI15LOk()
EndIf

//-- Analisa se todas os itens da GetDados estao deletados.
If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
	Help( ' ', 1, 'OBRIGAT2') //Um ou alguns campos obrigatorios nao foram preenchidos no Browse.
	lRet := .F.
EndIf

Return(lRet)

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI15Vld � Autor � Richard Anderson     � Data �19.03.2006 ���
��������������������������������������������������������������������������Ĵ��
���          � Validacao de digitacao de campos                            ���
��������������������������������������������������������������������������Ĵ��
���Uso       � EAL                                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMAI15Vld(cCampo)

Local   lRet   := .T.
Default cCampo := AllTrim(Upper(ReadVar()))

If "CCODREG" $ cCampo
	lRet := ExistCpo("DUY",cCodReg,1) .And. ExistChav("DI2",cCodReg)
	If lRet
		cDesReg := Posicione("DUY",1,xFilial("DUY")+cCodReg,"DUY_DESCRI")
		oDesReg:Refresh()
	EndIf
ElseIf "DI2_CODIAD" $ cCampo
	lRet := ExistCpo("DI1",M->DI2_CODIAD,1)
	If lRet
		GdFieldPut("DI2_NOMADU",Posicione("DI1",1,xFilial("DI1")+M->DI2_CODIAD,"DI1_NOME"))
	EndIf
EndIf
			
Return(lRet)

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI15Grv � Autor � Richard Anderson     � Data �22.11.2006 ���
��������������������������������������������������������������������������Ĵ��
���          � Gravacao                                                    ���
��������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMAI15Grv(nOpcx)

Local nI     := 0
Local nCnt   := 0
Local nUsado := Len(aHeader)

DI2->(dbSetOrder(1))

If nOpcx == 3 .Or. nOpcx == 4
	For nCnt := 1 To Len(aCols)
		If !GdDeleted(nCnt)
			If DI2->(!MsSeek(xFilial("DI2")+cCodReg+GdFieldGet("DI2_ITEM",nCnt)))
				RecLock("DI2",.T.)
				DI2->DI2_FILIAL := xFilial("DI2")
				DI2->DI2_CODREG := cCodReg
				DI2->DI2_ITEM   := GdFieldGet("DI2_ITEM",nCnt)
			Else
				RecLock("DI2",.F.)
			EndIf
			For nI := 1 To nUsado
				If aHeader[nI,10] != 'V'
					DI2->(FieldPut(FieldPos(aHeader[nI,2]),GDFieldGet(aHeader[nI,2],nCnt)))
				EndIf
			Next
			MsUnlock()
		ElseIf DI2->(MsSeek(xFilial("DI2")+cCodReg+GdFieldGet("DI2_ITEM",nCnt)))
			RecLock("DI2",.F.)
			dbDelete()
			MsUnLock()
		EndIf
	Next nCnt
ElseIf nOpcx == 5
	For nCnt := 1 To Len(aCols)
		If DI2->(MsSeek(xFilial("DI2")+cCodReg+GdFieldGet("DI2_ITEM",nCnt)))
			RecLock("DI2",.F.)
			dbDelete()
			MsUnLock()
		EndIf
	Next nCnt					
EndIf	
Return
