if SB1->(DbSeek(xFilial("SB1")+cRacao)) /* !!!!!!!!!!!!!!!! */
            if Empty(cArmzRac)
                cArmzRac := SB1->B1_LOCPAD
            endif
            if SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+cArmzRac)) ;
				.and. ( nQuant <= SB2->B2_QATU .or. (nQuant-SB2->B2_QATU)<=GetMV("VA_DIFTRAT",,1) )

				// [nQuant > SB2->B2_QATU] Alt. MJ: 08.02.2018 : Tratar diferenca dos 0,0001 que acontecia e deixava o Ricardo Zampieri doido;
				// [ABS(nQuant-SB2->B2_QATU)<=GetMV("VA_DIFTRAT",,1)] Alt. MJ : 31.07.18 => Toshio Pediu para acertar estoque qdo diferenca pequena, tratada por parametro: VA_DIFTRAT				
				If nQuant > SB2->B2_QATU .or. ABS(nQuant-SB2->B2_QATU)<=GetMV("VA_DIFTRAT",,1)
					nQuant := SB2->B2_QATU				
				EndIf
				/*TODO
				No aEmpenho, quero adicionar as 2 rações (030046 e 030047) conforme arquivo de exemplo
				*/
                aEmpenho := { { cIndividuo, cArmz, nQtdIndiv, cLoteCTL },;
                              { SB1->B1_COD, cArmzRac, nQuant, "" } }
                
                aDados  := {}
                aCampos := U_LoadCustomCpo("SB8")
                For nI := 1 to Len(aCampos)
					aAdd( aDados, { aCampos[nI], SB8->&(aCampos[nI]) } )
				Next nI
				
				U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
							cMsg := "[VAEST021] Cria OP: " + AllTrim(cIndividuo),;
							.T./* lConOut */,;
							/* lAlert */ )
				cNumOP := ""
				FWMsgRun(, {|| cNumOP := u_CriaOp(cIndividuo, nQtdIndiv, cArmz) },;
								"Processando [VAEST003]",;
								cMsg )
                u_LimpaEmp(cNumOP)
                u_AjustEmp(cNumOP, aEmpenho)
				
				U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
							cMsg := "Processando [VAEST003]"+_ENTER_+"Apontamento OP: " + AllTrim(cNumOp),;
							.T./* lConOut */,;
							/* lAlert */ )
				FWMsgRun(, {|| u_ApontaOP(cNumOp, cMovTrat, cCC, cIC, cClvl, cLoteCTL, SB8->B8_X_CURRA ) },;
								"Processando [VAEST003]",;
								"Apontamento OP: " + AllTrim(cNumOp) )
				
				// MJ : 09.02.2018 : atualizar os campos customizados do NOVO registro SB8 gerado a partir do processamento do lote;
				_cQry := " SELECT MAX(R_E_C_N_O_) RECNO
				_cQry += " FROM "+ RetSqlName('SB8')
				_cQry += " WHERE B8_FILIAL ='"+xFilial("SB8")+"' 
				_cQry += " 	 AND B8_PRODUTO='"+cIndividuo+"'
				_cQry += " 	 AND B8_LOTECTL='"+cLoteCTL+"'
				_cQry += " 	 AND D_E_L_E_T_=' '
				
				cAlias        := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(_cQry)),(cAlias),.T.,.T.)
                If !(cAlias)->(Eof())
					SB8->(DbGoTo((cAlias)->RECNO))
					
					RecLock("SB8", .F.)
						For nI := 1 to Len(aDados)
							SB8->&(aDados[nI,1]) := aDados[nI, 2]
						Next nI
					SB8->(MsUnLock())
				EndIf
				(cAlias)->(DbCloseArea())
            else
                MsgStop("Não existe saldo suficiente para apontar a alimentação [" + AllTrim(cRacao) + "] do animal [" + AllTrim(cIndividuo) + "]." )
            endif
        else
            MsgStop("Racao [" + AllTrim(cRacao) + "] não foi encontrada no cadastro de produtos." )
        endif
