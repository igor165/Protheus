#include "PROTHEUS.CH"
#include "PLSMGER.CH"
Static aFaixaEtaria 	:= {}
Static objCENFUNLGP := CENFUNLGP():New()
Static lAutost := .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLSR615  ³ Autor ³Guilherme Brunoro/Padua ³ Data ³ 14.11.02 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Familia/Usuario - com totalizacao                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR615                                                    ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial                               ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ 15/03/04 ³      ³ Brunoro     ³ Inclusao do parametro dDatBas         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSR615(lAuto)
	local aAlias 		:= {}
	
	Default lAuto := .F.

	Private nQtdLin     := 58
	Private nLimite     := 132     
	Private cTamanho    := "M"     
	Private cTitulo     := "Relatorio de Familias/Usuarios"
	Private cDesc1      := "Este relatorio ira emitir totais de usuarios "
	Private cDesc2      := "por familias e por contratos e por sub-contratos. "
	Private cDesc3      := ""
	Private cAlias      := "BA1"
	Private cPerg       := "PLR615"
	Private cRel        := "PLSR615"
	Private nli         := 00   
	Private m_pag       := 1    
	Private lCompres    := .F. 
	Private lDicion     := .F. 
	Private lFiltro     := .T. 
	Private lCrystal    := .F. 
	Private aOrderns    := {"Contrato + Matricula","Contrato + Nome","Matricula do sistema antigo"} 
	Private aReturn     := { "", 1,"", 1, 1, 1, "",1 } 
	Private lAbortPrint := .F.
	Private cCabec1     := "Grupo/Empresa" 
	Private cCabec2     := "Matricula            Nome                                   Dt.Nasc.   Sexo Est.Civil      Tipo Usuario   Parent.         Dt.Inicio"
	Private nColuna     := 01 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Testa ambiente do relatorio somente top...                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lAutost := lAuto

	If ! PLSRelTop()
	   Return
	Endif    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama SetPrint (padrao)                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !lAuto
		cRel  := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
	endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se foi cancelada a operacao (padrao)                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lAuto .AND. nLastKey  == 27 
	   Return
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acessa parametros do relatorio...                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)

	if !lAuto
		SetDefault(aReturn,cAlias) 
	endif

	aAlias := {"BA1", "BG9", "BT5", "BQC"}
	objCENFUNLGP:setAlias(aAlias)

	if !lAuto
		MsAguarde({|| R615Imp() }, cTitulo, "", .T.)
	else
		R615Imp()
	endif
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R615Imp  ³ Autor ³ Guilherme Brunoro     ³ Data ³ 04.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime detalhe do relatorio...                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function R615Imp()
	Local	k			  		:=	0
	Local j			  		:=	0
	Local nVlrTotTit  	:=	0
	Local nVlrTotdep  	:=	0 
	Local nVlrTotAgr  	:=	0
	Local nVlrSubTot  	:=	0
	Local nVlrTotGer  	:=	0
	Local nFaixa      	:=	0
	Local nScan       	:=	0
	Local nVlrTit     	:=	0
	Local nVlrdep     	:=	0
	Local nVlrAgr     	:=	0
	Local nIdade 			:=	0	
	Local nOrdSel			:= aReturn[8] 
	Local cBA1Name 		:= RetSQLName("BA1")	
	Local cSQL				:=	""	
	Local cMsgAv			:= ""
	Local cVlrSubTot  	:=	"" 
	Local cVlrTotGer		:=	"" 
	Local cSubCon			:=	""	
	Local aSubTot     	:= {}
	Local aTotGer     	:= {}
	//Dados do parametro...                                                    ³
	Local nTipPes     // (PF;PJ;Ambos)
	Local nTipo       // (Sintetico;Analitico)
	Local nAtivo      // Somente ativos (Sim;Nao;Ambos)
	Local nResumo     // Imprime Resumo
	Local cOpeDe      // Codigo da Operadora de
	Local cGrupoDe    // Codigo do Grupo/Empresa de
	Local cGrupoAte   // Codigo do Grupo/Empresa ate
	Local cContrDe    // Codigo do Contrato de
	Local cContrAte   // Codigo do Contrato ate
	Local cSbConDe    // Codigo do Sub-contrato de
	Local cSbConAte   // Codigo do Sub-contrato ate
	Local dDatBas     // Data de referencia
	
	Private cOperad  		:=	""
	Private cGrupEmp  		:=	""
	Private cDescGru		:=	""
	Private pQuant      	:= ""
	Private pQtdTot     	:= ""	
	Private aLinTit     	:= {}
	Private aLinDep     	:= {}
	Private aLinAgr     	:= {}
	Private aLinTotTit  	:= {}
	Private aLinTotDep  	:= {}
	Private aLinTotAgr  	:= {}
	Private aValFai     	:= {}
	Private aValTxt     	:= {}      
	Private aValTotFai  	:= {}
	Private aValTotTxt  	:= {}  
	Private nAnsFaixa  	:= 1 //1=Faixa Contratos assinados antes de 2004/2=Faixa Contratos assinados depois de 2004    

	nTipPes    := mv_par01 
	nTipo      := mv_par02 
	nAtivo     := mv_par03 
	nResumo    := mv_par04
	cOpeDe     := mv_par05 
	cOpeAte	  := mv_par06
	cGrupoDe   := mv_par07
	cGrupoAte  := mv_par08 
	cContrDe   := mv_par09 
	cContrAte  := mv_par10 
	cSbConDe   := mv_par11
	cSbConAte  := mv_par12 
	
	If  ! Empty(mv_par13)
	    dDatBas    := mv_par13 
	Else
	    dDatBas    := dDataBase 
	Endif
	
	//Carrega o array com as faixas Etarias                   		
	RetFai(0)
	//Caso haja 7 faixas = contratos antes de 2004, se for 10 faixas e para contratos depois de 2004.
	nAnsFaixa	:=	 Len(aFaixaEtaria)
   If nResumo == 1
		If nAnsFaixa == 7
			aValFai		:=	Array(nAnsFaixa)
			aValTotFai	:= Array(nAnsFaixa)
			pQuant      := "@E 999999"
			pQtdTot     := "@E 999999999"	
			nAnsFaixa	:=	1
		ElseIf nAnsFaixa == 10
			aValFai		:=	Array(nAnsFaixa)
			aValTotFai	:= Array(nAnsFaixa)  
			pQuant      := "@E 9999"		
			pQtdTot     := "@E 999999"
			nAnsFaixa	:=	2		
		Else
			cMsgAv	:=	"A quantidade de faixas etárias cadastradas, esta fora do padrão da ANS (Maximo de 10)." + chr(13)
			cMsgAv	+=	"Por favor, verifique o cadastro de faixas etárias."+ chr(13)
			cMsgAv	+=	"Deseja processeguir com a execução do relatório?"
				
			If MsgYesNo(cMsgAv)
				aValFai		:=	Array(10)
				aValTotFai	:= Array(10)  
				pQuant      := "@E 9999"		
				pQtdTot     := "@E 999999"
				nAnsFaixa	:=	2
			Else
				Return .F.
			EndIf		
		EndIf 
		aFill(aValFai,0)
		aFill(aValTotFai,0)	
	EndIf

	if !lAutost
		MsProcTxt(PLSTR0001) 
	endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz filtro no arquivo de Usuarios...                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := "SELECT BA1_CODINT,BA1_CODEMP,BA1_CONEMP,BA1_SUBCON,BA1_MOTBLO,BA1_VERCON,BA1_VERSUB,BA1_MATRIC,"
	cSQL += "BA1_TIPREG,BA1_NOMUSR,BA1_DATNAS,BA1_SEXO,BA1_ESTCIV,BA1_TIPUSU,BA1_GRAUPA,BA1_DATINC,BA1_MATANT "
	cSQL += "FROM "+cBA1Name+" "
	cSQL += "WHERE "+cBA1Name+".D_E_L_E_T_ = '' AND "
	cSQL += "BA1_FILIAL = '"+xFilial("BA1")+"' AND "
	cSQL += "BA1_CODINT >= '"+cOpeDe+"' AND    "
	cSQL += "BA1_CODINT <= '"+cOpeAte+"' AND    "
	cSQL += "BA1_CODEMP >= '"+cGrupoDe+"' AND  " 
	cSQL += "BA1_CODEMP <= '"+cGrupoAte+"'     "
	
	If nTipPes == 2 // Pessoa Juridica
	  cSQL += " AND BA1_CONEMP >= '"+cContrDe+"'   " 
	  cSQL += " AND BA1_CONEMP <= '"+cContrAte+"'  " 
	  cSQL += " AND BA1_SUBCON >= '"+cSbConDe+"'   " 
	  cSQL += " AND BA1_SUBCON <= '"+cSbConAte+"'  " 
	  cSQL += " AND BA1_CONEMP <> ''   "   
	  cSQL += " AND BA1_SUBCON <> ''   "     
	ElseIf nTipPes == 1 // Pessoa Fisica
	  cSQL += " AND BA1_CONEMP = ''   "   
	  cSQL += " AND BA1_SUBCON = ''   "   
	EndIf
	cSQL += "	AND BA1_DATINC <='"+DTOS(dDatBas)+"' "
	
	If  nAtivo == 1//Ativo
		cSQL += "AND (BA1_DATBLO = '   ' OR BA1_DATBLO >'"+DTOS(dDatBas)+"') "
	ElseIf nAtivo == 2  //Bloqueado
		cSQL += "AND (BA1_DATBLO <> '   ' AND BA1_DATBLO <='"+DTOS(dDatBas)+"') "
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se houver filtro executa parse para converter expressoes adv para SQL    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Empty(aReturn[7])
	   cSQL += " AND (" + PLSParSQL(aReturn[7])+" ) "
	Endif   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ De acordo com a ordem....                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOrdSel == 1 //codigo...
	    cSQL += "ORDER BY BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB+BA1_MATRIC+BA1_TIPREG"  
	ElseIf  nOrdSel == 2  //nome...
	    cSQL += "ORDER BY BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB+BA1_NOMUSR"  
	ElseIf  nOrdSel == 3  //Pela matricula antiga...       
		cSQL += "ORDER BY BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB+BA1_MATANT "
		// Altera o cabecalho do relatorio...'
		cCabec2 := "Mat. Antiga          Nome                                   Dt.Nasc.   Sexo Est.Civil      Tipo Usuario   Parent.         Dt.Inicio"	
	Endif                          
	
	PLSQuery(cSQL,"BA1TRB")
	cSQL := ChangeQuery(cSQL)
	BA1TRB->(DbGotop())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio da impressao dos detalhes.'..                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While ! BA1TRB->(Eof())
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	      //³ Verifica se foi abortada a impressao...                            ³
	      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	      If !lAutost .AND. Interrupcao(lAbortPrint)
	         nLi ++
	         @ nLi, nColuna pSay PLSTR0002
	         Exit
	      Endif                       
	      
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	      //³ Imprime cabecalho...                                               ³
			//³ Posiciono e Imprime grupo/empresa...                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	      Posicione("BG9",1,xFilial("BG9")+BA1TRB->(BA1_CODINT+BA1_CODEMP),"BG9_DESCRI")
	
	      If nTipo <> 2
				R615Cabec()
				@ nLi,nColuna pSay objCENFUNLGP:verCamNPR("BA1_CODINT", BA1TRB->BA1_CODINT)+"."+objCENFUNLGP:verCamNPR("BA1_CODEMP", BA1TRB->BA1_CODEMP)+" - "+ objCENFUNLGP:verCamNPR("BG9_DESCRI", BG9->BG9_DESCRI)
				@ nLi++
	      EndIf
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	      //³ Atribuo valor as variaveis de controle...                                ³
	      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	      cOperad  := BA1TRB->BA1_CODINT
	      cGrupEmp := BA1TRB->BA1_CODEMP
	      cDescGru := Substr(BG9->BG9_DESCRI,1,40)
	      cContrat := BA1TRB->(BA1_CONEMP+BA1_VERCON)
	      cSubCon  := BA1TRB->(BA1_SUBCON+BA1_VERSUB)
	
	      While ! BA1TRB->(Eof()) .And. BA1TRB->(BA1_CODINT+BA1_CODEMP) == cOperad+cGrupEmp
	         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	         //³ Posiciono e Imprime Contrato, se for pessoa juridica...            ³
	         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	         If nTipPes == 2 .And. nTipo <> 2 // Pessoa Juridica
	            BT5->(DbSetOrder(1))// BT5_CODINT + BT5_CODIGO + BT5_NUMCON + BT5_VERSAO
	            BT5->(DbSeek(xFilial("BT5")+BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)))

	            @ ++nLi, nColuna pSay "Contrato: "+objCENFUNLGP:verCamNPR("BA1_CONEMP", BA1TRB->BA1_CONEMP)+" - Versao: "+objCENFUNLGP:verCamNPR("BA1_VERCON", BA1TRB->BA1_VERCON)+" - "+ objCENFUNLGP:verCamNPR("BT5_TIPCON", Posicione("BII",1,xFilial("BII")+BT5->BT5_TIPCON,"BII_DESCRI"))
	         EndIf
	         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	         //³ Atribuo valor as variaveis de controle...                                ³
	         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	         cOperad  := BA1TRB->BA1_CODINT
	         cGrupEmp := BA1TRB->BA1_CODEMP
	         cContrat := BA1TRB->(BA1_CONEMP+BA1_VERCON)
	         cSubCon  := BA1TRB->(BA1_SUBCON+BA1_VERSUB)
	
	         While ! BA1TRB->(Eof()) .And. BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON) == cOperad+cGrupEmp+cContrat
	            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	            //³ Posiciono no Sub-Contrato, se for pessoa juridica...                     ³
	            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	            If nTipPes == 2 .And. nTipo <> 2 // Pessoa Juridica
	               BQC->(DbSetOrder(1))// BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB
	               BQC->(DbSeek(xFilial("BQC")+BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))

	               nLi++
	               @ ++nLi, nColuna pSay "Sub-Contrato: "+objCENFUNLGP:verCamNPR("BA1_SUBCON", BA1TRB->BA1_SUBCON)+" - Versao: "+objCENFUNLGP:verCamNPR("BA1_VERSUB", BA1TRB->BA1_VERSUB)+" - "+ objCENFUNLGP:verCamNPR("BQC_DESCRI", BQC->BQC_DESCRI)
	               @ ++nLi,nColuna pSay Replicate("-",nLimite)
	            Endif
	            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	            //³ Atribuo valor as variaveis de controle...                                ³
	            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	            cOperad  := BA1TRB->BA1_CODINT
	            cGrupEmp := BA1TRB->BA1_CODEMP
	            cContrat := BA1TRB->(BA1_CONEMP+BA1_VERCON)
	            cSubCon  := BA1TRB->(BA1_SUBCON+BA1_VERSUB)
	            
	            While ! BA1TRB->(Eof()) .And. BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB) ==cOperad+cGrupEmp+cContrat+cSubCon
	               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	               //³ Exibe mensagem...                                                  ³
	               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	               If !lAutost .AND. nOrdSel == 1
	                  MsProcTXT("Usuario: "+objCENFUNLGP:verCamNPR("BA1_CODINT", BA1TRB->BA1_CODINT)+"."+objCENFUNLGP:verCamNPR("BA1_CODEMP", BA1TRB->BA1_CODEMP)+"."+objCENFUNLGP:verCamNPR("BA1_MATRIC", BA1TRB->BA1_MATRIC)+"...")
	               Elseif !lAutost .AND. nOrdSel == 2
	                  MsProcTXT("Usuario: "+objCENFUNLGP:verCamNPR("BA1_NOMUSR", Substr(BA1TRB->BA1_NOMUSR,1,30)))
	               Elseif !lAutost .AND. nOrdSel == 3
	                  MsProcTXT("Usuario: "+objCENFUNLGP:verCamNPR("BA1_MATANT", Substr(BA1TRB->BA1_MATANT,1,30)))
	               Endif
	               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	               //³ Imprime usuario, se for relatorio analitico...                     ³
	               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	               If nTipo == 1// Analitico
							/*
							  "          10        20        30        40        50        60        70        80        90        100       110       120       130"
							  "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
							  "Mat. Antiga          Nome                                   Dt.Nasc.   Sexo Est.Civil      Tipo Usuario   Parent.         Dt.Inicio"	
							*/  
	
	                  @ ++nLi, nColuna pSay Iif(nOrdSel <> 3,  objCENFUNLGP:verCamNPR("BA1_CODINT", BA1TRB->BA1_CODINT)+"."+;
					  										   objCENFUNLGP:verCamNPR("BA1_CODEMP", BA1TRB->BA1_CODEMP)+"."+;
															   objCENFUNLGP:verCamNPR("BA1_MATRIC", BA1TRB->BA1_MATRIC)+"-"+;
															   objCENFUNLGP:verCamNPR("BA1_TIPREG", BA1TRB->BA1_TIPREG), objCENFUNLGP:verCamNPR("BA1_MATANT", BA1TRB->BA1_MATANT) )
	                                      
	                  @ nLi, 021 pSay objCENFUNLGP:verCamNPR("BA1_NOMUSR", Substr(BA1TRB->BA1_NOMUSR,1,38))
	                  @ nLi, 060 pSay objCENFUNLGP:verCamNPR("BA1_DATNAS", Dtoc(BA1TRB->BA1_DATNAS))
	                  @ nLi, 071 pSay Iif(!Empty(BA1TRB->BA1_SEXO), objCENFUNLGP:verCamNPR("BA1_SEXO", Substr(X3COMBO("BA1_SEXO",BA1TRB->BA1_SEXO),1,3)), Space(03))
	                  @ nLi, 076 pSay objCENFUNLGP:verCamNPR("BA1_ESTCIV", Substr(Posicione("SX5",1,xFilial("SX5")+"33"+BA1TRB->BA1_ESTCIV,"X5_DESCRI"),1,15))
	              	  @ nLi, 091 pSay objCENFUNLGP:verCamNPR("BA1_TIPUSU", Substr(Posicione("BIH",1,xFilial("BIH")+BA1TRB->BA1_TIPUSU,"BIH_DESCRI"),1,15))
	                  @ nLi, 106 pSay objCENFUNLGP:verCamNPR("BA1_GRAUPA", Substr(Posicione("BRP",1,xFilial("BRP")+BA1TRB->BA1_GRAUPA,"BRP_DESCRI"),1,15))
	      			  @ nLi, 122 pSay objCENFUNLGP:verCamNPR("BA1_DATINC", Dtoc(BA1TRB->BA1_DATINC))
	               Endif
	               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	               //³ verifica proxima pagina...                                         ³
	               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	               If nLi > nQtdLin .And. nTipo <> 2
	                  R615Cabec()
	               Endif 
	               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	               //³ Atribuo valor as variaveis de controle...                                ³
	               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	               cOperad  := BA1TRB->BA1_CODINT
	               cGrupEmp := BA1TRB->BA1_CODEMP
	               cContrat := BA1TRB->(BA1_CONEMP+BA1_VERCON)
	               cSubCon  := BA1TRB->(BA1_SUBCON+BA1_VERSUB)
	               nIdade   := Calc_Idade(dDataBase,BA1TRB->BA1_DATNAS)
	               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	               //³ Atribuo valores aos totalizadores...                                     ³
	               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	               If nResumo == 1 // Imprime Resumo
	                  nFaixa := RetFai(nIdade)  
	                  
	                  nScan  := aScan(aSubTot,{|x|x[1]==Alltrim(BA1TRB->BA1_TIPUSU) .AND. x[2]==Alltrim(BA1TRB->BA1_SEXO) .And. x[3]==nFaixa })
	                  If nScan == 0
	                     aadd(aSubTot,{Alltrim(BA1TRB->BA1_TIPUSU),Alltrim(BA1TRB->BA1_SEXO),nFaixa,1})
	                  Else  
	                    aSubTot[nScan,4] := aSubTot[nScan,4] + 1
	                  Endif
	                  
	                  nScan  := aScan(aTotGer,{|x|x[1]==Alltrim(BA1TRB->BA1_TIPUSU) .AND. x[2]==Alltrim(BA1TRB->BA1_SEXO) .And. x[3]==nFaixa })
	                  If nScan == 0
	                     aadd(aTotGer,{Alltrim(BA1TRB->BA1_TIPUSU),Alltrim(BA1TRB->BA1_SEXO),nFaixa,1})               
	                  Else
	                    aTotGer[nScan,4] := aTotGer[nScan,4] + 1
	                  Endif
	               Endif
	               BA1TRB->(DbSkip())
	            Enddo
	         Enddo   
	      Enddo
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	      //³ Atribuo valores do Sub-total...                                          ³
	      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	      If nResumo == 1 // Imprime Resumo
	         //Titular
				nVlrTit	:=	LoadFaixa(aLinTit,aSubTot,aValFai,"T")
	         //Depedente
	  			nVlrDep	:=	LoadFaixa(aLinDep,aSubTot,aValFai,"D")
	         //Agregado
	  			nVlrAgr	:=	LoadFaixa(aLinAgr,aSubTot,aValFai,"A")         
	     
	         For J := 1 to Len(aValFai)      
	             aadd(aValTxt,Transform(aValFai[J],pQtdTot))
	         Next
	            
	         nVlrSubTot := nVlrTit+nVlrDep+nVlrAgr
	         cVlrSubTot := Transform(nVlrSubTot,pQtdTot)
	
	         aadd(aValTxt,cVlrSubTot)
	         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	         //³ Imprime Sub-Total por grupo/empresa...                             ³
	         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	         PrintValor(.F.)
	
	         aSubTot    := {}
	         aLinTit    := {}
	         aLinDep    := {}
	         aLinAgr    := {}
	         aValTxt    := {}      
	         nVlrTit    := 0
	         nVlrDep    := 0
	         nVlrAgr    := 0
	         nVlrSubTot := 0
				aFill(aValFai,0)	         
	      Endif
	Enddo
	
	//Imprime Resumo	
	If nResumo == 1 
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Atribuo valores do Total Geral...                                        ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   //Titular
		nVlrTotTit	:=	LoadFaixa(aLinTotTit,aTotGer,aValTotFai,"T")
	         
	   //Depedente
		nVlrTotDep	:=	LoadFaixa(aLinTotDep,aTotGer,aValTotFai,"D")
	      
	   //Agregado
		nVlrTotAgr	:=	LoadFaixa(aLinTotAgr,aTotGer,aValTotFai,"A")
		
	   For J := 1 to Len(aValTotFai)
	       aadd(aValTotTxt,Transform(aValTotFai[J],pQtdTot))          
	   Next
	
	   nVlrTotGer := nVlrTotTit+nVlrTotDep+nVlrTotAgr
	   cVlrTotGer := Transform(nVlrTotGer,pQtdTot)
	
	   aadd(aValTotTxt,cVlrTotGer)      

	   //Imprime Total Geral
	   PrintValor(.T.)
	Endif
	
	//Imprime rodape do relatorio
	if !lAutost
		Roda(0,space(10),cTamanho)
	endif

	BA1TRB->(DbCloseArea())
	
	//Libera impressao
	If !lAutost .AND. aReturn[5] == 1 
	    Set Printer To
	    Ourspool(cRel)
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R615Cabec ³ Autor ³ Guilherme Brunoro    ³ Data ³ 04.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime Cabecalho                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function R615Cabec()      
	nLi ++
	if !lAutost
		nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
	endif
	nLi ++

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ RetFai    ³ Autor ³ Guilherme Brunoro    ³ Data ³ 26.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna a faixa etaria do usuario                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function RetFai(nIdade)
	Local nFaixa		:=	0
	Local nRetFaixa	:=	0
	Local nIdadeAnt	:=	-1

	If Len(aFaixaEtaria) == 0
		BL9->(DbGoTop())
		While ! BL9->(Eof())
			nIdadeAnt++
			aadd(aFaixaEtaria,{BL9->BL9_SEQUEN,nIdadeAnt,BL9->BL9_IDADEF})
			nIdadeAnt	:=	BL9->BL9_IDADEF
		   BL9->(DbSkip())
		EndDo
	EndIf	  

	For nFaixa := 1 To Len(aFaixaEtaria)
		If nIdade <= aFaixaEtaria[nFaixa,3] 
			nRetFaixa := val(aFaixaEtaria[nFaixa,1])
			Exit
		EndIf
	Next nFaixa
	
Return nFaixa

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ fPegaVal  ³ Autor ³ Padua/Brunoro        ³ Data ³ 27.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna valor de cada faixa                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fPegaVal(aSubTot,cTipUsu,cSexo,nFaixa)
	Local nScan := aScan(aSubTot,{|x|x[1]==Alltrim(cTipUsu) .AND. x[2]==Alltrim(cSexo) .And. x[3]==nFaixa})

	If nScan <> 0
	   Return(Transform(aSubTot[nScan,4],pQuant))   
	Endif
	
Return (Transform(0,pQuant))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcSubTot³ Autor ³ Guilherme Brunoro     ³ Data ³27.12.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa Sub-Total                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function PrintValor(isTotGeral)       
	Local	aL		:=	GetLayANS(isTotGeral)

	//Imprime cabecalho...
	R615Cabec()      
	
	FmtLin({},aL[01],,,@nLi)
	FmtLin({cOperad,cGrupEmp,cDescGru},aL[02],,,@nLi)
	//
	FmtLin({},aL[03],,,@nLi)
	FmtLin({},aL[04],,,@nLi)
	FmtLin({},aL[05],,,@nLi)
	FmtLin({},aL[06],,,@nLi)
	FmtLin({},aL[07],,,@nLi)   
	FmtLin({},aL[08],,,@nLi)
	FmtLin({},aL[09],,,@nLi)
	
	//Impressao dos Valores
	If isTotGeral
		FmtLin(aLinTotTit,aL[10],,,@nLi)      
		FmtLin({},aL[11],,,@nLi)
		FmtLin(aLinTotDep,aL[12],,,@nLi)      
		FmtLin({},aL[13],,,@nLi)
		FmtLin(aLinTotAgr,aL[14],,,@nLi)      
		FmtLin({},aL[15],,,@nLi)
		FmtLin(aValTotTxt,aL[16],,,@nLi)
		FmtLin({},aL[17],,,@nLi)
	Else 
		FmtLin(aLinTit,aL[10],,,@nLi)      
		FmtLin({},aL[11],,,@nLi)
		FmtLin(aLinDep,aL[12],,,@nLi)      
		FmtLin({},aL[13],,,@nLi)
		FmtLin(aLinAgr,aL[14],,,@nLi)      
		FmtLin({},aL[15],,,@nLi)
		FmtLin(aValTxt,aL[16],,,@nLi)
		FmtLin({},aL[17],,,@nLi)	
	EndIf
		
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GetLayANS ³ Autor ³ PSL Team              ³ Data ³10.08.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna qual e o layout que sera usado pelo relatorio.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function GetLayANS(isTotGeral)
	Local aLayCab := {}
	
	If nAnsFaixa == 1
		aLayCab	:=	LayANSOld(isTotGeral)
	Else
		aLayCab	:=	LayANSNew(isTotGeral)
	EndIf

Return aLayCab

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LayANSOld ³ Autor ³ PSL Team              ³ Data ³10.08.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta Lay-Out do total geral                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function LayANSOld(isTotGeral)
	Local aL 	:= Array(17)
	Local nItem	:= 0
	
	aL[01]:="+=========================================================================================================================+"
	If isTotGeral 
		aL[02]:="| Resumo Geral do Relatorio  --->>  Grupo/Empresa: ####-#### a ####-####                                                  |"
	Else
		aL[02]:="| Resumo do Grupo/Empresa: ####-#### - ############################################                                       |"	
	EndIf
	aL[03]:="+=========================================================================================================================+"
	aL[04]:="|                                             Faixas Etarias - Padrao ANS                                                 |"
	aL[05]:="+=========================================================================================================================+"

	//	aL[06]:="| Idade     |   0  - 17   |   18 - 29   |   30 - 39   |   40 - 49   |   50 - 59   |   60 - 69   |  70 - 999   |  TOTAIS   |"
	//Monta as faixas etarias de acordo com o BL9
	aL[06]:="| Idade     |"
	For nItem := 1 To 7
		aL[06]+= Space(03)
		aL[06]+= StrZero(aFaixaEtaria[nItem,02],3) +"-"+ StrZero(aFaixaEtaria[nItem,03],3)
		aL[06]+= Space(03)+"|"
	Next nItem
	aL[06]+=  "  TOTAIS   |"  	
	
	aL[07]:="+-----------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+-----------+"
	aL[08]:="| Sexo      |  M   |  F   |  M   |  F   |  M   |  F   |  M   |  F   |  M   |  F   |  M   |  F   |  M   |  F   |           |"
	aL[09]:="+-----------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+-----------+"
	aL[10]:="| Titular   |######|######|######|######|######|######|######|######|######|######|######|######|######|######| ######### |"
	aL[11]:="+-----------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+-----------+"
	aL[12]:="| Dependente|######|######|######|######|######|######|######|######|######|######|######|######|######|######| ######### |"
	aL[13]:="+-----------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+-----------+"
	aL[14]:="| Agregado  |######|######|######|######|######|######|######|######|######|######|######|######|######|######| ######### |"
	aL[15]:="+-----------+------+------+------+------+------+------+------+------+------+------+------+------+------+------+-----------+"
	aL[16]:="| TOTAIS    |  #########  |  #########  |  #########  |  #########  |  #########  |  #########  |  #########  | ######### |"
	aL[17]:="+-----------+-------------+-------------+-------------+-------------+-------------+-------------+-------------+-----------+"
         
Return(aL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LayANSNew ³ Autor ³ PLS-Team              ³ Data ³10.08.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta Lay-Out do total, para planos regulamentados          ³±±
±±³Descri‡…o ³a partir de 2004.                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function LayANSNew(isTotGeral)
	Local aL 		:= Array(17) 
	Local nItem 	:=	0
	Local nQtdFaixa:= Len(aFaixaEtaria)

	aL[01]	:=	"+=====================================================================================================================+"
	If isTotGeral
		aL[02]	:=	"| Resumo Geral do Relatorio  --->>  Grupo/Empresa: ####-#### a ####-####                                              |"
	Else
		aL[02]	:= "| Resumo do Grupo/Empresa: ####-#### - ############################################                                   |"			
	EndIf	
	aL[03]	:=	"+=====================================================================================================================+"
	aL[04]	:=	"|                                             Faixas Etarias - Padrao ANS                                             |"
	aL[05]	:=	"+=====================================================================================================================+"
	
	//Monta as faixas etarias de acordo com o BL9
	//aL[06]	:=	"|Idade     | 000-000 |  19-23  |  24-28  |  29-33  |  34-38  |  39-43  |  44-48  |  49-53  |  54-58  |  59-200 |TOTAIS|"	
	aL[06]:="| Idade    |"
	For nItem := 1 To 10
		aL[06]+= Space(01)
		If nItem <= nQtdFaixa
			aL[06]+= StrZero(aFaixaEtaria[nItem,02],3) +"-"+ StrZero(aFaixaEtaria[nItem,03],3)
		Else
			aL[06]+= "XXX-ZZZ"
		EndIf
		aL[06]+= Space(01)+"|"
	Next nItem
	aL[06]+=  "TOTAIS|"  	
	
	aL[07]	:=	"+----------+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+------+"
	aL[08]	:=	"|Sexo      |  M |  F | M  |  F | M  | F  | M  | F  | M  | F  | M  | F  | M  | F  | M  | F  | M  | F  | M  | F  |      |"
	aL[09]	:=	"+----------+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+------+"
	aL[10]	:=	"|Titular   |####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|######|"
	aL[11]	:=	"+----------+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+------+"
	aL[12]	:=	"|Dependente|####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|######|"
	aL[13]	:=	"+----------+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+------+"
	aL[14]	:=	"|Agregado  |####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|####|######|"
	aL[15]	:=	"+----------+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+------+"
	aL[16]	:=	"|TOTAIS    |  ###### |  ###### |  ###### |  ###### |  ###### |  ###### |  ###### |  ###### |  ###### |  ###### |######|"
	aL[17]	:=	"+----------+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+------+"
	
Return(aL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LoadFaixa ³ Autor ³ PLS-Team              ³ Data ³10.08.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o array com as quantidades de usuarios por faixa.     ³±±
±±³Descri‡…o ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function LoadFaixa(aLinha,aTotGrupo,aSumFaixa,cType)
	Local J 			:=	0
	Local K			:=	0	
	Local nQtdVida :=	0

	For J := 1 to len(aSumFaixa)
		For K := 1 to 2
			Aadd(aLinha, fPegaVal(aTotGrupo,cType,Str(K),J))
			nQtdVida 	:= nQtdVida + Val(fPegaVal(aTotGrupo,cType,Str(K),J))
			aSumFaixa[J]:= aSumFaixa[J] + Val(fPegaVal(aTotGrupo,cType,Str(K),J))
		Next K
	Next J                                              
	
   Aadd(aLinha,Transform(nQtdVida,pQtdTot))

Return nQtdVida
