#INCLUDE "PROTHEUS.CH"                       
#INCLUDE "RWMAKE.CH"  
#INCLUDE "GPER856.CH"
#INCLUDE "TOPCONN.CH"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Funcao   ³ GPER856 ³ Autor ³Paulo Eduardo                    ³ Data ³ 19/12/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Descricao³ Relación de Trabajadores - Apertura   de  Cuenta Ahorro Habitacional ³±±			
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Tiago Malta ³15/04/11³00000005374/2011³Ajustado erros de syntax no relatorio.   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³ Uso     ³ TOTVS    					                                       	   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function GPER856()
Local cString		:= "SRA"
Local nomeProg 	:= "GPER856"
Local cPerg     	:= "GPER856"
Local cQryRPVH		:= ""    
Local cDtNasc		:= "" ,	nSalFun    :=0 ,	nVlrEmp	:=0	,	nTFunEmp	:=0
Local cCodVer		:= "" ,	cDesVer    :="",	cMesAno	:="" 	,	cMat		:="", cCateg := "", cSit := "", nCtd :=0
Local cDtAdm  		:= "" ,  cDtDem	  :="" 	 
Local cTime			:= 0  ,	cPgm:=""
Local cDesc1		:= STR0001//"Relación de Trabajadores - Apertura   de  Cuenta  Ahorro  Habitacional"
Local cDesc2 		:= STR0002//"Ser  impresso de acordo com os parametros solicitados pelo"
Local cDesc3 		:= STR0003//"usuario."
Local aArea			:= GetArea()
Local cTamanho		:= "P"
Local aOrd      	:= {STR0026,STR0027,STR0028}		//"Sobrenome+Nome"###"Depto+Sobrenome+Nome"###"cc+Depto+sobrenome+Nome"###
Private oPrint
Private cTitulo 	:= STR0004//"Relación de Trabajadores - Apertura   de  Cuenta  Ahorro  Habitacional" 
Private aReturn 	:= {STR0005, 1,STR0006, 2, 1, 1, "",1 }//Zebrado#Administracao
Private oArial9N	:= TFont():New("Arial", 9, 9,,.T.,,,,.F.,.F.) 
Private oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.F.,.F.) 
Private oArial11N	:= TFont():New("Arial",11,11,,.T.,,,,.F.,.F.)
Private oArial12N	:= TFont():New("Arial",12,12,,.T.,,,,.F.,.F.)
Private oArial14N	:= TFont():New("Arial",14,14,,.T.,,,,.F.,.F.)
Private cStartPath:= GetSrvProfString("Startpath","")
Private dDatFat	:= CTOD("//"),dDatVen:= CTOD("//")  
Private dDataDia	:= Date() 

Private nSalario	:=0 , nSalMes		:=0 ,	nSalHora		:=0 ,	nSalDia		:=0 
Private cPrepar	:="",	cRevisa		:="",	cNBanco		:="",	cNAgenc		:=""
Private nContrato	:=0 , nTranEmp    :=0 , nTranFun 	:=0 , nVlrSTot		:=0, cUnidade		:=""
Private nVlrTot	:=0 ,	nVlrTFun		:=0 ,	nVlrTSal		:=0 ,	nVlrTEmp		:=0,  cDeptoAtu		:="", cCCustoAtu	:=""
Private nCi			:=0 ,	nNro			:=0 , nPag        :=0 , cDepto		:="", cCCusto	  		:="", nFilAtu     :=""
Private aRPVH		:= {}, cDesCC			:="", cDesDpto    :=""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "GPER856"             

wnrel:=SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,cTamanho,,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif
//================================
//================================
//  MV_PAR01 - FILIAL
//  MV_PAR02 - CENTRO DE CUSTO
//  MV_PAR03 - DEPTO
//  MV_PAR04 - MATRICULA
//  MV_PAR05 - NOME
//  MV_PAR06 - SITUACAO
//  MV_PAR07 - CATEGORIA  
//  MV_PAR08 - Tipo de Salario
//  MV_PAR09 - Contrato
//  MV_PAR10 - Unidade
//	 MV_PAR11 - Mes/Ano Referencia 
//  MV_PAR12 - Transac. Empresa
//  MV_PAR13 - Transac. Empregado
//  MV_PAR14 - Processo
//================================    

nFilial 		:= 	MV_PAR01     

If !Empty(MV_PAR06) 	
	cSit			:=		"'"
	For nCtd:=1 To Len(Alltrim(MV_PAR06))
	   If Substr(MV_PAR06,nCtd,1) <> '*'
			cSit+=Substr(MV_PAR06,nCtd,1)+"','"
	   EndIf
	Next                                  
	MV_PAR06:=Substr(cSit,1,Len(cSit)-2)
Else	
	MV_PAR06:="' '"
EndIf

If !Empty(MV_PAR07) 
	cCateg:="'"
	For nCtd:=1 To Len(Alltrim(MV_PAR07))
	   If Substr(MV_PAR07,nCtd,1) <> '*'
			cCateg+=Substr(MV_PAR07,nCtd,1)+"','"
	   EndIf
	Next                                  
	MV_PAR07:=Substr(cCateg,1,Len(cCateg)-2) 
Else	
	MV_PAR07:="' '"
EndIf




cTpSalario	:= 	MV_PAR08
nContrato 	:= 	MV_PAR09 
cUnidade 	:= 	MV_PAR10 

If !Empty(MV_PAR11)
	cMesAno		:= 	Substr(MV_PAR11,3,4)+Substr(MV_PAR11,1,2)
EndIf		
nTranEmp    := 	MV_PAR12
nTranFun    := 	MV_PAR13
//==============================================================================================================================================
//=================================================Processando dados RPVH======================================================================                                                                              
//==============================================================================================================================================
cQryRPVH:="SELECT RA_FILIAL,RA_MAT,RA_RG,RA_PRINOME,RA_SECNOME,RA_SALARIO,RA_NASC ,RA_ADMISSA,RA_DEMISSA, RA_CC, " 
cQryRPVH+=" RA_DEPTO, SRA.R_E_C_N_O_ AS REGSRA "
cQryRPVH+=" FROM "+RETSQLNAME("SRA")+" SRA
cQryRPVH+=" WHERE SRA.D_E_L_E_T_='' "
If !Empty(MV_PAR01)
	cQryRPVH += " 	AND "+RANGESX1("RA_FILIAL"	,MV_PAR01)  
EndIf
If !Empty(MV_PAR02)
	cQryRPVH += " 	AND "+RANGESX1("RA_CC"		,MV_PAR02)  
EndIf
If !Empty(MV_PAR03)
	cQryRPVH += " 	AND "+RANGESX1("RA_DEPTO"	,MV_PAR03)  
EndIf
If !Empty(MV_PAR04)
	cQryRPVH += " 	AND "+RANGESX1("RA_MAT"		,MV_PAR04)  
EndIf
If !Empty(MV_PAR05)
	cQryRPVH += " 	AND "+RANGESX1("RA_NOME"	,MV_PAR05)  
EndIf 

cQryRPVH += " 	AND RA_SITFOLH IN (" + MV_PAR06 + ")" 	

cQryRPVH += " 	AND RA_CATFUNC IN (" + MV_PAR07 + ")"  

If !Empty(MV_PAR14)
	cQryRPVH += " 	AND RA_PROCES='"+MV_PAR14+"' "  
EndIf 
cQryRPVH+=" AND RA_SITFOLH <> 'D' "
cQryRPVH+=" ORDER BY RA_PRINOME "
cQryRPVH := ChangeQuery(cQryRPVH)

If Select("TRBRPVH")>0
	DbSelectArea("TRBRPVH")
	TRBRPVH->(DbCloseArea())
Endif
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRPVH),"TRBRPVH",.F.,.T.)

  If TRBRPVH->(!Eof())
	Do While TRBRPVH->(!Eof())  
	   cDtAdm  := Substr(TRBRPVH->RA_ADMISSA,1,4) + Substr(TRBRPVH->RA_ADMISSA,5,2) //Admissao 
	   cDtDem  := Substr(TRBRPVH->RA_DEMISSA,1,4) + Substr(TRBRPVH->RA_DEMISSA,5,2) //Demissao 
	  
		If cDtAdm     == cMesAno .And. cDtDem     <> cMesAno //Dt. Adm. == Dt. Ref. And //Dt. Dem. <> Dt. Ref.           
			cMat		:=	TRBRPVH->RA_MAT     
			cNome		:=	Alltrim(TRBRPVH->RA_SECNOME)+" "+Alltrim(TRBRPVH->RA_PRINOME)  
			nCi		:=	TRBRPVH->RA_RG 
			cDepto	:= TRBRPVH->RA_DEPTO
			cCCusto	:= TRBRPVH->RA_CC    
			nRegSRA	:= TRBRPVH->REGSRA
			cFilSRA	:= TRBRPVH->RA_FILIAL
			nSalMes:=0
			cDtNasc:=0
			nVlrEmp:=0
		   nNro		:= nTranFun 
		   cDtNasc  := Substr(TRBRPVH->RA_NASC,7,2) + "/" + Substr(TRBRPVH->RA_NASC,5,2) + "/" + Substr(TRBRPVH->RA_NASC,1,4)
		
		  	If cTpSalario == 1 //1-Composto 2-Salario Base
		     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  //³ Monta as Variaveis de Salario Incorporado					 ³
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  			//-- Posiciona SRA
				//SRA->(DbGoto(aRPVH[nCont][8])) 
				SRA->(DbGoto(TRBRPVH->REGSRA))
		  		fSalInc(@nSalario,@nSalMes,@nSalHora,@nSalDia,.T.) 
		  		nSalFun  :=	nSalMes
		  	Else
			   nSalFun  := TRBRPVH->RA_SALARIO  
			Endif     
	   
	    	nVlrTot			+=	nSalFun
	
	   	Aadd(aRPVH,{nNro,cNome,nCi,cDtNasc,nSalFun,nVlrEmp,nTFunEmp,cDepto,cCCusto,nRegSRA,cFilSRA,})
	   Endif           
	   
		TRBRPVH->(DbSkip()) 
	End	      
	//aSort(aRPVH,,,{|x,y|x[2]<y[2]})      
	If aReturn[8] == 1 // Ordem retornada pela funcao SetPrint
		aSort(aRPVH,,,{|x,y|x[11]+x[2]<Y[11]+y[2]}) // Filial + SobreNome + Nome 
	ElseIf aReturn[8] == 2
		aSort(aRPVH,,,{|x,y|x[11]+x[8]+x[2]<Y[11]+y[8]+y[2]}) // Filial + Depto + SobreNome + Nome
	ElseIf aReturn[8] == 3
		aSort(aRPVH,,,{|x,y|x[11]+x[9]+x[8]+x[2]<Y[11]+y[9]+y[8]+y[2]}) // Filial + CCusto + Depto + SobreNome + Nome
	Else
	//	MsgAlert("Ordem Desconhecida!!","Atenção")
	EndIf 
	
	If nVlrTot	=	0
		Alert(STR0032,STR0033)//"Nao foram encontrados dados de acordo com o parametro.","Atencao"
	Else   
		MsgRun(STR0007,STR0008, {||CursorWait(),RelRPVH(aRPVH),CursorArrow()})//Aguarde...#Processando RPVH
	EndIf
	
Else
	Alert(STR0032,STR0033)//"Nao foram encontrados dados de acordo com o parametro.","Atencao"
Endif	
RestArea( aArea)
Return 
	
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ RelRPVH ³ Autor ³Paulo Eduardo             ³ Data ³ 19/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Contem todo o detalhe do relatorio  								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ TOTVS						                               			³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function RelRPVH(aRPVH)             
Local nCont:=0     ,nQtd:=0     
Local cChave := "" ,cChaveAtu := ""
Private nLin	:= 0
Private nCol	:= 0
          
oPrint:= TMSPrinter():New( cTitulo)
//oPrint := TMsPrinter():New(::cTitle,,,,,,::lPreview,cFile,(::nRemoteType == NO_REMOTE .or. ::cPrinterName == CONST_SEMIMPRESS),(::nDevice <> IMP_DISCO))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se ha impressora ativa conectada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! oPrint:IsPrinterActive() 
	oPrint:Setup()							//-- Escolhe a impressora	
	If ! oPrint:IsPrinterActive()	
		Help(" ",1,"NOPRINTGRA")		//-- Nao foi encontrada configuracao de impressora. ##Certifique-se de que as configurações da impressora estão corretas ou se há alguma impressora conectada.
		Return(Nil)
	Endif
Endif

oPrint:SetPortrait()

For nCont:=1 To Len(aRPVH)
	//-- Posiciona SRA
	SRA->(DbGoto(aRPVH[nCont][10])) 
	        
	//-- Controle de Quebra para opções 2 e 3 de ordenação
   If aReturn[8]==1			// Filial + SobreNome + Nome
   	cChaveAtu := aRPVH[nCont][11]
   ElseIf aReturn[8]==2		// Filial + Depto + SobreNome + Nome
   	cChaveAtu 	:= aRPVH[nCont][11] + aRPVH[nCont][8]    
		cDeptoAtu 	:= aRPVH[nCont][8]
   ElseIf aReturn[8]==3		// Filial + CCusto + Depto + SobreNome + Nome
   	cChaveAtu 	:= aRPVH[nCont][11] + aRPVH[nCont][9] + aRPVH[nCont][8]    
   	cCCustoAtu	:= aRPVH[nCont][9]
		cDeptoAtu 	:= aRPVH[nCont][8]
   EndIf
	If nCont == 1
		cChave := cChaveAtu
   	cCCustoAtu 	:= aRPVH[nCont][9]
		cDeptoAtu 	:= aRPVH[nCont][8]
		CabRPVH( SRA->RA_FILIAL )       
		nLin+=100 		
	EndIf
	
	If nQtd>20 .Or. cChave != cChaveAtu  
		cChave := cChaveAtu
		nQtd:=0  
		///////////////////////////////////////////////         
		oPrint:Box(nLin-50 ,2050,nLin+50,2400)  
		///////////////////////////////////////////////         
		oPrint:Say(nLin,nCol+1720 ,STR0031                               		  		,oArial10N)//SubTotais
		oPrint:Say(nLin,nCol+2050 ,Transform(nVlrSTot 		,"@R 999,999,999.99")	,oArial10N)//SubTotal 
		nLin+=100 
		// 
		//oPrint:Say(nLin,nCol+1000 ,STR0019,oArial10N)//<<<CONTINUA>>>
		oPrint:EndPage()	 
		oPrint:StartPage()	 
		CabRPVH( SRA->RA_FILIAL )       
		nLin+=100  
		
		cChave 		:= cChaveAtu  
   	cCCusto	 	:= cCCustoAtu
		cDepto 		:= cDeptoAtu
		nQtd   		:= 0			   
	Endif

	///////////////////////////////////////////////               
	oPrint:Box(nLin-50,nCol ,nLin+50,2400) 
	oPrint:Line(nLin-50, 250,nLin+50, 250) 
	oPrint:Line(nLin-50, 470,nLin+50, 470) 
	oPrint:Line(nLin-50,1630,nLin+50,1630)
	oPrint:Line(nLin-50,2050,nLin+50,2050)
	///////////////////////////////////////////////    
	oPrint:Say(nLin,nCol+20   ,StrZero(aRPVH[nCont][1],3),oArial10N)						//Transac. Fun.
	oPrint:Say(nLin,nCol+205  ,aRPVH[nCont][3],oArial10N)										//CI
	oPrint:Say(nLin,nCol+405  ,aRPVH[nCont][2],oArial9N)										//Sobrenome e Nome
	oPrint:Say(nLin,nCol+1700 ,aRPVH[nCont][4],oArial10N)										//Data de Nascimento
	oPrint:Say(nLin,nCol+2050 ,Transform(aRPVH[nCont][5],"@R 999,999,999.99"),oArial10N)//Valor do Salario Mensal
  
   nVlrSTot			+=	aRPVH[nCont][5] 
	nQtd++
	nLin+=100                        
Next  
If  nVlrSTot 	<> nVlrTot 
////
	oPrint:Box(nLin-50 ,2050,nLin+50,2400)  
	///////////////////////////////////////////////         
	oPrint:Say(nLin,nCol+1720 ,STR0031                               		  		,oArial10N)//SubTotais
	oPrint:Say(nLin,nCol+2050 ,Transform(nVlrSTot 		,"@R 999,999,999.99")	,oArial10N)//SubTotal 
	nQtd++
	nLin+=100   
EndIf	
////   
oPrint:Box(nLin-50 ,2050,nLin+50,2400)  
///////////////////////////////////////////////         
oPrint:Say(nLin,nCol+1800 ,STR0020                               		  		,oArial10N)//Totais
oPrint:Say(nLin,nCol+2050 ,Transform(nVlrTot 		,"@R 999,999,999.99")	,oArial10N)//Total 

nQtd++

oPrint:EndPage()                                    
If aReturn[5]==1
	MsgRun(STR0021,STR0007, {||CursorWait(),oPrint:Preview(),CursorArrow()})//Carregando#Aguarde... 
Else
	MsgRun(STR0022,STR0007, {||CursorWait(),oPrint:Print(),CursorArrow()})//Imprimindo#Aguarde... 
Endif
  				
Return           
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ CabRPVH  ³ Autor ³Paulo Eduardo             ³ Data ³ 19/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Cabecalho do relatorio RPVH      					       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ TOTVS						                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function CabRPVH( cFilSra )

Local cNomEmp := ""
Local cCNPJ   := ""
Local cEndEmp := ""

DbSelectArea("SM0")
Dbseek(cEmpAnt+cFilSra) 
cNomEmp	:=IIF(EMPTY(SM0->M0_NOMECOM),SM0->M0_NOME,SUBSTR(SM0->M0_NOMECOM,1,30))
cCNPJ	:=SM0->M0_CGC
cEndEmp	:=Substr(SM0->M0_ENDCOB,1,20)
	
nVlrSTot			:=	0 
nLin:=100
nCol:=80     
cTime:= TIME()  
cPgm:="SIGA/GPER856/v.P10"  

dbSelectArea("CTT")
dbSetOrder(1)
IF CTT->(dbSeek(xFilial("CTT",cFilAnt) + cCCustoAtu))
    cDesCC := CTT->CTT_DESC01
EndIf  

DbSelectArea("SQB")
SQB->(DbSetOrder(RetOrder("SQB","QB_FILIAL+QB_DEPTO")))
SQB->(DbGoTop())
If DbSeek(xFilial("SQB")+cDeptoAtu)
	cDesDpto:=SQB->QB_DESCRIC  
EndIf

nPag+= 1 
oPrint:Say(nLin+20,2230     	,"Pag.: " + Transform(nPag," 9,999") ,	oArial10N)// "Pagina" 
nLin+=90 
                        
oPrint:Say(nLin,nCol+10       ,cPgm  ,oArial10N)//PRW   
oPrint:Say(nLin,1980   	   ,STR0012,oArial10N)// "Data Emissao :" 
oPrint:Say(nLin,2250       	,DTOC(dDataDia),oArial10N)//Data Emissao
nLin+=30

oPrint:Say(nLin+20,nCol+10    ,cTime  ,	oArial10N)//Horas

oPrint:Say(nLin+20,1980     	,STR0024,	oArial10N)// "Data Ref. :" 
oPrint:Say(nLin+20,2250     	,Substr(MV_PAR11,1,2) + "/" + Substr(MV_PAR11,3,4),oArial10N)//Mes/Ano

oPrint:Say(nLin+100,nCol+240   ,STR0001,	oArial14N)//"Relación de Trabajadores - Apertura   de  Cuenta  Ahorro  Habitacional" 
nLin+=180

///////////////////////////////////////////////  
oPrint:Box(nLin+20,nCol ,nLin+280,2400)   
/////////////////////////////////////////////// 
oPrint:Say(nLin+50,100        ,STR0009,  oArial11N)// "Contrato :" 
oPrint:Say(nLin+50,330        ,Transform(nContrato,"@R 9999999"), oArial11N)//Numero do Contrato

oPrint:Say(nLin+50,600   		,STR0011,oArial11N)// "No. R.I.F. :" 
oPrint:Say(nLin+50,820   		,Transform(cCNPJ,"@R 999.999.999.999-99"),oArial11N)//código CGC   

oPrint:Say(nLin+50,1220      	,STR0013,oArial11N)// "Empresa : "  
oPrint:Say(nLin+50,1440      	,cNomEmp,oArial11N)//Empresa  

nLin+=80 

oPrint:Say(nLin+50,100        ,STR0010,oArial11N)// "Unidade :"  
oPrint:Say(nLin+50,330        ,cUnidade, oArial11N)//Codigo da Unidade  

oPrint:Say(nLin+50,600      	,STR0023,oArial11N)// "Endereco : "  
oPrint:Say(nLin+50,820      	,cEndEmp,oArial11N)//Endereco da Empresa  

If aReturn[8]==2		// Filial + Depto + SobreNome + Nome
	oPrint:Say(nLin+50,1220     		, STR0029 		+ ": " 									,oArial11N)
  	oPrint:Say(nLin+50,1440     		, cDeptoAtu		+ " - " 			+ cDesDpto	  	 	,oArial11N)
ElseIf aReturn[8]==3		// Filial + CCusto + Depto + SobreNome + Nome
  	oPrint:Say(nLin+50,1220     		, STR0030 		+ ": " 									,oArial11N)
  	oPrint:Say(nLin+50,1440     		, allTrim(cCCustoAtu)+ " - " 	+ cDesCC 			,oArial11N)    
EndIf

nLin+=80 

oPrint:Say(nLin+50,100        		,STR0025,oArial11N)// "Transac. :"  
oPrint:Say(nLin+50,330        		,StrZero(nTranEmp,3), oArial11N)//Transac. da Empresa 

If aReturn[8]==3		// Filial + CCusto + Depto + SobreNome + Nome
  	oPrint:Say(nLin+50,1220     		, STR0029 	+ ":" 						,oArial11N)    
	oPrint:Say(nLin+50,1440		     	, cDeptoAtu	+ " - " + cDesDpto	 	,oArial11N)
EndIf

//oPrint:Say(nLin+50,600      	,STR0023,oArial11N)// "Endereco : "  
//oPrint:Say(nLin+50,820      	,M0_ENDCOB,oArial11N)//Endereco da Empresa   
nLin+=170                 
///////////////////////////////////////////////  
oPrint:Box(nLin-50,nCol ,nLin+50,2400) 
oPrint:Line(nLin-50, 250,nLin+50, 250) 
oPrint:Line(nLin-50, 470,nLin+50, 470) 
oPrint:Line(nLin-50,1630,nLin+50,1630)
oPrint:Line(nLin-50,2050,nLin+50,2050)
///////////////////////////////////////////////
oPrint:Say(nLin,90        ,STR0014,oArial10N)//"Transac."
oPrint:Say(nLin,325       ,STR0015,oArial11N)//"C.I."
oPrint:Say(nLin,490       ,STR0016,oArial11N)//"Sobrenome e Nome"
oPrint:Say(nLin,1650      ,STR0017,oArial11N)//"Data de Nascimento"
oPrint:Say(nLin,2070      ,STR0018,oArial11N)//"Monto Bolivares" 

Return                            