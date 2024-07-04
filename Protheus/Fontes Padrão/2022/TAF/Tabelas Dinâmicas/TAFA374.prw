#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA374.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA374
Cadastro MVC de Natureza da SubConta

@author Evandro dos Santos Oliveira	
@since 19/01/2015
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA374()

Local	oBrw := FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Cadastro de Natureza da Subconta"
oBrw:SetAlias( 'CHI')
oBrw:SetMenuDef( 'TAFA374' )
CHI->(dbSetOrder(2))
oBrw:Activate()

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Evandro dos Santos Oliveira	
@since 19/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA374" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Evandro dos Santos Oliveira	
@since 19/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCHI 	:= 	FWFormStruct( 1, 'CHI' )
Local oModel 	:= 	MPFormModel():New( 'TAFA374' )

oModel:AddFields('MODEL_CHI', /*cOwner*/, oStruCHI)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Evandro dos Santos Oliveira	
@since 19/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local 	oModel 	:= 	FWLoadModel( 'TAFA374' )
Local 	oStruCHI 	:= 	FWFormStruct( 2, 'CHI' )
Local 	oView 		:= 	FWFormView():New()


oStruCHI:RemoveField('CHI_ID') //Remove o campo da view
oView:SetModel( oModel )
oView:AddField( 'VIEW_CHI', oStruCHI, 'MODEL_CHI' )

oView:EnableTitleView( 'VIEW_CHI', STR0001 )	//"Cadastro de Natureza da Subconta"
oView:CreateHorizontalBox( 'FIELDSCHI', 100 )
oView:SetOwnerView( 'VIEW_CHI', 'FIELDSCHI' )

Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1005

If nVerEmp < nVerAtu
	aAdd( aHeader, "CHI_FILIAL" )
	aAdd( aHeader, "CHI_ID" )
	aAdd( aHeader, "CHI_CODIGO" )
	aAdd( aHeader, "CHI_DESCRI" )
	aAdd( aHeader, "CHI_BASLEG" )
	aAdd( aHeader, "CHI_CTAPRI" )
	aAdd( aHeader, "CHI_DTINI" )
	aAdd( aHeader, "CHI_DTFIN" )

	aAdd( aBody, { "", "3bf3ffde-4684-7a4e-7cfe-1215232bb289", "10", "SUBCONTA GOODWILL", "Art. 20, Inciso III, Decreto-Lei no 1.598/77", "PARTICIPA��O SOCIETARIA", "20140101", "" } )
	aAdd( aBody, { "", "e5e1a33a-0487-3df8-e697-bd99d741c632", "11", "SUBCONTA MAIS VALIA", "Art. 20, Inciso II, Decreto-Lei no 1.598/77", "PARTICIPA��O SOCIETARIA", "20140101", "" } )
	aAdd( aBody, { "", "b7b8464a-7143-b79b-2131-b5d0bfe9ab85", "12", "SUBCONTA MENOS VALIA", "Art. 20, Inciso II, Decreto-Lei no 1.598/77", "PARTICIPA��O SOCIETARIA", "20140101", "" } )
	aAdd( aBody, { "", "a1e7c4d0-4bd9-bc8b-ab5a-b720a716a4a9", "90", "SUBCONTA ADO��O INICIAL - VINCULADA ATIVO/PASSIVO", "Arts. 66 e 67, Lei no 12.973/14", "ATIVO OU PASSIVO", "20140101", "" } )
	aAdd( aBody, { "", "0859d99a-f74a-abf6-dc4d-a8da6754e850", "2", "SUBCONTA TBU - CONTROLADA DIRETA NO EXTERIOR", "Art. 76, Lei no 12.973/14", "PARTICIPA��O CONTROLADA NO EXTERIOR", "20140101", "" } )
	aAdd( aBody, { "", "a86d0f56-285e-e0f9-f7aa-586b7b704c0c", "3", "SUBCONTA TBU - CONTROLADA INDIRETA NO EXTERIOR", "Art. 76, Lei no 12.973/14", "PARTICIPA��O CONTROLADA NO EXTERIOR", "20140101", "" } )
	aAdd( aBody, { "", "78fe709b-a9bc-5fbb-6911-3a11628bc366", "60", "SUBCONTA AVJ REFLEXO", "Arts. 24A e 24B, Decreto-Lei no 1.598/77", "PARTICIPA��O SOCIETARIA", "20140101", "" } )
	aAdd( aBody, { "", "a117fd6d-bd6c-eaf9-112c-17710fc08397", "65", "SUBCONTA AVJ SUBSCRI��O DE CAPITAL", "Arts. 17 e 18, Lei no 12.973/14", "PARTICIPA��O SOCIETARIA", "20140101", "" } )
	aAdd( aBody, { "", "69be0c31-b127-4dad-7038-4058785a403d", "70", "SUBCONTA AVJ - VINCULADA ATIVO/PASSIVO", "Arts 13 e 14, Lei no 12.973/14", "ATIVO OU PASSIVO", "20140101", "" } )
	aAdd( aBody, { "", "4395d642-41af-caac-772d-f3e055540d01", "71", "SUBCONTA AVJ - DEPRECIA��O ACUMULADA", "Arts 13, �1o, e 14, Lei no 12.973/14", "DEPRECIA��O ACUMULADA", "20140101", "" } )
	aAdd( aBody, { "", "afea3fe1-85e8-ebd5-42ae-cf61cb532cfb", "72", "SUBCONTA AVJ - AMORTIZA��O ACUMULADA", "Arts 13, �1o, e 14, Lei no 12.973/14", "AMORTIZA��O ACUMULADA", "20140101", "" } )
	aAdd( aBody, { "", "bef0b686-80f6-4b67-b690-8152b5ffc0cb", "73", "SUBCONTA AVJ - EXAUST�O ACUMULADA", "Arts 13, �1o, e 14, Lei no 12.973/14", "EXAUST�O ACUMULADA", "20140101", "" } )
	aAdd( aBody, { "", "0290141a-8d6a-8dc1-9e3a-f1130c2e6cf4", "75", "SUBCONTA AVP - VINCULADA AO ATIVO", "Art. 5o, � 1o, Lei no 12.973/14", "ATIVO", "20140101", "" } )
	aAdd( aBody, { "", "4f85185a-56b5-75a9-7eae-921348308b17", "76", "SUBCONTA AVP - DEPRECIA��O ACUMULADA", "Art. 5o, Inc. III, Lei no 12.973/14", "DEPRECIA��O ACUMULADA", "20140101", "" } )
	aAdd( aBody, { "", "cd731d48-611c-987b-a4a6-0e14c34edab1", "77", "SUBCONTA AVP - AMORTIZA��O ACUMULADA", "Art. 5o, Inc. III, Lei no 12.973/14", "AMORTIZA��O ACUMULADA", "20140101", "" } )
	aAdd( aBody, { "", "1b3f2aab-43ea-955b-8b19-293ef02544df", "78", "SUBCONTA AVP - EXAUST�O ACUMULADA", "Art. 5o, Inc. III, Lei no 12.973/14", "EXAUST�O ACUMULADA", "20140101", "" } )
	aAdd( aBody, { "", "f323ea46-9a99-276a-0677-ae8df4366c28", "80", "SUBCONTA MAIS VALIA ANTERIOR � EST�GIOS", "Art. 37, �3o, Inc. I, Lei no 12.973/14, ou Art. 39, �1o, Inc. I, Lei no 12.973/14", "PARTICIPA��O SOCIETARIA NO PA�S", "20140101", "" } )
	aAdd( aBody, { "", "d18f4085-2b04-2bde-f3a0-1e3ab45cf717", "81", "SUBCONTA MENOS VALIA ANTERIOR � EST�GIOS", "Art. 37, �3o, Inc. I, Lei no 12.973/14, ou Art. 39, �1o., Inc. I, Lei no 12.973/14", "PARTICIPA��O SOCIETARIA NO PA�S", "20140101", "" } )
	aAdd( aBody, { "", "343c26e4-3912-ba5f-40f3-9488854c36ed", "82", "SUBCONTA GOODWILL ANTERIOR � EST�GIOS", "Art. 37, �3o, Inc. I, Lei no 12.973/14, ou Art. 39, �1o, Inc. I, Lei no 12.973/14", "PARTICIPA��O SOCIETARIA NO PA�S", "20140101", "" } )
	aAdd( aBody, { "", "5a21b3ca-3c23-fc8b-1d56-1f216c5563bc", "84", "SUBCONTA VARIA��O MAIS VALIA ANTERIOR � EST�GIOS", "Art. 37, �3o, Inc. II, Lei no 12.973/14 ou Art. 39, �1o, Inc. II, Lei no 12.973/14", "PARTICIPA��O SOCIETARIA NO PA�S", "20140101", "" } )
	aAdd( aBody, { "", "046c471e-7c3e-836d-87e4-b8967d2efdd5", "85", "SUBCONTA VARIA��O MENOS VALIA ANTERIOR � EST�GIOS", "Art. 37, �3o, Inc. II, Lei no 12.973/14 ou Art. 39, �1o, Inc. II, Lei no 12.973/14", "PARTICIPA��O SOCIETARIA NO PA�S", "20140101", "" } )
	aAdd( aBody, { "", "7a27dd8b-32b9-1b2f-de7d-e3aff47b6411", "86", "SUBCONTA VARIA��O GOODWILL ANTERIOR � EST�GIOS", "Art. 37, �3o, Inc. II, Lei no 12.973/14 ou Art. 39, �1o, Inc. II, Lei no 12.973/14", "PARTICIPA��O SOCIETARIA NO PA�S", "20140101", "" } )
	aAdd( aBody, { "", "6a3a50cf-2800-17bd-8006-a9c8b3561b47", "91", "SUBCONTA ADO��O INICIAL -  DEPRECIA��O ACUMULADA", "Arts. 66 e 67, Lei no 12.973/14", "DEPRECIA��O ACUMULADA", "20140101", "" } )
	aAdd( aBody, { "", "42ab3160-5609-c02a-95a2-b6887e879a0c", "92", "SUBCONTA ADO��O INICIAL -  AMORTIZA��O ACUMULADA", "Arts. 66 e 67, Lei no 12.973/14", "AMORTIZA��O ACUMULADA", "20140101", "" } )
	aAdd( aBody, { "", "6bdeb415-a585-d79c-3c13-938b4a53e5ec", "93", "SUBCONTA ADO��O INICIAL -  EXAUST�O ACUMULADA", "Arts. 66 e 67, Lei no 12.973/14", "EXAUST�O ACUMULADA", "20140101", "" } )
	aAdd( aBody, { "", "e89097fa-a9d5-7b92-efe7-287cd3b936aa", "95", "SUBCONTA ADO��O INICIAL - VINCULADA DEPRECIA��O ACUMULADA", "Arts. 66 e 67, Lei no 12.973/14 c/c art. 57, Lei no 4.506/64", "DEPRECIA��O ACUMULADA", "20140101", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )