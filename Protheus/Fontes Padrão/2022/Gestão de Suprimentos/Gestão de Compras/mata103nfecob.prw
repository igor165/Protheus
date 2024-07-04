#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "mata103a.ch"

/*/
���������������������������������������������������������������������������Ŀ��
���Program   �NfeDocCob �   Autor � Leandro Nishihata     � Data �14/08/2019���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de selecao dos documentos de cobertura(Industrializador���
���������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Processamento Ok.                                    	���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Alias da Tabela                                      	���
���          �ExpN2: Numero do Registro da Tabela                         	���
���          �ExpN3: Opcao do aRotina                                     	���
����������������������������������������������������������������������������ٱ�
/*/

Function NfeDocCob(cAlias,nReg,nOpc)

PRIVATE aRotina   	:= MenuDef()

//������������������������������������������������������������������������Ŀ
//�Realiza a Filtragem                                                     �
//��������������������������������������������������������������������������
cFilSDH := "DH_FILIAL=='"+xFilial("SDH")+"' .And. "
cFilSDH += "DH_OPER<>'2' .And. "
cFilSDH += "DH_TPMOV=='1' .And. "
cFilSDH += "DH_SALDO <> 0 "

SDH->(MsSeek(xFilial("SDH")))

MarkBrow("SDH","DH_OK","",,,GetMark(,"SDH","DH_OK"),,,,,"ValDocCob()",{|oObj|  oObj:= GetMarkBrow(), oObj:oBrowse:SetMainProc("MATA103NFECOB")},,,,,,cFilSDH)

dbSelectArea("SDH")
RetIndex("SDH")

Return(.T.)

/*/
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Leandro Nishihata     � Data �14/08/2019���
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
/*/
Static Function MenuDef()
Local cFilSDH     	:= ""
Local oObj := nil
Local aRotina   	:= {{STR0001,"PesqBrw", 0 , 1},; //"Pesquisar"
						{STR0002,"NfeFilCob",0,1},; //"Filtro"
						{STR0003,"NfeNfeCob",0,3}} //"Documento"
PRIVATE cCadastro 	:= STR0004 //"Documentos de Cobertura"
PRIVATE cNFISCAL2	:= SF1->F1_DOC   

Return(aRotina)	
