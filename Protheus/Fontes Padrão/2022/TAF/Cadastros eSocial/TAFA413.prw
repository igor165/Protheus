#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA413.CH"

Static lTAFCodRub   := FindFunction("TAFCodRub")
Static cEvtPosic    := ""
Static lTAUTO       := .F.
Static lLaySimplif  := TafLayESoc()
Static lSimplBeta   := TafLayESoc("S_01_01_00",, .T.)
Static __cPicVAdv   := Nil
Static __cPicVCus   := Nil
Static __cPicQRRA   := Nil
Static cXmlInteg	:= ""
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA413
S-1202 - Remuneração de servidor vinculado a Regime Próprio de Previd. Social

@author Vitor Siqueira
@since 08/01/2016
@version 1.0

/*/ 
//------------------------------------------------------------------
Function TAFA413()

	Private oBrw		:= FWmBrowse():New()
	Private cNomEve		:= "S1202"
	
	If TafAtualizado(,"TAFA413")
		TafNewBrowse( "S-1202", , , , STR0001, , 2, 2 )
	EndIf

	oBrw:SetCacheView( .F. )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Vitor Siqueira
@since 08/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	If FindFunction("FilCpfNome") .And. GetSx3Cache("C91_CPFV","X3_CONTEXT") == "V" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES");
	 .And. !FwIsInCallStack("xNewHisAlt")

		ADD OPTION aRotina TITLE "Visualizar" ACTION "TAF413View('C91',RECNO())" OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Incluir"    ACTION "TAF413Inc('C91',RECNO())"  OPERATION 3 ACCESS 0 //'Incluir'
		ADD OPTION aRotina TITLE "Alterar"    ACTION "xTafAlt('C91', 0 , 0)"     OPERATION 4 ACCESS 0 //'Alterar'
		ADD OPTION aRotina TITLE "Imprimir"	  ACTION "VIEWDEF.TAFA413"			 OPERATION 8 ACCESS 0 //'Imprimir'

	Else

		Aadd( aFuncao, { "" , "TafxmlRet('TAF413Xml','1202','C91')" 								, "1" } )
		Aadd( aFuncao, { "" , "xFunHisAlt( 'C91', 'TAFA413' ,,,, 'TAF413XML','1202'  )"				, "3" } )
		Aadd( aFuncao, { "" , "TAFXmlLote( 'C91', 'S-1202' , 'evtRmnRPPS' , 'TAF413Xml',, oBrw )" 	, "5" } )
		Aadd( aFuncao, { "" , "xFunAltRec( 'C91' )" 												, "10"} )

		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If lMenuDif
			ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA413' OPERATION 2 ACCESS 0
		Else
			aRotina	:=	xFunMnuTAF( "TAFA413" , , aFuncao)
		EndIf

	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Vitor Siqueira
@since 08/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel   as object
	Local oStruT14 as object
	Local oStruT61 as object
	Local oStruT6C as object
	Local oStruT6D as object
	Local oStruT6E as object
	Local oStruT6H as object
	Local oStruT6I as object
	Local oStruT6J as object
	Local oStruT6K as object
	Local oStruV9L as object

	oModel   := MPFormModel():New('TAFA413', , {|oModel| ValidModel(oModel)} , {|oModel| SaveModel(oModel)})
	oStruC91 := FWFormStruct( 1, 'C91' )
	oStruT14 := FWFormStruct( 1, 'T14' )
	oStruT61 := FWFormStruct( 1, 'T61' )
	oStruT6C := FWFormStruct( 1, 'T6C' )
	oStruT6D := FWFormStruct( 1, 'T6D' )
	oStruT6E := FWFormStruct( 1, 'T6E' )
	oStruT6H := FWFormStruct( 1, 'T6H' )
	oStruT6I := FWFormStruct( 1, 'T6I' )
	oStruT6J := FWFormStruct( 1, 'T6J' )
	oStruT6K := FWFormStruct( 1, 'T6K' )
	oStruV9L := FWFormStruct( 1, 'V9L' )

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If TafColumnPos("T6E_DTRABA")
		oStruT6D:SetProperty("T6D_DTRABA", MODEL_FIELD_OBRIGAT, .F.)
		oStruT6J:SetProperty("T6J_DTRABA", MODEL_FIELD_OBRIGAT, .F.) 
	EndIf
	
	oStruT6D:SetProperty("T6D_CODCAT", MODEL_FIELD_OBRIGAT, .F.)
	oStruT6D:SetProperty("T6D_IDTRAB", MODEL_FIELD_OBRIGAT, .F.)
	oStruT6J:SetProperty("T6J_CODCAT", MODEL_FIELD_OBRIGAT, .F.)
	oStruT6J:SetProperty("T6J_IDTRAB", MODEL_FIELD_OBRIGAT, .F.) 
	oStruT61:SetProperty("T61_DTLEI" , MODEL_FIELD_OBRIGAT, .F.) 
	oStruT61:SetProperty("T61_NUMLEI", MODEL_FIELD_OBRIGAT, .F.)	
	
	oStruC91:AddTrigger("C91_CPF" , "C91_ORIEVE",, {|| "TAUTO"})	

	If lVldModel

		oStruC91:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT6C:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT6D:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
		oStruT6E:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT14:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })	
		oStruT6H:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT6I:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 			
		oStruT6J:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
		oStruT6K:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruV9L:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		
	EndIf    

	oStruC91:SetProperty("C91_CNPJEA", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'XVldTNrIns("1", M->C91_CNPJEA)'))
	oStruC91:SetProperty("C91_CPF"   , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'XVldTNrIns("2", M->C91_CPF)'   ))    

	// INFORMAÇÕES DE IDENTIFICAÇÃO DO EVENTO 
	oModel:AddFields('MODEL_C91', /*cOwner*/, oStruC91)

	//PRIMARY KEY
	oModel:GetModel('MODEL_C91'):SetPrimaryKey({"C91_INDAPU", "C91_PERAPU", "C91_TRABAL", "C91_CPF", "C91_NOMEVE", "C91_ATIVO"})   

	// DEMONSTRATIVOS DE VALORES DEVIDOS AO TRABALHADOR 
	oModel:AddGrid('MODEL_T14', 'MODEL_C91', oStruT14)
	oModel:GetModel('MODEL_T14'):SetOptional(.T.)
	oModel:GetModel('MODEL_T14'):SetUniqueLine({'T14_IDEDMD'})
	oModel:GetModel('MODEL_T14'):SetMaxLine(999)

	// INFORMAÇÕES DO ESTABELECIMENTO/LOTAÇÃO
	oModel:AddGrid('MODEL_T6C', 'MODEL_T14', oStruT6C)
	oModel:GetModel('MODEL_T6C'):SetOptional(.T.)
	oModel:GetModel('MODEL_T6C'):SetUniqueLine({'T6C_ESTABE'})
	oModel:GetModel('MODEL_T6C'):SetMaxLine(500)

	//INFORMAÇÕES DO REMUNERAÇÃO DO PERIODO DE APURAÇÃO
	oModel:AddGrid('MODEL_T6D', 'MODEL_T6C', oStruT6D)
	oModel:GetModel('MODEL_T6D'):SetOptional(.T.)
	oModel:GetModel('MODEL_T6D'):SetMaxLine(8) 

	If TafColumnPos("T6E_DTRABA")
		oModel:GetModel('MODEL_T6D'):SetUniqueLine({'T6D_IDTRAB', 'T6D_DTRABA'})
	Else
		oModel:GetModel('MODEL_T6D'):SetUniqueLine({'T6D_IDTRAB'})
	EndIf

	//INFORMAÇÕES DOS ITENS DE REMUNERAÇÃO
	oModel:AddGrid('MODEL_T6E', 'MODEL_T6D', oStruT6E)
	oModel:GetModel('MODEL_T6E'):SetOptional(.T.)
	oModel:GetModel('MODEL_T6E'):SetUniqueLine({'T6E_IDRUBR'})
	oModel:GetModel('MODEL_T6E'):SetMaxLine(200) 

	// IDENTIFICAÇÃO DA LEI QUE DETERMINOU REMUNERAÇÃO EM PERÍODOS ANTERIORES 
	oModel:AddGrid('MODEL_T61', 'MODEL_T14', oStruT61)
	oModel:GetModel('MODEL_T61'):SetOptional(.T.)
	oModel:GetModel('MODEL_T61'):SetUniqueLine({'T61_ORGSUC'})
	oModel:GetModel('MODEL_T61'):SetMaxLine(1) 

	// INFORMAÇÕES DO PERIODO
	oModel:AddGrid('MODEL_T6H', 'MODEL_T61', oStruT6H)
	oModel:GetModel('MODEL_T6H'):SetOptional(.T.)
	oModel:GetModel('MODEL_T6H'):SetUniqueLine({'T6H_PERREF','T6H_ORGSUC'})
	oModel:GetModel('MODEL_T6H'):SetMaxLine(180) 

	// INFORMAÇÕES DO ESTABELECIMENTO/LOTAÇÃO
	oModel:AddGrid('MODEL_T6I', 'MODEL_T6H', oStruT6I)
	oModel:GetModel('MODEL_T6I'):SetOptional(.T.)
	oModel:GetModel('MODEL_T6I'):SetUniqueLine({'T6I_ESTABE','T6I_ORGSUC'})
	oModel:GetModel('MODEL_T6I'):SetMaxLine(500)

	// INFORMAÇÕES DA REMUNERAÇÃO DO TRABALHADOR
	oModel:AddGrid('MODEL_T6J', 'MODEL_T6I', oStruT6J)
	oModel:GetModel('MODEL_T6J'):SetOptional(.T.)
	oModel:GetModel('MODEL_T6J'):SetUniqueLine({'T6J_IDTRAB','T6J_CODCAT','T6J_ORGSUC'})
	oModel:GetModel('MODEL_T6J'):SetMaxLine(8) 

	// INFORMAÇÕES DOS ITENS DA REMUNERAÇÃO
	oModel:AddGrid('MODEL_T6K', 'MODEL_T6J', oStruT6K)
	oModel:GetModel('MODEL_T6K'):SetOptional(.T.)
	oModel:GetModel('MODEL_T6K'):SetUniqueLine({'T6K_IDRUBR'})
	oModel:GetModel('MODEL_T6K'):SetMaxLine(200) 

	// INFORMAÇÕES DE RRA

	If lSimplBeta .And. TafColumnPos("T14_INDRRA")
		oModel:AddGrid('MODEL_V9L', 'MODEL_T14', oStruV9L)
		oModel:GetModel('MODEL_V9L'):SetOptional(.T.)
		oModel:GetModel('MODEL_V9L'):SetUniqueLine({ "V9L_TPINSC", "V9L_NRINSC" })
		oModel:GetModel('MODEL_V9L'):SetMaxLine(99) 
	EndIf

	// RELATIONS
	oModel:SetRelation('MODEL_T14', {{'T14_FILIAL','xFilial("T14")'}, {'T14_ID','C91_ID'}, {'T14_VERSAO','C91_VERSAO'}, {'T14_INDAPU','C91_INDAPU'}, {'T14_PERAPU','C91_PERAPU'}, {'T14_TRABAL','C91_TRABAL'}}, T14->(IndexKey(1)))
	oModel:SetRelation('MODEL_T6C', {{'T6C_FILIAL','xFilial("T6C")'}, {'T6C_ID','C91_ID'}, {'T6C_VERSAO','C91_VERSAO'}, {'T6C_INDAPU','C91_INDAPU'}, {'T6C_PERAPU','C91_PERAPU'}, {'T6C_TRABAL','C91_TRABAL'}, {'T6C_DEMPAG','T14_IDEDMD'}}, T6C->(IndexKey(1)))

	If lSimplBeta .And. TafColumnPos("T14_INDRRA")
		oModel:SetRelation('MODEL_V9L', {{'V9L_FILIAL','xFilial("V9L")'}, {'V9L_ID','C91_ID'}, {'V9L_VERSAO','C91_VERSAO'}, {'V9L_INDAPU','C91_INDAPU'}, {'V9L_PERAPU','C91_PERAPU'}, {'V9L_TRABAL','C91_TRABAL'}, {'V9L_DEMPAG','T14_IDEDMD'}}, V9L->(IndexKey(1)))
	EndIf

	oModel:SetRelation('MODEL_T6D', {{'T6D_FILIAL','xFilial("T6D")'}, {'T6D_ID','C91_ID'}, {'T6D_VERSAO','C91_VERSAO'}, {'T6D_INDAPU','C91_INDAPU'}, {'T6D_PERAPU','C91_PERAPU'}, {'T6D_TRABAL','C91_TRABAL'}, {'T6D_DEMPAG','T14_IDEDMD'}, {'T6D_ESTABE','T6C_ESTABE'}}, T6D->(IndexKey(1)))  
	oModel:SetRelation('MODEL_T61', {{'T61_FILIAL','xFilial("T61")'}, {'T61_ID','C91_ID'}, {'T61_VERSAO','C91_VERSAO'}, {'T61_INDAPU','C91_INDAPU'}, {'T61_PERAPU','C91_PERAPU'}, {'T61_TRABAL','C91_TRABAL'}, {'T61_DEMPAG','T14_IDEDMD'}}, T61->(IndexKey(1)))
	oModel:SetRelation('MODEL_T6H', {{'T6H_FILIAL','xFilial("T6H")'}, {'T6H_ID','C91_ID'}, {'T6H_VERSAO','C91_VERSAO'}, {'T6H_INDAPU','C91_INDAPU'}, {'T6H_PERAPU','C91_PERAPU'}, {'T6H_TRABAL','C91_TRABAL'}, {'T6H_DEMPAG','T14_IDEDMD'}, {'T6H_DTLEI','T61_DTLEI'}, {'T6H_NUMLEI','T61_NUMLEI'}, {'T6H_ORGSUC','T61_ORGSUC'}}, T6H->(IndexKey(1)))
	oModel:SetRelation('MODEL_T6I', {{'T6I_FILIAL','xFilial("T6I")'}, {'T6I_ID','C91_ID'}, {'T6I_VERSAO','C91_VERSAO'}, {'T6I_INDAPU','C91_INDAPU'}, {'T6I_PERAPU','C91_PERAPU'}, {'T6I_TRABAL','C91_TRABAL'}, {'T6I_DEMPAG','T14_IDEDMD'}, {'T6I_DTLEI','T61_DTLEI'}, {'T6I_NUMLEI','T61_NUMLEI'}, {'T6I_PERREF','T6H_PERREF'}, {'T6I_ORGSUC','T61_ORGSUC'}}, T6I->(IndexKey(1)))
	oModel:SetRelation('MODEL_T6J', {{'T6J_FILIAL','xFilial("T6J")'}, {'T6J_ID','C91_ID'}, {'T6J_VERSAO','C91_VERSAO'}, {'T6J_INDAPU','C91_INDAPU'}, {'T6J_PERAPU','C91_PERAPU'}, {'T6J_TRABAL','C91_TRABAL'}, {'T6J_DEMPAG','T14_IDEDMD'}, {'T6J_DTLEI','T61_DTLEI'}, {'T6J_NUMLEI','T61_NUMLEI'}, {'T6J_PERREF','T6H_PERREF'}, {'T6J_ESTABE','T6I_ESTABE'}, {'T6J_ORGSUC','T61_ORGSUC'}}, T6J->(IndexKey(1)))                                                                                 

	If TafColumnPos("T6E_DTRABA")
		oModel:SetRelation('MODEL_T6E', {{'T6E_FILIAL','xFilial("T6E")'}, {'T6E_ID','C91_ID'}, {'T6E_VERSAO','C91_VERSAO'}, {'T6E_INDAPU','C91_INDAPU'}, {'T6E_PERAPU','C91_PERAPU'}, {'T6E_TRABAL','C91_TRABAL'}, {'T6E_DEMPAG','T14_IDEDMD'}, {'T6E_ESTABE','T6C_ESTABE'}, {'T6E_IDTRAB','T6D_IDTRAB'}, {'T6E_DTRABA','T6D_DTRABA'}, {'T6E_CODCAT','T6D_CODCAT'}}, T6E->(IndexKey(3)))
		oModel:SetRelation('MODEL_T6K', {{'T6K_FILIAL','xFilial("T6K")'}, {'T6K_ID','C91_ID'}, {'T6K_VERSAO','C91_VERSAO'}, {'T6K_INDAPU','C91_INDAPU'}, {'T6K_PERAPU','C91_PERAPU'}, {'T6K_TRABAL','C91_TRABAL'}, {'T6K_DEMPAG','T14_IDEDMD'}, {'T6K_DTLEI','T61_DTLEI'}, {'T6K_NUMLEI','T61_NUMLEI'}, {'T6K_PERREF','T6H_PERREF'}, {'T6K_ESTABE','T6I_ESTABE'}, {'T6K_IDTRAB','T6J_IDTRAB'}, {'T6K_DTRABA','T6J_DTRABA'}, {'T6K_CODCAT','T6J_CODCAT'}}, T6K->(IndexKey(3)))     
	Else
		oModel:SetRelation('MODEL_T6E', {{'T6E_FILIAL','xFilial("T6E")'}, {'T6E_ID','C91_ID'}, {'T6E_VERSAO','C91_VERSAO'}, {'T6E_INDAPU','C91_INDAPU'}, {'T6E_PERAPU','C91_PERAPU'}, {'T6E_TRABAL','C91_TRABAL'}, {'T6E_DEMPAG','T14_IDEDMD'}, {'T6E_ESTABE','T6C_ESTABE'}, {'T6E_IDTRAB','T6D_IDTRAB'}, {'T6E_CODCAT','T6D_CODCAT'}}, T6E->(IndexKey(1)))
		oModel:SetRelation('MODEL_T6K', {{'T6K_FILIAL','xFilial("T6K")'}, {'T6K_ID','C91_ID'}, {'T6K_VERSAO','C91_VERSAO'}, {'T6K_INDAPU','C91_INDAPU'}, {'T6K_PERAPU','C91_PERAPU'}, {'T6K_TRABAL','C91_TRABAL'}, {'T6K_DEMPAG','T14_IDEDMD'}, {'T6K_DTLEI','T61_DTLEI'}, {'T6K_NUMLEI','T61_NUMLEI'}, {'T6K_PERREF','T6H_PERREF'}, {'T6K_ESTABE','T6I_ESTABE'}, {'T6K_IDTRAB','T6J_IDTRAB'}, {'T6K_CODCAT','T6J_CODCAT'}}, T6K->(IndexKey(1)))     
	EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Vitor Siqueira
@since 08/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	
	Local aCmpGrp   as array
	Local cCmpFil   as character
	Local cAbaAPur	as character
	Local cAbaAnt	as character
	Local cAbaRRA	as character
	Local lCallInc  as logical
	Local nI        as numeric
	Local oModel    as object
	Local oStruC91a as object
	Local oStruC91b as object
	Local oStruC91c as object
	Local oStruC91d as object
	Local oStruT14  as object
	Local oStruT61  as object
	Local oStruT6C  as object
	Local oStruT6D  as object
	Local oStruT6E  as object
	Local oStruT6H  as object
	Local oStruT6I  as object
	Local oStruT6J  as object
	Local oStruT6K  as object
	Local oStruV9L  as object
	Local oView     as object
	
	aCmpGrp   := {}
	cCmpFil   := ""
	lCallInc  := .F.
	nI        := 0
	oModel    := FWLoadModel( 'TAFA413' )
	oStruC91a := Nil
	oStruC91b := Nil
	oStruC91c := Nil
	oStruC91d := Nil
	oStruT14  := FWFormStruct( 2, 'T14' )
	oStruT61  := FWFormStruct( 2, 'T61' )
	oStruT6C  := FWFormStruct( 2, 'T6C' )
	oStruT6D  := FWFormStruct( 2, 'T6D' )
	oStruT6E  := FWFormStruct( 2, 'T6E' )
	oStruT6H  := FWFormStruct( 2, 'T6H' )
	oStruT6I  := FWFormStruct( 2, 'T6I' )
	oStruT6J  := FWFormStruct( 2, 'T6J' )
	oStruT6K  := FWFormStruct( 2, 'T6K' )
	oView     := Nil

	If FWIsInCallStack( "TAF413Inc" )
		lCallInc 	:= .T.
		lTAUTO		:= MsgYesNo(STR0022, STR0021)
	EndIf

	If lSimplBeta .And. TafColumnPos("T14_INDRRA")
		cAbaApur  := "ABA02"
		cAbaAnt   := "ABA03"
		cAbaRRA   := "ABA01"
		oStruV9L  := FWFormStruct( 2, 'V9L' )
	Else
		If TafColumnPos("T14_INDRRA")
			oStruT14:RemoveField( "T14_INDRRA" )
			oStruT14:RemoveField( "T14_TPPRRA" )
			oStruT14:RemoveField( "T14_NRPRRA" )
			oStruT14:RemoveField( "T14_DESCRA" )
			oStruT14:RemoveField( "T14_QTMRRA" )
			oStruT14:RemoveField( "T14_VLRCUS" )
		EndIf
		cAbaApur  := "ABA01"
		cAbaAnt   := "ABA02"
		cAbaRRA   := ""
		oStruV9L  := Nil
	EndIf	

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetContinuousForm()

	oStruT6D:RemoveField("T6D_CODCAT")
	oStruT6D:RemoveField("T6D_DCODCA")
	oStruT6K:RemoveField("T6K_VLRUNT")
	oStruT6E:RemoveField("T6E_VLRUNT")
	oStruT6J:RemoveField("T6J_CODCAT")
	oStruT61:RemoveField("T61_DTLEI" )
	oStruT61:RemoveField("T61_NUMLEI")
	oStruT61:RemoveField("T61_DTEFET")
	oStruT6H:RemoveField("T6H_ORGSUC")
	oStruT6I:RemoveField("T6I_ORGSUC")
	oStruT6J:RemoveField("T6J_ORGSUC")
	oStruT6J:RemoveField("T6J_DCODCA")
	oStruT14:RemoveField("T14_CODCBO")
	oStruT14:RemoveField("T14_NATATV")
	oStruT14:RemoveField("T14_QTDTRB")
	oStruT14:RemoveField("T14_DCODCB")
	oStruT6J:RemoveField("T6J_NOMEVE")
	oStruT6D:RemoveField("T6D_NOMEVE")
	oStruT14:RemoveField("T14_VLRADV")

	If lSimplBeta .And. TafColumnPos("T14_INDRRA")
		oStruV9L:RemoveField( "V9L_ESTABE")
		oStruV9L:RemoveField( "V9L_DESTAB")
	EndIf

	If (lCallInc .AND. !lTAUTO) .OR. (!lCallInc .AND. !Empty(C91->C91_TRABAL))
		cCmpFil := 'C91_TRABAL|C91_DTRABA|'
	Else
		cCmpFil := 'C91_CPF|C91_NOME|C91_NASCTO|'

		oStruT6D:RemoveField("T6D_IDTRAB")
		oStruT6J:RemoveField("T6J_IDTRAB")
	EndIf

	cCmpFil += 'C91_MATREA|C91_DTINVI|C91_OBSVIN|C91_CNPJEA|'

	oStruC91c := FwFormStruct( 2, 'C91', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := 'C91_ID|C91_INDAPU|C91_PERAPU|'

	If (lCallInc .AND. lTAUTO) .OR. (!lCallInc .AND. Empty(C91->C91_TRABAL))
		oStruC91c:SetProperty("C91_NOME"  , MVC_VIEW_CANCHANGE, .T.)
		oStruC91c:SetProperty("C91_NASCTO", MVC_VIEW_CANCHANGE, .T.)
	EndIf

	oStruC91a := FwFormStruct( 2, 'C91', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	// Campos do folder Número de protocolo
	cCmpFil := 'C91_PROTUL|
	oStruC91b := FwFormStruct( 2, 'C91', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	If TafColumnPos("C91_DTRANS")
		cCmpFil := 'C91_DINSIS|C91_DTRANS|C91_HTRANS|C91_DTRECP|C91_HRRECP|'
		oStruC91d := FwFormStruct( 2, 'C91', {|x| AllTrim( x ) + "|" $ cCmpFil } )
	EndIf
	/*--------------------------------------------------------------------------------------------
										Esrutura da View
	---------------------------------------------------------------------------------------------*/
	oView:AddField( 'VIEW_C91a', oStruC91a, 'MODEL_C91' )
	oView:EnableTitleView( 'VIEW_C91a', STR0002 ) // "Informações da Remuneração RPPS" 

	oView:AddField( 'VIEW_C91b', oStruC91b, 'MODEL_C91' )

	If TafColumnPos("C91_PROTUL")
		oView:EnableTitleView( 'VIEW_C91b', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"  
	EndIf

	If TafColumnPos("C91_DTRANS")
		oView:AddField( 'VIEW_C91d', oStruC91d, 'MODEL_C91' )
		oView:EnableTitleView( 'VIEW_C91d', TafNmFolder("recibo",2) )  
	EndIf

	oView:AddField( 'VIEW_C91c', oStruC91c, 'MODEL_C91' )
	oView:EnableTitleView( 'VIEW_C91c', STR0023 ) // "Informações da Remuneração RPPS" 

	oStruC91c:AddGroup( "GRP_TRABALHADOR_01", STR0003, "", 1 ) // "Trabalhador"

	If (lCallInc .AND. !lTAUTO) .OR. (!lCallInc .AND. !Empty(C91->C91_TRABAL))
		oStruC91c:SetProperty('C91_TRABAL', MVC_VIEW_GROUP_NUMBER, "GRP_TRABALHADOR_01")
		oStruC91c:SetProperty('C91_DTRABA', MVC_VIEW_GROUP_NUMBER, "GRP_TRABALHADOR_01")
	Else
		oStruC91c:SetProperty('C91_CPF', MVC_VIEW_GROUP_NUMBER, "GRP_TRABALHADOR_01")
		
		oStruC91c:AddGroup( "GRP_TRABALHADOR_02", STR0004, "", 1 ) // "Informações complementares de identificação do trabalhador <infoComplem>"
		oStruC91c:SetProperty('C91_NOME'  , MVC_VIEW_GROUP_NUMBER, "GRP_TRABALHADOR_02")
		oStruC91c:SetProperty('C91_NASCTO', MVC_VIEW_GROUP_NUMBER, "GRP_TRABALHADOR_02")
	EndIf

	oStruC91c:AddGroup( "GRP_TRABALHADOR_03", STR0005, "", 1 ) // "Informações da sucessão de vínculo trabalhista/estatutário"

	aCmpGrp := StrToKArr("C91_MATREA|C91_DTINVI|C91_OBSVIN|C91_CNPJEA|", "|")

	For nI := 1 to Len(aCmpGrp)
		oStruC91c:SetProperty(aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TRABALHADOR_03")
	Next

	oView:AddGrid( 'VIEW_T14', oStruT14, 'MODEL_T14' )
	oView:EnableTitleView("VIEW_T14",STR0006) //"Informações do Recibo de Pagamento"

	oView:AddGrid( 'VIEW_T6C', oStruT6C, 'MODEL_T6C' )
	oView:EnableTitleView("VIEW_T6C",STR0007) //"Informações do Estabelecimento/Lotação"

	oView:AddGrid( 'VIEW_T6D', oStruT6D, 'MODEL_T6D' )
	oView:EnableTitleView("VIEW_T6D",STR0008) //"Informações da Remuneração do Trabalhador"

	oView:AddGrid( 'VIEW_T6E', oStruT6E, 'MODEL_T6E' ) //"Informações do Plano de Saúde"

	oView:AddGrid( 'VIEW_T61', oStruT61, 'MODEL_T61' )
	oView:EnableTitleView("VIEW_T61",STR0009) //"Identificação da Lei que Determinou Remuneração em Períodos Anteriores "

	oView:AddGrid( 'VIEW_T6H', oStruT6H, 'MODEL_T6H' )
	oView:EnableTitleView("VIEW_T6H",STR0010) //"Informações do Periodo"

	oView:AddGrid( 'VIEW_T6I', oStruT6I, 'MODEL_T6I' )
	oView:EnableTitleView("VIEW_T6I",STR0007) //"Informações do Estabelecimento/Lotação"

	oView:AddGrid( 'VIEW_T6J', oStruT6J, 'MODEL_T6J' )
	oView:EnableTitleView("VIEW_T6J",STR0011) //"Informações da Remuneração do Trabalhador"

	oView:AddGrid( 'VIEW_T6K', oStruT6K, 'MODEL_T6K' )
	oView:EnableTitleView("VIEW_T6K",STR0012) //"Itens de Rumeneração"

	If lSimplBeta .And. TafColumnPos("T14_INDRRA")
		oView:AddGrid( 'VIEW_V9L', oStruV9L, 'MODEL_V9L' )
		oView:EnableTitleView("VIEW_V9L", STR0027) //"Itens de Rumeneração"
	EndIf

	If FindFunction('TafAjustRecibo')
		TafAjustRecibo(oStruC91b,"C91")
	EndIf 

	/*-----------------------------------------------------------------------------------
									Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )

	oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0002 )   //"Informações da Remuneração RPPS"
	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0016 )   //"Informações do Periodo de Apuração"

	If FindFunction('TafNmFolder')
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA03', TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA03', STR0017 )   //"Protocolo de Transmissão"
	EndIf

	oView:CreateHorizontalBox( 'C91a',  25,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'C91c',  75,,, 'FOLDER_SUPERIOR', 'ABA01' )

	oView:CreateHorizontalBox( 'PAINEL_DEMONST' ,	15,,, 'FOLDER_SUPERIOR', 'ABA02' )
	oView:CreateHorizontalBox( 'PAINEL_APURACAO',	85,,, 'FOLDER_SUPERIOR', 'ABA02' )

	If TafColumnPos("C91_DTRANS")
		oView:CreateHorizontalBox( 'C91b',  20,,, 'FOLDER_SUPERIOR', 'ABA03' )
		oView:CreateHorizontalBox( 'C91d',  80,,, 'FOLDER_SUPERIOR', 'ABA03' )
	Else
		oView:CreateHorizontalBox( 'C91b',  15,,, 'FOLDER_SUPERIOR', 'ABA03' )
	EndIf

	oView:CreateFolder( 'FOLDER_APURACAO', 'PAINEL_APURACAO' )

	If lSimplBeta .And. TafColumnPos("T14_INDRRA")
		oView:AddSheet( 'FOLDER_APURACAO', cAbaRRA , STR0026 )   //"Informações do Periodo de Apur. Anterior"
	EndIf
	oView:AddSheet( 'FOLDER_APURACAO', cAbaAPur, STR0016 )   //"Informações do Periodo de Apur. Anterior"
	oView:AddSheet( 'FOLDER_APURACAO', cAbaAnt, STR0018 )   //"Informações do Periodo de Apur. Anterior"

	If lSimplBeta .And. TafColumnPos("T14_INDRRA")
		oView:CreateHorizontalBox('V9L'  ,25,,,	'FOLDER_APURACAO',cAbaRRA) 
	EndIf

	oView:CreateHorizontalBox('PAINEL_ESTABELEC'  ,25,,,	'FOLDER_APURACAO',cAbaAPur)                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
	oView:CreateHorizontalBox('PAINEL_REMUN_PER'  ,25,,,	'FOLDER_APURACAO',cAbaAPur)
	oView:CreateHorizontalBox('PAINEL_ITENS_REMUN',50,,,	'FOLDER_APURACAO',cAbaAPur)

	oView:CreateFolder( 'FOLDER_REMUN', 'PAINEL_ITENS_REMUN' )
	oView:AddSheet( 'FOLDER_REMUN', cAbaAPur, STR0019 ) //"Itens Rem. Trab."

	oView:CreateHorizontalBox ( 'T6E', 100,,,'FOLDER_REMUN'  , cAbaAPur )

	/*------------------------
	PERIODO DE APUR. ANT.
	--------------------------*/
	oView:CreateHorizontalBox ( 'T61', 20,,, 'FOLDER_APURACAO' 	, cAbaAnt )
	oView:CreateHorizontalBox ( 'T6H', 20,,, 'FOLDER_APURACAO'	, cAbaAnt )
	oView:CreateHorizontalBox ( 'T6I', 20,,, 'FOLDER_APURACAO' 	, cAbaAnt )
	oView:CreateHorizontalBox ( 'T6J', 20,,, 'FOLDER_APURACAO'	, cAbaAnt )
	oView:CreateHorizontalBox ( 'T6K', 20,,, 'FOLDER_APURACAO' 	, cAbaAnt )

	oView:SetOwnerView( 'VIEW_C91a', 'C91a')
	oView:SetOwnerView( 'VIEW_C91b', 'C91b')

	If TafColumnPos("C91_DTRANS")
		oView:SetOwnerView( 'VIEW_C91d', 'C91d')
	EndIf

	oView:SetOwnerView( 'VIEW_T14' , 'PAINEL_DEMONST')
	oView:SetOwnerView( 'VIEW_T6C' , 'PAINEL_ESTABELEC')
	oView:SetOwnerView( 'VIEW_T6D' , 'PAINEL_REMUN_PER')
	oView:SetOwnerView( 'VIEW_T6E' , 'T6E')
	oView:SetOwnerView( 'VIEW_T61' , 'T61')
	oView:SetOwnerView( 'VIEW_T6H' , 'T6H')
	oView:SetOwnerView( 'VIEW_T6I' , 'T6I')
	oView:SetOwnerView( 'VIEW_T6J' , 'T6J')
	oView:SetOwnerView( 'VIEW_T6K' , 'T6K')
	oView:SetOwnerView( 'VIEW_T6K' , 'T6K')
	If lSimplBeta .And. TafColumnPos("T14_INDRRA")
		oView:SetOwnerView( 'VIEW_V9L' , 'V9L')
	EndIf

	oView:SetOwnerView( 'VIEW_C91c', 'C91c')

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif

		xFunRmFStr(@oStruC91a,"C91")
		
		oStruC91a:RemoveField('C91_ID')
		oStruT6D:RemoveField('T6D_ID')
		oStruT14:RemoveField('T14_NOMEVE')	
		
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@author Vitor Siqueira
@since 11/01/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local aGrava     as array
	Local aGravaT14  as array
	Local aGravaT61  as array
	Local aGravaT6C  as array
	Local aGravaT6D  as array
	Local aGravaT6E  as array
	Local aGravaT6H  as array
	Local aGravaT6I  as array
	Local aGravaT6J  as array
	Local aGravaT6K  as array
	Local aGravaV9L  as array
	Local cApurIR    as character
	Local cEvento    as character
	Local cLogOpeAnt as character
	Local cNomeEve   as character
	Local cOrgSuc    as character
	Local cProtocolo as character
	Local cVerAnt    as character
	Local cVersao    as character
	Local lRetorno   as logical
	Local nlI        as numeric
	Local nlY        as numeric
	Local nOperation as numeric
	Local nT14       as numeric
	Local nT61       as numeric
	Local nT61Add    as numeric
	Local nT6C       as numeric
	Local nT6CAdd    as numeric
	Local nT6D       as numeric
	Local nT6DAdd    as numeric
	Local nT6E       as numeric
	Local nT6EAdd    as numeric
	Local nT6H       as numeric
	Local nT6HAdd    as numeric
	Local nT6I       as numeric
	Local nT6IAdd    as numeric
	Local nT6J       as numeric
	Local nT6JAdd    as numeric
	Local nT6K       as numeric
	Local nT6KAdd    as numeric
	Local nV9L		 as numeric
	Local nV9LAdd	 as numeric
	Local oModelC91  as object
	Local oModelT14  as object
	Local oModelT61  as object
	Local oModelT6C  as object
	Local oModelT6D  as object
	Local oModelT6E  as object
	Local oModelT6H  as object
	Local oModelT6I  as object
	Local oModelT6J  as object
	Local oModelT6K  as object
	Local oModelV9L  as object

	Default oModel   := Nil

	aGrava     := {}
	aGravaT14  := {}
	aGravaT61  := {}
	aGravaT6C  := {}
	aGravaT6D  := {}
	aGravaT6E  := {}
	aGravaT6H  := {}
	aGravaT6I  := {}
	aGravaT6J  := {}
	aGravaT6K  := {}
	aGravaV9L  := {}
	cApurIR    := ""
	cEvento    := ""
	cLogOpeAnt := ""
	cNomeEve   := ""
	cOrgSuc    := ""
	cProtocolo := ""
	cVerAnt    := ""
	cVersao    := ""
	lRetorno   := .T.
	nlI        := 0
	nlY        := 0
	nOperation := 0
	nT14       := 0
	nT61       := 0
	nT61Add    := 0
	nT6C       := 0
	nT6CAdd    := 0
	nT6D       := 0
	nT6DAdd    := 0
	nT6E       := 0
	nT6EAdd    := 0
	nT6H       := 0
	nT6HAdd    := 0
	nT6I       := 0
	nT6IAdd    := 0
	nT6J       := 0
	nT6JAdd    := 0
	nT6K       := 0
	nT6KAdd    := 0
	nV9L	   := 0
	nV9LAdd	   := 0 

	oModelC91  := Nil
	oModelT14  := Nil
	oModelT61  := Nil
	oModelT6C  := Nil
	oModelT6D  := Nil
	oModelT6E  := Nil
	oModelT6H  := Nil
	oModelT6I  := Nil
	oModelT6J  := Nil
	oModelT6K  := Nil
	oModelV9L  := Nil	

	nOperation	:= oModel:GetOperation()

	Begin Transaction 
		
		If nOperation == MODEL_OPERATION_INSERT

			oModel:LoadValue( 'MODEL_C91', 'C91_VERSAO', xFunGetVer() ) 
			oModel:LoadValue( "MODEL_C91", "C91_NOMEVE", "S1202" )

			oModelC91 := oModel:GetModel( 'MODEL_C91' )

			cTrabal := oModelC91:GetValue( "C91_TRABAL" )

			If !Empty(cTrabal)

				oModel:LoadValue( "MODEL_C91", "C91_ORIEVE", Posicione("C9V", 2, xFilial("C9V") + cTrabal + "1", "C9V_NOMEVE") )

			EndIf

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_C91', 'C91_LOGOPE' , '2', '' )
			EndIf

			If !oModel:GetModel( 'MODEL_T14' ):IsEmpty() .And. !oModel:GetModel( "MODEL_T14" ):IsDeleted()
				
				For nT14 := 1 to oModel:GetModel( "MODEL_T14" ):Length()
					oModel:GetModel( "MODEL_T14" ):GoLine(nT14)
					oModel:LoadValue( "MODEL_T14", "T14_NOMEVE", "S1202" )
				Next nT14
		
			EndIf

			If !oModel:GetModel( 'MODEL_T6D' ):IsEmpty() .And. !oModel:GetModel( "MODEL_T6D" ):IsDeleted()

				For nT6D := 1 to oModel:GetModel( "MODEL_T6D" ):Length()
					oModel:GetModel( "MODEL_T6D" ):GoLine(nT6D)
					oModel:LoadValue( "MODEL_T6D", "T6D_NOMEVE", "S1202" )
				Next nT6D

			EndIf

			If !oModel:GetModel( 'MODEL_T6J' ):IsEmpty() .And. !oModel:GetModel( "MODEL_T6J" ):IsDeleted()

				For nT6J := 1 to oModel:GetModel( "MODEL_T6J" ):Length()
					oModel:GetModel( "MODEL_T6J" ):GoLine(nT6J)
					oModel:LoadValue( "MODEL_T6J", "T6J_NOMEVE", "S1202" )
				Next nT6J

			EndIf

			FwFormCommit( oModel )  
			
		ElseIf nOperation == MODEL_OPERATION_UPDATE 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			C91->( DbSetOrder( 3 ) )
			If C91->( MsSeek( xFilial( 'C91' ) + M->C91_ID + '1' ) )
							
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If C91->C91_STATUS $ ( "4" ) 
									
					oModelC91 := oModel:GetModel( 'MODEL_C91' )   
					oModelT14 := oModel:GetModel( 'MODEL_T14' ) 
					oModelT6C := oModel:GetModel( 'MODEL_T6C' )         
					oModelT6D := oModel:GetModel( 'MODEL_T6D' )     
					oModelT6E := oModel:GetModel( 'MODEL_T6E' ) 
					oModelT6H := oModel:GetModel( 'MODEL_T6H' )  
					oModelT6I := oModel:GetModel( 'MODEL_T6I' )    									    						
					oModelT6J := oModel:GetModel( 'MODEL_T6J' )     						
					oModelT6K := oModel:GetModel( 'MODEL_T6K' )  
					oModelT61 := oModel:GetModel( 'MODEL_T61' )

					If lSimplBeta .And. TafColumnPos("T14_INDRRA")
						oModelV9L := oModel:GetModel( 'MODEL_V9L' )	
					EndIf
																																																	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt   	:= oModelC91:GetValue( "C91_VERSAO" )				
					cProtocolo	:= oModelC91:GetValue( "C91_PROTUL" )
					cEvento		:= oModelC91:GetValue( "C91_EVENTO" )

					If TafColumnPos( "C91_LOGOPE" )
						cLogOpeAnt := oModelC91:GetValue( "C91_LOGOPE" )
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas       ³
					//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
					//³nao devem ser consideradas neste momento                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					/*------------------------------------------
						C91 - Folha de Pagamento  
					--------------------------------------------*/
					For nlI := 1 To 1
						For nlY := 1 To Len( oModelC91:aDataModel[ nlI ] )			
							Aadd( aGrava, { oModelC91:aDataModel[ nlI, nlY, 1 ], oModelC91:aDataModel[ nlI, nlY, 2 ] } )									
						Next
					Next 	
										
					/*------------------------------------------
						T14 - Ident. Demonstr. Val. Trabal. 
					--------------------------------------------*/
					For nT14 := 1 To oModel:GetModel( 'MODEL_T14' ):Length() 
						oModel:GetModel( 'MODEL_T14' ):GoLine(nT14)
						
						If !oModel:GetModel( 'MODEL_T14' ):IsEmpty()
							If !oModel:GetModel( 'MODEL_T14' ):IsDeleted()
								If lSimplBeta .And. TafColumnPos("T14_INDRRA")
									AAdd(aGravaT14, {	oModelC91:GetValue('C91_INDAPU'),;
														oModelC91:GetValue('C91_PERAPU'),;
														oModelC91:GetValue('C91_TRABAL'),;
														oModelT14:GetValue('T14_IDEDMD'),;
														oModelT14:GetValue('T14_CODCAT'),;
														oModelT14:GetValue('T14_CODCBO'),;
														oModelT14:GetValue('T14_NATATV'),;
														oModelT14:GetValue('T14_QTDTRB'),;
														oModelT14:GetValue('T14_INDRRA'),;
														oModelT14:GetValue('T14_TPPRRA'),;
														oModelT14:GetValue('T14_NRPRRA'),;
														oModelT14:GetValue('T14_DESCRA'),;
														oModelT14:GetValue('T14_QTMRRA'),;
														oModelT14:GetValue('T14_VLRCUS'),;
														oModelT14:GetValue('T14_VLRADV')	})

									/*------------------------------------------
										V9L - Informações de Valores Pagos
									--------------------------------------------*/
									For nV9L := 1 to oModel:GetModel( "MODEL_V9L" ):Length()
										oModel:GetModel( "MODEL_V9L" ):GoLine(nV9L)

										If !oModel:GetModel( 'MODEL_V9L' ):IsEmpty()
											If !oModel:GetModel( "MODEL_V9L" ):IsDeleted()
												aAdd(aGravaV9L, { 	oModelC91:GetValue('C91_INDAPU'),;
																	oModelC91:GetValue('C91_PERAPU'),;
																	oModelC91:GetValue('C91_TRABAL'),;
																	oModelT14:GetValue('T14_IDEDMD'),;
																	oModelV9L:GetValue('V9L_TPINSC'),;
																	oModelV9L:GetValue('V9L_NRINSC'),;
																	oModelV9L:GetValue('V9L_VLRADV')	})
											EndIf
										EndIf
									Next
								Else
									AAdd(aGravaT14, {	oModelC91:GetValue('C91_INDAPU'),;
														oModelC91:GetValue('C91_PERAPU'),;
														oModelC91:GetValue('C91_TRABAL'),;
														oModelT14:GetValue('T14_IDEDMD'),;
														oModelT14:GetValue('T14_CODCAT')	})								
								EndIf
							
								/*------------------------------------------
									T6C - Identificação do Estabelecimen
								--------------------------------------------*/			  		
								For nT6C := 1 to oModel:GetModel( "MODEL_T6C" ):Length()
									oModel:GetModel( "MODEL_T6C" ):GoLine(nT6C)
									
									If !oModel:GetModel( 'MODEL_T6C' ):IsEmpty()	
										If !oModel:GetModel( "MODEL_T6C" ):IsDeleted()
											aAdd(aGravaT6C,{oModelC91:GetValue('C91_INDAPU'),;
															oModelC91:GetValue('C91_PERAPU'),;
															oModelC91:GetValue('C91_TRABAL'),;
															oModelT14:GetValue('T14_IDEDMD'),;
															oModelT6C:GetValue('T6C_ESTABE')}) 
												
											/*------------------------------------------
												T6D - Remun Trabal. Período Apuração
											--------------------------------------------*/			  		
											For nT6D := 1 To oModel:GetModel( "MODEL_T6D" ):Length()
												oModel:GetModel( "MODEL_T6D" ):GoLine(nT6D)
												
												If !oModel:GetModel( 'MODEL_T6D' ):IsEmpty()	
													If !oModel:GetModel( "MODEL_T6D" ):IsDeleted()													
														cNomeEve := oModelT6D:GetValue('T6D_NOMEVE')
														cNomeEve := Iif(!Empty(oModelC91:GetValue('C91_NOME')), "TAUTO", cNomeEve)
														
														AAdd(aGravaT6D, {	oModelC91:GetValue('C91_INDAPU'),;
																			oModelC91:GetValue('C91_PERAPU'),;
																			oModelC91:GetValue('C91_TRABAL'),; 
																			oModelT14:GetValue('T14_IDEDMD'),;
																			oModelT6C:GetValue('T6C_ESTABE'),;
																			oModelT6D:GetValue('T6D_IDTRAB'),;
																			oModelT6D:GetValue('T6D_CODCAT'),;
																			cNomeEve,;						
																			IIf(TafColumnPos("T6E_DTRABA"), oModelT6D:GetValue("T6D_DTRABA"), "")	})

														/*------------------------------------------
															T6E - Itens Remun. do Trabalhador   
														--------------------------------------------*/
														For nT6E := 1 to oModel:GetModel( "MODEL_T6E" ):Length()
															oModel:GetModel( "MODEL_T6E" ):GoLine(nT6E)
															
															If !oModel:GetModel( 'MODEL_T6E' ):IsEmpty()	
																If !oModel:GetModel( "MODEL_T6E" ):IsDeleted()
																	cApurIR := oModelT6E:GetValue('T6E_APURIR')
																	
																	AAdd(aGravaT6E, {	oModelC91:GetValue('C91_INDAPU'),;
																						oModelC91:GetValue('C91_PERAPU'),;
																						oModelC91:GetValue('C91_TRABAL'),;
																						oModelT14:GetValue('T14_IDEDMD'),;
																						oModelT6C:GetValue('T6C_ESTABE'),;
																						oModelT6D:GetValue('T6D_IDTRAB'),;
																						oModelT6D:GetValue('T6D_CODCAT'),;
																						oModelT6E:GetValue('T6E_IDRUBR'),;
																						oModelT6E:GetValue('T6E_QTDRUB'),;
																						oModelT6E:GetValue('T6E_FATORR'),;
																						oModelT6E:GetValue('T6E_VLRUNT'),;
																						oModelT6E:GetValue('T6E_VLRRUB'),;
																						cApurIR,;						
																						IIf(TafColumnPos("T6E_DTRABA"), oModelT6D:GetValue("T6D_DTRABA"), "")	})
																EndIf
															EndIf
														Next								
													EndIf
												EndIf
											Next
										EndIf
									EndIf
								Next
									
								/*------------------------------------------
									T61 - Ident Lei  Remun. Per.  Anter.
								--------------------------------------------*/
								For nT61 := 1 To oModel:GetModel( 'MODEL_T61' ):Length() 
									oModel:GetModel( 'MODEL_T61' ):GoLine(nT61)
									If !oModel:GetModel( 'MODEL_T61' ):IsEmpty()
										If !oModel:GetModel( 'MODEL_T61' ):IsDeleted()
											cOrgSuc := oModelT61:GetValue('T61_ORGSUC')
																											
											aAdd(aGravaT61 ,{oModelC91:GetValue('C91_INDAPU'),;
																oModelC91:GetValue('C91_PERAPU'),;
																oModelC91:GetValue('C91_TRABAL'),;
																oModelT14:GetValue('T14_IDEDMD'),;
																oModelT61:GetValue('T61_DTLEI'),;
																oModelT61:GetValue('T61_NUMLEI'),;
																oModelT61:GetValue('T61_DTEFET'),;
																cOrgSuc})

											/*------------------------------------
												T6H - Informações do Periodo
											-------------------------------------*/			  		
											For nT6H := 1 to oModel:GetModel( "MODEL_T6H" ):Length()
												oModel:GetModel( "MODEL_T6H" ):GoLine(nT6H)
												If !oModel:GetModel( 'MODEL_T6H' ):IsEmpty()	
													If !oModel:GetModel( "MODEL_T6H" ):IsDeleted()
														aAdd(aGravaT6H ,{oModelC91:GetValue('C91_INDAPU'),;
																			oModelC91:GetValue('C91_PERAPU'),;
																			oModelC91:GetValue('C91_TRABAL'),;
																			oModelT14:GetValue('T14_IDEDMD'),;
																			oModelT61:GetValue('T61_DTLEI'),;
																			oModelT61:GetValue('T61_NUMLEI'),;
																			oModelT6H:GetValue('T6H_PERREF'),;
																			cOrgSuc})	

														/*------------------------------------
															T6I - Ident. do Estabelecimento
														-------------------------------------*/			  		
														For nT6I := 1 to oModel:GetModel( "MODEL_T6I" ):Length()
															oModel:GetModel( "MODEL_T6I" ):GoLine(nT6I)
															If !oModel:GetModel( 'MODEL_T6I' ):IsEmpty()	
																If !oModel:GetModel( "MODEL_T6I" ):IsDeleted()
																	aAdd(aGravaT6I ,{oModelC91:GetValue('C91_INDAPU'),;
																						oModelC91:GetValue('C91_PERAPU'),;
																						oModelC91:GetValue('C91_TRABAL'),;
																						oModelT14:GetValue('T14_IDEDMD'),;
																						oModelT61:GetValue('T61_DTLEI'),;
																						oModelT61:GetValue('T61_NUMLEI'),;
																						oModelT6H:GetValue('T6H_PERREF'),;
																						oModelT6I:GetValue('T6I_ESTABE'),;
																						cOrgSuc})

																	/*------------------------------------------
																		T6J - Informações da Remuneração Trab.
																	--------------------------------------------*/			  		
																	For nT6J := 1 to oModel:GetModel( "MODEL_T6J" ):Length()
																		oModel:GetModel( "MODEL_T6J" ):GoLine(nT6J)
																		If !oModel:GetModel( 'MODEL_T6J' ):IsEmpty()	
																			If !oModel:GetModel( "MODEL_T6J" ):IsDeleted()
																				cNomeEve := oModelT6J:GetValue('T6J_NOMEVE')
																				cNomeEve := Iif(!Empty(oModelC91:GetValue('C91_NOME')), "TAUTO", cNomeEve)
																																	
																				AAdd(aGravaT6J, {	oModelC91:GetValue('C91_INDAPU'),;
																									oModelC91:GetValue('C91_PERAPU'),;
																									oModelC91:GetValue('C91_TRABAL'),; 
																									oModelT14:GetValue('T14_IDEDMD'),;
																									oModelT61:GetValue('T61_DTLEI')	,;
																									oModelT61:GetValue('T61_NUMLEI'),;
																									oModelT6H:GetValue('T6H_PERREF'),;
																									oModelT6I:GetValue('T6I_ESTABE'),;
																									oModelT6J:GetValue('T6J_IDTRAB'),;
																									oModelT6J:GetValue('T6J_CODCAT'),;
																									cOrgSuc							,;
																									cNomeEve,;
																									IIf(TafColumnPos("T6E_DTRABA"), oModelT6J:GetValue("T6J_DTRABA"), "")	})

																				/*------------------------------------------
																					T6K - Itens da Remuneração Trab.
																				--------------------------------------------*/
																				For nT6K := 1 to oModel:GetModel( "MODEL_T6K" ):Length()
																					oModel:GetModel( "MODEL_T6K" ):GoLine(nT6K)
																					If !oModel:GetModel( 'MODEL_T6K' ):IsEmpty()	
																						If !oModel:GetModel( "MODEL_T6K" ):IsDeleted()
																							cApurIR := oModelT6K:GetValue('T6K_APURIR')
																						
																							AAdd(aGravaT6K, {	oModelC91:GetValue('C91_INDAPU'),;
																												oModelC91:GetValue('C91_PERAPU'),;
																												oModelC91:GetValue('C91_TRABAL'),;
																												oModelT14:GetValue('T14_IDEDMD'),;
																												oModelT61:GetValue('T61_DTLEI')	,;
																												oModelT61:GetValue('T61_NUMLEI'),;
																												oModelT6H:GetValue('T6H_PERREF'),;
																												oModelT6I:GetValue('T6I_ESTABE'),;
																												oModelT6J:GetValue('T6J_IDTRAB'),;
																												oModelT6J:GetValue('T6J_CODCAT'),;
																												oModelT6K:GetValue('T6K_IDRUBR'),;
																												oModelT6K:GetValue('T6K_QTDRUB'),;
																												oModelT6K:GetValue('T6K_FATORR'),;
																												oModelT6K:GetValue('T6K_VLRUNT'),;
																												oModelT6K:GetValue('T6K_VLRRUB'),;
																												cApurIR,;
																												IIf(TafColumnPos("T6E_DTRABA"), oModelT6J:GetValue("T6J_DTRABA"), "")	})

																						EndIf
																					EndIf
																				Next
																			EndIf
																		EndIf
																	Next
																EndIf
															EndIf
														Next																
													EndIf
												EndIf
											Next		
										EndIf
									EndIf
								Next
							EndIf
						EndIf
					Next								
												
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³ 
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'C91', '2' )
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu preciso setar a operacao do model³
					//³como Inclusao                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:DeActivate()
					oModel:SetOperation( 3 ) 	
					oModel:Activate()		
									
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu realizo a inclusao do novo registro ja³
					//³contemplando as informacoes alteradas pelo usuario     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					/*------------------------------------------
						C91 - Folha de Pagamento  
					--------------------------------------------*/
					For nlI := 1 To Len( aGrava )	
						oModel:LoadValue( 'MODEL_C91', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
					Next

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C91', 'C91_LOGOPE' , '' , cLogOpeAnt )	
					EndIf
									
					/*------------------------------------------

						T14 - Ident. Demonstr. Val. Trabal. 
					--------------------------------------------*/
					For nT14 := 1 To Len(aGravaT14)
						oModel:GetModel("MODEL_T14"):lValid := .T.
						
						If nT14 > 1
							oModel:GetModel("MODEL_T14"):AddLine()
						EndIf
						
						oModel:LoadValue("MODEL_T14", "T14_IDEDMD", aGravaT14[nT14][4] 	)
						oModel:LoadValue("MODEL_T14", "T14_NOMEVE", "S1202"				)
						oModel:LoadValue("MODEL_T14", "T14_CODCAT", aGravaT14[nT14][5]	)

						If lSimplBeta .And. TafColumnPos("T14_INDRRA")
							oModel:LoadValue("MODEL_T14", "T14_CODCBO", aGravaT14[nT14][6]	)
							oModel:LoadValue("MODEL_T14", "T14_NATATV", aGravaT14[nT14][7]	)
							oModel:LoadValue("MODEL_T14", "T14_QTDTRB", aGravaT14[nT14][8] 	)
							oModel:LoadValue("MODEL_T14", "T14_INDRRA", aGravaT14[nT14][9]	)
							oModel:LoadValue("MODEL_T14", "T14_TPPRRA", aGravaT14[nT14][10]	)
							oModel:LoadValue("MODEL_T14", "T14_NRPRRA", aGravaT14[nT14][11] )
							oModel:LoadValue("MODEL_T14", "T14_DESCRA", aGravaT14[nT14][12]	)
							oModel:LoadValue("MODEL_T14", "T14_QTMRRA", aGravaT14[nT14][13]	)
							oModel:LoadValue("MODEL_T14", "T14_VLRCUS", aGravaT14[nT14][14] )
							oModel:LoadValue("MODEL_T14", "T14_VLRADV", aGravaT14[nT14][15] )

							/*------------------------------------------
							V9L - Identificação dos advogados   
							--------------------------------------------*/
							nV9LAdd := 1

							For nV9L := 1 To Len(aGravaV9L)
								If aGravaV9L[nV9L][1] + aGravaV9L[nV9L][2] + aGravaV9L[nV9L][3] + aGravaV9L[nV9L][4] == aGravaT14[nT14][1] + aGravaT14[nT14][2] + aGravaT14[nT14][3] + aGravaT14[nT14][4]
									oModel:GetModel("MODEL_V9L"):lValid := .T.

									If nV9LAdd > 1
										oModel:GetModel("MODEL_V9L"):AddLine()
									EndIf

									oModel:LoadValue("MODEL_V9L", "V9L_TPINSC", aGravaV9L[nV9L][5])
									oModel:LoadValue("MODEL_V9L", "V9L_NRINSC", aGravaV9L[nV9L][6])
									oModel:LoadValue("MODEL_V9L", "V9L_VLRADV", aGravaV9L[nV9L][7])
								
									nV9LAdd++
								EndIf
							Next
						EndIf
											
						/*------------------------------------------
						T6C - Informações da Remuneração Trab.
						--------------------------------------------*/
						nT6CAdd := 1	
						For nT6C := 1 to Len( aGravaT6C )	

							If aGravaT14[nT14][1]+aGravaT14[nT14][2]+aGravaT14[nT14][3]+aGravaT14[nT14][4] == aGravaT6C[nT6C][1]+aGravaT6C[nT6C][2]+aGravaT6C[nT6C][3]+aGravaT6C[nT6C][4]
								
								oModel:GetModel( 'MODEL_T6C' ):LVALID := .T.
								
								If nT6CAdd > 1
									oModel:GetModel( "MODEL_T6C" ):AddLine()
								EndIf
								
								oModel:LoadValue( "MODEL_T6C", "T6C_ESTABE", aGravaT6C[nT6C][5] )

								/*------------------------------------------
								T6D - Informações da Remuneração Trab.
								--------------------------------------------*/
								nT6DAdd := 1	
								For nT6D := 1 to Len( aGravaT6D )	

									If aGravaT6D[nT6D][1]+aGravaT6D[nT6D][2]+aGravaT6D[nT6D][3]+aGravaT6D[nT6D][4]+aGravaT6D[nT6D][5] == aGravaT6C[nT6C][1]+aGravaT6C[nT6C][2]+aGravaT6C[nT6C][3]+aGravaT6C[nT6C][4]+aGravaT6C[nT6C][5]
										
										oModel:GetModel( 'MODEL_T6D' ):LVALID := .T.
										
										If nT6DAdd > 1
											oModel:GetModel( "MODEL_T6D" ):AddLine()
										EndIf
										
										oModel:LoadValue( "MODEL_T6D", "T6D_IDTRAB", aGravaT6D[nT6D][6] )
										oModel:LoadValue( "MODEL_T6D", "T6D_CODCAT", aGravaT6D[nT6D][7] )
										oModel:LoadValue( "MODEL_T6D", "T6D_NOMEVE", aGravaT6D[nT6D][8] )

										/*------------------------------------------
											T6E - Itens da Remuneração Trab.
										--------------------------------------------*/
										nT6EAdd := 1	
										For nT6E := 1 to Len( aGravaT6E )		
											
											If aGravaT6D[nT6D][1] + aGravaT6D[nT6D][2] + aGravaT6D[nT6D][3] +;
												aGravaT6D[nT6D][4] + aGravaT6D[nT6D][5] + aGravaT6D[nT6D][6] +;
												aGravaT6D[nT6D][7] + aGravaT6D[nT6D][9] == aGravaT6E[nT6E][1] +; 
												aGravaT6E[nT6E][2] + aGravaT6E[nT6E][3] + aGravaT6E[nT6E][4] +; 
												aGravaT6E[nT6E][5] + aGravaT6E[nT6E][6] + aGravaT6E[nT6E][7] +;
												aGravaT6E[nT6E][14]

												oModel:GetModel( 'MODEL_T6E' ):LVALID := .T.
												
												If nT6EAdd > 1
													oModel:GetModel( "MODEL_T6E" ):AddLine()
												EndIf
												
												oModel:LoadValue( "MODEL_T6E", "T6E_IDRUBR",	aGravaT6E[nT6E][8] )
												oModel:LoadValue( "MODEL_T6E", "T6E_QTDRUB",	aGravaT6E[nT6E][9] )
												oModel:LoadValue( "MODEL_T6E", "T6E_FATORR",	aGravaT6E[nT6E][10] )
												oModel:LoadValue( "MODEL_T6E", "T6E_VLRRUB",	aGravaT6E[nT6E][12] )
												oModel:LoadValue( "MODEL_T6E", "T6E_APURIR",	aGravaT6E[nT6E][13] )
																						
												nT6EAdd++
												
											EndIf			
										Next //nT6E
									
										nT6DAdd++		
									EndIf			
								Next //nT6D
							
								nT6CAdd++		
							EndIf		
						Next //nT6C
					
						/*------------------------------------------
							T61 - Ident Lei  Remun. Per.  Anter.
						--------------------------------------------*/
						For nT61 := 1 to Len( aGravaT61 )
						
							If aGravaT14[nT14][1]+aGravaT14[nT14][2]+aGravaT14[nT14][3]+aGravaT14[nT14][4] == aGravaT61[nT61][1]+aGravaT61[nT61][2]+aGravaT61[nT61][3]+aGravaT61[nT61][4]								
								
								oModel:GetModel( 'MODEL_T61' ):LVALID	:= .T.
								
								If nT61 > 1
									oModel:GetModel( "MODEL_T61" ):AddLine()
								EndIf
								
								oModel:LoadValue( "MODEL_T61", "T61_ORGSUC", aGravaT61[nT61][8] )							

								/*------------------------------------------
								T6H - Informações do Periodo
								--------------------------------------------*/
								nT6HAdd := 1	
								For nT6H := 1 to Len( aGravaT6H )		
									
									If aGravaT61[nT61][1]+aGravaT61[nT61][2]+aGravaT61[nT61][3]+aGravaT61[nT61][4]+DtoC(aGravaT61[nT61][5])+aGravaT61[nT61][6]+aGravaT61[nT61][8] == aGravaT6H[nT6H][1]+aGravaT6H[nT6H][2]+aGravaT6H[nT6H][3]+aGravaT6H[nT6H][4]+DtoC(aGravaT6H[nT6H][5])+aGravaT6H[nT6H][6]+aGravaT6H[nT6H][8]
										
										oModel:GetModel( 'MODEL_T6H' ):LVALID := .T.
										
										If nT6HAdd > 1
											oModel:GetModel( "MODEL_T6H" ):AddLine()
										EndIf
										
										oModel:LoadValue( "MODEL_T6H", "T6H_PERREF", aGravaT6H[nT6H][7] )
										
										/*------------------------------------------
										T6I - Ident. do Estabelecimento
										--------------------------------------------*/
										nT6IAdd := 1	
										For nT6I := 1 to Len( aGravaT6I )		
											
											If aGravaT6H[nT6H][1]+aGravaT6H[nT6H][2]+aGravaT6H[nT6H][3]+aGravaT6H[nT6H][4]+DtoC(aGravaT6H[nT6H][5])+aGravaT6H[nT6H][6]+aGravaT6H[nT6H][7]+aGravaT6H[nT6H][8] == aGravaT6I[nT6I][1]+aGravaT6I[nT6I][2]+aGravaT6I[nT6I][3]+aGravaT6I[nT6I][4]+DtoC(aGravaT6I[nT6I][5])+aGravaT6I[nT6I][6]+aGravaT6I[nT6I][7]+aGravaT6I[nT6I][9]
												
												oModel:GetModel( 'MODEL_T6I' ):LVALID := .T.
												
												If nT6IAdd > 1
													oModel:GetModel( "MODEL_T6I" ):AddLine()
												EndIf
												
												oModel:LoadValue( "MODEL_T6I", "T6I_ESTABE", aGravaT6I[nT6I][8] )
								
												/*------------------------------------------
												T6J - Informações da Remuneração Trab.
												--------------------------------------------*/
												nT6JAdd := 1	
												For nT6J := 1 to Len( aGravaT6J )
													
													If aGravaT6I[nT6I][1]+aGravaT6I[nT6I][2]+aGravaT6I[nT6I][3]+aGravaT6I[nT6I][4]+DtoC(aGravaT6I[nT6I][5])+aGravaT6I[nT6I][6]+aGravaT6I[nT6I][7]+aGravaT6I[nT6I][8]+aGravaT6I[nT6I][9] == aGravaT6J[nT6J][1]+aGravaT6J[nT6J][2]+aGravaT6J[nT6J][3]+aGravaT6J[nT6J][4]+DtoC(aGravaT6J[nT6J][5])+aGravaT6J[nT6J][6]+aGravaT6J[nT6J][7]+aGravaT6J[nT6J][8]+aGravaT6J[nT6J][11]
														
														oModel:GetModel( 'MODEL_T6J' ):LVALID := .T.
														
														If nT6JAdd > 1
															oModel:GetModel( "MODEL_T6J" ):AddLine()
														EndIf
														
														oModel:LoadValue( "MODEL_T6J", "T6J_IDTRAB", aGravaT6J[nT6J][9] )
														oModel:LoadValue( "MODEL_T6J", "T6J_NOMEVE", aGravaT6J[nT6J][12] )														
											
														/*------------------------------------------
															T6K - Itens da Remuneração Trab.
														--------------------------------------------*/
														nT6KAdd := 1	
														For nT6K := 1 to Len( aGravaT6K )		
															
															If aGravaT6J[nT6J][1] + aGravaT6J[nT6J][2] + aGravaT6J[nT6J][3] +; 
																aGravaT6J[nT6J][4] + DToC(aGravaT6J[nT6J][5]) + aGravaT6J[nT6J][6] +; 
																aGravaT6J[nT6J][7] + aGravaT6J[nT6J][8] + aGravaT6J[nT6J][9] +; 
																aGravaT6J[nT6J][10] + aGravaT6J[nT6J][13] == aGravaT6K[nT6K][1] +; 
																aGravaT6K[nT6K][2] + aGravaT6K[nT6K][3] + aGravaT6K[nT6K][4] +; 
																DToC(aGravaT6K[nT6K][5]) + aGravaT6K[nT6K][6] + aGravaT6K[nT6K][7] +; 
																aGravaT6K[nT6K][8] + aGravaT6K[nT6K][9] + aGravaT6K[nT6K][10] +;
																aGravaT6K[nT6K][17]
																
																oModel:GetModel( 'MODEL_T6K' ):LVALID := .T.
																
																If nT6KAdd > 1
																	oModel:GetModel( "MODEL_T6K" ):AddLine()
																EndIf
																
																oModel:LoadValue( "MODEL_T6K", "T6K_IDRUBR",	aGravaT6K[nT6K][11] )
																oModel:LoadValue( "MODEL_T6K", "T6K_QTDRUB",	aGravaT6K[nT6K][12] )
																oModel:LoadValue( "MODEL_T6K", "T6K_FATORR",	aGravaT6K[nT6K][13] )
																oModel:LoadValue( "MODEL_T6K", "T6K_VLRRUB",	aGravaT6K[nT6K][15] )															
																oModel:LoadValue( "MODEL_T6K", "T6K_APURIR",	aGravaT6K[nT6K][16] )															
																
																nT6KAdd++															
															EndIf			
														Next //nT6K
																
														nT6JAdd++		
													EndIf			
												Next //nT6J
												
												nT6IAdd++
											EndIf			
										Next //nT6I
							
										nT6HAdd++
									EndIf			
								Next //nT6H
						
								nT61Add++
							EndIf					
						Next //nT61		
					Next //nT14			
																								
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao que sera gravada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVersao := xFunGetVer()		 
													
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿		
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		                                                                      				         
					oModel:LoadValue( 'MODEL_C91', 'C91_VERSAO', cVersao 	)
					oModel:LoadValue( 'MODEL_C91', 'C91_VERANT', cVerAnt 	)
					oModel:LoadValue( 'MODEL_C91', 'C91_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_C91', 'C91_PROTUL', "" 		)
					oModel:LoadValue( 'MODEL_C91', 'C91_EVENTO', "A" 		)
					oModel:LoadValue( "MODEL_C91", 'C91_NOMEVE', "S1202" 	)

					// Tratamento para limpar o ID unico do xml
					cAliasPai := "C91"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf
					
					FwFormCommit( oModel )
					TAFAltStat( 'C91', " " )
		
				ElseIf C91->C91_STATUS == ( "2" )

					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno := .F.

				ElseIf C91->C91_STATUS == ( "6" )

					TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
					lRetorno := .F.

				ElseIf C91->C91_STATUS == "7"

					TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"  
					lRetorno:= .F.

				Else

					//alteração sem transmissão
					If TafColumnPos( "C91_LOGOPE" )
						cLogOpeAnt := C91->C91_LOGOPE
					EndIf

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C91', 'C91_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'C91', " " )  

				EndIf
			EndIf	
		
		ElseIf nOperation == MODEL_OPERATION_DELETE       
												
			TAFAltStat( 'C91', " " )
			FwFormCommit( oModel )	

			If C91->C91_EVENTO == "A" .Or. C91->C91_EVENTO == "E"
				TAFRastro( 'C91', 1, C91->(C91_ID + C91_VERANT), .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
			EndIf
			
		EndIf
							
	End Transaction 

	If !lRetorno 
		// Define a mensagem de erro que será exibida após o Return do SaveModel
		TAFMsgDel(oModel,.T.)
	EndIf

Return lRetorno 

//-------------------------------------------------------------------
/*/{Protheus.doc}ValidModel
Funcao de validação do Model
@author Rodrigo Nicolino
@since 25/02/2022
@version 1/.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )

	Local aAreaC91   as array
	Local cMsgErr    as character
	Local lRet       as logical
	Local nOperation as numeric
	Local oModelC91  as object

	Default oModel   := Nil

	aAreaC91   := C91->( GetArea() )
	cMsgErr    := ""
	lRet       := .T.
	nOperation := Nil
	oModelC91  := Nil

	oModelC91  := oModel:GetModel( "MODEL_C91" )
	nOperation := oModel:GetOperation()
	cTrabal    := oModelC91:GetValue( "C91_TRABAL" )
	cCPF       := oModelC91:GetValue( "C91_CPF"    )
	cNome      := oModelC91:GetValue( "C91_NOME"   )
	cDtNasc    := oModelC91:GetValue( "C91_NASCTO" )

	If isBlind()
		lTAUTO     := oModelC91:GetValue( "C91_ORIEVE" ) == "TAUTO"
	EndIf

	If (nOperation == MODEL_OPERATION_INSERT .And. !lTAUTO)

		If Empty(cTrabal)
			cMsgErr := STR0024 //"Obrigatório informar o campo Id. Trab."
			lRet := .F.
		EndIf

	ElseIf (nOperation == MODEL_OPERATION_INSERT .And. lTAUTO)

		If Empty(cCPF) .Or. Empty(cNome) .Or. Empty(cDtNasc)
			cMsgErr := STR0025 //"Obrigatório informar os campos Cpf, Nome e Dt. Nascto."
			lRet := .F.
		EndIf

	EndIf

	If !lRet
		oModel:SetErrorMessage(, , , , ,cMsgErr, , , )
	EndIf

	RestArea( aAreaC91 )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF413Xml
Funcao de geracao do XML para atender o registro S-1200
Quando a rotina for chamada o registro deve estar posicionado

@Param:

@Return:
cXml - Estrutura do Xml do Layout S-2320

@author Vitor Siqueira
@since 08/01/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF413Xml( cAlias, nRecno, nOpc, lJob, lAutomato, cFile )

	Local aMensal     	as array
	Local lV9L          as logical
	Local cIndRRA       as character
    Local cXmlProcJud   as character
    Local cXmlIdeAdv    as character
	Local cCPF       	as character
	Local cEvenOri   	as character
	Local cIdTabRub  	as character
	Local cIDTrab    	as character
	Local cLayout     	as character
	Local cMatric    	as character
	Local cOrgSuc     	as character
	Local cReg       	as character
	Local cXml        	as character
	Local cXmlEstab   	as character
	Local cXmlItRem   	as character
	Local cXmlRemPAnt 	as character
	Local cXmlSucVin  	as character
	Local lFindAuto   	as logical
	Local lOrgSuc     	as logical
	Local lXmlVLd       as logical

	Default cAlias    := ""
	Default cFile     := ""
	Default lAutomato := .F.
	Default lJob      := .F.
	Default nOpc      := 1
	Default nRecno    := 0
	
	aMensal     := {}
	cCPF        := ""
	cEvenOri    := ""
	cIdTabRub   := ""
	cIDTrab     := ""
	cLayout     := "1202"
	cMatric     := ""
	cOrgSuc     := ""
	cReg        := "RmnRPPS"
	cXml        := ""
	cXmlEstab   := ""
	cXmlItRem   := ""
	cXmlRemPAnt := ""
	cXmlSucVin  := ""
	cIndRRA 	:= "" 
	lV9L 		:= .T.
	cXmlProcJud := ""
	cXmlIdeAdv 	:= ""
	lFindAuto   := .F.
	lOrgSuc     := .F.
	lXmlVLd     := IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF413XML' ),.T.)

	If  lXmlVLd

		If  C91->C91_EVENTO $ "I|A|E"

			cEvenOri := C91->C91_ORIEVE
			cIDTrab	 := C91->C91_TRABAL
						
			If cEvenOri != "S2190"

				C9V->( DBSetOrder( 2 ) )

				If C9V->( MsSeek( xFilial( "C9V" ) + cIDTrab + "1" ) )

					If C9V->C9V_NOMEVE == "TAUTO"
						lFindAuto := .T.
					EndIf

				Else 

					C9V->( DbSetOrder (3) )

					If C9V->( MsSeek( xFilial("C9V") + C91->C91_CPF + "1") )
						If C9V->C9V_NOMEVE == "TAUTO"
							lFindAuto := .T.
						EndIf
					EndIf

				EndIf
			EndIf			

			AADD(aMensal,C91->C91_INDAPU) 
			
			If Len(Alltrim(C91->C91_PERAPU)) <= 4
				AADD(aMensal,C91->C91_PERAPU)  
			Else
				AADD(aMensal,substr(C91->C91_PERAPU, 1, 4) + '-' + substr(C91->C91_PERAPU, 5, 2) )
			EndIf   
				
			/*----------------------------------------------------------
					Inicio da TAG ideTrabalhador
			----------------------------------------------------------*/		
			cXml +=	"<ideTrabalhador>"
			
			If !Empty(C91->C91_CPF)
				cCPF :=	C91->C91_CPF
			Else
				C9V->( DbSetOrder( 2 ) )
				C9V->( MsSeek ( xFilial("C9V") + cIDTrab + "1") )    	
				
				cCPF :=	C9V->C9V_CPF
			EndIf
						
			cXml +=	xTafTag("cpfTrab", cCPF)
			
			T14->( DbSetOrder( 1 ) )

			If T14->( MsSeek ( xFilial("T14")+C91->(C91_ID+C91_VERSAO+C91_INDAPU+C91_PERAPU+C91_TRABAL)))   					
				
				While !T14->(Eof()) .AND. AllTrim(C91->(C91_ID+C91_VERSAO+C91_INDAPU+C91_PERAPU+C91_TRABAL)) == AllTrim(T14->(T14_ID+T14_VERSAO+T14_INDAPU+T14_PERAPU+T14_TRABAL))		
					
					T61->( DbSetOrder( 1 ) )	

					If T61->( MsSeek ( xFilial("T61")+T14->(T14_ID+T14_VERSAO+T14_INDAPU+T14_PERAPU+T14_TRABAL+T14_IDEDMD)))  								
						
						While !T61->(Eof()) .AND. AllTrim(T14->(T14_ID+T14_VERSAO+T14_INDAPU+T14_PERAPU+T14_TRABAL+T14_IDEDMD)) == AllTrim(T61->(T61_ID+T61_VERSAO+T61_INDAPU+T61_PERAPU+T61_TRABAL+T61_DEMPAG))							
							
							If T61->T61_ORGSUC == "1"
								lOrgSuc := .T.
							EndIf

							T14->( DbSkip() )
						EndDo

					EndIf

					T14->( DbSkip() )
				EndDo			
			EndIf

			If lFindAuto .OR. Empty(C91->C91_TRABAL) .Or. ( lOrgSuc .And. cEvenOri == "TAUTO" )

				If lOrgSuc

					xTafTagGroup("sucessaoVinc";
								,{{"cnpjOrgaoAnt", C91->C91_CNPJEA,, .F. } ;
								, {"matricAnt"	 , C91->C91_MATREA,, .T. } ;
								, {"dtExercicio" , C91->C91_DTINVI,, .F. } ;
								, {"observacao"	 , C91->C91_OBSVIN,, .T. }};
								, @cXmlSucVin;
								,;
								, .F. )

				EndIf

				xTafTagGroup("infoComplem";	
							,{{"nmTrab"	 , Iif(Empty(C91->C91_TRABAL), C91->C91_NOME  , Posicione("C9V", 2, xFilial("C9V") + C91->C91_TRABAL + "1", "C9V_NOME"))  ,, .F. } ;
							, {"dtNascto", Iif(Empty(C91->C91_TRABAL), C91->C91_NASCTO, Posicione("C9V", 2, xFilial("C9V") + C91->C91_TRABAL + "1", "C9V_DTNASC")),, .F. }};
							, @cXml;
							, {{ "sucessaoVinc" , cXmlSucVin, 0 }};
							, .F.;
							, .T.)

			EndIf			
			
			cXml +=	"</ideTrabalhador>"
			
			/*----------------------------------------------------------
					Inicio da TAG dmDev
			----------------------------------------------------------*/
			T14->( DbSetOrder( 1 ) )

			If T14->( MsSeek ( xFilial("T14")+C91->(C91_ID+C91_VERSAO+C91_INDAPU+C91_PERAPU+C91_TRABAL)))   					
				
				While !T14->(Eof()) .And. AllTrim(C91->(C91_ID+C91_VERSAO+C91_INDAPU+C91_PERAPU+C91_TRABAL)) == AllTrim(T14->(T14_ID+T14_VERSAO+T14_INDAPU+T14_PERAPU+T14_TRABAL))		

					cXml +=	"<dmDev>"	
					
					cXml +=	xTafTag( "ideDmDev" , T14->T14_IDEDMD , , .F. )	
					cXml +=	xTafTag("codCateg", Posicione("C87", 1, xFilial("C87") + T14->T14_CODCAT, "C87_CODIGO"),, .F.)	

					If lSimplBeta .And. TafColumnPos("T14_INDRRA")
						V9L->( DbSetOrder( 1 ) )
						cXmlProcJud := ""
						cXmlIdeAdv	:= ""
						lV9L 		:= .T.

                        cIndRRA := IIF( T14->T14_INDRRA == "1", "S", "" )
                        cXml += xTafTag("indRRA", cIndRRA,, .T.)

                            If cIndRRA == "S"

                                If __cPicVAdv == Nil
                                    __cPicVAdv := PesqPict("T14", "T14_VLRADV")
                                    __cPicVCus := PesqPict("T14", "T14_VLRCUS")
                                    __cPicQRRA := PesqPict("T14", "T14_QTMRRA")                                 
                                EndIf
                                
                                xTafTagGroup("despProcJud"; 
                                    ,{{"vlrDespCustas"      , T14->T14_VLRCUS, __cPicVCus, .F.};
                                    , {"vlrDespAdvogados"   , T14->T14_VLRADV, __cPicVAdv, .F.}};                       
                                    , @cXmlProcJud)
                                
                                If V9L->(MsSeek(T14->(T14_FILIAL+T14_ID+T14_VERSAO+T14_INDAPU+T14_PERAPU+T14_TRABAL+T14_IDEDMD)))

                                    While lV9L
                                        
                                        xTafTagGroup("ideAdv";  
                                            ,{{"tpInsc" , V9L->V9L_TPINSC,            , .F.};
                                            , {"nrInsc" , V9L->V9L_NRINSC,            , .F.};
                                            , {"vlrAdv" , V9L->V9L_VLRADV, __cPicVAdv , .F.}};                      
                                            , @cXmlIdeAdv)
                                        
                                        V9L->(DbSkip())
                                        lV9L := !V9L->(Eof()) .And. AllTrim(V9L->(V9L_ID+V9L_VERSAO+V9L_INDAPU+V9L_PERAPU+V9L_TRABAL+V9L_DEMPAG)) == AllTrim(T14->(T14_ID+T14_VERSAO+T14_INDAPU+T14_PERAPU+T14_TRABAL+T14_IDEDMD))
                                    
                                    EndDo

                                EndIf
                                
                                xTafTagGroup("infoRRA"; 
                                    ,{{"tpProcRRA"      ,T14->T14_TPPRRA ,           , .F.};
                                    , {"nrProcRRA"      ,T14->T14_NRPRRA ,           , .F.};
                                    , {"descRRA"        ,T14->T14_DESCRA ,           , .F.};
                                    , {"qtdMesesRRA"    ,T14->T14_QTMRRA , __cPicQRRA, .F.}};                                   
                                    , @cXml;
                                    , { { "despProcJud" , cXmlProcJud    , 0   };
                                    , {   "ideAdv"      , cXmlIdeAdv     , 0 } })

                            EndIf

                        EndIf						
					
					/*----------------------------------------------------------
							Inicio da TAG infoPerApur
					----------------------------------------------------------*/
					T6C->( DbSetOrder( 1 ) )	                            
					If T6C->( MsSeek ( xFilial("T6C")+T14->(T14_ID+T14_VERSAO+T14_INDAPU+T14_PERAPU+T14_TRABAL+T14_IDEDMD)))   
						If TafColumnPos("T6E_DTRABA")
							cT6DSeek := "T6D_ID + T6D_VERSAO + T6D_INDAPU + T6D_PERAPU + T6D_TRABAL + T6D_DEMPAG + T6D_ESTABE + T6D_IDTRAB + T6D_DTRABAL + T6D_CODCAT"
							cT6ESeek := "T6E_ID + T6E_VERSAO + T6E_INDAPU + T6E_PERAPU + T6E_TRABAL + T6E_DEMPAG + T6E_ESTABE + T6E_IDTRAB + T6E_DTRABAL + T6E_CODCAT"

							T6E->(DBSetOrder(3))
						Else
							cT6DSeek := "T6D_ID + T6D_VERSAO + T6D_INDAPU + T6D_PERAPU + T6D_TRABAL + T6D_DEMPAG + T6D_ESTABE + T6D_IDTRAB + T6D_CODCAT"
							cT6ESeek := "T6E_ID + T6E_VERSAO + T6E_INDAPU + T6E_PERAPU + T6E_TRABAL + T6E_DEMPAG + T6E_ESTABE + T6E_IDTRAB + T6E_CODCAT"

							T6E->(DBSetOrder(1))
						EndIf	   

						cXml +=	"<infoPerApur>"	 				
						
						/*----------------------------------------------------------
							Inicio da TAG ideEstab
						----------------------------------------------------------*/
						While !T6C->(Eof()) .And. AllTrim(T14->(T14_ID+T14_VERSAO+T14_INDAPU+T14_PERAPU+T14_TRABAL+T14_IDEDMD)) == AllTrim(T6C->(T6C_ID+T6C_VERSAO+T6C_INDAPU+T6C_PERAPU+T6C_TRABAL+T6C_DEMPAG))						
							
							cXml +=	"<ideEstab>"				
							cXml +=		xTafTag("tpInsc", POSICIONE("C92",1, xFilial("C92")+T6C->T6C_ESTABE,"C92_TPINSC") , , .F. )
							cXml +=		xTafTag("nrInsc", POSICIONE("C92",1, xFilial("C92")+T6C->T6C_ESTABE,"C92_NRINSC") , , .F. )

							/*----------------------------------------------------------
								Inicio da TAG remunPerApur
							----------------------------------------------------------*/									
							T6D->( DbSetOrder( 1 ) )	                            
							If T6D->( MsSeek ( xFilial("T6D")+T6C->(T6C_ID+T6C_VERSAO+T6C_INDAPU+T6C_PERAPU+T6C_TRABAL+T6C_DEMPAG+T6C_ESTABE)) )    				
								
								While !T6D->(Eof()) .And. AllTrim(T6C->(T6C_ID+T6C_VERSAO+T6C_INDAPU+T6C_PERAPU+T6C_TRABAL+T6C_DEMPAG+T6C_ESTABE)) == AllTrim(T6D->(T6D_ID+T6D_VERSAO+T6D_INDAPU+T6D_PERAPU+T6D_TRABAL+T6D_DEMPAG+T6D_ESTABE))	 
																																			
									cXml +=	"<remunPerApur>"

									If TafColumnPos("T6E_DTRABA")
										cMatric := IIf(Empty(T6D->T6D_DTRABAL), GetMatric(T6D->T6D_NOMEVE, T6D->T6D_IDTRAB), T6D->T6D_DTRABAL)
									Else
										cMatric := GetMatric(T6D->T6D_NOMEVE, T6D->T6D_IDTRAB)
									EndIf
																
									cXml +=	xTafTag("matricula", cMatric,, .T.)

									/*----------------------------------------------------------
										Inicio da TAG itensRemun
									----------------------------------------------------------*/                         
									If T6E->(MsSeek(xFilial("T6E") + T6D->(&(cT6DSeek))))
										
										While !T6E->(EOF()) .And. AllTrim(T6D->(&(cT6DSeek))) == AllTrim(T6E->(&(cT6ESeek)))
											
											cIdTabRub := POSICIONE("C8R",1, xFilial("C8R")+T6E->T6E_IDRUBR,"C8R_IDTBRU")
											
											cXml +=	"<itensRemun>"
											cXml +=		xTafTag("codRubr"	, AllTrim(Posicione("C8R",1, xFilial("C8R")+T6E->T6E_IDRUBR,"C8R_CODRUB")),                             , .F.     )	  
											cXml +=		xTafTag("ideTabRubr", AllTrim(Posicione("T3M",1, xFilial("T3M")+cIdTabRub,"T3M_ID"))          ,                             , .F.     )
											cXml +=		xTafTag("qtdRubr"	, T6E->T6E_QTDRUB                                                         , PesqPict("T6E","T6E_QTDRUB"), .T., .T.)
											cXml +=		xTafTag("fatorRubr"	, T6E->T6E_FATORR                                                         , PesqPict("T6E","T6E_FATORR"), .T., .T.)
											cXml +=		xTafTag("vrRubr"	, T6E->T6E_VLRRUB                                                         , PesqPict("T6E","T6E_VLRRUB"), .F., .T.)	
											cXml +=		xTafTag("indApurIR"	, T6E->T6E_APURIR                                                         ,                             , .F.     )	
											cXml +=	"</itensRemun>" 
											
											T6E->(DbSkip())

										EndDo 						
																										
									Else										
										//Seek retorna .f. -> grupo de tags obrigatorio					
										xTafTagGroup("itensRemun"	,{ {"codRubr"		,	''	, , .F. } ;
																	,  {"ideTabRubr"	,	''	, , .F. } ;
																	,  {"qtdRubr"		,	''	, , .T. } ;
																	,  {"fatorRubr"		,	''	, , .T. } ;
																	,  {"vrRubr"		,	''	, , .F. } ;
																	,  {"indApurIR"		,	''	, , .F. } } ;
																	,  @cXml , , .T. )
										
									EndIf
																																				
									cXml +=	"</remunPerApur>"			
									
									T6D->(DbSkip())

								EndDo
							
							Else								
									xTafTagGroup("itensRemun"	,{ {"codRubr"		,	''	, , .F. } ;
																,  {"ideTabRubr"	,	''	, , .F. } ;
																,  {"qtdRubr"		,	''	, , .T. } ;
																,  {"fatorRubr"		,	''	, , .T. } ;
																,  {"vrRubr"		,	''	, , .F. } ;
																,  {"indApurIR"		,	''	, , .F. } } ;
																,  @cXmlItRem , , .T. )
								
									xTafTagGroup("remunPerApur"	,{ {"matricula"		,	''	, , .T. } };
																,  @cXml ;
																, { { "itensRemun" , cXmlItRem , 1 } } ;
																, .T. )														
							EndIf			
							
							cXml +=	"</ideEstab>"
							
							T6C->(DbSkip())

						EndDo
						
						cXml +=	"</infoPerApur>"

					EndIf		
			
					/*----------------------------------------------------------
							Inicio da TAG infoPerAnt
					----------------------------------------------------------*/
					T61->( DbSetOrder( 1 ) )	                            
					If T61->( MsSeek ( xFilial("T61")+T14->(T14_ID+T14_VERSAO+T14_INDAPU+T14_PERAPU+T14_TRABAL+T14_IDEDMD)))  
						If TafColumnPos("T6E_DTRABA")
							cT6JSeek := "T6J_ID + T6J_VERSAO + T6J_INDAPU + T6J_PERAPU + T6J_TRABAL + T6J_DEMPAG + DToS(T6J_DTLEI) + T6J_NUMLEI + T6J_PERREF + T6J_ESTABE + T6J_IDTRAB + T6J_DTRABA + T6J_CODCAT"
							cT6KSeek := "T6K_ID + T6K_VERSAO + T6K_INDAPU + T6K_PERAPU + T6K_TRABAL + T6K_DEMPAG + DToS(T6K_DTLEI) + T6K_NUMLEI + T6K_PERREF + T6K_ESTABE + T6K_IDTRAB + T6K_DTRABA + T6K_CODCAT"

							T6K->(DBSetOrder(3))
						Else
							cT6JSeek := "T6J_ID + T6J_VERSAO + T6J_INDAPU + T6J_PERAPU + T6J_TRABAL + T6J_DEMPAG + DToS(T6J_DTLEI) + T6J_NUMLEI + T6J_PERREF + T6J_ESTABE + T6J_IDTRAB + T6J_CODCAT"
							cT6KSeek := "T6K_ID + T6K_VERSAO + T6K_INDAPU + T6K_PERAPU + T6K_TRABAL + T6K_DEMPAG + DToS(T6K_DTLEI) + T6K_NUMLEI + T6K_PERREF + T6K_ESTABE + T6K_IDTRAB + T6K_CODCAT"

							T6K->(DBSetOrder(1))
						EndIf	   

						cXml +=	"<infoPerAnt>"	 				
									
							While !T61->(Eof()) .And. AllTrim(T14->(T14_ID+T14_VERSAO+T14_INDAPU+T14_PERAPU+T14_TRABAL+T14_IDEDMD)) == AllTrim(T61->(T61_ID+T61_VERSAO+T61_INDAPU+T61_PERAPU+T61_TRABAL+T61_DEMPAG))							
								
								/*----------------------------------------------------------
								Inicio da TAG ideADC
								----------------------------------------------------------*/
								cOrgSuc := T61->T61_ORGSUC
								cXml 	+= xTafTag("remunOrgSuc" ,  xFunTrcSN(cOrgSuc, 1),,.F.)
								
								/*----------------------------------------------------------
									Inicio da TAG idePeriodo
								----------------------------------------------------------*/							
								T6H->( DbSetOrder( 1 ) )
								If T6H->( MsSeek( xFilial("T6H")+T61->(T61_ID+T61_VERSAO+T61_INDAPU+T61_PERAPU+T61_TRABAL+T61_DEMPAG+DTOS(T61_DTLEI)+T61_NUMLEI)))
									
									While !T6H->(Eof()) .And.  AllTrim(T61->(T61_ID+T61_VERSAO+T61_INDAPU+T61_PERAPU+T61_TRABAL+T61_DEMPAG+DTOS(T61_DTLEI)+T61_NUMLEI+cOrgSuc)) == AllTrim(T6H->(T6H_ID+T6H_VERSAO+T6H_INDAPU+T6H_PERAPU+T6H_TRABAL+T6H_DEMPAG+DTOS(T6H_DTLEI)+T6H_NUMLEI+cOrgSuc))							
										
										cXml +=	"<idePeriodo>"
										
										If Len(Alltrim(T6H->T6H_PERREF)) <= 4
											cXml +=		xTafTag("perRef",T6H->T6H_PERREF,,.F.)
										Else
											cXml +=		xTafTag("perRef",Substr(T6H->T6H_PERREF, 1, 4) + '-' +  substr(T6H->T6H_PERREF, 5, 2) ,,.F.)
										EndIf
					
										/*----------------------------------------------------------
											Inicio da TAG ideEstab
										----------------------------------------------------------*/
										T6I->( DbSetOrder( 1 ) )
										If T6I->( MsSeek( xFilial("T6I")+T6H->(T6H_ID+T6H_VERSAO+T6H_INDAPU+T6H_PERAPU+T6H_TRABAL+T6H_DEMPAG+DTOS(T6H_DTLEI)+T6H_NUMLEI+T6H_PERREF)))
											
											While !T6I->(Eof()) .And. AllTrim(T6H->(T6H_ID+T6H_VERSAO+T6H_INDAPU+T6H_PERAPU+T6H_TRABAL+T6H_DEMPAG+DTOS(T6H_DTLEI)+T6H_NUMLEI+T6H_PERREF+cOrgSuc)) == AllTrim(T6I->(T6I_ID+T6I_VERSAO+T6I_INDAPU+T6I_PERAPU+T6I_TRABAL+T6I_DEMPAG+DTOS(T6I_DTLEI)+T6I_NUMLEI+T6I_PERREF+cOrgSuc))						
												cXml +=	"<ideEstab>"				
												cXml +=		xTafTag("tpInsc", POSICIONE("C92",1, xFilial("C92")+T6I->T6I_ESTABE,"C92_TPINSC"),,.F.)
												cXml +=		xTafTag("nrInsc", POSICIONE("C92",1, xFilial("C92")+T6I->T6I_ESTABE,"C92_NRINSC"),,.F.)
											
												/*----------------------------------------------------------
													Inicio da TAG remunPerAnt
												----------------------------------------------------------*/   			
												T6J->( DbSetOrder( 1 ) )
												If T6J->( MsSeek( xFilial("T6J")+T6I->(T6I_ID+T6I_VERSAO+T6I_INDAPU+T6I_PERAPU+T6I_TRABAL+T6I_DEMPAG+DTOS(T6I_DTLEI)+T6I_NUMLEI+T6I_PERREF+T6I_ESTABE)))	
													
													While !T6J->(Eof()) .And. AllTrim(T6I->(T6I_ID+T6I_VERSAO+T6I_INDAPU+T6I_PERAPU+T6I_TRABAL+T6I_DEMPAG+DTOS(T6I_DTLEI)+T6I_NUMLEI+T6I_PERREF+T6I_ESTABE+cOrgSuc)) == AllTrim(T6J->(T6J_ID+T6J_VERSAO+T6J_INDAPU+T6J_PERAPU+T6J_TRABAL+T6J_DEMPAG+DTOS(T6J_DTLEI)+T6J_NUMLEI+T6J_PERREF+T6J_ESTABE+cOrgSuc))	 
																																			
														cXml +=	"<remunPerAnt>"
														
														If TafColumnPos("T6E_DTRABA")
															cMatric := IIf(Empty(T6J->T6J_DTRABA), GetMatric(T6J->T6J_NOMEVE, T6J->T6J_IDTRAB), T6J->T6J_DTRABA)
														Else
															cMatric := GetMatric(T6J->T6J_NOMEVE, T6J->T6J_IDTRAB)
														EndIf

														cXml +=	xTafTag("matricula", cMatric,, .T.)

														/*----------------------------------------------------------
															Inicio da TAG itensRemun
														----------------------------------------------------------*/ 		
														T6K->( DbSetOrder( 1 ) )	                            
														If T6K->(MsSeek(xFilial("T6K") + T6J->(&(cT6JSeek))))
															
															While !T6K->(EOF()) .And. AllTrim(T6J->(&(cT6JSeek))) == AllTrim(T6K->(&(cT6KSeek)))
					
																cIdTabRub := POSICIONE("C8R",1, xFilial("C8R")+T6K->T6K_IDRUBR,"C8R_IDTBRU")
																
																cXml +=		"<itensRemun>"
																cXml +=			xTafTag("codRubr"		, AllTrim(Posicione("C8R",1, xFilial("C8R")+T6K->T6K_IDRUBR,"C8R_CODRUB")),                             , .F.     )  												
																cXml +=			xTafTag("ideTabRubr"	, AllTrim(Posicione("T3M",1, xFilial("T3M")+cIdTabRub,"T3M_ID"))          ,                             , .F.     )
																cXml +=			xTafTag("qtdRubr"		, T6K->T6K_QTDRUB                                                         , PesqPict("T6K","T6K_QTDRUB"), .T., .T.)
																cXml +=			xTafTag("fatorRubr"		, T6K->T6K_FATORR                                                         , PesqPict("T6K","T6K_FATORR"), .T., .T.)
																cXml +=			xTafTag("vrRubr"		, T6K->T6K_VLRRUB                                                         , PesqPict("T6K","T6K_VLRRUB"), .F., .T.)
																cXml +=			xTafTag("indApurIR"		, T6K->T6K_APURIR                                                         ,                             , .F.     )
																cXml +=		"</itensRemun>" 
														
																T6K->(DbSkip())
															EndDo 																
														
														Else
														
															//Seek retorna .f. -> grupo de tags obrigatorio
															xTafTagGroup("itensRemun"	,{ {"codRubr"		,	''	, , .F. } ;
																						,  {"ideTabRubr"	,	''	, , .F. } ;
																						,  {"qtdRubr"		,	''	, , .T. } ;
																						,  {"fatorRubr"		,	''	, , .T. } ;
																						,  {"vrRubr"		,	''	, , .F. } ;
																						,  {"indApurIR"		,	''	, , .F. } } ;
																						,  @cXml , , .T.)
															
														EndIf
																																						
														cXml +=	"</remunPerAnt>"			
														
														T6J->(DbSkip())
													EndDo
												
												Else
													//Seek retorna .f. -> grupo de tags obrigatorio
													
													xTafTagGroup("itensRemun"	,{ {"codRubr"		,	''	, , .F. } ;
																				,  {"ideTabRubr"	,	''	, , .F. } ;
																				,  {"qtdRubr"		,	''	, , .T. } ;
																				,  {"fatorRubr"		,	''	, , .T. } ;
																				,  {"vrRubr"		,	''	, , .F. } ;
																				,  {"indApurIR"		,	''	, , .F. } } ;
																				,  @cXmlItRem , , .T. )
												
													//Seek retorna .f. -> grupo de tags obrigatorio													
													xTafTagGroup("remunPerAnt"	,{ {"matricula"		,	''	, , .T. } } ;
																				,  @cXml ;
																				, { { "itensRemun" , cXmlItRem , 1 } } ;
																				, .T. )																												
												EndIf	
												
												cXml +=	"</ideEstab>"
												
												T6I->(DbSkip())
											EndDo
										
										Else
										
											//Seek retorna .f. -> grupo de tags obrigatorio
											xTafTagGroup("ideEstab"		,{ {"tpInsc"		,	''	, , .F. } ;
																		,  {"nrInsc"		,	''	, , .F. } } ;
																		,  @cXml , , .T.)
										
										EndIf
												
										cXml +=	"</idePeriodo>"
										
										T6H->(DbSkip())
									EndDo
								
								Else
								
									//Seek retorna .f. -> grupo de tags obrigatorio									
									xTafTagGroup("itensRemun"	,{ {"codRubr"		,	''	, , .F. } ;
																,  {"ideTabRubr"	,	''	, , .F. } ;
																,  {"qtdRubr"		,	''	, , .T. } ;
																,  {"fatorRubr"		,	''	, , .T. } ;
																,  {"vrRubr"		,	''	, , .F. } ;
																,  {"indApurIR"		,	''	, , .F. } } ;
																,  @cXmlItRem , , .T. )									

									//Seek retorna .f. -> grupo de tags obrigatorio
									xTafTagGroup("remunPerAnt"	,{ {"matricula"		,	''	, , .T. } } ;
																,  @cXmlRemPAnt ;
																, { { "itensRemun" , cXmlItRem , 1 } } ;
																, .T. )									
									
									//Seek retorna .f. -> grupo de tags obrigatorio
									xTafTagGroup("ideEstab"		,{ {"tpInsc"		,	''	, , .F. } ;
																,  {"nrInsc"		,	''	, , .F. } } ;
																,  @cXmlEstab ;
																, { { "remunPerAnt" , cXmlRemPAnt , 1 } } ;
																, .T.)
									
									//Seek retorna .f. -> grupo de tags obrigatorio
									xTafTagGroup("idePeriodo"	,{ {"perRef"		,	''	, , .F. } } ;
																,  @cXml ;
																, { { "ideEstab" , cXmlEstab , 1 } } ;
																, .T.)
								
								EndIf
								
								T61->(DbSkip())

							EndDo	
					
						cXml +=	"</infoPerAnt>"
					
					EndIf	     
				
					cXml +=	"</dmDev>"	
					T14->(DbSkip())
				
				EndDo
			
			Else
				xTafTagGroup("dmDev"	,{ {"ideDmDev"		,	''	, , .F. }  	;
										,  {"codCateg"		,	''	, , .F. } } ;
										,  @cXml , , .T. )				
			EndIf
																																					
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do cabecalho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cXml := xTafCabXml(cXml,"C91",cLayout,cReg,aMensal)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa gravacao do registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lJob
			If lAutomato
				xTafGerXml( cXml, cLayout,,, .F.,, @cFile )
			Else
				xTafGerXml( cXml, cLayout )
			EndIf
		EndIf
	EndIf
	
Return cXml 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF413Grv
@type			function
@description	Função de gravação para atender o registro S-1200.
@author			Vitor Siqueira
@since			08/01/2016
@version		1.0
@param			cLayout		-	Nome do Layout que está sendo enviado
@param			nOpc		-	Opção a ser realizada ( 3 = Inclusão, 4 = Alteração, 5 = Exclusão )
@param			cFilEv		-	Filial do ERP para onde as informações deverão ser importadas
@param			oXML		-	Objeto com as informações a serem manutenidas ( Outras Integrações )
@param			cOwner
@param			cFilTran
@param			cPredeces
@param			nTafRecno
@param			cComplem
@param			cGrpTran
@param			cEmpOriGrp
@param			cFilOriGrp
@param			cXmlID		-	Atributo Id, único para o XML do eSocial. Utilizado para importação de dados de clientes migrando para o TAF
@return			lRet		-	Variável que indica se a importação foi realizada, ou seja, se as informações foram gravadas no banco de dados
@param			aIncons		-	Array com as inconsistências encontradas durante a importação
/*/
//-------------------------------------------------------------------
Function TAF413Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID, cEvtOri,lMigrador, lDepGPE, cKey, cMatrC9V, lLaySmpTot, lExclCMJ, oTransf, cXmls )

	Local aAuxInfComp  as array
	Local aChave       as array
	Local aEvento      as array
	Local aIncons      as array
	Local aInfComp     as array
	Local aRules       as array
	Local cChave       as character
	Local cCmpsNoUpd   as character
	Local cCodEvent    as character
	Local cCPF         as character
	Local cEvenOri     as character
	Local cEvtTrab     as character
	Local cIDCateg     as character
	Local cIdTrab      as character
	Local cIdTrbT6D    as character
	Local cIdTrbT6J    as character
	Local cInconMsg    as character
	Local cLogOpeAnt   as character
	Local cMatrcT6D    as character
	Local cMatrcT6J    as character
	Local cMatric      as character
	Local cOrgSuc      as character
	Local cPathPerAnt  as character
	Local cPathPerApu  as character
	Local cPeriodo     as character
	Local cT14Path     as character
	Local cT61Path     as character
	Local cT6CPath     as character
	Local cT6DPath     as character
	Local cT6EPath     as character
	Local cT6HPath     as character
	Local cT6IPath     as character
	Local cT6JPath     as character
	Local cT6KPath     as character
	Local cV9LPath     as character
	Local lExistTrab   as logical
	Local lInfoCompl   as logical
	Local lRet         as logical
	Local nJ           as numeric
	Local nlI          as numeric
	Local nSeqErrGrv   as numeric
	Local nT14         as numeric
	Local nT6C         as numeric
	Local nT6D         as numeric
	Local nT6E         as numeric
	Local nT6H         as numeric
	Local nT6I         as numeric
	Local nT6J         as numeric
	Local nT6K         as numeric
	Local nV9L         as numeric
	Local oModel       as object

	Private lVldModel  := .T.
	Private oDados     := Nil

	Default cComplem   := ""
	Default cEmpOriGrp := ""
	Default cFilEv     := ""
	Default cFilOriGrp := ""
	Default cFilTran   := ""
	Default cGrpTran   := ""
	Default cLayout    := ""
	Default cOwner     := ""
	Default cPredeces  := ""
	Default cXmlID     := ""
	Default cXmls	   := ""
	Default nOpc       := 1
	Default nTafRecno  := 0
	Default oXML       := Nil
	Default cEvtOri	   := ""	
	Default lMigrador  := .F.
	Default lDepGPE	   := .F.	
	Default cKey	   := ""
	Default cMatrC9V   := ""
	Default lLaySmpTot := .F.
	Default lExclCMJ   := .F.
	Default oTransf	   := Nil

	aAuxInfComp  := {}
	aChave       := {}
	aEvento      := {}
	aIncons      := {}
	aInfComp     := {}
	aRules       := {}
	cChave       := ""
	cCmpsNoUpd   := "|C91_FILIAL|C91_ID|C91_VERSAO|C91_NOMEVE|C91_VERANT|C91_PROTPN|C91_EVENTO|C91_STATUS|C91_ATIVO|"
	cCodEvent    := ""
	cCPF         := ""
	cEvenOri     := ""
	cEvtTrab     := ""
	cIDCateg     := ""
	cIdTrab      := ""
	cIdTrbT6D    := ""
	cIdTrbT6J    := ""
	cInconMsg    := ""
	cLogOpeAnt   := ""
	cMatrcT6D    := ""
	cMatrcT6J    := ""
	cMatric      := ""
	cOrgSuc      := ""
	cPathPerAnt  := "/eSocial/evtRmnRPPS/dmDev[1]/infoPerAnt/idePeriodo[1]/ideEstab[1]/remunPerAnt[1]"
	cPathPerApu  := "/eSocial/evtRmnRPPS/dmDev[1]/infoPerApur/ideEstab[1]/remunPerApur[1]"
	cPeriodo     := ""
	cT14Path     := ""
	cT61Path     := ""
	cT6CPath     := ""
	cT6DPath     := ""
	cT6EPath     := ""
	cT6HPath     := ""
	cT6IPath     := ""
	cT6JPath     := ""
	cT6KPath     := ""
	cV9LPath     := ""
	cXmlInteg    := cXmls
	lExistTrab   := .F.
	lInfoCompl   := .F.
	lRet         := .F.
	nJ           := 0
	nlI          := 0
	nSeqErrGrv   := 0
	nT14         := 0
	nT6C         := 0
	nT6D         := 0
	nT6E         := 0
	nT6H         := 0
	nT6I         := 0
	nT6J         := 0
	nT6K         := 0
	nV9L         := 0
	oModel       := Nil


	cCodEvent 	:= Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
	oDados 		:= oXML

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chave do registro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPeriodo  := FTafGetVal( "/eSocial/evtRmnRPPS/ideEvento/perApur", "C", .F., @aIncons, .F. )
	
	Aadd( aChave, {"C", "C91_INDAPU", FTafGetVal( "/eSocial/evtRmnRPPS/ideEvento/indApuracao", "C", .F., @aIncons, .F. )  , .T.} ) 
	cChave += Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1])

	If At("-", cPeriodo) > 0
		Aadd( aChave, {"C", "C91_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
		cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])	
	Else
		Aadd( aChave, {"C", "C91_PERAPU", cPeriodo  , .T.} ) 
		cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])		
	EndIf

	If oDados:XPathHasNode("/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem")

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRmnRPPS/ideTrabalhador/cpfTrab" ) )
			Aadd( aInfComp, {"C9V_CPF", FTafGetVal("/eSocial/evtRmnRPPS/ideTrabalhador/cpfTrab", "C", .F.,, .F. ) } )  
		EndIf	

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/nmTrab" ) )
			Aadd( aInfComp, {"C9V_NOME", FTafGetVal("/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/nmTrab", "C", .F.,, .F. ) } )  
		EndIf	

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/dtNascto" ) )
			Aadd( aInfComp, {"C9V_DTNASC", FTafGetVal("/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/dtNascto", "D", .F.,, .F. ) } )  
		EndIf

		If oDados:XPathHasNode("/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc")

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc/cnpjOrgaoAnt" ) )
				Aadd( aInfComp, {"CUP_CNPJEA", FTafGetVal("/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc/cnpjOrgaoAnt", "C", .F.,, .F. ) } )  
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc/matricAnt" ) )
				Aadd( aInfComp, {"CUP_MATANT", FTafGetVal("/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc/matricAnt", "C", .F.,, .F. ) } )  
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc/dtExercicio" ) )
				Aadd( aInfComp, {"CUP_DTINVI", FTafGetVal("/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc/dtExercicio", "D", .F.,, .F. ) } )  
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc/observacao" ) )
				Aadd( aInfComp, {"CUP_OBSVIN", FTafGetVal("/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc/observacao", "M", .F.,, .F. ) } )  
			EndIf

		EndIf

		aAuxInfComp := aClone(aInfComp)

	EndIf

	cCPF := FTafGetVal("/eSocial/evtRmnRPPS/ideTrabalhador/cpfTrab", "C", .F.,, .F.)

	If oDados:XPathHasNode(cPathPerApu + "/matricula") .AND. !Empty(FTafGetVal(cPathPerApu + "/matricula", "C", .F.,, .F.))

		aEvento		:= TAFIdFunc(cCPF, FTafGetVal( cPathPerApu + "/matricula", "C", .F.,, .F.), @cInconMsg, @nSeqErrGrv)
		cIdTrab 	:= aEvento[1]
		cEvenOri	:= aEvento[2]

	ElseIf oDados:XPathHasNode(cPathPerAnt + "/matricula") .AND. !Empty(FTafGetVal(cPathPerAnt + "/matricula", "C", .F.,, .F.))

		aEvento		:= TAFIdFunc(cCPF, FTafGetVal(cPathPerAnt + "/matricula", "C", .F.,, .F.), @cInconMsg, @nSeqErrGrv)
		cIdTrab 	:= aEvento[1]
		cEvenOri	:= aEvento[2]

	Else

		cMatric		:= FTafGetVal(cPathPerAnt + "/matricula", "C", .F.,, .F.)
		cIDCateg	:= FGetIdInt("codCateg", "", FTafGetVal("/eSocial/evtRmnRPPS/dmDev[1]/codCateg", "C", .F.,, .F.),, .F.,, @cInconMsg, @nSeqErrGrv)
		cIdTrab 	:= TAFGetIdFunc(cCPF, cPeriodo,, "cpfTrab", cCPF,, cMatric, cIDCateg, .F.,,, "codCateg", cIDCateg)

		If Empty(cIdTrab) .AND. !Empty(aInfComp)
			cIdTrab := TAFGetIdFunc(cCPF, cPeriodo,, "cpfTrab", cCPF, aInfComp, cMatric,, .F.,,,,,,,,,,, cLayout)
		ElseIf Empty(cIdTrab)
			cIdTrab := TAFGetIdFunc(cCPF, cPeriodo,, "cpfTrab", cCPF,, cMatric, cIDCateg, .F.,,,,,,, @cInconMsg, @nSeqErrGrv)
		EndIf

		cEvenOri   	:= Posicione("C9V", 2, xFilial("C9V") + cIdTrab + "1", "C9V_NOMEVE")
		aInfComp 	:= aClone(aAuxInfComp)

	EndIf

	lInfoCompl := oDados:XPathHasNode("/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem") .AND. (Empty(cIdTrab) .OR. Posicione("C9V", 2, xFilial("C9V") + cIdTrab + "1", "C9V_NOMEVE") == "TAUTO")

	If !Empty(cIdTrab)
		lExistTrab := .T.
	EndIf

	Aadd( aChave, {"C", "C91_TRABAL", cIdTrab , .T.} )
	Aadd( aChave, {"C", "C91_NOMEVE", "S1202" , .T.} )
	cChave += Padr( aChave[ 3, 3 ], Tamsx3( aChave[ 3, 2 ])[1])	

	//Verifica se o evento ja existe na base
	("C91")->( DbSetOrder( 2 ) )
	If ("C91")->( MsSeek( FTafGetFil( cFilEv , @aIncons , "C91" ) + cChave + 'S1202' + '1' ) )
		If !C91->C91_STATUS $ ( "2|4|6|" )
			nOpc := 4
		EndIf
	EndIf

	Begin Transaction	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao para validar se a operacao desejada pode ser realizada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FTafVldOpe( 'C91', 2, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA413', cCmpsNoUpd )		    	      				     		    	      	    		    		    		    		    																					

			If TafColumnPos( "C91_LOGOPE" )
				cLogOpeAnt := C91->C91_LOGOPE
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrego array com os campos De/Para de gravacao das informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRules := TAF413Rul( @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner, lExistTrab, lInfoCompl, aInfComp, cMatric, cIDCateg, cIdTrab, cEvenOri )								                
					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5 
							
				/*-----------------------------------------
				C91 - Informações de Folha de Pagamento
				-------------------------------------------*/	
				oModel:LoadValue( "MODEL_C91", "C91_INDAPU", C91->C91_INDAPU)              
				oModel:LoadValue( "MODEL_C91", "C91_PERAPU", C91->C91_PERAPU)              
				oModel:LoadValue( "MODEL_C91", "C91_TRABAL", C91->C91_TRABAL)   
				oModel:LoadValue( "MODEL_C91", "C91_NOMEVE", "S1202" 		) 
				oModel:LoadValue( "MODEL_C91", "C91_ORIEVE", C91->C91_ORIEVE )         
		
				If TAFColumnPos( "C91_XMLID" )
					oModel:LoadValue( "MODEL_C91", "C91_XMLID", cXmlID )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o aRules para gravar as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nlI := 1 To Len( aRules )                 					
					oModel:LoadValue( "MODEL_C91", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F. ) )
				Next
	
				oModel:LoadValue( "MODEL_C91", "C91_ORIEVE", cEvenOri )				
				
				If Findfunction("TAFAltMan")
					If nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C91', 'C91_LOGOPE' , '1', '' )
					ElseIf nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C91', 'C91_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf
			
				cEvtTrab := cEvenOri
				
				/*------------------------------------------
					T14 - Ident. demonstrativos de valores 
				--------------------------------------------*/		
				nT14 := 1
				cT14Path := "/eSocial/evtRmnRPPS/dmDev[" + CVALTOCHAR(nT14) + "]"
				
				If nOpc == 4
					For nJ := 1 to oModel:GetModel( 'MODEL_T14' ):Length()
						oModel:GetModel( 'MODEL_T14' ):GoLine(nJ)
						oModel:GetModel( 'MODEL_T14' ):DeleteLine()
					Next nJ
				EndIf
				
				nT14 := 1
				While oDados:XPathHasNode( cT14Path ) 
				
					oModel:GetModel( 'MODEL_T14' ):LVALID	:= .T.					

					If nOpc == 4 .Or. nT14 > 1
						oModel:GetModel( 'MODEL_T14' ):AddLine()
					EndIf	
					
					If oDados:XPathHasNode( cT14Path )
						oModel:LoadValue( "MODEL_T14", "T14_IDEDMD",  FTafGetVal( cT14Path + "/ideDmDev", "C", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T14", "T14_NOMEVE", "S1202" )
						oModel:LoadValue( "MODEL_T14", "T14_CODCAT", FGetIdInt( "codCateg", "", cT14Path + "/codCateg",,,,@cInconMsg, @nSeqErrGrv))					
					EndIf
					
					If lSimplBeta .And. TafColumnPos("T14_INDRRA")

						If oDados:XPathHasNode(	cT14Path + "/indRRA" )
							cIndRRA := FTafGetVal( cT14Path + "/indRRA", "C", .F., @aIncons, .F. )
							oModel:LoadValue( "MODEL_T14", "T14_INDRRA" , IIF( cIndRRA == "S", "1", "") )
						EndIf
						
						If oDados:XPathHasNode(	cT14Path + "/infoRRA/tpProcRRA" )
							oModel:LoadValue( "MODEL_T14", "T14_TPPRRA" , FTafGetVal( cT14Path + "/infoRRA/tpProcRRA", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(	cT14Path + "/infoRRA/nrProcRRA" )
							oModel:LoadValue( "MODEL_T14", "T14_NRPRRA" , FTafGetVal( cT14Path + "/infoRRA/nrProcRRA", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(	cT14Path + "/infoRRA/descRRA"  )
							oModel:LoadValue( "MODEL_T14", "T14_DESCRA" , FTafGetVal( cT14Path + "/infoRRA/descRRA", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(	cT14Path + "/infoRRA/qtdMesesRRA" )
							oModel:LoadValue( "MODEL_T14", "T14_QTMRRA" , FTafGetVal( cT14Path + "/infoRRA/qtdMesesRRA", "N", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(	cT14Path + "/infoRRA/despProcJud/vlrDespCustas" )
							oModel:LoadValue( "MODEL_T14", "T14_VLRCUS" , FTafGetVal( cT14Path + "/infoRRA/despProcJud/vlrDespCustas", "N", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode(	cT14Path + "/infoRRA/despProcJud/ vlrDespAdvogados" )
							oModel:LoadValue( "MODEL_T14", "T14_VLRADV" , FTafGetVal( cT14Path + "/infoRRA/despProcJud/vlrDespAdvogados", "N", .F., @aIncons, .F. ) )
						EndIf

						/*---------------------------------------
						   V9L - Identificação dos advogados
						----------------------------------------*/
						nV9L:= 1
						cV9LPath := cT14Path + "/infoRRA/ideAdv[" + CVALTOCHAR(nV9L) + "]"

						While oDados:XPathHasNode(cV9LPath)

							oModelV9L := oModel:GetModel( 'MODEL_V9L' )
							oModel:GetModel( 'MODEL_V9L' ):LVALID	:= .T.

							If nV9L > 1
								oModel:GetModel( 'MODEL_V9L' ):AddLine()
							EndIf

							If oDados:XPathHasNode(	cV9LPath + "/tpInsc")
								oModel:LoadValue( "MODEL_V9L", "V9L_TPINSC"	, FTafGetVal( cV9LPath + "/tpInsc", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV9LPath + "/nrInsc")
								oModel:LoadValue( "MODEL_V9L", "V9L_NRINSC"	, FTafGetVal( cV9LPath + "/nrInsc", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV9LPath + "/vlrAdv")
								oModel:LoadValue( "MODEL_V9L", "V9L_VLRADV"	, FTafGetVal( cV9LPath + "/vlrAdv", "N", .F., @aIncons, .F. ) )
							EndIf

							nV9L++
							cV9LPath := cT14Path + "/infoRRA/ideAdv[" + CVALTOCHAR(nV9L) + "]"

						EndDo

					EndIf
					
					/*------------------------------------------------
						Info. relativas ao período de apuração
							T6C - Identificação do Estabelecimen
					-------------------------------------------------*/          
					nT6C:= 1
					cT6CPath := cT14Path +"/infoPerApur/ideEstab[" + CVALTOCHAR(nT6C) + "]"
					
					If nOpc == 4 
						For nJ := 1 to oModel:GetModel( 'MODEL_T6C' ):Length()
							oModel:GetModel( 'MODEL_T6C' ):GoLine(nJ)
							oModel:GetModel( 'MODEL_T6C' ):DeleteLine()
						Next nJ
					EndIf
					
					nT6C := 1
					While oDados:XPathHasNode(cT6CPath)
											
						oModel:GetModel( 'MODEL_T6C' ):LVALID	:= .T.					
				
						If nOpc == 4 .Or. nT6C > 1
							oModel:GetModel( 'MODEL_T6C' ):AddLine()
						EndIf
						
						If oDados:XPathHasNode(	cT6CPath + "/tpInsc" , cT6CPath + "/nrInsc" )
							oModel:LoadValue( "MODEL_T6C", "T6C_ESTABE", FGetIdInt( "tpInsc", "nrInsc", cT6CPath + "/tpInsc" , cT6CPath + "/nrInsc",,,@cInconMsg, @nSeqErrGrv) ) 
						EndIf

						/*------------------------------------------
							T6D - Remun Trabal. Período Apuração
						--------------------------------------------*/      
						nT6D:= 1
						cT6DPath := cT6CPath+"/remunPerApur[" + CVALTOCHAR(nT6D) + "]"
						
						If nOpc == 4 
							For nJ := 1 to oModel:GetModel( 'MODEL_T6D' ):Length()
								oModel:GetModel( 'MODEL_T6D' ):GoLine(nJ)
								oModel:GetModel( 'MODEL_T6D' ):DeleteLine()
							Next nJ
						EndIf
						
						nT6D := 1
						While oDados:XPathHasNode(cT6DPath)
												
							oModel:GetModel( 'MODEL_T6D' ):LVALID	:= .T.					
					
							If nOpc == 4 .Or. nT6D > 1
								oModel:GetModel( 'MODEL_T6D' ):AddLine()
							EndIf
														
							If oDados:XPathHasNode(cT6DPath + "/matricula")
								cMatrcT6D := FTafGetVal( cT6DPath + "/matricula", "C", .F., @aIncons, .F. )	
								cIdTrbT6D := TAFIdFunc(cCPF, cMatrcT6D, @cInconMsg, @nSeqErrGrv)[1]										
								
								If TafColumnPos("T6E_DTRABA")
									oModel:LoadValue("MODEL_T6D", "T6D_DTRABA", cMatrcT6D)
								EndIf
							EndIf													
							
							oModel:LoadValue("MODEL_T6D", "T6D_IDTRAB", IIf(Empty(cIdTrbT6D), cIdTrab, cIdTrbT6D))
							oModel:LoadValue("MODEL_T6D", "T6D_NOMEVE", cEvenOri)						
													
							/*------------------------------------------
								T6E - Itens da Remuneração Trab.
							--------------------------------------------*/								
							nT6E:= 1
							cT6EPath := cT6DPath+"/itensRemun[" + CVALTOCHAR(nT6E) + "]"
							
							If nOpc == 4 
								For nJ := 1 to oModel:GetModel( 'MODEL_T6E' ):Length()
									oModel:GetModel( 'MODEL_T6E' ):GoLine(nJ)
									oModel:GetModel( 'MODEL_T6E' ):DeleteLine()
								Next nJ
							EndIf
		
							nT6E := 1
							While oDados:XPathHasNode(cT6EPath)
													
								oModel:GetModel( 'MODEL_T6E' ):LVALID	:= .T.					
						
								If nOpc == 4 .Or. nT6E > 1
									oModel:GetModel( 'MODEL_T6E' ):AddLine()
								EndIf	
										
								If oDados:XPathHasNode(	cT6EPath + "/ideTabRubr")
									cIdTabR := TAFIdTabRub( FTafGetVal( cT6EPath + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cT6EPath + "/codRubr", "C", .F., @aIncons, .F. ), cT6EPath, @cInconMsg, @nSeqErrGrv, @aIncons  )
								Else
									cIdTabR := ""
								EndIf

								If oDados:XPathHasNode(cT6EPath + "/codRubr")
									oModel:LoadValue( "MODEL_T6E", "T6E_IDRUBR"  ,  FGetIdInt( "codRubr", "ideTabRubr", FTafGetVal( cT6EPath + "/codRubr", "C", .F., @aIncons, .F. ),cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,StrTran(cPeriodo,"-","")))
								EndIf
								
								If oDados:XPathHasNode(cT6EPath + "/qtdRubr")
									oModel:LoadValue( "MODEL_T6E", "T6E_QTDRUB"	, FTafGetVal( cT6EPath + "/qtdRubr", "N", .F., @aIncons, .F. ) )
								EndIf
								
								If oDados:XPathHasNode(cT6EPath + "/fatorRubr")
									oModel:LoadValue( "MODEL_T6E", "T6E_FATORR"	, FTafGetVal( cT6EPath + "/fatorRubr", "N", .F., @aIncons, .F. ) )
								EndIf
								
								If oDados:XPathHasNode(cT6EPath + "/vrRubr")
									oModel:LoadValue( "MODEL_T6E", "T6E_VLRRUB"	, FTafGetVal( cT6EPath + "/vrRubr", "N", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode(cT6EPath + "/indApurIR")
									oModel:LoadValue( "MODEL_T6E", "T6E_APURIR"	, FTafGetVal( cT6EPath + "/indApurIR", "C", .F., @aIncons, .F. ) )
								EndIf	
								
								nT6E++
								cT6EPath := cT6DPath+"/itensRemun[" + CVALTOCHAR(nT6E) + "]"

							EndDo
							
							nT6D++
							cT6DPath := cT6CPath+"/remunPerApur[" + CVALTOCHAR(nT6D) + "]"

						EndDo
						
						nT6C++
						cT6CPath := cT14Path+"/infoPerApur/ideEstab[" + CVALTOCHAR(nT6C) + "]"

					EndDo
						
		
					/*-----------------------------------------------
						Remuneração relativa a Períodos Anteriores.
							T61 - Remun. Per.  Anter.
					------------------------------------------------*/
					cT61Path := cT14Path + "/infoPerAnt"
					
					If oDados:XPathHasNode(cT61Path)
											
						oModel:GetModel( 'MODEL_T61' ):LVALID	:= .T.					
						
						If oDados:XPathHasNode( cT61Path + "/remunOrgSuc" )
							cOrgSuc := xFunTrcSN(FTafGetVal( cT61Path + "/remunOrgSuc", "C" , .F., @aIncons, .F. ), 2)
							oModel:LoadValue( "MODEL_T61", "T61_ORGSUC", cOrgSuc )
						EndIf					
						
						/*------------------------------------------
								T6H - Informações do Periodo
						--------------------------------------------*/
						nT6H:= 1
						cT6HPath := cT61Path + "/idePeriodo[" + CVALTOCHAR(nT6H) + "]"
								
						If nOpc == 4
							For nJ := 1 to oModel:GetModel( 'MODEL_T6H' ):Length()
								oModel:GetModel( 'MODEL_T6H' ):GoLine(nJ)
								oModel:GetModel( 'MODEL_T6H' ):DeleteLine()
							Next nJ
						EndIf
						
						nT6H := 1
						While oDados:XPathHasNode(cT6HPath)
												
							oModel:GetModel( 'MODEL_T6H' ):LVALID	:= .T.					
					
							If nOpc == 4 .Or. nT6H > 1
								oModel:GetModel( 'MODEL_T6H' ):AddLine()
							EndIf
							
							If oDados:XPathHasNode(  cT6HPath + "/perRef" )
								If At("-", FTafGetVal( cT6HPath + "/perRef", "C", .F., @aIncons, .F. )) > 0
									oModel:LoadValue( "MODEL_T6H", "T6H_PERREF"	, StrTran( FTafGetVal( cT6HPath + "/perRef", "C", .F., @aIncons, .F. ), "-", "" ) )
								Else
									oModel:LoadValue( "MODEL_T6H", "T6H_PERREF"	,FTafGetVal( cT6HPath + "/perRef", "C", .F., @aIncons, .F. ) )		
								EndIf
							EndIf
										
							/*---------------------------------------
								T6I - Ident. do Estabelecimento
							---------------------------------------*/          
							nT6I := 1
							cT6IPath := cT6HPath +"/ideEstab[" + CVALTOCHAR(nT6I) + "]"
							
							If nOpc == 4 .And. oDados:XPathHasNode( cT6IPath )
								For nJ := 1 to oModel:GetModel( 'MODEL_T6I' ):Length()
									oModel:GetModel( 'MODEL_T6I' ):GoLine(nJ)
									oModel:GetModel( 'MODEL_T6I' ):DeleteLine()
								Next nJ
							EndIf
							
							nT6I := 1
							While oDados:XPathHasNode(cT6IPath)
													
								oModel:GetModel( 'MODEL_T6I' ):LVALID	:= .T.					
						
								If nOpc == 4 .Or. nT6I > 1
									oModel:GetModel( 'MODEL_T6I' ):AddLine()
								EndIf
								
								If oDados:XPathHasNode(	cT6IPath + "/tpInsc" , cT6IPath + "/nrInsc" )
									oModel:LoadValue( "MODEL_T6I", "T6I_ESTABE", FGetIdInt( "tpInsc", "nrInsc", cT6IPath + "/tpInsc" , cT6IPath + "/nrInsc",,,@cInconMsg, @nSeqErrGrv) ) 
								EndIf
										
								/*------------------------------------------
									T6J - Remuneração Período Anterior  
								--------------------------------------------*/
								nT6J:= 1
								cT6JPath := cT6IPath+ "/remunPerAnt[" + CVALTOCHAR(nT6J) + "]"
								
								If nOpc == 4
									For nJ := 1 to oModel:GetModel( 'MODEL_T6J' ):Length()
										oModel:GetModel( 'MODEL_T6J' ):GoLine(nJ)
										oModel:GetModel( 'MODEL_T6J' ):DeleteLine()
									Next nJ
								EndIf
								
								nT6J := 1
								While oDados:XPathHasNode(cT6JPath)
														
									oModel:GetModel( 'MODEL_T6J' ):LVALID	:= .T.					
							
									If nOpc == 4 .Or. nT6J > 1
										oModel:GetModel( 'MODEL_T6J' ):AddLine()
									EndIf
									
									If oDados:XPathHasNode(cT6JPath + "/matricula")
										cMatrcT6J := FTafGetVal(cT6JPath + "/matricula", "C", .F., @aIncons, .F.)

										If TafColumnPos("T6E_DTRABA")
											oModel:LoadValue("MODEL_T6D", "T6J_DTRABA", cMatrcT6J)
										EndIf		
									EndIf													

									cIdTrbT6J := Iif(cOrgSuc == "1", "", TAFIdFunc(cCPF, cMatrcT6J, @cInconMsg, @nSeqErrGrv)[1])
									
									oModel:LoadValue("MODEL_T6J", "T6J_IDTRAB", IIf(Empty(cIdTrbT6J), cIdTrab, cIdTrbT6J))
									oModel:LoadValue("MODEL_T6J", "T6J_NOMEVE", cEvenOri)

									/*------------------------------------------
										T6K - Itens Remun. Período Anterior 
									------------------------------------------*/
									nT6K:= 1
									cT6KPath := cT6JPath + "/itensRemun[" + CVALTOCHAR(nT6K) + "]"
																						
									If nOpc == 4
										For nJ := 1 to oModel:GetModel( 'MODEL_T6K' ):Length()
											oModel:GetModel( 'MODEL_T6K' ):GoLine(nJ)
											oModel:GetModel( 'MODEL_T6K' ):DeleteLine()
										Next nJ
									EndIf
									
									nT6K := 1								        
									While oDados:XPathHasNode(cT6KPath) 
													
										oModel:GetModel( 'MODEL_T6K' ):LVALID	:= .T.					
								
										If nOpc == 4 .Or. nT6K > 1
											oModel:GetModel( 'MODEL_T6K' ):AddLine()
										EndIf			
										
										If oDados:XPathHasNode(	cT6KPath + "/ideTabRubr")
											cIdTabR := TAFIdTabRub( FTafGetVal( cT6KPath + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cT6KPath + "/codRubr", "C", .F., @aIncons, .F. ), cT6KPath, @cInconMsg, @nSeqErrGrv, @aIncons  )
										Else
											cIdTabR := ""
										EndIf

										if oDados:XPathHasNode(	cT6KPath + "/codRubr" )
											oModel:LoadValue( "MODEL_T6K", "T6K_IDRUBR"	,;
											FGetIdInt( "codRubr", "ideTabRubr", FTafGetVal( cT6KPath + "/codRubr", "C", .F., @aIncons, .F. ),cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,StrTran(cPeriodo,"-","")))
										EndIf
										
										If oDados:XPathHasNode( cT6KPath + "/qtdRubr" )
											oModel:LoadValue( "MODEL_T6K", "T6K_QTDRUB"	, FTafGetVal( cT6KPath + "/qtdRubr", "N", .F., @aIncons, .F. ) )					
										EndIf
										
										If oDados:XPathHasNode( cT6KPath + "/fatorRubr")
											oModel:LoadValue( "MODEL_T6K", "T6K_FATORR"	, FTafGetVal( cT6KPath + "/fatorRubr", "N", .F., @aIncons, .F. ) )
										EndIf
																	
										If oDados:XPathHasNode( cT6KPath + "/vrRubr")
											oModel:LoadValue( "MODEL_T6K", "T6K_VLRRUB"	, FTafGetVal( cT6KPath + "/vrRubr", "N", .F., @aIncons, .F. ) )					
										EndIf

										If oDados:XPathHasNode( cT6KPath + "/indApurIR")
											oModel:LoadValue( "MODEL_T6K", "T6K_APURIR"	, FTafGetVal( cT6KPath + "/indApurIR", "C", .F., @aIncons, .F. ) )					
										EndIf	

										nT6K++
										cT6KPath := cT6JPath + "/itensRemun[" + CVALTOCHAR(nT6K) + "]"

									EndDo			
																																															
									nT6J++
									cT6JPath := cT6IPath+ "/remunPerAnt[" + CVALTOCHAR(nT6J) + "]"

								EndDo					
			
								nT6I++
								cT6IPath := cT6HPath + "/ideEstab[" + CVALTOCHAR(nT6I) + "]"

							EndDo
							
							nT6H++
							cT6HPath := cT61Path + "/idePeriodo[" + CVALTOCHAR(nT6H) + "]"

						EndDo
						
						cT61Path	:= cT14Path+"/infoPerAnt"
						cOrgSuc		:= ""	

					EndIf
						
					nT14++
					cT14Path := "/eSocial/evtRmnRPPS/dmDev[" + CVALTOCHAR(nT14) + "]"

				EndDo
										
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetiva a operacao desejada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cInconMsg)	.And. Empty(aIncons)

				aCommit := TafFormCommit(oModel, .T.)

				If aCommit[1]
					Aadd(aIncons, Iif(Empty(aCommit[3]), "ERRO19", aCommit[3]))
				Else	
					lRet := .T.	 
				EndIf	

			Else

				Aadd(aIncons, cInconMsg)	
				DisarmTransaction()	

			EndIf	
			
			oModel:DeActivate()

			If FindFunction('TafClearModel')
				TafClearModel(oModel)
			EndIf
																							
		EndIf                                                                           	

	End Transaction  	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zerando os arrays e os Objetos utilizados no processamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize( aRules, 0 ) 
	aRules     := Nil

	aSize( aChave, 0 ) 
	aChave     := Nil    
    
Return { lRet, aIncons }     
          
//-------------------------------------------------------------------
/*/{Protheus.doc} TAF413Rul           
Regras para gravacao das informacoes do registro S-1200 do E-Social

@Param
nOper  - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return	
aRull  - Regras para a gravacao das informacoes


@author Vitor Siqueira
@since 08/01/2016
@version 1.0

/*/                        	
//-------------------------------------------------------------------
Static Function TAF413Rul( cInconMsg, nSeqErrGrv, cCodEvent, cOwner, lExistTrab, lInfoCompl, aInfComp, cMatric, cIDCateg, cIdTrab, cNomEvC9V )
                                 
	Local aRull    		as array  
	Local cPeriodo 		as character
	Local cIdTrabal	    as character
	Local cPathPerAnt   as character
	Local cPathPerApu   as character

	Default cInconMsg	:= ""
	Default nSeqErrGrv	:= 0
	Default cCodEvent	:= ""
	Default cOwner		:= ""
	Default aInfComp    := {}
	Default cIDCateg	:= ""
	Default cIdTrab		:= ""
	Default cNomEvC9V	:= ""
	Default lInfoCompl	:= .F.
	Default lExistTrab	:= .F.

	aRull    		:= {}  
	cPeriodo 		:= ""
	cIdTrabal	    := ""
	cPathPerAnt     := "/eSocial/evtRmnRPPS/dmDev[1]/infoPerAnt/idePeriodo[1]/ideEstab[1]/remunPerAnt[1]"
	cPathPerApu     := "/eSocial/evtRmnRPPS/dmDev[1]/infoPerApur/ideEstab[1]/remunPerApur[1]"

	//indApuracao
	If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRmnRPPS/ideEvento/indApuracao" ) )
		Aadd( aRull, {"C91_INDAPU", "/eSocial/evtRmnRPPS/ideEvento/indApuracao","C",.F.} ) 	 	     	
	EndIF

	//perApur
	If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRmnRPPS/ideEvento/perApur" ) )

		cPeriodo := FTafGetVal("/eSocial/evtRmnRPPS/ideEvento/perApur", "C", .F.,, .F. )
		
		If At("-", cPeriodo) > 0
			Aadd( aRull, {"C91_PERAPU", StrTran(cPeriodo, "-", "" ) ,"C",.T.} )	
		Else
			Aadd( aRull, {"C91_PERAPU", cPeriodo ,"C", .T.} )		
		EndIf   

	EndIf

	If lExistTrab

		cCPF := FTafGetVal("/eSocial/evtRmnRPPS/ideTrabalhador/cpfTrab", "C", .F.,, .F.)

		If oDados:XPathHasNode(cPathPerApu + "/matricula") .AND. !Empty(FTafGetVal(cPathPerApu + "/matricula", "C", .F.,, .F.))
			aEvento		:= TAFIdFunc(cCPF, FTafGetVal( cPathPerApu + "/matricula", "C", .F.,, .F.), @cInconMsg, @nSeqErrGrv)
			cIdTrabal 	:= aEvento[1]
		ElseIf oDados:XPathHasNode(cPathPerAnt + "/matricula") .AND. !Empty(FTafGetVal(cPathPerAnt + "/matricula", "C", .F.,, .F.))
			aEvento		:= TAFIdFunc(cCPF, FTafGetVal(cPathPerAnt + "/matricula", "C", .F.,, .F.), @cInconMsg, @nSeqErrGrv)
			cIdTrabal 	:= aEvento[1]
		ElseIf !Empty(cIdTrab) .AND. cNomEvC9V == "TAUTO"
			cIdTrabal := cIdTrab
		Else
			cIdTrabal := TAFGetIdFunc(cCPF, cPeriodo,, "cpfTrab", cCPF,, cMatric, cIDCateg, .F.,,, "codCateg", cIDCateg)

			If Empty(cIdTrabal)
				cIdTrabal := TAFGetIdFunc(cCPF, cPeriodo,, "cpfTrab", cCPF,, cMatric, cIDCateg, .F.,,,,,,, @cInconMsg, @nSeqErrGrv)
			EndIf
		Endif

		Aadd( aRull, {"C91_TRABAL"	, cIdTrabal	, "C", .T.} )

		If cNomEvC9V == "TAUTO"
			Aadd( aRull, {"C91_CPF"		, cCPF		, "C", .T.} )  
		Endif

	EndIf

	If lInfoCompl

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/nmTrab" ) )
			Aadd( aRull, {"C91_NOME", "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/nmTrab", "C", .F. } )  
		EndIf	

		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/dtNascto" ) )
			Aadd( aRull, {"C91_NASCTO", "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/dtNascto", "D", .F. } )  
		EndIf

		If oDados:XPathHasNode("/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc")

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc/cnpjOrgaoAnt" ) )
				Aadd( aRull, {"C91_CNPJEA", "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc/cnpjOrgaoAnt", "C", .F. } )  
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc/matricAnt" ) )
				Aadd( aRull, {"C91_MATREA", "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc/matricAnt", "C", .F. } )  
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc/dtExercicio" ) )
				Aadd( aRull, {"C91_DTINVI", "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc/dtExercicio", "D", .F. } )  
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc/observacao" ) )
				Aadd( aRull, {"C91_OBSVIN", "/eSocial/evtRmnRPPS/ideTrabalhador/infoComplem/sucessaoVinc/observacao", "C", .F. } )  
			EndIf

		EndIf

	EndIf

Return aRull

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@Author Vitor Henrique Ferreira
@Since 11/01/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

	Local aGrava     as array
	Local aGravaT14  as array
	Local aGravaT61  as array
	Local aGravaT6C  as array
	Local aGravaT6D  as array
	Local aGravaT6E  as array
	Local aGravaT6H  as array
	Local aGravaT6I  as array
	Local aGravaT6J  as array
	Local aGravaT6K  as array
	Local aGravaV9L  as array
	Local cApurIR    as character
	Local cEvento    as character
	Local cNomeEve   as character
	Local cOrgSuc    as character
	Local cProtocolo as character
	Local cVerAnt    as character
	Local cVersao    as character
	Local nlI        as numeric
	Local nlY        as numeric
	Local nOperation as numeric
	Local nT14       as numeric
	Local nT61       as numeric
	Local nT61Add    as numeric
	Local nT6C       as numeric
	Local nT6CAdd    as numeric
	Local nT6D       as numeric
	Local nT6DAdd    as numeric
	Local nT6E       as numeric
	Local nT6EAdd    as numeric
	Local nT6H       as numeric
	Local nT6HAdd    as numeric
	Local nT6I       as numeric
	Local nT6IAdd    as numeric
	Local nT6J       as numeric
	Local nT6JAdd    as numeric
	Local nT6K       as numeric
	Local nT6KAdd    as numeric
	Local nV9L		 as numeric
	Local oModelC91  as object
	Local oModelT14  as object
	Local oModelT61  as object
	Local oModelT6C  as object
	Local oModelT6D  as object
	Local oModelT6E  as object
	Local oModelT6H  as object
	Local oModelT6I  as object
	Local oModelT6J  as object
	Local oModelT6K  as object
	Local oModelV9L  as object

	Default lRotExc  := .F.
	Default nRecno   := 0
	Default oModel   := Nil

	aGrava     := {}
	aGravaT14  := {}
	aGravaT61  := {}
	aGravaT6C  := {}
	aGravaT6D  := {}
	aGravaT6E  := {}
	aGravaT6H  := {}
	aGravaT6I  := {}
	aGravaT6J  := {}
	aGravaT6K  := {}
	aGravaV9L  := {}
	cApurIR    := ""
	cEvento    := ""
	cNomeEve   := ""
	cOrgSuc    := ""
	cProtocolo := ""
	cVerAnt    := ""
	cVersao    := ""
	nlI        := 0
	nlY        := 0
	nOperation := 0
	nT14       := 0
	nT61       := 0
	nT61Add    := 0
	nT6C       := 0
	nT6CAdd    := 0
	nT6D       := 0
	nT6DAdd    := 0
	nT6E       := 0
	nT6EAdd    := 0
	nT6H       := 0
	nT6HAdd    := 0
	nT6I       := 0
	nT6IAdd    := 0
	nT6J       := 0
	nT6JAdd    := 0
	nT6K       := 0
	nT6KAdd    := 0
	nV9L       := 0
	nV9LAdd    := 0
	oModelC91  := Nil
	oModelT14  := Nil
	oModelT61  := Nil
	oModelT6C  := Nil
	oModelT6D  := Nil
	oModelT6E  := Nil
	oModelT6H  := Nil
	oModelT6I  := Nil
	oModelT6J  := Nil
	oModelT6K  := Nil
	oModelV9L  := Nil

	nOperation := oModel:GetOperation()

	Begin Transaction

		//Posiciona o item
		("C91")->( DBGoTo( nRecno ) )
		
		oModelC91 := oModel:GetModel( 'MODEL_C91' )   
		oModelT14 := oModel:GetModel( 'MODEL_T14' ) 
		oModelT6C := oModel:GetModel( 'MODEL_T6C' )         
		oModelT6D := oModel:GetModel( 'MODEL_T6D' )     
		oModelT6E := oModel:GetModel( 'MODEL_T6E' ) 
		oModelT6H := oModel:GetModel( 'MODEL_T6H' )  
		oModelT6I := oModel:GetModel( 'MODEL_T6I' )    									    						
		oModelT6J := oModel:GetModel( 'MODEL_T6J' )     						
		oModelT6K := oModel:GetModel( 'MODEL_T6K' )  
		oModelT61 := oModel:GetModel( 'MODEL_T61' )							  						    						  																
								
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao anterior do registro para gravacao do rastro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVerAnt   	:= oModelC91:GetValue( "C91_VERSAO" )				
		cProtocolo	:= oModelC91:GetValue( "C91_PROTUL" )
		cEvento		:= oModelC91:GetValue( "C91_EVENTO" )

		If lSimplBeta .And. TafColumnPos("T14_INDRRA")
			oModelV9L := oModel:GetModel( 'MODEL_V9L' )
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu gravo as informacoes que foram carregadas       ³
		//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
		//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
		//³nao devem ser consideradas neste momento                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		/*------------------------------------------
			C91 - Folha de Pagamento  
		--------------------------------------------*/
		For nlI := 1 To 1
			For nlY := 1 To Len( oModelC91:aDataModel[ nlI ] )			
				Aadd( aGrava, { oModelC91:aDataModel[ nlI, nlY, 1 ], oModelC91:aDataModel[ nlI, nlY, 2 ] } )									
			Next
		Next 
					
		/*------------------------------------------
			T14 - Ident. Demonstr. Val. Trabal. 
		--------------------------------------------*/
		For nT14 := 1 To oModel:GetModel( 'MODEL_T14' ):Length() 
			oModel:GetModel( 'MODEL_T14' ):GoLine(nT14)
			
			If !oModel:GetModel( 'MODEL_T14' ):IsEmpty()
				If !oModel:GetModel( 'MODEL_T14' ):IsDeleted()
					If lSimplBeta .And. TafColumnPos("T14_INDRRA")
						AAdd(aGravaT14, {	oModelC91:GetValue('C91_INDAPU'),;
											oModelC91:GetValue('C91_PERAPU'),;
											oModelC91:GetValue('C91_TRABAL'),;
											oModelT14:GetValue('T14_IDEDMD'),;
											oModelT14:GetValue('T14_CODCAT'),;
											oModelT14:GetValue('T14_CODCBO'),;
											oModelT14:GetValue('T14_NATATV'),;
											oModelT14:GetValue('T14_QTDTRB'),;
											oModelT14:GetValue('T14_INDRRA'),;
											oModelT14:GetValue('T14_TPPRRA'),;
											oModelT14:GetValue('T14_NRPRRA'),;
											oModelT14:GetValue('T14_DESCRA'),;
											oModelT14:GetValue('T14_QTMRRA'),;
											oModelT14:GetValue('T14_VLRCUS'),;
											oModelT14:GetValue('T14_VLRADV')	})

						/*------------------------------------------
							V9L - Informações de Valores Pagos
						--------------------------------------------*/
						For nV9L := 1 to oModel:GetModel( "MODEL_V9L" ):Length()
							oModel:GetModel( "MODEL_V9L" ):GoLine(nV9L)

							If !oModel:GetModel( 'MODEL_V9L' ):IsEmpty()
								If !oModel:GetModel( "MODEL_V9L" ):IsDeleted()
									aAdd(aGravaV9L, { 	oModelC91:GetValue('C91_INDAPU'),;
														oModelC91:GetValue('C91_PERAPU'),;
														oModelC91:GetValue('C91_TRABAL'),;
														oModelT14:GetValue('T14_IDEDMD'),;
														oModelV9L:GetValue('V9L_TPINSC'),;
														oModelV9L:GetValue('V9L_NRINSC'),;
														oModelV9L:GetValue('V9L_VLRADV')	})
								EndIf
							EndIf
						Next
					Else
						AAdd(aGravaT14, {	oModelC91:GetValue('C91_INDAPU'),;
											oModelC91:GetValue('C91_PERAPU'),;
											oModelC91:GetValue('C91_TRABAL'),;
											oModelT14:GetValue('T14_IDEDMD'),;
											oModelT14:GetValue('T14_CODCAT')	})
					EndIf

					/*------------------------------------------
						T6C - Identificação do Estabelecimen
					--------------------------------------------*/			  		
					For nT6C := 1 to oModel:GetModel( "MODEL_T6C" ):Length()
						oModel:GetModel( "MODEL_T6C" ):GoLine(nT6C)
						
						If !oModel:GetModel( 'MODEL_T6C' ):IsEmpty()	
							If !oModel:GetModel( "MODEL_T6C" ):IsDeleted()
								aAdd(aGravaT6C ,{oModelC91:GetValue('C91_INDAPU'),;
													oModelC91:GetValue('C91_PERAPU'),;
													oModelC91:GetValue('C91_TRABAL'),;
													oModelT14:GetValue('T14_IDEDMD'),;
													oModelT6C:GetValue('T6C_ESTABE')}) 
										
								/*------------------------------------------
									T6D - Remun Trabal. Período Apuração
								--------------------------------------------*/			  		
								For nT6D := 1 to oModel:GetModel( "MODEL_T6D" ):Length()
									oModel:GetModel( "MODEL_T6D" ):GoLine(nT6D)
									
									If !oModel:GetModel( 'MODEL_T6D' ):IsEmpty()	
										If !oModel:GetModel( "MODEL_T6D" ):IsDeleted()
											cNomeEve := oModelT6D:GetValue('T6D_NOMEVE')
											cNomeEve := Iif(!Empty(oModelC91:GetValue('C91_CPF')), "TAUTO", cNomeEve)											

											AAdd(aGravaT6D, {	oModelC91:GetValue('C91_INDAPU'),;
																oModelC91:GetValue('C91_PERAPU'),;
																oModelC91:GetValue('C91_TRABAL'),; 
																oModelT14:GetValue('T14_IDEDMD'),;
																oModelT6C:GetValue('T6C_ESTABE'),;
																oModelT6D:GetValue('T6D_IDTRAB'),;
																oModelT6D:GetValue('T6D_CODCAT'),;
																cNomeEve,;
																IIf(TafColumnPos("T6E_DTRABA"), oModelT6D:GetValue("T6D_DTRABA"), "")	})

											/*------------------------------------------
												T6E - Itens Remun. do Trabalhador   
											--------------------------------------------*/
											For nT6E := 1 to oModel:GetModel( "MODEL_T6E" ):Length()
												oModel:GetModel( "MODEL_T6E" ):GoLine(nT6E)
												
												If !oModel:GetModel( 'MODEL_T6E' ):IsEmpty()	
													If !oModel:GetModel( "MODEL_T6E" ):IsDeleted()
														cApurIR := oModelT6E:GetValue('T6E_APURIR')
														
														AAdd(aGravaT6E, {	oModelC91:GetValue('C91_INDAPU'),;
																			oModelC91:GetValue('C91_PERAPU'),;
																			oModelC91:GetValue('C91_TRABAL'),;
																			oModelT14:GetValue('T14_IDEDMD'),;
																			oModelT6C:GetValue('T6C_ESTABE'),;
																			oModelT6D:GetValue('T6D_IDTRAB'),;
																			oModelT6D:GetValue('T6D_CODCAT'),;
																			oModelT6E:GetValue('T6E_IDRUBR'),;
																			oModelT6E:GetValue('T6E_QTDRUB'),;
																			oModelT6E:GetValue('T6E_FATORR'),;
																			oModelT6E:GetValue('T6E_VLRUNT'),;
																			oModelT6E:GetValue('T6E_VLRRUB'),;
																			cApurIR,;
																			IIf(TafColumnPos("T6E_DTRABA"), oModelT6D:GetValue("T6D_DTRABA"), "")	})
														
													EndIf
												EndIf
											Next //nT6E										
										EndIf
									EndIf
								Next //nT6D		
							EndIf
						EndIf
					Next //nT6C		
						
					/*------------------------------------------
						T61 - Ident Lei  Remun. Per.  Anter.
					--------------------------------------------*/
					For nT61 := 1 To oModel:GetModel( 'MODEL_T61' ):Length() 

						oModel:GetModel( 'MODEL_T61' ):GoLine(nT61)

						If !oModel:GetModel( 'MODEL_T61' ):IsEmpty()

							If !oModel:GetModel( 'MODEL_T61' ):IsDeleted()

								cOrgSuc := oModelT61:GetValue('T61_ORGSUC')
								
								aAdd(aGravaT61 ,{oModelC91:GetValue('C91_INDAPU'),;
													oModelC91:GetValue('C91_PERAPU'),;
													oModelC91:GetValue('C91_TRABAL'),;
													oModelT14:GetValue('T14_IDEDMD'),;
													oModelT61:GetValue('T61_DTLEI' ),;
													oModelT61:GetValue('T61_NUMLEI'),;
													oModelT61:GetValue('T61_DTEFET'),;
													cOrgSuc})

								/*------------------------------------
									T6H - Informações do Periodo
								-------------------------------------*/			  		
								For nT6H := 1 to oModel:GetModel( "MODEL_T6H" ):Length()

									oModel:GetModel( "MODEL_T6H" ):GoLine(nT6H)

									If !oModel:GetModel( 'MODEL_T6H' ):IsEmpty()

										If !oModel:GetModel( "MODEL_T6H" ):IsDeleted()

											aAdd(aGravaT6H ,{	oModelC91:GetValue('C91_INDAPU'),;
																oModelC91:GetValue('C91_PERAPU'),;
																oModelC91:GetValue('C91_TRABAL'),;
																oModelT14:GetValue('T14_IDEDMD'),;
																oModelT61:GetValue('T61_DTLEI'),;
																oModelT61:GetValue('T61_NUMLEI'),;
																oModelT6H:GetValue('T6H_PERREF'),;
																cOrgSuc})
															
											/*------------------------------------
												T6I - Ident. do Estabelecimento
											-------------------------------------*/			  		
											For nT6I := 1 to oModel:GetModel( "MODEL_T6I" ):Length()

												oModel:GetModel( "MODEL_T6I" ):GoLine(nT6I)

												If !oModel:GetModel( 'MODEL_T6I' ):IsEmpty()

													If !oModel:GetModel( "MODEL_T6I" ):IsDeleted()

														aAdd(aGravaT6I ,{oModelC91:GetValue('C91_INDAPU'),;
																			oModelC91:GetValue('C91_PERAPU'),;
																			oModelC91:GetValue('C91_TRABAL'),;
																			oModelT14:GetValue('T14_IDEDMD'),;
																			oModelT61:GetValue('T61_DTLEI'),;
																			oModelT61:GetValue('T61_NUMLEI'),;
																			oModelT6H:GetValue('T6H_PERREF'),;
																			oModelT6I:GetValue('T6I_ESTABE'),;
																			cOrgSuc})
													
														/*------------------------------------------
															T6J - Informações da Remuneração Trab.
														--------------------------------------------*/			  		
														For nT6J := 1 to oModel:GetModel( "MODEL_T6J" ):Length()

															oModel:GetModel( "MODEL_T6J" ):GoLine(nT6J)

															If !oModel:GetModel( 'MODEL_T6J' ):IsEmpty()

																If !oModel:GetModel( "MODEL_T6J" ):IsDeleted()

																	cNomeEve := oModelT6J:GetValue('T6J_NOMEVE')
																	cNomeEve := Iif(!Empty(oModelC91:GetValue('C91_CPF')), "TAUTO", cNomeEve)
																	
																	AAdd(aGravaT6J, {	oModelC91:GetValue('C91_INDAPU'),;
																						oModelC91:GetValue('C91_PERAPU'),;
																						oModelC91:GetValue('C91_TRABAL'),; 
																						oModelT14:GetValue('T14_IDEDMD'),;
																						oModelT61:GetValue('T61_DTLEI'),;
																						oModelT61:GetValue('T61_NUMLEI'),;
																						oModelT6H:GetValue('T6H_PERREF'),;
																						oModelT6I:GetValue('T6I_ESTABE'),;
																						oModelT6J:GetValue('T6J_IDTRAB'),;
																						oModelT6J:GetValue('T6J_CODCAT'),;
																						cOrgSuc							,;
																						cNomeEve,;
																						IIf(TafColumnPos("T6E_DTRABA"), oModelT6J:GetValue("T6J_DTRABA"), "")	})

																	/*------------------------------------------
																		T6K - Itens da Remuneração Trab.
																	--------------------------------------------*/
																	For nT6K := 1 to oModel:GetModel( "MODEL_T6K" ):Length()

																		oModel:GetModel( "MODEL_T6K" ):GoLine(nT6K)

																		If !oModel:GetModel( 'MODEL_T6K' ):IsEmpty()

																			If !oModel:GetModel( "MODEL_T6K" ):IsDeleted()

																				cApurIR := oModelT6K:GetValue('T6K_APURIR')
																				
																				AAdd(aGravaT6K, {	oModelC91:GetValue('C91_INDAPU'),;
																									oModelC91:GetValue('C91_PERAPU'),;
																									oModelC91:GetValue('C91_TRABAL'),;
																									oModelT14:GetValue('T14_IDEDMD'),;
																									oModelT61:GetValue('T61_DTLEI')	,;
																									oModelT61:GetValue('T61_NUMLEI'),;
																									oModelT6H:GetValue('T6H_PERREF'),;
																									oModelT6I:GetValue('T6I_ESTABE'),;
																									oModelT6J:GetValue('T6J_IDTRAB'),;
																									oModelT6J:GetValue('T6J_CODCAT'),;
																									oModelT6K:GetValue('T6K_IDRUBR'),;
																									oModelT6K:GetValue('T6K_QTDRUB'),;
																									oModelT6K:GetValue('T6K_FATORR'),;
																									oModelT6K:GetValue('T6K_VLRUNT'),;
																									oModelT6K:GetValue('T6K_VLRRUB'),;
																									cApurIR,;
																									IIf(TafColumnPos("T6E_DTRABA"), oModelT6J:GetValue("T6J_DTRABA"), "")	})
																			EndIf
																		EndIf
																	Next //nT6K
																EndIf
															EndIf
														Next //nT6J
													EndIf
												EndIf
											Next //nT6I	
										EndIf
									EndIf
								Next //nT6H			
							EndIf
						EndIf
					Next // nT61	
				EndIf
			EndIf
		Next //nT14
															
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seto o campo como Inativo e gravo a versao do novo registro³
		//³no registro anterior                                       ³ 
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FAltRegAnt( 'C91', '2' )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu preciso setar a operacao do model³
		//³como Inclusao                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oModel:DeActivate()
		oModel:SetOperation( 3 ) 	
		oModel:Activate()		
						
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu realizo a inclusao do novo registro ja³
		//³contemplando as informacoes alteradas pelo usuario     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		/*------------------------------------------
			C91 - Folha de Pagamento  
		--------------------------------------------*/
		For nlI := 1 To Len( aGrava )	
			oModel:LoadValue( 'MODEL_C91', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
		Next   
		
		/*------------------------------------------
			T14 - Ident. Demonstr. Val. Trabal. 
		--------------------------------------------*/
		For nT14 := 1 To Len(aGravaT14)
			oModel:GetModel("MODEL_T14"):lValid := .T.
			
			If nT14 > 1
				oModel:GetModel("MODEL_T14"):AddLine()
			EndIf
			
			oModel:LoadValue("MODEL_T14", "T14_IDEDMD", aGravaT14[nT14][4] 	)
			oModel:LoadValue("MODEL_T14", "T14_NOMEVE", "S1202"				)
			oModel:LoadValue("MODEL_T14", "T14_CODCAT", aGravaT14[nT14][5]	)

			If lSimplBeta .And. TafColumnPos("T14_INDRRA")
				oModel:LoadValue("MODEL_T14", "T14_CODCBO", aGravaT14[nT14][6]	)
				oModel:LoadValue("MODEL_T14", "T14_NATATV", aGravaT14[nT14][7]	)
				oModel:LoadValue("MODEL_T14", "T14_QTDTRB", aGravaT14[nT14][8] 	)
				oModel:LoadValue("MODEL_T14", "T14_INDRRA", aGravaT14[nT14][9]	)
				oModel:LoadValue("MODEL_T14", "T14_TPPRRA", aGravaT14[nT14][10]	)
				oModel:LoadValue("MODEL_T14", "T14_NRPRRA", aGravaT14[nT14][11] )
				oModel:LoadValue("MODEL_T14", "T14_DESCRA", aGravaT14[nT14][12]	)
				oModel:LoadValue("MODEL_T14", "T14_QTMRRA", aGravaT14[nT14][13]	)
				oModel:LoadValue("MODEL_T14", "T14_VLRCUS", aGravaT14[nT14][14] )
				oModel:LoadValue("MODEL_T14", "T14_VLRADV", aGravaT14[nT14][15] )

				/*------------------------------------------
				V9L - Identificação dos advogados   
				--------------------------------------------*/
				nV9LAdd := 1

				For nV9L := 1 To Len(aGravaV9L)
					If aGravaV9L[nV9L][1] + aGravaV9L[nV9L][2] + aGravaV9L[nV9L][3] + aGravaV9L[nV9L][4] == aGravaT14[nT14][1] + aGravaT14[nT14][2] + aGravaT14[nT14][3] + aGravaT14[nT14][4]
						oModel:GetModel("MODEL_V9L"):lValid := .T.

						If nV9LAdd > 1
							oModel:GetModel("MODEL_V9L"):AddLine()
						EndIf

						oModel:LoadValue("MODEL_V9L", "V9L_TPINSC", aGravaV9L[nV9L][5])
						oModel:LoadValue("MODEL_V9L", "V9L_NRINSC", aGravaV9L[nV9L][6])
						oModel:LoadValue("MODEL_V9L", "V9L_VLRADV", aGravaV9L[nV9L][7])
					
						nV9LAdd++
					EndIf
				Next
			EndIf
			
			/*------------------------------------------
			T6C - Informações da Remuneração Trab.
			--------------------------------------------*/
			nT6CAdd := 1	
			For nT6C := 1 to Len( aGravaT6C )	

				If aGravaT14[nT14][1]+aGravaT14[nT14][2]+aGravaT14[nT14][3]+aGravaT14[nT14][4] == aGravaT6C[nT6C][1]+aGravaT6C[nT6C][2]+aGravaT6C[nT6C][3]+aGravaT6C[nT6C][4]
					
					oModel:GetModel( 'MODEL_T6C' ):LVALID := .T.
					
					If nT6CAdd > 1
						oModel:GetModel( "MODEL_T6C" ):AddLine()
					EndIf
					
					oModel:LoadValue( "MODEL_T6C", "T6C_ESTABE", aGravaT6C[nT6C][5] )

					/*------------------------------------------
					T6D - Informações da Remuneração Trab.
					--------------------------------------------*/
					nT6DAdd := 1	
					For nT6D := 1 to Len( aGravaT6D )		
						
						If aGravaT6C[nT6C][1]+aGravaT6C[nT6C][2]+aGravaT6C[nT6C][3]+aGravaT6C[nT6C][4]+aGravaT6C[nT6C][5] == aGravaT6D[nT6D][1]+aGravaT6D[nT6D][2]+aGravaT6D[nT6D][3]+aGravaT6D[nT6D][4]+aGravaT6D[nT6D][5]
							
							oModel:GetModel( 'MODEL_T6D' ):LVALID := .T.
							
							If nT6DAdd > 1
								oModel:GetModel( "MODEL_T6D" ):AddLine()
							EndIf
							
							oModel:LoadValue( "MODEL_T6D", "T6D_IDTRAB", aGravaT6D[nT6D][6] )
							oModel:LoadValue( "MODEL_T6D", "T6D_NOMEVE", aGravaT6D[nT6D][8] )
							
							/*------------------------------------------
								T6E - Itens da Remuneração Trab.
							--------------------------------------------*/
							nT6EAdd := 1	
							For nT6E := 1 to Len( aGravaT6E )		
								
								If aGravaT6D[nT6D][1] + aGravaT6D[nT6D][2] + aGravaT6D[nT6D][3] +; 
									aGravaT6D[nT6D][4] + aGravaT6D[nT6D][5] + aGravaT6D[nT6D][6] +; 
									aGravaT6D[nT6D][7] + aGravaT6D[nT6D][9] == aGravaT6E[nT6E][1] +; 
									aGravaT6E[nT6E][2] + aGravaT6E[nT6E][3] + aGravaT6E[nT6E][4] +; 
									aGravaT6E[nT6E][5] + aGravaT6E[nT6E][6] + aGravaT6E[nT6E][7] +; 
									aGravaT6E[nT6E][14]
									
									oModel:GetModel( 'MODEL_T6E' ):LVALID := .T.
									
									If nT6EAdd > 1
										oModel:GetModel( "MODEL_T6E" ):AddLine()
									EndIf
									
									oModel:LoadValue( "MODEL_T6E", "T6E_IDRUBR",	aGravaT6E[nT6E][8] )
									oModel:LoadValue( "MODEL_T6E", "T6E_QTDRUB",	aGravaT6E[nT6E][9] )
									oModel:LoadValue( "MODEL_T6E", "T6E_FATORR",	aGravaT6E[nT6E][10])								
									oModel:LoadValue( "MODEL_T6E", "T6E_VLRRUB",	aGravaT6E[nT6E][12])								
									oModel:LoadValue( "MODEL_T6E", "T6E_APURIR",	aGravaT6E[nT6E][13] )
									
									nT6EAdd++
									
								EndIf			
							Next //nT6E					
														
							nT6DAdd++		
						EndIf			
					Next //nT6D
				
					nT6CAdd++		
				EndIf		
			Next //nT6C
		
		
			/*------------------------------------------
				T61 - Ident Lei  Remun. Per.  Anter.
			--------------------------------------------*/
			For nT61 := 1 to Len( aGravaT61 )
			
				If aGravaT14[nT14][1]+aGravaT14[nT14][2]+aGravaT14[nT14][3]+aGravaT14[nT14][4] == aGravaT61[nT61][1]+aGravaT61[nT61][2]+aGravaT61[nT61][3]+aGravaT61[nT61][4]								
					
					oModel:GetModel( 'MODEL_T61' ):LVALID	:= .T.
					
					If nT61 > 1
						oModel:GetModel( "MODEL_T61" ):AddLine()
					EndIf
					
					oModel:LoadValue( "MODEL_T61", "T61_ORGSUC", aGravaT61[nT61][8] )				

					/*------------------------------------------
					T6H - Informações do Periodo
					--------------------------------------------*/
					nT6HAdd := 1	
					For nT6H := 1 to Len( aGravaT6H )		
						
						If aGravaT61[nT61][1]+aGravaT61[nT61][2]+aGravaT61[nT61][3]+aGravaT61[nT61][4]+DtoC(aGravaT61[nT61][5])+aGravaT61[nT61][6]+aGravaT61[nT61][8] == aGravaT6H[nT6H][1]+aGravaT6H[nT6H][2]+aGravaT6H[nT6H][3]+aGravaT6H[nT6H][4]+DtoC(aGravaT6H[nT6H][5])+aGravaT6H[nT6H][6]+aGravaT61[nT61][8]
							
							oModel:GetModel( 'MODEL_T6H' ):LVALID := .T.
							
							If nT6HAdd > 1
								oModel:GetModel( "MODEL_T6H" ):AddLine()
							EndIf
							
							oModel:LoadValue( "MODEL_T6H", "T6H_PERREF", aGravaT6H[nT6H][7] )
							
							/*------------------------------------------
							T6I - Ident. do Estabelecimento
							--------------------------------------------*/
							nT6IAdd := 1	
							For nT6I := 1 to Len( aGravaT6I )		
								
								If aGravaT6H[nT6H][1]+aGravaT6H[nT6H][2]+aGravaT6H[nT6H][3]+aGravaT6H[nT6H][4]+DtoC(aGravaT6H[nT6H][5])+aGravaT6H[nT6H][6]+aGravaT6H[nT6H][7]+aGravaT61[nT61][8] == aGravaT6I[nT6I][1]+aGravaT6I[nT6I][2]+aGravaT6I[nT6I][3]+aGravaT6I[nT6I][4]+DtoC(aGravaT6I[nT6I][5])+aGravaT6I[nT6I][6]+aGravaT6I[nT6I][7]+aGravaT6I[nT6I][9]
									
									oModel:GetModel( 'MODEL_T6I' ):LVALID := .T.
									
									If nT6IAdd > 1
										oModel:GetModel( "MODEL_T6I" ):AddLine()
									EndIf
									
									oModel:LoadValue( "MODEL_T6I", "T6I_ESTABE", aGravaT6I[nT6I][8] )
					
									/*------------------------------------------
									T6J - Informações da Remuneração Trab.
									--------------------------------------------*/
									nT6JAdd := 1	
									For nT6J := 1 to Len( aGravaT6J )		
										
										If aGravaT6I[nT6I][1]+aGravaT6I[nT6I][2]+aGravaT6I[nT6I][3]+aGravaT6I[nT6I][4]+DtoC(aGravaT6I[nT6I][5])+aGravaT6I[nT6I][6]+aGravaT6I[nT6I][7]+aGravaT6I[nT6I][8]+aGravaT6I[nT6I][9] == aGravaT6J[nT6J][1]+aGravaT6J[nT6J][2]+aGravaT6J[nT6J][3]+aGravaT6J[nT6J][4]+DtoC(aGravaT6J[nT6J][5])+aGravaT6J[nT6J][6]+aGravaT6J[nT6J][7]+aGravaT6J[nT6J][8]+aGravaT6J[nT6J][11]
											
											oModel:GetModel( 'MODEL_T6J' ):LVALID := .T.
											
											If nT6JAdd > 1
												oModel:GetModel( "MODEL_T6J" ):AddLine()
											EndIf
											
											oModel:LoadValue( "MODEL_T6J", "T6J_IDTRAB", aGravaT6J[nT6J][9] )
											oModel:LoadValue( "MODEL_T6J", "T6J_NOMEVE", aGravaT6J[nT6J][12] )
											
											/*------------------------------------------
												T6K - Itens da Remuneração Trab.
											--------------------------------------------*/
											nT6KAdd := 1	
											For nT6K := 1 to Len( aGravaT6K )		
												
												If aGravaT6J[nT6J][1] + aGravaT6J[nT6J][2] + aGravaT6J[nT6J][3] +; 
													aGravaT6J[nT6J][4] + DToC(aGravaT6J[nT6J][5]) + aGravaT6J[nT6J][6] +; 
													aGravaT6J[nT6J][7] + aGravaT6J[nT6J][8] + aGravaT6J[nT6J][9] +; 
													aGravaT6J[nT6J][10] + aGravaT6J[nT6J][13] == aGravaT6K[nT6K][1] +; 
													aGravaT6K[nT6K][2] + aGravaT6K[nT6K][3] + aGravaT6K[nT6K][4] +; 
													DToC(aGravaT6K[nT6K][5]) + aGravaT6K[nT6K][6] + aGravaT6K[nT6K][7] +; 
													aGravaT6K[nT6K][8] + aGravaT6K[nT6K][9] + aGravaT6K[nT6K][10] +;
													aGravaT6K[nT6K][17]
													
													oModel:GetModel( 'MODEL_T6K' ):LVALID := .T.
													
													If nT6KAdd > 1
														oModel:GetModel( "MODEL_T6K" ):AddLine()
													EndIf
													
													oModel:LoadValue( "MODEL_T6K", "T6K_IDRUBR",	aGravaT6K[nT6K][11] )
													oModel:LoadValue( "MODEL_T6K", "T6K_QTDRUB",	aGravaT6K[nT6K][12] )
													oModel:LoadValue( "MODEL_T6K", "T6K_FATORR",	aGravaT6K[nT6K][13] )
													oModel:LoadValue( "MODEL_T6K", "T6K_VLRRUB",	aGravaT6K[nT6K][15] )
													oModel:LoadValue( "MODEL_T6K", "T6K_APURIR",	aGravaT6K[nT6K][16] )
													
													nT6KAdd++
													
												EndIf			
											Next //nT6K
													
											nT6JAdd++		
										EndIf			
									Next //nT6J
									
									nT6IAdd++
								EndIf			
							Next //nT6I
				
							nT6HAdd++
						EndIf			
					Next //nT6H

					nT61Add++
				EndIf					
			Next //nT61
		Next //nT14	
																					
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao que sera gravada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVersao := xFunGetVer()
		
		/*---------------------------------------------------------
		ATENCAO -> A alteracao destes campos deve sempre estar     
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima                        
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_C91", "C91_VERSAO", cVersao )
		oModel:LoadValue( "MODEL_C91", "C91_VERANT", cVerAnt )
		oModel:LoadValue( "MODEL_C91", "C91_PROTPN", cProtocolo )	
		
		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_C91", "C91_EVENTO", "E" )
		oModel:LoadValue( "MODEL_C91", "C91_ATIVO", "1" )
			
		FwFormCommit( oModel )
		TAFAltStat( 'C91',"6" )
		
	End Transaction

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMatric
@description  Retorna a Matrícula do trabalhador conforme Nome do Evento e ID

@param cNomeEve - Nome do Evento
@param cIDFunc - ID do funcionário

@author Melkz Siqueira
@since 23/04/2021
@version 1.0		

@return cRet - Matrícula do trabalhador
/*/
//-------------------------------------------------------------------
Static Function GetMatric(cNomeEve, cIDTrab)

	Local cRet			:= ""

	Default cNomeEve 	:= ""
	Default cIDTrab		:= ""

	Do Case
		Case cNomeEve == "S2300"
			cRet := Posicione("C9V", 2, xFilial("C9V") + cIDTrab + "1", "C9V_MATTSV")

		Case cNomeEve == "S2190"
			cRet := Posicione("T3A", 3, xFilial("C9V") + cIDTrab + "1", "T3A_MATRIC")
			
		OtherWise
			cRet := Posicione("C9V", 2, xFilial("C9V") + cIDTrab + "1", "C9V_MATRIC")
	EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF250View
Monta a View dinâmica
@author  Victor A. Barbosa
@since   30/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Function TAF413View( cAlias, nRecno )

	Local aArea 	as array
	Local oExecView	as object
	Local oNewView	as object
	Local nOpc		as numeric

	aArea 		:= GetArea()
	oExecView	:= Nil
	oNewView	:= ViewDef()
	nOpc		:= 1

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( nOpc )
	oExecView:setTitle( STR0001 )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return nOpc

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF250Inc
Monta a View dinâmica
@author  Victor A. Barbosa
@since   30/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Function TAF413Inc( cAlias, nRecno )


	Local aArea 	as array 
	Local oExecView	as object 
	Local oNewView	as object
	Local nOpc		as numeric

	aArea 		:= GetArea()
	oExecView	:= Nil
	oNewView	:= ViewDef()
	nOpc		:= 3

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( nOpc )
	oExecView:setTitle( STR0001 )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return nOpc
