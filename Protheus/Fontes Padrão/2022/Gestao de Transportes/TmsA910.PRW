#include "Protheus.ch"
#include "TMSA910.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA910  � Autor � Richard Anderson      � Data � 01.07.08   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Aeroportos x Regi�o                                          ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMS                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function TMSA910()

Private cCadastro	:= STR0001 //"Aeroportos x Regi�o"
Private aRotina		:= MenuDef()

dbSelectArea("DD7")
dbSetOrder(1)
dbGoTop()

mBrowse(06,01,22,75,"DD7")

Return Nil

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMA910Mnt � Autor � Richard Anderson     � Data �01.07.2008 ���
��������������������������������������������������������������������������Ĵ��
���          � Interface do Cadastro de Aeroportos x Regi�o                ���
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
Function TMA910Mnt(cAlias, nReg, nOpcx)

Local nUsado    := 0
Local nOpcA     := 0
Local aAreaDD7  := DD7->(GetArea())

Local aGet      := {}
Local aPosObj   := {} 
Local aObjects  := {}
Local aRecno    := {}
Local aSize     := MsAdvSize( .F. )             
Local nCntFor   := 0
Local aNoFields := {}
Local oDlg
Local aFldDD7	:={}
Local nI		:= 0

Private aHeader := {}
Private aCols   := {} 
Private cCodReg := Iif(Inclui,CriaVar("DD7_CODREG"),DD7->DD7_CODREG)
Private cDesReg := CriaVar("DD7_DESREG")
Private oDesReg := {}
Private oGetD   := {}

Aadd(aNoFields,"DD7_CODREG")
Aadd(aNoFields,"DD7_DESREG")

aadd(aGet,{FWX3Titulo("DD7_CODREG"),GetSX3Cache("DD7_CODREG", "X3_PICTURE"),GetSX3Cache("DD7_CODREG", "X3_F3")})
aadd(aGet,{FWX3Titulo("DD7_DESREG"),GetSX3Cache("DD7_DESREG", "X3_PICTURE"),GetSX3Cache("DD7_DESREG", "X3_F3")})

//��������������������������������������������������������������Ŀ
//� Monta o Array aHeader.                                       �
//����������������������������������������������������������������									
aFldDD7 := ApBuildHeader("DD7", aNoFields)
For nI := 1 To Len(aFldDD7)
	nUsado += 1
	Aadd(aHeader, aFldDD7[nI])
Next
aSize(aFldDD7, 0)
aFldDD7 := Nil


//��������������������������������������������������������������Ŀ
//� Monta o Array aCols.                                         �
//����������������������������������������������������������������
If !Inclui
	DD7->(dbSetOrder(1))
	DD7->(dbSeek(xFilial("DD7")+cCodReg))
	While DD7->(!Eof()) .And. DD7->(DD7_FILIAL+DD7_CODREG) == xFilial("DD7")+cCodReg
		Aadd(aCols,Array(nUsado+1))
		For nCntFor := 1 To nUsado
			If ( aHeader[nCntFor][10] != "V" )
				aCols[Len(aCols)][nCntFor] := DD7->(FieldGet(FieldPos(aHeader[nCntFor][2])))
			Else
				aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
			EndIf
		Next
		aCols[Len(aCols)][nUsado+1] := .F.
		DD7->(dbSkip())
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

If	Empty(GDFieldGet('DD7_ITEM',1))
	GDFieldPut('DD7_ITEM',StrZero(1,Len(DD7->DD7_ITEM)),1)
EndIf
		
AAdd( aObjects, { 100, 50, .T., .F. } )
AAdd( aObjects, { 100, 50, .T., .T. } )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 } 
aPosObj := MsObjSize( aInfo, aObjects ) 
	
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 to aSize[6],aSize[5] Of oMainWnd PIXEL

	@ 38,005 SAY   aGet[1][1] SIZE 50,7 OF oDlg PIXEL	
	@ 38,040 MSGET cCodReg    PICTURE aGet[1][2] F3 "DUY"  VALID TMA910Vld() WHEN Inclui SIZE 0,7 OF oDlg PIXEL	
	@ 38,085 MSGET oDesReg    VAR cDesReg PICTURE "@!"     WHEN .F. SIZE 120,7 OF oDlg PIXEL	
		
	oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"TMA910LOk()","TMA910TOk()","+DD7_ITEM",.T.)
			
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, If(oGetd:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()})			

If nOpcA == 1 .And. nOpcx <> 2
	Begin Transaction
		TMA910Grv(nOpcx)
	End Transaction
EndIf	

RestArea(aAreaDD7)
	
Return NIL

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMA910LOk � Autor � Richard Anderson     � Data �01.07.2008 ���
��������������������������������������������������������������������������Ĵ��
���          � Validacao de digitacao de linha                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMA910LOk()
Local lRet := .T.
//-- Nao avalia linhas deletadas.
If	!GDDeleted( n )
   If lRet := MaCheckCols(aHeader,aCols,n)
	   //-- Analisa se ha itens duplicados na GetDados.
	   lRet := GDCheckKey( { 'DD7_CODAER' }, 4 )
	EndIf   
EndIf
Return(lRet)

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMA910TOk � Autor � Richard Anderson     � Data �01.07.2008 ���
��������������������������������������������������������������������������Ĵ��
���          � Validacao de confirmacao para gravacao                      ���
��������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMA910TOk()

Local lRet   := .T.

//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet
	lRet := oGetD:ChkObrigat( n )
EndIf
//-- Analisa o linha ok.
If lRet
	lRet := TMA910LOk()
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
���Fun��o    � TMA910Vld � Autor � Richard Anderson     � Data �01.07.2008 ���
��������������������������������������������������������������������������Ĵ��
���          � Validacao de digitacao de campos                            ���
��������������������������������������������������������������������������Ĵ��
���Uso       � EAL                                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMA910Vld(cCampo)

Local   lRet    := .T.
Default cCampo  := AllTrim(Upper(ReadVar()))

If "CCODREG" $ cCampo
	lRet := ExistCpo("DUY",cCodReg,1) .And. ExistChav('DD7',cCodReg,1) 
	If lRet
		cDesReg:= Posicione("DUY",1,xFilial("DUY")+cCodReg,"DUY_DESCRI")
		oDesReg:Refresh()
	EndIf
ElseIf "DD7_CODAER" $ cCampo
	lRet := ExistCpo('SX5','M9'+M->DD7_CODAER,1)
	If lRet
		GDFieldPut('DD7_NOMAER',Tabela('M9',M->DD7_CODAER,.F.))
	EndIf
EndIf
			
Return(lRet)

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMA910Grv � Autor � Richard Anderson     � Data �01.07.2008 ���
��������������������������������������������������������������������������Ĵ��
���          � Gravacao                                                    ���
��������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMA910Grv(nOpcx)

Local nI     := 0
Local nCnt   := 0
Local nUsado := Len(aHeader)

DD7->(dbSetOrder(1))

If nOpcx == 3 .Or. nOpcx == 4
	For nCnt := 1 To Len(aCols)
		If !GdDeleted(nCnt)
			If DD7->(!MsSeek(xFilial("DD7")+cCodReg+GdFieldGet("DD7_ITEM",nCnt)))
				RecLock("DD7",.T.)
				DD7->DD7_FILIAL := xFilial("DD7")
				DD7->DD7_CODREG := cCodReg
				DD7->DD7_ITEM   := GdFieldGet("DD7_ITEM",nCnt)
			Else
				RecLock("DD7",.F.)
			EndIf
			For nI := 1 To nUsado
				If aHeader[nI,10] != 'V'
					DD7->(FieldPut(FieldPos(aHeader[nI,2]),GDFieldGet(aHeader[nI,2],nCnt)))
				EndIf
			Next
			MsUnlock()
		ElseIf DD7->(MsSeek(xFilial("DD7")+cCodReg+GdFieldGet("DD7_ITEM",nCnt)))
			RecLock("DD7",.F.)
			dbDelete()
			MsUnLock()
		EndIf
	Next nCnt
ElseIf nOpcx == 5
	For nCnt := 1 To Len(aCols)
		If DD7->(MsSeek(xFilial("DD7")+cCodReg+GdFieldGet("DD7_ITEM",nCnt)))
			RecLock("DD7",.F.)
			dbDelete()
			MsUnLock()
		EndIf
	Next nCnt					
EndIf	
Return
/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Jose Luiz Pinheiro Jr � Data �27/05/2010���
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

Private aRotina	:= {{ STR0002  , "AxPesqui" , 0, 1 },; //"Pesquisar"
				          { STR0003  , "TMA910Mnt" , 0, 2 },; //"Visualizar"
 				          { STR0004  , "TMA910Mnt" , 0, 3 },; //"Incluir"
				          { STR0005  , "TMA910Mnt" , 0, 4 },; //"Alterar"
				          { STR0006  , "TMA910Mnt" , 0, 5 }}  //"Excluir"

If ExistBlock("TM910MNU")
	ExecBlock("TM910MNU",.F.,.F.)
EndIf       

Return(aRotina)
