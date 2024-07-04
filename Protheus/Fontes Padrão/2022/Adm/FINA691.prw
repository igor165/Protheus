#INCLUDE "PROTHEUS.CH"
#include "APWIZARD.CH" 
#INCLUDE "FINA691.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA691
Wizard de Configurações de parâmetros da solução de Viagens 
Protheus/Reserve

@author Pedro Alencar	

@since 01/11/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Function FINA691(lAutomato)
Default lAutomato	:= .F.
	WizCfgParam(lAutomato)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} WizCfgParam
Função que monta as etapas doWizard de Configurações  

@author Pedro Alencar
@since 01/11/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function WizCfgParam(lAutomato)
	Local oWizard
	Local aCposGRL[08]  
	Local aCposFAT[05]
	Local aCposPRESA[13]
	Local aCposPRESB[04]
	Local aCposADT[14]
	Local aCposCTT[07]
	Local aCposVIN[05]
	Local aCposCONF[05]
	Local aCposVIAG[06]
	
	Default lAutomato	:= .F.
	
	If !lAutomato
		//Carrega os vetores com os valores dos parâmetros
		LoadGRL(@aCposGRL)
		LoadFAT(@aCposFAT)
		LoadPRESTA(@aCposPRESA)
		LoadPRESTB(@aCposPRESB)
		LoadADT(@aCposADT)
		LoadCTT(@aCposCTT)
		LoadCONF(@aCposCONF)
		LoadVIAG(@aCposVIAG)
		LoadVIN(@aCposVIN)
		
		//Painel 1 - Tela inicial do Wizard
		/*STRs: "Solução de Viagens Protheus/Reserve", "Configuração de parâmetros", "Wizard de Configuração Protheus/Reserve",  
				"Esta rotina irá configurar os parâmetros da solução de viagens Protheus/Reserve. Todos os valores aqui 
				definidos serão salvos na tabela de parâmetros (SX6)" */
		oWizard := APWizard():New(OemToAnsi(STR0001),OemToAnsi(STR0002),OemToAnsi(STR0003),OemToAnsi(STR0003),{||.T.},{||.T.},.F.)

		//Painel 2 - Parâmetros Gerais
		/*STRs: "Gerais", "Configuração de parâmetros gerais da solução Protheus/Reserve" */
		oWizard:NewPanel(OemToAnsi(STR0005),OemToAnsi(STR0006),{||.T.},{||.T.},{||.T.},.T.,{||MontaGRL(oWizard,aCposGRL)})

		//Painel 3 - Parâmetros de Faturamento
		/*STRs: "Faturamento", "Configuração de parâmetros de Faturamento da solução Protheus/Reserve" */
		oWizard:NewPanel(OemToAnsi(STR0007),OemToAnsi(STR0008),{||.T.},{||.T.},{||.T.},.T.,{||MontaFAT(oWizard,aCposFAT)})

		//Painel 4 - Parâmetros de Prestação de Contas
		/*STRs: "Prestação de Contas", "Configuração de parâmetros de Prestação de Contas da solução Protheus/Reserve" */
		oWizard:NewPanel(OemToAnsi(STR0009),OemToAnsi(STR0010),{||.T.},{||.T.},{||.T.},.T.,{||MontaPRESA(oWizard,aCposPRESA)})

		//Painel 5 - Parâmetros de Prestação de Contas
		/*STRs: "Prestação de Contas", "Configuração de parâmetros de Prestação de Contas da solução Protheus/Reserve" */
		oWizard:NewPanel(OemToAnsi(STR0009),OemToAnsi(STR0010),{||.T.},{||.T.},{||.T.},.T.,{||MontaPRESB(oWizard,aCposPRESB)})

		//Painel 6 - Adiantamento
		/*STRs: "Adiantamento", "Configuração de parâmetros de Adiantamento da solução Protheus/Reserve" */
		oWizard:NewPanel(OemToAnsi(STR0011),OemToAnsi(STR0012),{||.T.},{||.T.},{||.T.},.T.,{||MontaADT(oWizard,aCposADT)})

		//Painel 7 - Cadastros Gerais
		/*STRs: "Cadastros Gerais", "Configuração de parâmetros de Cadastros Gerais da solução Protheus/Reserve" */
		oWizard:NewPanel(OemToAnsi(STR0013),OemToAnsi(STR0014),{||.T.},{||.T.},{||.T.},.T.,{||MontaCTT(oWizard,aCposCTT)})

		//Painel 8 - Viagem Avulsa   
		/*STRs: "Viagem Avulsa", "Configuração de parâmetros de Serviços Disponíveis para Viagem Avulsa" */
		oWizard:NewPanel(OemToAnsi(STR0073),OemToAnsi(STR0074),{||.T.},{||.T.},{||.T.},.T.,{||MontaVIAG(oWizard,aCposVIAG)})

		//Painel 9 - Vinculo Automático
		/*STRs: "Vínculo Automático", "Configuração de parâmetros de Cadastros Gerais da solução Protheus/Reserve" */
		oWizard:NewPanel(OemToAnsi(STR0084),OemToAnsi(STR0014),{||.T.},{||.T.},{||.T.},.T.,{||MontaVIN(oWizard,aCposVIN)})	

		//Painel 10 - Conferência de Serviços
		/*STRs: "Conferência de Serviços", "Configuração de parâmetros de Conferência de Serviços da solução Protheus/Reserve" */
		oWizard:NewPanel(OemToAnsi(STR0015),OemToAnsi(STR0016),{||.T.},{||.T.},;
							{||FN691Grava(aCposGRL,aCposFAT,aCposPRESA,aCposADT,aCposCTT,aCposCONF,aCposVIAG,aCposVIN,aCposPRESB)},.T.,;
							{||MontaCONF(oWizard,aCposCONF)})
		
		oWizard:Activate( .T.,{||.T.},{||.T.},{||.T.})
	Else
		If FindFunction("GetParAuto")
			aRetAuto := GetParAuto("FINA691TestCase")
			FN691Grava(aRetAuto[1],aRetAuto[2],aRetAuto[3],aRetAuto[4],aRetAuto[5],aRetAuto[6],aRetAuto[7],aRetAuto[8],aRetAuto[9])
		EndIf
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadGRL
Função que carrega os valores dos Parâmetros Gerais, em um vetor   

@author Pedro Alencar	
@since 01/11/2013	
@version 11.90
@param aCposGRL, Vetor passado por referência
/*/
//-------------------------------------------------------------------
Static Function LoadGRL(aCposGRL)
	aCposGRL[1] := SuperGetMV("MV_RESAVIS",,Space(250)) //Aviso por e-mail
	aCposGRL[2] := SuperGetMV("MV_RESGRAC",,Space(250)) //Grupo de Acesso Padrão
	aCposGRL[3] := cValToChar(SuperGetMV("MV_RESDIAS",,Space(250))) //Dias Retrocedência
	aCposGRL[4] := SuperGetMV("MV_RESCAD",,Space(250)) //Exportação protheus/reserve
	aCposGRL[5] := SuperGetMV("MV_RESGVIA",,Space(250)) //Usuário do Depto. de Viagens
	aCposGRL[6] := SuperGetMV("MV_RESAPRO",,Space(250)) //Aprovador Padrão	
	aCposGRL[7] := SuperGetMV("MV_RESAPRT",,Space(250)) //Permite que participante seja aprovador dele mesmo.
	aCposGRL[8] := cValToChar(SuperGetMV("MV_RESUTCO",,SPACE(250))) //Considera dias úteis ou corridos
	
Return Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} MontaGRL
Função que monta, no Wizard, os campos dos parâmetros Gerais

@author Pedro Alencar	
@since 01/11/2013	
@version 11.90
@param oWizard, Objeto Wizard
@param aCposGRL, Vetor com os parâmetros
/*/
//--------------------------------------------------------------------

Static Function MontaGRL(oWizard,aCposGRL)
	Local oPanel	:= oWizard:oMPanel[oWizard:nPanel]   
	Local oGet1, oGet2, oGet3, oGet4, oGet5
	Local oCombo
	
	//STR0017: "Avisos por E-mail", STR0018: "Sim", STR0019: "Não"
	TSay():New(010,028,{||OemToAnsi(STR0017)},oPanel,,,,,,.T.)
	oCombo := TComboBox():New(008,075,{|u|If(PCount()>0,aCposGRL[1]:=u,aCposGRL[1])},;
	                  {"1="+OemToAnsi(STR0018),"2="+OemToAnsi(STR0019)},,,oPanel,,,,,,.T.)
	oCombo:bHelp := {||Help(,,"MV_RESAVIS",,GetDescMV("MV_RESAVIS"), 1, 0 )}
	
	//STR0020: "Grupo de Acesso padrão"
	TSay():New(010,145,{||OemToAnsi(STR0020)},oPanel,,,,,,.T.)
	oGet1 := TGet():New(008,210,{|u|If(PCount()>0,aCposGRL[2]:=u,aCposGRL[2]+Space(250-Len(aCposGRL[2])))},oPanel,50,;
	                       ,,,,,,,,.T.,,,,,,,,.F.,,"aCposGRL[2]")
	oGet1:bHelp := {||Help(,,"MV_RESGRAC",,GetDescMV("MV_RESGRAC"), 1, 0 )}
	
	//STR0021: "Dias Retrocedência"
	TSay():New(030,028,{||OemToAnsi(STR0021)},oPanel,,,,,,.T.)
	oGet2 := TGet():New(028,80,{|u|If(PCount()>0,aCposGRL[3]:=u,aCposGRL[3]+Space(250-Len(aCposGRL[3])))},oPanel,30,;
	                      ,"999999",,,,,,,.T.,,,,,,,,.F.,,"aCposGRL[3]")
	oGet2:bHelp := {||Help(,,"MV_RESDIAS",,GetDescMV("MV_RESDIAS"), 1, 0 )}
	
	//STR0022: "Exportações Protheus/Reserve"
	TSay():New(030,145,{||OemToAnsi(STR0022)},oPanel,,,,,,.T.)
	oGet3 := TGet():New(028,230,{|u|If(PCount()>0,aCposGRL[4]:=u,aCposGRL[4]+Space(250-Len(aCposGRL[4])))},oPanel,30,;
	                       ,,,,,,,,.T.,,,,,,,,.F.,,"aCposGRL[4]")
	oGet3:bHelp := {||Help(,,"MV_RESCAD",,GetDescMV("MV_RESCAD"), 1, 0 )}
	
	//STR0063: "Aprovador Padrão"
	TSay():New(050,028,{||OemToAnsi(STR0063)},oPanel,,,,,,.T.)
	oGet4 := TGet():New(048,080,{|u|If(PCount()>0,aCposGRL[6]:=u,aCposGRL[6]+Space(250-Len(aCposGRL[6])))},oPanel,50,;
	             ,,{||Vazio(aCposGRL[6]) .OR. ExistCPO("RD0",AllTrim(aCposGRL[6]))},,,,,,.T.,,,,,,,,.F.,;
	             "RD0","aCposGRL[6]",,,,.T.,.F.)
	oGet4:bHelp := {||Help(,,"MV_RESAPRO",,GetDescMV("MV_RESAPRO"), 1, 0 )}
	
	//Permite que participante seja aprovador dele mesmo.
	TSay():New(050,145,{||OemToAnsi(STR0085)},oPanel,,,,,,.T.)
	oCombo1 := TComboBox():New(050,225,{|u|If(PCount()>0,aCposGRL[7]:=u,aCposGRL[7])},;
	                  {"1=" + STR0086,"2=" + STR0087},40,,oPanel,,,,,,.T.)
	oCombo1:bHelp := {||Help(,,"MV_RESAPRT",,GetDescMV("MV_RESAPRT"), 1, 0 )}

	//STR0097: "Considera dias úteis ou corridos"
	TSay():New(070,028,{||OemToAnsi(STR0097)},oPanel,,,,,,.T.) //
	oCombo1 := TComboBox():New(070,080,{|u|If(PCount()>0,aCposGRL[8]:=u,aCposGRL[8])},; 
	                  {"1="+ OemToAnsi(STR0098),"2="+ OemToAnsi(STR0099)},50,,oPanel,,,,,,.T.)
	oCombo1:bHelp := {||Help(,,"MV_RESUTCO",,GetDescMV("MV_RESUTCO"), 1, 0 )}
	
	
	/*STR0023: "Códigos dos usuários do Depto. de Viagem com acesso as informações de todas as viagens,"
	  STR0024: "separados por ; (ID do usuário Protheus)" */
	TSay():New(090,028,{||OemToAnsi(STR0023)+CRLF+OemToAnsi(STR0024)},oPanel,,,,,,.T.,,,,50)
	oGet5 := TGet():New(110,028,{|u|If(PCount()>0,aCposGRL[5]:=u,aCposGRL[5]+Space(250-Len(aCposGRL[5])))},oPanel,230,;	
	                       ,,,,,,,,.T.,,,,,,,,.F.,,"aCposGRL[5]")
    oGet5:bHelp := {||Help(,,"MV_RESGVIA",,GetDescMV("MV_RESGVIA"), 1, 0 )}
Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadFAT
Função que carrega os valores dos Parâmetros de Faturamento, em um vetor   

@author Pedro Alencar	
@since 01/11/2013	
@version 11.90
@param aCposFAT, Vetor passado por referência
/*/
//--------------------------------------------------------------------
Static Function LoadFAT(aCposFAT)
	aCposFAT[1] := SuperGetMV("MV_RESPROD",,Space(250)) //Código do Produto
	aCposFAT[2] := SuperGetMV("MV_RESCPGT",,Space(250)) //Condição de pagamento
	aCposFAT[3] := SuperGetMV("MV_RESTES1",,Space(250)) //TES 1
	aCposFAT[4] := SuperGetMV("MV_RESTES2",,Space(250)) //TES 2
	aCposFAT[5] := SuperGetMV("MV_RESFTAN",,Space(250)) //antecipa faturamento?
	
Return Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} MontaFAT
Função que monta, no Wizard, os campos dos parâmetros de Faturamento

@author Pedro Alencar	
@since 01/11/2013	
@version 11.90
@param oWizard, Objeto Wizard
@param aCposFAT, Vetor com os parâmetros
/*/
//--------------------------------------------------------------------
Static Function MontaFAT(oWizard,aCposFAT)
	Local oPanel := oWizard:oMPanel[oWizard:nPanel]   
	Local oGet1, oGet2, oGet3, oGet4, oCombo1
	
	//STR0025: "Código do Produto"
	TSay():New(010,028,{||OemToAnsi(STR0025)},oPanel,,,,,,.T.)
	oGet1 := TGet():New(008,095,{|u|If(PCount()>0,aCposFAT[1]:=u,aCposFAT[1]+Space(250-Len(aCposFAT[1])))},oPanel,50,;
	             ,,{||Vazio(aCposFAT[1]) .OR. ExistCPO("SB1",AllTrim(aCposFAT[1]))},,,,,,.T.,,,,,,,,.F.,;
	             "SB1","aCposFAT[1]",,,,.T.,.F.)
	oGet1:bHelp := {||Help(,,"MV_RESPROD",,GetDescMV("MV_RESPROD"), 1, 0 )}
	
	//STR0026: "Condição de Pagamento"
	TSay():New(030,028,{||OemToAnsi(STR0026)},oPanel,,,,,,.T.,)
	oGet2 := TGet():New(028,095,{|u|If(PCount()>0,aCposFAT[2]:=u,aCposFAT[2]+Space(250-Len(aCposFAT[2])))},oPanel,50,;
	             ,,{||Vazio(aCposFAT[2]) .OR. ExistCPO("SE4",AllTrim(aCposFAT[2]))},,,,,,.T.,,,,,,,,.F.,;
	             "SE4","aCposFAT[2]",,,,.T.,.F.)
	oGet2:bHelp := {||Help(,,"MV_RESCPGT",,GetDescMV("MV_RESCPGT"), 1, 0 )}
	
	//STR0027: "Tipo de Entrada e Saída"
	TSay():New(050,028,{||OemToAnsi(STR0027)+" 1"},oPanel,,,,,,.T.)
	oGet3 := TGet():New(048,095,{|u|If(PCount()>0,aCposFAT[3]:=u,aCposFAT[3]+Space(250-Len(aCposFAT[3])))},oPanel,50,;
	             ,,{||Vazio(aCposFAT[3]) .OR. ExistCPO("SF4",AllTrim(aCposFAT[3]))},,,,,,.T.,,,,,,,,.F.,;
	             "SF4","aCposFAT[3]",,,,.T.,.F.)
	oGet3:bHelp := {||Help(,,"MV_RESTES1",,GetDescMV("MV_RESTES1"), 1, 0 )}
	
	TSay():New(070,028,{||OemToAnsi(STR0027)+" 2"},oPanel,,,,,,.T.)
	oGet4 := TGet():New(068,095,{|u|If(PCount()>0,aCposFAT[4]:=u,aCposFAT[4]+Space(250-Len(aCposFAT[4])))},oPanel,50,;
	             ,,{||Vazio(aCposFAT[4]) .OR. ExistCPO("SF4",AllTrim(aCposFAT[4]))},,,,,,.T.,,,,,,,,.F.,;
	             "SF4","aCposFAT[4]",,,,.T.,.F.)
	oGet4:bHelp := {||Help(,,"MV_RESTES2",,GetDescMV("MV_RESTES2"), 1, 0 )}
	
	//Antecipa Faturamento
	TSay():New(090,028,{||OemToAnsi(STR0083)},oPanel,,,,,,.T.)
	oCombo1 := TComboBox():New(088,095,{|u|If(PCount()>0,aCposFAT[5]:=u,aCposFAT[5])},;
	                  {"1="+OemToAnsi(STR0018),"2="+OemToAnsi(STR0019)},40,,oPanel,,,,,,.T.)
	oCombo1:bHelp := {||Help(,,"MV_RESFTAN",,GetDescMV("MV_RESFTAN"), 1, 0 )}
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadPRESTA
Função que carrega os valores dos Parâmetros de Prestação de Contas, 
em um vetor   

@author Pedro Alencar	
@since 01/11/2013	
@version 11.90
@param aCposPRESA, Vetor passado por referência
/*/
//--------------------------------------------------------------------
Static Function LoadPRESTA(aCposPRESA)
	Local aAuxCli := {}
	Local cAuxCli := ""
	
	aCposPRESA[1] := SuperGetMV("MV_RESPFCR",,Space(250)) //Prefixo Titulos a Recebr 
	aCposPRESA[2] := SuperGetMV("MV_RESPFCP",,Space(250)) //Prefixo Titulos a Pagar
	aCposPRESA[3] := SuperGetMV("MV_RESTPPR",,Space(250)) //Tipo Titulos a Receber 
	aCposPRESA[4] := SuperGetMV("MV_RESTPPC",,Space(250)) //Tipo Titulos a Pagar	
	aCposPRESA[5] := SuperGetMV("MV_RESNTCR",,Space(250)) //Natureza Titulos a Receber
	aCposPRESA[6] := SuperGetMV("MV_RESNTCP",,Space(250)) //Natureza Titulos a Pagar	
	aCposPRESA[7] := SuperGetMV("MV_RESNABR",,Space(250)) //Natureza Abono a Receber
	aCposPRESA[8] := SuperGetMV("MV_RESNABP",,Space(250)) //Natureza Abono a Pagar
	aCposPRESA[9] := SuperGetMV("MV_RESPABN",,Space(250)) //Prefixo Titulos de Abono
	aCposPRESA[10] := cValToChar(SuperGetMV("MV_RESDATR",,Space(250))) //Dias de Atraso
	
	//Divide o parâmetro de Cliente|Loja padrão em duas posições do vetor, para dividir em duas Gets
	cAuxCli := SuperGetMV("MV_RESCLIP",,Space(250))	
	aAuxCli := StrToKArr(cAuxCli,"|")
	aCposPRESA[11] := aAuxCli[1]
	If Len(aAuxCli) > 1
		aCposPRESA[12] := aAuxCli[2]
	Else
		aCposPRESA[12] := Space(250)
	EndIf	
	
	aCposPRESA[13] := SuperGetMV("MV_TPTXPCT",,1) //Tipo de taxa utilizada	
	
Return Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} MontaPRESA
Função que monta, no Wizard, os campos dos parâmetros de 
Prestação de Contas    

@author Pedro Alencar	
@since 01/11/2013	
@version 11.90
@param oWizard, Objeto Wizard
@param aCposPRESA, Vetor com os parâmetros
/*/
//--------------------------------------------------------------------
Static Function MontaPRESA(oWizard,aCposPRESA)
	Local oPanel := oWizard:oMPanel[oWizard:nPanel]   
	Local oGet1, oGet2, oGet3, oGet4, oGet5, oGet6, oGet7 
	Local cNotTipo	:= "'" + MV_CPNEG + "/" + MVPAGANT+ "/" + MVRECANT + "/" + MV_CRNEG + "/"+MVPROVIS + "'"

	//STR0028: "Prefixo de Títulos a Receber"
	TSay():New(010,018,{||OemToAnsi(STR0028)},oPanel,,,,,,.T.)
	oGet1 := TGet():New(008,100,{|u|If(PCount()>0,aCposPRESA[1]:=u,aCposPRESA[1]+Space(250-Len(aCposPRESA[1])))},oPanel,50,;
	             ,,,,,,,,.T.,,,,,,,,.F.,,"aCposPRESA[1]")
    oGet1:bHelp := {||Help(,,"MV_RESPFCR",,GetDescMV("MV_RESPFCR"), 1, 0 )}
	
	//STR0029: "Prefixo de Títulos a Pagar"
	TSay():New(010,155,{||OemToAnsi(STR0029)},oPanel,,,,,,.T.)
	oGet2 := TGet():New(008,230,{|u|If(PCount()>0,aCposPRESA[2]:=u,aCposPRESA[2]+Space(250-Len(aCposPRESA[2])))},oPanel,50,;
	             ,,,,,,,,.T.,,,,,,,,.F.,,"aCposPRESA[2]")
	oGet2:bHelp := {||Help(,,"MV_RESPFCP",,GetDescMV("MV_RESPFCP"), 1, 0 )}
	
	//STR0033: "Tipo de Títulos a Receber"
	TSay():New(028,018,{||OemToAnsi(STR0033)},oPanel,,,,,,.T.)
	oGet3 := TGet():New(026,100,{|u|If(PCount()>0,aCposPRESA[3]:=u,aCposPRESA[3]+Space(250-Len(aCposPRESA[3])))},oPanel,50,;
	             ,,{||Vazio(aCposPRESA[3]) .OR. (ExistCPO("SX5","05"+AllTrim(aCposPRESA[3])) .And. !(Alltrim(aCposPRESA[3]) $ cNotTipo)) },,,,,,.T.,,,,,,,,.F.,;
	             "05","aCposPRESA[3]",,,,.T.,.F.)
	oGet3:bHelp := {||Help(,,"MV_RESTPPR",,GetDescMV("MV_RESTPPR"), 1, 0 )}
	
	//STR0059: "Tipo de Títulos a Pagar"
	TSay():New(028,155,{||OemToAnsi(STR0059)},oPanel,,,,,,.T.)
	oGet4 := TGet():New(026,230,{|u|If(PCount()>0,aCposPRESA[4]:=u,aCposPRESA[4]+Space(250-Len(aCposPRESA[4])))},oPanel,50,;
	             ,,{||Vazio(aCposPRESA[4]) .OR. (ExistCPO("SX5","05"+AllTrim(aCposPRESA[4])) .And. !(Alltrim(aCposPRESA[4]) $ cNotTipo)) },,,,,,.T.,,,,,,,,.F.,;
	             "05","aCposPRESA[4]",,,199812,.T.,.F.)
	oGet4:bHelp := {||Help(,,"MV_RESTPPC",,GetDescMV("MV_RESTPPC"), 1, 0 )}
	
	//STR0030: "Natureza de Títulos a Receber"
	TSay():New(046,018,{||OemToAnsi(STR0030)},oPanel,,,,,,.T.)
	oGet5 := TGet():New(044,100,{|u|If(PCount()>0,aCposPRESA[5]:=u,aCposPRESA[5]+Space(250-Len(aCposPRESA[5])))},oPanel,50,;
	             ,,{||Vazio(aCposPRESA[5]) .OR. ExistCPO("SED",AllTrim(aCposPRESA[5]))},,,,,,.T.,,,,,,,,.F.,;
	             "SED","aCposPRESA[5]",,,,.T.,.F.)
	oGet5:bHelp := {||Help(,,"MV_RESNTCR",,GetDescMV("MV_RESNTCR"), 1, 0 )}
	
	//STR0031: "Natureza de Títulos a Pagar"
	TSay():New(046,155,{||OemToAnsi(STR0031)},oPanel,,,,,,.T.)
	oGet6 := TGet():New(044,230,{|u|If(PCount()>0,aCposPRESA[6]:=u,aCposPRESA[6]+Space(250-Len(aCposPRESA[6])))},oPanel,50,;
	             ,,{||Vazio(aCposPRESA[6]) .OR. ExistCPO("SED",AllTrim(aCposPRESA[6]))},,,,,,.T.,,,,,,,,.F.,;
	             "SED","aCposPRESA[6]",,,,.T.,.F.)
	oGet6:bHelp := {||Help(,,"MV_RESNTCP",,GetDescMV("MV_RESNTCP"), 1, 0 )}
	
	//STR0060: "Natureza de Abonos a Receber"
	TSay():New(064,018,{||OemToAnsi(STR0060)},oPanel,,,,,,.T.)
	oGet7 := TGet():New(062,100,{|u|If(PCount()>0,aCposPRESA[7]:=u,aCposPRESA[7]+Space(250-Len(aCposPRESA[7])))},oPanel,50,;
	             ,,{||Vazio(aCposPRESA[7]) .OR. ExistCPO("SED",AllTrim(aCposPRESA[7]))},,,,,,.T.,,,,,,,,.F.,;
	             "SED","aCposPRESA[7]",,,,.T.,.F.)
	oGet7:bHelp := {||Help(,,"MV_RESNABR",,GetDescMV("MV_RESNABR"), 1, 0 )}
	
	//STR0061: "Natureza de Abonos a Pagar"
	TSay():New(064,155,{||OemToAnsi(STR0061)},oPanel,,,,,,.T.)
	oGet8 := TGet():New(062,230,{|u|If(PCount()>0,aCposPRESA[8]:=u,aCposPRESA[8]+Space(250-Len(aCposPRESA[8])))},oPanel,50,;
	             ,,{||Vazio(aCposPRESA[8]) .OR. ExistCPO("SED",AllTrim(aCposPRESA[8]))},,,,,,.T.,,,,,,,,.F.,;
	             "SED","aCposPRESA[8]",,,,.T.,.F.)
	oGet8:bHelp := {||Help(,,"MV_RESNABP",,GetDescMV("MV_RESNABP"), 1, 0 )}
	
	//STR0062: "Prefixo de Títulos de Abono"
	TSay():New(082,018,{||OemToAnsi(STR0062)},oPanel,,,,,,.T.)
	oGet9 := TGet():New(080,100,{|u|If(PCount()>0,aCposPRESA[9]:=u,aCposPRESA[9]+Space(250-Len(aCposPRESA[9])))},oPanel,50,;
	             ,,,,,,,,.T.,,,,,,,,.F.,,"aCposPRESA[9]")
	oGet9:bHelp := {||Help(,,"MV_RESPABN",,GetDescMV("MV_RESPABN"), 1, 0 )}
	
	//STR0034: "Dias de Atraso" 
	TSay():New(082,155,{||OemToAnsi(STR0034)},oPanel,,,,,,.T.)
	oGet10 := TGet():New(080,230,{|u|If(PCount()>0,aCposPRESA[10]:=u,aCposPRESA[10]+Space(250-Len(aCposPRESA[10])))},oPanel,50,;
	             ,"999999",,,,,,,.T.,,,,,,,,.F.,,"aCposPRESA[10]")
	oGet10:bHelp := {||Help(,,"MV_RESDATR",,GetDescMV("MV_RESDATR"), 1, 0 )}
	
	//STR0032: "Cliente Padrão"
	TSay():New(100,018,{||OemToAnsi(STR0032)},oPanel,,,,,,.T.)
	oGet11 := TGet():New(098,100,{|u|If(PCount()>0,aCposPRESA[11]:=u,aCposPRESA[11]+Space(250-Len(aCposPRESA[11])))},oPanel,50,;
	             ,,{||Vazio(aCposPRESA[11]) .OR. ExistCPO("SA1",AllTrim(aCposPRESA[11]))},,,,,,.T.,,,,,,,,.F.,;
	             "SA1","aCposPRESA[11]",,,,.T.,.F.)
	oGet11:bHelp := {||Help(,,"MV_RESCLIP",,GetDescMV("MV_RESCLIP"), 1, 0 )}
	
	//STR0058: "Loja"
	TSay():New(100,155,{||OemToAnsi(STR0058)},oPanel,,,,,,.T.)
	oGet12 := TGet():New(098,230,{|u|If(PCount()>0,aCposPRESA[12]:=u,aCposPRESA[12]+Space(250-Len(aCposPRESA[12])))},oPanel,50,;
	             ,,,,,,,,.T.,,,,,,,,.F.,,"aCposPRESA[12]")
	oGet12:bHelp := {||Help(,,"MV_RESCLIP",,GetDescMV("MV_RESCLIP"), 1, 0 )}             	                  

	//STR0076: "Cotação de Turismo", STR0077: "Primeiro dia da Viagem", STR0078: "Último dia da Viagem"
	TSay():New(118,018,{||OemToAnsi(STR0108)},oPanel,,,,,,.T.)
	oCombo := TComboBox():New(116,100,{|u|If(PCount()>0,aCposPRESA[13]:=u,aCposPRESA[13])},;
	                  {"1="+STR0076,"2="+STR0077,"3="+STR0078},85,,oPanel,,,,,,.T.)
	oCombo:bHelp := {||Help(,,"MV_TPTXPCT",,GetDescMV("MV_TPTXPCT"), 1, 0 )}


Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadPRESTB
Função que carrega os valores dos Parâmetros de Prestação de Contas, 
em um vetor   

@author Pedro Pereira Lima	
@since 22/08/2016	
@version 12.1.7
@param aCposPRESB, Vetor passado por referência
/*/
//--------------------------------------------------------------------
Static Function LoadPRESTB(aCposPRESB)
Local aAuxCli := {}
Local cAuxCli := ""

aCposPRESB[01] := SuperGetMV("MV_PCMDCR",,"2") //Prefixo Titulos a Recebr 
aCposPRESB[02] := SuperGetMV("MV_PCMDCP",,"2") //Prefixo Titulos a Pagar
aCposPRESB[03] := SuperGetMV("MV_RESDTCP",,1) //Prorrogacao da data de vencimento Titulos a Pagar
aCposPRESB[04] := SuperGetMV("MV_RESDTCR",,1) //Prorrogacao da data de vencimento Titulos a Pagar
	
Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} MontaPRESB
Função que monta, no Wizard, os campos dos parâmetros de 
Prestação de Contas    

@author Pedro Pereira Lima	
@since 23/08/2016	
@version 12.1.7
@param oWizard, Objeto Wizard
@param aCposPRESB, Vetor com os parâmetros
/*/
//--------------------------------------------------------------------
Static Function MontaPRESB(oWizard,aCposPRESB)
Local oPanel := oWizard:oMPanel[oWizard:nPanel]   
Local oCombo01, oCombo02, oGet01, oGet02 
	
//STR0104: "Moeda forte", STR0105: "Moeda original"
TSay():New(010,018,{||OemToAnsi(STR0104)},oPanel,,,,,,.T.)
oCombo01 := TComboBox():New(006,120,{|u|If(PCount()>0,aCposPRESB[01]:=u,aCposPRESB[01])},;
                  {"1=" + STR0105,"2=" + STR0106},85,,oPanel,,,,,,.T.)
oCombo01:bHelp := {||Help(,,"MV_PCMDCR",,GetDescMV("MV_PCMDCR"), 1, 0 )}

//STR0104: "Moeda forte", STR0105: "Moeda original"
TSay():New(028,018,{||OemToAnsi(STR0107)},oPanel,,,,,,.T.)
oCombo02 := TComboBox():New(024,120,{|u|If(PCount()>0,aCposPRESB[02]:=u,aCposPRESB[02])},;
                  {"1=" + STR0105,"2=" + STR0106},85,,oPanel,,,,,,.T.)
oCombo02:bHelp := {||Help(,,"MV_PCMDCP",,GetDescMV("MV_PCMDCP"), 1, 0 )}

//STR0110: "Dias para vencimento do titulo a Pagar"
TSay():New(046,018,{||OemToAnsi(STR0110)},oPanel,,,,,,.T.)
oGet01 := TGet():New(042,120,{|u|If(PCount()>0,aCposPRESB[03]:=u,PadR(aCposPRESB[03],254))},oPanel,50,;
	             ,"9999",,,,,,,.T.,,,,,,,,.F.,,"aCposPRESB[03]")
oGet01:bHelp := {||Help(,,"MV_RESDTCP",,GetDescMV("MV_RESDTCP"), 1, 0 )}

//STR0110: "Dias para vencimento do titulo a Receber"
TSay():New(064,018,{||OemToAnsi(STR0111)},oPanel,,,,,,.T.)
oGet02 := TGet():New(056,120,{|u|If(PCount()>0,aCposPRESB[04]:=u,PadR(aCposPRESB[04],254))},oPanel,50,;
	             ,"9999",,,,,,,.T.,,,,,,,,.F.,,"aCposPRESB[04]")
oGet02:bHelp := {||Help(,,"MV_RESDTCR",,GetDescMV("MV_RESDTCR"), 1, 0 )}

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadADT
Função que carrega os valores dos Parâmetros de Adiantamento, 
em um vetor   

@author Pedro Alencar	
@since 01/11/2013	
@version 11.90
@param aCposADT, Vetor passado por referência
/*/
//--------------------------------------------------------------------
Static Function LoadADT(aCposADT)
	aCposADT[1] := cValToChar(SuperGetMV("MV_RESPCAT",,Space(250)))	//Dias (max.)
	aCposADT[2] := cValToChar(SuperGetMV("MV_RESQTPC",,Space(250)))	//Quantidade (max.)
	aCposADT[3] := SuperGetMV("MV_RESADSP",,0)							//Adiantamento sem pernoite
	aCposADT[4] := SuperGetMV("MV_RESADFX",,0)							//Valor fixo
	aCposADT[5] := SuperGetMV("MV_RESADDI",,0)							//Valor Diário
	aCposADT[6] := SuperGetMV("MV_RESNTAD",,Space(250))				//Natureza
	aCposADT[7] := cValToChar(SuperGetMV("MV_RESADDU",,Space(250)))	//Dias uteis
	aCposADT[8] := SuperGetMV("MV_RESPERA",,Space(250))				//Tipo de Viagem
	aCposADT[9] := SuperGetMV("MV_RESTPAD",,Space(250))				//Tipo de Título
	aCposADT[10] := SuperGetMV("MV_RESPREF",,Space(250))				//Prefixo titulos a pagar (Reserve)
	aCposADT[11] := SuperGetMV("MV_RESPRFP",,Space(250))				//Prefixo titulos a pagar (Protheus)
	aCposADT[12] := SuperGetMV("MV_ADITXME",,1)						//Informar taxa de conversão turismo
	
//	aCposADT[13] := cValToChar(SuperGetMV("MV_RESUTCO",,SPACE(250))) //Considera dias úteis ou corridos
	aCposADT[13]/*14*/ := cValToChar(SuperGetMV("MV_RESPURG",,SPACE(250))) //Previsão para adiantamentos urgentes
	aCposADT[14]/*15*/ := cValToChar(SuperGetMV("MV_RESCALC",,SPACE(250))) //Data base para cálculo
	
	
Return Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} MontaADT
Função que monta, no Wizard, os campos dos parâmetros de Adiantamento

@author Pedro Alencar	
@since 01/11/2013	
@version 11.90
@param oWizard, Objeto Wizard
@param aCposADT, Vetor com os parâmetros
/*/
//--------------------------------------------------------------------
Static Function MontaADT(oWizard,aCposADT)
	Local oPanel := oWizard:oMPanel[oWizard:nPanel]   
	Local oGet1, oGet2, oGet3, oGet4, oGet5, oGet6, oGet7, oGet8, oGet9, oGet10, oGet11
	Local oCombo1
	Local cNotTipo	:= "'" + MV_CPNEG + "/" + MVPAGANT+ "/" + MVRECANT + "/" + MV_CRNEG + "/"+MVPROVIS + "'"

	//STR0035: "Dias (max.)"
	TSay():New(003,015,{||OemToAnsi(STR0035)},oPanel,,,,,,.T.)
	oGet1 := TGet():New(001,105,{|u|If(PCount()>0,aCposADT[1]:=u,aCposADT[1]+Space(250-Len(aCposADT[1])))},oPanel,50,;
	             ,"999999",,,,,,,.T.,,,,,,,,.F.,,"aCposADT[1]")
	oGet1:bHelp := {||Help(,,"MV_RESPCAT",,GetDescMV("MV_RESPCAT"), 1, 0 )}
	
	//STR0036: "Quantidade (max.)"
	TSay():New(003,175,{||OemToAnsi(STR0036)},oPanel,,,,,,.T.)
	oGet2 := TGet():New(001,228,{|u|If(PCount()>0,aCposADT[2]:=u,aCposADT[2]+Space(250-Len(aCposADT[2])))},oPanel,50,;
	             ,"999999",,,,,,,.T.,,,,,,,,.F.,,"aCposADT[2]")
	oGet2:bHelp := {||Help(,,"MV_RESQTPC",,GetDescMV("MV_RESQTPC"), 1, 0 )}
	
	//STR0037: "Adiantamento sem Pernoite"
	TSay():New(019,015,{||OemToAnsi(STR0037)},oPanel,,,,,,.T.)
	oGet3 := TGet():New(017,105,{|u|If(PCount()>0,aCposADT[3]:=u,aCposADT[3])},oPanel,50,;
	             ,"@E 999,999,999.99",,,,,,,.T.,,,,,,,,.F.,,"aCposADT[3]")
	oGet3:bHelp := {||Help(,,"MV_RESADSP",,GetDescMV("MV_RESADSP"), 1, 0 )}
	
	//STR0038: "Valor Fixo"
	TSay():New(019,175,{||OemToAnsi(STR0038)},oPanel,,,,,,.T.)
	oGet4 := TGet():New(017,228,{|u|If(PCount()>0,aCposADT[4]:=u,aCposADT[4])},oPanel,50,;
	             ,"@E 999,999,999.99",,,,,,,.T.,,,,,,,,.F.,,"aCposADT[4]")
	oGet4:bHelp := {||Help(,,"MV_RESADFX",,GetDescMV("MV_RESADFX"), 1, 0 )}
	
	//STR0039: "Valor Diário"
	TSay():New(035,015,{||OemToAnsi(STR0039)},oPanel,,,,,,.T.)
	oGet5 := TGet():New(033,105,{|u|If(PCount()>0,aCposADT[5]:=u,aCposADT[5])},oPanel,50,;
	             ,"@E 999,999,999.99",,,,,,,.T.,,,,,,,,.F.,,"aCposADT[5]")
	oGet5:bHelp := {||Help(,,"MV_RESADDI",,GetDescMV("MV_RESADDI"), 1, 0 )}
	
	//STR0040: "Natureza"
	TSay():New(035,175,{||OemToAnsi(STR0040)},oPanel,,,,,,.T.)
	oGet6 := TGet():New(033,228,{|u|If(PCount()>0,aCposADT[6]:=u,aCposADT[6]+Space(250-Len(aCposADT[6])))},oPanel,50,;
	             ,,{||Vazio(aCposADT[6]) .OR. ExistCPO("SED",AllTrim(aCposADT[6]))},,,,,,.T.,,,,,,,,.F.,;
	             "SED","aCposADT[6]",,,,.T.,.F.)
	oGet6:bHelp := {||Help(,,"MV_RESNTAD",,GetDescMV("MV_RESNTAD"), 1, 0 )}
	
	//STR0041: "Dias úteis para previsão"
	TSay():New(051,015,{||OemToAnsi(STR0041)},oPanel,,,,,,.T.)
	oGet7 := TGet():New(049,105,{|u|If(PCount()>0,aCposADT[7]:=u,aCposADT[7]+Space(250-Len(aCposADT[7])))},oPanel,50,;
	             ,"999999",,,,,,,.T.,,,,,,,,.F.,,"aCposADT[7]")
	oGet7:bHelp := {||Help(,,"MV_RESADDU",,GetDescMV("MV_RESADDU"), 1, 0 )}
	
	//STR0042: "Tipo de Viagem", STR0043: "Nacional", STR0044: "Internacional", STR0045: "Todas"
	TSay():New(051,175,{||OemToAnsi(STR0042)},oPanel,,,,,,.T.)
	oCombo1 := TComboBox():New(049,228,{|u|If(PCount()>0,aCposADT[8]:=u,aCposADT[8])},;
	                  {"1="+OemToAnsi(STR0045),"2="+OemToAnsi(STR0043),"3="+OemToAnsi(STR0044)},50,,oPanel,,,,,,.T.)
	oCombo1:bHelp := {||Help(,,"MV_RESPERA",,GetDescMV("MV_RESPERA"), 1, 0 )}
	
	//STR0046: "Tipo dos Títulos"
	TSay():New(067,015,{||OemToAnsi(STR0046)},oPanel,,,,,,.T.)
	oGet8 := TGet():New(065,105,{|u|If(PCount()>0,aCposADT[9]:=u,aCposADT[9]+Space(250-Len(aCposADT[9])))},oPanel,50,;
	                       ,,{||Vazio(aCposADT[9]) .OR. (ExistCPO("SX5","05"+AllTrim(aCposADT[9])) .And. !(Alltrim(aCposADT[9]) $ cNotTipo)) },,,,,,.T.,,,,,,,,.F.,;
	                       "05","aCposADT[9]",,,,.T.,.F.)
	oGet8:bHelp := {||Help(,,"MV_RESTPAD",,GetDescMV("MV_RESTPAD"), 1, 0 )}
		
	//STR0047: "Prefixo Títulos a Pagar"
	TSay():New(083,015,{||OemToAnsi(STR0047)+" (Reserve)"},oPanel,,,,,,.T.)
	oGet9 := TGet():New(081,105,{|u|If(PCount()>0,aCposADT[10]:=u,aCposADT[10]+Space(250-Len(aCposADT[10])))},oPanel,50,;
	                       ,,,,,,,,.T.,,,,,,,,.F.,,"aCposADT[10]")
	oGet9:bHelp := {||Help(,,"MV_RESPREF",,GetDescMV("MV_RESPREF"), 1, 0 )}
	       
	//STR0100: "Previsao para adiantamento urgentes" !!!!!!!!!!!!!!!
	TSay():New(067,175/*083,175*/,{||OemToAnsi(STR0100)},oPanel,,,,,,.T.)
	oGet11 := TGet():New(067,228,{|u|If(PCount()>0,aCposADT[13]:=u,aCposADT[13]+Space(250-Len(aCposADT[13])))},oPanel,50,;
	             			  ,,,,,,,,.T.,,,,,,,,.F.,,"aCposADT[13]")
	oGet11 :bHelp := {||Help(,,"MV_RESPURG",,GetDescMV("MV_RESPURG"), 1, 0 )}
	
	//STR0047: "Prefixo Títulos a Pagar"
	TSay():New(099,015,{||OemToAnsi(STR0047)+" (Protheus)"},oPanel,,,,,,.T.)
	oGet10 := TGet():New(097,105,{|u|If(PCount()>0,aCposADT[11]:=u,aCposADT[11]+Space(250-Len(aCposADT[11])))},oPanel,50,;
	                       ,,,,,,,,.T.,,,,,,,,.F.,,"aCposADT[11]")
   	oGet10:bHelp := {||Help(,,"MV_RESPRFP",,GetDescMV("MV_RESPRFP"), 1, 0 )}
   	
   	//STR0101: "Data base para cálculo"	!!!!!!!!!!!!!!!!!!!!!!!!!!!
	TSay():New(083,175/*099,175*/,{||OemToAnsi(STR0101)},oPanel,,,,,,.T.)
	oCombo1 := TComboBox():New(083,228,{|u|If(PCount()>0,aCposADT[14]:=u,aCposADT[14])},;
	                  {"1="+ OemToAnsi(STR0102),"2="+ STR0103},60,,oPanel,,,,,,.T.)
	oCombo1:bHelp := {||Help(,,"MV_RESCALC",,GetDescMV("MV_RESCALC"), 1, 0 )}

	//STR0079: "Antes da geração do título", STR0080: "Após a geração do título"
	TSay():New(115,015,{||OemToAnsi(STR0109)},oPanel,,,,,,.T.)
	oCombo := TComboBox():New(113,105,{|u|If(PCount()>0,aCposADT[12]:=u,aCposADT[12])},;
	                  {"1="+STR0079,"2="+STR0080},90,,oPanel,,,,,,.T.)
	oCombo:bHelp := {||Help(,,"MV_ADITXME",,GetDescMV("MV_ADITXME"), 1, 0 )}
		

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadCTT
Função que carrega os valores dos Parâmetros de Cadastros Gerais, 
em um vetor   

@author Pedro Alencar	
@since 01/11/2013	
@version 11.90
@param aCposCTT, Vetor passado por referência
/*/
//--------------------------------------------------------------------
Static Function LoadCTT(aCposCTT)
	aCposCTT[1] := SuperGetMV("MV_RESMAIL",,Space(250)) //E-mail Destinatário
	aCposCTT[2] := SuperGetMV("MV_RESCTT",,Space(250)) //C.C. Rateio
	aCposCTT[3] := SuperGetMV("MV_RESAMB",,Space(250)) //Ambiente
	aCposCTT[4] := SuperGetMV("MV_RESEXP",,Space(250)) //Integração Reserve				
	aCposCTT[5] := SuperGetMV("MV_RESNUM",,Space(250)) //Numeração Viagens
	aCposCTT[6] := SuperGetMV("MV_RESPFX",,Space(250)) //Prefixo para Viagens Avulsas
	aCposCTT[7] := SuperGetMV("MV_RESTOUT",,120)
Return Nil 

//----------------------------------------------------------------------
/*/{Protheus.doc} MontaCTT
Função que monta, no Wizard, os campos dos parâmetros de Cadastros Gerais

@author Pedro Alencar	
@since 01/11/2013	
@version 11.90
@param oWizard, Objeto Wizard
@param aCposCTT, Vetor com os parâmetros
/*/
//----------------------------------------------------------------------
Static Function MontaCTT(oWizard,aCposCTT)

Local oPanel	:= oWizard:oMPanel[oWizard:nPanel]
Local oGet1	:= Nil
Local oGet2	:= Nil
Local oGet3	:= Nil
Local oGet4	:= Nil
Local oGet5	:= Nil
Local oGet6	:= Nil
Local oCombo1	:= Nil

//STR0048: "E-Mail(s) Destinatário(s)"
TSay():New(05,028,{||OemToAnsi(STR0048)},oPanel,,,,,,.T.)
oGet1 := TGet():New(003,095,{|u|If(PCount()>0,aCposCTT[1]:=u,aCposCTT[1]+Space(250-Len(aCposCTT[1])))},oPanel,150,;
                       ,,,,,,,,.T.,,,,,,,,.F.,,"aCposCTT[1]")
oGet1:bHelp := {||Help(,,"MV_RESMAIL",,GetDescMV("MV_RESMAIL"), 1, 0 )}

//STR0049: "C.C. Rateio"
TSay():New(025,028,{||OemToAnsi(STR0049)},oPanel,,,,,,.T.,)
oGet2 := TGet():New(023,095,{|u|If(PCount()>0,aCposCTT[2]:=u,aCposCTT[2]+Space(250-Len(aCposCTT[2])))},oPanel,50,;
                       ,,,,,,,,.T.,,,,,,,,.F.,,"aCposCTT[2]")
oGet2:bHelp := {||Help(,,"MV_RESCTT",,GetDescMV("MV_RESCTT"), 1, 0 )}

//STR0050: "Ambiente"
TSay():New(045,028,{||OemToAnsi(STR0050)},oPanel,,,,,,.T.)
oGet3 := TGet():New(043,095,{|u|If(PCount()>0,aCposCTT[3]:=u,aCposCTT[3]+Space(250-Len(aCposCTT[3])))},oPanel,150,;
            	       ,,,,,,,,.T.,,,,,,,,.F.,,"aCposCTT[3]")
oGet3:bHelp := {||Help(,,"MV_RESAMB",,GetDescMV("MV_RESAMB"), 1, 0 )}

//STR0051: "Integração Reserve", STR0052: "Desativado" 
TSay():New(065,028,{||OemToAnsi(STR0051)},oPanel,,,,,,.T.)
oCombo1 := TComboBox():New(063,095,{|u|If(PCount()>0,aCposCTT[4]:=u,aCposCTT[4])},;
                  {"0="+OemToAnsi(STR0052),"1=" + STR0088,"2=" + STR0089,"3=" + STR0090},100,,oPanel,,,,,,.T.)
oCombo1:bHelp := {||Help(,,"MV_RESEXP",,GetDescMV("MV_RESEXP"), 1, 0 )}

//STR0064: "Numeração Viagens"
TSay():New(085,028,{||OemToAnsi(STR0064)},oPanel,,,,,,.T.)
oGet4 := TGet():New(083,095,{|u|If(PCount()>0,aCposCTT[5]:=u,aCposCTT[5])},oPanel,50,;
             ,"9",{||f691MsgCpo(aCposCTT[5]) },,,,,,.T.,,,,,,,,.F.,,"aCposCTT[5]",,,,,,,,)
oGet4:bHelp := {||Help(,,"MV_RESNUM",,GetDescMV("MV_RESNUM"), 1, 0 )}

//STR0081: "Prefixo Viagens Avulsas"
TSay():New(105,028,{||OemToAnsi(STR0081)},oPanel,,,,,,.T.)
oGet5 := TGet():New(103,095,{|u|If(PCount()>0,aCposCTT[6]:=u,aCposCTT[6])},oPanel,50,;
             ,"9",,,,,,,.T.,,,,,,,,.F.,,"aCposCTT[6]",,,,,,,,)
oGet5:bHelp := {||Help(,,"MV_RESPFX",,GetDescMV("MV_RESPFX"), 1, 0 )}

//STR0081: "TimeOut Proc. Pedidos"
TSay():New(125,028,{ || OemToAnsi("TimeOut Proc. Pedidos")},oPanel,,,,,,.T.)
oGet6 := TGet():New(123, 095, { |u| If(PCount() > 0, aCposCTT[7] := u, aCposCTT[7] ) }, oPanel, 50, , "999999", , , , , , , .T., , , , , , , , .F., , "aCposCTT[7]", , , , , , , , )
oGet6:bHelp := { || Help( , , "MV_RESTOUT", , GetDescMV("MV_RESTOUT"), 1, 0 ) }

//STR0075: "Configurar Aprovações"
oTBtn1 := TButton():Create( oPanel,0120,160,STR0075,{||FINA688()},70,15,,,,.T.,,,,,,)	

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadCONF
Função que carrega os valores dos Parâmetros de Conferência de Serviço, 
em um vetor   

@author Pedro Alencar	
@since 01/11/2013	
@version 11.90
@param aCposCONF, Vetor passado por referência
/*/
//--------------------------------------------------------------------
Static Function LoadCONF(aCposCONF)
	aCposCONF[1] := SuperGetMV("MV_RESPRCF",,Space(250)) //Prefixo Contas a Pagar
	aCposCONF[2] := SuperGetMV("MV_RESTPCF",,Space(250)) //Tipo de Título
	aCposCONF[3] := SuperGetMV("MV_RESNTCF",,Space(250)) //Natureza
	aCposCONF[4] := SuperGetMV("MV_RESCAGE",,Space(250)) //Codigo Fornecedor
	aCposCONF[5] := SuperGetMV("MV_RESLAGE",,Space(250)) //Loja Fornecedor
Return Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} MontaCONF
Função que monta, no Wizard, os campos dos parâmetros de Conferência
de Serviços

@author Pedro Alencar	
@since 01/11/2013	
@version 11.90
@param oWizard, Objeto Wizard
@param aCposCONF, Vetor com os parâmetros
/*/
//--------------------------------------------------------------------
Static Function MontaCONF(oWizard,aCposCONF)
	Local oPanel := oWizard:oMPanel[oWizard:nPanel]   
	Local oGet1, oGet2, oGet3, oGet4, oGet5
	Local cNotTipo	:= "'" + MV_CPNEG + "/" + MVPAGANT+ "/" + MVRECANT + "/" + MV_CRNEG + "/"+MVPROVIS + "'"

	//STR0053: "Prefixo Contas a Pagar"
	TSay():New(010,018,{||OemToAnsi(STR0053)},oPanel,,,,,,.T.)
	oGet1 := TGet():New(008,095,{|u|If(PCount()>0,aCposCONF[1]:=u,aCposCONF[1]+Space(250-Len(aCposCONF[1])))},oPanel,50,;
	             ,,,,,,,,.T.,,,,,,,,.F.,,"aCposCONF[1]")
	oGet1:bHelp := {||Help(,,"MV_RESPRCF",,GetDescMV("MV_RESPRCF"), 1, 0 )}
	
	//STR0054: "Tipo de Título"
	TSay():New(010,155,{||OemToAnsi(STR0054)},oPanel,,,,,,.T.)
	oGet2 := TGet():New(008,225,{|u|If(PCount()>0,aCposCONF[2]:=u,aCposCONF[2]+Space(250-Len(aCposCONF[2])))},oPanel,50,;
	             ,,{||Vazio(aCposCONF[2]) .OR. (ExistCPO("SX5","05"+AllTrim(aCposCONF[2])) .And. !(Alltrim(aCposCONF[2]) $ cNotTipo)) },,,,,,.T.,,,,,,,,.F.,;
	             "05","aCposCONF[2]",,,,.T.,.F.)
	oGet2:bHelp := {||Help(,,"MV_RESTPCF",,GetDescMV("MV_RESTPCF"), 1, 0 )}
	
	//STR0040: "Natureza"
	TSay():New(030,018,{||OemToAnsi(STR0040)},oPanel,,,,,,.T.)
	oGet3 := TGet():New(028,095,{|u|If(PCount()>0,aCposCONF[3]:=u,aCposCONF[3]+Space(250-Len(aCposCONF[3])))},oPanel,50,;
	             ,,{||Vazio(aCposCONF[3]) .OR. ExistCPO("SED",AllTrim(aCposCONF[3]))},,,,,,.T.,,,,,,,,.F.,;
	             "SED","aCposCONF[3]",,,,.T.,.F.)
	oGet3:bHelp := {||Help(,,"MV_RESNTCF",,GetDescMV("MV_RESNTCF"), 1, 0 )}
	
	//STR0055: "Código do Fornecedor"
	TSay():New(030,155,{||OemToAnsi(STR0055)},oPanel,,,,,,.T.)
	oGet4 := TGet():New(028,225,{|u|If(PCount()>0,aCposCONF[4]:=u,aCposCONF[4]+Space(250-Len(aCposCONF[4])))},oPanel,50,;
	             ,,{||Vazio(aCposCONF[4]) .OR. ExistCPO("SA2",AllTrim(aCposCONF[4]))},,,,,,.T.,,,,,,,,.F.,;
	             "SA2A","aCposCONF[4]",,,,.T.,.F.)
	oGet4:bHelp := {||Help(,,"MV_RESCAGE",,GetDescMV("MV_RESCAGE"), 1, 0 )}
	
	//STR0056: "Loja do Fornecedor"
	TSay():New(050,018,{||OemToAnsi(STR0056)},oPanel,,,,,,.T.)
	oGet5 := TGet():New(048,095,{|u|If(PCount()>0,aCposCONF[5]:=u,aCposCONF[5]+Space(250-Len(aCposCONF[5])))},oPanel,50,;
	                       ,,,,,,,,.T.,,,,,,,,.F.,,"aCposCONF[5]")
	oGet5:bHelp := {||Help(,,"MV_RESLAGE",,GetDescMV("MV_RESLAGE"), 1, 0 )}                       
Return Nil
//--------------------------------------------------------------------
/*/{Protheus.doc} LoadVIAG
Função que carrega os valores dos Parâmetros de Viagem Avulsa, 
em um vetor   

@author Antonio Florêncio Domingos Filho	
@since 19/06/2015	
@version 12.1.6
@param aCposVIAG, Vetor passado por referência
/*/
//--------------------------------------------------------------------
Static Function LoadVIAG(aCposVIAG)

Local nX

	cAux := ALLTRIM(SuperGetMV("MV_RESSLAV",,Space(250))) //Todos
	
	For nX := 1 to Len(cAux)
	
		aCposVIAG[nX] := If(Substr(cAux,nX,1)=="1",.T.,.F.) //1=Aereo
    
    Next

Return Nil 
//--------------------------------------------------------------------
/*/{Protheus.doc} MontaVIAG
Função que monta, no Wizard, os campos dos parâmetros de Viagem Avulsa

@author Antonio Florêncio Domingos Filho
@since 19/06/2015	
@version 12.1.6
@param oWizard, Objeto Wizard
@param aCposVIAG, Vetor com os parâmetros
/*/
//--------------------------------------------------------------------
Static Function MontaVIAG(oWizard,aCposVIAG)
	Local oPanel := oWizard:oMPanel[oWizard:nPanel]   
	Local oCheck1, oCheck1, oCheck2, oCheck3, oCheck4, oCheck5, oCheck6
	oCheck1	:= TCheckBox():New(010,018,STR0067,bSETGET(aCposVIAG[1])		,oPanel,050,009,,,,,,,,.T.,,,) //"Aereo"
	oCheck2	:= TCheckBox():New(030,018,STR0068,bSETGET(aCposVIAG[2])		,oPanel,050,009,,,,,,,,.T.,,,) //"Hotel"
	oCheck3	:= TCheckBox():New(050,018,STR0069,bSETGET(aCposVIAG[3])		,oPanel,050,009,,,,,,,,.T.,,,) //"Carro"
	oCheck4	:= TCheckBox():New(070,018,STR0070,bSETGET(aCposVIAG[4])		,oPanel,050,009,,,,,,,,.T.,,,) //"Seguro"
	oCheck5	:= TCheckBox():New(090,018,STR0071,bSETGET(aCposVIAG[5])		,oPanel,050,009,,,,,,,,.T.,,,) //"Rodoviario"
	oCheck6	:= TCheckBox():New(110,018,STR0072,bSETGET(aCposVIAG[6])		,oPanel,050,009,,,,,,,,.T.,,,) //"Outros"
Return Nil
//--------------------------------------------------------------------
/*/{Protheus.doc} FN691Grava
Função que abre uma msgRun para gravação dos parâmetros no final do 
Wizard

@author Pedro Alencar	
@since 01/11/2013	
@version 11.90
@param aCposGRL, Vetor de parâmetros Gerais
@param aCposFAT, Vetor de parâmetros de Faturamento
@param aCposPRESA, Vetor de parâmetros de Prestação de Contas
@param aCposADT, Vetor de parâmetros de Adiantamento
@param aCposCTT, Vetor de parâmetros de Cadastros Gerais
@param aCposCONF, Vetor de parâmetros de Conferência de Serviços
@param aCposVIAG, Vetor de parâmetros de Viagem Avulsa
@param aCposVIN, Vetor de parâmetros de Vínculo Automático
@param aCposPRESB, Vetor de parâmetros de Prestação de Contas
/*/
//--------------------------------------------------------------------
Static Function FN691Grava(aCposGRL,aCposFAT,aCposPRESA,aCposADT,aCposCTT,aCposCONF,aCposVIAG,aCposVIN,aCposPRESB)
	//STR0057: "Gravando Parâmetros..."
	MsgRun (OemToAnsi(STR0057),"FN691Grava",{||FN691SalvaParam(aCposGRL,aCposFAT,aCposPRESA,aCposADT,aCposCTT,aCposCONF,aCposVIAG,aCposVIN,aCposPRESB)})
Return .T. 

//--------------------------------------------------------------------
/*/{Protheus.doc} FN691SalvaParam
Função que salva todos os parâmetros na X6

@author Pedro Alencar	
@since 01/11/2013	
@version 11.90
@param aCposGRL, Vetor de parâmetros Gerais
@param aCposFAT, Vetor de parâmetros de Faturamento
@param aCposPRESA, Vetor de parâmetros de Prestação de Contas
@param aCposADT, Vetor de parâmetros de Adiantamento
@param aCposCTT, Vetor de parâmetros de Cadastros Gerais 
@param aCposCONF, Vetor de parâmetros de Conferência de Serviços
@param aCposVIAG, Vetor de parâmetros de Viagem Avulsa
@param aCposPRESB, Vetor de parâmetros de Prestação de Contas
/*/
//--------------------------------------------------------------------
Static Function FN691SalvaParam(aCposGRL,aCposFAT,aCposPRESA,aCposADT,aCposCTT,aCposCONF,aCposVIAG,aCposVIN,aCposPRESB)
Local cConteudo:= ""
Local nX       := 1
Local cFilViag := ""
	//Salva os Parâmetros GERAIS
	PutMV("MV_RESAVIS",AllTrim(aCposGRL[1]))
	PutMV("MV_RESGRAC",AllTrim(aCposGRL[2]))
	PutMV("MV_RESDIAS",Val(aCposGRL[3]))
	PutMV("MV_RESCAD",AllTrim(aCposGRL[4]))
	PutMV("MV_RESGVIA",AllTrim(aCposGRL[5]))
	PutMV("MV_RESAPRO",AllTrim(aCposGRL[6]))
	PutMV("MV_RESAPRT",AllTrim(aCposGRL[7]))
	
	//Salva os Parâmetros de FATURAMENTO
	PutMV("MV_RESPROD",AllTrim(aCposFAT[1]))
	PutMV("MV_RESCPGT",AllTrim(aCposFAT[2]))
	PutMV("MV_RESTES1",AllTrim(aCposFAT[3]))
	PutMV("MV_RESTES2",AllTrim(aCposFAT[4]))
	PutMV("MV_RESFTAN",AllTrim(aCposFAT[5]))
	
	//Salva os Parâmetros de PRESTAÇÂO DE CONTAS
	PutMV("MV_RESPFCR",AllTrim(aCposPRESA[1]))
	PutMV("MV_RESPFCP",AllTrim(aCposPRESA[2]))
	PutMV("MV_RESTPPR",AllTrim(aCposPRESA[3]))
	PutMV("MV_RESTPPC",AllTrim(aCposPRESA[4]))
	PutMV("MV_RESNTCR",AllTrim(aCposPRESA[5]))
	PutMV("MV_RESNTCP",AllTrim(aCposPRESA[6]))
	PutMV("MV_RESNABR",AllTrim(aCposPRESA[7]))
	PutMV("MV_RESNABP",AllTrim(aCposPRESA[8]))
	PutMV("MV_RESPABN",AllTrim(aCposPRESA[9]))	
	PutMV("MV_RESDATR",Val(aCposPRESA[10]))
	If !Vazio(AllTrim(aCposPRESA[11])) .AND. !Vazio(AllTrim(aCposPRESA[12])) 
		PutMV("MV_RESCLIP",AllTrim(aCposPRESA[11])+"|"+AllTrim(aCposPRESA[12]))
	Else
		PutMV("MV_RESCLIP",AllTrim(""))
	Endif
	PutMV("MV_TPTXPCT",aCposPRESA[13])
	
	//Salva os Parâmetros de ADIANTAMENTO
	PutMV("MV_RESPCAT",Val(aCposADT[1]))
	PutMV("MV_RESQTPC",Val(aCposADT[2]))
	PutMV("MV_RESADSP",aCposADT[3])
	PutMV("MV_RESADFX",aCposADT[4])
	PutMV("MV_RESADDI",aCposADT[5])
	PutMV("MV_RESNTAD",AllTrim(aCposADT[6]))
	PutMV("MV_RESADDU",Val(aCposADT[7]))
	PutMV("MV_RESPERA",AllTrim(aCposADT[8]))
	PutMV("MV_RESTPAD",AllTrim(aCposADT[9]))
	PutMV("MV_RESPREF",AllTrim(aCposADT[10]))
	PutMV("MV_RESPRFP",AllTrim(aCposADT[11]))
	PutMV("MV_ADITXME",aCposADT[12])
	
//	PutMV("MV_RESUTCO",aCposADT[13])
	PutMV("MV_RESPURG",aCposADT[13])
	PutMV("MV_RESCALC",aCposADT[14])
	
	//Salva os Parâmetros de CADASTROS GERAIS
	PutMV("MV_RESMAIL",AllTrim(aCposCTT[1]))
	PutMV("MV_RESCTT",AllTrim(aCposCTT[2]))
	PutMV("MV_RESAMB",AllTrim(aCposCTT[3]))
	PutMV("MV_RESEXP",AllTrim(aCposCTT[4]))
	PutMV("MV_RESNUM",aCposCTT[5])
	PutMV("MV_RESPFX",aCposCTT[6])
	PutMV("MV_RESTOUT",aCposCTT[7])
		
	//Salva os Parâmetros de CONFERÊNCIA DE SERVIÇOS
	PutMV("MV_RESPRCF",AllTrim(aCposCONF[1]))
	PutMV("MV_RESTPCF",AllTrim(aCposCONF[2]))
	PutMV("MV_RESNTCF",AllTrim(aCposCONF[3]))
	PutMV("MV_RESCAGE",AllTrim(aCposCONF[4]))
	PutMV("MV_RESLAGE",AllTrim(aCposCONF[5]))

	//Salva os Parâmetros de Viagem Avulsa
	//1=Aereo;2=Hotel;3=Carro;4=Seguro;5=Rodoviario;6=Outros
	For nX := 1 to Len(aCposViag)
		cConteudo += If(aCposVIAG[nX],"1","0")	
	Next
	PutMV("MV_RESSLAV",Alltrim(cConteudo))
	
	//Salva os Parâmetros de Vínculo Automático
	For nX := 1 To 4
		cFilViag += If( aCposVIN[nX],"1","0")
	Next nX
	
	PutMV("MV_FILVIAG",cFilViag)
	PutMV("MV_RESVINC",aCposVIN[5])

	//Salva os Parâmetros de PRESTAÇÂO DE CONTAS
	PutMv("MV_PCMDCR",aCposPRESB[01])
	PutMv("MV_PCMDCP",aCposPRESB[02])
	PutMv("MV_RESDTCP",aCposPRESB[03])
	PutMv("MV_RESDTCR",aCposPRESB[04])

Return Nil


//--------------------------------------------------------------------
/*/{Protheus.doc} f691MsgCpo
Função que retorna mensagem fixa e pede confirmação quando campo for usado

@author Antonio Domingos	
@since 16/04/2015	
@version 11.90
@Return lRet,Aviso ao usar o campo 
/*/
//--------------------------------------------------------------------

Static Function f691MsgCpo(nNum)

Local lRet:=.T.

If nNum <= 4
	Help(,,"VLDNUM",,STR0082, 1, 0 )//'Valor digitado deve ser igual ou maior que cinco!'
	lRet := .F.
Endif

If lRet .AND. !MsgNoYes(STR0065,STR0066) //"Para uma melhor utilização do parâmetro, verifique a proporção de viagens nacionais em relação as internacionais. Confirme para continuar!"#"Importante"                                                                                                                                                                                                                                                                                                                                                                            
	lRet:=.F.
EndIf

Return(lRet)

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadVIN
Função que carrega os valores dos Parâmetros de Vínculo Automático, 
em um vetor   

@author Anderson Reis	
@since 30/04/2015	
@version 12.1.5
@param aCposVIN, Vetor passado por referência
/*/
//--------------------------------------------------------------------
Static Function LoadVIN(aCposVIN)

	aCposVIN[1] := (Substr(SuperGetMV("MV_FILVIAG",,Space(250)),1,1) == "1") //Passageiro
	aCposVIN[2] := (Substr(SuperGetMV("MV_FILVIAG",,Space(250)),2,1) == "1") //Cliente
	aCposVIN[3] := (Substr(SuperGetMV("MV_FILVIAG",,Space(250)),3,1) == "1") //Centro de Custo
	aCposVIN[4] := (Substr(SuperGetMV("MV_FILVIAG",,Space(250)),4,1) == "1") //Data	
	aCposVIN[5] := SuperGetMV("MV_RESVINC",,Space(250)) //dIAS	
	
				
Return Nil 

/*/{Protheus.doc} Vinculo
Função que monta, no Wizard, os campos dos parâmetros de Vínculo Automatico

@author Anderson Reis	
@since 30/04/2015	
@version 12.1.5
@param oWizard, Objeto Wizard
@param aCposCTT, Vetor com os parâmetros
/*/
//----------------------------------------------------------------------
Static Function MontaVIN(oWizard,aCposVIN)
	Local oPanel := oWizard:oMPanel[oWizard:nPanel] 
	Local oGet
	Local nDias := 0 
	Local nGet := 0 
	Local oCheck1, oCheck2, oCheck3, oCheck4
	
	oCheck1 := TCheckBox():Create( oPanel, {|u| If(PCount() > 0, aCposVin[1] := u, aCposVin[1])}, 31, 20, OemToAnsi(STR0091), 100, 210,,,,,,,, .T.,,,)
	oCheck2 := TCheckBox():Create( oPanel, {|u| If(PCount() > 0, aCposVin[2] := u, aCposVin[2])}, 51, 20, OemToAnsi(STR0092), 100, 210,,,,,,,, .T.,,,)
	oCheck3 := TCheckBox():Create( oPanel, {|u| If(PCount() > 0, aCposVin[3] := u, aCposVin[3])}, 71, 20, OemToAnsi(STR0093), 100, 210,,,,,,, .T.,,,)
	oCheck4 := TCheckBox():Create( oPanel, {|u| If(PCount() > 0, aCposVin[4] := u, aCposVin[4])}, 91, 20, OemToAnsi(STR0094), 100, 210,,,,,,,, .T.,,,)
	TSay():New(71,90,{||OemToAnsi(STR0095)},oPanel,,,,,,.T.)
	
	oGet := TGet():New(070,140,{|u|If(PCount()>0,aCposVIN[5]:=u,aCposVIN[5])},oPanel,25,;
	             ,"999999",,,,,,,.T.,,,,,,,,.F.,,"aCposVIN[5]")
	
		
	
Return Nil

/*/{Protheus.doc} GetDescMV
Retorna a descrição do parâmetro MV
@author Roberto Marques
@since 30/11/2020
@version P12
@param 01 cParam , caracter , código do parametro
@return cParDesc, caracter, descrição do parametro
/*/
Static Function GetDescMV( cParam )
    Local cParDesc := ""
    GetMV(cParam)
    cParDesc := StrTran(x6Descric() + " ", "  ", " ")
    cParDesc += StrTran(x6Desc1() + " " , "  ", " ")
    cParDesc += x6Desc2()
    cParDesc := cParam + ": " + StrTran(AllTrim(cParDesc), "  ", " ")
    If "- " $ cParDesc .AND. Substr(cParDesc,  At("- ", cParDesc) - 1, 1) != " "
        cParDesc := StrTran(AllTrim(cParDesc), "- ", "")
    EndIf
Return cParDesc


