#INCLUDE "TMSA853.CH"
#INCLUDE "PROTHEUS.CH"

//-- Diretivas Pergunte
#DEFINE APERCLIDEV 1  //-- Cliente pagador de frete?     
#DEFINE APERLOJDEV 2  //-- Loja pagador de frete?        
#DEFINE APEREMIINI 3  //-- Data de emissão NFe de?       
#DEFINE APEREMIFIM 4  //-- Data de emissão NFe até?      
#DEFINE APERCLRINI 5  //-- Cliente remetente de?         
#DEFINE APERLJRINI 6  //-- Loja remetente de?            
#DEFINE APERCLRFIM 7  //-- Cliente remetente até?        
#DEFINE APERLJRFIM 8  //-- Loja remetente até?           
#DEFINE APERCLDINI 9  //-- Cliente destinatário de?      
#DEFINE APERLJDINI 10 //-- Loja destinatário de?         
#DEFINE APERCLDFIM 11 //-- Cliente destinatário até?     
#DEFINE APERLJDFIM 12 //-- Loja destinatário de?      
#DEFINE APERCODOCO 13 //-- Ocorrência?  
#DEFINE APERCODNEG 14 //-- Negociação?                  
#DEFINE APERSERVIC 15 //-- Serviço?                      
#DEFINE APERCODTES 16 //-- TES?                          
#DEFINE APERPRDFIS 17 //-- Produto fiscal?  

//-- Diretivas array aCpoBrowse
#DEFINE ACPOBRWALI 1 //-- Alias
#DEFINE ACPOBRWNOM 2 //-- Campo
#DEFINE ACPOBRWIQR 3 //-- Inclui na query?
#DEFINE ACPOBRWIBR 4 //-- Inclui no browse?
#DEFINE ACPOBRWCOL 5 //-- Nome da coluna do browse
#DEFINE ACPOBRWTIT 6 //-- Titulo da coluna do browse
#DEFINE ACPOBRWSIZ 7 //-- Tamanho da coluna do browse
#DEFINE ACPOBRWEDT 8 //-- Coluna do browse editavel?
#DEFINE ACPONOFIEL 9 //-- Indica que não deve carregar como campo no Select

//-- Diretivas array aDocs
#DEFINE ADOCFILIAL 1
#DEFINE ADOCFILORI 2
#DEFINE ADOCLOTNFC 3
#DEFINE ADOCCLIREM 4
#DEFINE ADOCLOJREM 5
#DEFINE ADOCCLIDES 6
#DEFINE ADOCLOJDES 7
#DEFINE ADOCSERVIC 8
#DEFINE ADOCCODPRO 9
#DEFINE ADOCNUMNFC 10
#DEFINE ADOCSERNFC 11
#DEFINE ADOCCODNEG 12
#DEFINE ADOCKM     13
#DEFINE ADOCVALOR  14
#DEFINE ADOCPESOM3 15
#DEFINE ADOCMETRO3 16
#DEFINE ADOCQTDVOL 17
#DEFINE ADOCBASSEG 18
#DEFINE ADOCQTDUNI 19
#DEFINE ADOCPESO   20
#DEFINE ADOCFILOCO 21
#DEFINE ADOCNUMOCO 22
#DEFINE ADOCFILVIA 23
#DEFINE ADOCVIAGEM 24
#DEFINE ADOCSEQOCO 25

//-- Diretivas array aParCal
#DEFINE ACALTIPCAL 1
#DEFINE ACALCLIREM 2
#DEFINE ACALLOJREM 3
#DEFINE ACALCDRORI 4
#DEFINE ACALCLICAL 5
#DEFINE ACALLOJCAL 6
#DEFINE ACALCDRCAL 7
#DEFINE ACALCLIDES 8
#DEFINE ACALLOJDES 9
#DEFINE ACALCDRDES 10
#DEFINE ACALSQEDES 11
#DEFINE ACALCLIDEV 12
#DEFINE ACALLOJDEV 13
#DEFINE ACALCODPRO 14
#DEFINE ACALSERVIC 15
#DEFINE ACALCODNEG 16
#DEFINE ACALSERTMS 17
#DEFINE ACALTIPTRA 18
#DEFINE ACALDOCTMS 19
#DEFINE ACALLOTNFC 20
#DEFINE ACALTIPFRE 21
#DEFINE ACALTIPNFC 22
#DEFINE ACALSEQINS 23
#DEFINE ACALVALMER 24
#DEFINE ACALPESO   25
#DEFINE ACALPESOM3 26
#DEFINE ACALQTDVOL 27
#DEFINE ACALMETRO3 28
#DEFINE ACALKM     29
#DEFINE ACALQTDUNI 30
#DEFINE ACALBASSEG 31
#DEFINE ACALPRCPDG 32
#DEFINE ACALCLIGEN 33
#DEFINE ACALAJUAUT 34
#DEFINE ACALVALINF 35
#DEFINE ACALTIPVEI 36
#DEFINE ACALFRTCOM 37
#DEFINE ACALCTRCLI 38
#DEFINE ACALSEQTAB  39

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA853
Geração Cobrança de Serviço Adicional
Geração de documento fiscal baseado no cadastro de lotes de notas (DTC),
sem vínculo com documento fiscal original
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@return Nil Não há retorno
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA853()

	Local oMarkBrw, oTempTable
	Local aRetIdxBrw := {} //-- Array retorno da funcao GetIdxBrw()
	Local aRetStrBrw := {} //-- Array retorno da funcao GetStrBrw()
	Local aStructBrw := {} //-- Struct do browse
	Local aCamposBrw := {} //-- Colunas do browse
	Local aCamposFil := {} //-- Campos que serao apresentados no filtro
	Local aIdxTemp   := {} //-- Indices FWTemporaryTable
	Local aIdxPesq   := {} //-- Indices pesquisa (Seek)
	Local cAliasQry  := ""
	Local cAliasBrw  := GetNextAlias() //-- Alias do browse
	Local cCodTes    := Space(Len(SF4->F4_CODIGO))
	Local cCodPro    := Space(Len(SB1->B1_COD))
	Local lIFisSer   := SuperGetMv("MV_IFISSER", , .F.) //-- Informações fiscais do serviço?
	Local bPrcQry    := Nil
	Local bSetPar    := Nil
	Local bAtzBrw    := Nil
	Local bAllMrk    := Nil
	Local bBtnVis    := Nil
	Local bBtnPrc    := Nil
	Local bBtnDoc    := Nil
	Local bVisDoc    := Nil
	Local bInfFis    := Nil
	Local bVldBrw    := Nil
	
	Private cCadastro := ""

	//-- Apresenta a tela de Pergunte
	If ! SetPergunt()
		Return Nil
	EndIf

	aRetIdxBrw := GetIdxBrw()   //-- Indices que estarao na FWTemporaryTable e pesquisa
	aIdxTemp   := aRetIdxBrw[1] //-- Indices da tabela temporaria
	aIdxPesq   := aRetIdxBrw[2] //-- Indices de pesquisa

	aRetStrBrw := GetStrBrw()   //-- Estrutura do browse
	aStructBrw := aRetStrBrw[1] //-- Struct para tabela temporária
	aCamposBrw := aRetStrBrw[2] //-- Colunas para browse
	aCamposFil := aRetStrBrw[3] //-- Colunas para filtro
	
	//-- Processa query
	bPrcQry := {|| cAliasQry := GetQryBrw()}
	Processa(bPrcQry, STR0006,;     //STR0006 'Aguarde...'
	                  STR0007, .F.) //STR0007 'Processando consulta...'

	//-- Definicao da tabela temporaria
	oTempTable := SetDataBrw(oTempTable, cAliasBrw, cAliasQry, aStructBrw, aIdxTemp)

	oMarkBrw := FWMarkBrowse():New()
	oMarkBrw:SetTemporary(.T.)
	oMarkBrw:SetFields(aCamposBrw)
	oMarkBrw:SetSeek(.T., aIdxPesq)
	oMarkBrw:SetUseFilter(.T.)
	oMarkBrw:SetAlias(cAliasBrw)
	oMarkBrw:SetFieldMark("MARK")
	oMarkBrw:SetDescription(STR0001) //STR0001 'Geração Cobrança de Servico Adicional'
	oMarkBrw:oBrowse:SetFieldFilter(aCamposFil)
    oMarkBrw:AddLegend("STATUS == '1'", "GREEN", STR0048) //STR0048 'Não possui documento de serviço adicional gerado'
    oMarkBrw:AddLegend("STATUS == '2'", "BLUE" , STR0066) //STR0066 'Ocorrência disponível para geração de documento de serviço adicional'
	oMarkBrw:AddLegend("STATUS == '3'", "RED"  , STR0049) //STR0049 'Ocorrência não disponível para geração de documento de serviço adicional'

	bSetPar := {|| Iif(ParamBrw(cAliasBrw, oTempTable, oMarkBrw, aIdxTemp, aStructBrw, aCamposBrw),;
				       (oMarkBrw:Refresh(.T.), oMarkBrw:GoTop(.T.), .T.), .F.)}
	bAtzBrw := {|| oMarkBrw:Refresh(.T.), oMarkBrw:GoTop(.T.)}
	bAllMrk := {|| AllMarkBrw(oMarkBrw)}
	bBtnVis := {|| Processa({|| TMSA853Vis(oMarkBrw)}, STR0006,;      //STR0006 'Aguarde...'
		                   	              	           STR0015, .F.)} //STR0015 'Abrindo visualizacao...'
	bInfFis := {|| IFisSerAdd(@cCodTes, @cCodPro)}
	bBtnPrc := {|| IIf(TMSA853Prc(cAliasBrw, cCodTes, cCodPro),;
	                   (oMarkBrw:Refresh(.T.), .T.), .F.)}
	bBtnDoc := {|| Iif(GetStatDoc(cAliasBrw, .T.) == "4",;
	                   (oMarkBrw:Refresh(.T.), .T.), .F.)}
	bVisDoc := {|| VisDocTran(cAliasBrw), oMarkBrw:Refresh()}
	bVldBrw := {|| VldMrkBrw(cAliasBrw)}

	oMarkBrw:SetAllMark(bAllMrk)
	oMarkBrw:SetParam(bSetPar)
	oMarkBrw:SetIniWindow(bAtzBrw)
	oMarkBrw:SetValid(bVldBrw)
	oMarkBrw:AddButton(STR0002, bBtnVis, , 02, 7) //STR0002 'Visualizar'
	oMarkBrw:AddButton(STR0003, bBtnPrc, , 03, 7) //STR0003 'Processar'
	oMarkBrw:AddButton(STR0004 + " (F4)" , bAllMrk, , 09, 7) //STR0004 'Inverter marcacao'
	oMarkBrw:AddButton(STR0051 + " (F5)" , bBtnDoc, , 10, 7) //STR0051 'Docs.Serv.Add.'
	oMarkBrw:AddButton(STR0062 + " (F6)" , bVisDoc, , 11, 7) //STR0062 'Vis. Documento'
	oMarkBrw:AddButton(STR0053 + " (F12)", bSetPar, , 12, 7) //STR0053 'Parâmetros'

	SetKey(VK_F4, bAllMrk)
	SetKey(VK_F5, bBtnDoc)
	SetKey(VK_F6, bVisDoc)

	If lIFisSer
		oMarkBrw:AddButton(STR0063 + " (F7)", bInfFis, , 13, 7) //STR0063 'Informações Fiscais'
		SetKey(VK_F7, bInfFis)
	EndIf

	oMarkBrw:Activate()

	oTempTable:Delete()

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetPergunt
Apresenta Pergunte para que o usuário informe os parâmetros e valida os mesmos até serem válidos
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 25/01/2017
@param [cPergunte], Caracter, Nome do Pergunte
@param [bValid], Caracter, Bloco de validação
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function SetPergunt(cPergunte, bValid)

	Local lValidPerg := .F.
	Local lRetPerg   := .F.

	Default cPergunte := "TMSA853"
	Default bValid    := {|| ValidPerg()}

	//-- Apresenta a tela de Pergunte
	
	lRetPerg := Pergunte(cPergunte, .T.)
	If ! lRetPerg
		Return .F.
	EndIf
	
	If ! Empty(bValid)
		lValidPerg := Eval(bValid)
	EndIf
	
	If lValidPerg
		Return .T.
	EndIf

Return .F.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetInfPerg
Retorna as informações do Pergunte TMSA853   
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 25/01/2017
@param [cCodTes], Caracter, Código da TES
@param [cCodPro], Caracter, Código do Produto Fiscal
@return aRet Array com as informações do Pergunte TMSA853
@obs Informações: TES e Produto fiscal foram retiradas do Pergunte e colocadas
@obs de forma separada em uma tela a parte. Estas informações podem ser
@obs indicadas apenas se o parâmetro MV_IFISSER estiver ligado.
/*/
//-------------------------------------------------------------------------------------------------
Static Function GetInfPerg(cCodTes, cCodPro)

	Local aPerg853 := {}

	Default cCodTes := ""
	Default cCodPro := ""

	//-- Informacoes do Pergunte que sao necessarias
	Pergunte("TMSA853", .F.)
	aPerg853 := {MV_PAR01,;
	             MV_PAR02,;
				 MV_PAR03,;
				 MV_PAR04,;
			     MV_PAR05,;
				 MV_PAR06,;
				 MV_PAR07,;
				 MV_PAR08,;
			     MV_PAR09,;
				 MV_PAR10,;
				 MV_PAR11,;
				 MV_PAR12,;
			     MV_PAR13,;
				 MV_PAR14,;
				 MV_PAR15,;
				 cCodTes,;
				 cCodPro}

Return aPerg853

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA853VlP
Função disparada para validação de cada campo do Pergunte TMSA853
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@param [cCampo], Caracter, Nome do campo a ser validado
@return lRet True ou False
@obs [MV_PAR01]	[CLIDEV]	Cliente pagador de frete?     
@obs [MV_PAR02]	[LOJDEV]	Loja pagador de frete?        
@obs [MV_PAR03]	[EMINFEINI]	Data de emissão NFe de?       
@obs [MV_PAR04]	[EMINFEFIM]	Data de emissão NFe até?      
@obs [MV_PAR05]	[CLIREMINI]	Cliente remetente de?         
@obs [MV_PAR06]	[LOJREMINI]	Loja remetente de?            
@obs [MV_PAR07]	[CLIREMFIM]	Cliente remetente até?        
@obs [MV_PAR08]	[LOJREMFIM]	Loja remetente até?           
@obs [MV_PAR09]	[CLIDESINI]	Cliente destinatário de?      
@obs [MV_PAR10]	[LOJDESINI]	Loja destinatário de?         
@obs [MV_PAR11]	[CLIDESFIM]	Cliente destinatário até?     
@obs [MV_PAR12]	[LOJDESFIM]	Loja destinatário de?      
@obs [MV_PAR13]	[CODOCO]	Ocorrência?  
@obs [MV_PAR14]	[CODNEG]	Negociação?                  
@obs [MV_PAR15]	[SERVIC]	Serviço?
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA853VlP(cCampo)

	Local lRet := .T.
	
	Default cCampo := ""
	
	Do Case

	//-- Cliente pagador de frete? / Loja pagador de frete?
	Case (cCampo == "CLIDEV" .Or. cCampo == "LOJDEV")
		lRet := VldCpoPerg(cCampo, {MV_PAR01, MV_PAR02})

	//-- Data de emissao NFe de?
	Case (cCampo == "EMINFEINI")
		lRet := VldCpoPerg(cCampo, {MV_PAR03})

	//-- Data de emissao NFe ate?
	Case (cCampo == "EMINFEFIM")
		lRet := VldCpoPerg(cCampo, {MV_PAR04})

	//-- Ocorrencia?
	Case (cCampo == "CODOCO")
		lRet := VldCpoPerg(cCampo, {MV_PAR13})

	//-- Negociação?
	Case (cCampo == "CODNEG")
		lRet := VldCpoPerg(cCampo, {MV_PAR14})

	//-- Servico?
	Case (cCampo == "SERVIC")
		lRet := VldCpoPerg(cCampo, {MV_PAR15})

	EndCase

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg
Função disparada para validação dos campos do Pergunte TMSA853, após confirmação do mesmo
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@return lRet True ou False
@obs [MV_PAR01]	Cliente pagador de frete?     
@obs [MV_PAR02]	Loja pagador de frete?        
@obs [MV_PAR03]	Data de emissão NFe de?       
@obs [MV_PAR04]	Data de emissão NFe até?      
@obs [MV_PAR05]	Cliente remetente de?         
@obs [MV_PAR06]	Loja remetente de?            
@obs [MV_PAR07]	Cliente remetente até?        
@obs [MV_PAR08]	Loja remetente até?           
@obs [MV_PAR09]	Cliente destinatário de?      
@obs [MV_PAR10]	Loja destinatário de?         
@obs [MV_PAR11]	Cliente destinatário até?     
@obs [MV_PAR12]	Loja destinatário de?      
@obs [MV_PAR13]	Ocorrência?
@obs [MV_PAR14]	Negociação?                       
@obs [MV_PAR15]	Serviço?                               
/*/
//-------------------------------------------------------------------------------------------------
Static Function ValidPerg()

	//-- Cliente pagador de frete? / Loja pagador de frete?
	If ! VldCpoPerg("CLILOJDEV", {MV_PAR01, MV_PAR02})
		Return .F.
	EndIf
	
	//-- Data de emissao NFe de?
	If ! VldCpoPerg("EMINFEINI", {MV_PAR03})
		Return .F.
	EndIf
	
	//-- Data de emissao NFe ate?
	If ! VldCpoPerg("EMINFEFIM", {MV_PAR04})
		Return .F.
	EndIf
	
	//-- 'Data de emissao NFe de' maior que 'Data de emissao NFe ate?'
	If ! VldCpoPerg("EMINFEINIFIM", {MV_PAR03, MV_PAR04})
		Return .F.
	EndIf
	
	//-- Ocorrencia?
	If ! VldCpoPerg("CODOCO", {MV_PAR13})
		Return .F.
	EndIf
	
	//-- Negociação?
	If ! VldCpoPerg("CODNEG", {MV_PAR14})
		Return .F.
	EndIf

	//-- Servico?
	If ! VldCpoPerg("SERVIC", {MV_PAR15})
		Return .F.
	EndIf

Return .T.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldCpoPerg
Função que concentra todas as validações de campos do Pergunte TMSA853 e eh chamada tanto na validacao de cada campos do Pergunte quanto apos confirmar o Pergunte
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@param [cCampo], Caracter, Nome do campo a ser validado
@param [oValor], Objeto, Valor do campo (pode ser qualquer tipo)
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function VldCpoPerg(cCampo, aValor)

	Local lRet := .T.
	
	Default cCampo := ""
	Default aValor := {""}
	
	Do Case

	//-- Cliente pagador de frete? / Loja pagador de frete?
	Case (cCampo == "CLIDEV" .Or. cCampo == "LOJDEV" .Or. cCampo == "CLILOJDEV")
		If (! Empty(aValor[1]) .And. ! Empty(aValor[2])) .Or. cCampo == "CLILOJDEV"
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
			If ! SA1->(MsSeek(xFilial("SA1") + aValor[1] + aValor[2]))
				lRet := .F.
				Help(" ", 1, "REGNOIS", , " (" + STR0008 + ")", 2, 1) //-- Nao existe registro relacionado a este codigo
			EndIf
		EndIf

	//-- Data de emissao NFe de?
	Case (cCampo == "EMINFEINI")
		If Empty(aValor[1])
			lRet := .F.
			Help(" ", 1, "NVAZIO", , " (" + STR0009 + ")", 2, 1) //-- Este campo deve ser informado.
		EndIf

	//-- Data de emissao NFe ate?
	Case (cCampo == "EMINFEFIM")
		If Empty(aValor[1])
			lRet := .F.
			Help(" ", 1, "NVAZIO", , " (" + STR0010 + ")", 2, 1) //-- Este campo deve ser informado.
		EndIf

	//-- Data de emissao NFe ate?
	Case (cCampo == "EMINFEINIFIM")
		If aValor[1] > aValor[2]
			lRet := .F.
			Help(" ", 1, "DATAMAIOR", , " (" + STR0009 + ")", 2, 1)
		EndIf

	//-- Ocorrencia?
	Case (cCampo == "CODOCO")
		dbSelectArea("DT2")
		DT2->(dbSetOrder(1)) //DT2_FILIAL+DT2_CODOCO 
		If !Empty(aValor[1]) .And. !DT2->(MsSeek(xFilial("DT2") + aValor[1]))
			lRet := .F.
			Help(" ", 1, "REGNOIS", , " (" + STR0011 + ")", 2, 1) //-- Nao existe registro relacionado a este codigo
		EndIf
		
	//-- Negociação?
	Case (cCampo == "CODNEG")
		dbSelectArea("DDB")
		DDB->(dbSetOrder(1)) //DDB_FILIAL+DDB_CODNEG
		If !Empty(aValor[1]) .And. !DDB->(MsSeek(xFilial("DDB") + aValor[1]))
			lRet := .F.
			Help(" ", 1, "REGNOIS", , " (" + STR0061 + ")", 2, 1) //-- Nao existe registro relacionado a este codigo
		EndIf

	//-- Servico?
	Case (cCampo == "SERVIC")
		If !Empty(aValor[1]) 
			dbSelectArea("DC5")
			DC5->(dbSetOrder(1)) //DC5_FILIAL+DC5_SERVIC+DC5_ORDEM 
			If !DC5->(MsSeek(xFilial("DC5") + aValor[1]))
				lRet := .F.
				Help(" ", 1, "REGNOIS", , " (" + STR0012 + ")", 2, 1) //-- Nao existe registro relacionado a este codigo
			Else
				If DC5->DC5_CATSER != "1" //-- Diferente de Negociacao
					lRet := .F.
					Help(" ", 1, "TMSA85301", , " (" + STR0012 + ")", 2, 1) //-- Servico informado deve ter categoria 1 - Negociacao
				ElseIf DC5->DC5_TIPRAT == "0" //-- Igual a Nao tem
					lRet := .F.
					Help(" ", 1, "TMSA85302", , " (" + STR0012 + ")", 2, 1) //-- Servico informado deve possuir indicacao de criterio de rateio 
				ElseIf DC5->DC5_DOCTMS != StrZero(5, Len(DC5->DC5_DOCTMS)) //-- Documento fiscal diferente de 5
					lRet := .F.
					Help(" ", 1, "TMSA85303", , " (" + STR0012 + ")", 2, 1) //-- Tipo de documento fiscal do servico informado deve ser igual a "5 - Nota Fiscal"
				EndIf
			EndIf
		EndIf

	//-- TES?
	Case (cCampo == "CODTES")
		If ! Empty(aValor[1])
			dbSelectArea("SF4")
			SF4->(dbSetOrder(1)) //F4_FILIAL+F4_CODIGO
			If ! SF4->(MsSeek(xFilial("SF4") + aValor[1]))
				lRet := .F.
				Help(" ", 1, "REGNOIS", , " (" + STR0013 + ")", 2, 1) //-- Nao existe registro relacionado a este codigo
			EndIf
		EndIf
		
	//-- Produto fiscal?
	Case (cCampo == "PRDFIS")
		If ! Empty(aValor[1])
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD 
			If ! SB1->(MsSeek(xFilial("SB1") + aValor[1]))
				lRet := .F.
				Help(" ", 1, "REGNOIS", , " (" + STR0014 + ")", 2, 1) //-- Nao existe registro relacionado a este codigo
			EndIf
		EndIf
	EndCase

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCposBrw
Responsável por identificar os campos que estarão na query e browse
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@return aCpoBrowse Array de informações dos campos
@obs aCpoBrowse[1] - Alias (query)
@obs aCpoBrowse[2] - Campo
@obs aCpoBrowse[3] - Inclui na query?
@obs aCpoBrowse[4] - Inclui no browse?
@obs aCpoBrowse[5] - Nome do campo no browse
@obs aCpoBrowse[6] - Título do campo
@obs aCpoBrowse[7] - Tamanho da coluna do browse
@obs aCpoBrowse[8] - Coluna do browse editável?
@obs aCpoBrowse[9] - Indica que não deve carregar como campo no Select
/*/
//-------------------------------------------------------------------------------------------------
Static Function GetCposBrw()

	Local aArea      := GetArea()
	Local aCpoBrowse := {} //-- Array retorno da funcao

	Aadd(aCpoBrowse, {"DTC"   , "DTC_FILORI", .T., .T.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_NUMNFC", .T., .T.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_SERNFC", .T., .T.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_EMINFC", .T., .T.,            , STR0016, , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_CLIREM", .T., .T.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"SA1REM", "A1_NOME"   , .T., .T., "NOMEREM"  , STR0017, , .F., .F.})
	Aadd(aCpoBrowse, {"DUYREM", "DUY_CODMUN", .T., .F., "CODMUNREM",        , , .F., .F.})	
	Aadd(aCpoBrowse, {"CC2REM", "CC2_MUN"   , .T., .T., "MUNREM"   , STR0018, , .F., .F.})
	Aadd(aCpoBrowse, {"DUYREM", "DUY_EST"   , .T., .T., "ESTREM"   , STR0019, , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_CLIDES", .T., .T.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"SA1DES", "A1_NOME"   , .T., .T., "NOMEDES"  , STR0020, , .F., .F.})
	Aadd(aCpoBrowse, {"DUYDES", "DUY_CODMUN", .T., .F., "CODMUNDES",        , , .F., .F.})
	Aadd(aCpoBrowse, {"CC2DES", "CC2_MUN"   , .T., .T., "MUNDES"   , STR0021, , .F., .F.})
	Aadd(aCpoBrowse, {"DUYDES", "DUY_EST"   , .T., .T., "ESTDES"   , STR0022, , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_FILDOC", .T., .T.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_DOC"   , .T., .T.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_SERIE" , .T., .T.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_QTDVOL", .T., .T.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_PESO"  , .T., .T.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_PESOM3", .T., .T.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_VALOR" , .T., .T.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_FILIAL", .T., .F.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_LOJREM", .T., .F.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_LOJDES", .T., .F.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_CODPRO", .T., .F.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_LOTNFC", .T., .F.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_CDRORI", .T., .F.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_CDRDES", .T., .F.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_SERVIC", .T., .F.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_KM"    , .T., .F.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_METRO3", .T., .F.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_BASSEG", .T., .F.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC"   , "DTC_QTDUNI", .T., .F.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DTC", "DTC_CODNEG", .T., .F.,           ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DUA"   , "DUA_CODOCO", .T., .F.,            ,        , , .F., .F.})
	Aadd(aCpoBrowse, {"DUA"   , "DUA_FILOCO", .T., .F.,            ,        , , .F., .T.})
	Aadd(aCpoBrowse, {"DUA"   , "DUA_NUMOCO", .T., .F.,            ,        , , .F., .T.})
	Aadd(aCpoBrowse, {"DUA"   , "DUA_FILORI", .T., .F.,            ,        , , .F., .T.})
	Aadd(aCpoBrowse, {"DUA"   , "DUA_VIAGEM", .T., .F.,            ,        , , .F., .T.})
	Aadd(aCpoBrowse, {"DUA"   , "DUA_SEQOCO", .T., .F.,            ,        , , .F., .T.})

	RestArea(aArea)
	
Return aCpoBrowse

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetIdxBrw
Responsável por identificar os índices da tabela temporária e de pesquisa
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@return aIdxBrowse Array de informações dos índices
@obs aIdxBrowse[1] - Índices da tabela temporária
@obs aIdxBrowse[2] - Índices de pesquisa
/*/
//-------------------------------------------------------------------------------------------------
Static Function GetIdxBrw()

	Local aArea      := GetArea()
	Local aRetIdxBrw := {} //-- Array retorno da funcao
	Local aIdxTemp   := {} //-- Indices FWTemporaryTable
	Local aIdxPesq   := {} //-- Indices pesquisa (Seek)
	Local cNomIdx    := "" //-- Nome do indice
	Local nTamIdx    := 0  //-- Tamanho do indice pesquisa
	Local cFilOri    := "FILORI"
	Local cNumNfc    := "NUMNFC"
	Local cSerNfc    := "SERNFC"
	Local nFilOri    := 2
	Local nNumNfc    := 6
	Local nSerNfc    := 3
	
	cFilOri := GetSX3Cache("DTC_FILORI", "X3_TITULO")
	nFilOri := GetSX3Cache("DTC_FILORI", "X3_TAMANHO")

	cNumNfc := GetSX3Cache("DTC_NUMNFC", "X3_TITULO")
	nNumNfc := GetSX3Cache("DTC_NUMNFC", "X3_TAMANHO")

	cSerNfc := GetSX3Cache("DTC_SERNFC", "X3_TITULO")
	nSerNfc := GetSX3Cache("DTC_SERNFC", "X3_TAMANHO")
	
	cNomIdx := cFilOri + "+" + cNumNfc + "+" + cSerNfc
	nTamIdx := nFilOri + nNumNfc + nSerNfc
	AAdd(aIdxTemp, {"INDEX1", {"DTC_FILORI", "DTC_NUMNFC", "DTC_SERNFC"}})
	Aadd(aIdxPesq, {cNomIdx, {{"", "C", nTamIdx, 0, "DTC_FILORI+DTC_NUMNFC+DTC_SERNFC", ""}}, 1, .T. })

	cNomIdx := cNumNfc + "+" + cSerNfc
	nTamIdx := nNumNfc + nSerNfc
	AAdd(aIdxTemp, {"INDEX2", {"DTC_NUMNFC", "DTC_SERNFC"}})
	Aadd(aIdxPesq, {cNomIdx, {{"", "C", nTamIdx, 0, "DTC_NUMNFC+DTC_SERNFC", ""}}, 2, .T. })

	aRetIdxBrw := {aIdxTemp, aIdxPesq}
	
	RestArea(aArea)
	
Return aRetIdxBrw

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetStrBrw
Responsável por identificar os campos, estrutura e colunas que deverão ser apresentadas no browse
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@param [aCpoBrowse], Array, Campos que serão considerados na estrutura
@return aRetStrBrw Array - Informações para estrutura do browse
@obs aRetStrBrw[1] - Struct para tabela temporária
@obs aRetStrBrw[2] - Colunas para browse
@obs aRetStrBrw[3] - Colunas para filtro
/*/
//-------------------------------------------------------------------------------------------------
Static Function GetStrBrw(aCpoBrowse)

	Local aArea      := GetArea()
	Local aRetStrBrw := {} //-- Array retorno da funcao
	Local aStructBrw := {} //-- Struct do browse
	Local aCamposBrw := {} //-- Colunas do browse
	Local aColsBrw   := {} //-- Colunas do browse
	Local aCamposFil := {} //-- Campos que serao apresentados no filtro
	Local nContAlias := 0  //-- Contador
	Local cNomCpoBrw := "" //-- Nome do campo na coluna do browse
	Local cTitCpoBrw := "" //-- Titulo do campo na coluna do browse
	Local nSizCpoBrw := 0  //-- Tamanho da coluna do browse
	Local lEdtCpoBrw := .F.//-- Coluna do browse editavel?
	Local oBrwCol
	Local aFldAux	 := {}
	Local aFldAll	 := {}
	Local nI		 := 0
	Local nPos		 := 0
	Local aTblAll	 := {}
	Local nJ		 := 0 
	
	If Empty(aCpoBrowse)
		aCpoBrowse := GetCposBrw()

		aFldAux := ApBuildHeader("DTC")
		For nI := 1 To Len(aFldAux)
			aAdd(aFldAll, aFldAux[nI])
		Next

		aFldAux := ApBuildHeader("DUA")
		For nI := 1 To Len(aFldAux)
			aAdd(aFldAll, aFldAux[nI])
		Next

		aFldAux := ApBuildHeader("SA1")
		For nI := 1 To Len(aFldAux)
			aAdd(aFldAll, aFldAux[nI])
		Next

		aFldAux := ApBuildHeader("CC2")
		For nI := 1 To Len(aFldAux)
			aAdd(aFldAll, aFldAux[nI])
		Next

		aFldAux := ApBuildHeader("DUY")
		For nI := 1 To Len(aFldAux)
			aAdd(aFldAll, aFldAux[nI])
		Next
	Else
		For nJ := 1 To Len(aCpoBrowse)
			If aScan(aTblAll, aCpoBrowse[nJ][1]) == 0
				aFldAux := ApBuildHeader(aCpoBrowse[nJ][1])
				For nI := 1 To Len(aFldAux)
					aAdd(aFldAll, aFldAux[nI])
				Next
			EndIf
		Next
	EndIf

	If aScan(aFldAll, {|x| AllTrim(x[2]) == "DTC_FILIAL"}) == 0
		Aadd(aFldAll, {"Filial", "DTC_FILIAL", "", 8, 0, "", GetSX3Cache("DTC_FILIAL", "X3_USADO"), "C", "", ""})
	EndIf

	If aScan(aFldAll, {|x| AllTrim(x[2]) == "DTC_FILORI"}) == 0
		Aadd(aFldAll, {"Fil.Origem", "DTC_FILORI", "", 8, 0, "", GetSX3Cache("DTC_FILORI", "X3_USADO"), "C", "", ""})
	EndIf

	If aScan(aFldAll, {|x| AllTrim(x[2]) == "DTC_NUMNFC"}) == 0
		Aadd(aFldAll, {"Doc.Cliente", "DTC_NUMNFC", "@!", 9, 0, "TMSA050NF()", GetSX3Cache("DTC_NUMNFC", "X3_USADO"), "C", "", ""})
	EndIf

	If aScan(aFldAll, {|x| AllTrim(x[2]) == "DTC_SERNFC"}) == 0
		Aadd(aFldAll, {"Serie Dc.Cli", "DTC_SERNFC", "@!", 3, 0, "TMSA050NF()", GetSX3Cache("DTC_SERNFC", "X3_USADO"), "C", "", ""})
	EndIf

	//-- Identifica as colunas que devem aparecer no browse
	For nContAlias := 1 To Len(aCpoBrowse)
	
		If (nPos := AScan(aFldAll, {|x| Alltrim(x[2]) == aCpoBrowse[nContAlias][ACPOBRWNOM]})) > 0

			cNomCpoBrw := Iif(Empty(aCpoBrowse[nContAlias, ACPOBRWCOL]), aFldAll[nPos][2], aCpoBrowse[nContAlias, ACPOBRWCOL])
			cTitCpoBrw := Iif(Empty(aCpoBrowse[nContAlias, ACPOBRWTIT]), aFldAll[nPos][1], aCpoBrowse[nContAlias, ACPOBRWTIT])
			nSizCpoBrw := Iif(Empty(aCpoBrowse[nContAlias, ACPOBRWSIZ]), aFldAll[nPos][4], aCpoBrowse[nContAlias, ACPOBRWSIZ])
			lEdtCpoBrw := Iif(Empty(aCpoBrowse[nContAlias][ACPOBRWEDT]), .F., aCpoBrowse[nContAlias][ACPOBRWEDT])
			
			Aadd(aStructBrw, {cNomCpoBrw, aFldAll[nPos][8], nSizCpoBrw, aFldAll[nPos][5]})
			
			//-- Define as colunas a serem apresentadas na FWMarkBrowse
			If aCpoBrowse[nContAlias, ACPOBRWIBR]
			
				oBrwCol := FWBrwColumn():New()
				oBrwCol:SetType(aFldAll[nPos][8])
				oBrwCol:SetData(&("{|| " + cNomCpoBrw + " }"))
				oBrwCol:SetTitle(cTitCpoBrw)
				oBrwCol:SetSize(nSizCpoBrw)
				oBrwCol:SetDecimal(aFldAll[nPos][5])
				oBrwCol:SetPicture(aFldAll[nPos][3])
				oBrwCol:SetReadVar(cNomCpoBrw)
				oBrwCol:SetEdit(lEdtCpoBrw)

				Aadd(aCamposBrw, {cTitCpoBrw, cNomCpoBrw, aFldAll[nPos][8], nSizCpoBrw, aFldAll[nPos][5], aFldAll[nPos][3]})
				Aadd(aCamposFil, {cNomCpoBrw, cTitCpoBrw, aFldAll[nPos][8], nSizCpoBrw, aFldAll[nPos][5], aFldAll[nPos][3]})
				AAdd(aColsBrw  , oBrwCol)

			EndIf
		EndIf
	Next nContAlias

	aSize(aFldAux, 0)
	aFldAux := Nil

	aSize(aFldAll, 0)
	aFldAll := Nil

	//-- Cria array de retorno
	aRetStrBrw := {aStructBrw, aCamposBrw, aCamposFil, aColsBrw}

	RestArea(aArea)
	
Return aRetStrBrw

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetQryBrw
Responsável por montar a query conforme Pergunte e obter os dados que deverão ser apresentados no browse
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@param [aPerg853], Array, Informações do Pergunte TMSA853
@return cAliasQry Alias da query
/*/
//-------------------------------------------------------------------------------------------------
Static Function GetQryBrw(aPerg853)

	Local aCpoBrowse := GetCposBrw()
	Local cCamposQry := "" //-- Campos da query
	Local cQueryBrw  := "" //-- Query
	Local cAliasQry  := "" //-- Alias da query
	Local nContador  := 0  //-- Contador
	
	//-- Variaveis do Pergunte
	Local cCliDev    := ""
	Local cLojDev    := ""
	Local cEmisDe    := ""
	Local cEmisAte   := ""
	Local cCliRemDe  := ""
	Local cLojRemDe  := ""
	Local cCliRemAte := ""
	Local cLojRemAte := ""
	Local cCliDesDe  := ""
	Local cLojDesDe  := ""
	Local cCliDesAte := ""
	Local cLojDesAte := ""
	Local cOcorren   := ""
	Local dEmisDe    := Nil
	Local dEmisAte   := Nil
	
	Default aPerg853 := GetInfPerg()
	
	cCliDev    := aPerg853[APERCLIDEV]
	cLojDev    := aPerg853[APERLOJDEV]
	dEmisDe    := aPerg853[APEREMIINI]
	dEmisAte   := aPerg853[APEREMIFIM]
	cCliRemDe  := aPerg853[APERCLRINI]
	cLojRemDe  := aPerg853[APERLJRINI]
	cCliRemAte := aPerg853[APERCLRFIM]
	cLojRemAte := aPerg853[APERLJRFIM]
	cCliDesDe  := aPerg853[APERCLDINI]
	cLojDesDe  := aPerg853[APERLJDINI]
	cCliDesAte := aPerg853[APERCLDFIM]
	cLojDesAte := aPerg853[APERLJDFIM]
	cOcorren   := aPerg853[APERCODOCO]

	cCamposQry := ""
	For nContador := 1 To Len(aCpoBrowse)
		If aCpoBrowse[nContador, ACPOBRWIQR] .And. ! aCpoBrowse[nContador, ACPONOFIEL]
			If ! Empty(cCamposQry)
				cCamposQry += ", "
			EndIf
			cCamposQry += aCpoBrowse[nContador, ACPOBRWALI] + "." + aCpoBrowse[nContador, ACPOBRWNOM]
			If ! Empty(aCpoBrowse[nContador, ACPOBRWCOL])
				cCamposQry += " " + aCpoBrowse[nContador, ACPOBRWCOL]
			EndIf
		EndIf
	Next nContador

	If ! Empty(cCamposQry)

		cEmisDe   := Iif(! Empty(dEmisDe) , DToS(dEmisDe) , "")
		cEmisAte  := Iif(! Empty(dEmisAte), DToS(dEmisAte), "")

		cAliasQry := GetNextAlias()
		cQueryBrw := "SELECT DISTINCT " + cCamposQry + " FROM " + RetSqlName("DTC") + " DTC "
		
		cQueryBrw += " LEFT JOIN " + RetSqlName("SA1") + " SA1REM "
		cQueryBrw += "   ON SA1REM.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQueryBrw += "  AND SA1REM.A1_COD     = DTC.DTC_CLIREM "
		cQueryBrw += "  AND SA1REM.A1_LOJA    = DTC.DTC_LOJREM "
		cQueryBrw += "  AND SA1REM.D_E_L_E_T_ = ' ' "
		
		cQueryBrw += " LEFT JOIN " + RetSqlName("DUY") + " DUYREM "
		cQueryBrw += "   ON DUYREM.DUY_FILIAL = '" + xFilial("DUY") + "' "
		cQueryBrw += "  AND DUYREM.DUY_GRPVEN = DTC.DTC_CDRORI "
		cQueryBrw += "  AND DUYREM.D_E_L_E_T_ = ' ' "
		
		cQueryBrw += " LEFT JOIN " + RetSqlName("CC2") + " CC2REM "
		cQueryBrw += "   ON CC2REM.CC2_FILIAL = '" + xFilial("CC2") + "' "
		cQueryBrw += "  AND CC2REM.CC2_EST    = DUYREM.DUY_EST "
		cQueryBrw += "  AND CC2REM.CC2_CODMUN = DUYREM.DUY_CODMUN "
		cQueryBrw += "  AND CC2REM.D_E_L_E_T_ = ' ' "
		
		cQueryBrw += " LEFT JOIN " + RetSqlName("SA1") + " SA1DES "
		cQueryBrw += "   ON SA1DES.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQueryBrw += "  AND SA1DES.A1_COD     = DTC.DTC_CLIDES "
		cQueryBrw += "  AND SA1DES.A1_LOJA    = DTC.DTC_LOJDES "
		cQueryBrw += "  AND SA1DES.D_E_L_E_T_ = ' ' "
		
		cQueryBrw += " LEFT JOIN " + RetSqlName("DUY") + " DUYDES "
		cQueryBrw += "   ON DUYDES.DUY_FILIAL = '" + xFilial("DUY") + "' "
		cQueryBrw += "  AND DUYDES.DUY_GRPVEN = DTC.DTC_CDRDES "
		cQueryBrw += "  AND DUYDES.D_E_L_E_T_ = ' ' "

		cQueryBrw += " LEFT JOIN " + RetSqlName("CC2") + " CC2DES "
		cQueryBrw += "   ON CC2DES.CC2_FILIAL = '" + xFilial("CC2") + "' "
		cQueryBrw += "  AND CC2DES.CC2_EST    = DUYDES.DUY_EST "
		cQueryBrw += "  AND CC2DES.CC2_CODMUN = DUYDES.DUY_CODMUN "
		cQueryBrw += "  AND CC2DES.D_E_L_E_T_ = ' ' "

		cQueryBrw += " INNER JOIN " + RetSqlName("DUA") + " DUA "
		cQueryBrw += "    ON DUA.DUA_FILIAL = '" + xFilial("DUA") + "' "
		cQueryBrw += "   AND DUA.DUA_CODOCO = '" + cOcorren       + "' "
		cQueryBrw += "   AND DUA.DUA_FILDOC = DTC.DTC_FILDOC
		cQueryBrw += "   AND DUA.DUA_DOC    = DTC.DTC_DOC
		cQueryBrw += "   AND DUA.DUA_SERIE  = DTC.DTC_SERIE
		cQueryBrw += "   AND DUA.D_E_L_E_T_ = ' ' "

		cQueryBrw += " WHERE DTC.DTC_FILIAL  = '" + xFilial("DTC") + "' "
		cQueryBrw += "   AND DTC.DTC_CLIDEV  = '" + cCliDev        + "' "
		cQueryBrw += "   AND DTC.DTC_LOJDEV  = '" + cLojDev        + "' "
		cQueryBrw += "   AND DTC.DTC_EMINFC >= '" + cEmisDe        + "' "
		cQueryBrw += "   AND DTC.DTC_EMINFC <= '" + cEmisAte       + "' "
		cQueryBrw += "   AND DTC.DTC_CLIREM >= '" + cCliRemDe      + "' "
		cQueryBrw += "   AND DTC.DTC_CLIREM <= '" + cCliRemAte     + "' "
		cQueryBrw += "   AND DTC.DTC_LOJREM >= '" + cLojRemDe      + "' "
		cQueryBrw += "   AND DTC.DTC_LOJREM <= '" + cLojRemAte     + "' "
		cQueryBrw += "   AND DTC.DTC_CLIDES >= '" + cCliDesDe      + "' "
		cQueryBrw += "   AND DTC.DTC_CLIDES <= '" + cCliDesAte     + "' "
		cQueryBrw += "   AND DTC.DTC_LOJDES >= '" + cLojDesDe      + "' "
		cQueryBrw += "   AND DTC.DTC_LOJDES <= '" + cLojDesAte     + "' "
		cQueryBrw += "   AND DTC.DTC_FILDOC <> ' ' "
		cQueryBrw += "   AND DTC.DTC_DOC    <> ' ' "
		cQueryBrw += "   AND DTC.DTC_SERIE  <> ' ' "
		cQueryBrw += "   AND DTC.D_E_L_E_T_  = ' ' "

		cQueryBrw += "UNION "
		//Reentrega e Devolução
		cQueryBrw += "SELECT DISTINCT " + cCamposQry + " FROM " + RetSqlName("DTC") + " DTC "
				
		cQueryBrw += " INNER JOIN " + RetSqlName("DY4") + " DY4 "
		cQueryBrw += "    ON DY4.DY4_FILIAL = '" + xFilial("DY4") + "' "
		cQueryBrw += "   AND DTC.DTC_FILORI = DY4.DY4_FILORI " 		
		cQueryBrw += "   AND DTC.DTC_NUMNFC = DY4.DY4_NUMNFC " 							
		cQueryBrw += "   AND DTC.DTC_SERNFC = DY4.DY4_SERNFC " 
		cQueryBrw += "   AND DTC.DTC_CLIREM = DY4.DY4_CLIREM " 
		cQueryBrw += "   AND DTC.DTC_LOJREM = DY4.DY4_LOJREM " 
		cQueryBrw += "   AND DTC.DTC_CODPRO = DY4.DY4_CODPRO " 
		cQueryBrw += "   AND DY4.D_E_L_E_T_ = ' ' "

		cQueryBrw += " INNER JOIN " + RetSqlName("DUA") + " DUA "
		cQueryBrw += "    ON DUA.DUA_FILIAL = '" + xFilial("DUA") + "' "
		cQueryBrw += "   AND DUA.DUA_FILDOC = DY4.DY4_FILDOC " 
		cQueryBrw += "   AND DUA.DUA_DOC    = DY4.DY4_DOC " 
		cQueryBrw += "   AND DUA.DUA_SERIE  = DY4.DY4_SERIE "
		cQueryBrw += "   AND DUA.DUA_CODOCO = '" + cOcorren       + "' "
		cQueryBrw += "   AND DUA.D_E_L_E_T_ = ' ' "		

		cQueryBrw += " LEFT JOIN " + RetSqlName("SA1") + " SA1REM "
		cQueryBrw += "   ON SA1REM.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQueryBrw += "  AND SA1REM.A1_COD     = DTC.DTC_CLIREM "
		cQueryBrw += "  AND SA1REM.A1_LOJA    = DTC.DTC_LOJREM "
		cQueryBrw += "  AND SA1REM.D_E_L_E_T_ = ' ' "
		
		cQueryBrw += " LEFT JOIN " + RetSqlName("DUY") + " DUYREM "
		cQueryBrw += "   ON DUYREM.DUY_FILIAL = '" + xFilial("DUY") + "' "
		cQueryBrw += "  AND DUYREM.DUY_GRPVEN = DTC.DTC_CDRORI "
		cQueryBrw += "  AND DUYREM.D_E_L_E_T_ = ' ' "
		
		cQueryBrw += " LEFT JOIN " + RetSqlName("CC2") + " CC2REM "
		cQueryBrw += "   ON CC2REM.CC2_FILIAL = '" + xFilial("CC2") + "' "
		cQueryBrw += "  AND CC2REM.CC2_EST    = DUYREM.DUY_EST "
		cQueryBrw += "  AND CC2REM.CC2_CODMUN = DUYREM.DUY_CODMUN "
		cQueryBrw += "  AND CC2REM.D_E_L_E_T_ = ' ' "
		
		cQueryBrw += " LEFT JOIN " + RetSqlName("SA1") + " SA1DES "
		cQueryBrw += "   ON SA1DES.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQueryBrw += "  AND SA1DES.A1_COD     = DTC.DTC_CLIDES "
		cQueryBrw += "  AND SA1DES.A1_LOJA    = DTC.DTC_LOJDES "
		cQueryBrw += "  AND SA1DES.D_E_L_E_T_ = ' ' "
		
		cQueryBrw += " LEFT JOIN " + RetSqlName("DUY") + " DUYDES "
		cQueryBrw += "   ON DUYDES.DUY_FILIAL = '" + xFilial("DUY") + "' "
		cQueryBrw += "  AND DUYDES.DUY_GRPVEN = DTC.DTC_CDRDES "
		cQueryBrw += "  AND DUYDES.D_E_L_E_T_ = ' ' "

		cQueryBrw += " LEFT JOIN " + RetSqlName("CC2") + " CC2DES "
		cQueryBrw += "   ON CC2DES.CC2_FILIAL = '" + xFilial("CC2") + "' "
		cQueryBrw += "  AND CC2DES.CC2_EST    = DUYDES.DUY_EST "
		cQueryBrw += "  AND CC2DES.CC2_CODMUN = DUYDES.DUY_CODMUN "
		cQueryBrw += "  AND CC2DES.D_E_L_E_T_ = ' ' "

		cQueryBrw += " WHERE DTC.DTC_FILIAL  = '" + xFilial("DTC") + "' "
		cQueryBrw += "   AND DTC.DTC_CLIDEV  = '" + cCliDev        + "' "
		cQueryBrw += "   AND DTC.DTC_LOJDEV  = '" + cLojDev        + "' "
		cQueryBrw += "   AND DTC.DTC_EMINFC >= '" + cEmisDe        + "' "
		cQueryBrw += "   AND DTC.DTC_EMINFC <= '" + cEmisAte       + "' "
		cQueryBrw += "   AND DTC.DTC_CLIREM >= '" + cCliRemDe      + "' "
		cQueryBrw += "   AND DTC.DTC_CLIREM <= '" + cCliRemAte     + "' "
		cQueryBrw += "   AND DTC.DTC_LOJREM >= '" + cLojRemDe      + "' "
		cQueryBrw += "   AND DTC.DTC_LOJREM <= '" + cLojRemAte     + "' "
		cQueryBrw += "   AND DTC.DTC_CLIDES >= '" + cCliDesDe      + "' "
		cQueryBrw += "   AND DTC.DTC_CLIDES <= '" + cCliDesAte     + "' "
		cQueryBrw += "   AND DTC.DTC_LOJDES >= '" + cLojDesDe      + "' "
		cQueryBrw += "   AND DTC.DTC_LOJDES <= '" + cLojDesAte     + "' "
		cQueryBrw += "   AND DTC.D_E_L_E_T_  = ' '" 	

		cQueryBrw := ChangeQuery(cQueryBrw)
		
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryBrw), cAliasQry, .F., .T.)
		
	EndIf

Return cAliasQry

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetDataBrw
Responsável por criar os registros no alias do browse principal
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@param [oTempTable], Objeto, FWTemporaryTable
@param [cAliasBrw], Array, Alias que será utilizado no browse
@param [cAliasQry], Array, Alias com as informações que serão apresentadas no browse
@param [aStructBrw], Array, Estrutura do browse
@param [aIdxTemp], Array, Índices que deverão ser adicionados
@return oTempTable Objeto FWTemporaryTable
/*/
//-------------------------------------------------------------------------------------------------
Static Function SetDataBrw(oTempTable, cAliasBrw, cAliasQry, aStructBrw, aIdxTemp)

	Local aCpoBrowse := GetCposBrw()
	Local aStrBrwAux := {}
	Local nContador  := 0
	
	Default cAliasBrw  := ""
	Default oTempTable := Nil
	Default aIdxTemp   := {}
	Default aStructBrw := {}
	Default cAliasQry  := ""

	//-- Elimina os registros da tabela temporaria, se estiver definida
	If oTempTable != Nil
		(cAliasBrw)->(dbGoTop())
		While (cAliasBrw)->(!Eof())
			(cAliasBrw)->(RecLock(cAliasBrw, .F.))
			(cAliasBrw)->(DbDelete())
			(cAliasBrw)->(MsUnlock())
			(cAliasBrw)->(DbSkip())
		EndDo
	Else
	
		//-- Inclusao da coluna de marcacao na estrutura do browse
		aStrBrwAux := aStructBrw //-- Transfere a estrutura recebida p/ variavel auxiliar
		aStructBrw := {}
		Aadd(aStructBrw, {"MARK"  , "C", 1, 0})
		Aadd(aStructBrw, {"STATUS", "C", 1, 0})
		For nContador := 1 To Len(aStrBrwAux)
			Aadd(aStructBrw, aStrBrwAux[nContador])
		Next nContador

		//-- Cria estrutura da tabela temporaria que sera utilizada no browse
		oTempTable := FWTemporaryTable():New(cAliasBrw)
		oTempTable:SetFields(aStructBrw)
		
		//-- Indices
		For nContador := 1 To Len(aIdxTemp)
			oTempTable:AddIndex(aIdxTemp[nContador, 1], aIdxTemp[nContador, 2])
		Next nContador
		
		oTempTable:Create()

	EndIf

	//-- Cria os registros na tabela temporaria
	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->(!Eof())

		(cAliasBrw)->(RecLock(cAliasBrw, .T.))
		For nContador := 1 To Len(aCpoBrowse)
			If ! aCpoBrowse[nContador, ACPONOFIEL] //-- Apenas campos retornados da query
				cNomCpoBrw := Iif(Empty(aCpoBrowse[nContador, ACPOBRWCOL]), aCpoBrowse[nContador, ACPOBRWNOM], aCpoBrowse[nContador, ACPOBRWCOL])
				If (cAliasQry)->(FieldPos(cNomCpoBrw)) > 0
					If ValType((cAliasBrw)->(&(cNomCpoBrw))) == "D"
						(cAliasBrw)->(&(cNomCpoBrw)) := Stod((cAliasQry)->(&(cNomCpoBrw)))
					Else
						(cAliasBrw)->(&(cNomCpoBrw)) := (cAliasQry)->(&(cNomCpoBrw))
					EndIf
				EndIf
			EndIf
		Next nContador
		(cAliasBrw)->(MsUnlock())

		GetStatDoc(cAliasBrw)

		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

Return oTempTable

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetStatDoc
Atualiza o status do documento em relação a ter ou não documento de serviço adicional associado 
 e apresenta ao usuário a tela com os documentos de faturamento de serviço adicional quando o parâmetro 
 lApresDoc for informado como .T.
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 22/02/2017
@param [cAliasQry], Caracter, Alias do documento
@param [lApresDoc], Lógico, Apresenta documentos?
@return cRet '1' ou '2'
@obs cRet := '1' - Não possui documento de serviço adicional gerado para esta ocorrência
@obs cRet := '2' - Possui documento de serviço adicional gerado para esta ocorrência
@obs cRet := '3' - Há ocorrência disponível para geração de documento de serviço adicional
@obs cRet := '4' - Documento cancelado
/*/
//-------------------------------------------------------------------------------------------------
Static Function GetStatDoc(cAliasQry, lApresDoc)

	Local aArea      := GetArea()
	Local aSetKey    := GetKey()
	Local aAreaQry   := (cAliasQry)->(GetArea())
	Local cRet       := "1"
	Local cQuery     := ""
	Local cAlias     := GetNextAlias()
	Local cAliDoc    := GetNextAlias()
	Local aButtons   := {}
	Local aCpoDoc    := {}
	Local aRetStrBrw := {} //-- Array retorno da funcao GetStrBrw()
	Local aStrDoc    := {}
	Local nQtdDoc    := 0
	Local lOcorDisp  := .F.
	Local oDlgDoc, oPnlModal, oFWLayer, oPnlDoc, oTempDoc, oBrwDoc

	Default cAliasQry := ""
	Default lApresDoc := .F.

	TmsKeyOff(aSetKey)

	If ! Empty(cAliasQry) .And. (cAliasQry)->(!Eof())

		lOcorDisp := .F.

		//-- Identifica se existe ocorrência sem documento de serviço adicional gerado
		cQuery += "SELECT DUA.DUA_FILOCO, DUA.DUA_NUMOCO, DUA.DUA_FILORI, DUA.DUA_VIAGEM, DUA.DUA_SEQOCO "
		cQuery += "  FROM " + RetSqlName("DUA") + " DUA "
		cQuery += " WHERE DUA.DUA_FILIAL = '" + xFilial("DUA") + "' "
		cQuery += "   AND DUA.DUA_CODOCO = '" + (cAliasQry)->DUA_CODOCO + "' "
		cQuery += "   AND DUA.DUA_FILDOC = '" + (cAliasQry)->DTC_FILDOC + "' " 
		cQuery += "   AND DUA.DUA_DOC    = '" + (cAliasQry)->DTC_DOC    + "' " 
		cQuery += "   AND DUA.DUA_SERIE  = '" + (cAliasQry)->DTC_SERIE  + "' "
		cQuery += "   AND NOT EXISTS (SELECT 1 "
		cQuery += "                     FROM " + RetSqlName("DY4") + " DY4 "
		cQuery += "                    WHERE DY4.DY4_FILIAL = '" + xFilial("DY4") + "' "
		cQuery += "                      AND DY4.DY4_FILORI = '" + (cAliasQry)->DTC_FILORI + "' "
		cQuery += "                      AND DY4.DY4_LOTNFC = '" + (cAliasQry)->DTC_LOTNFC + "' "
		cQuery += "                      AND DY4.DY4_NUMNFC = '" + (cAliasQry)->DTC_NUMNFC + "' "
		cQuery += "                      AND DY4.DY4_SERNFC = '" + (cAliasQry)->DTC_SERNFC + "' "
		cQuery += "                      AND DY4.DY4_CODPRO = '" + (cAliasQry)->DTC_CODPRO + "' "
		cQuery += "                      AND DY4.DY4_CLIREM = '" + (cAliasQry)->DTC_CLIREM + "' "
		cQuery += "                      AND DY4.DY4_LOJREM = '" + (cAliasQry)->DTC_LOJREM + "' "
		cQuery += "                      AND DY4.DY4_FILOCO = DUA.DUA_FILOCO "
		cQuery += "                      AND DY4.DY4_NUMOCO = DUA.DUA_NUMOCO "
		cQuery += "                      AND DY4.DY4_FILVIA = DUA.DUA_FILORI "
		cQuery += "                      AND DY4.DY4_VIAGEM = DUA.DUA_VIAGEM "
		cQuery += "                      AND DY4.DY4_SEQOCO = DUA.DUA_SEQOCO "
		cQuery += "                      AND DY4.D_E_L_E_T_ = ' ') "
		cQuery += "   AND DUA.D_E_L_E_T_ = ' ' "

		cQuery += " UNION "

		cQuery += "SELECT DUA.DUA_FILOCO, DUA.DUA_NUMOCO, DUA.DUA_FILORI, DUA.DUA_VIAGEM, DUA.DUA_SEQOCO "
		cQuery += "  FROM " + RetSqlName("DUA") + " DUA ,  " + RetSqlName("DY4") + " DY41   "
		cQuery += " WHERE DUA.DUA_FILIAL  = '" + xFilial("DUA") + "' "
		cQuery += "   AND DY41.DY4_FILIAL = '" + xFilial("DY4") + "' "
		cQuery += "   AND DY41.DY4_FILORI = '" + (cAliasQry)->DTC_FILORI + "' "
		cQuery += "   AND DY41.DY4_LOTNFC = '" + (cAliasQry)->DTC_LOTNFC + "' "
		cQuery += "   AND DY41.DY4_NUMNFC = '" + (cAliasQry)->DTC_NUMNFC + "' "
		cQuery += "   AND DY41.DY4_SERNFC = '" + (cAliasQry)->DTC_SERNFC + "' "
		cQuery += "   AND DY41.DY4_CODPRO = '" + (cAliasQry)->DTC_CODPRO + "' "
		cQuery += "   AND DY41.DY4_CLIREM = '" + (cAliasQry)->DTC_CLIREM + "' "
		cQuery += "   AND DY41.DY4_LOJREM = '" + (cAliasQry)->DTC_LOJREM + "' "
		cQuery += "   AND DUA.DUA_CODOCO  = '" + (cAliasQry)->DUA_CODOCO + "' "
		cQuery += "   AND DUA.DUA_FILDOC  = DY41.DY4_FILDOC " 
		cQuery += "   AND DUA.DUA_DOC     = DY41.DY4_DOC  
		cQuery += "   AND DUA.DUA_SERIE   = DY41.DY4_SERIE "
		
		cQuery += "   AND NOT EXISTS (SELECT 1 "
		cQuery += "                     FROM " + RetSqlName("DY4") + " DY4 "
		cQuery += "                    WHERE DY4.DY4_FILIAL = '" + xFilial("DY4") + "' "
		cQuery += "                      AND DY4.DY4_FILORI = '" + (cAliasQry)->DTC_FILORI + "' "
		cQuery += "                      AND DY4.DY4_LOTNFC = '" + (cAliasQry)->DTC_LOTNFC + "' "
		cQuery += "                      AND DY4.DY4_NUMNFC = '" + (cAliasQry)->DTC_NUMNFC + "' "
		cQuery += "                      AND DY4.DY4_SERNFC = '" + (cAliasQry)->DTC_SERNFC + "' "
		cQuery += "                      AND DY4.DY4_CODPRO = '" + (cAliasQry)->DTC_CODPRO + "' "
		cQuery += "                      AND DY4.DY4_CLIREM = '" + (cAliasQry)->DTC_CLIREM + "' "
		cQuery += "                      AND DY4.DY4_LOJREM = '" + (cAliasQry)->DTC_LOJREM + "' "
		cQuery += "                      AND DY4.DY4_FILOCO = DUA.DUA_FILOCO "
		cQuery += "                      AND DY4.DY4_NUMOCO = DUA.DUA_NUMOCO "
		cQuery += "                      AND DY4.DY4_FILVIA = DUA.DUA_FILORI "
		cQuery += "                      AND DY4.DY4_VIAGEM = DUA.DUA_VIAGEM "
		cQuery += "                      AND DY4.DY4_SEQOCO = DUA.DUA_SEQOCO "
		cQuery += "                      AND DY4.D_E_L_E_T_ = ' ') "
		cQuery += "   AND DUA.D_E_L_E_T_ = ' ' "
		cQuery += "   AND DY41.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

		//-- Grava informação da ocorrência que irá ser associada ao documento de serviço adicional
		(cAlias)->(dbGoTop())
		If (cAlias)->(!Eof())
			lOcorDisp := .T.
			(cAliasQry)->(RecLock(cAliasQry, .F.))
			(cAliasQry)->DUA_FILOCO := (cAlias)->DUA_FILOCO
			(cAliasQry)->DUA_NUMOCO := (cAlias)->DUA_NUMOCO
			(cAliasQry)->DUA_FILORI := (cAlias)->DUA_FILORI
			(cAliasQry)->DUA_VIAGEM := (cAlias)->DUA_VIAGEM
			(cAliasQry)->DUA_SEQOCO := (cAlias)->DUA_SEQOCO
			(cAliasQry)->(MsUnlock())
		EndIf
		(cAlias)->(dbCloseArea())

		//-- Identifica os documentos de serviço adicional gerados para a nota
		cQuery := "SELECT DT6.DT6_FILDOC, DT6.DT6_SERIE , DT6.DT6_DOC   , DUA.DUA_CODOCO, DT2.DT2_DESCRI, "
		cQuery += "       DUA.DUA_FILOCO, DUA.DUA_NUMOCO, DUA.DUA_FILORI, DUA.DUA_VIAGEM, DUA.DUA_SEQOCO "
		cQuery += "  FROM " + RetSqlName("DY4") + " DY4 "
		cQuery += " INNER JOIN " + RetSqlName("DT6") + " DT6 "
		cQuery += "         ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
		cQuery += "        AND DT6.DT6_FILDOC = DY4.DY4_FILDOC "
		cQuery += "        AND DT6.DT6_SERIE  = DY4.DY4_SERIE "
		cQuery += "        AND DT6.DT6_DOC    = DY4.DY4_DOC "
		cQuery += "        AND DT6.DT6_DOCTMS = '" + StrZero(5, Len(DC5->DC5_DOCTMS)) + "' "
		cQuery += "        AND DT6.D_E_L_E_T_ = ' ' "
		cQuery += " INNER JOIN " + RetSqlName("DUA") + " DUA "
		cQuery += "         ON DUA.DUA_FILIAL = '" + xFilial("DUA") + "' "
		cQuery += "        AND DUA.DUA_FILOCO = DY4.DY4_FILOCO "
		cQuery += "        AND DUA.DUA_NUMOCO = DY4.DY4_NUMOCO "
		cQuery += "        AND DUA.DUA_FILORI = DY4.DY4_FILVIA "
		cQuery += "        AND DUA.DUA_VIAGEM = DY4.DY4_VIAGEM "
		cQuery += "        AND DUA.DUA_SEQOCO = DY4.DY4_SEQOCO "
		cQuery += "        AND DUA.D_E_L_E_T_ = ' ' "
		cQuery += " INNER JOIN " + RetSqlName("DT2") + " DT2 "
		cQuery += "         ON DT2.DT2_FILIAL = '" + xFilial("DT2") + "' "
		cQuery += "        AND DT2.DT2_CODOCO = DUA.DUA_CODOCO "
		cQuery += "        AND DT2.D_E_L_E_T_ = ' ' "
		cQuery += "      WHERE DY4.DY4_FILIAL = '" + xFilial("DY4") + "' "
		cQuery += "        AND DY4.DY4_FILORI = '" + (cAliasQry)->DTC_FILORI + "' "
		cQuery += "        AND DY4.DY4_LOTNFC = '" + (cAliasQry)->DTC_LOTNFC + "' "
		cQuery += "        AND DY4.DY4_NUMNFC = '" + (cAliasQry)->DTC_NUMNFC + "' "
		cQuery += "        AND DY4.DY4_SERNFC = '" + (cAliasQry)->DTC_SERNFC + "' "
		cQuery += "        AND DY4.DY4_CODPRO = '" + (cAliasQry)->DTC_CODPRO + "' "
		cQuery += "        AND DY4.DY4_CLIREM = '" + (cAliasQry)->DTC_CLIREM + "' "
		cQuery += "        AND DY4.DY4_LOJREM = '" + (cAliasQry)->DTC_LOJREM + "' "
		cQuery += "        AND DY4.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

		//-- Identifica o status da nota em relação a ter ou não documento de serviço adicional gerado
		//-- e se possui ocorrência disponível para gerar um documento de serviço adicional
		If (cAlias)->(!Eof())
			If lOcorDisp
				cRet := "2"
			Else
				cRet := "3"
			EndIf
		Else
			cRet := "1"
		EndIf

		//-- Atualiza o status da nota
		(cAliasQry)->(RecLock(cAliasQry, .F.))
		(cAliasQry)->STATUS := cRet
		(cAliasQry)->MARK   := "  "
		(cAliasQry)->(MsUnlock())

		If lApresDoc
		
			If (cAlias)->(Eof())
				Help(" ", 1, "TMSA85317") // Nao ha documento de serviço adicional gerado vinculado!
			Else

				//-- Modal que serao apresentados os documentos de servico adicional
				oDlgDoc := FWDialogModal():New()
				oDlgDoc:SetBackground(.F.)
				oDlgDoc:SetTitle(STR0050) //STR0050 'Documentos de Serviço Adicional'
				oDlgDoc:SetEscClose(.T.)
				oDlgDoc:EnableAllClient()
				oDlgDoc:CreateDialog()

				oPnlModal := oDlgDoc:GetPanelMain()
				
				oFWLayer := FWLayer():New() //-- Container
				oFWLayer:Init(oPnlModal, .F., .T.) //-- Inicializa container
				
				//-- Linha, coluna e window superior
				oFWLayer:AddLine('UP', 100, .F.) //-- Painel superior
				oFWLayer:AddCollumn('ALL', 100, .F., 'UP') //-- Adiciona uma "linha" com 100%
				oFWLayer:AddWindow('ALL', 'WINDOC', STR0050, 100, .F., .F., , 'UP') //STR0050 'Documentos de Servico Adicional'
				
				oPnlDoc := oFWLayer:GetWinPanel('ALL', 'WINDOC', 'UP')

				//-- Campos que serao apresentados no browse
				Aadd(aCpoDoc, {"DT6", "DT6_FILDOC", .T., .T., , , , .F.})
				Aadd(aCpoDoc, {"DT6", "DT6_DOC"   , .T., .T., , , , .F.})
				Aadd(aCpoDoc, {"DT6", "DT6_SERIE" , .T., .T., , , , .F.})
				Aadd(aCpoDoc, {"DUA", "DUA_CODOCO", .T., .T., , , , .F.})
				Aadd(aCpoDoc, {"DT2", "DT2_DESCRI", .T., .T., , , , .F.})
				Aadd(aCpoDoc, {"DUA", "DUA_FILOCO", .T., .T., , , , .F.})
				Aadd(aCpoDoc, {"DUA", "DUA_NUMOCO", .T., .T., , , , .F.})
				Aadd(aCpoDoc, {"DUA", "DUA_FILORI", .T., .T., , , , .F.})
				Aadd(aCpoDoc, {"DUA", "DUA_VIAGEM", .T., .T., , , , .F.})
				Aadd(aCpoDoc, {"DUA", "DUA_SEQOCO", .T., .T., , , , .F.})

				//-- Define estrutura do browse de componentes
				aRetStrBrw := GetStrBrw(aCpoDoc)
				aStrDoc := aRetStrBrw[1]
				aCpoDoc := aRetStrBrw[4]

				//-- Tabela temporaria Documentos de Serviço Adicional
				oTempDoc := FWTemporaryTable():New(cAliDoc)
				oTempDoc:SetFields(aStrDoc)
				oTempDoc:Create()

				//-- Cria os registros na tabela temporaria
				(cAlias)->(dbGoTop())
				While (cAlias)->(!Eof())
					(cAliDoc)->(RecLock(cAliDoc, .T.))
					(cAliDoc)->DT6_FILDOC := (cAlias)->DT6_FILDOC
					(cAliDoc)->DT6_SERIE  := (cAlias)->DT6_SERIE
					(cAliDoc)->DT6_DOC    := (cAlias)->DT6_DOC
					(cAliDoc)->DUA_CODOCO := (cAlias)->DUA_CODOCO
					(cAliDoc)->DT2_DESCRI := (cAlias)->DT2_DESCRI
					(cAliDoc)->DUA_FILOCO := (cAlias)->DUA_FILOCO
					(cAliDoc)->DUA_NUMOCO := (cAlias)->DUA_NUMOCO
					(cAliDoc)->DUA_FILORI := (cAlias)->DUA_FILORI
					(cAliDoc)->DUA_VIAGEM := (cAlias)->DUA_VIAGEM
					(cAliDoc)->DUA_SEQOCO := (cAlias)->DUA_SEQOCO
					(cAliDoc)->(MsUnlock())
					(cAlias)->(DbSkip())
					nQtdDoc := nQtdDoc + 1
				EndDo
				
				//-- Criacao do browse de componentes
				oBrwDoc:= FWBrowse():New()
				oBrwDoc:SetDataTable(.T.)
				oBrwDoc:SetOwner(oPnlDoc)
				oBrwDoc:SetDescription(STR0050) //STR0050 'Documentos de Servico Adicional'
				oBrwDoc:SetAlias(cAliDoc)
				oBrwDoc:SetColumns(aCpoDoc)
				oBrwDoc:DisableReport()
				oBrwDoc:Activate()
				oBrwDoc:Refresh(.T.)
				oBrwDoc:GoTop(.T.)

				//-- Cria botoes de operacao
				Aadd(aButtons, {"", STR0065, {|| oDlgDoc:DeActivate()  }, , , .T., .F.}) //STR0065 'Fechar'
				Aadd(aButtons, {"", STR0002, {|| DocServAdd(cAliDoc, 1)}, , , .T., .F.}) //STR0002 'Visualizar'																
				Aadd(aButtons, {"", STR0054, {|| cRet := "4",;
				                                 Iif(DocServAdd(cAliDoc, 2, @nQtdDoc),;
												     (oDlgDoc:DeActivate(), .T.),;
													 (oBrwDoc:Refresh(.T.), .F.))}, , , .T., .F.}) //STR0054 'Cancelar Documento'
				oDlgDoc:AddButtons(aButtons)

				oDlgDoc:Activate()
				
				//-- Ao finalizar, elimina tabelas temporarias
				oTempDoc:Delete()
			EndIf
		EndIf

		(cAlias)->(dbCloseArea())

	Else
		Help(" ", 1, "TMSA85307") // Nao existem registros para selecao.
	EndIf

	//-- Indica que cancelou um documento de servico adicional e deve atualizar
	//-- o status dos registros selecionados
	If cRet == "4"
		(cAliasQry)->(dbGoTop())
		While (cAliasQry)->(!Eof())
			GetStatDoc(cAliasQry)
			(cAliasQry)->(DbSkip())
		EndDo
		RestArea(aAreaQry)
	EndIf

	RestArea(aArea)
	TmsKeyOn(aSetKey)

Return cRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA853DSa
Indica se o documento é um Serviço Adicional
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 22/02/2017
@param [cFilDoc], Caracter, Filial do documento
@param [cDoc], Caracter, Número do documento
@param [cSerie], Caracter, Série do documento
@param [cDocTms], Caracter, Tipo documento de transporte
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA853DSa(cFilDoc, cDoc, cSerie, cDocTms)

	Local aArea    := GetArea()
	Local lRet     := .F.

	If (cDocTms == StrZero(5, Len(DC5->DC5_DOCTMS))) //-- 5 - Nota fiscal
		
		dbSelectArea("DY4")
		DY4->(dbSetOrder(1)) //DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE+DY4_NUMNFC+DY4_SERNFC+DY4_CODPRO 
		If DY4->(MsSeek(xFilial("DY4") + cFilDoc + cDoc + cSerie))
			lRet := .T.
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA853OSa
Indica se existe documento de Serviço Adicional vinculado a ocorrência e informações deste documento
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 11/04/2017
@param [cFilOco], Caracter, Filial da ocorrência
@param [cNumOco], Caracter, Número da ocorrência
@param [cFilOri], Caracter, Série do documento
@param [cViagem], Caracter, Viagem
@param [cSeqOco], Caracter, Sequência da ocorrência
@return aRet Array com informações do documento de serviço adicional vinculado a ocorrência
@obs aRet[1] lSvAdd Lógico Indica se existe ou não documento de serviço adicional vinculado a ocorrência
@obs aRet[2] cFilDoc Caracter Filial do documento
@obs aRet[3] cDoc Caracter Documento
@obs aRet[4] cSerie Caracter Série
@obs aRet[5] cChv Caracter Informação completa da chave do documento
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA853OSa(cFilOco, cNumOco, cFilOri, cViagem, cSeqOco)

	Local aArea   := GetArea()
	Local aRet    := {}

	Default cFilOco := ""
	Default cNumOco := ""
	Default cFilOri := ""
	Default cViagem := ""
	Default cSeqOco := ""

	AAdd(aRet, .F.) //-- 1
	AAdd(aRet, "")  //-- 2
	AAdd(aRet, "")  //-- 3
	AAdd(aRet, "")  //-- 4
	AAdd(aRet, "")  //-- 5

	dbSelectArea("DY4")

	//-- Índice deve existir
	If Empty(DY4->(IndexKey(4)))
		RestArea(aArea)
		Return aRet
	EndIf

	DY4->(dbSetOrder(4)) //DY4_FILIAL+DY4_FILOCO+DY4_NUMOCO+DY4_FILVIA+DY4_VIAGEM+DY4_SEQOCO
	If DY4->(MsSeek(xFilial("DY4") + cFilOco + cNumOco + cFilOri + cViagem + cSeqOco))
		aRet[1] := .T.
		aRet[2] := DY4->DY4_FILDOC
		aRet[3] := DY4->DY4_DOC
		aRet[4] := DY4->DY4_SERIE

		dbSelectArea("SX3")
		SX3->(dbSetOrder(2)) //X3_CAMPO
		If SX3->(MsSeek("DY4_FILDOC"))
			aRet[5] := Trim(X3TITULO()) + ": " + aRet[2]
		EndIf
		If SX3->(MsSeek("DY4_DOC"))
			aRet[5] += ", " + Trim(X3TITULO()) + ": " + aRet[3]
		EndIf
		If SX3->(MsSeek("DY4_SERIE"))
			aRet[5] += ", " + Trim(X3TITULO()) + ": " + aRet[4] + "."
		EndIf
	EndIf

	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA853ESa
Elimina relacionamento do documento de serviço adicional com a tabela DY4
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 22/02/2017
@param [cFilDoc], Caracter, Filial do documento
@param [cDoc], Caracter, Número do documento
@param [cSerie], Caracter, Série do documento
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA853ESa(cFilDoc, cDoc, cSerie)

	Local aArea := GetArea()
	Local lRet  := .T.
	Local cSeek := xFilial("DY4") + cFilDoc + cDoc + cSerie

	dbSelectArea("DY4")
	DY4->(dbSetOrder(1)) //DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE+DY4_NUMNFC+DY4_SERNFC+DY4_CODPRO 
	If DY4->(MsSeek(cSeek))
		While DY4->(!Eof()) .And. DY4->(DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE) == cSeek
			DY4->(RecLock("DY4", .F.))
			DY4->(DbDelete())
			DY4->(DbSkip())
		EndDo
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DocServAdd
Visualização ou cancelamento do documento de serviço adicional selecionado
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 22/02/2017
@param [cAliDoc], Caracter, Alias do documento
@param [nOpc], Numérico, Opção a ser executada
@param [nQtdDoc], Numérico, Quantidade de documentos
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function DocServAdd(cAliDoc, nOpc, nQtdDoc)

	Local aArea   := GetArea()
	Local lRet    := .F.
	Local aSetKey := GetKey()

	Private aRotina   := StaticCall(TmsA500, MenuDef)
	Private Inclui    := .F.
	Private Altera    := .F.

	TmsKeyOff(aSetKey)
	
	If nOpc == 1 //-- Visualizacao
		cCadastro := STR0052 //STR0052 'Manutencao de Documentos - Visualizar'
	ElseIf nOpc == 2 //-- Cancelamento
		cCadastro := STR0055 //STR0055 'Manutenção de Documentos - Cancelar'
	EndIf

	DT6->(DbSetOrder(1))
	If DT6->(MsSeek(xFilial("DT6") + (cAliDoc)->DT6_FILDOC + (cAliDoc)->DT6_DOC + (cAliDoc)->DT6_SERIE))
		If nOpc == 1 //-- Visualizacao
			Processa({|| TMSA500Mnt("DT6", DT6->(Recno()), 2)},;  
						STR0006,;     //STR0006 'Aguarde...'
						STR0015, .F.) //STR0015 'Abrindo visualizacao...'
		ElseIf nOpc == 2 //-- Cancelamento
			Processa({|| TMSA500Mnt("DT6", DT6->(Recno()), 6)},;
						STR0006,;     //STR0006 'Aguarde...'
						STR0056, .F.) //STR0015 'Abrindo cancelamento...'

			//-- Documento cancelado
			If ! DT6->(MsSeek(xFilial("DT6") + (cAliDoc)->DT6_FILDOC + (cAliDoc)->DT6_DOC + (cAliDoc)->DT6_SERIE))
				(cAliDoc)->(RecLock(cAliDoc, .F.))
				(cAliDoc)->(DbDelete())
				(cAliDoc)->(MsUnlock())
				
				nQtdDoc := nQtdDoc - 1
				If nQtdDoc <= 0
					lRet := .T.
				Endif
			EndIf
		EndIf 
    EndIf

	RestArea(aArea)
	TmsKeyOn(aSetKey)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ParamBrw
Apresenta tela de parâmetros (F12)
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@param [cAliasBrw], Caracter, Alias que será utilizado no browse
@param [oTempTable], Objeto, FWTemporaryTable
@param [oMarkBrw], Objeto, FWMarkBrowse
@param [aIdxTemp], Array, Índices que deverão ser adicionados
@param [aStructBrw], Array, Estrutura do browse
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function ParamBrw(cAliasBrw, oTempTable, oMarkBrw, aIdxTemp, aStructBrw)

	Local aArea      := GetArea()
	Local aSetKey    := GetKey()
	Local lRet       := .F.
	Local cAliasQry  := ""

	Default cAliasBrw  := ""
	Default oTempTable := Nil
	Default oMarkBrw   := Nil
	Default aIdxTemp   := {}
	Default aStructBrw := {}

	TmsKeyOff(aSetKey)

	//-- Apresenta a tela de Pergunte
	If ! SetPergunt()
		TmsKeyOn(aSetKey)
		Return lRet
	EndIf

	lRet := .T. //-- Parâmetros confirmados

	//-- Processa query
	Processa({|| cAliasQry := GetQryBrw()},;
	          STR0006,;     //STR0006 'Aguarde...'
	          STR0007, .F.) //STR0007 'Processando consulta...'

	//-- Definicao da tabela temporaria
	oTempTable := SetDataBrw(oTempTable, cAliasBrw, cAliasQry, aStructBrw, aIdxTemp)

	RestArea(aArea)
	TmsKeyOn(aSetKey)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA853Vis
Função responsável por apresentar a Visualização do Documento do Cliente (DTC)
Chama a função TmsA050Mnt da rotina de Entrada de Documentos dos Clientes
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@param [oMarkBrw], Objeto, FWMarkBrowse
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMSA853Vis(oMarkBrw)

	Local aArea      := GetArea()
	Local cAliasBrw  := oMarkBrw:Alias()
	Local lRet       := .T.
	Local aSetKey    := GetKey()

	Local cCadOld    := cCadastro
	Local aRotOld    := If( Type("aRotina") == "A", Aclone(aRotina), {} )

	Default oMarkBrw  := Nil
	
	//-- Necessario para chamar a funcao TmsA050Mnt
	Private Inclui    := .F.
	Private aRotina   := StaticCall( TmsA500, MenuDef )

	cCadastro := STR0005 //STR0005 'Documento do Cliente - Visualizar'

	TmsKeyOff(aSetKey)

	If (cAliasBrw)->(!Eof())
		DTC->(DbSetOrder(2)) //-- DTC_FILIAL+DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM+DTC_CODPRO+DTC_FILORI+DTC_LOTNFC 
		If DTC->(MsSeek(xFilial("DTC") + (cAliasBrw)->DTC_NUMNFC + (cAliasBrw)->DTC_SERNFC + (cAliasBrw)->DTC_CLIREM +;
		                                 (cAliasBrw)->DTC_LOJREM + (cAliasBrw)->DTC_CODPRO + (cAliasBrw)->DTC_FILORI +;
		                                 (cAliasBrw)->DTC_LOTNFC))
			TmsA050Mnt("DTC", DTC->(Recno()), 2)
		Else
			Help(" ", 1, "TMSA85304") // Documento do Cliente nao encontrado!
		EndIf
	Else
		Help(" ", 1, "TMSA85305") // Nenhum registro selecionado para Visualizacao.
	EndIf

	cCadastro := cCadOld
	aRotina   := Aclone(aRotOld)
	
	RestArea(aArea)
	TmsKeyOn(aSetKey)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA853Prc
Processa faturamento de serviço adicional
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@param [cAliasBrw], Array, Alias que será utilizado no browse
@param [cCodTes], Caracter, Código da TES
@param [cCodPro], Caracter, Código do Produto Fiscal
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA853Prc(cAliasBrw, cCodTes, cCodPro)

	Local aArea    := GetArea()
	Local aAreaBrw := (cAliasBrw)->(GetArea())
	Local aPerg853 := {}
	Local aDocs    := {}
	Local aContrat := {}
	Local lRet     := .F.
	
	Default cAliasBrw := ""
	Default cCodTes   := ""
	Default cCodPro   := ""

	aPerg853 := GetInfPerg(cCodTes, cCodPro)

	//-- Alimenta array aDocs com os itens selecionados
	(cAliasBrw)->(dbGoTop())
	While (cAliasBrw)->(!Eof())
		If ! Empty((cAliasBrw)->MARK)
			Aadd(aDocs, {(cAliasBrw)->DTC_FILIAL,;
					      (cAliasBrw)->DTC_FILORI,;
					      (cAliasBrw)->DTC_LOTNFC,;
					      (cAliasBrw)->DTC_CLIREM,;
					      (cAliasBrw)->DTC_LOJREM,;
					      (cAliasBrw)->DTC_CLIDES,;
					      (cAliasBrw)->DTC_LOJDES,;
					      (cAliasBrw)->DTC_SERVIC,;
					      (cAliasBrw)->DTC_CODPRO,;
					      (cAliasBrw)->DTC_NUMNFC,;
					      (cAliasBrw)->DTC_SERNFC,;
					      (cAliasBrw)->DTC_CODNEG,;
					      (cAliasBrw)->DTC_KM,;
					      (cAliasBrw)->DTC_VALOR,;
					      (cAliasBrw)->DTC_PESOM3,;
					      (cAliasBrw)->DTC_METRO3,;
					      (cAliasBrw)->DTC_QTDVOL,;
					      (cAliasBrw)->DTC_BASSEG,;
					      (cAliasBrw)->DTC_QTDUNI,;
					      (cAliasBrw)->DTC_PESO,;
						  (cAliasBrw)->DUA_FILOCO,;
						  (cAliasBrw)->DUA_NUMOCO,;
						  (cAliasBrw)->DUA_FILORI,;
						  (cAliasBrw)->DUA_VIAGEM,;
						  (cAliasBrw)->DUA_SEQOCO})
		EndIf
		(cAliasBrw)->(DbSkip())
	EndDo
	RestArea(aAreaBrw)
	
	//-- Validacoes antes do processamento
	If PreVldPrc(aDocs, aPerg853)
	
		aContrat := TMSContrat(aPerg853[APERCLIDEV], aPerg853[APERLOJDEV], , aPerg853[APERSERVIC], .F., "1", , , , , , , , , , , , , , , , aPerg853[APERCODNEG])
		
		//-- Existem duas formas de definir o valor do servico adicional
		If Empty(aContrat)
			//-- 1 -> Se o servico de negociacao nao estiver no contrato vigente do cliente pagador do frete
			//--      entao sera utilizado o componente indicado no parametro MV_COMPSER;
			Processa({|| lRet := ValServPar(aDocs, aPerg853)},;
			          STR0006,; //STR0006 'Aguarde...'
			          , .F.)
		Else
			//-- 2 -> Do contrario sera utilizado os componentes da tabela de frete indicada para o servico
			//--      no contrato;
			Processa({|| lRet := ValServTab(aDocs, aPerg853, aContrat)},;
			          STR0006,; //STR0006 'Aguarde...'
			          , .F.)
		EndIf
	EndIf

	//-- Indica que criou o documento de servico adicional e deve atualizar
	//-- o status dos registros selecionados
	If lRet
		(cAliasBrw)->(dbGoTop())
		While (cAliasBrw)->(!Eof())
			If ! Empty((cAliasBrw)->MARK)
				GetStatDoc(cAliasBrw)
			EndIf
			(cAliasBrw)->(DbSkip())
		EndDo
		RestArea(aAreaBrw)
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PreVldPrc
Validações realizadas antes de realizar o processamento do faturamento de serviço adicional
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@param [aDocs], Array, Documentos selecionados
@param [aPerg853], Array, Informacoes do Pergunte TMSA853
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function PreVldPrc(aDocs, aPerg853)

	Local aArea := GetArea()
	
	Default aDocs    := {}
	Default aPerg853 := {}
	
	If Empty(aDocs) .Or. Len(aDocs) <= 0
		Help(" ", 1, "TMSA85306") //-- Nao existem registros selecionados para processamento.
		Return .F.
	EndIf

	//-- Validacao Negociação
	If ! VldCpoPerg("CODNEG", {aPerg853[APERCODNEG]})
		Return .F.
	EndIf

	//-- Validacao Servico
	If ! VldCpoPerg("SERVIC", {aPerg853[APERSERVIC]})
		Return .F.
	EndIf
	
	//-- Validacao TES
	If ! VldCpoPerg("CODTES", {aPerg853[APERCODTES]})
		Return .F.
	EndIf
	
	//-- Validacao Produto fiscal
	If ! VldCpoPerg("PRDFIS", {aPerg853[APERPRDFIS]})
		Return .F.
	EndIf

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValServPar
Apresenta o componente informado no parâmetro MV_COMPSER para ser informado o valor a ser cobrado
pelo serviço adicional
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 11/01/2017
@param [aDocs], Array, Documentos selecionados
@param [aPerg853], Array, Informacoes do Pergunte TMSA853
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function ValServPar(aDocs, aPerg853)

	Local aButtons   := {}
	Local aCpoComp   := {}
	Local aRetStrBrw := {} //-- Array retorno da funcao GetStrBrw()
	Local aStrComp   := {}
	Local aParCal    := {}
	Local aCmpFrt    := {}
	Local cAliComp   := GetNextAlias()
	Local cTitWin    := ""
	Local cCompSer   := SuperGetMv("MV_COMPSER", , "") //-- Componente de frete de Servico Adicional
	Local lRet       := .T.
	Local oDlgCom, oPnlModal, oFWLayer, oPnlComp, oTempComp, oBrwComp
	
	Default aDocs    := {}
	Default aPerg853 := {}
	
	Help(" ", 1, "TMSA85312") //-- O servico de negociacao informado nos parametros nao foi identificado em contrato vigente do cliente pagador do frete.

	//-- Valida o parametro MV_COMPSER
	If Empty(cCompSer)
		Help(" ", 1, "TMSA85310") //-- Informe o codigo de um componente para faturamento do servico adicional no parametro MV_COMPSER
		lRet := .F.
	Else
	
		dbSelectArea("DT3")
		DT3->(dbSetOrder(1)) //DT3_FILIAL+DT3_CODPAS
		If ! DT3->(MsSeek(xFilial("DT3") + cCompSer))
			Help(" ", 1, "TMSA85311", , " (MV_COMPSER: " + cCompSer + ")", 2, 1) //-- Componente de frete do parametro MV_COMPSER invalido
			lRet := .F.
		EndIf
	Endif
	
	If ! lRet
		Return lRet
	Else
		lRet := .F.
	EndIf

	//-- Modal que sera apresentado o componente de frete de servico adicional
	oDlgCom := FWDialogModal():New()
	oDlgCom:SetBackground(.F.)
	oDlgCom:SetTitle(STR0001 + " - " + ; //STR0001 'Geração Cobrança de Servico Adicional'
	                 STR0003) //STR0003 'Processar'
	oDlgCom:SetEscClose(.T.)
	oDlgCom:EnableAllClient()
	oDlgCom:CreateDialog()

	oPnlModal := oDlgCom:GetPanelMain()
	
	oFWLayer := FWLayer():New() //-- Container
	oFWLayer:Init(oPnlModal, .F., .T.) //-- Inicializa container
	
	cTitWin := STR0034 + " (MV_COMPSER)" //STR0034 'Componente de Frete de Cobrança de Servico Adicional'
	
	oFWLayer:AddLine('UP', 100, .F.) //-- Painel superior
	oFWLayer:AddCollumn('ALL', 100, .F., 'UP') //-- Adiciona uma "linha" com 100%
	oFWLayer:AddWindow('ALL', 'WINCOMP', cTitWin, 100, .F., .F., , 'UP')
	
	oPnlComp := oFWLayer:GetWinPanel('ALL', 'WINCOMP', 'UP')

	//-- Campos que serao apresentados no browse
	Aadd(aCpoComp, {"DT3", "DT3_CODPAS", .T., .T.,         , STR0038,  , .F.}) //STR0038 'Comp'
	Aadd(aCpoComp, {"DT3", "DT3_DESCRI", .T., .T.,         ,        ,  , .F.}) 
	Aadd(aCpoComp, {"DT1", "DT1_VALOR" , .T., .T., "VALDIG", STR0036,  , .T.}) //STR0036 'Digitado'
	Aadd(aCpoComp, {"DT8", "DT8_VALIMP", .T., .T.,         , STR0039,  , .F.}) //STR0039 'Imposto'
	Aadd(aCpoComp, {"DT8", "DT8_VALTOT", .T., .T.,         , STR0040,  , .F.}) //STR0040 'Digitado + Imposto'

	//-- Define estrutura do browse
	aRetStrBrw := GetStrBrw(aCpoComp)
	aStrComp   := aRetStrBrw[1]
	aCpoComp   := aRetStrBrw[4]

	//-- Tabela temporaria Componente de Frete de Cobrança de Servico Adicional
	oTempComp := FWTemporaryTable():New(cAliComp)
	oTempComp:SetFields(aStrComp)
	oTempComp:Create()

	//-- Cria o registro na tabela temporaria referente ao componente
	(cAliComp)->(RecLock(cAliComp, .T.))
	(cAliComp)->DT3_CODPAS := cCompSer
	(cAliComp)->DT3_DESCRI := Posicione("DT3", 1, xFilial("DT3") + cCompSer, "DT3_DESCRI")
	(cAliComp)->VALDIG     := 0
	(cAliComp)->DT8_VALIMP := 0
	(cAliComp)->DT8_VALTOT := 0
	(cAliComp)->(MsUnlock())
	
	aParCal := SetDefParC(aDocs, aPerg853, , , , ) //-- Parametros para chamar funcao de calculo

	//-- Criacao do browse
	oBrwComp:= FWBrowse():New()
	oBrwComp:SetDataTable(.T.)
	oBrwComp:SetEditCell(.T., {|| Iif (EdtBrCompP(cAliComp, aParCal, @aCmpFrt),;
		                               (oBrwComp:Refresh(), .T.),;
		                               .F.)})
	oBrwComp:SetChange({|| oBrwComp:GoColumn(3)}) // Ao navegar, sempre posiciona na coluna 'Digitado'
	oBrwComp:SetOwner(oPnlComp)
	oBrwComp:SetDescription(STR0034) //STR0034 'Componente de Frete de Cobrança de Serviço Adicional'
	oBrwComp:SetAlias(cAliComp)
	oBrwComp:SetColumns(aCpoComp)
	oBrwComp:DisableReport()
	oBrwComp:Activate()
	oBrwComp:Refresh(.T.)
	oBrwComp:GoTop(.T.)

	//-- Cria botoes de operacao
	Aadd(aButtons, {"", STR0029, {|| Iif (lRet := PrepGerDoc(aDocs, aPerg853, aParCal, aCmpFrt),; //STR0029 'Gerar Documento'
		                                  (oDlgCom:DeActivate(), .T.),;
		                                  .F.)}, , , .T., .F.})
	Aadd(aButtons, {"", STR0028, {|| oDlgCom:DeActivate()}, , , .T., .F.})
	oDlgCom:AddButtons(aButtons)

	//-- Ao inicializar a modal, atualiza o browse, seta o foco no browse e posiciona na coluna 'Digitado'
	oDlgCom:SetInitBlock({|| oBrwComp:Refresh(.T.),;
	                         oBrwComp:GoTop(.T.),;
							 oBrwComp:SetFocus(),;
							 oBrwComp:GoColumn(3)})
	oDlgCom:Activate()
	
	//-- Ao finalizar, elimina tabela temporaria
	oTempComp:Delete()

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EdtBrCompP
Função de edição de célula do browse de Componente de Frete de Cobrança de Serviço Adicional
Recalcula imposto e atualiza total
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 11/01/2017
@param [cAliComp], Caracter, Alias da tabela dos valores dos componentes
@param [aParCal], Array, Parâmetros utilizados no cálculo da composição do frete
@param [aCmpFrt], Array, Composição de frete para ser utilizada na geração do documento (retorno @)
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function EdtBrCompP(cAliComp, aParCal, aCmpFrt)

	Local aArea     := GetArea()
	Local aFrtCom   := {}
	Local aRetCal   := {}
	Local aCalFrt   := {}
	Local aErrCal   := {}
	Local cMsgErr   := ""
	Local nContador := 0
	Local lRet      := .T.
	
	Default cAliComp := ""
	Default aParCal  := {}
	Default aCmpFrt  := {}

	If (cAliComp)->VALDIG < 0
		Help(" ", 1, "TMSA85313") // Nao eh permitido componente com valor menor que 0
		lRet := .F.
	Else
	
		//-- Cria composicao apenas com o componente que esta tendo seu valor
		//-- digitado alterado para efetuar o calculo de imposto
		AAdd(aFrtCom, {(cAliComp)->DT3_DESCRI,; //--[01]DESCRICAO DO COMPONENTE
				        (cAliComp)->VALDIG,;     //--[02]VALOR DO COMPONENTE (LIQUIDO)
				        (cAliComp)->DT3_CODPAS,; //--[03]CODIGO DO COMPONENTE
				        '',;                     //--[04]ITEM x SD2
				        0,;                      //--[05]VALOR DOS IMPOSTOS
				        (cAliComp)->VALDIG,;     //--[06]VALOR DO COMPONENTE (BRUTO)
				        aParCal[ACALCDRORI],;    //--[07]REGIAO DE ORIGEM
				        aParCal[ACALCDRDES],;    //--[08]REGIAO DESTINO
				        '',;                     //--[09]TABELA DE FRETE
				        '',;                     //--[10]TIPO DA TABELA DE FRETE
				        '',;                     //--[11]SEQUENC. DA TABELA DE FRETE
				        '',;                     //--[12]**NAO USADO**
				        0,;                      //--[13]VALOR DE DESCONTO
				        0,;                      //--[14]VALOR DE ACRESCIMO
				        '2',;                    //--[15]CALCULADO PELO MINIMO (1=SIM/2=NAO)
						0,;                      //--[16]Indica o criterio de calculo do componente - Peso, Volume, Quantidade
						'',;                     //--[17]Codigo do Produto
						'',;                     //--[18]Codigo do Serviço
						'',;                     //--[19]Codigo do Cliente
						'',;                     //--[20]Loja do Cliente
						0,;                      //--[21]Percentual de Rateio do Componente
						'',;                     //--[22]Codigo da Negociação
						''} )                    //--[23]Indica se o componente é obrigatorio  
	
		AAdd(aFrtCom, {'Total do Frete',;     //--[01]DESCRICAO DO COMPONENTE
				        (cAliComp)->VALDIG,;  //--[02]VALOR DO COMPONENTE (LIQUIDO)
				        'TF',;                //--[03]CODIGO DO COMPONENTE
				        '',;                  //--[04]ITEM x SD2
				        0,;                   //--[05]VALOR DOS IMPOSTOS
				        (cAliComp)->VALDIG,;  //--[06]VALOR DO COMPONENTE (BRUTO)
				        aParCal[ACALCDRORI],; //--[07]REGIAO DE ORIGEM
				        aParCal[ACALCDRDES],; //--[08]REGIAO DESTINO
				        '',;                  //--[09]TABELA DE FRETE
				        '',;                  //--[10]TIPO DA TABELA DE FRETE
				        '',;                  //--[11]SEQUENC. DA TABELA DE FRETE
				        '',;                  //--[12]**NAO USADO**
				        0,;                   //--[13]VALOR DE DESCONTO
				        0,;                   //--[14]VALOR DE ACRESCIMO
				        '2',;				  //--[15]CALCULADO PELO MINIMO (1=SIM/2=NAO)
						0,;                   //--[16]Indica o criterio de calculo do componente - Peso, Volume, Quantidade
						'',;                  //--[17]Codigo do Produto
						'',;                  //--[18]Codigo do Serviço
						'',;                  //--[19]Codigo do Cliente
						'',;                  //--[20]Loja do Cliente
						0,;                   //--[21]Percentual de Rateio do Componente
						'',;                  //--[22]Codigo da Negociação
						''} )                 //--[23]Indica se o componente é obrigatorio               


		//-- Chama a funcao para calcular o valor de imposto do componente
		Processa({|| aRetCal := A050CalFrt("3"                , aParCal[ACALCLIREM], aParCal[ACALLOJREM], aParCal[ACALCDRORI], aParCal[ACALCLICAL], aParCal[ACALLOJCAL], aParCal[ACALCDRCAL], aParCal[ACALCLIDES], aParCal[ACALLOJDES],;
		                                   aParCal[ACALCDRDES], aParCal[ACALSQEDES], aParCal[ACALCLIDEV], aParCal[ACALLOJDEV], aParCal[ACALCODPRO], aParCal[ACALSERVIC], aParCal[ACALCODNEG], aParCal[ACALSERTMS], aParCal[ACALTIPTRA],;
		                                   aParCal[ACALDOCTMS], aParCal[ACALLOTNFC], aParCal[ACALTIPFRE], aParCal[ACALTIPNFC], aParCal[ACALSEQINS], aParCal[ACALVALMER], aParCal[ACALPESO]  , aParCal[ACALPESOM3], aParCal[ACALQTDVOL],;
		                                   aParCal[ACALMETRO3], aParCal[ACALKM],     aParCal[ACALQTDUNI], aParCal[ACALBASSEG], aParCal[ACALPRCPDG], aParCal[ACALCLIGEN], aParCal[ACALAJUAUT], aParCal[ACALVALINF], aParCal[ACALTIPVEI],;
		                                   aFrtCom            , aParCal[ACALCTRCLI], .T. )},;
		          STR0006,;     //STR0006 'Aguarde...'
		          STR0033, .F.) //STR0037 'Calculando impostos...'
		          
		aCalFrt := aRetCal[1]
		aErrCal := aRetCal[2, 2]

		//-- Ocorreram os seguintes erros durante o calculo
		If ! Empty(aErrCal) .And. Len(aErrCal) > 0
			For nContador := 1 To Len(aErrCal)
				If ! Empty(cMsgErr)
					cMsgErr += chr(10)
				EndIf
				cMsgErr += aErrCal[nContador, 1]
			Next nContador
			Help(" ", 1, "TMSA85308", , cMsgErr, 2, 1)
			lRet := .F.
		Else
		
			//-- Apresenta valores sugeridos pelo calculo
			If ! Empty(aCalFrt) .And. Len(aCalFrt) > 0
			
				aCmpFrt := {}
				//-- Atualiza a composição de frete que sera utilizada na geracao do documento
				aCmpFrt := aClone(aCalFrt)

				(cAliComp)->(RecLock(cAliComp, .F.))
				(cAliComp)->DT8_VALIMP := aCalFrt[1, 5]
				(cAliComp)->DT8_VALTOT := aCalFrt[1, 6]
				(cAliComp)->(MsUnlock())

			Else
				Help(" ", 1, "TMSA85309") //-- Nenhum componente/valor identificado
				lRet := .F.
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValServTab
O valor do Serviço Adicional será definido conforme componentes da tabela de frete informada 
para o serviço de negociação no contrato do cliente
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 11/01/2017
@param [aDocs], Array, Documentos selecionados
@param [aPerg853], Array, Informacoes do Pergunte TMSA853
@param [aContrat], Array, Array com as informações do contrato do cliente pagador do frete
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function ValServTab(aDocs, aPerg853, aContrat)

	Local lRet     := .F.
	Local aButtons := {} //-- Botoes da modal de processamento
	Local aBrAcumD := {} 
	Local aBrVlInf := {}
	Local aBrTpVei := {}
	Local oDlgVlr, oPnlModal, oFWLayer, oPnBrAcumD, oPnBrVlInf, oPnBrTpVei,;
	      oTTBrAcumD, oTTBrVlInf, oTTBrTpVei, oBrAcumD, oBrVlInf, oBrTpVei

	Default aDocs    := {}
	Default aPerg853 := {}
	Default aContrat := {}
	
	//-- CALCULO DO SERVICO
	//-- PASSO 1 - Apresentacao dos valores acumulados dos documentos selecionados / valores informados
	//--           Valores informados / Tipos de veiculos
	
	//-- Modal que serao apresentados os valores acumulados
	oDlgVlr := FWDialogModal():New()
	oDlgVlr:SetBackground(.F.)
	oDlgVlr:SetTitle(STR0001 + " - " + STR0003) //STR0001 'Cobrança de Servico Adicional'
	oDlgVlr:SetEscClose(.T.)
	oDlgVlr:EnableAllClient()
	oDlgVlr:CreateDialog()

	oPnlModal := oDlgVlr:GetPanelMain()
	
	oFWLayer := FWLayer():New() //-- Container
	oFWLayer:Init(oPnlModal, .F., .T.) //-- Inicializa container
	
	oFWLayer:AddLine('UP', 30, .F.) //-- Painel superior
	oFWLayer:AddCollumn('ALL', 100, .F., 'UP') //-- Adiciona uma "linha" com 100%
	oFWLayer:AddWindow('ALL', 'WINBRA', STR0023, 100, .F., .T., , 'UP') //STR0023 'Valores Acumulados dos Documentos Selecionados'
	
	oFWLayer:AddLine('DOWN', 70, .F.) //-- Painel inferior
	oFWLayer:AddCollumn('LEFT' , 50, .F., 'DOWN') //-- Adiciona uma "linha" com 50%
	oFWLayer:AddCollumn('RIGHT', 50, .F., 'DOWN') //-- Adiciona uma "linha" com 50%
	oFWLayer:AddWindow('LEFT' , 'WINBRB', STR0024, 100, .F., .T., , 'DOWN') //STR0024 'Valores Informados por Componente de Frete'
	oFWLayer:AddWindow('RIGHT', 'WINBRC', STR0025, 100, .F., .T., , 'DOWN') //STR0025 'Tipos de Veiculos por Componente de Frete'

	oFWLayer:SetColSplit('LEFT' , CONTROL_ALIGN_LEFT , 'DOWN')
	oFWLayer:SetColSplit('RIGHT', CONTROL_ALIGN_RIGHT, 'DOWN')
	
	oPnBrAcumD := oFWLayer:GetWinPanel('ALL'  , 'WINBRA', 'UP')
	oPnBrVlInf := oFWLayer:GetWinPanel('LEFT' , 'WINBRB', 'DOWN')
	oPnBrTpVei := oFWLayer:GetWinPanel('RIGHT', 'WINBRC', 'DOWN')
	
	aBrAcumD := DefBrAcumD(oPnBrAcumD, aDocs)           //-- Monta o browse Valores Acumulados dos Documentos Selecionados
	aBrVlInf := DefBrVlInf(oPnBrVlInf, aDocs, aContrat) //-- Monta o browse Valores Informados por Componente de Frete
	aBrTpVei := DefBrTpVei(oPnBrTpVei, aDocs, aContrat) //-- Monta o browse Tipos de Veiculos por Componente de Frete

	oTTBrAcumD := aBrAcumD[1]
	oTTBrVlInf := aBrVlInf[1]
	oTTBrTpVei := aBrTpVei[1]

	oBrAcumD := aBrAcumD[2]
	oBrVlInf := aBrVlInf[2]
	oBrTpVei := aBrTpVei[2]

	Aadd(aButtons, {"", STR0027, {|| Iif(lRet := CalServTab(aDocs, aPerg853, aContrat, oTTBrAcumD:GetAlias(), oTTBrVlInf:GetAlias(), oTTBrTpVei:GetAlias()), oDlgVlr:DeActivate(), .F.)}, , , .T., .F.})
	Aadd(aButtons, {"", STR0028, {|| oDlgVlr:DeActivate()}, , , .T., .F.})
	
	oDlgVlr:AddButtons(aButtons)

	//-- Ao inicializar a modal, atualiza os browses, seta o foco no primeiro browse e posiciona na coluna primeira coluna
	oDlgVlr:SetInitBlock({|| oBrAcumD:SetFocus(),;
							 oBrAcumD:GoColumn(1)})
	oDlgVlr:Activate()
	
	//-- Ao finalizar, elimina tabelas temporarias
	oTTBrAcumD:Delete()
	oTTBrVlInf:Delete()
	oTTBrTpVei:Delete()

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DefBrAcumD
Monta o browse referente aos Valores Acumulados dos Documentos Selecionados
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@param [oPanel], Objeto, Alias que será utilizado no browse
@param [aDocs], Array, Documentos selecionados
@return aRet Array
@obs aRet[1] oTTBrAcumD Objeto FWTemporaryTable
@obs aRet[2] oBrowAcumD Objeto FWBrowse
/*/
//-------------------------------------------------------------------------------------------------
Static Function DefBrAcumD(oPanel, aDocs)

	Local aArea       := GetArea()
	Local aRet        := {}
	Local aCpBrAcumD  := {}
	Local aRetStrBrw  := {} //-- Array retorno da funcao GetStrBrw()
	Local aStBrAcumD  := {}
	Local cAlBrAcumD  := GetNextAlias()
	Local nContador   := 0
	Local oTTBrAcumD, oBrowAcumD
	
	Default oPanel  := Nil
	Default aDocs   := {}

	//-- Campos que serao apresentados no browse
	Aadd(aCpBrAcumD, {"DTC", "DTC_KM"    , .T., .T., , , GetSX3Cache("DTC_KM","X3_TAMANHO"), .T.})   
	Aadd(aCpBrAcumD, {"DTC", "DTC_VALOR" , .T., .T., , , GetSX3Cache("DTC_VALOR","X3_TAMANHO"), .T.})
	Aadd(aCpBrAcumD, {"DTC", "DTC_PESOM3", .T., .T., , , GetSX3Cache("DTC_PESOM3","X3_TAMANHO"), .T.})
	Aadd(aCpBrAcumD, {"DTC", "DTC_METRO3", .T., .T., , , GetSX3Cache("DTC_METRO3","X3_TAMANHO"), .T.})
	Aadd(aCpBrAcumD, {"DTC", "DTC_QTDVOL", .T., .T., , , GetSX3Cache("DTC_QTDVOL","X3_TAMANHO"), .T.})
	Aadd(aCpBrAcumD, {"DTC", "DTC_BASSEG", .T., .T., , , GetSX3Cache("DTC_BASSEG","X3_TAMANHO"), .T.})
	Aadd(aCpBrAcumD, {"DTC", "DTC_QTDUNI", .T., .T., , , GetSX3Cache("DTC_QTDUNI","X3_TAMANHO"), .T.})
	Aadd(aCpBrAcumD, {"DTC", "DTC_PESO"  , .T., .T., , , GetSX3Cache("DTC_PESO","X3_TAMANHO"), .T.})
	
	//-- Define estrutura do browse
	aRetStrBrw := GetStrBrw(aCpBrAcumD)
	aStBrAcumD := aRetStrBrw[1]
	aCpBrAcumD := aRetStrBrw[4]

	//-- Tabela temporaria Valores Acumulados dos Documentos Selecionados
	oTTBrAcumD := FWTemporaryTable():New(cAlBrAcumD)
	oTTBrAcumD:SetFields(aStBrAcumD)
	oTTBrAcumD:Create()

	//-- Cria o registro na tabela temporaria com os valores acumulados
	(cAlBrAcumD)->(RecLock(cAlBrAcumD, .T.))
	For nContador := 1 To Len(aDocs)
		(cAlBrAcumD)->DTC_KM     += aDocs[nContador, ADOCKM]
		(cAlBrAcumD)->DTC_VALOR  += aDocs[nContador, ADOCVALOR]
		(cAlBrAcumD)->DTC_PESOM3 += aDocs[nContador, ADOCPESOM3]
		(cAlBrAcumD)->DTC_METRO3 += aDocs[nContador, ADOCMETRO3]
		(cAlBrAcumD)->DTC_QTDVOL += aDocs[nContador, ADOCQTDVOL]
		(cAlBrAcumD)->DTC_BASSEG += aDocs[nContador, ADOCBASSEG]
		(cAlBrAcumD)->DTC_QTDUNI += aDocs[nContador, ADOCQTDUNI]
		(cAlBrAcumD)->DTC_PESO   += aDocs[nContador, ADOCPESO]
	Next nContador
	(cAlBrAcumD)->(MsUnlock())
	
	//-- Criacao do browse
	oBrowAcumD:= FWBrowse():New()
	oBrowAcumD:SetDataTable(.T.)
	oBrowAcumD:SetPreEditCell({|| dbSelectArea(cAlBrAcumD), .T.})
	oBrowAcumD:SetEditCell(.T.)
	oBrowAcumD:SetOwner(oPanel)
	oBrowAcumD:SetDescription(STR0023) //STR0023 'Valores Acumulados dos Documentos Selecionados'
	oBrowAcumD:SetAlias(cAlBrAcumD)
	oBrowAcumD:SetColumns(aCpBrAcumD)
	oBrowAcumD:DisableReport()
	oBrowAcumD:Activate()
	oBrowAcumD:Refresh(.T.)
	oBrowAcumD:GoTop(.T.)

	aRet := {oTTBrAcumD, oBrowAcumD}

	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DefBrVlInf
Monta o browse referente aos Valores Informados por Componente de Frete
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@param [oPanel], Objeto, Alias que será utilizado no browse
@param [aDocs], Array, Documentos selecionados
@param [aContrat], Array, Array com as informações do contrato do cliente pagador do frete
@return aRet Array
@obs aRet[1] oTTBrVlInf Objeto FWTemporaryTable
@obs aRet[2] oBrowVlInf Objeto FWBrowse
/*/
//-------------------------------------------------------------------------------------------------
Static Function DefBrVlInf(oPanel, aDocs, aContrat)

	Local aArea      := GetArea()
	Local aRet       := {}
	Local aCpBrVlInf := {}
	Local aRetStrBrw := {} //-- Array retorno da funcao GetStrBrw()
	Local aStBrVlInf := {}
	Local aCmpInf    := {} //-- Array com os componentes de valor informado
	Local cAlBrVlInf := GetNextAlias()
	Local cAliasQry  := GetNextAlias()
	Local cWhereComp := ""
	Local cQuery     := ""
	Local cTabFre    := aContrat[1, 3]
	Local cTipTab    := aContrat[1, 4]
	Local nContador  := 0
	Local oBrowVlInf, oTTBrVlInf
	
	Default oPanel   := Nil
	Default aDocs    := {}
	Default aContrat := {}

	//-- Campos que serao apresentados no browse
	Aadd(aCpBrVlInf, {"DVR", "DVR_CODPAS", .T., .T., ,        , GetSX3Cache("DVR_CODPAS","X3_TAMANHO") , .F.})
	Aadd(aCpBrVlInf, {"DVR", "DVR_DESPAS", .T., .T., ,        , GetSX3Cache("DVR_DESPAS","X3_TAMANHO") , .F.})
	Aadd(aCpBrVlInf, {"DVR", "DVR_VALOR" , .T., .T., , STR0026, GetSX3Cache("DVR_VALOR","X3_TAMANHO")  , .T.})

	//-- Define estrutura do browse
	aRetStrBrw := GetStrBrw(aCpBrVlInf)
	aStBrVlInf := aRetStrBrw[1]
	aCpBrVlInf := aRetStrBrw[4]

	//-- Tabela temporaria Valores Informados por Componente de Frete
	oTTBrVlInf := FWTemporaryTable():New(cAlBrVlInf)
	oTTBrVlInf:SetFields(aStBrVlInf)
	oTTBrVlInf:AddIndex("INDEX1", {"DVR_CODPAS"})
	oTTBrVlInf:Create()
	
	//-- Obtem componentes de valor informado da tabela
	aCmpInf := TmsCompFre(StrZero(7,Len(DT3->DT3_TIPFAI)), cTabFre, cTipTab)
	
	//-- Se houver componentes de valor informado
	If (! Empty(aCmpInf) .And. Len(aCmpInf) > 0)
	
		//-- Cria registro na tabela temporaria para cada componente
		For nContador := 1 To Len(aCmpInf)
			(cAlBrVlInf)->(RecLock(cAlBrVlInf, .T.))
			(cAlBrVlInf)->DVR_CODPAS := aCmpInf[nContador, 1]
			(cAlBrVlInf)->DVR_DESPAS := aCmpInf[nContador, 2]
			(cAlBrVlInf)->DVR_VALOR  := 0
			(cAlBrVlInf)->(MsUnlock())
		Next nContador
		
		//-- Cria condicao abrangendo todos os componentes de valor informado da tabela de frete
		cWhereComp := ""
		For nContador := 1 To Len(aCmpInf)
			If Empty(cWhereComp)
				cWhereComp += " AND ( DVR_CODPAS = '" + aCmpInf[nContador, 1] + "'"
			Else
				cWhereComp += "    OR DVR_CODPAS = '" + aCmpInf[nContador, 1] + "'"
			EndIf
		Next nContador
		cWhereComp += " ) "
		
		//-- Identifica os valores informados de cada documento selecionado
		For nContador := 1 To Len(aDocs)
		
			cQuery := "SELECT DVR_CODPAS, DVR_VALOR"
			cQuery += "  FROM " + RetSqlName("DVR")+ " DVR "
			cQuery += " WHERE DVR_FILIAL = '" + xFilial("DVR") + "'"
			cQuery += "   AND DVR_FILORI = '" + aDocs[nContador, ADOCFILORI] + "'"
			cQuery += "   AND DVR_LOTNFC = '" + aDocs[nContador, ADOCLOTNFC] + "'"
			cQuery += "   AND DVR_CLIREM = '" + aDocs[nContador, ADOCCLIREM] + "'"
			cQuery += "   AND DVR_LOJREM = '" + aDocs[nContador, ADOCLOJREM] + "'"
			cQuery += "   AND DVR_CLIDES = '" + aDocs[nContador, ADOCCLIDES] + "'"
			cQuery += "   AND DVR_LOJDES = '" + aDocs[nContador, ADOCLOJDES] + "'"
			cQuery += "   AND DVR_CODNEG = '" + aDocs[nContador, ADOCCODNEG] + "'"
			cQuery += "   AND DVR_SERVIC = '" + aDocs[nContador, ADOCSERVIC] + "'"
			cQuery += "   AND DVR_NUMNFC = '" + aDocs[nContador, ADOCNUMNFC] + "'"
			cQuery += "   AND DVR_SERNFC = '" + aDocs[nContador, ADOCSERNFC] + "'"
			cQuery += "   AND DVR_CODPRO = '" + aDocs[nContador, ADOCCODPRO] + "'"
			cQuery += cWhereComp
			cQuery += "   AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
			
			//-- Se houver valor informado para o documento de um componente que compoe a tabela, soma para sugestao
			While (cAliasQry)->(!Eof())
				(cAlBrVlInf)->(dbSetOrder(1))
				If (cAlBrVlInf)->(MsSeek((cAliasQry)->DVR_CODPAS))
					(cAlBrVlInf)->(RecLock(cAlBrVlInf, .F.))
					(cAlBrVlInf)->DVR_VALOR += (cAliasQry)->DVR_VALOR
					(cAlBrVlInf)->(MsUnlock())
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo
			
			(cAliasQry)->(dbCloseArea())

		Next nContador
	EndIf
	
	//-- Criacao do browse
	oBrowVlInf:= FWBrowse():New()
	oBrowVlInf:SetDataTable(.T.)
	oBrowVlInf:SetPreEditCell({|| dbSelectArea(cAlBrVlInf), .T.})
	oBrowVlInf:SetEditCell(.T.)
	oBrowVlInf:SetOwner(oPanel)
	oBrowVlInf:SetDescription(STR0024) //STR0024 'Valores Informados por Componente de Frete'
	oBrowVlInf:SetAlias(cAlBrVlInf)
	oBrowVlInf:SetColumns(aCpBrVlInf)
	oBrowVlInf:DisableReport()
	oBrowVlInf:Activate()
	oBrowVlInf:Refresh(.T.)
	oBrowVlInf:GoTop(.T.)
	
	aRet := {oTTBrVlInf, oBrowVlInf}

	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DefBrTpVei
Monta o browse referente aos Tipos de Veículos por Componente de Frete
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@param [oPanel], Objeto, Alias que será utilizado no browse
@param [aDocs], Array, Documentos selecionados
@param [aContrat], Array, Array com as informações do contrato do cliente pagador do frete
@return aRet Array
@obs aRet[1] oTTBrTpVei Objeto FWTemporaryTable
@obs aRet[2] oBrowTpVei Objeto FWBrowse
/*/
//-------------------------------------------------------------------------------------------------
Static Function DefBrTpVei(oPanel, aDocs, aContrat)

	Local aArea      := GetArea()
	Local aRet       := {}
	Local aCpBrTpVei := {}
	Local aRetStrBrw := {} //-- Array retorno da funcao GetStrBrw()
	Local aStBrTpVei := {}
	Local cAlBrTpVei := GetNextAlias()
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local cWhereTipV := ""
	Local cTabFre    := aContrat[1, 3]
	Local cTipTab    := aContrat[1, 4]
	Local nContador  := 0
	Local oBrowTpVei, oTTBrTpVei
	
	Default oPanel   := Nil
	Default aDocs    := {}
	Default aContrat := {}

	//-- Campos que serao apresentados no browse
	Aadd(aCpBrTpVei, {"DVU", "DVU_TIPVEI", .T., .T., , , GetSX3Cache("DVU_TIPVEI","X3_TAMANHO") , .F.})
	Aadd(aCpBrTpVei, {"DVU", "DVU_DESVEI", .T., .T., , , GetSX3Cache("DVU_DESVEI","X3_TAMANHO") , .F.})
	Aadd(aCpBrTpVei, {"DVU", "DVU_QTDVEI", .T., .T., , , GetSX3Cache("DVU_QTDVEI","X3_TAMANHO") , .T.})

	//-- Define estrutura do browse
	aRetStrBrw := GetStrBrw(aCpBrTpVei)
	aStBrTpVei := aRetStrBrw[1]
	aCpBrTpVei := aRetStrBrw[4]

	//-- Tabela temporaria Tipos de Veiculos por Componente de Frete
	oTTBrTpVei := FWTemporaryTable():New(cAlBrTpVei)
	oTTBrTpVei:SetFields(aStBrTpVei)
	oTTBrTpVei:AddIndex("INDEX1", {"DVU_TIPVEI"})
	oTTBrTpVei:Create()
	
	//-- Identifica todos os componentes da tabela de frete que indicam tipo de veiculo
	cQuery := " SELECT DVE.DVE_CODPAS, DT3.DT3_DESCRI, DT3.DT3_TIPVEI, DUT.DUT_DESCRI "
	cQuery += "   FROM " + RetSqlName("DVE") + " DVE "

	cQuery += "  INNER JOIN " + RetSqlName("DT3") + " DT3 "
	cQuery += "     ON DT3.DT3_FILIAL  = '" + xFilial('DT3') + "' "
	cQuery += "    AND DT3.DT3_CODPAS  = DVE.DVE_CODPAS "
	cQuery += "    AND DT3.DT3_TIPVEI <> '" + Space(TamSX3("DT3_TIPVEI")[2]) + "' "
	cQuery += "    AND DT3.D_E_L_E_T_  = ' ' "
	
	cQuery += "   LEFT JOIN " + RetSqlName("DUT") + " DUT "
	cQuery += "     ON DUT.DUT_FILIAL = '" + xFilial('DUT') + "' "
	cQuery += "    AND DUT.DUT_TIPVEI = DT3.DT3_TIPVEI "
	cQuery += "    AND DUT.D_E_L_E_T_ = ' ' "
	
	cQuery += "  WHERE DVE.DVE_FILIAL = '" + xFilial('DVE') + "' "
	cQuery += "    AND DVE.DVE_TABFRE = '" + cTabFre + "' "
	cQuery += "    AND DVE.DVE_TIPTAB = '" + cTipTab + "' "
	cQuery += "    AND DVE.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
	
	cWhereTipV := ""
	
	//-- Cria registro na tabela temporaria para cada tipo de veiculo
	While (cAliasQry)->(!Eof())
	
		//-- Cria somente um registro por tipo de veiculo
		(cAlBrTpVei)->(dbSetOrder(1))
		If ! (cAlBrTpVei)->(MsSeek((cAliasQry)->DT3_TIPVEI))
			(cAlBrTpVei)->(RecLock(cAlBrTpVei, .T.))
			(cAlBrTpVei)->DVU_TIPVEI := (cAliasQry)->DT3_TIPVEI
			(cAlBrTpVei)->DVU_DESVEI := (cAliasQry)->DUT_DESCRI
			(cAlBrTpVei)->DVU_QTDVEI := 0
			(cAlBrTpVei)->(MsUnlock())
			
			//-- Cria condicao abrangendo todos os tipos de veiculos
			If Empty(cWhereTipV)
				cWhereTipV += " AND ( DVU_TIPVEI = '" + (cAliasQry)->DT3_TIPVEI + "'"
			Else
				cWhereTipV += "    OR DVU_TIPVEI = '" + (cAliasQry)->DT3_TIPVEI + "'"
			EndIf
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	
	cWhereTipV += " ) "
	
	//-- Somente se houver tipo de veiculo em algum componente
	If (cAlBrTpVei)->(RecCount()) > 0
	
		//-- Identifica os tipos de veiculos de cada documento selecionado
		For nContador := 1 To Len(aDocs)
		
			cQuery := " SELECT DVU_TIPVEI, DVU_QTDVEI "
			cQuery += "   FROM " + RetSqlName("DVU")
			cQuery += "  WHERE DVU_FILIAL = '" + xFilial('DVU') + "' "
			cQuery += "    AND DVU_FILORI = '" + aDocs[nContador, ADOCFILORI] + "' "
			cQuery += "    AND DVU_NUMNFC = '" + aDocs[nContador, ADOCNUMNFC] + "' "
			cQuery += "    AND DVU_SERNFC = '" + aDocs[nContador, ADOCSERNFC] + "' "
			cQuery += "    AND DVU_CLIREM = '" + aDocs[nContador, ADOCCLIREM] + "' "
			cQuery += "    AND DVU_LOJREM = '" + aDocs[nContador, ADOCLOJREM] + "' "
			cQuery += "    AND DVU_LOTNFC = '" + aDocs[nContador, ADOCLOTNFC] + "' "  
			cQuery += cWhereTipV
			cQuery += "    AND D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
	
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
			
			//-- Se houver tipo de veiculo para o documento, soma para sugestao
			While (cAliasQry)->(!Eof())
				(cAlBrTpVei)->(dbSetOrder(1))
				If (cAlBrTpVei)->(MsSeek((cAliasQry)->DVU_TIPVEI))
					(cAlBrTpVei)->(RecLock(cAlBrTpVei, .F.))
					(cAlBrTpVei)->DVU_QTDVEI += (cAliasQry)->DVU_QTDVEI
					(cAlBrTpVei)->(MsUnlock())
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo
			
			(cAliasQry)->(dbCloseArea())
	
		Next nContador
	EndIf

	//-- Criacao do browse
	oBrowTpVei:= FWBrowse():New()
	oBrowTpVei:SetDataTable(.T.)
	oBrowTpVei:SetPreEditCell({|| dbSelectArea(cAlBrTpVei), .T.})
	oBrowTpVei:SetEditCell(.T.)
	oBrowTpVei:SetOwner(oPanel)
	oBrowTpVei:SetDescription(STR0025) //STR0025 'Tipos de Veiculos por Componente de Frete'
	oBrowTpVei:SetAlias(cAlBrTpVei)
	oBrowTpVei:SetColumns(aCpBrTpVei)
	oBrowTpVei:DisableReport()
	oBrowTpVei:Activate()
	oBrowTpVei:Refresh(.T.)
	oBrowTpVei:GoTop(.T.)
	
	aRet := {oTTBrTpVei, oBrowTpVei}
	
	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CalServTab
Calcula os componentes da tabela de frete do serviço de negociação com base nos valores acumulados
e informados pelo usuário
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@param [aDocs], Array, Documentos selecionados
@param [aPerg853], Array, Informacoes do Pergunte TMSA853
@param [aContrat], Array, Contrato do cliente
@param [cAlBrAcumD], Caracter, Alias Valores Acumulados dos Documentos Selecionados
@param [cAlBrVlInf], Caracter, Alias Valores Informados por Componente de Frete
@param [cAlBrTpVei], Caracter, Alias Tipos de Veículos por Componente de Frete
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function CalServTab(aDocs, aPerg853, aContrat, cAlBrAcumD, cAlBrVlInf, cAlBrTpVei)

	Local aArea     := GetArea()
	Local lRet      := .F.
	Local cMsgErr   := ""
	Local aCalFret  := {}
	Local aRetCal   := {}
	Local aErrCal   := {}
	Local aParCal   := {}
	Local nContador := 0
	
	Default aDocs      := {}
	Default aPerg853   := {}
	Default aContrat   := {}
	Default cAlBrAcumD := ""
	Default cAlBrVlInf := ""
	Default cAlBrTpVei := ""
	
	aParCal := SetDefParC(aDocs, aPerg853, aContrat, cAlBrAcumD, cAlBrVlInf, cAlBrTpVei)

	//-- Chama a funcao de calculo para retornar os valores indicados para cada componente
	//-- da tabela de frete do servico de negociacao
	//-- Processa query
	Processa({|| aRetCal := A050CalFrt(aParCal[ACALTIPCAL], aParCal[ACALCLIREM], aParCal[ACALLOJREM], aParCal[ACALCDRORI], aParCal[ACALCLICAL], aParCal[ACALLOJCAL], aParCal[ACALCDRCAL], aParCal[ACALCLIDES], aParCal[ACALLOJDES],;
	                                   aParCal[ACALCDRDES], aParCal[ACALSQEDES], aParCal[ACALCLIDEV], aParCal[ACALLOJDEV], aParCal[ACALCODPRO], aParCal[ACALSERVIC], aParCal[ACALCODNEG], aParCal[ACALSERTMS], aParCal[ACALTIPTRA],;
	                                   aParCal[ACALDOCTMS], aParCal[ACALLOTNFC], aParCal[ACALTIPFRE], aParCal[ACALTIPNFC], aParCal[ACALSEQINS], aParCal[ACALVALMER], aParCal[ACALPESO]  , aParCal[ACALPESOM3], aParCal[ACALQTDVOL],;
	                                   aParCal[ACALMETRO3], aParCal[ACALKM]    , aParCal[ACALQTDUNI], aParCal[ACALBASSEG], aParCal[ACALPRCPDG], aParCal[ACALCLIGEN], aParCal[ACALAJUAUT], aParCal[ACALVALINF], aParCal[ACALTIPVEI],;
	                                   aParCal[ACALFRTCOM], aParCal[ACALCTRCLI], .T. )},;
	          STR0006,;     //STR0006 'Aguarde...'
	          STR0037, .F.) //STR0037 'Calculando composicao de frete...'

	aCalFret            := aRetCal[1]
	aErrCal             := aRetCal[2, 2]
	aParCal[ACALSEQTAB] := aRetCal[2, 3] //-- Indica a sequencia da tabela de frete que foi utilizada

	//-- Ocorreram os seguintes erros durante o calculo
	If ! Empty(aErrCal) .And. Len(aErrCal) > 0
		For nContador := 1 To Len(aErrCal)
			If ! Empty(cMsgErr)
				cMsgErr += chr(10)
			EndIf
			cMsgErr += aErrCal[nContador, 1]
		Next nContador
		Help(" ", 1, "TMSA85308", , cMsgErr, 2, 1)
	Else
	
		//-- Apresenta valores sugeridos pelo calculo
		If ! Empty(aCalFret) .And. Len(aCalFret) > 0
		
			//-- Chama funcao para apresentacao dos valores dos componentes calculados
			If VisCompFrt(aDocs, aPerg853, aParCal, aCalFret)
				lRet := .T.
			EndIf
		Else
			Help(" ", 1, "TMSA85309") //-- Nenhum componente/valor identificado
		EndIf
	EndIf
	
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetDefParC
Monta array com parâmetros que serão passados para a função de cálculo A050CalFrt
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 26/01/2017
@param [aDocs], Array, Documentos selecionados
@param [aPerg853], Array, Informacoes do Pergunte TMSA853
@param [aContrat], Array, Contrato do cliente (opcional)
@param [cAlBrAcumD], Caracter, Alias Valores Acumulados dos Documentos Selecionados (opcional)
@param [cAlBrVlInf], Caracter, Alias Valores Informados por Componente de Frete (opcional)
@param [cAlBrTpVei], Caracter, Alias Tipos de Veículos por Componente de Frete (opcional)
@param [aFrtCom], Array, Composição de frete (opcional)
@return aParCal Array que contém todos os parâmetros para a função A050CalFrt
/*/
//-------------------------------------------------------------------------------------------------
Static Function SetDefParC(aDocs, aPerg853, aContrat, cAlBrAcumD, cAlBrVlInf, cAlBrTpVei, aFrtCom)

	Local aArBrAcumD := {}
	Local aArBrVlInf := {}
	Local aArBrTpVei := {}
	Local cCdrOri    := ""
	Local cCdrCal    := ""
	Local cServic    := ""
	Local cSerTms    := ""
	Local cTipTra    := ""
	Local cDocTms    := ""
	Local cTipFre    := ""
	Local cCodPro    := ""
	Local cTipNFC    := ""
	Local aValInf    := {}
	Local aTipVei    := {}
	Local aParCal    := {}
	Local nContador  := 0
	Local nKm        := 0
	Local nValor     := 0
	Local nPesoM3    := 0
	Local nMetroM3   := 0
	Local nQtdVol    := 0
	Local nBasSeg    := 0
	Local nQtdUni    := 0
	Local nPeso      := 0
	Local lCliGen    := .T.
	Local lAjuAut    := .F.
	Local lPrcPdg    := .T.
	
	Default aDocs      := {}
	Default aPerg853   := {}
	Default aContrat   := {}
	Default aFrtCom    := {}
	Default cAlBrAcumD := ""
	Default cAlBrVlInf := ""
	Default cAlBrTpVei := ""
	
	//-- Obtem informacoes: SERTMS e TIPTRA do servico de negociacao informado no Pergunte
	dbSelectArea("DC5")
	DC5->(dbSetOrder(1)) //DC5_FILIAL+DC5_SERVIC+DC5_ORDEM 
	If DC5->(MsSeek(xFilial("DC5") + aPerg853[APERSERVIC]))
		cServic := DC5->DC5_SERVIC
		cSerTms := DC5->DC5_SERTMS
		cTipTra := DC5->DC5_TIPTRA
	EndIf
	
	//-- Obtem regiao de origem do cliente
	cCdrOri := Posicione("SA1", 1, xFilial("SA1") + aPerg853[APERCLIDEV] + aPerg853[APERLOJDEV], "A1_CDRDES")
	If Empty(cCdrOri)
		cCdrOri := SuperGetMv("MV_CDRORI", , "") //-- Regiao de origem da filial
	EndIf
	cCdrCal := cCdrOri
	
	cDocTms := StrZero(5, Len(DC5->DC5_DOCTMS)) //-- 5 - Nota fiscal
	cTipFre := StrZero(1, Len(DT6->DT6_TIPFRE)) //-- 1 - CIF
	cTipNFC := StrZero(0, Len(DV1->DV1_TIPNFC)) //-- 0 - Normal
	cCodPro := Space(Len(SB1->B1_COD))          //-- Produto em branco
		
	//-- Obtem valores acumulados para passar como parametro para a funcao de calculo
	If ! Empty(cAlBrAcumD)
	
		aArBrAcumD := (cAlBrAcumD)->(GetArea())
		
		(cAlBrAcumD)->(dbGoTop())
		While (cAlBrAcumD)->(!Eof())
			nKm      := (cAlBrAcumD)->DTC_KM
			nValor   := (cAlBrAcumD)->DTC_VALOR
			nPesoM3  := (cAlBrAcumD)->DTC_PESOM3
			nMetroM3 := (cAlBrAcumD)->DTC_METRO3
			nQtdVol  := (cAlBrAcumD)->DTC_QTDVOL
			nBasSeg  := (cAlBrAcumD)->DTC_BASSEG
			nQtdUni  := (cAlBrAcumD)->DTC_QTDUNI
			nPeso    := (cAlBrAcumD)->DTC_PESO
			(cAlBrAcumD)->(dbSkip())
		EndDo
		
		RestArea(aArBrAcumD)
	Else

		//-- Percorre os documentos selecionados e
		//-- acumula valores de todos os documentos selecionados
		For nContador := 1 To Len(aDocs)
			nKm      += aDocs[nContador, ADOCKM]
			nValor   += aDocs[nContador, ADOCVALOR]
			nPesoM3  += aDocs[nContador, ADOCPESOM3]
			nMetroM3 += aDocs[nContador, ADOCMETRO3]
			nQtdVol  += aDocs[nContador, ADOCQTDVOL]
			nBasSeg  += aDocs[nContador, ADOCBASSEG]
			nQtdUni  += aDocs[nContador, ADOCQTDUNI]
			nPeso    += aDocs[nContador, ADOCPESO]
		Next nContador
	EndIf
	
	//-- Obtem valores informados para passar como parametro para a funcao de calculo
	If ! Empty(cAlBrVlInf)
		
		aArBrVlInf := (cAlBrVlInf)->(GetArea())

		(cAlBrVlInf)->(dbGoTop())
		While (cAlBrVlInf)->(!Eof())
			AAdd(aValInf, {(cAlBrVlInf)->DVR_CODPAS, (cAlBrVlInf)->DVR_VALOR, .F.})
			(cAlBrVlInf)->(dbSkip())
		EndDo
		
		RestArea(aArBrVlInf)
	EndIf
	
	//-- Obtem tipos de veiculos para passar como parametro para a funcao de calculo
	If ! Empty(cAlBrTpVei)
	
		aArBrTpVei := (cAlBrTpVei)->(GetArea())
		
		(cAlBrTpVei)->(dbGoTop())
		While (cAlBrTpVei)->(!Eof())
			AAdd(aTipVei, {(cAlBrTpVei)->DVU_TIPVEI, (cAlBrTpVei)->DVU_QTDVEI})
			(cAlBrTpVei)->(dbSkip())
		EndDo
		
		RestArea(aArBrTpVei)
	EndIf
	
	aParCal := {"1"     , aPerg853[APERCLIDEV], aPerg853[APERLOJDEV], cCdrOri             , aPerg853[APERCLIDEV], aPerg853[APERLOJDEV], cCdrCal, aPerg853[APERCLIDEV], aPerg853[APERLOJDEV],;
	            cCdrOri ,                     , aPerg853[APERCLIDEV], aPerg853[APERLOJDEV], cCodPro             , cServic             ,        , cSerTms             , cTipTra             ,;
	            cDocTms ,                     , cTipFre             , cTipNFC             ,                     , nValor              , nPeso  , nPesoM3             , nQtdVol             ,;
	            nMetroM3, nKm                 , nQtdUni             , nBasSeg             , lPrcPdg             , lCliGen             , lAjuAut, aValInf             , aTipVei             ,;
	            aFrtCom , aContrat            , ""}

Return aParCal

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VisCompFrt
Apresenta os componentes da tabela de frete do serviço de negociação calculados com base nos valores
acumulados e informados pelo usuário para verificação e/ou edição para assim efetuar a geração do
documento fiscal caso confirmado pelo usuário
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 11/01/2017
@param [aDocs], Array, Documentos selecionados
@param [aPerg853], Array, Informacoes do Pergunte TMSA853
@param [aParCal], Array, Parâmetros utilizados no cálculo da composição do frete
@param [aCalFret], Array, Valores dos componentes calculados
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function VisCompFrt(aDocs, aPerg853, aParCal, aCalFret)

	Local aButtons   := {}
	Local aCpoComp   := {}
	Local aRetStrBrw := {} //-- Array retorno da funcao GetStrBrw()
	Local aStrComp   := {}
	Local aContrat   := {}
	Local cAliComp   := GetNextAlias()
	Local cTitWin    := ""
	Local lRet       := .F.
	Local nContador  := 0
	Local oDlgCom, oPnlModal, oFWLayer, oPnlComp, oTempComp, oBrwComp
	
	Default aDocs    := {}
	Default aPerg853 := {}
	Default aParCal  := {}
	Default aCalFret := {}
	
	aContrat := aParCal[ACALCTRCLI]
	
	//-- Modal que serao apresentados os valores dos componentes de frete
	oDlgCom := FWDialogModal():New()
	oDlgCom:SetBackground(.F.)
	oDlgCom:SetTitle(STR0027) //STR0027 'Calcular Servico'
	oDlgCom:SetEscClose(.T.)
	oDlgCom:EnableAllClient()
	oDlgCom:CreateDialog()

	oPnlModal := oDlgCom:GetPanelMain()
	
	oFWLayer := FWLayer():New() //-- Container
	oFWLayer:Init(oPnlModal, .F., .T.) //-- Inicializa container
	
	//-- Titulo da Window
	cTitWin := STR0030 //STR0030 'Valores dos Componentes de Frete'
	cTitWin += " (" + STR0061 + ": " //STR0061 'Negociacao'
	cTitWin += aPerg853[APERCODNEG] + ", "
	cTitWin += STR0012 + ": " //STR0012 'Servico'
	cTitWin += aPerg853[APERSERVIC] + ", "
	cTitWin += STR0031 + ": " //STR0031 'Tabela'
	cTitWin += aContrat[1, 3] + " / " + aContrat[1, 4] + ")"
	
	//-- Linha, coluna e window superior
	oFWLayer:AddLine('UP', 100, .F.) //-- Painel superior
	oFWLayer:AddCollumn('ALL', 100, .F., 'UP') //-- Adiciona uma "linha" com 100%
	oFWLayer:AddWindow('ALL', 'WINCOMP', cTitWin, 100, .F., .F., , 'UP')
	
	oPnlComp := oFWLayer:GetWinPanel('ALL', 'WINCOMP', 'UP')

	//-- Campos que serao apresentados no browse
	Aadd(aCpoComp, {"DT3", "DT3_CODPAS", .T., .T.,         , STR0038,  , .F.}) //STR0038 'Comp'
	Aadd(aCpoComp, {"DT3", "DT3_DESCRI", .T., .T.,         ,        ,  , .F.}) 
	Aadd(aCpoComp, {"DVE", "DVE_COMOBR", .T., .F.,         ,        ,  , .F.}) 
	Aadd(aCpoComp, {"DT1", "DT1_VALOR" , .T., .T., "VALCAL", STR0035,  , .F.}) //STR0035 'Valor'
	Aadd(aCpoComp, {"DT1", "DT1_VALOR" , .T., .T., "VALDIG", STR0036,  , .T.}) //STR0036 'Digitado'
	Aadd(aCpoComp, {"DT8", "DT8_VALIMP", .T., .T.,         , STR0039,  , .F.}) //STR0039 'Imposto'
	Aadd(aCpoComp, {"DT8", "DT8_VALTOT", .T., .T.,         , STR0040,  , .F.}) //STR0040 'Digitado + Imposto'

	//-- Define estrutura do browse de componentes
	aRetStrBrw := GetStrBrw(aCpoComp)
	aStrComp   := aRetStrBrw[1]
	aCpoComp   := aRetStrBrw[4]

	//-- Tabela temporaria Valores dos Componentes de Frete
	oTempComp := FWTemporaryTable():New(cAliComp)
	oTempComp:SetFields(aStrComp)
	oTempComp:Create()

	//-- Cria os registros na tabela temporaria com os Valores dos Componentes de Frete
	For nContador := 1 To Len(aCalFret)
		(cAliComp)->(RecLock(cAliComp, .T.))
		(cAliComp)->DT3_CODPAS := aCalFret[nContador, 3]
		(cAliComp)->DT3_DESCRI := aCalFret[nContador, 1]
		(cAliComp)->DVE_COMOBR := aCalFret[nContador, 23]
		(cAliComp)->VALCAL     := aCalFret[nContador, 2]
		(cAliComp)->VALDIG     := aCalFret[nContador, 2]
		(cAliComp)->DT8_VALIMP := aCalFret[nContador, 5]
		(cAliComp)->DT8_VALTOT := aCalFret[nContador, 6]
		(cAliComp)->(MsUnlock())
	Next nContador
	
	//-- Criacao do browse de componentes
	oBrwComp:= FWBrowse():New()
	oBrwComp:SetDataTable(.T.)
	oBrwComp:SetPreEditCell({|oBrw, nCol| PEditBrCom(oBrw, nCol)})
	oBrwComp:SetEditCell(.T., {|| Iif (EdtBrCompF(cAliComp, aParCal, @aCalFret),;
		                               (oBrwComp:Refresh(), .T.),;
		                               .F.)})
	oBrwComp:SetChange({|| oBrwComp:GoColumn(4)}) // Ao navegar, sempre posiciona na coluna 'Digitado'
	oBrwComp:SetOwner(oPnlComp)
	oBrwComp:SetDescription(STR0030) //STR0030 'Valores dos Componentes de Frete'
	oBrwComp:SetAlias(cAliComp)
	oBrwComp:SetColumns(aCpoComp)
	oBrwComp:DisableReport()
	oBrwComp:Activate()

	//-- Cria botoes de operacao
	Aadd(aButtons, {"", STR0029, {|| Iif (lRet := PrepGerDoc(aDocs, aPerg853, aParCal, aCalFret),; //STR0029 'Gerar Documento'
		                                  (oDlgCom:DeActivate(), .T.),;
		                                  .F.)}, , , .T., .F.})
	Aadd(aButtons, {"", STR0028, {|| oDlgCom:DeActivate()}, , , .T., .F.}) //STR0028 'Cancelar'
	oDlgCom:AddButtons(aButtons)

	//-- Ao inicializar a modal, atualiza o browse, seta o foco no browse e posiciona na coluna 'Digitado'
	oDlgCom:SetInitBlock({|| oBrwComp:Refresh(.T.),;
	                         oBrwComp:GoTop(.T.),;
							 oBrwComp:SetFocus(),;
							 oBrwComp:GoColumn(4)})
	oDlgCom:Activate()
	
	//-- Ao finalizar, elimina tabelas temporarias
	oTempComp:Delete()

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEditBrCom
Pré-validação para a edição de celula do browse de Valores dos Componentes de Frete
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 25/01/2017
@param [oBrw], Objeto, Objeto que representa o Browse
@param [nCol], Numérico, Número da coluna que será editada
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function PEditBrCom(oBrw, nCol)

	Local lRet := .T.
	Local cAli := oBrw:Alias()

	//-- Nao permite editar o Total
	If (cAli)->(!Eof()) .And. (cAli)->DT3_CODPAS == "TF"
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EdtBrCompF
Função de edição de célula do browse de Valores dos Componentes de Frete
Recalcula impostos e atualiza totais
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 11/01/2017
@param [cAliComp], Caracter, Alias da tabela dos valores dos componentes
@param [aParCal], Array, Parâmetros utilizados no cálculo da composição do frete
@param [aCalFret], Array, Composição de frete para ser utilizada na geração do documento (retorno @)
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function EdtBrCompF(cAliComp, aParCal, aCalFret)

	Local aArea     := GetArea()
	Local aAreaCom  := (cAliComp)->(GetArea())
	Local aRetCal   := {}
	Local aErrCal   := {}
	Local cMsgErr   := ""
	Local nPosCom   := 0
	Local nContador := 0
	Local nValDig   := 0
	Local nValImp   := 0
	Local nValTot   := 0
	Local lRet      := .T.

	Default cAliComp := ""
	Default aParCal  := {}
	Default aCalFret := {}

	If (cAliComp)->VALDIG < 0
		Help(" ", 1, "TMSA85313") // Nao eh permitido componente com valor menor que 0
		lRet := .F.
	Else
	
		//-- Cria composicao apenas com o componente que esta tendo seu valor
		//-- digitado alterado para efetuar o calculo de imposto
		nPosCom := Ascan(aCalFret, {| x | x[3] == (cAliComp)->DT3_CODPAS})
		If nPosCom > 0
			aCalFret[nPosCom, 2] := (cAliComp)->VALDIG
			aCalFret[nPosCom, 5] := 0
			aCalFret[nPosCom, 6] := (cAliComp)->VALDIG
		EndIf

		//-- Chama a funcao para calcular o valor de imposto do componente
		Processa({|| aRetCal := A050CalFrt("3"                , aParCal[ACALCLIREM], aParCal[ACALLOJREM], aParCal[ACALCDRORI], aParCal[ACALCLICAL], aParCal[ACALLOJCAL], aParCal[ACALCDRCAL], aParCal[ACALCLIDES], aParCal[ACALLOJDES],;
		                                   aParCal[ACALCDRDES], aParCal[ACALSQEDES], aParCal[ACALCLIDEV], aParCal[ACALLOJDEV], aParCal[ACALCODPRO], aParCal[ACALSERVIC], aParCal[ACALCODNEG], aParCal[ACALSERTMS], aParCal[ACALTIPTRA],;
		                                   aParCal[ACALDOCTMS], aParCal[ACALLOTNFC], aParCal[ACALTIPFRE], aParCal[ACALTIPNFC], aParCal[ACALSEQINS], aParCal[ACALVALMER], aParCal[ACALPESO]  , aParCal[ACALPESOM3], aParCal[ACALQTDVOL],;
		                                   aParCal[ACALMETRO3], aParCal[ACALKM],     aParCal[ACALQTDUNI], aParCal[ACALBASSEG], aParCal[ACALPRCPDG], aParCal[ACALCLIGEN], aParCal[ACALAJUAUT], aParCal[ACALVALINF], aParCal[ACALTIPVEI],;
		                                   aCalFret            , aParCal[ACALCTRCLI], .T. )},;
		          STR0006,;     //STR0006 'Aguarde...'
		          STR0033, .F.) //STR0037 'Calculando impostos...'
		          
		aCalFret := aClone(aRetCal[1])
		aErrCal  := aClone(aRetCal[2, 2])

		//-- Ocorreram os seguintes erros durante o calculo
		If ! Empty(aErrCal) .And. Len(aErrCal) > 0
			For nContador := 1 To Len(aErrCal)
				If ! Empty(cMsgErr)
					cMsgErr += chr(10)
				EndIf
				cMsgErr += aErrCal[nContador, 1]
			Next nContador
			Help(" ", 1, "TMSA85308", , cMsgErr, 2, 1)
			lRet := .F.
		Else
		
			//-- Apresenta valores sugeridos pelo calculo
			If ! Empty(aCalFret) .And. Len(aCalFret) > 0
			
				nPosCom := Ascan(aCalFret, {| x | x[3] == (cAliComp)->DT3_CODPAS})

				(cAliComp)->(RecLock(cAliComp, .F.))
				(cAliComp)->DT8_VALIMP := aCalFret[nPosCom, 5]
				(cAliComp)->DT8_VALTOT := aCalFret[nPosCom, 6]
				(cAliComp)->(MsUnlock())
				
				nValDig := 0
				nValImp := 0
				nValTot := 0
				
				//-- Recalcula totais
				(cAliComp)->(dbGoTop())
				While (cAliComp)->(!Eof())
					If (cAliComp)->DT3_CODPAS != "TF"
						nValDig += (cAliComp)->VALDIG
						nValImp += (cAliComp)->DT8_VALIMP
						nValTot += (cAliComp)->DT8_VALTOT
					Else
						(cAliComp)->(RecLock(cAliComp, .F.))
						(cAliComp)->VALDIG     := nValDig
						(cAliComp)->DT8_VALIMP := nValImp
						(cAliComp)->DT8_VALTOT := nValTot
						(cAliComp)->(MsUnlock())
					EndIf
					(cAliComp)->(dbSkip())
				EndDo

				RestArea(aAreaCom)

			Else
				Help(" ", 1, "TMSA85309") //-- Nenhum componente/valor identificado
				lRet := .F.
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PrepGerDoc
Preparação para geração do documento fiscal referente ao Cobrança do Serviço Adicional
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 11/01/2017
@param [aDocs], Array, Documentos selecionados
@param [aPerg853], Array, Informacoes do Pergunte TMSA853
@param [aParCal], Array, Parâmetros utilizados no cálculo da composição do frete
@param [aCmpFrt], Array, Composição de frete
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function PrepGerDoc(aDocs, aPerg853, aParCal, aCmpFrt)

	Local aArea      := GetArea()
	Local aPerfil    := {}
	Local aCmpFrtAux := {}
	Local lRet       := .T.
	Local lFatSE1    := .F.
	Local cTmsERP    := SuperGetMV("MV_TMSERP",,'0')
	Local cTMSMFat   := SuperGetMv("MV_TMSMFAT",.F.,'1')
	Local lIFisSer   := SuperGetMv("MV_IFISSER", , .F.) //-- Informações fiscais do serviço?
	Local nTotDig    := 0
	Local nContador  := 0
	Local cCodTES    := ""
	Local cCodMsg    := ""
	Local cDocFat    := ""
	Local cCodPro    := ""
	Local cF4ISS    := ""
	Local cSerie     := ""
	Local bFatSE1

	Default aDocs    := {}
	Default aPerg853 := {}
	Default aParCal  := {}
	Default aCmpFrt  := {}

	//-- Identifica a regra de tributacao do cliente devedor para o DOCTMS 5
	aRegTrib := TmsRegTrib(StrZero(5, Len(DC5->DC5_DOCTMS)),; //-- Nota fiscal
							StrZero(3, Len(DT6->DT6_TIPFRE)),; //-- CIF/FOB
							,;
							aPerg853[APERCLIDEV],;
							aPerg853[APERLOJDEV],;
							,;
							.F.,;
							,;
							,;
							,;
							.F.,;
							'0',) //-- 0 - Normal

	If ! Empty(aRegTrib)
		cCodTES := aRegTrib[1]
		cCodMsg := aRegTrib[2]
		cF4ISS  := aRegTrib[3]
	EndIf

	//-- Identifica o produto fiscal da configuracao do documento 5
	cCodPro := ""
	DUI->(DbSetOrder(1))
	If DUI->(MsSeek(xFilial('DUI') + StrZero(5, Len(DC5->DC5_DOCTMS))))

		cSerie  := DUI->DUI_SERIE
		cCodPro := Iif(!Empty(DUI->DUI_PRDCIF), DUI->DUI_PRDCIF, DUI->DUI_CODPRO)
	EndIf

	//-- Caso o parâmetro MV_IFISSER (Informações fiscais do serviço?) esteja ativo e exista
	//-- informações indicadas para TES e/ou Produto Fiscal, assume o que foi informado
	If lIFisSer
		If ! Empty(aPerg853[APERCODTES])
			cCodTES := aPerg853[APERCODTES]
		EndIf
		If ! Empty(aPerg853[APERPRDFIS])
			cCodPro := aPerg853[APERPRDFIS]
		EndIf
	EndIf
	
	//-- Integracao com SIGAFIN - Identifica se deve gerar o titulo no Contas a Receber
	bFatSE1 := {|| .F. }
	If cTmsERP == '0' //-- ERP Protheus
	
		If cTMSMFat == '2' //-- Faturamento pela DT6

			//-- Obtem o perfil do cliente para verificar quais documentos possuem 
			//-- tratamento diferenciado no faturamento:
			aPerfil := TmsPerfil(aPerg853[APERCLIDEV], aPerg853[APERLOJDEV], , , ;
			                     aPerg853[APERCLIDEV], aPerg853[APERLOJDEV], ;
			                     aPerg853[APERCLIDEV], aPerg853[APERLOJDEV])
			cDocFat := aPerfil[47]

			If AllTrim(cDocFat) == '*' .Or. ('5' $ cDocFat)
				bFatSE1 := {|| .T. }
			EndIf
		Else
			bFatSE1 := {|| .T. }
		EndIf
	EndIf

	// VALIDACOES - INI
	
	//-- Valor total dos componentes deve ser maior que 0
	For nContador := 1 To Len(aCmpFrt)
		If aCmpFrt[nContador, 3] != "TF" .And. aCmpFrt[nContador, 2] >= 0
			nTotDig += aCmpFrt[nContador, 2]
		EndIf
	Next nContador

	If nTotDig <= 0
		lRet := .F.
		Help(" ", 1, "TMSA85314") //-- Valor total do servico deve ser maior que 0
	EndIf
	
	//-- TES deve ser informada
	If Empty(cCodTES)
		lRet := .F.
		If lIFisSer
			Help(" ", 1, "TMSA85315", , " (" + cCodMsg + ")", 2, 1) //-- TES nao informada no Pergunte e nao encontrada na regra de tributacao
		Else
			Help(" ", 1, "TMSA85322", , " (" + cCodMsg + ")", 2, 1) //-- TES não encontrada na regra de tributação do Docto.Transp. 5.
		EndIf
	EndIf
	
	//-- Produto fiscal deve ser informado
	If Empty(cCodPro)
		lRet := .F.
		If lIFisSer
			Help(" ", 1, "TMSA85316") //-- Produto fiscal nao informado no Pergunte e nao encontrado na configuracao do documento 5
		Else
			Help(" ", 1, "TMSA85323") //-- Produto fiscal não encontrado na configuração do Docto.Transp. 5.
		EndIf
	EndIf

	//-- Condicao de pagamento do cliente deve ser informado
	lFatSE1 := Eval(bFatSE1)
	If lFatSE1
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		If SA1->(MsSeek(xFilial('SA1') + aPerg853[APERCLIDEV] + aPerg853[APERLOJDEV]))
			If Empty(SA1->A1_COND)
				lRet := .F.
				Help(" ", 1, "TMSA85318") //-- Condicao de pagamento do cliente pagador de frete deve ser informada no cadastro do cliente!
			EndIf
		EndIf
	EndIf

	If lRet == .F.
		Return lRet
	EndIf
	
	// VALIDACOES - FIM

	//-- Ajusta composição de frete para o formato na qual as funções padroes
	//-- estao preparadas e levando apenas os componentes com valor maior que 0
	aCmpFrtAux := aClone(aCmpFrt)
	aCmpFrt    := {}
	Aadd(aCmpFrt, {cCodPro, {}})
	For nContador := 1 To Len(aCmpFrtAux)
		If aCmpFrtAux[nContador, 2] > 0
			AAdd(aCmpFrt[1][2], aClone(aCmpFrtAux[nContador]))
		EndIf
	Next nContador

	// GERACAO DO DOCUMENTO
	Processa({|| lRet := GerDocServ(aDocs, aParCal, aCmpFrt, cCodTES, cCodMsg, cF4ISS, cCodPro, cSerie, bFatSE1)},;
		      STR0041,;     //STR0041 'Gerando documento...'
		      STR0006, .F.) //STR0006 'Aguarde...'

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GerDocServ
Geração do documento fiscal referente ao Cobrança do Serviço Adicional
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 11/01/2017
@param [aDocs], Array, Documentos selecionados
@param [aParCal], Array, Parâmetros utilizados no cálculo da composição do frete
@param [aCmpFrt], Array, Composição de frete
@param [cCodTES], Caracter, Código TES
@param [cCodMsg], Caracter, Mensagem fiscal
@param [cF4ISS], Caracter, Incide ISS
@param [cCodPro], Caracter, Produto de cálculo
@param [cSerie], Caracter, Série
@param [bFatSE1], Bloco, Indica se deve ser gerado título (SE1)
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function GerDocServ(aDocs, aParCal, aCmpFrt, cCodTES, cCodMsg, cF4ISS, cCodPro, cSerie, bFatSE1)

Local aArea      := GetArea()
Local aParGerNfs := {}
Local aRetVerImp := {}
Local aParGrvDT6 := {}
Local aRetDT6    := {}
Local lRet       := .T.
Local nValFre    := 0
Local nValImp    := 0
Local nValTot    := 0
Local nPesoCobr  := 0
Local nRecDT6    := 0
Local nContador  := 0
Local cFilDoc    := ""
Local cDoc       := ""
Local cLotNfc    := ""
Local cTabFre    := ""
Local cTipTab    := ""
Local cSeqTab    := ""
Local cNrContr   := ""
Local cCodNeg    := ""
Local cChvDoc    := ""
Local cTaxCtr    := ""
Local lMultSerie := FindFunction("TmsSerie")

Default aParCal := {}
Default aCmpFrt := {}
Default cCodTES := ""
Default cCodMsg := ""
Default cF4ISS  := ""
Default cCodPro := ""
Default cSerie  := ""
Default bFatSE1 := {|| .F.}

				//-- Identifica o código da negociacao
If ! Empty(aParCal[ACALCTRCLI])          .And. ValType(aParCal[ACALCTRCLI])           == "A" .And.;
	Len(aParCal[ACALCTRCLI])           >= 1  .And. ValType(aParCal[ACALCTRCLI, 1])        == "A" .And.;
	Len(aParCal[ACALCTRCLI, 1])        >= 44 .And. ValType(aParCal[ACALCTRCLI, 1, 44])    == "A" .And.;
	Len(aParCal[ACALCTRCLI, 1, 44])    >= 1  .And. ValType(aParCal[ACALCTRCLI, 1, 44, 1]) == "A" .And.;
	Len(aParCal[ACALCTRCLI, 1, 44, 1]) >= 2
		cCodNeg := aParCal[ACALCTRCLI, 1, 44, 1, 2]
EndIf

If !Empty(aParCal[ACALCTRCLI]) .And. lMultSerie
	cSerie := TmsSerie(cSerie, aParCal[ACALCTRCLI, 1, 1], cCodNeg, aParCal[ACALSERVIC])
EndIf

// GERACAO DO DOCUMENTO - INI
lRet := .F.
Begin Transaction

	ProcRegua(6) //-- 6 passos para geracao do documento

	IncProc(STR0042) //-- PASSO 1 -> STR0042 'Gerando Nota Fiscal de Saida...'
	aParGerNfs := {aParCal[ACALCDRORI], aParCal[ACALCDRCAL], aParCal[ACALCLIDEV], aParCal[ACALLOJDEV], aParCal[ACALDOCTMS],;
					cCodPro           , aParCal[ACALSERVIC], aParCal[ACALQTDVOL], aParCal[ACALPESO]  ,                    ,;
										, aCmpFrt            , cF4ISS             , cCodTES            , bFatSE1            ,;
					cSerie            ,                    , }
	cNumNFS    := TmsGerNfs(aParGerNfs, {""})

	IncProc(STR0043) //-- PASSO 2 -> STR0043 'Verificando valores de impostos...'
	aRetVerImp := TmsVerImpC(cNumNFS, aParCal[ACALCLIDEV], aParCal[ACALLOJDEV], aParCal[ACALDOCTMS], cCodPro, aCmpFrt)
	aCmpFrt    := aClone(aRetVerImp[2])
	nValFre    := aRetVerImp[3]
	nValImp    := aRetVerImp[4]
	nValTot    := aRetVerImp[5]
	nPesoCobr  := 0
	
	IncProc(STR0044) //-- PASSO 3 -> STR0044 'Gravando lote de notas fiscais (DTP)...'
	cLotNfc := TmsGrvLot()

	IncProc(STR0045) //-- PASSO 4 -> STR0045 'Gravando documento de transporte (DT6)...'
	//-- Informacoes do contrato (quando houver)
	If ! Empty(aParCal[ACALCTRCLI])

		cTabFre  := aParCal[ACALCTRCLI, 1, 3]
		cTipTab  := aParCal[ACALCTRCLI, 1, 4]
		cSeqTab  := Iif(Empty(aParCal[ACALSEQTAB]), "", aParCal[ACALSEQTAB])
		cNrContr := aParCal[ACALCTRCLI, 1, 1]

		//-- Identifica se no contrato está parametrizado para taxa
		If ValType(aParCal[ACALCTRCLI]) == "A" .And.;
		Len(aParCal[ACALCTRCLI])        >= 1   .And. ValType(aParCal[ACALCTRCLI, 1]) == "A" .And.;
		Len(aParCal[ACALCTRCLI, 1])     >= 23
			cTaxCtr := aParCal[ACALCTRCLI, 1, 23]
		EndIf
	EndIf
	aParGrvDT6 := {/* cFilOri */      , /* cFilDes */      , /* cFilNeg */                   , /* cFilDeb */      , /* cFilDoc */      , cNumNFS            , cSerie             , aParCal[ACALCLIREM], aParCal[ACALLOJREM], aParCal[ACALCLIDES],;
					aParCal[ACALLOJDES], aParCal[ACALCLIDEV], aParCal[ACALLOJDEV]             , aParCal[ACALCLICAL], aParCal[ACALLOJCAL], aParCal[ACALCDRORI], aParCal[ACALCDRDES], aParCal[ACALCDRCAL],                    ,                    ,;
										,                    , /* dPrzEnt */                   , /* dDatEmi */      , /* cHorEmi */      , /* cUsrGer */      , aParCal[ACALDOCTMS], /* cStatus */      , /* cBlqDoc */      , /* cPriPer */      ,;
					/* cFImp */        , aParCal[ACALTIPFRE], StrZero(1, Len(DT6->DT6_DEVFRE)), /* cSerTms */      , cLotNfc            , /* nMoeda */       , aParCal[ACALTIPTRA], aParCal[ACALSERVIC], cCodMsg            , /* cSitCte */      ,;
					/* cRetCte */      , aParCal[ACALVALMER], aParCal[ACALPESOM3]             , nPesoCobr          , aParCal[ACALQTDUNI], aParCal[ACALQTDVOL], aParCal[ACALQTDVOL], aParCal[ACALPESO]  , nValFre            , nValImp            ,;
					nValTot            , nValTot            , /* nAcresc */                   , /* nDecres */      , cTabFre            , cTipTab            , cSeqTab            , cNrContr,          cCodNeg}
	aRetDT6    := TmsGrvDT6(aParGrvDT6, {"", ""}, Eval(bFatSE1))
	cFilDoc    := aRetDT6[1]
	cDoc       := aRetDT6[2]
	cSerie     := aRetDT6[3]
	nRecDT6    := aRetDT6[4]

	IncProc(STR0046) //-- PASSO 5 -> STR0046 'Gravando composicao de frete (DT8)...'
	TmsGrvDT8("TMSA853", cFilDoc, cDoc, cSerie, cTaxCtr, .T., aCmpFrt)

	IncProc(STR0047) //-- PASSO 6 -> STR0047 'Criando vinculo da(s) nota(s) (DTC) com o documento (DT6)...'
	For nContador := 1 To Len(aDocs)
		RecLock("DY4", .T.)
		DY4->DY4_FILIAL := xFilial("DY4")
		DY4->DY4_FILORI := aDocs[nContador, ADOCFILORI]
		DY4->DY4_LOTNFC := aDocs[nContador, ADOCLOTNFC]
		DY4->DY4_NUMNFC := aDocs[nContador, ADOCNUMNFC]
		DY4->DY4_SERNFC := aDocs[nContador, ADOCSERNFC]
		DY4->DY4_CODPRO := aDocs[nContador, ADOCCODPRO]
		DY4->DY4_QTDVOL := aDocs[nContador, ADOCQTDVOL]
		DY4->DY4_CLIREM := aDocs[nContador, ADOCCLIREM]
		DY4->DY4_LOJREM := aDocs[nContador, ADOCLOJREM]
		DY4->DY4_FILOCO := aDocs[nContador, ADOCFILOCO]
		DY4->DY4_NUMOCO := aDocs[nContador, ADOCNUMOCO]
		DY4->DY4_FILVIA := aDocs[nContador, ADOCFILVIA]
		DY4->DY4_VIAGEM := aDocs[nContador, ADOCVIAGEM]
		DY4->DY4_SEQOCO := aDocs[nContador, ADOCSEQOCO]
		DY4->DY4_FILDOC := cFilDoc
		DY4->DY4_SERIE  := cSerie
		DY4->DY4_DOC    := cDoc
		DY4->(MsUnLock())
	Next nContador
End Transaction
lRet := .T.
// GERACAO DO DOCUMENTO - FIM

//-- Na funcao NxtSX5Nota (MATXFUNA), chamado pela MaNfs2Nfs (MATA461), 
//-- chamado pela funcao TmsGerNfs (TMSXFUNE) eh realizado o lock de registros
//-- nas tabelas SX5 e SX6, porem dentro de uma transacao nao eh possivel
//-- executar a funcao MsRUnLock para retirar o lock e por isso eh necessario
//-- retirar o lock neste momento apos a transacao. Caso nao exista este
//-- tratamento, se outra rotina estiver executando simultaneamente e chamar a
//-- funcao MaNfs2Nfs (Ex.: TMSA050, operacao de Calculo de frete), ocorrerá erro.
If ! InTransact()
	SX5->(MsRUnLock())
	SX6->(MsRUnLock())
EndIf

//-- Montagem da mensagem de geracao do documento com sucesso
dbSelectArea("SX3")
SX3->(dbSetOrder(2)) //X3_CAMPO
cChvDoc := ""
If SX3->(MsSeek("DT6_FILDOC"))
	cChvDoc += Trim(X3TITULO())
	cChvDoc += cFilDoc
EndIf
If SX3->(MsSeek("DT6_DOC"))
	cChvDoc += ", " + Trim(X3TITULO())
	cChvDoc += cDoc
EndIf
If SX3->(MsSeek("DT6_SERIE"))
	cChvDoc += ", " + Trim(X3TITULO())
	cChvDoc += cSerie
EndIf

Help(" ", 1, "TMSA85321", , " (" + cChvDoc + ")", 2, 1) //-- Documento de faturamento de serviço adicional gerado com sucesso!

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AllMarkBrw
Inverte marcação
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 28/11/2016
@param [oMarkBrw], Objeto, FWMarkBrowse
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function AllMarkBrw(oMarkBrw)

	Local lRet      := .T.
	Local cAliasBrw := oMarkBrw:Alias()

	If (cAliasBrw)->(!Eof())
		(cAliasBrw)->(dbGoTop())
		While (cAliasBrw)->(!Eof())
			If oMarkBrw:IsMark() 
				oMarkBrw:MarkRec()
			ElseIf VldMrkBrw(cAliasBrw, .F.)
				oMarkBrw:MarkRec()
			EndIf
			(cAliasBrw)->(DbSkip())
		EndDo
		
		oMarkBrw:Refresh(.T.)
		oMarkBrw:GoTop(.T.)
		
	Else
		Help(" ", 1, "TMSA85307") // Nao existem registros para selecao.
	EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA853Doc
Mostra os documentos de faturamento de serviço adicional relacionados ao documento de frete (DT6)
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 03/03/2017
@param [cFilDoc], Caracter, Filial do documento
@param [cDoc], Caracter, Número do documento
@param [cSerie], Caracter, Série do documento
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA853Doc(cFilDoc, cDoc, cSerie)

	Local aArea      := GetArea()
	Local aAreaDTC   := {}
	Local aAreaDY4   := {}
	Local aAreaDT6   := {}
	Local aAreaDC5   := {}
	Local aAreaDY4An := {}
	Local aButtons   := {}
	Local aCpoDoc    := {}
	Local aRetStrBrw := {} //-- Array retorno da funcao GetStrBrw()
	Local aStrDoc    := {}
	Local aDocsDT6   := {}
	Local aDocsSrv   := {}
	Local cAliDoc    := GetNextAlias()
	Local cSeekDTC   := ""
	Local cSeekDY4   := ""
	Local cSeekDY4Nt := ""
	Local cServic    := ""
	Local cBrFilDoc  := ""
	Local cBrDoc     := ""
	Local cBrSerie   := ""
	Local cCodOco    := ""
	Local cDescri    := ""
	Local lRet       := .T.
	Local nContador  := 0
	Local nBrValFre  := 0
	Local nBrValImp  := 0
	Local nBrValTot  := 0
	Local nTotRat    := 0
	Local nTotRel    := 0
	Local nValRat    := 0
	Local oDlgDoc, oPnlModal, oFWLayer, oPnlDoc, oTempDoc, oBrwDoc
	
	Default cFilDoc := ""
	Default cDoc    := ""
	Default cSerie  := ""

	//-- Campos que serao apresentados no browse
	Aadd(aCpoDoc, {"DT6", "DT6_FILDOC", .T., .T.,         ,        , , .F.}) 
	Aadd(aCpoDoc, {"DT6", "DT6_DOC"   , .T., .T.,         ,        , , .F.}) 
	Aadd(aCpoDoc, {"DT6", "DT6_SERIE" , .T., .T.,         ,        , , .F.}) 
	Aadd(aCpoDoc, {"DT6", "DT6_VALTOT", .T., .T.,         ,        , , .F.})
	Aadd(aCpoDoc, {"DT6", "DT6_VALTOT", .T., .T., "PERRAT", STR0057, , .F.}) //STR0057 '% Val.Proporcional'
	Aadd(aCpoDoc, {"DT6", "DT6_VALTOT", .T., .T., "VALRAT", STR0058, , .F.}) //STR0058 'Valor Proporcional'
	Aadd(aCpoDoc, {"DC5", "DC5_TIPRAT", .T., .T.,         , STR0059, , .F.}) //STR0059 'Crit.Rat.Propor'
	Aadd(aCpoDoc, {"DUA", "DUA_CODOCO", .T., .T.,         ,        , , .F.})
	Aadd(aCpoDoc, {"DT2", "DT2_DESCRI", .T., .T.,         ,        , , .F.})
	Aadd(aCpoDoc, {"DUA", "DUA_FILOCO", .T., .T.,         ,        , , .F.})
	Aadd(aCpoDoc, {"DUA", "DUA_NUMOCO", .T., .T.,         ,        , , .F.})
	Aadd(aCpoDoc, {"DUA", "DUA_FILORI", .T., .T.,         ,        , , .F.})
	Aadd(aCpoDoc, {"DUA", "DUA_VIAGEM", .T., .T.,         ,        , , .F.})
	Aadd(aCpoDoc, {"DUA", "DUA_SEQOCO", .T., .T.,         ,        , , .F.})

	//-- Define estrutura do browse
	aRetStrBrw := GetStrBrw(aCpoDoc)
	aStrDoc   := aRetStrBrw[1]
	aCpoDoc   := aRetStrBrw[4]

	//-- Tabela temporaria
	oTempDoc := FWTemporaryTable():New(cAliDoc)
	oTempDoc:SetFields(aStrDoc)
	oTempDoc:Create()

	//-- 1: Obtem as notas do documento de frete que esta sendo visualizado
	aAreaDTC := DTC->(GetArea())
	dbSelectArea("DTC")
	DTC->(dbSetOrder(3)) //DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
	cSeekDTC := xFilial('DTC') + cFilDoc + cDoc + cSerie
	If DTC->(MsSeek(cSeekDTC))
		While(DTC->(!Eof()) .And. DTC->(DTC_FILIAL + DTC_FILDOC + DTC_DOC + DTC_SERIE) == cSeekDTC)
			//-- Necessario apenas as informacoes chaves que relacionam a tabela DY4 (referente a nota)
			Aadd(aDocsDT6, DTC->(DTC_NUMNFC + DTC_SERNFC + DTC_CLIREM + DTC_LOJREM + DTC_CODPRO + DTC_FILORI + DTC_LOTNFC))
			DTC->(dbSkip())
		EndDo
	EndIf
	RestArea(aAreaDTC)

	//-- 2: Atraves das notas do documento de frete, obtem os documentos de faturamento de servico adicional
	//-- relacionados, identifica para cada documento de servico adicional qual a forma de "rateio" para
	//-- proporcionalidade do valor do documento, quais notas estao relacionadas, efetua o calculo proporcional
	//-- e inclui o registro para o browse
	aAreaDY4 := DY4->(GetArea())
	dbSelectArea("DY4")
	DY4->(dbSetOrder(3)) //DY4_FILIAL+DY4_NUMNFC+DY4_SERNFC+DY4_CLIREM+DY4_LOJREM+DY4_CODPRO+DY4_FILORI+DY4_LOTNFC
	For nContador := 1 To Len(aDocsDT6)
		cSeekDY4 := xFilial('DY4') + aDocsDT6[nContador]
		If DY4->(MsSeek(cSeekDY4))
			While(DY4->(!Eof()) .And. DY4->(DY4_FILIAL + DY4_NUMNFC + DY4_SERNFC + DY4_CLIREM + DY4_LOJREM + DY4_CODPRO + DY4_FILORI + DY4_LOTNFC) == cSeekDY4)
				If Ascan(aDocsSrv, { |x| x[1] + x[2] + x[3] == DY4->(DY4_FILDOC + DY4_DOC + DY4_SERIE)}) <= 0
					Aadd(aDocsSrv, {DY4->DY4_FILDOC,; //-- Filial documento de servico adicional
									DY4->DY4_DOC,;    //-- Documento de servico adicional
									DY4->DY4_SERIE,;  //-- Serie documento de servico adicional
									"0",;             //-- Tipo de "rateio"
									{},;              //-- Notas relacionadas ao documento de servico adicional
									0,;               //-- Total valor a ser rateado
									0,;               //-- Total valor a ser considerado nas notas
									0,;               //-- % Proporcional
									0})               //-- Valor proporcional
					nPosArr := Len(aDocsSrv) //-- Posicao corrente do array

					//-- Identifica informacoes do documento
					aAreaDT6 := DT6->(GetArea())
					dbSelectArea("DT6")
					DT6->(dbSetOrder(1))
					cServic := ""
					If DT6->(MsSeek(xFilial('DT6') + aDocsSrv[nPosArr, 1] +  aDocsSrv[nPosArr, 2] +  aDocsSrv[nPosArr, 3]))
						cServic   := DT6->DT6_SERVIC
						cBrFilDoc := DT6->DT6_FILDOC
						cBrDoc    := DT6->DT6_DOC
						cBrSerie  := DT6->DT6_SERIE
						nBrValFre := DT6->DT6_VALFRE
						nBrValImp := DT6->DT6_VALIMP
						nBrValTot := DT6->DT6_VALTOT
					EndIf
					RestArea(aAreaDT6)

					//-- Identifica o tipo de "rateio" do servico
					aAreaDC5 := DC5->(GetArea())
					dbSelectArea("DC5")
					DC5->(dbSetOrder(1)) //DC5_FILIAL+DC5_SERVIC+DC5_ORDEM
					If DC5->(MsSeek(xFilial("DC5") + cServic))
						aDocsSrv[nPosArr, 4] := DC5->DC5_TIPRAT
					EndIf
					RestArea(aAreaDC5)

					//-- Necessario armazenar a area, pois ha duas consultas na mesma tabela
					aAreaDY4An := DY4->(GetArea())

					//-- Identifica as notas de cada documento de frete de servico adicional
					DY4->(dbSetOrder(1)) //DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE+DY4_NUMNFC+DY4_SERNFC+DY4_CODPRO
					cSeekDY4Nt := xFilial('DY4') + aDocsSrv[nPosArr, 1] + aDocsSrv[nPosArr, 2] + aDocsSrv[nPosArr, 3]
					If DY4->(MsSeek(cSeekDY4Nt))
						nTotRat := 0 //-- Valor total a ser considerado de todas as notas
						nTotRel := 0 //-- Valor total a ser considerado apenas das notas relacionadas ao documento visualizado
						While(DY4->(!Eof()) .And. DY4->(DY4_FILIAL + DY4_FILDOC + DY4_DOC + DY4_SERIE) == cSeekDY4Nt)

							nValRat := 0

							If aDocsSrv[nPosArr, 4] == '4' //-- "Rateio" por "4 - Qtde Doctos"
								nValRat := 1
							Else

								aAreaDTC := DTC->(GetArea())
								dbSelectArea("DTC")
								DTC->(dbSetOrder(2)) //DTC_FILIAL+DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM+DTC_CODPRO+DTC_FILORI+DTC_LOTNFC
								If DTC->(MsSeek(xFilial('DTC') + DY4->(DY4_NUMNFC + DY4_SERNFC + DY4_CLIREM + DY4_LOJREM + DY4_CODPRO + DY4_FILORI + DY4_LOTNFC)))
									Do Case
									Case aDocsSrv[nPosArr, 4] == '1' //-- "Rateio" por "1 - Peso mercadoria"
										nValRat := DTC->DTC_PESO
									Case aDocsSrv[nPosArr, 4] == '2' //-- "Rateio" por "2 - Valor mercadoria"
										nValRat := DTC->DTC_VALOR
									Case aDocsSrv[nPosArr, 4] == '3' //-- "Rateio" por "3 - Qtde volumes"
										nValRat := DTC->DTC_QTDVOL
									EndCase
								EndIf
								RestArea(aAreaDTC)
							EndIf

							nTotRat += nValRat
							If Ascan(aDocsDT6, { |x| xFilial('DY4') + x == DY4->(DY4_FILIAL + DY4_NUMNFC + DY4_SERNFC + DY4_CLIREM + DY4_LOJREM + DY4_CODPRO + DY4_FILORI + DY4_LOTNFC)}) > 0
								nTotRel += nValRat
							EndIf

							Aadd(aDocsSrv[nPosArr, 5], {DY4->(DY4_FILIAL + DY4_NUMNFC + DY4_SERNFC + DY4_CLIREM + DY4_LOJREM + DY4_CODPRO + DY4_FILORI + DY4_LOTNFC),;
														nValRat})

							DY4->(dbSkip())
						EndDo

						aDocsSrv[nPosArr, 6] := nTotRat
						aDocsSrv[nPosArr, 7] := nTotRel

						//-- Calculo da proporcionalidade
						aDocsSrv[nPosArr, 8] := (nTotRel * 100) / nTotRat
						aDocsSrv[nPosArr, 9] := (nBrValTot * aDocsSrv[nPosArr, 8]) / 100

					EndIf
					RestArea(aAreaDY4An)

					//-- Identifica o código e descrição da ocorrência
					dbSelectArea("DUA")
					DUA->(dbSetOrder(1)) //DUA_FILIAL+DUA_FILOCO+DUA_NUMOCO+DUA_FILORI+DUA_VIAGEM+DUA_SEQOCO
					If DUA->(MsSeek(xFilial('DUA') + DY4->(DY4_FILOCO + DY4_NUMOCO + DY4_FILVIA + DY4_VIAGEM + DY4_SEQOCO)))
						cCodOco := DUA->DUA_CODOCO
						dbSelectArea("DT2")
						DT2->(dbSetOrder(1)) //DT2_FILIAL+DT2_CODOCO
						If DT2->(MsSeek(xFilial('DT2') + DUA->DUA_CODOCO))
							cDescri := DT2->DT2_DESCRI
						EndIf
					EndIf

					//-- Cria registro para ser apresentado no browse
					(cAliDoc)->(RecLock(cAliDoc, .T.))
					(cAliDoc)->DT6_FILDOC := cBrFilDoc
					(cAliDoc)->DT6_DOC    := cBrDoc
					(cAliDoc)->DT6_SERIE  := cBrSerie
					(cAliDoc)->DT6_VALTOT := nBrValTot
					(cAliDoc)->PERRAT     := aDocsSrv[nPosArr, 8]
					(cAliDoc)->VALRAT     := aDocsSrv[nPosArr, 9]
					(cAliDoc)->DC5_TIPRAT := aDocsSrv[nPosArr, 4]
					(cAliDoc)->DUA_CODOCO := cCodOco
					(cAliDoc)->DT2_DESCRI := cDescri
					(cAliDoc)->DUA_FILOCO := DY4->DY4_FILOCO
					(cAliDoc)->DUA_NUMOCO := DY4->DY4_NUMOCO
					(cAliDoc)->DUA_FILORI := DY4->DY4_FILVIA
					(cAliDoc)->DUA_VIAGEM := DY4->DY4_VIAGEM
					(cAliDoc)->DUA_SEQOCO := DY4->DY4_SEQOCO
					(cAliDoc)->(MsUnlock())

				EndIf
				DY4->(dbSkip())
			EndDo
		EndIf
	Next nContador
	RestArea(aAreaDY4)

	If Len(aDocsSrv) <= 0
		Help(" ", 1, "TMSA85319") //-- Nao foi identificado documentos de faturamento de servico adicional associados ao documento de frete
		lRet := .F.
	Else

		//-- Modal que serao apresentados os documentos de serviço adicional do documento de frete
		oDlgDoc := FWDialogModal():New()
		oDlgDoc:SetBackground(.F.)
		oDlgDoc:SetTitle(STR0050) //STR0050 'Documentos de Serviço Adicional'
		oDlgDoc:SetEscClose(.T.)
		oDlgDoc:EnableAllClient()
		oDlgDoc:CreateDialog()

		oPnlModal := oDlgDoc:GetPanelMain()
		
		oFWLayer := FWLayer():New() //-- Container
		oFWLayer:Init(oPnlModal, .F., .T.) //-- Inicializa container
		
		//-- Linha, coluna e window superior
		oFWLayer:AddLine('UP', 100, .F.) //-- Painel superior
		oFWLayer:AddCollumn('ALL', 100, .F., 'UP') //-- Adiciona uma "linha" com 100%
		oFWLayer:AddWindow('ALL', 'WINDOC', STR0060, 100, .F., .F., , 'UP') //STR0060 'Documentos de Serviço Adicional Relacionados'
		
		oPnlDoc := oFWLayer:GetWinPanel('ALL', 'WINDOC', 'UP')

		//-- Criacao do browse
		oBrwDoc:= FWBrowse():New()
		oBrwDoc:SetDataTable(.T.)
		oBrwDoc:SetOwner(oPnlDoc)
		oBrwDoc:SetDescription(STR0050) //STR0050 'Documentos de Serviço Adicional'
		oBrwDoc:SetAlias(cAliDoc)
		oBrwDoc:SetColumns(aCpoDoc)
		oBrwDoc:DisableReport()
		oBrwDoc:Activate()
		oBrwDoc:Refresh(.T.)
		oBrwDoc:GoTop(.T.)

		//-- Cria botoes de operacao
		Aadd(aButtons, {"", STR0065, {|| oDlgDoc:DeActivate()  }, , , .T., .F.}) //STR0065 'Fechar'
		Aadd(aButtons, {"", STR0002, {|| DocServAdd(cAliDoc, 1)}, , , .T., .F.}) //STR0002 'Visualizar'
		oDlgDoc:AddButtons(aButtons)
		oDlgDoc:Activate()
	
	EndIf

	//-- Ao finalizar, elimina tabelas temporarias
	oTempDoc:Delete()

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VisDocTran
Visualiza diretamente o documento de transporte do registro selecionado
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 21/03/2017
@param [cAliasBrw], Caracter, Alias da tabela temporária do browse
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function VisDocTran(cAliasBrw)

	Local aArea    := GetArea()
	Local lRet     := .T.
	Local aSetKey  := GetKey()
	Local aAreaBrw := (cAliasBrw)->(GetArea())

	Default cAliasBrw := ""

	Private aRotina   := StaticCall(TmsA500, MenuDef)
	Private cCadastro := STR0052 //STR0052 'Manutencao de Documentos - Visualizar'
	Private Inclui    := .F.
	Private Altera    := .F.

	TmsKeyOff(aSetKey)

	If (cAliasBrw)->(!Eof())
		DT6->(DbSetOrder(1))
		If DT6->(MsSeek(xFilial("DT6") + (cAliasBrw)->DTC_FILDOC + (cAliasBrw)->DTC_DOC + (cAliasBrw)->DTC_SERIE))
			Processa({|| TMSA500Mnt("DT6", DT6->(Recno()), 2)},;  
						STR0006,;     //STR0006 'Aguarde...'
						STR0015, .F.) //STR0015 'Abrindo visualizacao...'

			//-- Atualiza o status dos registros
			(cAliasBrw)->(dbGoTop())
			While (cAliasBrw)->(!Eof())
				GetStatDoc(cAliasBrw)
				(cAliasBrw)->(DbSkip())
			EndDo
			RestArea(aAreaBrw)
		Else
			Help(" ", 1, "TMSA85320") //-- Nao ha documento de transporte vinculado a nota para visualizacao!
		EndIf
	Else
		Help(" ", 1, "TMSA85307") // Nao existem registros para selecao.
	EndIf

	RestArea(aArea)
	TmsKeyOn(aSetKey)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IFisSerAdd
Informações fiscais de cobrança de serviço adicional
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 22/03/2017
@param [cCodTes], Caracter, Código da TES
@param [cCodPro], Caracter, Código do Produto Fiscal
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function IFisSerAdd(cCodTes, cCodPro)

	Local aArea      := GetArea()
	Local aSetKey    := GetKey()
	Local aButtons   := {}
	Local lRet       := .F.
	Local cCodTesAnt := ""
	Local cCodProAnt := ""
	Local oDlgInf, oPnlModal, oFWLayer, oPnl01, oGetCodTes, oGetCodPro,;
	      oSayCodTes, oSayCodPro, bGetCodTes, bGetCodPro

	Default cCodTes := Space(Len(SF4->F4_CODIGO))
	Default cCodPro := Space(Len(SB1->B1_COD))

	TmsKeyOff(aSetKey)

	//-- Armazena informacoes da tela
	cCodTesAnt := cCodTes
	cCodProAnt := cCodPro

	//-- Modal que serao apresentados as informacoes fiscais
	oDlgInf := FWDialogModal():New()
	oDlgInf:SetBackground(.F.)
	oDlgInf:SetTitle(STR0063) //STR0063 'Informações Fiscais'
	oDlgInf:SetEscClose(.T.)
	oDlgInf:SetSize(90, 125)
	oDlgInf:CreateDialog()

	oPnlModal := oDlgInf:GetPanelMain()
	
	oFWLayer := FWLayer():New() //-- Container
	oFWLayer:Init(oPnlModal, .F., .T.) //-- Inicializa container
	
	//-- Linhas e colunas
	oFWLayer:AddLine('LIN01', 100, .F.) //-- Linha 01
	oFWLayer:AddCollumn('COL01', 100, .F., 'LIN01')

	oPnl01 := oFWLayer:GetColPanel('COL01', 'LIN01')

	oSayCodTes := TSay():New(05, 05, {|| STR0013}, oPnl01, , , , , ,.T.)
	bGetCodTes := {|u| Iif(PCount() > 0, cCodTes := u, cCodTes)}
	oGetCodTes := TGet():New(05      /* nRow */       , 50                                   /* nCol */      , bGetCodTes   /* bSetGet */   ,;
							 oPnl01  /* oWnd */       , 030                                  /* nWidth */    , 009          /* nHeight */   ,;
							 "@!"    /* cPict */      , {|| VldCpoPerg("CODTES", {cCodTes})} /* bValid */    , 0            /* nClrFore */  ,;
							         /* nClrBack */   ,                                      /* oFont */     , .F.          /* uParam12 */  ,;
							         /* uParam13 */   , .T.                                  /* lPixel */    ,              /* uParam15 */  ,;
							 .F.     /* uParam16 */   ,                                      /* bWhen */     , .F.          /* uParam18 */  ,;
							 .F.     /* uParam19 */   ,                                      /* bChange */   , .F.          /* lReadOnly */ ,;
							 .F.     /* lPassword */  , "SF4"                                /* cF3 */       , cCodTes      /* cReadVar */  ,;
							         /* uParam25 */   ,                                      /* uParam26 */  ,              /* uParam27 */  ,;
							 .T.     /* lHasButton */ ,                                      /* lNoButton */ ,              /* uParam30 */  ,;
							         /* cLabelText */ ,                                      /* nLabelPos */ ,              /* oLabelFont */,;
							         /* nLabelColor */,                                      /* cPlaceHold */)
	
	oSayCodPro := TSay():New(20, 05, {|| STR0014}, oPnl01, , , , , ,.T.)
	bGetCodPro := {|u| Iif(PCount() > 0, cCodPro := u, cCodPro)}
	oGetCodPro := TGet():New(20      /* nRow */       , 50                                   /* nCol */      , bGetCodPro   /* bSetGet */   ,;
							 oPnl01  /* oWnd */       , 070                                  /* nWidth */    , 009          /* nHeight */   ,;
							 "@!"    /* cPict */      , {|| VldCpoPerg("PRDFIS", {cCodPro})} /* bValid */    , 0            /* nClrFore */  ,;
							         /* nClrBack */   ,                                      /* oFont */     , .F.          /* uParam12 */  ,;
							         /* uParam13 */   , .T.                                  /* lPixel */    ,              /* uParam15 */  ,;
							 .F.     /* uParam16 */   ,                                      /* bWhen */     , .F.          /* uParam18 */  ,;
							 .F.     /* uParam19 */   ,                                      /* bChange */   , .F.          /* lReadOnly */ ,;
							 .F.     /* lPassword */  , "SB1"                                /* cF3 */       , cCodPro      /* cReadVar */  ,;
							         /* uParam25 */   ,                                      /* uParam26 */  ,              /* uParam27 */  ,;
							 .T.     /* lHasButton */ ,                                      /* lNoButton */ ,              /* uParam30 */  ,;
							         /* cLabelText */ ,                                      /* nLabelPos */ ,              /* oLabelFont */,;
							         /* nLabelColor */,                                      /* cPlaceHold */)

	//-- Cria botoes de operacao
	Aadd(aButtons, {"", STR0064, {|| Iif(FisSerOK(cCodTes, cCodPro), (lRet := .T., oDlgInf:DeActivate(), .T.), .F.)}, , , .T., .F.}) //STR0064 'Confirmar'
	Aadd(aButtons, {"", STR0028, {|| lRet := .F., oDlgInf:DeActivate() }, , , .T., .F.}) //STR0028 'Cancelar'													
	oDlgInf:AddButtons(aButtons)

	oDlgInf:Activate()

	If ! lRet
		//-- Retorna informacoes
		cCodTes := cCodTesAnt
		cCodPro := cCodProAnt
	EndIf

	RestArea(aArea)
	TmsKeyOn(aSetKey)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FisSerOK
Confirmação da tela de informações fiscais
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 22/03/2017
@param [cCodTes], Caracter, Código da TES
@param [cCodPro], Caracter, Código do Produto Fiscal
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function FisSerOK(cCodTes, cCodPro)

	//-- Validacao TES
	If ! VldCpoPerg("CODTES", {cCodTes})
		Return .F.
	EndIf
	
	//-- Validacao Produto fiscal
	If ! VldCpoPerg("PRDFIS", {cCodPro})
		Return .F.
	EndIf

Return .T.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetKey
Retorna array com teclas de atalhos da rotina
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 06/04/2017
@return aSetKey Array com as teclas de atalhos
@obs aSetKey[1] Tecla de atalho
@obs aSetKey[2] Bloco de código
/*/
//-------------------------------------------------------------------------------------------------
Static Function GetKey()

	Local aSetKey := {}

	AAdd(aSetKey, {VK_F4 , SetKey(VK_F4 , Nil)})
	AAdd(aSetKey, {VK_F5 , SetKey(VK_F5 , Nil)})
	AAdd(aSetKey, {VK_F6 , SetKey(VK_F6 , Nil)})
	AAdd(aSetKey, {VK_F7 , SetKey(VK_F7 , Nil)})
	AAdd(aSetKey, {VK_F12, SetKey(VK_F12, Nil)})

Return aSetKey

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldMrkBrw
Valida marcação de registro no browse
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 11/04/2017
@param [cAliasBrw], Caracter, Alias browse
@param [lHelp], Lógico, Indica se deve ou não apresentar help
@return lMrk True ou False
/*/
//-------------------------------------------------------------------------------------------------
Static Function VldMrkBrw(cAliasBrw, lHelp)

	Local aArea := GetArea()
	Local lMrk  := .F.

	Default cAliasBrw := ""
	Default lHelp     := .T.

	If ! Empty(cAliasBrw)    .And.;
	   (cAliasBrw)->(!Eof()) .And.;
	   (cAliasBrw)->STATUS != "3"
	   lMrk := .T.
	ElseIf lHelp
		// Nao eh possivel marcar o registro, pois nao ha ocorrencia disponivel para
		// geracao de documento de servico adicional
		Help(" ", 1, "TMSA85324")
	EndIf

	RestArea(aArea)

Return lMrk
