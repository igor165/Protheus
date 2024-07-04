#INCLUDE "TOTVS.CH" 
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "TRMM090.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} 


@author Rogerio Ribeiro da Cruz
@since 29/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function TRMM090()
	If !SuperGetMv("MV_TRMINTG", NIL, .F.)
		Alert(STR0002 + Chr(13) + STR0003) //"Rotina disponivel somente para integração com EPM/AMS" + Chr(13) + "Para utilizá-la, configure os parametros 'MV_TRMINTG', 'MV_TRMEPMW' e 'MV_TRMAMSW'")
		Return
	EndIf
	
	Pergunte("TRMM090", .F.)
	
	TNewProcess():New("TRMM090", STR0001, {|oSelf| TRMM090Process(oSelf)}, STR0004, "TRMM090", NIL, NIL, NIL, NIL, .T., .F.)		//"Carga de dados no EPM/AMS" / "Esta rotina realiza a carga inicial de dados no EPM/AMS"
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} 


@author Rogerio Ribeiro da Cruz
@since 29/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TRMM090Process(oProcess)   
	Local nOldSet 		:= SetVarNameLen(255)
	Local aArea			:= GetArea()
	Local nCount, nCount2
	Local aItems		:= {}
	Local lCancel		:= .F.

	Private aEmpresas	:= FWLoadSM0()
	Private nTamLayEmp  := len(FWSM0Layout(cEmpAnt,1))
	Private nTamLayUni  := len(FWSM0Layout(cEmpAnt,2))
	Private nTamLayFil  := len(FWSM0Layout(cEmpAnt,3))

	If ("N" $ mv_par01)
		AAdd(aItems, {STR0005, { || ProcUnid(oProcess) } })			//"Unidade"
	EndIf

	If ("T" $ mv_par01)
		AAdd(aItems, {STR0006, { || ProcTopi(oProcess) } })			//"Topico"
	EndIf

	If ("Q" $ mv_par01)
		AAdd(aItems, {STR0007, { || ProcQues(oProcess) } })			//"Questao"
	EndIf

	If ("A" $ mv_par01)
		AAdd(aItems, {STR0008, { || ProcAval(oProcess) } })			//"Avaliacao"
	EndIf

	If ("S" $ mv_par01)
		AAdd(aItems, {STR0009, { || ProcServ(oProcess) } })			//"Servidor de Conteudo"
	EndIf

	If ("C" $ mv_par01)
		AAdd(aItems, {STR0010, { || ProcCont(oProcess) } })			//"Conteudo"
	EndIf

	If ("E" $ mv_par01)
		AAdd(aItems, {STR0011, { || ProcCert(oProcess) } })			//"Certificado"
	EndIf

	If ("R" $ mv_par01)
		AAdd(aItems, {STR0012, { || ProcAvRe(oProcess) } })	  		//"Avaliacao de Reacao"
	EndIf

	If ("I" $ mv_par01)
		AAdd(aItems, {STR0013, { || ProcTrei(oProcess) } })			//"Treinamento"
	EndIf

	If ("U" $ mv_par01)
		AAdd(aItems, {STR0014, { || ProcUsua(oProcess) } })			//"Usuario"
	EndIf


	If ("M" $ mv_par01)
		AAdd(aItems, {STR0015, { || ProcMatr(oProcess) } })			//"Matricula"
	EndIf	
	
	oProcess:SetRegua1(Len(aItems))
	oProcess:SaveLog(STR0019)	//"Inicio de processamento"
	                                           
	For nCount:= 1 to Len(aItems)
		If (oProcess:lEnd)
			Break
		EndIf
		
		oProcess:IncRegua1(aItems[nCount, 1])
		oProcess:SetRegua2(0)
		oProcess:IncRegua2("")
		
		Eval(aItems[nCount, 2])
	Next

	oProcess:IncRegua1("")
	
	SetVarNameLen(nOldSet)			

	If !oProcess:lEnd
		Aviso(STR0001, STR0020, {"Ok"})		//"Carga de dados no EPM/AMS", "Fim do processamento!"
		oProcess:SaveLog(STR0020)			//"Fim do processamento"
	Else
		Aviso(STR0001, STR0021, {"Ok"})		//"Carga de dados no EPM/AMS", "Processamento cancelado pelo usuario!"
		oProcess:SaveLog(STR0021)			//"Processamento cancelado pelo usuario!"
	EndIf
		
	RestArea(aArea)
Return .T.                                     


//-------------------------------------------------------------------
/*/{Protheus.doc} 


@author Rogerio Ribeiro da Cruz
@since 29/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function ProcAval(oProcess)
	Local oWSAvaliacao	:= AMSWSNew("Avaliacao")
	Local aAvaliacao	:= {}
	Local oAvaliacao, nCount
	Local cCodAva, cFilAva
	Local cEmp       	:= ""
	Local cUni       	:= ""
	Local cFil	     	:= ""
	Local cPai       	:= ""
	Local cFilho     	:= ""

	DBSelectArea("SQQ")
	DBSetOrder(1)
	DBGoTop()
		
	While !SQQ->(Eof())
		If (oProcess:lEnd); Return; EndIf
		
		cFilAva := SQQ->QQ_FILIAL
		cCodAva := SQQ->QQ_TESTE
		
		oAvaliacao:= AvaliacaoWSService_AvaliacaoWSHolder():New()				
		oAvaliacao:cCodigo	 		:= ""
		oAvaliacao:cCdExterno 		:= SQQ->QQ_FILIAL+SQQ->QQ_TESTE
		oAvaliacao:cDescricao 		:= AllTrim(SQQ->QQ_DESCRIC)
		oAvaliacao:cNome	 		:= AllTrim(SQQ->QQ_DESCRIC)
		oAvaliacao:cDuracao 		:= AllTrim(Str(fTimeToMinutes(SQQ->QQ_DURACAO)))
		If SQQ->QQ_TIPO != "REA"
			oAvaliacao:cPesquisa	:= "n"
		Else	
			oAvaliacao:cPesquisa	:= "y"		
		EndIf		

		
		//-----------------------------------		
		// Prepara relacionamento com unidade
		If Empty(SQQ->QQ_FILIAL)
           cPai   := FWCodEmp() + FWunitBusiness() 
		   cFilho := FWCodFil()	
		else
			//Captura Empresa
			cEmp := substr(SQQ->QQ_FILIAL, 1, nTamLayEmp)
			//Captura Unidade
			cUni := substr(SQQ->QQ_FILIAL, nTamLayEmp+1, nTamLayUni)
			//Captura Filial
			cFil := substr(SQQ->QQ_FILIAL, nTamLayEmp+nTamLayUni+1, nTamLayFil)
	         
			// Tratamento para Gestao de Empresas //
	        //Identifica Pai-Filho para Filial SQ0
   	        If nTamLayEmp > 0 .Or. nTamLayUni > 0

				If !Empty(cFil) .and. cFil <> Nil
					cPai   := cEmp+cUni
					cFilho := cEmp+cUni+cFil
				Else 
					If !Empty(cUni) .and. cUni <> Nil
						cPai   := cEmp
						cFilho := cEmp+cUni
					Else
						If !Empty(cEmp) .and. cEmp <> Nil
							cPai   := FWGrpCompany()
 							cFilho := cEmp
						EndIf
					EndIf	
		        EndIf     
		   Else 
		   		cPai	 	:= FWGrpCompany()
		   		cFilho 		:= SQQ->QQ_FILIAL
		   EndIf
	    EndIf    
	
		oAvaliacao:oWSListaUnidade										:= AvaliacaoWSService_ListaUnidadeWSHolder():New()
		oAvaliacao:oWSListaUnidade:oWSUnidade							:= {}

		AAdd(oAvaliacao:oWSListaUnidade:oWSUnidade, AvaliacaoWSService_UnidadeWSHolder():New())
		oAvaliacao:oWSListaUnidade:oWSUnidade[1]:cCdUnidadePaiExterno	:= cPai
		oAvaliacao:oWSListaUnidade:oWSUnidade[1]:cCdUnidadeFilhoExterno	:= cFilho
		//---------------------------
		

		//---------------------------		
        // Questoes da avaliacao
		//---------------------------
		oAvaliacao:oWSListaQuestao:= AvaliacaoWSService_ListaQuestaoWSHolder():New()
		oAvaliacao:oWSListaQuestao:oWSQuestao:= {}	
		While !SQQ->(EOF()) .AND.;
				cFilAva == SQQ->QQ_FILIAL  .AND.;
				cCodAva == SQQ->QQ_TESTE
			oQuestao			:= AvaliacaoWSService_QuestaoWSHolder():New()
			oQuestao:cCdExterno := SQQ->QQ_FILIAL+SQQ->QQ_QUESTAO

			AAdd(oAvaliacao:oWSListaQuestao:oWSQuestao, oQuestao)

			SQQ->(DBSkip())
		EndDo
		//---------------------------


		AAdd(aAvaliacao, oAvaliacao)
		oProcess:IncRegua2(STR0018 + " [" + AllTrim(Str(Len(aAvaliacao))) + "]")	//"Aguarde... Selecionando registros..."
	EndDo
	
	oProcess:SetRegua2(Len(aAvaliacao))
	
	For nCount:= 1 to Len(aAvaliacao)
		If (oProcess:lEnd); Return; EndIf
		
		oProcess:IncRegua2(aAvaliacao[nCount]:cCdExterno + " - " + aAvaliacao[nCount]:cDescricao )
		
		If !oWSAvaliacao:InsertAvaliacao(aAvaliacao[nCount])
			oProcess:SaveLog(STR0022 + " " + aAvaliacao[nCount]:cCdExterno + " - " + aAvaliacao[nCount]:cDescricao)		//"Não foi possivel gravar a avaliacao!"
			oProcess:SaveLog(GetWSCError())
		EndIF			
	Next	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} 


@author Rogerio Ribeiro da Cruz
@since 29/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function ProcAvRe(oProcess)
	Local oWSAvReacao:= EPMWSNew("AvaliacaoReacao")	
	Local aAvReacao:= {}
	Local oAvReacao, nCount
	
	DBSelectArea("SQQ")
	DBSetOrder(1)
	DBGoTop()

	While !SQQ->(Eof())
		If (oProcess:lEnd); Return; EndIf
				
		If SQQ->QQ_TIPO != "REA"
			SQQ->(DBSkip())
			Loop
		EndIf		

		oAvReacao:= AvaliacaoReacaoWSService_AvaliacaoReacaoWSHolder():New()					
		oAvReacao:cCdExterno 					:= SQQ->QQ_FILIAL+SQQ->QQ_TESTE
		oAvReacao:cUrl 							:= SQQ->QQ_FILIAL+AllTrim(SQQ->QQ_TESTE)
		oAvReacao:cTipoPesquisa 				:= "1"
		oAvReacao:cTitulo						:= AllTrim(SQQ->QQ_DESCRIC)
		oAvReacao:cCdServidorConteudoExterno 	:= AllTrim(SQQ->QQ_SRVCNT)
		
		AAdd(aAvReacao, oAvReacao)		
		SQQ->(DBSkip())
		oProcess:IncRegua2(STR0018 + " [" + AllTrim(Str(Len(aAvReacao))) + "]")	//"Aguarde... Selecionando registros..."
	EndDo
	
	oProcess:SetRegua2(Len(aAvReacao))
	
	For nCount:= 1 to Len(aAvReacao)
		If (oProcess:lEnd); Return; EndIf
				
		oProcess:IncRegua2(aAvReacao[nCount]:cCdExterno + " - " + aAvReacao[nCount]:cTitulo)
		
		If !oWSAvReacao:insertAvaliacaoReacao(aAvReacao[nCount])
			oProcess:SaveLog(STR0023 + " " + aAvReacao[nCount]:cCdExterno + " - " + aAvReacao[nCount]:cTitulo)	//"Nao foi possivel gravar a avaliacao de reacao!" 
			oProcess:SaveLog(GetWSCError())
		EndIF			
	Next
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} 


@author Rogerio Ribeiro da Cruz
@since 29/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function ProcCert(oProcess)
	Local oWSCert:= EPMWSNew("Certificado")
	Local aCertificado:= {}
	Local oCertificado, oItem, nCount, cKeyRAX

	DBSelectArea("RAX")
	DBSetOrder(1)
	DBGoTop()

	While !RAX->(EOF())
		If (oProcess:lEnd); Return; EndIf
		
		oCertificado							:= CertificadoWSService_CertificadoWSHolder():New()
		oCertificado:cCdExterno 				:= RAX->RAX_CODIGO
		oCertificado:cDescricao 				:= FDesc("RHG",RAX->RAX_CODIGO,"RHG->RHG_DESC",60)
		oCertificado:oWSListaTextoCertificado	:= CertificadoWSService_ListaTextoCertificadoWSHolder():New()
		oCertificado:oWSListaTextoCertificado:oWSTextoCertificado:= {}

		cKeyRAX:= RAX->RAX_FILIAL + RAX->RAX_CODIGO

		While !RAX->(EOF()) .AND.;
				RAX->RAX_FILIAL + RAX->RAX_CODIGO == cKeyRAX		
		
			oItem:= CertificadoWSService_TextoCertificadoWSHolder():New()			
			oItem:cCdCertificadoExterno := RAX->RAX_CODIGO
			oItem:cAlinhamentoX 		:= RAX->RAX_ALIGNX
			oItem:nPosicaoX 			:= RAX->RAX_POSICX
			oItem:nPosicaoY 			:= RAX->RAX_POSICY
			oItem:cTexto 				:= AllTrim(RAX->RAX_TEXTO)
			
			AAdd(oCertificado:oWSListaTextoCertificado:oWSTextoCertificado, oItem)
			RAX->(DBSkip())
		EndDo
		
		Aadd(aCertificado, oCertificado)
		oProcess:IncRegua2(STR0018 + " [" + AllTrim(Str(Len(aCertificado))) + "]")	//"Aguarde... Selecionando registros..."
	EndDo

	oProcess:SetRegua2(Len(aCertificado))
	
	For nCount:= 1 to Len(aCertificado)
		If (oProcess:lEnd); Return; EndIf
		
		oProcess:IncRegua2(aCertificado[nCount]:cCdExterno + " - " + aCertificado[nCount]:cDescricao)
		
		If !oWSCert:InsertCertificado(aCertificado[nCount])
			oProcess:SaveLog(STR0024 + " " + aCertificado[nCount]:cCdExterno + " - " + aCertificado[nCount]:cDescricao)	//"Nao foi possivel gravar o certificado! "
			oProcess:SaveLog(GetWSCError())
		EndIF			
	Next
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} 


@author Rogerio Ribeiro da Cruz
@since 29/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function ProcCont(oProcess)
	Local oWSConteudo:= EPMWSNew("Conteudo")
	Local aConteudo := {}
	Local oConteudo, nCount
	
	DBSelectArea("RAV")
	DBSetOrder(1)
	DBGoTop()
		
	While !RAV->(EOF())		
		If (oProcess:lEnd); Return; EndIf
		
		oConteudo						  := ConteudoWSService_ConteudoWSHolder():New()
		oConteudo:cCdExterno 			  := RAV->RAV_CODIGO
        oConteudo:cSigla 				  := AllTrim(RAV->RAV_CODIGO)
        oConteudo:cTitulo 				  := AllTrim(RAV->RAV_TITULO)
		oConteudo:cDescricao 			  := AllTrim(RAV->RAV_DESC)
		oConteudo:cCdContentServerExterno := RAV->RAV_SRVCNT
		If RAV->RAV_TIPO == "4"//Scorm
			oConteudo:cUrl 					  := RTrim(RAV->RAV_URL)
		ElseIf Empty( xFilial( "SQQ" ) )
        	oConteudo:cUrl 					  := xFilial( "SQQ" ) + RTrim( RAV->RAV_URL )
  		Else
  			oConteudo:cUrl 					  := RAV->RAV_FILIAL + RTrim( RAV->RAV_URL )
  		EndIf
        oConteudo:nTipoOAExterno 		  := Val(RAV->RAV_TIPO)
        oConteudo:cCdIdiomaExterno 		  := GetLangType(RAV->RAV_IDIOMA)

		Aadd(aConteudo, oConteudo)
		RAV->(DBSkip())
		oProcess:IncRegua2(STR0018 + " [" + AllTrim(Str(Len(aConteudo))) + "]")	//"Aguarde... Selecionando registros..."
	EndDo

	oProcess:SetRegua2(Len(aConteudo))
	
	For nCount:= 1 to Len(aConteudo)
		If (oProcess:lEnd); Return; EndIf
		
		oProcess:IncRegua2(aConteudo[nCount]:cCdExterno + " - " + aConteudo[nCount]:cDescricao)
		
		If !oWSConteudo:InsertConteudo(aConteudo[nCount])
			oProcess:SaveLog(STR0025 + " " + aConteudo[nCount]:cCdExterno + " - " + aConteudo[nCount]:cDescricao)	//"Nao foi possivel gravar o conteúdo!"
			oProcess:SaveLog(GetWSCError())
		EndIF			
	Next
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} 


@author Rogerio Ribeiro da Cruz
@since 29/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function ProcMatr(oProcess)
	Local cTreinamento := ''
	Local oWSMatricula := EPMWSNew("Matricula")	
	Local aMatricula := {}
	Local oMatricula, nCount
	
	DBSelectArea("RA3")
	DBSetOrder(1)
	DBGoTop()
	
	While !RA3->(Eof())
		If (oProcess:lEnd); Return; EndIf
			
		If RA3->RA3_RESERV != "R" .OR.;
				Posicione("RA1", 1, xFilial("RA1", RA3->RA3_FILIAL) + RA3->RA3_CURSO, "RA1_TIPO") != "L"
			RA3->(DBSkip())
			Loop		
		EndIf

		cTreinamento := ltrim(xFilial("RA1", RA3->RA3_FILIAL) + alltrim(RA3->RA3_CURSO))
		
		oMatricula:= MatriculaWSService_MatriculaWSHolder():New()		
		oMatricula:cCdExterno            := cTreinamento + alltrim(RA3->RA3_MAT) + alltrim(Str(RA3->(RECNO()))) + DTOS(RA3->RA3_DATA)
		oMatricula:cCdTreinamentoExterno  := cTreinamento
		oMatricula:cCdUsuarioExterno		:= RA3->RA3_FILIAL + alltrim(RA3->RA3_MAT)        
		oMatricula:nSituacao				   := 2							//0=INATIVO; 1=PENDENTE; 2=MATRICULADO; 3=INICIADO; 4=CANCELADO, 5=FINALIZADO; 6=FINALIZADO_NOPRETESTE; 7=ACONFIRMAR			
		oMatricula:nStatusAprovacao			:= 0			  				//0=INDEFINIDO; 1=COM_EXITO; 2=SEM_EXITO; 3=APROVADO; 4=REPROVADO; 5=SEM_EXITO_EXPIRADO
		oMatricula:cDataMatricula 			:= fFormatDate(RA3->RA3_DATA)	//dateTime
		oMatricula:cDataInicio 				:= ""
		oMatricula:cDataFim					:= ""
		oMatricula:cTipoMatricula			:= "TREINAMENTO"
		oMatricula:cCdUnidadePaiExterno		:= FWGrpCompany()
		oMatricula:cCdUnidadeExterno		:= RA3->RA3_FILIAL
		oMatricula:nScorePreTeste			:= NIL
		oMatricula:nScorePosTeste			:= NIL
		oMatricula:nScoreAvaliacaoReacao	:= NIL
		oMatricula:cCodigoPreTeste			:= ""
		oMatricula:cCodigoPosTeste			:= ""
		oMatricula:cCodigoAvaliacaoReacao	:= ""

		AAdd(aMatricula, oMatricula)
		RA3->(DBSkip())
		oProcess:IncRegua2(STR0018 + " [" + AllTrim(Str(Len(aMatricula))) + "]")	//"Aguarde... Selecionando registros..."
	EndDo

	oProcess:SetRegua2(Len(aMatricula))
	
	For nCount:= 1 to Len(aMatricula)
		If (oProcess:lEnd); Return; EndIf
			
		oProcess:IncRegua2(aMatricula[nCount]:cCdUsuarioExterno + " - " + aMatricula[nCount]:cCdTreinamentoExterno)
		
		If !oWSMatricula:InsertMatricula(aMatricula[nCount])
			oProcess:SaveLog(STR0026 + " " + aMatricula[nCount]:cCdUsuarioExterno + " - " + aMatricula[nCount]:cCdTreinamentoExterno)	//"Nao foi possivel gravar a matricula!"
			oProcess:SaveLog(GetWSCError())
		EndIF			
	Next
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} 


@author Rogerio Ribeiro da Cruz
@since 29/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function ProcQues(oProcess)
	Local oWSQuestao := AMSWSNew("Questao")
	Local aQuestao 	 := {}
	Local oQuestao, oAlternativa, nCount
	Local cEmp       := ""
	Local cUni       := ""
	Local cFil	     := ""
	Local cPai       := ""
	Local cFilho     := ""

	dbSelectArea("RBL")
	dbSetOrder(1)
	dbSelectArea("SQP")
	dbSetOrder(1)
	DBSelectArea("SQO")
	DBSetOrder(1)
	DBGoTop()

	While !SQO->(Eof())
		If (oProcess:lEnd); Return; EndIf
			
		cFilSQO						:= IIF(Empty(SQO->QO_FILIAL), FWCodFil(), SQO->QO_FILIAL)
		oQuestao					:= QuestaoWSService_QuestaoWSHolder():New()
		oQuestao:cCdExterno 		:= SQO->QO_FILIAL+SQO->QO_QUESTAO
		oQuestao:cPergunta 			:= AllTrim(SQO->QO_QUEST)
		oQuestao:cTipo 				:= GetQuestType(SQO->QO_TIPOOBJ)
		oQuestao:lAtivo 			:= IIF(SQO->QO_ATIVO == "1", .T., .F.)
		oQuestao:nScore 			:= Int(SQO->QO_PONTOS)
		oQuestao:dDataCriacao		:= SQO->QO_DATA
		oQuestao:cCdTopicoExterno 	:= SQO->QO_AREA
		oQuestao:cDescricao			:= ""
		
		oQuestao:oWSListaAlternativa:= QuestaoWSService_ListaAlternativaWSHolder():New()
		oQuestao:oWSListaAlternativa:oWSAlternativa:= {}

		If Empty(SQO->QO_ESCALA)
			SQP->(dbSeek(xFilial("SQP", cFilSQO) + SQO->QO_QUESTAO))
			
			While !SQP->(Eof()) .AND.;
					SQP->QP_FILIAL == xFilial("SQP", cFilSQO) .AND.;
					SQP->QP_QUESTAO == SQO->QO_QUESTAO
			
				oAlternativa					:= QuestaoWSService_AlternativaWSHolder():New()
				oAlternativa:cCdQuestaoExterno 	:= SQP->QP_FILIAL + SQP->QP_QUESTAO
				oAlternativa:cCdExterno 		:= SQP->QP_FILIAL + SQP->QP_QUESTAO + SQP->QP_ALTERNA
				oAlternativa:cDescricao 		:= AllTrim(SQP->QP_DESCRIC)
				oAlternativa:cScore 			:= AllTrim(Str(SQP->QP_PERCENT))
	
				AAdd(oQuestao:oWSListaAlternativa:oWSAlternativa, oAlternativa)
				SQP->(DBSkip())
			EndDo
		Else
			RBL->(dbSeek(xFilial("RBL", SQO->QO_FILIAL) + SQO->QO_ESCALA))
			
			While !RBL->(Eof()) .AND.;
					RBL->RBL_FILIAL == xFilial("RBL", SQO->QO_FILIAL) .AND.;
					RBL->RBL_ESCALA == SQO->QO_ESCALA
			
				oAlternativa					:= QuestaoWSService_AlternativaWSHolder():New()
				oAlternativa:cCdQuestaoExterno 	:= SQO->QO_FILIAL + SQO->QO_QUESTAO
				oAlternativa:cCdExterno 		:= SQO->QO_FILIAL + SQO->QO_QUESTAO + RBL->RBL_ITEM
				oAlternativa:cDescricao 		:= AllTrim(RBL->RBL_DESCRI)
				oAlternativa:cScore 			:= AllTrim(Str(RBL->RBL_VALOR))

				AAdd(oQuestao:oWSListaAlternativa:oWSAlternativa, oAlternativa)
				RBL->(DBSkip())
			EndDo			
		EndIf
		
		// Prepara relacionamento com unidade
		If Empty(SQO->QO_FILIAL)
           cPai   := FWCodEmp() + FWunitBusiness() 
		   cFilho := FWCodFil()	
		else
			//Captura Empresa
			cEmp := substr(SQO->QO_FILIAL, 1, nTamLayEmp)
			//Captura Unidade
			cUni := substr(SQO->QO_FILIAL, nTamLayEmp+1, nTamLayUni)
			//Captura Filial
			cFil := substr(SQO->QO_FILIAL, nTamLayEmp+nTamLayUni+1, nTamLayFil)
	            
			// Tratamento para gestao de empresas //
	        //Identifica Pai-Filho para Filial SQ0  
	        If nTamLayEmp > 0 .Or. nTamLayUni > 0
				If !Empty(cFil) .and. cFil <> Nil
					cPai   := cEmp+cUni
					cFilho := cEmp+cUni+cFil
				Else 
					If !Empty(cUni) .and. cUni <> Nil
						cPai   := cEmp
						cFilho := cEmp+cUni
					Else
						If !Empty(cEmp) .and. cEmp <> Nil
							cPai   := FWGrpCompany()
							cFilho := cEmp
						EndIf
					EndIf	
				EndIf
			Else 
				cPai 	:= FWGrpCompany()
				cFilho 	:= SQO->QO_FILIAL
	        EndIf
		EndIf
			
		oQuestao:oWSListaUnidade				:= QuestaoWSService_ListaUnidadeWSHolder():New()
		oQuestao:oWSListaUnidade:oWSUnidade		:= {}		
		AAdd(oQuestao:oWSListaUnidade:oWSUnidade, QuestaoWSService_UnidadeWSHolder():New())
		oQuestao:oWSListaUnidade:oWSUnidade[1]:cCdUnidadePaiExterno  := cPai
		oQuestao:oWSListaUnidade:oWSUnidade[1]:cCdUnidadeFilhoExterno:= cFilho		
	
		AAdd(aQuestao, oQuestao)
		SQO->(DBSkip())
		oProcess:IncRegua2(STR0018 + " [" + AllTrim(Str(Len(aQuestao))) + "]")	//"Aguarde... Selecionando registros..."
	EndDo

	oProcess:SetRegua2(Len(aQuestao))
	
	For nCount:= 1 to Len(aQuestao)
		If (oProcess:lEnd); Return; EndIf
			
		oProcess:IncRegua2(aQuestao[nCount]:cCdExterno + " - " + aQuestao[nCount]:cPergunta)
		
		If !oWSQuestao:InsertQuestao(aQuestao[nCount])
			oProcess:SaveLog(STR0027 + " " + aQuestao[nCount]:cCdExterno + " - " + aQuestao[nCount]:cPergunta)	//"Nao foi possivel gravar a questao!"
			oProcess:SaveLog(GetWSCError())
		EndIF			
	Next
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} 


@author Rogerio Ribeiro da Cruz
@since 29/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function ProcServ(oProcess)
	Local oWSSrvCnt:= EPMWSNew("ServidorConteudo")		
	Local aSrvCnt := {}
	Local oSrvCnt, nCount
	
	DBSelectArea("RAT")
	DBSetOrder(1)
	DBGoTop()

	While !RAT->(Eof())	
		If (oProcess:lEnd); Return; EndIf
			
		oSrvCnt:= ServidorConteudoWSService_ServidorConteudoWSHolder():New()
		oSrvCnt:cCdExterno := RAT->RAT_CODIGO
		oSrvCnt:cDescricao := AllTrim(RAT->RAT_DESC)
		oSrvCnt:cServidorConteudo := AllTrim(RAT->RAT_OUTROS)
        oSrvCnt:cServidorGravacao := AllTrim(RAT->RAT_VIDEO)
        oSrvCnt:cServidorPosTeste := AllTrim(RAT->RAT_POSTES)
        oSrvCnt:cServidorPreTeste := AllTrim(RAT->RAT_PRETES)
        oSrvCnt:cServidorRts := AllTrim(RAT->RAT_SINCRO)
        
        AAdd(aSrvCnt, oSrvCnt)
        RAT->(DBSkip())
		oProcess:IncRegua2(STR0018 + " [" + AllTrim(Str(Len(aSrvCnt))) + "]")	//"Aguarde... Selecionando registros..."
	EndDo

	oProcess:SetRegua2(Len(aSrvCnt))
	
	For nCount := 1 To Len(aSrvCnt)
		If (oProcess:lEnd); Return; EndIf
			
		oProcess:IncRegua2(aSrvCnt[nCount]:cCdExterno + " - " + aSrvCnt[nCount]:cDescricao)
		
		If !oWSSrvCnt:InsertServidorConteudo(aSrvCnt[nCount])
			oProcess:SaveLog(STR0028 + " " + aSrvCnt[nCount]:cCdExterno + " - " + aSrvCnt[nCount]:cDescricao)	//"Não foi possível gravar o servidor de conteúdo!"
			oProcess:SaveLog(GetWSCError())
		EndIF			
	Next	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} 


@author Rogerio Ribeiro da Cruz
@since 29/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function ProcTopi(oProcess)
	Local oWSTopico := AMSWSNew("Topico")	
	Local aTopico	:= {}
	Local cLastEmp, cLastUnd := ""
	Local oTopico, nCount, nCountUni
	
	DBSelectArea("SX5")
	DBSetOrder(1)
	DBSeek(xFilial("SX5") + "R1")

	While !SX5->(EOF()) .AND.;
			SX5->X5_FILIAL == xFilial("SX5") .AND.;
			SX5->X5_TABELA == "R1"
		If (oProcess:lEnd); Return; EndIf

		oTopico								:= TopicoWSService_TopicoWSHolder():New()	
		oTopico:cCdPaiExterno 				:= FWGrpCompany()
		oTopico:cCdFilhoExterno 			:= AllTrim(SX5->X5_CHAVE)
		oTopico:cTitulo 					:= AllTrim(SX5->(X5Descri()))
		oTopico:cDescricao 					:= AllTrim(SX5->(X5Descri()))
		oTopico:nTipoTopico 				:= 0

		oTopico:oWSListaUnidade				:= TopicoWSService_ListaUnidadeWSHolder():New()
		oTopico:oWSListaUnidade:oWSUnidade  := {}

		// Disponibiliza unidades para o topico
		nCountUni := 0
		For nCount:= 1 to Len(aEmpresas)

			// Verifica Empresas
			If !Empty(aEmpresas[nCount, 3])
				If cLastEmp != aEmpresas[nCount, 3]
					nCountUni += 1
					AAdd(oTopico:oWSListaUnidade:oWSUnidade, TopicoWSService_UnidadeWSHolder():New())
					oTopico:oWSListaUnidade:oWSUnidade[nCountUni]:cCdUnidadePaiExterno   := aEmpresas[nCount, 1]
					oTopico:oWSListaUnidade:oWSUnidade[nCountUni]:cCdUnidadeFilhoExterno := aEmpresas[nCount, 3]
	
					cLastEmp := aEmpresas[nCount, 3]
				EndIf	
			EndIf
			
			// Verifica Unidades
			If !Empty(aEmpresas[nCount, 4])
				If cLastUnd != aEmpresas[nCount, 4]
					nCountUni += 1
					AAdd(oTopico:oWSListaUnidade:oWSUnidade, TopicoWSService_UnidadeWSHolder():New())
					oTopico:oWSListaUnidade:oWSUnidade[nCountUni]:cCdUnidadePaiExterno   := aEmpresas[nCount, 3]
					oTopico:oWSListaUnidade:oWSUnidade[nCountUni]:cCdUnidadeFilhoExterno := aEmpresas[nCount, 3] + aEmpresas[nCount, 4]
	
					cLastUnd := aEmpresas[nCount, 4]
				EndIf
			EndIf
	
			// Verifica Filiais
			If !Empty(aEmpresas[nCount, 5])
				nCountUni += 1	
				AAdd(oTopico:oWSListaUnidade:oWSUnidade, TopicoWSService_UnidadeWSHolder():New())
				If aEmpresas[nCount, 2] == aEmpresas[nCount, 5]
					oTopico:oWSListaUnidade:oWSUnidade[nCountUni]:cCdUnidadePaiExterno   := aEmpresas[nCount, 1]
					oTopico:oWSListaUnidade:oWSUnidade[nCountUni]:cCdUnidadeFilhoExterno := aEmpresas[nCount, 5]
				Else
					oTopico:oWSListaUnidade:oWSUnidade[nCountUni]:cCdUnidadePaiExterno   := aEmpresas[nCount, 3] + aEmpresas[nCount, 4]
					oTopico:oWSListaUnidade:oWSUnidade[nCountUni]:cCdUnidadeFilhoExterno := aEmpresas[nCount, 3] + aEmpresas[nCount, 4] + aEmpresas[nCount, 5]
				EndIf
			EndIf
		Next
		

		AAdd(aTopico, oTopico)								
		SX5->(DBSkip())
		oProcess:IncRegua2(STR0018 + " [" + AllTrim(Str(Len(aTopico))) + "]")	//"Aguarde... Selecionando registros..."
	EndDo
			
	oProcess:SetRegua2(Len(aTopico))
	
	For nCount := 1 To Len(aTopico)
		If (oProcess:lEnd); Return; EndIf
			
		oProcess:IncRegua2(aTopico[nCount]:cCdFilhoExterno + " - " + aTopico[nCount]:cDescricao)
		
		
		If !oWSTopico:InsertTopico(aTopico[nCount])
			oProcess:SaveLog(STR0029 + " " + aTopico[nCount]:cCdFilhoExterno + " - " + aTopico[nCount]:cDescricao)	//"Nao foi possivel gravar o tópico!"
			oProcess:SaveLog(GetWSCError())
		EndIF			
	Next	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} 


@author Rogerio Ribeiro da Cruz
@since 29/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function ProcTrei(oProcess)
	Local oWSTreinamento := EPMWSNew("Treinamento")
	Local oTreinamento, oConteudo, nCount
	Local aTreinamento   := {}
	Local cEmp          := ""
	Local cUni          := ""
	Local cFil          := ""
	Local cPai          := ""
	Local cFilho        := ""

	DBSelectArea("RAU")
	DBSetOrder(1)
	DBSelectArea("RAY")
	DBSetOrder(1)
	DBSelectArea("RA1")
	DBSetOrder(1)
	DBGoTop()

	While !RA1->(Eof())
		If (oProcess:lEnd); Return; EndIf
			
	    If RA1->RA1_TIPO != "L" .OR. ;
	    	!RAY->(DBSeek(xFilial("RAY", RA1->RA1_FILIAL) + RA1->RA1_CURSO))
			RA1->(DBSkip())
			Loop
		EndIf

		oTreinamento:= TreinamentoWSService_TreinamentoWSHolder():New()
		If Empty(RA1->RA1_FILIAL)
			oTreinamento:cCdExterno 			   := RA1->RA1_CURSO
		Else
			oTreinamento:cCdExterno 			   := RA1->RA1_FILIAL+RA1->RA1_CURSO
		EndIf	
		oTreinamento:cSigla 					   := AllTrim(RA1->RA1_DESC)
		oTreinamento:cTitulo 					   := AllTrim(RAY->RAY_DESCDT)
		oTreinamento:nSituacao 					   := Val(RAY->RAY_STATUS)
		oTreinamento:nPermissao 				   := 1
									
		oTreinamento:cCdAvaliacaoReacaoExterno 	   := xFilial("SQQ") + RAY->RAY_AVREAC 
		oTreinamento:cCdCertificadoExterno 		   := RAY->RAY_CERTIF
		oTreinamento:cCertificacao		 		   := ""    
			
		oTreinamento:cType 						   := "ASSINCRONO"	
		oTreinamento:cTexto1 					   := LimpaMemo( RAY->RAY_OBJCUR )
		oTreinamento:cTexto2 					   := LimpaMemo( RAY->RAY_PUBALV )
		oTreinamento:cTexto3 					   := LimpaMemo( RAY->RAY_CNTPRG )
		
		oTreinamento:cIdNavegadorScorm 			   := ""
		oTreinamento:cIdAlterarLessonStatus 	   := ""
		oTreinamento:cIdTotalTime 				   := ""
		oTreinamento:cIdLessonStatus 			   := ""
		oTreinamento:cIdScoreRaw 				   := ""

		oTreinamento:nScoreAprovacao			   := RAY->RAY_SCRAPV
		oTreinamento:cPeriodo 					   := fGetDuracao(RA1->RA1_DURACA, RA1->RA1_UNDURA)

		oTreinamento:nAprovacaoScorm			   := Val(RAY->RAY_CAPVSC)
		oTreinamento:nCargaHora 				   := Int(RA1->RA1_HORAS)
		oTreinamento:nCargaMinuto 				   := (RA1->RA1_HORAS - Int(RA1->RA1_HORAS)) * 100

		oTreinamento:cAutor 					   := ""
		oTreinamento:cCdAutorExterno 			   := "1"

		oTreinamento:cPreTestePreRequisito 		   := IIF(RAY->RAY_PREOBG  == "1", "Y", "N")
		oTreinamento:nScoreAprovacaoPre 		   := 0
		oTreinamento:cIdFinalizar 				   := ""
				
		// Montagem do Unidade
		//-----------------------------------		
		// Prepara relacionamento com unidade
		If Empty(RA1->RA1_FILIAL)
           cPai   := FWCodEmp() + FWunitBusiness() 
		   cFilho := FWCodFil()	
		else
			//Captura Empresa
			cEmp := substr(RA1->RA1_FILIAL, 1, nTamLayEmp)
			//Captura Unidade
			cUni := substr(RA1->RA1_FILIAL, nTamLayEmp+1, nTamLayUni)
			//Captura Filial
			cFil := substr(RA1->RA1_FILIAL, nTamLayEmp+nTamLayUni+1, nTamLayFil)
	        
			// Tratamento para Gestao de Empresas
	        //Identifica Pai-Filho para Filial SQ0
	        If nTamLayEmp > 0 .Or. nTamLayUni > 0
				If !Empty(cFil) .and. cFil <> Nil
					cPai   := cEmp+cUni
					cFilho := cEmp+cUni+cFil
				Else 
					If !Empty(cUni) .and. cUni <> Nil
						cPai   := cEmp
						cFilho := cEmp+cUni
					Else
						If !Empty(cEmp) .and. cEmp <> Nil
							cPai   := FWGrpCompany()
							cFilho := cEmp
						EndIf
					EndIf	
		        EndIf     
		   Else 
		   		cPai 	:= FWGrpCompany()
		   		cFilho	:= RA1->RA1_FILIAL
		   EndIf
	    EndIf    

			
		oTreinamento:oWSListaUnidade:= TreinamentoWSService_ListaUnidadeWSHolder():New()
		oTreinamento:oWSListaUnidade:oWSUnidade:= {}
		
		AAdd(oTreinamento:oWSListaUnidade:oWSUnidade, TreinamentoWSService_UnidadeWSHolder():New())
		oTreinamento:oWSListaUnidade:oWSUnidade[1]:cCdPaiExterno		:= cPai
		oTreinamento:oWSListaUnidade:oWSUnidade[1]:cCdFilhoExterno		:= cFilho
		oTreinamento:oWSListaUnidade:oWSUnidade[1]:cTipoUnidade			:= "1"
		//----------------------------------------------------------------------


		// Montagem do Conteudo
		oTreinamento:oWSListaConteudo:= TreinamentoWSService_ListaConteudoWSHolder():New()
		oTreinamento:oWSListaConteudo:oWSConteudo:= {}
            
		RAU->(DBSeek(xFilial("RAU", RA1->RA1_FILIAL) + RA1->RA1_CURSO))
		While !RAU->(EOF()) .AND.;
				xFilial("RAU", RA1->RA1_FILIAL) == RAU->RAU_FILIAL .AND.;
				RA1->RA1_CURSO 					== RAU->RAU_CURSO
			oConteudo				:= TreinamentoWSService_ConteudoWSHolder():New()
			oConteudo:cCdExterno 	:= RAU->RAU_CONTEU
			oConteudo:cPosicao		:= RAU->RAU_SEQUEN

			AAdd(oTreinamento:oWSListaConteudo:oWSConteudo, oConteudo)
			RAU->(DBSkip())
		EndDo
		
		AAdd(aTreinamento, oTreinamento)								
		RA1->(DBSkip())
		oProcess:IncRegua2(STR0018 + " [" + AllTrim(Str(Len(aTreinamento))) + "]")	//"Aguarde... Selecionando registros..."
	EndDo
	
	oProcess:SetRegua2(Len(aTreinamento))
	
	For nCount := 1 To Len(aTreinamento)
		If (oProcess:lEnd); Return; EndIf
			
		oProcess:IncRegua2(aTreinamento[nCount]:cCdExterno + " - " + aTreinamento[nCount]:cSigla)
		
		If !oWSTreinamento:InsertTreinamento(aTreinamento[nCount])
			oProcess:SaveLog(STR0030 + " " + aTreinamento[nCount]:cCdExterno + " - " + aTreinamento[nCount]:cSigla)	//"Nao foi possivel gravar o treinamento!"
			oProcess:SaveLog(GetWSCError())
		EndIF			
	Next
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} 


@author Rogerio Ribeiro da Cruz
@since 29/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function ProcUnid(oProcess)
	Local oWSEPMUnidade, oWSAMSUnidade, oEmpresa
	Local cLastGrp, cLastEmp, cLastUnd := ""
	Local nCount

	oProcess:SetRegua2(Len(aEmpresas))

	oWSEPMUnidade:= EPMWSNew("Unidade")
	oWSAMSUnidade:= AMSWSNew("Unidade")

	For nCount:= 1 to Len(aEmpresas)
		If (oProcess:lEnd); Return; EndIf
		
        // Atualiza Grupo (PAI)
		If cLastGrp != aEmpresas[nCount, 1]
			oEmpresa					:= UnidadeWSService_UnidadeWSHolder():New()
			oEmpresa:cDescricao			:= AllTrim(aEmpresas[nCount, 6])
			oEmpresa:cTitulo			:= AllTrim(aEmpresas[nCount, 6])
			oEmpresa:cCdFilhoExterno	:= aEmpresas[nCount, 1]
			oEmpresa:cCdPaiExterno		:= FWGrpCompany()
			oEmpresa:nTipoUnidade 		:= 0


			If !oWSEPMUnidade:InsertUnidade(oEmpresa)
				oProcess:SaveLog(STR0031 + " " + oEmpresa:cCdFilhoExterno + " - " + oEmpresa:cTitulo)	//"Não foi possivel gravar a empresa no EPM!"
				oProcess:SaveLog(GetWSCError())
			EndIf
			If !oWSAMSUnidade:InsertUnidade(oEmpresa)
				oProcess:SaveLog(STR0032 + " " + oEmpresa:cCdFilhoExterno + " - " + oEmpresa:cTitulo)	//"Não foi possivel gravar a empresa no AMS!"
				oProcess:SaveLog(GetWSCError())				
			EndIf
			
			cLastGrp := aEmpresas[nCount, 1]
		EndIf


		// Verifica Empresas
		If !Empty(aEmpresas[nCount, 3])
			If cLastEmp != aEmpresas[nCount, 3]
				oEmpresa					:= UnidadeWSService_UnidadeWSHolder():New()
				oEmpresa:cDescricao			:= AllTrim(aEmpresas[nCount, 7])
				oEmpresa:cTitulo			:= AllTrim(aEmpresas[nCount, 7])
				oEmpresa:cCdFilhoExterno	:= aEmpresas[nCount, 3]
				oEmpresa:cCdPaiExterno		:= aEmpresas[nCount, 1]
				oEmpresa:nTipoUnidade 		:= 1
				
				If !oWSEPMUnidade:InsertUnidade(oEmpresa)
					oProcess:SaveLog(STR0031 + " " + oEmpresa:cCdFilhoExterno + " - " + oEmpresa:cTitulo)	//"Não foi possivel gravar a empresa no EPM!"
					oProcess:SaveLog(GetWSCError())
				EndIf
		
				If !oWSAMSUnidade:InsertUnidade(oEmpresa)
					oProcess:SaveLog(STR0032 + " " + oEmpresa:cCdFilhoExterno + " - " + oEmpresa:cTitulo)	//"Não foi possivel gravar a empresa no AMS!"
					oProcess:SaveLog(GetWSCError())				
				EndIf 

				cLastEmp := aEmpresas[nCount, 3]
			EndIf	
		EndIf
		
		// Verifica Unidades
		If !Empty(aEmpresas[nCount, 4])
			If cLastUnd != aEmpresas[nCount, 4]
				oEmpresa					:= UnidadeWSService_UnidadeWSHolder():New()
				oEmpresa:cDescricao			:= AllTrim(aEmpresas[nCount, 7])
				oEmpresa:cTitulo			:= AllTrim(aEmpresas[nCount, 7])
				oEmpresa:cCdFilhoExterno	:= aEmpresas[nCount, 3] + aEmpresas[nCount, 4]
				oEmpresa:cCdPaiExterno		:= aEmpresas[nCount, 3]
				oEmpresa:nTipoUnidade 		:= 1
	
				If !oWSEPMUnidade:InsertUnidade(oEmpresa)
					oProcess:SaveLog(STR0031 + " " + oEmpresa:cCdFilhoExterno + " - " + oEmpresa:cTitulo)	//"Não foi possivel gravar a empresa no EPM!"
					oProcess:SaveLog(GetWSCError())
				EndIf
				If !oWSAMSUnidade:InsertUnidade(oEmpresa)
					oProcess:SaveLog(STR0032 + " " + oEmpresa:cCdFilhoExterno + " - " + oEmpresa:cTitulo)	//"Não foi possivel gravar a empresa no AMS!"
					oProcess:SaveLog(GetWSCError())				
				EndIf 

				cLastUnd := aEmpresas[nCount, 4]
			EndIf
		EndIf

		// Verifica Filiais
		If !Empty(aEmpresas[nCount, 5])

			oEmpresa						:= UnidadeWSService_UnidadeWSHolder():New()
			If aEmpresas[nCount, 2] == aEmpresas[nCount, 5]
				oEmpresa:cDescricao			:= AllTrim(aEmpresas[nCount, 7])
				oEmpresa:cTitulo			:= AllTrim(aEmpresas[nCount, 7])
				oEmpresa:cCdFilhoExterno	:= aEmpresas[nCount, 5]
				oEmpresa:cCdPaiExterno		:= aEmpresas[nCount, 1]
				oEmpresa:nTipoUnidade 		:= 1
			Else
				oEmpresa:cDescricao			:= AllTrim(aEmpresas[nCount, 7])
				oEmpresa:cTitulo			:= AllTrim(aEmpresas[nCount, 7])
				oEmpresa:cCdFilhoExterno	:= aEmpresas[nCount, 3] + aEmpresas[nCount, 4] + aEmpresas[nCount, 5]
				oEmpresa:cCdPaiExterno		:= aEmpresas[nCount, 3] + aEmpresas[nCount, 4]
				oEmpresa:nTipoUnidade 		:= 1
			EndIf


			oProcess:IncRegua2(oEmpresa:cCdPaiExterno + "/" + oEmpresa:cCdFilhoExterno + " - " + oEmpresa:cTitulo)
	        
			If !oWSEPMUnidade:InsertUnidade(oEmpresa)
				oProcess:SaveLog(STR0031 + " " + oEmpresa:cCdFilhoExterno + " - " + oEmpresa:cTitulo)	//"Não foi possivel gravar a empresa no EPM!"
				oProcess:SaveLog(GetWSCError())
			EndIf
			If !oWSAMSUnidade:InsertUnidade(oEmpresa)
				oProcess:SaveLog(STR0032 + " " + oEmpresa:cCdFilhoExterno + " - " + oEmpresa:cTitulo)	//"Não foi possivel gravar a empresa no AMS!"
				oProcess:SaveLog(GetWSCError())				
			EndIf
		EndIf
	Next
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} 


@author Rogerio Ribeiro da Cruz
@since 29/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function ProcUsua(oProcess)
	Local oWSUsuario:= EPMWSNew("Usuario")
	Local aUsuario := {}
	Local oUsuario, nCount
	Local cEmp     := ""
	Local cUni     := ""
	Local cFil     := ""
	Local cPai     := ""
	Local cFilho   := ""
	
	DBSelectArea("SRA")
	DBSetOrder(1)
	DBGoTop()	
	
	While !SRA->(Eof())
		If (oProcess:lEnd); Return; EndIf
		
		IF RA_SITFOLH == "D"
			SRA->(DBSkip())
			Loop
		EndIf
		
		oUsuario:= UsuarioWSService_UsuarioWSHolder():New()
		If Empty(SRA->RA_FILIAL)
			oUsuario:cCdExterno 	:= alltrim(SRA->RA_MAT)
    	Else
			oUsuario:cCdExterno 	:= SRA->RA_FILIAL + alltrim(SRA->RA_MAT)
		EndIf	    	
		oUsuario:cNome 				:= AllTrim(SRA->RA_NOME)
		oUsuario:cCpf 				:= AllTrim(SRA->RA_CIC)
		oUsuario:cEmail 			:= AllTrim(SRA->RA_EMAIL)
		oUsuario:cLogin 			:= AllTrim(SRA->RA_CIC)
		oUsuario:dDataNascimento 	:= SRA->RA_NASC
		oUsuario:cSexo 				:= SRA->RA_SEXO
		oUsuario:cRg 				:= AllTrim(SRA->RA_RG)
		oUsuario:cNomeMae 			:= AllTrim(SRA->RA_MAE)
                                                                                
		//------------------
		oUsuario:oWSListaUsuarioPerfil := UsuarioWSService_ListaUsuarioPerfilWSHolder():New()
		oUsuario:oWSListaUsuarioPerfil:oWSUsuarioPerfil := {}
		Aadd(oUsuario:oWSListaUsuarioPerfil:oWSUsuarioPerfil, UsuarioWSService_UsuarioPerfilWSHolder():New())
		oUsuario:oWSListaUsuarioPerfil:oWSUsuarioPerfil[1]:cCDUsuarioPerfilExterno 	:= ""

		//-----------------------------------		
		// Prepara relacionamento com unidade
		
		If Empty(SRA->RA_FILIAL)
			oUsuario:oWSListaUsuarioPerfil:oWSUsuarioPerfil[1]:cCDUsuarioExterno 	:= alltrim(SRA->RA_MAT)

           cPai   := FWCodEmp() + FWunitBusiness() 
		   cFilho := FWCodFil()	
		else
			oUsuario:oWSListaUsuarioPerfil:oWSUsuarioPerfil[1]:cCDUsuarioExterno 	:= SRA->RA_FILIAL + alltrim(SRA->RA_MAT)

			//Captura Empresa
			cEmp := substr(SRA->RA_FILIAL, 1, nTamLayEmp)
			//Captura Unidade
			cUni := substr(SRA->RA_FILIAL, nTamLayEmp+1, nTamLayUni)
			//Captura Filial
			cFil := substr(SRA->RA_FILIAL, nTamLayEmp+nTamLayUni+1, nTamLayFil)
	                    
			// Tratamento para Gestão de Emnpresas //
			If nTamLayEmp > 0.Or. nTamLayUni > 0
			
		        //Identifica Pai-Filho para Filial SQ0
				If !Empty(cFil) .and. cFil <> Nil
					cPai   := cEmp+cUni
					cFilho := cEmp+cUni+cFil
				Else 
					If !Empty(cUni) .and. cUni <> Nil
						cPai   := cEmp
						cFilho := cEmp+cUni
					Else
						If !Empty(cEmp) .and. cEmp <> Nil
							cPai   := FWGrpCompany()
							cFilho := cEmp
						EndIf
					EndIf	
	        	EndIf
	    	Else
	    		cPai 	:= FWGrpCompany()
	    		cFilho 	:= SRA->RA_FILIAL
	    	EndIf
        Endif
        
		oUsuario:oWSListaUsuarioPerfil:oWSUsuarioPerfil[1]:oWSListaUsuarioPerfilUnidade:= UsuarioWSService_ListaUsuarioPerfilUnidadeWSHolder():New()
		oUsuario:oWSListaUsuarioPerfil:oWSUsuarioPerfil[1]:oWSListaUsuarioPerfilUnidade:oWSUsuarioPerfilUnidade := {}

		Aadd(oUsuario:oWSListaUsuarioPerfil:oWSUsuarioPerfil[1]:oWSListaUsuarioPerfilUnidade:oWSUsuarioPerfilUnidade, UsuarioWSService_UsuarioPerfilUnidadeWSHolder():New())
		oUsuario:oWSListaUsuarioPerfil:oWSUsuarioPerfil[1]:oWSListaUsuarioPerfilUnidade:oWSUsuarioPerfilUnidade[1]:cCdUnidadeFilhoExterno			:= cFilho
		oUsuario:oWSListaUsuarioPerfil:oWSUsuarioPerfil[1]:oWSListaUsuarioPerfilUnidade:oWSUsuarioPerfilUnidade[1]:cCdUnidadePaiExterno				:= cPai
		oUsuario:oWSListaUsuarioPerfil:oWSUsuarioPerfil[1]:oWSListaUsuarioPerfilUnidade:oWSUsuarioPerfilUnidade[1]:cCdUsuarioPerfilExterno 			:= ""
		oUsuario:oWSListaUsuarioPerfil:oWSUsuarioPerfil[1]:oWSListaUsuarioPerfilUnidade:oWSUsuarioPerfilUnidade[1]:cCdUsuarioPerfilUnidadeExterno 	:= ""

		oUsuario:oWSUsuarioExtra := UsuarioWSService_UsuarioExtraWSHolder():New()
		oUsuario:oWSUsuarioExtra:cCdUsuarioExterno := ""
		//----------------------------------------------------------------------
 		
 		AAdd(aUsuario, oUsuario) 		
		SRA->(DBSkip())
		oProcess:IncRegua2(STR0018 + " [" + AllTrim(Str(Len(aUsuario))) + "]")	//"Aguarde... Selecionando registros..."
	EndDo
	
	oProcess:SetRegua2(Len(aUsuario))
	
	For nCount := 1 To Len(aUsuario)
		If (oProcess:lEnd); Return; EndIf
			
		oProcess:IncRegua2(aUsuario[nCount]:cCdExterno + " - " + aUsuario[nCount]:cNome)
		
		If !oWSUsuario:InsertUsuario(aUsuario[nCount])
			oProcess:SaveLog(STR0035 + " " + aUsuario[nCount]:cCdExterno + " - " + aUsuario[nCount]:cNome)	//"Nao foi possivel gravar o usuario!"
			oProcess:SaveLog(GetWSCError())
		EndIF			
	Next	
Return


Function TRMM090Opcoes()
	Local MvPar
	Local MvParDef := ""	
	Local aItems := {}	
	Local aArea := GetArea()
	
	MvPar := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	MvRet := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
	
	AAdd(aItems, "N - " + STR0005)		//"Unidade"
	AAdd(aItems, "T - " + STR0006)		//"Topico"
	AAdd(aItems, "Q - " + STR0007)		//"Questao"
	AAdd(aItems, "A - " + STR0008)		//"Avaliacao"
	AAdd(aItems, "S - " + STR0009)		//"Servidor de Conteudo"
	AAdd(aItems, "C - " + STR0010)		//"Conteudo"
	AAdd(aItems, "E - " + STR0011)		//"Certificado"
	AAdd(aItems, "R - " + STR0012)		//"Avaliacao de Reacao"
	AAdd(aItems, "I - " + STR0013)		//"Treinamento"
	AAdd(aItems, "U - " + STR0014)		//"Usuario"
	AAdd(aItems, "M - " + STR0015)		//"Matricula"

	MvParDef := "NTQASCERIUM"

	IF f_Opcoes(@MvPar, STR0017, aItems, MvParDef, 12, 49, .F.)  //	"Opções"
		&MvRet := MvPar                                                                          // Devolve Resultado
	EndIF	
	
	RestArea(aArea) 								 // Retorna Alias
Return MvParDef


//-------------------------------------------------------------------
/*/{Protheus.doc} 
@author Rogerio Ribeiro da Cruz
@since 29/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	aAdd(aRotina, {STR0016,	"TRMM090",	0, 3, 0, NIL})		//"Processar"
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} 
@author Rogerio Ribeiro da Cruz
@since 29/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
//Static Function FilialNotEmpty(cFilTmp)
//	Local cRet:= IIF(Empty(cFilTmp), FWCodFil(), cFilTmp)
//Return cRet

Static Function fTimeToMinutes(cTime)
	Local nHours
	Local nMinutes
	Local nReturn
	
	ExtractTime(cTime, @nHours, @nMinutes)
	
	nReturn:= (nHours * 60) + nMinutes
Return nReturn

Static Function fGetDuracao(nDuracao, cUnidade)
	Local nRet:= 1
	
	cUnidade:= AllTrim(cUnidade)
	
	Do Case
		Case (cUnidade == 'A' ); ( nRet := nDuracao * 365)
		Case (cUnidade == 'M' ); ( nRet := nDuracao * 30)
		Case (cUnidade == 'D' ); ( nRet := nDuracao )
	End Case
Return AllTrim(Str(nRet))

Static Function fFormatDate(dData)
	Local cRet:= Day2Str(dData) + "/" + Month2Str(dData) + "/" + Year2Str(dData)
Return cRet