#INCLUDE "PROTHEUS.CH"  
#INCLUDE "VDFXFUN.CH"
#INCLUDE "AP5MAIL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VDFXFUN  ³ Autor ³ Totvs                              ³ Data ³ 19/11/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcoes genericas a serem utilizadas pelo Modulo SigaVDF e SigaGFP         ³±±
±±³          ³                                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿±±
±±³Programador   ³ Data   ³ PRJ/REQ-Chamado ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcos Pereira³17/12/14³ TRGWMU          ³-Ajuste na fTemFalMes para utilizar o campo ³±±
±±³				 ³        ³                 ³ RC_PERIODO e correção na fTemDevMes que    ³±±
±±³				 ³        ³                 ³ usando a variavel nF no lugar de nD        ³±±
±±³Marcos Pereira³02/02/15³ TRLHU5          ³-Ajuste na funcao PerComis() para considerar³±±
±±³				 ³        ³                 ³ as acoes salariais ocorridas para o cargo  ³±±
±±³				 ³        ³                 ³ efetivo durante periodo de comissionamento ³±±
±±³				 ³        ³                 ³ para gerar corretamente a Dif.CNE na folha ³±±
±±³Joao balbino ³29/04/15³ TSDRAE          ³-Corrigido error log na funçao INIDATPAG     ³±±
±±³Joao balbino ³02/06/15³ TSKZ93          ³-Implementado tratamanento para gerar verba  ³±±
±±³				 ³        ³                 ³ de pensão alim. no calculo das férias      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFCATEG
Busca a categoria vinculada a função/cargo passado como parametro
@sample 	VDFA060(cParametro)
@param		cParametro
@return		Categoria
@author	    Nivia Ferreira
@since		15/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFCATEG(cParametro,cFilFun)
	Local aArea     := GetArea()
	Local oModel    
	Local oModelREY 
	Local cCateg    := '' 
	Local cQuery    := ''

	Default cFilFun	:= ''
	
	If IsInCallStack("VDFA040") .AND. Empty(cParametro)
		oModel    := FWModelActive()
		oModelREY := oModel:GetModel( 'REYDETAIL' )
		If oModelREY:Length() > 0
			cParametro:= oModel:GetValue('REYDETAIL', 'REY_CODFUN')
			cFilFun := oModel:GetValue('REYDETAIL', 'REY_FILFUN')
		EndIf	
	ElseIf IsInCallStack("VDFM010")
		cParametro:= ''
		cCateg := 'E'
		cFilFun := xFilial('SQ3')
	ElseIf IsInCallStack("VDFA060")
		cFilFun := REY->REY_FILFUN
	Else
		cFilFun := xFilial('SQ3')
	EndIf
	
	If !Empty(cParametro)
		cQuery  += "SELECT SQ3.Q3_CATEG "
		cQuery  += " FROM " + RetSqlName( 'SRJ' ) + " SRJ, " + RetSqlName( 'SQ3' ) + " SQ3 "
		cQuery  += " WHERE SRJ.D_E_L_E_T_ =' ' "
		cQuery  += " AND SQ3.D_E_L_E_T_ =' ' "
		cQuery  += " AND SQ3.Q3_FILIAL ='" +FwxFilial('SQ3',cFilFun)+"'"
		cQuery  += " AND SRJ.RJ_FILIAL ='" +FwxFilial('SRJ',cFilFun)+"'"
		cQuery  += " AND SRJ.RJ_CARGO  = SQ3.Q3_CARGO"
		cQuery  += " AND SRJ.RJ_FUNCAO ='" +cParametro+"'"
		
		If Select("TRB") > 0
			TRB->(DbCloseArea())
		EndIf
		dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
		dbSelectArea("TRB")
		If TRB->(!EOF())
			cCateg := TRB->Q3_CATEG
		Endif

		TRB->( dbCloseArea() )
	EndIf
	RestArea( aArea )
	
Return (cCateg)


//------------------------------------------------------------------------------
/*/{Protheus.doc} fVDFCateg()
Selecionar a Categoria do Func. com Base no SX5
@return		C
@author	    Everson S P Junior
@since		03/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function fVDFCateg(l1Elem,lTipoRet)
	Local cTitulo		:=""
	Local MvPar
	Local MvParDef		:=""	
	Local nTam   
	Private aCat:={}
	
	Default lTipoRet 	:= .T.
	Default nTam    	:= 30
	
	l1Elem := If (l1Elem = Nil , .F. , .T.)
	
	cAlias := Alias() 					 // Salva Alias Anterior
	
	IF lTipoRet
		MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
		mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
		nTam := Len(&(mvRet)) 
		cCpoRet	:= ReadVar()			//Armazena o campo do retorno, para ser utilizado no XB_TIPO = 5
	EndIF
	
	dbSelectArea("SX5")
	
	If dbSeek(cFilial+"0028")
	   cTitulo := Alltrim(Left(X5Descri(),20))
	Endif
	
	If dbSeek(cFilial+"28")
		CursorWait()
			While !Eof() .AND. SX5->X5_Tabela == "28"
				Aadd(aCat,Left(SX5->X5_Chave,1) + " - " + Alltrim(X5Descri()))
				MvParDef+=Left(SX5->X5_Chave,1)
				dbSkip()
			Enddo
		CursorArrow()
	Endif
	
	IF lTipoRet
		IF f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,l1Elem)  // Chama funcao f_Opcoes
			&MvRet := Padr(mvpar,nTam)   						 // Devolve Resultado
		EndIF
	EndIF
	
	dbSelectArea(cAlias) 								 // Retorna Alias	
Return( IF( lTipoRet , .T. , MvParDef ) )


//------------------------------------------------------------------------------
/*/{Protheus.doc}  FProxDoc
seleciona a sequencia das tabelas
@return		lRet
@author	    Everson S P Junior			       
@since		27/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function FProxDoc(cFil,cAlias,cPD,cMat)
	Local cSeq		:= ""
	Local cQryTmp	:= ""
	
	Default cFil  := FwxFilial('SRK') 
	
	If cAlias == 'SRK'
		cQryTmp += "SELECT MAX(RK_DOCUMEN) DOCUMEN " 
		cQryTmp += "FROM "+ RetSqlName("SRK") + " SRK "	
		cQryTmp += " WHERE  "
		cQryTmp += " SRK.RK_FILIAL  ='"+cFil+"' AND " 
		cQryTmp += " SRK.RK_MAT  ='"+cMat+"' AND "
		cQryTmp += " SRK.RK_PD  ='"+cPD+"' AND "  
		cQryTmp += " SRK.D_E_L_E_T_ =' ' "
		
		If Select("TRBSRK") > 0
			TRBSRK->(DbCloseArea())
		EndIf
		dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'TRBSRK', .F., .T. )
		cSeq:= TRBSRK->DOCUMEN
		TRBSRK->(dbCloseArea())	
	ElseIf cAlias == 'SR8'
		cQryTmp += "SELECT MAX(R8_SEQ) SEQ " 
		cQryTmp += "FROM "+ RetSqlName("SR8") + " SR8 "
		cQryTmp += " WHERE  "
		cQryTmp += " SR8.R8_FILIAL  ='"+cFil+"' AND " 
		cQryTmp += " SR8.R8_MAT  ='"+cMat+"' AND "
		cQryTmp += " SR8.D_E_L_E_T_ =' ' "
		
		If Select("TRBSR8") > 0
			TRBSR8->(DbCloseArea())
		EndIf
		dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'TRBSR8', .F., .T. )
		cSeq:= TRBSR8->SEQ
		TRBSR8->(dbCloseArea())
	EndIf
Return cSeq


//------------------------------------------------------------------------------
/*/{Protheus.doc} fVerRI8()
FUNCAO QUE VERIFICA AS SUBSTITUICOES PREVISTAS CONFORME A FILIAL / MATRICULA PASSADA NO PARAMETRO
         entre os dias 21/10/2013 a 06/11/2013
  	fVerRI8("D MG 02 ","000003",stod("20131021"),stod("20131106"),.F.,.T.,.F.,.F.,.T.)
		Se encontrar dados, armazena no aRet os valores.
							[1]- cFil 		= Filial
						  	[2]- cMat 		= Matricula
						  	[3]- dDataAte 	= Data inicial
						  	[4]- dDataDe 	= Data final
						  	[5]- lSR8  		= Indica se deseja também verificar os Afastamentos - SR8
						  	[6]- lMsg 		= Indica se deseja exibir uma Mensagem com as informações
						  	[7]- lBlq		= Indica se deseja bloquear a continuação ou perguntar se continua (Sim/Não)
						  	[8]- rRet		= Retorna o Array .T. ou a Validação .F.
						  	[9]- lBlqSR8 	= Quando utilizar a SR8 - Indica se deseja bloquear a continuação ou perguntar se continua (Sim/Não)
						  	[10]-lSub	  	= Indica se quem deverá ser analisado é o SUBSTITUIDO
						  	[11]-nRecRI8 	= Indica o recno que deseja desconsiderar na filtragem da RI8
						  	[12]-nRecSR8	= Indica o recno que deseja desconsiderar na filtragem da SR8
						  	[13]-nTipoMsg	= Tipo da msg de help 1=MsgBox 2=Help

@return	.T. ou .F. ou array
@return		cRetorno
@author	    Fabricio Amaro
@since		03/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function fVerRI8( cFil , cMat , dDataDe, dDataAte , lSR8 , lMsg , lBlq , rRet , lBlqSR8,lSub,nRecRI8,nRecSR8,nTipoMsg)

	Local aArea     := GetArea()
	Local aAreaSRA  := SRA->(GetArea())
	Local cFuncs := ""
	Local i := 0
	Local lRetSr8 := .T.
	Local cRetorno := .T.
	
	Private aRet := {}
	
	DEFAULT dDataDe		:= STOD("")
	DEFAULT dDataAte	:= STOD("")
	Default lSub		:= .F.
	Default nRecRI8		:= 0
	Default nRecSR8		:= 0
	Default nTipoMsg	:= 1

	//ARMAZENA O SUBSTITUTO OU SUBSTITUIDO INFORMADO
	cFuncSub := (Posicione("SRA",1,cFil + cMat,"RA_NOME"))
	
	cQryTmp := " SELECT * FROM " + RETSQLNAME("RI8") + " WHERE "
	If lSub
		cQryTmp += " RI8_FILIAL = '"+cFil+"' AND RI8_MAT = '"+cMat+"' "
	Else
		cQryTmp += " RI8_FILSUB = '"+cFil+"' AND RI8_MATSUB = '"+cMat+"' "
	EndIf
	
	If Empty(dDataDe)	//SE AS DATAS FOREM VAZIAS, ANALISA DA DATA BASE PRA FRENTE
		dDataDe  := dDataBase
	EndIf

	If Empty(dDataAte)
		dDataAte := STOD("99991231")
	EndIf

	cQryTmp += " AND ( ( ( RI8_DATADE >= '"+DTOS(dDataDe)+"' AND RI8_DATADE <= '"+DTOS(dDataAte)+"' ) OR ('"+DTOS(dDataDe)+"' >= RI8_DATADE AND '"+DTOS(dDataAte)+"' <= RI8_DATATE) )"
	cQryTmp += "    OR ( ( RI8_DATATE >= '"+DTOS(dDataDe)+"' AND RI8_DATATE <= '"+DTOS(dDataAte)+"' ) OR ('"+DTOS(dDataDe)+"' >= RI8_DATADE AND '"+DTOS(dDataAte)+"' <= RI8_DATATE) ) ) "
	cQryTmp += " AND R_E_C_N_O_ <> " + cValToChar(nRecRI8)
	cQryTmp += " AND D_E_L_E_T_ = ' ' "
	
	//EXECUTA A SELEÇÃO DE DADOS 		
	cQryTmp := ChangeQuery(cQryTmp)
	If Select("XRI8") > 0
		XRI8->(DbCloseArea())
	EndIf
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'XRI8', .F., .T. )
	If !XRI8->(Eof())
		While !XRI8->(Eof())
			cFunc 	 := (Posicione("SRA",1,XRI8->RI8_FILIAL + XRI8->RI8_MAT ,"RA_NOME"))
			aAdd(aRet,{XRI8->RI8_FILIAL,XRI8->RI8_MAT,cFunc,stod(XRI8->RI8_DATADE),stod(XRI8->RI8_DATATE),"RI8",XRI8->RI8_FILSUB,XRI8->RI8_MATSUB,cFuncSub}) 
		 	XRI8->(DbSkip())
		EndDo	
	EndIf	

	If lSR8
		lRetSr8 := fVerSR8(cFil , cMat , dDataDe , dDataAte , lMsg , lBlqSR8, , , , , ,nRecSR8, ,nTipoMsg)
	EndIf
	
	If lMsg .AND. !Empty(aRet) .AND. lRetSR8
	
		For i:=1 to Len(aRet)
			If aRet[i][6] == "RI8"
				cFuncs +=  aRet[i][1] + "/" + aRet[i][2] + "-" + aRet[i][3] + STR0017 + dtoc(aRet[i][4]) + " a " + dtoc(aRet[i][5]) + chr(13) + chr(10) //" - Per.:"
			EndIf      
		Next i				    	

		cMsg := STR0013 +chr(13)+chr(10)+chr(13)+chr(10)+; //"Atenção!"
				cFil+"/"+cMat+" - "+cFuncSub +chr(13)+chr(10)+chr(13)+chr(10)+;
			  	STR0018 + ; //"O substituto/substituído acima informado já possui SUBSTITUIÇÕES para o período de "
			  	dtoc(dDataDe) + STR0016 + dtoc(dDataAte) + chr(13) + chr(10) + chr(13) + chr(10) +; //" a "
			  	cFuncs
		If lBlq
			Help(,,STR0013,, cMsg,1,0 ) //"Atenção"
			cRetorno := .F.
		Else
			If (MsgYesNo(cMsg+chr(13)+chr(10)+chr(13)+chr(10)+ STR0015,STR0013))  // "Deseja Prosseguir?", "Atenção"
				cRetorno := .T.   
			Else
				cRetorno := .F.
			EndIf
		EndIf
	EndIf
	If !lRetSR8
		cRetorno := .F.
	EndIf
	
	If rRet 
		If lRetSR8
			cRetorno := aRet
		Else
			cRetorno := {}
		EndIf
	EndIf

	If Select("XRI8") > 0
		XRI8->(DbCloseArea())
	EndIf

	RestArea(aAreaSRA)
	RestArea( aArea )
Return cRetorno


//------------------------------------------------------------------------------
/*/{Protheus.doc} fVerSR8()
Busca afastamentos na tabela SR8
							[1]- cFil 		= Filial
						  	[2]- cMat 		= Matricula
						  	[3]- dDataAte 	= Data inicial
						  	[4]- dDataDe 	= Data final
						  	[5]- lMsg 		= Indica se deseja exibir uma Mensagem com as informações
						  	[6]- lBlq		= Indica se deseja bloquear a continuação ou perguntar se continua (Sim/Não)
						  	[7]- rRet		= Retorna o Array .T. ou a Validação .F.
						  	[8]- aRet		= Array no qual devera ser acrescentado o retornoCodigos dos Tipos de Afastamentos a serem filtrados
						  	[9]- cCodAf		= Codigos dos Tipos de Afastamentos a serem filtrados
						  	[10]-cSeparador = Separador dos cCodAf
						  	[11]-lRetSR8 	= Retorna o Array aRetSR8
						  	[12]-nRecSR8 	= Indica o recno que deseja desconsiderar na filtragem da SR8
						  	[13]-cCaract 	= Caracteristica da Ausencia na RCM_CARACT
						  	[14]-nTipoMsg 	= Tipo da msg de help 1=MsgBox 2=Help

@return	.T. ou .F. ou array
@return		cRetorno
@author	    Fabricio Amaro
@since		03/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function fVerSR8( cFil , cMat , dDataDe, dDataAte , lMsg , lBlq , rRet , aRet , cCodAf , cSeparador, lRetSR8 , nRecSR8, cCaract, nTipoMsg)

	Local aArea     := GetArea()
	Local aAreaSRA  := SRA->(GetArea())
	Local cAfast := ""
	Local i := 0
	Local cRetorno := .T.
	
	Private aRetSR8 := {}
	
	DEFAULT dDataDe		:= STOD("")
	DEFAULT dDataAte	:= STOD("")
	DEFAULT aRet		:= {}
	DEFAULT cCodAf		:= ""
	DEFAULT lRetSR8		:= .F.
	Default nRecSR8		:= 0
	Default cCaract     := ""
	Default nTipoMsg    := 1 
	
	//ARMAZENA O SUBSTITUTO OU SUBSTITUIDO INFORMADO
	cFuncSub := (Posicione("SRA",1,cFil + cMat,"RA_NOME"))
	
	cQryTmp := " SELECT R8_TIPOAFA, RCM_DESCRI, R8_DATAINI, R8_DATAFIM, R8_DURACAO, R8_DIASEMP FROM " + RETSQLNAME("SR8") + " SR8 "
	cQryTmp += " INNER JOIN " + RETSQLNAME("RCM") + " RCM ON "
	cQryTmp += FwJoinFilial("RCM","SR8") +  " AND "
	cQryTmp += " RCM.RCM_TIPO = R8_TIPOAFA AND RCM.D_E_L_E_T_ = ' ' "
	If !Empty(cCaract)
		cQryTmp	+= " AND RCM.RCM_CARACT = '" + cCaract + "' "
	EndIf
	cQryTmp += " WHERE "
	cQryTmp += " R8_FILIAL = '"+cFil+"' AND R8_MAT = '"+cMat+"' "
	If Empty(dDataDe) .AND. Empty(dDataAte)		//SE AS DATAS FOREM VAZIAS, ANALISA DA DATA BASE PRA FRENTE
		dDataDe  := dDataBase
		dDataAte := STOD("99993112")
	EndIf
	
	cQryTmp += " AND (((( R8_DATAINI >= '"+DTOS(dDataDe)+"' AND R8_DATAINI <= '"+DTOS(dDataAte)+"') OR "
	cQryTmp += "     ('"+DTOS(dDataDe)+"' >= R8_DATAINI AND ('"+DTOS(dDataAte)+"' <= R8_DATAFIM OR R8_DATAFIM='        ')))) "
	cQryTmp += " OR "
	cQryTmp += "     ((( R8_DATAFIM >= '"+DTOS(dDataDe)+"' AND (R8_DATAFIM <= '"+DTOS(dDataAte)+"' OR R8_DATAFIM='        ')) OR "
	cQryTmp += "     ('"+DTOS(dDataDe)+"' >= R8_DATAINI AND '"+DTOS(dDataAte)+"' <= R8_DATAFIM )))) "
	
	//CASO SEJA PASSADO OS CODIGOS DOS TIPOS DE AFASTAMENTOS
	If !(Empty(cCodAf))
		If Right(alltrim(cCodAf),1) == cSeparador //RETIRA O ULTIMO SEPARADOR
			cCodAf := SubStr(cCodAf,1,len(alltrim(cCodAf)) - 1)
		EndIf
		cQryTmp += " AND R8_TIPOAFA IN ('" + StrTran(cCodAf,"/","','") + "') " //FILTRA OS TIPOS DE AFASTAMENTOS
	EndIf
	cQryTmp += " AND SR8.R_E_C_N_O_ <> " + cValToChar(nRecSR8)
	cQryTmp += " AND SR8.D_E_L_E_T_ = ' ' "
	
	//EXECUTA A SELEÇÃO DE DADOS 		
	cQryTmp := ChangeQuery(cQryTmp)
	If Select("XSR8") > 0
		XSR8->(DbCloseArea())
	EndIf
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'XSR8', .F., .T. )
	If !XSR8->(Eof())
		cRetorno := .F.
		While !XSR8->(Eof())
			//cDesc := Posicione("RCM",1,xFilial("RCM")+XSR8->R8_TIPOAFA,"RCM_DESCRI")
			aAdd(aRetSR8,{XSR8->R8_TIPOAFA,;   		//1 - CODIGO DO TIPO DO AFASTAMENTO
						  XSR8->RCM_DESCRI,;   		//2 - DESCRIÇÃO DO AFASTAMENTO
						  stod(XSR8->R8_DATAINI),;	//3 - DATA INICIAL
						  stod(XSR8->R8_DATAFIM),;	//4 - DATA FINAL
						  XSR8->R8_DURACAO,;		//5 - DURAÇÃO
						  XSR8->R8_DIASEMP}) 		//6 - DIAS A PAGAR PARTE EMPRESA
			
			aAdd(aRet   ,{XSR8->R8_TIPOAFA,XSR8->RCM_DESCRI,"",stod(XSR8->R8_DATAINI),stod(XSR8->R8_DATAFIM),"SR8","","",""})
		 	
		 	XSR8->(DbSkip())
		EndDo	
	EndIf	

	If lMsg .AND. !Empty(aRetSR8)
	
		For i:=1 to Len(aRetSR8)
			cAfast +=  aRetSR8[i][1] + "-" + alltrim(aRetSR8[i][2]) + STR0017 + dtoc(aRetSR8[i][3]) + " a " + dtoc(aRetSR8[i][4]) + chr(13) + chr(10) //" - Per.:"
		Next i				    	

		cMsg := STR0013 +chr(13)+chr(10)+chr(13)+chr(10)+; //"Atenção!"
				cFil+"/"+cMat+" - "+cFuncSub +chr(13)+chr(10)+chr(13)+chr(10)+;
			  	STR0014 + ; //"O substituto/substituído acima informado possui AFASTAMENTOS para o período de "
			  	dtoc(dDataDe) + STR0016 + dtoc(dDataAte) + chr(13) + chr(10) + chr(13) + chr(10) +;  //
			  	cAfast
		If lBlq
			Help(,,STR0013,, cMsg,1,0 ) //"Atenção"			
			cRetorno := .F. 
		Else
			If MSGYESNO(cMsg+chr(13)+chr(10)+chr(13)+chr(10)+ STR0015,STR0013)  //"Deseja Prosseguir?","Atenção"
				cRetorno := .T.
			Else
				cRetorno := .F.
			EndIf
		EndIf
	EndIf
	
	If rRet
		cRetorno := aRet
	EndIf
	If lRetSR8
		cRetorno := aRetSR8
	EndIf
	If Select("XSR8") > 0
		XSR8->(DbCloseArea())
	EndIf
	RestArea(aAreaSRA)
	RestArea( aArea )
Return cRetorno


//------------------------------------------------------------------------------
/*/{Protheus.doc} TabSalIni()
BUSCA A TABELA DO INICIO DA CARREIRA
lTabIni = Indica se irá analisar a tabela amarrada
@return		nValor
@author	    Fabricio Amaro
@since		07/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function TabSalIni(cTabela,dData,lTabIni,cNivel,cFaixa)
	Local aArea      := GetArea()
	Local nValor     := 0
	LOCAL CALIASXRBR := "XRBR"
	Local cFUNCARG   := SuperGetMV("MV_FUNCARG",,.F.)

	Default lTabIni := .T.
	Default cNivel  := ""
	Default cFaixa  := ""

	IF cFUNCARG == "C"
		If Empty(dData)
			dData := dDataBase
		EndIf
		
		cQryTmp := " SELECT * FROM " + RETSQLNAME("RBR")
		cQryTmp += " WHERE RBR_TABELA = '"+cTabela+"' "
		cQryTmp += " AND RBR_FILIAL = '"+ FwxFilial('RBR')+"' "
		cQryTmp += " AND RBR_DTREF <= '"+ dtos(dData)+"' "
		cQryTmp += " AND D_E_L_E_T_ = ' ' "
		cQryTmp += " ORDER BY RBR_DTREF DESC "

		//EXECUTA A SELEÇÃO DE DADOS 		
		cQryTmp := ChangeQuery(cQryTmp)
		
		If Select(CALIASXRBR) > 0
			(CALIASXRBR)->(DbCloseArea())
		EndIf
		
		dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), CALIASXRBR )
		
		If !(CALIASXRBR)->(Eof())
			cTab    := XRBR->RBR_TABELA
			dDtRef  := XRBR->RBR_DTREF
			cTabIni := XRBR->RBR_TABINI
			
			If !(EMPTY(XRBR->RBR_TABINI)) .AND. lTabIni //CASO A TABELA INICIAL SEJA OUTRA, TEM QUE ANALISAR ELA
				XRBR->(DbCloseArea())
				nValor := TabSalIni(cTabIni,dData)
				Return nValor
			EndIf

			//AGORA VERIFICA O VALOR DA PRIMEIRA FAIXA
			cQryTmp := " SELECT * FROM " + RETSQLNAME("RB6")
			cQryTmp += " WHERE RB6_TABELA = '"+cTab+"' AND RB6_DTREF = '"+dDtRef+"' "
			
			//CASO SEJA PASSADO COMO PARAMETRO O NIVEL E FAIXA, DEVE FILTRAR
			If !Empty(cNivel) .AND. !Empty(cFaixa)
				cQryTmp += " AND RB6_NIVEL = '"+cNivel+"' AND RB6_FAIXA = '"+cFaixa+"' "
			EndIf
			
			cQryTmp += " AND D_E_L_E_T_ = ' ' ORDER BY RB6_NIVEL , RB6_FAIXA "
		
			//EXECUTA A SELEÇÃO DE DADOS 		
			cQryTmp := ChangeQuery(cQryTmp)
			
			If Select("XRB6") > 0
				XRB6->(DbCloseArea())
			EndIf
			
			dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'XRB6', .F., .T. )
			
			nValor := XRB6->RB6_VALOR
			XRB6->(DbCloseArea())
		EndIf

		XRBR->(DbCloseArea())
	ELSE
		nValor := M->RA_SALARIO
	ENDIF

	RestArea( aArea )
Return nValor 


//------------------------------------------------------------------------------
/*/{Protheus.doc} fBuscaTab()
FUNÇÃO QUE BUSCA O HISTÓRICO DA SR3 DO FUNCIONÁRIO COM BASE NA DATA PASSADA COMO PARAMETRO
ENTENDE-SE QUE O FUNCIONÁRIO JÁ ESTEJA POSICIONADO
@return		C
@author	    Fabricio Amaro
@since		07/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function fBuscaTab(dDataDe,cTabela, cNivel, cFaixa, cTabCom , cNivelCom , cFaixaCom , lDataRef, nSalEfe, nSalCom )
	Local aArea     := GetArea()
	Local aRecno	:= {}
	Local nPos 		:= 0 
	
	DEFAULT lDataRef 	:= .T.   
	DEFAULT nSalEfe 	:= 0
	DEFAULT nSalCom		:= 0

	If SR3->( dbSeek( SRA->(RA_FILIAL + RA_MAT) )  )
		While SR3->(!EOF()) .AND. If(lDataRef,(MesAno(SR3->R3_DATA) <= MesAno(dDataDe)),(SR3->R3_DATA <= dDataDe)).AND.;
						SR3->R3_FILIAL 	== SRA->RA_FILIAL .AND. ;
						SR3->R3_MAT   	== SRA->RA_MAT

			AADD(aRecno, {DTOS(SR3->R3_DATA),;
						 strzero(SR3->(Recno()),10) ,;
						 SR3->R3_TABELA,;
						 SR3->R3_TABNIVE,;
						 SR3->R3_TABFAIX,;
						 SR3->R3_CTABELA,;
						 SR3->R3_CTABNIV,;
						 SR3->R3_CTABFAI,;
						 SR3->R3_VALOR,;
						 SR3->R3_CSALAR,;
						 })

			SR3->(dbSkip())
		EndDo 
		If Len(aRecno) > 0 
			aSort( aRecno,,,{ |x,y| x[1] + x[2] < y[1] + y[2]  } )  //REORDENA O ARRAY DE FORMA DECRESCENTE 
			nPos 		:=  Len( aRecno ) 
			dData		:= 	aRecno[nPos,1]
			cTabela 	:=	aRecno[nPos,3]
			cNivel	 	:= 	aRecno[nPos,4]
			cFaixa		:= 	aRecno[nPos,5]
			cTabCom 	:=	aRecno[nPos,6]
			cNivelCom 	:= 	aRecno[nPos,7]
			cFaixaCom	:= 	aRecno[nPos,8]
			nSalEfe		:= 	aRecno[nPos,9]
			nSalCom		:= 	aRecno[nPos,10]
		Endif
	Endif
	
	//-- Se nao encontrou as informações na data solicitada, assume a do Cadastro de Funcionarios
	If  Empty( Len(aRecno) )
		dData		:=  dDataDe
		cTabela 	:=	SRA->RA_TABELA
		cNivel	 	:= 	SRA->RA_TABNIVE
		cFaixa		:= 	SRA->RA_TABFAIX
		cTabCom 	:=	""
		cNivelCom 	:= 	""
		cFaixaCom	:= 	""
		nSalEfe	    :=  if(SRA->RA_SUBCARR>0,SRA->RA_SUBCARR,SRA->RA_SALARIO)
		nSalCom		:=  0
	Endif
	RestArea( aArea )
Return 


//------------------------------------------------------------------------------
/*/{Protheus.doc} fOpcSx2()
Montar uma tela do tipo f_Opcao, com base na tabela e campos passados nos parametros
@return		C
@author	    Fabricio Amaro
@since		25/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function fOpcSX2(cTabela,cCampo1,cCampo2,cSeparador,l1Elem,lTipoRet,lFiltraFil,cCpoFil,cVlrFil )

	Local cFilDef	:= xFilial(cTabela)   
	Local cPrefixo	:= ( PrefixoCpo( cTabela ) + "_" )
	Local cConcat	:= ""
	Local MvParDef	:= ""	
	Local MvPar
	Local mvRet
	Local aCat:={}

	
	Default lTipoRet 	:= .T.
	Default cSeparador	:= "/"     
	Default lFiltraFil  := .F. 
	Default cCpoFil		:= ""
	Default cVlrFil		:= ""
	
	cCpoRet := ""  //CAMPO UTILIZADO PARA O RETORNO QUANDO XB_TIPO = 5 E XB_CONTEM = &cCpoRet
	
	l1Elem := If (l1Elem = Nil , .F. , .T.)  //Por padrão, o elemento do retorno deve ser logico

	nTamRet := TamSX3(cCampo1)[1] + 1	//PEGA O TAMANHO DO CAMPO, E INCREMENTA 1 PARA UTILIZAR PARA O SEPARADOR
	
	ccampo1 := ctabela +"->"+ccampo1	//O campo 1 será o principal, utilizado no retorno. Normalmente é o código.
	ccampo2 := ctabela +"->"+ccampo2 	//O campo 2 servirá apenas para demonstração, normalmente é uma descrição

	If !Empty(cCpoFil)
		cCpoFil := ctabela +"->"+cCpoFil	//O Campo Filial da coluna inicial para filtro dos registros a serem apresentados
	EndIf
	
	If !Empty(cVlrFil)
		cVlrFil:= aCols[n][GdFieldPos("RCC_FIL ")] 
		If Empty(cVlrFil)

			AVISO("Atenção",OemToAnsi("Preencha o campo filial antes de manipular este campo "+CRLF+"ou mantenha este campo vazio!"),{"Ok"} )
			Return .T.
		EndIf
		cFilDef:= Iif(!Empty(cVlrFil),xFilial(cTabela,cVlrFil),cFilDef)
		lFiltraFil:= Iif(Empty(cVlrFil),lFiltraFil,.T. )
	EndIf
	cTitulo := ALLTRIM(FWX2Nome(cTabela))  //PEGA A DESCRICAO DA TABELA
	
	cAlias := Alias() 					 // Salva Alias Anterior
	
	IF lTipoRet
		MvPar 	:= &(Alltrim(ReadVar()))	// Carrega Nome da Variavel do Get em Questao
		mvRet 	:= Alltrim(ReadVar())		// Iguala Nome da Variavel ao Nome variavel de Retorno
		nTam  	:= Len(&(mvRet))
		cCpoRet	:= ReadVar()			//Armazena o campo do retorno, para ser utilizado no XB_TIPO = 5
	EndIF
	
	nMaxElem := Int(nTam / nTamRet)		//Calcula quantos elementos podem ser selecionados, devido ao tamanho do campo

	dbSelectArea(cTabela)
	dbSetOrder(1)
	dbGoTop()
	CursorWait()  
	If lFiltraFil
	   If (cTabela)->(DbSeek(cFilDef))	
			While  ! (cTabela)->(Eof()) .And. ( cFilDef == (cTabela)->(&(cPrefixo+"FILIAL")) )
				cConcat:= ""				
				If !Empty(cCpoFil)
					cConcat:= 	Alltrim(&cCpoFil) + " - " 
				EndIf
				cConcat:= cConcat +ALLTRIM(&cCampo1)+ " - " + Alltrim(&cCampo2)
				Aadd(aCat,cConcat)
				MvParDef+= &cCampo1
				dbSkip()
				If !Eof()
					MvParDef+= cSeparador  //INCREMENTA O SEPARADOR DOS CÓDIGOS
				EndIf
			Enddo
       Endif
    Else
		While !Eof()
			cConcat:= ""
			If !Empty(cCpoFil)
				cConcat:= 	Alltrim(&cCpoFil) + " - " 
			EndIf
			cConcat:= cConcat+ALLTRIM(&cCampo1)+ " - " + Alltrim(&cCampo2)
			Aadd(aCat,cConcat)
			MvParDef+= &cCampo1
			dbSkip()
			If !Eof()
				MvParDef+= cSeparador  //INCREMENTA O SEPARADOR DOS CÓDIGOS
			EndIf
		Enddo
	Endif
	CursorArrow()
	
	IF lTipoRet
		IF f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,l1Elem,nTamRet,nMaxElem)  // Chama funcao f_Opcoes
			@mvpar := strtran(@mvpar,"*","")	//RETIRA OS ASTERISCOS DAS OPCOES QUE NÃO FORAM SELECIONADAS
			&MvRet := Padr(mvpar,nTam)			// Devolve Resultado
		EndIF
	EndIF
	
	dbSelectArea(cAlias) // Retorna Alias         	
	
Return( IF( lTipoRet , .T. , MvParDef ) )


//------------------------------------------------------------------------------
/*/{Protheus.doc} fMeses()
Montar uma tela do tipo f_Opcao com os meses de Janeiro a Dezembro
@return		C
@author	    Fabricio Amaro
@since		25/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function fMeses(l1Elem,lTipoRet)
	Local cTitulo	:= ""
	
	Local nTam
	Local i   
	Private aCat:={}
	Private MvParDef		:=""	
	Private MvPar
	
	Default lTipoRet 	:= .T.
	Default nTam    	:= 30
	
	l1Elem := If (l1Elem = Nil , .F. , .T.)


	cAlias := Alias() 					 // Salva Alias Anterior
	
	IF lTipoRet
		MvPar := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
		mvRet := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
		nTam  := Len(&(mvRet)) 
		cCpoRet	:= ReadVar()			//Armazena o campo do retorno, para ser utilizado no XB_TIPO = 5
	EndIF
	
	cTitulo := 'Meses'
	
	For i := 1 To 12
		Aadd(aCat,Left(StrZero(i,2),2) + ' - ' + mesextenso(i))
		MvParDef+= Left(StrZero(i,2),2) + '/'
	Next
	
	IF lTipoRet
		IF f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,l1Elem,3,12)  // Chama funcao f_Opcoes
			@mvpar := strtran(@mvpar,"*","")  //RETIRA OS ASTERISCOS DAS OPCOES QUE NÃO FORAM SELECIONADAS
			&MvRet := Padr(mvpar,nTam)   						 // Devolve Resultado
		EndIF
	EndIF
	
	dbSelectArea(cAlias) 								 // Retorna Alias
	
Return( IF( lTipoRet , .T. , MvParDef ) )


//------------------------------------------------------------------------------
/*/{Protheus.doc} fOpcTabS()
Montar uma tela do tipo f_Opcao, com base na tabela e campos passados nos parametros
@return		C
@author	    Everson S P Junior
@since		10/12/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function fOpcTabS(cTabela,nPosCamp1,nPosCamp2,cSeparador,l1Elem,lTipoRet,nPosFil,cContFilt )

	Local aTable  := {}
	Local cTitulo := OemToAnsi(STR0025)	//"Lista de Opções"
	Local nX		:= 1
	
	Private aCat:={}
	Private MvParDef	:= ""	
	Private MvPar
	Private mvRet
	
	Default lTipoRet 	:= .T.
	Default cSeparador	:= "/"
	
	If ValType("cCpoRet") $ "U*C"
		PUBLIC cCpoRet := ""
	EndIf
	
	cCpoRet := ""  //CAMPO UTILIZADO PARA O RETORNO QUANDO XB_TIPO = 5 E XB_CONTEM = &cCpoRet
	
	fCarrTab( @aTable, cTabela )
	
	If !Empty(@aTable)	
		nTamRet := Len(aTable[nX][nPosCamp1]) + 1
		IF lTipoRet
			MvPar 	:= &(Alltrim(ReadVar()))	// Carrega Nome da Variavel do Get em Questao
			mvRet 	:= Alltrim(ReadVar())		// Iguala Nome da Variavel ao Nome variavel de Retorno
			nTam  	:= Len(&(mvRet))
			cCpoRet	:= ReadVar()			//Armazena o campo do retorno, para ser utilizado no XB_TIPO = 5
		EndIF
		
		For nX := 1 to Len(aTable)
			If cContFilt $ aTable[nX][nPosFil] // nPosFil posição do filtro na tabela S 	
				Aadd(aCat,Alltrim(aTable[nX][nPosCamp1]) + " - " + Alltrim(aTable[nX][nPosCamp2]))
				MvParDef+= aTable[nX][nPosCamp1]
				dbSkip()
				If nX <= Len(aTable) 
					MvParDef+= cSeparador  //INCREMENTA O SEPARADOR DOS CÓDIGOS
				EndIf
			EndIf
		Next
		
		IF lTipoRet
			IF f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,l1Elem,nTamRet,/*nMaxElem*/)  // Chama funcao f_Opcoes
				@mvpar := strtran(@mvpar,"*","")	//RETIRA OS ASTERISCOS DAS OPCOES QUE NÃO FORAM SELECIONADAS
				&MvRet := Padr(mvpar,nTam)			// Devolve Resultado
			EndIF
		EndIF
	Else
		Help(,,STR0013,, STR0038 + cTabela ,1,0 ) //"Atenção" ""Não há nenhum registro cadastrado na tabela "
	EndIf
	
Return( IF( lTipoRet , .T. , MvParDef ) )


//------------------------------------------------------------------------------
/*/{Protheus.doc} FRIARET()
Funcao que retorna os Dias de Gozo e Dias de Direito
@return		nDiasGoz , nDiasAbo
@author	    Fabricio Amaro
@since		14/01/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function FRIARET(cVerba, dIni, dFim)
	Local aArea     := GetArea()
	Local cQuery	:= ""
	Local aRet 		:= {}
	Local cDtBaseAnt:= ""
	
	Default dIni		:= dDataDe  // DA INICIAL DO PERIODO, CARREGADO PELA FORMULA CARGARCH
	Default dFim  		:= dDataAte // DA FINAL   DO PERIODO, CARREGADO PELA FORMULA CARGARCH

	cQuery := " SELECT * FROM " + RETSQLNAME("RIA") + " RIA "
	cQuery += " INNER JOIN " + RETSQLNAME("SRF") + " SRF "
	cQuery += " 	ON RF_FILIAL  = RIA_FILIAL  AND  RF_MAT = RIA_MAT AND " 
	cQuery += " 	   RF_DATABAS = RIA_DTINPA  AND  RF_PD  = RIA_PD  AND  SRF.D_E_L_E_T_  =  ' ' "
	cQuery += " WHERE RIA_FILIAL  =  '"+ SRA->RA_FILIAL +"'  "
	cQuery += " AND   RIA_MAT     =  '"+ SRA->RA_MAT    +"'  "
	cQuery += " AND   RIA_PD  	  =  '"+ cVerba + "' "
	cQuery += " AND   RIA_STATUS IN ('0','2') " //0=PROGRAMADO 2=SUSPENSO 4=QUITADO (MESMO SUSPENSO TEM QUE PAGAR OS DIAS DE DIREITO SE TIVER)
	cQuery += " AND ( ( RIA_DATPAG  >= '"+ DTOS(dIni)  	+"' AND "
	cQuery += " 	    RIA_DATPAG  <= '"+ DTOS(dFim)  	+"')    "
	cQuery += "    OR ( RIA_DTPGAD  >= '"+ DTOS(dIni)  	+"' AND "
	cQuery += " 	    RIA_DTPGAD  <= '"+ DTOS(dFim)  	+"') )  "
	cQuery += " AND   RIA.D_E_L_E_T_  =  ' ' "
	cQuery += " ORDER BY RIA_FILIAL,RIA_MAT,RIA_PD,RIA_DTINPA "
	
	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
	dbSelectArea("TRB")
	While !Eof()
		If P_SUMFERAB == "S"	//-Soma linhas diferentes da RIA, porem com Data Base igual
			
			If cDtBaseAnt == TRB->RF_DATABAS
				
				If RIA_DATPAG >= DTOS(dIni) .AND. RIA_DATPAG <= DTOS(dFim)
					aRet[Len(aRet),02] += TRB->RIA_NRDGOZ
				EndIf
				
				If RIA_DTPGAD >= DTOS(dIni) .AND. RIA_DTPGAD <= DTOS(dFim)
					aRet[Len(aRet),04] += TRB->RIA_NRDIND
				EndIf
			
			Else
				lArray := .F.
				If RIA_DATPAG >= DTOS(dIni) .AND. RIA_DATPAG <= DTOS(dFim)
					Aadd(aRet,{	TRB->RIA_DATPAG,;	//-01-Data Pagto Gozo
								TRB->RIA_NRDGOZ,;	//-02-Dias de Gozo
								"",;				//-03-Data Pagto Indeniz
								0,;					//-04-Dias de Indeniz
								TRB->RF_DATAFIM,;	//-05-Data Fim do Periodo
								TRB->RF_DIASDIR,;	//-06-Dias de Direito do Periodo
								TRB->RF_DATABAS,;	//-07-Data Inicio do Periodo
								"",;				//-08-Data para Indenizacao
								0 ,;				//-09-Dias para Indenizacao
								TRB->RIA_DATINI})	//-10-Data Inicio gozo de ferias
					lArray := .T.
				EndIf
				If RIA_DTPGAD >= DTOS(dIni) .AND. RIA_DTPGAD <= DTOS(dFim)
					If lArray
					    aRet[Len(aRet),03] := TRB->RIA_DTPGAD
					    aRet[Len(aRet),04] += TRB->RIA_NRDIND
					Else
						Aadd(aRet,{	"",;				//-01
									0,;					//-02
									TRB->RIA_DTPGAD,;	//-03
									TRB->RIA_NRDIND,;	//-04
									TRB->RF_DATAFIM,;	//-05
									TRB->RF_DIASDIR,;	//-06
									TRB->RF_DATABAS,;	//-07-Data Inicio do Periodo
									"",;				//-08-Data para Indenizacao
									0 ,;					//-09-Dias para Indenizacao
									"" })	//-10-Data Inicio gozo de ferias
					EndIf
				EndIf
			EndIf
			
			cDtBaseAnt := TRB->RF_DATABAS
			
		Else	//-Diferente de P_SUMFERAB == "S"
		
			If RIA_DATPAG >= DTOS(dIni) .AND. RIA_DATPAG <= DTOS(dFim)
				Aadd(aRet,{	TRB->RIA_DATPAG,;	//-01
							TRB->RIA_NRDGOZ,;	//-02
							"",;				//-03
							0,;					//-04
							TRB->RF_DATAFIM,;	//-05
							TRB->RF_DIASDIR,;	//-06
							TRB->RF_DATABAS,;	//-07-Data Inicio do Periodo
							"",;				//-08-Data para Indenizacao
							0 ,;				//-09-Dias para Indenizacao
							TRB->RIA_DATINI})	//-10-Data Inicio gozo de ferias
			EndIf
			If RIA_DTPGAD >= DTOS(dIni) .AND. RIA_DTPGAD <= DTOS(dFim)
				Aadd(aRet,{	"",;				//-01
							0,;					//-02
							TRB->RIA_DTPGAD,;	//-03
							TRB->RIA_NRDIND,;	//-04
							TRB->RF_DATAFIM,;	//-05
							TRB->RF_DIASDIR,;	//-06
							TRB->RF_DATABAS,;	//-07-Data Inicio do Periodo
							"",;				//-08-Data para Indenizacao
							0 ,;				//-09-Dias para Indenizacao
							"" })					//-10-Data Inicio gozo de ferias
			EndIf
		EndIf
		
		dbSkip()
	EndDo
	TRB->( dbCloseArea() )
	RestArea( aArea )
Return(aRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} FSRFRET()
Funcao que retorna os Dias de Direito ainda NAO Programados na RIA
@return		
@author	    Ademar Fernandes
@since		13/06/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function FSRFRET(cVerba, dIni, dFim, cCateg)
	Local aArea     := GetArea()
	Local cQuery	:= ""
	Local aRet 		:= {}
	Local cSqlCateg	:= ""
	Local nX 		:= 0
	
	Default dIni	:= dDataDe  // DA INICIAL DO PERIODO, CARREGADO PELA FORMULA CARGARCH
	Default dFim  	:= dDataAte // DA FINAL   DO PERIODO, CARREGADO PELA FORMULA CARGARCH
	Default cCateg 	:= SRA->RA_CATFUNC
	
	For nX := 1 to Len(cCateg)
		cSqlCateg += "'" + Substr(cCateg,nX,1) + "',"
	Next nX
	cSqlCateg += "''"

	cQuery := " SELECT * FROM " + RETSQLNAME("SRF") + " RF "
	cQuery += " INNER JOIN " + RETSQLNAME("SRA") + " RA "
	cQuery += " ON RA.D_E_L_E_T_ = ' ' "
	cQuery += " 	AND RA_FILIAL = RF_FILIAL "
	cQuery += "		AND RA_MAT = RF_MAT "
	cQuery += "		AND RA_CATFUNC IN ("+ cSqlCateg +") "
	cQuery += " WHERE RF.D_E_L_E_T_ = ' ' "
	cQuery += " 	AND RF_FILIAL = '"+ SRA->RA_FILIAL +"' "
	cQuery += "		AND RF_MAT = '"+ SRA->RA_MAT +"' "
	cQuery += " 	AND RF_PD = '"+ cVerba + "' "
	cQuery += " 	AND RF_STATUS IN (' ','0','1') "
	cQuery += " 	AND (RF_DIASDIR-RF_DIASPRG) > 0 "
	
	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
	dbSelectArea("TRB")
	While !Eof()
		Aadd(aRet,{ STOD(TRB->RF_DATABAS),;			//-01
					STOD(TRB->RF_DATAFIM),;			//-02
					TRB->RF_DIASDIR,;				//-03
					TRB->RF_DIASPRG,;				//-04
					(TRB->RF_DIASDIR - TRB->RF_DIASPRG),;	//-05
					TRB->RF_STATUS })				//-06
		dbSkip()
	EndDo
	TRB->( dbCloseArea() )
	RestArea( aArea )
Return(aRet)


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} Vdf_EMail()
Envia E-Mail de Aviso  
Observacao: Utilizar a Funcao padrão RH_ErroMail() para apresentar erros 
			retornados por esta funcao.
@sample		Vdf_EMail(cEmailTo,cAssunto,cMensagem,clServer,clAccount,clPassword)
@param		cEmailTo	- Destinatário do e-mail
			cAssunto	- Assunto do e-mail
			cMensagem	- Corpo do e-mail
			cMailServer	- Servidor de e-mail
			cMailConta	- Conta Remetente do e-mail
			cMailSenha	- Senha do Remetente do e-mail
			cAttach		- Anexos
			cEmailcc	- Destinatários em cópia
@return		nErro
@author		Tania Bronzeri
@since      05/05/2014
@version    P11.9 
/*/
//---------------------------------------------------------------------------------------
Function Vdf_EMail(cEmailTo, cAssunto, cMensagem, cMailServer, cMailConta, cMailSenha, cAttach, cEmailcc)
Local aSaveArea		:= GetArea()
Local cUser			:= ""
Local aErro			:= {}
Local nAt			:= 0
Local lOk			:= .F.		// Variavel que verifica se foi conectado OK
Local lSendOk		:= .F.		// Variavel que verifica se foi enviado OK
Local lAutent		:= if(SuperGetMV("MV_RHAUTEN" ),.t.,if(SuperGetMV("MV_RELAUTH"),.t.,.f.))

Default cMailServer	:= 	if(!empty(SuperGetMV("MV_RHSERV" )),SuperGetMV("MV_RHSERV" ),SuperGetMV("MV_RELSERV"))
Default cMailConta	:=	if(!empty(SuperGetMV("MV_RHCONTA")),SuperGetMV("MV_RHCONTA"),SuperGetMV("MV_RELACNT"))
Default cMailSenha	:=	if(!empty(SuperGetMV("MV_RHSENHA")),SuperGetMV("MV_RHSENHA"),SuperGetMV("MV_RELAPSW"))

Default cEmailTo	:= ""
Default cAssunto	:= ""
Default cMensagem	:= ""
Default cAttach		:= ""
Default cEmailcc	:= ""

If 	Empty(cMailServer)
	aadd(aErro,OemToAnsi(STR0029)) //"Configure o servidor SMTP no parametro MV_RHSERV ou MV_RELSERV."
EndIf

If 	Empty(cMailConta)
	aadd(aErro,OemToAnsi(STR0030)) //"Configure a conta de email no parametro MV_RHCONTA ou MV_RELACNT."
EndIf

If 	Empty(cMailSenha) 
	aadd(aErro,OemToAnsi(STR0031)) //"Configure a senha da conta de email no parametro MV_RHSENHA ou MV_RELAPWS."
EndIf                                              
                 
If 	Empty(cEmailTo)
	aadd(aErro,OemToAnsi(STR0032)) //"Nao foi informado o email do destinatario!"
EndIf      

//Envia e-mail com os dados necessarios
If len(aErro) == 0
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk
	If lOk .And. lAutent	//Verifica se o Servidor de EMAIL necessita de Autenticacao
		//Primeiro tenta fazer a Autenticacao de E-mail utilizando o e-mail completo
		lOk := MailAuth(cMailConta, cMailSenha)
		//Se nao conseguiu fazer a Autenticacao usando o E-mail completo, tenta fazer a autenticacao usando apenas o nome de usuario do E-mail
		If !lOk
			nAt		:= At("@", cMailConta)
			cUser	:= If(nAt > 0, Subs(cMailConta, 1, nAt - 1), cMailConta)
			lOk 	:= MailAuth(cUser, cMailSenha)
		endif  
		If lOk
			SEND MAIL	FROM cMailConta;
						TO cEmailTo;
	 					BCC cEmailcc;					
						SUBJECT cAssunto;
						BODY cMensagem;  
						ATTACHMENT cAttach;					
						RESULT lSendOk 
		Else
			aadd(aErro,OemToAnsi(STR0033)) //"Erro na autenticação no SMTP server! Verifique os parametros MV_RHAUTEN e MV_RELAUTH."
		EndIf
		If !lSendOk
			aadd(aErro,OemToAnsi(STR0034)) //"Erro no envio do email."
		EndIf
		DISCONNECT SMTP SERVER
	Else
		aadd(aErro,OemToAnsi(STR0035)) //"Erro na conexão com o SMTP Server!"
	EndIf
EndIf                   

RestArea(aSaveArea)

Return aErro


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} fPerAnoCiv()
Verifica em qual perído do Ano Civel uma data está localizada.  
Utilização na Programação de Dias de Direito do Servidor 
@sample		fPerAnoCiv(dRiaPgIn, cTpPer)
@param		dRiaPgIn	- Data a ser Pesquisada
			cTpPer		- Tipo do Período a ser considerado, sendo:
							* "A" = Ano
							* "S" = Semestre
							* "Q" = Quadrimestre
							* "T" = Trimestre
							* "B" = Bimestre
							* "M" = Mês 
			Se este parâmetro não for passado, será assumido "M".
@return		aPerIniFim(dPerInicio,dPerFinal)
@author		Tania Bronzeri
@since      15/05/2014
@version    P11.9 
/*/
//---------------------------------------------------------------------------------------
Function fPerAnoCiv(dRiaPgIn, cTpPer)
Local aArea			:= GetArea()
Local aPerIniFim	:= {}
Local dPerInicio	:= CtoD("  /  /  ")
Local dPerFinal		:= CtoD("  /  /  ")
Local nPerMes		:= Month(dRiaPgIn)	//Mês Atual
Local nPerAno		:= Year(dRiaPgIn)	//Ano Atual
Local nMesIni		:= 0
Local nMesFim		:= 0
Local nMes			:= 0 
Local nI			:= 0

Do Case
	Case cTpPer == "A"
		nMes	:= 1
	Case cTpPer == "S" 
		nMes	:= 2 
	Case cTpPer == "Q"  
		nMes	:= 3
	Case cTpPer == "T"
		nMes	:= 4
	Case cTpPer == "B"
		nMes	:= 6
	OtherWise	//cTpPer == "M"  
		nMes	:= 12
EndCase

For nI	:= 1 to nMes 
	nMesIni	:= ((Int(12/nMes)) * (nI-1)) + 1
	nMesFim	:= (Int(12/nMes) * nI)
	If nPerMes >= nMesIni .And. nPerMes <= nMesFim
		dPerInicio	:= CtoD("01/" + StrZero(nMesIni,2) + "/" + AllTrim(Str(nPerAno)))
		dPerFinal	:= LastDay(CtoD("01/" + StrZero(nMesFim,2) + "/" + AllTrim(Str(nPerAno))))
	EndIf
Next nI

aPerIniFim	:= {dPerInicio,dPerFinal}

                        
RestArea(aArea)

Return aClone(aPerIniFim)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³VDFPadRetornoº Autor ³ Equipe IP-RH GSP º Data ³ 11/07/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorno da Consulta Padrao (SXB)                           º±±
±±º          ³ ExpC1 - Filtro de Tipo de roteiro                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus Versao 11.90                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VDFPadRetorno(cTipo)
Local aPerAtual := {}
Local cCpoRet   := ""

If fGetPerAtual( @aPerAtual, , MV_PAR01, MV_PAR02 )
    If cTipo == "PERIODO"
        cCpoRet := aPerAtual[1,1]
    Else
        cCpoRet := aPerAtual[1,2]
    EndIf
EndIf

Return (cCpoRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QryUtRCC ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 27/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna lista de opções utilizando a tabela RCC (RH)  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QryUtRCC() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Function QryUtRCC(aTam, cAnoMes)
	Local cNameDb := Upper(TcGetDb())
	Local cQuery  := "%SELECT MAX(RCCR.R_E_C_N_O_) FROM " + RetSqlName("RCC") + " RCCR " +;
					"JOIN (SELECT RCC_CODIGO AS COLUNA1, CASE WHEN RCC_FIL = ' ' THEN '" + cFilAnt + "' ELSE RCC_FIL END AS COLUNA2, ", nTam := 1, nSoma := 0

	Default cAnoMes := Str(Year(dDataBase), 4) + StrZero(Month(dDataBase), 2)

	For nTam := 1 To Len(aTam)
		IF !(cNameDB $ "POSTGRES")
			cQuery += "SUBSTRING(RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ") AS RCC_CONTE" + AllTrim(Str(nTam)) + ", "
		ELSE
			cQuery += "Substr(RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ") AS RCC_CONTE" + AllTrim(Str(nTam)) + ", "
		ENDIF
		nSoma += aTam[nTam]
	Next	

	cQuery += "MAX(CASE WHEN RCC_CHAVE = ' ' THEN '" + cAnoMes + "' ELSE RCC_CHAVE END) AS RCC_CHAVE " +;
			"FROM " + RetSqlName("RCC") + " " +;
			"WHERE D_E_L_E_T_ = ' ' AND RCC_FILIAL = '" + xFilial("RCC") + "' " +;
			"GROUP BY RCC_CODIGO, CASE WHEN RCC_FIL = ' ' THEN '" + cFilAnt + "' ELSE RCC_FIL END" 
	nSoma := 0

	For nTam := 1 To Len(aTam)
		IF !(cNameDB $ "POSTGRES")
			cQuery += ", SUBSTRING(RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ")"
		ELSE
			cQuery += ", Substr(RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ")"
		ENDIF
		nSoma += aTam[nTam]
	Next	

	cQuery +=      ") RCCM ON RCCM.COLUNA1 = RCCR.RCC_CODIGO " +;
			"AND RCCM.COLUNA2 = CASE WHEN RCCR.RCC_FIL = ' ' THEN '" + cFilAnt + "' ELSE RCCR.RCC_FIL END " +;
			"AND RCCM.RCC_CHAVE = CASE WHEN RCCR.RCC_CHAVE = ' ' THEN '" + cAnoMes + "' ELSE RCCR.RCC_CHAVE END "
	nSoma := 0

	For nTam := 1 To Len(aTam)
		IF !(cNameDB $ "POSTGRES")
			cQuery += " AND RCCM.RCC_CONTE" + AllTrim(Str(nTam)) + " = SUBSTRING(RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ")"
		ELSE
			cQuery += " AND RCCM.RCC_CONTE" + AllTrim(Str(nTam)) + " = Substr(RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ")"
		ENDIF
		nSoma += aTam[nTam]
	Next
			
	cQuery += " WHERE RCCR.D_E_L_E_T_ = ' ' AND RCCR.RCC_FILIAL = '" + xFilial("RCC") + "' " +;
				"AND RCCR.RCC_CODIGO = RCC.RCC_CODIGO AND CASE WHEN RCC_FIL = ' ' THEN '" + cFilAnt + "' ELSE RCC_FIL END = " +;
														"CASE WHEN RCC.RCC_FIL = ' ' THEN '" + cFilAnt + "' ELSE RCC.RCC_FIL END " +;
				"AND CASE WHEN RCCR.RCC_CHAVE = ' ' THEN '" + cAnoMes + "' ELSE RCCR.RCC_CHAVE END <= '" + cAnoMes + "' "
	nSoma := 0

	For nTam := 1 To Len(aTam)
		IF !(cNameDB $ "POSTGRES")
			cQuery += " AND SUBSTRING(RCCR.RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ") = " +;
					"SUBSTRING(RCC.RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ")"  
		ELSE
			cQuery += " AND Substr(RCCR.RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ") = " +;
					"Substr(RCC.RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ")"
		ENDIF
		nSoma += aTam[nTam]
	Next
	cQuery += "%"
Return cQuery


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ VDF_RBSREC  º Autor ³ Equipe IP-RH GSP º Data ³ 14/07/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Consulta padrao RBSREC para direcionar a tabela correta    º±±
±±º          ³ conforme o modulo utilizado                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus Versao 12                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VDF_RBSREC()
Local lRet := .t.

If fUsaGFP()
	lRet := ConPad1(,,,"RER" )
	If lRet 
		VAR_IXB := RER->RER_CODIGO
	Else
		VAR_IXB := Space(GetSx3Cache("RER_CODIGO", "X3_TAMANHO"))
	EndIf
Else
	lRet := ConPad1(,,,"RBS" )
	If lRet 
		VAR_IXB := RBS->RBS_CODIGO
	Else
		VAR_IXB := Space(GetSx3Cache("RBS_CODIGO", "X3_TAMANHO"))
	EndIf
EndIf

Return(lRet)
                                                                   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ fDias2Anos  º Autor ³ Equipe IP-RH GSP º Data ³ 14/07/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Calcula anos/meses/dias a partir de uma quantidade de dias º±±
±±º          ³ passado no parametro nTempo.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus Versao 12                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fDias2Anos(nTempo,nAnos,nMeses,nDias)
Default nTempo	:= 0
Default nAnos	:= 0
Default nMeses	:= 0
Default nDias	:= 0

nAnos	:= NoRound(nTempo/365,0)
nTempo	-= nAnos*365
nMeses	:= NoRound(nTempo/30,0)
nTempo	-= nMeses*30
nDias	:= nTempo

Return Nil             

FUNCTION fFaltaSRC (aSRCFaltas, cPeriodo, cRoteiros, cPDs )
Local aCodFol 		:= {}
local cWhere 		:= ""
local cJoin			:= ""
local cAliasSRC 	:= getNextAlias()
Local aArea     	:= GetArea()

cJoin := "% "
cJoin += FWJoinFilial( "SRC", "SRV" )
cJoin += " AND RC_PD = RV_COD "
cJoin += "%"
BeginSql alias cAliasSRC
	%noparser% 
	SELECT RC_ROTEIR, RC_TIPO1, RC_HORAS, RC_PD,RC_VALOR,RV_TIPO,RV_TIPOCOD, RV_CODFOL, RC_SEMANA, RV_ACUMAUX
	FROM %table:SRC% SRC 
	INNER JOIN %table:SRV% SRV ON %exp:cJoin%
		WHERE  RC_PERIODO = %exp:cPeriodo% AND 
			   RC_ROTEIR IN (%exp:STRTRAN(cRoteiros ,"/","','")%) AND 
			   RV_CODFOL IN (%exp:STRTRAN(cPDs ,"*","','")%) AND RC_MAT = %exp:SRA->RA_MAT% AND  RC_PROCES = %exp:SRA->RA_PROCES%
				AND SRC.%notDel%
		ORDER BY SRC.RC_FILIAL, SRC.RC_MAT, SRC.RC_PD 
EndSql

While (cAliasSRC)->(!EoF())
	aadd(aSRCFaltas, {(cAliasSRC)-> RC_ROTEIR,(cAliasSRC)-> RC_TIPO1,(cAliasSRC)-> RC_HORAS,(cAliasSRC)->RC_PD,;
	 				  (cAliasSRC)-> RC_VALOR, (cAliasSRC)->RV_TIPOCOD, (cAliasSRC)->RV_CODFOL, (cAliasSRC)->RC_SEMANA,; 
	 				  (cAliasSRC)->RV_ACUMAUX})
	(cAliasSRC)->( dbSkip())
End While

(cAliasSRC)->(DbCloseArea())
RestArea(aArea)

RETURN Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ fCarregSRB  º Autor ³ Equipe IP-RH GSP º Data ³ 14/07/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ RETORNA OS DADOS DA TABELA SRB 							  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus Versao 12                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

FUNCTION fCarregSRB (aSRB, RAFILIAL, RAMAT )
Local aCodFol 		:= {}
local cWhere 		:= ""
local cJoin			:= ""
local cAliasSRB 	:= getNextAlias()
Local aArea     	:= GetArea()

cJoin := "% "
cJoin += FWJoinFilial( "SRB", "SRA" )
cJoin += " AND RB_MAT = RA_MAT "
cJoin += "%"
BeginSql alias cAliasSRB
	%noparser% 
	SELECT *
	FROM %table:SRB% SRB 
	INNER JOIN %table:SRA% SRA ON %exp:cJoin%
		WHERE SRB.%notDel% AND SRA.%notDel% AND SRA.RA_MAT = %exp:RAMAT% AND SRA.RA_FILIAL = %exp:RAFILIAL% 
		ORDER BY SRB.RB_FILIAL, SRB.RB_MAT
EndSql
While (cAliasSRB)->(!EoF())
	aadd(aSRB, {(cAliasSRB)->RB_FILIAL,;    // 1
				(cAliasSRB)->RB_MAT,;       // 2
				(cAliasSRB)->RB_AUXCRE,;    // 3
				(cAliasSRB)->RB_DTBAIXA,;   // 4
	 			(cAliasSRB)->RB_DTINIAC,;   // 5
				(cAliasSRB)->RB_DTNASC,;    // 6
				(cAliasSRB)->RB_VLRCRE})    // 7
	(cAliasSRB)->( dbSkip())
End While

(cAliasSRB)->(DbCloseArea())
RestArea(aArea)

RETURN Nil



Function fSusp131()

Local cAliasRCM := GetNextAlias()
Local aRet		:= {}
Local aSoma		:= {}
Local dIni, dFim, nX, nPos, cCodSup
Local cRCMFil	:= "% " + FwJoinFilial("RCM","SRA") + "%"

//Inclui o mnemonico se ainda nao existir na base
If Type("aSusp131")=="U" 
	RCA->(dbsetorder(1))
	If !RCA->(dbseek(xFilial("RCA")+"ASUSP131")) 
		RecLock("RCA",.t.)
		RCA->RCA_FILIAL := xFilial("RCA")
		RCA->RCA_MNEMON	:= "ASUSP131"
		RCA->RCA_DESC	:= "ARRAY TIPOS DE AUSENCIAS P/SUSPENSAO 1P 13SAL"
   		RCA->RCA_TIPO	:= "A"
		RCA->RCA_CONTEU := 'GetValType("A")'
		RCA->RCA_ACUMUL := "1"
		RCA->(MsUnLock())
	EndIf
	aSusp131 := {}
EndIf		       

//Busca na RCM as ausencias parametrizadas para a filial
If Type("aSusp131")<>"U" .and. len(aSusp131) == 0	
	BeginSql alias cAliasRCM
		SELECT DISTINCT(RCM_TIPO), RCM_DSU131, RCM_APS131 
			FROM %table:RCM% RCM
		  	INNER JOIN %table:SRA% SRA 
		   		ON %exp:cRCMFil%
		WHERE 
			RCM.%NotDel% AND SRA.%NotDel% AND
			RCM_DSU131 > %exp:0% AND RCM_APS131 <> %exp:''%
	EndSql
	While (cAliasRCM)->(!EOF())
		aadd(aSusp131,{(cAliasRCM)->RCM_TIPO, (cAliasRCM)->RCM_DSU131, (cAliasRCM)->RCM_APS131})
		(cAliasRCM)->(dbskip())
	EndDo
	(cAliasRCM)->(dbclosearea())
EndIf

//cria uma linha no array com @@@ no codigo para identificar que ja buscou RCM e nao ha ausencia parametrizada
If len(aSusp131) == 0
	aadd(aSusp131,{"@@@",0,''}) 
EndIf

If len(aSusp131) > 0 .and. aSusp131[1,1] <> '@@@'
	cCodSusp := ''
	For nX := 1 to len(aSusp131)
		cCodSusp += aSusp131[nX,1] + '/'
	Next nX


	//Executa para cada ausencia encontrada
	For nX := 1 to len(aRet)
		nPos := aScan(aSusp131, {|x| x[1] == aRet[nX,1]})
		aRet[nX,4] := if(empty(aRet[nX,4]),dDataAte,aRet[nX,4]) //Preenche a data final com o ultimo dia do periodo quando a ausencia esta com data em branco
		//Apuracao no mes de calculo
		If aSusp131[nPos,3] == '1' 
			dIni := max(dDataDe ,aRet[nX,3]) //Define a data inicial = maximo entre data inicial do periodo em calculo e data de inicio da ausencia
		//Apuracao no ano corrente
		Else
			dIni := max(ctod("01/01"+mesano(dDataDe)) ,aRet[nX,3])  //Define a data inicial = maximo entre 01/jan e data de inicio da ausencia
		EndIf
		dFim := min(dDataAte,aRet[nX,4]) //Define a data final   = minimo entre data final   do periodo em calculo e data final da ausencia
		If dFim < dIni
			loop
		EndIf
		//Soma os dias do mesmo tipo de ausencia
        If (nPos := aScan(aSoma, {|x| x[1] == aRet[nX,1]})) > 0
        	aSoma[nPos,2] += ( dFim - dIni + 1 )
		Else
	        aadd(aSoma,{ aRet[nX,1], dFim - dIni + 1 })
	 	EndIf
    Next nX

endif

return
