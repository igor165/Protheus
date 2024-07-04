#Include 'Protheus.ch'

Function TAFA402()

	Local	oBrw		:=	FWmBrowse():New()

	oBrw:SetDescription('Cadastro de Distribuição')	//"Cadastro dos Modelos de Documentos Fiscais"
	oBrw:SetAlias( 'T37')
	oBrw:SetMenuDef( 'TAFA402' )

	T37->(DbSetOrder(1))
 //oBrw:Refresh()

	oBrw:Activate()
 

Return

Static Function MenuDef()
Return XFUNMnuTAF( "TAFA402" )


Static Function ModelDef()
	Local oStruT37 	 := 	FWFormStruct( 1, 'T37' )

	Local oModel 	:= 	MPFormModel():New( 'TAFA402MVC' )
	
	oModel:AddFields('MODEL_T37', /*cOwner*/, oStruT37)
	oModel:GetModel('MODEL_T37'):SetPrimaryKey({"T37_CODDIS"})


Return oModel



Static Function ViewDef()
	Local 	oModel 	 := 	FWLoadModel( 'TAFA402' )
	Local 	oStruT37 	 := 	FWFormStruct( 2, 'T37' )
	
	Local 	oView 	    := 	FWFormView():New()

	//Remover Campos da tela
	oStruT37:RemoveField( 'T37_ID' )

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_T37', oStruT37, 'MODEL_T37' )
	oView:EnableTitleView( 'VIEW_T37', 'Cadastro de Distribuição' )
	oView:CreateHorizontalBox( 'FIELDST37', 100 )
	oView:SetOwnerView( 'VIEW_T37', 'FIELDST37' )
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Marcos Buschmann
@Since		09/12/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1007

If nVerEmp < nVerAtu
	aAdd( aHeader, "T37_FILIAL" )
	aAdd( aHeader, "T37_ID" )
	aAdd( aHeader, "T37_CODDIS" )
	aAdd( aHeader, "T37_DESCRI" )
	aAdd( aHeader, "T37_TIPREG" )
	aAdd( aHeader, "T37_TIPPES" )
	aAdd( aHeader, "T37_VALIDA" )

	aAdd( aBody, { "", "1d0cbfb0-0a35-4786-4ccf-aae866bb909a", "58", "Operações e prestações não escrituradas denunciadas espontaneamente ou apuradas em ação fiscal     ", "1", "1", "" } )
	aAdd( aBody, { "", "30e2f75a-15c1-a395-017f-a023ef5c82b5", "20", "Comunicação - casos especiais de prestação de serviços                                             ", "1", "2", "" } )
	aAdd( aBody, { "", "3f9a762b-d59c-055f-53e7-5418f5c5b852", "21", "Aquisições de produtos agropecuários/pesqueiros sem nota fiscal de produtor                        ", "1", "2", "" } )
	aAdd( aBody, { "", "f03e74fe-4ab5-f5b1-e1c9-dc5b24c56ae1", "22", "Agua natural canalizada                                                                            ", "1", "2", "" } )
	aAdd( aBody, { "", "35972bd2-7ae8-abb2-a5bc-b163a85d5b0a", "23", "Operações e prestações não escrituradas denunciadas espontaneamente ou apuradas em ação fiscal     ", "1", "2", "" } )
	aAdd( aBody, { "", "85a7e6c2-fa6c-d9b7-e61f-a7e721be338f", "26", "Transporte intermunicipal e interestadual                                                          ", "1", "2", "" } )
	aAdd( aBody, { "", "223f8033-435a-63b6-42ed-8293c422c378", "32", "V.Adic.- situação especial de resp. por dispensa de inscrição e/ou registro centralizado (Res.2670)", "1", "2", "" } )
	aAdd( aBody, { "", "2428019e-b57d-7316-4dc6-e7bf41f2620f", "33", "V.Adic.- situação especial de inscrição responsável por revendedor autônomo (Res.2670)             ", "1", "2", "" } )
	aAdd( aBody, { "", "65585dc3-fdee-c6b4-323e-0baa594205b9", "38", "Gás canalizado                                                                                     ", "1", "2", "" } )
	aAdd( aBody, { "", "e795d8c1-e7c7-f4e8-d46b-b79c65e0df4c", "59", "Valor adicionado - consolidação das DASN-SIMEI                                                     ", "1", "2", "" } )
	aAdd( aBody, { "", "c7c82708-db29-a329-53fc-1297f363fed4", "18", "Comunicação - prestação de serviços                                                                ", "1", "2", "" } )
	aAdd( aBody, { "", "c61b76e8-799e-9832-7b0e-0dfb99d96984", "16", "Energia elétrica - geração                                                                         ", "1", "2", "" } )
	aAdd( aBody, { "", "fa9dadcd-067a-47a9-780a-eee46c3c7613", "15", "Energia elétrica - distribuição                                                                    ", "1", "2", "" } )
	aAdd( aBody, { "", "dd5e7a31-78ba-570e-0e9f-ab7c8db67c75", "53", "Transporte intermunicipal e interestadual                                                          ", "2", "2", "" } )
	aAdd( aBody, { "", "a59763bc-2f2d-e143-982a-3a71d6025229", "54", "Receita FG ICMS - situação especial de resp. por dispensa de inscrição e/ou registro centralizado  ", "2", "2", "" } )
	aAdd( aBody, { "", "6033939b-2f80-bc8b-64e6-145ab4faeaca", "55", "Receita FG ICMS - situação especial de inscrição responsável por revendedor autônomo               ", "2", "2", "" } )
	aAdd( aBody, { "", "868228ca-0bfa-3529-d5de-8394e53ffdc2", "56", "Aquisições de produtos agropecuários/pesqueiros sem nota fiscal de produtor                        ", "2", "2", "" } )
	aAdd( aBody, { "", "fc9efa71-566f-33d0-71f7-634699db13cc", "57", "Operações e prestações não escrituradas denunciadas espontaneamente ou apuradas em ação fiscal     ", "2", "2", "" } )
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )