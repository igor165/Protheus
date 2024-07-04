#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'FWMBROWSE.CH'


/*/                                                      
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLS790HO� Autor � Renan Martins          � Data � 02.04.15  ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Abre Browse da Guia OPME									    ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
/*/
Function PLS790HO()
Local oBrowse	  := Nil 
Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("")
oBrowse:SetDescription("GUIA OPME")
oBrowse:SetUseCursor(.F.)
oBrowse:Activate()

Return


/*/                                                      
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �MENUDEF� Autor � Renan Martins           � Data � 02.04.15  ����
�������������������������������������������������������������������������Ĵ���
���Descricao � MENU Hist�rico de OPME									       ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
/*/
Static FUnction MenuDef()
Return FWMVCMenu("apn_tes") 


/*/                                                      
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �MODELDEF� Autor � Renan Martins          � Data � 02.04.15  ����
�������������������������������������������������������������������������Ĵ���
���Descricao � ModelDef da tela Hist�rico de OPME						    ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
/*/

Static Function ModelDef()
Local oModel 
Local oStr1:= FWFormStruct(1,'B2I')
Local oStr2:= FWFormStruct(1,'B2I')

oModel := MPFormModel():New('Model')
oModel:SetDescription('Modelo de dados')
oStr1:RemoveField( 'B2I_CODOPE' )
oStr1:RemoveField( 'B2I_NOMUSR' )
oStr1:AddField('Maior Valor','Campo de Maior Valor' , 'MA_VALOR', 'N', 9, 2, , , {}, .F., , .F., .F., .T., , )
oStr1:AddField('Media Valor','Campo de M�dia de Valor' , 'MD_VALOR', 'N', 9, 2, , , {}, .F., , .F., .F., .T., , )
oStr1:AddField('Menor Valor','Campo de Menor Valor' , 'MN_VALOR', 'N', 9, 2, , , {}, .F., , .F., .F., .T., , )
oStr1:AddField('Regiao','Apenas L�gico' , 'MA_REGIAO', 'L', 1, 0, , , {}, .F., , .F., .F., .F., , )
oStr1:AddField('Guia de Maior Valor','Guia de Maior Valor' , 'GUI_MA_VALOR', 'C', 18, 0, , , {}, .F., , .F., .F., .T., , )
oStr1:AddField('Guia de Menor Valor','Guia de Menor Valor' , 'GUI_MN_VALOR', 'C', 18, 0, , , {}, .F., , .F., .F., .T., , )
oModel:addFields('FRM',,oStr1)
oModel:getModel('FRM'):SetDescription('Form')
oModel:SetPrimaryKey( { "B2I_FILIAL", "B2I_NUMGUI", "B2I_CODPAD", "B2I_CODPRO" } )

Return oModel


/*/                                                      
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �VIEWDEF� Autor � Totvs                  � Data � 16.02.11  ����
�������������������������������������������������������������������������Ĵ���
���Descricao � MENU Hist�rico de OPME									    ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef() 
Local oStr1:= FWFormStruct(2, 'B2I') 
Local oStr2:= FWFormStruct(2, 'B2I')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('FORM1' , oStr1,'FRM' )
oView:AddOtherObject('BTN',{|oPanel| PLSVGUIS(oPanel, oModel)})

oStr1:AddField( 'MA_VALOR','17','Maior Valor','Maior Valor',, 'Get' ,"@E 999,999.99",,,.F.,,,,,,.T.,, )
oStr1:AddField( 'MA_REGIAO','23','Regiao','Regiao',, 'Check' ,,,,,,,,,,,, )
oStr1:AddField( 'GUI_MN_VALOR','22','Guia de Menor Valor','Guia de Menor Valor',, 'Get' ,"@!",,,.F.,,,,,,.T.,, )
oStr1:AddField( 'GUI_MA_VALOR','21','Guia de Maior Valor','Guia de Maior Valor',, 'Get' ,"@!",,,.F.,,,,,'PLSSLOPME(1) ',.T.,, )
oStr1:AddField( 'MN_VALOR','18','Menor Valor','Menor Valor',, 'Get' ,"@E 999,999.99",,,.F.,,,,,,.T.,, )
oStr1:AddField( 'MD_VALOR','20','Media Valor','Media Valor',, 'Get' ,"@E 999,999.99",,,.F.,,,,,,.T.,, )

oStr1:SetProperty( 'B2I_CODPRO',MVC_VIEW_TITULO,'C�digo do Procedimento')
oStr1:SetProperty( 'B2I_DESCPR',MVC_VIEW_TITULO,'Descri��o')
oStr1:SetProperty( 'B2I_CDANVI',MVC_VIEW_TITULO,'C�digo Anvisa')
oStr1:SetProperty( 'B2I_NUMGUI',MVC_VIEW_TITULO,'Guia Selecionada no momento')
oStr1:SetProperty( 'B2I_CODPRO',MVC_VIEW_CANCHANGE,.F.)
oStr1:SetProperty( 'B2I_CDANVI',MVC_VIEW_CANCHANGE,.F.)
oStr1:SetProperty( 'B2I_CODRDA',MVC_VIEW_CANCHANGE,.F.)
oStr1:SetProperty( 'B2I_NUMGUI',MVC_VIEW_CANCHANGE,.F.)
oStr1:SetProperty( 'B2I_CODPAD',MVC_VIEW_CANCHANGE,.F.)
oStr1:SetProperty( 'B2I_CODRDA',MVC_VIEW_CANCHANGE,.F.)

oStr1:RemoveField( 'B2I_CODOPE' )
oStr1:RemoveField( 'B2I_NOMUSR' )
oStr1:RemoveField( 'B2I_DESCPO' )
oStr1:RemoveField( 'B2I_VLDESC' )
oStr1:RemoveField( 'B2I_VLNEGO' )
oStr1:RemoveField( 'B2I_VLORCA' )
oStr1:RemoveField( 'B2I_NOMFOR' )
oStr1:RemoveField( 'B2I_DTAGUI' )
oStr1:RemoveField( 'B2I_DTACAD' )
oStr1:RemoveField( 'B2I_NOMRDA' )
oStr1:RemoveField( 'B2I_CODMUN' )

oView:SetFieldAction( 'MA_REGIAO', { |oModel| PLSRETREG(oModel, oView)} )

oView:CreateHorizontalBox( 'BOXFORM1', 80)
oView:SetOwnerView('FORM1','BOXFORM1')
oView:CreateHorizontalBox( 'BOXBTN', 20)
oView:SetOwnerView('BTN','BOXBTN')

Return oView
