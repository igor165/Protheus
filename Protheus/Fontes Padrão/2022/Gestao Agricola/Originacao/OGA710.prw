#INCLUDE "OGA710.ch" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "FWMVCDEF.CH"
 
#DEFINE _CRLF CHR(13)+CHR(10)

Static __aFardos	:= {}		
Static __aLivres	:= {}
// Variáveis criadas como static para corrigir erro de visibilizadade OGA530 
Static cAliFil
Static cAliasBloc
Static cAliGrBlc
Static cAliFrd
Static oArqTempTree
Static oArqTempFrd
Static oArqTempBlc
Static oTree
Static lMarkFil    := .F. 
Static lMarkBlc    := .F.
Static lMarkFrd    := .F.
Static lRolTotal   := .F.  
Static __cProc     := ""
Static __cIdioma   := ""
Static __cPergunte := "OGA710"
Static lProdAlgo   := .F.
Static nIndTree	   := 0
Static lFrdCtn	   := .F. // Variável utilizada para mostrar mensagem do container (Rolagem Parcial)
Static lFrdCtnAlt  := .F. // Variável utilizada para mostrar mensagem do container (Alteração IE)		
Static __lAutomato   := IiF(IsBlind(),.T.,.F.) //iNDICA QUE FOI ACIONADO PELA ROTINA DE AUTOMACAO

/*{Protheus.doc} OGA710
Programa de Instrução de Embarque - Mercado Externo.
@author marcos.wagner
@since 26/07/2017
@version undefined
@type function
*/
Function OGA710(pcCodine, aIE)
	Local aArea    := GetArea()	
	Local oMBrowse := Nil
	Local cFiltroDef := ""
	Local nX := 0
	Local bTeclaF12 := SetKey( VK_F12, { || OGA710REG(.T.) } )

	Private nOpc            := 3
	Private lRolagem        := .F.
	Private __aFieldsN7Q2DO := {}
	Private cRetorno := ""
	Private nMaximo  := 0 
	Private _aRolItGrao := {} //variavel para armazenar os itens de grãos para rolagem parcial
	Default aIE := {}
	//-- Proteção de Código
	If .Not. TableInDic('N7Q') .OR. .Not. TableInDic('N7S')  .OR. .Not. TableInDic('N83')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	If len(aIE) > 0

		For nX:=1 to Len(aIE)
			cFiltroDef += "N7Q_CODINE="+aIE[nX]
			If nX < len(aIE)
				cFiltroDef += " .or. " 
			endif
		next nX

	elseIf !Empty(pcCodine)
		cFiltroDef := iIf( !Empty( pcCodine ), pcCodine, "" )
	endIf

	OGA710REG(.F.) 

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N7Q" )
	oMBrowse:SetDescription( STR0001 ) //"Instrução de Embarque - Mercado Externo"
	oMBrowse:SetFilterDefault( cFiltroDef )

	//Definição da legenda
	oMBrowse:AddLegend( "N7Q_STATUS==1", "YELLOW", STR0035) //Pré-Instruída
	oMBrowse:AddLegend( "N7Q_STATUS==2", "RED"   , STR0036) //Aguardando Instrução
	oMBrowse:AddLegend( "N7Q_STATUS==3 .OR. N7Q_STATUS==5", "GREEN" , STR0037) //Instruída
	//MBrowse:AddLegend( "N7Q_STATUS==4", "GRAY"  , STR0226) //Aguardando Aprovação

	oMBrowse:SetMenuDef('OGA710')
	oMBrowse:SetAttach( .T. ) //visualizações 

	oMBrowse:Activate()

	SetKey( VK_F12, bTeclaF12 )

	RestArea(aArea)

Return aArea

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since:     26/07/2017
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Static Function MenuDef()
	Local aRotina  := {}
	Local aRotina1 := {}
	Local aRotina2 := {}
	Local aRotina3 := {}
	Local aRotina4 := {}
	Local aRotina5 := {}

	aAdd( aRotina1, { STR0045, "GeraEEC('1')"   			, 0, 12, 0, .F. } ) //"Gerar Processos Exportação"
	aAdd( aRotina1, { STR0080, "GeraEEC('9')"   			, 0, 15, 0, .F. } ) //"Ajustar Processos Exportação"
	aAdd( aRotina1, { STR0051, "XEECAP100C"        			, 0, 13, 0, .F. } ) //"Consultar Processos Exportação"
	aAdd( aRotina1, { STR0156, "XEECAE100C"        			, 0, 13, 0, .F. } ) //"Consultar Embarques"	
	aAdd( aRotina1, { STR0049, "DelEEC"      				, 0, 14, 0, .F. } ) //"Excluir Processos Exportação"
	aAdd( aRotina1, { STR0144, "OG710NFExp()"      			, 0, 19, 0, .F. } ) //"Gerar NF Exportação"
	aAdd( aRotina1, { STR0131, "OGA710ACMV"        			, 0, 18, 0, .F. } ) //"Consultar Movimentações Exportação

	aAdd( aRotina2, { STR0150, "OGA710APC(1)"       		, 0, 22, 0, .F. } ) //"Aprovar Contratos sem Assinatura"
	aAdd( aRotina2, { STR0019, "AgrMostraStatus (1,1)" 		, 0, 10, 0, .F. } ) //"Parecer Logistico"
	aAdd( aRotina2, { STR0020, "AgrMostraStatus (2,1)" 		, 0, 25, 0, .F. } ) //"Parecer Comercial"

	aAdd( aRotina3, { STR0083 ,"OGA730(N7Q->N7Q_CODINE)"       , 0, 28, 0, Nil } ) //"Containers"	
	aAdd( aRotina3, { STR0108, "OGA710APCE('1')"               , 0, 15, 0, .F. } ) //"Aprovar Peso Certificado"
	aAdd( aRotina3, { STR0109, "OGA710APCE('2')"               , 0, 16, 0, .F. } ) //"Revisar Peso Certificado"
	aAdd( aRotina2, { STR0174, "OGA710APCE('3')" 		       , 0, 25, 0, .F. } ) //"Aprovar Pegajosidade"
	aAdd( aRotina3, { STR0120, "impCert()"                     , 0, 17, 0, .F. } ) //"Imprimir Certificado de Peso"
	aAdd( aRotina3, { STR0239, "OGAR120()"                     , 0, 31, 0, Nil } ) //"Packing list Bale by Bale"
		
	aAdd( aRotina4, { STR0158, "OG710AVREM()"				, 0, 25, 0, Nil }) 	//"Vincular NFs de Remessa"
	aAdd( aRotina4, { STR0161, "OGA710NREM(N7Q->N7Q_CODINE)", 0, 24, 0, Nil } ) //"Consultar NFs de Remessa"
	aAdd( aRotina4, { STR0163, "OG710BRREM()"				, 0, 27, 0, Nil }) 	//"Retornar NFs de Remessa"
	
	aAdd( aRotina5, { STR0236, "OGX711(N7Q->N7Q_CODINE)"    , 0, 24, 0, Nil } ) //"Consultar Documentos da IE
	
	aAdd( aRotina, { STR0002, "PesqBrw"       	  			, 0, 1,  0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "ViewDef.OGA710"	  			, 0, 2,  0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0005, "ViewDef.OGA710"    			, 0, 4,  0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0009, "AGRCONHECIM('N7Q')"			, 0, 4,  0, .F. } ) //"Conhecimento"
	aAdd( aRotina, { STR0006, "ViewDef.OGA710"	  			, 0, 5,  0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0007, "ViewDef.OGA710"	  			, 0, 8,  0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0050, "OGA710Copia()"    			, 0, 9,  0, Nil } ) //"Rolagem Parcial"
	aAdd( aRotina, { STR0060, "OGA710RLT"         			, 0, 4,  0, NIL } ) //"Rolagem Total"
	aAdd( aRotina, { STR0033, "OGA710HIS"         			, 0, 7,  0, .F. } ) //"Histórico"
	aAdd( aRotina, { STR0079, "OGA710MAIL(N7Q->N7Q_CODINE)"	, 0, 4, 0, Nil } )  //"Enviar e-mail"	
	
	aAdd( aRotina, { STR0242, "OGA710CPRC(N7Q->N7Q_FILIAL,N7Q->N7Q_CODINE)"	, 0, 29, 0, Nil } )  //"Consultar Preços"

	aAdd( aRotina, { STR0145,  aRotina1          	   		, 0, 20, 0, Nil } ) //"Exportação" 		
	aAdd( aRotina, { STR0151,  aRotina2          	   		, 0, 21, 0, Nil } ) //"Aprovações" 
	aAdd( aRotina, { STR0160,  aRotina3          	   		, 0, 23, 0, Nil } ) //"Certificação de Peso" 
	aAdd( aRotina, { STR0162,  aRotina4          	   		, 0, 26, 0, Nil } ) //"Remessa"
	aAdd( aRotina, { STR0235,  aRotina5          	   		, 0, 26, 0, Nil } ) //"Documentos"
	aAdd( aRotina, { STR0159, "OGC003('',N7Q->N7Q_CODINE)"	, 0, 22, 0, .F. } ) //"Romaneios"
	aAdd( aRotina, { STR0173, "AGRA570"    , 0, 22, 0, .F. } ) //"Negociação de Frete"

Return( aRotina )

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since:     26/07/2017
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Static Function ModelDef()
	Local oStruN7Q := FWFormStruct( 1, "N7Q" )
	Local oStruN7S := FWFormStruct( 1, "N7S" )
	Local oStruN7V := FWFormStruct( 1, "N7V" )
	Local oStruN7X := FWFormStruct( 1, "N7X" )
	Local oStruN7Y := FWFormStruct( 1, "N7Y" )	
	Local oStruN86 := FWFormStruct( 1, "N86" )
	Local oStruN90 := FWFormStruct( 1, "N90" )	
	Local oStruNLN := FWFormStruct( 1, "NLN" )
	Local oModel   := MPFormModel():New( "OGA710" , {| oModel | PreModelo( oModel ) }, {| oModel | PosModelo( oModel ) }, {| oModel | GrvModelo( oModel ) }  )
	
	oStruN7S:AddField('Vinc. PEPRO', "Legenda", 'N7S_VINDCO' , 'BT' , 1 , 0, {|| .T.} , NIL , NIL, NIL, {|| "PRECO" }, NIL, .F., .T.)
	
    IF  !__lAutomato          
		oStruN7Q:AddTrigger( "N7Q_CONDPA", "N7Q_CODNT1", { || .T. }, { || fTrgN7QMPA() } )
		oStruN7Q:AddTrigger( "N7Q_PERMIN", "N7Q_QTDMIN", { || .T. }, { | x | fTrgIncPer("N7Q_PERMIN") } )
		oStruN7Q:AddTrigger( "N7Q_PERMAX", "N7Q_QTDMAX", { || .T. }, { | x | fTrgIncPer("N7Q_PERMAX") } )
		oStruN7Q:SetProperty( "N7Q_IMPORT" , MODEL_FIELD_VALID , {|oField| OGA710VIMP(oField) } )	
	Endif	

	oModel:SetDescription(STR0001) //"Instrução de Embarque - Mercado Externo"
	oModel:AddFields("N7QUNICO", Nil, oStruN7Q )

	//--<< Campos que nao devem copiar no processo de rolagem >>--
	cFldsNCopy := ''
	cFldsNCopy += "N7Q_CODINE,N7Q_DESINE,N7Q_BOOK,N7Q_EMBARC,N7Q_DATETA,N7Q_DDELDR,N7Q_HDELDR,N7Q_DTCARG,N7Q_HRCARG,N7Q_STATUS,N7Q_STALOG,N7Q_STACOM,N7Q_STAEXP,N7Q_QTDROL,N7Q_QTDREC,N7Q_QTDCER,N7Q_QFRCER,N7Q_PCRMCE,N7Q_QTDCOR"
	aFldNCopy  := Separa(cFldsNCopy,',' )
	oModel:GetModel( "N7QUNICO" ):SetFldNoCopy( aFldNCopy ) // Na função Copiar nao copia os campos de retornados em array

	/* N7S - Instrução Embarque X Cadência */
	oModel:AddGrid( "N7SUNICO", "N7QUNICO", oStruN7S, , , ,)
	oModel:GetModel( "N7SUNICO" ):SetDescription( STR0011 ) //"Dados da Cadência"
	oModel:GetModel( "N7SUNICO" ):SetUniqueLine( { "N7S_CODCTR", "N7S_ITEM","N7S_SEQPRI" } )
	oModel:GetModel( "N7SUNICO" ):SetOptional(.T.)
	oModel:GetModel( 'N7SUNICO' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'N7SUNICO' ):SetNoDeleteLine( .T. )
	oModel:GetModel( "N7SUNICO" ):SetFldNoCopy({'N7S_CODINE,N7S_QTDREM'}) // Na função Copiar nao copia os campos de retornados em array
	oModel:SetRelation( "N7SUNICO", { { "N7S_FILIAL", "xFilial( 'N7S' )" }, { "N7S_CODINE", "N7Q_CODINE" } }, N7S->( IndexKey( 1 ) ) )

	/* N86 - IE Orig X IE Dest X Mot. Rol */
	oModel:AddGrid( "N86UNICO", "N7QUNICO", oStruN86, , , , )
	oModel:GetModel( "N86UNICO" ):SetDescription( STR0058 ) //"Motivos da Rolagem"
	oModel:GetModel( "N86UNICO" ):SetOptional(.T.)	
	oModel:GetModel( "N86UNICO" ):SetNoUpdateLine(.T.)
	oModel:GetModel( "N86UNICO" ):SetNoInsertLine(.T.)
	oModel:GetModel( 'N86UNICO' ):SetNoDeleteLine(.T.)
	oModel:GetModel( "N86UNICO" ):SetUniqueLine( { "N86_SEQMOT", "N86_IEORIG", "N86_IEDEST", "N86_CODROL" } )		
	oModel:SetRelation( "N86UNICO", { { "N86_FILIAL", "xFilial( 'N86' )" }, {"N86_IEDEST","N7Q_CODINE"}}, N86->( IndexKey( 1 ) ) )

	/* N90 - Cartas de Crédito da IE */
	oModel:AddGrid( "N90UNICO", "N7QUNICO", oStruN90, , , , )
	oModel:GetModel( "N90UNICO" ):SetDescription( STR0073 ) //"Carta de Crédito"
	oModel:GetModel( "N90UNICO" ):SetUniqueLine( { "N90_LC_NUM" } )
	oModel:GetModel( "N90UNICO" ):SetOptional(.T.)
	oModel:SetRelation( "N90UNICO", { { "N90_FILIAL", "xFilial( 'N90' )" }, {"N90_CODINE","N7Q_CODINE"}}, N90->( IndexKey( 1 ) ) )

	/* N7V - Descrição do Bill Of Lading */
	oModel:AddGrid( "N7VUNICO", "N7QUNICO", oStruN7V, , , , )
	oModel:GetModel( "N7VUNICO" ):SetDescription( STR0023 ) //"Descrição do Bill Of Lading"
	oModel:GetModel( "N7VUNICO" ):SetUniqueLine( { "N7V_CODBL" } )
	oModel:GetModel( "N7VUNICO" ):SetOptional(.T.)
	oModel:SetRelation( "N7VUNICO", { { "N7V_FILIAL", "xFilial( 'N7V' )" }, { "N7V_CODINE", "N7Q_CODINE" } }, N7V->( IndexKey( 1 ) ) )

	/* N7Y - Cláusulas Especiais do BL */
	oModel:AddGrid( "N7YUNICO", "N7QUNICO", oStruN7Y, , , , )
	oModel:GetModel( "N7YUNICO" ):SetDescription( STR0024 ) //"Cláusulas Especiais do BL"
	oModel:GetModel( "N7YUNICO" ):SetUniqueLine( { "N7Y_CODCLA" } )
	oModel:GetModel( "N7YUNICO" ):SetOptional(.T.)
	oModel:SetRelation( "N7YUNICO", { { "N7Y_FILIAL", "xFilial( 'N7Y' )" }, { "N7Y_CODINE", "N7Q_CODINE" } }, N7Y->( IndexKey( 1 ) ) )

	/* N7X - Documentos Instrução Embarque */
	oModel:AddGrid( "N7XUNICO", "N7QUNICO", oStruN7X, , , , )
	oModel:GetModel( "N7XUNICO" ):SetDescription( STR0022 ) //"Documentos"
	oModel:GetModel( "N7XUNICO" ):SetUniqueLine( { "N7X_CODDOC" } )
	oModel:GetModel( "N7XUNICO" ):SetOptional(.T.)
	oModel:SetRelation( "N7XUNICO", { { "N7X_FILIAL", "xFilial( 'N7X' )" }, { "N7X_CODINE", "N7Q_CODINE" } }, N7X->( IndexKey( 1 ) ) )
	
	/* NLN - DCOs do PEPRO */
    If TableInDic("NLN")
        oModel:AddGrid("NLNUNICO", "N7QUNICO", oStruNLN, , , ,  )
        oModel:GetModel("NLNUNICO"):SetDescription('PEPRO') //"PEPRO"
        oModel:GetModel("NLNUNICO"):SetUniqueLine({"NLN_CODCTR", "NLN_ITEMPE", "NLN_ITEMRF", "NLN_SEQUEN"})
        oModel:GetModel("NLNUNICO"):SetOptional(.T.)
        oModel:GetModel("NLNUNICO"):SetNoUpdateLine(.T.)
        oModel:GetModel("NLNUNICO"):SetNoInsertLine(.T.)
        oModel:GetModel("NLNUNICO"):SetNoDeleteLine(.T.)
        oModel:SetRelation("NLNUNICO", {{"NLN_FILIAL", "xFilial('NLN')"}, {"NLN_CODINE", "N7Q_CODINE"}}, NLN->(IndexKey(1)))
    EndIf
	
	oModel:SetActivate({|oModel| ActModelo(oModel)})
	
	oModel:SetVldActivate( { | oModel | IniModelo( oModel, oModel:GetOperation() ) } )

Return( oModel )

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since:     26/07/2017
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Static Function ViewDef()

	Local oStruN7QDOC := FWFormStruct( 2, "N7Q", { |x| ALLTRIM(x)  $ 'N7Q_PEDEXP, N7Q_DDELDR, N7Q_HDELDR, N7Q_DTCARG, N7Q_HRCARG, N7Q_DATETA, N7Q_STAEXP'+;
	'N7Q_TEREMB, N7Q_DESTER, N7Q_AGEMAR, N7Q_DESAGE, N7Q_ARMAZE, N7Q_DESARM, N7Q_DESPAC, N7Q_DESDES, N7Q_CONPES, N7Q_DESCON, N7Q_BOOK'  +; 
	'N7Q_EMBARC, N7Q_DESEMB, N7Q_FREETM, N7Q_ARMADO, N7Q_DESCAR, N7Q_VIA,    N7Q_DESVIA, N7Q_PORORI, N7Q_DPOROR, N7Q_PORDES, N7Q_DESPDE, N7Q_TIPCON'}) 

	Local oStruN7Q2DO := FWFormStruct( 2, "N7Q", { |x| ALLTRIM(x)  $ 'N7Q_CODNT1, N7Q_LOJNT1, N7Q_DESNT1, N7Q_ENDNT1, N7Q_EN2NT1,'+;
	'N7Q_CODNT2, N7Q_LOJNT2, N7Q_DESNT2, N7Q_ENDNT2, N7Q_EN2NT2' +;
	'N7Q_CONSIG, N7Q_CONLOJ, N7Q_CONDES, N7Q_CONEND, N7Q_CONEN2' +;
	'N7Q_DOCOBS, N7Q_CODENV, N7Q_DOCENV, N7Q_LOJENV, N7Q_DESENV,'+;
	'N7Q_ENDENV, N7Q_EN2ENV, N7Q_DOCINF,  N7Q_PARLOT, N7Q_EBQPAR'}) 

	Local oStruN7Q := FWFormStruct( 2, "N7Q", { |x| !ALLTRIM(x)  $ 	'N7Q_PEDEXP, N7Q_DDELDR, N7Q_HDELDR, N7Q_DTCARG, N7Q_HRCARG, N7Q_DATETA, N7Q_HORETA, N7Q_STAEXP'+;
	'N7Q_TEREMB, N7Q_DESTER, N7Q_AGEMAR, N7Q_DESAGE, N7Q_ARMAZE, N7Q_DESARM, N7Q_DESPAC, N7Q_DESDES, N7Q_CONPES, N7Q_DESCON, N7Q_BOOK'  +; 
	'N7Q_EMBARC, N7Q_DESEMB, N7Q_FREETM, N7Q_ARMADO, N7Q_DESCAR, N7Q_VIA,    N7Q_DESVIA, N7Q_CODNT1, N7Q_LOJNT1, N7Q_DESNT1, N7Q_ENDNT1, N7Q_EN2NT1,'+;
	'N7Q_CONSIG, N7Q_CONLOJ, N7Q_CONDES, N7Q_CONEND, N7Q_CONEN2, N7Q_PORORI, N7Q_DPOROR, N7Q_PORDES, N7Q_DESPDE' +;
	'N7Q_CODNT2, N7Q_LOJNT2, N7Q_DESNT2, N7Q_ENDNT2, N7Q_EN2NT2, N7Q_DOCOBS, N7Q_CODENV, N7Q_DOCENV, N7Q_LOJENV, N7Q_DESENV,'+;
	'N7Q_ENDENV, N7Q_EN2ENV, N7Q_DOCINF, N7Q_QTDROL, N7Q_TPCNTR, N7Q_LIMMIN, N7Q_LIMMAX, N7Q_PERMIN, N7Q_PERMAX, N7Q_PSCNTR, N7Q_QTDCON, N7Q_CODORI, N7Q_STAPCE, '+;
	'N7Q_PARLOT, N7Q_EBQPAR, N7Q_TOTFAR, N7Q_TOTLIQ, N7Q_TOTBRU, N7Q_QTDREM, N7Q_QTDREC, N7Q_QTDCOR, N7Q_QTDCER, N7Q_PCRMCE, N7Q_QFRCER, N7Q_TIPCON, N7Q_TPVINC, '+;
	'N7Q_QTDMAX, N7Q_QTDMIN'})

	Local oStruN7Q02 := FWFormStruct( 2, "N7Q", { |x| ALLTRIM(x)  $ 'N7Q_TOTFAR, N7Q_TOTLIQ, N7Q_TOTBRU, N7Q_QTDREM, N7Q_QTDREC, N7Q_QTDCOR, N7Q_QTDCER, N7Q_PCRMCE, N7Q_QFRCER, N7Q_TPVINC, N7Q_STAPCE'}) 

	Local oStruN7QROL := FWFormStruct( 2, "N7Q", { |x| ALLTRIM(x)  $ 'N7Q_QTDROL, N7Q_CODORI'})

	Local oStruLPS := FWFormStruct( 2, "N7Q", { |x| ALLTRIM(x)  $ 'N7Q_TPCNTR, N7Q_LIMMIN, N7Q_LIMMAX, N7Q_PERMIN, N7Q_PERMAX, N7Q_QTDMIN, N7Q_QTDMAX, N7Q_PSCNTR, N7Q_QTDCON '}) 

	Local oStruN7S := FWFormStruct( 2, "N7S" )
	Local oStruN7V := FWFormStruct( 2, "N7V" )
	Local oStruN7X := FWFormStruct( 2, "N7X" )
	Local oStruN7Y := FWFormStruct( 2, "N7Y" )
	Local oStruN86 := FWFormStruct( 2, "N86" )
	Local oStruN90 := FWFormStruct( 2, "N90" ) //Carta de Crédito	
	Local oStruNLN := FWFormStruct( 2, "NLN" )
	Local oModel   := FWLoadModel( "OGA710" ) 
	Local oView    := FWFormView():New()

	private lRet := .F.
	__aFieldsN7Q2DO := aClone( oStruN7Q2DO:GetFields() )

	Static oBrwFil := Nil
	Static cN83Fil := GetNextAlias()
	Static oBrwBlc := Nil
	Static cN83Blc := GetNextAlias()
	Static oBrwFrd := Nil
	Static cDXIFrd := GetNextAlias()
	
	oStruN7S:AddField("N7S_VINDCO"  ,'90' , "Vinc. PEPRO", "Legenda", {} , 'BT' ,'@BMP', NIL, NIL, .T., NIL, NIL, NIL,	NIL, NIL, .T.)

	oView:SetModel( oModel )

	If IsInCallStack("OGA530")	
		lProdAlgo := !ValTipProd()
	EndIf

	oView:CreateFolder( "CTRFOLDER") //Cria uma Folder Principal para as pastas, principal, dados documentais

	oView:AddSheet('CTRFOLDER', 'MASTER'      , STR0017) // #Principal
	oView:AddSheet('CTRFOLDER', 'DOCUMENTACAO', STR0089) // #Dados Documentais
	oView:AddSheet('CTRFOLDER', 'ROLAGEM'     , STR0058) // #Motivos da Rolagem
	oView:AddSheet('CTRFOLDER', 'ITE_A'       , STR0059, {|| ProcTree()}) // #'ITENS DA IE' - Algodão
	oView:AddSheet('CTRFOLDER', 'ITE_O'       , STR0059) // #'ITENS DA IE' - Outros	
	oView:AddSheet('CTRFOLDER', 'PEPRO'       , 'PEPRO') // #PEPRO

	/** FOLDER MASTER */
	oView:CreateHorizontalBox( "SUPERIOR" , 60, , , "CTRFOLDER", "MASTER" )
	oView:CreateHorizontalBox( "INFERIOR" , 40, , , "CTRFOLDER", "MASTER" )

	oView:CreateFolder( "GRADESUP", "SUPERIOR")
	oView:AddSheet( "GRADESUP", "PASTAN7Q", STR0052) //"Dados"
	oView:AddSheet( "GRADESUP", "PASTAN7Q02", STR0103) //"Controle"
	oView:CreateHorizontalBox( "PASTA_N7Q", 100, , , "GRADESUP", "PASTAN7Q" )
	oView:CreateHorizontalBox( "PASTA_N7Q02", 100, , , "GRADESUP", "PASTAN7Q02" )

	If !OGA710WHEN()
		oStruN7Q:SetProperty( 'N7Q_TIPCLI' , MVC_VIEW_CANCHANGE, .F.)
		oStruN7Q:SetProperty( 'N7Q_IMPORT' , MVC_VIEW_CANCHANGE, .F.)
		oStruN7Q:SetProperty( 'N7Q_IMLOJA' , MVC_VIEW_CANCHANGE, .F.)
	EndIf

	If !fWheEntEnt(oModel) .Or. !OGA710WHEN()
		oStruN7Q:SetProperty( 'N7Q_ENTENT' , MVC_VIEW_CANCHANGE, .F.)
		oStruN7Q:SetProperty( 'N7Q_LOJENT' , MVC_VIEW_CANCHANGE, .F.)
	EndIf

	oView:AddField( "VIEW_N7Q", oStruN7Q, "N7QUNICO" )
	oView:AddField( "VIEW_N7Q02", oStruN7Q02, "N7QUNICO" )
	oView:AddGrid( "VIEW_N7S", oStruN7S, "N7SUNICO" )

	///=== Remove campos do view ===/// 
	oStruN7Q:RemoveField( "N7Q_CODINE" )
	oStruN7Q:RemoveField( "N7Q_DTULAL" )
	oStruN7Q:RemoveField( "N7Q_HRULAL" )
	oStruN7S:RemoveField( "N7S_CODINE" )
	oStruN7S:RemoveField( "N7S_INCAUT" )	
	oStruN90:RemoveField( "N90_CODINE" )
	oStruN86:RemoveField( "N86_IEORIG" )
	oStruN86:RemoveField( "N86_IEDEST" )
	oStruN7S:RemoveField( "N7S_QTDNEG" )
	oStruN7S:RemoveField( "N7S_SALNEG" )
	oStruN7S:RemoveField( "N7S_OK" )

	If !lProdAlgo .AND. IsInCallStack("OGA530")
		oStruN7S:RemoveField( "N7S_QTDSOL" )
	EndIf

	oView:CreateFolder( "GRADES", "INFERIOR")
	oView:AddSheet( "GRADES", "PASTA01", STR0010) //"Cadência"

	oView:CreateHorizontalBox( "PASTA_N7S", 100, , , "GRADES", "PASTA01" )

	oView:SetOwnerView( "VIEW_N7Q", "PASTA_N7Q" )
	oView:SetOwnerView( "VIEW_N7Q02", "PASTA_N7Q02" )
	oView:SetOwnerView( "VIEW_N7S", "PASTA_N7S" )	

	oView:EnableTitleView( "VIEW_N7Q" )
	oView:EnableTitleView( "VIEW_N7Q02" )
	oView:EnableTitleView( "VIEW_N7S" )	
	
	oView:SetViewProperty("VIEW_N7S", "GRIDDOUBLECLICK", {{|oGrid,cFieldName,nLineGrid,nLineModel| DlbClickN7S(oGrid,cFieldName,nLineGrid,nLineModel)}})
	/*Fim FOLDER MASTER*/

	/*FOLDER DADOS DOCUMENTAIS*/
	oView:CreateHorizontalBox( "CABEC_DOC",   100, , , "CTRFOLDER", "DOCUMENTACAO" )
	oView:CreateFolder( "GRADEPRIN", "CABEC_DOC")

	oView:AddSheet( "GRADEPRIN", "PASTAPRINC",  STR0052) //"Dados"
	oView:AddSheet( "GRADEPRIN", "PASTAddEXP",  STR0018) //"Dados dOCUMENTACIONAIS"
	oView:AddSheet( "GRADEPRIN", "PASTADESCBL", STR0021) //"Desc. BL"
	oView:AddSheet( "GRADEPRIN", "PASTACLAEBL", STR0025) //"Cláusulas Esp. BL"
	oView:AddSheet( "GRADEPRIN", "PASTADOCUM",  STR0022) //"Documentos"
	oView:AddSheet( "GRADEPRIN", "PASTACARTA",  STR0073) //"Documentos"

	oView:CreateHorizontalBox( "PASTA_N7QDOC", 100, , , "GRADEPRIN", "PASTAPRINC" )
	oView:CreateHorizontalBox( "PASTA_N7Q2DO", 100, , , "GRADEPRIN", "PASTAddEXP" )
	oView:CreateHorizontalBox( "PASTA_N7V",    100, , , "GRADEPRIN", "PASTADESCBL" )
	oView:CreateHorizontalBox( "PASTA_N7Y",    100, , , "GRADEPRIN", "PASTACLAEBL" )
	oView:CreateHorizontalBox( "PASTA_N7X",    100, , , "GRADEPRIN", "PASTADOCUM" )
	oView:CreateHorizontalBox( "PASTA_N90",    100, , , "GRADEPRIN", "PASTACARTA" )

	oView:AddField( "VIEW_N7QDOC", oStruN7QDOC, "N7QUNICO" )
	oView:AddField( "VIEW_N7Q2DO", oStruN7Q2DO, "N7QUNICO" )
	oView:AddGrid( "VIEW_N7V",     oStruN7V,    "N7VUNICO" )
	oView:AddGrid( "VIEW_N7Y",     oStruN7Y,    "N7YUNICO" )
	oView:AddGrid( "VIEW_N7X",     oStruN7X,    "N7XUNICO" )	
	oView:AddGrid( "VIEW_N90",     oStruN90,    "N90UNICO" )	

	///=== Remove campos do Grid ===/// 
	oStruN7V:RemoveField( "N7V_CODINE" )
	oStruN7Y:RemoveField( "N7Y_CODINE" )
	oStruN7X:RemoveField( "N7X_CODINE" )

	oView:SetOwnerView( "VIEW_N7QDOC", "PASTA_N7QDOC" )
	oView:SetOwnerView( "VIEW_N7Q2DO", "PASTA_N7Q2DO" )
	oView:SetOwnerView( "VIEW_N7V",    "PASTA_N7V" )
	oView:SetOwnerView( "VIEW_N7Y",    "PASTA_N7Y" )
	oView:SetOwnerView( "VIEW_N7X",    "PASTA_N7X" )
	oView:SetOwnerView( "VIEW_N90",    "PASTA_N90" )

	oView:EnableTitleView( "VIEW_N7QDOC" )
	oView:EnableTitleView( "VIEW_N7Q2DO" )
	oView:EnableTitleView( "VIEW_N7V" ) 
	oView:EnableTitleView( "VIEW_N7Y" )
	oView:EnableTitleView( "VIEW_N7X" )  
	oView:EnableTitleView( "VIEW_N90" )  
	/*Fim FOLDER DADOS DOCUMENTAIS*/ 

	/*FOLDER ROLAGEM*/
	oView:CreateHorizontalBox( "PASTA_N7QROL", 20, , , "CTRFOLDER", "ROLAGEM" )
	oView:CreateHorizontalBox( "PASTA_N86"   , 80, , , "CTRFOLDER", "ROLAGEM" )

	oView:AddField( "VIEW_N7QROL", oStruN7QROL, "N7QUNICO" )
	oView:SetOwnerView( "VIEW_N7QROL", "PASTA_N7QROL" )
	oView:EnableTitleView( "VIEW_N7QROL" )

	oView:AddGrid ("VIEW_N86",oStruN86,"N86UNICO" )
	oView:SetOwnerView( "VIEW_N86","PASTA_N86" )
	oView:EnableTitleView( "VIEW_N86" )
	/*Fim FOLDER ROLAGEM*/ 

	/*INICIO FOLDER ITENS DA IE*/

	/*ALGODÃO - Tree, Limites de Peso e Grids Filiais, Blocos e Fardos*/		
	oView:CreateHorizontalBox( "ITENSIE_SUPERIOR" , 50, , , "CTRFOLDER", "ITE_A" )
	oView:CreateHorizontalBox( "ITENSIE_INFERIOR" , 50, , , "CTRFOLDER", "ITE_A" )

	//ITENSIE_SUPERIOR
	oView:CreateVerticalBox( 'ITEMS_DBTREE', 72, 'ITENSIE_SUPERIOR', , "CTRFOLDER", "ITE_A" )
	oView:CreateVerticalBox( 'ITEMS_LPESOS', 28, 'ITENSIE_SUPERIOR', , "CTRFOLDER", "ITE_A" ) 

	/* Tree - Detalhes da Selação de fardos */	
	oView:AddOtherObject("OTHER_PANEL", {|oPanel| OGA710TREE(oPanel)})

	/* Limites de Peso*/
	oView:AddField( "VIEW_LPESO", oStruLPS, "N7QUNICO" )
	oView:EnableTitleView('VIEW_LPESO',STR0066)

	oView:SetOwnerView("OTHER_PANEL","ITEMS_DBTREE")
	oView:SetOwnerView("VIEW_LPESO", "ITEMS_LPESOS")

	//ITENSIE_INFERIOR	
	/* Grids Filiais, Blocos e Fardos*/
	oView:CreateFolder( "FOLDER_ITENSINF", "ITENSIE_INFERIOR")
	oView:AddSheet( "FOLDER_ITENSINF", "PASTA1", STR0062) //"Filial"
	oView:AddSheet( "FOLDER_ITENSINF", "PASTA2", STR0063) //"Blocos"
	oView:AddSheet( "FOLDER_ITENSINF", "PASTA3", STR0064) //"Fardos"

	oView:CreateHorizontalBox( "BOX_PASTA1", 100, , , "FOLDER_ITENSINF", "PASTA1" )
	oView:CreateHorizontalBox( "BOX_PASTA2", 100, , , "FOLDER_ITENSINF", "PASTA2" )
	oView:CreateHorizontalBox( "BOX_PASTA3", 100, , , "FOLDER_ITENSINF", "PASTA3" )

	oView:AddOtherObject("VIEW_QFL", {|oPanel, oObj| IniBrowser(oPanel, oObj, 1)},,{|oPanel| IIF(nIndTree > 1, oBrwFil:Refresh(), nil) }) 
	oView:AddOtherObject("VIEW_QBC", {|oPanel, oObj| IniBrowser(oPanel, oObj, 2)},,{|oPanel| IIF(nIndTree > 1, oBrwBlc:Refresh(), nil) }) 
	oView:AddOtherObject("VIEW_QFD", {|oPanel, oObj| IniBrowser(oPanel, oObj, 3)},,{|oPanel| IIF(nIndTree > 1, oBrwFrd:Refresh(), nil) })

	oView:SetOwnerView( "VIEW_QFL", "BOX_PASTA1" ) 
	oView:SetOwnerView( "VIEW_QBC", "BOX_PASTA2" ) 
	oView:SetOwnerView( "VIEW_QFD", "BOX_PASTA3" )

	/* Outros - Apenas o componente dos Limites de Peso */
	oView:CreateHorizontalBox( "ITE_O_SUPERIOR" , 100, , , "CTRFOLDER", "ITE_O" )

	/* Limites de Peso*/
	oView:AddField( "V_ITE_0_LPESO", oStruLPS, "N7QUNICO" ) 
	oView:EnableTitleView('V_ITE_0_LPESO',STR0066)

	oView:SetOwnerView( "V_ITE_0_LPESO", "ITE_O_SUPERIOR" ) 

	/*FIM FOLDER ITENS DA IE*/
	
	/*FOLDER PEPRO*/
	If oStruNLN:HasField("NLN_CODINE")
        oStruNLN:RemoveField("NLN_CODINE")
        oStruNLN:RemoveField("NLN_SEQUEN")
        
        oView:CreateHorizontalBox("PASTA_NLN", 100, , , "CTRFOLDER", "PEPRO")

        oView:AddGrid("VIEW_NLN", oStruNLN, "NLNUNICO")
        oView:SetOwnerView("VIEW_NLN", "PASTA_NLN")
        oView:EnableTitleView("VIEW_NLN")
    EndIf
	/*Fim FOLDER PEPRO*/ 
	
	If !ValTipProd() .And. !lRolTotal  //Tipo commodity Algodão
		//Botão e Atalho para realizar o update dos fardinhos da IE conforme texto colado.
		oView:AddUserButton(STR0122,'', { || UpdCTxt() }, , VK_F10)//"Colar Fardos da IE"
	EndIf
	
	oView:SetAfterViewActivate({|oView|AfterVal(oView)})

	oView:SetCloseOnOk( {||.t.} )

Return( oView )

/** {Protheus.doc} PreModelo
Função que valida o modelo de dados após a confirmação
@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since:     26/07/2017
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Static Function PreModelo( oModel )
	Local lRetorno		:= .t.
	Local oView         := FwViewActive()
	local nx            := 0
	Local oModelN86     := oModel:GetModel( "N86UNICO" )

	If oModel:IsCopy()
		oModel:GetModel( 'N86UNICO' ):SetNoDeleteLine(.F.)

		For nX := 1 to oModelN86:Length()
			oModelN86:GoLine( nX )
			oModelN86:DeleteLine() //atualiza valores dos calculos também
		Next nX

		oModelN86:cleardata() // Limpa o Grid
		oModel:GetModel( 'N86UNICO' ):SetNoDeleteLine(.T.)

		lRetorno		:= .t.
	EndIf

	If oModel:IsCopy() .Or. lRolTotal
		oView:SelectFolder("CTRFOLDER",STR0017,2) //"Principal"
	EndIf

Return( lRetorno )

/** {Protheus.doc} PosModelo
Função que destinada a apresentar a mensagem de processamento e chamar o ValPosMod que irá fazer as consistências necessárias.

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Thiago Henrique Rover
@since:     12/12/2017
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Static Function PosModelo( oModel )

	Local nOperation := oModel:GetOperation()
	Local oModelN7Q  := oModel:GetModel( "N7QUNICO" )
	Local lContinua  := .t.	
	Local lVnDCOAut  := SuperGetMv('MV_AGRO210', , .F.)

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		lContinua := ValQtds( oModel,0)

		If lContinua 
			lContinua := ValidCad(oModel) // valida qtd instruida e solicitado
		EndIf       
		
		If oModel:IsCopy() 
			//quantidade instruida deve ser maior que zero e menor que a quantidade da IE de origem
			//Se grãos a qtd total da tela dos itens de grãos não poder ser diferente da qtd liquida da IE, pois ao confirmar a tela de itens de grão, este deveria atualizar o campo totl liquido da IE
			If  ValTipProd() .AND. ( oModelN7Q:GetValue("N7Q_TOTLIQ") <= 0 .OR. oModelN7Q:GetValue("N7Q_TOTLIQ") >= N7Q->N7Q_TOTLIQ ; 
				    .OR. _aRolItGrao[3] != oModelN7Q:GetValue("N7Q_TOTLIQ") )
				
				oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0189 , STR0190 + cValToChar( N7Q->N7Q_TOTLIQ ), "", "")	
				Return .F. 
				
			ElseIf oModelN7Q:GetValue("N7Q_TOTLIQ") <= 0 .OR. oModelN7Q:GetValue("N7Q_TOTLIQ") >= N7Q->N7Q_TOTLIQ 
				oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0189 , STR0192 + cValToChar( N7Q->N7Q_TOTLIQ ), "", "")	
				Return .F. 
			EndIf
		
		EndIf 

		If  lContinua .AND. (oModel:IsCopy() .Or. lRolTotal)
			lContinua := OGA710ROL(oModel)
		EndIf
	EndIf	

	//Verifica se a IE tem fardos vinculados a containers e que são de filiais diferentes
	If !ValidPARLOT(oModelN7Q) .AND. lContinua
		lContinua := .F.
	EndIf
	
	If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE) .and. TableInDic("NLN")
		//Vincular o PEPRO na IE de acordo com o vinculado no contrato
		OGX810VCtr(oModel)
		
		//Vínculo automático do PEPRO na IE
		If lVnDCOAut
			OGX810VCIE(oModel)
		EndIf
	EndIf

Return lContinua

/** {Protheus.doc} AtuRegCtr
Função que atualiza a quantidade instruida e saldo instruido
na regra fiscal do contrato.

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	claudineia.reinert
@since:     02/02/2018
@Uso: 		OGA710 - Instrução de Embarque 
*/
Static Function AtuRegCtr(oModel)
	Local nOperation := oModel:GetOperation()
	Local oModelN7S := oModel:GetModel( "N7SUNICO" )
	Local oModelN7Q := oModel:GetModel( "N7QUNICO" )
	Local cQry := ""
	Local cAliasQry := ""
	Local nX := 0
	Local nQtdIns := 0 //armazena qtd instruida em outras IE

	If .not. oModel:IsCopy() //se não for copia atualiza regras fiscais dos contratos(N9A)
		N9A->(DbSelectArea("N9A")) 
		N9A->(DbSetorder(1))

		For nX := 1 to oModelN7S:Length()
			oModelN7S:Goline( nX ) 			
			cAliasQry := GetNextAlias()
			cQry := " SELECT SUM(N7S_QTDVIN) AS QTDVIN "
			cQry += "   FROM " + RetSqlName("N7S") + " N7S "
			cQry += "  WHERE N7S_FILIAL = '" + xFilial("N7S") + "' " 
			cQry += "    AND N7S_CODINE <> '"+ oModelN7Q:GetValue("N7Q_CODINE") +"' " 
			cQry += "    AND N7S_CODCTR = '"+ oModelN7S:GetValue("N7S_CODCTR") +"' "
			cQry += "    AND N7S_ITEM = '"+ oModelN7S:GetValue("N7S_ITEM") +"' "
			cQry += "    AND N7S_SEQPRI = '"+ oModelN7S:GetValue("N7S_SEQPRI") +"' "
			cQry += "    AND D_E_L_E_T_ = ' ' "	
			cQry := ChangeQuery( cQry )	
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

			dbSelectArea(cAliasQry)
			(cAliasQry)->(dbGoTop())

			If (cAliasQry)->(!Eof()) 
				nQtdIns := (cAliasQry)->QTDVIN
			EndIf

			If N9A->(DbSeek(xFilial("N9A") + oModelN7S:GetValue("N7S_CODCTR") + oModelN7S:GetValue("N7S_ITEM")+oModelN7S:GetValue("N7S_SEQPRI")))
				RecLock("N9A",.F.)
				If nOperation == MODEL_OPERATION_DELETE
					N9A->N9A_QTDINS := (cAliasQry)->QTDVIN  //Atualiza a qtd instruida da regra fiscal
				Else
					N9A->N9A_QTDINS := (cAliasQry)->QTDVIN + oModelN7S:GetValue("N7S_QTDVIN") //Atualiza a qtd instruida da regra fiscal
				EndIf
				N9A->N9A_SDOINS := N9A->N9A_QUANT - N9A->N9A_QTDINS //Atualiza o saldo instruido da regra fiscal

				N9A->(MsUnlock())	
			EndIf
			(cAliasQry)->(DbCloseArea())
		Next nX
		N9A->(DbCloseArea())

	EndIf	

Return .T.


/** {Protheus.doc} ValidPARLOT
Função que Verifica se há fardos vinculados a Containers que são de filiais diferentes

@param: 	oModel - Modelo de dados
@return:	verdadeiro ou falso
@author: 	Equipe Agroindustria
@since:     26/07/2017
@author: 	Felipe.mendes
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Static Function ValidPARLOT(oModelN7Q)
	Local cFilDXI := ''
	Local cCont   := ''
	Local lRet    := .t.
	Local cAliasQry := ''	

	If oModelN7Q:Getvalue("N7Q_PARLOT") == "2"

		cAliasQry := GetNextAlias()

		cQry := " SELECT DXI_FILIAL,DXI_CODINE,DXI_CONTNR from " + RetSqlName("DXI") + " DXI WHERE DXI_CODINE = '"+oModelN7Q:Getvalue("N7Q_CODINE")+"' AND DXI_CONTNR <> '' ORDER BY DXI_CONTNR "

		cQry := ChangeQuery( cQry )	
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		//Inicia as variaveis para comparação
		cFilDXI	:= (cAliasQry)->DXI_FILIAL
		cCont   := (cAliasQry)->DXI_CONTNR
		//Verifica se há fardos vinculados a Containers que são de filiais diferentes
		While (cAliasQry)->(!Eof()) 

			If (cAliasQry)->DXI_CONTNR == cCont .AND. (cAliasQry)->DXI_FILIAL <> cFilDXI 
				Help(" ", 1, "OGA710PARLOT") //O campo Part Lot? não pode ser "Não" quando a IE possuir containers estufados com fardos de filiais diferentes
				lRet := .F.
				Exit
			EndIf
			cFilDXI	:= (cAliasQry)->DXI_FILIAL
			cCont   := (cAliasQry)->DXI_CONTNR

			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf

Return lRet

/** {Protheus.doc} GrvModelo
Função que chama a gravação do modelo de dados após a confirmação

@param: 	oModel - Modelo de dados
@return:	.t. - sempre verdadeiro
@author: 	Equipe Agroindustria
@since:     26/07/2017
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Static Function GrvModelo( oModel )
	Local nOperation := oModel:GetOperation()
	Local oModelN7Q  := oModel:GetModel( "N7QUNICO" )
	Local oModelN7S  := oModel:GetModel( "N7SUNICO" )
	Local cDesIE     := oModelN7Q:GetValue("N7Q_DESINE")
	Local lRet		 := .T.
	Local lSolFtAut  := SuperGetMV("MV_AGRB004",.F.,.F.)

	Begin Transaction
		Processa({|| lRet := ExecGrvMod(oModel) }, STR0104 + cDesIE ) //"  "
		
		If lRet
			//se estiver parametrizado faz solicitação de frete de forma automática
			If lSolFtAut
		    	//se tiver incoterm preenchida
		    	If AGRX570INC(oModelN7Q:GetValue("N7Q_INCOTE")) .And. !Empty(oModelN7Q:GetValue("N7Q_INCOTE")) 
					//função da solicitação de frete (fonte AGRX570.prw)
			    	lRet := AGRX570SFA(oModelN7S, oModelN7Q)	
			    EndIf
			EndIf
		EndIf	

		If !lRet
			DisarmTransaction() //rollback / desfaz tudo
		EndIf
	End Transaction

	DbSelectArea("N7Q")
	N7Q->(DbSetOrder(1))
	N7Q->(DbSeek(fWxFilial("N7Q") + oModelN7Q:GetValue("N7Q_CODINE"),.T.))
	
	If nOperation == MODEL_OPERATION_INSERT .And. lRet .And. (ValTpMerc(.F.) = "2") .and. valType(oBrwFrd) == 'O' 
	//se view esta ativa oBrwFrd existe, tratamento para REST-FLUIG(não tem view ativa)
		
		Begin Transaction
			lRetorno := XEECAP100I('1')
			If !lRetorno
				DisarmTransaction() //desfaz as transações no banco
			EndIf
		End Transaction
		
	EndIf
	
Return( lRet )

/** {Protheus.doc} ExecGrvMod
Função que grava o modelo de dados após a confirmação

@param: 	oModel - Modelo de dados
@return:	.t. - sempre verdadeiro
@author: 	Equipe Agroindustria
@since:     12/04/2018
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Static Function ExecGrvMod( oModel )
	Local nOperation := oModel:GetOperation()
	Local oModelN7S  := oModel:GetModel( "N7SUNICO" )
	Local oModelN7Q  := oModel:GetModel( "N7QUNICO" )
	Local cCodIE     := oModelN7Q:GetValue("N7Q_CODINE")
	Local cDesine    := oModelN7Q:GetValue("N7Q_DESINE")
	Local cIEOrig    := ''
	Local cDesIEOrig := ''
	Local nVlOri     := 0
	Local nX         := 0
	Local aCnts      := {}
	Local aFils      := {}
	Local cAliasN9E  := ""
	Local cQueryN9E  := ""
	Local lAlgodao   := AGRTPALGOD(oModelN7Q:GetValue('N7Q_CODPRO'))
	local aAreaN7Q   := N7Q->(GetArea())	
	Local nTam       := TamSx3("N83_SEQUEN")[1]   
	Local cSeq       := "01" 
	Local nQtdFar    := 0
	Local nPsBrut    := 0 
	Local nPsLiqu    := 0
	Local lRemFrd    := .F. //SE É REMESSA DE FARDOS
	Local lRet       := .T.

	ProcRegua(0)
	IncProc()
	
	If oModel:Activate() .And. (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)
		oModelN7Q:SetValue("N7Q_DTULAL", DDATABASE)
		oModelN7Q:SetValue("N7Q_HRULAL", TIME())
	EndIf

	// Gravar Histórico Automaticamente
	If nOperation == MODEL_OPERATION_INSERT
		AGRGRAVAHIS(,,,,{"N7Q",xFilial("N7Q")+cCodIE,"3",STR0004}) //Incluir
	elseIf nOperation == MODEL_OPERATION_UPDATE
		AGRGRAVAHIS(,,,,{"N7Q",N7Q->N7Q_FILIAL+N7Q->N7Q_CODINE,"4",STR0005}) //Alterar 
		
		If oModelN7Q:GetValue("N7Q_STATUS") == 5
			N7Q->N7Q_STATUS := 3
		EndIf

	elseIf nOperation == MODEL_OPERATION_DELETE
		AGRGRAVAHIS(,,,,{"N7Q",N7Q->N7Q_FILIAL+N7Q->N7Q_CODINE,"5",STR0006}) //Excluir
		
		 lRet := OGA710DELP()
		 If !lRet
		 	oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0218, STR0219, "", "") //STR0218 - "Falha na exclusão da IE."  STR0219 - "Essa IE possui integração com o Módulo de Exportação (EEC) e ocorreu uma falha ao tentar excluir o Processo de Exportação/Embarque."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
		 	Return .F.
		EndIf
		
	Endif
	
	If nIndTree > 0 .AND. lAlgodao .AND.; 
	   (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE .OR.;
	 	nOperation == MODEL_OPERATION_DELETE)
	 	
		DbselectArea(cAliasBloc)
		(cAliasBloc)->(DbGoTop())
		While !(cAliasBloc)->(Eof()) 
		
			lAtualizData := .F.
		
			N83->(DbSelectArea("N83")) 
			N83->(DbSetorder(3)) //N83_FILIAL+N83_CODINE+N83_CODCTR+N83_ITEM+N83_ITEREF+N83_FILORG+N83_BLOCO
			If N83->(DbSeek(FWxFilial("N83")+cCodIE+(cAliasBloc)->T_CONTRATO+(cAliasBloc)->T_CADENCIA+(cAliasBloc)->T_ITEREF+(cAliasBloc)->T_FILORG+(cAliasBloc)->T_BLOCO))
				
				If (cAliasBloc)->T_QTFRDSEL > 0 .AND. (N83->N83_FRDMAR == "2" .OR. AllTrim((cAliasBloc)->T_FRDMAR) == "2")
					lAtualizData := .T.					
				ElseIf (cAliasBloc)->T_QTFRDSEL == 0 .AND. N83->N83_FRDMAR == "2"
					lAtualizData := .T.
				EndIf				
								
			ElseIf (cAliasBloc)->T_QTFRDSEL > 0 .AND. AllTrim((cAliasBloc)->T_FRDMAR) == "2"
				lAtualizData := .T.
			EndIf
			
			If !lAtualizData
				(cAliasBloc)->(DbSkip())
				LOOP
			EndIf
		
			DbSelectArea("DXD") 
			DXD->(DbSetorder(1)) // DXD_FILIAL+DXD_SAFRA+DXD_CODIGO
			If DXD->(DbSeek((cAliasBloc)->T_FILORG+(cAliasBloc)->T_SAFRA+(cAliasBloc)->T_BLOCO))
				If RecLock("DXD", .F.)
	
					DXD->DXD_DATATU := dDataBase
					DXD->DXD_HORATU := Time()
					DXD->(MsUnLock())
				EndIf
			EndIf
			
			DbSelectArea("DXI")
			DXI->(DbSetOrder(4)) //DXI_FILIAL+DXI_SAFRA+DXI_BLOCO
			If DXI->(DbSeek((cAliasBloc)->T_FILORG+(cAliasBloc)->T_SAFRA+(cAliasBloc)->T_BLOCO))				
				While DXI->(!Eof()) .AND.;
					  DXI->DXI_FILIAL+DXI->DXI_SAFRA+DXI->DXI_BLOCO == (cAliasBloc)->T_FILORG+(cAliasBloc)->T_SAFRA+(cAliasBloc)->T_BLOCO
					
					If !AllTrim(DXI->DXI_STATUS) $ "70|80|90|100" .OR. (!Empty(AllTrim(DXI->DXI_CODINE)) .AND. DXI->DXI_CODINE != cCodIE)
						DXI->(DbSkip())
						LOOP
					EndIf
									
					If RecLock("DXI", .F.)
						DXI->DXI_DATATU := dDatabase
						DXI->DXI_HORATU := Time()
						DXI->(MsUnlock())
					EndIf
					
					DXI->(DbSkip())
				EndDo					
			EndIf
			
			(cAliasBloc)->(DbSkip())
		EndDo
	
	EndIf

	If lAlgodao .AND. nOperation == MODEL_OPERATION_DELETE 
		//DELETA OS FARDOS DA IE
		DelFarIE(cCodIE)
	EndIf

	AtuRegCtr(oModel) //Atualiza qtd e saldo regra fiscais no contrato
	
	If oModel:IsCopy()
		//SE ROLAGEM PARCIAL
		cIEOrig 	:= N7Q->N7Q_CODINE //armazena o codigo da IE de origem da rolagem
		cDesIEOrig  := N7Q->N7Q_DESINE //armazena a descrição da IE de origem da rolagem
	EndIf

	// Apenas realiza a inserção dos registros, caso seja clicado
	If nIndTree > 0 .AND. nOperation <> MODEL_OPERATION_DELETE 
		
		If valType(oBrwFrd) == 'O' //se view esta ativa oBrwFrd existe, tratamento para REST-FLUIG
			//Limpa filtros para gravar registros selecionados
			oBrwFrd:FWFilter():CleanFilter()
			oBrwFrd:CleanExFilter()
			oBrwFrd:FWFilter():DeleteFilter()
			oBrwFrd:SetFilterDefault("")
			oBrwFrd:Refresh(.T.)
		EndIf

		N83->(DbSelectArea("N83"))
		N83->(DbSetOrder(1))
		N83->(DbSeek(fWxFilial("N83") + cCodIE,.T.))
		IF !N83->( Eof() ) .And. AllTrim(N83->N83_FILIAL+N83->N83_CODINE) == AllTrim(xFilial("N83") + cCodIE)
			While AllTrim(N83->N83_FILIAL+N83->N83_CODINE) == AllTrim(xFilial("N83") + cCodIE) .AND. !N83->(Eof())	
				cSeq := N83->N83_SEQUEN
				N83->(dbSkip())
			End
			cSeq := Soma1(cSeq)
		Else
			cSeq := STRZERO(1,nTam) //gera nova sequencia para N83 caso for incluir novo registro
		Endif	

		DbselectArea(cAliasBloc)
		(cAliasBloc)->(DbGoTop())
		While !(cAliasBloc)->( Eof() ) 
			//lê a tabela temporario de bloco, que esta quebrada por bloco e regra fiscal
			N83->(DbSelectArea("N83")) 
			N83->(DbSetorder(3)) //N83_FILIAL+N83_CODINE+N83_CODCTR+N83_ITEM+N83_ITEREF+N83_FILORG+N83_BLOCO
			If N83->(DbSeek(xFilial("N83")+cCodIE+(cAliasBloc)->T_CONTRATO+(cAliasBloc)->T_CADENCIA+(cAliasBloc)->T_ITEREF+(cAliasBloc)->T_FILORG+(cAliasBloc)->T_BLOCO))
				//se registro ja existe na tabela N83
				RecLock("N83", .F.)
				
				N83->N83_DATATU := dDatabase
				N83->N83_HORATU := Time()
				
				If (cAliasBloc)->T_QTFRDSEL > 0
					//se tem quantidade para o bloco, atualiza
					N83->N83_QUANT  := (cAliasBloc)->T_QTFRDSEL
					N83->N83_PSBRUT := (cAliasBloc)->T_PSBRUSEL
					N83->N83_PSLIQU := (cAliasBloc)->T_PSLIQSEL											
					N83->N83_FRDMAR := AllTrim((cAliasBloc)->T_FRDMAR)
				Else
					//se bloco esta com quantidade zero, deleta
					N83->(dbDelete())
				EndIf
				N83->(MsUnLock())

			Else 
				//se não tem registro na N83 para o bloco e regra fiscal, inclui registro
				If (cAliasBloc)->T_QTFRDSEL > 0
					RecLock( "N83", .T. )
					N83->N83_FILIAL := xFilial("N83")
					N83->N83_CODINE := cCodIE
					N83->N83_SEQUEN := cSeq
					N83->N83_FILORG := (cAliasBloc)->T_FILORG
					N83->N83_CODCTR := (cAliasBloc)->T_CONTRATO
					N83->N83_ITEM   := (cAliasBloc)->T_CADENCIA
					N83->N83_ITEREF := (cAliasBloc)->T_ITEREF
					N83->N83_SAFRA  := (cAliasBloc)->T_SAFRA
					N83->N83_BLOCO  := (cAliasBloc)->T_BLOCO
					N83->N83_TIPO   := (cAliasBloc)->T_TIPO
					N83->N83_QUANT  := (cAliasBloc)->T_QTFRDSEL						
					N83->N83_PSBRUT := (cAliasBloc)->T_PSBRUSEL
					N83->N83_PSLIQU := (cAliasBloc)->T_PSLIQSEL																	
					N83->N83_FRDMAR := AllTrim((cAliasBloc)->T_FRDMAR)
					N83->N83_DATATU := dDatabase
					N83->N83_HORATU := Time()
						
					cSeq := Soma1(cSeq)
					N83->(MsUnLock())
				EndIf
			EndIf

			If oModel:IsCopy()
				//SE ROLAGEM PARCIAL		 		
				If N83->(DbSeek(xFilial("N83")+cIEOrig+(cAliasBloc)->T_CONTRATO+(cAliasBloc)->T_CADENCIA+(cAliasBloc)->T_ITEREF+(cAliasBloc)->T_FILORG+(cAliasBloc)->T_BLOCO))
					//se existe o registro para o bloco e regra fiscal na tabela N83 da IE de origem da rolagem
					RecLock( "N83", .F. )
					
					N83->N83_DATATU := dDatabase
					N83->N83_HORATU := Time()
					
					If N83->N83_QUANT - (cAliasBloc)->T_QTFRDSEL > 0 
						//se sobrar saldo na origem, atualiza as quantidade da origem 
						N83->N83_QUANT  := N83->N83_QUANT - (cAliasBloc)->T_QTFRDSEL							
						N83->N83_PSBRUT := N83->N83_PSBRUT - (cAliasBloc)->T_PSBRUSEL
						N83->N83_PSLIQU := N83->N83_PSLIQU - (cAliasBloc)->T_PSLIQSEL
						N83->N83_FRDMAR := AllTrim((cAliasBloc)->T_FRDMAR)

						nQtdFar += N83->N83_QUANT 
						nPsBrut += N83->N83_PSBRUT
						nPsLiqu += N83->N83_PSLIQU
					Else
						//senão deleta
						N83->(dbDelete())
					EndIf	
					N83->(MsUnLock())
				EndIf
			EndIf

			N83->(DbCloseArea())
			(cAliasBloc)->(dbSkip())
		EndDo
		
		If lAlgodao .AND. M->N7Q_TPCTR == "1" .AND. M->N7Q_TPMERC = "2" 
			// Se for algodão e IE de exportação(venda mercado externo) 
			lRemFrd := .T. //tem remessa de fardos
		EndIF

		DbselectArea( cAliFrd )
		(cAliFrd)->(DbGoTop())
		While !(cAliFrd)->( Eof() )
			//percorre a tabela da grid de fardos da IE
			DXI->(DbSelectArea("DXI")) 
			DXI->(DbSetorder(7))   
			If DXI->(DbSeek((cAliFrd)->FILORG+(cAliFrd)->SAFRA+(cAliFrd)->FARDO))
				//se encontrou o registro do fardo na DXI
				If oModel:IsCopy()  	
					// SE ROLAGEM PARCIAL
					If (cAliFrd)->OK = "OK"
						//registro esta marcado para rolagem, altera para a IE de rolagem 
						RecLock( "DXI", .F. )
						DXI->DXI_CODINE := cCodIE
						DXI->DXI_ROMSAI := ""
						DXI->(MsUnLock())
						RolMovFardo() //faz a rolagem da N9D do fardo para a IE de rolagem
					EndIf
				Else
					// NÃO É ROLAGEM
					// Atualiza o Status de Contaminante para "Não Avaliado"
					RecLock( "N7Q", .F. )
					N7Q->N7Q_STAPCT := '0'
					N7Q->(MsUnLock())

					If ( Empty(DXI->DXI_CODINE) .AND. (cAliFrd)->OK == "OK") .OR. (!Empty(DXI->DXI_CODINE) .AND. (cAliFrd)->OK != "OK" )
						//incluir(1)/retorna(2) status do fardo na DXI(DXI_STATUS)
						AGRXFNSF(IIf( (cAliFrd)->OK = "OK" , 1 , 2 ) , "IE")
					   	//registra a movimentação do fardinho(N9D)
					   	MovFardo(IIf( (cAliFrd)->OK = "OK" , .T. , .F. ), cCodIE )
					EndIf
					
					If lRemFrd .AND. !Empty(DXI->DXI_ROMFLO)
						//Para o fardo tem remessa 
						If Empty(DXI->DXI_CODINE) .AND. (cAliFrd)->OK == "OK"
							// Se estiver marcando um fardo que não está vinculado a IE
							// Atualizar vínculo nota de remessa
							OG710AAREM(.T., xFilial("N7Q"), cCodIE, M->N7Q_DESINE)
						ElseIf !Empty(DXI->DXI_CODINE) .AND. (cAliFrd)->OK != "OK" 
							// Se estiver desmarcando um fardo que está vinculado a IE
							// Atualizar vínculo nota de remessa
							OG710AAREM(.F., xFilial("N7Q"), cCodIE, M->N7Q_DESINE)
						EndIf
					EndIf

					RecLock( "DXI", .F. )
					DXI->DXI_CODINE:= IIF( (cAliFrd)->OK = "OK", cCodIE , "") //grava/limpa codigo da IE
					DXI->(MsUnLock())
				
				EndIf

			EndIF
			DXI->(DbCloseArea())
			(cAliFrd)->( dbSkip() )
		EndDo
	EndIf

	//atualiza a descrição da IE na N9I
	cQueryN9I := "   SELECT N9I.N9I_CODINE, N9I.N9I_CODINR , N9I.R_E_C_N_O_ AS Recno"
	cQueryN9I += "     FROM " + RetSqlName('N9I') + " N9I "
	cQueryN9I += "    WHERE N9I.N9I_FILIAL = '" + xFilial("N9I") + "'"
	cQueryN9I += "      AND N9I.N9I_CODINE = '" + cCodIE + "'"
	cQueryN9I += "      OR N9I.N9I_CODINR = '" + cCodIE + "'"
	cQueryN9I += "      AND N9I.D_E_L_E_T_ = ' ' "
	cAliasN9I := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryN9I), cAliasN9I, .F., .T.)

	While (cAliasN9I)->(!EoF())
		DbSelectArea(cAliasN9I)
		N9I->(DbGoTo((cAliasN9I)->Recno))

		If RecLock('N9I',.f.)
			If (cAliasN9I)->N9I_CODINE == cCodIE
				N9I->N9I_DESINE := cDesine
			EndIf
			If (cAliasN9I)->N9I_CODINR == cCodIE
				N9I->N9I_DESINR := cDesine
			EndIf
			N9I->( msUnLock() )
		Endif
		(cAliasN9I)->(DbSkip())
	EndDo
	(cAliasN9I)->(DbCloseArea())	
	
	// Retorna o saldo da comprovação do DCO
	If nOperation == MODEL_OPERATION_UPDATE
		OGX810PRN9W("1", oModel)
	EndIf
	
	lCommit := FWFormCommit( oModel )

    If  TableInDic("NLN")
    	DbSelectArea("NLN")
		NLN->(DbSetOrder(3)) //NLN_FILIAL+NLN_CODINE
	    If NLN->(DbSeek(FwxFilial("NLN")+cCodIE)) 
		    // Retorna saldo do Aviso/DCO depois da gravação, na deleção
			If lCommit .AND. nOperation == MODEL_OPERATION_DELETE
				OGX810PRN9W("1", oModel)
			EndIf
			
			// Consome o saldo da comprovação do DCO
			If lCommit .AND. nOperation != MODEL_OPERATION_DELETE
				OGX810PRN9W("2", oModel)
			EndIf
		Endif
	ENDIF
	
	If oModel:IsCopy()
		//SE ROLAGEM PARCIAL

		If lAlgodao
			// Se produto ALGODÃO, faz a ROLAGEM das notas de remessa dos fardos
			OG710ARRFR(oModelN7Q, cIEOrig)
		Else
			// Se produto GRÃOS, faz a ROLAGEM das notas de remessa 
			OG710ARGIE(oModelN7Q, cIEOrig, _aRolItGrao) 
		EndIf
		
		For nX := 1 to oModelN7S:Length()
			//le a grid da N7S
			oModelN7S:Goline( nX ) 
			//pega o valor da N7S da IE de origem
			nVlOri := Posicione("N7S",1,xFilial("N7S")+cIEOrig+FwFldGet("N7S_CODCTR")+FwFldGet("N7S_ITEM")+FwFldGet("N7S_SEQPRI"),"N7S_QTDVIN")
			N7S->(DbSelectArea("N7S")) 
			N7S->(DbSetorder(1))
			If N7S->(DbSeek(xFilial("N7S") + cIEOrig + FwFldGet("N7S_CODCTR") + FwFldGet("N7S_ITEM")+FwFldGet("N7S_SEQPRI")))
				//posiciona na N7S da IE de origem, e ajusta a quantidade
				RecLock("N7S",.F.)
				N7S->N7S_QTDVIN := nVlOri - FwFldGet("N7S_QTDVIN")
				N7S->N7S_QTDREM := N7S->N7S_QTDREM - FwFldGet("N7S_QTDREM")
				N7S->(MsUnlock())

				If aScan(aFils, FwFldGet("N7S_FILORG")) == 0 .And. N7S->N7S_QTDVIN <> nVlOri
					//Armazena o código das filiais para identificar os pedidos que sofrerão alterações
					aAdd(aFils, FwFldGet("N7S_FILORG"))
				EndIf

			EndIf
		Next nX

		//rolagem dos containers
		If lAlgodao
			//SE ALGODÃO
			//busca containers da IE de rolagem
			aCnts := OGA710Cnt(cCodIE) 
			IF Len(aCnts) > 0
				//se tiver container para rolagem
				//copia os container da IE de origem para a IE de rolagem
				OGA710CPC(cIEOrig, cCodIE, cDesine, aCnts)
				//Ecluir os containers da IE de origem
				OGA710EXC(cIEOrig, aCnts)
			EndIf
		Else 
			//SE GRÃOS
			aCnts := {}
			For nX := 1 to Len( _aRolItGrao[2]) 
				//percorre a variavel que armazena os container para seleção dos itens de rolagem de grãos
				If  _aRolItGrao[2][nX][1] == "2" 
					//Se marcado container para rolagem
					//guarda no array(aCnts) os CONTAINER para rolagem
					AADD(aCnts,_aRolItGrao[2][nX][2]) //_aRolItGrao[2][nX][2] = numero do container
				EndIf
			Next nX
			//copia os container da IE de origem para a IE de rolagem
			OGA710CPC( cIEOrig, cCodIE, cDesine, aCnts ) 
			//Ecluir os containers da IE de origem
			OGA710EXC( cIEOrig, aCnts ) 
		EndIf
		
		ajusPsIe(cIEOrig, lAlgodao, cCodIE, oModel) //Ajusta as quantidades da IE Origem
		
		If N7Q->(DbSeek(xFilial("N7Q") + cIEOrig) .AND. N7Q->N7Q_STAEXP == 3)
			//Posiciona na IE origem que tem processo de exportação gerado, para ajustar o processo de exportação e pedido de embarque
			XEECAP100I('9')
		EndIf

		//Verificar NF para cada pedido de exportação vinculado à IE de origem
		cQueryN82 := "   SELECT N82_FILORI, N82_PEDIDO, N82_CODINE "
		cQueryN82 += "     FROM " + RetSqlName('N82') + " N82 "
		cQueryN82 += "    WHERE N82.N82_FILIAL = '" + FWxFilial("N7Q") + "'"
		cQueryN82 += "      AND N82.N82_CODINE = '" + cIEOrig + "'"
		cQueryN82 += "      AND N82.D_E_L_E_T_ = ' ' "
		cAliasN82 := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryN82), cAliasN82, .F., .T.)
		
		DbSelectArea(cAliasN82)
		If (cAliasN82)->(!EoF())
			While (cAliasN82)->(!EoF()) 
				//IE origem possui pedido de exportação/embarque gerado
				//Busca o romaneio
				cQueryN9E := " SELECT DISTINCT N9E.N9E_CODROM "
				cQueryN9E += "   FROM " + RetSqlName('N9E') + " N9E "
				cQueryN9E += "  INNER JOIN " + RetSqlName('NJJ') + " NJJ "
				cQueryN9E += "     ON NJJ.NJJ_CODROM = N9E.N9E_CODROM "
				cQueryN9E += "    AND NJJ.NJJ_TIPO = '4' " //venda
				cQueryN9E += "    AND NJJ.NJJ_TIPENT = '2' " //sem pesagem
				cQueryN9E += "    AND NJJ.D_E_L_E_T_ = ' ' "
				cQueryN9E += "  WHERE N9E.N9E_FILIAL = '" + (cAliasN82)->N82_FILORI + "'"
				cQueryN9E += "    AND N9E.N9E_CODINE = '" + cIEOrig + "'"
				cQueryN9E += "    AND N9E.D_E_L_E_T_ = ' ' "
				cQueryN9E += "  ORDER BY N9E.N9E_CODROM
				cAliasN9E := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryN9E), cAliasN9E, .F., .T.)
				
				If (cAliasN9E)->(!EoF())
					While (cAliasN9E)->(!EoF()) 
						//IE origem possui o romaneio
						DbSelectArea("NJJ")
						NJJ->(DbSetorder(1)) //NJJ_FILIAL+NJJ_CODROM
						If NJJ->(DbSeek((cAliasN82)->N82_FILORI + (cAliasN9E)->N9E_CODROM) )
							If NJJ->NJJ_STAFIS == '2' .And. Posicione("N7Q",1,xFilial("N7Q")+cIEOrig,"N7Q->N7Q_NFDEVO") == "1" 
								//Romaneio possui NF gerada
								If aScan(aFils, (cAliasN82)->N82_FILORI) > 0 
									//Gera o romaneio de devolução pra filial do pedido
									MsgRun( STR0137, STR0136, {|| InsRoman((cAliasN82)->N82_FILORI,(cAliasN82)->N82_PEDIDO, cCodIE, cIEOrig, '9') } )//"AGUARDE"!###"Gerando Romaneio..."
								EndIf
							ElseIf NJJ->NJJ_STAFIS == '1'
								//Romaneio não tem NF gerada
								If N7Q->(DbSeek(xFilial("N7Q") + cIEOrig))
									If aScan(aFils, (cAliasN82)->N82_FILORI) > 0 
										//Gera o romaneio de venda pra filial do pedido
										MsgRun( STR0137, STR0136, {|| InsRoman((cAliasN82)->N82_FILORI,(cAliasN82)->N82_PEDIDO, cCodIE, cIEOrig, '4') } )//"AGUARDE"!###"Gerando Romaneio..."
									EndIf
								EndIf							
							EndIf													
						EndIf
						NJJ->(DbCloseArea())

						(cAliasN9E)->(dbSkip())
					EndDo
				EndIf
				(cAliasN9E)->(DbCloseArea())

				(cAliasN82)->(dbSkip())
			EndDo
		EndIf
		(cAliasN82)->(DbCloseArea())

		//Cancela os romaneios da filial se esta foi rolada totalmente
		CancelRoms(cIEOrig, cCodIE)
		
		RestArea(aAreaN7Q) //restaura a area da N7Q
		
		DbSelectArea("N7Q")
		N7Q->(DbSetOrder(1))
		N7Q->(DbSeek(FWxFilial("N7Q") + cCodIE)) //posiciona na IE de rolagem
		
	EndIf //fim ROLAGEM PARCIAL	

	//Recarrega os parâmetros da tela
	OGA710REG(.F.)

	/* 	Caso a instrução de embarque seja gerada pelo usuário que possui permissão para aprovar, 
	a mesma já deve ser gerada como aprovada pelo comercial. */
	IF !Empty(RetCodUsr()) .AND. MPUserHasAccess('OGA710', 25, RetCodUsr()) .And. nOperation == MODEL_OPERATION_INSERT 
		OGA710Status(1,2,STR0031)
	EndIf

	
	If !oModel:IsCopy()	
		// Caso não for rolagem parcial
		If verAssIe(oModel) .AND. ( Empty(N7Q->N7Q_STSASS) .OR.  N7Q->N7Q_STSASS == '3' )
		//Se todos os contratos da IE estiverem com NJR_STSASS = "F" então atualiza o status da IE para 1=Contrato Assinado.
			OGA710Status(1,3,STR0031)
		EndIf
	EndIf

	cTpFret:= POSICIONE('NJR',1,oModelN7S:GetValue('N7S_FILIAL')+oModelN7S:GetValue('N7S_CODCTR'),'NJR_TPFRET')

	If lCommit
		If cTpFret != "C"
 			OGA710Status(1,1,STR0256) //"Aprovação Logística Automática por Tipo de Frete do Contrato."
		EndIf
	EndIf

	If lCommit
		Processa( {|| lRet := fAjusN9A(oModel) }, STR0136, STR0246,.F.) //"AGUARDE!" ### "Ajustando Regras fiscais..."
		If !lRet
			Return .F.
		EndIf
	EndIf

	SetKey(VK_F10, nil)

Return( .T. )

/*/{Protheus.doc} OG710N7SQV
//TODO Validação When do campo N7S_QTDVIN, para validar se habilita campo para edição
@author claudineia.reinert
@since 09/07/2018
@version undefined

@type function
/*/
Function OG710WQVETG()
	Local oModel   := FwModelActive()
	Local lRet := .T.

	If oModel != Nil .AND. oModel:IsActive() //modelo esta ativo
		If !ValTipProd() .OR. ( oModel:IsCopy() .And. ValTipProd() )
			//se produto for algodão ou se for rolagem de grãos, desabilita edição do campo
			lRet := .F.
		EndIf
	EndIf

Return lRet

/** {Protheus.doc} ValTipProd()
Verifica se o Commodity é do tipo algodão, se sim, não permite alterar a quantidade vinculada da entrega.
@param: 	oGride - Gride do modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Rafael.Kleestadt
@since:     06/11/2017
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Function ValTipProd()	
	Local oN7Q     := Nil
	Local cProd    := ""
	Local lAlgodao := .F.
	Local oModel   := Nil
	
	If IsInCallStack("OGA530IE")
	
		cProd := N7Q->N7Q_CODPRO
	
	ElseIf IsInCallStack("OGA530")		
		If Empty(oModel)
			oModel := FwModelActive()			
		EndIf		
		
		If Empty(oModel)
			oModel := FwLoadModel('OGA710')
			oModel:Activate()
		EndIf
		
		oN7Q   := oModel:GetModel("N7QUNICO")
		cProd  := oN7Q:GetValue('N7Q_CODPRO')
	Else
		cProd := N7Q->N7Q_CODPRO
	EndIf

	lAlgodao := !if(Posicione("SB5",1,xFilial("SB5")+ cProd,"B5_TPCOMMO")== '2',.T.,.F.)

Return lAlgodao


/** {Protheus.doc} IniModelo
Função que valida a inicialização do modelo de dados

@param: 	oModel - Modelo de dados
@param: 	nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since:     26/07/2017
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Static Function IniModelo( oModel, nOperation )
	Local lRetorno := .t.

	nIndTree := 0
	
	If !IsInCallStack("OGA530")	
		lProdAlgo := IIf(Posicione("SB5",1,xFilial("SB5")+N7Q->N7Q_CODPRO,"B5_TPCOMMO")== '2',.T.,.F.)
	EndIf
	
	
Return( lRetorno )

/** {Protheus.doc} ActModelo
Função que incializa o modelo de dados

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since:     26/07/2017
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Static Function ActModelo( oModel )
	Local lRetorno 	 := .t.
	Local oModelN7Q  := oModel:GetModel("N7QUNICO")
	Local iCont      := 0
	Local oView      := FwViewActive()
	local nx         := 0
	Local nOperation := oModel:GetOperation()
	Local oModelN86  := oModel:GetModel("N86UNICO")	
	Local cDesine    := N7Q->N7Q_DESINE
	Local oModelN7S  := oModel:GetModel("N7SUNICO")

	If oModel:IsCopy() //Rolagem Parcial 

		cAliasQry := GetNextAlias()
		cQry := " SELECT COUNT(*) AS CONT  "
		cQry += "     FROM " + RetSqlName("N86") + " N86 "
		cQry += "    WHERE N86.N86_FILIAL = '" + xFilial('N86') + "'"
		cQry += "      AND N86.N86_IEORIG = '" + N7Q->N7Q_CODINE + "'"
		cQry += "      AND N86.D_E_L_E_T_ = ' ' "	
		cQry := ChangeQuery(cQry)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasQry, .F., .T.) 
		DbselectArea( cAliasQry )
		DbGoTop()
		If (cAliasQry)->( !Eof() )
			iCont := (cAliasQry)->CONT
		EndIf
		(cAliasQry)->(DbCloseArea())
		iCont++

		If Len(AllTrim(cDesine)) > (TamSX3("N7Q_DESINE")[1] - 4)
			cDesine := SUBSTR(AllTrim(cDesine), 1, TamSX3("N7Q_DESINE")[1] - 4)
		EndIf

		oModelN7Q:SetValue("N7Q_DESINE", AllTrim(cDesine) + "-" + StrZero(iCont,3))

		oModelN7Q:SetValue("N7Q_QTDROL", 1)							

		oModel:GetModel( 'N86UNICO' ):SetNoDeleteLine(.F.)

		For nX := 1 to oModelN86:Length()
			oModelN86:GoLine( nX )
			oModelN86:DeleteLine() //atualiza valores dos calculos também
		Next nX

		oModel:GetModel( 'N86UNICO' ):SetNoDeleteLine(.T.)

		oModelN86:ClearData() // Limpa o Grid

		For nX := 1 to oModelN7S:Length()
			oModelN7S:GoLine( nX )
			oModelN7S:SetValue("N7S_QTDDCD", 0)	
		Next nX

	EndIF

	If lRolTotal		
		If oModel:Activate()		
			oModelN7Q:setValue("N7Q_QTDROL", N7Q->N7Q_QTDROL+1)						
		EndIf			
	EndIf			

	If oModel:Activate() .And. (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)	
		oModelN7Q:SetValue("N7Q_DTULAL", DDATABASE)
		oModelN7Q:SetValue("N7Q_HRULAL", TIME())
	EndIf

	If oModel:IsCopy() .Or. lRolTotal // Rolagem Parcial ou Rolagem Total
		oModelN7Q:LoadValue("N7Q_CODORI", AllTrim(N7Q->N7Q_DESINE))
		oView:SelectFolder("CTRFOLDER", STR0017,2) //"Principal"
	EndIf
	
Return( lRetorno )

/** {Protheus.doc} OGA710VLD
Função que valida a informação digitada nos campos que utilizam a consulta na tabela SY5

@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since:     26/07/2017
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Function OGA710VLD()
	Local lRetorno := .t.

	If !Empty(&(ReadVar()))
		lRetorno := ExistCpo("SY5",&(ReadVar()))
	EndIf

Return lRetorno

/** {Protheus.doc} OGA710LIMI
Função que valida os campos de Limite Minimo e Limite Máximo

@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since:     28/07/2017
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Function OGA710LIMI()
	Local lRetorno := .t.
	Local nLimiteMin := FwFldGet("N7Q_LIMMIN")
	Local nLimiteMax := FwFldGet("N7Q_LIMMAX")

	If !Empty(nLimiteMin) .AND. !Empty(nLimiteMax) .AND. nLimiteMin > nLimiteMax
		MsgInfo(AllTrim(TitSX3("N7Q_LIMMIN")[1])+STR0014+AllTrim(TitSX3("N7Q_LIMMAX")[1])+"!",STR0015) //" não pode ser maior que o " ### "Atenção" 
		lRetorno := .f.
	EndIf

Return lRetorno


/*{Protheus.doc} OGA710RLT
Função que ativa o view na operação de alteração
@author Thiago Henrique Rover
@since 02/10/2017
@version P12
@return .T.
*/
Function OGA710RLT()

	//Função válida somente para IE do tipo Externa
	If ValTpMerc(.F.) = "1" 
		Help(" ", 1, "OGA710TIPMERC") //##Problema: Função não disponível para mercado interno. ##Solução: Esta função é especifica para mercado externo.
		Return .T.
	EndIf

	If N7Q->N7Q_TPCTR == "1"
		lRolTotal := .T.
		FwExecView('','VIEWDEF.OGA710', MODEL_OPERATION_UPDATE  ,,{|| .T.})
		lRolTotal := .F.
	Else
		MsgInfo(STR0184, STR0015) //"Não é possível realizar rolagem para Instrução do tipo Armazenagem" ### "Atenção"
		Return .F.
	EndIf

Return .T.

/*{Protheus.doc} 
Função que verifica e barra caso a quantidade à víncular ou solicitada seja maior que a quantidade disponível
@sample   	OGA710VALQ()
@param		nQtdVal - Quantidade vinculada ou Quantidade Solicitada
nTipQtd	- 1 - Quantidade vinculada, 2 - Quantidade Solicitada
@return   	.F. - Quantidade informada passou da quantidade disponível, 
.T. - Quantidade informada está de acordo com a quantidade disponível
@author   	Thiago Henrique Rover
@since    	27/07/2017
@version  	P12
*/
Function OGA710VALQ(nQtdVal,nTipQtd)
	Local oModel	 := FwModelActive()
	Local oView      := FwViewActive()	
	Local nOperation := oModel:GetOperation()
	Local oN7SUnico  := oModel:GetModel("N7SUNICO")
	Local nQtddcd    := 0
	Local nValOutIE  := 0
	Local nVlCad	 := 0	
	Local lRet       := .T.

	If  nOperation == 3 .OR. nOperation == 4 //Valida se é operação de inclusão ou alteração						
		If nQtdVal < 0   
			oModel:SetErrorMessage (,,,,,STR0085  + " " + AllTrim(Str(nQtdVal)) +"!",STR0016)  //"Quantidade informada é inválida " ### "Altere a quantidade à vincular" 
			lRet       := .F. 
		EndIf

		nVlCad		:= QTDN9ACAD(FWxFilial("N9A"),FwFldGet("N7S_CODCTR"),FwFldGet("N7S_ITEM"),FwFldGet("N7S_SEQPRI"))
		nValOutIE := RetVlCadIE(FwFldGet("N7S_CODCTR"),FwFldGet("N7S_ITEM"),FwFldGet("N7S_SEQPRI"),nTipQtd)		

		If nVlCad  < (nValOutIE + nQtdVal)  .And. !oModel:IsCopy() 
			nQtddcd := nVlCad - nValOutIE
			oModel:SetErrorMessage (,,,,,STR0013 + AllTrim(Str(nQtddcd)) +"!",STR0085)  //"Quantidade informada é superior a quantidade disponível" ### "Altere a quantidade"
			lRet       := .F.
		EndIf		

		If nQtdVal < FwFldGet("N7S_QTDREM") .And. !oModel:IsCopy()
			oModel:SetErrorMessage (,,,,,STR0166 +"!",STR0085)  //"Quantidade informada é inferior a quantidade remetida" ### "Altere a quantidade"
			lRet       := .F. 
		EndIf
		
		If lRet .and. nTipQtd	== 1
			nQtddcd := nVlCad - (nValOutIE + nQtdVal)

			If !oModel:IsCopy()
				oN7SUnico:LoadValue("N7S_QTDDCD", nQtddcd)
			Else
				oN7SUnico:LoadValue("N7S_QTDDCD", 0)
			EndIf

			If valType(oView) == 'O' .AND. oView:ACURRENTSELECT[1] == "VIEW_N7Q"  
				oView:Refresh("VIEW_N7S")
			EndIf

			//Gatilho para totais ie
			fVldN7S1(oModel)

			If valType(oView) == 'O' .AND. oView:ACURRENTSELECT[1] == "VIEW_N7Q" 
				oView:Refresh("VIEW_N7Q02")
				oView:Refresh("VIEW_N7S")
			EndIf

		EndIf	
	EndIf
Return lRet

/*{Protheus.doc} OGA710SCad - Retorna o saldo das entregas dos Ctr's da IE
@author 	Francisco Kennedy Nunes Pinheiro
@since 		31/07/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
Function OGA710SCad(cCodCtr, cItemCad, cItemReg, lInicio)

	Local nVlCad  := 0
	Local nSldCad := 0

	If lInicio	
		nVlIEM := OGA530VlIE(cCodCtr, cItemCad, cItemReg)
	Else
		nVlIEM := IIF(IsInCallStack("OGA250C"), N7S->N7S_QTDVIN, FwFldGet("N7S_QTDVIN")) + RetVlCadIE(cCodCtr, cItemCad, cItemReg)
	EndIf

	nVlCad := QTDN9ACAD(FWxFilial("N9A"),cCodCtr,cItemCad,cItemReg)

	nSldCad := nVlCad - nVlIEM 

Return nSldCad

/*{Protheus.doc} QTDN9ACAD 
Retorna a quantidade a ser considerada para a Regra fiscal na IE
@author 	claudineia.reinert	
@since 		21/05/2018
@version 	1.0
@param 		cFilCtr, caracter, Filial do contrato(NJR)
@param 		cCodCtr, caracter, Codigo do contrato
@param 		cItemCad, caracter, Item da entrega do contrato	
@param 		cItemReg, caracter, Item da regra fiscal do contrato
@return 	nQtd, number, valor da quantidade da regra fiscal
*/
Static Function QTDN9ACAD(cFilCtr,cCodCtr,cItemCad,cItemReg)
	Local nQtd := 0
	Local aArea    := GetArea()
	Local aAreaN9A := N9A->(GetArea())

	DbSelectArea("N9A")
	N9A->(dbSetorder(1)) //N9A_FILIAL + N9A_CODCTR + N9A_ITEM + N9A_SEQPRI
	If N9A->(dbSeek( cFilCtr+cCodCtr+cItemCad+cItemReg) )
		If N9A->N9A_QTDTKP > N9A->N9A_QUANT
			nQtd := N9A->N9A_QTDTKP
		Else
			nQtd := N9A->N9A_QUANT
		EndIf
	EndIf
	
	RestArea(aAreaN9A)
	RestArea(aArea)

Return nQtd

/*{Protheus.doc} RetVlCadIE - Retorna valor das cadências selecionadas em outras IEs
@author 	Francisco Kennedy Nunes Pinheiro
@since 		21/11/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
Function RetVlCadIE(cCodCtr, cItemCad,cItemReg,nTipQtd)
	Local oModel    := FwModelActive() 
	Local cCodIne   := ""
	Local nVlIEM    := 0
	Local nQtSol    := 0
	Local cFilSQL   := ""
	Local cAliasQry := GetNextAlias()
	Local oN7QUnico

	If IsInCallStack("OGA250C")
		cFilSQL   := " AND N7S.N7S_CODINE = '" + N9E->N9E_CODINE + "' " 
	Else
		oN7QUnico := oModel:GetModel("N7QUNICO")
		cCodIne   := oN7QUnico:GetValue("N7Q_CODINE")
		cFilSQL   := " AND N7S.N7S_CODINE <> '" + cCodIne + "' "
	EndIf

	//--- Qtd Instruída ---//
	cQry2 := " SELECT SUM(N7S_QTDVIN) AS QTDVIN, SUM(N7S_QTDSOL) AS QTDSOL "
	cQry2 += "   FROM " + RetSqlName("N7S") + " N7S "
	cQry2 += "  WHERE N7S.N7S_FILIAL  = '" + xFilial("N7S") + "' " 
	cQry2 += "    AND N7S.N7S_CODCTR  = '" + cCodCtr + "' " 
	cQry2 += "    AND N7S.N7S_ITEM    = '" + cItemCad + "' "
	cQry2 += "    AND N7S.N7S_SEQPRI  = '" + cItemReg + "' "
	cQry2 += cFilSQL
	cQry2 += "    AND N7S.D_E_L_E_T_ = ' ' "	

	cQry2 := ChangeQuery(cQry2)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry2),cAliasQry, .F., .T.) 
	DbselectArea( cAliasQry )
	DbGoTop()
	If (cAliasQry)->( !Eof() )

		nVlIEM := (cAliasQry)->QTDVIN	
		nQtSol := (cAliasQry)->QTDSOL		
	EndIf
	(cAliasQry)->(DbCloseArea())

	/* Se for verificação da quantidade solicitada e a quantidade solicitada na mesma cadências nas outras IEs
	for maior que a quantide vinculada na mesma cadências nas outras IEs */
	If nTipQtd == 2 
		nVlIEM := nQtSol
	EndIf

Return nVlIEM

/** {Protheus.doc} OGA250HIS
Descrição: Mostra em tela de Histórico da Instrução de Embarque

@param: 	Nil
@author: 	Janaina F B Duarte
@since: 	11/08/2017
@Uso: 		OGA710 
*/
Function OGA710HIS()
	Local cChaveI := "N7Q->("+Alltrim(AGRSEEKDIC("SIX","N7Q1",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))

	AGRHISTTABE("N7Q",cChaveA)
Return

/** {Protheus.doc} OGA710APCE
Permite aprovar/revisar certificação de IE, seguindo hierarquia de aprovação, 
para que a NF de exportação possa ser gerada com as informações de peso corretamente.  
@param: nOpcao 1-Aprovar Peso Certificado;2-Revisar Peso Certificado   
@author:    Tamyris ganzenmueller
@since:     20/12/2017
@Uso:       SIGAAGR - Originação de Grãos*/
Function OGA710APCE(nOpcao, lPerg, cMsgMemo, cCodUser, cNameUser )
	Local lOK 	   := .F. 
	Local oMsg     := .F.
	Local cTitmsg  := ""	
	Local lAntec   := .F.
	
	Default cCodUser 	:= RetCodUsr()
	Default cNameUser 	:= cUserName
	Default cMsgMemo 	:= TamSX3("NK9_MSGMEM")
	Default lPerg 		:= .T. //abre tela de pergunta
	
	/*Validações*/
	//Função válida somente para IE do tipo Externa
	If ValTpMerc(.F.) = "1" 
		Help(" ", 1, "OGA710TIPMERC") //##Problema: Função não disponível para mercado interno. ##Solução: Esta função é especifica para mercado externo.
		Return .F.
	EndIf

	If N7Q->N7Q_QTDCON <> N7Q->N7Q_QTDCOR .And. nOpcao == '1'
		MsgAlert(STR0180 + AllTrim(STR(N7Q->N7Q_QTDCOR)) + STR0181 + AllTrim(STR(N7Q->N7Q_QTDCON)) +".")//"A quantidade de Contêineres vinculados deve ser igual a quantidade de contêineres solicitados(campo Q. Contêiner pasta Itens da IE)."
		Return .F.
	EndIf

	//Opção Aprovar - Status de Peso igual a Certificado ou com peso Certificado Antecipado
	IF nOpcao == '1' .And. N7Q->N7Q_STAPCE <> '2' .And. N7Q->N7Q_STAPCE <> '3' //2-Em Certificação; 3-Certificado
		Help(" ", 1, "OGA710STAPESO") //##Problema: Status de Peso Certificado Inválido ##Solução: Instrução de Embarque deve estar com peso 'Em Certificação' ou 'Certificado'
		Return .F.
	EndIF

	//Opção Revisar - status de Peso igual a Aprovado ou com peso Certificado Antecipado
	IF nOpcao == '2' .And. !(N7Q->N7Q_STAPCE $ '234') //2-Em Certificação; 3-Certificado; 4-Aprovado
		Help(" ", 1, "OGA710REVPESO") //##Problema: Status de Peso Certificado Inválido ##Solução: Instrução de Embarque deve estar com peso 'Em Certificação' ou 'Aprovado'
		Return .F.
	EndIF

	//Opção Aprovar - Status Exp diferente de Gerado
	IF nOpcao == '1' .And. N7Q->N7Q_STAEXP <> 3 //3-Gerado
		Help(" ", 1, ".OGA710000001.") //##Problema: Status Processo Exp Inválido ##Solução:Instrução de Embarque deve estar com Processo de Exportação gerado
		Return .F.
	EndIF
	
	If !AGRTPALGOD(N7Q->N7Q_CODPRO) .And. nOpcao == '3'
		Help(" ", 1, ".OGA710000014.") //##Problema: Aprovação de Pegajosidade é valida apenas para Instruções de Algodão
		Return .T.
	EndIf

	//Opção Aprovar - status de Pegajosidade igual a Aprovado 
	IF nOpcao == '3' .And. (N7Q->N7Q_STAPCT $ '1') //1-Aprovado
		Help(" ", 1, ".OGA710000012.") //##Problema: Status de Pegajosidade Inválido ##Solução: Instrução de Embarque para Pegajosidade está aprovada
		Return .F.
	EndIF

	//Opção Aprovar
	If nOpcao == '1'

		If .Not. ValFarCnt('1')// Valida se não tem contêiner vazio e fardo ser contêiner ##Param: '1'-Aprovar peso certificado, '2'-Gerar Nf de exportação
			Return .F.
		EndIf

	EndIf
	
	//Verifica no cadastro de aprovadores do processo(OGAA760) se o usuário tem permissão de executar a ação de acordo com a faixa de tolerância de variação.
	If .Not. ValToler(nOpcao, cCodUser, cNameUser)
		Return .F.
	EndIf

	If nOpcao $ '3'
		cTitmsg  := STR0175 //#"Aprovação de Contaminante" 
	Else
		cTitmsg  := IIf(nOpcao='1',STR0108,STR0109) //#Aprovar Peso Certificado #Revisar Peso Certificado
	EndIf

	If lPerg
		/*Exibe Dialog para aprovação do peso certificado*/
		oDlg	:= TDialog():New(350,406,618,795,cTitmsg,,,,,CLR_BLACK,CLR_WHITE,,,.t.) 
		oDlg:lEscClose := .f.
	
		@ 038,008 SAY " " PIXEL
		@ 038,008 SAY STR0029 PIXEL
		@ 050,008 GET oMsg Var cMsgMemo OF oDlg Multiline Size 172,062 PIXEL 	
	
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| lOK := .T., oDlg:End() },{|| lOK := .F., oDlg:End() }) CENTERED
	
	EndIf
	
	Begin Transaction

		/*Botão OK - Atualiza as informações*/
		If lOK .OR. !lPerg

			/*Altera Status do Peso Certificado*/ 
			//nOpcao 1-Ação Aprovar -> Status 4=Aprovado
			//nOpcao 2-Ação Revisar -> Status 1=Aguardando Certificação
			RecLock("N7Q", .F. )
			N7Q->N7Q_STAPCE := IIf(nOpcao == '1','4','1')

			If nOpcao == '2' //Na Revisão, zerar a quantidade de fardos certificados
				N7Q->N7Q_QFRCER := 0
				N7Q->N7Q_QTDCER := 0
				N7Q->N7Q_PCRMCE := 0
				N7Q->N7Q_CPSFLG := "" //limpa processo workflow de certificação de peso para poder gerar uma novo na certificação dos container				
			Elseif nOpcao == '3'
				N7Q->N7Q_STAPCT := '1'
			EndIF 
			N7Q->( msUnLock() )

			If !(nOpcao == '3')
				/*Altera Status dos Containers*/ 
				//nOpcao 1-Ação Aprovar -> Containers '4=Em Certificação' ou '5=Certificados' alterados para '6=Aprovados'
				//nOpcao 2-Ação Revisar -> Containers '5=Certificados' ou '6=Aprovados' alterados para '4=Em Certificação'
				N91->(DbSelectArea("N91")) 
				N91->(DbSetorder(1))   
				If N91->(DbSeek( xFilial("N91")+N7Q->N7Q_CODINE))
					While !N91->( Eof() ) .AND. AllTrim(N91->N91_FILIAL+N91->N91_CODINE) == AllTrim(xFilial("N91") + N7Q->N7Q_CODINE)

						IF N91->N91_STATUS <= '4' //Containers que ainda não foram certificados não sofrem alteração 
							lAntec := .T. //Alerta Peso Certificado Antecipado
						Else
							RecLock( "N91", .F. )
							N91->N91_STATUS := IIf(nOpcao == '1','6','4')
							N91->(MsUnLock())
							//FUNCAO PARA ALTERA STATUS DO FARDO DO CONTAINER APROVADO
							//If nOpcao == '1' 
							  OG710SFC(N91->N91_FILIAL,N91->N91_CODINE,N91->N91_CONTNR)
							//EndIF  							  
						EndIF
						N91->(DbSkip())
					EndDo
				EndIf

				/*Alertar quando o peso Certificado for antecipado.*/
				If lAntec
					MsgAlert(STR0015 + " - " + STR0110 + _CRLF + _CRLF + STR0113) // Peso Certificado Antecipado ## Um ou mais containers não tiveram seu peso certificado
				EndIF

				/*Grava Histórico*/
				//Caso não informe a obs, será gerado automaticamente
				If Vazio(cMsgMemo) 
					cMsgMemo := if (nOpcao == '1',STR0111,STR0112) //Peso Certificado Aprovado ## Peso Certificado Revisado
				EndIf	
				AGRGRAVAHIS(,,,,{"N7Q",N7Q->N7Q_FILIAL+N7Q->N7Q_CODINE,"T", cTitmsg + '  :  ' + cMsgMemo}) //T=Atualizar

			EndIf

			/*Grava Histórico*/
			//Caso não informe a obs, será gerado automaticamente
			cMsgMemo := STR0175 //#"Aprovação de Contaminante"  

			AGRGRAVAHIS(,,,,{"N7Q",N7Q->N7Q_FILIAL+N7Q->N7Q_CODINE,"T", cTitmsg + '  :  ' + cMsgMemo}) //T=Atualizar
		EndIf

	End Transaction 

Return .T.


/** {Protheus.doc} AgrMostraStatus
Rotina para Mostrar tela com opcao para aprovar / reprovar dados

@param:     nAProv : 1 - logisdtica  2 Comercial
nOpcao : 1 - parecer logistica  2 - comercial    
nOrig  : 1 - Chamada a partir do Menu, 2 - Chamada por dentro da tela  
@author:    Equipe Agroindustria
@since:     11/08/2017
@Uso:       SIGAAGR - Originação de Grãos*/
Function AgrMostraStatus (nAprov, nOrig)
	Local nOpcao  := 2
	Local oRadio
	Local nRadio 
	Local oMsg     := .f.
	Local cMsgMemo := TamSX3("NK9_MSGMEM")
	Local cTitmsg  := if (nAprov == 1,STR0019,STR0020)  
	Local oModel   := FwModelActive()

	If nAprov == 2 .And. nOrig == 1
		If !Empty(OGA710VALID()) 
			Help( ,,"AJUDA",, cRetorno, 1, 0 ) 
			Return .F.	
		Endif
		
	Endif

	if nOrig == 2   //Se chamada por dentro da tela
		If oModel:getOperation() <> MODEL_OPERATION_UPDATE
			Help( ,,STR0026,, STR0053, 1, 0 ) //"AJUDA - Opção disponível apenas na alteração da Instrução de Embarque"
			return .F.
		EndIf
	EndIf

	if nAprov == 1
		oRadio :=  N7Q->(N7Q_STALOG)
		If N7Q->(N7Q_STALOG) == 2 // 1-Aguardando Análise 2-Aprovada 3-Reprovada	
			Help( ,,STR0026,, STR0027, 1, 0 ) //"AJUDA -instrucao de embarqe ja está aprovada."
			return .F.
		endif
	elseIf N7Q->(N7Q_STACOM) == 2 // 1-Aguardando Análise 2-Aprovada 3-Reprovada	
		oRadio :=  N7Q->(N7Q_STACOM)
		Help( ,,STR0026,, STR0027, 1, 0 ) //"AJUDA -instrucao de embarqe ja está aprovada."
		return .F.
	endif

	If .Not. N7Q->N7Q_STSASS $ '12'
		Help(" ", 1, ".OGA710000009.") //"Problema: A Instrução de Embarque possui contratos sem assinatura."
		/* Return */                   //"Solução: Realize a assinatura dos contratos com quantidade instruída antes de realizar esta ação."
	EndIf
	
	if nOrig == 2   //Se chamada por dentro da tela 
		if !oModel:Activate() .Or. !oModel:VldData() 
			aErro := oModel:GetErrorMessage()
			MsgInfo( AllToChar(aErro[6]) + CRLF +;
			AllToChar(aErro[7]) + CRLF + CRLF +;
			STR0154 + AllToChar(aErro[2]) + CRLF +;
			STR0155 + AllToChar(aErro[9]))
			Return .F.
		EndIf
	EndIf

	oDlg	:= TDialog():New(350,406,638,795,cTitmsg,,,,,CLR_BLACK,CLR_WHITE,,,.t.) 
	oDlg:lEscClose := .f.

	@ 038,008 SAY STR0028 PIXEL	
	@ 038,035 Radio oRadio VAR nRadio;
	ITEMS STR0031,;
	STR0032;
	3D SIZE 100,20 OF oDlg PIXEL 
	@ 058,008 SAY " " PIXEL
	@ 058,008 SAY STR0029 PIXEL	
	@ 070,008 GET oMsg Var cMsgMemo OF oDlg Multiline Size 172,062 PIXEL 	

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcao := 1, OGA710VlApr(oDlg, cMsgMemo, nRadio)},{|| nOpcao := 0,oDlg:End()}) CENTERED
	If nOpcao == 1

		if nRadio == 2 .or. nRadio == 1 

			If nRadio == 1 .and. Vazio(cMsgMemo)
				cMsgMemo := STR0031
			EndIf

			/*If nRadio == 1 .and. nAprov == 2 
			N7Q->(N7Q_RESPON) := cUserName
			EndIf*/

			OGA710Status(nRadio,nAprov,cMsgMemo)

			If nOrig == 2   //Se chamada por dentro da tela, grava a tela após aprovar 
				GrvModelo( oModel )
			EndIf
		Else
			Help( ,,STR0026,, STR0034, 1, 0 ) //"AJUDA - Informar Parecer."
		Endif
	Else
		return .F.
	EndIf
return .T.

/** {Protheus.doc} OGA710VlApr
Função para validar se o parecer foi informado

@author:    Equipe Agroindustria
@since:     25/09/2017
@Uso:       SIGAAGR - Originação de Grãos*/
Function OGA710VlApr(oDlg, cMsgMemo, nRadio)

	If Vazio(cMsgMemo) .and. nRadio == 2 
		Help( ,,STR0026,, STR0065, 1, 0 ) //"AJUDA - Para opção de Reprovação é necessário informar uma observação no parecer."
	Else
		oDlg:End()
	EndIf

return .T.

/** {Protheus.doc} OGA710Status
Rotina para atualizar o status da Instrucao de embarque

@param:  nAProv : 1 - aprovado  2 - reprovado 3 - Aguardando Análise 4 - Aprovado sem Assinatura
@param:  nOpcao : 1 - parecer logistica  2 - comercial 3 - Status Assinatura dos contratos   
@author:    Equipe Agroindustria
@since:     11/08/2017
@Uso:       SIGAAGR - Originação de Grãos*/
Function OGA710Status(nAprov,nOpcao,cMsgMemo)
	Local cTipo     := ""
	Local cTpOp     := ""
	Local lRetorno  := .F. 
	Local aArea   	:= GetArea()
	Local lRetEEC  	:= .T.
	Local cRet		:= ''

	Do Case
		Case nOpcao == 1
		cTipo := "L"
		Case nOpcao == 2
		cTipo := "M"
		Case nOpcao == 3
		cTipo := "A"
	EndCase

	Do Case
		Case nAprov == 1
		cTpOp := STR0031
		Case nAprov == 2
		cTpOp := STR0032
		Case nAprov == 3
		cTpOp := STR0152
		Case nAprov == 4
		cTpOp := STR0153
	EndCase

	N7Q->(DbSelectArea("N7Q")) 
	N7Q->(DbSetorder(1))   
	If N7Q-> ( DbSeek( xFilial( "N7Q" ) + N7Q->N7Q_CODINE))
		RecLock("N7Q") 
		//Objetivo: tratar status parecer logistico 		
		If nOpcao == 1 //parecer logistica
			if nAprov == 1 // Aprovar parecer logistica
				N7Q->(N7Q_STALOG) :=  2
			Else //reprovar parecer logistica
				N7Q->(N7Q_STALOG) :=  3
			EndIf
		elseIf nOpcao == 2 //parecer comercial
			If nAprov == 1 // Aprovar parecer comercial
				If ValTpMerc(.F.) == "2" .and. IsInCallStack("AgrMostraStatus")	
					lRetEEC := XEECAP100I('1') //sempre gera automatico pedido qdo aprova o comercial, independente se logistico foi ou não aprovado
				EndIf
				If lRetEEC
					N7Q->(N7Q_STACOM) :=  2
					N7Q->(N7Q_RESPON) := cUserName
				EndIf
				
				cRet := OGA710VALID()
				
				If !Empty(cRet)
					Help( ,,STR0015,, cRet, 1, 0 )//Atencao
				Endif	
				
			ElseIf nAprov == 2 //Reprovar parecer comercial
				N7Q->(N7Q_STACOM) :=  3
			Else //Voltar p/ Aguardando Análise
				N7Q->(N7Q_STACOM) :=  1
			EndIf
		Else //Aprovar contratos sem assinatura
			If nAprov == 1
				N7Q->(N7Q_STSASS) := "1" //Contrato Assinado
			Else
				N7Q->(N7Q_STSASS) := "2" //Aprovado sem Assinatura
			EndIf
		EndIf
		
		// tratar status da instrucao de embarque sendo inicial 1 - pre-instruida                
		// se aprovada por logistica e comercial será           3 - instruida,
		// se reprovada por logistica ou comnercial ficara como 2 - aguardando analise 

		// se aprovada por logistica e comercial e Sts. Assinat = 1-contrato assinado será 3 - instruida                     
		// se aprovada por logistica e comercial e Sts. Assinat = 2-aprovado sem assinatura será 3 - instruida                     
		If N7Q->(N7Q_STALOG) ==  2 .and. N7Q->(N7Q_STACOM) ==  2 .and. N7Q->(N7Q_STSASS) $ '12'	
			N7Q->N7Q_STATUS   :=  3
		elseif N7Q->(N7Q_STALOG) ==  3 .or. N7Q->(N7Q_STACOM) ==  3
			N7Q->N7Q_STATUS   :=  2
		else
			N7Q->N7Q_STATUS   :=  1
		endif
		
		N7Q->( msUnLock() ) 
		
		AGRGRAVAHIS(,,,,{"N7Q",N7Q->N7Q_FILIAL+N7Q->N7Q_CODINE,cTipo, cTpOp + '  :  ' + cMsgMemo}) //Alterar
		lRetorno := .T. //salvou a aprovação/reprovação, retorno necessario para o REST FLUIG
	EndIf

	RestArea(aArea)

return lRetorno

/*{Protheus.doc} 
Função que verifica a existencia do Porto\Aeroporto de origem no contrato
@sample   	ValPorOri()
@return   	lRetorno
@author   	rafael.kleestadt
@since    	15/08/2017
@version  	P12
*/
Function ValPorOri()
	Local lRet      := .T.
	Local oModel    := FwModelActive()
	Local oModelN7S := oModel:GetModel( "N7SUNICO" )
	Local nX        := 0

	For nX := 1 to oModelN7S:Length()
		oModelN7S:Goline( nX ) 
		If ExistCpo( "N7R", FwFldGet("N7S_CODCTR") + "1" , 1) //se existir algum porto cadastrado na N7R para o contrato
			If ExistCpo( "N7R", FwFldGet("N7S_CODCTR") + "1" + FwFldGet("N7Q_PORORI"), 1)  //verifica se porto informado existe na N7R para o contrato
				lRet := .T.
				EXIT
			Else
				lRet := .F. //se não existir retorna .F., pois o porto deve ser igual ao cadastrado na N7R
			EndIf
		EndIf
		//se para o(s) contrato(s) não existe nenhum porto cadastrado, o lRet mantem .T. inicial, pois o F3 retornará todos os portos permitindo informar qualquer um
	Next nX

	If lRet .and. !ExistCpo( "SY9", FwFldGet("N7Q_PORORI"), 1) 
		//Quando não existe nenhum porto cadastrado na N7R e o porto informado tambem não existe na SY9 
		lRet := .F.					
	EndIf

	If !lRet
		Help(" ", 1, "OGA710PORORI") //"Porto/Aeroporto de origem não relacionado ao contrato da instrução de embarque"
		Return(.F.)	
	EndIf

	If FwFldGet("N7Q_PORORI") == FwFldGet("N7Q_PORDES") 
		Help(" ", 1, "OGA710PORIGUAI") //"Porto/Aeroporto de origem e destino são iguais."
		Return(.F.)
	EndIf

Return lRet

/*{Protheus.doc} 
Função que verifica a existencia do Porto\Aeroporto de destino no contrato
@sample   	ValPorDes()
@return   	lRetorno
@author   	rafael.kleestadt
@since    	15/08/2017
@version  	P12
*/
Function ValPorDes()
	Local lRet      := .T.
	Local oModel    := FwModelActive()
	Local oModelN7S := oModel:GetModel( "N7SUNICO" )
	Local nX        := 0

	For nX := 1 to oModelN7S:Length()
		oModelN7S:Goline( nX )
		If ExistCpo( "N7R", FwFldGet("N7S_CODCTR") + "2", 1) //se existir algum porto cadastrado na N7R para o contrato
			If ExistCpo( "N7R", FwFldGet("N7S_CODCTR") + "2" + FwFldGet("N7Q_PORDES"), 1)  //verifica se porto informado existe na N7R para o contrato
				lRet := .T.
				EXIT
			Else
				lRet := .F. //se não existir retorna .F., pois o porto deve ser igual ao cadastrado na N7R
			EndIf
		EndIf
		//se para o(s) contrato(s) não existir nenhum porto cadastrado, o lRet mantem .T. inicial, pois o F3 retornará todos os portos permitindo informar qualquer um
	Next nX


	If lRet .and. !ExistCpo( "SY9", FwFldGet("N7Q_PORDES"), 1) 
		//Quando não existe nenhum porto cadastrado na N7R e o porto informado tambem não existe na SY9 
		lRet := .F.
	EndIf

	If !lRet 
		Help(" ", 1, "OGA710PORDES") //"Porto/Aeroporto de destino não relacionado ao contrato da instrução de embarque"	
		Return(.F.)
	EndIf

	If FwFldGet("N7Q_PORORI") == FwFldGet("N7Q_PORDES") 
		Help(" ", 1, "OGA710PORIGUAI") //"Porto/Aeroporto de origem e destino são iguais."
		Return(.F.)
	EndIf

Return lRet

/*{Protheus.doc} 
Função que chama a geração do Pedido de Exportação no SIGAEEC
@sample   	GeraEEC()
@return   	lRetorno
@author   	Agroindustria
@since    	12/04/2018
@version  	P12*/
Function GeraEEC(pShowMsg,cFilSel,cCodRom,cProcSel,cPedidos)
	Local lRetorno := .T.

	Begin Transaction
		lRetorno := XEECAP100I(pShowMsg,cFilSel,cCodRom,cProcSel,cPedidos)
		If !lRetorno
			DisarmTransaction() //desfaz as transações no banco
		EndIf
	End Transaction

Return lRetorno

/*{Protheus.doc} 
Função que executa a geração do Pedido de Exportação no SIGAEEC
@sample   	XEECAP100I()
@return   	lRetorno
@author   	marcos.wagner
@since    	17/08/2017
@version  	P12*/
Static Function XEECAP100I(pShowMsg,cFilSel,cCodRom,cProcSel,cPedidos)
	Local aItens     := {}
	Local aCab       := {}
	Local cQuery     := ''
	Local cPedido    := ''
	Local cSafra     := ''
	Local cCtrSf     := ''
	Local cDsProduto := ''	
	Local cCodEmbala := ''
	Local cCondPag   := ''
	Local cNCM       := ''
	Local cCodpag    := '' 
	Local nCodMoeda  := 1 
	Local cMoedaEE7  := ''
	Local nPesoLiq   := 0
	Local nQtdeNaEmb := 0
	Local nVlrUnita  := 0
	Local cOrigem    := ''
	Local cDestino   := ''
	Local cTipTra    := ''
	Local lRetorno   := .F.
	Local nPos       := 0
	Local nPosC      := 0
	Local nI         := 0
	Local nJ         := 0
	Local n2         := 0  
	Local n8         := 0
	Local nV         := 0
	Local nX         := 0
	Local nContDoc   := 0 
	Local nQtdNaEm   := 0 
	Local nPesBrUn   := 0 
	Local aFilOri    := {}
	Local aOldArea   := GetArea()	
	Local cAliasN82  := ""
	Local cAliasN7X  := ""
	Local nOperPed   := 0 //operação(inclusão/alteração) do pedido
	Local lAlgodao   := .f.
	Local cLc        := ""
	Local cAliasLc   := ""
	Local cAliasEE8  := ""
	Local cQryLc     := ""
	Local aN7X       := {}
	Local aN7Xs      := {}	
	Local aComis     := {} 	
	Local aAgCtr     := {}
	Local aItClass   := {}
	Local aloteNJM   := {}
	Local nGeraPV    := IIf (IsInCallStack("OGA250NF"),'1','2')
	Local aAreaN82 	 := N82->(GetArea())
	Local cLote      := ""
	Local cUnidPes   := posicione("SB1",1, xFilial("SB1")+N7Q->N7Q_CODPRO, "B1_UM")
	Local cClient	  := ""
	Local cLojClient  := ""
	Local cNomeClient := ""
	Local cUnidProd	  := ""
	Local cUnidPrc	  := ""
	Local lsemPexp    := .f.
	Local cObserv     := ''

	Private lMsErroAuto := .f.
	Private aN82        := {}	
	Private nQtdFard    := 0 

	Default cProcSel := ''
	Default cFilSel  := ''
	Default cPedidos := ''

	If ValTpMerc(.F.) = "1" 
		Help(" ", 1, "OGA710TIPMERC") //##Problema: Função não disponível para mercado interno. ##Solução: Esta função é especifica para mercado externo.
		Return .T.
	EndIf

	//Funcao para limpar relacionamento do pedido de exportacao e instrucao de embarque quando o pedido de exportacao nao existir 
	lsemPexp:= OGX710DN82(FwXFilial("N7Q"), N7Q->N7Q_CODINE)
	If  lsemPexp
		RecLock("N7Q",.F.)
		N7Q->N7Q_STAEXP := 2 //Incompleto
		N7Q->(MsUnlock())
	EndIf

	if N7Q->N7Q_STAEXP == 3 .and. pShowMsg != '9' //Pedido Gerado e não é alteração/ajuste
		If pShowMsg == '1'
			Help( ,,STR0026,, STR0061, 1, 0 ) //"AJUDA - "Processo de exportação já foi gerado para a Instrução de Embarque"                                                                                                                                                                                                                                                                                                                                                                                                                                                 "
		EndIf
		Return .T.
	ElseIf N7Q->N7Q_STAEXP < 3 .and. pShowMsg == '9' //pedidos não gerados e solicitado alteração/ajuste
		Help(" ", 1, "OGA710PEDEXP01")   //##Problema: Não é possivel realizar o processo de ajuste do(s) pedido(s) de embarque. A geração do(s) pedido(s) não foi iniciada ou esta incompleta. ##Solução: Conclua o processo de geração de pedido
		Return .T.
	EndIf

	If IsInCallStack("OGA250NF") //dse chamado pela confirmação do romaneio
		Pergunte('OGA710', .F.)
		__cIdioma  := cValToChar(mv_par02)
	EndIf

	DbSelectArea("NJ0")
	NJ0->(DbSetOrder(1))
	If NJ0->(DbSeek(xFilial("NJ0")+N7Q->N7Q_IMPORT+N7Q->N7Q_IMLOJA))
		cClient    := NJ0->NJ0_CODCLI
		cLojClient := NJ0->NJ0_LOJCLI
		cNomeClient := NJ0->NJ0_NOME
	EndIf

	dbSelectArea("N7S")
	N7S->(dbSetOrder(1))
	N7S->(dbSeek(xFilial("N7S")+N7Q->N7Q_CODINE))

	dbSelectArea("NJR")
	NJR->(dbSetOrder(1))
	If NJR->(dbSeek(xFilial("NJR")+N7S->N7S_CODCTR))

		cCondPag   := N7Q->N7Q_CONDPA
		cCodEmbala := NJR->NJR_CODEMB
		nVlrUnita  := IIF(NJR->NJR_VLRUNI > 0, NJR->NJR_VLRUNI, NJR->NJR_VLRBAS)
		cTES 	   := NJR->NJR_TESEST
		cMoeda     := NJR->NJR_MOEDA
		cUnidProd  := NJR->NJR_UM1PRO
		cUnidPrc   := NJR->NJR_UMPRC

		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+NJR->NJR_CODPRO))
			cDsProduto := SB1->B1_DESC
			nQtdeNaEmb := 1 //SB1->B1_QE
			cNCM       := SB1->B1_POSIPI		 	
		EndIf

		Store '' to cOrigem, cDestino, cTipTra
		dbSelectArea("SY9")
		SY9->(dbSetOrder(1))
		If SY9->(dbSeek(xFilial("SY9")+N7Q->N7Q_PORORI))
			cOrigem  := SY9->Y9_SIGLA
		EndIf
		If SY9->(dbSeek(xFilial("SY9")+N7Q->N7Q_PORDES))
			cDestino := SY9->Y9_SIGLA 
		EndIf

		dbSelectArea("SYR")
		SYR->(dbSetOrder(1))
		If SYR->(dbSeek(xFilial("SYR")+N7Q->N7Q_VIA+cOrigem+cDestino))
			cTipTra  := SYR->YR_TIPTRAN
		Else
			cTipTra  := "1"
		EndIf

		cQuery := "   SELECT N83_FILORG, N83_SAFRA, N83_CODCTR, SUM(N83_PSLIQU) AS PQUANT"
		cQuery += "     FROM " + RetSqlName('N83') + " N83 "
		cQuery += "    WHERE N83_FILIAL = '" + xFilial("N83") + "'"
		cQuery += "      AND N83_CODINE = '" + N7Q->N7Q_CODINE + "'"  
		cQuery += "      AND D_E_L_E_T_ = ' ' "
		cQuery += "      GROUP BY N83_FILORG, N83_SAFRA, N83_CODCTR"
		cQuery := ChangeQuery(cQuery)
		cAliasN83 := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN83, .F., .T.)
		If (cAliasN83)->(!EoF())
			While (cAliasN83)->(!EoF())

				nPos    := aScan( aFilOri, { |x| AllTrim( x[1] ) == AllTrim((cAliasN83)->N83_FILORG) } )
				If nPos == 0
					aAdd( aFilOri, { (cAliasN83)->N83_FILORG, (cAliasN83)->( N83_SAFRA ), (cAliasN83)->( PQUANT ), .T.,'', Posicione("N7S", 3, xFilial("N7S")+N7Q->N7Q_CODINE+(cAliasN83)->N83_FILORG, "N7S_TES")} )					
				Else
					aFilOri[nPos,3] += (cAliasN83)->( PQUANT )
				EndIf

				nPosC := aScan( aComis, { |x| AllTrim( x[1] ) == AllTrim((cAliasN83)->N83_FILORG + (cAliasN83)->( N83_CODCTR )) } )
				If nPosC == 0
					aAdd( aComis, { (cAliasN83)->N83_FILORG + (cAliasN83)->( N83_CODCTR ), (cAliasN83)->N83_FILORG , (cAliasN83)->( N83_CODCTR ), (cAliasN83)->( PQUANT ), , .T.,'' } )
				Else
					aComis[nPosC,4] += (cAliasN83)->( PQUANT )
				EndIf			

				(cAliasN83)->(dbSkip())

			EndDo
		Else
			cQuery := " Select N9A_FILORG, N7S_CODCTR, SUM(N7S_QTDVIN) QTDVIN  " 
			cQuery += " From " + RetSqlName('N9A') + " N9A "
			cQuery += " Inner Join " + RetSqlName('N7S') + " N7S "
			cQuery += "   on N9A.N9A_FILIAL = N7S_FILIAL "
			cQuery += "   And N7S.N7S_SEQPRI = N9A.N9A_SEQPRI "
			cQuery += "   And N7S.N7S_CODCTR = N9A.N9A_CODCTR  "
			cQuery += "   And N7S.N7S_ITEM = N9A.N9A_ITEM  "
			cQuery += "   And N7S.N7S_CODINE = '" + N7Q->N7Q_CODINE + "' " 
			cQuery += "   And N9A.D_E_L_E_T_ = ' '"
			cQuery += "   And N7S.D_E_L_E_T_ = ' '"		
			cQuery += " GROUP BY N9A.N9A_FILORG, N7S.N7S_CODCTR "
			cQuery := ChangeQuery(cQuery)
			cAliasSoma := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSoma, .F., .T.)
			If (cAliasSoma)->(!EoF())
				While (cAliasSoma)->(!EoF())

					If (cAliasSoma)->(QTDVIN) == 0
						(cAliasSoma)->(dbSkip())
						LOOP
					EndIf

					nPos    := aScan( aFilOri, { |x| AllTrim( x[1] ) == AllTrim((cAliasSoma)->N9A_FILORG) } )
					If nPos == 0
						cSafra := AllTrim(Posicione("NJR",1,xFilial("NJR")+(cAliasSoma)->N7S_CODCTR,"NJR_CODSAF"))
						aAdd( aFilOri, { (cAliasSoma)->N9A_FILORG, cSafra, (cAliasSoma)->( QTDVIN ), .T.,'' , Posicione("N7S", 3, xFilial("N7S")+N7Q->N7Q_CODINE+(cAliasSoma)->N9A_FILORG, "N7S_TES") } )					
					Else
						aFilOri[nPos,3] += (cAliasSoma)->( QTDVIN )						
					EndIf

					nPosC := aScan( aComis, { |x| AllTrim( x[1] ) == AllTrim((cAliasSoma)->N9A_FILORG + (cAliasSoma)->( N7S_CODCTR )) } )

					If nPosC == 0
						cCtrSf := AllTrim(Posicione("NJR",1,xFilial("NJR")+(cAliasSoma)->N7S_CODCTR,"NJR_CODCTR"))
						aAdd( aComis, { (cAliasSoma)->N9A_FILORG + (cAliasSoma)->( N7S_CODCTR ), (cAliasSoma)->N9A_FILORG , (cAliasSoma)->( N7S_CODCTR ), (cAliasSoma)->( QTDVIN ), , .T.,'' } )
					Else
						aComis[nPosC,4] += (cAliasSoma)->( QTDVIN )
					EndIf

					(cAliasSoma)->(dbSkip())
				EndDo
			EndIf
			(cAliasSoma)->(dbCloseArea())

		EndIf
		(cAliasN83)->(dbCloseArea())		

		// calular comissao para o contrato dos processos
		If  Len(aComis) > 0
			For nI := 1 to Len(aComis)
				aAdd( aAgCtr, OGX030C2(aComis[nI,2], aComis[nI,3], 0, aComis[nI,4]))
			Next NI		    
		EndIF

		aAgTot := {} //Cada dimensão representa um agente
		If  Len(aAgCtr) > 0
			For nI := 1 to Len(aAgCtr)
				For n2 := 1 to Len(aAgCtr[nI])
					If aAgCtr[nI][n2][15] $ "1|2" //tipo de comissão 0 nao integra com EEC
						nPosA := aScan( aAgTot, { |aAgTot| AllTrim( aAgTot[1] ) = aAgCtr[nI][n2][2] } )

						If nPosA == 0 
							aAdd( aAgTot, {aAgCtr[nI][n2][2], aAgCtr[nI][n2][3], aAgCtr[nI][n2][10], aAgCtr[nI][n2][1], aAgCtr[nI][n2][15], aAgCtr[nI][n2][4] })
						Else
							aAgTot[nPosA,3] += aAgCtr[nI][n2][10] 
						EndIf
					EndIf

				Next n2		
			Next nI
		EndIF

		//Verifica quais filiais já tiveram o pedido gerado
		If Len(aFilOri) > 0
			For nI := 1 to Len(aFilOri)
				cAliasN82 := GetNextAlias()
				cQuery := "   SELECT N82_FILORI, N82_PEDIDO "
				cQuery += "     FROM " + RetSqlName('N82') + " N82 "
				cQuery += "    WHERE N82.N82_FILIAL = '" + N7Q->N7Q_FILIAL + "'"
				cQuery += "      AND N82.N82_CODINE = '" + N7Q->N7Q_CODINE + "'"
				cQuery += "      AND N82.N82_FILORI = '" + aFilOri[nI,1]   + "'"
				cQuery += "      AND N82.D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN82, .F., .T.)
				If (cAliasN82)->(!EoF())
					aFilOri[nI,4] := .F. 
					aFilOri[nI,5] := (cAliasN82)->N82_PEDIDO
				EndIF 
				(cAliasN82)->(dbCloseArea())
			Next NI
		EndIF

		If Len(aFilOri) > 0
			For nI := 1 to Len(aFilOri)
				If aFilOri[nI,4] == .T.  .or.  pShowMsg == '9' //se pedido precisa ser incluido ou se for alteração/ajuste de pedido
					//Inicializando
					Store '' to cPedido, cSafra
					lMsErroAuto := .F.

					cSafra := AllTrim(aFilOri[nI,2]) 
					If aFilOri[nI,4] == .T.

						//Se informou numero do pedido, não gera novo
						If !Empty(cProcSel) 
							EXIT
						EndIf

						// Ponto de entrada inserido para controlar dados especificos do cliente 25/02/2015
						If ExistBlock("OGA710P1")
							cPedido := ExecBlock("OGA710P1",.F.,.F.,{aFilOri[nI,1],cSafra})
						EndIf
						
						nOperPed := 3 //INCLUSÃO DE PEDIDO

						If Empty(cPedido)
							cQuery := "   SELECT EE7.EE7_PEDIDO " 
							cQuery += "     FROM "+RetSqlName('EE7') + " EE7"
							cQuery += "    WHERE EE7.EE7_FILIAL = '" + aFilOri[nI,1] + "'"
							cQuery += "      AND SUBSTRING(EE7.EE7_PEDIDO,1," + AllTrim(Str(Len(cSafra))) + ") = '" + cSafra + "'"
							cQuery += "      AND EE7.D_E_L_E_T_ = ' ' "
							cQuery += " ORDER BY EE7.EE7_PEDIDO "
							cQuery := ChangeQuery(cQuery)
							cAliasQry := GetNextAlias()
							dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
							If (cAliasQry)->(!EoF())
								While (cAliasQry)->(!EoF())
	
									cPedido := AllTrim((cAliasQry)->EE7_PEDIDO)
	
									cSeq := Soma1(SubStr(cPedido,Len(cPedido)-2,3))
									cPedido := AllTrim(cSafra) + '-' + AllTrim(cSeq) 
	
									(cAliasQry)->(dbSkip())
	
								EndDo
							Else //se pedido precisa ser incluido, e não ha pedidos anteriores para a filial
								cPedido := AllTrim(cSafra) + '-' + '001'
							EndIf 
							(cAliasQry)->(dbCloseArea())
						EndIf
					Else
						//alteração/ajuste pedido
						dbSelectArea("EE7")
						EE7->(dbSetOrder(1))
						If EE7->(dbSeek(aFilOri[nI,1]+aFilOri[nI,5]))
							cPedido := AllTrim(aFilOri[nI,5]) //PEDIDO JA GERADO 
							nOperPed := 4 //ALTERAÇÃO DE PEDIDO

							//Tem pedido de exportação selecionado para alteração
							If !Empty(cProcSel) .And. (cFilSel <> aFilOri[nI,1] .Or. cProcSel <> aFilOri[nI,5])
								LOOP
							ElseIf !Empty(cFilSel) .And. cFilSel <> aFilOri[nI,1]
								LOOP
							EndIF

						ELSE
							EXIT //NÃO ENCONTROU O PEDIDO PARA A FILIAL NA TABELA EE7
						EndIf

					EndIf

					// Verifica se o pedido de exportação a ser alterado possui nota fiscal
					// Caso possua não será alterado
					If pShowMsg == '9'
						DbSelectArea("EE7")
						EE7->(dbSetOrder(1))
						If EE7->(dbSeek(aFilOri[nI,1]+cPedido))							
							DbSelectArea("SC5")
							SC5->(dbSetOrder(1))
							If SC5->(dbSeek(xFilial( "SC5")+EE7->EE7_PEDFAT))							
								If !Empty(SC5->C5_NOTA)
									LOOP								
								EndIf
							EndIf
							SC5->(dbCloseArea())
						EndIf									
						EE7->(dbCloseArea())
					EndIf

					//Estrutura Sql para buscar o código da condição de pagamento
					cQuery4 := "   SELECT SY6.Y6_COD" 
					cQuery4 += "   FROM "+ RetSqlName('SY6') + " SY6"
					cQuery4 += "   WHERE SY6.Y6_MDPGEXP = '"+ cCondPag + "'"
					cQuery4 += "   AND SY6.D_E_L_E_T_ = ' ' "
					cQuery4 := ChangeQuery(cQuery4)
					cAliasQry3 := GetNextAlias()
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery4), cAliasQry3, .F., .T.)

					If !Empty((cAliasQry3)->Y6_COD)
						cCodpag := (cAliasQry3)->Y6_COD
					EndIf

					(cAliasQry3)->(dbCloseArea())

					//Estrutura Sql para buscar o código da moeda
					cQuery5 := "   SELECT SYF.YF_MOEDA, SYF.YF_MOEFAT" 
					cQuery5 += "   FROM "+ RetSqlName('SYF') + " SYF"
					cQuery5 += "   WHERE SYF.YF_MOEFAT = "+ cValToChar(cMoeda)
					cQuery5 += "   AND SYF.D_E_L_E_T_ = ' ' "
					cQuery5 := ChangeQuery(cQuery5)
					cAliasQry4 := GetNextAlias()
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery5), cAliasQry4, .F., .T.)

					iF !Empty((cAliasQry4)->YF_MOEDA)
						nCodMoeda := (cAliasQry4)->YF_MOEFAT
						cMoedaEE7 := (cAliasQry4)->YF_MOEDA
					EndIf

					(cAliasQry4)->(dbCloseArea())

					//Cria query para trazer a primeira LC vinculada a IE
					cQryLc := " SELECT N90.N90_LC_NUM "
					cQryLc += " FROM "+ RetSqlName('N90') + " N90"
					cQryLc += " WHERE N90.N90_CODINE = '" + N7Q->N7Q_CODINE + "'"
					cQryLc += " AND N90.D_E_L_E_T_ = ' ' "
					cQryLc += " ORDER BY N90.R_E_C_N_O_ "
					cQryLc := ChangeQuery(cQryLc)
					cAliasLc := GetNextAlias()
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryLc), cAliasLc, .F., .T.)

					iF (cAliasLc)->(!EoF())
						(cAliasLc)->( dbGoTop() )
						cLc := (cAliasLc)->N90_LC_NUM
					EndIf
					(cAliasLc)->(dbCloseArea())

					aCab :={{'EE7_FILIAL', aFilOri[nI,1],                                                                  Nil},;
					{'EE7_PEDIDO', cPedido,                                                                        Nil},;
					{'EE7_IMPORT', cClient,																		   Nil},;
					{'EE7_IMLOJA', cLojClient, 																	   Nil},;
					{'EE7_IMPODE', cNomeClient, 						     									   Nil},;
					{'EE7_FORN'  , '',                                                                             Nil},;
					{'EE7_FOLOJA', '',                                                                             Nil},;
					{'EE7_RESPON', N7Q->N7Q_RESPON,                                                                Nil},;
					{'EE7_REFIMP', N7Q->N7Q_DESINE,                                                                Nil},;		
					{'EE7_LC_NUM', cLc,                                                                            Nil},;
					{'EE7_IDIOMA', __cIdioma,                                                                      Nil},;        
					{'EE7_CONDPA', cCodpag,                                                                        Nil},;               
					{'EE7_MPGEXP', cCondPag,                                                                       Nil},;                  
					{'EE7_INCOTE', N7Q->N7Q_INCOTE,                                                                Nil},;
					{'EE7_MOEDA' , cMoedaEE7,                                                                      Nil},;
					{'EE7_EMBAFI', cCodEmbala,                                                                     Nil},;            
					{'EE7_FRPPCC', 'PP',                                                                           Nil},;
					{'EE7_CALCEM', '1',                                                                            Nil},;
					{'EE7_VIA' 	 , N7Q->N7Q_VIA,                                                                   Nil},;                    
					{'EE7_ORIGEM', cOrigem,                                                                        Nil},;
					{'EE7_DEST'  , cDestino,                                                                       Nil},;
					{'EE7_PAISET', Posicione( "SY9", 1 , xFilial("SY9") + N7Q->N7Q_PORDES, "Y9_PAIS"),             Nil},;
					{'EE7_TIPTRA', cTipTra,                                                                        Nil},;
					{'EE7_INTEGR', 'S',                                                                            Nil},;
					{'EE7_EXPORT', '',                                                                             Nil},;        
					{'EE7_EXLOJA', '',                                                                             Nil},;	
					{'EE7_CONSIG', N7Q->N7Q_CONSIG,                                                                Nil},;
					{'EE7_COLOJA', N7Q->N7Q_CONLOJ,                                                                Nil},;
					{'EE7_CONSDE', N7Q->N7Q_CONDES,                                                                Nil},;
					{'EE7_BRUEMB', "2",                                                                            Nil},; //**** 1-Sim;2-Não    
					{'EE7_GPV'   , nGeraPV,                                                                        Nil},; //1-Sim;2-Não 
					{'EE7_UNIDAD', cUnidPes,                                                                       Nil},; //U. M. Peso
					{'EE7_DECPRC', TamSX3("EE8_PRECO")[2],                                                         Nil},; 
					{'EE7_DECPES', TamSX3("EE8_PSLQUN")[2],                                                        Nil},;
					{'EE7_DECQTD', TamSX3("EE8_SLDINI")[2],                                                        Nil},;
					{'ATUVIA   ' , .T.,                                                                            Nil},;
					{'ATUEMB'    , "S",                                                                            Nil};
					}

					nSeq := 1
					aItens := {}
					If pShowMsg == '9' //se ajuste pedido
						//Estrutura Sql para buscar OS ITENS JA CADASTRADOS
						cQuery := "   SELECT * " 
						cQuery += "   FROM "+ RetSqlName('EE8') + " EE8"
						cQuery += "   WHERE EE8_FILIAL = '"+ aFilOri[nI,1] +"' "
						cQuery += "   AND EE8_PEDIDO = '"+ cPedido +"' "
						cQuery += "   AND EE8_COD_I = '"+ N7Q->N7Q_CODPRO +"' "
						cQuery += "   AND EE8.D_E_L_E_T_ = ' ' "
						cQuery := ChangeQuery(cQuery)
						cAliasEE8 := GetNextAlias()
						dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasEE8, .F., .T.)

						While (cAliasEE8)->(!EoF())
							//MONTA ARRAY PARA EXCLUSÃO DO ITEM
							aIten := {{'EE8_FILIAL', (cAliasEE8)->EE8_FILIAL, Nil},;
							{'EE8_SEQUEN', (cAliasEE8)->EE8_SEQUEN, Nil},; //****
							{'EE8_COD_I' , (cAliasEE8)->EE8_COD_I , Nil},; //**** 'G001'
							{'EE8_VM_DES', (cAliasEE8)->EE8_DESC  , Nil},; //**** 'DESCRICAO'
							{'EE8_FORN'  , (cAliasEE8)->EE8_FORN  , Nil},; //**** '000001'
							{'EE8_FOLOJA', (cAliasEE8)->EE8_FOLOJA, Nil},; //**** '01'
							{'EE8_SLDINI', (cAliasEE8)->EE8_SLDINI, Nil},; //**** 10
							{'EE8_EMBAL1', (cAliasEE8)->EE8_EMBAL1, Nil},; //**** '001'
							{'EE8_QTDEM1', (cAliasEE8)->EE8_QTDEM1, Nil},; //**** Quantidade de Embalagem
							{'EE8_UNPRC' , (cAliasEE8)->EE8_UNPRC , Nil},; //**** Unidade de Medida do Contrato                     
							{'EE8_UNIDAD', (cAliasEE8)->EE8_UNIDAD, Nil},; //**** Unidade de Medida do Contrato								
							{'EE8_UNPES' , (cAliasEE8)->EE8_UNPES , Nil},; //**** Unidade de medida peso
							{'EE8_PSLQUN', (cAliasEE8)->EE8_PSLQUN, Nil},; //**** Peso Liq.Un.
							{'EE8_PRECO' , Round((cAliasEE8)->EE8_PRECO,TamSX3("EE8_PRECO")[2]) , Nil},; //**** Preco Unit. 
							{'EE8_POSIPI', (cAliasEE8)->EE8_POSIPI, Nil},;
							{'EE8_TES'   , (cAliasEE8)->EE8_TES   , Nil},;
							{'EE8_FABR'  , ''                     , Nil},;
							{'EE8_FALOJA', ''                     , Nil},;
							{'EE8_QE'    , (cAliasEE8)->EE8_QE    , Nil},; 
							{'EE8_PSBRUN', (cAliasEE8)->EE8_PSBRUN, Nil},; 										  							         
							{'EE8_LOTECT', (cAliasEE8)->EE8_LOTECT, Nil},;
							{"AUTDELETA" , "S" 		      		, Nil},; 
							{"LINPOS"    , "EE8_COD_I"      	    , (cAliasEE8)->EE8_SEQUEN}}

							AAdd(aItens, aIten)
							nSeq := VAL(Alltrim((cAliasEE8)->EE8_SEQUEN))
							(cAliasEE8)->(dbSkip())							
						EndDo

						(cAliasEE8)->(dbCloseArea())
						nSeq++
					EndIf

					lAlgodao := if(Posicione("SB5",1,xFilial("SB5")+ N7Q->N7Q_CODPRO,"B5_TPCOMMO")== '2',.T.,.F.)
					If lAlgodao //se algodão
						//funcao para quebrar os itens por tipo do algodão
						aItClass := classFard(aFilOri[nI,1], N7Q->N7Q_CODINE)

						If Len(aItClass) > 0
							For nX := 1 To Len(aItClass)

								cTipoAlgo := aItClass[nX,1]
								cLote     := aItClass[nX,2]
								nVlrUnita := aItClass[nX,3]
								nQtdFard  := aItClass[nX,4]
								nPesBrUn  := (aItClass[nX,5] /nQtdFard ) //Peso Bruto Fardos / Qtd de Embalagem
								nPesoLiq  := aItClass[nX,6] //peso liquido igual peso estoque								
								cAviso    := aItClass[nX,7]
								cDco      := aItClass[nX,8]
								cSeqDco   := aItClass[nX,9]
								cTpAvis   := aItClass[nX,10]
								nQtdNaEm  := (nPesoLiq / nQtdFard)

								aIten := {{'EE8_FILIAL', aFilOri[nI,1]    							, Nil},;
								{'EE8_SEQUEN', cValToChar(nX)   							, Nil},; //****
								{'EE8_COD_I' , N7Q->N7Q_CODPRO  							, Nil},; //**** 'G001'
								{'EE8_VM_DES', cDsProduto       							, Nil},; //**** 'DESCRICAO'
								{'EE8_FORN'  , ''   	          							, Nil},; //**** '000001'
								{'EE8_FOLOJA', ''    	          							, Nil},; //**** '01'
								{'EE8_SLDINI', ROUND(nPesoLiq,TamSX3("EE8_SLDINI")[2])	, Nil},; //****  10
								{'EE8_EMBAL1', cCodEmbala									, Nil},; //**** '001'
								{'EE8_QTDEM1', ROUND(nQtdFard, TamSX3("EE8_QTDEM1")[2])	, Nil},; //**** Quantidade de Embalagem
								{'EE8_UNPRC' , cUnidPrc         							, Nil},; //**** Unidade de Medida do Contrato                     
								{'EE8_UNIDAD', cUnidProd        							, Nil},; //**** Unidade de Medida do Contrato
								{'EE8_UNPES' , cUnidProd       							, Nil},; //**** Unidade de medida peso
								{'EE8_PSLQUN', 1                							, Nil},; //**** Peso Liq.Un.
								{'EE8_PRECO' , ROUND(nVlrUnita, TamSX3("EE8_PRECO")[2])   , Nil},; //**** Preco Unit. 
								{'EE8_POSIPI', cNCM             							, Nil},;
								{'EE8_TES'   , aFilOri[nI,6]    							, Nil},;
								{'EE8_FABR'  , ''               							, Nil},;
								{'EE8_FALOJA', ''               							, Nil},;
								{'EE8_QE'    , ROUND(nQtdNaEm, TamSX3("EE8_QE")[2])       , Nil},;
								{'EE8_PSBRUN', ROUND(nPesBrUn, TamSX3("EE8_PSBRUN")[2])   , Nil},; //**** Peso Bruto.Un.
								{"EE8_LOTECT", cLote 		                                , Nil},;
								{"EE8_LOCAL" , N7Q->N7Q_LOCAL                             , Nil},;
								{"NUMAVI"    , cAviso                                     , Nil},; //Usado para gravar a tab. N9Z
								{"NUMDCO"    , cDco                                       , Nil},; //Usado para gravar a tab. N9Z
								{"SEQDCO"    , cSeqDco                                    , Nil},; //Usado para gravar a tab. N9Z
								{"TIPALG"    , cTipoAlgo                                  , Nil},; //Usado para gravar a tab. N9Z
								{"TPAGAV"    , cTpAvis                                    , Nil},; //Usado para gravar a tab. N9Z
								{"AUTDELETA" , "N" 		                                , Nil},;
								{"LINPOS"    , "EE8_COD_I"                                , cValToChar((nSeq+nX))}}

								AAdd(aItens, aIten)
								
							Next nX
						Else
							Help(" ", 1, "OGA710PEDEXP02")   //##Problema: Erro no processamento do pedido de embarque, não há itens selecionados. ##Solução: Informe a Quantidade de Bloco/Fardos.
							Return .F.
						EndIf
					Else //se grãos										   						
						aloteNJM := OGX710GCLT(aFilOri[nI,1], cCodRom , N7Q->N7Q_FILIAL, N7Q->N7Q_CODINE) // filial, nr da ie,

						// Se for por romaneio, mesmo que não tenha lote terá apenas uma linha no aloteNJM
						// a unidade de medida do preco deverá ser a unidade de medida do produto						
						If Len(aloteNJM) > 0
							For n8 := 1 To Len(aloteNJM)
								nPesoLiq  := aloteNJM[n8,2]
								nVlrUnita := aloteNJM[n8,4]
								
								aIten := {{'EE8_FILIAL', aFilOri[nI,1]  								, Nil},;
								{'EE8_SEQUEN', cValToChar(n8)  								, Nil},;          						  
								{'EE8_COD_I' , N7Q->N7Q_CODPRO								, Nil},;           
								{'EE8_VM_DES', cDsProduto     								, Nil},;           
								{'EE8_FORN'  , ''   	        								, Nil},;           
								{'EE8_FOLOJA', ''    	        								, Nil},;           
								{'EE8_SLDINI', ROUND(nPesoLiq, TamSX3("EE8_SLDINI")[2])	, Nil},;
								{'EE8_EMBAL1', cCodEmbala     								, Nil},;           
								{'EE8_QTDEM1', 1              								, Nil},;                   
								{'EE8_UNPRC',  cUnidProd       								, Nil},;                             
								{'EE8_UNIDAD', cUnidProd      								, Nil},;                   
								{'EE8_UNPES' , cUnidProd      								, Nil},;
								{'EE8_PSLQUN', 1              								, Nil},;                   
								{'EE8_PRECO' , Round(nVlrUnita,TamSX3("EE8_PRECO")[2])	, Nil},;                   
								{'EE8_POSIPI', cNCM           								, Nil},;
								{'EE8_TES'   , aFilOri[nI, 6] 								, Nil},;
								{'EE8_FABR'  , ''             								, Nil},;
								{'EE8_FALOJA', ''             								, Nil},;
								{'EE8_QE'    , Round(nPesoLiq,TamSX3("EE8_QE")[2])	, Nil},;
								{'EE8_PSBRUN', Round(nPesoLiq,TamSX3("EE8_PSBRUN")[2])	, Nil},;
								{'EE8_LOTECT', aloteNJM[n8,1] 								, Nil},;
								{"EE8_LOCAL" , N7Q->N7Q_LOCAL 								, Nil},;
								{"NUMAVI", aloteNJM[n8,5]                                     , Nil},; //Usado para gravar a tab. N9Z
								{"NUMDCO", aloteNJM[n8,6]                                     , Nil},; //Usado para gravar a tab. N9Z
								{"SEQDCO", aloteNJM[n8,7]                                     , Nil},; //Usado para gravar a tab. N9Z
								{"AUTDELETA" , "N" 		    								, Nil},;		      						          
								{"LINPOS"    , "EE8_COD_I"    								, cValToChar(n8)}}							          
								AAdd(aItens, aIten)
							Next n8						
						
						Else
						 
							aItClass := OGX710QIGRAO(aFilOri[nI,1], N7Q->N7Q_CODINE, cClient, cLojClient, aFilOri[nI, 6], N7Q->N7Q_TIPCLI )	
							
							// Quando está integrando através da Instrução SEM ROMANEIO
							// O valor unitário do contrato está por unidade de medida de preço
							// A função OGX710QIGRAO ja retorna o preço na unidade de medida do produto, então enviar para EEC unidade de preço do produto
							For n8 := 1 To Len(aItClass)

									nPesoLiq   := aItClass[n8,5]
									nVlrUnita  := aItClass[n8,6]
								
									aIten := {{'EE8_FILIAL', aFilOri[nI,1]  					, Nil},;
									{'EE8_SEQUEN', cValToChar(n8)       						, Nil},; //****
									{'EE8_COD_I' , N7Q->N7Q_CODPRO								, Nil},; //**** 'G001'
									{'EE8_VM_DES', cDsProduto     								, Nil},; //**** 'DESCRICAO'
									{'EE8_FORN'  , ''   	        							, Nil},; //**** '000001'
									{'EE8_FOLOJA', ''    	        							, Nil},;           //**** '01'
									{'EE8_SLDINI', Round(nPesoLiq,TamSX3("EE8_SLDINI")[2])		, Nil},;           //**** 10
									{'EE8_EMBAL1', cCodEmbala    								, Nil},;           //**** '001'
									{'EE8_QTDEM1', 1              								, Nil},;           //****                       Quantidade de Embalagem
									{'EE8_UNPRC',  cUnidProd       								, Nil},;           //****                       Unidade de Medida do Contrato                     
									{'EE8_UNIDAD', cUnidProd      								, Nil},;           //****                       Unidade de Medida do Contrato
									{'EE8_UNPES' , cUnidProd      								, Nil},;            //****                 Unidade de medida peso
									{'EE8_PSLQUN', 1              								, Nil},;           //**** 200                   Peso Liq.Un.
									{'EE8_PRECO' , Round(nVlrUnita,TamSX3("EE8_PRECO")[2])      , Nil},;           //****                       Preco Unit. 
									{'EE8_POSIPI', cNCM           								, Nil},;
									{'EE8_TES'   , aFilOri[nI, 6] 								, Nil},;
									{'EE8_FABR'  , ''             								, Nil},;
									{'EE8_FALOJA', ''             								, Nil},;
									{'EE8_QE'    , Round(nPesoLiq,TamSX3("EE8_QE")[2])			, Nil},;
									{'EE8_PSBRUN', Round(nPesoLiq,TamSX3("EE8_PSBRUN")[2])		, Nil},;          //****                 Peso Bruto.Un.
									{"EE8_LOTECT", cLote          								, Nil},;    
									{"EE8_LOCAL" , N7Q->N7Q_LOCAL 								, Nil},;    
									{"NUMAVI"	 , aItClass[n8,2]                            	, Nil},; //Usado para gravar a tab. N9Z
									{"NUMDCO"	 , aItClass[n8,3]                            	, Nil},; //Usado para gravar a tab. N9Z
									{"SEQDCO"	 , aItClass[n8,4]                           	, Nil},; //Usado para gravar a tab. N9Z
									{"AUTDELETA" , "N" 		    								, Nil},;
									{"LINPOS"    , "EE8_COD_I"    								, cValToChar(n8)}}
									AAdd(aItens, aIten)

								Next n8

						EndIf
					EndIf
					//Array para receber dados das tabelas auxiliares
					aAux := {}

					//Array para receber dados da tabela EEN – Notifys do processo (Relação 1:N com o Embarque)
					aNotifys := {} //Multidimensional – 1:N

					//Cada registro é uma dimensão do array:
					//NOTIFY - Registro 1
					aNotify := {}
					aAdd(aNotify, {"EEN_IMPORT", N7Q->N7Q_CODNT1, Nil}) 
					aAdd(aNotify, {"EEN_IMLOJA", N7Q->N7Q_LOJNT1 , Nil})
					aAdd(aNotify, {"EEN_IMPODE", N7Q->N7Q_DESNT1 , Nil})
					aAdd(aNotify, {"EEN_ENDIMP", N7Q->N7Q_ENDNT1 , Nil})
					aAdd(aNotify, {"EEN_END2IM", N7Q->N7Q_EN2NT1 , Nil})

					//Adiciona registro na lista de registros
					aAdd(aNotifys, aNotify)
					//NOTIFY -----------------------

					//ALSO NOTIFY - Registro 2
					aNotify := {}
					aAdd(aNotify, {"EEN_IMPORT", N7Q->N7Q_CODNT2, Nil}) 
					aAdd(aNotify, {"EEN_IMLOJA", N7Q->N7Q_LOJNT2 , Nil})
					aAdd(aNotify, {"EEN_IMPODE", N7Q->N7Q_DESNT2 , Nil})
					aAdd(aNotify, {"EEN_ENDIMP", N7Q->N7Q_ENDNT2 , Nil})
					aAdd(aNotify, {"EEN_END2IM", N7Q->N7Q_EN2NT2 , Nil})

					//Adiciona registro na lista de registros
					aAdd(aNotifys, aNotify)
					//ALSO NOTIFY -----------------------

					//Adiciona na estrutura de tabelas adicionais no formato {“ALIAS” + “CONTEUDO”} 
					aAdd(aAux, {"EEN", aNotifys})

					// *************************************************************************************************
					//Array para receber dados da tabela EXB – Agenda de documentos (Relação 1:N com o Embarque)
					nContDoc := 0

					cAliasN7X := GetNextAlias()
					cQuery := "   SELECT N7X_CODDOC, N7X_DESDOC, N7X_QTDORI, N7X_QTDCOP "
					cQuery += "     FROM " + RetSqlName('N7X') + " N7X "
					cQuery += "    WHERE N7X.N7X_FILIAL = '" + xFilial( 'N7X' )  + "'"
					cQuery += "      AND N7X.N7X_CODINE = '" + N7Q->N7Q_CODINE + "'"
					cQuery += "      AND N7X.D_E_L_E_T_ = ' ' "
					cQuery := ChangeQuery( cQuery )
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN7X, .F., .T.)
					while (cAliasN7X)->(!EoF())

						aN7X := {}
						nContDoc++
						aAdd(aN7X, {"EXB_CODATV", (cAliasN7X)->N7X_CODDOC, Nil})
						aAdd(aN7X, {"EXB_TIPO"  ,'1'                     , Nil}) //1=Ativo;2=Histórico
						aAdd(aN7X, {"EXB_OBS"   , cValToChar( (cAliasN7X)->N7X_QTDORI) + " Original(is) / "+ cValToChar((cAliasN7X)->N7X_QTDCOP) + " Cópia(s)", Nil})
						aAdd(aN7X, {"EXB_FLAG"  , '1'                    , Nil}) //Enviar sempre “1” (fixo)
						aAdd(aN7X, {"EXB_ORDEM" , cValToChar(nContDoc)   , Nil}) //Enviar um sequencial de acordo com a quantidade de documentos incluídos

						//Adiciona registro na lista de registros
						aAdd(aN7Xs, aN7X)

						(cAliasN7X)->( dbSkip() )
					EndDo
					(cAliasN7X)->(dbCloseArea())						

					//Adiciona na estrutura de tabelas adicionais no formato {“ALIAS” + “CONTEUDO”}
					If Len(aN7Xs) >= 1  
						aAdd(aAux, {"EXB", aN7Xs})
					EndIf

					//Array multidimensional com dados do Agente
					aAgente  := {} 
					aAgentes := {}
					For nV := 1 to Len(aAgTot)
						If aAgTot[nV][4] = aFilOri[nI,1]
							aAdd(aAgente, {"EEB_FILIAL", aFilOri[nI,1], Nil}) //Código da filial
							aAdd(aAgente, {"EEB_PEDIDO", cPedido	  , Nil})
							aAdd(aAgente, {"EEB_CODAGE", aAgTot[nV][2], Nil}) //Código do Agente	
							aAdd(aAgente, {"EEB_TIPOAG", aAgTot[nV][6], Nil}) //Tipo de Agente	
							aAdd(aAgente, {"EEB_TIPCOM", aAgTot[nV][5], Nil}) //Tipo de Comissão que vem do contrato 1 ou 2 apenas	
							aAdd(aAgente, {"EEB_TIPCVL", AvKey("1", "EEB_TIPCVL"), Nil}) //Tipo de Valor de Comissão	
							aAdd(aAgente, {"EEB_VALCOM", aAgTot[nV][3], Nil}) //Valor da Comissão (neste caso o tipo é percentual)
							aAdd(aAgente, {"EEB_REFAGE", N7Q->N7Q_DESINE, Nil})//Referência
							aAdd(aAgentes, aAgente)
							aAgente  := {}						
						EndIf
					Next nV				

					aAdd(aAux, {"EEB", aAgentes})									

					// *************************************************************************************************
					// Ponto de entrada inserido para controlar dados especificos do cliente 25/02/2015
					If ExistBlock("OGA710P2")
						aRetPe := ExecBlock("OGA710P2",.F.,.F.,{aCab,aItens,aAux})
						If ValType(aRetPe) == "A" .And. Len(aRetPe) == 3 .And. ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A" .And. ValType(aRetPe[3]) == "A"
							aCab    := aClone(aRetPe[1])
							aItens  := aClone(aRetPe[2])
							aAux  	:= aClone(aRetPe[3])
						EndIf
					EndIf
					
					If pShowMsg == '9'
						Processa({|lEnd| IntegraEEC(aCab,aItens,nOperPed,cPedido,aAux) },STR0081 + cPedido + STR0047 + aFilOri[nI,1] ) //"Ajustando Pedido de Embarque"
					Else
						Processa({|lEnd| IntegraEEC(aCab,aItens,nOperPed,cPedido,aAux) },STR0041 + cPedido + STR0047 + aFilOri[nI,1]) //"Gerando Pedido de Embarque"
					EndIf

					If !lMsErroAuto
						lRetorno := .T.
						If Empty(cPedidos)
							cPedidos := AllTrim(EE7->EE7_PEDIDO) + STR0047 + AllTrim(EE7->EE7_FILIAL)
						Else
							cPedidos += _CRLF + AllTrim(EE7->EE7_PEDIDO) + STR0047 + AllTrim(EE7->EE7_FILIAL)
						EndIf

						If N7Q->N7Q_QTDCER > 0 
							//Envia os conteineres aprovados aos pedidos de embarque gerados.
							IntCnt(aFilOri[nI,1], N7Q->N7Q_CODINE, nOperPed, Posicione("EEC",14,aFilOri[nI,1] + cPedido,"EEC_PREEMB"))
						EndIf
					Else
							if !__lAutomato
							MostraErro()
					    EndIf		
					EndIf
				EndIF

			Next nI

			If pShowMsg == '9' //AJUSTE/ALTERAÇÃO PEDIDO
				cAliasN82 := GetNextAlias()
				//procura se há filiais que não estão no ajuste(aFilOri) e exclui os pedidos
				cQuery := "   SELECT N82_FILORI, N82_PEDIDO "
				cQuery += "     FROM " + RetSqlName('N82') + " N82 "
				cQuery += "    WHERE N82.N82_FILIAL = '" + N7Q->N7Q_FILIAL + "'"
				cQuery += "      AND N82.N82_CODINE = '" + N7Q->N7Q_CODINE + "'"
				cQuery += "      AND N82.D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN82, .F., .T.)
				while (cAliasN82)->(!EoF())
					nPos := aScan( aFilOri, { |x| AllTrim( x[1] ) == AllTrim((cAliasN82)->N82_FILORI) } )
					If nPos = 0
						OGA710DELP((cAliasN82)->N82_FILORI,(cAliasN82)->N82_PEDIDO) //DELETA O PEDIDO
					EndIf

					(cAliasN82)->( dbSkip() )
				EndDo
				(cAliasN82)->(dbCloseArea())	
			EndIf 		

		EndIf 

		For nI := 1 to Len(aN82)
			dbSelectArea("N82")
			N82->(dbSetOrder(1))
			If N82->(dbSeek(N7Q->N7Q_FILIAL+N7Q->N7Q_CODINE+PADR( aN82[nI][2], TamSx3('N82_PEDIDO')[1], '' )+aN82[nI][1]))
				RecLock("N82", .F.)
			Else
				RecLock("N82", .T.)
			EndIf

			cSeq :=  GetSXENum("N82","N82_ITEM")
			ConfirmSX8()

			N82->N82_FILIAL := N7Q->N7Q_FILIAL
			N82->N82_CODINE := N7Q->N7Q_CODINE
			N82->N82_DESINE := N7Q->N7Q_DESINE
			N82->N82_ITEM	:= cSeq
			N82->N82_PEDIDO := aN82[nI][2]
			N82->N82_FILORI := aN82[nI][1]
			N82->N82_CODPRO := N7Q->N7Q_CODPRO
			N82->N82_UNIMED := N7Q->N7Q_UNIMED
			N82->N82_CODENT := N7Q->N7Q_IMPORT
			N82->N82_LOJENT := N7Q->N7Q_IMLOJA
			N82->N82_QNTFAR := N7Q->N7Q_TOTFAR
			N82->N82_STATUS := '1'
			N82->N82_STAPES := '1'
			N82->N82_STAQUA := '1'
			N82->N82_MOEDA  := nCodMoeda
			N82->(MsUnlock())

			aEE8 := aN82[nI][3]

			For nJ := 1 to Len(aEE8)

				nPos   := AScan( aEE8[nJ], {|x| AllTrim(x[1]) == "AUTDELETA" } )
				If nPos > 0
					If  aEE8[nJ][nPos][2] == 'S'
						LOOP
					EndIf
				EndIf

				nPos   := AScan( aEE8[nJ], {|x| AllTrim(x[1]) == "EE8_SEQUEN" } )
				cSequ  := IIf(nPos > 0, aEE8[nJ][nPos][2], '')

				nPos   := AScan( aEE8[nJ], {|x| AllTrim(x[1]) == "EE8_COD_I" } )
				cCod_I := IIf(nPos > 0, aEE8[nJ][nPos][2], '')

				nPos    := AScan( aEE8[nJ], {|x| AllTrim(x[1]) == "NUMAVI" } )
				cNumAvi := IIf(nPos > 0, aEE8[nJ][nPos][2], '')

				nPos    := AScan( aEE8[nJ], {|x| AllTrim(x[1]) == "NUMDCO" } )
				cNumDCO := IIf(nPos > 0, aEE8[nJ][nPos][2], '')

				nPos    := AScan( aEE8[nJ], {|x| AllTrim(x[1]) == "SEQDCO" } )
				cSeqDCO := IIf(nPos > 0, aEE8[nJ][nPos][2], '')

				nPos    := AScan( aEE8[nJ], {|x| AllTrim(x[1]) == "TIPALG" } )
				cTipAlg := IIf(nPos > 0, aEE8[nJ][nPos][2], '')

				nPos    := AScan( aEE8[nJ], {|x| AllTrim(x[1]) == "TPAGAV" } )
				cTpAgAv := IIf(nPos > 0, aEE8[nJ][nPos][2], '')

				//Ajusta as variaveis conforme estrutura de dados
				cSequ := PADR( cSequ, TamSx3("N9Z_SEQUEN")[1])
				cPed := PADR( aN82[nI][2], TamSx3("N9Z_PEDIDO")[1])

				dbSelectArea("N9Z")
				N9Z->(dbSetOrder(1))
				If N9Z->(dbSeek(aN82[nI][1] + cPed + cSequ + cCod_I ))
					RecLock("N9Z",.F.)
				Else
					RecLock("N9Z",.T.)

					N9Z->N9Z_FILIAL := aN82[nI][1]
					N9Z->N9Z_PEDIDO := cPed
					N9Z->N9Z_SEQUEN := cSequ
					N9Z->N9Z_COD_I  := cCod_I

				EndIf

				N9Z->N9Z_FILORI := N7Q->N7Q_FILIAL
				N9Z->N9Z_CODINE := N7Q->N7Q_CODINE

				N9Z->N9Z_NUMAVI := cNumAvi
				N9Z->N9Z_NUMDCO := cNumDCO
				N9Z->N9Z_SEQDCO := cSeqDCO

				N9Z->N9Z_TIPALG := cTipAlg
				If .Not. Empty(cNumAvi)
					If Empty(cTpAgAv)
						cTpAgAv := cTipAlg
					EndIf
				Else
					cTpAgAv := ''
				EndIf

				N9Z->N9Z_TPAGAV := cTpAgAv

				If !Empty(cNumAvi)

					cObserv := getObsInd(cNumAvi, cClient, cLojClient , IIf(!Empty(cTpAgAv),cTpAgAv,cTipAlg) )
					
					N9Z->N9Z_OBSERV := cObserv

				EndIf
				N9Z->(MsUnlock())
			Next nJ
		Next nI

		If Len(aN82) = Len(aFilOri) .And. !Empty(aFilOri)
			RecLock("N7Q",.F.)
			N7Q->N7Q_STAEXP := 3 //Gerado
			N7Q->(MsUnlock())	
			
			GrvPed() //Grava pedidos no campo N7Q->N7Q_PEDEXP

			If Empty(cProcSel) .AND. !Empty(cPedidos)
				MsgInfo(cPedidos, STR0040) //"Contrato Confirmado com Sucesso!!!"###"Confirmação do Contrato"
			EndIf		
		Else
			//não gerou processo exportação para todas as filiais
			RecLock("N7Q",.F.)
			N7Q->N7Q_STAEXP := 2 //Incompleto
			N7Q->(MsUnlock())
			If !IsInCallStack("AgrMostraStatus")
				OGA710Status(3,2,STR0030) //ajusta status comercial
			EndIf
		EndIf 

	EndIf

	RestArea(aOldArea)
	RestArea(aAreaN82)

	//precisa de retorno para o romaneio de exportação
Return lRetorno 

/*{Protheus.doc} 
Função que realiza a geração do Pedido de Exportação no SIGAEEC, juntamente com a troca de filial
@sample   	IntegraEEC()
@return   	lRetorno
@author   	marcos.wagner
@since    	17/08/2017
@version  	P12
*/
Static Function IntegraEEC(aCab,aItens,nOpcao,cPedido,aAux)
	Local nScan
	Local aOldArea := GetArea()
	Local nX       := 0
	Local aSM0     := FwLoadSM0()
	Local cCGC     := FWArrFilAtu()[18]

	If !IsInCallStack("OGA250NF")
		_cFilBkp := cFilAnt
		If _cFilBkp <> aCab[1][2] //Alterando a Filial, caso seja diferente da Filial Logada

			For nX := 1 To Len(aSM0)
				If aSM0[nX,1] == cEmpAnt .AND. AllTrim(aSM0[nX,2]) == AllTrim(aCab[1,2]) 
					cFilAnt := aCab[1,2]
					cCGC    := aSM0[nX,18]
					Exit
				EndIf
			Next nX
	
		EndIf
	Else
 		For nX := 1 To Len(aSM0)
			If aSM0[nX,1] == cEmpAnt .AND. AllTrim(aSM0[nX,2]) == AllTrim(aCab[1,2]) 
				cFilAnt := aCab[1,2]
				cCGC    := aSM0[nX,18]
				Exit
			EndIf
		Next nX
	EndIf

	dbSelectArea("SA2")
	SA2->(dbSetOrder(3))
	If SA2->(dbSeek(xFilial("SA2",cFilAnt)+cCGC))
		nScan := AScan( aCab, {|x| AllTrim(x[1]) == "EE7_FORN" } )
		aCab[nScan][2] := SA2->A2_COD
		nScan := AScan( aItens[1], {|x| AllTrim(x[1]) == "EE8_FORN" } )

		For nX := 1 To Len(aItens)
			aItens[nX][nScan][2] := SA2->A2_COD
		Next nX

		nScan := AScan( aItens[1], {|x| AllTrim(x[1]) == "EE8_FABR" } )

		For nX := 1 To Len(aItens)
			aItens[nX][nScan][2] := SA2->A2_COD
		Next nX

		nScan := AScan( aCab, {|x| AllTrim(x[1]) == "EE7_FOLOJA" } )
		aCab[nScan][2] := SA2->A2_LOJA
		nScan := AScan( aItens[1], {|x| AllTrim(x[1]) == "EE8_FOLOJA" } )

		For nX := 1 To Len(aItens)
			aItens[nX][nScan][2] := SA2->A2_LOJA
		Next nX

		nScan := AScan( aItens[1], {|x| AllTrim(x[1]) == "EE8_FALOJA" } )

		For nX := 1 To Len(aItens)
			aItens[nX][nScan][2] := SA2->A2_LOJA
		Next nX

		nScan := AScan( aCab, {|x| AllTrim(x[1]) == "EE7_EXPORT" } )
		aCab[nScan][2] := SA2->A2_COD
		nScan := AScan( aCab, {|x| AllTrim(x[1]) == "EE7_EXLOJA" } )
		aCab[nScan][2] := SA2->A2_LOJA

	EndIf

	//PE para permitir customizar dados enviados para EEC
	If ExistBlock('OG710001')
		aRet := ExecBlock('OG710001',.F.,.F.,{aCab, aItens, nOpcao})
		If ValType(aRet) == 'A'
			aCab	:= aRet[1] // Cabeçalho do processo de exportação
			aItens  := aRet[2] // Itens do processo de exportação
		EndIf
	EndIf

    IF !__lAutomato //tratar erros eec
		nModulo := 29 //Tivemos que alterar o conteúdo para não dar erro no EEC
		MSExecAuto( {|X,Y,Z,W| EECAP100(X,Y,Z,W)},aCab ,aItens, nOpcao, aAux)
		nModulo := 67 //Voltando o conteúdo do módulo
	
		If !lMsErroAuto //Guardo os arrays/registros que não deram problema
	
			If nOpcao == 3 .Or. nOpcao == 4
	
				aADD(aN82,{ aCab[1][2], aCab[2][2], aItens })
	
			ElseIf nOpcao == 5 //exclusão
	
				dbSelectArea("N82")
				N82->(dbSetOrder(1))
				If N82->(dbSeek(N7Q->N7Q_FILIAL+N7Q->N7Q_CODINE+cPedido+aCab[1][2]))
					While N82->(!Eof()) .AND. N82->N82_FILIAL+N82->N82_CODINE+N82->N82_PEDIDO+N82->N82_FILORI ==;
					N7Q->N7Q_FILIAL+N7Q->N7Q_CODINE+cPedido+aCab[1][2] 
						RecLock("N82",.f.)
						N82->(dbDelete())
						N82->(MsUnlock())
						N82->(dbSkip())
					EndDo
				EndIf
	
				//Exclui a tabela de relacionamento do vinculo do processo de exportação com o SIGAAGR
				dbSelectArea("N9Z")
				N9Z->(dbSetOrder(1))//N9Z_FILIAL+N9Z_PEDIDO+N9Z_SEQUEN+N9Z_COD_I
				If N9Z->(dbSeek(FwXFilial("N9Z") + cPedido ))
					While N9Z->(!EOF()) .And. N9Z->N9Z_PEDIDO == cPedido .And. N9Z->N9Z_CODINE == N7Q->N7Q_CODINE
						RecLock("N9Z",.f.)
						N9Z->(dbDelete())
						N9Z->(MsUnlock())
						N9Z->(dbSkip())
					EndDo
				EndIf
				N9Z->(DbCloseArea())
	
				GrvPed() //Grava pedidos no campo N7Q->N7Q_PEDEXP
	
			EndIf
		EndIf
	ENDIF	
	If !IsInCallStack("OGA250NF")
		If _cFilBkp <> cFilAnt
			For nX := 1 To Len(aSM0)
				If aSM0[nX,1] == cEmpAnt .AND. AllTrim(aSM0[nX,2]) == AllTrim(_cFilBkp) 
					cFilAnt := _cFilBkp
					Exit
				EndIf
			Next nX
		EndIf
	EndIf

	RestArea(aOldArea)

Return

/*{Protheus.doc} VldQtdBlc
Valida o valor do campo quantidade de fardos do bloco e atualiza as demais pastas
@author 	Tamyris Ganzenmueller
@since 		12/10/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
Function VldQtdBlc(oBrw) 
	Local oModel   := FwModelActive()
	Local aAreaAtu := GetArea()
	Local lRetorno :=  .T.
	Local nQtdVinc := QtVincBlc(oBrw)
	Local nQtdRom  := 0 //QTD DE FARDOS DO BLOCO PARA A IE JA VINCULADO A ROMANEIOS
	Local aInfFrd  := {} //armazena dados selecionados na grid de fardos
	Local lMarca   := IIf( (cAliGrBlc)->QTFRDSEL > 0 , .T., .F. )

	If (cAliGrBlc)->FRDMAR == "1" .AND. oModel:IsCopy()
		//se for rolagem(copia) e IE de origem foi marcado fardos para o bloco
		Help(" ", 1, "OGA710FARORBLC") //"Não é possível informar a quantidade de fardos para o bloco."

		dbSelectArea(cAliGrBlc)
		(cAliGrBlc)->( dbSetorder(2) )
		If dbSeek((cAliGrBlc)->FILORG+(cAliGrBlc)->BLOCO)
			RecLock(cAliGrBlc, .F.)
			(cAliGrBlc)->QTFRDSEL := nQtdVinc
			(cAliGrBlc)->(MsUnlock())
		EndIf
	Else

		If Valtype(M->QTFRDSEL) == "N"
			dbSelectArea(cAliGrBlc)
			(cAliGrBlc)->( dbSetorder(2) )
			If dbSeek((cAliGrBlc)->FILORG+(cAliGrBlc)->BLOCO)
				RecLock(cAliGrBlc, .F.)
				(cAliGrBlc)->QTFRDSEL := M->QTFRDSEL
				(cAliGrBlc)->(MsUnlock())
			EndIf
		EndIf

		aInfFrd := ConsQFrd((cAliGrBlc)->FILORG,(cAliGrBlc)->BLOCO, .T.)
		nQtdRom := aInfFrd[1]

		If (cAliGrBlc)->QTFRDSEL > (cAliGrBlc)->QTDRESER .Or. (cAliGrBlc)->QTFRDSEL < 0 
			Help( ,,STR0026,, STR0042 , 1, 0 ) //"AJUDA - A quantidade de fardos informada para o bloco é invalida." 
			lRetorno :=  .F.
		ElseIf !oModel:IsCopy() .AND. (cAliGrBlc)->QTFRDSEL > ((cAliGrBlc)->QTDRESER - nQtdVinc)
			MsgInfo(STR0042+" ("+ (cAliGrBlc)->BLOCO +") " ,STR0015) //" A quantidade de fardos informada para o bloco é invalida. " ### "Atenção"
			lRetorno :=  .F.
		ElseIf !oModel:IsCopy() .and. (cAliGrBlc)->QTFRDSEL < nQtdRom 
			MsgInfo(STR0042+" ("+ (cAliGrBlc)->BLOCO +") " + STR0127 ,STR0015) //"Há fardos já selecionados neste bloco em romaneio " ### "Atenção"
			lRetorno :=  .F.
		ElseIf oModel:IsCopy() .And. (cAliGrBlc)->QTFRDSEL > nQtdVinc
			MsgInfo(STR0042+" ("+ (cAliGrBlc)->BLOCO +") " + _CRLF+_CRLF+STR0105+cValToChar(nQtdVinc),STR0015) //" A quantidade de fardos informada para o bloco é invalida. " ### "Atenção"
			lRetorno :=  .F.
		EndIf

		RestArea(aAreaAtu)

		If lRetorno			
			/* Atualiza a grid de Fardos */			
			AtualizFrd(oBrw:Alias(), 4, lMarca)

			/* Atualiza a grid de Blocos */
			AtualizBlc(oBrw:Alias(), 4)     			

			/* Atualiza a grid de Filiais */
			AtualizFil()

			/* Atualiza a tree */
			AtualizTree()

			/* Atualiza a grid de cadências */ 	
			AtualizCad() 

			/* Atualiza totais */
			AtuTotsIe()

			/* Atualiza as grids Filiais e Fardos */			
			oBrwFil:Refresh(.T.)
			oBrwFrd:Refresh(.T.)
		EndIf

	EndIf
Return lRetorno

/*{Protheus.doc} 
Função que realiza a validação das quantidades e percentuais máximos e mínimos permitidos
Valida se todos os blocos tem quantidade de fardos informada
@sample   	ValQtds()
@return   	lRetorno
@author   	rafael.kleestadt
@since    	25/08/2017
@version  	P12
*/
Function ValQtds(oModel,nTipQtd,nQtdVal,nPercMin,nPercMax,nLiMin,nLiMax )
	Local nOperation := oModel:GetOperation()
	Local oModelN7Q  := oModel:GetModel( "N7QUNICO" )
	Local oModelN7S  := oModel:GetModel( "N7SUNICO" )
	Local nLimMin    := IIf(nTipQtd > 0,nLiMin,  oModelN7Q:GetValue("N7Q_LIMMIN"))//Indica o limite mínimo de peso.
	Local nLimMax    := IIf(nTipQtd > 0,nLiMax,  oModelN7Q:GetValue("N7Q_LIMMAX"))//Indica o limite máximo de peso.
	Local nPerMin    := IIf(nTipQtd > 0,nPercMin,oModelN7Q:GetValue("N7Q_PERMIN"))//Percentual Mínimo da instruçao de embarque.
	Local nPerMax    := IIf(nTipQtd > 0,nPercMax,oModelN7Q:GetValue("N7Q_PERMAX"))//Percentual máximo da instrução de embarque.
	Local nTotLiq    := IIf(nTipQtd > 0,nQtdVal, oModelN7Q:GetValue("N7Q_TOTLIQ"))
	Local nTotBru    := oModelN7Q:GetValue("N7Q_TOTBRU")
	Local nQtdCon    := oModelN7Q:GetValue("N7Q_QTDCON")//Qtd. containers informada
	Local nPsCntr    := oModelN7Q:GetValue("N7Q_PSCNTR")//Peso Max. container
	Local cTpCntr    := oModelN7Q:GetValue("N7Q_TPCNTR")//Tipo de peso de CNTR
	local nQtdSol    := oModelN7S:GetValue('N7S_QTDSOL') 
	Local nQtdVin    := oModelN7S:GetValue('N7S_QTDVIN') 
	Local lContinua  := .t.
	Local nLMiPerm   := 0
	Local nLMaPerm   := 0
	Local nQtdCnt    := 0	
	Local nx         := 0
	Local nVlCad     := 0
	Local nValOutIE  := 0
	Local nTqtSol    := 0

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE	

		If nTotLiq <> 0 .And. nTotBru <> 0 .And. nPsCntr <> 0 .And. nQtdCon <> 0 
			If cTpCntr == "1" 
				nQtdCnt := Round((nTotLiq / nPsCntr), 0)
			Else
				nQtdCnt := Round((nTotBru / nPsCntr), 0)
			EndIf

			If nQtdCon < nQtdCnt
				//Help(" ", 1, "OGA710QTDCNT") 
				oModel:SetErrorMessage (,,,,, STR0185 + _CRLF + ; //"A quantidade de containers informada(Q. Container) é menor que a quantidade necessária calculada."
				STR0186 + AllTrim(cValToChar(nQtdCon)) + _CRLF + ;  //"-Qtd. Containers: "
				STR0187 + AllTrim(cValToChar(nQtdCnt)) + _CRLF + ;  //"-Qtd. Necessária Containers: "
				STR0188 + AllTrim(cValToChar(TRANSFORM(IIF(cTpCntr == "1",nTotLiq,nTotBru), "@E 9,999,999.99"))),STR0085) //"-Qtd. Instruída: "
				Return(.F.)
			EndIf
		EndIf

		//validar limite de peso x qtd solicitada e instruida por entregas da ie 	
		For nX := 1 to oModelN7S:Length()
			oModelN7S:Goline( nX )	

			nQtdSol := IIf(nTipQtd > 0, FwFldGet("N7S_QTDSOL"),oModelN7S:GetValue('N7S_QTDSOL'))
			nTqtSol += nQtdSol
			nQtdVin := IIf(nTipQtd > 0, FwFldGet("N7S_QTDVIN"),oModelN7S:GetValue('N7S_QTDVIN'))

			nVlCad  := QTDN9ACAD(FWxFilial("N9A"),oModelN7S:GetValue("N7S_CODCTR"),oModelN7S:GetValue("N7S_ITEM"),oModelN7S:GetValue("N7S_SEQPRI"))

			If !oModel:IsCopy()
				nValOutIE := RetVlCadIE(oModelN7S:GetValue("N7S_CODCTR"),oModelN7S:GetValue("N7S_ITEM"),oModelN7S:GetValue("N7S_SEQPRI"),2)	 // qtd solicitada	
			EndIf

			//VAlidar qtd solicitada + outras ies x limite maximo - ao salvar ao alterar perc.		
			If nVlCad < (nValOutIE + nQtdSol) .And. ValTipProd()//Não Algodão
				nQtddcd := nVlCad - nValOutIE
				oModel:SetErrorMessage (,,,,,STR0013 + AllTrim(Str(nQtddcd)) +"!",STR0085)  //"Quantidade informada é superior a quantidade disponível" ### "Altere a quantidade"
				Return(.F.)
			EndIf

			If !oModel:IsCopy()
				nValOutIE := RetVlCadIE(oModelN7S:GetValue("N7S_CODCTR"),oModelN7S:GetValue("N7S_ITEM"),oModelN7S:GetValue("N7S_SEQPRI"),1)	 // qtd solicitada	
			EndIf

			//VAlidar qtd instruida + outras ies x limite maximo - ao salvar ao alterar perc. 
			If nVlCad < (nValOutIE + nQtdVin) .And. ValTipProd()//Não Algodão
				nQtddcd := nVlCad - nValOutIE
				oModel:SetErrorMessage (,,,,,STR0013 + AllTrim(Str(nQtddcd)) +"!",STR0085)  //"Quantidade informada é superior a quantidade disponível" ### "Altere a quantidade"
				Return(.F.)
			EndIf		
		Next nX				

		//limite minimo e maximo solicitado 
		nLMiPerm := nLimMin - nLimMin * (nPerMin / 100) // Validação Qtd mínimo da instrução
		If nLMiPerm  > 0 .and. (nTotLiq > 0 .and. nTotLiq < nLMiPerm) 
			MsgInfo(STR0043 + AllTrim(cValToChar(TRANSFORM(nTotLiq, "@E 9,999,999.99"))) + STR0044 + AllTrim(cValToChar(TRANSFORM(nLMiPerm, "@E 9,999,999.99"))))//"O volume informado na Instrução de Embarque é menor que o volume mínimo permitido."
		EndIf

		If nLMiPerm  > 0 .and.  (nTqtSol > 0 .and. nTqtSol < nLMiPerm)
			MsgInfo(STR0128 + AllTrim(cValToChar(TRANSFORM(nTotLiq, "@E 9,999,999.99"))) + STR0129 + AllTrim(cValToChar(TRANSFORM(nLMiPerm, "@E 9,999,999.99"))))//"O volume informado na Instrução de Embarque é menor que o volume mínimo permitido."
		EndIf

		nLMaPerm :=  nLimMax - nLimMax * (nPerMax / 100) // Validação Qtd máxima da instrução
		If nLMaPerm > 0 .and. ((nTotLiq > 0 .and. nTotLiq > nLMaPerm) .or. (nTqtSol > 0 .and. nTqtSol > nLMaPerm))
			Help(" ", 1, "OGA710QTDPERMA") //"O volume informado na Instrução de Embarque é maior que o volume máximo permitido."
			Return(.F.)
		EndIf	

	EndIf

Return( lContinua )



/** {Protheus.doc} 
Função preenchimento automatico totais liquido\bruto e nr farto da IE
@param: 	Nil
@author: 	vanilda.moggio
@since: 	08/17
@Uso: 		SIGAAGR
*/
Static Function fVldN7S1( oModel )
	Local oN7Q			:= oModel:GetModel( "N7QUNICO" )
	Local oN7S			:= oModel:GetModel( "N7SUNICO" )
	Local nLinha 		:= oN7S:GetLine()
	Local nX            := 0
	Local nRetorno      := 0 
	local lAlgodao      := .F.

	dbSelectArea("NJR")
	dbSetOrder(1)
	If dbSeek(xFilial("NJR")+ oN7S:GetValue("N7S_CODCTR"))
		lAlgodao := if(Posicione("SB5",1,xFilial("SB5")+ NJR->NJR_CODPRO,"B5_TPCOMMO")== '2',.T.,.F.)
	endif
	NJR->(dbCloseArea())

	if lAlgodao == .F.
		For nX := 1 to oN7S:Length()
			oN7S:Goline( nX ) 
			nRetorno += oN7S:GetValue( "N7S_QTDVIN" )
		Next nX
		oN7Q:SetValue( "N7Q_TOTLIQ", nRetorno )
		oN7Q:SetValue( "N7Q_TOTBRU", nRetorno ) // Para produto diferente de algodão atualizar o total bruto igual ao peso liquido pois não tem embalagem.
		oN7S:GoLine( nLinha )
	endif

Return( .T. )

/** {Protheus.doc}
Mostra pedidos de exportação vinculados à IE
@param: 	Nil
@author: 	tamyris.ganzenmueller
@since: 	08/17
@Uso: 		SIGAAGR
*/
Function XEECAP100C(oModel)

	Local cQueryN82 := ""
	Local cAliasN82 := GetNextAlias()
	Local cFiltro   := ""

	If ValTpMerc(.F.) = "1"
		Help(" ", 1, "OGA710TIPMERC") //##Problema: Função não disponível para mercado interno. ##Solução: Esta função é especifica para mercado externo.
		Return .T.
	EndIf

	// Seleciona pedidos de exportação vinculados à IE
	cQueryN82 := "   SELECT N82_FILORI, N82_PEDIDO "
	cQueryN82 += "     FROM " + RetSqlName('N82') + " N82 "
	cQueryN82 += "    WHERE N82.N82_FILIAL = '" + N7Q->N7Q_FILIAL + "'"
	cQueryN82 += "      AND N82.N82_CODINE = '" + N7Q->N7Q_CODINE + "'"
	cQueryN82 += "      AND N82.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryN82), cAliasN82, .F., .T.)
	If (cAliasN82)->(!EoF())
		While (cAliasN82)->(!EoF())

			If !Empty(cFiltro)
				cFiltro += " .Or. "
			EndIF

			cFiltro += " ( EE7_FILIAL = '" + (cAliasN82)->N82_FILORI + "' .AND. EE7_PEDIDO = '"  + (cAliasN82)->N82_PEDIDO + "' )"
			(cAliasN82)->(dbSkip())
		End
	Else
		Help(" ", 1, "OGA710SEMPDEXP") //"Está Instrução de Embarque não possui pedidos de exportação relacionados."
		Return(.T.)         
	EndIf
	(cAliasN82)->(dbCloseArea())

	nModulo := 29 //Módulo Exportação    
	EE7->(DbSetFilter({|| cFiltro }, cFiltro))
	EECAP100()
	nModulo := 67 //Módulo Agroindustria

Return .T.

/*{Protheus.doc} 
Função que chama a deleção do Pedido de Exportação no SIGAEEC
@sample   	DelEEC()
@return   	lRetorno
@author   	Agroindustria
@since    	12/04/2018
@version  	P12
*/
Function DelEEC()
	Local lRet := .T.

	Begin Transaction
		lRet := OGA710DELP()
		If !lRet
			DisarmTransaction() 
		EndIf
		
	End Transaction

Return 
/*{Protheus.doc} 
Função que executa a deleção do Pedido de Exportação no SIGAEEC
@sample   	OGA710DELP()
@return   	lRetorno
@author   	marcos.wagner
@since    	28/08/2017
@version  	P12
*/
Static Function OGA710DELP(cFilPed,cPedido)
	Local aOldArea      := GetArea()
	Local aCab          := {} 
	Local aItens        := {}
	Local cAliasEE7     := ''
	Local cAliasEE8     := ''
	Local cOperacao     := ''
	Local lsemPexp      := .f.

	Private lMsErroAuto := .f.
	Default cFilPed     := ''
	Default cPedido     := ''

	If ValTpMerc(.F.) = "1" .And. Empty(FWModelActive())
		Help(" ", 1, "OGA710TIPMERC") //##Problema: Função não disponível para mercado interno. ##Solução: Esta função é especifica para mercado externo.
		Return .T.
	EndIf

	//Funcao para limpar relacionamento do pedido de exportacao e instrucao de embarque quando o pedido de exportacao nao existir 
	lsemPexp:= OGX710DN82(FwXFilial("N7Q"), N7Q->N7Q_CODINE)
	If lsemPexp
		RecLock("N7Q",.F.)
		N7Q->N7Q_STAEXP := 2 //Incompleto
		N7Q->(MsUnlock())
	EndIf

	cAliasEE7 := GetNextAlias()
	cQueryEE7 := "   SELECT * " 
	cQueryEE7 += "     FROM " + RetSqlName('EE7') + " EE7, " + RetSqlName('N82') + " N82 "
	cQueryEE7 += "    WHERE N82.N82_FILIAL = '" + N7Q->N7Q_FILIAL + "'"
	cQueryEE7 += "      AND N82.N82_CODINE = '" + N7Q->N7Q_CODINE + "'"
	cQueryEE7 += "      AND N82.N82_FILORI = EE7.EE7_FILIAL "
	cQueryEE7 += "      AND N82.N82_PEDIDO = EE7.EE7_PEDIDO "
	If !empty(cPedido) .and. !empty(cFilPed)
		cQueryEE7 += " AND N82.N82_FILORI = '" + Alltrim(cFilPed) + "' AND N82.N82_PEDIDO = '" + Alltrim(cPedido) + "' " 
	EndIf
	cQueryEE7 += "      AND EE7.D_E_L_E_T_ = ' ' "
	cQueryEE7 += "      AND N82.D_E_L_E_T_ = ' ' "
	cQueryEE7 += " ORDER BY EE7.EE7_FILIAL, EE7.EE7_PEDIDO "
	cQueryEE7 := ChangeQuery(cQueryEE7)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryEE7), cAliasEE7, .F., .T.)
	If (cAliasEE7)->(!EoF())
		While (cAliasEE7)->(!EoF())
			DbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			If SC5->(dbSeek((cAliasEE7)->EE7_FILIAL+(cAliasEE7)->EE7_PEDFAT))	
				If !Empty(SC5->C5_NOTA)
					cPedido := (cAliasEE7)->EE7_PEDIDO
					cFilPed := (cAliasEE7)->EE7_FILIAL
					(cAliasEE7)->(dbSkip())
					LOOP
				EndIf
			EndIf
			SC5->(dbCloseArea())				

			//For nI := 1 to 2

			//If nI == 1
			//cOperacao := "AUTCANCELA"
			//Else
			cOperacao := "AUTDELETA"
			//EndIf

			aCab :={{'EE7_FILIAL' ,(cAliasEE7)->EE7_FILIAL ,Nil},;
			{'EE7_PEDIDO' ,(cAliasEE7)->EE7_PEDIDO ,Nil},;
			{'EE7_IMPORT' ,(cAliasEE7)->EE7_IMPORT ,Nil},;
			{'EE7_IMLOJA' ,(cAliasEE7)->EE7_IMLOJA ,Nil},;
			{'EE7_IMPODE' ,(cAliasEE7)->EE7_IMPODE ,Nil},;
			{'EE7_FORN'   ,(cAliasEE7)->EE7_FORN   ,Nil},;
			{'EE7_FOLOJA' ,(cAliasEE7)->EE7_FOLOJA ,Nil},;
			{'EE7_RESPON' ,(cAliasEE7)->EE7_RESPON ,Nil},;
			{'EE7_REFIMP' ,(cAliasEE7)->EE7_REFIMP ,Nil},;
			{'EE7_IDIOMA' ,(cAliasEE7)->EE7_IDIOMA ,Nil},;
			{'EE7_CONDPA' ,(cAliasEE7)->EE7_CONDPA ,Nil},;
			{'EE7_MPGEXP' ,(cAliasEE7)->EE7_MPGEXP ,Nil},;
			{'EE7_INCOTE' ,(cAliasEE7)->EE7_INCOTE ,Nil},;
			{'EE7_MOEDA'  ,(cAliasEE7)->EE7_MOEDA  ,Nil},;
			{'EE7_FRPPCC' ,(cAliasEE7)->EE7_FRPPCC ,Nil},;
			{'EE7_CALCEM' ,(cAliasEE7)->EE7_CALCEM ,Nil},;
			{'EE7_VIA' 	  ,(cAliasEE7)->EE7_VIA    ,Nil},;
			{'EE7_ORIGEM' ,(cAliasEE7)->EE7_ORIGEM ,Nil},;
			{'EE7_DEST'   ,(cAliasEE7)->EE7_DEST   ,Nil},;
			{'EE7_PAISET' ,(cAliasEE7)->EE7_PAISET ,Nil},;
			{'EE7_TIPTRA' ,(cAliasEE7)->EE7_TIPTRA ,Nil},;
			{'EE7_EXPORT' ,(cAliasEE7)->EE7_EXPORT ,Nil},;
			{'EE7_EXLOJA' ,(cAliasEE7)->EE7_EXLOJA ,Nil},;
			{'EE7_CONSIG' ,(cAliasEE7)->EE7_CONSIG ,Nil},;
			{'EE7_COLOJA' ,(cAliasEE7)->EE7_COLOJA ,Nil},;
			{ cOperacao   , "S" 		       ,Nil}}

			cAliasEE8 := GetNextAlias()
			cQueryEE8 := "   SELECT * " 
			cQueryEE8 += "     FROM "+RetSqlName('EE8') + " EE8"
			cQueryEE8 += "    WHERE EE8.EE8_FILIAL = '" + (cAliasEE7)->EE7_FILIAL + "'"
			cQueryEE8 += "      AND EE8.EE8_PEDIDO = '" + (cAliasEE7)->EE7_PEDIDO + "'"
			cQueryEE8 += "      AND EE8.D_E_L_E_T_ = ' ' "
			cQueryEE8 += " ORDER BY EE8.EE8_FILIAL, EE8.EE8_PEDIDO, EE8.EE8_SEQUEN "
			cQueryEE8 := ChangeQuery(cQueryEE8)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryEE8), cAliasEE8, .F., .T.)
			If (cAliasEE8)->(!EoF())
				While (cAliasEE8)->(!EoF())

					aAdd(aItens,{{'EE8_FILIAL', (cAliasEE8)->EE8_FILIAL, Nil},;
					{'EE8_SEQUEN' , (cAliasEE8)->EE8_SEQUEN, Nil},;
					{'EE8_COD_I'  , (cAliasEE8)->EE8_COD_I , Nil},;
					{'EE8_FORN'   , (cAliasEE8)->EE8_FORN  , Nil},;
					{'EE8_FOLOJA' , (cAliasEE8)->EE8_FOLOJA, Nil},;
					{'EE8_SLDINI' , (cAliasEE8)->EE8_SLDINI, Nil},;
					{'EE8_EMBAL1' , (cAliasEE8)->EE8_EMBAL1, Nil},;
					{'EE8_QE' 	  , (cAliasEE8)->EE8_QE    , Nil},; 
					{'EE8_PSLQUN' , (cAliasEE8)->EE8_PSLQUN, Nil},;
					{'EE8_PRECO'  , Round((cAliasEE8)->EE8_PRECO,TamSX3("EE8_PRECO")[2]) , Nil},; 
					{'EE8_TES'    , (cAliasEE8)->EE8_TES   , Nil},;
					{'EE8_FABR'   , (cAliasEE8)->EE8_FABR  , Nil},;
					{'EE8_FALOJA' , (cAliasEE8)->EE8_FALOJA, Nil},;
					{'EE8_POSIPI' , (cAliasEE8)->EE8_POSIPI, Nil},;
					{'EE8_LOTECT' , (cAliasEE8)->EE8_LOTECT, Nil},;
					{"LINPOS" 	  , "EE8_COD_I", (cAliasEE8)->EE8_SEQUEN}})

					(cAliasEE8)->(dbSkip())
				End
			End 
			(cAliasEE8)->(dbCloseArea())
			//If nI == 1
			//cOperacao := STR0048 //"Cancelando o pedido "
			//Else
			cOperacao := STR0046 //"Deletando o pedido " 			
			//EndIf

			Processa({|lEnd| IntegraEEC(aCab,aItens,5,(cAliasEE7)->EE7_PEDIDO) },cOperacao + AllTrim((cAliasEE7)->EE7_PEDIDO) + STR0047 +(cAliasEE7)->EE7_FILIAL) // " da filial "  

			If lMsErroAuto
				MostraErro()
				Return .F.
				Exit
			EndIf
			lMsErroAuto := .f.
			//Next nI

			(cAliasEE7)->(dbSkip())
		EndDo
	EndIf 
	(cAliasEE7)->(dbCloseArea())

	If empty(cPedido) .and. empty(cFilPed)
		RecLock("N7Q",.F.)
		N7Q->N7Q_STAEXP := 1 //Não Gerado
		N7Q->(MsUnlock())
	EndIf

	RestArea(aOldArea)

Return .T.

/*{Protheus.doc} 
Função para limpar a relação entre IE e Fardos
@sample   	DelFarIE()
@return   	lRetorno
@author   	rafael.kleestadt
@since    	01/09/2017
@version  	P12
*/
Function DelFarIE(cCodIne)
	Local cAliasFar := GetNextAlias() // Obtem o proximo alias disponivel
	Local cQryFar   := ""

	//--- Fardos ---//
	cQryFar := " SELECT DXI_FILIAL, DXI_CODIGO, DXI_CODINE, DXI_ITEINE FROM " + RetSqlName("DXI") + " DXI "
	cQryFar += " WHERE DXI.DXI_CODINE = '" + cCodIne + "'"
	cQryFar += " AND DXI.D_E_L_E_T_ = ' ' "	

	cQryFar := ChangeQuery(cQryFar)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryFar),cAliasFar, .F., .T.) 
	DbselectArea( cAliasFar )
	(cAliasFar)->(DbGoTop())


	While (cAliasFar)->( !Eof() )
		DbselectArea( "DXI" )
		DXI->(dbSetOrder(8))		
		If DXI->(dbSeek((cAliasFar)->(DXI_FILIAL)+(cAliasFar)->(DXI_CODINE)+(cAliasFar)->(DXI_ITEINE)))			
			RecLock( "DXI", .F. )
			DXI->DXI_CODINE := ""
			DXI->DXI_ITEINE := ""
			DXI->(MsUnLock())
			//retorna(2) status do fardo na DXI(DXI_STATUS)
			AGRXFNSF( 2 , "IE")
			//registra a movimentação do fardinho(N9D)
			MovFardo(.F.,cCodIne)
			
		EndIf
		(cAliasFar)->(DbSkip())
	EndDo
	(cAliasFar)->(DbCloseArea())

	N83->(DbSelectArea("N83")) 
	N83->(DbSetorder(1))   
	If N83->(DbSeek( xFilial("N83")+cCodIne))
		While !N83->( Eof() ) .AND. AllTrim(N83->N83_FILIAL+N83->N83_CODINE) == AllTrim(xFilial("N83") + cCodIne)
			RecLock( "N83", .F. )
			N83->N83_DATATU := dDatabase
			N83->N83_HORATU := Time()			
			N83->(dbDelete())
			N83->(MsUnLock())

			N83->(DbSkip())
		EndDo
	EndIf	

Return .T.

/*{Protheus.doc} 
Tela para informação do motivo da rolagem
@sample   	OGA710ROL()
@return   	lRetorno
@author   	marcos.wagner
@since    	06/09/2017
@version  	P12
*/
Static Function OGA710ROL(oModel)
	Local nOpcao	   := 2
	Local lRet         := .t.	 
	Local oModelN7Q    := oModel:GetModel( "N7QUNICO" )
	Local cCodIneNew   := oModelN7Q:GetValue("N7Q_CODINE")
	Private cCodRolage := Space(6), cDescricao := Space(44), cObserva := Space(40)

	oDlg	:= TDialog():New(350,406,515,1150,STR0056,,,,,CLR_BLACK,CLR_WHITE,,,.t.) //"Indique o motivo da rolagem"
	oDlg:lEscClose := .f.

	@ 040,008 SAY STR0054 PIXEL //"Motivo:"
	@ 038,027 MSGET cCodRolage OF oDlg F3 "N85" HASBUTTON Valid VldRolagem() PIXEL

	@ 040,066 SAY STR0055 PIXEL //"Descrição:"
	@ 038,095 MSGET cDescricao OF oDlg PIXEL WHEN .f.

	@ 060,008 SAY STR0240+':' PIXEL //"Observação"
	@ 058,042 MSGET cObserva OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIF(VldTelaMot(), (nOpcao := 1, oDlg:End()),.F.)},{|| IIF(VldTelaMot(), (nOpcao := 0, oDlg:End()),.F.)}) CENTERED

	If nOpcao == 1

		cSeqMot := GetSXENum("N86","N86_SEQMOT")

		If ( __lSx8 )
			ConfirmSX8()
		EndIf

		RecLock("N86",.t.)
		N86->N86_FILIAL	:= xFilial("N86")	
		N86->N86_SEQMOT := cSeqMot		
		N86->N86_IEORIG	:= N7Q->N7Q_CODINE
		N86->N86_IEDEST	:= cCodIneNew
		N86->N86_CODROL := cCodRolage
		N86->N86_DATROL	:= dDataBase
		N86->N86_HORROL	:= Time()
		N86->N86_USUARI	:= cUserName
		N86->N86_OBSERV := cObserva
		N86->(MsUnLock())		
	Else
		lRet := .f.
	EndIf

Return lRet	

/*{Protheus.doc} 
Validação do Motivo da Rolagem
@sample   	VldRolagem()
@return   	lRetorno
@author   	marcos.wagner
@since    	06/09/2017
@version  	P12
*/
Function VldRolagem()
	Local lRetorno := .t.
	Local aOldArea := GetArea() 

	If !Empty(cCodRolage)
		If ExistCpo('N85',cCodRolage)
			cDescricao := N85->N85_DESCRI
		Else
			cDescricao := Space(80)
			lRetorno := .f.
		EndIf
	Else
		lRetorno := .f.
	EndIf

	RestArea(aOldArea)

Return lRetorno

/*{Protheus.doc} 
Validação do Motivo da Rolagem
@sample   	VldTelaMot()
@return   	lRetorno
@author   	marcos.wagner
@since    	06/09/2017
@version  	P12
*/
Static Function VldTelaMot()
	Local lRet := .t.

	If Empty(cCodRolage)
		MsgStop(STR0057,STR0015) //"Deverá ser informado o campo 'Motivo'!" ### "Atenção"
		lRet := .f.
	EndIf

Return lRet


Function OGA710Copy()

	lRolagem := .f.

Return


/*{Protheus.doc} 
Validação após ativação da VIEW
@sample   	AfterVal(oModel)
@return   	
@author   	Thiago Henrique Rover
@since    	13/09/2017
@version  	P12
*/
Static Function AfterVal(oView)
	Local oModel     := FwModelActive()
	Local aArea      := GetArea() 	
	Local cCodIE     := N7Q->N7Q_CODINE
	Local oModelN7Q  := oModel:GetModel('N7QUNICO')	
	Local lRetorno := .T.

	cQAlias := GetNextAlias()
	cQuery3 := " SELECT N86_IEORIG FROM " + RetSqlName("N86") + " N86 "
	cQuery3 += " WHERE N86.N86_FILIAL = '" + xFilial('N86') + "'"
	cQuery3 += " AND N86.N86_IEORIG = '" +cCodIE+ "' AND N86.N86_IEDEST = '" +cCodIE+ "'"
	cQuery3 += " AND N86.D_E_L_E_T_ = ' ' "	
	cQuery3 := ChangeQuery(cQuery3)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery3),cQAlias, .F., .T.) 

	(cQAlias)->(dbGoTop())

	If Empty((cQAlias)->N86_IEORIG)
		oView:SelectFolder("CTRFOLDER",STR0017,2) //"Principal"
	EndIf

	/*oView:HideFolder("GRADES",STR0038,2)*/

	(cQAlias)->(dbCloseArea())

	RestArea(aArea)	

	/* Caso o tipo de commodite seja "2 - Algodão" será apresentado a aba com os componentes: Tree, Limites de Peso e Grids de Filiais, Blocos e Fardos
	Caso não seja "2 - Algodão" será apresentado apenas o componente com os campos dos Limites de Peso	*/	
	If Posicione("SB5",1,xFilial("SB5")+oModelN7Q:GetValue('N7Q_CODPRO'),"B5_TPCOMMO") == '2' // Algodão
		oView:HideFolder("CTRFOLDER", 5, 2)			
	Else
		oView:HideFolder("CTRFOLDER", 4, 2)
	EndIf

	/*Caso seja mercado externo habilita pasta exportacao*/
	If ValTpMerc(.T.) == "1" // externo
		oView:HideFolder("CTRFOLDER", STR0089, 2)	//Exportacao
	EndIf   

	oView:SelectFolder("CTRFOLDER",STR0017,2) //"Principal"
	
	If oModel:IsCopy() .AND. !lProdAlgo //se rolagem e for grãos
		//adiciona opção no menu de edição da tela, para poder chamar a rotina de seleção dos itens de grão para rolagem
		oView:AddUserButton( STR0191 ,''       , { |oModel| OG710CTSRG(oModel) } ) //"Itens Rolagem Grãos"
		//limpa variavel para receber os itens da tela OG710CTSRG, esta variavel será usada na gravação da rolagem
		_aRolItGrao := {}  
		//chama/abre tela para seleção dos itens de grão para rolagem, caso tela seja cancelada será considerada rolagem de todos os itens
		lRetorno := OG710CTSRG(oModel) 
	EndIf
	
Return lRetorno

/*{Protheus.doc} 
Criação do DbTree
@sample   	OGA710TREE(oPanel)
@return   	
@author   	Marcos Wagner Junior
@since    	26/09/2017
@version  	P12
*/
Static Function OGA710TREE( oPanel )

	If !lProdAlgo
		Return
	EndIf

	// Cria a Tree
	oTree := DbTree():New(0,0,0,0,oPanel,,,.T.)

Return

/*{Protheus.doc} 
Processa os níveis da tree
@sample   	ProcTree
@return   	
@author   	Francisco Kennedy Nunes Pinheiro / Vanilda Moggio Machado
@since    	07/11/2017
@version  	P12
*/
Static Function ProcTree()

	nIndTree++
	If nIndTree == 1 
		MsAguarde({|| CarregTree()},"Processamento","Aguarde a finalização da busca dos Itens da IE...")
	EndIf
	
Return


/*{Protheus.doc} 
Carrega os níveis da tree
@sample   	CarregTree
@return   	
@author   	Francisco Kennedy Nunes Pinheiro / Vanilda Moggio Machado
@since    	07/11/2017
@version  	P12
*/
Static Function CarregTree()
	Local oMod710    := FWModelActive()
	Local nOperation := oMod710:GetOperation()

	// Cria estutura dos níveis da tree (Tabela temporária)
	CriaTmpTb()

	// Cria estrutura da grid "Filiais" e carrega os dados da mesma (Tabela temporária)
	CriaStrFil()

	// Cria estrutura da grid "Blocos" e carrega os dados da mesma (Tabela temporária)
	CriaStrBlc()

	// Cria estrutura da grid "Fardos" e carrega os dados da mesma (Tabela temporária)	
	CriaStrFrd()

	// Atualiza os dados do browser da grid "Filiais"
	AtuBrwFil()

	// Atualiza os dados do browser da grid "Blocos"
	AtuBrwBlc()

	// Atualiza os dados do browser da grid "Fardos"
	AtuBrwFrd()

	// Inicializa a quantidade instruida na grid de cadências (Apenas para Inclusão)
	If nOperation == MODEL_OPERATION_INSERT
		AtualizCad() //IniQtdInst()
	EndIf

	// Carrega os dados da tree
	LoadTree(1)

	// Atualiza Totais
	AtuTotsIe()

	If nOperation == MODEL_OPERATION_INSERT
		lMarkFil := .T. 
		lMarkBlc := .T.
		lMarkFrd := .T.
	EndIf

Return

/*{Protheus.doc} 
Carrega os dados da tree - Níveis IE, Cadência, Filial e Bloco
@sample   	LoadTree()
@return   	
@author   	Francisco Kennedy Nunes Pinheiro
@since    	27/11/2017
@param 		nAcao: 1 - Inicio, 2 - Atualização
@param 		aParam: Objeto com [1] = Filial e [2] = Bloco
@version  	P12
*/
Static Function LoadTree(nAcao,oParam)
	Local cQuery     := ""
	Local nX	     := 0
	Local oModel     := FwModelActive()
	Local oN7Q	     := oModel:GetModel("N7QUNICO")
	Local oN7S	     := oModel:GetModel("N7SUNICO")
	Local cDesIni    := oN7Q:GetValue("N7Q_DESINE")
	Local nQtdAten   := 0
	Local nQtdInst   := 0
	Local cDataIni   := ""
	Local cDataFim   := "" 
	Local cDescricao := ""
	Local cAliasIE  := ""
	Local cAliasCAD := ""
	Local cAliasFIL := ""
	local cAliasBLC := ""

	Default oParam   := {}

	If nAcao == 1	
		oTree:bChange := {|| TreeClick(oTree:Nivel(),oTree:GetCargo())}
		oTree:Align   := CONTROL_ALIGN_ALLCLIENT
	EndIf

	// Insere os dados no nível 1 (IE) na Tree	
	For nX := 1 to oN7S:Length()
		If .NOT. oN7S:IsDeleted()
			//nQtdAten += oN7S:GetValue('N7S_QTDDCD', nX)	
			nQtdAten += QTDN9ACAD(oN7S:GetValue('N7S_FILIAL', nX),oN7S:GetValue('N7S_CODCTR', nX),oN7S:GetValue('N7S_ITEM', nX),oN7S:GetValue('N7S_SEQPRI', nX))
			
			nQtdInst += oN7S:GetValue('N7S_QTDDCD', nX)		
		EndIf	
	Next nX

	cAliasIE := GetNextAlias()
	cQuery := "SELECT IE.T_CODINE AS CODINE, "
	cQuery += "       SUM(T_QTFRDSEL) AS QTFRDSEL, "
	cQuery += "       SUM(T_PSLIQSEL) AS PSLIQSEL, "
	cQuery += "       SUM(T_QTFRDDIS) AS QTFRDDIS, "
	cQuery += "       SUM(T_PSLIQDIS) AS PSLIQDIS "
	cQuery += " FROM "+ oArqTempTree:GetRealName() + " IE "	
	cQuery += " GROUP BY T_CODINE "	
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasIE, .F., .T. )

	dbSelectArea(cAliasIE)
	While (cAliasIE)->(!EOF())
		cDescricao := (STR0099 + AllTrim(cDesIni) +;
		STR0094  + AllTrim(TransForm(nQtdInst,    "@E 9,999,999.99"))+;             //" - Qtd. Atender: "      
		STR0095  + AllTrim(TransForm((cAliasIE)->(QTFRDSEL), "@E 9,999,999"))+;                //" - Fardos Selec: "
		STR0096  + AllTrim(TransForm((cAliasIE)->(PSLIQSEL), "@E 9,999,999.99"))+;             //" - Peso Selec: " 
		STR0097  + AllTrim(TransForm((cAliasIE)->(QTFRDDIS), "@E 9,999,999"))+;                //" - Fardos Disp: "
		STR0098  + AllTrim(TransForm((cAliasIE)->(PSLIQDIS), "@E 9,999,999.99")) + Space(60))  //" - Peso Disp: "

		If nAcao == 1
			oTree:AddItem(cDescricao,'NV1'+(cAliasIE)->(CODINE)+Space(24), "AREA" ,,,,1)
		Else		
			oTree:ChangePrompt(cDescricao,"NV1"+(cAliasIE)->(CODINE))			
		EndIf

		(cAliasIE)->(DbSkip())
	EndDo	
	(cAliasIE)->(DbCloseArea())

	// Insere os dados no nível 2 (Cadência) na Tree
	cAliasCAD := GetNextAlias()
	cQuery := "SELECT CAD.T_CODINE AS CODINE, "
	cQuery += "       CAD.T_CONTRATO AS CODCTR, "
	cQuery += "       CAD.T_CADENCIA AS CADEN, "
	cQuery += "       CAD.T_DATAINI AS DATINI, "
	cQuery += "       CAD.T_DATAFIM AS DATFIM, "
	cQuery += "       SUM(T_QTFRDSEL) AS QTFRDSEL, "
	cQuery += "       SUM(T_PSLIQSEL) AS PSLIQSEL, "
	cQuery += "       SUM(T_QTFRDDIS) AS QTFRDDIS, "
	cQuery += "       SUM(T_PSLIQDIS) AS PSLIQDIS "
	cQuery += " FROM "+ oArqTempTree:GetRealName() + " CAD "		
	cQuery += " GROUP BY T_CODINE, T_CONTRATO, T_CADENCIA, T_DATAINI, T_DATAFIM "	
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasCAD, .F., .T. )

	nQtdAten := 0

	dbSelectArea(cAliasCAD)
	While (cAliasCAD)->(!EOF())

		nQtdInst := 0
		lAdd := .t.

		For nX := 1 to oN7S:Length()
			If .NOT. oN7S:IsDeleted() .AND. AllTrim(oN7S:GetValue('N7S_CODCTR', nX)) == AllTrim((cAliasCAD)->(CODCTR)) .AND. AllTrim(oN7S:GetValue('N7S_ITEM', nX)) == AllTrim((cAliasCAD)->(CADEN))
				
				If lAdd
					nQtdAten := QTDN9ACAD(oN7S:GetValue('N7S_FILIAL', nX),oN7S:GetValue('N7S_CODCTR', nX),oN7S:GetValue('N7S_ITEM', nX),oN7S:GetValue('N7S_SEQPRI', nX))
					nQtdAten -= (cAliasCAD)->(PSLIQSEL)
					lAdd := .f.
				EndIf
				
				nQtdInst += oN7S:GetValue('N7S_QTDDCD', nX)

			EndIf	
		Next nX

		cDataIni := SUBSTR((cAliasCAD)->(DATINI), 7, 2) + "/" + SUBSTR((cAliasCAD)->(DATINI), 5, 2) + "/" + SUBSTR((cAliasCAD)->(DATINI), 1, 4)
		cDataFim := SUBSTR((cAliasCAD)->(DATFIM), 7, 2) + "/" + SUBSTR((cAliasCAD)->(DATFIM), 5, 2) + "/" + SUBSTR((cAliasCAD)->(DATFIM), 1, 4)

		cDescricao := STR0100 + AllTrim((cAliasCAD)->(CODCTR)) +;
		" - " + AllTrim((cAliasCAD)->(CADEN)) +;  
		" - " + cDataIni +;
		" a " + cDataFim +;
		STR0094 + AllTrim(TransForm(nQtdInst,    "@E 9,999,999.99"))+; //" - Qtd. Atender: "                                          
		STR0095 + AllTrim(TransForm((cAliasCAD)->(QTFRDSEL), "@E 9,999,999")) +;   //" - Fardos Selec: "
		STR0096 + AllTrim(TransForm((cAliasCAD)->(PSLIQSEL), "@E 9,999,999.99"))+; //" - Peso Selec: " 
		STR0097 + AllTrim(TransForm((cAliasCAD)->(QTFRDDIS), "@E 9,999,999")) +;   //" - Fardos Disp: "
		STR0098 + AllTrim(TransForm((cAliasCAD)->(PSLIQDIS), "@E 9,999,999.99"))   //" - Peso Disp: "

		If nAcao == 1
			If oTree:TreeSeek('NV1'+(cAliasCAD)->(CODINE))									
				oTree:AddItem(cDescricao,'NV2'+(cAliasCAD)->(CODINE)+(cAliasCAD)->(CODCTR)+(cAliasCAD)->(CADEN)+Space(5), "FOLDER5" ,,,,2)
			EndIf
		Else
			oTree:ChangePrompt(cDescricao,"NV2"+(cAliasCAD)->(CODINE)+(cAliasCAD)->(CODCTR)+(cAliasCAD)->(CADEN))
		EndIf

		(cAliasCAD)->(DbSkip())
	EndDo	
	(cAliasCAD)->(DbCloseArea())

	// Insere os dados no nível 3 (Filial) na Tree
	cAliasFIL := GetNextAlias()
	cQuery := "SELECT FIL.T_CODINE AS CODINE, "
	cQuery += "       FIL.T_CONTRATO AS CODCTR, "
	cQuery += "       FIL.T_CADENCIA AS CADEN, "
	cQuery += "       FIL.T_FILORG AS FILORG, "
	cQuery += "       SUM(T_QTFRDSEL) AS QTFRDSEL, "
	cQuery += "       SUM(T_PSLIQSEL) AS PSLIQSEL, "
	cQuery += "       SUM(T_QTFRDDIS) AS QTFRDDIS, "
	cQuery += "       SUM(T_PSLIQDIS) AS PSLIQDIS "
	cQuery += " FROM "+ oArqTempTree:GetRealName() + " FIL "		
	cQuery += " GROUP BY T_CODINE, T_CONTRATO, T_CADENCIA, T_FILORG "
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasFIL, .F., .T. )

	dbSelectArea(cAliasFIL)
	While (cAliasFIL)->(!EOF())

		cDescricao := STR0101 + AllTrim((cAliasFIL)->(FILORG)) +;
		STR0095  + AllTrim(TransForm((cAliasFIL)->(QTFRDSEL), "@E 9,999,999"))+;     //" - Fardos Selec: "
		STR0096  + AllTrim(TransForm((cAliasFIL)->(PSLIQSEL), "@E 9,999,999.99")) +; //" - Peso Selec: " 
		STR0097  + AllTrim(TransForm((cAliasFIL)->(QTFRDDIS), "@E 9,999,999"))+;     //" - Fardos Disp: "
		STR0098  + AllTrim(TransForm((cAliasFIL)->(PSLIQDIS), "@E 9,999,999.99"))    //" - Peso Disp: "

		If nAcao == 1
			If oTree:TreeSeek('NV2'+(cAliasFIL)->(CODINE)+(cAliasFIL)->(CODCTR)+(cAliasFIL)->(CADEN))
				oTree:AddItem(cDescricao,'NV2'+(cAliasFIL)->(CODINE)+(cAliasFIL)->(CODCTR)+(cAliasFIL)->(CADEN)+(cAliasFIL)->(FILORG)+Space(7), "FOLDER10" ,,,,2)					
			EndIf
		Else
			oTree:ChangePrompt(cDescricao,"NV2"+(cAliasFIL)->(CODINE)+(cAliasFIL)->(CODCTR)+(cAliasFIL)->(CADEN)+(cAliasFIL)->(FILORG))
		EndIf

		(cAliasFIL)->(DbSkip())
	EndDo	
	(cAliasFIL)->(DbCloseArea())

	// Insere os dados no nível 4 (Bloco) na Tree
	cAliasBLC := GetNextAlias()
	cQuery := "SELECT BLC.T_CODINE AS CODINE, "
	cQuery += "       BLC.T_CONTRATO AS CODCTR, "
	cQuery += "       BLC.T_CADENCIA AS CADEN, "
	cQuery += "       BLC.T_FILORG AS FILORG, "
	cQuery += "       BLC.T_BLOCO AS BLOCO, "
	cQuery += "       SUM(T_QTFRDSEL) AS QTFRDSEL, "
	cQuery += "       SUM(T_PSLIQSEL) AS PSLIQSEL, "
	cQuery += "       SUM(T_QTFRDDIS) AS QTFRDDIS, "
	cQuery += "       SUM(T_PSLIQDIS) AS PSLIQDIS "
	cQuery += " FROM "+ oArqTempTree:GetRealName() + " BLC "	
	cQuery += " GROUP BY T_CODINE, T_CONTRATO, T_CADENCIA, T_FILORG, T_BLOCO "	
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasBLC, .F., .T. )

	dbSelectArea(cAliasBLC)
	While (cAliasBLC)->(!EOF())

		cDescricao := STR0102 + AllTrim((cAliasBLC)->(BLOCO))+;
		STR0095  + AllTrim(TransForm((cAliasBLC)->(QTFRDSEL), "@E 9,999,999"))+;     //" - Fardos Selec: "
		STR0096  + AllTrim(TransForm((cAliasBLC)->(PSLIQSEL), "@E 9,999,999.99")) +; //" - Peso Selec: " 
		STR0097  + AllTrim(TransForm((cAliasBLC)->(QTFRDDIS), "@E 9,999,999"))+;     //" - Fardos Disp: "
		STR0098  + AllTrim(TransForm((cAliasBLC)->(PSLIQDIS), "@E 9,999,999.99"))    //" - Peso Disp: "

		If nAcao == 1
			If oTree:TreeSeek('NV2'+(cAliasBLC)->(CODINE)+(cAliasBLC)->(CODCTR)+(cAliasBLC)->(CADEN)+(cAliasBLC)->(FILORG))
				oTree:AddItem(cDescricao,'NV4'+(cAliasBLC)->(CODINE)+(cAliasBLC)->(CODCTR)+(cAliasBLC)->(CADEN)+(cAliasBLC)->(FILORG)+(cAliasBLC)->(BLOCO), "BONUS" ,,,,2)							
			EndIf

			oTree:TreeSeek('NV2'+(cAliasBLC)->(CODINE)+(cAliasBLC)->(CODCTR)+(cAliasBLC)->(CADEN)+(cAliasBLC)->(FILORG)+Space(7))
			oTree:PTCollapse()

			oTree:TreeSeek('NV2'+(cAliasBLC)->(CODINE)+(cAliasBLC)->(CODCTR)+(cAliasBLC)->(CADEN)+Space(5))
			oTree:PTCollapse()
		Else
			oTree:ChangePrompt(cDescricao,"NV4"+(cAliasBLC)->(CODINE)+(cAliasBLC)->(CODCTR)+(cAliasBLC)->(CADEN)+(cAliasBLC)->(FILORG)+(cAliasBLC)->(BLOCO))
		EndIf

		(cAliasBLC)->(DbSkip())
	EndDo	
	(cAliasBLC)->(DbCloseArea())

	If nAcao == 1
		oTree:TreeSeek('NV1')
		oTree:PTCollapse()
	EndIf

Return

/*{Protheus.doc} Markall

@author thiago.rover
@since 04/10/2017
@version 1.0
@return ${return}, ${return_description}
@param oBrwAll, Objeto, descricao
@param lMarcar, logical, descricao
@param nBrowse, number, Indica qual é o browse origem (1=Filiais, 2=Blocos, 3=Fardos)
@param nOperation - Operação (Visualização, Inclusão, Alteração ou Exclusão)
@type function
*/
Static Function MarkAll(oBrwAll,lMarcar,nBrowse,nOperation)
	Local aAreaAtu := GetArea()
	Local lMFrdRom := .T. // Marcar(.T.)/Desmarcar(.F.) fardos vinculados a romaneio
	Local oModel   := FwModelActive()	
	Local lSubQFrd := .F.	
	Local cTipMerc	 := M->N7Q_TPMERC //tipo do mercado
	Local lMsgDFRom	:= .T. //se mostra mensagem ao desmarcar fardo com romaneio

	lFrdCtn    := .F. // Utilizado para verificar a necessidade de atualizar os fardos com containers (Rolagem Parcial)	
	lFrdCtnAlt := .T. // Utilizado para mostrar a mensagem de aviso, na alteração da IE, quando tentar desmarcar um fardo
	// vincualdo a um container apenas uma vez

	If nOperation == MODEL_OPERATION_VIEW .Or. nOperation == MODEL_OPERATION_DELETE
		Return .T.
	Else
		If ValPerm(nBrowse)

			lMarcar := !lMarcar

			/* Caso não seja rolagem e esteja desmarcando todos os fardos na grid de fardos */
			/* Verifica se possui algum fardo com romaneio vinculado */
			/* Caso possua, conforme status do fardo mostra uma mensagem para o usuário indicar se deseja desmarcar inclusive os fardos com romaneio vinculado */ 
			If !oModel:isCopy() .AND. !lMarcar
				
				lMFrdRom := VldPgDmRom(oBrwAll:Alias(),nBrowse) //valida se mostra pergunta ao usaurio para desmarcar fardos
										
			EndIf 

			/* Caso seja Rolagem Parcial */
			If oModel:isCopy()				
				/* Verifica se os fardos que serão atualizados possuem containers */
				/* Mostra uma confirmação para o usuário escolher se deseja marcar/desmarcar estes fardos */
				VerCont(oBrwAll, lMarcar, nBrowse, .T.)							
			EndIf							

			(oBrwAll:Alias())->(dbGoTop())
			While !(oBrwAll:Alias())->(Eof())

				/* Atualiza a grid de Fardos */
				AtualizFrd(oBrwAll:Alias(), nBrowse, lMarcar, lMFrdRom, @lMsgDFRom)

				lSubQFrd := .F.
				
				/* Caso esteja desmarcando fardos na gride de fardos(nBrowse == 3 .AND. !lMarcar) 
				e esta vinculado em romaneio (!lMFrdRom .AND. !Empty((oBrwAll:Alias())->(ROMFLO))) */
				/* E não seja Rolagem (!oModel:isCopy()) */
				If nBrowse == 3 .AND. !lMarcar .AND. !lMFrdRom .AND. (!Empty((oBrwAll:Alias())->(ROMFLO)) .OR. (oBrwAll:Alias())->(STATUS) $ '100|110|120|170' ) .AND. !oModel:isCopy() .AND. !Empty((oBrwAll:Alias())->(CODINE))	
					If Empty((oBrwAll:Alias())->(OK)) 
						//o fardo foi de fato desmarcado(Empty((oBrwAll:Alias())->(OK))) 
						/* Envia um parâmetro para atualização do bloco para apenas subtrair um na quantidade de fardos */
						lSubQFrd := .T.
	
					ElseIf 	cTipMerc = '2' .AND. lMsgDFRom .AND. !Empty((oBrwAll:Alias())->(OK))
						//se mercado externo e não foi possivel desmarcar o fardo com romaneio
						MsgAlert(STR0197,STR0015) //##Há fardos vinculados em romaneio em expedição ou faturado, estes fardos não serão desmarcados! ##Atenção"
						lMsgDFRom := .F. //mostra mensagem apenas uma vez grid fardos
					EndIf		
				EndIf

				/* Atualiza a grid de Blocos */
				AtualizBlc(oBrwAll:Alias(), nBrowse, lSubQFrd)

				(oBrwAll:Alias())->(DbSkip())
			EndDo

			/* Atualiza a grid de Filiais */
			AtualizFil()

			/* Atualiza a tree */
			AtualizTree()

			/* Atualiza a grid de cadências */ 	
			AtualizCad() 

			/* Atualiza totais */
			AtuTotsIe()

			/* Atualiza as grids Filiais, Blocos e Fardos */
			oBrwFil:Refresh(.T.)			
			oBrwBlc:Refresh(.T.)
			oBrwFrd:Refresh(.T.)

			RestArea(aAreaAtu)

			lMarkFil := lMarcar
			lMarkBlc := lMarcar
			lMarkFrd := lMarcar

			oBrwAll:SetFocus() //mantem o foco no browser
		EndIf
	EndIf
Return .T.

/*{Protheus.doc} Marcar

@author claudineia.reinert	
@since 09/10/2017
@version 1.0
@return ${return}, ${return_description}
@param oBrwAll, Objeto, descricao
@param nBrowse, number, Indica qual é o browse origem (1=Filiais, 2=Blocos, 3=Fardos)
@param nOperation - Operação (Visualização, Inclusão, Alteração ou Exclusão)
@type function
*/
Static Function Marcar(oBrw,nBrowse,nOperation) 	
	Local lMarcar  := .F.
	Local oModel   := FwModelActive()	
	Local lMFrdRom := .F. //variavel usada apenas na grid de fardos, .T. mantem o fardos marcado e .F. desmarca o fardo com romaneio
	Local lSubQFrd := .F.
	Local aInfFrd  := {} //armazena dados selecionados na grid de fardos
	Local cTipMerc	 := M->N7Q_TPMERC //tipo do mercado

	lFrdCtn    := .F. // Utilizado para verificar a necessidade de atualizar os fardos com containers (Rolagem Parcial)	
	lFrdCtnAlt := .T. // Utilizado para mostrar a mensagem de aviso, na alteração da IE, quando tentar desmarcar um fardo
	// vincualdo a um container apenas uma vez

	If nOperation == MODEL_OPERATION_VIEW .Or. nOperation == MODEL_OPERATION_DELETE
		Return .T.
	Else
		If ValPerm(nBrowse)

			If Empty((oBrw:Alias())->(OK)) .or. (nBrowse != 3 .and. (oBrw:Alias())->(QTFRDDIS) > 0)
				lMarcar := .T.				
			EndIf

			/* Caso este desmarcando e não é rolagem */
			If !oModel:isCopy() .AND. !lMarcar
				
				If nBrowse == 3 //grid fardos
				
					If FRDGBLFUT((oBrw:Alias())->(FILORG), (oBrw:Alias())->(SAFRA), (oBrw:Alias())->(ETIQ)) .AND. (oBrw:Alias())->(STATUS) $ '100|110|120'
						//FARDO EM CONTRATO COM GLOBAL FUTURA E O STATUS 100|110|120 NO ROMANEIO DE REMESSA DA GLOBAL FUTURA
						lMFrdRom := .T. /* Não será desmarcado */
						MsgAlert(STR0194,STR0015) //## Este fardo esta vinculado a um romaneio de remessa global futura e não poderá ser desmarcado! ##Atenção
						Return .T.
					ElseIf (oBrw:Alias())->(STATUS) $ '100|170' 
						//status 100 trata romaneio de remessa e venda e 170 trata romaneio venda
						lMFrdRom := .T. /* Não será desmarcado */
						MsgAlert(STR0195,STR0015) //## Este fardo esta vinculado a um romaneio já faturado ou em expedição e não poderá ser desvinculado! ##Atenção
						Return .T.
					ElseIf cTipMerc = '2' .AND. !Empty((oBrw:Alias())->(ROMFLO)) .AND. (oBrw:Alias())->(STATUS) $ '110|120' .AND. !Empty((oBrw:Alias())->(CODINE))	
						//mercado externo, fardo esta em um romaneio de remessa 
						If !MsgYesNo(STR0121 + " " + STR0133, STR0015) //##"Este fardo já foi vinculado a um romaneio de remessa."  ##"Deseja desmarcá-lo?" ##"Atenção"
							lMFrdRom := .T. /* Não deseja desmarcar */
							/* Caso o usuário não deseja desmarcar o fardo, não será necessário realizar nenhuma ação */
							Return .T.
						EndIf
					EndIf
					
				Else //grid filial/blocos
				
					lMFrdRom := VldPgDmRom(oBrw:Alias(),nBrowse) //valida se mostra pergunta ao usaurio para desmarcar fardos
					
				EndIf
										
			EndIf	

			/* Caso não seja rolagem parcial (!oModel:IsCopy()) e esteja marcando um fardo na grid de Fardos (lMarcar .AND. nBrowse == 3) */
			If lMarcar .AND. !oModel:IsCopy() .AND. nBrowse == 3
				/* Consulta informações do bloco (Quantidade Disponível, Quantidade Selecionada, Informou manualmente qtd fardos?,  etc...) */
				aInfBlc := ConsInfBlc((oBrw:Alias())->FILORG, (oBrw:Alias())->BLOCO)

				// Quantidade Selecionada + Quantidade Disponível
				nQtdTotal := aInfBlc[1] + aInfBlc[2] 						

				/* Consulta quantidade de fardos selecionados */
				aInfFrd := ConsQFrd((oBrw:Alias())->FILORG, (oBrw:Alias())->BLOCO)	
				nQtdFrdSel := aInfFrd[1]

				/* Caso a quantidade total (Selecionada + Disponível) do Bloco for menor que a quantidade de fardos selecionados + 1, não deixará marcar fardos */ 
				If nQtdTotal < (nQtdFrdSel + 1)

					// "Não é possível marcar o fardo, pois a quantidade selecionada de fardos na Instrução de Embarque atingiu a quantidade disponível para esta instrução"
					// ### "Atenção"			
					MsgInfo(STR0149+"!",STR0015)

					Return .T.
				EndIf
			EndIf

			/* Caso seja Rolagem Parcial */
			If oModel:isCopy()				
				/* Verifica se os fardos que serão atualizados possuem containers */
				/* Mostra uma confirmação para o usuário escolher se deseja marcar/desmarcar estes fardos */
				VerCont(oBrw, lMarcar, nBrowse, .F.)							
			EndIf

			/* Atualiza a grid de Fardos */
			AtualizFrd(oBrw:Alias(), nBrowse, lMarcar, lMFrdRom)

			lSubQFrd := .F.

			/* Caso esteja desmarcando um fardo na grid de fardos com romaneio vinculado */
			If nBrowse == 3 .AND. Empty((oBrw:Alias())->OK)
				If !Empty((oBrw:Alias())->(ROMFLO))
					/* Envia um parâmetro para atualização do bloco para apenas subtrair um na quantidade de fardos */
					lSubQFrd := .T.

				EndIf
			EndIf

			/* Atualiza a grid de Blocos */
			AtualizBlc(oBrw:Alias(), nBrowse, lSubQFrd)     			

			/* Atualiza a grid de Filiais */
			AtualizFil()

			/* Atualiza a tree */
			AtualizTree()

			/* Atualiza a grid de cadências */ 	
			AtualizCad() 

			/* Atualiza totais */
			AtuTotsIe()

			/* Atualiza a grid Filiais caso esteja manipulando a grid Blocos / Fardos */
			/* OU caso tenha atualizado os fardos do container */
			If nBrowse <> 1 .OR. lFrdCtn 
				oBrwFil:Refresh(.T.)
			EndIf

			/* Atualiza a grid Blocos caso esteja manipulando a grid Filiais / Fardos */
			/* OU caso tenha atualizado os fardos do container */
			If nBrowse <> 2 .OR. lFrdCtn
				oBrwBlc:Refresh(.T.)
			EndIf	

			/* Atualiza a grid Fardos caso esteja manipulando a grid Filiais / Blocos */
			/* OU caso tenha atualizado os fardos do container */
			If nBrowse <> 3 .OR. lFrdCtn
				oBrwFrd:Refresh(.T.)
			EndIf				
		EndIf
	EndIf

	oBrw:SetFocus() //mantem o foco no browser

Return .T.

/*{Protheus.doc} IniBrowser - Inicializa browsers das grids "Filiais", "Blocos" e "Fardos"
@author Francisco Kennedy Nunes Pinheiro
@since 08/11/2017
@version 1.0
@type function
*/
Function IniBrowser(oPanel, oObj, lBrw)

	If !lProdAlgo
		Return
	EndIF

	If lBrw == 1	
		oBrwFil := FWBrowse():New()
		oBrwFil:SetDataTable(.T.)
		oBrwFil:SetOwner(oPanel)
	ElseIf lBrw == 2
		oBrwBlc :=  FWBrowse():New()
		oBrwBlc:SetDataTable(.T.)
		oBrwBlc:SetOwner(oPanel)
	Else
		oBrwFrd := FWBrowse():New()
		oBrwFrd:SetDataTable(.T.)
		oBrwFrd:SetOwner(oPanel)
	EndIf

Return

/*{Protheus.doc} CriaStrFil - Cria a estrutura da tabela temporária da grid "Filiais"
@author Francisco Kennedy Nunes Pinheiro
@since 06/11/2017
@version 1.0
@type function
*/
Function CriaStrFil()
	Local aStruct   := {{"OK", "C", 2, 0}}
	Local oArqTemp1 := Nil

	AAdd(aStruct, {"FILORG"  , "C", TamSX3("N83_FILORG")[1], TamSX3("N83_FILORG")[2]})
	AAdd(aStruct, {"QTFRDSEL", "N", TamSX3("N83_QUANT") [1], TamSX3("N83_QUANT") [2]})
	AAdd(aStruct, {"PSBRUSEL", "N", TamSX3("N83_PSBRUT")[1], TamSX3("N83_PSBRUT")[2]})
	AAdd(aStruct, {"PSLIQSEL", "N", TamSX3("N83_PSLIQU")[1], TamSX3("N83_PSLIQU")[2]})
	AAdd(aStruct, {"QTFRDDIS", "N", TamSX3("N83_QUANT") [1], TamSX3("N83_QUANT") [2]})
	AAdd(aStruct, {"PSBRUDIS", "N", TamSX3("N83_PSBRUT")[1], TamSX3("N83_PSBRUT")[2]})
	AAdd(aStruct, {"PSLIQDIS", "N", TamSX3("N83_PSLIQU")[1], TamSX3("N83_PSLIQU")[2]})	
	AAdd(aStruct, {"QTDINI" ,  "N", TamSX3("N83_QUANT") [1], TamSX3("N83_QUANT") [2]})
	AAdd(aStruct, {"PSBRUINI", "N", TamSX3("N83_PSBRUT")[1], TamSX3("N83_PSBRUT")[2]})
	AAdd(aStruct, {"PSLIQINI", "N", TamSX3("N83_PSLIQU")[1], TamSX3("N83_PSLIQU")[2]})

	cAliFil   :=  GetNextAlias()
	oArqTemp1 := AGRCRTPTB(cAliFil, {aStruct, {{"","FILORG"}} })

Return

/*{Protheus.doc} AtuBrwFil - Atualiza a grid "Filiais"
@author Francisco Kennedy Nunes Pinheiro
@since 06/11/2017
@version 1.0
@type function
*/
Function AtuBrwFil()
	Local aHeader	 := {}
	Local aCpFiltro  := {}
	Local lActivate  := .F.
	Local oModel	 := FwModelActive()
	Local nOperation := oModel:GetOperation()

	// Campos que serão mostrados na grid
	aAdd(aHeader, {STR0062	,{||(cAliFil)->FILORG}  			,   'C'   ,'@!'    					, 1    ,TamSX3("N83_FILORG")[1]     	,TamSX3("N83_FILORG")[2]  ,.F.})
	aAdd(aHeader, {STR0067	,{||(cAliFil)->QTFRDSEL}  			,   'N'   ,"@E 9,999"				, 1    ,TamSX3("N83_QUANT")[1]     		,TamSX3("N83_QUANT")[2]   ,.F.})
	aAdd(aHeader, {STR0068	,{||(cAliFil)->PSBRUSEL}  			,   'N'   ,"@E 99,999,999,999.99"	, 1    ,TamSX3("N83_PSBRUT")[1]     	,TamSX3("N83_PSBRUT")[2]  ,.F.})
	aAdd(aHeader, {STR0069	,{||(cAliFil)->PSLIQSEL}  			,   'N'   ,"@E 99,999,999,999.99"	, 1    ,TamSX3("N83_PSLIQU")[1]     	,TamSX3("N83_PSLIQU")[2]  ,.F.})
	aAdd(aHeader, {STR0070	,{||(cAliFil)->QTFRDDIS}  			,   'N'   ,"@E 9,999"			    , 1    ,TamSX3("N83_QUANT")[1]     		,TamSX3("N83_QUANT")[2]   ,.F.})
	aAdd(aHeader, {STR0071	,{||(cAliFil)->PSBRUDIS}  			,   'N'   ,"@E 99,999,999,999.99"	, 1    ,TamSX3("N83_PSBRUT")[1]     	,TamSX3("N83_PSBRUT")[2]  ,.F.})
	aAdd(aHeader, {STR0072	,{||(cAliFil)->PSLIQDIS}  			,   'N'   ,"@E 99,999,999,999.99"	, 1    ,TamSX3("N83_PSLIQU")[1]     	,TamSX3("N83_PSLIQU")[2]  ,.F.})

	// Campos para o botão de filtro
	AAdd(aCpFiltro, {"FILORG"	,STR0062,"C",TamSX3("N83_FILORG")[1],TamSX3("N83_FILORG")[2],"@!"					}) 
	AAdd(aCpFiltro, {"QTFRDSEL"	,STR0067,"N",TamSX3("N83_QUANT")[1] ,TamSX3("N83_QUANT")[2] ,"@E 9,999"				})
	AAdd(aCpFiltro, {"PSBRUSEL"	,STR0068,"N",TamSX3("N83_PSBRUT")[1],TamSX3("N83_PSBRUT")[2],"@E 99,999,999,999.99"	})
	AAdd(aCpFiltro, {"PSLIQSEL"	,STR0069,"N",TamSX3("N83_PSLIQU")[1],TamSX3("N83_PSLIQU")[2],"@E 99,999,999,999.99"	})
	AAdd(aCpFiltro, {"QTFRDDIS"	,STR0070,"N",TamSX3("N83_QUANT")[1] ,TamSX3("N83_QUANT")[2] ,"@E 9,999"				})
	AAdd(aCpFiltro, {"PSBRUDIS"	,STR0071,"N",TamSX3("N83_PSBRUT")[1],TamSX3("N83_PSBRUT")[2],"@E 99,999,999,999.99"	})
	AAdd(aCpFiltro, {"PSLIQDIS"	,STR0072,"N",TamSX3("N83_PSLIQU")[1],TamSX3("N83_PSLIQU")[2],"@E 99,999,999,999.99"	})

	lActivate := .T.

	oBrwFil:SetDataTable(.T.)
	oBrwFil:SetAlias(cAliFil)
	oBrwFil:SetProfileID('1')
	oBrwFil:Acolumns:= {}
	oBrwFil:AddMarkColumns({|| Iif((cAliFil)->OK == "OK", "LBOK", "LBNO") },{ || Marcar(oBrwFil,1,nOperation)},{|| MarkAll(oBrwFil,lMarkFil,1,nOperation)})
	oBrwFil:Setcolumns( aHeader )
	oBrwFil:DisableReport()
	oBrwFil:DisableConfig()
	oBrwFil:SetFieldFilter( aCpFiltro ) //seta os campos para o botão filtro
	oBrwFil:SetUseFilter() //ativa filtro
	oBrwFil:bLDblClick 		:= {||Marcar(oBrwFil,1,nOperation)} //ao dar duplo clique na linha

	If lActivate
		oBrwFil:Activate()
	EndIf

	oBrwFil:Enable()
	oBrwFil:Refresh(.T.)

Return	

/*{Protheus.doc} CriaStrBlc - Cria a estrutura da tabela temporária da grid "Blocos"
@author Francisco Kennedy Nunes Pinheiro
@since 06/11/2017
@version 1.0
@type function
*/
Function CriaStrBlc()
	Local aStruct	:= {{"OK", "C", 2, 0}}

	AAdd(aStruct, {"STCONT"	  , "N", 1, 0}) //status contaminante
	AAdd(aStruct, {"FILORG"	  , "C", TamSX3("N83_FILORG")[1], TamSX3("N83_FILORG")[2]})
	AAdd(aStruct, {"SAFRA"    , "C", TamSX3("N83_SAFRA") [1], TamSX3("N83_SAFRA") [2]})
	AAdd(aStruct, {"BLOCO"    , "C", TamSX3("N83_BLOCO") [1], TamSX3("N83_BLOCO") [2]})
	AAdd(aStruct, {"TIPO "    , "C", TamSX3("N83_TIPO")  [1], TamSX3("N83_TIPO")  [2]})
	AAdd(aStruct, {"QTFRDSEL" , "N", TamSX3("N83_QUANT") [1], TamSX3("N83_QUANT") [2]})
	AAdd(aStruct, {"PSBRUSEL" , "N", TamSX3("N83_PSBRUT")[1], TamSX3("N83_PSBRUT")[2]})
	AAdd(aStruct, {"PSLIQSEL" , "N", TamSX3("N83_PSLIQU")[1], TamSX3("N83_PSLIQU")[2]})
	AAdd(aStruct, {"QTFRDDIS" , "N", TamSX3("N83_QUANT") [1], TamSX3("N83_QUANT") [2]})
	AAdd(aStruct, {"PSBRUDIS" , "N", TamSX3("N83_PSBRUT")[1], TamSX3("N83_PSBRUT")[2]})
	AAdd(aStruct, {"PSLIQDIS" , "N", TamSX3("N83_PSLIQU")[1], TamSX3("N83_PSLIQU")[2]})
	AAdd(aStruct, {"QTDRESER" , "N", TamSX3("N83_QUANT") [1], TamSX3("N83_QUANT") [2]})
	AAdd(aStruct, {"PSBRUMED" , "N", 16, 10}) //definido casas decimais a maior devido ao calculo usando a media para poder bater o valor correto
	AAdd(aStruct, {"PSLIQMED" , "N", 16, 10})
	AAdd(aStruct, {"QTDINI"   , "N", TamSX3("N83_QUANT") [1], TamSX3("N83_QUANT") [2]})
	AAdd(aStruct, {"PSBRUINI" , "N", TamSX3("N83_PSBRUT")[1], TamSX3("N83_PSBRUT")[2]})
	AAdd(aStruct, {"PSLIQINI" , "N", TamSX3("N83_PSLIQU")[1], TamSX3("N83_PSLIQU")[2]})
	AAdd(aStruct, {"FRDMAR"   , "C", 1, 0})

	cAliGrBlc := GetNextAlias()	
	oArqTempBlc := AGRCRTPTB(cAliGrBlc, {aStruct, {{"","FILORG,SAFRA,BLOCO,TIPO"},{"","FILORG,BLOCO"}}})

	// Carrega dados na grid "Blocos"
	LoadGrBlc()	

Return

/*{Protheus.doc} LoadGrBlc - Carrega dados grid "Blocos"
@author Claudineia Heerdt Reinert
@since 04/10/2017
@version 1.0
@type function
*/
Function LoadGrBlc()
	Local oModel 	:= FwModelActive()
	Local oN7Q		:= Nil
	Local oN7S 		:= Nil
	Local nX      	 := 0
	Local nOperation := 0
	Local dDataIni
	Local dDataFim	
	Local cCodine
	Local lRestFluig := .f. 
	
	If IsInCallStack('OGAWPUTIE') .OR.  IsInCallStack('OGAWIEBLC')
		//OBS: o rest pode chamar esta função com um model ja ativo
		lRestFluig := .T.  
		cCodine = PADR( cCodIERest, TamSX3("N83_CODINE")[1] )
	EndIf
	
	If oModel != Nil .AND. oModel:IsActive()
		oN7Q 		 := oModel:GetModel("N7QUNICO") //IE
		oN7S 		 := oModel:GetModel("N7SUNICO") //ENTREGA
		nOperation   := oModel:GetOperation()
		cCodine	     := IIf(oModel:IsCopy(), N7Q->N7Q_CODINE, oN7Q:GetValue("N7Q_CODINE"))
		
		// Limpa a tabela temporária de blocos
		dbSelectArea(cAliGrBlc)
		(cAliGrBlc)->( dbSetorder(1) )
		ZAP
	
	EndIf

	// Limpa a tabela temporária do nível Bloco da tree
	dbSelectArea(cAliasBloc)
	(cAliasBloc)->( dbSetorder(1) )
	ZAP

	// Seleciona os registros para grid "Blocos"			
	cQuery := "SELECT N9D_FILIAL AS FILORG, "
	cQuery += " 	  N9D_SAFRA  AS SAFRA, "
	cQuery += " 	  N9D_BLOCO  AS BLOCO, "
	cQuery += " 	  DXD_CLACOM AS TIPO, "
	cQuery += " 	  N9D_CODCTR AS CODCTR, "
	cQuery += " 	  N9D_ITEETG AS CADENC, "
	cQuery += " 	  N9D_ITEREF AS ITEREF, "
	cQuery += " 	  NNY_DATINI AS DAT_INICAD, " 
	cQuery += " 	  NNY_DATFIM AS DAT_FIMCAD, "
	cQuery += " 	  COUNT(N9D_FARDO) AS QTD_RESERVA, "	
	cQuery += " 	  N83_FRDMAR AS FRDMAR, "
	cQuery += " 	  N83X.QTD_N83ALLIE, "
	cQuery += " 	  DXI.MEDBRUT_DXIDISP, "
	cQuery += " 	  DXI.MEDLIQU_DXIDISP, "
	cQuery += " 	  N83.QTD_N83IE, "
	cQuery += " 	  DXI2.QTD_DXIIE, "
	cQuery += " 	  DXI2.PSBRUT_DXIIE, "
	cQuery += " 	  DXI2.PSLIQU_DXIIE "
	cQuery += " FROM " + RetSqlName("N9D") + " N9D "
	cQuery += " INNER JOIN " + RetSqlName("DXD") + " DXD ON DXD.DXD_FILIAL = N9D.N9D_FILIAL AND DXD.DXD_SAFRA = N9D.N9D_SAFRA AND DXD.DXD_CODIGO = N9D.N9D_BLOCO AND DXD.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("NNY") + " NNY ON NNY.NNY_FILIAL = N9D.N9D_FILORG AND NNY.NNY_CODCTR = N9D.N9D_CODCTR AND NNY.NNY_ITEM = N9D.N9D_ITEETG AND NNY.D_E_L_E_T_ = ' ' "

	// Busca a quantidade de fardos do bloco na IE (N83_QUANT AS N83.QTD_N83IE)	
	cQuery += " LEFT OUTER JOIN (SELECT N83_FILIAL, N83_CODINE, N83_CODCTR, N83_ITEM, N83_ITEREF, N83_FILORG, N83_SAFRA, N83_BLOCO, N83_FRDMAR, D_E_L_E_T_, SUM(N83_QUANT) AS QTD_N83IE "
	cQuery += " 	FROM " + RetSqlName("N83") + " GROUP BY N83_FILIAL, N83_CODINE, N83_CODCTR, N83_ITEM, N83_ITEREF, N83_FILORG, N83_SAFRA, N83_BLOCO, N83_FRDMAR, D_E_L_E_T_) "
	cQuery += " 	N83 ON N83.D_E_L_E_T_ = ' ' AND N83.N83_FILIAL = '"+ xFilial("N83") +"' AND N83.N83_CODINE = '"+ cCodine +"' "
	cQuery += " 	AND N83.N83_CODCTR = N9D.N9D_CODCTR AND N83.N83_ITEM = N9D.N9D_ITEETG AND N83.N83_ITEREF = N9D.N9D_ITEREF AND N83.N83_FILORG = N9D.N9D_FILIAL AND N83.N83_SAFRA = N9D.N9D_SAFRA AND N83.N83_BLOCO = N9D.N9D_BLOCO "

	// Busca a quantidade ja vinculada de fardos do bloco em todas as IEs  (N83X.QTD_N83ALLIE)
	cQuery += " LEFT OUTER JOIN (SELECT N83_FILIAL, N83_CODCTR, N83_ITEM, N83_ITEREF, N83_FILORG, N83_SAFRA, N83_BLOCO, D_E_L_E_T_, SUM(N83_QUANT) AS QTD_N83ALLIE "
	cQuery += " 	FROM " + RetSqlName("N83") + " GROUP BY N83_FILIAL, N83_CODCTR, N83_ITEM, N83_ITEREF, N83_FILORG, N83_SAFRA, N83_BLOCO, D_E_L_E_T_) "
	cQuery += " 	N83X ON N83X.D_E_L_E_T_ = ' ' AND N83X.N83_FILIAL = '"+ xFilial("N83") +"' AND N83X.N83_CODCTR = N9D.N9D_CODCTR AND N83X.N83_ITEM = N9D.N9D_ITEETG "
	cQuery += " 	AND N83X.N83_ITEREF = N9D.N9D_ITEREF AND N83X.N83_FILORG = N9D.N9D_FILIAL AND N83X.N83_SAFRA = N9D.N9D_SAFRA AND N83X.N83_BLOCO = N9D.N9D_BLOCO "

	// Busca a média do peso bruto e peso líquido dos fardos do bloco que estão disponiveis, sem IE vinculada (DXI.MEDBRUT_DXIDISP e DXI.MEDLIQU_DXIDISP)
	cQuery += " LEFT OUTER JOIN (SELECT AVG(CASE WHEN DXI_PESCER > 0 THEN DXI_PESCER + DXI_PSTARA WHEN DXI_PESSAI > 0 THEN DXI_PESSAI + DXI_PSTARA WHEN DXI_PSESTO > 0 THEN DXI_PSESTO + DXI_PSTARA ELSE DXI_PSLIQU + DXI_PSTARA END)  AS MEDBRUT_DXIDISP, 
	cQuery += " 	AVG(CASE WHEN DXI_PESCER > 0 THEN DXI_PESCER WHEN DXI_PESSAI > 0 THEN DXI_PESSAI WHEN DXI_PSESTO > 0 THEN DXI_PSESTO ELSE DXI_PSLIQU END ) AS MEDLIQU_DXIDISP,  "
	cQuery += " 	DXI_FILIAL, DXI_CODRES, DXI_ITERES, DXI_SAFRA, DXI_BLOCO, D_E_L_E_T_ "
	cQuery += " 	FROM " + RetSqlName("DXI") 
	cQuery += " 	WHERE D_E_L_E_T_ = ' ' AND DXI_CODINE = '' " //para buscar media dos fardos que ainda estão disponiveis, sem IE
	cQuery += " 	GROUP BY DXI_FILIAL, DXI_CODRES, DXI_ITERES, DXI_SAFRA, DXI_BLOCO, D_E_L_E_T_) "
	cQuery += " 	DXI ON DXI.D_E_L_E_T_ = ' ' AND DXI.DXI_FILIAL = N9D.N9D_FILIAL AND DXI.DXI_CODRES = N9D.N9D_CODRES AND DXI.DXI_ITERES = N9D.N9D_ITERES AND DXI.DXI_SAFRA  = N9D.N9D_SAFRA AND DXI.DXI_BLOCO  = N9D.N9D_BLOCO "

	// Busca a qtd fardos e a soma do peso atual dos fardos na DXI com a IE para o bloco da IE(DXI2.QTD_DXIIE,DXI2.PSBRUT_DXIIE,DXI2.PSLIQU_DXIIE)
	cQuery += " LEFT OUTER JOIN (SELECT COUNT(DXI_ETIQ) AS QTD_DXIIE,SUM(CASE WHEN DXI_PESCER > 0 THEN DXI_PESCER + DXI_PSTARA WHEN DXI_PESSAI > 0 THEN DXI_PESSAI + DXI_PSTARA WHEN DXI_PSESTO > 0 THEN DXI_PSESTO + DXI_PSTARA ELSE DXI_PSLIQU + DXI_PSTARA END)  AS PSBRUT_DXIIE,  
	cQuery += " 	SUM(CASE WHEN DXI_PESCER > 0 THEN DXI_PESCER WHEN DXI_PESSAI > 0 THEN DXI_PESSAI WHEN DXI_PSESTO > 0 THEN DXI_PSESTO ELSE DXI_PSLIQU END ) AS PSLIQU_DXIIE, 
	cQuery += " 	DXI_FILIAL, DXI_CODRES, DXI_ITERES, DXI_SAFRA, DXI_BLOCO, D_E_L_E_T_           
	cQuery += " 	FROM " + RetSqlName("DXI") 
	cQuery += " 	WHERE D_E_L_E_T_ = ' ' AND DXI_CODINE = '"+ cCodine +"'
	cQuery += " 	GROUP BY DXI_FILIAL, DXI_CODRES, DXI_ITERES, DXI_SAFRA, DXI_BLOCO, D_E_L_E_T_ )            
	cQuery += " 	DXI2 ON DXI2.D_E_L_E_T_ = ' ' AND DXI2.DXI_FILIAL = N9D.N9D_FILIAL AND DXI2.DXI_CODRES = N9D.N9D_CODRES 
	cQuery += " 	AND DXI2.DXI_ITERES = N9D.N9D_ITERES AND DXI2.DXI_SAFRA  = N9D.N9D_SAFRA AND DXI2.DXI_BLOCO  = N9D.N9D_BLOCO 

	// Realiza a leitura na tabela N9D (Movimento dos fardos) pelo movimento 02 - Reserva	
	cQuery += " WHERE N9D.N9D_FILORG = '" + xFilial("NJR") + "' AND N9D.N9D_TIPMOV = '02' AND N9D.D_E_L_E_T_ = ' ' AND N9D.N9D_STATUS = '2' "
	cQuery += " AND ( "

	If lRestFluig .and. oModel == Nil
	//Se a chamada for via REST-FLUIG e não tem modelo ativo, variavel aRestN7S deve ser private na função chamadora
		For nX := 1 to len(aRestN7S)
			If (nX > 1)
				cQuery +=  " OR "				
			EndIf

			cQuery += " (N9D.N9D_FILIAL = '"+ aRestN7S[nx][5] +"' AND N9D.N9D_CODCTR = '"+ aRestN7S[nx][2] +"' AND N9D.N9D_ITEETG = '"+ aRestN7S[nx][3] +"' AND N9D.N9D_ITEREF = '"+ aRestN7S[nx][4] +"') "			
		Next nX
	Else
		For nX := 1 to oN7S:Length()
			If .not. oN7S:IsDeleted()
				If (nX > 1)
					cQuery +=  " OR "				
				EndIf

				cQuery += " (N9D.N9D_FILIAL = '"+ oN7S:GetValue('N7S_FILORG', nX) +"' AND N9D.N9D_CODCTR = '"+ oN7S:GetValue('N7S_CODCTR', nX) +"' AND N9D.N9D_ITEETG = '"+ oN7S:GetValue('N7S_ITEM', nX) +"' AND N9D.N9D_ITEREF = '"+ oN7S:GetValue('N7S_SEQPRI', nX) +"') "			
			EndIf	
		Next nX
	EndIf

	cQuery += " ) "    	
	cQuery += " GROUP BY N9D.N9D_FILIAL, N9D.N9D_SAFRA, N9D.N9D_BLOCO, DXD.DXD_CLACOM, N9D.N9D_CODCTR, N9D.N9D_ITEETG, N9D.N9D_ITEREF, "
	cQuery += " NNY.NNY_DATINI, NNY.NNY_DATFIM, N83.N83_FRDMAR, N83X.QTD_N83ALLIE, N83.QTD_N83IE,DXI.MEDBRUT_DXIDISP, DXI.MEDLIQU_DXIDISP, N83.QTD_N83IE,DXI2.QTD_DXIIE,DXI2.PSBRUT_DXIIE,DXI2.PSLIQU_DXIIE "

	// Executa a criação da área de acordo com a Query montada.
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cN83Blc, .F., .T.)

	(cN83Blc)->(dbGoTop())
	While !(cN83Blc)->(Eof())

		//Se a chamada não foi via REST
		If !lRestFluig
		
			If ((((cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE) == 0 .AND. (cN83Blc)->QTD_N83IE == 0) .OR.; 
			((cN83Blc)->QTD_N83IE == 0 .AND. (oModel:GetOperation() == MODEL_OPERATION_VIEW .OR. oModel:GetOperation() == MODEL_OPERATION_DELETE)));
			.And. !oModel:IsCopy()
				(cN83Blc)->( dbSkip() )
				LOOP
			EndIf

			If ((cN83Blc)->QTD_N83IE == 0 .And. oModel:IsCopy())
				(cN83Blc)->( dbSkip() )
				LOOP
			EndIf

			//********** Insere/Atualiza dados da grid "Filiais" ********************************
			If !(cAliFil)->(dbSeek((cN83Blc)->FILORG)) 
				RecLock(cAliFil, .T.)
				(cAliFil)->FILORG := (cN83Blc)->FILORG
			Else
				RecLock(cAliFil, .F.)
			EndIF

			If (cN83Blc)->QTD_N83IE > 0 .OR. (oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !oModel:IsCopy())
				(cAliFil)->OK := "OK"
			EndIf

			If oModel:GetOperation() == MODEL_OPERATION_INSERT
				If oModel:IsCopy()
					(cAliFil)->QTFRDSEL += (cN83Blc)->QTD_N83IE
					(cAliFil)->PSBRUSEL += (cN83Blc)->PSBRUT_DXIIE + Round((cN83Blc)->MEDBRUT_DXIDISP * ( (cN83Blc)->QTD_N83IE - (cN83Blc)->QTD_DXIIE ),2) //pode ter sido informado qtd manual no bloco e ter ja sido vinculado fardos deste bloco na IE pelo romaneio por exemplo  
					(cAliFil)->PSLIQSEL += (cN83Blc)->PSLIQU_DXIIE + Round((cN83Blc)->MEDLIQU_DXIDISP * ( (cN83Blc)->QTD_N83IE - (cN83Blc)->QTD_DXIIE ),2) 	
				Else
					(cAliFil)->QTFRDSEL += (cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE
					(cAliFil)->PSBRUSEL += Round( (cN83Blc)->MEDBRUT_DXIDISP * ((cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE ) ,2) //COMO ESTA INCLUIDO PEGA TUDO QUE ESTA DISPONIVEL
					(cAliFil)->PSLIQSEL += Round( (cN83Blc)->MEDLIQU_DXIDISP * ((cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE ) ,2)
				EndIf

				(cAliFil)->QTFRDDIS := 0
				(cAliFil)->PSBRUDIS := 0
				(cAliFil)->PSLIQDIS := 0
			Else
				(cAliFil)->QTFRDSEL += (cN83Blc)->QTD_N83IE				
				(cAliFil)->PSBRUSEL += (cN83Blc)->PSBRUT_DXIIE + Round((cN83Blc)->MEDBRUT_DXIDISP * ( (cN83Blc)->QTD_N83IE - (cN83Blc)->QTD_DXIIE ) ,2)  //pode ter sido informado qtd manual no bloco e ter ja sido vinculado fardos deste bloco na IE pelo romaneio por exemplo  
				(cAliFil)->PSLIQSEL += (cN83Blc)->PSLIQU_DXIIE + Round((cN83Blc)->MEDLIQU_DXIDISP * ( (cN83Blc)->QTD_N83IE - (cN83Blc)->QTD_DXIIE ) ,2) 
				(cAliFil)->QTFRDDIS += (cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE
				(cAliFil)->PSBRUDIS += Round( (cN83Blc)->MEDBRUT_DXIDISP * ((cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE ) ,2)
				(cAliFil)->PSLIQDIS += Round( (cN83Blc)->MEDLIQU_DXIDISP * ((cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE ) ,2)			
			EndIf

			(cAliFil)->QTDINI 	:= (cAliFil)->QTFRDDIS + (cAliFil)->QTFRDSEL
			(cAliFil)->PSBRUINI := (cAliFil)->PSBRUDIS + (cAliFil)->PSBRUSEL
			(cAliFil)->PSLIQINI := (cAliFil)->PSLIQDIS + (cAliFil)->PSLIQSEL

			//********** Insere/Atualiza dados da grid "Blocos" ********************************
			(cAliGrBlc)->(dbSetorder(1))
			If !(cAliGrBlc)->(dbSeek((cN83Blc)->FILORG+(cN83Blc)->SAFRA+(cN83Blc)->BLOCO+(cN83Blc)->TIPO)) 
				RecLock(cAliGrBlc, .T.)
				(cAliGrBlc)->FILORG := (cN83Blc)->FILORG
				(cAliGrBlc)->SAFRA  := (cN83Blc)->SAFRA
				(cAliGrBlc)->BLOCO  := (cN83Blc)->BLOCO
				(cAliGrBlc)->TIPO   := (cN83Blc)->TIPO
			Else
				RecLock(cAliGrBlc, .F.)
			EndIF

			If  (cN83Blc)->QTD_N83IE > 0 .Or. (!oModel:IsCopy() .and. oModel:GetOperation() == MODEL_OPERATION_INSERT )
				(cAliGrBlc)->OK	:= "OK"
			EndIf

			If oModel:GetOperation() == MODEL_OPERATION_INSERT
				If oModel:IsCopy()
					(cAliGrBlc)->QTFRDSEL += (cN83Blc)->QTD_N83IE 
					(cAliGrBlc)->PSBRUSEL += (cN83Blc)->PSBRUT_DXIIE + Round((cN83Blc)->MEDBRUT_DXIDISP * ( (cN83Blc)->QTD_N83IE - (cN83Blc)->QTD_DXIIE ) ,2)  //pode ter sido informado qtd manual no bloco e ter ja sido vinculado fardos deste bloco na IE pelo romaneio por exemplo  
					(cAliGrBlc)->PSLIQSEL += (cN83Blc)->PSLIQU_DXIIE + Round((cN83Blc)->MEDLIQU_DXIDISP * ( (cN83Blc)->QTD_N83IE - (cN83Blc)->QTD_DXIIE ) ,2) 
				Else
					(cAliGrBlc)->QTFRDSEL += (cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE 
					(cAliGrBlc)->PSBRUSEL += Round((cN83Blc)->MEDBRUT_DXIDISP * ((cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE) ,2) //COMO ESTA INCLUIDO PEGA TUDO QUE ESTA DISPONIVEL
					(cAliGrBlc)->PSLIQSEL += Round((cN83Blc)->MEDLIQU_DXIDISP * ((cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE) ,2)

				EndIf

				(cAliGrBlc)->QTFRDDIS := 0	
				(cAliGrBlc)->PSBRUDIS := 0
				(cAliGrBlc)->PSLIQDIS := 0			
				(cAliGrBlc)->QTDRESER += (cN83Blc)->QTD_RESERVA 	
			Else							
				(cAliGrBlc)->QTFRDSEL += (cN83Blc)->QTD_N83IE   
				(cAliGrBlc)->PSBRUSEL += (cN83Blc)->PSBRUT_DXIIE + round( ((cN83Blc)->MEDBRUT_DXIDISP * ( (cN83Blc)->QTD_N83IE - (cN83Blc)->QTD_DXIIE )),2) //pode ter sido informado qtd manual no bloco e ter ja sido vinculado fardos deste bloco na IE pelo romaneio por exemplo
				(cAliGrBlc)->PSLIQSEL += (cN83Blc)->PSLIQU_DXIIE + round( ((cN83Blc)->MEDLIQU_DXIDISP * ( (cN83Blc)->QTD_N83IE - (cN83Blc)->QTD_DXIIE )),2)
				(cAliGrBlc)->QTFRDDIS += (cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE 	
				(cAliGrBlc)->PSBRUDIS += round( (cN83Blc)->MEDBRUT_DXIDISP * ((cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE) ,2)
				(cAliGrBlc)->PSLIQDIS += round( (cN83Blc)->MEDLIQU_DXIDISP * ((cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE) ,2)		
				(cAliGrBlc)->QTDRESER += (cN83Blc)->QTD_RESERVA 	
			EndIf
		
			(cAliGrBlc)->PSBRUMED := ( (cAliGrBlc)->PSBRUDIS / (cAliGrBlc)->QTFRDDIS ) //MEDIA DE PESO BRUTO DOS FARDOS DISPONIVEIS NÃO VINCULADOS A ESTA IE E EM NUNHUMA OUTRA IE
			(cAliGrBlc)->PSLIQMED := ( (cAliGrBlc)->PSLIQDIS / (cAliGrBlc)->QTFRDDIS )
			(cAliGrBlc)->QTDINI   := (cAliGrBlc)->QTFRDDIS + (cAliGrBlc)->QTFRDSEL
			(cAliGrBlc)->PSBRUINI := (cAliGrBlc)->PSBRUDIS + (cAliGrBlc)->PSBRUSEL
			(cAliGrBlc)->PSLIQINI := (cAliGrBlc)->PSLIQDIS + (cAliGrBlc)->PSLIQSEL
			(cAliGrBlc)->FRDMAR	  := IIF(empty((cN83Blc)->FRDMAR),"1",(cN83Blc)->FRDMAR)

			(cAliGrBlc)->(MSUnlock())

			//********** Insere/Atualiza dados do nível "Bloco" da Tree ********************************
			If !(cAliasBloc)->(dbSeek(oN7Q:GetValue("N7Q_CODINE")+(cN83Blc)->CODCTR+(cN83Blc)->CADENC+(cN83Blc)->ITEREF+(cN83Blc)->FILORG+(cN83Blc)->BLOCO))

				dDataIni := cToD(SUBSTR((cN83Blc)->DAT_INICAD, 7, 2) + "/" + SUBSTR((cN83Blc)->DAT_INICAD, 5, 2) + "/" + SUBSTR((cN83Blc)->DAT_INICAD, 1, 4))
				dDataFim := cToD(SUBSTR((cN83Blc)->DAT_FIMCAD, 7, 2) + "/" + SUBSTR((cN83Blc)->DAT_FIMCAD, 5, 2) + "/" + SUBSTR((cN83Blc)->DAT_FIMCAD, 1, 4))

				RecLock(cAliasBloc, .T.)					
				(cAliasBloc)->T_CODINE   := oN7Q:GetValue("N7Q_CODINE")
				(cAliasBloc)->T_CONTRATO := (cN83Blc)->CODCTR
				(cAliasBloc)->T_CADENCIA := (cN83Blc)->CADENC
				(cAliasBloc)->T_ITEREF	 := (cN83Blc)->ITEREF
				(cAliasBloc)->T_DATAINI  := dDataIni
				(cAliasBloc)->T_DATAFIM  := dDataFim						
				(cAliasBloc)->T_FILORG   := (cN83Blc)->FILORG
				(cAliasBloc)->T_SAFRA  	 := (cN83Blc)->SAFRA
				(cAliasBloc)->T_BLOCO    := (cN83Blc)->BLOCO
				(cAliasBloc)->T_TIPO     := (cN83Blc)->TIPO
				(cAliasBloc)->T_FRDMAR 	 := IIf(Empty((cN83Blc)->FRDMAR),"1",(cN83Blc)->FRDMAR)		
			Else
				RecLock(cAliasBloc, .F.)
			EndIf

			If oModel:GetOperation() == MODEL_OPERATION_INSERT
				If oModel:IsCopy()
					(cAliasBloc)->T_QTFRDSEL += (cN83Blc)->QTD_N83IE
					(cAliasBloc)->T_PSBRUSEL += (cN83Blc)->PSBRUT_DXIIE + round( ((cN83Blc)->MEDBRUT_DXIDISP * ( (cN83Blc)->QTD_N83IE - (cN83Blc)->QTD_DXIIE )) ,2) //pode ter sido informado qtd manual no bloco e ter ja sido vinculado fardos deste bloco na IE pelo romaneio por exemplo			  
					(cAliasBloc)->T_PSLIQSEL += (cN83Blc)->PSLIQU_DXIIE + round( ((cN83Blc)->MEDLIQU_DXIDISP * ( (cN83Blc)->QTD_N83IE - (cN83Blc)->QTD_DXIIE ))	,2)
				Else
					(cAliasBloc)->T_QTFRDSEL += (cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE
					(cAliasBloc)->T_PSBRUSEL += Round((cN83Blc)->MEDBRUT_DXIDISP * ((cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE) ,2) //COMO ESTA INCLUIDO PEGA TUDO QUE ESTA DISPONIVEL			  
					(cAliasBloc)->T_PSLIQSEL += Round((cN83Blc)->MEDLIQU_DXIDISP * ((cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE) ,2)	
				EndIf

				(cAliasBloc)->T_QTFRDDIS := 0	
				(cAliasBloc)->T_PSLIQDIS := 0
				(cAliasBloc)->T_PSBRUDIS := 0
			Else	
				// SE ALTERANDO IE
				(cAliasBloc)->T_QTFRDSEL += (cN83Blc)->QTD_N83IE   			
				(cAliasBloc)->T_PSBRUSEL += (cN83Blc)->PSBRUT_DXIIE + Round( ((cN83Blc)->MEDBRUT_DXIDISP * ( (cN83Blc)->QTD_N83IE - (cN83Blc)->QTD_DXIIE )) ,2) //pode ter sido informado qtd manual no bloco e ter ja sido vinculado fardos deste bloco na IE pelo romaneio por exemplo
				(cAliasBloc)->T_PSLIQSEL += (cN83Blc)->PSLIQU_DXIIE + Round( ((cN83Blc)->MEDLIQU_DXIDISP * ( (cN83Blc)->QTD_N83IE - (cN83Blc)->QTD_DXIIE )) ,2)
				(cAliasBloc)->T_QTFRDDIS += (cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE 	
				(cAliasBloc)->T_PSBRUDIS += Round( (cN83Blc)->MEDBRUT_DXIDISP * ((cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE ), 2)
				(cAliasBloc)->T_PSLIQDIS += Round( (cN83Blc)->MEDLIQU_DXIDISP * ((cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE ), 2)
			EndIf

			(cAliasBloc)->T_PSBRUMED := ( (cAliasBloc)->T_PSBRUDIS / (cAliasBloc)->T_QTFRDDIS ) //MEDIA DE PESO BRUTO DOS FARDOS DISPONIVEIS NÃO VINCULADOS A ESTA IE E EM NUNHUMA OUTRA IE	
			(cAliasBloc)->T_PSLIQMED := ( (cAliasBloc)->T_PSLIQDIS / (cAliasBloc)->T_QTFRDDIS )
			(cAliasBloc)->T_QTDINI   := (cAliasBloc)->T_QTFRDDIS + (cAliasBloc)->T_QTFRDSEL
			(cAliasBloc)->T_PSLIQINI := (cAliasBloc)->T_PSLIQDIS + (cAliasBloc)->T_PSLIQSEL
			(cAliasBloc)->T_PSBRUINI := (cAliasBloc)->T_PSBRUDIS + (cAliasBloc)->T_PSBRUSEL
		
		Else//se a chamada for via REST

			dDataIni := cToD(SUBSTR((cN83Blc)->DAT_INICAD, 7, 2) + "/" + SUBSTR((cN83Blc)->DAT_INICAD, 5, 2) + "/" + SUBSTR((cN83Blc)->DAT_INICAD, 1, 4))
			dDataFim := cToD(SUBSTR((cN83Blc)->DAT_FIMCAD, 7, 2) + "/" + SUBSTR((cN83Blc)->DAT_FIMCAD, 5, 2) + "/" + SUBSTR((cN83Blc)->DAT_FIMCAD, 1, 4))
			
			If !(cAliasBloc)->(dbSeek(cCodIne+(cN83Blc)->CODCTR+(cN83Blc)->CADENC+(cN83Blc)->ITEREF+(cN83Blc)->FILORG+(cN83Blc)->BLOCO))
				RecLock(cAliasBloc, .T.)					
				(cAliasBloc)->T_CODINE   := cCodIne
				(cAliasBloc)->T_CONTRATO := (cN83Blc)->CODCTR
				(cAliasBloc)->T_CADENCIA := (cN83Blc)->CADENC
				(cAliasBloc)->T_ITEREF	 := (cN83Blc)->ITEREF
				(cAliasBloc)->T_DATAINI  := dDataIni
				(cAliasBloc)->T_DATAFIM  := dDataFim						
				(cAliasBloc)->T_FILORG   := (cN83Blc)->FILORG
				(cAliasBloc)->T_SAFRA  	 := (cN83Blc)->SAFRA
				(cAliasBloc)->T_BLOCO    := (cN83Blc)->BLOCO
				(cAliasBloc)->T_TIPO     := (cN83Blc)->TIPO
				(cAliasBloc)->T_FRDMAR 	 := IIf(Empty((cN83Blc)->FRDMAR),"1",(cN83Blc)->FRDMAR)	
			Else
				RecLock(cAliasBloc, .F.)
			EndIf		

			(cAliasBloc)->T_QTFRDSEL += (cN83Blc)->QTD_N83IE   			
			(cAliasBloc)->T_PSBRUSEL += (cN83Blc)->PSBRUT_DXIIE + Round( ((cN83Blc)->MEDBRUT_DXIDISP * ( (cN83Blc)->QTD_N83IE - (cN83Blc)->QTD_DXIIE )) ,2) //pode ter sido informado qtd manual no bloco e ter ja sido vinculado fardos deste bloco na IE pelo romaneio por exemplo
			(cAliasBloc)->T_PSLIQSEL += (cN83Blc)->PSLIQU_DXIIE + Round( ((cN83Blc)->MEDLIQU_DXIDISP * ( (cN83Blc)->QTD_N83IE - (cN83Blc)->QTD_DXIIE )) ,2)
			(cAliasBloc)->T_QTFRDDIS += (cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE 	
			(cAliasBloc)->T_PSBRUDIS += Round( (cN83Blc)->MEDBRUT_DXIDISP * ((cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE ), 2)
			(cAliasBloc)->T_PSLIQDIS += Round( (cN83Blc)->MEDLIQU_DXIDISP * ((cN83Blc)->QTD_RESERVA - (cN83Blc)->QTD_N83ALLIE ), 2)
			
			(cAliasBloc)->T_PSBRUMED := ( (cAliasBloc)->T_PSBRUDIS / (cAliasBloc)->T_QTFRDDIS ) //MEDIA DE PESO BRUTO DOS FARDOS DISPONIVEIS NÃO VINCULADOS A ESTA IE E EM NUNHUMA OUTRA IE	
			(cAliasBloc)->T_PSLIQMED := ( (cAliasBloc)->T_PSLIQDIS / (cAliasBloc)->T_QTFRDDIS )
			(cAliasBloc)->T_QTDINI   := (cAliasBloc)->T_QTFRDDIS + (cAliasBloc)->T_QTFRDSEL
			(cAliasBloc)->T_PSLIQINI := (cAliasBloc)->T_PSLIQDIS + (cAliasBloc)->T_PSLIQSEL
			(cAliasBloc)->T_PSBRUINI := (cAliasBloc)->T_PSBRUDIS + (cAliasBloc)->T_PSBRUSEL
			/************************************************* */
		EndIf

		(cAliasBloc)->(MsUnLock())	

		(cN83Blc)->( dbSkip() )
	EndDo
	
	If lRestFluig
		cRestAliBlc := cAliasBloc
	EndIf

	(cN83Blc)->(dbCloseArea())

Return

/*{Protheus.doc} AtuBrwBlc - Atualiza a grid "Blocos"
@author vanilda.moggio
@since 10/10/2017
@version undefined
@param oPanel, object, descricao
@param oObj, object, descricao
@type function
*/
Function AtuBrwBlc()
	Local aHeader	 := {}
	Local aCpFiltro  := {}
	Local lActivate  := .F.
	Local oModel	 := FwModelActive()
	Local nOperation := oModel:GetOperation()

	// Campos que serão mostrados na grid
	aAdd(aHeader, {STR0062	,{||(cAliGrBlc)->FILORG}   , 'C' ,'@!'    					, 1 ,TamSX3("N83_FILORG")[1] ,TamSX3("N83_FILORG")[2] ,.F.})
	aAdd(aHeader, {STR0075  ,{||(cAliGrBlc)->SAFRA}    , 'C' ,"@!"						, 1 ,TamSX3("N83_SAFRA") [1] ,TamSX3("N83_SAFRA") [2] ,.F.})
	aAdd(aHeader, {STR0063	,{||(cAliGrBlc)->BLOCO}    , 'C' ,"@!"						, 1 ,TamSX3("N83_BLOCO") [1] ,TamSX3("N83_BLOCO") [2] ,.F.})
	aAdd(aHeader, {STR0074	,{||(cAliGrBlc)->TIPO}     , 'C' ,"@!"						, 1 ,TamSX3("N83_TIPO")  [1] ,TamSX3("N83_TIPO")  [2] ,.F.})
	aAdd(aHeader, {STR0067	,{||(cAliGrBlc)->QTFRDSEL} , 'N' ,"@E 99,999"				, 1 ,TamSX3("N83_QUANT") [1] ,TamSX3("N83_QUANT") [2] ,.T.})
	aAdd(aHeader, {STR0068	,{||(cAliGrBlc)->PSBRUSEL} , 'N' ,"@E 99,999,999,999.99"    , 1 ,TamSX3("N83_PSBRUT")[1] ,TamSX3("N83_PSBRUT")[2] ,.F.})
	aAdd(aHeader, {STR0069	,{||(cAliGrBlc)->PSLIQSEL} , 'N' ,"@E 99,999,999,999.99"	, 1 ,TamSX3("N83_PSLIQU")[1] ,TamSX3("N83_PSLIQU")[2] ,.F.})
	aAdd(aHeader, {STR0070	,{||(cAliGrBlc)->QTFRDDIS} , 'N' ,"@E 99,999"				, 1 ,TamSX3("N83_QUANT")[1],  TamSX3("N83_QUANT")[2] ,.F.})
	aAdd(aHeader, {STR0071	,{||(cAliGrBlc)->PSBRUDIS} , 'N' ,"@E 99,999,999,999.99"	, 1 ,TamSX3("N83_PSBRUT")[1] ,TamSX3("N83_PSBRUT")[2] ,.F.})
	aAdd(aHeader, {STR0072	,{||(cAliGrBlc)->PSLIQDIS} , 'N' ,"@E 99,999,999,999.99"	, 1 ,TamSX3("N83_PSLIQU")[1] ,TamSX3("N83_PSLIQU")[2] ,.F.})

	// Campos para o botão de filtro
	AAdd(aCpFiltro, {"FILORG"	,STR0062	,"C",TamSX3("N83_FILORG")[1],TamSX3("N83_FILORG")[2],"@!"					}) 
	AAdd(aCpFiltro, {"SAFRA" 	,STR0075    ,"C",TamSX3("N83_SAFRA")[1] ,TamSX3("N83_SAFRA")[2] ,"@!"					}) 
	AAdd(aCpFiltro, {"BLOCO" 	,STR0063    ,"C",TamSX3("N83_BLOCO")[1] ,TamSX3("N83_BLOCO")[2] ,"@!"					}) 
	AAdd(aCpFiltro, {"TIPO"  	,STR0074	,"C",TamSX3("N83_TIPO")[1]  ,TamSX3("N83_TIPO")[2]  ,"@!"					}) 
	AAdd(aCpFiltro, {"QTFRDSEL" ,STR0067	,"N",TamSX3("N83_QUANT")[1] ,TamSX3("N83_QUANT")[2] ,"@E 99,999"			}) 
	AAdd(aCpFiltro, {"PSBRUSEL"	,STR0068	,"N",TamSX3("N83_PSBRUT")[1],TamSX3("N83_PSBRUT")[2],"@E 99,999,999,999.99"	}) 
	AAdd(aCpFiltro, {"PSLIQSEL"	,STR0069	,"N",TamSX3("N83_PSLIQU")[1],TamSX3("N83_PSLIQU")[2],"@E 99,999,999,999.99"	}) 
	AAdd(aCpFiltro, {"QTFRDDIS"	,STR0070	,"N",TamSX3("N83_QUANT")[1],TamSX3("N83_QUANT")[2], "@E 99,999"			}) 
	AAdd(aCpFiltro, {"PSBRUDIS"	,STR0071	,"N",TamSX3("N83_PSBRUT")[1],TamSX3("N83_PSBRUT")[2],"@E 99,999,999,999.99"	}) 
	AAdd(aCpFiltro, {"PSLIQDIS"	,STR0072	,"N",TamSX3("N83_PSLIQU")[1],TamSX3("N83_PSLIQU")[2],"@E 99,999,999,999.99"	}) 

	lActivate := .T.

	oBrwBlc:SetDataTable(.T.)
	oBrwBlc:SetAlias(cAliGrBlc)
	oBrwBlc:SetProfileID('2')
	oBrwBlc:Acolumns:= {}
	oBrwBlc:AddMarkColumns({|| Iif((cAliGrBlc)->OK == "OK", "LBOK", "LBNO")},{ || Marcar(oBrwBlc,2,nOperation)},{|| MarkAll(oBrwBlc,lMarkBlc,2,nOperation)})

	oBrwBlc:AddLegend( "STCONT = 1 "	, "GREEN"		, STR0176	) //"Liberado"
	oBrwBlc:AddLegend( "STCONT = 2 "	, "YELLOW"		, STR0177	) //"Sem Resultado"
	oBrwBlc:AddLegend( "STCONT = 3 "	, "RED"			, STR0178	) //"Resultado Fora da Faixa Estabelecida"
	oBrwBlc:aColumns[2]:cTitle := STR0179 //"Sts.Qualid"

	oBrwBlc:setcolumns( aHeader )
	oBrwBlc:DisableReport()
	oBrwBlc:DisableConfig()
	oBrwBlc:SetFieldFilter( aCpFiltro ) // Seta os campos para o botão filtro
	oBrwBlc:SetUseFilter() // Ativa filtro

	If nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE
		oBrwBlc:SetEditCell( .T. , {||VldQtdBlc(oBrwBlc) }) // Permite edição na grid
		oBrwBlc:acolumns[7]:SetEdit(.T.)
		oBrwBlc:acolumns[7]:SetReadVar('QTFRDSEL')
	EndIf

	oBrwBlc:SetPreEditCell( { || ValPerm(2) } )//Verifica se o usuário tem permissão de informar a quantidade de fardos para o bloco

	If lActivate
		oBrwBlc:Activate()
	EndIf

	oBrwBlc:Enable()
	oBrwBlc:Refresh(.T.)

Return

/*{Protheus.doc} CriaStrFrd - Cria a estrutura da tabela temporária da grid "Fardos"
@author Francisco Kennedy Nunes Pinheiro
@since 06/11/2017
@version 1.0
@type function
*/
Function CriaStrFrd()
	Local aStruct	:= {{"OK", "C", 2, 0}}	

	AAdd(aStruct, {"CODINE"	   	, "C", TamSX3("DXI_CODINE")[1], TamSX3("DXI_CODINE")[2]})
	AAdd(aStruct, {"FILORG"	   	, "C", TamSX3("DXQ_FILORG")[1], TamSX3("DXQ_FILORG")[2]})
	AAdd(aStruct, {"CODCTR"	   	, "C", TamSX3("DXQ_CODCTP")[1], TamSX3("DXQ_CODCTP")[2]})
	AAdd(aStruct, {"CADENC"	    , "C", TamSX3("N7S_ITEM")[1]  , TamSX3("N7S_ITEM")[2]})
	AAdd(aStruct, {"ITEREF"	    , "C", TamSX3("N7S_SEQPRI")[1], TamSX3("N7S_SEQPRI")[2]})
	AAdd(aStruct, {"BLOCO"     	, "C", TamSX3("DXQ_BLOCO" )[1], TamSX3("DXQ_BLOCO" )[2]})
	AAdd(aStruct, {"CLACOM"    	, "C", TamSX3("DXI_CLACOM" )[1],TamSX3("DXI_CLACOM" )[2]})
	AAdd(aStruct, {"FARDO"		, "C", TamSX3("DXI_CODIGO")[1], TamSX3("DXI_CODIGO")[2]})
	AAdd(aStruct, {"DESCSTS"	, "C", 30, 0})
	AAdd(aStruct, {"ETIQ"		, "C", TamSX3("DXI_ETIQ")[1]  , TamSX3("DXI_ETIQ")[2]})
	AAdd(aStruct, {"PSLIQU"    	, "N", TamSX3("DXI_PSLIQU")[1], TamSX3("DXI_PSLIQU")[2]})
	AAdd(aStruct, {"PSBRUT"	   	, "N", TamSX3("DXI_PSBRUT")[1], TamSX3("DXI_PSBRUT")[2]})
	AAdd(aStruct, {"SAFRA"		, "C", TamSX3("DXI_SAFRA" )[1], TamSX3("DXI_SAFRA")[2] })
	AAdd(aStruct, {"ROMFLO"		, "C", TamSX3("DXI_ROMFLO")[1], TamSX3("DXI_ROMFLO")[2]})	
	AAdd(aStruct, {"CONTNR"		, "C", TamSX3("DXI_CONTNR")[1], TamSX3("DXI_CONTNR")[2]})
	AAdd(aStruct, {"PESSAI"		, "N", TamSX3("DXI_PESSAI")[1], TamSX3("DXI_PESSAI")[2]})
	AAdd(aStruct, {"PESCHE"		, "N", TamSX3("DXI_PESCHE")[1], TamSX3("DXI_PESCHE")[2]})
	AAdd(aStruct, {"PESCER"		, "N", TamSX3("DXI_PESCER")[1], TamSX3("DXI_PESCER")[2]})
	AAdd(aStruct, {"STCONT"		, "N", 1					  , 0 }) //status contaminante
	AAdd(aStruct, {"STATUS"		, "C", TamSX3("DXI_STATUS")[1], TamSX3("DXI_STATUS")[2]})

	cAliFrd	  := GetNextAlias()	
	oArqTempFrd := AGRCRTPTB(cAliFrd, {aStruct, {{"","FILORG,SAFRA,BLOCO,FARDO"},{"","FILORG,BLOCO,CODCTR,CADENC"},{"","CODCTR,CADENC,FILORG,BLOCO"},{"","FILORG,FARDO"},{"","CONTNR"}}})

	// Carrega dados na grid "Fardos"
	LoadGrFrd()	

Return

/*{Protheus.doc} LoadGrFrd - Carrega dados grid "Blocos"
@author francisco.nunes
@since 28/09/2017
@version 1
@param lChange, logical, descricao
@type function
*/
Function LoadGrFrd()
	Local oModel	 := FwModelActive()
	Local oN7Q 		 := oModel:GetModel("N7QUNICO") //IE
	Local oN7S 		 := oModel:GetModel("N7SUNICO") //ENTREGA
	Local nX      	 := 0
	Local nOperation := oModel:GetOperation()	
	Local cFilAnt	 := ""
	Local cBlcAnt    := ""
	Local aBlcContam := {}
	Local nPos       := 0

	// Limpa a tabela temporária de fardos
	dbSelectArea(cAliFrd)
	(cAliFrd)->( dbSetorder(1) )
	ZAP

	cQuery := "SELECT N9D.N9D_FILIAL AS FILORG, " 
	cQuery += " 	  DXI.DXI_STATUS AS STATUSFRD, "
	cQuery += " 	  N9D.N9D_SAFRA  AS SAFRA, "
	cQuery += " 	  N9D.N9D_BLOCO  AS BLOCO, "
	cQuery += " 	  N9D.N9D_CODCTR AS CODCTR, "
	cQuery += " 	  N9D.N9D_ITEETG AS CADENC, "
	cQuery += " 	  N9D.N9D_ITEREF AS ITEREF, "	
	cQuery += " 	  DXI.DXI_ETIQ   AS ETIQ, "	
	cQuery += " 	  DXI.DXI_CODIGO AS FARDO, " 
	cQuery += " 	  DXI.DXI_CODINE AS IE, "
	cQuery += " 	  DXI.DXI_PSBRUT AS QTD_PSBRUT, "	
	cQuery += "		  DXI.DXI_PSLIQU AS QTD_PSLIQU, "
	cQuery += " 	  DXI.DXI_ROMFLO AS ROMFLO,"
	cQuery += " 	  DXI.DXI_CLACOM AS CLACOM, "
	cQuery += " 	  DXI.DXI_CONTNR AS CONTNR, "
	cQuery += " 	  DXI.DXI_PESSAI AS PESSAI, "
	cQuery += " 	  DXI.DXI_PESCHE AS PESCHE, "
	cQuery += " 	  DXI.DXI_PSESTO AS PSESTO, "
	cQuery += " 	  DXI.DXI_PSTARA AS PSTARA, "
	cQuery += " 	  DXI.DXI_PESCER AS PESCER, "
	cQuery += " 	  QTDCONTAMCTR "
	cQuery += " FROM " + RetSqlName("N9D") + " N9D "
	cQuery += " INNER JOIN " + RetSqlName("DXI") + " DXI ON DXI.DXI_FILIAL = N9D.N9D_FILIAL AND DXI.DXI_SAFRA = N9D.N9D_SAFRA AND DXI.DXI_ETIQ = N9D.N9D_FARDO AND DXI.D_E_L_E_T_ = ' ' "

	//Verifica se tem cadastro de contaminante para o contrato
	cQuery += " LEFT OUTER JOIN (SELECT N9O_CODCTR,COUNT(N9O_CODCTR) AS QTDCONTAMCTR "  
	cQuery += " FROM " + RetSqlName("N9O")
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND N9O_FILIAL = '" + xFilial("N9O") + "' "
	cQuery += " GROUP BY N9O_CODCTR) "
	cQuery += " N9O ON N9O.N9O_CODCTR = N9D_CODCTR "

	// Realiza a leitura na tabela N9D (Movimento dos fardos) pelo movimento 02 - Reserva		
	cQuery += " WHERE N9D.N9D_FILORG = '" + xFilial("NJR") + "' AND N9D.N9D_TIPMOV  = '02' AND N9D.D_E_L_E_T_  = ' ' AND N9D.N9D_STATUS  = '2' "		
	cQuery += " AND ( "

	For nX := 1 to oN7S:Length()
		If .not. oN7S:IsDeleted()
			If (nX > 1)
				cQuery +=  " OR "				
			EndIf

			cQuery += " (N9D.N9D_FILIAL = '"+ oN7S:GetValue('N7S_FILORG', nX) +"' AND N9D.N9D_CODCTR = '"+ oN7S:GetValue('N7S_CODCTR', nX) +"' AND N9D.N9D_ITEETG = '"+ oN7S:GetValue('N7S_ITEM', nX) +"' AND N9D.N9D_ITEREF = '"+ oN7S:GetValue('N7S_SEQPRI', nX) +"') "			
		EndIf	
	Next nX

	cQuery += " ) "

	If nOperation = 3 .And. !oModel:IsCopy()/*se for inserção, traz somente os fardos reservados que ainda não estão vinculados a outras IE*/
		cQuery += " AND DXI.DXI_CODINE = '' "
	ElseIf nOperation = 3 .And. oModel:IsCopy()
		cQuery += " and DXI.DXI_CODINE = '"+ N7Q->N7Q_CODINE +"' "
	ElseIf nOperation = 4/*se for alteração traz os fardos já vinculados e os disponíveis*/
		cQuery += " AND  (DXI.DXI_CODINE = '' OR DXI.DXI_CODINE = '"+ oN7Q:GetValue('N7Q_CODINE') +"') " 
	ElseIf (nOperation <> 3 .And. nOperation <> 4) /*se for visualização ou exclusão traz somente os fardos vinculados*/
		cQuery += " AND DXI.DXI_CODINE =  '"+ oN7Q:GetValue('N7Q_CODINE') +"' "
	EndIf

	cQuery += " ORDER BY N9D.N9D_CODCTR, N9D.N9D_ITEETG, N9D.N9D_ITEREF, N9D.N9D_FILIAL, N9D.N9D_SAFRA, N9D.N9D_BLOCO, DXI.DXI_CODIGO "

	// Executa a criação da área de acordo com a Query montada.
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cDXIFrd, .F., .T.)

	(cDXIFrd)->( dbGoTop() )
	While !(cDXIFrd)->( Eof() )

		// Insere/Atualiza dados da grid "Fardos"
		RecLock(cAliFrd, .T.)
		(cAliFrd)->CODINE	  := (cDXIFrd)->IE
		(cAliFrd)->CODCTR	  := (cDXIFrd)->CODCTR 
		(cAliFrd)->CADENC 	  := (cDXIFrd)->CADENC 
		(cAliFrd)->ITEREF 	  := (cDXIFrd)->ITEREF
		(cAliFrd)->FILORG     := (cDXIFrd)->FILORG 	
		(cAliFrd)->BLOCO  	  := (cDXIFrd)->BLOCO
		(cAliFrd)->SAFRA  	  := (cDXIFrd)->SAFRA
		(cAliFrd)->FARDO      := (cDXIFrd)->FARDO 
		(cAliFrd)->CLACOM     := (cDXIFrd)->CLACOM 
		(cAliFrd)->ETIQ       := (cDXIFrd)->ETIQ 
		(cAliFrd)->ROMFLO     := (cDXIFrd)->ROMFLO		
		(cAliFrd)->CONTNR     := (cDXIFrd)->CONTNR  
		(cAliFrd)->PESSAI 	  := Round((cDXIFrd)->PESSAI,2)
		(cAliFrd)->PESCHE     := Round((cDXIFrd)->PESCHE,2)
		(cAliFrd)->PESCER     := Round((cDXIFrd)->PESCER,2)
		(cAliFrd)->DESCSTS	  := Posicione( "SX5", 1, xFilial( "SX5" ) + "KE" + (cDXIFrd)->STATUSFRD, "X5_DESCRI" )  


		IF (cDXIFrd)->PESCER > 0 
			(cAliFrd)->PSLIQU     := Round((cDXIFrd)->PESCER,2)

		ElseIf (cDXIFrd)->PESSAI > 0
			(cAliFrd)->PSLIQU     := Round((cDXIFrd)->PESSAI,2)

		ElseIf (cDXIFrd)->PSESTO > 0
			(cAliFrd)->PSLIQU     := Round((cDXIFrd)->PSESTO,2)

		Else   
			(cAliFrd)->PSLIQU     := Round((cDXIFrd)->QTD_PSLIQU,2)
		EndIF

		(cAliFrd)->PSBRUT := Round((cAliFrd)->PSLIQU ,2) + Round((cDXIFrd)->PSTARA ,2) 

		// Se passou para outra filial ou bloco
		If cFilAnt != (cAliFrd)->(FILORG) .Or. cBlcAnt != (cAliFrd)->(BLOCO)
			cFilAnt := (cAliFrd)->(FILORG)
			cBlcAnt := (cAliFrd)->(BLOCO)

			/* Consulta informações do bloco (Quantidade Selecionada, Quantidade Disponível, etc...) */
			aInfBlc := ConsInfBlc((cAliFrd)->FILORG, (cAliFrd)->BLOCO)

			// Quantidade Selecionada + Quantidade Disponível
			nQtdTotal := aInfBlc[1] + aInfBlc[2] 						

			nQtdFrdSel := 0		
		EndIf	

		If  !oModel:IsCopy() .and. ( (cDXIFrd)->IE == oN7Q:GetValue("N7Q_CODINE") .Or. (oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. nQtdTotal >= (nQtdFrdSel + 1))) 
			(cAliFrd)->OK := "OK"
		ElseIf (oModel:IsCopy() .and. (cDXIFrd)->IE == N7Q->N7Q_CODINE)
			(cAliFrd)->OK := "OK"
		EndIf

		nQtdFrdSel := nQtdFrdSel + 1

		If (cDXIFrd)->QTDCONTAMCTR > 0 //se tem no contrato cadastro de contaminante
			//busca o status do contaminante para o fardo, sendo 1=liberado,2=sem resultado e 3=resultado fora da faixa
			(cAliFrd)->STCONT := RESCONTFRD( (cAliFrd)->(FILORG), (cAliFrd)->(ETIQ),(cAliFrd)->(SAFRA) )
		Else
			(cAliFrd)->STCONT := 1 //liberado
		EndIf

		nPos := aScan( aBlcContam, { |x| AllTrim( x[1] ) == AllTrim((cDXIFrd)->FILORG+(cDXIFrd)->BLOCO) } )
		If nPos == 0
			aAdd( aBlcContam, { (cDXIFrd)->FILORG+(cDXIFrd)->BLOCO, (cAliFrd)->STCONT } )
		Else
			If aBlcContam[nPos][2] < (cAliFrd)->STCONT
				aBlcContam[nPos][2] := (cAliFrd)->STCONT
			EndIf
		EndIf

		(cAliFrd)->STATUS := (cDXIFrd)->STATUSFRD //STATUS FARDO DXI_STATUS

		(cAliFrd)->( MSUnlock() )	

		(cDXIFrd)->( dbSkip() )
	EndDo

	(cDXIFrd)->(dbCloseArea())

	For nX := 1 to Len(aBlcContam)
		dbSelectArea(cAliGrBlc)
		dbSetOrder(2)
		If dbSeek(aBlcContam[nX][1])
			RecLock(cAliGrBlc, .f.)
			(cAliGrBlc)->STCONT := aBlcContam[nX][2]
			(cAliGrBlc)->( MSUnlock() )
		EndIf
	Next nX

Return

/*{Protheus.doc} AtuBrwFrd - Atualiza a grid "Fardos"
@author francisco.nunes
@since 28/09/2017
@version 1
@type function
*/
Function AtuBrwFrd()
	Local aHeader	 := {}
	Local aCpFiltro  := {}
	Local lActivate  := .F.
	Local oModel	 := FwModelActive()
	Local nOperation := oModel:GetOperation()

	// Campos que serão mostrados na grid	
	aAdd(aHeader, {STR0062, {||(cAliFrd)->FILORG},'C','@!'    				,1,TamSX3("DXQ_FILORG")[1],TamSX3("DXQ_FILORG")[2],.F.})
	aAdd(aHeader, {STR0075, {||(cAliFrd)->SAFRA} ,'C','@!'    				,1,TamSX3("DXI_SAFRA" )[1],TamSX3("DXI_SAFRA" )[2],.F.})
	aAdd(aHeader, {STR0063, {||(cAliFrd)->BLOCO} ,'C','@!'    				,1,TamSX3("DXQ_BLOCO" )[1],TamSX3("DXQ_BLOCO" )[2],.F.})
	aAdd(aHeader, {STR0064, {||(cAliFrd)->FARDO} ,'C','@!'    				,1,TamSX3("DXI_CODIGO")[1],TamSX3("DXI_CODIGO")[2],.F.})
	aAdd(aHeader, {STR0217, {||(cAliFrd)->DESCSTS},'C','@!'    				,1,30,0,.F.})
	aAdd(aHeader, {STR0074, {||(cAliFrd)->CLACOM},'C','@!'    				,1,TamSX3("DXI_CLACOM")[1],TamSX3("DXI_CLACOM")[2],.F.})
	aAdd(aHeader, {STR0077, {||(cAliFrd)->PSLIQU},'N',"@E 99,999,999,999.99",1,TamSX3("DXI_PSLIQU")[1],TamSX3("DXI_PSLIQU")[2],.F.})
	aAdd(aHeader, {STR0078, {||(cAliFrd)->PSBRUT},'N',"@E 99,999,999,999.99",1,TamSX3("DXI_PSBRUT")[1],TamSX3("DXI_PSBRUT")[2],.F.})
	aAdd(aHeader, {STR0157, {||(cAliFrd)->PESCER},'N',"@E 99,999,999,999.99",1,TamSX3("DXI_PESCER")[1],TamSX3("DXI_PESCER")[2],.F.})

	// Campos para o botão de filtro
	AAdd(aCpFiltro, {"FILORG",STR0062,"C",TamSX3("DXQ_FILORG")[1],TamSX3("DXQ_FILORG")[2],"@!"}) 
	AAdd(aCpFiltro, {"SAFRA" ,STR0075,"C",TamSX3("DXI_SAFRA")[1] ,TamSX3("DXI_SAFRA")[2] ,"@!"}) 
	AAdd(aCpFiltro, {"BLOCO" ,STR0063,"C",TamSX3("DXQ_BLOCO")[1] ,TamSX3("DXQ_BLOCO")[2] ,"@!"}) 
	AAdd(aCpFiltro, {"FARDO" ,STR0064,"C",TamSX3("DXI_CODIGO")[1],TamSX3("DXI_CODIGO")[2],"@!"}) 
	AAdd(aCpFiltro, {"PSLIQU",STR0077,"N",TamSX3("DXI_PSLIQU")[1],TamSX3("DXI_PSLIQU")[2],"@E 99,999,999,999.99"}) 
	AAdd(aCpFiltro, {"PSBRUT",STR0078,"N",TamSX3("DXI_PSBRUT")[1],TamSX3("DXI_PSBRUT")[2],"@E 99,999,999,999.99"}) 
	AAdd(aCpFiltro, {"PESCER",STR0157,"N",TamSX3("DXI_PESCER")[1],TamSX3("DXI_PESCER")[2],"@E 99,999,999,999.99"}) 

	lActivate := .T.

	oBrwFrd:SetDataTable(.T.)
	oBrwFrd:SetAlias(cAliFrd)
	oBrwFrd:SetProfileID('3')
	oBrwFrd:Acolumns:= {}
	oBrwFrd:AddMarkColumns({|| Iif((cAliFrd)->OK == "OK", "LBOK", "LBNO")},{ || Marcar(oBrwFrd,3,nOperation) },{|| MarkAll(oBrwFrd,lMarkFrd,3,nOperation)})

	oBrwFrd:AddLegend( "STCONT = 1 "	, "GREEN"		, STR0176	) //"Liberado"
	oBrwFrd:AddLegend( "STCONT = 2 "	, "YELLOW"		, STR0177	) //"Sem Resultado"
	oBrwFrd:AddLegend( "STCONT = 3 "	, "RED"			, STR0178	) //"Resultado Fora da Faixa Estabelecida"
	oBrwFrd:aColumns[2]:cTitle := STR0179 //"Sts.Qualid"

	oBrwFrd:setcolumns( aHeader )
	oBrwFrd:DisableReport()
	oBrwFrd:DisableConfig()
	oBrwFrd:SetFieldFilter( aCpFiltro ) // Seta os campos para o botão filtro
	oBrwFrd:SetUseFilter() // Ativa filtro
	oBrwFrd:bLDblClick 		:= {||Marcar(oBrwFrd,3,nOperation)} //ao dar duplo clique na linha

	If lActivate
		oBrwFrd:Activate()
	EndIf

	oBrwFrd:Enable()
	oBrwFrd:Refresh(.T.)

Return

/*{Protheus.doc} 
Evento OnClick da DbTree
@sample   	TreeClick(oTree)
@return   	
@author   	Marcos Wagner Junior
@since    	26/09/2017
@version  	P12
*/
Function TreeClick(cNivel,cCargo)
	Local cContrato  := ''
	Local cCadencia  := ''
	Local cFilialDXI := ''
	Local cBloco     := ''
	Local cFiltroFil := ''
	Local cFiltroBlc := ''
	Local cFiltroFrd := ''
	Local cAliasRes  := ''
	Local nX         := 1
	Local cTempFil 	 := ''

	If cNivel >= 2
		nIni := 4 + TamSX3("N7Q_CODINE")[1]
		nFim := TamSX3("NNY_CODCTR")[1]
		cContrato := SubStr(cCargo,nIni,nFim)

		nIni := 4 + TamSX3("N7Q_CODINE")[1]+TamSX3("NNY_CODCTR")[1]
		nFim := TamSX3("NNY_ITEM")[1]
		cCadencia := SubStr(cCargo,nIni,nFim)
	EndIf

	If cNivel >= 3 
		nIni := 4 + TamSX3("N7Q_CODINE")[1]+TamSX3("NNY_CODCTR")[1]+TamSX3("NNY_ITEM")[1]
		nFim := TamSX3("DXI_FILIAL")[1]
		cFilialDXI := SubStr(cCargo,nIni,nFim)
	EndIf

	If cNivel == 4
		nIni  := 4 + TamSX3("N7Q_CODINE")[1]+TamSX3("NNY_CODCTR")[1]+TamSX3("NNY_ITEM")[1]+TamSX3("DXI_FILIAL")[1]
		nFim  := TamSX3("DXQ_BLOCO")[1]
		cBloco:= SubStr(AllTrim(cCargo),nIni,nFim)
	EndIf

	If !Empty(cContrato) //Nível 02 - CTR + Cadencia(Entrega)
		cAliasRes := GetAliasRes(cContrato, cCadencia)
		DbselectArea( cAliasRes )
		(cAliasRes)->( dbGoTop() )
		While !(cAliasRes)->( Eof() )
			If nX = 1
				cTempFil := (cAliasRes)->DXQ_FILORG
				cFiltroFil := " ( FILORG  == '"+cTempFil+"' "
				cFiltroBlc := " ( FILORG  == '"+cTempFil+"' .AND. ( BLOCO == '"+(cAliasRes)->DXQ_BLOCO+"' "
				cFiltroFrd := " ( FILORG  == '"+cTempFil+"' .AND. CODCTR == '"+cContrato+"'  .AND. ( BLOCO == '"+(cAliasRes)->DXQ_BLOCO+"' "
			Else
				If cTempFil != (cAliasRes)->DXQ_FILORG
					cTempFil := (cAliasRes)->DXQ_FILORG
					cFiltroFil += " .OR.  FILORG  == '"+cTempFil+"' "
					cFiltroBlc += " )) .OR. ( FILORG  == '"+cTempFil+"' .AND. ( BLOCO == '"+(cAliasRes)->DXQ_BLOCO+"' "
					cFiltroFrd += " )) .OR. ( FILORG  == '"+cTempFil+"' .AND. CODCTR == '"+cContrato+"'  .AND. ( BLOCO == '"+(cAliasRes)->DXQ_BLOCO+"' "
				Else
					cFiltroBlc += " .OR. BLOCO == '"+(cAliasRes)->DXQ_BLOCO+"' "
					cFiltroFrd += " .OR. BLOCO == '"+(cAliasRes)->DXQ_BLOCO+"' "
				EndIf
			EndIf
			nX ++ 
			(cAliasRes)->( dbSkip() )
		EndDo
		If !Empty(cFiltroFil)
			cFiltroFil += " ) "
		EndIf
		If !Empty(cFiltroBlc)
			cFiltroBlc += " )) "
		EndIf
		If !Empty(cFiltroFrd)
			cFiltroFrd += " )) "
		EndIf
		(cAliasRes)->( dbCloseArea() )
	EndIf

	IF !EMPTY(cFilialDXI) //Nível 03 - Filial
		nX := 1
		cAliasRes := GetAliasRes(cContrato, cCadencia)
		DbselectArea( cAliasRes )
		(cAliasRes)->( dbGoTop() )
		While !(cAliasRes)->( Eof() )
			If cFilialDXI == (cAliasRes)->DXQ_FILORG 
				//Esta sendo filtrado pela filial na tree, então deve montar o filtro pelos blocos da filial filtrada
				//o cAliasRes traz todos os fardos da entrega/cadencia sem filtrar por filial
				If nX = 1
					cFiltroFil := "( FILORG == '"+cFilialDXI+"' )"
					cFiltroBlc := " FILORG == '"+cFilialDXI+"' .AND. ( BLOCO == '"+(cAliasRes)->DXQ_BLOCO+"' "
					cFiltroFrd := " FILORG == '"+cFilialDXI+"' .AND. CODCTR == '"+cContrato+"' .AND. ( BLOCO == '"+(cAliasRes)->DXQ_BLOCO+"' "
				Else
					//cFiltroFil += " .OR. ( FILORG == '"+cFilialDXI+"' )"
					cFiltroBlc += " .OR. BLOCO == '"+(cAliasRes)->DXQ_BLOCO+"' "
					cFiltroFrd += " .OR. BLOCO == '"+(cAliasRes)->DXQ_BLOCO+"' " 
				EndIf
				nX ++
			EndIf
			(cAliasRes)->( dbSkip() )
		EndDo
		If !Empty(cFiltroBlc)
			cFiltroBlc += " ) "
		EndIf
		If !Empty(cFiltroFrd)
			cFiltroFrd += " ) "
		EndIf
		(cAliasRes)->( dbCloseArea() )
	EndIf

	If !EMPTY(cBloco) //Nível 04 - Bloco
		cFiltroFil := "( FILORG == '"+cFilialDXI+"' )"
		cFiltroBlc := " FILORG == '"+cFilialDXI+"' .AND.  BLOCO == '"+cBloco+"' "
		cFiltroFrd := " FILORG == '"+cFilialDXI+"' .AND. CODCTR == '"+cContrato+"' .AND. BLOCO == '"+cBloco+"' "
	EndIf 

	oBrwFil:FWFilter():CleanFilter()
	oBrwBlc:FWFilter():CleanFilter()
	oBrwFrd:FWFilter():CleanFilter()

	oBrwFil:CleanExFilter()
	oBrwBlc:CleanExFilter()
	oBrwFrd:CleanExFilter() 

	oBrwFil:FWFilter():DeleteFilter()
	oBrwBlc:FWFilter():DeleteFilter()
	oBrwFrd:FWFilter():DeleteFilter()

	IF cNivel != 1 	
		oBrwFil:SetFilterDefault( cFiltroFil)
		oBrwBlc:SetFilterDefault( cFiltroBlc)
		oBrwFrd:SetFilterDefault( cFiltroFrd)
	else
		oBrwFil:SetFilterDefault("@")
		oBrwBlc:SetFilterDefault("@")
		oBrwFrd:SetFilterDefault("@")
	EndIf

	oBrwFil:Refresh(.T.)
	oBrwBlc:Refresh(.T.)
	oBrwFrd:Refresh(.T.)

Return .t.

/*{Protheus.doc} GetAliasRes
(long_description)
@type  Static Function
@author Rafael Kleestadt da Cruz
@since 11/10/2017
@version version.
@param cContrato, c, cod. contrato
cCadencia, c, item cadencia(entrega)
@return cAliasRes, c, Alias com registros necessarios para filtro das grids
@example
(examples)
@see (links_or_references)*/
Static Function GetAliasRes(cContrato, cCadencia)
	Local cAliasRes := ''
	Local cQuery    := ''

	cAliasRes := GetNextAlias()
	cQuery := " Select"
	cQuery += " DXQ_FILORG,DXQ_CODRES,DXQ_BLOCO"
	cQuery += " from " + RetSQLName("DXP") + " DXP "
	cQuery += " Inner Join " + RetSQLName("DXQ") + " DXQ  on DXQ.DXQ_CODRES = DXP.DXP_CODIGO"
	cQuery += " Where DXP.D_E_L_E_T_ = ' ' AND DXP_STATUS = '2' AND DXQ.D_E_L_E_T_ = ' ' "
	cQuery += " And DXP_CODCTP = '" + cContrato + "' "
	cQuery += " And DXP_ITECAD = '" + cCadencia + "' "
	cQuery += " ORDER BY DXQ_FILORG,DXQ_CODRES,DXQ_BLOCO "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasRes, .F., .T.)

Return cAliasRes

/*{Protheus.doc} 
Função que cria as tabelas temporarias dos niveis da tree
@sample   	CriaTmpTb()
@return   	
@author   	Rafael Kleestadt da Cruz, Marcos Wagner Junior
@since    	22/09/2017
@version  	P12
*/
Static Function CriaTmpTb()
	Local aEstruBloc := {}
	Local aIndBloc   := {}	

	//Nivel 4
	aEstruBloc := {{"T_CODINE" ,  "C", TamSX3("N83_CODINE")[1], TamSX3("N83_CODINE")[2]},;
	{"T_CONTRATO", "C", TamSX3("N83_CODCTR")[1], TamSX3("N83_CODCTR")[2]},;
	{"T_CADENCIA", "C", TamSX3("N83_ITEM")[1],   TamSX3("N83_ITEM")[2]},;
	{"T_ITEREF",   "C", TamSX3("N83_ITEREF")[1], TamSX3("N83_ITEREF")[2]},;
	{"T_DATAINI",  "D", 08, 0},;
	{"T_DATAFIM",  "D", 08, 0},;				  
	{"T_FILORG",   "C", TamSX3("N83_FILORG")[1], TamSX3("N83_FILORG")[2]},;
	{"T_SAFRA ",   "C", TamSX3("N83_SAFRA")[1],  TamSX3("N83_SAFRA")[2]},;				   
	{"T_BLOCO",    "C", TamSX3("N83_BLOCO")[1],  TamSX3("N83_BLOCO")[2]},;
	{"T_TIPO ",    "C", TamSX3("N83_TIPO")[1],   TamSX3("N83_TIPO")[2]},;
	{"T_QTATEN" ,  "N", 16, 0},;				   
	{"T_QTFRDSEL", "N", TamSX3("N83_QUANT")[1],  TamSX3("N83_QUANT")[2]},;
	{"T_PSLIQSEL", "N", TamSX3("N83_PSLIQU")[1], TamSX3("N83_PSLIQU")[2]},;
	{"T_PSBRUSEL", "N", TamSX3("N83_PSBRUT")[1], TamSX3("N83_PSBRUT")[2]},;
	{"T_QTFRDDIS", "N", TamSX3("N83_QUANT")[1],  TamSX3("N83_QUANT")[2]},;
	{"T_PSLIQDIS", "N", TamSX3("N83_PSLIQU")[1], TamSX3("N83_PSLIQU")[2]},;
	{"T_PSBRUDIS", "N", TamSX3("N83_PSBRUT")[1], TamSX3("N83_PSBRUT")[2]},;
	{"T_PSBRUMED", "N", 16, 10 },; //definido casas decimais a maior devido ao calculo usando a media para poder bater o valor correto
	{"T_PSLIQMED", "N", 16, 10 },;
	{"T_QTDINI",   "N", TamSX3("N83_QUANT")[1],  TamSX3("N83_QUANT")[2]},;
	{"T_PSBRUINI", "N", TamSX3("N83_PSBRUT")[1], TamSX3("N83_PSBRUT")[2]},;
	{"T_PSLIQINI", "N", TamSX3("N83_PSLIQU")[1], TamSX3("N83_PSLIQU")[2]},;				   				   
	{"T_FRDMAR",   "C", TamSX3("N83_FRDMAR")[1], TamSX3("N83_FRDMAR")[2]}}	

	// Definição dos índices
	aIndBloc := {{"","T_CODINE,T_CONTRATO,T_CADENCIA,T_ITEREF,T_FILORG,T_BLOCO"},{"","T_CODINE,T_FILORG,T_BLOCO"}}		

	// Tabela temporária de Blocos
	cAliasBloc 	 := GetNextAlias()
	oArqTempTree := AGRCRTPTB(cAliasBloc, {aEstruBloc, aIndBloc})

Return NIL

/*{Protheus.doc} AtualizFrd - Atualiza a grid de Fardos

@author francisco.nunes
@since 05/02/2018
@version 1.0
@return ${return}, ${return_description}
@param cAliasAll, characters, Alias que está sendo alterado (Filiais/Blocos/Fardos)
@param nBrowse, number, Indica qual é o browse alterado (1=Filiais, 2=Blocos, 3=Fardos)
@param lMarcar, logical, Marca/Desmarca
@param lMFrdRom, logical, Resposta do usuário quanto a marcar(.T.)/desmarcar(.F.) fardos com vinculo no romaneio
@param lMsgDFRom, logical, indica se mostra mensagem de alerta ao desmarcar fardo com romaneio

@type function
*/
Static Function AtualizFrd(cAliasAll, nBrowse, lMarcar, lMFrdRom, lMsgDFRom)

	Local aFrdArea  := (cAliFrd)->(GetArea())
	Local cChaveVal := ""
	Local cChaveTbl := ""
	Local lMarcaFrd := .F.
	Local oModel    := FwModelActive()
	Local aInfBlc	:= {}
	Local aInfFrd	:= {} //armazena dados selecionados na grid de fardos
	Local cFilAnt	 := ""
	Local cBlcAnt	 := ""
	Local nQtdTotal	 := 0
	Local nQtdFrdSel := 0
	Local cTipMerc	 := M->N7Q_TPMERC //tipo do mercado

	Default lMarcar  := .F.
	Default lMFrdRom := .T.
	Default lMsgDFRom := .T.

	/***** ATUALIZA OS DADOS DO BROWSER/GRID FARDOS CONFORME O QUE FOI MARCADA/DESMARCADA NO BROWSER/GRID FARDOS *****/
	If nBrowse == 3

		/* Caso não seja rolagem parcial (!oModel:IsCopy()) e esteja marcando um fardo na grid de Fardos (lMarcar .AND. nBrowse == 3) */
		If lMarcar .AND. !oModel:IsCopy()
			/* Consulta informações do bloco (Quantidade Disponível, Quantidade Selecionada, Informou manualmente qtd fardos?,  etc...) */
			aInfBlc := ConsInfBlc((cAliasAll)->FILORG, (cAliasAll)->BLOCO)

			// Quantidade Selecionada + Quantidade Disponível
			nQtdTotal := aInfBlc[1] + aInfBlc[2] 						

			/* Consulta quantidade de fardos selecionados */
			aInfFrd := ConsQFrd((cAliasAll)->FILORG, (cAliasAll)->BLOCO)
			nQtdFrdSel := aInfFrd[1] 	

			/* Caso a quantidade total (Selecionada + Disponível) do Bloco for menor que a quantidade de fardos selecionados + 1, não deixará marcar fardos */ 
			If nQtdTotal < (nQtdFrdSel + 1)				
				Return .T.
			EndIf
		EndIf


		RecLock(cAliasAll, .F.)

		/* Caso não seja rolagem e esteja desmarcando os fardos */				
		If !lMarcar .AND. !oModel:isCopy()

			If !Empty((cAliasAll)->(CONTNR)) .AND. !Empty((cAliasAll)->(CODINE))
				/* Caso tenha container vinculado - Não deixará desmarcar o fardo */
				(cAliasAll)->OK := 'OK'
				If lFrdCtnAlt
					/* Obs: O aviso só será apresentado uma vez para o usuário, por isso utilizamos a variável (lFrdCtnAlt) */
					lFrdCtnAlt := .F. //mostrar msg abaixo apenas uma vez
					// "A seleção possui fardo(s) vinculado(s) a um container. Os fardos vinculados a um container não serão desmarcados"		
					// ### "Atenção"
					MsgAlert(STR0141,STR0015)	
				EndIf
				
			ElseIf ( !Empty((cAliasAll)->(ROMFLO)) .OR. (cAliasAll)->(STATUS)  $ '100|110|120|170' ) .AND. !Empty((cAliasAll)->(CODINE)) .AND. lMFrdRom
				/* Caso tenha romaneio e o usuário informe que não deseja desmarcar os fardos com romaneio vinculado */
				(cAliasAll)->OK := 'OK'
			ElseIf ( cTipMerc != '2' .AND. (cAliasAll)->(STATUS)  $ '100|110|120|170' ) .OR. ( cTipMerc = '2' .AND. (cAliasAll)->(STATUS) $ '100|170' )
				/* Se IE for de mercado interno e status fardo em romaneio OU IE mercado externo com fardo em romaneio com status fardo em Expedição ou Faturado */
				(cAliasAll)->OK := 'OK'
			Else
				(cAliasAll)->OK := ''
				If !lMFrdRom .AND. cTipMerc = '2' .AND. !Empty((cAliasAll)->ROMFLO)
					/* Retira o romaneio do fardo em tela para ele não ser considerado nas validações de pergunta ao desmarcar o fardo e valores na atualizações da tree */
					/* Será retirado apenas da tabela temporária, não será atualizado na DXI */
					(cAliasAll)->ROMFLO := ''
				EndIf
			EndIf
		Else	
			/* Caso seja Rolagem Parcial (oModel:isCopy()) E (o fardo tenha container (!Empty((cAliasAll)->CONTNR)) */			
			/* E o usuário escolher não atualizar o fardo ou não tem fardo para atualizar (!lFrdCtn) */ 
			/* não deve atualizar o campo 'OK' */
			If !(oModel:isCopy() .AND. !Empty((cAliasAll)->CONTNR) .AND. !lFrdCtn)				
				(cAliasAll)->OK := IIf(lMarcar, 'OK', '')			
			EndIf								
		EndIf				

		(cAliasAll)->(MsUnlock())

		/* Caso esteja desmarcando/marcando um fardo com container vinculado (!Empty((cAliasAll)->CONTNR))		
		e seja Rolagem Parcial (oModel:isCopy()) */
		If !Empty((cAliasAll)->CONTNR) .AND. oModel:isCopy()
			lMarCont := .F. /* Desmarca */

			If !Empty((cAliasAll)->(OK)) 
				lMarCont := .T. /* Marca */
			EndIf

			/* Desmarcar/Marcar todos os fardos do mesmo container */
			AtuCont((cAliasAll)->CONTNR, lMarCont)
		EndIf

		Return .T.
	EndIf //grid fardos nBrowse == 3

	/***** ATUALIZA OS DADOS DO BROWSER/GRID FARDOS CONFORME O QUE FOI MARCADA/DESMARCADA NO BROWSER/GRID 
	FILIAIS OU BLOCOS OU CASO TENHA SIDO INFORMADO A QUANTIDADE DE FARDOS MANUALMENTE NA GRID DE BLOCOS *****/

	//Criação de indices
	If nBrowse == 1
		cChaveVal := (cAliasAll)->FILORG
		cChaveTbl := "(cAliFrd)->FILORG"
	Else
		cChaveVal := (cAliasAll)->FILORG+(cAliasAll)->BLOCO
		cChaveTbl := "(cAliFrd)->FILORG+(cAliFrd)->BLOCO"
	EndIf	

	//Se for browser/grid de blocos e esta sendo digitado a qtd de fardos então por padrão não marca os fardos
	lMarcaFrd := IIf(nBrowse == 4,.F.,lMarcar)  

	DbSelectArea(cAliFrd)
	(cAliFrd)->(dbSetorder(2))
	If (cAliFrd)->(dbSeek(cChaveVal))
		While (cAliFrd)->(!Eof()) .AND. cChaveVal == &(cChaveTbl)
		
			RecLock(cAliFrd, .F.)

			If lMarcaFrd .AND. Empty((cAliFrd)->OK)									
				// Se passou para outra filial ou bloco
				If cFilAnt != (cAliFrd)->(FILORG) .Or. cBlcAnt != (cAliFrd)->(BLOCO)
					cFilAnt := (cAliFrd)->(FILORG)
					cBlcAnt := (cAliFrd)->(BLOCO)

					/* Consulta informações do bloco (Quantidade Disponível, etc...) */
					aInfBlc := ConsInfBlc((cAliFrd)->FILORG,(cAliFrd)->BLOCO)

					// Quantidade Selecionada + Quantidade Disponível
					nQtdTotal := aInfBlc[1] + aInfBlc[2] 						

					/* Consulta quantidade de fardos selecionados */
					aInfFrd := ConsQFrd((cAliFrd)->FILORG, (cAliFrd)->BLOCO)	
					nQtdFrdSel := aInfFrd[1]			
				EndIf	

				/* Caso a quantidade total (Selecionada + Disponível) do Bloco for menor
				que a quantidade de fardos selecionados + 1, não continua a operação */ 
				If nQtdTotal < (nQtdFrdSel + 1)
					(cAliFrd)->(dbSkip())

					LOOP
				EndIf	

				nQtdFrdSel := nQtdFrdSel + 1									
			EndIf

			/* Se for desmarcar e o fardo esteja vinculado a um romaneio e não é rolagem parcial */
			If !lMarcaFrd .AND. !oModel:isCopy() .AND. (cAliFrd)->(STATUS) $ '100|110|120|170' .AND. !Empty((cAliFrd)->CODINE) 
				
				If cTipMerc != '2' 
					// se não for IE de exportação
					(cAliFrd)->OK := "OK" //permanece marcado
					If lMsgDFRom .AND. nBrowse != 4 //4->QTD MANUAL GRID BLOCO
						MsgAlert(STR0196 ,STR0015) //## Há fardos vinculado em romaneio, estes fardos não serão desmarcados! ##Atenção
						lMsgDFRom := .F. //para mostrar mensagem apenas uma vez
					EndIf
				ElseIf lMFrdRom 
					//se fardo com romaneio for para permanecer marcado
					(cAliFrd)->OK := "OK" //permanece marcado
				ElseIf !lMFrdRom .AND. cTipMerc = '2' .AND. (cAliFrd)->(STATUS) $ '100|170' 
					//se é para desmarcar fardo em romaneio e for uma IE de exportação(2=mercado externo) e status do fardo seja Expedição ou Faturado
					(cAliFrd)->OK := "OK" //permanece marcado
					If lMsgDFRom .AND. nBrowse != 4 //4->QTD MANUAL GRID BLOCO
						MsgAlert(STR0197,STR0015) //##Há fardos vinculados em romaneio em expedição ou faturado, estes fardos não serão desmarcados! ##Atenção"
						lMsgDFRom := .F. //para mostrar mensagem apenas uma vez
					EndIf
				Else
					(cAliFrd)->OK := '' //desmarca o fardo
					/* Retira o romaneio do fardo em tela para ele não ser considerado nas validações de pergunta ao desmarcar o fardo e valores na atualizações da tree */
					/* Será retirado apenas da tabela temporária, não será atualizado na DXI */
					(cAliFrd)->ROMFLO := ''
				EndIf
			ElseIf !lMarcaFrd .AND. !oModel:isCopy() .AND. !Empty((cAliFrd)->(CONTNR)) .AND. !Empty((cAliFrd)->(CODINE))
				/* não é rolagem e caso tenha container vinculado - Não deixará desmarcar o fardo */
				(cAliFrd)->OK := 'OK'
				If lFrdCtnAlt
					/* Obs: O aviso só será apresentado uma vez para o usuário, por isso utilizamos a variável (lFrdCtnAlt) */
					lFrdCtnAlt := .F. //mostrar msg abaixo apenas uma vez
					// "A seleção possui fardo(s) vinculado(s) a um container. Os fardos vinculados a um container não serão desmarcados"		
					// ### "Atenção"
					MsgAlert(STR0141,STR0015)	
				EndIf
			Else				
				/* Caso seja Rolagem Parcial (oModel:isCopy()) E (o fardo tenha container (!Empty((cAliFrd)->CONTNR)) */				
				/* E o usuário escolher não atualizar o fardo ou não tem fardo para atualizar (!lFrdCtn) */ 
				/* não deve atualizar o campo 'OK' */
				If !( oModel:isCopy() .AND. !Empty((cAliFrd)->CONTNR) .AND. !lFrdCtn )				
					(cAliFrd)->OK := IIf(lMarcaFrd, 'OK', '')			
				EndIf
			EndIf

			(cAliFrd)->(MsUnlock())

			/* Caso esteja desmarcando/marcando um fardo com container vinculado (!Empty((cAliFrd)->CONTNR))			
			e seja Rolagem Parcial (oModel:isCopy()) */
			If !Empty((cAliFrd)->CONTNR) .AND. oModel:isCopy()
				lMarCont := .F. /* Desmarca */

				If !Empty((cAliFrd)->(OK)) 
					lMarCont := .T. /* Marca */
				EndIf

				/* Desmarcar/Marcar todos os fardos do mesmo container */
				AtuCont((cAliFrd)->CONTNR, lMarCont)
			EndIf

			(cAliFrd)->(dbSkip())
		EndDo
	EndIf	

	RestArea(aFrdArea)

Return .T.

/*{Protheus.doc} VerCont - Verifica os fardos relacionados ao mesmo Container e 
mostra mensagem de confirmação para o usuário (Rolagem  Parcial). Nesta mensagem o usuário
poderá escolher se deseja marcar/desmarcar os fardos com os mesmos containers

@author francisco.nunes
@since 20/02/2018
@version 1.0
@return ${return}, ${return_description}
@param oBrwAll, character, Browse que está sendo atualizado (Filiais/Blocos/Fardos)
@param lMarcar, boolean, marcar/desmarcar
@param nBrowse, number, indica o browse que está sendo atualizado (1 - Filiais, 2 - Blocos, 3 - Fardos)
@param lMarkAll, boolean, indica se é a opção Marcar Todos
@type function
*/
Static Function VerCont(oBrwAll, lMarcar, nBrowse, lMarkAll)
	Local cQuery	 := ""	
	Local cListCnt	 := ""		
	Local cListFil   := ""
	Local cListBlc   := ""
	Local cListFrd   := ""	
	Local cContainer := ""	
	Local cAliasQry  := GetNextAlias()

	Default lMarkAll := .F.

	If lMarkAll	
		(oBrwAll:Alias())->(dbGoTop())
		While !(oBrwAll:Alias())->(Eof())	

			If Empty(cListFil) .AND. !(oBrwAll:Alias())->FILORG $ cListFil
				cListFil += " '" + (oBrwAll:Alias())->FILORG + "' "
			ElseIf !Empty(cListFil) .AND. !(oBrwAll:Alias())->FILORG $ cListFil
				cListFil += " , '" + (oBrwAll:Alias())->FILORG + "' "
			EndIf

			// Se atualização pelo browse de Blocos ou Fardos
			If nBrowse == 2 .Or. nBrowse == 3			
				If Empty(cListBlc) .AND. !(oBrwAll:Alias())->BLOCO $ cListBlc
					cListBlc += " '" + (oBrwAll:Alias())->BLOCO + "' "
				ElseIf !Empty(cListBlc) .AND. !(oBrwAll:Alias())->BLOCO $ cListBlc
					cListBlc += " , '" + (oBrwAll:Alias())->BLOCO + "' "
				EndIf
			EndIf

			// Se atualização pelo browse de Fardos
			If nBrowse == 3
				If Empty(cListFrd) .AND. !(oBrwAll:Alias())->FARDO $ cListFrd
					cListFrd += " '" + (oBrwAll:Alias())->FARDO + "' "
				ElseIf !Empty(cListFrd) .AND. !(oBrwAll:Alias())->FARDO $ cListFrd
					cListFrd += " , '" + (oBrwAll:Alias())->FARDO + "' "
				EndIf
			EndIf			

			(oBrwAll:Alias())->(DbSkip())
		EndDo
	Else

		cListFil += " '" + (oBrwAll:Alias())->FILORG + "' "

		// Se atualização pelo browse de Blocos ou Fardos
		If nBrowse == 2 .Or. nBrowse == 3			
			cListBlc += " '" + (oBrwAll:Alias())->BLOCO + "' "
		EndIf

		// Se atualização pelo browse de Fardos
		If nBrowse == 3
			cListFrd += " '" + (oBrwAll:Alias())->FARDO + "' "
		EndIf

	EndIf

	cQuery := "SELECT DISTINCT CONTNR "
	cQuery += " FROM "+ oArqTempFrd:GetRealName() + " FRD "	
	cQuery += " WHERE FRD.FILORG IN (" + cListFil + ") "

	// Se atualização pelo browse de Blocos ou Fardos
	If nBrowse == 2 .Or. nBrowse == 3
		cQuery += " AND FRD.BLOCO IN (" + cListBlc + ") "
	EndIf

	// Se atualização pelo browse de Fardos
	If nBrowse == 3
		cQuery += " AND FRD.FARDO IN (" + cListFrd + ") "
	EndIf

	/* Condição para apenas mostrar apenas os fardos que serão atualizados */
	/* Opção Marcar - fardos que NÃO tem o campo 'OK' informado (desmarcados) */
	/* Opção Desmarcar - fardos que tem o campo 'OK' informado (marcados) */	
	If lMarcar
		cQuery += " AND FRD.OK = ' ' " // Desmarcados
	Else
		cQuery += " AND FRD.OK = 'OK' " // Marcados
	EndIf	
	/* Fim condição dos fardos que serão atualizados */

	cQuery += " AND FRD.CONTNR != ' ' "
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	While !(cAliasQry)->(EOF())

		cContainer := (cAliasQry)->(CONTNR)

		If !Empty(cContainer) .AND. !cContainer $ cListCnt
			cListCnt += "* " + cContainer + _CRLF
		EndIf		

		(cAliasQry)->(DbSkip())
	EndDo	
	(cAliasQry)->(DbCloseArea())

	lFrdCtn := .F.

	If !Empty(cListCnt)

		If !Empty(cListCnt)
			// "Seleção possui fardo(s) vinculado(s) aos containers abaixo:"
			cMsg := STR0146 + _CRLF + _CRLF
		EndIf

		// Lista de containers
		If !Empty(cListCnt)
			cMsg += STR0142 + _CRLF + cListCnt + _CRLF
		EndIf

		If !lMarcar		
			If !Empty(cListCnt)
				// "Deseja desmarcar os fardos dos mesmos containers?" 	
				cMsg += STR0147
			EndIf
		Else
			If !Empty(cListCnt)
				// "Deseja marcar os fardos dos mesmos containers?" 	
				cMsg += STR0148
			EndIf
		EndIf

		If MsgYesNo(cMsg, STR0015) // ##"Atenção" 
			lFrdCtn := .T.			
		EndIf
	EndIf

Return

/*{Protheus.doc} AtuCont - Desmarca os fardos relacionados ao mesmo container (Rolagem Parcial)

@author francisco.nunes
@since 09/02/2018
@version 1.0
@return ${return}, ${return_description}
@param cContainer, character, Container utilizado para buscar os fardos relacionados
@param lMarcar, boolean, marcar/desmarcar
@type function
*/
Static Function AtuCont(cContainer, lMarcar)

	Local lAtuliz  := .F.

	Local aFrdArea := (cAliFrd)->(GetArea())	

	// Caso lFrdCtn for false o usuário informou que não deseja marcar/desmarcar os fardos com o mesmo container
	// OU não possui fardos com o mesmo container para atualizar
	If !lFrdCtn
		Return .T.
	EndIf

	DbSelectArea(cAliFrd)
	(cAliFrd)->(DbGoTop())
	If (cAliFrd)->(!Eof())	
		While (cAliFrd)->(!Eof())

			/* Caso o fardo não tenha container, não continua o processamento */
			If Empty((cAliFrd)->CONTNR)
				(cAliFrd)->(dbSkip())
				LOOP
			EndIf

			/* Caso o container do parâmetro for vazio OU for diferente do container do fardo, não continua o processamento */				
			If 	(Empty(cContainer) .OR. AllTrim(cContainer) != AllTrim((cAliFrd)->CONTNR))			
				(cAliFrd)->(dbSkip())
				LOOP
			EndIf

			lAtuliz := .F.

			If (lMarcar .AND. Empty((cAliFrd)->OK)) .OR. (!lMarcar .AND. !Empty((cAliFrd)->OK))
				lAtuliz := .T.
			EndIf

			RecLock(cAliFrd, .F.)

			(cAliFrd)->OK := IIf(lMarcar,"OK","")

			(cAliFrd)->(MsUnlock())

			/* Será necessário atualizar o bloco apenas quando o fardo for atualizado */
			If lAtuliz
				/* Atualiza a grid de Blocos */
				AtualizBlc(cAliFrd, 3)
			EndIf

			(cAliFrd)->(dbSkip())			
		EndDo
	EndIf

	RestArea(aFrdArea)

Return

/*{Protheus.doc} AtualizBlc - Atualiza a grid de Blocos

@author francisco.nunes
@since 05/02/2018
@version 1.0
@return ${return}, ${return_description}
@param cAliasAll, characters, Alias que está sendo alterado (Filiais/Blocos/Fardos)
@param nBrowse, number, Indica qual é o browse alterado (1=Filiais, 2=Blocos, 3=Fardos)
@param lSubQFrd, boolean, Indica se será subtraido um na quantidade de fardos da grid de bloco
@type function
*/
Static Function AtualizBlc(cAliasAll, nBrowse, lSubQFrd)

	Local aBlcArea	:= (cAliGrBlc)->(GetArea())
	Local oModel    := FwModelActive()	
	Local cChaveVal := ""
	Local cChaveTbl := ""	
	Local aInfFrd	:= {} //armazena dados selecionados na grid de fardos

	Default lSubQFrd := .F.

	/***** ATUALIZA OS DADOS DO BROWSER/GRID BLOCOS CONFORME O QUE FOI MARCADA/DESMARCADA NO BROWSER/GRID 
	FILIAIS / BLOCOS / FARDOS OU CASO TENHA SIDO INFORMADO A QUANTIDADE DE FARDOS MANUALMENTE NA GRID DE BLOCOS *****/	

	//Criação de indices
	If nBrowse == 1
		cChaveVal := (cAliasAll)->FILORG
		cChaveTbl := "(cAliGrBlc)->FILORG"
	Else
		cChaveVal := (cAliasAll)->FILORG+(cAliasAll)->BLOCO
		cChaveTbl := "(cAliGrBlc)->FILORG+(cAliGrBlc)->BLOCO"
	EndIf

	DbSelectArea(cAliGrBlc)
	(cAliGrBlc)->(dbSetorder(2))
	If (cAliGrBlc)->(dbSeek(cChaveVal))
		While (cAliGrBlc)->(!Eof()) .AND. cChaveVal == &(cChaveTbl)

			RecLock(cAliGrBlc, .F.)

			// Busca a quantidade de fardos marcados do bloco
			// É realizado esta consulta pois o bloco pode estar com quantidade de fardos informada manualmente		
			aInfFrd := ConsQFrd((cAliGrBlc)->FILORG,(cAliGrBlc)->BLOCO)		

			//atualiza a media do peso bruto e liquido disponivel para o bloco
			(cAliGrBlc)->PSBRUMED := ( (cAliGrBlc)->PSBRUINI - aInfFrd[2] ) / ((cAliGrBlc)->QTDINI - aInfFrd[1] )
			(cAliGrBlc)->PSLIQMED := ( (cAliGrBlc)->PSLIQINI - aInfFrd[3] ) / ((cAliGrBlc)->QTDINI - aInfFrd[1] )

			// Caso o bloco tenha quantidade de fardos informada manualmente ((cAliGrBlc)->FRDMAR) E 
			// foi desmarcado um fardo com romaneio (lSubQFrd .AND. nBrowse == 3)
			If (cAliGrBlc)->FRDMAR == '2' .AND. lSubQFrd .AND. nBrowse == 3				
				// Subtrai apenas o fardo desmarcado na quantidade informada da grid de blocos
				(cAliGrBlc)->QTFRDSEL := (cAliGrBlc)->QTFRDSEL - 1		
				(cAliGrBlc)->PSBRUSEL := aInfFrd[2] + ((cAliGrBlc)->PSBRUMED * ((cAliGrBlc)->QTFRDSEL - aInfFrd[1])) //qtd ja vinculada de fardos + qtd que falta vincular(media) --> fardos que tem codine na DXI devido ter romaneio mostra fardo marcado mesmo bloco estando digitado manual 
				(cAliGrBlc)->PSLIQSEL := aInfFrd[3] + ((cAliGrBlc)->PSLIQMED * ((cAliGrBlc)->QTFRDSEL - aInfFrd[1])) //qtd ja vinculada de fardos + qtd que falta vincular(media) --> fardos que tem codine na DXI devido ter romaneio mostra fardo marcado mesmo bloco estando digitado manual					
				// Caso seja as opções Marcar/Desmarcar da grid de Blocos ou Filiais
			ElseIf nBrowse == 1 .Or. nBrowse == 2 .Or. nBrowse == 3
				(cAliGrBlc)->QTFRDSEL := aInfFrd[1]
				(cAliGrBlc)->PSBRUSEL := aInfFrd[2]
				(cAliGrBlc)->PSLIQSEL := aInfFrd[3]
			ElseIf nBrowse == 4
				(cAliGrBlc)->PSBRUSEL := aInfFrd[2] + ((cAliGrBlc)->PSBRUMED * ((cAliGrBlc)->QTFRDSEL - aInfFrd[1])) //qtd ja vinculada de fardos + qtd que falta vincular(media) --> fardos que tem codine na DXI devido ter romaneio mostra fardo marcado mesmo bloco estando digitado manual 
				(cAliGrBlc)->PSLIQSEL := aInfFrd[3] + ((cAliGrBlc)->PSLIQMED * ((cAliGrBlc)->QTFRDSEL - aInfFrd[1])) //qtd ja vinculada de fardos + qtd que falta vincular(media) --> fardos que tem codine na DXI devido ter romaneio mostra fardo marcado mesmo bloco estando digitado manual					
			EndIf

			/* Não possui a opção de Informar Manualmente (nBrowse == 4) pois a quantidade selecionada já vem 
			informada */

			// Conforme quantidade selecionada realiza o cálculo para informar os outros campos
			If (cAliGrBlc)->QTDINI = (cAliGrBlc)->QTFRDSEL
				(cAliGrBlc)->QTFRDDIS := 0
				(cAliGrBlc)->PSLIQDIS := 0
				(cAliGrBlc)->PSBRUDIS := 0
			Else
				(cAliGrBlc)->QTFRDDIS := (cAliGrBlc)->QTDINI - (cAliGrBlc)->QTFRDSEL
				(cAliGrBlc)->PSLIQDIS := (cAliGrBlc)->PSLIQINI - (cAliGrBlc)->PSLIQSEL
				(cAliGrBlc)->PSBRUDIS := (cAliGrBlc)->PSBRUINI - (cAliGrBlc)->PSBRUSEL
			EndIf

			// Se não for rolagem
			If !oModel:IsCopy()
				(cAliGrBlc)->FRDMAR := "1"
			EndIf	

			// Se não for rolagem e for informado manualmente pela grid de blocos OU
			// se estiver apenas desmarcando um fardo vinculado a um romaneio
			If (!oModel:IsCopy() .AND. (cAliGrBlc)->QTFRDSEL > 0 .AND. nBrowse == 4) .Or. (lSubQFrd .AND. nBrowse == 3)
				(cAliGrBlc)->FRDMAR := "2" // Bloco com quantidade digitada
			EndIf

			(cAliGrBlc)->OK := IIf((cAliGrBlc)->QTFRDSEL > 0, "OK","" )
			(cAliGrBlc)->(MsUnlock())
			(cAliGrBlc)->(DbSkip())
		EndDo
	EndIf	

	RestArea(aBlcArea)

Return

/*{Protheus.doc} ConsQFrd - Consulta a quantidade de fardos marcados

@author francisco.nunes
@since 05/02/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilFrd, character, filial que será utilizada para busca a quantidade de fardos 
@param cBlcFrd, character, bloco que será utilizado para busca a quantidade de fardos
@param lRom, boolean, se .F. é default, se .T. insere filtro para retornar somente os marcados com romaneio e IE    
@param cContr, character, contrato que será utilizado para filtro
@param cItEnt, character, item da entrega do contrato que será utilizado para filtro
@param cItRef, character, item da regra fiscal da entrega que será utilizado para filtro
@param lOutRef, boolean, se .T. considera no filtro apenas o contrato/entrega/regra fiscal diferente do passado no parâmetro

@type function
*/
Static Function ConsQFrd(cFilFrd, cBlcFrd, lRom, cContr, cItEnt, cItRef, lOutRef)
	
	Local aInfFrd	 := {0,0,0}
	Local cQuery	 := ""	
	Local cAliasQry := GetNextAlias()

	Default lRom 	 := .F.
	Default cContr	 := ""
	Default cItEnt	 := ""
	Default cItRef	 := ""

	cQuery := "SELECT COUNT(FARDO) AS FARDO, SUM(PSBRUT) AS PSBRUT, SUM(PSLIQU) AS PSLIQU "
	cQuery += " FROM "+ oArqTempFrd:GetRealName() + " FRD "	
	cQuery += " WHERE FRD.FILORG = '" + cFilFrd + "' "
	cQuery += "   AND FRD.BLOCO = '" + cBlcFrd + "' "
	cQuery += "   AND FRD.OK = 'OK' "	

	If lRom 
		cQuery += "   AND ( FRD.ROMFLO <> '' OR FRD.STATUS IN ('100','110','120','170') ) AND FRD.CODINE <> '' " //TRAZ FARDOS E ROMANEIO MARCADOS NO BROWSER DE FARDOS	
	EndIf

	If !Empty(cContr) .AND. lOutRef
		cQuery += " AND (FRD.CODCTR != '" + cContr + "' OR FRD.CADENC != '" + cItEnt + "' OR FRD.ITEREF != '" + cItRef + "') "
	EndIf


	If !Empty(cContr) .AND. !lOutRef
		cQuery += "   AND FRD.CODCTR = '" + cContr + "' "
	EndIf

	If !Empty(cItEnt) .AND. !lOutRef
		cQuery += "   AND FRD.CADENC = '" + cItEnt + "' "		
	EndIf

	If !Empty(cItRef) .AND. !lOutRef
		cQuery += "   AND FRD.ITEREF = '" + cItRef + "' "
	EndIf

	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	While (cAliasQry)->(!EOF())

		aInfFrd[1] := (cAliasQry)->(FARDO) //QTD FARDOS
		aInfFrd[2] := (cAliasQry)->(PSBRUT) //PESO BRUTO
		aInfFrd[3] := (cAliasQry)->(PSLIQU) //PESO LIQUIDO

		(cAliasQry)->(DbSkip())
	EndDo	
	(cAliasQry)->(DbCloseArea())

Return (aInfFrd)

/*{Protheus.doc} ConsInfBlc - Consulta informações do bloco

@author francisco.nunes
@since 23/02/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilBlc, character, filial que será utilizada para buscar informações do bloco 
@param cBloco, character, bloco que será utilizado para buscar informações  

@type function
*/
Static Function ConsInfBlc(cFilBlc, cBloco)

	Local aInfBlc := {0,0,"2"} //valor padrão
	Local cQuery  := ""
	Local cAliasQry := GetNextAlias()
	Local cTabela := oArqTempBlc:GetRealName()

	cQuery := "SELECT SUM(QTFRDSEL) AS QTFRDSEL, SUM(QTFRDDIS) AS QTFRDDIS, FRDMAR "
	cQuery += " FROM "+ cTabela + " BLC "	
	cQuery += " WHERE BLC.FILORG = '" + cFilBlc + "' "
	cQuery += "   AND BLC.BLOCO = '" + cBloco + "' "
	cQuery += " GROUP BY FRDMAR "
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	While (cAliasQry)->(!EOF())

		aInfBlc := {(cAliasQry)->(QTFRDSEL), (cAliasQry)->(QTFRDDIS), (cAliasQry)->(FRDMAR)}

		(cAliasQry)->(DbSkip())
	EndDo	
	(cAliasQry)->(DbCloseArea())

Return (aInfBlc)

/*{Protheus.doc} AtualizFil - Atualiza a grid de Filiais conforme grid de Blocos

@author francisco.nunes
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}

@type function
*/
Static Function AtualizFil()

	Local aFilArea := (cAliFil)->(GetArea())	
	Local cQuery   := ""	
	Local cFilBlc  := ""
	Local nQtdSel  := 0
	Local nPLiqSel := 0
	Local nPBruSel := 0
	Local nQtdDis  := 0
	Local nPLiqDis := 0
	Local nPBruDis := 0
	Local cAliasQry := GetNextAlias()

	cQuery := " SELECT FILORG, " 
	cQuery += "        SUM(QTFRDSEL) AS QTFRDSEL, "
	cQuery += "        SUM(PSBRUSEL) AS PSBRUSEL, "
	cQuery += "        SUM(PSLIQSEL) AS PSLIQSEL, "
	cQuery += "        SUM(QTFRDDIS) AS QTFRDDIS, "
	cQuery += "        SUM(PSBRUDIS) AS PSBRUDIS, "
	cQuery += "        SUM(PSLIQDIS) AS PSLIQDIS "
	cQuery += " FROM "+ oArqTempBlc:GetRealName() + " BLC "
	cQuery += " GROUP BY FILORG "	
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	While (cAliasQry)->(!EOF())

		cFilBlc  := (cAliasQry)->(FILORG)
		nQtdSel  := (cAliasQry)->(QTFRDSEL)
		nPBruSel := (cAliasQry)->(PSBRUSEL)
		nPLiqSel := (cAliasQry)->(PSLIQSEL)			
		nQtdDis  := (cAliasQry)->(QTFRDDIS)
		nPBruDis := (cAliasQry)->(PSBRUDIS)
		nPLiqDis := (cAliasQry)->(PSLIQDIS)

		DbSelectArea(cAliFil)
		(cAliFil)->(dbSetorder(1))
		If (cAliFil)->(DbSeek(cFilBlc))			

			RecLock(cAliFil, .F.)
			(cAliFil)->QTFRDSEL := nQtdSel
			(cAliFil)->PSBRUSEL := nPBruSel
			(cAliFil)->PSLIQSEL := nPLiqSel		
			(cAliFil)->QTFRDDIS := nQtdDis
			(cAliFil)->PSBRUDIS := nPBruDis
			(cAliFil)->PSLIQDIS := nPLiqDis			

			// Atualiza Marcar/Desmarcar
			(cAliFil)->OK := IIf((cAliFil)->QTFRDSEL > 0, "OK","")
			(cAliFil)->(MsUnlock())
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo	
	(cAliasQry)->(DbCloseArea())

	RestArea(aFilArea)

Return

/*{Protheus.doc} AtualizTree - Atualiza a tree

@author francisco.nunes
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}

@type function
*/
Static Function AtualizTree()

	Local oModel    := FwModelActive()
	Local oModelN7Q := oModel:GetModel("N7QUNICO")
	Local cQuery    := ""
	Local cFilBlc   := ""
	Local cBloco    := ""
	Local nQtdSelec := 0
	Local nQtdOutCtr := 0
	Local aInfFrd 	:= {} //armazena dados selecionados na grid de fardos
	Local aInfFrdOut := {} 
	Local nQtdSelUsa := 0
	Local cAliasQry := GetNextAlias()

	/***** ATUALIZAÇÃO OS DADOS DA TREE *************************************************************
	* OBSERVAÇÃO: Os dados da tabela cAliasBloc são por contrato+cadencia(entrega)+filorg+bloco igual N83,
	* a grid de blocos na tela é por filorg+bloco, esta agrupado.
	*********************************************************************************************/	

	cQuery := " SELECT FILORG, " 
	cQuery += "        BLOCO, "
	cQuery += "        FRDMAR, "
	cQuery += "        SUM(QTFRDSEL) AS QTFRDSEL "
	cQuery += " FROM "+ oArqTempBlc:GetRealName() + " BLC "
	cQuery += " GROUP BY FILORG, BLOCO, FRDMAR "	
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	While (cAliasQry)->(!EOF())

		cFilBlc := (cAliasQry)->(FILORG)
		cBloco  := (cAliasQry)->(BLOCO)

		nQtdSelec := (cAliasQry)->(QTFRDSEL)

		nQtdSelUsa := 0  //qtd selecionada ja usada

		DbSelectArea(cAliasBloc)
		(cAliasBloc)->(DbSetorder(2))
		If (cAliasBloc)->(dbSeek(oModelN7Q:GetValue('N7Q_CODINE')+cFilBlc+cBloco))
			While (cAliasBloc)->(!Eof()) .AND. oModelN7Q:GetValue('N7Q_CODINE')+cFilBlc+cBloco == (cAliasBloc)->T_CODINE+(cAliasBloc)->T_FILORG+(cAliasBloc)->T_BLOCO

				RecLock(cAliasBloc, .F.)

				/* Consulta a quantidade de fardos selecionados para o mesma filial + bloco + contrato + cadência + regra fiscal */
				aInfFrd := ConsQFrd((cAliasBloc)->T_FILORG,(cAliasBloc)->T_BLOCO,.F.,(cAliasBloc)->T_CONTRATO,(cAliasBloc)->T_CADENCIA,(cAliasBloc)->T_ITEREF,.F.)

				//atualiza a media do peso bruto e liquido disponivel para o bloco da regra fiscal
				(cAliasBloc)->T_PSBRUMED := ( (cAliasBloc)->T_PSBRUINI - aInfFrd[2] ) / ((cAliasBloc)->T_QTDINI - aInfFrd[1] )
				(cAliasBloc)->T_PSLIQMED := ( (cAliasBloc)->T_PSLIQINI - aInfFrd[3] ) / ((cAliasBloc)->T_QTDINI - aInfFrd[1] )

				If (cAliasQry)->(FRDMAR) == "2" // Se foi informado manualmente a quantidade de fardos no bloco
					(cAliasBloc)->T_FRDMAR := "2"		

					/* Consulta a quantidade de fardos selecionados para o mesma filial + bloco e que são diferentes do contrato, cadência e regra fiscal
					do bloco atual */
					aInfFrdOut := ConsQFrd((cAliasBloc)->T_FILORG,(cAliasBloc)->T_BLOCO,.F.,(cAliasBloc)->T_CONTRATO,(cAliasBloc)->T_CADENCIA,(cAliasBloc)->T_ITEREF,.T.)
					nQtdOutCtr := aInfFrdOut[1] - nQtdSelUsa //qtd do bloco em outra regra fiscal desconsiderando a qtd ja usada de regras lidas anteriormente para o bloco 

					If (nQtdSelec - nQtdOutCtr ) >= (cAliasBloc)->T_QTDINI  //(cAliasBloc)->T_QTDINI = (cAliasBloc)->T_QTFRDSEL + (cAliasBloc)->T_QTFRDDIS
						(cAliasBloc)->T_QTFRDSEL := (cAliasBloc)->T_QTDINI
					Else
						(cAliasBloc)->T_QTFRDSEL := nQtdSelec - nQtdOutCtr
					EndIf	

					(cAliasBloc)->T_PSBRUSEL := aInfFrd[2] + ((cAliasBloc)->T_PSBRUMED * ((cAliasBloc)->T_QTFRDSEL - aInfFrd[1])) //qtd ja vinculada de fardos + qtd que falta vincular(media) --> fardos que tem codine na DXI devido ter romaneio mostra fardo marcado mesmo bloco estando digitado manual
					(cAliasBloc)->T_PSLIQSEL := aInfFrd[3] + ((cAliasBloc)->T_PSLIQMED * ((cAliasBloc)->T_QTFRDSEL - aInfFrd[1])) //qtd ja vinculada de fardos + qtd que falta vincular(media) --> fardos que tem codine na DXI devido ter romaneio mostra fardo marcado mesmo bloco estando digitado manual

					nQtdSelec := nQtdSelec - (cAliasBloc)->T_QTFRDSEL  
					nQtdSelUsa += aInfFrd[1]	//quantidade para não considerar no calculo pois ja foi descontada na nQtdSelec											
				Else									
					(cAliasBloc)->T_FRDMAR := "1"

					(cAliasBloc)->T_QTFRDSEL := aInfFrd[1]
					(cAliasBloc)->T_PSBRUSEL := aInfFrd[2]	
					(cAliasBloc)->T_PSLIQSEL := aInfFrd[3]	
				EndIf							

				(cAliasBloc)->T_QTFRDDIS := (cAliasBloc)->T_QTDINI - (cAliasBloc)->T_QTFRDSEL							
				(cAliasBloc)->T_PSBRUDIS := (cAliasBloc)->T_PSBRUINI - (cAliasBloc)->T_PSBRUSEL
				(cAliasBloc)->T_PSLIQDIS := (cAliasBloc)->T_PSLIQINI - (cAliasBloc)->T_PSLIQSEL

				(cAliasBloc)->(MsUnlock())												

				(cAliasBloc)->(dbSkip())
			EndDo
		EndIf //FIM  dbSeek() para cAliasBloc e atualização dos dados da TREE	

		(cAliasQry)->(DbSkip())
	EndDo	
	(cAliasQry)->(DbCloseArea())

	/* Carrega os valores na tree de acordo com a tabela temporária */
	LoadTree(2)

Return

/*{Protheus.doc} OGA710REG
Função para realizar a busca dos registros para consulta

@author 	janaina.duarte
@since 		20/10/2017
@version 	1.0
@param 		lF12, logico, (Identifica se pergunte foi ativo pela tecla F12)
*/
Function OGA710REG(lF12)

	//Se for chamada da tecla F12
	If lF12 .AND. .NOT. Pergunte(__cPergunte, .T.)
		Return(.T.)
	EndIf

	//Se não foi chamada da tecla F12
	If !lF12  
		Pergunte(__cPergunte, .F.) //carrega as variáveis
	EndIf

	//--Variaveis dos parametros
	__cProc    := cValToChar(mv_par01)     //*Processo  
	__cIdioma  := cValToChar(mv_par02)     //*Idioma

Return(.T.)

/*{Protheus.doc} OGA710MAIL
//Função chamada via menu que abre a tela de envio.
de e-mail.
@author janaina.duarte
@since 20/10/2017
@version 1.0
@type function
*/
Function OGA710MAIL(cCodIne)

	Local cEmails 	:= "" // E-mails de envio, ou seja, os destinatários. ! Não obrigatório
	Local cBody	 	:= "" // Corpo da mensagem, caso exista. ! Não obrigatório
	Local cTabPen	:= "N7Q" // Alias referente ao browse. ! Não obrigatório
	Local cChaveFt	:= "N7Q_CODINE = '" + cCodIne + "'" // Chave para trazer somente os dados referente ao registro posicionado. ! Obrigatório
	Local cProcess	:= __cProc  //Código do processo. ! Obrigatório	
	Local aRet		:= {}
	Local aArea		:= GetArea()
	Local cMsg		:= ""

	dbSelectArea("N7Q") // Seleciona a area desejada

	//Posicione("N7Q",1,xFilial("N7Q")+cCodIne,"N7Q_DESINE")

	aRet := OGX017(cEmails, cBody, cTabPen, cChaveFt, cProcess) // Chama a tela de envio de email, passando os emails e o corpo da mensagem, alias e a chave referente ao filtro.

	If .NOT. Select("SX2") > 0 // Se a SX2 estiver fechada, reabre a mesma
		dbSelectArea("SX2")
	EndIf

	If .NOT. Empty(aRet) // Caso houve retorno, realiza a gravação dos dados, gera histórico
		cMsg += AllTrim(aRet[1][1]) + CRLF + " / "
		cMsg += STR0082 + AllTrim(aRet[1][2]) + CRLF    //E-mail enviado para:
		AGRGRAVAHIS(,,,,{"N7Q",xFilial("N7Q")+cCodIne,"4",cMsg}) //Alterar
	EndIf

	RestArea(aArea)

Return

/** {Protheus.doc} OGA710FPOR
Filtro de portos da IE - N7QPOR e N7QPDE
Retorna os portos da SY9 conforme portos cadastratos na N7R filtrando pelo tipo(origem/destino)

@param: 	cTipo - tipo do porto 1-origem/2-destino
@return:	cRet - String com o filtro
@author: 	claudineia.reinert
@since:     25/10/2017
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Function OGA710FPOR(cTipo)

	Local oModel    := FwModelActive()
	Local oN7S      := oModel:GetModel("N7SUNICO")
	Local nX        := 0
	Local cCompQry  := ''
	Local cRet      := "" 
	Local cAliasQry := GetNextAlias()
	Local cQry      := ""
	Local nCont     := 0

	cQry := " SELECT DISTINCT(N7R_CODROT)  "
	cQry += " FROM " + RetSqlName("NJR") + " NJR "
	cQry += " INNER JOIN " + RetSqlName("N7R") + " N7R ON N7R_FILIAL = '"+ xFilial("N7R") +"' AND N7R.D_E_L_E_T_ = ' ' AND N7R_CODCTR = NJR_CODCTR AND N7R_TIPO = '"+ Alltrim(cTipo) +"' "
	cQry += " WHERE "

	For nX := 1 to oN7S:Length()
		oN7S:Goline( nX )
		If .not. oN7S:IsDeleted()

			If (nX > 1)
				cCompQry += " OR "
			EndIf

			cCompQry += " (NJR_CODCTR = '"+ oN7S:GetValue('N7S_CODCTR', nX) +"') "

		EndIf	
	Next nX

	cQry += cCompQry

	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasQry, .F., .T.) 

	DbselectArea( cAliasQry )
	( cAliasQry )->(DbGoTop())
	If (cAliasQry)->( !Eof() ) //query retornou registros
		cRet += "@#"
		While (cAliasQry)->( !Eof() )

			If nCont = 0
				cRet += "(Y9_COD = '" + (cAliasQry)->N7R_CODROT + "' )"
			Else
				cRet += ".or. (Y9_COD = '" + (cAliasQry)->N7R_CODROT +"' )"
			EndIf
			nCont++
			(cAliasQry)->(DbSkip())
		EndDo
		cRet += "@#"
	Else //se query não retornou registros
		cRet := "@# @#" //se não encontrar cadastro de portos na N7R para os contratos da IE retorna todos os portos
	EndIf
	(cAliasQry)->(DbCloseArea())

	Return cRet

	/*/{Protheus.doc} classFard()
	retorna um array com os itens do pedido quebrados por tipo e valor
	@type  Static Function
	@author rafael.kleestadt
	@since 29/01/2018
	@version 1.3
	@param cFilOri, caracter, filial para a qual está sendo gerado o processo de exportação
	@return aItens, array, array com os itens do pedido de exportação classificados por tipo e valor
	@example
	(examples)
	@see http://tdn.totvs.com/pages/viewpage.action?pageId=287072658
	/*/
Static Function classFard(cFilOri, cCodIE, lRomDev)
	Local aAreaAtu  := GetArea()
	Local aAreaNJM  := NJM->(GetArea())
	Local aItens    := {}	
	Local lContLt   := Posicione("SB1", 1, FwXFilial("SB1")+N7Q->N7Q_CODPRO, "B1_RASTRO") <> "N" .And. SuperGetMv('MV_RASTRO', , .F.) == 'S'	

	DEFAULT lRomDev := .F.

	If IsInCallStack( "OGA250NF" ) //chamado pela função de CONFIRMAÇÃO DO ROMANEIO para atualizar o processo de exportação o qual irá gerar o pedido de venda(SC5, SC6)
		//quando chamado pelo OGA250NF a NJJ esta posicionada
		aItens := OGX008BGFR( 3, NJM->NJM_FILIAL, NJJ->NJJ_CODROM, '', .F., lContLt, NJM->NJM_TES) 			

	Else
		//senão se chamado pela INSTRUÇÃO DE EMBARQUE(OGA710) 
		aItens := OGX008BGFR( 2, cFilOri, cCodIE, '', .F., lContLt) //2 - função que quebra os fardos por tipo, preço e lote usando agio/desagio

	EndIf

	RestArea( aAreaNJM )
	RestArea( aAreaAtu )
Return 	aItens


/*/{Protheus.doc} OGA710INCLUI
@Description Essa função foi criada para ser chamada via consulta padrão e o retorno dela é o parâmetro 
de acesso ao modulo EEC que permite a inclusão de novas LC.
@author thiago.rover
@since 06/11/2017
@version undefined
@type function
/*/
Function OGA710INCLUI()

Return &("01#(nModulo := 29, SetMBrExecute(3), EECAF100(), nModulo := 67)")

/*/{Protheus.doc} AtuTotsIe
@Description Essa função foi criada para atualizar os totais do cabeçalho da IE.
@author rafel.kleestadt
@since 16/11/2017
@version undefined
@type function
/*/
Function AtuTotsIe()
	Local oModel     := FwModelActive()
	Local oModelN7Q  := oModel:GetModel("N7QUNICO")
	Local nFardosIE  := 0
	Local nPesBrutIE := 0
	Local nPesLiqIE  := 0
	Local cQuery	 := ""
	Local cQryFrd    := ""
	Local oView      := FwViewActive()
	Local cAliasIE 	 := ""
	Local cAliasFRD  := ""

	Local nQtdRem := 0 //N7Q_QTDREM Peso de saída do Fardo
	Local nQtdRec := 0 //N7Q_QTDREC Peso de Chegada
	Local nQtdCer := 0 //N7Q_QTDCER Peso Certificado do Fardo
	Local nQtdFCe := 0 //N7Q_QFRCER Total Fardos Certificados
	Local nPcrMce := 0 //N7Q_PCRMCE % Variação Peso Certificado
	Local aCntCor := {}//N7Q_QTDCOR Qtd Containers Reservados

	If oModel:GetOperation() == MODEL_OPERATION_VIEW .Or. oModel:GetOperation() == MODEL_OPERATION_DELETE
		Return .T.
	EndIf
	cAliasIE := GetNextAlias()
	cQuery := "SELECT SUM(T_QTFRDSEL) AS QTFRDSEL, "
	cQuery += "       SUM(T_PSLIQSEL) AS PSLIQSEL, "
	cQuery += "       SUM(T_PSBRUSEL) AS PSBRUSEL "
	cQuery += " FROM "+ oArqTempTree:GetRealName() + " IE "	
	cQuery += " GROUP BY T_CODINE "	
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasIE, .F., .T. )

	dbSelectArea(cAliasIE)
	While (cAliasIE)->(!EOF())

		nFardosIE  := (cAliasIE)->(QTFRDSEL)
		nPesLiqIE  := (cAliasIE)->(PSLIQSEL)
		nPesBrutIE := (cAliasIE)->(PSBRUSEL)

		(cAliasIE)->(DbSkip())
	EndDo	
	(cAliasIE)->(DbCloseArea())

	cAliasFRD := GetNextAlias()
	cQryFrd := "SELECT PESSAI, PESCHE, PESCER, FARDO, CONTNR, FILORG, SAFRA, ETIQ"
	cQryFrd += " FROM "+ oArqTempFrd:GetRealName() + " FRD "	
	cQryFrd += " WHERE FRD.OK = 'OK' "	
	cQryFrd := ChangeQuery( cQryFrd )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryFrd ), cAliasFRD, .F., .T. )

	dbSelectArea(cAliasFRD)
	While (cAliasFRD)->(!EOF())  

		//Caso o fardo possua movimentação tipo "7 - Romaneio" Ativo, atualizar a Quantidade Remetida apos atuc
		If Posicione("N9D",5,(cAliasFRD)->(FILORG)+(cAliasFRD)->(SAFRA)+(cAliasFRD)->(ETIQ)+"07"+"2" ,"N9D_STATUS") == '2'		
			nQtdRem += (cAliasFRD)->(PESSAI)
		EndIf
		nQtdRec += (cAliasFRD)->(PESCHE)

		If (cAliasFRD)->(PESCER) <> 0
			nQtdCer += (cAliasFRD)->(PESCER)
			nQtdFCe ++
		EndIf

		If oModel:IsCopy() .and. Ascan(aCntCor, (cAliasFRD)->(CONTNR)) == 0 .AND. !Empty((cAliasFRD)->(CONTNR))
			aAdd(aCntCor, (cAliasFRD)->(CONTNR))
		EndIf

		(cAliasFRD)->(DbSkip())
	EndDo	
	(cAliasFRD)->(DbCloseArea())

	//calcula o percentual de  variação entre o peso remetido e certificado dos contêineres da IE.
	nPcrMce := IIF(nQtdRem > 0 ,round(((( nQtdCer / nQtdRem ) - 1) * 100),2) , 0)

	oModelN7Q:LoadValue("N7Q_QTDREM", nQtdRem)     // Peso de saída do Fardo
	oModelN7Q:LoadValue("N7Q_QTDREC", nQtdRec)     // Peso de Chegada
	oModelN7Q:LoadValue("N7Q_QTDCER", nQtdCer)     // Peso Certificado do Fardo
	oModelN7Q:LoadValue("N7Q_QFRCER", nQtdFCe)     // Total Fardos Certificados
	oModelN7Q:LoadValue("N7Q_PCRMCE", nPcrMce)     // % Variação Peso Certificado
	If oModel:IsCopy()
		//SE ROLAGEM, atualiza a qtd de container reservado conforme containers dos fardos marcados
		oModelN7Q:LoadValue("N7Q_QTDCOR", Len(aCntCor))// Qtd Containers Reservados
		oModelN7Q:LoadValue("N7Q_QTDCON", Len(aCntCor))// Qtd Containers Solicitado
	EndIf
	oModelN7Q:LoadValue("N7Q_TOTFAR", nFardosIE)
	oModelN7Q:LoadValue("N7Q_TOTBRU", nPesBrutIE)
	oModelN7Q:LoadValue("N7Q_TOTLIQ", nPesLiqIE)

	If valType(oView) == 'O'
		oView:Refresh("VIEW_N7Q02")
	EndIf
	
Return 

/** {Protheus.doc} OGA710QSol
Verifica se o produto é algodão, caso seja, habilita o campo

@param: 	
@return:	.T. - Habilita o campo N7S_QTDSOL , .F. - Desabilita o campo N7S_QTDSOL
@author: 	francisco.nunes
@since:     22/11/2017
@Uso: 		OGA710 - Instrução de Embarque
*/
Function OGA710QSol()
	Local lRetorno := .F.

	// Se o tipo de produto é Algodão
	If !ValTipProd()
		lRetorno := .T.
	EndIf	

Return lRetorno

/** {Protheus.doc} ValidCad - 
validar total solicitado + percentual maximo  x total instruido 
total instruido nao deve ser maior q slicitado
@param: 		
@author: 	francisco.nunes
@since:     22/11/2017
@Uso: 		OGA710 - Instrução de Embarque
*/
Static Function ValidCad(oModel)
	Local cMsgQtSol := ""
	Local nMxPesFr  := 0
	Local oModelN7Q	:= oModel:GetModel("N7QUNICO")
	Local oModelN7S := oModel:GetModel("N7SUNICO")
	Local nInd		:= 0
	Local nTotSol   := 0
	Local nTotIns   := 0


	For nInd := 1 to oModelN7S:Length()		
		oModelN7S:Goline(nInd)	
		nTotSol += IIF(oModelN7S:GetValue('N7S_QTDSOL') > 0, oModelN7S:GetValue('N7S_QTDSOL'), oModelN7S:GetValue('N7S_QTDVIN')) 
		nTotIns += oModelN7S:GetValue('N7S_QTDVIN') 

		nMxPes1 := oModelN7S:GetValue('N7S_QTDSOL') + (oModelN7S:GetValue('N7S_QTDSOL')  * (oModelN7Q:GetValue("N7Q_PERMAX") / 100))

		If oModelN7S:GetValue('N7S_QTDVIN') > nMxPes1 .AND. oModelN7S:GetValue('N7S_QTDSOL')  > 0
			cMsgQtSol += STR0087 + ": " + oModelN7S:GetValue("N7S_CODCTR") + _CRLF
			cMsgQtSol += STR0010 + ": " + oModelN7S:GetValue("N7S_ITEM") + _CRLF
			cMsgQtSol += STR0088 + ": " + cValToChar( oModelN7S:GetValue('N7S_QTDVIN') - nMxPes1) + _CRLF + _CRLF		   
			MsgAlert(STR0086 + _CRLF + _CRLF + cMsgQtSol) // A quantidade vinculada divergente da quantidade solicitada
			return .F.
		EndIf	
	Next nInd

	nMxPesFr := nTotSol + (nTotSol * (oModelN7Q:GetValue("N7Q_PERMAX") / 100))

	If  nTotIns > nMxPesFr .AND. nTotSol > 0
		cMsgQtSol += STR0088 + ": " + cValToChar( nTotIns - nMxPesFr) + _CRLF + _CRLF		
		MsgAlert(STR0086 + _CRLF + _CRLF + cMsgQtSol) // A quantidade vinculada divergente da quantidade solicitada
		return .F.						
	EndIf	

Return .T.

/** {Protheus.doc} AtualizCad - Atualiza a grid de cadências 
@param: 	
@author: 	francisco.nunes
@since:     22/11/2017
@Uso: 		OGA710 - Instrução de Embarque
*/
Static Function AtualizCad()

	Local oView     := FwViewActive()
	Local oModel    := FwModelActive()
	Local oModelN7S := oModel:GetModel('N7SUNICO')
	Local oModelN7Q	:= oModel:GetModel('N7QUNICO')
	Local nPesoFrd	:= 0
	Local nx        := 0
	Local cQuery	:= ""	
	Local nSldIns	:= 0
	Local cAliasCAD := ""
	Local cAliasFRD := ""

	// Atualizar a quantidade vinculada na grid de cadências
	For nx := 1 to oModelN7S:Length()		

		oModelN7S:Goline(nx) //posiciona na linha da grid

		nPesoFrd := 0

		//busca a quantidade para a cadencia
		cAliasCAD := GetNextAlias()
		cQuery := "SELECT SUM(T_PSLIQSEL) AS PSLIQSEL "
		cQuery += "  FROM "+ oArqTempTree:GetRealName() + " CAD "	
		cQuery += " WHERE CAD.T_CODINE = '" + oModelN7Q:GetValue("N7Q_CODINE") + "' "
		cQuery += "   AND CAD.T_CONTRATO = '" + FwFldGet("N7S_CODCTR") + "' "
		cQuery += "   AND CAD.T_CADENCIA = '" + FwFldGet("N7S_ITEM") + "' "
		cQuery += "   AND CAD.T_FILORG = '" + FwFldGet("N7S_FILORG") + "' "
		cQuery += "   AND CAD.T_ITEREF = '" + FwFldGet("N7S_SEQPRI") + "' "
		cQuery := ChangeQuery( cQuery )	
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasCAD, .F., .T. )

		dbSelectArea(cAliasCAD)
		If (cAliasCAD)->(!EOF())
			nPesoFrd := (cAliasCAD)->(PSLIQSEL)
		EndIf	
		(cAliasCAD)->(DbCloseArea())

		oModelN7S:LoadValue("N7S_QTDVIN", nPesoFrd)
		nPesoFrd := 0 //não tem sobra

		If !oModel:IsCopy()
			nSldIns := OGA710SCad(FwFldGet("N7S_CODCTR"),FwFldGet("N7S_ITEM"),FwFldGet("N7S_SEQPRI"),.F.)
			
			If nSldIns < 1
				nSldIns := 0
			EndIf
			
			oModelN7S:LoadValue("N7S_QTDDCD", nSldIns)														
		EndIf
		
		cAliasFRD := GetNextAlias()
		cQuery := "SELECT SUM(PESSAI) AS QTDREM "
		cQuery += " FROM "+ oArqTempFrd:GetRealName() + " FRD "	
		cQuery += " WHERE FRD.OK = 'OK' " //FARDO MARCADO
		cQuery += " AND FRD.CODCTR = '"+FwFldGet("N7S_CODCTR")+"' "
		cQuery += " AND FRD.CADENC = '"+FwFldGet("N7S_ITEM")+"' " 
		cQuery += " AND FRD.ITEREF = '"+FwFldGet("N7S_SEQPRI")+"' "	
		cQuery += " AND FRD.ROMFLO != '' "	//QUE TEM ROMANEIO 
		cQuery := ChangeQuery( cQuery )	
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasFRD, .F., .T. )

		dbSelectArea(cAliasFRD)
		If (cAliasFRD)->(!EOF())
			oModelN7S:LoadValue( "N7S_QTDREM", (cAliasFRD)->(QTDREM) )
		EndIf	
		(cAliasFRD)->(DbCloseArea())

	Next nx		

	If valType(oView) == 'O'
		oView:Refresh("VIEW_N7S")		
	EndIf
Return 


/*{Protheus.doc} ValTpMerc(leditTela)
(long_description)
@type  Function
@author user
@since date
@version version
@param leditTela - verifica se esta com tela de instrucao aberta e pega informacao da entrega ou busca primeira da ie
@return returno,return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function ValTpMerc(lEditTela)
	Local cQuery    := ''
	Local cAliasQry := GetNextAlias()
	Local cTipMer   := ''

	If 	lEditTela 
		cTipMer   := Posicione("NJR",1,xFilial("NJR")+FwFldGet("N7S_CODCTR"),"NJR_TIPMER")
	Else
		cQuery := "SELECT NJR_TIPMER "
		cQuery += " FROM "+ RetSqlName('N7S') + " N7S"
		cQuery += " INNER JOIN " + RetSqlName("NJR") + " NJR ON NJR_CODCTR = N7S_CODCTR"
		cQuery += " WHERE N7S_CODINE = '" + N7Q->N7Q_CODINE + "'"
		cQuery += " AND N7S.D_E_L_E_T_ = ' ' "
		cQuery += " AND NJR.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)

		dbSelectArea(cAliasQry)
		If (cAliasQry)->( !Eof() )
			cTipMer := (cAliasQry)->NJR_TIPMER
		EndIf
		(cAliasQry)->( dbCloseArea() )
	Endif

Return cTipMer

/*/{Protheus.doc} ValQtdCont
(long_description)
@type  Function
@author Thiago	
@since 07/12/2017
@version version
@param 
@return returno,return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function ValQtdCont()

	Local oModel     := FwModelActive()	
	Local oModelN7Q	 := oModel:GetModel("N7QUNICO")
	Local lRet       := .T.
	Local nOperation := oModel:GetOperation()

	If nOperation == 4
		If oModelN7Q:getValue("N7Q_QTDCON") < oModelN7Q:GetValue("N7Q_QTDCOR")
			Help( ,,STR0026,, STR0092 , 1, 0 ) //"AJUDA - A quantidade de fardos informada para o bloco é invalida."
			lRet := .F.
		EndIf
	Endif

	Return lRet

	/*/{Protheus.doc} QtVincBlc(oBrw)
	Retorna a quantidade inicial vinculada no bloco
	@type  Function
	@author rafael.kleestadt	
	@since 06/12/2017
	@version 1.0
	@param oBrw, Object, Browse dos blocos vinculados a IE
	@return nQtdVinc, numeric, quantidade vinculada do bloco da IE
	@example
	(examples)
	@see (links_or_references)
	/*/
Function QtVincBlc(oBrw)
	Local oModel 	 := FwModelActive()
	Local oN7S 		 := oModel:GetModel("N7SUNICO")
	Local oN7Q 		 := oModel:GetModel("N7QUNICO")
	Local cAliasQry2 := ""
	Local cQuery2 	 := "" // Query2
	Local cCompQry   := "" //complementa query
	Local cCompQry2  := "" //complementa query2
	Local nX         := 0
	Local nQtdVinc   := 0

	//lê a grid N7S para complementar a query mais abaixo
	For nX := 1 to oN7S:Length()
		If .not. oN7S:IsDeleted()

			If (nX > 1)
				cCompQry := cCompQry + " OR "
				cCompQry2 := cCompQry2 + " OR "
			EndIf

			cCompQry := cCompQry + " (DXP_CODCTP = '"+ oN7S:GetValue('N7S_CODCTR', nX) +"' AND DXP_ITECAD = '"+ oN7S:GetValue('N7S_ITEM', nX) +"') "
			cCompQry2 := cCompQry2 + " (N7S_CODCTR = '"+ oN7S:GetValue('N7S_CODCTR', nX) +"' AND N7S_ITEM = '"+ oN7S:GetValue('N7S_ITEM', nX) +"') "

		EndIf	
	Next nX

	//cQuery2 retorna quantidade do bloco conforme entregas(N7S) que ja foi vinculada para outra IE
	//distinct usado devido a 2 contratos poderem estar no mesmo bloco e na mesma IE
	If !Empty(cCompQry2)
		cQuery2 := " SELECT DISTINCT(N83_CODINE) AS IE, N83_QUANT AS QTD_VINCULADA" +;
		" FROM " + RetSqlName("N7S") + " N7S " +;
		" INNER JOIN " + RetSqlName("N83") + " N83 ON " +;
		" N83_FILIAL = N7S_FILIAL AND N83_CODINE = N7S_CODINE " +;
		" AND N83_FILORG = '"+ (cAliGrBlc)->FILORG + "' AND N83_BLOCO = '" + (cAliGrBlc)->BLOCO + "' AND N83.D_E_L_E_T_ = ' ' " +;				  
		" WHERE N7S_FILIAL = '"+xFilial("N7S")+"'  "

		If oModel:IsCopy() // Se for Rolagem Parcial
			// considera a IE que está sendo rolada
			cQuery2 += " AND N7S_CODINE = '"+N7Q->N7Q_CODINE+"' "
		Else
			cQuery2 += " AND N7S_CODINE <> '"+ oN7Q:GetValue('N7Q_CODINE') +"' " 					
		EndIf	

		cQuery2 += " AND ("+ cCompQry2 +") " +;
		" AND N7S.D_E_L_E_T_ = ' ' "

		cAliasQry2  := GetNextAlias()
		cQuery2 := ChangeQuery( cQuery2 )
		If Select(cAliasQry2) > 0 // Se o alias estiver aberto, fecha o alias
			(cAliasQry2)->( dbCloseArea() )
		EndIf
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery2 ), cAliasQry2, .F., .T. ) // Executa a query
		dbSelectArea(cAliasQry2) // Seleciona a area do alias
		(cAliasQry2)->(dbGoTop()) // Posiciona no topo do registro.
		While !(cAliasQry2)->(Eof()) 
			nQtdVinc += (cAliasQry2)->QTD_VINCULADA
			(cAliasQry2)->(DbSkip())
		EndDo
		(cAliasQry2)->(DbCloseArea())
	EndIf

	Return nQtdVinc

	/*/{Protheus.doc} GrvPed()
	(long_description)
	@type  Function
	@author Rafael.k
	@since 15/12/2017
	@version 1.0
	@param Necessario que a tabela N7Q esteja posicionada
	@return NULL
	@example
	(examples)
	@see (links_or_references)
	/*/
Function GrvPed()
	Local cPedidos := ""

	dbSelectArea("N82")
	dbSetOrder(1)
	If dbSeek(N7Q->N7Q_FILIAL+N7Q->N7Q_CODINE)

		While N82->(!(Eof()) .AND. N82->N82_FILIAL+N82->N82_CODINE == N7Q->N7Q_FILIAL+N7Q->N7Q_CODINE )
			cPedidos += STR0106 + N82->N82_FILORI + STR0107 + N82->N82_PEDIDO + Chr(13) + Chr(10)
			N82->(dbSkip())
		EndDo

	EndIf

	RecLock("N7Q",.f.)
	N7Q->N7Q_PEDEXP := cPedidos
	N7Q->(MsUnlock())


	Return 

	/*/{Protheus.doc} ValPerm()
	Verifica de acordo com os contratos selecionados para a IE se a grid selecionada pode ser editada.
	@type  Function
	@author rafael.kleestadt
	@since 21/12/2017
	@version 1.0
	@param nBrowse, numeric, numero do browse a ser editado;
	lEdiTcell, logical, indica se está tentando editar uma celula da grid
	@return cRestrAux, caracter, permição mais restrita de acordo com os contratos da IE
	@example
	Considerar NJR_TPSEVO:
	1=Por Volume: Pode alterar somente a quantidade solicitada na grid Cadência da pasta Principal;
	2=Por Bloco: Pode alterar somente as grids Filial e Blocos da pasta Itens da IE;
	3=Por Fardo: Pode alterar a quantidade solicitada na grid Cadência e todas as grids dos itens da IE.  
	@see (links_or_references)
	/*/
Function ValPerm(nBrowse)
	Local oModel    := FwModelActive()
	Local oN7S      := oModel:GetModel("N7SUNICO")
	Local nX        := 0
	Local cRestr    := "3"
	Local cRestrAux := ""
	Local lRet      := .F.

	//Verifica se o usuário tem permissão para realizar a aprovação comercial da IE
	IF !Empty(RetCodUsr()) .AND. .Not. MPUserHasAccess('OGA710', 25, RetCodUsr())
		//lê a grid N7S para buscar a restrição do contrato.
		For nX := 1 to oN7S:Length()
			oN7S:Goline(nX)	
			If .not. oN7S:IsDeleted()

				cRestrAux := Posicione("NJR",1,xFilial("NJR")+oN7S:GetValue("N7S_CODCTR"),"NJR_TPSEVO")
				If nX = 1
					cRestr := cRestrAux
				EndIf
				//A IE considera sempre a menor restrição dos contratos selecionados.
				If cRestrAux < cRestr
					cRestr := cRestrAux
				EndIf

			EndIf
		Next nX
	EndIf

	If nBrowse = 3 .And. cRestr > "2"
		lRet := .T.
	ElseIf nBrowse < 3 .And. cRestr > "1"
		lRet := .T.
	EndIf

	If !lRet
		Help(" ", 1, "OGA710SELVOLUM") //##Problema: Usuário sem permissão para aprovação comercial, ou o tipo seleção de volumes do(os) contrato(os) não permite esta ação. 
		//##Solução:  Solicite privilégio de aprovação comercial ou altere o tipo seleção de volumes do(os) contrato(os) selecionados.
	EndIf

	Return lRet

	/*/{Protheus.doc} ValToler()
	Verifica no cadastro de aprovadores do processo(OGAA760) se o usuário tem permissão de executar a ação de acordo com a faixa de tolerância de variação.
	@type  Function
	@author rafael.kleestadt
	@since 27/12/2017
	@version 1.0
	@param cOpcao, caracter, tipo do processo a ser verificado.
	@return lRet, logical, True or False.
	@example
	nOpcao: 1-Aprovar Peso Certificado;2-Revisar Peso Certificado.
	SX5: 010 - Aprovar Peso Certificado; 015 - Revisar Peso Certificado.
	@see http://tdn.totvs.com/pages/viewpage.action?pageId=318604330
	/*/
Function ValToler(cOpcao, cCodUser, cNameUser)
	Local lRet     := .F.
	Local cGrupo   := Posicione('SB1', 1, xFilial('SB1') + N7Q->N7Q_CODPRO, 'B1_GRUPO')
	Local nVaria   := 0
	Local cProcess := ""
	Local nSemResult := "2"
	Local cMsg		:= ""
	
	Default cCodUser := RetCodUsr()
	Default cNameUser := cUserName

	If cOpcao $ '1,2'
		cProcess := Iif(cOpcao == '1', '010', '015')

		If Posicione("SB5",1,xFilial("SB5")+ N7Q->N7Q_CODPRO,"B5_TPCOMMO") == '2'
			nVaria := N7Q->N7Q_PCRMCE
		Else
			nVaria := round(((( N7Q->N7Q_QTDCER / N7Q->N7Q_QTDREM ) - 1) * 100),2)
		EndIf
	Else
		cProcess := '040'

		nVaria := OGA710LIMFAR()


		DbSelectArea("N7S")
		N7S->(DbSetorder(3))//NJJ_FILIAL+NJJ_COROM		
		If N7S->(DbSeek( xFilial("N7Q") + N7Q->N7Q_CODINE ) )

			//Busca se os fardos sem resultado
			cQuery := " Select COUNT(N9D_CODCTR) AS CODCTR2 From " + RetSqlName('N9D') + " N9D "
			cQuery += "    Inner Join " + RetSqlName('N9O') + " N9O on N9O.D_E_L_E_T_ = ' ' and N9O_CODCTR = N9D_CODCTR "
			cQuery += " Where N9D_CODINE = '" + N7Q->N7Q_CODINE + "'"
			cQuery += " and N9D_CODCTR = '" +N7S->N7S_CODCTR+ "' and N9D.D_E_L_E_T_ = ' ' and N9D_TIPMOV = '04' and N9D_STATUS = '2' "
			cQuery += " And Not EXISTS (Select 1 From " + RetSqlName('NPX') + " Where NPX_FARDO = N9D_CODFAR and NPX_CODTA = N9O_CODCON and D_E_L_E_T_ = ' ' and NPX_ATIVO = '1' ) "
			cAliasValid2 := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasValid2, .F., .T.)

			If (cAliasValid)->(!EoF()) .And. (cAliasValid2)->CODCTR2 > 0
				nSemResult := "1"
			EndIf
			(cAliasValid2)->(DbCloseArea())
		EndIf

		N7S->(DbCloseArea())

	EndIf	

	DbSelectArea("N99")
	N99->(DbGoTop())
	While !N99->( Eof() )

		If cOpcao $ '3'

			If ((N99->N99_COPROD == N7Q->N7Q_CODPRO) .Or. (Iif(!Empty(cGrupo) .And. cGrupo == N99->N99_GRPROD, .T., .F.))) .And. (AllTrim(N99->N99_CODPRO) == cProcess) .And. (N99->N99_RESLAB == '1' .Or. N99->N99_RESLAB == nSemResult)
				If !Empty(N99->N99_CODUSU) 
					If !Empty(cCodUser) .AND. N99->N99_CODUSU == cCodUser
						If (nVaria >= N99->N99_PERINI .And. nVaria <= N99->N99_PERFIN)
							lRet := .T.
						EndIf
						EXIT
					EndIf
				Else 
					If !Empty(cCodUser) .AND. aScan( UsrRetGrp( cNameUser, cCodUser), AllTrim(N99->N99_GRPUSU)) > 0 
						If (nVaria >= N99->N99_PERINI .And. nVaria <= N99->N99_PERFIN)
							lRet := .T.
						EndIf
						EXIT
					EndIf
				EndIf
			EndIf	

		Else

			If ((N99->N99_COPROD == N7Q->N7Q_CODPRO) .Or. (Iif(!Empty(cGrupo) .And. cGrupo == N99->N99_GRPROD, .T., .F.))) .And. (AllTrim(N99->N99_CODPRO) == cProcess)
				If !Empty(N99->N99_CODUSU) 
					If !Empty(cCodUser) .AND. N99->N99_CODUSU == cCodUser
						If (nVaria >= N99->N99_PERINI .And. nVaria <= N99->N99_PERFIN)
							lRet := .T.
						EndIf
						EXIT
					EndIf
				Else 
					If !Empty(cCodUser) .AND. aScan( UsrRetGrp( cNameUser, cCodUser), AllTrim(N99->N99_GRPUSU)) > 0 
						If (nVaria >= N99->N99_PERINI .And. nVaria <= N99->N99_PERFIN)
							lRet := .T.
						EndIf
						EXIT
					EndIf
				EndIf
			EndIf	
			
		EndIf

		N99->(dbSkip())
	EndDo

	If !lRet .And. !Empty(cCodUser) .AND. (N99->N99_CODUSU != cCodUser)

		If cOpcao $ '3' .and. !(N99->N99_RESLAB == nSemResult)

			Help( , , STR0015, , STR0182, 1, 0 )
			/*Usuário não tem permissão para aprovar fardos que não foram informados os exames laboratóriais, 
				informe ou conceda permissão ao usuário para seguir o processo.*/

		Else 
			Help(" ", 1, ".OGA710000002.")	//Usuário não configurado para realizar está ação.
			return .F.
		EndIf

	Elseif !lRet

		If cOpcao $ '3'

			cMsg := STR0183 + CHR(13)+CHR(10) + STR0115 + cValToChar(nVaria) + STR0116 + cValToChar(N99->N99_PERINI) + STR0117 + cValToChar(N99->N99_PERFIN) + '%).'
			Help( , , STR0118, , cMsg, 1, 0 )
			/* "Ação não permitida!"
			"Usuário não tem permissão para realizar esta ação conforme faixa de tolerância miníma: maxíma: "
			"A variação entre peso certificado e peso remetido da instrução de embarque foi de: "
			"%, ajuste os pesos da instrução de embarque ou aumente a faixa de aprovação do usuário no cadastro de Aprovadores do Processo." 
			*/

		Else

			cMsg := STR0114 + CHR(13)+CHR(10) + STR0115 + cValToChar(nVaria) + STR0116 + cValToChar(N99->N99_PERINI) + STR0117 + cValToChar(N99->N99_PERFIN) + '%).'
			Help( , , STR0118, , cMsg, 1, 0 )
			/* "Ação não permitida!"
			"Usuário não tem permissão para realizar esta ação conforme faixa de tolerância miníma: maxíma: "
			"A variação entre peso certificado e peso remetido da instrução de embarque foi de: "
			"%, ajuste os pesos da instrução de embarque ou aumente a faixa de aprovação do usuário no cadastro de Aprovadores do Processo." 
			*/
		EndIf
	EndIf

Return lRet

/** {Protheus.doc} OGA710WMP
Função chamada no When dos campos da aba dados documentacionais
MV_AGRO008: Lista de modalidades de pagamento que não devem solicitar os dados documentacionais, 
pois serão informados na carta de crédito
Se a modalidade de pagamento informada estiver na lista, desabilitar a aba dados documentacionais 
@return:    lRet - indica se o campo será habilitado
@author:    Tamyris Ganzenmueller
@since:     04/01/2018
@Uso:       OGA710
*/
Function OGA710WMP()

	lRet := Empty(M->N7Q_CONDPA) .Or. !M->N7Q_CONDPA $ SuperGetMV( "MV_AGRO008", .f., "" )    

Return lRet

/** {Protheus.doc} OGA710WEE
Função chamada no When do campo Entidade Entrega da IE
Se já tiver notas de remessa vinculadas, não deixar alterar o código de entidade entrega da IE.
@return:    lRet - indica se o campo será habilitado
@author:    Janaina Fontana Biffi Duarte
@since:     04/06/2018
@Uso:       OGA710
*/
Function OGA710WEE()
	Local lRetorno  := .T.
	Local cAliasQry := ''
	Local cQry      := ''
	Local iCont     := 0

	cAliasQry := GetNextAlias()
	cQry := " SELECT COUNT(*) AS CONT  "
	cQry += "     FROM " + RetSqlName("N9I") + " N9I "
	cQry += "    WHERE N9I.N9I_FILORG = '" + xFilial('N7Q') + "'"
	cQry += "      AND N9I.N9I_CODINE = '" + M->N7Q_CODINE + "'"
	cQry += "      AND N9I.D_E_L_E_T_ = ' ' "	
	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasQry, .F., .T.) 
	DbselectArea( cAliasQry )
	DbGoTop()
	If (cAliasQry)->( !Eof() )
		iCont := (cAliasQry)->CONT
	EndIf
	(cAliasQry)->(DbCloseArea())

	if iCont > 0 
		lRetorno := .F.
	endIf

Return lRetorno

/** {Protheus.doc} fTrgN7QMPA
Gatilho do campo Modalidade de Pagamento
MV_AGRO008: Lista de modalidades de pagamento que não devem solicitar os dados documentacionais, 
pois serão informados na carta de crédito
Se a modalidade de pagamento informada estiver na lista, limpar a aba dados documentacionais
__aFieldsN7Q2DO : Lista da Campos da aba Dados Documentacionais 
@return:    
@author:    Tamyris Ganzenmueller
@since:     04/01/2018
@Uso:       OGA710
*/
Static Function fTrgN7QMPA() 
	Local oView := FwViewActive()
	Local oModel := FwModelActive()
	Local oN7Q   := oModel:GetModel( "N7QUNICO" )

	Local nA    := 0

	If !Empty(M->N7Q_CONDPA) .And. M->N7Q_CONDPA $ SuperGetMV( "MV_AGRO008", .f., "" )
		For nA:=1 to Len(__aFieldsN7Q2DO)
			oN7Q:LoadValue(__aFieldsN7Q2DO[nA][1],  "" )					
		next nA++
	EndIf

	IF valType(oView) == 'O' //se objeto estiver válido 
		If oView:ACURRENTSELECT[1] == "VIEW_N7Q2DO"
		oView:Refresh("VIEW_N7Q2DO")
		EndIf
	EndIF

	Return 

	/*/{Protheus.doc} impCert()
	Verifica o tipo de mercado e se a instrução possui contêineres certificados para imprimir o certificado de peso dos contêineres.
	@type  Function
	@author rafael.kleestadt
	@since 05/01/2018
	@version 1.0
	@param param, param_type, param_descr
	@return lRet, logical, true or false
	@example
	(examples)
	@see http://jiraproducao.totvs.com.br/browse/DAGROGAP-2694
	/*/
Function impCert()
	Local lRet := .T.

	//Função válida somente para IE do tipo Externa
	If ValTpMerc(.F.) = "1" 
		Help(" ", 1, "OGA710TIPMERC") //##Problema: Função não disponível para mercado interno. ##Solução: Esta função é especifica para mercado externo.
		lRet := .F.
	Else
		If N7Q->N7Q_QFRCER > 0
			OGAR730()
		Else
			Help(" ", 1, "OGA710IMPCERT") //##Problema: Esta intrução de embarque não possui contêineres certificados. 
				//##Solução: Certifique os contêineres desta instrução de embarque para gerar o certificado de peso.	
			lRet := .F.
		EndIf 
	EndIf
Return lRet

	/*/{Protheus.doc} UpdCTxt()
	Função que realiza o update dos fardinhos da IE conforme texto colado. 
	@type  Function
	@author rafael.kleestadt
	@since 08/01/2018
	@version 1.0
	@param param, param_type, param_descr
	@return lRet, logical, True or False
	@example
	(examples)
	@see http://tdn.totvs.com/pages/viewpage.action?pageId=305039786
	/*/
Function UpdCTxt()
	Local lOK 	     := .F.
	Local lRet       := .T.
	Local oModel     := FwModelActive()
	Local oView      := FwViewActive()
	Local nOperation := oModel:GetOperation() //4-Update, 3-Insert
	Local cFrdsMemo  := ""
	Local nRadio     := 1 //1-Adicionar Fardos, 2-Retirar Fardos

	If nOperation == 3 .OR. nOperation == 4

		/*Exibe Dialog para colar os dados*/
		oDlg := TDialog():New(100,506,618,795,STR0122,,,,,CLR_BLACK,CLR_WHITE,,,.t.) //"Colar Fardos da IE"
		oDlg:lEscClose := .f.

		@ 038,008 SAY " " PIXEL
		@ 038,008 SAY STR0123 PIXEL //"Lista de Fardos:"	
		@ 050,008 GET oMsg Var cFrdsMemo OF oDlg Multiline Size 130,180 PIXEL 	

		/* Cria os radio button para informar se vai adicionar ou retirar os fardos informados no memo */
		aItems := {STR0124,STR0125} //"Adicionar Fardos","Retirar Fardos"
		oRadio := TRadMenu():New (235,05,aItems,,oDlg,,,,,,,,200,12,,,,.T.)
		oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}

		/* Seleciona a pasta de itens da IE para visualizar os dados */
		oView:SelectFolder("CTRFOLDER",STR0059,2) //"Itens da IE"

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| lOK := .T., oDlg:End() },{|| lOK := .F., oDlg:End() }) CENTERED

		If !Empty(cFrdsMemo) .And. lOK

			AtuFrdIE(nRadio, cFrdsMemo)

		EndIf
	Else
		lRet := .F.
	EndIf

Return lRet

/** {Protheus.doc} OGA710CONF
Filtro de consulta para Categorizar e separar o que são fornecedores, corretores, etc..
Retorna os registros da SY5 conforme sua classificação no campo Y5_TIPOAGE

@param: 	cParam -recebe o nome do parametro que realiza a pesquisa
N7Q_ARMADO  - Codigo do Armador        MV_CSARMAD   
N7Q_DESPAC  - Codigo do Despachante    MV_CSDESPA   
N7Q_ARMAZE  - Codigo do Armazem        MV_CSARMAZ   
N7Q_AGEMAR  - Codigo Agente Maritimo   MV_CSAGEMA
N7Q_CONPES  - Controladora de Peso     MV_CSCONPE
N7Q_TEREMB  - Codigo Terminal Embarque MV_CSTEREM

@return:	cRet - String com o filtro
@author: 	felipe.mendes
@since:     05/1/2018
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Function OGA710CONF(cParam)
	Local cRet      := "" 
	Local lFirst     := .T.

	cRet += "@# "
	//consulta na SX5 a descrição das categorias para criar o filtro
	DbSelectArea('SX5')
	SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
	SX5->(DbSeek(xFilial("SX5") + "YE")) // YE = "Catedorias de fornecedores" 
	while SX5->( !Eof() ) .AND. ( SX5->X5_FILIAL+SX5->X5_TABELA == xFilial("SX5") + "YE" ) //compara os registros da SX5 com a N98, caso não haja o registro, o mesmo é criado

		If Alltrim(SX5->X5_CHAVE) $ SUPERGETMV(cParam,.F.," ")  // verifica se a X5_CHAVE está contida no parametro (Exemplo de conteudo do parametro "124A")
			If lFirst 
				cRet += "(Y5_TIPOAGE = '" + PADR( ALLTRIM(SX5->X5_CHAVE)+"-"+ALLTRIM(SX5->X5_DESCRI), TamSX3("Y5_TIPOAGE")[1] ) + "')" // A função PADR é utilizada para limitar o tamanho do filtro ao tamanho do campo Y5_TIPOAGE
				lFirst := .F.
			Else
				cRet += ".or. (Y5_TIPOAGE = '" + PADR( ALLTRIM(SX5->X5_CHAVE)+"-"+ALLTRIM(SX5->X5_DESCRI), TamSX3("Y5_TIPOAGE")[1] ) + "')"
			EndIf	
		EndIf
		SX5->( dbSkip() )
	endDo

	cRet += "@#" 

	If lFirst .AND. !VAZIO( SUPERGETMV(cParam,.F.," ") ) 
		cRet := "@# (Y5_TIPOAGE = '*' ) @#" //filtro adicionado para não haver retorno caso cliente parametrize apenas codigos que não existam no sistema
	EndIf

Return cRet

/*/{Protheus.doc} AtuFrdIE
Função que realiza a atualização dos itens da IE conforme lista de fardos informada.
@type  Function
@author rafael.kleestadt / claudineia.reinert
@since 10/01/2018
@version 1.0
@param nRadio, numeric, opção selecionada no radio da dialog de colagem dos fardos 1-Adicionar Fardos, 2-Retirar Fardos
@param cFrdsMemo, caractere, listas dos codigos dos fardos a serem marcados\desmarcados da IE, deve ser listado um fardo por linha
@return lRet, logical, true or false
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=305039786
/*/
Function AtuFrdIE(nRadio, cFrdsMemo)	
	Local aFrds    := StrTokArr2(cFrdsMemo, _CRLF, .F.) //_CRLF: CHR(13)+CHR(10), enter ou quebra de linha
	Local nX       := 0
	Local cFrdErro := ""
	Local lMFrdRom := .T.
	Local oModel   := FwModelActive()
	Local lSubQFrd := .F.
	Local cTipMerc := M->N7Q_TPMERC //tipo do mercado
	Local lMsgDFRom := .T.
	
	lFrdCtnAlt := .T.

	//Remove os filtros das grids antes de atualizar
	oBrwFrd:FWFilter():CleanFilter()
	oBrwFrd:CleanExFilter()
	oBrwFrd:FWFilter():DeleteFilter()
	oBrwFrd:SetFilterDefault("")
	oBrwBlc:FWFilter():CleanFilter()
	oBrwBlc:CleanExFilter()
	oBrwBlc:FWFilter():DeleteFilter()
	oBrwBlc:SetFilterDefault("")
	oBrwFil:FWFilter():CleanFilter()
	oBrwFil:CleanExFilter()
	oBrwFil:FWFilter():DeleteFilter()
	oBrwFil:SetFilterDefault("")

	// Caso seja a opção para desmarcar os fardos da lista e não seja rolagem e seja IE de mercado externo
	If nRadio = 2 .AND. !oModel:isCopy() .AND. cTipMerc = '2'	 	
		DbselectArea(cAliFrd)
		(cAliFrd)->(DbGoTop())
		While !(cAliFrd)->(Eof())

			nPos := aScan(aFrds, (cAliFrd)->FARDO) 
			If nPos > 0 .And. (cAliFrd)->FARDO == aFrds[nPos]			
				If !Empty((cAliFrd)->(OK)) .AND. !Empty((cAliFrd)->(ROMFLO))
					//##"Seleção possui fardos vinculados a romaneio. Deseja desmarcar inclusive os fardos vinculados a romaneio?" ##"Atenção"
					If MsgYesNo(STR0134, STR0015)
						lMFrdRom := .F. /* Desmarcar inclusive os fardos vinculados a romaneio */
					EndIf

					EXIT
				EndIf			
			EndIf			

			(cAliFrd)->(DbSkip())
		EndDo		
	EndIf	

	DbselectArea(cAliFrd)
	(cAliFrd)->(DbGoTop())
	While !(cAliFrd)->(Eof())

		nPos := aScan(aFrds, (cAliFrd)->FARDO) 
		If nPos > 0 .And. (cAliFrd)->FARDO == aFrds[nPos]

			RecLock(cAliFrd, .F.)

			// Caso tenha romaneio e esteja desmarcando todos os fardos	da lista			
			If nRadio = 2 .AND. !oModel:isCopy()
				// Caso usuário informe que não deseja desmarcar os fardos com romaneio vinculado
				If cTipMerc = '2' .AND. lMFrdRom .AND. !Empty((cAliFrd)->(OK)) .AND. ( !Empty((cAliFrd)->(ROMFLO)) .OR. (cAliFrd)->(STATUS) $ '100|110|120|170' ) 
					//mercado externo e é para manter marcado fardos em romaneio
					(cAliFrd)->OK := 'OK'
				
				ElseIf cTipMerc = '2' .AND. !Empty((cAliFrd)->(CONTNR)) .AND. !Empty((cAliFrd)->(CODINE))
					/* Caso tenha container vinculado - Não deixará desmarcar o fardo */
					(cAliFrd)->OK := 'OK' //mantem marcado
					If lFrdCtnAlt
						/* Obs: O aviso só será apresentado uma vez para o usuário, por isso utilizamos a variável (lFrdCtnAlt) */
						lFrdCtnAlt := .F. //mostrar msg abaixo apenas uma vez
						// "A seleção possui fardo(s) vinculado(s) a um container. Os fardos vinculados a um container não serão desmarcados" ### "Atenção"
						MsgAlert(STR0141,STR0015)	
					EndIf
				
				ElseIf cTipMerc = '2' .AND. !lMFrdRom .AND. (cAliFrd)->(STATUS) $ '100|170'
					//se for exportação, não é para marcar fardos em romaneio, porem fardos estão em expedição ou faturado
					(cAliFrd)->OK := "OK" //permanece marcado
					If lMsgDFRom 
						MsgAlert(STR0197,STR0015) //##Há fardos vinculados em romaneio em expedição ou faturado, estes fardos não serão desmarcados! ##Atenção"
						lMsgDFRom := .F. //para mostrar mensagem apenas uma vez
					EndIf
				
				ElseIf cTipMerc != '2' .AND. (cAliFrd)->(STATUS) $ '100|110|120|170'
					//se não for exportação
					(cAliFrd)->OK := 'OK' //mantem marcado
					If lMsgDFRom 
						MsgAlert(STR0196 ,STR0015) //## Há fardos vinculado em romaneio, estes fardos não serão desmarcados! ##Atenção
						lMsgDFRom := .F. //para mostrar mensagem apenas uma vez
					EndIf
					
				Else
					(cAliFrd)->OK := ''
					If !lMFrdRom .AND. cTipMerc = '2' .AND. !Empty((cAliFrd)->ROMFLO)
						/* Retira o romaneio do fardo em tela para ele não ser considerado nas validações de pergunta ao desmarcar o fardo e valores na atualizações da tree */
						/* Será retirado apenas da tabela temporária, não será atualizado na DXI */
						(cAliFrd)->ROMFLO := ''
					EndIf
				EndIf
			Else
				If nRadio = 1 .AND. Empty((cAliFrd)->(OK)) //se for marcar e o fardo não esta marcado
					(cAliFrd)->OK := "OK"
				ElseIf nRadio = 2 .AND. !Empty((cAliFrd)->(OK)) //opção desmarcar e o fardo esta marcado
					(cAliFrd)->OK := ""
				EndIf
			EndIf

			(cAliFrd)->(MsUnlock())

			aDel(aFrds,nPos) //remove fardo do array pois foi encontrado	

			lSubQFrd := .F.

			/* Caso esteja desmarcando um fardo (nRadio = 2) com romaneio vinculado (!lMFrdRom) */
			/* E não seja Rolagem (!oModel:isCopy()) */
			If nRadio = 2 .AND. !oModel:isCopy() .AND. (!Empty((cAliFrd)->(ROMFLO)) .OR. (cAliFrd)->(STATUS) $ '100|110|120|170' )					
				If Empty((cAliFrd)->(OK)) 
					/* Envia um parâmetro para atualização do bloco para apenas subtrair um na quantidade de fardos */
					lSubQFrd := .T.
				EndIf

			EndIf

			/* Atualiza a grid de Blocos */
			AtualizBlc(cAliFrd, 3, lSubQFrd)

		EndIf //of dbSeek cAliFrd para achar o fardo

		(cAliFrd)->(DbSkip())	
	EndDo		

	/* Atualiza a grid de Filiais */
	AtualizFil()

	/* Atualiza a tree */
	AtualizTree()

	/* Atualiza a grid de cadências */ 	
	AtualizCad() 

	/* Atualiza totais */
	AtuTotsIe()

	oBrwFil:Refresh(.T.)
	oBrwBlc:Refresh(.T.)
	oBrwFrd:Refresh(.T.)

	//Grava lista de fardos não atualizados na IE
	For nX := 1 to Len(aFrds)
		If !empty(aFrds[nX])
			cFrdErro := cFrdErro + aFrds[nX] + _CRLF
		EndIf
	Next nX

	//Mostra log com a lista de fardos não atualizados na IE
	If !empty(cFrdErro)
		AutoGrLog( STR0126 + _CRLF + _CRLF + cFrdErro ) //"Os fardos listados abaixo não foram atualizados na IE:"
		MostraErro()
	EndIF

Return .T.

/*{Protheus.doc} InsRomGlob
Criação do romaneio
@author Tamyris Ganzenmueller
@since 16/01/2018
@type function
*/
Static Function InsRoman(cFilOri, cPedido, cIeDest, cIeOrig, cTpRom )
	Local oModelNJJ	:= Nil
	Local oAux 		:= Nil
	Local oStruct	:= Nil
	Local nI 		:= 0
	Local nJ 		:= 0
	Local nPos 		:= 0
	Local lRet 		:= .T.
	Local aAux 		:= {}
	Local nItErro 	:= 0
	Local lAux 		:= .T.	
	Local nOperacao := 3
	Local cAliasN9E2 := Nil

	Private __cIdMov := ''
	Private _lAltIE := .F. //oga250 usa esta variavel

	BEGIN TRANSACTION
		//apropriar valores nas tabelas correspondentes
		aFldNJJ := {}
		aFldNJM := {}
		aFldN9E := {}

		//para criar registro na filial do processo de exportação
		cFilCor := cFilAnt
		cFilAnt := cFilOri

		__cIdMov := OG250DMVID(N7Q->N7Q_CODINE)		

		//Verifica se já existe um romaneio para o processo de exportação
		If cTpRom = '4'
			cAliasN9E := GetNextAlias()
			cQry := " SELECT DISTINCT N9E_FILIAL, N9E_CODROM  "
			cQry += "     FROM " + RetSqlName("N9E") + " N9E "
			cQry += "    WHERE N9E.N9E_FILIAL = '" + cFilOri + "'"
			cQry += "      AND N9E.N9E_PEDIDO = '" + cPedido + "'"
			cQry += "      AND N9E.N9E_FILIE  = '" + N7Q->N7Q_FILIAL + "'"
			cQry += "      AND N9E.N9E_CODINE = '" + N7Q->N7Q_CODINE + "'"
			cQry += "      AND N9E.D_E_L_E_T_ = ' ' "	
			cQry := ChangeQuery(cQry)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasN9E, .F., .T.) 
			DbselectArea( cAliasN9E)
			DbGoTop()
			If (cAliasN9E)->( !Eof() )
				While (cAliasN9E)->(!EoF())
					DbSelectArea("NJJ")
					DbSetorder(1)//NJJ_FILIAL+NJJ_COROM		
					If NJJ->(DbSeek( (cAliasN9E)->N9E_FILIAL + (cAliasN9E)->N9E_CODROM ) ) //Foi gerado romaneio para a IE de Origem

						//Função será implementada em DAGROGAP-1314
						IF NJJ->NJJ_STATUS == '3' //Confirmada

							cAliasN9E2 := GetNextAlias()
							// Apenas busca os romaneios que não possuem romaneios de devolução
							cQry := " SELECT 1 FROM " + RetSqlName('N9E')+ " N9E "
							cQry +=    " WHERE N9E.N9E_FILIAL = '"+ (cAliasN9E)->N9E_FILIAL +"' "
							cQry +=	   " AND N9E.N9E_PEDIDO   = '"+ cPedido +"' "
							cQry +=	   " AND N9E.N9E_ORIGEM   = '2' "
							cQry +=    " AND N9E.D_E_L_E_T_   = ' ' "
							cQry := ChangeQuery(cQry)
							dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasN9E2, .F., .T.) 
							DbselectArea(cAliasN9E2)
							DbGoTop()
							If (cAliasN9E2)->(!Eof())
								lRet := .F.
								(cAliasN9E)->(dbSkip())
								LOOP								
							EndIf
							(cAliasN9E2)->(DbCloseArea())

							msgInfo("Já existe romaneio confirmado para esta Filial. Não será possível continuar")
							lRet := .F.
						EndIf

						//Se Pendente, Completo, Atualizado => Atualiza o Romaneio
						If NJJ->NJJ_STATUS $ '0,1,2' 
							nOperacao := 4

							If NJJ->NJJ_STATUS = '2' //Atualizado => Reabre o Romaneio
								aValores := {}
								aAdd(aValores, "NJJ" )
								aAdd(aValores, (NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM) )
								aAdd(aValores, "B"  )  //Tipo = Alteracao
								aAdd(aValores, STR0144 ) //Gerar NF Exportação
								OGA250REA( Alias(), Recno(), 4 , aValores) 
							EndIf

							//Exclui registro de itens para recriá-los
							DbSelectArea( "NJM" ) // Comercializações do romaneio
							NJM->(DbSetOrder( 1 )) //NJM_FILIAL+NJM_CODROM+NJM_ITEROM
							If NJM->(dbSeek( xFilial( "NJM" ) + NJJ->( NJJ_CODROM ) ))
								While !( NJM->( Eof() ) ) .And. NJM->( NJM_FILIAL ) + NJM->( NJM_CODROM ) == xFilial( "NJM" ) + NJJ->( NJJ_CODROM )

									If RecLock( "NJM", .F. )
										NJM->(dbDelete())
										NJM->( MsUnLock() )
									EndIf
									NJM->( DbSkip() )					
								EndDo
							EndIf

							DbSelectArea("N9E") // Romaneios X Angendamentos
							N9E->(DbSetOrder(1)) // N9E_FILIAL+N9E_CODROM+N9E_SEQUEN
							If N9E->(dbSeek(xFilial("N9E")+NJJ->(NJJ_CODROM)))
								While !(N9E->(Eof())) .And. N9E->(N9E_FILIAL)+N9E->(N9E_CODROM) == xFilial("N9E")+NJJ->(NJJ_CODROM)

									If RecLock("N9E", .F.)
										N9E->(dbDelete())
										N9E->(MsUnLock())
									EndIf
									N9E->(DbSkip())					
								EndDo
							EndIf

							//Exclui registro de fardos para recriá-los
							cAliasDXI := GetNextAlias()//verifica se foram selecionados fardos para o bloco da IE
							cQuery := " SELECT DXI.R_E_C_N_O_ AS DXI_RECNO "
							cQuery += " FROM " + RetSqlName("DXI") + " DXI "
							cQuery += " WHERE DXI_CODINE = '" + N7Q->N7Q_CODINE + "'"
							cQuery += "   AND DXI_FILIAL = '" + cFilOri + "'"
							cQuery += "   AND DXI_ROMSAI = '" + NJJ->NJJ_CODROM + "'"
							cQuery += "   AND DXI.D_E_L_E_T_ = ' ' "
							cQuery := ChangeQuery(cQuery)
							dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasDXI, .F., .T.)

							If (cAliasDXI)->(!EoF())
								While (cAliasDXI)->(!EoF())

									dbSelectArea("DXI")
									DXI->(DbGoTo( (cAliasDXI)->DXI_RECNO ) )
									If RecLock( "DXI", .f.)
										DXI->DXI_ROMSAI := ''
										DXI->(MsUnlock())
									EndIf
									DXI->(dbCloseArea())
									(cAliasDXI)->(dbSkip())
								End
							EndIf
							(cAliasDXI)->(dbCloseArea())

							//Se Romaneio já existente estiver Cancelado, será criado um novo

						EndIf

					EndIf
					(cAliasN9E)->(dbSkip())
				End	
			EndIf
			(cAliasN9E)->(DbCloseArea())
		EndIf

		If lRet
			If cTpRom == '4'//Venda
				CarrRomArr(cFilOri, cPedido, @aFldNJJ, @aFldNJM, @aFldN9E) //carregar dados da tabela de contrato
			ElseIf cTpRom == '9'//Devolução de Venda
				CarrRomDev(cFilOri, cIeDest, cIeOrig , @aFldNJJ, @aFldNJM, @aFldN9E, cPedido)	
			ElseIf cTpRom == 'D'//Devolução de Exportação
				CarrRomDEx(cFilOri, cIeDest, cIeOrig , @aFldNJJ, @aFldNJM, @aFldN9E, cPedido)
			EndIf

			//coloca numa transação? yeah
			oModelNJJ := FWLoadModel( 'OGA250' )
			// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
			oModelNJJ:SetOperation( nOperacao )
			// Antes de atribuirmos os valores dos campos temos que ativar o modelo
			oModelNJJ:Activate()

			// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
			oAux := oModelNJJ:GetModel( 'NJJUNICO' )   
			// Obtemos a estrutura de dados do cabeçalho
			oStruct := oAux:GetStruct()
			aAux    := oStruct:GetFields()

			For nI := 1 To Len( aFldNJJ )
				// Verifica se os campos passados existem na estrutura do cabeçalho
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aFldNJJ[nI][1] ) } ) ) > 0
					// È feita a atribuição do dado aos campo do Model do cabeçalho
					If !( lAux := oModelNJJ:SetValue( 'NJJUNICO', aFldNJJ[nI][1],aFldNJJ[nI][2] ) )
						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						lRet := .F.
						Exit
					EndIf
				EndIf
			Next
		EndIf

		/*Comercialização*/
		If lRet
			// Instanciamos apenas a parte do modelo referente aos dados do item
			oAux := oModelNJJ:GetModel( 'NJMUNICO' )
			// Obtemos a estrutura de dados do item
			oStruct := oAux:GetStruct()
			aAux := oStruct:GetFields()
			nItErro := 0
			For nI := 1 To Len( aFldNJM )
				// Incluímos uma linha nova
				// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
				//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
				If nI > 1
					// Incluímos uma nova linha de item
					If ( nItErro := oAux:AddLine() ) <> nI
						// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
						lRet := .F.
						Exit
					EndIf
				EndIf
				For nJ := 1 To Len( aFldNJM[nI] )
					// Verifica se os campos passados existem na estrutura de item
					If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aFldNJM[nI][nJ][1] ) } ) ) > 0
						If !Empty(aFldNJM[nI][nJ][2])
							If !( lAux := oModelNJJ:SetValue( 'NJMUNICO', aFldNJM[nI][nJ][1], aFldNJM[nI][nJ][2] ) )
								// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
								// o método SetValue retorna .F.
								lRet := .F.
								nItErro := nI
								Exit
							EndIf
						EndIf
					EndIf
				Next nJ
				If !lRet
					Exit
				EndIf
			Next nI
		EndIf	

		/*Origem Do Romaneio*/
		If lRet
			// Instanciamos apenas a parte do modelo referente aos dados do item
			oAux := oModelNJJ:GetModel( 'N9EUNICO' )
			// Obtemos a estrutura de dados do item
			oStruct := oAux:GetStruct()
			aAux := oStruct:GetFields()
			nItErro := 0
			For nI := 1 To Len( aFldN9E )
				// Incluímos uma linha nova
				// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
				//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
				If nI > 1
					// Incluímos uma nova linha de item
					If ( nItErro := oAux:AddLine() ) <> nI
						// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
						lRet := .F.
						Exit
					EndIf
				EndIf
				For nJ := 1 To Len( aFldN9E[nI] )
					// Verifica se os campos passados existem na estrutura de item
					If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aFldN9E[nI][nJ][1] ) } ) ) > 0
						If !( lAux := oModelNJJ:SetValue( 'N9EUNICO', aFldN9E[nI][nJ][1], aFldN9E[nI][nJ][2] ) )
							// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
							// o método SetValue retorna .F.
							lRet := .F.
							nItErro := nI
							Exit
						EndIf
					EndIf
				Next nJ
				If !lRet
					Exit
				EndIf
			Next nI
		EndIf	

		If lRet
			// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
			// neste momento os dados não são gravados, são somente validados.
			If ( lRet := oModelNJJ:VldData() ) 
				// Se o dados foram validados faz-se a gravação efetiva dos
				// dados (commit)
				//guarda o código do contrato a ser gravado 
				lRet := oModelNJJ:CommitData()
			EndIf

		EndIf

		If lRet

			If AllTrim(NJJ->NJJ_TIPO) = "4"
				cAliasDXI := GetNextAlias()//verifica se foram selecionados fardos para o bloco da IE
				cQuery := " SELECT DXI.R_E_C_N_O_ AS DXI_RECNO "
				cQuery += " FROM " + RetSqlName("DXI") + " DXI "
				cQuery += " INNER JOIN " + RetSqlName("N83") + " N83 ON N83.N83_FILIAL = '" + xFilial("N83") + "' AND N83_BLOCO = DXI_BLOCO AND N83_CODINE = DXI_CODINE AND N83_FILORG = DXI_FILIAL AND N83.D_E_L_E_T_ = ' ' "
				cQuery += " WHERE DXI_CODINE = '" + N7Q->N7Q_CODINE + "'"
				cQuery += "   AND DXI_FILIAL = '" + cFilOri + "'"
				cQuery += "   AND DXI.D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasDXI, .F., .T.)
				If (cAliasDXI)->(!EoF())
					While (cAliasDXI)->(!EoF())

						dbSelectArea("DXI")
						DXI->(DbGoTo( (cAliasDXI)->DXI_RECNO ) )
						If RecLock( "DXI", .f.)
							DXI->DXI_ROMSAI := NJJ->NJJ_CODROM
							DXI->(MsUnlock())
							//Cria movimentação "07" para cada fardo vinculado ao romaneiro
							CriaMovFard(oModelNJJ:GetModel( 'NJJUNICO' ):GetValue("NJJ_CODROM"),N7Q->N7Q_CODINE,oModelNJJ:GetModel( 'NJJUNICO' ):GetValue("NJJ_FILIAL"))
						EndIf
						
						//somente ajustar status do fardo nao for romaneio antecipado
						If  N7Q->N7Q_STAPCE $ '4'						
							//incluir(1) status do fardo na DXI(DXI_STATUS)
							AGRXFNSF( 1 , "RomaneioVnd" ) //Romaneio Venda							
						EndIf
						(cAliasDXI)->(dbSkip())
					End
				EndIf
				(cAliasDXI)->(dbCloseArea())
			EndIf
			OGA250ATUC( Alias(), Recno(), 4, .t. )
			// Desativamos o Model
			oModelNJJ:DeActivate()
		ElseiF oModelNJJ <> NIL
			// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
			aErro := oModelNJJ:GetErrorMessage()

			AutoGrLog( STR0247 + ': [' + AllToChar( aErro[1] ) + ']' ) //"Id do formulário de origem"
			AutoGrLog( STR0248 + ': [' + AllToChar( aErro[2] ) + ']' ) //"Id do campo de origem"
			AutoGrLog( STR0249 + ': [' + AllToChar( aErro[3] ) + ']' ) //"Id do formulário de erro"
			AutoGrLog( STR0250 + ': [' + AllToChar( aErro[4] ) + ']' ) //"Id do campo de erro"
			AutoGrLog( STR0251 + ': [' + AllToChar( aErro[5] ) + ']' ) //"Id do erro"
			AutoGrLog( STR0252 + ': [' + AllToChar( aErro[6] ) + ']' ) //"Mensagem do erro"
			AutoGrLog( STR0253 + ': [' + AllToChar( aErro[7] ) + ']' ) //"Mensagem da solução"
			AutoGrLog( STR0254 + ': [' + AllToChar( aErro[8] ) + ']' ) //"Valor atribuído"
			AutoGrLog( STR0255 + ': [' + AllToChar( aErro[9] ) + ']' ) //"Valor anterior"
			If nItErro > 0
				AutoGrLog( "Erro no Item: " + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' )
			EndIf
			MostraErro()

			lRet := .F.

			Help( ,,STR0026,,STR0135, 1, 0 ) //"AJUDA"##"Não foi possivel gerar o romaneio."

			// Desativamos o Model
			oModelNJJ:DeActivate()
		EndIf



		cFilAnt := cFilCor

		If !lRet
			DisarmTransaction()
		EndIf

	END TRANSACTION

return (lRet)

/*{Protheus.doc} CarrRomArr
CarRega o array de dados para geração do romaneio
@author Tamyris Ganzenmueller
@since 16/01/2018
@param aFldNJJ, array campos NJJ
@param aFldNNY, array campos NJM
@type function
*/
Static Function CarrRomArr(cFilOri,cPedido, aFldNJJ, aFldNJM, aFldN9E)
	Local cUn := ""
	Local cCodCtr := ''
	Local cIteCtr := ''
	Local cSeqCtr := ''

	Local nItRom     := 0	
	Local __nPesoRom := 0
	Local __cLocal   := N7Q->N7Q_LOCAL

	DbSelectArea('SB1')
	SB1->( DbSetOrder(1) )
	IF SB1->(DbSeek(Fwxfilial('SB1') + NJR->NJR_CODPRO ))
		__cLocal := IIf(Empty(__cLocal),SB1->B1_LOCPAD,__cLocal)
		cUn    := SB1->B1_UM
	EndIf

	cQuery := "	SELECT N7S.N7S_CODCTR AS CONTRATO, N7S.N7S_ITEM AS ITEM, N7S.N7S_SEQPRI AS SEQPRI, SUM(N7S.N7S_QTDVIN) AS PESO " 
	cQuery += " FROM " + RetSqlName('N7S') + " N7S "
	cQuery += "	WHERE N7S.N7S_FILIAL = '" + N7Q->N7Q_FILIAL + "' "
	cQuery += "	AND N7S.N7S_CODINE = '" + N7Q->N7Q_CODINE + "' "  
	cQuery += "	AND N7S.N7S_FILORG = '"+ cFilOri +"' " 
	cQuery += "	AND N7S.D_E_L_E_T_ = ' ' "
	cQuery += "	GROUP BY N7S.N7S_CODCTR, N7S.N7S_ITEM, N7S.N7S_SEQPRI "
	cQuery := ChangeQuery(cQuery)
	cAliasN7S := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN7S, .F., .T.)
	If (cAliasN7S)->(!EoF())
		While (cAliasN7S)->(!EoF())
			__nPesoRom += (cAliasN7S)->PESO
			cCodCtr := (cAliasN7S)->CONTRATO //pega um contrato para incluir na NJM, porem na atualização do romaneio será realizada a quebra corretamente da NJM
			cIteCtr := (cAliasN7S)->ITEM
			cSeqCtr := (cAliasN7S)->SEQPRI
			(cAliasN7S)->(dbSkip())
		EndDo
	EndIf
	(cAliasN7S)->(dbCloseArea())

	/*Dados Tipo Romaneio*/
	aAdd( aFldNJJ, { 'NJJ_FILIAL', cFilOri } )
	aAdd( aFldNJJ, { 'NJJ_TIPO'  , "4" } ) 
	aAdd( aFldNJJ, { 'NJJ_TPFORM', "1" } )
	aAdd( aFldNJJ, { 'NJJ_TIPENT', "2" } ) 
	/*Dados do Contrato*/
	aAdd( aFldNJJ, { 'NJJ_FILORG', ""} )
	aAdd( aFldNJJ, { 'NJJ_CODCTR', ""} )
	aAdd( aFldNJJ, { 'NJJ_CODSAF', N7Q->N7Q_CODSAF} )
	//	aAdd( aFldNJJ, { 'NJJ_TES'   , N7Q->N7Q_TES	  } )
	aAdd( aFldNJJ, { 'NJJ_CODPRO', N7Q->N7Q_CODPRO} )
	aAdd( aFldNJJ, { 'NJJ_UM1PRO', cUn            } )
	aAdd( aFldNJJ, { 'NJJ_LOCAL' , __cLocal       } )
	/*Dados da Entidade*/
	aAdd( aFldNJJ, { 'NJJ_CODENT', N7Q->N7Q_IMPORT} )
	aAdd( aFldNJJ, { 'NJJ_LOJENT', N7Q->N7Q_IMLOJA} )
	aAdd( aFldNJJ, { 'NJJ_ENTENT', N7Q->N7Q_IMPORT} )
	aAdd( aFldNJJ, { 'NJJ_ENTLOJ', N7Q->N7Q_IMLOJA} )
	/*Dados Quantidade*/
	aAdd( aFldNJJ, { 'NJJ_PSSUBT', __nPesoRom 	 } )
	aAdd( aFldNJJ, { 'NJJ_PSBASE', __nPesoRom 	 } )
	aAdd( aFldNJJ, { 'NJJ_PSLIQU', __nPesoRom	 } )
	//aAdd( aFldNJJ, { 'NJJ_PESO3' , __nPesoRom	 } )
	aAdd( aFldNJJ, { 'NJJ_QTDFIS' , __nPesoRom	 } )

	/*Dados Pesagem*/
	aAdd( aFldNJJ, { 'NJJ_DATA'  , dDataBase         } )
	aAdd( aFldNJJ, { 'NJJ_DATPS1', dDataBase 		 } )
	aAdd( aFldNJJ, { 'NJJ_HORPS1', Substr(Time(), 1,5) } )
	aAdd( aFldNJJ, { 'NJJ_PESO1' , __nPesoRom  	 } )
	aAdd( aFldNJJ, { 'NJJ_DATPS2', dDataBase 		 } )
	aAdd( aFldNJJ, { 'NJJ_HORPS2', Substr(Time(), 1,5) } )
	/*Dados Fixos*/
	aAdd( aFldNJJ, { 'NJJ_TRSERV', "0" } )
	aAdd( aFldNJJ, { 'NJJ_STSPES', "1" } )
	aAdd( aFldNJJ, { 'NJJ_STATUS', "1" } )
	aAdd( aFldNJJ, { 'NJJ_STSCLA', "1" } )
	aAdd( aFldNJJ, { 'NJJ_STAFIS', "1" } )
	aAdd( aFldNJJ, { 'NJJ_STACTR', "1" } ) 
	aAdd( aFldNJJ, { 'NJJ_TPFRET', "C" } )

	//na inclusão do romaneio a NJM será fake, a quebra correta da NJM será feita na atualização do romaneio 
	If !OG250DCNJM(@nItRom, @aFldNJM, '', '', N7Q->N7Q_FILIAL, N7Q->N7Q_CODINE, cCodCtr, cIteCtr, cSeqCtr, __nPesoRom, __nPesoRom, 0 , N7Q->N7Q_IMPORT, N7Q->N7Q_IMLOJA, __cLocal, __cIdMov, '', '', 2)
		Return .F.
	EndIf

	//Carrega array da tabela N9E
	carrN9E(aFldN9E, '1', cPedido, cFilOri, N7Q->N7Q_CODINE, N7Q->N7Q_CODINE)

return .T.

/*{Protheus.doc} carrN9E
Carrega o array de dados da N9E para geração do romaneio
@author Felipe Rafael Mendes
@since 23/02/2018
@param aFldN9E, array campos N9E
@param cOrigem, codigo do contrato
@param cPedido, Codigo do Pedido
@param cFilial, Filial de Origem da Entrega
@param cCodIne, Código da Instrução de Embarque
@param cIeOrg, Código da Instrução de Embarque
@type function
*/
Static Function carrN9E(aFldN9E, cOrigem, cPedido, cFilOri, cCodIne, cIeOrg)

	Local aAux	   := {}
	Local aAreaN7Q := GetArea("N7Q")

	//Buscando as regras fiscais para criar o array da N9E
	DBSelectArea("N7S")
	DbSetOrder(3)
	DbSeek(xFilial("N7S")+cCodIne+cFilOri)
	While !N7S->(Eof()) .AND. N7S->N7S_FILIAL+N7S_CODINE+N7S_FILORG ==  xFilial("N7S")+cCodIne+cFilOri

		If N7S->N7S_QTDVIN > 0

			aAux := {}

			aAdd(aAux, {'N9E_CODINE', cIeOrg  })
			aAdd(aAux, {'N9E_FILIE',  N7S->N7S_FILIAL  })
			aAdd(aAux, {'N9E_CODCTR', N7S->N7S_CODCTR  })
			aAdd(aAux, {'N9E_ITEM'  , N7S->N7S_ITEM    })
			aAdd(aAux, {'N9E_SEQPRI', N7S->N7S_SEQPRI  })
			aAdd(aAux, {'N9E_PEDIDO', cPedido          })
			aAdd(aAux, {'N9E_ORIGEM', cOrigem          })		

			aAdd( aFldN9E, aAux )
		EndIf

		N7S->(DbSkip())
	EndDo

	RestArea(aAreaN7Q)

Return .T.

/*/{Protheus.doc} IntCnt
Monta o array com os conteineres separados pelas filiais dos fardos estufados
@type  Static Function
@author rafael.kleestadt	
@since 24/01/2018
@version 2.0
@param cFilOri, caracter, filial do embarque
@param cCodine, caracter, Instrução de Embarque
@param nOperac, numeric, operação a ser realizada 3-Inclusão, 4-Alteração, 5-Exclusão
@param cEmbarq, caracter, código do embarque gerado para a filial
@return returno,return_type, return_description
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=318604330
/*/
Static Function IntCnt(cFilOri, cCodine, nOperac, cEmbarq)
	Local aCnts     := {}	
	Local cAliasQry := ""
	Local cQuery    := ""
	Local nQtdCtn	:= 0
	Local nPos		:= 0

	If !ValTipProd() //Tipo de commodity Algodão

		cAliasQry := GetNextAlias()
		//Busca os contêineres conforme movimento dos fardos e agrupa por contêiner e filial de origem
		cQuery := "     SELECT N9D.N9D_CONTNR, N9D.N9D_FILIAL, "
		cQuery += "            SUM((DXI.DXI_PSBRUT - DXI.DXI_PSLIQU) + DXI.DXI_PESCER) PSBRUT, "
		cQuery += "            SUM(DXI.DXI_PESCER) PSLIQU, "
		cQuery += "            COUNT(DXI.DXI_CODIGO) QTDFRD "         
		cQuery += "       FROM " + RetSqlName('N9D') + " N9D "
		cQuery += " INNER JOIN " + RetSqlName('DXI') + " DXI ON DXI_FILIAL = N9D_FILIAL "
		cQuery += "    	   AND DXI.DXI_ETIQ = N9D.N9D_FARDO "
		cQuery += "        AND DXI_SAFRA = N9D_SAFRA "
		cQuery += "        AND DXI_BLOCO = N9D_BLOCO   "
		cQuery += "        AND DXI.D_E_L_E_T_ = ' ' "
		cQuery += "      WHERE N9D.N9D_CODINE = '" + cCodine + "' "  
		cQuery += "        AND N9D.N9D_FILIAL = '" + cFilOri + "' " 
		cQuery += "        AND N9D.D_E_L_E_T_ = ' ' "
		cQuery += "        AND N9D.N9D_TIPMOV = '05' "
		cQuery += "        AND N9D.N9D_STATUS = '2' "
		cQuery += "   GROUP BY N9D.N9D_CONTNR, N9D.N9D_FILIAL "

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
		If (cAliasQry)->(!EoF())
			While (cAliasQry)->(!EoF())

				If Posicione("N91",1,xFilial("N91")+cCodine+(cAliasQry)->N9D_CONTNR,"N91_STATUS") = '6'//Somente conteineres com status "6=aprovado"
					aAdd(aCnts, {(cAliasQry)->N9D_CONTNR, (cAliasQry)->N9D_FILIAL, (cAliasQry)->(PSBRUT), (cAliasQry)->(PSLIQU), (cAliasQry)->(QTDFRD)})
				EndIf

				(cAliasQry)->(dbSkip())
			End
		EndIf
		(cAliasQry)->(dbCloseArea())

	Else //Grãos 
		// Monta a query de busca
		cQuery := " SELECT N9I.N9I_CONTNR, "
		cQuery += " 	   SUM(N9I.N9I_QTDFIS) AS QTDFIS "
		cQuery += " FROM " + RetSqlName("N9I") + " N9I "							
		cQuery += " WHERE N9I.N9I_FILIAL =  '"+cFilOri+"'  "
		cQuery += "   AND N9I.N9I_FILORG = '"+N7Q->(N7Q_FILIAL)+"' "
		cQuery += "   AND N9I.N9I_CODINE = '"+N7Q->(N7Q_CODINE)+"' "	
		cQuery += "   AND N9I.N9I_CONTNR <> '' "
		cQuery += "   AND N9I.D_E_L_E_T_ = ' ' "
		cQuery += "   AND N9I.N9I_INDSLD = '2' "
		cQuery += " GROUP BY N9I.N9I_CONTNR "
		cQuery += " UNION ALL "
		cQuery += " SELECT N9I.N9I_CONTNR, "
		cQuery += " 	   SUM(N9I.N9I_QTDFIS) AS QTDFIS "
		cQuery += " FROM " + RetSqlName("N9I") + " N9I "							
		cQuery += " WHERE N9I.N9I_FILIAL =  '"+cFilOri+"'  "
		cQuery += "   AND N9I.N9I_FILORG = '"+N7Q->(N7Q_FILIAL)+"' "
		cQuery += "   AND N9I.N9I_CODINE = '"+N7Q->(N7Q_CODINE)+"' "	
		cQuery += "   AND N9I.N9I_CONTNR <> '' "
		cQuery += "   AND N9I.D_E_L_E_T_ = ' ' "
		cQuery += "   AND N9I.N9I_INDSLD = '3' "
		cQuery += "   AND NOT EXISTS (SELECT 1 "
		cQuery += "                     FROM " + RetSqlName("N9I") + " N9I2 "
		cQuery += "                    WHERE N9I2.N9I_FILORG = N9I.N9I_FILORG "
		cQuery += "                      AND N9I2.N9I_CODINE = N9I.N9I_CODINE "
		cQuery += "                      AND N9I2.N9I_CONTNR = N9I.N9I_CONTNR "
		cQuery += "                      AND N9I2.D_E_L_E_T_ = ' ' "
		cQuery += "                      AND N9I2.N9I_INDSLD = '2') "
		cQuery += " GROUP BY N9I.N9I_CONTNR "

		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)

		If (cAliasQry)->(!EoF())
			While (cAliasQry)->(!EoF())

				nPos := aScan( aCnts, { |x| AllTrim( x[6] ) == AllTrim(cFilOri+(cAliasQry)->N9I_CONTNR)} )
				nQtdCtn := (cAliasQry)->QTDFIS

				If nPos == 0
					aAdd( aCnts, {(cAliasQry)->N9I_CONTNR,cFilOri, nQtdCtn, nQtdCtn, 1, AllTrim(cFilOri+(cAliasQry)->N9I_CONTNR)  } )			
				Else
					aCnts[nPos][3] += nQtdCtn
					aCnts[nPos][4] += nQtdCtn
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo
		EndIf
		(cAliasQry)->(dbCloseArea())		
	EndIf

	If Len(aCnts) > 0
		IncCont(cEmbarq, aCnts, nOperac, cFilOri)
	EndIf


Return .T.

/*/{Protheus.doc} IncCont
Realiza o envio dos conteineres para os embarques gerados para a IE
@type  Static Function
@author rafael.kleestadt
@since 24/01/2018
@version 1.0
@param cEmbarq, caracter, código do embarque gerado para a filial
@param aCnts, array, array com os dados dos conteineres a serem enviados
@param nOpc, numeric, operação a ser realizada 3-Inclusão, 4-Alteração, 5-Exclusão
@param cFilOri, caracter, filial do embarque
@return returno,return_type, return_description
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=318604330
/*/
Static Function IncCont(cEmbarq, aCnts, nOpc, cFilOri)
	Local aCab    := {}
	Local aItens  := {}
	Local aItem   := {}
	Local nX      := 0
	Local nOpcAux := 0

	Private lMsErroAuto := .F.

	If nOpc = 4 // Alteração

		DbSelectArea("EXA")

		//Verifica se existe conteiners já está cadastrados no EEC para o embarque para fazer a exlcusão
		DbSelectArea("EX9") 
		EX9->(DbSetorder(1)) // EX9_FILIAL+EX9_PREEMB+EX9_CONTNR
		If EX9->(DbSeek(cFilOri+cEmbarq))
			While EX9->(!Eof()) .AND. EX9->(EX9_FILIAL+EX9_PREEMB) == cFilOri+cEmbarq

				aCab := {}
				aAdd(aCab, {"EX9_PREEMB", EX9->EX9_PREEMB,  Nil}) //- Código do embarque gerado
				aAdd(aCab, {"EX9_CONTNR", EX9->EX9_CONTNR,  Nil}) //- Número do contêiner
				aAdd(aCab, {"EX9_DTRETI", EX9->EX9_DTRETI,  Nil}) //- Data de retirada
				aAdd(aCab, {"EX9_DTPREV", EX9->EX9_DTPREV,  Nil}) //- Dt prevista devolução
				aAdd(aCab, {"AUTDELETA",  "S",              Nil}) 

				EXA->(DbSetorder(1)) // EXA_FILIAL+EXA_PREEMB+EXA_CONTNR+EXA_SEQEMB+EXA_LOTE
				If EXA->(DbSeek(EX9->EX9_FILIAL+EX9->EX9_PREEMB+EX9->EX9_CONTNR))

					aItem := {}
					aAdd(aItem, {"EXA_PREEMB", EXA->EXA_PREEMB, Nil}) //- Código do embarque gerado
					aAdd(aItem, {"EXA_CONTNR", EXA->EXA_CONTNR, Nil}) //- Número do contêiner
					aAdd(aItem, {"EXA_COD_I" , EXA->EXA_COD_I,  Nil}) //- Código do produto
					aAdd(aItem, {"EXA_SEQEMB", EXA->EXA_SEQEMB, Nil}) //- Sequencial de lotes no contêiner
					aAdd(aItem, {"EXA_LOTE"  , EXA->EXA_LOTE,   Nil}) //- "ND"
					aAdd(aItem, {"EXA_QTDE"  , EXA->EXA_QTDE,   Nil}) //- Quantidade de Fardinhos(se grãos recebe 1)
					aAdd(aItem, {"EXA_PESOLQ", EXA->EXA_PESOLQ, Nil}) //- Soma do peso liquido dos fardinhos estufados(se grãos peso rateado conforme calculo na função IntCnt)
					aAdd(aItem, {"EXA_PESOBR", EXA->EXA_PESOBR, Nil}) //- Soma do peso bruto dos fardinhos estufados(se grãos peso rateado conforme calculo na função IntCnt)
					aAdd(aItem, {"AUTDELETA",  "S",             Nil}) 

					aItens := {}
					aAdd(aItens, aItem)

					//Criar registro na filial do Embarque
					cFilCor := cFilAnt
					cFilAnt := cFilOri

					MsAguarde({|| MSExecAuto( {|X,Y,Z| EECAE104(X,Y,Z)}, aCab, aItens, 5) }, STR0130)

					cFilAnt := cFilCor
				EndIf

				EX9->(DbSkip())
			EndDo
		EndIf		
	EndIf

	For nX := 1 To Len(aCnts)

		dDtReti := Posicione("N91",1,xFilial("N91")+N7Q->N7Q_CODINE+aCnts[nX][1],"N91_DTRETI")
		dDtPDev := Posicione("N91",1,xFilial("N91")+N7Q->N7Q_CODINE+aCnts[nX][1],"N91_DTPREV")

		aCab := {}
		aAdd(aCab, {"EX9_PREEMB", cEmbarq,      Nil}) //- Código do embarque gerado
		aAdd(aCab, {"EX9_CONTNR", aCnts[nX][1], Nil}) //- Número do contêiner
		aAdd(aCab, {"EX9_DTRETI", dDtReti,      Nil}) //- Data de retirada
		aAdd(aCab, {"EX9_DTPREV", dDtPDev,      Nil}) //- Dt prevista devolução
		aAdd(aCab, {"AUTDELETA" , "N",          Nil})

		aItem := {}
		aAdd(aItem, {"EXA_PREEMB", cEmbarq,         Nil}) //- Código do embarque gerado
		aAdd(aItem, {"EXA_CONTNR", aCnts[nX][1],    Nil}) //- Número do contêiner
		aAdd(aItem, {"EXA_COD_I" , N7Q->N7Q_CODPRO, Nil}) //- Código do produto
		aAdd(aItem, {"EXA_SEQEMB", "1",             Nil}) //- Sequencial de lotes no contêiner
		aAdd(aItem, {"EXA_LOTE"  , "ND",            Nil}) //- "ND"
		aAdd(aItem, {"EXA_QTDE"  , aCnts[nX][5],    Nil}) //- Quantidade de Fardinhos(se grãos recebe 1)
		aAdd(aItem, {"EXA_PESOLQ", aCnts[nX][4],    Nil}) //- Soma do peso liquido dos fardinhos estufados(se grãos peso rateado conforme calculo na função IntCnt)
		aAdd(aItem, {"EXA_PESOBR", aCnts[nX][3],    Nil}) //- Soma do peso bruto dos fardinhos estufados(se grãos peso rateado conforme calculo na função IntCnt)
		aAdd(aItem, {"AUTDELETA" , "N",             Nil})

		aItens := {}
		aAdd(aItens, aItem)

		//Verifica se o conteiner já está cadastrado no EEC para fazer a inclusão ou alteração
		EX9->(DbSelectArea("EX9")) 
		EX9->(DbSetorder(1))   
		if .Not. EX9->(DbSeek(aCnts[nX][2] + cEmbarq + aCnts[nX][1])) .And. nOpc <> 5 //Exclusão
			nOpcAux := 3 //Inclusão
		Else
			nOpcAux := nOpc
		EndIf
		EX9->(DbCloseArea()) 

		//Criar registro na filial do Embarque
		cFilCor := cFilAnt
		cFilAnt := aCnts[nX][2]

		MsAguarde({|| MSExecAuto( {|X,Y,Z| EECAE104(X,Y,Z)},aCab ,aItens, nOpcAux) }, STR0130)

		cFilAnt := cFilCor
	Next nX

	If lMsErroAuto
		MostraErro()
	EndIf

	Return Nil

	/*/{Protheus.doc} OGA710ACMV()
	Verifica se a IE tem Movimentações e se sim, chama a tela para viaualizar as movimenteções.
	@type Function
	@author Story Brakers
	@since date
	@version version
	@param param, param_type, param_descr
	@return returno,return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OGA710ACMV()
	Local cTpMov    := SuperGetMV("MV_AGRO009",.F.,'') //Tipo de movimento para Exportação
	Local cIdMov    := ''

	//Função válida somente para IE do tipo Externa
	If ValTpMerc(.F.) = "1" 
		Help(" ", 1, "OGA710TIPMERC") //##Problema: Função não disponível para mercado interno. ##Solução: Esta função é especifica para mercado externo.
		Return .T.
	EndIf

	//Verifica se já existe uma movimentação do tipo Exportação para a IE
	cAliasNKM := GetNextAlias()
	cQry := " SELECT NKM_IDMOV  "
	cQry += "     FROM " + RetSqlName("NKM") + " NKM "
	cQry += "    WHERE NKM.NKM_FILIAL = '" + xFilial('NKM') + "'"
	cQry += "      AND NKM.NKM_TIPOMV = '" + cTpMov + "'"
	cQry += "      AND NKM.NKM_CODINE = '" + N7Q->N7Q_CODINE + "'"
	cQry += "      AND NKM.D_E_L_E_T_ = ' ' "	
	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasNKM, .F., .T.) 
	DbselectArea( cAliasNKM )
	DbGoTop()
	If (cAliasNKM)->( !Eof() )
		cIdMov := (cAliasNKM)->NKM_IDMOV
	EndIf
	(cAliasNKM)->(DbCloseArea())	

	iF !__lAutomato
		If Empty(cIdMov)
			Help( ,,STR0026,, STR0132, 1, 0 ) //"AJUDA -Instrução de Embarque não está vinculada a uma Movimentação
		Else
			OGX001Mov(cIdMov, 4) //Alterar
		EndIf
	EndIf

Return .t.


/*{Protheus.doc} OGA710WHEN
Função desenvolvida para validar se o usuário logado tem permissão logistica ou não, caso tenha o campo
Importador, loja do importador, entidade e loja da entidade de entrega ficarão habilitados para edição. 
@author thiago.rover
@since 02/02/2018
@version undefined
@type function
*/
Function OGA710WHEN()

	Local lRet  := .F.

	If !Empty(RetCodUsr()) .AND. MPUserHasAccess('OGA710', 10, RetCodUsr())

		lRet := .T.

	EndiF

Return lRet

/*/{Protheus.doc} CarrRomDev
Carrega os arrays de cabeçalho(NJJ) e Itens de comercialização(NJM) para gerar o romaneio de devolução de venda
@type  Static Function
@author rafael.kleestadt
@since 08/02/2018
@version 1.0
@param cFilOri, caracter, código da filial do pedido de exportação gerado para a IE de Origem
@param cIeDest, caracter, código da IE de destino(que foi gerada na rolagem parcial)
@param cIeOrig, caracter, código da IE de origem
@param aFldNJJ, array, array dos dados do cabeçalho do romaneio
@param aFldNJM, array, array dos dados dos itens de comercialização do romaneio
@param aFldN9E, array, array dos dados da origem do romaneio
@param cPedido, caracter, Codigo do pedido
@return return, logical, True or False
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=305039786
/*/
Static Function CarrRomDev(cFilOri, cIeDest, cIeOrig , aFldNJJ, aFldNJM, aFldN9E, cPedido)
	Local cUn       := ''
	Local nTotValor := 0

	Local cImpOri   := Posicione("N7Q", 1, FwxFilial("N7Q")  + cIeOrig,"N7Q_IMPORT")
	Local cImpOriLj := Posicione("N7Q", 1, FwxFilial("N7Q")  + cIeOrig,"N7Q_IMLOJA")
	Local aItens    := {}
	Local nX        := 0

	Local nItRom     := 0	
	Local __nPesoRom := 0
	Local __nPrecMed := 0
	Local __cLocal   := Posicione("N7Q", 1, FwxFilial("N7Q")  + cIeOrig,"N7Q->N7Q_LOCAL")//N7Q->N7Q_LOCAL

	DbSelectArea('SB1')
	SB1->( DbSetOrder(1) )
	IF SB1->(DbSeek(Fwxfilial('SB1') + NJR->NJR_CODPRO ))
		__cLocal := IIf(Empty(__cLocal), SB1->B1_LOCPAD, __cLocal)
		cUn      := SB1->B1_UM
	EndIf

	If !ValTipProd() //Se o produto for algodão
		DbSelectArea("N83")
		DbSetorder(2)//N83_FILIAL+N83_CODINE+N83_FILORG+N83_BLOCO
		If N83->(DbSeek(xFilial("N83") + cIeDest + cFilOri))//Verifica se foi gravado quantidades na IE destino para a filial do pedido encontrado para a IE destino

			//Posiciona na IE destino para obter os dados da filial/pedido
			If N7Q->(DbSeek(xFilial("N7Q") + cIeDest))
				aItens := classFard(cFilOri, N7Q->N7Q_CODINE, .T.)
			EndIf

			//Percorre array para obter as quantidades do romaneio
			For nX := 1 To Len(aItens)
				If retDocNjm(aItens[nX][7], cFilOri, NJJ->NJJ_CODROM) //Verifica se tem NF
					__nPesoRom += aItens[nX][6] //peso bruto dos fardos
					nTotValor  += aItens[nX][7] * aItens[nX][3] //peso liquido dos fardos x preco
				EndIf
			Next nX

		EndIf
		N83->(DbCloseArea())
	Else
		cQuery := "   SELECT N7S.N7S_CODCTR, SUM(N7S.N7S_QTDVIN) AS PESO " 
		cQuery += "     FROM " + RetSqlName('N7S') + " N7S "
		cQuery += "    WHERE N7S.N7S_FILORG = '" + cFilOri + "'"
		cQuery += "      AND N7S.N7S_CODINE = '" + cIeDest + "'"  
		cQuery += "      AND N7S.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY N7S.N7S_CODCTR "
		cQuery := ChangeQuery(cQuery)
		cAliasN7S := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN7S, .F., .T.)
		If (cAliasN7S)->(!EoF())
			While (cAliasN7S)->(!EoF())
				If retDocNjm((cAliasN7S)->N7S_CODCTR, cFilOri, NJJ->NJJ_CODROM) //Verifica se tem NF
					__nPesoRom += (cAliasN7S)->PESO
				EndIf
				(cAliasN7S)->(dbSkip())
			End
		EndIf
		(cAliasN7S)->(dbCloseArea())
		nTotValor := __nPesoRom * NJR->NJR_VLRUNI	
	EndIf

	__nPrecMed := nTotValor / __nPesoRom  

	/*Dados Tipo Romaneio*/
	aAdd( aFldNJJ, { 'NJJ_FILIAL', cFilOri } )
	aAdd( aFldNJJ, { 'NJJ_TIPO'  , "9" } )//(E) DEVOLUCAO DE VENDA  
	aAdd( aFldNJJ, { 'NJJ_TPFORM', "1" } )//Formulário Prórpio: 1=Sim;2=Nao
	aAdd( aFldNJJ, { 'NJJ_TIPENT', "2" } )//Tipo de Controle: 0=C/Pesagem;1=Terceiros;2=S/Pesagem;3=Retenção 
	/*Dados do Contrato*/
	aAdd( aFldNJJ, { 'NJJ_CODCTR', ""} )
	aAdd( aFldNJJ, { 'NJJ_CODSAF', N7Q->N7Q_CODSAF} )
	//	aAdd( aFldNJJ, { 'NJJ_TES'   , N7Q->N7Q_TES	  } )
	aAdd( aFldNJJ, { 'NJJ_CODPRO', N7Q->N7Q_CODPRO} )
	aAdd( aFldNJJ, { 'NJJ_UM1PRO', cUn            } )
	aAdd( aFldNJJ, { 'NJJ_LOCAL' , __cLocal       } )
	/*Dados da Entidade*/
	aAdd( aFldNJJ, { 'NJJ_CODENT', cImpOri    } )
	aAdd( aFldNJJ, { 'NJJ_LOJENT', cImpOriLj  } )
	aAdd( aFldNJJ, { 'NJJ_ENTENT', cImpOri    } )
	aAdd( aFldNJJ, { 'NJJ_ENTLOJ', cImpOriLj  } )
	/*Dados Quantidade*/
	aAdd( aFldNJJ, { 'NJJ_PSSUBT', __nPesoRom 	 } )
	aAdd( aFldNJJ, { 'NJJ_PSBASE', __nPesoRom 	 } )
	aAdd( aFldNJJ, { 'NJJ_PSLIQU', __nPesoRom	 } )
	aAdd( aFldNJJ, { 'NJJ_PESO3' , __nPesoRom	 } )
	aAdd( aFldNJJ, { 'NJJ_QTDFIS' , __nPesoRom	 } )

	/*Dados Pesagem*/
	aAdd( aFldNJJ, { 'NJJ_DATA'  , dDataBase         } )
	aAdd( aFldNJJ, { 'NJJ_DATPS1', dDataBase 		 } )
	aAdd( aFldNJJ, { 'NJJ_HORPS1', Substr(Time(), 1,5) } )
	aAdd( aFldNJJ, { 'NJJ_PESO1' , __nPesoRom  	 } )
	aAdd( aFldNJJ, { 'NJJ_DATPS2', dDataBase 		 } )
	aAdd( aFldNJJ, { 'NJJ_HORPS2', Substr(Time(), 1,5) } )
	/*Dados Fixos*/
	aAdd( aFldNJJ, { 'NJJ_TRSERV', "0" } )
	aAdd( aFldNJJ, { 'NJJ_STSPES', "1" } )
	aAdd( aFldNJJ, { 'NJJ_STATUS', "1" } )
	aAdd( aFldNJJ, { 'NJJ_STSCLA', "1" } )
	aAdd( aFldNJJ, { 'NJJ_STAFIS', "1" } )
	aAdd( aFldNJJ, { 'NJJ_STACTR', "1" } ) 
	aAdd( aFldNJJ, { 'NJJ_TPFRET', "C" } )

	/*Itens comercialização*/
	cQuery := "   SELECT N83_CODCTR, N83_ITEM, N83_ITEREF, SUM(N83_PSLIQU) AS PESO " 
	cQuery += "     FROM " + RetSqlName('N83') + " N83 "
	cQuery += "    WHERE N83.N83_FILIAL = '" + xFilial("N83") + "'"
	cQuery += "      AND N83.N83_CODINE = '" + cIeDest + "'"
	cQuery += "      AND N83.N83_FILORG = '" + cFilOri + "'"  
	cQuery += "      AND N83.D_E_L_E_T_ = ' ' "
	cQuery += "      GROUP BY N83_CODCTR, N83_ITEM, N83_ITEREF "
	cQuery := ChangeQuery(cQuery)
	cAliasN83 := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN83, .F., .T.)
	If (cAliasN83)->(!EoF())
		While (cAliasN83)->(!EoF())
			If retDocNjm((cAliasN83)->N83_CODCTR, cFilOri, NJJ->NJJ_CODROM) //Verifica se tem NF
				If !OG250DCNJM(@nItRom, @aFldNJM, '', '', N7Q->N7Q_FILIAL, cIeOrig, (cAliasN83)->N83_CODCTR, (cAliasN83)->N83_ITEM, (cAliasN83)->N83_ITEREF, (cAliasN83)->PESO, __nPesoRom, __nPrecMed, cImpOri , cImpOriLj, __cLocal, __cIdMov, '', '', 3)
					Return .F.
				EndIf
			EndIf
			(cAliasN83)->(dbSkip())
		End
	Else
		cQuery := "   SELECT N7S.N7S_CODCTR, N7S.N7S_ITEM, N7S.N7S_SEQPRI, SUM(N7S.N7S_QTDVIN) AS PESO " 
		cQuery += "     FROM " + RetSqlName('N7S') + " N7S "
		cQuery += "    WHERE N7S.N7S_FILORG = '" + cFilOri + "'"
		cQuery += "      AND N7S.N7S_CODINE = '" + cIeDest + "'"
		cQuery += "      AND N7S.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY N7S.N7S_CODCTR, N7S.N7S_ITEM, N7S.N7S_SEQPRI "
		cQuery := ChangeQuery(cQuery)
		cAliasN7S := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN7S, .F., .T.)
		If (cAliasN7S)->(!EoF())
			While (cAliasN7S)->(!EoF())
				If retDocNjm((cAliasN7S)->N7S_CODCTR, cFilOri, NJJ->NJJ_CODROM) //Verifica se tem NF
					If !OG250DCNJM(@nItRom, @aFldNJM, '', '', N7Q->N7Q_FILIAL, cIeOrig, (cAliasN7S)->N7S_CODCTR, (cAliasN7S)->N7S_ITEM, (cAliasN7S)->N7S_SEQPRI, (cAliasN7S)->PESO, __nPesoRom, __nPrecMed, cImpOri, cImpOriLj, __cLocal, __cIdMov, '', '', 3)
						Return .F.
					EndIf
				EndIf
				(cAliasN7S)->(dbSkip())
			End
		EndIf
		(cAliasN7S)->(dbCloseArea())
	EndIf
	(cAliasN83)->(dbCloseArea())

	//Carrega array da tabela N9E
	carrN9E(aFldN9E, '2', cPedido, cFilOri, cIeDest, cIeOrig)

	return .T.


	/*/{Protheus.doc} OGA710Cnt()
	Função criada para carregar os containers da IE destino ao fazer a rolagem produto algodão
	@type  Static Function
	@author Janaina F B Duarte
	@since 06.02.2018
	@version 1.0
	@param param, param_type, param_descr
	@return aCNTS	 array  	Array de Containers da IE Destino
	/*/
Function OGA710Cnt(cIEDestino)
	Local cQueryDXI := ''
	Local cAliasDXI := ''
	Local aCnts     := {}
	//
	//busca os containers da IE destino, para isso varre a tabela DXI com os fardos rolados para a IE destino e busca os
	//containers (DXI_CONTNR)
	cAliasDXI := GetNextAlias()  
	cQueryDXI := " SELECT DISTINCT DXI.DXI_CONTNR "
	cQueryDXI += " FROM " + RetSqlName("DXI") + " DXI "
	cQueryDXI += " WHERE DXI.DXI_CODINE = '" +cIEDestino+ "'"
	cQueryDXI += "   AND DXI.D_E_L_E_T_ = ' ' "
	cQueryDXI += "   AND DXI.DXI_CONTNR <> '' "
	cQueryDXI += " ORDER BY DXI.DXI_CONTNR"

	cQueryDXI := ChangeQuery(cQueryDXI)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryDXI),cAliasDXI, .F., .T.) 

	dbSelectArea(cAliasDXI)
	(cAliasDXI)->( dbGoTop() )
	While !(cAliasDXI)->( Eof() )
		aAdd(aCnts, (cAliasDXI)->DXI_CONTNR)
		(cAliasDXI)->( DbSkip() )
	EndDo
	(cAliasDXI)->(DbCloseArea())

	Return aCnts

	/*/{Protheus.doc} OGA710CPC()
	Função criada para copiar os containers da IE ao fazer a rolagem 
	@type  Static Function
	@author Janaina F B Duarte
	@since 05.02.2018
	@version 1.0
	@param param, param_type, param_descr
	@return returno,return_type, return_description
	/*/
Function OGA710CPC(cIEOrigem, cIEDestino, cDesine, aCnts)
	Local cQueryN91 := ''
	Local cAliasN91 := ''
	Local nX        := 0
	Local lRet      := .T.
	Local cDB       := TcGetDB()

	For nX := 1 to Len(aCnts) 

		cAliasN91 := GetNextAlias() //busca os containers da IE origem 
		cQueryN91 := " SELECT N91_FILIAL, N91_CODINE, N91_CONTNR, N91_LACRE, "
		cQueryN91 += "        N91_TARA, N91_STATUS, N91_TIPCON, "
		
		if cDB == 'ORACLE'
		  //cQueryN91 += "        REPLACE(REPLACE(utl_raw.cast_to_varchar2(N91_VM_OBS),CHR(13),'CHR(13)'),CHR(10),'CHR(10)') AS N91_VM_OBS, "
			cQueryN91 += "        REPLACE(REPLACE(utl_raw.cast_to_varchar2(DBMS_LOB.SUBSTR(N91_VM_OBS,1000,1)),chr(13),''),chr(10),'')  AS N91_VM_OBS, "
		else
			cQueryN91 += "        ISNULL(CONVERT(VARCHAR(1024), CONVERT(VARBINARY(1024), N91_VM_OBS)),'') AS N91_VM_OBS, "
		endIf
		
		cQueryN91 += "        N91_DTRETI, N91_DTPREV, N91_DTDEVO, N91_CSIRIN, N91_INFOSI, N91_QTDBL, N91_QTDBLC, N91_SEQSI, "
		
		if cDB == 'ORACLE'
//			cQueryN91 += "        REPLACE(REPLACE(utl_raw.cast_to_varchar2(N91_SICOM),CHR(13),'CHR(13)'),CHR(10),'CHR(10)') AS N91_SICOM, "
			cQueryN91 += "        REPLACE(REPLACE(utl_raw.cast_to_varchar2(DBMS_LOB.SUBSTR(N91_SICOM,1000,1)),chr(13),''),chr(10),'')  AS N91_SICOM, "
		else
			cQueryN91 += "        ISNULL(CONVERT(VARCHAR(1024), CONVERT(VARBINARY(1024), N91_SICOM)),'') AS N91_SICOM,  "
		endIf

		cQueryN91 += "        N91_SINUM, "

		if cDB == 'ORACLE'
//			cQueryN91 += "        REPLACE(REPLACE(utl_raw.cast_to_varchar2(N91_SIRINS),CHR(13),'CHR(13)'),CHR(10),'CHR(10)') AS N91_SIRINS, "
			cQueryN91 += "        REPLACE(REPLACE(utl_raw.cast_to_varchar2(DBMS_LOB.SUBSTR(N91_SIRINS,1000,1)),chr(13),''),chr(10),'')  AS N91_SIRINS, "
		else
			cQueryN91 += "        ISNULL(CONVERT(VARCHAR(1024), CONVERT(VARBINARY(1024), N91_SIRINS)),'') AS N91_SIRINS, "
		endIf

		cQueryN91 += "        N91_TIPOBL, N91_BLNUM, N91_CUBAGE,N91_DTULAL,N91_HRULAL, "
		cQueryN91 += "        N91_BRTREM, N91_QTDREM, N91_BRTREC,N91_QTDREC,N91_QTDFRD, "
		cQueryN91 += "        N91_BRTCER, N91_QTDCER, N91_PCNTCN,N91_DPNTCN,N91_DTSAI, "
		cQueryN91 += "        N91_HRSAI, N91_DTCHEG, N91_HRCHEG, N91_DTCERT "
		cQueryN91 += " FROM " + RetSqlName("N91") + " N91 "
		cQueryN91 += " WHERE N91_CODINE = '" +cIEOrigem+ "'"
		cQueryN91 += "   AND N91_FILIAL = '"+xFilial("N91")+"'  "
		cQueryN91 += "   AND N91_CONTNR = '"+aCnts[nX]+"'  "
		cQueryN91 += "   AND D_E_L_E_T_ = ' ' "
		cQueryN91 += " ORDER BY N91_CONTNR"

		cQueryN91 := ChangeQuery(cQueryN91)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryN91),cAliasN91, .F., .T.) 

		DbSelectArea(cAliasN91) 
		(cAliasN91)->( dbGoTop() )
		While !(cAliasN91)->( Eof() )

			//Insere na IE Destino
			DbSelectArea("N91")
			RecLock("N91", .T.) 
			N91->(N91_FILIAL) := (cAliasN91)->(N91_FILIAL) 
			N91->(N91_CODINE) := cIEDestino
			//N91->(N91_DESINE) := cDesine
			N91->(N91_CONTNR) := (cAliasN91)->(N91_CONTNR)
			N91->(N91_LACRE)  := (cAliasN91)->(N91_LACRE)
			N91->(N91_TARA)   := (cAliasN91)->(N91_TARA)
			N91->(N91_STATUS) := (cAliasN91)->(N91_STATUS)
			N91->(N91_TIPCON) := (cAliasN91)->(N91_TIPCON)
			N91->(N91_VM_OBS) := (cAliasN91)->(N91_VM_OBS)
			N91->(N91_DTRETI) := cToD(SUBSTR((cAliasN91)->N91_DTRETI, 7, 2) + "/" + SUBSTR((cAliasN91)->N91_DTRETI, 5, 2) + "/" + SUBSTR((cAliasN91)->N91_DTRETI, 1, 4)) 
			N91->(N91_DTPREV) := cToD(SUBSTR((cAliasN91)->N91_DTPREV, 7, 2) + "/" + SUBSTR((cAliasN91)->N91_DTPREV, 5, 2) + "/" + SUBSTR((cAliasN91)->N91_DTPREV, 1, 4))
			N91->(N91_DTDEVO) := cToD(SUBSTR((cAliasN91)->N91_DTDEVO, 7, 2) + "/" + SUBSTR((cAliasN91)->N91_DTDEVO, 5, 2) + "/" + SUBSTR((cAliasN91)->N91_DTDEVO, 1, 4))
			N91->(N91_CSIRIN) := (cAliasN91)->(N91_CSIRIN)
			N91->(N91_INFOSI) := (cAliasN91)->(N91_INFOSI) 
			N91->(N91_QTDBL)  := (cAliasN91)->(N91_QTDBL) 
			N91->(N91_QTDBLC) := (cAliasN91)->(N91_QTDBLC)
			N91->(N91_SEQSI)  := (cAliasN91)->(N91_SEQSI)
			N91->(N91_SICOM)  := (cAliasN91)->(N91_SICOM)
			N91->(N91_SINUM)  := (cAliasN91)->(N91_SINUM)
			N91->(N91_SIRINS) := (cAliasN91)->(N91_SIRINS)
			N91->(N91_TIPOBL) := (cAliasN91)->(N91_TIPOBL)
			N91->(N91_BLNUM)  := (cAliasN91)->(N91_BLNUM)
			N91->(N91_CUBAGE) := (cAliasN91)->(N91_CUBAGE)
			N91->(N91_DTULAL) := cToD(SUBSTR((cAliasN91)->N91_DTULAL, 7, 2) + "/" + SUBSTR((cAliasN91)->N91_DTULAL, 5, 2) + "/" + SUBSTR((cAliasN91)->N91_DTULAL, 1, 4))
			N91->(N91_HRULAL) := (cAliasN91)->(N91_HRULAL)
			N91->(N91_BRTREM) := (cAliasN91)->(N91_BRTREM)
			N91->(N91_QTDREM) := (cAliasN91)->(N91_QTDREM)
			N91->(N91_BRTREC) := (cAliasN91)->(N91_BRTREC)
			N91->(N91_QTDREC) := (cAliasN91)->(N91_QTDREC)
			N91->(N91_QTDFRD) := (cAliasN91)->(N91_QTDFRD)
			N91->(N91_BRTCER) := (cAliasN91)->(N91_BRTCER)
			N91->(N91_QTDCER) := (cAliasN91)->(N91_QTDCER)
			N91->(N91_PCNTCN) := (cAliasN91)->(N91_PCNTCN)
			N91->(N91_DPNTCN) := (cAliasN91)->(N91_DPNTCN)
			N91->(N91_DTSAI)  := cToD(SUBSTR((cAliasN91)->N91_DTSAI, 7, 2) + "/" + SUBSTR((cAliasN91)->N91_DTSAI, 5, 2) + "/" + SUBSTR((cAliasN91)->N91_DTSAI, 1, 4))
			N91->(N91_HRSAI)  := (cAliasN91)->(N91_HRSAI)
			N91->(N91_DTCHEG) := cToD(SUBSTR((cAliasN91)->N91_DTCHEG, 7, 2) + "/" + SUBSTR((cAliasN91)->N91_DTCHEG, 5, 2) + "/" + SUBSTR((cAliasN91)->N91_DTCHEG, 1, 4))
			N91->(N91_HRCHEG) := (cAliasN91)->(N91_HRCHEG)
			N91->(N91_DTCERT) := cToD(SUBSTR((cAliasN91)->N91_DTCERT, 7, 2) + "/" + SUBSTR((cAliasN91)->N91_DTCERT, 5, 2) + "/" + SUBSTR((cAliasN91)->N91_DTCERT, 1, 4))
			N91->( MsUnlock() )

			(cAliasN91)->( DbSkip() )
		EndDo
		(cAliasN91)->(DbCloseArea())
	Next nX

	Return lRet 


	/*/{Protheus.doc} OGA710EXC()
	Função criada para excluir os containers da IE origem que foram copiados para a IE destino ao fazer a rolagem 
	@type  Static Function
	@author Janaina F B Duarte
	@since 05.02.2018
	@version 1.0
	@param param, param_type, param_descr
	@return returno,return_type, return_description
	/*/
Function OGA710EXC(cIEOrigem, aCnts)
	Local nX        := 0
	Local lRet      := .T.

	For nX := 1 to Len(aCnts) 

		dbSelectArea('N91')
		N91->( dbSetOrder(1) )
		N91->( dbSeek( xFilial('N91') + cIEOrigem + aCnts[nX] ) )
		IF ! N91->( Eof() )
			If RecLock( 'N91', .f. )	
				N91->( dbDelete() )
				N91->( MsUnlock() )
			Endif
		Endif

	Next nX

Return lRet

/*/{Protheus.doc} ajusPsIe
Ajusta as quantidades da Instrução de Embarque
@type  Static Function
@author rafael.kleestadt
@since 09/02/2018
@version 1.0
@param cCodine, caractere, código único da IE
@param lAlgodao, logical, .T. - Algodao; .F. - Grãos
@return .T., Logical, True or False
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=305039786
/*/
Static Function ajusPsIe(cIEOrig, lAlgodao, cIEDest, oModel)
	Local aAreaAtu	:= GetArea()
	Local aAreaN7Q	:= N7Q->(GetArea())
	Local oN7Q	  := oModel:GetModel( "N7QUNICO" )
	Local nQtdRem := 0 //N7Q_QTDREM Peso de saída do Fardo
	Local nQtdRec := 0 //N7Q_QTDREC Peso de Chegada
	Local nQtdCer := 0 //N7Q_QTDCER Peso Certificado do Fardo
	Local nQtdFCe := 0 //N7Q_QFRCER Total Fardos Certificados
	Local nPcrMce := 0 //N7Q_PCRMCE % Variação Peso Certificado
	Local nQtdCor := 0 //N7Q_QTDCOR Qtd Containers Reservados
	Local nQtdFar := 0 //N7Q_TOTFAR Qtd FARDOS DA IE	
	
	If lAlgodao
		// Carrega as variaveis que são baseadas nos fardos
		DbSelectArea("N7S")
		N7S->(DbSetorder(1)) 
		If N7S->(dbSeek( FWxFilial("N7S") + cIEOrig ) )
			While N7S->( !Eof() ) .AND. N7S->N7S_CODINE = cIEOrig  
				DbSelectArea("DXI")
				DXI->(DbSetorder(8)) //DXI_FILIAL+DXI_CODINE+DXI_ITEINE
				If DXI->(DbSeek(N7S->N7S_FILORG + N7S->N7S_CODINE))
					While !DXI->( Eof() ) .AND. DXI->DXI_CODINE == N7S->N7S_CODINE
		
						nQtdRem += DXI->DXI_PESSAI
						nQtdRec += DXI->DXI_PESCHE
						nQtdFar ++
		
						If DXI->DXI_PESCER <> 0
							nQtdCer += DXI->DXI_PESCER
							nQtdFCe ++
						EndIf
		
						DXI->(DbSkip())
					EndDo
				EndIf				
				N7S->(DbSkip())
			EndDo
				
		
		EndIf
		
		// calcula o percentual de  variação entre o peso remetido e certificado dos contêineres da IE.
		nPcrMce := IIF(nQtdCer > 0, round(((( nQtdCer / nQtdRem ) - 1) * 100),2) , 0 )
	
	EndIf
		
	// Carrega as variaveis que são baseadas nos contêineres
	DbSelectArea("N91")
	DbSetorder(1) //N91_FILIAL+N91_CODINE+N91_CONTNR
	If N91->(DbSeek(FwxFilial("N91") + cIEOrig))
		While !N91->( Eof() ) .AND. N91->N91_CODINE == cIEOrig

			nQtdCor ++
			If !lAlgodao .AND. N91->N91_STATUS $ "4|5|6"
				nQtdCer += N91->N91_QTDCER
			EndIf

			N91->(DbSkip())
		EndDo
	EndIf

	//Faz o commit dos dados na IE
	DbSelectArea("N7Q")
	N7Q->(DbSetorder(1)) //N7Q_FILIAL+N7Q_CODINE
	If N7Q->(DbSeek(FwxFilial("N7Q") + cIEOrig))
		If RecLock( "N7Q", .F. )
			If !lAlgodao
				nQtdRem := N7Q->N7Q_QTDREM - oN7Q:GetValue("N7Q_QTDREM")
				nPcrMce := IIF(nQtdCer > 0, round(((( nQtdCer / nQtdRem ) - 1) * 100),2) , 0 )
			EndIf
			N7Q->N7Q_QTDREM := nQtdRem
			N7Q->N7Q_QTDREC := nQtdRec
			N7Q->N7Q_QTDCER := nQtdCer
			N7Q->N7Q_QFRCER := nQtdFCe
			N7Q->N7Q_PCRMCE := nPcrMce
			N7Q->N7Q_QTDCOR := nQtdCor
			N7Q->N7Q_TOTFAR := nQtdFar
			N7Q->N7Q_TOTLIQ := N7Q->N7Q_TOTLIQ - oN7Q:GetValue("N7Q_TOTLIQ")
			N7Q->N7Q_TOTBRU := N7Q->N7Q_TOTBRU - oN7Q:GetValue("N7Q_TOTBRU")
			N7Q->N7Q_QTDCON := N7Q->N7Q_QTDCON - oN7Q:GetValue("N7Q_QTDCON")
			N7Q->(MsUnLock())
		EndIf		
	EndIf
	
	RestArea(aAreaN7Q)
	RestArea(aAreaAtu)

Return .T.

/** {Protheus.doc} OG710NFExp
Gerar Romaneio de Exportação para Geração do Romaneio de Exportação
@param: 	Nil
@return:	Nil
@author: 	Tamyris Ganzenmueller
@since: 	
@Uso: 		OGA710 */
Function OG710NFExp()
	Local aArea     := GetArea()
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oPnDown   := Nil
	Local oSize     := Nil
	Local oBrwMrk 	:= Nil
	Local aButtons  := {}
	Local nOpcX     := 0
	Local cFiltro   := FiltraMark() 

	/*Validações*/
	//Função válida somente para IE do tipo Externa
	If ValTpMerc(.F.) = "1" 
		Help(" ", 1, "OGA710TIPMERC") //##Problema: Função não disponível para mercado interno. ##Solução: Esta função é especifica para mercado externo.
		Return .T.
	EndIf
	
	//Opção Aprovar - Status Exp diferente de Gerado
	IF N7Q->N7Q_STAEXP <> 3 //3-Gerado
		Help(" ", 1, ".OGA710000001.") //##Problema: Status Processo Exp Inválido ##Solução:Instrução de Embarque deve estar com Processo de Exportação gerado
		Return .T.
	EndIF	

	//Caso já exista romaneio com alguma NF pendente de retorno SEFAZ, não continuar e mostrar que mensagem de alerta
	IF NFPendSEF(N7Q->N7Q_FILIAL, N7Q->N7Q_CODINE)    
		Help(" ", 1, ".OGA710000005.") //##Problema: "Existe(m) Romaneio(s) de Exportação cuja(s) Notas Fiscal(is) estão pendentes de retorno da SEFAZ. Geração não permitida!
		Return .T.
	EndIF

	If N7Q->N7Q_QTDCON <> N7Q->N7Q_QTDCOR 
		MsgAlert(STR0180 + AllTrim(STR(N7Q->N7Q_QTDCOR)) + STR0181 + AllTrim(STR(N7Q->N7Q_QTDCON)) +".")//"A quantidade de Contêineres vinculados deve ser igual a quantidade de contêineres solicitados(campo Q. Contêiner pasta Itens da IE)."
		Return .T.
	EndIf

	If .Not. ValFarCnt('2')// Valida se não tem contêiner vazio e fardo ser contêiner ##Param: '1'-Aprovar peso certificado, '2'-Gerar Nf de exportação
		Return .T.
	EndIf
	
	If AGRTPALGOD(N7Q->N7Q_CODPRO)
		If N7Q->N7Q_STAPCT = '0'  //Se analise Pegajosidade estiver confirmada não valida  //0-Não Aprovado#1-Aprovado
			Help(" ", 1, ".OGA710000013.") //##Problema: "É nessário aprovar contaminantes para gerar NF de Exportação."
			Return .F.	
		EndIf
		
		If !Empty(OGA710VALID()) 
			Help( ,,"AJUDA",, cRetorno, 1, 0 ) 
			Return .F.	
		Endif
	EndIf
		
	Begin Transaction
		oSize := FWDefSize():New(.T.)
		oSize:AddObject( "ALL", 100, 100, .T., .T. )    
		oSize:lLateral	:= .F.  // Calculo vertical	
		oSize:Process() //executa os calculos

		oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4],;
		STR0144 , , , , , CLR_BLACK, CLR_WHITE, , , .t. ) 

		oFwLayer := FwLayer():New()
		oFwLayer:Init( oDlg, .f., .t. )

		oFWLayer:AddLine( 'UP', 5, .F. )
		oFWLayer:AddCollumn( 'ALL' , 100, .T., 'UP' )

		oFWLayer:AddLine( 'DOWN', 95, .F. )
		oFWLayer:AddCollumn( 'ALL' , 100, .T., 'DOWN' )

		oPnDown := TPanel():New(0 , 0,,oDlg,,.F.,.F.,,,450,960,.T.,.T.)
		oPnDown:Align	:= CONTROL_ALIGN_ALLCLIENT 

		oBrwMrk:=FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
		oBrwMrk:SetDescription( STR0144 ) // Define o titulo do MarkBrowse
		oBrwMrk:SetFilterDefault(cFiltro)
		oBrwMrk:SetAlias("N82") 
		oBrwMrk:SetFieldMark("N82_OK")	// Define o campo utilizado para a marcacao		
		oBrwMrk:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
		oBrwMrk:SetMenuDef("")	// Desabilita a opcao de imprimir	    
		oBrwMrk:Activate(oPnDown)	// Ativa o MarkBrowse
		oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| nOpcX := 1, oDlg:End() },{|| nOpcX := 0, oDlg:End() },, @aButtons ) } )

		If nOpcX = 1
			GeraRom(oBrwMrk)
		EndIf

		RestArea(aArea)
	End Transaction
Return .T.

/** {Protheus.doc} FiltraMark
@param: 	Nil
@return:	Nil
@author: 	Tamyris Ganzenmueller
@since: 	05/03/2018
@Uso: 		OGA710 */
Static Function FiltraMark()
	Local cQuery := ""

	cQuery := "        N82_FILIAL = '" + N7Q->N7Q_FILIAL  + "' " + ;
	"  .And. N82_CODINE = '" + N7Q->N7Q_CODINE  + "' " 

Return cQuery

/** {Protheus.doc} GeraRom
Rotina para gerar nota fiscal de exportação conforme registros marcados
@param: 	oBrwMrk
@return:	Nil
@author: 	Tamyris Ganzenmueller
@since: 	05/03/2018
@Uso: 		OGA710 */
Static Function GeraRom(oBrwMrk)

	Local lRet   := .T.
	Local cAliasN9E  := GetNextAlias() 
	Local cAliasDXI := ""
	Local lFaturad := .F.
	Local lPendent := .T.
	Local cQry := ""
	Local cQuery := ""

	//Verifica se existe algum romaneio de exportação que deve ser excluído	
	cQry := " SELECT DISTINCT N9E.N9E_FILIAL, N9E.N9E_CODROM, N9E.N9E_PEDIDO "
	cQry += " FROM " + RetSqlName("N9E") + " N9E "
	cQry += " WHERE N9E.N9E_FILIE = '" + N7Q->N7Q_FILIAL + "' "
	cQry += " AND N9E.N9E_CODINE = '" + N7Q->N7Q_CODINE + "' "
	cQry += " AND N9E.D_E_L_E_T_ = ' ' "
	cQry += " AND N9E.N9E_ORIGEM = '1' "
	cQry += " AND (((SELECT SUM(N7S.N7S_QTDVIN) FROM  " + RetSqlName("N7S") + " N7S " 
	cQry += " WHERE N7S.N7S_FILIAL = N9E.N9E_FILIE "
	cQry += " AND N7S.N7S_CODINE = N9E.N9E_CODINE " 
	cQry += " AND N7S.N7S_FILORG = N9E.N9E_FILIAL "
	cQry += " AND N7S.D_E_L_E_T_ = ' ' "
	cQry += " GROUP BY N7S.N7S_FILIAL, N7S.N7S_CODINE ) <= 0 ) "
	cQry += " OR ( NOT EXISTS (SELECT 1 FROM  " + RetSqlName("N7S") + " N7S "
	cQry += " WHERE N7S.N7S_FILIAL = N9E.N9E_FILIE "
	cQry += " AND N7S.N7S_CODINE = N9E.N9E_CODINE "
	cQry += " AND N7S.N7S_FILORG = N9E.N9E_FILIAL " 
	cQry += " AND N7S.D_E_L_E_T_ = ' ' )  ) )  "

	// Apenas busca os romaneios que não possuem romaneios de devolução
	cQry += " AND ( NOT EXISTS (SELECT 1 FROM  " + RetSqlName("N9E") + " N9E2 "
	cQry += " WHERE N9E2.N9E_FILIAL = N9E.N9E_FILIAL "
	cQry += " AND N9E2.N9E_PEDIDO = N9E.N9E_PEDIDO "
	cQry += " AND N9E2.N9E_ORIGEM = '2' " 
	cQry += " AND N9E2.D_E_L_E_T_ = ' ' )  ) "
	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasN9E, .F., .T.) 
	If (cAliasN9E)->( !Eof() )
		While (cAliasN9E)->(!EoF())
			DbSelectArea("NJJ")
			DbSetorder(1)//NJJ_FILIAL+NJJ_COROM		
			If NJJ->(DbSeek( (cAliasN9E)->N9E_FILIAL + (cAliasN9E)->N9E_CODROM ) ) //Foi gerado romaneio para a IE de Origem

				If NJJ->NJJ_STATUS = '2' //Atualizado => Reabre o Romaneio
					aValores := {}
					aAdd(aValores, "NJJ" )
					aAdd(aValores, (NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM) )
					aAdd(aValores, "B"  )  //Tipo = Alteracao
					aAdd(aValores, STR0144 ) //Gerar NF Exportação
					OGA250REA( Alias(), Recno(), 4 , aValores) 
				EndIf

				//0-Pendente, 1-Completo, 2-Atualizado => Cancela o Romaneio
				IF NJJ->NJJ_STATUS $ '0,1,2' //
					aValores := {}
					aAdd(aValores, "NJJ" )
					aAdd(aValores, (NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM) )
					aAdd(aValores, "C"  )  //Tipo = Alteracao
					aAdd(aValores, STR0144 ) //Gerar NF Exportação
					lRet := OGA250CAN( Alias(), Recno(), 4 , aValores) 
				EndIf

				//Confirmado => Será gerado romaneio de devolução
				If NJJ->NJJ_STATUS = '3' 
					MsgRun( STR0137, STR0136, {|| InsRoman((cAliasN9E)->N9E_FILIAL,(cAliasN9E)->N9E_PEDIDO, , ,'D') } )//"AGUARDE"!###"Gerando Romaneio..."
				EndIf

				cAliasDXI := GetNextAlias()
				//Exclui registro de fardos para recriá-los
				//verifica se foram selecionados fardos para o bloco da IE
				cQuery := " SELECT DXI.R_E_C_N_O_ AS DXI_RECNO "
				cQuery += " FROM " + RetSqlName("DXI") + " DXI "
				cQuery += " WHERE DXI_CODINE = '" + N7Q->N7Q_CODINE + "'"
				cQuery += "   AND DXI_FILIAL = '" + (cAliasN9E)->N9E_FILIAL + "'"
				cQuery += "   AND DXI_ROMSAI = '" + (cAliasN9E)->N9E_CODROM + "'"
				cQuery += "   AND DXI.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasDXI, .F., .T.)
				If (cAliasDXI)->(!EoF())
					While (cAliasDXI)->(!EoF())

						dbSelectArea("DXI")
						DXI->(DbGoTo( (cAliasDXI)->DXI_RECNO ) )
						If RecLock( "DXI", .f.)
							DXI->DXI_ROMSAI := ''
							DXI->(MsUnlock())
						EndIf
						DXI->(DbCloseArea())
						(cAliasDXI)->(dbSkip())
					End
				EndIf
				(cAliasDXI)->(DbCloseArea())
			EndIf
			(cAliasN9E)->(dbSkip())
		EndDo	
	EndIf
	(cAliasN9E)->(DbCloseArea())

	If ValSalVinc(oBrwMrk) .And. ValSalDAC(oBrwMrk) .And. ValDACAut(oBrwMrk)
		//Posiciona no topo da lista	
		N82->(dbGoTop())
		N82->(dbSetorder(1)) //N82_FILIAL+N82_CODINE
		N82->(dbSeek( N7Q->N7Q_FILIAL + N7Q->N7Q_CODINE) )
		While N82->( !Eof() .And. N82->N82_FILIAL==N7Q->N7Q_FILIAL .And. N82->N82_CODINE==N7Q->N7Q_CODINE   )

			//Verifica se produtor foi selecionado
			If oBrwMrk:IsMark()
				MsgRun( STR0137, STR0136, {|| InsRoman(N82->N82_FILORI,N82->N82_PEDIDO, , ,'4') } )//"AGUARDE"!###"Gerando Romaneio..."												
			Endif
			N82->(dbSkip())

		EndDo
	Endif		

	/* Atualização do Status de Faturamento da IE */

	lPendent := .T.
	lFaturad := .T.

	//Verifica se na instrução de embarque existem outros pedidos pendentes de geração da nota fiscal
	cQuery := " SELECT C5_NOTA "
	cQuery += " FROM " + RetSqlName('N82') + " N82 "
	cQuery += "	 LEFT JOIN " + RetSqlName("EE7") + " EE7 ON EE7.EE7_FILIAL = N82.N82_FILORI AND EE7.EE7_PEDIDO = N82.N82_PEDIDO AND EE7.D_E_L_E_T_ = ' ' "	
	cQuery += "	 LEFT JOIN " + RetSqlName('SC5') + " SC5 ON SC5.C5_FILIAL  = EE7.EE7_FILIAL AND SC5.C5_NUM = EE7.EE7_PEDFAT AND SC5.D_E_L_E_T_ = ' ' "
	cQuery += "    WHERE N82.N82_FILIAL = '" + N7Q->N7Q_FILIAL + "' "
	cQuery += "      AND N82.N82_CODINE = '" + N7Q->N7Q_CODINE + "' "
	cQuery += "      AND N82.D_E_L_E_T_ = ' ' "	
	cAliasSC5 := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSC5, .F., .T.)

	While .Not. (cAliasSC5)->(Eof())

		//Indica que foi gerado nota fiscal para um dos processos de exportação, ou seja, o faturamente não está pendente
		If !Empty((cAliasSC5)->C5_NOTA)
			lPendent := .F.
		EndIf

		//Indica que ainda existem pedidos de exportação pendentes - sem NF
		If Empty((cAliasSC5)->C5_NOTA)
			lFaturad := .F.
		EndIF
		(cAliasSC5)->( dbSkip() )
	Enddo
	(cAliasSC5)->(dbCloseArea())

	If RecLock('N7Q',.F.)	
		//1-Pendente;2-Parcial;3-Faturada
		If lPendent
			N7Q->N7Q_STAFAT := '1' 
		Else
			N7Q->N7Q_STAFAT := IIf(lFaturad,'3','2')
		EndIf		
		N7Q->(MsUnlock()) 	
	EndIf

Return .T.

/*/{Protheus.doc} CarrRomDEx
Carrega os arrays de cabeçalho(NJJ) e Itens de comercialização(NJM) para gerar o romaneio de devolução de exportação
@type  Static Function
@author rafael.kleestadt
@since 26/02/2018
@version 1.0
@param cFilOri, caracter, código da filial do pedido de exportação gerado para a IE de Origem
@param cIeDest, caracter, código da IE de destino(que foi gerada na rolagem parcial)
@param cIeOrig, caracter, código da IE de origem
@param aFldNJJ, array, array dos dados do cabeçalho do romaneio
@param aFldNJM, array, array dos dados dos itens de comercialização do romaneio
@param aFldN9E, array, array dos dados da origem do romaneio
@param cPedido, caracter, Codigo do pedido
@return return, logical, True or False
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=305039786
/*/
Static Function CarrRomDEx(cFilOri, cIeDest, cIeOrig , aFldNJJ, aFldNJM, aFldN9E, cPedido)

	Local nI := 0

	/*Dados Tipo Romaneio*/
	aAdd( aFldNJJ, { 'NJJ_FILIAL', NJJ->NJJ_FILIAL } )
	aAdd( aFldNJJ, { 'NJJ_TIPO'  , "9" } )//(E) DEVOLUCAO DE VENDA  
	aAdd( aFldNJJ, { 'NJJ_TPFORM', "1" } )//Formulário Prórpio: 1=Sim;2=Nao
	aAdd( aFldNJJ, { 'NJJ_TIPENT', "2" } )//Tipo de Controle: 0=C/Pesagem;1=Terceiros;2=S/Pesagem;3=Retenção 
	/*Dados do Contrato*/
	aAdd( aFldNJJ, { 'NJJ_CODCTR', ""} )
	aAdd( aFldNJJ, { 'NJJ_CODSAF', NJJ->NJJ_CODSAF} )
	aAdd( aFldNJJ, { 'NJJ_TES'   , Posicione("SF4",1,xFilial("SF4")+NJJ->NJJ_TES,"F4_TESDV") } )
	aAdd( aFldNJJ, { 'NJJ_CODPRO', NJJ->NJJ_CODPRO} )
	aAdd( aFldNJJ, { 'NJJ_UM1PRO', NJJ->NJJ_UM1PRO} )
	aAdd( aFldNJJ, { 'NJJ_LOCAL' , NJJ->NJJ_LOCAL } )
	/*Dados da Entidade*/
	aAdd( aFldNJJ, { 'NJJ_CODENT', NJJ->NJJ_CODENT} )
	aAdd( aFldNJJ, { 'NJJ_LOJENT', NJJ->NJJ_LOJENT} )
	aAdd( aFldNJJ, { 'NJJ_ENTENT', NJJ->NJJ_ENTENT} )
	aAdd( aFldNJJ, { 'NJJ_ENTLOJ', NJJ->NJJ_ENTLOJ} )
	/*Dados Quantidade*/
	aAdd( aFldNJJ, { 'NJJ_PSSUBT', NJJ->NJJ_PSSUBT } )
	aAdd( aFldNJJ, { 'NJJ_PSBASE', NJJ->NJJ_PSBASE } )
	aAdd( aFldNJJ, { 'NJJ_PSLIQU', NJJ->NJJ_PSLIQU } )
	aAdd( aFldNJJ, { 'NJJ_PESO3' , NJJ->NJJ_PSLIQU } )
	aAdd( aFldNJJ, { 'NJJ_QTDFIS', NJJ->NJJ_PSLIQU } )	
	/*Dados Pesagem*/
	aAdd( aFldNJJ, { 'NJJ_DATA'  , NJJ->NJJ_DATA   } )
	aAdd( aFldNJJ, { 'NJJ_DATPS1', NJJ->NJJ_DATPS1 } )
	aAdd( aFldNJJ, { 'NJJ_HORPS1', NJJ->NJJ_HORPS1 } )
	aAdd( aFldNJJ, { 'NJJ_PESO1' , NJJ->NJJ_PESO1  } ) 
	aAdd( aFldNJJ, { 'NJJ_DATPS2', NJJ->NJJ_DATPS2 } )
	aAdd( aFldNJJ, { 'NJJ_HORPS2', NJJ->NJJ_HORPS2 } )
	/*Dados Fixos*/
	aAdd( aFldNJJ, { 'NJJ_TRSERV', "0" } )
	aAdd( aFldNJJ, { 'NJJ_STSPES', "1" } )
	aAdd( aFldNJJ, { 'NJJ_STATUS', "1" } )
	aAdd( aFldNJJ, { 'NJJ_STSCLA', "1" } )
	aAdd( aFldNJJ, { 'NJJ_STAFIS', "1" } )
	aAdd( aFldNJJ, { 'NJJ_STACTR', "1" } ) 
	aAdd( aFldNJJ, { 'NJJ_TPFRET', "C" } )

	/*Itens comercialização*/
	DbSelectArea("NJM")
	DbSetorder(1)//NJM_FILIAL+NJM_CODROM+NJM_ITEROM
	If NJM->(DbSeek(NJJ->NJJ_FILIAL + NJJ->NJJ_CODROM) ) 
		While !( NJM->( Eof() ) ) .And. NJM->( NJM_FILIAL ) + NJM->( NJM_CODROM ) == xFilial( "NJM" ) + NJJ->( NJJ_CODROM )
			nI++
			aAux := {} 
			aAdd(aAux, {'NJM_ITEROM', StrZero(nI,2)})
			aAdd(aAux, {'NJM_CODENT', NJM->NJM_CODENT})
			aAdd(aAux, {'NJM_LOJENT', NJM->NJM_LOJENT})
			aAdd(aAux, {'NJM_CODSAF', NJM->NJM_CODSAF})
			aAdd(aAux, {'NJM_TES   ', Posicione("SF4",1,xFilial("SF4")+NJM->NJM_TES,"F4_TESDV")})
			aAdd(aAux, {'NJM_CODPRO', NJM->NJM_CODPRO})
			aAdd(aAux, {'NJM_UM1PRO', NJM->NJM_UM1PRO})
			aAdd(aAux, {'NJM_CODINE', NJM->NJM_CODINE})
			aAdd(aAux, {'NJM_CODCTR', NJM->NJM_CODCTR})
			aAdd(aAux, {'NJM_ITEM',   NJM->NJM_ITEM})
			aAdd(aAux, {'NJM_SEQPRI', NJM->NJM_SEQPRI})
			aAdd(aAux, {'NJM_VLRUNI', NJM->NJM_VLRUNI})
			aAdd(aAux, {'NJM_PERDIV', NJM->NJM_PERDIV})
			aAdd(aAux, {'NJM_STAFIS', "1"})
			aAdd(aAux, {'NJM_TPFORM', "1"})
			aAdd(aAux, {'NJM_NFPSER', ""})
			aAdd(aAux, {'NJM_NFPNUM', ""})
			aAdd(aAux, {'NJM_TRSERV', "0"})  // não })
			aAdd(aAux, {'NJM_QTDFIS',  NJM->NJM_QTDFIS})
			aAdd(aAux, {'NJM_QTDFCO',  NJM->NJM_QTDFCO})
			aAdd(aAux, {'NJM_LOCAL ',  NJM->NJM_LOCAL })  
			aAdd(aAux, {'NJM_IDMOV ',  NJM->NJM_IDMOV })

			aAdd( aFldNJM, aAux )

			NJM->( DbSkip() )					
		EndDo
	EndIf

	/*Itens comercialização*/
	DbSelectArea("N9E")
	DbSetorder(1)//N9E_FILIAL+N9E_CODROM+N9E_SEQUEN
	If N9E->(DbSeek(NJJ->NJJ_FILIAL + NJJ->NJJ_CODROM) ) 
		While !( N9E->( Eof() ) ) .And. N9E->( N9E_FILIAL ) + N9E->( N9E_CODROM ) == xFilial( "N9E" ) + NJJ->( NJJ_CODROM )

			aAux := {}
			aAdd(aAux, {'N9E_CODINE', N9E->N9E_CODINE })
			aAdd(aAux, {'N9E_FILIE',  N9E->N9E_FILIE  })
			aAdd(aAux, {'N9E_CODCTR', N9E->N9E_CODCTR })
			aAdd(aAux, {'N9E_ITEM'  , N9E->N9E_ITEM   })
			aAdd(aAux, {'N9E_SEQPRI', N9E->N9E_SEQPRI })
			aAdd(aAux, {'N9E_PEDIDO', N9E->N9E_PEDIDO })
			aAdd(aAux, {'N9E_ORIGEM', '2' })		

			aAdd( aFldN9E, aAux )

			N9E->( DbSkip() )					
		EndDo
	EndIf

return .T.

/** {Protheus.doc} OG710AtN7Q
Atualiza o registro de N7Q, alterando Status Faturamento da Instrução de Embarque

Função chamada a partir da Rotina OGX165Reabre - rotina que reabre o romaneio relacionado 
à nota que foi excluída ou não existe na base

@param: 	pcFilial - Filial do romaneio
@param: 	pcCodRom - Código do romaneio
@return:	Nil
@author: 	Tamyris Ganzenmueller
@since: 	28/02/2017
@Uso: 		SIGAAGR 
*/
Function OG710AtN7Q( pcFilial, pcCodRom )
	Local aAreaNJJ	:= GetArea( "NJJ" )

	dbSelectArea( 'NJJ' )
	NJJ->( DbSetOrder( 1 ) )
	If NJJ->( dbSeek( pcFilial + pcCodRom ) )

		dbSelectArea( 'N9E' )
		N9E->( dbSetOrder( 1 ) )
		N9E->( dbSeek( NJJ->(NJJ_FILIAL + NJJ_CODROM) ) ) 
		While ! N9E->( Eof() ) .And. N9E->( N9E_FILIAL + N9E_CODROM ) == NJJ->( NJJ_FILIAL + NJJ_CODROM ) 

			If N9E->N9E_ORIGEM $ '1,2' //Exportação
				dbSelectArea( 'N7Q' )
				N7Q->( dbSetOrder( 1 ) )
				If N7Q->( dbSeek( N9E->(N9E_FILIE + N9E_CODINE) ) ) 
					If RecLock( 'N7Q', .f. )	
						N7Q->N7Q_STAFAT := '2' //Incompleto 
					EndIf
				EndIf		
			EndIf

			dbSelectArea( 'N9E' )
			N9E->( dbSkip() )
		EndDo
	EndIf

	RestArea( aAreaNJJ )
	Return( Nil )

	/*/{Protheus.doc} retDocNjm()
	Retorna se a posição da NJM possui NF gerada para efetuar a devolução
	@type  Static Function
	@author rafael.kleestadt
	@since 02/03/2018
	@version 1.0
	@param cCodCtr, caractere, código do contrato da N7S sendo rolada
	@param cFilRom, caractere, código da filial da N7S sendo rolada
	@param cCodRom, caractere, código do romaneio posicionado na GrvModelo()
	@return lRet, Logical, se encontrar NF para o contrato que esta tentando gerar NJM de devolução no Romaneio de venda então gera a NJM de devolução
	@example
	(examples)
	@see http://tdn.totvs.com/pages/viewpage.action?pageId=338377171
	/*/
Static Function retDocNjm(cCodCtr, cFilRom, cCodRom)
	Local cAliasNJM := GetNextAlias()
	Local cQuery    := ""
	Local lRet      := .F.

	cQuery := " SELECT NJM_DOCNUM "
	cQuery += " FROM " + RetSqlName("NJM") + " NJM "
	cQuery += " WHERE NJM.NJM_CODCTR = '" + cCodCtr + "'"
	cQuery += "   AND NJM.NJM_FILIAL = '" + cFilRom + "'"
	cQuery += "   AND NJM.NJM_CODROM = '" + cCodRom + "'"
	cQuery += "   AND NJM.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasNJM, .F., .T.)
	If (cAliasNJM)->(!EoF())
		lRet := .T.
	EndIf
	(cAliasNJM)->(dbCloseArea())

	Return lRet


	/*/{Protheus.doc} NFPendSEF()
	Caso já exista romaneio com alguma NF pendente de retorno SEFAZ, não continuar e mostrar que mensagem de alerta
	@type  Static Function
	@author janaina.duarte
	@since 06/03/2018
	@version 1.0
	@param cFilIE, caractere, código da filial da instrução de embarque
	@param cCodIne, caractere, código da instrução de embarque
	@return lRet, Logical, se encontrar NF pendente SEFAZ então retorna TRUE
	/*/
Static Function NFPendSEF(cFilIE, cCodIne)
	Local cAliasN9E  := ""
	Local cQueryN9E  := ""
	Local cAliasNJM  := ""	
	Local lRet       := .F.
	Local cStaNfe    := ""

	cAliasN9E := GetNextAlias()
	cQueryN9E := " SELECT DISTINCT N9E_FILIAL, N9E_CODROM  "
	cQueryN9E += "     FROM " + RetSqlName("N9E") + " N9E "
	cQueryN9E += "    WHERE N9E.N9E_FILIE  = '" + cFilIE  + "'"
	cQueryN9E += "      AND N9E.N9E_CODINE = '" + cCodIne + "'"
	cQueryN9E += "      AND N9E.D_E_L_E_T_ = ' ' "
	cQueryN9E += "      AND N9E.N9E_ORIGEM = '1' "
	cQueryN9E := ChangeQuery(cQueryN9E)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryN9E),cAliasN9E, .F., .T.) 
	DbselectArea( cAliasN9E)
	DbGoTop()
	If (cAliasN9E)->( !Eof() )
		While (cAliasN9E)->(!EoF())
			DbSelectArea("NJJ")
			DbSetorder(1)//NJJ_FILIAL+NJJ_COROM		
			If NJJ->(DbSeek( (cAliasN9E)->N9E_FILIAL + (cAliasN9E)->N9E_CODROM ) ) 

				cAliasNJM := GetNextAlias()		
				cQryNJM := " SELECT DISTINCT NJM_FILIAL, NJM_PEDIDO "
				cQryNJM += " FROM " + RetSqlName("NJM") + " NJM "
				cQryNJM += " WHERE NJM.NJM_FILIAL = '" + NJJ->NJJ_FILIAL + "'"
				cQryNJM += "   AND NJM.NJM_CODROM = '" + NJJ->NJJ_CODROM + "'"
				cQryNJM += "   AND NJM.D_E_L_E_T_ = ' ' "
				cQryNJM := ChangeQuery(cQryNJM)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryNJM), cAliasNJM, .F., .T.)
				If (cAliasNJM)->(!EoF())
					While (cAliasNJM)->(!EoF())

						DbSelectArea( "SC5" )       
						DbSetOrder( 1 ) 
						//C5_FILIAL+C5_NUM       
						If SC5->(DbSeek( (cAliasNJM)->NJM_FILIAL + (cAliasNJM)->NJM_PEDIDO ))
							DbSelectArea( "SF2" )       
							DbSetOrder( 1 ) 
							//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO       
							If SF2->(DbSeek( xFilial( "SF2" ) + SC5->( C5_NOTA + C5_SERIE + C5_CLIENTE + C5_LOJACLI ) ))
								cStaNfe := SF2->( F2_FIMP )
								//"S" - NF Autorizada
								//" " - NF Não Transmitida
								//"T" - NF Transmitida
								//"N" - NF Não Autorizada
								//"D" - NF Uso Denegado

								if cStaNfe <> 'S'
									lRet := .T.
									Return lRet
								EndIf

							EndIf
							SF2->(DbCloseArea())
						EndIf
						SC5->(DbCloseArea())

						(cAliasNJM)->(dbSkip())
					End
				EndIf
				(cAliasNJM)->(dbCloseArea())
			EndIf
			(cAliasN9E)->(dbSkip())
		End	
	EndIf
	(cAliasN9E)->(DbCloseArea())

Return lRet

/*/{Protheus.doc} ValFarCnt
Valida se todos os contêineres da Ie estão estufados e se possui fardos sem contêiner e se a quantidade de contêineres vinculados é suficiente.
@type  Static Function
@author rafael.kleestadt
@since 07/03/2018
@version 2.0
@param cTip, caractere, '1'-Aprovar peso certificado, '2'-Gerar Nf de exportação
@return lRet, Logical, True or False
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=338377171
/*/
Static Function ValFarCnt(cTip)
	Local lRet      := .T.

	//todos os containers devem estar Certificados 
	DbSelectArea("N91")
	DbSetOrder(1)
	DbSeek(xFilial("N91")+N7Q->N7Q_CODINE)
	While !N91->(Eof()) .AND. xFilial("N91")+N7Q->N7Q_CODINE == N91->N91_FILIAL+N91->N91_CODINE
		If !(N91->N91_STATUS $ '56') .And. Empty(N91->N91_QTDANT) 
			If cTip == '1'
				Help(" ", 1, ".OGA710000003.") //##Problema: Não é possivel aprovar a IE com containers sem certificação. ##Solução:Certifique todas os containers antes da aprovação
			Else
				Help(" ", 1, ".OGA710000006.") //##Problema: Não é possível gerar nota fiscal de exportação para a IE com contêineres sem certificação. ##Solução:Certifique todos os contêineres antes de gerar NF exportação.
			EndIf
			Return .F.
		EndiF
		N91->(DbSkip())
	EndDo
	N91->(DbCloseArea())

	If !ValTipProd() //Se o Produto for algodão
		//todos os fardos da IE devem estar vinculados a um container
		DbSelectArea("DXI")
		DbSetOrder(8)
		DbSeek(xFilial("DXI")+N7Q->N7Q_CODINE)
		While !DXI->(Eof()) .AND. xFilial("DXI")+N7Q->N7Q_CODINE == DXI->DXI_FILIAL+DXI->DXI_CODINE
			If empty(DXI->DXI_CONTNR) 
				If cTip == '1'
					Help(" ", 1, ".OGA710000004.") //##Problema: Não é possivel aprovar a IE com fardos sem vinculos com containers. ##Solução:Vincule todos os fardos da IE e aprove a IE novamente
					Return .F.
				Else
					DbSelectArea("N9D")
					DbSetOrder(5)//N9D_FILIAL+N9D_SAFRA+N9D_FARDO+N9D_TIPMOV+N9D_STATUS
					If !N9D->(DbSeek(DXI->DXI_FILIAL + DXI->DXI_SAFRA + DXI->DXI_ETIQ + '05' + '2'))
						Help(" ", 1, ".OGA710000007.") //##Problema: Não é possível gerar nota fiscal de exportação para a IE com fardos sem vínculos com contêineres. ##Solução:Vincule todos os fardos da IE antes de gerar NF exportação.	
						Return .F.
					EndIf
					N9D->(DbCloseArea())
				EndIf
			EndIf

			DXI->(DbSkip())
		EndDo
		DXI->(DbCloseArea())
	EndIf

Return lRet


/** {Protheus.doc} MovFardo
Função que registra a movimentação do fardos(N9D) ao vincular/desvincular o fardo na IE

@param: 	lInclui - .T. para incluir o movimento e .F. para excluir o movimento
@author: 	Equipe Agroindustria
@since:     26/07/2017
@author: 	Felipe.mendes
@Uso: 		OGA710 - Instrução de Embarque - Mercado Externo
*/
Function MovFardo(lInclui,cCodine)	
	Local aAltera   := {} //Campos que serão alterados	
	Local dPesoF
	Local dPesoI

	If lInclui //Na criação do vinculo do fardos com IE, criar o registro na N9D

		IF DXI->DXI_PESCER > 0 
			dPesoF := DXI->DXI_PESCER 
		ElseIf DXI->DXI_PESSAI > 0
			dPesoF := DXI->DXI_PESSAI
		Else   
			dPesoF := DXI->DXI_PSLIQU
		EndIF   

		dPesoI := IIF( DXI->DXI_PSESTO > 0 , DXI->DXI_PSESTO , DXI->DXI_PSLIQU )

		aAltera := {{	{"N9D_FILIAL" ,DXI->DXI_FILIAL	},;
		{"N9D_SAFRA" ,DXI->DXI_SAFRA	},;
		{"N9D_FARDO" ,DXI->DXI_ETIQ 	},;
		{"N9D_TIPMOV" ,"04"		      	},;
		{"N9D_FILORG" ,FWXfilial("N7Q") },;
		{"N9D_CODINE" ,cCodine        	},;
		{"N9D_DATA"   ,dDatabase      	},;
		{"N9D_STATUS" ,"2"            	},;
		{"N9D_PESINI" ,dPesoI   	  	},; //Peso dos fardos será alterado no rateio
		{"N9D_PESFIM" ,dPesoF 	      	},;
		{"N9D_PESDIF" ,dPesoF - dPesoI	}	}}


		aRet    := AGRMOVFARD(aAltera, 1 )	           //Inclui movimentação para o fardo

	Else
		//Caso o fardo possua uma movimentação de Romaneio, a movimentação da IE deve ser Inativada.
		DbSelectArea("N9D")
		DbSetOrder(5)
		If DbSeek(DXI->DXI_FILIAL+DXI->DXI_SAFRA+DXI->DXI_ETIQ+"07") //Verifica se existe movimentação de Romaneio

			aAltera := { { {"N9D_STATUS" ,"3"    } } }
			aRet    :=  AGRMOVFARD(aAltera, 2 , 5 , {{DXI->DXI_FILIAL},{DXI->DXI_SAFRA},{DXI->DXI_ETIQ},{"04"}} )	           //Inclui movimentação para o fardo

		Else //Caso não possuia  movimentação de Romaneio, Excluir o registro
			aRet    :=  AGRMOVFARD(       , 3 , 5 , {{DXI->DXI_FILIAL},{DXI->DXI_SAFRA},{DXI->DXI_ETIQ},{"04"}} )
		EndIf 

	EndIf

Return 

/*/{Protheus.doc} RolMovFardo
//TODO Função que realiza a rolagem da movimentação do fardo
@author Felipe.mendes
@since 26/07/2017
@version 1.0

@type function
/*/
Function RolMovFardo()
	Local aAltera   := {} //Campos que serão alterados	
	Local nCertif := 0 //0=nao tem certificação, 1=tem certificação, e 2=tem certifição fisica

	//Inativa a movimentação do fardo referente a IE de origem da rolagem
	aAltera := { { {"N9D_STATUS" ,"3"    } } }
	//inativa o movimeto tipo 04-instrução de embarque da IE de origem da rolagem 
	aRet    :=  AGRMOVFARD(aAltera, 2 , 5 , {{DXI->DXI_FILIAL},{DXI->DXI_SAFRA},{DXI->DXI_ETIQ},{"04"}} ) 
	//Preparação do array para criar nova movimentação para a IE de rolagem
	// neste ponto ja foi salvo o codigo da IE de rolagem na DXI
	aAltera := {{	{"N9D_FILIAL", DXI->DXI_FILIAL 	},;
	{"N9D_SAFRA" , DXI->DXI_SAFRA  	},;
	{"N9D_FARDO" , DXI->DXI_ETIQ  	},;
	{"N9D_TIPMOV" ,"04"		      	},;
	{"N9D_CODINE" ,DXI->DXI_CODINE	},;
	{"N9D_FILORG", FwxFilial("N7Q") 	},;
	{"N9D_DATA"   ,dDatabase      	},;
	{"N9D_STATUS" ,"2"            	} 	}}
	aRet    := AGRMOVFARD(aAltera, 1  )	           //Inclui movimentação para o fardo
	
	//verifica se fardo tem movimento 05=certificação 
	DbSelectArea("N9D")
	N9D->(DbSetOrder(5))
	If N9D->(DbSeek(DXI->DXI_FILIAL + DXI->DXI_SAFRA + DXI->DXI_ETIQ + '05' + '2'))
		nCertif := 1
		While !N9D->(Eof()) .AND. N9D->N9D_FILIAL + N9D->N9D_SAFRA + N9D->N9D_FARDO + N9D->N9D_TIPMOV + N9D_STATUS == ;
		  DXI->DXI_FILIAL + DXI->DXI_SAFRA + DXI->DXI_ETIQ + '05' + '2' 
		  	If AllTrim(N9D->N9D_TIPOPE) == '1'  //1-estufagem Física
		  		nCertif := 2
		  	EndIf 
		  	N9D->(DbSkip())
		EndDo
	EndIf
	If nCertif > 0
	 	//seta para inativar o registro da movimentação do fardo
		aAltera := { { {"N9D_STATUS" ,"3"    } } }
		//inativa o movimeto tipo 05-certificação do fardo 
		aRet := AGRMOVFARD(aAltera, 2 , 5 , {{DXI->DXI_FILIAL},{DXI->DXI_SAFRA},{DXI->DXI_ETIQ},{"05"}} )
		If nCertif = 2
			//se tem movimentação do tipo certificação FISICA do fardo
			//Preparação do array para criar nova movimentação para a IE de rolagem
			//neste ponto ja foi salvo o codigo da IE de rolagem na DXI
			aAltera := {{ {"N9D_FILIAL", DXI->DXI_FILIAL 	},;
			{"N9D_SAFRA" , DXI->DXI_SAFRA  	},;
			{"N9D_FARDO" , DXI->DXI_ETIQ  	},;
			{"N9D_TIPMOV" ,"05"		      	},;
			{"N9D_CODINE" ,DXI->DXI_CODINE	},;
			{"N9D_FILORG", FwxFilial("N7Q") 	},;
			{"N9D_DATA"   ,dDatabase      	},;
			{"N9D_TIPOPE"   ,'1'      	},;
			{"N9D_STATUS" ,"2"            	} 	}} 
			aRet := AGRMOVFARD(aAltera, 1  ) //Inclui movimentação para o fardo
		EndIf
	EndIf
		
Return .T.

/*/{Protheus.doc} OGA710APC()
//TODO mostra dialog para realizar a aprovação da ie com contratos sem assinatura
@type  Function
@author rafael.kleestadt
@since 19/03/2018
@version 1.0
@param nOrig, numeric, 1-browse, 2-view
@return lRet, logycal, true or false
/*/
Function OGA710APC(nOrig)	
	Local cMsgMemo := TamSX3("NK9_MSGMEM")
	Local lOK      := .F.
	Local oModel   := FwModelActive()
	Local aErro    := {}
	Local oModelN7Q := Nil
	Local cStaSss   := ""

	If nOrig == 1
		cStaSss := N7Q->N7Q_STSASS
	Else
		oModel    := FwModelActive()
		oModelN7Q := oModel:GetModel("N7QUNICO")
		cStaSss   := oModelN7Q:GetValue( "N7Q_STSASS" )
	EndIf

	if nOrig == 2   //Se chamada por dentro da tela 
		if !oModel:Activate() .Or. !oModel:VldData() 
			aErro := oModel:GetErrorMessage()
			MsgInfo( AllToChar(aErro[6]) + CRLF +;
			AllToChar(aErro[7]) + CRLF + CRLF +;
			STR0154 + AllToChar(aErro[2]) + CRLF +;
			STR0155 + AllToChar(aErro[9]))
			Return .F.
		EndIf
	EndIf

	If cStaSss $ '12'
		Help(" ", 1, ".OGA710000010.") //##Problema: "O Status da assinatura dos contratos da instrução de embarque já foi aprovado."
		Return .F.                     //##Solução: "Esta opção está disponível somente para instruções de embarque com status da assinatura dos contratos 3=Sem Assinatura."	
	EndIf

    IF !__lAutomato
		oDlg	:= TDialog():New(350,406,618,795,STR0150,,,,,CLR_BLACK,CLR_WHITE,,,.t.) //"Aprovar Contratos sem Assinatura"
		oDlg:lEscClose := .F.
	
		@ 038,008 SAY " " PIXEL
		@ 038,008 SAY STR0029 PIXEL	//"Observação:"
		@ 050,008 GET oMsg Var cMsgMemo OF oDlg Multiline Size 172,062 PIXEL 	
	
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| lOK := .T., oDlg:End() },{|| lOK := .F., oDlg:End() }) CENTERED
	Else 
	    lOK      := .T. 
	    cMsgMemo := "Automação" 
		nOrig    := 1
	ENDIF

	/*Botão OK - Atualiza as informações*/
	If lOK 

		If Vazio(cMsgMemo)
			cMsgMemo := STR0031 //"Aprovado"
		EndIf

		Begin Transaction
			OGA710Status(4, 3, cMsgMemo)
		End Transaction

		If nOrig == 2 //Se chamada por dentro da tela, grava a tela após aprovar 
			GrvModelo( oModel )
		EndIf
	Else
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} verAssIe
Função que percorre os contratos da IE e verifica o status da assinatura, se nem todos eles estivem NJR_STSASS="A" retorna .F.
@type  Static Function
@author rafael.kleestadt
@since 19/03/2018
@version 1.0
@param param, param_type, param_descr
@return lRet, logycal, se nem todos eles estivem NJR_STSASS="A" retorna .F.
@example
(examples)
@see (links_or_references)
/*/
Static Function verAssIe(oModOG710)
	Local oModelN7S := oModOG710:GetModel("N7SUNICO")
	Local nX        := 0
	Local lRet      := .F.

	For nX := 1 to oModelN7S:Length()
		oModelN7S:Goline( nX ) 

		If Posicione("NJR", 1, FwxFilial("NJR")+oModelN7S:GetValue("N7S_CODCTR"), "NJR_STSASS") == "F" .And. oModelN7S:GetValue("N7S_QTDVIN") > 0
			lRet := .T.
		Else
			lRet := .F.	
			EXIT
		EndIf

	Next nX

	Return lRet

	/*/{Protheus.doc} OGA710F4()
	Função para chamar a tela de consulta de Saldo do Produto
	@type  Static Function
	@author rafael.kleestadt
	@since 22/03/2018
	@version 1.0
	@param param, param_type, param_descr
	@return returno,return_type, return_description
	@example
	(examples)
	@see http://tdn.totvs.com/pages/viewpage.action?pageId=287072658
	/*/
Function OGA710F4()
	Local oModel    := Nil
	Local oModelN7Q := Nil
	Local cCodPro   := ""
	Local aOldArea  := GetArea()

	If Empty(FWModelActive())
		cCodPro := N7Q->N7Q_CODPRO
	Else
		oModel    := FwModelActive()
		oModelN7Q := oModel:GetModel("N7QUNICO")
		cCodPro   := oModelN7Q:GetValue( "N7Q_CODPRO" )
	EndIf

	OGAC120( cCodPro )

	RestArea(aOldArea)

	Return .T.


	/*/{Protheus.doc} CriaMovFard()
	Função para criar mov fardos na criação automatica do romaneio
	@type  Static Function
	@author felipe.mendes
	@since 04/04/2018
	@version 1.0
	/*/
Static Function CriaMovFard(cCodRom,cCodIne,cFilOrg)
	Local aArea  := GetArea()
	Local dPesoI := 0
	Local dPesoF := 0
	Local aFardos := {}

	DbSelectArea("NJJ")
	NJJ->(DbSetOrder(1))
	NJJ->(DbSeek(xFilial("NJJ")+cCodRom))

	DbSelectArea("N9D")
	N9D->(DbSetOrder(5))
	N9D->(DbSeek(DXI->DXI_FILIAL+DXI->DXI_SAFRA+DXI->DXI_ETIQ+'022')) 
	//POSICIONA NO MOVIMENTO DE TAKE-UP PARA PEGAR CONTRATO, ITEM ENTREGA E ITEM REGRA FISCAL

	//Usar o peso certificado, ou peso saida ou peso liquido
	IF DXI->DXI_PESCER > 0 
		dPesoF := DXI->DXI_PESCER 
	ElseIf DXI->DXI_PESSAI > 0
		dPesoF := DXI->DXI_PESSAI
	Else   
		dPesoF := DXI->DXI_PSLIQU
	EndIF   

	dPesoI := IIF( DXI->DXI_PSESTO > 0 , DXI->DXI_PSESTO , DXI->DXI_PSLIQU )	

	aFardos:= 	{ { {"N9D_TIPMOV"	,"07"					 },;
	{"N9D_FILIAL"   ,DXI->DXI_FILIAL		 },;
	{"N9D_SAFRA"    ,DXI->DXI_SAFRA 		 },;
	{"N9D_FARDO"    ,DXI->DXI_ETIQ  		 },;
	{"N9D_PESINI"	,dPesoI   				 },; //Peso dos fardos será alterado no rateio
	{"N9D_PESFIM"	,dPesoF 	    		 },;
	{"N9D_PESDIF"	,dPesoF - dPesoI 		 },;
	{"N9D_DATA"		,dDatabase 				 },;
	{"N9D_STATUS"	,"2"                 	 },;
	{"N9D_CODROM"	,cCodRom        		 },;
	{"N9D_CODINE"   ,cCodIne        		 },;
	{"N9D_FILORG"	,cFilOrg         		 },;
	{"N9D_LOCAL"	,IIF( !Empty(NJJ->NJJ_LOCAL) , NJJ->NJJ_LOCAL , POSICIONE("SB1",1,xFilial("SB1")+NJJ->NJJ_LOCAL, "B1_LOCPAD" ) ) 		 },;
	{"N9D_TIPOPE"	,POSICIONE("NJM" , 1 , xFilial("NJM") + NJJ->NJJ_CODROM , "NJM_SUBTIP" )  		 },; 
	{"N9D_ENTLOC"	,NJJ->NJJ_CODENT		 },;
	{"N9D_LOJLOC"	,NJJ->NJJ_LOJENT		 },;
	{"N9D_CONTNR"	,DXI->DXI_CONTNR		 },;
	{"N9D_CODFAR"	,DXI->DXI_CODIGO		 },;
	{"N9D_CODCTR"	,N9D->N9D_CODCTR		 },;
	{"N9D_ITEETG"	,N9D->N9D_ITEETG		 },;
	{"N9D_ITEREF"	,N9D->N9D_ITEREF		 },;
	{"N9D_BLOCO"	,DXI->DXI_BLOCO			 } }	}

	aRet := AGRMOVFARD(aFardos, 1)

	RestArea(aArea)

Return .T.

/** {Protheus.doc}
Mostra embarque de exportação vinculados à IE
@param:  Nil
@author: vitor.barba
@since:  04/18
@Uso:    SIGAAGR
*/
Function XEECAE100C(oModel)
	Local cQueryN82 := ''
	Local cAliasN82 := GetNextAlias()
	Local cFiltro   := ''

	If ValTpMerc(.F.) = "1"
		Help(" ", 1, "OGA710TIPMERC") //##Problema: Função não disponível para mercado interno. ##Solução: Esta função é especifica para mercado externo.
		Return .T.
	EndIf

	// Seleciona pedidos de exportação vinculados à IE
	cQueryN82 := "   SELECT N82_FILORI, N82_PEDIDO "
	cQueryN82 += "     FROM " + RetSqlName('N82') + " N82 "
	cQueryN82 += "    WHERE N82.N82_FILIAL = '" + N7Q->N7Q_FILIAL + "'"
	cQueryN82 += "      AND N82.N82_CODINE = '" + N7Q->N7Q_CODINE + "'"
	cQueryN82 += "      AND N82.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryN82), cAliasN82, .F., .T.)
	If (cAliasN82)->(!EoF())
		While (cAliasN82)->(!EoF())

			If !Empty(cFiltro)
				cFiltro += " .Or. "
			EndIF

			cFiltro += " ( EEC_FILIAL = '" + (cAliasN82)->N82_FILORI + "' .AND. EEC_PREEMB = '"  + (cAliasN82)->N82_PEDIDO + "' )"

			(cAliasN82)->(dbSkip())
		End
	Else
		Help(" ", 1, "OGA710SEMPDEXP") //"Está Instrução de Embarque não possui pedidos de exportação relacionados."
		Return(.T.)         
	EndIf
	(cAliasN82)->(dbCloseArea())

	If !__lAutomato
		nModulo := 29 //Módulo Exportação    
		//Teste para o embarque de exportação:
		//Aplica o filtro na tabela EEC:
		EEC->(DbSetFilter({|| cFiltro }, cFiltro))
		//Executa a manutenção do embarque:
		EECAE100()
	
		nModulo := 67 //Módulo Agroindustria
     EndIF
     
Return .T.

/*{Protheus.doc} OGA710NREM
//Função que abre a tela de Painel de Saldos de Nota de Remessa
@author tamyris.g
@since 02/05/2018
@version 1.0
@type function
*/
Function OGA710NREM(cCodIne)

	Local cFilter := "N9I_INDSLD <> '3'"

	dbSelectArea( "N7Q" ) 
	N7Q->(dbSetOrder(1)) //N7Q_FILIAL+N7Q_CODINE
	If N7Q->(dbSeek( xFilial( "N7Q" ) + cCodIne) ) 
		If N7Q_TPCTR == "2" //ARMAZENAGEM
			cFilter += " .And. N9I_CODINR='"+cCodIne+"' " 
		Else 
			cFilter += " .And. N9I_CODINE='"+cCodIne+"' " 
		EndIf	
	EndIf	

	OGC130(cFilter)

Return .T.

/*/{Protheus.doc} OGA710Copia
Substitui a chamada padrão da função de cópia para validação
@type  Function
@author rafael.kleestadt
@since 03/05/2018
@version 1.0
@param param, param_type, param_descr
@return xRet, object, execução do programa
@example
(examples)
@see (links_or_references)
/*/
Function OGA710Copia()
	Local xRet 
	
	//Função válida somente para IE do tipo Externa
	If ValTpMerc(.F.) = "1" 
		Help(" ", 1, "OGA710TIPMERC") //##Problema: Função não disponível para mercado interno. ##Solução: Esta função é especifica para mercado externo.
		Return .T.
	EndIf

	//Caso já exista romaneio com alguma NF pendente de retorno SEFAZ, não continuar e mostrar que mensagem de alerta
	IF NFPendSEF(N7Q->N7Q_FILIAL, N7Q->N7Q_CODINE)    
		Help(" ", 1, ".OGA710000011.") //##Problema: "Existe(m) Romaneio(s) de Exportação cuja(s) Nota(s) Fiscal(is) está(ão) pendente(s) de retorno da SEFAZ."
		Return .F.                      //##Solução: "Efetuar o envio da(s) Nota(s) Fiscal(is) de Exportação para a SEFAZ para efetuar a rolagem." 
	Else
		If N7Q->N7Q_TPCTR == "1"
			xRet := FWExecView( STR0050, "OGA710", 9) //"Rolagem Parcial"
		Else
			MsgInfo(STR0184, STR0015) //"Não é possível realizar rolagem para Instrução do tipo Armazenagem" ### "Atenção" 
			Return .F.
		EndIf
	EndIF

	Return xRet

	/*/{Protheus.doc}  ValSalVinc()
	Se para a filial selecionada, tiver nota de remessa da filial com saldo sem vincular a container, dar mensagem de validação e não deixar continuar.
	@type  Static Function
	@author rafael.kleestadt
	@since 11/05/2018
	@version 1.0
	@param oBrwMrk, object, objeto do browse com as filiais selecinada para geração de NF
	@return lRet, logical, True or False
	@example
	(examples)
	@see http://tdn.totvs.com/pages/viewpage.action?pageId=354471558
	/*/
Static Function  ValSalVinc(oBrwMrk)
	Local lRet  := .T.
	Local cFils := ""

	If ValTipProd()  // Só faz essa consistencia se não for ALGODAO

		//Posiciona no topo da lista	
		N82->(dbGoTop())
		N82->(dbSetorder(1)) //N82_FILIAL+N82_CODINE
		N82->(dbSeek( N7Q->N7Q_FILIAL + N7Q->N7Q_CODINE) )
		While N82->( !Eof() .And. N82->N82_FILIAL==N7Q->N7Q_FILIAL .And. N82->N82_CODINE==N7Q->N7Q_CODINE   )

			//Verifica se a filail possui saldo sem vincular a container
			If oBrwMrk:IsMark()
				cQuery := " SELECT DISTINCT N9I.N9I_FILIAL "
				cQuery += "            FROM " + RetSqlName('N9I') + " N9I "
				cQuery += "           WHERE N9I.N9I_FILIAL = '" + N82->N82_FILORI + "' "
				cQuery += "             AND N9I.N9I_FILORG = '" + N82->N82_FILIAL + "' "
				cQuery += "             AND N9I.N9I_CODINE = '" + N7Q->N7Q_CODINE + "' "
				cQuery += "             AND N9I.N9I_INDSLD = '1' "
				cQuery += "             AND N9I.N9I_QTDFIS > N9I.N9I_QTDANT " //E não tem estufagem antecipada
				cQuery += "             AND N9I.D_E_L_E_T_ = ' ' "	
				cAliasN9I := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN9I, .F., .T.)

				If .Not. (cAliasN9I)->(Eof())
					If Empty(cFils)
						cFils := (cAliasN9I)->(N9I_FILIAL)
					Else
						cFils += ", " + (cAliasN9I)->(N9I_FILIAL)
					EndIf

					lRet := .F.
				EndIf
				(cAliasN9I)->(dbCloseArea())
			Endif

			N82->(dbSkip())
		EndDo
	EndIf	

	If .Not. lRet

		cMsg := STR0164 + _CRLF + _CRLF //"A(s) seguinte(s) filial(is) possue(em) saldo de remessa sem vincular a container:"
		cMsg += cFils
		Help( , , STR0162, , cMsg, 1, 0 )

	EndIf

	Return lRet

	/*/{Protheus.doc}  ValSalDAC()
	Se para a filial selecionada, tiver nota de remessa da filial com saldo sem retorno da SEFAZ, dar mensagem de validação e não deixar continuar.
	@type  Static Function
	@author rafael.kleestadt
	@since 11/05/2018
	@version 1.0
	@param oBrwMrk, object, objeto do browse com as filiais selecinada para geração de NF
	@return lRet, logical, True or False
	@example
	(examples)
	@see http://tdn.totvs.com/pages/viewpage.action?pageId=354471558
	/*/
Static Function  ValSalDAC(oBrwMrk)
	Local lRet  := .T.
	Local cFils := ""

	//Posiciona no topo da lista	
	N82->(dbGoTop())
	N82->(dbSetorder(1)) //N82_FILIAL+N82_CODINE
	N82->(dbSeek( N7Q->N7Q_FILIAL + N7Q->N7Q_CODINE) )
	While N82->( !Eof() .And. N82->N82_FILIAL==N7Q->N7Q_FILIAL .And. N82->N82_CODINE==N7Q->N7Q_CODINE   )

		//Verifica se a filail possui saldo sem vincular a container
		If oBrwMrk:IsMark()
			cQuery := " SELECT DISTINCT N9I.N9I_FILIAL "
			cQuery += "            FROM " + RetSqlName('N9I') + " N9I "
			cQuery += "           WHERE N9I.N9I_FILIAL = '" + N82->N82_FILORI + "' "
			cQuery += "             AND N9I.N9I_FILORG = '" + N82->N82_FILIAL + "' "
			cQuery += "             AND N9I.N9I_CODINE = '" + N7Q->N7Q_CODINE + "' "
			cQuery += "             AND N9I.N9I_INDRET <> '1' "
			cQuery += "             AND N9I.N9I_DEPALF = '1' "
			cQuery += "             AND N9I.N9I_INDSLD <> '3' "
			cQuery += "             AND N9I.D_E_L_E_T_ = ' ' "	
			cAliasN9I := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN9I, .F., .T.)

			If .Not. (cAliasN9I)->(Eof())
				If Empty(cFils)
					cFils := (cAliasN9I)->(N9I_FILIAL)
				Else
					cFils += ", " + (cAliasN9I)->(N9I_FILIAL)
				EndIf

				lRet := .F.
			EndIf
			(cAliasN9I)->(dbCloseArea())
		Endif

		N82->(dbSkip())

	EndDo	

	If .Not. lRet

		cMsg := STR0165 + _CRLF + _CRLF //"A(s) seguinte(s) filial(is) possue(em) saldo de remessa sem retorno da SEFAZ:"
		cMsg += cFils
		Help( , , STR0162, , cMsg, 1, 0 )

	EndIf

	Return lRet

	/*/{Protheus.doc}  ValSalDAC()
	Se para a filial selecionada, existe(m) nota(s) de retorno de formação de lote sem autorização da SEFAZ, mostra validação e não deixa continuar.
	@type  Static Function
	@author rafael.kleestadt
	@since 18/05/2018
	@version 1.0
	@param oBrwMrk, object, objeto do browse com as filiais selecinada para geração de NF
	@return lRet, logical, True or False
	@example
	(examples)
	@see http://tdn.totvs.com/pages/viewpage.action?pageId=354471558
	/*/
Static Function  ValDACAut(oBrwMrk)
	Local lRet  := .T.
	Local cNfs  := ""

	//Posiciona no topo da lista	
	N82->(dbGoTop())
	N82->(dbSetorder(1)) //N82_FILIAL+N82_CODINE
	N82->(dbSeek( N7Q->N7Q_FILIAL + N7Q->N7Q_CODINE) )
	While N82->( !Eof() .And. N82->N82_FILIAL==N7Q->N7Q_FILIAL .And. N82->N82_CODINE==N7Q->N7Q_CODINE   )

		//Verifica se a filail possui saldo sem vincular a container
		If oBrwMrk:IsMark()
			cQuery := " SELECT N9I.N9I_FILIAL, N9I.N9I_DOC, N9I.N9I_SERIE, N9I.N9I_CLIFOR, N9I.N9I_LOJA, N9I.N9I_ITEDOC
			cQuery += "   FROM " + RetSqlName('N9I') + " N9I "
			cQuery += "  WHERE N9I.N9I_FILIAL = '" + N82->N82_FILORI + "' 
			cQuery += "    AND N9I.N9I_FILORG = '" + N82->N82_FILIAL + "' 
			cQuery += "    AND N9I.N9I_CODINE = '" + N7Q->N7Q_CODINE + "' 
			cQuery += "    AND N9I.N9I_INDRET = '1'
			cQuery += "    AND N9I.N9I_DEPALF = '1'  
			cQuery += "    AND N9I.D_E_L_E_T_ = ' ' 
			cAliasN9I := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN9I, .F., .T.)

			While .Not. (cAliasN9I)->(Eof())

				cQryN9E := "     SELECT DISTINCT NJM.NJM_FILIAL, NJM.NJM_DOCNUM, NJM.NJM_DOCSER "
				cQryN9E += "       FROM " + RetSqlName('N9E') + " N9E "
				cQryN9E += " INNER JOIN " + RetSqlName('NJM') + " NJM ON NJM.NJM_FILIAL = N9E.N9E_FILIAL AND NJM.NJM_CODROM = N9E.N9E_CODROM AND NJM.D_E_L_E_T_ = ' ' "
				cQryN9E += "      WHERE N9E.N9E_FILIAL = '" + (cAliasN9I)->(N9I_FILIAL) + "'
				cQryN9E += "        AND N9E.N9E_DOC    = '" + (cAliasN9I)->(N9I_DOC) + "'
				cQryN9E += " 	    AND N9E.N9E_SERIE  = '" + (cAliasN9I)->(N9I_SERIE) + "'
				cQryN9E += " 	    AND N9E.N9E_CLIFOR = '" + (cAliasN9I)->(N9I_CLIFOR) + "'
				cQryN9E += " 	    AND N9E.N9E_LOJA   = '" + (cAliasN9I)->(N9I_LOJA) + "'
				cQryN9E += " 	    AND N9E.N9E_ITEDOC = '" + (cAliasN9I)->(N9I_ITEDOC) + "'
				cQryN9E += " 	    AND N9E.N9E_ORIGEM = '7' "
				cQryN9E += " 	    AND N9E.N9E_FILIE  = '" + N7Q->N7Q_FILIAL + "'
				cQryN9E += " 	    AND N9E.N9E_CODINE = '" + N7Q->N7Q_CODINE + "'
				cQryN9E += " 	    AND N9E.D_E_L_E_T_ = ' ' "
				cAliasN9E := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryN9E), cAliasN9E, .F., .T.)

				If (cAliasN9E)->(!EoF())
					While (cAliasN9E)->(!EoF())

						DbSelectArea( "SF1" )       
						DbSetOrder( 1 ) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO       
						If SF1->(DbSeek( (cAliasN9E)->NJM_FILIAL + (cAliasN9E)->NJM_DOCNUM + (cAliasN9E)->NJM_DOCSER + (cAliasN9I)->N9I_CLIFOR + (cAliasN9I)->N9I_LOJA ))
							cStaNfe := SF1->( F1_FIMP )
							//"S" - NF Autorizada
							//" " - NF Não Transmitida
							//"T" - NF Transmitida
							//"N" - NF Não Autorizada
							//"D" - NF Uso Denegado

							if cStaNfe <> 'S'
								If Empty(cNfs)
									cNfs := AllTrim(RetTitle("F1_DOC")) + ": " + SF1->F1_DOC + " " + AllTrim(RetTitle("F1_SERIE")) + ": " + SF1->F1_SERIE
								Else
									cNfs += _CRLF + AllTrim(RetTitle("F1_DOC")) + ": " + SF1->F1_DOC + " " + AllTrim(RetTitle("F1_SERIE")) + ": " + SF1->F1_SERIE
								EndIf
								lRet := .F.
							EndIf

						EndIf
						SF1->(DbCloseArea())

						(cAliasN9E)->(dbSkip())
					End
				EndIf
				(cAliasN9E)->(dbCloseArea())

				(cAliasN9I)->(dbSkip())
			EndDo
			(cAliasN9I)->(dbCloseArea())
		Endif

		N82->(dbSkip())

	EndDo	

	If .Not. lRet

		cMsg := STR0167 + ":" + _CRLF + _CRLF //"Existe(m) nota(s) de retorno de formação de lote sem autorização da SEFAZ:"
		cMsg += cNfs
		Help( , , STR0162, , cMsg, 1, 0 )

	EndIf

Return lRet

/*/{Protheus.doc} CancelRoms
Função para cancelar oss romaneios que tiveram suas filiais roladas totalmente
@type  Static Function
@author rafael.kleestadt
@since 24/05/2018
@version 1.0
@param cIeOri, caractere, N7Q_CODINE da Ie de origem
@param cIeDes, caractere, N7Q_CODINE da Ie de destino
@return lRet, logical, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function CancelRoms(cIeOri, cIeDes)
	Local aValores := {}
	Local cQryDes  := ""
	Local cQryOri  := ""
	Local cQryRom  := ""
	Local lRet     := .T.

	//Busca todas as filiais da IE destino
	cQryDes := " SELECT DISTINCT N7S.N7S_FILORG "
	cQryDes += "   FROM " + RetSqlName('N7S') + " N7S "
	cQryDes += "  WHERE N7S.N7S_CODINE = '" + cIeDes + "' "
	cQryDes += "    AND N7S.D_E_L_E_T_ = ' ' "
	cAliasDes := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryDes), cAliasDes, .F., .T.)
	If (cAliasDes)->(!EoF())
		While (cAliasDes)->(!EoF())

			//Busca todas as quantidades que sobraram na IE origem com base nas filiais da IE destino
			cQryOri := " SELECT SUM(N7S.N7S_QTDVIN) AS SOBRA"
			cQryOri += "   FROM " + RetSqlName('N7S') + " N7S "
			cQryOri += "  WHERE N7S.N7S_CODINE = '" + cIeOri + "' "
			cQryOri += "    AND N7S.N7S_FILORG = '" + (cAliasDes)->N7S_FILORG + "' "
			cQryOri += "    AND N7S.D_E_L_E_T_ = ' ' "
			cAliasOri := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryOri), cAliasOri, .F., .T.)
			If (cAliasOri)->(!EoF())

				If (cAliasOri)->SOBRA <= 0 //Se foi rolado totalmente a quantidade da filial

					//Busca se para filial rolada total tem romaneio com status diferente de confirmado
					cQryRom := "     SELECT N9E.N9E_CODROM, N9E.N9E_FILIAL "
					cQryRom += "       FROM " + RetSqlName('N9E') + " N9E "
					cQryRom += " INNER JOIN " + RetSqlName('NJJ') + " NJJ "
					cQryRom += "         ON NJJ.NJJ_FILIAL = N9E.N9E_FILIAL " 
					cQryRom += "        AND NJJ.NJJ_CODROM = N9E.N9E_CODROM "
					cQryRom += "        AND NJJ.D_E_L_E_T_ = ' ' "
					cQryRom += "      WHERE N9E.N9E_CODINE = '" + cIeOri + "' "
					cQryRom += "        AND N9E.N9E_FILIAL = '" + (cAliasDes)->N7S_FILORG + "' "
					cQryRom += "        AND N9E.D_E_L_E_T_ = ' ' "
					cQryRom += "        AND NJJ.NJJ_STATUS IN ('0','1','2','5','6') "
					cQryRom += "        AND NJJ.NJJ_TIPO = '4' "
					cAliasRom := GetNextAlias()
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryRom), cAliasRom, .F., .T.)
					If (cAliasRom)->(!EoF())
						DbSelectArea("NJJ")
						DbSetorder(1)//NJJ_FILIAL+NJJ_COROM		
						If NJJ->(DbSeek( (cAliasRom)->N9E_FILIAL + (cAliasRom)->N9E_CODROM ) )
							aAdd(aValores, "NJJ" )
							aAdd(aValores, (NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM) )
							aAdd(aValores, "C"  )  //Tipo = Cancelar
							aAdd(aValores, STR0168 ) //"Cancelamento por rolagem parcial"
							lRet := OGA250CAN( Alias(), Recno(), 4 , aValores)
						EndIf
						NJJ->(DbCloseArea())
					EndIf
					(cAliasRom)->(DbCloseArea())

				EndIf

			EndIf
			(cAliasOri)->(DbCloseArea())

			(cAliasDes)->(dbSkip())
		EndDo
	EndIf
	(cAliasDes)->(DbCloseArea())

Return lRet


/*/{Protheus.doc} OGA710VALID
Função que valida percentual de pegajosidade
@author thiago.rover
@since 08/06/2018
@version undefined

@type function
/*/
Static Function OGA710VALID()
	Local cGrp := Posicione("SB1", 1, xFilial("SB1")+N7Q->N7Q_CODPRO,"B1_GRUPO" )	
	Local nSemResult  := 0
	Local cAliasN99 := GetNextAlias()	
	Local cQryN99   := ''
	Local aUsers := PswRet(1) //Recupera todos os dados do Usuário logado
	Local cCodUser := RetCodUsr()
	Local cGrpUser := IIF( Len(aUsers[1][10]) > 0 , aUsers[1][10][1] , "" )
	
	cRetorno := ""
	
	cQryN99 := " Select N99_RESLAB "
	cQryN99 += "   FROM " + RetSqlName("N99") + " N99 "
	cQryN99 += " WHERE N99_CODPRO = '"+PadR('040',TamSx3('N99_CODPRO')[1])+"'"
	cQryN99 += "   AND (N99_CODUSU = '"+cCodUser+"' OR N99_GRPUSU = '"+cGrpUser+" ') "
	cQryN99 += "   AND (N99_COPROD= '"+ N7Q->N7Q_CODPRO +"' OR N99_GRPROD = '" +cGrp+ "') "  
	cQryN99 += "   AND D_E_L_E_T_ = ' ' "
	cQryN99 := ChangeQuery(cQryN99)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryN99), cAliasN99, .F., .T.)

	If (cAliasN99)->(!EoF())
		nSemResult := (cAliasN99)->N99_RESLAB
	EndIf
	(cAliasN99)->(DbCloseArea())
	
	DbSelectArea("N7S")
	DbSetorder(3)//NJJ_FILIAL+NJJ_COROM		
	If N7S->(DbSeek( xFilial("N7Q") + N7Q->N7Q_CODINE ) )

		//Busca se os fardos sem resultado
		cQuery := " Select COUNT(N9D_CODCTR) AS CODCTR2 From " + RetSqlName('N9D') + " N9D "
		cQuery += 	" Inner Join " + RetSqlName('N9O') + " N9O on  "
		cQuery += 		" (N9O.D_E_L_E_T_ = ' ' "
		cQuery += 			" And N9O.N9O_CODCTR = N9D.N9D_CODCTR)"
		cQuery += 				" Where N9D.N9D_CODINE = '" + N7Q->N7Q_CODINE + "'"
		cQuery += 					" And N9D.N9D_CODCTR = '" +N7S->N7S_CODCTR+ "'" 
		cQuery += 					" And N9D.D_E_L_E_T_ = ' ' "
		cQuery += 					" And N9D_TIPMOV = '04' "
		cQuery += 					" And N9D_STATUS = '2' "
		cQuery += 		" And Not EXISTS (Select 1 From " + RetSqlName('NPX') 
		cQuery += 							" Where NPX_FARDO = N9D.N9D_CODFAR "
		cQuery +=								" And NPX_CODTA = N9O_CODCON "
		cQuery +=								" And D_E_L_E_T_ = ' ' "
		cQuery +=								" And NPX_ATIVO = '1') "
		cAliasValid2 := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasValid2, .F., .T.)
		
		If Empty(nSemResult) .Or. nSemResult $ '2'
			If (cAliasValid2)->(!EoF()) .And. (cAliasValid2)->CODCTR2 > 0 
				cRetorno := STR0169 + N7S->N7S_CODCTR+ STR0170 + STR((cAliasValid2)->CODCTR2) +  STR0171//"Não foram encontrados analise definida no contrato: " //" em : " //" fardo(s)"
			EndIf
		EndIF
		(cAliasValid2)->(DbCloseArea())	
			
		//Busca se os fardos que estão dentro do limite de contaminantes
		cQuery := " Select COUNT(N9D_CODCTR) AS CODCTR From " + RetSqlName('N9D') + " N9D "
		cQuery += 	" Inner Join " + RetSqlName('N9O') + " N9O on "
		cQuery += 		"(N9O.D_E_L_E_T_ = ' ' "
		cQuery += 		" And N9O.N9O_CODCTR = N9D.N9D_CODCTR)"
		cQuery += 	" Inner Join " + RetSqlName('NPX') + " NPX on "
		cQuery += 		"(NPX.D_E_L_E_T_ = ' '"
		cQuery += 		" And NPX.NPX_FARDO  = N9D.N9D_CODFAR "
		cQuery += 		" And NPX.NPX_CODTA  = N9O.N9O_CODCON )"
		cQuery += " Where N9D_CODINE = '" + N7Q->N7Q_CODINE + "'"
		cQuery += 	" And N9D_CODCTR = '" + N7S->N7S_CODCTR + "'" 
		cQuery += 	" And N9D.D_E_L_E_T_ = ' ' "
		cQuery += 	" And N9D_TIPMOV = '04' "
		cQuery += 	" And N9D_STATUS = '2'" "
		cQuery += 	" And NPX_ATIVO  = '1' "
		cQuery += 	" And (NPX_RESNUM < N9O_FAIINI Or NPX_RESNUM > N9O_FAIFIM) "
		cAliasValid := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasValid, .F., .T.)

		If (cAliasValid)->(!EoF()) .and. (cAliasValid)->CODCTR > 0
			If Empty(cRetorno)
				cRetorno := AllTRIM(STR((cAliasValid)->CODCTR)) + STR0172
			else
				cRetorno += _CRLF + _CRLF + ALLTRIM(STR((cAliasValid)->CODCTR)) + STR0172
			Endif
		EndIf
		(cAliasValid)->(DbCloseArea())
		
	Endif
	
	N7S->(DbCloseArea())

Return cRetorno


/*/{Protheus.doc} RESCONTFRD
//TODO Consulta se fardo tem contaminante cadastrado, retornando um status para o fardos
@author claudineia.reinert
@since 22/06/2018
@version undefined
@param filial, , descricao
@param etiqueta, , descricao
@param safra, , descricao
@type function
/*/
Static Function RESCONTFRD( cFilFrd, cEtiqueta, cSafra )
	Local nRet := 0 //1-liberado,2-sem resultado,3-Resultado fora da faixa
	Local  cQuery := ""
	Local cAliasQry := GetNextAlias()

	cQuery := " SELECT N9D_CODFAR, N9O_CODCTR,N9O_FAIINI, N9O_FAIFIM, NPX_CODVA, NPX_RESNUM "
	cQuery += " FROM " + RetSqlName("N9D") + " N9D "
	cQuery += " LEFT OUTER JOIN " + RetSqlName("N9O") + " N9O ON N9O.D_E_L_E_T_ = ' ' AND N9O_FILIAL = '"+xFilial("N9O")+"' AND N9O_CODCTR = N9D_CODCTR "
	cQuery += " LEFT OUTER JOIN " + RetSqlName("NPX") + " NPX ON NPX.D_E_L_E_T_ = ' ' AND NPX_ETIQ = N9D_FARDO AND NPX_CODSAF = N9D_SAFRA AND NPX_CODTA = N9O_CODCON AND NPX_ATIVO = '1' "
	cQuery += " WHERE N9D.D_E_L_E_T_ = ' ' AND N9D_FILIAL = '"+ cFilFrd +"' AND N9D_FARDO = '"+ cEtiqueta +"' AND N9D_SAFRA = '"+ cSafra +"' "
	cQuery += " AND N9D_TIPMOV = '02' AND N9D_STATUS = '2' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.F.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->(!Eof())
		If Empty((cAliasQry)->N9O_CODCTR) .OR. ( !Empty((cAliasQry)->NPX_CODVA) .AND. (cAliasQry)->NPX_RESNUM >= (cAliasQry)->N9O_FAIINI .AND. (cAliasQry)->NPX_RESNUM <= (cAliasQry)->N9O_FAIFIM )
			//se não tem cadastro de limite de contaminante no contrato(N9O) ou se tem o cadastro e tem lançamento de contaminante(NPX) para o fardo com resultado dentro da faixa definida no contrato
			nRet := IIF(nRet > 1, nRet, 1) //1-liberado --> tratativa caso no contrato tiver mais de um contaminante, mantem pior resultado
		ElseIf Empty((cAliasQry)->NPX_CODVA)
			//não encontrou lançamento de contaminante(NPX) para o fardo e tem cadastro de limite de contaminante no contrato(N9O)
			nRet := IIF(nRet > 2, nRet, 2) //2-sem resultado --> tratativa caso no contrato tiver mais de um contaminante, mantem pior resultado
		Else
			nRet := 3 // 3-resultado fora da faixa definida no cadastro de contaminante no contrato(N9O)
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

Return nRet


/*/{Protheus.doc} OGA710LIMFAR
//TODO Descrição auto-gerada.
@author thiago.rover
@since 21/06/2018
@version undefined

@type function
/*/
Static Function OGA710LIMFAR()

	nMaximo := 0

	DbSelectArea("N7S")
	DbSetorder(3)//NJJ_FILIAL+NJJ_COROM		
	If N7S->(DbSeek( xFilial("N7Q") + N7Q->N7Q_CODINE ) )

		//Busca se os fardos que estão dentro do limite de contaminantes
		cQuery := " Select Max(NPX_RESNUM) AS MAXIMO, Min(NPX_RESNUM) AS MINIMO From " + RetSqlName('N9D') + " N9D "
		cQuery += "    Inner Join " + RetSqlName('N9O') + " N9O on N9O.D_E_L_E_T_ = ' ' and N9O_CODCTR = N9D_CODCTR "
		cQuery += "    Inner Join " + RetSqlName('NPX') + " NPX on NPX.D_E_L_E_T_ = ' ' and NPX_FARDO = N9D_CODFAR and NPX_CODTA = N9O_CODCON "
		cQuery += " Where N9D_CODINE = '" + N7Q->N7Q_CODINE + "'"
		cQuery += " and N9D_CODCTR = '" +N7S->N7S_CODCTR+ "' and N9D.D_E_L_E_T_ = ' ' and N9D_TIPMOV = '04' and N9D_STATUS = '2'"
		cQuery += " and NPX_ATIVO = '1' "
		cAliasValid := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasValid, .F., .T.)

		If (cAliasValid)->(!EoF())
			nMaximo :=  (cAliasValid)->MAXIMO
		EndIf
		(cAliasValid)->(DbCloseArea())

	Endif

	N7S->(DbCloseArea())

Return nMaximo


/*/{Protheus.doc} fTrgIncPer
//TODO Descrição auto-gerada.
@author janaina.duarte
@since 28/06/2018
@version undefined

@type function
/*/
Static Function fTrgIncPer(cCampo) 
	Local oModel	:= FwModelActive()
	Local oN7Q		:= oModel:GetModel( "N7QUNICO" )
	Local cRetorno	:= ""

	If cCampo == "N7Q_PERMIN"
		cRetorno := oN7Q:GetValue("N7Q_LIMMIN") - (oN7Q:GetValue("N7Q_LIMMIN") * oN7Q:GetValue("N7Q_PERMIN") / 100)
	Else 
		cRetorno := oN7Q:GetValue("N7Q_LIMMAX") - (oN7Q:GetValue("N7Q_LIMMAX") * oN7Q:GetValue("N7Q_PERMAX") / 100)
	EndIf
Return cRetorno


/*/{Protheus.doc} VldPergRom
//TODO Valida se mostra pergunta ao usuario deseja desmarcar fardos em romaneio quando desmarca fardos na IE
@author claudineia.reinert
@since 15/08/2018
@version undefined
@param cAliGrd, characters, alias da grid selecionada
@param nBrowser, numeric, numero do browser que esta sofrendo alteração
@type function
/*/
Static Function VldPgDmRom( cAliGrd ,nBrowse )
	Local oModel    := FwModelActive()	
	Local lMFrdRom  := .T. //manter marcado fardos em romaneio
	Local cTipMerc  := M->N7Q_TPMERC //tipo do mercado
	Local cChaveVal := ''
	Local cChaveTbl := ''
	
	If nBrowse = 3 //grid fardos
	
		(cAliGrd)->(dbGoTop())
		While !(cAliGrd)->(Eof())					
			If !oModel:isCopy()  .AND. !Empty((cAliGrd)->(OK)) .AND. (cAliGrd)->(STATUS) $ '100|110|120|170' .AND. !Empty((cAliGrd)->(CODINE))
			   	//FARDO com status de algum processo do romaneio (expedição|em transito|remetido|faturado)
			
				If cTipMerc = '2' //2=MERCADO EXTERNO
				//se fardo esta em uma IE de exportação, FAZ PERGUNTA
				//##"Seleção possui fardos vinculados a romaneio. Deseja desmarcar inclusive os fardos vinculados a romaneio?" ##"Atenção"
					If MsgYesNo(STR0134, STR0015)
						lMFrdRom := .F. /* Desmarcar inclusive os fardos vinculados a romaneio*/ 
						//será tratado em outro ponto do fonte se realmente pode desmarcar todos
					EndIf								
				Else
					lMFrdRom := .T. /* Não será desmarcado */
					MsgAlert(STR0196 ,STR0015) //## Há fardos vinculado em romaneio, estes fardos não serão desmarcados! ##Atenção
				EndIf		
				EXIT
			EndIf

			(cAliGrd)->(DbSkip())
		EndDo	
	
	Else //grid filial/bloco
	
		//Criação de indices
		If nBrowse == 1
			cChaveVal := (cAliGrd)->FILORG
			cChaveTbl := "(cAliFrd)->FILORG"
		Else
			cChaveVal := (cAliGrd)->FILORG+(cAliGrd)->BLOCO
			cChaveTbl := "(cAliFrd)->FILORG+(cAliFrd)->BLOCO"
		EndIf	
	
		DbSelectArea(cAliFrd)
		(cAliFrd)->(dbSetorder(2))
		If (cAliFrd)->(dbSeek(cChaveVal))
			While (cAliFrd)->(!Eof()) .AND. cChaveVal == &(cChaveTbl)
				
				/* Se for desmarcar e o fardo esteja vinculado a um romaneio e não é rolagem parcial */
				If !oModel:isCopy() .AND. !Empty((cAliFrd)->(OK)) .AND. (cAliFrd)->(STATUS) $ '100|110|120|170' .AND. !Empty((cAliFrd)->(CODINE))
					
					If cTipMerc = '2' .AND. nBrowse != 4
						//##"Seleção possui fardos vinculados a romaneio. Deseja desmarcar inclusive os fardos vinculados a romaneio?" ##"Atenção"
						If MsgYesNo(STR0134, STR0015)
							lMFrdRom := .F. //Desmarcar inclusive os fardos vinculados a romaneio 
							//será tratado abaixo se realmente pode desmarcar o fardo
						EndIf
						Exit //para e sai do while
					EndIf
				EndIf
				(cAliFrd)->(dbSkip())
			EndDo
		EndIf
	EndIf

Return lMFrdRom

/*/{Protheus.doc} OG710SFC()
Atualizar o status dos fardo para 170 - faturado na aprovacao do container que tenham romaneio de venda confirmado
@type  Static Function
@author vanilda
@since 20/09/2018
@version 1.0
@param cFilOri, caractere, filial do romaneio
@param cCodine, char , codigo da instrução de embarque
@param cContnr, char , codigo do container instrução de embarque
@return True, logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function OG710SFC(cFilOri,cCodine,cContnr)
	Local aFrdSts := {}
	Local cAliasQry := GetNextAlias()
	
	cQuery := " SELECT N9D.N9D_CONTNR, N9D.N9D_FILIAL, N9D.N9D_SAFRA, N9D.N9D_FARDO "
	cQuery += " FROM " + RetSqlName('N9D') + " N9D "
	cQuery += " INNER JOIN " + RetSqlName('DXI') + " DXI ON DXI_FILIAL = N9D.N9D_FILIAL "
	cQuery += "    AND DXI.DXI_ETIQ = N9D.N9D_FARDO "
	cQuery += "    AND DXI_SAFRA = N9D.N9D_SAFRA   "
	cQuery += "    AND DXI_BLOCO = N9D.N9D_BLOCO   "
	cQuery += "    AND DXI_STATUS <>  '170'      "
	cQuery += "    AND DXI.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("N9D") + " N9D2 ON N9D2.D_E_L_E_T_ = ' ' "
	cQuery += "    AND N9D2.N9D_FILIAL = N9D.N9D_FILIAL AND N9D2.N9D_FARDO = N9D.N9D_FARDO "
	cQuery += "    AND N9D2.N9D_CODINE = N9D.N9D_CODINE AND N9D2.N9D_TIPMOV='07' AND N9D2.N9D_STATUS='2' "
	cQuery += " INNER JOIN " + RetSqlName('NJJ') + " NJJ ON NJJ.D_E_L_E_T_ = ' ' AND NJJ.NJJ_FILIAL = N9D2.N9D_FILORG "
	cQuery += "    AND NJJ_CODROM = N9D2.N9D_CODROM AND NJJ.NJJ_TIPO='4' AND NJJ.NJJ_STATUS='3' AND NJJ.NJJ_STAFIS='2' "
	cQuery += " WHERE N9D.N9D_CODINE = '" + cCodine + "' "  
	cQuery += "    AND N9D.N9D_FILORG = '" + cFilOri + "' " 
	cQuery += "    AND N9D.D_E_L_E_T_ = ' ' "
	cQuery += "    AND N9D.N9D_TIPMOV = '05' "
	cQuery += "    AND N9D.N9D_STATUS = '2' "
	cQuery += "    AND N9D.N9D_CONTNR = '" + cContnr + "' "
	cQuery += "   GROUP BY N9D.N9D_CONTNR, N9D.N9D_FILIAL, N9D.N9D_SAFRA, N9D.N9D_FARDO 

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	If (cAliasQry)->(!EoF())
		While (cAliasQry)->(!EoF())
			AADD(aFrdSts, { (cAliasQry)->N9D_FILIAL, (cAliasQry)->N9D_SAFRA, (cAliasQry)->N9D_FARDO })			

			(cAliasQry)->(dbSkip())
		End
	EndIf
	(cAliasQry)->(dbCloseArea())
	
	//incluir(1) status do fardo na DXI(DXI_STATUS)
	IF LEN(aFrdSts) > 0 
   	   AGRXFNSF( 1 , "RomaneioVnd", aFrdSts ) //romaneio venda	
   	EndIf

Return Nil

Function OGA710CPRC(cParFil,cParCodine)
	Local cCodPro := N7Q->N7Q_CODPRO
	Local cCliImp := N7Q->N7Q_IMPORT
	Local cLojImp := N7Q->N7Q_IMLOJA
	Local cTipCli := N7Q->N7Q_TIPCLI
	Local lContLt  := Posicione("SB1", 1, FwXFilial("SB1")+N7Q->N7Q_CODPRO, "B1_RASTRO") <> "N" .And. SuperGetMv('MV_RASTRO', , .F.) == 'S'
	Local lAlgodao := if(Posicione("SB5",1,xFilial("SB5")+ N7Q->N7Q_CODPRO,"B5_TPCOMMO")== '2',.T.,.F.)
	Local aCompPrc := {}
	Local nX := 0
		
	cAliasQry := GetNextAlias()
	cQry := " SELECT N7S.N7S_FILORG,  N7S.N7S_CODINE FROM " + RetSqlName("N7S") + " N7S "		
	cQry += " WHERE N7S.N7S_FILIAL = '" + cParFil + "' AND N7S.N7S_CODINE = '" + cParCodine + "' "
	cQry += "   AND N7S.D_E_L_E_T_ = ' ' "
	cQry += " GROUP BY N7S.N7S_FILORG, N7S.N7S_CODINE "

	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	If (cAliasQry)->(Eof())
		MsgAlert(STR0241, STR0015) //"A Instrução de Embarque não possui Itens para consulta"
		(cAliasQry)->(DbCloseArea())
		lRet := .F.
	Else
		While (cAliasQry)->(!Eof())	
			
			cFilOrg := (cAliasQry)->N7S_FILORG
			/*Dados do Contrato*/
			dbSelectArea("N7S")
			N7S->(dbSetOrder(3))
			N7S->(dbSeek(cParFil+cParCodine+cFilOrg))
		
			dbSelectArea("NJR")
			NJR->(dbSetOrder(1))
			If NJR->(dbSeek(xFilial("NJR")+N7S->N7S_CODCTR))
				cTES 	   := NJR->NJR_TESEST
				cMoeda     := NJR->NJR_MOEDA
				cUnidProd  := NJR->NJR_UM1PRO
				cUnidPrc   := NJR->NJR_UMPRC
				cTipMer    := NJR->NJR_TIPMER
				cDescMoe   := AllTrim(AGRMVMOEDA(cMoeda))
			EndIF
		 	cClient := ""
		 	cLojCli := ""
		 	
		 	DbSelectArea("NJ0")
			NJ0->(DbSetOrder(1))
			If NJ0->(DbSeek(xFilial("NJ0")+cCliImp+cLojImp))
				cClient := NJ0->NJ0_CODCLI
				cLojCli := NJ0->NJ0_LOJCLI
			EndIf
					
			If lAlgodao //se algodão	
				
				aItens := OGX008BGFR( 2, cFilOrg , cParCodine, '', .F., lContLt)
											
				For nX := 1 to Len(aItens)
					
					cTipoAlg   := aItens[nx][1] 
					nPesoLiq   := aItens[nx][6] //Un Medida Produto 
					nVlrUnita  := aItens[nx][3] //Un Medida Preço
					
					nVlrTotal  := nVlrUnita * nPesoLiq 
						 
					 //Vl Unitário deve estar na Unidade de Medida de Preço
					If cUnidProd <> cUnidPrc
						nQtUM := AGRX001(cUnidProd, cUnidPrc ,1, cCodPro)
						nVlrTotal := nVlrUnita * Round(nPesoLiq * nQtUM , 6)
					EndIF
					
					aAdd(aCompPrc, {cFilOrg, cTipoAlg, nVlrUnita , nPesoLiq, nVlrTotal  })
					
				Next nx  
			Else
				
				
				// A função OGX710QIGRAO ja retorna o preço na unidade de medida do produto, então enviar para EEC unidade de preço do produto
				aItClass := OGX710QIGRAO(cFilOrg, cParCodine, cClient, cLojCli, cTes, cTipCli )	
				
				For nX := 1 to Len(aItClass)
					
					nPesoLiq   := aItClass[nX,5] //Unidade: do Produto
					nVlrUnita  := aItClass[nX,6] //Unidade: do Produto; Moeda: R$ se MI e U$ se ME
						 
					//Valor deve estar na Moeda do Contrato
					If cTipMer == '1' .And. cMoeda <> 1 //Se MI e contrato U$
						nVlrUnita := xMoeda(nVlrUnita, 1 , cMoeda, dDataBase , 6) //Converter Preço para U$
					EndIF
					
					nVlrTotal := nVlrUnita * nPesoLiq //Na Moeda do Contrato
					
					//Vl Unitário deve estar na Unidade de Medida de Preço
					If cUnidProd <> cUnidPrc
						nQtUM	:= AGRX001(cUnidPrc, cUnidProd ,1, cCodPro)
						nVlrUnita := Round(nVlrUnita * nQtUM ,6)
					EndIF
					
					aAdd(aCompPrc, {cFilOrg, "", nVlrUnita , nPesoLiq, nVlrTotal  })
					
				Next nx  
				
			EndIF
					
			(cAliasQry)->(DbSkip())		
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf	
	
	If !__lAutomato
		MontTelaPrc(aCompPrc, cDescMoe, cUnidProd, cUnidPrc)
	EndIF	

Return .t.


/*/{Protheus.doc} MontTelaPrc
//Tela para consulta dos preços 
@author tamyris.g
@since 22/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function MontTelaPrc(aCompPrc, cDescMoe, cUnidProd, cUnidPrc)
	Local aArea     := GetArea()
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oSize     := Nil
	Local aButtons  := {}
	Local nOpcX     := 0
	Local aBrowseCol := {}
	
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4],STR0242,,,,,CLR_BLACK,CLR_WHITE,,, .t. )   
		
	// Instancia o layer
	oFwLayer := FWLayer():New()

	// Inicia o Layer
	oFwLayer:init( oDlg, .F. )

	// Cria as divisões horizontais
	oFwLayer:addLine('UP' , 100, .F.)
	oFwLayer:addCollumn('ALL', 100, .F., 'UP')
	
	//cria as janelas
	oFwLayer:addWindow('ALL', 'WndUp', STR0242 +  " - " + AllTrim(N7Q->N7Q_DESINE), 100, .F., .T.,, 'UP') //"Selecionar Unid. Negócio para cópia"

	// Recupera os Paineis das divisões do Layer
	oPnlUP  := oFwLayer:getWinPanel('ALL' , 'WndUp'  , 'UP')
	
	/**** ITENS / CONSULTA DE PREÇOS *****/
	oBrwPrc:=FWBrowse():New()
	
	aAdd(aBrowseCol, { AllTrim( RetTitle("DXI_FILIAL") ) , {||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwPrc:NAT,01], Nil)} , 'C' , PesqPict( "DXI", "DXI_FILIAL" ), 1 ,TamSX3("DXI_FILIAL")[1] ,TamSX3("DXI_FILIAL")[2] ,.F.})
	aAdd(aBrowseCol, { AllTrim( RetTitle("DXI_CLACOM") ) , {||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwPrc:NAT,02], Nil)} , 'C' , PesqPict( "DXI", "DXI_CLACOM" ), 1 ,TamSX3("DXI_CLACOM")[1] ,TamSX3("DXI_CLACOM")[2] ,.F.})
	aAdd(aBrowseCol, { STR0243 + " (" + AllTrim(cDescMoe) + "/" + AllTrim(cUnidPrc) +")", {||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwPrc:NAT,03], Nil)} , 'N' , "@E 9,999,999.999999", 1 , 15 , 6 ,.F.})
	aAdd(aBrowseCol, { STR0245 + " (" + AllTrim(cUnidProd) +")", {||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwPrc:NAT,04], Nil)} , 'N' , "@E 999,999,999.9999", 1 , 15 , 4 ,.F.})
	aAdd(aBrowseCol, { STR0244 + " (" + AllTrim(cDescMoe)  +")", {||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwPrc:NAT,05], Nil)} , 'N' , "@E 999,999,999.9999", 1 , 15 , 4 ,.F.})
	
	oBrwPrc:setcolumns( aBrowseCol )
	oBrwPrc:setdataArray()  	
	oBrwPrc:setArray(aCompPrc)	
	oBrwPrc:SetDescription(STR0242)	

	oBrwPrc:DisableReport()
	oBrwPrc:DisableConfig()
	oBrwPrc:DisableLocate()
	oBrwPrc:SetOwner(oPnlUP)
	oBrwPrc:lheaderclick :=.f.
	
	oBrwPrc:SetEditCell(.F. ) 		
	
	oBrwPrc:Activate()	
		
	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| nOpcX := 1, oDlg:End() },{|| nOpcX := 0, oDlg:End() },, @aButtons ) } )
	
	RestArea(aArea)
Return .T.

/*/{Protheus.doc} OG710GIERWS
//TODO Função para gravação da IE via REST-FLUIG, necessario no OGA710 para usar as variaveis staticas
@author claudineia.reinert
@since 21/02/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, objeto do modelo 
@param aN7S, array, array com as regras fiscais
@param aRestBlocos, array, array com os blocos
@type function
/*/
Function OG710GIERWS(oModel,aN7S, aRestBlocos)
	Local nX := 0	
	Local nOperation := oModel:GetOperation()
	
	Private aRestN7S := aN7S //variavel necessaria para o OGA710
	
	// Cria estutura dos níveis da tree (Tabela temporária)
	StaticCall( OGA710, CriaTmpTb )

	// Cria estrutura da grid "Filiais" e carrega os dados da mesma (Tabela temporária)
	StaticCall( OGA710, CriaStrFil )

	// Cria estrutura da grid "Blocos" e carrega os dados da mesma (Tabela temporária)
	StaticCall( OGA710, CriaStrBlc )

	// Cria estrutura da grid "Fardos" e carrega os dados da mesma (Tabela temporária)	
	StaticCall( OGA710, CriaStrFrd )
	
	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		DbSelectArea(cAliasBloc)	
		(cAliasBloc)->(DbSetorder(2))//T_CODINE,T_FILORG,T_BLOCO
		For nX := 1 To Len(aRestBlocos)
			//percorre o array de blocos e atualiza a tabela temporario de blocos para a IE
			(cAliasBloc)->(DbGoTop())
			If (cAliasBloc)->(dbSeek( PADR(cCodIERest,TamSx3('N83_CODINE')[1],' ')+PADR(aRestBlocos[nX][1],TamSx3('N83_FILORG')[1],' ')+PADR(aRestBlocos[nX][2],TamSx3('N83_BLOCO')[1],' ') ))
				While (cAliasBloc)->(!Eof()) .AND. Alltrim((cAliasBloc)->T_FILORG)+Alltrim((cAliasBloc)->T_BLOCO) == Alltrim(aRestBlocos[nX][1])+Alltrim(aRestBlocos[nX][2]) 
					If Alltrim((cAliasBloc)->T_CONTRATO)+Alltrim((cAliasBloc)->T_CADENCIA)+Alltrim((cAliasBloc)->T_ITEREF) == ;
					   Alltrim(aRestBlocos[nX][3])+Alltrim(aRestBlocos[nX][4])+Alltrim(aRestBlocos[nX][5])
					   //GRAVA OS DADOS DO REST BLOCOS NA TABELA TEMPORARIA
					   	RecLock(cAliasBloc, .F.)		
					   	(cAliasBloc)->T_FRDMAR 	 := aRestBlocos[nX][7]	
						(cAliasBloc)->T_QTFRDSEL := VAL(aRestBlocos[nX][6])  
						(cAliasBloc)->T_PSLIQSEL := VAL(aRestBlocos[nX][8])			
						(cAliasBloc)->T_PSBRUSEL := VAL(aRestBlocos[nX][9])				
						(cAliasBloc)->T_QTFRDDIS := (cAliasBloc)->T_QTDINI - (cAliasBloc)->T_QTFRDSEL	
						(cAliasBloc)->T_PSLIQDIS := (cAliasBloc)->T_PSLIQINI - (cAliasBloc)->T_PSLIQSEL
						(cAliasBloc)->T_PSBRUDIS := (cAliasBloc)->T_PSBRUINI - (cAliasBloc)->T_PSBRUSEL
						(cAliasBloc)->(MSUnlock())
						nIndTree++ //variavel static do oga710, necessaria para a gravação do modelo 
					EndIf
					(cAliasBloc)->(DbSkip())
				EndDo
			EndIf
			
		Next nX
		If Len(aRestBlocos) > 0 .And. nIndTree > 0 
		//tem blocos e foi atualizado a tabela temporaria para gravação dos blocos 
			/* Atualiza a grid de cadências - atualiza o modelo*/ 	
			AtualizCad() 
		
			/* Atualiza totais da ie - atualiza o modelo*/
			AtuTotsIe()
		EndIf
	ElseIf nOperation == MODEL_OPERATION_DELETE .and. Len(aRestBlocos) > 0
		nIndTree++ //para poder excluir os blocos 
	EndIf
	
	lRet := GrvModelo( @oModel ) //realiza a gravação dos dados da IE - INSERT/UPDATE/DELETE
	
	(cAliasBloc)->(DbCloseArea()) //fecha a area para recriar novamente e  não ocorreu problema na alteração ou nova inclusão
	
Return lRet

/*{Protheus.doc} DlbClickN7S
Acao de duplo cique na linha da grid da regra fiscal

@author  francisco.nunes
@since   27/02/2019
@version version 1.0
*/
Static Function DlbClickN7S(oGrid, cFieldName, nLineGrid, nLineModel)	
	Local cTMerc     := ""
	Local cTCtr      := ""
	Local cFilCtr    := ""
	Local cCodCtr    := ""
	Local cItPrev    := ""
	Local cRegFis    := ""
	Local cCodIE     := ""
	Local nPeso      := 0
	Local cCodPro    := ""
	Local cFilOrg    := ""
	Local cCodEnt    := ""
	Local cLojEnt    := ""
	Local oView      := FwViewActive()
	Local oModel     := FwModelActive()
	Local oModelN7S  := oModel:GetModel("N7SUNICO")
	Local oModelN7Q  := oModel:GetModel("N7QUNICO")	
	Local oModelNLN  := oModel:GetModel("NLNUNICO")
	Local nOperation := oModel:GetOperation()
	
	If cFieldName == "N7S_VINDCO" 
	
		cFilCtr := oModelN7S:GetValue("N7S_FILIAL")
	    cCodCtr := oModelN7S:GetValue("N7S_CODCTR")
		
		DbSelectArea("NJR")
		NJR->(DbSetOrder(1)) // NJR_FILIAL+NJR_CODCTR
		If NJR->(DbSeek(cFilCtr+cCodCtr))
			If NJR->NJR_TIPFIX == "2"
				Help( , , STR0026, , STR0261, 1, 0 ) // Vínculo do PEPRO é permitido apenas para contrato com tipo de preço fixo
				Return .T.
			EndIf
		EndIf		
		NJR->(DbCloseArea())
			
		cTMerc  := oModelN7Q:GetValue("N7Q_TPMERC")
		cTCtr   := oModelN7Q:GetValue("N7Q_TPCTR")
	    cCodEnt := oModelN7Q:GetValue("N7Q_ENTENT")
	    cLojEnt := oModelN7Q:GetValue("N7Q_LOJENT")
	    cCodPro := oModelN7Q:GetValue("N7Q_CODPRO")   
	    cCodIE  := oModelN7Q:GetValue("N7Q_CODINE")
	    
	    
	    cItPrev := oModelN7S:GetValue("N7S_ITEM")
	    cRegFis := oModelN7S:GetValue("N7S_SEQPRI")
	    cFilOrg := oModelN7S:GetValue("N7S_FILORG")	   
	    nPeso   := oModelN7S:GetValue("N7S_QTDVIN")
	    nPesRom := oModelN7S:GetValue("N7S_QTDREM")
	
		OGX810ADCO(cTMerc, cTCtr, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodIE, nPeso, cCodPro, cFilOrg, cCodEnt, cLojEnt, nOperation, oModel, , nPesRom)
		
		If oModelNLN:HasField("NLN_CODINE")
            oModelNLN:GoLine(1)		
            oView:Refresh("VIEW_NLN")
        EndIf	
	EndIf

Return .T. 

/*/{Protheus.doc} fWheEntEnt
Verifica se a instrução de embarque esta vinculada a algum romaneio com status maior que atualizado
@type  Static Function
@author rafael.kleestadt
@since 14/03/2019
@version 1.0
@param oModel, object, objeto do modelo de dados
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function fWheEntEnt(oModel)
	Local cQryRom   := ""
	Local cAliasRom := ""
	Local aArea     := GetArea()

	If !IsInCallStack("OGA530") .And. !oModel:IsCopy()
		
		DbSelectArea("N7S")
		N7S->(DbSetOrder(1))//N7S_FILIAL+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI
		If N7S->(DbSeek(xFilial("N7S")+N7Q->N7Q_CODINE))
			While N7S->(!EOF()) .And. N7S->(N7S_FILIAL+N7S_CODINE) = xFilial("N7Q")+N7Q->N7Q_CODINE
				
				//Busca se para filial rolada total tem romaneio com status diferente de confirmado
				cQryRom := "     SELECT N9E.N9E_CODROM, N9E.N9E_FILIAL "
				cQryRom += "       FROM " + RetSqlName('N9E') + " N9E "
				cQryRom += " INNER JOIN " + RetSqlName('NJJ') + " NJJ "
				cQryRom += "         ON NJJ.NJJ_FILIAL = N9E.N9E_FILIAL " 
				cQryRom += "        AND NJJ.NJJ_CODROM = N9E.N9E_CODROM "
				cQryRom += "        AND NJJ.D_E_L_E_T_ = ' ' "
				cQryRom += "      WHERE N9E.N9E_CODINE = '" + N7Q->N7Q_CODINE + "' "
				cQryRom += "        AND N9E.N9E_FILIAL = '" + N7S->N7S_FILORG + "' "
				cQryRom += "        AND N9E.D_E_L_E_T_ = ' ' "
				cQryRom += "        AND NJJ.NJJ_STATUS IN ('0','2','3','4','5','6') " //2=Atualizado;3=Confirmado;4=Cancelado;5=Pendente Aprovação;6=Previsto
				cQryRom += "        AND NJJ.NJJ_TIPO = '4' " //(S) SAIDA POR VENDA
				
				cAliasRom := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryRom), cAliasRom, .F., .T.)

				If (cAliasRom)->(!EoF())
					RestArea(aArea)
					Return .F.
				EndIf

				N7S->(DbSkip())
			EndDo
		EndIf
		N7S->(DbCloseArea())

	EndIf

	RestArea(aArea)

Return .T.

/*/{Protheus.doc} fAjusN9A(oModel)
Verifica se foi alterada a entidade de entrega da IE e se sim ajusta as regras fiscais do contrato relacionado.
@type  Static Function
@author rafael.kleestadt
@since 15/03/2019
@version 1.0
@param oModel, object, objeto do modelo principal
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function fAjusN9A(oModel)
	Local oModelN7S  := oModel:GetModel("N7SUNICO")
	Local oModelN7Q  := oModel:GetModel("N7QUNICO")
	Local nOperation := oModel:GetOperation()
	Local lJaUsada   := .F.
	Local nX         := 0
	Local nQTDINS    := 0
	Local nSDOINS    := 0
	Local nQUANT     := 0
	Local cIteCad    := ""
	Local cSeqPri    := ""

	ProcRegua(oModelN7S:Length())

	//Se a IE não for de venda e mercado interno não faz o ajuste da regra fiscal
	For nX := 1 to oModelN7S:Length()
		oModelN7S:Goline( nX )
		If Posicione("NJR", 1, xFilial("N9A") + oModelN7S:GetValue("N7S_CODCTR"), "NJR_TIPO") <> "2" ; //2=Venda
			 .OR. Posicione("NJR", 1, xFilial("N9A") + oModelN7S:GetValue("N7S_CODCTR"), "NJR_TIPMER") <> "1" //1=Interno
			EXIT
			Return .T.
		EndIf
	Next nX

 If !oModel:IsCopy()	.And. (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE) .And. !Empty(oModelN7Q:GetValue("N7Q_IMPORT")) .And. !Empty(oModelN7Q:GetValue("N7Q_IMLOJA"))
		For nX := 1 to oModelN7S:Length()
			oModelN7S:Goline( nX )
			lJaUsada := .F.
			nQTDINS  := 0
			nSDOINS  := 0
			nQUANT   := 0
			cIteCad  := ""
			cSeqPri  := ""

			DbSelectArea("N9A")
			N9A->(DbSetOrder(1))
			If N9A->(DbSeek(xFilial("N9A") + oModelN7S:GetValue("N7S_CODCTR") + oModelN7S:GetValue("N7S_ITEM")+oModelN7S:GetValue("N7S_SEQPRI")))
				If N9A->(N9A_CODENT+N9A_LOJENT) <>  oModelN7Q:GetValue("N7Q_IMPORT")+oModelN7Q:GetValue("N7Q_IMLOJA")

					//Verificar se existem outras IEs com essa regra fiscal
					DbSelectArea("N7S")
					N7S->(DbSetOrder(2))//N7S_FILIAL+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI
					If N7S->(DbSeek(xFilial("N7S")+N9A->(N9A_CODCTR+N9A_ITEM+N9A_SEQPRI)))
						While N7S->(!EOF()) .And. N7S->(N7S_FILIAL+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI) = xFilial("N7S")+N9A->(N9A_CODCTR+N9A_ITEM+N9A_SEQPRI)
							If N7S->N7S_CODINE <> oModelN7Q:GetValue("N7Q_CODINE")
								lJaUsada  := .T.
								cRecNoN7S := N7S->(Recno())
								EXIT
							EndIf
							N7S->(DbSkip())
						EndDo
					EndIf
					N7S->(DbCloseArea())
							
					nQUANT  := N9A->N9A_QUANT - oModelN7S:GetValue("N7S_QTDVIN")
					nQTDINS := N9A->N9A_QTDINS - oModelN7S:GetValue("N7S_QTDVIN")
					nSDOINS := nQUANT - nQTDINS
					
					cIteCad := N9A->N9A_ITEM
					cSeqPri := N9A->N9A_SEQPRI

					//Cria uma nova Regra fiscal com a nova entidade
					DbSelectArea("NJR")
					NJR->(DbSetOrder(1))
					If NJR->(DbSeek(xFilial("NJR")+oModelN7S:GetValue("N7S_CODCTR")))
						oModelCtr := FWLoadModel('OGA290')
						oModelN9A := oModelCtr:GetModel("N9AUNICO")
						oModelNNY := oModelCtr:GetModel("NNYUNICO")
						oModelCtr:SetOperation( MODEL_OPERATION_UPDATE )
						IF oModelCtr:Activate()

							If oModelNNY:SeekLine({ {"NNY_ITEM", cIteCad} }) // Posiciona na previsão referente a reserva
								If oModelN9A:SeekLine({ {"N9A_SEQPRI", cSeqPri} }) // Posiciona na previsão referente a reserva
									If lJaUsada

										oModelN9A:SetValue("N9A_QUANT",  nQUANT)
										oModelN9A:SetValue("N9A_QTDINS", nQTDINS)
										oModelN9A:SetValue("N9A_SDOINS", nSDOINS)

										cSeqPri := Soma1(oModelN9A:GetValue("N9A_SEQPRI", oModelN9A:Length()))

										oModelN9A:AddLine()
										oModelN9A:GoLine(oModelN9A:Length())
										oModelN9A:SetValue("N9A_SEQPRI", cSeqPri) // Incremento manual de Item
										oModelN9A:SetValue("N9A_QUANT", oModelN7S:GetValue("N7S_QTDVIN"))
										oModelN9A:SetValue("N9A_QTDINS", oModelN7S:GetValue("N7S_QTDVIN"))
										oModelN9A:SetValue("N9A_SDOINS", oModelN9A:GetValue("N9A_QUANT") - oModelN9A:GetValue("N9A_QTDINS"))
										oModelN9A:SetValue("N9A_TES",    oModelN7S:GetValue("N7S_TES"))

									EndIf

									oModelN9A:SetValue("N9A_CODENT", oModelN7Q:GetValue("N7Q_IMPORT"))
									oModelN9A:SetValue("N9A_LOJENT", oModelN7Q:GetValue("N7Q_IMLOJA"))
										
										 // Valida o Model         // Realiza o commit
									If oModelCtr:VldData() .And. oModelCtr:CommitData()
										oModelCtr:DeActivate() // Desativa o model
										oModelCtr:Destroy() // Destroi o objeto do model
									Else
					
										aErro := oModelCtr:GetErrorMessage()
										AutoGrLog( STR0247 + ': [' + AllToChar( aErro[1] ) + ']' ) //"Id do formulário de origem"
										AutoGrLog( STR0248 + ': [' + AllToChar( aErro[2] ) + ']' ) //"Id do campo de origem"
										AutoGrLog( STR0249 + ': [' + AllToChar( aErro[3] ) + ']' ) //"Id do formulário de erro"
										AutoGrLog( STR0250 + ': [' + AllToChar( aErro[4] ) + ']' ) //"Id do campo de erro"
										AutoGrLog( STR0251 + ': [' + AllToChar( aErro[5] ) + ']' ) //"Id do erro"
										AutoGrLog( STR0252 + ': [' + AllToChar( aErro[6] ) + ']' ) //"Mensagem do erro"
										AutoGrLog( STR0253 + ': [' + AllToChar( aErro[7] ) + ']' ) //"Mensagem da solução"
										AutoGrLog( STR0254 + ': [' + AllToChar( aErro[8] ) + ']' ) //"Valor atribuído"
										AutoGrLog( STR0255 + ': [' + AllToChar( aErro[9] ) + ']' ) //"Valor anterior"
										MostraErro()
										
										Return .F.	
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					NJR->(DbCloseArea())

					//Atualiza o sequencial da regra fiscal da ie
					If lJaUsada
						N7S->(DbGoTo(cRecNoN7S))
						If RecLock("N7S", .F.)
							N7S->N7S_SEQPRI := cSeqPri
							N7S->(MsUnLock())
						EndIf
					EndIf

				EndIf
			EndIf
			N9A->(DbCloseArea())
		Next nX
	EndIf
Return .T.

/*/{Protheus.doc} OGA710VIMP(oField)
Valida para não permitir alterar a Entidade da IE(N7Q_IMPORT) diferente da entidade do Contrato(NJR_CODENT)
@type  Static Function
@author rafael.kleestadt
@since 27/03/2019
@version 1.0
@param oField, object, objeto do campo N7Q_IMPORT
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function OGA710VIMP(oField)
	Local oModelN7S  := oField:GetModel():GetModel("N7SUNICO")
	Local cCodCliCtr := ""
	Local cCodCtr    := ""
	Local cCodImp    := oField:GetValue("N7Q_IMPORT")
	Local cTitCliIe  := AllTrim(RetTitle("N7Q_IMPORT")) //"Cod.Entidade"
	Local cTitCliCt  := AllTrim(RetTitle("NJR_CODENT")) //"Cod.Cliente"

	If !Empty(cCodImp)
		If ExistCpo("NJ0", cCodImp)

			If oField:GetModel():GetOperation() == MODEL_OPERATION_INSERT
				cCodCtr := N9A->N9A_CODCTR
			Else
				cCodCtr := oModelN7S:GetValue("N7S_CODCTR", 1)
			EndIf
			
			cCodCliCtr := Posicione("NJR", 1, xFilial("N9A") + cCodCtr, "NJR_CODENT")

			If cCodImp <> cCodCliCtr
				HELP(' ', 1, cTitCliIe,, cTitCliIe + STR0257 + cTitCliCt + STR0258,2,0,,,,,, {STR0259+cTitCliIe+STR0260+ cCodCliCtr})
				Return .F. //"Cod.Entidade" ### "Cod.Entidade" ### " da Instrução de Embarque difere do " ### "Cod.Cliente" ### " do(s) contrato(s)." ### "Informe o " ### "Cod.Entidade" ### " igual a: " ### 
			EndIf

		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} FILTNJ0SA1()
Filtro da consulta padrao 
@type  Function
@author marcos.wagner
@since 28/03/2019
@version 1.0
@return true, logycal, true or false
/*/
Function FILTNJ0SA1()
	Local lRet := .t.

	If IsInCallStack("OGA700")
		lRet := (M->N79_TIPMER == "2" .AND. LEFT(NJ0->NJ0_CODENT,2)="EX") .OR. (M->N79_TIPMER == "1" .AND. LEFT(NJ0->NJ0_CODENT,2)<>"EX") .AND. !EMPTY(NJ0->NJ0_CODCLI)
	ElseIf IsInCallStack("OGA710")
		lRet := (M->N7Q_TPMERC == "2" .AND. LEFT(NJ0->NJ0_CODENT,2)="EX") .OR. (M->N7Q_TPMERC == "1" .AND. LEFT(NJ0->NJ0_CODENT,2)<>"EX") .AND. !EMPTY(NJ0->NJ0_CODCLI)
	EndIf

Return lRet
