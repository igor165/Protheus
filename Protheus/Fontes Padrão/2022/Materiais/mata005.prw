#INCLUDE "MATA005.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"        

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    �MATA005        �Autor  �Microsiga           � Data �  30/08/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Manutencao do Grupo de Filiais                           	       ���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat                                                     	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   �                                                                 ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Function MATA005()
	Local oBrowse    					//Novo browse de aplicacao MVC

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SAU')
	oBrowse:SetDescription(STR0001)		//'Grupo de Filiais'
	oBrowse:Activate()
Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    �MenuDef        �Autor  �Microsiga           � Data �  30/08/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Definicao do MenuDef para o MVC                          	       ���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat                                                     	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   �Array                                                            ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function MenuDef()
	Local aRotina := {} //Array utilizado para controlar opcao selecionada

	ADD OPTION aRotina TITLE STR0004 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 //'Pesquisar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.MATA005' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.MATA005' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.MATA005' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.MATA005' OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.MATA005' OPERATION 8 ACCESS 0 //'Imprimir'
	ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.MATA005' OPERATION 9 ACCESS 0 //'Copiar'
Return aRotina

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    �ModelDef       �Autor  �Microsiga           � Data �  30/08/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Definicao do ModelDef para o MVC                         	       ���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat                                                     	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   �Objeto                                                           ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ModelDef()
	Local oStructCab := FWFormStruct( 1,"SAU",{ |cCampo|  AllTrim( cCampo ) + "|" $ "AU_CODGRUP|AU_DESCRI|AU_ATIVO|"} ) //Estrutura de Cabecalho
	Local oStructSAU := FWFormStruct( 1,"SAU",{ |cCampo| !AllTrim( cCampo ) + "|" $ "AU_CODGRUP|AU_DESCRI|AU_ATIVO|"} ) //Estrutura de Itens
	Local oModel  //Modelo de Dados MVC
    Local bCommit	 := {|oMdl|Mta005Cmt(oMdl)} //Atualiza todos os registros 
        
	oModel:= MPFormModel():New("MATA005MOD",/*bPValid*/,/*Pos-Validacao*/,bCommit,/*Cancel*/)
	oModel:AddFields("SAU_CAB", /*cOwner*/, oStructCab ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	oModel:AddGrid("SAU_DET", "SAU_CAB"/*cOwner*/, oStructSAU,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)

	oModel:SetRelation("SAU_DET",{{"AU_FILIAL",'xFilial("SAU")'},{"AU_CODGRUP","AU_CODGRUP"}},SAU->(IndexKey()))
	oModel:SetPrimaryKey({"AU_FILIAL"},{"AU_CODGRUP"},{"AU_CODFIL"})
	oModel:GetModel("SAU_DET"):SetUniqueLine({"AU_CODFIL"})
	oModel:SetDescription( STR0001 ) //'Grupo de filiais'

	oModel:GetModel( 'SAU_CAB' ):SetDescription( STR0002 ) //'Dados do grupo'
	oModel:GetModel( 'SAU_DET' ):SetDescription( STR0003 ) //'Detalhe das filiais'
Return oModel 

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � ViewDef       �Autor  �Microsiga           � Data �  30/08/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Definicao da Visualizacao para o MVC                    	       ���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat                                                     	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   �Objeto                                                           ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ViewDef()
	Local oStructCab := FWFormStruct(2,"SAU",{|cCampo| AllTrim(cCampo)+"|" $ "AU_CODGRUP|AU_DESCRI|AU_ATIVO|"}) //Estrutura de Cabecalho
	Local oStructSAU := FWFormStruct(2,"SAU",{|cCampo| !AllTrim(cCampo)+"|" $ "AU_CODGRUP|AU_DESCRI|AU_ATIVO|"}) //Estrutura de Itens
	Local oModel     := FWLoadModel("MATA005") //Chamada do model criado anteriormente
	Local oView      := FWFormView():New() //View da MVC

	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB",oStructCab,"SAU_CAB")
	oView:AddGrid( "VIEW_DET",oStructSAU,"SAU_DET")

	oView:CreateHorizontalBox("CABEC",20)
	oView:CreateHorizontalBox("GRID",80)

	oView:SetOwnerView( "VIEW_CAB","CABEC")
	oView:SetOwnerView( "VIEW_DET","GRID")
Return oView

    
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Mta005Cmt � Autor � Vendas CRM         � Data �  29/07/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Grava a descricao do cabecalho no grid qdo for alteracao    ���
�������������������������������������������������������������������������͹��
���Uso       �Mata005                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Mta005Cmt(oMdl)
Local nOperation := oMdl:GetOperation()
Local oMdlCab 	 := oMdl:GetModel('SAU_CAB')
Local lRet     	 := .T. 
Local aArea      := GetArea()
      
If nOperation == 3 .AND. SAU->(DbSeek(xFilial("SAU") + oMdlCab:GetValue("AU_CODGRUP"))) 
	lRet := .F.
	Alert(STR0011 + oMdlCab:GetValue("AU_CODGRUP"))	  //"J� existe um cadastro com o c�digo " + oMdlCab:GetValue("AU_CODGRUP")
	Return lRet
EndIf

If nOperation == 3  .Or. nOperation == 5	
	FWModelActive(oMdl)
	FWFormCommit(oMdl)
Endif

If nOperation == 4
	FWModelActive(oMdl)
	FWFormCommit(oMdl)
	MT5GrvDesc(oMdl)
EndIf                  
     
RestArea(aArea)
Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GrvDesc   � Autor � Vendas CRM         � Data �  29/07/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Grava a descricao do cabecalho no grid.                     ���
�������������������������������������������������������������������������͹��
���Uso       �Mata005                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MT5GrvDesc(oMdl)

Local oMdlCab := oMdl:GetModel('SAU_CAB')
Local oMdlGrid := oMdl:GetModel('SAU_DET')
Local nX := 0

dbSelectArea("SAU")
dbSetOrder(1)
For nX:= 1 to oMdlGrid:GetQtdLine()
	oMdlGrid:GoLine(nX)
	If DbSeek(xFilial("SAU")+oMdlCab:GetValue("AU_CODGRUP")+oMdlGrid:GetValue("AU_CODFIL"))
		RecLock("SAU",.F.)
		SAU->AU_CODGRUP := oMdlCab:GetValue("AU_CODGRUP")
		SAU->AU_DESCRI  := oMdlCab:GetValue("AU_DESCRI")
		MsUnlock()
	Endif
Next nX

Return Nil

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    �A005VldFil     �Autor  �Microsiga           � Data �  30/08/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Funcao de validacao de filiais	                    	       ���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat                                                     	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   �Logico                                                           ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Function A005VldFil()
	Local lRet := .F. //Retorno da Validacao
	Local aArea := GetArea() //Controde Area
	
	SM0->( dbGoTop() )
	While !SM0->( Eof() )
		If AllTrim(SM0->M0_CODFIL) == AllTrim(M->AU_CODFIL) .Or. lRet
			lRet := .T.
			Exit
		EndIf
		SM0->( dbSkip() )
	EndDo
	
	RestArea(aArea)
Return lRet


