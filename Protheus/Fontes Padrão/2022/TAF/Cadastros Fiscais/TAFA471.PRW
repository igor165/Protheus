#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA471.CH" 

//-------------------------------------------------------------------
/*{Protheus.doc} TAFA471    

Informações sobre o Grupo Multinacional e a Entidade Declarante – Declaração País-a-País

@author Henrique Pereira 
@since 20/03/2017
@version 1.0
*/
//-------------------------------------------------------------------
Function TAFA471()
Local oBrw	as object

oBrw	:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Declaração País-a-País (Country-by-Country Report)
oBrw:SetAlias( "T67" )
oBrw:SetMenuDef( "TAFA471" )
oBrw:Activate()

Return()

//------------------------------------------------------------------
/*{Protheus.doc} MenuDef                

Funcao generica MVC com as opcoes de menu

@author Henrique Pereira
@since 20/03/2017
@version 1.0
*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao	as array
Local aRotina	as array

aFuncao	:=	{}
aRotina	:=	{}

Aadd( aFuncao, { "" , "Taf471Vld" , "2" } )

aRotina := xFunMnuTAF( "TAFA471",, aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Henrique Pereira
@since 20/03/2017
@version 1.0
*/

//-------------------------------------------------------------------
Static Function ModelDef()  

Local oStruT67	as object
Local oStruT68	as object
Local oStruT69	as object
Local oStruT6A	as object
Local oModel		as object

oStruT67	:=	FWFormStruct( 1, "T67" )
oStruT68	:=	FWFormStruct( 1, "T68" )
oStruT69	:=	FWFormStruct( 1, "T69" )
oStruT6A	:=	FWFormStruct( 1, "T6A" )

DbSelectArea("C08")

oModel		:=	MPFormModel():New( "TAFA471",,{|oModel|ValidModel(oModel)},{ |oModel| SaveModel( oModel ) },)

oModel:AddFields( 'MODEL_T67', /*cOwner*/ , oStruT67 )
oModel:GetModel( 'MODEL_T67' ):SetPrimaryKey( { "T67_FILIAL" } )

oModel:AddGrid( 'MODEL_T6A', 'MODEL_T67', oStruT6A )
oModel:GetModel( 'MODEL_T6A' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_T6A' ):SetUniqueLine( { "T6A_FILIAL","T6A_ID","T6A_INCREM" } )

oModel:AddGrid( 'MODEL_T68', 'MODEL_T67', oStruT68 )
oModel:GetModel ('MODEL_T68'):SetOptional( .T. )
oModel:GetModel( 'MODEL_T68' ):SetUniqueLine( { "T68_FILIAL","T68_ID","T68_IDJURI" } )

oModel:AddGrid( 'MODEL_T69', 'MODEL_T68', oStruT69 )
oModel:GetModel('MODEL_T69'):SetOptional( .T. )
oModel:GetModel( 'MODEL_T69' ):SetUniqueLine( { "T69_FILIAL","T69_ID","T69_IDJPAI","T69_INCREM" } )

oModel:SetRelation( 'MODEL_T68', { { 'T68_FILIAL', 'xFilial( "T68" )' } , { 'T68_ID' , "T67_ID" } }	, T68->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_T69', { { 'T69_FILIAL', 'xFilial( "T69" )' } , { 'T69_ID' , "T67_ID" }	, {'T69_IDJPAI' ,'T68_IDJURI'} }, T69->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_T6A', { { 'T6A_FILIAL', 'xFilial( "T6A" )' } , { 'T6A_ID' , "T67_ID" } }	, T6A->( IndexKey( 1 ) ) )

Return( oModel )

//-------------------------------------------------------------------
/* {Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Henrique Pereira
@since 20/03/2017
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		as object
Local oStruT67	as object
Local oStruT68	as object
Local oStruT69	as object
Local oStruT6A	as object
Local oView		as object
Local nOperation	:= 0

oModel		:=	FWLoadModel( "TAFA471" )
oStruT67	:=	FWFormStruct( 2, "T67" )
oStruT68	:=	FWFormStruct( 2, "T68" )
oStruT69	:=	FWFormStruct( 2, "T69" )
oStruT6A	:=	FWFormStruct( 2, "T6A" )

oView		:=	FWFormView():New()

oView:SetModel( oModel )

nOperation	:= oModel:GetOperation()
 
oStruT67:RemoveField( "T67_ID" )
oStruT68:RemoveField( "T68_ID" )
oStruT69:RemoveField( "T69_ID" )
oStruT69:RemoveField( "T69_IDJPAI" )
oStruT6A:RemoveField( "T6A_ID" )

oView:AddField( 'VIEW_T67' ,oStruT67 , 'MODEL_T67' )

oView:AddGrid( 'VIEW_T6A' ,oStruT6A , 'MODEL_T6A' )
oView:AddIncrementField( 'VIEW_T6A', 'T6A_INCREM' )

oView:AddGrid( 'VIEW_T68', oStruT68, 'MODEL_T68' )
oView:EnableTitleView( 'VIEW_T68', STR0003 ) //Declaração País-a-País

oView:AddGrid( 'VIEW_T69', oStruT69, 'MODEL_T69' )
oView:EnableTitleView( 'VIEW_T69', STR0004 ) //Declaração País-a-País – Entidades Integrantes
oView:AddIncrementField( 'VIEW_T69', 'T69_INCREM' )

oView:CreateHorizontalBox( 'PAINEL_ABAS', 100 )
oView:CreateFolder( 'FOLDER_GERAL', 'PAINEL_ABAS' )
oView:AddSheet( 'FOLDER_GERAL', 'ABA01', STR0002 )
oView:AddSheet( 'FOLDER_GERAL', 'ABA02', STR0005 )

//ABA01
oView:CreateHorizontalBox( 'FIELDST67', 50,,,'FOLDER_GERAL','ABA01' )
oView:CreateHorizontalBox( 'GRIDT68', 25,,,'FOLDER_GERAL','ABA01' )
oView:CreateHorizontalBox( 'GRIDT69', 25,,,'FOLDER_GERAL','ABA01' )

//ABA02
oView:CreateHorizontalBox( 'FIELDST6A', 100,,, 'FOLDER_GERAL', 'ABA02' )

oView:SetOwnerView( 'VIEW_T67', 'FIELDST67' )
oView:SetOwnerView( 'VIEW_T68', 'GRIDT68' )
oView:SetOwnerView( 'VIEW_T69', 'GRIDT69' )
oView:SetOwnerView( 'VIEW_T6A', 'FIELDST6A' )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados.

@Param  oModel -> Modelo de dados

@Return .T.

@Author Henrique Pereira
@Since 20/03/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )
Local nOperation	:= oModel:GetOperation()

Begin Transaction
	If nOperation == MODEL_OPERATION_UPDATE
		//Funcao responsavel por setar o Status do registro para Branco
		TAFAltStat( "T67", " "  )		
	EndIf
 
 	FwFormCommit( oModel )

End Transaction

Return( .T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Funcao Para validação do modelo T67.

@Param  oModel -> Modelo de dados

@Return .T.

@Author Henrique Pereira
@Since 20/03/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel(oModel)
Local nOperation	:= oModel:GetOperation()
Local lRet			:= .T.

Begin Transaction
	If nOperation == MODEL_OPERATION_INSERT
	 	If T67->(DbSeek(xFilial('T67')))
	 		Help(,,STR0009,, STR0010, 1, 0 ) 
			lRet := .F.
		EndIf
	EndIf 
End Transaction

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf471Vld

Funcao que valida os dados do Bloco.

lJob - Informa se foi chamado por Job

@return .T.

@author Henrique Pereira	
@since 28/03/2017
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function Taf471Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro	:= {}
Local cTINMemory	:= ""
Local cIdMemry	:= "" 
Local cJurCon		:= Iif(!Empty(T67->T67_IDJURC),POSICIONE("C08",3,XFILIAL("C08")+T67->T67_IDJURC,"C08_JURIDI"),"")
Local cJurSub		:= Iif(!Empty(T67->T67_IDJURS),POSICIONE("C08",3,XFILIAL("C08")+T67->T67_IDJURS,"C08_JURIDI"),"")
Local cJurTin		:= Iif(!Empty(T69->T69_IDJRTI),POSICIONE("C08",3,XFILIAL("C08")+T69->T69_IDJRTI,"C08_JURIDI"),"")
Local cJurNi		:= Iif(!Empty(T69->T69_IDJRNI),POSICIONE("C08",3,XFILIAL("C08")+T69->T69_IDJRNI,"C08_JURIDI"),"")
Local aAreaT69 	:= {}
Local lErroT67	:= .F.
Local lErroT68	:= .F.
Local lErroT69	:= .F.
Local nX			:= 0
Default lJob 		:= .F.
		
				// Validações W100
				// T67_NCONTR - NOME_CONTROLADORA
		If T67->T67_IDCONT == '2' .And. Empty(T67->T67_NCONTR)
			Aadd( aLogErro, { "T67_NCONTR", "000001", "T67", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."
		EndIf
		If T67->T67_IDCONT == '1' .And. !Empty(T67->T67_NCONTR)
			Aadd( aLogErro, { "T67_NCONTR", "000263", "T67", nRecno } ) //STR0263 - "Se o Campo W100.IND_CONTROLADORA é igual a “S” (Sim) o Campo NOME_CONTROLADORA não deve ser preecnhido."
		EndIf
				
				// T67_JURCON - JURISIDICAO_CONTROLADORA
		If T67->T67_IDCONT == '2' .And. Empty(cJurCon)
			Aadd( aLogErro, { "T67_JURCON", "000001", "T67", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."
		EndIf
		If T67->T67_IDCONT == '1' .And. !Empty(cJurCon)
			Aadd( aLogErro, { "T67_JURCON", "000264", "T67", nRecno } ) //000264 - "Se o Campo W100.IND_CONTROLADORA é igual a “S” (Sim) o Campo JURISDICAO_CONTROLADORA não deve estar preecnhido."
		EndIf
				
				// T67_TIN - TIN_CONTROLADORA
		If T67->T67_IDCONT == '2' .And. Empty(T67->T67_TIN)
			Aadd( aLogErro, { "T67_TIN", "000001", "T67", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."
		EndIf
		If T67->T67_IDCONT == '1' .And. !Empty(T67->T67_TIN)
			Aadd( aLogErro, { "T67_TIN", "000265", "T67", nRecno } ) //STR0265 - "Se o Campo W100.IND_CONTROLADORA é igual a "S" (Sim) o Campo TIN_CONTROLADORA não deve estar preecnhido."
		EndIf
		If cJurCon == 'BR' .And. !CGC(T67->T67_TIN)
			Aadd( aLogErro, { "T67_TIN", "000266", "T67", nRecno } ) //STR0266 - "Se o Campo JURISDICAO_CONTROLADORA é igual a "BR" o Campo TIN_CONTROLADORA deve estar preecnhido com um CNPJ."
		EndIf
		If cJurCon == 'BR' .And. CGC(T67->T67_TIN)
			If SubStr(T67->T67_TIN,1,8) <> SubStr(SM0->M0_CGC,1,8)
				Aadd( aLogErro, { "T67_TIN", "000291", "T67", nRecno } )//STR0291 - Se o campo W100.JURISDICAO_CONTROLADORA for igual a "BR" (Brasil), o campo W100.TIN_CONTROLADORA deve conter o CNPJ básico igual ao o informado em 0000.CNPJ.
			EndIf
		EndIf
				
				// T67_IENTRG - IND_ENTREGA
		If !Empty(T67->T67_IDCONT) .And. Empty(T67->T67_IENTRG)
			Aadd( aLogErro, { "T67_IENTRG", "000001", "T67", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."
		EndIf
		If Empty(T67->T67_IDCONT) .And. !Empty(T67->T67_IENTRG)
			Aadd( aLogErro, { "T67_IENTRG", "000267", "T67", nRecno } ) //STR0267 - Se o campo W100.IND_CONTROLADORA não estiver preenchido, o campo W100.IND_ENTREGA não deve estar preenchido.
		EndIf
		If T67->T67_IENTRG == "2" .And. cJurCon <> "BR" .AND. Empty(cJurCon) //Se cJurCon for vazio, logo o país não consta na tabela de Acordo de Autoridades Competentes
		   Aadd( aLogErro, { "T67_IENTRG", "000323", "T67", nRecno } ) //STR0323 - "Se W100.IND_ENTREGA for igual a “1” e W100.JURISDICAO_CONTROLADORA for diferente de “Brasil”, o país informado no campo W100.JURISDICAO_CONTROLADORA deve constar na tabela de Acordo de Autoridades Competentes"
		EndIf
		If T67->T67_IENTRG == "2" .And. cJurCon <> "BR" .AND. cJurCon $ "ES|AF" // Até o momoento a tabela de falha sistemica só possui essas dias Jurisdições
		   Aadd( aLogErro, { "T67_IENTRG", "000324", "T67", nRecno } ) //STR0324 - "Se W100.IND_ENTREGA for igual a “1” e W100.JURISDICAO_CONTROLADORA for diferente de “Brasil”, o país informado no campo W100.JURISDICAO_CONTROLADORA não deve constar na tabela de falhas sistemicas"
		EndIf
		If cJurCon == 'BR' .And. !T67->T67_IENTRG $ '1|2'
			Aadd( aLogErro, { "T67_IENTRG", "000268", "T67", nRecno } ) // STR0268 Se W100.JURISDICAO_CONTROLADORA for igual a “BR” (Brasil), o campo W100.IND_ENTREGA deve ser igual a "1" ou "2"
		EndIf
		If T67->T67_IDCONT == "1" .And. !T67->T67_IENTRG $ '1|2'
			Aadd( aLogErro, { "T67_IENTRG", "000269", "T67", nRecno } ) //STR0269 Se W100.IND_CONTROLADORA  for igual a "S-Sim", o campo W100.IND_ENTREGA deve ser igual a "1" ou "2"
		EndIf
				
				// T67_INDMOD - IND_MODALIDADE
		If T67->T67_IENTRG $ "3|4" .And. Empty(T67->T67_INDMOD)
			Aadd( aLogErro, { "T67_INDMOD", "000270", "T67", nRecno } )// STR0270 Se o campo W100.IND_ENTREGA for igual a "3" (Própria entidade declarante) ou "4" (Outra entidade), o campo W100.IND_MODALIDADE deve estar preenchido.
		EndIf
		If T67->T67_IENTRG == "1" .And. !Empty(T67->T67_INDMOD)
			Aadd( aLogErro, { "T67_INDMOD", "000271", "T67", nRecno } )// STR0271 Se o campo W100.IND_ENTREGA for igual "1" o campo W100.IND_MODALIDADE não deve estar preenchido.
		EndIf
				
				//T67_SUBSTI - NOME_SUBSTITUTA
		If T67->T67_IENTRG == "4" .And. Empty(T67->T67_SUBSTI)
			Aadd( aLogErro, { "T67_SUBSTI", "000272", "T67", nRecno } )// STR0272 Se o campo W100.IND_ENTREGA for igual a "4" (Outra entidade), o campo W100.NOME_SUBSTITUTA deve estar preenchido.
		EndIf
		If T67->T67_IENTRG <> "4" .And. !Empty(T67->T67_SUBSTI)
			Aadd( aLogErro, { "T67_SUBSTI", "000273", "T67", nRecno } )// STR0273 Se o campo W100.IND_ENTREGA for diferente de "4" (Outra entidade), o campo W100.NOME_SUBSTITUTA não deve estar preenchido.
		EndIf
				
				// T67_JURSUB - JURISDICAO_SUBSTITUTA
		If T67->T67_IENTRG == "4" .And. Empty(cJurSub)
			Aadd( aLogErro, { "T67_JURSUB", "000274", "T67", nRecno } )// STR0274 Se o campo W100.IND_ENTREGA for igual a "4" (Outra entidade), o campo W100.JURISDICAO_SUBSTITUTA deve estar preenchido.
		EndIf
		If T67->T67_IENTRG <> "4" .And. !Empty(cJurSub)
			Aadd( aLogErro, { "T67_JURSUB", "000275", "T67", nRecno } )// STR0275 Se o campo W100.IND_ENTREGA divferente de "4" (Outra entidade), o campo W100.JURISDICAO_SUBSTITUTA não deve estar preenchido.
		EndIf
		If (T67->T67_IENTRG == "4" .And. T67->T67_INDMOD == '2')
			If cJurSub <> "BR"
				Aadd( aLogErro, { "T67_JURSUB", "000276", "T67", nRecno } ) // STR0276 Se o campo W100.IND_ENTREGA for igual a "4" (Outra entidade) e W100.IND_MODALIDADE for igual a "2" (Preenchimento local), o W100.JURISDICAO_SUBSTITUTA deve ser igual a "BR" Brasil.
			EndIf
		EndIf
		If T67->T67_IENTRG == "4" .And. T67->T67_INDMOD == '2' .And. cJurSub <> "BR" 
			If Empty(cJurSub) // Se cJurSub vazio, logo não consta na tabela de Acordo de Autoridades Competentes
				Aadd( aLogErro, { "T67_JURSUB", "000325", "T67", nRecno } ) // STR0325 Se o campo W100.IND_ENTREGA for igual a "4" (Outra entidade) e W100.IND_MODALIDADE for igual a "1" (Entidade substituta) e o W100.JURISDICAO_SUBSTITUTA for diferente de "Brasil", o país informado no campo W100.JURISDICAO_SUBSTITUTA deve constar na tabela de Acordo de Autoridades Competentes
			EndIf
			If cJurSub $ 'ES|AF' // Até o momento a Tabela de falha sistemica só possui essas duas jurisdições 
				 Aadd( aLogErro, { "T67_JURSUB", "000326", "T67", nRecno } ) // STR0326 Se o campo W100.IND_ENTREGA for igual a "4" (Outra entidade) e W100.IND_MODALIDADE for igual a "1" (Entidade substituta) e o W100.JURISDICAO_SUBSTITUTA for diferente de "Brasil", o país informado no campo W100.JURISDICAO_SUBSTITUTA não deve constar na tabela de Falha Sisitemica
			EndIf
		EndIf				
				// T67_TINSUB - TIN_SUBSTITUTA 
		If T67->T67_IENTRG == "4" .And. cJurSub == "BR"
			If Empty(T67->T67_TINSUB)
				Aadd( aLogErro, { "T67_TINSUB", "000277", "T67", nRecno } ) // STR0277 Se o campo W100.IND_ENTREGA for igual a "4" (Outra entidade) e W100.JURISDICAO_SUBSTITUTA for igual a "Brasil", o campo W100.TIN_SUBSTITUTA deve estar preenchido.
			EndIf
		EndIf
		If T67->T67_IENTRG <> "4" .Or. (cJurSub <> "BR" .And. !Empty(cJurSub))
			If Empty(T67->T67_TINSUB)
				Aadd( aLogErro, { "T67_TINSUB", "000278", "T67", nRecno } ) // STR0278 Se o campo W100.IND_ENTREGA for diferente de "4" (Outra entidade) ou W100.JURISDICAO_SUBSTITUTA for diferente de “Brasil”, o campo W100.TIN_SUBSTITUTA não deve estar preenchido.
			EndIf
		EndIf
		If cJurCon == "BR" .And. !CGC(T67->T67_TINSUB)
			Aadd( aLogErro, { "T67_TINSUB", "000001", "T67", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."
		EndIf
		If cJurCon == "BR" .And. CGC(T67->T67_TINSUB)
			If SubStr(T67->T67_TINSUB,1,8) <> SubStr(SM0->M0_CGC,1,8)
				Aadd( aLogErro, { "T67_TINSUB", "000279", "T67", nRecno } ) // STR0279 Se o campo W100.JURISDICAO_CONTROLADORA for igual a "BR" (Brasil), e o campo W100.TIN_SUBSTITUTA estiver preenchido com um CNPJ. O CNPJ básico informado deve ser igual ao CNPJ básico do declarante da ECF, informado em 0000.CNPJ.
			EndIf
		EndIf
				
				// T67_DTINI - DT_INI 
		If (T67->T67_IDCONT == '1' .And. T67->T67_IENTRG == '2') .Or. ( T67->T67_IENTRG == '3' .And. Empty(T67->T67_INDMOD))
			If Empty(T67_DTINI)
				Aadd( aLogErro, { "T67_DTINI", "000280", "T67", nRecno } ) // Se o campo [W100.IND_CONTROLADORA seja igual a "S" (Sim) e W100.IND_ENTREGA seja igual a "2" (Controladora final do grupo multinacional)] ou [W100.IND_ENTREGA é igual a “3” (Própria entidade declarante da ECF) e W100.IND_MODALIDADE está preenchido], se o campo W100.DT_INI está preenchido
			EndIf
		EndIf
				
		If (T67->T67_IDCONT == '2' .Or. T67->T67_IENTRG <> '2') .And. ( T67->T67_IENTRG <> '3' .Or. Empty(T67->T67_INDMOD))
			If !Empty(T67_DTINI)
				Aadd( aLogErro, { "T67_DTINI", "000281", "T67", nRecno } ) // Se o campo [W100.IND_CONTROLADORA for igual a "N" (Não) ou W100.IND_ENTREGA for diferente de "2"] e [W100.IND_ENTREGA for diferente de "3" (Própria entidade declarante da ECF) ou W100.IND_MODALIDADE não estiver preenchido], se o campo W100.DT_INI não deve estar preenchido.
			EndIf
		EndIf
		If (T67_DTFIM - T67_DTINI) > 366
			Aadd( aLogErro, { "T67_DTINI", "000282", "T67", nRecno } ) // STR0282 Se a a diferença entre W100.DT_FIN e W100.DT_INI não pode ser maior que 366 dias (O período da Declaração País-a-País deve ser menor ou igual a 1 ano).
		EndIf
				
				//T67_DTFIM - DT_FIM
		If T67->T67_IDCONT == '1' .Or. (T67->T67_IENTRG == '3' .And. !Empty(T67->T67_INDMOD))
			If Empty(T67_DTFIM)
				Aadd( aLogErro, { "T67_DTFIM", "000283", "T67", nRecno } ) //Se o campo W100.IND_CONTROLADORA for igual a "S" (Sim) ou [W100.IND_ENTREGA for igual a "3" (Própria entidade declarante da ECF) e W100.IND_MODALIDADE está preenchido], se o campo W100.DT_FIN está preenchido.
			EndIf
		EndIf
		If T67->T67_IDCONT == '2' .And. (T67->T67_IENTRG <> '3' .Or. Empty(T67->T67_INDMOD))
			If !Empty(T67_DTFIM)
				Aadd( aLogErro, { "T67_DTFIM", "000284", "T67", nRecno } ) //Se o campo W100.IND_CONTROLADORA estiver igual a "N" (Não) e [W100.IND_ENTREGA for diferente de "3" (Própria entidade declarante da ECF) ou W100.IND_MODALIDADE não estiver preenchido], o campo W100.DT_FIN não deve estar preenchido.
			EndIf
		EndIf
		If T67_DTFIM <= T67_DTINI
			Aadd( aLogErro, { "T67_DTFIM", "000285", "T67", nRecno } ) // O campo W100.DT_FIN deve ser maior ou igual a W100.DT_INI
		EndIf
				
				//T67_MOEDA - TIP_MOEDA
		If T67->T67_IDCONT == '1' .Or. ( T67->T67_IENTRG == '3' .And. !Empty(T67->T67_INDMOD))
			If Empty(T67->T67_MOEDA)
				Aadd( aLogErro, { "T67_MOEDA", "000286", "T67", nRecno } )// Se o campo W100.IND_CONTROLADORA for igual a "S" (Sim) ou (W100.IND_ENTREGA for igual a "3" (Própria entidade declarante da ECF) e W100.IND_MODALIDADE estiver preenchido), o campo W100.TIP_MOEDA deve estar preenchido.
			EndIf
		EndIf
		If T67->T67_IDCONT == '2' .Or. ( T67->T67_IENTRG <> '3' .And. Empty(T67->T67_INDMOD))
			If !Empty(T67->T67_MOEDA)
				Aadd( aLogErro, { "T67_MOEDA", "000287", "T67", nRecno } )// Se o campo W100.IND_CONTROLADORA for igual a "N" (Não) ou (W100.IND_ENTREGA for diferente de "3" (Própria entidade declarante da ECF) e W100.IND_MODALIDADE estiver vazio), o campo W100.TIP_MOEDA não deve estar preenchido.
			EndIf
		EndIf
				
				// T67_IDIOMA - IND_IDIOMA
		If T67->T67_IDCONT == '1' .Or. ( T67->T67_IENTRG == '3' .And. !Empty(T67->T67_INDMOD))
			If Empty(T67->T67_IDIOMA)
				Aadd( aLogErro, { "T67_IDIOMA", "000288", "T67", nRecno } )// STR0288 - Se o campo W100.IND_CONTROLADORA for igual a "S" (Sim) ou (W100.IND_ENTREGA for igual a "3" (Própria entidade declarante da ECF) e W100.IND_MODALIDADE estiver preenchido), o campo W100.IND_IDIOMA deve estar preenchido.
			EndIf
		EndIf
		If T67->T67_IDCONT == '2' .Or. ( T67->T67_IENTRG <> '3' .And. Empty(T67->T67_INDMOD))
			If !Empty(T67->T67_INDMOD)
				Aadd( aLogErro, { "T67_INDMOD", "000289", "T67", nRecno } )// STR0289 - Se o campo W100.IND_CONTROLADORA for igual a "N" (Não) ou (W100.IND_ENTREGA for diferente de "3" (Própria entidade declarante da ECF) e W100.IND_MODALIDADE estiver vazio), o campo W100.IND_IDIOMA não deve estar preenchido.
			EndIf
		EndIf				
				// Validações W200
				// T68_VLRECE - VL_REC_NAO_REL_EST
				// A regra baaixo está comentada pelo motivo da tabela de moedas estar inconsistente no manual.
		/*If T67->T67_MOEDA <> 'R$' .And. Empty(T68-> T68_VLRECE)
			Aadd( aLogErro, { "T68_VLRECE", "000290", "T68", nRecno } ) //STR0290 - Se o campo W100.TIP_MOEDA for diferente de "Reais", o campo W200.VL_REC_NAO_REL_EST deve estar preenchido.
		EndIf
		If T67->T67_MOEDA == 'R$' .And. !Empty(T68-> T68_VLRECE)
			Aadd( aLogErro, { "T68_VLRECE", "000292", "T68", nRecno } ) //STR0292 - Se o campo W100.TIP_MOEDA for igual a "Reais", o campo W200.VL_REC_NAO_REL_EST não deve estar preenchido.
		EndIf*/
				
				//T68_VLRELE - VL_REC_REL_EST
		/*If T67->T67_MOEDA <> 'R$'.And. Empty(T68->T68_VLRELE)
			Aadd( aLogErro, { "T68_VLRELE", "000306", "T68", nRecno } ) // STR0306 - Se o campo W100.TIP_MOEDA for diferente de "Reais", o campo W200.VL_REC_REL_EST deve estar preenchido.
		EndIf
		If T67->T67_MOEDA == 'R$'.And. !Empty(T68->T68_VLRELE)
			Aadd( aLogErro, { "T68_VLRELE", "000293", "T68", nRecno } ) // STR0293 - Se o campo W100.TIP_MOEDA for igual a "Reais", o campo W200.VL_REC_REL_EST não deve estar preenchido.
		EndIf*/
				
				// T68_VLTOTE - VL_REC_TOTAL_EST
		If (T68->T68_VLRECE + T68->T68_VLRELE) <> T68->T68_VLTOTE
			Aadd( aLogErro, { "T68_VLTOTE", "000294", "T68", nRecno } ) // STR0294 - O campo W200.VL_REC_TOTAL_EST deve ser igual ao somatório dos campos W200.VL_REC_NAO_REL_EST e W200.VL_REC_REL_EST.
		EndIf
				
				// T68_VLTOTA - VL_REC_TOTAL
		If (T68->T68_VLRECE + T68->T68_VLRELE) <> T68->T68_VLTOTA
			Aadd( aLogErro, { "T68_VLTOTA", "000295", "T68", nRecno } ) // STR0295 - O campo W200.VL_REC_TOTAL deve ser igual ao somatório dos campos W200.VL_REC_NAO_REL_EST e W200.VL_REC_REL_EST.
		EndIf
				
				// T68_LPESTR - VL_LUC_PREJ_ANTES_IR_EST
		/*If T67->T67_MOEDA <> 'R$'.And. Empty(T68->T68_LPESTR)
			Aadd( aLogErro, { "T68_LPESTR", "000296", "T68", nRecno } ) // STR0296 - Se o campo W100.TIP_MOEDA for diferente de "Reais", o campo W200.VL_LUC_PREJ_ANTES_IR_EST deve estar preenchido.
		EndIf
		If T67->T67_MOEDA == 'R$'.And. !Empty(T68->T68_LPESTR)
			Aadd( aLogErro, { "T68_LPESTR", "000297", "T68", nRecno } ) // Se o campo W100.TIP_MOEDA for igual a "Reais", o campo W200.VL_LUC_PREJ_ANTES_IR_EST não deve estar preenchido.
		EndIf*/
				
				// T68_IRESTR - VL_IR_PAGO_EST
		/*If T67->T67_MOEDA <> 'R$'.And. Empty(T68->T68_IRESTR)
			Aadd( aLogErro, { "T68_IRESTR", "000298", "T68", nRecno } ) // Se o campo W100.TIP_MOEDA for diferente de "Reais"”,  o campo W200.VL_IR_PAGO_EST deve estar preenchido.
		EndIf
		If T67->T67_MOEDA == 'R$'.And. !Empty(T68->T68_IRESTR)
			Aadd( aLogErro, { "T68_IRESTR", "000299", "T68", nRecno } ) // Se o campo W100.TIP_MOEDA for igual a "Reais"”, o campo W200.VL_IR_PAGO_EST não deve estar preenchido.
		EndIf*/
				
				// T68_IRDEVE - VL_IR_DEVIDO_EST	
		/*If T67->T67_MOEDA <> 'R$'.And. Empty(T68->T68_IRDEVE)
			Aadd( aLogErro, { "T68_IRDEVE", "000300", "T68", nRecno } ) // Se o campo W100.TIP_MOEDA for diferente de "Reais", o campo W200.VL_IR_DEVIDO_EST deve estar preenchido.
		EndIf
		If T67->T67_MOEDA == 'R$'.And. !Empty(T68->T68_IRDEVE)
			Aadd( aLogErro, { "T68_IRDEVE", "000301", "T68", nRecno } ) // Se o campo W100.TIP_MOEDA for igual a "Reais", o campo W200.VL_IR_DEVIDO_EST não deve estar preenchido.
		EndIf*/
				
				// T68_CPSOCE - VL_CAP_SOC_EST
		/*If T67->T67_MOEDA <> 'R$' .And. Empty(T68->T68_CPSOCE)
			Aadd( aLogErro, { "T68_IRDEVE", "000302", "T68", nRecno } )// Se o campo W100.TIP_MOEDA for diferente de "Reais", o campo W200.VL_CAP_SOC_EST deve estar preenchido.
		EndIf
		If T67->T67_MOEDA == 'R$' .And. !Empty(T68->T68_CPSOCE)
			Aadd( aLogErro, { "T68_IRDEVE", "000303", "T68", nRecno } )// Se o campo W100.TIP_MOEDA for igual a "Reais", o campo W200.VL_CAP_SOC_EST não deve estar preenchido.
		EndIf*/
				
				// T68_LACUME - VL_LUC_ACUM_EST 		
		/*If T67->T67_MOEDA <> 'R$' .And. Empty(T68->T68_LACUME)
			Aadd( aLogErro, { "T68_LACUME", "000304", "T68", nRecno } ) // Se o campo W100.TIP_MOEDA for diferente de "Reais", se o campo W200.VL_LUC_ACUM_EST deve estar preenchido.
		EndIf
		If T67->T67_MOEDA == 'R$' .And. !Empty(T68->T68_LACUME)
			Aadd( aLogErro, { "T68_LACUME", "000305", "T68", nRecno } ) // Se o campo W100.TIP_MOEDA for igual a "Reais", o campo W200.VL_LUC_ACUM_EST não deve estar preenchido.
		EndIf*/
				
				// T68_ATVTES - VL_ATIV_TANG_EST
		/*If T67->T67_MOEDA <> 'R$' .And. Empty(T68->T68_ATVTES)
			Aadd( aLogErro, { "T68_ATVTES", "000306", "T68", nRecno } ) // Se o campo W100.TIP_MOEDA for diferente de "Reais", o campo W200.VL_ATIV_TANG_EST deve estar preenchido.
		EndIf
		If T67->T67_MOEDA == 'R$' .And. !Empty(T68->T68_ATVTES)
			Aadd( aLogErro, { "T68_ATVTES", "000307", "T68", nRecno } ) // Se o campo W100.TIP_MOEDA for igual a "Reais", o campo W200.VL_ATIV_TANG_EST não deve estar preenchido.
		EndIf*/
				
				
				// Validações W250
				// T69_TIN - TIN
		cTINMemory	:= T69->T69_TIN
		cIdMemry	:= T69->T69_ID
		aAreaT69 	:= T69->(GETAREA())
		T69->(DbGoTop())
		While !T69->(Eof())
			If Alltrim(T69->T69_TIN) <> "NOTIN"
				T69->(DbSetOrder(2))
				aAreaT69 := T69->(GETAREA())
				If T69->( MsSeek( xFilial( "T69" ) + cTINMemory ) ) .And. T69->T69_ID <> cIdMemry
					Aadd( aLogErro, { "T69_TIN", "000308", "T69", nRecno } ) //	Deve existir apenas 1 registro W250 com o TIN informado em W250.TIN. A regra não é executada caso W250.TIN seja igual a “NOTIN”.
				EndIf
				T69->(RESTAREA(aAreaT69))
			EndIf
			T69->(DbSkip())
		EndDo
		T69->(RESTAREA(aAreaT69))
		aAreaT69 := {}
		If cJurTin == "BR" .And. !CGC(T69->T69_TIN)
			Aadd( aLogErro, { "T69_TIN", "000309", "T69", nRecno } ) // Se o campo W250.JURISDICAO_TIN for igual a "BR" (Brasil),  o campo W250.TIN deve conter um  CNPJ válido.
		EndIf
				
				// T69_JURTIN - JURISDICAO_TIN
		If Alltrim(T69->T69_TIN) <> "NOTIN" .And. Empty(cJurTin)
			Aadd( aLogErro, { "T69_JURTIN", "000310", "T69", nRecno } ) // Se o campo for W250.TIN for diferente de "NOTIN", o campo W250.JURISDICAO_TIN deve estar com conteúdo
		EndIf
		If Alltrim(T69->T69_TIN) == "NOTIN" .And. !Empty(cJurTin)
			Aadd( aLogErro, { "T69_JURTIN", "000311", "T69", nRecno } ) // Se o campo for W250.TIN for igual "NOTIN", o campo W250.JURISDICAO_TIN não deve estar com preenchido
		EndIf
				
				// T69_NI - JURISDICAO_NI
		If !Empty(T69->T69_NI) .And. Empty(cJurNi)
			Aadd( aLogErro, { "T69_NI", "000312", "T69", nRecno } ) // Se o campo W250.NI estiver preenchido,  o campo W250.JURISDICAO_NI também deve estar preenchido.
		EndIf
		If Empty(T69->T69_NI) .And. !Empty(cJurNi)
			Aadd( aLogErro, { "T69_NI", "000313", "T69", nRecno } ) // Se o campo W250.NI não estiver preenchido,  o campo W250.JURISDICAO_NI também não deve estar preenchido.
		EndIf
				
				// T69_TIPONI - TIPO_NI
		If !Empty(T69->T69_NI) .And. Empty(T69->T69_TIPONI)
			Aadd( aLogErro, { "T69_TIPONI", "000314", "T69", nRecno } ) // Se o campo W250.NI estiver preenchido, o campo W250.TIPO_NI deve estar preenchido
		EndIf
		If Empty(T69->T69_NI) .And. !Empty(T69->T69_TIPONI)
			Aadd( aLogErro, { "T69_TIPONI", "000315", "T69", nRecno } ) // Se o campo W250.NI não estiver preenchido, o campo W250.TIPO_NI não deve estar preenchido
		EndIf
				
				// T69_OBSERV - DESC_OUTROS
		If T69->T69_ATIV_13 == "1" .And. Empty(T69->T69_OBSERV)
			Aadd( aLogErro, { "T69_OBSERV", "000316", "T69", nRecno } ) // Se o campo W250.ATIV_13 for igual a "S" (Sim), o campo W250.DESC_OUTROS deve estar preenchido.
		EndIf
		If T69->T69_ATIV_13 == "2" .And. !Empty(T69->T69_OBSERV)
			Aadd( aLogErro, { "T69_OBSERV", "000317", "T69", nRecno } ) // Se o campo W250.ATIV_13 for igual a "N" (Não), o campo W250.DESC_OUTROS não deve estar preenchido.
		EndIf
		
		// Tratamento do Status de validação do registro, 0 = registro Válido; 1 = Registro Inváliso
		If Len(aLogErro) > 0 
			If T67->T67_STATUS <> '1'
				TAFAltStat( "T67", "1" )
			EndIf
			lErroT67 := .T.
		EndIf
		If !lErroT67 .And. T67->T67_STATUS <> "0"
			TAFAltStat( "T67", "0" )
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Não apresento o alert quando utilizo o JOB para validar³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lJob
			VldECFLog(aLogErro)
		EndIf
Return(aLogErro)