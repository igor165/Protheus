#INCLUDE "OGA280.ch"
#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch" 

#DEFINE   FLDPREVFIN 1    //Folder Entregas
//--<< Vars Utilizadas composiçao de Preços >>--
Static aGrvNKA 		:= {}
Static dDEntrIni   	:= cTod('//')
Static dDEntrFim   	:= cTod('//') 

Static __lnewComerc	:= SuperGetMv('MV_AGRA001', , .F.) // Parametro de utilização do novo modelo de comercializaça
Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilizaçao do novo modelo de negocio
Static __lRegOpcional  	:= SuperGetMv('MV_AGRO040', , .F.) 	//parametro que deixa opcional o registro de negócio com o MV_AGRO002 ativo.
Static __lCtrRisco 	 	:= SuperGetMv('MV_AGRO041', , .F.) 
Static __lAprAuto		:= SuperGetMv('MV_AGRO033', , .F.) // Parametro que indica se o contrato será aprovado automaticamente após alteração
Static __lND1  	  := TableInDic('ND1')

Static __lNGraPrevF  := SuperGetMV( "MV_AGRPREV", .f., .f. ) //padrão do parametro é sempre .f. se nao existir - .f. gera previsao financeira - .t. nao gera previsao financeira
Static __lExibeImp   := SuperGetMv('MV_AGRO043', , .F.) // Parâmetro que indica se deve exibir a pasta de impostos
Static __lAutomato   := IiF(IsBlind(),.T.,.F.) 
STATIC __aOGX290FR	 := {}

/** {Protheus.doc} OGA280
Rotina para cadastro de contratos de compra
@param:     Nil
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       SIGAAGR - Originaçao de Graos
*/
Function OGA280( pcCodEnt, pcLojEnt )
	Local oMBrowse := Nil
	Local cFiltroDef := "NJR_TIPO='1'" + iIf(!Empty(pcCodEnt),".AND.NJR_CODENT='"+pcCodEnt+"'","") + iIf(!Empty(pcLojEnt),".AND.NJR_LOJENT='"+pcLojEnt+"'","")

	Private oview := Nil
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NJR" )
	oMBrowse:SetDescription( STR0001 ) //"Contratos de Compra"
	oMBrowse:SetFilterDefault( cFiltroDef )
	oMBrowse:SetMenuDef( "OGA280" )
	oMBrowse:AddFilter( STR0002, "NJR_TRANSF=='1'" ) //"Somente Transferencia entre Filiais"
	oMBrowse:AddLegend( "(NJR_MODELO=='1')"                                         , "WHITE"       , X3CboxDesc( "NJR_MODELO", "1" )   ) //"Pre-Contrato"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='P'"  , "BLUE"        , X3CboxDesc( "NJR_STATUS", "P" )   ) //"Previsto"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='A'"  , "GREEN"       , X3CboxDesc( "NJR_STATUS", "A" )   ) //"Aberto"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='I'"  , "YELLOW"      , X3CboxDesc( "NJR_STATUS", "I" )   ) //"Iniciado"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='E'"  , "BR_CANCEL"   , X3CboxDesc( "NJR_STATUS", "E" )   ) //"Cancelado"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='F'"  , "RED"         , X3CboxDesc( "NJR_STATUS", "F" )   ) //"Finalizado"

	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return( )

/** {Protheus.doc} MenuDef
Funçao que retorna os itens para construçao do menu da rotina

@param:     Nil
@return:    aRotina - Array com os itens do menu
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA280 - Contratos
*/
Static Function MenuDef()
	Local aRotina  := {}
	Local aRotina1 := {}

	aAdd( aRotina1, { STR0103   , "OGA340(NJR->NJR_CODCTR)"  				 , 0, 4, 0, Nil } ) //"Autorizaçoes"
	aAdd( aRotina1, { STR0104   , "OGA335(NJR->NJR_CODCTR,NJR->NJR_FILIAL)"  				 , 0, 4, 0, Nil } ) //"Adic./Supres."
	aAdd( aRotina1, { STR0105   , "OGA320(NJR->NJR_CODCTR,NJR->NJR_FILIAL)"  				 , 0, 4, 0, Nil } ) //"Status"
	aAdd( aRotina1, { STR0106   , "OGC003(NJR->NJR_CODCTR)"  				 , 0, 4, 0, Nil } ) //"Romaneios"
	aAdd( aRotina1, { STR0092   , "OGA280MV"            	  				 , 0, 4, 0, Nil } ) //"Amostras avulsas"
	aAdd( aRotina1, { STR0102   , "OGA280VNC"			  			 , 0, 4, 0, Nil } ) //"Vinculo Contrato"
	aAdd( aRotina1, { STR0122   , "OGR342(NJR->NJR_CODCTR, NJR->NJR_TIPO)" 			 , 0, 4, 0, Nil } ) //"Imprimir Word"

	aAdd( aRotina, { STR0009    , "PesqBrw"             , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0010    , "ViewDef.OGA280"      , 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0011    , "ViewDef.OGA280"      , 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0012    , "ViewDef.OGA280"      , 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0097    , "AGRCONHECIM('NJR')"  , 0, 4,  , .T. } ) //"Conhecimento"
	aAdd( aRotina, { STR0013    , "OGA280C"             , 0, 4, 0, Nil } ) //"Confirmar"
	aAdd( aRotina, { STR0014    , "OGA280E"             , 0, 4, 0, Nil } ) //"Cancelar"
	aAdd( aRotina, { STR0015    , "OGA280F"             , 0, 4, 0, Nil } ) //"Finalizar"
	aAdd( aRotina, { STR0016    , "AGRXREABRE"             , 0, 4, 0, Nil } ) //"Reabrir"
	aAdd( aRotina, { STR0017    , "ViewDef.OGA280"      , 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0018    , "ViewDef.OGA280"      , 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0019    , "OGR340"              , 0, 8, 0, Nil } ) //"Contrato"
	If .NOT. __lnewNeg
	   aAdd( aRotina, { STR0020    , "ViewDef.OGA280"      , 0, 9, 0, Nil } ) //"Copiar"
	EndIf

	aAdd( aRotina, { STR0100    , "AGRXHIST"           , 0, 7, 0, Nil } ) //"Historico"
	
    if __lnewNeg		
		aAdd( aRotina, { STR0136    , "OGA290VNGC(NJR->NJR_CODNGC)", 0, 2, 0, Nil } ) // # Consultar negociação
		aAdd( aRotina, { STR0137    , "OGA570(NJR->NJR_CODCTR)", 0, 2, 0, Nil } ) // # Precificação
		aAdd( aRotina, { STR0138    , "AGRXFINANC()", 0, 4, 0, Nil } ) // # Gerar Previsão Financeira
        aAdd( aRotina, { STR0139    , "OGC150(NJR->NJR_CODCTR, .F.)", 0, 2, 0, Nil } ) // # Consulta de Previsões        
		If __lRegOpcional // apenas sem ngc obrigado.
   			aAdd( aRotina, { STR0140    , "AGRXCNGC(NJR->NJR_CODCTR, nil, .T.)", 0, 2, 0, Nil } ) // # Fixação de Contrato
		Endif

		aAdd( aRotina1, { STR0154   , "OGRX020()"                         	    , 0, 8, 0, Nil } ) //"Extrato Contrato"
        aAdd( aRotina1, { STR0155   , "OGX290NFUT()"                         	, 0, 4, 0, Nil } ) //"Emitir NF Operação Futura"
	endif 

	If ExistBlock('OG280MNU')
		aRet := ExecBlock('OG280MNU',.F.,.F.,{aRotina})
		If ValType(aRet) == 'A'
			aRotina	:= aClone(aRet)
		EndIf
	EndIf
	aAdd( aRotina, { STR0108    , aRotina1              , 0, 4, 0, Nil } ) //"Mais açoes..."
Return( aRotina )

/** {Protheus.doc} ModelDef
Funçao que retorna o modelo padrao para a rotina

@param:     Nil
@return:    oModel - Modelo de dados
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA280 - Contratos
*/
Static Function ModelDef()
	Local oStruNJR  := FWFormStruct( 1, "NJR" ) //Contratos                      		
	Local oStruNNY  := FWFormStruct( 1, "NNY" ) //Cadencias do Contrato         
	Local oStruNN7  := FWFormStruct( 1, "NN7" )	//Previsao Financeira do Contrat
	Local oStruNNF  := FWFormStruct( 1, "NNF" ) //Despesas - Corretores         
	Local oStruNN8  := FWFormStruct( 1, "NN8" ) //Fixacao do Contrato           
	Local oStruNKA  := FWFormStruct( 1, "NKA" ) //Composicao de Preco da Fixacao
	Local oStruNKT  := FWFormStruct( 1, "NKT" ) //TROCAS
	Local oStruNNG  := FWFormStruct( 1, "NNG" ) //Cessao de Credito do Contrato 	
	Local oStruNKO  := FWFormStruct( 1, "NKO" ) //PRODUTOS DA TROCA             
	
	Local oStruNKH  := nil //Previsao Fiscal do Contrato   
	Local oStruN84  := nil //Condição Pagamento do Contrato
    Local oStruN9A  := nil //Regras Fiscais do Contrato    
    Local oStruN9J  := nil //Relacionamento Regra fiscal x 
    Local oStruND1  := nil //Fixação X Previsão                   
    Local oStruN9D  := nil //Movimentação de Fardos         					
	//Modelos que sera relacionados na operaçao de DELETE do model
	Local oStruN7M  	:= NIL //Componentes Fixados           
	Local oStruN7N  	:= NIL // Componentes Fix X Preços Fix 
	Local oStruN7O  	:= NIL //Negócios Fix X Componentes Fix

	Local oModel    := MPFormModel():New( "OGA280" ,  {| oModel | PreModelo( oModel ) }, {| oModel | PosModelo( oModel ) }, {| oModel | GrvModelo( oModel ) }  )
	Local oField    := oModel
	Local bPreVal   :=  {|oFieldModel, cAction, cIDField, xValue|PreValNJR(oFieldModel, cAction, cIDField, xValue)}

	oStruNJR:SetProperty( "NJR_TIPO" 	, MODEL_FIELD_INIT , {| x | x := "1" }  ) // 2=COMPRA -- INICIALIZADOR VALOR PADRÃO
	oStruNJR:SetProperty( "NJR_MODELO" 	, MODEL_FIELD_INIT , {| x | x := "2" }  ) // 2=CONTRATO	  -- INICIALIZADOR VALOR PADRÃO	

	oStruNNF:SetProperty("NNF_MODCOM",MODEL_FIELD_WHEN	, FWBuildFeature( STRUCT_FEATURE_WHEN , "OGA290WHN(a, b, c)" )  )		        

	If (IsInCallStack("OGX700CTR") .OR. IsInCallStack("OGX700ACTR")) 
		oStruNN7:SetProperty( "*", MODEL_FIELD_OBRIGAT , .F.  ) 
		oStruNJR:SetProperty( "*", MODEL_FIELD_OBRIGAT , .F.  ) 
		oStruNNY:SetProperty( "*", MODEL_FIELD_OBRIGAT , .F.  ) 
	else
		oStruNN7:SetProperty( "NN7_CODFAV", MODEL_FIELD_OBRIGAT , .F.  )
		oStruNN7:SetProperty( "NN7_LOJFAV", MODEL_FIELD_OBRIGAT , .F.  )
	EndIf 	
	
	oStruNN8:SetProperty( "NN8_ITEMFX" 	, MODEL_FIELD_VALID ,  {| oField | ExistChav('NN8',FwFldGet('NN8_CODCTR')+FwFldGet('NN8_ITEMFX') ) } ) 

	oStruNKO:SetProperty( '*', MODEL_FIELD_OBRIGAT,  .f.  )
	oStruNKT:SetProperty( "*", MODEL_FIELD_OBRIGAT , .F.  ) 

    oStruNN7:RemoveField( "NN7_CODCTR" )
    oStruNNY:RemoveField( "NNY_CODCTR" )
	oStruNNF:RemoveField( "NNF_CODCTR" )    
    oStruNNG:RemoveField( "NNG_CODCTR" )    

	If __lNGraPrevF // __lNGraPrevF = .F. --> Gera previsão financeira
		oStruNJR:SetProperty("NJR_VLRBAS", MODEL_FIELD_OBRIGAT, .F.)
		oStruNJR:SetProperty("NJR_VLRUNI", MODEL_FIELD_OBRIGAT, .F.)
		oStruNN7:SetProperty("NN7_VALOR" , MODEL_FIELD_OBRIGAT, .F.)
	EndIf

	If cPaisLoc == "PAR" .Or. cPaisLoc == "ARG"
		oStruNJR:SetProperty("NJR_VLRUNI", MODEL_FIELD_OBRIGAT, .F.)
	EndIf	

	//Tratamento TES inteligente.
	If cPaisLoc != "PAR" .AND. cPaisLoc != "ARG"
		oStruNJR:AddTrigger( "NJR_OPEFIS", "NJR_TESEST", { || .T. }, { | x | AGRXTESINT() } ) 
		oStruNJR:AddTrigger( "NJR_CODENT", "NJR_TESEST", { || .T. }, { | x | AGRXTESINT() } ) 
		oStruNJR:AddTrigger( "NJR_LOJENT", "NJR_TESEST", { || .T. }, { | x | AGRXTESINT() } ) 
		oStruNJR:AddTrigger( "NJR_CODPRO", "NJR_TESEST", { || .T. }, { | x | AGRXTESINT() } )        
	EndIf	
	
	If __lnewNeg //NOVO NEGOCIO     
		oStruN84    := FWFormStruct( 1, "N84" ) // Estrutura de Condição de pagamentos
		oStruN9A    := FWFormStruct( 1, "N9A" ) // Estrutura de Regras Fiscais
		oStruN9J    := FWFormStruct( 1, "N9J" ) // Estrutura de Regras Fiscais
		oStruND1    := FWFormStruct( 1, "ND1", { |x| !ALLTRIM(x) $ 'ND1_VLUDES'} )  // Retirado campo, pois a atualização não é via modelo e sim no OGX070	    				        
        oStruN9D    := FWFormStruct( 1, "N9D" ) // Estrutura de Regras Fiscais
        
        oStruN9D:AddField(STR0141, STR0141, "N9D_DXIREC", "C", 254, 0, , , , .F., {|| AGRXRECDXI(N9D->N9D_FILIAL, N9D->N9D_SAFRA, N9D->N9D_FARDO) }, , .F., .T.) // Campo auxiliar de recno # "Recno Auxiliar"
		oStruN9D:AddField(STR0142, STR0142, "N9D_DXIEMB", "C", 1, 0, , , , .F., {|| AGRXVQIE(N9D->N9D_FILIAL, N9D->N9D_SAFRA, N9D->N9D_FARDO) }, , .F., .T.) // Campo auxiliar de fardos com IE # Possui IE ?		
		
		oStruN9D:SetProperty("*", MODEL_FIELD_VALID, {|| .T.}) 
        oStruN9D:SetProperty("*", MODEL_FIELD_WHEN, {|| .T.}) 
        oStruN9D:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
        
		oStruN9A:SetProperty('N9A_CODCTR', MODEL_FIELD_OBRIGAT, .F.)		

		If __lRegOpcional
			oStruNN7:SetProperty( "*", MODEL_FIELD_OBRIGAT , .F.  ) 
		EndIf

		oStruN9A:SetProperty( "N9A_SEQPRI"	, MODEL_FIELD_OBRIGAT, .T. ) //Ajustado no dicionario da 34 para obrigatorio
		oStruN84:SetProperty( "N84_SEQUEN"	, MODEL_FIELD_OBRIGAT, .T. ) //Ajustado no dicionario da 34 para obrigatorio

		oStruNJR:SetProperty("NJR_TESEST", MODEL_FIELD_OBRIGAT, .F.)//não obrigatorio
		oStruNN7:SetProperty("NN7_DTVENC" ,MODEL_FIELD_INIT, { || "" }) 
		oStruNN7:SetProperty("NN7_VALOR" , MODEL_FIELD_OBRIGAT, .F.) //retira a obrigatoriedade do valor
		oStruN9A:SetProperty("N9A_VLUFPR", MODEL_FIELD_INIT, {| oField | fN9AVlUFa( oField ) } )	        
		oStruNNY:SetProperty("NNY_FILORG", MODEL_FIELD_OBRIGAT , .T.  )		
		oStruN84:SetProperty('N84_CODCTR', MODEL_FIELD_OBRIGAT, .F.)
		If GetRpoRelease() <= "12.1.027"
			oStruN9A:SetProperty("N9A_CODENT", MODEL_FIELD_INIT, {| | OGA290BSC( 'N9A_CODENT' ) } )	
			oStruN9A:SetProperty("N9A_LOJENT", MODEL_FIELD_INIT, {| | OGA290BSC( 'N9A_LOJENT' ) } )	
			oStruN9A:SetProperty("N9A_CODFIN", MODEL_FIELD_INIT, {| | OGA290BSC( 'N9A_CODFIN' ) } )	
			oStruN9A:SetProperty("N9A_TIPCLI", MODEL_FIELD_INIT, {| | OGA290BSC( 'N9A_TIPCLI' ) } )	
		EndIf

        If !AGRXRESI(NJR->NJR_CODPRO)
		    oStruNJR:SetProperty( "NJR_TABELA"	, MODEL_FIELD_OBRIGAT, .F. ) 
	    Endif

		If oStruN84:HasField("N84_PROVIS")
            oStruN84:RemoveField( "N84_PROVIS" )
        EndIf 

		If !isBlind() 
			oStruNN7:AddField("TP" , "Legenda", 'NN7_STSLEG', 'BT' , 1 , 0, , ;
							  NIL , NIL, NIL, {||Iif(!Empty(NN7->(NN7_STATUS)), AGRXPFLEG(NN7->(NN7_STATUS)),"BR_VERDE")}, NIL, .F., .T.) // Adiciona a Estrutura da Grid o Botão de Legenda
		endif		
	
		If cPaisLoc != "PAR" .AND. cPaisLoc != "ARG"
			oStruNJR:AddTrigger( "NJR_CODPRO", "NJR_BOLSA",  { || .T. }, { | x | AGRXBOLSA()  } )        
		EndIf	

		oStruNJR:AddTrigger( "NJR_CODENT", "NJR_CODENT", { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_CODENT" ) } )
		oStruNJR:AddTrigger( "NJR_LOJENT", "NJR_LOJENT", { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_LOJENT" ) } )
        oStruNJR:AddTrigger( "NJR_CODTER", "NJR_CODTER", { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_CODTER" ) } )
		oStruNJR:AddTrigger( "NJR_LOJTER", "NJR_LOJTER", { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_LOJTER" ) } )					
		oStruNJR:AddTrigger( "NJR_CODFIN", "NJR_CODFIN", { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_CODFIN" ) } )
		oStruNJR:AddTrigger( "NJR_DESFIN", "NJR_DESFIN", { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_DESFIN" ) } )
        oStruNJR:AddTrigger( "NJR_INCOTE", "NJR_INCOTE", { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_INCOTE" ) } )
        oStruNJR:AddTrigger( "NJR_CONDPA", "NJR_CONDPA", { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_CONDPA" ) } )
        oStruNJR:AddTrigger( "NJR_CONDPG", "NJR_CONDPG", { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_CONDPG" ) } )        
        oStruNJR:AddTrigger( "NJR_CODPRO", "NJR_CODPRO", { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_CODPRO" ) } )        
        oStruNJR:AddTrigger( "NJR_TIPO",   "NJR_TIPO",   { || .T. }, { | oField, cCampo | AGRXNJRN9A( oModel, "NJR_TIPO" ) } )        
        oStruN9A:AddTrigger( "N9A_OPEFIS", "N9A_TES",    { || .T. }, { | x | AGRXTESINT(.T.)}) 
        
        oModel:AddFields( "NJRUNICO", /*cOwner*/, oStruNJR,bPreVal , {| oField | PosValNJR( oField ) } /*bPost*/, /*bLoad */ /*{|oMod, lCopy| OGA280LOAD(oMod, lCopy)}*/  )
	else 
		//MODELO CLASSICO
		oModel:AddFields( "NJRUNICO", /*cOwner*/, oStruNJR,bPreVal , /*bPost*/, /*bLoad */ /*{|oMod, lCopy| OGA280LOAD(oMod, lCopy)}*/  )
	endIf
	
	oModel:GetModel( "NJRUNICO" ):SetDescription( STR0023 ) //"Dados do Contrato de Compra"
	oModel:SetDescription( STR0022 ) //"Contrato de Compra"

	//--<< Campos que nao devem copiar no processo de copia >>--
	cFldsNCopy :=''
	cFldsNCopy += "NJR_CODCTR,NJR_ULTALT,NJR_DATA,NJR_CODRPC,NJR_AUTENT,NJR_AUTSAI,NJR_QTEFCO,NJR_QTEFIS,NJR_VLEFIS,"
	cFldsNCopy += "NJR_QTSEMB,NJR_QTSFCO,NJR_QTSFIS,NJR_VLSFIS,NJR_QSLEMB,NJR_QSLFCO,NJR_SLDFIS,NJR_SLDTO,NJR_QTDRES,"
	cFldsNCopy += "NJR_QTDQUE,NJR_VLRUNI,NJR_VLRTOT,NJR_TRANSF,NJR_MODELO,NJR_MODBAS,NJR_STSASS,NJR_STSFIS,NJR_STSFIN,"
	cFldsNCopy += "NJR_STSEST,NJR_STATUS,NJR_VLRBAS,NJR_QTDINI,NJR_QTDCTR,NJR_MODAL,NJR_INSCPO"
	aFldNCopy  := Separa(cFldsNCopy,',' )
	oModel:GetModel( "NJRUNICO" ):SetFldNoCopy( aFldNcopy ) // Na função Copiar nao copia os campos de retornados em array 

	oModel:AddGrid( "NN7UNICO", "NJRUNICO", oStruNN7,/*bLinePre*/ ,/* bLinePos*/ ,{|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue|PreValNN7(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}, { | oGrid | AGRXPOSNN7( oGrid ) },  )
	oModel:GetModel( "NN7UNICO" ):SetDescription( STR0024 ) //"Dados das previsoes Financeiras"
	oModel:GetModel( "NN7UNICO" ):SetUniqueLine( { "NN7_ITEM" } )
	oModel:GetModel( "NN7UNICO" ):SetOptional( .t. )
	oModel:SetRelation( "NN7UNICO", { { "NN7_FILIAL", "xFilial( 'NN7' )" }, { "NN7_CODCTR", "NJR_CODCTR" } }, NN7->( IndexKey( 1 ) ) )
	oModel:GetModel( "NN7UNICO" ):SetFldNoCopy( AGRXNOCOPY( oModel:GetModel( "NN7UNICO" ) ) ) // Na função Copiar nao copia os campos de retornados em array   

	oModel:AddGrid( "NNYUNICO", "NJRUNICO",oStruNNY,{|oModelGrid, nLine,cAction,cField,xVrNovo,xVrAnt|PreValNNY(oModelGrid, nLine, cAction, cField,xVrNovo,xVrAnt)} , , , { | oGrid | AGRXPOSNNY( oGrid ) }, {|oGrid, lCopy| AGRXLICOPY(oGrid, lCopy)})
	oModel:GetModel( "NNYUNICO" ):SetDescription( STR0026 ) //"Dados do Intervalo de cadencia"
	oModel:GetModel( "NNYUNICO" ):SetUniqueLine( { "NNY_ITEM" } )
	oModel:GetModel( "NNYUNICO" ):SetOptional( .t. ) // .f. )
	oModel:SetRelation( "NNYUNICO", { { "NNY_FILIAL", "xFilial( 'NNY' )" }, { "NNY_CODCTR", "NJR_CODCTR" } }, NNY->( IndexKey( 1 ) ) )
	oModel:GetModel( "NNYUNICO" ):SetFldNoCopy( AGRXNOCOPY( oModel:GetModel( "NNYUNICO" ) ) ) // Na funcao Copiar nao copia os campos de retornados em array

	oModel:AddGrid( "NNGUNICO", "NJRUNICO", oStruNNG, , , , { | oGrid | ValPosNNG( oGrid ) } ,  )
	oModel:GetModel( "NNGUNICO" ):SetDescription( STR0027 ) //"Dados das cessoes de Credito"
	oModel:GetModel( "NNGUNICO" ):SetUniqueLine( { "NNG_ITEM" } )
	oModel:GetModel( "NNGUNICO" ):SetOptional( .t. )
	oModel:SetRelation( "NNGUNICO", { { "NNG_FILIAL", "xFilial( 'NNG' )" }, { "NNG_CODCTR", "NJR_CODCTR" } }, NNG->( IndexKey( 1 ) ) )
	oModel:GetModel( "NNGUNICO" ):SetFldNoCopy( AGRXNOCOPY( oModel:GetModel( "NNGUNICO" ) ) ) // Na função Copiar nao copia os campos de retornados em array

	oModel:AddGrid( "NNFUNICO", "NJRUNICO", oStruNNF, , , , { | oGrid | ValPosNNF( oGrid ) } ,  )
	oModel:GetModel( "NNFUNICO" ):SetDescription( STR0028 ) //"Dados dos Corretores"
	oModel:GetModel( "NNFUNICO" ):SetUniqueLine( { "NNF_ITEM" } )
	oModel:GetModel( "NNFUNICO" ):SetOptional( .t. )
	oModel:SetRelation( "NNFUNICO", { { "NNF_FILIAL", "xFilial( 'NNF' )" }, { "NNF_CODCTR", "NJR_CODCTR" } }, NNF->( IndexKey( 1 ) ) )
	oModel:GetModel( "NNFUNICO" ):SetFldNoCopy( AGRXNOCOPY( oModel:GetModel( "NNFUNICO" ) ) ) // Na função Copiar nao copia os campos de retornados em array

	If __lExibeImp
		//Impostos
		oStruNKH  := FWFormStruct( 1, "NKH" )	
		oStruNKH:SetProperty( '*', MODEL_FIELD_OBRIGAT, .f. )
		oStruNKH:RemoveField( "NKH_CODCTR" )

		oModel:AddGrid( "NKHUNICO", "NJRUNICO", oStruNKH, , , , , )
		oModel:GetModel( "NKHUNICO" ):SetDescription( STR0153 ) //"Dados dos Impostos"
		oModel:GetModel( "NKHUNICO" ):SetUniqueLine( { "NKH_ITEM" } )
		oModel:GetModel( "NKHUNICO" ):SetNoDelete( .t. )
		oModel:GetModel( "NKHUNICO" ):SetNoInsert( .t. )
		oModel:GetModel( "NKHUNICO" ):SetOptional( .t. )
		oModel:SetRelation( "NKHUNICO", { { "NKH_FILIAL", "xFilial( 'NKH' )" }, { "NKH_CODCTR", "NJR_CODCTR" } }, NKH->( IndexKey( 1 ) ) )
		oModel:GetModel( "NKHUNICO" ):SetFldNoCopy( AGRXNOCOPY( oModel:GetModel( "NKHUNICO" ) ) ) // Na função Copiar nao copia os campos de retornados em array

	EndIf

	If __lnewNeg 
		//NOVO NEGOCIO
		//Condição de Pagamento		
		oModel:AddGrid( "N84UNICO", "NJRUNICO", oStruN84,{|oSubModel, nLine, cAction, cIDField, xNewValue| AGRXN84Upd(oSubModel, nLine, cAction, cIDField, xNewValue)},,,{ | oMDGrid | AGRXVLDN84( oMDGrid )} )
		oModel:GetModel( "N84UNICO" ):SetUniqueLine( {"N84_SEQUEN" } )
		oModel:GetModel( "N84UNICO" ):SetOptional( .T. )
		oModel:SetRelation( "N84UNICO", { { "N84_FILIAL", "xFilial( 'N84' )" }, { "N84_CODCTR", "NJR_CODCTR" } }, N84->( IndexKey( 1 ) ) )
		oModel:GetModel( "N84UNICO" ):SetFldNoCopy( AGRXNOCOPY( oModel:GetModel( "N84UNICO" ) ) ) // Na função Copiar nao copia os campos de retornados em array

        //Regras Fiscais		
		oModel:AddGrid( "N9AUNICO", "NNYUNICO", oStruN9A,{|oModelGrid, nLine,cAction,cField,xVrNovo,xVrAnt|PreValN9A(oModelGrid, nLine, cAction, cField,xVrNovo,xVrAnt)} , , , { | | OGX280POSV( )} )
		oModel:GetModel( "N9AUNICO" ):SetUniqueLine( {"N9A_ITEM","N9A_SEQPRI" } )
		oModel:GetModel( "N9AUNICO" ):SetOptional( .T. )
		oModel:SetRelation( "N9AUNICO", { { "N9A_FILIAL", "xFilial( 'N9A' )" }, { "N9A_CODCTR", "NJR_CODCTR" }, { "N9A_ITEM", "NNY_ITEM" } }, N9A->( IndexKey( 1 ) ) )

		//relacionamento de previsões financeiras	
		oModel:AddGrid("N9JUNICO", "NJRUNICO", oStruN9J)
		oModel:GetModel("N9JUNICO"):SetOptional(.T.)
		oModel:SetRelation("N9JUNICO", {{ "N9J_FILIAL", "xFilial( 'N9J' )" }, { "N9J_CODCTR", "NJR_CODCTR" }}, N9J->(IndexKey(1)))

        //Fardos Vinculados X Regras Fiscais
		oModel:AddGrid("N9DUNICO", "N9AUNICO", oStruN9D)
		oModel:GetModel("N9DUNICO"):SetOptional(.T.)
		oModel:SetRelation("N9DUNICO", {{ "N9D_FILORG", "NJR_FILIAL" }, { "N9D_CODCTR", "NJR_CODCTR" }, { "N9D_ITEETG", "N9A_ITEM" }, { "N9D_ITEREF", "N9A_SEQPRI" }, { "N9D_TIPMOV", "'02'" }, { "N9D_STATUS", "'2'" } }, N9D->(IndexKey(4)))
		oModel:GetModel("N9DUNICO"):SetOnlyQuery(.T.)

		If __lND1
            oModel:AddGrid("ND1UNICO", "N9JUNICO", oStruND1)
            oModel:GetModel("ND1UNICO"):SetOptional(.T.)
            oModel:SetRelation("ND1UNICO", {{ "ND1_FILIAL",  "xFilial( 'ND1' )"  }, { "ND1_CODCTR", "NJR_CODCTR" }, { "ND1_ITEMPE", "N9J_ITEMPE" }, { "ND1_ITEMRF", "N9J_ITEMRF" }, { "ND1_SEQCP", "N9J_SEQCP" }, { "ND1_SEQPF", "N9J_SEQPF" }, { "ND1_SEQN9J", "N9J_SEQ" }}, ND1->(IndexKey(1)))                    
        EndIf   

        //trata para não aparecer os títulos sem previsão
		oModel:GetModel( 'NN7UNICO' ):SetLoadFilter(, "NN7_VALOR > 0 OR NN7_SLDQTD > 0") //comentado, pois é necessário todas as previsões para recalcular a previsão financeira     

		//Executa a partir da reprovação do negócio
		If IsInCallStack("OGX700CNEG")
			//Adiciona os relacionamentos das tabelas para deleção junto com o model
			oStruN7M  	:= FWFormStruct( 1, "N7M" )
			oStruN7N  	:= FWFormStruct( 1, "N7N" )
			oStruN7O  	:= FWFormStruct( 1, "N7O" )	   
			oStruNN8  	:= FWFormStruct( 1, "NN8" )
			oStruNKA  	:= FWFormStruct( 1, "NKA" )	   
			
			oModel:AddGrid( "N7MUNICO", "NJRUNICO", oStruN7M )
			oModel:AddGrid( "N7NUNICO", "NJRUNICO", oStruN7N )
			oModel:AddGrid( "N7OUNICO", "NJRUNICO", oStruN7O )	   
			oModel:AddGrid( "NN8UNICO", "NJRUNICO", oStruNN8 )
			oModel:AddGrid( "NKAUNICO", "NJRUNICO", oStruNKA )
			
			oModel:GetModel( "N7MUNICO" ):SetOptional( .T. )
			oModel:GetModel( "N7NUNICO" ):SetOptional( .T. )
			oModel:GetModel( "N7OUNICO" ):SetOptional( .T. )	 
			oModel:GetModel( "NN8UNICO" ):SetOptional( .T. )  
			oModel:GetModel( "NKAUNICO" ):SetOptional( .T. )
			
			oModel:SetRelation( "N7MUNICO", { { "N7M_FILIAL", "xFilial( 'N7M' )" }, { "N7M_CODCTR", "NJR_CODCTR" } }, N7M->( IndexKey( 1 ) ) )
			oModel:SetRelation( "N7NUNICO", { { "N7N_FILIAL", "xFilial( 'N7N' )" }, { "N7N_CODCTR", "NJR_CODCTR" } }, N7N->( IndexKey( 1 ) ) )
			oModel:SetRelation( "N7OUNICO", { { "N7O_FILIAL", "xFilial( 'N7O' )" }, { "N7O_CODCTR", "NJR_CODCTR" } }, N7O->( IndexKey( 2 ) ) )	   
			oModel:SetRelation( "NN8UNICO", { { "NN8_FILIAL", "xFilial( 'NN8' )" }, { "NN8_CODCTR", "NJR_CODCTR" } }, NN8->( IndexKey( 1 ) ) )
			oModel:SetRelation( "NKAUNICO", { { "NKA_FILIAL", "xFilial( 'NKA' )" }, { "NKA_CODCTR", "NJR_CODCTR" } }, NKA->( IndexKey( 1 ) ) )
		EndIF

	Else	
		//COMERCIALIZAÇÃO CLASSICA
		oModel:AddGrid( "NN8UNICO", "NJRUNICO", oStruNN8, , , , )
		oModel:GetModel( "NN8UNICO" ):SetDescription( "Fixações" ) //"Fixações"	
		oModel:GetModel( "NN8UNICO" ):SetOptional( .T. )
		oModel:SetRelation( "NN8UNICO", { { "NN8_FILIAL", "xFilial( 'NN8' )" }, { "NN8_CODCTR", "NJR_CODCTR" }}, NN8->( IndexKey( 1 ) ) )
		oModel:GetModel( "NN8UNICO" ):SetFldNoCopy( AGRXNOCOPY( oModel:GetModel( "NN8UNICO" ) ) ) // Na função Copiar nao copia os campos de retornados em array
		
		oModel:AddGrid( "NKAUNICO", "NN8UNICO", oStruNKA, , , , )
		oModel:GetModel( "NKAUNICO" ):SetDescription( "Componentes" ) //"Componentes"	
		oModel:GetModel( "NKAUNICO" ):SetOptional( .T. )
		oModel:SetRelation( "NKAUNICO", { { "NKA_FILIAL", "xFilial( 'NKA' )" }, { "NKA_CODCTR", "NN8_CODCTR" }, { "NKA_ITEMFX", "NN8_ITEMFX" } }, NKA->( IndexKey( 1 ) ) )
		oModel:GetModel( "NKAUNICO" ):SetFldNoCopy( AGRXNOCOPY( oModel:GetModel( "NKAUNICO" ) ) ) // Na função Copiar nao copia os campos de retornados em array	
	EndIf
	
	oModel:AddGrid( "NKTUNICO", "NJRUNICO", oStruNKT, , , ,) 
	oModel:GetModel( "NKTUNICO" ):SetUniqueLine( { "NKT_TRCNUM" } )
	oModel:GetModel( "NKTUNICO" ):SetOptional( .t. )
	oModel:GetModel( "NKTUNICO" ):SetOnlyQuery(.t.) 

	oModel:SetRelation("NKTUNICO", { { "NKT_FILIAL", "xFilial( 'NKT' )" } , { "NKT_CODCTR", "NJR_CODCTR" } }, NKT->( IndexKey( 2 ))) 
	
	oModel:AddGrid( "NKOUNICO", "NKTUNICO", oStruNKO, , , , /*{ | oGrid | ValPosNKO( oGrid ) }*/ )
	oModel:GetModel( "NKOUNICO" ):SetDescription( STR0074 ) //"Dados de Troca"
	oModel:GetModel( "NKOUNICO" ):SetUniqueLine( { "NKO_ITEM" } )
	oModel:GetModel( "NKOUNICO" ):SetOptional( .t. )
	oModel:GetModel( "NKOUNICO" ):SetOnlyQuery(.t.) //<<--Somente Consulta não Grava nada no Modelo, Os dados serão gravado no OGA300 >>

	oModel:SetRelation( 'NKOUNICO', { { "NKO_FILIAL", "xFilial( 'NKO' )" } , { 'NKO_TRCNUM','NKT_TRCNUM' }  }, NKO->( IndexKey( 1 )))

	//--<< Desabilita o Grid para Insert,Delete e Update >>--   
	oModel:GetModel( "NKOUNICO" ):SetNoInsertLine( .t. )
	oModel:GetModel( "NKOUNICO" ):SetNoUpdateLine( .t. )
	oModel:GetModel( "NKOUNICO" ):SetNoDeleteLine( .t. )    
	
	oModel:SetVldActivate(	{ | oModel | VldActveMd( oModel,	oModel:GetOperation() ) } )
	oModel:SetActivate( 	{ | oMod   | ActivateMD( oMod,		oModel:GetOperation() ) } )

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param:     Nil
@return:    oView - View do modelo de dados
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA280 - Contratos
*/
Static Function ViewDef()
	Local oStruNJR   := nil
	Local oStruNN7   := nil
    Local oStruNNY   := nil
	Local oStruNNG   := FWFormStruct( 2, "NNG", { |x| !ALLTRIM(x) $ 'NNG_CODCTR'} )
	Local oStruNNF   := NIL
	Local oStruNKH 	 as object
	Local oStruNKO   := FWFormStruct( 2, "NKO", { |x| !ALLTRIM(x) $ 'NKO_TRCNUM'}  )
	Local oModel     := FWLoadModel( "OGA280" )
	Local lAgoClas   := SuperGetMV("MV_AGOCLAS",.F.,.F.) //PARAMETRO SE HABILITA CONTROLE FISICO/FISCAL
    Local nIt        := 0
    Local aFields    := {}
	Local oStruN84   := Nil
	Local oStruN9A   := Nil	
    Local cNoViewNJR := ""
    Local cNoViewNN7 := ""
    Local cNoViewNNY := ""
    Local cNoViewN9A := ""
    Local cNoViewNNF := ""

	oView := Nil 
	oView := FWFormView():New()	
	
	cNoViewNJR := "NJR_TIPO;NJR_CARENC;NJR_DBOLSA;NJR_PROMIN;NJR_STSMIN;NJR_PERIOD;NJR_PERQUE;NJR_DTULTC|NJR_QTDRET|NJR_SLDTOT|NJR_CODTSE|NJR_DESTSE|NJR_QTDQUE|NJR_TESQTE|NJR_TESRSI|"+;   
					"NJR_OPERAC|NJR_DESMOR|NJR_DESMOF|NJR_DIASF|NJR_DIASR|NJR_TIPMER|NJR_CONDPA|NJR_DESCPA|NJR_VIA|NJR_DESVIA|NJR_INCOTE|NJR_DESINC|NJR_CODREM|NJR_DESREM"+;
					"NJR_CONDPG|NJR_DIASPG|NJR_DESPG|NJR_HVIUM|NJR_TIPUM|NJR_HVICAL|NJR_OUTUM|NJR_TIPCAL|NJR_HVIFAT|NJR_OUTCAL|NJR_OUTFAT|NJR_HVITOL|NJR_QAPADR|NJR_TIPACE|"+;
					"NJR_TISEVO|NJR_TKPFIS|NJR_TIPFAT|NJR_TPSEVO|NJR_TIPALG|NJR_HVIREG|"

    If !lAgoClas
	   cNoViewNJR +=  "NJR_CLASSP|NJR_CLASSQ"            
	EndIf
	
    cNoViewNN7 += "NN7_CODCTR|NN7_CONTST|NN7_STATUS|NN7_STSTIT|NN7_CONTOB|"
    cNoViewNNY += "NNY_CODCTR|NNY_DTLTKP|NNY_TKPQTD|NNY_CODCTR|NNY_MESBOL|NNY_MESANO|NNY_MEMBAR|NNY_TKPQTD"    

	If __lnewNeg 
		cNoViewNJR += "NJR_DATREF|NJR_OPETRI|NJR_OPEFUT|NJR_TESEST|NJR_TESFIN|NJR_OPEFIS|"
		cNoViewN9A += "N9A_DESCTR|N9A_TIPMER|N9A_TIPCTR|N9A_DESOPF|N9A_CODPRO|N9A_DESPRO|N9A_UNIPRO|N9A_INCOTE|N9A_CONDPA|N9A_DESCPA|N9A_CONDPG|N9A_DESPG|N9A_CTREXT|N9A_QTNFPV|N9A_TAKEUP|N9A_DTLTKP|N9A_NUMDCO|N9A_SEQDCO|N9A_TPAVIS|N9A_DTPAVI|N9A_CODCTR|N9A_ITEM|N9A_QTDTKP|N9A_QTDINS|N9A_SDOINS|N9A_OPETRI|"
		cNoViewNNF += "NNF_CODCTR|NNF_NLJENT|NNF_PCBCOM|NNF_STATUS|"

		IF !__lCtrRisco
			cNoViewNNY += "NNY_QTDCTR|"
		EndIf

		oStruNJR    := FWFormStruct( 2, "NJR",  { |x| !ALLTRIM(x) $ cNoViewNJR})		
		oStruNNY  	:= FWFormStruct( 2, "NNY" , { |x| !ALLTRIM(x) $ cNoViewNNY})
		oStruNN7  	:= FWFormStruct( 2, "NN7" , { |x| !ALLTRIM(x) $ cNoViewNN7} )		
		oStruNNF    := FWFormStruct( 2, "NNF" , { |x| !ALLTRIM(x) $ cNoViewNNF} )	

		oStruNN7:AddField( "NN7_STSLEG" ,'01' , "", "Legenda" , {} , 'BT' ,'@BMP', NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .T. )	
		
		oStruN84  	:= FWFormStruct( 2, "N84" , { |x| !ALLTRIM(x) $ 'N84_CODCTR|N84_PROVIS|N84_REFPRF'})		
		oStruN9A  	:= FWFormStruct( 2, "N9A" , { |x| !ALLTRIM(x) $ cNoViewN9A})		
		
		oStruN84:SetProperty('N84_REFCTR', MVC_VIEW_COMBOBOX, {'5=Início da Cadência', "6=Fim da Cadência", "7=Data negociada" })					

	Else
		cNoViewNJR += 'NJR_UM2PRO|NJR_QTDUM2|NJR_CTREXT|NJR_CODFIN|NJR_TIPOCL|NJR_DESFIN|NJR_CLVL|NJR_BOLSA|NJR_DBOLSA|NJR_DESMOR|NJR_DESMOF|NJR_GENMOD|NJR_BCOPRV|'+;
						'NJR_AGGPRV|NJR_CTAPRV|NJR_CODNGC|NJR_VERSAO|NJR_RESFIX|NJR_CHKFIX|NJR_TOTNN7|NJR_TOTN9G|NJR_TOTN9K|NJR_TOTAFT|NJR_TOTARB|'+;
						'NJR_STSMIN|NJR_PROMIN|NJR_CODEMB|NJR_DESEMB|NJR_CONPES|NJR_CLASSQ|'
		
		cNoViewNN7 += "NN7_VLUNIP|NN7_TIPO|NN7_FILORG|NN7_FILDES|NN7_CHATIT|NN7_MOEDA|NN7_VLRTAX|NN7_QTDE|NN7_SLDQTD|NN7_STSTIT|NN7_VLCOMP|"+;
						"NN7_VLTEMI|NN7_VLTNCO|NN7_VLRAVI|NN7_VLDEVL|NN7_TIPEVE|NN7_DESMOE|NN7_NOMENT|NN7_TIPMER|NN7_CTREXT|NN7_DESPRO|NN7_MOEREF|"+;
						"NN7_VALMOE|NN7_CODPGT|NN7_OPERAC|NN7_VLSALD|"

		cNoViewNNY += "NNY_MESEMB|NNY_FILORG|NNY_FILDES|NNY_MESBOL|NNY_DTLFIX|NNY_MESANO|NNY_VMESAN|NNY_IDXNEG|NNY_IDXCTF|NNY_QTDCTR|"
		
		cNoViewNNF += "NNF_CODCTR|NNF_TIPCOM|NNF_QTDCON|NNF_FATCON|NNF_TXMOED|NNF_VLBCOM|NNF_MODCOM|NNF_UNIMED|"
		
		oStruNJR    := FWFormStruct( 2, "NJR",  { |x| !ALLTRIM(x) $ cNoViewNJR})		
		oStruNNY  	:= FWFormStruct( 2, "NNY" , { |x| !ALLTRIM(x) $ cNoViewNNY})
		oStruNN7  	:= FWFormStruct( 2, "NN7" , { |x| !ALLTRIM(x) $ cNoViewNN7} )		
		oStruNNF    := FWFormStruct( 2, "NNF" , { |x| !ALLTRIM(x) $ cNoViewNNF} )	

		oStruNJR:RemoveField("NJR_MOEDAF")
		oStruNJR:RemoveField("NJR_MOEDAR")
	EndIf        

	oView:SetModel( oModel )

    If __lnewNeg 
		//NOVO NEGOCIO	
        //cria a pasta principal
        oView:CreateFolder( "CTRFOLDER")

        //abas folder contrato
        oView:AddSheet('CTRFOLDER', 'PRINCIPAL' , STR0143) // Principal
        oView:AddSheet('CTRFOLDER', 'CADENCIA'  , STR0031) // Cadência	
        oView:AddSheet('CTRFOLDER', 'FINANCEIRO', STR0029) // Financeiro       
        oView:AddSheet('CTRFOLDER', 'CORRETORA' , STR0033) // Corretoras
        oView:AddSheet('CTRFOLDER', 'CREDITO' ,   STR0032) // Cessão de Crédito
        oView:AddSheet('CTRFOLDER', 'TROCA' ,     STR0082) // Cessão de Crédito

        //view master
	    oView:AddField( "VIEW_NJR", oStruNJR, "NJRUNICO")
	    oView:CreateHorizontalBox( "BOX-PRIN" , 100, , , "CTRFOLDER", "PRINCIPAL" )
	    oView:SetOwnerView( "VIEW_NJR", "BOX-PRIN" )
	    oView:EnableTitleView( "VIEW_NJR" )	

	    //view cadência
		oView:AddGrid( "VIEW_NNY", oStruNNY,  "NNYUNICO")
		oView:AddGrid( "VIEW_N9A", oStruN9A, "N9AUNICO")
		oView:CreateHorizontalBox( "BOX-TOP-ENT" , 50, , , "CTRFOLDER", "CADENCIA" )
		oView:CreateHorizontalBox( "BOX-BOT-ENT" , 50, , , "CTRFOLDER", "CADENCIA" )
		oView:SetOwnerView( "VIEW_NNY", "BOX-TOP-ENT" )
		oView:SetOwnerView( "VIEW_N9A", "BOX-BOT-ENT" )
		oView:EnableTitleView( "VIEW_NNY") 
		oView:EnableTitleView( "VIEW_N9A") 
		oView:AddIncrementField( "VIEW_NNY", "NNY_ITEM"   )
		oView:AddIncrementField( "VIEW_N9A", "N9A_SEQPRI" )		
	
		//view financeiro
		oView:AddGrid( "VIEW_NN7", oStruNN7, "NN7UNICO")
		oView:AddGrid( "VIEW_N84", oStruN84, "N84UNICO")
		oView:CreateHorizontalBox( "BOX-TOP-FIN" , 50, , , "CTRFOLDER", "FINANCEIRO" )
		oView:CreateHorizontalBox( "BOX-BOT-FIN" , 50, , , "CTRFOLDER", "FINANCEIRO" )
		oView:SetOwnerView( "VIEW_N84", "BOX-TOP-FIN" )
		oView:SetOwnerView( "VIEW_NN7", "BOX-BOT-FIN" )
		oView:EnableTitleView( "VIEW_N84") 
		oView:EnableTitleView( "VIEW_NN7") 
		oView:SetViewProperty("NN7UNICO", "ONLYVIEW")              
        oView:SetNoDeleteLine("NN7UNICO")
		//increment fields
		oView:AddIncrementField( "VIEW_N84", "N84_SEQUEN" )

        //view Corretora
        oView:AddGrid( "VIEW_NNF", oStruNNF,  "NNFUNICO")				
        oView:CreateHorizontalBox( "BOX-TOP-COR" , 100, , , "CTRFOLDER", "CORRETORA" )		
        oView:SetOwnerView( "VIEW_NNF", "BOX-TOP-COR" )	
        oView:EnableTitleView( "VIEW_NNF" )		
        //increment fields
        oView:AddIncrementField( "VIEW_NNF", "NNF_ITEM"   ) 

        //view Cessão de crédito
        oView:AddGrid( "VIEW_NNG", oStruNNG,  "NNGUNICO")				
        oView:CreateHorizontalBox( "BOX-TOP-CES" , 100, , , "CTRFOLDER", "CREDITO" )		
        oView:SetOwnerView( "VIEW_NNG", "BOX-TOP-CES" )	
        oView:EnableTitleView( "VIEW_NNG" )		        
        oView:AddIncrementField( "VIEW_NNG", "NNG_ITEM" )

        //view Troca
        oView:AddGrid( "VIEW_NKO", oStruNKO,  "NKOUNICO")				
        oView:CreateHorizontalBox( "BOX-TOP-TRO" , 100, , , "CTRFOLDER", "TROCA" )		
        oView:SetOwnerView( "VIEW_NKO", "BOX-TOP-TRO" )	
        oView:EnableTitleView( "VIEW_NKO" )		        
        oView:AddIncrementField( "VIEW_NKO", "NKO_ITEM" )
        oView:SetViewProperty('VIEW_NKO' , 'ONLYVIEW' )

		//Impostos
		If __lExibeImp
			 //view impostos
			oView:AddSheet('CTRFOLDER', 'IMPOSTO' ,   STR0153) // Impostos
			oStruNKH  := FWFormStruct( 2, "NKH", { |x| !ALLTRIM(x) $ 'NKH_CODCTR'} )
			oView:AddGrid( "VIEW_NKH", oStruNKH,  "NKHUNICO")				
			oView:CreateHorizontalBox( "BOX-TOP-IMP" , 100, , , "CTRFOLDER", "IMPOSTO" )		
			oView:SetOwnerView( "VIEW_NKH", "BOX-TOP-IMP" )	
			oView:EnableTitleView( "VIEW_NKH" )		        
			oView:AddIncrementField( "VIEW_NKH", "NKH_ITEM" )
		EndIf
	Else
		//MODELO CLASSICO
		oView:AddField("VIEW_NJR", oStruNJR, "NJRUNICO" )
        oView:AddGrid( "VIEW_NN7", oStruNN7, "NN7UNICO" )
        oView:AddGrid( "VIEW_NNY", oStruNNY, "NNYUNICO" )
        oView:AddGrid( "VIEW_NNG", oStruNNG, "NNGUNICO" )
        oView:AddGrid( "VIEW_NNF", oStruNNF, "NNFUNICO" )
        oView:AddGrid( "VIEW_NKO", oStruNKO, "NKOUNICO" )
        
		oView:SetViewProperty('VIEW_NKO' , 'ONLYVIEW' )

        oView:AddIncrementField( "VIEW_NN7", "NN7_ITEM" )
        oView:AddIncrementField( "VIEW_NN7", "NN7_PARCEL" )
        oView:AddIncrementField( "VIEW_NNY", "NNY_ITEM" )
        oView:AddIncrementField( "VIEW_NNG", "NNG_ITEM" )
        oView:AddIncrementField( "VIEW_NNF", "NNF_ITEM" )
        oView:AddIncrementField( "VIEW_NKO", "NKO_ITEM" )		
        
		oView:CreateHorizontalBox( "SUPERIOR" , 60 )
        oView:CreateHorizontalBox( "INFERIOR" , 40 )

        oView:CreateFolder( "GRADES", "INFERIOR")
        oView:AddSheet( "GRADES", "PASTA01", OemToAnsi( STR0029) ) //"Financeiro"
        oView:AddSheet( "GRADES", "PASTA03", OemToAnsi( STR0031) ) //"Cadencia"
        oView:AddSheet( "GRADES", "PASTA04", OemToAnsi( STR0032) ) //"Cessão de Credito"
        oView:AddSheet( "GRADES", "PASTA05", OemToAnsi( STR0033) ) //"Corretoras"
        oView:AddSheet( "GRADES", "PASTA06", OemToAnsi( STR0082) ) //"Troca"		

        oView:CreateHorizontalBox( "PASTA_NN7", 100, , , "GRADES", "PASTA01" )
        oView:CreateHorizontalBox( "PASTA_NNY", 100, , , "GRADES", "PASTA03" )
        oView:CreateHorizontalBox( "PASTA_NNG", 100, , , "GRADES", "PASTA04" )
        oView:CreateHorizontalBox( "PASTA_NNF", 100, , , "GRADES", "PASTA05" )
        oView:CreateHorizontalBox( "PASTA_NKO", 100, , , "GRADES", "PASTA06" )		
        
		oView:SetOwnerView( "VIEW_NJR", "SUPERIOR" )
        oView:SetOwnerView( "VIEW_NN7", "PASTA_NN7" )
        oView:SetOwnerView( "VIEW_NNY", "PASTA_NNY" )
        oView:SetOwnerView( "VIEW_NNG", "PASTA_NNG" )
        oView:SetOwnerView( "VIEW_NNF", "PASTA_NNF" )
        oView:SetOwnerView( "VIEW_NKO", "PASTA_NKO" )
        
		oView:EnableTitleView( "VIEW_NJR" )
        oView:EnableTitleView( "VIEW_NN7" )
        oView:EnableTitleView( "VIEW_NNY" )
        oView:EnableTitleView( "VIEW_NNG" )
        oView:EnableTitleView( "VIEW_NNF" )
        oView:EnableTitleView( "VIEW_NKO" )

		If __lExibeImp
			oStruNKH  := FWFormStruct( 2, "NKH", { |x| !ALLTRIM(x) $ 'NKH_CODCTR'} )
			oView:AddGrid( "VIEW_NKH", oStruNKH,  "NKHUNICO")	
			oView:AddIncrementField( "VIEW_NKH", "NKH_ITEM" )
			oView:AddSheet( "GRADES", "PASTA07", OemToAnsi( STR0153) ) //" Impostos da TES"
			oView:CreateHorizontalBox( "PASTA_NKH", 100, , , "GRADES", "PASTA07" )
			oView:SetOwnerView( "VIEW_NKH", "PASTA_NKH" )	
			oView:EnableTitleView( "VIEW_NKH" )	
		EndIf

	EndIf
	
	oStruNJR:SetProperty( "NJR_QTDINI" 	, MVC_VIEW_CANCHANGE, .F.)
	
	//--                    Adicionando Grupos na view                      --//
	oStruNJR:AddGroup( 'GRUPOA', '', '', 1 )
	oStruNJR:AddGroup( 'GRUPOB', Chr(09), '', 2 )
	oStruNJR:AddGroup( 'GRUPOC', Chr(09), '', 3 )
	oStruNJR:AddGroup( 'GRUPOD', Chr(09), '', 4 )
	oStruNJR:AddGroup( 'GRUPOE', '', '', 5 )

	//-- Atribuindo Todos os Campos ao Grupo D (campos que fica em outras abas) --//
    AGRXSTPROP(oStruNJR, "*" , MVC_VIEW_GROUP_NUMBER , 'GRUPOE') // Verifica se o campo existe na estrutura antes de adicionar a view

	//-- Atribuindo os campos ao Grupo A--//
    aFields := Separa("NJR_CODCTR;NJR_ULTALT;NJR_DESCRI;NJR_DATA;NJR_CTREXT;NJR_CODENT;NJR_LOJENT;NJR_NOMENT;NJR_NLJENT;NJR_CODTER;NJR_LOJTER;NJR_NOMTER;NJR_NLJTER", ";")
    For nIt := 1 To Len(aFields)
        AGRXSTPROP(oStruNJR, aFields[nIt] , MVC_VIEW_GROUP_NUMBER , 'GRUPOA') // Verifica se o campo existe na estrutura antes de adicionar a view
    Next nIt

    AGRXSTPROP(oStruNJR, "NJR_TIPMER" , MVC_VIEW_GROUP_NUMBER , 'GRUPOA')

	//-- Atribuindo os campos ao Grupo B --//
    aFields := Separa("NJR_CODSAF;NJR_TALHAO;NJR_CODPRO;NJR_DESPRO;NJR_TABELA;NJR_DESTAB;NJR_GENMOD", ";")
    For nIt := 1 To Len(aFields)
        AGRXSTPROP(oStruNJR, aFields[nIt] , MVC_VIEW_GROUP_NUMBER , 'GRUPOB')
    Next nIt

	//-- Atribuindo os campos ao Grupo C --// claudineia testar e rever
    aFields := Separa("NJR_OPETRI;NJR_OPEFUT;NJR_CODOPE;NJR_CODRPC;NJR_OPEFIS;NJR_TESEST;NJR_TESFIN;NJR_TIPEMB;NJR_MSGNFS;NJR_OBSADT;NJR_ITVDAP;NJR_TRANSF", ";")
    For nIt := 1 To Len(aFields)
        AGRXSTPROP(oStruNJR, aFields[nIt] , MVC_VIEW_GROUP_NUMBER , 'GRUPOC')
    Next nIt
    
	AGRXSTPROP(oStruNJR, "NJR_TIPOCL" 	, MVC_VIEW_GROUP_NUMBER , 'GRUPOC')
    AGRXSTPROP(oStruNJR, "NJR_CLVL" 		, MVC_VIEW_GROUP_NUMBER , 'GRUPOC')
    AGRXSTPROP(oStruNJR, "NJR_CODFIN" 	, MVC_VIEW_GROUP_NUMBER , 'GRUPOC')
    AGRXSTPROP(oStruNJR, "NJR_DESFIN" 	, MVC_VIEW_GROUP_NUMBER , 'GRUPOC')

    AGRXSTPROP(oStruNJR, "NJR_OBSADT" , MVC_VIEW_ORDEM , 'B9')
    AGRXSTPROP(oStruNJR, "NJR_TIPOCL" , MVC_VIEW_ORDEM , 'C0')
	
	//-- Atribuindo os campos ao Grupo D --//
    aFields := Separa("NJR_MODELO;NJR_MODBAS;NJR_STSASS;NJR_STSFIS;NJR_STSFIN;NJR_STSEST;NJR_STATUS", ";")
    For nIt := 1 To Len(aFields)
        AGRXSTPROP(oStruNJR, aFields[nIt] , MVC_VIEW_GROUP_NUMBER , 'GRUPOD')
    Next nIt

	oView:AddUserButton(STR0090 ,'',{|oView| OGA280Prc()})  //"Composiçao de Preços"
	oView:AddUserButton(STR0106 ,'',{|| OGC003( oView:GetModel("NJRUNICO"):GetValue("NJR_CODCTR")) } ) //"Romaneios"

	oView:SetCloseOnOk( {||.t.} )

Return( oView )

/** {Protheus.doc} ValTABELA
Funçao que valida o campo da tabela de descontos utilizada no contrato

@param:     oFields - Field da tabela NJ0
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA280 - Contratos
*/
Static Function ValCpoFis( oField )
	Local oModel        as object
	Local oGrdNKH       as object
	Local cItem         as char
	Local nLinha        as numeric
	Local nCount        as numeric
	Local nX            as numeric
	Local aRetorno      as array

	If __lExibeImp
		NJ0->(dbSetOrder( 1 ))
		NJ0->(dbSeek( xFilial( "NJ0" ) + oField:GetValue( "NJR_CODENT" ) + oField:GetValue( "NJR_LOJENT" ) ))

		SA2->(dbSetOrder( 1 ))
		SA2->(dbSeek( xFilial( "SA2" ) + NJ0->( NJ0_CODFOR ) + NJ0->( NJ0_LOJFOR ) ))
		
		oModel      := oField:GetModel()
		oGrdNKH     := oModel:GetModel( "NKHUNICO" )
		nLinha      := oGrdNKH:Length()
		nCount      := 0
		cTipo       := "E"
		cCliFor     := NJ0->NJ0_CODFOR
		cLojaCF     := NJ0->NJ0_LOJFOR
		cTipoCF     := "F"
		aRetorno    := {}

		cCodPro     := oField:GetValue( "NJR_CODPRO" )
		cQtdPro     := oField:GetValue( "NJR_QTDINI" )
		If cPaisLoc == "PAR" .Or. cPaisLoc == "ARG"
			cVlrUni     := oField:GetValue( "NJR_VLRBAS" )
		Else
			cVlrUni     := oField:GetValue( "NJR_VLRUNI" )
		EndIf
		cVlrTot     := oField:GetValue( "NJR_VLRTOT" )
		If .Not. Empty( oField:GetValue( "NJR_TESEST" ) )
			cTes    := oField:GetValue( "NJR_TESEST" )
		Else
			cTes    := oField:GetValue( "NJR_TESFIN" )
		EndIf

		If !Empty(cTes)
			aRetorno    := OGC001F( cTipo, "N", cCliFor, cLojaCF, cTipoCF, cCodPro, cQtdPro, cVlrUni, cVlrTot, cTes )[1]
		EndIf

		If Len( aRetorno ) > 1

			oGrdNKH:SetNoInsert( .f. )
			oGrdNKH:SetNoDelete( .f. )

			For nX := 2 to Len( aRetorno )

				nCount++
				cItem := StrZero( nCount, TamSX3( "NKH_ITEM" )[1] )
				If nCount > nLinha
					oGrdNKH:AddLine()
				Else
					oGrdNKH:GoLine( nCount )
					If oGrdNKH:IsDeleted()
						oGrdNKH:UnDeleteLine()
					EndIf
				EndIf
				oGrdNKH:SetValue( "NKH_ITEM"  , cItem )
				oGrdNKH:SetValue( "NKH_CODIMP", aRetorno[nX, 1] )
				oGrdNKH:SetValue( "NKH_DESIMP", aRetorno[nX, 2] )
				oGrdNKH:SetValue( "NKH_VLRBAS", aRetorno[nX, 3] )
				oGrdNKH:SetValue( "NKH_VLRALQ", aRetorno[nX, 4] )
				oGrdNKH:SetValue( "NKH_VLRIMP", aRetorno[nX, 5] )

			Next nX

			oGrdNKH:SetNoInsert( .t. )
			oGrdNKH:SetNoDelete( .t. )

		Else
			oGrdNKH:SetNoDelete( .F. )
			oGrdNKH:DelAllLine()
			oGrdNKH:SetNoDelete( .T. )
		EndIf
	EndIf
Return( .t. )

/** {Protheus.doc} ValPosNNG
Função que valida o gride de dados após a perda do foco ou a confirmação do modelo

@param:     oGride - Gride do modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     01/01/2015     Refeito 07/07/2016   Inicio Luiz Kolling
@Uso:       OGA280 - Contratos
*/
Static Function ValPosNNG( oGride )
	Local oModel	  := FwModelActive()
	Local nQtdTot  := oModel:GetValue("NJRUNICO","NJR_QTDCTR")
	Local nVlrTot  := oModel:GetValue("NJRUNICO","NJR_VLRTOT")
	Local vVetSoma := AGRSOMACOLSM(oGride,{"NNG_QTDCSS","NNG_VLRCSS"})
	Local nSomaQtd := vVetSoma[1]
	Local nSomaVlr := vVetSoma[2]

	If oModel:GetValue("NJRUNICO","NJR_MODELO") == "3" .And. Empty(nSomaQtd) .And. Empty(nSomaVlr)
		Return .t.
	EndIf	
	If nSomaQtd > nQtdTot .Or. nSomaVlr > nVlrTot
		Help(,,STR0034,,STR0043,1,0) //"AJUDA"###"As quantidades e valores da Cessão não podem ser maiores que do Contrato!"
		Return .f.
	EndIf
Return .t.

/** {Protheus.doc} ValPosNNF
Funçao que valida o gride de dados após a perda do foco ou a confirmaçao do modelo

@param:     oGride - Gride do modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Jose Leite de Barros Neto
@since:     12/07/2013
@Uso:       OGA280 - Contratos
*/
Static Function ValPosNNF( oGride )
	Local lRetorno  := .t.
	//  Local oModel    := FwModelActive()
	Local nLinha    := 0
	Local nX        := 0
	Local cCorretora:= ""
	Local cCorretor := ""
	If .Not. __lnewNeg //Validação apenas para clássico.
		nLinha := oGride:GetLine()
		For nX := 1 to oGride:Length()
			oGride:GoLine( nX )
			If .Not. oGride:IsDeleted()
				cCorretora  := oGride:GetValue( "NNF_CODENT" )
				cCorretor   := oGride:GetValue( "NNF_CDCORR" )
				If Empty(cCorretora) .And. .Not. Empty(cCorretor)
					lRetorno := .F.
				ElseIf .Not. Empty(cCorretora) .And. Empty(cCorretor)
					lRetorno := .F.
				EndIf

			EndIf
		Next nX
		oGride:GoLine( nLinha )

		If .Not. lRetorno
			Help( , , STR0034, , STR0044, 1, 0 ) //"AJUDA"###"Verifique se o Codigo da corretora e codigo do corretor foram preenchidos!"
		EndIf
	EndIf
Return( lRetorno )


/** {Protheus.doc} VldActveMd
Função que valida a inicialização do modelo de dados

@param:     oModel - Modelo de dados
@param:     nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA280 - Contratos
*/
Static Function VldActveMd( oModel, nOperation )
	Local lRetorno  := .t.
	Local nQtdPre   := IIF(NJR->( NJR_CTRLLG ) == "1" ,NJR->( NJR_AUTENT ) + NJR->( NJR_AUTSAI ), 0) //SE TEM AUTORIZAÇÕES 

   IF nOperation == MODEL_OPERATION_INSERT
		If __lnewNeg .AND. !(IsInCallStack("OGX700CTR") .OR. IsInCallStack("OGX700ACTR"))
		    If !__lRegOpcional				
                Help(" ", 1, "OGA280INSR ")//Nao é possivel incluir contratos. Para incluir contratos utilize a rotina Registro de Negï¿½cios.
			    lRetorno := .f.
            EndIf
		EndIF
	EndIF

	//--Montando a Relacao entre o Ctr.Compra e os Itens do Acordo de Troca ( Relacao dinamica )--
	aRelacNKO:={}
	cNKO_TRCNUM := fGetTrcNum( )
	IF Empty(cNKO_TRCNUM)
		cNKO_TRCNUM := '0'
	EndIF

	aAdd(ArelacNKO,{ "NKO_FILIAL", "fwxFilial( 'NKO' )"     } )
	aAdd(ArelacNKO,{ "NKO_TRCNUM", "'"+ cNKO_TRCNum + "'"      } )
	oModel:SetRelation( "NKOUNICO", aRelacNKO, NKO->( IndexKey( 1 ) ) )
	//--Montando a Relacao entre o Ctr.Compra e os Itens do Acordo de Troca--    

	// Validação de assinatura do ctrato
	IF nOperation == MODEL_OPERATION_UPDATE .and. lRetorno
		/* Permite alterar o indice qdo ainda não tiver qtidade fisica entregue */
		if (cPaisLoc != "PAR" .and. cPaisLoc != "ARG") //dekalpar
			oModel:GetModel("NJRUNICO"):GetStruct():SetProperty( 'NJR_CODIDX' , MODEL_FIELD_WHEN, {|| NJR->NJR_QTEFCO == 0 } )       
		EndIf //dekalpar
		
		If NJR->NJR_STSASS == 'F'
			Help( ,, STR0034,, STR0099, 1, 0 )  //"AJUDA"###"Não é possivel excluir este contrato, pois ja foi confirmado ou esta em execução. Este contrato somente pode ser -Finalizado- ou - Encerrado-."
			lRetorno := .f.
		EndIF
	EndIF

	If nOperation == MODEL_OPERATION_DELETE .and. lRetorno
	    If !(IsInCallStack("OGX700CNEG")) .AND. !Empty(NJR->(NJR_CODNGC))
	 	    cCodNog := NJR->(NJR_CODNGC)
		    AgrHelp(STR0034, STR0128 + cCodNog, STR0129) //"Ajuda"###"Este contrato foi gerado pelo negocio 'Previsto' Para excluir o contrato é necessário rejeitar o negocio'.
			lRetorno := .f.
	
	    ElseIf !(NJR->( NJR_MODELO ) == "1")  // Diferente de Pre-contrato(reg.negocio)
		    If IsInCallStack("OGX700CNEG")
		         Help(" ", 1, "OGA280EXNEG")//Não é possivel rejeitar o negocio,Para Rejeitar o negocio o contrato deve estar em pré contrato	
	            lRetorno := .f.  //Não permite excluir
	        ElseIF NJR->( NJR_STATUS ) <> "P" .Or. NJR->( NJR_QTEFCO ) > 0 .OR.  NJR->( NJR_QTSFCO ) > 0  .OR. nQtdPre > 0 //P=Previsto
				AgrHelp(STR0034, STR0045, STR0156) //"AJUDA"###"Não é possivel excluir este contrato, pois ja foi confirmado ou esta em execuçao. ##Este contrato somente pode ser -Finalizado- ou - Cancelado-."
				lRetorno := .f.
		    EndIf
        ElseIf !IsInCallStack("OGX700CNEG")
	        lRetorno := .f.  //Não permite excluir  
		EndIf
	EndIf

Return( lRetorno )

/** {Protheus.doc} /** {Protheus.doc} ActivateMD
Funçao executada logo apos ativar o modelo de dados

@param:     oModel - Modelo de dados
@param:     nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@author:    Emerson Coelho
@since:     02/08/16
@Uso:       OGA280 - Contratos
*/
Static Function ActivateMD( oModel, nOperation )
	Local oView			:= FwViewActive()    
	Local aArea			:= GetArea()

	// Tratamento para Contratos Automaticos ( Nao permite Alterar a Cadencia , Nao Mostra Aba Financeiro )
	IF NJR->NJR_MODELO == '3'	// Contrato Automatico
		// --- Para Os Ctratos de Compra que são Automaticos a Cadencia /  Financeiro não pode ser alterado
		oModel:GetModel( "NNYUNICO" ):SetNoInsertLine( .t. )
		oModel:GetModel( "NNYUNICO" ):SetNoUpdateLine( .t. )
		oModel:GetModel( "NNYUNICO" ):SetNoDeleteLine( .t. )

		If oView != NIL    // Para os Contratos de Compra do tipo automatico 
			oView:HideFolder('GRADES', FLDPREVFIN ,2) 		// Retira a Folder do Financeiro
		EndIF
	ElseIf nOperation == MODEL_OPERATION_UPDATE .and. ( !(IsInCallStack("OGX700CTR") .OR. IsInCallStack("OGX700ACTR")) .and. !empty(NJR->NJR_CODNGC) .and. !empty(NJR->NJR_VERSAO)) //verifica se tem cod negocio 
			//Validação edição de Prev. Entrega Novo Negócio.	
			//Não permite insert/delete
			oModel:GetModel( "NNYUNICO" ):SetNoInsertLine( .t. )
			oModel:GetModel( "NNYUNICO" ):SetNoDeleteLine( .t. )
	Else
		oModel:GetModel( "NNYUNICO" ):SetNoInsertLine( .F. )
		oModel:GetModel( "NNYUNICO" ):SetNoUpdateLine( .F. )
		oModel:GetModel( "NNYUNICO" ):SetNoDeleteLine( .F. )	
    EndIF   

	RestArea(aArea)
Return( .t. )


/** {Protheus.doc} PreModelo
Funçao que valida o modelo de dados apos a confirmaçao

@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA290 - Contratos de Venda
*/
Static Function PreModelo( oModel )
	Local lRetorno      := .t.
	Local nOperation    := oModel:GetOperation()
	Local cStatus       := oModel:GetValue( "NJRUNICO", "NJR_STATUS" )

	If nOperation == MODEL_OPERATION_UPDATE

		If cStatus $ "E|F"
			Help( , , STR0034, , STR0046, 1, 0 ) //"AJUDA"###"Contrato ja foi Finalizado ou Cancelado! não pode ser alterado."
			lRetorno := .f.
		EndIf

	EndIf

Return( lRetorno )


/** {Protheus.doc} PosModelo
Função que valida o modelo de dados após a confirmação

@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA290 - Contratos de Venda
*/
Static Function PosModelo( oModel )
	Local nOperation    := oModel:GetOperation()
	Local cCodEnt       := oModel:GetValue( "NJRUNICO", "NJR_CODENT" )
	Local cLojEnt       := oModel:GetValue( "NJRUNICO", "NJR_LOJENT" )
	Local cTipo         := oModel:GetValue( "NJRUNICO", "NJR_TIPO" )
	Local cSafra        := oModel:GetValue( "NJRUNICO", "NJR_CODSAF" )
	Local cProd         := oModel:GetValue( "NJRUNICO", "NJR_CODPRO" )
	Local cCtr          := oModel:GetValue( "NJRUNICO", "NJR_CODCTR" )
	Local aRetblock  	:= {}
	Local cProblema     := ''
	Local cSolucao      := ''
	Local lContinua     := .t.
    Local cNegocio      := ''
	
	If nOperation == MODEL_OPERATION_INSERT 
		//Funçao para nao permitir dois contratos com a mesma entidade e safra [OGA390]
		lContinua := OGA390B(xFilial("NJR"), cCodEnt, cLojEnt, cSafra, cProd, cTipo)		
	EndIf

	If __lRegOpcional .and. __lnewNeg .AND. AGRXQTDN9J(cCtr) == 0
		oModel:GetModel("NN7UNICO"):ClearData()
	EndIf

    If __lnewNeg .and. !AGRXNNYNN9(oModel) //valida nos registros das previsões de entrega com as regras fiscais as quantidades
		Return .F.
	EndIf

	If lContinua .AND. (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)
        //Funçao para validar entidade 
		lContinua := AGRXVALENT("F",cCodEnt, cLojEnt) 		

		If lContinua .And. !OGA260CADEN(oModel)
			Return .F.
		EndIf 	
	EndIf

	If nOperation == MODEL_OPERATION_DELETE
		IF !Empty( fGetTrcNum() ) //--Verifica se existe acordo de troca relacionada a este Ctrato de Cpra --//
			Help( , , STR0034, , STR0107, 1, 0 ) //"AJUDA"###"'Contrato nao pode ser excluido pois faz parte de um acordo de troca'
			lContinua := .F.
		EndIf
	EndIf

    If lContinua
		//Se o tipo de mercado for interno(1=Interno;2=Externo) e moeda <> 1, é preciso informa-los	
		If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
			//proteção de fonte
			if oModel:GetModelStruct("NJRUNICO")[3]:OFORMMODELSTRUCT:HasField("NJR_CODNGC")
				cNegocio  	:= oModel:GetValue( "NJRUNICO", "NJR_CODNGC" )
				cVersao   	:= oModel:GetValue( "NJRUNICO", "NJR_VERSAO" )
			endif						
		endif
		
		If !Empty(cNegocio) .and. !Empty(cVersao) .and. !(IsInCallStack("OGX700CTR") .OR. IsInCallStack("OGX700ACTR"))
            lContinua := AGRXVLDNNF(oModel)            
        EndIf
	EndIf
	
	If ExistBlock ("OG280PREGV")
		aRetblock := ExecBlock ("OG280PREGV", .F., .F.)
		lContinua := aRetblock[1]
		cProblema := aRetblock[2]
		cSolucao  := aRetblock[3]
		If ! lContinua 
			oModel:SetErrorMessage( , , oModel:GetId() , "", "", cProblema,cSolucao, "", "")	
		EndIf
	EndIf
	
Return( lContinua )


/** {Protheus.doc} GrvModelo
Funçao que grava o modelo de dados apos a confirmaçao

@param:     oModel - Modelo de dados
@return:    .t. - sempre verdadeiro
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA280 - Contratos
*/
Static Function GrvModelo( oModel )
	Local nOperation    	:= oModel:GetOperation()		
	Local cCodNeg			:= oModel:GetValue( "NJRUNICO", "NJR_CODNGC")
	Local oModelNJR 		:= oModel:GetModel( "NJRUNICO" )	
	Local cCodProd			:= oModelNJR:GetValue("NJR_CODPRO")
	Local isOGA700			:= IsInCallStack("OGA700") .or. IsInCallStack("AGRA720")
	Local cNegocio          := ""
	Local cVersao           := ""
	Local lRet				:= .T.
	Local lN9AModify		:= .F.
	Local lNNYModify		:= .F.
	Local nIt				:= 0
	Local nX				:= 0
	Local nY				:= 0
	Local oModelNNY			:= Nil
	Local oModelN9A			:= Nil
	Local oModelN9D			:= Nil
	Local aFardsUpd			:= {}
	Local aRetMov			:= {}		
	Local oModel700			:= Nil
	Local oModelN7A			:= Nil
	Local oModelN79			:= Nil	
	Local cMsg				:= ""	
	Local lNatureza         := .T.

	//proteçao de fonte
	if oModel:GetModelStruct("NJRUNICO")[3]:OFORMMODELSTRUCT:HasField("NJR_CODNGC")
		cNegocio  	:= oModel:GetValue( "NJRUNICO", "NJR_CODNGC" )
		cVersao   	:= oModel:GetValue( "NJRUNICO", "NJR_VERSAO" )
	endif

    // Verifica se houve modificações nas regras fiscais
	If __lnewNeg 
		oModelNNY	:= oModel:GetModel("NNYUNICO")
		oModelN9A	:= oModel:GetModel("N9AUNICO")
		oModelN9D	:= oModel:GetModel("N9DUNICO") 		
        
        lN9AModify := oModelN9A:IsModified()

		//testa e carrega se foi alterado a NNY, se sim faz o load do OGA700
		If (lNNYModify := oModelNNY:IsModified()) .AND. !isOGA700
			N79->(DbSetOrder(1))
			If N79->(DbSeek(FwXfilial("N79")+cCodNeg))
				oModel700 := FWLoadModel("OGA700")
				
				oModel700:SetOperation(MODEL_OPERATION_UPDATE)
				
				oModelN7A := oModel700:GetModel("N7AUNICO")
				oModelN79 := oModel700:GetModel("N79UNICO")
				
				oModel700:Activate()
			EndIf
		EndIf

		//ajuste realizado para atualizar a N8D apos ajustar a regra fiscal
		If lN9AModify .AND. !isOGA700
			If !AGRTPALGOD(oModelNJR:GetValue("NJR_CODPRO"))
				If !AGRXN8DAut(oModel, NJR->NJR_FILIAL, NJR->NJR_CODCTR,NJR->NJR_TIPFIX)
					Help( , , STR0034, , "Existe mais de uma sequência de quantidades vinculadas de preço. Não é possível determinar qual fixaçao utilizar.", 1, 0 )  //"Existe mais de uma sequência de quantidades vinculadas de preço. Não é possível determinar qual fixaçao utilizar." # "Ajuda"
					Return .f.
				EndIf
			EndIf
		EndIf

		If Empty(oModel:GetValue( "N9AUNICO", "N9A_NATURE"))			
			lNatureza := .F.
		Endif	

		if oModel:GetModel("N84UNICO"):IsModified() .or. oModel:GetModel("N9AUNICO"):IsModified() .or. oModel:GetModel("NJRUNICO"):IsFieldUpdated("NJR_TIPMER")
			if !Empty(cNegocio) .and. !Empty(cVersao) .and. !(IsInCallStack("OGX700CTR") .OR. IsInCallStack("OGX700ACTR"))
				If AGRXVLDN84(oModel) .And. lNatureza 
					If !OGX018(oModel:GetModel("NJRUNICO"):GetValue("NJR_FILIAL"),oModel:GetModel("NJRUNICO"):GetValue("NJR_CODCTR"), .t., oModel )
                        Return .f.
                    EndIF
				endif
			endif
		endif	

	EndIf

	// Gravar Historico Automaticamente
	If nOperation == MODEL_OPERATION_INSERT
		AGRGRAVAHIS(,,,,{"NJR",xFilial("NJR")+oModelNJR:Getvalue('NJR_CODCTR'),"3",STR0011}) //Incluir
	elseIf nOperation == MODEL_OPERATION_UPDATE
		AGRGRAVAHIS(,,,,{"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"4",STR0012}) //Alterar
		lDelTitFin(NJR->NJR_CODCTR,NJR->NJR_CODENT,NJR->NJR_LOJENT)//exclui as previsoes 
	elseIf nOperation == MODEL_OPERATION_DELETE
		AGRGRAVAHIS(,,,,{"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"5",STR0017}) //Excluir
		lDelTitFin(NJR->NJR_CODCTR,NJR->NJR_CODENT,NJR->NJR_LOJENT)//exclui as previsoes 
	Endif

	//Atualiza o Modelo/Status contrato
	AGXSITMOL(oModel)

	If nOperation == MODEL_OPERATION_INSERT .Or. ( nOperation == MODEL_OPERATION_UPDATE .And. oModelNJR:Getvalue('NJR_STATUS')=='P' )

		oModelNJR:LOADVALUE('NJR_QSLFCO', oModelNJR:Getvalue('NJR_QTDCTR') - oModelNJR:Getvalue('NJR_QTEFCO') + oModelNJR:Getvalue('NJR_QTSFCO') )
		oModelNJR:LOADVALUE('NJR_SLDFIS', oModelNJR:Getvalue('NJR_QTDCTR') - oModelNJR:Getvalue('NJR_QTEFIS') + oModelNJR:Getvalue('NJR_QTSFIS') )		

	EndIf

	//--<< Inicio Tratamento Composiçao de Preço >>--
	If empty(cNegocio) .and. empty(cVersao) //nao se aplica a geraçao automatica do contrato pela negociaçao (OGA700)
		IF ( nOperation == MODEL_OPERATION_INSERT .OR.  nOperation == MODEL_OPERATION_UPDATE )
			fGrvComPrc( aGrvNKA , nOperation ) //--<< Grava/Atualiza composiçao de preço >>--
		EndIF
	EndIf
	//--<< Fim    Tratamento Composiçao de Preço >>--    

    If __lnewNeg .AND. nOperation != MODEL_OPERATION_DELETE     
        AGRXCADGRV(oModel)  
    EndIf

	FWFormCommit( oModel ) 

    // Se for o modelo de negócio, o commit foi realizado com sucesso, o tipo do produto for algodão, e as regras fiscais foram modificadas
	// então verifica se houve fardos movidos entre regras fiscais e grava os mesmos.
	If AGRTPALGOD(cCodProd) .AND. lN9AModify
		For nIt := 1 To oModelNNY:Length()
			oModelNNY:GoLine(nIt)
			If !oModelNNY:IsDeleted()
				For nX := 1 To oModelN9A:Length()
					oModelN9A:GoLine(nX)
					If !oModelN9A:IsDeleted()
						For nY := 1 To oModelN9D:Length()
							oModelN9D:GoLine(nY)
							// Fardos que não estão deletado e estão na regra porem vieram de outra regra fiscal
							If !oModelN9D:IsDeleted() .AND. !Empty(oModelN9D:GetValue("N9D_FARDO"));
								.AND. oModelN9D:GetValue("N9D_ITEREF") != oModelN9A:GetValue("N9A_SEQPRI")

								aAdd(aFardsUpd, {  {{"N9D_ITEREF", oModelN9A:GetValue("N9A_SEQPRI")}}, ;
									/* Filial do fardo */			{{oModelN9D:GetValue("N9D_FILIAL")}, ; 	
									/* Filial de origem */			{oModelN9D:GetValue("N9D_FILORG")}, ; 	
									/* Safra */						{oModelN9D:GetValue("N9D_SAFRA")}, ; 	
									/* Etiqueta */					{oModelN9D:GetValue("N9D_FARDO")}, ;	
									/* 02 - Reserva - Take-Up */	{"02"}, ;									
									/* Ativo */						{"2"}, ;									
									/* Código do Contrato */		{oModelN9D:GetValue("N9D_CODCTR")}}   })	
							EndIf
						Next nY
					EndIf
				Next nX
			EndIf
		Next nIt

		If !Empty(aFardsUpd)
			aRetMov := AGRMOVFARD(, 2, 2, , aFardsUpd) // Grava os fardos movidos entre take-ups
		EndIf
	EndIf

    //refaz o loop na NNY para todos os produtos.
	If lRet .AND. __lnewNeg .AND. !isOGA700
		//atualmente, se vc muda a filial de origem no contrato ele nao altera no negocio
		//dessa forma, se for um contrato a fixar, toda fixação vai ser feita sobe a filial
		//de origem do negocio e nao do contrato.
		//ajuste foi realizado dessa forma para atender a demanda de prazo da SLC e deve se analisado.
		
		For nIt := 1 To oModelNNY:Length()
			oModelNNY:GoLine(nIt)
			If !oModelNNY:IsDeleted() .AND. lNNYModify .AND. ValType(oModelN7A) == "O"
				
				If oModelN7A:SeekLine( { {"N7A_CODCAD",oModelNNY:GetValue("NNY_ITEM", nIt) } } )
					oModelN7A:LoadValue("N7A_FILORG", oModelNNY:GetValue("NNY_FILORG", nIt))
				endif
					
				oModelN7A:GoLine(nIt) //acompanha a linha da NNY
				If oModelNNY:GetValue("NNY_DATINI") == oModelN7A:GetValue("N7A_DATINI") .AND.;
				   oModelNNY:GetValue("NNY_DATFIM") == oModelN7A:GetValue("N7A_DATFIM")
					oModelN7A:LoadValue("N7A_FILORG", oModelNNY:GetValue("NNY_FILORG"),nIt)
				EndIf
			EndIf
		Next nIt
		
		If lNNYModify .AND. ValType(oModel700) == "O"
			If oModel700:VldData()    // Valida o Model
				oModel700:CommitData() // Realiza o commit
				oModel700:DeActivate() // Desativa o model
				oModel700:Destroy() // Destroi o objeto do model
			Else
				cMsg := oModel700:GetErrorMessage()[6]
				Help( ,, STR0034,,cMsg, 1, 0 ) //"Ajuda"
			EndIf
		EndIf
	EndIf

	If ExistBlock( "OG331APG" )
		ExecBlock( "OG331APG", .f., .f. )
	EndIf

    If __lAprAuto .AND. nOperation == MODEL_OPERATION_UPDATE .AND. !IsInCallStack("OGA700") .AND. !IsInCallStack("OGC020")
		OGA280C(,,,.f.)
	EndIf

Return( .t. )


/** {Protheus.doc} OGA280C
Rotina para que confirmaçao do contrato para que o mesmo possa ser utilizado

@param:     Nil
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       SIGAAGR - Originaçao de Graos
*/
Function OGA280C( cAlias, nReg, nAcao, lMsgConfir )
	Local aAreaAtu      := GetArea()
	Local lContinua     := .t.
	Local aFina050      := {}
	Local lRetorno      := .T.
	Local nValor        := 0
    Local cNegocio      := NJR->NJR_CODNGC
	Local cVersao       := NJR->NJR_VERSAO
	Local aLinVncAux2   := {}
	Local aVncCPag	    := {}
	Local  cE2Parcel    :=""
	Local nRet          := 1
	Local cQuery        := ''
	Local cAliasNN7 	:= GetNextAlias()

    Default lMsgConfir  := .t.

	Private lMsErroAuto := .f.

    If __lRegOpcional .and. __lnewNeg .and. NJR->NJR_TIPFIX = '2' .and. EMPTY(cNegocio) .AND. EMPTY(cVersao)  //A FIXAR
		AGRXCNGC(NJR->NJR_CODCTR, NIL, .F.)
	EndIf
    
    If !AGRXVLDVLR()
        Return .F.
    EndIf

	If cPaisLoc == "PAR" .Or. cPaisLoc == "ARG"
		nValor := NJR->NJR_VLRBAS
	Else
		nValor := NJR->NJR_VLRUNI
	EndIf    

    if !empty(cNegocio) 
		If !AGRXValN84()
			Return .F.
		EndIf
	Endif

	cQuery := " SELECT NN7_DTVENC "
	cQuery +=   " FROM "+RetSqlName("NN7")+" NN7		               "
	cQuery +=  " WHERE NN7.NN7_FILIAL 	= '" + xFilial( "NN7" )    + "'"
	cQuery +=    " AND NN7.NN7_CODCTR   = '" + NJR->( NJR_CODCTR ) + "'"
	cQuery +=    " AND NN7.NN7_DTVENC   < '" + DToS(dDatabase)     + "'"
	cQuery +=    " AND D_E_L_E_T_  =  ' '"
	cQuery := ChangeQuery(cQuery)		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cAliasNN7),.F.,.T.)		
	
	dbSelectArea((cAliasNN7))
	(cAliasNN7)->( dbGoTop() )
	IF (cAliasNN7)->( .NOT. Eof() )
	    Help( ,,STR0031,,STR0133, 1, 0 ) //"AJUDA"###"Contrato nao pode ser confirmado. Data de vencimento da previsão financeira anterior a data atual."
		Return .F.		
	EndIF 
	(cAliasNN7)->( dbCloseArea() )

	If __lnewNeg
    	AGRXVLDN9A(@lRetorno, @lContinua, lMsgConfir)
	endif
	
	If lContinua
        If NJR->( NJR_MODELO ) = "1"
            Help( ,,STR0034,, STR0047, 1, 0 ) //"AJUDA"###"Pre-Contratos nao podem ser confirmados, altere para Contrato para depois confirmar."
			Return .F.
        ElseIf __lnewNeg .and. (.Not. nValor > 0 .OR. AGRXVALFIX(NJR->NJR_CODCTR,.T.) ) .and. (cPaisLoc == "BRA" .or. ((cPaisLoc == "PAR" .or. cPaisLoc == "ARG") .and. EMPTY(NJR->NJR_CODIDX))) .and. !(!empty(cNegocio) .and. !empty(cVersao) .and. NJR->NJR_TIPFIX == "2") //validaçao oga700 - negocios a fixar
            AGRHELP(STR0034,STR0159,STR0160) //##Help ##Não há fixação de preço para o contrato. Composição de preço não gerada. ##Contrato nao pode ser confirmado.Valor unitario não é válido. Informe composição de preços.
			Return .F.
        ElseIf !__lnewNeg .and. empty(cNegocio) .and. empty(cVersao) .AND. NJR->NJR_TIPFIX != "2" .AND. AGRXVALFIX(NJR->NJR_CODCTR,.T.);
				.and. (cPaisLoc == "BRA" .or. ((cPaisLoc == "PAR" .or. cPaisLoc == "ARG") .and. EMPTY(NJR->NJR_CODIDX))) 
			AGRHELP(STR0034,STR0159,STR0096) //##Help ##Não há fixação de preço para o contrato. Composição de preço não gerada. ##Contrato nao pode ser confirmado.Valor unitario não é válido. Informe composição de preços.
			Return .F.	
		ElseIf Empty(cNegocio) .And. .Not. AGRXTOTFIN( NJR->( NJR_CODCTR ), NJR->( NJR_VLRTOT ))   //"A soma das quantias nos itens dos Titulos do Contrato esta divergente do Contrato!"
            Return .F.
        Else
            If NJR->( NJR_MODELO ) $ "2|3" .And. NJR->( NJR_STATUS ) = "P"
                
				If .NOT. OGXN8MVLD() //validação campo N8M
					Return .F.
				EndIf
				
				// Nao permite confirmar se houver outro contrato Confirmado ou Iniciado com a mesma Entidade e Safra
                If .not. OGA390B(xFilial("NJR"), NJR->( NJR_CODENT ) , NJR->( NJR_LOJENT ) , NJR->( NJR_CODSAF ), NJR->( NJR_CODPRO ) , NJR->( NJR_TIPO ) )
                	Return .F.
                Endif

                //#########################################################################
                //### A ocorrencia 23 (ACS), verifica se o usuario podera ou nao   		###
                //### efetuar substituicao de titulos provisorios.                		###
                //#########################################################################
                IF  !ChkPsw( 23 )
                    Help( ,,STR0034,, STR0125 , 1, 0 )	//"Contrato nao confirmado! Usuario nao possui acesso financeiro!"
                    Return .F.
                EndIf

                //"Deseja realmente confirmar o contrato?"
                If !__lAutomato
                    nRet := AGRGRAVAHIS(STR0048,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"N") 
                EndIf

                If nRet = 1
                    BEGIN TRANSACTION
						if AGRTPALGOD( NJR->(NJR_CODPRO)) .and. __lnewNeg //calcula ágio e deságio
                            	Processa({|| OGX016(FwxFilial("NJR"), NJR->(NJR_CODCTR)) }, "Calculando Ágio/Deságio...")		
                        endif	

                        if !empty(cNegocio) .and. !empty(cVersao)  //novos negócios	
                            //Recalcula Valores da regra FISCAL e recria as previsões
                            OGX055(xFilial("NJR"), NJR->NJR_CODCTR)
                        else
                            NJ0->( dbSetOrder( 1 ) )
                            NJ0->( dbSeek( xFilial( "NJ0" ) + NJR->( NJR_CODENT + NJR_LOJENT ) ) )

                            /** Gera titulos provisorios no financeiro */
                            cPrefixo    	:= PadR( "CTR", TamSX3( "E2_PREFIXO" )[1] )
                            cNumero 	:= PadR( NJR->( NJR_CODCTR ), TamSX3( "E2_NUM" )[1] )
                            cTipTit    	:= PadR( "PR", TamSX3( "E2_TIPO" )[1] )

                            NN7->( dbSetOrder( 1 ) )
                            NN7->( dbSeek( xFilial( "NN7" ) + NJR->( NJR_CODCTR ) ) )
                            While .Not. NN7->( Eof() ) .And. NN7->( NN7_FILIAL ) = xFilial( "NN7" ) .And. NN7->( NN7_CODCTR ) = NJR->( NJR_CODCTR )
                                //--verifica a entidade informada na NN7
                                NJ0->( dbSetOrder( 1 ) )

                                if	NJ0->( dbSeek( xFilial( "NJ0" ) + NN7->( NN7_CODFAV + NN7_LOJFAV ) ) )
                                    cE2Parcel := PadR(Alltrim(NN7->NN7_PARCEL), TamSX3( "E2_PARCELA" )[1] )
                                    nVlrCrz := xMoeda( NN7->( NN7_VALOR ), NJR->( NJR_MOEDA  ), 1, dDataBase )

                                    aFina050 := {}
                                    aAdd( aFina050, { "E2_PREFIXO" , cPrefixo                   , Nil } )
                                    aAdd( aFina050, { "E2_NUM"     , cNumero                    , Nil } )
                                    aAdd( aFina050, { "E2_PARCELA" , NN7->( NN7_PARCEL )        , Nil } )
                                    aAdd( aFina050, { "E2_TIPO"    , cTipTit                    , Nil } )
                                    aAdd( aFina050, { "E2_FORNECE" , NJ0->( NJ0_CODFOR ) 		, Nil } )
                                    aAdd( aFina050, { "E2_LOJA"    , NJ0->( NJ0_LOJFOR ) 		, Nil } )
                                    aAdd( aFina050, { "E2_EMISSAO" , dDatabase                  , Nil } )
                                    aAdd( aFina050, { "E2_VENCTO"  , NN7->( NN7_DTVENC )        , Nil } )
                                    aAdd( aFina050, { "E2_VALOR"   , NN7->( NN7_VALOR  )        , Nil } )
                                    aAdd( aFina050, { "E2_MOEDA"   , NJR->( NJR_MOEDA  )        , Nil } )
                                    aAdd( aFina050, { "E2_VLCRUZ"  , nVlrCrz                    , Nil } )
                                    aAdd( aFina050, { "E2_HIST"    , STR0050                    , Nil } ) 	//"Tit. Prov. Ctr. Orig."
                                    aAdd( aFina050, { "E2_ORIGEM"  , "OGA280"                   , Nil } )

                                    If .Not. Empty(NN7->( NN7_NATURE ))
                                        aAdd( aFina050, { "E2_NATUREZ" , NN7->( NN7_NATURE )    , Nil } )
                                    EndIf
                                    If .Not. Empty(NN7->( NN7_CCD ))
                                        aAdd( aFina050, { "E2_CCD" , NN7->( NN7_CCD )          	, Nil } )
                                    EndIf

                                    aLinvncAux2 := {}
									aadd( aLinvncAux2, { "N8M_FILIAL"    	, FwXfilial('N8M') 				} )
									aadd( aLinvncAux2, { "N8M_PREFIX"    	, cPrefixo						} )
									aadd( aLinvncAux2, { "N8M_NUM"    	, cNumero 					    } )
									aadd( aLinvncAux2, { "N8M_PARCEL"    	, cE2Parcel						} )
									aadd( aLinvncAux2, { "N8M_TIPO"    	, cTipTit					    } )
									aadd( aLinvncAux2, { "N8M_FORNEC"    	, NJ0->( NJ0_CODFOR )			} )
									aadd( aLinvncAux2, { "N8M_LOJA"    	, NJ0->( NJ0_LOJFOR )		    } )
									aadd( aLinVncAux2, { "N8M_CODCTR"    	, NJR->NJR_CODCTR				} )
									aadd( aLinVncAux2, { "N8M_CODSAF"	    , NJR->NJR_CODSAF				} )
									aadd( aLinVncAux2, { "N8M_CODROM"    	, ''			                } )
									aadd( aLinVncAux2, { "N8M_ITEROM"   	, ''				            } )
									aadd( aLinVncAux2, { "N8M_ITEMFX"   	, ''							} )
									aadd( aLinVncAux2, { "N8M_ORDTRA"    	, ''							} )
									aadd( aLinVncAux2, { "N8M_ORPGRC"    	, ''							} )
									aadd( aLinVncAux2, { "N8M_ITPGRC"    	, ''							} )
									aadd( aLinVncAux2, { "N8M_CODNGC"   	, ''							} )
									aadd( aLinVncAux2, { "N8M_VERNGC"   	, ''							} )
									aadd( aLinVncAux2, { "N8M_ORIGEM"    	, 'OGA280'		 				} )
									aAdd( aLinVncAux2, { "N8M_HISTOR"    	,FWI18NLang("OGA280","STR0132",132)		} )  //Previsï¿½o financeira, Contrato de compra
											
									aAdd(aVncCPag, aLinvncAux2)
                                   
									//Alteração para preencher os campos de contrato e safra - DAGROCCO-2914                            
									aAdd( aFina050, { "E2_CTROG"  , cNumero                 , Nil } )
									aAdd( aFina050, { "E2_CODSAF"  , NJR->( NJR_CODSAF )    , Nil } )
								
                                
                                    MsExecAuto( { |x,y| Fina050( x, y ) }, aFina050, 3 )
                                    If lMsErroAuto .and. !__lAutomato  
                                        MostraErro()
                                        lRetorno := .F.
										Exit
                                    EndIf

                                endif
                                NN7->( dbSkip() )
                            EndDo
                        EndIf

                        If lRetorno .and.  len( aVncCPag ) > 0
                            lRetorno := fAgrVncPag (aVncCPag, 3 )  //Incluir
                        EndIF

                        If lRetorno
                            // Atualiza as quantidades autorizadas do contrato
                            OGX010QAut("A")

                            //ATUALIZA O FINACEIRO
                            If NJR->(NJR_QTEFCO) - NJR->(NJR_QTSFCO)  > 0
                                OGA250ATUF(NJR->( NJR_CODCTR ) , NJR->(NJR_QTEFCO) - NJR->(NJR_QTSFCO) , "2")
                            Endif   
                            If  !__lAutomato                   
                                MsgInfo( STR0051, STR0052 ) //"Contrato Confirmado com Sucesso!!!"###"Confirmaçao do Contrato"   
                            Endif	
                            //Atualiza o codigo dos Contratos Externo caso o contrato ja possuia IE
                            If !Empty(cNegocio)
                                DbSelectArea("N7S")
                                DbSetOrder(2)
                                If DbSeek(xFilial("N7S")+NJR->NJR_CODCTR) 
                                    While !N7S->(Eof()) .AND. N7S->N7S_FILIAL+N7S->N7S_CODCTR == xFilial("N7S")+NJR->NJR_CODCTR
                                    
                                        If N7S->N7S_CTREXT != NJR->NJR_CTREXT
                                        
                                            RecLock("N7S",.F.)
                                                N7S->N7S_CTREXT := NJR->NJR_CTREXT
                                            N7S->(MsUnlock())
                                            
                                        EndIf
                                        
                                        N7S->(DbSkip())
                                    EndDo
                                EndIf
                            EndIf
                                
                            //FUNÇAO QUE ATUALIZA O STATUS DO ACORDO DE TROCA PARA PENDENTE(OGA300)
                            If FindFunction('StatusNKT')
                                StatusNKT('01')
                            Endif

                        Else               
                            DisarmTransaction()  
                        EndIf 
                    END TRANSACTION
                EndIf
            Else
                Help( ,,STR0034,, STR0053, 1, 0 ) //"AJUDA"###"Este contrato ja foi confirmado..."
            EndIf
        EndIf
    EndIf

	RestArea( aAreaAtu )
Return( lRetorno )

/** {Protheus.doc} OGA280E
Rotina para utilizada para Cancelar o contrato para que o mesmo nao seja mais movimentado

@param:     Nil
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       SIGAAGR - Originaçao de Graos
*/
Function OGA280E( cAlias, nReg, nAcao )
	Local aAreaAtu  := GetArea()
	Local cCodNog 	:= IIF(ColumnPos("NJR_CODNGC") > 0 , NJR->(NJR_CODNGC) , "" )
	Local nRet      := 1
	Local lRet 		:= .T.

	BEGIN TRANSACTION
        IF ValCancel() 
            Help(, , STR0034, , STR0113, 1, 0 )
           	lRet := .F.
        Else
			//Se NJR_STATUS for A=aberto , I=iniciado ou P=previsto
			If NJR->( NJR_STATUS ) $ "A|I|P"
				If !Empty(cCodNog)
					Help( ,,STR0034,, STR0128 +cCodNog, 1, 0, , , ,,,{STR0130} ) //"Ajuda"###"Este contrato foi gerado pelo negocio,  Nao é possivel cancelar o contrato.
					lRet := .F.
				ElseIf NJR->( NJR_STATUS) == "P"
					Help( ,,STR0034,, STR0126, 1, 0 ) //"Ajuda"###"Contrato com status 'Previsto' nao pode ser cancelado. Somente é permitido a operaçao de 'Excluir'.
					lRet := .F.
				Else 
					AGRXATUNN8("C")
						
					If !__lNGraPrevF // Validaçao para anular mesmo sem ter gerado previsao // __lNGraPrevF = .F. --> Gera previsão financeira

						If NJR->( NJR_QTEFIS ) = 0 .AND.  NJR->( NJR_QTSFIS )= 0
							//"Deseja realmente Cancelar este contrato?"
							If !__lAutomato
								nRet := AGRGRAVAHIS(STR0054,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"E") 
							EndIf
				
							If nRet = 1
								If RecLock( "NJR", .f. )
									NJR->( NJR_QTDCTR ) := NJR->( NJR_QTEFCO )
									NJR->( NJR_AUTENT ) := NJR->( NJR_QTEFCO )
									NJR->( NJR_AUTSAI ) := NJR->( NJR_QTSFCO )
									msUnLock()
								EndIf

								lDelTitFin(NJR->NJR_CODCTR,NJR->NJR_CODENT,NJR->NJR_LOJENT)//exclui as previsoes    

								//////////////////////////
								// Atualiza qtdes do contrato e saldos
								//////////////////////////
								OGX010QTDS("E")             

								MsgInfo( STR0055, STR0056 ) //"Contrato Cancelado com Sucesso!!!"###"Cancelamento do Contrato"
							Endif
						Else
							Help( ,,STR0034,,STR0120, 1, 0 ) //"Ajuda"#### "Contrato nao pode ser Cancelado. Existe saldo de quantidades."
							lRet := .F.
						EndIf
					Else //Sem Previsao Financeira
						If AGRGRAVAHIS(STR0054,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"E")

							If RecLock( "NJR", .f. )
								NJR->( NJR_QTDCTR ) := NJR->( NJR_QTEFCO )
								NJR->( NJR_AUTENT ) := NJR->( NJR_QTEFCO )
								NJR->( NJR_AUTSAI ) := NJR->( NJR_QTSFCO )
								msUnLock()
							EndIf

							lDelTitFin(NJR->NJR_CODCTR,NJR->NJR_CODENT,NJR->NJR_LOJENT)//exclui as previsoes    

							//////////////////////////
							// Atualiza qtdes do contrato e saldos
							//////////////////////////
							OGX010QTDS("E")             

							//////////////////////////
							// Atualiza o status do troca vinculado para pendente.
							//////////////////////////
							If FindFunction('StatusNKT')
								StatusNKT("01")
							Endif

							MsgInfo( STR0055, STR0056 ) //"Contrato Cancelado com Sucesso!!!"###"Cancelamento do Contrato"
						Endif
					Endif //Sem Previsao Financeira        
				Endif
			Else
				Help( ,,STR0034,, STR0057, 1, 0 ) //"Ajuda"###"Este contrato nao pode ser -Cancelado-, pois ja foi -Finalizado-..."
				lRet := .F.
			EndIf
		EndIf

		If !lRet
			DisarmTransaction()
		EndIf

    END TRANSACTION

	RestArea( aAreaAtu )
Return( lRet )


/** {Protheus.doc} OGA280F
Rotina para utilizada para finalizar os contrato para que o mesmo nao seja mais movimentado

@param:     Nil
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       SIGAAGR - Originacao de Graos
*/
Function OGA280F( cAlias, nReg, nAcao )
	Local aAreaAtu  := GetArea()
	Local aTpContrato := SuperGetMV("MV_AGRO001",.F., "") //tipo do contrato //1COMPRA 2 VENDA 3 ARM DE TERC 4 ARMA EM TERC
	Local nIt		  := 0
	Local lRet        := .T.
	Local nRet        := 1

	If !Empty(aTpContrato) // Verifica o parametro de tipo do contrato
		aTpContrato := Separa(aTpContrato, ";")
		For nIt := 1 To Len(aTpContrato)
			If NJR->( NJR_TIPO )== AllTrim(aTpContrato[nIt]) // se o tipo nao fizer parte do parametro valida normalmente
			   lRet := .F.
				//"Deseja realmente finalizar este contrato?"
				If NJR->( NJR_STATUS ) $ "I"
					If !__lAutomato
		                nRet := AGRGRAVAHIS(STR0101,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"F") 
		            EndIf
		
					If nRet = 1
						If RecLock( "NJR", .f. )
							NJR->( NJR_STATUS ) := "F"
							msUnLock()
						EndIf
						lDelTitFin(NJR->NJR_CODCTR,NJR->NJR_CODENT,NJR->NJR_LOJENT)//exclui as previsoes 
						Help( ,,STR0058,, STR0059, 1, 0 )//"Contrato Finalizado com Sucesso!!!"###"Finalizacao do Contrato"
						//Atualiza o status da troca para finalizado.(OGA300)
						If FindFunction('StatusNKT')
							StatusNKT('04')
						Endif
					EndIf
				Else
					Help( ,,STR0034,, STR0064, 1, 0 ) //"Ajuda"###"Este contrato nao pode ser -Finalizado-, pois ainda nao foi -Iniciado- ."
					Return( Nil )
				EndIf
			EndIf
		Next nIt
		If lRet
			If NJR->( NJR_STSASS ) = "F" .And. NJR->( NJR_STSEST ) = "F" .And. NJR->( NJR_STSFIS ) = "F" .And. NJR->( NJR_STSFIN ) = "F" .And. NJR->( NJR_STATUS ) $ "I"
				//"Deseja realmente finalizar este contrato?"
				If !__lAutomato
		           nRet := AGRGRAVAHIS(STR0101,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"F")
		        EndIf
		
				If nRet = 1
					If RecLock( "NJR", .f. )
						NJR->( NJR_STATUS ) := "F"
						msUnLock()
					EndIf           
					lDelTitFin(NJR->NJR_CODCTR,NJR->NJR_CODENT,NJR->NJR_LOJENT)//exclui as previsoes  
					Help( ,,STR0058,, STR0059, 1, 0 ) //"Contrato Finalizado com Sucesso!!!"###"Finalizacao do Contrato"
					
					//Atualiza o status da troca para finalizado.(OGA300)
					If FindFunction('StatusNKT')
						StatusNKT('04')
					Endif
				EndIf
			Else
				If NJR->( NJR_STSASS ) != "F"
					Help( ,,STR0034,, STR0060, 1, 0 ) //"Ajuda"###"Este contrato nao pode ser -Finalizado-, pois o Status Assinatura do Contrato consta como Aberto ."
					Return( Nil )
				Endif

				If NJR->( NJR_STSEST ) != "F"
					Help( ,,STR0034,, STR0061, 1, 0 ) //"Ajuda"###"Este contrato nao pode ser -Finalizado-, pois o Status Estoque do Contrato consta como Aberto ."
					Return( Nil )
				Endif

				If NJR->( NJR_STSFIS ) != "F"
					Help( ,,STR0034,, STR0062, 1, 0 ) //"Ajuda"###"Este contrato nao pode ser -Finalizado-, pois o Status Fiscal do Contrato consta como Aberto ."
					Return( Nil )
				Endif

				If NJR->( NJR_STSFIN ) != "F"
					Help( ,,STR0034,, STR0063, 1, 0 ) //"Ajuda"###"Este contrato nao pode ser -Finalizado-, pois o Status Financeiro do Contrato consta como Aberto ."
					Return( Nil )
				Endif

				If NJR->( NJR_STATUS ) != "I"
					Help( ,,STR0034,, STR0064, 1, 0 ) //"Ajuda"###"Este contrato nao pode ser -Finalizado-, pois ainda nao foi -Iniciado- ."
					Return( Nil )
				Endif
			EndIf



		EndIf
	Else
		If NJR->( NJR_STSASS ) = "F" .And. NJR->( NJR_STSEST ) = "F" .And. NJR->( NJR_STSFIS ) = "F" .And. NJR->( NJR_STSFIN ) = "F" .And. NJR->( NJR_STATUS ) $ "I"
			//"Deseja realmente finalizar este contrato?"
			If !__lAutomato
		       nRet := AGRGRAVAHIS(STR0101,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"F") 
		    EndIf
		
			If nRet = 1
				If RecLock( "NJR", .f. )
					NJR->( NJR_STATUS ) := "F"
					msUnLock()
				EndIf           
				lDelTitFin(NJR->NJR_CODCTR,NJR->NJR_CODENT,NJR->NJR_LOJENT)//exclui as previsoes  
				Help( ,,STR0058,, STR0059, 1, 0 ) //"Contrato Finalizado com Sucesso!!!"###"Finalizacao do Contrato"

				//Atualiza o status da troca para finalizado.(OGA300)
				If FindFunction('StatusNKT')
					StatusNKT('04')
				Endif
			EndIf
		Else
			If NJR->( NJR_STSASS ) != "F"
				Help( ,,STR0034,, STR0060, 1, 0 ) //"Ajuda"###"Este contrato nao pode ser -Finalizado-, pois o Status Assinatura do Contrato consta como Aberto ."
				Return( Nil )
			Endif

			If NJR->( NJR_STSEST ) != "F"
				Help( ,,STR0034,, STR0061, 1, 0 ) //"Ajuda"###"Este contrato nao pode ser -Finalizado-, pois o Status Estoque do Contrato consta como Aberto ."
				Return( Nil )
			Endif

			If NJR->( NJR_STSFIS ) != "F"
				Help( ,,STR0034,, STR0062, 1, 0 ) //"Ajuda"###"Este contrato nao pode ser -Finalizado-, pois o Status Fiscal do Contrato consta como Aberto ."
				Return( Nil )
			Endif

			If NJR->( NJR_STSFIN ) != "F"
				Help( ,,STR0034,, STR0063, 1, 0 ) //"Ajuda"###"Este contrato nao pode ser -Finalizado-, pois o Status Financeiro do Contrato consta como Aberto ."
				Return( Nil )
			Endif

			If NJR->( NJR_STATUS ) != "I"
				Help( ,,STR0034,, STR0064, 1, 0 ) //"Ajuda"###"Este contrato nao pode ser -Finalizado-, pois ainda nao foi -Iniciado- ."
				Return( Nil )
			Endif
		EndIf
	EndIf
	RestArea( aAreaAtu )
Return( Nil )

/** {Protheus.doc} oGa280PRC
Rotina para Chamada da funçao de composicao de precos OGA420
@param:     Nil
@author:    Emerson Coelho
@since:     02/10/2014
@Uso:       SIGAAGR - Originaçao de Graos
@type function
*/
Function OGA280Prc()
	Local oModel     	:= FWModelActive()
	Local oView         := FwViewActive()
	Local nOperation    := oModel:GetOperation()			//1-View / 3-Insert / 4-Update / 5-Delete / 6-Only Update
	Local oGridNNY  	:= oModel:GetModel( "NNYUNICO" )
	Local oGridNN7  	:= oModel:GetModel( "NN7UNICO" )
	Local aCompPrc  	:= aGrvNKA
	Local cNk7Aplica    := 'C' //Compra
	Local cNjrCodCtr    := oModel:GetValue( "NJRUNICO", "NJR_CODCTR" )
	Local cNjrUmPrc  	:= oModel:GetValue( "NJRUNICO", "NJR_UMPRC" )
	Local cNjrUm1Pro    := oModel:GetValue( "NJRUNICO", "NJR_UM1PRO" )
	Local cProduto  	:= oModel:GetValue( "NJRUNICO", "NJR_CODPRO" )	
	Local cTipoFx       := ''
	Local dDtFixa   	:= dDatabase
	Local nNjrMoeda 	:= oModel:GetValue( "NJRUNICO", "NJR_MOEDA" )
	Local nQtfixar      := oModel:GetValue( "NJRUNICO", "NJR_QTDINI" )	
	Local nLinha        := 0
	Local nPos			:= 0
	Local nX       		:= 0
	Local lTemCmpPrc    := .f.
	Local lEditar   	:= IF(nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE,.T., .F. )
	Local cNegocio  	:= ""
	Local cVersao   	:= ""
	Local lGeraPrev     := .F.
	Local lConfirma     := .F.
	Local cItem         := ""
	Local cParc         := ""
	Local nLinhaPrev    := 0
    Local dVcto         := nil
    Local nVrTotal		:= 0
    Local dDEntrIni     := nil
    Local dDEntrFim     := nil

	//protecao de fonte
	if oModel:GetModelStruct("NJRUNICO")[3]:OFORMMODELSTRUCT:HasField("NJR_CODNGC")
		cNegocio  	:= oModel:GetValue( "NJRUNICO", "NJR_CODNGC" )
		cVersao   	:= oModel:GetValue( "NJRUNICO", "NJR_VERSAO" )
	endif

	if (!empty(cNegocio) .and. !empty(cVersao)) .or. (__lnewNeg .and. nOperation == MODEL_OPERATION_INSERT) .or. AGRXCVNNGC( FwxFilial("NJR"), cNjrCodCtr )
		OGC050(FwxFilial("NJR"),cNjrCodCtr) //chama somente em visualizaçao
	else //old method
		//-- Quando Inclusao
	    IF nOperation == MODEL_OPERATION_INSERT .OR. cPaisLoc == "PAR" .Or. cPaisLoc == "ARG"  //DAGROGAP-1445			
            cTipoFx     := IIF( AllTrim( oModel:GetValue( "NJRUNICO", 'NJR_TIPFIX' )) == '1' , '1' , IIF( AllTrim( oModel:GetValue( "NJRUNICO", 'NJR_TIPFIX' )) == '3' , '2' , '0' ) )  //--<< njr_tipfix (1=Fixo;2=A Fixar;3=basis(pataguai)),cTipoFix (0=Previsto,1=Firme,2=basis(pataguai)) //DAGROGAP-1445
		Else			
            cTipoFx     := IIF( AllTrim( NJR->NJR_TIPFIX ) == '1' , '1' , IIF( AllTrim( NJR->NJR_TIPFIX ) == '3' , '2' , '0' ) ) //--<< njr_tipfix (1=Fixo;2=A Fixar;3=Basis),cTipoFix(0=Previsto,1=Firme,2=Basis) //DAGROGAP-1445
		EndIF
	
		cAliasNN8 := GetNextAlias()

		BeginSql Alias cAliasNN8
		SELECT NN8_DATA, NN8_DATINI, NN8_DATFIN, NN8_QTDENT, NN8_ITEMFX
		FROM %Table:NN8% NN8
		WHERE NN8.%notDel%
		AND NN8_FILIAL = %Exp:xFilial('NN8')%
		AND NN8_CODCTR = %Exp:cNjrCodCtr%
		AND NN8_TIPOFX = %Exp:cTipoFx%  
		AND NN8_ITEMFX != '' 
		EndSQL

		While (cAliasNN8)->(!Eof())

			lTemCmpPrc  := .T.
			dDtFixa     := Stod((cAliasNN8)->NN8_DATA)
			dDEntrIni   := Stod((cAliasNN8)->NN8_DATINI)
			dDEntrFim   := Stod((cAliasNN8)->NN8_DATFIN)

			IF Len(aGrvNKA)== 0
				aCompPrc := OGA420NKAR( cNjrCodCtr , (cAliasNN8)->NN8_ITEMFX ) 	//--<< Le a NKA e Recebe Retorno do Array com os Dados >>--
			EndIF
			//Se FOR Firme e Possuir Entregas lEditar = falso
			IF NJR->NJR_TIPFIX == '1' .AND. (cAliasNN8)->NN8_QTDENT > 0
				lEditar := .F.
			EndIf
			(cAliasNN8)->(DbSkip())
	
		EndDo
		
		If cPaisLoc != "PAR" .AND. cPaisLoc != "ARG"
			If !Empty(oModel:GetValue( "NJRUNICO", "NJR_DATREF" )) 
		   		dDtfixa := oModel:GetValue( "NJRUNICO", "NJR_DATREF" )
		   	EndIF
		EndIf
	
		IF !lTemCmpPrc  													//--<< Ainda nao existe Composiçao de preço >>--
			dDEntrIni := CTOD('//')
			dDEntrFim := CTOD('//')
			nLinha := oGridNNY:GetLine()
			For nX := 1 to oGridNNY:Length()
				oGridNNY:GoLine( nX )
				If .Not. oGridNNY:IsDeleted()
					If cPaisLoc == "PAR" .or. cPaisLoc == "ARG"
						IF dDEntrIni == CTOD('//') .or. oGridNNY:GetValue( "NNY_DATINI" ) < dDEntrIni
							dDEntrIni := oModel:GetValue( "NJRUNICO", "NJR_DATREF" )
						EndIF
						IF dDEntrFim == CTOD('//') .or. oGridNNY:GetValue( "NNY_DATFIM" ) > dDEntrFim
							dDEntrFim := oModel:GetValue( "NJRUNICO", "NJR_DATREF" )
						EndIF
					Else
						IF dDEntrIni == CTOD('//') .or. oGridNNY:GetValue( "NNY_DATINI" ) < dDEntrIni
							dDEntrIni := oGridNNY:GetValue( "NNY_DATINI" )
						EndIF
						IF dDEntrFim == CTOD('//') .or. oGridNNY:GetValue( "NNY_DATFIM" ) > dDEntrFim
							dDEntrFim := oGridNNY:GetValue( "NNY_DATFIM" )
						EndIF
					EndIf
				EndIF
			Next nX
			oGridNNY:GoLine( nLinha )
	
			//Validar se os Campos que sao necessarios Para Chamar a funçao nao estao Vazio
			Do Case
				Case Empty( cProduto  )
				Help( , , STR0034, , STR0085 , 1, 0 ) //"AJUDA"###"Informe produto para o Contrato"
				Return (.f.)
				Case Empty( oModel:GetValue( "NJRUNICO", "NJR_DATREF" ) ) .and. (cPaisLoc == "PAR" .OR. cPaisLoc == "ARG" )
                Help( , , STR0034, , STR0134, 1, 0 ) //"AJUDA"###"A data de referência da fixação não foi informada."
                Return (.f.)
                Case Empty( dDEntrIni )
				Help( , , STR0034, , STR0086, 1, 0 ) //"AJUDA"###"Informe Cadencia para o Contrato"
				Return (.f.)
				Case Empty( dDEntrFim )
				Help( , , STR0034, , STR0086, 1, 0 ) //"AJUDA"###"Informe Cadencia para o Contrato"
				Return (.f.)
				Case nQtfixar == 0
				Help( , , STR0034, , STR0087, 1, 0 ) //"AJUDA"###"Informe Qtidade para o Contrato"
				Return (.f.)
				Case Empty( cNjrUm1Pro )
				Help( , , STR0034, , STR0088, 1, 0 ) //"AJUDA"###"Informe Unidade de medida para o Contrato"
				Return (.f.)
				Case Empty( nNjrMoeda  )
				Help( , , STR0034, , STR0089, 1, 0 ) //"AJUDA"###"Informe Moeda do Contrato"
				Return (.f.)
			EndCase
		EndIF
	
		aCompPrc := OGA420( cNjrCodCtr , cProduto , dDtfixa , dDEntrIni , dDEntrFim , nQtfixar , cNk7Aplica, cNjrUm1Pro,cNjrUmPrc,nNjrMoeda,aCompPrc , lEditar, nil, nil, nil, nil, nil, cTipoFx, nil )
		aGrvNKA  := aCompPrc
		
		//--Se permite editar e array maior que zero [contem informaçoes]
		IF lEditar .AND. Len(aCompPrc) > 0
			//-- Limpa toda a GRID 
			For nX := 1 to oGridNN7:Length()
				oGridNN7:GoLine( nX )
				If !oGridNN7:IsDeleted() .And. NN7->(ColumnPos("NN7_CODCOM")) > 0 .and. !Empty(oGridNN7:GetValue("NN7_CODCOM")) .and. ALLTRIM(oGridNN7:GetValue("NN7_CODCOM")) != "TOTAL"
					oGridNN7:DeleteLine()
				ElseIf nLinhaPrev > 0 .and. !oGridNN7:IsDeleted()
					oGridNN7:DeleteLine()
				ElseIf !oGridNN7:IsDeleted()
					cItem	:= oGridNN7:GetValue( "NN7_ITEM" )
					cParc 	:= oGridNN7:GetValue( "NN7_PARCEL" )
					nLinhaPrev := nX //linha da previsao financeira do tipo PREVISAO 
				EndIf
			Next nX
			
			If nLinhaPrev == 0 //TODAS AS LINHAS FORAM DELETADAS
				//adiciona uma linha na NN7 do tipo PREVISAO(PADRAO)
				oGridNN7:AddLine()
				oGridNN7:SetValue( "NN7_ITEM"	, StrZero( 1, TamSX3("NN7_ITEM")[1]) 	)	
				oGridNN7:SetValue( "NN7_PARCEL"	, StrZero( 1, TamSX3("NN7_PARCEL")[1])	)
			Else
				oGridNN7:GoLine( nLinhaPrev )//posiciona na linha 
			EndIf
			
			IF Len ( aCompPrc ) > 0 //--<< Encontro onde esta o total no Array  >>--
				nPosTotal := aSCAN( aCompPrc, {|aCompPrc| aCompPrc[07] == "3" })
				IF nPosTotal > 0
					//--<< Atualiza NJR_VLRUNI com o Dado que veio da Composiçao de preço >>-- 
					oModel:LoadValue( "NJRUNICO", "NJR_VLRUNI", aCompPrc[nPosTotal,11] )        //--<< Pula todas as Validaçoes >>--
					//If cPaisLoc <> "PAR" .and. cPaisLoc <> "ARG"  
					    IF cTipoFx == "1" 														//--<< Se for Fixo , Tenho que Atualizar o Vr. do NJRVLRBAS >>-
						    oModel:SetValue( "NJRUNICO", "NJR_VLRBAS", aCompPrc[nPosTotal,11] )
					    EndIF				    
                    //EndIf
	
					//--<< Calc. Vr Total de acordo com as unidades de medidas (Produto e Contrato)
					//--<< Utilizar NJR_QTDCTR para considerar os aditivo caso houver    
					
					//pega o fator de conversão
					nConvert := AGRX001(oModel:GetValue( "NJRUNICO", "NJR_UMPRC" ), oModel:GetValue( "NJRUNICO", "NJR_UM1PRO" ),1, /*cProduto*/)
					//calcula o total
					nVrTotal := OGA420TOT(aCompPrc[nPosTotal,11], oModel:GetValue( "NJRUNICO", "NJR_QTDCTR" ) , nConvert)
				
					oModel:LoadValue( "NJRUNICO", "NJR_VLRTOT", nVrTotal )  //--<< Pula todas as Validações >>--

					If !__lNGraPrevF // __lNGraPrevF = .F. --> Gera previsão financeira
						oGridNN7:LoadValue( "NN7_VALOR", nVrTotal )     	//--<< Atualiza o Total no Grid do financeiro >>---
					Else 
						//nao gera a previsao financeira
						Return .T.					
					EndIf
				EndIF
			EndIF				
			
			If !__lAutomato
				lConfirma := MSGYESNO(STR0131, STR0013) //Confirma a geraçao de informaçao de componentes de preço? Confirmar
			Endif

			If lConfirma .Or. __lAutomato
				
				For nPos := 1 TO Len(aCompPrc)				
					If aCompPrc[nPos][16] <> 0
						DbSelectArea("NK7")		//Tabela de Componentes de Preço
						NK7->(DbSetOrder(1))			//NK7_FILIAL+NK7_CODCOM
						If NK7->(DbSeek(xFilial("NK7") + aCompPrc[nPos][3] ))
							If ColumnPos("NK7_GERFIN") > 0 .and. NK7->NK7_GERFIN $ "2|4"
								lGeraPrev := .T.
							Else
								lGeraPrev := .F.
							EndIf
						Else
							lGeraPrev := .F.
						EndIf
						If lGeraPrev // Gera Previsao Financeira quando posicionar na NK7 
							oGridNN7:AddLine() //adiciona uma nova linha para criar  títulos provisórios de despesas para o componnete
							cItem	:= StrZero(oGridNN7:Length(), TamSX3( "NN7_ITEM" )[1]) 
							cParc 	:= StrZero(oGridNN7:Length(), TamSX3( "NN7_PARCEL" )[1])  
							
							nValCom := Round(oModel:GetValue( "NJRUNICO", "NJR_QTDCTR" ) * AGRX003(cProduto, aCompPrc[nPos][13], aCompPrc[nPos][14], 10), TamSX3('NJR_VLRTOT')[2])
								
							If!Empty(cItem)
								oGridNN7:SetValue( "NN7_ITEM"		, cItem)	
							Endif
															
							If NN7->(ColumnPos("NN7_CODCOM")) > 0				
									oGridNN7:SetValue( "NN7_CODCOM"	, aCompPrc[nPos][3])
							EndIf
																
							If NN7->(ColumnPos("NN7_ITMCOM")) > 0	
								oGridNN7:SetValue( "NN7_ITMCOM"	, aCompPrc[nPos][4])
							EndIf

							If!Empty(cParc) 	
								oGridNN7:SetValue( "NN7_PARCEL"	, cParc)
							Endif

                            If oGridNN7:length() > 1
                                dVcto := oGridNN7:GetValue("NN7_DTVENC", oGridNN7:length()  - 1)
                            EndIf

                            If Empty(dVcto)
                                dVcto := dDataBase
                            EndIf
							
							oGridNN7:SetValue( "NN7_DTVENC"	, dVcto)
							oGridNN7:SetValue( "NN7_VALOR" 	, nValCom)
							oGridNN7:LoadValue( "NN7_CODFAV" 	, NJ0->NJ0_CODFOR)//Favorecido para compra é o Fornecedor
							oGridNN7:LoadValue( "NN7_LOJFAV" 	, NJ0->NJ0_LOJENT)
						EndIf						
					EndIf
				Next nPos			
	
			EndIf
	
			//--Posiciona na primeira linha da GRID
			oGridNN7:GoLine(1)
			If ValType(oView) != "U"	// Atualiza a View
				oView:Refresh("VIEW_NN7")
			EndIf
			
			//--Funçao para gatilho de favorecido
			AGRXVLFAV(oModel:GetModel( "NJRUNICO"),oModel:GetValue( "NJRUNICO", "NJR_CODENT"), oModel:GetValue( "NJRUNICO", "NJR_LOJENT"))
			
		EndIF
	endif
	
Return

/** {Protheus.doc} fGrvComPrc
Rotina para gravar a Composicao de Preco apartir do Array AgRVNKA
@param:     AcompPrc ( Array com Itens da Composiçao de Preço ) , nOperation se é Insercao ou alteração
@author:    Emerson Coelho
@since:     02/10/2014
@Uso:       SIGAAGR - Originação de Grãos
*/
Static Function fGrvComPrc( aCompPRC , nOperation)
	Local oModel        := FWModelActive()
	Local cNjrCodCtr    := oModel:GetValue( "NJRUNICO", "NJR_CODCTR" )
	Local oModelNN8     := oModel:GetModel("NN8UNICO")
	Local cTipoFx       :=''
	Local cItemFx       :=''
	Local dDtFixa       := dDatabase
	Local nQtfixar      := oModel:GetValue( "NJRUNICO", "NJR_QTDINI" )
	Local nNjrMoeda     := oModel:GetValue( "NJRUNICO", "NJR_MOEDA" )
	Local cAliasQry     := GetNextAlias()
	Local lMudouFix     := IF(! NJR->NJR_TIPFIX = oModel:GetValue( "NJRUNICO","NJR_TIPFIX" ),.T.,.F. ) //--<< Indica que mudou o tipo de Fixaçao no Contrato >>--
	Local lTemNN8       := .f. //---<< Indica que ja existe composiçao de precos gravada para o Contrato >>--
	Local lTemComPrc    := IF(Len ( aCompPRC ) == 0 ,.f.,.t.) //--<< Indica que foi na Rotina de composiçao de preco e tme Algo para Gravar >>-
	Local nPosTotal     := 0
	Local nNN8_VLRUNI   := 0

	If oModel:IsCopy()
	   oModelNN8:DelAllLine()
	   oModelNN8:AddLine()
	EndIf

	IF lMudouFix //--<< o Q Esta Gravado não é mais igual ao que esta na Tela >>--		
        cTipoFx     := IIF( AllTrim( NJR->NJR_TIPFIX ) == '1' , '1' , IIF( AllTrim( NJR->NJR_TIPFIX ) == '3' , '2' , '0' ) ) //--<< njr_tipfix (1=Fixo;2=A Fixar;3=Basis),cTipoFix (0=Previsto,1=Firme,2=Basis) //DAGROGAP-1445
	Else		
        cTipoFx     := IIF( AllTrim( oModel:GetValue( "NJRUNICO", 'NJR_TIPFIX' )) == '1' , '1' , IIF( AllTrim( oModel:GetValue( "NJRUNICO", 'NJR_TIPFIX' )) == '3' , '2' , '0' ) )  //--<< njr_tipfix (1=Fixo;2=A Fixar;3=Basis),cTipoFix (0=Previsto,1=Firme,2=Basis) //DAGROGAP-1445
	EndIF

	dbSelectArea("NN8")
	NN8->( dbSetOrder(2) )  //Contrato + Tipo + Item Fix
	If NN8->(DbSeek(xFilial("NN8") + cNjrCodCtr + cTipoFx  ))
		dDtFixa         := NN8->NN8_DATA
		dDEntrIni       := NN8->NN8_DATINI
		dDEntrFim       := NN8->NN8_DATFIN
		cItemFx     := NN8->NN8_ITEMFX
		nNN8_VLRUNI := NN8->NN8_VLRUNI		
		lTemNN8     := .t.
	EndIF
	
	If cPaisLoc != "PAR" .AND. cPaisLoc != "ARG"
		If !Empty(oModel:GetValue( "NJRUNICO", "NJR_DATREF" )) 
	   		dDtfixa := oModel:GetValue( "NJRUNICO", "NJR_DATREF" )
	   	EndIF
    EndIf

	IF lTemNN8 == .f. .and. lTemComPrc == .t. //--<< Indica que tenho que Gravar NKA Composiçao de Preço , Encontro o proximo nr. de Fixaçao >>--
		BeginSql Alias cAliasQry
		SELECT MAX(NN8_ITEMFX) as NN8_ITEMFX
		FROM %Table:NN8% NN8
		WHERE NN8.%notDel%
		AND NN8_FILIAL = %XFilial:NN8%
		AND NN8_CODCTR = %exp:cNjrCodCtr%
		EndSQL

		DbselectArea( cAliasQry )
		( cAliasQry )->( DbGoTop()  )
		If ( cAliasQry )->( !Eof() )
			cItemFx := Soma1( ( cAliasQry )->NN8_ITEMFX )
		Else
			cItemFx := StrZero( 1, TamSX3( "NN8_ITEMFX" )[1] )
		EndIf
		( cAliasQry )->( DbCloseArea() )
	EndIF


	IF (lTemComPrc == .t. ) .or. (lTemNN8 == .t. .and. lmudoufix == .t. ) // Se tiver Comp.Preço, ou Entao Se Tem Fixaçao e o tipo do Contrato foi Mudado
		If lTemComPrc //Indica q tem Composiçao de preço entao pego os Vrs.Ini da Composiçao de Preço
			nPosTotal := aSCAN(aCompPRC, {|aCompPRC| aCompPRC[3] == "TOTAL" }) // Encontro o Valor unitario em 1a Um e 2aUM na composiçao de preços
			nNN8_VLRUNI := aCompPrc[ nPosTotal , 11]
		EndIF

			If lMudouFix .and. (cPaisLoc == "PAR" .Or. cPaisLoc == "ARG")
				oGa420NKAD ( cNjrCodCtr , cItemFx ) //deleta a NKA para poder incluir os registros novos
			EndIf

            If cPaisLoc == "PAR" .Or. cPaisLoc == "ARG"  
				IF AllTrim( oModel:GetValue( "NJRUNICO", 'NJR_TIPFIX' )) == '1' //Fixo
				    oModelNN8:SetValue("NN8_TIPOFX", 1 ) 
				EndIF
				if AllTrim( oModel:GetValue( "NJRUNICO", 'NJR_TIPFIX' )) == '2' //á fixar
				   oModelNN8:SetValue("NN8_TIPOFX",'0')  
				EndIF
				if AllTrim( oModel:GetValue( "NJRUNICO", 'NJR_TIPFIX' )) == '3' // Basis
				   oModelNN8:SetValue("NN8_TIPOFX",'2')  
				Endif	
				
				oModelNN8:SetValue("NN8_TIPO",oModel:GetValue( "NJRUNICO", 'NJR_TIPO' ))
				oModelNN8:SetValue("NN8_CTRFIX",oModel:GetValue( "NJRUNICO", 'NJR_TIPFIX' ))
				oModelNN8:SetValue("NN8_CODENT",oModel:GetValue( "NJRUNICO", 'NJR_CODENT' ))
				oModelNN8:SetValue("NN8_LOJENT",oModel:GetValue( "NJRUNICO", 'NJR_LOJENT' ))
				oModelNN8:SetValue("NN8_CODPRO",oModel:GetValue( "NJRUNICO", 'NJR_CODPRO' ))
				oModelNN8:SetValue("NN8_CODSAF",oModel:GetValue( "NJRUNICO", 'NJR_CODSAF' ))
				oModelNN8:SetValue("NN8_UMPRC",oModel:GetValue( "NJRUNICO", 'NJR_UMPRC' ))
				
                oModelNN8:SetValue("NN8_DATREF",oModel:GetValue( "NJRUNICO", 'NJR_DATREF' ))
				oModelNN8:SetValue("NN8_DATINI",oModel:GetValue( "NJRUNICO", 'NJR_DATREF' ))
				oModelNN8:SetValue("NN8_DATFIN",oModel:GetValue( "NJRUNICO", 'NJR_DATREF' ))

				oModelNN8:SetValue("NN8_DATA",oModel:GetValue( "NJRUNICO", 'NJR_DATA' ))
				oModelNN8:SetValue("NN8_DATREF",oModel:GetValue( "NJRUNICO", 'NJR_DATREF' ))

			Else
				oModelNN8:SetValue("NN8_TIPOFX", IIF(oModel:GetValue( "NJRUNICO", 'NJR_TIPFIX' ) == '1' , '1' , '0' ) ) 
				oModelNN8:SetValue("NN8_DATA",dDtfixa)
			EndIf

			oModelNN8:SetValue("NN8_DATINI", dDEntrIni) 
			oModelNN8:SetValue("NN8_DATFIN", dDEntrFim) 
			oModelNN8:SetValue("NN8_QTDFIX", nQtfixar) 
			oModelNN8:SetValue("NN8_VLRUNI", nNN8_VlrUni) 
			oModelNN8:SetValue("NN8_MOEDA", nNjrMoeda) 
			oModelNN8:SetValue("NN8_ITEMFX", cItemFx) 
			oModelNN8:SetValue("NN8_STATUS", '1') 

			// EnContra Vrs/Vrs.Liquidos Previstos ( retirando os Impostos tipo funrural etc...) --//
			cCodEnt := oModel:GetValue( "NJRUNICO", "NJR_CODENT" )
			cLjaEnt := oModel:GetValue( "NJRUNICO", "NJR_LOJENT" ) 
			cCodPro := oModel:GetValue( "NJRUNICO", "NJR_CODPRO" ) 
			cUM1Pro := oModel:GetValue( "NJRUNICO", "NJR_UM1PRO" ) 
			cUmPrc  := oModel:GetValue( "NJRUNICO", "NJR_UMPRC"  ) 
			cTes    := oModel:GetValue( "NJRUNICO", "NJR_TESEST" )
			cTpCtr  := oModel:GetValue( "NJRUNICO", "NJR_TIPO"   ) 

			aVrSemImps := {}        // Contera Campo e seu respectivo Vr. Campo  aVrSemImps{{'NN8_VALUNI', nValor}}
			aVrSemImps :=   OG430VrSFx(;
			/*Codigo da entidade */ cCodEnt,;
			/*Loja   da entidade */ cLjaEnt,;
			/*Codigo do produto  */ cCodPro,;
			/*Un.Medida Produto  */ cUM1Pro,;
			/*Un.Medida Preço    */ cUmPrc,;            
			/*TES                */ cTes,;
			/*Qtd a Fiscar       */ nQtfixar,;
			/*Valor un. na Um Prc*/ nNN8_VlrUni,;
			/*Moeda              */ nNJrMoeda,;
			/*Tp Ctrato (2 venda)*/ cTpCtr,;
			/*Data da fixacao)   */ dDtfixa,;
			/*Txa de conversao   */ NJR_TXMOED)


			nPosCpo         :=  ASCAN(aVrSemImps,{|x| x[1] == 'NN8_TXMOED' })
			If nPosCpo > 0  
			   oModelNN8:SetValue("NN8_TXMOED",  aVrSemImps[ nPosCpo,2 ]) 
			EndIF

			nPosCpo         :=  ASCAN(aVrSemImps,{|x| x[1] == 'NN8_VALUNI' })
			If nPosCpo > 0
			   oModelNN8:SetValue("NN8_VALUNI",  aVrSemImps[ nPosCpo,2 ])
			EndIf 

			nPosCpo         :=  ASCAN(aVrSemImps,{|x| x[1] == 'NN8_VALTOT' })
			If nPosCpo > 0
			   oModelNN8:SetValue("NN8_VALTOT",  aVrSemImps[ nPosCpo,2 ])        
			EndIf 

			nPosCpo         :=  ASCAN(aVrSemImps,{|x| x[1] == 'NN8_VALLIQ' }) 
			If nPosCpo > 0
			   oModelNN8:SetValue("NN8_VALLIQ",  aVrSemImps[ nPosCpo,2 ]) 
			EndIf 

			nPosCpo         :=  ASCAN(aVrSemImps,{|x| x[1] == 'NN8_VALLQT' })
			If nPosCpo > 0
			   oModelNN8:SetValue("NN8_VALLQT",  aVrSemImps[ nPosCpo,2 ])
			EndIf 

			nPosCpo         :=  ASCAN(aVrSemImps,{|x| x[1] == 'NN8_VLRTOT' })
			If nPosCpo > 0
			   oModelNN8:SetValue("NN8_VLRTOT",  aVrSemImps[ nPosCpo,2 ])        
			EndIf 

			nPosCpo         :=  ASCAN(aVrSemImps,{|x| x[1] == 'NN8_VLRLIQ' })
			If nPosCpo > 0
			   oModelNN8:SetValue("NN8_VLRLIQ",  aVrSemImps[ nPosCpo,2 ]) 
			EndIf 

			nPosCpo         :=  ASCAN(aVrSemImps,{|x| x[1] == 'NN8_VLRLQT' })
			If nPosCpo > 0
			   oModelNN8:SetValue("NN8_VLRLQT",  aVrSemImps[ nPosCpo,2 ])
			EndIf 
			// FIM EnContra Vrs/Vrs.Liquidos Previstos ( retirando os Impostos tipo funrural etc...) --//

			NN8->( MsUnLock() )

			OGA420NKAW( aCompPRC, cItemFx )


	EndIF

	aGrvNKA := {} //--<< Limpa Array de Composiçao de Precos >>--
Return


/*
+=================================================================================================+
| Funçao    : OGA280MV                                                                            |
| Descriçao : Chamada da Amostra Avulsas pelo opçao relacionadas ( OGA180 )                       |
| Autor     : Inacio Luiz Kolling                                                                 |
| Data      : 17/11/2014                                                                          |
+=================================================================================================+     
*/  
Function OGA280MV()
	OGA180(NJR->NJR_CODCTR)
Return

/** {Protheus.doc} OG280NNGVR()
_Funçao de gatilho para Trazer o Vr. NNG_VLRCSS(VALOR CADENCIA),Gatilho do campo: NNG_QTDCSS
ao informar a Qtidade, a Rotina considera q Qtd. informada esta na Um. do Ctrato Aba Quantidades
@param:     oModel - Modelo de dados
@return:    nRetorno - Valor Calculado
@author:    Emerson coelho
@since:     15/12/2014
@Uso:       OGA280-Contrato de Compra
*/
Function OG280NNGVR()
	Local nTotal := 0
	Local oModel := FwModelActive()

	If cPaisLoc == "PAR" .Or. cPaisLoc == "ARG"
		nTotal:= oModel:GetValue("NJRUNICO","NJR_VLRBAS") * AGRX001(  oModel:GetValue("NJRUNICO","NJR_UM1PRO"), oModel:GetValue("NJRUNICO","NJR_UMPRC"), oModel:GetValue("NNGUNICO","NNG_QTDCSS"), oModel:GetValue("NJRUNICO","NJR_CODPRO")  )		
	Else
		nTotal:= oModel:GetValue("NJRUNICO","NJR_VLRUNI") * AGRX001(  oModel:GetValue("NJRUNICO","NJR_UM1PRO"), oModel:GetValue("NJRUNICO","NJR_UMPRC"), oModel:GetValue("NNGUNICO","NNG_QTDCSS"), oModel:GetValue("NJRUNICO","NJR_CODPRO") )		
	EndIf
Return(nTotal)

/** {Protheus.doc} fGetTrcNum
Descriçao: Verifica se o Contrato de compra esta relacionado a um acordo de Troca
e retorna o Nr. do acordo de troca para Caso Esteja 

@param:     Nil
@author:    Gilson Venturi
@since:     31/03/2015
@Uso:       OGA280 
*/

Static Function fGetTrcNum()

	Local cTrcNum := ''
	If AliasInDic("NKT") //-- Tabela ref. ao Processo de Troca --//
		dbSelectArea( "NKT" )
		NKT->( dbSetOrder( 2 ) ) //NKT_FILIAL+NKT_CODCTR
		If NKT->( dbSeek( fWxFilial( "NKT" ) + NJR->NJR_CODCTR ) )
			cTrcNum := NKT->NKT_TRCNUM
		EndIf
	EndIF

Return (cTrcNum)

/** {Protheus.doc} lDelTitFin
Descriçao: Exclui Titulo Financeiro

@param:     Nil
@author:    Agroindustria
@since:     15/10/2015
@Uso:       OGA280 
*/
Static Function lDelTitFin(cCtrDoc, cCodEnt, cLojEnt)
	Local   cE2Parcel   := ''
	Local   lContinua   := .t.
	local   aLinVncAux2 := {}
	Local   aVncCPag	:= {}

	Private lMsErroAuto := .f.


	NJ0->( dbSetOrder( 1 ) )
	NJ0->( dbSeek( xFilial( "NJ0" ) + cCodEnt + cLojEnt ) )

	/** Gera titulos provisorios no financeiro */
	cPrefixo    := PadR( "CTR", TamSX3( "E2_PREFIXO" )[1] )
	cNumero     := PadR( cCtrDoc, TamSX3( "E2_NUM" )[1] )
	cTipTit     := PadR( "PR", TamSX3( "E2_TIPO" )[1] )
	

	NN7->( dbSetOrder( 1 ) )
	NN7->( dbSeek( xFilial( "NN7" ) +cCtrDoc ) )

	While .Not. NN7->( Eof() ) .And. NN7->( NN7_FILIAL ) = xFilial( "NN7" ) .And. NN7->( NN7_CODCTR ) = cCtrDoc

		cE2Parcel := PadR(Alltrim(NN7->NN7_PARCEL), TamSX3( "E2_PARCELA" )[1] )

		/*Verifica a existencia de titulo**/
		dbSelectArea( "SE2" )
		dbSetOrder( 1 )
		//If dbSeek( xFilial( "SE2" ) + cPrefixo + cNumero + NN7->( NN7_PARCEL ) + cTipTit +  NJ0->( NJ0_CODFOR ) + NJ0->( NJ0_LOJFOR )  )
		If dbSeek( xFilial( "SE2" ) + cPrefixo + cNumero + cE2Parcel + cTipTit +  NJ0->( NJ0_CODFOR ) + NJ0->( NJ0_LOJFOR )  )
			aFina050 := {}

			aAdd( aFina050, { "E2_FILIAL" ,  SE2->E2_FILIAL             , Nil } )
			aAdd( aFina050, { "E2_PREFIXO" , SE2->E2_PREFIXO            , Nil } )
			aAdd( aFina050, { "E2_NUM"     , SE2->E2_NUM                , Nil } )
			aAdd( aFina050, { "E2_PARCELA" , SE2->E2_PARCELA            , Nil } )
			aAdd( aFina050, { "E2_TIPO"    , SE2->E2_TIPO               , Nil } )
			aAdd( aFina050, { "E2_FORNECE" , SE2->E2_FORNECE            , Nil } )
			aAdd( aFina050, { "E2_LOJA"    , SE2->E2_LOJA               , Nil } )

           //Removento o vinculo da SE2 
			aLinvncAux2 := {}
			aadd( aLinvncAux2, { "N8M_FILIAL"    	, FwXfilial('N8M') 				} )
			aadd( aLinvncAux2, { "N8M_PREFIX"    	, PadR(Alltrim(cPrefixo), TamSX3( "N8M_PREFIX" )[1] )				} )
			aadd( aLinvncAux2, { "N8M_NUM"    		, PadR(Alltrim(cNumero), TamSX3( "N8M_NUM" )[1] ) 				} )
			aadd( aLinvncAux2, { "N8M_PARCEL"    	, PadR(Alltrim(cE2Parcel), TamSX3( "N8M_PARCEL" )[1] )				} )
			aadd( aLinvncAux2, { "N8M_TIPO"    		, PadR(Alltrim(cTipTit), TamSX3( "N8M_TIPO" )[1] )				} )
			aadd( aLinvncAux2, { "N8M_FORNEC"    	, PadR(Alltrim(NJ0->( NJ0_CODFOR )), TamSX3( "N8M_FORNEC" )[1] )	} )
			aadd( aLinvncAux2, { "N8M_LOJA"    		, PadR(Alltrim(NJ0->( NJ0_LOJFOR )), TamSX3( "N8M_LOJA" )[1] )	} )
					
			aAdd(aVncCPag, aLinvncAux2)
			        
			MSExecAuto({|x,y,z| fina050(x,y,z)},aFina050,,5)
			If lMsErroAuto
				MostraErro()
				lContinua := .f.
				Exit
			EndIf

		Endif
		NN7->( dbSkip() )
	EndDo    

	If lContinua .and.  len( aVncCPag ) > 0
		lContinua := fAgrVncPag (aVncCPag, 5 )  //Excluir
	EndIF


Return( lContinua )

/** {Protheus.doc} oGa280NK6
ESTA ROTINA FOI DEIXADA AQUI SOMENTE PARA QUE NÃO DÉ ERRO NO
FATA400. POIS O PROCESSO DE TROCA NÃO FOI APORVADO PELA SEMENTES GOIAS 
E TIVEMOS Q REFAZE-LO. POREM A VANILDA ABRIU CHAMADO PARA IMPLEMENTAR AS
ALTERAÇÕES NO FATA400. AGORA(20/06/2015) TEMOS O FATA400 REFERENCIANDO ESSA ROTINA
MAS NAO MAIS UTILIZAMOS ESSA ROTINA, PORQUE O PROCESSO DE TROCAS FOI TODO REFORMULADO.
A PEDIDO DA SG.

ASSIM QUE OUTRO CHAMADO FOR ABERTO PARA RETIRAR A REFERENCIA A ESSA ROTINA NO FATA400
E INCLUIR AS NOVAS, DEVEMOS REMOVER-ESTA ROTINA

chamada do FATA400
@param:     nOpca  1 = Inclusao ,  2 = Alteraçao , 3 = Delete
@author:     Emerson Coelho
@since:     02/10/2014
@Uso:         SIGAARM - Originaçao de Graos
*/
Function oGa280NK6(nOPc)

Return( .T. )
/** {Protheus.doc} oGa280TrOk
ESTA ROTINA FOI DEIXADA AQUI SOMENTE PARA QUE NÃO DÉ ERRO NO
FATA400.
ASSIM QUE OUTRO CHAMADO FOR ABERTO PARA RETIRAR A REFERENCIA A ESSA ROTINA NO FATA400
E INCLUIR AS NOVAS, DEVEMOS REMOVER-ESTA ROTINA	
*/
Function oGa280TrOk()

Return ( .T. )
/** {Protheus.doc} oGa280Parc
ESTA ROTINA FOI DEIXADA AQUI SOMENTE PARA QUE NÃO DÉ ERRO NO
FATA400.
ASSIM QUE OUTRO CHAMADO FOR ABERTO PARA RETIRAR A REFERENCIA A ESSA ROTINA NO FATA400
E INCLUIR AS NOVAS, DEVEMOS REMOVER-ESTA ROTINA	
*/
Function oGa280Parc()

	Return ( .T. )

	/*/{Protheus.doc} ValLine(oModelGrid, nLinha, cAcao, cCampo,xVrNovo,xVrNovo)
	Rotina de Pre validaçao do modelo
	@param oModelGrid Modelo
	@param nLinha Linha corrente
	@param cAcao  Açao ("DELETE", "SETVALUE", e etc)
	@since 12/09/2013
	@version 1.1
	/*/
//------------------------------------------------------------------
Static Function PreValNNY(oModelNNY, nLinha, cAcao, cCampo,xVrNovo,xVrAnt)
	Local lRet		:= .T.
	Local oModel		:= oModelNNY:GetModel()
	Local oModelNJR  	:= oModel:GetModel("NJRUNICO")

	If cAcao == "CANSETVALUE" .AND. cCampo == "NNY_QTDINT" .AND. oModelNJR:GetValue("NJR_STATUS") $ "A|I"
		Return (.F.) //não deve alterar a quantidade depois de confirmado
	EndIf 
    If cAcao == "SETVALUE" .And. cCampo == "NNY_DATINI" 
		AGRXDTNNY(oModelNNY, xVrNovo) //se o data fim estiver vazio, preenche com o inicial.
	ElseIf cAcao == 'SETVALUE' .And. cCampo == 'NNY_FILORG'	
		AGRXFILORG(oModelNNY, nLinha, cAcao, cCampo,xVrNovo,xVrAnt)
    EndIf
	//atualizo o campo NJR_QTDINI e valido as quantidades.
    lRet := AGRXATUQTD(oModelNNY, cAcao, xVrNovo, xVrAnt, nLinha, cCampo )	

Return (lRet)

/** {Protheus.doc} OGA280VNC
Descriçao:  Valida o valor se nao esta cancelado ou finalizado.
@param:     Nil
@author:    Vinicius Becher Pagung
@since:     29/01/2016
@Uso:       OGA280 
*/
Function OGA280VNC()
	Local lRetorno  := .T.

	If NJR->NJR_STATUS == "E"
		Help(,, STR0034,,STR0115 , 1, 0 ) 
		lRetorno := .f.
	ElseIf NJR->NJR_STATUS == "F"
		Help(,, STR0034,,STR0114 , 1, 0 ) 
		lRetorno := .f.
	Else
		OGA285(NJR->NJR_TIPO,NJR->NJR_CODCTR)
	EndIf
Return ( lRetorno )

/** {Protheus.doc} ValCancel
Descriçao:  Validaçao para verificar se existe vinculo e barrar cancelamento caso possuir.
@param:     Nil
@author:    Vinicius Becher Pagung
@since:     17/03/2016
@Uso:       OGA280 
*/
STATIC Function ValCancel()
	Local cCodCtr       := NJR->NJR_CODCTR
	Local cAliasNKB     := GetNextAlias()
	Local lRet          := .f.

	BeginSql Alias cAliasNKB
	SELECT SUM(NKB_QTDADE) as NKB_QTDADE
	FROM %Table:NKB% NKB
	WHERE NKB.%notDel% 
	AND NKB_FILIAL = %xFilial:NKB% 
	AND NKB_CTRCOM = %Exp:cCodCtr%         
	GROUP BY NKB_CTRCOM                
	EndSQL

	(cAliasNKB)->( dbGoTop() )
	If !(cAliasNKB)->( Eof() )
		lRet := .t.
	Endif
	(cAliasNKB)->( dbCloseArea() ) 

Return (lRet)

/*/{Protheus.doc} OGA280WEXC
//TODO Função para habilitar/desabilitar campo NJR_TOLENT(WHEN)
@author claudineia.reinert
@since 27/05/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OGA280WTEN() 
	Local lRet := .F.
	Local oModel		:= FwModelActive()
	Local oNJR			:= oModel:GetModel( "NJRUNICO" )
	
	If oNJR:GetValue("NJR_TPEXC") == '3' //3-Percentual
		lRet  := .T.
	Else
		lRet  := .F.  
	EndIf 

Return lRet

/*/{Protheus.doc} PreValNJR()
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
 Static Function PreValNJR(oFieldModel, cAction, cIDField, xValue)
	Local oModel  := FwModelActive()
	Local lRet	   := .T.
	
	If ValType(oModel) == "U" //proteção quando o set é chamado de outra função (agrxctr)
		Return lRet
	EndIf 

	//SETVALUE
	If cAction == "SETVALUE" .AND. cIDField $ "NJR_CODPRO"		
		oFieldModel:ClearField("NJR_TABELA")		
		lRet := AGRXCODPRO( oFieldModel, xValue, oFieldModel:GetValue("NJR_TABELA")  )	
		Return lRet
	ElseIf cAction == "SETVALUE" .AND. cIDField $ "NJR_TABELA"	
		lRet := AGRXVLTAB(oFieldModel, xValue)//tabela	
		Return lRet
	ElseIf cAction == "SETVALUE" .AND. cIDField $ "NJR_CODENT|NJR_LOJENT"
		If cIDField == "NJR_CODENT"
			lRet := AGRXVLFAV(oFieldModel,xValue,oFieldModel:GetValue("NJR_LOJENT"))
		Else
			lRet := AGRXVLFAV(oFieldModel,oFieldModel:GetValue("NJR_CODENT"),xValue)
		EndIf
		Return lRet
	ElseIf cAction == "SETVALUE" .AND. cIDField $ "NJR_TIPFIX"
		If AGRXVALFIX(oFieldModel:GetValue("NJR_CODCTR"))
			Do Case
				Case xValue == '1'
				Help( , , STR0034, , STR0083, 1, 0 ) //'Contrato ja possui fixaçao de preços como Firme, mudando o tipo de fixaçao para A Fixar , a mesma sera Gravada Como Prevista'
				Case xValue == '2'
				Help( , , STR0034, , STR0084, 1, 0 ) //"AJUDA"###'Contrato ja possui fixaçao de preços como Prevista, mudando o tipo de fixaçao para Fixo, a mesma sera Gravada Como Firme'
			EndCase		
		EndIF
	ElseIf cAction == "SETVALUE" .AND. cIdField == "NJR_TPFRET" 
		If xValue != 'F' .AND. oFieldModel:HasField("NJR_CLASSF")
			oFieldModel:LoadValue( "NJR_CLASSF", '1')	//1 = NÃO CONTROLA			
		EndIF 
	EndIf 

	If cAction == "SETVALUE" .And. __lnewNeg .And. cIDField $ "NJR_TESEST|NJR_CODFIN|NJR_CODENT|NJR_LOJENT|NJR_CODPRO|NJR_CTREXT|"
	//atualiza os campos da N9A.
		lRet := AGRXAtuN9A(oFieldModel, cAction, cIDField, xValue)
		Return lRet
	ElseIf cAction == "SETVALUE" .And. cIDField $ "NJR_CONDPG"
		lRet := AGRXNJRCdPg( oFieldModel, cIDField, xValue)  
		Return lRet
	ElseIf cAction == "SETVALUE" .And. cIDField $ "NJR_DIASPG"
		lRet := AGRXDiasPg( oFieldModel, cIDField, xValue) 
		Return lRet
	ElseIf cAction == "SETVALUE" .And. cIDField $ "NJR_CONDPA"
		//preenche a codigo 
		cCodRem := AGRXTrgCdPg(oFieldModel, xValue)
		oFieldModel:SetValue("NJR_CODREM",cCodRem)
		//preenche a descrição
		cDesRem := AGRXDesRem(oFieldModel, xValue)
		oFieldModel:SetValue("NJR_DESREM",cDesRem)
	ElseIf cAction == "SETVALUE" .And. cIDField $ "NJR_INCOTE"
		//preenche o tipo
		cTpEvo := AGRXTrgInc(oFieldModel, xValue)
		oFieldModel:SetValue("NJR_TPSEVO",cTpEvo)	
	ElseIf cAction == "SETVALUE" .AND. cIDField $ "NJR_TIPMER"
		//gatilhos para N9A e NNF
		AGRXTrgNNF(oFieldModel, xValue) 

		If xValue == "1"
			oFieldModel:ClearField("NJR_CONDPA")
			oFieldModel:ClearField("NJR_VIA")
			oFieldModel:ClearField("NJR_INCOTE")
			oFieldModel:ClearField("NJR_CODREM")
		EndIf
	ElseIf cAction == "SETVALUE" .AND. cIDField $ "NJR_OPETRI|NJR_OPEFUT"
		AGRXTrgOPER(oFieldModel, cIDField, xValue)
	EndIf

	If cAction == "ISENABLE" .AND. cIDField $ "NJRUNICO" .AND. oFieldModel:GetOperation() == 3
		oFieldModel:SetValue("NJR_TIPO",'1')
		oFieldModel:SetValue("NJR_MODELO",'2')
	EndIf  

Return lRet

/*/{Protheus.doc} PosValNJR()
	Pos valid do modelo NJRUNICO
	@type  Static Function
	@author mauricio.joao
	@since 10/12/2019
	@version 1.0
/*/
 Static Function PosValNJR(oFieldModel)

 If lRet := ValCpoFis( oFieldModel )
    lRet := AGRXPOSNJR(oFieldModel) 
 EndIf

Return lRet

/*/{Protheus.doc} PreValNN7()
	Pre validação do modelo NN7UNICO
	@type  Static Function
	@author mauricio.joao
	@since 11/12/2019
	@version 1.0
	/*/
 Static Function PreValNN7(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
 Local lRet := .T.

If cIDField == "NN7_PARCEL" .And. cAction == "SETVALUE"
	If Empty(xValue)
		Return .F.
	EndIf
EndIf

Return lRet


/** {Protheus.doc} PreValN9A(oModelGrid, nLinha, cAcao, cCampo,xVrNovo,xVrNovo)
Rotina de Pre validação do modelo
@param oModelGrid Modelo
@param nLinha Linha corrente
@param cAcao  Ação ("DELETE", "SETVALUE", e etc)
@since 09/01/2017
@version 1.1
*/
Static Function PreValN9A(oN9A, nLinha, cAcao, cCampo,xVrNovo,xVrAnt)
	Local lRet 		:= .T.
	Local oModel    := oN9A:GetModel()
	Local lIsTakeUp := (FwIsInCallStack("AGRA720N9A") .OR. FwIsInCallStack("OGC020EST") .OR. FwIsInCallStack("AGRA720INAT")) // Processo de Take-Up
	Local lRfResum	:= (FwIsInCallStack("OGX290OK") .OR. FwIsInCallStack("OGX290MACT")) // Regras Fiscais View - Resumida
	
	//HELP: Operação não permitida.
	If !(IsInCallStack("OGX700CTR") .OR. IsInCallStack("OGX700ACTR") .OR. lRfResum .OR. lIsTakeUp) .AND. __lnewNeg
		
		//Não é permitido eliminar uma Regra Fiscal com Quantidade Instruída ou Quantidade NF.
		If cAcao == 'DELETE' 
			If oN9A:GetValue("N9A_QTDINS") <> 0 .Or. oN9A:GetValue("N9A_QTDNF") <> 0  
				Help(" ", 1, "OGA290DELRFIS")
				lRet := .F.			
			EndIf
		ElseIf cAcao == "CANSETVALUE" 
			//no CANSETVALUE não é acionado o help devido o campos ser bloqueado - ADICIONAR ESSA REGRA NA DOCUMENTACAO
			//todos os campos serão bloqueado se houver quantidade instruída. Exceto o campo quantidade e ptax
			If cCampo == "N9A_QUANT" .OR. cCampo == "N9A_TRVTAX"
				//não faz nada. Removido a validação pois estava travando o processo quando a quantidade eram igual mas existia saldo para instruir.	
			ElseIf cCampo $ "N9A_VLTDES|N9A_VLUDES"
				lRet := .F.
			ElseIf cCampo $ "N9A_DATINI|N9A_DATFIM|N9A_DTLTKP"
				If AGRTPALGOD(NJR->NJR_CODPRO) .AND. (Empty(oN9A:GetValue("N9A_TAKEUP"))) //verifico se é algodão e o take tá preenchido
					lRet := .T.
				Else
					lRet := .F.
				EndIf
			Else				
				//não permite alterar
				If oN9A:GetValue("N9A_QTDINS", nLinha) > 0
					//Help(nil, nil, , STR0031, STR0225, 1, 0 )  // AJUDA # Esta Regra fiscal já possui quantidade instruída, por este motivo não é permitido realizar alterações nesta linha. 
					lRet := .F.
				EndIf	
			EndIf
		Elseif cAcao == "SETVALUE"
			If cCampo == "N9A_TAKEUP"
				DbSelectArea("DXP")
				DbSetOrder(1)
				If DbSeek(oModel:GetValue("NJRUNICO","NJR_FILIAL") + xVrNovo )
					oN9A:SetValue("N9A_FILORG",DXP->DXP_FILIAL)
				EndIf
			elseIf cCampo == "N9A_CODFIN" .AND. TableInDic('NLM')
				DbSelectArea("NLM")
				DbSetOrder(1)
				If DbSeek(xFilial("NLM")+xVrNovo)
					oN9A:SetValue("N9A_OPEFIS",NLM->NLM_CODOPE)
				EndIf		
			EndIf
		EndIf
		
		//utilizado para bloquear as regras fiscais que possuam romaneio emitido.
		If FwIsInCallStack("OGX290") .AND. !Empty(oModel:GetValue("N9AUNICO","N9A_CODROM"))
			Help(" ", 1, "OGA290DELRFIS2")
			lRet := .F.
		EndIf
			
	ElseIf cAcao == "SETVALUE" //ao tentar setar um valor
		
		//permite somente alterar a quantidade se já houver valor faturado
		If cCampo == "N9A_QUANT"
			If !lIsTakeUp 
				If xVrNovo < oN9A:GetValue("N9A_QTDTKP", nLinha) // Não é take, então valida as quantidades.
		    		Help("", 1, "OGA290QTTKUPVL") // # A quantidade informada deve ser igual ou superior a quantidade de take-up realizado.                                   
				lRet := .F.
				EndIf 

				// Obtem a maior quantidade entre QTD NF e QTD INSTR
				If oN9A:GetValue("N9A_QTDINS", nLinha) >= oN9A:GetValue("N9A_QTDNF", nLinha)
					cQtdMax := "N9A_QTDINS"
				ElseIf oN9A:GetValue("N9A_QTDINS", nLinha) < oN9A:GetValue("N9A_QTDNF", nLinha)
					cQtdMax	:= "N9A_QTDNF"
				EndIf

				// Se for menor que o valor MÁXIMO
				If xVrNovo < oN9A:GetValue(cQtdMax, nLinha)
					Help("", 1, "OGA290QTDNFINS") // A quantidade informada deve ser igual ou superior a quantidade (faturada/recebida) ou a quantidade instruída. 
					lRet := .F.
				EndIf

			EndIf
		EndIf 
	
	EndIf

   If cAcao == "SETVALUE" .And. cCampo == "N9A_TES" .And. __lnewNeg
		lDuplic := Posicione("SF4", 1, xFilial("SF4") + xVrNovo, "F4_DUPLIC") == "S" 
		lEstoq  := Posicione("SF4", 1, xFilial("SF4") + xVrNovo, "F4_ESTOQUE") == "S"			
		If !lDuplic .Or. lEstoq 
			oN9A:SetValue("N9A_OPEFUT","2") //2-Não
		EndIf

		lEnt := oN9A:GetValue("N9A_CODENT")+oN9A:GetValue("N9A_LOJENT")  == oN9A:GetValue("N9A_ENTENT")+oN9A:GetValue("N9A_LJEENT")
		If lEnt
			oN9A:SetValue("N9A_OPETRI","2") //Retorna 2-Não
		EndIf
   EndIf		

Return lRet

/*/{Protheus.doc} fN9AVlUFa
Função responsavel em iniciar o Valor Unit. Faturamento quando uma linha for inserida na grid
@type  Static Function
@author rafael.kleestadt
@since 18/10/2018
@version 1.0
@param oField, object, objeto do campo
@return nValor, numeric, valor inicial copiado da linha superior
@example
(examples)
@see (links_or_references)
/*/
Static Function fN9AVlUFa(oField)
	Local nValor := 0
	Local oModel := oField:GetModel()
	Local oN9A   := oModel:GetModel( "N9AUNICO" )
	
	If oN9A:Length() >= 1
	
		nValor := oN9A:GetValue("N9A_VLUFPR", oN9A:Length())
		
	EndIf

Return nValor


/*{Protheus.doc} OGX280POSV
//Função de validação acionada ao confirmar, engloba as validações
ao confirmar a alteração das regras fiscais.
@author roney.maia / Filipe Olegini
@since 23/03/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
*/
Static Function OGX280POSV()

	Local oModel    := FwModelActive()
	Local aArea  	:= GetArea()
	Local lRet		:= .T.
	Local oModelNJR	as Object
	Local oModelN9A	as Object
	Local oModelN9D	as Object
	Local oModelNNY as Object
	Local nIt		:= 0
	Local nX		:= 0
	Local cMsg		:= ""
	Local aFardVer	:= {}	
	Local cRmTkp	:= ""

	Local nVldTkp   := 0 //Quando o ctr for de algodão, não pode ter mais de uma regra sem cod. tkp.

	If IsInCallStack('AGRA720INAT') .OR. Valtype(oModel) == "U"
		return .T.
	EndIf

	oModelNJR	:= oModel:GetModel("NJRUNICO")
	oModelN9A	:= oModel:GetModel("N9AUNICO")
	oModelN9D	:= oModel:GetModel("N9DUNICO")
	oModelNNY   := oModel:GetModel("NNYUNICO")
	
	// ################################# VALIDAÇÃO DE REGRAS COM LINHAS DELETADAS E POSSUEM FARDOS NÃO DELETADOS ##################################
	For nIt := 1 To oModelN9A:Length()

		oModelN9A:GoLine(nIt)
	
		If 	AGRTPALGOD(oModelNJR:GetValue("NJR_CODPRO"));
			.AND.!oModelN9A:isDeleted();
			.AND. Empty(oModelN9A:GetValue("N9A_TAKEUP", nIt)) //não deletado e vazio cod takeup.
			//adiciona um.
			nVldTkp++
			//se for maior do que 2, bloqueia.
			If nVldTkp >= 2
				Help( , , STR0151, , STR0152, 1, 0 )  //" Não é permitido existir mais de uma Regra Fiscal sem codigo de TakeUp vinculado."
				Return .F.
			EndIf
		EndIf

		If oModelN9A:isDeleted() .AND. oModelN9D:Length(.T.) > 0 // Se a regra fiscal esta deletada e possue linhas não deletadas então valida
			For nX := 1 To oModelN9D:Length()
				// Verifica as linhas que não estão deletadas e que possuem fardos, descartando linahs vazias.
				If !oModelN9D:IsDeleted(nX) .AND. (!Empty(oModelN9D:GetValue("N9D_FILIAL", nX)) .AND. !Empty(oModelN9D:GetValue("N9D_SAFRA", nX)) .AND. !Empty(oModelN9D:GetValue("N9D_FARDO", nX));
				   .AND. !Empty(oModelN9D:GetValue("N9D_CODFAR", nX)) .AND. !Empty( oModelN9D:GetValue("N9D_FILORG", nX)))
				
					aAdd(aFardVer, {oModelN9D:GetValue("N9D_FILIAL", nX), oModelN9D:GetValue("N9D_SAFRA", nX), ;
								oModelN9D:GetValue("N9D_FARDO", nX), "04", oModelN9D:GetValue("N9D_CODFAR", nX), oModelN9D:GetValue("N9D_FILORG", nX)})
				EndIf
			Next nX
			
			If !Empty(aFardVer)
				lRet := OGC040VEMB(aFardVer, "Exclusão de Regras Fiscais") // Verifica os fardos com IE # "Exclusão de Regras Fiscais" .T. - Valido , .F. - Invalido possue fardos com IE

				If lRet // Verifica os fardos com take-up que não estão deletados
					For nX := 1 To Len(aFardVer)
						If lRet
							cMsg := STR0149 + ": " + oModelN9A:GetValue("N9A_SEQPRI") + _CRLF // # "Existem fardos vinculados a regra fiscal."
							cMsg +=  STR0150 + _CRLF + _CRLF // # "Para prosseguir com a exclusão será necessário desvincular os fardos."
							lRet := .F.
						EndIf
						cMsg += "Filial"+ ": " + AllTrim(aFardVer[nX][1]) + ; // "Filial"
							"  " +  "Fardo" + ": " + AllTrim(aFardVer[nX][5]) + ; // "Fardo"
							"  " + "Safra" + ": " + AllTrim(aFardVer[nX][2]) + ; // Safra
							"  " + "Etiqueta" + ": " + AllTrim(aFardVer[nX][3]) + _CRLF // # Etiqueta
					Next nX
					
					If !lRet
						Aviso(STR0148, cMsg) // Apresenta tela de aviso // "Exclusão de Regras Fiscais"
					EndIf	
				EndIf 
			EndIf

			If !lRet // Caso inválido, não é necessario validar o resto
			//	FwRestRows(aSaveRows)
				RestArea(aArea)
				Return .F.
			EndIf
		EndIF
		
		//valida os itens deletados
		IF oModelN9A:isDeleted(nIt)
			//verifica a quantidade na precificação
			If oModelNJR:GetValue("NJR_TIPFIX") == "2" .AND. AGRTPALGOD(oModelNJR:GetValue("NJR_CODPRO"))
				if fChkQtdPrc(oModelNJR:GetValue("NJR_FILIAL"), oModelNJR:GetValue("NJR_CODCTR") , oModelNNY:GetValue("NNY_ITEM") , oModelN9A:GetValue("N9A_SEQPRI",nIt) ) > 0
					Help( , , STR0034, , STR0147, 1, 0 )  //"Existem quantidades vinculadas de preço para a regra fiscal deletada, favor verificar a quantidade vinculada a regra fiscal no programa de Precificação."
					Return .f.
				endif
			EndIf
		endif
		
		IF !(oModelN9A:isDeleted())

			//Não pode estar Operação triangular = SIM, e Venda Futura = SIM. 
			If 	oModelN9A:GetValue("N9A_OPETRI", nIt) == '1' .AND.  oModelN9A:GetValue("N9A_OPEFUT", nIt)  == '1'
				Help('',1,".OGA290000005.") //"AJUDA"###Não é possivel criar um contrato com Operação Futura e Operação Triangular.  
				Return .F.
			EndIf

            If  (oModelN9A:GetValue("N9A_OPETRI", nIt) == '1' .OR. oModelN9A:GetValue("N9A_OPEFUT", nIt) == '1') .AND. Empty(oModelN9A:GetValue("N9A_TESAUX", nIt))
			 	Help('',1,".OGA290000006.") //"AJUDA"###É necessario limpar o campo TES de Remessa para alterar a operação da regra fiscal.       
			 	Return .F.		
			EndIf

            //Validar se a regra possui operação futura ou triagular quando o campo TES REM está preenchido
			If !Empty( oModelN9A:GetValue("N9A_TESAUX", nIt) ) .AND. (oModelN9A:GetValue("N9A_OPETRI", nIt) == '2' .AND.  oModelN9A:GetValue("N9A_OPEFUT", nIt) == '2' )
				Help('',1,".OGA290000008.") //"AJUDA"###Para um contrato com Operação Triangular é necessario informar a Entidade e Loja de Entrega.     
			 	Return  .F.	
			EndIf				
		
			lDuplic := Posicione("SF4", 1, xFilial("SF4") + oModelN9A:GetValue("N9A_TES"), "F4_DUPLIC") == "S" 
			lEstoq  := Posicione("SF4", 1, xFilial("SF4") + oModelN9A:GetValue("N9A_TES"), "F4_ESTOQUE") == "S"
			lEnt    := oModelN9A:GetValue("N9A_CODENT", nIt)+oModelN9A:GetValue("N9A_LOJENT", nIt)  == oModelN9A:GetValue("N9A_ENTENT", nIt)+oModelN9A:GetValue("N9A_LJEENT", nIt)
			lMerInt := oModelNJR:GetValue("NJR_TIPMER") = '1' //Interno
			
			//HELP: Op Futura Inválida 
			//SOLUÇÃO: Op Futura só pode ser marcada como “Sim” quando contrato for do tipo “Mercado Interno”, 
			//         a TES estiver parametrizada como ‘Gerar Duplicatas’ = “Sim” e ‘Atualiza Estoque’ = “Não” 
			If oModelN9A:GetValue("N9A_OPEFUT", nIt ) == '1' .And. ( !lDuplic .Or. lEstoq .Or. !lMerInt) 
				Help(" ", 1, "OGA290OPEFUT")
				Return .F.
			EndIf 
			
			//HELP: Op Triangular Inválida 
			//SOLUÇÃO: Op Triangular só pode ser marcada como “Sim” quando contrato for do tipo “Mercado Interno”
			//         e a TES estiver parametrizada como ‘Gerar Duplicatas’ = “Sim” e ‘Atualiza Estoque’ = “Não”
			//         e Entidade for diferente da Entidade Entrega. 
			If oModelN9A:GetValue("N9A_OPETRI", nIt) == '1' .And. ( !lDuplic .Or. lEstoq .Or. !lMerInt .Or. lEnt)
				Help(" ", 1, "OGA290OPETRI")
				Return .F.
			EndIf 
				
			If  (oModelN9A:GetValue("N9A_OPETRI", nIt) == '1' .OR. oModelN9A:GetValue("N9A_OPEFUT", nIt) == '1') .AND. Empty(oModelN9A:GetValue("N9A_TESAUX", nIt))
			 	Help('',1,".OGA290000006.") //"AJUDA"###É necessario limpar o campo TES de Remessa para alterar a operação da regra fiscal.       
			 	Return .F.		
			EndIf
		
			//Quando operação triangular = SIM, deve ter Entidade Entrega/loja preenchidos.
			If oModelN9A:GetValue("N9A_OPETRI", nIt) == '1' .AND. Empty(oModelN9A:GetValue("N9A_ENTENT",nIt)) 
			 	Help('',1,".OGA290000007.") //"AJUDA"###Para um contrato com Operação Triangular é necessario informar a Entidade e Loja de Entrega.     
			 	Return  .F.			
			EndIf	
			
			//Validar se a regra possui operação futura ou triagular quando o campo TES REM está preenchido
			If !Empty( oModelN9A:GetValue("N9A_TESAUX", nIt) ) .AND. (oModelN9A:GetValue("N9A_OPETRI", nIt) == '2' .AND.  oModelN9A:GetValue("N9A_OPEFUT", nIt) == '2' )
				Help('',1,".OGA290000008.") //"AJUDA"###Para um contrato com Operação Triangular é necessario informar a Entidade e Loja de Entrega.     
			 	Return  .F.	
			EndIf	
			
			//verifica a quantidade na precificação
			If oModelNJR:GetValue("NJR_TIPFIX") == "2" .AND. AGRTPALGOD(oModelNJR:GetValue("NJR_CODPRO"))
				if fChkQtdPrc(oModelNJR:GetValue("NJR_FILIAL"), oModelNJR:GetValue("NJR_CODCTR") , oModelNNY:GetValue("NNY_ITEM") , oModelN9A:GetValue("N9A_SEQPRI",nIt) ) > oModelN9A:GetValue("N9A_QUANT", nIt)
					Help( , , STR0034, , STR0146, 1, 0 )  //"Existem quantidades vinculadas de preço para a regra fiscal, favor verificar a quantidade vinculada a regra fiscal no programa de Precificação."
					Return .f.
				endif
			EndIf
						 
		EndIf
	Next nIt
	// ####################################################################################################################
	
	If !Empty(__aOGX290FR)
		cMsg :=  STR0145 + _CRLF + _CRLF // # "Existem fardos sem vínculo de Take-Up."
		For nX := 1 To Len(__aOGX290FR)
			If !(__aOGX290FR[nX][1] $ cRmTkp) 
				cMsg += "Código do Take-Up" + ": " + __aOGX290FR[nX][1] + _CRLF + _CRLF // # "Código do Take-Up"
				cRmTkp += __aOGX290FR[nX][1] + ";"
			EndIf

			cMsg += 'Filial'+ ": " + AllTrim(__aOGX290FR[nX][2]) + ; // "Filial"
				"  " + 'Fardo' + ": " + AllTrim(__aOGX290FR[nX][5]) + ; // "Fardo"
				"  " + 'Safra' + ": " + AllTrim(__aOGX290FR[nX][3]) + ; // Safra
				"  " + 'Etiqueta' + ": " + AllTrim(__aOGX290FR[nX][4]) + _CRLF // # Etiqueta
		Next nX

		// Necessário pois o box de Aviso, apresenta linhas maiores com quantidades de linhas inferiores a 1 fardo
		For nX := 1 To 20
			cMsg += _CRLF
		Next nX

		Aviso(STR0144, cMsg) // Apresenta tela de aviso // # "Fardos sem vínculo de Take-Up"		
		
		Return .F.
	EndIf
	
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} fChkQtdPrc
Verifica quantidade de preço vinculada
@type function
@version 
@since 18/09/2020
@param cFilCtr, character, param_description
@param cCodCtr, character, param_description
@param cCodCadenc, character, param_description
@param cCodRegra, character, param_description
@return return_type, return_description
/*/
static function fChkQtdPrc(cFilCtr, cCodCtr , cCodCadenc, cCodRegra )
	Local nQtd := 0
	
	DbSelectArea("N8D") 
	N8D->(DbSetOrder(3))
	If N8D->(DbSeek( cFilCtr + cCodCtr + cCodCadenc  ))
		While N8D->( !Eof() ) .and. alltrim(N8D->(N8D_FILIAL+N8D_CODCTR+N8D_CODCAD))= alltrim(cFilCtr + cCodCtr + cCodCadenc )
			if N8D->N8D_REGRA == cCodRegra
				nQtd += N8D->(N8D_QTDVNC) 
			endif
			N8D->(DbSkip())
		EndDo		
	EndIf
	
return nQtd

/*/{Protheus.doc} OGXN8MVLD
Valida o tamanho de campo N8M_PARCEL com o tamanho do campo E2_PARCELA.
Foi ajustado no dicionario, porem para os clientes ja existentes é necessario ajuste manual.
@type function
@version P12.1.33
@since 18/06/2021
@author	claudineia.reinert
@return Logical, Retorna verdadeiro(.T.) ou False(.F.)
/*/
Function OGXN8MVLD()
	Local lRet := .T.
	Local nE2Parcela := TamSx3("E2_PARCELA")[1]
	Local nN8MParcel := TamSx3("N8M_PARCEL")[1]
	
	If nN8MParcel != nE2Parcela
		lRet := .F. 
		Agrhelp(STR0034,STR0157,STR0158) //#O campo N8M_PARCEL esta com tamanho diferente do campo E2_PARCELA.#Favor ajustar no dicionario de dados o tamanho do campo N8M_PARCEL igual ao tamanho do campo E2_PARCELA para prosseguir.

	EndIf

Return lRet
