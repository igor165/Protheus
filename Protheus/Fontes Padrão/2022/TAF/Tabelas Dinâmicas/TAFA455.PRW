#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA455.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAYYY
Cadastro MVC dos campos fiscais complementares

@author Rafael Völtz
@since 03/10/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA455()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001 )  //"Relacionamento campos compl. e Obrigações" 
oBrw:SetAlias( 'T55')
oBrw:SetMenuDef( 'TAFA455' )
CHW->(DbSetOrder(1))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rafael Völtz
@since 03/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA455" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rafael Völtz
@since 03/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT55  :=  FWFormStruct( 1, 'T55' )
Local oModel    :=  MPFormModel():New( 'TAFA455' )

oModel:AddFields('MODEL_T55', /*cOwner*/, oStruT55)
oModel:GetModel('MODEL_T55'):SetPrimaryKey({'T55_FILIAL','T55_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rafael Völtz
@since 03/10/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA455' )
Local   oStruT55    :=  FWFormStruct( 2, 'T55' )
Local   oView       :=  FWFormView():New()

oStruT55:RemoveField('T55_ID')
oStruT55:RemoveField("T55_IDOBRG")
oStruT55:RemoveField("T55_IDCHAV")

oView:SetModel( oModel )
oView:AddField( 'VIEW_T55', oStruT55, 'MODEL_T55' )

oView:EnableTitleView( 'VIEW_T55', STR0001)   //"Relacionamento campos compl. e Obrigações" 
oView:CreateHorizontalBox( 'FIELDST55', 100 )
oView:SetOwnerView( 'VIEW_T55', 'FIELDST55' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Rafael Völtz
@Since		13/10/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1018

If nVerEmp < nVerAtu
	aAdd( aHeader, "T55_FILIAL" )
	aAdd( aHeader, "T55_ID" )
	aAdd( aHeader, "T55_IDOBRG" )
	aAdd( aHeader, "T55_IDCHAV" )

	If AliasInDic("T55")
		//GIA-ST
		aAdd( aBody, { "", "f5aa4eb5-6218-2f2c-b8de-dfefabac0755", "1b771a1e-1eeb-d43f-3a4f-d1149ebd477e", "8ad7dc68-9c03-7058-530b-1ce482321f93"} ) //Repasse – ICMS Retido por Refinarias ou Complementos
		aAdd( aBody, { "", "9f76449a-e68d-7459-9606-ebd88f3d392a", "1b771a1e-1eeb-d43f-3a4f-d1149ebd477e", "6c4eb482-2c86-807f-9b2d-e32641ec3b93"} ) //Repasse – ICMS Retido por Outros Contribuintes
		
		//DIAP-AP			
		aAdd( aBody, { "", "10a53568-03d0-843e-94a9-1ece4b9a23d9", "e81fd4fb-2b64-fd5e-0c7b-ef97681fef40", "d67f2611-ff20-d767-95d9-2ec2fbfe81ae"} ) //ICMS Importação Recolhido Fora do Prazo
		aAdd( aBody, { "", "ddb9e3b4-cf34-49e5-bcd0-5755d42b2f54", "e81fd4fb-2b64-fd5e-0c7b-ef97681fef40", "f43dabaf-4bd1-4d2d-e527-b45ba16845a1"} ) //ICMS Importação Vencidos e não Recolhidos
		aAdd( aBody, { "", "54cc57ee-23c0-a7fc-e34a-8fa42e724dd5", "e81fd4fb-2b64-fd5e-0c7b-ef97681fef40", "39a22006-5af3-212c-5c49-0bdba02e2a03"} ) //Dif. Aliq. Ativo Recolhido Fora Prazo
		aAdd( aBody, { "", "b8ea10a0-66a0-07ee-ea66-1b3c1339c42f", "e81fd4fb-2b64-fd5e-0c7b-ef97681fef40", "7e3130eb-dfa5-693b-b95c-2f90109d0764"} ) //Dif. Aliq. Ativo Vencidos e não Recolhidos
		aAdd( aBody, { "", "520db018-5237-de4e-d592-3d907338f38e", "e81fd4fb-2b64-fd5e-0c7b-ef97681fef40", "cdcde72e-fedd-11c1-51d5-c7094d0b986f"} ) //Benefício de Importação
		aAdd( aBody, { "", "91238c7f-654e-6a7d-ab42-1a90dcdcc191", "e81fd4fb-2b64-fd5e-0c7b-ef97681fef40", "fa41a019-6578-6945-ead4-bebdef33d641"} ) //Benefício Dif. Alíquota
		aAdd( aBody, { "", "ad0b7bee-0795-e0dd-b51e-c5591cfd3a4a", "e81fd4fb-2b64-fd5e-0c7b-ef97681fef40", "2e3776d3-81eb-768d-2b13-adddf64544b0"} ) //Dif Aliq Uso/Cons Recolhido Fora do Prazo
		aAdd( aBody, { "", "023f4d57-cdfa-6d5c-5b42-d73fbd0d4fb0", "e81fd4fb-2b64-fd5e-0c7b-ef97681fef40", "7bbaf803-e4cc-7d3d-9c74-2a2166a92995"} ) //Dif Aliq Uso/Cons Vencidos e não Recolhidos		
		
		//DECLAN-RJ
		aAdd( aBody, { "", "97c48659-f599-ee73-6c30-11db3ed6a3d7", "12b9dd9d-aedf-c14c-0e60-39937cedc4fd", "722e460f-428f-4069-81fb-c675d7451b79"} ) //IPI na Entrada de Matéria Prima		
		aAdd( aBody, { "", "34cda47b-bf5e-1214-53a3-e7d7fdfd08c1", "12b9dd9d-aedf-c14c-0e60-39937cedc4fd", "e7746c02-3df6-d765-5635-1df011f758ae"} ) //Imposto Retido Entradas		
		aAdd( aBody, { "", "a15e2bf7-4abf-f2b6-49c8-6edb45580839", "12b9dd9d-aedf-c14c-0e60-39937cedc4fd", "4e07e343-1c86-aa13-3237-e7037b696d53"} ) //IPI que não integra a BC de ICMS na Saída
		aAdd( aBody, { "", "cc02efc0-bd8e-0003-6b4c-36261541b324", "12b9dd9d-aedf-c14c-0e60-39937cedc4fd", "a7ac9fb9-fc98-0170-2b29-5e9fb86d496f"} ) //IPI que integra a BC de ICMS na Saída		
		aAdd( aBody, { "", "1390e9a1-23f6-9662-50b0-1bb4115cf295", "12b9dd9d-aedf-c14c-0e60-39937cedc4fd", "873ceb4b-3378-ed03-320e-ce7e71eb54c1"} ) //Imposto Retido Saídas		
		
		//DPMP
		aAdd( aBody, { "", "15498884-5797-e7b9-0106-3d30ce695ed6", "c26d07af-6c74-c047-4eb8-f1191d728be2", "b9c6ca6a-bd2f-2e58-cf26-e61633832108"} ) //Nat. Operação de Venda de Conta e Ordem
	EndIf                   		
		
	aAdd( aRet, { aHeader, aBody } )
EndIf


Return( aRet )