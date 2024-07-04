#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'PLS790OP.ch'

/*/                                                      
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLS790OP� Autor � Totvs                  � Data � 16.02.11  ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Abre Browse da Guia OPME									    ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
/*/
Function PLS790OP()
Local oBrowse	  := Nil 
Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("B2I")
oBrowse:SetDescription("GUIA OPME")
oBrowse:SetUseCursor(.F.)
oBrowse:Activate()

Return

/*/                                                      
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �MODELDEF� Autor � Totvs                  � Data � 16.02.11  ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Faz a chamada do menu de analise da guia					    ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
/*/
Static Function ModelDef()
Local oModel
Local oStr1:= FWFormStruct(1,'B2I')

oModel := MPFormModel():New('MVCY', , , { |oModel| MENGRV( oModel ) } )
oModel:SetDescription('Modelo MVC')
oModel:addFields('FORMULARIO1',,oStr1)
oModel:getModel('FORMULARIO1'):SetDescription('Inclus�o de OPME')
//Set Primary Key devido a obrigatoriedade na V12
oModel:SetPrimaryKey( { "B2I_FILIAL", "B2I_NUMGUI", "B2I_CODPAD", "B2I_CODPRO" } )

Return oModel

/*/                                                      
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �VIEWDEF� Autor � Totvs                  � Data � 16.02.11  ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Faz a chamada do menu de analise da guia					    ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2, 'B2I')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('FORM1' , oStr1,'FORMULARIO1' ) 

//Definindo t�tulos dos campos
oStr1:SetProperty('B2I_VLNEGO',MVC_VIEW_TITULO,STR0001) //Valor Negociado com Fornecedor
oStr1:SetProperty('B2I_DTAGUI',MVC_VIEW_TITULO,STR0002) //Data de Digita��o da Guia
oStr1:SetProperty('B2I_NUMGUI',MVC_VIEW_TITULO,STR0003) //N�mero da Guia
oStr1:SetProperty('B2I_CDANVI',MVC_VIEW_TITULO,STR0004) //Registro ANVISA
oStr1:SetProperty('B2I_VLORCA',MVC_VIEW_TITULO,STR0005) //Valor Or�ado

//Definindo campos como n�o editav�is
oStr1:SetProperty('B2I_NUMGUI',MVC_VIEW_CANCHANGE,.F.)
oStr1:SetProperty('B2I_CODPRO',MVC_VIEW_CANCHANGE,.F.)
oStr1:SetProperty('B2I_CODRDA',MVC_VIEW_CANCHANGE,.F.)
oStr1:SetProperty('B2I_DTAGUI',MVC_VIEW_CANCHANGE,.F.)
oStr1:RemoveField('B2I_NOMUSR',MVC_VIEW_CANCHANGE,.F.)
oStr1:RemoveField('B2I_DTACAD',MVC_VIEW_CANCHANGE,.F.)

//Retirando campos da View para n�o serem exibidos
oStr1:RemoveField('B2I_CODPAD')
oStr1:RemoveField('B2I_CODOPE')
oStr1:RemoveField('B2I_CODMUN')

oView:CreateHorizontalBox( 'BOXFORM1', 100)
oView:SetOwnerView('FORM1','BOXFORM1')

Return oView

/*/                                                      
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �MENUDEF� Autor � Totvs                  � Data � 16.02.11   ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Faz a chamada do menu de analise da guia					    ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
/*/
Static FUnction MenuDef()
Return FWMVCMenu("PLS790OP")

/*/                                                      
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �MENGRV� Autor � Renan Martins          � Data � 16.02.11    ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Faz o commit do formul�rio.   se da guia					    ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
/*/
Function MENGRV(oModel)
FWFormCommit(oModel)
Return