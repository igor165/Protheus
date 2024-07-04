#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include 'Report.ch'
#include 'LOJA783.ch'

Static lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

//----------------------------------------------------------
/*/{Protheus.doc} LOJA783
Monitor Movimentacao de Documento Eletronico.

@type function

@author  Varejo
@version P12.1
@since   30/08/2016
@param	
@return Nil
/*/
//----------------------------------------------------------
Function LOJA783()
Local oBrowse		:= nil

DbSelectArea("MH5")

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('MH5')
oBrowse:SetDescription(STR0001)		//"Monitor Movim. Doc. Elet."
oBrowse:AddLegend( "MH5_TOTDIF==0", "GREEN", STR0003 )	//"Sem Diferença"
oBrowse:AddLegend( "MH5_TOTDIF<>0", "RED"  , STR0004 )	//"Com Diferença"
oBrowse:Activate()

Return NIL

//------------------------------------------'----------------
/*/{Protheus.doc} MenuDef
Funcao de definição do aRotina.

@type function

@author  Varejo
@version P12.1
@since   30/08/2016

@param	
@return aRotina 	Array com as opcoes da rotina.
/*/
//----------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0005  	ACTION 'PesqBrw'         	OPERATION 1 ACCESS 0	//"Pesquisar"
ADD OPTION aRotina TITLE STR0006 	ACTION 'VIEWDEF.LOJA783' 	OPERATION 2 ACCESS 0	//"Visualizar"
ADD OPTION aRotina TITLE STR0007 	ACTION 'LJ783Gera' 			OPERATION 3 ACCESS 0	//"Gerar"
ADD OPTION aRotina TITLE STR0008    ACTION 'VIEWDEF.LOJA783' 	OPERATION 5 ACCESS 0	//"Excluir"

Return aRotina

//----------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do Modelo de dados.

@type function

@author  Varejo
@version P11.8
@since   30/08/2016

@param	
@return oModel 	Objeto com o modelo de dados.
/*/
//----------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruMH5 := FWFormStruct( 1, 'MH5', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('LOJA783MODEL', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'MH5MASTER', /*cOwner*/, oStruMH5, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

Return oModel

//----------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao da Interface do programa.

@type function

@author  Varejo
@version P12.1
@since   30/08/2016

@param	
@return oView 	Objeto View
/*/
//----------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'LOJA783' )
// Cria a estrutura a ser usada na View
Local oStruMH5 := FWFormStruct( 2, 'MH5' )
Local oView  
// Cria o objeto de View
oView := FWFormView():New()
// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )
//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_MH5', oStruMH5, 'MH5MASTER' )
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )
// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_MH5', 'TELA' )

Return oView

//----------------------------------------------------------
/*/{Protheus.doc} LJ783Gera
Funcao que gera o processamento e alimenta os dados na tabela MH5.

@type function
@author  Varejo
@since   30/08/2016
@return Nil
/*/
//----------------------------------------------------------
Function LJ783Gera()

Processa({|lEnd| L783GerRun() })

Return

//----------------------------------------------------------
/*/{Protheus.doc} L783GerRun
Funcao que executa o processamento e alimenta os dados na tabela MH5.

@type function

@author  Varejo
@version P12.1
@since   30/08/2016

@param	
@return Nil
/*/
//----------------------------------------------------------
Function L783GerRun()	// Chamada da funcao de recalculos
Local cPerg			:= "LOJA783"
Local dDataDe 		:= cToD("  /  /  ")
Local dDataAte 		:= cToD("  /  /  ")
Local cFilialDe 	:= ""
Local cFilialAte 	:= ""
Local cPDVDe	 	:= ""
Local cPDVAte		:= ""
Local nTamDoc 		:= TamSx3("L1_DOC")[1]
Local nTamSerie		:= TamSx3("L1_SERIE")[1]
Local cDocDe 		:= Replicate("0",nTamDoc)
Local cDocAte		:= Replicate("9",nTamDoc)
Local lContinua 	:= .T.
Local lAborta		:= .F.
Local aFiltro 		:= {}
Local aArea			:= GetArea()
Local aAreaSF3		:= SF3->(GetArea())
Local aAreaSFT		:= SFT->(GetArea())
Local aAreaSLG		:= SLG->(GetArea())
Local aAreaSM0 		:= SM0->(GetArea())
Local cFilAntBkp 	:= cFilAnt
Local aFiliais 		:= FWAllFilial(,,,.F.)
Local nPos 			:= 0
Local nX 			:= 0
Local nY 			:= 0
Local nZ 			:= 0
Local nW			:= 0
Local aRetTSS 		:= {}
Local aNotasTSS		:= {}
Local cMsgAbort		:= ""
Local cNumNFIni 	:= ""
Local cNumNFFim 	:= ""
Local oXML 			:= Nil
Local cXML			:= ""
Local cXMLPROT		:= ""
Local lRetXMLMng 	:= .F.
Local cStatus 		:= ""
Local aRetXML		:= {}
Local lUsaNfce		:= .F.
Local nTotVdaTSS 	:= 0	//Valor Total da Venda no TSS
Local nTotVdaPrt 	:= 0	//Valor Total da Venda no Protheus
Local nTotCanTSS 	:= 0	//Valor Cancelamentos de Venda no TSS
Local nTotCanPrt 	:= 0	//Valor Cancelamentos de Venda no Protheus
Local dDataMov		:= cToD("  /  /  ")
Local cSerieFil		:= ""
Local aDatasFilt	:= {}
Local cPDV 			:= ""
Local nQtdCanTSS	:= 0	//Qtde de Cancelamentos no TSS
Local nQtdInuTSS	:= 0	//Qtde de Inutilizacoes no TSS
Local cTipoDoc		:= "1" //1=NFC-e
Local aDados 		:= {}
Local nPosic		:= 0
Local aVendas 		:= {}
Local aCancelados	:= {}
Local aInconsist	:= {}
Local nVlrVdaPrt	:= 0
Local nVlrVdaTSS	:= 0
Local nVlrCanTSS	:= 0
Local cMsgCanInu 	:= ""
Local aDoctos 		:= {}	//Array com a relacao de documentos (somente Vendas autorizadas), para saber se existe algum pulo de numeracao de nota. 
Local lUsaSat 		:= .F.
Local nQtdVenPrt	:= 0	//Quantidade vendas Protheus
Local nQtdVenSef 	:= 0	//Quantidade vendas SEFAZ
Local aRetVldSat	:= {}	//Array com o retorno das validações do SAT
Local nK			:= 0	//Contador
Local cDescDoc		:= "NFC-e" //Descrição do tipo de documento
Local aPDVSeries 	:= {}
Local cSerie 		:= ""
Local cMsg			:= ""
Local aMsg			:= {}
Local cTipoPDV 		:= ""
Local lLJ783 		:= .T.
Local cCodRetNF		:= ""
Local cMsgRetNF		:= ""
Local lLjMonitora 	:= ExistFunc("LjMonitora")
Local lVerNtTran 	:= .T. 	//Indica se deve ver dados da Nota Fiscal Transmitida
Local cSitCan 		:= ""	//Situacao do Cancelamento/Inutilizacao na tabela SL1 ou SLX
Local cBkpEst		:= "" 


If !lAutomato
	lContinua := Pergunte(cPerg,.T.)
EndIf

If lContinua
	dDataDe 	:= MV_PAR01 //Data De
	dDataAte 	:= MV_PAR02 //Data Ate
	cFilialDe 	:= MV_PAR03 //Filial De
	cFilialAte 	:= MV_PAR04 //Filial Ate
	cPDVDe	 	:= MV_PAR05 //PDV De
	cPDVAte		:= MV_PAR06 //PDV Ate

	dDataMov := dDataDe
	While dDataMov <= dDataAte
		aAdd( aDatasFilt, dDataMov )
		dDataMov := dDataMov + 1
	End
	
	nPos := aScan( aFiliais, cFilialDe )
	If nPos == 0
		nPos := 1
	EndIf
	
	For nX := nPos To Len(aFiliais)
		If aFiliais[nX] >= cFilialDe .And. aFiliais[nX] <= cFilialAte
			cFilAnt := aFiliais[nX] //Seta a filial a ser processada
			
			//Posiciona na SM0 correspondente a filial em questao
			SM0->(DbSetOrder(1)) //M0_CODIGO+M0_CODFIL
			SM0->(DbSeek(cEmpAnt+cFilAnt))
			
			aFiltro 	:= {}
			lAborta		:= .F.
			aPDVSeries 	:= {}
            
			//Carrega todas as Series a serem processadas
			DbSelectArea("SLG")
			SLG->(DbSetOrder(1)) //LG_FILIAL+LG_CODIGO
			If SLG->(DbSeek(xFilial("SLG")))
				While SLG->( !EoF() ) .And. SLG->LG_FILIAL == xFilial("SLG")
					
					If !Empty(SLG->LG_PDV) .And. !Empty(SLG->LG_SERIE)
						
						lUsaNfce:= SLG->LG_NFCE	   	//Verifica se o PDV esta configurado para usar NFC-e
						lUsaSat	:= SLG->LG_USESAT 	//Verifica se o PDV esta configurado para usar SAT
						
						//Somente considera o PDV caso esteja configurada para NFC-e ou SAT
						If lUsaNfce .Or. lUsaSat
							cTipoPDV := Iif( lUsaSat, "SAT", "NFCE" ) //Verifica se PDV esta configurado como SAT ou NFC-e
							
							If ( nPosic := aScan( aPDVSeries, { |x| x[1] == SLG->LG_SERIE } ) ) == 0
								aAdd( aPDVSeries, { SLG->LG_SERIE, { { SLG->LG_PDV, cTipoPDV } }, SLG->(RECNO()) } )
							Else
								aAdd( aPDVSeries[nPosic][2], { SLG->LG_PDV, cTipoPDV } )
							EndIf
						EndIf
						
					EndIf
					
					SLG->( DbSkip() )
				End
				
				//Percorre todos os PDVs para somente considerar o range de PDVs (De/Ate) parametrizado
				For nY := 1 To Len(aPDVSeries)
					
					cSerie 	:= aPDVSeries[nY][1]
					cMsg 	:= ""
					
					//Verifica se existe mais de um PDV configurado com o mesmo numero de Serie, se existir nao premitira continuar o processamento da rotina
					If Len(aPDVSeries[nY][2]) > 1
						For nZ := 1 To Len(aPDVSeries[nY][2])
							cMsg += AllTrim((aPDVSeries[nY][2][nZ][1])) + ", "
						Next nZ
						cMsg := SubStr(cMsg,1,Len(cMsg)-2) //Retira a ultima virgula e espaco
					EndIf
					
					If !Empty(cMsg)
						cMsg:=	STR0045 + ": [" + cFilAnt + "]" + "     /     " + STR0046 + ": [" + cSerie +"]" + Chr(13) + ; //"Filial" ### "Série"
								"PDVs" + ":" + cMsg
						
						aAdd( aMsg, cMsg )
						lAborta := .T. //Aborta o processamento desta filial
                    Else
						cPDV 	:= aPDVSeries[nY][2][1][1]
						lUsaSat	:= aPDVSeries[nY][2][1][2] == "SAT"
						
						If cPDV >= cPDVDe .And. cPDV <= cPDVAte
							aAdd( aFiltro, { cPDV, cSerie, lUsaSat, aPDVSeries[nY][3]  } )
						EndIf
					EndIf
					
				Next nY
				
			EndIf
			
			If lAborta
				//Pula para a proxima filial
				Loop
			EndIf
			
			If Len(aFiltro) > 0
				aSort( aFiltro,,, {|a,b| a[1] < b[1] })
			EndIf
			
			ProcRegua( Len(aFiltro) * Len(aDatasFilt) ) //Define tamanho da regua de progressao

			cBkpEst	:= cEstacao
			
			//Processa a busca dos dados
			For nY := 1 To Len(aFiltro)
				
				cPDV		:= aFiltro[nY][1]
				cSerieFil	:= aFiltro[nY][2]
				lUsaSat		:= aFiltro[nY][3]
				
				//Seta o codigo da Estacao e posiciona na tabela SLG
				SLG->( dbGoTo(aFiltro[nY][4]))
				cEstacao := SLG->LG_CODIGO
				
				//Percorre data a data
				For nW := 1 To Len(aDatasFilt)
					
					dDataMov	:= aDatasFilt[nW]
					cDocDe 		:= Replicate("0",nTamDoc)
					cDocAte		:= Replicate("9",nTamDoc)
					aNotasTSS	:= {}
					nTotVdaTSS 	:= 0
					nTotVdaPrt 	:= 0
					nTotCanTSS	:= 0
					nTotCanPrt	:= 0
					nQtdCanTSS	:= 0
					nQtdInuTSS	:= 0
					lAborta 	:= .F.
					lContinua	:= .T.
					aDoctos 	:= {}
					
					//Incrementa a Regua
					IncProc( STR0015 + cPDV + STR0016 + dtoc(dDataMov) )	//"Processando PDV "###" / Data " 
					//Busca no Protheus as vendas que foram realizadas no dia.
					aVendas 	:= Lj783Vendas( dDataMov, cPDV, cSerieFil, lUsaSat )
					//Busca no Protheus as vendas que foram canceladas no dia.
					aCancelados := Lj783Cancel( dDataMov, cPDV, cSerieFil, lUsaSat )

					LjGrvLog("LOJA783","Vendas no  Protheus",aVendas)
					LjGrvLog("LOJA783","Cancelados Protheus",aCancelados)
					
					// Tratamento para NFC-e
					If !lUsaSat
						//Percorre este laco ate nao encontrar mais dados no TSS para os parametros passados
						While lContinua .And. !lAborta
							//Busca dados no TSS
							aRetTSS := LjRetNFCe(dDataMov, dDataMov, cSerieFil, cSerieFil, cDocDe, cDocAte, lLJ783)
							
							/////////////////////////////////////////////////////////////////////////////////////
							//Setando a variálvel de controle para a obtenção do ident pertinente a cada filial// 
							//para que não tenhamos perda de performance									   //
							///////////////////////////////////////////////////////////////////////////////////// 
							lLJ783 := .F.
							
							If Len(aRetTSS) == 0
								lContinua := .F. //Se retornou vazio eh porque nao encontrou nenhuma nota para os parametros passados.
							ElseIf ValType(aRetTSS[1]) == "C" .And. aRetTSS[1] == "ERRO"
								cMsgAbort := STR0017 + Chr(13) + Chr(13) + aRetTSS[2] + Chr(13) + Chr(13)	//"Ocorreu problema ao tentar gerar as movimentações de NFC-e."
								cMsgAbort += STR0018 + dtoc(dDataMov) + Chr(13)		//"Data processada: "
								cMsgAbort += STR0019 + cSerieFil		//"Série processada: "
								lAborta := .T.
							Else
								aEval( aRetTSS,{ |x| AAdd( aNotasTSS, x ) } )
								cDocDe := SubStr(aRetTSS[Len(aRetTSS)]:CID, Len(cSerieFil)+1, nTamDoc )
								cDocDe := Alltrim(cDocDe)			//Evita loop, pois eu ajusto o número de caracteres devido ao tamanho da numeração ser variável.
																		// Ex: numeração c/ 9 caracteres, em um dia específico gravei com 6 caracteres. 
																		// Na próxima leitura do LjRetNfce, eu pesquiso com o número de caracteres correto (6 caract.) e o do/while continua normalmente. 
								cDocDe := StrZero(Val(cDocDe)+1,Len(cDocDe)) //Soma mais 1 para continuar pesquisando se existe mais notas para a data em questao
							EndIf
						End
						
						If lAborta
							MsgStop(cMsgAbort)
							Exit
						EndIf
						
						If Len(aNotasTSS) > 0
							cNumNFIni := SubStr(aNotasTSS[1]:CID, Len(cSerieFil)+1, nTamDoc )				//Numero da nota Inicial
							cNumNFFim := SubStr(aNotasTSS[Len(aNotasTSS)]:CID, Len(cSerieFil)+1, nTamDoc )	//Numero da nota Final
							
							For nZ := 1 To Len(aNotasTSS)
								cSerNota 	:= SubStr(aNotasTSS[nZ]:CID,1,nTamSerie)
								cNumNota 	:= SubStr(aNotasTSS[nZ]:CID,nTamSerie+1,nTamDoc)
								aRetXML		:= {}
								nVlrVdaPrt	:= 0
								nVlrVdaTSS 	:= 0
								nVlrCanTSS	:= 0
								cCodRetNF	:= ""
								cMsgRetNF	:= ""
								lVerNtTran	:= .T.
								
								//Verifica se houve solicitação de Cancelamento/Inutilização para esta nota
								If aNotasTSS[nZ]:OWSNFECANCELADA <> Nil
									
									cXML 		:= aNotasTSS[nZ]:OWSNFECANCELADA:CXML		//XML
									cXMLPROT 	:= aNotasTSS[nZ]:OWSNFECANCELADA:CXMLPROT 	//XML Protocolo
									
									If !Empty(cXMLPROT) //Verifica se tem o protocolo de retorno do SEFAZ, referente a transmissao do cancelamento/inutilizacao
										cStatus := Lj783SitNF( cXMLPROT )
										
										If cStatus $ "101|151|155" //Cancelado

											//Retorna alguns dados do XML da venda
											aRetXML := L783RetXML(aNotasTSS[nZ]:OWSNFE:CXML,.F.)

											lVerNtTran 	:= .F.

											If aRetXML[2] == "65" //Considera somente modelo 65 (NFC-e)

												nQtdCanTSS++ //Soma a quantidade de notas canceladas
												
												nVlrCanTSS := aRetXML[01] //01-Valor total do cancelamento na nota no TSS
												
												//Verifica se este DOC e Serie do TSS, existe tambem no Protheus como "Cancelado/Inutilizado"
												If !LjIsCanPrt(@aCancelados, cNumNota, cSerNota, nVlrCanTSS)
													aAdd( aCancelados, {cNumNota	,;	//01-DOC
																		cSerNota   	,;	//02-SERIE
																		0 			,;	//03-Valor do Cancelamento no Protheus
																		nVlrCanTSS	,;	//04-Valor do Cancelamento no TSS
																		"2" 		,;	//05-Seta para indicar que o DOC/Serie esta cancelado apenas no TSS (1=Protheus; 2=TSS; 3=Protheus e TSS)
																		"CANC" 		,;	//06-Indica que a nota esta CANCELADA
																		Nil 		} )	//07-Número do Cupom SAT que efetuou o Cancelamento desta venda
												EndIf

											EndIf
											
										ElseIf cStatus == "102" //Inutilizado

											//Retorna alguns dados do XML da venda
											aRetXML := L783RetXML(aNotasTSS[nZ]:OWSNFECANCELADA:CXML,.T.)

											lVerNtTran 	:= .F.

											If aRetXML[2] == "65" //Considera somente modelo 65 (NFC-e)
											
												nQtdInuTSS++ //Soma a quantidade de notas inutilizadas
												
												//Verifica se este DOC e Serie do TSS, existe tambem no Protheus como "Cancelado/Inutilizado"
												If !LjIsCanPrt(@aCancelados, cNumNota, cSerNota, nVlrCanTSS)
													aAdd( aCancelados, {cNumNota	,;	//01-DOC
																		cSerNota   	,;	//02-SERIE
																		0 			,;	//03-Valor do Cancelamento no Protheus
																		nVlrCanTSS	,;	//04-Valor do Cancelamento no TSS
																		"2" 		,;	//05-Seta para indicar que o DOC/Serie esta inutilizado apenas no TSS (1=Protheus; 2=TSS; 3=Protheus e TSS)
																		"INUT" 		,;	//06-Indica que a nota esta INUTILIZADA
																		Nil 		} )	//07-Número do Cupom SAT que efetuou o Cancelamento desta venda
												EndIf

											EndIf
											
										EndIf
									Else
										//Se o XMLPROT está vazio, então resgata a situação atual da NFC-e no TSS, pois pode ter ocorrido alguma rejeição de cancelamento
										If lLjMonitora
											//Monitora a nota para resgatar a situação atual da mesma
											LjMonitora( cNumNota, cSerNota, "65", @cCodRetNF, @cMsgRetNF )
											
											If !Empty(cCodRetNF)

												If cCodRetNF == "501" //501=Rejeicao: Prazo de Cancelamento Superior ao Previsto na Legislacao
													//Veirifica a situação atual do Cancelamento/Inutilizacao nas tabelas do LOJA
													cSitCan := LjSituaCan(cSerNota, cNumNota)
													If cSitCan $ "X0|X1|X2|X3"
														AAdd( aInconsist, { cFilAnt, dDataMov, cNumNota, cSerNota, cDescDoc,"0,00","0,00","Cod. Retorno:" + cCodRetNF + " - " + cMsgRetNF } )
														lVerNtTran 	:= .F.
													EndIf
												Else
													AAdd( aInconsist, { cFilAnt, dDataMov, cNumNota, cSerNota, cDescDoc,"0,00","0,00","Cod. Retorno:" + cCodRetNF + " - " + cMsgRetNF } )
													lVerNtTran 	:= .F.
												EndIf

											EndIf
										EndIf
									EndIf
								EndIf

								If lVerNtTran
									//Verifica se tem o protocolo de retorno do SEFAZ, referente a transmissao da nota
									If !Empty(aNotasTSS[nZ]:OWSNFE:CXMLPROT)
										cXML 		:= aNotasTSS[nZ]:OWSNFE:CXML				//XML
										cXMLPROT 	:= aNotasTSS[nZ]:OWSNFE:CXMLPROT			//XML Protocolo
										
										cStatus := Lj783SitNF( cXMLPROT )
										
										If cStatus $ "100/150" //Autorizado o uso da NF-e

											//Retorna alguns dados do XML da venda
											aRetXML := L783RetXML(aNotasTSS[nZ]:OWSNFE:CXML,.F.)

											If aRetXML[2] == "65" //Considera somente modelo 65 (NFC-e)
											
												nVlrVdaTSS := aRetXML[01] //01-Valor total da venda no TSS
												
												nTotVdaTSS += nVlrVdaTSS //Acumula o Valor total das vendas do TSS
												
												aAdd( aDoctos, {cNumNota, cSerNota} )
												
												//Verifica se para este DOC e Serie do TSS, existe a Venda no Protheus tambem
												If ( nPosic := aScan( aVendas, { |x| cNumNota+cSerNota == x[1]+x[2] } ) ) > 0
													nVlrVdaPrt := aVendas[nPosic][3]
													aVendas[nPosic][4] := nVlrVdaTSS
													aVendas[nPosic][5] := "3" //Seta para indicar que o DOC/Serie existe tambem no TSS (1=Protheus; 2=TSS; 3=Protheus e TSS)
												Else
													aAdd( aVendas, {cNumNota		,;	//01-DOC
																	cSerNota   		,;	//02-SERIE
																	0				,;	//03-Valor Total da Venda no Protheus
																	nVlrVdaTSS		,;	//04-Valor Total da Venda no TSS
																	"2" 			} )	//05-Seta para indicar que o DOC/Serie existe apenas no TSS (1=Protheus; 2=TSS; 3=Protheus e TSS)
												EndIf

											EndIf
										EndIf
									EndIf
								EndIf
							Next nZ
						EndIf
						
						//Percorre array de DOCs de Vendas para fazer a verificacao de inconsistencias para gerar o relatorio final.
						aSort( aVendas,,, {|a,b| a[5]+a[1]+a[2] < b[5]+b[1]+b[2] })
						For nZ := 1 to Len(aVendas)
							
							nTotVdaPrt += aVendas[nZ][3] //Totaliza o valor de Vendas existente no Protheus
							
							If aScan( aInconsist, { |x| aVendas[nZ][1]+aVendas[nZ][2] == x[3]+x[4] } ) == 0

								If aVendas[nZ][5] == "3" //DOC/Serie existe no Protheus e no TSS
									If aVendas[nZ][3] <> aVendas[nZ][4]	//Verifica se os totais batem.
										AAdd( aInconsist, { cFilAnt, dDataMov, aVendas[nZ][1], aVendas[nZ][2], cDescDoc,;
												AllTrim(TransForm(aVendas[nZ][3],'@E 999,999,999.99')),;
												AllTrim(TransForm(aVendas[nZ][4],'@E 999,999,999.99')),;
												STR0020;		//"Foi identificado diferença no valor total desta venda entre o Protheus e o TSS"
												})	
									EndIf
								ElseIf aVendas[nZ][5] == "1" //Verifica se o DOC/Serie existe apenas no Protheus (1=Protheus; 2=TSS; 3=Protheus e TSS)
									AAdd( aInconsist, { cFilAnt, dDataMov, aVendas[nZ][1], aVendas[nZ][2], cDescDoc,"0,00","0,00",STR0022 } )	//"Documento não foi localizado no TSS"
								ElseIf aVendas[nZ][5] == "2" //Verifica se o DOC/Serie existe apenas no TSS (1=Protheus; 2=TSS; 3=Protheus e TSS)
									AAdd( aInconsist, { cFilAnt, dDataMov, aVendas[nZ][1], aVendas[nZ][2], cDescDoc,"0,00","0,00",STR0023 } )	//"Documento não foi localizado no Protheus"
								EndIf

							EndIf
						Next nZ
	
						//Ordena o array de DOCs Cancelados, por tipo de insconsistencia (1=Protheus; 2=TSS; 3=Protheus e TSS)
						aSort( aCancelados,,, {|a,b| a[5]+a[1]+a[2] < b[5]+b[1]+b[2] })
						
						//Percorre array de DOCs Cancelados para fazer a verificacao se encontra o DOC Cancelado/Inutilizado" no TSS em outra data diferente da data que esta no Protheus
						For nZ := 1 to Len(aCancelados)
							If aCancelados[nZ][5] == "1" //Considera o DOC que a principio existe so no Protheus (1=Protheus; 2=TSS; 3=Protheus e TSS)
								nVlrCanTSS := 0
								//Verifica se encontra este DOC Cancelado/Inutilizado" no TSS em outra data diferente da data que esta no Protheus
								If LjIsCanTSS(aCancelados[nZ][1], aCancelados[nZ][2], @nVlrCanTSS,aCancelados[nZ][3])
									If aCancelados[nZ][6] == "INUT"
										//Atualiza o valor de cancelamento no Protheus igual ao que esta no TSS, pois neste caso nao pode apresentar diferenca
										aCancelados[nZ][3] := nVlrCanTSS
									EndIf
									
									aCancelados[nZ][4] := nVlrCanTSS
									aCancelados[nZ][5] := "3" //Seta para indicar que o DOC/Serie esta cancelado tambem no TSS (1=Protheus; 2=TSS; 3=Protheus e TSS)
								EndIf
							EndIf
						Next nZ					
						
						//Ordena o array de DOCs Cancelados, por tipo de insconsistencia (1=Protheus; 2=TSS; 3=Protheus e TSS)
						aSort( aCancelados,,, {|a,b| a[5]+a[1]+a[2] < b[5]+b[1]+b[2] })
						
						//Percorre array de DOCs Cancelados para fazer a verificacao de inconsistencias para gerar o relatorio final.
						For nZ := 1 to Len(aCancelados)
							If aCancelados[nZ][6] == "INUT"
								cMsgCanInu := STR0024		//"Inutilização"
							Else
								cMsgCanInu := STR0025		//"Cancelamento"
								
								nTotCanPrt += aCancelados[nZ][3]	//Totaliza o valor de Cancelamentos existente no Protheus
								nTotCanTSS += aCancelados[nZ][4]	//Valor total de cancelamentos no TSS
								
								If aCancelados[nZ][5] == "3" //DOC/Serie existe no Protheus e no TSS
									If aCancelados[nZ][3] <> aCancelados[nZ][4]	//Verifica se os totais batem.
										AAdd( aInconsist, { cFilAnt, dDataMov, aCancelados[nZ][1], aCancelados[nZ][2], cDescDoc,;
											 AllTrim(TransForm(aCancelados[nZ][3],'@E 999,999,999.99')),;
											 AllTrim(TransForm(aCancelados[nZ][4],'@E 999,999,999.99')),;
											 STR0026;	//"Foi identificado diferença no valor total deste cancelamento entre o Protheus e o TSS"
											 })
									EndIf
								EndIf
							EndIf
							
							If aCancelados[nZ][5] == "1" //Verifica se o DOC/Serie existe apenas no Protheus (1=Protheus; 2=TSS; 3=Protheus e TSS)
								AAdd( aInconsist, { cFilAnt, dDataMov, aCancelados[nZ][1], aCancelados[nZ][2], cDescDoc,"0,00","0,00",cMsgCanInu + STR0027 } )	//" não foi localizado no TSS"
							ElseIf aCancelados[nZ][5] == "2" //Verifica se o DOC/Serie existe apenas no TSS (1=Protheus; 2=TSS; 3=Protheus e TSS)
								AAdd( aInconsist, { cFilAnt, dDataMov, aCancelados[nZ][1], aCancelados[nZ][2], cDescDoc,"0,00","0,00",cMsgCanInu + STR0028 } )	//" não foi localizado no Protheus"
							EndIf
						Next nZ
						//Verifica a sequencia de numeracao da nota para ver se existe algum pulo de numeracao
						LjVerSeqNF( aDoctos, @aInconsist, cFilAnt, dDataMov, aCancelados, cDescDoc)
						cTipoDoc := "1" //Tipo de documento NFC-e
						
						//Referente ao SAT apenas
						nQtdVenPrt := 0
						nQtdVenSef := 0
					Else
						// Tratamento para SAT
						aRetVldSat := Lj783VldSat(aVendas,aCancelados,dDataMov)	//Valida vendas e cancelamentos SAT
						If Len(aRetVldSat) > 0
							nQtdCanTSS	:= aRetVldSat[1]  //Quantidade cancelamentos Sefaz
							nTotVdaPrt	:= aRetVldSat[2]  //Total vendas Protheus
							nQtdVenPrt	:= aRetVldSat[3]  //Quantidade de vendas Protheus
							nQtdVenSef	:= aRetVldSat[4]  //Quantidade de vendas Sefaz
							//Inconsistencia
							For nK := 1 To Len(aRetVldSat[5])
								aAdd(aInconsist,aRetVldSat[5][nK])
							Next nK
						Else
							lAborta := .T.	
						EndIf
						
						cTipoDoc := "2" //Tipo de documento SAT
					EndIf	
					
					If nTotVdaPrt > 0 .Or. nTotVdaTSS > 0 .or. nQtdVenSef > 0
						aDados :=  {dDataMov	,; //01=Data do movimento
									cPDV		,; //02=PDV
									cSerieFil	,; //03=Serie
									cTipoDoc	,; //04=Tipo de Documento (NFC-e ou SAT)
									nTotVdaPrt	,; //05=Valor de vendas Total Protheus
									IIf(lUsaSat,nQtdVenSef,nTotVdaTSS)	,; //06=Valor de vendas Total Transmitidas
									nQtdCanTSS	,; //07=Quantidade de notas Canceladas Transmitidas
									nQtdInuTSS 	,; //08=Quantidade de notas Inutilizadas Transmitidas
									nTotCanPrt 	,; //09=Valor de Cancelamentos Protheus
									nTotCanTSS 	,; //10=Valor de Cancelamentos Transmitidos
									nQtdVenPrt 	,; //11=Quantidade vendas Protheus
									nQtdVenSef 	} //12=Quantidade vendas SEFAZ
									
						//Grava registro na tabela MH5
						Lj783Grava( aDados )
					EndIf
					
				Next nW
				
				If lAborta
					If lUsaSat
						Loop
					EndIf

					Exit
				EndIf
				
			Next nY
			
			cEstacao := cBkpEst

			If lAborta
				Exit
			EndIf
			
		EndIf
		
		///////////////////////////////////////////////////////////////////////
		//Setando novamente para a atualização do ident para a proxima filial// 
		//de acordo com os parâmetros informados							 //
		///////////////////////////////////////////////////////////////////////
		lLJ783 := .T.
	Next nX
	
	If Len(aMsg) > 0
		cMsgAbort := ""
		For nZ := 1 To Len(aMsg)
			cMsgAbort += aMsg[nZ] + Chr(13) + Replicate("_",40) + Chr(13) + Chr(13)
		Next nZ
		
		cMsgAbort := 	STR0047 + Chr(13) + Chr(13)+; //"Foi identificado que existe mais de um PDV configurado com a mesma Série, conforme apresentado abaixo."
						STR0048 + Chr(13) + Chr(13)+; //"Não pode existir mais de um PDV configurado com a mesma Série. Ajuste as Séries dos PDVs no Cadastro de Estação."
						STR0049 + Chr(13) + Chr(13) + cMsgAbort //"As filiais apresentadas abaixo foram desconsideradas no processamento."
		
		MsgAlert(cMsgAbort)
	EndIf

EndIf

//Reposiciona na filial atual do sistema
cFilAnt := cFilAntBkp

RestArea(aAreaSM0)
RestArea(aAreaSLG)
RestArea(aAreaSFT)
RestArea(aAreaSF3)
RestArea(aArea)

If !lAutomato
	If Len(aInconsist) > 0
		//Gera em relatorio os detalhes das Inconsistencias encontradas.
		Lj783Detal( aInconsist )
	Else
		MsgInfo(STR0051,STR0050) //"Não foi encontrado diferenças no período"###"Executado com sucesso"
	EndIf
EndIf

Return

//----------------------------------------------------------
/*/{Protheus.doc} Lj783SitNF
Retorna a Situacao da Nota.

@type function

@author  Varejo
@version P12.1
@since   30/08/2016

@param	cXMLPROT	XML Protocolo
@return cStatus		Status da NFC-e
/*/
//----------------------------------------------------------
Static Function Lj783SitNF(cXMLPROT)
Local cStatus 	:= ""
Local oXML 		:= Nil
Local nPosic 	:= 0


//Status de autorizado o uso da NF-e/NFC-e: 100;150
//Status de Cancelamento: 101; 151; 155
//Status de Inutilizacao: 102 

//Verifica a Tag "cStat" pela funcao AT() ao inves de usar o TXMLManager, pois caso a nota  tenha
//sido transmitida em contingencia, o xml de protocolo de retorno (XMLPROT) pode vir diferente, ou seja, sem o atributo "http://www.portalfiscal.inf.br/nfe" e 
//tambem pode vir com as tags em caixa alta (MAIUSCULO). Neste caso daria problema ao utilizar o TXMLManager, pois ele considera "case sensitive".
cXMLPROT := Upper(cXMLPROT)

//Procura a posicao onde esta a tag <CSTAT>
nPosic := At("<CSTAT>", cXMLPROT)
cStatus := SubStr(cXMLPROT,nPosic+7)
nPosic := At("</CSTAT>", cStatus)
cStatus := SubStr(cStatus,1,nPosic-1)

oXML := Nil

Return cStatus

//----------------------------------------------------------
/*/{Protheus.doc} L783RetXML
Retorna a dados do XML

@type function

@author  Varejo
@version P12.1
@since   30/08/2016

@param	cXML		XML da NFC-e
@return aRet		Array com dados do XML
/*/
//----------------------------------------------------------
Static Function L783RetXML(cXML,lInutiliza)
Local aRet	 	:= {}
Local oXML 		:= Nil
Local lRetXMLMng:= .T.
Local nVlrTotal := 0 //Valor total da venda
Local cMsgAbort := ""
Local cMod		:= "" //Modelo do documento (Nfe/Nfce)

//Instancia um OBJETO da classe TXML Manager
oXML := TXMLManager():New()

//Executa o PARSE na string XML
lRetXMLMng := oXML:Parse( cXML )

If !lRetXMLMng
	//Se deu algum problema no PARSE, tenta retirar do XML o caracter CHR(10) que pode ser o causador do problema
	cXML := Replace(cXML,Chr(10), "")
	
	//Tenta fazer o PARSE novamente
	lRetXMLMng := oXML:Parse( cXML )
EndIf

//Registra o NAMESPACE do arquivo XML
If lRetXMLMng
	lRetXMLMng := oXML:XPathRegisterNS( "ns", "http://www.portalfiscal.inf.br/nfe" )
	If !lRetXMLMng
		cMsgAbort := STR0029 + oXML:Error()		//"ERRO ao registrar o NAMESPACE: "
	EndIf
Else
	If !Empty( oXML:Error() )
		cMsgAbort := STR0030 + oXML:Error()	//"ERRO ao executar o método PARSE: "
	ElseIf !Empty( oXML:Warning() )
		cMsgAbort := STR0031 + oXML:Warning()	//"AVISO ao executar o método PARSE: "
	EndIf
EndIf

If lRetXMLMng
	
	
	If lInutiliza //Se for inutilizacao
		cMod 		:= oXML:XPathGetNodeValue( "/ns:inutNFe/ns:infInut/ns:mod" )  //Modelo do documento
	Else
		cMod 		:= oXML:XPathGetNodeValue( "/ns:NFe/ns:infNFe/ns:ide/ns:mod" )  //Modelo do documento
		nVlrTotal 	:= Val(oXML:XPathGetNodeValue( "/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vNF" )) //Valor total da venda
	EndIf

Else
	MsgStop(cMsgAbort)
EndIf

oXML := Nil

aAdd( aRet, nVlrTotal ) //01-Valor total da venda
aAdd( aRet, cMod ) //02-Modelo do documento (Nfe/Nfce)

Return aRet

//----------------------------------------------------------
/*/{Protheus.doc} Lj783Grava
Grava registro na tabela MH5.

@type function

@author  Varejo
@version P12.1
@since   30/08/2016

@param	
@return Nil
/*/
//----------------------------------------------------------
Static Function Lj783Grava(	aDados )
Local lAppend 	:= .T.

DbSelectArea("MH5")
MH5->(DbSetOrder(1)) //MH5_FILIAL+MH5_DTMOV+MH5_PDV+MH5_SERIE+MH5_TIPDOC
If MH5->(DbSeek(xFilial("MH5")+dTos(aDados[01])+aDados[02]+aDados[03]+aDados[04]))
	lAppend := .F. //Atualiza
Else
	lAppend := .T. //Inclui
EndIf

RecLock("MH5", lAppend)
MH5->MH5_FILIAL	:= xFilial("MH5")
MH5->MH5_DTMOV	:= aDados[01] 	//Data do movimento
MH5->MH5_PDV	:= aDados[02]	//PDV
MH5->MH5_SERIE	:= aDados[03]	//Serie
MH5->MH5_TIPDOC	:= aDados[04]	//Tipo de Documento (NFC-e)
MH5->MH5_DTGER	:= dDataBase
MH5->MH5_TOTPRT	:= aDados[05]	//Valor de vendas Total Protheus
MH5->MH5_TOTTRM	:= aDados[06]	//Valor de vendas Total Transmitido no TSS
MH5->MH5_TOTDIF	:= Abs( MH5->MH5_TOTPRT - MH5->MH5_TOTTRM ) //Diferenca de valor de vendas entre Protheus e valor de vendas Transmitido no TSS
MH5->MH5_VCANPT	:= aDados[09]	//Valor de Cancelamentos no Protheus
MH5->MH5_VCANTR	:= aDados[10]	//Valor de Cancelamentos Transmitido no TSS
MH5->MH5_QCANTR	:= aDados[07]	//Quantidade de Cancelamentos no TSS
MH5->MH5_QINUTR	:= aDados[08]	//Quantidade de Inutilizacao no TSS
MH5->MH5_QTDVSF	:= aDados[12]	//Quantidade venda SEFAZ
MH5->MH5_QTDVPT	:= aDados[11]	//Quantidade venda Protheus
MH5->MH5_QTDDIV	:= Abs( MH5->MH5_QTDVSF - MH5->MH5_QTDVPT )	//Quantidade venda divergente
MH5->(MsUnLock())

Return

//----------------------------------------------------------
/*/{Protheus.doc} Lj783Vendas
Busca as vendas que foram realizadas no dia em determinado PDV e Serie.

@type function

@author  Varejo
@version P12.1
@since   30/08/2016

@param	
@return aRet
/*/
//----------------------------------------------------------
Static Function Lj783Vendas( dDataMov, cPDV, cSerieFil, lUsaSat )
Local aRet 		:= {}
Local cQuery 	:= ""
Local cEspecie 	:= If(lUsaSat,"SATCE","NFCE")

cQuery := "SELECT FT_NFISCAL, FT_SERIE, SUM(FT_VALCONT) VALCONT " 
cQuery += "  FROM " + RetSQLName("SFT") + " SFT,"
cQuery += "       " + RetSQLName("SF2") + " SF2 "
cQuery += " WHERE FT_FILIAL = '"+xFilial("SFT")+"'"
cQuery += "   AND F2_FILIAL = '"+xFilial("SF2")+"'"
cQuery += "   AND FT_TIPOMOV = 'S'"
cQuery += "   AND FT_ENTRADA = '"+dToS(dDataMov)+"'"
cQuery += "   AND FT_SERIE = '"+cSerieFil+"'"
cQuery += "   AND F2_PDV = '"+cPDV+"'"
cQuery += "   AND F2_DOC = FT_NFISCAL"
cQuery += "   AND F2_SERIE = FT_SERIE"
cQuery += "   AND F2_EMISSAO = FT_ENTRADA"
cQuery += "   AND FT_ESPECIE = '"+cEspecie+"'"
cQuery += "   AND FT_DTCANC = '        '" 
cQuery += "   AND SFT.D_E_L_E_T_ = ' '"
cQuery += "   AND SF2.D_E_L_E_T_ = ' '"
cQuery += " GROUP BY FT_NFISCAL, FT_SERIE"
cQuery += " ORDER BY FT_NFISCAL, FT_SERIE"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYSFT",.F.,.T.)        

While QRYSFT->( !EoF() )	
	aAdd( aRet, { 	QRYSFT->FT_NFISCAL	,;	//01-DOC
					QRYSFT->FT_SERIE	,;	//02-SERIE
					QRYSFT->VALCONT		,;	//03-Valor Total da Venda no Protheus
					0					,;	//04-Valor Total da Venda no TSS (Sera preenchido posteriormente)
					"1" 				} )	//05-Para indicar onde esta este DOC e Serie: (1=Protheus; 2=TSS; 3=Protheus e TSS)
					
	QRYSFT->(DbSkip())
End

QRYSFT->(DbCloseArea())

Return aRet

//----------------------------------------------------------
/*/{Protheus.doc} Lj783Cancel
Busca os Cancelamentos/Inutilizacoes no dia para determinado PDV e Serie.

@type function

@author  Varejo
@version P11.8
@since   30/08/2016

@param	
@return aRet
/*/
//----------------------------------------------------------
Static Function Lj783Cancel( dDataMov, cPDV, cSerieFil, lUsaSat )
Local aRet 		:= {}
Local cQuery 	:= ""
Local cProdInut := SuperGetMV("MV_INUTPRO", .F., "") //Codigo do Produto configurado para inutilizacao de Nota/NFC-e
Local cEspecie 	:= iIf(lUsaSat,"SATCE","NFCE")

cProdInut := PadR(cProdInut, TamSX3("FT_PRODUTO")[1] )

If !lUsaSat //Só procura por inutilização caso o PDV não seja SAT
	cQuery := "SELECT FT_NFISCAL, FT_SERIE, SUM(FT_VALCONT) VALCONT, 'INUT' TIPOCANC, FT_NFISCAN " 
	cQuery += "  FROM " + RetSQLName("SFT")
	cQuery += " WHERE FT_FILIAL = '"+xFilial("SFT")+"'"
	cQuery += "   AND FT_TIPOMOV = 'S'"
	cQuery += "   AND FT_SERIE = '"+cSerieFil+"'"
	//cQuery += "   AND FT_PDV = '"+cPDV+"'" //Campo PDV nao eh gravado ?
	cQuery += "   AND FT_DTCANC = '"+dToS(dDataMov)+"'"
	cQuery += "   AND FT_PRODUTO =	'"+cProdInut+"'"
	cQuery += "   AND FT_ESPECIE = '"+cEspecie+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY FT_NFISCAL, FT_SERIE, FT_NFISCAN"
	cQuery += " UNION "
EndIf
cQuery += "SELECT FT_NFISCAL, FT_SERIE, SUM(FT_VALCONT) VALCONT, 'CANC' TIPOCANC, FT_NFISCAN " 
cQuery += "  FROM " + RetSQLName("SFT")
cQuery += " WHERE FT_FILIAL = '"+xFilial("SFT")+"'"
cQuery += "   AND FT_TIPOMOV = 'S'"
cQuery += "   AND FT_SERIE = '"+cSerieFil+"'"
//cQuery += "   AND FT_PDV = '"+cPDV+"'" //Campo PDV nao eh gravado ?
cQuery += "   AND FT_DTCANC = '"+dToS(dDataMov)+"'"
cQuery += "   AND FT_PRODUTO <> '"+cProdInut+"'"
cQuery += "   AND FT_ESPECIE = '"+cEspecie+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
cQuery += " GROUP BY FT_NFISCAL, FT_SERIE, FT_NFISCAN"
cQuery += " ORDER BY FT_NFISCAL, FT_SERIE"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYSFT",.F.,.T.)

While QRYSFT->( !EoF() )	
	aAdd( aRet, { 	QRYSFT->FT_NFISCAL	,;	//01-DOC
					QRYSFT->FT_SERIE	,;	//02-SERIE
					QRYSFT->VALCONT		,;	//03-Valor Total do Cancelamento no Protheus
					0					,;	//04-Valor Total do Cancelamento no TSS (Sera preenchido posteriormente)
					"1" 				,;	//05-Para indicar onde esta cancelado este DOC: (1=Protheus; 2=TSS; 3=Protheus e TSS)
					QRYSFT->TIPOCANC	,;	//06-Indica se a nota esta Cancelada (CANC) ou Inutilizada (INUT)
					QRYSFT->FT_NFISCAN	} )	//07-Número do Cupom SAT que efetuou o Cancelamento desta venda
						
	QRYSFT->(DbSkip())
End

QRYSFT->(DbCloseArea())

Return aRet

//----------------------------------------------------------
/*/{Protheus.doc} Lj783Detal
Gera em relatorio os detalhes das diferencas encontradas.

@type function

@author  Varejo
@version P12.1
@since   30/08/2016

@param	
@return aRet
/*/
//----------------------------------------------------------
Static Function Lj783Detal( aDados )
Local aCab 		:= {}
Local oReport
Local oSection 
Local nX 		:= 0
Local cTitulo	:= STR0043 //"Divergências dos documentos eletrônicos"

//Definicao do Cabecalho das colunas
			//Nome        Tamanho
AAdd( aCab, {"Filial" 						, 15	} )
AAdd( aCab, {"Data"							, 15	} )
AAdd( aCab, {"Doc" 							, 15	} )
AAdd( aCab, {"Serie" 						, 10	} )
AAdd( aCab, {"Tipo Doc"						, 10	} )
AAdd( aCab, {"Vlr Protheus (FT_VALCONT)" 	, 15	} )
AAdd( aCab, {"Vlr TSS (SPED050)"			, 15	} )
AAdd( aCab, {"Mensagem" 					, 100	} )

aSort( aDados,,, {|a,b| a[1]+dToS(a[2])+a[3]+a[4] < b[1]+dToS(b[2])+b[3]+b[4] })

oReport := TReport():New( "LOJA783", cTitulo, , {|oReport| L783RunImp( oReport, aDados )}, cTitulo )	//"Divergências dos documentos eletrônicos"

DEFINE SECTION oSection OF oReport TITLE cTitulo TOTAL IN COLUMN	//"Divergências dos documentos eletrônicos"

For nX := 1 To Len(aCab)
	DEFINE CELL NAME "CEL"+Alltrim(Str(nX-1)) OF oSection SIZE aCab[nX][2] TITLE aCab[nX][1]
Next nX

//Define o espaçamento entre as colunas
oSection:SetColSpace(0)

//Define que a impressão poderá ocorrer em uma ou mais linhas no caso das colunas exederem o tamanho da página
oSection:SetLineBreak(.T.)

oReport:PrintDialog()
	
Return .T.


//----------------------------------------------------------
/*/{Protheus.doc} L783RunImp
Impressão dos dos dados no relatorio.

@type function

@author  Varejo
@version P12.1
@since   30/08/2016

@param	
@return Nil
/*/
//----------------------------------------------------------
Static Function L783RunImp( oReport, aDados )
Local oSection := oReport:Section(1) // Retorna objeto da classe TRSection (secao).
Local nX := 0
Local nY := 0

oReport:lEmptyLineExcel := .F. //Suprimir linhas em branco para impressao no Excel

//Define o limite da regua de progressão do relatorio
oReport:SetMeter( Len( aDados ) )	

oSection:Init()

For nX := 1 To Len( aDados )
	
	// Retorna se o usuario cancelou a impressão do relatorio
	If oReport:Cancel()
		Exit
	EndIf
	
	For nY := 1 To Len(aDados[ nX ])
	   If ValType( aDados[ nX, nY ] ) == 'D'
	   	oSection:Cell("CEL"+Alltrim(Str(nY-1))):SetBlock( &("{ || '" + Dtoc(aDados[ nX, nY ]) + "'}") )
	   Elseif ValType( aDados[ nX, nY ] ) == 'N'
	   	oSection:Cell("CEL"+Alltrim(Str(nY-1))):SetBlock( &("{ || '" + TransForm(aDados[ nX, nY ],'@E 999,999,999.99') + "'}") )
	   Else
	   	oSection:Cell("CEL"+Alltrim(Str(nY-1))):SetBlock( &("{ || '" + aDados[ nX, nY ] + "'}") )
	   Endif
	Next
	
	// Incrementa a regua de progressao do relatorio
	oReport:IncMeter()
	
	//Imprime a linha baseado nas celulas existentes
	oSection:PrintLine()
Next

//Finaliza a impressao do relatorio
oSection:Finish()

Return

//----------------------------------------------------------
/*/{Protheus.doc} LjVerSeqNF
Funcao que verifica o sequeciamento da Nota, para saber se 
existe algum pulo de numeracao de nota.

@type function

@author  Varejo
@version P12.1
@since   30/08/2016

@param	
@return Nil
/*/
//----------------------------------------------------------
Static Function LjVerSeqNF( aDoctos, aInconsist, cFil, dDataMov, aCancelados, cDescDoc )
Local cXml 		:= ""
Local cXmlProt	:= ""
Local cDoc		:= ""
Local cDocAux	:= ""
Local cSerie	:= ""
Local nZ 		:= 0
Local nDocAnt	:= ""
Local cStatus	:= ""
Local nPosic 	:= 0
Local lVerDocTSS:= .F. //Indica se deve verificar o DOC no TSS

If Len(aDoctos) > 0	

	aSort( aDoctos,,, {|a,b| a[1] < b[1] })
	
	nDocAnt := Val(aDoctos[1][1])-1 //Comeca com o primeiro numero de documento -1
	
	For nZ := 1 to Len(aDoctos)
		cDoc 	:= aDoctos[nZ][1]
		cSerie	:= aDoctos[nZ][2]
		
		While (nDocAnt+1) < Val(cDoc)
			
			cDocAux := StrZero(nDocAnt+1,Len(cDoc))
			
			nPosic := aScan( aCancelados, { |x| cDocAux+cSerie == x[1]+x[2] } )
			If nPosic > 0
				//Verifica se o DOC cancelado/inutilizado existe apenas no Protheus, para a data processada
				If aCancelados[nPosic][5] == "1" //1=Protheus; 2=TSS; 3=Protheus e TSS
					lVerDocTSS := .T.
				Else
					lVerDocTSS := .F.
				EndIf
			Else
				lVerDocTSS := .T.
			EndIf
			
			//Busca no TSS o XML de Protocolo do Documento, para saber se o documento esta cancelado/inutilizado
			If lVerDocTSS .And. LjNfceGet( @cXml, @cXmlProt, cDocAux, cSerie, .F., 2 )
				If !Empty(cXmlProt) //Verifica se tem o protocolo de retorno do SEFAZ, referente a transmissao do cancelamento/inutilizacao
					cStatus := Lj783SitNF( cXmlProt )
					
					//Verifica se o Doc esta cancelado ou inutilizado
					If !( cStatus $ "101|151|155" .Or. cStatus $ "102" ) //101|151|155=Cancelado;  102=Inutilizado
						AAdd( aInconsist, { cFil, dDataMov, cDocAux, cSerie, cDescDoc,"0,00","0,00",STR0033 } )	//"Detectado Pulo de numeração deste documento."
					EndIf
					
		        Else
		        	AAdd( aInconsist, { cFil, dDataMov, cDocAux, cSerie, cDescDoc,"0,00","0,00",STR0033 } )	//"Detectado Pulo de numeração deste documento."
		        EndIf
					
			EndIf
			
			nDocAnt++
		
		End
		
		nDocAnt++
			
	Next nZ

EndIf
	
Return

//----------------------------------------------------------
/*/{Protheus.doc} LjIsCanPrt
Verifica se o Documento existe no Protheus como "Cancelado/Inutilizado"

@type function

@author  Varejo
@version P12.1
@since   03/10/2016

@param	
@return lRet (.T. = Existe o Docuemnto no Protheus; .F. = Nao existe o Docuemnto no Protheus)
/*/
//----------------------------------------------------------
Static Function LjIsCanPrt(aCancelados, cNumNota, cSerNota, nVlrCanTSS)
Local lRet		:= .F.
Local nPosic	:= 0

//Verifica se para este DOC e Serie do TSS, existe o Cancelamento no Protheus tambem
If ( nPosic := aScan( aCancelados, { |x| cNumNota+cSerNota == x[1]+x[2] } ) ) > 0
	
	//Se no Protheus estiver como INUTILIZADA, porem no TSS estiver como CANCELADA, significa que pode ter ocorrido algum problema 
	//na finalizacao da venda apos ja ter transmitido o documento no TSS.
	//Devido o tratamento no Protheus para recuperar a venda ou inutilizar o Documento quando ocorrer algum problema na finalizacao da venda,
	//o DOC pode ter ficado como "Inutilizado" no Protheus porem ficou como "Cancelado" no TSS, devido este DOC ja ter sido transmitido no TSS, 
	//entao neste caso qdo. manda pra inutilizacao na verdade eh feito o cancelamento no TSS pelo motivo do DOC ja existir no TSS como transmitido.
	If aCancelados[nPosic][6] == "INUT"
		//Atualiza o valor de cancelamento no Protheus igual ao que esta no TSS, pois neste caso nao pode apresentar diferenca
		aCancelados[nPosic][3] := nVlrCanTSS
	EndIf
	
	aCancelados[nPosic][4] := nVlrCanTSS
	If aCancelados[nPosic][5] == "1" //1=Cancelado no Protheus
		aCancelados[nPosic][5] := "3" //Seta para indicar que o DOC/Serie esta cancelado tambem no TSS (1=Protheus; 2=TSS; 3=Protheus e TSS)
	EndIf
	
	lRet := .T.

Else
	
	//Se nao encontrou o DOC (Cancelado/Inutilizado) no Protheus na data em questao, verifica se o mesmo existe em outra data, pois pode ter ocorrido da 
	//solicitacao do cancelamento no Protheus ser realizado em um dia, porem a autorizacao do cancelamento no TSS pode ocorrer no dia seguinte.
	DbSelectArea("SFT")
	SFT->(DbSetOrder(1)) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
	If SFT->(DbSeek(xFilial("SFT")+"S"+cSerNota+cNumNota)) .And. !Empty(SFT->FT_DTCANC)
		lRet := .T.
	EndIf
	
EndIf

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} LjIsCanTSS
Verifica se o Documento existe no TSS como "Cancelado/Inutilizado"
@type function
@author  Varejo
@since   03/10/2016
@return lRet (.T. = Existe o Documento no TSS; .F. = Nao existe o Documento no TSS)
/*/
//----------------------------------------------------------
Static Function LjIsCanTSS(cNumNota, cSerNota, nVlrCanTSS,nVlrProt)
Local lRet		:= .F.
Local cXml 		:= ""
Local cXmlProt	:= ""
Local cStatus 	:= ""
Local aRetXML 	:= {}
Default nVlrProt := 0
//Verifica se para este DOC e Serie do Protheus, existe o Cancelamento/Inutilizacao no TSS tambem
If LjNfceGet( @cXml, @cXmlProt, cNumNota, cSerNota, .F., 2 ) //Busca no TSS o XML do Documento
	If !Empty(cXmlProt) //Verifica se tem o protocolo de retorno do SEFAZ, referente a transmissao do cancelamento/inutilizacao
		cStatus := Lj783SitNF( cXmlProt )
		If cStatus $ "101|151|155" //Cancelado
			//Verifica qual o valor total da nota que foi cancelada
			aRetXML := L783RetXML(cXml,.F.)
			
			nVlrCanTSS := aRetXML[01] //01-Valor total do cancelamento na nota no TSS
			If nVlrCanTSS = 0  			// No caso de cancelamentos do dia anterior nao conseguimos pegar o valor do canc 
				nVlrCanTSS := nVlrProt  // Nesse caso ele da como OK , pois o cancelamento foi efetuado
			EndIf

			lRet := .T.
		ElseIf cStatus == "102" //Inutilizado
			nVlrCanTSS := 0
			lRet := .T.
		EndIf
	EndIf
EndIf
	
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} Lj783VldSat
Validação dos orçamentos SAT - Vendas e Cancelamentos
@type 	Function
@author bruno.inoue
@since  21/02/2017
@return aRet
/*/
//----------------------------------------------------------
Static Function Lj783VldSat(aVendas,aCancelados,dDataMov)
Local aInfoSEFAZ	:= {}		//Vendas e Cancelamentos retornados da SEFAZ
Local aRet			:= {}		//Retorno da função
Local nX			:= 0		//Contador
Local nZ			:= 0		//Contador
Local cDataMov		:= ""		//Data incial da consulta
Local nQtdCanSFZ	:= 0		//Quantidade de cancelamentos SEFAZ
Local nTotVdaPrt	:= 0		//Valor total de vendas no Protheus
Local nTotCanPrt	:= 0		//Valor total de cancelamento Protheus
Local nQtdVenPrt	:= 0		//Quantidade de vendas Protheus
Local nQtdVenSef	:= 0		//Quantidade de vendas SEFAZ
Local aInconsist	:= {}		//Vendas e Cancelamentos com algum problema
Local cMVLJCHSAT	:= ""		//Token de acesso para informações do lote da filial na SEFAZ 
Local cMVVERSAT		:= ""		//Versão do layout do SAT
Local cSerieSAT		:= ""		//Serie do equipamento SAT
Local cDescDoc		:= "SATCF-e"//Descrição do tipo de documento
Local aVdasSefaz	:= {}	 	//Relacao de Vendas transmitidas na SEFAZ
Local aCancSefaz	:= {}	 	//Relacao de Cancelamentos transmitidas na SEFAZ
Local cCupom 		:= ""
Local nPosic 		:= 0

Default aVendas 	:= {}
Default aCancelados := {}

cDataMov 	:= Replace(DtoC(dDataMov),"/","")
cMVLJCHSAT 	:= SuperGetMV("MV_LJCHSAT",,"")
cMVVERSAT 	:= SuperGetMV("MV_VERSAT",,"")
cSerieSAT	:= LJGetStation("SERSAT")

//Ordenação dos arrays de venda e cancelamento
aSort( aVendas,,, {|a,b| a[5]+a[1]+a[2] < b[5]+b[1]+b[2] })
aSort( aCancelados,,, {|a,b| a[5]+a[1]+a[2] < b[5]+b[1]+b[2] })

//Consulta SEFAZ
aInfoSEFAZ := LjSefazSat(cSerieSAT,cDataMov,cDataMov,cMVLJCHSAT,,cMVVERSAT)

If Len(aInfoSEFAZ) > 0

	aVdasSefaz := aInfoSEFAZ[1]
	aCancSefaz := aInfoSEFAZ[2]

	nQtdVenPrt := Len(aVendas)
	nQtdCanSFZ := Len(aCancSefaz)

	//Compara os arrays para saber quais vendas estão no Protheus e no SEFAZ
	For nZ := 1 To Len(aVdasSefaz)

		cCupom := AllTrim(aVdasSefaz[nZ][3])

		//Verifica se a venda que esta no SEFAZ, existe também no Protheus
		If ( nPosic := aScan( aVendas, { |x| cCupom == AllTrim(x[1]) } ) ) > 0
			aVendas[nPosic][5] := "3" //Seta para indicar que o Cupom existe no Protheus e no SEFAZ (1=Protheus; 2=SEFAZ; 3=Protheus e SEFAZ)
		Else
			//Verifica se este DOC esta cancelado, pois o SEFAZ retorna no array aVdasSefaz o DOC da venda que foi transmitido e no array aCancSefaz retorna o DOC de referencia que fez o cancelamento da venda
			If aScan( aCancelados, { |x| cCupom == AllTrim(x[1]) } ) == 0
				aAdd( aVendas, {cCupom			,;	//01-DOC
								cSerieSAT  		,;	//02-SERIE
								0				,;	//03-Valor Total da Venda no Protheus
								0				,;	//04-Valor Total da Venda na SEFAZ
								"2" 			} )	//05-Seta para indicar que o DOC existe apenas no SEFAZ (1=Protheus; 2=SEFAZ; 3=Protheus e SEFAZ)
			EndIf
		EndIf

	Next nZ

	//Compara os arrays para saber quais cancelamentos de vendas estão no Protheus e no SEFAZ
	For nZ := 1 To Len(aCancSefaz)

		cCupom := AllTrim(aCancSefaz[nZ][3])

		//Verifica se a venda que esta no SEFAZ, existe também no Protheus
		If ( nPosic := aScan( aCancelados, { |x| cCupom == AllTrim(x[7]) } ) ) > 0
			aCancelados[nPosic][5] := "3" //Seta para indicar que o Cupom existe no Protheus e no SEFAZ (1=Protheus; 2=SEFAZ; 3=Protheus e SEFAZ)
		Else
			aAdd( aCancelados, {cCupom			,;	//01-DOC
								cSerieSAT  		,;	//02-SERIE
								0				,;	//03-Valor Total da Venda no Protheus
								0				,;	//04-Valor Total da Venda na SEFAZ
								"2" 			,;	//05-Seta para indicar que o DOC existe apenas no SEFAZ (1=Protheus; 2=SEFAZ; 3=Protheus e SEFAZ)
								"CANC" 			,;	//06-Indica que o DOC esta CANCELADO
								cCupom 			} )	//07-Número do Cupom SAT que efetuou o Cancelamento desta venda
		EndIf

	Next nZ

	//Percorre array de Vendas para fazer a verificacao de inconsistencias para gerar o relatorio final.
	For nZ := 1 to Len(aVendas)
		nTotVdaPrt += aVendas[nZ][3] //Totaliza o valor de Vendas existente no Protheus
		
		If aVendas[nZ][5] == "1" //O DOC existe apenas no Protheus (1=Protheus; 2=SEFAZ; 3=Protheus e SEFAZ)
			AAdd( aInconsist, { cFilAnt, dDataMov, aVendas[nZ][1], cSerieSAT, cDescDoc,"0,00","0,00",STR0038 } ) //"SAT - Venda não consta na SEFAZ"
		Else
			nQtdVenSef++
			If aVendas[nZ][5] == "2" //O DOC existe apenas no SEFAZ (1=Protheus; 2=SEFAZ; 3=Protheus e SEFAZ)
				AAdd( aInconsist, { cFilAnt, dDataMov, aVendas[nZ][1], cSerieSAT, cDescDoc,"0,00","0,00",STR0023 } ) //"SAT - Venda não consta no Protheus"
			EndIf
		EndIf
	Next nZ

	//Percorre array de Cancelamentos para fazer a verificacao de inconsistencias para gerar o relatorio final.
	For nZ := 1 to Len(aCancelados)
		nTotCanPrt += aCancelados[nZ][3]

		If aCancelados[nZ][5] == "1" //Verifica se o DOC existe apenas no Protheus (1=Protheus; 2=SEFAZ; 3=Protheus e SEFAZ)
			AAdd( aInconsist, { cFilAnt, dDataMov, aCancelados[nZ][1], cSerieSAT, cDescDoc,"0,00","0,00", STR0040 } ) //"SAT - Cancelamento não consta na SEFAZ"
		ElseIf aCancelados[nZ][5] == "2" //Verifica se o DOC existe apenas no SEFAZ (1=Protheus; 2=SEFAZ; 3=Protheus e SEFAZ)
			AAdd( aInconsist, { cFilAnt, dDataMov, aCancelados[nZ][1], cSerieSAT, cDescDoc,"0,00","0,00", STR0041 } ) //"SAT - Cancelamento não consta no Protheus"
		EndIf
	Next nZ
		
	aRet := { 	nQtdCanSFZ,;	//01-Quantidade cancelamentos Sefaz
				nTotVdaPrt,;	//02-Total vendas Protheus
				nQtdVenPrt,;	//03-Quantidade de vendas Protheus
				nQtdVenSef,;	//04-Quantidade de vendas Sefaz
				aInconsist }	//05-Inconsistencia
EndIf

Return aRet

//----------------------------------------------------------
/*/{Protheus.doc} LjSituaCan
Verifica a situação atual da nota nas tabelas do LOJA (SL1 ou SLX).

@type function

@author  albertod
@version P12.1
@since   04/06/2019

@param	cSerNota	Série da nota
@param	cNumNota	Número da nota
@return cRetSit Retorna a situação atual da nota nas tabelas do LOJA (SL1 ou SLX).
/*/
//----------------------------------------------------------
Static Function LjSituaCan(cSerNota, cNumNota)
Local cRetSit	:= ""
Local cAliasQry := ""

DbSelectArea("SL1")
SL1->(DbSetOrder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
If SL1->(DbSeek(xFilial("SL1")+cSerNota+cNumNota))
	cRetSit := SL1->L1_SITUA
Else
	cAliasQry := GetNextAlias()

	BeginSql alias cAliasQry

	SELECT	LX_SITUA
	FROM %table:SLX%
	WHERE	LX_FILIAL = %xfilial:SLX%  	AND
			LX_CUPOM  = %exp:cNumNota% 	AND
			LX_SERIE  = %exp:cSerNota% 	AND
			LX_MODDOC <> '  ' 			AND
			%notDel%

	EndSql

	If (cAliasQry)->( !EOF())
		cRetSit := (cAliasQry)->LX_SITUA
	EndIf

	(cAliasQry)->(DbCloseArea())

EndIf

Return cRetSit
