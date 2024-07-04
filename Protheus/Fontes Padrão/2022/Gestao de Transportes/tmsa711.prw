#Include 'Protheus.ch'
#Include 'TmsA711.ch'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA711   � Autor � Rodolfo K. Rosseto    � Data �02.03.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Distancias por Cliente                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA711()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�          													           ���
���          �   																			  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �  SIGATMS                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMSA711()

Private cCadastro   := "" 
Private aRotina	  := MenuDef()
						
cCadastro := STR0001 //'Distancias por Cliente'

DbSelectArea('DVZ')
DVZ->(dbSetOrder(1))	

mBrowse(6,1,22,75,"DVZ",,,,,,,,)

Return NIL

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA711Mnt� Autor � Rodolfo K. Rosseto    � Data �02.03.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Distancias por Cliente                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA711Mnt(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�����������������������������������������������������������������������������*/
Function TMSA711Mnt(cTmsAlias,nTmsReg,nTmsOpcx)

Local nTamACols		  := 1
//-- EnchoiceBar
Local aTelOld		:= Iif( Type('aTela') == 'A', aClone( aTela ), {} )
Local aGetOld		:= Iif( Type('aGets') == 'A', aClone( aGets ), {} )
Local nOpca			:= 0
Local oTmsEnch

//-- Dialog
Local cCadOld		:= Iif( Type('cCadastro') == 'C', cCadastro, '' )
Local oTmsDlgEsp
//-- GetDados
Local aHeaOld		:= Iif( Type('aHeader') == 'A', aClone( aHeader ), {} )
Local aColOld		:= Iif( Type('aCols') == 'A', aClone( aCols ), {} )
Local aNoFields	:= {}
Local aYesFields	:= {}
//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}
//-- Checkbox
Local oAllMark

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]
//-- GetDados
Private aHeader		:= {}
Private aCols		   := {}
Private oTmsGetD
Private aTmsPosObj	:= {}
//-- Checkbox

DEFAULT cTmsAlias 	:= 'DVZ'
DEFAULT nTmsReg		:= 1
DEFAULT nTmsOpcx	   := 2

//-- Configura variaveis da Enchoice
RegToMemory(cTmsAlias,Inclui)
	
	//-- Dimensoes padroes
	aSize := MsAdvSize()
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)
	
	DEFINE MSDIALOG oTmsDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oTmsEnch		:= MsMGet():New( cTmsAlias, nTmsReg, nTmsOpcx,,,, , aTmsPosObj[1],, 3,,,,,,.T. )
	ACTIVATE MSDIALOG oTmsDlgEsp ON INIT EnchoiceBar(oTmsDlgEsp,{|| If(Obrigatorio(aGets,aTela), (nOpca := 1,oTmsDlgEsp:End()), (nOpca := 0)) },{||nOpca:=0,oTmsDlgEsp:End()},,)

If nTmsOpcx != 2 .And. nOpcA == 1	
	TMSA711Grv(cTmsAlias,nTmsReg,nTmsOpcx)	
EndIf

If	!Empty( aTelOld )
	aTela		:= aClone( aTelOld )
	aGets		:= aClone( aGetOld )
EndIf

If	!Empty( aHeaOld )
	aHeader	:= aClone( aHeaOld )
	aCols	:= aClone( aColOld )
EndIf

Return .F.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA711Grv� Autor � Rodolfo K. Rosseto   � Data �02.03.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar dados                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function TMSA711Grv( cAlias, nReg, nTmsOpcx )

If (nTmsOpcx == 3) .Or. (nTmsOpcx == 4) //Inclusao ou Alteracao
	Begin Transaction
		AxIncluiAuto(cAlias,,,nTmsOpcx,nReg)
	End Transaction
Endif	
If (nTmsOpcx == 5) //Exclusao
	Begin Transaction	
		RecLock("DVZ",.F.)
		dbDelete()
		MsUnLock()
	End Transaction		
EndIf

Return NIL

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA711Vld| Autor � Rodolfo K. Rosseto    � Data � 17/03/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes do Cadastro de Distancias por Cliente           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA711Vld()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA711                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSA711Vld()

Local cCampo     := ReadVar()
Local lRet       := .T.

If cCampo $ 'M->DVZ_TIPTRA'
	lRet:= TmsValField('M->DVZ_TIPTRA',.T.,'DVZ_DESTPT') .And. ;
	ExistChav('DVZ',M->DVZ_CODCLI+M->DVZ_LOJCLI+M->DVZ_CDRORI+M->DVZ_CDRDES+M->DVZ_TIPTRA)
Endif

Return lRet

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
     
Private aRotina	  := {	{ STR0002,'TmsXPesqui',0,1,0,.F.},;  //'Pesquisar'
						       	{ STR0003,'TMSA711Mnt',0,2,0,NIL},;  //'Visualizar'
						        	{ STR0004,'TMSA711Mnt',0,3,0,NIL},;  //'Incluir'
						        	{ STR0005,'TMSA711Mnt',0,4,0,NIL},;  //'Alterar'
						        	{ STR0006,'TMSA711Mnt',0,5,0,NIL}}   //'Excluir'


If ExistBlock("TM711MNU")
	ExecBlock("TM711MNU",.F.,.F.)
EndIf

Return(aRotina)

