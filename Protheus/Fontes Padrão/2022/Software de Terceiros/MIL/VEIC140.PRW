#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "VEIC140.CH"

Function VEIC140( cCodVN0 )
Private oModel := FWLoadModel("VEIC140")
Private oView  := FWLoadView("VEIC140")
DbSelectArea("VN0")
DbSetOrder(1)
If DbSeek( xFilial("VN0") + cCodVN0 )
     oModel:setOperation(MODEL_OPERATION_VIEW)
     If oModel:Activate()
	 	//
		oModel:LoadValue( "PRCDETAIL" , "AVISTA" , VA2400151_ValorVendaPacote( "" , cCodVN0 , "1" ) ) // Retorna o Valor de Venda A VISTA do Pacote
		oModel:LoadValue( "PRCDETAIL" , "APRAZO" , VA2400151_ValorVendaPacote( "" , cCodVN0 , "2" ) ) // Retorna o Valor de Venda A PRAZO do Pacote
		oModel:LoadValue( "PRCDETAIL" , "MAXDESC" , VA2500021_Retorna_Indice_VN3( VN0->VN0_CODMAR , VN0->VN0_MODVEI , VN0->VN0_SEGMOD , "3" , dDataBase ) ) // Retorna o Desconto Maximo atual da Marca/Modelo/Segmento
		//
        oExecView := FWViewExec():New()
        oExecView:setTitle( STR0001 ) // Visualizar Pacote de Configuração
        oExecView:setModel(oModel)
        oExecView:setView(oView)
        oExecView:setOK( { || .T. } )
        oExecView:setCancel( { || .T. } )
        CursorArrow()
        oExecView:openView(.T.)
    EndIf
EndIf
Return .t.

Static Function ModelDef()
	Local oModel
	Local oStrVN0 := FWFormStruct(1, "VN0")
	Local oStrVN1 := FWFormStruct(1, "VN1")
	//Local oStrPrc := FWFormStruct(1, "VN0", { |campo| AllTrim(campo) $ "VN0_CODIGO" } )
	Local oStrPrc := FWFormStruct(1, "VN0" )
	Local oCpoAux := VC1400021_Campos_Precos()
	Local oStrAux := oCpoAux:GetModel()
	Local nCntFor := 0
	For nCntFor := 1 to len(oStrAux:aFields)
		aadd(oStrPrc:aFields,oStrAux:aFields[nCntFor])
	Next

	oModel := MPFormModel():New('VEIC140',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)

	oModel:AddFields('VN0MASTER',/*cOwner*/, oStrVN0)
	oModel:AddFields('PRCDETAIL','VN0MASTER', oStrPrc)
	oModel:AddGrid('VN1DETAIL','VN0MASTER', oStrVN1, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /* <bLoad> */ )

	oModel:SetRelation( 'PRCDETAIL', { { 'VN0_FILIAL', 'VN0_FILIAL' }, { 'VN0_CODIGO', 'VN0_CODIGO' } }, VN0->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'VN1DETAIL', { { 'VN1_FILIAL', 'xFilial( "VN1" )' }, { 'VN1_CODVN0', 'VN0_CODIGO' } }, VN1->( IndexKey( 2 ) ) )

	oModel:SetPrimaryKey( { "VN0_FILIAL", "VN0_CODIGO" } )
	oModel:SetDescription(STR0002) // Pacote de Configuração
	oModel:GetModel('VN0MASTER'):SetDescription(STR0003) // Informações do Pacote de Configuração
	oModel:GetModel('PRCDETAIL'):SetDescription(STR0004) // Preços e Desconto
	oModel:GetModel('VN1DETAIL'):SetDescription(STR0005) // Itens do Pacote de Configuração

Return oModel

Static Function ViewDef()

	Local oModel  := FWLoadModel( 'VEIC140' )
	Local oView   := Nil
	Local oStrVN0 := FWFormStruct(2, "VN0")
	Local oStrVN1 := FWFormStruct(2, "VN1")
	Local oStrPrc := FWFormStruct(2, "VN0", { |campo| AllTrim(campo) $ "VN0_CODIGO" } )
	Local oCpoAux := VC1400021_Campos_Precos()
	Local oStrAux := oCpoAux:GetView()
	Local nCntFor := 0
	For nCntFor := 1 to len(oStrAux:aFields)
		aadd(oStrPrc:aFields,oStrAux:aFields[nCntFor])
	Next

	oStrVN0:RemoveField('VN0_VLOPCS')
	oStrVN0:RemoveField('VN0_STATUS')
	oStrVN0:RemoveField('VN0_DATINC')
	oStrVN0:RemoveField('VN0_DATALT')
	oStrVN0:RemoveField('VN0_CHVOPC')

	oStrPrc:RemoveField('VN0_CODIGO')

	oStrVN1:RemoveField('VN1_CODIGO')
	oStrVN1:RemoveField('VN1_CODVN0')
	oStrVN1:RemoveField('VN1_CODVQC')
	oStrVN1:RemoveField('VN1_CODVQD')
	oStrVN1:RemoveField('VN1_DATINC')
	oStrVN1:RemoveField('VN1_DATALT')

	oView := FWFormView():New()

	oView:SetModel(oModel)
	
	oView:CreateHorizontalBox( 'BOXVN0', 50)
	oView:CreateHorizontalBox( 'BOXPRC',100,,.t.) // Fixo 100 pix
	oView:CreateHorizontalBox( 'BOXVN1', 50)
	
	oView:AddField('VIEW_VN0', oStrVN0, 'VN0MASTER')
	oView:EnableTitleView('VIEW_VN0',STR0002) // Pacote de Configuração
	oView:SetOwnerView('VIEW_VN0','BOXVN0')

	oView:AddField('VIEW_PRC', oStrPrc, 'PRCDETAIL')
	oView:EnableTitleView('VIEW_PRC',STR0004) // Preços e Desconto
	oView:SetOwnerView('VIEW_PRC','BOXPRC')

	oView:AddGrid("VIEW_VN1",oStrVN1, 'VN1DETAIL')
	oView:EnableTitleView('VIEW_VN1',STR0005) // Itens do Pacote de Configuração
	oView:SetOwnerView('VIEW_VN1','BOXVN1')

Return oView

/*/
{Protheus.doc} VC1400011_CodigoOpcional
Retorna o Codigo do Opcional - utilizado no SX3

@author Andre Luis Almeida
@since 15/07/2021
/*/
Function VC1400011_CodigoOpcional(cCodVQD)
Local cQuery  := ""
cQuery := "SELECT VJV.VJV_CODOPC "
cQuery += "  FROM " + RetSqlName("VQD")+" VQD"
cQuery += "  JOIN " + RetSqlName("VJV")+" VJV"
cQuery += "    ON VJV.VJV_FILIAL='"+xFilial("VJV")+"'"
cQuery += "   AND VJV.VJV_CODIGO=VQD.VQD_CODVJV"
cQuery += "   AND VJV.D_E_L_E_T_=' '"
cQuery += " WHERE VQD.VQD_FILIAL='"+xFilial("VQD")+"'"
cQuery += "   AND VQD.VQD_CODIGO='"+cCodVQD+"'"
cQuery += "   AND VQD.D_E_L_E_T_=' '"
Return FM_SQL(cQuery)

/*/
{Protheus.doc} VC1400021_Campos_Precos
Monta Campos da Grid de Preços e Desconto

@author Andre Luis Almeida
@since 27/07/2021
/*/
Static Function VC1400021_Campos_Precos()
Local oRetorno := OFDMSStruct():New()

oRetorno:AddField({	{ 'cIdField'   , 'AVISTA' },;
					{ 'cTitulo'    , STR0006 },; // Preço A VISTA
					{ 'cTooltip'   , STR0006 },; // Preço A VISTA
					{ 'cTipo'      , 'N' },;
					{ 'nTamanho'   , 15 },;
					{ 'nDecimal'   , 2 },;
					{ 'cPicture'   , '@E 999,999,999,999.99' } ,;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .f. } } )

oRetorno:AddField({	{ 'cIdField'   , 'APRAZO' },;
					{ 'cTitulo'    , STR0007 },; // Preço A PRAZO
					{ 'cTooltip'   , STR0007 },; // Preço A PRAZO
					{ 'cTipo'      , 'N' },;
					{ 'nTamanho'   , 15 },;
					{ 'nDecimal'   , 2 },;
					{ 'cPicture'   , '@E 999,999,999,999.99' } ,;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .f. } } )

oRetorno:AddField({	{ 'cIdField'   , 'MAXDESC' },;
					{ 'cTitulo'    , STR0008 },; // Desconto Máximo
					{ 'cTooltip'   , STR0008 },; // Desconto Máximo
					{ 'cTipo'      , 'N' },;
					{ 'nTamanho'   , 7 },;
					{ 'nDecimal'   , 2 },;
					{ 'cPicture'   , '@E 999.999' } ,;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .f. } } )

Return oRetorno