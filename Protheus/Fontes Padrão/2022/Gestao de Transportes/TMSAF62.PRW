#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAF62.CH"
#INCLUDE "FWMVCDEF.CH"

Static lDocVge    := SuperGetMV("MV_DOCVGE",,.F.)
Static lTMSDCol   := SuperGetMv("MV_TMSDCOL",,.F.)
Static lTMSCTe    := SuperGetMv("MV_TMSCTE",.F.,.F.)
Static lCarMult   := SuperGetMv("MV_TMSCMUL",,.F.)
Static lLocaliza  := SuperGetMv("MV_LOCALIZ",.F.,"") == "S"
Static lMV_EmViag := SuperGetMV("MV_EMVIAG",,.F.)
Static cVeiGen    := SuperGetMv("MV_VEIGEN",,"") 
Static cOcorCan   := SuperGetMv("MV_OCORCAN",,"")
Static lMVTMSAloc := SuperGetMv("MV_TMSALOC",.F.,.T.)
Static lContDoc   := SuperGetMv("MV_CONTDOC",.F.,.F.)
Static lProduto   := .T.
Static lTMSItCt   := TmsUniNeg()
Static lAgdEntr   := TMSA018Agd()
Static lValFunc   := .T.
Static lTmsCFec   := TmsCFec()
Static lTmsExp    := TmsExp()
Static lSeekSeq   := .T.
Static lDocCarreg := .F.
Static lTMS3GFE   := TmsIntGFE('02')
Static lTmsRdpU	  := SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho
Static lRestRepom := SuperGetMV('MV_VSREPOM',,"1") == "2.2"
Static lIntTPR    := SuperGetMV("MV_ROTAINT",,.F.)  .And. AliasInDic("DMR")

/*{Protheus.doc} TMSAF62
Valida campos da viagem modelo 3
@type Static Function
@author Valdemar Roberto Mognon
@since 15/06/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function TMSAF62(cOrigem,cCampo)
Local lRet := .T.

Default cOrigem := ""
Default cCampo  := ReadVar()

If cOrigem == "DTQ"
	lRet := ValidDTQ(cOrigem)
ElseIf cOrigem == "DM3"
	lRet := ValidDM3(cCampo)
ElseIf cOrigem == "DTR"
	lRet := ValidDTR(cCampo)
ElseIf cOrigem == "DUP"
	lRet := ValidDUP(cCampo)
ElseIf cOrigem == "DVW"
	lRet := ValidDVW(cCampo)
ElseIf cOrigem == "DM4"
	lRet := ValidDM4(cCampo)	
ElseIf cOrigem == "DM5"
	lRet := ValidDM5(cCampo)	
ElseIf cOrigem == "DLD"
	lRet := ValidDLD(cCampo)	
ElseIf cOrigem $ "DM8|DJN"
	lRet := TMSAF62G(cOrigem,cCampo)		
EndIf

Return lRet

/*{Protheus.doc} ValidDTQ
Valida campos da DTQ
@type Static Function
@author Valdemar Roberto Mognon
@since 07/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function ValidDTQ(cOrigem)
Local lRet       := .T.
Local cCampo     := ReadVar()
Local oModel     := FwModelActive()
Local oModelDM3  := oModel:GetModel("MdGridDM3")

Default cOrigem  := "DTQ"

If AllTrim(cCampo) $ "M->DTQ_ROTA"
	lRet := VldRota(oModel,oModelDM3)
ElseIf AllTrim(cCampo) $ "M->DTQ_TPOPVG"
	lRet := VldTpOpVg()
ElseIf AllTrim(cCampo) $ "M->DTQ_SERTMS"
	lRet := TMSF62VSrv(oModel,oModelDM3)
ElseIf AllTrim(cCampo) $ "M->DTQ_TIPTRA"
	lRet := TMSF62VTra(oModel,oModelDM3)		
ElseIf AllTrim(cCampo) $ "M->DTQ_PAGGFE|M->DTQ_CDMUNO"
	lRet:= TMSAF62G(cOrigem,cCampo,oModel)
EndIf

Return lRet

/*{Protheus.doc} ValidDM3
Valida campos da DM3
@type Static Function
@author Valdemar Roberto Mognon
@since 07/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function ValidDM3(cCampo)
Local lRet       := .T.
Local cFilDoc    := ""
Local cDoc       := ""
Local cSerie     := ""
Local oModel     := FwModelActive()
Local oModelDM3  := oModel:GetModel("MdGridDM3")
Local nOpcx      := oModel:GetOperation()
Default cCampo   := ReadVar()

cFilDoc := oModelDM3:GetValue("DM3_FILDOC")
cDoc    := oModelDM3:GetValue("DM3_DOC")
cSerie  := oModelDM3:GetValue("DM3_SERIE")

If AllTrim(cCampo) $ "M->DM3_FILDOC:M->DM3_DOC:M->DM3_SERIE"
	lRet := VldDocto(oModelDM3,cCampo,cFilDoc,cDoc,cSerie,nOpcx)
ElseIf lRet .And. cCampo $ "M->DM3_SEQUEN"	
	lRet:= VldSeqDoc()  	
ElseIf lRet .And. cCampo $ "M->DM3_ORIGEM"	
	lRet:= VldOrigem()  	
EndIf

Return lRet

/*{Protheus.doc} ValidDTR
Valida campos da DTR
@type Static Function
@author Valdemar Roberto Mognon
@since 07/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ValidDTR(cCampo)
Local lRet      := .T.
Default cCampo  := ReadVar()
	 
If cCampo == 'M->DTR_CODVEI'
	lRet:= VldVeiDTR(cCampo)
ElseIf cCampo $ "M->DTR_QTDEIX"
	lRet:= VldEixDTR()
ElseIf cCampo $ 'M->DTR_QTEIXV'
	lRet:= VldEixVDTR()
ElseIf cCampo $ 'M->DTR_CODRB1.M->DTR_CODRB2.M->DTR_CODRB3'
	lRet:= VldRebqDTR(cCampo)
ElseIf cCampo $ "M->DTR_CREADI.M->DTR_LOJCRE"
	lRet:= VldFornec(1)
ElseIf cCampo $ "M->DTR_FORPDG.M->DTR_LOJPDG"
	lRet:= VldFornec(2)
ElseIf cCampo $ "M->DTR_FOROPE.M->DTR_LOJOPE"
	lRet:= VldFornec(3)
ElseIf cCampo $ "M->DTR_VALFRE"
	lRet:= VldFretDTR()  
ElseIf cCampo $ "M->DTR_CNPJPG"
	lRet:= VldCNPJDTR()
ElseIf cCampo $ "M->DTR_INSRET"
	lRet:= VldInsRet()
ElseIf cCampo $ "M->DTR_VALPDG"
	lRet:= VldValPdg()  
ElseIf cCampo $ "M->DTR_DTFVSG"
	lRet:= VldDTFVSg(cCampo)
EndIf


Return lRet

/*{Protheus.doc} ValidDUP
Valida campos da DUP
@type Static Function
@author Valdemar Roberto Mognon
@since 07/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function ValidDUP(cCampo)
Local lRet       := .T.
Local oModel     := FwModelActive()
Local oModelIDUP := oModel:GetModel("MdGridDUP")
Local nOpcx      := oModel:GetOperation()

Default cCampo := ReadVar()

If AllTrim(cCampo) $ "M->DUP_CODMOT"
	lRet := VldMotoris(oModelIDUP,nOpcx)
ElseIf AllTrim(cCampo) $ "M->DUP_DTFVSG"
	lRet:= VldDTFVSg(cCampo)
EndIf

Return lRet

/*{Protheus.doc} VldDocto
Valida campos M->DM3_FILDOC, M->DM3_DOC e M->DM3_SERIE
@type Static Function
@author Valdemar Roberto Mognon
@since 15/06/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function VldDocto(oModelDM3,cCampo,cFilDoc,cDoc,cSerie,nOpcx)
Local lRet       := .T.
Local lRetDTC    := .T.
Local lRetDY4    := .T.
Local lValida    := .T.
Local lMovtoVge  := .F.
Local lAchou     := .F.
Local lAchouDTX  := .F.
Local lExistDUH  := .T.
Local lBloqEnt   := .F.
Local cSeek      := ""
Local cSeekDUD   := ""
Local cSeekDTC   := ""
Local cSeekDUH   := ""
Local cCriRat    := ""
Local cFilDF8    := ""
Local cNumDF8    := ""
Local cBaiCol    := ""
Local cMunCol    := ""
Local cEstCol    := ""
Local cAgenRem   := ""
Local cAgenDes   := ""
Local cQuery     := ""
Local cAliasQry  := ""
Local aAreas     := {DT6->(GetArea()),DUD->(GetArea()),DTP->(GetArea()),DFV->(GetArea()),DT5->(GetArea()),DC5->(GetArea()),DUE->(GetArea()),;
					 DUL->(GetArea()),DYD->(GetArea()),DTC->(GetArea()),DY4->(GetArea()),DUH->(GetArea()),DTX->(GetArea()),DM3->(GetArea()),GetArea()}
Local aAreaAnt   := {}
Local aAreaDF1   := {}
Local aRegiao    := {}
Local aRegRot    := {}
Local aVgaColg   := {}
Local nCntFor1   := 0
Local bWhile     := {||.F.}
Local nLinha     := 0
Local nLinAnt    := 0
Local nQtdVol    := 0
Local cFilOri    := M->DTQ_FILORI
Local cViagem    := M->DTQ_VIAGEM
Local cRota      := M->DTQ_ROTA
Local lVgeExpr   := .F.
Local cZona      := ""
Local cSetor     := ""
Local lVgeAntiga := IsInCallStack("TMSA140") .OR. IsInCallStack("TMSA141") .OR. IsInCallStack("TMSA143");
					.OR. IsInCallStack("TMSA144") .OR. IsInCallStack("TMSA210")

Local nLinAtu    := 0
Local nAltViagem := 0
Local aValAgend  :={}
Local nRecDUD    := 0
Local lMDFEAUT   := SuperGetMv('MV_MDFEAUT',,.F.) .And. ExistFunc("TmsMDFeAut") //--MDFe Automático 

Default oModelDM3  := Nil
Default cCampo     := ""
Default cFilDoc    := ""
Default cDoc       := ""
Default cSerie     := ""
Default nOpcx      := 0

//-- Esta validacao destrava o documento quando escolhido um outro documento na viagem.
//-- Esta validacao é utilizada para quando é digitado o documento, quando é selecionado
//-- através do F3 o tratamento é feito na função TMSCTRC() no TMSXFUNA
If cCampo == "M->DM3_FILDOC"
		cSeek := oModelDM3:GetValue("DM3_FILDOC") + cDoc + cSerie
ElseIf cCampo == "M->DM3_DOC"
		cSeek := cFilDoc + oModelDM3:GetValue("DM3_DOC") + cSerie
ElseIf cCampo == "M->DM3_SERIE"
		cSeek := cFilDoc + cDoc + oModelDM3:GetValue("DM3_SERIE")
EndIf

//-- Se um dos campos estiverem vazios nao faz a procura nos arquivos
If (cCampo == "M->DM3_FILDOC" .And. (Empty(cDoc)    .Or. Empty(cSerie))) .Or. ;
   (cCampo == "M->DM3_DOC"    .And. (Empty(cFilDoc) .Or. Empty(cSerie))) .Or. ;
   (cCampo == "M->DM3_SERIE"  .And. (Empty(cFilDoc) .Or. Empty(cDoc)))
	lValida := .F.
EndIf

If lValida
	If nOpcx == 4
		nLinAtu   := oModelDM3:GetLine()
		nAltViagem:= TF64GetSt('nTipAltVia')
	EndIf

	//-- Posiciona no documento
	DT6->(DbSetOrder(1))
	DT6->(DbSeek(xFilial("DT6") + cSeek))
	
	//-- Posiciona no ultimo DUD do Documento
	nRecDUD:= TMSFPosDUD(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
	If nRecDUD > 0
		DUD->( DbGoTo( nRecDUD ))
	Else
		lRet:= .F.
	EndIf

	If !Empty(cFilDoc) .AND. !Empty(cDoc) .AND. !Empty(cSerie) .AND. Empty( FwFldGet("DTQ_SERTMS") ) .AND. Empty( FwFldGet("DTQ_ROTA") )
		Help( , , "TMSAF62", , STR0040, , , , , , , , { STR0041 } ) // "Campos Serv.Transp.(DTQ_SERTMS) e Rota(DTQ_ROTA) do cabeçalho não foram preenchidos." "Para adicionar corretamente os documentos é necessário informar os Campos Serv.Transp.(DTQ_SERTMS) e Rota(DTQ_ROTA)."
		lRet := .F.
	EndIf

	If FwFldGet("DTQ_TIPVIA") != StrZero(5,Len(DTQ->DTQ_TIPVIA)) .And. !Empty(DUD->DUD_NUMRED)
		Help("",1,"TMSAF6213")	//-- "Documentos em lote de redespacho somente podem ser carregados em viagem de redespacho."
		lRet := .F.
	EndIf
	
	If lRet .And. lContDoc
		lRet := TmsConTran(FwFldGet("DM3_FILDOC"),FwFldGet("DM3_DOC"),FwFldGet("DM3_SERIE"),.T.)
	EndIf
	
	If lRet .And. !lVgeAntiga
		If FwFldGet("DTQ_SERTMS") == "3"
			lBloqEnt := (FwFldGet("DTQ_STATUS") == StrZero(2,Len(DTQ->DTQ_STATUS)) .Or. FwFldGet("DTQ_STATUS") == StrZero(5,Len(DTQ->DTQ_STATUS)))
		EndIf

		If lBloqEnt .And. DUD->DUD_SERTMS != StrZero(1,Len(DUD->DUD_SERTMS)) .And. DUD->DUD_STATUS == StrZero(1,Len(DUD->DUD_STATUS)) .And. ;
		 	nAltViagem == 0  //-- Não deve bloquear se for processo de retirada de mercadoria não prevista
			Help("  ",1,"TMSA14425")
			lRet := .F. 
		EndIf
		If lRet
			If !Empty(DUD->DUD_VIAGEM) .And. DUD->DUD_VIAGEM <> FwFldGet("DTQ_VIAGEM")
				lRet	:= .F. 
				Help("",1,"TMSA21010",,cSeek,2,1)	//-- "Documento ja carregado
			EndIf 
		EndIf

		//Agendamento de Entrega
		If lRet .And. DUD->DUD_SERTMS == StrZero(3,Len(DUD->DUD_SERTMS))
			aValAgend := TMSAgdVgVl(DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE,dDataBase,SubStr(Time(),1,5) )
			If !aValAgend[1] 
				Help( ,, 'HELP',, aValAgend[2], 1, 0) 
				lRet := .F.
			EndIf
		EndIf		
	EndIf

	//-- Na inclusão de documentos valida viagem em transito
	If lRet
		DTP->(DbSetOrder(2))
		If DTP->(MsSeek(xFilial("DTP") + DT6->(DT6_FILORI + DT6_LOTNFC)))
	        //-- Viagem de entrega, status em transito e viagem com o mesmo do lote da viagem 
	        If DT6->DT6_SERTMS == StrZero(3,Len(DT6->DT6_SERTMS)) .And. FwFldGet("DTQ_STATUS") == "2" .And. DTP->DTP_TIPLOT <> "5"
				If DTP->DTP_VIAGEM != FwFldGet("DTQ_VIAGEM")
	            	Help("",1,"TMSA21067")	//-- Para viagens em trânsito, só é permitido incluir documentos que tenham sido gerados em lotes vinculados à Viagem, ou seja, o campo Viagem (DTP_VIAGEM) deve estar preenchido com o mesmo número da viagem em que o documento está sendo inserido!
	            	lRet := .F.
				Else
					aAreaAnt := GetArea()
					lRet := Tm350Apoio(FwFldGet("DTQ_FILORI"),FwFldGet("DTQ_VIAGEM"))
					RestArea(aAreaAnt)
				EndIf	
			EndIf			
		EndIf
	EndIf

	//-- Verifica se o documento de coleta é com criterio de Rateio
	If lRet
		If lTMSItCt .And. !Empty(FwFldGet("DTQ_ROTA")) .And. !F11RotRote(FwFldGet("DTQ_ROTA"))
			If DT6->DT6_SERTMS == StrZero(1,Len(DT6->DT6_SERTMS))
				If !Empty(DT6->DT6_CODNEG) .And. !Empty(DT6->DT6_SERVIC)  
					cCriRat := TMSAF62DcR(DT6->DT6_NCONTR,DT6->DT6_CODNEG,DT6->DT6_SERVIC)
					If cCriRat == "A"	//-- "A" = Origem/Destino Vge
						Help("",1,"TMSAF6201",,STR0008 + ": " + cCriRat + "=" + TMSValField("cCriRat",.F.),3,0) //-- "Documentos com este criterio de rateio, não podem ser vinculados a uma Rota por Cep/Cliente. Critério de rateio: "
						lRet := .F.
					EndIf								
				EndIf
			EndIf
		EndIf
	EndIf

	//-- Valida se o docto é de Redespacho e se o Status do DT6 esta diferente de 1-aberto ou 5-Chegada em Filial.
	If lRet .And. !lVgeAntiga
		DFV->(DbSetOrder(2))          
		If DFV->(DbSeek(xFilial("DFV") + cSeek)) .And. DFV->DFV_STATUS != StrZero(1,Len(DFV->DFV_STATUS))
			If !(DT6->DT6_STATUS == StrZero(1,Len(DT6->DT6_STATUS)) .Or. DT6->DT6_STATUS == StrZero(5,Len(DT6->DT6_STATUS)))
				Help(" ", 1, "TMSA21024") //"Documento com Status diferente de","1-Aberto ou 5-Chegada em Filial"
				lRet := .F.
		   EndIf
		EndIf
	EndIf

	//-- Localiza movimento de viagem para o documento (DUD)
	If lRet .And. !lVgeAntiga
		cSeekDUD += (cSeek + Iif(lTMSDCol,"",cFilAnt))
		lMovtoVge := .F.
		
		DUD->(DbSetOrder(1))
		If !DUD->(MsSeek(xFilial("DUD") + cSeekDUD))
			cSeekDUD := cSeek + Iif(lTMSDCol,"",cFilOri)
			DUD->(MsSeek(xFilial("DUD") + cSeekDUD))
		EndIf

		While !DUD->(Eof()) .And. DUD->(DUD_FILIAL + DUD_FILDOC + DUD_DOC + DUD_SERIE) + Iif(lTMSDCol,"",DUD->DUD_FILORI) == xFilial("DUD") + cSeekDUD
			
			lMovtoVge := .T.
			
			If lCarMult .And. DUD->DUD_SERTMS != StrZero(1,Len(DUD->DUD_SERTMS))	//-- Carrega coleta em viagem de entrega com servico adicional
				If (!Empty(DUD->DUD_VIAGEM) .And. DUD->(DUD_FILORI + DUD_VIAGEM) != cFilOri + cViagem ) .Or. DUD->DUD_STATUS != StrZero(1,Len(DUD->DUD_STATUS))
					DUD->(DbSkip())
					Loop
				EndIf
			Else
				If (DUD->DUD_SERTMS != FwFldGet("DTQ_SERTMS") .And. DUD->DUD_SERTMS != "1") .Or. (DUD->DUD_TIPTRA != FwFldGet("DTQ_TIPTRA")) .Or. ;
				   (!Empty(DUD->DUD_VIAGEM) .And. DUD->(DUD_FILORI + DUD_VIAGEM) != cFilOri + cViagem .And. !lVgeExpr) .Or. ;
				   (DUD->DUD_STATUS != StrZero(1,Len(DUD->DUD_STATUS)) .And. !lVgeExpr)
					DUD->(DbSkip())
					Loop
				EndIf
			EndIf			

			If DUD->DUD_STATUS != StrZero(1,Len(DUD->DUD_STATUS))	//-- Em Aberto
				Help("",1,"TMSA21010",,cSeek,2,1)	//-- "Documento ja carregado
				lRet := .F.
			EndIf				

			DC5->(dbSetOrder(1))
			If !Empty(DUD->DUD_SERVIC) .And. DC5->(!MsSeek(xFilial("DC5") + DUD->DUD_SERVIC))
				Help("",1,"TMSA21012",,cSeek,2,1)	//-- Erro ao localizar serviço operacional
				lRet := .F.
			EndIf			

			//-- Ajusta DUD quando servico ou tipo de transporte sao diferentes
			If lRet
				If DUD->DUD_SERTMS != FwFldGet("DTQ_SERTMS") .Or. DUD->DUD_TIPTRA != FwFldGet("DTQ_TIPTRA")
					If DUD->DUD_SERTMS != StrZero(1,Len(DUD->DUD_SERTMS))	//-- Coleta sendo inserida em viagem de entrega com servico adicional
						lRet := .F.
					EndIf	
				EndIf
			EndIf
			
			//-- Verifica se o documento pertence a rota informada
			If lRet
				If FwFldGet("DTQ_SERTMS") != StrZero(2,Len(DC5->DC5_SERTMS)) .And. ;
					!TMSAF62DPC(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE) .And. ;
					!TMSAF62DA7(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,,,@cZona,@cSetor)
					lRet := .F.
				EndIf
			EndIf

			If lRet
				If FwFldGet("DTQ_SERTMS") == StrZero(2,Len(DC5->DC5_SERTMS))	//-- Transporte
					If TmsVgeMod3() .Or. (lDocVge .And. DUD->DUD_GERROM == StrZero(2,Len(DUD->DUD_GERROM)))	//-- Nao gera romaneio.
						//-- Passamos Regiao de Calculo pois se nao sofreu alteracao e a mesma da regiao de destino,
						//-- se alterar precisamos sempre considerar a Regiao de Calculo
						aRegiao := TMSNivSup(DUD->DUD_CDRCAL)	//-- Obtem os niveis superiores da regiao de destino.

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Retorna as Regioes / Filiais de Destino da Rota                       ³
						//³ Elementos contidos por dimensao:                                      ³
						//³ 1. Regiao Origem da Rota                                              ³
						//³ 2. Regioes de Destino da Rota                                         ³
						//³ 3. Filiais de Destino da Rota                                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
						aRegRot := TMSRegDes(cRota)	//-- Obtem as regioes da rota.

						For nCntFor1 := 1 To Len(aRegiao)
							//-- Verifica se a regiao de destino do CTRC pertence a regiao da rota.
							lAchou := Ascan(aRegRot,{|x| x[2] == aRegiao[nCntFor1]}) > 0
							If lAchou
								Exit
							EndIf
						Next nCntFor1

						If lAchou
				  			oModelDM3:LoadValue("DM3_STROTA","1")
						Else											
							oModelDM3:LoadValue("DM3_STROTA","3")
						EndIf
					EndIf
				EndIf			
			EndIf
			Exit
		EndDo		

		If lRet		
			If !lMovtoVge
				If !IsInCallStack ("TMSA144NFC")
	  				Help("",1,"TMSA21011",,cSeek,2,18)	//-- "Erro ao localizar movimento de viagem para o documento
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf		

	//-- Nao permite selecionar dois documentos simultanemanete em duas programações de carregamento
	If lRet .AND. !IsInCallStack("TMSA146EFT")
	
		//-- Posiciona no documento
		DT6->(DbSetOrder(1))
		DT6->(MsSeek(xFilial("DT6") + cSeek))
		DbSelectArea("DF8")
		lRet := TMSA146Prg(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,@cFilDF8,@cNumDF8)
		If !lRet
			Help("",1,"TMSA21061",,cFilDF8 + ' - ' + cNumDF8 ,2,18) // Documento já está em uma Programação de Carregamento: 	
			lRet := .F.
		EndIf

        If lRet .And. lIntTPR .And. FindFunction('T146DocTPR') 
			lRet:= T146DocTPR(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
		EndIf

    EndIf

	If lRet
		If DUD->DUD_SERTMS == StrZero(1,Len(DUD->DUD_SERTMS))	//-- Coleta inserida em viagem de entrega com servico adicional
			If DT6->DT6_BLQDOC == "1"
				Help("",1,"TMSA21003")	//-- Documento Bloqueado ...
				lRet := .F.
			EndIf


			//-- Atualiza campos da tela
			If lRet
				//-- Posiciona na ordem de coleta
				DT5->(DbSetOrder(1))
				DT5->(MsSeek(xFilial("DT5") + cSeek))

				//-- Posiciona no solicitante    
				DUE->(DbSetOrder(1))
				DUE->(MsSeek(xFilial("DUE") + DT5->DT5_CODSOL))

				//-- Obtem o endereco da coleta
				If Empty(DT5->DT5_SEQEND)
					cBaiCol := DUE->DUE_BAIRRO
					cMunCol := DUE->DUE_MUN
					cEstCol := DUE->DUE_EST
				Else
					DUL->(dbSetOrder(3))
					DUL->(MsSeek(xFilial("DUL") + DT5->(DT5_CODSOL + DT5_SEQEND)))
					cBaiCol := DUL->DUL_BAIRRO
					cMunCol := DUL->DUL_MUN
					cEstCol := DUL->DUL_EST
				EndIf

				If lTmsCFec
					aAreaDF1 := DF1->(GetArea())
					DF1->(DbSetOrder(3))
					If DF1->(MsSeek(xFilial("DF1") + DT5->(DT5_FILDOC + DT5_DOC + DT5_SERIE))) .And. !Empty(DF1->DF1_DOC)
						cAgenRem := Posicione("SA1",1,xFilial("SA1") + DF1->(DF1_CLIREM + DF1_LOJREM),"A1_NREDUZ")      
						cAgenDes := Posicione("SA1",1,xFilial("SA1") + DF1->(DF1_CLIDES + DF1_LOJDES),"A1_NREDUZ")
					EndIf
					RestArea(aAreaDF1)
				EndIf
			EndIf
		EndIf		
    EndIf

	//-- Se for documento de Devolucao, posiciona na tabela DY4 para achar os vínculos entre DT6 X DTC      
	If lRet
		If DUD->DUD_SERTMS != StrZero(1,Len(DUD->DUD_SERTMS))
			cSeekDTC := cSeek                                                                  
			If !TmsPsqDY4(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
				DTC->(DbSetOrder(3))
		   		lRetDTC := DTC->(MsSeek(xFilial("DTC") + cSeekDTC))   			
		   	Else
		   		DY4->(DbSetOrder(1))
				lRetDY4 := DYE->(MsSeek(xFilial("DY4") + cSeekDTC))		
			Endif
			
			If lRetDTC
				If !(DTC->DTC_SERIE != 'PED' .And. !Empty(DTC->DTC_DOC))		
					lRet := .F.
				Endif		
			Elseif lRetDY4
				If !(DY4->DY4_SERIE != 'PED' .And. !Empty(DY4->DY4_DOC))
					lRet := .F.
				Endif
			Else
				lRet := .F.	
			Endif	
			
			If lRet
				If DT6->DT6_BLQDOC == "1"
					Help("",1,"TMSA21003") // Documento Bloqueado ...
					lRet := .F.
				ElseIf DT6->DT6_PRIPER == "1"
					Help("",1,"TMSA21004") // Este Documento nao podera ser carregado pois esta configurado como sendo de 1o. percurso
					lRet := .F.
				EndIf
	
				If lRet			
					If lRetDTC
						lExistDUH := .F.
						nLinAnt := oModelDM3:GetLine()
						While DTC->(!Eof()) .And. DTC->(DTC_FILIAL + DTC_FILDOC + DTC_DOC + DTC_SERIE) == xFilial("DTC") + cSeekDTC 					
			
							cSeekDUH := cFilAnt + DTC->(DTC_NUMNFC + DTC_SERNFC + DTC_CLIREM + DTC_LOJREM + DTC_CODPRO)
							bWhile	:= {|| DUH->(!Eof() .And. DUH->(DUH_FILORI + DUH_NUMNFC + DUH_SERNFC + DUH_CLIREM + DUH_LOJREM + DUH_CODPRO) == cSeekDUH)}
			
							DUH->(DbSetOrder(1))
							If MsSeek(xFilial("DUH") + cSeekDUH) .And. DUH->DUH_STATUS == StrZero(1,Len(DUH->DUH_STATUS))
								lExistDUH := .T.
								While Eval(bWhile)
									lAchou := oModelDM3:SeekLine({{"DM3_FILDOC",SubStr(cSeek,1,TamSx3("DTA_FILDOC")[1])},;
																   {"DM3_DOC",SubStr(cSeek,TamSx3("DTA_FILDOC")[1] + 1,TamSx3("DTA_DOC")[1])},;
																   {"DM3_SERIE",SubStr(cSeek,TamSx3("DTA_FILDOC")[1] + TamSx3("DTA_DOC")[1] + 1,TamSx3("DTA_SERIE")[1])}})
									If lAchou .Or. (DUH_STATUS != "1")
										nLinha := oModelDM3:GetLine()
										If nLinha != oModelDM3:Length()
											DUH->(DbSkip())
											Loop
										EndIf
									EndIf
	
									
									aRegiao := TMSNivSup(DUD->DUD_CDRCAL)
									
									For nCntFor1 := 1 To Len(aRegiao)
										//-- Verifica se a regiao de destino do CTRC pertence a regiao da rota.
										lAchou := Ascan(aRegRot, {|x| x[2] == aRegiao[nCntFor1]}) > 0
										If lAchou
											Exit
										EndIf
									Next nCntFor1
									
									If lAchou
										oModelDM3:LoadValue("DM3_STROTA","1")
									Else
										oModelDM3:LoadValue("DM3_STROTA","3")
									EndIf							
									DUH->(DbSkip())
								EndDo
								
							EndIf
							DTC->(DbSkip())
						EndDo
						oModelDM3:GoLine(nLinAnt)
					ElseIf lRetDY4
						lExistDUH := .F.
						nLinAnt := oModelDM3:GetLine()
						While DY4->(!Eof()) .And. DY4->(DY4_FILIAL + DY4_FILDOC + DY4_DOC + DY4_SERIE) == xFilial("DTC") + cSeekDTC 					
			
							If lProduto
								cSeekDUH := cFilAnt + DY4->(DY4_NUMNFC + DY4_SERNFC + DY4_CLIREM + DY4_LOJREM + DY4_CODPRO)
								bWhile	:= {|| DUH->(!Eof() .And. DUH->(DUH_FILORI + DUH_NUMNFC + DUH_SERNFC + DUH_CLIREM + DUH_LOJREM + DUH_CODPRO) == cSeekDUH)}
							Else
								cSeekDUH := cFilAnt + DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM
								bWhile	:= {|| DUH->(!Eof() .And. DUH->(DUH_FILORI + DUH_NUMNFC + DUH_SERNFC + DUH_CLIREM + DUH_LOJREM == cSeekDUH))}
							EndIf
			
							DUH->(DbSetOrder(1))
							If MsSeek(xFilial("DUH") + cSeekDUH) .And. DUH->DUH_STATUS == StrZero(1,Len(DUH->DUH_STATUS))
								lExistDUH := .T.
								While Eval(bWhile)
									lAchou := oModelDM3:SeekLine({{"DM3_FILDOC",SubStr(cSeek,1,TamSx3("DTA_FILDOC")[1])},;
																   {"DM3_DOC",SubStr(cSeek,TamSx3("DTA_FILDOC")[1] + 1,TamSx3("DTA_DOC")[1])},;
																   {"DM3_SERIE",SubStr(cSeek,TamSx3("DTA_FILDOC")[1] + TamSx3("DTA_DOC")[1] + 1,TamSx3("DTA_SERIE")[1])}})
									If lAchou .Or. (DUH_STATUS != "1")
										nLinha := oModelDM3:GetLine()
										If nLinha != oModelDM3:Length()
											DUH->(DbSkip())
											Loop
										EndIf
									EndIf
	
									
									aRegiao := TMSNivSup(DUD->DUD_CDRCAL)
									
									For nCntFor1 := 1 To Len(aRegiao)
										//-- Verifica se a regiao de destino do CTRC pertence a regiao da rota.
										lAchou := Ascan(aRegRot, {|x| x[2] == aRegiao[nCntFor1]}) > 0
										If lAchou
											Exit
										EndIf
									Next nCntFor1
									
	
									If lAchou
										oModelDM3:LoadValue("DM3_STROTA","1")
									Else
										oModelDM3:LoadValue("DM3_STROTA","3")
									EndIf							
	
									DUH->(DbSkip())
								EndDo
							EndIf
							DY4->(DbSkip())
						EndDo
						oModelDM3:GoLine(nLinAnt)
					EndIf
				EndIf
	
				If lRet
					If !lExistDUH
						//-- Verificando os Produtos da Nota Fiscal para obter a Qtde. de Volumes
						If  !TmsPsqDY4(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)	
							DTC->(DbSetOrder(3))
							If DTC->(MsSeek(xFilial("DTC") + cSeekDTC))
								While DTC->(!Eof()) .And. DTC->(DTC_FILIAL + DTC_FILDOC + DTC_DOC + DTC_SERIE) == xFilial("DTC") + cSeekDTC
									nQtdVol += DTC->DTC_QTDVOL
									DTC->(DbSkip())
								EndDo
								If DT6->DT6_DOCTMS == "K"	//-- Carregamento em Partes
									nQtdVol := nQtdVol - (DT6->DT6_VOLORI - DT6->DT6_QTDVOL)
			
								EndIf
							EndIf
						Else
							DY4->(DbSetOrder(1))
							If DY4->(MsSeek(xFilial("DTC") + DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)))
								While DY4->(!Eof()) .And. DY4->(DY4_FILIAL + DY4_FILDOC + DY4_DOC + DY4_SERIE) == xFilial("DY4") + cSeekDTC
									nQtdVol += DY4->DY4_QTDVOL
									DY4->(DbSkip())
								EndDo
								If DT6->DT6_DOCTMS == "K"	//-- Carregamento em Partes
									nQtdVol := nQtdVol - (DT6->DT6_VOLORI - DT6->DT6_QTDVOL)
								EndIf
							EndIf	
						Endif	
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet
		If nOpcx == 4 .And. FwFldGet("DTQ_STATUS") != StrZero(2,Len(DTQ->DTQ_STATUS)) .and. FwFldGet("DTQ_STATUS") != StrZero(4,Len(DTQ->DTQ_STATUS))	//-- Alteracao e status da viagem diferente de em transito / Chegada em filial
			DTX->(DbSetOrder(3))
			aVgaColg := TMSAF62Col(cFilOri,cViagem,@lMdfeAut)
			For nCntFor1 := 1 To Len(aVgaColg)	
				If DTX->(MsSeek(xFilial("DTX") + aVgaColg[nCntFor1,1] + aVgaColg[nCntFor1,2]))		
					lAchouDTX := .T.
					Exit
				EndIf						
			Next nCntFor1
			
			//-- Verifica se ha manifesto 
			//-- Verifica se a Região de origem e destino dos documetos da viagem alterada pertence a mesma UF de origem e destino.
			//-- Caso pertença, deverá mostrar um help informando.
			//-- Nesta verificação também está contemplando as viagens coligadas.	
			//-- ADD: Com Mdf-e Automático, não executará esta validação, pois obrigará no fechamento ou saída de viagem
			If	lAchouDTX .And. !lMdfeAut 
				//-- Verifica DUD DIPONIVEL PARA MANIFESTAR	
				cAliasQry := GetNextAlias()
				cQuery := " SELECT COALESCE(COUNT(DUD.DUD_MANIFE), 0) QTD_DISPON "		
				cQuery += "   FROM " + RetSQLName("DUD") + " DUD "
				cQuery += "  INNER JOIN " + RetSQLName("DTX") + " DTX "
				cQuery += " 	ON DTX_VIAGEM = DUD.DUD_VIAGEM "	
				cQuery += "  INNER JOIN " + RetSQLName("DTR") + " DTR "
				cQuery += "     ON DTR.DTR_VIAGEM = DUD.DUD_VIAGEM "
				cQuery += "	 WHERE DTX_FILIAL = '" + xFilial("DTX") +"'"	
				cQuery += "    AND DTX_FILMAN = '" + cFilAnt  + "' "	
				cQuery += "    AND DTX_FILORI = '" + cFilori  + "' "
				cQuery += "    AND (DTR.DTR_VIAGEM = '" + cViagem  + "' "
				For nCntFor1 := 1 To Len(aVgaColg)	//-- Verifica as viagens coligadas,a Principal + Coligada.		
					If aVgaColg[nCntFor1,3] = .F. 
						cQuery += "   OR DTR.DTR_VIAGEM = '" + aVgaColg[nCntFor1,2]  + "' "	//-- Coligada	
					Else
						cQuery += "   OR DTR.DTR_VIAGEM = '" + aVgaColg[nCntFor1,2]  + "' "	//-- Principal
					EndIf					
				Next nCntFor
				cQuery += ")"
				cQuery += "    AND DTR.D_E_L_E_T_ =  ' ' "			
				cQuery += "    AND DTX_TIPMAN =  '2'  "
				cQuery += "    AND DTX_IDFMDF <> '132'"	
				cQuery += "    AND DUD.DUD_MANIFE <> ' ' "	
				cQuery += "    AND DTX.D_E_L_E_T_ =  ' ' "
				cQuery += "    AND DUD.D_E_L_E_T_ =  ' ' "
				cQuery += "    AND NOT EXISTS "
				cQuery += "(SELECT DUD_DOC   "
				cQuery += "   FROM " + RetSQLName("DUD") "
				cQuery += "  WHERE DUD_FILIAL = '" + xFilial("DUD") +"'"	
				cQuery += "    AND DUD_FILDOC = '" +  GDFieldGet('DM3_FILDOC',n)+ "' "	
				cQuery += "    AND DUD_DOC    = '" +  GDFieldGet('DM3_DOC',n)   + "' "
				cQuery += "    AND DUD_SERIE  = '" +  GDFieldGet('DM3_SERIE',n) + "' "
				cQuery += "    AND DUD_MANIFE = '' "
				cQuery += "    AND (DUD_CDRDES = DUD.DUD_CDRDES OR DUD_FILDCA = DUD.DUD_FILDCA)"		
				cQuery += "    AND D_E_L_E_T_ =  ' ' ) "				
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)		
					
				//-- Verifica DUD DIPONIVEL PARA MANIFESTAR		
				If (cAliasQry)->QTD_DISPON == 0
					Help("",1,"TMSA21064")  
					lRet := .F.	
				EndIf		
				(cAliasQry)->(DbCloseArea())	
			EndIf
		EndIf
    EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

FwFreeArray(aAreaAnt)
FwFreeArray(aAreaDF1)
FwFreeArray(aRegiao)
FwFreeArray(aRegRot)
FwFreeArray(aVgaColg)

Return lRet

/*{Protheus.doc} VldRota
Valida campo M->DTQ_ROTA
@author Katia
@since 22/06/2020
@version version
*/
Static Function VldRota(oModel,oModelDM3)
Local lRet       := .T.
Local cCdrOri    := ""
Local nCntFor    := 0
Local lContinua  := .T.
Local aSaveLine	 := FWSaveRows()
Local aAreas   	 := {DT6->(GetArea()),DA8->(GetArea()),DTX->(GetArea()),DTA->(GetArea()),GetArea()}
Local lAllRot    := .T. 
Local cZona      := ""
Local cSetor     := ""
Local oMdlFldDTQ := oModel:GetModel("MdFieldDTQ")
Local lRotaAlt   := .F.
Local nLinha     := oModelDM3:GetLine()
Local cChave     := ""
Local aFilDca    := {}
Local nSeek      := 0
Local aRegiao    := {}
Local aRegRot    := {}
Local nElemento  := 0
Local cFiltraDA8 := ""
Local bFiltraBrw 
Local aIndexDA8 := {}


If Empty(M->DTQ_ROTA)
	lRet     := .T.
	lContinua:= .F.
Else
	lRet := ExistCpo("DA8",M->DTQ_ROTA,1)
EndIf

//----  Valida se houve alteração de Rota
If oMdlFldDTQ:IsFieldUpdate('DTQ_ROTA')	
	If !oModelDM3:IsEmpty() 	
		lRotaAlt:= .T.
	EndIf
EndIf

If lRet .And. lContinua
cFiltraDA8 := MntFilRot(M->DTQ_SERTMS,M->DTQ_TIPTRA,M->DTQ_ROTA, M->DTQ_ROTA,M->DTQ_ROTA, M->DTQ_ROTA, lallRot, .T.)

bFiltraBrw := {|| FilBrowse("DA8",@aIndexDA8,@cFiltraDA8) }
Eval(bFiltraBrw)

	If !lAllRot
		cCdrOri := Padr(GetMv("MV_CDRORI",,""),Len(DA8->DA8_CDRORI))
	EndIf
	DA8->(DbSetOrder(1))
	DA8->(MsSeek(xFilial("DA8")+M->DTQ_ROTA))
	If DA8->DA8_SERTMS != M->DTQ_SERTMS .Or. DA8->DA8_TIPTRA != M->DTQ_TIPTRA
		Help(' ', 1, 'TMSA14403') //"Rota não pertence ao Serviço de Transporte e ou Tipo de Transporte da viagem"
		lRet := .F.
	ElseIf !lAllRot .And. DA8->DA8_CDRORI != cCdrOri 
		Help(' ', 1, 'TMSA14404',,cCdrOri,2,1) //"Rota não pertence a região de origem: "
		lRet := .F.
	ElseIf DA8->DA8_ATIVO == StrZero(2,Len(DA8->DA8_ATIVO))
		Help(' ', 1, 'TMSA14405',,DA8->DA8_COD,3,1) //"Rota não está ativa no Cadastro de Rotas: "
		lRet := .F.
	EndIf

	If lRet
		If FwFldGet("DTQ_SERTMS") == StrZero(2,Len(DC5->DC5_SERTMS))	//-- Transporte
			//-- Alteracoes de rotas sao permitidas somente na filial de origem
			If	FwFldGet("DTQ_FILORI") != cFilAnt
				Help("",1,"TMSA14021")	//-- Alteracao da rota permitida somente na filial de origem da viagem
				lRet := .F.
			EndIf

			//-- Verifica se ha manifesto
			If lRet
				DTX->(DbSetOrder(3))
				If DTX->(MsSeek(cChave := xFilial("DTX") + FwFldGet("DTQ_FILORI") + FwFldGet("DTQ_VIAGEM")))
					//-- Permite alterar a rota de uma viagem manifestada, somente se essa rota contemplar todas as filiais de 
					//-- descarga do manifesto
					//-- Obtem as filiais de descarga da rota
					aFilDca := TMSRegDca(M->DTQ_ROTA)
					nSeek   := 0
					//-- Avalia todos os manifestos da viagem
					While DTX->(!Eof() .And. DTX->(DTX_FILIAL + DTX_FILORI + DTX_VIAGEM) == cChave)
						nSeek := AScan(aFilDca,{|x| x[3] == DTX->DTX_FILDCA})
						If	nSeek <= 0
							Exit
						EndIf
						DTX->(DbSkip())
					EndDo
					//-- A rota nao atende uma das filiais de descarga do manifesto
					If	nSeek <= 0
						Help("",1,"TMSA14020")	//-- Ha manifesto de carga para esta viagem
						lRet := .F.
					EndIf
				EndIf
			EndIf

			//-- Verifica se a regiao de destino do CTRC pertence a regiao da rota.
			If lRet
				DT6->(DbSetOrder(1))
				For nCntFor := 1 To oModelDM3:Length()
					If !oModelDM3:IsDeleted(nCntFor) .And. !oModelDM3:IsEmpty(nCntFor)
						oModelDM3:GoLine(nCntFor)
						If !Empty(oModelDM3:GetValue("DM3_FILDOC"))
							If DT6->(MsSeek(xFilial("DT6") + oModelDM3:GetValue("DM3_FILDOC") + oModelDM3:GetValue("DM3_DOC") + ;
															 oModelDM3:GetValue("DM3_SERIE")))
								aRegiao := TMSNivSup(DT6->DT6_CDRCAL)	//-- Obtem os niveis superiores da regiao de calculo
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Retorna as Regioes / Filiais de Destino da Rota                       ³
								//³ Elementos contidos por dimensao:                                      ³
								//³ 1. Regiao Origem da Rota                                              ³
								//³ 2. Regioes de Destino da Rota                                         ³
								//³ 3. Filiais de Destino da Rota                                         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aRegRot := TMSRegDes(FwFldGet("DTQ_ROTA"))	//-- Obtem as regioes da rota.
								nSeek   := 0
								For nElemento := 1 To Len(aRegiao)
									nSeek := Ascan(aRegRot,{|x| x[2] == aRegiao[nElemento]})
									If nSeek > 0
										oModelDM3:LoadValue("DM3_STROTA","1")
										Exit
									EndIf
								Next nCntFor
								If nSeek <= 0
									oModelDM3:LoadValue("DM3_STROTA","3")
								EndIf
							EndIf
						EndIf
					EndIf
				Next
            EndIf
		Else
			If oModelDM3:Length() >= 1 .And.  !oModelDM3:IsEmpty() 			
				If oModelDM3:SeekLine({{"DM3_STATUS",StrZero(2,Len(DUD->DUD_STATUS)) }}) .Or. ;  //Em Transito
					oModelDM3:SeekLine({{"DM3_STATUS",StrZero(4,Len(DUD->DUD_STATUS)) }}) .Or. ; //Encerrado
					  oModelDM3:SeekLine({{"DM3_STATUS",StrZero(9,Len(DUD->DUD_STATUS)) }})      //Cancelado
						Help(' ', 1, 'TMSA14406') //"Rota não poderá ser alterada devido há existência de documentos em processo"
						lRet := .F.
				Else
					If lRotaAlt /////!Empty(cRotAnt) .And. cRotAnt != M->DTQ_ROTA
						//-- Verifica se ha manifesto
						DTX->(DbSetOrder(3))
						If	DTX->(dbSeek(FwxFilial('DTX') + M->DTQ_FILORI + M->DTQ_VIAGEM))
							Help('',1,'TMSA14020')		//-- Ha manifesto de carga para esta viagem
							lRet := .F.
						EndIf
						If lRet
							DTA->(DbSetOrder(2))  
							If	DTA->(dbSeek(FwxFilial('DTA') + M->DTQ_FILORI + M->DTQ_VIAGEM))
								Help(' ', 1, 'TMSA144K8') //"Não é permitido alteração da Rota, pois existe Carregamento para a Viagem
								lRet := .F.
							EndIf	
						EndIf				
					
						If lRet
							If !F11RotRote(M->DTQ_ROTA)
								For nCntFor := 1 To oModelDM3:Length()
									If !oModelDM3:IsDeleted(nCntFor) .And. !oModelDM3:IsEmpty(nCntFor)
										oModelDM3:GoLine(nCntFor)
										//-- Localiza zona e setor da rota a partir do documento
										If !Empty(FwFldGet("DM3_DOC"))
											If !TMSAF62DPC(FwFldGet("DM3_FILDOC"),FwFldGet("DM3_DOC"),FwFldGet("DM3_SERIE")) .And.;
												!TMSAF62DA7(FwFldGet("DM3_FILDOC"),FwFldGet("DM3_DOC"),FwFldGet("DM3_SERIE"),M->DTQ_ROTA,.F.,@cZona,@cSetor)
												oModelDM3:DeleteLine()
											EndIf
										EndIf
									EndIf	
								Next
								oModelDM3:GoLine(nLinha)
							EndIf
						EndIf
					
					EndIf
				EndIf
			EndIf 
		
		EndIf
	EndIf
EndFilBrw("DA8",aIndexDA8)		
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwRestRows( aSaveLine )
FwFreeArray(aFilDca)
FwFreeArray(aRegiao)
FwFreeArray(aRegRot)

Return lRet


/*{Protheus.doc} VldTpOpVg
Valida campo M->DTQ_TPOPVG
@author Katia
@since 22/06/2020
@version version
*/
Static Function VldTpOpVg()
Local lRet		:= .T.
Local aAreaDTY	:= DTY->(GetArea())

DTY->( DbSetOrder( 2 ) )
If DTY->(MsSeek(xFilial('DTY') + M->DTQ_FILORI + M->DTQ_VIAGEM)) .And. DTY->DTY_FILORI == cFilAnt
	Help(' ', 1, 'TMSXFUNA06')	//-- Manutencoes nao sao permitidas em viagens que ja tenham contrato de carreteiro
	lRet:= .F.
EndIf

RestArea(aAreaDTY)
FwFreeArray(aAreaDTY)

Return lRet


/*{Protheus.doc} TMSAF62DPC
Verifica se o documento sera entrege por despachante (TMSA144DPC)
@author Katia
@since 22/06/2020
@version version
*/
Function TMSAF62DPC(cFilDoc,cDoc,cSerie)

Local cAliasNew := GetNextAlias()
Local cQuery    := ''
Local lRet      := .F.
Local aAreaDT6  := DT6->(GetArea())

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""

cQuery := " SELECT COUNT(DT6_FILIAL) CNT "
cQuery += "   FROM " + RetSQLName("DT6")
cQuery += "   WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "     AND DT6_FILDOC = '" + cFilDoc + "' "
cQuery += "     AND DT6_DOC    = '" + cDoc    + "' "
cQuery += "     AND DT6_SERIE  = '" + cSerie  + "' "
cQuery += "     AND DT6_SERIE  <> 'COL' "
cQuery += "     AND (( DT6_CLIDPC <> ' ' AND DT6_LOJDPC <> ' ' ) "
cQuery += "       OR  DT6_CDRCAL <> DT6_CDRDES ) "
cQuery += "     AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )

If (cAliasNew)->CNT > 0
	lRet := .T.
EndIf
(cAliasNew)->(DbCloseArea())

RestArea(aAreaDT6)
FwFreeArray(aAreaDT6)
Return( lRet )


/*{Protheus.doc} TMSAF62DA7
Analisa pontos por zona e setor a partir do documento (TMSA144DA7)
@author Katia
@since 22/06/2020
@version version
*/
Function TMSAF62DA7(cFilDoc,cDoc,cSerie,cRota,lHelp,cZona,cSetor)

Local aAreas    := {DA7->(GetArea()),DA9->(GetArea()),DUE->(GetArea()),DUL->(GetArea()),DT6->(GetArea()),SA1->(GetArea()),GetArea()}
Local lRet      := .F.
Local cCep      := ''
Local cCliente  := ''
Local cLoja     := ''
Local cRotGCol  := Padr(GetMv('MV_ROTGCOL',,''),Len(DTQ->DTQ_ROTA))
Local cRotGEnt  := Padr(GetMv('MV_ROTGENT',,''),Len(DTQ->DTQ_ROTA))
Local cAliasDT5 := ''
Local cAliasDT6 := ''
Local cAliasDA6 := ''
Local cAliasDA7 := ''
Local cAliasDA9 := ''
Local cAliasAux	:= ''
Local cQuery    := ''
Local lDocCol   := .F.
Local lPesqCCli := SuperGetMv("MV_TMSPCLI",,.F.)	//-- Atraves deste parametro é possivel fazer com que o
													//-- Pontos por setor sejam pesquisados por codigo de Cliente.
Local lContinua := .T.
Local nAux		:= 1 

Static _oAuxDA71
Static _oAuxDT5
Static _oAuxDA72
Static _oAuxDA9
Static _oAuxDA73
Static _oAuxDT6

Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""
Default cRota      	:= M->DTQ_ROTA
Default lHelp      	:= .T.
Default cZona      	:= Space(Len(DA9->DA9_PERCUR))
Default cSetor     	:= Space(Len(DA9->DA9_ROTA))

If (Empty(cRota) .And. M->DTQ_SERTMS <> StrZero( 2, Len( DC5->DC5_SERTMS ) )) .Or. F11RotRote(cRota)
	lRet     := .T.
	lContinua:= .F.
EndIf

If lContinua

	cAliasAux	:= GetNextAlias()
	
	if _oAuxDT6 == Nil 

		_oAuxDT6	:= FWPreparedStatement():New()

		cQuery	:= " SELECT DT6_CLIDES , DT6_LOJDES , DT6_SERTMS , A1_CEP, A1_CEPE   "
		cQuery	+= " FROM " + RetSQLName("DT6") + " DT6 "
		cQuery	+= " LEFT JOIN " + RetSQLName("SA1") + " SA1 "
		cQuery	+= " ON A1_FILIAL		= ? "
		cQuery	+= " AND A1_COD			= DT6_CLIDES "
		cQuery	+= " AND A1_LOJA		= DT6_LOJDES "
		cQuery	+= " AND SA1.D_E_L_E_T_ = '' "
		cQuery	+= " WHERE DT6_FILIAL	= ? "
		cQuery	+= " AND DT6_FILDOC		= ? "
		cQuery	+= " AND DT6_DOC		= ? "
		cQuery	+= " AND DT6_SERIE		= ? "
		cQuery	+= " AND DT6.D_E_L_E_T_ = '' "

		cQuery := ChangeQuery(cQuery)
		_oAuxDT6:SetQuery(cQuery)
	EndIf 

	nAux	:= 1 

	_oAuxDT6:SetString(nAux++, xFilial("SA1") )
	_oAuxDT6:SetString(nAux++, xFilial("DT6") )
	_oAuxDT6:SetString(nAux++, cFilDoc )
	_oAuxDT6:SetString(nAux++, cDoc )
	_oAuxDT6:SetString(nAux++, cSerie )

	cQuery  := _oAuxDT6:GetFixQuery()

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAux,.T.,.T.)

	While (cAliasAux)->( !Eof() )
		cCliente := (cAliasAux)->DT6_CLIDES
		cLoja    := (cAliasAux)->DT6_LOJDES
		
		If (cAliasAux)->DT6_SERTMS == StrZero(1, Len(DT6->DT6_SERTMS))
			lDocCol := .T.     //-- Seleção de documentos de coleta em viagem de entrega deve ser validada como coleta
		EndIf
	
		If !lDocCol
			cCep     := If(Empty((cAliasAux)->A1_CEPE),(cAliasAux)->A1_CEP,(cAliasAux)->A1_CEPE)
		EndIf 

		(cAliasAux)->(dbSkip())
	EndDo 

	(cAliasAux)->(dbCloseArea())


	If !lDocCol
		//-- Se for rota generica
		If cRota == cRotGEnt
			lRet    := .T.
		EndIf

		/*--- Ponto de Entrada TM144CEP Removido ----*/	
		If !lRet
			cAliasDT6 := GetNextAlias()
			
			If _oAuxDA71 == Nil 
				_oAuxDA71	:= FWPreparedStatement():New()
				
				cQuery := "SELECT "
				cQuery += "DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE, "
				cQuery += "DT6.DT6_CLIDES, DT6.DT6_LOJDES, SA1.A1_FILIAL, SA1.A1_COD, "
				cQuery += "SA1.A1_LOJA, SA1.A1_CEP, DA7.DA7_ROTA, DA7.DA7_CEPDE, "
				cQuery += "DA7.DA7_CEPATE, DA7.DA7_PERCUR, DA7.DA7_FILIAL, DA6.DA6_ALIANC, "
				cQuery += "DA9.DA9_ROTEIR, DA9.DA9_ROTA, DA9.DA9_PERCUR "
				cQuery += "FROM "+RetSqlName("DT6")+" DT6 " 
				cQuery += "INNER JOIN "+RetSqlName("SA1")+" SA1 ON " 
				cQuery += "(SA1.A1_FILIAL = ?  AND DT6.DT6_CLIDES = SA1.A1_COD AND DT6.DT6_LOJDES = SA1.A1_LOJA) AND SA1.D_E_L_E_T_ = '' "  		
				cQuery += "INNER JOIN "+RetSqlName("DA7")+" DA7 ON "
				/* --- Ponto de Entrada TM144CEP Removido ----*/	
				cQuery += "(DA7.DA7_FILIAL  = ? AND SA1.A1_CEP >= DA7.DA7_CEPDE AND SA1.A1_CEP <= DA7.DA7_CEPATE
				If lPesqCCli
					cQuery += " OR DA7.DA7_CLIENT = SA1.A1_COD AND DA7.DA7_LOJA = SA1.A1_LOJA "
				EndIf	
				cQuery += " )  AND DA7.D_E_L_E_T_ = '' "
				cQuery += "INNER JOIN "+RetSqlName("DA6")+" DA6 ON "
				cQuery += "(DA6.DA6_FILIAL = ? AND DA6.DA6_ROTA = DA7.DA7_ROTA AND DA6.DA6_PERCUR = DA7.DA7_PERCUR) AND DA6.D_E_L_E_T_ = '' "
				cQuery += "INNER JOIN "+RetSqlName("DA9")+" DA9 ON "
				cQuery += "(DA9.DA9_FILIAL = ? AND DA9.DA9_ROTA = DA6.DA6_ROTA AND DA9.DA9_PERCUR = DA6.DA6_PERCUR AND DA9.DA9_ROTEIR = ? ) AND DA9.D_E_L_E_T_ = ''"
				cQuery += "WHERE DT6_FILIAL = ? "
				cQuery += "AND DT6.DT6_FILDOC = ? AND DT6.DT6_DOC = ? AND DT6.DT6_SERIE = ? AND DT6.D_E_L_E_T_ = '' "                                                                                    
				cQuery := ChangeQuery(cQuery)

				_oAuxDA71:SetQuery(cQuery)

			EndIf 
			nAux := 1
			_oAuxDA71:SetString(nAux++,xFilial("SA1"))
			_oAuxDA71:SetString(nAux++,xFilial("DA7"))
			_oAuxDA71:SetString(nAux++, xFilial("DA6") )
			_oAuxDA71:SetString(nAux++, xFilial("DA9") )
			_oAuxDA71:SetString(nAux++, cRota )
			_oAuxDA71:SetString(nAux++, xFilial("DT6") )
			_oAuxDA71:SetString(nAux++, cFilDoc )
			_oAuxDA71:SetString(nAux++, cDoc )
			_oAuxDA71:SetString(nAux++, cSerie )

			cQuery  := _oAuxDA71:GetFixQuery()

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDT6,.T.,.T.)
			If (cAliasDT6)->(!Eof()) 
				If(!Empty(Alltrim((cAliasDT6)->DA9_ROTEIR)))
					lRet 	:= .T.
					cZona  	:= (cAliasDT6)->DA9_PERCUR
					cSetor 	:= (cAliasDT6)->DA9_ROTA
				EndIf
				If (cAliasDT6)->(!Empty(DA6_ALIANC))
					//--Se alianca estiver preenchida nao analisa o cep e não considera o resultado.
					lRet := .T.
				EndIf	
			EndIf
			(cAliasDT6)->(dbCloseArea())
		EndIf
	Else

		If cRota == cRotGCol
			lRet    := .T.
		EndIf

		If !lRet
			cAliasDT5 := GetNextAlias()
			If _oAuxDT5 == Nil 

				_oAuxDT5	:= FWPreparedStatement():New()

				cQuery := "SELECT "
				cQuery += "DT5.DT5_SEQEND , DUL.DUL_CEP , DUE.DUE_CODCLI , DUE.DUE_LOJCLI , DUE.DUE_CEP "
				cQuery += "FROM "+RetSqlName("DT5")+" DT5 "
				cQuery += "LEFT JOIN "+RetSqlName("DUE")+" DUE ON "
				cQuery += "(DUE.DUE_FILIAL = ?  AND DUE.DUE_CODSOL = DT5.DT5_CODSOL) "
				cQuery += "LEFT JOIN "+RetSqlName("DUL")+" DUL ON "
				cQuery += "(DUL.DUL_FILIAL = ? AND DUL.DUL_CODSOL = DT5.DT5_CODSOL AND DUL.DUL_SEQEND = DT5.DT5_SEQEND) "
				cQuery += "WHERE DT5.DT5_FILIAL = ? "
				cQuery += "AND DT5.DT5_FILDOC = ? "
				cQuery += "AND DT5.DT5_DOC = ? "
				cQuery += "AND DT5.DT5_SERIE = ? "
				cQuery += "AND DT5.D_E_L_E_T_ = '' "
				cQuery += "AND DUE.D_E_L_E_T_ = '' "
				cQuery := ChangeQuery(cQuery)

				_oAuxDT5:SetQuery(cQuery)

			EndIf 

			nAux	:= 1 

			_oAuxDT5:SetString(nAux++, xFilial("DUE") )
			_oAuxDT5:SetString(nAux++, xFilial("DUL") )
			_oAuxDT5:SetString(nAux++, xFilial("DT5") )
			_oAuxDT5:SetString(nAux++, cFilDoc )
			_oAuxDT5:SetString(nAux++, cDoc )
			_oAuxDT5:SetString(nAux++, cSerie )

			cQuery  := _oAuxDT5:GetFixQuery()

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDT5,.T.,.T.)
			If (cAliasDT5)->(!Eof())
				cCliente := (cAliasDT5)->DUE_CODCLI
				cLoja    := (cAliasDT5)->DUE_LOJCLI
				If Empty((cAliasDT5)->DT5_SEQEND)
					cCep  := (cAliasDT5)->DUE_CEP
				Else
					cCep  := (cAliasDT5)->DUL_CEP
				EndIf
			EndIf
			(cAliasDT5)->(dbCloseArea())

			If !Empty(cCliente) .And. !Empty(cLoja)
				cAliasDA7 := GetNextAlias()
				If _oAuxDA72 == Nil 

					_oAuxDA72	:= FWPreparedStatement():New()

					cQuery := "SELECT DA7.DA7_PERCUR, DA7.DA7_ROTA "
					cQuery += "FROM "+RetSqlName("DA7")+" DA7 "
					cQuery += "INNER JOIN "+RetSqlName("DA9")+" DA9 ON "
					cQuery += "(DA9.DA9_FILIAL = ? AND DA9.DA9_PERCUR = DA7.DA7_PERCUR AND DA9.DA9_ROTA = DA7.DA7_ROTA) "
					cQuery += "WHERE DA7.DA7_FILIAL = ?  "
					cQuery += "AND DA7.DA7_CLIENT = ? "
					cQuery += "AND DA7.DA7_LOJA = ? "
					cQuery += "AND DA9.DA9_ROTEIR = ? "
					cQuery += "AND DA7.D_E_L_E_T_ = '' "
					cQuery += "AND DA9.D_E_L_E_T_ = '' "
					
					cQuery := ChangeQuery(cQuery)

					_oAuxDA72:SetQuery(cQuery)

				EndIf 

				nAux	:= 1 

				_oAuxDA72:SetString(nAux++, xFilial("DA9") )
				_oAuxDA72:SetString(nAux++, xFilial("DA7") )			
				_oAuxDA72:SetString(nAux++, cCliente )
				_oAuxDA72:SetString(nAux++, cLoja )
				_oAuxDA72:SetString(nAux++, cRota )

				cQuery  := _oAuxDA72:GetFixQuery()
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA7,.T.,.T.)
				If (cAliasDA7)->(!Eof())
					lRet   := .T.
					If lDocCol
						cZona  := (cAliasDA7)->DA7_PERCUR
						cSetor := (cAliasDA7)->DA7_ROTA
					EndIf
				EndIf
				(cAliasDA7)->(dbCloseArea())
			EndIf

			If !lRet
				cAliasDA6 := GetNextAlias()
				
				If _oAuxDA9 == Nil 

					_oAuxDA9	:= FWPreparedStatement():New()

					cQuery := "SELECT DA9.DA9_PERCUR, DA9.DA9_ROTA "
					cQuery += "FROM "+RetSqlName("DA9")+" DA9 "
					cQuery += "INNER JOIN "+RetSqlName("DA7")+" DA7 ON "
					cQuery += "(DA7.DA7_FILIAL = ? AND DA7.DA7_PERCUR = DA9.DA9_PERCUR AND DA7.DA7_ROTA = DA9.DA9_ROTA) "
					cQuery += "INNER JOIN "+RetSqlName("DA6")+" DA6 ON "
					cQuery += "(DA6.DA6_FILIAL = ? AND DA6.DA6_PERCUR = DA7.DA7_PERCUR AND DA6.DA6_ROTA = DA7.DA7_ROTA) "
					cQuery += "WHERE DA9.DA9_ROTEIR = ? "
					cQuery += "AND DA6.DA6_ALIANC <> '' "
					cQuery += "AND DA9.D_E_L_E_T_ = '' "
					cQuery += "AND DA7.D_E_L_E_T_ = '' "
					cQuery += "AND DA6.D_E_L_E_T_ = '' "
					cQuery := ChangeQuery(cQuery)

					_oAuxDA9:SetQuery( cQuery )

				EndIf 

				nAux	:= 1 

				_oAuxDA9:SetString(nAux++, xFilial("DA7") )
				_oAuxDA9:SetString(nAux++, xFilial("DA6") )			
				_oAuxDA9:SetString(nAux++, cRota )
			
				cQuery  := _oAuxDA9:GetFixQuery()

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA6,.T.,.T.)
				If (cAliasDA6)->(!Eof())
					lRet   := .T.
					If lDocCol
						cZona  := (cAliasDA6)->DA9_PERCUR
						cSetor := (cAliasDA6)->DA9_ROTA
					EndIf
				EndIf
				(cAliasDA6)->(dbCloseArea())

				If !lRet
					cAliasDA9 := GetNextAlias()
					If _oAuxDA73 == Nil 
						_oAuxDA73	:= FWPreparedStatement():New()

						cQuery := "SELECT DA7.DA7_PERCUR, DA7.DA7_ROTA "
						cQuery += "FROM "+RetSqlName("DA7")+" DA7 "
						cQuery += "INNER JOIN "+RetSqlName("DA9")+" DA9 ON "
						cQuery += "(DA9.DA9_FILIAL = ? AND DA9.DA9_PERCUR = DA7.DA7_PERCUR AND DA9.DA9_ROTA = DA7.DA7_ROTA) "
						cQuery += "WHERE DA7.DA7_FILIAL = ? "
						cQuery += "AND ? BETWEEN DA7.DA7_CEPDE AND DA7.DA7_CEPATE "
						cQuery += "AND DA9.DA9_ROTEIR = ? "
						cQuery += "AND DA7.D_E_L_E_T_ = '' "
						cQuery += "AND DA9.D_E_L_E_T_ = '' "
						cQuery := ChangeQuery(cQuery)

						_oAuxDA73:SetQuery(cQuery)
					EndIf 
					nAux	:= 1 

					_oAuxDA73:SetString(nAux++, xFilial("DA9") )
					_oAuxDA73:SetString(nAux++, xFilial("DA7") )			
					_oAuxDA73:SetString(nAux++, cCep )
					_oAuxDA73:SetString(nAux++, cRota )

					cQuery  := _oAuxDA73:GetFixQuery()
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA9,.T.,.T.)
					If (cAliasDA9)->(!Eof())
						lRet   := .T.
						If lDocCol
							cZona  := (cAliasDA9)->DA7_PERCUR
							cSetor := (cAliasDA9)->DA7_ROTA
						EndIf
					EndIf
					(cAliasDA9)->(dbCloseArea())
				EndIf
			EndIf
		EndIf
	EndIf

	If !lRet .And. lHelp
		Help(' ', 1, 'TMSA14409') //"Documento não pertence a esta rota"
		
		If FwFldGet("DTQ_STATUS") == StrZero(2,Len(DTQ->DTQ_STATUS))  //Viagem em trânsito exibe o alerta e permite incluir o documento
			lRet   := .T.
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return( lRet )

/*{Protheus.doc} VldMotoris
Valida campo M->DUP_CODMOT
@type Static Function
@author Valdemar Roberto Mognon
@since 06/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function VldMotoris(oModelIDUP,nOpcx)
Local lRet     	:= .T.
Local aAreas   	:= {DA4->(GetArea()),GetArea()}
Local cHora    	:= SubStr(Time(),1,2) +  SubStr(Time(),4,2)
Local dDataIni	:= Iif(!Empty(M->DM4_DATINI),M->DM4_DATINI,dDataBase)
Local dDataFim	:= Iif(!Empty(M->DM4_DATFIM),M->DM4_DATFIM,dDataBase)
Local cHoraIni	:= Iif(!Empty(M->DM4_HORINI),M->DM4_HORINI,cHora)
Local cHoraFim	:= Iif(!Empty(M->DM4_HORFIM),M->DM4_HORFIM,cHora)
Local lPagBem 	:= FindFunction("TMSIntgPB") .AND. DA3->(FieldPos("DA3_CODMUN")) > 0

Default oModelIDUP := Nil
Default nOpcx      := 0

//-- Verifica se é rotina de inclusão de motorista
If TMFGetStat("lIncMot") .And. !oModelIDUP:IsInserted()
	Help("",1,"TMSAF6211")	//-- Na inclusão de condutor, não é permitido a alteração do código do motorista já existente.
	lRet := .F.
EndIf

If lRet .And. !Vazio()
	lRet:= ExistCpo("DA4")
	//-- Verifica se o motorista está bloqueado
	If lRet .And. Posicione("DA4",1,xFilial("DA4") + FwFldGet("DUP_CODMOT"),"DA4_BLQMOT") == StrZero(1,Len(DA4->DA4_BLQMOT))
		Help("",1,"TMSA24055",,STR0023 + ":" + FwFldGet("DUP_CODMOT") + " - " + DA4->DA4_NOME,4,1)	//-- "O Motorista esta bloqueado"
		lRet := .F.
	EndIf
EndIf

//-- Valida Motorista Funcionário (SRA)
If lRet .And. lValFunc
	If Alltrim(FunName()) != "TMSAF15"
		lRet := TMSVldFunc(DA4->DA4_MAT,DA4->DA4_FILBAS,dDataIni,dDataFim)
	Else
		lRet := TMSVldFunc(DA4->DA4_MAT,DA4->DA4_FILBAS)
	EndIf
EndIf

//-- Quando a Viagem por planejada, trata como se o controle de veiculos estivesse desligado.
If lRet .And. lMV_EmViag .And. FwFldGet("DTQ_TIPVIA") != "3" .And. Empty(M->DM4_FILVGE) .And. Empty(M->DM4_NUMVGE)
	//-- Verifica se o Motorista esta sendo utilizado em outra viagem.
	//-- Verificacao realizada quando o parametro MV_CONVEI ou o parametro MV_EMVIAG estivem ativos e a viagem
	//-- for diferente de 'Planejada'
	If !TMSEmViag(M->DTQ_FILORI,M->DTQ_VIAGEM,FwFldGet("DUP_CODMOT"),2,.T.)
		lRet := .F.
	EndIf
	//-- Verifica se o Motorista esta sendo utilizado em outra viagem (Planejada)
	If lRet .And. !TMSF62MPla(M->DTQ_FILORI,M->DTQ_VIAGEM,FwFldGet("DUP_CODMOT"),{dDataIni,cHoraIni,dDataFim,cHoraFim})
		lRet := .F.
	EndIf
EndIf

//-- TMS x PAGBEM
If lRet .And. lPagBem .And. M->DM5_CODOPE == '03'
	lRet := VldMotPgBE(M->DUP_CODMOT) 
EndIf 

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TF62ChkVei
Valida seleção dos Veiculos na Viagem
@type Static Function
@author Katia
@since 08/07/2020
@version version
@param param, param_type, param_descr
@return lRet
*/
Static Function TF62ChkVei(cCampo, cCodVei, cFilOri, cViagem, cTipVia)
Local lRet := .T.

If cCodVei <> cVeiGen 
	If cCampo == 'M->DTR_CODRB1'
		lRet:= (cCodVei <> FwFldGet("DTR_CODRB2")) .And. (cCodVei <> FwFldGet("DTR_CODRB3"))
		If lRet
			lRet:= TF62VeiDup(,,cCodVei,.T.)
		EndIf
	ElseIf cCampo == 'M->DTR_CODRB2'
		lRet:= (cCodVei <> FwFldGet("DTR_CODRB1")) .And. (cCodVei <> FwFldGet("DTR_CODRB3"))		
		If lRet
			lRet:= TF62VeiDup(,,cCodVei,.T.)
		EndIf
	ElseIf cCampo == 'M->DTR_CODRB3'
		lRet:= (cCodVei <> FwFldGet("DTR_CODRB1")) .And. (cCodVei <> FwFldGet("DTR_CODRB2"))
		If lRet
			lRet:= TF62VeiDup(,,cCodVei,.T.)
		EndIf
	EndIf

	If !lRet
		Help(" ", 1, 'TMSA24028',,STR0030 + cCodVei,5,11)	//"Reboque informado para outro Veiculo!"	### "Veiculo : "
	EndIf
EndIf

If lRet .And. lMV_EmViag .And. Empty(M->DM4_FILVGE) .And. Empty(M->DM4_NUMVGE)
	If cTipVia <> StrZero( 3, Len( DTQ->DTQ_TIPVIA ) ) ;
		//-- Verifica se o Reboque esta em viagem, para viagens diferente de 'Planejada'
		If !TMSEmViag(cFilOri, cViagem, cCodVei, 1)
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*{Protheus.doc} VldVgeDM4
Valida campos da Viagem da DM4
@type Static Function
@author Katia
@since 08/07/2020
@return lRet
*/
Function VldVgeDM4(cCampo)
Local lRet     := .T.
Local aAreas   := {DTQ->(GetArea()),DM4->(GetArea()),DTR->(GetArea()),GetArea()}

Default cCampo := ReadVar()

If !Vazio() 
	If cCampo == "M->DM4_NUMVGE" .And. Empty(M->DM4_FILVGE)
		Help('',1,'REGNOIS')
		lRet := .F.
	EndIf
	If lRet .And. !ExistCpo("DTQ",M->DM4_FILVGE+AllTrim(M->DM4_NUMVGE),2)
		lRet := .F.
	EndIf
	If lRet .And. M->DM4_FILVGE+M->DM4_NUMVGE == M->DTQ_FILORI+M->DTQ_VIAGEM
		Help("",1,"TMSA24013") // A Viagem Original Nao Podera ser igual a Viagem ...
		lRet := .F.
	EndIf

	If lRet .And. FindFunction("ColEntAtiv")
		lRet := !ColEntAtiv(M->DM4_FILVGE,M->DM4_NUMVGE,"1")
	EndIf
		
	If lRet
		DTR->(dbSetOrder(1))
		If !DTR->(MsSeek(xFilial("DTR")+M->DM4_FILVGE+AllTrim(M->DM4_NUMVGE)))
			Help("",1,"TMSA24016") // Nao existe Complemento de Viagem para esta Viagem ...
			lRet := .F.
		EndIf
	EndIf
	
	If lRet
		DTQ->( MsSeek(xFilial("DTQ")+M->DM4_FILVGE+AllTrim(M->DM4_NUMVGE)) )
		If (DTQ->DTQ_VIAGEM == M->DM4_NUMVGE) .And. (DTQ->DTQ_STATUS > "2")  // Status != 1 - Em Aberto / 2 - Em Transito.
			Help(' ', 1, 'TMSA24003')  //-- Viagem nao esta Em Aberto e nem Em Transito!
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. !Empty(M->DM4_FILVGE) .And. !Empty(M->DM4_NUMVGE)
		If TMSF62MnCo(M->DM4_FILVGE,AllTrim(M->DM4_NUMVGE)) .And. M->DTQ_SERTMS != StrZero(1, Len( DTQ->DTQ_SERTMS ) ) //Viagens de Coleta não precisam validar se a viagem original está manifestada.       
			Help(' ', 1, 'TMSA24081')  //-- Nao e possivel informar uma viagem vinculada a um manifesto.
			lRet := .F.
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return lRet	

/*{Protheus.doc} VldDataIni
Valida campos da Viagem da DM4 - Data Inicio
@type Static Function
@author Katia
@since 08/07/2020
@return lRet
*/
Static Function VldDataIni()
Local lRet       := .T.
Local lVgeAntiga := (Left(FunName(),7) == "TMSA140" .Or. Left(FunName(),7) == "TMSA141" .Or. ;
					 Left(FunName(),7) == "TMSA143" .Or. Left(FunName(),7) == "TMSA144")

If !lVgeAntiga .And. !( ValDatHor( M->DM4_DATINI, StrTran( Left( Time(), 5 ), ":", "" ), dDataBase, StrTran( Left( Time(), 5 ), ":", "" ),,,,.F. ) )
	lRet := .F.
EndIf

Return lRet
	
/*{Protheus.doc} VldHorIni
Valida campos da Viagem da DTR - Hora Inicio
@type Static Function
@author Katia
@since 08/07/2020
@return lRet
*/	
Static Function VldHorIni()
Local lRet       := .T.
Local lVgeAntiga := (Left(FunName(),7) == "TMSA140" .Or. Left(FunName(),7) == "TMSA141" .Or. ;
					 Left(FunName(),7) == "TMSA143" .Or. Left(FunName(),7) == "TMSA144")

If !lVgeAntiga .And. !( ValDatHor( M->DM4_DATINI, M->DM4_HORINI, dDataBase, StrTran( Left( Time(), 5 ), ":", "" ),,,,.F. ) )
	lRet := .F.
EndIf

Return lRet	

/*{Protheus.doc} VldDataFim
Valida campos da Viagem da DTR - Data Fim
@type Static Function
@author Katia
@since 08/07/2020
@return lRet
*/	
Static Function VldDataFim()
Local lRet:= .T.

If !( ValDatHor( M->DM4_DATFIM, StrTran( Left( Time(), 5 ), ":", "" ), M->DM4_DATINI, StrTran( Left( Time(), 5 ), ":", "" ),,,,.F. ) )
	lRet := .F.
EndIf

Return lRet

/*{Protheus.doc} VldHorFim
Valida campos da Viagem da DTR - Hora Fim
@type Static Function
@author Katia
@since 08/07/2020
@return lRet
*/	
Static Function VldHorFim()
Local lRet:= .T.

If !( ValDatHor( M->DM4_DATFIM, M->DM4_HORFIM, M->DM4_DATINI, M->DM4_HORINI,,,,.F. ) )
	lRet := .F.
EndIf
Return lRet
	
/*{Protheus.doc} VldVeiDTR
Valida campos da Viagem da DTR - Veiculos
@type Static Function
@author Katia
@since 08/07/2020
@return lRet
*/	
Static Function VldVeiDTR(cCampo)
Local lRet    := .T.
Local aAreas  := {DUT->(GetArea()),DA3->(GetArea()),SA2->(GetArea()),GetArea()}
Local cHora   :=  SubStr(Time(),1,2) +  SubStr(Time(),4,2)
Local dDataIni:= Iif(!Empty(M->DM4_DATINI),M->DM4_DATINI,dDataBase)
Local dDataFim:= Iif(!Empty(M->DM4_DATFIM),M->DM4_DATFIM,dDataBase)
Local cHoraIni:= Iif(!Empty(M->DM4_HORINI),M->DM4_HORINI,cHora)
Local cHoraFim:= Iif(!Empty(M->DM4_HORFIM),M->DM4_HORFIM,cHora)
Local lPagBem := FindFunction("TMSIntgPB") .AND. DA3->(FieldPos("DA3_CODMUN")) > 0

If !Vazio() 
 	DA3->(DbSetOrder(1))
    lRet:= DA3->(DbSeek(xFilial("DA3") + M->DTR_CODVEI))
	If lRet
		If !M->DTQ_TIPVIA <> StrZero( 3, Len( DTQ->DTQ_TIPVIA ) )  //Viagem Planejada
			lRet := TMSA240Blq(M->DTR_CODVEI)
		EndIf

		//-- Verifica se veículo está em viagem
		If lRet
			lRet:= TF62ChkVei(cCampo, M->DTR_CODVEI, M->DTQ_FILORI, M->DTQ_VIAGEM, M->DTQ_TIPVIA)		
		EndIf	

		//-- Verifica se veículos estão em viagem planejada
		If lRet 
			//-- Veículo
			lRet := TMSF62VPla(M->DTQ_FILORI,M->DTQ_VIAGEM,FwFldGet("DTR_CODVEI"),{dDataIni,cHoraIni,dDataFim,cHoraFim},STR0030)
			If lRet .And. !Empty(FwFldGet("DTR_CODRB1"))
				lRet := TMSF62VPla(M->DTQ_FILORI,M->DTQ_VIAGEM,FwFldGet("DTR_CODRB1"),{dDataIni,cHoraIni,dDataFim,cHoraFim},STR0031)
				If lRet .And. !Empty(FwFldGet("DTR_CODRB2"))
					lRet := TMSF62VPla(M->DTQ_FILORI,M->DTQ_VIAGEM,FwFldGet("DTR_CODRB2"),{dDataIni,cHoraIni,dDataFim,cHoraFim},STR0032)
					If lRet .And. !Empty(FwFldGet("DTR_CODRB3"))
						lRet := TMSF62VPla(M->DTQ_FILORI,M->DTQ_VIAGEM,FwFldGet("DTR_CODRB3"),{dDataIni,cHoraIni,dDataFim,cHoraFim},STR0033)
					EndIf
				EndIf
			EndIf
		EndIf	
	
		If lRet
			DUT->(dbSetOrder(1))
			If DUT->(MsSeek(xFilial("DUT") + DA3->DA3_TIPVEI)) 
				If  DUT->DUT_CATVEI == '3' .And. Iif(!Empty(cVeiGen),M->DTR_CODVEI <> cVeiGen,.T.)
					Help('',1,'TMSA24009') //-- Nao poderao ser Informados Veiculos com categoria igual a "3" (Carreta)
					lRet := .F.
				EndIf
	
				If lRet .And. (!Empty(FwFldGet("DTR_CODRB1")) .Or. !Empty(FwFldGet("DTR_CODRB2")) .Or. !Empty(FwFldGet("DTR_CODRB3"))) .And.;
					(DUT->DUT_CATVEI == StrZero(1, Len(DUT->DUT_CATVEI)) .Or. DUT->DUT_CATVEI == StrZero(5, Len(DUT->DUT_CATVEI)))
					Help(' ', 1, 'TMSA240VEI', , STR0025, 3, 0) //-- Não é permitida a escolha de um Semi Reboque, quando o Cod.Veículo não for Cavalo Mecânico.
												
					lRet := .F.
				EndIf			
			Else
				Help('',1,'TMSA24011') //-- Nao foi encontrado Categoria de Veiculo para este Tipo de Veiculo
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lRet		
		If DA3->DA3_ATIVO != "1"
			Help(' ', 1, 'TMSA24001',,STR0024 + M->DTR_CODVEI,5,11)	//-- Este veiculo nao esta ativo (DA3)	//'Veiculo : ' //'Veiculo : '
			lRet := .F.
		EndIf
			
		If lRet .And. !Empty(DA3->DA3_CODFOR+DA3->DA3_LOJFOR)
			SA2->(DbSetOrder(1))								
			If SA2->(MsSeek(xFilial("SA2")+DA3->DA3_CODFOR+DA3->DA3_LOJFOR))
				If SA2->A2_MSBLQL == "1"
					HELP(" ",1,"TMSA24088") //Proprietário do veículo esta bloqueado, Verificar o campo Bloqueado no Cadastro de Fornecedor
					lRet := .F.
				EndIf	
			EndIf				
		EndIf			
	EndIf

	//--TMS x PAGBEM
	If lRet .And. lPagBem .And. M->DM5_CODOPE == "03"  
		lRet := VldVeiPgBE(M->DTR_CODVEI)
	EndIf  
		
EndIf
AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})	
Return lRet

/*{Protheus.doc} VldEixDTR
Valida campos da Viagem da DTR - Eixos
@type Static Function
@author Katia
@since 08/07/2020
@return lRet
*/	
Static Function VldEixDTR()
Local lRet    := .T.
Local nQtdEix := 0
Local aAreaDA3:= DA3->(GetArea())

lRet:= Positivo() //X3_VALID
If lRet
	If !Empty(FwFldGet('DTR_CODVEI'))
		nQtdEix := Posicione("DA3",1,xFilial("DA3")+FwFldGet('DTR_CODVEI'),"DA3_QTDEIX")
		If !Empty(FwFldGet('DTR_CODRB1'))
			nQtdEix += Posicione("DA3",1,xFilial("DA3")+FwFldGet('DTR_CODRB1'),"DA3_QTDEIX")
		EndIf
		If !Empty(FwFldGet('DTR_CODRB2'))
			nQtdEix += Posicione("DA3",1,xFilial("DA3")+FwFldGet('DTR_CODRB2'),"DA3_QTDEIX")
		EndIf
		If !Empty(FwFldGet('DTR_CODRB3'))
			nQtdEix += Posicione("DA3",1,xFilial("DA3")+FwFldGet('DTR_CODRB3'),"DA3_QTDEIX")
		EndIf 
		If nQtdEix > 0
			If M->DTR_QTDEIX > nQtdEix .Or. M->DTR_QTDEIX == 0
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaDA3)
FwFreeArray(aAreaDA3)
Return lRet	

/*{Protheus.doc} VldEixVDTR
Valida campos da Viagem da DTR - Eixos de Volta
@type Static Function
@author Katia
@since 08/07/2020
@return lRet
*/	
Static Function VldEixVDTR()
Local lRet:= .T.

If M->DTR_QTEIXV > FwFldGet('DTR_QTDEIX')
	Help("",1,"TMSA24044") // A Qtde. de Eixos para Volta nao deve ser maior que a Qtde. de eixos na Ida.
	lRet := .F.
EndIf
Return lRet


/*{Protheus.doc} VldRebqDTR
Valida campos da Viagem da DTR - Reboques
@type Static Function
@author Katia
@since 08/07/2020
@return lRet
*/	
Static Function VldRebqDTR(cCampo)
Local lRet     	:= .T.
Local aAreas   	:= {DA3->(GetArea()),GetArea()}
Local lPagBem	:= FindFunction("TMSIntgPB") .AND. DA3->(FieldPos("DA3_CODMUN")) > 0

If !Vazio()  //X3_VALID
	If !M->DTQ_TIPVIA <>  StrZero( 3, Len( DTQ->DTQ_TIPVIA ) )  //Viagem Planejada
		cReboque := &cCampo
		lRet := TMSA240Blq(cReboque)	
	EndIf	
	
	If ( RTrim(&(ReadVar())) <> RTrim(cVeiGen) )
		DA3->( DbSetOrder( 1 ) )
		If DA3->( MsSeek( xFilial('DA3') + &(ReadVar()) ))
			DUT->(dbSetOrder(1))
			If DUT->(MsSeek(xFilial('DUT')+DA3->DA3_TIPVEI))
				If DUT->DUT_CATVEI <> '3'
					Help('',1,'TMSA24010')	//--Os veiculos do reboque deverao ser de categoria igual "3" (Carreta).
					lRet := .F.
				EndIf
			Else
				Help('',1,'TMSA24011') //-- Nao foi encontrado Categoria de Veiculo para este Tipo de Veiculo
				lRet := .F.
			EndIf

			If	lRet .And. DA3->DA3_ATIVO != "1"
				Help(' ', 1, 'TMSA24001',,STR0009 + &(cCampo),5,11)	//-- Este veiculo nao esta ativo (DA3)	//'Veiculo : ' //'Veiculo : '
				lRet := .F.
			EndIf
		Else
			Help(' ', 1, 'TMSA24025',,STR0009 + &(cCampo),5,11)	 //"Veiculo não cadastrado ..." ### "Veiculo : "
			lRet := .F.
		EndIf
	EndIf
	
	If lRet .And. cCampo == 'M->DTR_CODRB1'
		If !Empty(M->DTR_CODRB1)			
			lRet:= TF62ChkVei(cCampo, M->DTR_CODRB1, M->DTQ_FILORI, M->DTQ_VIAGEM, M->DTQ_TIPVIA)
		EndIf
			
	ElseIf lRet .And. cCampo == 'M->DTR_CODRB2'
		If !Empty(M->DTR_CODRB2)			
			lRet:= TF62ChkVei(cCampo, M->DTR_CODRB2, M->DTQ_FILORI, M->DTQ_VIAGEM, M->DTQ_TIPVIA)
		EndIf
			
	ElseIf lRet .And. cCampo == 'M->DTR_CODRB3'
		If !Empty(M->DTR_CODRB3)
			lRet:= TF62ChkVei(cCampo, M->DTR_CODRB3, M->DTQ_FILORI, M->DTQ_VIAGEM, M->DTQ_TIPVIA)
		EndIf			
	EndIf

	//--TMS x PAGBEM
	If lRet .And. lPagBem .And. M->DM5_CODOPE == "03"  
		If cCampo == 'M->DTR_CODRB1'
			lRet := VldVeiPgBE(M->DTR_CODRB1)
		ElseIf cCampo == 'M->DTR_CODRB2'
			lRet := VldVeiPgBE(M->DTR_CODRB2)
		ElseIf cCampo == 'M->DTR_CODRB3'
			lRet := VldVeiPgBE(M->DTR_CODRB3)
		EndIf 
	EndIf  
		
EndIf
AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return lRet

/*{Protheus.doc} VldFornec
Valida campos da Viagem da DTR - Fornecedores
@type Static Function
@author Katia
@since 08/07/2020
@return lRet
*/	
Static Function VldFornec(nGrpCampos)
Local lRet     := .T.
Local aAreaSA2 := SA2->(GetArea())
Local cCodForn  := ""	
Local cLojForn  := ""

If nGrpCampos == 1
	cCodForn := "DTR_CREADI"
	cLojForn := "DTR_LOJCRE"
ElseIf nGrpCampos == 2
	cCodForn := "DTR_FORPDG"
	cLojForn := "DTR_LOJPDG"
ElseIf nGrpCampos == 3
	cCodForn := "DTR_FOROPE"
	cLojForn := "DTR_LOJOPE"
EndIf

If !Empty(FwFldGet(cCodForn)) .And. !Empty(FwFldGet(cLojForn))
	SA2->(dbSetOrder(1))
	If !SA2->(MsSeek(xFilial("SA2")+FwFldGet(cCodForn)+FwFldGet(cLojForn)))
		Help('',1,'REGNOIS') //Nao existe registro relacionado a este codigo"
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaSA2) 
FwFreeArray(aAreaSA2)

Return lRet

/*{Protheus.doc} VldCNPJDTR
Valida campos da Viagem da DTR - CNPJ 
@type Static Function
@author Katia
@since 08/07/2020
@return lRet
*/	
Static Function VldCNPJDTR()
Local lRet   := .T.
Local aFilSM0:= FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_CGC"} )
Local cCNPJPg:= ""
Local cCNPJFil:= ""
	
cCNPJPg	:= M->DTR_CNPJPG
cCNPJFil:= aFilSM0[1][2]

If cCNPJPg == cCNPJFil  
	HELP(" ",1,"TMSA240A6") // O CNPJ do responsável pelo pagamento do pedágio deve ser diferente do emitente do MDF-E. 
	lRet := .F.
EndIf 

Return lRet

/*{Protheus.doc} VldInsRet
Valida campos da Viagem da DTR - INSRET
@type Static Function
@author Katia
@since 08/07/2020
@return lRet
*/	
Static Function VldInsRet()	
Local lRet:= .T.

lRet:= Positivo() //X3_VALID
If lRet .And. M->DTR_INSRET <> 0
	lRet:= !TF61VldVei(FwFldGet("DTR_CODVEI"),"F")
EndIf

Return lRet

/*{Protheus.doc} VldFretDTR
Valida campos da Viagem da DTR - VALFRE
@type Static Function
@author Katia
@since 08/07/2020
@return lRet
*/	
Static Function VldFretDTR()
Local lRet    := .T.

lRet:= Positivo() //X3_VALID
If lRet .And. M->DTR_VALFRE <> 0
	lRet:= !TF61VldVei(FwFldGet("DTR_CODVEI"),"F")

EndIf

Return lRet

/*{Protheus.doc} VldValPdg
Valida campos da Viagem da DTR - VALPDG
@type Static Function
@author Katia
@since 08/07/2020
@return lRet
*/	
Static Function VldValPdg()
Local lRet:= .T.

lRet:= Positivo()

Return lRet

/*{Protheus.doc} TMSAF62DcR
Verifica criterio de rateio do documento
@type Static Function
@author Valdemar Roberto Mognon
@since 13/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function TMSAF62DcR(cNrCont,cCodNeg,cServic)
Local cRet    := ""
Local cBacRat := ""

Default cNrCont := ""
Default cCodNeg := ""
Default cServic := ""

cBacRat:= TmsSobServ("BACRAT",.T.,.T.,cNrCont,cCodNeg,cServic,"1")

If cBacRat <> "1"	//-- Nao Utiliza
	cRet:= TmsSobServ("CRIRAT",.T.,.T.,cNrCont,cCodNeg,cServic,"1")
EndIf	
						
Return cRet

/*{Protheus.doc} TMSAF62Col
Função que Retorna o Valor do Array com Viagem Principal e Coligada
@type Static Function
@author Valdemar Roberto Mognon
@since 13/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function TMSAF62Col(cFilOri,cViagem,lMDFEAut)
Local aAreas    := {GetArea()}
Local aVgaPrinc := {}
Local aVgaColig := {}
Local lMDFeSrv  := .F.

Default cFilOri := ""
Default cViagem := ""
Default lMDFEAut:= GetMV("MV_MDFEAUT",,.F.) .And. ExistFunc("TmsMDFeAut")

If !Empty(cViagem)
	DTR->(DbSetOrder(2))
	MsSeek(xFilial("DTR") + cFilOri + cViagem)
	If !Empty(DTR->DTR_FILVGE + DTR->DTR_NUMVGE)
		//-- Não e a Viagem Principal, acha viagem principal
		aVgaPrinc := VgaPrincial(cFilOri,cViagem)
	Else
		DTR->(DbSetOrder(1))
		If MsSeek(xFilial("DTR") + cFilOri + cViagem)
			//-- Achou viagem coligada, procura a principal
			aVgaPrinc := VgaPrincial(cFilOri,cViagem)
		EndIf
	EndIf
	
	//-- Procura Viagens Coligadas
	If Len(aVgaPrinc) > 0 
		
		//--- Verifica se Serviço de transporte da viagem esta configurado para MDFe Automatico.
		If (lMDFEAut .Or. ExistFunc("TmsAutViag")) .And. FindFunction('TMA190Srv')
			lMDFeSrv:= TMA190Srv(aVgaPrinc[1][1], aVgaPrinc[1][2])
			If !lMDFeSrv
				lMDFEAut:= .F.
			EndIf			
		EndIf


		aVgaColig := VgaColigada(aVgaPrinc[1,1],aVgaPrinc[1,2])
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return aVgaColig

/*{Protheus.doc} TMSF62MPla
Valida se o motorista esta esta em alguma viagem planejada
@type Static Function
@author Valdemar Roberto Mognon
@since 13/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function TMSF62MPla(cFilOri,cViagem,cCodMot,aPlanej)
Local lRet       := .T.
Local cNumVge    := ""
Local aAreas     := {GetArea()}
Local cQuery     := ""
Local cAliasDUP  := ""
Local cPeriodIni := ""
Local cPeriodFim := ""

Default cFilOri := ""
Default cViagem := ""
Default cCodMot := ""
Default aPlanej := {}

If Len(aPlanej) == 4
	cPeriodIni := DtoS(aPlanej[1]) + aPlanej[2]
	cPeriodFim := DtoS(aPlanej[3]) + aPlanej[4]
	
	If lMVTMSAloc .And. Empty(M->DM4_FILVGE) .And. Empty(M->DM4_NUMVGE)
		cAliasDUP := GetNextAlias()
		cQuery := "SELECT DUP.DUP_FILORI,DUP.DUP_VIAGEM,DUP.DUP_CODMOT,"
		cQuery += "       DTR.DTR_DATINI,DTR.DTR_HORINI,DTR.DTR_DATFIM,DTR.DTR_HORFIM,DTR_FILVGE,DTR_NUMVGE "

		cQuery += "  FROM " + RetSQLName("DUP") + " DUP "

		cQuery += "  JOIN " + RetSQLName("DTQ") + " DTQ "
		cQuery += "    ON DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "' "
		cQuery += "   AND DTQ.DTQ_FILORI = DUP.DUP_FILORI "
		cQuery += "   AND DTQ.DTQ_VIAGEM = DUP.DUP_VIAGEM "
		cQuery += "   AND DTQ.DTQ_STATUS NOT IN ('3','9') "
		If lTmsExp .And. !Empty(cOcorCan)
			cQuery += "   AND DTQ.DTQ_TIPVIA <> '3' "
			cQuery += "   AND DTQ.DTQ_SERTMS <> '1' "
		EndIf
		cQuery += "   AND DTQ.D_E_L_E_T_ = ' ' "

		cQuery += "  JOIN " + RetSQLName("DTR") + " DTR "
		cQuery += "    ON DTR.DTR_FILIAL = '" + xFilial("DTR") + "' "
		cQuery += "   AND DTR.DTR_FILORI = DTQ.DTQ_FILORI "
		cQuery += "   AND DTR.DTR_VIAGEM = DTQ.DTQ_VIAGEM "
		cQuery += "   AND DTR.D_E_L_E_T_ = ' ' "

		cQuery += "   AND NOT EXISTS (SELECT DF7_FILORI,DF7_VIAGEM "
		cQuery += "                     FROM " + RetSQLName("DF7") + " DF7 "
		cQuery += "                    WHERE DF7.DF7_FILIAL = '" + xFilial("DF7") + "' "
		cQuery += "                      AND ((DF7.DF7_FILORI = DUP.DUP_FILORI AND DF7.DF7_VIAGEM = DUP.DUP_VIAGEM) OR "
		cQuery += "                           (DF7.DF7_FILDTR = DUP.DUP_FILORI AND DF7.DF7_VGEDTR = DUP.DUP_VIAGEM)) "
		cQuery += "                      AND DF7.D_E_L_E_T_  = ' ') "

		cQuery += " WHERE DUP.DUP_FILIAL = '" + xFilial("DUP") + "' "
		cQuery += "   AND DUP.DUP_FILORI = '" + cFilOri + "' "
		cQuery += "   AND DUP.DUP_VIAGEM = '" + cViagem + "' "
		cQuery += "   AND DUP.DUP_CODMOT = '" + cCodMot + "' "
		cQuery += "   AND DUP.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDUP,.T.,.T.)
		
		While !(cAliasDUP)->(EoF())
			If (((cAliasDUP)->(DUP_FILORI + DUP_VIAGEM) <> cFilOri + cViagem) .And. ((cAliasDUP)->(DTR_FILVGE + DTR_NUMVGE) <> cFilOri + cViagem))
				If cPeriodIni >= (cAliasDUP)->(DTR_DATINI + DTR_HORINI) .And. cPeriodIni <= (cAliasDUP)->(DTR_DATFIM + DTR_HORFIM)
					lRet := .F.
					cNumVge := (cAliasDUP)->(DUP_FILORI + '/' + DUP_VIAGEM)
				ElseIf cPeriodFim >= (cAliasDUP)->(DTR_DATINI + DTR_HORINI) .And. cPeriodFim <= (cAliasDUP)->(DTR_DATFIM + DTR_HORFIM)
					lRet := .F.
					cNumVge := (cAliasDUP)->(DUP_FILORI + '/' + DUP_VIAGEM)
				ElseIf (cAliasDUP)->(DTR_DATINI + DTR_HORINI) >= cPeriodIni .And. (cAliasDUP)->(DTR_DATINI + DTR_HORINI) <= cPeriodFim
					lRet := .F.
					cNumVge := (cAliasDUP)->(DUP_FILORI + '/' + DUP_VIAGEM)
				ElseIf (cAliasDUP)->(DTR_DATFIM + DTR_HORFIM) >= cPeriodIni .And. (cAliasDUP)->(DTR_DATFIM + DTR_HORFIM) <= cPeriodFim
					lRet := .F.
					cNumVge := (cAliasDUP)->(DUP_FILORI + '/' + DUP_VIAGEM)
				EndIf
			EndIf
			(cAliasDUP)->(DbSkip())
		EndDo
		(cAliasDUP)->(DbCloseArea())
		
		If !lRet
			Help(" ",1,"TMSAF6207",,STR0026 + cCodMot + " - " + STR0027 + cNumVge,3,00)	//-- O Motorista informado esta sendo utilizado na viagem :
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMSF62VPla
Valida se o veículo esta esta em alguma viagem planejada
@type Static Function
@author Valdemar Roberto Mognon
@since 13/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function TMSF62VPla(cFilOri,cViagem,cCodVei,aPlanej,cTitCpo)
Local lRet       := .T.
Local cQuery     := ""
Local cAliasDTR  := ""
Local cNumVge 	 := ""
Local cDatIni    := ""
Local cHorIni    := ""
Local cDatFim    := ""
Local cHorFim    := ""

Default cFilOri := ""
Default cViagem := ""
Default cCodVei := ""
Default aPlanej := {}
Default cTitCpo := ""

If Len(aPlanej) == 4
	cDatIni := DtoS(aPlanej[1])
	cHorIni := aPlanej[2]
	cDatFim := DtoS(aPlanej[3])
	cHorFim := aPlanej[4]

	If lMVTMSAloc .And. Empty(M->DM4_FILVGE) .And. Empty(M->DM4_NUMVGE)
		cAliasDTR := GetNextAlias()
		cQuery := "SELECT DTR.DTR_CODVEI,DTR.DTR_DATINI,DTR.DTR_HORINI,DTR.DTR_DATFIM,DTR.DTR_HORFIM,"
		cQuery += "       DTQ.DTQ_FILORI,DTQ.DTQ_VIAGEM,DTQ.DTQ_STATUS"
		
		cQuery += "  FROM " + RetSQLName("DTR") + " DTR "
		
		cQuery += "  JOIN " + RetSQLName("DTQ") + " DTQ "
		cQuery += "    ON DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "' "
		cQuery += "   AND DTQ.DTQ_FILORI = DTR.DTR_FILORI "
		cQuery += "   AND DTQ.DTQ_VIAGEM = DTR.DTR_VIAGEM "
		cQuery += "   AND DTQ_STATUS NOT IN ('3','9') "
		cQuery += "   AND DTQ.D_E_L_E_T_ = ' ' "
	             
		cQuery += " WHERE DTR.DTR_FILIAL = '" + xFilial("DTR") + "' "
		cQuery += "   AND DTR.DTR_CODVEI = '" + cCodVei + "' "
		cQuery += "   AND DTR.DTR_VIAGEM <> '" + cViagem + "' "
		cQuery += "   AND DTR.DTR_NUMVGE <> '" + cViagem + "' "
		cQuery += "   AND (('" + cDatIni + "' BETWEEN DTR.DTR_DATINI AND DTR.DTR_DATFIM AND "
		cQuery += "         '" + cHorIni + "' BETWEEN DTR.DTR_HORINI AND DTR.DTR_HORFIM) OR "        
		cQuery += "        ('" + cDatFim + "' BETWEEN DTR.DTR_DATINI AND DTR.DTR_DATFIM AND "
		cQuery += "         '" + cHorFim + "' BETWEEN DTR.DTR_HORINI AND DTR.DTR_HORFIM) OR"
		cQuery += "       ((DTR.DTR_DATINI BETWEEN '" + cDatIni + "' AND '" + cDatFim + "') AND "
		cQuery += "        (DTR.DTR_DATFIM BETWEEN '" + cDatIni + "' AND '" + cDatFim + "') AND "
		cQuery += "        (DTR.DTR_HORINI BETWEEN '" + cHorIni + "' AND '" + cHorFim + "') AND "
		cQuery += "        (DTR.DTR_HORFIM BETWEEN '" + cHorIni + "' AND '" + cHorFim + "')))"
		cQuery += "   AND DTR.D_E_L_E_T_ = ' '"
	                                     
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDTR,.T.,.T.)
	
		If (cAliasDTR)->(!Eof())           
			cNumVge := (cAliasDTR)->DTQ_VIAGEM
			Help("",1,"TMSA24039",,cTitCpo + ": " + cCodVei + ", " + CHR(13) + CHR(10) + STR0028 + CHR(13) + CHR(10) + ;
								   STR0029 + cNumVge + ".", 1, 1)	//-- "ja esta sendo utilizado no mesmo periodo para Viagem: "
			lRet := .F.
		End If
		
		(cAliasDTR)->(DbCloseArea())
	
	End If
EndIf

Return lRet
/*{Protheus.doc} TMSF62MnCo
Verifica se existe manifesto em aberto para viagem coligada
@author Katia
@since 15/07/2020
@version version
@param param, param_type, param_descr
@return return lRet
Funcionalidade retirada da TA240MNCOL()
*/
Function TMSF62MnCo(FILVGE,NUMVGE)
Local cQuery    := ""
Local cAliasNew := ""
Local lPossuiMan := .F.

cQuery := "SELECT 1"
cQuery += " FROM " + RetSqlName("DUD") + " DUD, " + RetSqlName("DTX") + " DTX "
cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "'"
cQuery += " AND DUD.DUD_FILORI = '" +FILVGE + "'"
cQuery += " AND DUD.DUD_VIAGEM = '" +NUMVGE + "'"
cQuery += " AND DUD.D_E_L_E_T_ = ''"
cQuery += " AND DTX.DTX_FILIAL = '" + xFilial("DTX") + "'"
cQuery += " AND DTX.DTX_FILMAN = DUD.DUD_FILMAN"
cQuery += " AND DTX.DTX_MANIFE = DUD.DUD_MANIFE"
cQuery += " AND DTX.DTX_SERMAN = DUD.DUD_SERMAN"
cQuery += " AND DTX.D_E_L_E_T_ = ''"
cQuery += " AND DTX.DTX_STATUS <> '" + StrZero(3,Len(DTX->DTX_STATUS)) + "' "

cAliasNew := GetNextAlias()
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)

dbSelectArea( cAliasNew )
(cAliasNew)->( dbGoTop() )

if (cAliasNew)->(!Eof())
  lPossuiMan := .T.
EndIF

(cAliasNew)->(DbCloseArea())	
Return lPossuiMan

/*{Protheus.doc} TMSF62VSrv
Valida o Serviço de Transporte da Viagem (Não será aceito 1=Coleta)
@type Static Function
@author Valdemar Roberto Mognon
@since 20/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function TMSF62VSrv(oModel,oMdlGrdDM3)
Local lRet       := .T.
Local oMdlFldDTQ := oModel:GetModel("MdFieldDTQ")
Local nCntFor1   := 0

If !FwFldGet("DTQ_SERTMS") $ "23"
	Help("",1,"TMSAF6208",,STR0034,3,0)	//-- "Somente serão aceitas viagens de Transferência e Entrega."
	lRet := .F.
EndIf

If lRet
	If oMdlFldDTQ:IsFieldUpdate("DTQ_SERTMS")
		For nCntFor1 := 1 To oMdlGrdDM3:Length()
			If !oMdlGrdDM3:IsDeleted(nCntFor1) .And. !oMdlGrdDM3:IsEmpty(nCntFor1)
				oMdlGrdDM3:GoLine(nCntFor1)
				oMdlGrdDM3:DeleteLine()
			EndIf	
		Next
		oMdlGrdDM3:GoLine(1)
	EndIf
EndIf

Return lRet

/*{Protheus.doc} VldSeqDoc
Valida a Sequencia de documento 
@author Katia
@since 21/07/2020
@version version
@return return lRet
*/
Static Function VldSeqDoc()
Local lRet:= .T.

If Empty(M->DM3_SEQUEN) 
	Help('',1,"OBRIGAT2",,RetTitle('DM3_SEQUEN'),04,01) 
	lRet:= .F.
Else	
	lRet:= IsNumeric(M->DM3_SEQUEN) 
	If lRet
		lRet:= lSeekSeq
	
		If !lRet	
			//-- Nao permite digitar o nr. da sequencia de um documento carregado.
			If lDocCarreg
				Help(' ', 1, 'TMSA14008',,+ FwFldGet('DM3_DOC') + ' / '+ FwFldGet('DM3_SERIE'),4,3)		//-- Esta sequencia pertence a um documento carregado !
			EndIf
		EndIf
	EndIF
EndIf

TF62ZeraSt()
Return  lRet

/*{Protheus.doc} TF62SetaSt
Seta a variavel Static para controle da validação da sequencia
@author Katia
@since 21/07/2020
@version version
@return return Nil
Funçao TF62SetaSt() executada no fonte TMSAF65
*/
Function TF62SetaSt(lSeek,lCarregado)
lSeekSeq   := lSeek
lDocCarreg := lCarregado
Return 

/*{Protheus.doc} TF62ZeraSt
Limpa a Variavel Static
@author Katia
@since 21/07/2020
@version version
@return return Nil
*/
Function TF62ZeraSt()
lSeekSeq   := .T.
lDocCarreg := .F.
Return 

/*{Protheus.doc} ValidDVW
Valida campos da DVW
@type Static Function
@author Valdemar Roberto Mognon
@since 22/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function ValidDVW(cCampo)
Local lRet       := .T.
Local oModel     := FwModelActive()
Local oModelIDVW := oModel:GetModel("MdGridDVW")
Local nOpcx      := oModel:GetOperation()

Default cCampo := ReadVar()

If AllTrim(cCampo) $ "M->DVW_CODPAS"
	lRet := VldCodPas(oModelIDVW,nOpcx)
ElseIf AllTrim(cCampo) $ "M->DVW_VALOR"
	lRet := VldValPas(oModelIDVW,nOpcx)
EndIf

Return lRet

/*{Protheus.doc} VldCodPas
Valida campo M->DVW_CODPAS
@type Static Function
@author Valdemar Roberto Mognon
@since 22/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function VldCodPas(oModelIDVW,nOpcx)
Local lRet     := .T.
Local aAreas   := {DT3->(GetArea()),GetArea()}

Default oModelIDVW := Nil
Default nOpcx      := 0

DT3->(DbSetOrder(1))
If !DT3->(DbSeek(xFilial("DT3") + FwFldGet("DVW_CODPAS")))
	Help("",1,"TMSAF6209")	//-- Componente de frete não existe.
	lRet := .F.
EndIf

If lRet
	If DT3->DT3_FAIXA != StrZero(61,TamSx3("DT3_CODPAS")[1])
		Help("",1,"TMSAF6210")	//-- Componente não é do tipo valor informado (Faixa = 61).
		lRet := .F.
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} VldValPas
Valida campo M->DVW_VALPAS
@type Static Function
@author Valdemar Roberto Mognon
@since 23/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function VldValPas(oModelIDVW,nOpcx)
Local lRet     := .T.
Local aAreas   := {DT3->(GetArea()),GetArea()}

Default oModelIDVW := Nil
Default nOpcx      := 0

If nOpcx == 4	//-- Alteração da viagem
	If !Empty(FwFldGet("DVW_ORIGEM")) .And. FwFldGet("DVW_ORIGEM") != "TMSA240"
		Help("",1,"TMSAF6302")	//-- "O valor informado não foi gerado pelo TMS."
		lRet := .F.
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} ValidDM4
Valida campos da DM4
@type Static Function
@author Ktia
@since 29/07/2020
@version 12.1.30
@param cCampo
@return lRet
*/
Static Function ValidDM4(cCampo)
Local lRet       := .T.

Default cCampo := ReadVar()

If cCampo $ 'M->DM4_FILVGE|M->DM4_NUMVGE'
	lRet:= VldVgeDM4(cCampo)
ElseIf cCampo $ 'M->DM4_DATINI'
	lRet:= VldDataIni()
ElseIf cCampo $ 'M->DM4_HORINI'
	lRet:= VldHorIni() 
ElseIf cCampo $ 'M->DM4_DATFIM'
	lRet:= VldDataFim()
ElseIf cCampo $ 'M->DM4_HORFIM'
	lRet:= VldHorFim()
EndIf	

Return lRet

/*{Protheus.doc} ValidDM5
Valida campos da DM5
@type Static Function
@author Ktia
@since 29/07/2020
@version 12.1.30
@param cCampo
@return lRet
*/
Static Function ValidDM5(cCampo)
Local lRet       := .T.
Local lVgeAntiga := .F.

Default cCampo := ReadVar()

If cCampo $ 'M->DM5_CODOPE'
	If lTMS3GFE .Or. lTmsRdpU
		If !Empty(M->DM5_CODOPE) .And. M->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))  //Sim
			Help(" ",1,"TMSA24091")   //Pagamento da viagem via SIGAGFE. Não é permitido informar a Operadora de Frotas.  
			lRet:= .F.
		EndIf 
	EndIf

	If M->DM5_CODOPE == '01' .And. !lRestRepom
		lVgeAntiga := (Left(FunName(),7) == "TMSA140" .Or. Left(FunName(),7) == "TMSA141" .Or. ;
		Left(FunName(),7) == "TMSA143" .Or. Left(FunName(),7) == "TMSA144")

		If !lVgeAntiga
			Help(" ",1,"TMSAF6214")   //A integração com a REPOM está disponivel somente para a versão REPOM Frete V2.
			lRet:= .F.
		EndIf
		
	EndIf
EndIf	

Return lRet


/*{Protheus.doc} ValidDLD
Valida campos da DLD
@type Static Function
@author Katia
@since 28/07/2020
@version 12.1.30
@param cCampo
@return lRet
*/
Static Function ValidDLD(cCampo)
Local lRet        := .T.

Default cCampo  := ReadVar()
	
If cCampo == "M->DLD_RECEB" 
	lRet:= TF64PReceb(M->DLD_RECEB,FwFldGet('DTR_CODVEI'))
EndIf

Return lRet

/*{Protheus.doc} TF62CatVei
Retorna a Categoria do Veiculo
@type Function
@author Katia
@since 24/08/2020
@version 12.1.30
@param cCodVei
@return cRet
*/
Function TF62CatVei(cCodVei)
Local cRet    := ""
Local aAreas  := {DUT->(GetArea()),DA3->(GetArea())}

Default cCodVei:= ""

If !Empty(cCodVei)
	DA3->( DbSetOrder( 1 ) )
	If DA3->( MsSeek( xFilial('DA3') + cCodVei ))
		DUT->(dbSetOrder(1))
		If DUT->(MsSeek(xFilial('DUT')+DA3->DA3_TIPVEI))
			cRet:= DUT->DUT_CATVEI
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return cRet

//------------------------------------------------------------
/* TF62VeiDup
Função para Validar Duplicidade de Carreta e ou Reboque na
Grid de Veiculos
@author  Katia
@since   13/07/2020
@version 1.0      
*/
//------------------------------------------------------------
Function TF62VeiDup(oMdGridDTR,nLinAtu,cCodVei,lReboque)
Local lRet       := .T.
Local lSeek      := .F.
Local aSaveLines := FWSaveRows()
Local oModel     := Nil

Default oMdGridDTR := Nil
Default nLinAtu    := 0

If nLinAtu == 0
	oModel     := FWModelActive()
	oMdGridDTR := oModel:GetModel("MdGridDTR")
	nLinAtu    := oMdGridDTR:GetLine()
EndIf

If lReboque
	lSeek:= oMdGridDTR:SeekLine({{ "DTR_CODRB1", cCodVei }}) 
	If !lSeek
		lSeek:= oMdGridDTR:SeekLine({{ "DTR_CODRB2", cCodVei }})
	EndIf	
	If !lSeek
		lSeek:= oMdGridDTR:SeekLine({{ "DTR_CODRB3", cCodVei }})
	EndIf
Else
	lSeek:= oMdGridDTR:SeekLine({{ "DTR_CODVEI", cCodVei }})
EndIf

If lSeek
	If oMdGridDTR:GetLine() <> nLinAtu
		Help(" ", 1, 'TMSA24028',,"Veiculo: " + cCodVei,5,11)	//"Reboque informado para outro Veiculo!"	### "Veiculo : "
		lRet:= .F.
	EndIf
EndIf

FWRestRows( aSaveLines )
Return lRet

/*{Protheus.doc} VldDtFVSg
Valida Data de Fim da Validade do RRE
@type Static Function
@author Valdemar Roberto Mognon
@since 02/10/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function VldDtFVSg(cCampo)
Local lRet := .T.

Default cCampo := ""

If cCampo == "M->DTR_DTFVSG"
	If FwFldGet("DTR_DTFVSG") < FwFldGet("DTR_DTIVSG")
		Help("",1,"TMSA24079")	//-- Data de Validade do Seguro Invalida!
		lRet:= .F.
	EndIf
ElseIf cCampo == "M->DUP_DTFVSG"
	If FwFldGet("DUP_DTFVSG") < FwFldGet("DUP_DTIVSG")
		Help("",1,"TMSA24079")	//-- Data de Validade do Seguro Invalida!
		lRet:= .F.
	EndIf
EndIf

Return lRet

/*{Protheus.doc} VldOrigem
Valida a Origem do Documento 
@author Valdemar Roberto Mognon
@since 23/06/2021
@version version
@return return lRet
*/
Static Function VldOrigem()
Local lRet:= .T.

If FwFldGet("DTA_ORIGEM") == "1" .And. FwFldGet("DTQ_STATUS") == StrZero(2,Len(DTQ->DTQ_STATUS))	//-- 2=Viagem em Trânsito
	Help("",1,"TMSA21066") // Para viagens com status em trânsito, não é permitido o uso da opção 1-Rota/Transp 
	lRet := .F. 
EndIf 

Return lRet

/*{Protheus.doc} TMSF62VTra
Valida o Tipo de Transporte da Viagem (Somente 1-Rodoviario,2-Aereo,3-Fluvial)
@type Static Function
@author Katia
@since 29/06/2021
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
*/
Static Function TMSF62VTra(oModel,oMdlGrdDM3)
Local lRet       := .T.
Local oMdlFldDTQ := oModel:GetModel("MdFieldDTQ")
Local nCntFor1   := 0

If !(M->DTQ_TIPTRA $ "12")
    Help( ,, 'HELP',, STR0042, 1, 0)        //Somente serão aceitas viagens do Tipo Rodoviário ou Aéreo
	lRet := .F.
Else
    TMSValField("M->DTQ_TIPTRA",.T.,"DTQ_DESTPT")                                                                                   

	If oMdlFldDTQ:IsFieldUpdate("DTQ_TIPTRA")
		For nCntFor1 := 1 To oMdlGrdDM3:Length()
			If !oMdlGrdDM3:IsDeleted(nCntFor1) .And. !oMdlGrdDM3:IsEmpty(nCntFor1)
				oMdlGrdDM3:GoLine(nCntFor1)
				oMdlGrdDM3:DeleteLine()
			EndIf	
		Next
		oMdlGrdDM3:GoLine(1)
	EndIf
EndIf
Return lRet

/*{Protheus.doc} TMSF62VDoc
Identifica os documentos da viagem 
@type Function
@author Rafael Souza
@since 30/11/2021
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
*/
Function TMSF62VDoc(cFilVge, cViagem )

Local aAreas    := {GetArea()}
Local aDoctos	:= {} 
Local cQuery    := ""
Local cAliasDUD := ""
Local lDocDisp  := .F. 

Default cFilVge := ""
Default cViagem	:= ""

cQuery := "SELECT DUD_FILORI, DUD_FILDOC, DUD_DOC, DUD_SERIE, DUD_SERTMS, DUD_TIPTRA, DT6_CLIREM, DT6_LOJREM, CLIREM.A1_NOME REM_NOME, DT6_CLIDES, DT6_LOJDES, CLIDES.A1_NOME DES_NOME, CLIDES.A1_MUN DES_MUNICI, CLIDES.A1_EST DES_UF"
cQuery += " FROM " + RetSqlName("DUD") + " DUD "
cQuery += " INNER JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += " ON DT6.DT6_FILIAL 	= '" + xFilial("DT6") + "' "
cQuery += " AND DT6.DT6_FILDOC 	= DUD.DUD_FILDOC "
cQuery += " AND DT6.DT6_DOC 	= DUD.DUD_DOC "
cQuery += " AND DT6.DT6_SERIE 	= DUD.DUD_SERIE "
cQuery += " AND DT6.D_E_L_E_T_ 	= ' ' "
cQuery += " INNER JOIN " + RetSqlName('SA1') + " CLIREM  ON (CLIREM.A1_COD = DT6_CLIREM AND CLIREM.A1_LOJA = DT6_LOJREM ) " + CRLF
cQuery += " INNER JOIN " + RetSqlName('SA1') + " CLIDES  ON (CLIDES.A1_COD = DT6_CLIDES AND CLIDES.A1_LOJA = DT6_LOJDES ) " + CRLF
cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "'"
cQuery += " AND DUD.DUD_FILORI = '" +cFilVge + "'"
cQuery += " AND DUD.DUD_VIAGEM = '" +cViagem + "'"
cQuery += " AND DUD.D_E_L_E_T_ = ''"
cQuery += " AND CLIREM.A1_FILIAL  = '" + xFilial('SA1') + "'" + CRLF
cQuery += " AND CLIREM.D_E_L_E_T_ = ' '" + CRLF
cQuery += " AND CLIDES.A1_FILIAL  = '" + xFilial('SA1') + "'" + CRLF
cQuery += " AND CLIDES.D_E_L_E_T_ = ' '"

cAliasDUD := GetNextAlias()
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUD,.T.,.T.)


While (cAliasDUD)->(!Eof())
	DUD->(DbSetOrder(1))
	If DUD->(MsSeek(xFilial("DUD")+(cAliasDUD)->DUD_FILDOC+(cAliasDUD)->DUD_DOC+(cAliasDUD)->DUD_SERIE))
		While DUD->(!Eof()) .And. DUD->DUD_FILIAL + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE == ;
			xFilial("DUD") + (cAliasDUD)->DUD_FILDOC + (cAliasDUD)->DUD_DOC + (cAliasDUD)->DUD_SERIE 
			//-- Verifica a Filial para manutencao
			If DUD->DUD_STATUS == StrZero(1, Len(DUD->DUD_STATUS))
				lDocDisp   := .T.
				If DUD->DUD_FILORI <> cFilant
					Help( " ", 1,"TMSA50042",,DUD->DUD_FILORI,2,30) //-- A manutencao de transporte do documento e permitida somente na filial :
					lDocDisp := .F.
					Exit  
				EndIf
				//-- Verifica se foi informada a viagem
				If !Empty(DUD->DUD_FILORI) .And. !Empty(DUD->DUD_VIAGEM)
					lDocDisp := .F. 
					Exit 
				EndIf
				If lDocDisp
					Aadd(aDoctos,{DUD->DUD_FILORI,DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,DUD->DUD_SERTMS,DUD->DUD_TIPTRA,(cAliasDUD)->DT6_CLIREM,(cAliasDUD)->DT6_LOJREM,(cAliasDUD)->REM_NOME,(cAliasDUD)->DT6_CLIDES, (cAliasDUD)->DT6_LOJDES,(cAliasDUD)->DES_NOME, (cAliasDUD)->DES_MUNICI, (cAliasDUD)->DES_UF })	
				EndIf 
			EndIf
			DUD->(DbSkip())
		EndDo
	EndIf
	If !lDocDisp
		Exit 
	EndIf 
	(cAliasDUD)->(DbSkip()) 		 
EndDo
(cAliasDUD)->(DbCloseArea())	

AEval(aAreas,{|x,y| RestArea(x) })

If Len(aDoctos) > 0 
	T500MntDoc(aDoctos) //--Tela de Manutenção de Documentos 
Else 
	Help( " ",1,"TMSAF6215") //-- Não foram localizados documentos para manutenção. 
EndIf 

//--Destroi o array aDoctos
aSize(aDoctos, 0)
aDoctos := Nil 

Return   

