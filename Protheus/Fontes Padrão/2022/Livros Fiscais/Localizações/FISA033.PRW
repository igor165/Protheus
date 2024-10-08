#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA033.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FISA033  �Autor  � Ivan Haponczuk     � Data � 18/08/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     �  Cadastro da tabela de aliquotas por periodo.              ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA033()

	Local   oBrowse
	Private EAI_MESSAGE_MVC := ""
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "CE8" )
	oBrowse:SetDescription(STR0001)//"Validade das aliquotas"
	oBrowse:Activate()
	
Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � MenuDef       �Autor  � Ivan Haponczuk     � Data � 18/08/2011  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao do MenuDef para o MVC                                 ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   �Array                                                            ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 //'Pesquisar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA033' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA033' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA033' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA033' OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA033' OPERATION 8 ACCESS 0 //'Imprimir'
	
Return aRotina

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � ModelDef      �Autor  � Ivan Haponczuk     � Data � 18/08/2011  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao do ModelDef para o MVC                         	   ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                     	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ModelDef()

	Local oModel
	Local oStructCAB := FWFormStruct( 1 , "CE8" )
	Local oStructGRD := FWFormStruct( 1 , "CE8" )
    
	//Remove campos do cabecalho
	oStructCAB:RemoveField( "CE8_DATINI" )
	oStructCAB:RemoveField( "CE8_DATFIN" )
	oStructCAB:RemoveField( "CE8_ALIQ" )
	oStructCAB:RemoveField( "CE8_ISEN" )
	
	//Remove campos do grid	
	oStructGRD:RemoveField( "CE8_CODIMP" )
	oStructGRD:RemoveField( "CE8_DESC" )
	oStructGRD:RemoveField( "CE8_TIPO" )
	oStructGRD:RemoveField( "CE8_EST" )
    
	oModel:= MPFormModel():New("FISA033MOD")
	oModel:AddFields( "CE8_CAB" ,, oStructCAB )
	oModel:AddGrid( "CE8_GRD" , "CE8_CAB" , oStructGRD ,, {|oGrid| FLinOk(oGrid) } )

	oModel:SetRelation("CE8_GRD",{{"CE8_FILIAL",'xFilial("CE8")'},{"CE8_DESC","CE8_DESC"},{"CE8_CODIMP","CE8_CODIMP"},{"CE8_EST","CE8_EST"},{"CE8_TIPO","CE8_TIPO"}},CE8->(IndexKey()))
	oModel:SetPrimaryKey({"CE8_FILIAL"},{"CE8_CODIMP"},{"CE8_EST"},{"CE8_TIPO"})

	oModel:SetDescription( "Al�quotas por per�odo" )
	
Return oModel

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � ViewDef       �Autor  � Ivan Haponczuk     � Data � 18/08/2011  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao da Visualizacao para o MVC                    	       ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                     	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel( "FISA033" )
	Local oStructCAB := FWFormStruct( 2 , "CE8" )
	Local oStructGRD := FWFormStruct( 2 , "CE8" )
	
	//Remove campos do cabecalho
	oStructCAB:RemoveField( "CE8_DATINI" )
	oStructCAB:RemoveField( "CE8_DATFIN" )
	oStructCAB:RemoveField( "CE8_ALIQ" )
	oStructCAB:RemoveField( "CE8_ISEN" )
	
	//Remove campos do grid	
	oStructGRD:RemoveField( "CE8_CODIMP" )
	oStructGRD:RemoveField( "CE8_DESC" )
	oStructGRD:RemoveField( "CE8_TIPO" )
	oStructGRD:RemoveField( "CE8_EST" )

	oView:SetModel(oModel)

	oView:AddField( "VIEW_CAB" , oStructCAB , "CE8_CAB" )
	oView:AddGrid(  "VIEW_GRD" , oStructGRD , "CE8_GRD" )

	oView:CreateHorizontalBox( "CABEC" , 20 )
	oView:CreateHorizontalBox( "GRID"  , 80 )

	oView:SetOwnerView( "VIEW_CAB" , "CABEC" )
	oView:SetOwnerView( "VIEW_GRD" , "GRID" )
	
Return oView

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � FLinOk        �Autor  � Ivan Haponczuk     � Data � 18/08/2011  ���
������������������������������������������������������������������������������͹��
���Desc.     � Valida as linhas verificando se possuem per�odos iguais.        ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                     	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   � Logica                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function FLinOk(oGrid) 

	Local lRet := .T.
	Local nLinOri  := oGrid:nLine
	Local dDataIni := oGrid:GetValue("CE8_DATINI")
	Local dDataFin := oGrid:GetValue("CE8_DATFIN")

	If !oGrid:IsDeleted()
		
		//Verifica se a data inicial e maior que a data final da linha superior
		If nLinOri <> 1
			oGrid:GoLine(nLinOri-1)
			If !oGrid:IsDeleted()
				If !( dDataIni > oGrid:GetValue("CE8_DATFIN") )
					Help(" ",1,"Help",,STR0009,1,0)//"A data inicial tem que ser maior que a data final da linha superior."
					lRet := .F.
				EndIf
			EndIf
			oGrid:GoLine(nLinOri)
		EndIf
		
		//Verifica se a data inicial e menor que a data final
		If !( dDataIni <= dDataFin ) .and. lRet
			Help(" ",1,"Help",,STR0010,1,0)//"A data de vigencia final tem que ser maior ou igual a data inicial."
			lRet := .F.
		EndIf
		
	EndIf

Return lRet
