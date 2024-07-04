#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "OGA250.ch"

Static __aTab1221:= {"N83"} //tabelas SLC - previsão liberação 1220
Static __lLib1221:= .F. //Proteção de fonte para liberação 12.20 SLC
Static __lnewNeg := SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio
Static __aRfVenda:= {} // Array utilizado para armazenar as regras fiscais da ie de venda antes de trocar para regra da armazenagem

/** {Protheus.doc} OGA250G
Rotina para fechamento do romaneio

@param: 	cAlias - Tabela do Romaneio
@param: 	nReg - Registro para atualizacao
@param: 	nAcao - Tipo de atualizacao
@param: 	lAuto - Se automatica para nao exibir mensagens
@return:	Nil
@author: 	Vitor Alexandre de Barba
@since: 	13/10/2014
@Uso: 		OGA250 - Romaneio
*/
Function OGA250G(cAlias, nReg, nAcao, lAuto, cNumOP)
	Local lRetorno		:= .T.
	Local lRetArm		:= .T.
	Local aAreaAtu  	:= GetArea()
	Local cQryNJMNf		:= GetNextAlias() 
	Local cSerie		:= " "
	Local aRet 			:= {}
	Local aChvNJM		:= {}
	Local nX			:= 0
	Local cMsgErro		:= ""
	Local cNrPedExp		:= ""
	Local lExport		:= .F.
	Local lTemRastro    := .F.
	Local lAlgodao		:= NIL
	Local lAntecip      := .F.
	Local lQrbPrc       := SuperGetMV("MV_AGRO209",, .F.)
    Local cModoMov      := SuperGetMV("MV_AGRO045",.F.,"")
	
	Default cNumOP		:= ""

	//Atualiza automaticamente a data base do sistema na virada do dia
	FwDateUpd(.F.,.F.)

    If Empty(cModoMov) 
        If __lnewNeg
            cModoMov := "3" //via ordem de produção
        else
            cModoMov := "1" //via movimentação interna    
        EndIf    
    EndIf

	If SB5->(ColumnPos('B5_TPCOMMO')) > 0 .and. __lnewNeg
		lAlgodao		:= if(Posicione("SB5",1,fwxFilial("SB5")+NJJ->NJJ_CODPRO,"B5_TPCOMMO")== '2',.T.,.F.)
	EndIf

	__lLib1221 := AGRTABDIC(__aTab1221) //verifica se array de tabelas existe no dicionario de dados - para proteção fonte SLC

	If  NJJ->(NJJ_STATUS) != "2" //0=Pendente;1=Completo;2=Atualizado;3=Confirmado;4=Cancelado		
		If .Not. lAuto 
			AgrHelp(STR0021, STR0210, STR0023) //'HELP'###"Romaneio não foi confimado."###"Somente Romaneios com status de -Atualizado- podem ser -Confirmados-."
		EndIf

		RestArea(aAreaAtu)
		Return .F.  // A lRetorno ira retornar .t. ou .f. aqui nao posso retornar nil tenho q padronizar
	EndIf

	If NJJ->(NJJ_TIPO) == "1" 	
		//-- ROMANEIO POR PRODUÇÃO	
        If(AGRGRAVAHIS(,,,,{"NJJ",NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM,"N",STR0040})) = 1
			Begin Transaction	
			If cModoMov == "1" //gera apenas mov. interna
                
                lRetorno := OGX013() //realiza a movimentação

				If .NOT. lRetorno //OCORREU ALGUM ERRO
                    DisarmTransaction()
					BREAK //Faz ir direto para o fim da transação - end transaction
                EndIf

            ElseIf cModoMov == "2" //Não gera nenhuma movimentação
                If RecLock( "NJJ", .f. )										
					NJJ->( NJJ_STATUS ) := "3"					
					msUnLock()
				EndIf

            ElseIf cModoMov == "3" //3 - gera ordem produção                
                //-- NOVO PROCESSO DE MOVIMENTAÇÃO - FONTE AGRX500
                IF .NOT. Empty(NJJ->NJJ_CODPRO) .AND. .NOT. Empty(NJJ->NJJ_PSLIQU) .AND. .NOT. Empty(NJJ->NJJ_LOCAL)
                    
                        If __lnewNeg
                            if lAlgodao
                                //--Grava peso no fardão DXL - SE TEM FARDO VINCULADO ATUALIZA O PESO SEMPRE
                                lRetorno := AGRX500DXL(NJJ->NJJ_PSLIQU)
                            endIf

                            If lRetorno
                                //--Verifica se existe pendencias com peso estimado maior que zero
                                lRetorno := AGRX500PEN(NJJ->NJJ_CODROM, NJJ->NJJ_CODSAF, NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT, NJJ->NJJ_PSLIQU, @lTemRastro)

                                If .NOT. lRetorno
                                    DisarmTransaction()
									BREAK //Faz ir direto para o fim da transação - end transaction
                                EndIf 
                            EndIF		
                        EndIf

                        If lRetorno .AND. !(lTemRastro)
                            //-- Gera ordem de produção
                            //Retorno := (Numero da OP - Modelo - Operação de Inclusão)
                            If Empty(cNumOP)
                                Processa({|| lRetorno := A500GERAOP(@cNumOP, NJJ->NJJ_CODPRO, NJJ->NJJ_PSLIQU, NJJ->NJJ_LOCAL, 3) }, STR0345, STR0347 ) //"Gerando Ordem de Produção..."###"Aguarde"
                            Endif	

                            If lRetorno
                                //-- Realiza o apontamento da OP 
                                //Retorno := (Numero da OP - Modelo - Operação de Inclusão)
                                Processa({|| lRetorno := A500APROD(cNumOP,NJJ->NJJ_CODROM, NJJ->NJJ_CODPRO, NJJ->NJJ_PSLIQU, NJJ->NJJ_LOCAL, 3) }, STR0346, STR0347 ) //"Movimentando Ordem de Produção..."###"Aguarde"
                            EndIf

                            //--QUANDO FALSO
                            If .NOT. lRetorno
                                DisarmTransaction()
								BREAK //Faz ir direto para o fim da transação - end transaction
                            EndIf
                        EndIf                    
                EndIf  
            EndIf 
			
			/*INTEGRAÇÃO PIMS - EAI*/
			If lRetorno .AND. !Empty(NJJ->NJJ_ORDCLT) .And. NJJ->NJJ_PSLIQU > 0
				lRetorno := AGRA500Int()
				If !lRetorno
                    DisarmTransaction()  //se houver erro na integração não confirma romaneio e faz rollback
                EndIf
			EndIf
			
			End Transaction       

		Endif

		RestArea(aAreaAtu)

    Else
		//--demais romaneios

		If .Not. OGA250ENTOK() // Valida informações do fornecedor associado a entidade
			RestArea(aAreaAtu)		
			Return .F.  // A lRetorno ira retornar .t. ou .f. aqui nao posso retornar nil tenho q padronizar
		EndIf
		If __lnewNeg
			If .Not. OGA250IEOK()
				RestArea(aAreaAtu)
				Return .F.
			EndIf
		EndIf
		// Função para auto-healing (auto-cura) do romaneio, caso o mesmo já tenha NF gerada
		If .Not. fAjustaFiscal(NJJ->(NJJ_CODROM))
			AGRGRAVAHIS(,,,,{"NJJ",xFilial("NJJ")+NJJ->(NJJ_CODROM),"N", STR0010 + " " + STR0168})	//"Confirmar"###"(auto-cura)"

			RestArea(aAreaAtu)		
			Return .F.  // A lRetorno ira retornar .t. ou .f. aqui nao posso retornar nil tenho q padronizar
		EndIf

		If NJJ->(NJJ_TIPO) $ "3|5|7|9" .AND. .NOT. OGXN8MVLD() //validação do campo N8M
			Return .F.
		EndIf

		// Agrupa para geração do Pedido de Venda e Documento de Entrada
		//// 29/01/15 - Incluido o campo NJM_CODCTR no group by, para gerar uma NF por contrato, caso contrário dá problema com o financeiro

		If(AGRGRAVAHIS(,,,,{"NJJ",NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM,"N",STR0040})) = 1

			If __lnewNeg
				//Escolha automática do Lote para cada NJM
				Begin Transaction	
					lRetorno := OGA250LOT()
					If !lRetorno
						DisarmTransaction()
					EndIf
				End Transaction

				If !lRetorno
					RestArea(aAreaAtu)
					Return .F.
				EndIf
			EndIf
			cAliasNJM := GetNextAlias()
			If NJM->(ColumnPos('NJM_SEQPRI')) > 0 .and. __lnewNeg
				cQryNJMNf := " SELECT NJM_CODROM, NJM_CODENT, NJM_LOJENT, NJM_TIPMOV, NJM_DOCNUM, NJM_DOCSER, NJM_TIPO, NJM_CODCTR, NJM_TES, NJM_SEQPRI, NJM_SUBTIP, NJM_ITEM, MIN(NJM_ITEROM) AS NJM_ITEROM "
					If lQrbPrc
						cQryNJMNf += " , NJM_VLRUNI "
					EndIf	
					If NJM->(ColumnPos('NJM_NUMAVI')) > 0 .AND.;
						NJM->(ColumnPos('NJM_NUMDCO')) > 0 .AND.;
						NJM->(ColumnPos('NJM_SEQDCO')) > 0

						cQryNJMNf += ", NJM_NUMAVI, NJM_NUMDCO, NJM_SEQDCO "
					EndIf
			Else
				cQryNJMNf := " SELECT NJM_CODROM, NJM_CODENT, NJM_LOJENT, NJM_TIPMOV, NJM_DOCNUM, NJM_DOCSER, NJM_TIPO, NJM_CODCTR, NJM_TES, MIN(NJM_ITEROM) AS NJM_ITEROM , NJM_SUBTIP "
			EndIf
			cQryNJMNf += "   FROM " + RetSqlName("NJM") + " NJM "
			cQryNJMNf += "   WHERE NJM.NJM_FILIAL = '"+ FWxFilial("NJM") +"'"
			cQryNJMNf += "    AND NJM.NJM_CODROM = '"+ NJJ->(NJJ_CODROM) +"' "
			cQryNJMNf += "    AND NJM.NJM_STAFIS = '1' "
			cQryNJMNf += "    AND NJM.D_E_L_E_T_ = '' "
			If NJM->(ColumnPos('NJM_SEQPRI')) > 0 .and. __lnewNeg
				cQryNJMNf += "   GROUP BY NJM_CODROM,  NJM_SEQPRI , NJM_CODENT, NJM_LOJENT, NJM_TIPMOV, NJM_DOCNUM, NJM_DOCSER, NJM_TIPO, NJM_CODCTR, NJM_TES, NJM_SEQPRI, NJM_SUBTIP, NJM_ITEM"
				
				If lQrbPrc
					cQryNJMNf += " , NJM_VLRUNI "
				EndIf
		
				If NJM->(ColumnPos('NJM_NUMAVI')) > 0 .AND.;
						NJM->(ColumnPos('NJM_NUMDCO')) > 0 .AND.;
						NJM->(ColumnPos('NJM_SEQDCO')) > 0
						
					cQryNJMNf += ", NJM_NUMAVI, NJM_NUMDCO, NJM_SEQDCO "
				EndIf

				cQryNJMNf += "   ORDER BY NJM_CODROM,  NJM_SEQPRI , NJM_SUBTIP desc, NJM_CODENT, NJM_LOJENT, NJM_TIPMOV DESC, NJM_DOCNUM, NJM_DOCSER, NJM_TIPO, NJM_CODCTR "
				
			Else
				cQryNJMNf += "   GROUP BY NJM_CODROM, NJM_CODENT, NJM_LOJENT, NJM_TIPMOV, NJM_DOCNUM, NJM_DOCSER, NJM_TIPO, NJM_CODCTR, NJM_TES, NJM_SUBTIP "
				cQryNJMNf += "   ORDER BY NJM_CODROM, NJM_SUBTIP desc, NJM_CODENT, NJM_LOJENT, NJM_TIPMOV, NJM_DOCNUM, NJM_DOCSER, NJM_TIPO, NJM_CODCTR "
			EndIf

			cQryNJMNf := ChangeQuery(cQryNJMNf)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryNJMNf),(cAliasNJM),.F.,.T.)

			dbSelectArea((cAliasNJM))
			((cAliasNJM))->( dbGoTop() )

			While .Not. (cAliasNJM)->( Eof() )

				aAdd(aChvNJM, xFilial("NJM") + (cAliasNJM)->(NJM_CODROM) + (cAliasNJM)->(NJM_ITEROM))

				If .NOT. NJJ->NJJ_TIPO $ 'A|B' 
					If Empty((cAliasNJM)->(NJM_CODCTR))
						AgrHelp(STR0021, STR0027 + Chr(10) + Chr(13) + STR0014 + ": " + (cAliasNJM)->(NJM_CODROM) +" "+  (cAliasNJM)->(NJM_ITEROM), STR0505) //'HELP'###"Um ou mais contratos nao foram informados, ou o sistema nao pode determinar um contrato automaticamente."###"Romaneio: "###"Favor informar um Contrato válido."
						RestArea(aAreaAtu)				
						Return .F.  // A lRetorno ira retornar .t. ou .f. aqui nao posso retornar nil tenho q padronizar
					EndIf
				EndIf	

				IF Empty((cAliasNJM)->(NJM_TES)) 
					AgrHelp(STR0021, STR0210, STR0107 + (cAliasNJM)->(NJM_CODROM) +" "+  (cAliasNJM)->(NJM_ITEROM)) //'HELP'###"Romaneio não foi confirmado."###"Informe o campo TES na aba -Comercialização- do Romaneio "
					RestArea(aAreaAtu)				
					Return .F. // A lRetorno ira retornar .t. ou .f. aqui nao posso retornar nil tenho q padronizar
				EndIf	

				/*Verifica lote*/
				IF !fVerifLote((cAliasNJM)->(NJM_CODROM),(cAliasNJM)->(NJM_ITEROM)) //função ja retorna help
					RestArea(aAreaAtu)				
					Return .F.
				EndIf

				(cAliasNJM)->(DbSkip())
			Enddo
			(cAliasNJM)->(DbCloseArea())

			If TableInDic('N9E') .and. __lnewNeg
				DbSelectArea("N9E") // Romaneios X Angendamentos
				N9E->(DbSetOrder(1)) // N9E_FILIAL+N9E_CODROM+N9E_SEQUEN
				If N9E->(DbSeek(xFilial("N9E")+NJJ->(NJJ_CODROM)))
					If !(N9E->(Eof()))			
						If Alltrim(N9E->(N9E_ORIGEM)) == "1" .OR. Alltrim(N9E->(N9E_ORIGEM)) == "2"
							lExport	  := .T.
						EndIf									
					EndIf
				EndIf
			EndIf
			If TableInDic('N9E') .and. __lnewNeg
				// Comercial exportação - Se o Tipo romaneio for Venda e estiver vinculado a uma IE de Exportação, 
				// efetuar a geração da NF para o Pedido de Venda gerado para o Processo de Exportação. 
				// O pedido é gerado com base no processo de exportação, e não na NJM. 	   
				If NJJ->NJJ_TIPO == '4' .AND. lExport /*Saída por venda*/ 

					//CHAMA ROTINA PARA ATUALIZAR O PROCESSO DE EXPORTAÇÃO E GERAR O PEDIDO DE EXPORTAÇÃO(C5) SE PARAMETRO ESTIVER ATIVO
					DbSelectArea("N7Q")
					N7Q->( dbSetOrder( 1 ) )
					If N7Q->( dbSeek( xFilial( "N7Q" ) + N9E->(N9E_CODINE)  ) )
						lRetorno := GeraEEC("9",NJM->( NJM_FILIAL ),NJM->( NJM_CODROM ))
						If !lRetorno //se houve erro no ajuste do processo de exportação		
							Return .F. //aborta a confirmação do romaneio, pois precisa do pedido de exportação gerado pelo EEC para gerar a NF
						EndIf	

						IF !N7Q->N7Q_STAPCE $ '4' //nao estiver certificado
							lAntecip := .T.
						EndIf

					EndIf			

					cQuery := " SELECT EE7_PEDFAT "
					cQuery += " FROM " + RetSqlName('N82') + " N82 "
					cQuery += " INNER JOIN " + RetSqlName('EE7') + " EE7 ON EE7.D_E_L_E_T_ = '' AND EE7_FILIAL = N82_FILORI AND EE7_PEDIDO = N82_PEDIDO "
					cQuery += " WHERE N82_CODINE = '" + N9E->(N9E_CODINE) + "' "
					cQuery += " AND N82_FILORI = '" + NJJ->NJJ_FILIAL + "' "
					cQuery += " AND N82.D_E_L_E_T_ = '' "
					cAliasEE7 := GetNextAlias()
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasEE7, .F., .T.)
					If (cAliasEE7)->(!EoF())

						DbSelectArea("SC5")
						//Identifica pedido gerado para o processo de exportação 
						SC5->( dbSetOrder( 1 ) )
						If SC5->( dbSeek( xFilial( "SC5" ) + (cAliasEE7)->EE7_PEDFAT  ) )
							cNrPedExp := SC5->C5_NUM
						EndIf
						SC5->(dbCloseArea())
					EndIf 
				EndIF  

				// Atualizar estoque com o ajuste de peso calulado Diferenca do peso liquido com (PSSAI / PSCHE / PSCER)	
				If __lnewNeg .AND. NJJ->(NJJ_TIPO) $ "4|2" .AND. AGRTPALGOD(NJJ->(NJJ_CODPRO))					
					lRetorno  := MOVIESTQ(NJJ->NJJ_CODROM, NJJ->NJJ_CODPRO)
					If !lRetorno
						cMsgErro += Chr(13) + STR0353 + NJM->(NJM_CODROM) +" "+  NJM->(NJM_ITEROM) //"Não foi possível gerar o Movimento interno para o  romaneio
						Return .F.
					EndIf
				EndIf
			EndIf
			If Len(aChvNJM) > 0 
				For nX := 1 to Len(aChvNJM)	

					DbSelectArea("NJM")
					DbSetOrder(1)
					IF DbSeek(aChvNJM[nX])
						IF !NJM->NJM_STAFIS  = '1' // Indica que Item já Possui fiscal
							LOOP
						EndIF

						If NJM->(NJM_TIPO) $ "3|5|7|9" // Se for romaneio de ENTRADA

							//////////////////////////////
							// Gera Nota Fiscal de Entrada
							//////////////////////////////

							If !lExport .OR. (lExport .AND. Empty(NJJ->NJJ_DOCNUM))
								MsgRun(STR0049, STR0050, {|| lRetorno := OGX009A(NJM->(NJM_CODROM),,NJM->(NJM_ITEROM))}) //"Gerando Documento de Entrada......"###"Movimentando"

								If !lRetorno
									cMsgErro += Chr(13) + STR0097 + NJM->(NJM_CODROM) +" "+  NJM->(NJM_ITEROM) //"Não foi possível gerar o Documento de Entrada para o Romaneio "
									lRetorno := .F.
									Exit
								EndIf

								If NJM->NJM_TIPO = '3' //Entrada para depósito
									MsgRun(STR0115, STR0050, {|| lRetArm := OGX262NF()}) //"Calculando Serviços de Armazenagem......"###"Movimentando"

									If !lRetArm	
										cMsgErro += Chr(13) + STR0167 + NJM->(NJM_CODROM) +" "+  NJM->(NJM_ITEROM) //"Não foi calculado serviço de armazenagem para o romaneio "
									EndIf
								EndIf
							EndIf

							//Atualização dos dados referente a devolução de valor ( sem quantidade )
							If lRetorno .AND. NJM->NJM_VLRTOT == 0 

								cQrySD1 := GetNextAlias()

								// Verifica se tem nota fiscal emitida para o romaneio / item do romaneio
								BeginSql Alias cQrySD1
									Select Distinct SD1.R_E_C_N_O_ as D1_RECNO 
									From %table:SD1% SD1
									Where SD1.D1_FILIAL  = %xFilial:SD1% 
									And SD1.D1_CODROM  = %Exp:NJM->NJM_CODROM%
									And SD1.D1_ITEROM  = %Exp:NJM->NJM_ITEROM%
									And SD1.D1_CTROG   = %Exp:NJM->NJM_CODCTR%
									And SD1.%NotDel%
								EndSql

								(cQrySD1)->(DbGoTop())
								If !(cQrySD1)->(Eof())

									DbSelectArea("SD1")
									DbGoTo((cQrySD1)->(D1_RECNO))

									If RecLock( "NJM", .f. ) //Atualiza o valor de devolução
										NJM->( NJM_VLRTOT ) += SD1->D1_TOTAL
										NJM->( msUnLock() )
									EndIf

									DbSelectArea("NJR")
									DbSetOrder(1)
									If DbSeek(xFilial("NJR")+ NJM->NJM_CODCTR)
										If  RecLock( "NJR", .f. )
											NJR->( NJR_VLEFIS ) += SD1->D1_TOTAL
											NJR->( msUnLock() )
										EndIf
									EndIf

									// Atualiza qtdes do contrato				
									OGX010QTDS()

								EndIf
							ElseIf !__lnewNeg .and. NJM->NJM_TIPO == "9" .AND. !SuperGetMv('MV_AGRO047', , .F.) //devolução de venda, MV_AGRO047=.F. não considera valor unitario e total do romaneio
								//atualiza valores fiscais de entrada por devolução conforme NF de origem vinculada(SD1)
								FATVLDEVE()								
							EndIf
						Else // Senão, se for romaneio de SAIDA

							If cPaisLoc == "PAR" .And. !(NJM->NJM_TIPO $ "6|8")
								MsgRun(STR0328, STR0329, {|| lRetorno := OGX008A(NJM->(NJM_CODROM), NJM->(NJM_ITEROM),__aRfVenda)}) //"Gerando Remito... "###"Movimentando"

								If !lRetorno
									cMsgErro += Chr(13) + STR0330 + NJM->NJM_CODROM +" "+  NJM->NJM_ITEROM //"Não foi possível gerar o Remito para o Romaneio "
									lRetorno := .F.
									Exit
								EndIf
							Else							
								/*Se for Romaneio de Exportação, já tem o pedido gerado*/
								If !Empty(cNrPedExp)
									If RecLock("NJM", .F.)
										NJM->(NJM_PEDIDO) := cNrPedExp
										NJM->(MsUnLock())
									EndIf
								Else
									//////////////////////////////
									// Gera Pedido de Venda	
									//////////////////////////////
									If Empty(AllTrim(NJM->(NJM_PEDIDO)))

										MsgRun(STR0048, STR0050, {|| lRetorno := OGX008A(NJM->(NJM_CODROM), NJM->(NJM_ITEROM),__aRfVenda)}) //"Gerando Pedido de Venda..."###"Movimentando"

										If !lRetorno
											cMsgErro += Chr(13) + STR0098 + NJM->(NJM_CODROM) +" "+  NJM->(NJM_ITEROM) //"Não foi possível gerar o Pedido de Venda para o Romaneio "
											lRetorno := .F.
											Exit
										EndIf
									EndIf
								EndIf

								cSerie := NJM->(NJM_DOCSER)

								If NJM->(NJM_TPFORM) == "1" .and. Empty(cSerie)		// 1=Sim (form. próprio)
									//Busca serie de nota de Saida 	*Parametro*
									cSerie := SuperGetMV("MV_OGASERS",," ")
								EndIf

								//////////////////////////////
								// Gera Nota Fiscal de Saída	
								//////////////////////////////
								SC5->(DbSetOrder(1))
								If SC5->(DbSeek(xFilial("SC5")+NJM->(NJM_PEDIDO)))

									DbSelectArea("SF2")
									DbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
									If !DbSeek(xFilial("SF2")+SC5->(C5_NOTA)+SC5->(C5_SERIE)+SC5->(C5_CLIENTE)+SC5->(C5_LOJACLI))

										MsgRun(STR0556, STR0014, {|| aRet := AgrGeraNFS(NJM->(NJM_PEDIDO), cSerie)}) //###"Gerando NF de Saida..." ###"Romaneio"

										If Len(aRet) == 0
											cMsgErro += Chr(13) + STR0099 + NJM->(NJM_CODROM) +" "+  NJM->(NJM_ITEROM) //"Não foi possível gerar o Documento de Saída para o Romaneio "
											lRetorno := .F.
											Exit
										EndIf

										If NJM->NJM_TIPO = '6' //Devolução de Depósito 
											MsgRun(STR0115, STR0050 , {|| lRetArm := OGX262NF()}) //"Calculando Serviços de Armazenagem......"###"Movimentando"

											If !lRetArm	
												cMsgErro += Chr(13) + STR0167 + NJM->(NJM_CODROM) +" "+  NJM->(NJM_ITEROM) //"Não foi calculado serviço de armazenagem para o romaneio "
											EndIf
										EndIf
									EndIf

									/*Se for Romaneio de Exportação, atualiza dados da NF de Saída Gerada*/
									If !Empty(cNrPedExp) .And. lRetorno
										fAtuFisExp()
									EndIf			
								EndIf

							EndIf
						EndIf
					EndIf
				Next nX		

				//////////////////////////////
				// Consistências da rotina
				//////////////////////////////
				If  lRetorno	
					// registro de negocio		
					If __lnewNeg					
						//Apenas quando for subtipo 21 - (S) REMESSA PARA FORMAÇÃO LOTE
						If OG250DRFM(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM)
							//Gerar movimentos do tipo "8 - Transito Romaneio" para cada fardo do romaneio
							OG250EMF08(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM, NJJ->NJJ_LOCAL)
						EndIf

						If AGRTPALGOD(NJJ->(NJJ_CODPRO)) .AND. NJJ->NJJ_TIPO == '4' .AND. OG250DVFT( NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM ) != "43" 
							/* Algodão, Saída por venda (exceto global futura) */ 

							//inclui(1) status do fardo na DXI - faturado						
							If !lAntecip // verificar se é estufagem antecipada
								OG250GSTFR(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM)
							EndIF	
						EndIf
					EndIf

					// Verifica se o romaneio realmente possui os documentos fiscais relacionados. Caso não, ajusta os status do romaneio (auto-healing).
					OG250TFisc(NJJ->(NJJ_CODROM))

					// Função para auto-healing (auto-cura) do romaneio: ajusta o romaneio que já tenha NF gerada, mas não está com status fiscal = 2
					fAjustaFiscal(NJJ->(NJJ_CODROM))

					// Função para auto-healing (auto-cura) do romaneio: ajusta o romaneio que já tenha NF gerada, mas não está com a chave da nota.
					//fAjusDcFis()
					If __lnewNeg
						If OG250DRFM(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM)
							//Grava a tabela de remessas por formação de lote
							OG250HGVRF(NJJ->NJJ_CODROM)
						EndIf						

						//Chamada da função que abre o monitor de transmissão ao Sefaz só venda
						If SuperGetMV("MV_AGRO025", .F. , .T.)  == .T.	
							OGA250GTRANS() 
						Endif
					EndIf	
				Else
					AgrHelp(STR0021,STR0210, cMsgErro) //'HELP'###Romaneio não foi confirmado. //ok
				EndIf		
			EndIf

			RestArea(aAreaAtu)
		EndIf

		//Função para gerar romaneio quando for entidade propria
		If lRetorno .AND. !Empty(AllTrim(Posicione("NJ0",1,FWxFilial("NJ0")+NJJ->(NJJ_CODENT)+NJJ->(NJJ_LOJENT),"NJ0_CODCRP")))		
			cFilEnt := Posicione("NJ0",1,FWxFilial("NJ0")+NJJ->(NJJ_CODENT)+NJJ->(NJJ_LOJENT),"NJ0_CODCRP")

			//Envia código do Romaneio e falso [para não realizar comit]
			lRetorno := OGA250GERO(.T., cFilEnt)
		EndIf
		
	EndIf //fecha if tipo romaneio
			
	if lRetorno 
		//PE para manipular os dados do romaneio já confirmado.
		//A execução deste PE não influencia no andamento da rotina.
		If EXISTBLOCK ("OG250CFRM")
			ExecBlock("OG250CFRM",.F.,.F.,{NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM})
		EndIf
	endIf 

Return lRetorno

/** {Protheus.doc} fAjustaFiscal
Função para auto-healing (auto-cura) do romaneio: ajusta o romaneio que já tenha NF gerada, mas não está com status fiscal = 2

@param:     pcCodRom - Código do romaneio
@return:    .T. se foi tudo OK / .F. se houver algum erro de divergência entre NF e Romaneio
@author:    Marlon Richard Trettin
@since:     24/03/2015
@Uso:             SIGAAGR
*/
Static Function fAjustaFiscal(pcCodRom)
	Local aAreaAtu    := GetArea()
	Local cQryNJM     := GetNextAlias() 
	Local cQrySF1     := ""
	Local cQrySF1b    := ""
	Local cQrySC6     := ""
	Local cQrySD2     := ""
	Local aRetClFr    := {}
	Local cCliFor     := ""
	Local cLoja       := ""
	Local cTipoNF     := ""

	//Vars. de Vinculo
	Local aVincCab		:= {}
	Local aVincITE		:= {}
	Local aLinhaVinc	:= {}
	Local lVinculou		:= .f.
	
	// Verifica se há registros de NJM_STAFIS = 1 com documento fiscal relacionado, porém não relacionado na tabela do romaneio
	BeginSql Alias cQryNJM
		Select NJM_CODROM, NJM_ITEROM, NJM_TIPO, NJM_CODCTR, NJM_CODPRO, NJM_CODSAF, NJM_DOCNUM, NJM_DOCSER, 
		NJM_CODENT, NJM_LOJENT, NJM_TES, NJM_QTDFIS, NJM_PEDIDO, R_E_C_N_O_ AS NJM_RECNO
		From %table:NJM% NJM
		Where NJM.NJM_FILIAL = %xFilial:NJM% 
		And NJM.NJM_CODROM = %Exp:pcCodRom%
		And NJM.NJM_STAFIS = %Exp:"1"%          
		And NJM.%NotDel%
	EndSql

	(cQryNJM)->(DbGoTop())
	If !(cQryNJM)->(Eof())

		While !(cQryNJM)->(Eof())

			If (cQryNJM)->(NJM_TIPO) $ "3|5|7|9" // Se for romaneio de ENTRADA

				cQrySF1 := GetNextAlias()

				// Verifica se tem nota fiscal emitida para o romaneio / item do romaneio
				BeginSql Alias cQrySF1
					Select Distinct SF1.R_E_C_N_O_ as F1_RECNO 
					From %table:SD1% SD1
					Inner Join %table:SF1% SF1
					on SF1.F1_FILIAL  = SD1.D1_FILIAL 
					And SF1.F1_DOC     = SD1.D1_DOC
					And SF1.F1_SERIE   = SD1.D1_SERIE
					And SF1.F1_FORNECE = SD1.D1_FORNECE
					And SF1.F1_LOJA    = SD1.D1_LOJA
					And SF1.F1_TIPO    = SD1.D1_TIPO
					And SF1.%NotDel%
					Where SD1.D1_FILIAL  = %xFilial:SD1% 
					And SD1.D1_CODROM  = %Exp:(cQryNJM)->(NJM_CODROM)%
					And SD1.D1_ITEROM  = %Exp:(cQryNJM)->(NJM_ITEROM)%
					And SD1.D1_CTROG   = %Exp:(cQryNJM)->(NJM_CODCTR)%
					And SD1.%NotDel%
				EndSql
				(cQrySF1)->(DbGoTop())
				If !(cQrySF1)->(Eof())

					DbSelectArea("SF1")
					DbGoTo((cQrySF1)->(F1_RECNO))

					// Chama a função OGX140, com a tabela SF1 posicionada, para fazer as gravações inerentes ao romaneio de entrada
					OGX140(.T.)

				Else  // Se não achou

					//Retorna o Cliente ou Fornecedor, conforme o tipo do movimento do romaneio
					aRetClFr    := OGA250ClFr((cQryNJM)->(NJM_CODENT), (cQryNJM)->(NJM_LOJENT), (cQryNJM)->(NJM_TES), (cQryNJM)->(NJM_TIPO), (cQryNJM)->(NJM_QTDFIS))
					cTipoNF     := aRetClFr[1]
					cCliFor     := aRetClFr[2]
					cLoja       := aRetClFr[3]

					// Verifica se encontra a Nota pelo número da NF informada no Romaneio
					cQrySF1b := GetNextAlias()
					BeginSql Alias cQrySF1b
						Select SF1.R_E_C_N_O_ as F1_RECNO 
						,SD1.R_E_C_N_O_ as D1_RECNO
						From %table:SD1% SD1
						Inner Join %table:SF1% SF1
						on SF1.F1_FILIAL  = SD1.D1_FILIAL 
						And SF1.F1_DOC     = SD1.D1_DOC
						And SF1.F1_SERIE   = SD1.D1_SERIE
						And SF1.F1_FORNECE = SD1.D1_FORNECE
						And SF1.F1_LOJA    = SD1.D1_LOJA
						And SF1.F1_TIPO    = SD1.D1_TIPO
						And SF1.%NotDel%
						Where SD1.D1_FILIAL  = %xFilial:SD1% 
						And SD1.D1_DOC     = %Exp:(cQryNJM)->(NJM_DOCNUM)%
						And SD1.D1_SERIE   = %Exp:(cQryNJM)->(NJM_DOCSER)%
						And SD1.D1_FORNECE = %Exp:cCLiFor%
						And SD1.D1_LOJA    = %Exp:cLoja%
						And SD1.D1_TIPO    = %Exp:cTipoNF%
						And SD1.D1_DOC     != " "
						And SD1.%NotDel%
					EndSql

					(cQrySF1b)->( dbGoTop() )
					If !(cQrySF1b)->( Eof() )

						DbSelectArea( "SD1" )
						DbGoTo( (cQrySF1b)->( D1_RECNO ) )

						// Verifica se a quantidade da NF fecha com a quantidade do Romaneio
						If SD1->( D1_QUANT ) <> (cQryNJM)->(NJM_QTDFIS)
							AgrHelp( STR0021, STR0210, ; //'HELP'###Romaneio não foi confirmado.
									 STR0139 + Chr(13) + STR0140 + Chr(10) + Chr(13) + ; //###"Não foi possível associar Romaneio à Nota Fiscal já gerada, informada no Romaneio."###"Quantidade Fiscal do Romaneio difere da Quantidade da NF."###
									 STR0014 + ": " + pcCodRom + " ; " + STR0141 +": " + Transform( NJJ->(NJJ_QTDFIS), PesqPict("NJJ", "NJJ_QTDFIS")) + Chr(10) + Chr(13) + ; //"Romaneio":### ; "Qtde. Fiscal":
									 STR0136 + ": " + (cQryNJM)->(NJM_DOCNUM) + "/" +(cQryNJM)->(NJM_DOCSER) + " ; " + STR0141 +": " + Transform(SD1->(D1_QUANT), PesqPict("SD1", "D1_QUANT")) ) //###"Docto. Fiscal":####/### ; ""Qtde. Fiscal":

							(cQrySF1b)->(DbCloseArea())
							(cQrySF1)->(DbCloseArea())

							RestArea(aAreaAtu)
							Return .F.
						EndIf

						// Verifica se o Produto do Romaneio é o mesmo da NF
						If SD1->(D1_COD) <> (cQryNJM)->(NJM_CODPRO)
							AgrHelp( STR0021, STR0210, ; //'HELP'###Romaneio não foi confirmado.
									 STR0139 + Chr(13) + STR0142 + Chr(10) + Chr(13) + ; //'HELP'###"Não foi possível associar Romaneio à Nota Fiscal já gerada, informada no Romaneio."###"Produto do Romaneio difere do Produto da NF."###
									 STR0014 + ": " + pcCodRom + " ; " + STR0143 +": " + (cQryNJM)->( NJM_CODPRO ) + Chr(10) + Chr(13) + ; //"Romaneio":### ; "Produto":
									 STR0136 + ": " + (cQryNJM)->(NJM_DOCNUM) + "/" +(cQryNJM)->(NJM_DOCSER) + " ; " + STR0143 +": " + SD1->(D1_COD) ) //"Docto. Fiscal":####/### ; "Produto":

							(cQrySF1b)->(DbCloseArea())
							(cQrySF1)->(DbCloseArea())
							Return .F.
						EndIf

						// Verifica se a NF informada não pertence a outro romaneio
						If !Empty( SD1->(D1_CODROM))
							DbSelectArea("NJJ")
							DbSetOrder(1)
							If DbSeek(xFilial("NJJ") + SD1->(D1_CODROM))
								If NJJ->(NJJ_STATUS) $ "2|3" 	// 2=Atualizado; 3=Confirmado
									AgrHelp( STR0021, STR0210, ; //'HELP'###Romaneio não foi confirmado.
											 STR0139 + Chr(13) + STR0165 + Chr(10) + Chr(13) + ; 	//"HELP"###"Não foi possível associar Romaneio à Nota Fiscal já gerada, informada no Romaneio."###"NF informada já está associada a outro romaneio"###
											 STR0014 + ": " + SD1->( D1_CODROM ) ) //"Romaneio"

									(cQrySF1b)->(DbCloseArea())
									(cQrySF1)->(DbCloseArea())
									Return .F.
								EndIf
							EndIf
						EndIf

						// Associa o romaneio à SD1 
						If RecLock("SD1", .F. )
							SD1->(D1_CTROG)       := (cQryNJM)->( NJM_CODCTR )
							SD1->(D1_CODSAF)      := (cQryNJM)->( NJM_CODSAF )
							SD1->(D1_CODROM)      := (cQryNJM)->( NJM_CODROM )
							SD1->(D1_ITEROM)      := (cQryNJM)->( NJM_ITEROM )
							SD1->(MsUnLock())
						EndIf

						DbSelectArea("SF1")
						DbGoTo((cQrySF1b)->(F1_RECNO))

						// Associa o romaneio à SF1
						If RecLock("SF1", .F.)
							SF1->(F1_CODROM) := NJJ->(NJJ_CODROM)
							SF1->(MsUnLock())
						EndIf

						// Chama a função OGX140, com a tabela SF1 posicionada, para fazer as gravações inerentes ao romaneio de entrada
						OGX140(.T.)

					EndIf
					(cQrySF1b)->(DbCloseArea())

				EndIf
				(cQrySF1)->(DbCloseArea())

			Else  // Se for romaneio de SAIDA
				DbSelectArea("SC5")
				DbSetOrder(1) //C5_FILIAL+C5_NUM
				If DbSeek(xFilial("SC5") + (cQryNJM)->NJM_PEDIDO)
					dBSelectArea('N8H')
					N8H->(DbSetOrder(1))
					// Se não encontrou o pedido na tab. de vinculos quer dizer que a nf. foi gerada antes do romaneio
					IF .NOT. N8H->(DbSeek(FWxFilial('N8H') + (cQryNJM)->NJM_PEDIDO))
						// Associa Romaneio ao PV
						// Associa Romaneio ao Item do PV
						cQrySC6 := GetNextAlias()
						BeginSql Alias cQrySC6
							Select SC6.R_E_C_N_O_ as C6_RECNO 
							From %table:SC6% SC6
							Where SC6.C6_FILIAL  = %xFilial:SC6% 
							And SC6.C6_NUM     = %Exp:(cQryNJM)->(NJM_PEDIDO)%
							And SC6.C6_PRODUTO = %Exp:(cQryNJM)->(NJM_CODPRO)%
							And SC6.C6_QTDVEN  = %Exp:(cQryNJM)->(NJM_QTDFIS)%
							And SC6.%NotDel%
						EndSql
						(cQrySC6)->(DbGoTop())
						If !(cQrySC6)->(Eof())
							DbSelectArea("SC6")
							DbGoTo((cQrySC6)->(C6_RECNO))

							aLinhaVinc := {}

							aadd( aLinhaVinc, { "N8I_FILIAL"    	, FwXfilial('N8I') 			} )
							aadd( aLinhaVinc, { "N8I_ITEMPV"    	, SC6->C6_ITEM				} )
							aadd( aLinhaVinc, { "N8I_PRODUT"    	, SC6->C6_PRODUTO			} )
							aadd( aLinhaVinc, { "N8I_TPPROD"    	, ''			 			} )
							aadd( aLinhaVinc, { "N8I_CODCTR"    	, (cQryNJM)->NJM_CODCTR		} )
							aadd( aLinhaVinc, { "N8I_SAFRA"    		, (cQryNJM)->NJM_CODSAF		} )
							aadd( aLinhaVinc, { "N8I_CODROM"    	, (cQryNJM)->NJM_CODROM		} )
							aadd( aLinhaVinc, { "N8I_ITEROM"    	, (cQryNJM)->NJM_ITEROM		} )
							aadd( aLinhaVinc, { "N8I_CODOTR"   		, ''						} )
							aadd( aLinhaVinc, { "N8I_ITEOTR"   		, ''						} )
							aadd( aLinhaVinc, { "N8I_CODFIX"    	, ''						} )
							aadd( aLinhaVinc, { "N8I_ORIGEM"    	, 'OGA250'		 			} )		
							aAdd( aLinhaVinc, { "N8I_HISTOR"    	, FWI18NLang("OGA250","STR0043",43)	} )  //'Romaneio (fajustafiscal' 

							aAdd(aVincITE, aLInhaVinc)

						EndIf 
						(cQrySC6)->(DbCloseArea())

						// Criando Array de vinculo
						// Alimentando as tabelas de auxiliares de vinculo com ERP

						aadd( aVincCab, { "N8H_FILIAL"      , FwXfilial('N8H') 						} )
						aadd( aVincCab, { "N8H_NUMPV"    	, (cQryNJM)->NJM_PEDIDO		  			} )
						aadd( aVincCab, { "N8H_CODCTR"    	, (cQryNJM)->NJM_CODCTR		 			} )
						aadd( aVincCab, { "N8H_CODROM"    	, (cQryNJM)->NJM_CODROM					} )
						aadd( aVincCab, { "N8H_CODFIX"   	, ""									} )
						aadd( aVincCab, { "N8H_CODOTR"   	, ""									} )
						aadd( aVincCab, { "N8H_ORIGEM"   	, "OGA250"								} )
						aAdd( aVincCab, { "N8H_HISTOR"    	, FWI18NLang("OGA250","STR0043",43)		} ) //'Romaneio (fajustafiscal' 

						lVinculou := fAgrVncPV (aVincCab, aVincITE, 3)  	//Incluir

						IF .not. lVinculou
							Final(STR0044)
						EndIF

					EndIf	
						
					// Se C5_CODROM está vazio, quer dizer que a NF foi gerada antes do romaneio
					If SC5->(ColumnPos("C5_CODROM")) > 0 .and. Empty( SC5->( C5_CODROM ) )

						// Associa Romaneio ao PV
						If RecLock( "SC5", .F. )
							SC5->( C5_CODROM )      := (cQryNJM)->( NJM_CODROM )
							SC5->( MsUnLock() )
						EndIf

						// Associa Romaneio ao Item do PV
						cQrySC6 := GetNextAlias()
						BeginSql Alias cQrySC6
							Select SC6.R_E_C_N_O_ as C6_RECNO 
							From %table:SC6% SC6
							Where SC6.C6_FILIAL  = %xFilial:SC6% 
							And SC6.C6_NUM     = %Exp:(cQryNJM)->( NJM_PEDIDO )%
							And SC6.C6_PRODUTO = %Exp:(cQryNJM)->( NJM_CODPRO )%
							And SC6.C6_QTDVEN  = %Exp:(cQryNJM)->( NJM_QTDFIS )%
							And SC6.%NotDel%
						EndSql
						(cQrySC6)->( dbGoTop() )
						If !(cQrySC6)->( Eof() ) .AND. SC6->(ColumnPos("C6_CTROG")) > 0
							DbSelectArea( "SC6" )
							DbGoTo( (cQrySC6)->( C6_RECNO ) )
							If RecLock( "SC6", .F. )
								SC6->( C6_CTROG )       := (cQryNJM)->( NJM_CODCTR )
								SC6->( C6_CODSAF )      := (cQryNJM)->( NJM_CODSAF )
								SC6->( C6_CODROM )      := (cQryNJM)->( NJM_CODROM )
								SC6->( C6_ITEROM )      := (cQryNJM)->( NJM_ITEROM )
								SC6->( MsUnLock() )
							EndIf
						EndIf 
						(cQrySC6)->( dbCloseArea() )
					EndIf

					DbSelectArea("SF2")
					DbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
					If DbSeek(xFilial("SF2") + SC5->(C5_NOTA) + SC5->(C5_SERIE) + SC5->(C5_CLIENTE) + SC5->(C5_LOJACLI))

						// Chama a função OGX155, com a tabela SF2 posicionada, para fazer as gravações inerentes ao romaneio de saída
						OGX155()
						OGX140AtNJJ( xFilial( "NJJ" ), pcCodRom )
					EndIf

				Else // Se não encontrou pedido de venda, pode ser NF de saída inserida pelos Livros Fiscais, então verifica se a NF foi associada a um romaneio simbólico
					// Procura o item da NF de saída na tabela N8K tabela de extensão AGRO
					cQrySD2 := GetNextAlias()
					BeginSql Alias cQrySD2					
						SELECT SD2.R_E_C_N_O_ as D2_RECNO  
						FROM %table:SD2% SD2
						INNER JOIN %table:N8K% N8K 
						ON N8K.%NotDel%
						AND N8K.N8K_FILIAL 	= SD2.D2_FILIAL
						AND N8K.N8K_DOC 	= SD2.D2_DOC
						AND N8K.N8K_SERIE 	= SD2.D2_SERIE
						AND N8K.N8K_CLIFOR 	= SD2.D2_CLIENTE
						AND N8K.N8K_LOJA 	= SD2.D2_LOJA
						AND N8K.N8K_ITEDOC 	= SD2.D2_ITEM
						AND N8K.N8K_PRODUT 	= SD2.D2_COD					
						WHERE 	N8K.N8K_FILIAL 	= %xFilial:N8K% 
						AND 	N8K.N8K_CODCTR 	= %Exp:(cQryNJM)->(NJM_CODCTR)%
						AND 	N8K.N8K_PRODUT 	= %Exp:(cQryNJM)->(NJM_CODPRO)%
						AND 	N8K.N8K_CODROM 	= %Exp:(cQryNJM)->(NJM_CODROM)%
						AND 	N8K.N8K_ITEROM 	= %Exp:(cQryNJM)->(NJM_ITEROM)%
						AND 	N8K.%NotDel%
					EndSql
					
					(cQrySD2)->(DbGoTop())
					If (cQrySD2)->(Eof()) .AND. SD2->(ColumnPos("D2_CTROG")) > 0  //Não encontrou na N8K e tem campo legado na base
						// Procura o item da NF de saída
						cQrySD2 := GetNextAlias()
						BeginSql Alias cQrySD2
							Select SD2.R_E_C_N_O_ as D2_RECNO 
							From %table:SD2% SD2
							Where SD2.D2_FILIAL  = %xFilial:SD2% 	
							And SD2.D2_CTROG   = %Exp:(cQryNJM)->( NJM_CODCTR )%
							And SD2.D2_COD     = %Exp:(cQryNJM)->( NJM_CODPRO )%
							And SD2.D2_CODROM  = %Exp:(cQryNJM)->( NJM_CODROM )%
							And SD2.D2_ITEROM  = %Exp:(cQryNJM)->( NJM_ITEROM )%
							And SD2.%NotDel%
						EndSql				
					EndIf

					(cQrySD2)->(DbGoTop())
					If !(cQrySD2)->(Eof())
						DbSelectArea("SD2")
						DbGoTo((cQrySD2)->(D2_RECNO))

						// Garante a existência da SF2
						DbSelectArea("SF2")
						DbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
						If DbSeek(xFilial("SF2") + SD2->(D2_DOC) + SD2->(D2_SERIE) + SD2->(D2_CLIENTE) + SD2->(D2_LOJA))

							// Atualiza o item do romaneio (NJM)
							DbSelectArea("NJM")
							DbGoTo((cQryNJM)->(NJM_RECNO))
							If RecLock("NJM", .F.)
								NJM->(NJM_DOCSER) := SF2->(F2_SERIE)
								NJM->(NJM_DOCNUM) := SF2->(F2_DOC)
								NJM->(NJM_DOCEMI) := SF2->(F2_EMISSAO)
								NJM->(NJM_DOCESP) := SF2->(F2_ESPECIE)
								NJM->(NJM_CHVNFE) := SF2->(F2_CHVNFE)
								NJM->(NJM_STAFIS) := "2"
								NJM->(NJM_DTRANS) := dDatabase
								NJM->(MsUnLock())
							EndIf

							// Atualiza o registro de NJJ com o primeiro de NJM
							OGX140AtNJJ(xFilial("NJJ"), pcCodRom)

						EndIf
					EndIf
					(cQrySD2)->(DbCloseArea())

				EndIf
			EndIf

			(cQryNJM)->(DbSkip())
		EndDo                   

	Else // Se não achou nenhum NJM_STAFIS = "1" (ou seja, TEM fiscal )

		// Para garantir, atualiza o registro de NJJ com o primeiro de NJM
		OGX140AtNJJ(NJJ->(NJJ_FILIAL), pcCodRom)
	EndIf
	(cQryNJM)->(DbCloseArea())

	RestArea(aAreaAtu)

Return .T.

/** {Protheus.doc} fVerifLote				   
Função para verificação de informações do lote

Retorno:    .T. ou .F. 
@author: 	Ana Laura Olegini
@since: 	15/02/2016
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fVerifLote(cRomaneio, cItemRom)
	Local aAreaAtu	:= GetArea()
	Local lRetorno	:= .T.
	Local cTes		:= ''
	Local cProduto	:= ''
	Local cLote		:= ''
	Local cLocal	:= ''
	Local cTipRom   := ''
	Local cSubtip   := ''

	DbSelectArea("NJM")
	NJM->(DbSetOrder(1))
	If NJM->(Dbseek(xFilial("NJM")+cRomaneio+cItemRom)) 
		cTes		:= NJM->NJM_TES	
		cProduto	:= NJM->NJM_CODPRO
		cLote		:= NJM->NJM_LOTCTL
		cLocal		:= NJM->NJM_LOCAL
		cTipRom		:= NJM->NJM_TIPO
		If NJM->(ColumnPos('NJM_SUBTIP')) > 0 .and. __lnewNeg
			cSubtip     := NJM->NJM_SUBTIP
		EndIf


		If  __lnewNeg //Projeto SLC
			If   cSubtip $ "21|71|72|22"    
				/* Para remessa e retorno formacao de lote de algodao não irá validar movimentacao pois:  
				Se nao houver rastro e foi informado lote nao iremos enviar para o pedido/nota 
				uma vez que deve constar na NJM para o especifico fazer a transferencia
				Se houver rastro e nao movimentar estoque e e foi informado lote nao iremos enviar para o 
				pedido/nota uma vez que deve constar na NJM para o especifico fazer a transferencia*/

				//controla lote, se for grãos e lote NJM em branco  			
				IF Rastro(cProduto) 
					/*===============================================================================
					Se o produto controla lote e foi informado Lote, a Tes tem q movimentar Estoque 
					===============================================================================*/			  
					IF !AGRTPALGOD(NJM->NJM_CODPRO) .AND. !Empty(cLote)					   
						DbSelectArea("SF4")
						SF4->(DbSetOrder(1)) 
						If SF4->(Dbseek(xFilial("SF4")+cTes)) .And. SF4->F4_ESTOQUE=="N" .And. lRetorno
							AgrHelp( STR0021, STR0208, STR0552) //"AJUDA"#"TES informada não movimenta estoque."###" Favor informar uma TES com movimento de estoque."
							lRetorno := .F.
						EndIf						   	 						
					EndIF						
				else				
					/*Se o produto nao controla lote e foi informado Lote, nao deve permitir continuar*/
					If !AGRTPALGOD(NJM->NJM_CODPRO) .AND. !Empty(cLote) 
						AgrHelp(STR0021, STR0206, STR0553) //"AJUDA"###"Foi informado lote para o item do romaneio, porém o produto não controla lote. "###"Remova a informação do lote na aba 'Comercialização'. "
						lRetorno := .F.
					EndIf					 				
				Endif		             
			else 		    
				//controla lote, se for grãos e lote NJM em branco ou se for algodão e na N9D tiver registro com lote em branco 			
				IF Rastro(cProduto) 
					/*===============================================================================
					Se o produto controla lote e foi informado Lote, a Tes tem q movimentar Estoque. Exceto venda futura 
					===============================================================================*/			  
					If cSubtip != "43"
						IF (!AGRTPALGOD(NJM->NJM_CODPRO) .AND. !Empty(cLote)) .OR. (AGRTPALGOD(NJM->NJM_CODPRO) .AND. !fVerN9DLote(cRomaneio)) 					   
							DbSelectArea("SF4")
							SF4->(DbSetOrder(1))
							If SF4->(Dbseek(xFilial("SF4")+cTes)) .And. SF4->F4_ESTOQUE=="N" .And. lRetorno
								AgrHelp( STR0021, STR0208, STR0552) //"AJUDA"#"TES informada não movimenta estoque."###" Favor informar uma TES com movimento de estoque."
								lRetorno := .F.
							EndIf

							/*===============================================================
							Verifica se é um Romaneio de Saída com Data de Validade do Lote ok
							===============================================================*/
							IF lRetorno 
								DbSelectArea("SB8")
								SB8->(DbSetOrder(3))
								If SB8->(Dbseek(xFilial("SB8")+cProduto+cLocal+cLote)) .And. cTipRom $ "6|8" //devolucao compra e devolucao de deposito
									If SB8->B8_DTVALID < dDataBase 
										AgrHelp(STR0021, STR0209, STR0554) //"AJUDA"#"O lote informado está vencido."###"Favor informar um lote válido."
										lRetorno := .F.
									EndIf
								EndIf
							EndIF	 						
						EndIF
					EndIf
				else				
					/*Se o produto nao controla lote e foi informado Lote, nao deve permitir continuar*/
					If ((!AGRTPALGOD(NJM->NJM_CODPRO) .AND. !Empty(cLote)) .OR.  ;
					(AGRTPALGOD(NJM->NJM_CODPRO) .AND. !fVerN9DLote(cRomaneio) .AND. Rastro(NJM->NJM_CODPRO) ) )
						AgrHelp(STR0021, STR0206, STR0553) //"AJUDA"###"Foi informado lote para o item do romaneio, porém o produto não controla lote. "###"Remova a informação do lote na aba 'Comercialização'. "
						lRetorno := .F.
					EndIf					 				
				Endif
			Endif   	   
		Else 
			/*============================================================*\
			Se o produto controla lote, a Tes tem q movimentar Estoque 
			\*============================================================*/
			IF  Rastro(cProduto) 
				if  Empty(cLote)
					DbSelectArea("SF4")
					DbSetOrder(1) 
					If Dbseek(xFilial("SF4")+cTes) .And. SF4->F4_ESTOQUE=="N" .And. lRetorno
						AgrHelp( STR0021, STR0208, STR0552) //"AJUDA"#"TES informada não movimenta estoque."###" Favor informar uma TES com movimento de estoque."
						lRetorno := .F.
					EndIf
				else	 
					/*===============================================================*\
					Verifica se é um Romaneio de Saída com Data de Validade do Lote ok
					\*===============================================================*/
					DbSelectArea("SB8")
					SB8->(DbSetOrder(3))
					If  SB8->(Dbseek(xFilial("SB8")+cProduto+cLocal+cLote)) .And. cTipRom $ "2|4|6|8" .And. lRetorno
						If SB8->B8_DTVALID < dDataBase  
							AgrHelp(STR0021, STR0209, STR0554) //"AJUDA"#"O lote informado está vencido."###"Favor informar um lote válido."
							lRetorno := .F.
						EndIf							
					EndIf
				EndIF
			EndIF	
		Endif
	Endif				


	RestArea( aAreaAtu )
Return lRetorno

/** {Protheus.doc} fVerN9DLote				   
Função para verificação se todos os fardos vinculados ao romaneio possuem Lote

Retorno:    .T. ou .F. 
@author: 	
@since: 	29/05/2018
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static function fVerN9DLote(cRomaneio)
	Local aAreaAtu	:= GetArea()
	Local lRet := .F.
	Local cQuery 	:= ""
	Local cAliasQry	:= GetNextAlias()

	//select retorna quantidade de fardos sem lote
	cQuery :=  " SELECT COUNT(N9D_FARDO) AS QTD "
	cQuery +=  " FROM "+ RetSqlName("N9D") + " N9D"
	cQuery +=  " WHERE N9D_CODROM = '" + cRomaneio + "' "
	cQuery +=  " AND N9D_TIPMOV   = '07' "
	cQuery +=  " AND N9D_STATUS   = '2' "
	cQuery +=  " AND N9D_LOTECT   = '' "
	cQuery +=  " AND N9D.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)

	dbSelectArea(cAliasQry)
	If !(cAliasQry)->( Eof() ) .And. (cAliasQry)->QTD = 0 
		lRet := .T.
	EndIf
	(cAliasQry)->(DbCloseArea())

	RestArea( aAreaAtu )
Return lRet

/*{Protheus.doc} fAtuFisExp
Atualiza status do Romaneio de Exportação ao gerar a NF do Pedido de Venda relacionado
@author Tamyris Ganzenmueller
@since 25/01/2018
@type function
*/
Static Function fAtuFisExp()
	Local cQrySC6     := ""

	//Vars. de Vinculo
	Local aVincCab		:= {}
	Local aVincITE		:= {}
	Local aLinhaVinc	:= {}
	Local lVinculou		:= .f.
	Local lSF2          := .F.

	Local cNumAvi       := ""
	Local cNumDco       := ""
	Local cSeqDco       := ""
	Local cTpAvis       := ""
	Local cCodCli       := ""
	Local cLojCli       := ""
	Local cObserv       := ""

	DbSelectArea("SF2")
	DbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If DbSeek(xFilial("SF2") + SC5->(C5_NOTA) + SC5->(C5_SERIE) + SC5->(C5_CLIENTE) + SC5->(C5_LOJACLI))
		// Atualiza o item do romaneio (NJM)
		RecLock( "NJM", .f. )
		NJM->(NJM_DOCSER) := SF2->(F2_SERIE)
		NJM->(NJM_DOCNUM) := SF2->(F2_DOC)
		NJM->(NJM_DOCEMI) := SF2->(F2_EMISSAO)
		NJM->(NJM_DOCESP) := SF2->(F2_ESPECIE)
		NJM->(NJM_CHVNFE) := SF2->(F2_CHVNFE)
		NJM->(NJM_STAFIS) := "2"
		NJM->(NJM_DTRANS) := dDatabase
		msUnLock("NJM")
		lSF2 := .T.
	EndIf

	dBSelectArea('N8H')
	N8H->(DbSetOrder(1))

	IF .NOT. N8H->(DbSeek(FWxFilial('N8H') + NJM->NJM_PEDIDO))
		// Associa Romaneio ao PV
		// Associa Romaneio ao Item do PV
		cQrySC6 := GetNextAlias()
		BeginSql Alias cQrySC6
			Select SC6.R_E_C_N_O_ as C6_RECNO 
			From %table:SC6% SC6
			Where SC6.C6_FILIAL  = %xFilial:SC6% 
			And SC6.C6_NUM     = %Exp:NJM->(NJM_PEDIDO)%
			And SC6.C6_PRODUTO = %Exp:NJM->(NJM_CODPRO)%
			And SC6.%NotDel%
		EndSql
		(cQrySC6)->( dbGoTop() )
		While !(cQrySC6)->(Eof())
			DbSelectArea( "SC6" )
			DbGoTo((cQrySC6)->(C6_RECNO))

			aLinhaVinc := {}

			cNumAvi := Posicione("N7S",2,NJM->(NJM_FILORG + NJM_CODCTR + NJM_ITEM + NJM_SEQPRI),"N7S_NUMAVI")
			cNumDco := Posicione("N7S",2,NJM->(NJM_FILORG + NJM_CODCTR + NJM_ITEM + NJM_SEQPRI),"N7S_NUMDCO")
			cSeqDco := Posicione("N7S",2,NJM->(NJM_FILORG + NJM_CODCTR + NJM_ITEM + NJM_SEQPRI),"N7S_SEQDCO")
			cTpAvis := Posicione("N7S",2,NJM->(NJM_FILORG + NJM_CODCTR + NJM_ITEM + NJM_SEQPRI),"N7S_TPAVIS")

			cCodCli := Posicione("NJ0",1,FwxFilial("NJ0") + NJM->(NJM_CODENT + NJM_LOJENT),"NJ0_CODCLI")
			cLojCli := Posicione("NJ0",1,FwxFilial("NJ0") + NJM->(NJM_CODENT + NJM_LOJENT),"NJ0_LOJCLI")

			cObserv := getObsInd(cNumAvi, cCodCli, cLojCli, cTpAvis )

			cTipAlg := TpAlgN9Z(SC6->C6_NUM, SC6->C6_ITEM)

			aadd( aLinhaVinc, { "N8I_FILIAL"    	, FwXfilial('N8I')  } )
			aadd( aLinhaVinc, { "N8I_ITEMPV"    	, SC6->C6_ITEM	    } )
			aadd( aLinhaVinc, { "N8I_PRODUT"    	, SC6->C6_PRODUTO   } )
			aadd( aLinhaVinc, { "N8I_TPPROD"    	, cTipAlg		    } )
			aadd( aLinhaVinc, { "N8I_CODCTR"    	, ''		        } )
			aadd( aLinhaVinc, { "N8I_SAFRA"    		, NJM->NJM_CODSAF   } )
			aadd( aLinhaVinc, { "N8I_CODROM"    	, NJM->NJM_CODROM   } )
			aadd( aLinhaVinc, { "N8I_ITEROM"    	, NJM->NJM_ITEROM   } )
			aadd( aLinhaVinc, { "N8I_CODOTR"   		, ''				} )
			aadd( aLinhaVinc, { "N8I_ITEOTR"   		, ''				} )
			aadd( aLinhaVinc, { "N8I_CODFIX"    	, ''				} )
			aadd( aLinhaVinc, { "N8I_ORIGEM"    	, 'OGA250'		 	} )		
			aAdd( aLinhaVinc, { "N8I_HISTOR"    	, STR0352           } )

			//Dados Aviso PEPRO  
			aAdd( aLinhaVinc, { "N8I_NUMAVI"   	    , cNumAvi    		} )
			aAdd( aLinhaVinc, { "N8I_NUMDCO"   	    , cNumDco    		} )
			aAdd( aLinhaVinc, { "N8I_SEQDCO"   	    , cSeqDco			} )

			If .Not. Empty(cNumAvi)
				If Empty(cTpAvis)
					cTpAvis := cTipAlg
				EndIf
			Else
				cTpAvis := ''
			EndIf

			aAdd( aLinhaVinc, { "N8I_TPAVIS"   	    , cTpAvis			} )
			aAdd( aLinhaVinc, { "N8I_OBSERV"   	    , cObserv			} ) 

			aAdd(aVincITE, aLInhaVinc)

			(cQrySC6)->(dbSkip())			
		EndDo 
		(cQrySC6)->(dbCloseArea())

		// Criando Array de vinculo
		// Alimentando as tabelas de auxiliares de vinculo com ERP

		aadd( aVincCab, { "N8H_FILIAL"      , FwXfilial('N8H') 						} )
		aadd( aVincCab, { "N8H_NUMPV"    	, NJM->NJM_PEDIDO		  			} )
		aadd( aVincCab, { "N8H_CODCTR"    	, ''		 			} )
		aadd( aVincCab, { "N8H_CODROM"    	, NJM->NJM_CODROM					} )
		aadd( aVincCab, { "N8H_CODFIX"   	, ""									} )
		aadd( aVincCab, { "N8H_CODOTR"   	, ""									} )
		aadd( aVincCab, { "N8H_ORIGEM"   	, "OGA250"								} )
		aAdd( aVincCab, { "N8H_HISTOR"    	, STR0352 } )

		lVinculou := fAgrVncPV (aVincCab, aVincITE, 3)  	//Incluir

		IF .not. lVinculou
			Final(STR0044)
		EndIF

	EndIf

	If lSF2
		// Chama a função OGX155, com a tabela SF2 posicionada, para fazer as gravações inerentes ao romaneio de saída
		OGX155() 
	EndIf

Return .T.

/*{Protheus.doc} OGA250LOT
Ao confirmar romaneio de grãos, quando tenha controle por lote, seja feita escolha automática de lotes que tenham saldo
@author tamyris.g	
@since 23/04/2018
@version 1.0
@type function
*/
Static Function OGA250LOT()
	Local lRet := .T.
	Local lRastFIFO := SuperGetMv("MV_AGRO019",.F.,.F.)
	Local aStruct  := NJM->(dBStruct()) // Obtém a estrutura
	Local nIt      := 0
	Local aAux     := {}
	Local aFldNJM  := {}
	Local cFilRom  := NJJ->NJJ_FILIAL
	Local cCodRom  := NJJ->NJJ_CODROM
	Local nPesoNJJ := NJJ->NJJ_PESO3
	Local nItRom := 0

	dbSelectArea( "NJM" )
	dbSetOrder( 1 )
	dbSeek( NJJ->NJJ_FILIAL  + NJJ->NJJ_CODROM )
	While .Not. Eof() .And. NJM->(NJM_FILIAL) = NJJ->(NJJ_FILIAL) .And. NJM->(NJM_CODROM) = NJJ->( NJJ_CODROM ) 

		aAux := {}
		For nIt := 1 To Len(aStruct)
			AADD(aAux,{ aStruct[nIt][1] , NJM->&(AllTrim(aStruct[nIt][1]))  } )
		Next nIt

		AADD(aFldNJM,aAux)

		nItRom++

		NJM->( dbSkip() )
	EndDo			


	For nIt := 1 to Len(aFldNJM)

		cCodPro  := ''
		cLotCtl  := '' 
		cSubTipo := ''
		cLocal   := ''
		cTes     := ''
		lAtuEst  := .F.

		nPos := aScan(aFldNJM[nIt], {|x| AllTrim(x[1]) == "NJM_CODPRO"})			
		If nPos > 0
			cCodPro := aFldNJM[nIt][nPos][2]
		EndIf

		nPos := aScan(aFldNJM[nIt], {|x| AllTrim(x[1]) == "NJM_LOTCTL"})			
		If nPos > 0
			cLotCtl := aFldNJM[nIt][nPos][2]
		EndIf

		nPos := aScan(aFldNJM[nIt], {|x| AllTrim(x[1]) == "NJM_SUBTIP"})			
		If nPos > 0
			cSubTipo := aFldNJM[nIt][nPos][2]
		EndIF

		nPos := aScan(aFldNJM[nIt], {|x| AllTrim(x[1]) == "NJM_TES"})			
		If nPos > 0
			cTes := aFldNJM[nIt][nPos][2]
			lAtuEst := IIF(Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_ESTOQUE") == 'S',.T.,.F.) 
		EndIF

		clocal := NJJ->NJJ_LOCAL
		nPos := aScan(aFldNJM[nIt], {|x| AllTrim(x[1]) == "NJM_LOCAL"})			
		If nPos > 0 .And. !empty(aFldNJM[nIt][nPos][2])
			cLocal := aFldNJM[nIt][nPos][2]
		EndIF

		/*Se o produto não é algodão (grãos), tem rastro por lote e não tem lote na NJM e Parâmetro FIFO = Verdadeiro e TES atualiza estoque
		e subtipo (S)REMESSA P/ DEPÓSITO|(S)REMESSA P/ FORMAÇÃO LOTE|(S)SAIDA POR VENDA|(S)REMESSA ENTREGA FUTURA|(S)REMESSA VENDA A ORDEM*/
		If !AGRTPALGOD(cCodPro) .And. Rastro(cCodPro) .And. Empty(cLotCtl) .And. lRastFIFO .And. lAtuEst .And. (cSubTipo $ '20|21|40|41|42|44|46|52') 

			//Efetua a seleção do Lote
			If !QuebraNJM(2, /*cCodEnt*/, /*cLojEnt*/, NJJ->NJJ_CODSAF, cCodPro, cFilRom, @aFldNJM[nIt], nPesoNJJ, @aFldNJM, @nItRom, cLocal)
				lRet := .F.
			EndIf

		EndIF
	Next nIt

	If lRet	
		OG250DGNJM(aFldNJM, cFilRom, cCodRom)									
	EndIf

Return lRet


/** -------------------------------------------------------------------------------------
{Protheus.doc} MOVIESTQ
Responsavel por fazer o ajuste de estoque via movimentos internos

@param: nOperac - Tipo de Operação 3 = Inclusão; 
@author thiago.rover / vanilda.moggio
@since: 14/11/2017   / 08/03/18
------------------------------------------------------------------------------------- **/
Static Function MOVIESTQ(cCodRom, cProd  )
	Local aArea		 := GetArea()
	Local aCab		 := {}
	Local aLinhas	 := {}
	Local aDifLote   := {} //Quebra por lote dos fardos para atualizar estoque
	Local aFardos    := {} //fardos para atualizar estoque
	Local cTM		 := ""
	Local cNumDoc	 := ""
	Local lRet		 := .T.  
	Local nX		 := 0
	Local nI		 := 0	
	Local nModuloOld := nModulo		
	Local nPos       := 0
	Local ccD3       := ''
	Local lTemdif    :=.f.
	SaveInter() // Salva as Variaveis publicas	
	nModulo = 4 // Estoque 

	DbSelectArea("N9D")
	DbSetOrder(3)//N9D_FILIAL+N9D_TIPMOV+N9D_CODROM+N9D_STATUS
	DbGoTop()
	dbSeek(xFilial("NJJ")+'07'+cCodRom+'2')
	while  N9D->(!Eof()) .and. N9D->N9D_FILIAL+N9D->N9D_TIPMOV+N9D->N9D_CODROM+N9D->N9D_STATUS == xFilial("NJJ")+'07'+cCodRom+'2'
		lTemdif := .F.	
		If Posicione("DXI",1,N9D->N9D_FILORG+N9D->N9D_SAFRA+N9D->N9D_FARDO,"DXI_PSESTOQ") <> N9D->N9D_PESFIM	
			lTemdif := .t. 
			nPos := aScan( aDifLote, { |x| AllTrim( x[1] ) == AllTrim(N9D->N9D_lotect) } )
			If nPos == 0
				Aadd( aDifLote, { N9D->N9D_lotect,	N9D->N9D_PESDIF, N9D->N9D_numlot, N9D->N9D_dtvalid, N9D->N9D_safra, N9D->N9D_local, N9D->N9D_CLVL})								
			Else
				aDifLote[nPos,2] += N9D->N9D_PESDIF
			EndIf						
		EndIF

		Aadd( afardos, { N9D->N9D_filorg,N9D->N9D_safra, N9D->N9D_fardo, N9D->N9D_PESFim,N9D->N9D_ITEROM, lTemdif,N9D->N9D_CODROM})		

		N9D->(dbSkip()) 	  
	End

	//Grava lista de fardos não atualizados na IE
	For nX := 1 to Len(aDifLote)
		// Busca o proximo numero de documento
		cNumDoc := ProxNumDoc()

		If aDifLote[nX][2] > 0		   
			// verifica se TM x tipo R=Requisicao;D=Devolucao				
			cTM := SuperGetMV("MV_AGRTMDV",.F.,"")
			If lRet := SF5->(dbSeek(xFilial("SF5")+cTM))	
				lRet := SF5->F5_TIPO $ "D"
			EndIf	
		ElseIF aDifLote[nX][2] < 0 			
			cTM := SuperGetMV("MV_AGRTMPP",.F.,"")

			If lRet := SF5->(dbSeek(xFilial("SF5")+cTM))
				lRet := SF5->F5_TIPO $ "R"
			EndIf		
		Else  //sem diferenca nao precisa atualizr estoq 
			return(.T.)
		EndIf			

		If !lRet                
			Help(" ",1,"A240TM")
			return(.F.)
		EndIf

		If lRet			
			AADD(aCab, {"D3_DOC"		, cNumDoc				, Nil } ) // Documento
			AADD(aCab, {"D3_TM"			, cTM					, Nil } ) // TM 

			if Empty(CriaVar("D3_TM",.F.))
				ccD3:= Posicione( "SB1", 1, FWxFilial("SB1") + CProd, "B1_CC" ) 
			Else   
				ccD3:= CriaVar("D3_TM",.F.)			
			EndIf

			AADD(aCab, {"D3_CC"		, ccD3            , Nil } ) // Centro de Custo				
			AADD(aCab, {"D3_EMISSAO", ddatabase		  , Nil } ) // Data de Emissão
			AADD(aCab, {"D3_OBSERVA", cCodRom		  , Nil } ) // Nr. Romaneio
			AADD(aCab, {"D3_CODSAF" , aDifLote[nX][5] , Nil } ) // Safra
			AADD(aCab, {"D3_LOTECTL", aDifLote[nX][1] , Nil } ) // lote

			If !Empty(aDifLote[nX][3])
				AADD(aCab, {"D3_NUMLOTE",aDifLote[nX][3], Nil } ) // sub-lote
			EndIf
			If !Empty(aDifLote[nX][4])
				AADD(aCab, {"D3_DTVALID",aDifLote[nX][4], Nil } ) // validade
			EndIF

			If !Empty(aDifLote[nX][7])
				AADD(aCab, {"D3_CLVL" , aDifLote[nX][7]	, Nil } ) // classe de valor
			EndIF

			AADD(aLinhas,{})
			AADD(aTail(aLinhas),  {"D3_COD"	   ,CProd               ,NIL} )
			AADD(aTail(aLinhas),  {"D3_LOCAL"  ,aDifLote[nX][6]	    ,NIL} )
			AADD(aTail(aLinhas),  {"D3_QUANT"  ,Abs(aDifLote[nX][2]),NIL} )			
			AADD(aTail(aLinhas),  {"D3_LOTECTL",aDifLote[nX][1]     ,NIL} )

			If !Empty(aDifLote[nX][3])
				AADD(aTail(aLinhas),  {"D3_NUMLOTE",aDifLote[nX][3] ,NIL} )
			EndIf
			If !Empty(aDifLote[nX][4])
				AADD(aTail(aLinhas),  {"D3_DTVALID",aDifLote[nX][4]	,NIL} )
			EndIF			
			If !Empty(aDifLote[nX][7])
				AADD(aTail(aLinhas),  {"D3_CLVL" ,aDifLote[nX][7]   , Nil } ) // classe de valor
			EndIF

			If SF5->(F5_VAL) = "S"
				SB2->(dbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
				SB2->(dbSeek(xFilial("SB2") + CProd + aDifLote[nX][6]))

				For nI := 1 to 5									
					AADD(aTail(aLinhas),  {"D3_CUSTO"+Str(nI,1) ,( &("SB2->B2_CM" + Str(nI,1)) ) * Abs(aDifLote[nX][2] )		,NIL} )
				Next									
			EndIf
		EndIf
	Next nX

	Private	lMSErroAuto := .F.
	Private	lMSHelpAuto := .T.

	If Len(aCab) > 0
		MsAguarde({||MSExecAuto({|x,y,z|MATA241(x,y,z)},aCab,aLinhas,3)},"Aguarde","Ajustando estoque...") //"Aguarde..."###"Ajustando estoque..."

		If lMSErroAuto
			lRet := .F.
			MostraErro()
			DisarmTransaction()
		Else

			//Grava lista de fardos não atualizados na IE
			For nX := 1 to Len(aDifLote)	
				//-----------------------------------------------------------------------
				// Relaciona o numero do documento da movimentação de estoque ao romaneio
				//-----------------------------------------------------------------------
				DbSelectArea("N9E")
				cSeqn9E := GetSXENum("N9E","N9E_SEQUEN")

				If ( __lSx8 )
					ConfirmSX8()
				EndIf

				RecLock("N9E",.T.)
				N9E->N9E_FILIAL := xFilial("NJJ")
				N9E->N9E_SEQUEN := cSeqn9E
				N9E->N9E_CODROM := cCodRom
				N9E->N9E_Origem := '6'
				N9E->N9E_NUMMI  := cNumDoc				
				N9E->N9E_LOTE   := aDifLote[nX][1]
				N9E->N9E_QTDEST := aDifLote[nX][2]
				N9E->(MsUnLock())
			Next nX

			For nI := 1 to Len( afardos )
				If afardos[nI][6]
					dbSelectArea( "DXI" ) 
					dbSetorder(1)
					If DbSeek(afardos[nI][1] + afardos[nI][2] + afardos[nI][3])
						If RecLock( "DXI", .F. )
							DXI->(DXI_PSESTO) := afardos[nI][4]		
						EndIf	
					EndIf	
				EndIf	   			
			Next nI
		EndIf		
	EndIf

	//Guarda os registros das regras fiscai de venda da Ie para remessa
	//Apenas quando for subtipo 21 - (S) REMESSA PARA FORMAÇÃO LOTE
	If OG250DRFM(xFilial("NJJ"), cCodRom)
		OG250GGRF(aFardos)
	EndIf


	nModulo := nModuloOld  
	RestInter() // Restaura as variaveis publicas
	RestArea(aArea)

	Return( lRet )


	/*/{Protheus.doc} AGRFILNFE()
	função chamada pelo ponto de entrada no fonte SPEDNFE para carregar os parametros de impressão da danfe e não mostrar a tela de parametros.
	@type  Function
	@author rafael.kleestadt
	@since 21/05/2018
	@version 1.0
	@param param, param_type, param_descr
	@return _lDanfe, logical, quando chamado pelo botão DANFE fica .F. para não abrir a tela de parametros do DANFEII e DANFEIII
	@example
	(examples)
	@see (links_or_references)
	/*/
Function AGRFILNFE()

	Local oModel  := Nil
	Local oNJM	  := Nil	
	Local cFiltro := "" 
	Local nNfs    := 0
	Local aArea   := GetArea()
	Local lFunAgr := .F.
	Local cCondicao := ""

	If (IsInCallStack("OGA440") .OR. IsInCallStack("OGA440NFE")) .OR. IsInCallStack("OGC003") .OR. (IsInCallStack("OGA250F") .Or.; 
	IsInCallStack("OGA250G")) .OR. (IsInCallStack("OGA250") .OR. IsInCallStack("OGA251")) .OR. IsInCallStack("OGA245") 
		Pergunte("SPEDNFE",.F.)
	EndIf

	If IsInCallStack("OGA440") .OR. (IsInCallStack("OGA440NFE") .AND. !IsInCallStack("OGC003")) // Movimentações do Romaneio

		lFunAgr := .T.

		oModel := FwModelActive()
		oNJM   := oModel:GetModel( "NJMUNICO" )

		If oNJM:GetValue("NJM_TIPO")  $ "2|4|6|8|11"			
			MV_PAR01 := "1"			
			cFiltro := ".AND. F2_DOC == '" + oNJM:GetValue( "NJM_DOCNUM" ) + "' .AND. F2_SERIE == '" + oNJM:GetValue( "NJM_DOCSER" ) + "' "
		Else
			MV_PAR01 := "2"
			cFiltro := ".AND. F1_DOC == '" + oNJM:GetValue( "NJM_DOCNUM" ) + "' .AND. F1_SERIE == '" + oNJM:GetValue( "NJM_DOCSER" ) + "' "
		EndIf

	ElseIf IsInCallStack("OGC003") // Movimentações do Romaneio

		lFunAgr := .T.

		If AllTrim((cAlT2)->TIPO2)  $ "2|4|6|8|11"
			MV_PAR01 := "1"
			cFiltro := ".AND. F2_DOC == '" + (cAlT2)->NJM_DOCNUM + "' .AND. F2_SERIE == '" + (cAlT2)->NJM_DOCSER + "' "
		Else
			MV_PAR01 := "2"
			cFiltro := ".AND. F1_DOC == '" + (cAlT2)->NJM_DOCNUM + "' .AND. F1_SERIE == '" + (cAlT2)->NJM_DOCSER + "' "
		EndIf

	ElseIf IsInCallStack("OGA250F") .Or. IsInCallStack("OGA250G") // Informar documento de referência / Confirmação do romaneio

		lFunAgr := .T.

		cCondicao := ""		

		DbSelectArea("NJM")
		NJM->(DbSetOrder(1)) //NJM_FILIAL+NJM_CODROM+NJM_ITEROM
		If NJM->( DbSeek( xFilial( "NJM" ) + NJJ->( NJJ_CODROM ) ) )
			While ! NJM->( Eof() ) .And. NJM->( NJM_FILIAL + NJM_CODROM ) == xFilial( "NJM" ) + NJJ->( NJJ_CODROM )					

				If  IsInCallStack("OGA250G") // Confirmação Romaneio
					if  ( NJM->( NJM_SUBTIP ) $ SuperGetMV("MV_AGRO026", .F. , .T.))
						NJM->( DbSkip() )
						LOOP 
					EndIf					
				ElseIf  IsInCallStack("OGA250F") .And. NJM->NJM_SUBTIP == "46" // Confirmação Docto Referencia para remessa a ordem
					DbSelectArea("N8J")
					N8J->(dbSetOrder(1)) //N8J_FILIAL+N8J_DOCREF+N8J_SERREF+N8J_CLIREF+N8J_LOJREF

					If  N8J->(dbSeek(xFilial("N8J")+ NJM->NJM_DOCNUM + NJM->NJM_DOCSER))
						If Empty(N8J->N8J_DOCREF) .Or. Empty(N8J->N8J_SERREF) .Or. Empty(N8J->N8J_DTEREF)
							NJM->( DbSkip() )
							LOOP
						EndIF 	 	 
					EndIF
				EndIf		

				If nNfs >= 1
					cCondicao += " .Or. "
				EndIF

				If NJJ->NJJ_TIPO  $ "2|4|6|8|11"
					cCondicao += " F2_DOC == '" + NJM->( NJM_DOCNUM ) + "' .AND. F2_SERIE == '" + NJM->( NJM_DOCSER ) + "' "
				Else
					cCondicao += " F1_DOC == '" + NJM->( NJM_DOCNUM ) + "' .AND. F1_SERIE == '" + NJM->( NJM_DOCSER ) + "' "
				EndIf	

				nNfs ++

				NJM->( DbSkip() )
			EndDo	
		EndIf
		NJM->(DbCloseArea())

		If NJJ->NJJ_TIPO  $ "2|4|6|8|11"
			MV_PAR01 := "1"
		Else
			MV_PAR01 := "2"
		EndIf

		If !Empty(alltrim(cCondicao))
			cFiltro := " .AND. ( " + alltrim(cCondicao) + " ) "		
		EndIf

	ElseIf IsInCallStack("OGA250") .OR. IsInCallStack("OGA251") // Opção "SPED NFe" do OGA250/OGA251

		lFunAgr := .T.

		If NJJ->NJJ_TIPO  $ "2|4|6|8|11"
			MV_PAR01 := "1"
			cFiltro := ".AND. F2_DOC == '" + NJJ->NJJ_DOCNUM + "' .AND. F2_SERIE == '" + NJJ->NJJ_DOCSER + "' "
		Else
			MV_PAR01 := "2"
			cFiltro := ".AND. F1_DOC == '" + NJJ->NJJ_DOCNUM + "' .AND. F1_SERIE == '" + NJJ->NJJ_DOCSER + "' "
		EndIf	

	ElseIf IsInCallStack("OGA245") 

		lFunAgr := .T.

		MV_PAR01 := "2"
		cFiltro := ".AND. F1_DOC == '" + NK2->NK2_NUMNFT + "' .AND. F1_SERIE == '" + NK2->NK2_SERNFT + "' "
		
	EndIf

	If lFunAgr				
		MV_PAR02 := "2"
		MV_PAR03 := ""		
	EndIf

	RestArea(aArea)

Return cFiltro


/*/{Protheus.doc} OGA250GTRANS
Função genérica para abrir a tela de monitoramento para trasmissão
@author thiago.rover
@since 30/05/2018
@version undefined

@type function
/*/
Function OGA250GTRANS()

	Return MsgRun( STR0555, STR0014, {|| aRet := SPEDNFE() } ) //###"Alimentando Parâmetro para Transmissão..." ###"Romaneio" 


	/*/{Protheus.doc} TpAlgN9Z()
	Retorna o tipo do algodão conforme atbela de extensão N9Z
	@type  Static Function
	@author rafael.kleestadt
	@since 25/06/2018
	@version 1.0
	@param cPedido, caractere, código do pedido de venda
	@param cItem, caractere, item do pedido de venda
	@return cTipo, caractere, tipo do algodão conforme atbela de extensão N9Z
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function TpAlgN9Z(cPedido, cItem)
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local cTipo     := ""

	cQuery := "     SELECT N9Z_TIPALG "
	cQuery += "       FROM " + RetSqlName("EE7") + " EE7 "
	cQuery += " INNER JOIN " + RetSqlName("EE8") + " EE8 "
	cQuery += "         ON EE8_PEDIDO = EE7_PEDIDO AND EE8_FATIT = '" + cItem + "' "
	cQuery += "        AND EE8.EE8_FILIAL = EE7.EE7_FILIAL AND EE8.D_E_L_E_T_ = '' "
	cQuery += " INNER JOIN " + RetSqlName("N9Z") + " N9Z "
	cQuery += "         ON N9Z.N9Z_FILIAL = EE8.EE8_FILIAL AND N9Z.D_E_L_E_T_ = '' " 
	cQuery += "        AND N9Z_PEDIDO = EE8_PEDIDO AND N9Z_SEQUEN = EE8_SEQUEN AND N9Z_COD_I = EE8_COD_I AND N9Z.D_E_L_E_T_ = '' "
	cQuery += "      WHERE EE7_PEDFAT = '" + cPedido + "' "
	cQuery += "        AND EE7.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)

	DbSelectArea( cAliasQry ) 
	(cAliasQry)->( dbGoTop() )
	If .Not. (cAliasQry)->( Eof() )
		cTipo := (cAliasQry)->( N9Z_TIPALG )
	EndIf

Return cTipo


/** {Protheus.doc} OG250DQDEV
Relizar a gravacao dos dados do aviso\dco de todas as regras fiscais do itemdo romaneio

@author: vanilda.moggio
@since:  29/06/18
@Uso: 	 OGX008 - aO CONFIRMAR O ROMANEIO , Grava tabela de extencao gravar dados para posteriormente mostrar na emissao da nf 
@param   cRom, character, código do romaneio
@param   citRom, character, item  do romaneio
@return: aDcoNf, array com todos os avisos e dcos das regras fiscais
@type function
*/
Function OG250GRFD (cRom, cCliente, cLoja)
	Local aDcoNf  := {} 
	Local cNumAvi := ""
	Local cNumDco := ""
	Local cSeqDco := ""
	Local cTpAvis := ""
	Local cObserv := ""
	Local nx      := 0

	For nx := 1 To Len(__aRfVenda)
		if __aRfVenda[nx][2] = cRom 		
			cNumAvi := Posicione("N7S",1,FwXFilial("N7S") + __aRfVenda[nx][7] + __aRfVenda[nx][4] + __aRfVenda[nx][5] + __aRfVenda[nx][6],"N7S_NUMAVI")
			cNumDco := Posicione("N7S",1,FwXFilial("N7S") + __aRfVenda[nx][7] + __aRfVenda[nx][4] + __aRfVenda[nx][5] + __aRfVenda[nx][6],"N7S_NUMDCO")
			cSeqDco := Posicione("N7S",1,FwXFilial("N7S") + __aRfVenda[nx][7] + __aRfVenda[nx][4] + __aRfVenda[nx][5] + __aRfVenda[nx][6],"N7S_SEQDCO")
			cTpAvis := Posicione("N7S",1,FwXFilial("N7S") + __aRfVenda[nx][7] + __aRfVenda[nx][4] + __aRfVenda[nx][5] + __aRfVenda[nx][6],"N7S_TPAVIS")
			cObserv := getObsInd(cNumAvi, cCliente, cLoja, cTpAvis )
			aAdd(aDcoNf, {cNumAvi, cNumDco, cSeqDco, cTpAvis, cObserv})
		EndIF		
	Next nX

Return aDcoNf


/** {Protheus.doc} OG250GGRF
Guarda os registros das regras fiscai de venda da Ie

@author: vanilda.moggio
@since:  29/06/18
@Uso: 	 OGX008 - aO CONFIRMAR O ROMANEIO , Grava tabela de extencao gravar dados para posteriormente mostrar na emissao da nf 
@param   cRom, character, código do romaneio
@param   afardos, array, todos os fardos do romaneio 
@return: __aRfVenda, array com todas regras fiscais dos fardos
*/
Static Function OG250GGRF(afardos)
	Local nIt := 0

	// Guardar as regras fiscais de venda
	For nIt := 1 To Len(afardos)
		DbSelectArea("N9D")
		N9D->(DbSetOrder(2)) // N9D_FILIAL+N9D_FILORG+N9D_SAFRA+N9D_FARDO+N9D_TIPOMOV+N9D_STATUS)
		If  N9D->(DbSeek(afardos[nIt][1] + Fwxfilial('N7Q') + afardos[nIt][2] + afardos[nIt][3]+"04"+"2"))
			While N9D->(!Eof()) .AND. N9D->(N9D_FILIAL+N9D_FILORG+N9D_SAFRA+N9D_FARDO+N9D_TIPMOV+N9D_STATUS) == afardos[nIt][1] + Fwxfilial('N7Q') + afardos[nIt][2] + afardos[nIt][3]+"04"+"2"
				// Guardar as regras fiscais de venda
				nPosRV := aScan( __aRfVenda, { |x| AllTrim( x[1] ) == AllTrim(afardos[nIt][7] + afardos[nIt][5] + N9D->N9D_CODCTR + N9D->N9D_ITEETG + N9D->N9D_ITEREF) } )				
				If nPosRV == 0
					aAdd( __aRfVenda, {afardos[nIt][7] + afardos[nIt][5] + N9D->N9D_CODCTR + N9D->N9D_ITEETG + N9D->N9D_ITEREF, afardos[nIt][7] , afardos[nIt][5], N9D->N9D_CODCTR , N9D->N9D_ITEETG, N9D->N9D_ITEREF, N9D->N9D_CODINE} )
				EndIf		
				N9D->( dbSkip() )							
			EndDO			
		EndIf									
	Next nIt
	N9D->(DbCloseArea())
return .T.


/** {Protheus.doc} OG250GSTFR
Atualiza Status do Fardo na DXI ao confirmar romaneio de venda 
@return:	.T. OU .F.
@author: 	claudineia.reinert
@since: 	19/07/2018
*/
Function OG250GSTFR(cFilRom, cCodRom)
	Local aFrdSts 		:= {}
	Local aAreaAtu		:= GetArea()
	Local aAreaN7Q 		:= N7Q->(GetArea())
	Local lPesoAprov 	:= .F. //armazena se certificação de peso da IE esta aprovada
	Local aIEs  		:= OG250DIES(cFilRom, cCodRom)  //busca as IEs na N9E

	DbSelectArea("N7Q")
	N7Q->(DbSetOrder(1))

	DbSelectArea("N9D")
	N9D->(DbSetOrder(6)) // N9D_FILORG+N9D_CODROM+N9D_TIPMOV
	If N9D->(DbSeek(cFilRom+cCodRom+"07"))
		While N9D->(!Eof()) .AND. N9D->(N9D_FILORG+N9D_CODROM+N9D_TIPMOV) == cFilRom+cCodRom+"07"
			If !lPesoAprov .AND. N7Q->(DbSeek(FWxFilial("N7Q")+N9D->N9D_CODINE))
				If N7Q->N7Q_STAPCE $ '4' //IE esta com peso certificado aprovado, ou seja containers todos certificados
					lPesoAprov := .T.
				ElseIf N7Q->N7Q_TPMERC $ '1' //MERCADO INTERNO, não tem container
					lPesoAprov := .T.
				Else 
					Exit //sai do while e não atualiza o status do fardo
				EndIf
			ElseIf __lnewNeg .and. LEN(aIEs) = 0 //NÃO USA IE NO ROMANEIO
				lPesoAprov := .T.
			EndIf

			If lPesoAprov .AND. N9D_STATUS == "2"
				AADD(aFrdSts, { N9D->N9D_FILIAL, N9D->N9D_SAFRA, N9D->N9D_FARDO })
			EndIf	
			N9D->(DbSkip())
		EndDo
	EndIf

	If Len(aFrdSts) > 0
		//incluir(1) status do fardo na DXI(DXI_STATUS)
		AGRXFNSF( 1 , "RomaneioVnd", aFrdSts ) //romaneio venda
	EndIf

	RestArea(aAreaN7Q)  
	RestArea(aAreaAtu)  
Return .T.

/** -------------------------------------------------------------------------------------
{Protheus.doc} ProxNumDoc()
Retorna o próximo número disponível para o documento

@author: thiago.rover
@since: 14/11/2017
------------------------------------------------------------------------------------- **/
Static Function ProxNumDoc()
	Local aAreaAtu 	:= GetArea()
	Local cNumDoc 	:= ""
	Local cMay			:= ""

	//----------------------------------------------------
	// Inicializa o numero do Documento com o ultimo + 1
	//----------------------------------------------------
	dbSelectArea("SD3")
	cNumDoc := NextNumero("SD3",2,"D3_DOC",.T.)
	cNumDoc := A261RetINV(cNumDoc)
	dbSetOrder(2)
	dbSeek(cFilAnt+cNumDoc)
	cMay := "SD3"+Alltrim(cFilAnt)+cNumDoc
	While SD3->(D3_FILIAL+D3_DOC) == cFilAnt + cNumDoc .Or. !MayIUseCode(cMay)
		If SD3->D3_ESTORNO # "S"
			cNumDoc := Soma1(cNumDoc)
			cMay := "SD3"+Alltrim(cFilAnt)+cNumDoc
		EndIf
		dbSkip()
	EndDo

	RestArea( aAreaAtu )
Return( cNumDoc )

/*/{Protheus.doc} FATVLDEVE
Após confirmação do romaneio, parametro MV_AGRO047=.F., atualiza Valor fiscal no contrato e romaneio conforme a entrada de devolução 
NJM deve estar posicionada
@type function
@version  P12
@author claudineia.reinert
@since 20/09/2022
@return Logical, Padrão .T.
/*/
Static Function FATVLDEVE()
	Local cQrySD1 := GetNextAlias()
	Local aAreaNJR := NJR->(GetArea())

	// Verifica se tem nota fiscal emitida para o romaneio / item do romaneio
	BeginSql Alias cQrySD1
		Select SUM(SD1.D1_TOTAL) AS D1_TOTAL, SUM(SD1.D1_QUANT) AS D1_QUANT
		From %table:SD1% SD1
		Where SD1.D1_FILIAL  = %xFilial:SD1% 
		And SD1.D1_CODROM  = %Exp:NJM->NJM_CODROM%
		And SD1.D1_ITEROM  = %Exp:NJM->NJM_ITEROM%
		And SD1.D1_CTROG   = %Exp:NJM->NJM_CODCTR%
		And SD1.%NotDel%
	EndSql

	(cQrySD1)->(DbGoTop())
	If !(cQrySD1)->(Eof())
		If (cQrySD1)->(D1_TOTAL) != NJM->NJM_VLRTOT //faz somente se houver diferença
			DbSelectArea("NJR")
			NJR->(DbSetOrder(1))
			If NJR->(DbSeek(xFilial("NJR")+ NJM->NJM_CODCTR))
				If  RecLock( "NJR", .f. )
					NJR->( NJR_VLEFIS ) -= NJM->( NJM_VLRTOT ) //ajusta NJR removendo valor do romaneio que foi ajustado na atualização do romaneio
					NJR->( NJR_VLEFIS ) += (cQrySD1)->(D1_TOTAL) //Ajusta NJR com o valor da devolução SD1
					NJR->( msUnLock() )
				EndIf

				If RecLock( "NJM", .f. ) //Atualiza o valor de devolução no romaneio
					NJM->( NJM_VLRUNI ) := ROUND((cQrySD1)->(D1_TOTAL) / (cQrySD1)->(D1_QUANT), TamSX3( "NJM_VLRUNI" )[2])
					NJM->( NJM_VLRTOT ) := (cQrySD1)->(D1_TOTAL) 
					NJM->( msUnLock() ) 
				EndIf
			EndIf

			// Atualiza qtdes do contrato				
			OGX010QTDS()
		EndIf
	EndIf
	RestArea(aAreaNJR)
Return .T.
