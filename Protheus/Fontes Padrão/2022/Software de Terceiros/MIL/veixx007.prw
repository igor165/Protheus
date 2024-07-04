#Include "PROTHEUS.CH"
#Include "VEIXX007.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXX007 º Autor ³ Andre Luis Almeida º Data ³  08/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Minimo Comercial Valor de Venda e Resultado x Margem Lucro º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpcao ( 1-Valor de Venda / 2-Resultado )                  º±±
±±º          ³ aMinCom  (Vetor de Parametros/Retorno)                     º±±
±±º			 ³	  [n,01] = Chassi Interno (CHAINT)                        º±±
±±º			 ³	  [n,02] = Marca do Veiculo                               º±±
±±º			 ³	  [n,03] = Modelo do Veiculo                              º±±
±±º			 ³	  [n,04] = Segmento do Modelo                             º±±
±±º			 ³	  [n,05] = Cor do Veiculo                                 º±±
±±º			 ³	  [n,06] = Valor Negociacao                               º±±
±±º			 ³	  [n,07] = Valor Sugerido Venda                           º±±
±±º			 ³	  [n,08] = % de Valor de Venda do Minimo Comercial        º±±
±±º			 ³	  [n,09] = % do Resultado na Negociacao                   º±±
±±º			 ³    [n,10] = % do Resultado Minimo Comercial permitido      º±±
±±º          ³ cCdCliAt = Codigo do Cliente do Atendimento                º±±
±±º          ³ cLjCliAt = Loja do Cliente do Atendimento                  º±±
±±º          ³ cObsMCV = Obs sobre o Min.Com gravada no MEMO da Aprovacao º±±
±±º          ³ nPMapGeral = Percentual Geral TOTAL do Mapa da Aprovacao   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX007(nOpcao,aMinCom,cCdCliAt,cLjCliAt,cObsMCV,nPMapGeral)
Local aObjects    := {} , aPos := {} , aInfo := {} 
Local aSizeHalf   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor     := 1
Local nVlrVdaM    := 0 // Valor Minimo Comercial
Local nVlrDiff    := 0
Local ni          := 0
Local lRet        := .t.
Local lVAI_MNCOMU := ( VAI->(FieldPos("VAI_MNCOMU")) <> 0 ) // % do Minimo Comercial permitido para o Usuario
Local aMCVeic     := {}
Local cMVMIL0150  := GetNewPar("MV_MIL0150","0") // Atendimento de Veiculos - Valida Minimo Comercial (0-Por Veiculo/1-Por Atendimento)
Local aTotMin     := {0,0}
Private oVerd     := LoadBitmap( GetResources(), "BR_VERDE")
Private oBran     := LoadBitmap( GetResources(), "BR_BRANCO")
Private oVerm     := LoadBitmap( GetResources(), "BR_VERMELHO")
Default cCdCliAt  := "" 
Default cLjCliAt  := ""
Default cObsMCV   := "" // Preenche a Observacao para ser utilizada na gravacao do MEMO da Aprovacao ( VEIXX013 )
Default nPMapGeral := 0

For ni := 1 to len(aMinCom)
	
	If !Empty(Alltrim(aMinCom[ni,1]+aMinCom[ni,2]+aMinCom[ni,3])) // Verificar se o veiculo nao foi EXCLUIDO no Atendimento
	
		If !Empty(aMinCom[ni,1])
			VV1->(DbSetOrder(1))
			VV1->(DbSeek(xFilial("VV1")+aMinCom[ni,01]))
			aMinCom[ni,02] := VV1->VV1_CODMAR
			aMinCom[ni,03] := VV1->VV1_MODVEI
			aMinCom[ni,04] := VV1->VV1_SEGMOD
			aMinCom[ni,05] := VV1->VV1_CORVEI
			aMinCom[ni,07] := FGX_VLRSUGV( aMinCom[ni,01] , aMinCom[ni,02] , aMinCom[ni,03] , aMinCom[ni,04] , aMinCom[ni,05] , .t. , cCdCliAt , cLjCliAt ) // Valor Sugerido para Venda do Veiculo ( VVP (vlr tabela) + VVC (vlr cor adicional) )
			aMinCom[ni,08] := VV1->VV1_MNVLVD // % de Valor de Venda do Minimo Comercial
			aMinCom[ni,10] := VV1->VV1_MNCOMV // % do Minimo Comercial permitido
		EndIf
		
		If FGX_VV2(aMinCom[ni,02], aMinCom[ni,03], aMinCom[ni,04])		
	
			If nOpcao == 1 // Valor de Venda Minimo Comercial
		
				If aMinCom[ni,07] == 0
					aMinCom[ni,07] := FGX_VLRSUGV( "" , aMinCom[ni,02] , aMinCom[ni,03] , aMinCom[ni,04] , aMinCom[ni,05] , .t. , cCdCliAt , cLjCliAt ) // Valor Sugerido para Venda do Veiculo ( VVP (vlr tabela) + VVC (vlr cor adicional) )
				EndIf

				If left(GetNewPar("MV_MINCVDU","0"),1) $ "1/S" // Utiliza Minimo Comercial como Valor Sugerido de Venda
					aMinCom[ni,08] := 0
				Else
					If aMinCom[ni,08] == 0
						aMinCom[ni,08] := VV2->VV2_MNVLVD // % de Valor de Venda do Minimo Comercial do Modelo do Veiculo
						If aMinCom[ni,08] == 0
							aMinCom[ni,08] := GetNewPar("MV_MINCVLV",0) // % de Valor de Venda do Minimo Comercial Geral
						EndIf
					EndIf
				EndIf
				nVlrVdaM := ( aMinCom[ni,07] * ( aMinCom[ni,08] / 100 ) ) // Valor Minimo Comercial (Vlr de Venda - % Minimo Comercial)
				nVlrDiff := ( aMinCom[ni,06] - nVlrVdaM )

				aAdd(aMCVeic,{ ;
					IIf(!Empty(aMinCom[ni,1]),Alltrim(VV1->VV1_CHASSI)+" - ","")+Alltrim(aMinCom[ni,02])+" "+Alltrim(VV2->VV2_DESMOD) ,;
					aMinCom[ni,07] ,;
					aMinCom[ni,08] ,;
					nVlrVdaM ,;
					aMinCom[ni,06] ,;
					nVlrDiff })
	
			ElseIf nOpcao == 2 // Resultado do Minimo Comercial
		
				If aMinCom[ni,10] == 0
					aMinCom[ni,10] := VV2->VV2_MNCOMV // % do Minimo Comercial permitido do Modelo do Veiculo
					If aMinCom[ni,10] == 0
						aMinCom[ni,10] := GetNewPar("MV_MINCOMV",0) // % do Minimo Comercial permitido Geral
					EndIf
				EndIf
				//
				VAI->(dbSetOrder(4))
				VAI->(MsSeek(xFilial("VAI")+__cUserID))
				//
				If lVAI_MNCOMU
					If VAI->VAI_MNCOMV == "1" // Considerar o Minimo Comercial
						If VAI->VAI_MNCOMU <> 0
							FMX_HELP("VX007ERR002", STR0013) // Existe divergência no Cadastro de Equipe Técnica. O usuário logado tem % de Minimo Comercial cadastrado, porém não esta configurado para utiliza-lo. A configuração deve ser realizada através da rotina de Equipe Técnica (OFIOA180), aba Veiculos, campo 'Min.Comerc' (VAI_MNCOMV) com conteúdo igual a '2'. / Atencao
							lRet := .f.
							Exit
						EndIf
					ElseIf VAI->VAI_MNCOMV == "2" // Considerar o Minimo Comercial do USUARIO
						aMinCom[ni,10] := VAI->VAI_MNCOMU  // % do Minimo Comercial permitido para o Usuario
					EndIf
				EndIf
				//
				//////////////////////////////////////////////////////////////////////
				// Customiza o % do Minimo Comercial permitido                      //
				//////////////////////////////////////////////////////////////////////
				If ExistBlock("VX007RMC")
					aMinCom[ni,10] := ExecBlock("VX007RMC",.f.,.f.,{aMinCom[ni,10]})
				EndIf
				//
				cObsMCV += CHR(13)+CHR(10)
				//
				If VAI->VAI_MNCOMV == "1" .or. VAI->VAI_MNCOMV == "2" // Valida Minimo Comercial para o usuario ?

					If cMVMIL0150 == "0" // Atendimento de Veiculos - Valida Minimo Comercial 0 = Por Veiculo

						//////////////////////////////////////////////////////////////////////
						// % do Resultado da Negociacao  <  % do Minimo Comercial permitido //
						//////////////////////////////////////////////////////////////////////
						If round(aMinCom[ni,09],2) < round(aMinCom[ni,10],2) // Verifica o % 
							///////////////////////////////////////////////
							// Impossivel continuar!                     //
							// Minimo Comercial permitido      999999.99 //
							// Resultado do Mapa de Avaliacao  999999.99 //
							///////////////////////////////////////////////
							FMX_HELP("VX007ERR001", STR0006 + CHR(13) + CHR(10) + CHR(13) + CHR(10) +;
								AllTrim(STR0011) + ":" + Transform(round(aMinCom[ni,10],2),"@E 999999.99") + "%" + CHR(13) + CHR(10) +;
								AllTrim(STR0007) + ":" + Transform(round(aMinCom[ni,09],2),"@E 999999.99") + "%") // Impossivel continuar! / Minimo Comercial permitido / Resultado do Mapa de Avaliacao / Atencao
							lRet := .f.
							Exit
						Else
							cObsMCV += left(STR0011+":"+space(35),35)+Transform(round(aMinCom[ni,10],2),"@E 999999.99")+"%"+CHR(13)+CHR(10) // Minimo Comercial permitido      999999.99
						EndIf

					ElseIf cMVMIL0150 == "1" // Atendimento de Veiculos - Valida Minimo Comercial 1 = Por Atendimento

						aTotMin[1] += aMinCom[ni,10] // % do Minimo Comercial permitido
						aTotMin[2]++ // Qtde de Veiculos

					EndIf

				Else
					cObsMCV += STR0012+CHR(13)+CHR(10) // Nao considera Minimo Comercial para este usuario
				EndIf
				//
				cObsMCV += left(STR0007+":"+space(35),35)+Transform(round(aMinCom[ni,09],2),"@E 999999.99")+"%" // Resultado do Mapa de Avaliacao  999999.99
				//
			EndIf

		EndIf

	EndIf

Next

If lRet

	If nOpcao == 1 
		If len(aMCVeic) > 0 // Valor de Venda Minimo Comercial

			// Fator de reducao 80%
			For nCntFor := 1 to Len(aSizeHalf)
				aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
			Next   
			aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
			// Configura os tamanhos dos objetos
			aObjects := {}
			AAdd( aObjects, { 0,  0, .T. , .T. } ) // Veiculos
			aPos := MsObjSize( aInfo, aObjects )
			//

			DEFINE MSDIALOG oDlgMinCom TITLE STR0001 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Minimo Comercial
			oDlgMinCom:lEscClose := .F.
			
			@ aPos[1,1]+004,aPos[1,2]+001 LISTBOX oLboxMCV FIELDS HEADER "",STR0009,STR0002,STR0003,STR0004,STR0005,STR0010 COLSIZES 10,(aPos[1,4]-310),55,55,55,55,55 SIZE aPos[1,4]-2,aPos[1,3]-14 OF oDlgMinCom PIXEL
			oLboxMCV:SetArray(aMCVeic)
			oLboxMCV:bLine := { || { IIf(aMCVeic[oLboxMCV:nAt,06]==0,oBran,IIf(aMCVeic[oLboxMCV:nAt,06]>0,oVerd,oVerm)) ,;
				aMCVeic[oLboxMCV:nAt,01] ,;
				FG_AlinVlrs(Transform(aMCVeic[oLboxMCV:nAt,02],"@E 999,999,999.99")),;
				FG_AlinVlrs(Transform(aMCVeic[oLboxMCV:nAt,03],"@E 999,999,999.99")),;
				FG_AlinVlrs(Transform(aMCVeic[oLboxMCV:nAt,04],"@E 999,999,999.99")),;
				FG_AlinVlrs(Transform(aMCVeic[oLboxMCV:nAt,05],"@E 999,999,999.99")),;
				FG_AlinVlrs(Transform(aMCVeic[oLboxMCV:nAt,06],"@E 999,999,999.99"))}}

			ACTIVATE MSDIALOG oDlgMinCom CENTER ON INIT (EnchoiceBar(oDlgMinCom,{|| oDlgMinCom:End() },{ || oDlgMinCom:End() },,))
		Else
			lRet := .f.
		EndIf

	ElseIf nOpcao == 2 // Resultado do Minimo Comercial

		If VAI->VAI_MNCOMV == "1" .or. VAI->VAI_MNCOMV == "2" // Valida Minimo Comercial para o usuario ?
			If cMVMIL0150 == "1" // Atendimento de Veiculos - Valida Minimo Comercial 1 = Por Atendimento
				//////////////////////////////////////////////////////////////////////
				// % do Resultado da Negociacao  <  % do Minimo Comercial permitido //
				//////////////////////////////////////////////////////////////////////
				If round(nPMapGeral,2) < round(aTotMin[1]/aTotMin[2],2) // Verifica o % 
					///////////////////////////////////////////////
					// Impossivel continuar!                     //
					// Minimo Comercial permitido      999999.99 //
					// Resultado do Mapa de Avaliacao  999999.99 //
					///////////////////////////////////////////////
					FMX_HELP("VX007ERR003", STR0006 + CHR(13) + CHR(10) + CHR(13) + CHR(10) +;
						AllTrim(STR0011) + ":" + Transform(round(aTotMin[1]/aTotMin[2],2),"@E 999999.99") + "%" + CHR(13) + CHR(10) +;
						AllTrim(STR0007) + ":" + Transform(round(nPMapGeral,2),"@E 999999.99") + "%") // Impossivel continuar! / Minimo Comercial permitido / Resultado do Mapa de Avaliacao / Atencao
					lRet := .f.
				Else
					cObsMCV += left(STR0011+":"+space(35),35)+Transform(round(aTotMin[1]/aTotMin[2],2),"@E 999999.99")+"%"+CHR(13)+CHR(10) // Minimo Comercial permitido      999999.99
				EndIf
			EndIf
		EndIf

	EndIf
EndIf

Return lRet