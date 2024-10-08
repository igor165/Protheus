#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA267   � Autor �SUSTENTACAO         � Data �  24/03/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro da DMED                                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSA267()
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local aArea	:= GetArea()
Private cCadastro := "Cadastro da Dmed"
//���������������������������������������������������������������������Ŀ
//� Monta um aRotina proprio                                            �
//�����������������������������������������������������������������������
Private aRotina := MenuDef()
PRIVATE aCdCores  	:= { 	{ 'BR_VERDE'	, 'Registro Aguardando Envio' },; 
							{ 'BR_VERMELHO'	, 'Registro Enviado para Arquivo' }}
Private cString := "B5A"					  	

If ExistBlock("PL267MEN")
	aRotina := ExecBlock( "PL267MEN",.F.,.F.,{aRotina} )
EndIf

dbSelectArea(cString)
dbSetOrder(1)

B5A->(DbSeek(xFilial("B5A")))
B5A->(mBrowse( 6,1,22,75,cString,,,,,,,,,,, .T. ))
RestArea(aArea)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �27/12/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
Local 	aRotina := {	{"Pesquisar"	,"AxPesqui"		,0	,1	, 0, .F.} ,;
             		  	{"Visualizar"	,"AxVisual"		,0	,2	, 0, .F.} ,;
 					  	{"Incluir"		,"AxInclui"		,0	,3	, 0, .F.} ,;
  					  	{"Alterar"		,"AxAltera"		,0	,4 	, 0, .F.} ,;
  					  	{"Excluir"		,"AxDeleta"		,0	,5 	, 0, .F.} } 

Return(aRotina)

Function A267Nom()
	If !Empty(M->B5A_CODINT) .And. !Empty(M->B5A_CODEMP) .And. !Empty(M->B5A_MATRIC) .And. !Empty(M->B5A_TIPREG)
		BA1->(dbSetOrder(2))
		If BA1->(dbSeek(xFilial("BA1")+M->(B5A_CODINT+B5A_CODEMP+B5A_MATRIC+B5A_TIPREG), .F.))
			M->B5A_DIGITO := BA1->BA1_DIGITO
			M->B5A_NOMUSR := BA1->BA1_NOMUSR
			M->B5A_DATNAS := BA1->BA1_DATNAS
			If B5A->(FieldPos("B5A_MATVID")) > 0
				M->B5A_MATVID := BA1->BA1_MATVID
			EndIf
			M->B5A_RELDEP := M260GrPa(BA1->BA1_GRAUPA)
			If BA1->BA1_TIPUSU == GetNewPar("MV_PLCDTIT","T")
				M->B5A_CPFTIT := BA1->BA1_CPFUSR
				M->B5A_CPFDEP := Space(14)
			Else
				M->B5A_CPFDEP := BA1->BA1_CPFUSR
				M->B5A_CPFTIT := Space(14)
			EndIf
		Else
			MsgInfo("Usu�rio n�o encontrado para a matr�cula informada.")
			Return .F.
		EndIf
	EndIf
Return .T.