#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRMA710.CH"
#INCLUDE "FWMVCDEF.CH"     

Static cPCodUser	:= ""
Static aMDefEntRel	:= {}
Static aEnchEntRel	:= {}  

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA710

Rotina que centraliza as chamada do Perfil 360, para que seja filtrado o browse, 
conforme o registro posicionado.  


@sample	CRMA710(cFunction,cEntidade)

@param	    cFunction  - Função que será chamada 
			cEntidade  - Alias correnpondente a função

@return	Nenhum

@author	Victor Bitencourt
@since		12/05/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Function CRMA710(cFunction,cEntidade)

Local cAlias 	 	:= Alias()
Local aArea 	 	:= GetArea()
Local aBkpRotina	:= {}
Local aBkpMemos		:= Nil
Local aAddFil   	:= {}
Local aDadosSX2		:= {}
Local lLmpMemo		:= .F.
Local cFilter 		:=	""
Local aMenuDef		:= {}		 
Local cFunName	 	:= ""

Default cFunction 	:=	""
Default cEntidade 	:=	""

//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Limpa o contúdo da variável Private aMemos, pois como irá mudar de rotina.											//
//Esta situação estava bagunçando o MATXATU, onde misturava informação de rotinas diferentes, gerando error log			//
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("aMemos") <> "U"
	aBkpMemos := aMemos
	aMemos := Nil
	lLmpMemo := .T.
EndIf

cEntidade := AllTrim(cEntidade)

DbSelectArea(cAlias) //Deixa a última area aberta em foco novamente

If Type( "aRotina" ) == "A"
	aBkpRotina	:= aClone( aRotina ) 
EndIf

SaveInter()

If !Empty(cFunction) .AND. !Empty(cEntidade) 

	If !IsInCAllStack( cFunction )
	
		cFunName := FunName()

		If CRM710Perm( cFunction )

			If ( IsInCallStack("CRMA290") .And. !IsInCallStack("CRMA290RFUN") )
				CRM290ClrFil(3, .T., cFunction)
			EndIf 

			aMenuDef := FwLoadMenuDef( cFunction )
			
			If ValType(aMenuDef) == "A"
				aRotina := aMenuDef
			// TENTA PELO NOME DO FONTE NOVAMENTE
			ElseIf (Upper(SubStr(cFunction, 1, 2)) == "U_")
				aMenuDef := FwLoadMenuDef(SubStr(cFunction, 3))
 				If (ValType(aMenuDef) == "A")
					aRotina := aMenuDef
				Endif
			EndIf
		
			SetFunName(cFunction)

			Do Case
		        Case cFunction $ "CRMA320|TMKA341" //Suspect
				
					SUS->(DBSetOrder(5))//US_FILIAL+US_CODCLI+US_LOJACLI
					
					If SUS->( DBSeek( xFilial("SUS")+SA1->A1_COD+SA1->A1_LOJA) )
						ACH->(DBSetOrder(4))
						If ACH->( DBSeek(xFilial("ACH")+SUS->US_COD+SUS->US_LOJA))
							cFilter := "( ACH_CODIGO == '" + ACH->ACH_CODIGO + "' .And. ACH_LOJA == '" + ACH->ACH_LOJA + "' )"
						EndIf 
					EndIf
		
					If !Empty(cFilter)
						aAdd( aAddFil, { STR0001, cFilter , .T., .T.,, /*lFilterAsk*/, /*aFilParser*/, STR0002} )
						If cFunction = "CRMA320"
							CRMA320(aAddFil)
						Else
							TMKA341(,,,aAddFil)
						EndIf
					Else	
						Help("",1,"P360",,STR0006,1,0,,,,,,{STR0007})	//"Não existe Suspect relacionado a este Cliente."//"Verifique o histórico de conversão (Suspect->Prospect->Cliente)."	
					EndIf
				 			
				Case cFunction $ "CRMA700|TMKA260" //Prospect
					
					SUS->(DBSetOrder(5))//US_FILIAL+US_CODCLI+US_LOJACLI
				 			
					If SUS->( DBSeek( xFilial("SUS")+SA1->A1_COD+SA1->A1_LOJA) )
						cFilter := "( US_COD == '" + SUS->US_COD + "' .And. US_LOJA == '" + SUS->US_LOJA + "' )"
					EndIf
		
					If !Empty(cFilter)
						aAdd( aAddFil, { STR0001, cFilter , .T., .T.,, /*lFilterAsk*/, /*aFilParser*/, STR0002 } )//"Filtro Perfil 360" //"FILP360"
						If cFunction == "TMKA260"
							TMKA260(,,,,aAddFil)
						Else
							CRMA700(,aAddFil)
						EndIf
					Else
						Help("",1,"P360",,STR0008,1,0,,,,,,{STR0009})	//"Não existe Prospect relacionado a este Cliente."	/"Verifique o histórico de conversão (Prospect->Cliente)."
					EndIf
					
		        Case cFunction == "MATA030" //Clientes
					aDadosSX2  := CRMXGetSX2(cAlias)
					If !Empty(aDadosSX2)
				      	cUnico  := (cAlias)->&(aDadosSX2[1])
				      	cFilter	:= "A1_COD+A1_LOJA = '"+cUnico+"'"
				      	aAdd( aAddFil, { STR0001, cFilter , .T., .T.,, /*lFilterAsk*/, /*aFilParser*/, STR0002 } ) //"Filtro Perfil 360" //"FILP360"
			       EndIf
			       
					MATA030(,,,, aAddFil)
					
				Case cFunction == "CRMA190" //Conexões
					CRMA190(cAlias)	
					
				Case cFunction == "CRMA180" //Atividades	
					CRMA180(,,,, cAlias,,,,,)
				
				Case cFunction == "CRMA090" //Anotações
					CRMA090(,,cAlias)
		
				Case cFunction == "CRMA110" //Oportunidades
					CRMA110(,cAlias)
					
				Case cFunction == "CRMA310" //Pedido de Vendas
					CRMA310(,cAlias)
					
				Case cFunction == "CNTA300" //Contratos
				
					If MPUserHasAccess(cFunction, /*nOpc*/ , /*[cCodUser]*/, /*[lShowMsg]*/, /*[lAudit]*/  )	
						 DbSelectArea("CNC")
						 cFilter	:= "CNC_FILIAL = '"+xFilial("CNC")+"' AND CNC_CLIENT = '"+ SA1->A1_COD +"' AND CNC_LOJACL = '"+SA1->A1_LOJA+"'"
						 aAdd( aAddFil, { STR0001, cFilter , .T., .T.,"CNC", /*lFilterAsk*/, /*aFilParser*/, STR0002 } )//"Filtro Perfil 360" //"FILP360" 
					     
						 CNTA300(aAddFil)
				     
				     Else
				     	Alert( STR0004 ) //"Usuário não autorizado"
				     EndIf
		    	
		    	    		 
				Case cFunction == "CRMA470" //Cadastro de Contatos
					
					aDadosSX2  := CRMXGetSX2(cAlias)
					If !Empty(aDadosSX2)
				      	cUnico  := (cAlias)->&(aDadosSX2[1])
				      	cFilter	:= "AC8_FILIAL = '"+xFilial("AC8")+"' AND AC8_ENTIDA = '"+cAlias+"' AND AC8_CODENT = '"+cUnico+"'"
				      	aAdd( aAddFil, { STR0001, cFilter , .T., .T.,"AC8", /*lFilterAsk*/, /*aFilParser*/, STR0002 } ) //"Filtro Perfil 360" //"FILP360"
			       EndIf
					
					CRMA470(,aAddFil)		
		
				Case cFunction == "CRMA060" //Relação de Contatos
				
					CRMA060( cAlias, (cAlias)->(RecNo()) , 4)
		
				Case cFunction == "CRMA360" //Campanhas
		
					CRMA360(,cAlias)
		
				Case cFunction == "CRMA250" //Campanhas Rapidas
		
					CRMA250(cAlias)
					
				Case cFunction == "CRMA530" //Lista de Marketing
				
					aDadosSX2  := CRMXGetSX2(cAlias)
					If !Empty(aDadosSX2)
				      	cUnico  := (cAlias)->&(aDadosSX2[1])
				      	cFilter	:= "U6_FILENT = '"+xFilial(cAlias)+"' AND U6_ENTIDA = '"+cAlias+"' AND U6_CODENT = '"+cUnico+"'"
				      	aAdd( aAddFil, { STR0001, cFilter , .T., .T.,"SU6", /*lFilterAsk*/, /*aFilParser*/, STR0002 } ) //"Filtro Perfil 360" //"FILP360"
			       EndIf
				
					CRMA530( ,aAddFil )
			
				Case cFunction == "CRMA380" //Banco de Conhecimento
				
					aDadosSX2  := CRMXGetSX2(cAlias)
					If !Empty(aDadosSX2)
				      	cUnico  := (cAlias)->&(aDadosSX2[1])
				      	cFilter	:= "AC9_FILENT = '"+xFilial(cAlias)+"' AND AC9_ENTIDA = '"+cAlias+"' AND AC9_CODENT = '"+cUnico+"'"
				      	aAdd( aAddFil, { STR0001, cFilter , .T., .T.,"AC9", /*lFilterAsk*/, /*aFilParser*/, STR0002 } ) //"Filtro Perfil 360" //"FILP360"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
			       EndIf
				
					CRMA380(aAddFil)
					
				Case upper(cFunction) == "MSDOCUMENT" //Conhemiento
				
					MsDocument(cAlias,(cAlias)->(Recno()),4)
				
				Case upper(cFunction) == upper("A450F4Con") // Posição do Cliente
					A450F4Con()	
				
				Case upper(cFunction) == upper("CRMA080") // Funil de Venda
					CRMA080()	
					
				Case upper(cFunction) == upper("CRMA390") // Análise Gerencial das Contas
					CRMA390()	
		
		    	Case upper(cFunction) == upper("CRMA010") // Previsão de Venda
					CRMA010()	
					
				Case upper(cFunction) == upper("CA600Tracker") // Rastreador de Contas
					CA600Tracker()								
		
				Case upper(cFunction) == upper("CRMA430") // Despesas Financeiras
					CRMA430()		
					
				Case upper(cFunction) == upper("FATR050") // Metas X Realizado
					FATR050()		
				
				Case upper(cFunction) == upper("CRMA420") // Relatório Oportunidades
					CRMA420()		
				
				Case upper(cFunction) == upper("FATR020") // "Processos de Vendas
					FATR020()		
					
				Case upper(cFunction) == upper("CRMA450") // Oportunidade X Proc. Venda
					CRMA450()	
															
				Case upper(cFunction) == upper("CRMA801") // Painel de Propostas
					CRMA801()
					
				Case upper(cFunction) == upper("CRMA620") //SubSegmentos	
					IF cAlias == 'SA1'
						CRMA620(Nil, 'SA1', SA1->A1_COD, SA1->A1_LOJA, SA1->A1_CODSEG, 1)	
					EndiF										
				OtherWise 
					
					DbSelectArea(cEntidade)
					DbSelectArea(cAlias) // Voltar a area principal como corrente.
					
					cFilter := MntFilter(cAlias,cEntidade)
					
					If !Empty( cFilter )
						(cEntidade)->(DbSetFilter({|| &( cFilter ) }, cFilter ))
					EndIf	
					
					FwMsgRun(,{|| &(cFunction+"()") },Nil,STR0003) //"Aguarde..."
					(cEntidade)->(DbClearFilter())
					
			EndCase	
			
		ElseIf !Empty(cFunction) .AND. Empty(cEntidade)
			
			SetFunName(cFunction)

			If Upper(cFunction) == "TK010CON" //Perfil
			
				Do Case 
					//Cliente 
					Case cAlias == "SA1" 
						cCod	:= 	SA1->A1_COD
						cLoja	:=	SA1->A1_LOJA  
					//Prospect 
					Case cAlias == "SUS"
						cCod	:=	SUS->US_COD
						cLoja	:=	SUS->US_COD
					//Suspect
					Case cAlias == "ACH" 
						cCod	:=	ACH->ACH_CODIGO
						cLoja	:=	ACH->ACH_LOJA
				EndCase
				
				TK010Con(,,,,,cAlias,cCod+cLoja) 	
			Else	
				//	Tratando a opção de executar somente a rotina chamada. quando não é passado Alias.
				FwMsgRun(,{|| &(cFunction+"()") },Nil,STR0003) //"Aguarde..."
			EndIf
		EndIf
		SetFunName(cFunName)
	Else
		Alert(STR0005) // "Esta rotina já está em execução"
	EndIf
EndIf

If Type( "aRotina" ) == "A"
	aRotina := aClone( aBkpRotina ) 
EndIf

If lLmpMemo
	aMemos := aBkpMemos
EndIf

RestInter()

RestArea(aArea)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MntFilter

Rotina que monta o filtro em advpl levando em consideração o SX9 das tabelas 


@sample	MntFilter(cDom,cCtraDom) 

@param	    cDom  - Alias de Dominio
			cCtraDom - Alias de Contra dominio

@return	cFilter - Filtro em advpl  

@author	Victor Bitencourt
@since		12/05/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function MntFilter(cDom,cCDom) 

Local aAreaSX9		:= SX9->( GetArea() )
Local cFilterAux	:= ""
Local cFilter  		:= ""
Local cExpDOM		:= ""
Local aExpDOM	 	:= {}
Local aExpCDOM 		:= {}
Local aSX2Ent		:= {}
Local nLenCDOM 		:= 0
Local nX		 	:= 0
Local nY			:= 0
Local nLenSX9Ent	:= 0
Local aSX9Entity	:= {}

Default cDom   	:= ""
Default cCDom  	:= ""

If ( !Empty( cDom ) .And. !Empty( cCDom ) )
	
	If cDom <> cCDom 
	
		DbSelectArea("SX9")
		SX9->(DbSetOrder(2))//cCDom+cDom 
		
		If SX9->( DbSeek( cCDom + cDom ) )
			
			While ( SX9->( !Eof() ) .AND. SX9->X9_CDOM == cCDom .AND. SX9->X9_DOM == cDom )
				cExpDOM	:= AllTrim( SX9->X9_EXPDOM )
				If ( ( cExpDOM == "A1_COD+A1_LOJA" .Or. cExpDOM == "US_COD+US_LOJA"  ) .And. SX9->X9_ENABLE == "S" ) 
					aExpDOM		:= StrToKArr( AllTrim( SX9->X9_EXPDOM )			, "+" )
					aExpCDOM	:= StrToKArr( AllTrim( SX9->X9_EXPCDOM )		, "+" )
					nLenCDOM	:= Len( aExpCDOM )	
					
					aAdd( aSX9Entity, {	aExpDOM						,;
										aExpCDOM					,;
										nLenCDOM					,;
										AllTrim( SX9->X9_EXPCDOM )	,;
										AllTrim( SX9->X9_EXPDOM )	} )
				EndIf
				
				SX9->( DBSkip() )
			End
			
				
		EndIf
		
	Else
		
		aSX2Ent 	:= CRMXGetSX2(cDom, .T.)
		
		If !Empty( aSX2Ent ) .And. !Empty( aSX2Ent[1] )
			aExpDOM	:= StrToKArr( AllTrim( aSX2Ent[1] )	, "+" )
			aExpCDOM	:= aClone( aExpDOM )	
			nLenCDOM	:= Len( aExpCDOM )	
		EndIf
		
		aAdd( aSX9Entity, {	aExpDOM						,;
								aExpCDOM						,;
								nLenCDOM						,;
								AllTrim( SX9->X9_EXPCDOM )	,;
								AllTrim( SX9->X9_EXPDOM )	} )
		
	EndIf
	
	nLenSX9Ent := Len( aSX9Entity )
	
	For nY := 1 To nLenSX9Ent
		
	  	If !Empty( aSX9Entity[nY][1] ) .And. !Empty( aSX9Entity[nY][2] ) 
					
			If ( Len( aSX9Entity[nY][1] ) == Len( aSX9Entity[nY][2] ) )
				For nX := 1 To aSX9Entity[nY][3]
					cFilterAux += aSX9Entity[nY][2][nX] +" == '" + ( cDom )->&( aSX9Entity[nY][1][nX] ) + "'"
					If nX < aSX9Entity[nY][3]
						cFilterAux += " .And. "	 
					EndIf
				Next nX
			Else
				cFilterAux := AllTrim( aSX9Entity[nY][4] ) + " == '" + ( cDom )->&( AllTrim( aSX9Entity[nY][5] ) ) + "'"
			EndIf
					
		EndIf
		
		cFilter += "( " + cFilterAux + " ) "
		
		If nY < nLenSX9Ent
			cFilter += ".OR. "
		EndIf
		
		cFilterAux := ""
		
	Next nY		
					
EndIf

RestArea( aAreaSX9 ) 

Return( cFilter ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM710P360() 

Função efetua a carga do menu Perfil 360

@sample	CRM710P360()

@return	aMDefEntRel - array com as rotinas e contextos Perfil 360

@author	Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Function CRM710P360()

Local aArea			:= {}
Local cCodUser		:= ""
Local cSeek360		:= ""
Local nPos			:= 0
Local aEntAOR		:={}
Local aBkpEntAOR	:={}
Local aBkpEntAOQ	:={}
Local lRet			:= .T.

If ( Select("SX2") > 0 .And. Select("SIX") > 0 )

	aArea 		:= GetArea()
	cCodUser	:= RetCodUsr()
	
	If ( Empty( aMDefEntRel ) .Or. cCodUser <> cPCodUser )
		
		//Atualiza as variaveis estatica ( Melhoria de performance )
		aMDefEntRel	:= {}
		cPCodUser	:= cCodUser
		
		AOR->( DBSetOrder(1) )	
		AOO->( DBSetOrder(1) )
		
		BeginSQL Alias "TRB360"
			SELECT *
			FROM %table:AOP% AOP	
			INNER JOIN %table:AOQ% AOQ ON AOQ.AOQ_FILIAL = AOP.AOP_FILIAL
									AND AOQ.AOQ_CODPAP = AOP.AOP_CODIGO
									AND AOQ.%NotDel% 		 			 
			INNER JOIN %table:AOS% AOS ON AOS.AOS_FILIAL = AOP.AOP_FILIAL 
									AND AOS.AOS_CODPAP = AOP.AOP_CODIGO 					 
									AND %exp:FixQuery( ExistGroup( UsrRetGrp(Nil,cCodUser) ) )% AND AOS.%NotDel%			 	  		
			Where AOP.%NotDel%
			And AOP.AOP_FILIAL = %xFilial:AOP% 
			And AOP.AOP_STATUS = '1'
		EndSQL
		
		// -- Migra os itens de medicoes para a nova revisao
		While !TRB360->(Eof())
			cSeek360 := xFilial("AOR")+TRB360->AOQ_CODPAP+TRB360->AOQ_CODIGO
			AOR->(DbSeek(xFilial("AOR")+TRB360->AOQ_CODPAP+TRB360->AOQ_CODIGO))
			
			While !Eof() .AND. cSeek360 == AOR->AOR_FILIAL+AOR->AOR_CODPAP+AOR->AOR_CODNIV
				If AOR->AOR_STATUS =='1'
					
					If AOO->(DbSeek(xFilial("AOR")+AOR->AOR_CODROT)) .And. ( AllTrim(AOO->AOO_ROTINA) <> "MATA030" )
						
						//Verifica se ja existe rotina cadastrada em outros papeis
						if (aScan( aBkpEntAOR, { |x| Alltrim(x[1]) == AllTrim(AOO->AOO_DESCRI) .And. Alltrim(x[2]) == AllTrim(AOO->AOO_TPFUN) } )>0) 
							lRet := .F.
						EndIf	
						
						//Verifica se descricao do contexto é semelhante a outros papeis para este usuário
						If  lRet .And. (aScan( aBkpEntAOQ, { |x| Alltrim(x[1]) == AllTrim(TRB360->AOQ_DESCRI).And. !( Alltrim(x[1]) == AllTrim(AOO->AOO_CODIGO))})>0)
							nPos:= (aScan( aBkpEntAOQ, { |x| Alltrim(x[1]) == AllTrim(TRB360->AOQ_DESCRI)}))
							aadd(aMDefEntRel[nPos][2],{AOO->AOO_DESCRI,"CRMA710('"+AllTrim(AOO->AOO_ROTINA)+"','"+AOO->AOO_ALIAS+"')",0,8,0 })
							lRet:= .F.
						EndIf
						
						If lRet
							ADD OPTION aEntAOR TITLE AOO->AOO_DESCRI ACTION  "CRMA710('"+AllTrim(AOO->AOO_ROTINA)+"','"+AOO->AOO_ALIAS+"')"  OPERATION  8 ACCESS 0
							aadd(aBkpEntAOR,{AOO->AOO_DESCRI,AOO->AOO_TPFUN})  
						EndIf
					EndIF
				EndIf
			
				AOR->(dbSkip())
				lRet := .T.
				
			EndDo
			
			If len(aEntAOR)>0
				ADD OPTION aMDefEntRel TITLE TRB360->AOQ_DESCRI   ACTION aEntAOR	 OPERATION  8 ACCESS 0		
				aadd(aBkpEntAOQ,{TRB360->AOQ_DESCRI,AOO->AOO_CODIGO})  
				aEntAOR   :={} 
			EndIf
			
			TRB360->( DBSkip() )
			
		EndDo
		
		TRB360->(dbCloseArea())
	
	EndIf	
	
	RestArea(aArea)

EndIf
	
Return( aClone( aMDefEntRel ) )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM710Ench() 

Função efetua a carga do menu Perfil 360

@sample	CRM710Ench()

@return	aEnchEntRel - array com as rotinas e contextos Perfil 360

@author	Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Function CRM710Ench()

Local cCodUser		:= RetCodUsr()
Local cSeek360		:= ""
Local nX			:= 0
Local nPos			:= 0
Local aAux360		:= {}
Local nY			:= 0
Local bFunction		:= {|| }

If ( Select("SX2") > 0 .And.  Select("SIX") > 0  .And. ( Empty( aEnchEntRel ) .Or. cCodUser <> cPCodUser ) )

	//Atualiza as variaveis estatica ( Melhoria de performance )
	aEnchEntRel	:= {}
	cPCodUser	:= cCodUser
	
	AOR->( DBSetOrder(1) )
	AOO->( DBSetOrder(1) )
		
	BeginSQL Alias "TRB360"
		SELECT *
		FROM %table:AOP% AOP	
		INNER JOIN %table:AOQ% AOQ ON AOQ.AOQ_FILIAL = AOP.AOP_FILIAL
							 	  AND AOQ.AOQ_CODPAP = AOP.AOP_CODIGO
							 	  AND AOQ.%NotDel% 		 			 
		INNER JOIN %table:AOS% AOS ON AOS.AOS_FILIAL = AOP.AOP_FILIAL 
							 	  AND AOS.AOS_CODPAP = AOP.AOP_CODIGO 					 
							 	  AND %exp:FixQuery( ExistGroup( UsrRetGrp(Nil,cCodUser) ) )% AND AOS.%NotDel%			 	  		
		Where AOP.%NotDel%
		  And AOP.AOP_FILIAL = %xFilial:AOP% 
		  And AOP.AOP_STATUS = '1'
	EndSQL
	
	// -- Migra os itens de medicoes para a nova revisao
	While !TRB360->(Eof())
		
		
		cSeek360 := xFilial("AOR")+TRB360->AOQ_CODPAP+TRB360->AOQ_CODIGO
		AOR->(DbSeek(xFilial("AOR")+TRB360->AOQ_CODPAP+TRB360->AOQ_CODIGO))
		
		nLinha := aScan(aAux360,{|x| x[1] == TRB360->AOQ_DESCRI })
		
		If nLinha == 0 
			aAdd(aAux360,{TRB360->AOQ_DESCRI,{}})
			nLinha := Len(aAux360)
		EndIf
		
		
		
		While AOR->(!Eof()) .AND. cSeek360 == AOR->AOR_FILIAL+AOR->AOR_CODPAP+AOR->AOR_CODNIV
			If AOR->AOR_STATUS =='1'

				If AOO->(DbSeek(xFilial("AOR")+AOR->AOR_CODROT))
				
					For nX := 1 To Len(aAux360)
						nPos := aScan(aAux360[nX][2],{|x| x[1] == AllTrim("CRMA710('"+AllTrim(AOO->AOO_ROTINA)+"','"+AOO->AOO_ALIAS+"')") })	
						If nPos > 0
							Exit
						EndIf
					Next nX
					If nPos == 0
						aAdd(aAux360[nLinha][2],{"CRMA710('"+AllTrim(AOO->AOO_ROTINA)+"','"+AOO->AOO_ALIAS+"')",AllTrim(AOO->AOO_DESCRI)})
					EndIf
				EndIf		
							
			EndIF

			AOR->(dbSkip())

		EndDo
		
			
		TRB360->(dbSkip())
	EndDo
	
	TRB360->(dbCloseArea())
	
EndIf


For nX := 1 To Len(aAux360)
	aAdd(aEnchEntRel,{/*<Resource (Depreciado)>*/,/*<Action>*/,aAux360[nX][1],aAux360[nX][1],,,{}})
	For nY := 1 To Len(aAux360[nX][2])
		bFunction := &("{|| "+aAux360[nX][2][nY][1]+" }")
		aAdd(aEnchEntRel[nX][7],{/*<Resource (Depreciado)>*/,bFunction,aAux360[nX][2][nY][2],aAux360[nX][2][nY][2]})
	Next nY	
Next nX

Return( aEnchEntRel ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM710Perm() 

Valida se o usuário tem permissão de acessar a rotina

@sample	CRM710Perm()
@Param cFunction
@return	lRet

@author	Renato da Cunha
@since		23/06/2016
@version	12.1.7
/*/
//------------------------------------------------------------------------------

Function CRM710Perm(cFunction)

Local lRet	:= .F.

Default cFunction	:= ""

	If MPUserHasAccess(cFunction, /*nOpc*/ , /*[cCodUser]*/, /*[lShowMsg]*/, /*[lAudit]*/  )
		lRet := .T.
	Else
		Alert(STR0004) //Usuário não autorizado
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ExistGroup() 

Retorna o(s) Grupo(s) no qual o Usuário está associado

@sample	ExistGroup(aUserGrp)
@Param aUserGrp	, Array	, Contem os grupos no qual o usuário tem acesso.
@return	cGrps	,Char	, String contendo os códigos dos grupos separados por virgula 

@author		SQUAD CRM/Faturamento
@since		29/05/2017
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Static Function ExistGroup(aUserGrp) 
Local 	cGrps		:= ""
Local	nX			:= 0
Default aUserGrp	:= {}
If !Empty(aUserGrp)
	For nX :=1 to len(aUserGrp)
		cGrps += "'"+aUserGrp[nX]+"',"
	Next
	cGrps := SubStr(cGrps,1,len(cGrps)-1) 	
EndIf
Return( cGrps )

//------------------------------------------------------------------------------
/*/{Protheus.doc} FixQuery() 

Gera a query de permissão conforme grupo de usuários

@sample	FixQuery( cGroup )
@Param cGrupo, char, String  contendo os grupos de acesso do usuário
@return	lRet

@author		SQUAD CRM/Faturamento
@since		29/05/2017
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Static Function FixQuery( cGroup )

Local cWhere	:= ""
Default	cGroup	:= ""

If !Empty(cGroup)
	cWhere += "%"
	cWhere += "((AOS.AOS_CODIGO =" + "'" + RetCodUsr() +"'" 
	cWhere += " AND AOS.AOS_TIPO  ='2') Or"
	cWhere += " (AOS.AOS_CODIGO IN (" + cGroup + ")" 
	cWhere += " AND AOS.AOS_TIPO ='1'))	"
	cWhere += "%"
Else
	cWhere += "%"
	cWhere += " ((AOS.AOS_CODIGO = "+"'"+RetCodUsr()+"'"
	cWhere += " AND AOS.AOS_TIPO ='2') ) "	
	cWhere += "%"
EndIf

Return( cWhere )
