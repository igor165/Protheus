#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' //Necessita desse include quando usar MVC.
#include 'PLSA445.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � PLSA445  � Autor �Everton M. Fernandes� Data �  03/05/2013 ���
�������������������������������������������������������������������������͹��
��� Descricao� Fun��o voltada para Cadastro de Campos Adicionais TISS     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � PLSA445                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA445()
Local oBrowse

Private cChv444 := ""

If !FWAliasInDic("BTP", .F.) 
MsgAlert(STR0011) //"Para esta funcionalidade � necess�rio executar os procedimentos referente ao chamado: THQGIW"
Return()
EndIf

// Instanciamento da Classe de Browse
oBrowse := FWMBrowse():New()

// Defini��o da tabela do Browse
oBrowse:SetAlias('BTP')

// Defini��o da legenda
//oBrowse:AddLegend( "C5_TPFRETE<>'C'", "YELLOW", "Frete Diferente de CIF" )
//oBrowse:AddLegend( "C5_TPFRETE=='C'", "BLUE" , "Frete CIF" )

// Defini��o de filtro
//oBrowse:SetFilterDefault( "C5_NUM<> ' ' )

// Titulo da Browse
oBrowse:SetDescription(STR0001)

// Opcionalmente pode ser desligado a exibi��o dos detalhes
//oBrowse:DisableDetails()

// Ativa��o da Classe
oBrowse:Activate()

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � MenuDef  � Autor �Everton M. Fernandes� Data �  03/05/2013 ���
�������������������������������������������������������������������������͹��
��� Descricao� Define o menu da aplica��o                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � PLSA445                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*//*
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina Title 'Visualizar'	Action 'VIEWDEF.PLSA445' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir' 		Action 'VIEWDEF.PLSA445' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar' 		Action 'VIEWDEF.PLSA445' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir' 		Action 'VIEWDEF.PLSA445' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Imprimir' 	Action 'VIEWDEF.PLSA445' OPERATION 8 ACCESS 0
//ADD OPTION aRotina Title 'Copiar' 		Action 'VIEWDEF.PLSA445' OPERATION 9 ACCESS 0
Return aRotina
*/
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � ModelDef � Autor �Everton M. Fernandes� Data �  03/05/2013 ���
�������������������������������������������������������������������������͹��
��� Descricao� Define o modelo de dados da aplica��o                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � PLSA445                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()
// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruBTP := FWFormStruct( 1, 'BTP' )
Local oStruBTD := FWFormStruct( 1, 'BTD' )

Local oModel // Modelo de dados constru�do

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PLSA445' )

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields( 'BTPMASTER', /*cOwner*/, oStruBTP )

// Adiciona ao modelo uma componente de grid
oModel:AddGrid( 'BTDDETAIL', 'BTPMASTER', oStruBTD )

// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'BTDDETAIL', { { 'BTD_FILIAL', 'xFilial( "BTD" )'},;
       									{ 'BTD_CODTAB', 'BTP_CODTAB' } }, BTD->( IndexKey( 1 ) ) )

// Adiciona a descri��o do Modelo de Dados
oModel:SetDescription( STR0002 )

// Adiciona a descri��o dos Componentes do Modelo de Dados
oModel:GetModel( 'BTPMASTER' ):SetDescription( STR0003 )
oModel:GetModel( 'BTDDETAIL' ):SetDescription( STR0004 )

//Permite gravar apenas a tabela BTP
oModel:GetModel('BTDDETAIL'):SetOptional(.T.)

//Permite gravar apenas a tabela BTP
oModel:GetModel('BTPMASTER'):SetOnlyView(.T.)

// Retorna o Modelo de dados
Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � ViewDef  � Autor �Everton M. Fernandes� Data �  03/05/2013 ���
�������������������������������������������������������������������������͹��
��� Descricao� Define o modelo de dados da aplica��o                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � PLSA445                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel( 'PLSA445' )

// Cria as estruturas a serem usadas na View
Local oStruBTP := FWFormStruct( 2, 'BTP' )
Local oStruBTD := FWFormStruct( 2, 'BTD' )

// Interface de visualiza��o constru�da
Local oView

//Retira o campo c�digo da tela
oStruBTD:RemoveField('BTD_CODTAB')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual Modelo de dados ser� utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)
oView:AddField( 'VIEW_BTP', oStruBTP, 'BTPMASTER' )

//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'VIEW_BTD', oStruBTD, 'BTDDETAIL' )

//Nao deixa duplicar o campo BTD_CAMPO
oModel:GetModel( 'BTDDETAIL' ):SetUniqueLine( { 'BTD_CAMPO' } )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 20 )
oView:CreateHorizontalBox( 'INFERIOR', 80 )

// Relaciona o identificador (ID) da View com o "box" para exibi��o
oView:SetOwnerView( 'VIEW_BTP', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_BTD', 'INFERIOR' )

// Retorna o objeto de View criado
Return oView

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � PL445Fil � Autor �Everton M. Fernandes� Data �  03/05/2013 ���
�������������������������������������������������������������������������͹��
��� Descricao� Filtra os campos adicionais			                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � PLSA445                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PL445Fil(cAlias)

LOCAL oDlgPesCmp	:= Nil

LOCAL oBrowUsr		:= Nil

LOCAL bOK			:= { ||nLin := oBrowUsr:nAt, nOpca := 1,oDlgPesCmp:End() }
LOCAL bCanc		:= { || nOpca := 3,oDlgPesCmp:End() }

LOCAL nOpca		:= 0
LOCAL nLin			:= 1

LOCAL aDados		:= {}
LOCAL aButtons		:= {}

//variaveis lgpd
local aBls         := {}
local aCampos      := {}
local objCENFUNLGP := CENFUNLGP():New()

DEFAULT cAlias		:= "BTQ"




DEFINE MSDIALOG oDlgPesCmp TITLE STR0004 FROM 008.2,000 TO 035,050 OF GetWndDefault() //"Pesquisa de Beneficiarios"

//Retorna os campos adicionais da tabela BTD
aDados := PL445CMP(cAlias)	

//��������������������������������������������������������������������������Ŀ
//� Monta Browse...                                                          �
//����������������������������������������������������������������������������
oBrowUsr := TcBrowse():New( 035, 008, 185, 142,,,, oDlgPesCmp,,,,,,,,,,,, .T.,, .T.,, .F., )

oBrowUsr:AddColumn(TcColumn():New(STR0005,nil,; //"Campo"
         nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowUsr:ACOLUMNS[1]:BDATA     := { || aDados[oBrowUsr:nAt,1] }

oBrowUsr:AddColumn(TcColumn():New(STR0006,nil,; //"Descri��o"
         nil,nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowUsr:ACOLUMNS[2]:BDATA     := { || aDados[oBrowUsr:nAt,2] }

oBrowUsr:SetArray(aDados)
oBrowUsr:BLDBLCLICK := bOK

if objCENFUNLGP:isLGPDAt()
   aCampos := {"X3_CAMPO", "X3_DESCRIC"}
   aBls := objCENFUNLGP:getTcBrw(aCampos)

   oBrowUsr:aObfuscatedCols := aBls
endif

//��������������������������������������������������������������������������Ŀ
//� Ativa o Dialogo...                                                       �
//����������������������������������������������������������������������������
ACTIVATE MSDIALOG oDlgPesCmp ON INIT Eval({ || EnChoiceBar(oDlgPesCmp,bOK,bCanc,.F.,aButtons) })

If nOpca == 1
 	SX3->(DbSetOrder(2))
	SX3->(DbSeek(aDados[nLin,1]))
Endif

cChv444 := SX3->X3_CAMPO

//��������������������������������������������������������������������������Ŀ
//� Retorno da Funcao...                                                     �
//����������������������������������������������������������������������������
Return(nOpca==1)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � PL445CMP � Autor �Everton M. Fernandes� Data �  03/05/2013 ���
�������������������������������������������������������������������������͹��
��� Descricao� Retorna codigo e descri��o dos campos da tabela solicitada ���
���          � Para a tabela BTQ existe um tratamento especial, pois      ���
���          � representa campos adicionais e alguns n�o pode ser exibidos���
�������������������������������������������������������������������������͹��
��� Uso      � PLSA445                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PL445CMP(cAlias)
LOCAL aDados 		:= {}
DEFAULT cAlias 	:= 'BTQ'

DbSelectArea("SX3")
SX3->(DbSetOrder(1))
If SX3->(DbSeek(cAlias))
	While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == cAlias//'BTQ'
		If cAlias=='BTQ'
			If !AllTrim(SX3->X3_CAMPO) $ "BTQ_FILIAL,BTQ_CODTAB,BTQ_CDTERM,BTQ_DESTER,BTQ_VIGDE ,BTQ_VIGATE,BTQ_DATFIM"
				aAdd(aDados,{SX3->X3_CAMPO,SX3->X3_DESCRIC} )
			EndIf
		Else
			aAdd(aDados,{SX3->X3_CAMPO,SX3->X3_DESCRIC} )
		EndIf
		SX3->(DbSkip())
	EndDo
EndIf

Return(aDados)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � PL445GTCMP�Autor �Everton M. Fernandes� Data �  03/05/2013 ���
�������������������������������������������������������������������������͹��
��� Descricao� Retorna os campos pardr�es da tabela BTQ                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � PLSA445                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PL445GTCMP()
Local lRet	:= .T.
Local aDados := PL445CMP("BTQ")

lRet := aScan(aDados,{ |x| x[1] == M->BTD_CAMPO}) > 0

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � PL445Fil � Autor �Everton M. Fernandes� Data �  03/05/2013 ���
�������������������������������������������������������������������������͹��
��� Descricao� Filtra os campos adicionais			                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � PLSA445                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PL445BTQ(cAlias)

LOCAL cChave     := IIF (!Empty(M->BTU_CDTERM), M->BTU_CDTERM, Space(100))
LOCAL oDlgPesTis
LOCAL oTipoPes
LOCAL nOpca      := 0
LOCAL aBrowUsr   := {}
LOCAL aVetPad    := { {"",""} }
LOCAL oBrowUsr
LOCAL bRefresh   := { || If(!Empty(cChave),PLSAPTISPq(AllTrim(cChave),Subs(cTipoPes,1,1),BTP->BTP_CODTAB,lChkChk,aBrowUsr,aVetPad,oBrowUsr),.T.), If( Empty(aBrowUsr[1,2]) .And. !Empty(cChave),.F.,.T. )  }
LOCAL cValid     := "{|| Eval(bRefresh) }"
LOCAL bOK        := { || IIF(FunName() == "TMKA271", (nLin := oBrowUsr:nAt, nOpca := 1,oDlgPesTis:End()), IIF(!Empty(cChave),(nLin := oBrowUsr:nAt, nOpca := 1,oDlgPesTis:End()),Help("",1,"PLSMCON"))) }
LOCAL bCanc      := { || nOpca := 3,oDlgPesTis:End() }
LOCAL nReg
LOCAL oGetChave
LOCAL aTipoPes   := {}
LOCAL nOrdem     := 1
LOCAL cTipoPes   := ""
LOCAL oChkChk
LOCAL lChkChk    := .F.
LOCAL nLin       := 1
LOCAL aButtons 	 := {}
LOCAL cSQL
LOCAL cRet       := ''
LOCAL cTerminolo := ''

If !FWAliasInDic("BTQ", .F.) 
MsgAlert(STR0011) //"Para esta funcionalidade � necess�rio executar os procedimentos referente ao chamado: THQGIW"
Return()
EndIf

cChv444 := BTU->BTU_CDTERM

aBrowUsr := aClone(aVetPad)
//��������������������������������������������������������������������������Ŀ
//� Itens do combo do tipo de pesquisa...                                    �
//����������������������������������������������������������������������������
aTipoPes   := {STR0007,STR0008} //C�digo Terminologia || Decri��o Item Terminologia

DbSelectArea("BTQ")
//��������������������������������������������������������������������������Ŀ
//� Define dialogo...                                                        �
//����������������������������������������������������������������������������
DEFINE MSDIALOG oDlgPesTis TITLE cTerminolo FROM 009,000 TO 280,780 OF GetWndDefault() PIXEL
//��������������������������������������������������������������������������Ŀ
//� Monta objeto que recebera o a chave de pesquisa  ...                     �
//����������������������������������������������������������������������������
oGetChave := TGet():New(020,103,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesTis,210,008 ,"@!S30",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
//��������������������������������������������������������������������������Ŀ
//� Monta Browse...                                                          �
//����������������������������������������������������������������������������
oBrowUsr := TcBrowse():New( 043, 008, 378, 075,,,, oDlgPesTis,,,,,,,,,,,, .F.,, .T.,, .F., )

//C�digo
oBrowUsr:AddColumn(TcColumn():New(STR0009,nil,;
         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowUsr:ACOLUMNS[1]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,1] }
//Descri��o
oBrowUsr:AddColumn(TcColumn():New(STR0010,nil,;
         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowUsr:ACOLUMNS[2]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,2] }

@ 020,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 090,010 OF oDlgPesTis PIXEL COLOR CLR_HBLUE

oBrowUsr:SetArray(aBrowUsr)
oBrowUsr:BLDBLCLICK := bOK
//��������������������������������������������������������������������������Ŀ
//� Ativa o Dialogo...                                                       �
//����������������������������������������������������������������������������
ACTIVATE MSDIALOG oDlgPesTis ON INIT Eval({ || EnChoiceBar(oDlgPesTis,bOK,bCanc,.F.,aButtons), EVAL(bRefresh), oGetChave:SetFocus() })

//se o usu�rio selecionou algum registro
If nOpca == 1
	//verifica se o registro n�o est� em branco
   	If !Empty(aBrowUsr[nLin,1])
   		//atribui o c�digo do item da terminologia a vari�vel de retorno
      	cChv444 := aBrowUsr[nLin,1]
   Endif
Endif

//��������������������������������������������������������������������������Ŀ
//� Retorno da Funcao...                                                     �
//����������������������������������������������������������������������������
Return(nOpca==1)