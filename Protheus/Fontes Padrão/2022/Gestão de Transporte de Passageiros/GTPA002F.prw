#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'GTPA002.CH'
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} GTPA002F()
Função que faz a chamada para geração dos títulos POS
@type function
@author flavio.martins
@since 04/06/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*///,oMdl003,aDelete
Function GTPA002F(lJob,cEmp,cFil,cCod,cRevisa,nOp,lRevisao)

Default lJob  := .F.

	If lJob
		RpcSetType(3)
		RpcClearEnv()
		RpcSetEnv(cEmp,cFil,,,'GTP',,)
	Endif

	AtuaGI2("2",cCod,cRevisa, lRevisao)
    GeraTrechos(lJob,cCod,cRevisa,nOp,lRevisao)

Return


/*/{Protheus.doc} AtuaGI2
(long_description)
@type  Static Function
@author user
@since 09/03/2021
@version version
@param cTipo, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function AtuaGI2(cTipo,cCod,cRevisa, lRevisao)
Local aArea     := GetArea()

If lRevisao
	cRevisa := StrZero(Val(cRevisa)+1,tamsx3('GI3_REVISA')[1])
Endif

If GI2->(FieldPos("GI2_DTLOG")) > 0 .AND. GI2->(FieldPos("GI2_HRLOG")) > 0 .AND. GI2->(FieldPos("GI2_STATUS")) > 0
	DbSelectArea("GI2")
	GI2->(DbSetOrder(3))
	If GI2->(DbSeek(XFILIAL("GI2") + cCod + cRevisa))
		GI2->(RecLock(("GI2"),.F.))
		GI2->GI2_DTLOG  := DDATABASE
		GI2->GI2_HRLOG  := SUBSTR(TIME(), 1, 2) + SUBSTR(TIME(), 4, 2) 
		GI2->GI2_STATUS := cTipo
		GI2->(MsUnlock())
	EndIf
EndIf

RestArea(aArea)
Return 

/*/{Protheus.doc} GeraTrechos
(long_description)
@type  Static Function
@author user
@since 05/03/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GeraTrechos(lJob,cCod,cRevisa,nOpc,lRevisao)
Local aArea		:= GetArea()
Local aDelete   := {}
Local oModel    := FWLoadModel("GTPA002")
Local oMdlGI2	:= oModel:GetModel('FIELDGI2')
Local oMdlG5I	:= oModel:GetModel('GRIDG5I')
Local oMdl003   := nil
Local oMdlGI3	:= nil
Local oMdlGI4	:= nil
Local lRet		:= .T.
Local n1		:= 0
Local n2		:= 0
Local nItem		:= 1
Local lDelete	:= nOpc == MODEL_OPERATION_DELETE
Local cLinha	:= ""
Local cVia		:= ""
Local cOrgao	:= ""
Local cStatus	:= ""
Local cRev		:= "000"
Local cLocOri	:= ""
Local cLocDes	:= ""
Local lOk	:= .T.
Local lCamp  := .T.
Local nX	:= 0
Local nTamItem	:= TamSx3("GI4_ITEM")[1] 
Local cDeletado	:= ""
Local aTxGI4	:= {}
Local nPos		:= 0
Local cQuery	:= ""
	
	Begin Transaction

	//Efetuo a alteração do GI3_HIST com base na versão passada
	If lRevisao

		cQuery := "UPDATE " + RetSqlName('GI3') "
		cQuery += " SET GI3_HIST = '1' "
		cQuery += " WHERE GI3_FILIAL = '" + xFilial('GI3') + "'"
		cQuery += " AND GI3_LINHA = '" + cCod + "'" 
		cQuery += " AND GI3_REVISA = '" + cRevisa + "'" 
		cQuery += " AND D_E_L_E_T_ = ' ' "

		TcSqlExec(cQuery)

		cQuery := ''

		cRev := cRevisa


	EndIf
	
	DbSelectArea("GI2")
	GI2->(DbSetOrder(3))
	If GI2->(DbSeek(XFILIAL("GI2") + cCod + cRevisa))
		Sleep(10000)
		If oModel:Activate()
			cLinha	  := oMdlGI2:GetValue('GI2_COD')
			cVia	  := oMdlGI2:GetValue('GI2_VIA')
			cOrgao	  := oMdlGI2:GetValue('GI2_ORGAO')
			cStatus	  := oMdlGI2:GetValue('GI2_MSBLQL')
			cDeletado := oMdlGI2:GetValue('GI2_DEL')

			GI3->(DBOrderNickname('GI3REVISA'))//GI3_FILIAL+GI3_LINHA+GI3_REVISA
			GI4->(DbSetOrder(3))

			If lRet
				oMdl003	:= FwLoadModel('GTPA003')
					
				//Verifica se e uma exclusão sem versionamento
				If !lDelete
					//Verifica se e uma inclusão ou alteração com versionamento
					If nOpc == MODEL_OPERATION_INSERT
						oMdl003:SetOperation(MODEL_OPERATION_INSERT)
						
						If GI3->(DbSeek(xFilial('GI3')+cLinha+cRevisa)) .And. GI4->(DbSeek(xFilial('GI4')+cLinha+cRevisa))
							cRev	:= StrZero(Val(cRev)+1,tamsx3('GI3_REVISA')[1])
						EndIf
						
					Else
						//Verifica se e uma exclusão com versionamento 
						oMdl003:SetOperation(MODEL_OPERATION_UPDATE)
						
						//Posicionando na ultima revisao ativa
						dbSelectArea("GI3")	
						dbSelectArea("GI4")	
						
						GI3->(DbSeek(xFilial('GI3')+cLinha+cRevisa))
						GI4->(DbSeek(xFilial('GI4')+cLinha+cRevisa))
					
					EndIF
				//Verifica se existe a linha 
				ElseIf GI3->(DbSeek(xFilial('GI3')+cLinha+cRevisa))
					oMdl003:SetOperation(MODEL_OPERATION_DELETE)
				Endif

				dbSelectArea("GI4")
				GI4->(DbSetOrder(4))//Filia + Codigo Linha + Historico
				If GI4->(DbSeek(xFilial('GI4')+cLinha+'2')) 
					While GI4->(!Eof()) .AND. GI4->GI4_LINHA == cLinha .AND. GI4->GI4_HIST == '2'
						aAdd(aTxGI4,{GI4->GI4_LOCORI, GI4->GI4_LOCDES,;
								GI4->GI4_VIGTAR, GI4->GI4_TAR,;
								GI4->GI4_VIGTAX, GI4->GI4_TAX,;
								GI4->GI4_VIGPED, GI4->GI4_PED,;
								GI4->GI4_VIGSGF, GI4->GI4_SGFACU,;
								GI4->GI4_KMPED, GI4->GI4_KMASFA,;
								GI4->GI4_KMTERR, GI4->GI4_KM,;
								GI4->GI4_CCS, GI4->GI4_TEMPO,;
								GI4->GI4_TARANU, GI4->GI4_MSBLQL,;
								GI4->GI4_ITEM, GI4->GI4_SENTID,;
								GI4->GI4_LINHA})
						GI4->(dbSkip())
					EndDo
				EndIf

				cQuery := "UPDATE " + RetSqlName('GI4') "
				cQuery += " SET D_E_L_E_T_ = '*', "
				cQuery += " R_E_C_D_E_L_ = R_E_C_N_O_ "
				cQuery += " WHERE GI4_FILIAL = '" + xFilial('GI4') + "'"
				cQuery += " AND GI4_LINHA = '" + cLinha + "'" 
				cQuery += " AND D_E_L_E_T_ = ' ' "

				TcSqlExec(cQuery)

				If oMdl003:Activate()

					oMdlGI3	:= oMdl003:GetModel('GI3MASTER')
					oMdlGI4	:= oMdl003:GetModel('GI4DETAIL')
					If (nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE) .And. !lDelete .And. cDeletado == '2'
										
						If nOpc == MODEL_OPERATION_INSERT
						//Adicionar uma condição adicionar revisão apenas para caso alteração com revisao
							lRet := oMdlGI3:LoadValue('GI3_LINHA',cLinha)
							lRet := lRet .and. oMdlGI3:LoadValue('GI3_VIA',cVia)
							lRet := lRet .and. oMdlGI3:LoadValue('GI3_ORGAO',cOrgao)
							lRet := lRet .and. oMdlGI3:LoadValue('GI3_REVISA',cRev)
							lRet := lRet .and. oMdlGI3:LoadValue('GI3_DEL','2')
							lRet := lRet .and. oMdlGI3:LoadValue('GI3_MSBLQL',cStatus)
						ElseIf nOpc == MODEL_OPERATION_UPDATE
							lRet := lRet .and. oMdlGI3:LoadValue('GI3_MSBLQL',cStatus)
						EndIF

						//Geraçao dos trecho para GI4
						If lRet
							
							For n1 := 1 To oMdlG5I:Length()
								If !oMdlG5I:IsDeleted(n1)   	
									cLocOri := oMdlG5I:GetValue('G5I_LOCALI',n1) 
									For n2 := n1+1 to oMdlG5I:Length()
										cItem := STRZERO(nItem,nTamItem)
										If !oMdlG5I:IsDeleted( n2 )	
											cLocDes := oMdlG5I:GetValue('G5I_LOCALI',n2) // Locais Destino
											If oMdlG5I:GetValue('G5I_VENDA',n1) <> "2" .and. oMdlG5I:GetValue('G5I_VENDA',n2) <> "2"
												If !oMdlGI4:IsEmpty() 
													oMdlGI4:AddLine()
												EndIf
												lCamp := oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_ITEM"})[1],	cItem)
												lCamp := oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_LOCORI"})[1],cLocOri)
												lCamp := oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_LOCDES"})[1],cLocDes)
												lCamp := oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_SENTID"})[1],'1')
												lCamp := oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_MSBLQL"})[1],'1')
												
												nPos := aScan(aTxGI4,{|x| x[1] == cLocOri .And. x[2] == cLocDes})

												If nPos > 0
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_VIGTAR"})[1]	,aTxGI4[nPos][3])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_TAR"})[1]	,aTxGI4[nPos][4])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_VIGTAX"})[1]	,aTxGI4[nPos][5])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_TAX"})[1]	,aTxGI4[nPos][6])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_VIGPED"})[1]	,aTxGI4[nPos][7])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_PED"})[1]	,aTxGI4[nPos][8])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_VIGSGF"})[1]	,aTxGI4[nPos][9])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_SGFACU"})[1]	,aTxGI4[nPos][10])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_KMPED"})[1]	,aTxGI4[nPos][11])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_KMASFA"})[1]	,aTxGI4[nPos][12])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_KMTERR"})[1]	,aTxGI4[nPos][13])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_KM"})[1]		,aTxGI4[nPos][14])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_CCS"})[1]	,aTxGI4[nPos][15])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_TEMPO"})[1]	,aTxGI4[nPos][16])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_TARANU"})[1]	,aTxGI4[nPos][17])
												Endif
											Endif

											If !lRet
												Exit
											Else
												nItem++
											Endif
										
										EndIf
									Next
									If !lRet
										Exit
									Endif
								Else
									If aScan(aDelete,oMdlG5I:GetValue("G5I_LOCALI")) == 0
										Aadd(aDelete,oMdlG5I:GetValue('G5I_LOCALI', n1 ))// Trechos que foram deletados	
									Endif
								EndIf	  
							Next

						Endif
						
						If lRet
							For n1 := oMdlG5I:Length() To 1 Step -1
								If !oMdlG5I:IsDeleted(n1)   	
									cLocOri := oMdlG5I:GetValue('G5I_LOCALI',n1) 
									For n2 := n1-1 to 1  Step -1
										cItem := STRZERO(nItem,nTamItem)
										If !oMdlG5I:IsDeleted( n2 )	
											cLocDes := oMdlG5I:GetValue('G5I_LOCALI',n2) // Locais Destino
											If oMdlG5I:GetValue('G5I_VENDA',n1) <> "2" .and. oMdlG5I:GetValue('G5I_VENDA',n2) <> "2"
												If !oMdlGI4:IsEmpty() 
													oMdlGI4:AddLine()
												EndIf
												lCamp := oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_ITEM"})[1],	cItem)
												lCamp := oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_LOCORI"})[1],cLocOri)
												lCamp := oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_LOCDES"})[1],cLocDes)
												lCamp := oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_SENTID"})[1],'2')
												lCamp := oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_MSBLQL"})[1],'1')
												
												nPos := aScan(aTxGI4,{|x| x[1] == cLocOri .And. x[2] == cLocDes})

												If nPos > 0
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_VIGTAR"})[1]	,aTxGI4[nPos][3])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_TAR"})[1]	,aTxGI4[nPos][4])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_VIGTAX"})[1]	,aTxGI4[nPos][5])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_TAX"})[1]	,aTxGI4[nPos][6])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_VIGPED"})[1]	,aTxGI4[nPos][7])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_PED"})[1]	,aTxGI4[nPos][8])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_VIGSGF"})[1]	,aTxGI4[nPos][9])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_SGFACU"})[1]	,aTxGI4[nPos][10])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_KMPED"})[1]	,aTxGI4[nPos][11])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_KMASFA"})[1]	,aTxGI4[nPos][12])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_KMTERR"})[1]	,aTxGI4[nPos][13])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_KM"})[1]		,aTxGI4[nPos][14])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_CCS"})[1]	,aTxGI4[nPos][15])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_TEMPO"})[1]	,aTxGI4[nPos][16])
													oMdlGI4:LdValueByPos(oMdlGI4:GetStruct():GetArrayPos({"GI4_TARANU"})[1]	,aTxGI4[nPos][17])
												Endif
											Endif

											If !lRet
												Exit
											ElseIf lOk
												nItem++
											Endif
										
										EndIf
									Next
									If !lRet
										Exit
									Endif
								EndIf	  
							Next
						
						Endif
						
						If lRet
							For n1 :=  1 to Len(aDelete)
								If !oModel:GetModel('GRIDG5I'):SeekLine({{'G5I_LOCALI',aDelete[n1]}})
									Do While oMdlGI4:SeekLine({{'GI4_LOCORI',aDelete[n1]}}) .OR. oMdlGI4:SeekLine({{'GI4_LOCDES',aDelete[n1]}})
										If !(lRet := oMdlGI4:DeleteLine())
											Exit
										Endif
									Enddo
								Endif
								If !lRet
									Exit
								Endif
							Next
						Endif

					//Desativando o registro caso for deletado
					ElseIf nOpc == MODEL_OPERATION_UPDATE .And. !lDelete .And. cDeletado == '1'
						
						//Adicionando data de alteração e mudadando historico? para sim
						oMdlGI3:SetValue('GI3_DTALT', DDATABASE)
						oMdlGI3:SetValue('GI3_HIST', '1')
						oMdlGI3:SetValue('GI3_DEL', '1')
						//Adicionando data de alteração e mudadando historico? para sim
						// GI4 Grid com todos os trecho gerado
						For nX	:= 1 to oMdlGI4:Length()
							
							oMdlGI4:GoLine(nX)
							oMdlGI4:SetValue('GI4_DTALT', DDATABASE)
							oMdlGI4:SetValue('GI4_HIST', '1')
				
						Next nX
					
					Endif
					
					If lRet .or. oMdl003:VldData() 
						FwFormCommit(oMdl003)
						AtuaGI2("1",cCod,cRevisa, lRevisao)
					Else
						AtuaGI2("3",cCod,cRevisa, lRevisao)
						If !FwIsInCallStack('GTPI002_01')
							JurShowErro( oMdl003:GetErrormessage() )
							lRet := .F.
						EndIf
					EndIf 
				Else
					AtuaGI2("3",cCod,cRevisa, lRevisao)
				Endif
				oMdl003:DeActivate()
			Endif
			oMdl003:Destroy()
			FwModelActive(oModel)
			
			 
		EndIf
	EndIf 
	End Transaction

RestArea(aArea)
Return 

