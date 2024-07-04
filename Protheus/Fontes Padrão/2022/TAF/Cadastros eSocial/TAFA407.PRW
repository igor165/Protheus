#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA407.CH"
#INCLUDE "TOPCONN.CH"


#DEFINE CRLF CHR(13) + CHR(10)

Static __aRubrica   := {}
Static __cPicVlDe 	:= Nil
Static __cPicVlLi   := Nil
Static __cPicQtdR   := Nil
Static __cPicFatR   := Nil
Static __cPicVlUn   := Nil
Static __cPicVlRu   := Nil
Static __cPicVlPe   := Nil
Static __cPicVlRb   := Nil
Static __lRubPad 	:= Nil
Static lLaySimplif	:= TafLayESoc()
Static lSimplBeta   := TafLayESoc("S_01_01_00",, .T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA407
Cadastro MVC de Pagamentos de Rendimentos do Trabalho - S-1210

@author Vitor Siqueira
@since 11/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA407()
	
    Private cEvtPosic 	:= ""
	Private cNomEve		:= "S1210"
	Private oBrw        := FWmBrowse():New()

	DbSelectArea('T3P')

	If TafAtualizado()
		TafNewBrowse( "S-1210", , , , STR0001, , 2, 2 )
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Vitor Siqueira
@since 29/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}
	Local nPosVis := 0

	If FindFunction("FilCpfNome") .And. GetSx3Cache("T3P_CPFV","X3_CONTEXT") == "V" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES");
     .And. !FwIsInCallStack("xNewHisAlt")

		ADD OPTION aRotina TITLE "Visualizar" ACTION "TAF407View('T3P',RECNO())" OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Incluir"    ACTION "TAF407Inc('T3P',RECNO())"  OPERATION 3 ACCESS 0 //'Incluir'
		ADD OPTION aRotina TITLE "Alterar"    ACTION "xTafAlt('T3P', 0 , 0)"     OPERATION 4 ACCESS 0 //'Alterar'
		ADD OPTION aRotina TITLE "Imprimir"	  ACTION "VIEWDEF.TAFA407"			 OPERATION 8 ACCESS 0 //'Imprimir'

	Else

		Aadd( aFuncao, { "" , "TAF407Xml"                       , "1" } )
		Aadd( aFuncao, { "" , "xFunAltRec( 'T3P' )"             , "10"} )
		Aadd( aFuncao, { "" , "xNewHisAlt( 'T3P', 'TAFA407' )"  , "3" } ) //Chamo a Browse do Histórico
		Aadd( aFuncao, { "" , "StaticCall(TAFA407,PreXmlLote)"  , "5" } )

		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If lMenuDif
			ADD OPTION aRotina Title STR0002 Action "VIEWDEF.TAFA407" OPERATION 2 ACCESS 0 //"Visualizar"
            aRotina	:= xMnuExtmp( "TAFA407", "T3P", .F. ) // Menu dos extemporâneos
		Else
			aRotina	:=	xFunMnuTAF( "TAFA407" , , aFuncao)
			nPosVis := aScan( aRotina, { |x| x[4] == 2 })
			aRotina[nPosVis][2] := "Taf407View"
		EndIf

	EndIf

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função que chama a TAFXmlLote e limpa slRubERPPad

@author Marcelo Neumann
@since 01/10/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function PreXmlLote()

	TAFXmlLote('T3P', 'S-1210', 'evtPgtos', 'TAF407Xml')
	slRubERPPad := Nil	//Limpa variável no final do processo em lote

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Vitor Siqueira
@since 29/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local aTrigger  as array
	LocaL nILE3     as numeric
	Local oStruV6M  as object
    Local oStruV9I  as object
    Local oStruV9J  as object
	Local oStruT3P  as object
	Local oStruT3Q  as object
	Local oStruT3R  as object
	Local oStruLE2  as object
	Local oStruLE3  as object
	Local oStruLE4  as object
	Local oStruT5V  as object
	Local oStruT5U  as object
	Local oStruT5Y  as object
	Local oStruT5Z  as object
	Local oStruT5X  as object
	Local oStruT6P  as object
	Local oStruT6Q  as object
	Local oStruT6R  as object
	LocaL oModel    as object

	aTrigger    := TAF407Trigger()
	nILE3       := 0
	oStruV6M    := Nil
    oStruV9I    := Nil
    oStruV9J    := Nil
	oStruT3P    := FWFormStruct(1, "T3P")
	oStruT3Q    := FWFormStruct(1, "T3Q")
	oStruT3R    := FWFormStruct(1, "T3R")
	oStruLE2    := FWFormStruct(1, "LE2")
	oStruLE3    := FWFormStruct(1, "LE3")
	oStruLE4    := FWFormStruct(1, "LE4")
	oStruT5V    := FWFormStruct(1, "T5V")
	oStruT5U    := FWFormStruct(1, "T5U")
	oStruT5Y    := FWFormStruct(1, "T5Y")
	oStruT5Z    := FWFormStruct(1, "T5Z")
	oStruT5X    := FWFormStruct(1, "T5X")
	oStruT6P    := FWFormStruct(1, "T6P")
	oStruT6Q    := FWFormStruct(1, "T6Q")
	oStruT6R    := FWFormStruct(1, "T6R")
	oModel      := MPFormModel():New("TAFA407",,, {|oModel| SaveModel(oModel)})

	oStruT3P:AddTrigger( aTrigger[1],;
		aTrigger[2],;
		aTrigger[3],;
		aTrigger[4] )

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	//*********************************************************
	//Aba - Identificação do beneficiário de pagamento
	//*********************************************************
	oModel:AddFields("MODEL_T3P",/*cOwner*/,oStruT3P)
	oModel:GetModel("MODEL_T3P"):SetPrimaryKey({"T3P_FILIAL","T3P_ID","T3P_VERSAO"})

	If !lLaySimplif // Tratamento Simplificação do e-Social.

		oModel:AddGrid("MODEL_T3Q", "MODEL_T3P", oStruT3Q)
		oModel:GetModel("MODEL_T3Q"):SetOptional( .T. )
		oModel:GetModel("MODEL_T3Q"):SetUniqueLine( { "T3Q_DTPGTO","T3Q_TPPGTO"} )
		oModel:GetModel('MODEL_T3Q'):SetMaxLine(60)

		//*********************************************************
		//Aba - Detalhamento de Eventos 1200, 1202, 2299 e 2399
		//*********************************************************
		oModel:AddGrid( "MODEL_T3R", "MODEL_T3Q", oStruT3R)
		oModel:GetModel("MODEL_T3R"):SetOptional( .T. )
		oModel:GetModel("MODEL_T3R"):SetUniqueLine({ "T3R_PERREF","T3R_IDEDMD", "T3R_INDPGT"  })
		oModel:GetModel('MODEL_T3R'):SetMaxLine(200)

		//*********************************************************
		//Aba - Retenções de Pagamento Total
		//*********************************************************
		oModel:AddGrid( "MODEL_LE2", "MODEL_T3R", oStruLE2)
		oModel:GetModel("MODEL_LE2"):SetOptional( .T. )
		oModel:GetModel("MODEL_LE2"):SetUniqueLine( { "LE2_IDRUBR", "LE2_SEQUEN", "LE2_RUBRIC"} )
		oModel:GetModel('MODEL_LE2'):SetMaxLine(99)

		oModel:AddGrid(	"MODEL_LE3", "MODEL_LE2", oStruLE3)
		oModel:GetModel("MODEL_LE3"):SetOptional( .T. )
		oModel:GetModel("MODEL_LE3"):SetUniqueLine( {"LE3_CPFBEN"} )
		oModel:GetModel('MODEL_LE3'):SetMaxLine(99)

		//*********************************************************
		//Aba - Informação de Pagamento Parcial
		//*********************************************************
		oModel:AddGrid( "MODEL_LE4", "MODEL_T3R", oStruLE4)
		oModel:GetModel("MODEL_LE4"):SetOptional( .T. )
		oModel:GetModel("MODEL_LE4"):SetUniqueLine( { "LE4_IDRUBR","LE4_RUBRIC","LE4_IDTABR"} )
		oModel:GetModel('MODEL_LE4'):SetMaxLine(99)

		//*********************************************************
		//Aba - Benefiários Previdenciários
		//*********************************************************
		oModel:AddGrid( "MODEL_T6P", "MODEL_T3Q", oStruT6P)
		oModel:GetModel("MODEL_T6P"):SetOptional( .T. )
		oModel:GetModel("MODEL_T6P"):SetUniqueLine({ "T6P_PERREF","T6P_IDEDMD","T6P_INDPGT"})
		oModel:GetModel('MODEL_T6P'):SetMaxLine(200)

		//*********************************************************
		//Aba - Retenções de Pagamento Total
		//*********************************************************
		oModel:AddGrid(	"MODEL_T6Q", "MODEL_T6P", oStruT6Q)
		oModel:GetModel("MODEL_T6Q"):SetOptional( .T. )
		oModel:GetModel("MODEL_T6Q"):SetUniqueLine( { "T6Q_IDRUBR","T6Q_RUBRIC","T6Q_IDTABR" } )
		oModel:GetModel('MODEL_T6Q'):SetMaxLine(99)

		//*********************************************************
		//Aba - Informação de Pagamento Parcial
		//*********************************************************
		oModel:AddGrid(	"MODEL_T6R", "MODEL_T6P", oStruT6R)
		oModel:GetModel("MODEL_T6R"):SetOptional( .T. )
		oModel:GetModel("MODEL_T6R"):SetUniqueLine( { "T6R_IDRUBR","T6R_RUBRIC","T6R_IDTABR"} )
		oModel:GetModel('MODEL_T6R'):SetMaxLine(99)

		//*********************************************************
		//Aba - Pagamentos Efetuados Relativos a Férias
		//*********************************************************
		oModel:AddGrid( "MODEL_T5U", "MODEL_T3Q", oStruT5U)
		oModel:GetModel("MODEL_T5U"):SetOptional( .T. )
		oModel:GetModel("MODEL_T5U"):SetUniqueLine({"T5U_IDCATE", "T5U_DTINIG", "T5U_QTDIAS","T5U_MATRIC"})
		oModel:GetModel('MODEL_T5U'):SetMaxLine(5)

		oModel:AddGrid(	"MODEL_T5Y", "MODEL_T5U", oStruT5Y)
		oModel:GetModel("MODEL_T5Y"):SetOptional( .T. )
		oModel:GetModel("MODEL_T5Y"):SetUniqueLine( {"T5Y_IDRUBR","T5Y_RUBRIC"} )
		oModel:GetModel('MODEL_T5Y'):SetMaxLine(99)

		oModel:AddGrid( "MODEL_T5Z", "MODEL_T5Y", oStruT5Z)
		oModel:GetModel("MODEL_T5Z"):SetOptional( .T. )
		oModel:GetModel("MODEL_T5Z"):SetUniqueLine( { "T5Z_CPFBEN"} )
		oModel:GetModel('MODEL_T5Z'):SetMaxLine(99)

		//*********************************************************
		//Aba - Pagamentos Relativos a Competências Anteriores
		//*********************************************************
		oModel:AddGrid(	"MODEL_T5V", "MODEL_T3Q", oStruT5V)
		oModel:GetModel("MODEL_T5V"):SetOptional( .T. )
		oModel:GetModel("MODEL_T5V"):SetUniqueLine({"T5V_IDCATE"})
		oModel:GetModel('MODEL_T5V'):SetMaxLine(99)

		oModel:AddGrid(	"MODEL_T5X", "MODEL_T5V", oStruT5X)
		oModel:GetModel("MODEL_T5X"):SetOptional( .T. )
		oModel:GetModel("MODEL_T5X"):SetUniqueLine( {"T5X_IDTPIR","T5X_VLRBCI"} )
		oModel:GetModel('MODEL_T5X'):SetMaxLine(99)

		oModel:SetRelation("MODEL_T3Q" ,{ {"T3Q_FILIAL","xFilial('T3Q')"}, {"T3Q_ID","T3P_ID"}, {"T3Q_VERSAO","T3P_VERSAO"} },T3Q->(IndexKey(1)) )

		oModel:SetRelation("MODEL_T3R",{ {"T3R_FILIAL","xFilial('T3R')"}, {"T3R_ID","T3P_ID"}, {"T3R_VERSAO","T3P_VERSAO"}, {"T3R_DTPGTO","T3Q_DTPGTO"}, {"T3R_TPPGTO","T3Q_TPPGTO"}},T3R->(IndexKey(1)) )
		oModel:SetRelation("MODEL_LE2",{ {"LE2_FILIAL","xFilial('LE2')"}, {"LE2_ID","T3P_ID"}, {"LE2_VERSAO","T3P_VERSAO"}, {"LE2_DTPGTO","T3Q_DTPGTO"}, {"LE2_TPPGTO","T3Q_TPPGTO"}, {"LE2_PERREF","T3R_PERREF"}, {"LE2_IDEDMD","T3R_IDEDMD"},{"LE2_INDPGT","T3R_INDPGT"}},LE2->(IndexKey(1)) )

		IIF(FWSIXUtil():ExistIndex( "LE3", "LE3I3", .T.), nILE3 := 3, nILE3 := 1)
		oModel:SetRelation("MODEL_LE3",{ {"LE3_FILIAL","xFilial('LE3')"}, {"LE3_ID","T3P_ID"}, {"LE3_VERSAO","T3P_VERSAO"}, {"LE3_DTPGTO","T3Q_DTPGTO"}, {"LE3_TPPGTO","T3Q_TPPGTO"}, {"LE3_PERREF","T3R_PERREF"}, {"LE3_IDEDMD","T3R_IDEDMD"},{"LE3_INDPGT","T3R_INDPGT"}, {"LE3_IDRUBR","LE2_IDRUBR"}, {"LE3_SEQUEN","LE2_SEQUEN"}, {"LE3_RUBRIC","LE2_RUBRIC"}  },LE3->(IndexKey(nILE3)) )
		oModel:SetRelation("MODEL_LE4",{ {"LE4_FILIAL","xFilial('LE4')"}, {"LE4_ID","T3P_ID"}, {"LE4_VERSAO","T3P_VERSAO"}, {"LE4_DTPGTO","T3Q_DTPGTO"}, {"LE4_TPPGTO","T3Q_TPPGTO"}, {"LE4_PERREF","T3R_PERREF"}, {"LE4_IDEDMD","T3R_IDEDMD"},{"LE4_INDPGT","T3R_INDPGT"}},LE4->(IndexKey(1)) )

		oModel:SetRelation("MODEL_T6P",{ {"T6P_FILIAL","xFilial('T6P')"}, {"T6P_ID","T3P_ID"}, {"T6P_VERSAO","T3P_VERSAO"}, {"T6P_DTPGTO","T3Q_DTPGTO"}, {"T6P_TPPGTO","T3Q_TPPGTO"}},T6P->(IndexKey(1)) )
		oModel:SetRelation("MODEL_T6Q",{ {"T6Q_FILIAL","xFilial('T6Q')"}, {"T6Q_ID","T3P_ID"}, {"T6Q_VERSAO","T3P_VERSAO"}, {"T6Q_DTPGTO","T3Q_DTPGTO"}, {"T6Q_TPPGTO","T3Q_TPPGTO"}, {"T6Q_PERREF","T6P_PERREF"}, {"T6Q_IDEDMD","T6P_IDEDMD"},{"T6Q_INDPGT","T6P_INDPGT"}},T6Q->(IndexKey(1)) )
		oModel:SetRelation("MODEL_T6R",{ {"T6R_FILIAL","xFilial('T6R')"}, {"T6R_ID","T3P_ID"}, {"T6R_VERSAO","T3P_VERSAO"}, {"T6R_DTPGTO","T3Q_DTPGTO"}, {"T6R_TPPGTO","T3Q_TPPGTO"}, {"T6R_PERREF","T6P_PERREF"}, {"T6R_IDEDMD","T6P_IDEDMD"},{"T6R_INDPGT","T6P_INDPGT"}},T6R->(IndexKey(1)) )

		oModel:SetRelation("MODEL_T5U", { {"T5U_FILIAL","xFilial('T5U')"}, {"T5U_ID","T3P_ID"}, {"T5U_VERSAO","T3P_VERSAO"}, {"T5U_DTPGTO","T3Q_DTPGTO"}, {"T5U_TPPGTO","T3Q_TPPGTO"}},T5U->(IndexKey(1)) )

		If TAFColumnPos( "T5Y_MATRIC" )
			oModel:SetRelation("MODEL_T5Y", { {"T5Y_FILIAL","xFilial('T5Y')"}, {"T5Y_ID","T3P_ID"}, {"T5Y_VERSAO","T3P_VERSAO"}, {"T5Y_DTPGTO","T3Q_DTPGTO"}, {"T5Y_TPPGTO","T3Q_TPPGTO"}, {"T5Y_IDCATE","T5U_IDCATE"}, {"T5Y_DTINIG","T5U_DTINIG"},{"T5Y_QTDIAS","T5U_QTDIAS"},{"T5Y_MATRIC","T5U_MATRIC"}},T5Y->(IndexKey(2)) )
			oModel:SetRelation("MODEL_T5Z" ,{ {"T5Z_FILIAL","xFilial('T5Z')"}, {"T5Z_ID","T3P_ID"}, {"T5Z_VERSAO","T3P_VERSAO"}, {"T5Z_DTPGTO","T3Q_DTPGTO"}, {"T5Z_TPPGTO","T3Q_TPPGTO"}, {"T5Z_IDCATE","T5U_IDCATE"}, {"T5Z_DTINIG","T5U_DTINIG"},{"T5Z_QTDIAS","T5U_QTDIAS"},{"T5Z_MATRIC","T5U_MATRIC"},{"T5Z_IDRUBR","T5Y_IDRUBR"}, {"T5Z_RUBRIC","T5Y_RUBRIC"} },T5Z->(IndexKey(1)) )
		Else
			oModel:SetRelation("MODEL_T5Y", { {"T5Y_FILIAL","xFilial('T5Y')"}, {"T5Y_ID","T3P_ID"}, {"T5Y_VERSAO","T3P_VERSAO"}, {"T5Y_DTPGTO","T3Q_DTPGTO"}, {"T5Y_TPPGTO","T3Q_TPPGTO"}, {"T5Y_IDCATE","T5U_IDCATE"}, {"T5Y_DTINIG","T5U_DTINIG"},{"T5Y_QTDIAS","T5U_QTDIAS"}},T5Y->(IndexKey(1)) )
			oModel:SetRelation("MODEL_T5Z" ,{ {"T5Z_FILIAL","xFilial('T5Z')"}, {"T5Z_ID","T3P_ID"}, {"T5Z_VERSAO","T3P_VERSAO"}, {"T5Z_DTPGTO","T3Q_DTPGTO"}, {"T5Z_TPPGTO","T3Q_TPPGTO"}, {"T5Z_IDCATE","T5U_IDCATE"}, {"T5Z_DTINIG","T5U_DTINIG"},{"T5Z_IDRUBR","T5Y_IDRUBR"}},T5Z->(IndexKey(1)) )
		EndIf

		oModel:SetRelation("MODEL_T5V", { {"T5V_FILIAL","xFilial('T5V')"}, {"T5V_ID","T3P_ID"}, {"T5V_VERSAO","T3P_VERSAO"}, {"T5V_DTPGTO","T3Q_DTPGTO"}, {"T5V_TPPGTO","T3Q_TPPGTO"}},T5V->(IndexKey(1)) )
		oModel:SetRelation("MODEL_T5X", { {"T5X_FILIAL","xFilial('T5X')"}, {"T5X_ID","T3P_ID"}, {"T5X_VERSAO","T3P_VERSAO"}, {"T5X_DTPGTO","T3Q_DTPGTO"}, {"T5X_TPPGTO","T3Q_TPPGTO"}, {"T5X_IDCATE","T5V_IDCATE"}},T5X->(IndexKey(1)) )

		oStruLE2:SetProperty( '*', MODEL_FIELD_OBRIGAT , .F.  )
		oStruLE4:SetProperty( '*', MODEL_FIELD_OBRIGAT , .F.  )
		oStruT5Y:SetProperty( '*', MODEL_FIELD_OBRIGAT , .F.  )
		oStruT6Q:SetProperty( '*', MODEL_FIELD_OBRIGAT , .F.  )
		oStruT6R:SetProperty( 'T6R_IDRUBR', MODEL_FIELD_OBRIGAT , .F.  )
		oStruT5U:SetProperty( 'T5U_MATRIC', MODEL_FIELD_OBRIGAT , .F.  )

	Else
		oStruT3P:SetProperty("T3P_INDAPU", MODEL_FIELD_OBRIGAT, .F.)
		oStruT3P:SetProperty("T3P_INDAPU", MODEL_FIELD_INIT, {|| ""})

		oStruV6M := FWFormStruct(1, "V6M")

        If !lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")
            oStruV6M:RemoveField("V6M_PAIEXT")
            oStruV6M:RemoveField("V6M_DPAIEX")
        EndIf       

		oModel:AddGrid("MODEL_V6M", "MODEL_T3P", oStruV6M)
		oModel:GetModel("MODEL_V6M"):SetOptional(.F.)
		oModel:GetModel("MODEL_V6M"):SetUniqueLine({"V6M_TPPGTO", "V6M_PERREF", "V6M_INDDEV"})
		oModel:GetModel("MODEL_V6M"):SetMaxLine(999)

        oModel:SetRelation("MODEL_V6M", {{"V6M_FILIAL", "xFilial('V6M')"}, {"V6M_ID", "T3P_ID"}, {"V6M_VERSAO", "T3P_VERSAO"}}, V6M->(IndexKey(1)))

        If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")
            oStruV9I := FWFormStruct(1, "V9I")
            oStruV9J := FWFormStruct(1, "V9J")

            oModel:AddGrid("MODEL_V9I", "MODEL_V6M", oStruV9I)
            oModel:GetModel("MODEL_V9I"):SetOptional(.T.)
            oModel:GetModel("MODEL_V9I"):SetMaxLine(1)     

            oModel:AddGrid("MODEL_V9J", "MODEL_V9I", oStruV9J)
            oModel:GetModel("MODEL_V9J"):SetOptional(.T.)
            oModel:GetModel("MODEL_V9J"):SetMaxLine(1)

            oModel:SetRelation("MODEL_V9I", {{"V9I_FILIAL", "xFilial('V9I')"}, {"V9I_ID", "T3P_ID"}, {"V9I_VERSAO", "T3P_VERSAO"}, {"V9I_TPPGTO", "V6M_TPPGTO"}, {"V9I_PERREF", "V6M_PERREF"}, {"V9I_INDDEV", "V6M_INDDEV"}}, V9I->(IndexKey(1)))
            oModel:SetRelation("MODEL_V9J", {{"V9J_FILIAL", "xFilial('V9J')"}, {"V9J_ID", "T3P_ID"}, {"V9J_VERSAO", "T3P_VERSAO"}, {"V9J_TPPGTO", "V6M_TPPGTO"}, {"V9J_PERREF", "V6M_PERREF"}, {"V9J_INDDEV", "V6M_INDDEV"}}, V9J->(IndexKey(1)))                
        EndIf
	EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Vitor Siqueira
@since 29/12/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local aCmpGrp   as array
	Local cGrpBen1  as character
	Local cGrpBen2	as character
	Local cGrpBen3 	as character
	Local cFldLE2   as character
	Local cFldLE4   as character
	Local cFldT5Y   as character
	Local cFldT6Q   as character
	Local cFldT6R   as character
	Local lIncMV    as logical
	Local lCallInc	as logical
	Local nI        as numeric
	Local oStruT3Pa	as object
	Local oStruT3Pb as object
	Local oStruT3Pc as object
	Local oStruT3Pd as object
	Local oStruT3Pe as object
	Local oStruT3Q 	as object
	Local oStruT3R 	as object
	Local oStruLE2 	as object
	Local oStruLE3 	as object
	Local oStruLE4  as object
	Local oStruT5U 	as object
	Local oStruT5Y 	as object
	Local oStruT5Z 	as object
	Local oStruT5V 	as object
	Local oStruT5X 	as object
	Local oStruT6P 	as object
	Local oStruT6Q 	as object
	Local oStruT6R 	as object
	Local oStruV6M  as object
    Local oStruV9I  as object
    Local oStruV9J  as object
	Local oModel 	as object
	Local oView 	as object

	aCmpGrp     := {}
	cGrpBen1	:= ""
	cGrpBen2	:= ""
	cGrpBen3 	:= ""
	cFldLE2     := ""
	cFldLE4     := ""
	cFldT5Y     := ""
	cFldT6Q     := ""
	cFldT6R     := ""
	lIncMV      := .F.
	lCallInc	:= .T.
	nI          := 0
	oStruT3Pa	:= Nil
	oStruT3Pb   := Nil
	oStruT3Pc   := Nil
	oStruT3Pd   := Nil
	oStruT3Pe   := Nil
	oStruT3Q 	:= Nil
	oStruT3R 	:= Nil
	oStruLE2 	:= Nil
	oStruLE3 	:= Nil
	oStruLE4    := Nil
	oStruT5U 	:= Nil
	oStruT5Y 	:= Nil
	oStruT5Z 	:= Nil
	oStruT5V 	:= Nil
	oStruT5X 	:= Nil
	oStruT6P 	:= Nil
	oStruT6Q 	:= Nil
	oStruT6R 	:= Nil
	oStruV6M    := Nil
    oStruV9I    := Nil
    oStruV9J    := Nil
	oModel 	    := FWLoadModel('TAFA407')
	oView 	    := FWFormView():New()

	oView:SetModel( oModel )
	oView:SetContinuousForm(.T.)

	If !lLaySimplif

		oStruT3Q    := FWFormStruct( 2, 'T3Q' )
		oStruT3R 	:= FWFormStruct( 2, 'T3R' )
		oStruLE3 	:= FWFormStruct( 2, 'LE3' )
		oStruT5U 	:= FWFormStruct( 2, 'T5U' )
		oStruT5Z 	:= FWFormStruct( 2, 'T5Z' )
		oStruT5V 	:= FWFormStruct( 2, 'T5V' )
		oStruT5X 	:= FWFormStruct( 2, 'T5X' )
		oStruT6P    := FWFormStruct( 2, 'T6P' )

        /*-----------------------------------------------------------------------------------
        Estrutura da View de Apuração
        -------------------------------------------------------------------------------------*/
        cGrpBen1 	:= "T3P_ID|T3P_INDAPU|T3P_PERAPU|"
        cCmpFil   	:= cGrpBen1
        oStruT3Pa	:= FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

        /*-----------------------------------------------------------------------------------
        Identificaçao do Beneficiario de Pagamento
        -------------------------------------------------------------------------------------*/
        If FWIsInCallStack( "TAF407Inc" ) .And. !FWIsInCallStack( "TAF407AUTI" )
        
            lCallInc 	:= .F.
            lIncMV 		:= Aviso( "Atenção", "O pagamento de rendimentos do trabalho a ser incluído é de um funcionário com ";
                            + "múltiplos vínculos?", {"Sim", "Não"}, 2 ) == 1

        ElseIf FWIsInCallStack( "TAF407AUTI" )

            lCallInc 	:= .F.

        EndIf

        If ( !lCallInc .And. lIncMV ) .Or. ( lCallInc .And. Empty( T3P->T3P_BENEFI ) )

            cGrpBen2 := "T3P_CPF|T3P_NOMER|"
            cFldLE2 := "LE2_IDRUBR|LE2_DRUBR|"
            cFldLE4 := "LE4_IDRUBR|LE4_DRUBR|LE4_MATRIC"
            cFldT5Y := "T5Y_IDRUBR|T5Y_DRUBR|"
            cFldT6Q := "T6Q_IDRUBR|T6Q_DRUBR|"
            cFldT6R := "T6R_IDRUBR|T6R_DRUBR|"

        Else

            cGrpBen2 := "T3P_BENEFI|T3P_NOME|"
            cFldLE2 := "LE2_RUBRIC|LE2_IDTABR|"
            cFldLE4 := "LE4_RUBRIC|LE4_IDTABR|"
            cFldT5Y := "T5Y_RUBRIC|T5Y_IDTABR|"
            cFldT6Q := "T6Q_RUBRIC|T6Q_IDTABR|"
            cFldT6R := "T6R_RUBRIC|T6R_IDTABR|"

        Endif

        cCmpFil   := cGrpBen2
        oStruT3Pb := FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

        oStruLE2 := FWFormStruct( 2, 'LE2', { |x| !(AllTrim( x ) + "|" $ cFldLE2) }  )
        oStruLE4 := FWFormStruct( 2, 'LE4', { |x| !(AllTrim( x ) + "|" $ cFldLE4) }  )
        oStruT5Y := FWFormStruct( 2, 'T5Y', { |x| !(AllTrim( x ) + "|" $ cFldT5Y) }  )
        oStruT6Q := FWFormStruct( 2, 'T6Q', { |x| !(AllTrim( x ) + "|" $ cFldT6Q) }  )
        oStruT6R := FWFormStruct( 2, 'T6R', { |x| !(AllTrim( x ) + "|" $ cFldT6R) }  )

        If ( !lCallInc .And. lIncMV ) .Or. ( lCallInc .And. Empty( T3P->T3P_BENEFI ) )

            oStruLE2:SetProperty("LE2_RUBRIC", MVC_VIEW_ORDEM, "01")
            oStruLE2:SetProperty("LE2_IDTABR", MVC_VIEW_ORDEM, "02")
            oStruLE4:SetProperty("LE4_RUBRIC", MVC_VIEW_ORDEM, "01")
            oStruLE4:SetProperty("LE4_IDTABR", MVC_VIEW_ORDEM, "02")
            oStruT5Y:SetProperty("T5Y_RUBRIC", MVC_VIEW_ORDEM, "01")
            oStruT5Y:SetProperty("T5Y_IDTABR", MVC_VIEW_ORDEM, "02")
            oStruT6Q:SetProperty("T6Q_RUBRIC", MVC_VIEW_ORDEM, "01")
            oStruT6Q:SetProperty("T6Q_IDTABR", MVC_VIEW_ORDEM, "02")
            oStruT6R:SetProperty("T6R_RUBRIC", MVC_VIEW_ORDEM, "01")
            oStruT6R:SetProperty("T6R_IDTABR", MVC_VIEW_ORDEM, "02")
            oStruLE4:RemoveField("LE4_MATRIC")
            oStruT5U:RemoveField("T5U_MATRIC")

        EndIf

        //-----------------------------------------------------------------------
        // Altera consulta padrão do beneficiário para apenas exibir autonomos
        //-----------------------------------------------------------------------
        If FWIsInCallStack( "TAF407AUTI" )
            oStruT3Pb:SetProperty( "T3P_BENEFI"	, MVC_VIEW_LOOKUP, "C9VAUT" )
        EndIf

        /*-----------------------------------------------------------------------------------
        Informações de dependentes do beneficiário do pagamento
        -------------------------------------------------------------------------------------*/
        cGrpBen4  := "T3P_VLDEDB|"
        cCmpFil   := cGrpBen4
        oStruT3Pd := FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

        /*-----------------------------------------------------------------------------------
        Protocolo de Transmissao
        -------------------------------------------------------------------------------------*/
        cGrpBen3 := "T3P_PROTUL|"   
        cCmpFil   := cGrpBen3
        oStruT3Pc	:= FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

        If TafColumnPos("T3P_DTRANS")
            cCmpFil := "T3P_DINSIS|T3P_DTRANS|T3P_HTRANS|T3P_DTRECP|T3P_HRRECP|"
            oStruT3Pe	:= FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )
        EndIf

        /*-----------------------------------------------------------------------------------
        Grupo de campos do Beneficiário
        -------------------------------------------------------------------------------------*/
        //Informações do Beneficiario
        oStruT3Pa:AddGroup( "GRP_BENEFICARIO_01", STR0003, "", 1 ) //Informações de Apuração
        oStruT3Pb:AddGroup( "GRP_BENEFICARIO_02", STR0011, "", 1 ) //Beneficiário
        oStruT3Pd:AddGroup( "GRP_BENEFICARIO_03", STR0022, "", 1 ) //Dependentes do Beneficiário do Pagamento

        aCmpGrp := StrToKArr(cGrpBen1,"|")
        For nI := 1 to Len(aCmpGrp)
            oStruT3Pa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENEFICARIO_01")
        Next nI

        aCmpGrp := StrToKArr(cGrpBen2,"|")
        For nI := 1 to Len(aCmpGrp)
            oStruT3Pb:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENEFICARIO_02")
        Next nI

        aCmpGrp := StrToKArr(cGrpBen4,"|")
        For nI := 1 to Len(aCmpGrp)
            oStruT3Pd:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENEFICARIO_03")
        Next nI

        oStruLE2:SetProperty("LE2_SEQUEN",MVC_VIEW_CANCHANGE,.F.)

        /*-----------------------------------------------------------------------------------
                                    Esrutura da View
        -------------------------------------------------------------------------------------*/
        oView:AddField( "VIEW_T3Pa", oStruT3Pa, "MODEL_T3P" )
        oView:AddField( "VIEW_T3Pb", oStruT3Pb, "MODEL_T3P" )
        oView:AddField( "VIEW_T3Pd", oStruT3Pd, "MODEL_T3P" )
        oView:AddField( "VIEW_T3Pc", oStruT3Pc, "MODEL_T3P" )

        If TafColumnPos("T3P_PROTUL")
            oView:EnableTitleView('VIEW_T3Pc',TafNmFolder("recibo",1)) // "Recibo da última Transmissão"
        EndIf

        If TafColumnPos("T3P_DTRANS")
            oView:AddField( "VIEW_T3Pe", oStruT3Pe, "MODEL_T3P" )
            oView:EnableTitleView('VIEW_T3Pe',TafNmFolder("recibo",2))
        EndIf

        oView:AddGrid( "VIEW_T3Q", oStruT3Q, "MODEL_T3Q" )
        oView:EnableTitleView("VIEW_T3Q",STR0008) //"Informações dos Pagamentos Efetuados"

        //Detalhamento dos pagamentos efetuados, relativos a folha de pagamento e rescisões contratuais, apurados em S-1200, S-1202, S-2299 e S-2399.
        oView:AddGrid( "VIEW_T3R", oStruT3R, "MODEL_T3R" )
        oView:EnableTitleView("VIEW_T3R",STR0024) //Detalhamento dos Pgtos
        oView:AddGrid( "VIEW_LE2", oStruLE2, "MODEL_LE2" )
        oView:EnableTitleView("VIEW_LE2",STR0026) //"Rubricas de Pgto"
        oView:AddGrid( "VIEW_LE3", oStruLE3, "MODEL_LE3" )
        oView:EnableTitleView("VIEW_LE3",STR0017) //Pensão Alimentícia
        oView:AddGrid( "VIEW_LE4", oStruLE4, "MODEL_LE4" )
        oView:EnableTitleView("VIEW_LE4",STR0026) //"Rubricas de Pgto"

        //Detalhamento de Pagamentos Relativos a Benefícios Previdenciários
        oView:AddGrid( "VIEW_T6P", oStruT6P, "MODEL_T6P" )
        oView:EnableTitleView("VIEW_T6P",STR0024) //"Detalhamento dos Pgtos"
        oView:AddGrid( "VIEW_T6Q", oStruT6Q, "MODEL_T6Q" )
        oView:EnableTitleView("VIEW_T6Q",STR0016) //Rubricas de Pgto
        oView:AddGrid( "VIEW_T6R", oStruT6R, "MODEL_T6R" )
        oView:EnableTitleView("VIEW_T6R",STR0018) //Rubricas de Pgto

        //Detalhamento dos pagamentos efetuados relativos a férias
        oView:AddGrid( "VIEW_T5U", oStruT5U, "MODEL_T5U" )
        oView:EnableTitleView("VIEW_T5U",STR0024) //Detalhamento dos Pgtos
        oView:AddGrid( "VIEW_T5Y", oStruT5Y, "MODEL_T5Y" )
        oView:EnableTitleView("VIEW_T5Y",STR0031) //Rubricas do Recibo Antecipado de Férias
        oView:AddGrid( "VIEW_T5Z", oStruT5Z, "MODEL_T5Z" )
        oView:EnableTitleView("VIEW_T5Z",STR0017) //Pensão Alimentícia

        //Pagamento relativo a competências anteriores
        oView:AddGrid( "VIEW_T5V", oStruT5V, "MODEL_T5V" )
        oView:EnableTitleView("VIEW_T5V",STR0032) //Referências

        oView:AddGrid( "VIEW_T5X", oStruT5X, "MODEL_T5X" )
        oView:AddIncrementField( 'VIEW_T5X', 'T5X_SEQUEN' )
        oView:EnableTitleView("VIEW_T5X",STR0024) //Detalhamento dos Pgtos

        //------------------------------------
        // Ordem dos campos na tela para T5X
        //-----------------------------------
        oStruT5X:SetProperty( "T5X_SEQUEN"	, MVC_VIEW_ORDEM	, "08"	)
        oStruT5X:SetProperty( "T5X_IDTPIR"	, MVC_VIEW_ORDEM	, "09"	)
        oStruT5X:SetProperty( "T5X_DTPIRR"	, MVC_VIEW_ORDEM	, "10"	)
        oStruT5X:SetProperty( "T5X_VLRBCI"	, MVC_VIEW_ORDEM	, "11"	)

        If FindFunction('TafAjustRecibo')
            TafAjustRecibo(oStruT3Pc,"T3P")
        EndIf

        /*-----------------------------------------------------------------------------------
                                    Estrutura do Folder
        -------------------------------------------------------------------------------------*/
        oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )
        oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

        //Abas
        oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0004 )   //"Informações de Beneficiários"

        If FindFunction('TafNmFolder')
            oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', TafNmFolder("recibo") )   //"Numero do Recibo"
        Else
            oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0007 )   //"Protocolo de Transmissão"
        EndIf

        //////////////////////////////////////////////////////////////////////////////////
        oView:CreateHorizontalBox("T3Pa"            , 009,,, "FOLDER_SUPERIOR", "ABA01")
        oView:CreateHorizontalBox("T3Pb"            , 009,,, "FOLDER_SUPERIOR", "ABA01")
        oView:CreateHorizontalBox("T3Pd"            , 009,,, "FOLDER_SUPERIOR", "ABA01")
        oView:CreateHorizontalBox("T3Q"             , 015,,, "FOLDER_SUPERIOR", "ABA01")
        oView:CreateHorizontalBox("PAINEL_INFOPGTO" , 058,,, "FOLDER_SUPERIOR", "ABA01")

        oView:CreateFolder( 'FOLDER_INFOPGTO', 'PAINEL_INFOPGTO' )

        ///////////////////////////////////////////////////////////////////////////////////
        oView:AddSheet( "FOLDER_INFOPGTO", "ABA01", STR0023 ) //Detalhamento dos eventos S-1200, S-1202, S-2299 e S-2399
        oView:CreateHorizontalBox( 'T3R', 025,,, 'FOLDER_INFOPGTO', 'ABA01' )

        oView:CreateHorizontalBox("PAINEL_DETHALFOLHA",075,,,"FOLDER_INFOPGTO","ABA01")
        oView:CreateFolder( 'FOLDER_DETHALFOLHA', 'PAINEL_DETHALFOLHA' )
        oView:AddSheet( "FOLDER_DETHALFOLHA", "ABA01", STR0025 ) //"Retenções do Pgto Total"
        oView:CreateHorizontalBox( 'LE2', 	050,,, 'FOLDER_DETHALFOLHA', 'ABA01' )
        oView:AddIncrementField( 'VIEW_LE2', 'LE2_SEQUEN' ) 
        oView:CreateHorizontalBox( 'LE3', 	050,,, 'FOLDER_DETHALFOLHA', 'ABA01' )
        oView:AddSheet( "FOLDER_DETHALFOLHA", "ABA02", STR0027 ) //Informação de Pgto Parc.
        oView:CreateHorizontalBox( 'LE4', 	100,,, 'FOLDER_DETHALFOLHA', 'ABA02' )

        ///////////////////////////////////////////////////////////////////////////////////
        oView:AddSheet( "FOLDER_INFOPGTO", "ABA02", STR0028 ) //Benefícios Previdenciários
        oView:CreateHorizontalBox( 'T6P', 	050,,, 'FOLDER_INFOPGTO', 'ABA02' )
        oView:CreateHorizontalBox("PAINEL_BENEFICI",050,,,"FOLDER_INFOPGTO","ABA02")
        oView:CreateFolder( 'FOLDER_BENEFICI', 'PAINEL_BENEFICI' )
        oView:AddSheet( "FOLDER_BENEFICI", "ABA01", STR0025 ) //Retenções do Pgto Total
        oView:CreateHorizontalBox( 'T6Q', 	100,,, 'FOLDER_BENEFICI', 'ABA01' )
        oView:AddSheet( "FOLDER_BENEFICI", "ABA02", STR0027 ) //Informação de Pgto Parc.
        oView:CreateHorizontalBox( 'T6R', 	100,,, 'FOLDER_BENEFICI', 'ABA02' )

        ///////////////////////////////////////////////////////////////////////////////////
        oView:AddSheet( "FOLDER_INFOPGTO", "ABA03", STR0029 ) //Pgtos Efetuados Relativos a Férias
        oView:CreateHorizontalBox( 'T5U', 	035,,, 'FOLDER_INFOPGTO', 'ABA03' )
        oView:CreateHorizontalBox( 'T5Y', 	035,,, 'FOLDER_INFOPGTO', 'ABA03' )
        oView:CreateHorizontalBox( 'T5Z', 	030,,, 'FOLDER_INFOPGTO', 'ABA03' )

        ///////////////////////////////////////////////////////////////////////////////////
        oView:AddSheet( "FOLDER_INFOPGTO", "ABA04", STR0030 ) //Pgto Relativo a Competências Anteriores
        oView:CreateHorizontalBox( 'T5V', 	050,,, 'FOLDER_INFOPGTO', 'ABA04' )
        oView:CreateHorizontalBox( 'T5X', 	050,,, 'FOLDER_INFOPGTO', 'ABA04' )

        //////////////////////////////////////////////////////////////////////////////////
        If TafColumnPos("T3P_DTRANS")
            oView:CreateHorizontalBox( 'T3Pc',  20,,,'FOLDER_SUPERIOR', 'ABA02' )
            oView:CreateHorizontalBox( 'T3Pe',  80,,,'FOLDER_SUPERIOR', 'ABA02' )
        Else
            oView:CreateHorizontalBox( 'T3Pc',  100,,,'FOLDER_SUPERIOR', 'ABA02' )
        EndIf

        oStruT3Pa:RemoveField('T3P_ID')
        If TAFColumnPos( "T5Y_QTDIAS" )
            oStruT5Y:RemoveField('T5Y_QTDIAS')
        EndIf

        If TAFColumnPos( "T5Z_QTDIAS" )
            oStruT5Z:RemoveField('T5Z_QTDIAS')
        EndIf

        /*-----------------------------------------------------------------------------------
                                    Amarração para exibição das informações
        -------------------------------------------------------------------------------------*/
        oView:SetOwnerView( "VIEW_T3Pa"  , "T3Pa" )
        oView:SetOwnerView( "VIEW_T3Pb"  , "T3Pb" )
        oView:SetOwnerView( "VIEW_T3Pc"  , "T3Pc" )
        oView:SetOwnerView( "VIEW_T3Pd"  , "T3Pd" )
        If TafColumnPos("T3P_DTRANS")
            oView:SetOwnerView( "VIEW_T3Pe"  , "T3Pe" )
        EndIf
        oView:SetOwnerView( "VIEW_T3Q"   , "T3Q"  )
        oView:SetOwnerView( "VIEW_T3R"   , "T3R"  )
        oView:SetOwnerView( "VIEW_LE2"   , "LE2"  )
        oView:SetOwnerView( "VIEW_LE3"   , "LE3"  )
        oView:SetOwnerView( "VIEW_LE4"   , "LE4"  )

        oView:SetOwnerView( "VIEW_T6P"   , "T6P"  )
        oView:SetOwnerView( "VIEW_T6Q"   , "T6Q"  )
        oView:SetOwnerView( "VIEW_T6R"   , "T6R"  )
        oView:SetOwnerView( "VIEW_T5U"   , "T5U"  )
        oView:SetOwnerView( "VIEW_T5Y"   , "T5Y"  )
        oView:SetOwnerView( "VIEW_T5Z"   , "T5Z"  )
        oView:SetOwnerView( "VIEW_T5V"   , "T5V"  )
        oView:SetOwnerView( "VIEW_T5X"   , "T5X"  )

    Else
        oStruV6M := FWFormStruct(2, "V6M")

        If !lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")       
            oStruV6M:RemoveField("V6M_PAIEXT")
            oStruV6M:RemoveField("V6M_DPAIEX")
        EndIf

        cGrpBen1 	:= "T3P_ID|T3P_PERAPU|T3P_TPGUIA|"
        cCmpFil   	:= cGrpBen1
        oStruT3Pa	:= FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

        If FWIsInCallStack( "TAF407Inc" ) .And. !FWIsInCallStack( "TAF407AUTI" )
            lCallInc 	:= .F.
            lIncMV 		:= Aviso( "Atenção", "O pagamento de rendimentos do trabalho a ser incluído é de um funcionário com ";
                            + "múltiplos vínculos?", {"Sim", "Não"}, 2 ) == 1
        ElseIf FWIsInCallStack( "TAF407AUTI" )
            lCallInc 	:= .F.
        EndIf

        If ( !lCallInc .And. lIncMV ) .Or. ( lCallInc .And. Empty( T3P->T3P_BENEFI ) )
            cGrpBen2 := "T3P_CPF|"
        Else
            cGrpBen2 := "T3P_BENEFI|T3P_NOME|"
        EndIf

        cCmpFil   := cGrpBen2
        oStruT3Pb := FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

        If FWIsInCallStack( "TAF407AUTI" )
            oStruT3Pb:SetProperty( "T3P_BENEFI"	, MVC_VIEW_LOOKUP, "C9VAUT" )
        EndIf

        cGrpBen3 := "T3P_PROTUL|"
        cCmpFil   := cGrpBen3
        oStruT3Pc	:= FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

        If TafColumnPos("T3P_DTRANS")
            cCmpFil := "T3P_DINSIS|T3P_DTRANS|T3P_HTRANS|T3P_DTRECP|T3P_HRRECP|"
            oStruT3Pe	:= FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )
        EndIf

        oStruT3Pa:AddGroup( "GRP_BENEFICARIO_01", STR0003, "", 1 )  //Informações de Apuração
        oStruT3Pb:AddGroup( "GRP_BENEFICARIO_02", STR0011, "", 1 )  //Beneficiário

        aCmpGrp := StrToKArr(cGrpBen1,"|")
        For nI := 1 to Len(aCmpGrp)
            oStruT3Pa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENEFICARIO_01")
        Next nI

        aCmpGrp := StrToKArr(cGrpBen2,"|")
        For nI := 1 to Len(aCmpGrp)
            oStruT3Pb:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENEFICARIO_02")
        Next nI

        oView:AddField( "VIEW_T3Pa", oStruT3Pa, "MODEL_T3P" )
        oView:AddField( "VIEW_T3Pb", oStruT3Pb, "MODEL_T3P" )
        oView:AddField( "VIEW_T3Pc", oStruT3Pc, "MODEL_T3P" )

        If TafColumnPos("T3P_PROTUL")
            oView:EnableTitleView('VIEW_T3Pc',TafNmFolder("recibo",1)) // "Recibo da última Transmissão"
        EndIf

        If TafColumnPos("T3P_DTRANS")
            oView:AddField( "VIEW_T3Pe", oStruT3Pe, "MODEL_T3P" )
            oView:EnableTitleView('VIEW_T3Pe',TafNmFolder("recibo",2))
        EndIf

        oView:AddGrid( "VIEW_V6M", oStruV6M, "MODEL_V6M" )
        oView:EnableTitleView("VIEW_V6M", STR0008)  //"Informações dos Pagamentos Efetuados"

        oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )
        oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

        //Abas
        oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0004 )   //"Informações de Beneficiários"

        If FindFunction('TafNmFolder')
            oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', TafNmFolder("recibo") ) //"Numero do Recibo"
        Else
            oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0007 )   //"Protocolo de Transmissão"
        EndIf

        oView:CreateHorizontalBox( 'T3Pa',  005,,, 'FOLDER_SUPERIOR', 'ABA01' )
        oView:CreateHorizontalBox( 'T3Pb',  005,,, 'FOLDER_SUPERIOR', 'ABA01' )
        oView:CreateHorizontalBox( 'V6M' , 	030,,, 'FOLDER_SUPERIOR', 'ABA01' )

        If TafColumnPos("T3P_DTRANS")
            oView:CreateHorizontalBox( 'T3Pc',  20,,,'FOLDER_SUPERIOR', 'ABA02' )
            oView:CreateHorizontalBox( 'T3Pe',  80,,,'FOLDER_SUPERIOR', 'ABA02' )
        Else
            oView:CreateHorizontalBox( 'T3Pc',  100,,,'FOLDER_SUPERIOR', 'ABA02' )
        EndIf
        
        oStruT3Pa:RemoveField("T3P_VLDEDB") 
        oStruT3Pa:RemoveField("T3P_INDAPU") 

        oView:SetOwnerView( "VIEW_T3Pa"  , "T3Pa" )
        oView:SetOwnerView( "VIEW_T3Pb"  , "T3Pb" )
        oView:SetOwnerView( "VIEW_T3Pc"  , "T3Pc" )
        If TafColumnPos("T3P_DTRANS")
            oView:SetOwnerView( "VIEW_T3Pe"  , "T3Pe" )
        EndIf
        oView:SetOwnerView( "VIEW_V6M"   , "V6M"  )

        If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")
            oStruV9I := FWFormStruct(2, "V9I")
            oStruV9J := FWFormStruct(2, "V9J")

            oView:AddGrid("VIEW_V9I", oStruV9I, "MODEL_V9I")
            oView:AddGrid("VIEW_V9J", oStruV9J, "MODEL_V9J")

            oView:EnableTitleView("VIEW_V9I", STR0039) // "Informações complementares relativas a pagamentos a residente fiscal no exterior"
            oView:EnableTitleView("VIEW_V9J", STR0040) // "Endereço do beneficiário residente ou domiciliado no exterior"

            oView:CreateHorizontalBox("V9I", 030,,, "FOLDER_SUPERIOR", "ABA01")
            oView:CreateHorizontalBox("V9J", 030,,, "FOLDER_SUPERIOR", "ABA01")
            
            oView:SetOwnerView("VIEW_V9I", "V9I")
            oView:SetOwnerView("VIEW_V9J", "V9J")
        EndIf
    EndIf

    oStruT3Pa:RemoveField('T3P_ID')

    //Tratamento para que alguns campos de controle interno não sejam exibidos na tela
    lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

    If !lMenuDif
        xFunRmFStr(@oStruT3Pa,"T3P")
    EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Vitor Siqueira
@since 29/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel as object)

    Local aGrava        as array
    Local aGravaT3Q     as array
    Local aGravaT3R     as array
    Local aGravaLE2     as array
    Local aGravaLE3     as array
    Local aGravaLE4     as array
    Local aGravaT6P     as array
    Local aGravaT6Q     as array
    Local aGravaT6R     as array
    Local aGravaT5U     as array
    Local aGravaT5Y     as array
    Local aGravaT5Z     as array
    Local aGravaT5V     as array
    Local aGravaT5X     as array
    Local aGravaV6M     as array
    Local aGravaV9I     as array
    Local aGravaV9J     as array
    Local cLogOpe       as character
    Local cLogOpeAnt    as character
    Local cVerAnt       as character
    Local cProtocolo    as character
    Local cVersao       as character
    Local cEvento       as character
    Local cChvRegAnt    as character
    Local lRetorno      as logical
    Local nI            as numeric
    Local nT3Q          as numeric
    Local nT3R          as numeric
    Local nLE2          as numeric
    Local nLE3          as numeric
    Local nLE4          as numeric
    Local nT6P          as numeric
    Local nT6Q          as numeric
    Local nT6R          as numeric
    Local nT5U          as numeric
    Local nT5Y          as numeric
    Local nT5Z          as numeric
    Local nT5V          as numeric
    Local nT5X          as numeric
    Local nV6M          as numeric
    Local nV9I          as numeric
    Local nV9J          as numeric
    Local nT3RAdd       as numeric
    Local nLE2Add       as numeric
    Local nLE3Add       as numeric
    Local nLE4Add       as numeric
    Local nT6PAdd       as numeric
    Local nT6QAdd       as numeric
    Local nT6RAdd       as numeric
    Local nT5UAdd       as numeric
    Local nT5XAdd       as numeric
    Local nT5YAdd       as numeric
    Local nT5ZAdd       as numeric
    Local nT5VAdd       as numeric
    Local nV6MAdd       as numeric
    Local nOperation    as numeric
    Local oModelT3P     as object
    Local oModelT3Q     as object
    Local oModelT3R     as object
    Local oModelLE2     as object
    Local oModelLE3     as object
    Local oModelLE4     as object
    Local oModelT6P     as object
    Local oModelT6Q     as object
    Local oModelT5U     as object
    Local oModelT5Y     as object
    Local oModelT5Z     as object
    Local oModelT5V     as object
    Local oModelT5X     as object
    Local oModelV6M     as object
    Local oModelV9I     as object
    Local oModelV9J     as object

    Default oModel      := Nil 

    aGrava      := {}
    aGravaT3Q   := {}
    aGravaT3R   := {}
    aGravaLE2   := {}
    aGravaLE3   := {}
    aGravaLE4   := {}
    aGravaT6P   := {}
    aGravaT6Q   := {}
    aGravaT6R   := {}
    aGravaT5U   := {}
    aGravaT5Y   := {}
    aGravaT5Z   := {}
    aGravaT5V   := {}
    aGravaT5X   := {}
    aGravaV6M   := {}
    aGravaV9I   := {}
    aGravaV9J   := {}
    cLogOpe     := ""
    cLogOpeAnt  := ""
    cVerAnt     := ""
    cProtocolo  := ""
    cVersao     := ""
    cEvento     := ""
    cChvRegAnt  := ""
    lRetorno    := .T.
    nI          := 0
    nT3Q        := 0
    nT3R        := 0
    nLE2        := 0
    nLE3        := 0
    nLE4        := 0
    nT6P        := 0
    nT6Q        := 0
    nT6R        := 0
    nT5U        := 0
    nT5Y        := 0
    nT5Z        := 0
    nT5V        := 0
    nT5X        := 0
    nV6M        := 0
    nV9I        := 0
    nV9J        := 0
    nT3RAdd     := 0
    nLE2Add     := 0
    nLE3Add     := 0
    nLE4Add     := 0
    nT6PAdd     := 0
    nT6QAdd     := 0
    nT6RAdd     := 0
    nT5UAdd     := 0
    nT5XAdd     := 0
    nT5YAdd     := 0
    nT5ZAdd     := 0
    nT5VAdd     := 0
    nV6MAdd     := 0
    nOperation  := 0
    oModelT3P   := Nil
    oModelT3Q   := Nil
    oModelT3R   := Nil
    oModelLE2   := Nil
    oModelLE3   := Nil
    oModelLE4   := Nil
    oModelT6P   := Nil
    oModelT6Q   := Nil
    oModelT5U   := Nil
    oModelT5Y   := Nil
    oModelT5Z   := Nil
    oModelT5V   := Nil
    oModelT5X   := Nil
    oModelV6M   := Nil
    oModelV9I   := Nil
    oModelV9J   := Nil
        
    If oModel != Nil
        nOperation := oModel:GetOperation()
        
        Begin Transaction

            //Inclusao Manual do Evento
            If nOperation == MODEL_OPERATION_INSERT
                TafAjustID( "T3P", oModel)
                oModel:LoadValue( "MODEL_T3P", "T3P_VERSAO", xFunGetVer() )

                If Findfunction("TAFAltMan")
                    TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T3P', 'T3P_LOGOPE' , '2', '' )
                EndIf

                FwFormCommit( oModel )

            //Alteração Manual do Evento
            ElseIf nOperation == MODEL_OPERATION_UPDATE

                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³Seek para posicionar no registro antes de realizar as validacoes,³
                //³visto que quando nao esta pocisionado nao eh possivel analisar   ³
                //³os campos nao usados como _STATUS                                ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                //Posicionando no registro para que nao ocorra erros durante o processo de validação
                T3P->( DbSetOrder( 4 ) ) //T3P_FILIAL+T3P_ID+T3P_ATIVO
                If T3P->( MsSeek( xFilial( 'T3P' ) + T3P->T3P_ID + '1' ) )

                    If T3P->T3P_STATUS $ ( "4" )

                        oModelT3P  := oModel:GetModel( "MODEL_T3P" )
                        oModelV6M  := oModel:GetModel( "MODEL_V6M" )

                        //Guardo as informações do registro corrente para rastro do registro
                        cVerAnt     := oModelT3P:GetValue( "T3P_VERSAO" )
                        cProtocolo 	:= oModelT3P:GetValue( "T3P_PROTUL" )
                        cEvento	 	:= oModelT3P:GetValue( "T3P_EVENTO" )

                        If TafColumnPos( "T3P_LOGOPE" )
                            cLogOpeAnt := oModelT3P:GetValue( "T3P_LOGOPE" )
                        EndIf

                        /*---------------------------------------------
                            T3P - Pgto Rendimentos do Trabalho
                        -----------------------------------------------*/
                        For nI := 1 To Len( oModelT3P:aDataModel[ 1 ] )
                            Aadd( aGrava, { oModelT3P:aDataModel[ 1, nI, 1 ], oModelT3P:aDataModel[ 1, nI, 2 ] } )
                        Next nI

                        If !lLaySimplif
                        
                            DBSelectArea("T3Q")
                            DBSetOrder(1)

                            If T3Q->(MsSeek(xFilial("T3Q")+T3P->(T3P_ID + T3P_VERSAO) ) )

                                oModelT3Q  := oModel:GetModel( "MODEL_T3Q" )
                                oModelT3R  := oModel:GetModel( "MODEL_T3R" )
                                oModelLE2  := oModel:GetModel( "MODEL_LE2" )
                                oModelLE3  := oModel:GetModel( "MODEL_LE3" )
                                oModelLE4  := oModel:GetModel( "MODEL_LE4" )
                                oModelT6P  := oModel:GetModel( "MODEL_T6P" )
                                oModelT6Q  := oModel:GetModel( "MODEL_T6Q" )
                                oModelT6R  := oModel:GetModel( "MODEL_T6R" )
                                oModelT5U  := oModel:GetModel( "MODEL_T5U" )
                                oModelT5Y  := oModel:GetModel( "MODEL_T5Y" )
                                oModelT5Z  := oModel:GetModel( "MODEL_T5Z" )
                                oModelT5V  := oModel:GetModel( "MODEL_T5V" )
                                oModelT5X  := oModel:GetModel( "MODEL_T5X" )
                                
                                /*---------------------------------------------
                                T3Q - Informações dos Pagamentos Efetuados
                                ----------------------------------------------*/
                                For nT3Q := 1 To oModel:GetModel( "MODEL_T3Q" ):Length()

                                    oModel:GetModel( "MODEL_T3Q" ):GoLine(nT3Q)

                                    If !oModel:GetModel( "MODEL_T3Q" ):IsDeleted()

                                        aAdd(aGravaT3Q,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                        oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                        oModelT3Q:GetValue("T3Q_INDRES"),;
                                                        oModelT3Q:GetValue("T3Q_IDPAIS"),;
                                                        oModelT3Q:GetValue("T3Q_INDNIF"),;
                                                        oModelT3Q:GetValue("T3Q_NIFBEN"),;
                                                        oModelT3Q:GetValue("T3Q_DLOUGR"),;
                                                        oModelT3Q:GetValue("T3Q_NUMLOG"),;
                                                        oModelT3Q:GetValue("T3Q_COMPLE"),;
                                                        oModelT3Q:GetValue("T3Q_BAIRRO"),;
                                                        oModelT3Q:GetValue("T3Q_CIDADE"),;
                                                        oModelT3Q:GetValue("T3Q_CEP")})

                                        /*---------------------------------------------
                                            T3R - Detalh. Pgto Folha e Rescisão
                                        ----------------------------------------------*/
                                        For nT3R := 1 to oModel:GetModel( "MODEL_T3R" ):Length()

                                            oModel:GetModel( "MODEL_T3R" ):GoLine(nT3R)

                                            If !oModel:GetModel( "MODEL_T3R" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_T3R" ):IsDeleted()

                                                    aAdd (aGravaT3R ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                    oModelT3R:GetValue('T3R_PERREF'),;
                                                                    oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                    oModelT3R:GetValue('T3R_INDPGT'),;
                                                                    oModelT3R:GetValue('T3R_VLRLIQ')})

                                                    /*------------------------------------------
                                                    LE2 - Retenções Pagamento do Vlr Tot
                                                    --------------------------------------------*/
                                                    For nLE2 := 1 To oModel:GetModel( "MODEL_LE2" ):Length()
                                                        
                                                        oModel:GetModel( "MODEL_LE2" ):GoLine(nLE2)

                                                        If !oModel:GetModel( "MODEL_LE2" ):IsEmpty()

                                                            If !oModel:GetModel( "MODEL_LE2" ):IsDeleted()

                                                                aAdd (aGravaLE2 ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                oModelT3R:GetValue('T3R_PERREF'),;
                                                                                oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                                oModelT3R:GetValue('T3R_INDPGT'),;
                                                                                oModelLE2:GetValue('LE2_IDRUBR'),;
                                                                                oModelLE2:GetValue('LE2_QTDRUB'),;
                                                                                oModelLE2:GetValue('LE2_FATRUB'),;
                                                                                oModelLE2:GetValue('LE2_VLRRUB'),;
                                                                                oModelLE2:GetValue('LE2_VLRUNI'),;
                                                                                oModelLE2:GetValue('LE2_SEQUEN'),;
                                                                                oModelLE2:GetValue('LE2_RUBRIC'),;
                                                                                oModelLE2:GetValue('LE2_IDTABR');
                                                                                })

                                                                /*------------------------------------------
                                                                            LE3 - Pensão Alimentícia
                                                                --------------------------------------------*/
                                                                For nLE3 := 1 to oModel:GetModel( "MODEL_LE3" ):Length()

                                                                oModel:GetModel( "MODEL_LE3" ):GoLine(nLE3)

                                                                    If !oModel:GetModel( "MODEL_LE3" ):IsEmpty()

                                                                        If !oModel:GetModel( "MODEL_LE3" ):IsDeleted()

                                                                            aAdd (aGravaLE3 ,{	oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                                oModelT3R:GetValue('T3R_PERREF'),;
                                                                                                oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                                                oModelT3R:GetValue('T3R_INDPGT'),;
                                                                                                oModelLE2:GetValue('LE2_IDRUBR'),;
                                                                                                oModelLE3:GetValue('LE3_CPFBEN'),;
                                                                                                oModelLE3:GetValue('LE3_DTNSBE'),;
                                                                                                oModelLE3:GetValue('LE3_NMBEN'),;
                                                                                                oModelLE3:GetValue('LE3_VLRPEN'),;
                                                                                                oModelLE2:GetValue('LE2_SEQUEN'),;
                                                                                                oModelLE2:GetValue('LE2_RUBRIC'),;
                                                                                            })
                                                                        EndIF
                                                                    EndIF
                                                                Next//LE3

                                                            EndIf
                                                        EndIF
                                                    Next//LE2

                                                    /*------------------------------------------
                                                        LE4 - Inf Comp Relac ao Pgto Efetuad
                                                    --------------------------------------------*/
                                                    For nLE4 := 1 to oModel:GetModel( "MODEL_LE4" ):Length()

                                                        oModel:GetModel( "MODEL_LE4" ):GoLine(nLE4)

                                                        If !oModel:GetModel( "MODEL_LE4" ):IsEmpty()

                                                            If !oModel:GetModel( "MODEL_LE4" ):IsDeleted()

                                                                aAdd (aGravaLE4 ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                    oModelT3R:GetValue('T3R_PERREF'),;
                                                                                    oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                                    oModelT3R:GetValue('T3R_INDPGT'),;
                                                                                    oModelLE4:GetValue('LE4_IDRUBR'),;
                                                                                    oModelLE4:GetValue('LE4_QTDRUB'),;
                                                                                    oModelLE4:GetValue('LE4_FATRUB'),;
                                                                                    oModelLE4:GetValue('LE4_VLRRUB'),;
                                                                                    oModelLE4:GetValue('LE4_VLRUNI'),;
                                                                                    oModelLE4:GetValue('LE4_MATRIC')})
                                                            EndIf
                                                        EndIF
                                                    Next//LE4

                                                EndIf
                                            EndIF
                                        Next//nT3R

                                        /*------------------------------------------
                                        T6P - Detalh. Pgto Folha e Rescisão
                                        --------------------------------------------*/
                                        For nT6P := 1 to oModel:GetModel( "MODEL_T6P" ):Length()

                                            oModel:GetModel( "MODEL_T6P" ):GoLine(nT6P)

                                            If !oModel:GetModel( "MODEL_T6P" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_T6P" ):IsDeleted()

                                                    aAdd (aGravaT6P ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                    oModelT6P:GetValue('T6P_PERREF'),;
                                                                    oModelT6P:GetValue('T6P_IDEDMD'),;
                                                                    oModelT6P:GetValue('T6P_INDPGT'),;
                                                                    oModelT6P:GetValue('T6P_VLRLIQ')})

                                                    /*------------------------------------------
                                                        T6Q - Retenções Pagamento do Vlr Tot
                                                    --------------------------------------------*/
                                                    For nT6Q := 1 to oModel:GetModel( "MODEL_T6Q" ):Length()

                                                        oModel:GetModel( "MODEL_T6Q" ):GoLine(nT6Q)

                                                        If !oModel:GetModel( "MODEL_T6Q" ):IsEmpty()

                                                            If !oModel:GetModel( "MODEL_T6Q" ):IsDeleted()

                                                                aAdd (aGravaT6Q ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                oModelT6P:GetValue('T6P_PERREF'),;
                                                                                oModelT6P:GetValue('T6P_IDEDMD'),;
                                                                                oModelT6P:GetValue('T6P_INDPGT'),;
                                                                                oModelT6Q:GetValue('T6Q_IDRUBR'),;
                                                                                oModelT6Q:GetValue('T6Q_QTDRUB'),;
                                                                                oModelT6Q:GetValue('T6Q_FATRUB'),;
                                                                                oModelT6Q:GetValue('T6Q_VLRRUB'),;
                                                                                oModelT6Q:GetValue('T6Q_VLRUNI')})

                                                            EndIf
                                                        EndIF
                                                    Next//T6Q

                                                    /*------------------------------------------
                                                        T6R - Inf Comp Relac ao Pgto Efetuad
                                                    --------------------------------------------*/
                                                    For nT6R := 1 To oModel:GetModel( "MODEL_T6R" ):Length()

                                                        oModel:GetModel( "MODEL_T6R" ):GoLine(nT6R)

                                                        If !oModel:GetModel( "MODEL_T6R" ):IsEmpty()
                                                        
                                                            If !oModel:GetModel( "MODEL_T6R" ):IsDeleted()

                                                                aAdd (aGravaT6R ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                oModelT6P:GetValue('T6P_PERREF'),;
                                                                                oModelT6P:GetValue('T6P_IDEDMD'),;
                                                                                oModelT6P:GetValue('T6P_INDPGT'),;
                                                                                oModelT6R:GetValue('T6R_IDRUBR'),;
                                                                                oModelT6R:GetValue('T6R_QTDRUB'),;
                                                                                oModelT6R:GetValue('T6R_FATRUB'),;
                                                                                oModelT6R:GetValue('T6R_VLRRUB'),;
                                                                                oModelT6R:GetValue('T6R_VLRUNI')})
                                                            EndIf
                                                        EndIF
                                                    Next//T6R

                                                EndIf
                                            EndIF
                                        Next//nT6P

                                        /*------------------------------------------
                                        T5U - Detalhamento Rub Recibo Férias
                                        --------------------------------------------*/
                                        For nT5U := 1 to oModel:GetModel( "MODEL_T5U" ):Length()

                                            oModel:GetModel( "MODEL_T5U" ):GoLine(nT5U)

                                            If !oModel:GetModel( "MODEL_T5U" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_T5U" ):IsDeleted()

                                                    aAdd (aGravaT5U ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                    oModelT5U:GetValue('T5U_IDCATE'),;
                                                                    oModelT5U:GetValue('T5U_DTINIG'),;
                                                                    oModelT5U:GetValue('T5U_QTDIAS'),;
                                                                    oModelT5U:GetValue('T5U_VLRLIQ')})

                                                    /*------------------------------------------
                                                        T5Y - Det Rub Rebibo Ant de Ferias
                                                    --------------------------------------------*/
                                                    For nT5Y := 1 to oModel:GetModel( "MODEL_T5Y" ):Length()

                                                        oModel:GetModel( "MODEL_T5Y" ):GoLine(nT5Y)

                                                        If !oModel:GetModel( "MODEL_T5Y" ):IsEmpty()

                                                            If !oModel:GetModel( "MODEL_T5Y" ):IsDeleted()

                                                                If TAFColumnPos( "T5Y_QTDIAS" )

                                                                    aAdd (aGravaT5Y ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                    oModelT5U:GetValue('T5U_IDCATE'),;
                                                                                    oModelT5U:GetValue('T5U_DTINIG'),;
                                                                                    oModelT5Y:GetValue('T5Y_IDRUBR'),;
                                                                                    oModelT5Y:GetValue('T5Y_QTDRUB'),;
                                                                                    oModelT5Y:GetValue('T5Y_FATRUB'),;
                                                                                    oModelT5Y:GetValue('T5Y_VLRRUB'),;
                                                                                    oModelT5Y:GetValue('T5Y_VLRUNI'),;
                                                                                    oModelT5Y:GetValue('T5Y_QTDIAS')})

                                                                Else

                                                                    aAdd (aGravaT5Y ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                    oModelT5U:GetValue('T5U_IDCATE'),;
                                                                                    oModelT5U:GetValue('T5U_DTINIG'),;
                                                                                    oModelT5Y:GetValue('T5Y_IDRUBR'),;
                                                                                    oModelT5Y:GetValue('T5Y_QTDRUB'),;
                                                                                    oModelT5Y:GetValue('T5Y_FATRUB'),;
                                                                                    oModelT5Y:GetValue('T5Y_VLRRUB'),;
                                                                                    oModelT5Y:GetValue('T5Y_VLRUNI')})

                                                                EndIf

                                                                /*------------------------------------------
                                                                            T5Z - Beneficiários de Pensão Alimen
                                                                --------------------------------------------*/
                                                                For nT5Z := 1 to oModel:GetModel( "MODEL_T5Z" ):Length()

                                                                    oModel:GetModel( "MODEL_T5Z" ):GoLine(nT5Z)

                                                                    If !oModel:GetModel( "MODEL_T5Z" ):IsEmpty()

                                                                        If !oModel:GetModel( "MODEL_T5Z" ):IsDeleted()

                                                                            If TAFColumnPos( "T5Z_QTDIAS" )

                                                                                aAdd (aGravaT5Z ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                                    oModelT5U:GetValue('T5U_IDCATE'),;
                                                                                                    oModelT5U:GetValue('T5U_DTINIG'),;
                                                                                                    oModelT5Y:GetValue('T5Y_IDRUBR'),;
                                                                                                    oModelT5Z:GetValue('T5Z_CPFBEN'),;
                                                                                                    oModelT5Z:GetValue('T5Z_DTNSBE'),;
                                                                                                    oModelT5Z:GetValue('T5Z_NMBEN'),;
                                                                                                    oModelT5Z:GetValue('T5Z_VLRPEN'),;
                                                                                                    oModelT5Z:GetValue('T5Z_QTDIAS')})

                                                                            Else

                                                                                aAdd (aGravaT5Z ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                                oModelT5U:GetValue('T5U_IDCATE'),;
                                                                                                oModelT5U:GetValue('T5U_DTINIG'),;
                                                                                                oModelT5Y:GetValue('T5Y_IDRUBR'),;
                                                                                                oModelT5Z:GetValue('T5Z_CPFBEN'),;
                                                                                                oModelT5Z:GetValue('T5Z_DTNSBE'),;
                                                                                                oModelT5Z:GetValue('T5Z_NMBEN'),;
                                                                                                oModelT5Z:GetValue('T5Z_VLRPEN')})

                                                                            EndIf
                                                                        EndIf
                                                                    EndIf
                                                                Next//T5Z

                                                            EndIf
                                                        EndIf
                                                    Next//T5Y

                                                EndIf
                                            EndIF
                                        Next//T5U

                                        /*------------------------------------------
                                        T5V - Pgto Relat Compet Anteriores
                                        --------------------------------------------*/
                                        For nT5V := 1 to oModel:GetModel( "MODEL_T5V" ):Length()

                                            oModel:GetModel( "MODEL_T5V" ):GoLine(nT5V)

                                            If !oModel:GetModel( "MODEL_T5V" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_T5V" ):IsDeleted()

                                                    aAdd (aGravaT5V ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                    oModelT5V:GetValue('T5V_IDCATE')})

                                                    /*------------------------------------------
                                                        T5X - Detalhamento do pagamento
                                                    --------------------------------------------*/
                                                    For nT5X := 1 to oModel:GetModel( "MODEL_T5X" ):Length()

                                                        oModel:GetModel( "MODEL_T5X" ):GoLine(nT5X)

                                                        If !oModel:GetModel( "MODEL_T5X" ):IsEmpty()

                                                            If !oModel:GetModel( "MODEL_T5X" ):IsDeleted()

                                                                aAdd (aGravaT5X ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                oModelT5V:GetValue('T5V_IDCATE'),;
                                                                                oModelT5X:GetValue('T5X_SEQUEN'),;
                                                                                oModelT5X:GetValue('T5X_IDTPIR'),;
                                                                                oModelT5X:GetValue('T5X_VLRBCI')})


                                                            EndIf
                                                        EndIf
                                                    Next//T5X

                                                EndIf
                                            EndIf
                                        Next//nT5V

                                    EndIf
                                Next //nT3Q

                            EndIf

                        Else
                            V6M->(DBSetOrder(1))
                            
                            If V6M->(MsSeek(xFilial("V6M") + T3P->(T3P_ID + T3P_VERSAO)))
                                oModelV6M := oModel:GetModel("MODEL_V6M")
                                oModelV9I := oModel:GetModel("MODEL_V9I")
                                oModelV9J := oModel:GetModel("MODEL_V9J")

                                For nV6M := 1 To oModel:GetModel("MODEL_V6M"):Length()
                                    oModel:GetModel("MODEL_V6M"):GoLine(nV6M)

                                    If !oModel:GetModel("MODEL_V6M"):IsEmpty()
                                        If !oModel:GetModel("MODEL_V6M"):IsDeleted()
                                            AAdd(aGravaV6M, {   oModelV6M:GetValue("V6M_DTPGTO"),;
                                                                oModelV6M:GetValue("V6M_TPPGTO"),;
                                                                oModelV6M:GetValue("V6M_PERREF"),;
                                                                oModelV6M:GetValue("V6M_INDDEV"),;
                                                                oModelV6M:GetValue("V6M_VLRLIQ")    })

                                            If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")
                                                AAdd(aGravaV6M[nV6M], oModelV6M:GetValue("V6M_PAIEXT"))

                                                For nV9I := 1 To oModel:GetModel("MODEL_V9I"):Length()
                                                    oModel:GetModel("MODEL_V9I"):GoLine(nV9I)

                                                    If !oModel:GetModel("MODEL_V9I"):IsEmpty()
                                                        If !oModel:GetModel("MODEL_V9I"):IsDeleted()
                                                            AAdd(aGravaV9I, {   oModelV6M:GetValue("V6M_TPPGTO"),;
                                                                                oModelV6M:GetValue("V6M_PERREF"),;
                                                                                oModelV6M:GetValue("V6M_INDDEV"),;
                                                                                oModelV9I:GetValue("V9I_INDNIF"),;
                                                                                oModelV9I:GetValue("V9I_NIFBEN"),;
                                                                                oModelV9I:GetValue("V9I_FRMTRI")    })
                                                        
                                                            For nV9J := 1 To oModel:GetModel("MODEL_V9J"):Length()
                                                                oModel:GetModel("MODEL_V9J"):GoLine(nV9J)

                                                                If !oModel:GetModel("MODEL_V9J"):IsEmpty()
                                                                    If !oModel:GetModel("MODEL_V9J"):IsDeleted()
                                                                        AAdd(aGravaV9J, {   oModelV6M:GetValue("V6M_TPPGTO"),;
                                                                                            oModelV6M:GetValue("V6M_PERREF"),;
                                                                                            oModelV6M:GetValue("V6M_INDDEV"),;  
                                                                                            oModelV9J:GetValue("V9J_DSCLOG"),;
                                                                                            oModelV9J:GetValue("V9J_NRLOGR"),;
                                                                                            oModelV9J:GetValue("V9J_COMPLE"),;
                                                                                            oModelV9J:GetValue("V9J_BAIRRO"),;
                                                                                            oModelV9J:GetValue("V9J_CIDADE"),;
                                                                                            oModelV9J:GetValue("V9J_ESTADO"),;
                                                                                            oModelV9J:GetValue("V9J_CODPOS"),;
                                                                                            oModelV9J:GetValue("V9J_TELEF" )   })
                                                                    EndIf
                                                                EndIf
                                                            Next
                                                        EndIf
                                                    EndIf
                                                Next
                                            EndIf
                                        EndIf
                                    EndIf
                                Next
                            EndIf
                        EndIf
                        
                        /*----------------------------------------------------------
                        Seto o campo como Inativo e gravo a versao do novo registro
                        no registro anterior

                        ATENCAO -> A alteracao destes campos deve sempre estar
                        abaixo do Loop do For, pois devem substituir as informacoes
                        que foram armazenadas no Loop acima
                        -----------------------------------------------------------*/
                        FAltRegAnt( "T3P", "2" )

                        /*----------------------------------------------------------
                        Apos deixar o registro corrente como inativo eu seto a
                        operação de inclusão para o novo registro
                        -----------------------------------------------------------*/
                        oModel:DeActivate()
                        oModel:SetOperation( 3 )
                        oModel:Activate()

                        /*----------------------------------------------------------
                        Neste momento eu realizo a gravação de um novo registro idêntico
                        ao original, apenas com as alterações nos campos modificados
                        pelo usuário no cadastro
                        -----------------------------------------------------------*/

                        /*------------------------------------------
                            T3P - Pgto Rendimentos do Trabalho
                        --------------------------------------------*/
                        For nI := 1 to Len( aGrava )
                            oModel:LoadValue( "MODEL_T3P", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
                        Next nI

                        //Necessário Abaixo do For Nao Retirar
                        If Findfunction("TAFAltMan")
                            TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T3P', 'T3P_LOGOPE' , '' , cLogOpeAnt )
                        EndIf

                        If !lLaySimplif

                            /*------------------------------------------
                            T3Q - Informações dos Pagamentos Efetuados
                            --------------------------------------------*/
                            For nT3Q := 1 to Len( aGravaT3Q )

                                oModel:GetModel( 'MODEL_T3Q' ):LVALID	:= .T.

                                If nT3Q > 1
                                    oModel:GetModel( "MODEL_T3Q" ):AddLine()
                                EndIf
                                
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_DTPGTO",  aGravaT3Q[nT3Q][1] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_TPPGTO",  aGravaT3Q[nT3Q][2] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_INDRES",  aGravaT3Q[nT3Q][3] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_IDPAIS",  aGravaT3Q[nT3Q][4] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_INDNIF",  aGravaT3Q[nT3Q][5] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_NIFBEN",  aGravaT3Q[nT3Q][6] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_DLOUGR",  aGravaT3Q[nT3Q][7] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_NUMLOG",  aGravaT3Q[nT3Q][8] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_COMPLE",  aGravaT3Q[nT3Q][9] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_BAIRRO",  aGravaT3Q[nT3Q][10] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_CIDADE",  aGravaT3Q[nT3Q][11] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_CEP"   ,  aGravaT3Q[nT3Q][12] )
                            
                                /*------------------------------------------
                                    T3R - Detalh. Pgto Folha e Rescisão
                                --------------------------------------------*/
                                nT3RAdd := 1
                                For nT3R := 1 to Len( aGravaT3R )

                                    If  DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                                        oModel:GetModel( "MODEL_T3R" ):LVALID := .T.

                                        If nT3RAdd > 1
                                            oModel:GetModel( "MODEL_T3R" ):AddLine()
                                        EndIf

                                        oModel:LoadValue( "MODEL_T3R", "T3R_PERREF", aGravaT3R[nT3R][3] )
                                        oModel:LoadValue( "MODEL_T3R", "T3R_IDEDMD", aGravaT3R[nT3R][4] )
                                        oModel:LoadValue( "MODEL_T3R", "T3R_INDPGT", aGravaT3R[nT3R][5] )
                                        oModel:LoadValue( "MODEL_T3R", "T3R_VLRLIQ", aGravaT3R[nT3R][6] )

                                        /*------------------------------------------
                                            LE2 - Retenções Pagamento do Vlr Tot
                                        --------------------------------------------*/
                                        nLE2Add := 1
                                        For nLE2 := 1 to Len( aGravaLE2 )

                                            If  DTOS(aGravaLE2[nLE2][1])+aGravaLE2[nLE2][2]+aGravaLE2[nLE2][3]+aGravaLE2[nLE2][4]+aGravaLE2[nLE2][5] == ;
                                                DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2]+aGravaT3R[nT3R][3]+aGravaT3R[nT3R][4]+aGravaT3R[nT3R][5]

                                                oModel:GetModel( "MODEL_LE2" ):LVALID := .T.

                                                If nLE2Add > 1
                                                    oModel:GetModel( "MODEL_LE2" ):AddLine()
                                                EndIf

                                                oModel:LoadValue( "MODEL_LE2" , "LE2_IDRUBR", aGravaLE2[nLE2][6] )
                                                oModel:LoadValue( "MODEL_LE2" , "LE2_QTDRUB", aGravaLE2[nLE2][7] )
                                                oModel:LoadValue( "MODEL_LE2" , "LE2_FATRUB", aGravaLE2[nLE2][8] )
                                                oModel:LoadValue( "MODEL_LE2" , "LE2_VLRRUB", aGravaLE2[nLE2][9] )
                                                oModel:LoadValue( "MODEL_LE2" , "LE2_VLRUNI", aGravaLE2[nLE2][10] )
                                                oModel:LoadValue( "MODEL_LE2" , "LE2_SEQUEN", aGravaLE2[nLE2][11] )
                                                oModel:LoadValue( "MODEL_LE2" , "LE2_RUBRIC", aGravaLE2[nLE2][12] )
                                                oModel:LoadValue( "MODEL_LE2" , "LE2_IDTABR", aGravaLE2[nLE2][13] )

                                                /*------------------------------------------
                                                    LE3 - Pensão Alimentícia
                                                --------------------------------------------*/
                                                nLE3Add := 1
                                                For nLE3 := 1 to Len( aGravaLE3 )

                                                    If  DTOS(aGravaLE3[nLE3][1])+aGravaLE3[nLE3][2]+aGravaLE3[nLE3][3]+aGravaLE3[nLE3][4]+aGravaLE3[nLE3][5]+aGravaLE3[nLE3][6]+aGravaLE3[nLE3][11]+aGravaLE3[nLE3][12];
                                                    == DTOS(aGravaLE2[nLE2][1])+aGravaLE2[nLE2][2]+aGravaLE2[nLE2][3]+aGravaLE2[nLE2][4]+aGravaLE2[nLE2][5]+aGravaLE2[nLE2][6]+aGravaLE2[nLE2][11]+aGravaLE2[nLE2][12]
                                                        
                                                        oModel:GetModel( "MODEL_LE3" ):LVALID := .T.

                                                        If nLE3Add > 1
                                                            oModel:GetModel( "MODEL_LE3" ):AddLine()
                                                        EndIf

                                                        oModel:LoadValue( "MODEL_LE3" , "LE3_CPFBEN", aGravaLE3[nLE3][7] )
                                                        oModel:LoadValue( "MODEL_LE3" , "LE3_DTNSBE", aGravaLE3[nLE3][8] )
                                                        oModel:LoadValue( "MODEL_LE3" , "LE3_NMBEN",  aGravaLE3[nLE3][9] )
                                                        oModel:LoadValue( "MODEL_LE3" , "LE3_VLRPEN", aGravaLE3[nLE3][10] )
                                                        nLE3Add++

                                                    EndIf
                                                Next//nLE3

                                                nLE2Add++
                                            EndIf
                                        Next//LE2

                                        /*------------------------------------------
                                            LE4 - Inf Comp Relac ao Pgto Efetuad
                                        --------------------------------------------*/
                                        nLE4Add := 1
                                        For nLE4 := 1 to Len( aGravaLE4 )

                                            If  DTOS(aGravaLE4[nLE4][1])+aGravaLE4[nLE4][2]+aGravaLE4[nLE4][3]+aGravaLE4[nLE4][4]+aGravaLE4[nLE4][5] == DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2]+aGravaT3R[nT3R][3]+aGravaT3R[nT3R][4]+aGravaT3R[nT3R][5]

                                                oModel:GetModel( "MODEL_LE4" ):LVALID := .T.

                                                If nLE4Add > 1
                                                    oModel:GetModel( "MODEL_LE4" ):AddLine()
                                                EndIf

                                                oModel:LoadValue( "MODEL_LE4" , "LE4_IDRUBR", aGravaLE4[nLE4][6] )
                                                oModel:LoadValue( "MODEL_LE4" , "LE4_QTDRUB", aGravaLE4[nLE4][7] )
                                                oModel:LoadValue( "MODEL_LE4" , "LE4_FATRUB", aGravaLE4[nLE4][8] )
                                                oModel:LoadValue( "MODEL_LE4" , "LE4_VLRUNI", aGravaLE4[nLE4][9] )
                                                oModel:LoadValue( "MODEL_LE4" , "LE4_VLRRUB", aGravaLE4[nLE4][10] )
                                                oModel:LoadValue( "MODEL_LE4" , "LE4_MATRIC", aGravaLE4[nLE4][11] )

                                                nLE4Add++
                                            EndIf
                                        Next//nLE4

                                        nT3RAdd++
                                    EndIf
                                Next //nT3R

                                /*------------------------------------------
                                    T6P - Detalh. Pgto Folha e Rescisão
                                --------------------------------------------*/
                                nT6PAdd := 1
                                For nT6P := 1 to Len( aGravaT6P )

                                    If  DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                                        oModel:GetModel( "MODEL_T6P" ):LVALID := .T.

                                        If nT6PAdd > 1
                                            oModel:GetModel( "MODEL_T6P" ):AddLine()
                                        EndIf

                                        oModel:LoadValue( "MODEL_T6P", "T6P_PERREF", aGravaT6P[nT6P][3] )
                                        oModel:LoadValue( "MODEL_T6P", "T6P_IDEDMD", aGravaT6P[nT6P][4] )
                                        oModel:LoadValue( "MODEL_T6P", "T6P_INDPGT", aGravaT6P[nT6P][5] )
                                        oModel:LoadValue( "MODEL_T6P", "T6P_VLRLIQ", aGravaT6P[nT6P][6] )

                                        /*------------------------------------------
                                            T6Q - Retenções Pagamento do Vlr Tot
                                        --------------------------------------------*/
                                        nT6QAdd := 1
                                        For nT6Q := 1 to Len( aGravaT6Q )

                                            If  DTOS(aGravaT6Q[nT6Q][1])+aGravaT6Q[nT6Q][2]+aGravaT6Q[nT6Q][3]+aGravaT6Q[nT6Q][4]+aGravaT6Q[nT6Q][5] == DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2]+aGravaT6P[nT6P][3]+aGravaT6P[nT6P][4]+aGravaT6P[nT6P][5]

                                                oModel:GetModel( "MODEL_T6Q" ):LVALID := .T.

                                                If nT6QAdd > 1
                                                    oModel:GetModel( "MODEL_T6Q" ):AddLine()
                                                EndIf

                                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_IDRUBR", aGravaT6Q[nT6Q][6]  )
                                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_QTDRUB", aGravaT6Q[nT6Q][7]  )
                                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_FATRUB", aGravaT6Q[nT6Q][8]  )
                                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_VLRRUB", aGravaT6Q[nT6Q][9]  )
                                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_VLRUNI", aGravaT6Q[nT6Q][10] )

                                                nT6QAdd++
                                            EndIf

                                        Next//T6Q

                                        /*------------------------------------------
                                            T6R - Inf Comp Relac ao Pgto Efetuad
                                        --------------------------------------------*/
                                        nT6RAdd := 1
                                        For nT6R := 1 to Len( aGravaT6R )
                                        
                                            If  DTOS(aGravaT6R[nT6R][1])+aGravaT6R[nT6R][2]+aGravaT6R[nT6R][3]+aGravaT6R[nT6R][4]+aGravaT6R[nT6R][5] == DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2]+aGravaT6P[nT6P][3]+aGravaT6P[nT6P][4]+aGravaT6P[nT6P][5]

                                                oModel:GetModel( "MODEL_T6R" ):LVALID := .T.

                                                If nT6RAdd > 1
                                                    oModel:GetModel( "MODEL_T6R" ):AddLine()
                                                EndIf

                                                oModel:LoadValue( "MODEL_T6R" , "T6R_IDRUBR", aGravaT6R[nT6R][6] )
                                                oModel:LoadValue( "MODEL_T6R" , "T6R_QTDRUB", aGravaT6R[nT6R][7] )
                                                oModel:LoadValue( "MODEL_T6R" , "T6R_FATRUB", aGravaT6R[nT6R][8] )
                                                oModel:LoadValue( "MODEL_T6R" , "T6R_VLRUNI", aGravaT6R[nT6R][9] )
                                                oModel:LoadValue( "MODEL_T6R" , "T6R_VLRRUB", aGravaT6R[nT6R][10] )

                                                nT6RAdd++
                                            EndIf

                                        Next//nT6R

                                        nT6PAdd++
                                    EndIf

                                Next //nT6P

                                /*------------------------------------------
                                    T5U - Detalhamento Rub Recibo Férias
                                --------------------------------------------*/
                                nT5UAdd := 1
                                For nT5U := 1 to Len( aGravaT5U )

                                    If  DTOS(aGravaT5U[nT5U][1])+aGravaT5U[nT5U][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                                        oModel:GetModel( "MODEL_T5U" ):LVALID := .T.

                                        If nT5UAdd > 1
                                            oModel:GetModel( "MODEL_T5U" ):AddLine()
                                        EndIf

                                        oModel:LoadValue( "MODEL_T5U", "T5U_IDCATE", aGravaT5U[nT5U][3] )
                                        oModel:LoadValue( "MODEL_T5U", "T5U_DTINIG", aGravaT5U[nT5U][4] )
                                        oModel:LoadValue( "MODEL_T5U", "T5U_QTDIAS", aGravaT5U[nT5U][5] )
                                        oModel:LoadValue( "MODEL_T5U", "T5U_VLRLIQ", aGravaT5U[nT5U][6] )

                                        /*------------------------------------------
                                            T5Y - Det Rub Rebibo Ant de Ferias
                                        --------------------------------------------*/
                                        nT5YAdd := 1
                                        For nT5Y := 1 to Len( aGravaT5Y )

                                            If  DTOS(aGravaT5Y[nT5Y][1])+aGravaT5Y[nT5Y][2]+aGravaT5Y[nT5Y][3]+DTOS(aGravaT5Y[nT5Y][4])+STR(aGravaT5Y[nT5Y][10])== DTOS(aGravaT5U[nT5U][1])+aGravaT5U[nT5U][2]+aGravaT5U[nT5U][3]+DTOS(aGravaT5U[nT5U][4])+STR(aGravaT5U[nT5U][5])

                                                oModel:GetModel( "MODEL_T5Y" ):LVALID := .T.

                                                If nT5YAdd > 1
                                                    oModel:GetModel( "MODEL_T5Y" ):AddLine()
                                                EndIf

                                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_IDRUBR", aGravaT5Y[nT5Y][5] )
                                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_QTDRUB", aGravaT5Y[nT5Y][6] )
                                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_FATRUB", aGravaT5Y[nT5Y][7] )
                                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_VLRRUB", aGravaT5Y[nT5Y][8] )
                                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_VLRUNI", aGravaT5Y[nT5Y][9] )

                                                /*------------------------------------------
                                                    T5Z - Beneficiários de Pensão Alimen
                                                --------------------------------------------*/
                                                nT5ZAdd := 1
                                                For nT5Z := 1 to Len( aGravaT5Z )

                                                    If  DTOS(aGravaT5Z[nT5Z][1])+aGravaT5Z[nT5Z][2]+aGravaT5Z[nT5Z][3]+DTOS(aGravaT5Z[nT5Z][4])+aGravaT5Z[nT5Z][5]+STR(aGravaT5Z[nT5Z][10]) == DTOS(aGravaT5Y[nT5Y][1])+aGravaT5Y[nT5Y][2]+aGravaT5Y[nT5Y][3]+DTOS(aGravaT5Y[nT5Y][4])+aGravaT5Y[nT5Y][5]+STR(aGravaT5Y[nT5Y][10])

                                                        oModel:GetModel( "MODEL_T5Z" ):LVALID := .T.

                                                        If nT5ZAdd > 1
                                                            oModel:GetModel( "MODEL_T5Z" ):AddLine()
                                                        EndIf

                                                        oModel:LoadValue( "MODEL_T5Z" , "T5Z_CPFBEN", aGravaT5Z[nT5Z][6] )
                                                        oModel:LoadValue( "MODEL_T5Z" , "T5Z_DTNSBE", aGravaT5Z[nT5Z][7] )
                                                        oModel:LoadValue( "MODEL_T5Z" , "T5Z_NMBEN",  aGravaT5Z[nT5Z][8] )
                                                        oModel:LoadValue( "MODEL_T5Z" , "T5Z_VLRPEN", aGravaT5Z[nT5Z][9] )
                                                        nT5ZAdd++
                                                    EndIf

                                                Next//T5Z

                                                nT5YAdd++

                                            EndIf

                                        Next//T5Y

                                        nT5UAdd++

                                    EndIf

                                Next //T5U

                                /*------------------------------------------
                                    T5V - Pgto Relat Compet Anteriores
                                --------------------------------------------*/
                                nT5VAdd := 1
                                For nT5V := 1 to Len( aGravaT5V )

                                    If  DTOS(aGravaT5V[nT5V][1])+aGravaT5V[nT5V][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                                        oModel:GetModel( "MODEL_T5V" ):LVALID := .T.

                                        If nT5VAdd > 1
                                            oModel:GetModel( "MODEL_T5V" ):AddLine()
                                        EndIf

                                        oModel:LoadValue( "MODEL_T5V", "T5V_IDCATE", aGravaT5V[nT5V][3] )

                                        /*------------------------------------------
                                            T5X - Detalhamento do pagamento
                                        --------------------------------------------*/
                                        nT5XAdd := 1
                                        For nT5X := 1 to Len( aGravaT5X )

                                            If  DTOS(aGravaT5X[nT5X][1])+aGravaT5X[nT5X][2]+aGravaT5X[nT5X][3] == DTOS(aGravaT5V[nT5V][1])+aGravaT5V[nT5V][2]+aGravaT5V[nT5V][3]

                                                oModel:GetModel( "MODEL_T5X" ):LVALID := .T.

                                                If nT5XAdd > 1
                                                    oModel:GetModel( "MODEL_T5X" ):AddLine()
                                                EndIf

                                                oModel:LoadValue( "MODEL_T5X" , "T5X_SEQUEN", aGravaT5X[nT5X][4] )
                                                oModel:LoadValue( "MODEL_T5X" , "T5X_IDTPIR", aGravaT5X[nT5X][5] )
                                                oModel:LoadValue( "MODEL_T5X" , "T5X_VLRBCI", aGravaT5X[nT5X][6] )

                                                nT5XAdd++

                                            EndIf

                                        Next//T5X

                                        nT5VAdd++

                                    EndIf

                                Next //nT5V

                            Next //nT3Q

                        Else
                            nV6MAdd := 1

                            For nV6M := 1 To Len(aGravaV6M)
                                oModel:GetModel("MODEL_V6M"):lValid := .T.

                                If nV6MAdd > 1
                                    oModel:GetModel("MODEL_V6M"):AddLine()
                                EndIf

                                oModel:LoadValue("MODEL_V6M", "V6M_DTPGTO", aGravaV6M[nV6M][1])
                                oModel:LoadValue("MODEL_V6M", "V6M_TPPGTO", aGravaV6M[nV6M][2])
                                oModel:LoadValue("MODEL_V6M", "V6M_PERREF", aGravaV6M[nV6M][3])
                                oModel:LoadValue("MODEL_V6M", "V6M_INDDEV", aGravaV6M[nV6M][4])
                                oModel:LoadValue("MODEL_V6M", "V6M_VLRLIQ", aGravaV6M[nV6M][5])

                                If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")
                                    oModel:LoadValue("MODEL_V6M", "V6M_PAIEXT", aGravaV6M[nV6M][6])

                                    For nV9I := 1 To Len(aGravaV9I)
                                        If aGravaV9I[nV9I][1] + aGravaV9I[nV9I][2] + aGravaV9I[nV9I][3] == aGravaV6M[nV6M][2] +;
                                            aGravaV6M[nV6M][3] + aGravaV6M[nV6M][4]
                                            oModel:GetModel("MODEL_V9I"):lValid := .T.

                                            oModel:LoadValue("MODEL_V9I", "V9I_INDNIF", aGravaV9I[nV9I][4])
                                            oModel:LoadValue("MODEL_V9I", "V9I_NIFBEN", aGravaV9I[nV9I][5])
                                            oModel:LoadValue("MODEL_V9I", "V9I_FRMTRI", aGravaV9I[nV9I][6])
                                            
                                            For nV9J := 1 To Len(aGravaV9J)
                                                If aGravaV9J[nV9J][1] + aGravaV9J[nV9J][2] + aGravaV9J[nV9J][3] == aGravaV6M[nV6M][2] +;
                                                    aGravaV6M[nV6M][3] + aGravaV6M[nV6M][4]
                                                    oModel:GetModel("MODEL_V9J"):lValid := .T.
                                                    
                                                    oModel:LoadValue("MODEL_V9J", "V9J_DSCLOG", aGravaV9J[nV9J][4])
                                                    oModel:LoadValue("MODEL_V9J", "V9J_NRLOGR", aGravaV9J[nV9J][5])
                                                    oModel:LoadValue("MODEL_V9J", "V9J_COMPLE", aGravaV9J[nV9J][6])
                                                    oModel:LoadValue("MODEL_V9J", "V9J_BAIRRO", aGravaV9J[nV9J][7])
                                                    oModel:LoadValue("MODEL_V9J", "V9J_CIDADE", aGravaV9J[nV9J][8])
                                                    oModel:LoadValue("MODEL_V9J", "V9J_ESTADO", aGravaV9J[nV9J][9])
                                                    oModel:LoadValue("MODEL_V9J", "V9J_CODPOS", aGravaV9J[nV9J][10])
                                                    oModel:LoadValue("MODEL_V9J", "V9J_TELEF" , aGravaV9J[nV9J][11])
                                                EndIf
                                            Next
                                        EndIf
                                    Next
                                EndIf

                                nV6MAdd++
                            Next
                        EndIf
                        
                        //Busco a nova versao do registro
                        cVersao := xFunGetVer()

                        /*---------------------------------------------------------
                        ATENCAO -> A alteracao destes campos deve sempre estar
                        abaixo do Loop do For, pois devem substituir as informacoes
                        que foram armazenadas no Loop acima
                        -----------------------------------------------------------*/
                        oModel:LoadValue( "MODEL_T3P", "T3P_VERSAO", cVersao    )
                        oModel:LoadValue( "MODEL_T3P", "T3P_VERANT", cVerAnt    )
                        oModel:LoadValue( "MODEL_T3P", "T3P_PROTPN", cProtocolo )
                        oModel:LoadValue( "MODEL_T3P", "T3P_PROTUL", ""         )
                        oModel:LoadValue( "MODEL_T3P", "T3P_EVENTO", "A"        )

                        // Tratamento para limpar o ID unico do xml
                        cAliasPai := "T3P"

                        If TAFColumnPos( cAliasPai+"_XMLID" )
                            oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
                        EndIf

                        FwFormCommit( oModel )
                        TAFAltStat( 'T3P', " " )

                    ElseIf	T3P->T3P_STATUS == "2"

                        TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
                        lRetorno:= .F.

                    ElseIf T3P->T3P_STATUS == "6"

                        TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
                        lRetorno:= .F.

                    ElseIf T3P->T3P_STATUS == "7"

                        TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"
                        lRetorno:= .F.

                    Else

                        //alteração sem transmissão
                        If TafColumnPos( "T3P_LOGOPE" )
                            cLogOpeAnt := T3P->T3P_LOGOPE
                        EndIf

                        If Findfunction("TAFAltMan")
                            TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T3P', 'T3P_LOGOPE' , '' , cLogOpeAnt )
                        EndIf

                        FwFormCommit( oModel )
                        TAFAltStat( 'T3P', " " )

                    EndIf

                EndIf

            //Exclusão Manual do Evento
            ElseIf nOperation == MODEL_OPERATION_DELETE

                cChvRegAnt := T3P->(T3P_ID + T3P_VERANT)

                TAFAltStat( 'T3P', " " )
                FwFormCommit( oModel )

                If T3P->T3P_EVENTO == "A" .Or. T3P->T3P_EVENTO == "E"
                    TAFRastro( 'T3P', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
                EndIf

            EndIf

        End Transaction

        If lRetorno .and. FWIsInCallStack( "TAF407AUTI" )

            //Executa atualização dos registros que são elegí­veis para autônomos do S-1210 
            FwMsgRun(, { || AtuRegT3P() }, "Atualizando Registros S-1210 Autônomos...", "Aguarde") 	//"Atualizando Registros S-1210 Autônomos.."

        EndIf
    EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF407Grv
@type			function
@description	Função de gravação para atender o registro S-1210.
@author			Vitor Siqueira
@since			29/12/2015
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
Function TAF407Grv(cLayout as character, nOpc as numeric, cFilEv as character, oXML as object, cOwner as character,; 
            cFilTran as character, cPredeces as character, nTafRecno as numeric, cComplem as character, cGrpTran as character,;
            cEmpOriGrp as character, cFilOriGrp as character, cXmlID as character, cEvtOri as character, lMigrador as logical,;
            lDepGPE as logical, cKey as character, cMatrC9V as character)

	Local aIncons       as array
	Local aRulesCad     as array
	Local aChave        as array
	Local aChvRetif     as array
	Local cLogOpeAnt    as character
	Local cT3QPath      as character
    Local cV6MPath      as character
    Local cV9IPath      as character
    Local cV9JPath      as character
	Local cT3RPath      as character
	Local cPeriodo      as character
	Local cChave        as character
	Local cInconMsg     as character
    Local cTpGuia       as character
    Local cIndApur      as character
    Local cCPF          as character
    Local cBenef        as character
	LocaL cOwExi        as character
	Local cNewOw        as character
	Local cPerRef       as character
	Local cIndRetif     as character
	Local cChvRetif     as character
	Local cTpPgto       as character
	Local cCabec        as character
	Local cCmpsNoUpd    as character
	Local cCodEvent     as character
	Local lExistTrab    as logical
	Local lRet          as logical
	Local lNovCenar     as logical
	Local nI            as numeric
	Local nJ            as numeric
	Local nSeqErrGrv    as numeric
	Local nT3R          as numeric
	Local nLE2          as numeric
	Local nLE3          as numeric
	Local nLE4          as numeric
	Local nT6P          as numeric
	Local nT6Q          as numeric
	Local nT6R          as numeric
	Local nT5U          as numeric
	Local nT5X          as numeric
	Local nT5Y          as numeric
	Local nT5Z          as numeric
	Local nT5V          as numeric
    Local nV6M          as numeric
    Local nV9I          as numeric
    Local nV9J          as numeric
	Local nIndexKey     as numeric
	Local nIndexKey1    as numeric
	Local oModel        as object
	Local oMdlNvCen     as object
	Local xChkDupl      as variant

	Private lVldModel   as logical
	Private oDados      as object

	Default cComplem    := ""
	Default cGrpTran    := ""
	Default cEmpOriGrp  := ""
	Default cFilOriGrp  := ""
	Default cXmlID      := ""
	Default cKey        := ""
	Default cOwner      := ""
	Default cFilTran    := ""
	Default cPredeces   := ""
    Default cFilEv      := ""
    Default cLayout     := "1210"
	Default nOpc        := 1
	Default nTafRecno   := 0
	Default oXML        := Nil

	aIncons     := {}
	aRulesCad   := {}
	aChave      := {}
	aChvRetif   := {}
	cLogOpeAnt  := ""
	cT3QPath    := ""
    cV6MPath    := ""
    cV9IPath    := ""
    cV9JPath    := ""
	cT3RPath    := ""
	cPeriodo    := ""
	cChave      := ""
	cInconMsg   := ""
    cTpGuia     := ""
    cIndApur    := ""
    cCPF        := ""
    cBenef      := ""
	cOwExi      := ""
	cNewOw      := ""
	cPerRef     := ""
	cIndRetif   := ""
	cChvRetif   := ""
	cTpPgto     := ""
	cCabec      := "/eSocial/evtPgtos/ideBenef"
	cCmpsNoUpd  := "|T3P_FILIAL|T3P_ID|T3P_VERSAO|T3P_VERANT|T3P_PROTUL|T3P_PROTPN|T3P_EVENTO|T3P_STATUS|T3P_ATIVO|"
	cCodEvent   := Posicione("C8E", 2, xFilial("C8E") + "S-" + cLayout, "C8E->C8E_ID")
	lExistTrab  := .F.
	lRet        := .F.
	lNovCenar   := .F.
	nI          := 0
	nJ          := 0
	nSeqErrGrv  := 0
	nT3R        := 0
	nLE2        := 0
	nLE3        := 0
	nLE4        := 0
	nT6P        := 0
	nT6Q        := 0
	nT6R        := 0
	nT5U        := 0
	nT5X        := 0
	nT5Y        := 0
	nT5Z        := 0
	nT5V        := 0
    nV6M        := 0
    nV9I        := 0
    nV9J        := 0
	nIndexKey   := 0
	nIndexKey1  := 0
	oModel      := Nil
	oMdlNvCen   := Nil
	xChkDupl    := Nil

	lVldModel   := .T.
	oDados      := oXML

    //Chave do Registro
    cIndRetif	:= FTafGetVal("/eSocial/evtPgtos/ideEvento/indRetif"        , "C", .F., @aIncons, .F.)
    cPeriodo	:= FTafGetVal("/eSocial/evtPgtos/ideEvento/perApur"         , "C", .F., @aIncons, .F.)
    cTpPgto     := FTafGetVal("/eSocial/evtPgtos/ideBenef/infoPgto/tpPgto"  , "C", .F., @aIncons, .F.)
    
    If !lLaySimplif

        cIndApur := FTafGetVal("/eSocial/evtPgtos/ideEvento/indApuracao", "C", .F., @aIncons, .F.) 
        cChave   += Padr(cIndApur, GetSx3Cache('T3P_INDAPU', 'X3_TAMANHO'))

        Aadd(aChave, {"C", "T3P_INDAPU", cIndApur, .T.})       
        Aadd(aChvRetif, {"C", "T3P_INDAPU", cIndApur, .T.})

    EndIf

    cChave += Padr(StrTran(cPeriodo, "-", "" ), GetSx3Cache('T3P_PERAPU', 'X3_TAMANHO'))

    Aadd(aChave, {"C", "T3P_PERAPU", StrTran(cPeriodo, "-", ""), .T.})
    Aadd(aChvRetif, {"C", "T3P_PERAPU", StrTran(cPeriodo, "-", ""), .T.})

    If lLaySimplif

        cTpGuia := FTafGetVal("/eSocial/evtPgtos/ideEvento/indGuia", "C", .F., @aIncons, .F.)    
        cChave  += Padr(cTpGuia, GetSx3Cache('T3P_TPGUIA', 'X3_TAMANHO'))

        Aadd(aChave, {"C", "T3P_TPGUIA", cTpGuia, .T.})
        Aadd(aChvRetif, {"C", "T3P_TPGUIA", cTpGuia, .T.})

    EndIf
    
    cChvRetif   := cChave
    cCPF        := FTafGetVal( "/eSocial/evtPgtos/ideBenef/cpfBenef", "C", .F., @aIncons, .F. )
        
    If lLaySimplif .And. cTpPgto $ "5"

        cBenef := FGetIdInt( "cpfBenef", "","/eSocial/evtPgtos/ideBenef/cpfBenef",,,,@cInconMsg, @nSeqErrGrv,,,,,,,,,"S-1210")
        cEvtNew   := "S2400"

    Else

        // Usa o ID do funcionário quando não for Múltiplos Vínculos
        If !AllTrim( Upper( cComplem ) ) == "MV"
            cBenef := TAFGetIdFunc( cCPF, cPeriodo,,,,, cMatrC9V,,,,,,,,,@cInconMsg )
            cEvtNew   := "S2200
        EndIf

    EndIf
    
    If Empty( cBenef )

        aAdd( aChave, {"C", "T3P_CPF", cCPF, .T. } )
        aAdd( aChvRetif, {"C", "T3P_BENEFI", TAFGetIdFunc( cCPF, cPeriodo,,,,, cMatrC9V ), .T. } )  
        cEvtNew   := "S2200

    Else

        aAdd( aChave, {"C", "T3P_BENEFI", cBenef, .T. } )
        aAdd( aChvRetif, {"C", "T3P_CPF", cCPF, .T. } )  

    EndIf

    If !lLaySimplif

        If Empty( cBenef )
            nIndexKey1 	:= 2
            nIndexKey 	:= 6
        Else
            nIndexKey 	:= 2
            nIndexKey1 	:= 6
            lExistTrab 	:= .T.
        EndIf

    Else

        If Empty( cBenef )
            nIndexKey1 	:= 7
            nIndexKey 	:= 8
        Else
            nIndexKey 	:= 7
            nIndexKey1 	:= 8
            lExistTrab 	:= .T.
        EndIf

    EndIf

    cChave    += Padr( aChave[ 3, 3 ], Tamsx3(aChave[ 3, 2 ])[1])
    cChvRetif += Padr( aChvRetif[ 3, 3 ], Tamsx3(aChvRetif[ 3, 2 ])[1])

    //Verifica se o evento ja existe na base
    If cIndRetif == '1'

        ("T3P")->( DbSetOrder( nIndexKey ) )
        If ("T3P")->( MsSeek( xFilial("T3P") + cChave + '1' ) )

            If !T3P->T3P_STATUS $ ( "2|6|4" )
                nOpc := 4
            ElseIf T3P->T3P_STATUS == "4" .AND. !Empty(T3P->T3P_PROTUL)
                nOpc := 4
                lNovCenar := .T.
                oMdlNvCen := FWLoadModel( 'TAFA407' )
                oMdlNvCen:Activate()
            EndIf

        EndIf

    ElseIf cIndRetif == '2'

        ("T3P")->( DbSetOrder( nIndexKey ) )
        If ("T3P")->( MsSeek( xFilial("T3P") + cChave + '1' ) )

            If !T3P->T3P_STATUS $ ( "2|6" )
                nOpc := 4
            EndIf

        Else

            ("T3P")->( DbSetOrder( nIndexKey1 ) )
            If ("T3P")->( MsSeek( xFilial("T3P") + cChvRetif + '1' ) )

                If !T3P->T3P_STATUS $ ( "2|6" )
                    nOpc 		:= 4
                    nIndexKey 	:= nIndexKey1
                    aChave		:= aChvRetif
                EndIf

            EndIf

        EndIf
    EndIf

    Begin Transaction

        //Funcao para validar se a operacao desejada pode ser realizada
        If FTafVldOpe( "T3P", nIndexKey, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA407", cCmpsNoUpd , , , ,  )

            If TafColumnPos( "T3P_LOGOPE" )
                cLogOpeAnt := T3P->T3P_LOGOPE
            EndIf

            //Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
            aRulesCad := TAF407Rul( cCabec, cInconMsg, nSeqErrGrv, cCodEvent, cOwner, lExistTrab, cMatrC9V, cBenef )

            //Quando se tratar de uma Exclusao direta apenas preciso realizar
            //o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
            If nOpc <> 5

                oModel:LoadValue( "MODEL_T3P", "T3P_FILIAL", T3P->T3P_FILIAL )
                
                If TafColumnPos("T3P_ORIEVE")
                    oModel:LoadValue( "MODEL_T3P", "T3P_ORIEVE", cEvtNew )
                EndIf

                //tratamento para os campos tafckey e owner
                If TafColumnPos("T3P_TAFKEY") .AND.TafColumnPos("T3P_OWNER")
                    
                    //Pegar valor do owner
                    cOwExi := T3P->T3P_OWNER
        
                    oModel:LoadValue( "MODEL_T3P", "T3P_TAFKEY ", cKey  )

                    If Empty(cOwExi) .AND. !Empty(cOwner)

                        oModel:LoadValue( "MODEL_T3P", "T3P_OWNER ", cOwner  )

                    Else

                        If !cOwner $(cOwExi) .AND.!Empty(cOwner)
                            cNewOw := Alltrim(cOwExi) + " | " + cOwner
                            oModel:LoadValue( "MODEL_T3P", "T3P_OWNER ", cNewOw )
                        EndIf

                    EndIf

                EndIf

                If TAFColumnPos( "T3P_XMLID" )
                    oModel:LoadValue( "MODEL_T3P", "T3P_XMLID", cXmlID )
                EndIf

                //Rodo o aRulesCad para gravar as informacoes
                For nI := 1 to Len( aRulesCad )
                    oModel:LoadValue( "MODEL_T3P", aRulesCad[ nI, 01 ], FTafGetVal( aRulesCad[ nI, 02 ], aRulesCad[nI, 03], aRulesCad[nI, 04], @aIncons, .F. ) )
                Next nI

                If Findfunction("TAFAltMan")
                    If nOpc == 3
                        TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T3P', 'T3P_LOGOPE' , '1', '' )
                    ElseIf nOpc == 4
                        TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T3P', 'T3P_LOGOPE' , '', cLogOpeAnt )
                    EndIf
                EndIf

                If lNovCenar 
                    TafCrrMdl(oMdlNvCen, @oModel, T3P->T3P_ID, T3P->T3P_VERSAO )
                EndIf

                If !lLaySimplif
                
                    nT3Q := 1
                    cT3QPath := cCabec + "/infoPgto[" + CVALTOCHAR(nT3Q) + "]"

                    //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                    //Correção efetuada de modo que, o cliente possa escolher se realiza a limpeza da grid ou não.
                    T93->(DbSetOrder(1)) //T93_FILIAL + T93_EVENTO + T93_ATIVO + T93_PADRAO

                    If T93->( MsSeek( xFilial("T93") + cCodEvent + "1" + "1" ) )

                        T94->(DbSetOrder(1))
                        If T94->(MsSeek( xFilial("T94") + cCodEvent + Upper( cCabec + "/infoPgto") ) )

                            If T94->T94_EXCLUI == "1"

                                If nOpc == 4

                                    For nJ := 1 To oModel:GetModel( 'MODEL_T3Q' ):Length()
                                        oModel:GetModel( 'MODEL_T3Q' ):GoLine(nJ)
                                        oModel:GetModel( 'MODEL_T3Q' ):DeleteLine()
                                    Next nJ

                                EndIf

                            EndIf

                        EndIf
                        
                    EndIf

                    //Rodo o XML parseado para gravar as novas informacoes no GRID
                    nT3Q := 1
                    While oDados:XPathHasNode(cT3QPath)

                        oModel:GetModel( 'MODEL_T3Q'):lValid:= .T.

                        If Empty(FTafGetVal( cT3QPath + "/tpPgto","C", .F., @aIncons, .F. ))
                            aAdd( aIncons, "Tag TpPgto Obrigatória.")
                        EndIf

                        If !oModel:GetModel( 'MODEL_T3Q' ):SeekLine( { 	{ "T3Q_DTPGTO", FTafGetVal( cT3QPath + "/dtPgto","D", .F., @aIncons, .F. ) },;
                                                                        { "T3Q_TPPGTO", FTafGetVal( cT3QPath + "/tpPgto","C", .F., @aIncons, .F. ) } } )

                            If !oModel:GetModel( 'MODEL_T3Q' ):IsEmpty()
                                oModel:GetModel( 'MODEL_T3Q' ):AddLine()
                            EndIf

                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/dtPgto"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_DTPGTO", FTafGetVal( cT3QPath + "/dtPgto","D", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/tpPgto"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_TPPGTO", FTafGetVal( cT3QPath + "/tpPgto","C", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/indResBr"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_INDRES", xFunTrcSN(FTafGetVal( cT3QPath + "/indResBr","C", .F., @aIncons, .F. ), 2) )
                        EndIf
                        
                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/idePais/codPais"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_IDPAIS", FGetIdInt( "codPais", "", cT3QPath + "/idePgtoExt/idePais/codPais",,,,@cInconMsg, @nSeqErrGrv ))
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/idePais/indNIF"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_INDNIF", FTafGetVal( cT3QPath + "/idePgtoExt/idePais/indNIF","C", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/idePais/nifBenef"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_NIFBEN", FTafGetVal( cT3QPath + "/idePgtoExt/idePais/nifBenef","C", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/endExt/dscLograd"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_DLOUGR", FTafGetVal( cT3QPath + "/idePgtoExt/endExt/dscLograd", "C", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/endExt/nrLograd"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_NUMLOG", FTafGetVal( cT3QPath + "/idePgtoExt/endExt/nrLograd","C", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/endExt/complem"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_COMPLE", FTafGetVal( cT3QPath + "/idePgtoExt/endExt/complem","C", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/endExt/bairro"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_BAIRRO", FTafGetVal( cT3QPath + "/idePgtoExt/endExt/bairro","C", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/endExt/nmCid"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_CIDADE", FTafGetVal( cT3QPath + "/idePgtoExt/endExt/nmCid", "C", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/endExt/codPostal"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_CEP"   , FTafGetVal( cT3QPath + "/idePgtoExt/endExt/codPostal", "C", .F., @aIncons, .F. ) )
                        EndIf

                        nT3R := 1
                        If oDados:XPathHasNode( cT3QPath +"/detPgtoFl[" + cValToChar(nT3R) + "]" )

                            cT3RPath := cT3QPath + "/detPgtoFl[" + cValToChar(nT3R) + "]"

                            //Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Dependentes )
                            nT3R := 1
                            While oDados:XPathHasNode(cT3RPath )

                                oModel:GetModel( "MODEL_T3R" ):lValid:= .T.

                                cPerRef := StrTran(FwCutOff( FTafGetVal(cT3RPath + "/perRef","C",.F.,@aIncons,.F.) ), "-", "")

                                If Empty(cPerRef)
                                    cPerRef := " "
                                EndIf

                                If !oModel:GetModel( 'MODEL_T3R' ):SeekLine( { 	{ "T3R_PERREF", cPerRef },;
                                                                                                    { "T3R_IDEDMD", PadR(FTafGetVal( cT3RPath + "/ideDmDev","C", .F., @aIncons, .F. ), TamSX3("T3R_IDEDMD")[1]) },;
                                                                                                    { "T3R_INDPGT", FTafGetVal( cT3RPath + "/indPgtoTt","C", .F., @aIncons, .F. ) } } )

                                    If !oModel:GetModel( 'MODEL_T3R' ):IsEmpty()
                                        oModel:GetModel( 'MODEL_T3R' ):AddLine()
                                    EndIf

                                EndIf

                                If oDados:XPathHasNode( cT3RPath + "/perRef"  )
                                    oModel:LoadValue( "MODEL_T3R" ,"T3R_PERREF", cPerRef)
                                EndIf

                                If oDados:XPathHasNode( cT3RPath + "/ideDmDev"  )
                                    oModel:LoadValue( "MODEL_T3R" , "T3R_IDEDMD", FTafGetVal( cT3RPath + "/ideDmDev",    "C", .F., @aIncons, .F. ) )
                                EndIf

                                If oDados:XPathHasNode( cT3RPath + "/indPgtoTt"  )
                                    oModel:LoadValue( "MODEL_T3R" , "T3R_INDPGT", FTafGetVal( cT3RPath + "/indPgtoTt",    "C", .F., @aIncons, .F. ) )
                                EndIf

                                If oDados:XPathHasNode( cT3RPath + "/vrLiq"  )
                                    oModel:LoadValue( "MODEL_T3R", "T3R_VLRLIQ", FTafGetVal( cT3RPath + "/vrLiq"   ,    "N", .F., @aIncons, .F. ) )
                                EndIf
                                
                                If oDados:XPathHasNode( cT3RPath + "/nrRecArq" )
                                    If X3Usado("T3R_NRARQ") 
                                        oModel:LoadValue( "MODEL_T3R", "T3R_NRARQ", FTafGetVal( cT3RPath + "/nrRecArq"   ,   "C", .F., @aIncons, .F. ) )
                                    EndIf
                                EndIf

                                nLE2 := 1
                                cLE2Path := cT3RPath + "/retPgtoTot[" + cValToChar(nLE2) + "]"

                                //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                                If nOpc == 4

                                    For nJ := 1 to oModel:GetModel( "MODEL_LE2"  ):Length()
                                        oModel:GetModel( "MODEL_LE2"  ):GoLine(nJ)
                                        oModel:GetModel( "MODEL_LE2"  ):DeleteLine()
                                    Next nJ

                                EndIf

                                nLE2 := 1
                                While oDados:XPathHasNode(cLE2Path)

                                    oModel:GetModel( "MODEL_LE2" ):lValid:= .T.
                                    If nOpc == 4 .Or. nLE2 > 1
                                        oModel:GetModel( "MODEL_LE2" ):AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_LE2", "LE2_SEQUEN", StrZero( nLE2, TamSX3( "LE2_SEQUEN" )[1] ) )

                                    If oDados:XPathHasNode(	cLE2Path + "/ideTabRubr")

                                        cIdTabR := TAFIdTabRub( FTafGetVal( cLE2Path + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cLE2Path + "/codRubr", "C", .F., @aIncons, .F. ), cLE2Path, @cInconMsg, @nSeqErrGrv, @aIncons  )

                                    Else
                                        cIdTabR := ""

                                        //Gera mensagem de erro
                                        TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', cIdTabR, '', , '', '' )
                                    EndIf
                                    
                                    If oDados:XPathHasNode( cLE2Path + "/codRubr"  )

                                        If lExistTrab
                                            oModel:LoadValue( "MODEL_LE2", "LE2_IDRUBR", FGetIdInt( "codRubr", "ideTabRubr", FTafGetVal( cLE2Path + "/codRubr",   "C", .F., @aIncons, .F. ),cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,StrTran(cPeriodo,"-","")))
                                        Else
                                            oModel:LoadValue( "MODEL_LE2", "LE2_RUBRIC", FTafGetVal( cLE2Path + "/codRubr",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                    EndIf

                                    If !lExistTrab
                                        oModel:LoadValue( "MODEL_LE2", "LE2_IDTABR", cIdTabR )
                                    EndIf

                                    If oDados:XPathHasNode( cLE2Path + "/qtdRubr"  )
                                        oModel:LoadValue( "MODEL_LE2", "LE2_QTDRUB", FTafGetVal( cLE2Path + "/qtdRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cLE2Path + "/fatorRubr"  )
                                        oModel:LoadValue( "MODEL_LE2", "LE2_FATRUB", FTafGetVal( cLE2Path + "/fatorRubr",   "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cLE2Path + "/vrUnit"  )
                                        oModel:LoadValue( "MODEL_LE2", "LE2_VLRUNI", FTafGetVal( cLE2Path + "/vrUnit",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cLE2Path + "/vrRubr"  )
                                        oModel:LoadValue( "MODEL_LE2", "LE2_VLRRUB", FTafGetVal( cLE2Path + "/vrRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    nLE3 := 1
                                    cLE3Path := cLE2Path + "/penAlim[" + cValToChar(nLE3) + "]"

                                    //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                                    If nOpc == 4

                                        For nJ := 1 to oModel:GetModel( "MODEL_LE3" ):Length()
                                            oModel:GetModel( "MODEL_LE3" ):GoLine(nJ)
                                            oModel:GetModel( "MODEL_LE3" ):DeleteLine()
                                        Next nJ

                                    EndIf

                                    nLE3 := 1
                                    While oDados:XPathHasNode(cLE3Path)

                                        oModel:GetModel( "MODEL_LE3" ):lValid:= .T.
                                        If nOpc == 4 .or. nLE3 > 1
                                            oModel:GetModel( "MODEL_LE3" ):AddLine()
                                        EndIf

                                        If oDados:XPathHasNode( cLE3Path + "/cpfBenef"  )
                                            oModel:LoadValue( "MODEL_LE3", "LE3_CPFBEN", FTafGetVal( cLE3Path + "/cpfBenef",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                        If oDados:XPathHasNode( cLE3Path + "/dtNasctoBenef"  )
                                            oModel:LoadValue( "MODEL_LE3", "LE3_DTNSBE", FTafGetVal( cLE3Path + "/dtNasctoBenef",   "D", .F., @aIncons, .F. ) )
                                        EndIf

                                        If oDados:XPathHasNode( cLE3Path + "/nmBenefic"  )
                                            oModel:LoadValue( "MODEL_LE3", "LE3_NMBEN", FTafGetVal( cLE3Path + "/nmBenefic",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                        If oDados:XPathHasNode( cLE3Path + "/vlrPensao"  )
                                            oModel:LoadValue( "MODEL_LE3", "LE3_VLRPEN", FTafGetVal( cLE3Path + "/vlrPensao",   "N", .F., @aIncons, .F. ) )
                                        EndIf

                                        nLE3++
                                        cLE3Path := cLE2Path + "/penAlim[" + cValToChar(nLE3) + "]"

                                    EndDo

                                    nLE2++
                                    cLE2Path := cT3RPath + "/retPgtoTot[" + cValToChar(nLE2) + "]"

                                EndDo

                                nLE4 := 1
                                cLE4Path := cT3RPath + "/infoPgtoParc[" + cValToChar(nLE4) + "]"

                                //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                                If nOpc == 4

                                    For nJ := 1 to oModel:GetModel( "MODEL_LE4" ):Length()
                                        oModel:GetModel( "MODEL_LE4" ):GoLine(nJ)
                                        oModel:GetModel( "MODEL_LE4" ):DeleteLine()
                                    Next nJ

                                EndIf

                                nLE4 := 1
                                While oDados:XPathHasNode(cLE4Path)

                                    oModel:GetModel( "MODEL_LE4" ):lValid:= .T.
                                    If nOpc == 4 .Or. nLE4 > 1
                                        oModel:GetModel( "MODEL_LE4" ):AddLine()
                                    EndIf

                                    If oDados:XPathHasNode(	cLE4Path + "/ideTabRubr")

                                        cIdTabR := TAFIdTabRub( FTafGetVal( cLE4Path + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cLE4Path + "/codRubr", "C", .F., @aIncons, .F. ), cLE4Path, @cInconMsg, @nSeqErrGrv, @aIncons  )

                                    Else

                                        cIdTabR := ""

                                        //Gera mensagem de erro
                                        TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', cIdTabR, '', , '', '' )

                                    EndIf

                                    If oDados:XPathHasNode( cLE4Path + "/codRubr"  )

                                        If lExistTrab
                                            oModel:LoadValue( "MODEL_LE4", "LE4_IDRUBR", FGetIdInt( "codRubr", "ideTabRubr",  FTafGetVal( cLE4Path + "/codRubr",   "C", .F., @aIncons, .F. ),cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,StrTran(cPeriodo,"-","")))
                                        Else
                                            oModel:LoadValue( "MODEL_LE4", "LE4_RUBRIC", FTafGetVal( cLE4Path + "/codRubr",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                    EndIf

                                    If !lExistTrab
                                        oModel:LoadValue( "MODEL_LE4", "LE4_IDTABR", cIdTabR )
                                    EndIf

                                    If oDados:XPathHasNode( cLE4Path + "/qtdRubr"  )
                                        oModel:LoadValue( "MODEL_LE4", "LE4_QTDRUB", FTafGetVal( cLE4Path + "/qtdRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cLE4Path + "/fatorRubr"  )
                                        oModel:LoadValue( "MODEL_LE4", "LE4_FATRUB", FTafGetVal( cLE4Path + "/fatorRubr",   "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cLE4Path + "/vrUnit"  )
                                        oModel:LoadValue( "MODEL_LE4", "LE4_VLRUNI", FTafGetVal( cLE4Path + "/vrUnit",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cLE4Path + "/vrRubr"  )
                                        oModel:LoadValue( "MODEL_LE4", "LE4_VLRRUB", FTafGetVal( cLE4Path + "/vrRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cLE4Path + "/matricula"  )
                                        oModel:LoadValue( "MODEL_LE4", "LE4_MATRIC", FTafGetVal( cLE4Path + "/matricula", "C", .F., @aIncons, .F. ) )
                                    EndIf

                                    nLE4++
                                    cLE4Path := cT3RPath + "/infoPgtoParc[" + cValToChar(nLE4) + "]"

                                EndDo

                                nT3R++
                                cT3RPath := cT3QPath + "/detPgtoFl[" + cValToChar(nT3R) + "]"

                            EndDo

                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/detPgtoBenPr[1]"  )

                            nT6P := 1
                            cT6PPath := cT3QPath + "/detPgtoBenPr[" + cValToChar(nT6P) + "]"

                            //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                            If nOpc == 4

                                For nJ := 1 to oModel:GetModel( "MODEL_T6P"  ):Length()
                                    oModel:GetModel( "MODEL_T6P"  ):GoLine(nJ)
                                    oModel:GetModel( "MODEL_T6P"  ):DeleteLine()
                                Next nJ

                            EndIf

                            //Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Dependentes )
                            nT6P := 1
                            While oDados:XPathHasNode(cT6PPath )

                                If nOpc == 4 .Or. nT6P > 1
                                    oModel:GetModel( "MODEL_T6P" ):lValid:= .T.
                                    oModel:GetModel( "MODEL_T6P" ):AddLine()
                                EndIf

                                If oDados:XPathHasNode( cT6PPath + "/perRef"  )
                                    oModel:LoadValue( "MODEL_T6P" ,"T6P_PERREF", StrTran(FTafGetVal( cT6PPath + "/perRef","C",.F.,@aIncons,.F. ),"-",""))
                                EndIf

                                If oDados:XPathHasNode( cT6PPath + "/ideDmDev"  )
                                    oModel:LoadValue( "MODEL_T6P" , "T6P_IDEDMD", FTafGetVal( cT6PPath + "/ideDmDev",    "C", .F., @aIncons, .F. ) )
                                EndIf

                                If oDados:XPathHasNode( cT6PPath + "/indPgtoTt"  )
                                    oModel:LoadValue( "MODEL_T6P" , "T6P_INDPGT", FTafGetVal( cT6PPath + "/indPgtoTt",    "C", .F., @aIncons, .F. ) )
                                EndIf

                                If oDados:XPathHasNode( cT6PPath + "/vrLiq"  )
                                    oModel:LoadValue( "MODEL_T6P", "T6P_VLRLIQ", FTafGetVal( cT6PPath + "/vrLiq"   ,    "N", .F., @aIncons, .F. ) )
                                EndIf

                                nT6Q := 1
                                cT6QPath := cT6PPath + "/retPgtoTot[" + cValToChar(nT6Q) + "]"

                                //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                                If nOpc == 4 .and. oDados:XPathHasNode( cT6PPath )

                                    For nJ := 1 to oModel:GetModel( "MODEL_T6Q" ):Length()
                                        oModel:GetModel( "MODEL_T6Q" ):GoLine(nJ)
                                        oModel:GetModel( "MODEL_T6Q" ):DeleteLine()
                                    Next nJ

                                EndIf

                                nT6Q := 1
                                While oDados:XPathHasNode(cT6QPath)

                                    If nOpc == 4 .Or. nT6Q > 1
                                        oModel:GetModel( "MODEL_T6Q" ):lValid:= .T.
                                        oModel:GetModel( "MODEL_T6Q" ):AddLine()
                                    EndIf

                                    If oDados:XPathHasNode(	cT6QPath + "/ideTabRubr")
                                    
                                        cIdTabR := TAFIdTabRub( FTafGetVal( cT6QPath + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cT6QPath + "/codRubr", "C", .F., @aIncons, .F. ), cT6QPath, @cInconMsg, @nSeqErrGrv, @aIncons  )

                                    Else

                                        cIdTabR := ""

                                        //Gera mensagem de erro
                                        TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', cIdTabR, '', , '', '' )

                                    EndIf

                                    If oDados:XPathHasNode( cT6QPath + "/codRubr"  )

                                        If lExistTrab
                                            oModel:LoadValue( "MODEL_T6Q", "T6Q_IDRUBR", FGetIdInt( "codRubr", "ideTabRubr", FTafGetVal( cT6QPath + "/codRubr",   "C", .F., @aIncons, .F. ),cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,StrTran(cPeriodo,"-","")))
                                        Else
                                            oModel:LoadValue( "MODEL_T6Q", "T6Q_RUBRIC", FTafGetVal( cT6QPath + "/codRubr",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                    EndIf

                                    If !lExistTrab
                                        oModel:LoadValue( "MODEL_T6Q", "T6Q_IDTABR", cIdTabR )
                                    EndIf

                                    If oDados:XPathHasNode( cT6QPath + "/qtdRubr"  )
                                        oModel:LoadValue( "MODEL_T6Q", "T6Q_QTDRUB", FTafGetVal( cT6QPath + "/qtdRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT6QPath + "/fatorRubr"  )
                                        oModel:LoadValue( "MODEL_T6Q", "T6Q_FATRUB", FTafGetVal( cT6QPath + "/fatorRubr",   "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT6QPath + "/vrUnit"  )
                                        oModel:LoadValue( "MODEL_T6Q", "T6Q_VLRUNI", FTafGetVal( cT6QPath + "/vrUnit",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT6QPath + "/vrRubr"  )
                                        oModel:LoadValue( "MODEL_T6Q", "T6Q_VLRRUB", FTafGetVal( cT6QPath + "/vrRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    nT6Q++
                                    cT6QPath := cT6PPath + "/retPgtoTot[" + cValToChar(nT6Q) + "]"

                                EndDo

                                nT6R := 1
                                cT6RPath := cT6PPath + "/infoPgtoParc[" + cValToChar(nT6R) + "]"

                                //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                                If nOpc == 4 .and. oDados:XPathHasNode( cT6RPath )
                                
                                    For nJ := 1 to oModel:GetModel( "MODEL_T6R" ):Length()
                                        oModel:GetModel( "MODEL_T6R" ):GoLine(nJ)
                                        oModel:GetModel( "MODEL_T6R" ):DeleteLine()
                                    Next nJ

                                EndIf

                                nT6R := 1
                                While oDados:XPathHasNode(cT6RPath)

                                    oModel:GetModel( "MODEL_T6R" ):lValid:= .T.

                                    If nOpc == 4 .Or. nT6R > 1
                                        oModel:GetModel( "MODEL_T6R" ):AddLine()
                                    EndIf

                                    If oDados:XPathHasNode(	cT6RPath + "/ideTabRubr")

                                        cIdTabR := TAFIdTabRub( FTafGetVal( cT6RPath + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cT6RPath + "/codRubr", "C", .F., @aIncons, .F. ), cT6RPath, @cInconMsg, @nSeqErrGrv, @aIncons  )

                                    Else

                                        cIdTabR := ""

                                        //Gera mensagem de erro
                                        TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', cIdTabR, '', , '', '' )

                                    EndIf

                                    If oDados:XPathHasNode( cT6RPath + "/codRubr"  )

                                        If lExistTrab
                                            oModel:LoadValue( "MODEL_T6R", "T6R_IDRUBR", FGetIdInt( "codRubr", "ideTabRubr",  FTafGetVal( cT6RPath + "/codRubr",   "C", .F., @aIncons, .F. ),cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,StrTran(cPeriodo,"-","")))
                                        Else
                                            oModel:LoadValue( "MODEL_T6R", "T6R_RUBRIC", FTafGetVal( cT6RPath + "/codRubr",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                    EndIf

                                    If !lExistTrab
                                        oModel:LoadValue( "MODEL_T6R", "T6R_IDTABR", cIdTabR )
                                    EndIf

                                    If oDados:XPathHasNode( cT6RPath + "/qtdRubr"  )
                                        oModel:LoadValue( "MODEL_T6R", "T6R_QTDRUB", FTafGetVal( cT6RPath + "/qtdRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT6RPath + "/fatorRubr"  )
                                        oModel:LoadValue( "MODEL_T6R", "T6R_FATRUB", FTafGetVal( cT6RPath + "/fatorRubr",   "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT6RPath + "/vrUnit"  )
                                        oModel:LoadValue( "MODEL_T6R", "T6R_VLRUNI", FTafGetVal( cT6RPath + "/vrUnit",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT6RPath + "/vrRubr"  )
                                        oModel:LoadValue( "MODEL_T6R", "T6R_VLRRUB", FTafGetVal( cT6RPath + "/vrRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    nT6R++
                                    cT6RPath := cT6PPath + "/infoPgtoParc[" + cValToChar(nT6R) + "]"

                                EndDo

                                nT6P++
                                cT6PPath := cT6PPath + "/detPgtoFl[" + cValToChar(nT6P) + "]"

                            EndDo

                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/detPgtoFer[1]"  )

                            nT5U := 1
                            cT5UPath := cT3QPath + "/detPgtoFer[" + cValToChar(nT5U) + "]"

                            //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                            If nOpc == 4

                                For nJ := 1 to oModel:GetModel( "MODEL_T5U" ):Length()
                                    oModel:GetModel( "MODEL_T5U" ):GoLine(nJ)
                                    oModel:GetModel( "MODEL_T5U" ):DeleteLine()
                                Next nJ

                            EndIf

                            //Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Dependentes )
                            nT5U := 1
                            While oDados:XPathHasNode(cT5UPath )

                                oModel:GetModel( "MODEL_T5U"  ):lValid:= .T.

                                If nOpc == 4 .or. nT5U > 1
                                    oModel:GetModel( "MODEL_T5U"  ):AddLine()
                                EndIf

                                If oDados:XPathHasNode( cT5UPath + "/codCateg" )
                                    oModel:LoadValue( "MODEL_T5U", "T5U_IDCATE", FGetIdInt( "codCateg", "", cT5UPath + "/codCateg",,,,@cInconMsg, @nSeqErrGrv))
                                EndIf

                                If oDados:XPathHasNode( cT5UPath + "/dtIniGoz" )
                                    oModel:LoadValue( "MODEL_T5U" , "T5U_DTINIG", FTafGetVal( cT5UPath + "/dtIniGoz",    "D", .F., @aIncons, .F. ) )
                                EndIf

                                If oDados:XPathHasNode( cT5UPath + "/qtDias" )
                                    oModel:LoadValue( "MODEL_T5U" , "T5U_QTDIAS", FTafGetVal( cT5UPath + "/qtDias",    "N", .F., @aIncons, .F. ) )
                                EndIf

                                If oDados:XPathHasNode( cT5UPath + "/vrLiq" )
                                    oModel:LoadValue( "MODEL_T5U", "T5U_VLRLIQ", FTafGetVal( cT5UPath + "/vrLiq"   ,    "N", .F., @aIncons, .F. ) )
                                EndIf

                                If oDados:XPathHasNode( cT5UPath + "/matricula" )
                                    oModel:LoadValue( "MODEL_T5U", "T5U_MATRIC", FTafGetVal( cT5UPath + "/matricula",    "C", .F., @aIncons, .F. ) )
                                EndIf

                                nT5Y := 1
                                cT5YPath := cT5UPath + "/detRubrFer[" + cValToChar(nT5Y) + "]"

                                //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                                If nOpc == 4

                                    For nJ := 1 to oModel:GetModel( "MODEL_T5Y" ):Length()
                                        oModel:GetModel( "MODEL_T5Y" ):GoLine(nJ)
                                        oModel:GetModel( "MODEL_T5Y" ):DeleteLine()
                                    Next nJ

                                EndIf

                                nT5Y := 1
                                While oDados:XPathHasNode(cT5YPath)

                                    oModel:GetModel( "MODEL_T5Y" ):lValid:= .T.
                                    If nOpc == 4 .or. nT5Y > 1
                                        oModel:GetModel( "MODEL_T5Y" ):AddLine()
                                    EndIf

                                    If oDados:XPathHasNode(	cT5YPath + "/ideTabRubr")

                                        cIdTabR := TAFIdTabRub( FTafGetVal( cT5YPath + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cT5YPath + "/codRubr", "C", .F., @aIncons, .F. ), cT5YPath, @cInconMsg, @nSeqErrGrv, @aIncons  )

                                    Else

                                        cIdTabR := ""

                                        //Gera mensagem de erro
                                        TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', cIdTabR, '', , '', '' )

                                    EndIf

                                    If oDados:XPathHasNode( cT5YPath + "/codRubr" )

                                        If lExistTrab
                                            oModel:LoadValue( "MODEL_T5Y", "T5Y_IDRUBR", FGetIdInt( "codRubr", "ideTabRubr", FTafGetVal( cT5YPath + "/codRubr",   "C", .F., @aIncons, .F. ),cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,StrTran(cPeriodo,"-","")))
                                        Else
                                            oModel:LoadValue( "MODEL_T5Y", "T5Y_RUBRIC", FTafGetVal( cT5YPath + "/codRubr",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                    EndIf

                                    If !lExistTrab
                                        oModel:LoadValue( "MODEL_T5Y", "T5Y_IDTABR", cIdTabR )
                                    EndIf

                                    If oDados:XPathHasNode( cT5YPath + "/qtdRubr" )
                                        oModel:LoadValue( "MODEL_T5Y", "T5Y_QTDRUB", FTafGetVal( cT5YPath + "/qtdRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT5YPath + "/fatorRubr" )
                                        oModel:LoadValue( "MODEL_T5Y", "T5Y_FATRUB", FTafGetVal( cT5YPath + "/fatorRubr",   "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT5YPath + "/vrUnit" )
                                        oModel:LoadValue( "MODEL_T5Y", "T5Y_VLRUNI", FTafGetVal( cT5YPath + "/vrUnit",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT5YPath + "/vrRubr" )
                                        oModel:LoadValue( "MODEL_T5Y", "T5Y_VLRRUB", FTafGetVal( cT5YPath + "/vrRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    nT5Z := 1
                                    cT5ZPath := cT5YPath + "/penAlim[" + cValToChar(nT5Z) + "]"

                                    //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                                    If nOpc == 4

                                        For nJ := 1 to oModel:GetModel( "MODEL_T5Z" ):Length()
                                            oModel:GetModel( "MODEL_T5Z" ):GoLine(nT5Z)
                                            oModel:GetModel( "MODEL_T5Z" ):DeleteLine()
                                        Next nJ

                                    EndIf

                                    nT5Z := 1
                                    While oDados:XPathHasNode(cT5ZPath)

                                        oModel:GetModel( "MODEL_T5Z" ):lValid:= .T.
                                        If nOpc == 4 .or. nT5Z > 1
                                            oModel:GetModel( "MODEL_T5Z" ):AddLine()
                                        EndIf

                                        If oDados:XPathHasNode( cT5ZPath + "/cpfBenef" )
                                            oModel:LoadValue( "MODEL_T5Z", "T5Z_CPFBEN", FTafGetVal( cT5ZPath + "/cpfBenef",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                        If oDados:XPathHasNode( cT5ZPath + "/dtNasctoBenef" )
                                            oModel:LoadValue( "MODEL_T5Z", "T5Z_DTNSBE", FTafGetVal( cT5ZPath + "/dtNasctoBenef",   "D", .F., @aIncons, .F. ) )
                                        EndIf

                                        If oDados:XPathHasNode( cT5ZPath + "/nmBenefic" )
                                            oModel:LoadValue( "MODEL_T5Z", "T5Z_NMBEN ", FTafGetVal( cT5ZPath + "/nmBenefic",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                        If oDados:XPathHasNode( cT5ZPath + "/vlrPensao" )
                                            oModel:LoadValue( "MODEL_T5Z", "T5Z_VLRPEN", FTafGetVal( cT5ZPath + "/vlrPensao",   "N", .F., @aIncons, .F. ) )
                                        EndIf

                                        nT5Z++
                                        cT5ZPath := cT5YPath + "/penAlim[" + cValToChar(nT5Z) + "]"

                                    EndDo

                                    nT5Y++
                                    cT5YPath := cT5UPath + "/detRubrFer[" + cValToChar(nT5Y) + "]"

                                EndDo

                                nT5U++
                                cT5UPath := cT3QPath + "/detPgtoFer[" + cValToChar(nT5U) + "]"

                            EndDo

                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/detPgtoAnt[1]" )

                            nT5V := 1
                            cT5VPath := cT3QPath + "/detPgtoAnt[" + cValToChar(nT5V) + "]"

                            //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                            If nOpc == 4

                                For nJ := 1 to oModel:GetModel( "MODEL_T5V"  ):Length()
                                    oModel:GetModel( "MODEL_T5V"  ):GoLine(nJ)
                                    oModel:GetModel( "MODEL_T5V"  ):DeleteLine()
                                Next nJ

                            EndIf

                            nT5V := 1
                            While oDados:XPathHasNode(cT5VPath)

                                oModel:GetModel( "MODEL_T5V" ):lValid:= .T.

                                If nOpc == 4 .or. nT5V > 1
                                    oModel:GetModel( "MODEL_T5V" ):AddLine()
                                EndIf

                                If oDados:XPathHasNode( cT5VPath + "/codCateg" )
                                    oModel:LoadValue( "MODEL_T5V", "T5V_IDCATE", FGetIdInt( "codCateg", "", cT5VPath + "/codCateg",,,,@cInconMsg, @nSeqErrGrv))
                                EndIf

                                nT5X := 1
                                cT5XPath := cT5VPath + "/infoPgtoAnt[" + cValToChar(nT5X) + "]"

                                //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                                If nOpc == 4

                                    For nJ := 1 to oModel:GetModel( "MODEL_T5X" ):Length()
                                        oModel:GetModel( "MODEL_T5X" ):GoLine(nJ)
                                        oModel:GetModel( "MODEL_T5X" ):DeleteLine()
                                    Next nJ

                                EndIf

                                nT5X := 1
                                While oDados:XPathHasNode(cT5XPath)

                                    oModel:GetModel( "MODEL_T5X" ):lValid:= .T.

                                    If nOpc == 4 .or. nT5X > 1
                                        oModel:GetModel( "MODEL_T5X" ):AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_T5X", "T5X_SEQUEN", StrZero( nT5X, TamSX3( "T5X_SEQUEN" )[1] ) )

                                    If oDados:XPathHasNode( cT5XPath + "/tpBcIRRF" )
                                        oModel:LoadValue( "MODEL_T5X", "T5X_IDTPIR", FGetIdInt( "tpBcIRRF", "", cT5XPath + "/tpBcIRRF",,,,@cInconMsg, @nSeqErrGrv))
                                    EndIf

                                    If oDados:XPathHasNode( cT5XPath + "/vrBcIRRF" )
                                        oModel:LoadValue( "MODEL_T5X", "T5X_VLRBCI", FTafGetVal( cT5XPath + "/vrBcIRRF",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    nT5X++
                                    cT5XPath := cT5VPath + "/infoPgtoAnt[" + cValToChar(nT5X) + "]"

                                EndDo

                                nT5V++
                                cT5VPath := cT3QPath + "/detPgtoAnt[" + cValToChar(nT5V) + "]"

                            EndDo

                        EndIf

                        nT3Q++
                        cT3QPath := cCabec + "/infoPgto[" + CVALTOCHAR(nT3Q) + "]"

                    EndDo

                Else
                    nTpPagto    := GetSX3Cache("V6M_TPPGTO", "X3_TAMANHO")
                    nPerRef     := GetSX3Cache("V6M_PERREF", "X3_TAMANHO")
                    nIndDev     := GetSX3Cache("V6M_INDDEV", "X3_TAMANHO")
                    cChvFil     := xFilial("T3P")
                    cChvId      := T3P->T3P_ID
                    cChvVer     := T3P->T3P_VERSAO
                    cChvPgt     := Space(nTpPagto)
                    cChvPer     := Space(nPerRef)
                    cChvInd     := Space(nIndDev)

                    oModelV6M := oModel:GetModel("MODEL_V6M")
                    
                    If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")
                        oModelV9I := oModel:GetModel("MODEL_V9I")
                        oModelV9J := oModel:GetModel("MODEL_V9J")
                    EndIf

                    If nOpc == 4 .And. cIndRetif == "2"
                        For nJ := 1 To oModelV6M:Length()
                            oModelV6M:GoLine(nJ)
                            oModelV6M:DeleteLine()
                        Next
                    EndIf

                    nV6M        := 1
                    cV6MPath    := cCabec + "/infoPgto[" + cValToChar(nV6M) + "]"

                    While oDados:XPathHasNode(cV6MPath)
                        cChvPgt := PadR(FTafGetVal(cV6MPath + "/tpPgto", "C", .F., @aIncons, .F.)                    , nTpPagto)
                        cChvPer := PadR(StrTran(FTafGetVal(cV6MPath + "/perRef", "C", .F., @aIncons, .F.), "-", "")  , nPerRef)
                        cChvInd := PadR(FTafGetVal(cV6MPath + "/ideDmDev", "C", .F., @aIncons, .F.)                  , nIndDev)

                        oModelV6M:lValid := .T.

                        If !oModelV6M:SeekLine({{"V6M_TPPGTO", cChvPgt}, {"V6M_PERREF", cChvPer}, {"V6M_INDDEV", cChvInd}})
                            If !oModelV6M:IsEmpty()
                                oModelV6M:AddLine()
                            EndIf
                        Else
                            oModelV6M:DeleteLine()
                            oModelV6M:AddLine()
                        EndIf

                        If oDados:XPathHasNode(cV6MPath + "/dtPgto")
                            oModel:LoadValue("MODEL_V6M", "V6M_DTPGTO", FTafGetVal(cV6MPath + "/dtPgto", "D", .F., @aIncons, .F.))
                        EndIf

                        If oDados:XPathHasNode(cV6MPath + "/tpPgto")
                            oModel:LoadValue("MODEL_V6M", "V6M_TPPGTO", FTafGetVal(cV6MPath + "/tpPgto", "C", .F., @aIncons, .F.))
                        EndIf

                        If oDados:XPathHasNode(cV6MPath + "/perRef")
                            oModel:LoadValue("MODEL_V6M", "V6M_PERREF", StrTran(FTafGetVal(cV6MPath + "/perRef", "C", .F., @aIncons, .F.), "-"))
                        EndIf

                        If oDados:XPathHasNode(cV6MPath + "/ideDmDev")
                            oModel:LoadValue("MODEL_V6M", "V6M_INDDEV", FTafGetVal(cV6MPath + "/ideDmDev", "C", .F., @aIncons, .F.))
                        EndIf
                
                        If oDados:XPathHasNode(cV6MPath + "/vrLiq")
                            oModel:LoadValue("MODEL_V6M", "V6M_VLRLIQ", FTafGetVal(cV6MPath + "/vrLiq", "N", .F., @aIncons, .F.))
                        EndIf

                        If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")
                            If oDados:XPathHasNode(cV6MPath + "/paisResidExt")
                                oModel:LoadValue("MODEL_V6M", "V6M_PAIEXT", FGetIdInt("paisResidExt", "", cV6MPath + "/paisResidExt",,,, @cInconMsg, @nSeqErrGrv))
                            EndIf                            

                            nV9I        := 1
                            cV9IPath    := cV6MPath + "/infoPgtoExt[" + cValToChar(nV9I) + "]"

                            While oDados:XPathHasNode(cV9IPath)
                                oModelV9I:lValid := .T.
                                
                                If oDados:XPathHasNode(cV9IPath + "/indNIF")
                                    oModel:LoadValue("MODEL_V9I", "V9I_INDNIF", FTafGetVal(cV9IPath + "/indNIF", "C", .F., @aIncons, .F.))
                                EndIf

                                If oDados:XPathHasNode(cV9IPath + "/nifBenef")
                                    oModel:LoadValue("MODEL_V9I", "V9I_NIFBEN", FTafGetVal(cV9IPath + "/nifBenef", "C", .F., @aIncons, .F.))
                                EndIf  

                                If oDados:XPathHasNode(cV9IPath + "/frmTribut")
                                    oModel:LoadValue("MODEL_V9I", "V9I_FRMTRI", FGetIdInt("frmTribut", "", cV9IPath + "/frmTribut",,,, @cInconMsg, @nSeqErrGrv))
                                EndIf

                                nV9J        := 1
                                cV9JPath    := cV9IPath + "/endExt[" + cValToChar(nV9J) + "]"

                                While oDados:XPathHasNode(cV9JPath)
                                    oModelV9J:lValid := .T. 

                                    If oDados:XPathHasNode(cV9JPath + "/endDscLograd")
                                        oModel:LoadValue("MODEL_V9J", "V9J_DSCLOG", FTafGetVal(cV9JPath + "/endDscLograd", "C", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV9JPath + "/endNrLograd")
                                        oModel:LoadValue("MODEL_V9J", "V9J_NRLOGR", FTafGetVal(cV9JPath + "/endNrLograd", "C", .F., @aIncons, .F.))
                                    EndIf  

                                    If oDados:XPathHasNode(cV9JPath + "/endComplem")
                                        oModel:LoadValue("MODEL_V9J", "V9J_COMPLE", FTafGetVal(cV9JPath + "/endComplem", "C", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV9JPath + "/endBairro")
                                        oModel:LoadValue("MODEL_V9J", "V9J_BAIRRO", FTafGetVal(cV9JPath + "/endBairro", "C", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV9JPath + "/endCidade")
                                        oModel:LoadValue("MODEL_V9J", "V9J_CIDADE", FTafGetVal(cV9JPath + "/endCidade", "C", .F., @aIncons, .F.))
                                    EndIf   

                                    If oDados:XPathHasNode(cV9JPath + "/endEstado")
                                        oModel:LoadValue("MODEL_V9J", "V9J_ESTADO", FTafGetVal(cV9JPath + "/endEstado", "C", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV9JPath + "/endCodPostal")
                                        oModel:LoadValue("MODEL_V9J", "V9J_CODPOS", FTafGetVal(cV9JPath + "/endCodPostal", "C", .F., @aIncons, .F.))
                                    EndIf  

                                    If oDados:XPathHasNode(cV9JPath + "/telef")
                                        oModel:LoadValue("MODEL_V9J", "V9J_TELEF", FTafGetVal(cV9JPath + "/telef", "C", .F., @aIncons, .F.))
                                    EndIf
                                    
                                    nV9J++
                                    cV9JPath := cV9IPath + "/endExt[" + cValToChar(nV9J) + "]"                                                    
                                EndDo
                                
                                nV9I++
                                cV9IPath := cV6MPath + "/infoPgtoExt[" + cValToChar(nV9I) + "]"                                                 
                            EndDo
                        EndIf

                        nV6M++
                        cV6MPath := cCabec + "/infoPgto[" + cValToChar(nV6M) + "]"
                    EndDo
                EndIf

            EndIf

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Efetiva a operacao desejada³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If Empty(cInconMsg) .And. Empty(aIncons)

                xChkDupl := TafFormCommit( oModel, .T. )

                If ValType( xChkDupl ) == "A"

                    If xChkDupl[1]
                        Aadd(aIncons, "ERRO19" + "|" + xChkDupl[2] + "|" + xChkDupl[3])
                    Else
                        lRet := .T.
                    EndIf

                ElseIf ValType( xChkDupl ) == "L"

                    If xChkDupl
                        Aadd(aIncons, "ERRO19" )
                    Else
                        lRet := .T.
                    EndIf
                    
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

	//Zerando os arrays e os Objetos utilizados no processamento
	aSize( aRulesCad, 0 )
	aRulesCad := Nil

	aSize( aChave, 0 )
	aChave := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF407Rul
Regras para gravacao das informacoes do registro S-2365

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return
aRull  - Regras para a gravacao das informacoes

@author Vitor Siqueira
@since 29/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF407Rul( cCabec, cInconMsg, nSeqErrGrv, cCodEvent, cOwner, lExistTrab, cMatrC9V, cBenef )

	Local aRull        := {}
	Local cPeriodo     := ""

	Default cCabec     := ""
	Default cInconMsg  := ""
	Default nSeqErrGrv := 0
	Default cCodEvent  := ""
	Default cOwner     := ""
	Default cBenef     := ""
	Default lExistTrab := .F.

	//**********************************
	//eSocial/evtPgtos/ideEvento/
	//**********************************
    If !lLaySimplif

        If TafXNode(oDados, cCodEvent, cOwner, "/eSocial/evtPgtos/ideEvento/indApuracao")
            Aadd(aRull, {"T3P_INDAPU", "/eSocial/evtPgtos/ideEvento/indApuracao", "C", .F.})
        EndIf

    EndIf

	If TafXNode(oDados, cCodEvent, cOwner, "/eSocial/evtPgtos/ideEvento/perApur")
		cPeriodo := FTafGetVal("/eSocial/evtPgtos/ideEvento/perApur", "C", .F.,, .F.)
		Aadd(aRull, {"T3P_PERAPU", StrTran(cPeriodo, "-", "") ,"C", .T.})
	EndIf

    If lLaySimplif

        If TafXNode(oDados, cCodEvent, cOwner, "/eSocial/evtPgtos/ideEvento/indGuia")
            Aadd(aRull, {"T3P_TPGUIA", "/eSocial/evtPgtos/ideEvento/indGuia", "C", .F.})
        EndIf

    EndIf

	//**********************************
	//eSocial/evtPgtos/ideBenef/cpfBenef
	//**********************************
	If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtPgtos/ideBenef/cpfBenef" ) )
		//*****************************************************************************************************************************************
		//a tag de referencia para buscar o id do beneficiario neste caso é o cpfTrab, pois o trabalhador é considerado o beneficiario de pagamento
		//*****************************************************************************************************************************************

		If lExistTrab
			Aadd( aRull, {"T3P_BENEFI", cBenef, "C", .T. } )   		//cpfBenef
		Else
			Aadd( aRull, {"T3P_CPF", "/eSocial/evtPgtos/ideBenef/cpfBenef","C",.F.} )
		EndIf

	EndIf

    If !lLaySimplif

        If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtPgtos/ideBenef/deps/vrDedDep" ) )
            Aadd( aRull, {"T3P_VLDEDB", "/eSocial/evtPgtos/ideBenef/deps/vrDedDep", "N", .F. } )   		//vrDedDep
        EndIf

    EndIf
	//----------------------------------

Return aRull

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF407Xml
Retorna o Xml do Registro Posicionado

@author Vitor Siqueira
@since 29/12/2015
@version 1.0

@Param:
lJob - Informa se foi chamado por Job

@return
cXml - Estrutura do Xml do Layout S-1210
/*/
//-------------------------------------------------------------------
Function TAF407Xml(cAlias as character, nRecno as numeric, nOpc as numeric, lJob as logical)

    Local aMensal       as array
	Local cPerRef       as character
	Local cNrRecArq     as character
    Local cCodRubr      as character
    Local cTabRubric    as character
    Local cRubrica      as character
	Local cXml          as character
	Local cXmlIdePais   as character
	Local cXmlEndExt    as character
	Local cC8R_IDTBRU   as character
	Local cCpfBenefi    as character
	Local cIdBenefi     as character
	Local cLayout       as character
	Local cReg          as character
	Local cFilBkp       as character
	Local cMVIDETABR    as character
	Local lInfo1210     as logical
	Local lRubERPPad    as logical
	Local lDicAtu       as logical
	Local lXmlVLd       as logical
	Local nTamQtdDias   as numeric
    Local nPosRubric    as numeric

	Default cAlias      := "T3P"
	Default lJob        := .F.
	Default nRecno      := 1
	Default nOpc        := 1

    aMensal     := {}
	cPerRef     := ""
	cNrRecArq   := ""
    cCodRubr    := ""
    cTabRubric  := ""
    cRubrica    := ""
	cXml        := ""
	cXmlIdePais := ""
	cXmlEndExt  := ""
	cC8R_IDTBRU := ""
	cCpfBenefi  := ""
	cIdBenefi   := ""
	cLayout     := "1210"
	cReg        := "Pgtos"
	cFilBkp     := cFilAnt
	cMVIDETABR  := SuperGetMV("MV_IDETABR", .F., "0")
	lInfo1210   := .F.
	lRubERPPad  := .T.
	lDicAtu     := .T.
	lXmlVLd     := IIf(FindFunction("TafXmlVLD"), TafXmlVLD("TAF407XML"), .T.)
	nTamQtdDias := 0
    nPosRubric  := 0

	If lXmlVLd
        If !lLaySimplif
            If IsInCallStack("TAFA407") .And. (IsInCalLStack("TAFXmlLote") .Or. IsInCallStack("TAF407Xml"))
                If __lRubPad == Nil
                    lRubERPPad := cMVIDETABR == "1" .Or. (cMVIDETABR == "0" .And. ApMsgYesNo(STR0035 + CRLF + STR0036 + CRLF + STR0037, STR0038)) // "Deseja gerar o conteúdo da tag 'ideTabRubr' com o código padrão deste ERP ou conforme ERP de Origem?" // " - Sim para código padrão (T3M_ID)." // " - Não para conforme ERP de Origem (T3M_CODERP)." // "Conteúdo 'ideTabRubr' padrão?"
                    
                    If IsInCalLStack("TAFXmlLote")
                        __lRubPad := lRubERPPad
                    EndIf
                Else
                    lRubERPPad := __lRubPad
                EndIf
            EndIf
        EndIf

		If IsInCallStack("TafNewBrowse") .And. ( T3P->T3P_FILIAL <> cFilAnt )
			cFilAnt := T3P->T3P_FILIAL
		EndIf
        
		If !lLaySimplif
        
            If T3P->T3P_INDAPU == '1'

                aAdd(aMensal, T3P->T3P_INDAPU)

                If Len(Alltrim(T3P->T3P_PERAPU)) <= 4
                    aAdd(aMensal, T3P->T3P_PERAPU)
                Else
                    aAdd(aMensal, SubStr(T3P->T3P_PERAPU, 1, 4) + '-' + SubStr(T3P->T3P_PERAPU, 5, 2))
                EndIf

            EndIf
        
        Else

			If Len(Alltrim(T3P->T3P_PERAPU)) <= 4
				aAdd(aMensal, T3P->T3P_PERAPU)
			Else
				aAdd(aMensal, SubStr(T3P->T3P_PERAPU, 1, 4) + '-' + SubStr(T3P->T3P_PERAPU, 5, 2))
			EndIf

		EndIf

		If Empty(T3P->T3P_BENEFI)
			lInfo1210 := .T.
		EndIf

		cXml +=	"<ideBenef>"

		If !lInfo1210

            If TafColumnPos("T3P_ORIEVE") .And. T3P->T3P_ORIEVE == 'S2400'
			    cXml += xTafTag( "cpfBenef" , POSICIONE( "V73" , 4 , xFilial( "V73" ) + T3P->T3P_BENEFI , "V73_CPFBEN" ) )
            Else
                cXml += xTafTag( "cpfBenef" , POSICIONE( "C9V" , 1 , xFilial( "C9V" ) + T3P->T3P_BENEFI , "C9V_CPF" ) )
            EndIf

		Else

			cXml += xTafTag( "cpfBenef" , T3P->T3P_CPF )

		EndIf

        If !lLaySimplif

            If T3P->T3P_VLDEDB > 0

                If __cPicVlDe == Nil
                    __cPicVlDe := PesqPict("T3P", "T3P_VLDEDB")
                EndIf
                
                cXml +=	"<deps>"
                cXml +=	xTafTag("vrDedDep", T3P->T3P_VLDEDB, __cPicVlDe, .F.,, .T.) 
                cXml +=	"</deps>"

            EndIf

            DBSelectArea("T5Y")
            T5Y->(DBSetOrder(2)) //T5Y_FILIAL+T5Y_ID+T5Y_VERSAO+DTOS(T5Y_DTPGTO)+T5Y_TPPGTO+T5Y_IDCATE+DTOS(T5Y_DTINIG)+T5Y->T5Y_QTDIAS+T5Y->T5Y_MATRIC

            // Verifica se o índice 2da tabela T5Y está correto
            // Caso não esteja, é necessário atualizar o dicionário
            If "+T5Y_MATRIC+T5Y_IDRUBR" $ T5Y->(IndexKey( T5Y->(indexOrd()) ))  //T5Y_FILIAL+T5Y_ID+T5Y_VERSAO+DTOS(T5Y_DTPGTO)+T5Y_TPPGTO+T5Y_IDCATE+DTOS(T5Y_DTINIG)+STR(T5Y_QTDIAS)+T5Y_MATRIC+T5Y_IDRUBR

                DBSelectArea("T3Q")
                T3Q->(DBSetOrder(1))

                If T3Q->( MsSeek( xFilial( "T3Q" ) + T3P->T3P_ID + T3P->T3P_VERSAO ) )

                    DBSelectArea("CMD")
                    CMD->(DBSetOrder(2))

                    DBSelectArea("T92")
                    T92->(DBSetOrder(3))

                    DBSelectArea("T3R")
                    T3R->(DBSetOrder(1))  //T3R_FILIAL+T3R_ID+T3R_VERSAO+DTOS(T3R_DTPGTO)+T3R_TPPGTO

                    DBSelectArea("LE2")
                    LE2->(DBSetOrder(1)) //LE2_FILIAL+LE2_ID+LE2_VERSAO+DTOS(LE2_DTPGTO)+LE2_TPPGTO+LE2_PERREF+LE2_IDEDMD+LE2_INDPGT

                    DBSelectArea("LE3")
                    LE3->(DBSetOrder(1)) //LE3_FILIAL+LE3_ID+LE3_VERSAO+DTOS(LE3_DTPGTO)+LE3_TPPGTO+LE3_PERREF+LE3_IDEDMD+LE3_INDPGT+LE3_IDRUBR+LE3_SEQUEN+LE3_CPFBEN

                    DBSelectArea("LE4")
                    LE4->(DBSetOrder(1)) //LE4_FILIAL+LE4_ID+LE4_VERSAO+DTOS(LE4_DTPGTO)+LE4_TPPGTO+LE4_PERREF+LE4_IDEDMD+LE4_INDPGT+LE4_IDRUBR+LE4_IDENPG

                    DBSelectArea("T5U")
                    T5U->(DBSetOrder(1))  //T5U_FILIAL+T5U_ID+T5U_VERSAO+DTOS(T5U_DTPGTO)+T5U_TPPGTO+T5U_IDCATE

                    DBSelectArea("T5Z")
                    T5Z->(DBSetOrder(1)) //T5Z_FILIAL+T5Z_ID+T5Z_VERSAO+DTOS(T5Z_DTPGTO)+T5Z_TPPGTO+T5Z_IDCATE+DTOS(T5Z_DTINIG)+T5Z_IDRUBR+T5Z_CPFBEN

                    DBSelectArea("T5X")
                    T5X->(DBSetOrder(1)) //T5X_FILIAL+T5X_ID+T5X_VERSAO+DTOS(T5X_DTPGTO)+T5X_TPPGTO+T5X_IDCATE+T5X_IDTPIR

                    DBSelectArea("T5V")
                    T5V->(DBSetOrder(1))  //T5V_FILIAL+T5V_ID+T5V_VERSAO+DTOS(T5V_DTPGTO)+T5V_TPPGTO+T5V_IDCATE

                    DBSelectArea("T6P")
                    T6P->(DBSetOrder(1))  //T6P_FILIAL+T6P_ID+T6P_VERSAO+DTOS(T6P_DTPGTO)+T6P_TPPGTO

                    DBSelectArea("T6Q")
                    T6Q->(DBSetOrder(1)) //T6Q_FILIAL+T6Q_ID+T6Q_VERSAO+DTOS(T6Q_DTPGTO)+T6Q_TPPGTO+T6Q_PERREF+T6Q_IDEDMD+T6Q_INDPGT

                    DBSelectArea("T6R")
                    T6R->(DBSetOrder(1)) //T6R_FILIAL+T6R_ID+T6R_VERSAO+DTOS(T6R_DTPGTO)+T6R_TPPGTO+T6R_PERREF+T6R_IDEDMD+T6R_INDPGT+T6R_IDRUBR

                    DBSelectArea("CMD")
                    CMD->(DBSetOrder(5)) //CMD_FILIAL+CMD_FUNC+CMD_ATIVO

                    C08->(DBSetOrder(3)) 
                    
                    While T3Q->(!Eof()) .And. T3Q->( T3Q_FILIAL + T3Q_ID + T3Q_VERSAO) == xFilial( "T3Q" ) + T3P->T3P_ID + T3P->T3P_VERSAO

                        cXml +=		"<infoPgto>"
                        cXml +=			xTafTag( "dtPgto" , T3Q->T3Q_DTPGTO )
                        cXml +=			xTafTag( "tpPgto" , T3Q->T3Q_TPPGTO )
                        cXml +=			xTafTag( "indResBr" , xFunTrcSN( T3Q->T3Q_INDRES , 1 ) )

                        If T3R->( MsSeek( xFilial( "T3R" ) + T3Q->T3Q_ID + T3Q->T3Q_VERSAO + DTOS(T3Q->T3Q_DTPGTO) + T3Q->T3Q_TPPGTO ) )
                            
                            If __cPicVlLi == Nil
                                __cPicVlLi := PesqPict("T3R", "T3R_VLRLIQ")
                            EndIf

                            While T3R->(!Eof()) .And. T3R->( T3R_FILIAL + T3R_ID + T3R_VERSAO + DTOS(T3R_DTPGTO) + T3R_TPPGTO) == xFilial( "T3Q" ) + T3Q->T3Q_ID + T3Q->T3Q_VERSAO + DTOS(T3Q->T3Q_DTPGTO) + T3Q->T3Q_TPPGTO

                                If Len(Alltrim(T3R->T3R_PERREF)) > 4
                                    cPerRef := substr(T3R->T3R_PERREF, 1, 4) + '-' + substr(T3R->T3R_PERREF, 5, 2)
                                Else
                                    cPerRef := substr(T3R->T3R_PERREF, 1, 4)
                                EndIf

                                If T3Q->T3Q_TPPGTO $ '2|3'

                                    If T3Q->T3Q_TPPGTO == '2'

                                        If Empty(T3P->T3P_CPF)

                                            //Cenário sem multiplos vinculos
                                            //Pego o CPF
                                            cCpfBenefi	:= GetAdvFVal("C9V", "C9V_CPF", xFilial("C9V") + T3P->T3P_BENEFI + "1", 2, Space(TamSX3("C9V_CPF")[1]))
                                            cIdBenefi	:= T3P->T3P_BENEFI
                                            
                                        Else

                                            //Cenário com multiplos vinculos
                                            //Procuro pelo registro do S-2200
                                            cIdBenefi	:= TAFGetIdFunc( T3P->T3P_CPF, T3P->T3P_PERAPU )
                                                            
                                        EndIf
                                    
                                        If !Empty(T3R->T3R_NRARQ) .And. T3R->T3R_NRARQ <> "0"
                                            cNrRecArq := T3R->T3R_NRARQ
                                        Else 
                                            //-> Busca o Protocolo da Ultima Transm.
                                            cNrRecArq := RetPrtUl('2', iIf(Empty(cCpfBenefi),T3P->T3P_CPF,cCpfBenefi), T3Q->T3Q_DTPGTO, T3R->T3R_IDEDMD)
                                        EndIf

                                        If Empty(cNrRecArq)

                                            If CMD->( MsSeek( xFilial( "CMD" ) + cIdBenefi + "1" ) )
                                                cNrRecArq := CMD->CMD_PROTUL
                                            EndIf

                                        EndIf

                                        cCpfBenefi 	:= ""
                                        cIdBenefi	:= ""

                                    ElseIf T3Q->T3Q_TPPGTO == '3'

                                        If Empty(T3P->T3P_CPF)

                                            //Cenário sem multiplos vinculos
                                            //Pego o CPF
                                            cCpfBenefi	:= GetAdvFVal("C9V", "C9V_CPF", xFilial("C9V") + T3P->T3P_BENEFI + "1", 2, Space(TamSX3("C9V_CPF")[1]))
                                            cIdBenefi	:= T3P->T3P_BENEFI

                                        Else

                                            //Cenário com multiplos vinculos
                                            //Procuro pelo registro do S-2300
                                            cIdBenefi	:= TAFGetIdFunc( T3P->T3P_CPF, T3P->T3P_PERAPU )

                                        EndIf

                                        If !Empty(T3R->T3R_NRARQ) .And. T3R->T3R_NRARQ <> "0"
                                            cNrRecArq := T3R->T3R_NRARQ
                                        Else 
                                            //-> Busca o Protocolo da Ultima Transm.
                                            cNrRecArq := RetPrtUl('3', iIf(Empty(cCpfBenefi),T3P->T3P_CPF,cCpfBenefi), T3Q->T3Q_DTPGTO, T3R->T3R_IDEDMD)
                                        EndIf

                                        If Empty(cNrRecArq)
                                        
                                            //Posiciono no termino
                                            If T92->( MsSeek( xFilial( "T92" ) + cIdBenefi + "1" ) )
                                                cNrRecArq := T92->T92_PROTUL
                                            EndIf

                                        EndIf

                                        cCpfBenefi 	:= ""
                                        cIdBenefi	:= ""

                                    EndIf
                                    
                                EndIf

                                cXml +=	"<detPgtoFl>"
                                cXml +=	xTafTag("perRef"    , cPerRef		    ,, .T. )
                                cXml +=	xTafTag("ideDmDev"  , T3R->T3R_IDEDMD   ,, .F. )
                                cXml +=	xTafTag("indPgtoTt" , T3R->T3R_INDPGT   ,, .F. )
                                cXml +=	xTafTag("vrLiq"	    , T3R->T3R_VLRLIQ   , __cPicVlLi, .F.,, .T.)
                                cXml +=	xTafTag("nrRecArq"  , cNrRecArq         ,, .T. )

                                //Correção realizada para que o cNrRecArq não gere para os demais registros do S-1210
                                cNrRecArq := ""

                                If LE2->( MsSeek( xFilial( "LE2" ) + T3R->(  T3R_ID + T3R_VERSAO + DTOS(T3R_DTPGTO) + T3R_TPPGTO + T3R_PERREF + T3R_IDEDMD + T3R_INDPGT) ) )
                                    
                                    If __cPicQtdR == Nil
                                        __cPicQtdR := PesqPict("LE2", "LE2_QTDRUB")
                                        __cPicFatR := PesqPict("LE2", "LE2_FATRUB")
                                        __cPicVlUn := PesqPict("LE2", "LE2_VLRUNI")
                                        __cPicVlRu := PesqPict("LE2", "LE2_VLRRUB")
                                    EndIf

                                    While LE2->(!Eof()) .And.  LE2->(LE2_FILIAL + LE2_ID + LE2_VERSAO + DTOS(LE2_DTPGTO) + LE2_TPPGTO + LE2_PERREF + LE2_IDEDMD + LE2_INDPGT) == T3R->(T3R_FILIAL + T3R_ID + T3R_VERSAO + DTOS(T3R_DTPGTO) + T3R_TPPGTO + T3R_PERREF + T3R_IDEDMD + T3R_INDPGT )

                                        cXml +=	"<retPgtoTot>"

                                        If !lInfo1210

                                            cCodRubr := LE2->LE2_IDRUBR

                                            If !Empty(__aRubrica)
                                                nPosRubric := aScan(__aRubrica, {|x| x[2] == cCodRubr})
                                            EndIf

                                            If nPosRubric > 0

                                                cC8R_IDTBRU	:= __aRubrica[nPosRubric][1]
                                                cCodRubr	:= __aRubrica[nPosRubric][2]
                                                cTabRubric 	:= __aRubrica[nPosRubric][3]
                                                cRubrica	:= __aRubrica[nPosRubric][4]	

                                            Else

                                                C8R->(DbSetOrder(5))
                                                C8R->(MsSeek(xFilial("C8R") + cCodRubr + "1"))
                                                
                                                cC8R_IDTBRU := C8R->C8R_IDTBRU
                                                cRubrica    := C8R->C8R_CODRUB
                                                
                                                T3M->(DbSetOrder(1))
                                                T3M->(MsSeek(xFilial("T3M") + cC8R_IDTBRU))
                                                
                                                cTabRubric := IIf(lRubERPPad, T3M->T3M_ID, T3M->T3M_CODERP)
                                                
                                                AAdd(__aRubrica, {cC8R_IDTBRU, cCodRubr, cTabRubric, cRubrica})

                                            EndIf

                                            cXml += xTafTag("codRubr"   , cRubrica)
                                            cXml +=	xTafTag("ideTabRubr", cTabRubric)

                                        Else

                                            cXml +=	xTafTag("codRubr"		, LE2->LE2_RUBRIC)
                                            cXml +=	xTafTag("ideTabRubr"	, LE2->LE2_IDTABR)

                                        EndIf

                                        cXml +=	xTafTag("qtdRubr"	, LE2->LE2_QTDRUB, __cPicQtdR, .T.)
                                        cXml +=	xTafTag("fatorRubr" , LE2->LE2_FATRUB, __cPicFatR, .T.)
                                        cXml +=	xTafTag("vrUnit"	, LE2->LE2_VLRUNI, __cPicVlUn, .T.)
                                        cXml +=	xTafTag("vrRubr"	, LE2->LE2_VLRRUB, __cPicVlRu, .F.)

                                        If LE3->( MsSeek( xFilial( "LE3" ) + LE2->(  LE2_ID + LE2_VERSAO + DTOS(LE2_DTPGTO) + LE2_TPPGTO + LE2_PERREF + LE2_IDEDMD + LE2_INDPGT + LE2_IDRUBR + LE2_SEQUEN) ) )
                                           
                                            If __cPicVlPe == Nil
                                                __cPicVlPe := PesqPict("LE3", "LE3_VLRPEN")
                                            EndIf

                                            While LE3->(!Eof()) .And. LE3->(LE3_FILIAL + LE3_ID + LE3_VERSAO + DTOS(LE3_DTPGTO) + LE3_TPPGTO + LE3_PERREF + LE3_IDEDMD + LE3_INDPGT + LE3_IDRUBR + LE3_SEQUEN )  == LE2->(LE2_FILIAL + LE2_ID + LE2_VERSAO + DTOS(LE2_DTPGTO) + LE2_TPPGTO + LE2_PERREF + LE2_IDEDMD + LE2_INDPGT + LE2_IDRUBR + LE2_SEQUEN)

                                                cXml +=	"<penAlim>" 
                                                cXml +=	xTafTag("cpfBenef"      , LE3->LE3_CPFBEN				,,.F.)
                                                cXml +=	xTafTag("dtNasctoBenef" , LE3->LE3_DTNSBE               ,,.T.)
                                                cXml +=	xTafTag("nmBenefic"	    , FwCutOff(LE3->LE3_NMBEN, .T.) ,,.F.)
                                                cXml +=	xTafTag("vlrPensao"	    , LE3->LE3_VLRPEN               , __cPicVlPe, .F.)
                                                cXml +=	"</penAlim>"

                                                LE3->(DBSkip())

                                            EndDo

                                        EndIF

                                        cXml +=	"</retPgtoTot>"
                                        LE2->(DBSkip())

                                    EndDo

                                EndIf

                                If LE4->( MsSeek( xFilial( "LE4" ) + T3R->( T3R_ID + T3R_VERSAO + DTOS(T3R_DTPGTO) + T3R_TPPGTO + T3R_PERREF + T3R_IDEDMD + T3R_INDPGT) ) )
                                    
                                    If __cPicQtdR == Nil
                                        __cPicQtdR := PesqPict("LE4", "LE4_QTDRUB")
                                        __cPicFatR := PesqPict("LE4", "LE4_FATRUB")
                                        __cPicVlUn := PesqPict("LE4", "LE4_VLRUNI")
                                        __cPicVlRu := PesqPict("LE4", "LE4_VLRRUB")
                                    EndIf

                                    C9V->(DbSetOrder(1))

                                    While LE4->(!Eof()) .And. LE4->(LE4_FILIAL + LE4_ID + LE4_VERSAO + DTOS(LE4_DTPGTO) + LE4_TPPGTO + LE4_PERREF + LE4_IDEDMD + LE4_INDPGT) == T3R->(T3R_FILIAL + T3R_ID + T3R_VERSAO + DTOS(T3R_DTPGTO) + T3R_TPPGTO + T3R_PERREF + T3R_IDEDMD + T3R_INDPGT)
                                        
                                        cXml +=	"<infoPgtoParc>"
                                        
                                        If !lInfo1210

                                            C9V->(MsSeek(xFilial("C9V") + T3P->T3P_BENEFI))

                                            cXml +=	xTafTag("matricula", C9V->C9V_MATRIC,, .T.)
                                            
                                            cCodRubr := LE4->LE4_IDRUBR

                                            If !Empty(__aRubrica)
                                                nPosRubric := aScan(__aRubrica, {|x| x[2] == cCodRubr})
                                            EndIf

                                            If nPosRubric > 0

                                                cC8R_IDTBRU	:= __aRubrica[nPosRubric][1]
                                                cCodRubr	:= __aRubrica[nPosRubric][2]
                                                cTabRubric 	:= __aRubrica[nPosRubric][3]
                                                cRubrica	:= __aRubrica[nPosRubric][4]	

                                            Else

                                                C8R->(DbSetOrder(5))
                                                C8R->(MsSeek(xFilial("C8R") + cCodRubr + "1"))
                                                
                                                cC8R_IDTBRU := C8R->C8R_IDTBRU
                                                cRubrica    := C8R->C8R_CODRUB
                                                
                                                T3M->(DbSetOrder(1))
                                                T3M->(MsSeek(xFilial("T3M") + cC8R_IDTBRU))
                                                
                                                cTabRubric := IIf(lRubERPPad, T3M->T3M_ID, T3M->T3M_CODERP)
                                                
                                                AAdd(__aRubrica, {cC8R_IDTBRU, cCodRubr, cTabRubric, cRubrica})

                                            EndIf

                                            cXml += xTafTag("codRubr"   , cRubrica)
                                            cXml +=	xTafTag("ideTabRubr", cTabRubric)

                                        Else

                                            cXml +=	    xTafTag("matricula"     ,LE4->LE4_MATRIC ,,.T.)
                                            cXml +=		xTafTag("codRubr"		,LE4->LE4_RUBRIC)
                                            cXml +=		xTafTag("ideTabRubr"	,LE4->LE4_IDTABR)

                                        EndIf

                                        cXml +=	xTafTag("qtdRubr"	,LE4->LE4_QTDRUB, __cPicQtdR, .T.)
                                        cXml +=	xTafTag("fatorRubr" ,LE4->LE4_FATRUB, __cPicFatR, .T.)
                                        cXml +=	xTafTag("vrUnit"	,LE4->LE4_VLRUNI, __cPicVlUn, .T.)
                                        cXml +=	xTafTag("vrRubr"	,LE4->LE4_VLRRUB, __cPicVlRu, .F.)

                                        cXml +=	"</infoPgtoParc>"

                                        LE4->( dbSkip() )

                                    EndDo

                                EndIf

                                cXml += "</detPgtoFl>"
                                T3R->(DBSkip())

                            EndDo

                        EndIf

                        If T6P->( MsSeek( xFilial( "T6P" ) + T3Q->T3Q_ID + T3Q->T3Q_VERSAO + DTOS(T3Q->T3Q_DTPGTO) + T3Q->T3Q_TPPGTO ) )

                            If __cPicVlLi == Nil
                                __cPicVlLi := PesqPict("T6P", "T6P_VLRLIQ")
                            EndIf

                            While T6P->(!Eof()) .And. T6P->(T6P_FILIAL + T6P_ID + T6P_VERSAO + DTOS(T6P_DTPGTO) + T6P_TPPGTO) == T3Q->(T3Q_FILIAL + T3Q_ID + T3Q_VERSAO + DTOS(T3Q_DTPGTO) + T3Q_TPPGTO)

                                cXml +=	"<detPgtoBenPr>"
                                cXml +=	xTafTag("perRef"	, SubStr(T6P->T6P_PERREF, 1, 4) + '-' + SubStr(T6P->T6P_PERREF, 5, 2)   ,,.F.)
                                cXml +=	xTafTag("ideDmDev" 	, T6P->T6P_IDEDMD                                                       ,,.F.)
                                cXml +=	xTafTag("indPgtoTt" , T6P->T6P_INDPGT                                                       ,,.F.)
                                cXml +=	xTafTag("vrLiq"	   	, T6P->T6P_VLRLIQ                                                       , __cPicVlLi, .F.,, .T.)

                                If T6Q->( MsSeek( xFilial( "T6Q" ) + T6P->(  T6P_ID + T6P_VERSAO + DTOS(T6P_DTPGTO) + T6P_TPPGTO + T6P_PERREF + T6P_IDEDMD + T6P_INDPGT) ) )

                                    If __cPicQtdR == Nil
                                        __cPicQtdR := PesqPict("T6Q", "T6Q_QTDRUB")
                                        __cPicFatR := PesqPict("T6Q", "T6Q_FATRUB")
                                        __cPicVlUn := PesqPict("T6Q", "T6Q_VLRUNI")
                                        __cPicVlRu := PesqPict("T6Q", "T6Q_VLRRUB") 
                                    EndIf

                                    While T6Q->(!Eof()) .And. T6Q->( T6Q_FILIAL + T6Q_ID + T6Q_VERSAO + DTOS(T6Q_DTPGTO) + T6Q_TPPGTO + T6Q_PERREF + T6Q_IDEDMD + T6Q_INDPGT) == T6P->(T6P_FILIAL + T6P_ID + T6P_VERSAO + DTOS(T6P_DTPGTO) + T6P_TPPGTO + T6P_PERREF + T6P_IDEDMD + T6P_INDPGT )
                                        
                                        cXml +=	"<retPgtoTot>"

                                        If !lInfo1210

                                            cCodRubr := T6Q->T6Q_IDRUBR

                                            If !Empty(__aRubrica)
                                                nPosRubric := aScan(__aRubrica, {|x| x[2] == cCodRubr})
                                            EndIf

                                            If nPosRubric > 0

                                                cC8R_IDTBRU	:= __aRubrica[nPosRubric][1]
                                                cCodRubr	:= __aRubrica[nPosRubric][2]
                                                cTabRubric 	:= __aRubrica[nPosRubric][3]
                                                cRubrica	:= __aRubrica[nPosRubric][4]	

                                            Else

                                                C8R->(DbSetOrder(5))
                                                C8R->(MsSeek(xFilial("C8R") + cCodRubr + "1"))
                                                
                                                cC8R_IDTBRU := C8R->C8R_IDTBRU
                                                cRubrica    := C8R->C8R_CODRUB
                                                
                                                T3M->(DbSetOrder(1))
                                                T3M->(MsSeek(xFilial("T3M") + cC8R_IDTBRU))
                                                
                                                cTabRubric := IIf(lRubERPPad, T3M->T3M_ID, T3M->T3M_CODERP)
                                                
                                                AAdd(__aRubrica, {cC8R_IDTBRU, cCodRubr, cTabRubric, cRubrica})

                                            EndIf

                                            cXml += xTafTag("codRubr"   , cRubrica)
                                            cXml +=	xTafTag("ideTabRubr", cTabRubric)

                                        Else

                                            cXml +=		xTafTag( "codRubr"		, T6Q->T6Q_RUBRIC)
                                            cXml +=		xTafTag( "ideTabRubr"	, T6Q->T6Q_IDTABR)

                                        EndIf

                                        cXml +=	xTafTag("qtdRubr"   , T6Q->T6Q_QTDRUB, __cPicQtdR, .T.)
                                        cXml +=	xTafTag("fatorRubr" , T6Q->T6Q_FATRUB, __cPicFatR, .T.)
                                        cXml +=	xTafTag("vrUnit"    , T6Q->T6Q_VLRUNI, __cPicVlUn, .T.)
                                        cXml +=	xTafTag("vrRubr"    , T6Q->T6Q_VLRRUB, __cPicVlRu, .F.)
                                        cXml +=	"</retPgtoTot>"

                                        T6Q->(DBSkip())

                                    EndDo

                                EndIf

                                If T6R->( MsSeek( xFilial( "T6R" ) + T6P->( T6P_ID + T6P_VERSAO + DTOS(T6P_DTPGTO) + T6P_TPPGTO + T6P_PERREF + T6P_IDEDMD + T6P_INDPGT) ) )
                                    
                                    If __cPicQtdR == Nil
                                        __cPicQtdR := PesqPict("T6R", "T6R_QTDRUB")
                                        __cPicFatR := PesqPict("T6R", "T6R_FATRUB")
                                        __cPicVlUn := PesqPict("T6R", "T6R_VLRUNI")
                                        __cPicVlRu := PesqPict("T6R", "T6R_VLRRUB")
                                    EndIf

                                    While T6R->(!Eof()) .And. T6R->( T6R_FILIAL + T6R_ID + T6R_VERSAO + DTOS(T6R_DTPGTO) + T6R_TPPGTO + T6R_PERREF + T6R_IDEDMD + T6R_INDPGT) == T6P->( T6P_FILIAL + T6P_ID + T6P_VERSAO + DTOS(T6P_DTPGTO) + T6P_TPPGTO + T6P_PERREF + T6P_IDEDMD + T6P_INDPGT)
                                       
                                        cXml +=	"<infoPgtoParc>"

                                        If !lInfo1210

                                            cCodRubr := T6R->T6R_IDRUBR

                                            If !Empty(__aRubrica)
                                                nPosRubric := aScan(__aRubrica, {|x| x[2] == cCodRubr})
                                            EndIf

                                            If nPosRubric > 0

                                                cC8R_IDTBRU	:= __aRubrica[nPosRubric][1]
                                                cCodRubr	:= __aRubrica[nPosRubric][2]
                                                cTabRubric 	:= __aRubrica[nPosRubric][3]
                                                cRubrica	:= __aRubrica[nPosRubric][4]	

                                            Else

                                                C8R->(DbSetOrder(5))
                                                C8R->(MsSeek(xFilial("C8R") + cCodRubr + "1"))

                                                cC8R_IDTBRU := C8R->C8R_IDTBRU
                                                cRubrica    := C8R->C8R_CODRUB

                                                T3M->(DbSetOrder(1))
                                                T3M->(MsSeek(xFilial("T3M") + cC8R_IDTBRU))
                                                
                                                cTabRubric := IIf(lRubERPPad, T3M->T3M_ID, T3M->T3M_CODERP)
                                                
                                                AAdd(__aRubrica, {cC8R_IDTBRU, cCodRubr, cTabRubric, cRubrica})

                                            EndIf

                                            cXml += xTafTag("codRubr"   , cRubrica)
                                            cXml +=	xTafTag("ideTabRubr", cTabRubric)

                                        Else

                                            cXml +=		xTafTag( "codRubr"		, T6R->T6R_RUBRIC)
                                            cXml +=		xTafTag( "ideTabRubr"	, T6R->T6R_IDTABR)

                                        EndIf

                                        cXml +=	xTafTag("qtdRubr"	,T6R->T6R_QTDRUB, __cPicQtdR, .T.)
                                        cXml +=	xTafTag("fatorRubr" ,T6R->T6R_FATRUB, __cPicFatR, .T.)
                                        cXml +=	xTafTag("vrUnit"	,T6R->T6R_VLRUNI, __cPicVlUn, .T.)
                                        cXml +=	xTafTag("vrRubr"	,T6R->T6R_VLRRUB, __cPicVlRu, .F.)
                                        cXml +=	"</infoPgtoParc>"

                                        T6R->(DBSkip())

                                    EndDo

                                EndIf

                                cXml +=	"</detPgtoBenPr>"
                                T6P->(DBSkip())

                            EndDo
                        EndIf

                        nTamQtdDias := GetSx3Cache("T5Y_QTDIAS","X3_TAMANHO")

                        If T5U->( MsSeek( xFilial( "T5U" ) + T3Q->T3Q_ID + T3Q->T3Q_VERSAO + DTOS(T3Q->T3Q_DTPGTO) + T3Q->T3Q_TPPGTO  ) )

                            If __cPicVlLi == Nil
                                __cPicVlLi := PesqPict("T5U", "T5U_VLRLIQ")
                            EndIf

                            C87->(DbSetOrder(1))
                            C9V->(DbSetOrder(1))

                            While T5U->(!Eof()) .And. T5U->(T5U_FILIAL + T5U_ID + T5U_VERSAO + DTOS(T5U_DTPGTO) + T5U_TPPGTO ) == T3Q->(T3Q_FILIAL + T3Q_ID + T3Q_VERSAO + DTOS(T3Q_DTPGTO) + T3Q_TPPGTO )
                                
                                cXml +=	"<detPgtoFer>"

                                C87->(MsSeek(xFilial("C87") + T5U->T5U_IDCATE))

                                cXml +=	xTafTag("codCateg", C87->C87_CODIGO,, .F.)

                                If TAFColumnPos("T5U_MATRIC") .And. !Empty( T5U->T5U_MATRIC )
                                    cXml +=	xTafTag("matricula",T5U->T5U_MATRIC,,.T.)
                                Else
                                    C9V->(MsSeek(xFilial("C9V") + T3P->T3P_BENEFI))

                                    cXml +=	xTafTag("matricula", C9V->C9V_MATRIC,, .T.)
                                EndIf
                                    
                                cXml +=	xTafTag("dtIniGoz"  , T5U->T5U_DTINIG,,, .F.)
                                cXml +=	xTafTag("qtDias"    , T5U->T5U_QTDIAS,, .F.,, .T.)
                                cXml +=	xTafTag("vrLiq"	    , T5U->T5U_VLRLIQ, __cPicVlLi, .F.,, .T.)

                                If T5Y->( MsSeek(xFilial("T5Y")+T5U->(T5U_ID+T5U_VERSAO+DTOS(T5U_DTPGTO)+T5U_TPPGTO+T5U_IDCATE+DTOS(T5U_DTINIG)) +PADR(cValToChar(T5U->T5U_QTDIAS),nTamQtdDias)+ Iif(TAFColumnPos("T5Y_MATRIC"), AllTrim(T5U->T5U_MATRIC), "")  )) 
                                    
                                    If __cPicQtdR == Nil
                                        __cPicQtdR := PesqPict("T5Y", "T5Y_QTDRUB")
                                        __cPicFatR := PesqPict("T5Y", "T5Y_FATRUB")
                                        __cPicVlUn := PesqPict("T5Y", "T5Y_VLRUNI")
                                        __cPicVlRu := PesqPict("T5Y", "T5Y_VLRRUB")
                                    EndIf

                                    While T5Y->(!Eof()) .And. T5Y->(T5Y_FILIAL + T5Y_ID + T5Y_VERSAO + DTOS(T5Y_DTPGTO) + T5Y_TPPGTO + T5Y_IDCATE + DTOS(T5Y_DTINIG) + PADR(cValToChar(T5Y_QTDIAS),nTamQtdDias) + Iif(TAFColumnPos("T5Y_MATRIC"), T5Y->T5Y_MATRIC, "") ) == T5U->(T5U_FILIAL + T5U_ID + T5U_VERSAO + DTOS(T5U_DTPGTO) + T5U_TPPGTO + T5U_IDCATE + DTOS(T5U_DTINIG) + PADR(cValToChar(T5U_QTDIAS),nTamQtdDias) + Iif(TAFColumnPos("T5Y_MATRIC"), T5U->T5U_MATRIC, "")   )
                                        
                                        cXml +=	"<detRubrFer>"

                                        If !lInfo1210

                                            cCodRubr := T5Y->T5Y_IDRUBR

                                            If !Empty(__aRubrica)
                                                nPosRubric := aScan(__aRubrica, {|x| x[2] == cCodRubr})
                                            EndIf

                                            If nPosRubric > 0

                                                cC8R_IDTBRU	:= __aRubrica[nPosRubric][1]
                                                cCodRubr	:= __aRubrica[nPosRubric][2]
                                                cTabRubric 	:= __aRubrica[nPosRubric][3]
                                                cRubrica	:= __aRubrica[nPosRubric][4]	

                                            Else

                                                C8R->(DbSetOrder(5))
                                                C8R->(MsSeek(xFilial("C8R") + cCodRubr + "1"))

                                                cC8R_IDTBRU := C8R->C8R_IDTBRU
                                                cRubrica    := C8R->C8R_CODRUB
                                                
                                                T3M->(DbSetOrder(1))
                                                T3M->(MsSeek(xFilial("T3M") + cC8R_IDTBRU))

                                                cTabRubric := IIf(lRubERPPad, T3M->T3M_ID, T3M->T3M_CODERP)
                                                
                                                AAdd(__aRubrica, {cC8R_IDTBRU, cCodRubr, cTabRubric, cRubrica})

                                            EndIf

                                            cXml += xTafTag("codRubr"   , cRubrica)
                                            cXml +=	xTafTag("ideTabRubr", cTabRubric)

                                        Else

                                            cXml +=		xTafTag("codRubr"		,T5Y->T5Y_RUBRIC)
                                            cXml +=		xTafTag("ideTabRubr"	,T5Y->T5Y_IDTABR)

                                        EndIf

                                        cXml +=	xTafTag("qtdRubr"	, T5Y->T5Y_QTDRUB, __cPicQtdR, .T.)
                                        cXml +=	xTafTag("fatorRubr" , T5Y->T5Y_FATRUB, __cPicFatR, .T.)
                                        cXml +=	xTafTag("vrUnit"	, T5Y->T5Y_VLRUNI, __cPicVlUn, .T.)
                                        cXml +=	xTafTag("vrRubr"	, T5Y->T5Y_VLRRUB, __cPicVlRu, .F.)

                                        If T5Z->( MsSeek( xFilial( "T5Z" ) + T5Y->(T5Y_ID+T5Y_VERSAO+DTOS(T5Y_DTPGTO)+T5Y_TPPGTO+T5Y_IDCATE+DTOS(T5Y_DTINIG)+ PADR(cValToChar(T5Y_QTDIAS),nTamQtdDias) + Iif(TAFColumnPos("T5Y_MATRIC"), T5Y->T5Y_MATRIC, "") + T5Y_IDRUBR+T5Y_RUBRIC) ) )
                                            
                                            If __cPicVlPe == Nil
                                                __cPicVlPe := PesqPict("T5Z", "T5Z_VLRPEN")
                                            EndIf

                                            While T5Z->(!Eof()) .And. T5Z->( T5Z_FILIAL + T5Z_ID + T5Z_VERSAO + DTOS(T5Z_DTPGTO) + T5Z_TPPGTO + T5Z_IDCATE + DTOS(T5Z_DTINIG) + PADR(cValToChar(T5Z_QTDIAS),nTamQtdDias) +  Iif(TAFColumnPos("T5Y_MATRIC"), T5Z->T5Z_MATRIC, "") +  T5Z->T5Z_IDRUBR + T5Z->T5Z_RUBRIC ) ==  T5Y->(T5Y_FILIAL + T5Y_ID + T5Y_VERSAO + DTOS(T5Y_DTPGTO) + T5Y_TPPGTO + T5Y_IDCATE + DTOS(T5Y_DTINIG) + PADR(cValToChar(T5Y_QTDIAS),nTamQtdDias) + Iif(TAFColumnPos("T5Y_MATRIC"), T5Y->T5Y_MATRIC, "") + T5Y_IDRUBR + T5Y_RUBRIC)
                                                
                                                cXml +=	"<penAlim>"
                                                cXml +=	xTafTag("cpfBenef"		, T5Z->T5Z_CPFBEN				,,.F.)
                                                cXml +=	xTafTag("dtNasctoBenef" , T5Z->T5Z_DTNSBE				,,.T.)
                                                cXml +=	xTafTag("nmBenefic"		, FwCutOff(T5Z->T5Z_NMBEN, .T.)	,,.F.)
                                                cXml +=	xTafTag("vlrPensao"		, T5Z->T5Z_VLRPEN				, __cPicVlPe, .F.)
                                                cXml +=	"</penAlim>"
                                                 
                                                T5Z->(DBSkip())

                                            EndDo

                                        EndIF

                                        cXml += "</detRubrFer>"

                                        T5Y->(DBSkip())

                                    EndDo

                                Else

                                    //Seek retorna .f. -> grupo de tags obrigatorio
                                    xTafTagGroup("detRubrFer"	,{ {"codRubr"		,	''	, , .F. } ;
                                        ,  {"ideTabRubr"	,	''	, , .F. } ;
                                        ,  {"qtdRubr"		,	''	, , .T. } ;
                                        ,  {"fatorRubr"		,	''	, , .T. } ;
                                        ,  {"vrUnit"		,	''	, , .T. } ;
                                        ,  {"vrRubr"		,	''	, , .F. } } ;
                                        ,  @cXml , , .T.)

                                EndIf

                                cXml +=	"</detPgtoFer>"
                                T5U->(DBSkip())

                            EndDo

                        EndIf

                        If T5V->( MsSeek( xFilial( "T5V" ) + T3Q->T3Q_ID + T3Q->T3Q_VERSAO + DTOS(T3Q->T3Q_DTPGTO) + T3Q->T3Q_TPPGTO ) )

                            C87->(DbSetOrder(1))

                            While T5V->(!Eof()) .And. T5V->( T5V_FILIAL + T5V_ID + T5V_VERSAO + DTOS(T5V_DTPGTO) + T5V_TPPGTO ) == T3Q->(T3Q_FILIAL + T3Q_ID + T3Q_VERSAO + DTOS(T3Q_DTPGTO) + T3Q_TPPGTO)
                                
                                If T3Q->T3Q_TPPGTO == "9"

                                    cXml +=	"<detPgtoAnt>"

                                    C87->(MsSeek(xFilial("C87") + T5V->T5V_IDCATE))

                                    cXml +=	xTafTag("codCateg", C87->C87_CODIGO,, .F.,, "T5Z_VLRPEN")

                                    If T5X->( MsSeek( xFilial( "T5X" ) +  T5V->( T5V_ID+T5V_VERSAO+DTOS(T5V_DTPGTO)+T5V_TPPGTO + T5V_IDCATE ) ) )
                                        
                                        If __cPicVlRb == Nil
                                            __cPicVlRb := PesqPict("T5X", "T5X_VLRBCI")
                                        EndIf
                                        
                                        C8U->(DbSetOrder(1))

                                        While T5X->(!Eof()) .And. T5X->( T5X_FILIAL + T5X_ID + T5X_VERSAO + DTOS(T5X_DTPGTO) + T5X_TPPGTO + T5X_IDCATE) == T5V->(T5V_FILIAL + T5V_ID + T5V_VERSAO + DTOS(T5V_DTPGTO) + T5V_TPPGTO + T5V_IDCATE)
                                            
                                            C8U->(MsSeek(xFilial("C8U") + T5X->T5X_IDTPIR))                                    
                                            
                                            cXml +=	"<infoPgtoAnt>"
                                            cXml +=	xTafTag("tpBcIRRF", C8U->C8U_CODIGO,, .F.,, "T5X_IDTPIR")
                                            cXml +=	xTafTag("vrBcIRRF", T5X->T5X_VLRBCI, __cPicVlRb, .F.)
                                            cXml +=	"</infoPgtoAnt>"

                                            T5X->(DBSkip())

                                        EndDo

                                    Else

                                        //Seek retorna .f. -> grupo de tags obrigatorio
                                        xTafTagGroup("infoPgtoAnt"	,{ {"tpBcIRRF"		,	''	, , .F. } ;
                                            ,  {"vrBcIRRF"		,	''	, , .F. } } ;
                                            ,  @cXml , , .T. )

                                    EndIf

                                    cXml +=	"</detPgtoAnt>"

                                Endif

                                T5V->(DBSkip())

                            EndDo

                        EndIf

                        cXmlIdePais := ""
                        cXmlEndExt  := ""

                        C08->(MsSeek(xFilial("C08") + T3Q->T3Q_IDPAIS))

                        //Utilizacao da funcao xTafTagGroup - Encadeamento de grupos de tags (eh funcional quando nao existe um laço na geração dos grupos de tags filhos )
                        xTafTagGroup("idePais"	, { {"codPais"  , C08->C08_PAISSX   ,, .F.};
                                                ,   {"indNIF"	, T3Q->T3Q_INDNIF	,, .F.};
                                                ,   {"nifBenef"	, T3Q->T3Q_NIFBEN	,, .T.} };
                                                , @cXmlIdePais)

                        //Seek retorna .f. -> grupo de tags obrigatorio
                        xTafTagGroup("endExt"	,{ {"dscLograd"		,	FwCutOff(T3Q->T3Q_DLOUGR, .T.)	, , .F. } ;
                            ,  {"nrLograd"		,	T3Q->T3Q_NUMLOG					, , .T. } ;
                            ,  {"complem"		,	FwCutOff(T3Q->T3Q_COMPLE, .T.)	, , .T. } ;
                            ,  {"bairro"		,	FwCutOff(T3Q->T3Q_BAIRRO, .T.)	, , .T. } ;
                            ,  {"nmCid"			,	FwCutOff(T3Q->T3Q_CIDADE, .T.)	, , .F. } ;
                            ,  {"codPostal"		,	AllTrim(T3Q->T3Q_CEP)			, , .T. } } ;
                            ,  @cXmlEndExt)

                        xTafTagGroup( "idePgtoExt" , , @cXml , { { "idePais" , cXmlIdePais , 1 } , { "endExt" , cXmlEndExt , 1 } } ,,.T.)

                        cXml +=	"</infoPgto>"

                        T3Q->(DBSkip())

                    EndDo

                    T3R->(DbCloseArea())
                    LE2->(DbCloseArea())
                    LE3->(DbCloseArea())
                    LE4->(DbCloseArea())
                    T6P->(DbCloseArea())
                    T6Q->(DbCloseArea())
                    T6R->(DbCloseArea())
                    T5U->(DbCloseArea())
                    T5Z->(DbCloseArea()) 
                    T5V->(DbCloseArea())
                    T5X->(DbCloseArea())

                Else

                    //Seek retorna .f. -> grupo de tags obrigatorio
                    xTafTagGroup("infoPgto"	,{ {"dtPgto"		,	''	, , .F. } ;
                        ,  {"tpPgto"			,	''	, , .F. } ;
                        ,  {"indResBr"		,	''	, , .F. } } ;
                        ,  @cXml , , .T. )

                EndIf
                
                T3Q->(DbCloseArea())

            Else

                lDicAtu := .F.
                MsgInfo( STR0033 + ' Alias T5Y ', STR0034 )

            EndIf

            T5Y->(DbCloseArea())

        Else
            V6M->(DBSetOrder(1))

            If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")
                V9I->(DBSetOrder(1)) 
                V9J->(DBSetOrder(1)) 
                C08->(DBSetOrder(3))
                V9H->(DBSetOrder(1))
            EndIf

            If V6M->(MsSeek(xFilial("V6M") + T3P->(T3P_ID + T3P_VERSAO)))
                If __cPicVlLi == Nil
                    __cPicVlLi := PesqPict("V6M", "V6M_VLRLIQ")
                EndIf

                While !V6M->(EOF()) .And. V6M->(V6M_FILIAL + V6M_ID + V6M_VERSAO) == xFilial("T3P") + T3P->(T3P_ID + T3P_VERSAO)
                    If Len(Alltrim(V6M->V6M_PERREF)) > 4
                        cPerRef := substr(V6M->V6M_PERREF, 1, 4) + '-' + substr(V6M->V6M_PERREF, 5, 2)
                    Else
                        cPerRef := substr(V6M->V6M_PERREF, 1, 4)
                    EndIf

                    cXml +=	"<infoPgto>"
                    cXml +=	xTafTag("dtPgto"    , V6M->V6M_DTPGTO)
                    cXml +=	xTafTag("tpPgto"    , V6M->V6M_TPPGTO)
                    cXml +=	xTafTag("perRef"    , cPerRef)
                    cXml +=	xTafTag("ideDmDev"  , V6M->V6M_INDDEV)
                    cXml +=	xTafTag("vrLiq"     , V6M->V6M_VLRLIQ, __cPicVlLi,,, .T.) 

                    If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")
                        C08->(MsSeek(xFilial("C08") + V6M->V6M_PAIEXT))
                        
                        cXml +=	xTafTag("paisResidExt", C08->C08_PAISSX,, .T.)  

                        If V9I->(MsSeek(xFilial("V9I") + V6M->(V6M_ID + V6M_VERSAO + V6M_TPPGTO + V6M_PERREF + V6M_INDDEV)))
                            While !V9I->(EOF()) .And. V9I->(V9I_FILIAL + V9I_ID + V9I_VERSAO + V9I_TPPGTO + V9I_PERREF + V9I_INDDEV) == xFilial("V6M") +; 
                                    V6M->(V6M_ID + V6M_VERSAO + V6M_TPPGTO + V6M_PERREF + V6M_INDDEV)        
                                cXml +=	"<infoPgtoExt>"
                                cXml +=	xTafTag("indNIF"    , V9I->V9I_INDNIF)
                                cXml +=	xTafTag("nifBenef"  , V9I->V9I_NIFBEN,, .T.)
                                
                                V9H->(MsSeek(xFilial("V9H") + V9I->V9I_FRMTRI))
                                
                                cXml +=	xTafTag("frmTribut", V9H->V9H_CODIGO)
                                
                                If V9J->(MsSeek(xFilial("V9J") + V6M->(V6M_ID + V6M_VERSAO + V6M_TPPGTO + V6M_PERREF + V6M_INDDEV)))
                                    While !V9J->(EOF()) .And. V9J->(V9J_FILIAL + V9J_ID + V9J_VERSAO + V9J_TPPGTO + V9J_PERREF + V9J_INDDEV) == xFilial("V6M") +; 
                                            V6M->(V6M_ID + V6M_VERSAO + V6M_TPPGTO + V6M_PERREF + V6M_INDDEV)        
                                        cXml +=	"<endExt>"
                                        cXml +=	xTafTag("endDscLograd"  , FwCutOff(V9J->V9J_DSCLOG))
                                        cXml +=	xTafTag("endNrLograd"   , AllTrim(V9J->V9J_NRLOGR))
                                        cXml +=	xTafTag("endComplem"    , FwCutOff(V9J->V9J_COMPLE))
                                        cXml +=	xTafTag("endBairro"     , FwCutOff(V9J->V9J_BAIRRO))
                                        cXml +=	xTafTag("endCidade"     , FwCutOff(V9J->V9J_CIDADE))
                                        cXml +=	xTafTag("endEstado"     , FwCutOff(V9J->V9J_ESTADO))                                                  
                                        cXml +=	xTafTag("endCodPostal"  , AllTrim(V9J->V9J_CODPOS))                    
                                        cXml +=	xTafTag("telef"         , AllTrim(V9J->V9J_TELEF))   
                                        cXml +=	"</endExt>"
                                    
                                        V9J->(DbSkip())
                                    EndDo
                                EndIf
                                
                                cXml +=	"</infoPgtoExt>"

                                V9I->(DbSkip())
                            EndDo
                        EndIf
                    EndIf

                    cXml +=	"</infoPgto>"

                    V6M->(DbSkip())
                EndDo            
            EndIf
        EndIf

        cXml +=	"</ideBenef>"

        /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³Estrutura do cabecalho  ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
        cXml := xTafCabXml(cXml,"T3P",cLayout,cReg, aMensal)

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Executa gravacao do registro  ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !lJob .And. lDicAtu
			xTafGerXml(cXml,cLayout)
		EndIf

		cFilAnt := cFilBkp
	EndIf

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@author Vitor Siqueira
@since 29/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc(oModel as object, nRecno as numeric, lRotExc as logical)

	Local aGrava        as array
	Local aGravaT3Q     as array
	Local aGravaT3R     as array
	Local aGravaLE2     as array
	Local aGravaLE3     as array
	Local aGravaLE4     as array
	Local aGravaT6P     as array
	Local aGravaT6Q     as array
	Local aGravaT6R     as array
	Local aGravaT5U     as array
	Local aGravaT5Y     as array
	Local aGravaT5Z     as array
	Local aGravaT5V     as array
	Local aGravaT5X     as array
    Local aGravaV6M     as array
    Local aGravaV9I     as array
    Local aGravaV9J     as array
	Local cVerAnt       as character
	Local cProtocolo    as character
	Local cVersao       as character
	Local cEvento       as character
	Local nI            as numeric
	Local nT3Q          as numeric
	Local nT3R          as numeric
	Local nT6P          as numeric
	Local nLE2          as numeric
	Local nT6Q          as numeric
	Local nLE3          as numeric
	Local nLE4          as numeric
	Local nT6R          as numeric
	Local nT5U          as numeric
	Local nT5Y          as numeric
	Local nT5Z          as numeric
	Local nT5V          as numeric
	Local nT5X          as numeric
    Local nV6M          as numeric
    Local nV9I          as numeric
    Local nV9J          as numeric
	Local nT3RAdd       as numeric
	Local nLE2Add       as numeric
	Local nLE3Add       as numeric
	Local nLE4Add       as numeric
	Local nT6PAdd       as numeric
	Local nT6QAdd       as numeric
	Local nT6RAdd       as numeric
	Local nT5UAdd       as numeric
	Local nT5XAdd       as numeric
	Local nT5YAdd       as numeric
	Local nT5ZAdd       as numeric
	Local nT5VAdd       as numeric
    Local nV6MAdd       as numeric
	Local oModelT3P     as object 
	Local oModelT3Q     as object 
	Local oModelT3R     as object 
	Local oModelLE2     as object 
	Local oModelLE3     as object 
	Local oModelLE4     as object 
	Local oModelT6P     as object 
	Local oModelT6Q     as object 
	Local oModelT5U     as object 
	Local oModelT5Y     as object 
	Local oModelT5Z     as object 
	Local oModelT5V     as object 
	Local oModelT5X     as object 
    Local oModelV6M     as object 
    Local oModelV9I     as object
    Local oModelV9J     as object

    Default oModel      := Nil
    Default lRotExc     := .F.
    Default nRecno      := 0

	aGrava      := {}
	aGravaT3Q   := {}
	aGravaT3R   := {}
	aGravaLE2   := {}
	aGravaLE3   := {}
	aGravaLE4   := {}
	aGravaT6P   := {}
	aGravaT6Q   := {}
	aGravaT6R   := {}
	aGravaT5U   := {}
	aGravaT5Y   := {}
	aGravaT5Z   := {}
	aGravaT5V   := {}
	aGravaT5X   := {}
    aGravaV6M   := {}
    aGravaV9I   := {}
    aGravaV9J   := {}
	cVerAnt     := ""
	cProtocolo  := ""
	cVersao     := ""
	cEvento     := ""
	nI          := 0
	nT3Q        := 0
	nT3R        := 0
	nT6P        := 0
	nLE2        := 0
	nT6Q        := 0
	nLE3        := 0
	nLE4        := 0
	nT6R        := 0
	nT5U        := 0
	nT5Y        := 0
	nT5Z        := 0
	nT5V        := 0
	nT5X        := 0
    nV6M        := 0
    nV9I        := 0
    nV9J        := 0
	nT3RAdd     := 0
	nLE2Add     := 0
	nLE3Add     := 0
	nLE4Add     := 0
	nT6PAdd     := 0
	nT6QAdd     := 0
	nT6RAdd     := 0
	nT5UAdd     := 0
	nT5XAdd     := 0
	nT5YAdd     := 0
	nT5ZAdd     := 0
	nT5VAdd     := 0
    nV6MAdd     := 0
	oModelT3P   := Nil
	oModelT3Q   := Nil
	oModelT3R   := Nil
	oModelLE2   := Nil
	oModelLE3   := Nil
	oModelLE4   := Nil
	oModelT6P   := Nil
	oModelT6Q   := Nil
	oModelT5U   := Nil
	oModelT5Y   := Nil
	oModelT5Z   := Nil
	oModelT5V   := Nil
	oModelT5X   := Nil
    oModelV6M   := Nil
    oModelV9I   := Nil
    oModelV9J   := Nil

    If oModel != Nil
        Begin Transaction
            //Posiciona o item
            ("T3P")->( DBGoTo( nRecno ) )

            oModelT3P 	:= oModel:GetModel( "MODEL_T3P" )
            oModelV6M 	:= oModel:GetModel( "MODEL_V6M" )

            //Guardo as informações do registro corrente para rastro do registro
            cVerAnt   	:= oModelT3P:GetValue( "T3P_VERSAO" )
            cProtocolo	:= oModelT3P:GetValue( "T3P_PROTUL" )
            cEvento	:= oModelT3P:GetValue( "T3P_EVENTO" )

            //Armazeno as informações correntes do cadastro( Depois da alteração do Usuário )

            /*------------------------------------------
            T3P - Pgto Rendimentos do Trabalho
            --------------------------------------------*/
            For nI := 1 to Len( oModelT3P:aDataModel[ 1 ] )
                Aadd( aGrava, { oModelT3P:aDataModel[ 1, nI, 1 ], oModelT3P:aDataModel[ 1, nI, 2 ] } )
            Next nI

            If !lLaySimplif

                //Posicionando no registro
                DBSelectArea("T3Q")
                DBSetOrder(1)

                If T3Q->(MsSeek(xFilial("T3Q")+T3P->(T3P_ID + T3P_VERSAO) ) )
                    
                    oModelT3Q 	:= oModel:GetModel( "MODEL_T3Q" )
                    oModelT3R 	:= oModel:GetModel( "MODEL_T3R" )
                    oModelLE2	:= oModel:GetModel( "MODEL_LE2" )
                    oModelLE3 	:= oModel:GetModel( "MODEL_LE3" )
                    oModelLE4 	:= oModel:GetModel( "MODEL_LE4" )
                    oModelT6P 	:= oModel:GetModel( "MODEL_T6P" )
                    oModelT6Q 	:= oModel:GetModel( "MODEL_T6Q" )
                    oModelT6R 	:= oModel:GetModel( "MODEL_T6R" )
                    oModelT5U 	:= oModel:GetModel( "MODEL_T5U" )
                    oModelT5Y 	:= oModel:GetModel( "MODEL_T5Y" )
                    oModelT5Z 	:= oModel:GetModel( "MODEL_T5Z" )
                    oModelT5V 	:= oModel:GetModel( "MODEL_T5V" )
                    oModelT5X 	:= oModel:GetModel( "MODEL_T5X" )

                    /*------------------------------------------
                    T3Q - Informações dos Pagamentos Efetuados
                    --------------------------------------------*/
                    For nT3Q := 1 To oModel:GetModel( "MODEL_T3Q" ):Length()

                        oModel:GetModel( "MODEL_T3Q" ):GoLine(nT3Q)

                        If !oModel:GetModel( "MODEL_T3Q" ):IsDeleted()

                            aAdd(aGravaT3Q,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                            oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                            oModelT3Q:GetValue("T3Q_INDRES"),;
                                            oModelT3Q:GetValue("T3Q_IDPAIS"),;
                                            oModelT3Q:GetValue("T3Q_INDNIF"),;
                                            oModelT3Q:GetValue("T3Q_NIFBEN"),;
                                            oModelT3Q:GetValue("T3Q_DLOUGR"),;
                                            oModelT3Q:GetValue("T3Q_NUMLOG"),;
                                            oModelT3Q:GetValue("T3Q_COMPLE"),;
                                            oModelT3Q:GetValue("T3Q_BAIRRO"),;
                                            oModelT3Q:GetValue("T3Q_CIDADE"),;
                                            oModelT3Q:GetValue("T3Q_CEP")})

                            /*------------------------------------------
                            T3R - Detalhamento dos pagamentos efetuados, apurados em S-1200 ou S-1202/
                            Detalhamento dos pagamentos efetuados relativos a rescisões contratuais
                            --------------------------------------------*/
                            For nT3R := 1 to oModel:GetModel( "MODEL_T3R" ):Length()

                                oModel:GetModel( "MODEL_T3R" ):GoLine(nT3R)

                                If !oModel:GetModel( "MODEL_T3R" ):IsEmpty()

                                    If !oModel:GetModel( "MODEL_T3R" ):IsDeleted()

                                        aAdd (aGravaT3R ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                        oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                        oModelT3R:GetValue('T3R_PERREF'),;
                                                        oModelT3R:GetValue('T3R_IDEDMD'),;
                                                        oModelT3R:GetValue('T3R_INDPGT'),;
                                                        oModelT3R:GetValue('T3R_VLRLIQ')})

                                    /*------------------------------------------
                                    LE2 - Retenções efetuadas (Rubrica)
                                    --------------------------------------------*/
                                    For nLE2 := 1 to oModel:GetModel( "MODEL_LE2" ):Length()

                                        oModel:GetModel( "MODEL_LE2" ):GoLine(nLE2)

                                        If !oModel:GetModel( "MODEL_LE2" ):IsEmpty()

                                            If !oModel:GetModel( "MODEL_LE2" ):IsDeleted()

                                                aAdd (aGravaLE2 ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                oModelT3R:GetValue('T3R_PERREF'),;
                                                                oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                oModelT3R:GetValue('T3R_INDPGT'),;
                                                                oModelLE2:GetValue('LE2_IDRUBR'),;
                                                                oModelLE2:GetValue('LE2_QTDRUB'),;
                                                                oModelLE2:GetValue('LE2_FATRUB'),;
                                                                oModelLE2:GetValue('LE2_VLRRUB'),;
                                                                oModelLE2:GetValue('LE2_VLRUNI'),;
                                                                oModelLE2:GetValue('LE2_SEQUEN'),;
                                                                oModelLE2:GetValue('LE2_RUBRIC'),;
                                                                oModelLE2:GetValue('LE2_IDTABR')})

                                                /*------------------------------------------
                                                LE3 - Informações sobre beneficiários de pensão alimentícia
                                                --------------------------------------------*/
                                                For nLE3 := 1 to oModel:GetModel( "MODEL_LE3" ):Length()

                                                    oModel:GetModel( "MODEL_LE3" ):GoLine(nLE3)

                                                        If !oModel:GetModel( "MODEL_LE3" ):IsEmpty()

                                                            If !oModel:GetModel( "MODEL_LE3" ):IsDeleted()

                                                                aAdd (aGravaLE3 ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                    oModelT3R:GetValue('T3R_PERREF'),;
                                                                                    oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                                    oModelT3R:GetValue('T3R_INDPGT'),;
                                                                                    oModelLE2:GetValue('LE2_IDRUBR'),;
                                                                                    oModelLE3:GetValue('LE3_CPFBEN'),;
                                                                                    oModelLE3:GetValue('LE3_DTNSBE'),;
                                                                                    oModelLE3:GetValue('LE3_NMBEN'),;
                                                                                    oModelLE3:GetValue('LE3_VLRPEN'),;
                                                                                    oModelLE2:GetValue('LE2_SEQUEN'),;
                                                                                    oModelLE2:GetValue('LE2_RUBRIC');
                                                                                    })
                                                            EndIF

                                                        EndIF

                                                    Next//LE3

                                                EndIf

                                            EndIF

                                        Next//LE2

                                        /*------------------------------------------
                                        LE4 - Composição das bases de cálculo, deduções e isenções do IRRF
                                        --------------------------------------------*/
                                        For nLE4 := 1 to oModel:GetModel( "MODEL_LE4" ):Length()

                                            oModel:GetModel( "MODEL_LE4" ):GoLine(nLE4)

                                            If !oModel:GetModel( "MODEL_LE4" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_LE4" ):IsDeleted()

                                                    aAdd (aGravaLE4 ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                        oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                        oModelT3R:GetValue('T3R_PERREF'),;
                                                                        oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                        oModelT3R:GetValue('T3R_INDPGT'),;
                                                                        oModelLE4:GetValue('LE4_IDRUBR'),;
                                                                        oModelLE4:GetValue('LE4_QTDRUB'),;
                                                                        oModelLE4:GetValue('LE4_FATRUB'),;
                                                                        oModelLE4:GetValue('LE4_VLRRUB'),;
                                                                        oModelLE4:GetValue('LE4_VLRUNI'),;
                                                                        oModelLE4:GetValue('LE4_RUBRIC'),;
                                                                        oModelLE4:GetValue('LE4_IDTABR'),;
                                                                        oModelLE4:GetValue('LE4_MATRIC')})

                                                EndIf
                                            EndIf
                                        Next//LE4

                                    EndIf
                                EndIf
                            Next//nT3R

                            /*------------------------------------------
                            T6P - Detalhamento dos pagamentos efetuados, apurados em S-1200 ou S-1202/
                            Detalhamento dos pagamentos efetuados relativos a rescisões contratuais
                            --------------------------------------------*/
                            For nT6P := 1 to oModel:GetModel( "MODEL_T6P" ):Length()

                                oModel:GetModel( "MODEL_T6P" ):GoLine(nT6P)

                                If !oModel:GetModel( "MODEL_T6P" ):IsEmpty()

                                    If !oModel:GetModel( "MODEL_T6P" ):IsDeleted()

                                        aAdd (aGravaT6P ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                        oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                        oModelT6P:GetValue('T6P_PERREF'),;
                                                        oModelT6P:GetValue('T6P_IDEDMD'),;
                                                        oModelT6P:GetValue('T6P_INDPGT'),;
                                                        oModelT6P:GetValue('T6P_VLRLIQ')})

                                        /*------------------------------------------
                                            T6Q - Retenções efetuadas (Rubrica)
                                        --------------------------------------------*/
                                        For nT6Q := 1 to oModel:GetModel( "MODEL_T6Q" ):Length()

                                            oModel:GetModel( "MODEL_T6Q" ):GoLine(nT6Q)

                                            If !oModel:GetModel( "MODEL_T6Q" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_T6Q" ):IsDeleted()

                                                    aAdd (aGravaT6Q ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                    oModelT6P:GetValue('T6P_PERREF'),;
                                                                    oModelT6P:GetValue('T6P_IDEDMD'),;
                                                                    oModelT6P:GetValue('T6P_INDPGT'),;
                                                                    oModelT6Q:GetValue('T6Q_IDRUBR'),;
                                                                    oModelT6Q:GetValue('T6Q_QTDRUB'),;
                                                                    oModelT6Q:GetValue('T6Q_FATRUB'),;
                                                                    oModelT6Q:GetValue('T6Q_VLRRUB'),;
                                                                    oModelT6Q:GetValue('T6Q_VLRUNI'),;
                                                                    oModelT6Q:GetValue('T6Q_RUBRIC'),;
                                                                    oModelT6Q:GetValue('T6Q_IDTABR')})

                                                EndIf
                                            EndIf
                                        Next//T6Q

                                        /*------------------------------------------
                                            T6R - Composição das bases de cálculo, deduções e isenções do IRRF
                                        --------------------------------------------*/
                                        For nT6R := 1 to oModel:GetModel( "MODEL_T6R" ):Length()

                                            oModel:GetModel( "MODEL_T6R" ):GoLine(nT6R)

                                            If !oModel:GetModel( "MODEL_T6R" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_T6R" ):IsDeleted()

                                                    aAdd (aGravaT6R ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                    oModelT6P:GetValue('T6P_PERREF'),;
                                                                    oModelT6P:GetValue('T6P_IDEDMD'),;
                                                                    oModelT6P:GetValue('T6P_INDPGT'),;
                                                                    oModelT6R:GetValue('T6R_IDRUBR'),;
                                                                    oModelT6R:GetValue('T6R_QTDRUB'),;
                                                                    oModelT6R:GetValue('T6R_FATRUB'),;
                                                                    oModelT6R:GetValue('T6R_VLRRUB'),;
                                                                    oModelT6R:GetValue('T6R_VLRUNI'),;
                                                                    oModelT6R:GetValue('T6R_RUBRIC'),;
                                                                    oModelT6R:GetValue('T6R_IDTABR')})

                                                EndIf
                                            EndIf
                                        Next//T6R

                                    EndIf
                                EndIf
                            Next//nT6P

                            /*------------------------------------------
                            T5U - Detalhamento Rub Recibo Férias
                            --------------------------------------------*/
                            For nT5U := 1 to oModel:GetModel( "MODEL_T5U" ):Length()

                                oModel:GetModel( "MODEL_T5U" ):GoLine(nT5U)

                                If !oModel:GetModel( "MODEL_T5U" ):IsEmpty()

                                    If !oModel:GetModel( "MODEL_T5U" ):IsDeleted()

                                        aAdd (aGravaT5U ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                        oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                        oModelT5U:GetValue('T5U_IDCATE'),;
                                                        oModelT5U:GetValue('T5U_DTINIG'),;
                                                        oModelT5U:GetValue('T5U_QTDIAS'),;
                                                        oModelT5U:GetValue('T5U_VLRLIQ'),;
                                                        oModelT5U:GetValue('T5U_MATRIC')})

                                        /*------------------------------------------
                                        T5Y - Retenções efetuadas (Rubrica)
                                        --------------------------------------------*/
                                        For nT5Y := 1 to oModel:GetModel( "MODEL_T5Y" ):Length()

                                            oModel:GetModel( "MODEL_T5Y" ):GoLine(nT5Y)

                                            If !oModel:GetModel( "MODEL_T5Y" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_T5Y" ):IsDeleted()

                                                    aAdd (aGravaT5Y ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                    oModelT5U:GetValue('T5U_IDCATE'),;
                                                                    oModelT5U:GetValue('T5U_DTINIG'),;
                                                                    oModelT5Y:GetValue('T5Y_IDRUBR'),;
                                                                    oModelT5Y:GetValue('T5Y_QTDRUB'),;
                                                                    oModelT5Y:GetValue('T5Y_FATRUB'),;
                                                                    oModelT5Y:GetValue('T5Y_VLRRUB'),;
                                                                    oModelT5Y:GetValue('T5Y_VLRUNI'),;
                                                                    oModelT5Y:GetValue('T5Y_RUBRIC'),;
                                                                    oModelT5Y:GetValue('T5Y_IDTABR')})

                                                    /*------------------------------------------
                                                    T5Z - Informações sobre beneficiários de pensão alimentícia
                                                    --------------------------------------------*/
                                                    For nT5Z := 1 to oModel:GetModel( "MODEL_T5Z" ):Length()

                                                        oModel:GetModel( "MODEL_T5Z" ):GoLine(nT5Z)

                                                        If !oModel:GetModel( "MODEL_T5Z" ):IsEmpty()

                                                            If !oModel:GetModel( "MODEL_T5Z" ):IsDeleted()

                                                                aAdd (aGravaT5Z ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                    oModelT5U:GetValue('T5U_IDCATE'),;
                                                                                    oModelT5U:GetValue('T5U_DTINIG'),;
                                                                                    oModelT5Y:GetValue('T5Y_IDRUBR'),;
                                                                                    oModelT5Z:GetValue('T5Z_CPFBEN'),;
                                                                                    oModelT5Z:GetValue('T5Z_DTNSBE'),;
                                                                                    oModelT5Z:GetValue('T5Z_NMBEN'),;
                                                                                    oModelT5Z:GetValue('T5Z_VLRPEN')})

                                                            EndIF
                                                        EndIf
                                                    Next//T5Z

                                                EndIf
                                            EndIf
                                        Next//T5Y

                                    EndIf
                                EndIf
                            Next//T5U

                            /*------------------------------------------
                            T5V - Pgto Relat Compet Anteriores
                            --------------------------------------------*/
                            For nT5V := 1 to oModel:GetModel( "MODEL_T5V" ):Length()

                                oModel:GetModel( "MODEL_T5V" ):GoLine(nT5V)

                                If !oModel:GetModel( "MODEL_T5V" ):IsEmpty()

                                    If !oModel:GetModel( "MODEL_T5V" ):IsDeleted()

                                        aAdd (aGravaT5V ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                        oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                        oModelT5V:GetValue('T5V_IDCATE')})

                                        /*------------------------------------------
                                        T5X - Retenções efetuadas (Rubrica)
                                        --------------------------------------------*/
                                        For nT5X := 1 to oModel:GetModel( "MODEL_T5X" ):Length()

                                            oModel:GetModel( "MODEL_T5X" ):GoLine(nT5X)

                                            If !oModel:GetModel( "MODEL_T5X" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_T5X" ):IsDeleted()

                                                    aAdd (aGravaT5X ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                    oModelT5V:GetValue('T5V_IDCATE'),;
                                                                    oModelT5X:GetValue('T5X_SEQUEN'),;
                                                                    oModelT5X:GetValue('T5X_IDTPIR'),;
                                                                    oModelT5X:GetValue('T5X_VLRBCI')})

                                                EndIf
                                            EndIf
                                        Next//T5X

                                    EndIf
                                EndIf
                            Next//nT5V

                        EndIf
                    Next //nT3Q

                EndIf

            Else
                V6M->(DbSetOrder(1))

                If V6M->(MsSeek(xFilial("V6M") + T3P->(T3P_ID + T3P_VERSAO)))
                    oModelV6M := oModel:GetModel("MODEL_V6M")
                    oModelV9I := oModel:GetModel("MODEL_V9I")
                    oModelV9J := oModel:GetModel("MODEL_V9J")

                    For nV6M := 1 To oModel:GetModel("MODEL_V6M"):Length()
                        oModel:GetModel("MODEL_V6M"):GoLine(nV6M)

                        If !oModel:GetModel("MODEL_V6M"):IsEmpty()
                            If !oModel:GetModel("MODEL_V6M"):IsDeleted()
                                AAdd(aGravaV6M, {   oModelV6M:GetValue("V6M_DTPGTO"),;
                                                    oModelV6M:GetValue("V6M_TPPGTO"),;
                                                    oModelV6M:GetValue("V6M_PERREF"),;
                                                    oModelV6M:GetValue("V6M_INDDEV"),;
                                                    oModelV6M:GetValue("V6M_VLRLIQ")    })

                                If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")
                                    AAdd(aGravaV6M[nV6M], oModelV6M:GetValue("V6M_PAIEXT"))

                                    For nV9I := 1 To oModel:GetModel("MODEL_V9I"):Length()
                                        oModel:GetModel("MODEL_V9I"):GoLine(nV9I)

                                        If !oModel:GetModel("MODEL_V9I"):IsEmpty()
                                            If !oModel:GetModel("MODEL_V9I"):IsDeleted()
                                                AAdd(aGravaV9I, {   oModelV6M:GetValue("V6M_TPPGTO"),;
                                                                    oModelV6M:GetValue("V6M_PERREF"),;
                                                                    oModelV6M:GetValue("V6M_INDDEV"),;
                                                                    oModelV9I:GetValue("V9I_INDNIF"),;
                                                                    oModelV9I:GetValue("V9I_NIFBEN"),;
                                                                    oModelV9I:GetValue("V9I_FRMTRI")    })
                                            
                                                For nV9J := 1 To oModel:GetModel("MODEL_V9J"):Length()
                                                    oModel:GetModel("MODEL_V9J"):GoLine(nV9J)

                                                    If !oModel:GetModel("MODEL_V9J"):IsEmpty()
                                                        If !oModel:GetModel("MODEL_V9J"):IsDeleted()
                                                            AAdd(aGravaV9J, {   oModelV6M:GetValue("V6M_TPPGTO"),;
                                                                                oModelV6M:GetValue("V6M_PERREF"),;
                                                                                oModelV6M:GetValue("V6M_INDDEV"),;   
                                                                                oModelV9J:GetValue("V9J_DSCLOG"),;
                                                                                oModelV9J:GetValue("V9J_NRLOGR"),;
                                                                                oModelV9J:GetValue("V9J_COMPLE"),;
                                                                                oModelV9J:GetValue("V9J_BAIRRO"),;
                                                                                oModelV9J:GetValue("V9J_CIDADE"),;
                                                                                oModelV9J:GetValue("V9J_ESTADO"),;
                                                                                oModelV9J:GetValue("V9J_CODPOS"),;
                                                                                oModelV9J:GetValue("V9J_TELEF" )   })
                                                        EndIf
                                                    EndIf
                                                Next
                                            EndIf
                                        EndIf
                                    Next
                                EndIf
                            EndIf
                        EndIf
                    Next
                EndIf       
            EndIf

            /*----------------------------------------------------------
            Seto o campo como Inativo e gravo a versao do novo registro
            no registro anterior

            ATENCAO -> A alteracao destes campos deve sempre estar
            abaixo do Loop do For, pois devem substituir as informacoes
            que foram armazenadas no Loop acima
            -----------------------------------------------------------*/
            FAltRegAnt( "T3P", "2" )

            /*----------------------------------------------------------
            Apos deixar o registro corrente como inativo eu seto a
            operação de inclusão para o novo registro
            -----------------------------------------------------------*/
            oModel:DeActivate()
            oModel:SetOperation( 3 )
            oModel:Activate()

            /*----------------------------------------------------------
            Neste momento eu realizo a gravação de um novo registro idêntico
            ao original, apenas com as alterações nos campos modificados
            pelo usuário no cadastro
            -----------------------------------------------------------*/

            /*------------------------------------------
                T3P - Pgto Rendimentos do Trabalho
            --------------------------------------------*/
            For nI := 1 to Len( aGrava )
                oModel:LoadValue( "MODEL_T3P", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
            Next nI

            If !lLaySimplif

                /*------------------------------------------
                T3Q - Informações dos Pagamentos Efetuados
                --------------------------------------------*/
                For nT3Q := 1 to Len( aGravaT3Q )

                    oModel:GetModel( 'MODEL_T3Q' ):LVALID	:= .T.

                    If nT3Q > 1
                        oModel:GetModel( "MODEL_T3Q" ):AddLine()
                    EndIf

                    oModel:LoadValue( "MODEL_T3Q", "T3Q_DTPGTO" , aGravaT3Q[nT3Q][1] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_TPPGTO" , aGravaT3Q[nT3Q][2] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_INDRES",  aGravaT3Q[nT3Q][3] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_IDPAIS",  aGravaT3Q[nT3Q][4] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_INDNIF",  aGravaT3Q[nT3Q][5] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_NIFBEN",  aGravaT3Q[nT3Q][6] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_DLOUGR",  aGravaT3Q[nT3Q][7] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_NUMLOG",  aGravaT3Q[nT3Q][8] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_COMPLE",  aGravaT3Q[nT3Q][9] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_BAIRRO",  aGravaT3Q[nT3Q][10] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_CIDADE",  aGravaT3Q[nT3Q][11] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_CEP"   ,  aGravaT3Q[nT3Q][12] )

                    /*------------------------------------------------------------------------------
                    T3R - Detalhamento dos pagamentos efetuados, apurados em S-1200 ou S-1202/
                    Detalhamento dos pagamentos efetuados relativos a rescisões contratuais
                    --------------------------------------------------------------------------------*/
                    nT3RAdd := 1
                    For nT3R := 1 to Len( aGravaT3R )

                        If  DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                            oModel:GetModel( "MODEL_T3R" ):LVALID := .T.

                            If nT3RAdd > 1
                                oModel:GetModel( "MODEL_T3R" ):AddLine()
                            EndIf

                            oModel:LoadValue( "MODEL_T3R", "T3R_PERREF", aGravaT3R[nT3R][3] )
                            oModel:LoadValue( "MODEL_T3R", "T3R_IDEDMD", aGravaT3R[nT3R][4] )
                            oModel:LoadValue( "MODEL_T3R", "T3R_INDPGT", aGravaT3R[nT3R][5] )
                            oModel:LoadValue( "MODEL_T3R", "T3R_VLRLIQ", aGravaT3R[nT3R][6] )

                            /*------------------------------------------
                            LE2 - Retenções efetuadas (Rubrica)
                            --------------------------------------------*/
                            nLE2Add := 1
                            For nLE2 := 1 to Len( aGravaLE2 )

                                If  DTOS(aGravaLE2[nLE2][1])+aGravaLE2[nLE2][2]+aGravaLE2[nLE2][3]+aGravaLE2[nLE2][4]+aGravaLE2[nLE2][5] == DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2]+aGravaT3R[nT3R][3]+aGravaT3R[nT3R][4]+aGravaT3R[nT3R][5]
                                    
                                    oModel:GetModel( "MODEL_LE2" ):LVALID := .T.

                                    If nLE2Add > 1
                                        oModel:GetModel( "MODEL_LE2" ):AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_LE2" , "LE2_IDRUBR", aGravaLE2[nLE2][6] )
                                    oModel:LoadValue( "MODEL_LE2" , "LE2_QTDRUB", aGravaLE2[nLE2][7] )
                                    oModel:LoadValue( "MODEL_LE2" , "LE2_FATRUB", aGravaLE2[nLE2][8] )
                                    oModel:LoadValue( "MODEL_LE2" , "LE2_VLRRUB", aGravaLE2[nLE2][9] )
                                    oModel:LoadValue( "MODEL_LE2" , "LE2_VLRUNI", aGravaLE2[nLE2][10] )
                                    oModel:LoadValue( "MODEL_LE2" , "LE2_SEQUEN", aGravaLE2[nLE2][11] )
                                    oModel:LoadValue( "MODEL_LE2" , "LE2_RUBRIC", aGravaLE2[nLE2][12] )
                                    oModel:LoadValue( "MODEL_LE2" , "LE2_IDTABR", aGravaLE2[nLE2][13] )


                                    /*------------------------------------------------------------
                                    LE3 - Informações sobre beneficiários de pensão alimentícia
                                    --------------------------------------------------------------*/
                                    nLE3Add := 1
                                    For nLE3 := 1 to Len( aGravaLE3 )
                                        
                                        If  DTOS(aGravaLE3[nLE3][1])+aGravaLE3[nLE3][2]+aGravaLE3[nLE3][3]+aGravaLE3[nLE3][4]+aGravaLE3[nLE3][5]+aGravaLE3[nLE3][6] == ;
                                            DTOS(aGravaLE2[nLE2][1])+aGravaLE2[nLE2][2]+aGravaLE2[nLE2][3]+aGravaLE2[nLE2][4]+aGravaLE2[nLE2][5]+aGravaLE2[nLE2][6]
                                        
                                            oModel:GetModel( "MODEL_LE3" ):LVALID := .T.

                                            If nLE3Add > 1
                                                oModel:GetModel( "MODEL_LE3" ):AddLine()
                                            EndIf

                                            oModel:LoadValue( "MODEL_LE3" , "LE3_CPFBEN", aGravaLE3[nLE3][7] )
                                            oModel:LoadValue( "MODEL_LE3" , "LE3_DTNSBE", aGravaLE3[nLE3][8] )
                                            oModel:LoadValue( "MODEL_LE3" , "LE3_NMBEN",  aGravaLE3[nLE3][9] )
                                            oModel:LoadValue( "MODEL_LE3" , "LE3_VLRPEN", aGravaLE3[nLE3][10] )

                                            nLE3Add++

                                        EndIf

                                    Next//nLE3

                                    nLE2Add++

                                EndIf

                            Next//LE2

                            /*----------------------------------------------------------------------------------
                            LE4 - Composição das bases de cálculo, deduções e isenções do IRRF
                            -----------------------------------------------------------------------------------*/
                            nLE4Add := 1
                            For nLE4 := 1 to Len( aGravaLE4 )

                                If  DTOS(aGravaLE4[nLE4][1])+aGravaLE4[nLE4][2]+aGravaLE4[nLE4][3]+aGravaLE4[nLE4][4]+aGravaLE4[nLE4][5] == DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2]+aGravaT3R[nT3R][3]+aGravaT3R[nT3R][4]+aGravaT3R[nT3R][5]
                                    
                                    oModel:GetModel( "MODEL_LE4" ):LVALID := .T.

                                    If nLE4Add > 1
                                        oModel:GetModel( "MODEL_LE4" ):AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_LE4" , "LE4_IDRUBR", aGravaLE4[nLE4][6] )
                                    oModel:LoadValue( "MODEL_LE4" , "LE4_QTDRUB", aGravaLE4[nLE4][7] )
                                    oModel:LoadValue( "MODEL_LE4" , "LE4_FATRUB", aGravaLE4[nLE4][8] )
                                    oModel:LoadValue( "MODEL_LE4" , "LE4_VLRUNI", aGravaLE4[nLE4][9] )
                                    oModel:LoadValue( "MODEL_LE4" , "LE4_VLRRUB", aGravaLE4[nLE4][10] )
                                    oModel:LoadValue( "MODEL_LE4" , "LE4_RUBRIC", aGravaLE4[nLE4][11] )
                                    oModel:LoadValue( "MODEL_LE4" , "LE4_IDTABR", aGravaLE4[nLE4][12] )

                                    nLE4Add++

                                EndIf

                            Next//nLE4

                            nT3RAdd++

                        EndIf

                    Next //nT3R

                    /*------------------------------------------------------------
                        T6P - Detalhamento dos pagamentos efetuados, apurados em S-1200 ou S-1202/
                    Detalhamento dos pagamentos efetuados relativos a rescisões contratuais
                    --------------------------------------------------------------*/
                    nT6PAdd := 1
                    For nT6P := 1 to Len( aGravaT6P )

                        If  DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                            oModel:GetModel( "MODEL_T6P" ):LVALID := .T.

                            If nT6PAdd > 1
                                oModel:GetModel( "MODEL_T6P" ):AddLine()
                            EndIf

                            oModel:LoadValue( "MODEL_T6P", "T6P_PERREF", aGravaT6P[nT6P][3] )
                            oModel:LoadValue( "MODEL_T6P", "T6P_IDEDMD", aGravaT6P[nT6P][4] )
                            oModel:LoadValue( "MODEL_T6P", "T6P_INDPGT", aGravaT6P[nT6P][5] )
                            oModel:LoadValue( "MODEL_T6P", "T6P_VLRLIQ", aGravaT6P[nT6P][6] )

                            /*------------------------------------------
                            T6Q - Retenções efetuadas (Rubrica)
                            --------------------------------------------*/
                            nT6QAdd := 1
                            For nT6Q := 1 to Len( aGravaT6Q )

                                If  DTOS(aGravaT6Q[nT6Q][1])+aGravaT6Q[nT6Q][2]+aGravaT6Q[nT6Q][3]+aGravaT6Q[nT6Q][4]+aGravaT6Q[nT6Q][5] == DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2]+aGravaT6P[nT6P][3]+aGravaT6P[nT6P][4]+aGravaT6P[nT6P][5]
                                    
                                    oModel:GetModel( "MODEL_T6Q" ):LVALID := .T.

                                    If nT6QAdd > 1
                                        oModel:GetModel( "MODEL_T6Q" ):AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_T6Q" , "T6Q_IDRUBR", aGravaT6Q[nT6Q][6]  )
                                    oModel:LoadValue( "MODEL_T6Q" , "T6Q_QTDRUB", aGravaT6Q[nT6Q][7]  )
                                    oModel:LoadValue( "MODEL_T6Q" , "T6Q_FATRUB", aGravaT6Q[nT6Q][8]  )
                                    oModel:LoadValue( "MODEL_T6Q" , "T6Q_VLRRUB", aGravaT6Q[nT6Q][9]  )
                                    oModel:LoadValue( "MODEL_T6Q" , "T6Q_VLRUNI", aGravaT6Q[nT6Q][10] )
                                    oModel:LoadValue( "MODEL_T6Q" , "T6Q_RUBRIC", aGravaT6Q[nT6Q][11] )
                                    oModel:LoadValue( "MODEL_T6Q" , "T6Q_IDTABR", aGravaT6Q[nT6Q][12] )

                                    nT6QAdd++

                                EndIf

                            Next//T6Q

                            /*------------------------------------------
                            T6R - Composição das bases de cálculo, deduções e isenções do IRRF
                            --------------------------------------------*/
                            nT6RAdd := 1
                            For nT6R := 1 to Len( aGravaT6R )

                                If  DTOS(aGravaT6R[nT6R][1])+aGravaT6R[nT6R][2]+aGravaT6R[nT6R][3]+aGravaT6R[nT6R][4]+aGravaT6R[nT6R][5] == DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2]+aGravaT6P[nT6P][3]+aGravaT6P[nT6P][4]+aGravaT6P[nT6P][5]
                                    
                                    oModel:GetModel( "MODEL_T6R" ):LVALID := .T.

                                    If nT6RAdd > 1
                                        oModel:GetModel( "MODEL_T6R" ):AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_T6R" , "T6R_IDRUBR", aGravaT6R[nT6R][6] )
                                    oModel:LoadValue( "MODEL_T6R" , "T6R_QTDRUB", aGravaT6R[nT6R][7] )
                                    oModel:LoadValue( "MODEL_T6R" , "T6R_FATRUB", aGravaT6R[nT6R][8] )
                                    oModel:LoadValue( "MODEL_T6R" , "T6R_VLRUNI", aGravaT6R[nT6R][9] )
                                    oModel:LoadValue( "MODEL_T6R" , "T6R_VLRRUB", aGravaT6R[nT6R][10] )
                                    oModel:LoadValue( "MODEL_T6R" , "T6R_RUBRIC", aGravaT6R[nT6R][11] )
                                    oModel:LoadValue( "MODEL_T6R" , "T6R_IDTABR", aGravaT6R[nT6R][12] )

                                    nT6RAdd++

                                EndIf

                            Next//nT6R

                            nT6PAdd++

                        EndIf
                        
                    Next //nT6P

                    /*------------------------------------------
                    T5U - Detalhamento dos pagamentos efetuados, apurados em S-1200 ou S-1202/
                    Detalhamento dos pagamentos efetuados relativos a rescisões contratuais
                    --------------------------------------------*/
                    nT5UAdd := 1
                    For nT5U := 1 to Len( aGravaT5U )

                        If  DTOS(aGravaT5U[nT5U][1])+aGravaT5U[nT5U][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                            oModel:GetModel( "MODEL_T5U" ):LVALID := .T.

                            If nT5UAdd > 1
                                oModel:GetModel( "MODEL_T5U" ):AddLine()
                            EndIf

                            oModel:LoadValue( "MODEL_T5U", "T5U_IDCATE", aGravaT5U[nT5U][3] )
                            oModel:LoadValue( "MODEL_T5U", "T5U_DTINIG", aGravaT5U[nT5U][4] )
                            oModel:LoadValue( "MODEL_T5U", "T5U_QTDIAS", aGravaT5U[nT5U][5] )
                            oModel:LoadValue( "MODEL_T5U", "T5U_VLRLIQ", aGravaT5U[nT5U][6] )

                            /*------------------------------------------
                            T5Y - Retenções efetuadas (Rubrica)
                            --------------------------------------------*/
                            nT5YAdd := 1
                            For nT5Y := 1 to Len( aGravaT5Y )

                                If  DTOS(aGravaT5Y[nT5Y][1])+aGravaT5Y[nT5Y][2]+aGravaT5Y[nT5Y][3]+DTOS(aGravaT5Y[nT5Y][4])== DTOS(aGravaT5U[nT5U][1])+aGravaT5U[nT5U][2]+aGravaT5U[nT5U][3]+DTOS(aGravaT5U[nT5U][4])
                                    
                                    oModel:GetModel( "MODEL_T5Y" ):LVALID := .T.

                                    If nT5YAdd > 1
                                        oModel:GetModel( "MODEL_T5Y" ):AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_T5Y" , "T5Y_IDRUBR", aGravaT5Y[nT5Y][5] )
                                    oModel:LoadValue( "MODEL_T5Y" , "T5Y_QTDRUB", aGravaT5Y[nT5Y][6] )
                                    oModel:LoadValue( "MODEL_T5Y" , "T5Y_FATRUB", aGravaT5Y[nT5Y][7] )
                                    oModel:LoadValue( "MODEL_T5Y" , "T5Y_VLRRUB", aGravaT5Y[nT5Y][8] )
                                    oModel:LoadValue( "MODEL_T5Y" , "T5Y_VLRUNI", aGravaT5Y[nT5Y][9] )
                                    oModel:LoadValue( "MODEL_T5Y" , "T5Y_RUBRIC", aGravaT5Y[nT5Y][10] )
                                    oModel:LoadValue( "MODEL_T5Y" , "T5Y_IDTABR", aGravaT5Y[nT5Y][11] )

                                    /*------------------------------------------
                                    T5Z - Informações sobre beneficiários de pensão alimentícia
                                    --------------------------------------------*/
                                    nT5ZAdd := 1
                                    For nT5Z := 1 to Len( aGravaT5Z )
                                        
                                        If  DTOS(aGravaT5Z[nT5Z][1])+aGravaT5Z[nT5Z][2]+aGravaT5Z[nT5Z][3]+DTOS(aGravaT5Z[nT5Z][4])+aGravaT5Z[nT5Z][5] == DTOS(aGravaT5Y[nT5Y][1])+aGravaT5Y[nT5Y][2]+aGravaT5Y[nT5Y][3]+DTOS(aGravaT5Y[nT5Y][4])+aGravaT5Y[nT5Y][5]
                                            
                                            oModel:GetModel( "MODEL_T5Z" ):LVALID := .T.

                                            If nT5ZAdd > 1
                                                oModel:GetModel( "MODEL_T5Z" ):AddLine()
                                            EndIf

                                            oModel:LoadValue( "MODEL_T5Z" , "T5Z_CPFBEN", aGravaT5Z[nT5Z][6] )
                                            oModel:LoadValue( "MODEL_T5Z" , "T5Z_DTNSBE", aGravaT5Z[nT5Z][7] )
                                            oModel:LoadValue( "MODEL_T5Z" , "T5Z_NMBEN",  aGravaT5Z[nT5Z][8] )
                                            oModel:LoadValue( "MODEL_T5Z" , "T5Z_VLRPEN", aGravaT5Z[nT5Z][9] )

                                            nT5ZAdd++

                                        EndIf

                                    Next//T5Z

                                    nT5YAdd++

                                EndIf

                            Next//T5Y

                            nT5UAdd++

                        EndIf

                    Next //T5U

                    /*------------------------------------------
                    T5V - Detalhamento dos pagamentos efetuados, apurados em S-1200 ou S-1202/
                    Detalhamento dos pagamentos efetuados relativos a rescisões contratuais
                    --------------------------------------------*/
                    nT5VAdd := 1
                    For nT5V := 1 to Len( aGravaT5V )

                        If  DTOS(aGravaT5V[nT5V][1])+aGravaT5V[nT5V][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]
                            
                            oModel:GetModel( "MODEL_T5V" ):LVALID := .T.

                            If nT5VAdd > 1
                                oModel:GetModel( "MODEL_T5V" ):AddLine()
                            EndIf

                            oModel:LoadValue( "MODEL_T5V", "T5V_IDCATE", aGravaT5V[nT5V][3] )

                            /*------------------------------------------
                            T5X - Composição das bases de cálculo, deduções e isenções do IRRF
                            --------------------------------------------*/
                            nT5XAdd := 1
                            For nT5X := 1 to Len( aGravaT5X )

                                If  DTOS(aGravaT5X[nT5X][1])+aGravaT5X[nT5X][2]+aGravaT5X[nT5X][3] == DTOS(aGravaT5V[nT5V][1])+aGravaT5V[nT5V][2]+aGravaT5V[nT5V][3]
                                    
                                    oModel:GetModel( "MODEL_T5X" ):LVALID := .T.

                                    If nT5XAdd > 1
                                        oModel:GetModel( "MODEL_T5X" ):AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_T5X" , "T5X_SEQUEN", aGravaT5X[nT5X][4] )
                                    oModel:LoadValue( "MODEL_T5X" , "T5X_IDTPIR", aGravaT5X[nT5X][5] )
                                    oModel:LoadValue( "MODEL_T5X" , "T5X_VLRBCI", aGravaT5X[nT5X][6] )

                                    nT5XAdd++

                                EndIf

                            Next//T5X

                            nT5VAdd++

                        EndIf

                    Next //nT5V

                Next //nT3Q

            Else
                nV6MAdd := 1

                For nV6M := 1 To Len(aGravaV6M)
                    oModel:GetModel("MODEL_V6M"):lValid := .T.

                    If nV6MAdd > 1
                        oModel:GetModel("MODEL_V6M"):AddLine()
                    EndIf

                    oModel:LoadValue("MODEL_V6M", "V6M_DTPGTO", aGravaV6M[nV6M][1])
                    oModel:LoadValue("MODEL_V6M", "V6M_TPPGTO", aGravaV6M[nV6M][2])
                    oModel:LoadValue("MODEL_V6M", "V6M_PERREF", aGravaV6M[nV6M][3])
                    oModel:LoadValue("MODEL_V6M", "V6M_INDDEV", aGravaV6M[nV6M][4])
                    oModel:LoadValue("MODEL_V6M", "V6M_VLRLIQ", aGravaV6M[nV6M][5])

                    If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")
                        oModel:LoadValue("MODEL_V6M", "V6M_PAIEXT", aGravaV6M[nV6M][6])

                        For nV9I := 1 To Len(aGravaV9I)
                            If aGravaV9I[nV9I][1] + aGravaV9I[nV9I][2] + aGravaV9I[nV9I][3] == aGravaV6M[nV6M][2] +;
                                aGravaV6M[nV6M][3] + aGravaV6M[nV6M][4]
                                oModel:GetModel("MODEL_V9I"):lValid := .T.

                                oModel:LoadValue("MODEL_V9I", "V9I_INDNIF", aGravaV9I[nV9I][4])
                                oModel:LoadValue("MODEL_V9I", "V9I_NIFBEN", aGravaV9I[nV9I][5])
                                oModel:LoadValue("MODEL_V9I", "V9I_FRMTRI", aGravaV9I[nV9I][6])
                                
                                For nV9J := 1 To Len(aGravaV9J)
                                    If aGravaV9J[nV9J][1] + aGravaV9J[nV9J][2] + aGravaV9J[nV9J][3] == aGravaV6M[nV6M][2] +;
                                        aGravaV6M[nV6M][3] + aGravaV6M[nV6M][4]
                                        oModel:GetModel("MODEL_V9J"):lValid := .T.
                                       
                                        oModel:LoadValue("MODEL_V9J", "V9J_DSCLOG", aGravaV9J[nV9J][4])
                                        oModel:LoadValue("MODEL_V9J", "V9J_NRLOGR", aGravaV9J[nV9J][5])
                                        oModel:LoadValue("MODEL_V9J", "V9J_COMPLE", aGravaV9J[nV9J][6])
                                        oModel:LoadValue("MODEL_V9J", "V9J_BAIRRO", aGravaV9J[nV9J][7])
                                        oModel:LoadValue("MODEL_V9J", "V9J_CIDADE", aGravaV9J[nV9J][8])
                                        oModel:LoadValue("MODEL_V9J", "V9J_ESTADO", aGravaV9J[nV9J][9])
                                        oModel:LoadValue("MODEL_V9J", "V9J_CODPOS", aGravaV9J[nV9J][10])
                                        oModel:LoadValue("MODEL_V9J", "V9J_TELEF" , aGravaV9J[nV9J][11])
                                    EndIf
                                Next
                            EndIf
                        Next
                    EndIf

                    nV6MAdd++
                Next
            EndIf

            //Busco a nova versao do registro
            cVersao := xFunGetVer()

            /*---------------------------------------------------------
            ATENCAO -> A alteracao destes campos deve sempre estar
            abaixo do Loop do For, pois devem substituir as informacoes
            que foram armazenadas no Loop acima
            -----------------------------------------------------------*/
            oModel:LoadValue( "MODEL_T3P", "T3P_VERSAO", cVersao )
            oModel:LoadValue( "MODEL_T3P", "T3P_VERANT", cVerAnt )
            oModel:LoadValue( "MODEL_T3P", "T3P_PROTPN", cProtocolo )
            oModel:LoadValue( "MODEL_T3P", "T3P_PROTUL", "" )

            /*---------------------------------------------------------
            Tratamento para que caso o Evento Anterior fosse de exclusão
            seta-se o novo evento como uma "nova inclusão", caso contrário o
            evento passar a ser uma alteração
            -----------------------------------------------------------*/
            oModel:LoadValue( "MODEL_T3P", "T3P_EVENTO", "E" )
            oModel:LoadValue( "MODEL_T3P", "T3P_ATIVO", "1" )

            FwFormCommit( oModel )
            TAFAltStat( 'T3P',"6" )
        End Transaction
    EndIf

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF407VlRu
REGRA_RUBRICA_COMPATIVEL_CATEGORIA
1) Se for relativa a segurado empregado ou avulso não é permitida a inclusão de registro cujo {codRubr} classificada na tabela de Rubricas com {codIncCP} seja igual a [34,35];
2) Se for relativa a contribuinte individual [701,711,712,721,722,723,731,734,738,741,751,761,771,781], não podem ser utilizados códigos de rubrica cujos
   {codIncCP} e {codIncIRRF} da tabela de Rubricas correspondente seja específica de segurados empregados. Portanto, não são aceitas rubricas cujo:
   2a) {codIncCP} classificado como: [12, 21, 22, 32, 51, 92, 93, 94], exceto se categoria de trabalhador = [771];
   2b) {codIncIRRF} classificado como: [12,13,32,33,42,43,47,52,53,62,63,64,71,92,93], exceto se categoria de trabalhador = [771];
   2c) {codIncCP} seja igual a [34,35] se a categoria do respectivo trabalhador for diferente de [711,712,734];
   2d) {codIncCP} classificado como [31] se {classTrib} do contribuinte for igual a [21,22] (Pessoa Física) e {codCateg} = Contribuinte individual (7XX)
   2e) {codIncIRRF} classificado como: [14,34,54,94], exceto se categoria de trabalhador = [721,722,723,731,734,738,761,771];
3) Se for relativa ao estagiário, não podem ser aceitas rubricas cujo {codIncCP} seja diferente de [00, 01] ou {codIncFGTS} seja diferente de [00].
@author  Ricardo Prandi
@since   21/08/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function TAF407VlRu(cCodRubr,cCodCat,cCodClaFis,nRecno,cCampoLog,aLogErro)

	Local cIdCintps  := ""
	Local cCodCintps := ""
	Local cCodIRRF   := ""

	cIdCintps  := Posicione("C8R",5,xFilial("C8R") + cCodRubr + "1","C8R_CINTPS")
	cCodCintps := Posicione("C8T",1,xFilial("C8T") + C8R->C8R_CINTPS,"C8T_CODIGO")
	cCodIRRF   := Posicione("C8U",1,xFilial("C8U") + C8R->C8R_CINTIR,"C8U_CODIGO")

	If "|"+AllTrim(cCodCat)+"|" $ "|201|202|" .And. "|"+AllTrim(cCodCintps)+"|" $ "|34|35|"
		aAdd( aLogErro, { cCampoLog, "001157", "T3P", nRecno } ) //"Para rúbricas com o código de incidência tributária {codIncCP} igual a 34 ou 35, não é permitido a utilização para trabalhador beneficiário com categoria Avulsa ou segurado empregado (códigos 201 ou 202)"
	EndIf

	If "|"+AllTrim(cCodCat)+"|" $ "|701|711|712|721|722|723|731|734|738|741|751|761|771|781|"
		
        If cCodCat <> "771" .And. "|"+AllTrim(cCodCintps)+"|" $ "|12|21|22|32|51|92|93|94|"
			aAdd( aLogErro, { cCampoLog, "001158", "T3P", nRecno } ) //"Para rúbricas com o código de incidência tributária {codIncCP} igual a 12, 21, 22, 32, 51, 92, 93 ou 94, não é permitido a utilização da mesma para trabalhador contribuinte individual com código de categoria igual a 701,711,721,722,723,731,734,738,741,751,761 ou 781"
		EndIf

		If cCodCat <> "771" .And. "|"+AllTrim(cCodIRRF)+"|" $ "|12|13|32|33|42|43|47|52|53|62|63|64|71|92|93|"
			aAdd( aLogErro, { cCampoLog, "001159", "T3P", nRecno } ) //"Para rúbricas com o código de incidência tributária para IRRF {codIncIRRF} igual a 12,13,32,33,42,43,47,52,53,62,63,64,71,92 ou 93, não é permitido a utilização da mesma para trabalhador contribuinte individual com código de categoria igual a 701,711,721,722,723,731,734,738,741,751,761 ou 781"
		EndIf

		If cCodCat <> "711" .And. cCodCat <> "712" .And. cCodCat <> "734" .And. "|"+AllTrim(cCodCintps)+"|" $ "|34|35|"
			aAdd( aLogErro, { cCampoLog, "001160", "T3P", nRecno } ) //"Para rúbricas com o código de incidência tributária {codIncCP} igual a 34 ou 35, não é permitido a utilização da mesma para trabalhador contribuinte individual com código de categoria igual a 701,721,722,723,731,738,741,751,761,771 ou 781"
		EndIf

		If !( cCodCat $ "721|722|723|731|734|738|761|771" ) .and. AllTrim( cCodIRRF ) $ "14|34|54|94"
			aAdd( aLogErro, { cCampoLog, "001168", "T3P", nRecno } ) //"Para rúbricas com o código de incidência tributária para IRRF {codIncIRRF} igual a 14,34,54 ou 94, não é permitido a utilização da mesma para trabalhador contribuinte individual com código de categoria igual a 701, 711, 712, 741, 751 ou 781."
		EndIf

	EndIf

	If "|"+AllTrim(cCodCat)+"|" $ "|701|702|703|704|711|712|713|721|722|723|731|732|733|734|735|736|738|741|751|761|771|781|" .And. cCodCintps == "31" .And. "|"+AllTrim(cCodClaFis)+"|" $ "|21|22|"
		aAdd( aLogErro, { cCampoLog, "001161", "T3P", nRecno } ) //"Para rúbricas com o código de incidência tributária para Previdência Social {codIncCP} igual a 31 e estabelicimento com classificação fiscal igual a 21 ou 22, não é permitido a utilização da mesma para trabalhador contribuinte individual (7XX)"
	EndIf

	If cCodCat == "901" .And. ((cCodCintps <> "00" .And. cCodCintps <> "01") .Or. C8R->C8R_CINTIR <> "00")
		aAdd( aLogErro, { cCampoLog, "001162", "T3P", nRecno } ) //"Para trabalhador com categoria igual à estagiário, não podem ser aceitas rubricas cujo {codIncCP} seja diferente de 00 e 01 ou {codIncFGTS} seja diferente de [00]"
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF407View
Monta a View dinâmica
@author  Diego R. Santos
@since   30/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Function TAF407View( cAlias, nRecno )

	Local oNewView	:= ViewDef()
	Local aArea 	:= GetArea()
	Local oExecView	:= Nil

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( 1 )
	oExecView:setTitle( STR0001 )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return 1 

//-------------------------------------------------------------------
/*/{Protheus.doc} RetPrtUl
Retorna o protocolo da ultima transmissão do ID Correto 

@author Hermiro Júnior
@since 14/02/2019
@version 1.0

@Param: 
	Mod. Pagamento			-> (2=S2200 | 3= S2300)
	Cpf do Beneficiario 	-> (T3P->T3P_CPF)
	Data do Pagamento 	-> (T3Q_DTPGTO)
	Ident. Demonstrativo	-> (T3R_IDEDMD)	

@Return
	Ult. Protocolo Trans.-> (CMD_PROTUL)	
/*/
//-------------------------------------------------------------------
Static Function RetPrtUl(cModPag, cCpfBen, dDtPag, cIdeDmd)

	Local cPrtTran	:= ""
	Local cQryPrt	:= ""
	Local cAliasQry	:= GetNextAlias()
	Local lMv		:= Empty(T3P->T3P_BENEFI)

    // ________________________________________________________________________
    //| Posiciona no Desligamento  - SOLUÇÃO DE ID's Diferentes de Func com o  |
    //| mesmo CPF.                                                             |
    //|________________________________________________________________________|

    If cModPag	== '2'

        cQryPrt	:= " SELECT														"+CRLF
        cQryPrt	+= " T06.T06_ID,  												"+CRLF
        cQryPrt	+= " T06.T06_IDEDMD,  											"+CRLF
        cQryPrt	+= " CMD.CMD_ID,  												"+CRLF
        cQryPrt	+= " CMD.CMD_FUNC,  											"+CRLF
        cQryPrt	+= " CMD.CMD_PROTUL  											"+CRLF
        cQryPrt	+= " FROM "+RetSqlName("T06")+" T06  							"+CRLF
        cQryPrt	+= "	INNER JOIN "+RetSqlName("CMD")+" CMD  ON 				"+CRLF
        cQryPrt	+= "		CMD.CMD_FILIAL = T06.T06_FILIAL AND 				"+CRLF
        cQryPrt	+= "		CMD.CMD_ID	=  T06.T06_ID AND 						"+CRLF
        cQryPrt	+= "		CMD.CMD_VERSAO = T06.T06_VERSAO AND 				"+CRLF
        cQryPrt	+= "		CMD.CMD_ATIVO  = '1'	AND 			            "+CRLF
        cQryPrt	+= "		CMD.CMD_STATUS = '4'	AND 			            "+CRLF
        cQryPrt	+= "		CMD.D_E_L_E_T_ = ' '								"+CRLF
        cQryPrt	+= "	INNER JOIN "+RetSqlName("C9V")+" C9V  ON 				"+CRLF
        cQryPrt	+= "		C9V.C9V_FILIAL = T06.T06_FILIAL AND					"+CRLF
        cQryPrt	+= "		C9V.C9V_ID = CMD.CMD_FUNC AND 						"+CRLF
        cQryPrt	+= "		C9V.C9V_CPF = '"+cCpfBen+"' AND 					"+CRLF
        cQryPrt	+= "		C9V.C9V_NOMEVE = 'S2200' AND 						"+CRLF
        cQryPrt	+= "		C9V.D_E_L_E_T_ = ' '								"+CRLF
        cQryPrt	+= " WHERE 														"+CRLF

        If ! lMv
            cQryPrt	+= "	T06.T06_FILIAL = '"+xFilial("T06")+"'  AND 			"+CRLF
        EndIf
        cQryPrt	+= "	T06.T06_IDEDMD = '"+cIdeDmd+"' AND 						"+CRLF
        cQryPrt	+= "	T06.D_E_L_E_T_ = ' ' 										"+CRLF

    ElseIf cModPag	== '3'

        cQryPrt	:= " SELECT																"+CRLF
        cQryPrt	+= " T3I.T3I_ID,  													"+CRLF
        cQryPrt	+= " T3I.T3I_IDEDMD,  												"+CRLF
        cQryPrt	+= " T92.T92_ID,  													"+CRLF
        cQryPrt	+= " T92.T92_TRABAL,  												"+CRLF
        cQryPrt	+= " T92.T92_PROTUL  												"+CRLF
        cQryPrt	+= " FROM "+RetSqlName("T3I")+" T3I 								"+CRLF
        cQryPrt	+= "	INNER JOIN "+RetSqlName("T92")+" T92  ON 				"+CRLF
        cQryPrt	+= "		T92.T92_FILIAL = T3I.T3I_FILIAL AND 				"+CRLF
        cQryPrt	+= "		T92.T92_ID	=  T3I.T3I_ID AND 						"+CRLF
        cQryPrt	+= "		T92.T92_VERSAO = T3I.T3I_VERSAO AND					"+CRLF
        cQryPrt	+= "		T92.T92_ATIVO   = '1'	AND 			            "+CRLF
        cQryPrt	+= "		T92.T92_STATUS  = '4'	AND 			            "+CRLF
        cQryPrt	+= "		T92.D_E_L_E_T_ = ' '								"+CRLF
        cQryPrt	+= "	INNER JOIN "+RetSqlName("C9V")+" C9V  ON 				"+CRLF
        cQryPrt	+= "		C9V.C9V_FILIAL = 	T92.T92_FILIAL AND				"+CRLF
        cQryPrt	+= "		C9V.C9V_ID = T92.T92_TRABAL AND 					"+CRLF
        cQryPrt	+= "		C9V.C9V_CPF = '"+cCpfBen+"' AND 					"+CRLF
        cQryPrt	+= "		C9V.C9V_NOMEVE = 'S2300' AND 						"+CRLF
        cQryPrt	+= "		C9V.D_E_L_E_T_ = ' '								"+CRLF
        cQryPrt	+= "WHERE 														"+CRLF
        If !lMv
            cQryPrt	+= "	T3I.T3I_FILIAL = '"+xFilial("T3I")+"'  AND 			    "+CRLF
        EndIf
        cQryPrt	+= "	T3I.T3I_IDEDMD = '"+cIdeDmd+"' AND					 	"+CRLF
        cQryPrt	+= "	T3I.D_E_L_E_T_ = ' ' 									"+CRLF

    EndIf

    cQryPrt := ChangeQuery(cQryPrt)

    TCQuery cQryPrt New Alias (cAliasQry)

    If !(cAliasQry)->(Eof())

        If cModPag	    == '2'
            cPrtTran := (cAliasQry)->CMD_PROTUL
        ElseIf cModPag	== '3'
            cPrtTran := (cAliasQry)->T92_PROTUL
        EndIf

    EndIf

    (cAliasQry)->(DbCloseArea())

Return cPrtTran

//--------------------------------------------------------------------
/*/{Protheus.doc} SetCssButton

Cria objeto TButton utilizando CSS

@author Eduardo Sukeda
@since 22/03/2019
@version 1.0

@param cTamFonte - Tamanho da Fonte
@param cFontColor - Cor da Fonte
@param cBackColor - Cor de Fundo do Botão
@param cBorderColor - Cor da Borda

@return cCss
/*/
//--------------------------------------------------------------------
Static Function SetCssButton(cTamFonte,cFontColor,cBackColor,cBorderColor)

	Local cCSS := ""

	cCSS := "QPushButton{ background-color: " + cBackColor + "; "
	cCSS += "border: none; "
	cCSS += "font: bold; "
	cCSS += "color: " + cFontColor + ";"
	cCSS += "padding: 2px 5px;"
	cCSS += "text-align: center; "
	cCSS += "text-decoration: none; "
	cCSS += "display: inline-block; "
	cCSS += "font-size: " + cTamFonte + "px; "
	cCSS += "border: 1px solid " + cBorderColor + "; "
	cCSS += "border-radius: 3px "
	cCSS += "}"

Return cCSS

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF407Inc
Monta a View dinâmica
@author  Eduardo Sukeda
@since   29/05/2019
@version 1
/*/
//-------------------------------------------------------------------
Function TAF407Inc( cAlias, nRecno )

	Local oNewView	:= ViewDef()
	Local aArea 	:= GetArea()
	Local oExecView	:= Nil

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( 3 )
	oExecView:setTitle( STR0001 )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return 3

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF407AUTI
Monta a View dinâmica
@author  Ricardo Lovrenovic
@since   27/01/2020
@version 1
/*/
//-------------------------------------------------------------------
Function TAF407AUTI( cAlias, nRecno )

	Local oNewView	:= ViewDef()
	Local aArea 	:= GetArea()
	Local oExecView	:= Nil

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( 3 )
	oExecView:setTitle( STR0001 )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return 3

//-------------------------------------------------------------------
/*/{Protheus.doc} XT3PValid
Rotina p/ executar os valids presentes no dicionário de dados em virtude
do campo X3_VALID não possuir caracteres suficientes
@author  Alexandre/SILAS
@since   31-08-2020
@version 1.0
/*/
//-------------------------------------------------------------------

Function XT3PValid( cCampo )

	Local lRet := .T.

	If !lLaySimplif

		If AllTrim(cCampo) == "T3P_BENEFI"
			lRet := XFUNVldCmp("C9V",,,, 1,,, .T.) .AND. XFUNVldUni("T3P", 2, FwFldGet("T3P_INDAPU") + FwFldGet("T3P_PERAPU") + M->T3P_BENEFI + '1')
		ElseIf AllTrim(cCampo) == "T3P_CPF"
			lRet := XFUNVldUni("T3P", 6, FwFldGet("T3P_INDAPU")+FwFldGet("T3P_PERAPU")+M->T3P_CPF+'1')
		EndIF
	
    Else

		If AllTrim(cCampo) == "T3P_BENEFI" .And. TafColumnPos("T3P_ORIEVE") .And. T3P->T3P_ORIEVE == 'S2400'
			V73->( DbSetOrder( 4 ) )
			lRet := V73->( DBSeek(xFilial("V73")+ M->T3P_BENEFI + "1"))
		ElseIf AllTrim(cCampo) == "T3P_BENEFI"
			lRet := XFUNVldUni("T3P", 7, FwFldGet("T3P_PERAPU") + FwFldGet("T3P_TPGUIA") + M->T3P_BENEFI + '1')
		ElseIf AllTrim(cCampo) == "T3P_CPF"
			lRet := XFUNVldUni("T3P", 8, FwFldGet("T3P_PERAPU") + FwFldGet("T3P_TPGUIA") + M->T3P_CPF + '1')
		EndIF

	EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} TafCrrMdl

Carrega o modelo com os registro para aglutinar no novo cenário

@author Bruno Rosa
@since 28/08/2020
@version 1.0

@param oMdlNvCen, caracter, Modelo que contem os registros
@param oModel   , caracter, Modelo que receberá os dados
@param cIDT3P   , caracter, ID do T3P - Pgto Rendimentos do Trabalho  
@param cVersT3P , caracter, Versão do T3P - Pgto Rendimentos do Trabalho  

/*/
//--------------------------------------------------------------------
Static Function TafCrrMdl(oMdlNvCen as object, oModel as object, cIDT3P as character, cVersT3P as character)

	Local aGravaT3Q     as array
	Local aGravaT3R     as array
	Local aGravaLE2     as array
	Local aGravaLE3     as array
	Local aGravaLE4     as array
	Local aGravaT6P     as array
	Local aGravaT6Q     as array
	Local aGravaT6R     as array
	Local aGravaT5U     as array
	Local aGravaT5Y     as array
	Local aGravaT5Z     as array
	Local aGravaT5V     as array
	Local aGravaT5X     as array
	Local aGravaV6M     as array
    Local aGravaV9I     as array
    Local aGravaV9J     as array
	Local nT3Q 		    as numeric
	Local nT3R  	    as numeric
	Local nLE2  	    as numeric
	Local nLE3  	    as numeric
	Local nLE4  	    as numeric
	Local nT6P  	    as numeric
	Local nT6Q  	    as numeric
	Local nT6R  	    as numeric
	Local nT5U  	    as numeric
	Local nT5Y 	 	    as numeric
	Local nT5Z  	    as numeric
	Local nT5V  	    as numeric
	Local nT5X		    as numeric
	Local nV6M 		    as numeric
    Local nV9I          as numeric
    Local nV9J          as numeric
	Local nT3RAdd 	    as numeric
	Local nLE2Add 	    as numeric
	Local nLE3Add 	    as numeric
	Local nLE4Add 	    as numeric
	Local nT6PAdd 	    as numeric
	Local nT6QAdd 	    as numeric
	Local nT6RAdd 	    as numeric
	Local nT5UAdd 	    as numeric
	Local nT5YAdd 	    as numeric
	Local nT5ZAdd 	    as numeric
	Local nT5VAdd 	    as numeric
	Local nT5XAdd 	    as numeric
    Local nV6MAdd       as numeric
    Local oModelT3Q     as object
    Local oModelT3R     as object
    Local oModelLE2     as object
    Local oModelLE3     as object
    Local oModelLE4     as object
    Local oModelT6P     as object
    Local oModelT6Q     as object
    Local oModelT6R     as object
    Local oModelT5U     as object
    Local oModelT5Y     as object
    Local oModelT5Z     as object
    Local oModelT5V     as object
    Local oModelT5X     as object
    Local oModelV6M     as object
    Local oModelV9I     as object
    Local oModelV9J     as object

    Default cIDT3P      := ""
    Default cVersT3P    := ""
    Default oModel      := Nil
    Default oMdlNvCen   := Nil

	aGravaT3Q   := {}
	aGravaT3R   := {}
	aGravaLE2   := {}
	aGravaLE3   := {}
	aGravaLE4   := {}
	aGravaT6P   := {}
	aGravaT6Q   := {}
	aGravaT6R   := {}
	aGravaT5U   := {}
	aGravaT5Y   := {}
	aGravaT5Z   := {}
	aGravaT5V   := {}
	aGravaT5X   := {}
	aGravaV6M   := {}
    aGravaV9I   := {}
    aGravaV9J   := {}
	nT3Q        := 0
	nT3R  	    := 0
	nLE2  	    := 0
	nLE3  	    := 0
	nLE4  	    := 0
	nT6P  	    := 0
	nT6Q  	    := 0
	nT6R  	    := 0
	nT5U  	    := 0
	nT5Y 	 	:= 0
	nT5Z  	    := 0
	nT5V  	    := 0
	nT5X		:= 0
	nV6M 		:= 0
    nV9I        := 0
    nV9J        := 0
	nT3RAdd 	:= 0
	nLE2Add 	:= 0
	nLE3Add 	:= 0
	nLE4Add 	:= 0
	nT6PAdd 	:= 0
	nT6QAdd 	:= 0
	nT6RAdd 	:= 0
	nT5UAdd 	:= 0
	nT5YAdd 	:= 0
	nT5ZAdd 	:= 0
	nT5VAdd 	:= 0
	nT5XAdd 	:= 0
    nV6MAdd     := 0
    oModelT3Q   := Nil
    oModelT3R   := Nil
    oModelLE2   := Nil
    oModelLE3   := Nil
    oModelLE4   := Nil
    oModelT6P   := Nil
    oModelT6Q   := Nil
    oModelT6R   := Nil
    oModelT5U   := Nil
    oModelT5Y   := Nil
    oModelT5Z   := Nil
    oModelT5V   := Nil
    oModelT5X   := Nil
    oModelV6M   := Nil
    oModelV9I   := Nil
    oModelV9J   := Nil

    If oModel != Nil .And. oMdlNvCen != Nil
        If !lLaySimplif

            oModelT3Q := oMdlNvCen:GetModel( 'MODEL_T3Q' )
            oModelT3R := oMdlNvCen:GetModel( 'MODEL_T3R' )
            oModelLE2 := oMdlNvCen:GetModel( 'MODEL_LE2' )
            oModelLE3 := oMdlNvCen:GetModel( 'MODEL_LE3' )
            oModelLE4 := oMdlNvCen:GetModel( 'MODEL_LE4' )
            oModelT6P := oMdlNvCen:GetModel( 'MODEL_T6P' )
            oModelT6Q := oMdlNvCen:GetModel( 'MODEL_T6Q' )
            oModelT6R := oMdlNvCen:GetModel( 'MODEL_T6R' )
            oModelT5U := oMdlNvCen:GetModel( 'MODEL_T5U' )
            oModelT5Y := oMdlNvCen:GetModel( 'MODEL_T5Y' )
            oModelT5Z := oMdlNvCen:GetModel( 'MODEL_T5Z' )
            oModelT5V := oMdlNvCen:GetModel( 'MODEL_T5V' )
            oModelT5X := oMdlNvCen:GetModel( 'MODEL_T5X' )

            /*T3Q - Informações de Pagamentos Efetuados*/
            For nT3Q := 1 To oModelT3Q:Length()

                oModelT3Q:GoLine(nT3Q)

                If !oModelT3Q:IsDeleted()

                    aAdd(aGravaT3Q, { oModelT3Q:GetValue('T3Q_DTPGTO'),;
                                        oModelT3Q:GetValue('T3Q_TPPGTO'),;
                                        oModelT3Q:GetValue('T3Q_INDRES'),;
                                        oModelT3Q:GetValue('T3Q_IDPAIS'),;
                                        oModelT3Q:GetValue('T3Q_INDNIF'),;
                                        oModelT3Q:GetValue('T3Q_NIFBEN'),;
                                        oModelT3Q:GetValue('T3Q_DLOUGR'),;
                                        oModelT3Q:GetValue('T3Q_NUMLOG'),;
                                        oModelT3Q:GetValue('T3Q_COMPLE'),;
                                        oModelT3Q:GetValue('T3Q_BAIRRO'),;
                                        oModelT3Q:GetValue('T3Q_CIDADE'),;
                                        oModelT3Q:GetValue('T3Q_CEP') })

                    /*T3R - Info. de Pgto Efetuados*/
                    For nT3R := 1 to oModelT3R:Length()

                        oModelT3R:GoLine(nT3R)

                        If !oModelT3R:IsEmpty()

                            If !oModelT3R:IsDeleted()

                                aAdd(aGravaT3R ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                    oModelT3R:GetValue('T3R_PERREF'),;
                                                    oModelT3R:GetValue('T3R_IDEDMD'),;
                                                    oModelT3R:GetValue('T3R_INDPGT'),;
                                                    oModelT3R:GetValue('T3R_VLRLIQ')})

                                /*LE2 - Retenções Pagamento do Vlr Tot*/
                                For nLE2 := 1 to oModelLE2:Length()

                                    oModelLE2:GoLine(nLE2)

                                    If !oModelLE2:IsEmpty()

                                        If !oModelLE2:IsDeleted()

                                            aAdd(aGravaLE2 ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                oModelT3R:GetValue('T3R_PERREF'),;
                                                                oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                oModelT3R:GetValue('T3R_INDPGT'),;
                                                                oModelLE2:GetValue('LE2_IDRUBR'),;
                                                                oModelLE2:GetValue('LE2_QTDRUB'),;
                                                                oModelLE2:GetValue('LE2_FATRUB'),;
                                                                oModelLE2:GetValue('LE2_VLRRUB'),;
                                                                oModelLE2:GetValue('LE2_VLRUNI'),;
                                                                oModelLE2:GetValue('LE2_SEQUEN'),;
                                                                oModelLE2:GetValue('LE2_RUBRIC'),;
                                                                oModelLE2:GetValue('LE2_IDTABR')})

                                            /*LE3 - Pensão Alimentícia*/
                                            For nLE3 := 1 to oModelLE3:Length()

                                                oModelLE3:GoLine(nLE3)

                                                If !oModelLE3:IsEmpty()

                                                    If !oModelLE3:IsDeleted()

                                                        aAdd(aGravaLE3 ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                            oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                            oModelT3R:GetValue('T3R_PERREF'),;
                                                                            oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                            oModelT3R:GetValue('T3R_INDPGT'),;
                                                                            oModelLE2:GetValue('LE2_IDRUBR'),;
                                                                            oModelLE3:GetValue('LE3_CPFBEN'),;
                                                                            oModelLE3:GetValue('LE3_DTNSBE'),;
                                                                            oModelLE3:GetValue('LE3_NMBEN'),;
                                                                            oModelLE3:GetValue('LE3_VLRPEN'),;
                                                                            oModelLE2:GetValue('LE2_SEQUEN'),;
                                                                            oModelLE2:GetValue('LE2_RUBRIC') })

                                                    EndIf

                                                EndIf

                                            Next nLE3

                                        EndIf

                                    EndIf

                                Next nLE2

                                /*LE4 - Inf Comp Relac ao Pgto Efetuad*/
                                For nLE4 := 1 to oModelLE4:Length()

                                    oModelLE4:GoLine(nLE4)

                                    If !oModelLE4:IsEmpty()

                                        If !oModelLE4:IsDeleted()

                                            aAdd(aGravaLE4 ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                oModelT3R:GetValue('T3R_PERREF'),;
                                                                oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                oModelT3R:GetValue('T3R_INDPGT'),;
                                                                oModelLE4:GetValue('LE4_IDRUBR'),;
                                                                oModelLE4:GetValue('LE4_QTDRUB'),;
                                                                oModelLE4:GetValue('LE4_FATRUB'),;
                                                                oModelLE4:GetValue('LE4_VLRRUB'),;
                                                                oModelLE4:GetValue('LE4_VLRUNI'),;
                                                                oModelLE4:GetValue('LE4_RUBRIC'),;
                                                                oModelLE4:GetValue('LE4_IDTABR'),;
                                                                oModelLE4:GetValue('LE4_MATRIC')})
                                        EndIf
                                        
                                    EndIf

                                Next nLE4

                            EndIf

                        EndIf

                    Next nT3R

                    /*T6P - Detalh. Pgto Folha e Rescisão*/
                    For nT6P := 1 to oModelT6P:Length()

                        oModelT6P:GoLine(nT6P)

                        If !oModelT6P:IsEmpty()

                            If !oModelT6P:IsDeleted()

                                aAdd(aGravaT6P ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                    oModelT6P:GetValue('T6P_PERREF'),;
                                                    oModelT6P:GetValue('T6P_IDEDMD'),;
                                                    oModelT6P:GetValue('T6P_INDPGT'),;
                                                    oModelT6P:GetValue('T6P_VLRLIQ')})

                                /*T6Q - Retenções Pagamento do Vlr Tot*/
                                For nT6Q := 1 to oModelT6Q:Length()

                                    oModelT6Q:GoLine(nT6Q)

                                    If !oModelT6Q:IsEmpty()

                                        If !oModelT6Q:IsDeleted()

                                            aAdd(aGravaT6Q ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                oModelT6P:GetValue('T6P_PERREF'),;
                                                                oModelT6P:GetValue('T6P_IDEDMD'),;
                                                                oModelT6P:GetValue('T6P_INDPGT'),;
                                                                oModelT6Q:GetValue('T6Q_IDRUBR'),;
                                                                oModelT6Q:GetValue('T6Q_QTDRUB'),;
                                                                oModelT6Q:GetValue('T6Q_FATRUB'),;
                                                                oModelT6Q:GetValue('T6Q_VLRRUB'),;
                                                                oModelT6Q:GetValue('T6Q_VLRUNI'),;
                                                                oModelT6Q:GetValue('T6Q_RUBRIC'),;
                                                                oModelT6Q:GetValue('T6Q_IDTABR')})

                                        EndIf

                                    EndIf

                                Next nT6Q

                                /*T6R - Inf Comp Relac ao Pgto Efetuad*/
                                For nT6R := 1 to oModelT6R:Length()

                                    oModelT6R:GoLine(nT6R)

                                    If !oModelT6R:IsEmpty()

                                        If !oModelT6R:IsDeleted()

                                            aAdd(aGravaT6R ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                oModelT6P:GetValue('T6P_PERREF'),;
                                                                oModelT6P:GetValue('T6P_IDEDMD'),;
                                                                oModelT6P:GetValue('T6P_INDPGT'),;
                                                                oModelT6R:GetValue('T6R_IDRUBR'),;
                                                                oModelT6R:GetValue('T6R_QTDRUB'),;
                                                                oModelT6R:GetValue('T6R_FATRUB'),;
                                                                oModelT6R:GetValue('T6R_VLRRUB'),;
                                                                oModelT6R:GetValue('T6R_VLRUNI'),;
                                                                oModelT6R:GetValue('T6R_RUBRIC'),;
                                                                oModelT6R:GetValue('T6R_IDTABR')})
                                        EndIf

                                    EndIf

                                Next nT6R

                            EndIf

                        EndIf

                    Next nT6P

                    /*T5U - Detalhamento Rub Recibo Férias*/
                    For nT5U := 1 to oModelT5U:Length()

                        oModelT5U:GoLine(nT5U)

                        If !oModelT5U:IsEmpty()

                            If !oModelT5U:IsDeleted()

                                aAdd(aGravaT5U ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                    oModelT5U:GetValue('T5U_IDCATE'),;
                                                    oModelT5U:GetValue('T5U_DTINIG'),;
                                                    oModelT5U:GetValue('T5U_QTDIAS'),;
                                                    oModelT5U:GetValue('T5U_VLRLIQ'),;
                                                    oModelT5U:GetValue('T5U_MATRIC')})

                                /*T5Y - Det Rub Rebibo Ant de Ferias*/
                                For nT5Y := 1 to oModelT5Y:Length()

                                    oModelT5Y:GoLine(nT5Y)

                                    If !oModelT5Y:IsEmpty()

                                        If !oModelT5Y:IsDeleted()

                                            aAdd(aGravaT5Y ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                oModelT5U:GetValue('T5U_IDCATE'),;
                                                                oModelT5U:GetValue('T5U_DTINIG'),;
                                                                oModelT5Y:GetValue('T5Y_IDRUBR'),;
                                                                oModelT5Y:GetValue('T5Y_QTDRUB'),;
                                                                oModelT5Y:GetValue('T5Y_FATRUB'),;
                                                                oModelT5Y:GetValue('T5Y_VLRRUB'),;
                                                                oModelT5Y:GetValue('T5Y_VLRUNI'),;
                                                                oModelT5Y:GetValue('T5Y_RUBRIC'),;
                                                                oModelT5Y:GetValue('T5Y_IDTABR')})

                                            /*T5Z - Beneficiários de Pensão Alimen*/
                                            For nT5Z := 1 to oModelT5Z:Length()

                                                oModelT5Z:GoLine(nT5Z)

                                                If !oModelT5Z:IsEmpty()

                                                    If !oModelT5Z:IsDeleted()

                                                        aAdd(aGravaT5Z ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                            oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                            oModelT5U:GetValue('T5U_IDCATE'),;
                                                                            oModelT5U:GetValue('T5U_DTINIG'),;
                                                                            oModelT5Y:GetValue('T5Y_IDRUBR'),;
                                                                            oModelT5Z:GetValue('T5Z_CPFBEN'),;
                                                                            oModelT5Z:GetValue('T5Z_DTNSBE'),;
                                                                            oModelT5Z:GetValue('T5Z_NMBEN'),;
                                                                            oModelT5Z:GetValue('T5Z_VLRPEN')})
                                                    EndIf

                                                EndIf

                                            Next nT5Z

                                        EndIf

                                    EndIf

                                Next nT5Y

                            EndIf

                        EndIf

                    Next nT5U

                    /*T5V - Pgto Relat Compet Anteriores*/
                    For nT5V := 1 to oModelT5V:Length()

                        oModelT5V:GoLine(nT5V)

                        If !oModelT5V:IsEmpty()

                            If !oModelT5V:IsDeleted()

                                aAdd(aGravaT5V ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                    oModelT5V:GetValue('T5V_IDCATE')})

                                /*T5X - Detalhamento do pagamento*/
                                For nT5X := 1 to oModelT5X:Length()

                                    oModelT5X:GoLine(nT5X)

                                    If !oModelT5X:IsEmpty()

                                        If !oModelT5X:IsDeleted()

                                            aAdd(aGravaT5X ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                oModelT5V:GetValue('T5V_IDCATE'),;
                                                                oModelT5X:GetValue('T5X_SEQUEN'),;
                                                                oModelT5X:GetValue('T5X_IDTPIR'),;
                                                                oModelT5X:GetValue('T5X_VLRBCI')})

                                        EndIf

                                    EndIf

                                Next nT5X

                            EndIf

                        EndIf

                    Next nT5V

                EndIf

            Next nT3Q

            //Gravação no modelo original para segunda
            /*T3Q - Informações de Pagamentos Efetuados*/
            For nT3Q := 1 to Len(aGravaT3Q)

                oModel:GetModel('MODEL_T3Q'):LVALID := .T.

                If nT3Q > 1
                    oModel:GetModel("MODEL_T3Q"):AddLine()
                EndIf

                oModel:LoadValue( "MODEL_T3Q", "T3Q_DTPGTO" , aGravaT3Q[nT3Q][1] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_TPPGTO" , aGravaT3Q[nT3Q][2] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_INDRES",  aGravaT3Q[nT3Q][3] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_IDPAIS",  aGravaT3Q[nT3Q][4] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_INDNIF",  aGravaT3Q[nT3Q][5] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_NIFBEN",  aGravaT3Q[nT3Q][6] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_DLOUGR",  aGravaT3Q[nT3Q][7] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_NUMLOG",  aGravaT3Q[nT3Q][8] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_COMPLE",  aGravaT3Q[nT3Q][9] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_BAIRRO",  aGravaT3Q[nT3Q][10] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_CIDADE",  aGravaT3Q[nT3Q][11] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_CEP"   ,  aGravaT3Q[nT3Q][12] )

                /*T3R - Info. de Pgto Efetuados*/
                nT3RAdd := 1
                For nT3R := 1 to Len(aGravaT3R)

                    If  DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                        oModel:GetModel("MODEL_T3R"):LVALID := .T.

                        If nT3RAdd > 1
                            oModel:GetModel("MODEL_T3R"):AddLine()
                        EndIf

                        oModel:LoadValue( "MODEL_T3R", "T3R_PERREF", aGravaT3R[nT3R][3] )
                        oModel:LoadValue( "MODEL_T3R", "T3R_IDEDMD", aGravaT3R[nT3R][4] )
                        oModel:LoadValue( "MODEL_T3R", "T3R_INDPGT", aGravaT3R[nT3R][5] )
                        oModel:LoadValue( "MODEL_T3R", "T3R_VLRLIQ", aGravaT3R[nT3R][6] )

                        /*LE2 - Retenções Pagamento do Vlr Tot*/
                        nLE2Add := 1
                        For nLE2 := 1 to Len(aGravaLE2)

                            If  DTOS(aGravaLE2[nLE2][1])+aGravaLE2[nLE2][2]+aGravaLE2[nLE2][3]+aGravaLE2[nLE2][4]+aGravaLE2[nLE2][5] == DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2]+aGravaT3R[nT3R][3]+aGravaT3R[nT3R][4]+aGravaT3R[nT3R][5]

                                oModel:GetModel("MODEL_LE2"):LVALID := .T.

                                If nLE2Add > 1
                                    oModel:GetModel("MODEL_LE2"):AddLine()
                                EndIf

                                oModel:LoadValue( "MODEL_LE2" , "LE2_IDRUBR", aGravaLE2[nLE2][6] )
                                oModel:LoadValue( "MODEL_LE2" , "LE2_QTDRUB", aGravaLE2[nLE2][7] )
                                oModel:LoadValue( "MODEL_LE2" , "LE2_FATRUB", aGravaLE2[nLE2][8] )
                                oModel:LoadValue( "MODEL_LE2" , "LE2_VLRRUB", aGravaLE2[nLE2][9] )
                                oModel:LoadValue( "MODEL_LE2" , "LE2_VLRUNI", aGravaLE2[nLE2][10] )
                                oModel:LoadValue( "MODEL_LE2" , "LE2_SEQUEN", aGravaLE2[nLE2][11] )
                                oModel:LoadValue( "MODEL_LE2" , "LE2_RUBRIC", aGravaLE2[nLE2][12] )
                                oModel:LoadValue( "MODEL_LE2" , "LE2_IDTABR", aGravaLE2[nLE2][13] )

                                /*LE3 -  */
                                nLE3Add := 1
                                For nLE3 := 1 to Len(aGravaLE3)

                                    If  DTOS(aGravaLE3[nLE3][1])+aGravaLE3[nLE3][2]+aGravaLE3[nLE3][3]+aGravaLE3[nLE3][4]+aGravaLE3[nLE3][5]+aGravaLE3[nLE3][6] == DTOS(aGravaLE2[nLE2][1])+aGravaLE2[nLE2][2]+aGravaLE2[nLE2][3]+aGravaLE2[nLE2][4]+aGravaLE2[nLE2][5]+aGravaLE2[nLE2][6]

                                        oModel:GetModel("MODEL_LE3"):LVALID := .T.

                                        If nLE3Add > 1
                                            oModel:GetModel("MODEL_LE3"):AddLine()
                                        EndIf

                                        oModel:LoadValue( "MODEL_LE3" , "LE3_CPFBEN", aGravaLE3[nLE3][7] )
                                        oModel:LoadValue( "MODEL_LE3" , "LE3_DTNSBE", aGravaLE3[nLE3][8] )
                                        oModel:LoadValue( "MODEL_LE3" , "LE3_NMBEN",  aGravaLE3[nLE3][9] )
                                        oModel:LoadValue( "MODEL_LE3" , "LE3_VLRPEN", aGravaLE3[nLE3][10] )

                                        nLE3Add++

                                    EndIf

                                Next nLE3

                                nLE2Add++

                            EndIf

                        Next nLE2

                        /*LE4 - */
                        nLE4Add := 1
                        For nLE4 := 1 to Len(aGravaLE4)

                            If  DTOS(aGravaLE4[nLE4][1])+aGravaLE4[nLE4][2]+aGravaLE4[nLE4][3]+aGravaLE4[nLE4][4]+aGravaLE4[nLE4][5] == DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2]+aGravaT3R[nT3R][3]+aGravaT3R[nT3R][4]+aGravaT3R[nT3R][5]

                                oModel:GetModel("MODEL_LE4"):LVALID := .T.

                                If nLE4Add > 1
                                    oModel:GetModel("MODEL_LE4"):AddLine()
                                EndIf

                                oModel:LoadValue( "MODEL_LE4" , "LE4_IDRUBR", aGravaLE4[nLE4][6] )
                                oModel:LoadValue( "MODEL_LE4" , "LE4_QTDRUB", aGravaLE4[nLE4][7] )
                                oModel:LoadValue( "MODEL_LE4" , "LE4_FATRUB", aGravaLE4[nLE4][8] )
                                oModel:LoadValue( "MODEL_LE4" , "LE4_VLRUNI", aGravaLE4[nLE4][9] )
                                oModel:LoadValue( "MODEL_LE4" , "LE4_VLRRUB", aGravaLE4[nLE4][10] )
                                oModel:LoadValue( "MODEL_LE4" , "LE4_RUBRIC", aGravaLE4[nLE4][11] )
                                oModel:LoadValue( "MODEL_LE4" , "LE4_IDTABR", aGravaLE4[nLE4][12] )

                                nLE4Add++

                            EndIf

                        Next nLE4

                        nT3RAdd++

                    EndIf

                Next nT3R

                /*T6P -  */
                nT6PAdd := 1
                For nT6P := 1 to Len(aGravaT6P)

                    If  DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                        oModel:GetModel("MODEL_T6P"):LVALID := .T.

                        If nT6PAdd > 1
                            oModel:GetModel("MODEL_T6P"):AddLine()
                        EndIf

                        oModel:LoadValue( "MODEL_T6P", "T6P_PERREF", aGravaT6P[nT6P][3] )
                        oModel:LoadValue( "MODEL_T6P", "T6P_IDEDMD", aGravaT6P[nT6P][4] )
                        oModel:LoadValue( "MODEL_T6P", "T6P_INDPGT", aGravaT6P[nT6P][5] )
                        oModel:LoadValue( "MODEL_T6P", "T6P_VLRLIQ", aGravaT6P[nT6P][6] )

                        /*T6Q -  */
                        nT6QAdd := 1
                        For nT6Q := 1 to Len(aGravaT6Q)

                            If  DTOS(aGravaT6Q[nT6Q][1])+aGravaT6Q[nT6Q][2]+aGravaT6Q[nT6Q][3]+aGravaT6Q[nT6Q][4]+aGravaT6Q[nT6Q][5] == DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2]+aGravaT6P[nT6P][3]+aGravaT6P[nT6P][4]+aGravaT6P[nT6P][5]

                                oModel:GetModel("MODEL_T6Q"):LVALID := .T.

                                If nT6QAdd > 1
                                    oModel:GetModel("MODEL_T6Q"):AddLine()
                                EndIf

                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_IDRUBR", aGravaT6Q[nT6Q][6]  )
                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_QTDRUB", aGravaT6Q[nT6Q][7]  )
                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_FATRUB", aGravaT6Q[nT6Q][8]  )
                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_VLRRUB", aGravaT6Q[nT6Q][9]  )
                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_VLRUNI", aGravaT6Q[nT6Q][10] )
                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_RUBRIC", aGravaT6Q[nT6Q][11] )
                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_IDTABR", aGravaT6Q[nT6Q][12] )

                                nT6QAdd++

                            EndIf

                        Next nT6Q

                        /*T6R -  */
                        nT6RAdd := 1
                        For nT6R := 1 to Len(aGravaT6R)

                            If  DTOS(aGravaT6R[nT6R][1])+aGravaT6R[nT6R][2]+aGravaT6R[nT6R][3]+aGravaT6R[nT6R][4]+aGravaT6R[nT6R][5] == DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2]+aGravaT6P[nT6P][3]+aGravaT6P[nT6P][4]+aGravaT6P[nT6P][5]

                                oModel:GetModel("MODEL_T6R"):LVALID := .T.

                                If nT6RAdd > 1
                                    oModel:GetModel("MODEL_T6R"):AddLine()
                                EndIf

                                oModel:LoadValue( "MODEL_T6R" , "T6R_IDRUBR", aGravaT6R[nT6R][6] )
                                oModel:LoadValue( "MODEL_T6R" , "T6R_QTDRUB", aGravaT6R[nT6R][7] )
                                oModel:LoadValue( "MODEL_T6R" , "T6R_FATRUB", aGravaT6R[nT6R][8] )
                                oModel:LoadValue( "MODEL_T6R" , "T6R_VLRUNI", aGravaT6R[nT6R][9] )
                                oModel:LoadValue( "MODEL_T6R" , "T6R_VLRRUB", aGravaT6R[nT6R][10] )
                                oModel:LoadValue( "MODEL_T6R" , "T6R_RUBRIC", aGravaT6R[nT6R][11] )
                                oModel:LoadValue( "MODEL_T6R" , "T6R_IDTABR", aGravaT6R[nT6R][12] )

                                nT6RAdd++

                            EndIf

                        Next nT6R

                        nT6PAdd++

                    EndIf

                Next nT6P

                /*T5U -  */
                nT5UAdd := 1
                For nT5U := 1 to Len(aGravaT5U)

                    If  DTOS(aGravaT5U[nT5U][1])+aGravaT5U[nT5U][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                        oModel:GetModel( "MODEL_T5U" ):LVALID := .T.

                        If nT5UAdd > 1
                            oModel:GetModel( "MODEL_T5U" ):AddLine()
                        EndIf

                        oModel:LoadValue( "MODEL_T5U", "T5U_IDCATE", aGravaT5U[nT5U][3] )
                        oModel:LoadValue( "MODEL_T5U", "T5U_DTINIG", aGravaT5U[nT5U][4] )
                        oModel:LoadValue( "MODEL_T5U", "T5U_QTDIAS", aGravaT5U[nT5U][5] )
                        oModel:LoadValue( "MODEL_T5U", "T5U_VLRLIQ", aGravaT5U[nT5U][6] )

                        /*T5Y -  */
                        nT5YAdd := 1
                        For nT5Y := 1 to Len(aGravaT5Y)

                            If  DTOS(aGravaT5Y[nT5Y][1])+aGravaT5Y[nT5Y][2]+aGravaT5Y[nT5Y][3]+DTOS(aGravaT5Y[nT5Y][4])== DTOS(aGravaT5U[nT5U][1])+aGravaT5U[nT5U][2]+aGravaT5U[nT5U][3]+DTOS(aGravaT5U[nT5U][4])

                                oModel:GetModel("MODEL_T5Y"):LVALID := .T.

                                If nT5YAdd > 1
                                    oModel:GetModel("MODEL_T5Y"):AddLine()
                                EndIf

                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_IDRUBR", aGravaT5Y[nT5Y][5] )
                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_QTDRUB", aGravaT5Y[nT5Y][6] )
                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_FATRUB", aGravaT5Y[nT5Y][7] )
                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_VLRRUB", aGravaT5Y[nT5Y][8] )
                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_VLRUNI", aGravaT5Y[nT5Y][9] )
                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_RUBRIC", aGravaT5Y[nT5Y][10] )
                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_IDTABR", aGravaT5Y[nT5Y][11] )

                                /*T5Z -  */
                                nT5ZAdd := 1
                                For nT5Z := 1 to Len(aGravaT5Z)

                                    If  DTOS(aGravaT5Z[nT5Z][1])+aGravaT5Z[nT5Z][2]+aGravaT5Z[nT5Z][3]+DTOS(aGravaT5Z[nT5Z][4])+aGravaT5Z[nT5Z][5] == DTOS(aGravaT5Y[nT5Y][1])+aGravaT5Y[nT5Y][2]+aGravaT5Y[nT5Y][3]+DTOS(aGravaT5Y[nT5Y][4])+aGravaT5Y[nT5Y][5]

                                        oModel:GetModel("MODEL_T5Z"):LVALID := .T.

                                        If nT5ZAdd > 1
                                            oModel:GetModel("MODEL_T5Z"):AddLine()
                                        EndIf

                                        oModel:LoadValue( "MODEL_T5Z" , "T5Z_CPFBEN", aGravaT5Z[nT5Z][6] )
                                        oModel:LoadValue( "MODEL_T5Z" , "T5Z_DTNSBE", aGravaT5Z[nT5Z][7] )
                                        oModel:LoadValue( "MODEL_T5Z" , "T5Z_NMBEN",  aGravaT5Z[nT5Z][8] )
                                        oModel:LoadValue( "MODEL_T5Z" , "T5Z_VLRPEN", aGravaT5Z[nT5Z][9] )

                                        nT5ZAdd++

                                    EndIf

                                Next nT5Z

                                nT5YAdd++

                            EndIf

                        Next nT5Y

                        nT5UAdd++

                    EndIf

                Next nT5U

                /*T5V -  */
                nT5VAdd := 1
                For nT5V := 1 to Len(aGravaT5V)

                    If  DTOS(aGravaT5V[nT5V][1])+aGravaT5V[nT5V][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                        oModel:GetModel("MODEL_T5V"):LVALID := .T.

                        If nT5VAdd > 1
                            oModel:GetModel( "MODEL_T5V" ):AddLine()
                        EndIf

                        oModel:LoadValue( "MODEL_T5V", "T5V_IDCATE", aGravaT5V[nT5V][3] )

                        /*T5X - */
                        nT5XAdd := 1
                        For nT5X := 1 to Len(aGravaT5X)

                            If  DTOS(aGravaT5X[nT5X][1])+aGravaT5X[nT5X][2]+aGravaT5X[nT5X][3] == DTOS(aGravaT5V[nT5V][1])+aGravaT5V[nT5V][2]+aGravaT5V[nT5V][3]

                                oModel:GetModel( "MODEL_T5X" ):LVALID := .T.

                                If nT5XAdd > 1
                                    oModel:GetModel( "MODEL_T5X" ):AddLine()
                                EndIf

                                oModel:LoadValue( "MODEL_T5X" , "T5X_SEQUEN", aGravaT5X[nT5X][4] )
                                oModel:LoadValue( "MODEL_T5X" , "T5X_IDTPIR", aGravaT5X[nT5X][5] )
                                oModel:LoadValue( "MODEL_T5X" , "T5X_VLRBCI", aGravaT5X[nT5X][6] )

                                nT5XAdd++

                            EndIf

                        Next nT5X

                        nT5VAdd++

                    EndIf

                Next nT5V

            Next nT3Q

        Else
            oModelV6M := oMdlNvCen:GetModel("MODEL_V6M")
            oModelV9I := oMdlNvCen:GetModel("MODEL_V9I")
            oModelV9J := oMdlNvCen:GetModel("MODEL_V9J")

            For nV6M := 1 To oModelV6M:Length()
                oModelV6M:GoLine(nV6M)

                If !oModelV6M:IsEmpty()
                    If !oModelV6M:IsDeleted()
                        aAdd(aGravaV6M, {   oModelV6M:GetValue("V6M_DTPGTO"),;
                                            oModelV6M:GetValue("V6M_TPPGTO"),;
                                            oModelV6M:GetValue("V6M_PERREF"),;
                                            oModelV6M:GetValue("V6M_INDDEV"),;
                                            oModelV6M:GetValue("V6M_VLRLIQ")    })

                        If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")
                            AAdd(aGravaV6M[nV6M], oModelV6M:GetValue("V6M_PAIEXT"))

                            For nV9I := 1 To oModelV9I:Length()
                                oModelV9I:GoLine(nV9I)

                                If !oModelV9I:IsEmpty()
                                    If !oModelV9I:IsDeleted()
                                        AAdd(aGravaV9I, {   oModelV6M:GetValue("V6M_TPPGTO"),;
                                                            oModelV6M:GetValue("V6M_PERREF"),;
                                                            oModelV6M:GetValue("V6M_INDDEV"),;                                   
                                                            oModelV9I:GetValue("V9I_INDNIF"),;
                                                            oModelV9I:GetValue("V9I_NIFBEN"),;
                                                            oModelV9I:GetValue("V9I_FRMTRI")    })
                                        
                                        For nV9J := 1 To oModelV9J:Length()
                                            oModelV9J:GoLine(nV9J)

                                            If !oModelV9J:IsEmpty()
                                                If !oModelV9J:IsDeleted()
                                                    AAdd(aGravaV9J, {   oModelV6M:GetValue("V6M_TPPGTO"),;
                                                                        oModelV6M:GetValue("V6M_PERREF"),;
                                                                        oModelV6M:GetValue("V6M_INDDEV"),;  
                                                                        oModelV9J:GetValue("V9J_DSCLOG"),;
                                                                        oModelV9J:GetValue("V9J_NRLOGR"),;
                                                                        oModelV9J:GetValue("V9J_COMPLE"),;
                                                                        oModelV9J:GetValue("V9J_BAIRRO"),;
                                                                        oModelV9J:GetValue("V9J_CIDADE"),;
                                                                        oModelV9J:GetValue("V9J_ESTADO"),;
                                                                        oModelV9J:GetValue("V9J_CODPOS"),;
                                                                        oModelV9J:GetValue("V9J_TELEF" )    })
                                                EndIf
                                            EndIf
                                        Next
                                    EndIf
                                EndIf
                            Next
                        EndIf
                    EndIf
                EndIf
            Next

            nV6MAdd := 1

            For nV6M := 1 To Len(aGravaV6M)
                oModel:GetModel("MODEL_V6M"):lValid := .T.

                If nV6MAdd > 1
                    oModel:GetModel("MODEL_V6M"):AddLine()
                EndIf

                oModel:LoadValue("MODEL_V6M", "V6M_DTPGTO", aGravaV6M[nV6M][1])
                oModel:LoadValue("MODEL_V6M", "V6M_TPPGTO", aGravaV6M[nV6M][2])
                oModel:LoadValue("MODEL_V6M", "V6M_PERREF", aGravaV6M[nV6M][3])
                oModel:LoadValue("MODEL_V6M", "V6M_INDDEV", aGravaV6M[nV6M][4])
                oModel:LoadValue("MODEL_V6M", "V6M_VLRLIQ", aGravaV6M[nV6M][5])

                If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")
                    oModel:LoadValue("MODEL_V6M", "V6M_PAIEXT", aGravaV6M[nV6M][6])
                    
                    For nV9I := 1 To Len(aGravaV9I)
                        If aGravaV9I[nV9I][1] + aGravaV9I[nV9I][2] + aGravaV9I[nV9I][3] == aGravaV6M[nV6M][2] +;
                            aGravaV6M[nV6M][3] + aGravaV6M[nV6M][4]
                            oModel:GetModel("MODEL_V9I"):lValid := .T.
                                                      
                            oModel:LoadValue("MODEL_V9I", "V9I_INDNIF", aGravaV9I[nV9I][4])
                            oModel:LoadValue("MODEL_V9I", "V9I_NIFBEN", aGravaV9I[nV9I][5])
                            oModel:LoadValue("MODEL_V9I", "V9I_FRMTRI", aGravaV9I[nV9I][6])

                            For nV9J := 1 To Len(aGravaV9J)
                                If aGravaV9J[nV9J][1] + aGravaV9J[nV9J][2] + aGravaV9J[nV9J][3] == aGravaV6M[nV6M][2] +;
                                    aGravaV6M[nV6M][3] + aGravaV6M[nV6M][4]
                                    oModel:GetModel("MODEL_V9J"):lValid := .T.
                                        
                                    oModel:LoadValue("MODEL_V9J", "V9J_DSCLOG", aGravaV9J[nV9J][4])
                                    oModel:LoadValue("MODEL_V9J", "V9J_NRLOGR", aGravaV9J[nV9J][5])
                                    oModel:LoadValue("MODEL_V9J", "V9J_COMPLE", aGravaV9J[nV9J][6])
                                    oModel:LoadValue("MODEL_V9J", "V9J_BAIRRO", aGravaV9J[nV9J][7])
                                    oModel:LoadValue("MODEL_V9J", "V9J_CIDADE", aGravaV9J[nV9J][8])
                                    oModel:LoadValue("MODEL_V9J", "V9J_ESTADO", aGravaV9J[nV9J][9])
                                    oModel:LoadValue("MODEL_V9J", "V9J_CODPOS", aGravaV9J[nV9J][10])
                                    oModel:LoadValue("MODEL_V9J", "V9J_TELEF" , aGravaV9J[nV9J][11])
                                EndIf
                            Next
                        EndIf
                    Next
                EndIf

                nV6MAdd++
            Next
        EndIf
    EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF407Trigger
Criação da trigger
@author  Rodrigo Nicolino
@since   04/05/2021
@version 1
/*/
//-------------------------------------------------------------------
Static Function TAF407Trigger()

	Local aAux := FwStruTrigger("T3P_BENEFI",;                                                  // Campo Dominio
                                "T3P_CPF",;                                                     // Campo de Contradominio
                                "TafGetCPF(T3P->T3P_FILIAL,M->T3P_BENEFI,,'T3P')",; 			// Regra de Preenchimento
                                .F.,;                                                           // Se posicionara ou nao antes da execucao do gatilhos
                                "",;                                                            // Alias da tabela a ser posicionada
                                0 ,;                                                            // Ordem da tabela a ser posicionada
                                "",;                                                            // Chave de busca da tabela a ser posicionada
                                "!Empty(M->T3P_BENEFI)",;                                       // Condicao para execucao do gatilho
                                "001" )                                                         // Sequencia do gatilho (usado para identificacao no caso de erro)

Return aAux
