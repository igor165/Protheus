#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA233.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA233
Cadastro de incidência tributária da rubrica para a Previdência Social

@author Anderson Costa
@since 14/08/2013
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA233()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"Cadastro de incidência tributária da rubrica para a Previdência Social"
oBrw:SetAlias( 'C8T')
oBrw:SetMenuDef( 'TAFA233' )
C8T->(dbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 14/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA233" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Anderson Costa
@since 14/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC8T  :=  FWFormStruct( 1, 'C8T' )
Local oModel    :=  MPFormModel():New( 'TAFA233' )

oModel:AddFields('MODEL_C8T', /*cOwner*/, oStruC8T)
oModel:GetModel('MODEL_C8T'):SetPrimaryKey({'C8T_FILIAL', 'C8T_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao genérica MVC do View

@return oView - Objeto da View MVC

@author Anderson Costa
@since 14/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA233' )
Local   oStruC8T    :=  FWFormStruct( 2, 'C8T' )
Local   oView       :=  FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C8T', oStruC8T, 'MODEL_C8T' )

oView:EnableTitleView( 'VIEW_C8T', STR0001 )    //"Cadastro de incidência tributária da rubrica para a Previdência Social"
oView:CreateHorizontalBox( 'FIELDSC8T', 100 )
oView:SetOwnerView( 'VIEW_C8T', 'FIELDSC8T' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet	   	-	Array com estrutura de campos e conteúdo da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	as array
Local aBody	as array
Local aRet		as array

Default nVerEmp	:= 0
Default nVerAtu	:= 0

aHeader	:=	{}
aBody		:=	{}
aRet		:=	{}

nVerAtu	:= 1031.20

If nVerEmp < nVerAtu .And. TafAtualizado(.F.) 
	aAdd( aHeader, "C8T_FILIAL" )
	aAdd( aHeader, "C8T_ID" )
	aAdd( aHeader, "C8T_CODIGO" )
	aAdd( aHeader, "C8T_DESCRI" )
	aAdd( aHeader, "C8T_VALIDA" )

	aAdd( aBody, { "", "000001", "00", "NAO E BASE DE CALCULO", "" } )
	aAdd( aBody, { "", "000002", "11", "BASE DE CALCULO DAS CONTRIB. SOCIAIS - MENSAL", "" } )
	aAdd( aBody, { "", "000003", "12", "BASE DE CALCULO DAS CONTRIB. SOCIAIS - 13. SALARIO", "" } )
	aAdd( aBody, { "", "000004", "21", "BASE DE CALCULO DAS CONTRIB. SOCIAIS - SAL. MATERNIDADE MENSAL PAGO PELO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000005", "22", "BASE DE CALCULO DAS CONTRIB. SOCIAIS - SAL. MATERNIDADE - 13. SALARIO, PAGO PELO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000006", "23", "BASE DE CALCULO DAS CONTRIB. SOCIAIS - AUXILIO DOENÇA MENSAL - REGIME PROPRIO DE PREVIDENCIA SOCIAL", "20211109" } )
	aAdd( aBody, { "", "000007", "24", "BASE DE CALCULO DAS CONTRIB. SOCIAIS - AUXILIO DOENÇA - 13. SALARIO DOENÇA - REGIME PROPRIO DE PREVIDENCIA SOCIAL", "20211109" } )
	aAdd( aBody, { "", "000008", "31", "CONTRIBUICAO DESCONTADA DO SEGURADO - MENSAL", "" } )
	aAdd( aBody, { "", "000009", "32", "CONTRIBUICAO DESCONTADA DO SEGURADO - 13. SALARIO", "" } )
	aAdd( aBody, { "", "000010", "34", "CONTRIBUICAO DESCONTADA DO SEGURADO - SEST ", "" } )
	aAdd( aBody, { "", "000011", "51", "OUTROS - SALARIO-FAMILIA", "" } )
	aAdd( aBody, { "", "000012", "61", "OUTROS - COMPLEMENTO DE SALARIO-MINIMO - REGIME PROPRIO DE PREVIDENCIA SOCIAL", "20211109" } )
	aAdd( aBody, { "", "000013", "91", "SUSPENSAO DE INCID. SOBRE SAL. DE CONTRIB. EM DECOR. DE DECISAO JUDIC. - MENSAL", "" } )
	aAdd( aBody, { "", "000014", "92", "SUSPENSAO DE INCID. SOBRE SAL. DE CONTRIB. EM DECOR. DE DECISAO JUDIC. - 13. SALARIO", "" } )
	aAdd( aBody, { "", "000015", "93", "SUSPENSAO DE INCID. SOBRE SAL. DE CONTRIB. EM DECOR. DE DECISAO JUDIC. - SAL. MATERNIDADE", "" } )
	aAdd( aBody, { "", "000016", "94", "SUSPENSAO DE INCID. SOBRE SAL. DE CONTRIB. EM DECOR. DE DECISAO JUDIC. - SAL. MATERNIDADE 13. SALARIO", "" } )
	//Inclusões versão 2.2 beta
	aAdd( aBody, { "", "000017", "25", "BASE DE CALCULO DAS CONTRIB. SOCIAIS - SAL. MATERNIDADE MENSAL PAGO PELO INSS", "" } )
	aAdd( aBody, { "", "000018", "26", "BASE DE CALCULO DAS CONTRIB. SOCIAIS - SAL. MATERNIDADE - 13. SALARIO, PAGO PELO INSS", "" } )
	aAdd( aBody, { "", "000019", "35", "CONTRIBUICAO DESCONTADA DO SEGURADO - SENAT", "" } )
	//Versao 2.2.3 beta
	aAdd( aBody, { "", "000020", "01", "NAO E BASE DE CALCULO EM FUNÇÃO DE ACORDOS INTERNACIONAIS DE PREVIDÊNCIA SOCIAL", "" } )
	//Versao 2.2.3
	aAdd( aBody, { "", "000021", "13", "BASE DE CALCULO DAS CONTRIB. SOCIAIS - EXCLUSIVA DO EMPREGADOR - MENSAL", "" } )
	aAdd( aBody, { "", "000022", "14", "BASE DE CALCULO DAS CONTRIB. SOCIAIS - EXCLUSIVA DO EMPREGADOR - 13º SALÁRIO", "" } )
	aAdd( aBody, { "", "000023", "15", "BASE DE CALCULO DAS CONTRIB. SOCIAIS - EXCLUSIVA DO SEGURADO - MENSAL", "" } )
	aAdd( aBody, { "", "000024", "16", "BASE DE CALCULO DAS CONTRIB. SOCIAIS - EXCLUSIVA DO SEGURADO - 13º SALÁRIO", "" } )
	// 2.4.01
	aAdd( aBody, { "", "000025", "95", "SUSPENSAO DE INCID. SOBRE SAL. DE CONTRIB. EM DECOR. DE DECISAO JUDIC. - EXCLUSIVA DO EMPREGADOR - MENSAL", "" } )
	aAdd( aBody, { "", "000026", "96", "SUSPENSAO DE INCID. SOBRE SAL. DE CONTRIB. EM DECOR. DE DECISAO JUDIC. - EXCLUSIVA DO EMPREGADOR - 13º SALÁRIO", "" } )
	aAdd( aBody, { "", "000027", "97", "SUSPENSAO DE INCID. SOBRE SAL. DE CONTRIB. EM DECOR. DE DECISAO JUDIC. - EXCLUSIVA DO EMPREGADOR - SALÁRIO MATERNIDADE", "" } )
	aAdd( aBody, { "", "000028", "98", "SUSPENSAO DE INCID. SOBRE SAL. DE CONTRIB. EM DECOR. DE DECISAO JUDIC. - EXCLUSIVA DO EMPREGADOR - SALÁRIO MATERNIDADE 13º SALÁRIO", "" } )
	
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
