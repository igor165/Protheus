#INCLUDE "OGA290.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "fwMvcDef.ch"
#INCLUDE "FWEditPanel.ch"

#DEFINE FLDPREVFIN 		3    		//Folder Financeiro
#DEFINE FLDPRINCIP 		STR0118		// Id Folder Principal
#DEFINE FLDALGODAO 		STR0124	 	// Id Folder Algodão 
#DEFINE	FLDALG			6			// Id da Folder Algodão em numerico
#DEFINE	FLDALGPRINC		1 			// Id da Folder Principal na aba Algodão em numerico
#DEFINE	FLDALGTTIPO		2 			// Id da Folder Tipo na aba Algodão em numerico
#DEFINE	FLDALGHVI		3 			// Id da Folder HVI na aba Algodão em numerico
#DEFINE	FLDALGOUTR		4 			// Id da Folder Outros na aba Algodão em numerico

#DEFINE _CRLF CHR(13)+CHR(10)                                                    

Static __lnewComerc		:= SuperGetMv('MV_AGRA001', , .F.) // Parametro de utilização do novo conceito de utilização do UBA
Static __lnewNeg		:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio
Static __cAnaCred		:= SuperGetMv('MV_AGRB003', , .F.) // Parametro de utilização de análise de crédito
Static __lAprAuto		:= SuperGetMv('MV_AGRO033', , .F.) // Parametro que indica se o contrato será aprovado automaticamente após alteração
Static __cRotName		:= "OGA290"
Static __oViewNJR		:= Nil 		// View Pai(Principal) - NJR
Static __oViewN7E 		:= Nil 		// View Filha da Principal - Tipos de Algodão Aceitáveis - (N7E)
Static __oViewN7H		:= Nil 		// View Filha da Principal - Qualidade do Algodão - (N7H)
Static __cCampDX7		:= "DX7_MIC,DX7_RES,DX7_FIBRA,DX7_UI,DX7_SFI,DX7_ELONG,DX7_LEAF,DX7_AREA,DX7_CSP,DX7_CG,DX7_MAISB,DX7_RD,DX7_COUNT,DX7_UHM,DX7_SCI"
Static __lCampVld		:= .F. 		// Variavel de controle para bloquear lógica de validação das grids com consulta específica
Static __cRet			:= ""
Static __cCampo      	:= ""		//Gaurda a regra pra gravar no campo N78_HVICMP 
Static __lFiltr      	:= .F.
Static __lValid			:= .F.
Static __cNewVal		:= ""
Static __cOldVal		:= ""
Static __cOldHvi		:= ""
Static __lNGraPrevF     := SuperGetMV( "MV_AGRPREV", .f., .f. ) //padrão do parametro é sempre .f. se não existir - .f. gera previsão financeira - .t. não gera previsao financeira
Static __lRegOpcional  	:= SuperGetMv('MV_AGRO040', , .F.) 	//parametro que deixa opcional o registro de negócio com o MV_AGRO002 ativo.
Static __lCtrRisco 	 	:= SuperGetMv('MV_AGRO041', , .F.) 
Static __lMostraAlg 	:= .F.
Static __lAprTakeUp     := IsInCallStack("OGC020APR")
//--<<--------------------------------------->>-- 
Static _lCeoga290	    := .F.			// Variável de controle na consulta específica UBAA060 para saber quando voi acionado o botão de cancelar
STATIC __lAutomato      := IiF(IsBlind(),.T.,.F.) //automação
STATIC __aOGX290FR	    := {}
STATIC __cEntidade      := ''
STATIC __cEntiLoja      := ''

/** {Protheus.doc} OGA290 ..
Rotina para cadastro de contratos de Venda

@param:     Nil
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGA290( pcCodEnt, pcLojEnt, pcFiltDco, pcCodCtr )
	Local oMBrowse 		:= Nil
	Local cFiltroDef 	:= "NJR_TIPO='2'" + iIf(!Empty(pcCodEnt),".AND.NJR_CODENT='"+pcCodEnt+"'","") + iIf(!Empty(pcLojEnt),".AND.NJR_LOJENT='"+pcLojEnt+"'","")

	Local bKeyF4 := nil	

	//--<< Vars Utilizadas composição de Preços >>--
	Private aGrvNKA     := {}
	Private dDEntrIni   := cTod('//')
	Private dDEntrFim   := cTod('//')	
 
	bKeyF4 := SetKey( VK_F4,  { || OGA290F4() } )
		
	//Substitui o filtro padão pelo filtro gerado na função OGAA890CTR()
	If !Empty(pcFiltDco)
		cFiltroDef := pcFiltDco
	EndIf  

	//Substitui o filtro padão pelo filtro gerado na função OGA530IE()
	If !Empty(pcCodCtr)
		cFiltroDef := "NJR_TIPO='2' .AND. NJR_CODCTR = '" + pcCodCtr + "'"
	EndIf  
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NJR" )
	oMBrowse:SetDescription( STR0001 ) //"Contratos de Venda"
	oMBrowse:SetFilterDefault( cFiltroDef )
	oMBrowse:SetMenuDef( "OGA290" )
	oMBrowse:AddFilter( STR0002, "NJR_TRANSF=='1'" ) //"Somente Transferencia entre Filiais"
	oMBrowse:AddLegend( "(NJR_MODELO=='1')"                                         , "WHITE"       , X3CboxDesc( "NJR_MODELO", "1" )   ) //"Pré-Contrato"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='P'"  , "BLUE"        , X3CboxDesc( "NJR_STATUS", "P" )   ) //"Previsto"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='A'"  , "GREEN"       , X3CboxDesc( "NJR_STATUS", "A" )   ) //"Aberto"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='I'"  , "YELLOW"      , X3CboxDesc( "NJR_STATUS", "I" )   ) //"Iniciado"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='E'"  , "BR_CANCEL"   , X3CboxDesc( "NJR_STATUS", "E" )   ) //"Cancelado"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='F'"  , "RED"         , X3CboxDesc( "NJR_STATUS", "F" )   ) //"Finalizado"
	oMBrowse:DisableDetails()
	oMBrowse:SetAttach( .T. ) //Visualização
	oMBrowse:Activate()
Return( )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param:     Nil
@return:    aRotina - Array com os itens do menu
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA290 - Contrato de Venda
*/
Static Function MenuDef()
	Local aRotina 	:= {}
	Local aRotina1 	:= {} 

	aAdd( aRotina1, { STR0086   , "OGA340(NJR->NJR_CODCTR)" 				, 0, 4, 0, Nil } ) //"Autorizações"
	aAdd( aRotina1, { STR0087   , "OGA335(NJR->NJR_CODCTR, NJR->NJR_FILIAL)" , 0, 4, 0, Nil } ) //"Adic./Supres."
	aAdd( aRotina1, { STR0088   , "OGA290320()"				 				, 0, 4, 0, Nil } ) //"Status"
	aAdd( aRotina1, { STR0089   , "OGC003(NJR->NJR_CODCTR)" 				, 0, 4, 0, Nil } ) //"Romaneios"
	aAdd( aRotina1, { STR0085   , "OGA290VNC"								, 0, 4, 0, Nil } ) //"Vínculo Contrato"
	aAdd( aRotina1, { STR0103   , "OGR342(NJR->NJR_CODCTR, NJR->NJR_TIPO)" 	, 0, 4, 0, Nil } ) //"Imprimir Word"
	
	If __lnewNeg
		aAdd( aRotina1, { STR0164   , "OGX290NFUT()"                         	, 0, 4, 0, Nil } ) //"Emitir NF Operação Futura"
		aAdd( aRotina1, { STR0209   , "OGRX020()"                         	    , 0, 8, 0, Nil } ) //"Extrato Contrato"
		aAdd( aRotina1, { STR0212   , "OGC170(NJR->NJR_CODCTR)"					, 0, 8, 0, Nil } ) //"Despesas Logisticas"
		aAdd( aRotina1, { STR0213   , "OGA530(NJR->NJR_CODCTR)"					, 0, 8, 0, Nil } ) //"Painel instrução"
	EndIf	
	
	aAdd( aRotina, { STR0009    , "PesqBrw"         	, 0, 1, 0, .t. } ) //"Pesquisar"
	aAdd( aRotina, { STR0010    , "ViewDef.OGA290"  	, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0011    , "ViewDef.OGA290"  	, 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0012    , "ViewDef.OGA290"  	, 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0013    , "OGA290C"         	, 0, 4, 0, Nil } ) //"Confirmar"
	aAdd( aRotina, { STR0070    , "AGRCONHECIM('NJR')"	, 0, 4,  , .T. } ) //"Conhecimento"	
	aAdd( aRotina, { STR0015    , "OGA290E"         	, 0, 4, 0, Nil } ) //"Cancelar"
	aAdd( aRotina, { STR0016    , "OGA290F"         	, 0, 4, 0, Nil } ) //"Finalizar"
	aAdd( aRotina, { STR0017    , "AGRXREABRE"         	, 0, 4, 0, Nil } ) //"Reabrir"
	aAdd( aRotina, { STR0018    , "ViewDef.OGA290"  	, 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0019    , "ViewDef.OGA290"  	, 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0020    , "OGR340"          	, 0, 8, 0, Nil } ) //"Contrato"

	If .NOT. __lnewNeg .OR. (__lRegOpcional .AND. __lnewNeg)
	    aAdd( aRotina, { STR0021, "ViewDef.OGA290" , 0, 9, 0, Nil } ) //"Copiar"
	EndIf
	aAdd( aRotina, { STR0083    , "AGRXHIST"       	, 0, 7, 0, Nil } ) //"Histórico"  
	
	if __lnewNeg		
		aAdd( aRotina, { STR0160    , "OGA290VNGC(NJR->NJR_CODNGC)", 0, 2, 0, Nil } ) // # Consultar negociação
		aAdd( aRotina, { STR0161    , "OGA570(NJR->NJR_CODCTR)", 0, 2, 0, Nil } ) // # Precificação
		aAdd( aRotina, { STR0179    , "AGRXFINANC()", 0, 4, 0, Nil } ) // # Gerar Previsão Financeira
        aAdd( aRotina, { STR0199    , "OGC150(NJR->NJR_CODCTR, .F.)", 0, 2, 0, Nil } ) // # Consulta de Previsões	    

		If __lRegOpcional // apenas sem ngc obrigado.
   			aAdd( aRotina, { STR0265    , "AGRXCNGC(NJR->NJR_CODCTR, nil, .T.)", 0, 2, 0, Nil } ) // # Fixação de Contrato
		Endif
		
		if __lnewComerc
			aAdd( aRotina, { STR0127    , "OGA290VBLC(NJR->NJR_CODCTR, NJR->NJR_CODPRO, NJR->NJR_FILIAL)" , 0, 2, 0, Nil } ) //"Blocos e Fardos Vinculados"  
			aAdd( aRotina, { STR0154    , "OGC080(NJR->NJR_CODCTR)" , 0, 2, 0, Nil } ) //"Blocos e Fardos Vinculados regra BCI"
			aAdd( aRotina, { STR0276    , "OGA290ALG()", 0, 4, 0, Nil } ) // # "Qualidade Algodão"
		Endif		
	endif 

	If ExistBlock('OG290MNU')
		aRet := ExecBlock('OG290MNU',.F.,.F.,{aRotina})
		If ValType(aRet) == 'A'
			aRotina	:= aClone(aRet)
		EndIf
	EndIf
	aAdd( aRotina, { STR0090    , aRotina1          	, 0, 4, 0, Nil } ) //"Mais ações..."  
Return( aRotina )

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param:     Nil
@return:    oModel - Modelo de dados
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA290 - Contratos
*/
Static Function ModelDef()
	Local oStruNJR  	:= FWFormStruct( 1, "NJR" ) // Campos da NJR contrato, contem todos os campos devido a gravação de dados de outros campos divididos em submodelos da NJR
	Local oStruNN7  	:= FWFormStruct( 1, "NN7", { |x| !ALLTRIM(x) $ 'NN7_CODCTR'} ) // Previsao Financeira do Contrat
	Local oStruNNY  	:= FWFormStruct( 1, "NNY", { |x| !ALLTRIM(x) $ 'NNY_CODCTR'} ) // Cadencias do Contrato         
	Local oStruNNF  	:= FWFormStruct( 1, "NNF", { |x| !ALLTRIM(x) $ 'NNF_CODCTR'} ) // Despesas - Corretores         
	Local oStruNN8 		:= FWFormStruct( 1, "NN8" ) // Fixacao do Contrato           
	Local oStruNKA  	:= FWFormStruct( 1, "NKA" ) // Composicao de Preco da Fixacao
	
	Local oStruN7J  	:= NIL // Descontos por Tipo e Folha    
	Local oStruN7R  	:= NIL // Rotas de Exportação           
	Local oStruN78b 	:= NIL // Regras do Agio e Desagio      
	Local oStruN78c 	:= NIL // Regras do Agio e Desagio      
	Local oStruN7F  	:= NIL // Regra HVI Ágio Deságio        
	Local oStruN7G  	:= NIL // Cor Tipo Classif. Agio/Desagio
	Local oStruN7E  	:= NIL // Estrutura de tipo de algodão aceitáveis
	Local oStruN7H  	:= NIL // Estrutura de Qualidade do Algodão
	Local oStruN84      := NIL // Condição Pagamento do Contrato
	Local oStruN9A      := NIL // Regras Fiscais do Contrato    
	Local oStruN9D		:= Nil // Movimentação de Fardos        
	Local oStruN9J		:= Nil // Relacionamento Regra fiscal x Previsao financeira x condição pagamento   
	Local oStruND1		:= Nil // Fixação X Previsão          
	Local oStruN9O		:= Nil // Limites Contaminantes         
	//Modelos que serão relacionados na operação de DELETE do model
	Local oStruN7M  	:= NIL // Componentes Fixados           
	Local oStruN7N  	:= NIL // Componentes Fix X Preços Fix 
	Local oStruN7O  	:= NIL // Negócios Fix X Componentes Fix	
	Local oStruNLN      := Nil // Preços X DCO PEPRO   
	
	Local oModel    	:= MPFormModel():New( "OGA290" , {| oModel | PreModelo( oModel ) }, {| oModel | PosModelo( oModel ) }, {| oModel | GrvModelo( oModel ) },)
	Local bLinPreN7J 	:= Nil
	Local bGrdValid		:= Nil		

	oStruNJR:SetProperty( "NJR_TIPO" 	, MODEL_FIELD_INIT , {| x | x := "2" }  ) // 2=VENDA -- INICIALIZADOR VALOR PADRÃO
	oStruNJR:SetProperty( "NJR_MODELO" 	, MODEL_FIELD_INIT , {| x | x := "2" }  ) // 2=CONTRATO	  -- INICIALIZADOR VALOR PADRÃO
		  
	If (IsInCallStack("OGX700CTR") .OR. IsInCallStack("OGX700ACTR")) 
		oStruNN7:SetProperty( "*", MODEL_FIELD_OBRIGAT , .F.  ) 
		oStruNJR:SetProperty( "*", MODEL_FIELD_OBRIGAT , .F.  ) 
		oStruNNY:SetProperty( "*", MODEL_FIELD_OBRIGAT , .F.  ) 
	else
		oStruNN7:SetProperty( "NN7_CODFAV", MODEL_FIELD_OBRIGAT , .F.  )
		oStruNN7:SetProperty( "NN7_LOJFAV", MODEL_FIELD_OBRIGAT , .F.  )
	EndIf 	

	oStruNN8:SetProperty( "NN8_ITEMFX" 	, MODEL_FIELD_VALID ,  {| oField | ExistChav('NN8',FwFldGet('NN8_CODCTR')+FwFldGet('NN8_ITEMFX') ) } ) 

	oStruNJR:SetProperty( "NJR_CLASSP" 	, MODEL_FIELD_INIT 	, {| | '2' } ) //VIA dicionario sempre carrega 1=destino, na venda padrão será 2=origem
	oStruNJR:SetProperty( "NJR_CLASSQ" 	, MODEL_FIELD_INIT 	, {| | '2' } ) //VIA dicionario sempre carrega 1=destino, na venda padrão será 2=origem
	
	If __lNGraPrevF // __lNGraPrevF = .F. --> Gera previsão financeira
		oStruNJR:SetProperty("NJR_VLRBAS", MODEL_FIELD_OBRIGAT, .F.)
		oStruNJR:SetProperty("NJR_VLRUNI", MODEL_FIELD_OBRIGAT, .F.)
		oStruNN7:SetProperty("NN7_VALOR" , MODEL_FIELD_OBRIGAT, .F.)		
	EndIf

	oStruNNF:SetProperty( "NNF_MODCOM"	, MODEL_FIELD_WHEN	, FWBuildFeature( STRUCT_FEATURE_WHEN , "OGA290WHN(a, b, c)" )  )	
   
	If cPaisLoc == "PAR" .Or. cPaisLoc == "ARG"
		oStruNJR:SetProperty("NJR_VLRUNI", MODEL_FIELD_OBRIGAT, .F.)
	EndIf  

	//Tratamento TES inteligente.
	If cPaisLoc != "PAR" .AND. cPaisLoc != "ARG"	
		oStruNJR:AddTrigger( "NJR_OPEFIS", "NJR_TESEST", { || .T. }, { | x | AGRXTESINT() } ) 
		oStruNJR:AddTrigger( "NJR_CODENT", "NJR_TESEST", { || .T. }, { | x | AGRXTESINT() } ) 
		oStruNJR:AddTrigger( "NJR_LOJENT", "NJR_TESEST", { || .T. }, { | x | AGRXTESINT() } ) 
		oStruNJR:AddTrigger( "NJR_CODPRO", "NJR_TESEST", { || .T. }, { | x | AGRXTESINT() } )
	EndIF

	If __lnewNeg	
		//NOVO NEGOCIO
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
 	 
		If !__lAprTakeUp 

			oStruNLN    := FWFormStruct( 1, "NLN" ) //Preços X DCO PEPRO            
			oStruN7R  	:= FWFormStruct( 1, "N7R", { |x| !ALLTRIM(x) $ 'N7R_CODCTR'}  )

			If !AGRXRESI(NJR->NJR_CODPRO)
				oStruNJR:SetProperty( "NJR_TABELA"	, MODEL_FIELD_OBRIGAT, .F. ) 
			Endif	
			
			If __lMostraAlg .OR. __lAutomato      
				oStruN7J  	:= FWFormStruct( 1, "N7J", { |x| !ALLTRIM(x) $ 'N7J_CODCTR'} )                
				oStruN78b 	:= FWFormStruct( 1, "N78", { |x| !ALLTRIM(x) $ 'N78_CODCTR'}  )
				oStruN78c 	:= FWFormStruct( 1, "N78", { |x| !ALLTRIM(x) $ 'N78_CODCTR'}  )	
				oStruN7F  	:= FWFormStruct( 1, "N7F", { |x| !ALLTRIM(x) $ 'N7F_CODCTR|N7F_SEQTIP'}  ) 
				oStruN7G  	:= FWFormStruct( 1, "N7G", { |x| !ALLTRIM(x) $ 'N7G_CODCTR'}  )	//--Estrutura Cor
				oStruN7E  	:= FWFormStruct( 1, "N7E" ) // Estrutura de tipo de algodão aceitáveis
				oStruN7H  	:= FWFormStruct( 1, "N7H" ) // Estrutura de Qualidade do Algodão
				oStruN9O    := FWFormStruct( 1, "N9O" )	//Limite contaminantes	            

				bLinPreN7J 	:= {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| ValPreN7J(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}                
				bGrdValid		:= {|oMdGridDXQ, nLine, cAction, cField, xValueNew, xValueOld|OGA290VMDF(oMdGridDXQ, nLine, cAction, cField, xValueNew, xValueOld)}
			EndIf
		EndIf

		oStruN84    := FWFormStruct( 1, "N84" ) // Estrutura de Condição de pagamentos
		oStruN9A    := FWFormStruct( 1, "N9A" ) // Estrutura de Regras Fiscais
		oStruN9J    := FWFormStruct( 1, "N9J" ) // Estrutura de Regras Fiscais
		oStruND1    := FWFormStruct( 1, "ND1", { |x| !ALLTRIM(x) $ 'ND1_VLUDES'} )  // Retirado campo, pois a atualização não é via modelo e sim no OGX070	    					
		oStruN9D 	:= FWFormStruct( 1, "N9D" ) // Estrutura de Regras Fiscais
		
		oStruN9D:AddField(STR0178, STR0178, "N9D_DXIREC", "C", 254, 0, , , , .F., {|| AGRXRECDXI(N9D->N9D_FILIAL, N9D->N9D_SAFRA, N9D->N9D_FARDO) }, , .F., .T.) // Campo auxiliar de recno # "Recno Auxiliar"
		oStruN9D:AddField(STR0180, STR0181, "N9D_DXIEMB", "C", 1, 0, , , , .F., {|| AGRXVQIE(N9D->N9D_FILIAL, N9D->N9D_SAFRA, N9D->N9D_FARDO) }, , .F., .T.) // Campo auxiliar de fardos com IE # Possui IE ?
		
		oStruN9D:SetProperty("*", MODEL_FIELD_VALID, {|| .T.}) 
	    oStruN9D:SetProperty("*", MODEL_FIELD_WHEN, {|| .T.}) 
	    oStruN9D:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)	

		oStruN9A:SetProperty( "N9A_SEQPRI"	, MODEL_FIELD_OBRIGAT, .T. ) //Ajustado no dicionario da 34 para obrigatorio
		oStruN84:SetProperty( "N84_SEQUEN"	, MODEL_FIELD_OBRIGAT, .T. ) //Ajustado no dicionario da 34 para obrigatorio

		If oStruN84:HasField("N84_PROVIS")
			oStruN84:RemoveField( "N84_PROVIS" )
		EndIf	

		If !__lAprTakeUp .and. (__lMostraAlg .OR. __lAutomato)
			oStruN78b:SetProperty( "N78_APLICA" , MODEL_FIELD_INIT , {| x | x := "2" }  ) //2=HVI
			oStruN78c:SetProperty( "N78_APLICA" , MODEL_FIELD_INIT , {| x | x := "3" }  ) //3=Outros
			oStruN78c:SetProperty( "N78_QTDVDA" , MODEL_FIELD_INIT , {| | OGA290QDV() } )
			oStruN78c:SetProperty( "N78_QTDAVI" , MODEL_FIELD_INIT , {| | OGA290QAV('I') } )		
		EndIf	

		oStruN9A:AddTrigger( "N9A_OPEFIS", "N9A_TES",    { || .T. }, { | x | AGRXTESINT(.T.)}) 

		//Validação para não se repetir o codigo do porto/aeroporto
		If !__lAprTakeUp 
			oStruN7R:SetProperty( "N7R_CODROT" 	, MODEL_FIELD_VALID , {| oModelN7R | ValidaN7R( oModelN7R ) } )
		EndIf	
		
		If !isBlind() 
			oStruNN7:AddField("TP" , "Legenda", 'NN7_STSLEG', 'BT' , 1 , 0, , ;
								NIL , NIL, NIL, {||Iif(!Empty(NN7->(NN7_STATUS)), AGRXPFLEG(NN7->(NN7_STATUS)),"BR_VERDE")}, NIL, .F., .T.) // Adiciona a Estrutura da Grid o Botão de Legenda
		endif	
		
		oStruNJR:SetProperty("NJR_TESEST", MODEL_FIELD_OBRIGAT, .F.)//não obrigatorio
		
		If __lRegOpcional
			oStruNN7:SetProperty( "*", MODEL_FIELD_OBRIGAT , .F.  ) 
		EndIf
		
		oStruNN7:SetProperty("NN7_DTVENC" , MODEL_FIELD_INIT, { || "" }) //retira a obrigatoriedade do valor
		oStruNN7:SetProperty("NN7_VALOR" ,  MODEL_FIELD_OBRIGAT, .F.) //retira a obrigatoriedade do valor
		oStruNNY:SetProperty("NNY_FILORG", MODEL_FIELD_OBRIGAT , .T.  )
		oStruN9A:SetProperty("N9A_VLUFPR", MODEL_FIELD_INIT, {| oField | fN9AVlUFa( oField ) } )			
		If GetRpoRelease() <= "12.1.027"
			oStruN9A:SetProperty("N9A_CODENT", MODEL_FIELD_INIT, {| | OGA290BSC( 'N9A_CODENT' ) } )	
			oStruN9A:SetProperty("N9A_LOJENT", MODEL_FIELD_INIT, {| | OGA290BSC( 'N9A_LOJENT' ) } )	
			oStruN9A:SetProperty("N9A_CODFIN", MODEL_FIELD_INIT, {| | OGA290BSC( 'N9A_CODFIN' ) } )	
			oStruN9A:SetProperty("N9A_TIPCLI", MODEL_FIELD_INIT, {| | OGA290BSC( 'N9A_TIPCLI' ) } )	
		EndIf 

		If cPaisLoc != "PAR" .AND. cPaisLoc != "ARG"	
			oStruNJR:AddTrigger( "NJR_CODPRO", "NJR_BOLSA",  { || .T. }, { | x | AGRXBOLSA()  } )
		EndIF

		oStruN84:SetProperty('N84_CODCTR', MODEL_FIELD_OBRIGAT, .F.)

	EndIf //FIM if novo negocio
	
	oModel:SetDescription( STR0023 ) //"Contrato de Venda"

	//--Field Contrato
	oModel:AddFields( "NJRUNICO", /*cOwner*/, oStruNJR,{|oFieldModel, cAction, cIDField, xValue|PreValNJR(oFieldModel, cAction, cIDField, xValue)}, {| oField | AGRXPOSNJR( oField ) } /*bPost*/, /*bLoad */  )
	oModel:GetModel( "NJRUNICO" ):SetDescription( STR0024 ) //"Dados do Contrato de Venda"

	If !__lnewNeg 
		//MODELO CLASSICO
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

	//--<< Campos que nao devem copiar no processo de copia >>--
    If !__lAprTakeUp 
        cFldsNCopy :=''
        cFldsNCopy += "NJR_CODCTR,NJR_ULTALT,NJR_DATA,NJR_CODRPC,NJR_AUTENT,NJR_AUTSAI,NJR_QTEFCO,NJR_QTEFIS,NJR_VLEFIS,"
        cFldsNCopy += "NJR_QTSEMB,NJR_QTSFCO,NJR_QTSFIS,NJR_VLSFIS,NJR_QSLEMB,NJR_QSLFCO,NJR_SLDFIS,NJR_SLDTO,NJR_QTDRES,"
        cFldsNCopy += "NJR_QTDQUE,NJR_VLRUNI,NJR_VLRTOT,NJR_TRANSF,NJR_MODELO,NJR_MODBAS,NJR_STSASS,NJR_STSFIS,NJR_STSFIN,"
        cFldsNCopy += "NJR_STSEST,NJR_STATUS,NJR_VLRBAS,NJR_QTDINI,NJR_QTDCTR,NJR_MODAL,NJR_INSCPO,NJR_CODNGC,NJR_VERSAO"
        aFldNCopy  := Separa(cFldsNCopy,',' )
        oModel:GetModel( "NJRUNICO" ):SetFldNoCopy( aFldNcopy ) // Na função Copiar nao copia os campos de retornados em array
    EndIf

	//--Grid Previsão Financeira
	oModel:AddGrid( "NN7UNICO", "NJRUNICO",oStruNN7,{|oModelGrid, nLine,cAction,cField,xVrNovo,xVrAnt|PreValNN7(oModelGrid, nLine, cAction, cField,xVrNovo,xVrAnt)} , , , { | oGrid | AGRXPOSNN7( oGrid ) } )
	oModel:GetModel( "NN7UNICO" ):SetDescription( STR0025 ) //"Dados das Previsões Financeiras"
	oModel:GetModel( "NN7UNICO" ):SetUniqueLine( { "NN7_ITEM" } )
	oModel:GetModel( "NN7UNICO" ):SetOptional( .T. )
	oModel:SetRelation( "NN7UNICO", { { "NN7_FILIAL", "xFilial( 'NN7' )" }, { "NN7_CODCTR", "NJR_CODCTR" } }, NN7->( IndexKey( 1 ) ) )
	oModel:GetModel( "NN7UNICO" ):SetFldNoCopy( AGRXNOCOPY( oModel:GetModel( "NN7UNICO" ) ) ) // Na função Copiar nao copia os campos de retornados em array

	//--Grid Cadencia
	oModel:AddGrid( "NNYUNICO", "NJRUNICO",oStruNNY,{|oModelGrid, nLine,cAction,cField,xVrNovo,xVrAnt|PreValNNY(oModelGrid, nLine, cAction, cField,xVrNovo,xVrAnt)} , , , { | oGrid | AGRXPOSNNY( oGrid ) }, {|oGrid, lCopy| AGRXLICOPY(oGrid, lCopy)})
	oModel:GetModel( "NNYUNICO" ):SetDescription( STR0026 ) //"Dados do Intervalo de Cadência"
	oModel:GetModel( "NNYUNICO" ):SetUniqueLine( { "NNY_ITEM" } )
	oModel:GetModel( "NNYUNICO" ):SetOptional( .T. )
	oModel:SetRelation( "NNYUNICO", { { "NNY_FILIAL", "xFilial( 'NNY' )" }, { "NNY_CODCTR", "NJR_CODCTR" } }, NNY->( IndexKey( 1 ) ) )
	oModel:GetModel( "NNYUNICO" ):SetFldNoCopy( AGRXNOCOPY( oModel:GetModel( "NNYUNICO" ) ) ) // Na função Copiar nao copia os campos de retornados em array

	//--Grid Corretores
    If !__lAprTakeUp
        oModel:AddGrid( "NNFUNICO", "NJRUNICO", oStruNNF, , , ,  )
        oModel:GetModel( "NNFUNICO" ):SetDescription( STR0027 ) //"Dados dos Corretores"
        oModel:GetModel( "NNFUNICO" ):SetUniqueLine( { "NNF_ITEM" } )
        oModel:GetModel( "NNFUNICO" ):SetOptional( .t. )
        oModel:SetRelation( "NNFUNICO", { { "NNF_FILIAL", "xFilial( 'NNF' )" }, { "NNF_CODCTR", "NJR_CODCTR" } }, NNF->( IndexKey( 1 ) ) )
        oModel:GetModel( "NNFUNICO" ):SetFldNoCopy( AGRXNOCOPY( oModel:GetModel( "NNFUNICO" ) ) ) // Na função Copiar nao copia os campos de retornados em array
    EndIf

	If __lnewNeg //NOVO NEGOCIO
		If !__lAprTakeUp
			oModel:AddGrid( "N7RUNICO", "NJRUNICO", oStruN7R, , , , /*{ | oGrid | ValidaN7R( oGrid )}*/)
			oModel:GetModel( "N7RUNICO" ):SetUniqueLine( { "N7R_TIPO","N7R_CODROT" } )
			oModel:GetModel( "N7RUNICO" ):SetOptional( .T. )
			oModel:SetRelation( "N7RUNICO", { { "N7R_FILIAL", "xFilial( 'N7R' )" }, { "N7R_CODCTR", "NJR_CODCTR" } }, N7R->( IndexKey( 1 ) ) )                    
			
			If __lMostraAlg .OR. __lAutomato      
				//--Grid Agio/Desagio TIPO	
				oModel:AddGrid( "N7JUNICO", "NJRUNICO", oStruN7J, , , bLinPreN7J, { | oGrid | ValPosN7J( oGrid ) })
				oModel:GetModel( "N7JUNICO" ):SetUniqueLine( { "N7J_TCRTIP" } )
				oModel:GetModel( "N7JUNICO" ):SetOptional( .t. )
				oModel:SetRelation( "N7JUNICO", { { "N7J_FILIAL", "xFilial( 'N7J' )" }, { "N7J_CODCTR", "NJR_CODCTR" } }, N7J->( IndexKey( 1 ) ) )
				oModel:GetModel( "N7JUNICO" ):SetNoInsertLine(.T.) // Desabilita a inserção de linhas
				oModel:GetModel( "N7JUNICO" ):SetNoDeleteLine(.T.) // Desabilita o deletar de linhas
			
				//--Grid Agio/Desagio OUTROS	
				oModel:AddGrid( "N78HVI", "NJRUNICO", oStruN78b, , , bGrdValid, { | oGrid | ValPosN78H( oGrid ) })
				oModel:GetModel( "N78HVI" ):SetUniqueLine( { "N78_SEQUEN" } )
				oModel:GetModel( "N78HVI" ):SetOptional( .T. )
				oModel:SetRelation( "N78HVI", { { "N78_FILIAL", "xFilial( 'N78' )" }, { "N78_CODCTR", "NJR_CODCTR" }, { "N78_APLICA", "'2'" } }, N78->( IndexKey( 1 ) ) )
			
				//--Grid Agio/Desagio OUTROS	
				oModel:AddGrid( "N78OUTROS", "NJRUNICO", oStruN78c, , , , { | oGrid | ValPosN78O( oGrid ) })
				oModel:GetModel( "N78OUTROS" ):SetUniqueLine( { "N78_SEQUEN" } )
				oModel:GetModel( "N78OUTROS" ):SetOptional( .t. )
				oModel:SetRelation( "N78OUTROS", { { "N78_FILIAL", "xFilial( 'N78' )" }, { "N78_CODCTR", "NJR_CODCTR" }, { "N78_APLICA", "'3'" } }, N78->( IndexKey( 1 ) ) )
			
				//--Grid Agio/Desagio - Cor
				oModel:AddGrid( "N7GUNICO", "NJRUNICO", oStruN7G, , , , { | oGrid | ValPosN7G( oGrid ) })
				oModel:GetModel( "N7GUNICO" ):SetUniqueLine( { "N7G_TCRTIP" } )
				oModel:GetModel( "N7GUNICO" ):SetOptional( .t. )
				oModel:GetModel( "N7GUNICO" ):SetNoInsertLine(.T.) // Desabilita a inserção de linhas
				oModel:GetModel( "N7GUNICO" ):SetNoDeleteLine(.T.) // Desabilita o deletar de linhas
				oModel:SetRelation( "N7GUNICO", { { "N7G_FILIAL", "xFilial( 'N7G' )" }, { "N7G_CODCTR", "NJR_CODCTR" } }, N7G->( IndexKey( 1 ) ) )
			
				//--Grid Agio/Desagio - Dados HVI
				oModel:AddGrid( "N7FUNICO", "N7JUNICO", oStruN7F, , , bGrdValid, { | oGrid | ValPosN7F( oGrid ) }   )
				oModel:GetModel( "N7FUNICO" ):SetOptional( .t. )
				oModel:SetRelation( "N7FUNICO", { { "N7F_FILIAL", "xFilial( 'N7F' )" }, { "N7F_CODCTR", "NJR_CODCTR" } , { "N7F_SEQTIP", "N7J_SEQUEN" } }, N7F->( IndexKey( 1 ) ) )
			
				//--Grid Limitantes Contaminantes	
				oModel:AddGrid( "N9OUNICO", "NJRUNICO", oStruN9O, , , , { | oGrid | ValPosN9O( oGrid ) } )
				oModel:GetModel( "N9OUNICO" ):SetUniqueLine( { "N9O_CODCON" } )
				oModel:GetModel( "N9OUNICO" ):SetOptional( .t. )
				oModel:SetRelation( "N9OUNICO", { { "N9O_FILIAL", "xFilial( 'N9O' )" }, { "N9O_CODCTR", "NJR_CODCTR" } }, N9O->( IndexKey( 1 ) ) )
				
				oModel:AddGrid( "N7EUNICO", "NJRUNICO", oStruN7E, , , bGrdValid, { | oGrid | ValPosN7E( oGrid ) } )
				oModel:GetModel( "N7EUNICO" ):SetUniqueLine( { "N7E_TIPACE" } )
				oModel:GetModel( "N7EUNICO" ):SetOptional( .T. )
				oModel:SetRelation( "N7EUNICO", { { "N7E_FILIAL", "xFilial( 'N7E' )" }, { "N7E_CODCTR", "NJR_CODCTR" } }, N7E->( IndexKey( 1 ) ) )
			
				oModel:AddGrid( "N7HUNICO", "NJRUNICO", oStruN7H, , , bGrdValid, { | oGrid | ValPosN7H( oGrid ) })
				oModel:GetModel( "N7HUNICO" ):SetUniqueLine( { "N7H_HVIDES" } )
				oModel:GetModel( "N7HUNICO" ):SetOptional( .T. )
				oModel:SetRelation( "N7HUNICO", { { "N7H_FILIAL", "xFilial( 'N7H' )" }, { "N7H_CODCTR", "NJR_CODCTR" } }, N7H->( IndexKey( 1 ) ) )      
			EndIf
		EndIf

		//Condição de Pagamento		
		oModel:AddGrid( "N84UNICO", "NJRUNICO", oStruN84,{|oSubModel, nLine, cAction, cIDField, xNewValue| AGRXN84Upd(oSubModel, nLine, cAction, cIDField, xNewValue)},,,{ | oMDGrid | AGRXVLDN84( oMDGrid )} )
		oModel:GetModel( "N84UNICO" ):SetUniqueLine( {"N84_SEQUEN" } )
		oModel:GetModel( "N84UNICO" ):SetOptional( .T. )
		oModel:SetRelation( "N84UNICO", { { "N84_FILIAL", "xFilial( 'N84' )" }, { "N84_CODCTR", "NJR_CODCTR" } }, N84->( IndexKey( 1 ) ) )
		oModel:GetModel( "N84UNICO" ):SetFldNoCopy( AGRXNOCOPY( oModel:GetModel( "N84UNICO" ) ) ) // Na função Copiar nao copia os campos de retornados em array

		//Regras Fiscais		
		If !__lAprTakeUp
			oStruN9A:AddField('Vinc. PEPRO',  "Legenda", 'N9A_VINDCO' , 'BT' , 1 , 0, {|| .T.} , NIL , NIL, NIL, {|| "PRECO" }, NIL, .F., .T.)			
			oStruN9A:SetProperty('N9A_CODCTR', MODEL_FIELD_OBRIGAT, .F.)
		EndIf
		oModel:AddGrid( "N9AUNICO", "NNYUNICO", oStruN9A,{|oModelGrid, nLine,cAction,cField,xVrNovo,xVrAnt|PreValN9A(oModelGrid, nLine, cAction, cField,xVrNovo,xVrAnt)} , , , { | | OGX290POSV( )} )
		oModel:GetModel( "N9AUNICO" ):SetUniqueLine( {"N9A_ITEM","N9A_SEQPRI" } )
		oModel:GetModel( "N9AUNICO" ):SetOptional( .T. )
		oModel:SetRelation( "N9AUNICO", { { "N9A_FILIAL", "xFilial( 'N9A' )" }, { "N9A_CODCTR", "NJR_CODCTR" }, { "N9A_ITEM", "NNY_ITEM" } }, N9A->( IndexKey( 1 ) ) )			
		
		//Fardos Vinculados X Regras Fiscais
		oModel:AddGrid("N9DUNICO", "N9AUNICO", oStruN9D)
		oModel:GetModel("N9DUNICO"):SetOptional(.T.)
		oModel:SetRelation("N9DUNICO", {{ "N9D_FILORG", "NJR_FILIAL" }, { "N9D_CODCTR", "NJR_CODCTR" }, { "N9D_ITEETG", "N9A_ITEM" }, { "N9D_ITEREF", "N9A_SEQPRI" }, { "N9D_TIPMOV", "'02'" }, { "N9D_STATUS", "'2'" } }, N9D->(IndexKey(4)))
		oModel:GetModel("N9DUNICO"):SetOnlyQuery(.T.)
		
		//relacionamento de previsões financeiras	
		oModel:AddGrid("N9JUNICO", "NJRUNICO", oStruN9J)
		oModel:GetModel("N9JUNICO"):SetOptional(.T.)
		oModel:SetRelation("N9JUNICO", {{ "N9J_FILIAL", "xFilial( 'N9J' )" }, { "N9J_CODCTR", "NJR_CODCTR" }}, N9J->(IndexKey(1)))
		
		If TableInDic('ND1')
			oModel:AddGrid("ND1UNICO", "N9JUNICO", oStruND1)
			oModel:GetModel("ND1UNICO"):SetOptional(.T.)
			oModel:SetRelation("ND1UNICO", {{ "ND1_FILIAL",  "xFilial( 'ND1' )"  }, { "ND1_CODCTR", "NJR_CODCTR" }, { "ND1_ITEMPE", "N9J_ITEMPE" }, { "ND1_ITEMRF", "N9J_ITEMRF" }, { "ND1_SEQCP", "N9J_SEQCP" }, { "ND1_SEQPF", "N9J_SEQPF" }, { "ND1_SEQN9J", "N9J_SEQ" }}, ND1->(IndexKey(1)))        
		EndIf           
		
		//trata para não aparecer os títulos sem previsão
		//somente faz para nova comercialização, pois na clássica, se tiver zero não carregará para o modelo 
		//e ao fazer composição vai dar erro de registro duplicado
		If __lnewNeg .and. !__lAprTakeUp
			oModel:GetModel( 'NN7UNICO' ):SetLoadFilter(, "NN7_VALOR > 0 OR NN7_SLDQTD > 0") 
		EndIf
		
		/* NLN - DCOs do PEPRO */
		If !__lAprTakeUp .and. !__lMostraAlg .and. TableInDic('NLN')
			oModel:AddGrid("NLNUNICO", "NJRUNICO", oStruNLN, , , ,  )
			oModel:GetModel("NLNUNICO"):SetDescription('PEPRO') //"PEPRO"
			oModel:GetModel("NLNUNICO"):SetUniqueLine({"NLN_CODCTR", "NLN_ITEMPE", "NLN_ITEMRF", "NLN_SEQUEN"})
			oModel:GetModel("NLNUNICO"):SetOptional(.T.)
			oModel:GetModel("NLNUNICO"):SetNoUpdateLine(.T.)
			oModel:GetModel("NLNUNICO"):SetNoInsertLine(.T.)
			oModel:GetModel("NLNUNICO"):SetNoDeleteLine(.T.)
			oModel:GetModel("NLNUNICO"):SetLoadFilter({{'NLN_CODINE', "'"+ SPACE(TamSX3("NLN_CODINE")[1]) +"'"} })
			oModel:SetRelation("NLNUNICO", {{"NLN_FILIAL", "xFilial('NLN')"}, {"NLN_CODCTR", "NJR_CODCTR"}}, NLN->(IndexKey(1)))
		EndIf
				
		//Executa a partir da reprovação do negócio
		If (IsInCallStack("OGX700CNEG"))
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
	EndIf //FIM IF NOVO NEGOCIO

	oModel:SetVldActivate(	{ | oModel | VldActveMd( oModel,	oModel:GetOperation()) } )
	oModel:SetActivate( 	{ | oMod   | ActivateMD( oMod,		oModel:GetOperation() ) } )

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param:     Nil
@return:    oView - View do modelo de dados
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA290 - Contratos
*/
Static Function ViewDef()
	Local oModel   		:= FWLoadModel( "OGA290" )
	Local oView     	:= FWFormView():New()
	Local lAgoClas  	:= SuperGetMV("MV_AGOCLAS",.F.,.F.) //PARAMETRO SE HABILITA CONTROLE FISICO/FISCAL
    Local nIt           := 0
    Local aFields       := {}	
	Local oStruNJR  	:= Nil
	Local oStruNN7  	:= Nil
	Local oStruNNY  	:= Nil
	Local oStruNNF  	:= Nil
	Local oStruNJRX  	:= Nil
	Local oStruNJRT  	:= Nil
	Local oStruNJRH  	:= Nil
	Local oStruNJRO  	:= Nil
	Local oStruN7J   	:= Nil
	Local oStruN7R   	:= Nil
	Local oStruN78O  	:= Nil
	Local oStruN78H  	:= Nil
	Local oStruN7F  	:= Nil
	Local oStruN7G  	:= Nil
	Local oStruN84  	:= Nil
	Local oStruN9A  	:= Nil	
	Local oStruNLN      := Nil
    Local cNoViewNJR    := ""
    Local cNoViewN9A    := ""
    Local cNoViewNN7    := ""
    Local cNoViewNNF    := ""
    Local cNoViewNNY    := ""
	
	cNoViewNJR := 	"NJR_CLASSF-NJR_TIPUM-NJR_TIPCAL-NJR_TIPFAT-NJR_OUTUM-NJR_OUTCAL-NJR_OUTFAT-" + ;
					"NJR_HVIUM-NJR_HVICAL-NJR_HVIFAT-NJR_HVITOL-NJR_SLDTOT-" + ;
					"NJR_TIPO-NJR_CODTSE-NJR_DESTSE-NJR_TESQTE-NJR_TESRSI-NJR_QTDQUE-NJR_TKPFIS-NJR_CONDPG-NJR_DIASPG-NJR_DESPG-" + ;
				    "NJR_TIPALG-NJR_HVIREG-NJR_QAPADR-NJR_TIPACE-NJR_CONDPA-NJR_VIA-NJR_INCOTE-NJR_CODEMB-NJR_DESEMB-NJR_DESCPA-NJR_DESVIA-"+;
                    "NJR_DESINC-NJR_TPSEVO-NJR_CODREM-NJR_DESREM" 
	
	If !lAgoClas
		cNoViewNJR += "-NJR_CLASSP-NJR_CLASSQ-"        
	EndIf
    
    cNoViewNN7 := "NN7_CODCTR-NJR_SLDTOT-NN7_CONTOB-NN7_CONTST-NN7_STATUS-NN7_VLSALD-NN7_STSTIT"
    cNoViewNNY := "NNY_CODCTR-NNY_MESBOL-NNY_MESANO-NNY_MEMBAR"
    cNoViewNNF := "NNF_CODCTR"

    If __lnewNeg 
		//NOVO NEGOCIO
		cNoViewNJR += "-NJR_DATREF-NJR_OPETRI-NJR_OPEFUT-NJR_CODOPE-NJR_CODRPC-NJR_OPEFIS-NJR_TESEST-NJR_TESFIN-NJR_OBSADT-NJR_CODFIN"+;
                        "-NJR_DESFIN-NJR_TIPOCL-NJR_CTREXT"
        cNoViewN9A += "-N9A_DESCTR-N9A_TIPMER-N9A_TIPCTR-N9A_DESOPF-N9A_CODPRO-N9A_DESPRO-N9A_UNIPRO-N9A_INCOTE-N9A_CONDPA-N9A_DESCPA-N9A_CONDPG-"+;
                        "-N9A_DESPG-N9A_CTREXT-N9A_QTNFPV"
        cNoViewNN7 += "-NN7_VLUNIP-NN7_CHATIT-NN7_CODCOM-NN7_ITMCOM-NN7_DESCOM-NN7_CODPGT"
        cNoViewNNF += "-NNF_NLJENT-NNF_PCBCOM-NNF_STATUS"
		cNoViewN9A += "-N9A_CODCTR-N9A_ITEM"

        IF !__lCtrRisco
            cNoViewNNY += "-NNY_QTDCTR"            
        EndIf	   

        oStruNJR  	:= FWFormStruct( 2, "NJR" , { |x| !ALLTRIM(x) $ cNoViewNJR } )
		oStruNJRE 	:= FWFormStruct( 2, 'NJR' , { |x| ALLTRIM(x)  $ 'NJR_TKPFIS,NJR_TIPALG,NJR_TPSEVO' }) 
		oStruNJRX 	:= FWFormStruct( 2, 'NJR' , { |x| ALLTRIM(x)  $ 'NJR_CONDPA,NJR_DESCPA,NJR_CODREM,NJR_DESREM,NJR_VIA,NJR_DESVIA,NJR_INCOTE,NJR_DESINC, NJR_CONDPG, NJR_DIASPG, NJR_DESPG, NJR_CODEMB,NJR_DESEMB ' }) 
		oStruNJRT 	:= FWFormStruct( 2, 'NJR' , { |x| ALLTRIM(x)  $ 'NJR_TIPUM,NJR_TIPCAL,NJR_TIPFAT' } )
		oStruNJRH 	:= FWFormStruct( 2, 'NJR' , { |x| ALLTRIM(x)  $ 'NJR_HVIUM,NJR_HVICAL,NJR_HVIFAT,NJR_HVIREG,NJR_HVITOL' } ) //Estrutura Aba HVI Cabeçalho
		oStruNJRO 	:= FWFormStruct( 2, 'NJR' , { |x| ALLTRIM(x)  $ 'NJR_OUTUM,NJR_OUTCAL,NJR_OUTFAT' } )
		oStruNN7  	:= FWFormStruct( 2, "NN7" , { |x| !ALLTRIM(x) $ cNoViewNN7} )
		oStruNNY  	:= FWFormStruct( 2, "NNY" , { |x| !ALLTRIM(x) $ cNoViewNNY})
        oStruN84  	:= FWFormStruct( 2, "N84" , { |x| !ALLTRIM(x) $ 'N84_CODCTR|N84_PROVIS'})
        oStruN9A  	:= FWFormStruct( 2, "N9A" , { |x| !ALLTRIM(x) $ cNoViewN9A })				
		
        If !__lAprTakeUp 
            oStruNNF  	:= FWFormStruct( 2, "NNF" , { |x| !ALLTRIM(x) $ cNoViewNNF} )
            oStruN7R  	:= FWFormStruct( 2, "N7R" , { |x| !ALLTRIM(x) $ 'N7R_CODCTR'})
            oStruNLN    := FWFormStruct( 2, "NLN",  { |x| !ALLTRIM(x) $ 'NLN_CODINE-NLN_CODCTR-NLN_SEQUEN-NLN_QTDFAT'} )            

            oStruN9A:AddField("N9A_VINDCO"  ,'90' , "Vinc. PEPRO", "Legenda", {} , 'BT' ,'@BMP', NIL, NIL, .T., NIL, NIL, NIL,	NIL, NIL, .T.)
            oStruNN7:AddField( "NN7_STSLEG" ,'01' , "", "Legenda" , {} , 'BT' ,'@BMP', NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .T. )
            
            If __lMostraAlg
                oStruN7J  	:= FWFormStruct( 2, "N7J" , { |x| !ALLTRIM(x) $ 'N7J_CODCTR'}) // Estrutura Grid Descontos por Tipo e Folha                
                oStruN78O 	:= FWFormStruct( 2, "N78" , { |x| ALLTRIM(x)  $ 'N78_SEQUEN, N78_OUTCOD, N78_OUTDES, N78_OUTPER, N78_OUTPON,N78_QTDVDA,N78_QTDAVI '})
                oStruN78H 	:= FWFormStruct( 2, "N78" , { |x| ALLTRIM(x)  $ 'N78_SEQUEN,N78_HVIAGR,N78_HVIPON,N78_HVIREG,N78_HVITIP'})
                oStruN7F  	:= FWFormStruct( 2, "N7F" , { |x| !ALLTRIM(x) $ 'N7F_CODCTR,N7F_CAMPO,N7F_SEQTIP'})
                oStruN7G  	:= FWFormStruct( 2, "N7G" , { |x| !ALLTRIM(x) $ 'N7G_CODCTR, N7G_TCRTIP'})	//--Estrutura Cor            
                oStruN9O  	:= FWFormStruct( 2, "N9O" , { |x| !ALLTRIM(x) $ 'N9O_CODCTR'})                 
            EndIf
        EndIf

		//remoção de folders para aba de Qualidade
		oStruNJRE:SetNoFolders(.t.) 	
		oStruNJRH:SetNoFolders(.t.) 	
		oStruNJRT:SetNoFolders(.t.) 	
		oStruNJRO:SetNoFolders(.t.) 	
		oStruNJRX:SetNoFolders(.t.) 

	Else 	        
        //MODELO CLASSICO
		cNoViewNJR += "-NJR_TIPMER-NJR_CTREXT-NJR_GENMOD-NJR_CODFIN-NJR_DESFIN-NJR_CLVL-NJR_TIPOCL-NJR_BOLSA-NJR_DBOLSA-NJR_BCOPRV-NJR_AGGPRV"    +;
                        "-NJR_CTAPRV-NJR_DIASF-NJR_DIASR-NJR_DESMOF-NJR_DESMOR-NJR_OPERAC-NJR_CODNGC-NJR_VERSAO-NJR_RESFIX"   +;
                        "-NJR_CHKFIX-NJR_TOTNN7-NJR_TOTN9G-NJR_TOTN9K-NJR_TOTAFT-NJR_TOTARB-NJR_STSMIN-NJR_PROMIN-NJR_CODEMB-NJR_DESEMB-NJR_CONPES" +;
                        "-NJR_UM2PRO-NJR_QTDUM2-NJR_CLASSQ"

        cNoViewNNY += "-NNY_MESEMB-NNY_FILORG-NNY_FILDES-NNY_DTLFIX-NNY_DTLTKP-NNY_TKPQTD-NNY_MESBOL-NNY_IDXNEG-NNY_IDXCTF-NNY_QTDCTR-NNY_VMESAN"
        cNoViewNN7 += "-NN7_VLRAVI-NN7_VLTNCO-NN7_VLTEMI-NN7_VLCOMP-NN7_SLDQTD-NN7_QTDE-NN7_VLRTAX-NN7_MOEDA-NN7_VLSALD-NN7_CTREXT"  +;
                        "-NN7_VLUNIP-NN7_TIPO-NN7_FILORG-NN7_FILDES-NN7_CHATIT-NN7_VLRCTR-NN7_VLDEVL-NN7_TIPEVE-NN7_CODPGT-NN7_OPERAC" +;
                        "-NN7_VALMOE-NN7_MOEREF-NN7_DESMOE-NN7_TIPMER"     


        cNoViewNNF += "-NNF_TIPCOM-NNF_QTDCON-NNF_FATCON-NNF_TXMOED-"

		oStruNJR  := FWFormStruct( 2, "NJR", { |x| !ALLTRIM(x) $ cNoViewNJR })
		oStruNN7  := FWFormStruct( 2, "NN7", { |x| !ALLTRIM(x) $ cNoViewNN7 })
		oStruNNY  := FWFormStruct( 2, "NNY", { |x| !ALLTRIM(x) $ cNoViewNNY })		
		oStruNNF  := FWFormStruct( 2, "NNF", { |x| !ALLTRIM(x) $ cNoViewNNF })
	
		oStruNJR:RemoveField("NJR_MOEDAF")
		oStruNJR:RemoveField("NJR_MOEDAR")							
		oStruNNF:SetProperty( 'NNF_CODENT' , MVC_VIEW_TITULO, "Cod. Crtra.") 
		oStruNNF:SetProperty( 'NNF_LOJENT' , MVC_VIEW_TITULO, "Loj. Corr.")
		oStruNNF:SetProperty( 'NNF_NOMENT' , MVC_VIEW_TITULO, "Nome Crtra.")
		oStruNNF:SetProperty( 'NNF_CDCORR' , MVC_VIEW_TITULO, "Cod Corretor")
		oStruNNF:SetProperty( 'NNF_NMCORR' , MVC_VIEW_TITULO, "Nme Corretor")
		oStruNNF:SetProperty( 'NNF_VLBCOM' , MVC_VIEW_TITULO, "Comis. R$/SC")
		oStruNNF:SetProperty( 'NNF_MODCOM' , MVC_VIEW_TITULO, "Mod. Com.")
		oStruNNF:SetProperty( 'NNF_UNIMED' , MVC_VIEW_TITULO, "Un. Med.")
		
		oStruNNF:SetProperty( 'NNF_ITEM'   , MVC_VIEW_ORDEM, "01")
		oStruNNF:SetProperty( 'NNF_CODENT' , MVC_VIEW_ORDEM, "02")
		oStruNNF:SetProperty( 'NNF_LOJENT' , MVC_VIEW_ORDEM, "03")
		oStruNNF:SetProperty( 'NNF_NOMENT' , MVC_VIEW_ORDEM, "04")
		oStruNNF:SetProperty( 'NNF_NLJENT' , MVC_VIEW_ORDEM, "05")
		oStruNNF:SetProperty( 'NNF_CDCORR' , MVC_VIEW_ORDEM, "06")
		oStruNNF:SetProperty( 'NNF_NMCORR' , MVC_VIEW_ORDEM, "07")
		oStruNNF:SetProperty( 'NNF_VLBCOM' , MVC_VIEW_ORDEM, "08")
		oStruNNF:SetProperty( 'NNF_PCBCOM' , MVC_VIEW_ORDEM, "09")
		oStruNNF:SetProperty( 'NNF_MODCOM' , MVC_VIEW_ORDEM, "10")
		oStruNNF:SetProperty( 'NNF_STATUS' , MVC_VIEW_ORDEM, "11")
		oStruNNF:SetProperty( 'NNF_UNIMED' , MVC_VIEW_ORDEM, "12")
		
		If cPaisLoc != "PAR" .AND. cPaisLoc != "ARG"
			oStruNJR:SetProperty( 'NJR_MODAL' , MVC_VIEW_FOLDER_NUMBER, "3")
			oStruNJR:SetProperty( 'NJR_DESMOD', MVC_VIEW_FOLDER_NUMBER, "3")
			oStruNJR:SetProperty( 'NJR_INSCPO', MVC_VIEW_FOLDER_NUMBER, "3")
		EndIf

	EndIf

    oStruNJR:SetProperty( "NJR_QTDINI" 	, MVC_VIEW_CANCHANGE, .F.)	

	//seta modelo	
	oView:SetModel( oModel )

	If __lMostraAlg 
		// Opção qualidade do MENU
		If __lnewComerc // Se usa o novo modelo de comercialização e o Agio Desagio então	
			/*######## ALGODÃO ########*/	
			oView:CreateHorizontalBox( "PASTA_ALGODAO", 100, , , , )			
			oView:CreateFolder('ALGFOLDER','PASTA_ALGODAO',STR0124) // #Algodão

			oView:AddSheet('ALGFOLDER','ALGPRINCP', STR0118) // #Principal
			oView:AddSheet('ALGFOLDER','AGIOTIPO', STR0119 + " - " + STR0120) // #Ágio Deságio - Tipo 
			oView:AddSheet('ALGFOLDER','AGIOHVI', STR0119 + " - " + STR0121) // #Ágio Deságio - HVI 
			oView:AddSheet('ALGFOLDER','AGIOOUTRO', STR0119 + " - " + STR0122) // #Ágio Deságio - Outros 
			oView:AddSheet('ALGFOLDER','CONTAMINA', STR0200) // #Limites Contaminantes
			
			/*######## PRINCIPAL ########*/       
			oView:AddField( "VIEW_FIELDALG" , oStruNJRE, "NJRUNICO")      // Adiciona o Field com base na estrutura da NJR com os campos especificos
			oView:AddOtherObject( "VIEW_ALGGRIDS" , {|oPanel, oObj| OGA290FLWS(oPanel, oObj)})  // Adiciona o objeto que contem as duas grids de tipos aceitaveis e qualidade do algodão

			oView:CreateHorizontalBox( "ALGODAOFLD" , 20, , , "ALGFOLDER", "ALGPRINCP")
			oView:CreateHorizontalBox( "ALGODAOGRD" , 80, , , "ALGFOLDER", "ALGPRINCP") // Cria um box para as grids de tipos aceitaveis e qualidade do algodão

			oView:SetOwnerView("VIEW_FIELDALG", "ALGODAOFLD")       
			oView:SetOwnerView("VIEW_ALGGRIDS", "ALGODAOGRD")    

			/*****TIPO************/
			//--Field Agio/Desagio
			oView:AddField( "VIEW_TIPOC" , oStruNJRT	, "NJRUNICO")
			//--Grid Tipo
			oView:AddGrid( "VIEW_TIPOT"	 , oStruN7J		, "N7JUNICO")
			//--Grid Cor
			oView:AddGrid( "VIEW_TIPOM"	 , oStruN7G		, "N7GUNICO")		
			//--Grid HVI
			oView:AddGrid( "VIEW_TIPOR"	 , oStruN7F		, "N7FUNICO")	

			oView:CreateHorizontalBox( "PASTA_TIPOC", 20, , , "ALGFOLDER", "AGIOTIPO" ) //Cabecalho
			oView:CreateHorizontalBox( "PASTA_TIPOTM", 50, , , "ALGFOLDER", "AGIOTIPO" ) //Box Tipo - Cor

			oView:CreateVerticalBox( "PASTA_TIPOT", 61, "PASTA_TIPOTM", , "ALGFOLDER", "AGIOTIPO" ) //TIPO
			oView:CreateVerticalBox( "PASTA_TIPOM", 39, "PASTA_TIPOTM", , "ALGFOLDER", "AGIOTIPO" ) //COR

			oView:CreateHorizontalBox( "PASTA_TIPOR", 30, , , "ALGFOLDER", "AGIOTIPO" ) //REGRA

			oView:SetOwnerView("VIEW_TIPOC", "PASTA_TIPOC")		//Cabecalho
			oView:SetOwnerView("VIEW_TIPOT", "PASTA_TIPOT")		//TIPO
			oView:SetOwnerView("VIEW_TIPOM", "PASTA_TIPOM")		//COR
			oView:SetOwnerView("VIEW_TIPOR", "PASTA_TIPOR")		//REGRA

			oView:EnableTitleView( "VIEW_TIPOC", STR0114 )		//"Parâmetros Ágio Deságio"
			oView:EnableTitleView( "VIEW_TIPOT", STR0115 )		//"Descontos por Tipo"
			oView:EnableTitleView( "VIEW_TIPOM", STR0116 )		//"Descontos por Cor"
			oView:EnableTitleView( "VIEW_TIPOR", STR0117 )		//"Regra Aplicação de Desconto Conforme Dados HVI"

			//--Auto Increment 
			oView:AddIncrementField( "VIEW_TIPOT", "N7J_SEQUEN"   )
			oView:AddIncrementField( "VIEW_TIPOR", "N7F_ITEM"   )
			oView:AddIncrementField( "VIEW_TIPOM", "N7G_SEQUEN"   )

			/***** HVI *****/
			oView:CreateHorizontalBox( "PASTA_HVIFLD", 35, , , "ALGFOLDER", "AGIOHVI" )
			oView:CreateHorizontalBox( "PASTA_HVIBOT", 65, , , "ALGFOLDER", "AGIOHVI" )

			oView:CreateVerticalBox( "PASTA_HVIGRD", 100, "PASTA_HVIBOT", , "ALGFOLDER", "AGIOHVI" )

			//--Field Agio/Desagio -- HVI
			oView:AddField( "VIEW_HVIFLD" , oStruNJRH	, "NJRUNICO")
			//--Grid Descontos HVI
			oView:AddGrid( "VIEW_HVIGRD"  , oStruN78H	, "N78HVI")
			oView:SetOwnerView("VIEW_HVIFLD", "PASTA_HVIFLD")		//Cabecalho
			oView:SetOwnerView("VIEW_HVIGRD", "PASTA_HVIGRD")		//GRID
			oView:EnableTitleView("VIEW_HVIFLD", STR0114)	 //"Parâmetros Ágio Deságio"
			oView:EnableTitleView("VIEW_HVIGRD", STR0130)    //"Descontos HVI"

			//--Auto Increment
			oView:AddIncrementField("VIEW_HVIGRD", "N78_SEQUEN")

			/***OUTROS ****/
			oView:CreateHorizontalBox( "PASTA_OUTROC", 25, , , "ALGFOLDER", "AGIOOUTRO" )
			oView:CreateHorizontalBox( "PASTA_OUTROG", 75, , , "ALGFOLDER", "AGIOOUTRO" )

			//--Field Agio/Desagio
			oView:AddField( "VIEW_OUTROC" , oStruNJRO	, "NJRUNICO")
			//--Grid Desconto
			oView:AddGrid( "VIEW_OUTROG"  , oStruN78O	, "N78OUTROS")

			oView:SetOwnerView("VIEW_OUTROC", "PASTA_OUTROC")		//Cabecalho
			oView:SetOwnerView("VIEW_OUTROG", "PASTA_OUTROG")		//TIPO

			oView:EnableTitleView( "VIEW_OUTROC", STR0114 )		//"Parâmetros Ágio Deságio"
			oView:EnableTitleView( "VIEW_OUTROG", STR0123 )		//"Ágio Deságio Outros"

			//--Limitantes Contaminantes
			oView:AddGrid( "VIEW_N9O", oStruN9O, "N9OUNICO" )
			oView:CreateHorizontalBox( "PASTA_CONTAM", 100, , , "ALGFOLDER", "CONTAMINA" )
			oView:SetOwnerView( "VIEW_N9O" , "PASTA_CONTAM" )			
			//--Auto Increment
			oView:AddIncrementField( "VIEW_OUTROG", "N78_SEQUEN"   )
			
			oView:AddUserButton(STR0182 ,'',{|oView, oButton| OGA290Rag(oView, oButton)}) // Importar regra Ágio/Deságio	
		
			/* Action definida para diferenciar o evento de deletar da grid N7J, quando é pressionado a tecla Del,
			para quando o DELETE e ocasionado ao adicionar uma nova linha e desfazer a linha retornando */
			oView:SetViewAction( 'DELETELINE', { |oView,cIdView,nNumLine| OGA290EDEL( oView,cIdView,nNumLine ) } )

			// Eventos de troca de linha para replicar nas grids paralelas N7J e N7G
			oView:SetViewProperty( 'VIEW_TIPOT', "CHANGELINE", {{ |oView, cViewID| OGA290CHJ(oView, cViewID) }} )
				
			oView:SetAfterViewActivate({|oView| OGA290VACT(oView)}) // Método chamado após a ativação da view
		EndIf
	Else 
		//contrato 
		//cria a pasta principal
		oView:CreateFolder( "CTRFOLDER")

		//abas folder contrato
		oView:AddSheet('CTRFOLDER', 'PRINCIPAL' , STR0118) // Principal
		oView:AddSheet('CTRFOLDER', 'CADENCIA'  , STR0029) // Cadência	
		oView:AddSheet('CTRFOLDER', 'FINANCEIRO', STR0028) // Financeiro		
		oView:AddSheet('CTRFOLDER', 'CORRETORA' , STR0030) // Corretoras

		If __lnewNeg //NOVO NEGOCIO
			oView:AddSheet('CTRFOLDER', 'EXPORTACAO', STR0138) // Exportação
			oView:AddSheet('CTRFOLDER', 'PEPRO'     , 'PEPRO') // #PEPRO
		EndIf

		//view master
		oView:AddField( "VIEW_NJR", oStruNJR, "NJRUNICO")
		oView:CreateHorizontalBox( "BOX-PRIN" , 100, , , "CTRFOLDER", "PRINCIPAL" )
		oView:SetOwnerView( "VIEW_NJR", "BOX-PRIN" )
		oView:EnableTitleView( "VIEW_NJR" )	

		//--  Adicionando Grupos na view  - adicionar em RUP?    --//
		oStruNJR:AddGroup( 'GRUPOA', ''     , '', 1 )
		oStruNJR:AddGroup( 'GRUPOB', Chr(09), '', 2 )   
		oStruNJR:AddGroup( 'GRUPOC', Chr(09), '', 3 )
		oStruNJR:AddGroup( 'GRUPOD', Chr(09), '', 4 )
		oStruNJR:AddGroup( 'GRUPOE', ''     , '', 5 )
		oStruNJR:AddGroup( 'GRUPOF', STR0227, '', 6 ) //Moeda de Faturamento
		oStruNJR:AddGroup( 'GRUPOG', STR0228, '', 7 ) //Moeda de Pagamento

		//-- Atribuindo Todos os Campos ao Grupo D (campos que fica em outras abas) --//
		AGRXSTPROP(oStruNJR, "*" , MVC_VIEW_GROUP_NUMBER , 'GRUPOE') // Verifica se o campo existe na estrutura antes de adicionar a view

		//-- Atribuindo os campos ao Grupo A--//
		aFields := Separa("NJR_CODCTR;NJR_ULTALT;NJR_DESCRI;NJR_DATA;NJR_CODENT;NJR_LOJENT;NJR_NOMENT;NJR_NLJENT;NJR_CODTER;NJR_LOJTER;NJR_NOMTER;NJR_NLJTER;NJR_CTREXT", ";")
		For nIt := 1 To Len(aFields)
			AGRXSTPROP(oStruNJR, aFields[nIt] , MVC_VIEW_GROUP_NUMBER , 'GRUPOA') // Verifica se o campo existe na estrutura antes de adicionar a view
		Next nIt

		AGRXSTPROP(oStruNJR, "NJR_TIPMER" , MVC_VIEW_GROUP_NUMBER , 'GRUPOA')
		
		//-- Atribuindo os campos ao Grupo B --//
		aFields := Separa("NJR_CODSAF;NJR_CODPRO;NJR_DESPRO;NJR_TABELA;NJR_DESTAB;NJR_GENMOD;NJR_TALHAO", ";")
		For nIt := 1 To Len(aFields)
			AGRXSTPROP(oStruNJR, aFields[nIt] , MVC_VIEW_GROUP_NUMBER , 'GRUPOB')
		Next nIt

		//-- Atribuindo os campos ao Grupo C --//
		aFields := Separa("NJR_OPETRI;NJR_OPEFUT;NJR_CODOPE;NJR_CODRPC;NJR_OPEFIS;NJR_TESEST;NJR_TESFIN;NJR_OBSADT;NJR_CODFIN;NJR_DESFIN", ";")
		For nIt := 1 To Len(aFields)
			AGRXSTPROP(oStruNJR, aFields[nIt] , MVC_VIEW_GROUP_NUMBER , 'GRUPOC')
		Next nIt

		AGRXSTPROP(oStruNJR, "NJR_TIPOCL" , MVC_VIEW_GROUP_NUMBER , 'GRUPOC')

		AGRXSTPROP(oStruNJR, "NJR_OBSADT" , MVC_VIEW_ORDEM , 'B9')
		AGRXSTPROP(oStruNJR, "NJR_TIPOCL" , MVC_VIEW_ORDEM , 'C0')

		//-- Atribuindo os campos ao Grupo D --//
		aFields := Separa("NJR_MODELO;NJR_MODBAS;NJR_STSASS;NJR_STSFIS;NJR_STSFIN;NJR_STSEST;NJR_STATUS", ";")
		For nIt := 1 To Len(aFields)
			AGRXSTPROP(oStruNJR, aFields[nIt] , MVC_VIEW_GROUP_NUMBER , 'GRUPOD')
		Next nIt
		
		//-- Atribuindo os campos ao Grupo F --//
		aFields := Separa("NJR_MOEDAR;NJR_DESMOR;NJR_DIASR", ";")
		For nIt := 1 To Len(aFields)
			AGRXSTPROP(oStruNJR, aFields[nIt] , MVC_VIEW_GROUP_NUMBER , 'GRUPOF')
		Next nIt

		//-- Atribuindo os campos ao Grupo G --//
		aFields := Separa("NJR_OPERAC;NJR_MOEDAF;NJR_DESMOF;NJR_DIASF", ";")
		For nIt := 1 To Len(aFields)
			AGRXSTPROP(oStruNJR, aFields[nIt] , MVC_VIEW_GROUP_NUMBER , 'GRUPOG')
		Next nIt

		If __lnewNeg 
			// NOVO NEGOCIO			
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
			oView:SetOwnerView( "VIEW_NN7", "BOX-BOT-FIN" )
			oView:SetOwnerView( "VIEW_N84", "BOX-TOP-FIN" )		
			oView:EnableTitleView( "VIEW_NN7") 	
			oView:EnableTitleView( "VIEW_N84") 			
			//increment fields
			oView:AddIncrementField( "VIEW_N84", "N84_SEQUEN" )
			oView:SetViewProperty("NN7UNICO", "ONLYVIEW")              
			oView:SetNoDeleteLine("NN7UNICO")
			
		Else
			//MODELO CLASSICO
			//view cadência
			oView:AddGrid( "VIEW_NNY", oStruNNY,  "NNYUNICO")
			oView:CreateHorizontalBox( "BOX-CADEN" , 100, , , "CTRFOLDER", "CADENCIA" )
			oView:SetOwnerView( "VIEW_NNY", "BOX-CADEN" )
			oView:EnableTitleView( "VIEW_NNY" )	
			//increment fields
			oView:AddIncrementField( "VIEW_NNY", "NNY_ITEM"   )
			
			//view financeiro
			oView:AddGrid( "VIEW_NN7", oStruNN7, "NN7UNICO")
			oView:CreateHorizontalBox( "BOX-TOP-FIN" , 100, , , "CTRFOLDER", "FINANCEIRO" )
			oView:SetOwnerView( "VIEW_NN7", "BOX-TOP-FIN" )
			oView:EnableTitleView( "VIEW_NN7") 				
			//increment fields
			oView:AddIncrementField( "VIEW_NN7", "NN7_ITEM"   )
			oView:AddIncrementField( "VIEW_NN7", "NN7_PARCEL" )
		EndIf	

		//view Corretora
		oView:AddGrid( "VIEW_NNF", oStruNNF,  "NNFUNICO")				
		oView:CreateHorizontalBox( "BOX-TOP-COR" , 100, , , "CTRFOLDER", "CORRETORA" )		
		oView:SetOwnerView( "VIEW_NNF", "BOX-TOP-COR" )	
		oView:EnableTitleView( "VIEW_NNF" )		
		//increment fields
		oView:AddIncrementField( "VIEW_NNF", "NNF_ITEM"   ) 

		If __lnewNeg 
			//NOVO NEGOCIO
			//view exportação	
			oView:AddField( "VIEW_FIELDEXP" , oStruNJRX, "NJRUNICO") // Adiciona o Field com base na estrutura da NJR com os campos especificos
			oView:AddGrid(  "VIEW_EXPGRIDS"	, oStruN7R,  "N7RUNICO") // Adiciona o Grid de portos
			oView:CreateHorizontalBox( "EXPORTACAOFLD" , 30, , ,"CTRFOLDER", 'EXPORTACAO') // Cria um box para a field dos campos de exportação
			oView:CreateHorizontalBox( "EXPORTACAOGRD" , 70, , ,"CTRFOLDER", 'EXPORTACAO') // Cria um box para a grid de Portos/Aeroportos
			oView:SetOwnerView("VIEW_FIELDEXP", "EXPORTACAOFLD")       
			oView:SetOwnerView("VIEW_EXPGRIDS", "EXPORTACAOGRD")    
			oView:EnableTitleView( "VIEW_EXPGRIDS") 
			oView:AddIncrementField( "VIEW_EXPGRIDS", "N7R_ITEM" )			
			
			/*FOLDER PEPRO*/ 
			If TableInDic("NLN")
				oView:CreateHorizontalBox("PASTA_NLN", 100, , , "CTRFOLDER", "PEPRO")		
				oView:AddGrid("VIEW_NLN", oStruNLN, "NLNUNICO")
				oView:SetOwnerView("VIEW_NLN", "PASTA_NLN")
				oView:EnableTitleView("VIEW_NLN")
			Endif
		
			oView:AddUserButton("Demonstrativo de Preços" ,'',{|oView, oButton| OGA290DPRC(oView, oButton)}) // # "Demonstrativo Preços"
		
		EndIf
	EndIf

	//botões de outras ações	
	oView:AddUserButton(STR0089 ,'',{|| OGC003( NJR->NJR_CODCTR ) } ) //romaneios
	oView:AddUserButton(STR0080 ,'',{|oView, oButton| OGA290Prc(oView, oButton)}) //"Composição de Preços"	
    	
	If __lnewNeg
		//NOVO NEGOCIO
		oView:AddUserButton( STR0160  ,'',{|oView, oButton| OGA290VNGC(NJR->NJR_CODNGC)}) // Consultar negociação		
		oView:addUserButton("Selecionar Fardos", 'MAGIC_BMP',{|oView| OGX290SF(oView)}, STR0004, , {MODEL_OPERATION_UPDATE}) // # "Selecionar Fardos" # "Seleção de Fardos pertencentes as regras ficais."
	EndIf

	oView:SetCloseOnOk( {||.t.} ) 

Return( oView )

/*{Protheus.doc} ValPreN7J
(Função de Prá-Validação da Grid de Descontos por Tipo - Folha)
@type function
@author roney.maia
@since 31/05/2017
@version 1.0
@param oGridModel, objeto, (Submodelo da grid N7J)
@param nLine, numérico, (Linha que está sendo validada)
@param cAction, character, (Ação executada na grid)
@param cIDField, character, (Campo acionado)
@param xValue, variável, (Valor contido no campo)
@param xCurrentValue, variável, (Novo valor a ser inserido no campo)
@return ${return}, ${.T. - Validado, .F. - Falso}
*/
Static Function ValPreN7J(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)

	Local lRet 		:= .T.
	Local cSoma		:= ""
	Local oModelN7J	:= oGridModel:GetModel():GetModel("N7JUNICO") // Sub Model N7J
	Local oModelN7G	:= oGridModel:GetModel():GetModel("N7GUNICO") // Sub Model N7G

	If cAction == "ADDLINE" // Se Ação for de adicionar linha
		oModelN7G:SetNoInsertLine(.F.) // Habilita a inserção de linhas da grid N7G - Descontos por Cor
		oModelN7G:AddLine(.T.) // Adiciona uma nova linha na grid N7G - Descontos por Cor
		oModelN7G:SetNoInsertLine(.T.) // Desabilita a inserção de linhas da grid N7G - Descontos por Cor
		If ValType(__oViewNJR) != "U" // Validação para realizar o incremento do campo N7G_SEQUEN atraves da view caso ela exista ou não, realizando pelo model
			__oViewNJR:Refresh("VIEW_TIPOM") // Aplica o refresh na grid Desc Tipo - Folha
		Else
			cSoma := Soma1(oModelN7G:GetValue("N7G_SEQUEN",oModelN7G:Length()  - 1))			
			oModelN7G:SetValue("N7G_SEQUEN", cSoma)
		EndIf
		oModelN7G:GoLine(Iif(oGridModel:GetLine() == 1, 1,oGridModel:GetLine() - 1))	
	ElseIf cAction == "DELETE" // Se a Ação for Delete
		oModelN7J:GoLine(nLine) // Posiciona a linha da grid N7J - Descontos por Tipo/Folha
		oModelN7G:GoLine(nLine) // Posiciona a linha da grid N7G - Descontos por Cor, na linha corrente da grid N7J
		If !Empty(oModelN7J:GetValue("N7J_TCRTIP")) // Se contem valor no campo de tipo, então deleta a linha correspondente na grid de Desc Cor, senão, deleta fisicamente
			oModelN7G:DeleteLine(.F., .T.)
		Else	
			oModelN7G:DeleteLine(.T., .T.)
			oModelN7G:GoLine(1)
		EndIf
		If ValType(__oViewNJR) != "U"
			__oViewNJR:Refresh("VIEW_TIPOM") // Aplica o refresh na grid Desc Cor
			__oViewNJR:Refresh("VIEW_TIPOT") // Aplica o refresh na grid Desc Tipo - Folha
		EndIf
	ElseIf cAction == "UNDELETE" // Se a Ação for Undelete
		oModelN7G:GoLine(nLine) // Posiciona na linha correspondente da grid Desc Cor
		oModelN7G:UnDeleteLine() // Aplica o Undelete na linha
		If ValType(__oViewNJR) != "U"
			__oViewNJR:Refresh("VIEW_TIPOM")
			__oViewNJR:Refresh("VIEW_TIPOT")
		EndIf	
	ElseIf cAction == "SETVALUE"
		If __lAutomato .and. ValType(__oViewNJR) == "U" // Validação para realizar o incremento do campo N7J_SEQUEN,N7G_SEQUEN atraves do model quando a view não existe, ex: automação
			oModelN7J:GoLine(nLine)
			If Empty(oModelN7J:GetValue("N7J_SEQUEN"))
				cSoma := Soma1(PadL( oModelN7J:Length()-1,TamSx3("N7J_SEQUEN")[1],'0'))			
				oModelN7J:LoadValue("N7J_SEQUEN", cSoma)
			EndIf
			oModelN7G:GoLine(nLine) //para cada N7J é criado uma N7G
			If Empty(oModelN7G:GetValue("N7G_SEQUEN"))
				cSoma := Soma1(PadL( oModelN7G:Length()-1,TamSx3("N7G_SEQUEN")[1],'0'))
				oModelN7G:SetValue("N7G_SEQUEN", cSoma)
			EndIf
		EndIf
	EndIf

Return lRet

/*{Protheus.doc} OGA290EDEL
(Função responsável por separar a lógica de DELETE
da grid N7J Desc Tipo - Folha, Lógica aplicada na função, somente
acionada quando o DELETE for acionado pela tecla Delete)
@type function
@author roney.maia
@since 31/05/2017
@version 1.0
@param oView, objeto, (View Ativa)
@param cIdView, character, (Id da View disparou o evento)
@param nNumLine, numérico, (Numero da linha corrente)
*/
Static Function OGA290EDEL( oView,cIdView,nNumLine )

	Local lRet := .T.
	Local oModelN7J := oView:GetModel():GetModel("N7JUNICO")

	If cIdView $ "VIEW_TIPOT"
		// Se o valor do campo estiver vazio, marcado como deletado e o tamanho da grid maior que 1
		// insere uma nova linha na grid N7G - Desc Cor e marca como deletada.
		If Empty(oModelN7J:GetValue("N7J_TCRTIP")) .AND. oModelN7J:IsDeleted(nNumLine) .AND. oModelN7J:Length() > 1 
			oView:GetModel():GetModel( "N7GUNICO" ):SetNoInsertLine(.F.) 
			oView:GetModel():GetModel("N7GUNICO"):AddLine(.T.)
			oView:GetModel():GetModel( "N7GUNICO" ):SetNoInsertLine(.T.)
			oView:GetModel():GetModel( "N7GUNICO" ):DeleteLine(.F., .T.)

			If !__lAutomato
                oView:Refresh("VIEW_TIPOM")
                oView:Refresh("VIEW_TIPOT")	
            EndIf
		EndIf
	EndIf

Return lRet

/*{Protheus.doc} OGA290CHJ
(Função que replica a troca de linha com a grid N7G Desc Cor)
@type function
@author roney.maia
@since 31/05/2017
@version 1.0
@param oView, objeto, (View Ativa)
@param cViewID, character, (Id da View que acionou o evento)
*/
Static Function OGA290CHJ(oView, cViewID)
Local lRet := .T.

	// Se a Linha for diferente da correspondente, aplica o GoLine e em seguida o Refresh
	If oView:GetModel():GetModel("N7JUNICO"):GetLine() != oView:GetModel():GetModel("N7GUNICO"):GetLine()
		oView:GetModel():GetModel("N7GUNICO"):GoLine(oView:GetModel():GetModel("N7JUNICO"):GetLine())
		oView:Refresh("VIEW_TIPOM")
		oView:Refresh("VIEW_TIPOT")
	EndIf

Return lRet

/** {Protheus.doc} ValPosN7F
Função que valida o gride de dados após a perda do foco ou a confirmação do modelo

@param:     oGride - Gride do modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     01/01/2015  
@Uso:       OGA290 - Contratos
*/
Static Function ValPosN7F( oGride ) 
	Local nLinha    	:= 0
	Local nX        	:= 0	
	Local oModel	  	:= oGride:GetModel()
	Local oModelNJRT	:= oModel:GetModel("NJRUNICO")

	/*Validação de valores*/
	nLinha := oGride:GetLine()
	For nX := 1 to oGride:Length()
		If .not. oGride:IsDeleted()
			If !empty(oGride:GetValue('N7F_CAMPO', nX))
				If oModelNJRT:GetValue("NJR_TIPCAL", nX) = "1" //nenhum
					Help(" ",1,"OGA290N7F5") //Para informar uma regra por tipo, é necessário informar uma forma de cálculo.
					OGA290SFLD(FLDALG, FLDALGTTIPO)  
					Return .f.
				EndIf	
			ElseIf Empty(oGride:GetValue("N7F_CAMPO", nX)) .AND. oGride:Length() == nX .AND. oGride:IsUpdated(nX)
				oGride:GoLine(nX)
				oGride:DeleteLine()			
			ElseIf Empty(oGride:GetValue("N7F_CAMPO", nX)) .AND. oGride:IsUpdated(nX)
				Help(" ",1,"OGA290N7F2") //Para informar uma regra, é necessário informar o campo de HVI.
				OGA290SFLD(FLDALG, FLDALGTTIPO)
				Return .F.
			EndIf
		Endif   
	Next nX
	oGride:GoLine( nLinha )

Return .t.

/** {Protheus.doc} ValPosN7J
Função que valida o gride de dados após a perda do foco ou a confirmação do modelo de tipo

@param:     oGride - Gride do modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     01/01/2015  
@Uso:       OGA290 - Contratos
*/
Static Function ValPosN7J( oGride )
	Local nLinha    	:= 0
	Local nX        	:= 0
	Local oModel		:= oGride:GetModel()
	Local aFolhasFld	:= FwFormStruct(2, "N7J" , {|cCampos| ALLTRIM(cCampos) = "N7J_FOLHA"}):AFIELDS // Array somente com os campos de FOLHA
	Local oModelNJRT	:= oModel:GetModel("NJRUNICO")
	Local nIt			:= 0
	Local lPercen		:= .F.

	/*Validação de valores*/
	nLinha := oGride:GetLine()
	For nX := 1 to oGride:Length()
		oGride:GoLine( nX )
		nMaxPercen := 0

		if .not. oGride:IsDeleted()
			For nIt := 1 To Len(aFolhasFld) // Realiza a soma dos valores dos campos FOLHA para validar com a porcentagem
				If oGride:GetValue(aFolhasFld[nIt][1]) > 100
					lPercen := .T.
					Exit
				EndIf
			Next nIt
			if !empty(oGride:GetValue('N7J_TCRTIP')) //tipo
				if oModelNJRT:GetValue("NJR_TIPCAL") = "3" .AND. lPercen
					Help(" ",1,"OGA290N785") //Para Forma de Cálculo por Porcentagem, o Valor de Cálculo não pode exceder 100%.   
					OGA290SFLD(FLDALG, FLDALGTTIPO)
					Return .f. 
				endif		
			endif 
		endif		
	Next nX
	oGride:GoLine( nLinha )

Return .t.

/** {Protheus.doc} ValPosN78H
Função que valida o gride de dados da aba HVI após a perda do foco ou a confirmação do modelo

@param:     oGride - Gride do modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     01/01/2015  
@Uso:       OGA290 - Contratos
*/
Static Function ValPosN78H( oGride ) 
	Local nLinha    	:= 0
	Local nX        	:= 0
	Local oModel	  	:= oGride:GetModel()
	Local oModelNJRT	:= oModel:GetModel("NJRUNICO")

	/*Validação de valores*/
	nLinha := oGride:GetLine()
	For nX := 1 to oGride:Length()

		If .NOT. oGride:IsDeleted()
			If !Empty(oGride:GetValue('N78_HVIREG', nX))
				If oModelNJRT:GetValue("NJR_HVICAL") = "1" //nenhum
					Help(" ",1,"OGA290N78H1") //Para informar uma regra por hvi, é necessário informar uma forma de cálculo.
					OGA290SFLD(FLDALG, FLDALGHVI)  
					Return .F.
				ElseIf oModelNJRT:GetValue("NJR_HVICAL") = "3" 	.AND. oGride:GetValue('N78_HVIPON', nX) > 100 /* Porcentagem */
					Help(" ",1,"OGA290N785") //Para Forma de Cálculo por Porcentagem, o Valor de Cálculo não pode exceder 100%.   
					OGA290SFLD(FLDALG, FLDALGHVI) 
					Return .F.
				ElseIf oModelNJRT:GetValue("NJR_HVICAL") = "3" 	.AND. (oGride:GetValue('N78_HVIPON', nX) * -1) > 100 /* Porcentagem */	
					Help(" ",1,"OGA290N789") //Para Forma de Cálculo por Porcentagem, o Valor de Cálculo não pode ser menor que -100%.   
					OGA290SFLD(FLDALG, FLDALGHVI) 
					Return .F.
				Elseif !OGA290TPDS(oGride:GetValue('N78_HVITIP', nX), oModel:GetModel("N7EUNICO")) //valida os tipos aceitaveis	
					OGA290SFLD(FLDALG, FLDALGHVI) 
					Return .F.
				Endif
			ElseIf Empty(oGride:GetValue("N78_HVICMP", nX)) .AND. oGride:Length() == nX .AND. oGride:IsUpdated(nX)
				oGride:GoLine(nX)
				oGride:DeleteLine()			
			ElseIf Empty(oGride:GetValue("N78_HVICMP", nX)) .AND. oGride:IsUpdated(nX)
				Help(" ",1,"OGA290N7F2") //Para informar uma regra, é necessário informar o campo de HVI.
				OGA290SFLD(FLDALG, FLDALGHVI)
				Return .F.	
			EndIf
		EndIf

	Next nX
	oGride:GoLine( nLinha )

Return .T.

/** {Protheus.doc} ValPosN78O
Função que valida o gride de dados após a perda do foco ou a confirmação do modelo de tipo

@param:     oGride - Gride do modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     01/01/2015  
@Uso:       OGA290 - Contratos
*/
Static Function ValPosN78O( oGride ) 
	Local nLinha    	:= 0
	Local nX        	:= 0
	Local oModel		:= oGride:GetModel()
	Local oModelNJRO	:= oModel:GetModel("NJRUNICO")

	/*Validação de valores*/
	nLinha := oGride:GetLine()
	For nX := 1 to oGride:Length()
		oGride:GoLine( nX )

		if .not. oGride:IsDeleted()
			if !empty(oGride:GetValue('N78_OUTCOD')) //tipo

				if oModelNJRO:GetValue("NJR_OUTCAL") = "1" //nenhum
					Help(" ",1,"OGA290N786") //Para informar um Ágio Deságio por tipo, é necessário informar uma forma de cálculo.  
					OGA290SFLD(FLDALG, FLDALGOUTR) 
					Return .f.
				elseif empty(oGride:GetValue('N78_OUTPON')) 
					Help(" ",1,"OGA290N787") //É obrigatório informar o Vlr do Calculo.  
					OGA290SFLD(FLDALG, FLDALGOUTR) 
					Return .f.
				elseif oModelNJRO:GetValue("NJR_OUTCAL") = "3" .and. oGride:GetValue('N78_OUTPON') > 100 /* Porcentagem */	
					Help(" ",1,"OGA290N785") //Para Forma de Cálculo por Porcentagem, o Valor de Cálculo não pode exceder 100%.   
					OGA290SFLD(FLDALG, FLDALGOUTR) 
					Return .f.
				endif
				//não pode informar uma restrição sem informar o hvi	
			elseif empty(oGride:GetValue('N78_OUTCOD')) .and.  !empty(oGride:GetValue('N78_OUTPON'))
				Help(" ",1,"OGA290N788") //Para informar um Ágio Deságio por tipo, é necessário informar o campo Tipo.  
				OGA290SFLD(FLDALG, FLDALGOUTR) 
				Return .f.
			endif
		endif	

		//Exclui o registro da Tabela de fardos por regra BCI
		If oGride:IsDeleted(nX) 
			OGC080EXFR("", oModelNJRO:GetValue('NJR_CODCTR'), oGride:GetValue('N78_SEQUEN') )
		EndIf
	Next nX
	oGride:GoLine( nLinha )

Return .t.

/** {Protheus.doc} ValPosN7G
Função que valida o gride de dados após a perda do foco ou a confirmação do modelo de tipo

@param:     oGride - Gride do modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     01/01/2015  
@Uso:       OGA290 - Contratos
*/
Static Function ValPosN7G( oGride ) 
	Local nLinha    	:= 0
	Local nX        	:= 0
	Local oModel		:= oGride:GetModel()
	Local oModelNJRT	:= oModel:GetModel("NJRUNICO")
	Local aCorFld		:= FwFormStruct(2, "N7G" , {|cCampos| ALLTRIM(cCampos) = "N7G_COR"}):AFIELDS // ARRAY somente com os CAMPOS COR
	Local nIt			:= 0
	Local lPercen		:= .F.

	/*Validação de valores*/
	nLinha := oGride:GetLine()
	For nX := 1 to oGride:Length()
		oGride:GoLine( nX )
		nMaxPercen := 0

		if .not. oGride:IsDeleted()
			For nIt := 1 To Len(aCorFld) // Realiza a soma dos valores dos campos COR para validar com a porcentagem
				If oGride:GetValue(aCorFld[nIt][1]) > 100
					lPercen := .T.
					Exit
				EndIf
			Next nIt
			if !empty(oGride:GetValue('N7G_TCRTIP')) //tipo
				if oModelNJRT:GetValue("NJR_TIPCAL") = "3" .AND. lPercen	
					Help(" ",1,"OGA290N785") //Para Forma de Cálculo por Porcentagem, o Valor de Cálculo não pode exceder 100%.   
					OGA290SFLD(FLDALG, FLDALGTTIPO) 
					Return .f.
				endif
			endif
		endif	

	Next nX
	oGride:GoLine( nLinha )

Return .t.
/*{Protheus.doc} ValPosN9O
(Função de pós validação da grid N9OUNICO)
@type function
@param oGrid, objeto, (Submodelo da Grid N9OUNICO)
@return ${return}, ${.T. = Validado, .F. = Inválido}
*/
Static Function ValPosN9O(oGrid) 

	Local lRet  := .T.
	Local nIt   := 0 
	
	For nIt := 1 To oGrid:Length()
		If Posicione("N76",1,xFilial("N76")+oGrid:GetValue("N9O_CODCON", nIt),"N76_TPCON") <> '5' .AND. !oGrid:isDeleted(nIt)
			Help(" ",1,".OGA290000009.") 
			Return .F.
		EndIf
		If oGrid:GetValue("N9O_FAIINI", nIt) > oGrid:GetValue("N9O_FAIFIM", nIt)
			Help(" ",1,".OGA290000010.") 
			Return  .F.		
		EndIf
	Next nIt
		
Return lRet

/*{Protheus.doc} ValPosN7E
(Função de pós validação da grid N7EUNICO)
@type function
@author roney.maia
@since 04/05/2017
@version 1.0
@param oGrid, objeto, (Submodelo da Grid N7EUNICO)
@return ${return}, ${.T. = Validado, .F. = Inválido}
*/
Static Function ValPosN7E(oGrid) 

	Local lRet 		    := .T.
	Local oModel 		:= oGrid:GetModel() // Obtem o Modelo a partir do submodelo da grid
	Local oModelNJRE 	:= oModel:GetModel("NJRUNICO") // Submodelo do Fields da aba Algodão
	Local cTipAlg		:= AllTrim(oModelNJRE:GetValue("NJR_TIPALG")) // Valor atribuido ao campo da aba algodão
	Local nIt			:= 0
	Local cTipOpc		:= ""

	//Só permite o preenchimento dos Tipos Aceitáveis se o Tipo Padrão estiver preenchido.	
	If Empty(cTipAlg)
		Help(" ",1,"OGA290CPO1")//"Para preencher o Tipo Aceitável de Algodão o Tipo Padrão não pode estar vazio."
		OGA290SFLD(FLDALG, FLDALGPRINC)
		lRet := .F.
	EndIf 

	If lRet
		For nIt := 1 To oGrid:Length()
			//Se foi preenchido e válido, então valida para que não seja igual ao tipo padrão  
			If AllTrim(oGrid:GetValue("N7E_TIPACE", nIt)) == cTipAlg .AND. !oGrid:isDeleted(nIt)
				Help(" ",1,"OGA290CPO2") //"O Tipo Aceitável de Algodão não pode ser igual ao Tipo Padrão."
				OGA290SFLD(FLDALG, FLDALGPRINC)
				lRet := .F.
				Exit
			EndIf
		Next nIt
	EndIf

	If lRet // Se válido, realiza lógica para popular o campo N7E_TIPACE com os tipo adicionados a grid
		For nIt := 1 To oGrid:Length()
			oGrid:GoLine(nIt)
			If !oGrid:IsDeleted()
				cTipOpc += ALLTRIM(oGrid:GetValue("N7E_TIPACE"))
				If nIt != oGrid:Length()
					cTipOpc += " OU "
				EndIf 
			EndIf
		Next nIt
		oModelNJRE:LoadValue("NJR_TIPACE", cTipOpc) // carrega o campo de tipos opcionais com os tipos da grid
	EndIf

Return lRet

/*{Protheus.doc} ValPosN7H
(Função de pos-validação da Grid N7H)
@type function
@author roney.maia
@since 16/05/2017
@version 1.0
@param oGride, objeto, (FwFormGrid - N7H)
@return ${return}, ${.T. - Validado, .F. - Não Validado}
*/
Static Function ValPosN7H( oGride ) 

	Local lRet			:= .T.
	Local nX        	:= 0

	/*Validação de valores*/
	For nX := 1 to oGride:Length()

		If !oGride:IsDeleted( nX )

			If !Empty(oGride:GetValue('N7H_CAMPO' , nX))	
				If Empty(oGride:GetValue('N7H_VLRINI', nX)) .OR. Empty(oGride:GetValue('N7H_VLRFIM', nX) )
					Help(" ",1,"OGA290N7F3") //É obrigatório informar o valor Inicial e Final da regra HVI.  
					OGA290SFLD(FLDALG, FLDALGPRINC) 
					Return .F.
				EndIf
				If oGride:GetValue('N7H_VLRINI', nX) > oGride:GetValue('N7H_VLRFIM', nX)
					Help(" ",1,"OGA290N7F6") // # O valor informado no campo ( De ) é maior que o valor informado no campo ( Até )
					OGA290SFLD(FLDALG, FLDALGPRINC) 
					Return .F.
				EndIf
				//não pode informar uma restrição sem informar o hvi	
			ElseIf Empty(oGride:GetValue('N7H_CAMPO', nX)) .AND. ( !Empty(oGride:GetValue('N7H_VLRINI', nX)) .OR. !Empty(oGride:GetValue('N7H_VLRFIM', nX) ))
				Help(" ",1,"OGA290N7F2") //Para informar uma regra, é necessário informar o campo de HVI.  
				OGA290SFLD(FLDALG, FLDALGPRINC) 
				Return .F.
			ElseIf Empty(oGride:GetValue("N7H_CAMPO", nX)) .AND. oGride:Length() == nX .AND. oGride:IsUpdated(nX)
				oGride:GoLine(nX)
				oGride:DeleteLine()			
			ElseIf Empty(oGride:GetValue("N7H_CAMPO", nX)) .AND. oGride:IsUpdated(nX)
				Help(" ",1,"OGA290N7F2") //Para informar uma regra, é necessário informar o campo de HVI.
				OGA290SFLD(FLDALG, FLDALGPRINC)
				Return .F.
			EndIf
		EndIf

	Next nX

Return lRet

/** {Protheus.doc} OGA290VTKP
Função que valida as datas de TakeUP e Limite de Fixação

@param:     dtCheck, dtCadem, cCampo
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     03/03/2017
@Uso:       OGA290/OGA280/OGA260 - Contratos
*/
Function OGA290VTKP(dtCheck, dtCadem, cCampo)

	if DtoS(dtCheck) >= DtoS(dtCadem)  
		Help( , , STR0031, , STR0110 +STR0112+ STR0113, 1, 0 ) 	//"AJUDA"###"A data take-up deve ser menor que a data inicial da Cadência."
		Return .f.
	endif

return .t.

/** {Protheus.doc} VldActveMd
Função que valida a inicialização do modelo de dados

@param:     oModel - Modelo de dados
@param:     nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA290 - Contratos
*/
Static Function VldActveMd( oModel, nOperation )
	Local lRetorno  := .t.
	Local nQtdPre   := IIF(NJR->( NJR_CTRLLG ) == "1" ,NJR->( NJR_AUTENT ) + NJR->( NJR_AUTSAI ), 0) //SE TEM AUTORIZAÇÕES 

   IF nOperation == MODEL_OPERATION_INSERT		
		If __lnewNeg .AND. !(IsInCallStack("OGX700CTR") .OR. IsInCallStack("OGX700ACTR"))
			If __lRegOpcional
				lRetorno := .t.
			Else
				Help(" ", 1, "OGA290INSR ")//Não é possivel incluir contratos. Para incluir contratos utilize a rotina Registro de Negócios.
				lRetorno := .f.
			EndIf
		EndIF
	ElseIF nOperation == MODEL_OPERATION_UPDATE
           __cEntidade      := NJR->( NJR_CODENT)
		   __cEntiLoja      := NJR->( NJR_LOJENT)
	ElseIF nOperation == MODEL_OPERATION_DELETE
	 	If !(IsInCallStack("OGX700CNEG")) .AND. !Empty(NJR->(NJR_CODNGC)) 
	 		cCodNog := NJR->(NJR_CODNGC)
			AgrHelp( STR0031,  STR0166 + cCodNog , STR0168 )//"Ajuda"###"Este contrato foi gerado pelo negócio , Para excluir o contrato é necessário rejeitar o negócio..
		    lRetorno := .f.
		
		ElseIf !(NJR->( NJR_MODELO ) == "1")  // Diferente de Pré-contrato(reg.negocio)
		    if  IsInCallStack("OGX700CNEG")
		        Help(" ", 1, "OGA290EXNEG ") //"AJUDA"###"Não é possivel rejeitar o negócio para rejeitar o negocio o contrato deve estar em pré contrato. 
	            lRetorno := .f.  //Não permite excluir  
			ElseIf NJR->( NJR_STATUS ) <> "P" .Or. NJR->( NJR_QTEFIS ) > 0 .OR.  NJR->( NJR_QTSFIS ) > 0 .OR. nQtdPre > 0  //Previsto
				AgrHelp(STR0031 , STR0037 , STR0283 ) //"AJUDA"###"Não é possivel excluir este contrato, pois ja foi confirmado ou esta em execução. ###Este contrato somente pode ser -Finalizado- ou - Encerrado-."
				lRetorno := .f.
			EndIf
        
		ElseIf !IsInCallStack("OGX700CNEG")
	        lRetorno := .f.  //Não permite excluir 
		EndIf

	EndIf

Return( lRetorno )

/** {Protheus.doc} /** {Protheus.doc} ActivateMD
Função executada logo apos ativar o modelo de dados
@param:     oModel - Modelo de dados
@param:     nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@author:    Emerson Coelho
@since:     02/08/16
@Uso:       OGA280 - Contratos
*/
Static Function ActivateMD( oModel, nOperation )
	Local oView			:= __oViewNJR	
	Local aArea			:= GetArea()

  	// Tratamento para Contratos Automaticos ( Nao permite Alterar a Cadencia , Nao Mostra Aba Financeiro )
	IF nOperation == MODEL_OPERATION_UPDATE .and. NJR->NJR_MODELO == '3'	// Contrato Automatico
			// --- Para Os Ctratos de Compra que são Automaticos a Cadencia /  Financeiro não pode ser alterado
			If !(IsInCallStack("OGX700CTR") .OR. IsInCallStack("OGX700ACTR"))
				oModel:GetModel( "NNYUNICO" ):SetNoInsertLine( .t. )
				oModel:GetModel( "NNYUNICO" ):SetNoUpdateLine( .t. )
				oModel:GetModel( "NNYUNICO" ):SetNoDeleteLine( .t. )
			endif
	
			If oView != NIL    // Para os Contratos de Compra do tipo automatico 
				oView:HideFolder('CTRFOLDER', FLDPREVFIN ,2) 		// Retira a Folder do Financeiro
			EndIF
	
	ElseIf nOperation == MODEL_OPERATION_UPDATE .and. (NJR->NJR_STATUS <> 'P' .OR. (!(IsInCallStack("OGX700CTR") .OR. IsInCallStack("OGX700ACTR")) .and. !empty(NJR->NJR_CODNGC) .and. !empty(NJR->NJR_VERSAO))) //verifica se tem cod negocio 
			
			//Validação edição de Prev. Entrega Novo Negócio e classico. 
			//contrato iniciado ou tem movimentação. Na venda teve saida.
			//Não permite insert/delete
			oModel:GetModel( "NNYUNICO" ):SetNoInsertLine( .t. )
			oModel:GetModel( "NNYUNICO" ):SetNoDeleteLine( .t. )
	Else
		oModel:GetModel( "NNYUNICO" ):SetNoInsertLine( .F. )
		oModel:GetModel( "NNYUNICO" ):SetNoUpdateLine( .F. )
		oModel:GetModel( "NNYUNICO" ):SetNoDeleteLine( .F. )
	EndIf

	RestArea(aArea)
Return( .t. )

/** {Protheus.doc} PreModelo
Função que valida o modelo de dados após a confirmação

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

		If cStatus $ "F|E"
			Help( , , STR0031, , STR0038, 1, 0 ) //"AJUDA"###"Contrato ja foi Finalizado ou Encerrado! não pode ser alterado."
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
	Local lContinua	:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local cCodEnt		:= oModel:GetValue( "NJRUNICO", "NJR_CODENT" )
	Local cLojEnt    	:= oModel:GetValue( "NJRUNICO", "NJR_LOJENT" )
	Local cTipo     	:= oModel:GetValue( "NJRUNICO", "NJR_TIPO" )
	Local cSafra   		:= oModel:GetValue( "NJRUNICO", "NJR_CODSAF" )
	Local cProd     	:= oModel:GetValue( "NJRUNICO", "NJR_CODPRO" )
	Local cCtr          := oModel:GetValue( "NJRUNICO", "NJR_CODCTR" )
	Local oNJR 			:= oModel:GetModel("NJRUNICO")
	Local aRetblock  	:= {}
	Local cProblema    	:= ''
	Local cSolucao     	:= ''	
	Local cNegocio      := ''	

	If nOperation == MODEL_OPERATION_INSERT 
		//Função para não permitir dois contratos com a mesma entidade e safra [OGA390]
		lContinua := OGA390B(xFilial("NJR"), cCodEnt, cLojEnt, cSafra, cProd, cTipo)				
	EndIf

	If __lRegOpcional .and. __lnewNeg .AND. AGRXQTDN9J(cCtr) == 0
		oModel:GetModel("NN7UNICO"):ClearData()
	EndIf
	
	If __lnewNeg .and. !AGRXNNYNN9(oModel) //valida nos registros das previsões de entrega com as regras fiscais as quantidades
		Return .F.
	EndIf

	If lContinua .AND. (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)
        
		If __lnewComerc .and. __lMostraAlg
			if !OGA290VAGD(oModel)
				Return .F.
			Endif	     		
		EndIf

		//Função para validar entidade 
		lContinua := AGRXVALENT("C", cCodEnt, cLojEnt) 

		If lContinua .And. !OGA260CADEN(oModel)
			Return .F.
		EndIf
	EndIf		

	If lContinua .AND. nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		//proteção de fonte
		if oModel:GetModelStruct("NJRUNICO")[3]:OFORMMODELSTRUCT:HasField("NJR_CODNGC")
			cNegocio  	:= oModel:GetValue( "NJRUNICO", "NJR_CODNGC" )
			cVersao   	:= oModel:GetValue( "NJRUNICO", "NJR_VERSAO" )
		endif
		
		If oNJR:GetValue("NJR_TIPMER") == '1' .AND. oNJR:GetValue("NJR_MOEDA") != 1 .and. !empty(cNegocio)
			//Se o tipo de mercado for interno(1=Interno;2=Externo) e moeda <> 1, é preciso informa-los			
			//Se as funções abaixo estiverem na pilha de chamadas não é necessário validar.
			If !( IsInCallStack("OGX700CTR") .OR. IsInCallStack("OGX700ACTR") )			
				If Empty(oNJR:GetValue("NJR_OPERAC") )
					Help( , , STR0031, , STR0187, 1, 0 ) //"AJUDA"###"Campo de (Recebimento) precisa ser informado."
					Return .F.
				EndIf
	
				If oNJR:GetValue("NJR_MOEDA") > 1 .and. oNJR:GetValue("NJR_OPERAC") == "2" .AND. oNJR:GetValue("NJR_MOEDAF") <= 1  //Moeda Provisória
					Help( , , STR0031, , "Quando informado a referência moeda como pagamento, é necessário informar a moeda provisória.", 1, 0, ,,,,,{"Informe uma moeda provisória diferente da moeda corrente."}, 1, 0 ) //"AJUDA"###"Moeda de recebimento é inválida. ### Quando o campo 'Ref.de Receb' é do tipo 1 - Faturamento, a moeda de Recebimento deve ser igual a moeda de Faturamento.
					Return .F.
				EndIf		
	
				If oNJR:GetValue("NJR_MOEDA") > 1 .AND.   (oNJR:GetValue("NJR_MOEDAR") <= 1)   //Moeda de conversao
					Help( , , STR0031, , "A moeda de Faturamento ou de Recebimento está inválida.", 1, 0, ,,,,,{"Quando a moeda do contrato é estrangeira e o contrato de mercado interno, a moeda de faturamento ou de recebimento deve ser diferente da moeda local."}, 1, 0 ) //"AJUDA"###"Quantidade de dias retroativos da moeda de recebimento é inválida.  ### Quando o campo 'Ref.de Receb' é do tipo 1 - Faturamento, a quantidade de dias da moeda de Recebimento deve ser igual a moeda de Faturamento.
					Return .F.
				EndIf
			EndIf
		Else
			oNJR:LoadValue( "NJR_MOEDAF" , 1 )
			oNJR:LoadValue( "NJR_DIASF"  , 0 )
			oNJR:LoadValue( "NJR_MOEDAR" , 1 )
			oNJR:LoadValue( "NJR_DIASR"  , 0 )
			oNJR:LoadValue( "NJR_OPERAC" , '1' )
		EndIf
	endif

	If __lnewNeg .and. !(IsInCallStack("OGX700CTR") .OR. IsInCallStack("OGX700ACTR"))
		lContinua := AGRXVLDNNF(oModel)
	EndIf    
		
	If ExistBlock ("OG290PREGV")
		aRetblock := ExecBlock ("OG290PREGV", .F., .F.)
		lContinua := aRetblock[1]
		cProblema := aRetblock[2]
		cSolucao  := aRetblock[3]
		If ! lContinua 
			oModel:SetErrorMessage( , , oModel:GetId() , "", "", cProblema,cSolucao, "", "")	
		EndIf
	EndIf

Return(lContinua)

/** {Protheus.doc} GrvModelo
Função que grava o modelo de dados após a confirmação

@param:     oModel - Modelo de dados
@return:    .t. - sempre verdadeiro
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA290 - Contratos
*/
Static Function GrvModelo( oModel )
	Local nOperation    	:= oModel:GetOperation()		
	Local cCodNeg			:= oModel:GetValue( "NJRUNICO", "NJR_CODNGC")
	Local oModelNJR 		:= oModel:GetModel( "NJRUNICO" )
	Local oModelNLN 		:= ""
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
	Local aDcos   			:= {}
	Local cMsg				:= ""	
	Local lNLNModify		:= .F.
    Local lNatureza         := .T.
	Local cStatusCtr		:= oModelNJR:GetValue("NJR_STATUS") //status do contrato antes de salvar o registro

	Default aGrvNKA := {}  //valor padrão caso a variavel não foi declarada ao usar o modelo de dados sem tela

	//proteção de fonte
	if oModel:GetModelStruct("NJRUNICO")[3]:OFORMMODELSTRUCT:HasField("NJR_CODNGC")
		cNegocio  	:= oModel:GetValue( "NJRUNICO", "NJR_CODNGC" )
		cVersao   	:= oModel:GetValue( "NJRUNICO", "NJR_VERSAO" )
	endif

	// Verifica se houve modificações nas regras fiscais
	If __lnewNeg //NOVO NEGOCIO
		oModelNNY	:= oModel:GetModel("NNYUNICO")
		oModelN9A	:= oModel:GetModel("N9AUNICO")
		oModelN9D	:= oModel:GetModel("N9DUNICO") 
		
        If TableInDic("NLN")
            oModelNLN  := oModel:GetModel("NLNUNICO")		
            If ValType(oModelNLN) == "O"
                lNLNModify := oModelNLN:IsModified()            
            EndIf
        EndIf

        lN9AModify := oModelN9A:IsModified()

		//testa e carrega se foi alterado a NNY, se sim faz o load do OGA700
		If (lNNYModify := oModelNNY:IsModified()) .AND. !isOGA700 .And. !__lAprTakeUp
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
				If !AGRXN8DAut(oModel, oModelNJR:GetValue("NJR_FILIAL"), oModelNJR:GetValue("NJR_CODCTR"),oModelNJR:GetValue("NJR_TIPFIX"))
					Help( , , STR0163, , STR0230, 1, 0 )  //"Existe mais de uma sequência de quantidades vinculadas de preço. Não é possível determinar qual fixaçao utilizar." # "Ajuda"
                    Return .f.
				EndIf
			EndIf
		EndIf

        If Empty(oModel:GetValue( "N9AUNICO", "N9A_NATURE"))			
			lNatureza := .F.
		Endif				
        
        //verifica a necessidade de refazer as previsões financeiras
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

	// Gravar Histórico Automaticamente
	If nOperation == MODEL_OPERATION_INSERT
		AGRGRAVAHIS(,,,,{"NJR",xFilial("NJR")+oModelNJR:Getvalue('NJR_CODCTR'),"3",STR0011}) //Incluir
	elseIf nOperation == MODEL_OPERATION_UPDATE
		AGRGRAVAHIS(,,,,{"NJR",xFilial("NJR")+oModelNJR:Getvalue('NJR_CODCTR'),"4",STR0012}) //Alterar 
		if (empty(cNegocio) .and. empty(cVersao) ) 
			lDelTitFin(oModelNJR:Getvalue('NJR_CODCTR'),__cEntidade,__cEntiLoja)//exclui as previsões 
		endif		
	elseIf nOperation == MODEL_OPERATION_DELETE
		AGRGRAVAHIS(,,,,{"NJR",xFilial("NJR")+oModelNJR:Getvalue('NJR_CODCTR'),"5",STR0018}) //Excluir
		lDelTitFin(oModelNJR:Getvalue('NJR_CODCTR'),oModelNJR:Getvalue('NJR_CODENT'),oModelNJR:Getvalue('NJR_LOJENT'))//exclui as previsões 
	Endif

	//Atualiza o Modelo/Status contrato
	AGXSITMOL(oModel)

	If nOperation == MODEL_OPERATION_INSERT .Or. ( nOperation == MODEL_OPERATION_UPDATE .And. oModelNJR:Getvalue('NJR_STATUS')=='P' )
		oModelNJR:LOADVALUE('NJR_QSLFCO', oModelNJR:Getvalue('NJR_QTDCTR') - oModelNJR:Getvalue('NJR_QTSFCO') + oModelNJR:Getvalue('NJR_QTEFCO') )
		oModelNJR:LOADVALUE('NJR_SLDFIS', oModelNJR:Getvalue('NJR_QTDCTR') - oModelNJR:Getvalue('NJR_QTSFIS') + oModelNJR:Getvalue('NJR_QTEFIS') )	
	EndIf	

	//--<< Inicio Tratamento Composição de Preço >>--
	If  empty(cNegocio) .and. empty(cVersao) .and.  !IsInCallStack("OGC020")  //não se aplica a geração automática do contrato pela negociação (OGA700)
		IF ( nOperation == MODEL_OPERATION_INSERT .OR.  nOperation == MODEL_OPERATION_UPDATE )
			fGrvComPrc( aGrvNKA , nOperation, oModel) //--<< Grava/Atualiza composição de preço >>--
		EndIF
	EndIf
	//--<< Fim    Tratamento Composição de Preço >>-- 
	// Se utilizado o novo modelo de comercialização realiza a transposição de campos dos submodelos NJREUNICO,
	//	NJRTUNICO, NJROUNICO para o submodelo NJRUNICO
	
	If TableInDic("NLN") .AND. (lNLNModify .OR. nOperation == MODEL_OPERATION_DELETE) //NLN-LIBERADO 12.1.25
		aAreaNLN := NLN->(GetArea())
		
		DbSelectArea("NLN")
		NLN->(DbSetOrder(1)) //NLN_FILIAL+NLN_CODCTR+NLN_ITEMPE+NLN_ITEMRF+NLN_SEQUEN
		If NLN->(DbSeek(oModelNJR:GetValue("NJR_FILIAL")+oModelNJR:GetValue("NJR_CODCTR")))
			While NLN->(!Eof()) .AND. NLN->(NLN_FILIAL+NLN_CODCTR) == oModelNJR:GetValue("NJR_FILIAL")+oModelNJR:GetValue("NJR_CODCTR") 
				
				//Atualiza a previsão de recebimento DCO
				If aScan(aDcos, NLN->NLN_NUMAVI+NLN->NLN_NUMDCO) == 0
					Processa({|| OGA810AVLP(NLN->NLN_FILIAL, NLN->NLN_NUMAVI, NLN->NLN_NUMDCO)}, STR0229) //"Atualizando previsão de recebimento do DCO..."
					aAdd(aDcos, NLN->NLN_NUMAVI+NLN->NLN_NUMDCO)
				EndIf
				
				NLN->(DbSkip())
			EndDo
		EndIf
				
		RestArea(aAreaNLN)
	 EndIf

	 If __lnewNeg .AND. nOperation != MODEL_OPERATION_DELETE     
        AGRXCADGRV(oModel)  
    EndIf
	
	lRet := FWFormCommit( oModel )

	// Se for o modelo de negócio, o commit foi realizado com sucesso, o tipo do produto for algodão, e as regras fiscais foram modificadas
	// então verifica se houve fardos movidos entre regras fiscais e grava os mesmos.
	If lRet .AND. __lnewNeg .AND. AGRTPALGOD(cCodProd) .AND. lN9AModify
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
	If lRet .AND. __lnewNeg .AND. !isOGA700 .and. ValType(oModel700) == "O"
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
		
		If lNNYModify 
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

	If ExistBlock( "OG332APG" )
		ExecBlock( "OG332APG", .f., .f. )
	EndIf

	If ( __lAprAuto .or. cStatusCtr == "I" ) .AND. nOperation == MODEL_OPERATION_UPDATE .AND.;
		!IsInCallStack("OGA700") .AND. !IsInCallStack("OGC020")
		OGA290C(,,,.f.) //confirma contrato 
	EndIf

		//Atualiza a previsão de recebimento DCO
	If lNLNModify .AND. lRet .AND. nOperation != MODEL_OPERATION_DELETE //NLN-LIBERADO 12.1.25
		aDcos := {}
		
		For nX := 1 to oModelNLN:Length()
			
			oModelNLN:GoLine(nX)
			If !oModelNLN:IsDeleted()			
				//Atualiza a previsão de recebimento DCO
				If aScan(aDcos, oModelNLN:GetValue("NLN_NUMAVI")+oModelNLN:GetValue("NLN_NUMDCO")) == 0
					Processa({|| OGA810AVLP(oModelNLN:GetValue("NLN_FILIAL"), oModelNLN:GetValue("NLN_NUMAVI"), oModelNLN:GetValue("NLN_NUMDCO"))}, STR0229) //"Atualizando previsão de recebimento do DCO..."
					aAdd(aDcos, oModelNLN:GetValue("NLN_NUMAVI")+oModelNLN:GetValue("NLN_NUMDCO"))
				EndIf
			EndIf			
			
		Next nX	
	EndIf	

Return( .t. )

/** {Protheus.doc} VLDCORET()
VALIDAÇÃO para não permitir corretores que não estão cadastrados no EEC
@author:    Agro
@since:     31/01/2018
@Uso:       Dicionario campo : NNF_CODENT
*/
Function VLDCORET()
	Local oModel    := FwModelActive()
	Local oModelNNF	:= oModel:GetModel("NNFUNICO")
	Local cAliasQry := ""
	Local cQry
	Local lRet := .T.
	
	If oModelNNF:GetValue("NNF_TIPCOM") <> "0"
	
		cAliasQry := GetNextAlias()
		cQry := " SELECT COUNT(*) CONT FROM " + RETSQLNAME('SY5') + " WHERE Y5_FORNECE = '" + oModelNNF:GetValue("NNF_CODENT")  + "' AND Y5_LOJAF = '" + POSICIONE("SA2",1,xFilial("SA2")+oModelNNF:GetValue("NNF_CODENT"),"A2_LOJA") +  "'"
		cQry := ChangeQuery( cQry )	
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
		
		FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cQry , 0, 0, {})
	
		dbSelectArea(cAliasQry)
		dbGoTop()
		//Verifica se existe registros no EEC que tenho o codigo do fornecedor
		If (cAliasQry)->CONT == 0
			Help(" ", 1, "OGA290CORET") //O Fornecedor informado não está cadastrado como agente corretor no modulo Easy Export Control.
			lRet := .F. 
		EndIf
		
		(cAliasQry)->(DbCloseArea())
		
	EndIf


Return( lRet )

/** {Protheus.doc} OGA290C
Rotina para que confirmação do contrato para que o mesmo possa ser utilizado

@param:     Nil
@param:     lMsgConfir - se mostra/apresenta mensagens na tela
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGA290C( cAlias, nReg, nAcao, lMsgConfir )
	Local aAreaAtu      := GetArea()
	Local oModel    	:= FwModelActive()
	Local aFina040      := {}
	Local lRetorno      := .T.
	Local lContinua     := .T.
	Local cNegocio      := NJR->NJR_CODNGC 
	Local cVersao       := NJR->NJR_VERSAO
	Local nValor        := 0
	Local cMsg          := ""
	Local aLinVncAux	:= {}
	Local aLinVncAux2	:= {}
	Local aVncCRec		:= {}
	Local aVncCPag		:= {}	
	Local nMoeda        := NJR->( NJR_MOEDA )
	Local cFilAntTmp 	:= cFilAnt
    Local nRet          := 1
    Local aRet1			:= {}
    Local aRet2			:= {}    
    Local nPosVlCrz     := 0
	
	Default lMsgConfir  := .t.

	Private lMsErroAuto := .f.

	If __lRegOpcional .and. __lnewNeg .and. NJR->NJR_TIPFIX = '2' .and. EMPTY(cNegocio) .AND. EMPTY(cVersao)  
		AGRXCNGC(NJR->NJR_CODCTR, NIL, .F.) //gera registro de negocio contrato AFIXAR
		cNegocio      := NJR->NJR_CODNGC 
		cVersao       := NJR->NJR_VERSAO
	EndIf
    
    If !AGRXVLDVLR()
        Return .F.
    EndIf

	If cPaisLoc == "PAR" .Or. cPaisLoc == "ARG"
		nValor := NJR->NJR_VLRBAS
	Else
		nValor := NJR->NJR_VLRUNI
	EndIf
	// -- Validações Padrão Antes de Confirmar -- //

	If NJR->NJR_TIPMER == '2'  //Tipo de Mercado: 1=Interno;2=Externo 
		CMsg := fVldNJR1() 
		If !Empty(cMsg)
		 	If lMsgConfir
				Help( ,,STR0031,, CMsg, 1, 0 ) 
		 	EndIf
			Return .F.
		EndIf
	EndIf	

	if !empty(cNegocio)
		If !AGRXValN84()
			Return .F.
		EndIf
	Endif
	
	If __lnewNeg .AND. Empty(NJR->NJR_TIPEMB)
		Help( , , STR0031, , 'O campo Tipo de Embalagem precisa ser informado.', 1, 0 ) //"AJUDA"###"O campo Tipo de Embalagem precisa ser informado."
		Return .F.
	EndIf	
	
	If __cAnaCred $ "1|2|3" //Parâmetro de análise de crédito: 1 - Interno, 2 - Externo, 3 - Ambos, 4 - Nenhum
		If __cAnaCred = NJR->NJR_TIPMER .OR. __cAnaCred = "3"
			If .not. AGRX500VCC(oModel)
				Return .F.
			EndIf
		EndIf
	EndIf
	
	IF !__lNGraPrevF 
		NN7->( dbSetOrder( 1 ) )
		if NN7->( dbSeek( FWxFilial( "NN7" ) + NJR->( NJR_CODCTR ) ) )
			While ! NN7->( Eof() ) .And. NN7->( NN7_FILIAL ) = xFilial( "NN7" ) .And. NN7->( NN7_CODCTR ) = NJR->( NJR_CODCTR )
				if NN7->NN7_DTVENC < dDatabase 
					If lMsgConfir
						Help( ,,STR0031,,STR0255, 1, 0 ) //"AJUDA"###"Contrato nao pode ser confirmado. Data de vencimento da previsão financeira anterior a data atual."
					EndIf
					Return .F.			
				endIf
				If NN7->NN7_VALOR <= 0
					//não continua.
				    Help( ,,STR0031,,STR0268, 1, 0 ) //"AJUDA"###"Contrato nao pode ser confirmado. Previsão Financeira não foi gerada."
					Return .F.
				EndIf				
				
				NN7->(DbSkip())
			endDo
		EndIf		
	EndIf
	
	IF lRetorno
		If NJR->NJR_MODELO = "1"
			If lMsgConfir
				Help( ,,STR0031,, STR0039, 1, 0 ) //"AJUDA"###"Pre-Contratos nao podem ser confirmados, altere para Contrato para depois confirmar."
			EndIf
			Return .F.
		ElseIF __lnewNeg .and. ( .Not. nValor > 0 .or. AGRXVALFIX(NJR->NJR_CODCTR,.T.) ) ; 
		.and. (cPaisLoc == "BRA" .or. ((cPaisLoc == "PAR" .or. cPaisLoc == "ARG") .and. EMPTY(NJR->NJR_CODIDX))) ;
		.and. !(!empty(cNegocio) .and. !empty(cVersao) .and. NJR->NJR_TIPFIX == "2") 
			//validação oga700 - negócios fixo	
			If lMsgConfir
				AGRHELP(STR0031,STR0272+STR0267,STR0273) //##Help //##Help ##Não há fixação de preço para o contrato. Composição de preço não gerada. ##Realize a fixação de preço na opção Outras Ações -> Fixação de preço.
			EndIf
			Return .F.
		ElseIf !__lnewNeg .and. empty(cNegocio) .and. empty(cVersao) .AND. NJR->NJR_TIPFIX != "2" .AND. AGRXVALFIX(NJR->NJR_CODCTR,.T.);
				.and. (cPaisLoc == "BRA" .or. ((cPaisLoc == "PAR" .or. cPaisLoc == "ARG") .and. EMPTY(NJR->NJR_CODIDX))) 
			AGRHELP(STR0031,STR0272+STR0267,STR0081) //##Help ##Não há fixação de preço para o contrato. Composição de preço não gerada. ##Contrato nao pode ser confirmado.Valor unitario não é válido. Informe composição de preços.
			Return .F.		
		ElseIf .Not. AGRXTOTFIN( NJR->NJR_CODCTR, NJR->NJR_VLRTOT, NJR->NJR_CODNGC)   //"A soma das quantias nos itens dos Titulos do Contrato esta divergente do Contrato!"
			Return .F.
		elseif __lnewComerc .AND. AGRTPALGOD(NJR->NJR_CODPRO) .and. (AllTrim(NJR->NJR_TIPALG) == '-' .or. empty(NJR->NJR_TIPALG)) //verifica se tem tipo padrão de algodão
			If lMsgConfir
				Help(" ",1,"OGA290CTIPALG")// # É necessário informar o Tipo Padrão para o contrato.
			EndIf
			Return .F.	
		ElseIf NJR->( NJR_MODELO ) $ "2|3"
			Do Case 
				Case NJR->NJR_STATUS == "P"
				// Não permite confirmar se houver outro contrato Confirmado ou Iniciado com a mesma Entidade e Safra
				If .not. OGA390B(xFilial("NJR"), NJR->NJR_CODENT , NJR->NJR_LOJENT , NJR->NJR_CODSAF, NJR->NJR_CODSAF , NJR->NJR_TIPO )
					Return .F.
				EndIf
				OtherWise
				If lMsgConfir
					Help( ,,STR0031,, STR0092 , 1, 0 ) //"AJUDA"###"Somente Contratos com status de previstos podem ser Confirmados"
				EndIf
				Return .F.
			EndCase

		EndIF

		//Não permite confirmar o contrato caso os campos TES,Finalidade,Entidade de faturamento ou se operação futura ou triagular, validar se TES auxiliar foi preenchida.
		If lRetorno .and. __lnewNeg
			AGRXVLDN9A(@lRetorno, @lContinua, lMsgConfir)
		EndIf
		
	EndIf
	// -- Fim Validações Padrão Antes de Confirmar -- //

	//-- PE para Validações  --//
	IF lContinua .And. ( (ExistBlock("OG290COK")) )
		If (! ExecBlock("OG290COK",.F.,.F.) )
			lContinua   := .F.
			lRetorno    := .F.
		EndIf
	EndIf
	//-------------------------------------//


	IF lContinua
		If NJR->( NJR_MODELO ) $ "2|3" .And. NJR->( NJR_STATUS ) = "P"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ A ocorrencia 23 (ACS), verifica se o usuario poder  ou n„o   ³
			//³ efetuar substituicao de titulos provisorios.                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF !ChkPsw( 23 )    
				If lMsgConfir
					Help( ,,STR0031,, STR0102 , 1, 0 )
				EndIf
				Return .F.
			EndIf

			//"Deseja realmente confirmar o contrato?"
            If !__lAutomato
                nRet := AGRGRAVAHIS(STR0040,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"N",,,lMsgConfir) 
            EndIf

			If nRet = 1
										
				BEGIN TRANSACTION
					
					if AGRTPALGOD( NJR->(NJR_CODPRO)) //calcula ágio e deságio
						Processa({|| OGX016(FwxFilial("NJR"), NJR->(NJR_CODCTR)) }, STR0173)		
					endif
					
					if !empty(cNegocio) .and. !empty(cVersao)  //novos negócios		
						//Recalcula Valores da regra FISCAL e recria as previsões
						OGX055(xFilial("NJR"), NJR->NJR_CODCTR)
					elseif !__lNGraPrevF
						NJ0->( dbSetOrder( 1 ) )
						NJ0->( dbSeek( xFilial( "NJ0" ) + NJR->( NJR_CODENT + NJR_LOJENT ) ) )
	
						NN7->( dbSetOrder( 1 ) )
						NN7->( dbSeek( xFilial( "NN7" ) + NJR->( NJR_CODCTR ) ) )
						While .Not. NN7->( Eof() ) .And. NN7->( NN7_FILIAL ) = xFilial( "NN7" ) .And. NN7->( NN7_CODCTR ) = NJR->( NJR_CODCTR )
						    lGerouCRec := .f.
							//--verifica a entidade informada na NN7
							NJ0->( dbSetOrder( 1 ) )
							If NJ0->( dbSeek( xFilial( "NJ0" ) + NJR->( NJR_CODENT + NJR_LOJENT ) ) )
	
								//--SE CODCOMP ESTIVER VAZIO REALIZA A INCLUSAO DO TIT. RECEBER
								If NN7->(ColumnPos("NN7_CODCOM")) == 0 .or. (NN7->(ColumnPos("NN7_CODCOM")) > 0 .and. ( Empty(NN7->NN7_CODCOM) .OR. ALLTRIM(NN7->NN7_CODCOM) == 'TOTAL'))
									nVlrTit := NN7->( NN7_VALOR )
									If NJR->(NJR_TIPMER) != "1"
										nVlrCrz := xMoeda( nVlrTit, NJR->( NJR_MOEDA ), 1, dDataBase)
									Else	
										If NJR->( NJR_MOEDA ) <> 1 //Ver tratamento ideal
											If NJR->( NJR_TXMOED ) <= 0 //Se taxa da moeda for igual ou menor a zero, usa a da SM2
												nVlrCrz := xMoeda( nVlrTit, NJR->( NJR_MOEDA ), 1, dDataBase)
											Else // Se não, usa a do contrato
												nVlrCrz := nVlrTit * NJR->( NJR_TXMOEDA ) 
											Endif
										Else
											nVlrCrz := nVlrTit //Contrato em reais
										End
									EndIf
				
									aFina040 := {}
									aAdd( aFina040, { "E1_PREFIXO" , "CTR"                      , Nil } )
									aAdd( aFina040, { "E1_NUM"     , NJR->( NJR_CODCTR )        , Nil } )
									aAdd( aFina040, { "E1_PARCELA" , NN7->( NN7_PARCEL )        , Nil } )
									aAdd( aFina040, { "E1_TIPO"    , "PR "                      , Nil } )
									aAdd( aFina040, { "E1_CLIENTE" , NJ0->( NJ0_CODCLI ) 		, Nil } )
									aAdd( aFina040, { "E1_LOJA"    , NJ0->( NJ0_LOJCLI ) 		, Nil } )
									aAdd( aFina040, { "E1_EMISSAO" , dDataBase                  , Nil } )
									aAdd( aFina040, { "E1_VENCTO"  , NN7->( NN7_DTVENC )        , Nil } )
									aAdd( aFina040, { "E1_VALOR"   , nVlrTit                    , Nil } )
									aAdd( aFina040, { "E1_MOEDA"   , nMoeda     				, Nil } )
									aAdd( aFina040, { "E1_VLCRUZ"  , nVlrCrz                    , Nil } )
									aAdd( aFina040, { "E1_HIST"    , STR0042                    , Nil } ) //"Tit. Prov. Ctr. Orig."
									aAdd( aFina040, { "E1_ORIGEM"  , "OGA290"                   , Nil } )
	                                    
	                                //Caso taxa seja informada, então passa a geração de título
	                                If NJR->( NJR_MOEDA ) <> 1 .And. NJR->( NJR_TXMOED ) > 0 .And. .Not. __lnewNeg
										aAdd( aFina040, { "E1_TXMOEDA"  , NJR->( NJR_TXMOED )     , Nil } )
									End                  
	                                
	                                aAdd( aFina040, { "E1_FILORIG" , NN7->( NN7_FILORG )     	, Nil } ) //filial de origem da N9A
									aAdd( aFina040, { "E1_CLVL"    , NJR->( NJR_CLVL ) 	        , Nil } )
									aAdd( aFina040, { "E1_CLVLCR"  , NJR->( NJR_CLVL ) 	        , Nil } )
									aAdd( aFina040, { "E1_CLVLDB"  , NJR->( NJR_CLVL ) 	        , Nil } )
									aAdd( aFina040, { "E1_BCOCLI"  , NN7->( NN7_CODBCO ) 	    , Nil } )
									aAdd( aFina040, { "E1_AGECLI"  , NN7->( NN7_CODAGE ) 	    , Nil } )
									aAdd( aFina040, { "E1_CTACLI"  , NN7->( NN7_CODCTA ) 	    , Nil } )
									
									If SE1->(FieldPos("E1_CTROG")) > 0 //LEGADO - se campo existir manter gravando informação
										aAdd( aFina040, { "E1_CTROG"   , NJR->( NJR_CODCTR )     , Nil } )										
										aAdd( aFina040, { "E1_CODSAF"  , NJR->( NJR_CODSAF )     , Nil } ) 										
									EndIf

									If .Not. Empty(NN7->( NN7_NATURE )) //verifica se possui natureza
										aAdd( aFina040, { "E1_NATUREZ" , NN7->( NN7_NATURE )    , Nil } )
									EndIf			
									
									//Criando Vinculo com SE1
									aLinVncAux := {}									
									aadd( aLinVncAux, { "N8L_FILIAL"    	, FwXfilial('SE1') 							} )
									aadd( aLinVncAux, { "N8L_FILORI"    	, cFilant								    } )
									aadd( aLinVncAux, { "N8L_PREFIX"    	, 'CTR'										} )
									aadd( aLinVncAux, { "N8L_NUM"    		, NJR->NJR_CODCTR 							} )
									aadd( aLinVncAux, { "N8L_PARCEL"    	, NN7->NN7_PARCEL		 					} )
									aadd( aLinVncAux, { "N8L_TIPO"    		, "PR "										} )
									aadd( aLinVncAux, { "N8L_CODCTR"    	, NJR->NJR_CODCTR							} )
									aadd( aLinVncAux, { "N8L_SAFRA"	    	, NJR->NJR_CODSAF							} )
									aadd( aLinVncAux, { "N8L_CODROM"    	, ''										} )
									aadd( aLinVncAux, { "N8L_ITEROM"   		, ''										} )
									aadd( aLinVncAux, { "N8L_CODFIX"   		, ''										} )
									aadd( aLinVncAux, { "N8L_CODOTR"    	, ''										} )
									aadd( aLinVncAux, { "N8L_ORPGRC"   		, ''										} )	
									aadd( aLinVncAux, { "N8L_ORIGEM"    	, 'OGA290'		 							} )
									aAdd( aLinVncAux, { "N8L_HISTOR"    	, FWI18NLang("OGA290","STR0175",175)		} )  //Previsão financeira, Contrato de vendas
									
									aAdd(aVncCRec,aLinVncAux)
									
									If !Empty(NN7->( NN7_FILORG ))
										cFilAnt := NN7->( NN7_FILORG )
									EndIf
									
									If ExistBlock('OG290F40')
										aRet1 :=  ExecBlock('OG290F40',.F.,.F.,{aFina040}) 
										If ValType(aRet1) == 'A'
											aFina040 := aClone(aRet1)
										EndIf
									EndIf					
									
									//Bruna
									nPosVl    := aScan(aFina040, {|x| x[1] == "E1_VALOR"})
									nPosVlCrz := aScan(aFina040, {|x| x[1] == "E1_VLCRUZ"})
																		
									nVlrTit := aFina040[nPosVl,2]
									If NJR->(NJR_TIPMER) != "1"
										nVlrCrz := xMoeda( nVlrTit, NJR->( NJR_MOEDA ), 1, dDataBase)
									Else	
										If NJR->( NJR_MOEDA ) <> 1 //Ver tratamento ideal
											If NJR->( NJR_TXMOED ) <= 0 //Se taxa da moeda for igual ou menor a zero, usa a da SM2
												nVlrCrz := xMoeda( nVlrTit, NJR->( NJR_MOEDA ), 1, dDataBase)
											Else // Se não, usa a do contrato
												nVlrCrz := nVlrTit * NJR->( NJR_TXMOEDA ) 
											Endif
										Else
											nVlrCrz := nVlrTit //Contrato em reais
										End
									EndIf
									
									aFina040[nPosVlCrz,2] := nVlrCrz
									
									MsExecAuto( { |x,y| Fina040( x, y ) }, aFina040, 3 )
									
									If lMsErroAuto
										MostraErro()
										lRetorno    := .f.
										DisarmTransaction()     // Tenho q ter o DisarmTransaction antes do mostraErro, pois enquanto o usuario estiver com tela de erro aberta, todos os regs. stão travados.
										Break
										//Exit  Exit Substituido por return, para não cair no DisarmTransaction um pouco mais abaixo
									EndIf
									
									cFilAnt := cFilAntTmp
								
								//--SE CODCOMP COM CONTEUDO REALIZA A INCLUSAO DO TIT. PAGAR
								ElseIf NN7->(ColumnPos("NN7_CODCOM")) > 0 .and. !Empty(NN7->NN7_CODCOM) .AND. ALLTRIM(NN7->NN7_CODCOM) != "TOTAL"
							
									If .NOT. OGXN8MVLD() //validação campo N8M
										lRetorno    := .f.
										Exit
									EndIf
									
									// Gera titulos provisórios no financeiro 
									cPrefixo    := PadR( "CTR", TamSX3( "E2_PREFIXO" )[1] )
									cNumero 	:= PadR( NJR->( NJR_CODCTR ), TamSX3( "E2_NUM" )[1] )
									cTipTit    	:= PadR( "PR", TamSX3( "E2_TIPO" )[1] )
									
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
									aAdd( aFina050, { "E2_HIST"    , "Tit. Prov. Ctr. Orig. Compl.", Nil } ) 	//"Tit. Prov. Ctr. Orig."
									aAdd( aFina050, { "E2_ORIGEM"  , "OGA290"                   , Nil } )
									
									If .Not. Empty(NN7->( NN7_NATURE ))
										aAdd( aFina050, { "E2_NATUREZ" , NN7->( NN7_NATURE )    , Nil } )
									EndIf
	 								If .Not. Empty(NN7->( NN7_CCD ))
										aAdd( aFina050, { "E2_CCD" , NN7->( NN7_CCD )          	, Nil } )
									EndIf
	
		                            //Criando Vinculo com SE2
									aLinVncAux2 := {}										
									aadd( aLinVncAux2, { "N8M_FILIAL"    	, FwXfilial('N8M') 							} )
									aadd( aLinVncAux2, { "N8M_FILORI"    	, cFilant								    } )
									aadd( aLinVncAux2, { "N8M_PREFIX"    	, 'CTR'										} )
									aadd( aLinVncAux2, { "N8M_NUM"    		, NJR->NJR_CODCTR 							} )
									aadd( aLinVncAux2, { "N8M_PARCEL"    	, NN7->NN7_PARCEL		 					} )
									aadd( aLinVncAux2, { "N8M_TIPO"    		, "PR "										} )
									aAdd( aLinVncAux2, { "N8M_FORNEC"      	, NJ0->( NJ0_CODFOR ) 		                } )
									aAdd( aLinVncAux2, { "N8M_LOJA"         , NJ0->( NJ0_LOJFOR ) 		                } )
									aadd( aLinVncAux2, { "N8M_CODCTR"    	, NJR->NJR_CODCTR							} )
									aadd( aLinVncAux2, { "N8M_CODSAF"	    , NJR->NJR_CODSAF							} )
									aadd( aLinVncAux2, { "N8M_CODROM"    	, ''										} )//ROMANEIO
									aadd( aLinVncAux2, { "N8M_ITEROM"   	, ''										} )//ITEM DO ROMANEIO
									aadd( aLinVncAux2, { "N8M_ITEMFX"   	, ''										} )//ITEM FIXAÇÃO
									aadd( aLinVncAux2, { "N8M_ORDTRA"    	, ''										} )//ORDEM DE TRANSITO
									aadd( aLinVncAux2, { "N8M_ORIGEM"    	, 'OGA290'		 							} )//ORIGEM
									aAdd( aLinVncAux2, { "N8M_HISTOR"    	, FWI18NLang("OGA290","STR0175",175)		} )  //Previsão financeira, Contrato de vendas
									
									aAdd(aVncCPag,aLinVncAux2)
									
									If !Empty(NN7->( NN7_FILORG ))
										cFilAnt := NN7->( NN7_FILORG )
									EndIf
									
									If ExistBlock('OG290F50')
										aRet2 :=  ExecBlock('OG290F50',.F.,.F.,{aFina050}) 
										If ValType(aRet2) == 'A'
											aFina050 := aClone(aRet2)
										EndIf
									EndIf
				
									MsExecAuto( { |x,y| Fina050( x, y ) }, aFina050, 3 )
									
									If lMsErroAuto
										MostraErro()
										lRetorno := .f.
										Exit
									EndIf
									
									cFilAnt := cFilAntTmp
																								
								EndIf
							EndIF
							NN7->( dbSkip() )
						EndDo
						IF lRetorno .and. Len( aVncCRec ) > 0
						   	lRetorno:= fAgrVncRec (aVncCRec, 3 )  //Incluir
						EndIf
						IF lRetorno .and. Len( aVncCPag ) > 0
							lRetorno := fAgrVncPag (aVncCPag, 3 )  //Incluir
						EndIF
					endif
					
					If lRetorno
						If NJR->( NJR_OPEFUT ) = "1"
							If RecLock( "NJR", .f. )
								NJR->( NJR_STATUS ) := "A"
								NJR->( MsUnLock() )
							EndIf
						EndIf
						
						// Atualiza as quantidades autorizadas do contrato
						OGX010QAut("A")
						
						if empty(cNegocio) .and. empty(cVersao) //novos negócios	
							//ATUALIZA O FINACEIRO
							If NJR->(NJR_QTSFCO) - NJR->(NJR_QTEFCO)  > 0
								OGA250ATUF(NJR->( NJR_CODCTR ) , NJR->(NJR_QTSFCO) - NJR->(NJR_QTEFCO) , "2")
							Endif
						ELSE
							//Atualiza o codigos dos Contratos Externo caso o contrato já possuia IE
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
							
							//Atualizar os valores financeiros no contrato - DAGROCOM-3521	
							OGX310(2,NJR->NJR_CODCTR)
						ENDIF	
						
						//END TRANSACTION                   //Colocado aqui para Garantir q os Registros não fique travados se o usuario não sair da Mensagem
						If lMsgConfir .and. !__lAutomato
							MsgInfo( STR0045, STR0046 ) //"Contrato Confirmado com Sucesso!!!"###"Confirmação do Contrato"
						EndIf
						lRetorno := .t.
					Else
						DisarmTransaction()
						lRetorno := .f.
					EndIf

				END TRANSACTION 
			Else
				lRetorno := .f.
			EndIf
		Else
			If lMsgConfir
				Help( ,,STR0031,, STR0047, 1, 0 ) //"AJUDA"###"Este contrato ja foi confirmado..."
			EndIf
			lRetorno := .f.
		EndIf
	EndIf

	RestArea( aAreaAtu )
Return( lRetorno )

/** {Protheus.doc} OGA290E
Rotina para utilizada para encerrar o contrato para que o mesmo nao seja mais movimentado

@param:     Nil
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGA290E( cAlias, nReg, nAcao )
	Local aAreaAtu  := GetArea()
	Local cCodNog := ""
	Local lEnc    := .T.
	Local lRet := .T.

	BEGIN TRANSACTION	
		IF ValCancel() 
			Help(, , STR0031, , STR0096, 1, 0 )
			lRet := .F.
		Else
			If NJR->( NJR_STATUS ) $ "A|I|P"
				If !Empty(NJR->(NJR_CODNGC))
					cCodNog := NJR->(NJR_CODNGC)
					Help( ,,STR0031,,STR0166 +cCodNog, 1, 0, , , ,,,{STR0167} ) //"Ajuda"###"Este contrato foi gerado pelo negocio, Não é possivel cancelar o contrato.
					lRet := .F.
				ElseIf NJR->( NJR_STATUS) == "P" 
					Help( ,,STR0031,, STR0152, 1, 0 ) //"Ajuda"###"Contrato com status 'Previsto' não pode ser cancelado. Somente é permitido a operação de 'Excluir'.
					lRet := .F.
				Else				
					AGRXATUNN8("C")							
					If !__lNGraPrevF // Validação para anular mesmo sem ter gerado previsão	
						If NJR->( NJR_QTEFIS ) = 0 .AND.  NJR->( NJR_QTSFIS )= 0
							//"Deseja realmente encerrar este contrato?"
								If !__lAutomato
									lEnc :=  AGRGRAVAHIS(STR0048,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"E") = 1
								EndIf
								If  lEnc 

									If RecLock( "NJR", .f. )
										NJR->( NJR_QTDCTR ) := NJR->( NJR_QTSFCO )
										NJR->( NJR_AUTENT ) := NJR->( NJR_QTEFCO )
										NJR->( NJR_AUTSAI ) := NJR->( NJR_QTSFCO )
										msUnLock()
									EndIf
				
									lDelTitFin(NJR->NJR_CODCTR,NJR->NJR_CODENT,NJR->NJR_LOJENT)//exclui as previsões 
				
									//////////////////////////
									// Atualiza qtdes do contrato e saldos
									//////////////////////////
									OGX010QTDS("E")
				
									If !__lAutomato
										MsgInfo( STR0049, STR0050 ) //"Contrato Encerrado com Sucesso!!!"###"Encerramento do Contrato"
									EndIf
								EndIF
							
						Else
							Help( ,,STR0031,,STR0068, 1, 0 ) //"Ajuda"#### "Contrato nao pode ser encerrado. Existe saldo de quantidades."
							lRet := .F.
						EndIf
			
					Else // Sem Previsão Financeira
			
						If AGRGRAVAHIS(STR0048,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"E") = 1 
							If RecLock( "NJR", .f. )
								NJR->( NJR_QTDCTR ) := NJR->( NJR_QTSFCO )
								NJR->( NJR_AUTENT ) := NJR->( NJR_QTEFCO )
								NJR->( NJR_AUTSAI ) := NJR->( NJR_QTSFCO )
								msUnLock()
							EndIf
			
							lDelTitFin(NJR->NJR_CODCTR,NJR->NJR_CODENT,NJR->NJR_LOJENT)//exclui as previsões 
			
							//////////////////////////
							// Atualiza qtdes do contrato e saldos
							//////////////////////////
							OGX010QTDS("E")
			
							If !__lAutomato
								MsgInfo( STR0049, STR0050 ) //"Contrato Encerrado com Sucesso!!!"###"Encerramento do Contrato"
							EndIf
						EndIf
					EndIf 
				EndIf		
			Else
				Help( ,,STR0031,, STR0051, 1, 0 ) //"Ajuda"###"Este contrato não pode ser -Encerrado-, pois ja foi -Finalizado-..."
				lRet := .F.
			EndIf
		EndIf

		If !lRet
			DisarmTransaction()
		Endif
	END TRANSACTION
	RestArea( aAreaAtu )
Return( Nil )

/** {Protheus.doc} OGA290F
Rotina para utilizada para finalizar o contrato para que o mesmo nao seja mais movimentado

@param:     Nil
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGA290F( cAlias, nReg, nAcao )
	Local aAreaAtu    := GetArea()
	Local aTpContrato := SuperGetMV("MV_AGRO001",.F., "") //tipo do contrato //1COMPRA 2 VENDA 3 ARM DE TERC 4 ARMA EM TERC
	Local nIt		  := 0
	Local lRet        := .T.

	If !Empty(aTpContrato) // Verifica o parametro de tipo do contrato
		aTpContrato := Separa(aTpContrato, ";")
		For nIt := 1 To Len(aTpContrato)
			If NJR->( NJR_TIPO )== AllTrim(aTpContrato[nIt])// se o tipo não fizer parte do parametro valida normalmente
				lRet := .f. 
				//"Deseja realmente finalizar este contrato?"
				If NJR->( NJR_STATUS ) $ "I" 
					If AGRGRAVAHIS(STR0084,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"F") = 1
						If RecLock( "NJR", .f. )
							NJR->( NJR_STATUS ) := "F"
							msUnLock()
						EndIf
						lDelTitFin(NJR->NJR_CODCTR,NJR->NJR_CODENT,NJR->NJR_LOJENT)//exclui as previsões 
						If !__lAutomato
                            MsgInfo( STR0052, STR0053 ) //"Contrato Finalizado com Sucesso!!!"###"Finalizacao do Contrato"
                        EndIf
					EndIf
				Else
					Help( ,,STR0031,, STR0174, 1, 0 ) //"Ajuda"###"Contrato não pode Finalizado. Verifique o Status do Contrato em Outras Ações."
					Return( Nil )
				EndIf
			
			EndIf
		Next nIt
		If lRet 
			If ( NJR->( NJR_STSASS ) = "F" .and. NJR->( NJR_STSEST ) = "F" .and. NJR->( NJR_STSFIS ) = "F" .and. NJR->( NJR_STSFIN ) = "F" .and. NJR->( NJR_STATUS ) $ "I" )
				//"Deseja realmente finalizar este contrato?"
				If AGRGRAVAHIS(STR0084,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"F") = 1
					If RecLock( "NJR", .f. )
						NJR->( NJR_STATUS ) := "F"
						msUnLock()
					EndIf
					lDelTitFin(NJR->NJR_CODCTR,NJR->NJR_CODENT,NJR->NJR_LOJENT)//exclui as previsões 
					If !__lAutomato
                        MsgInfo( STR0052, STR0053 ) //"Contrato Finalizado com Sucesso!!!"###"Finalizacao do Contrato"
                    EndIf
				EndIf
			Else
				Help( ,,STR0031,, STR0174, 1, 0 ) //"Ajuda"###"Contrato não pode Finalizado. Verifique o Status do Contrato em Outras Ações."
				Return( Nil )
			EndIf	
		EndIf
	Else
		If ( NJR->( NJR_STSASS ) = "F" .and. NJR->( NJR_STSEST ) = "F" .and. NJR->( NJR_STSFIS ) = "F" .and. NJR->( NJR_STSFIN ) = "F" .and. NJR->( NJR_STATUS ) $ "I" )
			//"Deseja realmente finalizar este contrato?"
			If AGRGRAVAHIS(STR0084,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"F") = 1
				If RecLock( "NJR", .f. )
					NJR->( NJR_STATUS ) := "F"
					msUnLock()
				EndIf
				lDelTitFin(NJR->NJR_CODCTR,NJR->NJR_CODENT,NJR->NJR_LOJENT)//exclui as previsões 
				If !__lAutomato
                    MsgInfo( STR0052, STR0053 ) //"Contrato Finalizado com Sucesso!!!"###"Finalizacao do Contrato"
                EndIf
			EndIf
		Else
			Help( ,,STR0031,, STR0174, 1, 0 ) //"Ajuda"###"Contrato não pode Finalizado. Verifique o Status do Contrato em Outras Ações."
			Return( Nil )
		EndIf	
	EndIf
	RestArea( aAreaAtu )
Return( Nil )

/** {Protheus.doc} oGa290PRC
Rotina para Chamada da função de composicao de precos OGA420
@param:     Nil
@author:    Emerson Coelho
@since:     02/10/2014
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGA290Prc(oView, oButton)
	Local oModel     	:= FWModelActive()
	Local oGridNNY  	:= oModel:GetModel( "NNYUNICO" )
	Local oGridNN7  	:= oModel:GetModel( "NN7UNICO" )
	Local nOperation    := oModel:GetOperation()
	Local aCompPrc  	:= aGrvNKA 
	Local cTipoFx       := ''
	Local cNjrCodCtr    := oModel:GetValue( "NJRUNICO", "NJR_CODCTR" )
	Local cProduto  	:= oModel:GetValue( "NJRUNICO", "NJR_CODPRO" )
	Local dDtFixa   	:= dDatabase
	Local nQtfixar      := oModel:GetValue( "NJRUNICO", "NJR_QTDINI" )
	Local cNk7Aplica    := 'V' //Venda
	Local cNjrUm1Pro    := oModel:GetValue( "NJRUNICO", "NJR_UM1PRO" )
	Local cNjrUmPrc     := oModel:GetValue( "NJRUNICO", "NJR_UMPRC" )
	Local nNjrMoeda 	:= oModel:GetValue( "NJRUNICO", "NJR_MOEDA" )
	Local lEditar   	:= IF(nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE,.t., .f. )
	Local lTemCmpPrc    := .f.
	Local nX        	:= 0
	Local nLinha        := 0
	Local nPos			:= 0	
	Local cItem         := "000"
	Local cParc         := "0"
	Local cNegocio  	:= ""	
	Local cVersao   	:= ""	
	Local lGeraPrev     := .F.	
	Local nLinhaPrev    := 0	
	Local dVcto         := nil
	Local lConfirma     := .F.
	
	//proteção de fonte
	If oModel:GetModelStruct("NJRUNICO")[3]:OFORMMODELSTRUCT:HasField("NJR_CODNGC")
		cNegocio  	:= oModel:GetValue( "NJRUNICO", "NJR_CODNGC" )	
		cVersao   	:= oModel:GetValue( "NJRUNICO", "NJR_VERSAO" )	
	EndIf
	
	If (!empty(cNegocio) .and. !empty(cVersao)) .or. (__lnewNeg .and. nOperation == MODEL_OPERATION_INSERT) .or. AGRXCVNNGC( FwxFilial("NJR"), cNjrCodCtr )
		OGC050(FwxFilial("NJR"),cNjrCodCtr) //chama somente em visualização
	else //old method	
		IF nOperation == MODEL_OPERATION_INSERT  .OR. cPaisLoc == "PAR" .Or. cPaisLoc == "ARG"  //DAGROGAP-1445
			cTipoFx     := IIF( AllTrim( oModel:GetValue( "NJRUNICO", 'NJR_TIPFIX' )) == '1' , '1' , IIF( AllTrim( oModel:GetValue( "NJRUNICO", 'NJR_TIPFIX' )) == '3' , '2' , '0' ) )  //--<< njr_tipfix (1=Fixo;2=A Fixar;3=basis(pataguai)),cTipoFix (0=Previsto,1=Firme,2=basis(pataguai)) //DAGROGAP-1445
		Else
			cTipoFx     := IIF( AllTrim( NJR->NJR_TIPFIX ) == '1' , '1' , IIF( AllTrim( oModel:GetValue( "NJRUNICO", 'NJR_TIPFIX' )) == '3' , '2' , '0' ) )  //--<< njr_tipfix (1=Fixo;2=A Fixar),cTipoFix (1=Previsto,2=Firme) //DAGROGAP-1445
		EndIF
						// --<< Verifica se existe a Fixação >>--
		dbSelectArea( "NN8" )
		NN8->( dbSetOrder( 2 ) )  //Contrato + Tipo + Item Fix
		If NN8->(DbSeek(xFilial( "NN8" ) + cNjrCodCtr + cTipoFx  ))
			lTemCmpPrc  := .t.
			dDtFixa     := NN8->NN8_DATA
			dDEntrIni   := NN8->NN8_DATINI
			dDEntrFim   := NN8->NN8_DATFIN
			IF Len ( aGrvNKA )== 0
				aCompPrc    :=oGa420NKAR( cNjrCodCtr , NN8->NN8_ITEMFX ) //--<< Le a NKA e Recebe Retorno do Array com os Dados >>--
			EndIF
			//Se FOR Firme e Possuir Entregas lEditar = falso
			IF NJR->NJR_TIPFIX == '1' .AND. NN8->NN8_QTDENT > 0
				lEditar := .F.
			EndIf       
		EndIF

		If cPaisLoc != "PAR" .AND. cPaisLoc != "ARG"
			If !Empty(oModel:GetValue( "NJRUNICO", "NJR_DATREF" )) 
				dDtfixa := oModel:GetValue( "NJRUNICO", "NJR_DATREF" ) 
			EndIF
		EndIf

		IF ! lTemCmpPrc  //--<< Ainda não existe Composição de preço >>--
			dDEntrIni := CTOD('//')
			dDEntrFim := CTOD('//')
			nLinha := oGridNNY:GetLine()
			For nX := 1 to oGridNNY:Length()
				oGridNNY:GoLine( nX )				
				If .Not. oGridNNY:IsDeleted()
					If  cPaisLoc == "PAR" .OR. cPaisLoc == "ARG"
						If .Not. oGridNNY:IsDeleted()
							IF dDEntrIni == CTOD('//') .or. oGridNNY:GetValue( "NNY_DATINI" ) < dDEntrIni
								dDEntrIni := oModel:GetValue( "NJRUNICO", "NJR_DATREF" )
							EndIF
							IF dDEntrFim == CTOD('//') .or. oGridNNY:GetValue( "NNY_DATFIM" ) > dDEntrFim
								dDEntrFim := oModel:GetValue( "NJRUNICO", "NJR_DATREF" )
							EndIF
						EndIF
	                ELSE				
						IF dDEntrIni == CTOD('//') .or. oGridNNY:GetValue( "NNY_DATINI" ) < dDEntrIni
							dDEntrIni := oGridNNY:GetValue( "NNY_DATINI" )
						EndIF
						IF dDEntrFim == CTOD('//') .or. oGridNNY:GetValue( "NNY_DATFIM" ) > dDEntrFim
							dDEntrFim := oGridNNY:GetValue( "NNY_DATFIM" )
						EndIF
				    EndIF		
				EndIF
			Next nX
			oGridNNY:GoLine( nLinha )

			//Validar se os Campos que são necessarios Para Chamar a função não estão Vazio
			Do Case
				Case Empty( cProduto  )
				Help( , , STR0034, , STR0071 , 1, 0 ) //"AJUDA"###"Informe produto para o Contrato"
				Return (.f.)
				Case Empty( dDEntrIni )
				Help( , , STR0034, , STR0072, 1, 0 ) //"AJUDA"###"Informe Cadencia para o Contrato"
				Return (.f.)
				Case Empty( dDEntrFim )
				Help( , , STR0034, , STR0072, 1, 0 ) //"AJUDA"###"Informe Cadencia para o Contrato"
				Return (.f.)
				Case nQtfixar == 0
				Help( , , STR0034, , STR0073, 1, 0 ) //"AJUDA"###"Informe Qtidade para o Contrato"
				Return (.f.)
				Case Empty( cNjrUm1Pro )
				Help( , , STR0034, , STR0074, 1, 0 ) //"AJUDA"###"Informe Unidade de medida para o Contrato"
				Return (.f.)
				Case Empty( nNjrMoeda  )
				Help( , , STR0034, , STR0075, 1, 0 ) //"AJUDA"###"Informe Moeda do Contrato"
				Return (.f.)
			EndCase
		EndIF

		aCompPrc := OGA420( cNjrCodCtr , cProduto , dDtfixa , dDEntrIni , dDEntrFim , nQtfixar , cNk7Aplica, cNjrUm1Pro,cNjrUmPrc,nNjrMoeda,aCompPrc , lEditar, nil, nil, nil, nil, nil, cTipoFx, nil )  
		aGrvNKA := aCompPrc
		//--Se permite editar e array maior que zero [contem informações]
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
			
			IF Len ( aCompPrc ) > 0 //--<< Encontro onde está o total no Array  >>--
				nPosTotal := aSCAN( aCompPrc, {|aCompPrc| aCompPrc[07] == "3" })
				IF nPosTotal > 0
					//--<< Atualiza NJR_VLRUNI com o Dado que veio da Composição de preço >>-- 
					oModel:LoadValue( "NJRUNICO", "NJR_VLRUNI", aCompPrc[nPosTotal,11] )        //--<< Pula todas as Validações >>--
					//If cPaisLoc <> "PAR" .and. cPaisLoc <> "ARG"  
						IF cTipoFx == "1" //--<< Se for Fixo , Tenho que Atualizar o Vr. do NJRVLRBAS >>-
							oModel:SetValue( "NJRUNICO", "NJR_VLRBAS", aCompPrc[nPosTotal,11] )
						EndIF
	                //EndIF 
					//--<< Calc. Vr Total de acordo com as unidades de medidas (Produto e Contrato)
					//--<< Utilizar NJR_QTDCTR para considerar os aditivo caso houver    

 					//pega o fator de conversão
					nConvert := AGRX001(oModel:GetValue( "NJRUNICO", "NJR_UMPRC" ), oModel:GetValue( "NJRUNICO", "NJR_UM1PRO" ),1, /*cProduto*/)
					//calcula o total
					nVrTotal := OGA420TOT(aCompPrc[nPosTotal,11], oModel:GetValue( "NJRUNICO", "NJR_QTDCTR" ) , nConvert)
				
					oModel:LoadValue( "NJRUNICO", "NJR_VLRTOT", nVrTotal )  //--<< Pula todas as Validações >>--

					If !__lNGraPrevF // __lNGraPrevF = .F. --> Gera previsão financeira
						oGridNN7:LoadValue( "NN7_VALOR", nVrTotal )     //--<< Atualiza o Total no Grid do financeiro >>---
					Else
						//não gera a previsão financeira
						Return .T.				
					EndIf
				EndIF
			EndIF
			
			
			If !__lAutomato
				lConfirma := MSGYESNO(STR0172 , STR0013) //Confirma a geração de informação de componentes de preço? Confirmar
			EndIf
			
			If lConfirma .OR. __lAutomato
				For nPos := 1 TO Len(aCompPrc)				
					If aCompPrc[nPos][16] <> 0
						DbSelectArea("NK7")		//Tabela de Componentes de Preço
						DbSetOrder(1)			//NK7_FILIAL+NK7_CODCOM
						If DbSeek(xFilial("NK7") + aCompPrc[nPos][3] )
							If NK7->(ColumnPos("NK7_GERFIN")) > 0 .and.  NK7->NK7_GERFIN $ "3|4"
								lGeraPrev := .T.
							Else
								lGeraPrev := .F.
							EndIf
						Else
							lGeraPrev := .F.
						EndIf
						
						If lGeraPrev // Gera Previsão Financeira quando posicionar na NK7 
							oGridNN7:AddLine() //adiciona uma nova linha para criar  títulos provisórios de despesas para o componnete
							cItem	:= StrZero(oGridNN7:Length(), TamSX3( "NN7_ITEM" )[1]) 
							cParc 	:= StrZero(oGridNN7:Length(), TamSX3( "NN7_PARCEL" )[1])
							
							nValCom := Round(oModel:GetValue( "NJRUNICO", "NJR_QTDCTR" ) * AGRX003(cProduto, aCompPrc[nPos][13], aCompPrc[nPos][14], 10), TamSX3('NJR_VLRTOT')[2])
						    
						    If oGridNN7:length() > 1
                                dVcto := oGridNN7:GetValue("NN7_DTVENC", oGridNN7:length()  - 1)
                            EndIf

                            If Empty(dVcto)
                                dVcto := dDataBase
                            EndIf
						    
							oModel:SetValue( "NN7UNICO", "NN7_ITEM"		, cItem)
							oModel:SetValue( "NN7UNICO", "NN7_CODCOM"	, aCompPrc[nPos][3])
							oModel:SetValue( "NN7UNICO", "NN7_ITMCOM"	, aCompPrc[nPos][4])									
							oModel:SetValue( "NN7UNICO", "NN7_PARCEL"	, cParc)
							oModel:SetValue( "NN7UNICO", "NN7_DTVENC"	, dVcto)
							oModel:SetValue( "NN7UNICO", "NN7_VALOR" 	, nValCom)
							oModel:LoadValue("NN7UNICO", "NN7_CODFAV" 	, NJ0->NJ0_CODCLI)//Favorecido para compra é o Cliente
							oModel:LoadValue("NN7UNICO", "NN7_LOJFAV" 	, NJ0->NJ0_LOJENT)
						EndIf						
					EndIf
				Next nPos			
					
			EndIf
			
			//--Posiciona na primeira linha da GRID
			oGridNN7:GoLine(1)
			If ValType(oView) != "U" // Atualiza a View
				oView:Refresh("NN7UNICO")
			EndIf
			
		//--Funçao para gatilho de favorecido
			AGRXVLFAV(oModel:GetModel( "NJRUNICO" ),oModel:GetValue( "NJRUNICO", "NJR_CODENT"), oModel:GetValue( "NJRUNICO", "NJR_LOJENT"))
		EndIF
	endif
	//--Posiciona na primeira linha da GRID
	oModel:GetModel('NN7UNICO'):GoLine(1)
Return


/*/{Protheus.doc} OGA290Rag
//Rotina para Chamada da função de importação de regras de Ágil / Deságil
@author Jefferson Schueroff
@since 09/04/2018
@version undefined
@param oView, object, descricao
@param oButton, object, descricao
@type function
/*/
Static Function OGA290Rag(oView, oButton)

  Local nIt					  := 0
  Local oModelNJR 	  := Nil
  Local oModelN7E 	  := Nil
  Local oModelN7H		  := Nil  
  Local nNewLin       := 0
  
  Local cAliasNJR  := ""
  Local cAliasN7E  := ""
  Local cAliasN7H  := ""
  Local cAliasN7J  := ""
  Local cAliasN7G  := ""
  
  Local cAliasN7F  := ""
  Local cAliasN78H := ""
  Local cAliasN78O := ""
  Local aSubModel			:= {"N7EUNICO", "N7HUNICO", "N7JUNICO", "N7GUNICO", "N7FUNICO", "N78HVI", "N78OUTROS"}
  
  Local oModel 				:= oView:GetModel() //Pega o modelo 
  Local cProduto  			:= oModel:GetValue( "NJRUNICO", "NJR_CODPRO" )
  
  Local aGrids 				:= {}
  
  
  If oModel:GetOperation() != 3 .and. oModel:GetOperation() != 4
  	Return .f.
  End If
  
  If .NOT. AGRTPALGOD(cProduto)
  	Help( , , STR0031, , STR0183, 1, 0 ) //"Somente poderá ser importado contrato se o produto for do tipo ALGODÃO."
  	Return .f.
  End If
  
  oModelNJR 	:= oModel:GetModel("NJRUNICO")
  
  //Aba Principal
  oModelN7E 	:= oModel:GetModel("N7EUNICO")
  oModelN7H		:= oModel:GetModel("N7HUNICO")
  
  //Aba Ágio / Deságio - Tipo
  oModelN7J		:= oModel:GetModel("N7JUNICO")
  oModelN7G		:= oModel:GetModel("N7GUNICO")
  
  //Aba Ágio / Deságio - Tipo - rodapé
  oModelN7F		:= oModel:GetModel("N7FUNICO")
  
  //Aba Ágio / Deságio - HVI
  oModelN78H	:= oModel:GetModel("N78HVI")
  
  //Aba Ágio / Deságio - OUTROS
  oModelN78O	:= oModel:GetModel("N78OUTROS")
  
  //Valida se estão habilitadas as manipulações de linhas na grid
  
  For nIt := 1 To Len(aSubModel)
  	aAdd(aGrids, {aSubModel[nIt], oModel:GetModel(aSubModel[nIt]):CanInsertLine()})
  	aAdd(aGrids, {aSubModel[nIt], oModel:GetModel(aSubModel[nIt]):CanUpdateLine()})
  	aAdd(aGrids, {aSubModel[nIt], oModel:GetModel(aSubModel[nIt]):CanDeleteLine()})
  Next nIt

  Pergunte("OGA290001",.T.)
  If !Empty(MV_PAR01)
   		cAliasNJR  := GetNextAlias()
   		cAliasN7E  := GetNextAlias()
   		cAliasN7H  := GetNextAlias()
   		cAliasN7J  := GetNextAlias()
   		cAliasN7F  := GetNextAlias()
   		cAliasN78H := GetNextAlias()
   		cAliasN78O := GetNextAlias()

		//Carrega os campos mestre NJR			
		BeginSql Alias cAliasNJR
			SELECT NJR.*
		    FROM %Table:NJR% NJR
		   WHERE NJR.%notDel%
		     AND NJR_FILIAL = %xFilial:NJR%
  		   AND NJR_CODCTR = %exp:MV_PAR01%
		EndSQL
		
		DbSelectArea(cAliasNJR)
		DbGoTop()
		oModelNJR:SetValue("NJR_TKPFIS", (cAliasNJR)->NJR_TKPFIS )
		oModelNJR:SetValue("NJR_TIPALG", (cAliasNJR)->NJR_TIPALG )
		oModelNJR:SetValue("NJR_TPSEVO", (cAliasNJR)->NJR_TPSEVO )
		oModelNJR:SetValue("NJR_TIPACE", (cAliasNJR)->NJR_TIPACE )
		oModelNJR:SetValue("NJR_QAPADR", (cAliasNJR)->NJR_QAPADR )
		
		oModelNJR:SetValue("NJR_TIPCAL", (cAliasNJR)->NJR_TIPCAL )
		oModelNJR:SetValue("NJR_TIPUM",  (cAliasNJR)->NJR_TIPUM )
		oModelNJR:SetValue("NJR_TIPFAT", (cAliasNJR)->NJR_TIPFAT )
		
		oModelNJR:SetValue("NJR_HVICAL", (cAliasNJR)->NJR_HVICAL )
		oModelNJR:SetValue("NJR_HVIUM",  (cAliasNJR)->NJR_HVIUM )
		oModelNJR:SetValue("NJR_HVIFAT", (cAliasNJR)->NJR_HVIFAT )
		oModelNJR:SetValue("NJR_HVIREG", (cAliasNJR)->NJR_HVIREG )
		oModelNJR:SetValue("NJR_HVITOL", (cAliasNJR)->NJR_HVITOL )
		
		oModelNJR:SetValue("NJR_OUTCAL", (cAliasNJR)->NJR_OUTCAL )
		oModelNJR:SetValue("NJR_OUTUM",  (cAliasNJR)->NJR_OUTUM ) 
		oModelNJR:SetValue("NJR_OUTFAT", (cAliasNJR)->NJR_OUTFAT )
  
		(cAliasNJR)->(DbCloseArea())          
		 
		// Apaga os dados do contrato atual(N7E)
		oModelN7E:SetNoInsertLine(.f.)
		oModelN7E:SetNoUpdateLine(.f.)
		oModelN7E:SetNoDeleteLine(.f.)
	
		For nIt := 1 To oModelN7E:Length() // Deleta todas as linhas da grid para a nova carga
			oModelN7E:GoLine(nIt)
			oModelN7E:DeleteLine()				
		Next nIt

		BeginSql Alias cAliasN7E
			SELECT N7E.*
		    FROM %Table:N7E% N7E
		   WHERE N7E.%notDel%
		     AND N7E_FILIAL = %xFilial:N7E%
  		   AND N7E_CODCTR = %exp:MV_PAR01%
		EndSQL
		
		DbSelectArea(cAliasN7E)
		DbGoTop()
		While (cAliasN7E)->(!Eof())
			oModelN7E:AddLine()
			oModelN7E:SetValue("N7E_TIPACE", (cAliasN7E)->N7E_TIPACE )
			oModelN7E:SetValue("N7E_PERCEN", (cAliasN7E)->N7E_PERCEN )
			(cAliasN7E)->(dbSkip())
		EndDo
		(cAliasN7E)->(DbCloseArea())
	
		// Apaga os dados do contrato atual(N7H)
		oModelN7H:SetNoInsertLine(.f.)
		oModelN7H:SetNoUpdateLine(.f.)
		oModelN7H:SetNoDeleteLine(.f.)
	
		For nIt := 1 To oModelN7H:Length() // Deleta todas as linhas da grid para a nova carga
			oModelN7H:GoLine(nIt)
			oModelN7H:DeleteLine()				
		Next nIt
		
		BeginSql Alias cAliasN7H
			SELECT N7H.*
		    FROM %Table:N7H% N7H
		   WHERE N7H.%notDel%
		     AND N7H_FILIAL = %xFilial:N7H%
  		   AND N7H_CODCTR = %exp:MV_PAR01%
		EndSQL
		
		DbSelectArea(cAliasN7H)
		DbGoTop()
		While (cAliasN7H)->(!Eof())
		  oModelN7H:AddLine()
			oModelN7H:SetValue("N7H_HVIDES", (cAliasN7H)->N7H_HVIDES )
			oModelN7H:SetValue("N7H_VLRINI", (cAliasN7H)->N7H_VLRINI )
			oModelN7H:SetValue("N7H_VLRFIM", (cAliasN7H)->N7H_VLRFIM )
			(cAliasN7H)->(dbSkip())
		EndDo
		(cAliasN7H)->(DbCloseArea())
	
		// Apaga os dados do contrato atual(N7J)
		oModelN7J:SetNoInsertLine(.f.)
		oModelN7J:SetNoUpdateLine(.f.)
		oModelN7J:SetNoDeleteLine(.f.)
	
		For nIt := 1 To oModelN7J:Length() // Deleta todas as linhas da grid para a nova carga
			oModelN7J:GoLine(nIt)
			oModelN7J:DeleteLine()				
		Next nIt
		
		BeginSql Alias cAliasN7J
			SELECT N7J.*
		    FROM %Table:N7J% N7J
		   WHERE N7J.%notDel%
		     AND N7J_FILIAL = %xFilial:N7J%
  		   AND N7J_CODCTR = %exp:MV_PAR01%
		EndSQL
		
		DbSelectArea(cAliasN7J) 
		DbGoTop() 
		While (cAliasN7J)->(!Eof()) 
			nLine := oModelN7J:AddLine() 
			oModelN7J:SetValue("N7J_TCRTIP", (cAliasN7J)->N7J_TCRTIP ) 
			oModelN7J:SetValue("N7J_FOLHA1", (cAliasN7J)->N7J_FOLHA1 ) 
			oModelN7J:SetValue("N7J_FOLHA2", (cAliasN7J)->N7J_FOLHA2 )
			oModelN7J:SetValue("N7J_FOLHA3", (cAliasN7J)->N7J_FOLHA3 )
			oModelN7J:SetValue("N7J_FOLHA4", (cAliasN7J)->N7J_FOLHA4 )
			oModelN7J:SetValue("N7J_FOLHA5", (cAliasN7J)->N7J_FOLHA5 )
			oModelN7J:SetValue("N7J_FOLHA6", (cAliasN7J)->N7J_FOLHA6 )
			oModelN7J:SetValue("N7J_FOLHA7", (cAliasN7J)->N7J_FOLHA7 )
			oModelN7J:SetValue("N7J_FOLHA8", (cAliasN7J)->N7J_FOLHA8 )
			
			cAliasN7G := GetNextAlias()
			
			BeginSql Alias cAliasN7G
				SELECT N7G.*
			    FROM %Table:N7G% N7G
			   WHERE N7G.%notDel%
			     AND N7G_FILIAL = %xFilial:N7G%
  			   AND N7G_CODCTR = %exp:MV_PAR01%
  			   AND N7G_SEQUEN = %exp:(cAliasN7J)->N7J_SEQUEN%
			EndSQL
			
			DbSelectArea(cAliasN7G) 
			
			If (cAliasN7G)->(!Eof()) 
				oModelN7G:LoadValue("N7G_COR1", (cAliasN7G)->N7G_COR1 )
				oModelN7G:LoadValue("N7G_COR2", (cAliasN7G)->N7G_COR2 )
				oModelN7G:LoadValue("N7G_COR3", (cAliasN7G)->N7G_COR3 )
				oModelN7G:LoadValue("N7G_COR4", (cAliasN7G)->N7G_COR4 )
				oModelN7G:LoadValue("N7G_COR5", (cAliasN7G)->N7G_COR5 )
			EndIf
			(cAliasN7G)->(DbCloseArea())

			(cAliasN7J)->(dbSkip())
		EndDo			
		(cAliasN7J)->(DbCloseArea())
		
		// Apaga os dados do contrato atual(N7F)
		oModelN7F:SetNoInsertLine(.f.)
		oModelN7F:SetNoUpdateLine(.f.)
		oModelN7F:SetNoDeleteLine(.f.)
	
		For nIt := 1 To oModelN7F:Length() // Deleta todas as linhas da grid para a nova carga
			oModelN7F:GoLine(nIt)
			oModelN7F:DeleteLine()				
		Next nIt
		
		BeginSql Alias cAliasN7F
			SELECT N7F.*
		    FROM %Table:N7F% N7F
		   WHERE N7F.%notDel%
		     AND N7F_FILIAL = %xFilial:N7F%
  		   AND N7F_CODCTR = %exp:MV_PAR01%
		EndSQL
		
		DbSelectArea(cAliasN7F)
		DbGoTop()
		While (cAliasN7F)->(!Eof())
			oModelN7F:AddLine()
			oModelN7F:SetValue("N7F_REGRA", (cAliasN7F)->N7F_REGRA )
			(cAliasN7F)->(dbSkip())
		EndDo
		(cAliasN7F)->(DbCloseArea())
	
		// Apaga os dados do contrato atual(N78H)
		oModelN78H:SetNoInsertLine(.f.)
		oModelN78H:SetNoUpdateLine(.f.)
		oModelN78H:SetNoDeleteLine(.f.)
	
		For nIt := 1 To oModelN78H:Length() // Deleta todas as linhas da grid para a nova carga
			oModelN78H:GoLine(nIt)
			oModelN78H:DeleteLine()				
		Next nIt
	
		BeginSql Alias cAliasN78H
			SELECT N78.*
		    FROM %Table:N78% N78
		   WHERE N78.%notDel%
		     AND N78_FILIAL = %xFilial:N78%
  		   AND N78_CODCTR = %exp:MV_PAR01%
  		   AND N78_APLICA = "2"
		EndSQL
		
		DbSelectArea(cAliasN78H)
		DbGoTop()
		While (cAliasN78H)->(!Eof())
			nNewLin	:= Soma1(oModelN78H:GetValue("N78_SEQUEN"))
			oModelN78H:AddLine()
			oModelN78H:LoadValue("N78_SEQUEN" , nNewLin)				
			oModelN78H:LoadValue("N78_HVIAGR" , (cAliasN78H)->N78_HVIAGR)
			oModelN78H:LoadValue("N78_HVIREG" , (cAliasN78H)->N78_HVIREG)
			oModelN78H:LoadValue("N78_HVIPON" , (cAliasN78H)->N78_HVIPON)
			oModelN78H:LoadValue("N78_HVITIP" , (cAliasN78H)->N78_HVITIP)
			(cAliasN78H)->(dbSkip())
		EndDo
		(cAliasN78H)->(DbCloseArea())
	
		// Apaga os dados do contrato atual(N78O)
		oModelN78O:SetNoInsertLine(.f.)
		oModelN78O:SetNoUpdateLine(.f.)
		oModelN78O:SetNoDeleteLine(.f.)
		
		For nIt := 1 To oModelN78O:Length() // Deleta todas as linhas da grid para a nova carga
			oModelN78O:GoLine(nIt)
			oModelN78O:DeleteLine()				
		Next nIt
	
		BeginSql Alias cAliasN78O
			SELECT N78.*
		    FROM %Table:N78% N78
		   WHERE N78.%notDel%
		     AND N78_FILIAL = %xFilial:N78%
  		   AND N78_CODCTR = %exp:MV_PAR01%
  		   AND N78_APLICA = "3"
		EndSQL
		
		DbSelectArea(cAliasN78O)
		DbGoTop()
		While (cAliasN78O)->(!Eof())
			nNewLin	:= Soma1(oModelN78O:GetValue("N78_SEQUEN"))
			oModelN78O:AddLine()
			oModelN78O:LoadValue("N78_SEQUEN" , nNewLin)				
			oModelN78O:SetValue("N78_OUTCOD", (cAliasN78O)->N78_OUTCOD)
			oModelN78O:LoadValue("N78_OUTPER", (cAliasN78O)->N78_OUTPER)
			oModelN78O:LoadValue("N78_OUTPON", (cAliasN78O)->N78_OUTPON)
		(cAliasN78O)->(dbSkip())
		EndDo
		(cAliasN78O)->(DbCloseArea())
  EndIf
	
	For nIt := 1 To Len(aGrids)
		//Só adiciona quando for .t., pois neste momento estão todos como .f.
		//Preccisa inverter, poir quando foi gravar o valor original, é gravado de forma inversa.
		
		If aGrids[nIt][2]
			oModel:GetModel(aGrids[nIt][1]):SetNoInsertLine( .f. )
		Else
		  oModel:GetModel(aGrids[nIt][1]):SetNoInsertLine( .t. ) 
		End If			
		
		nIt := nIt+1
		If aGrids[nIt][2]
			oModel:GetModel(aGrids[nIt][1]):SetNoUpdateLine( .f. )
		Else
			oModel:GetModel(aGrids[nIt][1]):SetNoUpdateLine( .t. )
		End If			

		nIt := nIt+1
		If aGrids[nIt][2]
			oModel:GetModel(aGrids[nIt][1]):SetNoDeleteLine( .f. )
		Else
			oModel:GetModel(aGrids[nIt][1]):SetNoDeleteLine( .t. )
		End If			
  Next nIt
		
	If !__lAutomato
        oview:refresh()
        __oViewN7E:Refresh()
        __oViewN7H:Refresh()
    EndIf

Return .F.

/** {Protheus.doc} fGrvComPrc
Rotina para gravar a Composicao de Preco apartir do Array aGrvNKA
@param:     AcompPrc ( Array com Itens da Composição de Preço ) , nOperation se é Insercao ou alteração
@author:    Emerson Coelho
@since:     02/10/2014
@Uso:       SIGAAGR - Originação de Grãos
*/
Static Function fGrvComPrc( aCompPRC , nOperation, oModel)
	Local cNjrCodCtr    := oModel:GetValue( "NJRUNICO", "NJR_CODCTR" )
	Local oModelNN8     := oModel:GetModel("NN8UNICO")
	Local cTipoFx       :=''
	Local cItemFx    :=''
	Local dDtFixa   := dDatabase
	Local nQtfixar      := oModel:GetValue( "NJRUNICO", "NJR_QTDINI" )
	Local nNjrMoeda := oModel:GetValue( "NJRUNICO", "NJR_MOEDA" )
	Local cAliasQry     := ""
	Local lMudouFix     := IF(! NJR->NJR_TIPFIX = oModel:GetValue( "NJRUNICO","NJR_TIPFIX" ),.T.,.F. ) //--<< Indica que mudou o tipo de Fixação no Contrato >>--
	Local lTemNN8       := .f. //---<< Indica que já existe composição de precos gravada para o Contrato >>--
	Local lTemComPrc    := IF(Len ( aCompPRC ) == 0 ,.f.,.t.) //--<< Indica que foi na Rotina de composição de preco e tme Algo para Gravar >>-
	Local nPosTotal     := 0
	Local nNN8_VLRUNI   := 0

	If oModel:IsCopy() .AND. !__lnewNeg 
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
		cItemFx         := NN8->NN8_ITEMFX
		nNN8_VLRUNI := NN8->NN8_VLRUNI
		lTemNN8     := .t.
	EndIF

	If cPaisLoc != "PAR" .AND. cPaisLoc != "ARG"
		If !Empty(oModel:GetValue( "NJRUNICO", "NJR_DATREF" )) 
			dDtfixa := oModel:GetValue( "NJRUNICO", "NJR_DATREF" ) 
		EndIF
	EndIf

	IF lTemNN8 == .f. .and. lTemComPrc == .t. //--<< Indica que tenho que Gravar NKA Composição de Preço , Encontro o proximo nr. de Fixação >>--
		cAliasQry := GetNextAlias()

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


	IF (lTemComPrc == .t. ) .or. (lTemNN8 == .t. .and. lmudoufix == .t. ) // Se tiver Comp.Preço, ou Entao Se Tem Fixação e o tipo do Contrato foi Mudado
		If lTemComPrc       //Indica q tem Composição de preço então pego os Vrs.Ini da Composição de Preço
			nPosTotal       := aSCAN(aCompPRC, {|aCompPRC| aCompPRC[3] == "TOTAL" }) // Encontro o Valor unitario em 1a Um e 2aUM na composição de preços
			nNN8_VLRUNI     := aCompPrc[ nPosTotal , 11]
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
			cUmPrc  := oModel:GetValue( "NJRUNICO", "NJR_UMPRC" ) 
			cTes    := oModel:GetValue( "NJRUNICO", "NJR_TESEST" )
			cTpCtr  := oModel:GetValue( "NJRUNICO", "NJR_TIPO" )
			//nQtdFix = nQtfixar
			//nVlrUNI = NN8_VLRUNI

			aVrSemImps := {}        // Conterá Campo e seu respectivo Vr. Campo  aVrSemImps{{'NN8_VALUNI', nValor}}
			aVrSemImps :=   OG430VrSFx(;
			/*Codigo da entidade */ cCodEnt,;
			/*Loja   da entidade */ cLjaEnt,;
			/*Codigo do produto  */ cCodPro,;
			/*Un.Medida Produto  */ cUM1Pro,;
			/*Un.Medida Preço    */ cUmPrc,;            
			/*TES                */ cTes,;
			/*Qtd a Fiscar       */ nQtfixar,;
			/*Valor un. na Um Prç*/ nNN8_VlrUni,;
			/*Moeda              */ nNJrMoeda,;
			/*Tp Ctrato (2 venda)*/ cTpCtr,;
			/*Data da fixacao)   */ dDtfixa,;
			/*Txa de conversão   */ NJR_TXMOED)

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

			OGA420NKAW( aCompPRC, cItemFx )
		
	EndIF

	aGrvNKA := {} //--<< Limpa Array de Composição de Precos >>--
	dDEntrIni   := cTod('//')
	dDEntrFim   := cTod('//')
Return

/** {Protheus.doc} lDelTitFin
Descrição: Exclui Titulo Financeiro

@param:     Nil
@author:    Vinicius Becher Pagung
@since:     15/04/2015
@Uso:       OGA290 
*/
Static Function lDelTitFin(cCtrDoc, cCodEnt, cLojEnt)
	Local   lContinua   := .t.
	Local   aLinVncAux	:= {}
	local   aLinVncAux2 := {}
	Local   aVncCRec	:= {}
	Local   aVncCPag	:= {}
	Local cFilAntTmp 	:= cFilAnt
	Private lMsErroAuto := .f.

	NJ0->( dbSetOrder( 1 ) )
	NJ0->( dbSeek( xFilial( "NJ0" ) + cCodEnt + cLojEnt ) )

	/** Gera titulos provisórios no financeiro */
	cPrefixo    := "CTR"
	cNumero     := PadR( cCtrDoc, TamSX3( "E2_NUM" )[1] )
	cTipTit     := "PR "

	NN7->( dbSetOrder( 1 ) )
	NN7->( dbSeek( xFilial( "NN7" ) + cCtrDoc ) )
	While .Not. NN7->( Eof() ) .And. NN7->( NN7_FILIAL ) = xFilial( "NN7" ) .And. NN7->( NN7_CODCTR ) = cCtrDoc
				
		If  NN7->(ColumnPos("NN7_CODCOM")) == 0 .or. (NN7->(ColumnPos("NN7_CODCOM")) > 0 .and. ( Empty(NN7->NN7_CODCOM) .OR. ALLTRIM(NN7->NN7_CODCOM) == 'TOTAL' ))
			NJ0->( dbSetOrder( 1 ) )
			NJ0->( dbSeek( xFilial( "NJ0" ) + cCodEnt + cLojEnt ) )

			cE1_PARC := PADR(Alltrim(NN7->NN7_PARCEL),TAMSX3('E1_PARCELA')[1])      
			aFina040 := {}
	
			dbSelectArea( "SE1" )
			dbSetOrder( 2 )
			If dbSeek( xFilial( "SE1" ) + NJ0->( NJ0_CODCLI ) + NJ0->( NJ0_LOJCLI ) + cPrefixo + cNumero + cE1_PARC + cTipTit)
	
				aAdd( aFina040, { "E1_PREFIXO" , cPrefixo                   , Nil } )
				aAdd( aFina040, { "E1_NUM"     , cNumero                    , Nil } )
				aAdd( aFina040, { "E1_PARCELA" , cE1_PARC                   , Nil } )
				aAdd( aFina040, { "E1_TIPO"    , cTipTit                    , Nil } )
				aAdd( aFina040, { "E1_CLIENTE" , NJ0->( NJ0_CODCLI ), Nil})
				aAdd( aFina040, { "E1_LOJA"    , NJ0->( NJ0_LOJCLI ), Nil})
	
				//Removento o vinculo da SE1 
				aLinVncAux := {}
				aadd( aLinVncAux, { "N8L_FILIAL"    	, FwXfilial('N8L') 				} )
				aadd( aLinVncAux, { "N8L_PREFIX"    	, cPrefixo						} )
				aadd( aLinVncAux, { "N8L_NUM"    		, cNumero 						} )
				aadd( aLinVncAux, { "N8L_PARCEL"    	, cE1_PARC						} )
				aadd( aLinVncAux, { "N8L_TIPO"    		, cTipTit						} )
				
				aAdd(aVncCRec, aLinvncAux)
				
				If !Empty(NN7->( NN7_FILORG ))
					cFilAnt := NN7->( NN7_FILORG )
				EndIf
				
				MsExecAuto( { |x,y| Fina040( x, y ) }, aFina040, 5 )
				
				cFilAnt := cFilAntTmp
	
				If lMsErroAuto .AND. !__lAutomato
					MostraErro()
					lContinua := .f.
					Exit
				EndIf
			endif  
		
		ElseIf NN7->(ColumnPos("NN7_CODCOM")) > 0 .and. !Empty(NN7->NN7_CODCOM) .AND. ALLTRIM(NN7->NN7_CODCOM) != 'TOTAL'
			NJ0->( dbSetOrder( 1 ) )
			NJ0->( dbSeek( xFilial( "NJ0" ) + NN7->NN7_CODFAV + NN7->NN7_LOJFAV ) ) //Usa favorecido da NN7 quando comercialização classico gera previsao financeiro para componentes
						
			cE2Parcel := PadR(Alltrim(NN7->NN7_PARCEL), TamSX3( "E2_PARCELA" )[1] )
	
			/*Verifica a existencia de titulo**/
			dbSelectArea( "SE2" )
			dbSetOrder( 1 )
			//If dbSeek( xFilial( "SE2" ) + cPrefixo + cNumero + NN7->( NN7_PARCEL ) + cTipTit +  NJ0->( NJ0_CODFOR ) + NJ0->( NJ0_LOJFOR )  )
			If dbSeek( xFilial( "SE2" ) + cPrefixo + cNumero + cE2Parcel + cTipTit +  NJ0->( NJ0_CODFOR ) + NJ0->( NJ0_LOJFOR )  )
				aFina050 := {}
	
				aAdd( aFina050, { "E2_FILAIL" ,  SE2->E2_FILIAL             , Nil } )
				aAdd( aFina050, { "E2_PREFIXO" , SE2->E2_PREFIXO            , Nil } )
				aAdd( aFina050, { "E2_NUM"     , SE2->E2_NUM                , Nil } )
				aAdd( aFina050, { "E2_PARCELA" , SE2->E2_PARCELA            , Nil } )
				aAdd( aFina050, { "E2_TIPO"    , SE2->E2_TIPO               , Nil } )
				aAdd( aFina050, { "E2_FORNECE" , SE2->E2_FORNECE            , Nil } )
				aAdd( aFina050, { "E2_LOJA"    , SE2->E2_LOJA               , Nil } )
				
				//Removento o vinculo da SE2 
				aLinvncAux2 := {}
				aadd( aLinvncAux2, { "N8M_FILIAL"    	, FwXfilial('N8M') } )
				aadd( aLinvncAux2, { "N8M_PREFIX"    	, PadR(Alltrim(cPrefixo), TamSX3( "N8M_PREFIX" )[1] )			} )
				aadd( aLinvncAux2, { "N8M_NUM"    		, PadR(Alltrim(cNumero), TamSX3( "N8M_NUM" )[1] ) 				} )
				aadd( aLinvncAux2, { "N8M_PARCEL"    	, PadR(Alltrim(cE2Parcel), TamSX3( "N8M_PARCEL" )[1] )			} )
				aadd( aLinvncAux2, { "N8M_TIPO"    		, PadR(Alltrim(cTipTit), TamSX3( "N8M_TIPO" )[1] )				} )
				aadd( aLinvncAux2, { "N8M_FORNEC"    	, PadR(Alltrim(NJ0->( NJ0_CODFOR )), TamSX3( "N8M_FORNEC" )[1] )} )
				aadd( aLinvncAux2, { "N8M_LOJA"    		, PadR(Alltrim(NJ0->( NJ0_LOJFOR )), TamSX3( "N8M_LOJA" )[1] )	} )
				aAdd(aVncCPag, aLinvncAux2)
	
				If !Empty(NN7->( NN7_FILORG ))
					cFilAnt := NN7->( NN7_FILORG )
				EndIf
	
				MSExecAuto({|x,y,z| fina050(x,y,z)},aFina050,,5)
				
				cFilAnt := cFilAntTmp
				
				If lMsErroAuto
					MostraErro()
					lContinua := .f.
					Exit
				EndIf
	
			Endif		
		EndIf
		NN7->( dbSkip() )
	EndDo
	
	If lContinua .and.  len( aVncCRec ) > 0
	   	lContinua:= fAgrVncRec (aVncCRec, 5 )  //Excluir
	EndIf
	If lContinua .and.  len( aVncCPag ) > 0
		lContinua := fAgrVncPag (aVncCPag, 5 )  //Excluir
	EndIf

Return(.t.)

/** {Protheus.doc} PreValNNY(oModelGrid, nLinha, cAcao, cCampo,xVrNovo,xVrNovo)
Rotina de Pre validação do modelo NNYUNICO
@param oModelGrid Modelo
@param nLinha Linha corrente
@param cAcao  Ação ("DELETE", "SETVALUE", e etc)
@since 12/09/2013
@version 1.1
*/
Static Function PreValNNY(oModelNNY, nLinha, cAcao, cCampo,xVrNovo,xVrAnt)
	Local lRet		:= .T.
	Local oModel		:= oModelNNY:GetModel()
	Local oModelNJR  	:= oModel:GetModel("NJRUNICO")
	Local oModelN9A     := oModel:GetModel("N9AUNICO")

	If cAcao == "CANSETVALUE" .AND. cCampo == "NNY_QTDINT" .AND. oModelNJR:GetValue("NJR_STATUS") $ "A|I"
		Return (.F.) //não deve alterar a quantidade depois de confirmado
	EndIf 

    If cAcao == "SETVALUE" .And. cCampo == "NNY_DATINI" 
		AGRXDTNNY(oModelNNY, xVrNovo) //se o data fim estiver vazio, preenche com o inicial.
		IF __lnewNeg
			AGRXDTN9A(oModelN9A, xVrNovo, cCampo)
		EndIF
	ElseIf cAcao == "SETVALUE" .And. cCampo == "NNY_DATFIM" .and. __lnewNeg
		AGRXDTN9A(oModelN9A, xVrNovo, cCampo)
	ElseIf cAcao == 'SETVALUE' .And. cCampo == 'NNY_FILORG'	.and. __lnewNeg
		AGRXFILORG(oModelNNY, nLinha, cAcao, cCampo,xVrNovo,xVrAnt)
	EndIf
	//atualizo o campo NJR_QTDINI e valido as quantidades.
    lRet := AGRXATUQTD(oModelNNY, cAcao, xVrNovo, xVrAnt, nLinha, cCampo )	
	
Return (lRet)

/** {Protheus.doc} PreValNN7(oModelGrid, nLinha, cAcao, cCampo,xVrNovo,xVrNovo)
Rotina de Pre validação do modelo NN7UNICO
@param oModelGrid Modelo
@param nLinha Linha corrente
@param cAcao  Ação ("DELETE", "SETVALUE", e etc)
@since 12/09/2013
@version 1.1
*/
Static Function PreValNN7(oModelNN7, nLinha, cAcao, cCampo,xVrNovo,xVrAnt)
	Local lRet		:= .T.

    If cAcao == "SETVALUE" .And. cCampo == "NN7_PARCEL" .And. Empty(xVrNovo) 		   
		lRetorno := .f.
	EndIf

Return (lRet)

/** {Protheus.doc} OGA290VNC
Descrição:  Valida o valor se não está cancelado ou finalizado.
@param:     Nil
@author:    Vinicius Becher Pagung
@since:     29/01/2016
@Uso:       OGA290 
*/
Function OGA290VNC()
	Local lRetorno  := .T.

	If NJR->NJR_STATUS == "E"
		Help(,, STR0031,,STR0098, 1, 0 ) //#Ajuda #"Item não pode ser excluido pois já possui Quantidade empenhada."
		lRetorno := .f.
	ElseIf NJR->NJR_STATUS == "F"
		Help(,, STR0031,,STR0097 , 1, 0 ) //#Ajuda #"Item não pode ser excluido pois já possui Quantidade empenhada."
		lRetorno := .f.
	Else
		OGA285(NJR->NJR_TIPO,NJR->NJR_CODCTR)
	endif
Return ( lRetorno )

/** {Protheus.doc} ValCancel
Descrição:  Validação para verificar se existe vinculo e barrar cancelamento caso possuir.
@param:     Nil
@author:    Vinicius Becher Pagung
@since:     17/03/2016
@Uso:       OGA290 
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
	AND NKB_CTRVND = %Exp:cCodCtr%         
	GROUP BY NKB_CTRVND                
	EndSQL

	(cAliasNKB)->( dbGoTop() )
	If !(cAliasNKB)->( Eof() )
		lRet := .t.
	Endif
	(cAliasNKB)->( dbCloseArea() ) 

Return (lRet)

/** {Protheus.doc} OGA290VAGD
Descrição:  Validação Ágio Deságio
@param:     oModel
@author:    Agroindústria
@since:     03/05/2017
@Uso:       OGA290 
*/
Static Function OGA290VAGD(oModel) 
	Local cForCalTip := oModel:GetValue( "NJRUNICO", "NJR_TIPCAL") 		
	Local nUMTip     := oModel:GetValue( "NJRUNICO", "NJR_TIPUM ") //um agio desagio
	Local nFatTip    := oModel:GetValue( "NJRUNICO", "NJR_TIPFAT") //fator
	Local cForCalOut := oModel:GetValue( "NJRUNICO", "NJR_OUTCAL") 	
	Local nUMOut     := oModel:GetValue( "NJRUNICO", "NJR_OUTUM ") //um agio desagio
	Local nFatOut    := oModel:GetValue( "NJRUNICO", "NJR_OUTFAT") //fator
	Local cForCalHvi := oModel:GetValue( "NJRUNICO", "NJR_HVICAL") 	          /// ALTERADO
	Local nUMHvi     := oModel:GetValue( "NJRUNICO", "NJR_HVIUM ") //um agio desagio
	Local nFatHvi    := oModel:GetValue( "NJRUNICO", "NJR_HVIFAT") //fator
    Local oModelN7E  := oModel:GetModel( "N7EUNICO" )

	//valida o TIPO - Não bloquear alterações na tela
	if cForCalTip > "1" //nenhum
		//valida cabeçalho
		If empty(nUMTip)
			Help(" ",1,"OGA290AGD1")//"Quando informado a forma de cálculo na aba Tipo, o campo de Unidade de Medida se torna Obrigatório."
			OGA290SFLD(FLDALG, FLDALGTTIPO)
			Return .F.
		elseif cForCalTip = "4" /*pontuação*/ .and. empty(nFatTip)
			Help(" ",1,"OGA290AGD3")// # Quando informada a forma de cálculo (Pontuação) na aba Tipo, o campo Fator se torna Obrigatório.
			OGA290SFLD(FLDALG, FLDALGTTIPO)
			Return .F.
		EndIf
	endif  	

	//valida o Outros - Não bloquear alterações na tela
	if cForCalOut > "1" //nenhum
		//valida cabeçalho
		if empty(nUMOut)
			Help(" ",1,"OGA290AGD4")//"Quando informado a forma de cálculo na aba Outros, o campo de Unidade de Medida se torna Obrigatório."
			OGA290SFLD(FLDALG, FLDALGOUTR)
			Return .F.
		elseif cForCalOut = "4" /*pontuação*/ .and. empty(nFatOut)
			Help(" ",1,"OGA290AGD6")// # Quando informado a forma de cálculo Pontuação na aba Outros, o campo Fator se torna Obrigatório.
			OGA290SFLD(FLDALG, FLDALGOUTR)
			Return .F.
		EndIf
	endif 

	//valida o HVI - Não bloquear alterações na tela   // ALTERAR AS MSGES
	if cForCalHvi > "1" //nenhum  adiconada validação

		//valida cabeçalho
		if empty(nUMHvi)
			Help(" ",1,"OGA290AGDA7")//"Quando informado a forma de cálculo na aba HVI, o campo de Unidade de Medida se torna Obrigatório."
			OGA290SFLD(FLDALG, FLDALGHVI)
			Return .F.
		elseif cForCalHvi = "4" /*pontuação*/ .and. empty(nFatHvi)
			Help(" ",1,"OGA290AGD8")// # Quando informado a forma de cálculo Pontuação na aba HVI, o campo Fator se torna Obrigatório.
			OGA290SFLD(FLDALG, FLDALGHVI)
			Return .F.
		EndIf
	endif

	//força a validação no UPDATE
	if oModel:GetModel( "NJRUNICO" ):IsFieldUpdated("NJR_TIPCAL") 			
		if !ValPosN7F( oModel:GetModel( "N7FUNICO" ) )
			Return .F.
		endif
	endif

	if oModel:GetModel( "NJRUNICO" ):IsFieldUpdated("NJR_TIPCAL")
		if !ValPosN7J( oModel:GetModel( "N7JUNICO" ) )
			Return .F.
		endif
		if !ValPosN7G( oModel:GetModel( "N7GUNICO" ) )
			Return .F.
		endif
	endif	

	if oModel:GetModel( "NJRUNICO" ):IsFieldUpdated("NJR_OUTCAL") 	
		if !ValPosN78O( oModel:GetModel( "N78OUTROS" ) )
			Return .F.
		endif
	endif

	If oModel:GetModel( "NJRUNICO" ):IsFieldUpdated("NJR_HVICAL") .or. (valType(oModelN7E) == "O" .and. oModelN7E:IsModified())	
		If !ValPosN78H( oModel:GetModel( "N78HVI" ) )
			Return .F.
		Endif
	EndIf

Return(.t.)

/*{Protheus.doc} OGA290VACT
(Pós Validação de ativação da view, para desabilitar a aba algodão)
@type function
@author roney.maia
@since 27/04/2017
@version 1.0
@param oView, objeto, (View Ativa)
@return ${lRet}, ${.T. - Validado, .F. - Não Validado}
*/
Static Function OGA290VACT(oView)

	Local lRet 		:= .T.
	Local oModel    := oView:getModel()
	/* Atribui a view pai NJR a variável static __oViewNJR para utilização posterior sem a necessidade do método FWViewActive,
	pois a rotina foi montada com 3 views, sendo a view principal(pai) a NJR e suas views filhas sendo as grids construídas
	na Aba Principal que está localizada na aba Algodão. __oViewN7E (N7E) e __oViewN7H (N7H)  _*/ 
	__oViewNJR := oView 

	// Desabilita a aba algodão quando a operação for igual a inserção ou a validação do campo codigo do produto for falsa. 		
	If __lnewComerc	
		// Altera a largura das colunas para melhorar a usabilidade
		oView:GetViewObj("VIEW_TIPOT")[3]:oBrowse:oBrowse:SetColumnSize(1, 160)
		cCodPro := oModel:GetModel('NJRUNICO'):GetValue('NJR_CODPRO')
		If !Iif(.NOT.Empty(cCodPro), AGRTPALGOD(cCodPro),.F.)
			oView:HideFolder('CTRFOLDER', FLDALGODAO, 2) // Esconde a aba Algodão
			oView:SelectFolder('CTRFOLDER', FLDPRINCIP, 2) // Retorna para a aba Principal	
		Endif
	EndIf

Return lRet

/*{Protheus.doc} OGA290CPO
//Função que realiza as validações/consistências dos campos da tela
@author janaina.duarte
@since 28/04/2017
@version 1.0
@type function
*/
Function OGA290CPO()  
	Local aArea 		:= GetArea()
	Local lRet			:= .T.
	Local nX    		:= 0
	Local oModel    	:= Nil
	Local oModelN7E 	:= Nil
	Local oModelNJRE	:= Nil
	Local oModelN7J	:= Nil
	Local oModelN7G	:= Nil
	Local oModelN7H	:= Nil
	Local oModelN7F	:= Nil
	Local oStruDX7	:= Nil
	Local nIt			:= 0
	Local aTipsAce	:= {}
	Local nTipLine	:= 1
	Local nTipLineJ	:= 1
	Local aTipsPd	:= {}
	Local nTip		:= 1
	Local aFolhaCor := {}

	If ValType(__oViewNJR) != "U" // Verifica se a View NJR não é Nula
		oModel := __oViewNJR:GetModel() // Obtém o Model
	Else
		oModel := FWModelActive() // Obtém o Model Ativo
	EndIf

	oModelN7E 	:= oModel:GetModel("N7EUNICO") // Obtém o submodelo da N7E
	oModelNJRE	:= oModel:GetModel("NJRUNICO")
	oModelN7J	:= oModel:GetModel("N7JUNICO")
	oModelN7G	:= oModel:GetModel("N7GUNICO")
	oModelN78H	:= oModel:GetModel("N78HVI")
	oModelN7H	:= oModel:GetModel("N7HUNICO")
	oModelN7F	:= oModel:GetModel("N7FUNICO")
	oModelN78O	:= oModel:GetModel("N78OUTROS")
	oModelNNF	:= oModel:GetModel("NNFUNICO")

	If FunName() == __cRotName .OR. __lAutomato // Se a rotina que invocou as validações for a OGA290 então
		DO CASE
			CASE ( "NJR_TIPALG" $ Readvar() )		
				// Valida se o registro informado existe na base de dados	
				lRet := AllTrim(oModelNJRE:GetValue("NJR_TIPALG")) == '-' .OR. ExistCPO("DXA", oModelNJRE:GetValue("NJR_TIPALG"), 1)
				If lRet
					//Se tiver Tipos Aceitáveis já cadastrados, consistir pois o Tipo Padrão não pode ser igual aos Tipos Aceitáveis.
					For nX := 1 to oModelN7E:Length()	
						If .NOT. oModelN7E:IsDeleted(nX) .AND. oModelNJRE:GetValue("NJR_TIPALG") == oModelN7E:GetValue( "N7E_TIPACE" , nX)
							Help(" ",1,"OGA290CPO3") //"Não podem existir Tipos Aceitáveis de Algodão iguais ao Tipo Padrão."
							lRet := .F.
							Exit
						EndIf
					Next nX
				EndIf
			CASE ( "N7J_TCRTIP" $ Readvar() )		

				// Se a linha da grid N7J - Desc Tipo e Folha for diferente da grid N7G - Desc Cor
				If oModelN7J:GetLine() != oModelN7G:GetLine()
					oModelN7G:GoLine(oModelN7J:GetLine()) // Posiciona a linha da grid Desc Cor
				EndIf
	
				//valida os usos das folhas e cores	- reset							
				aTipsAce := Separa(&(Readvar()), "/")
	
				For nX := 1 to Len(aTipsAce)	
					aAdd(aFolhaCor, {substr(alltrim(aTipsAce[nX]), 4,1), substr(alltrim(aTipsAce[nX]), 2,1)})
				Next nX
	
				For nX := 1 to 8 //valida as folhas	
					if aScan(aFolhaCor, {|x| alltrim(x[1])  == alltrim(str(nX)) }  ) == 0 //reset cor
						if !empty(oModelN7J:GetValue("N7J_FOLHA"+alltrim(str(nX))))
							oModelN7J:ClearField("N7J_FOLHA"+alltrim(str(nX)))
						endif
					endif
				next NX 
	
				For nX := 1 to 5 //valida as cores	
					if aScan(aFolhaCor, {|x| alltrim(x[2])  == alltrim(str(nX)) }  ) == 0 //reset cor
						if !empty(oModelN7G:GetValue("N7G_COR"+alltrim(str(nX))))
							oModelN7G:ClearField("N7G_COR"+alltrim(str(nX)))
						endif
					endif
				next NX 
	
				oModelN7G:SetValue("N7G_TCRTIP", &(Readvar())) // Seta o tipo na grid Desc Cor na linha correspondente
	
				If !__lAutomato
					__oViewNJR:Refresh("VIEW_TIPOM") // Aplica o Refresh - como correção do problema de visualização da grid de cor
				EndIf
	
			CASE ( "NJR_TOLENT" $ Readvar() )
				If lRet := Positivo()
					If oModelNJRE:GetValue("NJR_TOLENT") > 100
						Help(" ",1,"OGA290CPO5")//"O Valor percentual informado é superior a 100%"
						lRet := .F.
					EndIf
				EndIf
			CASE "NJR_QAPADR" $ ReadVar()
				if (!Empty(oModelNJRE:GetValue('NJR_QAPADR')))
					if ExistCPO( 'N80',oModelNJRE:GetValue("NJR_QAPADR") , 1 ) 
						OGA290ITE(ALLTrim(oModelNJRE:GetValue("NJR_QAPADR")), oModel )
					Else 
						Help(" ",1,"OGA290REG") //Valor invalido! Informe um código Válido !
						lRet := .F.
					endIf
				endIf	
			CASE ( "NJR_HVIREG" $ Readvar() )
				If lRet := Pertence('123')
				
					If  oModel:GetModel("NJRUNICO"):GetValue("NJR_HVIREG") != '3' // Validação para limpeza de campo em Tolerancia
						oModelNJRE:ClearField("NJR_HVITOL")
					EndIf
				EndIf 	
			CASE ( "NJR_HVICAL" $ Readvar() )
				// Realiza a troca de labels dos campos Pontuação e P.Grupo conforme a Form de Cálculo					    
				If lRet := Pertence("1|2|3|4|") 
					If  oModelNJRE:GetValue("NJR_HVICAL") ="1"
						oModelNJRE:LoadValue("NJR_HVIREG", '1')
						oModelNJRE:ClearField("NJR_HVITOL")
						oModelNJRE:ClearField("NJR_HVIUM")
						oModelNJRE:ClearField("NJR_HVIFAT")
					ElseIf oModelNJRE:GetValue("NJR_HVICAL")!= "4"
						If !Empty("NJR_HVICAL")
							oModelNJRE:ClearField("NJR_HVIFAT")
						EndIf	
					EndIf
				EndIf 		
			CASE ( "NJR_HVITOL" $ Readvar() )
				If lRet := Positivo()
					If oModelNJRE:GetValue("NJR_HVITOL") > 100
						Help(" ",1,"OGA290CPO5")//"O Valor percentual informado é superior a 100%"
						lRet := .F.
					EndIf
				EndIf
			CASE 'NJR_TIPCAL' $ Readvar()
				If lRet := Pertence("1234") // Verifica o valid do campo
					If M->NJR_TIPCAL = "1" // Se a Formula de calculo for nenhum, limpa todos os fields					
						oModel:GetModel("NJRUNICO"):SetValue("NJR_TIPUM","")
						oModel:GetModel("NJRUNICO"):SetValue("NJR_TIPFAT",0)
					ElseIf M->NJR_TIPCAL != "4"
						If !Empty(M->NJR_TIPFAT)
							oModel:GetModel("NJRUNICO"):SetValue("NJR_TIPFAT",0)
						EndIf	
					EndIf
				EndIf		
			CASE 'NJR_OUTCAL' $ Readvar()
				If lRet := Pertence("1234")
					If M->NJR_OUTCAL = "1"
						oModel:GetModel("NJRUNICO"):SetValue("NJR_OUTUM","")
						oModel:GetModel("NJRUNICO"):SetValue("NJR_OUTFAT",0)			
					ElseIf M->NJR_OUTCAL != "4"
						If !Empty(M->NJR_OUTFAT)
							oModel:GetModel("NJRUNICO"):SetValue("NJR_OUTFAT",0)
						EndIf	
					EndIf
				EndIf         
			CASE ( "N7E_PERCEN" $ Readvar() )
				If Empty(AllTrim(oModel:GetModel("N7EUNICO"):GetValue("N7E_TIPACE")))	
					Help(" ",1,"OGA290CPO4")//"Para preencher o Valor Percentual o Tipo Aceitável não pode estar vazio."
					lRet := .F.
				EndIf
				If lRet
					lRet := Positivo() // Campo percentual deve ser positivo
				EndIf
				If lRet
					If oModel:GetModel("N7EUNICO"):GetValue("N7E_PERCEN") > 100 
						Help(" ",1,"OGA290CPO5")//"O Valor percentual informado é superior a 100%"
						lRet := .F.
					EndIf
				EndIf
			CASE ( "N78_HVITIP" $ Readvar() )

				lRet := OGA290TPDS(&(Readvar()), oModelN7E) //valida os tipos opcionais

			CASE ( "N7H_HVIDES" $ Readvar() ) 
				If __lCampVld // Se o o valor inserido na pre edição do campo for igual ao valor contido
					__lCampVld := .F.
					RestArea(aArea)
					Return .T.
				EndIf	
													
				oStruDX7 := FwFormStruct(1, "DX7", {|cCampo| ALLTRIM(cCampo) $ __cCampDX7}) // Obtem a estrutura da DX7
				For nIt := 1 To Len(oStruDX7:AFIELDS)	// Percore os campos da DX7
					// Compara os Titulos dos campos a fim de encontrar o campo informado na N7H_HVIDES	 
					If UPPER(AllTrim(oStruDX7:AFIELDS[nIt][1])) == UPPER(AllTrim(oModel:GetModel("N7HUNICO"):GetValue("N7H_HVIDES")))
						// Se os valor encontrado é diferente do que contem no campo, preenche o campo
						If AllTrim(oStruDX7:AFIELDS[nIt][3]) != AllTrim(oModel:GetModel("N7HUNICO"):GetValue("N7H_CAMPO"))  
							oModelN7H:SetValue('N7H_CAMPO', oStruDX7:AFIELDS[nIt][3])
							lRet := .T.
							Exit
						Else // Senão o valor ja está contido no campo
							lRet := .T.
							Exit
						EndIf
					Else // Caso não encontrar o campo, o valor informado é invalido
						Help("", 1, "REGNOIS")
						lRet := .F.
					EndIf
				Next nIt
					
				If Empty(oModel:GetModel("N7HUNICO"):GetValue("N7H_HVIDES")) // Se o campo informado estiver vazio, limpa o campo hvi
					oModelN7H:ClearField('N7H_CAMPO')
					lRet := .T.
				EndIf
				If lRet
					oModelN7H:ClearField('N7H_VLRINI')
					oModelN7H:ClearField('N7H_VLRFIM')
				EndIf
			CASE ( "N78_HVIREG" $ Readvar() )			//CODIFICANDO								
				If ValType(__cCampo) != "U"	// 
					oModelN78H:SetValue('N78_HVICMP',__cCampo )
				EndIf
				
				If Empty(oModel:GetModel("N78HVI"):GetValue("N78_HVIREG")) // Se o campo informado estiver vazio, limpa o campo hvi
					oModelN78H:ClearField('N78_HVICMP')
					oModelN78H:ClearField('N78_HVIPON')
					If ValType(__oViewNJR) != "U"	// Atualiza a View
						__oViewNJR:Refresh("VIEW_HVIGRD")
					EndIf
					lRet := .T.
				EndIf
			CASE ( "N7F_REGRA" $ Readvar() )//CODIFICANDO								

				If ValType(__cCampo) != "U"	// 
					oModelN7F:SetValue('N7F_CAMPO',__cCampo )
				EndIf
				
				If Empty(oModel:GetModel("N7FUNICO"):GetValue("N7F_REGRA")) // Se o campo informado estiver vazio, limpa o campo hvi
					oModelN7F:ClearField('N7F_CAMPO')
					If ValType(__oViewNJR) != "U"	// Atualiza a View
						__oViewNJR:Refresh("VIEW_TIPOR")
					EndIf
					lRet := .T.
				EndIf

			CASE ( "NJR_TIPACE" $ ReadVar() )
				If _lCeoga290 // Se for pressionar o botão de Cancelar na consulta específica do campo então
					_lCeoga290 := .F.
					RestArea(aArea)
					Return .T.
				EndIf
				If Empty(oModelNJRE:GetValue("NJR_TIPACE")) // Se o campo estiver vazio não executa a validação e retorna .T.
					lRet := .T.
				ElseIf lRet := UBAA060BLO(oModelNJRE:GetValue("NJR_TIPACE")) // Se válido então
					oModelN7J:SetNoInsertLine(.F.)
					oModelN7J:SetNoDeleteLine(.F.)
	
					aTipsAce := Separa(oModelNJRE:GetValue("NJR_TIPACE") , "OU") // Monta o array de tipos
	
					//Se tiver Tipos Aceitáveis já cadastrados, consistir pois o Tipo Padrão não pode ser igual aos Tipos Aceitáveis.
					For nX := 1 to Len(aTipsAce)	
						If AllTrim(oModelNJRE:GetValue("NJR_TIPALG")) == AllTrim(aTipsAce[nX])
							Help(" ",1,"OGA290CPO3") //"Não podem existir Tipos Aceitáveis de Algodão iguais ao Tipo Padrão."
							Return .F.
						EndIf
					Next nX
	
					If oModel:GetOperation() == MODEL_OPERATION_INSERT 
						oModelN7E:ClearData() // Limpa a grid fisicamente
						oModelN7E:InitLine() // Inicializa uma nova linha
	
						oModelN7J:ClearData() // Limpa a grid fisicamente
						oModelN7J:InitLine() // Inicializa uma nova linha
	
						oModelN7G:ClearData() // Limpa a grid fisicamente
						oModelN7G:InitLine() // Inicializa uma nova linha						
	
					ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE			
						//--grid de tipo-cor aba algodao
						For nIt := 1 To oModelN7J:Length() // Deleta todas as linhas da grid para a nova carga
							If oModelN7J:Length() == 1 .AND. Empty(oModelN7J:GetValue("N7J_TCRTIP", 1))
								Exit
							EndIf
							oModelN7J:GoLine(nIt)
							oModelN7J:DeleteLine()
							nTipLineJ++
						Next nIt
	
						//--grid de tipos opcionais/aceitaveis aba principal
						For nIt := 1 To oModelN7E:Length() // Deleta todas as linhas da grid para a nova carga
							If oModelN7E:Length() == 1 .AND. Empty(oModelN7E:GetValue("N7E_TIPACE", 1))
								Exit
							EndIf
							oModelN7E:GoLine(nIt)
							oModelN7E:DeleteLine()
							nTipLine++ // Incrementa a variavel de posição
						Next nIt
					EndIf
	
					//--grid de tipos opcionais/aceitaveis aba principal
					For nIt := 1 to Len(aTipsAce) // Realiza a carga de dados
						If .NOT.( oModelN7E:Length() == 1 .AND. Empty(oModelN7E:GetValue("N7E_TIPACE", 1)) ) 
							oModelN7E:AddLine()
						EndIf
						oModelN7E:LoadValue('N7E_TIPACE', ALLTRIM(aTipsAce[nIt]))             
					Next nIt
	
					oModelN7E:GoLine(nTipLine) // Posiciona na primeira linha do Grid N7E
	
					//--grid de tipo-cor aba algodao
					For nIt := 1 To Len(aTipsAce) // Remonta o array com os tipos opcionais correspondentes de cada linha
						aTipsAce[nIt] := AllTrim(aTipsAce[nIt])
						If Empty(aTipsPd)
							aAdd(aTipsPd, aTipsAce[nIt])
						Else
							If Substr(aTipsPd[nTip], 1, 2) == Substr(aTipsAce[nIt], 1, 2) 
								//agrupa por tipo e folha ex: 12-3 --> 1=tipo, 2=cor, 3=folha então agruparia 12-1; 12-2; 12-3 ... 
								aTipsPd[nTip] += " / " + aTipsAce[nIt]
							Else							
								aAdd(aTipsPd, aTipsAce[nIt])
								nTip++							
							EndIf
						EndIf
					Next nIt
	
					//--grid de tipo-cor aba algodao
					For nIt := 1 to Len(aTipsPd) // Realiza a carga de dados											   							
						If .NOT.(oModelN7J:Length() == 1 .AND. Empty(oModelN7J:GetValue("N7J_TCRTIP", 1)) ) 
							oModelN7J:AddLine()
						EndIf
	
						If ValType(__oViewNJR) != "U" // Validação para incremental do campo N7J_SEQUEN, caso tenha view e caso não tenha
							__oViewNJR:Refresh("VIEW_TIPOT") // View N7J
						Else
							If nIt == 1
								oModelN7J:SetValue("N7J_SEQUEN", "001")
							Else
								oModelN7J:SetValue("N7J_SEQUEN", Soma1(oModelN7J:GetValue("N7J_SEQUEN", nIt - 1)))
							EndIf
						EndIf
	
						oModelN7J:SetValue('N7J_TCRTIP', ALLTRIM(aTipsPd[nIt]))
	
					Next nIt
	
					oModelN7J:SetNoInsertLine(.T.) // Desabilita a ação de Inserir Linhas
					oModelN7J:SetNoDeleteLine(.T.) // Desabilita a ação de Deletar Linhas
	
					oModelN7J:GoLine(nTipLineJ) // Posiciona na primeira linha do Grid N7J
					oModelN7G:GoLine(nTipLineJ) // Posiciona na primeira linha do Grid N7J
	
					If ValType(__oViewNJR) != "U" .AND. ValType(__oViewN7E) != "U" // Aplica o Refresh na View - Tipos Opcionais
						__oViewNJR:Refresh("VIEW_TIPOT") // View N7J
						__oViewNJR:Refresh("VIEW_TIPOM") // View N7G
						__oViewN7E:Refresh() // View N7E
					EndIf			
				EndIf			                                                                                	
			CASE ( "N78_OUTCOD" $ ReadVar() )
				If .Not. Empty(oModelN78O:GetValue("N78_OUTCOD"))
	
					lRet := ExistCpo("N7K", oModelN78O:GetValue("N78_OUTCOD"))
	
					If lRet 
						If Posicione("N7K", 1, xFilial("N7K") + oModelN78O:GetValue("N78_OUTCOD"), "N7K_SITUAC") != "1"
							Help("",1,"OGA290AGATIV") //Permitir somente selecionar Ágio/Deságio que estão com situação Ativo. 
							Return .F.
						EndIf
					Else 
						Return .F.
					EndIf
				EndIf 
			CASE ( "NNF_VLBCOM" $ ReadVar() )
				If oModelNNF:GetValue("NNF_MODCOM") == "1" .OR. oModelNNF:GetValue("NNF_MODCOM") == "2"
					lRet := Positivo()
					If .NOT. lRet 
						Help("",1,"OGA290PON") //Para informar Vl. Comissão negativo o tipo de comissão deve ser por pontos.Informe um valor Positivo.
						Return .F. 
					EndIf
				EndIf
			CASE ( "NNF_MODCOM" $ ReadVar() )
				If lRet := Pertence('123')
					If oModelNNF:GetValue("NNF_MODCOM") == "1" .OR. oModelNNF:GetValue("NNF_MODCOM") == "2"
						If .Not. Empty(oModelNNF:GetValue("NNF_VLBCOM"))
							If oModelNNF:GetValue("NNF_VLBCOM") < 0
								Help("",1,"OGA290PON") //Para informar Vl. Comissão negativo o tipo de comissão deve ser por pontos.Informe um valor Positivo. 
								Return .F.
							EndIf    
						EndIf    
					EndIf  
				EndIf         
		ENDCASE
	EndIf

	RestArea(aArea)
Return(lRet)

/*{Protheus.doc} OGA290FLWS
(Função para adição das duas grid na aba Principal da Aba Algodão)
@type function
@author roney.maia
@since 11/05/2017
@version 1.0
@param oPanel, objeto, (Painel no qual será construido as grids)
@param oObj, objeto, (FwOtherObject no qual contem a view principal)
*/
Static Function OGA290FLWS(oPanel, oObj)
	Local oModel 		:= oObj:OCONTROL:GetModel() // Obtem o model utilizado pela view
	Local oViewPai	:= oObj:OCONTROL // Obtem a view pai
	Local oStruNJRTA 	:= FWFormStruct( 2, 'NJR' , { |x| ALLTRIM(x)  $ 'NJR_TIPACE' })
	Local oStruNJRQA 	:= FWFormStruct( 2, 'NJR' , { |x| ALLTRIM(x)  $ 'NJR_QAPADR' })
	Local oStruN7E  	:= FWFormStruct( 2, "N7E" , { |x| !ALLTRIM(x) $ 'N7E_CODCTR, N7E_CAMPO'})	// Estrutura de tipo de algodão aceitáveis
	Local oStruN7H  	:= FWFormStruct( 2, "N7H" , { |x| !ALLTRIM(x) $ 'N7H_CODCTR, N7H_CAMPO'})	// Estrutura da tabela de qualidade de algodão
	Local oFWLayer 	:= Nil
	Local oLayerESQ	:= Nil
	Local oLayerDIR	:= Nil

	oStruNJRTA:SetNoFolders(.T.)
	oStruNJRQA:SetNoFolders(.T.)

	__oViewN7E	:= FwFormView():New(oViewPai) // Instância uma nova view para a grid de tipos aceitaveis, setando o pai a view principal
	__oViewN7H	:= FwFormView():New(oViewPai) // Instância uma nova view para a grid de qualidade do algodão, , setando o pai a view principal

	__oViewN7E:SetOperation(oViewPai:GetOperation()) // Seta a operação para as views filhas
	__oViewN7H:SetOperation(oViewPai:GetOperation())

	__oViewN7E:SetModel(oModel) // Seta o model utilizado pela view
	__oViewN7H:SetModel(oModel)

	/* -- Layers -- */
	oFWLayer := FWLayer():New() // Instância um novo Layer
	oFWLayer:Init(oPanel, .F., .T.) // Inicia o Layer passando o panel que será construido as janelas

	oFWLayer:AddCollumn('COL01', 50, .F.) // Adiciona uma coluna ao layer de tamanho 50%
	oFWLayer:AddCollumn('COL02', 50, .F.) // Adiciona uma coluna ao layer de tamanho 50% 

	oFwLayer:addWindow('COL01', 'C1_Win01', STR0125, 100, .F., .F.) // Adiciona uma janela para a coluna definida nos parametros
	oFwLayer:addWindow('COL02', 'C1_Win02', STR0126, 100, .F., .F.) // Adiciona uma janela para a coluna definida nos parametros

	oLayerESQ := oFWLayer:GetWinPanel('COL01', 'C1_Win01') // Obtém o panel da janela que contem a coluna 1
	oLayerDIR := oFWLayer:GetWinPanel('COL02', 'C1_Win02') // Obtém o panel da janela que contem a coluna 2

	// ### Construção da View N7E
	__oViewN7E:AddField( "VIEW_FLDTIPACE", oStruNJRTA, "NJRUNICO")
	__oViewN7E:AddGrid( "VIEW_GRIDTIPACE", oStruN7E  , "N7EUNICO")

	__oViewN7E:CreateHorizontalBox( "ALGODAOTPAFLD" , 15)
	__oViewN7E:CreateHorizontalBox( "ALGODAOTPAGRD" , 85) 

	__oViewN7E:SetOwnerView("VIEW_FLDTIPACE", "ALGODAOTPAFLD")
	__oViewN7E:SetOwnerView("VIEW_GRIDTIPACE", "ALGODAOTPAGRD")

	__oViewN7E:AddIncrementField( "VIEW_GRIDTIPACE", "N7E_ORDEM" )
	// ###########################################################################

	// ### Construção da View N7H
	__oViewN7H:AddField( "VIEW_FLDQUALID", oStruNJRQA, "NJRUNICO")
	__oViewN7H:AddGrid( "VIEW_GRIDQUALID", oStruN7H, "N7HUNICO")

	__oViewN7H:CreateHorizontalBox( "ALGODAOQUAFLD" , 15)
	__oViewN7H:CreateHorizontalBox( "ALGODAOQUAGRD" , 85)

	__oViewN7H:SetOwnerView("VIEW_FLDQUALID", "ALGODAOQUAFLD")
	__oViewN7H:SetOwnerView("VIEW_GRIDQUALID", "ALGODAOQUAGRD")

	__oViewN7H:AddIncrementField( "VIEW_GRIDQUALID", "N7H_ITEM" )
	// ###########################################################################

	__oViewN7E:SetOwner(oLayerESQ) // Seta o objeto pai que sera construido a view
	__oViewN7H:SetOwner(oLayerDIR) // Seta o objeto pai que sera construido a view

	__oViewN7E:Activate() // Realiza a ativação da view
	__oViewN7H:Activate() // Realiza a ativação da view

	// Habilita o When dos Fields devido a limitação de utilização de multiplas views
	__oViewN7E:GetViewObj("VIEW_FLDTIPACE")[3]:GetFwEditCtrl("NJR_TIPACE"):OCTRL:BWHEN := {|| .T.}
	__oViewN7H:GetViewObj("VIEW_FLDQUALID")[3]:GetFwEditCtrl("NJR_QAPADR"):OCTRL:BWHEN := {|| .T.}

Return

/*{Protheus.doc} OGA290VMDF
(Função de verificação para Modificação da View e Pré-Validação de Grids)
@type function
@author roney.maia
@since 15/05/2017
@version 1.0
@param oMdGridDXQ, objeto, (FwFormGrid que acionou a validação)
@param nLine, numérico, (Número da linha que a grid está posicionada)
@param cAction, character, (Ação que chamou a validação)
@param cField, character, (Campo posicionado)
@param xValueNew, variável, (Valor novo inserido)
@param xValueOld, variável, (Valor anterior)
@return ${return}, ${.T. - Validado, .F. - Não Validado}
*/
Static Function OGA290VMDF(oMdGrid, nLine, cAction, cField, xValueNew, xValueOld)
	Local lRet 		:= .T.
	Local oView 		:= __oViewNJR // View Pai - NJR
	Local nIt			:= 0
	Local oModel		:= oMdGrid:GetModel()
	Local oModelN7J	:= oModel:GetModel("N7JUNICO")
	Local oModelN7G	:= oModel:GetModel("N7GUNICO")
	Local oModelNJRE	:= oModel:GetModel("NJRUNICO")
	Local oModelN78	    := oModel:GetModel("N78HVI")
	Local oModelN7F	    := oModel:GetModel("N7FUNICO")
	Local lAdd			:= .F.
	Local nIta			:= 0
	Local cConcVlr	:= ""
	Local lDel			:= .F.
	Local nLineAtu 	:= 1

	oModelN7F:SetNoInsertLine(.T.) // Desabilita a inserção de linhas da grid N7F - Regra HVI por tipo, cor e folha

	If .NOT.  __lFiltr .AND. oMdGrid:GetId() $ "N78HVI" .AND. cAction == "SETVALUE" .AND. cField == "N78_HVIREG" .AND. !__lAutomato
		Help(" ",1,"OGA290RHVIM")//Regra Invalida! Favor utilizar  o filtro!
		__lFiltr 	:=  .F.
		__lValid 	:= .T.
		__cNewVal	:= xValueNew
		__cOldVal	:= xValueOld
		Return .F.
	ElseIf oMdGrid:GetId() $ "N78HVI" .AND. cAction == "CANSETVALUE" .AND. cField == "N78_HVIREG"
		__cOldHvi := oModelN78:GetValue(cField, nLine)
	ElseIf .NOT.  __lFiltr .AND. oMdGrid:GetId() $ "N7FUNICO" .AND. cAction == "SETVALUE" .AND. cField == "N7F_REGRA"
		Help(" ",1,"OGA290RHVIM")//Regra Invalida! Favor utilizar  o filtro!
		__lFiltr 	:=  .F.
		__lValid 	:= .T.
		__cNewVal	:= xValueNew
		__cOldVal	:= xValueOld
		Return .F.
	ElseIf oMdGrid:GetId() $ "N7FUNICO" .AND. cAction == "CANSETVALUE" .AND. cField == "N7F_REGRA"
		__cOldHvi := oModelN7F:GetValue(cField, nLine)
	Else
		__lFiltr :=  .F.	
	EndIf

	If	oMdGrid:GetId() $ "N7HUNICO|N7EUNICO" .AND. Valtype(oView) != "U" .AND. cAction == "DELETE"	// Se a View Existe e a ação for DELETE	
		oView:SetModified()	// Seta a View como modificada, para realizar o commit.
	EndIf

	// Validação de valores iguais para não execução de validação dos campos de HVIDES
	If oMdGrid:GetId() $ "N7HUNICO|N7FUNICO|N78HVI" .AND. ValType(cField) != "U" .AND. cField $ "N7H_HVIDES|N7F_HVIDES" .AND. ;
	cAction == "SETVALUE" .AND. UPPER(ALLTRIM(xValueNew)) == UPPER(ALLTRIM(xValueOld))
		__lCampVld := .T.
	EndIf

	If oMdGrid:GetId() == "N7EUNICO"		
		If cAction == "SETVALUE" .AND. cField == "N7E_TIPACE" // SE A AÇÂO FOR SETVALUE
			If AllTrim(oModelNJRE:GetValue("NJR_TIPALG")) == AllTrim(xValueNew) // Validação de tipo padrão igual a tipo opcional
				Help(" ",1,"OGA290CPO3") //"Não podem existir Tipos Opcionais de Algodão iguais ao Tipo Padrão."
				Return .F.
			EndIf
			If lRet := .NOT. AllTrim(xValueNew) == '-' .AND. ExistCPO("DXA", AllTrim(xValueNew), 1) // Validação de campo antes da carga de dados
				For nIt := 1 To oMdGrid:Length() // Validação de Linha Duplicada, que difere do changeline padrão do protheus										
					If !oMdGrid:IsDeleted(nIt) .AND. ALLTRIM(oMdGrid:GetValue("N7E_TIPACE", nIt)) == ALLTRIM(xValueNew) .AND. nIt != nLine
						Help("", 1, "OGA290LINDUPL") // # Já foi informado um registro relacionado a este código.
						Return .F.
					EndIf
				Next nIt
				// ##########	Remoção de Tipo Opcional que estava anteriormente presente no campo e consequentemente presente na grid de tipo/folha	#########
				For nIt := oModelN7J:Length() To 1 Step -1
					If  AllTrim(xValueOld) $ AllTrim(oModelN7J:GetValue("N7J_TCRTIP", nIt)) .AND. .NOT. oModelN7J:IsDeleted(nIt)	// Verifica se o tipo opcional anterior existe na grid tipo/folha e não se encontra deletado									
						aAux := Separa(AllTrim(oModelN7J:GetValue("N7J_TCRTIP", nIt)), " / ") // Separa os tipos em um array

						If Len(aAux) > 1 // Se contem mais que dois tipos, realiza a remoção do tipo encontrado
							For nIta := 1 To Len(aAux) // Percorre os tipos para realizar a remoção do tipo opcional que devera ser removido
								If AllTrim(xValueOld) $ aAux[nIta]
									aDel(aAux, nIta)
									aSize(aAux, Len(aAux) - 1)
									Exit
								EndIf	
							Next nIta

							aSort(aAux) // Realiza a reordenação

							For nIta := 1 To Len(aAux) // Monta a nova string de tipos que será inserido no campo correspondente da grid tipo/folha
								cConcVlr += aAux[nIta] + " / "
							Next nIta

							cConcVlr := Substr(cConcVlr, 1, Len(cConcVlr) - 3) // Remove caracteres excedentes

							oModelN7J:GoLine(nIt) // Posiciona na linha
							oModelN7J:SetValue('N7J_TCRTIP', cConcVlr) // Seta o nos tipos opcionais
							cConcVlr := ""
						ElseIf Len(aAux) == 1 .AND. AllTrim(xValueOld) $ aAux[1] // Se contem 1 tipo opcional e é igual o valor anterior seta como deletado
							oModelN7J:GoLine(nIt) // Posiciona na linha
							oModelN7J:SetNoDeleteLine(.F.) // Habilita a permissão de deletar linhas
							oModelN7J:DeleteLine() // Deleta a linha ja posicionada anteriormente
							oModelN7J:SetNoDeleteLine(.T.) // Desabilita a permissão de deletar linhas
							Exit
						EndIf
					EndIf
				Next nIt	
				// #################	END ######################

				// ################ ADIÇÃO DE NOVO TIPO OPCIONAL INSERIDO ###############
				For nIt := oModelN7J:Length() To 1 Step -1
					If  AllTrim(xValueNew) $ AllTrim(oModelN7J:GetValue("N7J_TCRTIP", nIt)) .AND. .NOT. oModelN7J:IsDeleted(nIt) // Se já contém o mesmo tipo opcional na grid tipo/folha, não realiza a carga
						Return lRet
					ElseIf .NOT. oModelN7J:IsDeleted(nIt) .AND. Substr(AllTrim(xValueNew), 1, 2) == Substr(AllTrim(oModelN7J:GetValue("N7J_TCRTIP", nIt)), 1, 2) //Correção Vitor Se contém o mesmo tipo de algodão e não está deletado, realiza a carga	
						aAux := Separa(AllTrim(oModelN7J:GetValue("N7J_TCRTIP", nIt)), " / ") // Separa os tipos em um array

						aAdd(aAux, AllTrim(xValueNew)) // Adiciona o novo tipo
						aSort(aAux) // Reordena os tipos

						For nIta := 1 To Len(aAux) // Monta a nova string de tipos que será inserido no campo correspondente da grid tipo/folha
							cConcVlr += aAux[nIta] + " / "
						Next nIta

						cConcVlr := Substr(cConcVlr, 1, Len(cConcVlr) - 3) // Remove caracteres excedentes

						oModelN7J:GoLine(nIt) // Posiciona na linha
						oModelN7J:SetValue('N7J_TCRTIP', cConcVlr) // Seta o nos tipos opcionais
						lDel := .F. // Atribui falso a variavel para não remover a o deletado da linha
						Exit
					Else
						lDel := .T. // Atribui verdadeiro para remover o deletado da linha
					EndIf
				Next nIt

				If lDel // Se .T. Avalia se a linha sera removida o deletado ou será adicionado uma nova linha
					For nIt := oModelN7J:Length() To 1 Step -1
						If oModelN7J:IsDeleted(nIt) .AND. Substr(AllTrim(xValueNew), 1, 2) == Substr(AllTrim(oModelN7J:GetValue("N7J_TCRTIP", nIt)), 1, 2) //CORREÇÃO VITOR PARA CONSIDERAR A COR
							If Substr(AllTrim(oModelN7J:GetValue("N7J_TCRTIP", nIt)), 1, 2) > Substr(AllTrim(oModelN7J:GetValue("N7J_TCRTIP", oModelN7J:Length())), 1, 2) //CORREÇÃO VITOR PARA CONSIDERAR A COR Se o tipo opcional maior que o tipo opcional da ultima linha iserida, então adiciona uma nova linha
								lAdd := .T.
								Exit
							Else // Senão remove o deletado da linha e atribui o novo valor
								oModelN7J:GoLine(nIt)
								oModelN7J:SetNoDeleteLine(.F.) // Habilita a permissão para deletar ou remover o deletado da linha
								oModelN7J:UnDeleteLine() // Remove o deletado da linha
								oModelN7J:SetValue('N7J_TCRTIP', AllTrim(xValueNew))
								oModelN7J:SetNoDeleteLine(.T.) // Desabilita a permissão para deletar ou remover o deletado da linha
								lAdd := .F.
								Exit
							EndIf		
						Else // Atribui .T. para adicionar uma nova linha
							lAdd := .T.
						EndIf
					Next nIt
				EndIf

				If oModelN7J:Length() == 1 .AND. .NOT. oModelN7J:IsDeleted(1) .AND. Empty(oModelN7J:GetValue("N7J_TCRTIP", 1)) // Se o tamanho da grid tipo/folha for 1, e não estiver deletada e estiver vazia
					oModelN7J:GoLine(1) // Posiciona na linha 1
					oModelN7J:SetValue('N7J_TCRTIP', AllTrim(xValueNew)) // Atribui o tipo opcional a linha posicionada
				ElseIf lAdd // Senão se, for inserção de linha, realiza a inserção
					oModelN7J:SetNoInsertLine(.F.) // habilita a inserção de linha
					oModelN7J:AddLine() // Adiciona uma nova linha
					oModelN7J:SetValue('N7J_TCRTIP', AllTrim(xValueNew)) 
					oModelN7J:SetNoInsertLine(.T.) // Desabilita a inserção de linha
				EndIf

				For nIt := 1 To oModelN7J:Length() // Procura a primeira linha que não está deletada
					If .NOT. oModelN7J:IsDeleted(nIt)
						nLineAtu := nIt
						Exit
					EndIf
				Next nIt
				oModelN7J:GoLine(nLineAtu) // Posiciona na ultima linha não deletada
				oModelN7G:GoLine(nLineAtu) // Posiciona na ultima linha não deletada
				If ValType(__oViewNJR) != "U" // Aplica o Refresh na View - Tipos Opcionais
					__oViewNJR:Refresh("VIEW_TIPOT")
					__oViewNJR:Refresh("VIEW_TIPOM")
				EndIf
			EndIf
			// #####################################################################################

		ElseIf cAction == "DELETE" // SE A AÇÃO FOR DELETE
			For nIt := oModelN7J:Length() To 1 Step -1 // Realiza a remoção do tipo opcional que foi deletado
				If .NOT. oModelN7J:IsDeleted(nIt) // Se não está deletado
					If  AllTrim(oMdGrid:GetValue("N7E_TIPACE" , nLine)) $ AllTrim(oModelN7J:GetValue("N7J_TCRTIP", nIt))	// Se contem o tipo a ser deletado
						aAux := Separa(AllTrim(oModelN7J:GetValue("N7J_TCRTIP", nIt)), " / ") // Separa os tipos em um array

						For nIta := 1 To Len(aAux) // Percorre os tipos para realizar a remoção do tipo opcional que devera ser removido
							If AllTrim(oMdGrid:GetValue("N7E_TIPACE" , nLine)) $ aAux[nIta]
								aDel(aAux, nIta)
								aSize(aAux, Len(aAux) - 1)
								Exit
							EndIf	
						Next nIta

						For nIta := 1 To Len(aAux) // Monta a nova string de tipos que será inserido no campo correspondente da grid tipo/folha
							cConcVlr += aAux[nIta] + " / "
						Next nIta

						cConcVlr := Substr(cConcVlr, 1, Len(cConcVlr) - 3) // Remove caracteres excedentes

						oModelN7J:GoLine(nIt) // Posiciona na linha a ser alterada da grid tipo/folha
						If .NOT. Empty(cConcVlr) // Se a string com os tipos opcionais não estiver vazia, seta o novo valor no campo sem o tipo que foi deletado
							oModelN7J:SetValue('N7J_TCRTIP', cConcVlr) 							
						Else
							oModelN7J:SetNoDeleteLine(.F.) // Habilita a pemissão de deletar linhas
							oModelN7J:DeleteLine() // Deleta a linha
							oModelN7J:SetNoDeleteLine(.T.) // Desabilita a pemissão de deletar linhas
						EndIf
					EndIf
				EndIf
			Next nIt

			For nIt := 1 To oModelN7J:Length() // Procura a primeira linha não deletada
				If .NOT. oModelN7J:IsDeleted(nIt)
					nLineAtu := nIt
					Exit
				EndIf
			Next nIt
			oModelN7J:GoLine(nLineAtu) // Posiciona na primeira linha não deletada
			oModelN7G:GoLine(nLineAtu) // Posiciona na primeira linha não deletada
			If ValType(__oViewNJR) != "U" // Aplica o Refresh na View - Tipos Opcionais
				__oViewNJR:Refresh("VIEW_TIPOT")
				__oViewNJR:Refresh("VIEW_TIPOM")
			EndIf
		ElseIf cAction == "UNDELETE" // SE FOR A AÇÃO DE REMOÇÂO DE DELETE
			If AllTrim(oModelNJRE:GetValue("NJR_TIPALG")) == ALLTRIM(oMdGrid:GetValue("N7E_TIPACE", nLine)) // Validação de tipo opcional igual a tipo padrão.
				Help(" ",1,"OGA290CPO3") //"Não podem existir Tipos Aceitáveis de Algodão iguais ao Tipo Padrão."
				Return .F.
			EndIf	
			For nIt := 1 To oMdGrid:Length() // Validação de Linha Duplicada, que difere do changeline padrão do protheus
				If !oMdGrid:IsDeleted(nIt) .AND. ALLTRIM(oMdGrid:GetValue("N7E_TIPACE", nIt)) == ALLTRIM(oMdGrid:GetValue("N7E_TIPACE", nLine)) .AND. nIt != nLine
					Help("", 1, "OGA290LINDUPL") // # Já foi informado um registro relacionado a este código.
					Return .F.
				EndIf
			Next nIt

			For nIt := oModelN7J:Length() To 1 Step -1 
				If .NOT. oModelN7J:IsDeleted(nIt) .AND. Substr(ALLTRIM(oMdGrid:GetValue("N7E_TIPACE", nLine)), 1, 2) == Substr(AllTrim(oModelN7J:GetValue("N7J_TCRTIP", nIt)), 1, 2) //CORREÇÃO VITOR PARA CONSIDERAR A COR Verifica a linha que contem o mesmo tipo e que não está deletada
					aAux := Separa(AllTrim(oModelN7J:GetValue("N7J_TCRTIP", nIt)), " / ") // Separa os tipos em um array

					aAdd(aAux, ALLTRIM(oMdGrid:GetValue("N7E_TIPACE", nLine))) // Adiciona o novo tipo
					aSort(aAux) // Reordena os tipos

					For nIta := 1 To Len(aAux) // Monta a string com os novos tipos opcionais
						cConcVlr += aAux[nIta] + " / "
					Next nIta

					cConcVlr := Substr(cConcVlr, 1, Len(cConcVlr) - 3) // Remove caracteres excedentes

					oModelN7J:GoLine(nIt) // Posiciona na linha correspondente
					oModelN7J:SetValue('N7J_TCRTIP', cConcVlr) // Atribui o tipo opcional a linha posicionada
					lDel := .F.
					Exit
				Else // Senão a linha está deletada e deverá ser restaurada
					lDel := .T.
				EndIf
			Next nIt

			If lDel // Se a linha consta como deletada
				For nIt := oModelN7J:Length() To 1 Step -1 // Verifica a necessidade de adicionar uma nova linha para ordenação crescente
					If oModelN7J:IsDeleted(nIt) .AND. Substr(ALLTRIM(oMdGrid:GetValue("N7E_TIPACE", nLine)), 1, 2) == Substr(AllTrim(oModelN7J:GetValue("N7J_TCRTIP", nIt)), 1, 2) //CORREÇÃO VITOR PARA CONSIDERAR A COR
						oModelN7J:GoLine(nIt)
						oModelN7J:SetNoDeleteLine(.F.)
						oModelN7J:UnDeleteLine()
						oModelN7J:SetValue('N7J_TCRTIP', ALLTRIM(oMdGrid:GetValue("N7E_TIPACE", nLine)))
						oModelN7J:SetNoDeleteLine(.T.)
						lAdd := .F.
						Exit
					Else // Senão será necessário adicionar uma nova linha
						lAdd := .T.
					EndIf
				Next nIt
			EndIf

			If lAdd // Se caso for necessário adicionar uma nova linha
				oModelN7J:SetNoInsertLine(.F.)
				oModelN7J:AddLine()
				oModelN7J:SetValue('N7J_TCRTIP', ALLTRIM(oMdGrid:GetValue("N7E_TIPACE", nLine)))
				oModelN7J:SetNoInsertLine(.T.)
			EndIf

			For nIt := 1 To oModelN7J:Length() // Procura a primeira linha que não está deletada
				If .NOT. oModelN7J:IsDeleted(nIt)
					nLineAtu := nIt
					Exit
				EndIf
			Next nIt
			oModelN7J:GoLine(nLineAtu) // Posiciona na primeira linha não deletada
			oModelN7G:GoLine(nLineAtu) // Posiciona na primeira linha não deletada
			If ValType(__oViewNJR) != "U" // Aplica o Refresh na View - Tipos Opcionais
				__oViewNJR:Refresh("VIEW_TIPOT")
				__oViewNJR:Refresh("VIEW_TIPOM")
			EndIf
		EndIf
	EndIf

Return lRet

/*{Protheus.doc} OGA290VBLC
Executa a consulta de fardos
@author jean.schulze
@since 26/05/2017
@version undefined
@type function
*/
Function OGA290VBLC(cCodCtr, cCodPro, cFilCtr)
	if AGRTPALGOD(cCodPro) 
		OGC040(cCodCtr, cFilCtr) //executa a consulta
	else
		Help(" ",1,"OGA290ALGOD") //Opção disponível somente para commodities do tipo Algodão
	endif			
return .t.

/*-------------------------------------------------------------------
{Protheus.doc} OGA290ITE
//Retorna os itens da regra
@author marcelo.wesan
@since 14/06/2017
@type function
-------------------------------------------------------------------*/
Function OGA290ITE(cRegra, oModel)

	Local aArea		:= GetArea()
	Local aColsLoad	:= {}
	Local nX 		:= 0
	Local nY        := 0
	Local cQuery 	:= ""
	Local cAliasQry := GetNextAlias()
	Local cCodigo   := cRegra
	Local nLineAtu	:= 1 

	oModelN7H	:= oModel:GetModel("N7HUNICO")

	cQuery := " SELECT  N81.N81_CAMPO, N81.N81_CODREG, N81.N81_VLDE, N81.N81_VLATE "
	cQuery += " FROM " + RetSqlName("N81") + " N81"
	cQuery += " INNER  JOIN " + RetSqlName("N80")+" N80" +" ON"
	cQuery += " N80.N80_FILIAL = N81.N81_FILIAL "
	cQuery += " AND N80.N80_CODIGO = N81.N81_CODEMB "
	cQuery += " AND N80.N80_TIPEMB = N81.N81_TIPEMB "	
	cQuery += " AND N80.D_E_L_E_T_ <> '*'""
	cQuery += " WHERE  N81.N81_FILIAL 	= '"+xFilial("N81")+"'"
	cQuery += " AND N81.N81_TIPREG = '1' " 
	cQuery += " AND N81.N81_TIPEMB = '1' " 
	cQuery += " AND N81.D_E_L_E_T_ <> '*' AND "	
	cQuery += " N81.N81_CODEMB  = '"+cCodigo+"'"	

	If Select(cAliasQry) > 0
		(cAliasQry)->( dbCloseArea())
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	//Seleciona a tabela 
	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof())
		aAdd( aColsLoad, {(cAliasQry)->N81_CAMPO, ALLTrim((cAliasQry)->N81_CODREG), (cAliasQry)->N81_VLDE, (cAliasQry)->N81_VLATE})
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)

	If Len(aColsLoad) > 0

		If oModel:GetOperation() == 3 
			oModelN7H:ClearData()
			oModelN7H:InitLine()
		Else
			If !(oModelN7H:Length() == 1 .AND. Empty(oModelN7H:GetValue("N7H_HVIDES", 1)))
				for nY := 1 to oModelN7H:Length()
					oModelN7H:GoLine( nY )
					oModelN7H:DeleteLine()
					nLineAtu++ 
				Next nY
				__oViewN7H:GetModel():GetModel("N7HUNICO"):AddLine()   
			EndIf     	
		EndIf

		For nX := 1 to Len(aColsLoad)

			If nX > 1
				__oViewN7H:GetModel():GetModel("N7HUNICO"):AddLine()
			EndIf

			oModel:SetValue('N7HUNICO', 'N7H_HVIDES' , aColsLoad[nX][2])      
			oModel:LoadValue('N7HUNICO', 'N7H_VLRINI' , aColsLoad[nX][3])  
			oModel:LoadValue('N7HUNICO', 'N7H_VLRFIM' , aColsLoad[nX][4])

		Next nX 

		oModelN7H:GoLine(nLineAtu) // Posicionada na linha que estava anteriormente posicionada

		If ValType(__oViewN7H) != "U" // Aplica o Refresh na View N7H - HVI
			__oViewN7H:Refresh()
		EndIf
	EndIf
Return(.T.)

/*{Protheus.doc} OGA290SFLD
(Função que faz a seleção de aba)
@type function
@author roney.maia
@since 06/07/2017
@version 1.0
@param nAbaOwn, numérico, (Número da Aba Pai)
@param nAbaVld, numérico, (Número da Aba Filho)
*/
Static Function OGA290SFLD(nAbaOwn, nAbaVld)
	If __lMostraAlg
		If ValType(__oViewNJR) != 'U' // Se Existe a View Pai
			If __oViewNJR:GetFolderActive("ALGFOLDER", 2)[1] != nAbaVld
				__oViewNJR:SelectFolder("ALGFOLDER", nAbaVld, 2) // Seleciona a Aba Filha
			EndIf
		EndIf
	Else
		If ValType(__oViewNJR) != 'U' // Se Existe a View Pai
			If __oViewNJR:GetFolderActive("CTRFOLDER", 2)[1] != nAbaOwn
				__oViewNJR:SelectFolder("CTRFOLDER", nAbaOwn, 2) // Selectiona a Aba Pai
			EndIf
			If __oViewNJR:GetFolderActive("ALGFOLDER", 2)[1] != nAbaVld
				__oViewNJR:SelectFolder("ALGFOLDER", nAbaVld, 2) // Seleciona a Aba Filha
			EndIf
		EndIf
	EndIf
Return

/*{Protheus.doc} OGA290TPDS
Função para validar os tipos da regra hvi
@author jean.schulze
@since 25/07/2017
@version undefined
@param cTipos, characters, descricao
@param oModelN7E, object, descricao
@type function
*/
Static Function OGA290TPDS(cTipos, oModelN7E)
	Local lRet     := .t.
	Local aTipsAce := {}
	Local nX       := 0
	Local oModel  := oModelN7E:GetModel()

	if !Empty(cTipos)  .AND. (lRet := UBAA060BLO (cTipos))
		aTipsAce := Separa(cTipos , "OU") // Monta o array de tipos

		//Se tiver Tipos Aceitáveis já cadastrados, consistir pois o Tipo Padrão não pode ser igual aos Tipos Aceitáveis.
		For nX := 1 to Len(aTipsAce)
		
			If AllTrim(oModel:GetModel("NJRUNICO"):GetValue("NJR_TIPALG")) == AllTrim(aTipsAce[nX])
				Loop
			EndIf

			if oModelN7E:SeekLine( { {"N7E_TIPACE", AllTrim(aTipsAce[nX]) } } ) //tipo opcional
				if !oModelN7E:IsDeleted()  
					Loop
				endif	
			endif

			//não entrou nas verificações possíveis
			Help("", 1, "OGA290CPO9") //Tipo não encontrado na lista de Tipos Opcionais do contrato. 
			lRet := .f.
			Exit

		Next nX
	endif

return lRet

/** {Protheus.doc} OGC290VDTF
Função validar o campo.
@return:    cRet - true ou false
@author:    filipe.olegini
@since:     20/04/2018
@Uso:       OGA290 - Contrato de Venda
*/
Function OGC290VDTF() 
	Local oModel	:= FwModelActive()
	Local oN84		:= nil
	Local lRetorno	:= .T.

    If oModel:GetID() == "OGA290"
        oN84    := oModel:GetModel( "N84UNICO" )

        If oN84:GetValue("N84_DTFIXA") < dDataBase	
            Help("", 1, "OGA290VDTFIXA") //Data negociada não pode ser menor que a data atual . 
            lRetorno := .F.
        EndIf
    EndIf

Return( lRetorno )


/*{Protheus.doc} OGA290WATP
Validação das GRID de àgio e deságio por tipo
@author jean.schulze
@since 07/08/2017
@version undefined
@param cFolha, characters, descricao
@param cCor, characters, descricao
@type function
*/
Function OGA290WATP(cFolha, cCor) 
	Local lRet      := .t.
	Local aTipos    := {}
	Local nX        := 0
	Local aFolhaCor := {}
	Local oModel    := FwModelActive()

	Default cFolha  := ""
	Default cCor    := ""

	//monta a lista de dados a serem validados
	if !empty(cFolha)	
		aTipos := Separa(oModel:GetModel("N7JUNICO"):GetValue("N7J_TCRTIP"), "/")
	elseif !empty(cCor)	
		aTipos := Separa(oModel:GetModel("N7GUNICO"):GetValue("N7G_TCRTIP"), "/")
	endif

	For nX := 1 to Len(aTipos)	
		aAdd(aFolhaCor, substr(alltrim(aTipos[nX]), iif(!empty(cFolha),4,2),1))
	Next nX

	if !empty(cFolha) .and. aScan(aFolhaCor, {|x| alltrim(x)  == cFolha }  ) > 0
		lRet := .t.
	elseif !empty(cCor) .and. aScan(aFolhaCor, {|x| alltrim(x)  == cCor }  ) > 0
		lRet := .t.
	else
		lRet := .f.
	endif 

return lRet

/*{Protheus.doc} ValidaN7R
(Função de pos-validação da Grid N7R)
@type function
@author rafael.kleestadt
@since 02/08/2017
@version 1.0
@param oModelN7R, objeto, (FwFormGrid - N7R)
@return ${return}, ${.T. - Validado, .F. - Não Validado}
*/
Static Function ValidaN7R(oModelN7R) 
	Local oModel      := FwModelActive()	
	Local oModelNJR	  := oModel:GetModel( "NJRUNICO" )
	Local nX          := 0
	Local aCodRot     := {}
	Local lRet        := .T.
	Local cCodAtual   := ""
	Local cCodRota    := ""
	Local cCodCtr     := ""
	Local cTipo       := ""

	/*Validação de valores*/
	dbSelectArea( "SY9" ) 
	dbSetOrder( 1 )
	If !dbSeek( xFilial( "SY9" ) + oModel:GetModel('N7RUNICO'):GetValue("N7R_CODROT"))
		lRet := .F.
		Help("", 1, "OGA290VALPORTO")//O código informado não existe no cadastro de Portos/Aeroportos. 
	Else
		For nX := 1 to oModelN7R:Length()

			cCodRota := ALLTRIM(oModelN7R:GetValue('N7R_CODROT' , nX) )
			cCodCtr  := ALLTRIM(oModelNJR:GetValue('NJR_CODCTR' , nX) )
			cTipo    := ALLTRIM(oModelN7R:GetValue('N7R_TIPO'   , nX) )

			cCodAtual := cTipo + cCodRota

			If ASCAN(aCodRot, cCodAtual)	
				Help("", 1, "OGA290IDPORTO") //Porto/Aeroporto já informado. 
				lRet := .F.
				Exit
			EndIf

			If !oModelN7R:IsDeleted( nX )
				aAdd(aCodRot, cCodAtual) 	
			EndIf

		Next nX
	ENDiF
Return lRet

/** {Protheus.doc} OGA290FN
Função que valida o gride de dados após sair do grid
Retorna a primeira loja encontrada para fornecedor informado na grid.
@param:     cForn - Fornecedor
@return:    Loja relacionada ao fornecedor
@author:    Niara Cristina Caetano
@since:     29/08/2017  
@Uso:       OGA290 - Contratos
*/
Function OGA290FN(cForn) 
	Local aArea := GetArea()
	Local cLoja := ""

	dbSelectArea("SA2")
	dbSetOrder(1)

	If dbSeek(xFilial("SA2")+cForn)
		While !SA2->(EOF()) .And. SA2->A2_COD == cForn
			cLoja := SA2->A2_LOJA
			If SA2->A2_MSBLQL == '1'
				SA2->(dbSkip())
			Else
				Exit
			EndIf
		EndDo
	EndIf

	RestArea(aArea)

Return cLoja


/** {Protheus.doc} OGA290WH
Função para dicionário [SX3] - validação para limpar o campo de contato ao 
mudar o código do fornecedor  

@return:    lRetorno - .T. verdadeiro ou .F. falso
@author:    Niara Cristina Caetano
@since:     29/08/2017
@Uso:       OGA290 - Contrato de Venda
*/
Function OGA290WH() 
	Local oField	:= FWModelActive()	
	Local oNNF		:= oField:GetModel( "NNFUNICO" )
	Local lRetorno  := .T.

	oNNF:LoadValue("NNF_CDCORR" , "")
	oNNF:LoadValue("NNF_NMCORR" , "")


Return(lRetorno)

/** {Protheus.doc} OGA290VL
Função para dicionário [SX3] - validação para verificar se o contato está relacionado ao 
fornecedor e loja selecionado. 
@return:    lRetorno - .T. verdadeiro ou .F. falso
@author:    Niara Cristina Caetano
@since:     29/08/2017
@Uso:       OGA290 - Contrato de Venda
*/
Function OGA290VL(cForn, cLoja, cCont) 
	Local lRetorno  := .T.
	Local cCodEnt   := cForn + cLoja

	dbSelectArea("AC8")
	AC8->(dbSetOrder(1))

	//verifica se o contato está relacionado ao fornecedor
	If AC8->(dbSeek(xFilial("AC8") + cCont + "SA2" + xFilial("SA2") + cCodEnt))

		dbSelectArea("SU5")
		SU5->(dbSetOrder(1))

		//verifica se o contato está inativo
		If SU5->(dbSeek(xFilial("SU5") + cCont))
			While !SU5->(EOF()) .And. SU5->U5_CODCONT == cCont
				If SU5->U5_MSBLQL == '1' //Inativo
					Help(" ",1,"OGA290REGBLOQ")  //Este registro está bloqueado para uso. 
					lRetorno := .F.
					SU5->(dbSkip())
				Else
					Exit
				EndIf
			End
		EndIf
	Else
		lRetorno := .F.
	EndIf

Return(lRetorno)

/*{Protheus.doc} OGA290Rhvi
(Função que executa executa o filtro de construção de regras HVI da Grid N78)
@type function
@author marcelo.wesan
@since 14/08/2017
@version 1.0
@param 
@return ${return}
*/
Function OGA290Rhvi()    
	Local aCampos 	:= {}
	Local aMostra 	:= {}
	Local aOper   	:= {}
	Local aSepara 	:= {}
	Local aSepCam	:= {}
	Local cExpFil 	:= ""
	Local cExpFi2 	:= ""
	Local lDifere   := .F.
	Local nTamDes 	:= ""
	Local nTamReg 	:= ""
	Local nF      	:= 0
	Local nX      	:= 0
	Local nY      	:= 0	
	Local oField  	:= FWModelActive()	
	Local oFlN78	:= oField:GetModel( "N78HVI" )
	Local oView	 	:= __oViewNJR

	Private _lOkHvi	:= .F.

	//-Array das operações do filtro
	aAdd(aOper,{'=='	,STR0140})	//Igual a
	aAdd(aOper,{'!='	,STR0141})	//Diferente de
	aAdd(aOper,{' < '	,STR0142})	//Menor que
	aAdd(aOper,{' > '	,STR0143})	//Maior que
	aAdd(aOper,{'<='	,STR0144})	//Menor ou igual a
	aAdd(aOper,{'>='	,STR0145})	//Maior ou igual a
	aAdd(aOper,{'.AND.'	,STR0146})	// E
	aAdd(aOper,{'.OR.'	,STR0147})	// OU

	//-Array dos campos do filtro
	aAdd(aCampos,"DX7_MIC")
	aAdd(aCampos,"DX7_RES")
	aAdd(aCampos,"DX7_FIBRA")
	aAdd(aCampos,"DX7_UI")
	aAdd(aCampos,"DX7_SFI")
	aAdd(aCampos,"DX7_ELONG")
	aAdd(aCampos,"DX7_LEAF")
	aAdd(aCampos,"DX7_AREA")
	aAdd(aCampos,"DX7_CSP") 
	aAdd(aCampos,"DX7_CG")
	aAdd(aCampos,"DX7_MAISB")
	aAdd(aCampos,"DX7_RD")
	aAdd(aCampos,"DX7_COUNT")
	aAdd(aCampos,"DX7_UHM")
	aAdd(aCampos,"DX7_SCI")

	DO CASE 
	
		CASE ( "N78_HVIREG" $ Readvar() )
		cExpFil := oField:GetModel("N78HVI"):GetValue("N78_HVICMP")
		nTamDes := TamSX3("N78_HVIREG")[1]
		nTamReg := TamSX3("N78_HVICMP")[1]

		CASE ( "N7F_REGRA" $ Readvar() )
		cExpFil := oField:GetModel("N7FUNICO"):GetValue("N7F_CAMPO")
		nTamDes := TamSX3("N7F_REGRA")[1]
		nTamReg := TamSX3("N7F_CAMPO")[1]      
	ENDCASE

	For nF := 1 to Len(aCampos) // Alimenta o Array aMostra com os campos da DX7  de HVI que possuem X3_USADO = .T.
		If X3USADO(aCampos[nF])
			aAdd(aMostra,aCampos[nF])
		EndIf 
	Next nF

	cExpFil := BuildExpr("DX7",/*[ oWnd ]*/ ,ALLTRIM(cExpFil),/*[ lTopFilter ]*/,{||OGA290BOK()},/*[ oDlg ]*/,/*[ aUsado ]*/aMostra,STR0139,/*[ nRow ]*/,/*[ nCol ]*/,/*aCampos*/,/*[ lVisibleTopFilter ] */,.F.,)

	__cRet := cExpFil

	If __lValid .AND. AllTrim(__cNewVal) == AllTrim(cExpFil)
		__lValid 	:= .F.		
		__cRet 		:= AllTrim(__cOldVal) 
		__cNewVal	:= ""
		__lFiltr 	:= .T.
		_lOkHvi	:= .F.
		Return .T.
	ElseIf AllTrim(__cNewVal) == AllTrim(cExpFil)
		__cRet 		:= AllTrim(__cOldHvi)
		_lOkHvi 	:= .F.
		Return .T.	
	EndIf

	_lOkHvi := .F.

	__cCampo 	:= cExpFil
	cExpFi2 	:= __cCampo

	//--Separa a variavel com o retorno do filtro
	//--Para tratamento se regra agrupa ou não
	aSepara := Separa(cExpFil," ")

	//--Varre os campos do filtro
	For nX := 1 to Len(aMostra)
		//--Varre os campos para separar os campos de valores
		For nY := 1 To Len(aSepara) 
			aSepara[nY] := StrTran(aSepara[ny],"(",'',,)
			If aSepara[ny] == aMostra[nx]
				//--Adiciona somente os campos que contem no array aMostra
				Aadd(aSepCam , aSepara[ny]) 
			EndIf 
		Next nY
	Next nX
	//--Varre os campos da regra
	For nX := 1 To Len(aSepCam)
		//--Se for ultimo do array
		If nx+1 > Len(aSepCam)
			If aSepCam[nx] != aSepCam[nx]
				//--variavel que identifica se existe na regra campos DX7 diferentes
				//--se SIm varivel é verdadeira ex: Dx7_Mic Dx7_Res
				lDifere := .T.
			EndIf  		
		Else
			If aSepCam[nx] != aSepCam[nx+1]
				//--variavel que identifica se existe na regra campos DX7 diferentes
				//--se SIm varivel é verdadeira ex: Dx7_Mic Dx7_Res	 		
				lDifere := .T.
			EndIf 
		EndIf 
	Next nX

	//--variavel que identifica se existe na regra campos DX7 diferentes
	//--se SIm varivel é verdadeira ex: Dx7_Mic Dx7_Res
	If lDifere
		//Verifica na SX3 se o campo "N78_HVIAGR" é usado ou não
		If X3USADO("N78_HVIAGR")
			//--Altera o campo para SIM 
			oFlN78:SetValue("N78_HVIAGR", '1')	//SIM AGRUPA
			If !__lAutomato
                oView:Refresh("VIEW_HVIGRD") 		//Aplica o refresh na grid HVI
            EndIf
		EndIf
	Else 
		//Verifica na SX3 se o campo "N78_HVIAGR" é usado ou não
		//--Altera o campo para NAO 
		If X3USADO("N78_HVIAGR")
			oFlN78:SetValue("N78_HVIAGR", '2')	//NAO AGRUPA
			If !__lAutomato
                oView:Refresh("VIEW_HVIGRD") 		//Aplica o refresh na grid HVI
            EndIf
		EndIf	
	EndIf

	For nX := 1 to Len(aMostra)// Realiza o tratamento de replace nos campos da regra
		If .NOT. Empty(AGRTITULO(aMostra[nX]))
			cExpFi2 := StrTran(cExpFi2,aMostra[nX],AGRTITULO(aMostra[nX]),, )
		EndIf
	Next nX

	For nY :=  1 to Len(aOper)// Realiza o tratamento de replace nas operações da regra
		cExpFi2  := StrTran(cExpFi2,aOper[nY][1],aOper[nY][2] ,, )
	Next nY	

	If  nTamReg == nTamDes  // Valida se os campos N78_HVIREG e N78_HVICMP  possuem o mesmo tamanho
		If Len(cExpFi2) <= nTamReg // Valida se a regra cabe no campo N78_HVIREG 
			__cRet := cExpFi2
		Else
			__cRet := ""
			Help(" ",1,"OGA290RHVITAM ")//Regra possui tamanho maior que o campo N78_HVIREG!// Altere a regra ou o tamanho do campo N78_HVIREG!
			return .F.
		EndIf
	Else
		__cRet := ""
		Help(" ",1,"OGA290RHVITAC ")//Os campos N78_HVIREG e N78_HVICMP possuem tamanhos diferentes. // Favor igualar o tamanho dos campos N78_HVIREG e N78_HVICMP.
		return .F.
	EndIf	

	__lFiltr := .T.
Return .t.

/*{Protheus.doc} OGA290RetR
(Função que retorna a expressão montada no  filtro de regras HVI da Grid N78)
@type function
@author marcelo.wesan
@since 14/08/2017
@version 1.0
@param 
@return ${return}
*/
Function OGA290RetR()  

Return (__cRet)

/*{Protheus.doc} OGA290BOK
(Função executada no quinto parametro da função BuildExpr )
@type function
@author marcelo.wesan
@since 14/08/2017
@version 1.0
@param 
@return ${return}
*/

Function OGA290BOK() 

	_lOkHvi := .T.

Return 

/*{Protheus.doc} OGA290QDV
(Função que calcula a quantidade vinculada de Fardos - Executado pelo gatilho 
@type function
@author Daniel Maniglia A. Silva
@since 13/09/2017
@version 1.0
@param 
@return nQtdVic
*/

Function OGA290QDV()  

	Local cAliasQDV	 := GetNextAlias()
	Local cFiltro    := ""
	Local cSequen	:= N78->N78_SEQUEN
	Local cRetorno  := 0
	Local cCodCtr 	:= N78->N78_CODCTR
	cFiltro += " AND N87.N87_SEQUEN = '" + cSequen+"' " + ; 
	" AND N87.N87_CODCTR = '" + cCodCtr+"' " + ; 
	" AND DXP.DXP_CODCTP = '" + cCodCtr+"' "
	cFiltro := "%" + cFiltro + "%" 


	//monta a query de busca da quantidade de fardos vinculados (N87)
	BeginSql Alias cAliasQDV

	SELECT SUM(DXI.DXI_PSLIQU) as DXI_PSLIQU
	FROM %Table:N87% N87 
	INNER JOIN %Table:DXI% DXI ON  DXI.DXI_SAFRA  = N87.N87_SAFRA
	AND DXI.DXI_ETIQ   = N87.N87_ETIQ
	AND DXI.%notDel%
	INNER JOIN %Table:DXD% DXD ON  DXI.DXI_FILIAL  = DXD.DXD_FILIAL
	AND DXI.DXI_SAFRA   = DXD.DXD_SAFRA
	AND DXI.DXI_BLOCO   = DXD.DXD_CODIGO
	AND DXD.%notDel%
	INNER JOIN %Table:DXQ% DXQ ON  DXQ.DXQ_FILORG  = DXD.DXD_FILIAL 
	AND DXQ.DXQ_BLOCO   = DXD.DXD_CODIGO
	AND DXQ.DXQ_CODRES  = DXI.DXI_CODRES
	AND DXQ.%notDel%  
	INNER JOIN %Table:DXP% DXP ON  DXP.DXP_CODIGO  = DXQ.DXQ_CODRES
	AND DXP.DXP_FILIAL  = DXQ.DXQ_FILIAL
	AND DXP.%notDel%       
	WHERE N87.%notDel%
	%exp:cFiltro% 
	EndSQL


	DbselectArea( cAliasQDV )
	DbGoTop()

	While ( cAliasQDV )->( !Eof() )
		cRetorno := (cAliasQDV)->DXI_PSLIQU
		(cAliasQDV)->(dbSkip())
	EndDo

	(cAliasQDV)->(dbCloseArea())	

return cRetorno

/*{Protheus.doc} OGA290QAV
(Função que calcula a quantidade a vincular dos fardos - Executado pelo gatilho 
@type function
@author Daniel Maniglia A. Silva
@since 13/09/2017
@version 1.0
@param 
@return nQtdAvi
*/
Function OGA290QAV(cChamada) 
	Local nOutPer	:= 0 
	Local cRetorno  := 0
	Local nQtdVin	:= 0 
	Local cTipReg 	:= ''
	Local nOutCod   := ''
	Local oModel    := FWModelActive()
	Local oModelN78O := oModel:GetModel( "N78OUTROS" )


	If cChamada = 'G' //gatilho 
		nOutPer := M->N78_OUTPER
		nOutCod := oModelN78O:GetValue("N78_OUTCOD")
		cTipReg := GetDataSql("SELECT N7K_VINCUL FROM " + RetSqlName("N7K") +" N7K WHERE N7K_FILIAL = '" + FWxFilial( "N7K" ) + "'" +  " AND N7K_CODIGO = '" + nOutCod + "'")
	Else // MODEL_FIELD_INIT
		nOutPer := N78->N78_OUTPER
		cTipReg := GetDataSql("SELECT N7K_VINCUL FROM " + RetSqlName("N7K") +" N7K WHERE N7K_FILIAL = '" + FWxFilial( "N7K" ) + "'" +  " AND N7K_CODIGO = '" + N78->N78_OUTCOD + "'") 
	EndIF 

	If cTipReg == '2' //se a regra vincula blocos 
		nQtdVin	:= OGA290QDV() //busca a quantidade já vinculada
		cRetorno := ((nOutPer * NJR->NJR_QTDINI)/100) - nQtdVin
		If cChamada = 'G'
		   cRetorno := ((nOutPer * NJR->NJR_QTDINI)/100) - oModelN78O:GetValue("N78_QTDVDA ")
		EndIf
	EndIf 	

	If cRetorno < 0 
		cRetorno := 0 
	EndIF 	

return cRetorno

/** {Protheus.doc} OGA290WHN
Função para dicionário [SX3] - when para excluir o campo NNF_FATCON quando o tipo da comissão for diferente de pontos.
Essa função esta sendo utilizada no when do campo NNF_MODCOM

@return:    lRetorno - .T. verdadeiro ou .F. falso
@author:    Ana Laura Olegini
@since:     03/10/2017
@Uso:       OGA290 - Contrato de Venda
*/
Function OGA290WHN(oModelNNF, cCampo, xNewValue, xOldValue) 
	Local oModel	:= oModelNNF:GetModel()
	Local oNNF		:= oModel:GetModel( "NNFUNICO" )
	Local lRetorno  := .T.

	If cCampo == "NNF_MODCOM" .AND. xNewValue <> '3'
		oNNF:LoadValue("NNF_FATCON" , 0)
	EndIf
Return(lRetorno)

/*{Protheus.doc} OGA290NGCW
Bloqueio de Edição de Campos do Contrato. Chamado tambem via campos SX3
@author jean.schulze
@since 05/10/2017
@version undefined
@type function
*/
Function OGA290NGCW() 
	Local lret    		:= .t.
	Local oModel  		:= FWModelActive()
	Local cCodCtr 		:= nil
	Local nQtdPre 		:= 0
	Local nOperation 	:= oModel:GetOperation()

	If ( !(IsInCallStack("OGX700CTR") .OR. IsInCallStack("OGX700ACTR")) ) .and. !oModel:IsCopy()
		If TYPE("M->NJR_CODNGC") <> "U" //verifica se está em memória
			lret := empty(M->NJR_CODNGC) .and. empty(M->NJR_VERSAO)  
			nQtdPre := M->( NJR_AUTENT ) + M->( NJR_AUTSAI )
		ElseIf Valtype(oModel) == "O" //objeto
			if oModel:GetId() $ "OGA260|OGA270|OGA280|OGA290" 
				if nOperation == MODEL_OPERATION_UPDATE
					lret := .T.
				else
					lret := (TYPE("M->NJR_CODNGC") <> "U"  .AND. empty(oModel:GetValue("NJRUNICO","NJR_CODNGC")) .and. empty(oModel:GetValue("NJRUNICO","NJR_VERSAO")))
					nQtdPre := oModel:GetValue("NJRUNICO","NJR_AUTENT") + oModel:GetValue("NJRUNICO","NJR_AUTSAI")
				endif
			ElseIf oModel:GetId() == "OGA335" //aditações e subtrações
				cCodCtr := oModel:GetValue("NNWUNICO","NNW_CODCTR") 
				lret := (empty(Posicione("NJR", 1, FwXFilial("NJR") +  cCodCtr, "NJR_CODNGC") ) .and. empty(Posicione("NJR", 1, FwXFilial("NJR") + cCodCtr, "NJR_VERSAO")))
				nQtdPre := NJR->( NJR_AUTENT ) + NJR->( NJR_AUTSAI ) //o posicione acima ja posicionou na NJR
			EndIf	
		EndIf
		
		If lret .and. nOperation != MODEL_OPERATION_INSERT .and. "NJR_QTDINI" $ READVAR() .and. (NJR->( NJR_STATUS ) <> "P" .Or. nQtdPre > 0)
			lRet := .F. //não pode alterar qtdini do contrato se status diferente de previsto ou ja tenha sido confirmado o contrato alguma vez
		EndIf 	
	EndIf	
	
return lret 

/** {Protheus.doc} fVldNJR1
Função para tornar obrigatórios determinados campos, quando o tipo de contrato for
MERCADO EXTERNO (NJR_TIPMER == 2)

@return:    cMsg - Mensagem com as informações não preenchidas.
@author:    Janaina F B Duarte
@since:     04/10/2017
@Uso:       OGA290 - Contrato de Venda
*/
Static Function fVldNJR1()
	Local cMsg      := ""

	if Empty(NJR->NJR_CONDPA )
	 	if Empty(cMsg) 
	 		cMsg :=  STR0155 + _CRLF + _CRLF  //"Para contrato do tipo Mercado Externo, os seguintes campos são obrigatórios: "
	 	endIf
		cMsg := cMsg + "* " + STR0156 + _CRLF  //"Modalidade Pagamento Exportação"
	EndIf
	if Empty(NJR->NJR_INCOTE)
	 	if Empty(cMsg) 
	 		cMsg :=  STR0155 + _CRLF + _CRLF  //"Para contrato do tipo Mercado Externo, os seguintes campos são obrigatórios: "
	 	endIf
		cMsg := cMsg + "* " + STR0157 + _CRLF  //"INCOTERM"
	endIf
	if Empty(NJR->NJR_VIA)
	 	if Empty(cMsg) 
	 		cMsg :=  STR0155 + _CRLF + _CRLF  //"Para contrato do tipo Mercado Externo, os seguintes campos são obrigatórios: "
	 	endIf
		cMsg := cMsg + "* " + STR0158 + _CRLF //"Via de Transporte"
	endif
	if Empty(NJR->NJR_CODEMB) 	
	 	if Empty(cMsg) 
	 		cMsg :=  STR0155 + _CRLF + _CRLF  //"Para contrato do tipo Mercado Externo, os seguintes campos são obrigatórios: "
	 	endIf
		cMsg := cMsg + "* " + STR0159 + _CRLF //"Embalagem"
	endIf
		
Return cMsg

/*{Protheus.doc} OGA290VNGC
//Consulta de negociação por contrato.
@author roney.maia
@since 11/10/2017
@version 6
@param cCodNgc, characters, Código do negócio
@type function
/*/
Function OGA290VNGC(cCodNgc) 
	Local oModel := FwModelActive()
	Local aAreaN79	:= N79->(GetArea())
	Local nRet	:= 0

	If Valtype(oModel) == "O"
		cCodNgc := oModel:GetModel("NJRUNICO"):GetValue("NJR_CODNGC")
	Else
		cCodNgc := NJR->NJR_CODNGC
	EndIf	

	If .NOT. Empty(cCodNgc) // Se o contrato possui um novo negócio
		dbSelectArea('N79')
		dbSetOrder(1)
		If N79->(dbSeek(FwXFilial('N79') + cCodNgc)) 
			nRet := FWExecView( , 'OGA700', MODEL_OPERATION_VIEW, , {|| .T.}, , 20 / 100) // Abre a rotina de Negociação em modo de visualização
		Endif
	Else
		Help(" ",1,"OGA290NGC00001") // O contrato informado não possui um novo negócio
	EndIf

	RestArea(aAreaN79)

Return

/** {Protheus.doc} OGA290VLMB
Descrição:  Validação do campo MES/BOLSA REFERENCIA
@param:     Nil
@author:    Marcelo Ferrari
@since:     31/10/2016
@Uso:       OGA290 
*/
Function OGA290VLMB(cOrig)
	
	Local aArea		:= GetArea()
	Local lRet      := .F.
	Local oModel    := FwModelActive()
	Local oModelNNY	:= oModel:GetModel("NNYUNICO")
	Local cMesBol   := oModelNNY:GetValue("NNY_VMESAN")
	Local cVMesBol  := oModelNNY:GetValue("NNY_MESANO")
	Local dIniCad   := oModelNNY:GetValue("NNY_DATINI")
	Local cMesEmb   := oModelNNY:GetValue("NNY_MESEMB")
	Local dFimCad   := oModelNNY:GetValue("NNY_DATFIM")
	Local cMesEmbN	:= ""

	If cOrig == 1
	   If !Empty(cMesBol)
	      lRet := cMesBol >= AnoMes(dIniCad) 
	   EndIf
	ElseIf cOrig == 3 
		If !Empty(cMesEmb)
			cMesEmbN := AGRMesAno(cMesEmb, 1)
			If Alltrim(cMesEmbN) == "000000" .OR. !(cMesEmbN == cMesEmb)
				Help(" ", 1, "OGA290NNY00001") //"AJUDA #"A data informada deve seguir o modelo de mês/ano. Exemplo: mm/aaaa."
				RestArea(aArea)
				Return .F.
			ElseIf AGRMesAno(cMesEmbN, 2) < AnoMes(dFimCad)
				Help(" ", 1, "OGA290NNY00002") //"AJUDA #"O mês de embarque informado é inferior a data final da cadência."
				RestArea(aArea)
				Return .F.
			EndIf
		EndIf
		lRet := .T.	
	Else
	   If !Empty(cVMesBol)
	      cVMesBol := AGRMesAno(cVMesBol, 0)
	      lRet := cVMesBol >= AnoMes(dIniCad) 
	   EndIf
	EndIf
	
	If !lRet
	   Help(" ",1,"NNY_VMESAN") //Help do campo N7A_VMESAN => Campo para informar o mês/ano para bolsa. Informar nos formatos mmm/aaaa ou mm/aaaa.
	EndIf
	
	RestArea(aArea)
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
	
	//HELP: Operação não permitida.
	If !(IsInCallStack("OGX700CTR") .OR. IsInCallStack("OGX700ACTR") .OR. lIsTakeUp) .AND. __lnewNeg
		
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

/** {Protheus.doc} OGA290BSC()
Função criada para buscar o nome da entidade e nome da loja 
é chamada nos InitPadrão dos campos N9A_NOMENT,N9A_NMLENT,N9A_NMEENT,N9A_NLJENT quando não for INCLUSÃO
@param 
@param 
@param 
@since 19/01/2017
@author felipe.mendes
@version 1.0
*/
Function OGA290BSC(cCpoOrigem)
	Local cRet := ""
	Local oModel	:= FwModelActive()
	Local oNJR      := Nil
	Local oNNY      := Nil
	Local cCodCli	:= ""
	Local cLojCli	:= ""
	Local cCodFor	:= ""
	Local cLojFor	:= ""

	// Verificação de modelo ativo e se o modelo é proveniente da rotina OGA290, necessário caso existir 2 modelos ativos
	If oModel != Nil .AND. oModel:IsActive() .AND. ( oModel:GetId() == "OGA290" .or. oModel:GetId() == "OGA270" .OR. oModel:GetId() == 'OGA280' ) 
	
		oNJR      := oModel:GetModel( "NJRUNICO" )	
		oNNY      := oModel:GetModel( "NNYUNICO" )
		
		cTipoCtr  := oNJR:GetValue("NJR_TIPO")
		
		If cTipoCtr == '4'
			cCodFor	:= POSICIONE('NJ0',1,FWXFILIAL('NJ0')+oNJR:GetValue("NJR_CODENT")+oNJR:GetValue("NJR_LOJENT"),'NJ0_CODFOR') 
			cLojFor	:= POSICIONE('NJ0',1,FWXFILIAL('NJ0')+oNJR:GetValue("NJR_CODENT")+oNJR:GetValue("NJR_LOJENT"),'NJ0_LOJFOR')
		Else
			cCodCli	:= POSICIONE('NJ0',1,FWXFILIAL('NJ0')+oNJR:GetValue("NJR_CODENT")+oNJR:GetValue("NJR_LOJENT"),'NJ0_CODCLI') 
			cLojCli	:= POSICIONE('NJ0',1,FWXFILIAL('NJ0')+oNJR:GetValue("NJR_CODENT")+oNJR:GetValue("NJR_LOJENT"),'NJ0_LOJCLI') 
		EndIf
		
		If cCpoOrigem == "N9A_NOMENT"  //Nome Entidade
			
			If !Empty(N9A->N9A_CODENT) .AND. !INCLUI// Se não for criação de uma linha nova
				cRet := POSICIONE('NJ0' , 1 , XFILIAL('NJ0') + N9A->N9A_CODENT + N9A->N9A_LOJENT , 'NJ0_NOME' )
			Else 
				cRet := POSICIONE('NJ0' , 1 , XFILIAL('NJ0') + oNJR:GetValue("NJR_CODENT") + oNJR:GetValue("NJR_LOJENT") , 'NJ0_NOME' )
			EndIf
			
		ElseIf cCpoOrigem == "N9A_NMLENT" //Nome Loja Entidade
		
			If !Empty(N9A->N9A_LOJENT)  .AND. !INCLUI// Se não for criação de uma linha nova
				cRet := POSICIONE('NJ0' , 1 , XFILIAL('NJ0') + N9A->N9A_CODENT + N9A->N9A_LOJENT , 'NJ0_NOMLOJ' )
			Else 
				cRet := POSICIONE('NJ0' , 1 , XFILIAL('NJ0') + oNJR:GetValue("NJR_CODENT") + oNJR:GetValue("NJR_LOJENT") , 'NJ0_NOMLOJ' )
			EndIf
		
		ElseIf cCpoOrigem == "N9A_NMEENT" // Nome Entidade Entrega
		
			If !Empty(N9A->N9A_ENTENT)  .AND. !INCLUI// Se não for criação de uma linha nova
				cRet := POSICIONE('NJ0' , 1 , XFILIAL('NJ0') + N9A->N9A_ENTENT + N9A->N9A_LJEENT ,'NJ0_NOME') 
			Else 
				cRet := POSICIONE('NJ0' , 1 , XFILIAL('NJ0') + oNNY:GetValue("NNY_ENTDES") + oNNY:GetValue("NNY_LOJDES") , 'NJ0_NOME' )
			EndIf
			
		ElseIf cCpoOrigem == "N9A_NLJENT" // Nome Loja Entidade Entrega
			
			If !Empty(N9A->N9A_LJEENT)  .AND. !INCLUI// Se não for criação de uma linha nova
				cRet := POSICIONE('NJ0' , 1 , XFILIAL('NJ0') + N9A->N9A_ENTENT + N9A->N9A_LJEENT , 'NJ0_NOMLOJ' )
			Else 
				cRet := POSICIONE('NJ0' , 1 , XFILIAL('NJ0') + oNNY:GetValue("NNY_ENTDES") + oNNY:GetValue("NNY_LOJDES") , 'NJ0_NOMLOJ' )
			EndIf
			
		ElseIf cCpoOrigem == "N9A_DESFIN" // DESCRIÇÃO DA FINALIDADE
			
			If !Empty(N9A->N9A_CODFIN)  .AND. !INCLUI// Se não for criação de uma linha nova
				cRet := POSICIONE('N8A' , 1 , XFILIAL('N8A') + N9A->N9A_CODFIN , 'N8A_DESFIN' )
			Else 
				cRet := POSICIONE('N8A' , 1 , XFILIAL('N8A') + oNJR:GetValue("NJR_CODFIN"), 'N8A_DESFIN' )
			EndIf		
		
		ElseIf cCpoOrigem == "N9A_NATURE"
			
			If cTipoCtr == '4'
				cRet := Posicione("SA2",1,FWXFILIAL("SA2")+cCodFor+cLojFor,"A2_NATUREZ")
			Else
				cRet := Posicione("SA1",1,FWXFILIAL("SA1")+cCodCli+cLojCli,"A1_NATUREZ")
			EndIf
		
		ElseIf cCpoOrigem == "N9A_CODENT"  //CHAMADO VIA FONTE, APOS RELEASE 12.1.027 ESTA AJUSTADO NO DICIONARIO
			cRet := oNJR:GetValue("NJR_CODENT")
		ElseIf cCpoOrigem == "N9A_LOJENT"   //CHAMADO VIA FONTE, APOS RELEASE 12.1.027 ESTA AJUSTADO NO DICIONARIO
			cRet := oNJR:GetValue("NJR_LOJENT")
		ElseIf cCpoOrigem == "N9A_CODFIN"   //CHAMADO VIA FONTE, APOS RELEASE 12.1.027 ESTA AJUSTADO NO DICIONARIO
			cRet := oNJR:GetValue("NJR_CODFIN") 
		ElseIf cCpoOrigem == "N9A_TIPCLI"  //CHAMADO VIA FONTE, APOS RELEASE 12.1.027 ESTA AJUSTADO NO DICIONARIO
			cRet := oNJR:GetValue("NJR_TIPOCL") 
		EndIf
		
	EndIf

Return cRet

/** {Protheus.doc} OG290VQN9A
Descrição:  Valid do campo N9A_QUANT 
@param:     Nil
@author:   Tamyris Ganzenmueller
@since:     09/01/2017 
@Uso:       OGA290 
*/
Function OG290VQN9A()
	Local lRet := .T.
	Local oModel	:= FwModelActive()
	Local oN9A      := oModel:GetModel( "N9AUNICO" )
	
	//HELP: Quantidade informada inválida 
	//SOLUÇÃO: Quantidade deve ser maior que a Quantidade Instruída ou Quantidade NF.
	If oN9A:GetValue("N9A_QUANT") < oN9A:GetValue("N9A_QTDINS") .Or. oN9A:GetValue("N9A_QUANT") < oN9A:GetValue("N9A_QTDNF")  
		LRet := .F.
		Help(" ", 1, "OGA290QTRFIS")
	EndIf 
	
Return lRet


/** {Protheus.doc} OGA290QIRF()
Função criada para inserir valor inicial nos campo N9A_QUANT,N9A_SDOINS E N9A_SDONF 
Esta função é chamada pelo inicializador padrão do campo(X3_RELACAO)
@param: cCpoOrigem - nome do campo
@since: 16/02/2018
@author: claudineia.reinert
@Uso:       OGA290 e OGA270
@version 1.0
*/
Function OGA290QIRF(cCpoOrigem)
	Local nRet := 0
	Local oModel	:= FwModelActive()
	Local oN9A      := oModel:GetModel( "N9AUNICO" )
	
	If cCpoOrigem == 'N9A_QUANT' .or. cCpoOrigem == 'N9A_SDOINS' .or. cCpoOrigem == 'N9A_SDONF'  //CAMPO QUANTIDADE DA REGRA FISCAL OU CAMPO SALDO INSTRUIDO OU CAMPO SALDO NF
		If oN9A:Length() = 0 //ainda não foi inserido a linha na N9A, será a primeira linha
			nRet :=  oModel:GetModel("NNYUNICO"):GetValue('NNY_QTDINT')
		EndIf
	EndIf

Return nRet


/*/{Protheus.doc} OGA290F4()
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
Static Function OGA290F4()
	Local oModel    := Nil
	Local oModelNJR := Nil
	Local cCodPro   := ""
	Local aOldArea  := GetArea()
	
	If Empty(FWModelActive())
		cCodPro := NJR->NJR_CODPRO
	Else
		oModel    := FwModelActive()
		oModelNJR := oModel:GetModel("NJRUNICO")
		cCodPro   := oModelNJR:GetValue( "NJR_CODPRO" )
	EndIf
	
	OGAC120( cCodPro )
	
	RestArea(aOldArea)

Return .T.


/*{Protheus.doc} OGA290VLBA
Retorna os valor do contrato aFixar
@author jean.schulze
@since 20/04/2018
@version 1.0
@return ${return}, ${return_description}
@param oModelNJR, object, descricao
@type function
*/
Function OGA290VLBA(oModelNJR)
	Local nPrecoBase := 0
	
	If !Empty(oModelNJR:GetValue("NJR_CODIDX"))
		If NK0->(DbSeek(xFilial("NK0") + oModelNJR:GetValue("NJR_CODIDX") ))
			nPrecoBase := AgrGetInd( NK0->NK0_INDICE,NK0->NK0_TPCOTA, dDataBase ) //tratar para uso de indice de tabela -  necessidade de usar fardo a fardo
			nPrecoBase := OGX700UMVL(nPrecoBase, NK0->NK0_UM1PRO,oModelNJR:GetValue("NJR_UMPRC"),oModelNJR:GetValue("NJR_CODPRO"))	
		EndIF
	EndIf		
			
	/* ---- ASSUME VALOR BASE DO CONTRATO ---- */
	If nPrecoBase == 0
		nPrecoBase := oModelNJR:GetValue("NJR_VLRBAS")
	EndIf
	
return nPrecoBase

/*/{Protheus.doc} OGA290320
//Estabelece as permissões do usuário para as permissões definidas no OGA320
@author thiago.avila
@since 11/09/2018
@version P12
@type function
/*/
Function OGA290320()
	SetFunName("OGA320")
	OGA320(NJR->NJR_CODCTR,NJR->NJR_FILIAL)
	SetFunName("OGA290")
Return .T.

/*/{Protheus.doc} OGA290NAT
//Validação do campo Natureza
@author marcos.wagner
@since 11/09/2018
@version P12
@type function
/*/
Function OGA290NAT()
Local aOldArea := SED->(GetArea())
Local lRet := .t.

If !Vazio()
	If ExistCpo("SED", M->N9A_NATURE)
		If !FinVldNat( .F., M->N9A_NATURE,2)
			lRet := .f.
		EndIf     
	Else
		cProblema := _CRLF+_CRLF + STR0215 //"Não existe registro relacionado a esse código!"
		cSolucao  := STR0216 + _CRLF //"1) Informe um código que exista no cadastro "
		cSolucao  += STR0217 + _CRLF //"2)Efetue o cadastro no programa de manutenção do respectivo cadastro "
		cSolucao  += STR0218 //"3) Escolha um registro válido "

		Help( ,,STR0031,, cProblema, 1, 0,,,,,,{cSolucao} ) //"AJUDA"

		lRet := .f.
	EndIf
EndIf

RestArea(aOldArea)

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


/*/{Protheus.doc} OGA290VFIX()
Validação do campo N84_REFPRF - Dt.Ref.Prev.
@type  Function
@author marcos.wagner
@since 22/02/2019
@version 1.0
@param oModel, Objeto, Modelo da view
@return .T./.F., Logical, 
/*/

Function OGA290VFIX()
	Local lRet   := .t.
	Local oModel := FwModelActive()
	Local oN84	 := nil

    If oModel:GetID() == "OGA290"
        oN84		:= oModel:GetModel( "N84UNICO" )

        If oN84:GetValue("N84_REFPRF") == "4" .AND. oModel:GetValue("NJRUNICO","NJR_TIPFIX") == "1"
        	cProblema := STR0234 //"Para contrato do tipo 'Fixo' a coluna 'Dt.Ref.Prev.' não pode ser igual a 'Dt. Lim. Fixação'!"
        	cSolucao  := STR0235 // "Deverá ser trocado o valor da coluna 'Dt.Ref.Prev.'."
        	oModel:SetErrorMessage( , , oModel:GetId() , "", "", cProblema,cSolucao, "", "")
            lRet := .f.
        EndIf
    EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} OGA290DPRC
Mostra tela de consulta de precos por fixacao
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function OGA290DPRC(oView, oButton)

	 Local oModel 	    := oView:GetModel()
	 Local oModelNJR	:= oModel:GetModel("NJRUNICO") 
	 Local oModelNNY    := oModel:GetModel("NNYUNICO") 
	 Local oModelN9A	:= oModel:GetModel("N9AUNICO")
	
	 Local cCodClient := ""
	 Local cCodLoja   := ""
	 Local nLineModel := oModelN9A:GetLine()
	 Local aAreaNJ0   := NJ0->(GetArea())

     If AGRTPALGOD(oModelNJR:GetValue("NJR_CODPRO")) 
        HELP(' ',1,STR0031 ,,STR0252,2,0,,,,,,) //Atenção  //O demonstrativo está disponível apenas para produtos diferente de Algodão.
        Return
    EndIf
	
	 //busca as informações de Cliente - verifciar se não vai ser da NNY ou N9A
	 DbSelectArea("NJ0")
	 DbSetOrder(1)
	 If DbSeek(xFilial("NJ0")+oModelN9A:GetValue("N9A_CODENT")+oModelN9A:GetValue("N9A_LOJENT"))
	 	If NJR->NJR_TIPO == "1" //Compras - fornecedor
	 		cCodClient     := NJ0->(NJ0_CODFOR)
			cCodLoja       := NJ0->(NJ0_LOJFOR)				
		else //vendas - cliente
			cCodClient     := NJ0->(NJ0_CODCLI)
			cCodLoja       := NJ0->(NJ0_LOJCLI)				
		endif
	EndIf	

    MsgRun(STR0253,STR0254, {|| ;   //"Processando... //Demonstrativo de Preços"
        OGX055SIMU("R",  ;
                oModelNJR:GetValue("NJR_FILIAL"), ;
                oModelNJR:GetValue("NJR_CODCTR"), ;
                oModelNNY:GetValue("NNY_ITEM"), ;
                oModelN9A:GetValue("N9A_SEQPRI",nLineModel), ;
                1, ;
                oModelN9A:GetValue("N9A_TES",nLineModel) , ;
                oModelN9A:GetValue("N9A_NATURE",nLineModel), ;
                oModelN9A:GetValue("N9A_TIPCLI",nLineModel) , ;
                cCodClient, ;
                cCodLoja, ;
                oModelN9A:GetValue("N9A_FILORG",nLineModel) , ;
                oModelNJR:GetValue("NJR_CODNGC"), ;
                oModelNJR:GetValue("NJR_VERSAO"), ;
                oModelNJR:GetValue("NJR_TIPMER"), ;
                oModelNJR:GetValue("NJR_MOEDAR"), ;
                oModelNJR:GetValue("NJR_DIASR"),  ;
                oModelNJR:GetValue("NJR_UMPRC"), ;
                oModelNJR:GetValue("NJR_UM1PRO"),  ;
                oModelNJR:GetValue("NJR_CODPRO"), ;
                oModelNJR:GetValue("NJR_MOEDA"),  ;
                oModelN9A:GetValue("N9A_DATINI",nLineModel) ,;
                oModelN9A:GetValue("N9A_DATFIM",nLineModel) ,;
                oModelN9A:GetValue("N9A_VLRTAX",nLineModel) );								
            })				

	RestArea(aAreaNJ0)	

Return

/*{Protheus.doc} OG290EMB
Retorno do gatilho NJR_CODPRO > NJR_TIPEMB

@author  francisco.nunes
@since   22/03/2019
@version 1.0
*/
Function OG290EMB(cTipMerc, cCodPro)

	Local cEmb := ""
	
	If cTipMerc == "1"
	
		DbSelectArea("SB5")
		SB5->(DbSetOrder(1)) // B5_FILIAL+B5_COD
		If SB5->(DbSeek(FWxFilial("SB5")+cCodPro))
			cEmb := SB5->B5_EMB1
		EndIf
		SB5->(DbCloseArea())
	Else
		
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
		If SB1->(DbSeek(FWxFilial('SB1')+cCodPro))
			cEmb := SB1->B1_CODEMB
		EndIf		
		SB1->(DbCloseArea())
	EndIf	

Return cEmb

/*{Protheus.doc} OGX290POSV
//Função de validação acionada ao confirmar, engloba as validações
ao confirmar a alteração das regras fiscais.
@author roney.maia / Filipe Olegini
@since 23/03/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
*/
Static Function OGX290POSV()

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
				Help( , , "Validação Regra Fiscal", , " Não é permitido existir mais de uma Regra Fiscal sem codigo de TakeUp vinculado.", 1, 0 )  //erro de limite de quantidade
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
							cMsg := "Existem fardos vinculados a regra fiscal." + ": " + oModelN9A:GetValue("N9A_SEQPRI") + _CRLF // # "Existem fardos vinculados a regra fiscal."
							cMsg +=  "Para prosseguir com a exclusão será necessário desvincular os fardos." + _CRLF + _CRLF // # "Para prosseguir com a exclusão será necessário desvincular os fardos."
							lRet := .F.
						EndIf
						cMsg += "Filial"+ ": " + AllTrim(aFardVer[nX][1]) + ; // "Filial"
							"  " +  "Fardo" + ": " + AllTrim(aFardVer[nX][5]) + ; // "Fardo"
							"  " + "Safra" + ": " + AllTrim(aFardVer[nX][2]) + ; // Safra
							"  " + "Etiqueta" + ": " + AllTrim(aFardVer[nX][3]) + _CRLF // # Etiqueta
					Next nX
					
					If !lRet
						Aviso("Exclusão de Regras Fiscais", cMsg) // Apresenta tela de aviso // "Exclusão de Regras Fiscais"
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
					Help( , , "Ajuda", , "Existem quantidades vinculadas de preço para a regra fiscal deletada, favor verificar a quantidade vinculada a regra fiscal no programa de Precificação.", 1, 0 )  //erro de limite de quantidade
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
					Help( , , "Ajuda", , "Existem quantidades vinculadas de preço para a regra fiscal, favor verificar a quantidade vinculada a regra fiscal no programa de Precificação.", 1, 0 )  //erro de limite de quantidade
					Return .f.
				endif
			EndIf
						 
		EndIf
	Next nIt
	// ####################################################################################################################
	
	If !Empty(__aOGX290FR)
		cMsg :=  "Existem fardos sem vínculo de Take-Up." + _CRLF + _CRLF // # "Existem fardos sem vínculo de Take-Up."
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

		Aviso("Fardos sem vínculo de Take-Up", cMsg) // Apresenta tela de aviso // # "Fardos sem vínculo de Take-Up"
		
		//FwRestRows(aSaveRows)
	
	//	RestArea(aAreaNJR)
		Return .F.
	EndIf
	

	//FwRestRows(aSaveRows)
	RestArea(aArea)

Return lRet

/*{Protheus.doc} OGX290SF
//Função acionada ao clicar no botão de selecionar fardos.
@author roney.maia
@since 20/03/2018
@version 1.0
@return ${return}, ${return_description}
@param oView, object, View
@type function
*/
Function OGX290SF(oView)

	Local aArea			:= GetArea()
	Local oModel		:= oView:GetModel()
	Local oModelNJR		:= oModel:GetModel("NJRUNICO")
	Local oModelN7H		:= oModel:GetModel("N7HUNICO")
	Local oModelNNY		:= oModel:GetModel("NNYUNICO")
	Local oModelN9A		:= oModel:GetModel("N9AUNICO")
	//Local oModelN9AR	:= oModel:GetModel("N9AUNICORESUM")
	Local oModelN9D		:= oModel:GetModel("N9DUNICO")
	Local oModelN7E 	:= oModel:GetModel("N7EUNICO")
	Local aFieldsN9D	:= oModelN9D:GetStruct():GetFields()
	Local aFilHVI		:= {}
	Local aFardos		:= {}
	Local cSafra		:= oModelNJR:GetValue("NJR_CODSAF")
	Local cCodCtr		:= oModelNJR:GetValue("NJR_CODCTR")
	Local cFilCtr		:= oModelNJR:GetValue("NJR_FILIAL")
	Local nTolen		:= oModelNJR:GetValue("NJR_TOLENT")
	Local nQtPrevEn		:= oModelNNY:GetValue("NNY_QTDINT")
	Local cCdPrevEn		:= oModelNNY:GetValue("NNY_ITEM")
	Local nQtdUsada		:= oModelNNY:GetValue("NNY_TKPQTD")
	Local cCodTkp		:= oModelN9A:GetValue("N9A_TAKEUP") // Seleção de fardos com base no take-up
	Local cCodRom		:= oModelN9A:GetValue("N9A_CODROM") // Seleção de fardos com base no take-up
	Local cLinRF		:= oModelN9A:GetLine() // linha de referencia caso desposicionamento
	Local nIt			:= 0
	Local nX			:= 0
	Local nY			:= 0
	Local cFiltDXI		:= "" 
	Local cFiltN9D		:= ""
	Local cTipsAce		:= oModelNJR:GetValue("NJR_TIPALG")  // String de tipos aceitaveis iniciando com o tipo padrão
	Local aOptions		:= {}
	Local nPos			:= 0
	Local aTransp		:= {}
	Local aIEFar		:= {}
	Local aFardsDel		:= {}
	Local nPosRf		:= 0
	Local cOGX290F	    := oModelN9A:GetValue("N9A_FILORG") 

	If !(_lAlgOG290 := AGRTPALGOD(oModelNJR:GetValue("NJR_CODPRO"))) 
		return
	EndIf
	// ########## PRÉ - Validações para seleção de fardos ###########################
	If !Empty(cCodRom) // Não pode selecionar fardos de uma regra fiscal com global futura
		Help('',1, "OGX290GLOBALFT") // # A regra fiscal selecionada possue nota global futura. # Selecionar uma regra fiscal que não possua nota global futura.
		RestArea(aArea)
		Return .F.
	ElseIf Empty(cCodTkp)
		Help('',1, "OGX290CDTAKEUP") // # A regra fiscal selecionada não possui um código de Take-Up. # Informar um código de Take-Up para a regra fiscal selecionada.
		RestArea(aArea)
		Return .F.
    ElseIf oModelN9A:IsDeleted() // Seleção de fardos permitida somente para regras fiscais que não estão deletadas
        Help('',1, "OGX290DELSEL") // # A regra fiscal selecionada não possui um código de Take-Up. # Informar um código de Take-Up para a regra fiscal selecionada.
		RestArea(aArea)
		Return .F.
	EndIf

	// ########## Tratamento de tela e filtros para a seleção de fardos #############
	aOptions	:= {{'_cCodCtr', cCodCtr}} 

	cFiltDXI	:= "DXI_SAFRA = '" + AllTrim(cSafra) + "'"

	// Filtro para fardos com take-up, para o contrato e filial de origem do mesmo, e filtrando tambem pelo codigo do take-up os fardos sem romaneio
	cFiltN9D	:= "N9D_TIPMOV = '02' AND N9D_CODCTR = '"+ AllTrim(cCodCtr) + "' AND N9D_FILORG = '" + cFilCtr + "' AND N9D_CODRES = '" + cCodTkp+ "'"
	cFiltN9D	+= " AND N9D_ITEETG = '" + cCdPrevEn + "' AND (" 

	// Compoe o filtro para selecionar os fardos somente de regras fiscais que não possuem nota global futura
	For nIt := 1 To oModelN9A:Length()
		oModelN9A:GoLine(nIt)
		If AllTrim(cOGX290F) == AllTrim(oModelN9A:GetValue("N9A_FILORG", nIt)) .AND. Empty(oModelN9A:GetValue("N9A_CODROM", nIt)) .AND. ;
			AllTrim(cCodTkp) == AllTrim(oModelN9A:GetValue("N9A_TAKEUP", nIt))

			cFiltN9D += " N9D_ITEREF = '" + oModelN9A:GetValue("N9A_SEQPRI", nIt) + "' OR"
			// Adiciona no array de filtro para fardos com instrução de embarque
			For nX := 1 To oModelN9D:Length()
				// Fardos que possuem instrução de embarque
				If !Empty(oModelN9D:GetValue("N9D_FARDO", nX)) .AND. oModelN9D:GetValue("N9D_DXIEMB", nX) == "1" 
					aAdd(aIEFar,  val(oModelN9D:GetValue("N9D_DXIREC", nX)))
				EndIf
			Next nX
		EndIf
	Next nIt

	oModelN9A:Goline(cLinRF) // Caso ocorrer desposicionamento da Regra fiscal, reposiciona a mesma

	cFiltN9D := SubStr(cFiltN9D, 1, Len(cFiltN9D) - 2) + ")"

	// ########## Montagem do array de tipos aceitaveis #############################
	For nIt := 1 To oModelN7E:Length()
		If !oModelN7E:IsDeleted(nIt) .AND. !Empty(oModelN7E:GetValue("N7E_TIPACE", nIt))
			cTipsAce += " OU " + oModelN7E:GetValue("N7E_TIPACE", nIt)
		EndIf
	Next nIt
	// ########## Montagem do array de filtros hvi ##################################
	For nIt := 1 To oModelN7H:Length()
		If !oModelN7H:IsDeleted(nIt) .AND. !Empty(oModelN7H:GetValue("N7H_CAMPO", nIt))
			aAdd(aFilHVI, {oModelN7H:GetValue("N7H_CAMPO", nIt), oModelN7H:GetValue("N7H_HVIDES", nIt), ;
							oModelN7H:GetValue("N7H_VLRINI", nIt), oModelN7H:GetValue("N7H_VLRFIM", nIt)})
		EndIf
	Next nIt

	// Verificação de linhas iniciais vazias sem fardo. para não impactar na seleção de fardos
	For nIt := 1 To oModelN9A:Length()
			oModelN9A:GoLine(nIt)
			If oModelN9D:Length() >= 1 .AND. !oModelN9D:IsDeleted(1) .AND. Empty(oModelN9D:GetValue("N9D_FARDO"))
				oModelN9D:GoLine(1)
				oModelN9D:DeleteLine()
			EndIf
	Next nIt

	oModelN9A:GoLine(cLinRF) // Posiciona na linha da regra fiscal selecionada
	
	// ########## Montagem do array de fardos selecionados #######################################
	For nIt := 1 To oModelN9D:Length()
		// Somente fardos que não estão deletados e que não contem IE
		If !oModelN9D:IsDeleted(nIt) .AND. !Empty(oModelN9D:GetValue("N9D_FARDO", nIt)) .AND. oModelN9D:GetValue("N9D_DXIEMB", nIt) != "1"
			If Empty(aFardos)
				aFardos := {{oModelN9A:GetValue("N9A_ITEM"), oModelN9D:GetValue("N9D_BLOCO", nIt), {val(oModelN9D:GetValue("N9D_DXIREC", nIt))}}}
			// Verifica se o bloco ja esta contido no array de fardos, senão estiver inclui o bloco e o primeiro fardo
			ElseIf (nPos := aScan(aFardos, {|x| x[2] == oModelN9D:GetValue("N9D_BLOCO", nIt)})) == 0
				aAdd(aFardos, { oModelN9A:GetValue("N9A_ITEM"), oModelN9D:GetValue("N9D_BLOCO", nIt), {val(oModelN9D:GetValue("N9D_DXIREC", nIt))}})
			Else // Senão, é por que ja existe um bloco, então adiciona o fardo no respectivo bloco
				aAdd(aFardos[nPos][3], val(oModelN9D:GetValue("N9D_DXIREC", nIt)))
			EndIf
			
			aAdd(aFardsDel, {oModelN9D:GetValue("N9D_FILIAL", nIt), oModelN9D:GetValue("N9D_SAFRA", nIt), oModelN9D:GetValue("N9D_FARDO", nIt), oModelN9D:GetValue("N9D_PESFIM", nIt), oModelN9D:GetValue("N9D_CODFAR", nIt)})
		ElseIf !oModelN9D:IsDeleted(nIt) .AND. Empty(oModelN9D:GetValue("N9D_FARDO", nIt))
			oModelN9D:DeleteLine() // Deleta linha vazia
		EndIf
	Next nIt

	// Caso existir algum array de fardos sem bloco, então remove o mesmo
	If (nPos := aScan(aFardos, {|x| x[2] == ""})) > 0
		aDel(aFardos, nPos)
		aSize(aFardos, Len(aFardos) - 1)
	EndIf

	// Chama a tela de seleção de fardos
	aFardos := AGRX720( cFiltDXI, cTipsAce, aFilHVI,  cFiltN9D, ;
				 aOptions, aFardos, aIEFar, nQtPrevEn, nTolen, nQtdUsada)

	FwModelActive(oModel) // Define o modelo ativo

	If aFardos[1] .AND. !Empty(aFardos[2]) 
		// aADD(aFarSel, { (__cTabFar)->DXI_FILIAL,(__cTabFar)->DXI_CODIGO,(__cTabFar)->DXI_BLOCO, (__cTabFar)->DXI_SAFRA, (__cTabFar)->DXI_ETIQ,  (__cTabFar)->DXI_PSLIQU })
		// Verifica se os fardos ja existem na regra fiscal selecionada

		oModelN9A:GoLine(cLinRF) // Posiciona na linha da regra fiscal selecionada
		
		// Percorre os fardos da regra fiscal em questão verificando os fardos selecionados, se não conter nos fardos da regra fiscal entao deleta o mesmo
		For nIt := 1 To oModelN9D:Length()
			oModelN9D:GoLine(nIt)
			If !oModelN9D:IsDeleted() .AND. aScan(aFardos[2], {|x| x[1] == oModelN9D:GetValue("N9D_FILIAL") .AND. ;
																	x[4] == oModelN9D:GetValue("N9D_SAFRA") .AND. ;
																	x[5] == oModelN9D:GetValue("N9D_FARDO")}) == 0 .AND. ;
																	oModelN9D:GetValue("N9D_DXIEMB") != "1"
														
				oModelN9D:DeleteLine()
				oModelN9A:SetValue("N9A_QTDTKP", oModelN9A:GetValue("N9A_QTDTKP") - oModelN9D:GetValue("N9D_PESFIM")) // Adiciona a quantidade do fardo
				oModelN9A:SetValue("N9A_QUANT", oModelN9A:GetValue("N9A_QTDTKP") ) // Adiciona a quantidade do fardo
				aAdd(__aOGX290FR, {cCodTkp,  oModelN9D:GetValue("N9D_FILIAL"), oModelN9D:GetValue("N9D_SAFRA"), ;
											oModelN9D:GetValue("N9D_FARDO"), oModelN9D:GetValue("N9D_CODFAR"), oModelN9A:GetLine(), oModelN9D:GetLine()})
			EndIf
		Next nIt

		oModelN9A:GoLine(cLinRF) // Posiciona na linha da regra fiscal selecionada

		// ########## Verifica em outras Regras fiscais os fardos adicionados para tratar os mesmos ##########
		For nIt := 1 To Len(aFardos[2])
			// Como foi verificado e encontrado o fardo em outra regra, adiciona uma nova linha na regra posicionada e preenche com o fardo
			oModelN9A:GoLine(cLinRF) // Posiciona na linha da regra fiscal selecionada

			// Adiciona somente fardos que ja não foram adicionados
			If !oModelN9D:SeekLine({ {"N9D_FILIAL", aFardos[2][nIt][1]}, {"N9D_SAFRA", aFardos[2][nIt][4]}, {"N9D_FARDO", aFardos[2][nIt][5]} })
				
				// ########## Se não encontrou na devida regra, então procura o fardo em outra regra fiscal ##########
				For nX := 1 To oModelN9A:Length()
					oModelN9A:GoLine(nX)
					// Verifica fardos da mesma filial, sem um codigo de romaneio e com o mesmo codigo de take-up, e que não seja da mesma regra fiscal
					If AllTrim(cOGX290F) == AllTrim(oModelN9A:GetValue("N9A_FILORG")) .AND. Empty(oModelN9A:GetValue("N9A_CODROM")) .AND. ;
							AllTrim(cCodTkp) == AllTrim(oModelN9A:GetValue("N9A_TAKEUP")) .AND. nX != cLinRF 
						// Por quesito de visualização esse if abaixo não foi encadeado, mas poderia ser.
						// Busca o fardo e o remove da regra fiscal
						If oModelN9D:SeekLine({ {"N9D_FILIAL", aFardos[2][nIt][1]}, {"N9D_SAFRA", aFardos[2][nIt][4]}, {"N9D_FARDO", aFardos[2][nIt][5]} })
							
							For nY := 1 To Len(aFieldsN9D)
								aAdd(aTransp, {aFieldsN9D[nY][3], oModelN9D:GetValue(aFieldsN9D[nY][3])})
							Next nY
							
							oModelN9D:DeleteLine()
							oModelN9A:SetValue("N9A_QTDTKP", oModelN9A:GetValue("N9A_QTDTKP") - oModelN9D:GetValue("N9D_PESFIM")) // Adiciona a quantidade do fardo
							oModelN9A:SetValue("N9A_QUANT", oModelN9A:GetValue("N9A_QTDTKP") ) // Adiciona a quantidade do fardo
							aAdd(__aOGX290FR, {cCodTkp,  oModelN9D:GetValue("N9D_FILIAL"), oModelN9D:GetValue("N9D_SAFRA"), ;
														oModelN9D:GetValue("N9D_FARDO"), oModelN9D:GetValue("N9D_CODFAR"), oModelN9A:GetLine(), oModelN9D:GetLine()})

							Exit // Sai do loop, pois ja encontrou o fardo em outra regra, o removeu e transpos os dados para o array auxiliar
						EndIf
					EndIf
				Next nX

				oModelN9A:GoLine(cLinRF) // Posiciona na linha da regra fiscal selecionada
				
				// Se o array de transposição está vazio, então verifica a regra fiscal corrente atras de fardos deletados
				If Empty(aTransp) .AND. oModelN9D:SeekLine({ {"N9D_FILIAL", aFardos[2][nIt][1]}, {"N9D_SAFRA", aFardos[2][nIt][4]}, {"N9D_FARDO", aFardos[2][nIt][5]} }, .T.) .AND. ;
					oModelN9D:IsDeleted()
					For nY := 1 To Len(aFieldsN9D)
						aAdd(aTransp, {aFieldsN9D[nY][3], oModelN9D:GetValue(aFieldsN9D[nY][3])})
					Next nY
                // Caso não localizar os fardos na regra, então verifica o array de fardos desvinculados sem regras
                elseif Empty(aTransp) .AND. (nPosRf := aScan(__aOGX290FR, {|x| x[2] == aFardos[2][nIt][1] .AND. ;
													x[3] == aFardos[2][nIt][4] .AND. ;
													x[4] == aFardos[2][nIt][5]})) > 0
                        
                        oModelN9A:GoLine(__aOGX290FR[nPosRf][6]) // Posiciona na linha da regra fiscal do fardo
                        oModelN9D:GoLine(__aOGX290FR[nPosRf][7]) // Posiciona na linha do fardo
                        
                        For nY := 1 To Len(aFieldsN9D)
							aAdd(aTransp, {aFieldsN9D[nY][3], oModelN9D:GetValue(aFieldsN9D[nY][3])})
						Next nY

                        oModelN9A:GoLine(cLinRF) // Posiciona na linha da regra fiscal selecionada
				EndIf
				
                If !Empty(aTransp) // Se possue fardo
                    oModelN9D:AddLine()
                    oModelN9A:SetValue("N9A_QTDTKP", oModelN9A:GetValue("N9A_QTDTKP") + aFardos[2][nIt][7]) // Adiciona a quantidade do fardo
                    oModelN9A:SetValue("N9A_QUANT", oModelN9A:GetValue("N9A_QTDTKP") ) // Adiciona a quantidade do fardo
					
					For nY := 1 To Len(aTransp)
                        oModelN9D:LoadValue(aTransp[nY][1], aTransp[nY][2])
                    Next nY

                    // Se está contido no array de controle dos fardos removidos, então remove o mesmo
                    If (nPosRf := aScan(__aOGX290FR, {|x| x[2] == aFardos[2][nIt][1] .AND. ;
                                                        x[3] == aFardos[2][nIt][4] .AND. ;
                                                        x[4] == aFardos[2][nIt][5]})) > 0
                        aDel(__aOGX290FR, nPosRf)
                        aSize(__aOGX290FR, Len(__aOGX290FR) - 1)
                    EndIf
                EndIf 
			EndIf

			aTransp := {} // Limpa variavel
		Next nIt

		oModelN9A:SetLineModify(cLinRF) // Seta linha como modificada
	ElseIf aFardos[1] .AND. Empty(aFardos[2]) // Se não trouxe nenhum fardo e confirmou, então desmarcou todos os fardos
		For nIt := 1 To Len(aFardsDel) // Procura na linha posicionada
			If oModelN9D:SeekLine({ {"N9D_FILIAL", aFardsDel[nIt][1]}, {"N9D_SAFRA", aFardsDel[nIt][2]}, {"N9D_FARDO", aFardsDel[nIt][3]} })
				oModelN9D:DeleteLine() // Deleta os fardos
				oModelN9A:SetValue("N9A_QTDTKP", oModelN9A:GetValue("N9A_QTDTKP") - aFardsDel[nIt][4]) // Reduz a quantidade de take-up dos fardos removidos
			    oModelN9A:SetValue("N9A_QUANT", oModelN9A:GetValue("N9A_QTDTKP") ) // Reduz a quantidade de take-up dos fardos removidos
				
				aAdd(__aOGX290FR, {cCodTkp,  aFardsDel[nIt][1],  aFardsDel[nIt][2],  aFardsDel[nIt][3], aFardsDel[nIt][5], oModelN9A:GetLine(), oModelN9D:GetLine()})
			EndIf
		Next nIt
		oModelN9A:SetLineModify(cLinRF) // Seta linha como modificada
	EndIf
	// ########## PÓS - Validações para seleção de fardos ###########################

	// ....
	//oModelN9AR:GoLine(1) // mantem na primeira posição a grid de pre-visualizacao
	oModelN9A:GoLine(1)
	RestArea(aArea)
	
Return

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
	Local lRet := .T.	

	If cAction == "SETVALUE" .AND. cIDField $ "NJR_CODPRO"
		//limpa a tabela
		oFieldModel:ClearField("NJR_TABELA")
		//valida o produto
		lRet := AGRXCODPRO(oFieldModel,xValue,oFieldModel:GetValue("NJR_TABELA"))
		Return lRet
	ElseIf cAction == "SETVALUE" .AND. cIDField $ "NJR_MODAL"
		cCodFin := Posicione('NK5',1,XFILIAL('NK5')+xValue,'NK5_CODFIN')		
		oFieldModel:SetValue("NJR_CODFIN",cCodFin )	
	ElseIf cAction == "SETVALUE" .AND. cIDField $ "NJR_TABELA"	
		//valida a tabela
		lRet := AGRXVLTAB(oFieldModel, xValue)//tabela	
		Return lRet	
	ElseIf cAction == "SETVALUE" .AND. cIDField $ "NJR_CODENT|NJR_LOJENT" .AND. !__lnewNeg
		//faz o vinculo de entidade njr x nny
		If cIDField == "NJR_CODENT"
			lRet := AGRXVLFAV(oFieldModel,xValue,oFieldModel:GetValue("NJR_LOJENT"))
		Else
			lRet := AGRXVLFAV(oFieldModel,oFieldModel:GetValue("NJR_CODENT"),xValue)
		EndIf
		Return lRet	
	ElseIf cAction == "SETVALUE" .AND. cIDField $ "NJR_VLRTOT" .AND. !__lnewNeg
		//atualiza a nn7 com o total
		AGRXTOTAL(oFieldModel, xValue)

	ElseIf cAction == "SETVALUE" .AND. cIDField $ "NJR_TIPFIX"
		lRet := AGRXVALFIX(oFieldModel:GetValue("NJR_CODCTR"))
		If !lRet 
			If xValue == '1'
				Help( , , STR0031, , STR0076, 1, 0 ) //'Contrato ja possui fixaçao de preços como Firme, mudando o tipo de fixaçao para A Fixar , a mesma sera Gravada Como Prevista'
			ElseIf xValue == '2'
				Help( , , STR0031, , STR0077, 1, 0 ) //"AJUDA"###'Contrato ja possui fixaçao de preços como Prevista, mudando o tipo de fixaçao para Fixo, a mesma sera Gravada Como Firme'
			EndIf		
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
		oFieldModel:SetValue("NJR_TIPO",'2')
		oFieldModel:SetValue("NJR_MODELO",'2')	
	EndIf

Return lRet


/*/{Protheus.doc} OGA290ALG()
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
Function OGA290ALG()
	If AGRTPALGOD(NJR->NJR_CODPRO) // algodao
		//mostra algodão para realizar o desvio na view.				
		__lMostraAlg := .T.

		FWExecView( 'QUALIDADE' ,'OGA290',MODEL_OPERATION_UPDATE,,{|| .T.},{|| .T.} )  //'consulta'
		//desabilita o desvio da view.
		__lMostraAlg := .F. 
	else
		Help(NIL, NIL, STR0031, NIL, STR0274, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0275})
		//"Para acessar a aba de qualidade é necessário que o produto do contrato seja definido como Algodão."
		//"Selecione um contrato que contenha um produto definido como Algodão."
	EndIF	
Return
