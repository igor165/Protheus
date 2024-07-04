#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECA900.CH"
#INCLUDE "FILEIO.CH"   
#INCLUDE "TOPCONN.CH"

//Define Atraso, Saida Antecipada, Hora Extra Conforme Tabela I5 - SX5
#DEFINE I5_ATRASO		'02'
#DEFINE I5_SAIANT		'03'
#DEFINE I5_HREXTR		'04'
#DEFINE I5_MANUT		'01' //Falta

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA900()

Realiza a Geração Automatica de Atendimentos da O.S quando utilizar o Controle Alocação

/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA900(lAutomato, aParams)

Local aArea			:= GetArea()
Local cIdcfal		:= Space(TamSX3("ABB_IDCFAL")[1])
Local cCondicao		:= ""
Local cMsg			:= ""
Local nTotal		:= 0
Local oDlg
Local oMeter
Local nMeter
Local nX
Local oPanTop
Local oPanBot
Local oSayMsg
Local oSay
Local oFont
Local lMobile 	:= SuperGetMV("MV_GSHRPON",.F., "2") == "1"
Local lInsert
Local lHasPerg	:= TecHasPerg("MV_PAR01","TEC900A")	
Local lGsGerOs	:= SuperGetMV("MV_GSGEROS",.F.,"1") == "1" //Gera O.S na rotina de geração de atendimento do gestão de serviços 1 = Sim e 2 = Não.
Local cPergTec	:= Iif(lGsGerOs,"TEC900","TEC900A")
Local lMultFil	:= Iif(lGsGerOs,TecHasPerg("MV_PAR17","TEC900"),TecHasPerg("MV_PAR10","TEC900A"))
Local aMtFil	:= {}
Local cFilBkp	:= cFilAnt
Local cTitTela	:= ""
Local cTexMsg	:= "" 
Local nTotGeral := 0


//----------------------------------------------------------------------------
// Parametros Utilizados no Pergunte TEC900                                                            
// 
// MV_PAR01: Atendente De ?
// MV_PAR02: Atendente Ate ?                                               	  
// MV_PAR03: Data Inicio De ?                                                     
// MV_PAR04: Data Inicio Ate ?                                                                                                    
// MV_PAR05: Cliente De ? 
// MV_PAR06: Cliente Ate ?
// MV_PAR07: Contrato De ?
// MV_PAR08: Contrato Ate ?
// MV_PAR09: O.S. De ?
// MV_PAR10: O.S. Ate ?
// MV_PAR11: Serviço Padrao ?         
// MV_PAR12: Local De ?
// MV_PAR13: Local Ate ?                         			  
// MV_PAR14: Supervisor de ?               
// MV_PAR15: Supervisor ate ?              
// MV_PAR16: Operação ?
// MV_PAR17: Filial ?

// Parametros Utilizados no Pergunte TEC900A                                                            
// 
// MV_PAR01: Atendente De ?
// MV_PAR02: Atendente Ate ?                                               	  
// MV_PAR03: Data Inicio De ?                                                     
// MV_PAR04: Data Inicio Ate ?                                                                                                    
// MV_PAR05: Cliente De ? 
// MV_PAR06: Cliente Ate ?
// MV_PAR07: Local De ?
// MV_PAR08: Local Ate ?                         			  
// MV_PAR09: Operação ?
// MV_PAR10: Filial ?
//------------------------------------------------------------------------------

Default lAutomato := IsBlind()
Default aParams := {}

If ( !lAutomato .AND. ((FindFunction("U_PNMSESC") .And. FindFunction("U_PNMSCAL")) .OR. ( FindFunction( "TecExecPNM" ) .AND. TecExecPNM() )) .AND. lGsGerOs )
	At900Avis()
EndIf

If lHasPerg .OR. lGsGerOs
	If Empty(aParams)
		lContinua := Pergunte(cPergTec,.T.)
	Else
		lContinua := .T.
		Pergunte(cPergTec,.F.)
		MV_PAR01 := aParams[1]
		MV_PAR02 := aParams[2]
		MV_PAR03 := aParams[3]
		MV_PAR04 := aParams[4]
		MV_PAR05 := aParams[5]
		MV_PAR06 := aParams[6]
		MV_PAR07 := aParams[7]
		MV_PAR08 := aParams[8]
		MV_PAR09 := aParams[9]
		If LEN(aParams) >= 10 .AND. cPergTec == "TEC900A"
			MV_PAR10 := aParams[10]
		EndIf
	EndIf
Else
	Help(,,"At900Perg", , STR0058, 1, 0) //Para utilizar a rotina com o parâmetro MV_GSGEROS = 2, é necessário criar o pergunte TEC990A, indicado no TDN.
	lContinua := .F.
EndIf

If lMobile
	If !( ABB->(ColumnPos('ABB_HRCHIN')) > 0 ) .OR. !( ABB->(ColumnPos('ABB_HRCOUT')) > 0 ) 
		lContinua := .F.
		cMsg := STR0049 + CRLF // "Verificamos que existe integração com o APP."
		cMsg += STR0050 + CRLF // "O(s) Campo(s) ABB_HRCHIN e ou ABB_HRCOUT não estão devidamentes criados. O procedimento não será completado."
		cMsg += STR0051 + CRLF // "Por favor realize a criação do campo ou desligue a integração. "
		
		AtShowLog( cMsg, STR0052, .T., .T., .T., .F. ) //"Integração APP"   

	EndIf
EndIf

If lContinua

	If lGsGerOs
		lInsert := !(TecHasPerg("MV_PAR16",cPergTec)) .OR. MV_PAR16 <> 2
	Else
		lInsert := MV_PAR09 <> 2
	Endif

	If lMultFil

		If lGsGerOs .And. (lMultFil := !Empty(MV_PAR17))
			lContinua := At900PMtFl(MV_PAR17,@aMtFil,cPergTec,"MV_PAR17")
		Elseif !lGsGerOs .And. (lMultFil := !Empty(MV_PAR10))
			lContinua := At900PMtFl(MV_PAR10,@aMtFil,cPergTec,"MV_PAR10")
		Endif

	Endif

	If !lMultFil 
		aMtFil := {cFilAnt}
	Endif

	If lContinua
		For nX := 1 To LEN(aMtFil)
			
			lContinua := .T.
			cCondicao := ""
			nTotal 	  := 0
			
			If lMultFil .And. cFilAnt <> aMtFil[nX]
				cFilAnt := aMtFil[nX]
			Endif
			
			If lContinua .AND. lGsGerOs .And. ((Empty(MV_PAR11)  .OR. !ExistCpo("AA5", MV_PAR11, 1)))
				If lMultFil
					Aviso(STR0001+STR0053+cFilAnt,STR0003,{STR0002},2) //"Atenção"##" - Filial "##"Um código de Serviço Padrão para geração do atendimento deve ser obrigatoriamente preenchido."##OK!
				Else	
					Aviso(STR0001,STR0003,{STR0002},2) //"Atenção"##"Um código de Serviço Padrão para geração do atendimento deve ser obrigatoriamente preenchido."##OK!
				Endif
			ElseIf lContinua
				//Ativo, Chegou como Nao e Atendeu tambem Nao.
				cCondicao += "ABB.ABB_IDCFAL != '"+cIdcfal+"' AND " 
				cCondicao += "ABB.ABB_ATIVO = '1' AND "
				If lInsert
					If lMobile
						cCondicao += "( ABB.ABB_CHEGOU = 'N' OR (ABB.ABB_CHEGOU = 'S' AND ABB.ABB_HRCHIN != '" + SPACE(TamSX3("ABB_HRCHIN")[1]) + "')) AND "
						cCondicao += "( ABB.ABB_ATENDE = '2' OR (ABB.ABB_ATENDE = '1' AND ABB.ABB_HRCHIN != '" + SPACE(TamSX3("ABB_HRCHIN")[1]) + "')) AND " 
					Else
						cCondicao += "ABB.ABB_CHEGOU = 'N' AND "
						cCondicao += "ABB.ABB_ATENDE = '2' AND " 
					EndIf 
				Else
					cCondicao += "ABB.ABB_CHEGOU = 'S' AND "
					cCondicao += "ABB.ABB_ATENDE = '1' AND "

					If lGsGerOs
						cCondicao += "ABB.ABB_NUMOS <> '" + SPACE(TamSX3("ABB_NUMOS")[1]) + "' AND "  
					Else
						cCondicao += "ABB.ABB_NUMOS = '" + SPACE(TamSX3("ABB_NUMOS")[1]) + "' AND "  
					Endif

				EndIf
				//Filtro Tecnico De e Ate		
				If !Empty(MV_PAR01)
					cCondicao += "ABB.ABB_CODTEC >='" + MV_PAR01 + "' AND "
				EndIf						
				If !Empty(MV_PAR02)
					cCondicao += "ABB.ABB_CODTEC <='" + MV_PAR02 + "' AND "
				EndIf
				
				//Filtra De/Ate
				If !Empty(MV_PAR03)
					cCondicao += "TDV.TDV_DTREF >='" + DToS( MV_PAR03 ) + "' AND " 	
				EndIf		

				If !Empty(MV_PAR04)		
					cCondicao += "TDV.TDV_DTREF <='" + DToS( MV_PAR04 ) + "' AND "
				EndIf

				If lGsGerOs
					
					If lMultFil
						cTitTela := STR0004+STR0054+cFilAnt //"Geração do atendimento da O.S."##" Filial: "
					Else
						cTitTela := STR0004	//"Geração do atendimento da O.S."
					Endif

					If lInsert
						// Adiciona consistencia para os agendamentos sem O.S.
						If	!Empty(MV_PAR05) .Or. !Empty(MV_PAR06) .Or. ;
							!Empty(MV_PAR07) .Or. !Empty(MV_PAR08) .Or. ;
							!Empty(MV_PAR09) .Or. !Empty(MV_PAR10)		
							cCondicao += "(ABB.ABB_NUMOS = '" + SPACE(TamSX3("ABB_NUMOS")[1]) + "'  OR ("
						EndIf
					EndIf
					
					//Cliente De/Ate
					If !Empty(MV_PAR05)		
						cCondicao += "AB6.AB6_CODCLI >='" + MV_PAR05 + "' AND " 	
					EndIf		
					If !Empty(MV_PAR06)		
						cCondicao += "AB6.AB6_CODCLI <='" + MV_PAR06 + "' AND "
					EndIf						
					
					//Contrato De e Ate
					If !Empty(MV_PAR07)
						cCondicao += "AB6.AB6_CONTRT >='" + MV_PAR07 + "' AND "	
					EndIf		
					If !Empty(MV_PAR08)
						cCondicao += "AB6.AB6_CONTRT <='" + MV_PAR08 + "' AND "			
					EndIf
					
					//O.S. De e Ate
					If !Empty(MV_PAR09)
						cCondicao += "AB6.AB6_NUMOS >='" + MV_PAR09 + "' AND "	
					EndIf			
					If !Empty(MV_PAR10)
						cCondicao += "AB6.AB6_NUMOS <='" + MV_PAR10 + "' AND "			
					EndIf

					If lInsert
						// Adiciona consistencia para os agendamentos sem O.S.
						If	!Empty(MV_PAR05) .Or. !Empty(MV_PAR06) .Or. ;
							!Empty(MV_PAR07) .Or. !Empty(MV_PAR08) .Or. ;
							!Empty(MV_PAR09) .Or. !Empty(MV_PAR10)
							If AllTrim(Right(cCondicao, 4)) == "AND"
								cCondicao := Substr(cCondicao, 1, Len(Alltrim(cCondicao)) - 4) + ")) AND "
							Else 
								cCondicao += ")) AND "
							EndIf	
						EndIf
					EndIf

					//Local De e Ate
					If !Empty(MV_PAR12)
						cCondicao += "ABB.ABB_LOCAL >='" + MV_PAR12 + "' AND "
					EndIf
					If !Empty(MV_PAR13)
						cCondicao += "ABB.ABB_LOCAL <='" + MV_PAR13 + "' AND "
					EndIf			
				Else
					
					If lMultFil
						cTitTela := STR0036+STR0054+cFilAnt //"Geração do Atendimento de Agenda."##" Filial: " 
					Else
						cTitTela := STR0036 //"Geração do Atendimento de Agenda."  					
					Endif
					
					//Local De e Ate
					If !Empty(MV_PAR07)
						cCondicao += "ABB.ABB_LOCAL >='" + MV_PAR07 + "' AND "
					EndIf
					If !Empty(MV_PAR08)
						cCondicao += "ABB.ABB_LOCAL <='" + MV_PAR08 + "' AND "
					EndIf				
				Endif
				
				If !Empty(MV_PAR05)		
					cCondicao += "ABS.ABS_CODIGO >='" + MV_PAR05 + "' AND " 	
				EndIf		
				If !Empty(MV_PAR06)		
					cCondicao += "ABS.ABS_CODIGO <='" + MV_PAR06 + "' AND "
				EndIf		
						
				cAliasUI := At900Qry(@cCondicao)
				
				DbSelectArea(cAliasUI)
				While !(cAliasUI)->(EOF())	
					nTotGeral++
					nTotal++
					(cAliasUI)->(DbSkip())
				End
				
				(cAliasUI)->(DbGoTop())	
				If nTotal > 0 
					If !lAutomato
						DEFINE MSDIALOG oDlg TITLE cTitTela FROM 0,0 TO 100,422 PIXEL STYLE DS_MODALFRAME //"Geração do Atendimento da O.S."
							oPanTop := TPanel():New( 0, 0, , oDlg, , , , , , 0, 0, ,  )
							oPanTop:Align := CONTROL_ALIGN_ALLCLIENT     
							
							oPanBot := TPanel():New( 0, 0, , oDlg, , , , ,/*CLR_YELLOW*/, 0, 25 , )
							oPanBot:Align := CONTROL_ALIGN_BOTTOM
							
							DEFINE FONT oFont NAME "Arial" SIZE 0,16
							@ 05,08 SAY oSay Var "<center>" + STR0005 + cValToChar(nTotal)+STR0006 + "</center>" PIXEL SIZE 210,65 HTML FONT oFont PIXEL OF oPanTop //"Serão processados "##" atendimentos."
								
							nMeter := 0
							oMeter := TMeter():New(02,7,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oPanBot,200,100,,.T.,,,.F.)			
							
							@ 10,02 SAY oSayMsg Var "<center>"+STR0007+"</center>" PIXEL SIZE 210,65 HTML FONT oFont PIXEL OF oPanBot //"Processando..."
												
						ACTIVATE DIALOG oDlg CENTERED ON INIT At900Proc(cAliasUI,oDlg,oMeter,oSayMsg,lInsert,lAutomato, @cTexMsg)
						
					Else
						At900Proc(cAliasUI,nil,nil,nil,lInsert, lAutomato,@cTexMsg)							
					EndIf
				Else
		
				If lMultFil	
					cTexMsg += STR0001+STR0053+cFIlAnt+","+STR0008+","+STR0002+CRLF  //"Atenção"##" - Filial "##"Não há registros para gerar atendimento conforme parametros informados."##{"OK"}			 				 
				else
					cTexMsg += STR0001+","+STR0008+","+STR0002 //"Atenção"##"Não há registros para gerar atendimento conforme parametros informados."##{"OK"}							
				Endif
			EndIf	
				(cAliasUI)->(DbCloseArea())			
			EndIf
			RestArea( aArea )
		Next nX	
		If !(isBlind())
			AtShowLog(cTexMsg,STR0001,.T.,.T.,.T.,.F.) 
		EndIf
	Endif		
Endif

If lMultFil .And. cFilBkp <> cFilAnt
	cFilAnt := cFilBkp
Endif

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At900Proc

@description Processa a inclusão ou exclusão dos atendimentos
@author	Mateus Boiani
@since	30/04/2019
/*/
//------------------------------------------------------------------------------
Static Function At900Proc(cAliasUI,oDlg,oMeter,oSayMsg,lInsert, lAutomato, cTexMsg)

Local lRet := .F.
Default lInsert := .T.

If lInsert
	lRet := At900GerAt(cAliasUI,oDlg,oMeter,oSayMsg, lAutomato, @cTexMsg)	
Else
	lRet := At900DelAt(cAliasUI,oDlg,oMeter,oSayMsg, lAutomato, @cTexMsg)	
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At900GerAt()

Realiza o Processamento do Pergunte na geração do Atendimento da O.S

@param ExpC:Alias da Tabela de processamento
@param ExpO:Dialog do Processamento
@param ExpO:Tmeter para atualizar o processamento
@param ExpO:Texto do processamento

@return ExpL: Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At900GerAt(cAliasUI,oDlg,oMeter,oSayMsg, lAutomato, cTexMsg)
Local cServico		:= MV_PAR11							// Codigo Serviço Padrao
Local cServExt		:= MV_PAR11							// Serviço para Hora Extra
Local nReg			:= 0								// Contador Gauge/Tmeter
Local aSeqTec		:= {}								// Sequencia dos Tecnicos
Local aAtende		:= {}
Local aItAten		:= {}
Local aChaveAA3		:= {}
Local aOsContrt		:= {}
Local nPosTec		:= 0
Local dDataIni
Local cHoraIni
Local dDataFim
Local cHoraFim
Local nI
Local cSequencia	:= "01"
Local nTamItem		:= TamSX3("ABA_ITEM")[1]
Local nHrTotal		:= 0								//Total de Horas 
Local nHrExtra		:= 0								//Total de Horas Extras
Local nHrNormal		:= 0								//Total de Horas Normais
Local aCritica		:= {}
Local lGrpCob		:= .F.
Local nTamChave 	:= TamSX3("AB7_NUMOS")[1]+TamSX3("AB7_ITEM")[1]	
Local lContinua		:= .T.	
Local cCodGrup		:= ""
Local cErro			:= ""
Local cCondPV		:= ""
Local cTpCont		:= ""
Local cChave     	:= ""
Local cOsLocal		:= ""
Local cItemOS		:= ""
Local lGerOS		:= .F.
Local cOcoGct		:= SuperGetMV("MV_OCOGCT",.F.,"")
Local lOrcSimp		:= .F.
Local aArea
Local cCodEnt		:= ""
Local cCodLoja		:= ""
Local lHasOrcSim	:= HasOrcSimp()
Local lGsGerOs		:= SuperGetMV("MV_GSGEROS",.F.,"1") == "1" //Gera O.S na rotina de geração de atendimento do gestão de serviços 1 = Sim e 2 = Não.
Local cBsError 		:= ""
Local lMultFil		:= Iif(lGsGerOs,TecHasPerg("MV_PAR17","TEC900") .And. !Empty(MV_PAR17),TecHasPerg("MV_PAR10","TEC900A") .And. !Empty(MV_PAR10))

(cAliasUI)->(dbGoTop())

DbSelectArea("AAB")

While (cAliasUI)->(!Eof())	
	cBsError	:= ""
	aBsError 	:= {}
	
	If !lAutomato
		oMeter:Set(++nReg) // Atualiza Gauge/Tmeter
		oSayMsg:SetText("<center>"+STR0007+cValToChar(nReg)+"</center>")//"Processando..."
	EndIf

	If lGsGerOs
		//Inicializa Variaveis e Datas
		dDataIni	:= (cAliasUI)->ABB_DTINI
		cHoraIni	:= (cAliasUI)->ABB_HRINI
		dDataFim	:= (cAliasUI)->ABB_DTFIM
		cHoraFim	:= (cAliasUI)->ABB_HRFIM
		cServico	:= MV_PAR11
		cServExt	:= MV_PAR11
		nHrExtra	:= 0
		nHrNormal	:= 0
		lGrpCob	:= .F.	
		lContinua	:= .T.
		cCodGrup	:= ""	
		cChave		:= ""
		lGerOs		:= .F. 
					
		If Empty((cAliasUI)->ABB_NUMOS)			
			nPosOs := aScan(aOsContrt, {|x| x[1] == (cAliasUI)->ABB_IDCFAL } )		 	
			If nPosOs == 0	
				lGerOs := .T.
			Else	
				cChave := aOsContrt[nPosOs][2]
			Endif 		
		Else 
			//verifica se a ordem de serviço está em Atendimento ou Aberta
			If At900OS((cAliasUI)->ABB_NUMOS)
				nPosOs := aScan(aOsContrt, {|x| x[1] == (cAliasUI)->ABB_IDCFAL } )		 	
				If nPosOs == 0	
					lGerOs := .T.
				Else	
					cChave := aOsContrt[nPosOs][2]
				Endif 	
			EndIf
		EndIf
		
		If lGerOs
		
			// Gerar O.S. para apontamento quando o agedamento for pela nova estrutura		
			aArea := GetArea()		
					
			aChaveAA3 := At900BaseCM(cAliasUI, (cAliasUI)->ABQ_CONTRT,(cAliasUI)->ABQ_ORIGEM, (cAliasUI)->ABQ_CODTFF, @cBsError)					
			
			If Len(aChaveAA3) > 0
				If (cAliasUI)->ABQ_ORIGEM == "CN9"
					
					If !lHasOrcSim
						cCodProp := At900GetPro((cAliasUI)->ABQ_CONTRT, (cAliasUI)->ABQ_CODTFF)
					Else
						cCodProp := At900GetPro((cAliasUI)->ABQ_CONTRT, (cAliasUI)->ABQ_CODTFF, @lOrcSimp, @cCodEnt, @cCodLoja)  
					EndIf
					
					cCondPV  := Posicione("CN9", 1, xFilial("CN9")+(cAliasUI)->ABQ_CONTRT, "CN9_CONDPG")						
					cOcorren := cOcoGct
					cTpCont  := "3"
					
					AAG->(dbSetOrder(1))
					
					If Empty(cOcorren) .Or. ! AAG->(dbSeek(xFilial("AAG")+cOcorren)) 
						At900Crit(@aCritica,cAliasUI,STR0024) //"A ocorrência padrão para GCT (MV_OCOGCT), não foi encontrada."				
					EndIf
							
				Else
					DbSelectArea("AAH")
					AAH->(DbSetOrder(1))	
					AAH->(dbSeek(xFilial("AAH")+(cAliasUI)->ABQ_CONTRT))
				
					cCodProp := AAH->AAH_PROPOS
					cCondPV  := AAH->AAH_CONPAG
					cOcorren := AAH->AAH_OCOROS
					cTpCont  := "1"
				EndIf
					 
				If !Empty(cOcorren)
				
					If lHasOrcSim .AND. lOrcSimp
						cCodProp := ""
					EndIf
					
					If !lHasOrcSim
						At240GerOs(cCodProp, aChaveAA3, cCondPV, cOcorren,; 
									(cAliasUI)->ABQ_CONTRT, @cOsLocal, Nil, cTpCont)
					Else
						At240GerOs(cCodProp, aChaveAA3, cCondPV, cOcorren,; 
									(cAliasUI)->ABQ_CONTRT, @cOsLocal, Nil, cTpCont, cCodEnt, cCodLoja)
					EndIf
					
				EndIf		
						
				cItemOs := ""
				
				For nI:=1 To Len(aChaveAA3)
					AB7->(dbSetOrder(5))			
					If AB7->(dbSeek(xFilial("AB7")+Substr(aChaveAA3[nI],9)))			
						While	AB7->AB7_FILIAL+AB7->AB7_CODFAB+AB7->AB7_LOJAFA+;
								AB7->AB7_CODPRO+AB7->AB7_NUMSER == xFilial("AB7")+Substr(aChaveAA3[nI],9)												
							If AB7->AB7_NUMOS == cOsLocal
								cItemOs := AB7->AB7_ITEM						
								Exit			
							EndIf					
							AB7->(dbSkip())					
						EndDo
					EndIf		
					If !Empty(cItemOs)
						Exit 
					EndIf
				Next nI		
				
				cChave := cOsLocal + cItemOs
					
				AAdd(aOsContrt, { (cAliasUI)->ABB_IDCFAL, cChave, cOsLocal, Nil, Nil } )
			EndIf 
			
			RestArea( aArea )			
			
		ElseIf Empty(cChave)
			If !Empty(cBsError)
				At900Crit(@aCritica,cAliasUI,cBsError)
				cChave := (cAliasUI)->ABB_CHAVE
			Else
				cChave := (cAliasUI)->ABB_CHAVE				
			EndIf
		EndIf 
		
		aArea := GetArea()
		
		DbSelectArea("AB7")
		AB7->(DbSetOrder(1))		
			
		DbSelectArea("ABQ")
		ABQ->(DbSetOrder(1))
			
		//Posiciona no Item da O.S.
		If !Empty(cChave) .And. (AB7->(MsSeek(xFilial("AB7")+Substr(cChave,1,nTamChave)))) //ABQ_CONTRT + ABQ_ITEM | AB7_NUMOS + AB7_ITEM	
			
			// Quando houver manutenção ajusta as datas
			If 	(cAliasUI)->ABB_MANUT == "1" 
				//Considera Horario Extra
				If !Empty((cAliasUI)->HRE_DTINI) .AND. !Empty((cAliasUI)->HRE_HRINI) .AND. !Empty((cAliasUI)->HRE_DTFIM) .AND. !Empty((cAliasUI)->HRE_HRFIM)																			
					dDataIni := (cAliasUI)->HRE_DTINI
					cHoraIni := (cAliasUI)->HRE_HRINI
					dDataFim := (cAliasUI)->HRE_DTFIM
					cHoraFim := (cAliasUI)->HRE_HRFIM												
					//Quando hora extra verifica se há codigo de serviço no Motivo (ABN)
					DbSelectArea("ABN")
					ABN->(DbSetOrder(1))
					//Se na manutencao usuario especificou servico diferente para hora extra. 
					If (cAliasUI)->ABR_USASER == "1" .AND. (ABN->(MsSeek(XFilial("ABN")+(cAliasUI)->ABR_MOTIVO)) .AND. !Empty(ABN->ABN_SERVIC))
						nHrExtra := HoraToInt((cAliasUI)->ABR_TEMPO) 				
						cServExt := ABN->ABN_SERVIC
					EndIf																		
				EndIf
				//Considera Atrasos (Horario Inicial)
				If !Empty((cAliasUI)->ATR_DTINI) .AND. !Empty((cAliasUI)->ATR_HRINI) 
					dDataIni := (cAliasUI)->ATR_DTINI
					cHoraIni := (cAliasUI)->ATR_HRINI
					//Recalcula Tempo da Hora Extra	
					If (nHrExtra > 0)
						nHrExtra := SubtHoras( dDataFim, cHoraFim, (cAliasUI)->ABB_DTFIM, (cAliasUI)->ABB_HRFIM)					
					EndIf		
				EndIf		
				//Considera Saida Antecipada (Horario Final)
				If !Empty((cAliasUI)->SAI_DTFIM) .AND. !Empty((cAliasUI)->SAI_HRFIM) 
					dDataFim := (cAliasUI)->SAI_DTFIM
					cHoraFim := (cAliasUI)->SAI_HRFIM
					//Recalcula Tempo da Hora Extra	
					If (nHrExtra > 0)
						nHrExtra := SubtHoras( dDataIni, cHoraIni, (cAliasUI)->ABB_DTINI, (cAliasUI)->ABB_HRINI)
					EndIf									
				EndIf	
																		
			EndIf
			
			//Calcula Total de Horas Realizadas
			nHrTotal	:= Round(SubtHoras(dDataIni,cHoraIni,dDataFim,cHoraFim), 2)
					
			//Calcula Horas Normais retirando o horario extra.
			If nHrExtra < 0 
				nHrExtra := 0
			EndIf

			nHrNormal	:= nHrTotal - nHrExtra		
			
			//Verifica se ha grupo de cobertura e o servico usado.
			//Quando chama AtBaseServ, se nao houver grupo de cobertura retorna vazio, entao preenche com o serviço do parametro.
			cServico := AtBaseServ(AB7->AB7_CODFAB,AB7->AB7_LOJAFA,AB7->AB7_CODPRO,AB7->AB7_NUMSER,(cAliasUI)->ABQ_PRODUT,@cCodGrup)
	
			// Quando Demanda procura o serviço conforme grupo de cobertura	
			If (cAliasUI)->ABQ_TPPROD == "3"
				//Se houver grupo cobertura ativa a flag.
				If !Empty(cServico)				
					lGrpCob	:= .T.				
				Else
					cServico	:= MV_PAR11
				EndIf		
			//Valida Impedindo a Geração do Atendimento caso seja usado um serviço relacionado a um grupo de cobertura
			//Para Mensal ou Material Operacional	
			ElseIf	!Empty(cCodGrup) .AND. !Empty(cServico) .AND. (cAliasUI)->ABQ_TPPROD != "3"
				//Caso seja Mensal e exista alguma alocação utilizando grupo de cobertura. Adota o serviço do parametro
				If cServico != MV_PAR11
					cServico := MV_PAR11
				EndIf
				
				SB1->( DbSetOrder( 1 ) ) 
				If SB1->( DbSeek( xFilial( "SB1" ) + (cAliasUI)->ABQ_PRODUT ) )							
					DbSelectArea("AAB")
					AAB->(DbSetOrder(1))
					//Se usar servico que consome G.C. em mensal/operacional no atendimento da o.s. sera consumido o G.C.
					If AAB->(DbSeek(XFilial("AAB")+cCodGrup+SB1->B1_TIPO+SB1->B1_GRUPO+(cAliasUI)->ABQ_PRODUT)) .AND. AAB->AAB_CODSER == MV_PAR11									 
						At900Crit(@aCritica,cAliasUI,STR0009) //"O Serviço Padrão para a alocação mensal não pode ser o mesmo serviço configurado para consumo do grupo de cobertura."
						lContinua	:= .F.
					EndIf
				EndIf
			Else
				cServico := MV_PAR11		
			EndIf	
			
			//Caso nao haja critica no uso do servico
			If lContinua
				//Determina a Sequencia do Atendimento da O.S.			
				cSequencia := ""			
				If (nPosTec := aScan(aSeqTec,{|x| x[1]==(cAliasUI)->ABB_CODTEC+Substr((cAliasUI)->ABB_CHAVE,1,nTamChave)})) > 0
					cSequencia += Soma1(aSeqTec[nPosTec][2])
					aSeqTec[nPosTec][2] := cSequencia 			
				Else			
					cSequencia := At900SeqT((cAliasUI)->ABB_CODTEC,Substr((cAliasUI)->ABB_CHAVE,1,nTamChave))
					AAdd(aSeqTec,{(cAliasUI)->ABB_CODTEC+Substr((cAliasUI)->ABB_CHAVE,1,nTamChave),cSequencia})
				EndIf

				aAtende :=		{;
								AB7->AB7_NUMOS+AB7->AB7_ITEM,;		// Numero da O.S + Item
								cSequencia,;							// Sequencia de Atendimento
								(cAliasUI)->ABB_CODTEC,;				// Codigo do Técnico
								dDataIni,;								// Data de Chegada
								cHoraIni,;								// Hora de Chegada
								dDataFim,;								// Data de Saida
								cHoraFim,;								// Hora de Saida
								dDataIni,;								// Data de Inicio
								cHoraIni,;								// Hora de Inicio
								dDataFim,;								// Data de Fim
								cHoraFim,;								// Hora de Fim
								AB7->AB7_CODPRB,;						// Codigo da Ocorrencia
								"2",;									// Tipo(1= Encerrado,2=Aberta)
								"",;								// Horas Faturadas * mantido por questões de legado
								AB7->AB7_NUMOS;						// Numero da O.S 
								}					
				aItAten :=		{{;					
								StrZero(1,nTamItem),;				// Item (ABA)
								(cAliasUI)->ABQ_PRODUT,;				// Cod. Prod (ABA)
								nHrNormal,;							// Quantidade
								cServico,;								// Servico Padrao
								If(lGrpCob,"1","2");					// Força Grupo de Cobertura
								}}
								
				If nHrExtra > 0 // Quando houver codigo de serviço diferente na tabela ABN utiliza o serviço do total da hora extra.
					AAdd(aItAten,;
								{;					
								StrZero(2,nTamItem),;				// Item (ABA)
								(cAliasUI)->ABQ_PRODUT,;				// Cod. Prod (ABA)
								nHrExtra,;								// Quantidade
								cServExt,;								// Servico Padrao
								"2";									// Força Grupo de Cobertura
								})		
				EndIf
		
				Begin Transaction				 	
				
				If At900IncAt(aAtende,aItAten,3)
					If !At900AtABB((cAliasUI)->ABBRECNO,aAtende[1],aAtende[2],aAtende[3],(cAliasUI)->ABB_CODIGO,aAtende[15])
						DisarmTransaction()
						At900Crit(@aCritica,cAliasUI,STR0010) //"Erro ao Atualizar a Agenda referente ao Atendimento da O.S."
					Else 
						nPos := aScan(aOsContrt, { |x| x[2] == AB7->AB7_NUMOS+AB7->AB7_ITEM})
						If nPos > 0
							aOsContrt[nPos][4] := aAtende
							aOsContrt[nPos][5] := aItAten
						Endif						
					EndIf				
				Else
					DisarmTransaction()				
					cErro := ""
					AEval(GetAutoGRLog(),{|x| cErro += x+CRLF })
					At900Crit(@aCritica,cAliasUI,STR0011+CRLF+cErro) //"Erro ao Incluir Atendimento da O.S. para Alocação."
				EndIf
				
				End Transaction
												
			EndIf
			
		Else	
			If !Empty(cBsError)
				At900Crit(@aCritica,cAliasUI,cBsError) 
			Else
				At900Crit(@aCritica,cAliasUI,STR0012) //"Não Encontrado Item da O.S. para Alocação."
			EndIf
		EndIf

		RestArea( aArea )
		
	Else
		ABB->( MsGoto( (cAliasUI)->ABBRECNO ) )	
		RecLock("ABB", .F.)

		//Limpa os campos de OS
		REPLACE ABB_CHAVE	WITH ""	
		REPLACE ABB_NUMOS	WITH ""
		
		REPLACE ABB_CHEGOU WITH	"S"	//Compareceu "S" - Sim ; "N" - Não
		REPLACE ABB_ATENDE WITH	"1"	//Atendeu 	 "1" - Sim ; "2" - Não		
				
		ABB->( MsUnLock() )	  		
		lRet := .T.
	
	Endif
		
	(cAliasUI)->(DbSkip())
		
EndDo

If lGsGerOs
	// Encerra o atendimento gerado para a nova estrutura de alocação
	If Len(aOsContrt) > 0	
		For nI := 1 to Len(aOsContrt)			
			If aOsContrt[nI][4] <> Nil
				aOsContrt[nI][4][13] := "1"			
				At900IncAt(aOsContrt[nI][4],aOsContrt[nI][5],4)
			EndIf			
		Next nI	
	EndIf 
Endif

If !lAutomato
	If nReg == 0
		If lMultFil	
			cTexMsg += STR0001+STR0053+cFilAnt+","+STR0013+","+CRLF //"Atenção"##" - Filial "##"Não há registros para gerar atendimento conforme parametros informados."##{"OK"}
		else
			cTexMsg += STR0001+STR0013+","+CRLF //"Atenção"##"Não há registros para gerar atendimento conforme parametros informados."##{"OK"}	
		Endif
	ElseIf Len(aCritica) == 0
		If lMultFil
			cTexMsg += STR0001+STR0053+cFilAnt+","+STR0014+cValToChar(nReg)+STR0015+","+CRLF //"Atenção"##" - Filial "##"Foram gerados:"##" atendimentos de ordens de serviço de alocação."##{"OK"}						
		Else			
			cTexMsg += STR0001+","+STR0014+cValToChar(nReg)+STR0015+","+CRLF //"Atenção"##"Foram gerados:"##" atendimentos de ordens de serviço de alocação."##{"OK"}		
		Endif
	Else		
		If lMultFil
			cTexMsg += STR0001+STR0053+cFilAnt+","+STR0014+cValToChar((nReg-Len(aCritica)))+STR0015+STR0016+CRLF+STR0017+TxLogPath("GerAtend")+","+CRLF //"Atenção"##" - Filial "##"Foram gerados:"##" atendimentos de ordens de serviço de alocação."## " Ocorreram erros na geração do atendimento da O.S."##"Foi gerado o log no arquivo "##"OK"	 																																				   
		else
			cTexMsg += STR0001+","+STR0014+cValToChar((nReg-Len(aCritica)))+STR0015+STR0016+CRLF+STR0017+TxLogPath("GerAtend")+","+CRLF //"Atenção"##"Foram gerados:"##" atendimentos de ordens de serviço de alocação."## //" Ocorreram erros na geração do atendimento da O.S."##"Foi gerado o log no arquivo "##"
		Endif
	EndIf
	oDlg:End()
EndIf

Return( Len(aCritica) == 0 )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At900IncAt()

Inclui o Atendimento da O.S via ExecAuto(Teca460)

@param ExpA:Array com os dados da ABB para a execAuto
@param ExpC:Sequencia que será utilizada na geração do atendimento
@param ExpN:Nopc para inclusão do atendimento da O.S (3 - Inclusão)

@return ExpL: Retorna .T. quando houve sucesso na execução da execauto 
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At900IncAt(aAtende,aItAten,nOpcx)

Local aCabec   		:= {}		//Array para o cabeçalho do atendimento		
Local aItem    		:= {}		//Array auxiliar para os itens da O.S
Local aItens   		:= {}		//Array para o item da O.S
Local lRet			:= .F.		//Retorno da função
Local nX			:= 0

Default nOpcx 		:= 3

Private lMsHelpAuto 	:= .T.		// Controle interno do ExecAuto
Private lMsErroAuto 	:= .F.		// Informa a ocorrência de erros no ExecAuto
Private lAutoErrNoFile	:= .T.		// Loga Erros do Execauto na array
Private INCLUI 			:= .T.		// Variavel necessária para o ExecAuto identificar que se trata de uma inclusão
Private ALTERA 			:= .F.		// Variavel necessária para o ExecAuto identificar que se trata de uma inclusão

If nOpcx == 3 .Or. nOpcx == 4
	
	//Adiciona itens para o cabeçalho do Atendimento
	aAdd(aCabec,{"AB9_NUMOS"		, aAtende[1] , Nil })       	// Numero da O.S + Item
	aAdd(aCabec,{"AB9_SEQ"		, aAtende[2] , Nil })			// Sequencia de Atendimento
	aAdd(aCabec,{"AB9_CODTEC"  	, aAtende[3] , Nil })			// Codigo do Técnico
	aAdd(aCabec,{"AB9_DTCHEG"	, aAtende[4] , Nil })			// Data de Chegada
	aAdd(aCabec,{"AB9_HRCHEG" 	, aAtende[5] , Nil })			// Hora de Chegada
	aAdd(aCabec,{"AB9_DTSAID"	, aAtende[6] , Nil })			// Data de Saida	
	aAdd(aCabec,{"AB9_HRSAID"  	, aAtende[7] , Nil })			// Hora de Saida
	aAdd(aCabec,{"AB9_DTINI"  	, aAtende[8] , Nil })			// Data de Inicio
	aAdd(aCabec,{"AB9_HRINI"  	, aAtende[9] , Nil })			// Hora de Inicio
	aAdd(aCabec,{"AB9_DTFIM"  	, aAtende[10], Nil })			// Data de Fim
	aAdd(aCabec,{"AB9_HRFIM"  	, aAtende[11], Nil })			// Hora de Fim
	aAdd(aCabec,{"AB9_CODPRB"  	, aAtende[12], Nil })       	// Codigo da Ocorrencia
	aAdd(aCabec,{"AB9_TIPO"  	, aAtende[13], Nil })			// Tipo(1= Encerrado,2=Aberta)	
	//aAdd(aCabec,{"AB9_TOTFAT"	, aAtende[14], Nil })			// Horas Faturadas * Não há necessidade, já existe gatilho
	
	For nX := 1 To Len(aItAten)
		aItem := {}
		//Itens do Atendimento da O.S
		aAdd(aItem, {"ABA_ITEM"			, aItAten[nX][1]	, Nil}) 		// Item 
		aAdd(aItem, {"ABA_CODPRO"		, aItAten[nX][2]	, Nil}) 		// Cod. do Produto				
		aAdd(aItem, {"ABA_QUANT"			, aItAten[nX][3]	, Nil}) 		// Quantidade usada
		aAdd(aItem, {"ABA_CODSER"		, aItAten[nX][4]	, Nil}) 		// Cod. do servico
		aAdd(aItens,aItem)		
	Next nX
	
	//Executa ExecAuto
	TECA460(aCabec,aItens,nOpcx)
	
	If !lMsErroAuto
		lRet := .T.	    
	EndIf
	
	aCabec := {}
	aItem  := {}
	aItens := {}

EndIf

Return ( lRet )

// 
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At900SeqT()

Retorna a proxima sequencia a gerar para um tecnico no atendimento de uma O.S. 

@param ExpC:Codigo do Tecnico
@param ExpC:AB7_NUMOS

@return cSeq Sequencia em caractere
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At900SeqT(cCodTec,cChave)
Local aArea	:= GetArea()
Local cSeq		:= "00"

DbSelectArea("AB9") //Filial+NUMOS+Tecnico
AB9->(DbSetOrder(1))
If AB9->(DbSeek(XFilial("AB9")+cChave+cCodTec))	
	While !AB9->(EOF()) .AND. AB9->AB9_FILIAL+AB9->AB9_NUMOS+AB9->AB9_CODTEC == XFilial("AB9")+cChave+cCodTec 
		cSeq := AB9->AB9_SEQ
		DbSkip()
	End	
EndIf

RestArea(aArea)

Return Soma1(cSeq) 


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At900Qry()

Gera Tabela Temporaria utilizada para processamento

@param ExpC:Condicao para montar a query

@return cAlias Alias da tabela gerada

/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At900Qry(cCondicao)
Local cAliasUI		:= "TMPATDPRO"
Local cAtraso		:= "%''"								// 02 - Atraso (Tabela I5 - SX5)
Local cSaidaAnt		:= "%''"								// 03 - Saida Antecipada (Tabela I5 - SX5)
Local cHoraExtra	:= "%''"								// 04 - Hora Extra (Tabela I5 - SX5)
Local cManut		:= ""									// 01|07 - Falta e Ausência (Tabela I5 - SX5)
Local cSinalCon		:= If(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+") //Sinal de concatenação (Igual ao ADMXFUN)
Local cExpCon		:= "%ABQ.ABQ_CONTRT"+cSinalCon+"ABQ.ABQ_ITEM"
Local cIdcfal		:= Space(TamSX3("ABB_IDCFAL")[1])	// ID Configuracao Alocacao
Local cExpCmp		:= ""
Local lFilTFF		:= FindFunction("ExistFilTFF") .And. ExistFilTFF()
Local lGsGerOs		:= SuperGetMV("MV_GSGEROS",.F.,"1") == "1" //Gera O.S na rotina de geração de atendimento do gestão de serviços 1 = Sim e 2 = Não.
Local lMobile 		:= SuperGetMV("MV_GSHRPON",.F., "2") == "1"
Local cExpHR		:= ""

If Select(cAliasUI) > 0
	(cAliasUI)->(DbCloseArea())
EndIf

cExpCon += cSinalCon+"ABQ.ABQ_ORIGEM%"	

//Codigos Atraso/Saida Antecipada/Hr. Extra/Falta
DbSelectArea("ABN")
DbSetOrder(1)
DbGoTop()
While !ABN->(EOF())

	If ABN->ABN_TIPO == I5_ATRASO
		cAtraso	+=	",'"	+	ABN->ABN_CODIGO + "'"
	ElseIf ABN->ABN_TIPO == I5_SAIANT
		cSaidaAnt	+=	",'"	+	ABN->ABN_CODIGO + "'"
	ElseIf ABN->ABN_TIPO == I5_HREXTR
		cHoraExtra	+=	",'"	+	ABN->ABN_CODIGO + "'"	
	EndIf

	If !lGsGerOs .And. ABN->ABN_TIPO $ I5_MANUT

		If Empty(cManut)
			cManut	+=	"'"+ABN->ABN_CODIGO+"'"
		Else
			cManut	+=	",'"+ABN->ABN_CODIGO+"'"		
		Endif
	Endif

	ABN->(DbSkip())
End

cAtraso		+= "%"
cSaidaAnt	+= "%"
cHoraExtra	+= "%"

//Quando for geração de marcação sem os, verifica se foi aplicado algumas manuntenções
If !lGsGerOs .And. !Empty(cManut)
	cCondicao += "NOT EXISTS( SELECT 1 FROM " + RetSqlName("ABR") + " MANUT "
	cCondicao += "WHERE MANUT.ABR_FILIAL = '"+xFilial("ABR")+"' AND MANUT.ABR_AGENDA=ABB.ABB_CODIGO AND MANUT.ABR_MOTIVO IN ("+cManut+") AND MANUT.D_E_L_E_T_ = ' ' ) AND "
Endif

cCondicao := "%"+cCondicao+"%"

If lMobile
	cExpHr := "% CASE WHEN ABB.ABB_HRCHIN = '' OR ABB.ABB_HRCHIN IS NULL THEN ABB.ABB_HRINI ELSE ABB.ABB_HRCHIN END ABB_HRINI, "
	cExpHr += " CASE WHEN ABB.ABB_HRCOUT = '' OR ABB.ABB_HRCOUT IS NULL THEN ABB.ABB_HRFIM ELSE ABB.ABB_HRCOUT END ABB_HRFIM, %"
Else
	cExpHR := "%ABB.ABB_HRINI, ABB.ABB_HRFIM, %" 
EndIf

IF !lFilTFF 
	cExpCmp := "%ABQ.ABQ_ORIGEM, ABQ.ABQ_CODTFF,%"
ELSE
	cExpCmp := "%ABQ.ABQ_ORIGEM, ABQ.ABQ_CODTFF, ABQ.ABQ_FILTFF,%"
ENDIF

//Verifica alocações ativas e não atendidas
BeginSQL alias cAliasUI
	column ABB_DTINI as Date
	column ABB_DTFIM as Date
	column ATR_DTINI as Date
	column ATR_DTFIM as Date
	column SAI_DTINI as Date
	column SAI_DTFIM as Date
	column HRE_DTINI as Date
	column HRE_DTFIM as Date	
	
SELECT
	ABB.ABB_FILIAL,
	ABB.ABB_CODTEC,
	ABB.ABB_NUMOS,
	ABB.ABB_ENTIDA,
	ABB.ABB_CHAVE,
	ABB.ABB_DTINI,
	ABB.ABB_DTFIM,
	%exp:cExpHR%
	ABB.ABB_ATENDE,
	ABB.ABB_MANUT,	
	ABB.ABB_IDCFAL,
	ABB.ABB_CODIGO,
	ABQ.ABQ_PRODUT,	
	ABQ.ABQ_TPPROD,	
	ABQ.ABQ_CODTFF,
	ABQ.ABQ_FILTFF,
	ABQ.ABQ_CONTRT,
	%exp:cExpCmp%
	ATRASO.ABR_DTINI ATR_DTINI, 
	ATRASO.ABR_HRINI ATR_HRINI,
	ATRASO.ABR_DTFIM ATR_DTFIM, 
	ATRASO.ABR_HRFIM ATR_HRFIM,
	SAIANT.ABR_DTINI SAI_DTINI, 
	SAIANT.ABR_HRINI SAI_HRINI,
	SAIANT.ABR_DTFIM SAI_DTFIM, 
	SAIANT.ABR_HRFIM SAI_HRFIM,			
	HREXTR.ABR_DTINI HRE_DTINI, 
	HREXTR.ABR_HRINI HRE_HRINI,
	HREXTR.ABR_DTFIM HRE_DTFIM, 
	HREXTR.ABR_HRFIM HRE_HRFIM,
	HREXTR.ABR_MOTIVO,
	HREXTR.ABR_USASER,
	HREXTR.ABR_TEMPO,		
	ABB.R_E_C_N_O_ ABBRECNO	
	
FROM 
	%table:ABB% ABB
LEFT JOIN 
	%table:AB6% AB6 ON (AB6.AB6_FILIAL=%xfilial:AB6% AND AB6.AB6_NUMOS=ABB.ABB_NUMOS AND AB6.%notDel%)
INNER JOIN 
	%table:TDV% TDV ON (TDV.TDV_FILIAL=%xfilial:TDV% AND TDV.TDV_CODABB = ABB.ABB_CODIGO AND TDV.%notDel%)
JOIN
	%table:ABQ% ABQ ON (ABQ.ABQ_FILIAL=%xfilial:ABQ% AND %exp:cExpCon%=ABB.ABB_IDCFAL AND ABQ.ABQ_FILTFF = %xfilial:TFF% AND ABQ.%notDel%) 
LEFT JOIN	
	%table:ABR% ATRASO ON (ATRASO.ABR_FILIAL=%xfilial:ABR% AND ATRASO.ABR_AGENDA=ABB.ABB_CODIGO AND ATRASO.ABR_MOTIVO IN (%exp:cAtraso%) AND ATRASO.%notDel%)
LEFT JOIN	
	%table:ABR% SAIANT ON (SAIANT.ABR_FILIAL=%xfilial:ABR% AND SAIANT.ABR_AGENDA=ABB.ABB_CODIGO AND SAIANT.ABR_MOTIVO IN (%exp:cSaidaAnt%) AND SAIANT.%notDel%)
LEFT JOIN	
	%table:ABR% HREXTR ON (HREXTR.ABR_FILIAL=%xfilial:ABR% AND HREXTR.ABR_AGENDA=ABB.ABB_CODIGO AND HREXTR.ABR_MOTIVO IN (%exp:cHoraExtra%) AND HREXTR.%notDel%)
INNER JOIN 	
	%table:ABS% ABS ON ABS.ABS_FILIAL = %xfilial:ABS% AND ABS.%notDel% AND ABS.ABS_LOCAL =  ABB.ABB_LOCAL
WHERE
		ABB.ABB_FILIAL = %xfilial:ABB%
	AND
		ABB.ABB_IDCFAL != %exp:cIdcfal%
	AND
		%exp:cCondicao%
		
		ABB.%notDel%
	
ORDER BY ABB_CODTEC,ABB_DTINI

EndSql

Return cAliasUI

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At900AtABB()

Atualiza o agendamento da ABB para atendido apos a geração do atendimento da O.S

@param ExpN: Valor do Recno para atualização da ABB
@param ExpC: Código do AB9_NUMOS par atualização da AB9
@param ExpC: Código do AB9_SEQ para atualização da AB9
@param ExpC: Código do AB9_CODTEC para atualização da AB9
@param ExpC: Código da agenda da ABB para atualização da AB(

@return lRet Retorna .T. a atualização aconteceu com sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At900AtABB(nRecno,cChave,cSeq,cCodTec,cCodABB,cNumOS)
Local lRet 		:= .F.		//Retorno da Função
Local lContinua	:= .F.		//Retorno da Atualização da AB9

Default cChave	:= ""
Default cSeq		:= ""
Default cCodTec	:= ""	
Default cCodABB	:= ""
Default cCodABB	:= ""
Default cNumOS	:= ""

DbSelectArea("ABB")
DbSetOrder(7) //ABB_FILIAL+ABB_CODTEC+ABB_ENTIDA+ABB_CHAVE

DbSelectArea("AB9")
DbSetOrder(1) //AB9_FILIAL+AB9_NUMOS+AB9_CODTEC+AB9_SEQ

//Atualiza o campo AB9_ATAUT, para indicar que o atendimento foi gerado automaticamente
If AB9->(DbSeek(xFilial("AB9")+cChave+cCodTec+cSeq))
	RecLock("AB9", .F.)
	
	REPLACE AB9_ATAUT WITH cCodABB
	
	AB9->( MsUnLock() )
	lContinua := .T.
EndIf

//Atualiza os campos na ABB para indicar que foi gerado o atendimento
If lContinua
	ABB->( MsGoto( nRecno ) )	
	RecLock("ABB", .F.)
	
	If !Empty(cNumOs)
		REPLACE ABB_NUMOS WITH	cNumOs
		REPLACE ABB_CHAVE WITH	cChave
	EndIf
	
	REPLACE ABB_CHEGOU WITH	"S"	//Compareceu "S" - Sim ; "N" - Não
	REPLACE ABB_ATENDE WITH	"1"	//Atendeu 	"1" - Sim ; "2" - Não
	
	ABB->( MsUnLock() )
	lRet := .T.
EndIf 
		
Return( lRet )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At900Crit()

Adiciona dados do registro em processamento quando houver crítica.

@param ExpA:Array com as criticas de todo o processamento.
@param Expc:Alias da tabela do processamento.
@param cMsg:Mensagem de critica do registro corrente.

/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At900Crit(aCritica,cAliasUI,cMsg, cLogName)
	Local cText
	Local lMultFil	:= Iif(SuperGetMV("MV_GSGEROS",.F.,"1") == "1",TecHasPerg("MV_PAR17","TEC900") .And. !Empty(MV_PAR17),TecHasPerg("MV_PAR10","TEC900A") .And. !Empty(MV_PAR10))

	Default cLogName := "GerAtend"
	
	If lMultFil
		cLogName += STR0055+cFilAnt //"-Filial"
	Endif
	
	AAdd(aCritica,{;
		(cAliasUI)->ABBRECNO,;
		(cAliasUI)->ABB_CODTEC,;
		(cAliasUI)->ABB_NUMOS,;
		(cAliasUI)->ABQ_CONTRT,;
		(cAliasUI)->ABB_DTINI,;
		(cAliasUI)->ABB_HRINI,;
		(cAliasUI)->ABB_DTFIM,;
		(cAliasUI)->ABB_HRFIM,;
		cMsg})
		
		
		cText := STR0023+cValToChar((cAliasUI)->ABBRECNO)+CRLF;
		+" "+RetTitle("ABB_CODTEC")+":"+(cAliasUI)->ABB_CODTEC+CRLF;
		+" "+RetTitle("ABB_NUMOS")+":"+(cAliasUI)->ABB_NUMOS+CRLF;
		+" "+RetTitle("ABQ_CONTRT")+":"+(cAliasUI)->ABQ_CONTRT+CRLF;
		+" "+RetTitle("ABB_DTINI")+":"+DtoC((cAliasUI)->ABB_DTINI)+CRLF;
		+" "+RetTitle("ABB_HRINI")+":"+(cAliasUI)->ABB_HRINI+CRLF;
		+" "+RetTitle("ABB_DTFIM")+":"+DToC((cAliasUI)->ABB_DTFIM)+CRLF;
		+" "+RetTitle("ABB_HRFIM")+":"+(cAliasUI)->ABB_HRFIM+CRLF;
		+" "+CRLF+cMsg+CRLF	
	
		//Cria arquivo de Log
		TxLogFile(cLogName,cText)
		
Return


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At900BaseCM()

Retorna a lista de bases de atendimento associadas a um contrato de manutencao.

@author 	Serviços
@since		10/10/2013
@version	P11 R9

@param 		ExpC1:Alias utilizado para a busca
@param 		ExpC2:Codigo do contrato de manutencao.
@param 		ExpC3:Origem do contrato.

@return	aBase - Lista de bases de atendimento associadas ao contrato.

/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At900BaseCM(cAliasUI,cContrato,cOrigem,cCodTFF, cBsError)

Local aArea		:= GetArea()
Local aAreaAA3	:= AA3->(GetArea())
Local aAreaUI 	:= (cAliasUI)->(GetArea())
Local aBase		:= {}
Local cFilAA3	:= xFilial("AA3")
Local cFilOrBas	:= ""
Local cFilOrCtr	:= ""
Local aCliLoj	:= GetCli(cCodTFF)
Local aAuxBs	:= {}
Local cError 	:= ""
Local nCountBs	:= 0

Default cBsError := ""

dbSelectArea("AA3")
AA3->(dbSetOrder(2)) //AA3_FILIAL+AA3_CONTRT+AA3_CODCLI+AA3_LOJA+AA3_CODPRO+AA3_NUMSER
lFoundBs 	:= AA3->(dbSeek(cFilAA3+cContrato))

While AA3->(!Eof()) .AND. AA3->AA3_CONTRT == cContrato
	If AA3->AA3_ORIGEM <> cOrigem
	 	If cOrigem == "CN9"
	 		// Adicionando mensagem de erro
	 		If aScan(aAuxBs, {|x| x == AA3->AA3_NUMSER}) == 0 .AND. nCountBs == 0
	 			cError += STR0037 + CRLF //"Divergência do campo origem, da base de atendimento."
	 			cError += STR0038 + cOrigem //"Origem do contrato: "
	 			cError += STR0039 + AA3->AA3_ORIGEM + CRLF //"Origem da base de atendimento: "
	 			cBsError += cError
	 			cError := ""
	 			aAdd(aAuxBs,AA3->AA3_NUMSER)
	 		EndIf
	 	EndIf
		AA3->(dbSkip())
		Loop
	EndIf	

	If (AA3->AA3_CODCLI + AA3->AA3_LOJA) != (aCliLoj[1] + aCliLoj[2])
		If cOrigem == "CN9"
			// Adicionando mensagem de erro
			If aScan(aAuxBs, {|x| x == AA3->AA3_NUMSER}) == 0 .AND. nCountBs == 0
				cError += STR0040 + CRLF //"Divergência no cliente/loja da base de atendimento com o cliente do item da TFF."
				cError += STR0041 + AA3->AA3_NUMSER + STR0042 + AA3_CODCLI + STR0043 + AA3->AA3_LOJA + CRLF //"Base de atendimento " # ": Cliente = " #" --- Loja = " 
				cError += STR0044 + cCodTFF + STR0042 + aCliLoj[1] + STR0043 + aCliLoj[2] + CRLF //"Item de RH " # ": Cliente = "  # " --- Loja = "
	 			cBsError := cError
		 		cError := ""
		 		aAdd(aAuxBs,AA3->AA3_NUMSER)
		 	EndIf
	 	EndIf
		AA3->(dbSkip())
		Loop
	EndIf
	nCountBs++
	cFilOrBas	:= AA3->AA3_FILORI
	cFilOrCtr	:= (cAliasUI)->ABQ_FILTFF // Filial de Origem da TFF
	
	//Verifica FILORI da Base e FILORI do contrato
	If (!Empty(AA3->AA3_CONTRT) .AND. !Empty(cContrato) .AND. (cFilOrBas == cFilOrCtr) )			
		If (cFilOrBas == cFilAnt)
			AAdd(aBase,AA3->AA3_FILIAL+AA3->AA3_CODFAB+AA3->AA3_LOJAFA+AA3->AA3_CODPRO+AA3->AA3_NUMSER)
			cBsError := ""
		Else
 			cError += STR0045 + CRLF //"Inconsistência na filial de origem da base com a filial da TFF." 
 			cError += STR0045 //"Verifique os campos AA3_FILORI e ABQ_FILTFF."
 			cBsError := cError
 			cError := ""
		EndIf
	EndIf	
	
	AA3->(dbSkip())
	cError := ""
End

If !lFoundBs
	cBsError := STR0047 + cContrato + CRLF //"Não foi encontrada base de atendimento para o contrato "
	cBsError += STR0048 + (cAliasUI)->ABQ_FILTFF + "'AA3_CONTRT = '" + cContrato + "' , AA3_FILORI = '" + cFilAnt + "' ,AA3_ORIGEM = 'CN9'" //"Necessário Base de Atendimento configurada da seguinte maneira: AA3_FILIAL = '"
EndIf


RestArea(aAreaAA3)
RestArea(aAreaUI)
RestArea(aArea)

Return(aBase)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At900GetPro()

Retorna a proposta do contrato com a nova estrutura e integração com o GCT.

@author 	Serviços
@since		10/10/2013
@version	P11 R9

@param 		ExpC1:Codigo do contrato da integração GCT.
@param 		ExpC1:Codigo da revisão do contrato.
@param 		ExpC1:Codigo dos recursos do contrato.

@return	cProposta - Proposta relacionada ao contrato

/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At900GetPro(cCodContrt, cCodTFF, lOrcSimp, cCodEnt, cCodLoja)

Local cProposta := ""
Local cAliasTFF := GetNextAlias()
Local lHasOrcSim := HasOrcSimp()
Default lOrcSimp := .F.

If !lHasOrcSim

	BeginSql Alias cAliasTFF
		
		SELECT 
			TFJ.TFJ_PROPOS, TFJ.TFJ_PREVIS	 
		FROM 	
			%Table:TFF% TFF
			JOIN 	%Table:TFL% TFL
		  	  ON 	TFL.TFL_FILIAL = %xFilial:TFL%
		 	 AND 	TFL.TFL_CODIGO = TFF.TFF_CODPAI
		 	 AND 	TFL.TFL_CONTRT = %Exp:cCodContrt%	 	 	 	 
		 	 AND 	TFL.%NotDel%
			JOIN 	%Table:TFJ% TFJ 
		  	  ON 	TFJ.TFJ_FILIAL = %xFilial:TFJ%
		 	 AND 	TFJ.TFJ_CODIGO = TFL.TFL_CODPAI  
		 	 AND 	TFJ.%NotDel%	 
		WHERE	
			TFF.TFF_FILIAL = %xFilial:TFF%	AND
			TFF.TFF_COD = %Exp:cCodTFF%		AND 
			TFF.%NotDel%
			
	EndSql
	
	cProposta := (cAliasTFF)->TFJ_PROPOS

Else

	BeginSql Alias cAliasTFF
		
		SELECT 
			TFJ.TFJ_PROPOS, TFJ.TFJ_PREVIS, TFJ.TFJ_ORCSIM, TFJ.TFJ_CODENT, TFJ.TFJ_LOJA
		FROM 	
			%Table:TFF% TFF
			JOIN 	%Table:TFL% TFL
		  	  ON 	TFL.TFL_FILIAL = %xFilial:TFL%
		 	 AND 	TFL.TFL_CODIGO = TFF.TFF_CODPAI
		 	 AND 	TFL.TFL_CONTRT = %Exp:cCodContrt%	 	 	 	 
		 	 AND 	TFL.%NotDel%
			JOIN 	%Table:TFJ% TFJ 
		  	  ON 	TFJ.TFJ_FILIAL = %xFilial:TFJ%
		 	 AND 	TFJ.TFJ_CODIGO = TFL.TFL_CODPAI  
		 	 AND 	TFJ.%NotDel%	 
		WHERE	
			TFF.TFF_FILIAL = %xFilial:TFF%	AND
			TFF.TFF_COD = %Exp:cCodTFF%		AND 
			TFF.%NotDel%
			
	EndSql
	
	lOrcSimp := (cAliasTFF)->TFJ_ORCSIM == '1'
	cProposta := (cAliasTFF)->TFJ_PROPOS
	
	If lOrcSimp
		cCodEnt := (cAliasTFF)->TFJ_CODENT
		cCodLoja := (cAliasTFF)->TFJ_LOJA
	EndIf

EndIf

(cAliasTFF)->(DbCloseArea())

Return(cProposta)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At900DelAt

@description Baseando-se na AGENDA (ABB), carrega os dados da AB9 para excluir o
atendimento da O.S.

@author	Mateus Boiani
@since	02/05/2019
/*/
//------------------------------------------------------------------------------
Static Function At900DelAt(cAliasUI,oDlg,oMeter,oSayMsg, lAutomato, cTexMsg)
Local nReg 		:= 0
Local cSql 		:= ""
Local dDataIni
Local cHoraIni
Local dDataFim
Local cHoraFim
Local cAliasAux
Local lOk 		:= .T.
Local nOks 		:= 0
Local cErro 	:= ""
Local aCritica 	:= {}
Local lGsGerOs	:= SuperGetMV("MV_GSGEROS",.F.,"1") == "1" //Gera O.S na rotina de geração de atendimento do gestão de serviços 1 = Sim e 2 = Não.
Local lMultFil	:= Iif(lGsGerOs,TecHasPerg("MV_PAR17","TEC900") .And. !Empty(MV_PAR17),TecHasPerg("MV_PAR10","TEC900A") .And. !Empty(MV_PAR10))

Private lMsErroAuto := .F.

(cAliasUI)->(dbGoTop())

DbSelectArea("AAB")

While (cAliasUI)->(!Eof())	

	If !lAutomato
		oMeter:Set(++nReg)
		oSayMsg:SetText("<center>"+STR0007+cValToChar(nReg)+"</center>")//"Processando..."
	EndIf
	
	If lGsGerOs
	
		dDataIni	:= (cAliasUI)->ABB_DTINI
		cHoraIni	:= (cAliasUI)->ABB_HRINI
		dDataFim	:= (cAliasUI)->ABB_DTFIM
		cHoraFim	:= (cAliasUI)->ABB_HRFIM
		
		If 	(cAliasUI)->ABB_MANUT == "1" 
			If !Empty((cAliasUI)->HRE_DTINI) .AND. !Empty((cAliasUI)->HRE_HRINI) .AND. !Empty((cAliasUI)->HRE_DTFIM) .AND. !Empty((cAliasUI)->HRE_HRFIM)																			
				dDataIni := (cAliasUI)->HRE_DTINI
				cHoraIni := (cAliasUI)->HRE_HRINI
				dDataFim := (cAliasUI)->HRE_DTFIM
				cHoraFim := (cAliasUI)->HRE_HRFIM																												
			EndIf
			If !Empty((cAliasUI)->ATR_DTINI) .AND. !Empty((cAliasUI)->ATR_HRINI) 
				dDataIni := (cAliasUI)->ATR_DTINI
				cHoraIni := (cAliasUI)->ATR_HRINI	
			EndIf		
			If !Empty((cAliasUI)->SAI_DTFIM) .AND. !Empty((cAliasUI)->SAI_HRFIM) 
				dDataFim := (cAliasUI)->SAI_DTFIM
				cHoraFim := (cAliasUI)->SAI_HRFIM						
			EndIf	
		EndIf
		
		cSql := "SELECT AB9.R_E_C_N_O_ RECAB9 FROM " + RetSqlName("AB9") + " AB9 "
		cSql += " WHERE AB9.AB9_FILIAL = '" + xFilial("AB9") + "' AND AB9.D_E_L_E_T_ = ' ' "
		cSql += " AND AB9.AB9_NUMOS = '" + (cAliasUI)->ABB_CHAVE + "' "
		cSql += " AND AB9.AB9_CODTEC = '" + (cAliasUI)->ABB_CODTEC + "' "
		cSql += " AND AB9.AB9_DTCHEG = '" + DTOS(dDataIni) + "' "
		cSql += " AND AB9.AB9_HRCHEG = '" + cHoraIni + "' "
		cSql += " AND AB9.AB9_DTSAID = '" + DTOS(dDataFim) + "' "
		cSql += " AND AB9.AB9_HRSAID = '" + cHoraFim + "' "
		cSql += " AND AB9.AB9_DTINI  = '" + DTOS(dDataIni) + "' "
		cSql += " AND AB9.AB9_HRINI  = '" + cHoraIni + "' "
		cSql += " AND AB9.AB9_DTFIM  = '" + DTOS(dDataFim) + "' "
		cSql += " AND AB9.AB9_HRFIM  = '" + cHoraFim + "' "
		cSql := ChangeQuery(cSql)
		cAliasAux := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasAux, .F., .T.)
		
		If (cAliasAux)->RECAB9 > 0
			AB9->(dbGoTo((cAliasAux)->RECAB9))
			Begin Transaction
				lOk := TECA460({;
							{"AB9_NUMOS", AB9->AB9_NUMOS , Nil },;
							{"AB9_SEQ"	 , AB9->AB9_SEQ , Nil },;
							{"AB9_CODTEC", AB9->AB9_CODTEC , Nil };
						},;
						{},;
						5)
				If lOk .AND. !lMsErroAuto
					nOks++
				Else
					DisarmTransaction()				
					cErro := ""
					AEval(GetAutoGRLog(),{|x| cErro += x+CRLF })
					At900Crit(@aCritica,cAliasUI,STR0032+CRLF+cErro,"DelAtend") //"Erro ao Excluir Atendimento da O.S."
				EndIf
			End Transaction
		EndIf
		
		(cAliasAux)->(DbCloseArea())
	
	Else

		ABB->( MsGoto( (cAliasUI)->ABBRECNO ) )	
		RecLock("ABB", .F.)
		
		REPLACE ABB_CHEGOU WITH	"N"	//Compareceu "S" - Sim ; "N" - Não
		REPLACE ABB_ATENDE WITH	"2"	//Atendeu 	 "1" - Sim ; "2" - Não		
			
		ABB->( MsUnLock() )	  		
		lRet := .T.	
		nOks++
	Endif
	
	(cAliasUI)->(DbSkip())
EndDo

If nReg == 0
	If lMultFil
		cTexMsg += STR0001+STR0053+cFilAnt+","+STR0033+","+STR0002+CRLF //"Atenção"##" - Filial "##"Não há registros para excluir atendimento conforme parametros informados."##{"OK"}
	Else
		cTexMsg += STR0001+STR0033+STR0002+CRLF //"Atenção"##"Não há registros para excluir atendimento conforme parametros informados."##{"OK"}	
	Endif
ElseIf Len(aCritica) == 0
	If lMultFil
		cTexMsg += STR0001+STR0053+cFilAnt+","+STR0034+" "+cValToChar(nOks)+STR0015+","+STR0002+CRLF //"Atenção"##" - Filial "##"Foram excluidos:"##" atendimentos de ordens de serviço de alocação."##{"OK"}				
		Else
 		cTexMsg += STR0001+","+STR0034+" "+cValToChar(nOks)+STR0015+","+STR0002+CRLF //"Atenção"##"Foram excluidos:"##" atendimentos de ordens de serviço de alocação."##{"OK"}			
	Endif

Else
	If lMultFil
		cTexMsg += STR0001+STR0053+cFilAnt+", "+STR0034+" "+cValToChar(nOks)+STR0015+STR0035+CRLF+STR0017+TxLogPath("DelAtend")+CRLF //"Atenção"##" - Filial "##"Foram gerados:"##" atendimentos de ordens de serviço de alocação."## //" Ocorreram erros na geração do atendimento da O.S."##"Foi gerado o log no arquivo "##"OK"	
	else
		cTexMsg += STR0001+","+STR0034+" "+cValToChar(nOks)+STR0015+STR0035+CRLF+STR0064+TxLogPath("DelAtend")+CRLF //"Atenção"##"Foram gerados:"##" atendimentos de ordens de serviço de alocação."## //" Ocorreram erros na geração do atendimento da O.S."##"Consulte o log no arquivo: "		 	
	Endif	
EndIf
If !lAutomato
	oDlg:End()
EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetCli

@description Obtém o cliente do orçamento vinculado ao contrato

@author	fabiana.silva
@since	22/072019
/*/
//------------------------------------------------------------------------------
Static Function GetCli(cCodTFF)
Local aRet := {"",""}
Local aArea := {}
Local cAlias := GetNextAlias()

If !Empty(cCodTFF)
	 aArea := GetArea()
	BeginSQL Alias cAlias
		SELECT 	TFJ.TFJ_CODENT, TFJ.TFJ_LOJA
		From %table:TFJ% TFJ
		INNER JOIN  %table:TFL%  TFL ON (TFL.TFL_FILIAL = %xfilial:TFL% AND  TFL.TFL_CODPAI = TFJ.TFJ_CODIGO AND TFL.%notDel%)
		INNER JOIN  %table:TFF%  TFF ON (TFF.TFF_FILIAL = %xfilial:TFF% AND  TFF.TFF_CODPAI = TFL.TFL_CODIGO AND TFF.%notDel%)
		WHERE
		TFF.TFF_COD  = %exp:cCodTFF% AND
		TFJ.TFJ_FILIAL = %xfilial:TFJ% AND  TFJ.%notDel%
	
	EndSql
	
	If !(cAlias)->(Eof())
		aRet[01] := (cAlias)->TFJ_CODENT
		aRet[02] := (cAlias)->TFJ_LOJA
	EndIf
	
	(cAlias)->(DbCloseArea())
	RestArea(aArea)
EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At900PMtFl

@description Prepara o array com multi-filiais.
			 Se econtrar algum erro no parâmetro de filiais não deixa a rotina prosseguir.

@author	Kaique Schiller
@since	15/04/2020
/*/
//------------------------------------------------------------------------------
Function At900PMtFl(cMvMultFil,aMtFIlRet,cPergTec,cMvPar)
Local aAllFilial:= AllFilial()
Local aFilAux	:= {}
Local cMsgErr	:= ""
Local nIniRange	:= 0
Local nFimRange	:= 0
Local nX		:= 0
Local nY		:= 0
Local nZ		:= 0

If !Empty(cMvMultFil)

	MakeSqlExpr(cPergTec)
		
	aFilAux := At900Manip(&cMvPar, "'")
	
	For nX := 1 To Len(aFilAux)
		If !FWFilExist(,aFilAux[nX][1])
			cMsgErr += aFilAux[nX][1]+CRLF
		EndIf
	Next nX

	If Empty(cMsgErr)
		For nY := 1 to Len(aFilAux)
			If aFilAux[nY][2]
				nIniRange := aScan(aAllFilial, {|x| x == aFilAux[nY][1]})
				If nY <= Len(aFilAux)
					If !aFilAux[nY+1][2]
						nFimRange := aScan(aAllFilial, {|x| x == aFilAux[nY+1][1]})
						nY ++
					EndIf	
				EndIf
				For nZ := nIniRange To nFimRange
					AAdd(aMtFIlRet, aAllFilial[nz])
				Next nZ
				nIniRange := 0
				nFimRange := 0
			ElseIf !(aFilAux[nY][2])
				AAdd(aMtFIlRet, aFilAux[nY][1])
			EndIf
		Next nY
	EndIf
Endif

If !Empty(cMsgErr)
	AtShowLog(cMsgErr,STR0056,,,,) //"Não é possível encontrar a filial:"
	aMtFIlRet := {}		
Endif

Return Empty(cMsgErr)

//------------------------------------------------------------------------------
/*/{Protheus.doc} AllFilial

@description Seleciona todas as filiais.

@author	Kaique Schiller
@since	17/04/2020
/*/
//------------------------------------------------------------------------------
Static Function AllFilial()
Local aAreaSM0 := SM0->(GetArea())
Local aAllFil  := {}

DbSelectArea("SM0")
SM0->(DbGoTop())
While SM0->(!EOF())	
	Aadd(aAllFil,AllTrim(SM0->M0_CODFIL))
	SM0->(DbSkip())
EndDo

RestArea(aAreaSM0)

Return aAllFil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At900OS

@description Verifica se a ordem de serviço já gravada não 

@author	Luiz Gabriel
@since	17/04/2020
/*/
//------------------------------------------------------------------------------
Static Function At900OS(cNumOs)
Local lRetorno 	:= .T.
Local aAreaAB7	:= AB7->(GetArea())

dbSelectArea("AB7")
dbSetOrder(1)
If ( DbSeek(xFilial("AB7")+cNumOs) )
	If ( AB7->AB7_TIPO $ "13" )
		lRetorno := .F.
	EndIf
EndIf

RestArea(aAreaAB7)

Return(lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At900Avis()

Aviso informando a descontinuação da utilização da rotina com o parâmetro MV_GSGEROS = 1 

@author Junior Santos
@since 04/03/2021
/*/
//------------------------------------------------------------------------------
Function At900Avis()
Local oDlg	 := Nil
Local cLink  := "https://tdn.totvs.com/pages/releaseview.action?pageId=555849119"
Local SW_NORMAL := 1

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM 0,0 TO 200,970 PIXEL //Atenção

TSay():New( 010,010,{||OemToAnsi(STR0059)},oDlg,,TFont():New("Tahoma",,-12,.T.,.T.) ,.F.,.F.,.F.,.T.,CLR_BLACK)  //"A integração com Geração de Atendimentos está integrada com a Geração de Ordens de Serviço (MV_GSGEROS = 1). "                                                                                                                                                                                                                                                                                                                                                                                                     
TSay():New( 020,010,{||OemToAnsi(STR0060)},oDlg,,TFont():New("Tahoma",,-12,.T.,.T.) ,.F.,.F.,.F.,.T.,CLR_BLACK)  //"Com o desenvolvimento de novas funcionalidades, esta integração tornou-se obsoleta. "                                                                                                                                                                                                                                                                                                                                                                                                                              
TSay():New( 030,010,{||OemToAnsi(STR0061)},oDlg,,TFont():New("Tahoma",,-12,.T.,.T.) ,.F.,.F.,.F.,.T.,CLR_BLACK) //"A rotina de Geração de Atendimento ainda deve ser executada para concluir o fluxo de operações do Gestão de Serviços, porém, em sua versão mais recente."                                                                                                                                                                                                                                                                                                                                                          
TSay():New( 040,010,{||OemToAnsi(STR0062)},oDlg,,TFont():New("Tahoma",,-12,.T.,.T.) ,.F.,.F.,.F.,.T.,CLR_BLACK) //"Por favor, siga as orientações do TDN abaixo para atualizar a rotina:"                                                                                                                                                                                                                                                                                                                                                                                                                                             
@ 050,010 GET oMemo VAR cLink SIZE 273,010 PIXEL READONLY MEMO

TButton():New(065,010, OemToAnsi(STR0063), oDlg,{|| ShellExecute("Open", cLink, "", "", SW_NORMAL) },030,011,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Abrir Link"
TButton():New(065,050, OemToAnsi(STR0002), oDlg,{|| oDlg:End() },26,11,,,.F.,.T.,.F.,,.F.,,,.F. )  //"Ok"

ACTIVATE MSDIALOG oDlg CENTER

Return ( .T. )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At900Manip()
Função que pega a string recebida do pergunte de filiais após o tratamento 
com MakeSqlExpr e retorna um array de n casas com as filiais pesquisadas.

@Parametros cStrMain -> Texto principal (MV_PAR do pergunte)
			cChr	-> Caracteres a localizar ("'")
@Return 	aArray  -> Array[X][Y], sendo X a filial e Y um booleano, 
					   se existe ou não "range" de filiais no pergunte.
@author TECA Serviços - Jack Junior/Luiz Gabriel
@since 31/08/2022
/*/
//------------------------------------------------------------------------------
Static Function At900Manip(cStrMain, cChr)
Local aArray 	:= {}
Local cStrAux 	:= ""
Local cString	:= ""
Local cStrPre 	:= ""
Local nPos1 	:= 0
Local nPos2 	:= 0
Local nX 		:= 0
Local nY 		:= 0

cString := Upper(AllTrim(cStrMain))

For nX := 1 to Len(cString)
	If (nPos1 := AT(cChr, cString)) > 0
		cStrAux := Substr(cString, nPos1+1, Len(cString))
		For nY := 1 to Len(cStrAux)
			If (nPos2 := AT(cChr, cStrAux)) > 0
				cStrPre := Substr(cString, 1, nPos1-1)
				If RAT("BETWEEN", Right(AllTrim(cStrPre),7)) > 0
					AADD(aArray,{Substr(cStrAux, 1, nPos2-1),.T.})
				Else
					AADD(aArray,{Substr(cStrAux, 1, nPos2-1),.F.})
				EndIf
				cString := Substr(cString, nPos1+nPos2+1, Len(cString))
				Exit
			EndIf
		Next nY
		nX := 1
	ElseIf Len(cString) == 1
		Exit
	EndIf
Next nX

Return (aArray)
