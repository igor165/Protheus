#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "COLORS.CH"
	
Function GravaSub(nOpc,lLock)
Local nCont,nInd, nI, nPos := 0
Local lCentralObr := GetNewPar("MV_PLSEXCO",.F.)//Indica se o sistema utilizara a atualizacao automatica da central de obrigacoes sempre que um cadastro relevante for alterado no Protheus
Local lUsaSIP := "1" $ GetNewPar("MV_PLSTIPO","")
Local lUsaSIB := "2" $ GetNewPar("MV_PLSTIPO","")
Local lSIPSincrono := "1" $ GetNewPar("MV_PLOBRSI","1,2")
Local lSIBSincrono := "2" $ GetNewPar("MV_PLOBRSI","1,2")
LOCAL lCritSib := .F.
LOCAL lReturn := .F.
LOCAL cMvPLCDTIT := SuperGetMv("MV_PLCDTIT")

Local cTipTit := SuperGetMv("MV_PLCDTIT")

Local nQtdBenef := 0

Local aCritSib		:= {}
Local aOpcSip		:= {}
Local aDadCob		:= {}
Local aCmpSipAux	:= {}
Local aDadCobJob	:= {}
Local cAliasQry		:= GetNextAlias()


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Trata se for exclusao...                                            Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpcx == K_Excluir
	If ! PLSA660Exc("3",BG9->BG9_CODINT,BG9->BG9_CODIGO,.T.,BT5->BT5_NUMCON,BT5->BT5_VERSAO,M->BQC_SUBCON,M->BQC_VERSUB)
		Return
	Endif
Endif

If nOpcx <> K_Visualizar

	//Integracao HAT
	if GetNewPar("MV_PLSHAT","0") == "1"
		oBrwCobHAT := oBrwCob
		if oBrwCobHAT:lFilter
			oBrwCobHAT:endFilter(.f.)
		endIf

		oBrwGruHAT := oBrwGru
		if oBrwGruHAT:lFilter
			oBrwGruHAT:endFilter(.f.)
		endIf

		PLHAT660(nOpcx,cChave+M->BQC_SUBCON+M->BQD_VERSUB,oBrwCobHAT,oBrwGruHAT)
	endIf	

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicio da Transacao...                                            Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Begin Transaction
	
	If lNewVer
		nOpcx  := K_Incluir
		nOpc   := K_Incluir
	Endif
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza cadastro de contratos ...                                  Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nOpcx == K_Incluir
		M->BQC_CODIGO := Subs(cChave,1,8)
		M->BQC_NUMCON := Subs(cChave,9,12)
		M->BQC_VERCON := Subs(cChave,21,3)
		M->BQC_CODEMP := Right(M->BQC_CODIGO,Len(M->BQC_CODEMP))
	Endif
	PLUPTENC("BQC",nOpc)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Versoes...                                                          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	M->BQD_CODIGO := cChave
	M->BQD_CODINT := Subs(cChave,1,4)
	M->BQD_CDEMP  := Subs(cChave,5,4)
	M->BQD_NUMCON := Subs(cChave,9,12)
	M->BQD_VERCON := Subs(cChave,21,3)
	M->BQD_SUBCON := M->BQC_SUBCON
	PLUPTENC("BQD",nOpc)
	
	//Atualiza os endereГos dos beneficiАrios se necessАrio
	
	BeginSql Alias cAliasQry

		SELECT BA3.R_E_C_N_O_ AS BA3 ,BA1.R_E_C_N_O_ AS BA1
		FROM %Table:BA3% BA3, %Table:BA1% BA1
		WHERE

			BA1.BA1_FILIAL  =  %xFilial:BA1%    AND
			BA1.BA1_CODINT  =  BA3.BA3_CODINT	AND 
			BA1.BA1_CODEMP  =  BA3.BA3_CODEMP	AND
			BA1.BA1_CONEMP  =  BA3.BA3_CONEMP	AND 
			BA1.BA1_VERCON  =  BA3.BA3_VERCON	AND 
			BA1.BA1_SUBCON  =  BA3.BA3_SUBCON	AND 
			BA1.BA1_VERSUB  =  BA3.BA3_VERSUB	AND
			BA1.BA1_MATRIC  =  BA3.BA3_MATRIC	AND
			BA1.%NotDel% AND

			BA3.BA3_FILIAL  =  %xFilial:BA3%    	AND
			BA3.BA3_CODINT  =  %Exp:M->BQC_CODINT%	AND 
			BA3.BA3_CODEMP  =  %Exp:M->BQC_CODEMP%	AND
			BA3.BA3_CONEMP  =  %Exp:M->BQC_NUMCON%	AND 
			BA3.BA3_VERCON  =  %Exp:M->BQC_VERCON%	AND 
			BA3.BA3_SUBCON  =  %Exp:M->BQC_SUBCON%	AND 
			BA3.BA3_VERSUB  =  %Exp:M->BQC_VERSUB%	AND
			BA3.%NotDel%
			ORDER BY BA3_FILIAL, BA3_CODINT, BA3_CODEMP, BA3_MATRIC, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB
	EndSql	

	While !(cAliasQry)->( Eof() )

		nCodRecBA3 := (cAliasQry)->(BA3)
		BA3->(DbGoTo(nCodRecBA3))
		While !(cAliasQry)->( Eof() ) .And. (cAliasQry)->(BA3) == nCodRecBA3
		
			nCodRecBA1 := (cAliasQry)->(BA1)

			BA1->(DbGoTo(nCodRecBA1))
		
			If BA1->BA1_ORIEND == '3' //3=Subcontrato;

				cCepUsr := M->BQC_CEP
				cEndere := M->BQC_LOGRAD
				cBairro := M->BQC_BAIRRO
				cMunici := M->BQC_MUN
				cEstado := M->BQC_ESTADO
				cCodMun := M->BQC_CODMUN
				cNrEnd :=  M->BQC_NUMERO
				cComend := M->BQC_COMPLE
				cTipEnd := ""
				cResExt := ""
							
				RecLock("BA1", .F.)
				BA1->BA1_CEPUSR := cCepUsr 
				BA1->BA1_ENDERE := cEndere 
				BA1->BA1_BAIRRO := cBairro 
				BA1->BA1_MUNICI := cMunici 
				BA1->BA1_ESTADO := cEstado 
				BA1->BA1_CODMUN := cCodMun 
				BA1->BA1_NR_END := cNrEnd 
				BA1->BA1_COMEND := cComend 
				MsUnlock()
								
				//Rotina que trata e envia os dados dos beneficiАrios para a Central de ObrigaГУes
				If lCentralObr .AND. (lUsaSIP .OR.  lUsaSIB)
									
					If PlSibEnvANS(BA3->BA3_TIPOUS,BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_CONEMP,BA1->BA1_VERCON,	BA1->BA1_SUBCON,BA1->BA1_VERSUB,BA1->BA1_INFANS)
										//Primeiro monto o array com os dados do beneficiАrio oModel
						oModel := PlPrDadNio(aDadCob,,,lUsaSIP)
										
						oModel:SetValue( "B3KMASTER", 'B3K_OPESIB','2')//InclusЦo/AlteraГЦo*/
					
						//Chamo a rotina genИrica que atualiza o NЗcleo de InformaГУes da Central de ObrigaГУes
						If lSIPSincrono .OR. lSIBSincrono 
											
							cB3KMat	:= oModel:GetValue( "B3KMASTER", 'B3K_MATRIC')
							cNomBen	:= oModel:GetValue( "B3KMASTER", 'B3K_NOMBEN')
							aAdd(aCritSib,{cB3KMat,cNomBen,""})
							PLCGrvBen( oModel,.F.,aCritSib ) 
							DelClassInf()
						Else
							aAdd(aCmpSIPAux,oModel)
							aAdd(aOpcSip,K_Alterar)
							aAdd(aDadCobJob,aDadCob)
						EndIf
										
					EndIf
								
				EndIf

				//Se for titular, busco em todos os dependentes que puxam o endereГo do titular
				If BA1->BA1_TIPUSU == cMvPLCDTIT
									
					PlAtuEndTi(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),cCepUsr,cEndere,cBairro,	cMunici,cEstado,cCodMun,cNrEnd,cComend,	cTipEnd,cResExt)
									
				EndIf 

				nQtdBenef++
			EndIf 
							
			(cAliasQry)->( dbSkip() )
			
			If nCodRecBA3 <> (cAliasQry)->(BA3)
				Exit
			Endif
		EndDo

			
		If Len(aCmpSipAux) > 0
			StartJob("PLJOBNIO",GetEnvServer(),.F.,cEmpAnt,cFilAnt,	"B3K",aCmpSIPAux,nOpcx,.T./*lMult*/,aOpcSip,dDataBase,aDadCobJob)
		Else
			lCritSib := Len(aCritSib) > nQtdBenef
			If lCritSib
				PLSCRIGEN(aCritSib,{ {"Codigo Crit.","@C",5} , {"DescriГЦo","@C",200 } , {"SoluГЦo","@C",200 } }, "  CrМticas de BeneficiАrios  ")
				//Se nЦo permite gravar beneficiАrio criticados, sai da rotina.
				If lCritSib .AND. !GetNewPar("MV_PLGRCRI",.T.)
					MsgAlert("Foram encontradas crМticas do SIB no cadastro. NЦo serА possМvel realizar a gravaГЦo.") 
					lReturn := .T.
				EndIf
			EndIf
		EndIf
		
	EndDo

	(cAliasQry)->(DbCloseArea())
   
   If !lReturn
	    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	    //Ё Exclui Parametros do Sub-Contrato...                                Ё
		//Ё BQC_CODIGO = BYA_CODINT + BYA_CODIGO								Ё
		//Ё Alexander 06/04/2005		                                        Ё
	    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                            
	    If nOpcx == K_Excluir
	       BYA->( DbSetOrder(1)) //BYA_FILIAL + BYA_CODINT + BYA_CODIGO + BYA_NUMCON+ BYA_VERSAO + BYA_SUBCON + BYA_VERSUB + BYA_ANO + BYA_MES
	       If BYA->( MsSeek( M->( BQC_FILIAL + BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB ) ) )       
	          While !BYA->(EOF()) .And. M->( BQC_FILIAL + BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB ) == BYA->( BYA_FILIAL + BYA_CODINT + BYA_CODIGO + BYA_NUMCON + BYA_VERSAO + BYA_SUBCON + BYA_VERSUB)
		         PLUPTENC("BYA",nOpc)                     
	             BYA->(DBSkip())
	          EndDo
	       EndIf
		EndIf    
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Produtos relacionados...                                            Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwPro") == "O" 
			aChave := {}
			aadd(aChave,{"BT6_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BT6_CODIGO",Subs(cChave,5,4) })
			aadd(aChave,{"BT6_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BT6_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BT6_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BT6_VERSUB",M->BQD_VERSUB})
	
	     	If lNewVer
	       	   oBrwPro:lAltered := .T.
	       	Endif   
	
			oBrwPro:nOpc := nOpc
			oBrwPro:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BT6',aTrbPro)    
		Endif   
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grupo de coberturas...                                              Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwGru") == "O"
			aChave := {}
			aadd(aChave,{"BT7_CODINT",Subs(cChave,1,4)})
			aadd(aChave,{"BT7_CODIGO",Subs(cChave,5,4)})
			aadd(aChave,{"BT7_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BT7_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BT7_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BT7_VERSUB",M->BQD_VERSUB})
	
			oBrwGru:Consiste()
			oBrwGru:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BT7',aTrbGru)    
		Endif   
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grupo de Quantidades...                                             Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwQtd") == "O"
			aChave := {}
			aadd(aChave,{"BW5_CODINT",Subs(cChave,1,4)})
			aadd(aChave,{"BW5_CODIGO",Subs(cChave,5,4)})
			aadd(aChave,{"BW5_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BW5_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BW5_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BW5_VERSUB",M->BQD_VERSUB})
			
			oBrwQtd:nOpc := nOpc
			oBrwQtd:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BW5',aTrbQtd)    
		Endif   
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Co-Partic. Grupo de Quantidade...                                   Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grupo Coberturas x Co-Participacao                                  Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nOpc == K_Alterar .Or. nOpc == K_Incluir
			aChave := {}
			aadd(aChave,{"BHF_CODINT",Subs(cChave,1,4)})
			aadd(aChave,{"BHF_CODIGO",Subs(cChave,5,4)})
			aadd(aChave,{"BHF_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BHF_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BHF_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BHF_VERSUB",M->BQD_VERSUB})
			
			PlsConsiste(oBrwGru:aCols,oBrwGru:aHeader,{"BT7_CODPRO","BT7_VERPRO","BT7_CODGRU"},aDadcGru,aCabcGru,{"BHF_CODPRO","BHF_VERPRO","BHF_CODGRU"})			
			PLUPTCOLS('BHF',aDadcGru,aCabcGru,aTrbCGru,nOpc,aChave)

		ElseIf nOpc == K_Excluir
	   		A260DELREG('BHF',aTrbCGru)    
		Endif

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Coberturas ...                                                      Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwCob") == "O"
			aChave := {}
			aadd(aChave,{"BT8_CODINT",Subs(cChave,1,4)})
			aadd(aChave,{"BT8_CODIGO",Subs(cChave,5,4)})
			aadd(aChave,{"BT8_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BT8_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BT8_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BT8_VERSUB",M->BQD_VERSUB})

			oBrwCob:nOpc := nOpc
			oBrwCob:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BT8',aTrbCob)    
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Usuarios Permitidos...                                              Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwUsp") == "O"
			aChave := {}
			aadd(aChave,{"BT0_CODIGO",Subs(cChave,1,8)})
			aadd(aChave,{"BT0_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BT0_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BT0_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BT0_VERSUB",M->BQD_VERSUB})
		
			oBrwUsp:nOpc := nOpc
			oBrwUsp:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BT0',aTrbUsp)    
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Forma de Cobranca ...                                          Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwFor") == "O"
			aChave := {}
			aadd(aChave,{"BT9_CODIGO",Subs(cChave,1,8)})
			aadd(aChave,{"BT9_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BT9_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BT9_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BT9_VERSUB",M->BQD_VERSUB})
			
			oBrwFor:nOpc := nOpc
			oBrwFor:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BT9',aTrbFor)    
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Produtos X Tipo Prestador                                      Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwBGP") == "O"
			aChave := {}
			aadd(aChave,{"BGP_CODINT",Subs(cChave,1,4)})
			aadd(aChave,{"BGP_CODIGO",Subs(cChave,5,4)})
			aadd(aChave,{"BGP_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BGP_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BGP_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BGP_VERSUB",M->BQD_VERSUB})
			
			oBrwBGP:nOpc := nOpc
			oBrwBGP:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BGP',aTrbBGP)    
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Produtos X Municipio de Atendimento                            Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If PLSALIASEX("BGG") 
		    If Type("oBrwBGG") == "O"
				aChave := {}
				aadd(aChave,{"BGG_CODINT",Subs(cChave,1,4)})
				aadd(aChave,{"BGG_CODIGO",Subs(cChave,5,4)})
				aadd(aChave,{"BGG_NUMCON",Subs(cChave,9,12)})
				aadd(aChave,{"BGG_VERCON",Subs(cChave,21,3)})
				aadd(aChave,{"BGG_SUBCON",M->BQC_SUBCON})
				aadd(aChave,{"BGG_VERSUB",M->BQD_VERSUB})
				
				oBrwBGG:nOpc := nOpc
				oBrwBGG:Grava(aChave)
			ElseIf nOpc == K_Excluir
		   		A260DELREG('BGG',aTrbBGG)    
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Produtos X Tipo Prestador                                      Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nOpc == K_Alterar
				aChave := {}
				aadd(aChave,{"BGL_CODINT",Subs(cChave,1,4)})
				aadd(aChave,{"BGL_CODIGO",Subs(cChave,5,4)})
				aadd(aChave,{"BGL_NUMCON",Subs(cChave,9,12)})
				aadd(aChave,{"BGL_VERCON",Subs(cChave,21,3)})
				aadd(aChave,{"BGL_SUBCON",M->BQC_SUBCON})
				aadd(aChave,{"BGL_VERSUB",M->BQD_VERSUB})
				
				If Type("oBrwBGL") == "O"
					oBrwBGL:Consiste()
					oBrwBGL:nOpc := nOpc
					oBrwBGL:Grava(aChave)
				Else
					PlsConsiste(oBrwBGG:aCols,oBrwBGG:aHeader,{"BGG_CODPRO","BGG_VERPRO","BGG_CODMUN"},aDadBGL,aCabBGL,{"BGL_CODPRO","BGL_VERPRO","BGL_CODMUN"})
					PLUPTCOLS('BGL',aDadBGL,aCabBGL,aTrbBGL,nOpc,aChave)
				EndIf
			ElseIf nOpc == K_Excluir
		   		A260DELREG('BGL',aTrbBGL)    
			EndIf
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё SUB X PROD X FAT. MULT. REEMB 				                        Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwB33") == "O"
			aChave := {}
			aadd(aChave,{"B33_CODINT",Subs(cChave,1,4)})
			aadd(aChave,{"B33_CODIGO",Subs(cChave,5,4)})
			aadd(aChave,{"B33_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"B33_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"B33_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"B33_VERSUB",M->BQD_VERSUB})
			
			oBrwB33:nOpc := nOpc
			oBrwB33:Grava(aChave)
		ElseIf nOpc == K_Excluir
			A260DELREG('B33',aTrbB33)    
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё VIG SUB XPROD X FAT MULT REEMB                                      Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nOpc == K_Alterar
			aChave := {}
			aadd(aChave,{"B34_CODINT",Subs(cChave,1,4)})
			aadd(aChave,{"B34_CODIGO",Subs(cChave,5,4)})
			aadd(aChave,{"B34_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"B34_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"B34_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"B34_VERSUB",M->BQD_VERSUB})
			
			If Type("oBrwB34") == "O"
				oBrwB34:Consiste()
				oBrwB34:nOpc := nOpc
				oBrwB34:Grava(aChave)
			Else
				PlsConsiste(oBrwB33:aCols,oBrwB33:aHeader,{"B33_SEQUEN","B33_CODPRO","B33_VERSAO","B33_CLASSE"},aDadB34,aCabB34,{"B34_SEQUEN","B34_CODPRO","B34_VERSAO","B34_CLASSE"})
				PLUPTCOLS('B34',aDadB34,aCabB34,aTrbB34,nOpc,aChave)
			EndIf
		ElseIf nOpc == K_Excluir
			A260DELREG('B34',aTrbB34)    
		EndIf	
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Rede Referenciada Alexander 12/06/2005								Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If PLSALIASEX("BOR") 
			If Type("oBrwRDF") == "O"
				aChave := {}
				aadd(aChave,{"BOR_CODINT",Subs(cChave,1,4)})
				aadd(aChave,{"BOR_CODEMP",Subs(cChave,5,4)})
				aadd(aChave,{"BOR_NUMCON",Subs(cChave,9,12)})
				aadd(aChave,{"BOR_VERCON",Subs(cChave,21,3)})
				aadd(aChave,{"BOR_SUBCON",M->BQC_SUBCON})
				aadd(aChave,{"BOR_VERSUB",M->BQD_VERSUB})
			
				oBrwRDF:Consiste()
				oBrwRDF:Grava(aChave)               
			ElseIf nOpc == K_Excluir
		   		A260DELREG('BOR',aTrbRDF)    
			Endif
		EndIf	
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Produtos X Tipo Prestador                                      Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nOpc == K_Alterar
			aChave := {}
			aadd(aChave,{"BGS_CODINT",Subs(cChave,1,4)})
			aadd(aChave,{"BGS_CODIGO",Subs(cChave,5,4)})
			aadd(aChave,{"BGS_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BGS_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BGS_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BGS_VERSUB",M->BQD_VERSUB})
			
			If Type("oBrwBGS") == "O"
				oBrwBGS:Consiste()
				oBrwBGS:nOpc := nOpc
				oBrwBGS:Grava(aChave)
			Else
				PlsConsiste(oBrwBGP:aCols,oBrwBGP:aHeader,{"BGP_CODPRO","BGP_VERPRO","BGP_TIPPRE"},aDadBGS,aCabBGS,{"BGS_CODPRO","BGS_VERPRO","BGS_TIPPRE"})
				PLUPTCOLS('BGS',aDadBGS,aCabBGS,aTrbBGS,nOpc,aChave)
			Endif
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BGS',aTrbBGS)    
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Produto  x Co-Participacao                                          Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwCPro") == "O"
			aChave := {}
			aadd(aChave,{"BHG_CODINT",Subs(cChave,1,4)})
			aadd(aChave,{"BHG_CODIGO",Subs(cChave,5,4)})
			aadd(aChave,{"BHG_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BHG_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BHG_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BHG_VERSUB",M->BQD_VERSUB})
			
			oBrwCPro:nOpc := nOpc
			oBrwCPro:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BHG',aTrbCPro)    
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Produto  x Situacao Adversa                                         Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwSAD") == "O"
			aChave := {}
			aadd(aChave,{"BHN_CODINT",Subs(cChave,1,4)})
			aadd(aChave,{"BHN_CODIGO",Subs(cChave,5,4)})
			aadd(aChave,{"BHN_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BHN_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BHN_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BHN_VERSUB",M->BQD_VERSUB})
			
			oBrwSAD:nOpc := nOpc
			oBrwSAD:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BHN',aTrbSAD)    
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Produto  x Regras novos depedentes...                               Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwBEY") == "O"
			aChave := {}
			aadd(aChave,{"BEY_CODINT",Subs(cChave,1,4)})
			aadd(aChave,{"BEY_CODIGO",Subs(cChave,5,4)})
			aadd(aChave,{"BEY_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BEY_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BEY_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BEY_VERSUB",M->BQD_VERSUB})

			oBrwBEY:Consiste()
			oBrwBEY:nOpc := nOpc
			oBrwBEY:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BEY',aTrbBEY)    
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Produto  x Classe de Carencia                                       Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
		If Type("oBrwBA6") == "O"
			aChave := {}
			aadd(aChave,{"BA6_CODINT",Subs(cChave,1,4)})
			aadd(aChave,{"BA6_CODIGO",Subs(cChave,5,4)})
			aadd(aChave,{"BA6_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BA6_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BA6_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BA6_VERSUB",M->BQD_VERSUB})

			oBrwBA6:Consiste()
			oBrwBA6:nOpc := nOpc
			oBrwBA6:Grava(aChave)	
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BA6',aTrbBA6)    
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Produto x Cobranca da Co-Participacao                               Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwCobCP") == "O"
			aChave := {}
			aadd(aChave,{"BHX_CODINT",Subs(cChave,1,4)})
			aadd(aChave,{"BHX_CODIGO",Subs(cChave,5,4)})
			aadd(aChave,{"BHX_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BHX_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BHX_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BHX_VERSUB",M->BQD_VERSUB})
			
			oBrwCobCP:nOpc := nOpc
			oBrwCobCP:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BHX',aTrbCobCP)    
		Endif               
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Produto x Opcionais                                                 Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwOpc") == "O"           
			aChave := {}
			aadd(aChave,{"BHS_CODINT",Subs(cChave,1,4)})
			aadd(aChave,{"BHS_CODIGO",Subs(cChave,5,4)})
			aadd(aChave,{"BHS_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BHS_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BHS_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BHS_VERSUB",M->BQD_VERSUB})
			
			oBrwOpc:Consiste()
			oBrwOpc:nOpc := nOpc
			oBrwOpc:Grava(aChave)	
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BHS',aTrbOpc)    
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gravacao das Formas de Cobranca ...                            Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nInd := 1 To Len(aVetsFor)
			cAlias   := aVetsFor[nInd,2]
			cTipo    := aVetsFor[nInd,3]
			aVetTrab := aVetsFor[nInd,4]
			uTrbRec  := aVetsFor[nInd,5]
			cBrw	  := "oBrw"+cAlias
			
			If cTipo == "0" // Enchoice
				
				For nCont  := 1 To Len(aVetTrab)
					cDado  := aVetTrab[nCont,1]
					&cDado := aVetTrab[nCont,2]
				Next
				&("M->"+cAlias+"_CODIGO") := Subs(cChave,1,8)
				&("M->"+cAlias+"_NUMCON") := Subs(cChave,9,12)
				&("M->"+cAlias+"_VERCON") := Subs(cChave,21,3)
				&("M->"+cAlias+"_SUBCON") := M->BQC_SUBCON
				&("M->"+cAlias+"_VERSUB") := M->BQD_VERSUB
				If uTrbRec > 0
					(cAlias)->(DbGoTo(uTrbRec))
				Endif
				PLUPTENC(cAlias,If(uTrbRec==0,K_Incluir,nOpc))
			ElseIf cTipo == "1" // GetDados
				
				STORE HEADER cAlias TO aHeader For .T.
				aChave := {}
				aadd(aChave,{cAlias+"_CODIGO",Subs(cChave,1,8)})
				aadd(aChave,{cAlias+"_NUMCON",aVetsFor[nInd,6]})
				aadd(aChave,{cAlias+"_VERCON",aVetsFor[nInd,7]})
				aadd(aChave,{cAlias+"_SUBCON",aVetsFor[nInd,8]})
				If !lNewVer
					aadd(aChave,{cAlias+"_VERSUB",aVetsFor[nInd,9]})
				Else
					aadd(aChave,{cAlias+"_VERSUB",StrZero(Val(aVetsFor[nInd,9])+1,3)})
				EndIf
				
				For nI := 1 to Len(aVetTrab)
					nPos := Ascan(oBrwPro:Acols,{|x| x[1]+x[2] = aVetTrab[nI,1]+aVetTrab[nI,2]})
					
					If nPos > 0 .and. oBrwPro:Acols[nPos,Len(oBrwPro:aHeader)+1]
						aVetTrab[nI,Len(aHeader)+1] := .T.
					EndIf
				Next nI
				
				PLUPTCOLS(cAlias,aVetTrab,aHeader,uTrbRec,nOpc,aChave)
			Endif
		Next
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Forma de Cobranca dos Opcionais...                                  Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwFrOpc") == "O"
				
			aChave := {}
			aadd(aChave,{"BJW_CODIGO",Subs(cChave,1,8)})
			aadd(aChave,{"BJW_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BJW_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BJW_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BJW_VERSUB",M->BQD_VERSUB})
			
			oBrwFrOpc:Consiste()
			oBrwFrOpc:nOpc := nOpc
			oBrwFrOpc:Grava(aChave,.T.)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BJW',aTrbFrOpc)    
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gravacao das Formas de Cobranca dos Opcionais...                    Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nInd := 1 To Len(aVetsOpc)
			cAlias   := aVetsOpc[nInd,2]
			cTipo    := aVetsOpc[nInd,3]
			aVetTrab := aVetsOpc[nInd,4]
			uTrbRec  := aVetsOpc[nInd,5]
			cBrw	  := "oBrw"+cAlias
			
			If cTipo == "0" // Enchoice
				For nCont  := 1 To Len(aVetTrab)
					cDado  := aVetTrab[nCont,1]
					&cDado := aVetTrab[nCont,2]
				Next
				&("M->"+cAlias+"_CODIGO") := Subs(cChave,1,8)
				&("M->"+cAlias+"_NUMCON") := Subs(cChave,9,12)
				&("M->"+cAlias+"_VERCON") := Subs(cChave,21,3)
				&("M->"+cAlias+"_SUBCON") := M->BQC_SUBCON
				&("M->"+cAlias+"_VERSUB") := M->BQD_VERSUB
				
				If uTrbRec > 0
					(cAlias)->(DbGoTo(uTrbRec))
				Endif
				PLUPTENC(cAlias,If(uTrbRec==0,K_Incluir,nOpc))
			ElseIf cTipo == "1" // GetDados
			
				STORE HEADER cAlias TO aHeader For .T.
				aChave := {}
				aadd(aChave,{cAlias+"_CODIGO",Subs(cChave,1,8)})
				aadd(aChave,{cAlias+"_NUMCON",Subs(cChave,9,12)})
				aadd(aChave,{cAlias+"_VERCON",Subs(cChave,21,3)})
				aadd(aChave,{cAlias+"_SUBCON",M->BQC_SUBCON})
				aadd(aChave,{cAlias+"_VERSUB",M->BQC_VERSUB})
				
				For nI := 1 to Len(aVetTrab)
					nPos := Ascan(oBrwPro:Acols,{|x| x[1]+x[2] = aVetTrab[nI,1]+aVetTrab[nI,2]})
					
					If nPos > 0 .and. oBrwPro:Acols[nPos,Len(oBrwPro:aHeader)+1]
						aVetTrab[nI,Len(aHeader)+1] := .T.
					EndIf
				Next nI

				PLUPTCOLS(cAlias,aVetTrab,aHeader,uTrbRec,nOpc,aChave)
				
			Endif
		Next
		
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Tratamento Debitos...                                               Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	/*	
		If Type("oBrwDeb") == "O"
			aChave := {}
			aadd(aChave,{"BR5_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BR5_CODGRU",Subs(cChave,5,4) })
			aadd(aChave,{"BR5_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BR5_VERSAO",Subs(cChave,21,3)})
			aadd(aChave,{"BR5_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BR5_VERSUB",M->BQD_VERSUB})
			
			oBrwDeb:nOpc := nOpc
			oBrwDeb:Grava(aChave)	
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BR5',aTrbDeb)    
		Endif            
	*/	           
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Cobranca de Identificacao de Usuario                                Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwBJC") == "O"
			aChave := {}
			aadd(aChave,{"BJC_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BJC_CODEMP",Subs(cChave,5,4) })
			aadd(aChave,{"BJC_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BJC_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BJC_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BJC_VERSUB",M->BQD_VERSUB})
			
			oBrwBJC:nOpc := nOpc
			oBrwBJC:Grava(aChave)	
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BJC',aTrbBJC)    
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Docs. Obrigatorios do Usuario                                       Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwBCO") == "O"
			aChave := {}
			aadd(aChave,{"BCO_CODOPE",Subs(cChave,1,4) })
			aadd(aChave,{"BCO_CODEMP",Subs(cChave,5,4) })
			aadd(aChave,{"BCO_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BCO_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BCO_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BCO_VERSUB",M->BQD_VERSUB})
			
			oBrwBCO:nOpc := nOpc
			oBrwBCO:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BCO',aTrbBCO)    
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Tratamento Taxas de Adesao...                                       Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		
		If Type("oBrwAde") == "O"
			aChave := {}
			aadd(aChave,{"BTK_CODIGO",Subs(cChave,1,8)})
			aadd(aChave,{"BTK_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BTK_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BTK_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BTK_VERSUB",M->BQD_VERSUB})
		
			oBrwAde:nOpc := nOpc
			oBrwAde:Grava(aChave, .T.)	
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BTK',aTrbAde)    
		Endif                
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gravacao das Formas de Cobranca da Taxa de Adesao...                Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nInd := 1 To Len(aVetsTxF)
			cAlias   := aVetsTxF[nInd,2]
			cTipo    := aVetsTxF[nInd,3]
			aVetTrab := aVetsTxF[nInd,4]
			uTrbRec  := aVetsTxF[nInd,5]
			cBrw	  := "oBrw"+cAlias
			
			If     cTipo == "0" // Enchoice
				For nCont  := 1 To Len(aVetTrab)
					cDado  := aVetTrab[nCont,1]
					&cDado := aVetTrab[nCont,2]
				Next
				&("M->"+cAlias+"_CODIGO") := Subs(cChave,1,8)
				&("M->"+cAlias+"_NUMCON") := Subs(cChave,9,12)
				&("M->"+cAlias+"_VERCON") := Subs(cChave,21,3)
				&("M->"+cAlias+"_SUBCON") := M->BQC_SUBCON
				&("M->"+cAlias+"_VERSUB") := M->BQD_VERSUB
				
				If uTrbRec > 0
					(cAlias)->(DbGoTo(uTrbRec))
				Endif
				PLUPTENC(cAlias,If(uTrbRec==0,K_Incluir,nOpc))
			ElseIf cTipo == "1" // GetDados
				STORE HEADER cAlias TO aHeader For .T.
				aChave := {}
				aadd(aChave,{cAlias+"_CODIGO",Subs(cChave,1,8)})
				aadd(aChave,{cAlias+"_NUMCON",Subs(cChave,9,12)})
				aadd(aChave,{cAlias+"_VERCON",Subs(cChave,21,3)})
				aadd(aChave,{cAlias+"_SUBCON",M->BQC_SUBCON})
				aadd(aChave,{cAlias+"_VERSUB",M->BQC_VERSUB})
				PLUPTCOLS(cAlias,aVetTrab,aHeader,uTrbRec,nOpc,aChave)
			Endif
		Next
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava propriedades pagamento...                                     Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwPPg") == "O"
			aChave := {}
			aadd(aChave,{"BMF_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BMF_CODEMP",Subs(cChave,5,4) })
			aadd(aChave,{"BMF_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BMF_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BMF_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BMF_VERSUB",M->BQD_VERSUB})
		
			oBrwPPg:Consiste()
			oBrwPPg:nOpc := nOpc
			oBrwPPg:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BMF',aTrbPPg)    
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava propriedades pagamento x procedimento...                      Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwPPP") == "O"
			aChave := {}
			aadd(aChave,{"BMG_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BMG_CODEMP",Subs(cChave,5,4) })
			aadd(aChave,{"BMG_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BMG_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BMG_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BMG_VERSUB",M->BQD_VERSUB})
	
			oBrwPPP:Consiste()
			oBrwPPP:nOpc := nOpc
			oBrwPPP:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BMG',aTrbPPP)    
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava propriedades pagamento...                                     Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwBML") == "O"
			aChave := {}
			aadd(aChave,{"BML_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BML_CODEMP",Subs(cChave,5,4) })
			aadd(aChave,{"BML_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BML_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BML_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BML_VERSUB",M->BQD_VERSUB})
	
			oBrwBML:Consiste()
			oBrwBML:nOpc := nOpc
			oBrwBML:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BML',aTrbBML)    
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava propriedades pagamento x procedimento...                      Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwBMM") == "O"
			aChave := {}
			aadd(aChave,{"BMM_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BMM_CODEMP",Subs(cChave,5,4) })
			aadd(aChave,{"BMM_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BMM_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BMM_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BMM_VERSUB",M->BQD_VERSUB})
	
			oBrwBMM:Consiste()
			oBrwBMM:nOpc := nOpc
			oBrwBMM:Grava(aChave)	
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BMM',aTrbBMM)    
		Endif                
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava diferenciacao filme ...                                       Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If PLSALIASEX("BG6") .And. Type("oBrwBG6") == "O"
			aChave := {}
			aadd(aChave,{"BG6_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BG6_CODEMP",Subs(cChave,5,4) })
			aadd(aChave,{"BG6_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BG6_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BG6_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BG6_VERSUB",M->BQD_VERSUB})
			
			oBrwBG6:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BG6',aTrbBG6)    
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava informacoes Ans ...                                           Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If PLSALIASEX("BYU") .And. Type("oBrwBYU") == "O"
			aChave := {}
			aadd(aChave,{"BYU_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BYU_CODEMP",Subs(cChave,5,4) })
			aadd(aChave,{"BYU_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BYU_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BYU_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BYU_VERSUB",M->BQD_VERSUB})
			
			oBrwBYU:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BYU',aTrbBYU)    
		Endif
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava ProteГЦo Financeira ...                                       Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If PLSALIASEX("BDV") .And. Type("oBrwBDV") == "O"
			aChave := {}
			aadd(aChave,{"BDV_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BDV_CODEMP",Subs(cChave,5,4) })
			aadd(aChave,{"BDV_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BDV_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BDV_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BDV_VERSUB",M->BQD_VERSUB})
			
			oBrwBDV:Grava(aChave)
		ElseIf nOpc == K_Excluir .and. PLSALIASEX("BDV")
	   		A260DELREG('BDV',aTrbBDV)
		Endif
			
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava propriedades pagamento x OPERADORA                            Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If PLSALIASEX("BKA")
			If Type("oBrwBKA") == "O"
				aChave := {}
				aadd(aChave,{"BKA_CODINT",Subs(cChave,1,4) })
				aadd(aChave,{"BKA_CODEMP",Subs(cChave,5,4) })
				aadd(aChave,{"BKA_NUMCON",Subs(cChave,9,12)})
				aadd(aChave,{"BKA_VERCON",Subs(cChave,21,3)})
				aadd(aChave,{"BKA_SUBCON",M->BQC_SUBCON})
				aadd(aChave,{"BKA_VERSUB",M->BQD_VERSUB})
	
				oBrwBKA:Consiste()
				oBrwBKA:nOpc := nOpc
				oBrwBKA:Grava(aChave)
			ElseIf nOpc == K_Excluir
		   		A260DELREG('BKA',aTrbBKA)    
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava propriedades pagamento x OPERADORA                            Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If Type("oBrwBKB") == "O"
				aChave := {}
				aadd(aChave,{"BKB_CODINT",Subs(cChave,1,4) })
				aadd(aChave,{"BKB_CODEMP",Subs(cChave,5,4) })
				aadd(aChave,{"BKB_NUMCON",Subs(cChave,9,12)})
				aadd(aChave,{"BKB_VERCON",Subs(cChave,21,3)})
				aadd(aChave,{"BKB_SUBCON",M->BQC_SUBCON})
				aadd(aChave,{"BKB_VERSUB",M->BQD_VERSUB})
	
				oBrwBKB:Consiste()
				oBrwBKB:nOpc := nOpc
				oBrwBKB:Grava(aChave)
			ElseIf nOpc == K_Excluir
		   		A260DELREG('BKB',aTrbBKB)    
			EndIf
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava propriedades pagamento x prestador...                         Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwPPgPRE") == "O"
			aChave := {}
			aadd(aChave,{"BMH_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BMH_CODEMP",Subs(cChave,5,4) })
			aadd(aChave,{"BMH_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BMH_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BMH_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BMH_VERSUB",M->BQD_VERSUB})
	
			oBrwPPgPRE:Consiste()
			oBrwPPgPRE:nOpc := nOpc
			oBrwPPgPRE:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BMH',aTrbPPgPre)    
		EndIf              
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava propriedades pagamento x procedimento...                      Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwPPPPRE") == "O"
			aChave := {}
			aadd(aChave,{"BMI_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BMI_CODEMP",Subs(cChave,5,4) })
			aadd(aChave,{"BMI_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BMI_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BMI_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BMI_VERSUB",M->BQD_VERSUB})
	
			oBrwPPPPRE:Consiste()
			oBrwPPPPRE:nOpc := nOpc
			oBrwPPPPRE:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BMI',aTrbPPPPre)    
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Controle interno de troca de versao de plano...                     Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lNewVer
			dDataIni := M->BQD_DATINI
			cVersao  := M->BQD_VERSAO
			
			BQD->(DbSetOrder(1))
			BQD->(DbSeek(xFilial("BQD")+cChave+cSubCon+cVersao,.T.))
			BQD->(DbSkip(-1))
			
			BQD->(RecLock("BQD",.F.))
			BQD->BQD_DATFIN := (dDataIni-1)
			BQD->(MsUnLock())
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Libera Lock...                                                      Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lLock
			BQC->(MsUnLock())
		Endif
		
		
		// GRAVA BZC
		/*
		If Type("oGetBZC") == "O"
			aChave := {}
			aadd(aChave,{"BZC_CODIGO",Subs(cChave,1,8)})
			aadd(aChave,{"BZC_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BZC_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BZC_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BZC_VERSUB",M->BQD_VERSUB})
			
			oGetBZC:Grava(aChave, .F.)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BZC',aVetBZC)    
		EndIf
	*/	
		// GRAVA BZD
		
	/*	
		If Type("oGetBZD") == "O"
			aChave := {}
			aadd(aChave,{"BZD_CODIGO",Subs(cChave,1,8)})
			aadd(aChave,{"BZD_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BZD_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BZD_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BZD_VERSUB",M->BQD_VERSUB})
		
			oGetBZD:Grava(aChave, .F.)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BZD',aVetBZD)    
		EndIf
	*/	
		// GRAVA BZE
	/*	
		If Type("oGetBZE") == "O"
			aChave := {}
			aadd(aChave,{"BZE_CODIGO",Subs(cChave,1,8)})
			aadd(aChave,{"BZE_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BZE_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BZE_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BZE_VERSUB",M->BQD_VERSUB})
			
			oGetBZE:Grava(aChave, .F.)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BZE',aVetBZE)    
		EndIf
	
		// GRAVA BZF
		If Type("oGetBZF") == "O"
			aChave := {}
			aadd(aChave,{"BZF_CODIGO",Subs(cChave,1,8)})
			aadd(aChave,{"BZF_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BZF_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BZF_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BZF_VERSUB",M->BQD_VERSUB})
			
			oGetBZF:Grava(aChave, .F.)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BZF',aVetBZF)    
		EndIf         
		
		// GRAVA BZG
		If Type("oGetBZG") == "O"
			aChave := {}
			aadd(aChave,{"BZG_CODINT",Subs(cChave,1,4)})
			aadd(aChave,{"BZG_CODIGO",Subs(cChave,5,4)})
			aadd(aChave,{"BZG_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BZG_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BZG_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BZG_VERSUB",M->BQD_VERSUB})
		
			oGetBZG:Grava(aChave, .F.)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BZG',aVetBZG)    
		EndIf           
	*/	
		// GRAVA BZL
		If Type("oGetBZL") == "O"
			aChave := {}
			aadd(aChave,{"BZL_CODIGO",Subs(cChave,1,8)})
			aadd(aChave,{"BZL_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BZL_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BZL_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BZL_VERSUB",M->BQD_VERSUB})
			
			oGetBZL:Grava(aChave, .F.)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BZL',aVetBZL)    
		EndIf
		// GRAVA BZM
		If Type("oGetBZM") == "O"
			aChave := {}
			aadd(aChave,{"BZM_CODIGO",Subs(cChave,1,8)})
			aadd(aChave,{"BZM_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BZM_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BZM_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BZM_VERSUB",M->BQD_VERSUB})
				
			oGetBZM:Grava(aChave, .F.)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BZM',aVetBZM)    
		EndIf
		// GRAVA BZH
	/*	
		If Type("oGetBZH") == "O"
			aChave := {}
			aadd(aChave,{"BZH_CODINT",Subs(cChave,1,4)})
			aadd(aChave,{"BZH_CODIGO",Subs(cChave,5,4)})
			aadd(aChave,{"BZH_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BZH_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BZH_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BZH_VERSUB",M->BQD_VERSUB})
			
			oGetBZH:Grava(aChave, .F.)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BZH',aVetBZH)    
		EndIf           
		
		// GRAVA BZJ
		If Type("oGetBZJ") == "O"
			aChave := {}
			aadd(aChave,{"BZJ_CODIGO",Subs(cChave,1,8)})
			aadd(aChave,{"BZJ_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BZJ_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BZJ_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BZJ_VERSUB",M->BQD_VERSUB})
			
			oGetBZJ:Grava(aChave, .F.)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BZJ',aVetBZJ)    
		EndIf
		
		// GRAVA BZK
		If Type("oGetBZK") == "O"
			aChave := {}
			aadd(aChave,{"BZK_CODIGO",Subs(cChave,1,8)})
			aadd(aChave,{"BZK_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BZK_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BZK_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BZK_VERSUB",M->BQD_VERSUB})
			
			oGetBZK:Grava(aChave, .F.)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BZK',aVetBZK)    
		EndIf      
		// GRAVA BZI
		
		If Type("oGetBZI") == "O"
		   aChave := {}
		   aadd(aChave,{"BZI_CODIGO",Subs(cChave,1,8)})
		   aadd(aChave,{"BZI_NUMCON",Subs(cChave,9,12)})
		   aadd(aChave,{"BZI_VERCON",Subs(cChave,21,3)})
		   aadd(aChave,{"BZI_SUBCON",M->BQC_SUBCON})
		   aadd(aChave,{"BZI_VERSUB",M->BQD_VERSUB})
		   
		   oGetBZI:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BZI',aVetBZI)    
		EndIf
	*/	
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Coberturas x Co-Participacao                                        Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		
		// O objeto oBrwCCo sС И criado ao acionar o botЦo de co-participaГЦo da aba de procedimentos, caso contrario tenho que gravar dados ao incluir 
		//UM SUBCONTATO para os casos em que um produto que tenha informaГУes da tabela BHD (Produtos e Co-ParticipaГЦo    )
		If Type("oBrwCCo") == "O" .or.  (nOpc ==  K_Incluir .and.  Len(aDadCCo) > 0)
			aChave := {}
			aadd(aChave,{"BHE_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BHE_CODIGO",Subs(cChave,5,4) })
			aadd(aChave,{"BHE_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BHE_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BHE_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BHE_VERSUB",M->BQD_VERSUB})
			
			PlsConsiste(oBrwCob:aCols,oBrwCob:aHeader,{"BT8_CODPRO","BT8_VERPRO","BT8_CODPAD","BT8_CODPSA"},aDadCCo,aCabCCo,{"BHE_CODPRO","BHE_VERPRO","BHE_CODPAD","BHE_CODPSA"})			
			PLUPTCOLS('BHE',aDadCCo,aCabCCo,aTrbCCo,nOpc,aChave)
			
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BHE',aTrbCCo)    
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Coberturas x CID                                                    Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nOpc == K_Alterar 
			aChave := {}
			aadd(aChave,{"BLU_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BLU_CODIGO",Subs(cChave,5,4) })
			aadd(aChave,{"BLU_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BLU_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BLU_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BLU_VERSUB",M->BQD_VERSUB})
			
			If Type("oBrwBLU") == "O"
				oBrwBLU:Consiste()
				oBrwBLU:nOpc := nOpc
				oBrwBLU:Grava(aChave, .F.)
			Else
				PlsConsiste(oBrwCob:aCols,oBrwCob:aHeader,{"BT8_CODPRO","BT8_VERPRO","BT8_CODPAD","BT8_CODPSA"},aDadBLU,aCabBLU,{"BLU_CODPRO","BLU_VERPRO","BLU_CODPAD","BLU_CODPSA"})
				PLUPTCOLS('BLU',aDadBLU,aCabBLU,aTrbBLU,nOpc,aChave)
			EndIf
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BLU',aTrbBLU)    
		EndIf
	
		If nOpc == K_Alterar
			aChave := {}
			aadd(aChave,{"BLW_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BLW_CODIGO",Subs(cChave,5,4) })
			aadd(aChave,{"BLW_NUMCON",Subs(cChave,9,12) })
			aadd(aChave,{"BLW_VERCON",Subs(cChave,21,3) })
			aadd(aChave,{"BLW_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"BLW_VERSUB",M->BQD_VERSUB})
	
			If Type("oBrwBLW") == "O"
				oBrwBLW:Consiste()
				oBrwBLW:nOpc := nOpc
				oBrwBLW:Grava(aChave)
			Else
				PlsConsiste(aDadBLU,aCabBLU,{"BLU_CODPRO","BLU_VERPRO","BLU_CODPAD","BLU_CODPSA","BLU_CID","BLU_SEQUEN"},aDadBLW,aCabBLW,{"BLW_CODPRO","BLW_VERPRO","BLW_CODPAD","BLW_CODPSA","BLW_CID","BLW_SEQUEN"})
				PLUPTCOLS('BLW',aDadBLW,aCabBLW,aTrbBLW,nOpc,aChave)
			EndIf
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BLW',aTrbBLW)    
		EndIf                   
		
		If nOpc == K_Alterar
			aChave := {}
			aadd(aChave,{"BLT_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BLT_CODIGO",Subs(cChave,5,4) })
			aadd(aChave,{"BLT_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BLT_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BLT_SUBCON",M->BQC_SUBCON		})
			aadd(aChave,{"BLT_VERSUB",M->BQD_VERSUB		})
			
			PlsConsiste(oBrwCob:aCols,oBrwCob:aHeader,{"BT8_CODPRO","BT8_VERPRO","BT8_CODPAD","BT8_CODPSA"},aDadBLT,aCabBLT,{"BLT_CODPRO","BLT_VERPRO","BLT_CODPAD","BLT_CODPSA"})
			PLUPTCOLS('BLT',aDadBLT,aCabBLT,aTrbBLT,nOpc,aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BLT',aTrbBLT)    
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Coberturas x Especialidade X CID                                    Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nOpc == K_Alterar
			aChave := {}
			aadd(aChave,{"BLX_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BLX_CODIGO",Subs(cChave,5,4) })
			aadd(aChave,{"BLX_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BLX_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BLX_SUBCON",M->BQC_SUBCON		})
			aadd(aChave,{"BLX_VERSUB",M->BQD_VERSUB		})
			
			PlsConsiste(aDadBLT,aCabBLT,{"BLT_CODPRO","BLT_VERPRO","BLT_CODPAD","BLT_CODPSA","BLT_CODESP","BLT_SEQUEN"},aDadBLX,aCabBLX,{"BLX_CODPRO","BLX_VERPRO","BLX_CODPAD","BLX_CODPSA","BLX_CODESP","BLX_SEQUEN"})
			PLUPTCOLS('BLX',aDadBLX,aCabBLX,aTrbBLX,nOpc,aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BLX',aTrbBLX)    
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Coberturas x Co-Participacao                                        Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	/*	
		If Type("oBrwPc") == "O"
			aChave := {}
			aadd(aChave,{"BWF_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BWF_CODEMP",Subs(cChave,5,4) })
			aadd(aChave,{"BWF_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BWF_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BWF_SUBCON",M->BQC_SUBCON		})
			aadd(aChave,{"BWF_VERSUB",M->BQD_VERSUB		})
			
			oBrwPc:Grava(aChave)		
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BWF',aTrbPc)    
		EndIf
	*/	
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Clas.Caren. novos Dep. SubCont						                Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Type("oBrwBWV") == "O"
			aChave := {}
			aadd(aChave,{"BWV_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"BWV_CODIGO",Subs(cChave,5,4) })
			aadd(aChave,{"BWV_NUMCON",Subs(cChave,9,12)})
			aadd(aChave,{"BWV_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"BWV_SUBCON",M->BQC_SUBCON		})
			aadd(aChave,{"BWV_VERSUB",M->BQD_VERSUB		})
			
			oBrwBWV:Grava(aChave)		
		ElseIf nOpc == K_Excluir
	   		A260DELREG('BWV',aTrbBWV)    
		EndIf
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava regras de reajuste...                                     Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If PLSALIASEX("B77") .And. Type("oBrwB77") == "O"
			aChave := {}
			aadd(aChave,{"B77_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"B77_CODEMP",Subs(cChave,5,4) })
			aadd(aChave,{"B77_CONEMP",Subs(cChave,9,12)})
			aadd(aChave,{"B77_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"B77_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"B77_VERSUB",M->BQD_VERSUB})
			
			oBrwB77:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('B77',aTrbB77)    
		Endif 
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava regras de parcelamento...                                     Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If PLSALIASEX("B81") .And. Type("oBrwB81") == "O"
			aChave := {}
			aadd(aChave,{"B81_CODINT",Subs(cChave,1,4) })
			aadd(aChave,{"B81_CODEMP",Subs(cChave,5,4) })
			aadd(aChave,{"B81_CONEMP",Subs(cChave,9,12)})
			aadd(aChave,{"B81_VERCON",Subs(cChave,21,3)})
			aadd(aChave,{"B81_SUBCON",M->BQC_SUBCON})
			aadd(aChave,{"B81_VERSUB",M->BQD_VERSUB})
			
			oBrwB81:Grava(aChave)
		ElseIf nOpc == K_Excluir
	   		A260DELREG('B81',aTrbB81)    
		Endif
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Fim do controle de semafaro iniciado em PLSA660OK                   Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nOpcx == K_Incluir
			PLSFechaSem(nHS,"PLSA660S.SMF")
		Endif
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Fim da Transacao...                                                 Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
   EndIf
   
   End Transaction
	
	If !lReturn
		If ExistBlock("PLSSUBMN")
		   ExecBlock("PLSSUBMN",.F.,.F.,{nOpc})
		Endif
	EndIf	
Endif

Return

