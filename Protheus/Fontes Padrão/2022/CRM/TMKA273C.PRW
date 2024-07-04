#INCLUDE "TCBROWSE.CH"
#INCLUDE "TMKA273C.CH"
#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TMKDEF.CH" 

#DEFINE TEF_CLISITEF				"6"		// Utiliza a DLL CLISITEF no TeleVendas
#DEFINE _FORMATEF					"CC" 	// Formas de pagamento que utilizam operação TEF para validação


/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³																						 ³
³	Posicoes do array aParcelas - por PARCELA											 ³
³	1  - Data    																	 	 ³
³	2  - Valor    																		 ³
³	3  - Forma de Pagamento 															 ³
³	4  - Observacao            															 ³	
³	5  - Valor em Percentual 									   					     ³	
³	6  - ID Cartao (quando usar Multi-TEF)								   			     ³	
³																						 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271Pagamento³ Autor ³ Vendas Clientes   ³ Data ³10/05/00   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa a tela com as condicoes de pagamento                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk271Pagamento(ExpN1, ExpL2,	 ExpA3,	 ExpC4,                ³±±
±±³          ³                ExpO5, ExpC6,  ExpC7,  ExpC8                 ³±±
±±³          ³                ExpO9, ExpC10, ExpC11, ExpC12,               ³±±
±±³          ³                ExpO13,ExpC14, ExpC15, ExpC16,               ³±±
±±³          ³                ExpO17,ExpC18, ExpC19, ExpC20,               ³±±
±±³          ³                Exp021,ExpC22, ExpO23, ExpC24,               ³±±
±±³          ³                Exp025,ExpC26, ExpO27, ExpC28,               ³±±
±±³          ³                ExpO29,ExpC30, ExpO31, ExpN32,               ³±±
±±³          ³                ExpO33,ExpN34, ExpO35, ExpN36,               ³±±
±±³          ³                ExpO37,ExpA38, ExpO39, ExpN40,               ³±±
±±³          ³                ExpO41,ExpN42, ExpO43, ExpN44,               ³±±
±±³          ³                ExpO45,ExpN46, ExpO47, ExpL48,               ³±±
±±³          ³                ExpO49,ExpN50, ExpC51, ExpL52)               ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = opcao selecionada pelo usuario                	   ³±±
±±³          ³ ExpL2 = habilitar ou nao os objetos da tela de forma de     ³±±
±±³          ³ pagamento - para que nao haja conflito com a tela Pai       ³±±
±±³          ³ ExpA3 = dados complementares da parcela                     ³±±
±±³          ³ ExpC4 = condicao de pagamento                               ³±±
±±³          ³ ExpO5 = objeto msget da condicao de pagamento               ³±±
±±³          ³ ExpC6 = descriçao da condicao de pagamento                  ³±±
±±³          ³ ExpO7 = objeto msget da descrição da condicao de pagamento  ³±±
±±³          ³ ExpC8 = transportadora                                      ³±±
±±³          ³ ExpO9 = objeto msget da transportadora                      ³±±
±±³          ³ ExpC10= nome da transportadora                              ³±±
±±³          ³ ExpO11= objeto msget do nome da transportadora              ³±±
±±³          ³ ExpC12= endereço de cobrança                                ³±±
±±³          ³ ExpO13= objeto msget do endereço de cobrança                ³±±
±±³          ³ ExpC14= endereço de entrega                                 ³±±
±±³          ³ ExpO15= objeto msget do endereço de entrega                 ³±±
±±³          ³ ExpC16= cidade de cobrança                                  ³±±
±±³          ³ ExpO17= objeto msget da cidade de cobrança                  ³±±
±±³          ³ ExpC18= cep de cobrança                                     ³±±
±±³          ³ ExpO19= objeto msget do cep de cobrança                     ³±±
±±³          ³ ExpC20= estado de cobrança                                  ³±±
±±³          ³ ExpO21= objeto msget do estado de cobrança                  ³±±
±±³          ³ ExpC22= bairro de entrega                                   ³±±
±±³          ³ ExpO23= objeto msget do bairro de entrega                   ³±±
±±³          ³ ExpC24= bairro de cobrança                                  ³±±
±±³          ³ ExpO25= objeto msget do bairro de cobrança                  ³±±
±±³          ³ ExpC26= cidade de entrega                                   ³±±
±±³          ³ ExpO27= objeto msget da cidade de entrega                   ³±±
±±³          ³ ExpC28= cep de entrega                                      ³±±
±±³          ³ ExpO29= objeto msget do cep de entrega                      ³±±
±±³          ³ ExpC30= estado de entrega                                   ³±±
±±³          ³ ExpO31= objeto msget do estado de entrega                   ³±±
±±³          ³ ExpN32= valor liquido                                       ³±±
±±³          ³ ExpO33= objeto msget para valor liquido                 	   ³±±
±±³          ³ ExpN34= valor da taxa de juros                              ³±±
±±³          ³ ExpO35= objeto msget valor da taxa de juros                 ³±±
±±³          ³ ExpN36= taxa de desconto                                    ³±±
±±³          ³ ExpO37= objeto msget taxa de desconto                       ³±±
±±³          ³ ExpA38= array de parcelas                                   ³±±
±±³          ³ ExpO39= objeto browse de parcelas                           ³±±
±±³          ³ ExpN40= valor da entrada                                    ³±±
±±³          ³ ExpO41= objeto msget com valor de entrada                   ³±±
±±³          ³ ExpN42= valor financiado                                    ³±±
±±³          ³ ExpO43= objeto msget com valor financiado                   ³±±
±±³          ³ ExpN44= quantidade de parcelas                              ³±±
±±³          ³ ExpO45= objeto msget com quantidade de parcelas             ³±±
±±³          ³ ExpN46= valor do juros                                      ³±±
±±³          ³ ExpC47= código de pagamento carregado antes de qualquer     ³±±
±±³          ³ atualização                                                 ³±±
±±³          ³ ExpL48= flag para condicao de pagto do tipo 9.              ³±±
±±³          ³ ExpO49= objeto msget do valor nao faturado                  ³±±
±±³          ³ ExpN50= valor nao faturado                                  ³±±
±±³          ³ ExpC51= código do cliente carregado antes de qualquer       ³±±
±±³          ³ atualização                                                 ³±±
±±³          ³ ExpL52= flag para controle de integração com o SIGACRD      ³±±
±±³          ³ ExpL53= flag para controle da regra de negocios             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273Pagamento(nOpc			,lHabilita		,aItens			,cCodPagto,;
						oCodPagto		,cDescPagto		,oDescPagto		,cCodTransp,;
						oCodTransp		,cTransp		,oTransp		,cCob,;
						oCob			,cEnt			,oEnt			,cCidadeC,;
						oCidadeC		,cCepC			,oCepC			,cUfC,;
						oUfC			,cBairroE		,oBairroE		,cBairroC,;
						oBairroC		,cCidadeE		,oCidadeE		,cCepE,;
						oCepE			,cUfE			,oUfE			,nLiquido,;
						oLiquido		,nTxJuros		,oTxJuros		,nTxDescon,;
						oTxDescon		,aParcelas		,oParcelas		,nEntrada,;
						oEntrada		,nFinanciado	,oFinanciado	,nNumParcelas,;
						oNumParcelas	,nVlJur			,cCodAnt		,lTipo9,;
						oValNFat		,nValNFat		,cCliAnt		,lSigaCRD,;
						lTLVReg)

Local oDlgPagto         						       	// Tela de pagamento
Local lTMKCND  	:= ExistBlock("TMKCND")					// P.E. para TLV na abertura da tela 
Local lTMKVPA  	:= ExistBlock("TMKVPA")					// P.E. para TLV Substitui a funcao
Local lTMKVCPT 	:= FindFunction("T_TMKVCP")				// P.E. para TLV no final da funcao - Para uso exclusivo de Templates
Local lTMKVCP  	:= ExistBlock("TMKVCP")					// P.E. para TLV no final da funcao
Local lTMKCPG	:= ExistBlock("TMKCPG")					// P.E. executado antes da abertura da tela de pagamento para que se possa mudar a variável lHabilAux
Local oVlrPrazo                                         // objeto com o Total do pedido com a condicao
Local nVlrPrazo := 0									// Valor do Total do pedido com a condicao
Local nOpcA		:= 0									// Opcao da escolha OK ou CANCELA
Local cNumTlv   := ""                                   // Codigo do atendimento TLV
Local cCliente  := ""									// Codigo do Cliente
Local cLoja     := ""                                   // Codigo da Loja
Local cCodCont  := ""                                   // Codigo do Contato	
Local cCodOper  := ""                                   // Codigo do Operador
Local cTipoOper := ""                                   // Tipo de operacao("1-Faturamento;2-Orcamento;3-Atendimento")
Local oCurTmk           								// Objeto do CURSOR
Local lRet		:= .F.									// Retorno da funcao
Local cPictTrans:= PesqPict("SUA","UA_TRANSP")			// Picture "Default" do campo de transportadora
Local lHabilAux := lHabilita                            // Flag auxiliar para habilitar ou nao os objetos da tela de forma de pagamento - para que nao haja conflito com a tela Pai
Local lTefMult	:= SuperGetMV("MV_TEFMULT")				// Parametro do SX6 que indica se o sistema vai o TEF multiplas transacoes
Local lTMKFIS	:= GetNewPar("MV_TMKFIS",.T.)			// (Não divulgar) Parametro que indica que a atualização da MATXFIS é feita de maneira on-line, no off-line a MATXFIS só é atualizada quando se entra na condição de pagamento.
Local oFolder		:= Nil								// Objeto TFolder com os folder quando o atendimento televendas é off-line
Local oFolderPagto	:= Nil								// Quando o atendimento televendas é off-line, terá a aba da condição de pagamento, quando o atendimento for on-line terá o dialog da condição de pagamento.
Local oFis			:= Nil								// Objeto com os impostos
Local lTLVReg1		:= IIF(ValType(lTLVReg) <>	"L",.F.,lTLVReg)	// controle de validacao da regra de negocios 
Local lTLVReg2		:= IIF(ValType(lTLVReg) <>	"L",.F.,lTLVReg)	// controle de validacao da regra de negocios 
Local aDadosCompl	:= {}								// Guarda os campos dos dados complementares
Local aInfoSx3      := {}								// Array que possui as informações do SX3
Local aPDFields		:= {"UA_ESTE","UA_CEPE","UA_MUNE","UA_BAIRROE","UA_ENDENT","UA_ESTC","UA_CEPC","UA_MUNC","UA_BAIRROC","UA_ENDCOB"}
Local lChangeSE4	:= .F.
Local lRecalc		:= .F.
Local lObfEstE 		:= .F.
Local lObfCepE 		:= .F. 
Local lObfMunE 		:= .F.
Local lObfBairrE 	:= .F.
Local lObfEndEnt 	:= .F.
Local lObfEstC 		:= .F. 
Local lObfCepC 		:= .F.
Local lObfMunC 		:= .F.
Local lObfBairrC 	:= .F.
Local lObfEndCob 	:= .F.

DEFINE CURSOR oCurTmk HAND								// Muda o cursor para "Hand"	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sincroniza os campos, caso as variaveis passadas pelo parâ³
//³metro não foram atualizadas pelo objeto.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Type("M->UA_CONDPG") <> "U") .And. (cCodPagto <> M->UA_CONDPG)
	cCodPagto := M->UA_CONDPG
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o campo UA_TRANSP é usado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If X3Uso(GetSX3Cache("UA_TRANSP","X3_USADO")) .AND. cCodTransp <> M->UA_TRANSP
	cCodTransp := M->UA_TRANSP
	Tk273AtuTransp(cCodTransp,@cTransp,oTransp)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se a picture da transportadora esta OK³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cPictTrans)
	cPictTrans := "@!"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda os dados complementares originais. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDadosCompl := {cCodTransp	,cTransp	,cCob		,cEnt		,;
				cCidadeC	,cCepC		,cUfC		,cBairroE	,;
				cBairroC	,cCidadeE	,cCepE		,cUfE		,;
				cCliAnt}
				
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o parâmetro MV_TMKFIS estiver falso, significa que     ³
//³o Televendas está trabalhando em modo off-line, ou seja,  ³
//³somente quando abrir a tela de condição de pagamento,     ³
//³a MATXFIS será atualizadada. (Não divulgar)               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTMKFIS

	Tk273RecCpg()		
	Tk273AtuNFs()	
	
	aValores[MERCADORIA] := MaFisRet(, "NF_VALMERC")
	aValores[SUFRAMA] 	 := MaFisRet(, "NF_DESCZF")
	aValores[TOTAL] 	 := MaFisRet(, "NF_TOTAL")
	aValores[BASEDUP] 	 := MaFisRet(, "NF_BASEDUP")
	
EndIf
                            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se existem produtos lancados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aValores[TOTAL] <= 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o flag para nao gerar titulo, poder lancar quantidade e valor total = 0,00 estiver TRUE: NAO FECHA O ATENDIMENTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTesTit
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao estiver usando a entrada automatica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lTk271Auto
			Help(" ",1,"SEMDADOS")
		Endif
		Return(lRet)
		
	Else
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o atendiment vai gerar duplicata, ou a TES esta configurada para que o valor do pedido seja > 0,00³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Type("M->UA_CONDPG") <> "U")
			If Empty(M->UA_CONDPG) .AND. Empty(cCodPagto)
				Help(" ",1,"FALTA_PGTO")
				Return(lRet)
			Endif	
		Else
			Return(lRet)
		EndIf
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Essa funcao esta acessivel somente para a tela de Televendas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nFolder == 1 .AND. (TkGetTipoAte() == "2" .OR. TkGetTipoAte() == "4")) .OR. (nFolder == 2) //Televendas
	cNumTlv   := M->UA_NUM
	cCliente  := M->UA_CLIENTE
	cLoja     := M->UA_LOJA
	cCodCont  := M->UA_CODCONT
	cCodOper  := M->UA_OPERADO
	cTipoOper := M->UA_OPER
Endif

nLiquido 	:= aValores[BASEDUP] 
nValNFat	:= aValores[TOTAL] - aValores[BASEDUP]
nLiquido	:= aValores[BASEDUP] - aValores[ACRESCIMO]
nSuframa	:= aValores[SUFRAMA]
nTotal		:= aValores[TOTAL]

If lTMKVPA
	lRet := U_TMKVPA(	@aValores		,@aObj			,@aItens		,@cCodPagto		,;
						oCodPagto		,@cDescPagto	,@oDescPagto	,@cCodTransp	,;
						@oCodTransp		,@cTransp		,@oTransp		,@cCob			,;
						@oCob			,@cEnt			,@oEnt			,@cCidadeC		,;
						@oCidadeC		,@cCepC			,@oCepC			,@cUfC			,;
						@oUfC			,@cBairroE		,@oBairroE		,@cBairroC		,;
						@oBairroC		,@cCidadeE		,@oCidadeE		,@cCepE			,;
						@oCepE			,@cUfE			,@oUfE			,@nLiquido		,;
						@oLiquido		,@nTxJuros		,@oTxJuros		,@nTxDescon		,;
						@oTxDescon		,@aParcelas		,@oParcelas		,@nEntrada		,;
						@oEntrada		,@nFinanciado	,@oFinanciado	,@nNumParcelas	,;
						@oNumParcelas	,@nVlJur		,nOpc			,cNumTlv		,;
						cCliente		,cLoja			,cCodCont		,cCodOper		,;
						@cCliAnt        ,@lTLVReg)
	Return(lRet)
Endif

If lTMKCPG
	U_TMKCPG( @lHabilAux )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso o nOpc = 2 (visualizacao), nao e habilitado³
//³o campo de condicao de pagamento.               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 2
	lHabilita := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando for feita inclusao de novo GET na tela de condicao de ³
//³pagamento, nao esquecer de incluir novo GET no array         ³
//³aValidGet e se o mesmo possuir uma funcao de validacao,      ³
//³adapta-la a rotina de entrada automatica e incluir essa      ³
//³funcao no array aVldBlock.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao estiver usando a entrada automatica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTk271Auto
	//Desabilita o comando padrão CTRL+S (Salvar)
	SetKEY(K_CTRL_S, { || AllWaysTrue() } )

	//Carregando informaçoes das propriedades dos campos do sx3 para aplicar nos MSGET
	aInfoSx3 := TK273LdSx3()	
	FATPDLoad(Nil,Nil,aPDFields)
	DEFINE MSDIALOG oDlgPagto FROM  23,80 TO IF(!lTMKFIS,495,465),710 TITLE STR0001 PIXEL STYLE DS_MODALFRAME //"Forma de Pagamento"
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for televendas off-line, cria folder de imposto, já que o³
		//³mesmo não é exibido no atendimento.                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lTMKFIS	
			oFolder := TFolder():New(01, 01,{STR0060, STR0061}, {"HEADER", "HEADER"},oDlgPagto,,,,.T.,.F.,0, 0,) // "Cond. Pagto" "Impostos"
			oFolder:Align := CONTROL_ALIGN_ALLCLIENT
			oFolder:aDialogs[1]:oFont := oDlgPagto:oFont			
			oFolder:aDialogs[2]:oFont := oDlgPagto:oFont
			oFis := MaFisRodape(1,oFolder:aDialogs[2],,{01,01,0,0},bListRefresh,.T.)
			oFis:Align := CONTROL_ALIGN_ALLCLIENT
			oFolderPagto :=	oFolder:aDialogs[1]
		Else
			oFolderPagto := oDlgPagto
		EndIf
		
		@ 003,002 TO 115,310 LABEL STR0002 OF oFolderPagto  PIXEL //"Condi‡”es de Pagamento" 
		
		
		@ 011,004 SAY STR0003 OF oFolderPagto PIXEL  //"Condi‡„o" 
		@ 011,040 MSGET oCodPagto VAR cCodPagto SIZE 30,8 OF oFolderPagto PIXEL F3 X3F3("UA_CONDPG") Picture "@!" WHEN lHabilita ;			
					VALID MsgRun(STR0059,"",{||(oParcelas:Disable(),Tk273MontaParcela(	nOpc		,cNumTlv	,@nLiquido		,oLiquido		,;
												 				   						@nTxJuros	,oTxJuros	,@nTxDescon		,oTxDescon		,;
																						@aParcelas	,oParcelas	,@cCodPagto		,oCodPagto		,;
																						@nEntrada	,oEntrada	,@nFinanciado	,oFinanciado	,;
																						@cDescPagto	,oDescPagto	,@nNumParcelas	,oNumParcelas	,;
																						@nVlrPrazo	,oVlrPrazo	,@nVlJur		,@cCodAnt		,;
																						@lTipo9		,nValNFat	,oValNFat		,.T.			,;
																						oFis		,@nSuframa	,oSuframa		,@nTotal		,;
																						oTotal		,@lTLVReg1  ,@lTLVReg2		,.F. 			,;
																						.T.			,@lChangeSE4),;
							oParcelas:Enable(),.T.)})
		oCodPagto:cSX1Hlp := "UA_CONDPG"
		
		@ 011,070 SAY oDescPagto VAR cDescPagto Picture "@!" SIZE 50,8 OF oFolderPagto PIXEL COLOR CLR_BLUE
	  
		@ 021,004 SAY STR0053  OF oFolderPagto PIXEL  //"Valor Nao Faturado"
		@ 021,040 MSGET oValNFat VAR nValNFat Picture "@E 999,999,999.99" SIZE 55,8  OF oFolderPagto PIXEL When .F.
		
		@ 031,004 SAY STR0004 OF oFolderPagto PIXEL //"L¡quido" 
		@ 031,040 MSGET oLiquido VAR nLiquido Picture "@E 999,999,999.99" SIZE 55,8 OF oFolderPagto PIXEL When .F.
		
		@ 041,004 SAY STR0005 OF oFolderPagto PIXEL //"Entrada" 
		@ 041,040 MSGET oEntrada VAR nEntrada Picture "@E 999,999,999.99" SIZE 55,8  OF oFolderPagto PIXEL When .F.
		
		@ 051,004 SAY STR0006 OF oFolderPagto PIXEL //"Juros" 
		@ 051,040 MSGET oTxJuros VAR nTxJuros  Picture "@E 999.99" SIZE 15,8 OF oFolderPagto PIXEL When .F.
		
		@ 051,073 SAY STR0007 OF oFolderPagto PIXEL //"Parcelas"
		@ 051,095 MSGET oNumParcelas VAR nNumParcelas Picture "99"  SIZE 17,8  OF oFolderPagto PIXEL When .F.
		
		@ 061,004 SAY STR0008 OF oFolderPagto PIXEL //"Financiado" 
		@ 061,040 MSGET oFinanciado VAR nFinanciado Picture "@E 999,999,999.99" SIZE 55,8  OF oFolderPagto PIXEL When .F.
		
		@ 071,004 SAY STR0062 OF oFolderPagto PIXEL // "Total Fat."
		@ 071,040 MSGET oVlrPrazo VAR nVlrPrazo Picture "@E 999,999,999.99"  SIZE 55,8  OF oFolderPagto PIXEL When .F.
		
		@ 081,004 SAY STR0063 OF oFolderPagto PIXEL // "Total Ped."
		@ 081,040 MSGET oTotal VAR nTotal Picture "@E 999,999,999.99"  SIZE 55,8  OF oFolderPagto PIXEL When .F.
		
		@ 091,004 SAY STR0064 OF oFolderPagto PIXEL // "Suframa"
		@ 091,040 MSGET oSuframa VAR nSuframa Picture "@E 999,999,999.99" SIZE 55,8  OF oFolderPagto PIXEL When .F.		
		
		@ 101,004 SAY STR0010 OF oFolderPagto PIXEL //"Desconto" 
		@ 101,040 MSGET oTxDescon VAR nTxDescon Picture "@E 999.99" SIZE 20,8  OF oFolderPagto PIXEL When .F.
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Listbox com as parcelas de pagamento conforme a condicao escolhida  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@09,125 BROWSE oParcelas SIZE 180,102 OF oFolderPagto PIXEL ;
				ON DbLCLICK Tk273Detalhe(	@aParcelas	,oParcelas	,@aItens	,lHabilita,;
											nLiquido	,@nEntrada	,oEntrada	,@nFinanciado,;
											oFinanciado	,cCodPagto	,lSigaCRD   ,@lTLVReg2 ) 
		
		// Visualizacao das parcelas 
		oParcelas:SetArray( aParcelas )                                
		ADD COLUMN TO oParcelas HEADER STR0011 OEM DATA {|| DTOC(aParcelas[oParcelas:nAt,1]) }  					  	ALIGN LEFT SIZE 40 PIXEL //"Data" 
		ADD COLUMN TO oParcelas HEADER STR0012 OEM DATA {|| Transform(aParcelas[oParcelas:nAt,2],"@E 999,999,999.99")}  ALIGN LEFT SIZE 55 PIXEL //"Valor"
		ADD COLUMN TO oParcelas HEADER STR0013 OEM DATA {|| aParcelas[oParcelas:nAt,3] } 								ALIGN LEFT SIZE 40 PIXEL //"Forma" 
		oParcelas:oCursor := oCurTmk
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Browse com as parcelas de pagamento (Sintetizada) conforme a condicao escolhida ³
		//³Esta forma de visualizacao sera usada somente quando for TEF com ClisiTef       ³		
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	lVisuSint 	.AND.;
		 	lUsaTef 	.AND.;
		 	cTipTef == TEF_CLISITEF
		 	
			@09,115 BROWSE oPgtosSint SIZE 190,82 OF oFolderPagto PIXEL ;
					ON DbLCLICK Tk273DetSint(	@aParcelas	,oParcelas	,@aItens	,lHabilita,;
												nLiquido	,@nEntrada	,oEntrada	,@nFinanciado,;
												oFinanciado	,cCodPagto	,lSigaCRD	,oDlgPagto) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Estrutura do array aPgtosSint                                ³
			//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
			//³ [1] - Forma de Pagamento                                     ³
			//³ [2] - Qtde de Parcelas da forma de pagto                     ³
			//³ [3] - Valor total desta forma de pagamento                   ³
			//| [4] - Sequencia para controle de múltiplas transaçõies		 |
			//³ [5] - Data da primeira parcela                               ³	
			//³ [6] - Codigo da Administradora financeira                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			oPgtosSint:SetArray( aPgtosSint )                                
			ADD COLUMN TO oPgtosSint HEADER STR0038	OEM DATA { || aPgtosSint[oPgtosSint:nAt,5] } ALIGN LEFT  SIZE 40 PIXEL 	//"Data"
			ADD COLUMN TO oPgtosSint HEADER STR0039	OEM DATA { || aPgtosSint[oPgtosSint:nAt,1] } ALIGN LEFT  SIZE 40 PIXEL 	//"Forma Pgto"
			ADD COLUMN TO oPgtosSint HEADER STR0040	OEM DATA { || aPgtosSint[oPgtosSint:nAt,3] } ALIGN LEFT  SIZE 55 PIXEL  //"Valor"
			ADD COLUMN TO oPgtosSint HEADER STR0041	OEM DATA { || aPgtosSint[oPgtosSint:nAt,2] } ALIGN LEFT  SIZE 30 PIXEL 	//"Parcelas"

			//So inserir a coluna ID Cartao quando o cliente trabalhar com multiplas transacoes TEF
			If lUsaTef .AND. lTefMult
				ADD COLUMN TO oPgtosSint HEADER STR0042		OEM DATA { || aPgtosSint[oPgtosSint:nAt,4] } ALIGN LEFT  SIZE 30 PIXEL  //"ID Cartao"
			Endif 
			
			oPgtosSint:oCursor := oCurTmk
		Endif
			
		oEntrada:Refresh()
		oLiquido:Refresh()
		oFinanciado:Refresh()
		
		@ 120,002 TO 205,310 LABEL STR0014 OF oFolderPagto  PIXEL 	// "Dados Complementares" 
		
		@ 131,004 SAY STR0015 OF oFolderPagto PIXEL 				// "Transportadora" 
		@ 131,045 MSGET oCodTransp VAR cCodTransp Picture cPicttrans F3 X3F3("UA_TRANSP") SIZE 40,8 OF oFolderPagto PIXEL ;
					Valid Tk273AtuTransp(cCodTransp,@cTransp,oTransp) When IIF(lTMKCPG, lHabilAux, aInfoSx3[aScan(aInfoSx3,  {|x| x[1] == "UA_TRANSP"}),2])
		oCodTransp:cSX1Hlp := "UA_TRANSP"
		
		@ 130,090 SAY oTransp VAR cTransp Picture "@!" SIZE 150,16 OF oFolderPagto PIXEL COLOR CLR_BLUE
		
		@ 146,004 SAY STR0016 OF oFolderPagto PIXEL  //"Cobranca"
		lObfEndCob := FATPDIsObfuscate("UA_ENDCOB")
		@ 146,045 MSGET oCob VAR cCob  Picture "@!" SIZE 115,8  OF oFolderPagto PIXEL; 
		When ( IIF(lTMKCPG, lHabilAux, aInfoSx3[aScan(aInfoSx3,  {|x| x[1] == "UA_ENDCOB"}),2]) .And. !lObfEndCob )
		If FATPDActive() .And. FTPDUse(.T.)
			oCob:lObfuscate := lObfEndCob
		Endif
		oCob:cSX1Hlp := "UA_ENDCOB" 
		
		@ 146,180 SAY STR0017 OF oFolderPagto PIXEL //"Bairro"
		lObfBairrC := FATPDIsObfuscate("UA_BAIRROC")
		@ 146,205 MSGET oBairroC VAR cBairroC Picture "@!" SIZE 80,8 OF oFolderPagto PIXEL ; 
		When ( IIF(lTMKCPG, lHabilAux, aInfoSx3[aScan(aInfoSx3,  {|x| x[1] == "UA_BAIRROC"}),2]) .And. !lObfBairrC )
		If FATPDActive() .And. FTPDUse(.T.)
			oBairroC:lObfuscate := lObfBairrC
		Endif
		oBairroC:cSX1Hlp := "UA_BAIRROC"
			
		@ 161,004 SAY STR0018 OF oFolderPagto PIXEL //"Cidade"
		lObfMunC := FATPDIsObfuscate("UA_MUNC")
		@ 161,045 MSGET oCidadeC VAR cCidadeC Picture "@!" SIZE 80,8 OF oFolderPagto PIXEL ;
					Valid Tk273CidC(@oCidadeC,@cCidadeC); 
					When ( IIF(lTMKCPG, lHabilAux, aInfoSx3[aScan(aInfoSx3,  {|x| x[1] == "UA_MUNC"}),2]) .And. !lObfMunC )
		oCidadeC:cSX1Hlp := "UA_MUNC"
		If FATPDActive() .And. FTPDUse(.T.)
			oCidadeC:lObfuscate := lObfMunC
		Endif

		@ 161,150 SAY STR0019 OF oFolderPagto PIXEL //"CEP"
		lObfCepC := FATPDIsObfuscate("UA_CEPC")
		@ 161,170 MSGET oCepC VAR cCepC Picture "@R 99999-999" SIZE 40,8 OF oFolderPagto PIXEL Valid ;
					Tk273CepC(	@cCepC	,@oCepC	,@cCidadeC	,@oCidadeC,;
								@cUfC	,@oUfC	,@cBairroC	,@oBairroC);
					When ( IIF(lTMKCPG, lHabilAux, aInfoSx3[aScan(aInfoSx3,  {|x| x[1] == "UA_CEPC"}),2]) .And. !lObfCepC )
		oCepC:cSX1Hlp := "UA_CEPC"
		If FATPDActive() .And. FTPDUse(.T.)
			oCepC:lObfuscate := lObfCepC
		Endif

		@ 161,225 SAY STR0020 SIZE 25,8 OF oFolderPagto PIXEL  //"Estado" 
		lObfEstC:= FATPDIsObfuscate("UA_ESTC")
		@ 161,250 MSGET oUfC VAR cUfC Picture "@!" F3 "12" SIZE 35,8 OF oFolderPagto;
		PIXEL Valid Tk273Estado(cUfc) When ( IIF(lTMKCPG, lHabilAux, aInfoSx3[aScan(aInfoSx3,  {|x| x[1] == "UA_ESTC"}),2]) .And. !lObfEstC )
		oUfC:cSX1Hlp := "UA_ESTC"
		If FATPDActive() .And. FTPDUse(.T.)
			oUfC:lObfuscate := lObfEstC
		Endif

		@ 176,004 SAY STR0021 OF oFolderPagto PIXEL  //"Entrega"
		lObfEndEnt := FATPDIsObfuscate("UA_ENDENT") 
		@ 176,045 MSGET oEnt VAR cEnt Picture "@!" SIZE 115,8 OF oFolderPagto PIXEL ;
		When ( IIF(lTMKCPG, lHabilAux, aInfoSx3[aScan(aInfoSx3,  {|x| x[1] == "UA_ENDENT"}),2]) .And. !lObfEndEnt )
		oEnt:cSX1Hlp := "UA_ENDENT"
		If FATPDActive() .And. FTPDUse(.T.)
			oEnt:lObfuscate := lObfEndEnt
		Endif
		
		@ 176,180 SAY STR0017 OF oFolderPagto PIXEL  //"Bairro"
		lObfBairrE := FATPDIsObfuscate("UA_BAIRROE") 
		@ 176,205 MSGET oBairroE VAR cBairroE Picture "@!" SIZE 80,8 OF oFolderPagto PIXEL ;
		When ( IIF(lTMKCPG, lHabilAux, aInfoSx3[aScan(aInfoSx3,  {|x| x[1] == "UA_BAIRROE"}),2]) .And. !lObfBairrE )
		oBairroE:cSX1Hlp := "UA_BAIRROE"
		If FATPDActive() .And. FTPDUse(.T.)
			oBairroE:lObfuscate := lObfBairrE
		Endif

		@ 191,004 SAY STR0018 OF oFolderPagto PIXEL  //"Cidade"
		lObfMunE := FATPDIsObfuscate("UA_MUNE") 
		@ 191,045 MSGET oCidadeE VAR cCidadeE Picture "@!"  SIZE 80,8 OF oFolderPagto PIXEL Valid ;
					Tk273CidE(@oCidadeE,@cCidadeE) ;
					 When ( IIF(lTMKCPG, lHabilAux, aInfoSx3[aScan(aInfoSx3,  {|x| x[1] == "UA_MUNE"}),2]) .And. !lObfMunE )
		oCidadeE:cSX1Hlp := "UA_MUNE"
		If FATPDActive() .And. FTPDUse(.T.)
			oCidadeE:lObfuscate := lObfMunE
		Endif
		
		@ 191,150 SAY STR0019 OF oFolderPagto PIXEL //"CEP" 
		lObfCepE := FATPDIsObfuscate("UA_CEPE") 
		@ 191,170 MSGET oCepE VAR cCepE  Picture "@R 99999-999"	SIZE 40,8 OF oFolderPagto PIXEL Valid ;
					Tk273CepE(	@cCepE	,@oCepE	,@cCidadeE	,@oCidadeE,;
								@cUfE	,@oUfE	,@cBairroE	,@oBairroE);
					When ( IIF(lTMKCPG, lHabilAux, aInfoSx3[aScan(aInfoSx3,  {|x| x[1] == "UA_CEPE"}),2]) .And. !lObfCepE )
		oCepE:cSX1Hlp := "UA_CEPE" 
		If FATPDActive() .And. FTPDUse(.T.)
			oCepE:lObfuscate := lObfCepE
		Endif

		@ 191,225 SAY STR0020 SIZE 25,8 OF oFolderPagto PIXEL //"Estado"
		lObfEstE := FATPDIsObfuscate("UA_ESTE") 
		@ 191,250 MSGET oUfE VAR cUfE Picture "@!" F3 "12"  SIZE 35,8 OF oFolderPagto PIXEL ;
		Valid Tk273Estado(cUfe) When ( IIF(lTMKCPG, lHabilAux, aInfoSx3[aScan(aInfoSx3,  {|x| x[1] == "UA_ESTE"}),2]) .And. !lObfEstE )
		If FATPDActive() .And. FTPDUse(.T.)
			oUfE:lObfuscate := lObfEstE
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for VISUALIZACAO nao precisa habilitar o botao de OK - nao havera novas manutencoes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lHabilita
			DEFINE SBUTTON FROM 207,240 TYPE 1;
				 ACTION (nOpcA := 1,lRet := IIF(	Tk273ParcelaOk(	aParcelas	,nEntrada	,nFinanciado	,nValNFat	,;
																	cTipoOper	,cCodPagto	,cCodTransp		,cCob		,;
																	cEnt		,cCidadeC	,cCepC			,cBairroC	,;
																	cBairroE	,cCidadeE	,cCepE			,cUfE 		,;
																	@cTransp	,oTransp) .AND.;
													MaVldTabPrc( M->UA_TABELA, cCodPagto ),;
												oDlgPagto:End(),;																			
												""));
												ENABLE OF oFolderPagto
	    Endif
	    
		DEFINE SBUTTON FROM 207,280 TYPE 2 ACTION (lRet := .F.,oDlgPagto:End()) ENABLE OF oFolderPagto
	
		// Desabilita a tecla ESC
	    oDlgPagto:LESCCLOSE := .F.       
	    
	ACTIVATE MSDIALOG oDlgPagto CENTERED ON INIT MsgRun(STR0059,"",{||	(Tk273InitPagto(	cNumTlv		,cCliente	,cLoja		,nOpc,;
																	   						@cCodPagto	,oCodPagto	,@cDescPagto,oDescPagto,;
																							@cCodTransp	,oCodTransp	,@cTransp	,oTransp,;
																							@cCob		,oCob		,@cEnt		,oEnt,;
																							@cCidadeC	,oCidadeC	,@cCepC		,oCepC,;
																							@cUfC		,oUfC		,@cBairroE	,oBairroE,;
																							@cBairroC	,oBairroC	,@cCidadeE	,oCidadeE,;
																							@cCepE		,oCepE		,@cUfE		,oUfE,;
																							@cCliAnt   ),;
																  		IIF(!Tk273CompVal(	@aParcelas	, nLiquido	, nVlJur	, cCodPagto	,;
																  							cCodAnt		),;
																		Tk273MontaParcela(	nOpc		,cNumTlv		,@nLiquido		,oLiquido		,;
																		 					@nTxJuros	,oTxJuros		,@nTxDescon		,oTxDescon		,;
											 												@aParcelas	,oParcelas		,@cCodPagto		,oCodPagto		,;
																			 				@nEntrada	,oEntrada		,@nFinanciado	,oFinanciado	,;
																							@cDescPagto	,oDescPagto		,@nNumParcelas	,oNumParcelas	,;
																							@nVlrPrazo	,oVlrPrazo		,@nVlJur		,@cCodAnt		,;
																							@lTipo9		,nValNFat		,oValNFat		,.F.			,;
																							oFis		,@nSuframa		,oSuframa		,@nTotal		,;
																							oTotal		,@lTLVReg1      ,@lTLVReg2		,.T.  		    ,;
																							.T. 		,@lChangeSE4),;
																		( nVlrPrazo := nEntrada + nFinanciado, If(!lTk271Auto,oVlrPrazo:Refresh(),) ) ),;
																		IIF(lTMKCND,;
																			U_TMKCND(	cNumTlv		,cCliente		,cLoja			,cCodCont,;
																						cCodOper	,@aParcelas		,@cCodPagto		,oCodPagto,;
																						@cDescPagto	,@oDescPagto 	,@lHabilAux		,@cCodTransp) ,"") )})
    FATPDUnload() 
	FATPDLogUser("TK273PAGAM") 
Endif														

//Confirmou a condicao atualiza o rodape, caso haja acrescimo na condicao
If nOpcA == 1 
	aParcTef	:= AClone(aParcelas)	
	M->UA_CONDPG:= cCodPagto
	M->UA_TRANSP:= cCodTransp
	lRecalc := .T.
ElseIf nOpcA == 0
	//Caso o usuário cancele a janela do pagamento, retorna os dados complementares anteriores.
	cCodTransp 	:= aDadosCompl[1]
	cTransp 	:= aDadosCompl[2]
	cCob 		:= aDadosCompl[3]
	cEnt 		:= aDadosCompl[4]
	cCidadeC 	:= aDadosCompl[5]
	cCepC 		:= aDadosCompl[6]
	cUfC 		:= aDadosCompl[7]
	cBairroE 	:= aDadosCompl[8]
	cBairroC 	:= aDadosCompl[9]
	cCidadeE 	:= aDadosCompl[10]
	cCepE 		:= aDadosCompl[11]
	cUfE 		:= aDadosCompl[12] 
	cCliAnt     := aDadosCompl[13]
	If M->UA_CONDPG <> cCodPagto
		Tk273CompVal( @aParcelas, nLiquido, nVlJur, M->UA_CONDPG, cCodAnt )
		Tk273MontaParcela( nOpc, cNumTlv, @nLiquido ,, @nTxJuros, , @nTxDescon,,;
			@aParcelas,, M->UA_CONDPG,, @nEntrada,, @nFinanciado,,;
			@cDescPagto,, @nNumParcelas,, @nVlrPrazo,, @nVlJur, @cCodAnt,;
			@lTipo9, nValNFat,, .F., oFis, @nSuframa,, @nTotal,, @lTLVReg1, @lTLVReg2, .F. , .F., @lChangeSE4,.T.)		
	Endif
	lRecalc := .F.
Endif

lTLVReg := (lTLVReg1 .Or. lTLVReg2 ) //retorno das validacoes da regra de negocios

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para uso em Templates									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTMKVCPT
	If T_TMKVCP(@cCodTransp	,@oCodTransp	,@cTransp	,@oTransp,;
				@cCob		,@oCob			,@cEnt		,@oEnt,;
				@cCidadeC	,@oCidadeC		,@cCepC		,@oCepC,;
				@cUfC		,@oUfC			,@cBairroE	,@oBairroE,;
				@cBairroC	,@oBairroC		,@cCidadeE	,@oCidadeE,;
				@cCepE		,@oCepE			,@cUfE		,@oUfE,;
				nOpc		,cNumTlv		,cCliente	,cLoja,;
				cCodPagto	,aParcelas)
		lRet := .T.		
	 	Return(lRet)
	Else
		Return(lRet)	
	Endif	
Endif
If lTMKVCP
	If U_TMKVCP(@cCodTransp	,@oCodTransp	,@cTransp	,@oTransp,;
				@cCob		,@oCob			,@cEnt		,@oEnt,;
				@cCidadeC	,@oCidadeC		,@cCepC		,@oCepC,;
				@cUfC		,@oUfC			,@cBairroE	,@oBairroE,;
				@cBairroC	,@oBairroC		,@cCidadeE	,@oCidadeE,;
				@cCepE		,@oCepE			,@cUfE		,@oUfE,;
				nOpc		,cNumTlv		,cCliente	,cLoja,;
				cCodPagto	,aParcelas)
		lRet := .T.		
	 	Return(lRet)
	Else
		Return(lRet)	
	Endif	
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271InitPagto ³ Autor ³ Vendas Clientes  ³ Data ³27/12/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza os dados da condicao de pagamento no INIT da tela  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273InitPagto( cNumTlv,   cCliente,	cLoja,		nOpc,;
						cCodPagto,	oCodPagto,	cDescPagto,	oDescPagto,;
						cCodTransp,	oCodTransp,	cTransp,	oTransp,;
						cCob,		oCob,		cEnt,		oEnt,;
						cCidadeC,	oCidadeC,	cCepC,		oCepC,;
						cUfC,		oUfC,		cBairroE,	oBairroE,;
						cBairroC,	oBairroC,	cCidadeE,	oCidadeE,;
						cCepE,		oCepE,		cUfE,		oUfE,;
						cCliAnt )
								
Local cCondPad 	:= ""													// Condicao de Pagamento Padrao
Local cParCond	:= SuperGetMv("MV_CONDPAD")								// Conteudo do parametro MV_CONDPAD

				
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicoes do array aRetTrans ³
//³1- Codigo da Transportadora ³
//³2- Codigo da Cond. Pagto	   ³
//³3- Endereco  			   ³
//³4- Bairro    			   ³
//³6- Cep    				   ³
//³7- Uf    				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(M->UA_CONDPG)
	If nOpc == 4 .And. !Empty(SUA->UA_CONDPG)
		cCondPad := SUA->UA_CONDPG
	Else
		cCondPad := cParCond + Space(3-Len(cParCond))
	EndIf
Else
	cCondPad := M->UA_CONDPG
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o campo UA_TRANSP é visualizável.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(2)

If ( DbSeek( "UA_TRANSP" ) ) .AND. SX3->X3_BROWSE == "S"
	If (cCodTransp <> M->UA_TRANSP)
		cCodTransp := M->UA_TRANSP
		Tk273AtuTransp(cCodTransp,@cTransp,oTransp)
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o atendente ainda nao escolheu uma condicao de pagamento pega a condicao do SA1³
//³ou se o operador alterou o CLIENTE/PROSPECT no atendimento atualiza os enderecos  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cCodPagto) .OR. (cCliAnt <> cCliente+cLoja)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o codigo do cliente antigo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCliAnt := cCliente+cLoja	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura pelos campos de endereco (entrega e cobranca) somente para CLIENTES   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lProspect
		DbSelectArea("SA1")
		DbSetOrder(1)
		If DbSeek(xFilial("SA1")+cCliente+cLoja)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Dados para entrega³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim(Upper(SA1->A1_ENDENT)) == "O MESMO"
				cEnt    :=SA1->A1_END
				cCidadeE:=SA1->A1_MUN
				cCepE   :=SA1->A1_CEP
				cUfE    :=SA1->A1_EST
				cBairroE:=SA1->A1_BAIRRO
			Else
				cEnt    :=SA1->A1_ENDENT
				cCidadeE:=SA1->A1_MUNE
				cCepe   :=SA1->A1_CEPE
				cUfe    :=SA1->A1_ESTE   
				cBairroE:=SA1->A1_BAIRROE
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Dados de cobranca³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim(UPPER(SA1->A1_ENDCOB)) = "O MESMO"
				cCob    :=SA1->A1_END
				cCidadeC:=SA1->A1_MUN
				cCepC   :=SA1->A1_CEP
				cUfC    :=SA1->A1_EST
				cBairroc:=SA1->A1_BAIRRO
			Else
				cCob    :=SA1->A1_ENDCOB
				cCidadeC:=SA1->A1_MUNC
				cCepC   :=SA1->A1_CEPC
				cUfC    :=SA1->A1_ESTC
				cBairroC:=SA1->A1_BAIRROC
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Condicao de pagamento utilizada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(M->UA_CONDPG)
				cCondPad := M->UA_CONDPG
			ElseIf nOpc == 4 .And. !Empty(SUA->UA_CONDPG)
				cCondPad := SUA->UA_CONDPG
			ElseIf !Empty(SA1->A1_COND)
				cCondPad := SA1->A1_COND
			EndIf
			cCodPagto  := cCondPad
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³So pega a transportadora do cliente, se nenhuma   ³
			//³transportadora for selecionada antes.             ³
			//³(So funciona quando o campo UA_TRANSP estiver como³
			//³"Usado") e tambem ja faz a gravacao na memoria    ³
			//³para evitar que se pressionado cancelar nao grave ³			
			//³essa informacao, ja que o cliente podera nao ser  ³			
			//³alterado deixando o campo UA_TRANSP em branco.    ³						
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cCodTransp)
                cCodTransp := M->UA_TRANSP := SA1->A1_TRANSP
            EndIf    

		Endif
	Else                       
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O cadastro de Prospect nao tem condicao de pagamento Default por isso assume o parametro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodPagto := cCondPad
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega o nome da condição de pagamento.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDescPagto := ""
	DbSelectArea("SE4")
	DbSetOrder(1)
	If DbSeek(xFilial("SE4")+cCondPad)
		cDescPagto:= SE4->E4_DESCRI
	Else
		DbSeek(xFilial("SE4"))
		cCondPad 	:= SE4->E4_CODIGO
		cCodPagto	:= SE4->E4_CODIGO
		cDescPagto	:= SE4->E4_DESCRI
	Endif

Else
	
	If (nOpc == 4) .OR. (nOpc == 2) // Alterar ou Visualizar
		DbSelectArea("SUA")
		DbSetOrder(1)
		If DbSeek(xFilial("SUA")+cNumTlv)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ uma altera‡„o: A condi‡„o pode ou n„o ter sido informada anteriormente verifico isso pelo UA_COND   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SUA->UA_CONDPG)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se as variaveis estiverem vazias o Operador nao alterou o conteudo da forma de pagamento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				If Empty(cCodPagto) .AND. Empty(cDescPagto)

					nEntrada   := SUA->UA_ENTRADA
					nTxJuros   := SUA->UA_JUROS    	// percentual de juros
					nVlJur	   := SUA->UA_ACRECND  	// valor do juros
					nTxDescon  := SUA->UA_TXDESC	// percentual de desconto
					nParcelas  := SUA->UA_PARCELA
					nFinanciado:= SUA->UA_FINANC

					DbSelectArea("SE4")
					DbSetOrder(1)
					If DbSeek(xFilial("SE4")+SUA->UA_CONDPG)
						cCodPagto := SE4->E4_CODIGO
						cDescPagto:= SE4->E4_DESCRI
					Endif
				
					If Empty(cCodTransp) .OR. Empty(cTransp)					
						DbSelectArea("SA4")
						DbSetOrder(1)
						If DbSeek(xFilial("SA4")+SUA->UA_TRANSP)
							cCodTransp 	:= SUA->UA_TRANSP
							cTransp		:= SA4->A4_COD+"-"+SA4->A4_NOME
						Endif
					Endif
					
					cCob    :=SUA->UA_ENDCOB
					cEnt    :=SUA->UA_ENDENT
					cCidadeC:=SUA->UA_MUNC
					cCepC   :=SUA->UA_CEPC
					cUfC    :=SUA->UA_ESTC
					cBairroC:=SUA->UA_BAIRROC
					
					cCidadeE:=SUA->UA_MUNE
					cCepE   :=SUA->UA_CEPE
					cUfE    :=SUA->UA_ESTE
					cBairroE:=SUA->UA_BAIRROE
				Endif
			Else	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³O cadastro de Prospect nao tem condicao de pagamento Defatult por isso assume o parametro ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCodPagto := cCondPad
			Endif
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Permite que o usuario altere dados de transporte, entrega e ³
//³condicao de pagamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tk273Trans(	@cCodTransp	, @cTransp		, @cCodPagto, @cDescPagto	,;
			@cEnt		, @cBairroE		, @cCidadeE	, @cCepE		,;
			@cUfE		)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao estiver usando a entrada automatica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTk271Auto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza os objetos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDescPagto:Refresh()
	oCodPagto:Refresh()
	oCodTransp:Refresh()
	oTransp:Refresh()
	oEnt:Refresh()
	oCidadeE:Refresh()
	oCepE:Refresh()
	oUfE:Refresh()
	oBairroE:Refresh()
	oCob:Refresh()
	oCidadeC:Refresh()
	oCepC:Refresh()
	oUfC:Refresh()
	oBairroc:Refresh()
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271MontaParcela³ Autor ³ Vendas Clientes³ Data ³ 17/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Array com Parcelas de acordo com a condicao de        ³±±
±±³          ³pagamento escolhida com data,valor e forma de pagamento     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk273MontaParcela(ExpN1,	ExpC2,	ExpN3,	ExpO4,            ³±±
±±³          ³                   ExpN5, ExpO6,  ExpC7,  ExpO8             ³±±
±±³          ³                   ExpA9, ExpO10, ExpC11, ExpO12,           ³±±
±±³          ³                   ExpN13,ExpO14, ExpN15, ExpO16,           ³±±
±±³          ³                   ExpC17,ExpO18, ExpN19, ExpO20,           ³±±
±±³          ³                   ExpN21,ExpO22, ExpN23, ExpC24,           ³±±
±±³          ³                   ExpL25,ExpN26, ExpO27, ExpL28            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = opcao selecionada pelo usuario                	  ³±±
±±³          ³ ExpC2 = numero do atendimento                              ³±±
±±³          ³ ExpN3 = valor liquido                                      ³±±
±±³          ³ ExpO4 = objeto msget para valor liquido                 	  ³±±
±±³          ³ ExpN5 = valor da taxa de juros                             ³±±
±±³          ³ ExpO6 = objeto msget valor da taxa de juros                ³±±
±±³          ³ ExpC7 = taxa de desconto                                   ³±±
±±³          ³ ExpO8 = objeto msget taxa de desconto                      ³±±
±±³          ³ ExpA9 = array de parcelas                                  ³±±
±±³          ³ ExpO10= objeto browse de parcelas                          ³±±
±±³          ³ ExpC11= cod. condicao de pagamento                         ³±±
±±³          ³ ExpO12= objeto msget para condicao de pagamento            ³±±
±±³          ³ ExpN13= valor da entrada                                   ³±±
±±³          ³ ExpO14= objeto msget com valor de entrada                  ³±±
±±³          ³ ExpN15= valor financiado                                   ³±±
±±³          ³ ExpO16= objeto msget com valor financiado                  ³±±
±±³          ³ ExpC17= valor do desconto                                  ³±±
±±³          ³ ExpO18= objeto msget do valor do desconto                  ³±±
±±³          ³ ExpN19= quantidade de parcelas                             ³±±
±±³          ³ ExpO20= objeto msget com quantidade de parcelas            ³±±
±±³          ³ ExpN21= prazo                                              ³±±
±±³          ³ ExpO22= objeto msget prazo                                 ³±±
±±³          ³ ExpN23= valor do juros                                     ³±±
±±³          ³ ExpC24= controla alteracoes enquanto nao esta salvo        ³±±
±±³          ³ ExpL25= flag para condicao de pagto do tipo 9.             ³±±
±±³          ³ ExpN26= valor nao faturado                                 ³±±
±±³          ³ ExpO27= objeto msget do valor nao faturado                 ³±±
±±³          ³ ExpL34= controle de verificacao da regra de negocio        ³±±
±±³          ³ ExpL35= controle de verificacao da regra de negocios       ³±±
±±³          ³ ExpL36= contrele de chamada na carga inical ou alteração	  ³±±
±±³          ³ ExpL37= Atualiza objetos na tela de Forma de Pagamento.	  ³±±
±±³          ³ ExpL38= controle de verificacao se Condicao foi alterada.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273MontaParcela(	nOpc		,cNumTlv	,nLiquido		,oLiquido		,;
							nTxJuros	,oTxJuros	,nTxDescon		,oTxDescon		,;
							aParcelas	,oParcelas	,cCodPagto		,oCodPagto		,;
							nEntrada	,oEntrada	,nFinanciado	,oFinanciado	,;
							cDescPagto	,oDescPagto	,nNumParcelas	,oNumParcelas	,;
							nVlrPrazo	,oVlrPrazo	,nVlJur			,cCodAnt		,;
							lTipo9		,nValNFat	,oValNFat		,lEntrada		,;
							oFis		,nSuframa	,oSuframa		,nTotal			,;
							oTotal		,lTLVReg1   ,lTLVReg2		,lInit			,;
							lRefresh	,lChangeSE4	,lCancPagto)

Local cForma1 		:= SPACE(2)													// Variavel auxiliar da forma 
Local cForma2 		:= SPACE(2)             									// Variavel auxiliar da forma 
Local nParcelas		:= 0														// Numero de parcelas
Local nTotalParcela	:= 0														// Total das parcelas
Local nCont			:= 0														// Contador	
Local nResto 		:= 0														// diferenca da parcela (entrada) e do valor total 
Local nTotParc      := 0														// variavel auxiliar 
Local aVazio 		:= {}														// Array vazio
Local aAux 			:= {}														// Array auxiliar
Local dDataPar		:= CTOD("  /  /  ")											// Data da 1 parcela
Local dDataCond		:= dDataBase												// Data para desdobramento
Local lCalcula		:= .F.														// Flag para controle do recalculo das parcelas
Local nContx        := 0 														// Contador auxiliar
Local aTipo9		:= {}														// Se a condicao for do tipo 9 alimenta o array com as parcelas
Local lTMKVLDE4  	:= ExistBlock("TMKVLDE4")									// Flag para validar a existencia do Rdmake de P.E. TMKVLDE4 
Local lRet 			:= .F.														// Retorno da funcao
Local cOperAnt		:= CRIAVAR("UA_OPER",.F.)									// Variavel com a OPERACAO original do atendimento em caso de alteracao.		
Local dCalculo		:= M->UA_EMISSAO											// Data que sera usada no calculo da condicao de pagamento. Alteracao de uma operacao de FATURAMENTO = M->UA_EMISSAO, Orcamento = dDataBase
Local aProdDesc		:= {}														// Array com os produtos e seus descontos. Utilizado na verificação da regra de negócio
Local cMensagem		:= ""														// String utilizado em exibição de mensagens dinâmicas.
Local cForma3		:= "CH"														// Forma de pagamento padrão, quando essa não é informada
Local cTipo9		:= Posicione("SE4",1,xFilial("SE4")+cCodPagto,"E4_TIPO")	// Retorna o tipo da condição de pagamento
Local lPedidoBloq	:= .F.														// Se a regra de negócio bloqueará o pedido
Local nPProd		:= aPosicoes[1][2]											// Recebe a posição do campo UB_PRODUTO
Local nPItem		:= aPosicoes[20][2]											// Recebe a posição do campo UB_ITEM
Local nPPrven		:= aPosicoes[5][2]											// Recebe a posição do campo UB_VRUNIT
Local nPPrlis		:= aPosicoes[15][2]											// Recebe a posição do campo UB_PRCTAB
Local nPDesc		:= aPosicoes[9][2]											// Recebe a posição do campo UB_DESC
Local lMV_TMKFIS	:= IIf(lTk271Auto, .T., GetNewPar("MV_TMKFIS",.T.))								// (Não divulgar) Parametro que indica que a atualização da MATXFIS é feita de maneira on-line, no off-line a MATXFIS só é atualizada quando se entra na condição de pagamento.
Local lRecParc		:= .F.														//  Define necessidade de recalcular parcelas 
Local nDescon		:= 0
Local lLimpa		:= .F.
Local nPorcParc		:= 0
Local cFilSL4		:= xFilial("SL4")
Local aParcAux		:= {}

Default lEntrada := .F.
Default lTLVReg1 := .F. 														// controle de validacao da regra de negocios 
Default lTLVReg2 := .F. 														// controle de validacao da regra de negocios 
Default lInit	 := .F.
Default lRefresh := .F.
Default lChangeSE4 := .F.
Default lCancPagto := .F.

If cTipo9 <> "9" .And. cCodAnt <> cCodPagto
	lEntrada := .F.
	aParcelas := {}
ElseIf cTipo9 == "9" 
	If cCodAnt == cCodPagto
		lTipo9 := .T.
		If !Empty(aParcelas)
			lCancPagto := .T.
		EndIf
	Else
		aParcelas := {}
	EndIf
EndIf

If lTipo9
	aTipo9 := aClone(aParcelas)
EndIf

If lTMKVLDE4
	lRet := U_TMKVLDE4(nOpc,cCodPagto,oCodPagto)
	If (ValType(lRet) <> "L")
		Return(.F.)
	ElseIf !lRet
		Return(.F.)
	Endif 
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Flag para controlar se as alteracoes do usuario enquanto o atendimento ³
//³nao foi gravado e o conteudo permanece nas variaveis de memoria	      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If cCodAnt <> cCodPagto
	cCodAnt   := cCodPagto
	lCalcula  := .T.
	lTLVReg1  := .F.
	lTLVReg2  := .F.	
	DbSelectArea("SL4")
	DbSetOrder(1)
	// Valido a existencia das parcelas gravadas no SL4. Se nao existir, monta as parcelas novamente. 
	If nOpc <> 4 .And. DbSeek(cFilSL4+cNumTlv+"SIGATMK ")
		While (!SL4->(Eof())) .AND. (cFilSL4 == SL4->L4_FILIAL) .AND. ;
								(SL4->L4_NUM == cNumTlv) 			.AND. ;
								(AllTrim(SL4->L4_ORIGEM) == "SIGATMK")

			SL4->( RecLock("SL4", .F.) )
			SL4->( DbDelete() )
			SL4->( MsUnLock() )			
			SL4->( DbSkip() )
		End
	EndIf
	DbSelectArea("SE4")
	DbSetOrder(1)
	If DbSeek(xFilial("SE4")+cCodPagto)
		//Tratamento para atualizacao o Array de aValores caso alterada Cond. de Pagamento C/ Acréscimo ou Descrescimo
		If !lTk271Auto .And. !lInit
			TK273AtuVal( cCodPagto )
			lChangeSE4 := .T.
		Endif
			
		cDescPagto:= SE4->E4_DESCRI
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lTk271Auto .And. lRefresh
			oDescPagto:Refresh()
		Endif
		
		If aValores[MERCADORIA] > SE4->E4_SUPER .AND. SE4->E4_SUPER <> 0 .AND. SuperGetMv("MV_CNDPLIM",,"1") == "1"
			If !lTk271Auto
				Help(" ","1","LJLIMSUPER")
			Endif
			lRet	:= .F.
		ElseIf aValores[MERCADORIA] < SE4->E4_INFER .AND. SE4->E4_INFER <> 0 .AND. SuperGetMv("MV_CNDPLIM",,"1") == "1"
			If !lTk271Auto
				Help(" ","1","LJLIMINFER")
			Endif
			lRet	:= .F.
		Endif
	Endif

// Se não houve alteracao dos itens do atendimento e as parcelas já estão preenchidas, mantem o conteudo das PARCELAS
ElseIf aValores[BASEDUP] == (nEntrada + nFinanciado) .AND. Len(aParcelas) > 0
	If lTipo9
		lCalcula := .T.     	
	Else
		nVlrPrazo := nEntrada + nFinanciado
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao estiver usando a entrada automatica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lTk271Auto .And. lRefresh
			oVlrPrazo:Refresh()
		Endif	
		lRet := .T.   
		lRecParc := .T. // nao recalcula a parcela
	Endif
Else
	// Se houve alteracao dos itens do atendimento REFAZ AS PARCELAS
	lCalcula := .T.
	lLimpa	 := .T.
Endif

If !lRecParc
	Do case
		case nOpc == 3 // Incluir
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Como e uma inclusao o valor de calculo sera baseado no valor da mercadoria         ³
			//³e a parcelas serao calculadas de acordo com a condicao escolhida (com ou sem juros)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nLiquido 	:= aValores[BASEDUP] - aValores[ACRESCIMO]
			nSuframa	:= aValores[SUFRAMA]
			nTotal		:= aValores[TOTAL]
			If lLimpa
				aParcelas := aClone(aVazio)
			Endif
			nEntrada 	:= 0
			nFinanciado	:= 0
			nTxJuros 	:= 0
			nTxDescon	:= 0
			nVlrPrazo 	:= 0
			nVlJur 		:= 0
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pego as informacoes da Condicao de Pagto Escolhida F3³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SE4")
			DbSetOrder(1)
			If !DbSeek(xFilial("SE4")+cCodPagto)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se nao estiver usando a entrada automatica³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lTk271Auto .And. lRefresh
					oParcelas:SetArray(aParcelas)
					oParcelas:Refresh()
					Help(" ",1,"FALTA_PGTO")
				Endif	
				Return(lRet)
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica a TABELA de precos inforamada existe                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("DA0")
			DbSetOrder(1)
			If !Empty(M->UA_TABELA)
				If !DbSeek(xFilial("DA0")+M->UA_TABELA)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lTk271Auto
						Help(" ",1,"OMSTABPRC2")
					Endif	
					Return(lRet)
				Endif
			Endif	
				
			DbSelectArea("SE4")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se a condicao de pagamento escolhida esta de acordo com a tabela de preco³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !MaVldTabPrc(M->UA_TABELA,cCodPagto)
				Return(lRet)
			Endif
			
			cDescPagto:= SE4->E4_DESCRI
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se nao estiver usando a entrada automatica³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lTk271Auto .And. lRefresh
				oDescPagto:Refresh()
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pega a porcentagem de juros da condicao de pagamento ou a de desc. finan.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SE4->E4_ACRSFIN)
				nTxJuros := SE4->E4_ACRSFIN
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se nao estiver usando a entrada automatica³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lTk271Auto .And. lRefresh
					oTxJuros:Refresh()
				Endif	
			ElseIf !Empty(SE4->E4_DESCFIN)
				nTxDescon:= SE4->E4_DESCFIN
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se nao estiver usando a entrada automatica³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lTk271Auto .And. lRefresh
					oTxDescon:Refresh()
				Endif	
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pega a Forma de Pagamento										        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(SE4->E4_FORMA)
				cForma1 := "CH"
			Else
				cForma1 := SE4->E4_FORMA
			EndIf
			If Empty(SE4->E4_FORMA)
				cForma2 := cForma1
			Elseif Empty(SubStr(SE4->E4_FORMA,1,TAMSX3("E4_FORMA")[1]))
				cForma2 := cForma1
			Else
				cForma2 := SubStr(SE4->E4_FORMA,1,TAMSX3("E4_FORMA")[1])
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calculo o valor do juro para atualizar o ACRESCIMO e o valor TOTAL do atendimento  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nVlJur := Tk273RecCpg( cCodPagto )
			
			If !lMV_TMKFIS
				Tk273AtuNFs()	
		
				aValores[MERCADORIA] := MaFisRet(, "NF_VALMERC")
				aValores[SUFRAMA] := MaFisRet(, "NF_DESCZF")
				aValores[TOTAL] := MaFisRet(, "NF_TOTAL")
				aValores[BASEDUP] := MaFisRet(, "NF_BASEDUP")
				If !lTk271Auto .And. lRefresh
					oFis:Refresh()
				EndIf
			EndIf
			
			// Calcula novamente o nLiquido para subtrair o valor de acrescimo que foi calculado
			nLiquido := aValores[BASEDUP] - aValores[ACRESCIMO]
			nSuframa := aValores[SUFRAMA]
			nTotal	 := aValores[TOTAL]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O tipo 9 e carregado em uma funcao especifica                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cTipo9 == "9"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se nao estiver usando a entrada automatica³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lTk271Auto
					If Empty(aParcelas)
						If nLiquido > 0
							aParcelas := TK273TipoNove(	nOpc		,nLiquido	,nVlJur	,cForma1,;
													SE4->E4_COND	,cNumTlv	,aTipo9	,lTipo9,;
													lCalcula		,lCancPagto)
						Else
							AADD(aParcelas,{	dDataBase	,;	// 1 - Data
											0		,;	// 2 - Valor
											cForma1		,;	// 3 - Forma de Pagamento	
											Space(80)	,;	// 4 - Complemento
											0			,;	// 5 - Valor R$ ou %
											Space(01)	})	// 6 - ID Cartao (para visualiz. sintetica)
						EndIf
						nParcelas := Len(aParcelas)
						lTipo9 	  := .T.
					EndIf
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Venda tipo 9 nao funciona em entrada automatica³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Return(lRet)
				Endif	
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta as parcelas com a funcao padrao CONDICAO (valor de compra + Juros 	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAux := {}
				aAux := Condicao(	(nLiquido + nVlJur)		, cCodPagto	, MaFisRet(,"NF_VALIPI")	, M->UA_EMISSAO	,;
									MaFisRet(,"NF_VALSOL")	, Nil		, Nil						, nVlJur		)
									
				nParcelas := Len(aAux)
	
				If nCont == 1
					cForma3 := cForma1
				Else
					cForma3 := cForma2
				EndIf
				If Empty(cForma3)
					cForma3 := "CH"
				EndIf			
				
				For nCont := 1 To nParcelas
					Aadd(aParcelas,{	aAux[nCont][1]	, aAux[nCont][2]	, cForma3	, Space(80)	,;
										0				, space(1)			})		
				Next nCont
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza a tela, pois pode acontecer de algum campo não ser³
			//³alterado e permanecer visualmente desatualizado.           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lTk271Auto .And. lRefresh
				oLiquido:Refresh()
				oEntrada:Refresh()
				oFinanciado:Refresh()
				oTxJuros:Refresh()
				oTxDescon:Refresh()
				oVlrPrazo:Refresh()
				oSuframa:Refresh()
				oTotal:Refresh()
			EndIf		
			
		case nOpc == 4 .OR. nOpc == 2	// Alterar ou Visualizar
			If !Empty(M->UA_EMISNF) .And. M->UA_STATUS = 'NF.'
				dDataCond := M->UA_EMISNF
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se foi determinado o calculo das parcelas ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCalcula
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se as parcelas estiverem vazias³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aParcelas) == 0
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta as parcelas de acordo com a condicao de pagamento gravada no atendimento ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aParcelas   := aClone(aVazio)
					nTotParc  := 0
					DbSelectArea("SL4")
					DbSetOrder(1)
					// Valido a existencia das parcelas gravadas no SL4.
					// Se nao existir ou se a data de emissão for diferente da database, monta as parcelas novamente. 
					If (cCodAnt == SUA->UA_CONDPG .Or. Empty(M->UA_CONDPG)) .And. DbSeek(cFilSL4+cNumTlv + "SIGATMK")
						While (!SL4->(Eof())) .AND. (cFilSL4 == SL4->L4_FILIAL) .AND. ;
											(SL4->L4_NUM == cNumTlv) 			.AND. ;
											(AllTrim(SL4->L4_ORIGEM) == "SIGATMK")
							If  cTipo9 == "9"
								nPorcParc := (L4_VALOR/UA_VLRLIQ) * 100
							Else
								nPorcParc :=  VAL(L4_COMP)
							EndIf   
							
							AADD(aParcelas,{L4_DATA			,;	// 1 - Data
											L4_VALOR		,;	// 2 - Valor
											LEFT(L4_FORMA,TAMSX3("L4_FORMA")[1]),;	// 3 - Forma de pagamento
											L4_OBS			,;	// 4 - Complemento	
											nPorcParc   	,;	// 5 - R$ ou %
											IIf(lVisuSint,L4_FORMAID,space(1)) })	// 6 - ID Cartao  

														
							nTotParc += SL4->L4_VALOR
							SL4->(DbSkip())
						End
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Monta as parcelas com a funcao padrao CONDICAO (valor de compra + Juros 	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
					nVlJur := Tk273RecCpg( cCodPagto )
					
					If !lMV_TMKFIS
						Tk273AtuNFs()	
	
						aValores[MERCADORIA] := MaFisRet(, "NF_VALMERC")
						aValores[SUFRAMA] := MaFisRet(, "NF_DESCZF")
						aValores[TOTAL] := MaFisRet(, "NF_TOTAL")
						aValores[BASEDUP] := MaFisRet(, "NF_BASEDUP")
						If !lTk271Auto .And. lRefresh
							oFis:Refresh()
						EndIf
					EndIf
					
					aAux := {}
					aAux := Condicao(	(nLiquido + nVlJur)		, cCodPagto	, MaFisRet(,"NF_VALIPI")	, dDataCond	,;
										MaFisRet(,"NF_VALSOL")	, Nil		, Nil						, nVlJur	)

					nParcelas := Len(aAux)

					If Len(aParcelas) == 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Pega a Forma de Pagamento										        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("SE4")
						DbSetOrder(1)
						If DbSeek(xFilial("SE4")+cCodPagto)
							If Empty(SE4->E4_FORMA)
								cForma1  := "CH"
							Else
								cForma1  := SE4->E4_FORMA
							EndIf
							If Empty(SE4->E4_FORMA)
								cForma2 := cForma1
							Elseif Empty(SubStr(SE4->E4_FORMA,1,TAMSX3("E4_FORMA")[1]))
								cForma2 := cForma1
							Else
								cForma2 := SubStr(SE4->E4_FORMA,1,TAMSX3("E4_FORMA")[1])
							Endif
						Endif

						For nCont := 1 To nParcelas
							Aadd(aParcelas,	{aAux[nCont][1]	, aAux[nCont][2]	, Iif(nCont==1,cForma1,cForma2)	, Space(80)	,;
											0				, space(1)			})
							nTotParc +=aAux[nCont][2]
						Next nCont
					Else
						//Se existir SL4 atualiza as datas e valores, somente se a data do atendimento for diferente da database
						If Len(aParcelas) == nParcelas .And. (dDataCond <> dCalculo) .And. cTipo9 <> "9" 
							For nCont := 1 To nParcelas
								aParcelas[nCont][1] := aAux[nCont][1]
								aParcelas[nCont][2] := aAux[nCont][2]
							Next nCont
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se total gravado anteriormente for <> do valor atual do atendimento - calcula novamente as parcelas³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nTotParc <> aValores[BASEDUP]
						lCalcula := .T.
					Else
						lCalcula := .F.
					Endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se a data das parcelas serao RECALCULADAS ou NAO                                          ³ 
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SUA")
					DbSetOrder(1)
					If DbSeek(xFilial("SUA")+cNumTlv)
						cOperAnt := SUA->UA_OPER
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se a operacao anterior era de ATENDIMENTO/ORCAMENTO              ³ 
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ( VAL(cOperAnt) == ATENDIMENTO .OR. VAL(cOperAnt) == ORCAMENTO ) 
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³e agora mudou para FATURAMENTO e a data de alteracao e nova - RECALCULA A DATA DAS PARCELAS³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (VAL(M->UA_OPER) == FATURAMENTO) .AND. (M->UA_EMISSAO <> dDataBase)
								lCalcula := .T.
								dCalculo := dDataBase
							Endif     
						Endif	
	            	Endif
				Else
					lCalcula := .T.
				Endif
				
			Else
			    
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Soma o valor das parcelas que foram gravadas no atendimento ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nCont :=1 To Len(aParcelas)
					nTotParc += aParcelas[nCont][2]
				Next nCont
			Endif
	
			nParcelas := Len(aParcelas)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Determina a data do primeiro pagamento ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nParcelas > 0
				dDataPar := aParcelas[1][1]
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se mudou o valor liquido do pedido consultado refaz as parcelas da condicao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cTipo9 <> "9" .AND. nToTParc <> (nEntrada + nFinanciado) .OR. lCalcula
	
				nLiquido 	:= aValores[BASEDUP] - aValores[ACRESCIMO]
				nSuframa	:= aValores[SUFRAMA]
				nTotal		:= aValores[TOTAL]
				aParcelas   := aClone(aVazio)
				nNumParcelas:= 0
				nParcelas	:= 0
				nEntrada 	:= 0
				nFinanciado	:= 0
				nTxJuros 	:= 0
				nTxDescon	:= 0
				nVlrPrazo 	:= 0
				nVlJur 		:= 0
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pego as informa‡oes da Condi‡ao de Pagto Escolhida F3³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SE4")
				DbSetOrder(1)
				If !DbSeek(xFilial("SE4")+cCodPagto)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se nao estiver usando a entrada automatica³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lTk271Auto .And. lRefresh
						oParcelas:SetArray(aParcelas)
						oParcelas:Refresh()
						Help(" ",1,"FALTA_PGTO")
					Endif	
					Return(lRet)
				Endif
				
				cDescPagto:= SE4->E4_DESCRI
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se nao estiver usando a entrada automatica³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lTk271Auto .And. lRefresh
					oDescPagto:Refresh()
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pega a porcentagem de juros da condicao de pagamento ou a de desc. finan.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(SE4->E4_ACRSFIN)
					nTxJuros := SE4->E4_ACRSFIN
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se nao estiver usando a entrada automatica³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lTk271Auto .And. lRefresh
						oTxJuros:Refresh()
					Endif	
				ElseIf !Empty(SE4->E4_DESCFIN)
					nTxDescon:= SE4->E4_DESCFIN
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se nao estiver usando a entrada automatica³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lTk271Auto .And. lRefresh
						oTxDescon:Refresh()
					Endif	
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pega a Forma de Pagamento										        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(SE4->E4_FORMA)
					cForma1  := "CH"
				Else
					cForma	:= SE4->E4_FORMA
					cForma1	:= SE4->E4_FORMA
				EndIF
				If Empty(SE4->E4_FORMA)
					cForma2 := cForma1
				Elseif Empty(SubStr(SE4->E4_FORMA,1,TAMSX3("E4_FORMA")[1]))
					cForma2 := cForma1
				Else
					cForma2 := SubStr(SE4->E4_FORMA,1,TAMSX3("E4_FORMA")[1])
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calculo o valor do juro sobre o valor da compra      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nVlJur := Tk273RecCpg( cCodPagto )
				
				If !lMV_TMKFIS
					Tk273AtuNFs()	
			
					aValores[MERCADORIA] := MaFisRet(, "NF_VALMERC")
					aValores[SUFRAMA] := MaFisRet(, "NF_DESCZF")
					aValores[TOTAL] := MaFisRet(, "NF_TOTAL") 
					aValores[BASEDUP] := MaFisRet(, "NF_BASEDUP")
					If !lTk271Auto .And. lRefresh     
						oFis:Refresh()
					EndIf
				EndIf			
				
				//Calcula novamente o nLiquido para subtrair o valor de acrescimo que foi calculado
				nLiquido := aValores[BASEDUP] - aValores[ACRESCIMO]
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³O tipo 9 e carregado em uma funcao especifica                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SE4->E4_TIPO == "9" .AND. nOpc <> 2
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se nao estiver usando a entrada automatica³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lTk271Auto 
						If nLiquido > 0
							aParcelas := TK273TipoNove(	nOpc		,nLiquido	,nVlJur	,cForma1,;
														SE4->E4_COND,cNumTlv	,aTipo9	,lTipo9,;
														lCalcula	,lCancPagto)
						Else
							AADD(aParcelas,{	dDataBase	,;	// 1 - Data
											0		,;	// 2 - Valor
											cForma1		,;	// 3 - Forma de Pagamento	
											Space(80)	,;	// 4 - Complemento
											0			,;	// 5 - Valor R$ ou %
											Space(01)	})	// 6 - ID Cartao (para visualiz. sintetica)
						EndIf
						nParcelas := Len(aParcelas)
						lTipo9 	  := .T.
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Venda tipo 9 nao funciona em entrada automatica³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Return(lRet)
					Endif	
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se o array aParcelas esta vazio quer dizer que nao foi escolhido uma condicao anteriomente - ORCAMENTO³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nParcelas == 0
	
						If (VAL(M->UA_OPER) <> ORCAMENTO)
							dDataCond := dCalculo
						EndIf
					
						aAux := {}
						aAux := Condicao(	(nLiquido + nVlJur)		, cCodPagto	, MaFisRet(,"NF_VALIPI")	, dDataCond	,;
											MaFisRet(,"NF_VALSOL")	, Nil		, Nil						, nVlJur	)
						nParcelas := Len(aAux)
						
						If nCont == 1
							cForma3 := cForma1
						Else
							cForma3 := cForma2
						EndIf
						If Empty(cForma3)
							cForma3 := "CH"
						EndIf			
	
						For nCont := 1 To nParcelas
							Aadd(aParcelas	, {	aAux[nCont][1]	, aAux[nCont][2]	, cForma3	, Space(80)	,;
												0				, space(1)			})
						Next nCont
					Endif
					
				Endif
			Endif
	Endcase
Else
	If nParcelas <= 0
		nParcelas := Len(aParcelas)
	EndIf
Endif

If Len(aParcelas) > 0

	If !lTLVReg1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a array para verificação dos descontos através da³
		//³função FtRegraNeg                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³       Estrutura do array aProdDesc                                          ³			
		//³       [1] - Codigo do Produto                                               ³
		//³       [2] - Item do Pedido de Venda                                         ³
		//³       [3] - Preco de Venda                                                  ³
		//³       [4] - Preco de Lista                                                  ³						
		//³       [5] - % do Desconto Concedido no item do pedido                       ³
		//³       [6] - % do Desconto Permitido pela regra (FtRegraNeg)                 ³
		//³       [7] - Indica se sera necessario verificar o saldo de verba            ³
		//³                             01 - Bloqueio de regra de negocio               ³
		//³                             02 - Bloqueio para verificacao de verba         ³
		//³       [8] - Valor a ser abatido da verba caso seja aprovada (FtVerbaVen)    ³			
		//³       [9] - Flag que indica se o item sera analisado nas regras             ³							
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nContx := 1 To Len(aCols)
			If !GdDeleted(nContx)
				If aCols[nContx][nPDesc] == 0 .And. aCols[nContx][nPPrven] < aCols[nContx][nPPrlis]
					nDescon := (100 - (aCols[nContx][nPPrven] / aCols[nContx][nPPrlis]) * 100 )
				Else
					nDescon := aCols[nContx][nPDesc]
				EndIf
				Aadd(aProdDesc,{	aCols[nContx][nPProd]	, aCols[nContx][nPItem]	, aCols[nContx][nPPrven]	, aCols[nContx][nPPrlis]	,;
									nDescon	, 0					, ""				, 0					,;
									.T.					}) 
			EndIf						
		Next nContx
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a regra de negocio cadastrada e valida com a tabela de preco escolhida³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nContx := 1 To Len(aParcelas)
		  	If !FtRegraNeg(	M->UA_CLIENTE			, M->UA_LOJA	, M->UA_TABELA	, cCodPagto	,;
							aParcelas[nContx][3]	, @aProdDesc	, .F., nil , .T.			)
				lPedidoBloq := .T.
				lTLVReg2 := .T. 
			Endif
		Next nContx
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibe uma mensagêm dinâmica com os produtos que estão   ³
		//³com o desconto acima do permitido pela regra do negócio.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCont:=1 To Len(aProdDesc)
			If aProdDesc[nCont][7] == "02"
				lTLVReg1 := .T.// regra de negocios bloqueada por desconto. 
				If nCont == 1 .OR. Empty(cMensagem)
					cMensagem += STR0057 + Chr(13) + Chr(10) // "Os seguintes produtos ocasionarão o bloqueio do pedido devido à regra de negócios referente ao desconto:"
				Endif
				cMensagem += AllTrim(aCols[nCont][3]) + STR0051 + Transform(aProdDesc[nCont][5],aHeader[8][3]) + STR0052 + Transform(aProdDesc[nCont][6],aHeader[8][3]) + Chr(13) + Chr(10) // " - atual: " // " máximo permitido: "					
			Endif
		    If aProdDesc[nCont][7] == "01"
				lTLVReg1 := .T.// regra de negocios bloqueada por produto não consta na regra. 
		    Endif
		Next nCont	
				
		If Len(cMensagem) > 0
			MsgStop(cMensagem, STR0046) // "Atenção"
			lCondBlq := .T.
		ElseIf lPedidoBloq
			MsgInfo(STR0058,STR0046) //"Conforme a configuração das condições comerciais determinadas pela regra de negócio da empresa, este pedido de venda será gerado como bloqueado." ## "Atenção" 
		EndIf
	EndIf
 If !lEntrada
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega o total da parcela.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCont:=1 To nParcelas
		nTotalParcela += Round(aParcelas[nCont][2],2)
	Next nCont
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega a Entrada										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nEntrada := 0
	For nCont := 1 To nParcelas
		If aParcelas[nCont][1] == dDataBase
			nEntrada += aParcelas[nCont][2]
		EndIf
	Next nCont
	
	If !lTk271Auto .And. lRefresh
		oEntrada:Refresh()
	Endif	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega o valor a ser financiado						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nFinanciado := 0
	For nCont := 1 TO nParcelas
		If aParcelas[nCont][1] > dDataBase
			nFinanciado += Round(aParcelas[nCont][2],2)
		Endif
	Next nCont
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajuste da ultima parcela (arredondamento)				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nResto := aValores[BASEDUP] - nTotalParcela
	If (nResto <> 0) .And. Len(aParcelas) >= (nCont-1)
		aParcelas[nCont-1][2] += nResto
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Incrementa no valor financiado a diferen‡a       	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nFinanciado > 0
			nFinanciado += Round(nResto,2)
		EndIf
	EndIf                                            
	
	If !lTk271Auto .And. lRefresh
		oFinanciado:Refresh()
	EndIf	
 EndIf	
EndIf

If ExistBlock("TKTLVPAG")
	aParcAux := ExecBlock( "TKTLVPAG", .F., .F.,{ aParcelas, nOpc } )

	If ValType( aParcAux ) == "A"
		aParcelas := aParcAux
	EndIf

	nParcelas := Len(aParcelas) //numero de parcelas
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao estiver usando a entrada automatica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTk271Auto .And. lRefresh
	
	oParcelas:SetArray(aParcelas)
	oParcelas:bLine := {||{	DTOC(aParcelas[oParcelas:nAt,1]),;  //Visualizacao
							xPadR(Transform(aParcelas[oParcelas:nAt,2],"@E 999,999,999.99"),50) ,;
							aParcelas[oParcelas:nAt,3]}}
	
	oParcelas:Refresh()
	
	nNumParcelas:= nParcelas
	oNumParcelas:Refresh()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o array de parcelas sintetizadas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	lVisuSint 				.AND.;
		Type("oPgtosSint")=="O" .AND.;
		lUsaTef 				.AND.;
		cTipTef == TEF_CLISITEF
		
		aPgtosSint := Tk273MontPgt( aParcelas )
		oPgtosSint:SetArray( aPgtosSint )
		oPgtosSint:Refresh()
	Endif
		
	nVlrPrazo := nEntrada + nFinanciado
	oVlrPrazo:Refresh()
	oSuframa:Refresh()
	oTotal:Refresh()
Else
	nNumParcelas := nParcelas
	nVlrPrazo := nEntrada + nFinanciado
Endif

lRet := .T.
lTipo9	:= .F.
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271Detalhe ³Autor ³ Vendas Clientes       ³Data ³08/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Tela para preenchimento com os detalhes de cada tipo de     ³±±
±±³          ³parcela CHEQUE, CARTAO e FINANCIAMENTO                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk273Detalhe(aParcelas	,oParcelas	,aItens		,lHabilita,;
							 nLiquido	,nEntrada	,oEntrada	,nFinanciado,;
							 oFinanciado,cCodPagto	,lSigaCRD   ,lTLVReg2)

Local cComplemento 	:= SPACE(80)        				// Obervacao do SL4
Local nPos 			:= 0								// Posicao no APARCELAS
Local aAux 			:= {}                               // Variavel auxiliar
Local nCont			:= 0                                // Contador
Local aMatriz 		:= {}                               // Array com as formas de pagamento
Local aChave  		:= {}								// Array com as formas de pagamento
Local cComboForma 	:= ""								// Combobox para escolhar a forma de pagamento - tabela 24
Local oComboForma										// Objeto COMBO	
Local dDtParcela  	:= CTOD("  /  /  ")					// Data de vencimento da parcela - VISUAL
Local oDtParcela										// Objeto GET
Local nVlrParcela 	:= 0								// Valor da parcela - VISUAL
Local oVlrParcela                                       // Objeto GET
Local cTipo			:= ""								// Tipo da forma de pagamento
Local dDataAnt 		:= CTOD("  /  /  ")					// Data anterior
Local nValAnt  		:= 0								// Valor anterior
Local cComboAnt		:= ""                               // Conteudo do combo anterior
Local oDetailDlg										// Tela 
Local lOk			:= (SuperGetMv("MV_TMKLOJ") == "I")//Flag que vai controlar a alteracao da data e do valor da parcela 
														//SOMENTE QUANDO HOUVER INTEGRACAO COM SIGALOJA
Local lRet			:= .F.								// Retorno da funcao
Local cFormaId		:= IIf(lVisuSint,Space(TamSX3("L4_FORMAID")[1]),Space(01))	// ID do cartao
Local cFormaIdAnt 	:= cFormaId							// ID anterior do cartao
Local nLinha		:= 0                            	// Linha selecionada no browse
Local nParc			:= 1								// Nr. parcelas
Local oParc 											// Objeto GET nr. parcelas
Local oCart 											// Objeto GET ID do cartao
Local oCheckPag 										// Objeto Checkbox 
Local lCheckPag		:= .F.								// indica se utiliza nas prox. parcelas
Local lConfirma		:= .F.								// Indica se confirmou a operacao digitada
Local nX 			:= 1								// variav. auxiliar em lacos for...next
Local lTefMult		:= SuperGetMV("MV_TEFMULT")			// Parametro do SX6 que indica se o sistema vai o TEF multiplas transacoes
Local lAltValor		:= .F.								// Indica se podera alterar o valor da parcela

Default lTLVReg2    := .F. 								// controle de validacao da regra de negocios 
                       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpo os dados do complemento da parcela selecionada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cComplemento := SPACE(80)

If Len(aParcelas) == 0 .OR. Empty(aParcelas[1][1])
	aParcelas := {}
	aParcelas :={{CTOD("  /  /  "),0,SPACE(15),SPACE(80)}}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTk271Auto
		oParcelas:Refresh()
    Endif
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega a linha da parcela selecionada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVisuSint .AND. Type("oPgtosAna")=="O"
	//Visualizacao sintetica
	nLinha := oPgtosAna:nAt
Else
	//Visualizacao normal
	nLinha := oParcelas:nAt	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o ID do cartao quando esta habilitado o TEF com mult. transacoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	lUsaTef 	.AND.;
	lTefMult 	.AND.;
	lVisuSint
	
	cFormaID 	:= aParcelas[nLinha][6]
	cFormaIdAnt := cFormaID
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mult. transacoes TEF: permitira alterar o valor para cada cartao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lAltValor	:= .T.
Endif

dDtParcela 	:= aParcelas[nLinha,1]		//Data
nVlrParcela	:= aParcelas[nLinha,2]		//Valor da parcela

For nCont := 1 To Len(aItens)
	AAdd(aMatriz,aItens[nCont][1])
	AAdd(aChave ,aItens[nCont][2])
Next nCont

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa no ARRAY de dados complementares da parcela qual foi a parcela selecionada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := Ascan(aItens,{|aAux|AllTrim(aAux[2]) == AllTrim(aParcelas[nLinha,3])})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para proteger o codigo caso os dados da base estejam inconsistentes     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nPos < 1
	Help(" ",1,"TK273TAB24" )
	Return(lRet)
Endif

cComboForma	:= aItens[nPos,1]
cTipo	   	:= aItens[nPos,2]

dDataAnt  	:= aParcelas[nLinha,1]
nValAnt   	:= aParcelas[nLinha,2]
cComboAnt 	:= aParcelas[nLinha,3]

DEFINE MSDIALOG oDetailDlg FROM 10,20 TO 235,300 TITLE STR0022 PIXEL STYLE DS_MODALFRAME  //"Forma de Pagamento da Parcela" 

	@ 05,10 SAY STR0011 SIZE 30,8 PIXEL OF oDetailDlg  //"Data" 
	
	@ 05,37 MSGET oDtParcela VAR dDtParcela SIZE 50,8 PIXEL OF oDetailDlg PICTURE "99/99/99" ;
			WHEN IIf(cTipTef <> TEF_CLISITEF, lOk, .F.) VALID Tk273ValData(dDataAnt	,@dDtParcela	,oDtParcela	,aParcelas,;
																			oParcelas	,aItens			,cComboForma)
	
	@ 20,10 SAY STR0012 SIZE 30,8 PIXEL OF oDetailDlg //"Valor" 
	@ 20,37 MSGET oVlrParcela VAR nVlrParcela SIZE 70,8 PIXEL OF oDetailDlg PICTURE "@E 9999999.99" ;
			WHEN IIf(cTipTef == TEF_CLISITEF .AND. lTefMult, lAltValor, lOk) RIGHT
	
	@ 35,10 SAY STR0013 SIZE 50,8 PIXEL OF oDetailDlg //"Forma"
	@ 35,37 MSCOMBOBOX oComboForma VAR cComboForma ITEMS aMatriz SIZE 100,50 OF oDetailDlg PIXEL ;
			VALID TK273Data(cComboForma,aParcelas,aItens,dDtParcela);
			ON CHANGE (cTipo := aChave[oComboForma:nAt]) ;
			WHEN lHabilita .AND. (If(nLinha == 0 .OR. (lVisuSint .AND. cTipo$_FORMATEF) ,.F.,.T.))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Objetos para tratamento de mult. transacoes TEF ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lUsaTef 	.AND.;
   	  lTefMult	.AND.;
   	  lVisuSint .AND.;
   	  cTipTef == TEF_CLISITEF
   	  
	   @ 50,10 Say STR0042 SIZE 50,8 PIXEL OF oDetailDlg 	//"ID Cartão"
  	   @ 50,37 MSGET oCart VAR cFormaId RIGHT SIZE 15,08 OF oDetailDlg PIXEL PICTURE PesqPict("SL4","L4_FORMAID") ;
  		   	   WHEN  TK273WhenID(nLinha,cTipo,@cFormaId,aItens) VALID TK273ValidID(cTipo,@cFormaId,aItens)
    			oCart:cSx1Hlp:="L4_FORMAID"
   Endif

   If lVisuSint .AND. (nLinha == 0 .AND. cTipo $ _FORMATEF )
	   @ 65,10 Say STR0041 SIZE 10,1 		//"Parcelas"
  	   @ 65,37 MSGET oParc VAR nParc	RIGHT SIZE 15,08 PICTURE "99" VALID(If (nParc < 1 ,(MsgStop(STR0043), .F.),.T.)) // Valor nao permitido para esse campo
 	  	            oParc:cSx1Hlp:=""
   Endif
   
   If nLinha > 0 .AND. nLinha < Len(aParcelas) .AND. !IsMoney(cTipo)
	  @ 80,10 CHECKBOX oCheckPag VAR lCheckPag PROMPT STR0044 SIZE 90,8 OF oDetailDlg //"Utiliza nas próximas parcelas"
   	  	            oCheckPag:cSx1Hlp:=""
   Endif
	
	DEFINE SBUTTON FROM 95,070 TYPE 1 ACTION (Tk273Compl(@cComboForma	,@cTipo		,@aParcelas	,@oParcelas,;
														 aItens			,lHabilita	,cCodPagto	,lSigaCRD  ,@lTLVReg2,lCheckPag),;
														lConfirma:=.T., oDetailDlg:End()) ENABLE OF oDetailDlg	 
														
	DEFINE SBUTTON FROM 95,105 TYPE 2 ACTION (lConfirma:=.F., oDetailDlg:End()) ENABLE OF oDetailDlg
	
	// Desabilita a tecla ESC
    oDetailDlg:LESCCLOSE := .F.
    
ACTIVATE MSDIALOG oDetailDlg CENTER

If lConfirma
	If nVlrParcela > 0                	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os dados da parcela ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aParcelas[nLinha][1] := dDtParcela
		If nLinha < Len(aParcelas)
			aParcelas[nLinha][2] := nVlrParcela
		Else
			If nValAnt <> nVlrParcela
				MsgAlert(STR0047, STR0046) //"O valor da última parcela não poderá ser alterado"
			EndIf
		EndIf
		aParcelas[nLinha][3] := cTipo
		aParcelas[nLinha][6] := cFormaID
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Recalcula o valor das demais parcelas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nValAnt <> nVlrParcela
			Tk273ReFill( nLinha, nLiquido, aParcelas )
		EndIf
		
		If lCheckPag   

			For nX := nLinha+1 To Len(aParcelas)
				//Só alterar as próximas parcelas iguais a originária devido ao controle de datas
				If !IsMoney(cComboAnt) .AND. AllTrim(aParcelas[nX][3]) == AllTrim(cComboAnt) ;
					.AND. AllTrim(aParcelas[nX][6]) == AllTrim(cFormaIdAnt)
                    
					aParcelas[nX][3] := aParcelas[nLinha][3]
					aParcelas[nX][6] := aParcelas[nLinha][6]
				Endif
			Next nX
		Endif		

	Endif	
	
	oParcelas:SetArray(aParcelas)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTk271Auto
		oParcelas:Refresh()
	Endif
	                 
	//Atualiza array de parcelas (analitico)
	If Type("oPgtosAna") == "O"
		oPgtosAna:SetArray(aParcelas)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lTk271Auto
			oPgtosAna:Refresh()
		Endif	
	Endif

	// Atualiza Array de parcelas (Sintetizado)
	If 	lVisuSint 	.AND. ;
		lUsaTef 	.AND. ;
		cTipTef == TEF_CLISITEF
		
		aPgtosSint := Tk273MontPgt(aParcelas)
		oPgtosSint:SetArray( aPgtosSint )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lTk271Auto
			oPgtosSint:Refresh()
		Endif	
	Endif	
	
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271Compl³ Autor ³ Vendas Clientes       ³ Data ³08/01/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de complemento da parcela de acordo com a Forma       ³±±
±±³          ³ de pagamento escolhida                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk273Compl(	cComboForma	,cTipo		,aParcelas	,oParcelas,;
							aItens		,lHabilita	,cCodPagto	,lSigaCRD ,;
							lTLVReg2    ,lCheckPag)

Local cBanco 	:=SPACE(3),oBanco			//Banco
Local cAgencia	:=SPACE(5),oAgencia			//Agencia
Local cConta 	:=SPACE(10),oConta			//Conta
Local cCheque 	:=SPACE(15),oCheque			//Cheque
Local cRg 		:=SPACE(14),oRg				//RG
Local cFone 	:=SPACE(15),oFone			//Telefone
Local cComboAdm	:=SPACE(20),oComboAdm		//Administradora	
Local aSAE    	:={}						//Array com as Administradoras cadastradas
Local cCartao	:=SPACE(20),oCartao			//Dados do cartao
Local dDtValid 	:=CTOD("  /  /  "),oDtValid	//Data de validade 
Local cAutor	:=SPACE(6),oAutor			//Codigo de autorizacao	
Local oDlg									//Tela
Local nPos 		:= 0                        //Posicao
Local lCheckBox	:=.F.,oCheckBox				//Checkbox
Local cDetalhe	:= SPACE(80)				//Detalhe 
Local nOpca 	:= 0						//Opcao de escolha OK ou CANCELA
Local lShowDlg  := .T.						//Flag para exibicao da tela dos dados complementares	
Local cFormCRD	:= SuperGetMv("MV_FORMCRD",,"CH/FI") //Formas de pagamento aceitas para analise de credito do SIGACRD
Local nLinha	:= 0  						//Linha selecionada no browse
Local nContx    := 0
Local cFormaPag := ""

DEFAULT lCheckPag := .F.

lTLVReg2  := .F. 						// Se alterar a forma de pagamento deve revalidar a regra de negocios.
                             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a regra de negocio cadastrada e valida com a tabela de preco escolhida³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! FtRegraNeg(M->UA_CLIENTE	, M->UA_LOJA	, M->UA_TABELA	, cCodPagto	,;
				cTipo			, NIL			, .F., nil, .T.			)
	lTLVReg2  := .T. 
Else
	For nContx := 1 To Len(aParcelas)
		If nContx <> oParcelas:nAt	
		  	If !lCheckPag
				cFormaPag := aParcelas[nContx][3]
			Else
				If nContx > oParcelas:nAt
					cFormaPag := cTipo
				Else
					cFormaPag := aParcelas[nContx][3]
				Endif			
			EndIf
			
		  	If !FtRegraNeg(	M->UA_CLIENTE			, M->UA_LOJA	, M->UA_TABELA	, cCodPagto	,;
				cFormaPag	, NIL	, .F.,nil , .T.			)
				lTLVReg2 := .T.
			Endif			
			
		Endif
	Next nContx
Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica qual eh a forma de visualizacao das parcelas ³
//³ Sintetica ou analitica                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVisuSint .AND. Type("oPgtosAna")=="O"
	//Visualizacao sintetica
	nLinha := oPgtosAna:nAt
Else
	//Visualizacao normal
	nLinha := oParcelas:nAt	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for a vista n„o tem informa‡”es complementares			    	  ³
//³Se estiver usando TEF nao tem informacoes complementares para CC e CH  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaTef
	If (cTipo == "CC" .OR. cTipo == "CH") .OR. ("$" $ cTipo) .OR. !(cTipo $ "CCVAFICOCH")
		lShowDlg := .T.
	Endif
Endif

cDetalhe := aParcelas[nLinha,4]	//Detalhes da parcela - cartao, cheque, etc

If lShowDlg
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for pagamento em CHEQUE					     					  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cTipo == "CH") 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o valor digitado anteriormente n„o foi em CHEQUE limpo o complemento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Substr(cDetalhe,79,2) <> "CH"
			cDetalhe:=SPACE(80)
		Endif
	
		cBanco  := Substr(cDetalhe,1,3)
		cAgencia:= Substr(cDetalhe,4,5)
		cConta  := Substr(cDetalhe,9,10)
		cCheque := Substr(cDetalhe,19,15)
		cRg     := Substr(cDetalhe,34,14)
		cFone   := Substr(cDetalhe,48,15)
	
		DEFINE MSDIALOG oDlg FROM 10,20 TO 210,250 TITLE STR0023 PIXEL STYLE DS_MODALFRAME  //"Complemento da Parcela" 
	
			@05,10 SAY STR0024 OF oDlg PIXEL //"Banco" 
			@05,47 MSGET oBanco VAR cBanco Picture "999" SIZE 40,8 OF oDlg PIXEL When lHabilita RIGHT
		
			@16,10 SAY STR0025 OF oDlg PIXEL //"Agencia" 
			@16,47 MSGET oAgencia VAR cAgencia Picture "99999" SIZE 40,8 PIXEL OF oDlg When lHabilita RIGHT
		
			@26,10 SAY STR0026 OF oDlg PIXEL //"Conta" 
			@26,47 MSGET oConta VAR cConta Picture "9999999999" SIZE 60,8 PIXEL OF oDlg When lHabilita RIGHT
		
			@36,10 SAY STR0027 OF oDlg PIXEL //"Cheque" 
			@36,47 MSGET oCheque VAR cCheque Picture "999999999999999" SIZE 60,8 PIXEL OF oDlg When lHabilita RIGHT
		
			@46,10 SAY STR0028 OF oDlg PIXEL //"RG" 
			@46,47 MSGET oRg VAR cRg Picture "@R 99.999.999.999" SIZE 60,8 PIXEL OF oDlg When lHabilita RIGHT
		
			@56,10 SAY STR0029 OF oDlg PIXEL //"Telefone"
			@56,47 MSGET oFone VAR cFone  Picture "@R (999) 9999-9999" SIZE 60,8 PIXEL OF oDlg When lHabilita RIGHT
		
			@68,10 CHECKBOX oCheckBox VAR lCheckBox PROMPT STR0030 SIZE 90,10 OF oDlg PIXEL WHEN (nLinha <> Len(aParcelas))  //"Aplica em todas as parcelas" 
		
			DEFINE SBUTTON FROM 85,055 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
		
			DEFINE SBUTTON FROM 85,085 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
			
		    // Desabilita a tecla ESC
		    oDlg:LESCCLOSE := .F.
		    		
		ACTIVATE MSDIALOG oDlg CENTER
	
		If nOpcA == 1
			cDetalhe := cBanco + cAgencia + cConta + cCheque + cRg + cFone + SPACE(16) + cTipo
		Endif
		
		If !Empty(cCheque)
			nAux := VAL(cCheque)
		Else
			nAux := 0
		EndIf

	ElseIf (cTipo == "CC") .OR. cTipo $ cFormCRD
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega as administradora de cart„o de cr‚dito					      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SAE")
		DbSetOrder(1)
		DbSeek(xFilial("SAE"))
		While !SAE->(Eof()) .AND. SAE->AE_FILIAL == xFilial("SAE")
			AADD(aSAE,AE_COD+"-"+AE_DESC)
			SAE->(DbSkip())
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o valor digitado ou gravado anteriormente n„o foi em CARTAO limpo o complemento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Substr(cDetalhe,79,2) $ "CH"
			cDetalhe:=SPACE(80)
		Endif
		
		cComboAdm 	:=Substr(cDetalhe,1,AT("*",cDetalhe)-1)
		cCartao 	:=Substr(cDetalhe,AT("*",cDetalhe),16)
		dDtValid	:=CTOD(Substr(cDetalhe,AT("*",cDetalhe)+16,8))
		cAutor 	 	:=Substr(cDetalhe,AT("*",cDetalhe)+16+8,6)
		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o conteudo da administradora nao estiver vazio, seleciona o valor gravado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If !Empty(cComboAdm)
			nPos:= Ascan(aSAE,{|x| Upper(x) == Upper(cComboAdm)})
			If nPos > 0
				cComboAdm:= aSAE[nPos]
			Endif
		Endif		
		
		DEFINE MSDIALOG oDlg FROM 10,20 TO 210,300 TITLE STR0023 PIXEL STYLE DS_MODALFRAME  //"Complemento da Parcela" 
		
			@05,10 SAY STR0031 OF oDlg PIXEL //"Administradora" 
			@05,57 MSCOMBOBOX oComboAdm VAR cComboAdm ITEMS aSAE SIZE 80,8 PIXEL OF oDlg When lHabilita
			
			@20,10 SAY STR0032 OF oDlg PIXEL //"Cart„o" 
			@20,57 MSGET oCartao  VAR cCartao Picture "@R XXXXXXXXXXXXXXXX" SIZE 80,8 PIXEL OF oDlg VALID !Empty(cCartao) When lHabilita
			
			@35,10 SAY STR0033 OF oDlg PIXEL  //"Validade"
			@35,57 MSGET oDtValid VAR dDtValid Picture "99/99/99" SIZE 50,8 PIXEL OF oDlg VALID ValDtCC(dDtValid) When lHabilita
			
			@50,10 SAY STR0034 OF oDlg PIXEL  //"Autoriza‡„o"
			@50,57 MSGET oAutor  VAR cAutor Picture "@!"  SIZE 40,8 PIXEL OF oDlg When lHabilita
		
			@65,10 CHECKBOX oCheckBox VAR lCheckBox PROMPT STR0030 SIZE 90,10 OF oDlg PIXEL WHEN lHabilita  //"Aplica em todas as parcelas"
		
			//Confirmacao - Botao de Ok
			DEFINE SBUTTON FROM 80,075 TYPE 1 ACTION (IIF(!Empty(cCartao) .And. ValDtCC(dDtValid),(nOpca:= 1,oDlg:End()),nil)) ENABLE OF oDlg
			
			DEFINE SBUTTON FROM 80,105 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
		
		    // Desabilita a tecla ESC
		    oDlg:LESCCLOSE := .F.
			
		ACTIVATE MSDIALOG oDlg CENTER

		If nOpcA == 1
			cDetalhe := cComboAdm + "************" + If(!Empty(cCartao),SubStr(cCartao,13,4),"****") +;
						DTOC(dDtValid) + cAutor + SPACE(28) + cTipo
		Endif
	Endif
	
Else
	nOpca := 1
Endif	

If nOpca == 1
	If lCheckBox

		For nPos := 1 TO Len(aParcelas)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifico se a parcela e igual a parcela preenchida e se nao 			   ³
			//³e a primeira, pois o numero sequencial dos cheques e a partir da segunda³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If (cTipo == "CH")
		    	If (nPos > 1)
		    		nAux ++
		    	Endif
		    	
				cDetalhe := cBanco + cAgencia + cConta + StrZero(nAux,Len(cCheque)) + cRg + cFone + SPACE(16) + cTipo
			Endif
				
			aParcelas[nPos,3] := cTipo
			aParcelas[nPos,4] := cDetalhe
		
		Next nPos
		
	Else
			
		nPos := Ascan( aItens, { |x| x[1] = cComboForma } )
		If nPos > 0
			aParcelas[nLinha,3] := aItens[nPos][2]	//Forma de pagamento	
			aParcelas[nLinha,4] := cDetalhe			//Detalhes
		Endif
			
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTk271Auto
		oParcelas:Refresh()
    Endif

Else
	If !(cTipo $ "CC/CH" .OR. cTipo $ cFormCRD)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso nao seja necessario o complemento e a parcela nao      ³
		//³for cheque e nem cartao altera a terceira coluna do aParcelas³
		//³ com a forma de pagto escolhida.                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos := Ascan( aItens, { |x| x[1] = cComboForma } )
		If nPos > 0
			aParcelas[nLinha,3] := aItens[nPos][2]		//Forma de Pagamento
			aParcelas[nLinha,4] := cDetalhe				//Detalhes
		Endif	
	Else                
		nPos := Ascan( aItens, { |x| x[2] = aParcelas[nLinha,3] } )  
		If nPos > 0
			cComboForma := aItens[nPos][1]
			cTipo 		:= aItens[nPos][2]
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTk271Auto
		oParcelas:Refresh()
	Endif
		
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValDtCC   ºAutor  ³Vendas / CRM        º Data ³  02/17/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se a data do cartao e menor que a data do sistema  º±±
±±º          ³ou a data do computador                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA273C                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValDtCC(dDtValid)
Local lRet := .T.

If Empty(dDtValid) .Or. (dDtValid < dDataBase) .Or. (dDtValid < Date())
	Help(" ",1,"DATA_INVAL")
	lRet  := .F.
EndIf

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271ValData   ³ Autor ³ Vendas Clientes  ³ Data ³22/05/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se a data digitada e maior que a anterior   	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk273ValData(	dDataAnt	,dDtParcela		,oDtParcela		,aParcelas,;
								oParcelas	,aItens			,cComboForma)

Local nTamPgtos := Len(aParcelas)			
Local nPos 		:= 1					//Posicao dentro do aParcelas	
Local lRet 		:= .T.					//Retorno da funcao

If lVisuSint .AND. Type("oPgtosAna")=="O"
	nPos := oPgtosAna:nAt
Else
	nPos := oParcelas:nAt	
Endif

If Empty(dDtParcela)
	dDtParcela:= dDataAnt
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTk271Auto
		oDtParcela:Refresh()
	Endif	
	lRet := .F.
	
ElseIf (nPos <= nTamPgtos) .AND. (nPos > 1)
	If dDtParcela < aParcelas[nPos-1,1]
		dDtParcela := dDataAnt
		lRet := .F.
	Else
		nPos := 0
		nPos := Ascan(aItens,{|aItens| aItens[1] == cComboForma})
		If nPos > 0
			If ("$" $ aItens[nPos][2] ) .AND. (dDtParcela > dDataBase)
				Help( " ", 1, "NOPRAZO" )
				lRet := .F.
			Endif
		Endif
	Endif
	
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk273ParcelaOk ³ Autor ³ Vendas Clientes  ³ Data ³21/05/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se total das parcelas esta igual ao valor liquido  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk273ParcelaOk( aParcelas  	,nEntrada   ,nFinanciado  	,nValNFat   ,;
                                cTipoOper  	,cCodPagto	,cCodTransp		,cCob		,;
								cEnt		,cCidadeC	,cCepC			,cBairroC	,;
								cBairroE	,cCidadeE	,cCepE			,cUfE       ,;
								cTransp		,oTransp)

Local nCont		:= 0								// Contador
Local nJuros	:= 0								// Total dos juros da condicao escolhida
Local lTmkDados	:= ExistBlock("TMKDADOS")			// P.E. para TLV	
Local lAuxRet	:= .T.								// Retorno auxiliar do P.E. TMKDADOS
Local lRet		:= .T.                              // Retorno da funcao
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o campo condicao de pagamento foi preenchido corretamente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Empty(cCodPagto)
	
	Help(" ",1,"FALTA_PGTO")
	lret := .F.
EndIf


lRet:= TK273ValTrans(cCodTransp,cTransp,oTransp)

	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a Condicao esta bloqueada ou nao       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Empty(cCodPagto) .And. cPaisLoc == "BRA"
	 DbSelectArea("SE4")
	 DbSetOrder(1)
	 If DbSeek(xFilial("SE4")+cCodPagto)
		If SE4->E4_MSBLQL=="1"
			Help(" ",1,"REGBLOQ")
			lRet	:= .F.
		Endif	
	EndIf		
EndIf

If aValores[MERCADORIA] > SE4->E4_SUPER .AND. SE4->E4_SUPER <> 0 .AND. SuperGetMv("MV_CNDPLIM",,"1") == "1"
	Help(" ","1","LJLIMSUPER")
	lRet	:= .F.
ElseIf aValores[MERCADORIA] < SE4->E4_INFER .AND. SE4->E4_INFER <> 0 .AND. SuperGetMv("MV_CNDPLIM",,"1") == "1"
	Help(" ","1","LJLIMINFER")
	lRet	:= .F.
Endif
	
If !Empty(aParcelas)
	
	For nCont := 1 To Len(aParcelas)
		
		nJuros += Round(NoRound(aParcelas[nCont][2],4),2)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe parcela DINHEIRO fora da data     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ("$" $ aParcelas[nCont][3]) .AND. (nCont > 1) .AND. (aParcelas[nCont][1] > dDataBase)
			Help( " ", 1, "NOPRAZO" )
			lRet  := .F.
			Exit
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se as Datas das parcelas estao corretas     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nCont > 1
			If aParcelas[nCont][1] < aParcelas[nCont-1][1]
				Help(" ",1,"DATA_INVAL")
				lRet  := .F.
				Exit
			Endif
		Endif
	Next nCont
	
	If lRet
	   If NoRound(nJuros,2) <> aValores[BASEDUP]
		  Help( " ", 1, "TK010VALOK" )
		  lRet  := .F.
	   Endif
	Endif   
	
	If lRet .AND. cTipoOper == "1"   //Faturamento
	   
		For nCont := 1 To Len(aParcelas)
			If !IsMoney(aParcelas[nCont][3]) .AND. AllTrim(aParcelas[nCont][3]) <> "CH"

				If lUsaTef .AND. (cTipTef <> NIL)
					//Se o atendimento for com TEF e for CLISITEF nao verifica a Administradora, pois a mesma e informada durante a transacao
					If cTipTef <> TEF_CLISITEF
						
						If Empty(aParcelas[nCont][4]) .OR. SUBSTR(aParcelas[nCont][4],1,1) == "*"
							//"Selecione uma administradora financeira para a parcela "
							MsgStop(STR0037+AllTrim(STR(nCont))+".")
							lRet  := .F.
							Exit
						Endif
							
					Endif
				Endif
				
			Endif
		Next nCont
		
	Endif   
Endif

If lRet .AND. lTMKDADOS
	lAuxRet	:= lRet
	
	lAuxRet := U_TMKDADOS(	cCodPagto	,cCodTransp	,cCob		,cEnt		,;
							cCidadeC	,cCepC		,cBairroC	,cBairroE	,;
							cCidadeE	,cCepE		,cUfE		,aParcelas 	)
	If (ValType(lAuxRet) == "L")
		lRet := lAuxRet
	Endif	
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271Data ³ Autor ³ Vendas Clientes       ³ Data ³26/10/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se as parcelas correspondem ao Tipo de pagamento	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK273Data(cComboForma,aParcelas,aItens,dDtParcela)

Local cForma := ""		//Forma de pagamento 
Local nPos   := 0		//Contador
Local lRet	 := .T.		//Retorno da funcao

nPos 	:= Ascan(aItens,{|X| AllTrim(X[1]) == AllTrim(cComboForma) })
If nPos > 0
	cForma 	:= aItens[nPos][2]	//Forma de pagamento no ARRAY 
	If ("$" $ SubStr(cForma,1,2)) .AND. ( Len(aParcelas) <> 1 ) .AND. (dDtParcela > dDataBase)
		Help( " ", 1, "NOPRAZO" )
		lRet := .F.
	Endif
Endif          

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271CompVal   ³ Autor ³ Vendas Clientes      ³ Data ³ 17/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de Verifica‡„o dos valores dae parcelas		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SOMENTE TELEVENDAS 								     		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk273CompVal(aParcelas	, nLiquido	, nVlJur	, cCodPagto	,;
							 cCodAnt    )
Local lRet   := .F.			//Retorno da funcao
Local nTotAux:= 0           //Total das parcelas

If (Len(aParcelas) > 0)
	Aeval(aParcelas,{|aVal|nTotAux+= aVal[2]})	//Soma todas as colunas 2 do aParcelas (valor)
	
	If (nTotAux == nLiquido + nVlJur)
		lRet:= .T.
	Endif
   	
   	If cCodPagto <> cCodAnt
		aParcelas:= {}
		lRet:= .F.
	Endif
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271AtuTransp ³ Autor ³ Vendas Clientes  ³ Data ³16/05/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza o nome da Transportadora na tela de Cond.Pagamento ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273AtuTransp(cCodTransp,cTransp,oTransp)

Local lRet 			:= .F.										//Retorno da funcao
Local lTMKVLDSA4  	:= ExistBlock("TMKVLDSA4")				// P.E. para TLV na validacao do codigo de transportadora - antes da validacao padrao do sistema

cTransp := CRIAVAR("A4_NOME",.F.)

If Empty(cCodTransp)
	lRet := .T.
Else	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida o P.E. antes da validacao padrao do sistema que exige que o codigo da transportadora exista no cadastro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTMKVLDSA4
		lRet := ExecBlock("TMKVLDSA4",.F.,.F.,{cCodTransp})

		If (ValType(lRet) <> "L")
			Return(.F.)
		ElseIf !lRet
			Return(.F.)
		Endif 
	Endif 
	
	lRet:= Tk273ValTrans(cCodTransp,@cTransp,oTransp)	
	
Endif	

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271Estado    ³ Autor ³ Vendas Clientes  ³ Data ³06/11/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida se o usuario informou o ESTADO correto 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SOMENTE TELEVENDAS 								     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273Estado(cUf)
Local lRet := .F.		//Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o Operador preencheu o estado valida o conteudo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cUf)
	DbSelectArea("SX5")
	DbSetOrder(1)
	If DbSeek(xFilial("SX5")+"12"+cUf)
	   lRet := .T.
	Endif
Else
    lRet := .T.
Endif
	
Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271CidC      ³ Autor ³ Vendas Clientes  ³ Data ³27/12/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao para o MUNICIPIO de COBRANCA        			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SOMENTE TELEVENDAS 								     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273CidC(oCidadeC,cCidadeC)

Local lRet 	  := .T.								// Retorno da funcao	
Local aCidC	  := {cCidadeC}							// Cidade de Cobrancao
Local lTMKCIDC:= ExistBlock("TMKCIDC")				// P.E. para TLV

If lTMKCIDC
	lRet 	 := .F.
	cCidadeC := U_TMKCIDC(aCidC)
	If !Empty(cCidadeC)
		lRet := .T.
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao estiver usando a entrada automatica³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTk271Auto
		oCidadeC:Refresh()
	Endif	
Endif

Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271CidE      ³ Autor ³ Vendas Clientes  ³ Data ³27/12/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao para o MUNICIPIO de ENTREGA         			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SOMENTE TELEVENDAS 								     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273CidE(oCidadeE,cCidadeE)
Local lRet 	  := .T.							// Retorno da funcao
Local aCidE	  := {cCidadeE}						// Cidade de Entrega
Local lTMKCIDE:= ExistBlock("TMKCIDE")			// P.E. para TLV

If lTMKCIDE
	lRet	 := .F.
	cCidadeE := U_TMKCIDE(aCidE)
	If !Empty(cCidadeE)
		lRet := .T.
	Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao estiver usando a entrada automatica³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTk271Auto
		oCidadeE:Refresh()
	Endif	
Endif

Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271CepC      ³ Autor ³ Vendas Clientes  ³ Data ³27/12/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao para o CEP de Cobranca              			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SOMENTE TELEVENDAS 								     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273CepC(	cCepC	,oCepC	,cCidadeC	,oCidadeC,;
					cUfC	,oUfC	,cBairroC	,oBairroC)
Local lRet 	  := .T.                  					//Retorno da funcao
Local aCepC	  := {cCepC,cCidadeC,cUfC,cBairroC}			//Cep , Cidade , estado e bairro de Cobranca
Local lTMKCEPC:= ExistBlock("TMKCEPC")					//P.E.		

If lTMKCEPC        
	lRet	:= .F.
	aCepC   := U_TMKCEPC(aCepC)
	cCepC	:= aCepC[1]
	cCidadeC:= aCepC[2]
	cUfC	:= aCepC[3]
	cBairroC:= aCepC[4]
	If !Empty(cCepC)
		lRet	:= .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao estiver usando a entrada automatica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lTk271Auto
			oCepC:Refresh()
			oCidadeC:Refresh()
			oUfC:Refresh()
			oBairroC:Refresh()
		Endif	
	Endif
Endif	
Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271CepE      ³ Autor ³ Vendas Clientes  ³ Data ³27/12/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao para o CEP de Entrega               			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SOMENTE TELEVENDAS 								     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273CepE(	cCepE	,oCepE	,cCidadeE	,oCidadeE,;
					cUfE	,oUfE	,cBairroE	,oBairroE)
					
Local lRet	  := .T.				  				// Retorno da funcao
Local aCepE	  := {cCepE,cCidadeE,cUfE,cBairroE}		// Cep , Cidade , estado e bairro de Cobranca
Local lTMKCEPE:= ExistBlock("TMKCEPE")          	// P.E. do TLV

If lTMKCEPE
	lRet	:= .F. 
	aCepE 	:= U_TMKCEPE(aCepE)
	cCepE 	:= aCepE[1]
	cCidadeE:= aCepE[2]
	cBairroE:= aCepE[4]
	If !Empty(cCepE)
		lRet 	:= .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao estiver usando a entrada automatica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lTk271Auto
			oCepE:Refresh()
			oCidadeE:Refresh()
			oBairroE:Refresh()
		Endif	
    Endif
Endif
    
Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao³Tk271CalcAcre ºAutor  ³Vendas Clientes     º Data ³  06/20/02   º±±
±±ÌÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. ³Preenche o acréscimo de cada produto com o acréscimo da condicaoº±±
±±º      ³de pagamento.                                                   º±±
±±ÌÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.³ExpN1 : - Taxa de acrescimo da condicao de pagamento.           º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk273CalcAcre(nTxJuros, nVlJur)

Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF") 		//Preco fiscal bruto 1=SIM / 2=NAO
Local cAcrescimo:= TkPosto(M->UA_OPERADO,"U0_ACRESCI") 		//Acrescimo 1=ITEM / 2=NAO
Local lRet 		:= .F.                                      //Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o posto de venda nao recalcula o unitario nao pode dar acrescimo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(cAcrescimo) == "2" .AND. (nVlJur > 0 .OR. nTxJuros > 0)   	   // Acrescimo = 2 - Nao
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao estiver usando a entrada automatica³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTk271Auto
		Help( " ", 1, "NAO_ACRESC")
	Endif	
	Return(lRet)
ElseIf AllTrim(cPrcFiscal) == "1"  // Preco Fiscal Bruto NAO (NAO ALTERA O UNITARIO NAO PODE DAR ACRESCIMO)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao estiver usando a entrada automatica³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTk271Auto
		Help( " ", 1, "NAO_ACRESC")
	Endif	
	Return(lRet)
Endif

If Len(aCols) > 0        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Joga o  ACRESCIMO financeiro calculado no campo "Acrescimo" do rodape da tela             ³
	//³Isso e feito assim para que na emissao da NF o SIGAFAT nao calcule duas vezes o acrescimo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aValores[ACRESCIMO] := nVlJur
Endif

lRet := .T.

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA273TipoNove ºAutor  ³Vendas Clientes    º Data ³07/10/02º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Gera as parcelas para venda do tipo 9                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP811                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK273TipoNove(	nOpc		,nLiquido	,nVlJur		,cForma,;
						cE4_COND	,cNumTlv	,aArray9	,lTipo9,;
						lCalcula	,lCancPagto)

Local aArea		:= GetArea()				//Salva a area anterior
Local aHeadAnt 	:= aClone(aHeader)			//Salva o aHeader
Local aColsAnt 	:= aClone(aCols)			//Salva o aCols
Local nAnt		:= n  

Local lTmkTipo9 := ExistBlock("TMKTIPO9")	//Controle de ponto de entrada

Local oDlg									//Tela
Local oGetParc								//Getdados da Parcela
Local nOpcA		:= 0						//Opcao de escolha  OK - CANCELA
Local nLinha	:= 0						//Contador de Linha
Local aTipo9 	:= {}						//Array com as parcelas         
Local nTotal 	:= nLiquido+nVlJur			//Valor Total do pedido	
Local nValParc  := 0						//Valor Total da Parcela
Local nCabeca   := 0						//Tamanho do aHeader
Local nX		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se no TIPO 9  da condicao estiver especificado "%" so ³
//³pode ser preenchido os valores das parcelas em %      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lValor	:= !(AllTrim(cE4_COND) $ "%")			//TRUE - so pode preencher em Dinheiro / FALSE - so pode preencher em %
Local nOpAux    := nOpc
SaveInter()
Private aRotina := {{"Pesquisar", "AxPesqui", 0, 1},;
                    {"Visualizar", "AxVisual", 0, 2},;
                    {"Incluir", "AxInclui", 0, 3},;
                    {"Alterar", "AxAltera", 0, 4},;
                    {"Excluir", "AxDeleta", 0, 5}}

Default lCancPagto := .F.

lCalcula := .F.

aHeader := {}
aCols   := {}
n		:= 1

If lTipo9
	aTipo9 := aArray9
EndIf

If lValor 
	AADD(aHeader,{	STR0054,;					//01 - X3TITULO()            //"Valor da Parcela"
					"L4_VALOR",;							//02 - X3_CAMPO
					PesqPict("SL4","L4_VALOR"),;   			//03 - X3_PICTURE
				    TamSX3("L4_VALOR")[1]     ,;			//04 - X3_TAMANHO
					TamSX3("L4_VALOR")[2]     ,;			//05 - X3_DECIMAL
					"Positivo()",;							//06 - X3_VALID
					"€‚€€€€€€€€€€€€"+chr(65533),;						//07 - X3_USADO
					"N",;									//08 - X3_TIPO
					"",;									//09 - X3_ARQUIVO
					"" 	} )									//10 - X3_CONTEXT
Else
	AADD(aHeader,{	STR0055,;								//01 - X3TITULO()		//"Percentual da Parcela"
					"L4_COMP",;								//02 - X3_CAMPO
					"@E 999.99",;							//03 - X3_PICTURE
					5,;										//04 - X3_TAMANHO
					2,;										//05 - X3_DECIMAL
					"Positivo()",;							//06 - X3_VALID
					"€‚€€€€€€€€€€€€"+chr(65533),;						//07 - X3_USADO
					"N",;									//08 - X3_TIPO
					"",;									//09 - X3_ARQUIVO
					"" 	} )									//10 - X3_CONTEXT
Endif
				
AADD(aHeader,{	STR0056,;												//01 - X3TITULO()		//"Data"
				"L4_DATA",;												//02 - X3_CAMPO
				"",;													//03 - X3_PICTURE
				8,;														//04 - X3_TAMANHO
				0,;														//05 - X3_DECIMAL
				"NaoVazio()",;											//06 - X3_VALID
				"€‚€€€€€€€€€€€€"+chr(65533),;										//07 - X3_USADO
				"D",;													//08 - X3_TIPO
				"",;													//09 - X3_ARQUIVO
				"" 	} )													//10 - X3_CONTEXT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se as parcelas devem ser recalculadas  ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lCalcula)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array com 1 elemento vazio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols := Array(1, Len(aHeader) + 1)
	aCols[1][1] := 0
	aCols[1][2] := CTOD("")
	aCols[1][3] := .F.			//Linha de controle de DELECAO
	
	nOpAux := 3
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for inclusao  ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf (nOpc == 3) 
	If Len(aTipo9) > 0 
	   
	   nCabeca := Len(aHeader)+1
	   For nLinha := 1 TO LEN(aTipo9)
	   		Aadd(aCols,{ 0,CTOD(""),.F. })
	       	aCols[nLinha][1] := IIF(lValor,aTipo9[nLinha][2],aTipo9[nLinha][5])  //Valor, Percentual
	       	aCols[nLinha][2] := aTipo9[nLinha][1]  //Data
	       	aCols[nLinha][3] := .F.
	   Next nLinha
	
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Na inclusao Monta o Array com 1 elemento vazio³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCols := Array(1, Len(aHeader) + 1)
		aCols[1][1] := 0
		aCols[1][2] := CTOD("")
		aCols[1][3] := .F.			//Linha de controle de DELECAO
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alteracao - Visualizacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Elseif (nOpc == 4)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta as parcelas de acordo com a condicao de pagamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValParc  := 0
	nLinha 	  := 0
	DbSelectArea("SL4")
	DbSetOrder(1)
	DbSeek(xFilial("SL4")+cNumTlv+"SIGATMK ")
	While (!SL4->(Eof())) .AND. (xFilial("SL4") == SL4->L4_FILIAL) 		.AND. ;
						 (SL4->L4_NUM == cNumTlv) 					.AND. ;
						 (AllTrim(SL4->L4_ORIGEM) == "SIGATMK") .AND. Empty(aTipo9)
							 
		nLinha++
   		Aadd(aCols,{ 0,CTOD(""),.F. })

		aCols[nLinha][1] := IIF(lValor,SL4->L4_VALOR,IIf(Empty(SL4->L4_COMP),((SL4->L4_VALOR/SUA->UA_VLRLIQ) * 100),Val(SL4->L4_COMP)))
		aCols[nLinha][2] := SL4->L4_DATA
		aCols[nLinha][3] := .F.			//Linha de controle de DELECAO
	
		nValParc += SL4->L4_VALOR

		SL4->(DbSkip())
	End
	If lTipo9 .And. Len(aCols) == 0 .And. !Empty(aTipo9)
		For nX := 1 To Len(aTipo9)
			Aadd(aCols,{ 0,CTOD(""),.F. })
			aCols[nX][1] := aTipo9[nX][5]	//Percentual da parcela
			aCols[nX][2] := aTipo9[nX][1]	//Data de vencimento
			aCols[nX][3] := .F.				//Linha de controle de DELECAO
		Next nX
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para possibilitar alteracao do acols e troca da opcao da operacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTmkTipo9
	nOpAux := ExecBlock("TMKTIPO9",.F.,.F.,{nOpAux} )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Protecao para retorno do ponto de entrada                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Valtype(nOpAux) <> "N"
		nOpAux    := nOpc	
	Endif
		
Endif	

n := Len(aCols)
If !lCancPagto .OR. lTipo9
	DEFINE MSDIALOG oDlg FROM 10,20 TO 200,450 TITLE STR0034 PIXEL //"Valor da Parcela e Vencimento"

		oGetParc := MSGetDados():New(01,02,80,215,nOpAux,{|| Tk273ParcLin(lValor)},"AlwaysTrue","",.T.,,,.F.,SuperGetMv("MV_NUMPARC"))
		oGetParc:oBrowse:bDelete:={ || aCols[n,Len(Acols[n])]:=!aCols[n,Len(aCols[n])],"AlwaysTrue",oGetParc:oBrowse:Refresh(.F.)}
		oGetParc:oBrowse:Refresh(.T.)
		
		DEFINE SBUTTON FROM 81,150 TYPE 1 ACTION (nOpcA := 1,IIF(Tk273ValTp9(nTotal,lValor,@aTipo9,cForma),oDlg:End(),nOpcA:=0)) ENABLE OF oDlg
		
		DEFINE SBUTTON FROM 81,185 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTER

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o Operador nao confirmou as parcelas da condicao - limpa o retorno do array ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nOpcA <> 1
		If Len(aArray9) == 0
				AADD(aTipo9,{	dDataBase	,;	// 1 - Data
								nTotal		,;	// 2 - Valor
								cForma		,;	// 3 - Forma de Pagamento	
								Space(80)	,;	// 4 - Complemento
								0			,;	// 5 - Valor R$ ou %
								Space(01)	})	// 6 - ID Cartao (para visualiz. sintetica)
		Endif				
	Endif
EndIf
aHeader	:= aClone(aHeadAnt)
aCols 	:= aClone(aColsAnt)
n		:= nAnt

RestArea(aArea)
RestInter()
Return(aTipo9)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk273ParcLinºAutor  ³Vendas Clientes   º Data ³  07/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Validacao da linha da GETDADOS das parcelas do tipo 9       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TELEVENDAS                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273ParcLin(lValor)

Local lRet := .F.		//Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for uma linha valida³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !aCols[n][Len(aHeader)+1]
	If (aCols[n][1] == 0)
		If lValor //Se for TRUE indica que apenas os valores em DINHEIRO podem ser preenchidos
			Help(" ",1,"TMKTIP901" ) //"Informe o valor em Dinheiro porque essa é uma regra da condição de pagamento escolhida"
		Else	//Se apenas os valores em PERCENTUAL pode ser preenchidos
			Help(" ",1,"TMKTIP902" ) //"Informe o valor em % porque essa é uma regra da condição de pagamento","Atenção")
		Endif
		Return(lRet)
	Endif

	If Empty(aCols[n][2]) .OR. (aCols[n][2] < dDataBase)
		Help(" ",1,"TMKTIP903" ) //"A data esta incorreta"
		Return(lRet)
	Endif
Endif

lRet := .T.

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk273ValTp9 ºAutor  ³Vendas Clientes   º Data ³  07/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Validacao da linha da GETDADOS das parcelas do tipo 9       º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP811                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk271Pagamento(ExpN1, ExpL2,	 ExpA3,	 ExpC4)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor total do parcelamento.                  	  ³±±
±±³          ³ ExpL2 = Se esta em valor ou em porcentagem            	  ³±±
±±³          ³ ExpA3 = Array com o valor e a data das parcelas       	  ³±±
±±³          ³ ExpC4 = Forma de pagamento utilizada nas parcela      	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Sempre retorna .T. (Verdadeiro)                       	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk273ValTp9(nTotal,lValor,aTipo9,cForma)

Local lRet	 		:= .F.			// Retorno da funcao
Local nLinha 		:= 0  			// Contador da Linha
Local nValParc 		:= 0 			// Valor de cada parcela informada em % ou R$
Local nValTotal		:= 0 			// Valor total das parcelas informadas pelo Operador
Local dData			:= dDatabase	// Data Inicial
Local nLenAux  		:= LEN(aCols)	// Contador auxiliar para o FOR
Local nResto 		:= 0			// Diferenca entre o valor total e a somatoria das parcelas
Local nUltLinha		:= 1			// Número da última linha válida
Local cParcela  	:= "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
Local nParcelas 	:= GETMV("MV_NUMPARC")
Local cChave 		:= ""
Local cChave1		:= ""  
Local nDecE1Vlr 	:= TamSX3( "E1_VALOR"  )[2]
Local i				:= 0
Local cE4_COND		:= ""
Local cE4_IPI		:= ""
Local cE4_SOLID		:= ""
Local nValTot 		:= 0
Local nSomaTp9 		:= 0
Local nValPed 		:= 0
Local nValIPI 		:= MaFisRet(,"NF_VALIPI")
Local nValSolid 	:= MaFisRet(,"NF_VALSOL")
Local nValor 		:= 0
Local nAcrescimo	:= aValores[ACRESCIMO]

If nParcelas > 4
	cChave := "C5_DATA"+Subs(cParcela,nParcelas,1)
	cChave1:= "C5_PARC"+Subs(cParcela,nParcelas,1)
	aAreaSX3 := SX3->(GetArea())
	
	DbSelectArea("SX3")
	DbSetOrder(2)
	If !DbSeek(cChave) .or. !DbSeek(cChave1)
		Help(" ",1,"TMKTIP905") //"A quantidade de parcelas nao esta compativel. Verificar junto ao administrador do sistema relacao entre parametro MV_NUMPARC e dicionario de dados"
		Return(lRet)        
	EndIf
	
	Restarea(aAreaSX3)
	
EndIf

aTipo9 := {}  //Array com os valores das parcelas 

For nLinha := 1 TO nLenAux

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a linha estiver habilitada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aCols[nLinha][Len(aHeader)+1]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida a Data informada ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(aCols[nLinha][2]) .OR. (aCols[nLinha][2] < dDataBase)
			Help(" ",1,"TMKTIP903" ) //"A data esta incorreta"
			Return(lRet)
		Endif
	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida Data da ultima parcela ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If nLinha > 1
		    dData := aCols[nUltLinha][2]
		Endif
		    
		If (aCols[nLinha][2] < dData)
			Help(" ",1,"TMKTIP904" ) //"As datas das parcelas precisam ser crescentes","Atenção")
			Return(lRet)
		Endif	

		If Empty(aCols[nLinha][1]) 
			MsgStop(STR0036)//"Não foi informado o valor da parcela." 
			Return(lRet)
		Endif

		nValParc := 0
		If lValor
			nValParc := aCols[nLinha][1]
		Else
			nValParc := A410Arred((nTotal * aCols[nLinha][1]) / 100,"UB_VRUNIT")
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando a parcela e informada em % esse valor e convertido ³
		//³para VALOR (R$) para que entre nas Parcelas da condicao   ³
		//³de pagamento                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aTipo9,{	aCols[nLinha][2],;		// 1 - Data
						nValParc,;				// 2 - Valor 
						cForma,;				// 3 - Forma 
						SPACE(80),;				// 4 - Complemento
						aCols[nLinha][1],;		// 5 - % ou R$
						space(01)})				// 6 - ID Cartao (visualiz. sintetizada)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se os valores forem em VALOR³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lValor
			nValTotal += aCols[nLinha][1]
		Else	
			nValTotal += A410Arred(aCols[nLinha][1],"UB_VRUNIT")
		Endif       
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza a variável com a última linha válida.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nUltLinha := nLinha
	Endif
	
Next nLinha
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para condição de pagamento Tipo9 definido como % e  ¿
//³ quando possuir IPI e ICMS-ST = Junta (pois tipo 9 so mermite   ¿
//³ utilizar "Junta" quanfo for definido em porcentagem (%) )      ¿
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Valor Total das Parcelas
If !lValor 
	cE4_COND	:= SE4->E4_COND
	cE4_IPI		:= SE4->E4_IPI
	cE4_SOLID	:= SE4->E4_SOLID
	cE4_ACRES	:= SE4->E4_ACRES
	nValTot 	:= nTotal			//Valor Total do parcelamento 
	For i:= 1 to Len(aTipo9)
		nValPed += aTipo9[i][5]		//Percentual das parcelas
	Next i
	For i:= 1 to Len(aTipo9)
		cCpoParc := ""
		nValParc := aTipo9[i][5]	//Percentual das parcelas
		dDtParc  := aTipo9[i][1]
		If !Empty(dDtParc) .And. !Empty(nValParc)
			If Trim(cE4_COND) == "%"
				If i == 1
					If cE4_IPI == "J"
						nSomaTp9 := nValIPI
						nValTot -= nValIPI
					EndIf
					If cE4_SOLID == "J"
						nSomaTp9 += nValSolid
						nValTot -= nValSolid
					EndIf
					If cE4_ACRES == "J"
						nSomaTp9 += nAcrescimo
						nValTot  -= nAcrescimo
					EndIf	
				Else
					nSomaTp9 := 0
				EndIf
				If nValPed > 100
					nValor := nValTot * (((nValParc/nValPed)*100) / 100 )
				Else
					nValor := nValTot * (nValParc / 100 )
				EndIf
				nValor += nSomaTp9
			Else
				// achar o % referente ao valor
				nValor := nValParc / nValPed
				nValor := nValTot * nValor
				// os quant. presentes em C5_PARCn referem-se a valores
				nValor := IIf(Abs(nValor - nValParc ) <= 1, nValParc, nValor)
			EndIf
			aTipo9[i][2] := nValor
		EndIf
	Next i
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Soma novamente o total das parcelas e joga a diferenca na ³
//³ultima parcela.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValParc:= 0
nLenAux	:= Len(aTipo9)
For nLinha := 1 TO nLenAux    
	aTipo9[nLinha][2] := NoRound(aTipo9[nLinha][2], nDecE1Vlr )
	nValParc += aTipo9[nLinha][2]   
Next nLinha

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o Acols esta em VALOR.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nResto := 0
nResto := nTotal - nValParc
If (nResto <> 0)
	nValParc += nResto
	If Len(aTipo9) > 1
		aTipo9[Len(aTipo9)][2]+= nResto
	Endif
Endif

If NoRound(nTotal,2) <> NoRound(nValParc,2)
	Help(" ",1,"TK010VALOK" ) //"O total das parcelas nao está correto"
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se condicao de pagamento calcular em Percentual, verifico  ³
//³se os percentuais informados somam 100%, caso seja em valor³
//³verifico se a soma das parcelas batem com o total.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lValor
	If nValTotal <> 100
		Help( " ", 1, "TK010VALOK" )
		Return(lRet)
	Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a somatoria das parcelas for <> que o valor total do ³
//³atendimento.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nValTotal <> nTotal 
	Help( " ", 1, "TK010VALOK" )
	Return(lRet)
Endif

lRet := .T.

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk273DetSintºAutor³ Vendas Clientes 	 º Data ³ 09/11/05    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Prepara o array aParcelas para ser tratado em uma nova tela,º±±
±±º          ³pois na principal sera exibida a Sintetizada.  		      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TeleVendas                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273DetSint(	aParcelas	,oParcelas	,aItens		,lHabilita,;
						nLiquido	,nEntrada	,oEntrada	,nFinanciado,;
						oFinanciado	,cCodPagto	,lSigaCRD	,oDlgPagto) 

Local lContinua	  := .T.							   					  // Laco para o controle da abertura de tela
Local lConfirma   := .F.												  // Indica se o operador confirmou a alteração das parcelas
Local nPos		  := 0													  // Identifica a posicao da informacao no Array
Local oDlgPgtoSin									 					  // Objeto para tratamento da janela
Local lTefMult	  := SuperGetMV("MV_TEFMULT")	   						  // Parametro do SX6 que indica se o sistema vai o TEF multiplas transacoes
Local oGetFormas 								   						  // Objeto GET para informar nr. de formas de pagto e/ou cartoes (Mult. transacoes)
Local nFormas	:= 0							   						  // Variavel que guarda o nr. de formas de pagto e/ou cartoes (Mult. transacoes)
Local lHomol	:= ExistBlock("LJHOMTEF") .AND. LjMSSM0(SM0->M0_CGC)  	  // Indica que esta fazendo homologacao na Software Express p/ nao exibir as parcelas
Local nNrParc	:= 0								  					  // Nr. de parcelas
Local cForma	:= ""								 					  // Forma de pagto (CC,CH,$)
Private oPgtosAna									 				  	  // Copia do Objeto oParcelas que sera aberto em outra tela
  
If Len(aPgtosSint) > 0
	nNrParc := aPgtosSint[1][2]
	cForma	:= aPgtosSint[1][1]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao exibir as parcelas durante a Homologacao na Soft. Express ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nNrParc > 1 .AND. lHomol
		Return nil
	Endif
Endif
        
While lContinua

	lConfirma := .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria interface com o usuario                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgPgtoSin TITLE STR0022 FROM 0,0 TO 20,50 OF oDlgPagto //"Detalhes da Forma de Pagamento"
	
		DEFINE SBUTTON FROM 136,170	TYPE 1 ACTION (lConfirma := .T. , oDlgPgtoSin:End()) ENABLE
		
		oPgtosAna	:= TCBrowse()	:New( 5, 5, 190, 125,;
									 Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,,,,,,,,, .T. )
	
		oPgtosAna:bLDblClick	:= {|| Tk273Detalhe(@aParcelas	,oParcelas	,@aItens	,lHabilita,;
													nLiquido	,@nEntrada	,oEntrada	,@nFinanciado,;
													oFinanciado	,cCodPagto	,lSigaCRD)  }
	
		oPgtosAna:SetArray( aParcelas )
		
		nPos 			:= Ascan(aParcelas, { |x| ( AllTrim(x[3]) == AllTrim(aPgtosSint[oPgtosSint:nAt][1]) ) })
		oPgtosAna:nAt 	:= Iif(nPos>0,nPos,oPgtosAna:nAt)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lTk271Auto
			oPgtosAna:Refresh()	
			oPgtosAna:SetFocus()
		Endif

		ADD COLUMN TO oPgtosAna HEADER STR0011 OEM DATA	{|| DTOC(aParcelas[oPgtosAna:nAt,1]) }							ALIGN LEFT SIZE 40 PIXEL //"Data" 
		ADD COLUMN TO oPgtosAna HEADER STR0012 OEM DATA {|| Transform(aParcelas[oPgtosAna:nAt,2],"@E 999,999,999.99")}	ALIGN LEFT SIZE 55 PIXEL //"Valor"
		ADD COLUMN TO oPgtosAna HEADER STR0013 OEM DATA {|| aParcelas[oPgtosAna:nAt,3] } 								ALIGN LEFT SIZE 40 PIXEL //"Forma" 
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ So inserir a coluna ID Cartao quando o cliente trabalhar com multiplas transacoes TEF ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	lUsaTef 	.AND.;
			lTefMult 	.AND.;
			lVisuSint
			// ID Cartao (6)
			ADD COLUMN TO oPgtosAna HEADER STR0042 OEM DATA { || aParcelas[oPgtosAna:nAt,6] } 	ALIGN LEFT  SIZE 20 PIXEL //"ID Cartao"
		Endif			
		
		If 	lUsaTef .AND. lTefMult .AND.;
			lVisuSint .AND. nNrParc == 1 .AND. cForma == "CC"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Get de Nr. de cartoes p/ pagto com multiplos cartoes ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ 136,10 SAY STR0048 OF oDlgPgtoSin PIXEL	//"Nr. cartões: "
			@ 136,60 GET oGetFormas VAR nFormas Picture "@99" SIZE 30,8 PIXEL OF oDlgPgtoSin VALID Tk273AtuParc(nFormas,aParcelas,oPgtosAna,nLiquido)
		EndIf
		
	ACTIVATE MSDIALOG oDlgPgtoSin CENTERED
	
	If lConfirma
		oParcelas:SetArray(aParcelas)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lTk271Auto
			oParcelas:Refresh()
		Endif	

		aPgtosSint := Tk273MontPgt( aParcelas )
		oPgtosSint:SetArray( aPgtosSint )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lTk271Auto
			oPgtosSint:Refresh()
    	Endif
    	
		lContinua := .F.
	Endif
End

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk273AtuPaºAutor  ³Vendas Clientes      º Data ³  24/04/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza o array de parcelas conforme nr. de cartoes infor- º±±
±±º          ³ mados (usada somente em Multiplas Transacoes TEF)           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpN1: Nr. de cartoes/formas                                º±±
±±º          ³ ExpA2: Array de Parcelas                                    º±±
±±º          ³ ExpO3: Objeto com as parcelas calculadas                    º±±
±±º          ³ ExpN4: Valor liquido da venda                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TeleVendas                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273AtuParc(nFormas, aParcelas, oPgtosAna, nLiquido)

Local lRet 		:= .T.		//Indica o retorno da funcao
Local nValTotal := 0		//Valor total da venda
Local nValParc  := 0		//Valor das parcelas
Local nI 		:= 1    	//Variav. usada em lacos For...Next
Local nVlrTotParc:=0		//Totalizador das parcelas

If nFormas <= 0
	MsgStop(STR0049,STR0046) //"O valor deve ser maior que zero!"
	lRet := .F.
Endif          

If lRet
	//Total da venda
	nValTotal := nLiquido
	aParcelas := {}	
	
	//Valor de cada parcela
	nValParc :=  nValTotal / nFormas	
	
	//Gera as novas parcelas
	For nI := 1 To nFormas
		aAdd(aParcelas, {	dDataBase	, A410Arred(nValParc,"UB_VRUNIT")	, "CC"	, ""	,;
							0			, StrZero(nI,1) 					})
	Next nI
    
    //Acerta eventuais diferencas por arredondamento 
	aEval( aParcelas, { |x| nVlrTotParc += x[2] } )
	If nValTotal <> nVlrTotParc .AND. Len(aParcelas) >= 1
		aParcelas[1][2] += (nValTotal - nVlrTotParc)
	Endif    
    
    oPgtosAna:SetArray(aParcelas)
	If !lTk271Auto
		oPgtosAna:Refresh()
	EndIf
    
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk273MontPgt³ Autor³ Vendas Clientes       ³ Data ³09/11/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Prepara a array sintetizada para exibição                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CALL CENTER - TeleVendas                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk273MontPgt( aParc )

Local nFor 	 		:= 0															// Usada em lacos For...Next
Local cCond  		:= ""															// Forma Pagto (CC,CH)
Local nValor 		:= 0    														// Valor da parcela
Local nParc	 		:= 0   															// Nr. de parcelas		
Local cFormaId 		:= IIf(lVisuSint,Space(TamSX3("L4_FORMAID")[1]),Space(01))		// Id do cartao
Local nPos	 		:= 0															// Posicao dentro do array
Local aParcSint		:= {}															// Array construido com as parcelas sinteticas
Local aSequencia	:= {}															// Array auxiliar do aParc	
Local cSimbMoeda	:= SuperGetMv("MV_SIMB"+Ltrim(Str(nMoedaCor)))						// Simbolo da moeda

DEFAULT aParc	  	:= {}	//Array com as parcelas a sintetizar

// Verifica se a aPgtos ou a aDados esta zerada
If Len(aParc) == 1 .AND. aParc[1][2] == 0
	aParcSint := { {Space(02)	,;
					0			,;
					TransForm(0,PesqPict("SL4","L4_VALOR",,nMoedaCor)),;
					Space(TamSX3("L4_FORMAID")[1]),;
					Ctod(Space(8)),;
					{}}}

//Efetua o tratamento para a sintetizacao das informacoes
ElseIf Len(aParc) > 0
	aParcSint := {}						//Limpa o array para soma dos valores sintetizados

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera array sintetico de acordo com a quantidade de cartoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nFor:= 1 To Len(aParc)

		// Forma Pagto (CC,CH,CD etc)
		cCond  		:= AllTrim(aParc[nFor][3])
		                             
		// ID Cartao
		cFormaId 	:= aParc[nFor][6]
		nPos		:= Ascan(aParcSint, { |x| ( AllTrim(x[1]) == cCond .AND. AllTrim(x[4]) == AllTrim(cFormaId) ) })
		If nPos > 0
			aParcSint[nPos][2] := aParcSint[nPos][2] + 1				//Parcela
			aParcSint[nPos][3] := aParcSint[nPos][3] + aParc[nFor][2]	//Valor
		Else
			nParc	:= 1
			nValor	:= aParc[nFor][2]
			Aadd( aParcSint , {	cCond			, nParc	, nValor	, cFormaId	,;
								aParc[nFor][1]	, {}  	})
		Endif
		
    	Aadd( aSequencia , {nFor , cCond , nValor, cFormaId} )
	Next nFor

	// Atualizando a sequencia para a array aParc
	For nFor := 1 To Len(aParc)
		
		nPos := Ascan(aSequencia,{|x| x[1] == nFor})
		If nPos > 0
			aParc[nFor][6] := aSequencia[nPos][4]
		Endif
		
	Next nFor

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Formata na Picture do L4_VALOR³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nFor := 1 to Len(aParcSint)
		aParcSint[nFor][3] := TransForm(aParcSint[nFor][3],PesqPict("SL4","L4_VALOR",,nMoedaCor))
	Next nFor
Endif

aSort( aParcSint,,, {|x,y| Dtos(x[5])+x[1]+x[4] < Dtos(y[5])+y[1]+y[4] } ) //Data + Cond + Seq.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A Forma $ sempre sera a primeira!!!  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nPos := Ascan(aParcSint, {|x| x[1] == cSimbMoeda})) > 1
	aAdd(aParcSint,{})
	aIns(aParcSint,1)
	nPos++
	aParcSint[1] := aParcSint[nPos]
	aDel(aParcSint, nPos)
	aSize(aParcSint,Len(aParcSint)-1)
Endif

Return(aParcSint)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK273WhenID  ºAutor ³ Vendas Clientes  º Data ³  10/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se e necessaria a digitacao do digito de controle º±±
±±º          ³ de cartoes                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - Televendas                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                           
Static Function TK273WhenID(nLinha,cForma,cFormaID,aItens)

Local lRet 		:= .F.	// Variavel de retorno da funcao
Local nPos 		:= 0	// Posicao localizada no array

nPos := Ascan(aItens,{|x| AllTrim(Upper(x[2]))==AllTrim(Upper(cForma))})	
If nPos > 0
	If AllTrim(Upper(aItens[nPos][2])) $ _FORMATEF
		lRet := .T.
	Else
		If lVisuSint
			cFormaID := Space(TamSX3("L4_FORMAID")[1])
		Else
			cFormaID :=	Space(01)
		Endif
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK273ValidID ºAutor ³ Vendas Clientes  º Data ³  10/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o digito informado e correto para o controle de  º±±
±±º          ³ multiplos cartoes                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1: Forma a ser localizada                              º±±
±±º          ³ ExpC2: ID do cartão para a operação TEF                    º±±
±±º          ³ ExpA3: Formas selecionadas                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpL1: .T. se o digito é validado                          º±±
±±º          ³        .F. se o digito não é validado                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - Televendas                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                           
Static Function TK273ValidID(cForma,cFormaID,aItens)

Local lRet 	 := .T.			// Retorno da funcao
Local nPos 	 := 0 			// Posicao localizada no array
Local cCond  := Space(02)	// Forma de pagto TEF

nPos := Ascan(aItens,{|x| AllTrim(Upper(x[2])) == AllTrim(Upper(cForma))})	// Posicao localizada no array
If nPos > 0
	cCond := AllTrim( Upper(aItens[nPos][2]) )
Endif	

If cCond $ _FORMATEF
	If Empty(cFormaId)
		MsgAlert(STR0045,STR0046) //"Informe o ID do Cartao para a operacao TEF.","Atencao"
		lRet := .F.
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk273ReFilºAutor  ³Vendas Clientes      º Data ³  25/04/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Altera os valores das parcelas para que nao haja inconsis-  º±±
±±º          ³ tencia nas mesmas.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpN1: Parcela Alterada                                     º±±
±±º          ³ ExpN2: Total das parcelas                                   º±±
±±º          ³ ExpA3: Array de parcelas                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TeleVendas                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273ReFill( nParcAlt, nTotParc, aParcelas )

Local nI		:= 0								//Variavel de apoio
Local nTotTemp 	:= 0								//Total das parcelas menos o valor da parcela alterada e das anteriores
Local nVlrTemp	:= 0								//Valor das parcelas que nao foram alteradas
Local nNumParc	:= Len( aParcelas ) - nParcAlt		//Numero de parcelas que serao alteradas (Somente a partir da parcela atual)

If nParcAlt <> Len( aParcelas ) .OR. Len( aParcelas ) == 1
	nTotTemp := nTotParc
	For nI := 1 To nParcAlt
		nTotTemp -= aParcelas[nI][2]					//Soma o valor das parcelas que nao sofrerao alteracao
	Next nI
	
	nVlrTemp	:= nTotTemp / nNumParc					//Calcula o novo valor das parcelas
	
	For nI := nParcAlt+1 To Len( aParcelas )
		aParcelas[nI][2] 	:= A410Arred( nVlrTemp, "UB_VRUNIT" )
		nTotTemp 			-= A410Arred( nVlrTemp, "UB_VRUNIT" )
	Next nI
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK273RecCpg  ºAutor  ³Vendas Clientes  º Data ³  27/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recalcula o valor dos juros sobre o total de acordo com a   º±±
±±º          ³condicao de pagamento atual (M->UA_CONDPG).                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCond - Codigo da Condicao de Pagamento utilizada.         º±±
±±º          ³         Default = M->UA_CONDPG (campo da Enchoice)         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ nVlJur - Total de juros calculado                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273RecCpg( cCond, lValidPgto, nLinha, nVlrAItem )

Local aArea		:= GetArea()					// Armazena tabela, indice e recno atual
Local aAreaSE4	:= SE4->(GetArea())			// Armazena indice e recno atual da SE4
Local nTxJuros	:= 0							// Taxa de juros para a condicao de pagamento atual
Local nVlJur	:= 0							// Valor dos juros sobre o total da venda
Local nJurUnit	:= 0							// Valor dos juros sobre o preco unitario
Local nLiquido 	:= 0							// Valor liquido do atendimento
Local i			:= 0							// Contador de laco
Local lTKVDACR	:= Iif(SuperGetMV("MV_TMKLOJ",,.F. )== "S" .And. GetNewPar("MV_TKVDACR",.F.),.T.,.F.)	//Se possuir integração com o SIGALOJA, faz o cálculo do acrescimo sobre o total menos o desconto.
Local cAgregaValor 
Local nPosTES	:= GDFieldPos("UB_TES")
Local nAcresFin := 0

 
Default cCond	  	:= M->UA_CONDPG				// Condicao de pagamento digitada na Enchoice
Default lValidPgto	:= .F.
Default nLinha		:= 0 
Default nVlrAItem	:= 0

DbSelectArea("SE4")
DbSetOrder(1)

If DbSeek(xFilial("SE4")+cCond)
	
	nTxJuros := SE4->E4_ACRSFIN
	nLiquido := aValores[BASEDUP] - aValores[ACRESCIMO]
	
	If nLiquido > 0 .Or. nTxJuros > 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo dos juros para atualizar o ACRESCIMO e o valor TOTAL do atendimento. ³
		//³Para compatibilizar com o Faturamento, calcula o acrescimo a partir do preco ³
		//³unitario, arredonda e depois multiplica pela quantidade vendida, arredondando³
		//³novamente.                                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For i := 1 to Len( aCols )   

			cAgregaValor := ''    
			DbSelectArea("SF4")
			DbSetOrder(1)                            
	   		If DbSeek(xFilial("SF4")+ aCols[i][nPosTES])
				cAgregaValor := SF4->F4_AGREG
			Endif
		
		
			If !GDDeleted(i) .And. cAgregaValor <> 'N'	// Se a linha nao estiver deletada
				nJurUnit  := A410Arred(GDFieldGet("UB_VRUNIT",i) * SE4->E4_ACRSFIN / 100,"UB_VRUNIT")
				nAcresFin := A410Arred(GDFieldGet("UB_QUANT" ,i) * nJurUnit,"UB_VLRITEM")
				nVlJur	  += nAcresFin

				If nLinha == i
					nVlrAItem := nAcresFin
				Endif							
			EndIf

		Next i

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando possuir integração com o SIGALOJA, calcula o acrescimo sobre o 	³
		//³total menos o desconto. ((TOTAL - DESCONTO) + ACRESCIMO)					³
		//³A regra utilizada por padrão no Faturamento e no Televendas é a seguinte:³
		//³((TOTAL + ACRESCIMO) - DESCONTO)                                        	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If lTKVDACR .And. M->UA_OPER == "2" .And. !lValidPgto 		//Orçamento
			nVlJur := (A410Arred(nVlJur,"UB_VLRITEM") - A410Arred(aValores[DESCONTO]*SE4->E4_ACRSFIN/100, "UB_VRUNIT"))
		Else
			nVlJur := A410Arred(nVlJur,"UB_VLRITEM")
		EndIf

		Tk273CalcAcre(nTxJuros, nVlJur)

	EndIf

	

EndIf

RestArea(aAreaSE4)
RestArea(aArea)

Return nVlJur


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk273Trans     ³ Autor ³Vendas Clientes   ³ Data ³09/08/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Encapsulamento do ponto de entrada TMKTRANS:                ³±±
±±³          ³Atualiza dados referentes a transporte e endereco de entrega³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da transportadora                           ³±±
±±³          ³ ExpC2 = Nome da transportadora                             ³±±
±±³          ³ ExpC3 = Codigo da condicao de pagament                     ³±±
±±³          ³ ExpC4 = Descricao da condicao                              ³±±
±±³          ³ ExpC5 = Endereco de entrega                                ³±±
±±³          ³ ExpC6 = Bairro de entrega                                  ³±±
±±³          ³ ExpC7 = Cidade de entrega                                  ³±±
±±³          ³ ExpC8 = CEP de entrega                                     ³±±
±±³          ³ ExpC9 = Estado de entrega                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk273Trans(	cCodTransp	, cTransp	, cCodPagto	, cDescPagto,;
							cEnt		, cBairroE	, cCidadeE	, cCepE		,;
							cUfE		)

Local nCont		:= 0													// Contador auxiliar para loop
Local aArea		:= GetArea()											// Armazena tabela, indice e recno atual
Local lTmkTrans := ExistBlock("TMKTRANS")								// P.E. para permitir escolha da transportadora e dados de entrega
Local aRetTrans := {cCodTransp	, cCodPagto	, cEnt		, cBairroE	,;	// Retorno no P.E. TMKTRANS com a seleção da transportadora de acordo com as regras de negócio específicas
					cCidadeE	, cCepE		, cUfE		}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para permitir ao usuario escolher a   ³
//³transportadora e dados de entrega de acordo com alguma ³
//³regra de negocio especifica.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTmkTrans

	aRetTrans := U_TMKTRANS(aRetTrans)
	
	If Len(aRetTrans) > 0
		cCodTransp := aRetTrans[1]
		If Len(aRetTrans) >= 2
			cCodPagto := aRetTrans[2]
		Endif	
	Endif	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o retorno do array aRetTrans e valido e contem as 	   ³
	//³informacoes para preenchimento dos dados de entrega. 			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aRetTrans) >= 3
		For nCont:=3 to Len(aRetTrans)
			If ValType(aRetTrans[nCont]) <> "C"
				Loop
			Else 
				Do Case
					Case nCont == 3 .AND. !Empty(aRetTrans[nCont])
						cEnt:=aRetTrans[nCont]					
					Case nCont == 4 .AND. !Empty(aRetTrans[nCont])
						cBairroE:=aRetTrans[nCont]
					Case nCont == 5 .AND. !Empty(aRetTrans[nCont])
						cCidadeE:=aRetTrans[nCont]
					Case nCont == 6 .AND. !Empty(aRetTrans[nCont])
						cCepE:=aRetTrans[nCont]
					Case nCont == 7 .AND. !Empty(aRetTrans[nCont])
						cUfE:=aRetTrans[nCont]
				Endcase
			Endif	
		Next nCont
	Endif
EndIf

DbSelectArea("SE4")
DbSetOrder(1)
If DbSeek(xFilial("SE4")+ cCodPagto )
	cDescPagto:= SE4->E4_DESCRI
Endif

DbSelectArea("SA4")
DbSetOrder(1)
If DbSeek(xFilial("SA4") + cCodTransp)
	cTransp		:= SA4->A4_COD+"-"+SA4->A4_NOME
Endif

RestArea(aArea)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK273VCondºAutor  ³Vendas Cliente      º Data ³  12/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recalcula os juros da condicao de pagamento e atualiza o    º±±
±±º          ³rodape com os totais.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER - Televendas                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK273VCond(lOperacao)

DEFAULT lOperacao := .F.

If !lOperacao
	Tk273RecCpg( &(ReadVar()),.T. )
Else
	Tk273RecCpg( UA_CONDPG,.T. )
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK273ValOperºAutor  ³Vendas Cliente      º Data ³  13/03/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função utilizada no X3_VALID do campo UA_OPER.			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER - Televendas                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK273VdJur()

Local lTKVDACR	:= Iif(SuperGetMV("MV_TMKLOJ",,.F. )== "S" .And. GetNewPar("MV_TKVDACR",.F.),.T.,.F.)	//Se possuir integração com o SIGALOJA, faz o cálculo do acrescimo sobre o total menos o desconto.

If VAL(M->UA_OPER) == FATURAMENTO
	If !ctbValiDt( Nil, dDataBase, .T., Nil, Nil, { "FAT001" }, Nil )
		Return .F. 
	EndIf
EndIf

If lTKVDACR
	Tk273VCond(.T.)
	Tk273Recalc(,,.T.)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK273ValTransºAutor ³Vendas Cliente      º Data ³  25/06/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função utilizada do campo UA_TRANS.	   					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER - Televendas                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK273ValTrans(cCodTransp,cTransp,oTransp) 
Local lRet := .T.
Local cBloq			:= ""										// Variável para verificacao de boloqueio da transportadora

If !Empty(cCodTransp)
	DbSelectArea("SA4")
	DbSetOrder(1)
	If DbSeek(xFilial("SA4")+cCodTransp)
		cBloq := FieldGet(FieldPos("A4_MSBLQL"))
		If Empty(cBloq) .OR. cBloq == "2"
			cTransp := SA4->A4_NOME
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se nao estiver usando a entrada automatica³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lTk271Auto
				If ValType(oTransp)=="O"
					oTransp:Refresh()
				EndIf
			Endif	
			lRet := .T.
		Else
			Help("",1,"REGBLOQ")
			lRet := .F.
		EndIf
	Else
		Help(" ",1,"REGNOIS")
		lRet:= .F.
	EndIf            
EndIf

Return(lRet)

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK273LdSx3

Retorna as informaçoes contidas no dicionário de dados para ser utilizado nos MSGETs

@sample	TK273LdSx3()

@param		Nenhum

@return	ExpA Array contendo o nome e a propriedade de cada campo da tabela SUA

@author Eduardo Yamamoto
@since		17/06/2014
@version	11.8
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TK273LdSx3()

Local aArea := GetArea()
Local aRet  := {}

DbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SUA")

While ( !Eof() .And. SX3->X3_ARQUIVO == "SUA" )
	
	AADD(aRet, {AllTrim(SX3->X3_CAMPO), IIF(SX3->X3_VISUAL == 'V', .F., .T.) })
	dbSkip()
	
EndDo

RestArea(aArea)

Return aRet

//------------------------------------------------------------------
/*/{Protheus.doc} TK273AtuVal()
Recalcula o valor dos impostos 

@sample		TK273AtuVal( cCodPagto )
@param		cCodPagto,	Caractere, Cond. de Pagamento
@author 	Squad CRM
@since 		24/07/2019
@version 	P12.1.28
@return 	Nil
/*/
//-------------------------------------------------------------------
Static Function TK273AtuVal( cCodPagto )

	Local nAcresRat		:= 0
	Local nAux			:= Len(aCols)
	Local nLinha		:= 0
	Local nPosQtd		:= aScan(aHeader,{|x|Alltrim(x[2])=="UB_QUANT"})
	Local nPosVlUnit	:= aScan(aHeader,{|x|Alltrim(x[2])=="UB_VRUNIT"})
	Local nPosVlItem	:= aScan(aHeader,{|x|Alltrim(x[2])=="UB_VLRITEM"})
	Local lTKVDACR		:= IIF(SuperGetMV("MV_TMKLOJ",,.F.) == "S" .And. GetNewPar("MV_TKVDACR",.F.),.T.,.F.)
	Local lRet			:= .F.

	Default cCodPagto		:= M->UA_CONDPG		

	aValores[ACRESCIMO]  	:= 0
	aValores[MERCADORIA]	:= 0
	aValores[SUFRAMA]		:= 0
	aValores[TOTAL]			:= 0
	aValores[BASEDUP]		:= 0

	TkRegraDesc(2, Nil, @M->UA_DESC4, Nil, cCodPagto, Nil)

	For nLinha := 1 To nAux
		If !GDDeleted(nLinha)
			
			MaFisAlt("IT_QUANT" , aCols[nLinha, nPosQtd], nLinha)
			MaFisAlt("IT_PRCUNI", aCols[nLinha, nPosVlUnit], nLinha)
							
			nAcresRat := 0
			Tk273RecCpg( cCodPagto, , nLinha, @nAcresRat)
			MaFisAlt("IT_VALMERC",aCols[nLinha, nPosVlItem] + nAcresRat, nLinha)

			If lTKVDACR .And. M->UA_OPER == "2"
				Tk273RodImposto("NF_DESCONTO", aValores[DESCONTO])
				Tk273RodImposto("NF_DESPESA" , aValores[DESPESA])
			Else
				Tk273RodImposto("NF_DESPESA" , aValores[DESPESA])
				Tk273RodImposto("NF_DESCONTO", aValores[DESCONTO])
			EndIf
		Endif
		
	Next nLinha

	Eval(bListRefresh)

Return lRet




//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource


//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------

Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet    

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive    
 
