#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "GPER857.CH"
#INCLUDE "TOPCONN.CH"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ GPER857 ³ Autor ³Marcos Kato                      ³ Data ³ 14/01/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Relatório ARC										                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tiago Malta ³16/05/2011³009206/2011³Ajustes no layout do relatorio.             ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso     ³ Microsiga						                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function GPER857()
Local cString		:= "SRA"
Local nomeProg 		:= "GPER857"  
Local cPerg     	:= "GPER857"
Local cDesc1		:=STR0001//"Comprovante de Retencao ISLR"
Local cDesc2 		:=STR0002//"Ser  impresso de acordo com os parametros solicitados pelo"
Local cDesc3 		:=STR0003//"usuario."
Local aArea			:= GetArea()
Local cTamanho		:="P"
Local nCont			:= 0
Private oPrint
Private cTitulo 	:= STR0001//"Comprovante de Retencao ISLR"
Private aReturn 	:= {STR0004, 1,STR0005, 2, 1, 1, "",1 }//Zebrado#Administracao
Private oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.F.,.F.)
Private oArial12N	:= TFont():New("Arial",12,12,,.T.,,,,.F.,.F.)
Private cStartPath	:= GetSrvProfString("Startpath","")
Private nLin		:= 0 ,nCol		  	:= 0 ,nPag			:= 0
Private cProces		:= "",cAnoBas		:= "",cPeriod		:= "",cRotSra		:= ""
Private cTurSra		:= "",cFilSra		:= "",cCCusto		:= "",cDepart		:= ""
Private cMatric		:= "",cSitua 		:= "",cCateg        := "",cNome  		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "GPER857"

wnrel:=SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,,,cTamanho,,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif
//=======================================================================
//MV_PAR01 - PROCESSO
//MV_PAR02 - ANO DO COMPROVANTE DE RENDA
//MV_PAR03 - FILIAL
//MV_PAR04 - CENTRO DE CUSTO
//MV_PAR05 - DEPARTAMENTO
//MV_PAR06 - MATRICULA
//MV_PAR07 - SITUACAO
//MV_PAR08 - NOME DO FUNCIONARIO
//MV_PAR09 - CATEGORIA
//=======================================================================
cProces:=MV_PAR01
cAnoBas:=MV_PAR02
cFilSra:=IIF(EMPTY(MV_PAR03),"",RANGESX1("RA_FILIAL",MV_PAR03))
cCCusto:=IIF(EMPTY(MV_PAR04),"",RANGESX1("RA_CC"    ,MV_PAR04))
cDepart:=IIF(EMPTY(MV_PAR05),"",RANGESX1("RA_DEPTO" ,MV_PAR05))
cMatric:=IIF(EMPTY(MV_PAR06),"",RANGESX1("RA_MAT"   ,MV_PAR06))
cSitua :="'"
For nCont:=1 To Len(MV_PAR07)
	cSitua+=Substr(MV_PAR07,nCont,1)+"','"
Next                                  
cSitua:=Substr(cSitua,1,Len(cSitua)-2)    
If Empty(cSitua)
	cSitua:="' '"
Endif
cNome  :=IIF(EMPTY(MV_PAR08),"",RANGESX1("RA_NOME"  ,MV_PAR08))
cCateg:="'"
For nCont:=1 To Len(MV_PAR09)
	cCateg+=Substr(MV_PAR09,nCont,1)+"','"
Next                                  
cCateg:=Substr(cCateg,1,Len(cCateg)-2)
If Empty(cCateg)
	cCateg:="' '"
Endif

oPrint:= TMSPrinter():New( cTitulo)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se ha impressora ativa conectada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! oPrint:IsPrinterActive()
	oPrint:Setup()							//-- Escolhe a impressora
	If ! oPrint:IsPrinterActive()
	Help(" ",1,"NOPRINTGRA")			//-- Nao foi encontrada configuracao de impressora. ##Certifique-se de que as configurações da impressora estão corretas ou se há alguma impressora conectada.
		Return(Nil)
	Endif
Endif
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
//Modo de Impressao                                                           //
//oPrint:SetLandscape() - Impressao Paisagem                                  //
//oPrint:SetPortrait()  - Impressao Retrato                                   //
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
oPrint:SetPortrait()

MsgRun(STR0008,STR0007, {||CursorWait(),RELARC(),CursorArrow()})//"Processando Comprovante de Retencao"#"Aguarde..."

SET DEVICE TO SCREEN
MS_FLUSH()

RestArea( aArea)
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ RELARC ³  Autor ³Marcos Kato              ³ Data ³ 14/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Contem todo o detalhe do Comprovante de Retencao ISLR 	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ Microsiga						                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function RELARC()
Local cQryArc    	:= "",cMat			:= "",cNomFunc		:= "",cRgFunc 		:= ""
Local cEmpNom 		:= "",cEmpRIF 		:= "",cEmpEnd 		:= "",cEmpCid 		:= ""
Local cEmpCep 		:= "",cEmpEst 		:= "",cEmpTel 		:= "",cEmpIns 		:= ""
Local cDtArq 		:= ""
Local nMes   		:= 0 ,nVlrRem		:= 0 ,nVlrImp       := 0 ,nPorRet		:= 0 ,nVlrSal1 		:= 0 ,nVlrSal2 		:= 0 
Local nVlrSal3 		:= 0 ,nVlrSal4 		:= 0 ,nVlrSal5 		:= 0 ,nVlrSal6 		:= 0 ,nVlrSal7 		:= 0 ,nCont         := 0
Local nVlrRemPR		:= 0 ,nVlrDedPR		:= 0 ,nVlrConPR		:= 0 ,nVlrAscPR		:= 0 ,nVlrDesPR		:= 0 ,nVlrTotPR		:= 0
Local nVlrRemPV		:= 0 ,nVlrDedPV		:= 0 ,nVlrConPV		:= 0 ,nVlrAscPV		:= 0 ,nVlrDesPV		:= 0 ,nVlrTotPV		:= 0
Local nVlrRemSV		:= 0 ,nVlrDedSV		:= 0 ,nVlrConSV		:= 0 ,nVlrAscSV		:= 0 ,nVlrDesSV		:= 0 ,nVlrTotSV		:= 0
Local nVlrRemTV		:= 0 ,nVlrDedTV		:= 0 ,nVlrConTV		:= 0 ,nVlrAscTV		:= 0 ,nVlrDesTV		:= 0 ,nVlrTotTV		:= 0
Local nLinRet		:= 0
Local aVlrMes		:=  {}
Local lNacVen		:= .F.
//==============================================================================================================================================
//====================================Processando Comprovante de Retencao ISLR==================================================================
//==============================================================================================================================================
                 
cQryArc:="SELECT RA_FILIAL,RA_MAT,RA_PRINOME,RA_SECNOME,RA_NOME,RA_CIC,RA_RG,RA_NACIONA,RV_DIRF,RD_DATARQ,RD_VALOR "
cQryArc+="FROM "+RetSqlName("SRD")+" SRD "
cQryArc+="INNER JOIN "+RetSqlName("SRA")+" SRA ON "
cQryArc+="RA_MAT = RD_MAT "   
If !Empty(cFilSra)                     
	cQryArc+="AND "+cFilSra
Endif
If !Empty(cCCusto)
	cQryArc+="AND "+cCCusto
Endif
If !Empty(cDepart)
	cQryArc+="AND "+cDepart
Endif
If !Empty(cMatric)
	cQryArc+="AND "+cMatric
Endif
If !Empty(cNome)
	cQryArc+="AND "+cNome
Endif
cQryArc+="AND RA_CATFUNC IN ("+cCateg+")
cQryArc+="AND RA_SITFOLH IN ("+cSitua+") "	
cQryArc+="AND RA_PROCES = RD_PROCES "
cQryArc+="AND RA_PROCES ='"+cProces+"' "
If !Empty(cTurSra)
	cQryArc+="AND RA_TNOTRAB ='"+cTurSra+"' "
Endif
cQryArc+="AND SRA.D_E_L_E_T_='' "
cQryArc+="LEFT JOIN "+RetSqlName("SRV")+" SRV ON "
cQryArc+="RV_COD=RD_PD "         
cQryArc+="AND SRV.D_E_L_E_T_='' "
cQryArc+="WHERE SRD.D_E_L_E_T_='' "
cQryArc+="AND SUBSTRING(RD_DATARQ,1,4) = '"+cAnoBas+"' "
cQryArc+="ORDER BY RA_FILIAL,RA_MAT, RD_DATARQ "
cQryArc:= ChangeQuery(cQryArc)


If Select("TRBARC")>0
	DbSelectArea("TRBARC")
	TRBARC->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryARC),"TRBARC",.F.,.T.)
If TRBARC->(!Eof())       
	Do While TRBARC->(!Eof()) 
		nVlrRemPR:=0
		nVlrDedPR:=0
		nVlrConPR:=0
		nVlrAscPR:=0
		nVlrDesPR:=0
		nVlrRemPV:=0
		nVlrDedPV:=0
		nVlrConPV:=0
		nVlrAscPV:=0
		nVlrDesPV:=0
		nVlrRemSV:=0
		nVlrDedSV:=0
		nVlrConSV:=0
		nVlrAscSV:=0
		nVlrDesSV:=0
		nVlrRemTV:=0
		nVlrDedTV:=0
		nVlrConTV:=0
		nVlrAscTV:=0
		nVlrDesTV:=0
		nVlrTotPR:=0
		nVlrTotPV:=0
		nVlrTotSV:=0
		nVlrTotTV:=0

		aVlrMes		:=  array(12,5)
		For nCont := 1 to 12
			aFill(aVlrMes[nCont],0)
		Next  

		DbSelectArea("SM0")
		SM0->(DbSetOrder(1))
		SM0->(DbSeek(cEmpAnt+TRBARC->RA_FILIAL))
		cNomFunc:=IIF(EMPTY(TRBARC->RA_PRINOME),ALLTRIM(TRBARC->RA_NOME),ALLTRIM(TRBARC->RA_PRINOME)+" "+ALLTRIM(TRBARC->RA_SECNOME))//Nome do Funcionario
		cRgFunc :=ALLTRIM(TRBARC->RA_RG)                                     //Rg do Funcionario		
		lNacVen:=Iif(TRBARC->RA_NACIONA=="60",.T.,.F.)		                 //Nacionalidade 
        cEmpNom :=IIF(EMPTY(SM0->M0_NOMECOM),SM0->M0_NOME,SM0->M0_NOMECOM)   //Nome da Empresa
        cEmpRIF :=SM0->M0_CGC                                                //CPF da Empresa   
        cEmpEnd :=IIF(EMPTY(SM0->M0_ENDCOB),SM0->M0_ENDENT,SM0->M0_ENDCOB)   //Endereco da Empresa
        cEmpCid :=IIF(EMPTY(SM0->M0_CIDCOB),SM0->M0_CIDENT,SM0->M0_CIDCOB)   //Cidade da Empresa
        cEmpCep :=IIF(EMPTY(SM0->M0_CEPCOB),SM0->M0_CEPENT,SM0->M0_CEPCOB)   //Cep da Empresa
        cEmpEst :=IIF(EMPTY(SM0->M0_ESTCOB),SM0->M0_ESTENT,SM0->M0_ESTCOB)   //Estado da Empresa
        cEmpTel :=SM0->M0_TEL                                                //Telefone da Empresa   
        cEmpIns :=SM0->M0_INSC                                               //Inscricao Estadual da Empresa
		MsgRun(TRBARC->RA_MAT+"-"+cNomFunc,STR0007, {||})//"Processando Comprovante de Retencao"#"Aguarde..."
		//valores Informados na Manutencao IRSL-Os dados sao apenas preenchidos pelo usuario sem que haja o calculo pelo sistema
		DbSelectArea("RGS")
		RGS->(DbsetOrder(1))
		RGS->(DbGoTop())        
		If DbSeek(xFilial("RGS")+TRBARC->RA_MAT+cAnoBas)
			While RGS->(!eof()) .and. RGS->RGS_MAT == TRBARC->RA_MAT .AND. RGS->RGS_ANO == cAnoBas
				//Primeira Realacao
				If RGS->RGS_CODIGO=="1R"
					nVlrRemPR:=RGS->RGS_SALARI
					nVlrDedPR:=RGS->RGS_INSTEN+RGS->RGS_SEGSAL+RGS->RGS_SERVME+RGS->RGS_INTERA
					nVlrConPR:=RGS->RGS_QTDDEP
					nVlrAscPR:=RGS->RGS_DEPASC
					nVlrDesPR:=RGS->RGS_DEPDES
					nVlrTotPR:=nVlrConPR+nVlrAscPR+nVlrDesPR
				Endif	          
				//Primeira Variacao
				If RGS->RGS_CODIGO=="1V"
					nVlrRemPV:=RGS->RGS_SALARI
					nVlrDedPV:=RGS->RGS_INSTEN+RGS->RGS_SEGSAL+RGS->RGS_SERVME+RGS->RGS_INTERA
					nVlrConPV:=RGS->RGS_QTDDEP
					nVlrAscPV:=RGS->RGS_DEPASC
					nVlrDesPV:=RGS->RGS_DEPDES              
					nVlrTotPV:=nVlrConPV+nVlrAscPV+nVlrDesPV				
				Endif              
				//Segunda Variacao
				If RGS->RGS_CODIGO=="2V"
					nVlrRemSV:=RGS->RGS_SALARI
					nVlrDedSV:=RGS->RGS_INSTEN+RGS->RGS_SEGSAL+RGS->RGS_SERVME+RGS->RGS_INTERA
					nVlrConSV:=RGS->RGS_QTDDEP
					nVlrAscSV:=RGS->RGS_DEPASC
					nVlrDesSV:=RGS->RGS_DEPDES              
					nVlrTotSV:=nVlrConSV+nVlrAscSV+nVlrDesSV				
				Endif                 
				//Terceira variacao
				If RGS->RGS_CODIGO=="3V"
					nVlrRemTV:=RGS->RGS_SALARI
					nVlrDedTV:=RGS->RGS_INSTEN+RGS->RGS_SEGSAL+RGS->RGS_SERVME+RGS->RGS_INTERA
					nVlrConTV:=RGS->RGS_QTDDEP
					nVlrAscTV:=RGS->RGS_DEPASC
					nVlrDesTV:=RGS->RGS_DEPDES              
					nVlrTotTV:=nVlrConTV+nVlrAscTV+nVlrDesTV
				Endif	
				RGS->(DBSKIP())
			ENDDO
		Endif
		
  		DbSelectArea("RH9")
		RH9->(DbsetOrder(1))
		RH9->(DbGoTop())        
		If DbSeek(xFilial("RH9")+TRBARC->RA_MAT+cAnoBas)
			While RH9->(!eof()) .and. RH9->RH9_MAT == TRBARC->RA_MAT .AND. RH9->RH9_ANO == cAnoBas                                 
				nMes := Val(RH9->RH9_MES)
				aVlrMes[nMes][1]:=RH9->RH9_REMUNE
				aVlrMes[nMes][2]:=RH9->RH9_VLIMPO
				aVlrMes[nMes][3]:=RH9->RH9_PERIMP
				aVlrMes[nMes][4]:=RH9->RH9_REMACM			
				aVlrMes[nMes][5]:=RH9->RH9_IMPACM
				RH9->(DBSKIP())			                                                                                                                         	
			ENDDO
		ENDIF

		cMat:=TRBARC->RA_MAT
		Do While TRBARC->(!Eof()) .And. cMat==TRBARC->RA_MAT
			cDtArq :=TRBARC->RD_DATARQ//Ano+Mes
			nMes   :=Val(Substr(TRBARC->RD_DATARQ,5,2))	
			nVlrRem:=0     
			nVlrImp:=0
			Do While TRBARC->(!Eof()).And.cMat==TRBARC->RA_MAT.And.cDtArq==TRBARC->RD_DATARQ  
				If TRBARC->RV_DIRF=="01"//Remuneracao Salario
					nVlrRem+=TRBARC->RD_VALOR
                    nVlrSal1+=TRBARC->RD_VALOR
				ElseIf TRBARC->RV_DIRF=="02"//Remuneracao Utilidades
					nVlrRem+=TRBARC->RD_VALOR
                    nVlrSal2+=TRBARC->RD_VALOR
				ElseIf TRBARC->RV_DIRF=="03"//Remuneracao Bonificacoes
					nVlrRem+=TRBARC->RD_VALOR
                    nVlrSal3+=TRBARC->RD_VALOR
				ElseIf TRBARC->RV_DIRF=="04"//Remuneracao Gratificacoes
					nVlrRem+=TRBARC->RD_VALOR
					nVlrSal4+=TRBARC->RD_VALOR                    
				ElseIf TRBARC->RV_DIRF=="05"//Remuneracao Antiguidades
					nVlrRem+=TRBARC->RD_VALOR
					nVlrSal5+=TRBARC->RD_VALOR
				ElseIf TRBARC->RV_DIRF=="06"//Remuneracao Outros
					nVlrRem+=TRBARC->RD_VALOR
					nVlrSal6+=TRBARC->RD_VALOR
				ElseIf TRBARC->RV_DIRF=="07"//Imposto Retido
					nVlrImp+=TRBARC->RD_VALOR
				ElseIf TRBARC->RV_DIRF>"09"//OutrosAdicionais
					nVlrRem+=TRBARC->RD_VALOR
					nVlrSal7+=TRBARC->RD_VALOR					
				Endif
				TRBARC->(DbSkip())                
			End
		End  
		     
		nLin:=370                 
		nCol:=120       
		nLinRet:=0
		oPrint:StartPage()
		oPrint:Saybitmap(250,100,cStartPath+"ARC"+".JPG",2210,2300)    
		oPrint:Say(nLin  ,nCol+1740 ,"01"				,oArial10N)//"Periodo Inicio - Dia"
		oPrint:Say(nLin  ,nCol+1820 ,"01"				,oArial10N)//"Periodo Inicio - Mes"
		oPrint:Say(nLin  ,nCol+1900 ,SubStr(cAnoBas,3,2),oArial10N)//"Periodo Inicio - Ano"
		oPrint:Say(nLin  ,nCol+1980 ,"31"				,oArial10N)//"Periodo Final - Dia"
		oPrint:Say(nLin  ,nCol+2050 ,"12"				,oArial10N)//"Periodo Final - Mes"
		oPrint:Say(nLin  ,nCol+2130 ,SubStr(cAnoBas,3,2),oArial10N)//"Periodo Final - Ano"
		
		nLin+=150
		oPrint:Say(nLin  ,nCol      ,cNomFunc									,oArial10N)//"Sobrenome e Nome"
		If lNacVen                                                                                             
			oPrint:Say(nLin  ,1860  ,"X"     									,oArial10N)//"Venezuelano"
		Else
			oPrint:Say(nLin  ,1950  ,"X"    									,oArial10N)//"Venezuelano"		
		Endif	
		oPrint:Say(nLin  ,nCol+1890 ,cRgFunc					               	,oArial10N)//"RG"
	
		nLin+=250
		oPrint:Say(nLin  ,nCol+0100 ,cEmpNom	 								,oArial10N)//"Nome Pessoa Juridica"
		oPrint:Say(nLin  ,nCol+1340 ,cEmpRIF             			 			,oArial10N)//"CPF/CGC"
		oPrint:Say(nLin  ,nCol+1750 ,cEmpIns            						,oArial10N)//"Inscricao Estadual"
		
		nLin+=330
		oPrint:Say(nLin  ,nCol+0100 ,cEmpEnd	 	    						,oArial10N)//"Endereco Pessoa Juridica"
  		If nVlrSal1>0
			nLinRet += 10
			oPrint:Say(nLin+nLinRet ,nCol+1740 ,STR0011	 		 			    		,oArial10N)//"SALARIO"
			oPrint:Say(nLin+nLinRet,nCol+1910 ,AliDir(nVlrSal1  ,"@E 999,999,999.99")	,oArial10N)//"Valor da Retencao 1"
			nLinRet+=050  			
   		Endif
	   	If nVlrSal2>0		
			oPrint:Say(nLin+nLinRet,nCol+1740 ,STR0012	  		 	 		    		,oArial10N)//"UTILIDADES"
			oPrint:Say(nLin+nLinRet,nCol+1910 ,Alidir(nVlrSal2  ,"@E 999,999,999.99")	,oArial10N)//"Valor da Retencao 2"
			nLinRet+=060  			
	  	Endif
		nLin-=10	       
		oPrint:Say(nLin+120,nCol+0680 ,cEmpCid	 								,oArial10N)//"Cidade Pessoa Juridica 15"
		oPrint:Say(nLin+120,nCol+0920 ,cEmpCEP    		 						,oArial10N)//"CEP Pessoa Juridica 9"
		oPrint:Say(nLin+120,nCol+1220 ,cEmpEst	 								,oArial10N)//"UF Pessoa Juridica 15"
		oPrint:Say(nLin+120,nCol+1435 ,cEmpTel	 	  			    			,oArial10N)//"Tel. Pessoa Juridica 9"
	 	If nVlrSal3>0		
			oPrint:Say(nLin+nLinRet,nCol+1740 ,STR0013			 	 		   			,oArial10N)//"BONIFICACAO"
			oPrint:Say(nLin+nLinRet,nCol+1910 ,AliDir(nVlrSal3  ,"@E 999,999,999.99")	,oArial10N)//"Valor da Retencao 3"
			nLinRet+=050    
		Endif	
   		If nVlrSal4>0		
			oPrint:Say(nLin+nLinRet,nCol+1740 ,STR0014		 		 		   			,oArial10N)//"GRATIFICACAO"
			oPrint:Say(nLin+nLinRet,nCol+1910 ,AliDir(nVlrSal4  ,"@E 999,999,999.99")	,oArial10N)//"Valor da Retencao 4"
			nLinRet+=050    
   		Endif	
   		If nVlrSal5>0		                                                                                                       
			oPrint:Say(nLin+nLinRet,nCol+1740 ,STR0015			 	 		   			,oArial10N)//"ANTIGUIDADES"
			oPrint:Say(nLin+nLinRet,nCol+1910 ,AliDir(nVlrSal5  ,"@E 999,999,999.99")	,oArial10N)//"Valor da Retencao 5"
			nLinRet+=050    
   		Endif	
  		If nVlrSal6>0		
			oPrint:Say(nLin+nLinRet,nCol+1740 ,STR0016 		 	 		    			,oArial10N)//"Outros"
			oPrint:Say(nLin+nLinRet,nCol+1910 ,AliDir(nVlrSal6  ,"@E 999,999,999.99")	,oArial10N)//"Valor da Retencao 6"
			nLinRet+=045    
 		Endif	
  		If nVlrSal7>0		
			oPrint:Say(nLin+nLinRet,nCol+1740 ,STR0017		 	   						,oArial10N)//"OUTROS ADICIONAIS"
			oPrint:Say(nLin+nLinRet,nCol+1910 ,AliDir(nVlrSal7  ,"@E 999,999,999.99")	,oArial10N)//"Valor da Retencao 7"
 		Endif 
		nCol:=50
		nLin+=580                       
		oPrint:Say(nLin  ,nCol+0070 ,AliDir(aVlrMes[01][1],"@E 999,999,999.99")	,oArial10N)//"Janeiro - Remuneracao"
		oPrint:Say(nLin  ,nCol+0170 ,AliDir(aVlrMes[01][3],"@E 999.99")    		,oArial10N)//"Janeiro - Porcentagem"
		oPrint:Say(nLin  ,nCol+0350 ,AliDir(aVlrMes[01][2],"@E 9,999,999.99")	,oArial10N)//"Janeiro - Imposto retido"
		oPrint:Say(nLin  ,nCol+0560 ,AliDir(aVlrMes[01][4],"@E 999,999,999.99")	,oArial10N)//"Janeiro - Remuneracao acumulada"
		oPrint:Say(nLin  ,nCol+0740 ,AliDir(aVlrMes[01][5],"@E 9,999,999.99")	,oArial10N)//"Janeiro - Imposto retido acumulada"
		nLin+=050                                       
		oPrint:Say(nLin  ,nCol+0070 ,AliDir(aVlrMes[02][1],"@E 999,999.99")		,oArial10N)//"Fevereiro - Remuneracao"
		oPrint:Say(nLin  ,nCol+0170 ,AliDir(aVlrMes[02][3],"@E 999.99")   		,oArial10N)//"Fevereiro - Porcentagem"
		oPrint:Say(nLin  ,nCol+0350 ,AliDir(aVlrMes[02][2],"@E 9,999.99")		,oArial10N)//"Fevereiro - Imposto retido"
		oPrint:Say(nLin  ,nCol+0560 ,AliDir(aVlrMes[02][4],"@E 999,999,999.99")	,oArial10N)//"Fevereiro - Remuneracao acumulada"
		oPrint:Say(nLin  ,nCol+0740 ,AliDir(aVlrMes[02][5],"@E 9,999,999.99")	,oArial10N)//"Fevereiro - Imposto retido acumulada"
		nLin+=050
		oPrint:Say(nLin  ,nCol+0070 ,AliDir(aVlrMes[03][1],"@E 999,999.99")		,oArial10N)//"Marco - Remuneracao"
		oPrint:Say(nLin  ,nCol+0170 ,AliDir(aVlrMes[03][3],"@E 999.99")    		,oArial10N)//"Marco - Porcentagem"
		oPrint:Say(nLin  ,nCol+0350 ,AliDir(aVlrMes[03][2],"@E 9,999.99")		,oArial10N)//"Marco - Imposto retido"
		oPrint:Say(nLin  ,nCol+0560 ,AliDir(aVlrMes[03][4],"@E 999,999,999.99")	,oArial10N)//"Marco - Remuneracao acumulada"
		oPrint:Say(nLin  ,nCol+0740 ,AliDir(aVlrMes[03][5],"@E 9,999,999.99")	,oArial10N)//"Marco - Imposto retido acumulada"
		nLin+=030
		oPrint:Say(nLin  ,nCol+1270 ,AliDir(nVlrRemPR,"@E 999,999,999.99")		,oArial10N)//"Primeira Relacional - Remuneracao"
		oPrint:Say(nLin  ,nCol+1510 ,AliDir(nVlrDedPR,"@E 999,999,999.99") 		,oArial10N)//"Primeira Relacional - Deducao"
		oPrint:Say(nLin  ,nCol+1640 ,AliDir(nVlrConPR,"@E 999")					,oArial10N)//"Primeira Relacional - Cony"
		oPrint:Say(nLin  ,nCol+1720 ,AliDir(nVlrAscPR,"@E 999")					,oArial10N)//"Primeira Relacional - Asc"
		oPrint:Say(nLin  ,nCol+1790 ,AliDir(nVlrDesPR,"@E 999")		   			,oArial10N)//"Primeira Relacional - Desc"
		oPrint:Say(nLin  ,nCol+1860 ,AliDir(nVlrTotPR,"@E 9999")				,oArial10N)//"Primeira Relacional - Total"
		nLin+=020
		oPrint:Say(nLin  ,nCol+0070 ,AliDir(aVlrMes[04][1],"@E 999,999.99")		,oArial10N)//"Abril - Remuneracao"
		oPrint:Say(nLin  ,nCol+0170 ,AliDir(aVlrMes[04][3],"@E 999.99")    		,oArial10N)//"Abril - Porcentagem"
		oPrint:Say(nLin  ,nCol+0350 ,AliDir(aVlrMes[04][2],"@E 9,999.99")		,oArial10N)//"Abril - Imposto retido"
		oPrint:Say(nLin  ,nCol+0560 ,AliDir(aVlrMes[04][4],"@E 999,999,999.99")	,oArial10N)//"Abril - Remuneracao acumulada"
		oPrint:Say(nLin  ,nCol+0740 ,AliDir(aVlrMes[04][5],"@E 9,999,999.99")	,oArial10N)//"Abril - Imposto retido acumulada"
		nLin+=050
		oPrint:Say(nLin  ,nCol+0070 ,AliDir(aVlrMes[05][1],"@E 999,999.99")		,oArial10N)//"Maio - Remuneracao"
		oPrint:Say(nLin  ,nCol+0170 ,AliDir(aVlrMes[05][3],"@E 999.99")    		,oArial10N)//"Maio - Porcentagem"
		oPrint:Say(nLin  ,nCol+0350 ,AliDir(aVlrMes[05][2],"@E 9,999.99")		,oArial10N)//"Maio - Imposto retido"
		oPrint:Say(nLin  ,nCol+0560 ,AliDir(aVlrMes[05][4],"@E 999,999,999.99")	,oArial10N)//"Maio - Remuneracao acumulada"
		oPrint:Say(nLin  ,nCol+0740 ,AliDir(aVlrMes[05][5],"@E 9,999,999.99")	,oArial10N)//"Maio - Imposto retido acumulada"
		nLin+=030
		oPrint:Say(nLin  ,nCol+1270 ,AliDir(nVlrRemPV,"@E 999,999,999.99")		,oArial10N)//"Primeira Variacao - Remuneracao"
		oPrint:Say(nLin  ,nCol+1510 ,AliDir(nVlrDedPV,"@E 999,999,999.99") 		,oArial10N)//"Primeira Variacao - Deducao"
		oPrint:Say(nLin  ,nCol+1640 ,AliDir(nVlrConPV,"@E 999")					,oArial10N)//"Primeira Variacao - Conjuge"
		oPrint:Say(nLin  ,nCol+1720 ,AliDir(nVlrAscPV,"@E 999")					,oArial10N)//"Primeira Variacao - Ascendente"
		oPrint:Say(nLin  ,nCol+1790 ,AliDir(nVlrDesPV,"@E 999")		   			,oArial10N)//"Primeira Variacao - Descendente"
		oPrint:Say(nLin  ,nCol+1860 ,AliDir(nVlrTotPV,"@E 9999")				,oArial10N)//"Primeira Variacao - Total"
		nLin+=020
		oPrint:Say(nLin  ,nCol+0070 ,AliDir(aVlrMes[06][1],"@E 999,999.99")		,oArial10N)//"Junho - Remuneracao"
		oPrint:Say(nLin  ,nCol+0170 ,AliDir(aVlrMes[06][3],"@E 999.99")    		,oArial10N)//"Junho - Porcentagem"
		oPrint:Say(nLin  ,nCol+0350 ,AliDir(aVlrMes[06][2],"@E 9,999.99")		,oArial10N)//"Junho - Imposto retido"
		oPrint:Say(nLin  ,nCol+0560 ,AliDir(aVlrMes[06][4],"@E 999,999,999.99")	,oArial10N)//"Junho - Remuneracao acumulada"
		oPrint:Say(nLin  ,nCol+0740 ,AliDir(aVlrMes[06][5],"@E 9,999,999.99")	,oArial10N)//"Junho - Imposto retido acumulada"
		nLin+=050
		oPrint:Say(nLin  ,nCol+0070 ,AliDir(aVlrMes[07][1],"@E 999,999.99")		,oArial10N)//"Julho - Remuneracao"
		oPrint:Say(nLin  ,nCol+0170 ,AliDir(aVlrMes[07][3],"@E 999.99")    		,oArial10N)//"Julho - Porcentagem"
		oPrint:Say(nLin  ,nCol+0350 ,AliDir(aVlrMes[07][2],"@E 9,999.99")		,oArial10N)//"Julho - Imposto retido"
		oPrint:Say(nLin  ,nCol+0560 ,AliDir(aVlrMes[07][4],"@E 999,999,999.99")	,oArial10N)//"Julho - Remuneracao acumulada"
		oPrint:Say(nLin  ,nCol+0740 ,AliDir(aVlrMes[07][5],"@E 9,999,999.99")	,oArial10N)//"Julho - Imposto retido acumulada"
		nLin+=030
		oPrint:Say(nLin  ,nCol+1270 ,AliDir(nVlrRemSV,"@E 999,999,999.99")		,oArial10N)//"Segunda Variacao - Remuneracao"
		oPrint:Say(nLin  ,nCol+1510 ,AliDir(nVlrDedSV,"@E 999,999,999.99") 		,oArial10N)//"Segunda Variacao - Deducao"
		oPrint:Say(nLin  ,nCol+1640 ,AliDir(nVlrConSV,"@E 999")					,oArial10N)//"Segunda Variacao - Conjuge"
		oPrint:Say(nLin  ,nCol+1720 ,AliDir(nVlrAscSV,"@E 999")					,oArial10N)//"Segunda Variacao - Ascendente"
		oPrint:Say(nLin  ,nCol+1790 ,AliDir(nVlrDesSV,"@E 999")		   			,oArial10N)//"Segunda Variacao - Descendente"
		oPrint:Say(nLin  ,nCol+1860 ,AliDir(nVlrTotSV,"@E 9999")				,oArial10N)//"Segunda Variacao - Total"
		nLin+=020
		oPrint:Say(nLin  ,nCol+0070 ,AliDir(aVlrMes[08][1],"@E 999,999.99")		,oArial10N)//"Agosto - Remuneracao"
		oPrint:Say(nLin  ,nCol+0170 ,AliDir(aVlrMes[08][3],"@E 999.99")    		,oArial10N)//"Agosto - Porcentagem"
		oPrint:Say(nLin  ,nCol+0350 ,AliDir(aVlrMes[08][2],"@E 9,999.99")		,oArial10N)//"Agosto - Imposto retido"
		oPrint:Say(nLin  ,nCol+0560 ,AliDir(aVlrMes[08][4],"@E 999,999,999.99")	,oArial10N)//"Agosto - Remuneracao acumulada"
		oPrint:Say(nLin  ,nCol+0740 ,AliDir(aVlrMes[08][5],"@E 9,999,999.99")	,oArial10N)//"Agosto - Imposto retido acumulada"
		nLin+=050
		oPrint:Say(nLin  ,nCol+0070 ,AliDir(aVlrMes[09][1],"@E 999,999.99")		,oArial10N)//"Setembro - Remuneracao"
		oPrint:Say(nLin  ,nCol+0170 ,AliDir(aVlrMes[09][3],"@E 999.99")    		,oArial10N)//"Setembro - Porcentagem"
		oPrint:Say(nLin  ,nCol+0350 ,AliDir(aVlrMes[09][2],"@E 9,999.99")		,oArial10N)//"Setembro - Imposto retido"
		oPrint:Say(nLin  ,nCol+0560 ,AliDir(aVlrMes[09][4],"@E 999,999,999.99")	,oArial10N)//"Setembro - Remuneracao acumulada"
		oPrint:Say(nLin  ,nCol+0740 ,AliDir(aVlrMes[09][5],"@E 9,999,999.99")	,oArial10N)//"Setembro - Imposto retido acumulada"
		nLin+=030
		oPrint:Say(nLin  ,nCol+1270 ,AliDir(nVlrRemTV,"@E 999,999,999.99")		,oArial10N)//"Terceira Variacao - Remuneracao"
		oPrint:Say(nLin  ,nCol+1510 ,AliDir(nVlrDedTV,"@E 999,999,999.99") 		,oArial10N)//"Terceira Variacao - Deducao"
		oPrint:Say(nLin  ,nCol+1640 ,AliDir(nVlrConTV,"@E 999")					,oArial10N)//"Terceira Variacao - Conjuge"
		oPrint:Say(nLin  ,nCol+1720 ,AliDir(nVlrAscTV,"@E 999")					,oArial10N)//"Terceira Variacao - Ascendente"
		oPrint:Say(nLin  ,nCol+1790 ,AliDir(nVlrDesTV,"@E 999")		   			,oArial10N)//"Terceira Variacao - Descendente"
		oPrint:Say(nLin  ,nCol+1860 ,AliDir(nVlrTotTV,"@E 9999")				,oArial10N)//"Terceira Variacao - Total"
		nLin+=020
		oPrint:Say(nLin  ,nCol+0070 ,AliDir(aVlrMes[10][1],"@E 999,999.99")		,oArial10N)//"Outubro - Remuneracao"
		oPrint:Say(nLin  ,nCol+0170 ,AliDir(aVlrMes[10][3],"@E 999.99")    		,oArial10N)//"Outubro - Porcentagem"
		oPrint:Say(nLin  ,nCol+0350 ,AliDir(aVlrMes[10][2],"@E 9,999.99")		,oArial10N)//"Outubro - Imposto retido"
		oPrint:Say(nLin  ,nCol+0560 ,AliDir(aVlrMes[10][4],"@E 999,999,999.99")	,oArial10N)//"Outubro - Remuneracao acumulada"
		oPrint:Say(nLin  ,nCol+0740 ,AliDir(aVlrMes[10][5],"@E 9,999,999.99")	,oArial10N)//"Outubro - Imposto retido acumulada"
		nLin+=050
		oPrint:Say(nLin  ,nCol+0070 ,AliDir(aVlrMes[11][1],"@E 999,999.99")		,oArial10N)//"Novembro - Remuneracao"
		oPrint:Say(nLin  ,nCol+0170 ,AliDir(aVlrMes[11][3],"@E 999.99")   	 	,oArial10N)//"Novembro - Porcentagem"
		oPrint:Say(nLin  ,nCol+0350 ,AliDir(aVlrMes[11][2],"@E 9,999.99")		,oArial10N)//"Novembro - Imposto retido"
		oPrint:Say(nLin  ,nCol+0560 ,AliDir(aVlrMes[11][4],"@E 999,999,999.99")	,oArial10N)//"Novembro - Remuneracao acumulada"
		oPrint:Say(nLin  ,nCol+0740 ,AliDir(aVlrMes[11][5],"@E 9,999,999.99")	,oArial10N)//"Novembro - Imposto retido acumulada"
		nLin+=050
		oPrint:Say(nLin  ,nCol+0070 ,AliDir(aVlrMes[12][1],"@E 999,999.99")		,oArial10N)//"Dezembro - Remuneracao"
		oPrint:Say(nLin  ,nCol+0170 ,AliDir(aVlrMes[12][3],"@E 999.99")    		,oArial10N)//"Dezembro - Porcentagem"
		oPrint:Say(nLin  ,nCol+0350 ,AliDir(aVlrMes[12][2],"@E 9,999.99")      	,oArial10N)//"Dezembro - Imposto retido"
		oPrint:Say(nLin  ,nCol+0560 ,AliDir(aVlrMes[12][4],"@E 999,999,999.99")	,oArial10N)//"Dezembro - Remuneracao acumulada"
		oPrint:Say(nLin  ,nCol+0740 ,AliDir(aVlrMes[12][5],"@E 9,999,999.99") 	,oArial10N)//"Dezembro - Imposto retido acumulada"
        oPrint:EndPage()
	End   
Else
	Aviso(STR0010,STR0009 ,{ "OK" } )//"Atencao"#"Nao ha informacoes para serem geradas.Verifique os parametros"	
Endif	        
If aReturn[5]==1
	oPrint:Preview()
Endif
Return        

Static Function AliDir(nVlr,cPicture)
Local cRet:=""
If Len(Alltrim(Str(Int(nVlr))))==9                    
	cRet:=PADL(" ",1," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==8                    
	cRet:=PADL(" ",3," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==7                    
	cRet:=PADL(" ",5," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==6                    
	cRet:=PADL(" ",8," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==5                     
	cRet:=PADL(" ",10," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==4                       
	cRet:=PADL(" ",12," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==3                    
	cRet:=PADL(" ",15," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==2               
	cRet:=PADL(" ",17," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==1         
	cRet:=PADL(" ",19," ")+alltrim(Transform(nVlr,cPicture))
Endif	
If At("*",cRet)>0 .Or. Len(Alltrim(Str(Int(nVlr))))>9
	cRet:=PADL(" ",19," ")+"****"
Endif
Return cRet