#INCLUDE "PROTHEUS.CH"
#INCLUDE "RUP_TMS.CH"

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_TMS
@autor		: Eduardo Alberti
@descricao	: Atualização De Dicionários Para UpdDistr
@since		: Sep./2015
@using		: UpdDistr Para TMS
@review	:
@param		: 	cVersion 	: Versão do Protheus, Ex. ‘12’
				cMode 		: Modo de execução. ‘1’=Por grupo de empresas / ‘2’=Por grupo de empresas + filial (filial completa)
				cRelStart	: Release de partida. Ex: ‘002’ ( Este seria o Release no qual o cliente está)
				cRelFinish	: Release de chegada. Ex: ‘005’ ( Este seria o Release ao final da atualização)
				cLocaliz	: Localização (país). Ex: ‘BRA’
/*/
//---------------------------------------------------------------------------------------------------
Function RUP_TMS( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

Local aArea 			:= GetArea()
Local aArSXB			:= SXB->( GetArea() )
Local aArSX1			:= {}
Local aArSX3			:= SX3->( GetArea() )
Local aArSX7			:= SX7->( GetArea() )
Local aArSX6			:= SX6->( GetArea() )
Local aDicSXB			:= {}
Local aDicSX3       	:= {}
Local aDicSX7       	:= {}
Local aDicSX6			:= {}	
Local aDicSX9			:= {} 
Local nL				:= 0
Local nAtu				:= 0
Local lAtu				:= .F.	
Local cAliasQry  		:= nil
Local cQryDocTms 		:= ' '
Local cAliasDA3			:= GetNextAlias()
Local cQryAtvDmd		:= ' '
Local aPerg				:= {}
Local xTamPadR			:= ''

Default cVersion		:= ''
Default cMode			:= '1'
Default cRelStart		:= ''
Default cRelFinish		:= ''
Default cLocaliz		:= ''
	
	//-- Executa Uma Vez Por Empresa
#IFDEF TOP
	If cMode == "1"

		//-- Release Maior Ou Igual a '007'
		If cRelStart >= "007"
		
			//-- Colocado Os Comandos TmsLogMsg dentro Dos 'If's Acima Pois Repetia Muito No Console.Log
			TmsLogMsg(,STR0001 + 'RUP_TMS: ' + DtoC(dDataBase) + STR0002 + Time()) //-- ' Inicio RUP_TMS: '  ' Hora: '
			TmsLogMsg(,STR0003 + ' cMode = ' + cMode + Iif( cMode == '1', STR0004 , STR0005)) //-- 'Executando' 'Por Grupo De Empresas' 'Por Empresa + Filial'
			TmsLogMsg(,STR0006 + ' >= 007') //-- 'Release Inicial'

			//--------------------------------------------------------------------------------------------------------------//
			//--  Montagem Dos Vetores Dos Dicionarios Que Serão Ajustados Para Releases Maiores Que '007'                  //
			//--------------------------------------------------------------------------------------------------------------//
			
			//-- Ajustes Do Dicionário SX3
			//aAdd(aDicSX3,{'DYL','DYL_DETPIC','X3_RELACAO','IF(INCLUI,"",TABELA("ET",DYL->DYL_CODPIC,.F.))'})
			//-- Ajustes Do Dicionário SX3 Para Divergencia De Produtos
			//aAdd(aDicSX3,{'DDT','DDT_GREMBP','X3_VALID'  ,'Vazio() .Or. (ExistCpo("SX5","LX"+M->DDT_GREMBP) .And. DDTPosVl())'	})
			
			//--------------------------------------------------------------------------------------------------------------//			
			//-- Ajustes Do Dicionário SX6
			//--------------------------------------------------------------------------------------------------------------//		
			//Aadd(aDicSX6,{'MV_NATTXBA','X6_VALID','TmsX6Valid(X6_FIL, X6_VAR, X6_TIPO, X6_CONTEUD, X6_CONTSPA, X6_CONTENG)'} )                                                     

			//--------------------------------------------------------------------------------------------------------------//			
			//-- Ajustes Do Dicionário SX7
			//--------------------------------------------------------------------------------------------------------------//		
			//aAdd(aDicSX7,{'DYL_CODPIC','001','X7_CHAVE','xFilial("SX5")+"ET"+M->DYL_CODPIC'})
			
			//--Exclusão do gatilho DIZ_STADCO
			//aAdd(aDicSX7,{'DIZ_STADCO','001','',''})
			
			//-- Exclusão relacionamento SDG
			//AAdd(aDicSX9,{ "SDG","001","DYX","DG_CODDES","DYX_NUMDES" } )
			
			//--Exclusão da Consulta Padrão MR
			//aAdd(aDicSXB,{"MR ", "1", "Tipo Pagamento"})
			
			//-------------------------------------------//
			//  Atualização Do Dicionário De Dados (SXB) //
			//-------------------------------------------//
			TmsLogMsg(,STR0018)
			nAtu := 0
			lAtu := .f.
			For nL := 1 To Len(aDicSXB)
				
				DbSelectArea("SXB")
				SXB->( DbSetOrder(1) )
				If SXB->( MsSeek( PadR( aDicSXB[nL,1], Len(SXB->XB_ALIAS) ) + PadR( aDicSXB[nL,2], Len(SXB->XB_TIPO) ) ) )
					nAtu ++
					lAtu := .T.

					RecLock("SXB", .F.)
					SXB->( DbDelete() )
					SXB->( MsUnlock() )
				EndIf
				TmsLogMsg(,STR0016 + aDicSXB[nL,1] + ' - ' + aDicSXB[nL,2] + STR0017 + Iif(lAtu, STR0009 , STR0010 )) //-- 'Campo: ' ' Propriedade: ' 'Atualizado' " Atualizado Anteriormente "
				lAtu := .f.
						
			Next nL
			
			TmsLogMsg(,STR0011 + Alltrim(Str(nAtu)) + STR0012 ) // 'Atualizado(s) ' ' Registros.'

			//--------------------------------------------------------------------------------------------------------------//
			//--  Atualização Do Dicionário De Dados (SX3).                                                                 //
			//--------------------------------------------------------------------------------------------------------------//
			TmsLogMsg(," Atualização de SX3 - Campos")
			nAtu := 0
			lAtu := .f.
			For nL := 1 To Len(aDicSX3)
			
				DbSelectArea("SX3")
				DbSetOrder(2)
				If MsSeek( PadR( aDicSX3[nL,2], Len(SX3->X3_CAMPO)) )

					If ValType(&(aDicSX3[nL,3])) == 'C'
						xTamPadR:= PadR(aDicSX3[nL,4], Len( &( aDicSX3[nL,3] ) ) )
					Else
						xTamPadR:= aDicSX3[nL,4]
					EndIf

					//-- Efetua Macro Substituição Do Dicionário
					If &(aDicSX3[nL,3]) <> xTamPadR
						
						nAtu ++
						lAtu := .t.
						
						RecLock("SX3",.F.)
						&("SX3->" + aDicSX3[nL,3]) := aDicSX3[nL,4]
						SX3->(MsUnlock())
						
					EndIf
				EndIf
				
				TmsLogMsg(,'   SX3 - ' + STR0007 + aDicSX3[nL,2] + STR0008 + aDicSX3[nL,3] + ' ' + Iif(lAtu, STR0009 , STR0010 )) //-- 'Campo: ' ' Propriedade: ' 'Atualizado' " Atualizado Anteriormente "
				lAtu := .f.
						
			Next nL
			
			TmsLogMsg(,STR0011 + Alltrim(Str(nAtu)) + STR0012 ) // 'Atualizado(s) ' ' Registros.'
			
			//--------------------------------------------------------------------------------------------------------------//
			//--  Atualização Do Dicionário De Parâmetros (SX6)                                                             //
			//--------------------------------------------------------------------------------------------------------------//
			TmsLogMsg(," Atualização de SX6 - Parâmetros")
			FsAtuSX6(aDicSX6 , cRelStart , cMode )
			
			//--------------------------------------------------------------------------------------------------------------//
			//--  Atualização Do Dicionário De Gatilhos (SX7).                                                              //
			//--------------------------------------------------------------------------------------------------------------//
			TmsLogMsg(," Atualização de SX7 - Gatilhos")
			nAtu := 0
			lAtu := .f.
			For nL := 1 To Len(aDicSX7)
			
				DbSelectArea("SX7")
				SX7->(DbSetOrder(1))
				
				If MsSeek(PadR(aDicSX7[nL,1],Len(SX7->X7_CAMPO)) + PadR(aDicSX7[nL,2],Len(SX7->X7_SEQUENC)) )
					//-- Efetua Macro Substituição Do Dicionário
					If	&(aDicSX7[nL,3]) <> PadR(aDicSX7[nL,4],Len(&(aDicSX7[nL,3])))
					
						nAtu ++
						lAtu := .t.

						RecLock("SX7",.F.)
						&("SX7->" + aDicSX7[nL,3]) := aDicSX7[nL,4]
						SX7->(MsUnlock())
						
					EndIf
				EndIf
				
				TmsLogMsg(,'    SX7 - ' + STR0013 + aDicSX7[nL,1] + STR0014 + aDicSX7[nL,2] + STR0007 + aDicSX7[nL,3] + ' ' + Iif(lAtu, STR0009 , STR0010 )) //-- ' Gatilho: ' ' Sequencia: ' ' Campo: ' ' Atualizado ' " Atualizado Anteriormente " 
				lAtu := .f.
				
			Next nL
			TmsLogMsg(,STR0011 + Alltrim(Str(nAtu)) + STR0012 ) //-- ' Atualizado(s) ' ' Registros '
			
			//-------------------------------------------//
			//  Atualização Do Dicionário De Dados (SX9) //
			//-------------------------------------------//
			TmsLogMsg(,"Atualização campos SX9")
			nAtu := 0
			lAtu := .f.
			For nL := 1 To Len(aDicSX9)
				dbSelectArea("SX9")
				SX9->( DBSetOrder(1))
				If SX9->( MsSeek( aDicSX9[nL][1] ) )
					While SX9->(!Eof()) .And. SX9->X9_DOM == aDicSX9[nL][1]

						If SX9->X9_DOM == aDicSX9[nL][1] ;
							.And. SX9->X9_CDOM == aDicSX9[nL][3];
							.And. RTrim(SX9->X9_EXPDOM) == RTrim(aDicSX9[nL][4]) ;
							.And. RTrim(SX9->X9_EXPCDOM ) == RTrim(aDicSX9[nL][5] )

							nAtu ++
							lAtu := .T.

							RecLock("SX9", .F.)
							SX9->( DbDelete() )
							SX9->( MsUnlock() )
							
							TmsLogMsg(, "SX9 - Dominio: " + aDicSX9[nL][1] + ' - Contra Dominio: ' + aDicSX9[nL][3] + STR0017 ) //-- 'Campo: ' ' Propriedade: ' 'Atualizado' " Atualizado Anteriormente "
							lAtu := .F.

						EndIf
						SX9->(dbSkip())
					EndDo
				EndIf 
			Next nL 

		TmsLogMsg(,STR0015 + 'RUP_TMS: ' + DtoC(dDataBase) + STR0002 + Time()) //-- ' Fim ' ' Hora: '

		EndIf
		
		//-- Release Maior ou Igual que '023'
		If cRelFinish >= "023"

			TmsLogMsg(,"Inicio Atualização Pergunte TMB144...")

			aAdd(aPerg, "Exibir Monitor de CT-e ?")
			aAdd(aPerg, "Calcula Romaneio SIGAGFE ?")
			aAdd(aPerg, "Calcula Romaneio SIGAGFE ?")
			nL := 1
			lAtu := .T.

			aArSX1 := SX1->(GetArea())
			SX1->(DbSetOrder(1)) //X1_GRUPO+X1_ORDEM
			cPerg := Padr("TMB144", Len(SX1->X1_GRUPO))

			If SX1->(MsSeek(cPerg+"07"))
				While SX1->(!Eof()) .AND. SX1->X1_GRUPO == cPerg .AND. nL <= Len(aPerg)
					If AllTrim(SX1->X1_PERGUNT) != aPerg[nL]
						lAtu := .F.
						Exit
					EndIf

					If lAtu .AND. SX1->X1_ORDEM == "09" .AND. AllTrim(SX1->X1_PERGUNT) == "Calcula Romaneio SIGAGFE ?"
						RecLock("SX1", .F.)
						dbDelete()
						MsUnlock()
						TmsLogMsg(,"Excluido item 09 do Pergunte TMB144.")
					EndIf

					nL++
					SX1->(dbSkip())
				EndDo
			EndIf

			RestArea(aArSX1)
			TmsLogMsg(,"Fim Atualização Pergunte TMB144...")
		EndIf

	ElseIf cMode == "2"
		
		//--------------------------------------------------------------------------------------------------------------//			
		//-- Ajustes Do Dicionário SX6
		//--------------------------------------------------------------------------------------------------------------//		
		//Aadd(aDicSX6,{'MV_NATTXBA','X6_VALID','TmsX6Valid(X6_FIL, X6_VAR, X6_TIPO, X6_CONTEUD, X6_CONTSPA, X6_CONTENG)'} )                                                     

		//--------------------------------------------------------------------------------------------------------------//
		//--  Atualização Do Dicionário De Parâmetros (SX6)                                                             //
		//--------------------------------------------------------------------------------------------------------------//
		TmsLogMsg(," Atualização de SX6 - Parâmetros")
		FsAtuSX6(aDicSX6 , cRelStart , cMode )
	
	EndIf
#ENDIF
	RestArea( aArSX7 )
	RestArea( aArSXB )
	RestArea( aArSX3 )
	RestArea( aArSX6 )
	RestArea( aArea )

Return NIL

//-------------------------------
//-- Atualiza SX6
//-------------------------------
Static Function FsAtuSX6(aDicSX6, cRelStart, cMode )
Local nCount	:= 1 
Local cUpd 		:= ""
Local lDicInDB 	:= MPDicInDB()
Local cCampo	:= ""
Local cTipo		:= ""
Local cNewVar	:= ""
Local lAlt		:= .F. 

Default aDicSX6		:= {}
Default cRelStart	:= ""
Default cMode		:= "" //-- Modo de execução. ‘1’=Por grupo de empresas / ‘2’=Por grupo de empresas + filial (filial completa)

//-- Executa alteração de dicionário para Release superior ou igual a 12.1.17
If cRelStart >= "017" 
	dbSelectArea("SX6")
	SX6->( dbSetOrder(1) )

	For nCount := 1 To Len(aDicSX6)
		lAlt	:= .F. 
		cCampo 	:= aDicSX6[nCount,1]
		cTipo	:= aDicsX6[nCount,2]
		cNewVar	:= aDicSX6[nCount,3] 
		
		If lDicInDB .And. cMode == "1"

			cUpd := " UPDATE " + MPSysSqlName("SX6")
			cUpd += " SET " + cTipo + " = '" + cNewVar + "' "	
			cUpd += " WHERE X6_VAR 		= '" + cCampo  +"' "
			cUpd += " 	AND " + cTipo 	+ " != " + "'" + cNewVar + "'" 
			cUpd += " 	AND D_E_L_E_T_ 	= '' "

			lAlt	:= .T.

			If TCSqlExec(cUpd) < 0 
				lAlt := .F. 
			EndIf

		Else

			//-- Tratamento filial em branco
			If SX6->(MsSeek(Replicate(" ", FwSizeFilial())+ cCampo) )
				If SX6->(&(cTipo)) <> cNewVar
					RecLock("SX6",.F.)
					SX6->(&(cTipo)) := cNewVar
					MsUnlock()
					lAlt	:= .T. 
				EndIf
			EndIf

			//-- Tratamento Referente Empresa
			If SX6->(MsSeek(PadR(FwCompany(),FwSizeFilial())+cCampo))
				If SX6->(&(cTipo)) <> cNewVar
					RecLock("SX6",.F.)
					SX6->(&(cTipo)) := cNewVar
					MsUnlock()
					lAlt	:= .T. 
				EndIf
			EndIf
			
			//-- Tratamento Referente Empresa + Filial
			If SX6->(MsSeek(PadR(FwCompany()+FwUnitBusiness(),FwSizeFilial())+cCampo))
				If SX6->(&(cTipo)) <> cNewVar
					RecLock("SX6",.F.)
					SX6->(&(cTipo)) := cNewVar
					MsUnlock()
					lAlt	:= .T. 
				EndIf
			EndIf

			//-- Código Completo da Filial Atual
			If SX6->(MsSeek(FwCodFil()+ cCampo ))
				If SX6->(&(cTipo)) <> cNewVar
					RecLock("SX6",.F.)
					SX6->(&(cTipo)) := cNewVar
					MsUnlock()
					lAlt	:= .T. 
				EndIf
			EndIf

		EndIf
		
		If lAlt
			TmsLogMsg(,'    SX6 - ' + cCampo + ' atualizado. - '  +  cNewVar ) 
		EndIf

	Next nCount
EndIf

Return
