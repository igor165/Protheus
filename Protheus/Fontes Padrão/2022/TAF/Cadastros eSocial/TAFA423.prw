#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA423.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF	Chr( 13 ) + Chr( 10 )

#DEFINE ANALITICO_MATRICULA				1
#DEFINE ANALITICO_CATEGORIA				2
#DEFINE ANALITICO_TIPO_ESTABELECIMENTO	3
#DEFINE ANALITICO_ESTABELECIMENTO		4
#DEFINE ANALITICO_LOTACAO				5
#DEFINE ANALITICO_NATUREZA				6
#DEFINE ANALITICO_TIPO_RUBRICA			7
#DEFINE ANALITICO_INCIDENCIA_CP			8
#DEFINE ANALITICO_INCIDENCIA_IRRF		9
#DEFINE ANALITICO_INCIDENCIA_FGTS		10
#DEFINE ANALITICO_DECIMO_TERCEIRO		11
#DEFINE ANALITICO_TIPO_VALOR			12
#DEFINE ANALITICO_VALOR					13

Static oReport		:=	Nil
Static __lGrvRPT	:=	Nil
Static __nTamGrpCpy :=  NIl
Static lLaySimplif	:= TafLayESoc("S_01_00_00")

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA423
@description Informações das contribuições sociais por trabalhador - S-5001

@author Daniel Schmidt
@since 29/05/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA423()

	Local aSize			:= FWGetDialogSize()
	Local oDialog		:= Nil
	Local oLayer		:= Nil
	Local oPanel01		:= Nil
	Local oPanel02		:= Nil
	Local oBtFil		:= Nil
	Local nTop			:= 0
	Local nHeight		:= 0
	Local nWidth		:= 0

	Local lFreeze		:= .T.
	Local bFiltro		:= {|| FilCpfNome(oBrw, "T2M", "S-5001", 1, 'T2M_PERAPU') }
	Local bExcReg		:= {|| TAFVExcEsocial('T2M'), oBrw:Refresh(.T.) }
	Local bGerXml		:= {|| TAF423Xml(), oBrw:Refresh(.T.) }
	Local bAjuRec		:= {|| xFunAltRec( 'T2M' ), oBrw:Refresh(.T.)}

	Local bXmlLote		:= {|| TAFXmlLote( 'T2M', 'S-5001' , 'evtBasesTrab' , 'TAF423Xml', ,oBrw ), oBrw:Refresh(.T.) }

	Local bClose		:= {|| oDialog:End() }

	Private oBrw := FwMBrowse():New()

	If TafAtualizado()
		If FindFunction("FilCpfNome") .And. GetSx3Cache("T2M_NOMEV","X3_CONTEXT") == "V"

				/*----------------------------
				Construção do Painel Principal
				----------------------------*/

				oDialog := MsDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0001,,,,,,,,, .T.,,,, .F. )

				oLayer := FWLayer():New()

				oLayer:Init( oDialog, .F. )

				oLayer:AddLine( "LINE01", 100 )

				oLayer:AddCollumn( "BOX01",88,, "LINE01" )
				oLayer:AddCollumn( "BOX02",12,, "LINE01" )

				oLayer:AddWindow( "BOX01", "PANEL01", STR0001, 100, .F.,,, "LINE01" )
				oLayer:AddWindow( "BOX02", "PANEL02", "Outras Ações"            , 100, .F.,,, "LINE01" )

				oPanel01 := oLayer:GetWinPanel( "BOX01", "PANEL01", "LINE01" )
				oPanel02 := oLayer:GetWinPanel( "BOX02", "PANEL02", "LINE01" )

				/*----------------------------------------------------------------
				Construção do Painel 01 - Browse do Cadastro de Reintegração
				----------------------------------------------------------------*/

				// Função que indica se o ambiente é válido para o eSocial 2.4
				oBrw:SetDescription(STR0001) 
				oBrw:SetAlias("T2M")
				oBrw:SetMenuDef("TAFA423")
				oBrw:SetOwner( oPanel01 )
				oBrw:SetIniWindow(DbSetOrder(2))
				//oBrw:DisableReport()

				If FindFunction('TAFSetFilter')
					oBrw:SetFilterDefault(TAFBrwSetFilter("T2M","TAFA423","S-5001"))
				Else
					oBrw:SetFilterDefault( "T2M_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos (1 = Ativo, 2 = Inativo)
				EndIf
				
				TafLegend(2,"T2M",@oBrw)

				/*------------------------------------
				Construção do Painel 02 - Outras Ações
				------------------------------------*/

				nWidth := ( oPanel02:nClientWidth / 2 ) - 3
				nHeight := Int( ( oPanel02:nClientHeight / 2 ) / 10 ) - 5

				nTop := 5
				oBtFil := TButton():New( 005, 002, "Filtro CPF/Nome", oPanel02, bFiltro, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )
				oBtFil:SetCSS(SetCssButton("11","#FFFFFF","#1DA2C3","#1DA2C3"))

				nTop += nHeight + 5
				TButton():New( nTop, 002, "Gerar Xml e-Social"  , oPanel02, bGerXml , nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

				nTop += nHeight + 5
				TButton():New( nTop, 002, "Gerar XML em Lote"   , oPanel02, bXmlLote, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

				nTop += nHeight + 5
				TButton():New( nTop, 002, "Ajuste de Recibo"    , oPanel02, bAjuRec , nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

				nTop += nHeight + 5
				TButton():New( nTop, 002, "Excluir Registro"    , oPanel02, bExcReg , nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

				nTop += nHeight + 5
				TButton():New( nTop, 002, "Fechar"              , oPanel02, bClose  , nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

				/*-------------------
				Ativação da Interface
				-------------------*/

				oBrw:Activate()
				oDialog:Activate()


		Else

				//Função que indica se o ambiente é válido para o eSocial 2.3
				oBrw:SetDescription(STR0001)  //"Informações das contribuições sociais por trabalhador"
				oBrw:SetAlias( 'T2M')
				oBrw:SetMenuDef( 'TAFA423' )

				If FindFunction('TAFSetFilter')
					oBrw:SetFilterDefault(TAFBrwSetFilter("T2M","TAFA423","S-5001"))
				Else
					oBrw:SetFilterDefault( "T2M_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
				EndIf

				oBrw:AddLegend( "T2M_EVENTO == 'I' ", "GREEN"  , STR0025 ) //"Registro Incluído"
				oBrw:AddLegend( "T2M_EVENTO == 'A' ", "YELLOW" , STR0026 ) //"Registro Alterado"
				oBrw:AddLegend( "T2M_EVENTO == 'E' ", "RED"    , STR0027 ) //"Registro Excluído"

				oBrw:Activate()
		EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@description Funcao generica MVC com as opcoes de menu

@author Daniel Schmidt
@since 29/05/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}
Local aFuncao := {}

If FindFunction("FilCpfNome") .And. GetSx3Cache("T2M_NOMEV","X3_CONTEXT") == "V"
	
	ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.TAFA423' OPERATION 2 ACCESS 0 //'Visualizar'
    ADD OPTION aRotina TITLE "Imprimir"	  ACTION 'VIEWDEF.TAFA423'			 OPERATION 8 ACCESS 0 //'Imprimir'

Else
	Aadd( aFuncao, { "" , "TAF423Xml" , "1" } )
	Aadd( aFuncao, { "" , "xFunHisAlt( 'T2M' , 'TAFA423' )" , "3" } )
	Aadd( aFuncao, { "" , "TAFXmlLote( 'T2M', 'S-5001' , 'evtBasesTrab' , 'TAF423Xml' , ,oBrw )" , "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'T2M' )" , "10" } )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA423' OPERATION 2 ACCESS 0 //"Visualizar"
	Else
		aRotina	:=	xFunMnuTAF( "TAFA423" , , aFuncao)

		nPosDel	:=	aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Exibir Histórico de Alterações" } )
		If nPosDel > 0
			aDel( aRotina , nPosDel )
			aSize( aRotina , Len( aRotina ) - 1 )
		EndIf

	EndIf
EndIf

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef

@description Funcao generica MVC do model

@author Daniel Schmidt
@since 29/05/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruT2M := FWFormStruct( 1, 'T2M' )
	Local oStruT2N := FWFormStruct( 1, 'T2N' )
	Local oStruT2O := FWFormStruct( 1, 'T2O' )
	Local oStruT2P := FWFormStruct( 1, 'T2P' )
	Local oStruT2Q := FWFormStruct( 1, 'T2Q' )
	Local oStruT2R := FWFormStruct( 1, 'T2R' )
	Local oStruT2S := FWFormStruct( 1, 'T2S' )
	Local oStruV5J := Nil
	Local oStruV5K := Nil 
	Local oModel   := MPFormModel():New('TAFA423',,,{|oModel| SaveModel(oModel)} )
	Local oStruV6F := Nil
	Local oStruV6G := Nil
	Local oStruV6H := Nil
	Local oStruV6I := Nil

	If TAFColumnPos( "V5J_PERREF" )
		oStruV5J := FWFormStruct( 1, 'V5J' )
		oStruV5K := FWFormStruct( 1, 'V5K' )
	Endif

	If TAFColumnPos( "V6I_TPCON" ) .and. lLaySimplif
		oStruV6F := FWFormStruct( 1, 'V6F' )
		oStruV6G := FWFormStruct( 1, 'V6G' )
		oStruV6H := FWFormStruct( 1, 'V6H' )
		oStruV6I := FWFormStruct( 1, 'V6I' )
	EndIf 

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
	If !TAFNT0421(lLaySimplif) .And. TafColumnPos("T2P_CLATRI")
		oStruT2P:RemoveField("T2P_CLATRI")
		oStruT2P:RemoveField("T2P_DESCLA")
	EndIf
	
	If lVldModel
		oStruT2M:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT2N:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT2O:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT2P:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT2Q:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT2R:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT2S:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		
		If TAFColumnPos( "V5J_PERREF" )
			oStruV5J:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
			oStruV5K:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		EndIf

		If TAFColumnPos( "V6I_TPCON" ) .and. lLaySimplif
			oStruV6F:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
			oStruV6G:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
			oStruV6H:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
			oStruV6I:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		EndIf 

	EndIf

	oModel:AddFields('MODEL_T2M', /*cOwner*/, oStruT2M)

	// PROCESSOS JUDICIAIS DO TRABALHADOR
	oModel:AddGrid("MODEL_T2N","MODEL_T2M",oStruT2N)
	oModel:GetModel("MODEL_T2N"):SetOptional(.T.)
	oModel:GetModel("MODEL_T2N"):SetUniqueLine({"T2N_IDPROC"})
	oModel:GetModel('MODEL_T2N'):SetMaxLine(99)


	If TAFColumnPos( "V6I_TPCON" ) .and. lLaySimplif

		oModel:AddGrid("MODEL_V6F","MODEL_T2M",oStruV6F)
		oModel:GetModel("MODEL_V6F"):SetOptional(.T.)
		oModel:GetModel('MODEL_V6F'):SetMaxLine(1)
		
		oModel:AddGrid("MODEL_V6G","MODEL_T2M",oStruV6G)
		oModel:GetModel("MODEL_V6G"):SetOptional(.T.)
		oModel:GetModel("MODEL_V6G"):SetUniqueLine({"V6G_DIA"})
		oModel:GetModel('MODEL_V6G'):SetMaxLine(31)

		oModel:AddGrid("MODEL_V6H","MODEL_T2M",oStruV6H)
		oModel:GetModel("MODEL_V6H"):SetOptional(.T.)
		oModel:GetModel("MODEL_V6H"):SetUniqueLine({"V6H_CBO","V6H_NATV","V6H_QTDIA"})

	EndIf 

	// CÁLCULO DA CONTRIBUIÇÃO PREV. DO SEGURADO
	oModel:AddGrid("MODEL_T2O","MODEL_T2M",oStruT2O)
	oModel:GetModel("MODEL_T2O"):SetOptional(.T.)
	oModel:GetModel("MODEL_T2O"):SetUniqueLine({"T2O_IDCODR"})
	oModel:GetModel('MODEL_T2O'):SetMaxLine(9)

	// IDENTIFICAÇÃO DO ESTABELECIMENTO
	oModel:AddGrid("MODEL_T2P","MODEL_T2M",oStruT2P)
	oModel:GetModel("MODEL_T2P"):SetOptional(.T.)
	oModel:GetModel("MODEL_T2P"):SetUniqueLine({"T2P_ESTABE","T2P_LOTACA"})

	If !TafLayESoc("02_05_00")
		oModel:GetModel('MODEL_T2P'):SetMaxLine(99)
	EndIf

	// INFORMAÇÕES DA CATEG. DO TRABALHADOR E TIPO DE INCIDÊNCIA
	oModel:AddGrid("MODEL_T2Q","MODEL_T2P",oStruT2Q)
	oModel:GetModel("MODEL_T2Q"):SetOptional(.T.)
	oModel:GetModel("MODEL_T2Q"):SetUniqueLine({"T2Q_MATRIC","T2Q_CODCAT"})
	oModel:GetModel('MODEL_T2Q'):SetMaxLine(10)

	// INFORMAÇÂO DE BASE DE CÁLCULO CONTRIBUIÇÃO SOCIAL
	oModel:AddGrid("MODEL_T2R","MODEL_T2Q",oStruT2R)
	oModel:GetModel("MODEL_T2R"):SetOptional(.T.)
	oModel:GetModel("MODEL_T2R"):SetUniqueLine( {"T2R_INDDEC","T2R_TPVLR"} )
	oModel:GetModel('MODEL_T2R'):SetMaxLine(99)

	// CÁLCULO DAS CONTRIBUIÇÕES SOCIAIS
	oModel:AddGrid("MODEL_T2S","MODEL_T2Q",oStruT2S)
	oModel:GetModel("MODEL_T2S"):SetOptional(.T.)
	oModel:GetModel("MODEL_T2S"):SetUniqueLine({"T2S_IDCODR"})
	oModel:GetModel('MODEL_T2S'):SetMaxLine(2)

	If TAFColumnPos( "V5J_PERREF" )

		//Informações de remuneração por período de referência 
		oModel:AddGrid("MODEL_V5J","MODEL_T2Q",oStruV5J)
		oModel:GetModel("MODEL_V5J"):SetOptional(.T.)
		oModel:GetModel("MODEL_V5J"):SetUniqueLine({"V5J_PERREF"})

		//Detalhamento das informações de remuneração por período de referência 
		oModel:AddGrid("MODEL_V5K","MODEL_V5J",oStruV5K)
		oModel:GetModel("MODEL_V5K"):SetUniqueLine({"V5K_INDDEC","V5K_TPVLR"})
		oModel:GetModel('MODEL_V5K'):SetMaxLine(99)

		If lLaySimplif

			oModel:AddGrid("MODEL_V6I","MODEL_V5J",oStruV6I)
			oModel:GetModel("MODEL_V6I"):SetOptional(.T.)
			oModel:GetModel("MODEL_V6I"):SetUniqueLine({"V6I_DTCON","V6I_TPCON"})

		EndIf

	EndIf

	// RELATIONS
	oModel:SetRelation("MODEL_T2N", {{"T2N_FILIAL","xFilial('T2N')"}, {"T2N_ID","T2M_ID"}, {"T2N_VERSAO","T2M_VERSAO"} },T2N->(IndexKey(1)) )

	If TAFColumnPos( "V6I_TPCON" ) .and. lLaySimplif

		oModel:SetRelation("MODEL_V6F", {{"V6F_FILIAL","xFilial('V6F')"}, {"V6F_ID","T2M_ID"}, {"V6F_VERSAO","T2M_VERSAO"} },V6F->(IndexKey(1)) )
		oModel:SetRelation("MODEL_V6G", {{"V6G_FILIAL","xFilial('V6G')"}, {"V6G_ID","T2M_ID"}, {"V6G_VERSAO","T2M_VERSAO"} },V6G->(IndexKey(1)) )
		oModel:SetRelation("MODEL_V6H", {{"V6H_FILIAL","xFilial('V6H')"}, {"V6H_ID","T2M_ID"}, {"V6H_VERSAO","T2M_VERSAO"} },V6H->(IndexKey(1)) )
		
		oModel:SetRelation("MODEL_V6I", {{"V6I_FILIAL","xFilial('V6I')"}, {"V6I_ID","T2M_ID"}, {"V6I_VERSAO","T2M_VERSAO"},{"V6I_ESTABE","T2P_ESTABE"},{"V6I_LOTACA","T2P_LOTACA"},{"V6I_MATRIC","T2Q_MATRIC"},{"V6I_CODCAT","T2Q_CODCAT"},{"V6I_PERREF","V5J_PERREF"} },V6I->(IndexKey(1)) )

	EndIf 

	oModel:SetRelation("MODEL_T2O", {{"T2O_FILIAL","xFilial('T2O')"}, {"T2O_ID","T2M_ID"}, {"T2O_VERSAO","T2M_VERSAO"} },T2O->(IndexKey(1)) )
	oModel:SetRelation("MODEL_T2P", {{"T2P_FILIAL","xFilial('T2P')"}, {"T2P_ID","T2M_ID"}, {"T2P_VERSAO","T2M_VERSAO"} },T2P->(IndexKey(1)) )

	oModel:SetRelation("MODEL_T2Q", {{"T2Q_FILIAL","xFilial('T2Q')"}, {"T2Q_ID","T2M_ID"}, {"T2Q_VERSAO","T2M_VERSAO"}, {"T2Q_ESTABE","T2P_ESTABE"}, {"T2Q_LOTACA","T2P_LOTACA"}},T2Q->(IndexKey(1)) )

	oModel:SetRelation("MODEL_T2R", {{"T2R_FILIAL","xFilial('T2R')"}, {"T2R_ID","T2M_ID"}, {"T2R_VERSAO","T2M_VERSAO"}, {"T2R_ESTABE","T2P_ESTABE"}, {"T2R_LOTACA","T2P_LOTACA"}, {"T2R_MATRIC","T2Q_MATRIC"},{"T2R_CODCAT","T2Q_CODCAT"} },T2R->(IndexKey(1)) )
	oModel:SetRelation("MODEL_T2S", {{"T2S_FILIAL","xFilial('T2S')"}, {"T2S_ID","T2M_ID"}, {"T2S_VERSAO","T2M_VERSAO"}, {"T2S_ESTABE","T2P_ESTABE"}, {"T2S_LOTACA","T2P_LOTACA"}, {"T2S_MATRIC","T2Q_MATRIC"},{"T2S_CODCAT","T2Q_CODCAT"} },T2S->(IndexKey(1)) )

	If TAFColumnPos( "V5J_PERREF" )
		oModel:SetRelation("MODEL_V5J", {{"V5J_FILIAL","xFilial('V5J')"}, {"V5J_ID","T2M_ID"}, {"V5J_VERSAO","T2M_VERSAO"}, {"V5J_ESTABE","T2P_ESTABE"}, {"V5J_LOTACA","T2P_LOTACA"}, {"V5J_MATRIC","T2Q_MATRIC"},{"V5J_CODCAT","T2Q_CODCAT"} },V5J->(IndexKey(1)) )
		oModel:SetRelation("MODEL_V5K", {{"V5K_FILIAL","xFilial('V5K')"}, {"V5K_ID","T2M_ID"}, {"V5K_VERSAO","T2M_VERSAO"}, {"V5K_ESTABE","T2P_ESTABE"}, {"V5K_LOTACA","T2P_LOTACA"}, {"V5K_MATRIC","T2Q_MATRIC"},{"V5K_CODCAT","T2Q_CODCAT"},{"V5K_PERREF","V5J_PERREF"} },V5K->(IndexKey(1)) )
	EndIf

	oModel:GetModel('MODEL_T2M'):SetPrimaryKey({'T2M_INDAPU', 'T2M_PERAPU', 'T2M_CPFTRB', 'T2M_NRRECI'})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@description Funcao generica MVC do View

@author Daniel Schmidt
@since 29/05/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local cCmpFil	:= ""
	Local oModel	:= FWLoadModel( 'TAFA423' )
	Local oStruT2Ma := Nil
	Local oStruT2Mb := Nil
	Local oStruT2Mc	:= Nil
	Local oStruT2N 	:= Nil
	Local oStruT2O 	:= Nil
	Local oStruT2P 	:= Nil
	Local oStruT2Q 	:= Nil
	Local oStruT2R 	:= Nil
	Local oStruT2S 	:= Nil
	Local oStruV5J 	:= Nil
	Local oStruV5K 	:= Nil
	Local oStruV6F  := Nil
	Local oStruV6G  := Nil
	Local oStruV6H  := Nil
	Local oStruV6I  := Nil
	Local oView		:= FWFormView():New()

	oView:SetModel( oModel )
	oView:SetContinuousForm(.T.)

	// Campos do folder Identificação do Evento
	cCmpFil := 'T2M_ID|T2M_NRRECI|T2M_INDAPU|T2M_PERAPU|'
	oStruT2Ma := FwFormStruct( 2, 'T2M', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	// Campos do folder Trabalhador
	cCmpFil := 'T2M_CPFTRB|'
	oStruT2Mb := FwFormStruct( 2, 'T2M', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	// Campos do folder do número do ultimo protocolo
	cCmpFil := 'T2M_PROTUL|
	oStruT2Mc := FwFormStruct( 2, 'T2M', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
		cCmpFil := "T2N_NPROCJ|T2N_CODSUS|"
	Else
		cCmpFil := "T2N_NPROCR|T2N_CODSUR|"
	Endif
	oStruT2N := FWFormStruct( 2, 'T2N', {|x| !(AllTrim( x ) + "|" $ cCmpFil) } )

	If TAFColumnPos( "V6I_TPCON" ) .and. lLaySimplif

		cCmpFil  := "V6F_TPINSC|V6F_NRINSC|V6F_MATANT|V6F_DTADM|"

		oStruV6F := FWFormStruct( 2, 'V6F', {|x| AllTrim( x ) + "|" $ cCmpFil } )

		cCmpFil  := "V6G_DIA|"

		oStruV6G := FWFormStruct( 2, 'V6G', {|x| AllTrim( x ) + "|" $ cCmpFil } )

		cCmpFil  := "V6H_CBO|V6H_NATV|V6H_QTDIA|"

		oStruV6H := FWFormStruct( 2, 'V6H', {|x| AllTrim( x ) + "|" $ cCmpFil } )

		cCmpFil  := "V6I_DTCON|V6I_TPCON|V6I_DSC|V6I_REMUN|"

		oStruV6I := FWFormStruct( 2, 'V6I', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	EndIf 

	If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
		cCmpFil := "T2O_DCODRE|"
	Else
		cCmpFil := "T2O_DCODRR|"
	Endif
	oStruT2O := FWFormStruct( 2, 'T2O', {|x| !(AllTrim( x ) + "|" $ cCmpFil) } )

	If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
		cCmpFil := "T2P_DESTAB|T2P_DLOTAC|"
	Else
		cCmpFil := "T2P_DESTAR|T2P_DLOTAR|"
	Endif

	If !TAFNT0421(lLaySimplif) .And. TafColumnPos("T2P_CLATRI")
		cCmpFil += "T2P_CLATRI|T2P_DESCLA|
	EndIf

	oStruT2P := FWFormStruct( 2, 'T2P', {|x| !(AllTrim( x ) + "|" $ cCmpFil) } )

	If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
		cCmpFil := "T2Q_DCODCA|"
	Else
		cCmpFil := "T2Q_DCODCR|"
	Endif
	oStruT2Q := FWFormStruct( 2, 'T2Q', {|x| !(AllTrim( x ) + "|" $ cCmpFil) } )

	If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
		cCmpFil := "T2R_DTPVLR|"
	Else
		cCmpFil := "T2R_DTPVRR|"
	Endif
	oStruT2R := FWFormStruct( 2, 'T2R', {|x| !(AllTrim( x ) + "|" $ cCmpFil) } )

	If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
		cCmpFil := "T2S_DCODRE|"
	Else
		cCmpFil := "T2S_DCODRR|"
	Endif
	oStruT2S := FWFormStruct( 2, 'T2S', {|x| !(AllTrim( x ) + "|" $ cCmpFil) } )

	If TAFColumnPos( "V5J_PERREF" )
		//cCmpFil := 'V5J_PERREF|'
		oStruV5J := FWFormStruct( 2, 'V5J', {|x| !(AllTrim( x ) + "|" $ cCmpFil) } )

		//cCmpFil := 'V5K_DTPVRR|V5K_VALOR|'
		oStruV5K := FWFormStruct( 2, 'V5K', {|x| !(AllTrim( x ) + "|" $ cCmpFil) } )
	EndIf

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruT2Mc,"T2M")
	EndIf

	/*--------------------------------------------------------------------------------------------
										Esrutura da View
	---------------------------------------------------------------------------------------------*/
	oView:AddField( 'VIEW_T2Ma', oStruT2Ma, 'MODEL_T2M' )
	oView:EnableTitleView( 'VIEW_T2Ma', STR0017 ) //Identificação do Evento

	oView:AddField( 'VIEW_T2Mb', oStruT2Mb, 'MODEL_T2M' )
	oView:EnableTitleView( 'VIEW_T2Mb', STR0018 ) //Trabalhador

	oView:AddField( 'VIEW_T2Mc', oStruT2Mc, 'MODEL_T2M' )

	If FindFunction("TafNmFolder")
		oView:EnableTitleView( 'VIEW_T2Mc', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"
	Else
		oView:EnableTitleView( 'VIEW_T2Mc', STR0008 ) //Protocolo da última Transmissão
	EndIf

	oView:AddGrid("VIEW_T2N",oStruT2N,"MODEL_T2N")
	oView:EnableTitleView("VIEW_T2N",STR0002) //Processos Judiciais do Trabalhador

	If TAFColumnPos( "V6I_TPCON" ) .and. lLaySimplif

		oView:AddGrid("VIEW_V6F",oStruV6F,"MODEL_V6F")
		oView:EnableTitleView("VIEW_V6F",STR0032) //"Sucessão de vínculo trabalhista" 

		oView:AddGrid("VIEW_V6G",oStruV6G,"MODEL_V6G")
		oView:EnableTitleView("VIEW_V6G",STR0033) //"Dia do mês efetivamente trabalhado pelo empregado com contrato de trabalho intermitente"

		oView:AddGrid("VIEW_V6H",oStruV6H,"MODEL_V6H")
		oView:EnableTitleView("VIEW_V6H",STR0034) //"Informações complementares contratuais do trabalhador"

		oView:AddGrid("VIEW_V6I",oStruV6I,"MODEL_V6I")
		oView:EnableTitleView("VIEW_V6I",STR0035) //"Instrumento ou situação ensejadora da remuneração em períodos anteriores"

	EndIf 

	oView:AddGrid("VIEW_T2O",oStruT2O,"MODEL_T2O")
	oView:EnableTitleView("VIEW_T2O",STR0003) //Cálculo da Contribuição Prev. do Segurado

	oView:AddGrid("VIEW_T2P",oStruT2P,"MODEL_T2P")
	oView:EnableTitleView("VIEW_T2P",STR0004) //Identificação do Estabelecimento

	oView:AddGrid("VIEW_T2Q",oStruT2Q,"MODEL_T2Q")
	oView:EnableTitleView("VIEW_T2Q",STR0019)  //Inf. Categ. do Trab. e Tipos de Incidências

	oView:AddGrid("VIEW_T2R",oStruT2R,"MODEL_T2R")
	oView:EnableTitleView("VIEW_T2R",STR0022)  //Bases de Cálculo, Descontos e Deduções de Contribuição Social

	oView:AddGrid("VIEW_T2S",oStruT2S,"MODEL_T2S")
	oView:EnableTitleView("VIEW_T2S",STR0023) // Cálculo das Contribuições Sociais Devidas a Outras Entidades e Fundos.

	If TAFColumnPos( "V5J_PERREF" )
		oView:AddGrid("VIEW_V5J",oStruV5J,"MODEL_V5J")
		oView:EnableTitleView("VIEW_V5J",STR0028) // Informações de Remuneração por Período de Referência.

		oView:AddGrid("VIEW_V5K",oStruV5K,"MODEL_V5K")
		oView:EnableTitleView("VIEW_V5K",STR0029) // Detalhamento das Informações de Remuneração por Período de Referência.
	EndIf

	/*-----------------------------------------------------------------------------------
									Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )

	oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0009 )   //"Informações da Contribuições Sociais"
	oView:CreateHorizontalBox( 'T2Ma'	,  012,,, 'FOLDER_SUPERIOR', 'ABA01' )

	If FindFunction("TafNmFolder")
		oView:AddSheet('FOLDER_SUPERIOR' ,"ABA02", TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_SUPERIOR','ABA02', STR0010 )   //"Protocolo de Transmissão"
	EndIf

	oView:CreateHorizontalBox( 'PAINEL_PRINCIPAL', 	088,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'T2Mc', 				100,,, 'FOLDER_SUPERIOR', 'ABA02' )

	oView:CreateFolder( 'FOLDER_PRINCIPAL', 'PAINEL_PRINCIPAL' )

	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA01', STR0015 ) //"Identificação do Trabalhador"

	If TAFColumnPos( "V6I_TPCON" ) .and. lLaySimplif

		oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA04', STR0031 ) //"Informações complementares do trabalhador e do contrato"

	EndIf 

	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA02', STR0012 ) //"Inf. Cálculo da Contribuição Prev."
	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA03', STR0024 ) //"Inf. Bases e Valores das Contribuições Sociais"



	oView:CreateHorizontalBox( 'T2Mb'					,  012,,, 'FOLDER_PRINCIPAL', 'ABA01' )
	oView:CreateHorizontalBox( 'T2N'					,  080,,, 'FOLDER_PRINCIPAL', 'ABA01' )

	oView:CreateHorizontalBox( 'T2O'					,  100,,, 'FOLDER_PRINCIPAL', 'ABA02' )

	oView:CreateHorizontalBox( 'T2P'					,  025,,, 'FOLDER_PRINCIPAL', 'ABA03' )
	oView:CreateHorizontalBox( 'T2Q'					,  025,,, 'FOLDER_PRINCIPAL', 'ABA03' )

	If TAFColumnPos( "V6I_TPCON" ) .and. lLaySimplif

		oView:CreateHorizontalBox( 'V6F'					,  25,,, 'FOLDER_PRINCIPAL', 'ABA04' )
		oView:CreateHorizontalBox( 'V6G'					,  25,,, 'FOLDER_PRINCIPAL', 'ABA04' )
		oView:CreateHorizontalBox( 'V6H'					,  50,,, 'FOLDER_PRINCIPAL', 'ABA04' )

	EndIf 

	oView:CreateHorizontalBox( 'PANINEL_INFO_CALC'	,  050,,, 'FOLDER_PRINCIPAL', 'ABA03' )

	oView:CreateFolder( 'FOLDER_INFO_CALC', 'PANINEL_INFO_CALC' )

	oView:AddSheet( 'FOLDER_INFO_CALC', 'ABA01', STR0021 )   //Inf. de Base de Cálculo Contrib. Social
	oView:AddSheet( 'FOLDER_INFO_CALC', 'ABA02', STR0007 )   //Cálculo das Contribuições Sociais


	If TAFColumnPos( "V5J_PERREF" )
		oView:AddSheet( 'FOLDER_INFO_CALC', 'ABA03', STR0030  )   //Informações de remuneração por período de referência. 
	EndIf

	oView:CreateHorizontalBox( 'T2R'	,  100,,, 'FOLDER_INFO_CALC', 'ABA01' )
	oView:CreateHorizontalBox( 'T2S'	,  100,,, 'FOLDER_INFO_CALC', 'ABA02' )

	If TAFColumnPos( "V5J_PERREF" )
		oView:CreateHorizontalBox( 'V5J'	,  25,,,  'FOLDER_INFO_CALC', 'ABA03' )
		oView:CreateHorizontalBox( 'V5K'	,  25,,,  'FOLDER_INFO_CALC', 'ABA03' )
		
		If TAFColumnPos( "V6I_TPCON" ) .and. lLaySimplif

			oView:CreateHorizontalBox( 'V6I'  ,  50,,, 'FOLDER_INFO_CALC', 'ABA03' )

		EndIf 
	EndIf

	oView:SetOwnerView('VIEW_T2Ma'	, 'T2Ma')
	oView:SetOwnerView('VIEW_T2Mb'	, 'T2Mb')
	oView:SetOwnerView('VIEW_T2Mc'	, 'T2Mc')
	oView:SetOwnerView("VIEW_T2N"	, "T2N")
	oView:SetOwnerView("VIEW_T2O"	, "T2O")
	oView:SetOwnerView("VIEW_T2P"	, "T2P")
	oView:SetOwnerView("VIEW_T2S"	, "T2S")
	oView:SetOwnerView("VIEW_T2Q"	, "T2Q")
	oView:SetOwnerView("VIEW_T2R"	, "T2R")

	If TAFColumnPos( "V6I_TPCON" ) .and. lLaySimplif

		oView:SetOwnerView("VIEW_V6F"	, "V6F")
		oView:SetOwnerView("VIEW_V6G"	, "V6G")
		oView:SetOwnerView("VIEW_V6H"	, "V6H")
		oView:SetOwnerView("VIEW_V6I"	, "V6I")

	EndIf 

	If TAFColumnPos( "V5J_PERREF" )
		oView:SetOwnerView("VIEW_V5J"	, "V5J")
		oView:SetOwnerView("VIEW_V5K"	, "V5K")
		oStruV5K:RemoveField('V5K_DTPVLR')
	EndIf

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		xFunRmFStr(@oStruT2Ma, 'T2M')
		xFunRmFStr(@oStruT2Mb, 'T2M')
		xFunRmFStr(@oStruT2Mc, 'T2M')
		oStruT2N:RemoveField('T2N_IDSUSP')
	EndIf

Return oView
///-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
@description Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@author Daniel Schmidt
@since 29/05/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation 	:= oModel:GetOperation()
Local lRetorno		:= .T.
Local cLogOpeAnt	:= ""

//Relatório de Conferência de Valores
Local oInfoRPT	:=	Nil
Local lInfoRPT	:=	.F.

Begin Transaction

	If nOperation == MODEL_OPERATION_INSERT
		oModel:LoadValue( 'MODEL_T2M', 'T2M_VERSAO', xFunGetVer() )

		If Findfunction("TAFAltMan")
			TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T2M', 'T2M_LOGOPE' , '2', '' )
		Endif

		FwFormCommit( oModel )

	ElseIf nOperation == MODEL_OPERATION_UPDATE

		If TafColumnPos( "T2M_LOGOPE" )
			cLogOpeAnt := T2M->T2M_LOGOPE
		endif

		If Findfunction("TAFAltMan")
			TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T2M', 'T2M_LOGOPE' , '' , cLogOpeAnt )
		EndIf

		TAFAltStat( 'T2M', " " )
		FwFormCommit( oModel )
	ElseIf nOperation == MODEL_OPERATION_DELETE
		If __lGrvRPT == Nil
			TAF423Rpt() //Inicializa a variável static __lGrvRPT
		EndIf

		lInfoRPT := __lGrvRPT

		//Realiza a exclusão do registro da tabela do relatório
		If lInfoRPT
			If oReport == Nil
				oReport := TAFSocialReport():New()
			EndIf

			oInfoRPT := oReport:oVOReport
			oInfoRPT:SetIndApu( "1" )
			oInfoRPT:SetPeriodo( AllTrim( T2M->T2M_PERAPU ) )
			oInfoRPT:SetCPF( AllTrim( T2M->T2M_CPFTRB ) )

			oReport:UpSert( GetEvento( T2M->T2M_NRRECI ), "3", xFilial( "T2M" ), oInfoRPT, .T. )
		EndIf

		oModel:DeActivate()
		oModel:SetOperation( 5 )
		oModel:Activate()

		FwFormCommit( oModel )
	EndIf
End Transaction

If !lRetorno
	// Define a mensagem de erro que será exibida após o Return do SaveModel
	TAFMsgDel(oModel,.T.)
EndIf


Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF423Grv

@description Funcao de gravacao para atender o registro S-5001

@Param:
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
          alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
          tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oDados -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
		  informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao

@author Daniel Schmidt
@since 29/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF423Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTAFRecno, cComplem, cGrpTran, cEmpEnv, cFilEnv, cXmlID, cEvtOri, lMigrador, lDepGPE, cKey, cMatrC9V, lLaySmpTot )

Local cCmpsNoUpd	:= "|T2M_FILIAL|T2M_ID|T2M_VERSAO|T2M_PROTUL|T2M_EVENTO|T2M_STATUS|T2M_ATIVO|"
Local cCabec		:= "/eSocial/evtBasesTrab/"
Local cIdProc		:= ""
Local cInconMsg		:= ""
Local cString		:= ""
Local cTpInsc  		:= ""
Local cNrInsc  		:= ""
Local cIdEstab 		:= ""
Local cLogOpeAnt 	:= ""
Local nI			:= 0
Local nJ			:= 0
Local nlA			:= 0
Local nSeqErrGrv	:= 0
Local lRet			:= .F.
Local oModel		:= Nil
Local aIncons		:= {}
Local aRules		:= {}
Local aChave		:= {}
Local cRecibo		:= ""
Local cIDEvento		:= ""
Local cInscDesc		:= ""
Local cNrProcJud    := ""
Local cCodSusp      := ""
Local cIdSusp       := ""
Local aCondicao     := {}
Local cTpCR         := ""
Local cDescCR       := ""
Local cIdLotac      := ""
Local cIdCat        := ""
Local cDescCat      := ""
Local cIdTpVl       := ""
Local cDescTpVl     := ""
Local nTamNrInsc	:= TamSX3("C92_NRINSC")[1]
Local nIndice		:= 2
Local nV6G 			:= 0
Local nV6H          := 0
Local nV6I          := 0
Local cV6FPath      := ""
Local cV6GPath      := ""
Local cV6HPath      := ""
Local cV6IPath      := ""


//Relatório de Conferência de Valores
Local oInfoRPT		:=	Nil
Local cCPF			:=	""
Local nPosValores	:=	0
Local aAnalitico	:=	{}
Local lInfoRPT		:=	.F.

Private lVldModel := .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
Private oDados    := {}

Default cLayout   := ""
Default nOpc      := 1
Default cFilEv    := ""
Default oXML      := Nil
Default lDepGPE   := .F.
Default cKey      := ""
Default cMatrC9V  := ""

If IsInCallStack("TafPrepInt")
	lLaySimplif := lLaySmpTot
EndIf	

oDados := oXML

If __lGrvRPT == Nil
	TAF423Rpt() //Inicializa a variável static __lGrvRPT
EndIf

lInfoRPT := __lGrvRPT

If lInfoRPT
	If oReport == Nil
		oReport := TAFSocialReport():New()
	EndIf
EndIf

Begin Transaction

cPeriodo  := FTafGetVal(  cCabec + "ideEvento/perApur", "C", .F., @aIncons, .F. )

Aadd( aChave, { "C", "T2M_INDAPU", cCabec + "ideEvento/indApuracao"							  , .F. } )

If At("-", cPeriodo) > 0
	Aadd( aChave, {"C", "T2M_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
Else
	Aadd( aChave, {"C", "T2M_PERAPU", cPeriodo,.T.} )
EndIf

Aadd( aChave, { "C", "T2M_CPFTRB", FTafGetVal(cCabec + "ideTrabalhador/cpfTrab", "C", .F.,, .F. ), .T. } )

cRecibo := FTafGetVal(  cCabec + "ideEvento/nrRecArqBase", "C", .F., @aIncons, .F. )

If TafColumnPos( "T2M_IDEVEN" )
	cIDEvento := GetIDEvent( cEvtOri )
	aAdd( aChave, { "C", "T2M_IDEVEN", cIDEvento, .T. } )
	aAdd( aChave, { "C", "T2M_ATIVO", '1', .T. } )
	nIndice := 3
else
	Aadd( aChave, { "C", "T2M_NRRECI", cCabec + "ideEvento/nrRecArqBase"						  , .F. } )
endif

//Funcao para validar se a operacao desejada pode ser realizada
If FTafVldOpe( 'T2M', nIndice, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA423', cCmpsNoUpd )

	If TafColumnPos( "T2M_LOGOPE" )
		cLogOpeAnt := T2M->T2M_LOGOPE
	endif

	cPeriodo :=  StrTran(cPeriodo, "-", "" )
	//VERIFICAR SE TEM UM REGISTRO COM PERIODO E CPF IGUAIS...
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrego array com os campos De/Para de gravacao das informacoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRules := TAF423Rul(cEvtOri)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
	//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc <> 5

			oModel:LoadValue( "MODEL_T2M", "T2M_FILIAL", T2M->T2M_FILIAL )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Rodo o aRules para gravar as informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nI := 1 to Len( aRules )
			 	oModel:LoadValue( "MODEL_T2M", aRules[ nI, 01 ], FTafGetVal( aRules[ nI, 02 ], aRules[nI, 03], aRules[nI, 04], @aIncons, .F. ) )
			Next nI

			If Findfunction("TAFAltMan")
				if nOpc == 3
					TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T2M', 'T2M_LOGOPE' , '1', '' )
				elseif nOpc == 4
					TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T2M', 'T2M_LOGOPE' , '', cLogOpeAnt )
				EndIf
			EndIf

			/*----------------------------------------
			(grupo InfoCompl) 
			------------------------------------------*/

			If lLaySimplif .AND. oDados:XPathHasNode(cCabec + "ideTrabalhador/infoCompl" )

				/*----------------------------------------
				(GRUPO SUCESSÃO DE VINCULO) 
				------------------------------------------*/
				
				If oDados:XPathHasNode(cCabec + "ideTrabalhador/infoCompl/sucessaoVinc" )

					// If nOpc == 4 
						oModel:GetModel( "MODEL_V6F" ):LVALID := .T.
						oModel:GetModel( "MODEL_V6F" ):AddLine()
					// EndIf
					cV6FPath := cCabec + "ideTrabalhador/infoCompl/sucessaoVinc"

					oModel:LoadValue("MODEL_V6F", "V6F_TPINSC", FTafGetVal( cV6FPath + "/tpInsc"    , "C", .F., @aIncons, .T. ) )
					oModel:LoadValue("MODEL_V6F", "V6F_NRINSC", FTafGetVal( cV6FPath + "/nrInsc"    , "C", .F., @aIncons, .T. ) )
					oModel:LoadValue("MODEL_V6F", "V6F_MATANT", FTafGetVal( cV6FPath + "/matricAnt" , "C", .F., @aIncons, .T. ) )
					oModel:LoadValue("MODEL_V6F", "V6F_DTADM" , FTafGetVal( cV6FPath + "/dtAdm"     , "D", .F., @aIncons, .T. ) )

				EndIf

				/*----------------------------------------
				V6G -  Dia do mês efetivamente trabalhado pelo empregado com contrato de trabalho intermitente.
				------------------------------------------*/

				nV6G := 1
				cV6GPath := cCabec + "ideTrabalhador/infoCompl/infoInterm[" + CVALTOCHAR(nV6G) + "]"

				If nOpc == 4 .And. oDados:XPathHasNode( cV6GPath )
					For nJ := 1 to oModel:GetModel( 'MODEL_V6G' ):Length()
						oModel:GetModel( 'MODEL_V6G' ):GoLine(nJ)
						oModel:GetModel( 'MODEL_V6G' ):DeleteLine()
					Next nJ
				EndIf

				nV6G := 1
				
				While oDados:XPathHasNode(cV6GPath)

					oModel:GetModel( 'MODEL_V6G' ):LVALID	:= .T.

					If nOpc == 4 .Or. nV6G > 1
						oModel:GetModel( 'MODEL_V6G' ):AddLine()
					EndIf
							
					oModel:LoadValue("MODEL_V6G", "V6G_DIA", FTafGetVal( cV6GPath + "/dia", "C", .F., @aIncons, .F. ) )
					
					nV6G++
					cV6GPath := cCabec + "ideTrabalhador/infoInterm[" + CVALTOCHAR(nV6G) + "]"
				EndDo

				/*----------------------------------------
				V6H -  INFORMAÇÕES COMPLEMENTARES CONT.
				------------------------------------------*/

				nV6H := 1
				cV6HPath := cCabec + "ideTrabalhador/infoCompl/infoComplCont[" + CVALTOCHAR(nV6H) + "]"

				If nOpc == 4 .And. oDados:XPathHasNode( cV6HPath )
					For nJ := 1 to oModel:GetModel( 'MODEL_V6H' ):Length()
						oModel:GetModel( 'MODEL_V6H' ):GoLine(nJ)
						oModel:GetModel( 'MODEL_V6H' ):DeleteLine()
					Next nJ
				EndIf

				While oDados:XPathHasNode(cV6HPath)

					oModel:GetModel( 'MODEL_V6H' ):LVALID	:= .T.

					If nOpc == 4 .Or. nV6H > 1
						oModel:GetModel( 'MODEL_V6H' ):AddLine()
					EndIf
							
					oModel:LoadValue("MODEL_V6H", "V6H_CBO", 	FTafGetVal( cV6HPath + "/codCBO", "C", .F., @aIncons, .F. ) )
					oModel:LoadValue("MODEL_V6H", "V6H_NATV", 	FTafGetVal( cV6HPath + "/natAtividade", "C", .F., @aIncons, .F. ) )
					oModel:LoadValue("MODEL_V6H", "V6H_QTDIA", 	FTafGetVal( cV6HPath + "/qtdDiasTrab", "C", .F., @aIncons, .F. ) )
					
					nV6H++
					cV6HPath := cCabec + "ideTrabalhador/infoComplCont[" + CVALTOCHAR(nV6H) + "]"
				EndDo				

			EndIf

			/*----------------------------------------
			T2N - Informações sobre processos judiciais do trabalhador
			------------------------------------------*/

			nT2N := 1
			cT2NPath := cCabec + "ideTrabalhador/procJudTrab[" + CVALTOCHAR(nT2N) + "]"

			If nOpc == 4 .And. oDados:XPathHasNode( cT2NPath )
				For nJ := 1 to oModel:GetModel( 'MODEL_T2N' ):Length()
					oModel:GetModel( 'MODEL_T2N' ):GoLine(nJ)
					oModel:GetModel( 'MODEL_T2N' ):DeleteLine()
				Next nJ
			EndIf

			nT2N := 1
			While oDados:XPathHasNode(cT2NPath)

				oModel:GetModel( 'MODEL_T2N' ):LVALID	:= .T.

				If nOpc == 4 .Or. nT2N > 1
					oModel:GetModel( 'MODEL_T2N' ):AddLine()
			    EndIf

				//oModel:LoadValue( "MODEL_T2N", "T2N_IDPROC",  FGetIdInt( "", "nrProcJud",, cCabec + "ideTrabalhador/procJudTrab[" + CVALTOCHAR(nT2N) + "]/nrProcJud",,,@cInconMsg, @nSeqErrGrv))
				//oModel:LoadValue( "MODEL_T2N", "T2N_CODSUS", FTafGetVal( cCabec + "ideTrabalhador/procJudTrab[" + CVALTOCHAR(nT2N) + "]/codSusp" , "C", .F., @aIncons, .F.) )

				If oDados:XPathHasNode(cT2NPath)
					If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
						cNrProcJud := FTafGetVal( cT2NPath + "/nrProcJud", "C", .F., @aIncons, .F. )
						aCondicao := {}
						
						aAdd(aCondicao, "C1G_NUMPRO = '" + cNrProcJud + "'")
						aAdd(aCondicao, "C1G_DTINI <= '" + cPeriodo + "'")
						cIdProc := TAF423Ret("C1G", "C1G_ID", aCondicao, .T., cPeriodo)
						
						If ValType(cIdProc) <> "U"
							oModel:LoadValue("MODEL_T2N", "T2N_IDPROC", cIdProc)
						EndIf

						oModel:LoadValue("MODEL_T2N", "T2N_NPROCR", cNrProcJud )

					Else
						cIdProc := FGetIdInt( "nrProcJ", , cT2NPath + "/nrProcJud",,,,@cInconMsg, @nSeqErrGrv)
						oModel:LoadValue("MODEL_T2N", "T2N_IDPROC", cIdProc )
					Endif
				EndIf

				If !Empty(cIdProc)
					If oDados:XPathHasNode(cT2NPath + "/codSusp" )
						If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
							cCodSusp := FTafGetVal( cT2NPath + "/codSusp", "C", .F., @aIncons, .F. )
							
							oModel:LoadValue("MODEL_T2N", "T2N_CODSUS", cCodSusp )

							aCondicao := {}
							aAdd(aCondicao, "T5L_CODSUS = '" + cCodSusp + "'")
							cIdSusp := TAF423Ret("T5L", "T5L_ID", aCondicao)

							If ValType(cIdSusp) <> "U"
								oModel:LoadValue("MODEL_T2N", "T2N_IDSUSP", cIdSusp )
							EndIf

						Else
							oModel:LoadValue("MODEL_T2N", "T2N_IDSUSP", FGetIdInt( "codSusp","",FTafGetVal( cT2NPath + "/codSusp", "C", .F., @aIncons, .F. ),cIdProc,.F.,,@cInconMsg, @nSeqErrGrv) )
						Endif
					EndIf
				EndIf


				nT2N++
				cT2NPath := cCabec + "ideTrabalhador/procJudTrab[" + CVALTOCHAR(nT2N) + "]"
			EndDo

			/*----------------------------------------
			T2O - Cálculo da contribuição previdenciária do segurado
			------------------------------------------*/

			nT2O := 1
			cT2OPath := cCabec + "infoCpCalc[" + CVALTOCHAR(nT2O) + "]"

			If nOpc == 4 .And. oDados:XPathHasNode( cT2OPath )
				For nJ := 1 to oModel:GetModel( 'MODEL_T2O' ):Length()
					oModel:GetModel( 'MODEL_T2O' ):GoLine(nJ)
					oModel:GetModel( 'MODEL_T2O' ):DeleteLine()
				Next nJ
			EndIf

			nT2O := 1
			While oDados:XPathHasNode(cT2OPath)

				oModel:GetModel( 'MODEL_T2O' ):LVALID	:= .T.

				If nOpc == 4 .Or. nT2O > 1
					oModel:GetModel( 'MODEL_T2O' ):AddLine()
			    EndIf

			    If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
					aCondicao := {}
					aAdd(aCondicao, "C6R_CODIGO = '" + FTafGetVal( cT2OPath + "/tpCR", "C", .F., @aIncons, .F. ) + "'")
					cIdCR := TAF423Ret("C6R", "C6R_ID", aCondicao)

					If ValType(cIdCR) <> "U"
						oModel:LoadValue( "MODEL_T2O", "T2O_IDCODR", cIdCR )
					EndIf
					
					cDescCR := TAF423Ret("C6R", "C6R_DESCRI", aCondicao)
					
					If ValType(cDescCR) <> "U"
						oModel:LoadValue( "MODEL_T2O", "T2O_DCODRR", SubStr(AllTrim(FTafGetVal( cT2OPath + "/tpCR", "C", .F., @aIncons, .F. )) + " - " + AllTrim(cDescCR), 1, TamSX3("T2O_DCODRR")[1]) )
					EndIf

				Else
					cTpCR := FGetIdInt( "tpCR", "", cT2OPath + "/tpCR",,,,@cInconMsg, @nSeqErrGrv)
				
					oModel:LoadValue( "MODEL_T2O", "T2O_IDCODR", cTpCR )
				Endif
				oModel:LoadValue( "MODEL_T2O", "T2O_VRCPSE", FTafGetVal( cT2OPath + "/vrCpSeg"        , "N", .F., @aIncons, .T. )	)
				oModel:LoadValue( "MODEL_T2O", "T2O_VRDESC", FTafGetVal( cT2OPath + "/vrDescSeg"      , "N", .F., @aIncons, .T. ) 	)

				nT2O++
				cT2OPath := cCabec + "infoCpCalc[" + CVALTOCHAR(nT2O) + "]"
			EndDo


			/*----------------------------------------
			T2P - Identificação do Estabelecimento ou Obra de Construção Civil e da Lotação Tributária.
			------------------------------------------*/
			If TAFNT0421(lLaySimplif) .And. TafColumnPos("T2P_CLATRI")
				oModel:LoadValue("MODEL_T2P", "T2P_CLATRI", Posicione("C8D", 2, xFilial("C8D") + FTAFGetVal(cCabec + "infoCp/classTrib", "C", .F.,, .F.), "C8D_ID"))
			EndIf

			nT2P := 1
			cT2PPath := cCabec + "infoCp/ideEstabLot[" + CVALTOCHAR(nT2P) + "]"

			If nOpc == 4 .And. oDados:XPathHasNode( cT2PPath )
				For nJ := 1 to oModel:GetModel( 'MODEL_T2P' ):Length()
					oModel:GetModel( 'MODEL_T2P' ):GoLine(nJ)
					oModel:GetModel( 'MODEL_T2P' ):DeleteLine()
				Next nJ
			EndIf

			nT2P := 1
			While oDados:XPathHasNode(cT2PPath)

				oModel:GetModel( 'MODEL_T2P' ):LVALID	:= .T.

				If nOpc == 4 .Or. nT2P > 1
					oModel:GetModel( 'MODEL_T2P' ):AddLine()
			    EndIf

			    cTpInsc  := FTafGetVal(cT2PPath + "/tpInsc", "C", .F.,, .F. )
				cNrInsc  := FTafGetVal(cT2PPath + "/nrInsc", "C", .F.,, .F. )

				//Este trecho do código foi inserido no começo do eSocial, pois o governo devolvia o número do CNPJ sem 0 à esquerda, nos obrigando a inserir este 0 para comparação com a base de dados.
				//Em 09-05-2019 foi efetuada alteração, pois quando se trata de CNO, o tamanho da inscrição é 12 e, desta forma, o 0 à esquerda era acrescentado em situações indevidas.
				//Para o ajuste, foi realizado levantamento de todas inscrições possíveis e suas estruturas.
				If cTpInsc == "1" .and. Len( cNrInsc ) < 14 //CNPJ NN.NNN.NNN/NNNN-NN
					cNrInsc := "0" + cNrInsc
				ElseIf cTpInsc == "2" .and. Len( cNrInsc ) < 11 //CPF NNN.NNN.NNN-NN
					cNrInsc := "0" + cNrInsc
				ElseIf cTpInsc == "3" .and. Len( cNrInsc ) < 15 //CAEPF NNN.NNN.NNN/NNNN-NN
					cNrInsc := "0" + cNrInsc
				ElseIf cTpInsc == "4" .and. Len( cNrInsc ) < 12 //CNO NN.NNN.NNNNN/NN
					cNrInsc := "0" + cNrInsc
				EndIf

				If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
					aCondicao := {}
					aAdd(aCondicao, "(C92_NRINSC = '" + PadR(cNrInsc, nTamNrInsc) + "' OR C92_NRINSC = '" + PadR(SubStr(cNrInsc, 2, Len(cNrInsc)), nTamNrInsc) + "')")
					aAdd(aCondicao, "C92_DTINI <= '" + cPeriodo + "'")
					cIdEstab := TAF423Ret("C92", "C92_ID", aCondicao, .T., cPeriodo)
					
					If ValType(cIdEstab) <> "U"

						cInscDesc := AllTrim(Posicione("C92", 5, xFilial("C92") + cIdEstab + "1", "C92_NRINSC"))

						oModel:LoadValue( "MODEL_T2P", "T2P_ESTABE", cIdEstab)
						oModel:LoadValue( "MODEL_T2P", "T2P_DESTAR", SubStr(AllTrim(cIdEstab) + " - " + cInscDesc, 1, TamSX3("T2P_DESTAR")[1]) )

					EndIf

					If oDados:XPathHasNode(cT2PPath + "/codLotacao")

						cCodLot :=  FTafGetVal( cT2PPath + "/codLotacao", "C", .F., @aIncons, .F. )

						If !Empty(cCodLot)

							aCondicao := {}
							cPeriodo	:= StrTran(cPeriodo, "-", "")
							aAdd(aCondicao, "C99_CODIGO = '" + Padr( cCodLot, TamSx3("C99_CODIGO")[1] ) + "'")
							aAdd(aCondicao, "C99_DTINI <= '" + cPeriodo + "'")
							cIdLotac := TAF423Ret("C99", "C99_ID", aCondicao, .T., cPeriodo)

							If ValType(cIdLotac) <> "U"
								
								oModel:LoadValue( "MODEL_T2P", "T2P_LOTACA", cIdLotac )
								oModel:LoadValue( "MODEL_T2P", "T2P_DLOTAR", SubStr(AllTrim(cIdLotac) + " - " + AllTrim(FTafGetVal( cT2PPath + "/codLotacao", "C", .F., @aIncons, .F. )), 1, TamSX3("T2P_DLOTAR")[1]) )

							EndIf
		
						EndIf 
					EndIf 

				Else
					cIdEstab :=	Posicione("C92", 6, xFilial("C92") + cTpInsc + Padr( cNrInsc, TamSx3("C92_NRINSC")[1] ) + "1","C92_ID")

					oModel:LoadValue( "MODEL_T2P", "T2P_ESTABE", cIdEstab	)
					oModel:LoadValue( "MODEL_T2P", "T2P_LOTACA", FGetIdInt( "codLotacao",		"", cT2PPath + "/codLotacao",,,,@cInconMsg, @nSeqErrGrv)	)
				Endif

				/*----------------------------------------
				T2Q - Informações relativas à matrícula e categoria do trabalhador e tipos de incidências.
				------------------------------------------*/

				nT2Q := 1
				cT2QPath := cT2PPath + "/infoCategIncid[" + CVALTOCHAR(nT2Q) + "]"

				If nOpc == 4 .And. oDados:XPathHasNode( cT2QPath )
					For nJ := 1 to oModel:GetModel( 'MODEL_T2Q' ):Length()
						oModel:GetModel( 'MODEL_T2Q' ):GoLine(nJ)
						oModel:GetModel( 'MODEL_T2Q' ):DeleteLine()
					Next nJ
				EndIf

				nT2Q := 1
				While oDados:XPathHasNode(cT2QPath)

					oModel:GetModel( 'MODEL_T2Q' ):LVALID	:= .T.

					If nOpc == 4 .Or. nT2Q > 1
						oModel:GetModel( 'MODEL_T2Q' ):AddLine()
				    EndIf

					oModel:LoadValue( "MODEL_T2Q", "T2Q_MATRIC"	, FTafGetVal( cT2QPath + "/matricula"	, "C", .F., @aIncons, .F.))

					If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
						aCondicao := {}
						aAdd(aCondicao, "C87_CODIGO = '" + FTafGetVal( cT2QPath + "/codCateg", "C", .F., @aIncons, .F. ) + "'")
						cIdCat := TAF423Ret("C87", "C87_ID", aCondicao)

						If ValType(cIdCat) <> "U"
							oModel:LoadValue( "MODEL_T2Q", "T2Q_CODCAT" , cIdCat)
						EndIf

						cDescCat := TAF423Ret("C87", "C87_DESCRI", aCondicao)

						If ValType(cDescCat) <> "U"
							oModel:LoadValue( "MODEL_T2Q", "T2Q_DCODCR" , SubStr(AllTrim(FTafGetVal( cT2QPath + "/codCateg", "C", .F., @aIncons, .F. )) + " - " + cDescCat, 1, TamSX3("T2Q_DCODCR")[1]))
						EndIf
					Else
						oModel:LoadValue( "MODEL_T2Q", "T2Q_CODCAT" , FGetIdInt( "codCateg", "", cT2QPath + "/codCateg",,,,@cInconMsg, @nSeqErrGrv))
					Endif

					if oDados:XPathHasNode( cT2QPath + "/indSimples" )
					    oModel:LoadValue( "MODEL_T2Q", "T2Q_INDCON"	, FTafGetVal( cT2QPath + "/indSimples"	, "C", .F., @aIncons, .T.))
					endif

					/*----------------------------------------
					T2R - Informações sobre bases de cálculo, descontos e deduções de contribuições
					------------------------------------------*/

					nT2R := 1
					cT2RPath := cT2QPath + "/infoBaseCS[" + CVALTOCHAR(nT2R) + "]"

					If nOpc == 4 .And. oDados:XPathHasNode( cT2RPath )
						For nJ := 1 to oModel:GetModel( 'MODEL_T2R' ):Length()
							oModel:GetModel( 'MODEL_T2R' ):GoLine(nJ)
							oModel:GetModel( 'MODEL_T2R' ):DeleteLine()
						Next nJ
					EndIf

					nT2R := 1
					While oDados:XPathHasNode(cT2RPath)

						oModel:GetModel( 'MODEL_T2R' ):LVALID	:= .T.

						If nOpc == 4 .Or. nT2R > 1
							oModel:GetModel( 'MODEL_T2R' ):AddLine()
					    EndIf

						oModel:LoadValue( "MODEL_T2R", "T2R_INDDEC",	FTafGetVal( cT2RPath + "/ind13"	, "C", .F.	, @aIncons, .T.))
						
						If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
							aCondicao := {}
							aAdd(aCondicao, "T2T_CODIGO = '" + FTafGetVal( cT2RPath + "/tpValor", "C", .F., @aIncons, .F. ) + "'")
							cIdTpVl := TAF423Ret("T2T", "T2T_ID", aCondicao)

							If ValType(cIdTpVl) <> "U"
								oModel:LoadValue( "MODEL_T2R", "T2R_TPVLR",	cIdTpVl)
							EndIf

							cDescTpVl := TAF423Ret("T2T", "T2T_DESCRI", aCondicao)

							If ValType(cDescTpVl) <> "U"
								oModel:LoadValue( "MODEL_T2R", "T2R_DTPVRR", SubStr(AllTrim(FTafGetVal( cT2RPath + "/tpValor", "C", .F., @aIncons, .F. )) + " - " + cDescTpVl, 1, TamSX3("T2R_DTPVRR")[1]))
							EndIf
						Else
							oModel:LoadValue( "MODEL_T2R", "T2R_TPVLR",		FGetIdInt( "", "tpValor", "" , cT2RPath + "/tpValor" ,,,@cInconMsg, @nSeqErrGrv))
						Endif

						oModel:LoadValue( "MODEL_T2R", "T2R_VALOR", 	FTafGetVal( cT2RPath + "/valor"	, "N", .F.	, @aIncons, .T.))

						If lInfoRPT
							aAdd( aAnalitico, Array( 16 ) )
							nPosValores := Len( aAnalitico )

							aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( FTAFGetVal( cT2QPath + "/matricula", "C", .F.,, .F. ) )
							aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( FTAFGetVal( cT2QPath + "/codCateg", "C", .F.,, .F. ) )
							aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( FTAFGetVal( cT2PPath + "/tpInsc", "C", .F.,, .F. ) )
							aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( FTAFGetVal( cT2PPath + "/nrInsc", "C", .F.,, .F. ) )
							aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( FTAFGetVal( cT2PPath + "/codLotacao", "C", .F.,, .F. ) )
							aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	""
							aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	""
							aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	""
							aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	""
							aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	""
							aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	AllTrim( FTAFGetVal( cT2RPath + "/ind13", "C", .F.,, .F. ) )
							aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	AllTrim( FTAFGetVal( cT2RPath + "/tpValor", "C", .F.,, .F. ) )
							aAnalitico[nPosValores][ANALITICO_VALOR]				:=	FTAFGetVal( cT2RPath + "/valor", "N", .F.,, .F. )
						EndIf

						nT2R++
						cT2RPath := cT2QPath + "/infoBaseCS[" + CVALTOCHAR(nT2R) + "]"

					EndDo

					/*----------------------------------------
					T2S - Cálculo das contribuições sociais devidas a Outras Entidades e Fundos.
					------------------------------------------*/
					nT2S := 1
					cT2SPath := cT2QPath + "/calcTerc[" + CVALTOCHAR(nT2S) + "]"

					If nOpc == 4 .And. oDados:XPathHasNode( cT2SPath )
						For nJ := 1 to oModel:GetModel( 'MODEL_T2S' ):Length()
							oModel:GetModel( 'MODEL_T2S' ):GoLine(nJ)
							oModel:GetModel( 'MODEL_T2S' ):DeleteLine()
						Next nJ
					EndIf

					nT2S := 1
					While oDados:XPathHasNode(cT2SPath)

						oModel:GetModel( 'MODEL_T2S' ):LVALID	:= .T.

						If nOpc == 4 .Or. nT2S > 1
							oModel:GetModel( 'MODEL_T2S' ):AddLine()
					    EndIf

						If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
							aCondicao := {}
							aAdd(aCondicao, "C6R_CODIGO = '" + FTafGetVal( cT2SPath + "/tpCR", "C", .F., @aIncons, .F. ) + "'")
							cIdCR := TAF423Ret("C6R", "C6R_ID", aCondicao)

							If ValType(cIdCR) <> "U"
								oModel:LoadValue( "MODEL_T2S", "T2S_IDCODR", cIdCR)
							EndIf

							cDescCR := TAF423Ret("C6R", "C6R_DESCRI", aCondicao)

							If ValType(cDescCR) <> "U"
								oModel:LoadValue( "MODEL_T2S", "T2S_DCODRR", SubStr(AllTrim(FTafGetVal( cT2SPath + "/tpCR", "C", .F., @aIncons, .F. )) + " - " + cDescCR, 1, TamSX3("T2S_DCODRR")[1]))
							EndIf
						Else
							oModel:LoadValue( "MODEL_T2S", "T2S_IDCODR",	FGetIdInt( "tpCR", "", cT2SPath + "/tpCR",,,,@cInconMsg, @nSeqErrGrv)	)
						Endif
						
						oModel:LoadValue( "MODEL_T2S", "T2S_VLRCON",	FTafGetVal( cT2SPath + "/vrCsSegTerc"        	 , "N", .F., @aIncons, .T. ))
						oModel:LoadValue( "MODEL_T2S", "T2S_VLRDES", 	FTafGetVal( cT2SPath + "/vrDescTerc"   			 , "N", .F., @aIncons, .T. ))

						nT2S++
						cT2SPath := cT2QPath + "/calcTerc[" + CVALTOCHAR(nT2S) + "]"
					EndDo


					If TAFColumnPos( "V5J_PERREF" )

						/*----------------------------------------
						V5J - Informações de remuneração por período de referência 
						------------------------------------------*/
						nV5J := 1
						cV5JPath := cT2QPath + "/infoPerRef[" + cValToChar( nV5J ) + "]"

						If nOpc == 4 .and. oDados:xPathHasNode( cV5JPath )
							For nI := 1 to oModel:GetModel( "MODEL_V5J" ):Length()
								oModel:GetModel( "MODEL_V5J" ):GoLine( nI )
								oModel:GetModel( "MODEL_V5J" ):DeleteLine()
							Next nI
						EndIf

						nV5J := 1
						While oDados:xPathHasNode( cV5JPath )

							If nOpc == 4 .or. nV5J > 1
								oModel:GetModel( "MODEL_V5J" ):LVALID := .T.
								oModel:GetModel( "MODEL_V5J" ):AddLine()
							EndIf

							If oDados:xPathHasNode( cV5JPath + "/perRef" )
								cPerRef := StrTran( FTAFGetVal( cV5JPath + "/perRef", "C", .F., @aIncons, .F. ), "-", "" )
								cPerRef := SubStr( cPerRef, 5, 2 ) + SubStr( cPerRef, 1, 4 )
								oModel:LoadValue( "MODEL_V5J", "V5J_PERREF", cPerRef )
							EndIf

							//GRUPO IDEADC
							If lLaySimplif .AND. TAFColumnPos('V6I_DTCON')

								nV6I := 1
								cV6IPath := cV5JPath + "/ideADC[" + cValToChar( nV6I ) + "]"

								If nOpc == 4 .and. oDados:xPathHasNode( cV6IPath )
									For nI := 1 to oModel:GetModel( "MODEL_V6I" ):Length()
										oModel:GetModel( "MODEL_V6I" ):GoLine( nI )
										oModel:GetModel( "MODEL_V6I" ):DeleteLine()
									Next nI
								EndIf

								While oDados:XPathHasNode(cV6IPath)

									oModel:GetModel( 'MODEL_V6I' ):LVALID	:= .T.

									If nOpc == 4 .Or. nV6I > 1
										oModel:GetModel( 'MODEL_V6I' ):AddLine()
									EndIf
											
									oModel:LoadValue("MODEL_V6I", "V6I_DTCON", 	FTafGetVal( cV6IPath + "/dtAcConv"	, "D", .F., @aIncons, .F. ) )
									oModel:LoadValue("MODEL_V6I", "V6I_TPCON", 	FTafGetVal( cV6IPath + "/tpAcConv"	, "C", .F., @aIncons, .F. ) )
									oModel:LoadValue("MODEL_V6I", "V6I_DSC", 	FTafGetVal( cV6IPath + "/dsc"		, "C", .F., @aIncons, .F. ) )
									oModel:LoadValue("MODEL_V6I", "V6I_REMUN", 	FTafGetVal( cV6IPath + "/remunSuc"	, "C", .F., @aIncons, .F. ) )
									
									nV6I++
									cV6IPath := cV5JPath + "/ideADC[" + cValToChar( nV6I ) + "]"

								EndDo

							EndIf

							/*----------------------------------------
							V5K - Detalhamento das informações de remuneração por período de referência
							------------------------------------------*/
							nV5K := 1
							cV5KPath := cV5JPath + "/detInfoPerRef[" + cValToChar( nV5K ) + "]"

							If nOpc == 4 .and. oDados:xPathHasNode( cV5KPath )
								For nI := 1 to oModel:GetModel( "MODEL_V5K" ):Length()
									oModel:GetModel( "MODEL_V5K" ):GoLine( nI )
									oModel:GetModel( "MODEL_V5K" ):DeleteLine()
								Next nI
							EndIf

							nV5K := 1

							While oDados:xPathHasNode( cV5KPath )

								If nOpc == 4 .or. nV5K > 1
									oModel:GetModel( "MODEL_V5K" ):LVALID := .T.
									oModel:GetModel( "MODEL_V5K" ):AddLine()
								EndIf

								If oDados:xPathHasNode( cV5KPath + "/ind13" )
									oModel:LoadValue( "MODEL_V5K", "V5K_INDDEC", FTAFGetVal( cV5KPath + "/ind13", "C", .F., @aIncons, .F. ) )
								EndIf

								If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
									aCondicao := {}
									If !lLaySimplif
										aAdd(aCondicao, "V5L_CODIGO = '" + FTafGetVal( cV5KPath + "/tpValor", "C", .F., @aIncons, .F. ) + "'")
									Else
										aAdd(aCondicao, "V5L_CODIGO = '" + FTafGetVal( cV5KPath + "/tpVrPerRef", "C", .F., @aIncons, .F. ) + "'")
									EndIf

									cIdTpVl := TAF423Ret("V5L", "V5L_ID", aCondicao)

									If ValType(cIdTpVl) <> "U"
										oModel:LoadValue( "MODEL_V5K", "V5K_TPVLR",	cIdTpVl)
									EndIf

									cDescTpVl := TAF423Ret("V5L", "V5L_DESCRI", aCondicao)

									If ValType(cDescTpVl) <> "U"
										If !lLaySimplif
											oModel:LoadValue( "MODEL_V5K", "V5K_DTPVRR", SubStr(AllTrim(FTafGetVal( cV5KPath + "/tpValor", "C", .F., @aIncons, .F. )) + " - " + cDescTpVl, 1, TamSX3("V5K_DTPVRR")[1]))
										Else
											oModel:LoadValue( "MODEL_V5K", "V5K_DTPVRR", SubStr(AllTrim(FTafGetVal( cV5KPath + "/tpVrPerRef", "C", .F., @aIncons, .F. )) + " - " + cDescTpVl, 1, TamSX3("V5K_DTPVRR")[1]))
										EndIf
									EndIf
								Else
									oModel:LoadValue( "MODEL_V5K", "V5K_TPVLR", FGetIDInt( "", "tpValorV5L",, cV5KPath + "/tpValor",,, @cInconMsg, @nSeqErrGrv ) )
								Endif

								If oDados:xPathHasNode( cV5KPath + "/vrPerRef" )
									oModel:LoadValue( "MODEL_V5K", "V5K_VALOR", FTAFGetVal( cV5KPath + "/vrPerRef", "N", .F., @aIncons, .F. ) )
								EndIf

								nV5K ++
								cV5KPath := cV5JPath + "/detInfoPerRef[" + cValToChar( nV5K ) + "]"
								
							EndDo

							nV5J ++
							cV5JPath := cT2QPath + "/infoPerRef[" + cValToChar( nV5J ) + "]"

						EndDo

					EndIf
					
					nT2Q++
					cT2QPath := cT2PPath + "/infoCategIncid[" + CVALTOCHAR(nT2Q) + "]"

				EndDo

				nT2P++
				cT2PPath := cCabec + "infoCp/ideEstabLot[" + CVALTOCHAR(nT2P) + "]"

			EndDo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetiva a operacao desejada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cInconMsg) .And. Empty(aIncons)
			If TafFormCommit( oModel )
				Aadd(aIncons, "ERRO19")
				cString += "- Totalizador aIncons ERRO19 - " + CRLF
				TAFConOut( "- totalizador aIncons ERRO19 -" )

				for nlA := 1 to Len( aIncons )
					if len( aIncons[nlA] ) >= 1
						cString += "- Totalizador aIncons  - " + aIncons[nlA] + CRLF
						TAFConOut( "- totalizador aIncons - " + aIncons[nlA] + " - " )
					endif
				next nlA
			Else
				lRet := .T.

				If lRet .and. lInfoRPT
					cCPF := FTAFGetVal( cCabec + "ideTrabalhador/cpfTrab", "C", .F.,, .F. )

					oInfoRPT := oReport:oVOReport
					oInfoRPT:SetIndApu( Iif( Len( StrTran( cPeriodo, "-", "" ) ) <= 4, "2", "1" ) )
					oInfoRPT:SetPeriodo( AllTrim( StrTran( cPeriodo, "-", "" ) ) )
					oInfoRPT:SetCPF( AllTrim( cCPF ) )
					oInfoRPT:SetNome( AllTrim( Posicione( "C9V", 3, xFilial( "C9V" ) + cCPF + "1", "C9V_NOME" ) ) )
					oInfoRPT:SetRecibo( AllTrim( cRecibo ) )
					oInfoRPT:SetAnalitico( aAnalitico )

					oReport:UpSert( cEvtOri, "3", xFilial( "T2M" ), oInfoRPT )
				EndIf
			EndIf
		Else
			Aadd(aIncons, cInconMsg)
			cString += "| Totalizador aIncons | " + cInconMsg + CRLF
			TAFConOut( "| totalizador aIncons | " + cInconMsg )

			for nlA := 1 to Len( aIncons )
				if len( aIncons[nlA] ) >= 1
					cString += "| Totalizador aIncons | " + aIncons[nlA] + CRLF
					TAFConOut( "| totalizador aIncons | " + aIncons[nlA] + " | ")
				endif
			next nlA
		EndIf
		if !empty(cString)
			MakeDir( GetSrvProfString("rootpath","") + "\profile\" )
			MemoWrite(GetSrvProfString("rootpath","") + "\profile\" + "logtot-" + strtran(dtoc( date() ),"/","") + "-" + strtran(time(),":","") + ".txt", cString )
		endif
		oModel:DeActivate()

		// Atualiza o status do registro - utiliza RecLock, pois o setvalue somente funciona em campos usados
		/*DBSelectArea("T2M")
		T2M->(DbSetOrder( 1 ))

		If RecLock("T2M",.F.)
			T2M->T2M_STATUS := "4"
			T2M->( MsUnlock() )
		EndIf*/
	Endif

End Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zerando os arrays e os Objetos utilizados no processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize( aRules, 0 )
aRules := Nil

aSize( aChave, 0 )
aChave := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF423Rul

@description Regras para gravacao das informacoes do registro S-5001 do E-Social

@Param

@Return
aRull - Regras para a gravacao das informacoes

@author Daniel Schmidt
@since 29/05/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF423Rul(cEvtOri)

Local aRull		:= {}
Local cCabec	:= "/eSocial/evtBasesTrab/"
Local cIDEvento	:=	GetIDEvent(cEvtOri)
Local cPeriodo	:= FTafGetVal(cCabec + "ideEvento/perApur", "C", .F.,, .F. )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chave do registro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aAdd( aRull, {"T2M_INDAPU",FTafGetVal(cCabec + "ideEvento/indApuracao", "C", .F.,, .F. ), "C", .T.} )

If At("-", cPeriodo) > 0
	Aadd( aRull, {"T2M_PERAPU", StrTran(cPeriodo, "-", "" ) ,"C",.T.} )
Else
	Aadd( aRull, {"T2M_PERAPU", cPeriodo ,"C", .T.} )
EndIf
Aadd( aRull, {"T2M_NRRECI",  FTafGetVal(cCabec + "ideEvento/nrRecArqBase", "C", .F.,, .F. ), "C", .T. } )
Aadd( aRull, {"T2M_CPFTRB",  FTafGetVal(cCabec + "ideTrabalhador/cpfTrab", "C", .F.,, .F. ), "C", .T. } )

If TafColumnPos( "T2M_IDEVEN" )
		Aadd( aRull, {"T2M_IDEVEN",  cIDEvento, "C", .T. } )
endif

Return( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF423Xml

@description Funcao de geracao do XML para atender o registro S-5001
Quando a rotina for chamada o registro deve estar posicionado

@Param:

@Return:
cXml - Estrutura do Xml do Layout S-5001

@author Daniel Schmidt
@since 29/05/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF423Xml(cAlias, nRecno, nOpc, lJob)

	Local cXml     			:= ""
	Local cLayout  			:= "5001"
	Local cReg     			:= "BasesTrab"
	Local cCodSusp 			:= ""
	Local aMensal  			:= {}
	Local lXmlVLd  			:= IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF423XML' ),.T.)
	Local cFilBkp  			:= cFilAnt
	Local cPerRef			:= ""
	Local cIdeADC			:= ""
	Local cDeInfPR 			:= ""
	Local cTpValor			:= ""

	Default cAlias 			:= "T2M"

	cFilAnt := T2M->T2M_FILIAL

	If lXmlVLd

		DBSelectArea("C1G")
		C1G->(DbSetOrder(8))

		DBSelectArea("T2N")
		T2N->( DbSetOrder( 1 ) )

		DBSelectArea("T2O")
		T2O->( DbSetOrder( 1 ) )

		DBSelectArea("T2Q")
		T2Q->( DbSetOrder( 1 ) )

		DBSelectArea("T2P")
		T2P->( DbSetOrder( 1 ) )

		DBSelectArea("T2R")
		T2R->( DbSetOrder( 1 ) )

		DBSelectArea("T2S")
		T2S->( DbSetOrder( 1 ) )

		DBSelectArea("C91")
		C91->( DbSetOrder( 5 ) )
		
		If lLaySimplif
			
			DBSelectArea("V6F")
			V6F->( DbSetOrder( 1 ) )

			DBSelectArea("V6G")
			V6G->( DbSetOrder( 1 ) )

			DBSelectArea("V6H")
			T6H->( DbSetOrder( 1 ) )

			DBSelectArea("V6I")
			V6I->( DbSetOrder( 1 ) )

		EndIf

		AADD(aMensal,T2M->T2M_NRRECI)
		AADD(aMensal,T2M->T2M_INDAPU)

		MsSeek(xFilial('C91')+T2M->T2M_NRRECI +'1')
		If Len(Alltrim(T2M->T2M_PERAPU)) <= 4
			AADD(aMensal,T2M->T2M_PERAPU)
		Else
			AADD(aMensal,substr(T2M->T2M_PERAPU, 1, 4) + '-' + substr(T2M->T2M_PERAPU, 5, 2) )
		EndIf

		cXml +=	"<ideTrabalhador>"
		cXml +=		xTafTag("cpfTrab",T2M->T2M_CPFTRB)

		If lLaySimplif
			cXml += infoCompl()
		EndIf

		If T2N->( MsSeek( xFilial("T2N")+T2M->(T2M_ID+T2M_VERSAO) ) )
			
			While !T2N->(Eof()) .And. AllTrim(T2N->(T2N_ID+T2N_VERSAO)) == AllTrim(T2M->(T2M_ID+T2M_VERSAO))

				cXml +=	"<procJudTrab>"

				C1G->(MsSeek(xFilial("C1G") + T2N->T2N_IDPROC + "1"))
				cXml +=		xTafTag("nrProcJud",C1G->C1G_NUMPRO)

				cCodSusp    := Posicione("T5L",1,xFilial("T5L")+T2N->T2N_IDSUSP,"T5L_CODSUS")

				If !Empty(cCodSusp)
					cXml += xTafTag("codSusp", Alltrim(cCodSusp))
				EndIf

				cXml +=	"</procJudTrab>"

				T2N->(DbSkip())

			EndDo
		EndIf

		cXml +=	"</ideTrabalhador>"

		If T2O->( MsSeek( xFilial("T2O")+T2M->(T2M_ID+T2M_VERSAO) ) )

			While !T2O->(Eof()) .And. AllTrim(T2O->(T2O_ID+T2O_VERSAO)) == AllTrim(T2M->(T2M_ID+T2M_VERSAO))

				cXml +=	"<infoCpCalc>"
				cXml +=		xTafTag("tpCR",POSICIONE("C6R",3, xFilial("C6R")+T2O->T2O_IDCODR,"C6R_CODIGO"))
				cXml +=		xTafTag("vrCpSeg",T2O->T2O_VRCPSE)
				cXml +=		xTafTag("vrDescSeg",T2O->T2O_VRDESC)
				cXml +=	"</infoCpCalc>"

				T2O->(DbSkip())

			EndDo
		EndIf

		cXml +=	"<infoCp>"

		If T2P->( MsSeek( xFilial("T2P")+T2M->(T2M_ID+T2M_VERSAO) ) )
			If TAFNT0421(lLaySimplif) .And. TafColumnPos("T2P_CLATRI")
				cXml += xTafTag("classTrib", AllTrim(Posicione("C8D", 1, xFilial("C8D") + T2P->T2P_CLATRI, "C8D_CODIGO")))
			EndIf
			
			While !T2P->(Eof()) .And. AllTrim(T2P->(T2P_ID+T2P_VERSAO)) == AllTrim(T2M->(T2M_ID+T2M_VERSAO))

				cXml +=	"<ideEstabLot>"

				cXml +=		xTafTag("tpInsc",POSICIONE("C92",1, xFilial("C92")+T2P->T2P_ESTABE,"C92_TPINSC"))
				cXml +=		xTafTag("nrInsc",POSICIONE("C92",1, xFilial("C92")+T2P->T2P_ESTABE,"C92_NRINSC"))
				cXml +=		xTafTag("codLotacao",Posicione("C99",4,xFilial("C99") + T2P->T2P_LOTACA + '1',"C99_CODIGO"))

				If T2Q->( MsSeek( xFilial("T2Q")+T2P->( T2P_ID+T2P_VERSAO+T2P_ESTABE+T2P_LOTACA ) ) )
					
					While !T2Q->(Eof()) .And. AllTrim( T2Q->( T2Q_ID+T2Q_VERSAO+T2Q_ESTABE+T2Q_LOTACA ) ) == AllTrim( T2P->( T2P_ID+T2P_VERSAO+T2P_ESTABE+T2P_LOTACAO ) )

						cXml +=	"<infoCategIncid>"
						cXml +=		xTafTag("matricula",T2Q->T2Q_MATRIC,,.T.)
						cXml += 		xTafTag("codCateg",POSICIONE("C87",1, xFilial("C87")+T2Q->T2Q_CODCAT,"C87_CODIGO"))
						cXml +=		xTafTag("indSimples",T2Q->T2Q_INDCON,,.T.)

						If T2R->( MsSeek( xFilial("T2R")+T2Q->(T2Q_ID+T2Q_VERSAO+T2Q_ESTABE+T2Q_LOTACA+T2Q_MATRIC+T2Q_CODCAT) ) )
							
							While !T2R->(Eof()) .And. AllTrim(T2R->(T2R_ID+T2R_VERSAO+T2R_ESTABE+T2R_LOTACA+T2R_MATRIC+T2R_CODCAT)) == AllTrim(T2Q->(T2Q_ID+T2Q_VERSAO+T2Q_ESTABE+T2Q_LOTACA+T2Q_MATRIC+T2Q_CODCAT))

								cXml +=	"<infoBaseCS>"
								cXml +=		xTafTag("ind13",T2R->T2R_INDDEC)
								cXml +=		xTafTag("tpValor",POSICIONE("T2T",3, xFilial("T2T")+T2R->T2R_TPVLR,"T2T_CODIGO"))
								cXml +=		xTafTag("valor",T2R->T2R_VALOR )
								cXml +=	"</infoBaseCS>"

								T2R->(DbSkip())

							EndDo
						EndIf

						If T2S->( MsSeek( xFilial("T2S")+T2Q->(T2Q_ID+T2Q_VERSAO+T2Q_ESTABE+T2Q_LOTACA+T2Q_MATRIC+T2Q_CODCAT) ) )
							
							While !T2S->(Eof()) .And. AllTrim(T2S->(T2S_ID+T2S_VERSAO+T2S_ESTABE+T2S_LOTACA+T2S_MATRIC+T2S_CODCAT)) == AllTrim(T2Q->(T2Q_ID+T2Q_VERSAO+T2Q_ESTABE+T2Q_LOTACA+T2Q_MATRIC+T2Q_CODCAT))

								cXml +=	"<calcTerc>"
								cXml +=		xTafTag("tpCR",POSICIONE("C6R",3, xFilial("C6R")+T2S->T2S_IDCODR,"C6R_CODIGO"))
								cXml +=		xTafTag("vrCsSegTerc",T2S->T2S_VLRCON)
								cXml +=		xTafTag("vrDescTerc",T2S->T2S_VLRDES)
								cXml +=	"</calcTerc>"

								T2S->(DbSkip())

							EndDo
						EndIf

						If TAFColumnPos( "V5J_PERREF" )

							cPerRef			:= ""
							cIdeADC			:= ""
							cDetInfoPerRef 	:= ""

							If V5J->( MsSeek( xFilial("V5J")+T2Q->(T2Q_ID+T2Q_VERSAO+T2Q_ESTABE+T2Q_LOTACA+T2Q_MATRIC+T2Q_CODCAT) ) )
								
								While !V5J->(Eof()) .And. AllTrim(V5J->(V5J_ID+V5J_VERSAO+V5J_ESTABE+V5J_LOTACA+V5J_MATRIC+V5J_CODCAT)) == AllTrim(T2Q->(T2Q_ID+T2Q_VERSAO+T2Q_ESTABE+T2Q_LOTACA+T2Q_MATRIC+T2Q_CODCAT))
									
									cPerRef := Iif(Empty(V5J->V5J_PERREF), "", SubStr(V5J->V5J_PERREF, 3, 4) + "-" + SubStr(V5J->V5J_PERREF, 1, 2))
									
									If lLaySimplif

										If V6I->( MsSeek( xFilial("V6I")+V5J->(V5J_ID+V5J_VERSAO+V5J_ESTABE+V5J_LOTACA+V5J_MATRIC+V5J_CODCAT+V5J_PERREF) ) )
											
											While !V6I->(Eof()) .And. AllTrim(V6I->(V6I_ID+V6I_VERSAO+V6I_ESTABE+V6I_LOTACA+V6I_MATRIC+V6I_CODCAT+V6I_PERREF)) == AllTrim(V5J->(V5J_ID+V5J_VERSAO+V5J_ESTABE+V5J_LOTACA+V5J_MATRIC+V5J_CODCAT+V5J_PERREF))
												
												xTafTagGroup("ideADC"	,{ {"dtAcConv"	,	V6I->V6I_DTCON	,, .T. } 	;
																		,  {"tpAcConv"	,	V6I->V6I_TPCON	,, .F. } 	;
																		,  {"dsc"		,	V6I->V6I_DSC	,, .F. }	;
																		,  {"remunSuc"	,	V6I->V6I_REMUN	,, .T. }}	;
																		,  @cIdeADC,, .F.)

												V6I->(DbSkip())

											EndDo
										EndIf
									EndIf

									cTpValor := Iif(lLaySimplif, "tpVrPerRef", "tpValor")
									
									If  V5K->( MsSeek( xFilial( "V5K" ) + V5J->( V5J_ID+V5J_VERSAO+V5J_ESTABE+V5J_LOTACA+V5J_MATRIC+V5J_CODCAT+V5J_PERREF ) ) )
										
										While V2K->( !Eof() ) .and. xFilial( "V5K" ) + V5K->( V5K_ID+V5K_VERSAO+V5K_ESTABE+V5K_LOTACA+V5K_MATRIC+V5K_CODCAT+V5K_PERREF ) == xFilial( "V5K" ) + V5J->( V5J_ID+V5J_VERSAO+V5J_ESTABE+V5J_LOTACA+V5J_MATRIC+V5J_CODCAT+V5J_PERREF )
											
											xTafTagGroup("detInfoPerRef"	, {	{"ind13"	,	V5K->V5K_INDDEC															,, .F.} 	;
																			,	{cTpValor	,	Posicione("V5L", 3, xFilial( "V5L" ) + V5K->V5K_TPVLR, "V5L_CODIGO")	,, .F.} 	;
																			, 	{"vrPerRef"	,	V5K->V5K_VALOR															,, .F.}	}	;
																			, @cDeInfPR,, .T.)

											V5K->( DBSkip() )

										EndDo

									ElseIf !Empty(cIdeADC) .OR. !Empty(cPerRef)

										xTafTagGroup("detInfoPerRef"	, {	{"ind13"	,	""	,, 	.F.} 		;
																		,	{cTpValor	,	""	,, 	.F.} 		;
																		, 	{"vrPerRef"	,	""	,, 	.F.}	}	;
																		, @cDeInfPR,, .T.)

									EndIf

									V5J->(DbSkip())

								EndDo
							
							EndIf

							xTafTagGroup("infoPerRef"	, 			{	{"perRef"			, cPerRef			,, .F. 	}	}	;
														, @cXml	, 	{	{ "ideADC" 			, cIdeADC 			, 0 	}		;
																,		{ "detInfoPerRef" 	, cDeInfPR			, 1	 	}	}	;
														, .F.	, .T.)

						EndIf

						cXml +=	"</infoCategIncid>"

						T2Q->(DbSkip())

					EndDo
				EndIf

				cXml +=	"</ideEstabLot>"

				T2P->(DbSkip())

			EndDo
		EndIf

		cXml +=	"</infoCp>"


		C1G->(DbCloseArea())
		T2N->(DbCloseArea())
		T2O->(DbCloseArea())
		T2P->(DbCloseArea())
		T2Q->(DbCloseArea())
		T2R->(DbCloseArea())
		T2S->(DbCloseArea())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do cabecalho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cXml := xTafCabXml(cXml,"T0G",cLayout,cReg,aMensal)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa gravacao do registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf 

	EndIf

	If !( Empty( cFilBkp ) )
		cFilAnt := cFilBkp
	EndIf

Return( cXml )

Static Function TAF423Ret(cTabela, cRetorno, aCondicao, lValidDate, cPeriodo)

Local xRet := Nil
Local cQuery := ""
Local cTab := GetNextAlias()
Local nI := 1
Local cBaseCnpj := ""
Local aBaseFil := {}
Local nPosFil := 0
Local nPosIni := 0
Local cFilBkp := ""
Local cTabAux := GetNextAlias()
Local nX := 1

Default cTabela		:= ""
Default cRetorno	:= ""
Default aCondicao	:= {}
Default lValidDate	:= .F.
Default cPeriodo	:= ""

cQuery := "SELECT " + cRetorno + CRLF

If lValidDate
	cQuery += " , " + cTabela + "_DTINI "
	cQuery += " , " + cTabela + "_DTFIN "
EndIf

cQuery += "FROM " + RetSQLName((cTabela)) + CRLF
cQuery += "WHERE " + cTabela + "_FILIAL = '" + xFilial((cTabela)) + "'" + CRLF

For nI := 1 To Len(aCondicao)
	cQuery += "	AND " + aCondicao[nI] + CRLF
Next nI

If FindFunction("tafIsTabeSocial")
	If tafIsTabeSocial(cTabela)
		cQuery += "	AND " + cTabela + "_ATIVO = '1'" + CRLF
	Endif
EndIf

cQuery += "	AND D_E_L_E_T_ = ' '"

If lValidDate
	cQuery += "	ORDER BY " + cTabela + "_DTINI "
EndIf

cQuery := ChangeQuery(cQuery)
TCQuery cQuery New Alias (cTab)

If ((cTab)->(!Eof()))

	// Pega o último registro ativo
	If lValidDate	
		While (cTab)->( !Eof() )
			
			If Empty( (cTab)->&( cTabela + "_DTFIN" ) ) .Or. ( !Empty( (cTab)->&( cTabela + "_DTFIN" ) ) .And. cPeriodo <= (cTab)->&( cTabela + "_DTFIN" ) )
				xRet := (cTab)->&(cRetorno)
			EndIf

			(cTab)->( dbSkip() )
		EndDo
	Else
		xRet := (cTab)->&(cRetorno)
	EndIf

Else
	aBaseFil := FwLoadSM0()
	nPosFil := aScan(aBaseFil, {|x| x[2] == cFilAnt})
	cBaseCnpj := SubStr(aBaseFil[nPosFil][18], 1, 9)
	aSort(aBaseFil, , , {|x,y|x[18] < y[18]})
	nPosIni := aScan(aBaseFil, {|x| SubStr(x[18], 1, 9) == cBaseCnpj})
	cFilBkp := cFilAnt

	If !(Empty(nPosIni))
		nI := nPosIni

		While ((nI <= Len(aBaseFil)) .And. (SubStr(aBaseFil[nI][18], 1, 9) == cBaseCnpj))
			cFilAnt := aBaseFil[nI][2]

			cQuery := "SELECT " + cRetorno + CRLF
			cQuery += "FROM " + RetSQLName((cTabela)) + CRLF
			cQuery += "WHERE " + cTabela + "_FILIAL = '" + xFilial((cTabela)) + "'" + CRLF
			For nX := 1 To Len(aCondicao)
				cQuery += "	AND " + aCondicao[nX] + CRLF
			Next nX

			If FindFunction("tafIsTabeSocial")
				If tafIsTabeSocial(cTabela)
					cQuery += "	AND " + cTabela + "_ATIVO = '1'" + CRLF
				Endif
			EndIf 

			cQuery += "	AND D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			TCQuery cQuery New Alias (cTabAux)

			If ((cTabAux)->(!Eof()))
				xRet := (cTabAux)->&(cRetorno)

				Exit
			Else
				nI++
			Endif

			(cTabAux)->(DbCloseArea())
		Enddo
	Endif

	cFilAnt := cFilBkp
Endif

(cTab)->(DbCloseArea())
Return(xRet)

//--------------------------------------------------------------------
/*/{Protheus.doc} SetCssButton

@description Cria objeto TButton utilizando CSS

@author Eduardo Sukeda
@since 09/04/2019
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

//---------------------------------------------------------------------
/*/{Protheus.doc} GetIDEvent
@type			function
@description	Busca o ID do Evento Original a partir do Recibo.
@author			Alexandre de Lima S.
@since			05/08/2019
@version		1.0
@param			cRecibo	-	Recibo do evento original
@return			cEvento	-	Evento original
/*/
//---------------------------------------------------------------------
Static Function GetIDEvent( cEvtOri )

Local cEvento	:=	""

Default cEvtOri	:=  ""

/*-----
S-1200
------*/
If cEvtOri == "S-1200"
	cEvento := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-1200", "C8E_ID" )
EndIf

/*-----
S-2299
------*/
If cEvtOri == "S-2299"
	cEvento := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-2299", "C8E_ID" )
EndIf

/*-----
S-2399
------*/
If cEvtOri == "S-2399"
	cEvento := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-2399", "C8E_ID" )
EndIf

Return( cEvento )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetEvento
@type			function
@description	Busca o ID do Evento Original a partir do Recibo.
@author			Felipe C. Seolin
@since			06/08/2019
@version		1.0
@param			cRecibo	-	Recibo do evento original
@return			cEvento	-	Evento original
/*/
//---------------------------------------------------------------------
Static Function GetEvento( cRecibo )

Local cAliasQry	:=	GetNextAlias()
Local cQuery	:=	""
Local cEvento	:=	""
Local lContinue	:=	.T.

If lContinue
	/*-----
	S-1200
	------*/
	cQuery := "SELECT C91.C91_ID "
	cQuery += "FROM " + RetSqlName( "C91" ) + " C91 "
	cQuery += "WHERE C91.C91_PROTUL = '" + cRecibo + "' "
	cQuery += "  AND C91.C91_ATIVO = '1' "
	cQuery += "  AND C91.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

	If ( cAliasQry )->( !Eof() )
		cEvento		:=	"S-1200"
		lContinue	:=	.F.
	EndIf

	( cAliasQry )->( DBCloseArea() )
EndIf

If lContinue
	/*-----
	S-2299
	------*/
	cQuery := "SELECT CMD.CMD_ID "
	cQuery += "FROM " + RetSqlName( "CMD" ) + " CMD "
	cQuery += "WHERE CMD.CMD_PROTUL = '" + cRecibo + "' "
	cQuery += "  AND CMD.CMD_ATIVO = '1' "
	cQuery += "  AND CMD.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

	If ( cAliasQry )->( !Eof() )
		cEvento		:=	"S-2299"
		lContinue	:=	.F.
	EndIf

	( cAliasQry )->( DBCloseArea() )
EndIf

If lContinue
	/*-----
	S-2399
	------*/
	cQuery := "SELECT T92.T92_ID "
	cQuery += "FROM " + RetSqlName( "T92" ) + " T92 "
	cQuery += "WHERE T92.T92_PROTUL = '" + cRecibo + "' "
	cQuery += "  AND T92.T92_ATIVO = '1' "
	cQuery += "  AND T92.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

	If ( cAliasQry )->( !Eof() )
		cEvento		:=	"S-2399"
		lContinue	:=	.F.
	EndIf

	( cAliasQry )->( DBCloseArea() )
EndIf

Return( cEvento )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF423Rpt
@type			function
@description	Inicializa a variável static __lGrvRPT
@author			Felipe C. Seolin
@since			23/05/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function TAF423Rpt()

__lGrvRPT := TAFAlsInDic( "V3N" )

Return()


//---------------------------------------------------------------------
/*/{Protheus.doc} infoCompl
@type			function
@description	Gera grupo infoCompl
@author			Alexandre de Lima Santos.
@since			24/02/2021
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function infoCompl()

Local cXml  	:= ""
Local lSuces 	:= .F.
Local lTerm 	:= .F.
Local lInfoC    := .F.

If V6F->( MsSeek( xFilial("V6F")+T2M->(T2M_ID+T2M_VERSAO) ) )
		
	While !V6F->(Eof()) .And. AllTrim(V6F->(V6F_ID+V6F_VERSAO)) == AllTrim(T2M->(T2M_ID+T2M_VERSAO))
		cXml :=	"<infoCompl>"
			cXml +=	"<sucessaoVinc>"
			cXml +=		xTafTag("tpInsc",V6F->V6F_TPINSC)
			cXml +=		xTafTag("nrInsc",V6F->V6F_NRINSC)
			cXml +=		xTafTag("matricAnt",V6F->V6F_MATANT,,.T.)
			cXml +=		xTafTag("dtAdm",V6F->V6F_DTADM)
			cXml +=	"</sucessaoVinc>"
		lSuces := .T.
	V6F->(DbSkip())
	EndDo
EndIf

If V6G->( MsSeek( xFilial("V6G")+T2M->(T2M_ID+T2M_VERSAO) ) )
		
	While !V6G->(Eof()) .And. AllTrim(V6G->(V6G_ID+V6G_VERSAO)) == AllTrim(T2M->(T2M_ID+T2M_VERSAO))

	Iif(lSuces,,cXml :=	"<infoCompl>")

	cXml +=	"<infoInterm>"
	cXml +=		xTafTag("dia",V6G->V6G_DIA)
	cXml +=	"</infoInterm>"
		
	lTerm := .T.
	V6G->(DbSkip())
	EndDo
EndIf

If V6H->( MsSeek( xFilial("V6H")+T2M->(T2M_ID+T2M_VERSAO) ) )
		
	While !V6H->(Eof()) .And. AllTrim(V6H->(V6H_ID+V6H_VERSAO)) == AllTrim(T2M->(T2M_ID+T2M_VERSAO))
		
		Iif(lSuces.OR.lTerm,,cXml :="<infoCompl>")

		cXml +=	"<infoComplCont>"
		cXml +=		xTafTag("codCBO",V6H->V6H_CBO)
		cXml +=		xTafTag("natAtividade",V6H->V6H_NATV,,.T.)
		cXml +=		xTafTag("qtdDiasTrab",V6H->V6H_QTDIA,,.T.)
		cXml +=	"</infoComplCont>"

	lInfoC := .T.
	V6H->(DbSkip())
	EndDo
EndIf

Iif(lSuces.OR.lTerm.OR.lInfoC,cXml +="</infoCompl>",)

Return cXml
